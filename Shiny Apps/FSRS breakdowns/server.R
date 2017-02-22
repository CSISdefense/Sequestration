library(shiny)
library(tidyverse)
library(forcats)
library(magrittr)

shinyServer(function(input, output, session) {

  options(scipen = 99)
  
  # read data  
  full_data <- read_csv("FSRSprocessed.csv")
  
  # set correct data types
  full_data %<>%
    mutate(SubCustomer = factor(SubCustomer)) %>%
    mutate(ProductOrServiceArea = factor(ProductOrServiceArea)) %>%
    mutate(SimpleArea = factor(SimpleArea)) %>%
    mutate(PlatformPortfolio = factor(PlatformPortfolio)) %>%
    mutate(Vendor.Size = factor(Vendor.Size)) %>%
    mutate(IsInFSRS = factor(IsInFSRS))
  
  
  
  
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
  
  shown_data %<>%
    filter(Fiscal.Year >= input$year[1] & Fiscal.Year <= input$year[2])
  
  
  
  
  
  # aggregate to the breakout level
  if(input$breakout == "None"){
    shown_data %<>%
      group_by(Fiscal.Year, IsInFSRS) %>%
      summarize(
        PrimeObligatedAmount = sum(PrimeObligatedAmount),
        PrimeNumberOfActions = sum(PrimeNumberOfActions)
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
  
  mainplot <- mainplot + geom_line()
  
  mainplot <- switch(input$breakout,
    "None" = mainplot,
    "Customer" = mainplot + facet_wrap(~ Customer),
    "SubCustomer" = mainplot + facet_wrap(~ SubCustomer),
    "ProductOrServiceArea" = mainplot + facet_wrap(~ ProductOrServiceArea),
    "SimpleArea" = mainplot + facet_wrap(~ SimpleArea),
    "PlatformPortfolio" = facet_wrap(~ PlatformPortfolio),
    "Vendor.Size" = facet_wrap(~ Vendor.Size)
  )
  
  if(input$use_log) mainplot <- mainplot + scale_y_log10()
  
  return(mainplot)
  })
  
  output$plot <- renderPlot({
    mainplot()
  })

})
