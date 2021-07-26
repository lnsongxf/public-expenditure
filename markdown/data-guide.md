# Data Guide

In this Jupyter book, we usually calibrate our models to US data. However, the models are generalizable, and can be applied to other countries. To help users make the most out of it, we compile a list of data sources for macroeconomic data across different countries. We also provide links to Python APIs that allow users to import these data series directly.

| Data Source | API         | Notes       |
| ----------- | ----------- | ----------- |
| World Bank  | [WBGAPI](https://pypi.org/project/wbgapi/)      |             |
| IMF         |   [JSON RESTful](http://www.bd-econ.com/imfapi1.html)          |             |
| IFS         | [WBGAPI](https://pypi.org/project/wbgapi/)      |             |
| Eurostat    | [WBGAPI](https://pypi.org/project/wbgapi/)      |             |
|UN           | | |
|BIS          | | |
|ECB       | | |
|ILO      | | |
|OECD    | | |

```{Note}
[pandasdmx](https://pandasdmx.readthedocs.io/en/v1.0/) is a useful package for the data sources that have **SDMX** API format. 
```
