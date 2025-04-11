library(readxl)   # Para leer archivos Excel
library(dplyr)    # Para manipulación de datos
library(purrr)    # Para iterar sobre hojas y archivos
library(ggplot2)  # Para gráficos
library(stringr)
library(openxlsx)
library(tidyr)
library(lubridate)

# Definir la ruta donde están los archivos
ruta <- "/Users/giraald/Desktop/EVOLVE/abril"

# Filtrar solo los archivos de accidentalidad (regex) "20XX_Accidentalidad.xlsx"
archivos <- list.files(path = ruta, pattern = "^20\\d{2}_Accidentalidad\\.xlsx$", full.names = TRUE)

# Creo una lista vacía para almacenar los dataframes
lista_datos <- list()

# Leer cada archivo y almacenarlo en la lista
for (archivo in archivos) {
  nombre <- gsub(".xlsx", "", basename(archivo))  
  df <- read_excel(archivo)
  
  # todo a minusculas para no tener problemas
  colnames(df) <- tolower(colnames(df))
  
  lista_datos[[nombre]] <- df
}


names(lista_datos)  # lista de los nombres de los archivos cargados (accidentes
#desde 2010 hasta 2024)


head(lista_datos$'2020_Accidentalidad')# Muestra las primeras filas del archivo 2010_Accidentalidad

#############
#AGRUPACIONES
#############


#lista vacía para almacenar los dataframes procesados
lista_datos_limpios <- list()

#esta función es para convertir "hora" en "RANGO_HORARIO" en formato "9-10", "19-20", etc.
#ya que está en formato 23:00:00, 01:15:00, etc

convertir_a_rango <- function(valor) {
  if (is.na(valor)) return(NA)
  h <- if (inherits(valor, "POSIXct")) hour(valor) else as.numeric(str_extract(valor, "\\d{1,2}"))
  if (!is.na(h)) paste0(h, "-", h + 1) else NA
}

# Nombres correctos para renombrar
nombres_correctos <- list(
  "tipo_accidente" = c("tipo accidente", "tipo_accidente"),
  "tipo_persona" = c("tipo persona", "tipo_persona"),
  "tipo_vehiculo" = c("tipo vehiculo", "tipo_vehiculo"),
  "tramo_edad" = c("tramo edad", "rango_edad")
)

# Columnas deseadas y orden
columnas_deseadas <- c("fecha", "rango_horario", "tramo_edad", "sexo", 
                       "tipo_persona", "distrito", "tipo_accidente", 
                       "lesividad", "tipo_vehiculo")

# Lista para guardar resultados
lista_datos_limpios <- list()

# Iterar sobre archivos
for (archivo in archivos) {
  nombre <- gsub(".xlsx", "", basename(archivo))
  df <- read_excel(archivo)
  
  # Normalizar nombres
  colnames(df) <- tolower(trimws(colnames(df)))
  
  # Renombrar columnas si hace falta
  for (col in names(nombres_correctos)) {
    nombre_correcto <- nombres_correctos[[col]][nombres_correctos[[col]] %in% colnames(df)][1]
    if (!is.na(nombre_correcto)) {
      df <- df %>% rename(!!col := all_of(nombre_correcto))
    } else {
      df[[col]] <- NA
    }
  }
  
  # Crear o limpiar rango_horario
  if ("hora" %in% colnames(df)) {
    df <- df %>% mutate(rango_horario = map_chr(hora, convertir_a_rango))
  } else if ("rango horario" %in% colnames(df)) {
    df <- df %>%
      rename(rango_horario = `rango horario`) %>%
      mutate(rango_horario = map_chr(rango_horario, convertir_a_rango))
  }
  
  # Asegurar columnas deseadas
  for (col in columnas_deseadas) {
    if (!(col %in% colnames(df))) {
      df[[col]] <- NA
    }
  }
  
  # Seleccionar columnas en orden
  df_limpio <- df %>% select(all_of(columnas_deseadas))
  
  # Guardar
  lista_datos_limpios[[nombre]] <- df_limpio
}

