################################################################################
# Functions for FPDS breakdowns 2.0 Shiny App - March 2017
#
################################################################################

library(tidyverse)
library(lazyeval)

populate_ui_var_lists <- function(data_source, session){
  # Fills the ui menus with appropriate variables from the tibble passed to it
  #
  # Args:
  #   session: the active session of the shiny app, from server.R
  #   data_source: tibble from which to populate the ui menus    
  
  # get the class for each variable (except fiscal year)
  var_class <- sapply(data_source[-1], class)
  
  # put numeric variables in the y_var list
  numerics <- names(data_source[-1])[var_class == "numeric"]
  updateSelectInput(session, "y_var", choices = numerics)
  
  # put categorical variables in the color_var and facet_var lists
  categories <- names(data_source[-1])[var_class == "factor"]
  categories <- c("None", categories)
  updateSelectInput(session, "color_var", choices = categories)
  updateSelectInput(session, "facet_var", choices = categories)
}  

format_data_for_plot <- function(incoming_data, session, input){
  # Returns data in the appropriate format for the user-specified plot
  #
  # Args:
  #   incoming_data: tibble of data to format
  #   session: current session of shiny, passed from server.R
  #   input: the user input object from the shiny session
  # 
  # Returns:
  #   a tibble of formatted data
  
  shown_data <- incoming_data
  
  # filter by year
  shown_data %<>%
    filter(Fiscal.Year >= input$year[1] & Fiscal.Year <= input$year[2])
  
  # aggregate to the level of [fiscal year x breakouts]
  # the evaluation for dplyr::summarize_ was a pain in the ass to figure out;
  # see stack overflow at https://tinyurl.com/z82ywf3
  breakouts <- c(input$color_var, input$facet_var)
  breakouts <- breakouts[breakouts != "None"]
  if(length(breakouts) == 0){
    shown_data %<>%
      group_by_(names(shown_data)[1]) %>%
      summarize_(
        sum_val = interp(~sum(var, na.rm = TRUE), var = as.name(input$y_var)))
  } else {
    shown_data %<>%
      group_by_(.dots = c("Fiscal.Year", breakouts)) %>%
      summarize_(
        sum_val = interp(~sum(var, na.rm = TRUE), var = as.name(input$y_var)))
  }
  
  names(shown_data)[which(names(shown_data) == "sum_val")] <- input$y_var
  
  #
  # NOTE: NAs replaced with 0 here; potential data quality issue
  #
  shown_data[is.na(shown_data)] <- 0
  
  # calculate shares if share checkbox is checked
  if(input$y_total_or_share == "As Share" & input$color_var != "None"){
    
    # share_vars indicates which columns are being used to calculate the shares.
    # If there's only one breakout, it's set to -1:
    # "everything except fiscal year." 
    # With two breakouts, it's set to c(-1, -2):
    # "everything except fiscal year and the facet variable."
    share_vars <- c(-1, -length(breakouts))
    
    # spread the shares breakout variable across multiple columns
    shown_data %<>%
      spread_(input$color_var, input$y_var)
    
    #
    # NOTE: NAs replaced with 0 here; potential data quality issue
    #
    shown_data[is.na(shown_data)] <- 0
    
    # calculate a total for each row - i.e. the total for the shares breakout
    # variable for each fiscal year,
    # or for each [fiscal year x facet variable] combo
    shown_data$total <- rowSums(shown_data[share_vars])
    
    # divide each column by the total column, to get each column as shares
    shown_data[share_vars] <-
      sapply(shown_data[share_vars], function(x){x / shown_data$total})
    shown_data %<>% select(-total)
    
    # gather the data back to long form
    shown_data <- gather_(
      data = shown_data,
      key_col = input$color_var,
      value_col = input$y_var,
      gather_cols = names(shown_data[share_vars])
    )
  }
  
  # For the case where the user displays shares not broken out by any variable.
  # This is going to make a very boring chart of 100% shares, 
  # but it's handled here to avoid displaying an error.
  if(input$y_total_or_share == "As Share" & input$color_var == "None"){
    shown_data %<>%
      mutate(total = 1)
    shown_data <- shown_data[which(names(shown_data) != input$y_var)]
    names(shown_data)[which(names(shown_data) == "total")] <- input$y_var
  }
  
  # return the ggplot-ready data
  return(shown_data)
}

build_plot_from_input <- function(plot_data, session, input) {
  # Adds a geom layer to a ggplot object based on user input.  
  # Intended to handle ggplot settings that depend on user input.
  # Settings that apply universally should be added in server.R
  #
  # Args:
  #   plot_data: data tibble for use in the plot
  #   session: current session of shiny, passed from server.R
  #   input: the user input object from the shiny session
  # 
  # Returns:
  #   A ggplot object including user-specified geom layer
  
  mainplot <- ggplot(data = plot_data)
  
  # add a line layer, broken out by color if requested
  if(input$chart_geom == "Line Chart"){
    if(input$color_var == "None"){
      mainplot <- mainplot +
        geom_line(aes_q(
          x = as.name(names(plot_data)[1]),
          y = as.name(input$y_var)
        ))
    } else {
      mainplot <- mainplot +
        geom_line(aes_q(
          x = as.name(names(plot_data)[1]),
          y = as.name(input$y_var),
          color = as.name(input$color_var)
        ))
    }
  }
  
  # add a bar layer, broken out by color if requested
  if(input$chart_geom == "Bar Chart"){
    if(input$color_var == "None"){
      mainplot <- mainplot +
        geom_bar(aes_q(
          x = as.name(names(plot_data)[1]),
          y = as.name(input$y_var)
        ),
        stat = "identity")
    } else {
      mainplot <- mainplot +
        geom_bar(aes_q(
          x = as.name(names(plot_data)[1]),
          y = as.name(input$y_var),
          fill = as.name(input$color_var)
        ),
        stat = "identity")
    }
  }
  
  # add faceting if requested
  if(input$facet_var != "None"){
    mainplot <- mainplot +
      facet_wrap(as.formula(paste("~",input$facet_var))) 
  }

  # return the plot to server.R
  return(mainplot)
}