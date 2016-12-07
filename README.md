
# Introduction

Since 2014, Yelp has been hosting a competition called the Yelp Dataset Challenge. Thus far, Yelp has offered 8 rounds of this competition to the general public. Since its inception, the Yelp Dataset Challenge has given the machine learning and data science communities a useful and thorough dataset in which to apply state of the art ML algorithms and advanced data analysis to. We chose this dataset because it offers highly relevant data that is granular enough to be useful in our analysis, but not too granular as to require computationally complex routines to pre-process the data.

The dataset consists of 2.7M reviews and 649K tips by 687K users for 86K businesses. Furthermore, there are a total of 566K attributes that can be applied to a business. In addition to data that is core to Yelp’s business, the dataset also includes associations between the users creating a graph network of approximately 4.2M edges. All of the data is represented in json form stored in text files and takes up about 2.5GB on disk.

# Process

The portion of the data we have chosen to focus on are the review data. We are using reviews as a proxy measure of Yelp’s popularity overtime. We are able to do this because each review contains a date in ‘yyyy-mm-dd’ format which enables us to measure popularity down to the granularity of a day. Because yelp has been in business since 2014, grouping reviews by day gives us 4,003 samples to build our predictive model with; however, to improve the  accuracy of our predictions, we have decided to limit the granularity of time to a month, providing us with 141 samples.

Review JSON Object
```
{
    'type': 'review',
    'business_id': (encrypted business id),
    'user_id': (encrypted user id),
    'stars': (star rating, rounded to half-stars),
    'text': (review text),
    'date': (date, formatted like '2012-03-14'),
    'votes': {(vote type): (count)},
}
```

The first step taken to normalize our data and make it easier to query was to build a an ETL program to put our data into a relational database: doing so supports us in making ad-hoc queries in reasonable time. Once the data was in relational form, we wrote a simple query that grouped reviews by month and year and counted the number of items in each group. 

Review Aggregation Query
```sql
SELECT
  rollUp.reviewDate
  , count(1) as reviews
FROM (
   SELECT date_format(review.date, '%Y-%m') as reviewDate
   FROM review
   ORDER BY review.date) AS rollUp
GROUP BY rollUp.reviewDate
```

After producing the dataset of review counts by month, we produced a visualization using Tableau software so that we could identify obvious trends, cycles, and seasonality.

![Alt text](/assets/yelp_checkins_raw.png?raw=true "Review Counts over Time")

As evident in the chart, there is a strong upward trend in the number of reviews made by users over time. We have taken the liberty of specifying several key events in Yelp's history that helped contribute to their success, especially related to advances in mobile technology and search engine technology.  The releases of the iPhone and Android greatly increased Yelp's accessibility by users, and by the first quarter of 2013, smartphones had a 65% marketshare of the mobile market.  Also, the release of Google Pigeon in 2014 gave preference to local listings in Google searches, which also greatly increased Yelp's visibility, making 2014 the first profitable year in the company's existence.

In regards to the time series, there is a cyclical component to the series, highlighted by the lower graph. Specifically, every November, there is a sharp dip in the number of reviews made. This cycle seems to happen yearly, and could be demonstrative of users' tendencies to eat out less during these times.

To start off our analysis, we wrote the following code to get our data into memory for processing.

