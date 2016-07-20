
# ------------------------------------------------------------------------ #
#                                                                         
# Descriptif : Membres meetup rparis
#
#                                                                         
# Auteur : Fanny MEYER et Victor PERRIER 
# 
# Date creation : 03/06/2016
# Date modification : 03/06/2016
# 
# Version 0.1
# 
# ------------------------------------------------------------------------ #





# Packages ----------------------------------------------------------------

library("httr")




# Connexion API -----------------------------------------------------------

# Credentials
Client_id <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
Client_secret <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
Access_URL <- "https://secure.meetup.com/oauth2/access"
Authorize_URL <- "https://secure.meetup.com/oauth2/authorize"
Request_token_URL <- "https://secure.meetup.com/oauth2/access"

api_key <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Con
mon_app <- oauth_app(appname = "meetup", key = Client_id, secret = Client_secret)
ep <- oauth_endpoint(authorize = Authorize_URL, access = Access_URL, request = Request_token_URL)
meetup_tok <- oauth2.0_token(
  endpoint = ep, app = mon_app, 
  scope = "basic"
)

meetup_tok$refresh()





# Requete -----------------------------------------------------------------

meetup_json <- GET(
  url = "https://api.meetup.com/2/members/",
  query = list(
    "access_token" = meetup_tok$credentials$access_token,
    "group_urlname" = "rparis",
    "only" = "name,joined,id,lat,lon,visited,bio,city,topics,photo"
  )
)


# Parse result ------------------------------------------------------------

members_raw <- httr::content(meetup_json, type = "application/json; charset=utf-8")

`%||%` <- function(a, b) {
  if (!is.null(a)) a else b
}

parse_members <- function(x) {
  x$topics <- paste(sapply(X = x$topics, FUN = `[[`, "name"), collapse = ";")
  x$bio <- x$bio %||% ""
  if (!is.null(x$photo)) {
    x$photo_link <- x$photo$photo_link %||% ""
    x$photo_highres_link <- x$photo$highres_link %||% ""
    x$photo <- NULL
  } else {
    x$photo_link <- ""
    x$photo_highres_link <- ""
  }
  res <- as.data.frame(x, stringsAsFactors = FALSE)
  res[, c("id", "name", "joined", "city", "topics", "visited", "bio", 
          "lon", "lat", "photo_link", "photo_highres_link")]
}


# data.frame
rparis_members <- do.call("rbind", lapply(members_raw$results, parse_members))

# Et voila
str(rparis_members)
head(rparis_members)

