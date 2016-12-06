
library(zoo)
source("bc2.R")
source("decom1.r")
source("bulkfit.R")
library(forecast)

yelp =  read.zoo(review, sep = "," , FUN = as.yearmon)


plot.ts(yelp)


bc2(yelp,ploty=TRUE)
#0.3838384


yelp.tr = yelp^(383/1000)

bulkfit(yelp.tr)
# 1.0000   2.0000   2.0000 516.3467 

yelp.tr.fit = arima(yelp.tr,order =c(1,2,2))

yelp.tr.fit
#Coefficients:
#         ar1      ma1     ma2
#      0.5384  -1.9144  0.9144
#s.e.   0.1318   0.1004  0.0993

#sigma^2 estimated as 2.596:  log likelihood = -254.17,  aic = 516.35


yelp.tr.pred = predict(yelp.tr.fit, n.ahead=12)

length(yelp)
#134

Lower = yelp.tr.pred$pred - 1.96*yelp.tr.pred$se/sqrt(134)

Upper = yelp.tr.pred$pred + 1.96*yelp.tr.pred$se/sqrt(134)

Predict = yelp.tr.pred$pred

pred.mat = cbind(Lower,Predict,Upper)


final.mat = pred.mat^(1000/383)

final.mat


######decom 
yelp.dec = decom1(yelp,fore1 =12,se1 =12)


yelp.dec.final = yelp.dec$pred.df

yelp.dec.final




#######using forecast to make plot
fit_ar = arima(yelp, order= c(1,2,2))

fit_ar_f = forecast(fit_ar, h =12)

plot(fit_ar_f, include =100)

