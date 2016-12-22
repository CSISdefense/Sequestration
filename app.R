################################################################################
# Data exploration tool for sequestration - Dec 2016
################################################################################

# load packages
library(shiny)
library(tidyverse)
library(forcats)
library(Cairo)

################################################################################
# 1. Builds the user interface and display areas
################################################################################

ui <- fluidPage(
  fluidRow(
    
    # left column, with buttons and settings
    column(3, align = 'center',
      br(),
      
      sliderInput('yr', "Year Range",
        min = 2000, max = 2015,
        value = c(2000,2015),
        ticks = FALSE,
        step = 1, width = '100%', sep = ""),
      #br(),
      
      selectInput('Breakout',"Displayed Breakout",
        c("SubCustomer", "PlatformPortfolio", "VendorSize", "ServicesCategory",
          "CompetitionClassification", "ClassifyNumberOfOffers"),
        multiple = FALSE,
        selectize = FALSE,
        selected = "SubCustomer",
        width = '100%',
        size = 6),
      
      
      selectInput('ServicesCategory',"Include: ServicesCategory",
        c("ERS", "FRS&C", "ICT", "MED", "PAMS", "Products", "R&D", "NULL"),
        multiple = TRUE,
        selectize = FALSE,
        selected = c(
          "ERS", "FRS&C", "ICT", "MED", "PAMS", "Products", "R&D", "NULL"),
        width = '100%',
        size = 8),
      
      selectInput('PlatformPortfolio',"Include: PlatformPortfolio",
        c("Aircraft and Drones",
          "Electronics and Communications",
          "Facilities and Construction",
          "Land Vehicles",
          "Missile and Space Systems",
          "Ships & Submarines",
          "Weapons and Ammunition",
          "Other Products",
          "Other Services",
          "Other R&D and Knowledge Based",
          "NULL"),
        multiple = TRUE,
        selectize = FALSE,
        selected = c("Aircraft and Drones",
          "Electronics and Communications",
          "Facilities and Construction",
          "Land Vehicles",
          "Missile and Space Systems",
          "Ships & Submarines",
          "Weapons and Ammunition",
          "Other Products",
          "Other Services",
          "Other R&D and Knowledge Based",
          "NULL"),
        width = '100%',
        size = 11),
      
      selectInput('VendorSize',"Include: VendorSize",
        c("Large", "Big 6", "Medium", "Small"),
        multiple = TRUE,
        selectize = FALSE,
        selected = c("Large", "Big 6", "Medium", "Small"),
        width = '100%',
        size = 4),
      
      downloadLink('CSVDownloadBtn', 
        "Download Displayed Data (csv)", class = "butt")
      
      
    ),
    
    
    # right column, with output areas
    column(9, align = 'center',
      #h2(" ", align = "center"),
      
      # large plot area
      div(
        style = "position:relative",
        plotOutput("plot", height = '525px',
          click = clickOpts(id =".plot_click"),
          hover = hoverOpts(id = "plot_hover",
            delay = 30, delayType = "debounce")),
        uiOutput("hover_info")
      )
     
    ) 
    
  )
)
# end of ui section

