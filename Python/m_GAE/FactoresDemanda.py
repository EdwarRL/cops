#!/usr/bin/env python
# coding: utf-8

# In[ ]:


# Library import

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

from ftplib import FTP_TLS
import tkinter as tk
from tkinter import messagebox

from datetime import datetime

import json

delta=dt.timedelta(days=1)


# In[11]:


# Función para asignar los días de la semana a cada fecha, si es festivo se trata como un domingo
import holidays
co_holidays = holidays.Colombia()

def typedays(row,tipo):

     if tipo=='WeekDay':
          return row['Fecha'].weekday()

     elif tipo=='WeekMonth':
          return (row['Fecha'].day - 1) // 7 + 1

     elif tipo=='DayType':
          if row['Fecha'] in co_holidays:
               return 3
          elif row['Fecha'].weekday()==5:
               return 2
          elif row['Fecha'].weekday()==6:
               return 3
          else:
               return 1


# In[14]:


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

    if Tipo=='DemDespacho':
        # Navigate to the directory you want to access
        ftps.cwd(rf"/INFORMACION_XM/Publico/DESPACHO/{year:04d}-{mes:02d}")
    elif Tipo=='Demanda':
        # Calcular el lunes asociado a la semana de la fecha dada
        lunes_asociado = fecha_dt - dt.timedelta(days=fecha_dt.weekday())
        # Obtener mes y día
        year= lunes_asociado.year
        mes = lunes_asociado.month
        dia = lunes_asociado.day
        ftps.cwd(rf"/INFORMACION_XM/PUBLICO/DEMANDAS/Pronostico Oficial/{year:04d}-{mes:02d}")
    else:
        messagebox.showinfo('Estado del proceso',f'No se reconoce el formato {Tipo}', parent=root)
        df=pd.DataFrame()
        return df


    # List files
    files = ftps.nlst()
    # print("Available files:", files)


    if Tipo=='DemDespacho':
        # Download condiciones iniciales de planta
        pathfile=rf"C:\Informacion_XM\Publico\DESPACHO\{year:04d}-{mes:02d}"
        if not os.path.exists(pathfile):
            os.makedirs(pathfile)
        filename = rf"dDEM{mes:02d}{dia:02d}.TXT"    
    elif Tipo=='Demanda':
        # Calcular el lunes asociado a la semana de la fecha dada
        lunes_asociado = fecha_dt - dt.timedelta(days=fecha_dt.weekday())
        # Obtener mes y día
        year= lunes_asociado.year
        mes = lunes_asociado.month
        dia = lunes_asociado.day

        pathfile=rf"C:\Informacion_XM\PUBLICO\DEMANDAS\Pronostico Oficial\{year:04d}-{mes:02d}"
        if not os.path.exists(pathfile):
            os.makedirs(pathfile)
        filename = rf"PRON_AREAS{mes:02d}{dia:02d}.TXT"

    try:
        # print(pathfile + "\\" + filename)
        with open(pathfile + "\\" + filename, 'wb') as f:
            ftps.retrbinary(f"RETR {filename}", f.write)

        ftps.quit()
        # print(f"{filename} downloaded successfully.")


    except:

        df=pd.DataFrame()


    return 


# In[ ]:


