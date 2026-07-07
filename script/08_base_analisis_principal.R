# Base de análisis principal
# Correr librerías
library(tidyverse)

# Creamos una base de análisis principal sin pandemia ni recuperación post-pandemia
# para evitar que esos años distorsionen la comparación entre crisis y no crisis.

base_analisis_principal <- base_empleo_final %>%
  filter(
    !anio %in% c(2020, 2021, 2022)
  )

base_analisis_principal

View(base_analisis_principal)

write_csv(
  base_analisis_principal,
  "input/base_analisis_principal.csv"
)