

# ------------------------------------------------------------------------ #
#                                                                         
# Descriptif :Exemple d'utilisation d'un modal
#
#                                                                         
# Auteurs : Fanny MEYER (fannymeyer2@gmail.com) et Victor PERRIER (perrier.victor@gmail.com)
#           https://github.com/pvictor/pimpMyShiny
# 
# Date creation : 12/07/2016
# Date modification : 12/07/2016
# 
# Version 1.0
# 
# ------------------------------------------------------------------------ #


library("shiny")
source("bs_modal.R")


# ui ----------------------------------------------------------------------

ui <- fluidPage(
  tags$h1("Utilisation de la fonction", tags$code("bs_modal", style = "color: steelblue"), style = "color: steelblue"),
  tags$h6("Reprise de l'exemple : ", tags$a(href = "http://shiny.rstudio.com/gallery/kmeans-example.html", "http://shiny.rstudio.com/gallery/kmeans-example.html"), style = "color: steelblue"),
  tags$h6("Pour afficher le modal, cliquez sur le bouton ou sur le graphique.", style = "color: steelblue"),
  tags$h6("Le code sur ", tags$a("github", href = "https://github.com/pvictor/pimpMyShiny"), style = "color: steelblue"),
  br(),
  sidebarPanel(
    selectInput('xcol', 'X Variable', names(iris)),
    selectInput('ycol', 'Y Variable', names(iris),
                selected=names(iris)[[2]]),
    numericInput('clusters', 'Cluster count', 3,
                 min = 1, max = 9),
    actionButton(inputId = "bouton", label = "See data"),
    display_modal_onclick(idTrigger = "bouton", idModal = "monModal")
  ),
  mainPanel(
    plotOutput('plot1'),
    display_modal_onclick(idTrigger = "plot1", idModal = "monModal")
  ),
  bs_modal(
    id = "monModal",
    title = tags$h2("Data", style = "color: steelblue;"), 
    dataTableOutput(outputId = "data")
  )
)



# server ------------------------------------------------------------------

palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
          "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))

server <- function(input, output) {
  
  # server from : https://github.com/rstudio/shiny-examples/tree/master/050-kmeans-example
  
  selectedData <- reactive({
    iris[, c(input$xcol, input$ycol)]
  })
  
  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })
  
  output$plot1 <- renderPlot({
    par(mar = c(5.1, 4.1, 0, 1))
    plot(selectedData(),
         col = clusters()$cluster,
         pch = 20, cex = 3)
    points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
  })
  
  output$data <- renderDataTable({
    dat <- selectedData()
    dat$cluster <- clusters()$cluster
    return(dat)
  })
  
}



# app ---------------------------------------------------------------------

shinyApp(ui = ui, server = server)

