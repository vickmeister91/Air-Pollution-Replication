@echo off
cd /d "%~dp0"
echo Running R script...
Rscript merge_clean_version.R
echo R script finished.

echo Running Stata do-file...
StataMP-64 -b do "Dataset preparation.do"
echo Stata do-file finished.

