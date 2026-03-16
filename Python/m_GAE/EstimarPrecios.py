#!/usr/bin/env python
# coding: utf-8

# In[138]:


import pandas as pd
from pathlib import Path
import os
import json
import datetime as dt
from ftplib import FTP_TLS
import tkinter as tk
from tkinter import messagebox
import csv
from openpyxl import load_workbook

root = tk.Tk()
root.withdraw()
root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano


# In[139]:


def readfileOfe(file_path):
    # Read all lines from the file
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
        
    # Initialize variables
    data = []
    current_agent = None

    # Process each line
    for line in lines:
        line = line.strip()

        if not line:
            continue  # Skip empty lines

        if line.startswith("AGENTE:"):
            current_agent = line.replace("AGENTE:", "").strip()
            continue

        parts = [x.strip() for x in line.split(",")]

        if len(parts) >= 3:
            unidad = parts[0]
            tipo = parts[1]
            valores = parts[2:]

            # Try to convert values to float; skip line if fails
            if len(valores)>6:
                valores_float = [float(v) for v in valores]
            else:
                if valores[0].replace('.', '', 1).isdigit():
                    valores_float = [float(v) for v in valores]
                else:
                    valores_float = [v for v in valores]
                

            for hora, valor in enumerate(valores_float, start=1):
                data.append({
                    "Agente": current_agent,
                    "Unidad": unidad,
                    "Tipo": tipo,
                    "Hora": hora,
                    "Valor": valor
                })

    # Convert to DataFrame
    df = pd.DataFrame(data)

    return df

# Show the first few rows (optional)
# print(df.head())

# df_filter= df[(df['Tipo'].str.match(r'^P\d+')) & (df['Unidad']=='TEBSABCC')]


# In[140]:


def readfilePINal(file_path):

    column_names = ["planta"] + [str(i) for i in range(1, 25)]

    df_csv = pd.read_csv(file_path, sep=",", names=column_names, skipinitialspace=True)

    # Convert to DataFrame
    df = df_csv

    return df


# In[141]:


def readfileiMar(file_path):

    column_names = ["item"] + [str(i) for i in range(1, 25)]

    df_csv = pd.read_csv(file_path, sep=",", names=column_names, skipinitialspace=True)

    # Convert to DataFrame
    df = df_csv

    return df


# In[142]:


# Buscar el precio de cada una de las plantas
def PreciosPlt(df):
    # Lectura de datos con los mapeos
    s_parentpath=Path('C:\Alejo\cops\Data')
    filepath=s_parentpath.joinpath(s_parentpath,'Mapeos.xlsx')


    l_sheets=['NomRecursos','RecHidraulicos','RecVariable']

    df_precios_plt=pd.DataFrame()
    df_plantas=pd.DataFrame()

    for sheet_name in l_sheets:
        
        df_pltt=pd.read_excel(filepath, header=0,sheet_name=sheet_name)
        df_plantas=pd.concat([df_plantas,df_pltt],axis=0)
        
        if sheet_name=='NomRecursos':
            # Plantas térmica
            df_plt=df_pltt[(df_pltt.TipoPlt=='CS')][['RecCops','RecOfe','TipoPlt']]
            df_plt['Poferta']=0

            df_plt.loc[df_plt['RecOfe'].str.contains('PROELECTRICA1|PROELECTRICA2', regex=True), 'RecOfe'] = 'PROELECTRICA'

        elif sheet_name=='RecHidraulicos' or sheet_name=='RecVariable':
            df_plt=df_pltt[['RecCops','RecOfe','TipoPlt']]
            df_plt['Poferta']=0
            df_plt['Confoferta']=1

        for ind in df_plt.index:
            plt=df_plt.loc[ind,'RecOfe']
            # print(plt)
            if plt in df['Unidad'].values:
                df_filter= df[(df['Unidad']==plt) & (df['Tipo']=='P')]
                if df_filter.shape[0]>0:  
                    df_filter= df[(df['Unidad']==plt) & (df['Tipo']=='P')]['Valor'].values[0]
                    df_plt.loc[ind,'Poferta']=df_filter
                else:
                    messagebox.showinfo('Información proceso de oferta',rf'El recurso {plt} no tienen precio de oferta', parent=root)
                    df_plt.loc[ind,'Poferta']=0

                if df_plt.loc[ind,'TipoPlt']=='CS':
                    df_filter= df[(df['Unidad']==plt) & (df['Tipo']=='CONF')]
                    if df_filter.shape[0]>0:  
                        df_filter= df[(df['Unidad']==plt) & (df['Tipo']=='CONF')]['Valor'].values[0]
                        df_plt.loc[ind,'Confoferta']=df_filter
                    else:
                        messagebox.showinfo('Información proceso de oferta',rf'El recurso {plt} no tienen configuración de oferta', parent=root)
                        df_plt.loc[ind,'Confoferta']=1
                else:
                    df_plt.loc[ind,'Confoferta']=0

                
            else:
                print('No se encontró la planta:', plt)

        df_precios_plt=pd.concat([df_precios_plt,df_plt],axis=0)
    
    return df_precios_plt,df_plantas


