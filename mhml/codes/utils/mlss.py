import lightgbm as lgb
import numpy as np
import pandas as pd
from rpy2.robjects import Formula, pandas2ri
from rpy2.robjects.packages import importr
from statsmodels.tools import add_constant
from tqdm.auto import tqdm

from sklearn.metrics import accuracy_score
from sklearn.metrics import roc_auc_score
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import GridSearchCV
from sklearn.svm import SVC
from sklearn.model_selection import train_test_split
from sklearn.ensemble import (
    GradientBoostingRegressor,
    RandomForestClassifier,
    RandomForestRegressor,
)
from sklearn.preprocessing import PolynomialFeatures
import re

pandas2ri.activate()

ivpack = importr("ivpack")
aer = importr("AER")
r_base = importr("base")
fixest = importr("fixest")


def hyperparameter_search(
    sample,
    x,
    y,
    depths=range(4, 10),
    n_estimators_lst=[60, 80, 100, 120, 140],
    verbose=False,
    rng=None,
    stratify=None,
):
    train, test = train_test_split(
        sample, test_size=0.1, random_state=rng, stratify=stratify
    )
    best_score = np.inf
    best_param = (None, None)
    for max_depth in tqdm(depths):
        for n_estimators in n_estimators_lst:
            clf = RandomForestRegressor(
                max_depth=max_depth, n_estimators=n_estimators, random_state=rng
            )
            clf.fit(train[x], train[y].values)
            score = -(
                np.corrcoef(
                    x=clf.predict(test[x]).flatten(), y=test[y].values.flatten()
                )[0, 1]
                ** 2
            )
            if verbose:
                r2 = (
                    np.corrcoef(
                        x=clf.predict(test[x]).flatten(), y=test[y].values.flatten()
                    )[0, 1]
                    ** 2
                )

                print(f"{max_depth}, {n_estimators}, {r2 * 100}")
            if score < best_score:
                best_param = max_depth, n_estimators
                best_score = score
    clf = RandomForestRegressor(max_depth=best_param[0], n_estimators=best_param[1])
    return clf, best_param


def train_random_forest(sample, new_data, x, y, clf):
    clf.fit(sample[x].values, sample[y].values)
    if type(new_data) is list:
        lst = []
        for nd in new_data:
            try:
                res = clf.predict_proba(nd[x].values)[:, 1]
            except AttributeError:
                res = clf.predict(nd[x].values)
            lst.append(res)
        return lst
    else:
        try:
            return clf.predict_proba(new_data[x].values)[:, 1]
        except AttributeError:
            return clf.predict(new_data[x].values)


def train_lgb(sample, new_data, x, y, **hyper_kwargs):
    """Train lightgbm"""
    d_train = lgb.Dataset(sample[x], label=sample[y])

    hyper_params = {
        "task": "train",
        "boosting_type": "gbdt",
        "objective": "regression",
        "metric": ["l2", "auc"],
        "learning_rate": 0.001,
        "num_leaves": 128,
        "max_bin": 128,
        "verbose": -1,
    }
    hyper_params.update(hyper_kwargs)

    gbm = lgb.train(hyper_params, d_train, num_boost_round=128, verbose_eval=False)
    if type(new_data) is list:
        return [gbm.predict(nd[x]) for nd in new_data]
    else:
        return gbm.predict(new_data[x])


def linear_prediction(sample, new_data, x, y):
    """Get predicted value on new_data from a regression of y ~ 1 + x"""
    design = add_constant(sample[x]).values
    coef = np.linalg.pinv(design.T @ design) @ design.T @ sample[y].values
    if type(new_data) is list:
        return [add_constant(nd[x]).values @ coef for nd in new_data]
    else:
        return add_constant(new_data[x].values) @ coef


def quadratic_prediction(sample, new_data, x, y):
    """Get predicted value on new_data from a regression of y ~ 1 + x + x^2"""
    design = add_constant(np.c_[sample[x].values, sample[x].values ** 2])
    coef = np.linalg.pinv(design.T @ design) @ design.T @ sample[y].values
    if type(new_data) is list:
        return [
            add_constant(np.c_[nd[x].values, nd[x].values ** 2]) @ coef
            for nd in new_data
        ]
    else:
        return add_constant(np.c_[new_data[x].values, new_data[x].values ** 2]) @ coef


def quadratic_prediction_with_interaction(sample, new_data, x, y):
    """Get predicted value on new_data from a regression of y ~ 1 + x + x^2"""
    ftrans = PolynomialFeatures(degree=2)
    design = ftrans.fit_transform(sample[x])

    coef = np.linalg.pinv(design.T @ design) @ design.T @ sample[y].values
    if type(new_data) is list:
        return [ftrans.fit_transform(nd[x]) @ coef for nd in new_data]
    else:
        return ftrans.fit_transform(new_data[x]) @ coef


