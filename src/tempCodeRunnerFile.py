import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Cargar datos
datos = pd.read_csv("../data/processed/datos_abril_evolve.csv")
# Convertir tipos
datos['FECHA'] = pd.to_datetime(datos['FECHA'], errors='coerce')
datos['AÑO'] = datos['AÑO'].astype(int)

cols_categoria = [
        'RANGO_HORARIO', 'TRAMO_EDAD', 'SEXO', 'TIPO_PERSONA', 
        'DISTRITO', 'TIPO_ACCIDENTE', 'LESIVIDAD', 'TIPO_VEHICULO', 
        'MES', 'DIA_SEMANA'
    ]
for col in cols_categoria:
        datos[col] = datos[col].astype('category')
        # Ordenar correctamente TRAMO_EDAD
orden_tramo_edad = [
    "0-5", "6-10", "11-15", "16-20", "21-25", "26-30",
    "31-35", "36-40", "41-45", "46-50", "51-55", "56-60",
    "61-65", "66-70", "71-75", "74+"
    ]
datos['TRAMO_EDAD'] = pd.Categorical(datos['TRAMO_EDAD'], categories=orden_tramo_edad, ordered=True)

print("\n ¿Que tipo de datos tengo?")
print(datos.dtypes)
    

# Agrupar para contar accidentes únicos porque la base de datos contabiliza los accidentes por cada persona involucrada
# y no por accidente
# Se considera un accidente único por fecha, rango horario y distrito
accidentes_unicos = datos.drop_duplicates(subset=['FECHA', 'RANGO_HORARIO', 'DISTRITO'])
conteo_accidentes_por_año = accidentes_unicos['AÑO'].value_counts().sort_index()
print(conteo_accidentes_por_año)



# Estadísticas básicas
print("\n📋 No tiene sentido sacar las estadísticas descriptivas numéricas ya que las unicas que tenemos son los años y la fecha:")
print(datos.describe())



# — 1. Tendencia de accidentes por año
conteo_accidentes_por_año.plot(kind='bar')
plt.title('Número de accidentes por año')
plt.xlabel('Año')
plt.ylabel('Número de accidentes')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# — 2. Conteo de accidentes por tipo
plt.figure(figsize=(12,6))
datos['TIPO_ACCIDENTE'].value_counts().plot(kind='bar')
plt.title('Número de Accidentes por Tipo de Accidente')
plt.xlabel('Tipo de Accidente')
plt.ylabel('Número de Accidentes')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# — 3. Accidentes por Día de la Semana
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

# — 4. Accidentes por Tramo de Edad
plt.figure(figsize=(12,6))
datos['TRAMO_EDAD'].value_counts().sort_index().plot(kind='bar')
plt.title('Accidentes por Tramo de Edad')
plt.xlabel('Tramo de Edad')
plt.ylabel('Número de Accidentes')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# -5. Conteo de personas involucradas en accidentes por año
conteo_por_año = datos['AÑO'].value_counts().sort_index()
print(conteo_por_año)
accidentes_por_ano = datos.groupby('AÑO').size()

plt.figure(figsize=(10,6))
accidentes_por_ano.plot(marker='o')
plt.title('Total de personas involucradas en accidentes por Año')
plt.xlabel('Año')
plt.ylabel('Número total de personas involucradas')
plt.grid(True)
plt.show()

# — 6. Accidentes por distrito

conteo_distrito = accidentes_unicos['DISTRITO'].value_counts().sort_values(ascending=False)
print("\n — Conteo de accidentes únicos por distrito —")
print(conteo_distrito)

plt.figure(figsize=(12,6))
conteo_distrito.plot(kind='bar')
plt.title("Número de accidentes únicos por distrito")
plt.xlabel("Distrito")
plt.ylabel("Número de accidentes únicos")
plt.xticks(rotation=90)
plt.tight_layout()
plt.show()

estadisticas_distrito = conteo_distrito.describe()
print("\n — Estadísticas de accidentes únicos por distrito —")
print(estadisticas_distrito)

# Número de accidentes únicos por distrito y año
accidentes_por_distrito_anyo = accidentes_unicos.groupby(['DISTRITO', 'AÑO']).size().unstack(fill_value=0)

print("\n — Número de accidentes únicos por Distrito y Año —")
print(accidentes_por_distrito_anyo)

# Estadísticas generales
estadisticas_por_anyo = accidentes_por_distrito_anyo.describe()
print("\n — Estadísticas generales de accidentes únicos por año —")
print(estadisticas_por_anyo)
