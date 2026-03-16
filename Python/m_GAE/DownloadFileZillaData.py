#!/usr/bin/env python
# coding: utf-8

# In[6]:


from ftplib import FTP_TLS
from pathlib import Path 
import json
import os
import pandas as pd
import tkinter as tk
from tkinter import messagebox


# In[7]:


from datetime import datetime


def DownFile(FechaInicial: str, usuarioSIO: str, pws: str)->str:
    # Connect to the FTP server (replace with your actual details)
    ftps  = FTP_TLS()
    ftps .connect('xmftps.xm.com.co', 210)  # default port is 210

    # Secure the control connection
    ftps .auth()
    ftps .prot_p()  # Switch to secure data connection (important!)

    ftps .login(usuarioSIO, pws)

    # Obtener mes y día de la fecha inicial
    # Transformar string en fecha
    fecha = datetime.strptime(FechaInicial, "%d/%m/%Y")

    # Obtener mes y día
    year= fecha.year
    mes = fecha.month
    dia = fecha.day

    # Navigate to the directory you want to access
    ftps.cwd(f"/INFORMACION_XM/Publico/DESPACHO/{year:04d}-{mes:02d}")

    # List files
    files = ftps.nlst()
    # print("Available files:", files)

    # Download condiciones iniciales de planta
    
    pathfile=f"C:\Informacion_XM\Publico\Despacho\{year:04d}-{mes:02d}\\"

    filename = f"dCondIniP{mes:02d}{dia:02d}.txt"
    # print(filename)
    with open(pathfile + filename, 'wb') as f:
        ftps.retrbinary(f"RETR {filename}", f.write)

    # Download condiciones iniciales de unidad
    filename = f"dCondIniU{mes:02d}{dia:02d}.txt"

    # print(filename)
    with open(pathfile + filename, 'wb') as f:
        ftps.retrbinary(f"RETR {filename}", f.write)

    ftps.quit()
    # print(f"{filename} downloaded successfully.")

    return "Finalizado"


# In[8]:


def CreateFile(FechaInicial,sPathfile)->str:

    #Leer archivo de mapeos
    spathFileMap=r'C:\Alejo\cops\Data\Mapeos.xlsx'
    mapping_df=pd.read_excel(spathFileMap,sheet_name='NomRecursos')

    fecha = datetime.strptime(FechaInicial, "%d/%m/%Y")

    # Obtener mes y día
    year= fecha.year
    mes = fecha.month
    dia = fecha.day

    # Download condiciones iniciales de planta
    
    pathfile=f"C:\Informacion_XM\Publico\Despacho\{year:04d}-{mes:02d}\\"

    filename = f"dCondIniP{mes:02d}{dia:02d}.txt"
    # print(filename)
    pathfile = pathfile + filename

    # Load the file into a dataframe
    df = pd.read_csv(pathfile, delimiter=',',header=0,encoding="ISO-8859-1")
    # df['ConfMod']= df['Conf_Pini-1'].str.split('_').str[0].fillna(0).astype(int)
  
    # Remove leading and trailing spaces from column names
    df.columns = df.columns.str.strip()

    # Eliminar filas donde la columna 'Recurso' coincide con varios strings específicos
    strings_to_remove = ['MIEL I', 'SOGAMOSO']
    df = df[~df['Planta'].isin(strings_to_remove)]
    df = df.sort_values(by='Planta')
    l_cols=list(df.columns)
    l_cols.append('RecCops')
    df=df.merge(mapping_df,left_on=['Planta'],right_on=['RecDesp'],how='left')[l_cols]
    # Save the dataframe to a JSON file
    sFile=r"CIPlanta.txt"
    output_path = os.path.join(sPathfile, sFile)
    df.to_csv(output_path, index=False)

    mapping_df=pd.read_excel(spathFileMap,sheet_name='NomUnidad')

    pathfile=f"C:\Informacion_XM\Publico\Despacho\{year:04d}-{mes:02d}\\"

    filename = f"dCondIniU{mes:02d}{dia:02d}.TXT"
    # print(filename)
    pathfile = pathfile + filename

    # Load the file into a dataframe
    df = pd.read_csv(pathfile, delimiter=',',header=0,encoding="ISO-8859-1")
    # Remove leading and trailing spaces from column names
    df.columns = df.columns.str.strip()
    
    df = df.sort_values(by='Unidad')
    l_cols=list(df.columns)
    l_cols.append('UniCops')
    df=df.merge(mapping_df,left_on=['Unidad'],right_on=['UniDespacho'],how='left')[l_cols]

    # Save the dataframe to a JSON file
    sFile=r"CIUnidad.txt"
    output_path = os.path.join(sPathfile, sFile)
    df.to_csv(output_path, index=False)

    

    return df


# In[9]:
if 1==1:
# try: 
    # Ruta del archivo
    sFile=r"Parametros.json"
    # script_dir = Path(__file__).resolve()
    # script_dir=script_dir.parent.parent.parent
    # sPathfile=os.path.join(script_dir,r"Modules\Utils\ArchivosAux",sFile)
    sPathfile=os.path.join(r"C:\Alejo\cops\Modules\Utils\ArchivosAux",sFile)
    sPathFolder=r"C:\Alejo\cops\Modules\Utils\ArchivosAux"

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
    usuarioSIO=data['Pws']['UsuarioXm']
    pws=data['Pws']['PwsXm']


    msj=DownFile(FechaInicial,usuarioSIO,pws)
    df=CreateFile(FechaInicial,sPathFolder)
    
    # Crear ventana raíz oculta
    root = tk.Tk()
    root.withdraw()
    root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano
    messagebox.showinfo('Estado del proceso','Se descargaron los archivos de condiciones iniciales', parent=root)

# except:
    
#     root = tk.Tk()
#     root.withdraw()
#     root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano
#     messagebox.showerror('Estado del proceso','Error en el proceso, por favor validar', parent=root)  


