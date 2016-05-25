source("helpers.R")
#read csv
df <- read.csv("Consumer_Complaints.csv", head = TRUE, stringsAsFactors = FALSE, na.strings = c("NA", "", "<NA>"))
df$Sub.product[df$Sub.product %in% unique(df$Sub.product)[43]] <- "Traveler/Cashier Checks"

#Dealing with NA values 
#Remove all data where 'ZIP.code' with unusual format and apply the function from helpers.R
df <- df[!is.na(df$ZIP.code),]
df <- df[!grepl("[^[:alnum:]]", substr(df$'ZIP.code', 1, 3)),]
df[is.na(df$State),] <- FillingState(df[is.na(df$State),])

##Assuming subproduct for "Credit reporting" and "Credit card" as the product itself
df$Sub.product[df$Product == "Credit reporting"] <- "Credit reporting"
df$Product[df$Product == "Credit card"] <- "Credit Card"
df$Sub.product[df$Product == "Credit Card"] <- "Credit Card"
df$Sub.product[is.na(df$Sub.product)] <- "I do not know"
##create 'Year.received' column
df$Year.received <- as.numeric(format(as.Date(df$Date.received, "%m/%d/%Y"),"%Y"))
df$Mon.received <- as.integer(format(as.Date(df$Date.received, "%m/%d/%Y"),"%m"))
df$Date.received <- as.Date(df$Date.received, "%m/%d/%Y")



#dataprep for treemap
TMdf <- data.frame()
for(i in 1:length(unique(df$Product))){
    
    subdf <- data.frame()
    temp <- df[df$Product==unique(df$Product)[i],]
    for(ii in 1:length(unique(temp$Sub.product))){
        subdf <- rbind(subdf, data.frame(Product = unique(temp$Product[ii]),Subproduct = unique(temp$Sub.product)[ii], 
                                         Count = sum(temp$Sub.product==unique(temp$Sub.product)[ii])))
    }
    TMdf <- rbind(TMdf, subdf)
}

#writing json
library(jsonlite)
makeList<-function(x){
    if(ncol(x)>2){
        listSplit<-split(x[-1],x[1],drop=T)
        lapply(names(listSplit),function(y){list(name=y,children=makeList(listSplit[[y]]))})
    }else{
        lapply(seq(nrow(x[1])),function(y){list(name=x[,1][y],value=x[,2][y])})
    }
}
jsonOut<-toJSON(list(name="MyData",children=makeList(TMdf)), pretty = TRUE)
##write json file
write(jsonOut, "CFPB_treemapData.json")

#Dataprep with SQL
library(sqldf)
## dataprep for treemap; less code than the above loop codes
sqlquery1 <- "select df.'Product', df.'Sub.product', count(*) from df group by df.'Sub.product' order by df.'Product'"
sqldf1 <- sqldf(sqlquery1, stringsAsFactors = FALSE)

## sorting data by year and Product, calculating percentage of the product each year
tempquery <- "select df.'Year.received', (count(*)) as 'yeartotal' from df group by df.'Year.received'"
tempsqldf <- sqldf(tempquery, stringsAsFactors = FALSE);tempsqldf

sqlquery2 <- "select df.'Year.received', df.'Product', (count(*)) as 'count', tempsqldf.yeartotal
              from df join tempsqldf on df.'Year.received' = tempsqldf.'Year.received'
              group by df.'Year.received', df.'Product' order by df.'Year.received'"
sqldf2 <- sqldf(sqlquery2, stringsAsFactors = FALSE)
sqldf2$percent <- sqldf2$count/sqldf2$yeartotal * 100; sqldf2$percent <- round(sqldf2$percent, 2)

## percentage of complaints made on each month
tempquery <- "select df.'Mon.received', (count(*)) as 'montotal' from df group by df.'Mon.received'"
tempsqldf <- sqldf(tempquery, stringsAsFactors = FALSE)

sqlquery3 <- "select df.'Mon.received', df.'Product', (count(*)) as 'count', tempsqldf.montotal
              from df join tempsqldf on df.'Mon.received' = tempsqldf.'Mon.received'
              group by df.'Mon.received', df.'Product' order by df.'Mon.received'"
sqldf3 <- sqldf(sqlquery3, stringsAsFactors = FALSE);sqldf3
sqldf3$percent <- sqldf3$count/sqldf3$montotal * 100; sqldf3$percent <- round(sqldf3$percent, 2)

## 


#EDA
##
library(RColorBrewer); library(ggplot2)
getPalette = colorRampPalette(brewer.pal(11, "Paired"))
ggplot(sqldf2, aes(x= Year.received, y= percent, group= Product)) + geom_line(aes(color = Product), size = 2) + 
    scale_color_manual(values = getPalette(length(unique(sqldf2$Product))))

ggplot(sqldf3, aes(x= Mon.received, y= percent, group= Product)) + geom_line(aes(color = Product), size = 2) + 
    scale_color_manual(values = getPalette(length(unique(sqldf2$Product))))


# Aggregate the data set for visualization. The dataset is group by state and subproduct
csvdf <- sqldf("SELECT df.'State',df.'Product', df.'Sub.product', (count(*)) AS 'count' FROM df
                GROUP BY df.'State', df.'Sub.product'",
              stringsAsFactors = FALSE)
## The geojson for dataviz shows only 50 states, D.C., and Puerto Rico.
## The aggregated dataset is needed to be filtered accordingly.

csvdf <- FilteringState(csvdf)
write.csv(csvdf, "CFPB_USState.csv", row.names = FALSE)

