[Beveridgean Unemployment Gap](https://www.pascalmichaillat.org/9.html)  
Pascal Michaillat, Emmanuel Saez
October 2020

----

### Replication Files

---

This document describes the files provided to replicate the results in the article. The results were obtain on a Mac running macOS Catalina 10.15.7 with the following software:

* Matlab R2020a
* Microsoft Excel 16.16.27

The results are produced through the following steps:

1. Run the Matlab script `baiPerron.m`. This script estimates the Beveridge elasticity, allowing for structural breaks in the Beveridge curve. The estimation results  are reported in the Matlab window.
2.  Run the Matlab script `beveridgeElasticity.m`. This script collects the results from the Bai-Perron algorithm and plots the Beveridge curve and Beveridge elasticity for the US, 1951--2019. The script saves the results in the Excel book `book.xlsx` so they can be used by the script `efficientUnemployment.m`. This script produces two sets of graphs:
* `elasticity.pdf`: The time series for the Beveridge elasticity, with its 95% confidence interval.
* `beveridgebreaks_n.pdf`, with $n$ between 1 and 6: The 6 branches of the Beveridge curve.
3. Run the Matlab script `efficientUnemployment.m`. This script plots the efficient unemployment rate for the US, 1951--2019, and various robustness checks. This script produces 6 graphs:
* `efficienttightness.pdf`: Time series for the efficient labor-market tightness.
* `efficientunemployment.pdf`: Time series for the efficient unemployment rate.
* `unemploymentgap.pdf`: Time series for the unemployment gap.
* `unemploymentgap_epsilon.pdf`: Range of efficient unemployment rates when the Beveridge elasticity takes all the values in its 95% confidence interval.
* `unemploymentgap_zeta.pdf`: Range of efficient unemployment rates when the social value of nonwork takes a range of plausible values.
* `unemploymentgap_kappa.pdf`: Range of efficient unemployment rates when the recruiting cost takes a range of plausible values.