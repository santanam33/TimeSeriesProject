bulkfit <- function(x) {
w <- matrix(0,nrow=27,ncol=4)
ii <- 0
for(i in 0:2) {
	for(k in 0:2) {
	for(j in 0:2) {
		ii <- ii + 1
		fit <- try(arima(x,order=c(i,k,j)),silent=TRUE)
	
			if(inherits(fit,"try-error")) {
				w[ii,4] <- 99999 	
				}
			else {
			w[ii,4] <- fit$aic
			w[ii,1] <- i
			w[ii,2] <- k	
			w[ii,3] <- j
		
		}
		}
		}
	}
	
	dimnames(w) <- list(NULL,c("ar","d","ma","AIC"))
	xxx <- which(w[,4]==min(w[,4],na.rm=TRUE))[1]
return(list(res=w,min=w[xxx,]))

}

