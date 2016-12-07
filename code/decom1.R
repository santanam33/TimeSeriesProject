decom1 <- function(x1,fore1=0,se1=1) {
#Changes made on 2/21/06
#Remove "its" section and remove options for irre.
#x1 is the original data series;
#fore1 is the number of forecast periods
#se1 is the annual frequency
  n1 <- length(x1)
if(is.ts(x1) !=TRUE){
  x <- ts(x1,start=1,frequency=1)
}
else {
  x <- x1
}
f1 <- tsp(x)[3]
f21 <- f1
ck1 <- n1/f1
if(se1 != 1)f21 <- 1
#if(ck1 != floor(ck1))stop("Need exact values for a year")
if(fore1 < 0)stop("Forecast value must be positive")
if(fore1 > n1)stop("Forecast value must be less than series length")
#Now start the seasonal process
#This is NOT done for annual data
if(f21 == 1) {
y <- filter(x,rep(1,f1))/f1
z <- filter(y,rep(1,2))/2
xx <- as.vector(z)
z1 <- c(NA,xx[-n1])
w1 <- x/z1
#w2 <- matrix(w1,nrow=f1)
#w3 <- apply(w2,1,function(x)mean(x,na.rm=TRUE))
xw <- vector("list",f1)
for(i in 1:n1) {
  j1 <- ifelse(i%%f1==0,f1,i%%f1)
  xw[[j1]] <- c(xw[[j1]],w1[i])
}
w3 <- unlist(lapply(xw,function(x)mean(x,na.rm=TRUE)))
w4 <- sum(w3)/f1
w3 <- w3/w4
sea1 <- rep(w3,length=n1)
sea1 <- ts(sea1,start=start(x),frequency=f1)
ab <- f1 - start(x)[2] +2
sea2 <- sea1[ab:(ab+f1-1)]
dy <- x/sea1
}
else {
sea1 <- rep(1,length=n1)
sea2 <- 1
dy <- x
}
#Begin fitting the trend
t1 <- 1:n1
trend.lm <- lm(dy ~ t1)
trend.ts <- ts(trend.lm$fitted.values,start=start(x),frequency=f1)
print(trend.lm$coef)
#Obtain Final Fitted series
#2/05/2006
#Make adjustments to set up cycle and irregular as time series
yhat <- trend.ts*sea1
#We will get cyclical and irregular values
cr1 <- x/yhat
cy1 <- ts(as.vector(filter(cr1,rep(1,3))/3),start=start(x),frequency=f1)
ir1 <- cr1/cy1
#Calculate forecasts if needed
if(fore1 != 0) {
new1 <- data.frame(t1=(n1+1):(n1+fore1))
pred1 <- predict(trend.lm,newdata=new1,interval="prediction")
pred2 <- (pred1[,3] - pred1[,2])/2
xs1 <- sea1[1:fore1]
pred4 <- pred1[,1]*xs1
pred5 <- pred4 - pred2
pred6 <- pred4 + pred2
pred.df <- data.frame(pred=pred4,lower=pred5,upper=pred6)
print(pred.df)
#return(data.frame(mult=pred.df$pred))
}
x2 <- data.frame(x1,deas=dy,
		trend=trend.ts,seas=sea1,seay=sea2,cycle=cy1,irr=ir1)
if(fore1 !=0) {
	 zzz <- list(x2=x2,pred.df=pred.df)
	 }
	 else {

	 zzz <- list(x2=x2)
	 }
return(zzz)
}
