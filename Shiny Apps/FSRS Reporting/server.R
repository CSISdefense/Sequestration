################################################################################
# FSRS REPORTING SHINY SERVER.R
# 
# Data: 
################################################################################

library(shiny)
library(tidyverse)
library(magrittr)

shinyServer(function(input, output) {
  
  options(scipen = 99)
   
  #_________________ Read in data __________________#
  data <- read_csv("Contract.FSRSinFPDShistoryCustomer.csv")
  
  names(data)[1] <- "fiscal_year"
  
  data <- gather(data, "Presence", "Amount",
    PrimeObligatedAmount, SubawardAmount)
    
  data <- arrange(data, fiscal_year, Customer)
  
  data <- filter(data, IsInFSRS == 1 | Presence == "PrimeObligatedAmount")
  
  
  # set Presence variable to contain our relevant categories
  data <- data %>%
    mutate(Presence =
      ifelse(Presence == "SubawardAmount",
        "Sub in FSRS",
        ifelse(IsInFSRS == 1,
          "Prime in FSRS",
          "Prime outside FSRS"
        )
      )
    )
  
  # drop before 1990
  data <- filter(data, fiscal_year >= 1990)
  
  # set correct data types
  data <- data %>%
    mutate(Amount = as.numeric(Amount)) %>%
    mutate(Customer = as.factor(Customer)) %>%
    mutate(Presence = as.factor(Presence)) %>%
    mutate(NumberOfActions = as.numeric(NumberOfActions))
  
  
  
  
  #_________________ Subset data ___________________#
  dataset <- reactive({
    shown <- data %>%
      filter(fiscal_year %in% input$year[1]:input$year[2])
    
    shown <- filter(shown, Customer %in% input$customer)
    
    if(input$yvar != "Amount"){
      shown <- filter(shown, Presence != "Sub in FSRS")
    }
    
    shown <- shown %>%
      group_by(fiscal_year, Presence) %>%
      summarize(
        Amount = sum(Amount),
        NumberOfActions = sum(NumberOfActions),
        NumberOfContracts = sum(NumberOfContracts)
        )
    
    return(shown)
  })
  
  #_________________ Build ggplot __________________#
  plotsettings <- reactive({
    
    shown <- dataset() 
    
    switch(input$yvar, 
      "Amount" = {
        shown$Amount <- shown$Amount / 1000000
        
        p <- ggplot(data = shown,
          aes(x = fiscal_year, y = Amount, color = Presence)) +
          geom_line(size = 1) +
          ylab("Amount ($M) deflation?")
      },
      "Actions" = {
        # shown <- filter(shown, Presence != "Sub in FSRS")
        p <- ggplot(data = shown,
          aes(x = fiscal_year, y = NumberOfActions, color = Presence)) +
          geom_line(size = 1) +
          ylab("Number of Actions (log scale)") +
          scale_y_log10()
      },
      "Contracts" = {
        # shown <- filter(shown, Presence != "Sub in FSRS")
        p <- ggplot(data = shown,
          aes(x = fiscal_year, y = NumberOfContracts, color = Presence)) +
          geom_line(size = 1) +
          ylab("Number of Contracts (log scale)") +
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
