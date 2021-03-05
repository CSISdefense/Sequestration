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
library(Hmisc)
# read in data
full_data <- read_delim(
  "data//semi_clean//Summary.SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer.txt",delim = "\t",
  col_names = TRUE, col_types = "cccccccccc",na=c("NA","NULL"))


full_data<-standardize_variable_names(full_data)
# coerce Amount to be a numeric variable
full_data$Action_Obligation %<>% as.numeric()
full_data$Number.Of.Actions %<>% as.numeric()
full_data$Fiscal.Year <- as.numeric(full_data$Fiscal.Year)

# discard pre-2000
full_data %<>% filter(Fiscal.Year >= 2000)


full_data<-deflate(full_data,
                  money_var = "Action_Obligation",
                  deflator_var="OMB19_19"
)
 
   colnames(full_data)[colnames(full_data)=="Action_Obligation_Then_Year"]<-"Action_Obligation"
full_data<-deflate(full_data,
                   money_var = "Action_Obligation",
                   deflator_var="OMB20_GDP18"
)



#Consolidate categories for Vendor Size

full_data<-csis360::read_and_join(full_data,
  "LOOKUP_Contractor_Size.csv",
  by="Vendor.Size",
  add_var="Shiny.VendorSize",
  path="https://raw.githubusercontent.com/CSISdefense/R-scripts-and-data/master/",
  dir="Lookups/"
)



# classify competition
full_data<-csis360::read_and_join(full_data,
  "Lookup_SQL_CompetitionClassification.csv",
  by=c("CompetitionClassification","ClassifyNumberOfOffers"),
  replace_na_var="ClassifyNumberOfOffers",
  add_var=c("Competition.sum",
    "Competition.multisum",
    "Competition.effective.only",
    "No.Competition.sum"),
  path="https://raw.githubusercontent.com/CSISdefense/R-scripts-and-data/master/",
  dir="Lookups/"
)


#Classify Product or Service Codes
full_data<-csis360::read_and_join(full_data,
  "LOOKUP_Buckets.csv",
  # by="ProductOrServiceArea",
  by="ProductServiceOrRnDarea",
  replace_na_var="ProductServiceOrRnDarea",
  add_var="ProductServiceOrRnDarea.sum",
  path="https://raw.githubusercontent.com/CSISdefense/R-scripts-and-data/master/",
  dir="Lookups/"
)


full_data<-replace_nas_with_unlabeled(full_data,"SubCustomer","Uncategorized")
full_data<-csis360::read_and_join(full_data,
                        "Lookup_SubCustomer.csv",
                        by=c("Customer","SubCustomer"),
                        add_var="SubCustomer.platform",
                        path="https://raw.githubusercontent.com/CSISdefense/R-scripts-and-data/master/",
                        dir="Lookups/"
)


full_data<-replace_nas_with_unlabeled(full_data,"PlatformPortfolio")

# debug(csis360::prepare_labels_and_colors)
# load("Shiny Apps/FPDS_chart_maker/2016_unaggregated_FPDS.Rda")
labels_and_colors<-csis360::prepare_labels_and_colors(full_data)


column_key<-csis360::get_column_key(full_data)

# set correct data types
full_data %<>%
  select(-Customer) %>%
  # select(-ClassifyNumberOfOffers) %>%
  mutate(SubCustomer = factor(SubCustomer)) %>%
  mutate(SubCustomer.platform = factor(SubCustomer.platform)) %>%
  mutate(ProductServiceOrRnDarea = factor(ProductServiceOrRnDarea)) %>%
  mutate(PlatformPortfolio = factor(PlatformPortfolio)) %>%
  mutate(Shiny.VendorSize = factor(Shiny.VendorSize)) %>%
  mutate(ProductServiceOrRnDarea.sum = factor(ProductServiceOrRnDarea.sum)) %>%
  mutate(Competition.sum = factor(Competition.sum)) %>%
  mutate(Competition.effective.only = factor(Competition.effective.only)) %>%
  mutate(Competition.multisum = factor(Competition.multisum))  %>%
  mutate(No.Competition.sum = factor(No.Competition.sum))

colnames(full_data)[colnames(full_data)=="Fiscal.Year"]<-"fiscal_year"


# write output to CleanedVendorSize.csv
# save(full_data,labels_and_colors,column_key, file="Shiny Apps//FPDS_chart_maker//2018_unaggregated_FPDS.Rda")

# # 
partial <- read_delim(
  "Data//semi_clean//Contract_Agency_ProdServ_FYear.csv",delim = ",")


ota<- read_delim(
  "Data//semi_clean//OTA_Agency_ProdServ_FYear.csv",delim = ",")

# colnames(partial)[colnames(partial)=="X9"]<-"ContractActions"
# 
sum(text_to_number(partial$`Dollars Obligated`))
sum(text_to_number(ota$`Dollars Obligated`))
# # 
# # 
partial<-standardize_variable_names(partial)
ota<-standardize_variable_names(ota)
# 
# 
colnames(partial)[colnames(partial)=="Dollars Obligated"]<-"Action_Obligation"
colnames(partial)[colnames(partial)=="Contracting.Agency.ID"]<-"AgencyID"
partial$Action_Obligation<-text_to_number(partial$Action_Obligation)

colnames(ota)[colnames(ota)=="Dollars Obligated"]<-"Action_Obligation"
colnames(ota)[colnames(ota)=="Contracting.Agency.ID"]<-"AgencyID"
partial$ota<-text_to_number(ota$Action_Obligation)

# 
# 
partial<-deflate(partial,
                   money_var = "Action_Obligation",
                   deflator_var="OMB19_19"
)
# 
ota<-deflate(ota,
                 money_var = "Action_Obligation",
                 deflator_var="OMB19_19"
)