# In[143]:


def PreciosPltCC(df):
    df_precios_plt=pd.DataFrame()
    # Carga del nivel probabilístico del embalse
    s_parentpath=Path('C:\Alejo\cops\Data')
    filepath=s_parentpath.joinpath(s_parentpath,'Mapeos.xlsx')
    sheet_name='NomRecursos'
    df_pltt=pd.read_excel(filepath, header=0,sheet_name=sheet_name)
    df_plt=df_pltt[(df_pltt.TipoPlt=='CC')][['RecCops','RecOfe']]
    df_plt_final=df_plt.copy()

    for ind in df_plt.index:
        plt=df_plt.loc[ind,'RecOfe']
        if plt in df['Unidad'].values:
            df_filter = df[(df['Unidad'] == plt) & (df['Tipo'].str.startswith('P'))][['Unidad','Tipo','Valor']]
            df_plt_final = df_filter.merge(df_plt, left_on=['Unidad'],right_on=['RecOfe'], how='left')[['RecCops','RecOfe','Tipo','Valor']]
            df_plt_final['Tipo_num'] = df_plt_final['Tipo'].str.extract(r'(\d+)').astype(float)
            df_plt_final = df_plt_final.sort_values(by='Tipo_num')
            df_plt_final['Conf'] = df_plt_final['Tipo_num'].astype(int)
            df_plt_final = df_plt_final.drop(columns=['Tipo_num'])
            # df_plt_final = df_plt_final.sort_values(by='Tipo')
            # df_filter= df[(df['Unidad']==plt) & (df['Tipo']=='P')]['Valor']
        else:
            print('No se encontró la planta:', plt)

        df_precios_plt=pd.concat([df_precios_plt,df_plt_final],axis=0)
    
    return df_precios_plt


# In[144]:


def DispUni(df):
    # Lectura de datos con los mapeos
    s_parentpath=Path('C:\Alejo\cops\Data')
    filepath=s_parentpath.joinpath(s_parentpath,'Mapeos.xlsx')

    df=df[(df['Tipo']=='D')]

    l_sheets=['NomUnidad','UniHidro','UniVariable']

    df_precios_plt=pd.DataFrame()

    # --- Preprocesar df como diccionario para búsqueda rápida
    df_lookup = df.set_index(['Unidad', 'Hora'])['Valor'].to_dict()
    unidades_validas = set(df['Unidad'].unique())

    # --- Procesamiento por hoja
    for sheet_name in l_sheets:
        df_pltt = pd.read_excel(filepath, sheet_name=sheet_name)
        df_plt = df_pltt[['UniCops', 'UniOfe','Tipo']].copy()

        # Inicializar columnas D_1 a D_24
        for i in range(1, 25):
            df_plt[f'{i}'] = 0

        # Llenar valores por unidad y hora
        for ind, row in df_plt.iterrows():
            unidad = row['UniOfe']

            if unidad in unidades_validas:
                for hora in range(1, 25):
                    valor = df_lookup.get((unidad, hora), None)
                    if valor is not None:
                        df_plt.at[ind, f'{hora}'] = valor
            else:
                print(f'No se encontró la planta: {unidad}')

        # Concatenar resultados
        df_precios_plt = pd.concat([df_precios_plt, df_plt], axis=0, ignore_index=True)
        
    return df_precios_plt


# In[145]:


