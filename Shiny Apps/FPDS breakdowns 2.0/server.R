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
#library(diigtheme1)
library(stringr)
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
  
  # in case user renames the data-frame choosing variables
  vars <- reactiveValues(
    fiscal_year = "Fiscal.Year",
    user_title = "None")
  
  # create working copies of the data for user modification, while retaining
  # the original data in case the user wants to reset to it
  current_data <- original_data
  changed_data <- original_data
  
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
    plot_data <- format_data_for_plot(current_data, vars$fiscal_year, input)
    # build plot with user-specified geoms
    mainplot <- build_plot_from_input(plot_data, input)
    
    # add overall visual settings to the plot
    mainplot <- mainplot + 
      #diigtheme1:::diiggraph()
      theme(panel.border = element_blank(),
        panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white", color="white"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y = element_line(size=.1, color="lightgray"),
        panel.grid.minor.y = element_line(size=.1, color="lightgray"),
        axis.ticks = element_blank()
  ) +
    theme(plot.title = element_text(
      family = "Open Sans",
      color = "#554449",
      size = 21, face="bold",
      margin=margin(20,0,20,0),
      hjust = 0.5)) +
    theme(axis.text.x = element_text(
      size = 15,
      family = "Open Sans",
      vjust = 7,
      margin = margin(-10,0,0,0))) +
    theme(axis.text.y = element_text(
      size = 15,
      family = "Open Sans",
      color ="#554449",
      margin = margin(0,5,0,0))) +
    theme(axis.title.x = element_text(
      size = 16,
      face = "bold",
      color = "#554449",
      family = "Open Sans",
      margin = margin(15,0,0,60))) +
    theme(axis.title.y = element_text(
      size = 16,
      face = "bold",
      color = "#554449",
      family = "Open Sans",
      margin = margin(0,15,0,0))
    ) +
    theme(legend.text = element_text(
      size = 15,
      family = "Open Sans",
      color ="#554449")) +
    theme(legend.title = element_text(
      size = 15,
      family = "Open Sans",
      color ="#554449")) +
    theme(legend.position = 'bottom') +
    theme(legend.background = element_rect(fill = "white")
    ) 
    
    if(input$show_title == TRUE){
      mainplot <- mainplot + ggtitle(input$title_text) 
    }
        
    # return the built plot
    return(mainplot)
  })
  
  output$plot <- renderPlot({
    mainplot()
  })
  
  output$download_current <- downloadHandler(
    filename = "edited_data_view.csv",
    content = function(file){
      write_csv(changed_data, file) 
    }
  )
  
  output$download_plot <- downloadHandler(
    filename = "plot_data.csv",
    content = function(file){
      write_csv(format_data_for_plot(current_data, input), file)
    }
  )
  
  output$download_image <- downloadHandler(
    filename = "plot_image.jpg",
    content = function(file){
      ggsave(
      filename = file,
      plot = mainplot(),
      width = input$save_plot_width,
      height = input$save_plot_height,
      units = "in")
    }
  )
  # populate and depopulate ui elements when the user changes tabs
  observeEvent(input$current_tab, {
    if(input$current_tab == "Edit Data"){  
      populate_edit_var(current_data, input)
      create_edit_values_list(current_data, input)
    } else {
      clear_edit_ui(input)
      populate_ui_var_lists(current_data)
      changed_data <<- current_data
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
    removeUI(selector = "#edit_value_select")
    # make a new values edit box
    create_edit_values_list(changed_data, input)
  })
  
  
  # drop values from all frames at user request
  observeEvent(input$drop_value_btn, {
    
    changed_data <<- changed_data %>%
      drop_from_frame(input$edit_var, input$edit_value)
    
    # update edit_value list to reflect dropped value
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(changed_data, input)
  })
  
  observeEvent(input$keep_value_btn, {
    
    dropped <- unique(changed_data[[input$edit_var]])
    dropped <- dropped[dropped != input$edit_value]
    
    changed_data <<- changed_data %>%
      drop_from_frame(input$edit_var, dropped)
    
    # update edit_value list to reflect dropped value
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(changed_data, input)
  })
  
  # apply data edits when user says so
  observeEvent(input$apply_changes_btn, {
    current_data <<- changed_data
    updateTabsetPanel(
      session,
      inputId = "current_tab",
      selected = "Charts"
      )
    update_title(current_data, input, vars$user_title)
  })
  
  # discard data changes when user says so
  observeEvent(input$discard_btn, {
    changed_data <<- current_data
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(current_data, input)
  })
  
  # restore orginal data on request
  observeEvent(input$restore_btn, {
    changed_data <<- original_data
    current_data <<- original_data
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(current_data, input)
    update_title(current_data, input, vars$user_title)
    removeUI(selector = "#edit_var_select")
    populate_edit_var(changed_data, input)

    
  })
  
  # update title depending on variable selection
  observeEvent(input$color_var, {
    update_title(current_data, input, vars$user_title)
  })
    
  observeEvent(input$facet_var, {
    update_title(current_data, input, vars$user_title)
  })
  
  observeEvent(input$lock_title, {
    if(input$lock_title) vars$user_title <- input$title_text
    if(!input$lock_title){
      vars$user_title <- "None"
      update_title(current_data, input, vars$user_title)
    }
  })
  
  observeEvent(input$rename_var_btn, {
    if(input$rename_var_txt != "") {
      names(changed_data)[names(changed_data) == input$edit_var] <<-
        input$rename_var_txt
      
      if(input$edit_var == vars$fiscal_year) {
        vars$fiscal_year <- input$rename_var_txt
      }
     
      removeUI(selector = "#edit_var_select")
      populate_edit_var(changed_data, input)
      removeUI(selector = "#edit_value_select")
      create_edit_values_list(changed_data, input) 
    }
  })
  
  
  observeEvent(input$rename_value_btn, {
    if(input$rename_value_txt != "" &
    input$edit_value != "*Not a Category Variable*") {
      
      changed_data <<- rename_value(changed_data, input)

      if(input$edit_var == vars$fiscal_year) {
        vars$fiscal_year <- input$rename_var_txt
      }

      removeUI(selector = "#edit_value_select")
      create_edit_values_list(changed_data, input)
    }
  })

  observeEvent(input$edit_value, {
    updateTextInput(
      session,
      inputId = "rename_value_txt",
      value = input$edit_value
    )
  })
  
    
})