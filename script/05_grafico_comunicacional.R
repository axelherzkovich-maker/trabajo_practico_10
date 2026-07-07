# Gráfico comunicacional: comparación del crecimiento del empleo entre crisis
#correr librerias
library(tidyverse)


base_empleo_final <- read_csv("input/base_empleo_final.csv")

# Indexamos las series para comparar la evolución del empleo registrado
# y no registrado aunque parten de niveles distintos.

base_indexada <- base_empleo_final %>%
  select(
    trimestre,
    anio,
    trimestre_num,
    periodo,
    puestos_ar,
    puestos_anr
  ) %>%
  pivot_longer(
    cols = c(puestos_ar, puestos_anr),
    names_to = "tipo_empleo",
    values_to = "puestos"
  ) %>%
  mutate(
    tipo_empleo = case_when(
      tipo_empleo == "puestos_ar" ~ "Empleo registrado",
      tipo_empleo == "puestos_anr" ~ "Empleo no registrado"
    )
  ) %>%
  group_by(tipo_empleo) %>%
  mutate(
    indice = puestos / first(puestos) * 100
  ) %>%
  ungroup()

# Resumimos los períodos de crisis para mostrar de forma simple
# si el empleo no registrado crece más que el registrado en esos contextos.

promedios_crisis <- base_indexada %>%
  filter(
    periodo == "crisis"
  ) %>%
  mutate(
    crisis = case_when(
      anio %in% c(2018, 2019) ~ "Crisis 2018-2019",
      anio %in% c(2023, 2024) ~ "Crisis 2023-2024"
    )
  ) %>%
  filter(!is.na(crisis)) %>%
  group_by(crisis, tipo_empleo) %>%
  summarise(
    indice_promedio = round(mean(indice, na.rm = TRUE), 2),
    .groups = "drop"
  ) %>%
  mutate(
    crisis = factor(
      crisis,
      levels = c("Crisis 2018-2019", "Crisis 2023-2024")
    )
  )

# Calculamos la diferencia de crecimiento entre ambas series para que
# el título comunique el principal hallazgo del gráfico.

crecimiento_entre_crisis <- promedios_crisis %>%
  arrange(crisis) %>%
  group_by(tipo_empleo) %>%
  summarise(
    crecimiento_pct = round((last(indice_promedio) / first(indice_promedio) - 1) * 100, 1),
    .groups = "drop"
  )

brecha_crecimiento <- crecimiento_entre_crisis %>%
  summarise(
    crecimiento_registrado = crecimiento_pct[tipo_empleo == "Empleo registrado"],
    crecimiento_no_registrado = crecimiento_pct[tipo_empleo == "Empleo no registrado"],
    diferencia_pp = round(crecimiento_no_registrado - crecimiento_registrado, 1)
  )

titulo_grafico <- paste0(
  "Entre las crisis, los no registrados crecieron ",
  brecha_crecimiento$diferencia_pp,
  " puntos más que los registrados"
)


# armamos un gráfico para una visualización clara,con mensaje directo y entendible para todo público.

grafico_comunicacional <- ggplot(
  promedios_crisis,
  aes(
    x = crisis,
    y = indice_promedio,
    group = tipo_empleo,
    color = tipo_empleo
  )
) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 4) +
  geom_text(
    aes(label = indice_promedio),
    vjust = -1,
    size = 4,
    show.legend = FALSE
  ) +
  labs(
    title = titulo_grafico,
    subtitle = "Comparación del crecimiento promedio del empleo registrado y no registrado entre las dos crisis analizadas.",
    x = NULL,
    y = "Índice de crecimiento promedio",
    color = "Tipo de empleo",
    caption = "Fuente: elaboración propia en base a CGI-INDEC. La diferencia se expresa en puntos porcentuales. Índice base 2016 Q1 = 100."
  ) +
  scale_color_manual(
    values = c(
      "Empleo registrado" = "#1F77B4",
      "Empleo no registrado" = "#D95F02"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray35"),
    plot.caption = element_text(size = 8, color = "gray50", hjust = 0),
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

grafico_comunicacional

# Guardamos el gráfico
ggsave(
  filename = "output/graficos/grafico_comunicacional.png",
  plot = grafico_comunicacional,
  width = 10,
  height = 6
)




