def DispCC(df):
    # Lectura de datos con los mapeos
    s_parentpath=Path('C:\Alejo\cops\Data')
    filepath=s_parentpath.joinpath(s_parentpath,'Mapeos.xlsx')

    df_pltt = pd.read_excel(filepath, sheet_name='NomRecursos')
    df_pltcc = df_pltt[['RecOfe','RecDesp','TipoPlt']]
    df_pltcc=df_pltcc[(df_pltcc.TipoPlt=='CC')]
    unique_plt=list(df_pltcc['RecOfe'].unique())

    df_cc = df[(df['Unidad'].isin(unique_plt)) & (df['Tipo'].str.startswith('DISCONF'))][['Unidad','Tipo','Hora','Valor']]

    df_maxConf=df_cc[(df_cc.Hora==1)]
    df_maxConf= df_maxConf.loc[df_maxConf.groupby("Unidad")["Valor"].idxmax(), ["Unidad", "Tipo", "Valor"]]

    df_precios_plt=pd.DataFrame()

    # --- Preprocesar df como diccionario para búsqueda rápida
    df_lookup = df_cc.set_index(['Unidad','Tipo','Hora'])['Valor'].to_dict()

    df_plt=df_maxConf.copy()
    df_plt=df_plt[['Unidad','Tipo']]
    # Inicializar columnas D_1 a D_24
    for i in range(1, 25):
        df_plt[f'{i}'] = 0

    # Llenar valores por unidad y hora
    for ind, row in df_maxConf.iterrows():
        unidad = row['Unidad']
        conf = row['Tipo']

        for hora in range(1, 25):
            valor = df_lookup.get((unidad,conf, hora), None)
            if valor is not None:
                df_plt.at[ind, f'{hora}'] = valor


        # Concatenar resultados
        # df_precios_plt = pd.concat([df_precios_plt, df_plt], axis=0, ignore_index=True)

    l_col=list(df_plt.columns)
    l_col.append('RecOfe')
    df_plt=df_plt.merge(df_pltcc,left_on=['Unidad'],right_on=['RecOfe'],how='inner')[l_col]

    return df_plt


# In[146]:


# Función para descargar el archivo
def DownFile(fecha_dt,UsuXM,PwsXM,Tipo):

    # Connect to the FTP server (replace with your actual details)
    ftps  = FTP_TLS()
    ftps .connect('xmftps.xm.com.co', 210)  # default port is 210

    # Secure the control connection
    ftps .auth()
    ftps .prot_p()  # Switch to secure data connection (important!)

    ftps .login(UsuXM, PwsXM)

    # Obtener mes y día de la fecha inicial
    # Transformar string en fecha
    # fecha = dt.datetime.strptime(fecha_dt, "%d/%m/%Y")

    # Obtener mes y día
    year= fecha_dt.year
    mes = fecha_dt.month
    dia = fecha_dt.day

    if Tipo=='Oferta':
        # Navigate to the directory you want to access
        ftps.cwd(rf"/INFORMACION_XM/PUBLICO/OFERTAS/INICIAL/{year:04d}-{mes:02d}")
    elif Tipo=='PINal' or Tipo=='iMar':
        ftps.cwd(rf"/INFORMACION_XM/PUBLICO/Predespachoideal/{year:04d}-{mes:02d}")
    else:
        messagebox.showinfo('Estado del proceso',f'No se reconoce el formato {Tipo}', parent=root)
        df=pd.DataFrame()
        return df


    # List files
    files = ftps.nlst()
    # print("Available files:", files)


    if Tipo=='Oferta':
        # Download condiciones iniciales de planta
        pathfile=rf"C:\Informacion_XM\PUBLICO\OFERTAS\INICIAL\{year:04d}-{mes:02d}\\"
        filename = f"OFEI{mes:02d}{dia:02d}.TXT"
    elif Tipo=='PINal' or Tipo=='iMar':
        # Download condiciones iniciales de planta
        pathfile=rf"C:\Informacion_XM\PUBLICO\Predespachoideal\{year:04d}-{mes:02d}\\"
        if Tipo=='PINal':
            filename = f"PrId{mes:02d}{dia:02d}_NAL.TXT" 
        elif Tipo=='iMar':
            filename = f"iMAR{mes:02d}{dia:02d}.TXT"       
    
    print(pathfile + filename)
    with open(pathfile + filename, 'wb') as f:
        ftps.retrbinary(f"RETR {filename}", f.write)

    ftps.quit()
    # print(f"{filename} downloaded successfully.")

    if Tipo=='Oferta':
        df=readfileOfe(pathfile + filename)
    elif Tipo=='PINal':
        df=readfilePINal(pathfile + filename)
    elif Tipo=='iMar':
        df=readfileiMar(pathfile + filename)
    
    return df


