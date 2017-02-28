################################################################################
# FSRS breakdowns app
################################################################################

library(shiny)

shinyUI(fluidPage(
  
  fluidRow(
    
    column(4,
      titlePanel("FSRS breakouts"),
      wellPanel(
        sliderInput(
          inputId ="year",
          label = "Years",
          min = 2000,
          max = 2016,
          value = c(2010,2015)
        )
      )  
    ),
    
    column(4,
      wellPanel(
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
          inputId = "use_log",
          label = "Use log scale",
          value = FALSE
        ),
        checkboxInput(
          inputId = "use_share",
          label = "Show as share",
          value = TRUE
        )
      )
    ),
    
    column(4,
      wellPanel(
        selectInput(
          inputId = "breakout",
          label = "Breakout Variable",
          multiple = FALSE,
          choices = c(
            "None",
            "Customer",
            "SubCustomer",
            "ProductOrServiceArea",
            "SimpleArea",
            "PlatformPortfolio",
            "Vendor.Size"
            ),
          selected = "None",
          selectize = FALSE,
          size = 7
        )
      )
    )  
  ),
  
  fluidRow(
    
    column(4,
      selectInput(
        inputId = "filter",
        label = "Filter by Variable(s)",
        multiple = TRUE,
        choices = c(
          "Customer",
          "SubCustomer",
          "ProductOrServiceArea",
          "SimpleArea",
          "PlatformPortfolio",
          "Vendor.Size"
          ),
        selectize = FALSE,
        size = 6
      ),
      tags$div(id = "placeholder")
    ),
  
    column(8,
      plotOutput("plot")
    )
  )
))