library(tidyverse)
library(dplyr)
library(rvest)

# Criar pasta dados se não existir
if (!dir.exists("dados")) {
  dir.create("dados")
}

data_coleta <- gsub("[[:space:]]+", "_", Sys.time())
html <- read_html("https://proad.ufpr.br/ru/ru-centro-politecnico/", encoding = "utf-8")

# Extrair os dias (textos em negrito que contém "feira")
dias <- html |> 
  html_elements("strong") |>
  html_text2() |>
  as_tibble() |>
  filter(str_detect(value, "[Ff]eira")) |>
  pull(value)

# Extrair todas as tabelas
tabelas <- html |> 
  html_elements("table") |>
  html_table()

cardapio_raw <- data.frame(tabelas)
names(cardapio_raw) <- dias


cardapio <- cardapio_raw %>%
  filter(!.[[1]] %in% c("Almoço", "Café da manhã", "Jantar"))

cardapio <- cardapio %>%
  mutate(
    data = data_coleta,
    tipo_refeicao = case_when(
      row_number() == 1 ~ "Café da manhã",
      row_number() == 2 ~ "Almoço",
      row_number() == 3 ~ "Jantar"
    )
  )

cardapio <- relocate(cardapio,tipo_refeicao)
cardapio <- relocate(cardapio,data)

write.csv(cardapio, paste0("dados/",data_coleta, ".csv"), 
           row.names = FALSE,
           quote = TRUE,        
           na = "",              
           fileEncoding = "UTF-8") 