# 
# # 
# partial<-transform_contract(partial)
# 
# 
# 
partial<-read_and_join(partial,
                            path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
                            "Agency_AgencyID.csv",
                            dir="",
                            by=c("AgencyID"),
                            add_var=c("Customer","SubCustomer"),#,"Platform"),
                            skip_check_var=c("Customer","SubCustomer")#Platform"
                       )
# 
# sum(partial$Action_Obligation.Then.Year)

partial<-partial%>%filter(Customer=="Defense")
# 
#Classify Product or Service Codes
partial<-csis360::read_and_join(partial,
                                  "ProductOrServiceCodes.csv",
                                  by="ProductOrServiceCode",
                                  # replace_na_var="ProductServiceOrRnDarea",
                                  add_var=c("Simple"),
                                path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
                                  dir=""
)

f<-full_data %>% group_by(fiscal_year,ProductServiceOrRnDarea.sum) %>% summarise(Action_Obligation_OMB19_19=sum(Action_Obligation_OMB19_19))
p<-partial %>% group_by(Fiscal_Year,Simple) %>% summarise(Action_Obligation_OMB19_19=sum(Action_Obligation_OMB19_19))
colnames(p)<-colnames(f)
p$ProductServiceOrRnDarea.sum<-factor(p$ProductServiceOrRnDarea.sum)
levels(p$ProductServiceOrRnDarea.sum)<-list(
  "Products (All)"=c("Products","Products (All)"),
  "Services (Non-R&D)"=c("Services","Services (Non-R&D)"),
  "R&D"=c("R&D")
)
p<-replace_nas_with_unlabeled(p,"ProductServiceOrRnDarea.sum")
p
f<-rbind(f,p)

f_labels_and_colors<-prepare_labels_and_colors(f,na_replaced=TRUE)
f_column_key<-get_column_key(f)
f$Action_Obligation_OMB19_19
f$fiscal_year
(topline<-build_plot(f %>% filter(ProductServiceOrRnDarea.sum!="Unlabeled"),
               chart_geom = "Bar Chart",
               share = FALSE,
               labels_and_colors=f_labels_and_colors,
               # NA, #VAR.ncol
               x_var="fiscal_year", #x_var
               y_var="Action_Obligation_OMB19_19", #VAR.y.variable
               color_var="ProductServiceOrRnDarea.sum", #color_var
               # facet_var="ContractCrisisFunding", #facet_var
               # second_var="Is.Defense", #facet_var
               column_key=f_column_key,
               format=FALSE,
               legend = TRUE
             )      +
    labs(y="Constant FY 2019 $ Billions")
)
ggsave(topline,file="Output//simple_bucket_topline.png", width=9, height=4.125)
write.csv(f,file="output//topline.csv")           
# 
# 
# partial<-replace_nas_with_unlabeled(partial,"SubCustomer","Uncategorized")
# partial<-csis360::read_and_join(partial,
#                                   "Lookup_SubCustomer.csv",
#                                   by=c("Customer","SubCustomer"),
#                                   add_var="SubCustomer.platform",
#                                   path="https://raw.githubusercontent.com/CSISdefense/R-scripts-and-data/master/",
#                                   dir="Lookups/"
# )
# 
# 
# colnames(partial)[colnames(partial)=="Fiscal.Year"]<-"fiscal_year"
# colnames(partial)[colnames(partial)=="ContractActions"]<-"Number.Of.Actions"
# 
# colnames(partial)[colnames(partial) %in% colnames(full_data)]
# colnames(full_data)[!colnames(full_data) %in% colnames(partial)]
# 
# 
# 
# 
# partial<-partial %>% group_by(ProductServiceOrRnDarea,
#                                         ProductServiceOrRnDarea.sum,
#                           SubCustomer,
#                           SubCustomer.platform,
#                           fiscal_year) %>%
#   dplyr::summarize(Action_Obligation.Then.Year=sum(Action_Obligation.Then.Year,na.rm=TRUE),
#                    Action_Obligation.OMB.2019=sum(Action_Obligation.OMB.2019,na.rm=TRUE),
#                    Number.Of.Actions=sum(Number.Of.Actions,na.rm=TRUE))
# 
# 
# 
# partial$PlatformPortfolio<-"Unlabeled"
# partial$Vendor.Size<-"Unlabeled"
# partial$CompetitionClassification<-"Unlabeled"
# partial$ClassifyNumberOfOffers<-"Unlabeled"
# partial$Shiny.VendorSize<-"Unlabeled"
# partial$Competition.sum<-"Unlabeled"
# partial$Competition.effective.only<-"Unlabeled"
# partial$Competition.multisum<-"Unlabeled"
# partial$No.Competition.sum<-"Unlabeled"
# 
# full_data<-rbind(full_data,as.data.frame(partial))
# 
save(full_data,labels_and_colors,column_key, file="2018_unaggregated_FPDS.Rda")
# 
# 

# write.csv(full_data%>%group_by(fiscal_year)%>%
#       dplyr::summarize(Action_Obligation.Then.Year=sum(Action_Obligation.Then.Year,na.rm=TRUE),
#                                                          Action_Obligation.OMB.2019=sum(Action_Obligation.OMB.2019,na.rm=TRUE),
#                                                          Number.Of.Actions=sum(Number.Of.Actions,na.rm=TRUE)),
#       file="topline_usaspending.csv"
# )
# 
# 
# full_data <- read_delim(
#   "Data//2017_Summary.SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer.txt",delim = "\t",
#   col_names = TRUE, col_types = "cccccccccc",na=c("NA","NULL"))
