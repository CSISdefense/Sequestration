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
Path<-"K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\"
# Path<-"C:\\Users\\gsand_000.ALPHONSE\\Documents\\Development\\R-scripts-and-data\\"

source("package.r")
# source(paste(Path,"lookups.R",sep=""))
# source(paste(Path,"helper.R",sep=""))

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
# coerce Amount to be a numeric variable
FullData$Action.Obligation %<>% as.numeric()
FullData$SumOfnumberOfActions %<>% as.numeric()

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

# write output to CleanedVendorSize.csv
write_csv(FullData, "2016_unaggregated_FPDS.csv")





FullData<-replace_nas_with_unlabeled(FullData,"SubCustomer")


LabelsAndColors<-PrepareLabelsAndColors(Coloration,FullData,"SubCustomer")
LabelsAndColors$Column<-"SubCustomer"

FullData<-replace_nas_with_unlabeled(FullData,"PlatformPortfolio")
LabelsAndColors<-rbind(LabelsAndColors,
                       cbind(PrepareLabelsAndColors(Coloration,FullData,"PlatformPortfolio"),"PlatformPortfolio"))
#Shiny.VendorSize is the new Vendor.Size
PrepareLabelsAndColors(Coloration,FullData,"Shiny.VendorSize")
PrepareLabelsAndColors(Coloration,FullData,"Competition.sum")
PrepareLabelsAndColors(Coloration,FullData,"Competition.multisum")
PrepareLabelsAndColors(Coloration,FullData,"Competition.effective.only")
PrepareLabelsAndColors(Coloration,FullData,"No.Competition.sum")
PrepareLabelsAndColors(Coloration,FullData,"Customer")
PrepareLabelsAndColors(Coloration,FullData,"ProductOrServiceArea")
PrepareLabelsAndColors(Coloration,FullData,"ProductServiceOrRnDarea.sum")
