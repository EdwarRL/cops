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


def GetInfoUE(s_mainpath):
    # Lectura de datos de enrtrada para el cálculo
    s_parentpath=s_mainpath.parent
    # filepath=s_parentpath.joinpath(s_parentpath,'IPOEM_Data.xlsx')
    filepath=r'C:\Alejo\cops\Python\IPOEM_Data.xlsx'

    # Caribe 2 1300-1400
    sheet_name='Caribe2'
    skip_rows = 1
    start_col=0
    end_col = 2
    end_row = 12
    df_UniCar2_2024=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=4
    end_col = 6
    end_row = 12
    df_UniCar2_2025=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=8
    end_col = 10
    end_row = 13
    df_UniCar2_2026=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=12
    end_col = 14
    end_row = 14
    df_UniCar2_2027=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=16
    end_col = 18
    end_row = 15
    df_UniCar2_2028=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=20
    end_col = 22
    end_row = 16
    df_UniCar2_2029=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=24
    end_col = 26
    end_row = 17
    df_UniCar2_2030=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=28
    end_col = 30
    end_row = 18
    df_UniCar2_2031=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=32
    end_col =34
    end_row = 20
    df_UniCar2_2032=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=36
    end_col =38
    end_row = 21
    df_UniCar2_2033=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=40
    end_col =42
    end_row = 22
    df_UniCar2_2034=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=44
    end_col =46
    end_row = 23
    df_UniCar2_2035=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=48
    end_col =50
    end_row = 24
    df_UniCar2_2036=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=52
    end_col =54
    end_row = 20
    df_UniCar2_2042=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    sheet_name='Caribe2'
    skip_rows = 1
    start_col=56
    end_col =58
    end_row = 20
    df_UniCar2_2044=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1)

    # Atlántico
    sheet_name='Atlantico'
    start_col=0
    end_col = 2
    end_row = 1
    df_Atl=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1), nrows=end_row+1)  

    # Bolivar
    sheet_name='Bolivar'
    start_col=0
    end_col = 2
    end_row = 1
    df_Bol=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1), nrows=end_row+1) 

    # GCM con demmanda de caribe 2
    sheet_name='GCM'
    skip_rows = 1
    start_col=0
    end_col = 2
    end_row = 1
    df_GCM_C2=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1) 

    # GCM con demanda de GCM
    sheet_name='GCM'
    skip_rows = 1
    start_col=4
    end_col = 6
    end_row = 1
    df_GCM_1=pd.read_excel(filepath, header=0,sheet_name=sheet_name, usecols=range(start_col, end_col+1),skiprows=skip_rows, nrows=end_row+1) 


    return (df_UniCar2_2024, df_UniCar2_2025, df_UniCar2_2026, df_UniCar2_2027, df_UniCar2_2028, df_UniCar2_2029, df_UniCar2_2030, df_UniCar2_2031,
             df_UniCar2_2032, df_UniCar2_2033, df_UniCar2_2034, df_UniCar2_2035, df_UniCar2_2036, df_UniCar2_2042, df_UniCar2_2044, df_Atl, df_Bol,df_GCM_C2,df_GCM_1)

