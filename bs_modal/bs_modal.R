

# ------------------------------------------------------------------------ #
#                                                                         
# Descriptif : Bootstrap Modal
#    Details : Permet de faire apparaitre un modal suite a une action du user
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



`%||%` <- function(a, b) {
  if (!is.null(a)) a else b
}

bs_modal <- function(id, title, ..., width = NULL) {
  # By FM & VP 4 dreamRs
  tags$div(
    class="modal bs-modal-lg", id=id, tabindex="-1", role="dialog", 
    tags$div(
      class="modal-dialog modal-lg", role="document",
      style = if (!is.null(width))
        paste0("width: ", shiny::validateCssUnit(width), ";"),
      tags$div(
        class="modal-content",
        tags$div(
          class="modal-header",
          tags$button(
            type="button", class="close", `data-dismiss`="modal", `aria-label`="Close",
            tags$span(
              `aria-hidden`="true", HTML("&times;")
            )
          ),
          tags$h4(
            class="modal-title", title
          )
        ),
        tags$div(
          class="modal-body", list(...)
        ),
        tags$div(
          class="modal-footer",
          tags$button(
            type="button", class="btn btn-default", `data-dismiss`="modal", "Fermer"
          )
        )
      )
    )
  )
}


display_modal_onclick <- function(idTrigger, idModal) {
  tags$script(paste0("$('#", idTrigger, "').click(function() {$('#", idModal, "').modal();});"))
}



