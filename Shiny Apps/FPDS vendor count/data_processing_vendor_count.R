################################################################################
# Data processing for FPDS vendor count - March 2017
################################################################################

library(magrittr)
library(tidyverse)
library(forcats)

  platform_sub <- read.csv(
    "Vendor.sp_EntityCountHistoryPlatformSubCustomer.csv")
  sub_only <- read.csv(
    "Vendor.sp_EntityCountHistorySubCustomer.csv")
  platform_only <- read.csv(
    "Vendor.sp_EntityCountHistoryPlatformCustomer.csv")
  top_level <- read.csv(
    "Vendor.sp_EntityCountHistoryCustomer.csv")

  # remove unused variables
  platform_sub %<>%
    select(-Customer, -EntityCategory, -EntitySizeCode) %>%
    mutate(
      SumOfNumberOfActions = as.character(SumOfNumberOfActions),
      SumOfObligatedAmount = as.character(SumOfObligatedAmount)) %>%
    mutate(
      SumOfNumberOfActions = as.integer(
        ifelse(SumOfNumberOfActions == "NULL", 0, SumOfNumberOfActions)),
      SumOfObligatedAmount = as.numeric(
        ifelse(SumOfObligatedAmount == "NULL", 0, SumOfObligatedAmount))) %>%
    mutate(
      EntitySizeText = fct_recode(
        EntitySizeText,
        Small = "Always Small Vendor",
        Small = "Sometimes Small Vendor",
        Medium = "Medium Vendor",
        "Large+" = "Big Five",
        "Large+" = "Large Vendor",
        "Large+" = "Large: Big 5 JV")) %>%
    group_by(
      fiscal_year, SubCustomer, PlatformPortfolio, EntitySizeText,
      AnyEntityUSplaceOfPerformance,
      IsEntityAbove1990constantReportingThreshold,
      IsEntityAbove2016constantReportingThreshold) %>%
    summarize(
      EntityCount = sum(EntityCount), 
      AllContractorCount = sum(AllContractorCount),
      SumOfNumberOfActions = sum(SumOfNumberOfActions),
      SumOfObligatedAmount = sum(SumOfObligatedAmount)) %>%
    filter(fiscal_year >= 2000)
  
  
  
  platform_only %<>%
    select(-Customer, -EntityCategory, -EntitySizeCode) %>%
    rename(EntityCount = EntityCount) %>%
    mutate(
      SumOfNumberOfActions = as.character(SumOfNumberOfActions),
      SumOfObligatedAmount = as.character(SumOfObligatedAmount)) %>%
    mutate(
      SumOfNumberOfActions = as.integer(
        ifelse(SumOfNumberOfActions == "NULL", 0, SumOfNumberOfActions)),
      SumOfObligatedAmount = as.numeric(
        ifelse(SumOfObligatedAmount == "NULL", 0, SumOfObligatedAmount))) %>%
    mutate(
      EntitySizeText = fct_recode(
        EntitySizeText,
        Small = "Always Small Vendor",
        Small = "Sometimes Small Vendor",
        Medium = "Medium Vendor",
        "Large+" = "Big Five",
        "Large+" = "Large Vendor",
        "Large+" = "Large: Big 5 JV")) %>%
    group_by(
      fiscal_year, PlatformPortfolio, EntitySizeText,
      AnyEntityUSplaceOfPerformance,
      IsEntityAbove1990constantReportingThreshold,
      IsEntityAbove2016constantReportingThreshold) %>%
    summarize(
      EntityCount = sum(EntityCount), 
      AllContractorCount = sum(AllContractorCount),
      SumOfNumberOfActions = sum(SumOfNumberOfActions),
      SumOfObligatedAmount = sum(SumOfObligatedAmount)) %>%
    filter(fiscal_year >= 2000)
                             
    
  names(sub_only)[1] <- "fiscal_year"
  
  sub_only %<>%
    select(-Customer, -EntityCategory, -EntitySizeCode) %>%
    mutate(
      SumOfNumberOfActions = as.character(SumOfNumberOfActions),
      SumOfObligatedAmount = as.character(SumOfObligatedAmount)) %>%
    mutate(
      SumOfNumberOfActions = as.integer(
        ifelse(SumOfNumberOfActions == "NULL", 0, SumOfNumberOfActions)),
      SumOfObligatedAmount = as.numeric(
        ifelse(SumOfObligatedAmount == "NULL", 0, SumOfObligatedAmount))) %>%
    mutate(
      EntitySizeText = fct_recode(
        EntitySizeText,
        Small = "Always Small Vendor",
        Small = "Sometimes Small Vendor",
        Medium = "Medium Vendor",
        "Large+" = "Big Five",
        "Large+" = "Large Vendor",
        "Large+" = "Large: Big 5 JV")) %>%
    group_by(
      fiscal_year, SubCustomer, EntitySizeText,
      AnyEntityUSplaceOfPerformance,
      IsEntityAbove1990constantReportingThreshold,
      IsEntityAbove2016constantReportingThreshold) %>%
    summarize(
      EntityCount = sum(EntityCount), 
      AllContractorCount = sum(AllContractorCount),
      SumOfNumberOfActions = sum(SumOfNumberOfActions),
      SumOfObligatedAmount = sum(SumOfObligatedAmount)) %>%
    filter(fiscal_year >= 2000)
  
  names(top_level)[1] <- "fiscal_year"
  
  top_level %<>%
    filter(Customer == "Defense") %>%
    rename(EntityCount = EntityCount) %>%
    select(-Customer, -EntityCategory, -EntitySizeCode) %>%
    mutate(
      SumOfNumberOfActions = as.character(SumOfNumberOfActions), 
      SumOfObligatedAmount = as.character(SumOfObligatedAmount)) %>%
    mutate(
      SumOfNumberOfActions = as.integer(
        ifelse(SumOfNumberOfActions == "NULL", 0, SumOfNumberOfActions)),
      SumOfObligatedAmount = as.numeric(
        ifelse(SumOfObligatedAmount == "NULL", 0, SumOfObligatedAmount))) %>%
    mutate(
      EntitySizeText = fct_recode(
        EntitySizeText,
        Small = "Always Small Vendor",
        Small = "Sometimes Small Vendor",
        Medium = "Medium Vendor",
        "Large+" = "Big Five",
        "Large+" = "Large Vendor",
        "Large+" =  "Large: Big 5 JV")) %>%
    group_by(
      fiscal_year, EntitySizeText,
      AnyEntityUSplaceOfPerformance,
      IsEntityAbove1990constantReportingThreshold,
      IsEntityAbove2016constantReportingThreshold) %>%
    summarize(
      EntityCount = sum(EntityCount), 
      AllContractorCount = sum(AllContractorCount),
      SumOfNumberOfActions = sum(SumOfNumberOfActions),
      SumOfObligatedAmount = sum(SumOfObligatedAmount)) %>%
    filter(fiscal_year >= 2000)
  
  
  
  deflate <- c(
    "2000" = 0.7057,
    "2001" = 0.7226,
    "2002" = 0.7343,
    "2003" = 0.7483,
    "2004" = 0.7668,
    "2005" = 0.7909,
    "2006" = 0.8166,
    "2007" = 0.8388,
    "2008" = 0.8562,
    "2009" = 0.8662,
    "2010" = 0.8738,
    "2011" = 0.8916,
    "2012" = 0.9078,
    "2013" = 0.9232,
    "2014" = 0.9401,
    "2015" = 0.9511,
    "2016" = 0.9625,
    "2017" = 0.9802,
    "2018" = 1.0000,
    "2019" = 1.0199,
    "2020" = 1.0404,
    "2021" = 1.0612,
    "2022" = 1.0824)
 
  
  sub_only$fiscal_year <- as.character(sub_only$fiscal_year)
  platform_only$fiscal_year <- as.character(platform_only$fiscal_year)
  top_level$fiscal_year <- as.character(top_level$fiscal_year)
  platform_sub$fiscal_year <- as.character(platform_sub$fiscal_year)
  
sub_only$SumOfObligatedAmount <- as.numeric(sub_only$SumOfObligatedAmount /
                           deflate[sub_only$fiscal_year])
platform_only$SumOfObligatedAmount <- round(platform_only$SumOfObligatedAmount /
                           deflate[platform_only$fiscal_year])
platform_sub$SumOfObligatedAmount <- round(platform_sub$SumOfObligatedAmount /
                           deflate[platform_sub$fiscal_year])
top_level$SumOfObligatedAmount <- round(top_level$SumOfObligatedAmount /
                           deflate[top_level$fiscal_year])

sub_only$fiscal_year <- as.numeric(sub_only$fiscal_year)
platform_only$fiscal_year <- as.numeric(platform_only$fiscal_year)
top_level$fiscal_year <- as.numeric(top_level$fiscal_year)
platform_sub$fiscal_year <- as.numeric(platform_sub$fiscal_year)
  
  
  write_csv(platform_only, "platform_only.csv")
  write_csv(sub_only, "sub_only.csv")
  write_csv(platform_sub, "platform_sub.csv")
  write_csv(top_level, "top_level.csv")
  