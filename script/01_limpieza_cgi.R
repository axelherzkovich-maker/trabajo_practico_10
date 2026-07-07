#limpieza de datos CGI

#correr librerias
library(tidyverse)
library(readxl)

# creamos la ruta relativa que permite reproducir el script dentro del proyecto.

ruta_cgi <- "raw/serie_cgi_04_26.xls"

#Importamos las hojas en bruto porque el archivo original no tiene una estructura impia desde la primera fila

puestos_ar_crudos <- read_excel(
  ruta_cgi,
  sheet = "Puestos AR",
  col_names = FALSE
)
puestos_ar_crudos

puestos_anr_crudos <- read_excel(
  ruta_cgi,
  sheet = "Puestos ANR",
  col_names = FALSE
)
#Selección de columnas trimestrales 

columnas_trimestres <- c(
  3:6,     # 2016
  9:12,    # 2017
  15:18,   # 2018
  21:24,   # 2019
  27:30,   # 2020
  33:36,   # 2021
  39:42,   # 2022
  45:48,   # 2023
  51:54,   # 2024
  57:60    # 2025
)
columnas_trimestres

#Se toma la fila de Total general de Asalariados registrados y lo llevamos a formato trimestral para lograr
#una seri comparable en el tiempo

puestos_ar_limpio <- puestos_ar_crudos %>%
  slice(7) %>%
  select(all_of(columnas_trimestres)) %>%
  pivot_longer(
    cols = everything(),
    names_to = "columna_original",
    values_to = "puestos_ar"
  ) %>%
  mutate(
    puestos_ar = round(as.numeric(puestos_ar), 2),
    anio = rep(2016:2025, each = 4),
    trimestre_num = rep(1:4, times = 10),
    trimestre = paste0(anio, " Q", trimestre_num)
  ) %>%
  select(trimestre, anio, trimestre_num, puestos_ar)

glimpse(puestos_ar_limpio)
view(puestos_ar_limpio)

# Se toma la fila de Total general de asalariados no registrados y lo llevamos a formato trimestral
# para lograr una serie única y comparable con los puestos registrados.

puestos_anr_limpio <- puestos_anr_crudos %>%
  slice(7) %>%
  select(all_of(columnas_trimestres)) %>%
  pivot_longer(
    cols = everything(),
    names_to = "columna_original",
    values_to = "puestos_anr"
  ) %>%
  mutate(
    puestos_anr = round(as.numeric(puestos_anr), 2),
    anio = rep(2016:2025, each = 4),
    trimestre_num = rep(1:4, times = 10),
    trimestre = paste0(anio, " Q", trimestre_num)
  ) %>%
  select(trimestre, anio, trimestre_num, puestos_anr)

glimpse(puestos_anr_limpio)
View(puestos_anr_limpio)


# union de las tablas de asalariados registrados y no registrados
cgi_empleo <- puestos_ar_limpio %>%
  left_join(
    puestos_anr_limpio,
    by = c("trimestre", "anio", "trimestre_num")
  )
view(cgi_empleo)

#Creamos variables para medir el peso del empleo no registrado
# y clasificar los trimestres según los períodos de crisis y no crisis
cgi_empleo <- cgi_empleo %>%
  mutate(
    puestos_total_asalariados = puestos_ar + puestos_anr,
    tasa_informalidad = puestos_anr / puestos_total_asalariados,
    periodo = case_when(
      anio == 2020 ~ "excluido",
      anio == 2018 & trimestre_num >= 2 ~ "crisis",
      anio == 2019 ~ "crisis",
      anio == 2023 & trimestre_num >= 3 ~ "crisis",
      anio == 2024 ~ "crisis",
      TRUE ~ "no_crisis"
    )
  )
view(cgi_empleo)

#Calculamos variaciones interanuales para comparar cada trimestre con el mismo
# trimestre del año anterior y evitar estacionalidad.

cgi_empleo <- cgi_empleo %>%
  arrange(anio, trimestre_num) %>%
  mutate(
    var_ia_puestos_ar = (puestos_ar / lag(puestos_ar, 4) - 1) * 100,
    var_ia_puestos_anr = (puestos_anr / lag(puestos_anr, 4) - 1) * 100,
    var_ia_tasa_informalidad = (tasa_informalidad / lag(tasa_informalidad, 4) - 1) * 100
  )

# Dejamos fuera el año 2020 porque la pandemia fue un shock atípico que puede distorsionar
# el anális entre períodos de crisis y no crisis.

cgi_empleo_limpia <- cgi_empleo %>%
  filter(periodo != "excluido")

#Verificaciones simples de la estructura y cantidad de observaciones.

glimpse(cgi_empleo_limpia)

cgi_empleo_limpia %>%
  count(anio)

cgi_empleo_limpia %>%
  count(periodo)

# Guardamos la base limpia para reutilizarla después en los gráficos y en el análisis descriptivo.

write_csv(cgi_empleo_limpia, "input/cgi_empleo_limpia.csv")


view(cgi_empleo_limpia)





