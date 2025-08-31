# Population by age group - Data package

This data package contains the data that powers the chart ["Population by age group"](https://ourworldindata.org/grapher/population-by-five-year-age-group?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website.

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


## Population, ages 0-4 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 0-4.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 0-4 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 5-9 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 5-9.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 5-9 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 10-14 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 10-14.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 10-14 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 15-19 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 15-19.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 15-19 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 20-24 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 20-24.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 20-24 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 25-29 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 25-29.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 25-29 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 30-34 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 30-34.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 30-34 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 35-39 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 35-39.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 35-39 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 40-44 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 40-44.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 40-44 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 45-49 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 45-49.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 45-49 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 50-54 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 50-54.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 50-54 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 55-59 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 55-59.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 55-59 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 60-64 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 60-64.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 60-64 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 65-69 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 65-69.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 65-69 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 70-74 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 70-74.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 70-74 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 75-79 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 75-79.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 75-79 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 80-84 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 80-84.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 80-84 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 85-89 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 85-89.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 85-89 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 90-94 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 90-94.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 90-94 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 95-99 – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 95-99.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 95-99 – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


## Population, ages 100+ – UN WPP
De facto total population in a country, area or region as of 1 July of the year indicated. This only includes individuals aged 100+.
Last updated: July 12, 2024  
Date range: 1950–2023  
Unit: people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
UN, World Population Prospects (2024) – processed by Our World in Data

#### Full citation
UN, World Population Prospects (2024) – processed by Our World in Data. “Population, ages 100+ – UN WPP” [dataset]. United Nations, “World Population Prospects” [original data].
Source: UN, World Population Prospects (2024) – processed by Our World In Data

### Source

#### United Nations – World Population Prospects
Retrieved on: 2024-07-11  
Retrieved from: https://population.un.org/wpp/Download/  


    