# Estadísticas descriptivas post-limpieza
# Correr librerías
library(tidyverse)

base_empleo_final <- read_csv("input/base_empleo_final.csv")
base_analisis_principal <- read_csv("input/base_analisis_principal.csv")

# Comparamos las estadísticas antes y después de excluir pandemia y recuperación
# para evaluar si esos años modificaban de forma relevante las variables del análisis.

tabla_comparacion_limpieza <- bind_rows(
  base_empleo_final %>%
    mutate(base = "Base original"),
  base_analisis_principal %>%
    mutate(base = "Base análisis principal")
) %>%
  select(
    base,
    var_ia_puestos_ar,
    var_ia_puestos_anr,
    var_ia_tasa_informalidad,
    tasa_informalidad
  ) %>%
  pivot_longer(
    cols = -base,
    names_to = "variable",
    values_to = "valor"
  ) %>%
  group_by(base, variable) %>%
  summarise(
    media = round(mean(valor, na.rm = TRUE), 2),
    mediana = round(median(valor, na.rm = TRUE), 2),
    minimo = round(min(valor, na.rm = TRUE), 2),
    maximo = round(max(valor, na.rm = TRUE), 2),
    desvio = round(sd(valor, na.rm = TRUE), 2),
    cantidad_observaciones = sum(!is.na(valor)),
    .groups = "drop"
  )

tabla_comparacion_limpieza

View(tabla_comparacion_limpieza)

write_csv(
  tabla_comparacion_limpieza,
  "output/tablas/tabla_comparacion_limpieza.csv"
)

#Luego de excluir 2020, 2021 y 2022, se observa una reducción en los valores máximos 
#y en la dispersión de las variables de variación interanual.
#Esto confirma que esos años concentraban valores extremos asociados a la 
#pandemia y a la recuperación posterior.
