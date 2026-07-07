#Gráfico exploratorio: brecha de crecimiento del empleo
#correr librerias
library(tidyverse)

base_empleo_final <- read_csv("input/base_empleo_final.csv")

# Construimos una medida de brecha porque la hipótesis compara directamente
# si el empleo no registrado crece más que el empleo registrado en cada trimestre.

base_brecha <- base_empleo_final %>%
  filter(
    !is.na(var_ia_puestos_ar),
    !is.na(var_ia_puestos_anr),
    !anio %in% c(2021, 2022)
  ) %>%
  mutate(
    brecha_var_ia = var_ia_puestos_anr - var_ia_puestos_ar,
    periodo = case_when(
      periodo == "crisis" ~ "Crisis",
      periodo == "no_crisis" ~ "No crisis"
    )
  ) %>%
  arrange(anio, trimestre_num) %>%
  mutate(
    trimestre = factor(trimestre, levels = trimestre),
    posicion_trimestre = row_number()
  )

# Usamos un gráfico de barras porque permite ver rápidamente en qué trimestres 
# la brecha fue positiva o negativa respecto del empleo registrado.
grafico_exploratorio <- ggplot(
  base_brecha,
  aes(
    x = posicion_trimestre,
    y = brecha_var_ia,
    fill = periodo
  )
) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    color = "gray40"
  ) +
  geom_col() +
  annotate(
    "label",
    x = 4,
    y = 16,
    label = "Barras positivas:\nel empleo no registrado creció más",
    size = 3.5,
    fill = "white",
    color = "gray25",
    linewidth = 0.3
  ) +
  annotate(
    "label",
    x = 4,
    y = -3,
    label = "Barras negativas:\nel empleo registrado creció más",
    size = 3.5,
    fill = "white",
    color = "gray25",
    linewidth = 0.3
  ) +
  scale_x_continuous(
    breaks = base_brecha$posicion_trimestre,
    labels = base_brecha$trimestre
  ) +
  labs(
    title = "Brecha de crecimiento entre empleo no registrado y registrado",
    subtitle = "Brecha = variación interanual no registrada menos registrada.",
    x = "Trimestre",
    y = "Diferencia de variación interanual (puntos porcentuales)",
    fill = "Período",
    caption = "Fuente: elaboración propia en base a CGI-INDEC."
  ) +
  scale_fill_manual(
    values = c(
      "No crisis" = "#1F77B4",
      "Crisis" = "#D95F02"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray35"),
    plot.caption = element_text(size = 8, color = "gray50", hjust = 0),
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 60, hjust = 1)
  )

grafico_exploratorio

#guardamos el gráfico
ggsave(
  "output/graficos/grafico_exploratorio_brecha.png",
  plot = grafico_exploratorio,
  width = 11,
  height = 6
)