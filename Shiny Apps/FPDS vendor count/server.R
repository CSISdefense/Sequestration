################################################################################
# Vendor Count App - March 2017
#
# server.R
################################################################################

library(shiny)
library(magrittr)
library(forcats)
library(Cairo)
library(shinyBS)
library(stringr)
library(tidyverse)

shinyServer(function(input, output, session) {
  options(scipen = 99)
  source("vendor_count_functions.R")
  
  # read data  
  platform_sub <- read.csv("platform_sub.csv")
  sub_only <- read.csv("sub_only.csv")
  platform_only <- read.csv("platform_only.csv")
  
  # in case user renames the data-frame choosing variables
  vars <- reactiveValues(
    double_counted = c(
      "PlatformPortfolio" = "PlatformPortfolio",
      "SubCustomer" = "SubCustomer"),
    frame = "current_platform_only")
  
  # create working copies of the data for user modification, while retaining
  # the original data in case the user wants to reset to it
  current_platform_sub <- platform_sub
  changed_platform_sub <- platform_sub
  current_platform_only <- platform_only
  changed_platform_only <- platform_only
  current_sub_only <- sub_only
  changed_sub_only <- sub_only
  
  # fill the variable lists in the ui with variables from current_platform_sub
  populate_ui_var_lists(current_platform_only)
  
  
  mainplot <- reactive({
    # Builds a ggplot based on user settings, for display on the main panel.
    # Reactive binding will cause the ggplot to update when the user changes any
    # relevant setting.  
    #  
    # Returns:
    #   a fully built ggplot object
    
    # get appropriately formatted data to use in the plot
    plot_data <- format_data_for_plot(get(vars$frame), input)
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
      size = 26, face="bold",
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
        
    # return the built plot
    return(mainplot)
  })
  
  output$plot <- renderPlot({
    mainplot()
  })
  
  output$download_current <- downloadHandler(
    filename = "edited_data_view.csv",
    content = function(file){
      write_csv(get(gsub("current", "changed", vars$frame)), file) 
    }
  )
  
  output$download_plot <- downloadHandler(
    filename = "plot_data.csv",
    content = function(file){
      write_csv(format_data_for_plot(get(vars$frame), input), file)
    }
  )
  
  # populate and depopulate ui elements when the user changes tabs
  observeEvent(input$current_tab, {
    if(input$current_tab == "Edit Data"){  
      populate_edit_var(get(gsub("current", "changed", vars$frame)), input)
      create_edit_values_list(get(vars$frame), input)
    } else {
      clear_edit_ui(input)
      populate_ui_var_lists(get(vars$frame))
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
    create_edit_values_list(get(gsub("current", "changed", vars$frame)), input)
  })
  
  
  # drop values from changed_platform_sub at user request
  observeEvent(input$drop_value_btn, {
    changed_platform_sub <<- 
      changed_platform_sub[changed_platform_sub[[input$edit_var]] !=
        input$edit_value, ]
    changed_platform_sub[[input$edit_var]] <<-
      fct_drop(changed_platform_sub[[input$edit_var]])
    
    if(input$edit_var != vars$double_counted["SubCustomer"]){
      changed_platform_only <<- 
        changed_platform_only[changed_platform_only[[input$edit_var]] !=
                              input$edit_value, ]
      changed_platform_only[[input$edit_var]] <<-
        fct_drop(changed_platform_only[[input$edit_var]])
    }
    
    if(input$edit_var != vars$double_counted["PlatformPortfolio"]){
    changed_sub_only <<- 
      changed_sub_only[changed_sub_only[[input$edit_var]] !=
        input$edit_value, ]
    changed_sub_only[[input$edit_var]] <<-
      fct_drop(changed_sub_only[[input$edit_var]])
    }
    
    # update edit_value list to reflect dropped value
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(get(gsub("current", "changed", vars$frame)), input)
  })
  
  observeEvent(input$keep_value_btn, {
    changed_platform_sub <<-
      changed_platform_sub[changed_platform_sub[[input$edit_var]] ==
        input$edit_value, ]
    changed_platform_sub[[input$edit_var]] <<-
      fct_drop(changed_platform_sub[[input$edit_var]])
    
    if(input$edit_var != vars$double_counted["SubCustomer"]){
      changed_platform_only <<-
        changed_platform_only[changed_platform_only[[input$edit_var]] ==
                              input$edit_value, ]
      changed_platform_only[[input$edit_var]] <<-
        fct_drop(changed_platform_only[[input$edit_var]])
    }
    
    if(input$edit_var != vars$double_counted["PlatformPortfolio"]){
      changed_sub_only <<-
        changed_sub_only[changed_sub_only[[input$edit_var]] ==
                           input$edit_value, ]
      changed_sub_only[[input$edit_var]] <<-
        fct_drop(changed_sub_only[[input$edit_var]])
    }
    
    # update edit_value list to reflect dropped value
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(get(gsub("current", "changed", vars$frame)), input)
  })
  
  # apply data edits when user says so
  observeEvent(input$apply_changes_btn, {
    current_platform_sub <<- changed_platform_sub
    current_platform_only <<- changed_platform_only
    current_sub_only <<- changed_sub_only
    updateTabsetPanel(
      session,
      inputId = "current_tab",
      selected = "Charts"
      )
  })
  
  # discard data changes when user says so
  observeEvent(input$discard_btn, {
    changed_platform_sub <<- current_platform_sub
    changed_sub_only <<- current_sub_only
    changed_platform_only <<- current_platform_only
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(get(gsub("current", "changed", vars$frame)), input)
  })
  
  # restore orginal data on request
  observeEvent(input$restore_btn, {
    changed_platform_sub <<- platform_sub
    changed_platform_only <<- platform_only
    changed_sub_only <<- sub_only
    current_platform_sub <<- platform_sub
    current_platform_only <<- platform_only
    current_sub_only <<- sub_only
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(get(gsub("current", "changed", vars$frame)), input)
  })
  
  observeEvent(input$agg_level, {
    if(input$agg_level == "SubCustomer") {
      vars$frame <- "current_sub_only"}
    if(input$agg_level == "PlatformPortfolio") {
      vars$frame <- "current_platform_only"}
    if(input$agg_level == "Both (Double Counts)") {  
      vars$frame <- "current_platform_sub"}
    populate_ui_var_lists(get(vars$frame))
  })
  
  
})
