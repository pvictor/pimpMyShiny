



# Fonction calcul des coordonnees -----------------------------------------

coord_smart_cloud <- function(tdm, nbMots = 25, echelle_nuage = c(0.5, 7), mots2suppr = NULL, center = FALSE, SMART = FALSE) {
  #library(FactoMineR)
  
  if (!require("ca"))
    stop("'ca' must be available")
  
  tdm <- tdm[order(rowSums(tdm), decreasing = TRUE), ]
  
  # Poids SMART
  if (SMART) {
    tdm <- as.matrix(as.TermDocumentMatrix(tdm, weighting = weightSMART))
  }
  
  # Prep TDM
  if (!is.null(mots2suppr)) {
    tdm <- tdm[!rownames(tdm) %in% mots2suppr, ]
  }
  tdm <- tdm[1:min(nbMots, nrow(tdm)), ]
  sum_col <- colSums(tdm)
  tdm <- tdm[, sum_col>quantile(sum_col, 1/4)]
  #tdm <- tdm[, colSums(tdm)>0]
  tdm <- tdm[rowSums(tdm) > 0, ]
  echelle <- echelle_nuage #c(0.5, 7)
  taille <- (echelle[2] - echelle[1]) * (rowSums(tdm)/max(rowSums(tdm))) + echelle[1]
  tdm2 <- tdm
  tdm2[tdm2>0] <- 1
  #tdm2 <- tdm2[rowSums(tdm2) > 0, ]
  
  # AFC
  #res.ca <- CA(tdm2, graph=FALSE) # FactoMineR
  res.ca <- ca(obj = tdm2) # ca
  
  #coordonnees <- as.data.frame(res.ca$row$coord) # FactoMineR
  coordonnees <- as.data.frame(res.ca$rowcoord[, seq_len(min(5, ncol(res.ca$rowcoord)))]) # ca
  
  if (center) {
    #center_coord <- kmeans(x = coordonnees[, 1:2], centers = 1)$centers
    center_coord <- colMeans(res.coord$coordonnees[, 1:2])
    #center_dist <- sqrt((center_coord[[1]] - coordonnees[, 1])^2 +
    #                      (center_coord[[2]] - coordonnees[, 2])^2)
    #coordonnees[, 1] <- coordonnees[, 1] - (center_dist)#sqrt(center_dist)
    #coordonnees[, 2] <- coordonnees[, 2] - (center_dist)#sqrt(center_dist)
    center_dist_x <- sqrt((center_coord[[1]] - coordonnees[, 1])^2)
    center_dist_y <- sqrt((center_coord[[2]] - coordonnees[, 2])^2)
    coordonnees[, 1] <- coordonnees[, 1] - sqrt(center_dist_x)#sqrt(center_dist)
    coordonnees[, 2] <- coordonnees[, 2] - sqrt(center_dist_y)#sqrt(center_dist)
  }
  
  names(coordonnees) = gsub(pattern = "\\s", replacement = "", x = names(coordonnees))
  coordonnees$Taille <- taille
  res = list(coordonnees = coordonnees, taille = taille, tdm = tdm)
  return(res)
}



# Fonction pour tracer un nuage -------------------------------------------

draw_smart_cloud <- function(res, couleur = "aucune", nb.clus = 4, raw = FALSE) {
  library(RColorBrewer)
  library(wordcloud)
  coordonnees = res$coordonnees
  taille = res$taille
  tdm = res$tdm
  
  # Couleur
  couleur = match.arg(arg = couleur, choices = c("aucune", "frequence", "kmeans"), several.ok = FALSE)
  if (couleur == "aucune") {
    couleur_mots <- rep(brewer.pal(n = 5, name = "Blues")[4], times = NROW(tdm))
  } else if (couleur == "frequence") {
    echelleColFreq <- c(1, 8)
    colFreq <- (echelleColFreq[2] - echelleColFreq[1]) * (rowSums(tdm)/max(rowSums(tdm))) + echelleColFreq[1]
    couleur_mots <- brewer.pal(n = 8, name = "Set2")[round(colFreq)]
  } else if (couleur == "kmeans") {
    res.kmeans <- kmeans(coordonnees[, 1:2], centers = nb.clus, nstart = 25)
    couleurs_cluster = c("#377EB8", "firebrick3", "forestgreen", "#984EA3", "darkorange2", "saddlebrown", "snow4", "#E6AB02")
    couleur_mots <- couleurs_cluster[as.numeric(res.kmeans$cluster)]
  }
  
  # Nuage
  if (raw) {
    x_fen = 1
    plot.new()
    op <- par("mar")
    par(mar=c(0,0,0,0))
    plot.window(
      c(min(coordonnees[, 1]*2)-x_fen, max(coordonnees[, 1]*2)+x_fen),
      c(min(coordonnees[, 2]*2)-x_fen, max(coordonnees[, 2]*2)+x_fen),
      asp=NA
    )
    text(coordonnees[, 1]*2, coordonnees[, 2]*2, labels=rownames(tdm), cex = taille,
         col = couleur_mots)
    par(mar=op)
  } else {
    res.ca.row.coord2 <- coordonnees * 3
    x_fen = 0
    x_feny1 = 0
    x_feny0 = 0
    plot.new()
    op <- par("mar")
    par(mar=c(0,0,0,0))
    plot.window(
      xlim = c(min(res.ca.row.coord2[, 1]) - x_fen, max(res.ca.row.coord2[, 1]) + x_fen),
      ylim = c(min(res.ca.row.coord2[, 2]) - x_feny0, max(res.ca.row.coord2[, 2]) + x_feny1),
      asp=NA
    )
    set.seed(123)
    layoutMotsAFC <- wordlayout(
      res.ca.row.coord2[, 1], res.ca.row.coord2[, 2], words=rownames(tdm),
      cex = taille, xlim=c(min(res.ca.row.coord2[, 1])-x_fen, max(res.ca.row.coord2[, 1])+x_fen),
      ylim=c(min(res.ca.row.coord2[, 2])-x_feny0, max(res.ca.row.coord2[, 2])+x_feny1)
    )
    text(
      x = layoutMotsAFC[, 1] + 0.5 * layoutMotsAFC[, 3], y = layoutMotsAFC[, 2] + 0.5 * layoutMotsAFC[, 4],
      labels=rownames(layoutMotsAFC), cex = taille, col = couleur_mots
    )
    par(mar=op)
    layoutMotsAFC[, 1] <- layoutMotsAFC[, 1] + 0.5 * layoutMotsAFC[, 3]
    layoutMotsAFC[, 2] <- layoutMotsAFC[, 2] + 0.5 * layoutMotsAFC[, 4]
    layoutMotsAFC <- as.data.frame(layoutMotsAFC)
    return(invisible(layoutMotsAFC))
  }
}