def CalcularFactores(sRutaDesp,s_FechaIni,s_FechaFin,tipod,DowmdFTP):

    folderpath=Path(sRutaDesp + 'Despacho\\')


    # Create a DataFrame of dates
    df_dates = pd.DataFrame(pd.date_range(start=s_FechaIni, end=s_FechaFin, freq='D')  , columns=["Date"])

    df_dates['Mes']=df_dates['Date'].dt.month


    filetype='dDEM'

    l_colDem=['Subarea']

    l_SubCar=['ATLANTIC','BOLIVAR','GCM','CORDOSUC','CERROMAT','SubArea Atlantico','SubArea Bolivar','SubArea Cerromatoso','SubArea Cordoba_Sucre','SubArea GCM'] # Lista con las subareas Caribe

    df_Factor=pd.DataFrame()
    df_Factor_typo_d=pd.DataFrame()

    for i in range(1,25): 
        l_colDem.append(i)


    for mes in range(1,13):

        df_Dem=pd.DataFrame()
        df_datesAx=df_dates[(df_dates.Mes==mes)]
        df_datesAx=df_datesAx.sort_values(by='Date', ascending=True)

        # print(mes)

        for ind in df_datesAx.index:

            dFecha=df_datesAx.at[ind,'Date']

            ano=dFecha.year
            mes=dFecha.month
            dia=dFecha.day

            UsuXM='1060588666'
            PwsXM='Alejo230710*+'
            Tipo='DemDespacho'

            if DowmdFTP==1:
                DownFile(dFecha,UsuXM,PwsXM,Tipo)


            file = filetype + "{:02d}".format(mes) + "{:02d}".format(dia) + '.txt'
            s_filepath=folderpath.joinpath(str(ano) + '-' + "{:02d}".format(mes),file)
            df_Aux = pd.read_csv(s_filepath, sep=',',names=l_colDem,encoding="ISO-8859-1")
            df_Aux['Fecha']=dFecha
            df_Aux = df_Aux[~df_Aux['Subarea'].isin(['Total','ECUADOR138','ECUADOR220','COROZO','CUATRIC','SubArea Venezuela_Corozo','SubArea Venezuela_Cuatricentenario','SubArea Ecuador138','SubArea Ecuador230'])]

            df_Aux['Subarea'] = df_Aux['Subarea'].replace({
                'SubArea Atlantico': 'ATLANTIC',
                'SubArea Bolivar': 'BOLIVAR',
                'SubArea Cerromatoso': 'CERROMAT',
                'SubArea Cordoba_Sucre': 'CORDOSUC',
                'SubArea GCM': 'GCM'
            })

            df_Dem=pd.concat([df_Dem,df_Aux])


        # df_Dem.to_csv(sRutaPrint.joinpath('D1.csv'))

        # Definir tipo de día
        df_Dem['day_osf']=df_Dem.apply(lambda row: typedays(row,tipo='DayType'),axis=1)
        # Definir día de la semana
        df_Dem['day_w']=df_Dem.apply(lambda row: typedays(row,tipo='WeekDay'),axis=1)
        # Definir semana del mes
        # df_Dem['week_m']=df_Dem.apply(lambda row: typedays(row,tipo='WeekMonth'),axis=1)


        # Definir los periodos en una columna
        df_Dem = pd.melt(df_Dem, id_vars=['Fecha','day_osf','day_w','Subarea'], var_name='Periodo', value_name='DemMW')
        # # df_dataP['Precio']=df_dataP['Precio']/1000

        df_Dem['Mes']=df_Dem['Fecha'].dt.month
        df_Dem['Dia']=df_Dem['Fecha'].dt.day

        # Calcualr energía del mes con todos los valores
        EnerMes=df_Dem.groupby(['Mes'])[['DemMW']].sum().values[0][0]

        # Cálculo de factores para distribuir por día
        df_EneDiaFecha=df_Dem.groupby(['Fecha','Mes','day_osf','day_w'])[['DemMW']].sum()
        df_EneDiaFecha['FactorDay']=df_EneDiaFecha['DemMW']/EnerMes

        # Energía por periodo
        # df_EneDiaFecha.to_csv(sRutaPrint.joinpath('D2.csv'))

        df_EneDia=df_EneDiaFecha.groupby(['Mes','day_osf','day_w'])[['FactorDay']].mean()
        df_EneDia=df_EneDia.reset_index()

        df_FactorAux=df_EneDia[['Mes','day_osf','day_w','FactorDay']]


        # Cálculo de factores para distribuir por hora
        # Cálculo de promedio día
        df_EneDiaFecha=df_Dem.groupby(['Fecha','Mes','day_osf','day_w'])[['DemMW']].sum()
        df_EneDiaM=df_EneDiaFecha.reset_index()
        df_EneDiaM=df_EneDiaM.rename(columns={'DemMW':'DemMWDia'})

        # Cálculo de promedio hora
        df_EnePer=df_Dem.groupby(['Fecha','Mes','day_osf','day_w','Periodo'])[['DemMW']].sum()
        df_EnePer=df_EnePer.reset_index()

        df_EnePer=df_EnePer.merge(df_EneDiaM,left_on=['Fecha','Mes','day_osf','day_w'],right_on=['Fecha','Mes','day_osf','day_w'], how='left')[['Fecha','Mes','day_osf','day_w','Periodo','DemMW','DemMWDia']]

        df_EnePer['FactorHour']=df_EnePer['DemMW']/df_EnePer['DemMWDia']

        # Energía por periodo
        # df_EnePer.to_csv(sRutaPrint.joinpath('D3.csv'))

        df_EnePer=df_EnePer.groupby(['Mes','day_osf','day_w','Periodo'])[['FactorHour']].mean()
        df_EnePer=df_EnePer.reset_index()

        df_EnePer=df_EnePer[['Mes','day_osf','day_w','Periodo','FactorHour']]

        df_FactorAux=df_EnePer.merge(df_FactorAux,left_on=['Mes','day_osf','day_w'],right_on=['Mes','day_osf','day_w'], how='left')[['Mes','day_osf','day_w','Periodo','FactorHour','FactorDay']]

        # Cálculo de los factores para distribuir la demanda en cada subárea de caribe
        df_Aux=df_Dem.groupby(['Fecha','Mes','day_osf','day_w','Periodo'])[['DemMW']].sum()
        df_Aux=df_Aux.reset_index()
        df_Aux=df_Aux.rename(columns={'DemMW':'DemMWDia'})

        # Cálculo de promedio hora
        df_Aux2=df_Dem[df_Dem['Subarea'].isin(l_SubCar)]
        df_Aux2=df_Aux2.groupby(['Fecha','Mes','day_osf','day_w','Subarea','Periodo'])[['DemMW']].sum()
        df_Aux2=df_Aux2.reset_index()


        df_Aux2=df_Aux2.merge(df_Aux,left_on=['Fecha','Mes','day_osf','day_w','Periodo'],right_on=['Fecha','Mes','day_osf','day_w','Periodo'], how='left')[['Fecha','Mes','day_osf','day_w','Subarea','Periodo','DemMW','DemMWDia']]
        df_Aux2['FactorH']=(df_Aux2['DemMW']/df_Aux2['DemMWDia'])

        # df_Aux2.to_csv(sRutaPrint.joinpath('D4.csv'))

        df_Aux2=df_Aux2.groupby(['Mes','day_osf','day_w','Subarea','Periodo'])[['FactorH']].mean()
        df_Aux2=df_Aux2.reset_index()
        df_Aux2=df_Aux2[['Mes','day_osf','day_w','Subarea','Periodo','FactorH']]



        df_FacCar=df_Aux2.groupby(['Mes','day_osf','day_w','Periodo'])[['FactorH']].sum()
        df_FacCar=df_FacCar.reset_index()
        df_FacCar=df_FacCar.rename(columns={'FactorH':'F_Car'})

        df_FactorAux=df_FactorAux.merge(df_FacCar,left_on=['Mes','day_osf','day_w','Periodo'],right_on=['Mes','day_osf','day_w','Periodo'], how='left')[['Mes','day_osf','day_w','Periodo','FactorDay','FactorHour','F_Car']]

        df_Aux2['Subarea']='F_' + df_Aux2['Subarea']
        df_Aux2 = df_Aux2.pivot(index=['Mes','day_osf','day_w','Periodo'], columns='Subarea', values='FactorH')
        df_Aux2=df_Aux2.reset_index()
        df_FactorAux=df_FactorAux.merge(df_Aux2,left_on=['Mes','day_osf','day_w','Periodo'],right_on=['Mes','day_osf','day_w','Periodo'], how='left')[['Mes'
                                            ,'day_osf','day_w','Periodo','FactorDay','FactorHour','F_Car','F_ATLANTIC', 'F_BOLIVAR','F_CERROMAT', 'F_CORDOSUC', 'F_GCM']]
        df_Factor=pd.concat([df_Factor,df_FactorAux],axis=0)

    if tipod=='day_osf':
        # Factores por tipo de día
        df_Factor_typo_d=df_Factor.groupby(['Mes','day_osf','Periodo'])[['FactorDay','FactorHour','F_Car','F_ATLANTIC', 'F_BOLIVAR','F_CERROMAT', 'F_CORDOSUC', 'F_GCM']].mean().reset_index()
    else:
        # Factores por día de la semana
        df_Factor_typo_d=df_Factor.groupby(['Mes','day_w','Periodo'])[['FactorDay','FactorHour','F_Car','F_ATLANTIC', 'F_BOLIVAR','F_CERROMAT', 'F_CORDOSUC', 'F_GCM']].mean().reset_index()


    df_Factor_typo_d['F_Interior'] = 1 - df_Factor_typo_d['F_Car']
    df_Factor_typo_d['F_Caribe2'] = df_Factor_typo_d['F_ATLANTIC'] + df_Factor_typo_d['F_BOLIVAR'] + df_Factor_typo_d['F_GCM']

    return df_Factor_typo_d





