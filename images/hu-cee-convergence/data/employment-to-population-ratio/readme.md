# Employment-to-population ratio - Data package

This data package contains the data that powers the chart ["Employment-to-population ratio"](https://ourworldindata.org/grapher/employment-to-population-ratio?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website. It was downloaded on January 11, 2026.

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


## Employment-to-population ratio
Share of the working-age population (ages 15 and older) who are employed.
Last updated: September 8, 2025  
Next update: September 2026  
Date range: 1991–2024  
Unit: %  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
International Labour Organization, ILO Modelled Estimates (ILOEST) / ILOSTAT, via World Bank (2025) – processed by Our World in Data

#### Full citation
International Labour Organization, ILO Modelled Estimates (ILOEST) / ILOSTAT, via World Bank (2025) – processed by Our World in Data. “Employment-to-population ratio – ILO” [dataset]. International Labour Organization, ILO Modelled Estimates (ILOEST) / ILOSTAT, via World Bank, “World Development Indicators 122” [original data].
Source: International Labour Organization, ILO Modelled Estimates (ILOEST) / ILOSTAT, via World Bank (2025) – processed by Our World In Data

### What you should know about this data
* This indicator is defined as the proportion of a country’s working-age population that is employed. Employment refers to people who worked for at least an hour during the reference period (typically a week), whether in paid employment or self-employment. This indicator gives a broad sense of how many people in a country are working, regardless of the kind of job they have or how many hours they work.
* When defining the working-age population, the definition of “working age” varies across countries, depending on national laws and practices. In the ILO modeled estimates shown here, this is harmonized to refer to people aged 15 and older.
* This data comes from the ILO Modelled Estimates series. The ILO combines countries' own reported estimates with statistically modeled estimates when observations are missing. This improves comparability across countries and over time and allows the ILO to calculate regional and global aggregates for every year. You can read more about how the ILO produces these estimates in the [Modelled Estimates documentation](https://ilostat.ilo.org/methods/concepts-and-definitions/ilo-modelled-estimates/).
* This data follows the standards of the [13th International Classification of Labour Statisticians (ICLS)](#dod:13-icls). Under this framework, employment includes work for pay or profit, including self-employment, as well as the production of goods for own use (such as subsistence farming). Changes in the definition of employment also affect who is counted as unemployed or outside the labor force. Because definitions were updated under the [19th ICLS](#dod:19-icls), data using the newer definitions is not fully comparable with data based on the 13th ICLS. You can read more about the definitions in [this explainer by the ILO](https://www.ilo.org/publications/quick-guide-understanding-impact-new-statistical-standards-ilostat).

### How is this data described by its producer - International Labour Organization, ILO Modelled Estimates (ILOEST) / ILOSTAT, via World Bank (2025)?
Employment to population ratio is the proportion of a country's population that is employed. Employment is defined as persons of working age who, during a short reference period, were engaged in any activity to produce goods or provide services for pay or profit, whether at work during the reference period (i.e. who worked in a job for at least one hour) or not at work due to temporary absence from a job, or to working-time arrangements. Ages 15 and older are generally considered the working-age population.

### Limitations and exceptions:
Data on employment by status are drawn from labor force surveys and household surveys, supplemented by official estimates and censuses for a small group of countries. The labor force survey is the most comprehensive source for internationally comparable employment, but there are still some limitations for comparing data across countries and over time even within a country.

Comparability of employment ratios across countries is affected by variations in definitions of employment and population. The biggest difference results from the age range used to define labor force activity. The population base for employment ratios can also vary. Most countries use the resident, non-institutionalized population of working age living in private households, which excludes members of the armed forces and individuals residing in mental, penal, or other types of institutions. But some countries include members of the armed forces in the population base of their employment ratio while excluding them from employment data.

The reference period of a census or survey is another important source of differences: in some countries data refer to people's status on the day of the census or survey or during a specific period before the inquiry date, while in others data are recorded without reference to any period. Employment ratios tend to vary during the year as seasonal workers enter and leave.

This indicator also has a gender bias because women who do not consider their work employment or who are not perceived as working tend to be undercounted. This bias has different effects across countries and reflects demographic, social, legal, and cultural trends and norms.

### Statistical concept and methodology:
The employment-to-population ratio indicates how efficiently an economy provides jobs for people who want to work. A high ratio means that a large proportion of the population is employed. But a lower employment-to-population ratio can be seen as a positive sign, especially for young people, if an increase in their education causes it.

The series is part of the "ILO modeled estimates database," including nationally reported observations and imputed data for countries with missing data, primarily to capture regional and global trends with consistent country coverage. Country-reported microdata is based mainly on nationally representative labor force surveys, with other sources (e.g., household surveys and population censuses) considering differences in the data source, the scope of coverage, methodology, and other country-specific factors. Country analysis requires caution where limited nationally reported data are available. A series of models are also applied to impute missing observations and make projections. However, imputed observations are not based on national data, are subject to high uncertainty, and should not be used for country comparisons or rankings. For more information: https://ilostat.ilo.org/resources/concepts-and-definitions/ilo-modelled-estimates/

### Notes from original source:
Given the exceptional situation, including the scarcity of relevant data, the ILO modeled estimates and projections from 2020 onwards are subject to substantial uncertainty.

### Source

#### International Labour Organization, ILO Modelled Estimates (ILOEST) / ILOSTAT, via World Bank – World Development Indicators
Retrieved on: 2025-09-08  
Retrieved from: https://data.worldbank.org/indicator/SL.EMP.TOTL.SP.ZS  


    