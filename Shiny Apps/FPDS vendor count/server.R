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
  #windowsFonts(`Open Sans` = windowsFont("Open Sans"))
  source("vendor_count_functions.R")
  
  # read data  
  platform_sub <- read.csv("platform_sub.csv")
  sub_only <- read.csv("sub_only.csv")
  platform_only <- read.csv("platform_only.csv")
  top_level <- read.csv("top_level.csv")
  # in case user renames the data-frame choosing variables
  vars <- reactiveValues(
    double_counted = c(
      "PlatformPortfolio" = "PlatformPortfolio",
      "SubCustomer" = "SubCustomer"),
    frame = "current_top_level",
    fiscal_year = "fiscal_year",
    user_title = "None")
  
  # create working copies of the data for user modification, while retaining
  # the original data in case the user wants to reset to it
  current_platform_sub <- platform_sub
  changed_platform_sub <- platform_sub
  current_platform_only <- platform_only
  changed_platform_only <- platform_only
  current_sub_only <- sub_only
  changed_sub_only <- sub_only
  current_top_level <- top_level
  changed_top_level <- top_level
  
  # fill the variable lists in the ui with variables from current_platform_sub
  populate_ui_var_lists(current_platform_sub)
  
  
  mainplot <- reactive({
    # Builds a ggplot based on user settings, for display on the main panel.
    # Reactive binding will cause the ggplot to update when the user changes any
    # relevant setting.  
    #  
    # Returns:
    #   a fully built ggplot object
    # get appropriately formatted data to use in the plot
    vars$frame <- 
      choose_data_frame(current_platform_sub, input, vars$double_counted)
    plot_data <- format_data_for_plot(get(vars$frame), vars$fiscal_year, input)
    # build plot with user-specified geoms
    mainplot <- build_plot_from_input(plot_data, input)
 
    # add overall visual settings to the plot
    mainplot <- mainplot + labs(x = "Fiscal Year", y = "Vendor Count") + 
      #diigtheme1:::diiggraph()
      theme(
        panel.border = element_blank(),
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
      hjust = 0.5))  +
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
    
     if(length(input$facet_var) == 0){
    mainplot <- mainplot +  theme(axis.text.x = element_text(
      size = 15,
      family = "Open Sans",
      vjust = 7,
      margin = margin(-10,0,0,0)))}
    else if(length(input$facet_var) > 0){
      mainplot <- mainplot +  theme(axis.text.x = element_text(
        size = 15,
        family = "Open Sans",
        vjust = 7),
        strip.background = element_rect(colour = "#554449", fill = "white", size=0.5),
        panel.border = element_rect(colour = "#554449", fill=NA, size=0.5)
      )}
      
       
    # return the built plot
    return(mainplot)
  })
  
  output$plot <- renderPlot({
    mainplot()
  })

    
  output$current_frame <- renderText({
    paste("displayed data: \n", vars$frame)
  })
  
  output$download_current <- downloadHandler(
    filename = "edited_data_view.csv",
    content = function(file){
      write_csv(changed_platform_sub, file) 
    }
  )
  
  output$download_plot <- downloadHandler(
    filename = "plot_data.csv",
    content = function(file){
      write.csv(format_data_for_plot(get(vars$frame),vars$fiscal_year, input), 
                file, row.names = FALSE)
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
      populate_edit_var(current_platform_sub, input)
      create_edit_values_list(current_platform_sub, input)
    } else {
      clear_edit_ui(input)
      populate_ui_var_lists(current_platform_sub)
      changed_platform_sub <<- current_platform_sub
      changed_platform_only <<- current_platform_only
      changed_top_level <<- current_top_level
      changed_sub_only <<- current_sub_only
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
    create_edit_values_list(changed_platform_sub, input)
  })
  
  
  # drop values from all frames at user request
  observeEvent(input$drop_value_btn, {
    
    changed_platform_sub <<- changed_platform_sub %>%
      drop_from_frame(input$edit_var, input$edit_value)
    
    if(input$edit_var != vars$double_counted["SubCustomer"]){
      changed_platform_only <<- changed_platform_only %>%
        drop_from_frame(input$edit_var, input$edit_value)
    }
    if(input$edit_var != vars$double_counted["PlatformPortfolio"]){
      changed_sub_only <<- changed_sub_only %>%
        drop_from_frame(input$edit_var, input$edit_value)
    }
    if(input$edit_var != vars$double_counted["PlatformPortfolio"] &
       input$edit_var != vars$double_counted["SubCustomer"]) {
      changed_top_level <<- changed_top_level %>%
        drop_from_frame(input$edit_var, input$edit_value)
    }
    
    # update edit_value list to reflect dropped value
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(changed_platform_sub, input)
  })
  
  observeEvent(input$keep_value_btn, {
    
    dropped <- unique(changed_platform_sub[[input$edit_var]])
    dropped <- dropped[dropped != input$edit_value]
    
    changed_platform_sub <<- changed_platform_sub %>%
      drop_from_frame(input$edit_var, dropped)
    
    if(input$edit_var != vars$double_counted["SubCustomer"]){
      changed_platform_only <<- changed_platform_only %>%
        drop_from_frame(input$edit_var, dropped)
    }
    if(input$edit_var != vars$double_counted["PlatformPortfolio"]){
      changed_sub_only <<- changed_sub_only %>%
        drop_from_frame(input$edit_var, dropped)
    }
    if(!(input$edit_var %in% vars$double_counted)) {
      changed_top_level <<- changed_top_level %>%
        drop_from_frame(input$edit_var, dropped)
    }
    
    # update edit_value list to reflect dropped value
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(changed_platform_sub, input)
  })
  
  # apply data edits when user says so
  observeEvent(input$apply_changes_btn, {
    current_platform_sub <<- changed_platform_sub
    current_platform_only <<- changed_platform_only
    current_sub_only <<- changed_sub_only
    current_top_level <<- changed_top_level
    updateTabsetPanel(
      session,
      inputId = "current_tab",
      selected = "Charts"
      )
    vars$frame <- 
      choose_data_frame(current_platform_sub, input, vars$double_counted)
    update_title(get(vars$frame), input, vars$user_title)
  })
  
  # discard data changes when user says so
  observeEvent(input$discard_btn, {
    changed_platform_sub <<- current_platform_sub
    changed_sub_only <<- current_sub_only
    changed_platform_only <<- current_platform_only
    changed_top_level <<- current_top_level
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(current_platform_sub, input)
  })
  
  # restore orginal data on request
  observeEvent(input$restore_btn, {
    changed_platform_sub <<- platform_sub
    changed_platform_only <<- platform_only
    changed_sub_only <<- sub_only
    changed_top_level <<- top_level
    current_platform_sub <<- platform_sub
    current_platform_only <<- platform_only
    current_sub_only <<- sub_only
    current_top_level <<- top_level
    removeUI(selector = "#edit_value_select")
    create_edit_values_list(current_platform_sub, input)
    update_title(get(vars$frame), input, vars$user_title)
    removeUI(selector = "#edit_var_select")
    populate_edit_var(changed_platform_sub, input)

    
  })
  
  # choose the active data frame depending on user selections
  observeEvent(input$color_var, {
    vars$frame <- 
      choose_data_frame(current_platform_sub, input, vars$double_counted)
    update_title(get(vars$frame), input, vars$user_title)
  })
    
  observeEvent(input$facet_var, {
    vars$frame <- 
      choose_data_frame(current_platform_sub, input, vars$double_counted)
    update_title(get(vars$frame), input, vars$user_title)
  })
  
  observeEvent(input$lock_title, {
    if(input$lock_title) vars$user_title <- input$title_text
    if(!input$lock_title){
      vars$user_title <- "None"
      update_title(get(vars$frame), input, vars$user_title)
    }
  })
  
  observeEvent(input$rename_var_btn, {
    if(input$rename_var_txt != "") {
      names(changed_sub_only)[names(changed_sub_only) == input$edit_var] <<-
        input$rename_var_txt
      names(changed_platform_only)[names(changed_platform_only) == input$edit_var] <<-
        input$rename_var_txt
      names(changed_platform_sub)[names(changed_platform_sub) == input$edit_var] <<-
        input$rename_var_txt
      names(changed_top_level)[names(changed_top_level) == input$edit_var] <<-
        input$rename_var_txt
      
      if(input$edit_var == vars$double_counted["SubCustomer"]) {
        vars$double_counted["SubCustomer"] <- input$rename_var_txt
      }
      
      if(input$edit_var == vars$double_counted["PlatformPortfolio"]) {
        vars$double_counted["PlatformPortfolio"] <- input$rename_var_txt
      }
      
      if(input$edit_var == vars$fiscal_year) {
        vars$fiscal_year <- input$rename_var_txt
      }
     
      removeUI(selector = "#edit_var_select")
      populate_edit_var(changed_platform_sub, input)
      removeUI(selector = "#edit_value_select")
      create_edit_values_list(changed_platform_sub, input) 
    }
  })
  
  
  observeEvent(input$rename_value_btn, {
    if(input$rename_value_txt != "" &
    input$edit_value != "*Not a Category Variable*") {
      
      changed_top_level <<- rename_value(changed_top_level, input)
      changed_platform_sub <<- rename_value(changed_platform_sub, input)
      changed_platform_only <<- rename_value(changed_platform_only, input)
      changed_sub_only <<- rename_value(changed_sub_only, input)
      

      if(input$edit_var == vars$double_counted["SubCustomer"]) {
        vars$double_counted["SubCustomer"] <- input$rename_var_txt
      }

      if(input$edit_var == vars$double_counted["PlatformPortfolio"]) {
        vars$double_counted["PlatformPortfolio"] <- input$rename_var_txt
      }

      if(input$edit_var == vars$fiscal_year) {
        vars$fiscal_year <- input$rename_var_txt
      }

      removeUI(selector = "#edit_value_select")
      create_edit_values_list(changed_platform_sub, input)
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
