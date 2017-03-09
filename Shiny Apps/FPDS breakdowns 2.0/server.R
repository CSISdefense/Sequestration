################################################################################
# FPDS breakdowns 2.0 app - March 2017
#
# server.R
################################################################################

library(shiny)
library(magrittr)
library(forcats)
library(Cairo)
library(shinyBS)
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
  populate_ui_var_lists(current_data)
  
  
  mainplot <- reactive({
    # Builds a ggplot based on user settings, for display on the main panel.
    # Reactive binding will cause the ggplot to update when the user changes any
    # relevant setting.  
    #  
    # Returns:
    #   a fully built ggplot object
    
    
    # get appropriately formatted data to use in the plot 
    plot_data <- format_data_for_plot(current_data, input)
    
    # build plot with user-specified geoms
    mainplot <- build_plot_from_input(plot_data, input)
    
    # add overall visual settings to the plot
    
    
    
    # return the built plot
    return(mainplot)
  })
  
  output$plot <- renderPlot({
    mainplot()
  })
  
  # populate and depopulate ui elements when the user changes tabs
  observeEvent(input$current_tab, {
    
  if(input$current_tab == "Edit Data"){  
    populate_edit_var(current_data, input)
    create_edit_values_list(current_data, input)
  } else {
    clear_edit_ui(input)
  }
      
  })
  
  # change ui elements when the user changes variable in the edit tab
  observeEvent(input$edit_var, {
    
    # change the variable rename text box
    updateTextInput(
      session,
      inputId = "rename_var_txt",
      value = input$edit_var
    )
    
    # delete previous values edit box
    removeUI(
      selector = "#edit_value_select"
    )
    
    # make a new values edit box
    create_edit_values_list(current_data, input, session)
  })
  
  
  
  
})
