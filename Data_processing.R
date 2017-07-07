#=================================================================================================================#
# Data processing for Sequestration App
#=================================================================================================================#
rm(list = ls())
library(tidyverse)

sequestration_original <- read_csv("Vendor_SP_FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform.csv",
                          col_names = TRUE,
                          na = c("","NA"))

# For faster processing the for-loop, vectorise, pre-allocate the data structures and 
# put the condiction outside for-loop

Faceting <- character(nrow(sequestration_original))
Condition1 <- (sequestration_original$IsSubContract + sequestration_original$IsInFSRS) == 0 
Condition2 <- (sequestration_original$IsSubContract + sequestration_original$IsInFSRS) == 1
Condition3 <- (sequestration_original$IsSubContract + sequestration_original$IsInFSRS) == 2

for(i in 1:nrow(sequestration_original)){
  if(Condition1[i]){
    Faceting[i] <- "PrimeNotReportInFSRS"}
  
  else if(Condition2[i]){
    Faceting[i] <- "PrimeReportInFSRS"}
  
  else if(Condition3[i]){
    Faceting[i] <- "SubReportInFSRS"}}

sequestration_original$Faceting <- Faceting

# Filter sequestration_original to only include fical year ranging from 2008 to 2016

sequestration <- filter(sequestration_original,fiscal_year >= 2008 &
                        fiscal_year <= 2016 &
                        Customer == "Defense")

# Transform some columns of interest into factor or integer

sequestration$PrimeOrSubObligatedAmount <- as.numeric(sequestration$PrimeOrSubObligatedAmount)

# Aggregating sequestration by fiscal_year, Platform Portfolio and IsSubContract

sequestration_Facet <- sequestration %>% group_by(fiscal_year,
                                                  PlatformPortfolio,
                                                #  IsSubContract,
                                                  SubCustomer,
                                                  Faceting) %>% 
                       summarise(PrimeOrSubTotalAmount = sum(PrimeOrSubObligatedAmount)/1e+9)

# Rename 'IsSubContract' column
#sequestration_Facet$IsSubContract <- ifelse(sequestration_Facet$IsSubContract == 1,
#                                            "SubContract", 
#                                            "Prime Contract")
colnames(sequestration_Facet)[3] <- "Customer"

sequestration_Facet$FacetingFill<-sequestration_Facet$Faceting

sequestration_Facet$Faceting[sequestration_Facet$Faceting=="PrimeNotReportInFSRS"]<-"AllPrimes"

PrimeReport<-subset(sequestration_Facet,Faceting == "PrimeReportInFSRS")
PrimeReport$Faceting<-"AllPrimes"

# Really confused why rbind two dataframes create list if I don't explicitly coerce them to dataframes  
sequestration_Duplicates <- rbind(as.data.frame(sequestration_Facet),as.data.frame(PrimeReport))

write.csv(x = sequestration_Duplicates, 
          file = "Sequestration_Duplicates.csv",
          row.names = FALSE)









