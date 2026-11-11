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
- librería `ellmer`
- OpenAI API (`gpt-4.1-mini`)

## Configuración

1. Crea un archivo `.env` en la raíz con:

2. Instala las dependencias:
```R
install.packages(c("shiny", "ellmer", "dotenv")) 

3. Ejecuta la app:
shiny::runApp("STI_app.R")

## Requisitos

- R 4.3+
- Cuenta de OpenAI con saldo
