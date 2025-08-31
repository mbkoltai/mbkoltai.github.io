# Annual death rate by age group - Data package

This data package contains the data that powers the chart ["Annual death rate by age group"](https://ourworldindata.org/grapher/annual-death-rate-by-age-group?v=1&csvType=full&useColumnShortNames=false) on the Our World in Data website.

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


## Central death rate at birth – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at birth – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 1-4 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 1-4 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 5-9 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 5-9 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 10-14 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 10-14 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 15-19 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 15-19 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 20-24 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 20-24 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 25-29 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 25-29 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 30-34 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 30-34 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 35-39 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 35-39 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 40-44 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 40-44 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 45-49 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 45-49 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 50-54 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 50-54 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 55-59 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 55-59 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 60-64 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 60-64 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 65-69 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 65-69 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 70-74 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 70-74 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 75-79 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 75-79 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 80-84 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 80-84 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


## Central death rate at 85-89 – period tables – HMD
The death rate, calculated as the number of deaths divided by the average number of people alive during the interval.
Last updated: December 1, 2024  
Next update: December 2025  
Date range: 1751–2023  
Unit: deaths per 1,000 people  


### How to cite this data

#### In-line citation
If you have limited space (e.g. in data visualizations), you can use this abbreviated in-line citation:  
Human Mortality Database (2024) – with minor processing by Our World in Data

#### Full citation
Human Mortality Database (2024) – with minor processing by Our World in Data. “Central death rate at 85-89 – HMD – period tables” [dataset]. Human Mortality Database, “Human Mortality Database” [original data].
Source: Human Mortality Database (2024) – with minor processing by Our World In Data

### What you should know about this data
* The death rate is measured using the number of person-years lived during the interval.
* Person-years refers to the combined total time that a group of people has lived. For example, if 10 people each live for 2 years, they collectively contribute 20 person-years.
* The death rate is slightly different from the 'probability of death' during the interval, because the 'probability of death' metric uses a different denominator: the number of people alive at that age at the start of the interval, while this indicator uses the average number of people alive during the interval.

### Source

#### Human Mortality Database
Retrieved on: 2024-11-27  
Retrieved from: https://www.mortality.org/Data/ZippedDataFiles  

#### Notes on our processing step for this indicator
The original metric is given as a fraction between 0 and 1 (i.e. per-capita). We multiply this by 1,000 to get a per-1,000 people rate.


    