################################################################################
# FSRS REPORTING SHINY UI.R
################################################################################

library(shiny)

shinyUI(fluidPage(
  
  titlePanel("FSRS REPORTING"),
  
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId ="year",
        label = "Years",
        min = 1987,
        max = 2016,
        value = c(2000,2016)
      ),
      selectInput(
        inputId = "yvar",
        label = "Variable",
        choices = c("Amount","Actions", "Contracts"),
        selected = "Amount",
        width = "100%",
        selectize = FALSE,
        size = 3
      ),
      selectInput(
        inputId = "customer",
        label = "Customer",
        multiple = TRUE,
        choices = c(
          "Defense", "NASA", "DHS", "Energy",
          "GSA", "HHS", "Other Agencies", "State and IAP", "NULL"
        ),
        selected = c(
          "Defense", "NASA", "DHS", "Energy",
          "GSA", "HHS", "Other Agencies", "State and IAP", "NULL"
        ),
        selectize = FALSE,
        size = 9
      )
    ),
    
    
    mainPanel(
       plotOutput("plot")
    )
  )
))
