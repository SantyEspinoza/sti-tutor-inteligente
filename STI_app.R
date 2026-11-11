library(shiny)
library(ellmer)

# Leer historial
historial_file <- "C:/STI/historial.csv"
if(!file.exists(historial_file)){
  write.csv(data.frame(fecha = character(), 
                       tema = character(), 
                       edad = numeric(),
                       estilo = character(),
                       entendio = character()), 
            historial_file, row.names = FALSE)
}

ui <- fluidPage(
  titlePanel("STI para docentes"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("topic", "Tema:", "tablas en Word"),
      numericInput("age", "Edad:", 8, min = 5, max = 12),
      selectInput("style", "Estilo de aprendizaje:",
                  choices = c("Visual" = "visual",
                              "Práctico" = "practico",
                              "Teórico" = "teorico")),
      actionButton("generate", "Generar clase"),
      br(),
      uiOutput("pregunta_entendiste"),
      actionButton("si", "Sí, entendí"), 
      actionButton("no", "No, explícame de nuevo"), 
      uiOutput("zona_evaluacion") 
    ),
    
    mainPanel(
      htmlOutput("result")
    )
  )
)

server <- function(input, output, session) {
  historial_file <- "C:/STI/historial.csv"
  
  # Función para decidir tema automáticamente
  decidir_tema <- function(historial) {
    if(nrow(historial) == 0) return("tablas en Word")  # primer tema por defecto
    
    conteo <- table(trimws(historial$tema))
    
    # Tema visto solo 1 vez → reforzar
    vistos_una <- names(conteo[conteo == 1])
    if(length(vistos_una) > 0) {
      return(vistos_una[1])
    }
    
    # Todos vistos 2+ veces → tema nuevo relacionado
    return("temas avanzados")
  }
  # Función para decidir el estilo de aprendizaje
  decidir_estilo <- function(historial) {
    # Si el historial está vacío o no hay "si", devolvemos visual por defecto
    if(nrow(historial) == 0) return("visual")
    
    # Filtrar solo las clases donde el estudiante SÍ entendió
    exitosos <- historial[historial$entendio == "si", ]
    
    # Si aún no hay ningún "si", devolvemos visual
    if(nrow(exitosos) == 0) return("visual")
    
    # Contar cuál es el estilo más repetido en los exitosos
    conteo_estilos <- table(exitosos$estilo)
    
    # Devolver el nombre del estilo con más éxitos
    return(names(conteo_estilos)[which.max(conteo_estilos)])
  }
  # 2. El observador que ejecuta la función al iniciar
  observe({
    historial_inicial <- read.csv(historial_file)
    
    # Actualizar tema
    tema_sugerido <- decidir_tema(historial_inicial)
    updateTextInput(session, "topic", value = tema_sugerido)
    
    # Actualizar estilo
    estilo_sugerido <- decidir_estilo(historial_inicial)
    updateSelectInput(session, "style", selected = estilo_sugerido)
  })
  
  # 3. Luego el observeEvent
  observeEvent(input$generate, {
    api_key <- Sys.getenv("OPENAI_API_KEY") 
    
    # Detectar historial
    historial <- read.csv(historial_file)
    repeticiones <- sum(historial$tema == input$topic)
    
    prompt_extra <- if(repeticiones == 0) {
      "Primera vez. Explica desde cero."
    } else if(repeticiones == 1) {
      "Segunda vez. Refuerza conceptos clave."
    } else {
      "Tercera o más. Profundiza y agrega evaluación."
    }
    
    print(paste("Repeticiones:", repeticiones))
    print(prompt_extra)
    
    tema_actual <- gsub(" ", "_", input$topic)
    
    # Generar respuesta
    chat <- chat_openai(model = "gpt-4.1-mini")
    
    response <- chat$chat(
      paste(
        "Eres un docente experto en primaria.",
        prompt_extra,
        "\nTema:", input$topic,
        "\nEdad:", input$age,
        "\nEstilo de aprendizaje:", input$style,
        "\n\nGenera:",
        "\n[EXPLICACIÓN]",
        "\n[ACTIVIDAD]",
        "\n[EJERCICIO]",
        "\n[CONTROL DE GRUPO]",
        "\n\nAl final, incluye una pregunta corta para evaluar si el estudiante entendió el tema."
      )
    )
    
    texto <- response
    
    # Guardar en historial
    nueva_fila <- data.frame(fecha = as.character(Sys.time()), 
                             tema = input$topic, 
                             edad = input$age,
                             estilo = input$style,
                             entendio = "pendiente")
    write.table(nueva_fila, historial_file, append = TRUE, 
                sep = ",", col.names = FALSE, row.names = FALSE)
    
    # Guardar archivo
    filename <- paste0(
      "C:/STI/clase_",
      tema_actual,
      "_",
      format(Sys.time(), "%Y%m%d_%H%M%S"),
      ".txt"
    )
    
    write(texto, file = filename)
    
    # Mostrar resultado
    output$result <- renderUI({
      div(style = "white-space: pre-wrap; word-wrap: break-word;", texto)
    })
    
    # Mostrar pregunta "¿Entendiste?"
    output$pregunta_entendiste <- renderUI({
      h4("¿Entendiste la clase?")
    })
    output$pregunta_entendiste <- renderUI({
      h4("¿Entendiste la clase?")
    })
    
    # Pega el código aquí:
    output$zona_evaluacion <- renderUI({
      tagList(
        hr(),
        h4("✍️ Escribe tu respuesta a la pregunta aquí:"),
        textAreaInput("respuesta_estudiante", "Tu respuesta:", "", width = "100%"),
        actionButton("evaluar", "Enviar respuesta al STI")
      )
    })
    
  })  # <--- Esta llave cierra el observeEvent
  
  # Botón "Sí, entendí"
  observeEvent(input$si, {
    # Guardar en historial
    historial <- read.csv(historial_file)
    ultimo <- nrow(historial)
    historial$entendio[ultimo] <- "si"
    write.csv(historial, historial_file, row.names = FALSE)
    
    # Mostrar mensaje
    showModal(modalDialog(
      title = "Excelente",
      paste("¡Me alegra que hayas entendido", input$topic, "!"),
      "¿Quieres seguir con otro tema?",
      actionButton("siguiente_tema", "Sí, siguiente tema"),
      footer = modalButton("Cerrar")
    ))
  })
  
  # Botón "No, explícame de nuevo"
  observeEvent(input$no, {
    # Guardar en historial
    historial <- read.csv(historial_file)
    ultimo <- nrow(historial)
    historial$entendio[ultimo] <- "no"
    write.csv(historial, historial_file, row.names = FALSE)
    
    # Generar nueva explicación más sencilla
    chat <- chat_openai(model = "gpt-4.1-mini")
    
    response <- chat$chat(
      paste(
        "El estudiante NO entendió la explicación anterior sobre", input$topic,
        "Explica el mismo tema pero de forma MUY sencilla,",
        "con ejemplos cotidianos y vocabulario fácil para un niño de", input$age, "años.",
        "Incluye:",
        "\n[EXPLICACIÓN SIMPLE]",
        "\n[EJEMPLO COTIDIANO]"
      )
    )
    
    texto <- response
    
    # Mostrar nueva explicación
    output$result <- renderUI({
      div(style = "white-space: pre-wrap; word-wrap: break-word;", 
          tags$h4("Explicación más sencilla:"), texto)
    })
  })
  
  # Botón "Sí, siguiente tema"
  observeEvent(input$siguiente_tema, {
    updateTextInput(session, "topic", value = "Compartir archivos en la nube")
    removeModal()
  })
  # --- NUEVO: Evaluar la respuesta del estudiante ---
  observeEvent(input$evaluar, {
    req(input$respuesta_estudiante) # Evita que se ejecute si está vacío
    
    # Mostrar un mensaje de "Cargando..."
    showModal(modalDialog("Evaluando tu respuesta...", footer = NULL))
    
    chat <- chat_openai(model = "gpt-4.1-mini")
    
    prompt_evaluacion <- paste(
      "Actúa como un docente evaluando a un niño de", input$age, "años.",
      "El tema era:", input$topic,
      "La respuesta del estudiante es:", input$respuesta_estudiante,
      "\nEvalúa la respuesta de forma amigable.",
      "Si está bien, felicítalo y explícale por qué está bien.",
      "Si está mal o incompleta, corrígelo con cariño y explícale la respuesta correcta de forma sencilla.",
      "Sé breve."
    )
    
    evaluacion <- chat$chat(prompt_evaluacion)
    
    removeModal() # Quita el mensaje de cargando
    
    # Mostrar la evaluación en una ventana
    showModal(modalDialog(
      title = "Resultado de tu evaluación 📝",
      div(style = "white-space: pre-wrap; font-size: 16px;", evaluacion),
      easyClose = TRUE,
      footer = modalButton("Entendido")
    ))
  })
}

shinyApp(ui = ui, server = server)