# In[148]:

if 1==1:
# try:
    # Ruta del archivo
    sFile=r"Parametros.json"
    script_dir = Path.cwd()
    script_dir=script_dir.parent.parent
    sPathfile=os.path.join(script_dir,r"Modules\Utils\ArchivosAux",sFile)
    sPathfile = os.path.join(r"C:\Alejo\cops\Modules\Utils\ArchivosAux",sFile)

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
    FechaDem=data['Parametros']['Fecha_Demanda']
    Horizon=data['Parametros']['Tipo_Ejecucion']

    # Banderas para la ejecución
    DemFile=data['BanderasFile']['CB_ArchivoDem']
    AccessFile=data['BanderasFile']['CB_ArchivoAccess']
    InfoTipoDia=data['BanderasFile']['CB_TipoDia']

    UsuXM=data['Pws']['UsuarioXm']
    PwsXM=data['Pws']['PwsXm']

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

    # Leer Mapeo planta unidad
    spathFileMap=r'C:\Alejo\cops\Data\Mapeos.xlsx'
    mapping_df=pd.read_excel(spathFileMap,sheet_name='Planta_Unidad',header=0)


    # Descargar archivo de oferta para el día 1 y obtener los precios iniciales

    # Obtener la fecha del día 1
    fecha_dt = dt.datetime.strptime(FechaInicial, "%d/%m/%Y")
    diaini = fecha_dt.day
    mesini=fecha_dt.month
    yearini=fecha_dt.year

    fecha_dt = fecha_dt.replace(day=1)

    df=DownFile(fecha_dt,UsuXM,PwsXM,Tipo='Oferta')
    df_precios,df_plantas=PreciosPlt(df)
    df_precios['Poferta'] = df_precios['Poferta'].astype(float)
    df_plantascc=list(df_plantas[(df_plantas.TipoPlt=='CC')]['RecOfe'])
    df_preciosCC=PreciosPltCC(df)
    # df_DispUni=DispUni(df)

    # Obtener interativamente la disponibilidad del archivo de ofeta desde el día 2 hasta el día acutal
    fecha_dt = fecha_dt + dt.timedelta(days=1)
    fecha_dt_fin = dt.datetime.strptime(FechaInicial, "%d/%m/%Y")
    fecha_dt_pru = fecha_dt + dt.timedelta(days=1)

    l_col1=['RecDesp','TipoPlt','Conf']
    l_per=[f'{i}' for i in range(1,25)]
    l_col1=l_col1 + l_per


    while fecha_dt<=fecha_dt_fin:

        print(fecha_dt)

        # Obtener información de archivo de precios
        df_imar=DownFile(fecha_dt,UsuXM,PwsXM,Tipo='iMar')
        # Filter the row where 'item' is 'MPO'
        df_mpo = df_imar[df_imar['item'] == 'MPO']
        # Convert columns 1 to 24 into a single column for periods and their corresponding values
        df_mpo_melted = df_mpo.melt(id_vars=["item"], var_name="Periodo", value_name="Valor")
        df_mpo_melted["Periodo"] = df_mpo_melted["Periodo"].astype(int)  # Ensure Periodo is an integer
        # Obtener los valores únicos de la columna 'Valor'
        unique_values = df_mpo_melted['Valor'].unique()
        # Filtrar el primer registro para cada valor único
        df_unique_values = df_mpo_melted.loc[df_mpo_melted.groupby('Valor').head(1).index]

        # Obtener disponiblidad de planta
        # # # Obtener disponbilidad de undiada
        df=DownFile(fecha_dt,UsuXM,PwsXM,Tipo='Oferta')
        df_DispUni=DispUni(df)
        l_col=list(df_DispUni.columns)
        l_col.append('RecDesp')
        l_col.append('TipoPlt')
        df_DispUni=df_DispUni.merge(mapping_df,left_on=['UniOfe'],right_on=['UniOfe'],how='inner')[l_col]

        # # # Agrupar por planta
        last_26_columns = list(df_DispUni.columns[-26:])
        l_per=last_26_columns[0:24]
        df_DispPlt=df_DispUni.groupby(['RecDesp','TipoPlt'])[l_per].sum().reset_index()

        # Disponibilidad por configuración
        df_DispCC=DispCC(df)

        # # # Quitar las de CC y agregar las disponibilidad de la configuración que más tenga
        l_pltcc=list(df_DispCC['RecOfe'].unique())
        df_DispPlt=df_DispPlt[~df_DispPlt['RecDesp'].isin(l_pltcc)]
        df_DispPlt['Conf']=0

        # # # Agregar la disponibidad de las plnatas de CC
        df_DispCC=df_DispCC.rename(columns={'RecOfe':'RecDesp','Tipo':'Conf'})
        df_DispCC['Conf']=df_DispCC["Conf"].str.replace(r"\D", "", regex=True).astype(int)
        df_DispCC['TipoPlt']='CC'
        df_DispCC=df_DispCC[l_col1]

        # # # Disponiblidad final
        df_DispPlt=df_DispPlt[l_col1]
        df_DispPlt=pd.concat([df_DispPlt,df_DispCC], axis=0, ignore_index=True)
        df_pltm=df_DispPlt[['RecDesp']]

        # Leer el archivo con la generación preideal
        df_pid=DownFile(fecha_dt,UsuXM,PwsXM,Tipo='PINal')

        # # # Hacer el filtro con las plantas DC
        l_col=list(df_pid.columns)
        df_pid = df_pid.merge(df_pltm,left_on=['planta'],right_on=['RecDesp'],how='inner')[l_col]

        # Encontrar los marginales
        # --- Ajustar nombres para merge ---
        df_pid = df_pid.rename(columns={"planta": "RecDesp"})

        # --- Hacemos merge para tener TipoPlt disponible en el mismo df ---
        df_merged = df_pid.merge(df_DispPlt[["RecDesp","TipoPlt","Conf"]], on="RecDesp", how="left")
        df_merged = df_merged.merge(df_plantas[["RecDesp","RecOfe"]], on="RecDesp", how="left")

        # --- Identificar columnas de horas (1 al 24) ---
        horas = [str(i) for i in range(1,25)]   # asegúrate de que en tus dfs los nombres de columnas sean string

        # --- Crear df bandera ---
        df_bandera = df_merged[["RecDesp","TipoPlt","Conf"]].copy()
        df_bandera = df_bandera.merge(df_plantas[["RecDesp", "RecOfe"]], on="RecDesp", how="left")

        for h in horas:
            cond_H = (df_merged["TipoPlt"]=="H") & (df_merged[h] > 0) & (df_merged[h] < df_DispPlt.set_index("RecDesp").loc[df_merged["RecDesp"], h].values)
            cond_CSCC = (df_merged["TipoPlt"].isin(["CS","CC"])) & (df_merged[h] > 1) & (df_merged[h] < df_DispPlt.set_index("RecDesp").loc[df_merged["RecDesp"], h].values)
            
            df_bandera[h] = 0  # inicializar
            df_bandera.loc[cond_H | cond_CSCC, h] = 1

        # result[periodo] => DataFrame con las filas que tienen 1 en ese periodo
        result = {h: df_bandera.loc[df_bandera[h] == 1, ["RecDesp","RecOfe", "TipoPlt","Conf"] + horas]
                for h in horas}

        # Actualizar precios de la planta respectiva
        for ind,row in df_unique_values.iterrows():
            periodo=row['Periodo']
            precio=row['Valor']
            df_p = result[str(periodo)]
            if df_p.shape[0]>=1:
                df_p=df_p.reset_index(drop=True)
                plt = df_p.iloc[0]['RecOfe']
                conf = df_p.iloc[0]['Conf']
                print(fecha_dt,plt,precio)
                if plt in df_plantascc:
                    df_preciosCC.loc[(df_preciosCC['RecOfe'] == plt) & (df_preciosCC['Tipo'] == f'P{conf}'), 'Valor']= precio
                else:
                    df_precios.loc[(df_precios['RecOfe'] == plt), 'Poferta']= precio
                
                if df_p.shape[0]>1:
                    messagebox.showinfo('Estado del proceso',f'Exite más de dos marginales en el periodo {periodo} del día {fecha_dt}', parent=root)
            else:
                messagebox.showinfo('Estado del proceso',f'No se encontró planta marfinal en el {periodo} del día {fecha_dt}', parent=root)

            # Evaluar los recursos que están por encima y por debajo del precio con la generación
            # Filtrar recursos que tengan precio inferior y generación igual cero (es decir son plantas que están por encima del marginal)
            # Hidráulicas
            df_plt_up=list(df_merged[(df_merged["TipoPlt"]=="H") & (df_merged[str(periodo)] <= 0) & (df_DispPlt.set_index("RecDesp").loc[df_merged["RecDesp"], str(periodo)].values>0)]['RecOfe'])
            df_plt_up=df_precios[((df_precios.Poferta<=precio) & (df_precios['RecOfe'].isin(df_plt_up)))]

            # Iterar y actualziar los precios
            precioMod=precio + 10000
            for ind,row in df_plt_up.iterrows():
                plt=row['RecOfe']
                df_precios.loc[(df_precios['RecOfe'] == plt), 'Poferta']= precioMod
                precioMod = precioMod + 5000 

            # Térmicas CS
            df_plt_up=list(df_merged[(df_merged["TipoPlt"]=="CS") & (df_merged[str(periodo)] <= 1) &  ((periodo<14) | (periodo>23)) & (df_DispPlt.set_index("RecDesp").loc[df_merged["RecDesp"], str(periodo)].values>5)]['RecOfe'])
            df_plt_up=df_precios[((df_precios.Poferta<=precio) & (df_precios['RecOfe'].isin(df_plt_up)))]

            # Iterar y actualziar los precios
            precioMod = precioMod + 5000
            for ind,row in df_plt_up.iterrows():
                plt=row['RecOfe']
                if plt=='CARTAGENA_1':
                    stop=1
                df_precios.loc[(df_precios['RecOfe'] == plt), 'Poferta']= precioMod
                precioMod = precioMod + 5000 

            # Filtrar recursos que tengan precio superior y generación mayor que la disponibilidad 
            # Hidráulicas y térmicas CS
            df_plt_up=list(df_merged[(df_merged["TipoPlt"].isin(["CS"])) & ((df_merged[str(periodo)] >= df_DispPlt.set_index("RecDesp").loc[df_merged["RecDesp"], str(periodo)].values * 0.95)) & (df_DispPlt.set_index("RecDesp").loc[df_merged["RecDesp"], str(periodo)].values>5)]['RecOfe'])
            df_plt_up=df_precios[((df_precios.Poferta>precio) & (df_precios['RecOfe'].isin(df_plt_up)))]

            # Iterar y actualziar los precios
            precioMod=precio - 10000
            for ind,row in df_plt_up.iterrows():
                plt=row['RecOfe']
                df_precios.loc[(df_precios['RecOfe'] == plt), 'Poferta']= precioMod
                precioMod = precioMod - 5000  
                
        fecha_dt = fecha_dt + dt.timedelta(days=1)

    df_precios.to_csv(os.path.join(sPathAE + f"{int(year):00d}" + "-" + f"{int(mes):02d}" ,Carpeta , f"Precios_plantas_{yearini}_{mesini}_{diaini}.csv"), index=False)
    df_preciosCC.to_csv(os.path.join(sPathAE + f"{int(year):00d}" + "-" + f"{int(mes):02d}" ,Carpeta , f"Precios_plantasCC_{yearini}_{mesini}_{diaini}.csv"), index=False)

    messagebox.showinfo('Estado del proceso','Se estimaron los precios de manera correcta', parent=root)

    

    import runpy

    if b_PrecioPlt==1:
        # Execute the script CargarPrecios.py
        print("###################################################################")
        print("############ Cargando los precios al archivo de excel #############")
        print("###################################################################")
        runpy.run_path("C:\Alejo\cops\Python\m_GAE\CargarPrecios.py")

    # if b_PrecioTPL==1:
    #     runpy.run_path("CargarPreciosTPL.py")

    

# except:

#     messagebox.showerror('Estado del proceso','Error en el proceso de estimación de precios, por favor validar', parent=root)  


# In[ ]:




