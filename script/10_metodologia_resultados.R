# Metodología y resultados
# Correr librerías
library(tidyverse)
library(broom)

base_analisis_principal <- read_csv("input/base_analisis_principal.csv")

# Construimos la brecha de crecimiento porque la hipótesis compara
# directamente la variación del empleo no registrado contra el registrado.

base_resultados <- base_analisis_principal %>%
  filter(
    !is.na(var_ia_puestos_ar),
    !is.na(var_ia_puestos_anr)
  ) %>%
  mutate(
    brecha_var_ia = var_ia_puestos_anr - var_ia_puestos_ar,
    periodo_crisis = case_when(
      periodo == "crisis" ~ 1,
      periodo == "no_crisis" ~ 0
    ),
    periodo = case_when(
      periodo == "crisis" ~ "Crisis",
      periodo == "no_crisis" ~ "No crisis"
    )
  ) %>%
  filter(!is.na(periodo_crisis))

base_resultados

View(base_resultados)

write_csv(
  base_resultados,
  "output/tablas/base_resultados.csv"
)


# Comparamos la brecha promedio entre crisis y no crisis para evaluar
# si el patrón observado acompaña la hipótesis principal.

tabla_brecha_por_periodo <- base_resultados %>%
  group_by(periodo) %>%
  summarise(
    brecha_promedio = round(mean(brecha_var_ia, na.rm = TRUE), 2),
    brecha_mediana = round(median(brecha_var_ia, na.rm = TRUE), 2),
    brecha_minima = round(min(brecha_var_ia, na.rm = TRUE), 2),
    brecha_maxima = round(max(brecha_var_ia, na.rm = TRUE), 2),
    desvio = round(sd(brecha_var_ia, na.rm = TRUE), 2),
    cantidad_observaciones = n(),
    .groups = "drop"
  )

tabla_brecha_por_periodo

View(tabla_brecha_por_periodo)

write_csv(
  tabla_brecha_por_periodo,
  "output/tablas/tabla_brecha_por_periodo.csv"
)


# Usamos un test de diferencia de medias para ver si la brecha promedio
# cambia entre períodos de crisis y no crisis.

test_brecha <- t.test(
  brecha_var_ia ~ periodo,
  data = base_resultados
)


resultado_test_brecha <- tidy(test_brecha)
resultado_test_brecha

View(resultado_test_brecha)

write_csv(
  resultado_test_brecha,
  "output/tablas/resultado_test_brecha.csv"
)


# Estimamos una regresión simple para medir cuánto cambia la brecha promedio
# cuando el trimestre pertenece a un período de crisis.

modelo_brecha <- lm(
  brecha_var_ia ~ periodo_crisis,
  data = base_resultados
)

resultado_modelo_brecha <- tidy(modelo_brecha)

resultado_modelo_brecha

View(resultado_modelo_brecha)

write_csv(
  resultado_modelo_brecha,
  "output/tablas/resultado_modelo_brecha.csv"
)


# Guardamos una tabla final resumida.

brecha_crisis <- tabla_brecha_por_periodo %>%
  filter(periodo == "Crisis") %>%
  pull(brecha_promedio)

brecha_no_crisis <- tabla_brecha_por_periodo %>%
  filter(periodo == "No crisis") %>%
  pull(brecha_promedio)

diferencia_crisis <- resultado_modelo_brecha %>%
  filter(term == "periodo_crisis") %>%
  pull(estimate) %>%
  round(2)

p_valor_test <- resultado_test_brecha %>%
  pull(p.value) %>%
  round(4)

p_valor_regresion <- resultado_modelo_brecha %>%
  filter(term == "periodo_crisis") %>%
  pull(p.value) %>%
  round(4)

resultado_final_metodologia <- tibble(
  indicador = c(
    "Brecha promedio en crisis",
    "Brecha promedio en no crisis",
    "Diferencia crisis - no crisis",
    "P-valor test de medias",
    "P-valor regresión simple"
  ),
  valor = c(
    brecha_crisis,
    brecha_no_crisis,
    diferencia_crisis,
    p_valor_test,
    p_valor_regresion
  )
)

resultado_final_metodologia

View(resultado_final_metodologia)

write_csv(
  resultado_final_metodologia,
  "output/tablas/resultado_final_metodologia.csv"
)

# Creamos una tabla simplificada para presentar los resultados principales
# de forma clara en la presentación final.

brecha_crisis <- tabla_brecha_por_periodo %>%
  filter(periodo == "Crisis") %>%
  pull(brecha_promedio)

brecha_no_crisis <- tabla_brecha_por_periodo %>%
  filter(periodo == "No crisis") %>%
  pull(brecha_promedio)

diferencia_crisis <- resultado_modelo_brecha %>%
  filter(term == "periodo_crisis") %>%
  pull(estimate) %>%
  round(2)

p_valor_regresion <- resultado_modelo_brecha %>%
  filter(term == "periodo_crisis") %>%
  pull(p.value)

tabla_presentacion_resultados <- tibble(
  resultado = c(
    "Brecha promedio en crisis",
    "Brecha promedio en no crisis",
    "Diferencia crisis - no crisis",
    "Significatividad estadística"
  ),
  valor = c(
    paste0(brecha_crisis, " puntos"),
    paste0(brecha_no_crisis, " puntos"),
    paste0(diferencia_crisis, " puntos"),
    case_when(
      p_valor_regresion < 0.05 ~ "Significativa al 5%",
      TRUE ~ "No significativa al 5%"
    )
  )
)

tabla_presentacion_resultados


View(tabla_presentacion_resultados)

write_csv(
  tabla_presentacion_resultados,
  "output/tablas/tabla_presentacion_resultados.csv"
)


#Luego de excluir 2020, 2021 y 2022, la brecha promedio fue mayor en los períodos de crisis. 
#Esto acompaña la hipótesis de que el empleo no registrado crece más que el registrado en contextos de crisis.
#Sin embargo, la diferencia no resulta estadísticamente significativa al 5%, por 
#lo que la evidencia debe interpretarse como descriptiva y no concluyente.