```{r}
library(ggplot2)
library(xts)
library(reshape2)


library(zoo)

# Downloads the 'bc2.R' file.
download.file("https://raw.githubusercontent.com/brent-halen/TSProject2016/master/bc2.R", destfile = "bc2.R", method = "libcurl")
source("bc2.R")
# Downloads 'decom1.R'
download.file("https://raw.githubusercontent.com/brent-halen/TSProject2016/master/decom1.R",destfile="decom1.R", method="libcurl")
source("decom1.R")
# Downloads the 'bulkfit.R' file.
download.file("https://raw.githubusercontent.com/brent-halen/TSProject2016/master/bulkfit.R",destfile="bulkfit.R",method="libcurl")
source("bulkfit.R")

# The following is an upgraded version of 'Bulkfit' designed to test seasonal ARIMA models as well as stationary. 
# ###WARNING### 
# This modification will cause the function to test 729 models instead of just 27. It may take a while to complete.
bulkfit2 <- function(x,y) {
    w <- matrix(0,nrow=729,ncol=7)
    ii <- 0
    
    for(i in 0:2) {
        for(k in 0:2) {
            for(j in 0:2) {
                for(I in 0:2){
                    for(K in 0:2){
                        for(J in 0:2){
                            ii <- ii + 1
                            fit <- try(arima(x,order=c(i,k,j),seasonal= list(order=c(I,K,J),period=y)))
                            
                            if(inherits(fit,"try-error")) {
                                w[ii,7] <- 99999 	
                            }
                            else {
                                w[ii,7] <- fit$aic
                                w[ii,1] <- i
                                w[ii,2] <- k	
                                w[ii,3] <- j
                                w[ii,4] <- I
                                w[ii,5] <- K
                                w[ii,6] <- J
                            }
                        }
                    }     
                }
            }
        }
    }
    
    dimnames(w) <- list(NULL,c("ar","d","ma","seasar","seasd","seasma","AIC"))
    xxx <- which(w[,7]==min(w[,7],na.rm=TRUE))[1]
    return(list(res=w,min=w[xxx,])) 
}

library(forecast)
library(MASS)
library(quadprog)

# Downloads the final file from the web site.
link <- "https://raw.githubusercontent.com/brent-halen/TSProject2016/master/reviews.csv"
reviews <- "reviews.csv"
download.file(link, destfile = reviews, method = "libcurl")

#yelp =  read.zoo(file = reviews, sep = "," , FUN = as.yearmon)

yelp <- read.csv(file = reviews, header = TRUE)
yelp <- as.data.frame(yelp)
yelp_forzoo <- yelp
yelp_forzoo$reviewDate <- as.yearmon(yelp_forzoo$reviewDate)
yelp <- zoo(yelp_forzoo$reviews,yelp_forzoo$reviewDate)
plot.ts(yelp)
yelp.ts <- as.ts(yelp)

```

# Model Building

First, we ran the 'bc2' function on the original data. 

```{r}

bc2(yelp.ts,ploty=TRUE)
#bc2(yelp.zoo,ploty=TRUE)
#0.3838384

```


```{r}
#yelp.tr1 <- yelp
#yelp.tr1$reviews = yelp.tr1$reviews^(383/1000)

yelp.tr = yelp.ts^(383/1000)

bulkfit(yelp.tr)
# 1.0000   2.0000   2.0000 516.3467 
yelp.bulkfit2 <- bulkfit2(yelp.tr,12)


yelp.tr.fit = arima(yelp.tr,order =c(1,2,2))
yelp.tr.fit2 <- arima(yelp.tr, order = c(0,1,2),seasonal = list(order=c(0,1,2),period=12))

yelp.tr.fit
#Coefficients:
#         ar1      ma1     ma2
#      0.5384  -1.9144  0.9144
#s.e.   0.1318   0.1004  0.0993

#sigma^2 estimated as 2.596:  log likelihood = -254.17,  aic = 516.35

yelp.tr.fit2

# Call:
# arima(x = yelp.tr, order = c(0, 1, 2), seasonal = list(order = c(0, 1, 2), period = 12))
# 
# Coefficients:
#           ma1      ma2     sma1    sma2
#       -0.1155  -0.2259  -0.6475  0.1870
# s.e.   0.0907   0.0884   0.1093  0.1181
# 
# sigma^2 estimated as 1.021:  log likelihood = -175.85,  aic = 361.69

yelp.tr.pred = predict(yelp.tr.fit, n.ahead=12)
yelp.tr.pred2 = predict(yelp.tr.fit2, n.ahead=12)

length(yelp)
#134

Lower = yelp.tr.pred$pred - 1.96*yelp.tr.pred$se/sqrt(134)
Lower2 = yelp.tr.pred2$pred - 1.96*yelp.tr.pred2$se/sqrt(134)
Upper = yelp.tr.pred$pred + 1.96*yelp.tr.pred$se/sqrt(134)
Upper2 = yelp.tr.pred2$pred + 1.96*yelp.tr.pred2$se/sqrt(134)

Predict = yelp.tr.pred$pred
Predict2 = yelp.tr.pred2$pred

pred.mat = cbind(Lower,Predict,Upper)
pred2.mat = cbind(Lower2,Predict2,Upper2)
final.mat = pred.mat^(1000/383)
final2.mat = pred2.mat^(1000/383)

final.mat
final2.mat

######decom 
yelp.dec = decom1(yelp,fore1 =12,se1 =12)
yelp.dec.final = yelp.dec$pred.df
yelp.dec.final

#######using forecast to make plot
fit_ar = arima(yelp, order= c(1,2,2))
fit_ar2 = arima(yelp, order = c(0,1,2),seasonal = list(order=c(0,1,2),period=12))

fit_ar_f = forecast(fit_ar, h =12)
fit_ar_f2 = forecast(fit_ar2,h=12)

plot(fit_ar_f, include =100)
plot(fit_ar_f2,include=100)

```

