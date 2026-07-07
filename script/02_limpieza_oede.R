#Limpieza de datos oede

#correr librerias
library(tidyverse)
library(readxl)

#Usamos OEDE como fuente complementaria porque permite contrastar la evolución
# del empleo registrado privado con la información del CGI

ruta_oede <- "raw/nacional_serie_empleo_trimestral_6.xlsx"

oede_crudo <- read_excel(
  ruta_oede,
  sheet = "C1.1",
  skip = 2
)
glimpse(oede_crudo)
View(oede_crudo)

# seleccionamos solo las variables necesarias para el análisis.
oede_limpio <- oede_crudo %>%
  select(
    periodo_oede = Período,
    empleo_oede = Empleo,
    var_ia_empleo_oede = `Var. %  interanual`
  )

# Adaptamos el período de OEDE al formato de CGI y descartamos las filas auxiliares
# del la tabla original para que la unión se haga solo sobre trimestres válidos.
oede_limpio <- oede_crudo %>%
  select(
    periodo_oede = Período,
    empleo_oede = Empleo,
    var_ia_empleo_oede = `Var. %  interanual`
  ) %>%
  filter(!is.na(periodo_oede)) %>%
  mutate(
    periodo_oede = as.character(periodo_oede)
  ) %>%
  filter(substr(periodo_oede, 1, 1) %in% c("1", "2", "3", "4")) %>%
  filter(str_detect(periodo_oede, "20[0-9]{2}$")) %>%
  mutate(
    trimestre_num = as.numeric(substr(periodo_oede, 1, 1)),
    anio = as.numeric(substr(
      periodo_oede,
      nchar(periodo_oede) - 3,
      nchar(periodo_oede)
    )),
    trimestre = paste0(anio, " Q", trimestre_num),
    empleo_oede = round(as.numeric(empleo_oede), 0),
    var_ia_empleo_oede = round(as.numeric(var_ia_empleo_oede) * 100, 2)
  ) %>%
  filter(anio >= 2016, anio <= 2025) %>%
  select(
    trimestre,
    anio,
    trimestre_num,
    empleo_oede,
    var_ia_empleo_oede
  )

glimpse(oede_limpio)
View(oede_limpio)

base_empleo_final <- cgi_empleo_limpia %>%
  left_join(
    oede_limpio,
    by = c("trimestre", "anio", "trimestre_num")
  )


View(base_empleo_final)

#Guardamos la base OEDE limpia para unirla después con la base CGI
write_csv(oede_limpio, "input/oede_limpio.csv")