# In[ ]:


def DistribuirDemanda(sRutaPrint,df_Factor_typo_d,tipod,yearIniLP,yearFinLP,esc_dem):
    from datetime import datetime
    import pandas as pd

    # Lectura de datos de enrtrada para el cálculo
    s_parentpath=Path(r'C:\Alejo\cops\Modules\Utils\Demanda')

    filepath=s_parentpath.joinpath(s_parentpath,'DemandaUPME.xlsx')

    # Carga del nivel probabilístico del embalse
    sheet_name='DemandaUPME'
    df_DemMes=pd.read_excel(filepath, header=0,sheet_name=sheet_name)
    # df_DemMes=df_DemMes.set_index('Embalse_Sinergox')


    tipo='MP'
    d_YearIni=int(yearIniLP)
    d_YearFin=int(yearFinLP)

    df_Factor_typo_d_adjusted = df_Factor_typo_d.copy()
    # iFactorInterior=-0.0089802
    # iFactorCaribe=0.00114209
    # iFactorCaribe2=0.00223202

    # iFactorInterior=-0.007
    # iFactorCaribe=0.00089025
    # iFactorCaribe2=0.00173984


    df_DemMod=pd.DataFrame()

    for year in range(d_YearIni,d_YearFin+1):

        if year==2026:
            iFactorInterior=0.01
            iFactorCaribe=-0.001271781
            iFactorCaribe2=-0.002485479

        else:
            iFactorInterior=-0.005986827
            iFactorCaribe=0.000761393
            iFactorCaribe2=0.001488013


        df_Factor_typo_d_adjusted['F_Interior'] += iFactorInterior
        df_Factor_typo_d_adjusted[['F_CERROMAT', 'F_CORDOSUC']] += iFactorCaribe
        df_Factor_typo_d_adjusted[['F_ATLANTIC', 'F_BOLIVAR', 'F_GCM']] += iFactorCaribe2

        if year==2026:
            perini=1
            perfin=13
        else:
            perini=1
            perfin=13

        for mes in range(perini,perfin):

            fecha_str = f"{year}-{mes:02d}-01"

            if tipo=='MP':
                fechas = pd.date_range(start=fecha_str, periods=pd.Period(fecha_str).days_in_month, freq='D')
            elif tipo=='LP':
                # Crear fechas para los primeros 5 días del mes
                fechas = pd.date_range(start=fecha_str, periods=5, freq='D')
                # Crear columna 'DiaTipo' según la posición del día en el mes
                dia_tipo_map = {0: 1, 1: 2, 2: 3, 3: 1, 4: 1}
                df_diatipo = pd.DataFrame({'Fecha': fechas, 'day_osf': [dia_tipo_map[i] for i in range(len(fechas))]})

            # Crear dataframe con 24 periodos para cada día

            df_mes = pd.DataFrame([
                {'Fecha': fecha, 'Periodo': periodo}
                for fecha in fechas
                for periodo in range(1, 25)
            ])

            if tipo=='MP':
                if tipod=='day_osf':
                    df_mes['day_osf']=df_mes.apply(lambda row: typedays(row,tipo='DayType'),axis=1)
                else:
                    df_mes['day_w']=df_mes.apply(lambda row: typedays(row,tipo='WeekDay'),axis=1)
            elif tipo=='LP':
                df_mes = df_mes.merge(df_diatipo, on='Fecha', how='left')

            d_date = datetime.strptime(fecha_str, '%Y-%m-%d')
            df_DemDia=df_DemMes[(df_DemMes['Fecha']==d_date)][esc_dem]
            # df_DemDia=df_DemMes[(df_DemMes['Fecha']==d_date)]['IC Superior 68%']
            # df_DemDia=df_DemMes[(df_DemMes['Fecha']==d_date)]['IC Superior 95%']
            valor = df_DemDia.values[0]
            df_mes['ValorMes']=valor

            df_mes['Mes'] = df_mes['Fecha'].dt.month

            if tipod=='day_osf':

                df_mes=df_mes.merge(df_Factor_typo_d_adjusted,left_on=['Mes','day_osf','Periodo'],
                                    right_on=['Mes','day_osf','Periodo'], how='left')[['Fecha','Mes','day_osf','Periodo','ValorMes','FactorDay','FactorHour','F_Car','F_Interior','F_ATLANTIC', 'F_BOLIVAR','F_CERROMAT', 'F_CORDOSUC', 'F_GCM']]
            else:
                df_mes=df_mes.merge(df_Factor_typo_d_adjusted,left_on=['Mes','day_w','Periodo'],
                                    right_on=['Mes','day_w','Periodo'], how='left')[['Fecha','Mes','day_w','Periodo','ValorMes','FactorDay','FactorHour','F_Car','F_Interior','F_ATLANTIC', 'F_BOLIVAR','F_CERROMAT', 'F_CORDOSUC', 'F_GCM']]

            df_mes['SubAntioquia'] = df_mes['ValorMes'] * 1000 * df_mes['FactorDay'] * df_mes['FactorHour'] * df_mes['F_Interior']
            df_mes['SubAtlantico'] = df_mes['ValorMes'] * 1000 * df_mes['FactorDay'] * df_mes['FactorHour'] * df_mes['F_ATLANTIC']
            df_mes['SubBolivar'] = df_mes['ValorMes'] * 1000 * df_mes['FactorDay'] * df_mes['FactorHour'] * df_mes['F_BOLIVAR']
            df_mes['SubGCM'] = df_mes['ValorMes'] * 1000 * df_mes['FactorDay'] * df_mes['FactorHour'] * df_mes['F_GCM']
            df_mes['SubCordoba-Sucre'] = df_mes['ValorMes'] * 1000 * df_mes['FactorDay'] * df_mes['FactorHour'] * df_mes['F_CORDOSUC']
            df_mes['SubCerromatoso'] = df_mes['ValorMes'] * 1000 * df_mes['FactorDay'] * df_mes['FactorHour'] * df_mes['F_CERROMAT']


            df_mes=df_mes[['Fecha','Periodo','SubAntioquia','SubAtlantico','SubBolivar','SubGCM','SubCordoba-Sucre','SubCerromatoso']]

            df_mes = df_mes.melt(id_vars=['Fecha', 'Periodo'], var_name='Subarea', value_name='Valor')
            df_mes['Fecha'] = df_mes['Fecha'].dt.date

            df_DemMod=pd.concat([df_DemMod,df_mes],axis=0)

    df_DemMod=df_DemMod[['Fecha','Subarea','Periodo','Valor']]
    df_DemMod.to_csv(sRutaPrint.joinpath('DatosDemanda.csv'),index=False)

    return df_DemMod


