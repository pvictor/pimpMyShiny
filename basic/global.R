


# App meetup R Addicts - basic version ------------------------------------

# Par Fanny Meyer et Victor Perrier - 12/07/2016 --------------------------





# Packages ----------------------------------------------------------------

library("ggplot2")
library("data.table")
library("ggalt")
library("mapproj")



# Data --------------------------------------------------------------------

load("R_datas/rparis_members.RData")
load("R_datas/cumul_members.RData")
# load("R_datas/data_carte_monde.RData")
load("R_datas/carte_monde.RData")
load("R_datas/data_carte_france.RData")
load("R_datas/data_carte_idf.RData")
load("R_datas/raddicts_lonlat.RData")
load("R_datas/tdm_min.RData")
load("R_datas/all_other_meetup.RData")
load("R_datas/rparis_other_meetups.RData")


list_raddicts <- rparis_members$id
names(list_raddicts) <- rparis_members$name


# Funs --------------------------------------------------------------------

source("R_funs/smart_cloud.R")


`%||%` <- function(a, b) {
  if (!is.null(a)) a else b
}


`%ne%` <- function(a, b) {
  if (a != "") a else b
}