# Ver ejemplo
lista_datos_limpios$'2012_Accidentalidad'
lista_datos_limpios$'2023_Accidentalidad'


# recodificamos todo de la misma fomra. por ejemplo a partir de 2019 lo ponemos todo en función de HL,...
# ademas los Na los ponemos como No asignado.
# tambien 

recodificacion <- c(
  "Ingreso superior a 24 horas" = "HG",
  "Fallecido 24 horas" = "MT",
  "Asistencia sanitaria sólo en el lugar del accidente" = "HL",
  "Asistencia sanitaria ambulatoria con posterioridad" = "HL",
  "Asistencia sanitaria inmediata en centro de salud o mutua" = "HL",
  "Atención en urgencias sin posterior ingreso" = "HL",
  "Ingreso inferior o igual a 24 horas" = "HL",
  "Sin asistencia sanitaria" = "IL",
  "Se desconoce" = "NO ASIGNADO",
  "NULL" = "NO ASIGNADO"
)
lapply(lista_datos_limpios, function(x) {
  x[!complete.cases(x), ]
})
# Creo una copia de los datos sin modificar lista_datos_limpios para hacer cambios
datos_evolve <- lista_datos_limpios
table(lista_datos_limpios$`2024_Accidentalidad`$lesividad, useNA = "always")
table(lista_datos_limpios$`2024_Accidentalidad`$tipo_vehiculo, useNA = "always")
lapply(datos_evolve, function(x) {
  x[!complete.cases(x), ]
})
# Aplicar recodificación solo a los años >= 2019 que son los que no están como HL,IL.. ademas de poner como "No asignados" a los NA
datos_evolve[names(datos_evolve) >= "2019_Accidentalidad"] <- 
  lapply(datos_evolve[names(datos_evolve) >= "2019_Accidentalidad"], function(df) {
    df %>%
      mutate(
        lesividad = recode(lesividad, !!!recodificacion) %>% replace_na("NO ASIGNADO"),
        tipo_vehiculo = replace_na(tipo_vehiculo, "NO ASIGNADO"),
        tipo_accidente = replace_na(tipo_accidente, "NO ASIGNADO")
      ) 
  })


lapply(datos_evolve, function(x) {
  x[!complete.cases(x), ]
})

# Convertir nombres de columnas a mayúsculas y valores, sin alterar el orden
datos_evolve <- lapply(datos_evolve, function(df) {
  df %>%
    rename_with(~toupper(.)) %>%  # Convertir nombres de columnas a mayúsculas
    mutate(across(where(is.character), ~ str_to_upper(.)))  # Convertir valores a mayúsculas solo en columnas de texto
})
#desde el 2010 al 2019 no llevan tilde los distritos y >=2019 si. Decido quitar las tildes para que sea homogeneo
#ademas ponemos el distrito de SAN BLAS como SAN BLAS-CANILLEJAS para tenerlo igual en todos los años
# limpiar_distritos <- function(x) {
#   x %>%
#     str_to_upper() |> 
#     iconv(to = "ASCII//TRANSLIT") |> 
#     str_replace_all("[^[:alnum:][:space:]-]", "") |> 
#     ifelse(. == "NULL" | is.na(.), "NO ASIGNADO", .) |> 
#     str_replace("^SAN BLAS$", "SAN BLAS-CANILLEJAS")
# }
# 
# datos_evolve <- lapply(datos_evolve, function(df) {
#   df %>%
#     mutate(
#       DISTRITO = limpiar_distritos(DISTRITO)
#     )
# })
limpiar_distritos <- function(x) {
  x <- x %>%
    str_to_upper() %>% 
    iconv(to = "ASCII//TRANSLIT") %>% 
    str_replace_all("[^[:alnum:][:space:]-]", "")
  
  x <- ifelse(x == "NULL" | is.na(x), "NO ASIGNADO", x)
  x <- str_replace(x, "^SAN BLAS$", "SAN BLAS-CANILLEJAS")
  
  return(x)
}

