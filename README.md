# STI - Sistema Tutorial Inteligente

Sistema Tutorial Inteligente (STI) desarrollado en R con Shiny y conectado a la API de OpenAI (GPT-4.1-mini). Genera clases personalizadas, se adapta al estudiante y evalúa su aprendizaje de forma autónoma.

## Módulos

| Módulo | Función | Estado |
|--------|---------|--------|
| Dominio | Genera clases y ajusta dificultad | ✅ |
| Estudiante | Detecta estilo de aprendizaje | ✅ |
| Tutor | Decide tema, estilo y evalúa | ✅ |
| Interfaz | App Shiny interactiva | ✅ |

## Funcionalidades

- Generación de clases con estructura fija
- Guardado automático en `.txt`
- Historial en `historial.csv`
- Autonomía de tema y estilo
- Bucle de retroalimentación
- Evaluación automática con IA

## Tecnologías

- R + Shiny
- Librería `ellmer`
- OpenAI API (`gpt-4.1-mini`)

## Configuración

1. Crea un archivo .env en la raíz con la línea: OPENAI_API_KEY=tu_clave_aqui
2. Instala las dependencias ejecutando en R: install.packages(c("shiny", "ellmer", "dotenv"))
3. Ejecuta la aplicación con: shiny::runApp("STI_app.R")

## Requisitos

- R versión 4.3 o superior
- Cuenta de OpenAI con saldo
