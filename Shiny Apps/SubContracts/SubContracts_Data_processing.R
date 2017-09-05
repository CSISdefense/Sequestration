#=================================================================================================================#
# Data processing for Sequestration App
#=================================================================================================================#
rm(list = ls())
library(tidyverse)
library(csis360)


Path<-"C:\\Users\\gsand_000.ALPHONSE\\Documents\\Development\\R-scripts-and-data\\"
# Path<-"K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\"
source(paste(Path,"lookups.r",sep=""))

sequestration_original <- read_csv(unz("Data\\Vendor_SP_FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform.zip"),
                          col_names = TRUE,
                          na = c("","NA","NULL"))


sequestration_original<-apply_lookups(Path,sequestration_original)
sequestration_original$Fiscal.Year<-as.numeric(format(sequestration_original$Fiscal.Year, format="%Y"))

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

sequestration <- filter(sequestration_original,Fiscal.Year >= 2007 &
                        Fiscal.Year <= 2016 &
                        Customer == "Defense")

# Transform some columns of interest into factor or integer and deflating


sequestration<-deflate(sequestration,
  money_var = "PrimeOrSubObligatedAmount",
  deflator_var="Deflator.2016"
)



# Aggregating sequestration by Fiscal.Year, Platform Portfolio and IsSubContract

  #This suddenly stopped working after R / package updates. ??
sequestration_Facet<- sequestration %>% dplyr::group_by(Fiscal.Year,
                                                  PlatformPortfolio,
                                                #  IsSubContract,
                                                  SubCustomer.sum,
                                                Pricing.Mechanism.sum,
                                                  Faceting,
                                                IsFSRSreportable) %>%
    dplyr::summarise(PrimeOrSubTotalAmount.2016 = sum(PrimeOrSubObligatedAmount.2016)/1e+9)

# Rename 'IsSubContract' column
#sequestration_Facet$IsSubContract <- ifelse(sequestration_Facet$IsSubContract == 1,
#                                            "SubContract", 
#                                            "Prime Contract")
# colnames(sequestration_Facet)[3] <- "SubCustomer.sum"

full_data<- sequestration_Facet

labels_and_colors<-prepare_labels_and_colors(full_data)

column_key<-csis360::get_column_key(full_data)

save(labels_and_colors,column_key,full_data,file="Shiny Apps//SubContracts//subcontract_full_data.RData")