# start of server section
server <- function(input, output, session){
  
################################################################################
# 2. Reads in and cleans up data initially
# You could pull most of this out into a data processing file if you cared about
# load time
################################################################################ 
data <- read_csv(
  "Vendor_SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer.csv")

# fix a badly read-in variable name
data <- select(data, fiscal_year = contains("iscal_year"), everything())

# ditch pre-2000 data
data <- data %>%
  filter(fiscal_year <= 2000)

# remove null values and fix variable classes  
data <- data %>%
  filter(fiscal_year != "NULL" & SumOfobligatedAmount != "NULL") %>%
  mutate(fiscal_year = as.numeric(fiscal_year)) %>%
  mutate(SubCustomer = factor(SubCustomer)) %>%
  mutate(ServicesCategory = factor(ServicesCategory)) %>%
  mutate(PlatformPortfolio = factor(PlatformPortfolio)) %>%
  mutate(VendorSize = factor(VendorSize)) %>%
  mutate(CompetitionClassification = factor(CompetitionClassification)) %>%
  mutate(ClassifyNumberOfOffers = factor(ClassifyNumberOfOffers)) %>%
  mutate(SumOfobligatedAmount = as.numeric(SumOfobligatedAmount))
  
# ditch pre-2000 data
data <- data %>%
  filter(fiscal_year >= 2000)

# deflation
deflate <- 
    c("2000" = 0.720876,
      "2001" = 0.740141,
      "2002" = 0.752442,
      "2003" = 0.773698,
      "2004" = 0.793958,
      "2005" = 0.821364,
      "2006" = 0.849765,
      "2007" = 0.872196,
      "2008" = 0.902677,
      "2009" = 0.904486,
      "2010" = 0.918687,
      "2011" = 0.940213,
      "2012" = 0.959027,
      "2013" = 0.971599,
      "2014" = 0.986071,
      "2015" = 1
      )

data$SumOfobligatedAmount <- round(data$SumOfobligatedAmount /
    deflate[as.character(data$fiscal_year)])

# drop NULL subcustomer and combine MilitaryHealth into Other DoD
data <- data %>%
  filter(SubCustomer != "NULL")

data$SubCustomer <- fct_recode(data$SubCustomer, `Other DoD` = "MilitaryHealth")
data$SubCustomer <- fct_drop(data$SubCustomer)


# recode VendorSize
data$VendorSize <- fct_recode(data$VendorSize, 
  `Big 6` = "Large: Big 6",
  `Big 6` = "Large: Big 6 JV",
  Medium = "Medium <1B",
  Medium = "Medium >1B")

################################################################################
# 3. Subset data based on user input
################################################################################

dataset <- reactive({
    
    # subset based on year, as requested by user -
    # would work fine filtering by (input > lower limit & input < upper limit)
    # but the findInterval function seems a bit faster
    shown <- filter(FullData, FY >= input$Yr[1] & FY <= input$Yr[2])
    
    # subset based on customer field, as requested by user
    shown <- filter(shown, Customer %in% input$C)
    
    # subset to products / services / R&D for the breakout graph types,
    # and rename the "breakout" variable to "category."
    # Do nothing for the all contracts graph type; it already uses "category"
    switch(input$BreakoutType,
           "Prd" = {
             shown <- filter(shown, Category == "Products")
             shown <- select(shown, -Category)
             names(shown)[names(shown)=="Breakout"] <- "Category"
           },
           "Svc" = {
             shown <- filter(shown, Category == "Services")
             shown <- select(shown, -Category)
             names(shown)[names(shown)=="Breakout"] <- "Category"
           },
           "RnD" = {
             shown <- filter(shown, Category == "R&D")
             shown <- filter(shown, Breakout !=
                               "Operation of Government R&D Facilities")
             shown <- select(shown, -Category)
             names(shown)[names(shown)=="Breakout"] <-
               "Category"
           }
    )
    
    #aggregate obligations amount by FY and breakout category
    shown <- shown %>%
      group_by(FY, Category) %>%
      summarise(Billion = sum(Billion))
    

    

    shown
    
  })



################################################################################
# Do good ggplot go
################################################################################


plotsettings <- function(){
    
    plotdata <- dataset()
    
    # determine y-axis position ("overpos") to display yearly totals
    plotdata$overpos <- plotdata$sumBillion + (0.03 * max(plotdata$sumBillion))
    
    # round yearly totals
    if(max(plotdata$sumBillion) >= 150){
      plotdata$sumBillion <- round(plotdata$sumBillion)
    } else if(max(plotdata$sumBillion >= 5)){
      plotdata$sumBillion <- round(signif(plotdata$sumBillion, 3), 1)
    } else {
      plotdata$sumBillion <- round(signif(plotdata$sumBillion, 3), 2)
    }
    
    
    # build the plot with a long string of ggplot commands
    p <- ggplot(data = plotdata,
                aes(x=FY, y=Billion, fill = Category)) +
      geom_bar(stat = 'identity', width = 0.7,
               size = 0.9) +
      
      # DIIGcolors defined in section 4
      DIIGcolors +
      
      
      # Custom background color / layout       
      theme(panel.border = element_blank(), 
            panel.background = element_rect(fill = "white"),
            plot.background = element_rect(fill = "white", color="white"),
            #plot.background = element_rect(fill="#F9FBFF"), second choice 
            #plot.background = element_rect(fill="#EFF1F5"),
            #plot.background = element_rect(fill="#ECF2F5"),
            panel.grid.major.x = element_blank(), 
            panel.grid.minor.x = element_blank(), 
            panel.grid.major.y = element_line(size=.1, color="lightgray"), 
            panel.grid.minor.y = element_line(size=.1, color="lightgray")) +
            
            scale_x_continuous(breaks = seq(input$Yr[1], input$Yr[2], by = 1),
              labels = function(x) {substring(as.character(x), 3, 4)}) +
      
      # Added title 
      getTitle() + 
      
      # ongraph and pos are for displaying the sub-category totals 
      # (white numbers) and are defined in section 3
      # geom_text(aes(label = ongraph, y = pos), size = 4,
      #           color = 'white', fontface = 'bold', family = 'Arial') +
      
      # sumBillion and overpos are for displaying the yearly totals
      # (grey30 numbers) and are defined earlier in this section
      geom_text(aes(label = sumBillion, y = overpos), size = 5,
                color = '#554449', fontface = 'bold', family = "Arial") +
      theme(plot.title = element_text(
        family = "Arial", color = "#554449", size = 26, face="bold",
        margin=margin(20,0,20,0), hjust = 0.5)) +
      theme(axis.text.x = element_text(
        size = 15, family = "Arial", vjust=7, margin=margin(-10,0,0,0))) +
      theme(axis.text.y = element_text(
        size = 15, family = "Arial", color ="#554449", margin=margin(0,5,0,0))) +
      theme(axis.title.x = element_text(
        size = 16, face = "bold", color = "#554449", family = "Arial",
        margin=margin(15,0,0,60))) +
      theme(axis.title.y = element_text(
        size = 16, face = "bold", color = "#554449", family = "Arial",
        margin=margin(0,15,0,0))) +
      theme(axis.ticks.x = element_blank()) + 
      theme(axis.ticks.y = element_blank()) + 
      theme(legend.text = element_text(size = 15, family = "Arial", color ="#554449")) +
      theme(legend.position = 'bottom') +
      theme(legend.background = element_rect(fill = "white")) + 
      guides(fill=guide_legend(keywidth = 1.5, keyheight = 1.5)) +
      xlab("Fiscal Year") +
      ylab("Constant 2015 $ Billions") +
      labs( caption = "Source: FPDS; CSIS analysis" )
    
    
    
    # settings for the highlight box that appears when clicking the plot
    if(HL$on){
      return(p + annotate("rect", xmin = HL$xmin,
                          xmax = HL$xmax,
                          ymin = HL$ymin,
                          ymax = HL$ymax,
                          #color = "#E2E264",
                          size = .6,
                          fill = "white",
                          alpha = 0.5)
      )    
    }
    

      
    # return the built plot    
    p      
}

output$plot <- renderPlot({
    plotsettings()
  }) 


################################################################################
# Download handling -
# should get the current dataset, rewrite it to wide form with years as the
# new variables, then write it to a csv (or an .xls if possible)
################################################################################  

  output$CSVDownloadBtn <- downloadHandler(
    filename = paste('CSIS.Contract Obligations.', Sys.Date(),'.csv', sep=''),
    content = function(file) {
      writedata <- dataset()
      writedata <- select(writedata, FY, Category, Billion)
      write.csv(writedata, file)
    }
  )

} 

shinyApp(ui= ui, server = server)