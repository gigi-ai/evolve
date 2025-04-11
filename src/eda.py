import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def cargar_datos(path):
    datos = pd.read_csv(path)
    datos['FECHA'] = pd.to_datetime(datos['FECHA'], errors='coerce')
    datos['AÑO'] = datos['AÑO'].astype(int)
    cols_categoria = [
        'RANGO_HORARIO', 'TRAMO_EDAD', 'SEXO', 'TIPO_PERSONA', 
        'DISTRITO', 'TIPO_ACCIDENTE', 'LESIVIDAD', 'TIPO_VEHICULO', 
        'MES', 'DIA_SEMANA'
    ]
    for col in cols_categoria:
        datos[col] = datos[col].astype('category')
    orden_tramo_edad = [
        "0-5", "6-10", "11-15", "16-20", "21-25", "26-30",
        "31-35", "36-40", "41-45", "46-50", "51-55", "56-60",
        "61-65", "66-70", "71-75", "74+"
    ]
    datos['TRAMO_EDAD'] = pd.Categorical(datos['TRAMO_EDAD'], categories=orden_tramo_edad, ordered=True)
    return datos

def accidentes_unicos(datos):
    return datos.drop_duplicates(subset=['FECHA', 'RANGO_HORARIO', 'DISTRITO'])

def plot_accidentes_por_ano(conteo):
    conteo.plot(kind='bar')
    plt.title('Número de accidentes por año')
    plt.xlabel('Año')
    plt.ylabel('Número de accidentes')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

def plot_accidentes_por_tipo(datos):
    plt.figure(figsize=(12,6))
    datos['TIPO_ACCIDENTE'].value_counts().plot(kind='bar')
    plt.title('Número de Accidentes por Tipo de Accidente')
    plt.xlabel('Tipo de Accidente')
    plt.ylabel('Número de Accidentes')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

def plot_accidentes_por_dia_semana(datos):
    plt.figure(figsize=(8,6))
    dias = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    datos['DIA_SEMANA'] = pd.Categorical(datos['DIA_SEMANA'], categories=dias, ordered=True)
    datos['DIA_SEMANA'].value_counts().sort_index().plot(kind='bar')
    plt.title('Accidentes por Día de la Semana')
    plt.xlabel('Día de la Semana')
    plt.ylabel('Número de Accidentes')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

def plot_accidentes_por_tramo_edad(datos):
    plt.figure(figsize=(12,6))
    datos['TRAMO_EDAD'].value_counts().sort_index().plot(kind='bar')
    plt.title('Accidentes por Tramo de Edad')
    plt.xlabel('Tramo de Edad')
    plt.ylabel('Número de Accidentes')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

def plot_personas_involucradas(datos):
    accidentes_por_ano = datos.groupby('AÑO').size()
    plt.figure(figsize=(10,6))
    accidentes_por_ano.plot(marker='o')
    plt.title('Total de personas involucradas en accidentes por Año')
    plt.xlabel('Año')
    plt.ylabel('Número total de personas involucradas')
    plt.grid(True)
    plt.show()

def plot_accidentes_por_distrito(accidentes_unicos):
    conteo_distrito = accidentes_unicos['DISTRITO'].value_counts().sort_values(ascending=False)
    plt.figure(figsize=(12,6))
    conteo_distrito.plot(kind='bar')
    plt.title("Número de accidentes únicos por distrito")
    plt.xlabel("Distrito")
    plt.ylabel("Número de accidentes únicos")
    plt.xticks(rotation=90)
    plt.tight_layout()
    plt.show()
    return conteo_distrito

def resumen_estadisticas(accidentes_unicos):
    return accidentes_unicos.groupby(['DISTRITO', 'AÑO']).size().unstack(fill_value=0).describe()