datos_evolve <- lapply(datos_evolve, function(df) {
  df %>%
    mutate(
      DISTRITO = limpiar_distritos(DISTRITO)
    )
})
# Ver nombres después de la conversión
unique(datos_evolve$`2020_Accidentalidad`$LESIVIDAD)
unique(datos_evolve$`2013_Accidentalidad`$LESIVIDAD)
unique(datos_evolve$`2013_Accidentalidad`$DISTRITO)
unique(datos_evolve$`2020_Accidentalidad`$DISTRITO)
#decido cambiar "NO ASIGNADA" por "NO ASIGNADO" para que sea más homogéneo en los años entre 2010 y 2019
datos_evolve[names(datos_evolve) < "2019_Accidentalidad"] <- 
  lapply(datos_evolve[names(datos_evolve) < "2019_Accidentalidad"], function(df) {
    df %>%
      mutate(
        LESIVIDAD = if_else(LESIVIDAD == "NO ASIGNADA", "NO ASIGNADO", LESIVIDAD)
      )
  })



# 1.recodificación de tipo de accidente
recodificacion_accidente <- c(
  "ATROPELLO A PERSONA" = "ATROPELLO",
  "CHOQUE CONTRA OBSTÁCULO FIJO" = "CHOQUE CON OBJETO FIJO",
  "COLISIÓN LATERAL" = "COLISIÓN DOBLE",
  "COLISIÓN FRONTO-LATERAL" = "COLISIÓN DOBLE",
  "COLISIÓN FRONTAL" = "COLISIÓN DOBLE",
  "COLISIÓN MÚLTIPLE" = "COLISIÓN MÚLTIPLE",
  "OTRO" = "OTRAS CAUSAS",
  "ALCANCE" = "COLISIÓN DOBLE",
  "VUELCO" = "VUELCO",
  "ATROPELLO A ANIMAL" = "OTRAS CAUSAS",
  "SOLO SALIDA DE LA VÍA" = "OTRAS CAUSAS",
  "DESPEÑAMIENTO" = "OTRAS CAUSAS"
)

# Nueva agrupación de vehículos 
agrupacion_vehiculo <- c(
  "TURISMO" = "Turismos", "AUTO-TAXI" = "Turismos", "TODO TERRENO" = "Turismos",
  "MOTOCICLETA" = "Motos y Ciclomotores", "CICLOMOTOR" = "Motos y Ciclomotores",
  "CICLOMOTOR DE DOS RUEDAS L1E-B" = "Motos y Ciclomotores", "CICLO DE MOTOR L1E-A" = "Motos y Ciclomotores",
  "MOTO DE TRES RUEDAS HASTA 125CC" = "Motos y Ciclomotores", "MOTO DE TRES RUEDAS > 125CC" = "Motos y Ciclomotores",
  "BICICLETA" = "Bicicletas y Patinetes", "BICICLETA EPAC (PEDALEO ASISTIDO)" = "Bicicletas y Patinetes",
  "PATINETE" = "Bicicletas y Patinetes", "PATINETE NO ELÉCTRICO" = "Bicicletas y Patinetes", "VMU ELÉCTRICO" = "Bicicletas y Patinetes",
  "CAMIÓN" = "Vehículos Pesados", "CAMIÓN DE BOMBEROS" = "Vehículos Pesados", "TRACTOCAMIÓN" = "Vehículos Pesados",
  "REMOLQUE" = "Vehículos Pesados", "SEMIREMOLQUE" = "Vehículos Pesados", "FURGONETA" = "Vehículos Pesados",
  "AUTOBÚS" = "Transporte Público", "AUTOBÚS EMT" = "Transporte Público", "AUTOBÚS ARTICULADO" = "Transporte Público",
  "AUTOBÚS ARTICULADO EMT" = "Transporte Público", "AUTOBUS-AUTOCAR" = "Transporte Público", "TRANVÍA" = "Transporte Público",
  "TREN/METRO" = "Transporte Público",
  "AMBULANCIA" = "Especiales y Maquinaria", "AMBULANCIA SAMUR" = "Especiales y Maquinaria",
  "MAQUINARIA AGRÍCOLA" = "Especiales y Maquinaria", "MAQUINARIA DE OBRAS" = "Especiales y Maquinaria",
  "NO ASIGNADO" = "Otros y Desconocidos", "VARIOS" = "Otros y Desconocidos",
  "OTROS VEHÍCULOS CON MOTOR" = "Otros y Desconocidos", "OTROS VEHÍCULOS SIN MOTOR" = "Otros y Desconocidos",
  "CUADRICICLO LIGERO" = "Otros y Desconocidos", "CUADRICICLO NO LIGERO" = "Otros y Desconocidos",
  "CARAVANA" = "Otros y Desconocidos"
)

