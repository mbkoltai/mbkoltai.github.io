# GDP per capita - Data package

This data package contains the data that powers the chart ["GDP per capita"](https://ourworldindata.org/grapher/gdp-per-capita-worldbank?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website. It was downloaded on December 10, 2024.

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


## GDP per capita – In constant 2017 international $ – World Bank
This data is adjusted for inflation and for differences in the cost of living between countries.
Last updated: May 20, 2024  
Next update: May 2025  
Date range: 1990–2022  
Unit: international-$ in 2017 prices  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
World Bank (2023) – with minor processing by Our World in Data

#### Full citation
World Bank (2023) – with minor processing by Our World in Data. “GDP per capita – World Bank – In constant 2017 international $” [dataset]. World Bank, “World Bank World Development Indicators” [original data].
Source: World Bank (2023) – with minor processing by Our World In Data

### What you should know about this data
* This GDP per capita indicator provides information on economic growth and income levels from 1990.
* This data is adjusted for inflation and for differences in the cost of living between countries.
* This data is expressed in international-$ at 2017 prices.
* For GDP per capita estimates in the very long run, see the [Maddison Project Database's indicator](https://ourworldindata.org/grapher/gdp-per-capita-maddison).

### How is this data described by its producer - World Bank (2023)?
GDP per capita based on purchasing power parity (PPP). PPP GDP is gross domestic product converted to international dollars using purchasing power parity rates. An international dollar has the same purchasing power over GDP as the U.S. dollar has in the United States. GDP at purchaser's prices is the sum of gross value added by all resident producers in the country plus any product taxes and minus any subsidies not included in the value of the products. It is calculated without making deductions for depreciation of fabricated assets or for depletion and degradation of natural resources. Data are in constant 2017 international dollars.

For the concept and methodology of 2017 PPP, please refer to the [International Comparison Program (ICP)’s website](https://www.worldbank.org/en/programs/icp).

### Source

#### World Bank – World Bank World Development Indicators
Retrieved on: 2023-05-29  
Retrieved from: https://datacatalog.worldbank.org/search/dataset/0037712/World-Development-Indicators  


    