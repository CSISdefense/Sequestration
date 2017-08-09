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

library(tidyverse)
library(magrittr)
library(csis360)
Path<-"K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\"
# Path<-"C:\\Users\\gsand_000.ALPHONSE\\Documents\\Development\\R-scripts-and-data\\"

# source(paste(Path,"lookups.R",sep=""))
# source(paste(Path,"helper.R",sep=""))



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


FullData<-read_and_join(Path,
                      "LOOKUP_Deflators.csv",
                      FullData,
                      by="Fiscal.Year",
                      NA.check.columns="Deflator.2016",
                      OnlyKeepCheckedColumns=TRUE
)


FullData$Obligation.2016 <- FullData$Action.Obligation /
  FullData$Deflator.2016
FullData<-FullData[,colnames(FullData)!="Deflator.2016"]


#Consolidate categories for Vendor Size
FullData<-read_and_join(Path,
                        "LOOKUP_Contractor_Size.csv",
                        FullData,
                        by="Vendor.Size",
                        NA.check.columns="Shiny.VendorSize",
                        OnlyKeepCheckedColumns=TRUE
)



# classify competition
FullData<-read_and_join(Path,
                        "Lookup_SQL_CompetitionClassification.csv",
                        FullData,
                        by=c("CompetitionClassification","ClassifyNumberOfOffers"),
                        ReplaceNAsColumns="ClassifyNumberOfOffers",
                        NA.check.columns=c("Competition.sum",
                                           "Competition.multisum",
                                           "Competition.effective.only",
                                           "No.Competition.sum"),
                        OnlyKeepCheckedColumns=TRUE
)


#Classify Product or Service Codes
FullData<-read_and_join(Path,
                        "LOOKUP_Buckets.csv",
                        FullData,
                        by="ProductOrServiceArea",
                        NA.check.columns="ProductServiceOrRnDarea.sum",
                        OnlyKeepCheckedColumns=TRUE,
                        ReplaceNAsColumns="ProductOrServiceArea"
)


FullData<-replace_nas_with_unlabeled(FullData,"SubCustomer","Uncategorized")
FullData<-read_and_join(Path,
                        "Lookup_SubCustomer.csv",
                        FullData,
                        by=c("Customer","SubCustomer"),
                        NA.check.columns="SubCustomer.platform",
                        OnlyKeepCheckedColumns=TRUE
)


LabelsAndColors<-PrepareLabelsAndColors(FullData,"SubCustomer")

FullData<-replace_nas_with_unlabeled(FullData,"PlatformPortfolio")
LabelsAndColors<-rbind(LabelsAndColors,
  PrepareLabelsAndColors(FullData,"PlatformPortfolio")
)
# ,"PlatformPortfolio")
# )
#Shiny.VendorSize is the new Vendor.Size
LabelsAndColors<-rbind(LabelsAndColors,
  PrepareLabelsAndColors(FullData,"Shiny.VendorSize")
)

LabelsAndColors<-rbind(LabelsAndColors,
  PrepareLabelsAndColors(FullData,"Competition.sum")
)

LabelsAndColors<-rbind(LabelsAndColors,
  PrepareLabelsAndColors(FullData,"Competition.multisum")
)

LabelsAndColors<-rbind(LabelsAndColors,
  PrepareLabelsAndColors(FullData,"Competition.effective.only")
)

LabelsAndColors<-rbind(LabelsAndColors,
  PrepareLabelsAndColors(FullData,"No.Competition.sum")
)

LabelsAndColors<-rbind(LabelsAndColors,
  PrepareLabelsAndColors(FullData,"Customer")
)

LabelsAndColors<-rbind(LabelsAndColors,
  PrepareLabelsAndColors(FullData,"ProductOrServiceArea")
)

LabelsAndColors<-rbind(LabelsAndColors,
  PrepareLabelsAndColors(FullData,"ProductServiceOrRnDarea.sum")
)

# LabelsAndColors<-rbind(LabelsAndColors,
#   PrepareLabelsAndColors(FullData,"ClassifyNumberOfOffers")
# )
#We haven't done a key for this one. 



# set correct data types
FullData %<>%
  select(-Customer) %>%
  # select(-ClassifyNumberOfOffers) %>%
  mutate(SubCustomer = factor(SubCustomer)) %>%
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
