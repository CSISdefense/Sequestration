library(shiny)
library(dplyr)
library(ggplot2)
library(scales)

wd <- "K:/Yuanjing/SARs/Shiny_Faceting 6-21"
setwd(wd)

Vendor <- read.csv("Vendor_SubPrime.csv",header = TRUE,sep = ",")
PlatPort <- as.list(levels(Vendor$PlatformPortfolio))
PrimeAmount <- read.csv("PrimeAmount_by_Platform_Portfolio_SubCustomer.csv",header = TRUE,sep = ",")
PrimeAmount$SubCustomer <- as.character(PrimeAmount$SubCustomer)


server <- shinyServer(function(input, output){


# PlatportInput() function is for subsetting the main dataset(which is the aggregated dataset called Vendor) 
# based on user input of Platform Portfolio and it will return a dataframe
  
  PlatportInput <- reactive({
    Vendor$IsSubContract <- as.factor(Vendor$IsSubContract)
    PP1 <- subset(Vendor,PlatformPortfolio %in% input$Plat_Port)
  })
  
  
# Statistics_Annotation() function is for subsetting the dataset "PrimeAmount" to add annotation and creating 
# a list containing all the SubCustomer and the according three numbers as key-value pair and using this list
# to add a column in a dataframe "Prime_Percent".
  
  Statistics_Annotation <- reactive({
    Prime_Percent <- subset(PrimeAmount,PlatformPortfolio %in% input$Plat_Port)
    Prime_Percent_list <- list()
    for(i in 1:nrow(Prime_Percent)){
      key <- Prime_Percent$SubCustomer[i]
      value <- c(prettyNum(Prime_Percent$TotalPrimeObligatedAmount[i],big.mark = ","),
                 prettyNum(Prime_Percent$PrimeObligatedAmount[i],big.mark = ","),
                 100*Prime_Percent$Percent_of_dollars_InFSRS[i])
      Prime_Percent_list[[key]] <- value
    }
    
    for(i in 1:nrow(Prime_Percent)){
      Facet_Total <- paste("Total Prime Obligations: $",prettyNum(Prime_Percent_list[[i]][1],big.mark=","),sep = "")
      Facet_Prime <- paste(Facet_Total, "\nPrime Obligations with SubContract reporting: $",
                           prettyNum(Prime_Percent_list[[i]][2],big.mark = ","),sep = "")
      Facet_Percent <- paste(Facet_Prime,"\nPercent of Prime Obligations with reporting: ",Prime_Percent_list[[i]][3],"%",sep = "")
      Prime_Percent$Annotation_Display[i] <- Facet_Percent
    }
    return(Prime_Percent)
  })

# yearrangeInput() function is for continuing subsetting the output of PlatportInput() and it will return a dataframe
# for creating the faceting ggplot
  
  yearrangeInput <- reactive({
    yearrange <- as.list(input$year_range)
    PP2 <- subset(PlatportInput(),fiscal_year >= yearrange[1] & fiscal_year <= yearrange[2])
  })
  
# Create the facet main plot and add annotation: x-axis will be fiscal year, y-axis will be total amount and every facet will
# contain two separate lines---Sub Contract and Prime Contract; facet is based on SubCustomer Type
  
  output$LinePlot <- renderPlot({

    P1 <- ggplot(yearrangeInput(),aes(x=fiscal_year,y=Total_Amount,color=IsSubContract)) + 
      facet_wrap(~SubCustomer,ncol=3) + scale_x_continuous(breaks=seq(2000,2016,1)) +  
      geom_line() + 
      scale_color_manual(values=c("#CC0033", "#3300CC"),breaks=c(1,0),labels=c("Sub Contract","Prime Contract")) +
      scale_y_continuous(labels = comma) + 
      xlab("Fiscal Year") + ylab("obiligated Amount") + geom_point() + 
      theme(legend.position = "bottom")
    
    P1 + annotate("text", x = min(yearrangeInput()$fiscal_year), y = max(yearrangeInput()$Total_Amount),
                  label = Statistics_Annotation()$Annotation_Display,size=3.5,hjust=0,vjust=1)
    })
})

ui <- shinyUI(fluidPage(
  
  
  titlePanel("DoD Contracting by Platform Portfolio"),
  
  hr(),
  
  sidebarLayout(
    sidebarPanel(
      
      selectInput("Plat_Port",
                  "Choose a platform portfolio",
                  choices = PlatPort
      ),
      hr(),
      
      hr(),
      
      sliderInput("year_range", label = h3("Fiscal Year Range"), min = 2000, 
                  max = 2016, value = c(2012, 2016))
      
    ),
    
    mainPanel(
      plotOutput("LinePlot")
    )
  )
))


shinyApp(ui = ui, server = server)















