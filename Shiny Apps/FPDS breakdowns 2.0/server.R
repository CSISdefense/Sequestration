################################################################################
# FPDS breakdowns 2.0 app - March 2017
#
# server.R
################################################################################

library(shiny)
library(magrittr)
library(forcats)
library(Cairo)
library(tidyverse)

shinyServer(function(input, output, session) {
  options(scipen = 99)
  source("FPDS_breakdowns_functions.R")
  
  # read data  
  original_data <- read_csv("2016_unaggregated_FPDS.csv")
  
  # set correct data types
  original_data %<>%
    select(-Customer) %>%
    mutate(SubCustomer = factor(SubCustomer)) %>%
    mutate(ProductOrServiceArea = factor(ProductOrServiceArea)) %>%
    mutate(PlatformPortfolio = factor(PlatformPortfolio)) %>%
    mutate(Vendor.Size = factor(Vendor.Size)) %>%
    mutate(CompetitionClassification = factor(CompetitionClassification)) %>%
    mutate(ClassifyNumberOfOffers = factor(ClassifyNumberOfOffers)) %>%
    mutate(Simple = factor(Simple))
  
  # create a working copy of the data for user modification, while retaining
  # the original data in case the user wants to reset to it
  current_data <- original_data
  
  # fill the variable lists in the ui with variables from current_data
  populate_ui_var_lists(current_data, session)
  
  
 mainplot <- reactive({
  # Builds a ggplot based on user settings, for display on the main panel.
  # Reactive binding will cause the ggplot to update when the user changes any
  # relevant setting.  
  #  
  # Returns:
  #   a fully built ggplot object
    
  
  # get appropriately formatted data to use in the plot 
  plot_data <- format_data_for_plot(current_data, session, input)
  
  # build plot with user-specified geoms
  mainplot <- build_plot_from_input(plot_data, session, input)
  
  # add overall visual settings to the plot
  
  
  
  # return the built plot
  return(mainplot)
  })
  
  output$plot <- renderPlot({
    mainplot()
  })

  
  
  
  
  
  
  
  
      
})
