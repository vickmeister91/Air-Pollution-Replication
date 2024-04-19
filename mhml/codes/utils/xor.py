import numpy as np
from numpy.lib.histograms import _unsigned_subtract
from scipy.special import expit
import pandas as pd
from .mlss import (
    split_sample_ml,
    Formula,
    anderson_rubin,
    fixest,
    aer,
    ivpack,
    train_lgb,
    train_random_forest,
    parse_ars,
    split_sample_ml_efficient,
)
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.preprocessing import PolynomialFeatures
from rpy2.rinterface_lib.embedded import RRuntimeError
from itertools import product


def compute_propensity(w):
    rad = w[:, 0] ** 2 + w[:, 1] ** 2
    w12 = np.where(rad > 1, 0.1, np.where(w[:, 0] * w[:, 1] > 0, rad, -rad,),)
    return expit(3 * w12) * np.sin(2 * w[:, 2]) ** 2


def oracle_prediction(sample, new_data, x, y):
    if type(new_data) is list:
        return [compute_propensity(nd[x].values) for nd in new_data]
    else:
        return compute_propensity(new_data[x].values)


def compute_skedasticity(w):
    return 0.1 + expit((w[:, 0] + w[:, 1]) * w[:, 2])


def sim(seed, n):
    rng = np.random.RandomState(seed)

    w = rng.randn(n, 3)
    prob = compute_propensity(w)
    d = (rng.rand(n) <= prob).astype(float)
    err = (d - prob) * np.abs(rng.randn(n))
    u = rng.randn(n)
    u = 0.5 * err + (1 - 0.5 ** 2) ** 0.5 * u

    y = d + compute_skedasticity(w) * u

    split = (rng.rand(n) > 0.5).astype(int)
    return pd.DataFrame(
        {"y": y, "d": d, **{f"w{k}": w[:, k] for k in range(3)}, "split": split}
    )


def sim_with_covariates(seed, n):
    data = sim(seed, n)
    mat = np.array([[1, 0.5], [0.4, 2], [0.3, 0.2]])

    rng = np.random.RandomState(seed + 1)
    x = data[["w0", "w1", "w2"]] @ mat + rng.randn(len(data), 2)
    data.loc[:, ["x0", "x1"]] = x.values

    prob = rng.rand(len(data)) < 0.3

    err = data["y"] - data["d"]
    data["d"] = np.where(prob & (data["x0"] > 0), 1 - data["d"], data["d"])
    data["y"] = data["d"] + x @ np.array([0.1, -0.3]) + err
    return data


def discretize_column(c):
    return (c[:, None] < np.array([[-1, 0, 1, 1000]])).argmax(1)


def discretize_data(df):
    k = df.shape[1]
    discretized = []
    for i in range(k):
        discretized.append(discretize_column(df.iloc[:, i].values))

    max_cat = discretized[0].max() + 1
    products = product(*[list(range(max_cat)) for _ in range(len(discretized))])
    cols = []
    for tup in products:
        col = np.ones(len(df))
        for k, dc in zip(tup, discretized):
            col *= dc == k
        cols.append(col)
    return np.array(cols).T


def discretized_prediction(sample, new_data, x, y):
    """Get predicted value on new_data from a regression of y ~ 1 + x + x^2"""
    design = discretize_data(sample[x])

    coef = np.linalg.pinv(design.T @ design) @ design.T @ sample[y].values
    if type(new_data) is list:
        return [discretize_data(nd[x]) @ coef for nd in new_data]
    else:
        return discretize_data(new_data[x]) @ coef


def ml_experiment_efficient(seed, n, training, name, clf=None, covariates=False):
    if not covariates:
        df = sim(seed, n)
        split = df["split"].values
        data, _ = split_sample_ml(
            df,
            split,
            ["w0", "w1", "w2"],
            "d",
            "y",
            training=training,
            name=name,
            tune=False,
            clf=clf,
        )
    else:
        df = sim_with_covariates(seed, n)
        split = df["split"].values
        _, data = split_sample_ml(
            df,
            split,
            ["w0", "w1", "w2"],
            "d",
            "y",
            covariates=["x0", "x1"],
            training=training,
            name=name,
            tune=False,
            clf=clf,
        )
        data.columns = ["y", "d", f"{name}_inst"]
    fml = Formula(f"y ~ 1 | d ~ {name}_inst")

    try:
        fit = fixest.feols(fml, data=data, se="hetero")
        est, se, _, _ = fit.rx["coeftable"][0].T["fit_d"]

        resid = data["y"] - est * data["d"]
        df["resid2"] = resid ** 2

        parameter_estimate = split_sample_ml_efficient(
            df,
            df["split"],
            ["w0", "w1", "w2"],
            "d",
            "y",
            covariates=["x0", "x1"] if covariates else None,
            training=lgb_trainer,
            name="lgb",
            train_residual_sq="resid2",
        )
        return parameter_estimate
    except RRuntimeError:
        return None


