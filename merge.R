#-- Limpieza y enriquecimiento del dataset (Practica 1 y 2) --
# Cargar librerías necesarias
library(tidyverse)

# 1. Cargar datasets
mental_health <- read_csv("survey.csv")
happiness <- read_csv("World Happiness Report.csv")
suicide <- read_csv("who_suicide_statistics.csv")

# 2. Filtrar datasets para 2014
happiness_2014 <- happiness %>%
  filter(Year == 2014)

suicide_2014 <- suicide %>%
  filter(year == 2014)

# 3. Procesar tasa de suicidio
# Agrupar por país para calcular la tasa de suicidio total
suicide_country_2014 <- suicide_2014 %>%
  group_by(country) %>%
  summarise(
    total_suicides = sum(suicides_no, na.rm = TRUE),
    total_population = sum(population, na.rm = TRUE)
  ) %>%
  mutate(suicide_rate = (total_suicides / total_population) * 100000)

# 4. Normalizar nombres de países para facilitar join
normalize_country <- function(x) {
  x %>%
    str_to_lower() %>%
    str_replace_all("[^a-z ]", "") %>%
    str_replace_all(" +", " ") %>%
    str_trim()
}

correct_country_names <- function(country) {
  case_when(
    country == "united states" ~ "united states of america",
    country == "uk" ~ "united kingdom",
    country == "russia" ~ "russian federation",
    country == "south korea" ~ "korea, republic of",
    country == "north korea" ~ "korea, democratic people's republic of",
    country == "venezuela" ~ "venezuela (bolivarian republic of)",
    country == "iran" ~ "iran (islamic republic of)",
    TRUE ~ country
  )
}

mental_health <- mental_health %>% 
  mutate(Country_norm = normalize_country(Country)) %>%
  mutate(Country_norm = correct_country_names(Country_norm))

happiness_2014 <- happiness_2014 %>%
  mutate(Country_norm = normalize_country(`Country Name`)) %>%
  mutate(Country_norm = correct_country_names(Country_norm))

suicide_country_2014 <- suicide_country_2014 %>%
  mutate(Country_norm = normalize_country(country)) %>%
  mutate(Country_norm = correct_country_names(Country_norm))



# 5. Unir datasets
mental_health_enriched <- mental_health %>%
  left_join(happiness_2014 %>% select(Country_norm, 
                                      Life_Ladder = `Life Ladder`,
                                      Log_GDP_per_Capita = `Log GDP Per Capita`,
                                      Social_Support = `Social Support`,
                                      Healthy_Life_Expectancy = `Healthy Life Expectancy At Birth`,
                                      Freedom = `Freedom To Make Life Choices`,
                                      Generosity = `Generosity`,
                                      Corruption = `Perceptions Of Corruption`,
                                      Positive_Affect = `Positive Affect`,
                                      Negative_Affect = `Negative Affect`,
                                      Confidence_Government = `Confidence In National Government`), 
            by = "Country_norm") %>%
  left_join(suicide_country_2014 %>% select(Country_norm, suicide_rate), by = "Country_norm")

# 6. Guardar dataset final
write_csv(mental_health_enriched, "mental_health_enriched_2014.csv")

# 7. Verificar estructura
glimpse(mental_health_enriched)

# --- LIMPIEZA PARA VISUALIZACIÓN (Práctica 2) ---
library(tidyverse)
library(janitor)

# Cargar dataset ya enriquecido
df <- read_csv("mental_health_enriched_2014.csv")

# Limpiar nombres de columnas
df <- clean_names(df)

# 1. Limpiar y recodificar género
library(dplyr)
library(stringr)

# Guardamos la versión original por si queremos auditar
library(stringr)

# Lista de patrones típicos
female_keywords <- c(
  "female", "f", "fem", "femail", "cis female", "woman", "Femake", "female (cis)", "trans female"
)

male_keywords <- c(
  "male", "m", "man", "cis male", "male (cis)", "malr", "Malr", "Mail", "Make", "male-ish", "trans male"
)

# Normalización robusta
df <- df %>%
  mutate(
    gender_original = gender,
    gender_clean = gender %>%
      tolower() %>%
      str_replace_all("[^a-z]", " ") %>%      # eliminar signos y símbolos
      str_squish()
  ) %>%
  mutate(
    gender = case_when(
      gender_clean %in% female_keywords ~ "female",
      gender_clean %in% male_keywords ~ "male",
      TRUE ~ "Queer/Non-binary/Androgyne/Fluid"
    )
  )

# 2. Estandarizar respuestas tipo Yes/No/Maybe
df <- df %>% mutate(across(
  .cols = where(is.character),
  .fns = ~str_to_title(str_trim(.))
))

# 3. Reemplazar NA en variables categóricas por "Unknown"
df <- df %>% mutate(across(
  .cols = where(is.character),
  .fns = ~replace_na(., "Unknown")
))

# 4. Limpiar edades inválidas (por si hubiera)
df <- df %>% mutate(age = ifelse(age < 18 | age > 80, NA, age))

# 5. Guardar dataset limpio para visualización
write_csv(df, "mental_health_clean_viz.csv")

