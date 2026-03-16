#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Librerias
import warnings

warnings.filterwarnings('ignore')
warnings.simplefilter('ignore')

import pandas as pd
from pathlib import Path
import datetime as dt
import numpy as np
import os
import matplotlib.pyplot as plt
import seaborn as sns
import json

from google.cloud import bigquery
from google.oauth2 import service_account

import tkinter as tk
from tkinter import messagebox
import shutil

delta=dt.timedelta(days=1)


# In[2]:


def Precios_Tebsa(s_FechaIni):
    # Información del proyecto y autenticación a BQ
    project_id = "enersinc-tbsg-bq"
    key_path = "C:\BigQuery\eramirez-tbsg.json"

    # Cargar las credenciales del archivo JSON
    credentials = service_account.Credentials.from_service_account_file(key_path)

    # Crear el cliente de BigQuery
    client = bigquery.Client(project=project_id, credentials=credentials)

    d_FechaIni=dt.datetime.strptime(s_FechaIni, '%d/%m/%Y').strftime('%Y-%m-%d')
    d_FechaIni = str(d_FechaIni)

    # Consulta a la maestra de recursos
    query = """
    select t1.planta, t1.concepto, t1.precio
    from 
    (select planta, concepto, hora1/1000 as precio, IF(LENGTH(SUBSTR(concepto, 2)) > 0, SAFE_CAST(SUBSTR(concepto, 2) AS INT64), 1) AS concepto_num
    from tbsg.private_oferta_ori
    where fechaoperacion = 'd_FechaIni' and concepto like 'P%') t1
    order by t1.planta, t1.concepto_num 
    """

    query = query.replace('d_FechaIni', d_FechaIni)

    # Ejecutar la consulta
    df_Precio = client.query(query).to_dataframe()

    return df_Precio


# In[3]:
if 1==1:
# try:
    # Ruta del archivo
    # script_dir = Path(__file__).resolve()
    # script_dir=script_dir.parent.parent.parent
    # sPathfile=os.path.join(script_dir,r"Modules\Utils\ArchivosAux",sFile)
    sPathFolder=r"C:\Alejo\cops\Modules\Utils\ArchivosAux"

    sFile=r"Parametros.json"
    sPathfile=os.path.join(sPathFolder,sFile)

    # Open and load the JSON file
    with open(sPathfile,'r') as f:
        data = json.load(f)

    # Almancenar los parámetros en variables python
    year=data['Parametros']['Ano']
    mes=data['Parametros']['Mes']
    Carpeta=data['Parametros']['Carpeta']
    FechaInicial=data['Parametros']['Fecha_Inicial']
    FechaFinal=data['Parametros']['Fecha_Final']
    FileName=data['Parametros']['Nombre_Archivo']

    sPathAE=data['Paths']['AEnerPath']

        # Banderas carga de precios
    b_PrecioPlt=data['BanderasLoadPrecios']['CB_LoadPrecios']
    b_PrecioTPL=data['BanderasLoadPrecios']['CB_LoadPreciosTPL']

    if b_PrecioPlt=='Verdadero':
        b_PrecioPlt=1
    else:
        b_PrecioPlt=0

    if b_PrecioTPL=='Verdadero':
        b_PrecioTPL=1
    else:
        b_PrecioTPL=0

        
    fecha_dt = dt.datetime.strptime(FechaInicial, "%d/%m/%Y")
    diaini = fecha_dt.day
    mesini=fecha_dt.month
    yearini=fecha_dt.year

    df_Precio =Precios_Tebsa(FechaInicial)


    # In[4]:

    df_Precio['planta']=df_Precio['planta'].str.replace(" ", "", regex=False)

    df_Precio.to_csv(os.path.join(sPathAE + f"{int(year):00d}" + "-" + f"{int(mes):02d}" ,Carpeta , f"Precios_TPL_{yearini}_{mesini}_{diaini}.csv"), index=False)


    import runpy

    if b_PrecioTPL==1:
        runpy.run_path("C:\Alejo\cops\Python\m_GAE\CargarPreciosTPL.py")

    # Crear ventana raíz oculta
    root = tk.Tk()
    root.withdraw()
    root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano
    messagebox.showinfo('Estado del proceso','Se descargó el archivo de precios corretamente', parent=root)

# except:

#     root = tk.Tk()
#     root.withdraw()
#     root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano
#     messagebox.showerror('Estado del proceso','Error en el proceso, por favor validar', parent=root)   
