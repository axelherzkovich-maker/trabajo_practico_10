#Unión de bases CGI + OEDE

#correr librerias
library(tidyverse)
library(readxl)

# Unimos las bases limpias porque el análisis final necesita comparar
# las series de empleo usando la misma referencia temporal.


cgi_empleo_limpia <- read_csv("input/cgi_empleo_limpia.csv")
oede_limpio <- read_csv("input/oede_limpio.csv")

base_empleo_final <- cgi_empleo_limpia %>%
  left_join(
    oede_limpio,
    by = c("trimestre", "anio", "trimestre_num")
  )

glimpse(base_empleo_final)

View(base_empleo_final)

#Guardamos la base del empleo final para el uso de metodos, gráficos y presentación final.
write_csv(base_empleo_final, "input/base_empleo_final.csv")

