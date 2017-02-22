################################################################################
# FSRS breakdowns app
################################################################################

library(shiny)

shinyUI(fluidPage(
  
  titlePanel("FSRS Breakdowns"),
  
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId ="year",
        label = "Years",
        min = 2000,
        max = 2016,
        value = c(2010,2015)
      ),
      
      selectInput(
        inputId = "y_var",
        label = "Y Variable",
        choices = c("Amount", "Actions"),
        selected = "Amount",
        width = "100%",
        selectize = FALSE,
        size = 2
      ),
      
      checkboxInput(
        inputID = "use_log",
        label = "Use log scale",
        value = FALSE
      ),
      
      selectInput(
        inputId = "breakout",
        label = "Breakout Variable",
        multiple = FALSE,
        choices = c(
          "None",
          "Customer",
          "SubCustomer",
          "ProductOrServiceArea",
          "Simple",
          "PlatformPortfolio",
          "VendorSize"
          ),
        selected = "None",
        selectize = FALSE,
        size = 7
      ),
      
      selectInput(
        inputId = "filter",
        label = "Filter by Variable(s)",
        multiple = TRUE,
        choices = c(
          "Customer",
          "SubCustomer",
          "ProductOrServiceArea",
          "Simple",
          "PlatformPortfolio",
          "VendorSize"
        ),
        selectize = FALSE,
        size = 6
      )  
    ),
    
    
    mainPanel(
      plotOutput("plot")
    )
  )
))