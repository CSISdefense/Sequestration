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
  
  current_data <- original_data
  propegate_category_vars_to_ui(session, current_data)
  
  
  # create currently shown filter vector
  # current <- reactiveValues()
  # current$filter <- character(length = 0)
  
  
 mainplot <- reactive({
  # Builds a ggplot based on user settings, for display on the main panel.
  # Reactive binding will cause the ggplot to update when the user changes any
  # relevant setting.  
  #  
  # Returns:
  #   a fully built ggplot object
    
  
  # define plot based on appropriate data  
  mainplot <- ggplot(data = dataset(current_data, session, input))
  
  
  # add a line layer, broken out by color if requested
  if(input$color_var == "None"){
    mainplot <- mainplot +
      geom_line(aes_q(x = as.name("Fiscal.Year"), y = as.name(input$y_var)))
  } else {
    mainplot <- mainplot +
      geom_line(aes_q(x = as.name("Fiscal.Year"), y = as.name(input$y_var),
        color = as.name(input$color_var)))
  }
  
  # add faceting if requested
  if(input$facet_var != "None"){
    mainplot <- mainplot +
      facet_wrap(as.formula(paste("~",input$facet_var))) 
  }
  
  # add other settings to the plot
  
  
  
  # return the built plot
  return(mainplot)
  })
  
  output$plot <- renderPlot({
    mainplot()
  })

  
  
  
  
  
  
  
  
      
})
