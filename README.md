# Empleo informal vs. registrado en Argentina durante crisis económicas (2016–2025)

## Integrantes — Grupo 10

- Axel Herzkovich

*(Materia: Ciencia de Datos para Economía y Negocios — FCE-UBA)*

---

## Objetivo

El trabajo analiza la dinámica del empleo asalariado registrado y no registrado en Argentina entre 2016 y 2025, con el objetivo de evaluar si el empleo no registrado crece más que el registrado durante los períodos de crisis económica.

**Hipótesis principal:** durante los períodos de crisis económica, el empleo informal (no registrado) crece en mayor medida que el empleo registrado.

Se definieron dos períodos de crisis dentro de la serie:

| Período | Categoría |
|---|---|
| 2018 Q2 – 2019 Q4 | Primera crisis cambiaria |
| 2023 Q3 – 2024 Q4 | Segunda crisis cambiaria |
| Resto de la serie (excluyendo 2020) | No crisis |

El año 2020 se excluyó por completo del análisis por tratarse de un shock atípico (pandemia). Los años 2021 y 2022 se excluyeron de la base de análisis principal porque corresponden a la recuperación pos-pandemia, cuyo rebote distorsiona la comparación entre crisis y no crisis.

---

## Datos utilizados

- **Fuente principal:** [Cuenta Generación del Ingreso (CGI) — INDEC](https://www.indec.gob.ar), series trimestrales de puestos de trabajo asalariados registrados (AR) y no registrados (ANR), 2016 Q1–2025 Q4. Archivo crudo: `raw/serie_cgi_04_26.xls`.
- **Fuente complementaria:** [Observatorio de Empleo y Dinámica Empresarial (OEDE) — Ministerio de Trabajo](https://www.trabajo.gob.ar/estadisticas/oede/), serie nacional trimestral de empleo privado registrado, usada para contrastar la evolución del CGI con otra fuente. Archivo crudo: `raw/nacional_serie_empleo_trimestral_6.xlsx`.

> Nota: en el planteo inicial del trabajo se había previsto usar el PIB per cápita como serie de benchmark. En esta entrega final el análisis se concentró en CGI y OEDE, por lo que la carpeta `auxiliar/` no contiene archivos.

---

## Descripción del análisis realizado

El pipeline se organiza en 10 scripts secuenciales dentro de `script/`:

| Script | Qué hace |
|---|---|
| `00_setup.R` | Instala los paquetes necesarios (`tidyverse`, `readxl`, `lubridate`). |
| `01_limpieza_cgi.R` | Lee las hojas crudas del CGI, extrae los puestos AR y ANR, los lleva a formato largo trimestral, calcula la tasa de informalidad, clasifica cada trimestre en crisis/no crisis/excluido y calcula variaciones interanuales. Guarda `input/cgi_empleo_limpia.csv`. |
| `02_limpieza_oede.R` | Limpia la serie de empleo del OEDE, homogeneiza el formato de trimestre con el del CGI y guarda `input/oede_limpio.csv`. |
| `03_union_bases.R` | Une CGI y OEDE por trimestre (`left_join`) en `input/base_empleo_final.csv`. |
| `04_estadisticas_descriptivas.R` | Estadística descriptiva general y por período (crisis/no crisis) de las variables de empleo. |
| `05_grafico_comunicacional.R` | Gráfico de índices (base 100) comparando el crecimiento promedio del empleo registrado y no registrado entre ambas crisis. |
| `06_grafico_exploratorio.R` | Gráfico de barras de la brecha trimestral entre las variaciones interanuales de empleo no registrado y registrado. |
| `07_datos_faltantes_outliers.R` | Diagnóstico de valores faltantes y detección de outliers (criterio IQR) en las variables de variación interanual. |
| `08_base_analisis_principal.R` | Construye la base de análisis principal excluyendo 2020–2022, usada en el Método 2. |
| `09_estadisticas_post_limpieza.R` | Compara estadísticas descriptivas antes y después de excluir pandemia y recuperación, para justificar la exclusión. |
| `10_metodologia_resultados.R` | Calcula la brecha de crecimiento (variación interanual no registrado − registrado), aplica un test t de Welch y una regresión lineal simple para comparar la brecha entre crisis y no crisis. |

---

## Resultados principales

| Indicador | Valor |
|---|---|
| Brecha promedio de crecimiento en crisis | 2,11 p.p. |
| Brecha promedio de crecimiento en no crisis | 0,89 p.p. |
| Diferencia estimada (crisis − no crisis) | 1,22 p.p. |
| Test t de Welch, p-valor | 0,2146 |

Durante los períodos de crisis, el empleo no registrado mostró una brecha de crecimiento interanual promedio superior a la del empleo registrado, en línea con la hipótesis principal. Sin embargo, el test de Welch (elegido por la desigualdad de varianzas entre ambos grupos) no arroja una diferencia estadísticamente significativa al 5%, por lo que el resultado se interpreta como evidencia descriptiva a favor de la hipótesis, pero no concluyente.

---

## Estructura del repositorio

```
trabajo_practico_10/
├── raw/                  # Datos crudos del CGI y del OEDE, sin modificar
├── auxiliar/             # Reservada para insumos complementarios (sin uso en esta entrega)
├── input/                # Bases limpias y unidas, listas para el análisis
├── output/
│   ├── tablas/           # Tablas de resultados generadas por los scripts
│   └── graficos/         # Visualizaciones generadas por los scripts
├── script/               # Scripts de R, uno por etapa (00 a 10)
├── utils/                # Reservada para funciones propias (sin uso en esta entrega)
├── presentacion/         # Presentación final del trabajo (PDF)
└── README.md
```

---

## Reproducción del análisis

### Paquetes necesarios

```r
install.packages(c("tidyverse", "readxl", "lubridate", "broom"))
```

### Orden de ejecución

1. `script/00_setup.R` — instala los paquetes (correr una sola vez).
2. `script/01_limpieza_cgi.R` — limpia el CGI y genera `input/cgi_empleo_limpia.csv`.
3. `script/02_limpieza_oede.R` — limpia el OEDE y genera `input/oede_limpio.csv`.
4. `script/03_union_bases.R` — une ambas bases en `input/base_empleo_final.csv`.
5. `script/04_estadisticas_descriptivas.R` — estadística descriptiva general y por período.
6. `script/05_grafico_comunicacional.R` y `script/06_grafico_exploratorio.R` — generan las visualizaciones en `output/graficos/`.
7. `script/07_datos_faltantes_outliers.R` — diagnóstico de valores faltantes y outliers.
8. `script/08_base_analisis_principal.R` — genera la base sin 2020–2022 para el análisis principal.
9. `script/09_estadisticas_post_limpieza.R` — compara estadísticas antes/después de la exclusión.
10. `script/10_metodologia_resultados.R` — aplica el test t de Welch y la regresión, y genera las tablas finales de resultados.

No es necesario descargar ningún archivo manualmente: los datos crudos ya están incluidos en `raw/`.

---

## Conclusiones principales

La evidencia descriptiva es consistente con la hipótesis de que el empleo no registrado crece más que el registrado durante los períodos de crisis analizados (2018 Q2–2019 Q4 y 2023 Q3–2024 Q4): la brecha promedio de crecimiento interanual en crisis (2,11 p.p.) más que duplica a la de los períodos sin crisis (0,89 p.p.). No obstante, esta diferencia no resulta estadísticamente significativa al 5% (test t de Welch, p = 0,21), por lo que el resultado debe leerse como un patrón descriptivo y no como una confirmación estadística robusta de la hipótesis. Además, se observa que la brecha entre ambos tipos de empleo también aparece —aunque en menor magnitud— fuera de los períodos de crisis, lo que matiza la idea de que este comportamiento sea exclusivo de los contextos de crisis.
