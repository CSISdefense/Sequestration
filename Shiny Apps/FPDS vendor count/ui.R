################################################################################
# Vendor count app - March 2017
#
# ui.R
################################################################################

library(shiny)
library(shinyBS)
library(tidyverse)

shinyUI(fluidPage(
  
  sidebarLayout(
    sidebarPanel(
      titlePanel("FPDS Vendor Count"),
      wellPanel(
        sliderInput(
          inputId ="year",
          label = "Years",
          min = 2000,
          max = 2016,
          value = c(2000,2016)
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
          label = "Breakout",
          choices = "None",
          selected = "None",
          width = "100%",
          selectize = TRUE
        ),
        selectInput(
          inputId = "facet_var",
          label = "Facet",
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
          choices = "EntityCount",
          selected = "EntityCount",
          width = "100%",
          selectize = TRUE
        ),
        radioButtons(
          inputId = "y_total_or_share",
          label = NULL,
          choices = c("As Total", "As Share"),
          selected = "As Total"
        ),
        radioButtons(
          inputId = "agg_level",
          label = "Aggregation",
          choices = c("SubCustomer", "PlatformPortfolio", "Both (Double Counts)"),
          selected = "PlatformPortfolio"
        )
      )
    ),
    mainPanel(
      width = 8,
      tabsetPanel(
        id = "current_tab",
        tabPanel("Charts",
          plotOutput("plot"),
          br(),
          br(),
          downloadButton(
            outputId = "download_plot",
            label = "Download Plotted Data"
          )
        ),
        tabPanel("Edit Data",
          fluidRow(
            column(
              width = 6,
              bsButton(
                inputId = "apply_changes_btn",
                label = "Apply Data Changes",
                style = "warning",
                size = "large",
                block = TRUE
              ),
              bsButton(
                inputId = "discard_btn",
                label = "Discard Data Changes",
                style = "primary",
                block = TRUE
              ),
              br(),
              tags$div(id = "edit_var_placeholder"),
              textInput(
                inputId = "rename_var_txt",
                label = NULL
              ),
              bsButton(
                inputId = "rename_var_btn",
                label = "Rename",
                style = "info"
              ),
              br(),
              br(),
              downloadButton(
                outputId = "download_current",
                label = "Download this view"
              )
            ),
            column(
              width = 6,
              bsButton(
                inputId = "restore_btn",
                label = "Restore Original Data",
                style = "success",
                size = "default",
                block = TRUE
              ),
              br(),
              br(),
              br(),
              br(),
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