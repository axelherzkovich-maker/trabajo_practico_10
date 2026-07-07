#correr librerias
library(tidyverse)
library(readxl)

base_empleo_final <- read_csv("input/base_empleo_final.csv")

# Resumimos las variables de empleo para ver una visón general
# de sus niveles, variación y dispersión antes del análisis gráfico.

tabla_descriptiva_general <- base_empleo_final %>%
  select(
    puestos_ar,
    puestos_anr,
    tasa_informalidad,
    var_ia_puestos_ar,
    var_ia_puestos_anr,
    empleo_oede,
    var_ia_empleo_oede
  ) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "valor"
  ) %>%
  group_by(variable) %>%
  summarise(
    media = round(mean(valor, na.rm = TRUE), 2),
    mediana = round(median(valor, na.rm = TRUE), 2),
    minimo = round(min(valor, na.rm = TRUE), 2),
    maximo = round(max(valor, na.rm = TRUE), 2),
    desvio = round(sd(valor, na.rm = TRUE), 2),
    .groups = "drop"
  )

tabla_descriptiva_general
view(tabla_descriptiva_general)

write_csv(tabla_descriptiva_general,"output/tablas/tabla_descriptiva_general.csv")


# Comparamos los períodos de crisis y no crisis porque la hipótesis plantea
# que el empleo no registrado cambia de manera distinta según el contexto.

tabla_por_periodo <- base_empleo_final %>%
  group_by(periodo) %>%
  summarise(
    promedio_puestos_ar = round(mean(puestos_ar, na.rm = TRUE), 2),
    promedio_puestos_anr = round(mean(puestos_anr, na.rm = TRUE), 2),
    promedio_var_ia_puestos_ar = round(mean(var_ia_puestos_ar, na.rm = TRUE), 2),
    promedio_var_ia_puestos_anr = round(mean(var_ia_puestos_anr, na.rm = TRUE), 2),
    diferencia_var_ia_anr_ar = round(mean(var_ia_puestos_anr, na.rm = TRUE) - mean(var_ia_puestos_ar, na.rm = TRUE),2),
    promedio_tasa_informalidad = round(mean(tasa_informalidad, na.rm = TRUE), 2),
    cantidad_observaciones = n(),
    .groups = "drop"
  )

tabla_por_periodo

view(tabla_por_periodo)

write_csv(tabla_por_periodo,"output/tablas/tabla_por_periodo.csv")

#------------------------------------------------------------------------------------------------------------------------
#La evidencia descriptiva muestra que, durante los períodos de crisis, 
#el empleo no registrado tuvo una variación interanual promedio superior 
#a la del empleo registrado. Mientras el empleo registrado cayó levemente 
#en promedio (-0,13%), el empleo no registrado creció 1,98%. Esto acompaña la 
#hipótesis principal. Sin embargo, la diferencia también se observa en períodos no crisis, 
#por lo que el resultado lo analizo como una primera evidencia,pero no una confirmación.






















