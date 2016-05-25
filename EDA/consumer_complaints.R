library(ggplot2); library(RColorBrewer); library(gridExtra)
library(wordcloud)
library(dplyr)

library(devtools)
install_github("skimthru", "ykimmate14")
library(skimthru)
df <- read.csv("Consumer_Complaints.csv" ,header= TRUE, stringsAsFactors = F)

df$Date.received <- as.Date(df$Date.received, format = "%m/%d/%Y")
df$Date.sent.to.company <- as.Date(df$Date.sent.to.company, format = "%m/%d/%Y")


# Exploratory Analysis

## Before exploratory analysis, create a color palette with more distinctive colors
## a palette for product
colcount.product = length(unique(df$Product))
getPalette = colorRampPalette(brewer.pal(8, "Set2"))

## creating wordcloud that shows product with most complaints
set.seed(1)
clouddf1 <- NofRow(df, 2)
wordcloud(clouddf1[,1], clouddf1[,2], scale = c(3,.8), colors=brewer.pal(12,"Set3"))


## create a bar plot that shows product with most complaints
ggplot(df, aes(x= Product)) + geom_bar(aes(fill = factor(Product))) + theme(axis.text.x = element_blank()) +
    scale_fill_manual(values = getPalette(colcount.product))

## creating consultant's chart that shows product with most complaints
p1 <- ggplot(df, aes(x= Product)) + geom_bar(aes(fill = factor(Product))) + 
    scale_fill_manual(values = getPalette(colcount.product)) + coord_polar() + 
    theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
          axis.text.y = element_blank(), axis.text.x = element_text(size = 12),
          axis.ticks.x = element_blank(), axis.ticks.y = element_blank())

## [all data] bar plot on Submitted.via, Company.response.to.consumer, 
## Timely.response. by Product, Consumer.disputed. by Product

p2 <- ggplot(df, aes(x = Submitted.via)) + geom_bar(aes(fill = Submitted.via)) + 
    theme(axis.text.x = element_blank()) + scale_fill_brewer(palette="Accent")

p3 <- ggplot(df, aes(x = Company.response.to.consumer)) + geom_bar(aes(fill = Company.response.to.consumer)) + 
    theme(axis.text.x = element_blank()) + scale_fill_brewer(palette="Dark2")

p4 <- ggplot(df[df$Timely.response. %in% "No",], aes(x = factor(1), fill = Product)) + geom_bar(width = 1) + 
    coord_polar(theta = "y") + theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
                                     axis.title.y = element_blank(), axis.title.x = element_blank()) + 
    scale_fill_manual(values = getPalette(colcount.product)) + 
    labs(title = "Products that failed to provide timely response")

p5 <- ggplot(df[df$Consumer.disputed %in% "Yes",], aes(x = factor(1), fill = Product)) + geom_bar(width = 1) +
    coord_polar(theta = "y") + theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
                                     axis.title.y = element_blank(), axis.title.x = element_blank()) + 
    scale_fill_manual(values = getPalette(colcount.product)) + 
    labs(title = "Products that customers disputed")

grid.arrange(p2, p3, p4, p5, nrow=2, ncol=2)


## [for each product] bar plot on Submitted.via, Company.response.to.consumer, 
## Timely.response. by Sub.product, Consumer.disputed. by Sub.product

EDA.Sub.product <- function(dataframe, prod){
    EDAdf <- df[df$Product == prod,]
    
    colcount.subproduct = length(unique(df$Sub.product))
    getPalette = colorRampPalette(brewer.pal(8, "Accent"))
    
    p2.1 <- ggplot(EDAdf, aes(x = Submitted.via)) + geom_bar(aes(fill = Submitted.via)) + 
        theme(axis.text.x = element_blank()) + scale_fill_brewer(palette="Accent") + 
        labs(title = paste("Submission Method for ", prod))
    
    p3.1 <- ggplot(EDAdf, aes(x = Company.response.to.consumer)) + geom_bar(aes(fill = Company.response.to.consumer)) + 
        theme(axis.text.x = element_blank()) + scale_fill_brewer(palette="Dark2") +
        labs(title = paste("Company Response to Complaints regarding ", prod))
    
    p4.1 <- ggplot(EDAdf[EDAdf$Timely.response. %in% "No",], aes(x = factor(1), fill = Sub.product)) + geom_bar(width = 1) + 
        coord_polar(theta = "y") + theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
                                     axis.title.y = element_blank(), axis.title.x = element_blank()) + 
        scale_fill_brewer(palette = "Set3") + 
        labs(title = paste(prod, " failed to responde timely",sep = ""))
    
    p5.1 <- ggplot(EDAdf[EDAdf$Consumer.disputed %in% "Yes",], aes(x = factor(1), fill = Sub.product)) + geom_bar(width = 1) +
        coord_polar(theta = "y") + theme(axis.text.x = element_blank(), axis.text.y = element_blank(), 
                                         axis.title.y = element_blank(), axis.title.x = element_blank()) + 
        scale_fill_brewer(palette = "Set3") + 
        labs(title = paste(prod, " Complaints that Consumer Disputed", sep=""))
    
    grid.arrange(p2.1, p3.1, p4.1, p5.1, nrow=2, ncol=2)
}
