# generate random data for therapy report
library(magrittr)
library(plyr)
dates <- seq(as.Date("2022-01-01"), as.Date("2022-02-28"), by="days")
outbreaks <- sample(0:4, length(dates), replace = T, prob = c(0.6, 0.2, 0.1, 0.05, 0.05)) 
outbreak_level <- lapply(1:length(outbreaks), function(x){
  if (outbreaks[x] !=0){
    out <- sample(1:5, outbreaks[x], replace = T, prob = c(0.1, 0.2, 0.4, 0.1, 0.2))
    day=dates[x]
    df <- data.frame(matrix(ncol = 2, nrow = length(out)))
    colnames(df)=c("dates","intensity")
    df$dates=day
    df$intensity=out
    df
    }
}) %>% do.call(rbind,.) %>% data.frame()
# now we add triggers
type <- sample(c("Panic Attack","Shut Down","Mute","Tantrum"), dim(outbreak_level)[1],
               replace = T, prob = c(0.3,0.3,0.1,0.2))
location <-sample(c("School","In Public","At Home", "Relatives"),
                  dim(outbreak_level)[1], 
                  replace = T, prob = c(0.3,0.4,0.2,0.1))

outbreak_level$type=as.factor(type)
outbreak_level$location=as.factor(location)


save(outbreak_level, file = "outbreak_level.rda")
