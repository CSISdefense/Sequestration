# Prime contracting for involving U.S.-Canada vendors
Greg Sanders  
July 14, 2016  

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:

#Requirements

```r
library(plyr)
require(ggplot2)
```

```
## Loading required package: ggplot2
```

```r
require(scales)
```

```
## Loading required package: scales
```

```r
# setwd("K:\\Development\\Sequestration")
setwd("D:\\Users\\Greg Sanders\\Documents\\Development\\Sequestration")

# Path<-"K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\"
Path<-"D:\\Users\\Greg Sanders\\Documents\\Development\\R-scripts-and-data\\"
source(paste(Path,"lookups.r",sep=""))
```

```
## Loading required package: stringr
```

```r
source(paste(Path,"helper.r",sep=""))
```

```
## Loading required package: grid
```

```
## Loading required package: reshape2
```

```
## Loading required package: lubridate
```

```
## 
## Attaching package: 'lubridate'
```

```
## The following object is masked from 'package:plyr':
## 
##     here
```

```
## The following object is masked from 'package:base':
## 
##     date
```

```r
Coloration<-read.csv(
  paste(Path,"Lookups\\","Lookup_coloration.csv",sep=""),
  header=TRUE, sep=",", na.strings="NA", dec=".", strip.white=TRUE, 
  stringsAsFactors=FALSE
)

#Clear out lines from the coloration CSV where no variable is listed.
Coloration<-subset(Coloration, variable!="")
```



#Read And Processs

```r
#This really shouldn't just be Canada related, but working with what I have.
FSRShistory  <- read.csv(
    file.path("Data","Location_CCCvendorIdentification2.csv"),
    header = TRUE, sep = ",", dec = ".", strip.white = TRUE, 
    na.strings = c("NULL","NA",""),
    stringsAsFactors = TRUE
)
# FSRShistory<-subset(FSRShistory,fiscal_year>=1990)
FSRShistory<-apply_lookups(Path,FSRShistory)
```

```
## Joining by: Customer, SubCustomer
```

```
## Joining by: ProductServiceOrRnDarea
```

```
## Joining by: PlatformPortfolio
```

```
## Joining by: Fiscal.Year
```

```
## Warning in apply_lookups(Path, FSRShistory): NaNs produced
```

```r
FSRShistory<-subset(FSRShistory,Customer %in% c("Defense"))



# FSRShistory$Category[FSRShistory$AnyIsSmall==0]<-"Never Small"
# FSRShistory$Category[FSRShistory$AlwaysIsSmall==1]<-"Always Small"
# FSRShistory$Category[FSRShistory$AlwaysIsSmall==0 & 
#                              FSRShistory$AnyIsSmall==1]<-"Sometimes Small"
# 

FSRScategoryNotVendor<-ddply(FSRShistory,.(Fiscal.Year,#Is this what we want?
                                  Customer,
                                  SubCustomer,
                                  SubCustomer.component,
                                  SubCustomer.sum,
                                  SubCustomer.detail,
                                  PlatformPortfolio,
                                  PlatformPortfolio.sum,
                                  ProductServiceOrRnDarea,
                                  ServicesCategory.sum,
                                  ProductOrServiceCode,
                                  ProductOrServiceCodeText
                                  ),
                               summarize,
      # count=length(FiscalYear),
      # ObligatedAmount=sum(ObligatedAmount),
      Obligation.2014=sum(Obligation.2014)
      )

write.csv(FSRScategoryNotVendor,"Data\\FSRShistoryCustomerPlatformBucket.csv")




# DunsCountyByPercent<-ddply(FSRShistory,.(RoundedPercentSmall,AnyIsSmall,AlwaysIsSmall,Category),
#       summarize,
#       count=length(FiscalYear),
#       ObligatedAmount=sum(ObligatedAmount),
#       ObligatedAmountisSmall=sum(ObligatedAmountisSmall)
#       )

# DunsCountyByPercent$SmallValueThreshold[DunsCountyByPercent$RoundedPercentSmall>=0.25]<-">=25%"
# DunsCountyByPercent$SmallValueThreshold[DunsCountyByPercent$RoundedPercentSmall<0.25 &
#                                               DunsCountyByPercent$RoundedPercentSmall>=0.1]<-"[10%-25%)"
# 
# DunsCountyByPercent$SmallValueThreshold[DunsCountyByPercent$RoundedPercentSmall<0.1 &
#                                         DunsCountyByPercent$RoundedPercentSmall>=0.01]<-"[1%-10%)"
# DunsCountyByPercent$SmallValueThreshold[DunsCountyByPercent$RoundedPercentSmall<0.01 ]<-"<1%"
# # DunsCountyByPercent$SmallValueThreshold[is.na(DunsCountyByPercent$RoundedPercentSmall)]<-"NA"
# DunsCountyByPercent$SmallValueThreshold<-ordered(DunsCountyByPercent$SmallValueThreshold,levels=c("<1%","[1%-10%)","[10%-25%)",">=25%"))
```

#Prime and Sub Top Level

```r
FSRSsummary<-read.csv(file.path("Data","Contract_FSRSinFPDShistory.csv"),
                     na.strings=c("NULL","NA"),
                     header=TRUE)
FSRSsummary<-subset(FSRSsummary,fiscal_year>1990)
FSRSsummary<-apply_lookups(Path,FSRSsummary)
```

```
## Joining by: Fiscal.Year
```

#Prime Contract Sub Study

```r
FSRSstudy<-read.csv(unz(file.path("Data","Location_CanadaRelatedFPDScomplete.zip"),
                         "Location_CanadaRelatedFPDScomplete.csv"),
                     na.strings=c("NULL","NA"),
                     header=TRUE)
FSRSstudy<-apply_lookups(Path,FSRSstudy)
```

```
## Joining by: Customer, SubCustomer
```

```
## Joining by: ProductServiceOrRnDarea
```

```
## Joining by: PlatformPortfolio
```

```
## Joining by: Fiscal.Year
```

```
## Warning in apply_lookups(Path, FSRSstudy): NaNs produced
```

```r
PrimeContract2011<-ddply(subset(FSRSstudy,Fiscal.Year>=2011),
      .(CSIScontractID,IsSubcontractReportingContract),
      summarise,
      Obligation.2014=sum(Obligation.2014))

PrimeContractCount<-ddply(PrimeContract2011,
      .(IsSubcontractReportingContract),
      summarise,
      Obligation.2014=sum(Obligation.2014),
      ContractCount=length(CSIScontractID))

write.csv(PrimeContractCount,"PrimeContractCount.csv")
```