# Función para calcular las unidades equivalentes según la demanda
def CalcularUnidadesCar2(Demanda,df_U2024,df_U2025,df_U2026,df_U2027,df_U2028,df_U2029,df_U2030,df_U2031,df_U2032,df_U2033,df_U2034,df_U2035,df_U2036,df_U2042,df_U2044,Fecha):

    # print(Fecha)
    # if Fecha=='2044-01-01':
    #     stop=1

    if dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2025-11-15','%Y-%m-%d'):
        df_data=df_U2024.copy()
        df_data=df_data.rename(columns={'ValMin24':'ValMin','ValMax24':'ValMax','Unidades24':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2025-11-15','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2026-11-30','%Y-%m-%d'):
        df_data=df_U2025.copy()
        df_data=df_data.rename(columns={'ValMin25':'ValMin','ValMax25':'ValMax','Unidades25':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2026-11-30','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2026-12-31','%Y-%m-%d'):
        df_data=df_U2026.copy()
        df_data=df_data.rename(columns={'ValMin26':'ValMin','ValMax26':'ValMax','Unidades26':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2026-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2027-12-31','%Y-%m-%d'):
        df_data=df_U2027.copy()
        df_data=df_data.rename(columns={'ValMin27':'ValMin','ValMax27':'ValMax','Unidades27':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2027-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2028-12-31','%Y-%m-%d'):
        df_data=df_U2028.copy()
        df_data=df_data.rename(columns={'ValMin28':'ValMin','ValMax28':'ValMax','Unidades28':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2028-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2029-12-31','%Y-%m-%d'):
        df_data=df_U2029.copy()
        df_data=df_data.rename(columns={'ValMin29':'ValMin','ValMax29':'ValMax','Unidades29':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2029-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2030-12-31','%Y-%m-%d'):
        df_data=df_U2030.copy()
        df_data=df_data.rename(columns={'ValMin30':'ValMin','ValMax30':'ValMax','Unidades30':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2030-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2031-12-31','%Y-%m-%d'):
        df_data=df_U2031.copy()
        df_data=df_data.rename(columns={'ValMin31':'ValMin','ValMax31':'ValMax','Unidades31':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2031-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2032-12-31','%Y-%m-%d'):
    # elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2031-12-31','%Y-%m-%d'):    
        df_data=df_U2032.copy()
        df_data=df_data.rename(columns={'ValMin32':'ValMin','ValMax32':'ValMax','Unidades32':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2032-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2033-12-31','%Y-%m-%d'):
  
        df_data=df_U2033.copy()
        df_data=df_data.rename(columns={'ValMin33':'ValMin','ValMax33':'ValMax','Unidades33':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2033-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2034-12-31','%Y-%m-%d'):
    
        df_data=df_U2034.copy()
        df_data=df_data.rename(columns={'ValMin34':'ValMin','ValMax34':'ValMax','Unidades34':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2034-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2035-12-31','%Y-%m-%d'):
    
        df_data=df_U2035.copy()
        df_data=df_data.rename(columns={'ValMin35':'ValMin','ValMax35':'ValMax','Unidades35':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2035-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2036-12-31','%Y-%m-%d'):

        df_data=df_U2036.copy()
        df_data=df_data.rename(columns={'ValMin36':'ValMin','ValMax36':'ValMax','Unidades36':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2041-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2043-12-31','%Y-%m-%d'):
    
        df_data=df_U2042.copy()
        df_data=df_data.rename(columns={'ValMin42':'ValMin','ValMax42':'ValMax','Unidades42':'Unidades'})

    elif dt.datetime.strptime(Fecha,'%Y-%m-%d')>dt.datetime.strptime('2043-12-31','%Y-%m-%d') and dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2044-12-31','%Y-%m-%d'):
     
        df_data=df_U2044.copy()
        df_data=df_data.rename(columns={'ValMin44':'ValMin','ValMax44':'ValMax','Unidades44':'Unidades'})

    rows,cols=df_data.shape
    if (Demanda>df_data.at[0,'ValMin']) and (Demanda<=df_data.at[rows-1,'ValMax']):

        Val=df_data[(Demanda>df_data.ValMin) & (Demanda<=df_data.ValMax)]['Unidades'].values[0]

    else:
        Val=0

    return Val

# Función para calcular las unidades de atlantico según la demanda
def CalcularUnidadesAtl(Demanda,df_Atl,Fecha):
    # print(Fecha)
    if dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2050-06-30','%Y-%m-%d'):
        df_data=df_Atl.copy()

    rows,cols=df_data.shape
    if (Demanda>df_data.at[0,'ValMin']) and (Demanda<=df_data.at[rows-1,'ValMax']):

        Val=df_data[(Demanda>df_data.ValMin) & (Demanda<=df_data.ValMax)]['Unidades'].values[0]

    else:
        Val=0

    return Val

# Función para calcular las unidades de bolivar según la demanda
def CalcularUnidadesBol(Demanda,df_Bol,Fecha):
    # print(Fecha)
    if dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2050-06-30','%Y-%m-%d'):
        df_data=df_Bol.copy()

    rows,cols=df_data.shape
    if (Demanda>df_data.at[0,'ValMin']) and (Demanda<=df_data.at[rows-1,'ValMax']):

        Val=df_data[(Demanda>df_data.ValMin) & (Demanda<=df_data.ValMax)]['Unidades'].values[0]

    else:
        Val=0

    return Val

# Función para calcular las unidades de bolivar según la demanda
def CalcularUnidadesGCM(DemandaCar2,DemandaGCM,df_GCM_C2,df_GCM_1,Fecha):
    # print(Fecha)
    if dt.datetime.strptime(Fecha,'%Y-%m-%d')<=dt.datetime.strptime('2050-06-30','%Y-%m-%d'):
        df_data1=df_GCM_C2.copy()
        df_data2=df_GCM_1.copy()

    rows,cols=df_data1.shape
    if (DemandaCar2>df_data1.at[0,'ValMinC2']) and (DemandaCar2<=df_data1.at[rows-1,'ValMaxC2']):

        Val1=df_data1[(DemandaCar2>df_data1.ValMinC2) & (DemandaCar2<=df_data1.ValMaxC2)]['UnidadesC2'].values[0]

    else:
        Val1=0

    rows,cols=df_data2.shape
    if (DemandaGCM>df_data2.at[0,'ValMinGCM']) and (DemandaGCM<=df_data2.at[rows-1,'ValMaxGCM']):

        Val2=df_data2[(DemandaGCM>df_data2.ValMinGCM) & (DemandaGCM<=df_data2.ValMaxGCM)]['UnidadesGCM'].values[0]

    else:
        Val2=0

    val=max(Val1,Val2)
    if val==0.9:
        stop=1
    return max(Val1,Val2)


def ApplyFuncyionValue(df_Apply,demGCM,df_U2024,df_U2025,df_U2026,df_U2027,df_U2028,df_U2029,df_U2030,df_U2031,df_U2032,df_U2033,df_U2034,df_U2035,df_U2036,df_U2042
                            ,df_U2044,df_Atl,df_Bol,df_GCM_C2,df_GCM_1):

    l_date=[]
    l_per=[]
    l_valCar2=[]
    l_valAtl=[]
    l_valBol=[]
    l_valGCMC=[]
    
    for ind in df_Apply.index:
        
        fecha=df_Apply.at[ind,'fecha']
        hora=df_Apply.at[ind,'periodo']
        x=df_Apply.at[ind,'valor'] # Demanda de Caribe2
        x2=demGCM.at[ind,'valor'] # Demanda de GCM

        if fecha=='2025-01-15' and hora==24:
            stop=1
        
        val=CalcularUnidadesCar2(x,df_U2024,df_U2025,df_U2026,df_U2027,df_U2028,df_U2029,df_U2030,df_U2031,df_U2032,df_U2033,df_U2034,df_U2035,df_U2036,df_U2042,df_U2044,fecha)
        if ((hora>=1 and hora<=5) or (hora>=10 and hora<=14) or (hora>=17 and hora<=18)):
            val=val
        l_date.append(fecha)
        l_per.append(hora)
        l_valCar2.append(val)

        val=CalcularUnidadesAtl(x,df_Atl,fecha)
        l_valAtl.append(val)

        val=CalcularUnidadesBol(x,df_Bol,fecha)
        l_valBol.append(val)

        val=CalcularUnidadesGCM(x,x2,df_GCM_C2,df_GCM_1,fecha)
        l_valGCMC.append(val)

    df_ResultsCar2=pd.DataFrame({'fecha':l_date,'periodo':l_per,'valor':l_valCar2})

    df_ResultsAtl=pd.DataFrame({'fecha':l_date,'periodo':l_per,'valor':l_valAtl})

    df_ResultsBol=pd.DataFrame({'fecha':l_date,'periodo':l_per,'valor':l_valBol})

    df_ResultsGCM=pd.DataFrame({'fecha':l_date,'periodo':l_per,'valor':l_valGCMC})
    
    return df_ResultsCar2, df_ResultsAtl, df_ResultsBol, df_ResultsGCM

def GetUE(df_dem,demGCM):

    # Get main path and other folders
    s_mainpath=Path.cwd()

    [df_U2024,df_U2025,df_U2026,df_U2027,df_U2028,df_U2029,df_U2030,df_U2031,df_U2032,df_U2033,df_U2034,df_U2035,df_U2036,df_U2042,df_U2044, df_Atl, df_Bol,df_GCM_C2,df_GCM_1]= GetInfoUE(s_mainpath)

    [df_UniCar2, df_UniAtl, df_UniBol,df_UniGCM]=ApplyFuncyionValue(df_dem,demGCM,df_U2024,df_U2025,df_U2026,df_U2027,df_U2028,df_U2029,df_U2030,df_U2031,df_U2032,df_U2033,df_U2034,df_U2035,df_U2036,df_U2042,df_U2044, df_Atl, df_Bol,df_GCM_C2,df_GCM_1) 

    return df_UniCar2, df_UniAtl, df_UniBol, df_UniGCM