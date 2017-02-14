################################################################################
# FSRS REPORTING SHINY SERVER.R
################################################################################

library(shiny)
library(tidyverse)
library(magrittr)

shinyServer(function(input, output) {
  
  options(scipen = 99)
   
  #_________________ Read in data __________________#
  data <- read_csv("..//Contract_FSRSinFPDShistory.csv")
  
  data <- data %>%
    filter(fiscal_year != "NULL") %>%
    mutate(fiscal_year = as.numeric(fiscal_year))
  
  data <- data %>%
    mutate(Amount = ifelse(PrimeObligatedAmount == "NULL",
      SubawardAmount,
      PrimeObligatedAmount
      )
  )
  
  data <- data %>%
    mutate(Amount = as.numeric(Amount)) 
  
  data <- data %>%
    mutate(
      Type = ifelse(!SubawardAmount == "NULL", "Subcontracts",
        ifelse(IsInFSRS == 1, "Prime in FSRS", "Uncovered Prime")
      )
    )
  
  data <- data %>%
    mutate(Type = factor(Type))
  
  
  #_________________ Subset data ___________________#
  dataset <- reactive({
    shown <- data %>%
      filter(fiscal_year %in% input$year[1]:input$year[2])
    
    return(shown)
  })
  
  #_________________ Build ggplot __________________#
  plotsettings <- reactive({
    
    shown <- dataset() 
    
    switch(input$yvar, 
      "Amount" = {
        shown$Amount <- shown$Amount / 1000000
        
        p <- ggplot(data = shown,
          aes(x = fiscal_year, y = Amount, color = Type)) +
          geom_line(size = 1) +
          ylab("Amount ($M) deflation?")
      },
      "Actions" = {
        shown <- filter(shown, NumberOfActions != "NULL")
        shown <- mutate(shown, Actions = as.numeric(NumberOfActions))
        shown <- mutate(shown, FSRS =factor(ifelse(IsInFSRS == 1, "yes", "no")))
        p <- ggplot(data = shown,
          aes(x = fiscal_year, y = Actions, color = FSRS)) +
          geom_line(size = 1) +
          ylab("Number of Actions") +
          scale_y_log10()
      },
      "Contracts" = {
        shown <- filter(shown, NumberOfContracts != "NULL")
        shown <- mutate(shown, Contracts = as.numeric(NumberOfContracts))
        shown <- mutate(shown, FSRS =factor(ifelse(IsInFSRS == 1, "yes", "no")))
        p <- ggplot(data = shown,
          aes(x = fiscal_year, y = Contracts, color = FSRS)) +
          geom_line(size = 1) +
          ylab("Number of Contracts") +
          scale_y_log10()
      }
    )
    
    return(p)
  })
  
  #_________________ Render ggplot _________________#
  output$plot <- renderPlot({
    plotsettings()
  })
  
})
