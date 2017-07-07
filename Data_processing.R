#=================================================================================================================#
# Data processing for Sequestration App
#=================================================================================================================#
rm(list = ls())
library(tidyverse)

Path<-"K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\"
source(paste(Path,"lookups.r",sep=""))


sequestration_original <- read_csv("Data\\Vendor_SP_FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform.csv",
                          col_names = TRUE,
                          na = c("","NA","NULL"))



sequestration_original<-apply_lookups(Path,sequestration_original)
sequestration_original$Fiscal_Year<-format(sequestration_original$Fiscal.Year, format="%Y")

# For faster processing the for-loop, vectorise, pre-allocate the data structures and 
# put the condiction outside for-loop

# Faceting <- character(nrow(sequestration_original))
# Condition1 <- (sequestration_original$IsSubContract + sequestration_original$IsInFSRS) == 0 
# Condition2 <- (sequestration_original$IsSubContract + sequestration_original$IsInFSRS) == 1
# Condition3 <- (sequestration_original$IsSubContract + sequestration_original$IsInFSRS) == 2
# 
# for(i in 1:nrow(sequestration_original)){
#   if(Condition1[i]){
#     Faceting[i] <- "PrimeNotReportInFSRS"}
#   
#   else if(Condition2[i]){
#     Faceting[i] <- "PrimeReportInFSRS"}
#   
#   else if(Condition3[i]){
#     Faceting[i] <- "SubReportInFSRS"}}

sequestration_original$Faceting <- NA
sequestration_original$Faceting[sequestration_original$IsSubContract==1]<-"SubReportInFSRS"
sequestration_original$Faceting[sequestration_original$IsSubContract==0&
                                    sequestration_original$IsInFSRS==1]<-"PrimeReportInFSRS"
sequestration_original$Faceting[sequestration_original$IsSubContract==0&
                                    sequestration_original$IsInFSRS==0]<-"PrimeNotReportInFSRS"


# Filter sequestration_original to only include fical year ranging from 2008 to 2016

sequestration <- filter(sequestration_original,Fiscal.Year >= as.Date("2007/10/1") &
                        Fiscal.Year <= as.Date("2016/9/30") &
                        Customer == "Defense")

# Transform some columns of interest into factor or integer and deflating

sequestration$PrimeOrSubObligatedAmount <- as.numeric(sequestration$PrimeOrSubObligatedAmount)
sequestration$PrimeOrSubObligatedAmount<-sequestration$PrimeOrSubObligatedAmount/
    sequestration$Deflator.2015

# Aggregating sequestration by Fiscal.Year, Platform Portfolio and IsSubContract

sequestration_Facet <- sequestration %>% group_by(Fiscal_Year,
                                                  PlatformPortfolio,
                                                #  IsSubContract,
                                                  SubCustomer,
                                                Pricing.Mechanism.sum,
                                                  Faceting) %>% 
                       summarise(PrimeOrSubTotalAmount = sum(PrimeOrSubObligatedAmount)/1e+9)

# Rename 'IsSubContract' column
#sequestration_Facet$IsSubContract <- ifelse(sequestration_Facet$IsSubContract == 1,
#                                            "SubContract", 
#                                            "Prime Contract")
# colnames(sequestration_Facet)[3] <- "Customer"
colnames(sequestration_Facet)[colnames(sequestration_Facet)=="SubCustomer"] <- "Customer"

sequestration_Facet$FacetingFill<-sequestration_Facet$Faceting

sequestration_Facet$Faceting[sequestration_Facet$Faceting=="PrimeNotReportInFSRS"]<-"AllPrimes"

PrimeReport<-subset(sequestration_Facet,Faceting == "PrimeReportInFSRS")
PrimeReport$Faceting<-"AllPrimes"

# Really confused why rbind two dataframes create list if I don't explicitly coerce them to dataframes  
sequestration_Duplicates <- rbind(as.data.frame(sequestration_Facet),as.data.frame(PrimeReport))

write.csv(x = sequestration_Duplicates, 
          file = "Data\\Sequestration_Duplicates.csv",
          row.names = FALSE)









