################################################################################
# Data Pre-Processing for FSRS shiny
################################################################################

library(tidyverse)
library(magrittr)

# read in data            
FullData <- read_csv(
  "Vendor_SP_FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform.csv")

names(FullData)[1] <- "fiscal_year"

# coerce Amount to be a numeric variable
FullData$PrimeObligatedAmount %<>% as.numeric()
FullData$PrimeNumberOfActions %<>% as.numeric()

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
FullData$VendorSize <- as.factor(
    vendorClassification[as.character(FullData$VendorSize)])

# discard pre-2000
FullData %<>% filter(fiscal_year >= 2000)

# deflation lookup

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

FullData$PrimeObligatedAmount <- round(FullData$PrimeObligatedAmount /
                           deflate[as.character(FullData$fiscal_year)])

# recode IsInFSRS
FullData$IsInFSRS[FullData$IsInFSRS == 0] <- "no"
FullData$IsInFSRS[FullData$IsInFSRS == 1] <- "yes"

# write output to FSRSprocessed.csv
write_csv(FullData, "FSRSprocessed.csv")


