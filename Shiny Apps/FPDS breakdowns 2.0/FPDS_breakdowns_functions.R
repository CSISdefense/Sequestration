################################################################################
# Functions for FPDS breakdowns 2.0 Shiny App - March 2017
#
################################################################################

library(tidyverse)
library(lazyeval)

  propegate_category_vars_to_ui <- function(session, current_data){
    # Fills the ui menus (y_var, color_var, facet_var) with whatever categorical
    # variables remain in current_data (i.e. haven't been dropped by the user)
    #
    # Args:
    #   session: the active session of the shiny app, from server.R
    #   current_data: the active user-modified dataframe in server.R     
    var_class <- sapply(current_data[-1], class)
    
    numerics <- names(current_data[-1])[var_class == "numeric"]
    updateSelectInput(session, "y_var", choices = numerics)
    
    
    categories <- names(current_data[-1])[var_class == "factor"]
    categories <- c("None", categories)
    updateSelectInput(session, "color_var", choices = categories)
    updateSelectInput(session, "facet_var", choices = categories)
  }  

 dataset <- function(current_data, session, input){
  # Returns data filtered as the user requests
  #
  # Args:
  #   current_data: the currently-in-use data frame for the app
  #   session: current session of shiny, passed from server.R
  #   input: the user input object from the shiny session
  # 
  # Returns:
  #   a tibble of filtered data

  shown_data <- current_data

  # filter by year
  shown_data %<>%
    filter(Fiscal.Year >= input$year[1] & Fiscal.Year <= input$year[2])

  # aggregate to appropriate level for breakouts
  # the evaluation for dplyr::summarize was pain in the ass to figure out;
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
  # This is going to make a very boring chart, but it's handled here to avoid
  # displaying an error.
  if(input$y_total_or_share == "As Share" & input$color_var == "None"){
    shown_data %<>%
      mutate(total = 1)
    shown_data <- shown_data[which(names(shown_data) != input$y_var)]
    names(shown_data)[which(names(shown_data) == "total")] <- input$y_var
  }

  # return the ggplot-ready data
  return(shown_data)
}