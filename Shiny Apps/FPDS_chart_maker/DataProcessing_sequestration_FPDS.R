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
full_data <- read_csv(
  "2016_SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer.csv",
  col_names = TRUE, col_types = "cccccccccc",na=c("NA","NULL"))


full_data<-standardize_variable_names(full_data)
# coerce Amount to be a numeric variable
full_data$Action.Obligation %<>% as.numeric()
full_data$SumOfnumberOfActions %<>% as.numeric()
full_data$Fiscal.Year <- as.numeric(full_data$Fiscal.Year)

# discard pre-2000
full_data %<>% filter(Fiscal.Year >= 2000)


full_data<-deflate(full_data,
                  money_var = "Action.Obligation",
                  deflator_var="Deflator.2016"
)
  

#Consolidate categories for Vendor Size
full_data<-read_and_join(full_data,
  "LOOKUP_Contractor_Size.csv",
  by="Vendor.Size",
  add_var="Shiny.VendorSize"
)



# classify competition
full_data<-read_and_join(full_data,
  "Lookup_SQL_CompetitionClassification.csv",
  by=c("CompetitionClassification","ClassifyNumberOfOffers"),
  replace_na_var="ClassifyNumberOfOffers",
  add_var=c("Competition.sum",
    "Competition.multisum",
    "Competition.effective.only",
    "No.Competition.sum")
)


#Classify Product or Service Codes
full_data<-read_and_join(full_data,
  "LOOKUP_Buckets.csv",
  by="ProductOrServiceArea",
  replace_na_var="ProductOrServiceArea",
  add_var="ProductServiceOrRnDarea.sum"
)


full_data<-replace_nas_with_unlabeled(full_data,"SubCustomer","Uncategorized")
full_data<-read_and_join(full_data,
                        "Lookup_SubCustomer.csv",
                        by=c("Customer","SubCustomer"),
                        add_var="SubCustomer.platform"
)

full_data<-replace_nas_with_unlabeled(full_data,"PlatformPortfolio")


labels_and_colors<-prepare_labels_and_colors(full_data,"SubCustomer")


labels_and_colors<-rbind(labels_and_colors,
  prepare_labels_and_colors(full_data,"PlatformPortfolio")
)
# ,"PlatformPortfolio")
# )
#Shiny.VendorSize is the new Vendor.Size
labels_and_colors<-rbind(labels_and_colors,
  prepare_labels_and_colors(full_data,"Shiny.VendorSize")
)

labels_and_colors<-rbind(labels_and_colors,
  prepare_labels_and_colors(full_data,"Competition.sum")
)

labels_and_colors<-rbind(labels_and_colors,
  prepare_labels_and_colors(full_data,"Competition.multisum")
)

labels_and_colors<-rbind(labels_and_colors,
  prepare_labels_and_colors(full_data,"Competition.effective.only")
)

labels_and_colors<-rbind(labels_and_colors,
  prepare_labels_and_colors(full_data,"No.Competition.sum")
)

labels_and_colors<-rbind(labels_and_colors,
  prepare_labels_and_colors(full_data,"Customer")
)

labels_and_colors<-rbind(labels_and_colors,
  prepare_labels_and_colors(full_data,"ProductOrServiceArea")
)

labels_and_colors<-rbind(labels_and_colors,
  prepare_labels_and_colors(full_data,"ProductServiceOrRnDarea.sum")
)

labels_and_colors<-rbind(labels_and_colors,
  prepare_labels_and_colors(full_data,"SubCustomer.platform")
)

# labels_and_colors<-rbind(labels_and_colors,
#   prepare_labels_and_colors(full_data,"ClassifyNumberOfOffers")
# )
#We haven't done a key for this one. 
column_key<-csis360::get_column_key(full_data)

# set correct data types
full_data %<>%
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
save(full_data,labels_and_colors,column_key, file="2016_unaggregated_FPDS.Rda")
