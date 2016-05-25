The treemap visually represents the relative number of complaints made by consumers in the United States on each financial product.
The bigger block means more complaints about the financial product. The data is prepared by the Consumer Financial Protection Bureau (CFPB) and avaiable [here](http://catalog.data.gov/dataset/consumer-complaint-database). R is used to process the original data, which is in CSV format, and create hierarchical json structure for d3 treemap layout.


Each financial product is classified in different colors and each block represents a sub-product.

The first line on tooltip shows financial product in its assigned color.

The second line shows a sub-product of the financial product.

The thrid line shows the number of complaints for the selected sub-product.