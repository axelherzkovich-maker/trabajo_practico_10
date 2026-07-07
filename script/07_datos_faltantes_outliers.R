# Datos faltantes y outliers
# Correr librerías
library(tidyverse)

base_empleo_final <- read_csv("input/base_empleo_final.csv")

# Primero revisamos si la base tiene valores faltantes.
# Esto es importante porque las variaciones interanuales pueden generar NA
# cuando no existe el mismo trimestre del año anterior para comparar.
datos_faltantes <- base_empleo_final %>%
  summarise(
    across(
      everything(),
      ~ sum(is.na(.))
    )
  ) %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "cantidad_na"
  ) %>%
  arrange(desc(cantidad_na))

datos_faltantes

View(datos_faltantes)

write_csv(datos_faltantes, "output/tablas/datos_faltantes.csv")


# Detectamos outliers en las variables de variación interanual porque son las
# que pueden mostrar saltos fuertes asociados a crisis o recuperación económica.

variables_outliers <- base_empleo_final %>%
  select(
    trimestre,
    anio,
    periodo,
    var_ia_puestos_ar,
    var_ia_puestos_anr,
    var_ia_tasa_informalidad,
    var_ia_empleo_oede
  ) %>%
  pivot_longer(
    cols = c(
      var_ia_puestos_ar,
      var_ia_puestos_anr,
      var_ia_tasa_informalidad,
      var_ia_empleo_oede
    ),
    names_to = "variable",
    values_to = "valor"
  ) %>%
  filter(!is.na(valor)) %>%
  mutate(
    variable = case_when(
      variable == "var_ia_puestos_ar" ~ "Empleo registrado",
      variable == "var_ia_puestos_anr" ~ "Empleo no registrado",
      variable == "var_ia_tasa_informalidad" ~ "Tasa de informalidad",
      variable == "var_ia_empleo_oede" ~ "Empleo privado OEDE"
    )
  )

# Usamos el criterio IQR para marcar valores muy alejados del rango habitual
# de cada variable.

outliers_iqr <- variables_outliers %>%
  group_by(variable) %>%
  mutate(
    q1 = quantile(valor, 0.25, na.rm = TRUE),
    q3 = quantile(valor, 0.75, na.rm = TRUE),
    iqr = q3 - q1,
    limite_inferior = q1 - 1.5 * iqr,
    limite_superior = q3 + 1.5 * iqr,
    es_outlier = valor < limite_inferior | valor > limite_superior
  ) %>%
  ungroup() %>%
  filter(es_outlier == TRUE) %>%
  select(
    trimestre,
    anio,
    periodo,
    variable,
    valor,
    limite_inferior,
    limite_superior
  )

outliers_iqr

View(outliers_iqr)

write_csv(outliers_iqr, "output/tablas/outliers_iqr.csv")


# Visualizamos las variables de variación interanual para mostrar dónde aparecen
# los valores extremos detectados por el criterio IQR.

grafico_outliers <- variables_outliers %>%
  ggplot(
    aes(
      x = variable,
      y = valor,
      fill = variable,
      color = variable
    )
  ) +
  geom_boxplot(
    alpha = 0.35,
    outlier.shape = NA
  ) +
  geom_jitter(
    width = 0.15,
    alpha = 0.7,
    size = 2
  ) +
  labs(
    title = "Valores extremos en las variaciones interanuales",
    subtitle = "Los puntos alejados del boxplot indican posibles outliers según el criterio IQR.",
    x = "Variable",
    y = "Variación interanual (%)",
    caption = "Fuente: elaboración propia en base a CGI-INDEC y OEDE."
  ) +
  scale_fill_manual(
    values = c(
      "Empleo privado OEDE" = "#1F77B4",
      "Empleo no registrado" = "#D95F02",
      "Empleo registrado" = "#2CA02C",
      "Tasa de informalidad" = "#9467BD"
    )
  ) +
  scale_color_manual(
    values = c(
      "Empleo privado OEDE" = "#1F77B4",
      "Empleo no registrado" = "#D95F02",
      "Empleo registrado" = "#2CA02C",
      "Tasa de informalidad" = "#9467BD"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray35"),
    plot.caption = element_text(size = 8, color = "gray50", hjust = 0),
    legend.position = "none",
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 25, hjust = 1)
  )

grafico_outliers

ggsave(
  "output/graficos/boxplot_outliers_variaciones.png",
  plot = grafico_outliers,
  width = 10,
  height = 6
)

#Los valores extremos se concentran en las variaciones interanuales del 
#empleo no registrado y de la tasa de informalidad, principalmente en 2021 y 2022. 
#Estos valores no se interpretan como errores, 
#sino como efectos asociados a la recuperación posterior a la pandemia.

