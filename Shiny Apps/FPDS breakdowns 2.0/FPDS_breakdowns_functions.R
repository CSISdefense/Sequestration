################################################################################
# Functions for FPDS breakdowns 2.0 Shiny App - March 2017
#
################################################################################


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

 dataset <- function(session, input, current_data){
  # Returns data filtered as the user requests
  #  
  # Returns:
  #   a tibble of filtered data 
  
  shown_data <- current_data
  
  # filter by year
  shown_data %<>%
    filter(Fiscal.Year >= input$year[1] & Fiscal.Year <= input$year[2])
  
  
  # aggregate to appropriate level for breakouts
  breakouts <- c(input$color_var, input$facet_var)
  breakouts <- breakouts[breakouts != "None"]
  y <- get(input$y_var, shown_data)
  if(length(breakouts) == 0){
    shown_data %<>%
      group_by_("Fiscal.Year")
   
    ## help ##
    
    
  } else {
  shown_data %<>%
      group_by_(c("Fiscal.Year",breakouts)) 
    shown_data <- summarize_(shown_data, ~sum(input$y_var))
  }
  
  # calculate shares if share checkbox is checked
  # if(input$use_share == TRUE){
  #   if(input$y_var == "Amount"){
  #     shown_data %<>%
  #       select(-PrimeNumberOfActions) %>%
  #       spread(IsInFSRS, PrimeObligatedAmount)
  #   }
  #   if(input$y_var == "Actions"){
  #     shown_data %<>%
  #       select(-PrimeObligatedAmount) %>%
  #       spread(IsInFSRS, PrimeNumberOfActions)
  #   }
  #   
  #   shown_data$yes[is.na(shown_data$yes)] <- 0
  #   shown_data %<>%
  #     mutate(share = yes / (yes + no))
  # }
  
  return(shown_data)
}