# Recodificación de tipo de persona
recodificacion_persona <- c(
  "PASAJERO" = "VIAJERO",
  "PEATÓN" = "PEATÓN",
  "CONDUCTOR" = "CONDUCTOR"
)

# Aplicar todas las recodificaciones en un solo paso
datos_evolve <- lapply(datos_evolve, function(df) {
  df %>%
    mutate(
      # Recodificar tipo de accidente
      TIPO_ACCIDENTE = case_when(
        TIPO_ACCIDENTE %in% names(recodificacion_accidente) ~ unlist(recodificacion_accidente[TIPO_ACCIDENTE]),
        TIPO_ACCIDENTE == "CAÍDA" & TIPO_VEHICULO %in% c("Motos y Ciclomotores") ~ "CAÍDA MOTOCICLETA",
        TIPO_ACCIDENTE == "CAÍDA" & TIPO_VEHICULO == "BICICLETAS" ~ "CAÍDA BICICLETA",
        TRUE ~ TIPO_ACCIDENTE
      ),
      
      TIPO_VEHICULO = case_when(
        TIPO_VEHICULO %in% names(agrupacion_vehiculo) ~ unlist(agrupacion_vehiculo[TIPO_VEHICULO]),
        TRUE ~ TIPO_VEHICULO
      ),
      
      TIPO_PERSONA = case_when(
        TIPO_PERSONA %in% names(recodificacion_persona) ~ unlist(recodificacion_persona[TIPO_PERSONA]),
        TRUE ~ TIPO_PERSONA
      )
    )
})

unique(datos_evolve$`2013_Accidentalidad`$TIPO_VEHICULO)
unique(datos_evolve$`2022_Accidentalidad`$TIPO_VEHICULO)
# Verificar la recodificación en un año de prueba (2020)
table(datos_evolve$"2020_Accidentalidad"$TIPO_ACCIDENTE)
table(datos_evolve$"2020_Accidentalidad"$TIPO_VEHICULO)
table(datos_evolve$"2020_Accidentalidad"$TIPO_PERSONA)



library(purrr)
# Función para transformar cada tibble
procesar_datos <- function(df) {
  df %>%
    mutate(
      FECHA = as.Date(FECHA),  # Asegurar formato de fecha
      AÑO = year(FECHA),       # Extraer el año
      MES = month(FECHA, label = TRUE, abbr = FALSE),  # Nombre del mes
      DIA_SEMANA = wday(FECHA, label = TRUE, abbr = FALSE)  # Nombre del día de la semana
    )
}

# Aplicar la función a cada tibble dentro de la lista
datos_evolve <- map(datos_evolve, procesar_datos)
head(datos_evolve$"2024_Accidentalidad")

datos_completos <- bind_rows(datos_evolve)
datos_completos <- datos_completos %>%
  mutate(
    SEXO = as.factor(SEXO),
    DISTRITO = as.factor(DISTRITO),
    TIPO_PERSONA = as.factor(TIPO_PERSONA),
    TIPO_ACCIDENTE = as.factor(TIPO_ACCIDENTE),
    LESIVIDAD = factor(datos_completos$LESIVIDAD, 
                       levels = c("NO ASIGNADO", "IL", "HL", "HG", "MT"),
                       ordered = TRUE), 
    TIPO_VEHICULO = as.factor(TIPO_VEHICULO),
    RANGO_HORARIO = factor(RANGO_HORARIO, ordered = TRUE)  # Horas ordenadas
  )
