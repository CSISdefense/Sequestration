################################################################################
# Data Pre-Processing for Vendor Size Shiny Graphic
# UPDATED 2/22/17
#
# This script does pre-processing to get a SQL query into usable form for shiny
# graphics
#
# Input: CSV-format results from SQL query:
# Vendor_SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer 
#
# Output: CSV file (CleanedVendorSize.csv)
# with data in the minimal form needed by Shiny script
################################################################################

library(tidyverse)
library(magrittr)
source("K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\lookups.R")
source("K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\helper.R")

# read in data            
FullData <- read_csv(
  "2016_SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer.csv",
  col_names = FALSE, col_types = "cccccccccc")

# header names didn't read well, enter manually
names(FullData) <- c("Fiscal.Year","Customer", "SubCustomer",
  "ServicesCategory", "PlatformPortfolio", "VendorSize",
  "CompetitionClassification", "ClassifyNumberOfOffers",
  "SumOfobligatedAmount","SumOfnumberOfActions")

FullData <- standardize_variable_names(
  "K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\",
  FullData)

# coerce Amount to be a numeric variable
FullData$Action.Obligation %<>% as.numeric()
FullData$SumOfnumberOfActions %<>% as.numeric()


# create lookup table for VendorSize, used in next command
vendorClassification <- c("Large" = "Large",
                          "Large(Small Subsidiary)" = "Large",
                          "Large: Big 5" = "Big Five",
                          "Large: Big 5 (Small Subsidiary)" = "Big Five",
                          "Large: Big 5 JV" = "Big Five",
                          "Large: Big 5 JV (Small Subsidiary)" = "Big Five",
                          "Large: Pre-Big 6" = "Large",
                          "Medium <1B" = "Medium",
                          "Medium >1B" = "Medium",
                          "Medium >1B (Small Subsidiary)" = "Medium",
                          "Small" = "Small",
                          "Unlabeled" = "Small")

# reduce VendorSize variable to four categories, as guided by lookup table
FullData$Vendor.Size <- as.factor(
    vendorClassification[as.character(FullData$Vendor.Size)])


# discard pre-2000
FullData %<>% filter(Fiscal.Year >= 2000)


deflate <- c(
  "2000"= 0.707312744,
  "2001"= 0.726215832,
  "2002"= 0.73828541,
  "2003"=	0.75914093,
  "2004"=	0.779020234,
  "2005"=	0.805910543,
  "2006"=	0.833777068,
  "2007"=	0.855786297,
  "2008"=	0.885694001,
  "2009"=	0.887468939,
  "2010"=	0.901402201,
  "2011"=	0.922523962,
  "2012"=	0.940983316,
  "2013"=	0.953319134,
  "2014"=	0.967518637,
  "2015"=	0.981185659,
  "2016"=	1
)

FullData$Action.Obligation <- round(FullData$Action.Obligation /
                           deflate[FullData$Fiscal.Year])


# write output to CleanedVendorSize.csv
write_csv(FullData, "2016_unaggregated_FPDS.csv")
