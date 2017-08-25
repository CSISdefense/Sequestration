# FSRS reporting

library(tidyverse)
library(magrittr)
options(scipen = 999)

comp_data <- read_csv("Data/Contract_FSRSinFPDShistory.csv")

comp_data %<>% 
  filter(NumberOfContracts != "NULL" & fiscal_year >= 2010) %>%
  filter(fiscal_year != "NULL") %>%
  select(
    FY = fiscal_year,
    Amount = PrimeObligatedAmount, 
    Contracts = NumberOfContracts,
    FSRS = IsInFSRS)

p <- ggplot(data = comp_data, aes(x = FY, y = Amount, fill = FSRS)) +
  geom_bar(stat = 'identity', position = 'stack')

p
