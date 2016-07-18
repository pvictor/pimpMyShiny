

library("shiny")

function(input, output, session) {
  
  output$res1 <- renderPrint({
    input$switch1
  })
  output$res2 <- renderPrint({
    input$switch2
  })
  output$res3 <- renderPrint({
    input$switch3
  })
  output$res4 <- renderPrint({
    input$switch4
  })
  output$res5 <- renderPrint({
    input$switch5
  })
  output$res6 <- renderPrint({
    input$switch6
  })
  output$res7 <- renderPrint({
    input$switch7
  })
  output$resbox1 <- renderPrint({
    input$box1
  })
  observeEvent(input$vrai, {
    updateSwitchInput(session = session, inputId = "switchUp", value = TRUE)
  })
  observeEvent(input$faux, {
    updateSwitchInput(session = session, inputId = "switchUp", value = FALSE)
  })
  output$resup1 <- renderPrint({
    input$switchUp
  })
}
