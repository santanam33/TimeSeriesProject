bc2 <- function(x,lam1=seq(-2,2,.1),ploty=FALSE) {
  require(MASS)
  if(any(x)<=0)stop("Negative values present..no transformations permitted")
  t1 <- 1:length(x)
  xxx <-boxcox(x~t1,lambda=lam1,plot=ploty)
  z <- xxx$x[xxx$y==max(xxx$y)]
return(z) 
}