# In[ ]:


# if 1==1:
try:
    # Ruta del archivo
    sFile=r"Parametros.json"
    script_dir = Path.cwd()
    script_dir=script_dir.parent.parent
    sPathfile=os.path.join(script_dir,r"Modules\Utils\ArchivosAux",sFile)
    sPathfile = os.path.join(r"C:\Alejo\cops\Modules\Utils\ArchivosAux",sFile)

    # Get main path and other folders
    s_mainpath=Path.cwd()

    # Ruta General
    sRutaDesp=r'C:\Informacion_XM\\Publico\\'


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

    # Ruta principal
    sPathAE=data['Paths']['AEnerPath']

    # Parámetros largo plazo
    FechaInicialLP=data['ParametrosLP']['fecha_ini_lp']
    FechaFinalLP=data['ParametrosLP']['fecha_fin_lp']
    yearIniLP=data['ParametrosLP']['year_ini']
    yearFinLP=data['ParametrosLP']['year_fin']
    tipod=data['ParametrosLP']['tipo_dia_fac']
    esc_dem=data['ParametrosLP']['escenario_dem']

    # Banderas LP
    DownFTP=data['BanderasLP']['DownFTP']



    # Cargar bandera de demandas
    if DownFTP=='Verdadero':
        DownFTP=1
    else:
        DownFTP=0

    file_path=os.path.join(sPathAE + f"{int(year):00d}" + "-" + f"{int(mes):02d}" ,Carpeta)



    # Rango de análisis
    fecha = datetime.strptime(FechaInicialLP, "%d/%m/%Y")
    s_FechaIni=fecha.strftime("%Y-%m-%d")

    fecha = datetime.strptime(FechaFinalLP, "%d/%m/%Y")
    s_FechaFin=fecha.strftime("%Y-%m-%d")

    # tipod='day_w'
    # tipod='day_osf'

    df_Factor_typo_d=CalcularFactores(sRutaDesp,s_FechaIni,s_FechaFin,tipod,DownFTP)

    DistribuirDemanda(Path(file_path),df_Factor_typo_d,tipod,yearIniLP,yearFinLP,esc_dem)

    # Crear ventana raíz oculta
    root = tk.Tk()
    root.withdraw()
    root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano
    messagebox.showinfo('Estado del proceso','Se imprimió el archivo de excel con la demanda correctamente', parent=root)


except:

    root = tk.Tk()
    root.withdraw()
    root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano
    messagebox.showerror('Estado del proceso','Error en el proceso, por favor validar', parent=root)   

