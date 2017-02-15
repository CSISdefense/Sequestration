################################################################################
# Data Pre-Processing for Vendor Size Shiny Graphic
# L. Lipsey for DIIG, May 2016
#
# This script does pre-processing to get VendorSizeShiny.csv into proper form
# for use in the Shiny graphic.  The purpose is to avoid doing this processing
# in the Shiny script itself, thus reducing the graphic's load times for users.
#
# Input: CSV-format results from SQL query:
# sp_VendorSizeHistoryPlatformPortfolioSubCustomer on 5/13/2016
#
# Output: CSV file (CleanedVendorSize.csv)
# with data in the minimal form needed by Shiny script
################################################################################

library(dplyr)

# read in data            
FullData <- read.csv("VendorSizeShiny.csv")

# change header names to be shorter / more useful
names(FullData) <- c("FY","Customer","Portfolio","Category","Area","VendorSize",
                     "Amount","Actions")

# coerce Amount to be a numeric variable
FullData$Amount <- suppressWarnings(as.numeric(as.character(FullData$Amount)))

# remove lines with NA obligation amounts and unlabeled vendor sizes
FullData <- FullData[!is.na(FullData$Amount) & FullData$VendorSize !=
                         "Unlabeled",]

# subset to years of focus (2000-2014)
FullData <- suppressWarnings(subset(FullData, 
                                    1999 < as.numeric(as.character(FY))
))

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


