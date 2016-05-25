### Introduction

Complaints are the greatest feedback from a customer who may have suggestions to improve a service or product.
Complaints made by customers can show what are the demands in the market and possibly suggest ways to make a business stands out amoung
other bussiness by satisfying the demands.
The goal of the dataviz project is to analyze the [complaints dataset](http://catalog.data.gov/dataset/consumer-complaint-database) to see if there's any particular pattern from customers' complaints in the United States

The dataset, which is provided by Consumer Financial Protection Bureau (CFPB), contains more than 500,000 rows and 16 variables. Each row is a complaints made by a customer in the United States. Each variable shows details about each complaints such as product, issue, company, state, date, etc.

### Exploratory Data Analysis

In order to observe any interesting patterns from the data, EDA was performed using R and its famous [ggplot2](http://ggplot2.org/) library. The [brief EDA report](http://rpubs.com/ykimmate14/154171) shows all the codes and various attempts to observe patterns from the dataset.

### Data Visualization

##### [1. Treemap](http://bl.ocks.org/ykimmate14/6211570d713c66c5788518b34daa1676)

The treemap visually represents the relative number of complaints made by consumers in the United States on each financial product.
The bigger block means more complaints about the financial product. R is used to process the original data, which is in CSV format, and create hierarchical json structure for d3 treemap layout.

Each financial product is classified in different colors and each block represents a sub-product.

The first line of tooltip shows financial product in its assigned color.

The second line of tooltip shows a sub-product of the financial product.

The thrid line of tooltip shows the number of complaints for the selected sub-product.

##### [2. Map with chart](http://bl.ocks.org/ykimmate14/60a7546627bfd233482c36afbf90addd)

A user can select the state of interest on the map to observe number of financial products made by residents of the state.
The data was cleaned, sorted, grouped, and aggregated by using R and SQL. Javascript d3.js and dimple.js are used to create the interactive visualization.

