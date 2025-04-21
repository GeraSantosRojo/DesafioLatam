import pandas as pd
from sqlalchemy import create_engine

def filtrar_por_fechas(df, columna, fecha_inicio, fecha_fin):
    return df[(df[columna] >= fecha_inicio) & (df[columna] <= fecha_fin)]

def generar_reporte(df, filas, columnas, valores, medida):
    return pd.pivot_table(df, values=valores, index=filas, columns=columnas, aggfunc=medida, fill_value=0)

def escribir_en_sql(df, nombre_tabla, engine, if_exists='fail'):
    df.to_sql(nombre_tabla, engine, if_exists=if_exists, index=False)