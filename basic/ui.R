


# App meetup R Addicts - basic version ------------------------------------

# Par Fanny Meyer et Victor Perrier - 12/07/2016 --------------------------



library("shinydashboard")
library("shiny")




# header ------------------------------------------------------------------

header <- dashboardHeader(title = "R Addicts - basic")




# sidebar -----------------------------------------------------------------

sidebar <- dashboardSidebar(disable = TRUE)




# body --------------------------------------------------------------------

body <- dashboardBody(
  # Une box pour contenir tous les éléments de l'app
  box(
    width = 12, status = "danger", 
    tags$h1(tags$b("R Addicts à la loupe"), style = "color: firebrick; text-align: center;"),
    tags$style(HTML("#tabsbox > li.active { border-top-color: #f39c12; }")),
    # Layout avec 3 colonnes
    fluidRow(
      column(
        width = 2,
        # Première colonne : 4 valueBox superposées crées côté server
        tags$div(style = "height: 50px;"),
        valueBoxOutput(outputId = "valuebox_inscrit", width = NULL),
        valueBoxOutput(outputId = "valuebox_topflop", width = NULL),
        valueBoxOutput(outputId = "valuebox_geoloc", width = NULL),
        valueBoxOutput(outputId = "valuebox_interet", width = NULL)
      ),
      column(
        width = 7,
        # Deuxième colonne : box avec 4 onglets
        tabBox(
          id = "tabsbox", title = "Les R Addicts ...",
          side = "right", width = NULL, selected = "inscrit", height = "650px",
          tabPanel(
            title = HTML("font quoi"), value = "interet", 
            plotOutput(outputId = "nuageBio", width = "100%", height = "550px", click = "clickNuage"),
            tags$em("Cliquez sur un mot pour mettre à jour la box à gauche.")
          ),
          tabPanel(
            title = "sont où", value = "geoloc", 
            plotOutput(outputId = "carte", width = "100%", height = "500px"),
            radioButtons(
              inputId = "nivGeo", label = "Niveau géographique : ", 
              choices = c("Monde", "France", "Ile-de-France"), inline = TRUE
            ),
            tags$em("Sélectionnez un R Addicts à droite pour le placer sur la carte.")
          ),    
          tabPanel(
            title = "kiffent quoi", value = "topflop", 
            radioButtons(
              inputId = "bouton_top_flop", label = NULL,
              choices = c("Un peu", "Beaucoup", "Passionnement", "A la folie"),
              inline = TRUE, selected = "A la folie"
            ),
            plotOutput(outputId = "top_flop", width = "100%", height = "550px")
          ),
          tabPanel(
            title = "dans le temps", value = "inscrit", 
            plotOutput(
              outputId = "graph_inscrit", width = "100%", height = "550px", 
              brush = brushOpts(id = "inscrit_brush", direction = "x", resetOnNew = FALSE)
            ),
            tags$em("Sélectionnez une zone sur le graphique.")
          )
        )
      ),
      column(
        width = 3,
        # Troisième colonne : module recherche personne
        box(
          title = "C'est qui ?", status = "danger", solidHeader = TRUE, width = NULL, height = "600px",
          selectizeInput(
            inputId = "raddicts", label = NULL, choices = NULL,
            options = list(
              placeholder = 'Rechercher un R Addicts', 
              onInitialize = I('function() { this.setValue(""); }')
            )
          ),
          uiOutput(outputId = "carte_identite")
        )
      )
    )
  )
)




# Page --------------------------------------------------------------------

dashboardPage(header = header, sidebar = sidebar, body = body, skin = "red")
