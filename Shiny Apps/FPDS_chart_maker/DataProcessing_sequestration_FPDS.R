################################################################################
# Data Pre-Processing for Vendor Size Shiny Graphic
# UPDATED 2/22/17
#
# This script does pre-processing to get a SQL query into usable form for shiny
# graphics
#
# Input:
#   CSV-format results from SQL query:
#     Vendor_SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer
#
# Output: CSV file (CleanedVendorSize.csv)
# with data in the minimal form needed by Shiny script
################################################################################

# install.packages("../csis360_0.0.0.9022.tar.gz")

library(tidyverse)
library(magrittr)
library(csis360)

# read in data
FullData <- read_csv(
  "2016_SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer.csv",
  col_names = TRUE, col_types = "cccccccccc",na=c("NA","NULL"))


FullData<-standardize_variable_names(FullData)
# coerce Amount to be a numeric variable
FullData$Action.Obligation %<>% as.numeric()
FullData$SumOfnumberOfActions %<>% as.numeric()
FullData$Fiscal.Year <- as.numeric(FullData$Fiscal.Year)

# discard pre-2000
FullData %<>% filter(Fiscal.Year >= 2000)


FullData<-deflate(FullData,
                  money_var = "Action.Obligation",
                  deflator_var="Deflator.2016"
)
  

#Consolidate categories for Vendor Size
FullData<-read_and_join(FullData,
  "LOOKUP_Contractor_Size.csv",
  by="Vendor.Size",
  add_var="Shiny.VendorSize"
)



# classify competition
FullData<-read_and_join(FullData,
  "Lookup_SQL_CompetitionClassification.csv",
  by=c("CompetitionClassification","ClassifyNumberOfOffers"),
  replace_na_var="ClassifyNumberOfOffers",
  add_var=c("Competition.sum",
    "Competition.multisum",
    "Competition.effective.only",
    "No.Competition.sum")
)


#Classify Product or Service Codes
FullData<-read_and_join(FullData,
  "LOOKUP_Buckets.csv",
  by="ProductOrServiceArea",
  replace_na_var="ProductOrServiceArea",
  add_var="ProductServiceOrRnDarea.sum"
)


FullData<-replace_nas_with_unlabeled(FullData,"SubCustomer","Uncategorized")
FullData<-read_and_join(FullData,
                        "Lookup_SubCustomer.csv",
                        by=c("Customer","SubCustomer"),
                        add_var="SubCustomer.platform"
)


LabelsAndColors<-prepare_labels_and_colors(FullData,"SubCustomer")

FullData<-replace_nas_with_unlabeled(FullData,"PlatformPortfolio")
LabelsAndColors<-rbind(LabelsAndColors,
  prepare_labels_and_colors(FullData,"PlatformPortfolio")
)
# ,"PlatformPortfolio")
# )
#Shiny.VendorSize is the new Vendor.Size
LabelsAndColors<-rbind(LabelsAndColors,
  prepare_labels_and_colors(FullData,"Shiny.VendorSize")
)

LabelsAndColors<-rbind(LabelsAndColors,
  prepare_labels_and_colors(FullData,"Competition.sum")
)

LabelsAndColors<-rbind(LabelsAndColors,
  prepare_labels_and_colors(FullData,"Competition.multisum")
)

LabelsAndColors<-rbind(LabelsAndColors,
  prepare_labels_and_colors(FullData,"Competition.effective.only")
)

LabelsAndColors<-rbind(LabelsAndColors,
  prepare_labels_and_colors(FullData,"No.Competition.sum")
)

LabelsAndColors<-rbind(LabelsAndColors,
  prepare_labels_and_colors(FullData,"Customer")
)

LabelsAndColors<-rbind(LabelsAndColors,
  prepare_labels_and_colors(FullData,"ProductOrServiceArea")
)

LabelsAndColors<-rbind(LabelsAndColors,
  prepare_labels_and_colors(FullData,"ProductServiceOrRnDarea.sum")
)

LabelsAndColors<-rbind(LabelsAndColors,
  prepare_labels_and_colors(FullData,"SubCustomer.platform")
)

# LabelsAndColors<-rbind(LabelsAndColors,
#   prepare_labels_and_colors(FullData,"ClassifyNumberOfOffers")
# )
#We haven't done a key for this one. 



# set correct data types
FullData %<>%
  select(-Customer) %>%
  # select(-ClassifyNumberOfOffers) %>%
  mutate(SubCustomer = factor(SubCustomer)) %>%
  mutate(SubCustomer.platform = factor(SubCustomer.platform)) %>%
  mutate(ProductOrServiceArea = factor(ProductOrServiceArea)) %>%
  mutate(PlatformPortfolio = factor(PlatformPortfolio)) %>%
  mutate(Shiny.VendorSize = factor(Shiny.VendorSize)) %>%
  mutate(ProductServiceOrRnDarea.sum = factor(ProductServiceOrRnDarea.sum)) %>%
  mutate(Competition.sum = factor(Competition.sum)) %>%
  mutate(Competition.effective.only = factor(Competition.effective.only)) %>%
  mutate(Competition.multisum = factor(Competition.multisum))  %>%
  mutate(No.Competition.sum = factor(No.Competition.sum))


# write output to CleanedVendorSize.csv
save(FullData,LabelsAndColors, file="2016_unaggregated_FPDS.Rda")
