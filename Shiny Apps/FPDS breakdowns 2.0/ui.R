################################################################################
# FPDS breakdowns 2.0 app - March 2017
#
# ui.R
################################################################################

library(shiny)
library(tidyverse)

shinyUI(fluidPage(
  
  sidebarLayout(
    sidebarPanel(
      titlePanel("FPDS Charts"),
      wellPanel(
        sliderInput(
          inputId ="year",
          label = "Years",
          min = 2000,
          max = 2016,
          value = c(2010,2015)
        )
      ),
      wellPanel(
        radioButtons(
          inputId = "chart_geom",
          label = NULL,
          choices = c("Bar Chart", "Line Chart"),
          selected = "Line Chart"
        ),
        selectInput(
          inputId = "color_var",
          label = "Color Breakout",
          choices = "None",
          selected = "None",
          width = "100%",
          selectize = TRUE
        ),
        selectInput(
          inputId = "facet_var",
          label = "Facet Breakout",
          choices = "None",
          selected = "None",
          width = "100%",
          selectize = TRUE
        )
      ),
      wellPanel(
        selectInput(
          inputId = "y_var",
          label = "Y Variable",
          choices = "Action.Obligation",
          selected = "Action.Obligation",
          width = "100%",
          selectize = TRUE
        ),
        radioButtons(
          inputId = "y_total_or_share",
          label = NULL,
          choices = c("As Total", "As Share"),
          selected = "As Total"
        )
      )
    ),
    mainPanel(
      width = 8,
      tabsetPanel(
        id = "current_tab",
        tabPanel("Charts",
          plotOutput("plot")
        ),
        tabPanel("Edit Data",
          fluidRow(
            column(
              width = 5,
              tags$div(id = "edit_var_placeholder"),
              textInput(
                inputId = "rename_var_txt",
                label = NULL
              ),
              bsButton(
                inputId = "rename_var_btn",
                label = "Rename",
                style = "info"
              )
            ),
            column(
              width = 6,
              tags$div(id = "edit_value_placeholder"),
              textInput(
                inputId = "rename_value_txt",
                label = NULL
              ),
              fluidRow(
                column(
                  width = 5,
                  bsButton(
                    inputId = "rename_value_btn",
                    label = "Rename",
                    style = "info",
                    block = TRUE
                  ),
                  bsButton(
                    inputId = "color_value_btn",
                    label = "Color",
                    block = TRUE
                  )
                ),
                column(
                  width = 5,
                  bsButton(
                    inputId = "drop_value_btn",
                    label = "Drop",
                    block = TRUE
                  ),
                  bsButton(
                    inputId = "keep_value_btn",
                    label = "Keep",
                    block = TRUE
                  )
                ),
                column(
                  width = 2,
                  bsButton(
                    inputId = "move_up_value_btn",
                    label = "△",
                    block = TRUE
                  ),
                  bsButton(
                    inputId = "move_down_value_btn",
                    label = "▽",
                    block = TRUE
                  )
                )
              )
            )
          )
        )
      )
    )
  )
))