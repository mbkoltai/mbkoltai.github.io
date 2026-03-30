# Gross national income (GNI) per capita - Data package

This data package contains the data that powers the chart ["Gross national income (GNI) per capita"](https://ourworldindata.org/grapher/gross-national-income-per-capita-undp?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website.

## CSV Structure

The high level structure of the CSV file is that each row is an observation for an entity (usually a country or region) and a timepoint (usually a year).

The first two columns in the CSV file are "Entity" and "Code". "Entity" is the name of the entity (e.g. "United States"). "Code" is the OWID internal entity code that we use if the entity is a country or region. For normal countries, this is the same as the [iso alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) code of the entity (e.g. "USA") - for non-standard countries like historical countries these are custom codes.

The third column is either "Year" or "Day". If the data is annual, this is "Year" and contains only the year as an integer. If the column is "Day", the column contains a date string in the form "YYYY-MM-DD".

The remaining columns are the data columns, each of which is a time series. If the CSV data is downloaded using the "full data" option, then each column corresponds to one time series below. If the CSV data is downloaded using the "only selected data visible in the chart" option then the data columns are transformed depending on the chart type and thus the association with the time series might not be as straightforward.

## Metadata.json structure

The .metadata.json file contains metadata about the data package. The "charts" key contains information to recreate the chart, like the title, subtitle etc.. The "columns" key contains information about each of the columns in the csv, like the unit, timespan covered, citation for the data etc..

## About the data

Our World in Data is almost never the original producer of the data - almost all of the data we use has been compiled by others. If you want to re-use data, it is your responsibility to ensure that you adhere to the sources' license and to credit them correctly. Please note that a single time series may have more than one source - e.g. when we stich together data from different time periods by different producers or when we calculate per capita metrics using population data from a second source.

### How we process data at Our World In Data
All data and visualizations on Our World in Data rely on data sourced from one or several original data providers. Preparing this original data involves several processing steps. Depending on the data, this can include standardizing country names and world region definitions, converting units, calculating derived indicators such as per capita measures, as well as adding or adapting metadata such as the name or the description given to an indicator.
[Read about our data pipeline](https://docs.owid.io/projects/etl/)

## Detailed information about each time series


## Gross national income per capita
Average income per person earned by residents of a country or region, including income earned abroad. This data is adjusted for inflation and for differences in living costs between countries.
Last updated: May 7, 2025  
Next update: May 2026  
Date range: 1990–2023  
Unit: international-$ in 2021 prices  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UNDP, Human Development Report (2025) – with minor processing by Our World in Data

#### Full citation
UNDP, Human Development Report (2025) – with minor processing by Our World in Data. “Gross national income per capita – UNDP – In constant international-$” [dataset]. UNDP, Human Development Report, “Human Development Report” [original data].
Source: UNDP, Human Development Report (2025) – with minor processing by Our World In Data

### What you should know about this data
* Gross national income (GNI) is a measure of the total income earned by residents of a country or region each year. It is calculated as GDP plus net income received from abroad, plus taxes (minus subsidies) on production. GNI per capita is GNI divided by population.
* This GNI per capita indicator provides information on economic growth and income levels from 1990.
* This data is adjusted for inflation and for differences in living costs between countries.
* This data is expressed in [international-$](#dod:int_dollar_abbreviation) at 2021 prices.
* Higher GNI per capita typically signals greater average command over resources, but says little about distribution, non‑market production or environmental costs.
* Subject to revisions when PPP benchmarks are updated; omits remittances/leakages in informal economies; exchange‑rate mis‑measurement can bias cross‑country comparisons.

### How is this data described by its producer - UNDP, Human Development Report (2025)?
UNDP relies on IMF (2023), UNDESA (2023), United Nations Statistics Division (2023), World Bank (2023).

The World Bank's 2023 World Development Indicators database contains estimates of GNI per capita in constant 2021 purchasing power parity (PPP) terms for many countries. For countries missing this indicator (entirely or partly), the Human Development Report Office calculates it by converting GNI per capita in local currency from current to constant terms using two steps. First, the value of GNI per capita in current terms is converted into PPP terms for the base year (2021). Second, a time series of GNI per capita in 2021 PPP constant terms is constructed by applying the real growth rates to the GNI per capita in PPP terms for the base year. The real growth rate is implied by the ratio of the nominal growth of GNI per capita in current local currency terms to the GDP deflator.

For several countries without a value of GNI per capita in constant 2021 PPP terms for 20 22 reported in the World Development Indicators database, real growth rates of GDP per capita available in the World Development Indicators database or in the International Monetary Fund's Economic Outlook database are applied to the most recent GNI values in constant PPP terms.

Official PPP conversion rates are produced by the International Comparison Program, whose surveys periodically collect thousands of prices of matched goods and services in many countries. The last round of this exercise refers to 2021 and covered 176 economies.

### Source

#### UNDP, Human Development Report – Human Development Report
Retrieved on: 2025-05-07  
Retrieved from: https://hdr.undp.org/  


## World regions according to OWID
Regions defined by Our World in Data, which are used in OWID charts and maps.
Last updated: January 1, 2023  
Date range: 2023–2023  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Our World in Data – processed by Our World in Data

#### Full citation
Our World in Data – processed by Our World in Data. “World regions according to OWID” [dataset]. Our World in Data, “Regions” [original data].
Source: Our World in Data

### Source

#### Our World in Data – Regions


    