tabla<-datos_completos %>% 
  filter(if_any(everything(), is.na)) #para ver si hay algun valor NA después de la unión


# Normalizar el texto y eliminar espacios extra
datos_completos <- datos_completos %>%
  mutate(TRAMO_EDAD = str_trim(toupper(TRAMO_EDAD))) %>%  # Convertir a mayúsculas y quitar espacios
  mutate(TRAMO_EDAD = case_when(
    TRAMO_EDAD %in% c("DE 0 A 4 AÑOS", "DE 0 A 5 AÑOS","Menor de 5 años") ~ "0-5",
    TRAMO_EDAD %in% c("DE 5 A 9 AÑOS","DE 6 A 9 AÑOS")~ "6-10",
    TRAMO_EDAD == "DE 10 A 14 AÑOS" ~ "11-15",
    TRAMO_EDAD == "DE 15 A 17 AÑOS" ~ "16-20",
    TRAMO_EDAD == "DE 18 A 20 AÑOS" ~ "16-20",
    TRAMO_EDAD == "DE 21 A 24 AÑOS" ~ "21-25",
    TRAMO_EDAD == "DE 25 A 29 AÑOS" ~ "26-30",
    TRAMO_EDAD %in% c("DE 30 A 34 AÑOS","DE 30 A 34 ANOS") ~ "31-35",
    TRAMO_EDAD == "DE 35 A 39 AÑOS" ~ "36-40",
    TRAMO_EDAD == "DE 40 A 44 AÑOS" ~ "41-45",
    TRAMO_EDAD == "DE 45 A 49 AÑOS" ~ "46-50",
    TRAMO_EDAD == "DE 50 A 54 AÑOS" ~ "51-55",
    TRAMO_EDAD == "DE 55 A 59 AÑOS" ~ "56-60",
    TRAMO_EDAD == "DE 60 A 64 AÑOS" ~ "61-65",
    TRAMO_EDAD == "DE 65 A 69 AÑOS" ~ "66-70",
    TRAMO_EDAD == "DE 70 A 74 AÑOS" ~ "71-75",
    TRAMO_EDAD %in% c("DE MAS DE 74 AÑOS","MÁS DE 74 AÑOS") ~ "74+",
    TRAMO_EDAD %in% c("DESCONOCIDO","DESCONOCIDA")~ "NO ASIGNADO",
    TRUE ~ "NO ASIGNADO"  # Para manejar valores que no encajan
  ))
#la cosa es que en 2010 por ejemplo en algunos tramos de edad son distintos a los demas como de 30 a 34 anos pone o de 6 a 9 años..


# Convertir en factor para asegurar consistencia
datos_completos <- datos_completos %>%
  mutate(TRAMO_EDAD = as.factor(TRAMO_EDAD))

# Verificar los valores únicos después de la transformación
table(datos_completos$TRAMO_EDAD)
table(datos_completos$TIPO_PERSONA)
table(datos_completos$TIPO_ACCIDENTE) #tras observar la tabla, considero oportuno
#resumir mas la informacion del tipo de accidente
table(datos_completos$SEXO) 
table(datos_completos$TIPO_VEHICULO) 

#columna de tipo de accidente resumido

datos_completos <- datos_completos %>%
  mutate(TIPO_ACCIDENTE = case_when(
    TIPO_ACCIDENTE == "ATROPELLO" ~ "Atropello",
    TIPO_ACCIDENTE %in% c("CAÍDA", "CAÍDA BICICLETA", "CAÍDA CICLOMOTOR", 
                          "CAÍDA MOTOCICLETA", "CAÍDA VEHÍCULO 3 RUEDAS", 
                          "CAÍDA VIAJERO BUS") ~ "Caída",
    TIPO_ACCIDENTE %in% c("COLISIÓN DOBLE", "COLISIÓN MÚLTIPLE") ~ "Colisión",
    TIPO_ACCIDENTE == "CHOQUE CON OBJETO FIJO" ~ "Choque con objeto",
    TIPO_ACCIDENTE %in% c("VUELCO", "OTRAS CAUSAS") ~ "Vuelco/Otros",
    TRUE ~ "NO ASIGNADO"
  )) %>%
  mutate(TIPO_ACCIDENTE = as.factor(TIPO_ACCIDENTE))  # Convertir en factor
