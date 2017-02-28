library(shiny)
library(tidyverse)
library(forcats)
library(magrittr)
library(reshape2)

shinyServer(function(input, output, session) {

  options(scipen = 99)
  
  # read data  
  full_data <- read_csv("FSRSprocessed.csv")
  
  # set correct data types
  full_data %<>%
    mutate(Customer = factor(Customer)) %>%
    mutate(SubCustomer = factor(SubCustomer)) %>%
    mutate(ProductOrServiceArea = factor(ProductOrServiceArea)) %>%
    mutate(SimpleArea = factor(SimpleArea)) %>%
    mutate(PlatformPortfolio = factor(PlatformPortfolio)) %>%
    mutate(Vendor.Size = factor(Vendor.Size)) %>%
    mutate(IsInFSRS = factor(IsInFSRS))
  
  # create currently shown filter vector
  current <- reactiveValues()
  current$filter <- character(length = 0)
  
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
  shown_data <- full_data
  
  # filter by year
  shown_data %<>%
    filter(Fiscal.Year >= input$year[1] & Fiscal.Year <= input$year[2])
  
  # filter by filter variables
  if(length(current$filter) != 0){
    if("Customer" %in% current$filter){
      shown_data %<>%
        filter(Customer %in% input$Customer)
    }
    if("SubCustomer" %in% current$filter){
      shown_data %<>%
        filter(SubCustomer %in% input$SubCustomer)
    }
    if("ProductOrServiceArea" %in% current$filter){
      shown_data %<>%
        filter(ProductOrServiceArea %in% input$ProductOrServiceArea)
    }
    if("SimpleArea" %in% current$filter){
      shown_data %<>%
        filter(SimpleArea %in% input$SimpleArea)
    }
    if("PlatformPortfolio" %in% current$filter){
      shown_data %<>%
        filter(PlatformPortfolio %in% input$PlatformPortfolio)
    }
    if("Vendor.Size" %in% current$filter){
      shown_data %<>%
        filter(Vendor.Size %in% input$Vendor.Size)
    }
  }
  
  
  # aggregate to the breakout level
  if(input$breakout == "None"){
    shown_data %<>%
      group_by(Fiscal.Year, IsInFSRS) %>%
      summarize(
        PrimeObligatedAmount = sum(PrimeObligatedAmount, na.rm = TRUE),
        PrimeNumberOfActions = sum(PrimeNumberOfActions, na.rm = TRUE)
      )
  } else {
    shown_data %<>% 
      # see vignette("nse")
      group_by_(.dots = c("Fiscal.Year", "IsInFSRS", input$breakout)) %>%
      summarize(
        PrimeObligatedAmount = sum(PrimeObligatedAmount),
        PrimeNumberOfActions = sum(PrimeNumberOfActions)
      )
  }
  
  
  # calculate shares if share checkbox is checked
  if(input$use_share == TRUE){
    if(input$y_var == "Amount"){
      shown_data %<>%
        select(-PrimeNumberOfActions) %>%
        spread(IsInFSRS, PrimeObligatedAmount)
    }
    if(input$y_var == "Actions"){
      shown_data %<>%
        select(-PrimeObligatedAmount) %>%
        spread(IsInFSRS, PrimeNumberOfActions)
    }
    
    shown_data$yes[is.na(shown_data$yes)] <- 0
    shown_data %<>%
      mutate(share = yes / (yes + no))
  }
  
  return(shown_data)
}
  
  mainplot <- reactive({
  # Builds a ggplot based on user settings, for display on the main panel.
  # Reactive binding will cause the ggplot to update when the user changes any
  # relevant setting.  
  #  
  # Returns:
  #   a fully built ggplot object
    current_data <- dataset(input$filter, "dummy")
  
    
    
  # creates a different plot depending on user choice of y var and share check    
    if(input$use_share == FALSE){
      
      # plots using count/amount
      
      if(input$y_var == "Amount"){
        mainplot <- ggplot(data = current_data, aes(x = Fiscal.Year,
          y = PrimeObligatedAmount, color = IsInFSRS)) +
          ylab("$ 2016") 
      }
      if(input$y_var == "Actions"){
        mainplot <- ggplot(data = current_data, aes(x = Fiscal.Year,
          y = PrimeNumberOfActions, color = IsInFSRS)) +
          ylab("Number of Actions") 
      }
    } else {
      
      # plots using share
      
      if(input$y_var == "Amount"){
        mainplot <- ggplot(data = current_data, aes(x = Fiscal.Year,
          y = share)) +
          ylab("Share of prime $$$ in FSRS") +
          scale_y_continuous()
      }
      if(input$y_var == "Actions"){
        mainplot <- ggplot(data = current_data, aes(x = Fiscal.Year,
          y = share)) +
          ylab("Share of prime Actions in FSRS") +
          scale_y_continuous()
      }
    }
      
      
      
      
      
  
  mainplot <- mainplot + geom_line()
  
  mainplot <- switch(input$breakout,
    "None" = mainplot,
    "Customer" = mainplot + facet_wrap(~ Customer),
    "SubCustomer" = mainplot + facet_wrap(~ SubCustomer),
    "ProductOrServiceArea" = mainplot + facet_wrap(~ ProductOrServiceArea),
    "SimpleArea" = mainplot + facet_wrap(~ SimpleArea),
    "PlatformPortfolio" = mainplot + facet_wrap(~ PlatformPortfolio),
    "Vendor.Size" = mainplot + facet_wrap(~ Vendor.Size)
  )
  
  if(input$use_log){
    mainplot <- mainplot + scale_y_log10()
  }
  
  
  
  return(mainplot)
  })
  
  output$plot <- renderPlot({
    mainplot()
  })

  
  # dynamically add filtering menus based on user input
observeEvent(input$filter,
  {
    new <- input$filter[!(input$filter %in% current$filter)]
    removed <- current$filter[!(current$filter %in% input$filter)]
    cat(removed, "\n")
    
    if(length(new) == 1){
      levels <- levels(full_data[[new]]) 
      
      # add new filter
      insertUI(
        selector = "#placeholder",
        ui = tags$div(
          selectInput(
            inputId = new,
            label = new,
            choices = levels,
            selected = levels,
            multiple = TRUE,
            selectize = FALSE,
            size = 6
          ),
          id = new
        )
      )
      current$filter <- c(current$filter, new)
    }
    
    if(length(removed) > 0){
      for(i in seq_along(removed)){
      removeUI(
       selector = paste0("#", removed[i]) 
      )
      current$filter <- current$filter[current$filter != removed[i]]
      }
    }
    
  })
  
  
  
  
  
})
