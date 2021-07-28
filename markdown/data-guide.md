# Data Guide

In this Jupyter book, we calibrate our models to US data and use `FRED` to get our data series. However, the models are generalizable, and can be applied to other countries. To help you make better use of this project, we compile a list of macro data sources. We also provide references on how users can retrieve data from these sources using Python.

## International Sources

| Name                                                 | API|
| ---------------------------------------------------- | -----------   |
| World Bank Group                                     | [WBGAPI](https://pypi.org/project/wbgapi/)      |
| International Monetary Fund                          | [SDMX](http://www.bd-econ.com/imfapi1.html)|
| Eurostat                                             | [SDMX](https://ec.europa.eu/eurostat/online-help/public/en/API_06_DataQuery_en/) and [eurostat](https://pypi.org/project/eurostat/)     |
| United Nations                                       | [SDMX](https://data.un.org/Host.aspx?Content=API)        |
| Bank for International Settlements                   | [SDMX](https://www.bis.org/statistics/sdmx.htm) |
| European Central Bank                                | [SDMX](https://sdw-wsrest.ecb.europa.eu/help/). Additional tutorial [here](https://www.pythonsherpa.com/static/files/html/ECB%20-%20Open%20Data.html) |
| International Labor Organization                     | [SDMX](https://www.ilo.org/sdmx/index.html)|
| Organization for Economic Cooperation and Development| [SDMX](https://data.oecd.org/api/sdmx-ml-documentation/)|

## Country-Specific Sources
| Name                                                  | Country   | API |
| ------------                                          | -------   | -----------   |
| Australian Bureau of Statistics                       | Australia | [SDMX](https://api.gov.au/service/715cdfd0-4742-402e-8729-086a7fd42a51/Getting%20Started)  |
| Bundesbank                                            | Germany   | [SDMX](https://api.statistiken.bundesbank.de/doc/index.html)|
| National Institute of Statistics and Economic Studies | France    | [SDMX](https://www.insee.fr/en/information/2868055)|
| National Institute of Statistics                      | Italy     | [SDMX](https://developers.italia.it/it/api/istat-sdmx-rest/) |
| Norges Bank                                           | Norway    | [SDMX](https://app.norges-bank.no/query/#/en/)|

```{tip}
As shown above, `SDMX`, which stands for Statistical Data and Metadata Exchange, is an API protocol that is widely used internationally. [pandasdmx](https://pandasdmx.readthedocs.io/en/v1.0/) is a useful Python package for data retrieval under the SDMX API format. [Here](https://pandasdmx.readthedocs.io/en/v1.0/example.html) is an example of how you can retrieve data with the `pandasdmx` package from Eurostat. 
```

```{note}
This list of references is by no means exhaustive. If you have any recommendation on additional data sources and their corresponding API references and would like to share them with us, feel free to write to us using the **raise issue** option under the Github icon in the top right corner. Thanks a lot in advance! 
```