library(forcats)

datos_completos <- datos_completos %>%
  # 1. Cambiar "DESCONOCIDO" por "NO ASIGNADO" en SEXO
  mutate(SEXO = fct_recode(SEXO, "NO ASIGNADO" = "DESCONOCIDO")) %>%
  
  # 2.Eliminar completamente las filas donde TIPO_PERSONA sea "NULL"
  filter(TIPO_PERSONA != "NULL") %>%
  mutate(TIPO_PERSONA = fct_drop(TIPO_PERSONA)) %>%  # Eliminar el nivel "NULL"
  
  # 3. Cambiar "NULL" por "SIN ESPECIFICAR" en TIPO_VEHICULO
  mutate(TIPO_VEHICULO = fct_recode(TIPO_VEHICULO, "SIN ESPECIFICAR" = "NULL")) %>%
  
  # 4. Eliminar filas con "CICLOMOTOR DE TRES RUEDAS" y "MICROBÚS <= 17 PLAZAS" en TIPO_VEHICULO
  #porque he observado que el número de estos es muy bajo
  filter(!(TIPO_VEHICULO %in% c("CICLOMOTOR DE TRES RUEDAS", "MICROBÚS <= 17 PLAZAS"))) %>%
  mutate(TIPO_VEHICULO = fct_drop(TIPO_VEHICULO))  # Eliminar niveles vacíos después del filtro

# Verificar que los cambios se aplicaron correctamente
table(datos_completos$SEXO)
table(datos_completos$TIPO_PERSONA)  # Aquí ya no debería aparecer "NULL"
table(datos_completos$TIPO_VEHICULO) #prefiero agrupar más aún.

datos_completos <- datos_completos %>%
  mutate(TIPO_VEHICULO = case_when(
    TIPO_VEHICULO %in% c("Turismos") ~ "Turismos",
    TIPO_VEHICULO %in% c("Motos y Ciclomotores", "MOTOCICLETA > 125CC", "MOTOCICLETA HASTA 125CC") ~ "Motos y Ciclomotores",
    TIPO_VEHICULO %in% c("CAMION", "CAMIÓN RÍGIDO", "Vehículos Pesados", "VEHÍCULO ARTICULADO") ~ "Vehículos Pesados",
    TIPO_VEHICULO %in% c("AUTOBUS EMT", "Transporte Público") ~ "Transporte Público",
    TIPO_VEHICULO %in% c("Bicicletas y Patinetes", "CICLO") ~ "Bicicletas y Patinetes",
    TIPO_VEHICULO %in% c("SIN ESPECIFICAR", "Otros y Desconocidos", "Especiales y Maquinaria", "VEH.3 RUEDAS", "AUTOCARAVANA") ~ "Otros",
    is.na(TIPO_VEHICULO) | TIPO_VEHICULO == "" ~ "NO ASIGNADO", #porque he visto tenia NA
    TRUE ~ TIPO_VEHICULO,
  )) %>%
  mutate(TIPO_VEHICULO = as.factor(TIPO_VEHICULO))  # Convertir en factor
sum(is.na(datos_completos)) 

#para finalizar, lo exporto a un excel.
ruta_salida <- "/Users/giraald/Desktop/EVOLVE/abril/datos_completos.xlsx"
write.xlsx(datos_completos, file = ruta_salida, rownames = FALSE)
write.csv(datos_completos, "/Users/giraald/miniconda3/envs/proyecto_evolve/data/processed/datos_completos.csv", row.names = FALSE)