def ml_experiment(seed, n, training, name, clf=None, covariates=False):
    if not covariates:
        df = sim(seed, n)
        split = df["split"].values
        data, _ = split_sample_ml(
            df,
            split,
            ["w0", "w1", "w2"],
            "d",
            "y",
            training=training,
            name=name,
            tune=False,
            clf=clf,
        )
    else:
        df = sim_with_covariates(seed, n)
        split = df["split"].values
        _, data = split_sample_ml(
            df,
            split,
            ["w0", "w1", "w2"],
            "d",
            "y",
            covariates=["x0", "x1"],
            training=training,
            name=name,
            tune=False,
            clf=clf,
        )
        data.columns = ["y", "d", f"{name}_inst"]
    fml = Formula(f"y ~ 1 | d ~ {name}_inst")

    try:
        fit = fixest.feols(fml, data=data, se="hetero")
        est, se, _, _ = fit.rx["coeftable"][0].T["fit_d"]

        arci1, _ = anderson_rubin(
            data.loc[df.loc[split == 1].index],
            "y ~ 1 + d",
            f"~ {name}_inst",
            conflevel=0.975,
        )
        arci2, _ = anderson_rubin(
            data.loc[df.loc[split == 0].index],
            "y ~ 1 + d",
            f"~ {name}_inst",
            conflevel=0.975,
        )

        lb, ub = parse_ars(arci1, arci2)
        f_stat = fixest.fitstat(fit, type="F")[0][0][0]
        wald = (est - 1) / se
    except RRuntimeError:
        est = se = wald = f_stat = wald = arci1 = arci2 = lb = ub = None

    r2 = data[["d", f"{name}_inst"]].corr().iloc[0, 1] ** 2

    return pd.Series(
        [name, est, se, wald, f_stat, r2, arci1, arci2, lb, ub],
        index=[
            "name",
            "estimate",
            "se",
            "wald",
            "f_stat",
            "r2",
            "arci1",
            "arci2",
            "ar_lb",
            "ar_ub",
        ],
    )


def tsls_estimator(seed, n, basis, covariates=False):
    if covariates:
        df = sim_with_covariates(seed, n)
    else:
        df = sim(seed, n)

    inst = df[["w0", "w1", "w2"]]
    instruments = None
    if basis == "discretized":
        instruments = discretize_data(inst).argmax(1)[:, None]
    elif basis.startswith("lin"):
        instruments = inst.copy().values
    elif basis == "quad":
        instruments = np.c_[inst.values, inst.values ** 2]
    elif basis == "quad_inter":
        ftrans = PolynomialFeatures(degree=2)
        instruments = ftrans.fit_transform(inst)[:, 1:]
    elif basis == "cubic_inter":
        ftrans = PolynomialFeatures(degree=3)
        instruments = ftrans.fit_transform(inst)[:, 1:]
    instruments = pd.DataFrame(
        instruments,
        index=df.index,
        columns=[f"inst_{i}" for i in range(instruments.shape[1])],
    )

    try:
        df.loc[:, instruments.columns] = instruments.values
        inst_fml = (
            " + ".join(instruments.columns)
            if basis != "discretize"
            else " factor(inst_0) "
        )
        fml = (
            Formula(f"y ~ 1 | d ~ {inst_fml}")
            if not covariates
            else Formula(f"y ~ 1 + x0 + x1 | d ~ {inst_fml}")
        )

        fit = fixest.feols(fml, data=df, se="hetero")
        est, se, _, _ = fit.rx["coeftable"][0].T["fit_d"]

        arci, _ = anderson_rubin(
            df,
            "y ~ 1 + d" if not covariates else "y ~ 1 + d + x0 + x1",
            f"~ {inst_fml}" if not covariates else f"~ 1 + {inst_fml} + x0 + x1",
            conflevel=0.95,
        )
    except RRuntimeError:
        arci = est = se = np.nan
    return pd.Series(
        [basis, est, se, (est - 1) / se, arci],
        index=["name", "estimate", "se", "wald", "arci"],
    )


def lgb_trainer(*args, **kwargs):
    return train_lgb(*args, **kwargs, learning_rate=0.01, num_leaves=64)


rf = RandomForestClassifier(n_estimators=60, max_depth=5)
rf_cont = RandomForestRegressor(n_estimators=60, max_depth=5)
