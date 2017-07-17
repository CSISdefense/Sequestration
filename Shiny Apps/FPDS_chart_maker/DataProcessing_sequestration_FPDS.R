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
# Path<-"K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\"
Path<-"C:\\Users\\gsand_000.ALPHONSE\\Documents\\Development\\R-scripts-and-data\\"

source(paste(Path,"lookups.R",sep=""))
source(paste(Path,"helper.R",sep=""))

Coloration<-read.csv(
  paste(Path,"Lookups\\","lookup_coloration.csv",sep=""),
  header=TRUE, sep=",", na.strings="", dec=".", strip.white=TRUE, 
  stringsAsFactors=FALSE
)

Coloration<-ddply(Coloration
                  , c(.(R), .(G), .(B))
                  , transform
                  , ColorRGB=as.character(
                    if(min(is.na(c(R,G,B)))) {NA} 
                    else {rgb(max(R),max(G),max(B),max=255)}
                  )
)


# read in data            
FullData <- read_csv(
  "2016_SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer.csv",
  col_names = TRUE, col_types = "cccccccccc",na=c("NA","NULL"))


FullData<-standardize_variable_names(Path,
                           FullData)


NA.check(FullData,
         "Customer",
         "SumOfnumberOfActions",
         "test.csv")



PrepareLabelsAndColors(Coloration,FullData,"Customer")

FullData<-replace_nas_with_unlabeled(FullData,"SubCustomer")
PrepareLabelsAndColors(Coloration,FullData,"SubCustomer")

FullData<-replace_nas_with_unlabeled(FullData,"ProductOrServiceArea")
PrepareLabelsAndColors(Coloration,FullData,"ProductOrServiceArea")

FullData<-replace_nas_with_unlabeled(FullData,"PlatformPortfolio")
PrepareLabelsAndColors(Coloration,FullData,"PlatformPortfolio")

<<<<<<< HEAD
PrepareLabelsAndColors(Coloration,FullData,"Vendor.Size")
=======

PrepareLabelsAndColors(Coloration,FullData,"CompetitionClassification")
PrepareLabelsAndColors(Coloration,FullData,"ClassifyNumberOfOffers")
>>>>>>> 0f8d1f28312aa328f607084683205e186d9dc014


FullData<-competition_vehicle_lookups(Path,FullData)
PrepareLabelsAndColors(Coloration,FullData,"Competition.sum")

  

# coerce Amount to be a numeric variable
FullData$Action.Obligation %<>% as.numeric()
FullData$SumOfnumberOfActions %<>% as.numeric()


#Consolidate categories for Vendor Size
FullData<-read_and_join(Path,
                      "LOOKUP_Contractor_Size.csv",
                      FullData,
                      by="Vendor.Size",
                      NA.check.columns="Shiny.VendorSize")

#Shiny.VendorSize is the new Vendor.Size
FullData<-FullData[,!colnames(FullData) %in% c("Vendor.Size",
                                     "Vendor.Size.detail",
                                     "Vendor.Size.sum")]
PrepareLabelsAndColors(Coloration,FullData,"Shiny.VendorSize")

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


# classify competition


debug(read_and_join)
FullData<-read_and_join(Path,
                        "LOOKUP_Buckets.csv",
                        FullData,
                        by="ProductOrServiceArea",
                        NA.check.columns="ProductServiceOrRnDarea.sum"
)

FullData<-FullData[,!colnames(FullData) %in% c("ProductOrServiceArea",
                                               "ServicesCategory.detail",
                                               "ServicesCategory.sum",
                                               "ProductsCategory.detail",
                                               "ProductOrServiceArea.DLA",
                                               "ProductOrServicesCategory.Graph",
                                               "SupplyServiceFRC",
                                               "SupplyServiceERS")]


# write output to CleanedVendorSize.csv
write_csv(FullData, "2016_unaggregated_FPDS.csv")

