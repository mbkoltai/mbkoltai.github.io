# GDP per employed person - Data package

This data package contains the data that powers the chart ["GDP per employed person"](https://ourworldindata.org/grapher/gdp-per-person-employed-constant-ppp?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website. It was downloaded on December 02, 2025.

### Active Filters

A filtered subset of the full data was downloaded. The following filters were applied:

## CSV Structure

The high level structure of the CSV file is that each row is an observation for an entity (usually a country or region) and a timepoint (usually a year).

The first two columns in the CSV file are "Entity" and "Code". "Entity" is the name of the entity (e.g. "United States"). "Code" is the OWID internal entity code that we use if the entity is a country or region. For normal countries, this is the same as the [iso alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) code of the entity (e.g. "USA") - for non-standard countries like historical countries these are custom codes.

The third column is either "Year" or "Day". If the data is annual, this is "Year" and contains only the year as an integer. If the column is "Day", the column contains a date string in the form "YYYY-MM-DD".

The final column is the data column, which is the time series that powers the chart. If the CSV data is downloaded using the "full data" option, then the column corresponds to the time series below. If the CSV data is downloaded using the "only selected data visible in the chart" option then the data column is transformed depending on the chart type and thus the association with the time series might not be as straightforward.

## Metadata.json structure

The .metadata.json file contains metadata about the data package. The "charts" key contains information to recreate the chart, like the title, subtitle etc.. The "columns" key contains information about each of the columns in the csv, like the unit, timespan covered, citation for the data etc..

## About the data

Our World in Data is almost never the original producer of the data - almost all of the data we use has been compiled by others. If you want to re-use data, it is your responsibility to ensure that you adhere to the sources' license and to credit them correctly. Please note that a single time series may have more than one source - e.g. when we stich together data from different time periods by different producers or when we calculate per capita metrics using population data from a second source.

## Detailed information about the data


## GDP per person employed (constant 2021 PPP $)
Last updated: September 8, 2025  
Next update: September 2026  
Date range: 1991–2024  
Unit: constant 2021 PPP $  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
World Bank, International Labour Organization, United Nations Population Division, Eurostat, and OECD (2025) – processed by Our World in Data

#### Full citation
World Bank, International Labour Organization, United Nations Population Division, Eurostat, and OECD (2025) – processed by Our World in Data. “GDP per person employed (constant 2021 PPP $)” [dataset]. World Bank, International Labour Organization, United Nations Population Division, Eurostat, and OECD, “World Development Indicators 122” [original data].
Source: World Bank, International Labour Organization, United Nations Population Division, Eurostat, and OECD (2025) – processed by Our World In Data

### How is this data described by its producer - World Bank, International Labour Organization, United Nations Population Division, Eurostat, and OECD (2025)?
GDP per person employed is gross domestic product (GDP) divided by total employment in the economy. Purchasing power parity (PPP) GDP is GDP converted to 2021 constant international dollars using PPP rates. An international dollar has the same purchasing power over GDP that a U.S. dollar has in the United States.

### Limitations and exceptions:
For comparability of individual sectors labor productivity is estimated according to national accounts conventions. However, there are still significant limitations on the availability of reliable data. Information on consistent series of output in both national currencies and purchasing power parity dollars is not easily available, especially in developing countries, because the definition, coverage, and methodology are not always consistent across countries. For example, countries employ different methodologies for estimating the missing values for the nonmarket service sectors and use different definitions of the informal sector.

### Statistical concept and methodology:
GDP per person employed represents labor productivity—output per unit of labor input. To compare labor productivity levels across countries, GDP is converted to international dollars using purchasing power parity rates which take account of differences in relative prices between countries.

Estimates are based on employment, population, GDP, and PPP data obtained from International Labour Organization, United Nations Population Division, Eurostat, OECD, and World Bank. The employment rates are part of the "ILO modeled estimates database," including nationally reported observations and imputed data for countries with missing data, primarily to capture regional and global trends with consistent country coverage. Country-reported microdata is based mainly on nationally representative labor force surveys, with other sources (e.g., household surveys and population censuses) considering differences in the data source, the scope of coverage, methodology, and other country-specific factors. Country analysis requires caution where limited nationally reported data are available. A series of models are also applied to impute missing observations and make projections. However, imputed observations are not based on national data, are subject to high uncertainty, and should not be used for country comparisons or rankings. For more information: https://ilostat.ilo.org/resources/concepts-and-definitions/ilo-modelled-estimates/

### Notes from original source:
Given the exceptional situation, including the scarcity of relevant data, the ILO modeled estimates and projections from 2020 onwards are subject to substantial uncertainty.

### Source

#### World Bank, International Labour Organization, United Nations Population Division, Eurostat, and OECD – World Development Indicators
Retrieved on: 2025-09-08  
Retrieved from: https://data.worldbank.org/indicator/SL.GDP.PCAP.EM.KD  


    