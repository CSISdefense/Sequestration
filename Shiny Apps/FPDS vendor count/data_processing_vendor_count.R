################################################################################
# Data processing for FPDS vendor count - March 2017
################################################################################

library(magrittr)
library(tidyverse)

  platform_sub <- read.csv(
    "Defense_Vendor_sp_EntityCountHistoryPlatformSubCustomer.csv")
  sub_only <- read.csv(
    "Defense_Vendor_sp_EntityCountHistorySubCustomer.csv")
  platform_only <- read.csv(
    "Defense_Vendor_sp_EntityCountHistoryPlatformCustomer.csv")
  top_level <- read.csv(
    "Vendor_sp_EntityCountHistoryCustomer.csv")
  
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
    rename(EntityCount = EntityCounty) %>%
    mutate(
      SumOfNumberOfActions = as.character(SumOfNumberOfActions),
      SumOfObligatedAmount = as.character(SumOfObligatedAmount)) %>%
    mutate(
      SumOfNumberOfActions = as.integer(
        ifelse(SumOfNumberOfActions == "NULL", 0, SumOfNumberOfActions)),
      SumOfObligatedAmount = as.numeric(
        ifelse(SumOfObligatedAmount == "NULL", 0, SumOfObligatedAmount))) %>%
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
    rename(EntityCount = EntityCounty) %>%
    select(-Customer, -EntityCategory, -EntitySizeCode) %>%
    mutate(
      SumOfNumberOfActions = as.character(SumOfNumberOfActions),
      SumOfObligatedAmount = as.character(SumOfObligatedAmount)) %>%
    mutate(
      SumOfNumberOfActions = as.integer(
        ifelse(SumOfNumberOfActions == "NULL", 0, SumOfNumberOfActions)),
      SumOfObligatedAmount = as.numeric(
        ifelse(SumOfObligatedAmount == "NULL", 0, SumOfObligatedAmount))) %>%
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

sub_only$fiscal_year <- factor(sub_only$fiscal_year)
platform_only$fiscal_year <- factor(platform_only$fiscal_year)
platform_sub$fiscal_year <- factor(platform_sub$fiscal_year)
top_level$fiscal_year <- factor(top_level$fiscal_year)
  
sub_only$SumOfObligatedAmount <- round(sub_only$SumOfObligatedAmount /
                           deflate[sub_only$fiscal_year])
platform_only$SumOfObligatedAmount <- round(platform_only$SumOfObligatedAmount /
                           deflate[platform_only$fiscal_year])
platform_sub$SumOfObligatedAmount <- round(platform_sub$SumOfObligatedAmount /
                           deflate[platform_sub$fiscal_year])
top_level$SumOfObligatedAmount <- round(top_level$SumOfObligatedAmount /
                           deflate[top_level$fiscal_year])


  
  
  write_csv(platform_only, "platform_only.csv")
  write_csv(sub_only, "sub_only.csv")
  write_csv(platform_sub, "platform_sub.csv")
  write_csv(top_level, "top_level.csv")
  