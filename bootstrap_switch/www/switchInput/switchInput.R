


# Fun switchInput ---------------------------------------------------------

switchInput <- function(inputId, label = NULL, value = FALSE, onLabel = 'ON', offLabel = 'OFF',
                        onStatus = NULL, offStatus = NULL, size = "default") {
  size <- match.arg(arg = size, choices = c('default', 'mini', 'small', 'normal', 'large'))
  switchProps <- shiny:::dropNulls(
    list(
      id = inputId, type = "checkbox", class = "switchInput", `data-input-id` = inputId,
      `data-on-text` = onLabel, `data-off-text` = offLabel, `data-label-text` = label,
      `data-on-color` = onStatus, `data-off-color` = offStatus, #`data-state` = value, 
      `data-size` = if (size == "default") "" else size
    )
  )
  switchProps <- lapply(switchProps, function(x) {
    if (identical(x, TRUE)) 
      "true"
    else if (identical(x, FALSE)) 
      "false"
    else x
  })
  inputTag <- do.call(tags$input, switchProps)
  if (!is.null(value) && value)
    inputTag$attribs$checked <- "checked"
  tagList(
    singleton(
      tags$head(
        tags$link(href="switchInput/css/bootstrap-switch.min.css", rel="stylesheet"),
        tags$script(src = "switchInput/js/bootstrap-switch.min.js"),
        tags$script(src = "switchInput/switch-bindings.js")
      )
    ),
    tags$div(
      style = "margin: 3px;",
      inputTag,
      tags$script(paste0('$("#', inputId, '").bootstrapSwitch();'))
    )
  )
}



# Update switchInput ------------------------------------------------------

updateSwitchInput <- function(session, inputId, value = NULL) {
  message <- shiny:::dropNulls(list(value = value))
  session$sendInputMessage(inputId, message)
}


