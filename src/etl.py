import pandas as pd
import numpy as np

def run_etl():
    print("Cargando datos finales (CSV)...")
    datos = pd.read_csv("../data/processed/datos_completos.csv")

    print("\nPrimeras filas de datos:")
    print(datos.head())
    # —— 1. Imputar proporcionalmente en 'sexo' —— https://www.madrid.es/UnidadesDescentralizadas/UDCEstadistica/Nuevaweb/Demografía%20y%20población/Cifras%20de%20población/PMH/Avance/POBLACIÓN%202024_v1.pdf

    prop_hombres = 0.468 
    prop_mujeres = 0.532
    
    if 'sexo' in datos.columns:
    
        mask_sexo = datos['SEXO'].astype(str).str.strip() == "NO ASIGNADO"
        num_no_asignado_sexo = mask_sexo.sum()
        
        if num_no_asignado_sexo > 0:
            print(f"\nImputando {num_no_asignado_sexo} valores 'NO ASIGNADO' en 'sexo'...")
            
            imputaciones = np.random.choice(
                ['HOMBRE', 'MUJER'], 
                size=num_no_asignado_sexo, 
                p=[prop_hombres, prop_mujeres]
            )
            datos.loc[mask_sexo, 'sexo'] = imputaciones
    # —— 2. Eliminar filas con "NO ASIGNADO" en >1 columna ——

    print("\nFiltrando filas con 'NO ASIGNADO' en múltiples columnas...")
        # Contar "NO ASIGNADO" por fila

    no_asignado_counts = datos.astype(str).apply(
        lambda x: x.str.contains("NO ASIGNADO", na=False), 
        axis=1
    ).sum(axis=1)
    
    datos_limpios = datos[no_asignado_counts <= 1].copy()
    
    filas_eliminadas = datos[no_asignado_counts > 1]
    
    datos_limpios.to_csv("../data/processed/datos_abril_evolve.csv", index=False)
    
    print("\n✅ Resultados:")
    print(f"- Registros originales: {datos.shape[0]}")
    print(f"- Registros conservados: {datos_limpios.shape[0]}")
    print(f"- Registros eliminados (por >1 'NO ASIGNADO'): {filas_eliminadas.shape[0]}")
    
    return datos, datos_limpios, filas_eliminadas