def cubic_prediction_with_interaction(sample, new_data, x, y):
    """Get predicted value on new_data from a regression of y ~ 1 + x + x^2"""
    ftrans = PolynomialFeatures(degree=3)
    design = ftrans.fit_transform(sample[x])

    coef = np.linalg.pinv(design.T @ design) @ design.T @ sample[y].values
    if type(new_data) is list:
        return [ftrans.fit_transform(nd[x]) @ coef for nd in new_data]
    else:
        return ftrans.fit_transform(new_data[x]) @ coef


def construct_instrument(
    train_sample,
    test_sample,
    instruments,
    treatment,
    covariates=None,
    training=train_lgb,
    train_residual_sq=None,
    min_var=0.01,
    **training_kwargs,
):
    """Generate optimal instruments (no weighting)"""

    train_sample = train_sample.copy()

    d = train_sample[treatment].values

    # Predicting D with instruments
    predicted_d_train, predicted_d = training(
        train_sample,
        [train_sample, test_sample],
        x=instruments,
        y=treatment,
        **training_kwargs,
    )

    # Do OLS to align prediction
    pdt = add_constant(predicted_d_train)
    coef_pdt = np.linalg.pinv(pdt.T @ pdt) @ (pdt.T @ d)

    if train_residual_sq is not None:
        predicted_residual2_train, predicted_residual2 = training(
            train_sample,
            [train_sample, test_sample],
            x=instruments,
            y=train_residual_sq,
            **training_kwargs,
        )

    if (covariates is None) and (train_residual_sq is not None):
        return (
            add_constant(predicted_d) / predicted_residual2.clip(min=min_var)[:, None]
        )
    elif covariates is None:
        return predicted_d

    # Predicting X with instruments
    if train_residual_sq is None:
        predicted_covs = [
            [
                training(
                    train_sample,
                    [train_sample, test_sample],
                    x=instruments,
                    y=c,
                    **training_kwargs,
                )
                for c in covariates
            ]
        ]
        predicted_x_train_sample = np.array([y[0] for x in predicted_covs for y in x]).T
        predicted_x_test_sample = np.array([y[1] for x in predicted_covs for y in x]).T

        # Do OLS to align prediction
        pxt = add_constant(predicted_x_train_sample)
        coefmat_pxt = (
            np.linalg.pinv(pxt.T @ pxt) @ pxt.T @ train_sample[covariates].values
        )

        # X - predicted_x(instrument)
        x_resid = (
            train_sample[covariates].values
            - add_constant(predicted_x_train_sample) @ coefmat_pxt
        )

        # Linear coefficient on X from Robinson
        coef = np.linalg.pinv(x_resid.T @ x_resid) @ x_resid.T @ (d - predicted_d_train)

        predicted_d_instrument = add_constant(predicted_d) @ coef_pdt
        predicted_d_covariates = (
            test_sample[covariates].values
            - add_constant(predicted_x_test_sample) @ coefmat_pxt
        ) @ coef

        return predicted_d_instrument + predicted_d_covariates

    else:
        cov_res2 = []
        for c in covariates:
            train_sample[f"{c}_res2"] = (
                train_sample[c] * train_sample[train_residual_sq]
            )
            cov_res2.append(f"{c}_res2")

        # Predict x
        predicted_x = [
            [
                training(
                    train_sample,
                    [train_sample, test_sample],
                    x=instruments,
                    y=c,
                    **training_kwargs,
                )
                for c in covariates
            ]
        ]
        predicted_x_test = np.array([y[1] for x in predicted_x for y in x]).T

        # Predict XU
        predicted_covs = [
            [
                training(
                    train_sample,
                    [train_sample, test_sample],
                    x=instruments,
                    y=f"{c}_res2",
                    **training_kwargs,
                )
                for c in covariates
            ]
        ]

        predicted_x_train_sample = (
            np.array([y[0] for x in predicted_covs for y in x]).T
            / predicted_residual2_train[:, None]
        )
        predicted_x_test_sample = (
            np.array([y[1] for x in predicted_covs for y in x]).T
            / predicted_residual2[:, None]
        )

        tilde_x = test_sample[covariates].values - predicted_x_test_sample
        train_tilde_x = train_sample[covariates].values - predicted_x_train_sample

        conversion_matrix = (
            add_constant(train_sample[[treatment] + covariates].values).T
            @ train_tilde_x
            / len(train_tilde_x)
        )

        conversion_matrix = conversion_matrix @ np.linalg.pinv(
            train_tilde_x.T
            @ (train_sample[train_residual_sq].values[:, None] * train_tilde_x)
            / len(train_tilde_x)
        )

        return (
            np.c_[add_constant(predicted_d), predicted_x_test]
            / predicted_residual2.clip(min=min_var)[:, None]
        ) + (conversion_matrix @ tilde_x.T).T


