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


# This line discards the "Area" and "Actions" columns and aggregates Amount
# by the five other category columns.  You must alter or remove this if you 
# want to use Area or Actions for anything.
FullData <- FullData %>%
  group_by(FY, VendorSize, Customer, Category, Portfolio) %>%
  summarize(Amount = sum(Amount))


deflate <- 
  c("2000" = 0.720876,
    "2001" = 0.740141,
    "2002" = 0.752442,
    "2003" = 0.773698,
    "2004" = 0.793958,
    "2005" = 0.821364,
    "2006" = 0.849765,
    "2007" = 0.872196,
    "2008" = 0.902677,
    "2009" = 0.904486,
    "2010" = 0.918687,
    "2011" = 0.940213,
    "2012" = 0.959027,
    "2013" = 0.971599,
    "2014" = 0.986071,
    "2015" = 1
  )

FullData$Amount <- round(FullData$Amount / deflate[as.character(FullData$FY)])


# write output to CleanedVendorSize.csv
write.csv(FullData, "CleanedVendorSize.csv")


