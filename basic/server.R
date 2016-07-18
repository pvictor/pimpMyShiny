


# App meetup R Addicts - basic version ------------------------------------

# Par Fanny Meyer et Victor Perrier - 12/07/2016 --------------------------



library("shinydashboard")
library("shiny")

function(input, output, session) {
  
  raddicts_joined <- reactiveValues(x = rep(TRUE, length(list_raddicts)))
  observeEvent(ranges$x, {
    if (!is.null(ranges$x)) {
      ind <- rparis_members$joined >= ranges$x[1] & rparis_members$joined <= ranges$x[2]
      raddicts_joined$x <- ind 
    } else {
      raddicts_joined$x <- rep(TRUE, length(list_raddicts))
    }
  }, ignoreNULL = FALSE)
  
  raddicts_geo <- reactiveValues(x = rep(TRUE, length(list_raddicts)))
  observeEvent(input$nivGeo, {
    if (input$nivGeo == "France") {
      ind <- rparis_members$id %in% raddicts_france$id
      raddicts_geo$x <- ind
    } else if (input$nivGeo == "Ile-de-France") {
      ind <- rparis_members$id %in% raddicts_idf$id
      raddicts_geo$x <- ind
    } else {
      raddicts_geo$x <- rep(TRUE, length(list_raddicts))
    }
  })
  
  raddicts_topflop <- reactiveValues(x = rep(TRUE, length(list_raddicts)))
  observeEvent(input$bouton_top_flop, {
    other_meetup_unique <- all_meetup_react()
    index <- switch(
      input$bouton_top_flop,
      "Un peu" = 102:107, "Beaucoup" = 61:66, "Passionnement" = 31:36, "A la folie" = 1:6
    )
    other_meetup_unique <- other_meetup_unique[index]
    meetups_filter <- paste(other_meetup_unique$all_other_meetup, collapse = "|")
    raddicts_filter <- rparis_other_meetups[other_meetups %like% meetups_filter]
    ind <- rparis_members$id %in% raddicts_filter$id
    raddicts_topflop$x <- ind
  })
  
  observe({
    updateSelectizeInput(
      session = session, inputId = "raddicts",
      choices = list_raddicts[raddicts_joined$x & raddicts_geo$x & raddicts_topflop$x],
      server = TRUE
    )
  })
  
  
  # valueBox ----
  
  output$valuebox_inscrit <- renderValueBox({
    if (!is.null(ranges$x)) {
      nb_inscrit <- cumul_members[date >= ranges$x[1] & date <= ranges$x[2], max(cumul) - min(cumul)]
    } else {
      nb_inscrit <- max(cumul_members$cumul)
    }
    col <- switch(input$tabsbox, "inscrit" = "yellow", "red")
    valueBox(value = nb_inscrit, subtitle = tags$p("inscrits", style = "font-size: 200%;"), color = col, icon = icon("users"), width = NULL)
  })
  
  output$valuebox_topflop <- renderValueBox({
    col <- switch(input$tabsbox, "topflop" = "yellow", "red")
    other_meetup_unique <- all_meetup_react()
    index <- switch(
      input$bouton_top_flop,
      "Un peu" = 102, "Beaucoup" = 61, "Passionnement" = 31, "A la folie" = 2
    )
    valueBox(value = other_meetup_unique[index,list(Freq)], 
             subtitle = tags$p(other_meetup_unique[index,list(all_other_meetup)], style = "font-size: 150%;"), color = col, icon = icon("heart"), width = NULL)
  })
  
  output$valuebox_geoloc <- renderValueBox({
    if (input$nivGeo == "Monde") {
      val <- round(nrow(raddicts_france) / nrow(rparis_members) * 100)
      lab <- "en France"
    } else if (input$nivGeo == "France") {
      val <- round(nrow(raddicts_idf) / nrow(rparis_members) * 100)
      lab <- "en Ile-de-France"
    } else if (input$nivGeo == "Ile-de-France") {
      val <- round(sum(raddicts_lonlat$in_paris) / nrow(rparis_members) * 100)
      lab <- "à Paris"
    }
    col <- switch(input$tabsbox, "geoloc" = "yellow", "red")
    valueBox(value = paste0(val, "%"), subtitle = tags$p(lab, style = "font-size: 200%;"), color = col, icon = icon("globe"), width = NULL)
  })
  
  output$valuebox_interet <- renderValueBox({
    if (length(mot_click$x) > 0) {
      mot <- mot_click$x
    } else {
      mot <- sample(rownames(tdm_min), 1)
    }
    val <- round(sum(tdm_min[mot, ]) / sum(rparis_members$bio != "") * 100)
    col <- switch(input$tabsbox, "interet" = "yellow", "red")
    valueBox(value = paste0(val, "%"), subtitle = tags$p(mot, style = "font-size: 200%;"), color = col, icon = icon("binoculars"), width = NULL)
  })
  
  
  
  # --- Graph des arrivées des Raddict
  
  output$graph_inscrit <- renderPlot({
    p <- ggplot(data = cumul_members, mapping = aes(x = date, y = cumul)) +
      geom_line(size = 1.2, colour = "firebrick") + 
      geom_point(data = cumul_members[!is.na(name)], size = 3, col = "grey40") +
      geom_text(data = cumul_members[!is.na(name) & date >= as.Date("2014-01-01")], aes(label = name), hjust = 1, nudge_y = 5, nudge_x = -25, col = "grey40", size = 4) +
      geom_text(data = cumul_members[!is.na(name) & date < as.Date("2014-01-01")], aes(label = name), hjust = 0, nudge_y = -5, nudge_x = 25, col = "grey40") +
      theme_minimal() + xlab(NULL) + ylab("Nombre de R Addicts (en humains)") +
      theme(
        axis.title.y = element_text(margin = margin(0, 20, 0, 0), colour = "grey40"),
        axis.title.x = element_text(colour = "grey40"), axis.text = element_text(colour = "grey40")
      ) #+
      #coord_cartesian(xlim = ranges$x)
    if (input$raddicts != "") {
      raddict <- input$raddicts
      rparis_members <- rparis_members[rparis_members$id == raddict, ]
      p <- p + geom_point(data = cumul_members[date == rparis_members$joined], colour = "firebrick", size = 8)
    }
    return(p)
  })
  
  # Clic sur le graph 
  ranges <- reactiveValues(x = NULL)
  observeEvent(input$inscrit_brush, {
    brush <- input$inscrit_brush
    if (!is.null(brush)) {
      ranges$x <- as.Date(c(brush$xmin, brush$xmax), origin = "1970-01-01")
    } else {
      ranges$x <- NULL
    }
  }, ignoreNULL = FALSE)
  
  
  # Carte identité ----
  
  output$carte_identite <- renderUI({
    if (input$raddicts != "") {
      raddict <- input$raddicts
      rparis_members <- rparis_members[rparis_members$id == raddict, ]
      topics <- unlist(strsplit(x = rparis_members$topics, split = ";"))
      if (length(topics) > 3) {
        topics <- sample(topics, 3)
        topics <- paste0(paste(topics, collapse = ", "), ",...")
      } else if (length(topics) < 1) {
        topics <- "mystère..."
      } else {
        topics <- paste0(paste(topics, collapse = ", "), ",...")
      }
      tagList(
        tags$div(
          style = "text-align: center;",
          tags$img(src = (rparis_members$photo_highres_link %ne% rparis_members$photo_link) %ne% "Raddict.jpg", 
                   style = "max-height: 350px; max-width: 100%;"), #height = "400px"
          br(), br(),
          tags$p("Nom : ", tags$b(rparis_members$name)),
          tags$p("Inscrit le : ", tags$b(format(rparis_members$joined, "%d/%m/%Y"))),
          tags$p("Centre(s) d'intérêt : ", topics)
        )
      )
    } else {
      dispo <- list_raddicts[raddicts_joined$x & raddicts_geo$x & raddicts_topflop$x]
      # Date inscription
      if (!is.null(ranges$x)) {
        filtre_insription <- format(ranges$x, "%d/%m/%Y")
      } else {
        filtre_insription <- format(range(rparis_members$joined), "%d/%m/%Y")
      }
      filtre_insription <- paste(filtre_insription, collapse = " au ")
      tagList(
        tags$div(
          style = "text-align: center;",
          tags$img(src = "Raddict.jpg", 
                   style = "max-height: 300px; max-width: 100%;"), #height = "400px"
          br(), br(),
          tags$p("Voir un R Addicts parmi :"),
          tags$h2(tags$b(length(dispo)), style = "color: firebrick;"),
          tags$p("Date d'inscription : ", filtre_insription),
          tags$p("Zone géographique : ", input$nivGeo)
        )
      )
    }
  })
  
  
  
  # TOP/FLOP ----
  
  all_meetup_react <- reactive({
    all_other_meetup[, alea := sample.int(.N)]
    all_other_meetup <- all_other_meetup[order(rang,alea)]
    other_meetup_unique <- unique(all_other_meetup, by = "rang")
  })
  
  output$top_flop <- renderPlot({
    other_meetup_unique <- all_meetup_react()
    index <- switch(
      input$bouton_top_flop,
      "Un peu" = 102:107, "Beaucoup" = 61:66, "Passionnement" = 31:36, "A la folie" = 1:6
    )
    top <- ggplot(data = other_meetup_unique[index]) + 
      aes(y = factor(all_other_meetup, levels = rev(all_other_meetup)), x = Freq) +
      geom_lollipop(point.colour="firebrick", point.size=5, horizontal=TRUE) + 
      theme_minimal() + xlab(NULL) + ylab(NULL) +
      theme(
        axis.title.y = element_text(margin = margin(0, 20, 0, 0), colour = "grey40"),
        axis.title.x = element_text(colour = "grey40"), axis.text = element_text(colour = "grey40"),
        axis.text.y = element_text(size = 15, colour = "grey40")
      )
    return(top)
    
  })
  
  
  
  
  
  # Cartes ----
  
  output$carte <- renderPlot({
    if (input$nivGeo == "Monde") {
      p <- carte_monde
      if (input$raddicts != "") {
        raddict <- input$raddicts
        ind <- which(rparis_members$id == raddict)
        p <- p + geom_point(data = raddicts_loc[ind, ], mapping = aes(x = long, y = lat), col = "firebrick", size = 4)
      }
    } else if (input$nivGeo == "France") {
      p <- ggplot() + 
        geom_polygon(data = france_reg_df, mapping = aes(x = long, y = lat, group = group), fill = "grey20", color = "grey90") + 
        # geom_path(data = france_reg_df, mapping = aes(x = long, y = lat, group = group), color = "grey90") + 
        geom_point(data = raddicts_france, mapping = aes(x = lon, y = lat), col = "#f39c12", size = 4) + 
        theme_void() + coord_map(projection = "mercator")
      if (input$raddicts != "") {
        raddict <- input$raddicts
        ind <- which(raddicts_france$id == raddict)
        p <- p + geom_point(data = raddicts_france[ind, ], mapping = aes(x = lon, y = lat), col = "firebrick", size = 4)
      }
    } else if (input$nivGeo == "Ile-de-France") {
      p <- ggplot() + 
        geom_polygon(data = idf_df, mapping = aes(x = long, y = lat, group = group), fill = "grey20") + 
        geom_path(data = idf_df, mapping = aes(x = long, y = lat, group = group), color = "grey90") + 
        geom_point(data = raddicts_idf, mapping = aes(x = lon, y = lat), col = "#f39c12", size = 4) + 
        theme_void() + coord_map(projection = "mercator")
      if (input$raddicts != "") {
        raddict <- input$raddicts
        ind <- which(raddicts_idf$id == raddict)
        p <- p + geom_point(data = raddicts_idf[ind, ], mapping = aes(x = lon, y = lat), col = "firebrick", size = 4)
      }
    }
    print(p)
  })
  
  
  # Nuage bio ----
  
  output$nuageBio <- renderPlot({
    coord_cloud <- coord_smart_cloud(tdm = tdm_min, nbMots = 100, echelle_nuage = c(0.8, 6))
    coord_nuage <<- draw_smart_cloud(coord_cloud, couleur = "kmeans")
  })
  
  mot_click <- reactiveValues(x = character(0))
  observeEvent(input$clickNuage, {
    mot <- nearPoints(
      df = coord_nuage, coordinfo = input$clickNuage, xvar = "x", yvar = "y", threshold = 50, maxpoints = 1
    )
    mot_click$x <- rownames(mot)
  })

}