def cross_fit_instruments(
    sample1,
    sample2,
    instruments,
    treatment,
    covariates=None,
    training=train_lgb,
    tune=False,
    clf=None,
    **kwargs,
):

    if clf is not None:
        training_kwargs = dict(clf=clf)
    elif tune:
        clf, best_param = hyperparameter_search(sample1, instruments, treatment)
        training_kwargs = dict(clf=clf)
    else:
        training_kwargs = dict()

    instrument_2 = construct_instrument(
        sample1,
        sample2,
        instruments,
        treatment=treatment,
        covariates=covariates,
        training=training,
        **training_kwargs,
        **kwargs,
    )

    instrument_1 = construct_instrument(
        sample2,
        sample1,
        instruments,
        treatment=treatment,
        covariates=covariates,
        training=training,
        **training_kwargs,
        **kwargs,
    )
    return instrument_1, instrument_2


def residualize(df, y, x):
    response = df[y].values
    rhs = add_constant(df[x].values)
    return response - rhs @ np.linalg.inv(rhs.T @ rhs) @ rhs.T @ response


def split_sample_ml(
    df,
    sample,
    instrument,
    treatment,
    outcome,
    covariates=None,
    training=train_lgb,
    name="mlss",
    **kwargs,
):
    sample1 = df[sample == 0].copy()
    sample2 = df[sample == 1].copy()

    inst_1, inst_2 = cross_fit_instruments(
        sample1, sample2, instrument, treatment, covariates, training=training, **kwargs
    )

    sample1[f"{name}_inst"] = inst_1
    sample2[f"{name}_inst"] = inst_2
    extract = (
        [outcome, treatment, f"{name}_inst"] + covariates
        if covariates
        else [outcome, treatment, f"{name}_inst"]
    )

    data = pd.concat([sample1, sample2], axis=0)[extract]
    
    data.to_csv("sample_data.csv")

    fwl_data = None
    if covariates is not None:
        y = residualize(data, outcome, covariates)
        d = residualize(data, treatment, covariates)
        z = residualize(data, f"{name}_inst", covariates)

        fwl_data = pd.DataFrame({"y": y, "d": d, "z": z})
    return data, fwl_data


def split_sample_ml_efficient(
    df,
    sample,
    instrument,
    treatment,
    outcome,
    covariates=None,
    training=train_lgb,
    name="mlss",
    **kwargs,
):

    sample1 = df[sample == 0].copy()
    sample2 = df[sample == 1].copy()

    inst_1, inst_2 = cross_fit_instruments(
        sample1, sample2, instrument, treatment, covariates, training=training, **kwargs
    )

    inst = np.r_[inst_1, inst_2]
    d = add_constant(np.r_[sample1[treatment].values, sample2[treatment].values])
    if covariates is not None:
        d = np.c_[d, np.r_[sample1[covariates].values, sample2[covariates].values]]
    y = np.r_[sample1[outcome].values, sample2[outcome].values]

    return np.linalg.pinv(inst.T @ d) @ (inst.T @ y)


def anderson_rubin(sample, fml1, fml2, conflevel=0.975):
    ivr = aer.ivreg(Formula(fml1), Formula(fml2), data=sample, x=True)
    return ivpack.anderson_rubin_ci(ivr, conflevel=conflevel)[0][0], ivr


def feols(fml, data):
    fit = fixest.feols(Formula(fml), data=data)
    tab = fit.rx["coeftable"][0]
    return tab, fit


def parse_ar(arstr):
    numbers = [float(n) for n in re.findall(r"[-+]?\d+\.\d+", arstr)]
    if "mpty" in arstr:
        return None, "empty"
    elif "union" in arstr:
        return numbers, "donut"
    elif len(numbers) == 0:
        return [-np.inf, np.inf], "interval"
    else:
        return numbers, "interval"


def parse_ars(ar1, ar2):
    inter1, typ1 = parse_ar(ar1)
    inter2, typ2 = parse_ar(ar2)
    if typ1 == typ2 == "interval":
        return [max(min(*inter1), min(*inter2)), min(max(*inter1), max(*inter2))]
    elif typ1 == "interval":
        return inter1
    elif typ2 == "interval":
        return inter2
    else:
        return [np.nan, np.nan]

