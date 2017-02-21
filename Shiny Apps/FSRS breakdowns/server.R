library(shiny)
library(tidyverse)
library(forcats)
library(magrittr)

shinyServer(function(input, output, session) {

  # read data  
  FullData <- read_csv("FSRSprocessed.csv")
  
  # set correct data types
  FullData %<>%
    mutate(SubCustomer = factor(SubCustomer)) %>%
    mutate(ProductOrServiceArea = factor(ProductOrServiceArea)) %>%
    mutate(Simple = factor(Simple)) %>%
    mutate(PlatformPortfolio = factor(PlatformPortfolio)) %>%
    mutate(VendorSize = factor(VendorSize)) %>%
    mutate(IsInFSRS = factor(IsInFSRS))
  
  
  
  
  dataset <- function(filtervars, allowedvalues){
  # Returns data filtered as the user requests
  #  
  # Args:
  #   filtervars: a character vector of categorical variables to filter by
  #   allowedvalues: a list containing a vector of allowable values for each
  #      variable in filtervars
  #   
  # Returns:
  #   a tibble of filtered data 

    
  }
  
  plotsettings <- reactive({
    
  })
  
  output$plot <- renderPlot({

  })

})
