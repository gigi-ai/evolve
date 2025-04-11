# Análisis de Accidentes de Tráfico en la Comunidad de Madrid (2010-2024)

## Descripción del Proyecto

Este proyecto analiza la siniestralidad vial en la Comunidad de Madrid entre 2010 y 2024.  
Se ha llevado a cabo un proceso completo de extracción, limpieza, análisis exploratorio, inferencia estadística y visualización de los datos.

El objetivo principal es identificar patrones y tendencias relevantes en los accidentes de tráfico según variables como sexo, edad, tipo de accidente, gravedad, distrito o franja horaria.

## Preguntas de investigación

- ¿Existe una tendencia creciente o decreciente en el número de accidentes en la Comunidad de Madrid desde 2010 hasta 2024?
- ¿Qué diferencias existen en el número de accidentes entre los distintos días de la semana?
- ¿Cómo varía la gravedad de los accidentes según el distrito donde ocurren?
- ¿El perfil de los implicados en accidentes (edad y sexo) presenta patrones claros?

## Tecnologías y Herramientas Utilizadas
- Rstudio
- Python: pandas, numpy, matplotlib, seaborn, scipy, statsmodels
- Power BI: visualización de datos interactiva
- Jupyter Notebooks
- Visual Studio Code

## Estructura del Proyecto
PROYECTO_EVOLVE

├── data/        # Archivos de datos                 
│   ├── raw/            # Sin procesar              
│   └── processed/      # Procesados                
├── notebooks/          # Notebooks de análisis y pruebas               
├── dashboards/         # Archivo de Power BI               
├── src/                
│   ├── etl.py          
│   ├── eda.py           
│   └── stats.py                 
├── requirements.txt                                   
├── .gitignore      
└── README.md


## Cómo Ejecutar el Proyecto

1. Instalar las dependencias necesarias:
    ```
    pip install -r requirements.txt
    ```
2. Ejecutar el script de ETL:
    ```
    python src/etl.py
    python src/eda.py
    ```
3. Limpiar y analizar los datos mediante los notebooks:
    - notebooks/etl.ipynb
    - notebooks/eda.ipynb
    - notebooks/inferencia.ipynb
4. Visualizar el dashboard interactivo en Power BI (dashboard.pbix).

## Resumen del proyecto

Este proyecto trabaja con una base de datos de accidentalidad vial en la Comunidad de Madrid, que recoge registros anuales desde 2010 hasta 2024. Los datos anteriores a 2019 utilizaban una codificación diferente respecto a los posteriores, por lo que ha sido necesario unificar criterios y agrupar categorías similares para asegurar la coherencia del análisis. Todo el proceso de limpieza y homogeneización inicial se realizó en RStudio, cuyo archivo adjunto está incluido en el repositorio.

En cuanto al tratamiento de valores no asignados, se imputaron los valores faltantes en la variable "sexo" de manera proporcional a la distribución real de hombres y mujeres en la Comunidad de Madrid. Para el resto de variables, si en una misma fila había dos o más valores "no asignados", se optó por eliminar ese registro, ya que mantenerlo hubiese supuesto una alteración artificial de los datos. En los demás casos, los valores faltantes se mantuvieron como una categoría aparte ("NO ASIGNADO").

Posteriormente, se llevó a cabo un análisis exploratorio de datos (EDA) con tablas descriptivas, gráficos y primeras conclusiones. También se realizaron contrastes de hipótesis para explorar relaciones entre variables y cambios significativos a lo largo del tiempo, recogidos en un archivo de inferencia separado.

Finalmente, en Power BI se construyó un dashboard interactivo con diversas visualizaciones para facilitar la interpretación de los resultados y dar respuesta a las principales preguntas de investigación planteadas.

## Visualizaciones 

- Evolución del número de accidentes únicos por año por distrito.
- Accidentes por tramo de edad y sexo.
- Accidentes por año y tipo de vehiculo
- Accidentes por día de la semana.
- Gravedad del accidente por cada distrito en 2024.


![dashboard](https://github.com/user-attachments/assets/8eb8a2e1-2832-47cf-80a6-c03fff5ddfe8)

## Principales Aspectos del Análisis

- Imputación de datos faltantes en sexo basada en el censo poblacional de Madrid (46.8% hombres, 53.2% mujeres).
- Eliminación de registros con múltiples variables "NO ASIGNADO" para mejorar la calidad del análisis.
- Aplicación de tests de hipótesis no paramétricos debido a la no normalidad de los datos.
- Análisis de los efectos del COVID-19 en la siniestralidad vial.
- Estudio de diferencias en la accidentalidad por edad, tipo de vehículo y distrito.


## Resultados principales 

- Se observa una tendencia creciente general en el número de accidentes entre 2010 y 2024, especialmente después de la pandemia, aunque con un descenso puntual en 2020 debido al confinamiento. Gran parte de este aumento se debe al incremento del uso de patinetes eléctricos.
- Se detecta un mayor número de accidentes los viernes, seguido de los jueves y miércoles, con un descenso durante el fin de semana.
- Existen diferencias claras: algunos distritos como Salamanca, Chamartín y Puente de Vallecas presentan mayor número de accidentes graves respecto a otros. Probablemente debido al gran transito de la zona. 
- El grupo de edad de 26 a 40 años concentra la mayor parte de los accidentes, y en términos de sexo, los hombres están involucrados en una mayor proporción.

## Autor

- Nombre: [Daniel Giraldo]
- Fecha: Abril 2025

