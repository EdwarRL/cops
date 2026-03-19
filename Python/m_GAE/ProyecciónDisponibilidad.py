#!/usr/bin/env python
# coding: utf-8

# ### Cálculo de la disponiblidad histórica de las plantas

# In[21]:


# import warnings

# warnings.filterwarnings('ignore')
# warnings.simplefilter('ignore')

from pydataxm import *                           #Se realiza la importación de las librerias necesarias para ejecutar                        
from pydataxm.pydataxm import ReadDB as apiXM 
import datetime as dt                            
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

from datetime import datetime

root = tk.Tk()
root.withdraw()
root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano


# In[22]:


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
            # print(line)
            unidad = parts[0]
            tipo = parts[1]
            valores = parts[2:]

            if unidad=='URRA' and tipo=='AGCP':
                stop=1


            # Try to convert values to float; skip line if fails
            if len(valores)>6:
                valores_float = [float(v) if str(v).replace('.', '', 1).isdigit() else 0 for v in valores]
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


# In[23]:


def DispUni(df):
    # Lectura de datos con los mapeos
    s_parentpath=Path('C:\Alejo\cops\Data')
    filepath=s_parentpath.joinpath(s_parentpath,'Mapeos.xlsx')

    df=df[(df['Tipo']=='D')]

    df_precios_plt=pd.DataFrame()

    # --- Preprocesar df como diccionario para búsqueda rápida
    df_lookup = df.set_index(['Unidad', 'Hora'])['Valor'].to_dict()
    unidades_validas = set(df['Unidad'].unique())

    df_plt = df[['Unidad']]
    df_plt = df_plt.drop_duplicates(subset=['Unidad']).reset_index(drop=True)

    # Inicializar columnas D_1 a D_24
    l_per=[]
    for i in range(1, 25):
        df_plt[f'{i}'] = 0
        l_per.append(f'{i}')

    # Llenar valores por unidad y hora
    for ind, row in df_plt.iterrows():
        unidad = row['Unidad']

        if unidad in unidades_validas:
            for hora in range(1, 25):
                valor = df_lookup.get((unidad, hora), None)
                if valor is not None:
                    df_plt.at[ind, f'{hora}'] = valor
        else:
            print(f'No se encontró la unidad: {unidad}')

    # Concatenar resultados
    df_precios_plt = pd.concat([df_precios_plt, df_plt], axis=0, ignore_index=True)

    # df_plt_uni = pd.read_excel(filepath, sheet_name='Planta_Unidad')
    # df_precios_plt=df_precios_plt.merge(df_plt_uni,left_on=['Unidad'],right_on=['UniOfe'],how='Left')[l_col]


    return df_precios_plt


# In[24]:


# Función para descargar el archivo
def DownFile(fecha_dt,UsuXM,PwsXM,Tipo,bDownFile):


    if bDownFile==True:

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

    if bDownFile==True:

        if Tipo=='Oferta':
            # Navigate to the directory you want to access
            ftps.cwd(rf"/INFORMACION_XM/PUBLICO/OFERTAS/INICIAL/{year:04d}-{mes:02d}")
        else:
            messagebox.showinfo('Estado del proceso',f'No se reconoce el formato {Tipo}', parent=root)
            df=pd.DataFrame()
            return df


        #List files
        files = ftps.nlst()
        # print("Available files:", files)


    if Tipo=='Oferta':
        # Download condiciones iniciales de planta
        pathfile=rf"C:\\Informacion_XM\PUBLICO\OFERTAS\INICIAL\{year:04d}-{mes:02d}"
        if not os.path.exists(pathfile):
            os.makedirs(pathfile)
        filename = rf"OFEI{mes:02d}{dia:02d}.TXT"

        if bDownFile==True:

            # print(pathfile + filename)
            with open(pathfile + "\\" + filename, 'wb') as f:
                ftps.retrbinary(f"RETR {filename}", f.write)

            ftps.quit()

        print(pathfile + "\\" + filename)
        if Tipo=='Oferta':
            df=readfileOfe(pathfile + "\\" + filename)


    # except:
        # df=pd.DataFrame()


    return df


# In[25]:


def get_data(FechaInicialLP,FechaFinalLP,UsuXM,PwsXM,DownFTP):


    FechaIni=datetime.strptime(FechaInicialLP, "%d/%m/%Y").date()
    FechaFin=datetime.strptime(FechaFinalLP, "%d/%m/%Y").date()
    # FechaFin=dt.date(2023,12,31)
    # FechaFin=dt.date(2022,7,11)
    fecha_dt = FechaIni

    # Cargar bandera de demandas
    if DownFTP=='Verdadero':
        bDownFile=True
    else:
        bDownFile=False


    df_data=pd.DataFrame()

    while fecha_dt<=FechaFin:

        df_Ini=DownFile(fecha_dt,UsuXM,PwsXM,Tipo='Oferta',bDownFile=bDownFile)

        # Obtener disponibilidad por unidad
        df_DispPlt=DispUni(df_Ini)

        # Filtar por las unidades requeridas
        df_DispPlt=df_DispPlt[(df_DispPlt['Unidad'].isin(['FLORES2','FLORES3','FLORES4','FLORES1GAS','FLORES1VAPOR','GUAJIRA1','GUAJIRA2','PROELECTRICA1','PROELECTRICA2','TERMOCANDELARIACC1'
                                                    ,'TERMOCANDELARIACC2','TERMOCANDELARIACC3','TEBSA11','TEBSA12','TEBSA13','TEBSA14','TEBSA21','TEBSA22','TEBSA24','BARRANQUILLA3'
                                                    ,'BARRANQUILLA4']))]

        df_DispPlt['Fecha']=fecha_dt
        df_data=pd.concat([df_data,df_DispPlt],axis=0)

        fecha_dt=fecha_dt + dt.timedelta(days=1)

    df_pltt = df_data.copy()

    cols_horas = [str(i) for i in range(1, 25)]  # ['1','2',...,'24']

    df_pltt['flag'] = (
        df_pltt[cols_horas]
        .eq(0)            # True donde hay ceros
        .any(axis=1)     # True si existe al menos un 0 en la fila
        .map(lambda x: 0 if x else 1)
    )

    df_pltt = df_pltt[['Fecha', 'Unidad', 'flag']]

    return df_pltt


# In[26]:


# df_pltt=df_pltt_Ini.copy()
# df_pltt['flag'] = df_pltt.loc[:, 1:24].apply(lambda row: 0 if (row == 0).any() else 1, axis=1)
# df_pltt=df_pltt[['Fecha','Unidad','flag']]
# df_pltt


# #### Código para concurrencia de unidades

# In[27]:


import pandas as pd
import numpy as np
from collections import defaultdict, deque



# =========================================================
# PARÁMETROS GLOBALES
# =========================================================

RANDOM_SEED = 42                          # reproducibilidad
EPS = 1e-6                                # estabilidad numérica

# Control de concurrencia global (requisito 3)
PERC_CAP_HIST = 0.90     # percentil histórico para limitar K_t futuro por mes
MAX_SHIFT_DIAS = 3       # máximo corrimiento (± días) para redistribuir sin romper rachas
MAX_REASIGN_POR_DIA = 3  # cuántas rachas como máximo mover por día "congestivo"

rng = np.random.default_rng(RANDOM_SEED)


# =========================================================
# UTILIDADES BÁSICAS
# =========================================================
def prepara_historico(df: pd.DataFrame) -> pd.DataFrame:
    """
    Normaliza el histórico.
    Espera columnas: ['Fecha','Unidad','flag'] con flag ∈ {0,1} (1=disponible, 0=indisponible).
    """
    d = df.copy()
    d['Fecha'] = pd.to_datetime(d['Fecha'])
    d = d.sort_values(['Unidad','Fecha']).reset_index(drop=True)
    d['flag'] = d['flag'].astype(int).clip(0, 1)
    return d


def matriz_fuera_diaria(df: pd.DataFrame) -> pd.DataFrame:
    """
    Retorna una matriz diaria (index=Fecha, columnas=Unidad) con 0/1 indicando 'fuera'.
    """
    d = df.copy()
    d['fuera'] = 1 - d['flag']
    mat = d.pivot_table(index='Fecha', columns='Unidad', values='fuera', aggfunc='mean', fill_value=0)
    return (mat > 0.5).astype(int)


# =========================================================
# (1) PERSISTENCIA TIPO MARKOV POR UNIDAD Y MES
# =========================================================
def estima_transiciones_markov(df: pd.DataFrame) -> pd.DataFrame:
    """
    Estima, por unidad y mes, probabilidades de transición:
      p01 = P(fuera_t=1 | fuera_{t-1}=0, mes),
      p10 = P(fuera_t=0 | fuera_{t-1}=1, mes),
      pi1 = fracción histórica de días fuera (margen mensual).
    Retorna DataFrame ['Unidad','mes','p01','p10','pi1'].
    """
    d = df.copy()
    d = d.sort_values(['Unidad','Fecha'])
    d['mes'] = d['Fecha'].dt.month
    d['fuera'] = 1 - d['flag']
    d['fuera_prev'] = d.groupby('Unidad')['fuera'].shift()

    grupos = d.dropna(subset=['fuera_prev']).groupby(['Unidad','mes'])
    n00 = grupos.apply(lambda g: ((g['fuera_prev']==0) & (g['fuera']==0)).sum()).rename('n00')
    n01 = grupos.apply(lambda g: ((g['fuera_prev']==0) & (g['fuera']==1)).sum()).rename('n01')
    n10 = grupos.apply(lambda g: ((g['fuera_prev']==1) & (g['fuera']==0)).sum()).rename('n10')
    n11 = grupos.apply(lambda g: ((g['fuera_prev']==1) & (g['fuera']==1)).sum()).rename('n11')
    cnt  = pd.concat([n00, n01, n10, n11], axis=1).reset_index().fillna(0)

    # Suavizado bayesiano leve para evitar 0/1 puros
    cnt['p01'] = (cnt['n01'] + 0.5) / (cnt['n00'] + cnt['n01'] + 1.0)
    cnt['p10'] = (cnt['n10'] + 0.5) / (cnt['n10'] + cnt['n11'] + 1.0)

    # Margen pi1 mensual
    marg = d.groupby(['Unidad','mes'])['fuera'].mean().rename('pi1').reset_index()

    trans = cnt.merge(marg, on=['Unidad','mes'], how='outer').fillna(0.0)
    trans['p01'] = trans['p01'].clip(0.001, 0.999)
    trans['p10'] = trans['p10'].clip(0.001, 0.999)
    trans['pi1'] = trans['pi1'].clip(0.0, 1.0)
    return trans


# =========================================================
# (2) DETECCIÓN DE ALTA CONCURRENCIA (≥ 80%) Y CLUSTERIZACIÓN
# =========================================================
def pares_concurrencia_fuerte(df: pd.DataFrame, umbral: float = 0.80):
    """
    Detecta pares de unidades con concurrencia histórica 'alta'.
    Métrica usada: condicional simétrica alta:
        c_ij = min( P(j=1 | i=1), P(i=1 | j=1) )
    (Equivalente a exigir que, cuando una cae, la otra también cae con prob ≥ umbral.)
    Retorna lista de pares [(u1,u2), ...].
    """
    mat = matriz_fuera_diaria(df)  # Fecha x Unidad (0/1)
    U = mat.columns.tolist()

    pares = []
    # Precalcular tasas y co-ocurrencias
    tot = len(mat)
    sum_u = mat.sum(axis=0)  # días fuera por unidad
    for i in range(len(U)):
        ui = U[i]
        xi = mat[ui].values
        di = int(sum_u[ui])
        if di == 0:
            continue
        for j in range(i+1, len(U)):
            uj = U[j]
            xj = mat[uj].values
            dj = int(sum_u[uj])
            if dj == 0:
                continue
            both = int((xi & xj).sum())
            p_j_g_i = both / (di + EPS)
            p_i_g_j = both / (dj + EPS)
            c_ij = min(p_j_g_i, p_i_g_j)
            if c_ij >= umbral:
                pares.append((ui, uj))
    return pares


def clusters_desde_pares(pares):
    """
    Construye clústeres (componentes conexos) a partir de pares con alta concurrencia.
    Retorna lista de clusters: [set(unidades), ...].
    Unidades no conectadas quedan en clusters unitarios luego (más abajo).
    """
    # Grafo no dirigido
    adj = defaultdict(set)
    for a,b in pares:
        adj[a].add(b)
        adj[b].add(a)

    vistos = set()
    clusters = []

    for nodo in list(adj.keys()):
        if nodo in vistos: 
            continue
        # BFS/DFS
        comp = set()
        dq = deque([nodo])
        vistos.add(nodo)
        while dq:
            v = dq.popleft()
            comp.add(v)
            for w in adj[v]:
                if w not in vistos:
                    vistos.add(w)
                    dq.append(w)
        clusters.append(comp)

    return clusters


def clusters_fortificados(df: pd.DataFrame, umbral: float = 0.80):
    """
    Produce clusters de alta concurrencia (≥ umbral).
    Además, agrega como clusters unitarios a las unidades no incluidas.
    """
    mat = matriz_fuera_diaria(df)
    U = set(mat.columns.tolist())
    pares = pares_concurrencia_fuerte(df, umbral=umbral)
    base = clusters_desde_pares(pares)
    usados = set().union(*base) if base else set()
    # Añadir unidades solitarias
    for u in U - usados:
        base.append({u})
    return base


# =========================================================
# (3) SIMULACIÓN FUTURA CON PERSISTENCIA Y CLUSTERS FORZADOS
# =========================================================
def simula_markov_clusters(df: pd.DataFrame,
                           clusters: list[set],
                           trans: pd.DataFrame,
                           ini: pd.Timestamp,
                           fin: pd.Timestamp,
                           seed: int = 42) -> pd.DataFrame:
    """
    Simula futuro día a día con:
      - Persistencia por unidad (Markov mensual) para clusters unitarios.
      - Persistencia compartida por cluster (cadena común) para clusters de tamaño >1,
        forzando concurrencia (todas 'fuera' juntas).
    Estrategia de cluster (>1):
      - Se construye una cadena común por mes:
          p01_cluster = promedio de p01 de sus miembros (mes),
          p10_cluster = promedio de p10 de sus miembros (mes),
          pi1_cluster = promedio de pi1 de sus miembros (mes).
      - Se simula estado_cl(m) y se asigna a TODAS las unidades del cluster.
    Retorna DataFrame ['fecha','unidad','fuera'].
    """
    rng_local = np.random.default_rng(seed)
    dias = pd.date_range(ini, fin, freq='D')
    unidades_all = sorted(df['Unidad'].unique().tolist())

    # Mapas (Unidad, mes) -> parámetros Markov
    key = list(zip(trans['Unidad'], trans['mes']))
    map_p01 = {k: v for k, v in zip(key, trans['p01'])}
    map_p10 = {k: v for k, v in zip(key, trans['p10'])}
    map_pi1 = {k: v for k, v in zip(key, trans['pi1'])}

    # Prepara salida
    registros = []

    # Helper para simular cadena binaria con p01/p10 mensuales
    def simula_cadena(m, estado_prev, p01, p10):
        if estado_prev == 0:
            return 1 if rng_local.random() < p01 else 0
        else:
            return 0 if rng_local.random() < p10 else 1

    # Simulación cluster por cluster
    # Para clusters unitarios, se simula por unidad.
    # Para clusters >1, se simula una cadena común y se aplica a todos.
    # Estado inicial: se muestrea según pi1 del mes inicial.

    for cluster in clusters:
        cluster = sorted(list(cluster))
        if len(cluster) == 1:
            # --- CLUSTER UNITARIO: Markov individual ---
            u = cluster[0]
            estado_u = None
            for f in dias:
                m = f.month
                pi1 = map_pi1.get((u, m), 0.0)
                p01 = map_p01.get((u, m), 0.02)
                p10 = map_p10.get((u, m), 0.20)

                if estado_u is None:
                    estado_u = 1 if rng_local.random() < pi1 else 0
                else:
                    estado_u = simula_cadena(m, estado_u, p01, p10)

                if estado_u == 1:
                    registros.append({'fecha': f, 'unidad': u, 'fuera': 1})

        else:
            # --- CLUSTER >1: Markov común (fuerza concurrencia) ---
            # Parámetros cluster por mes = promedio de miembros
            # (robusto y suficiente para mantener persistencia)
            # Estado común:
            estado_c = None
            for f in dias:
                m = f.month
                # promedios
                p01_vals = [map_p01.get((u, m), 0.02) for u in cluster]
                p10_vals = [map_p10.get((u, m), 0.20) for u in cluster]
                pi1_vals = [map_pi1.get((u, m), 0.00) for u in cluster]

                p01_c = float(np.mean(p01_vals))
                p10_c = float(np.mean(p10_vals))
                pi1_c = float(np.mean(pi1_vals))

                if estado_c is None:
                    estado_c = 1 if rng_local.random() < pi1_c else 0
                else:
                    estado_c = 1 if simula_cadena(m, estado_c, p01_c, p10_c) == 1 else 0

                if estado_c == 1:
                    for u in cluster:
                        registros.append({'fecha': f, 'unidad': u, 'fuera': 1})

    return pd.DataFrame(registros)


# =========================================================
# (4) CONTROL DE CONCURRENCIA GLOBAL (RESTRICCIÓN SUAVE)
# =========================================================
def pmf_concurrencia_historica_por_mes(df: pd.DataFrame) -> pd.DataFrame:
    """
    PMF de concurrencia histórica por mes. Útil para fijar caps y diagnóstico.
    Retorna DataFrame ['mes','unidades_fuera','prob'] y también devuelve caps recomendados.
    """
    d = df.copy()
    d['fuera'] = 1 - d['flag']
    K = d.groupby('Fecha')['fuera'].sum().rename('K').reset_index()
    K['mes'] = K['Fecha'].dt.month
    pmf = K.groupby('mes')['K'].value_counts(normalize=True).rename('prob').reset_index()
    return pmf


def cap_concurrencia_por_mes_desde_hist(df: pd.DataFrame, perc: float = 0.90) -> dict:
    """
    Calcula un 'cap' mensual de concurrencia diaria K_t a partir del percentil histórico.
    Retorna dict: mes -> K_cap.
    """
    d = df.copy()
    d['fuera'] = 1 - d['flag']
    K = d.groupby('Fecha')['fuera'].sum().rename('K').reset_index()
    K['mes'] = K['Fecha'].dt.month
    Kcaps = {}
    for m, g in K.groupby('mes'):
        Kcaps[m] = int(np.ceil(g['K'].quantile(perc)))
    return Kcaps


def redistribuye_para_cap(df_fuera: pd.DataFrame,
                          Kcap_mes: dict,
                          max_shift: int = 3,
                          max_mover_por_dia: int = 3) -> pd.DataFrame:
    """
    Aplica una redistribución suave para que K_t futuro no exceda caps mensuales.
    Mantiene rachas (mueve bloques completos) hasta ±max_shift días dentro del mismo mes.
    Prioriza mover rachas más cortas primero (menos impacto).
    """
    if df_fuera.empty:
        return df_fuera

    # 1) Compactar a intervalos por unidad para manipular rachas
    df = df_fuera[['fecha','unidad']].copy()
    df = df.sort_values(['unidad','fecha']).reset_index(drop=True)
    df['g'] = df.groupby('unidad')['fecha'].apply(lambda s: (s.diff().dt.days.ne(1)).cumsum()).reset_index(level=0, drop=True)

    bloques = (
        df.groupby(['unidad','g'])
          .agg(fechaIni=('fecha','min'), fechaFin=('fecha','max'), dur=('fecha','count'))
          .reset_index()
    )

    # Mapa de concurrencia diaria actual
    K = df_fuera.groupby('fecha')['unidad'].nunique().rename('K').to_frame()
    fechas_all = pd.date_range(df_fuera['fecha'].min(), df_fuera['fecha'].max(), freq='D')
    K = K.reindex(fechas_all).fillna(0).astype(int)
    K['mes'] = K.index.to_series().dt.month

    # Ordenar bloques (cortos primero)
    bloques = bloques.sort_values('dur').reset_index(drop=True)

    # Función auxiliar para probar mover un bloque a un nuevo inicio
    def puede_mover(unidad, ini_old, fin_old, ini_new):
        dur = (fin_old - ini_old).days + 1
        fin_new = ini_new + pd.Timedelta(days=dur-1)
        # mismo mes
        if ini_new.month != ini_old.month or fin_new.month != fin_old.month:
            return False, None, None
        # chequear cap
        rango = pd.date_range(ini_new, fin_new, freq='D')
        for f in rango:
            if (K.loc[f, 'K'] + 1) > Kcap_mes.get(f.month, 999):
                return False, None, None
        return True, ini_new, fin_new

    # Intentar aliviar días que exceden cap
    excedidos = K[K['K'] > K['mes'].map(Kcap_mes)].index.tolist()
    # Iterar días excedidos; por cada día, mover hasta 'max_mover_por_dia' bloques
    for f in excedidos:
        movidos = 0
        if movidos >= max_mover_por_dia:
            continue

        # Buscar bloques que cubran f (candidatos)
        cand = bloques[(bloques['fechaIni'] <= f) & (bloques['fechaFin'] >= f)]
        # Ordenar candidatos por dur ascendente
        cand = cand.sort_values('dur')

        for _, row in cand.iterrows():
            if movidos >= max_mover_por_dia:
                break
            u, ini, fin, dur = row['unidad'], row['fechaIni'], row['fechaFin'], row['dur']

            # Probar corrimientos -max_shift..+max_shift excepto 0
            ok = False
            for delta in list(range(1, max_shift + 1)) + list(range(-1, -max_shift - 1, -1)):
                ini_new = ini + pd.Timedelta(days=delta)
                puede, a, b = puede_mover(u, ini, fin, ini_new)
                if puede:
                    # Actualizar concurrencia diaria: liberar días viejos y ocupar nuevos
                    for ff in pd.date_range(ini, fin, freq='D'):
                        K.loc[ff, 'K'] = max(0, K.loc[ff, 'K'] - 1)
                    for ff in pd.date_range(a, b, freq='D'):
                        K.loc[ff, 'K'] = K.loc[ff, 'K'] + 1

                    # Actualizar bloque en DataFrame 'bloques' usando su índice real
                    idx_row = row.name
                    bloques.at[idx_row, 'fechaIni'] = a
                    bloques.at[idx_row, 'fechaFin'] = b

                    ok = True
                    movidos += 1
                    break  # salir del ciclo delta si se movió
            # si logramos mover alguno, seguimos al siguiente candidato

    # Reconstruir df_fuera a partir de bloques reubicados
    registros = []
    for _, r in bloques.iterrows():
        for f in pd.date_range(r['fechaIni'], r['fechaFin'], freq='D'):
            registros.append({'fecha': f, 'unidad': r['unidad'], 'fuera': 1})

    df_new = pd.DataFrame(registros)
    return df_new


# =========================================================
# (5) COMPACTACIÓN Y DIAGNÓSTICO
# =========================================================
def compacta_intervalos(df_fuera: pd.DataFrame) -> pd.DataFrame:
    """
    Compacta días consecutivos por unidad en intervalos [fechaIni, fechaFin].
    Salida: ['unidad','fechaIni','fechaFin','Pini','Pfin'] con 1–24.
    """
    if df_fuera.empty:
        return pd.DataFrame(columns=['unidad','fechaIni','fechaFin','Pini','Pfin'])

    d = df_fuera.sort_values(['unidad','fecha']).reset_index(drop=True)
    d['g'] = d.groupby('unidad')['fecha'].apply(lambda s: (s.diff().dt.days.ne(1)).cumsum()).reset_index(level=0, drop=True)

    res = (
        d.groupby(['unidad','g'], as_index=False)
         .agg(fechaIni=('fecha','min'), fechaFin=('fecha','max'))
    )
    res['Pini'] = 1
    res['Pfin'] = 24
    return res[['unidad','fechaIni','fechaFin','Pini','Pfin']].sort_values(['unidad','fechaIni']).reset_index(drop=True)


def diagnostico_concurrencia(df_fuera: pd.DataFrame):
    """
    Concurrencia futura diaria y PMFs (para control/calibración).
    """
    conc = (
        df_fuera.groupby('fecha')['unidad']
                .nunique()
                .rename('unidades_fuera')
                .reset_index()
    )
    conc['mes'] = conc['fecha'].dt.month
    pmf_mes_fut = (
        conc.groupby('mes')['unidades_fuera']
            .value_counts(normalize=True)
            .rename('prob')
            .reset_index()
    )
    pmf_global_fut = (
        conc['unidades_fuera']
            .value_counts(normalize=True)
            .rename_axis('unidades_fuera')
            .reset_index(name='prob')
    )
    return conc, pmf_mes_fut, pmf_global_fut


# =========================================================
# (6) ORQUESTADOR PRINCIPAL — CUMPLE TUS 3 REQUISITOS
# =========================================================
def plan_indisponibilidad(df: pd.DataFrame,FUTURO_INI,FUTURO_FIN,
                                    umbral_concurrencia_fuerte: float = 0.80,
                                    aplicar_cap: bool = True) -> dict:
    """
    Pipeline completo que cumple:
    1) Rachas realistas (persistencia) por unidad (Markov mensual).
    2) Si concurrencia histórica entre unidades ≥ umbral (default 80%),
       se fuerzan como clúster que cae junto en la proyección (p.ej., ciclo combinado G/V).
    3) Control de concurrencia global: evita “muchas” indisponibilidades el mismo día
       comparado con histórico, con un cap por mes y redistribución suave de rachas.

    Returns:
      {
        'plan_intervals': DataFrame ['unidad','fechaIni','fechaFin','Pini','Pfin'],
        'concurrencia_diaria': DataFrame ['fecha','unidades_fuera','mes'],
        'pmf_mes_futura': DataFrame PMF mensual de concurrencia,
        'pmf_global_futura': DataFrame PMF global de concurrencia,
        'clusters': lista de sets (clústeres detectados),
        'Kcap_mes': dict (si aplicar_cap=True)
      }
    """
    # --- Preparación histórica ---
    df_hist = prepara_historico(df)

    # --- Persistencia por unidad (Markov mensual) ---
    trans = estima_transiciones_markov(df_hist)

    # --- Clusters de concurrencia fuerte (≥80%) ---
    clusters = clusters_fortificados(df_hist, umbral=umbral_concurrencia_fuerte)

    # --- Simulación futura con clusters y persistencia ---
    df_fuera = simula_markov_clusters(df_hist, clusters, trans, FUTURO_INI, FUTURO_FIN, seed=RANDOM_SEED)
    # df_fuera: ['fecha','unidad','fuera'=1]

    # --- Control de concurrencia global (cap mensual + redistribución suave) ---
    Kcap_mes = {}
    if aplicar_cap:
        Kcap_mes = cap_concurrencia_por_mes_desde_hist(df_hist, perc=PERC_CAP_HIST)
        df_fuera = redistribuye_para_cap(df_fuera, Kcap_mes, max_shift=MAX_SHIFT_DIAS, max_mover_por_dia=MAX_REASIGN_POR_DIA)

    # --- Salida final compactada para optimización ---
    plan_intervals = compacta_intervalos(df_fuera)

    # --- Diagnóstico de concurrencia generada ---
    conc_fut, pmf_mes_fut, pmf_global_fut = diagnostico_concurrencia(df_fuera)

    return {
        'plan_intervals': plan_intervals,
        'concurrencia_diaria': conc_fut,
        'pmf_mes_futura': pmf_mes_fut,
        'pmf_global_futura': pmf_global_fut,
        'clusters': clusters,
        'Kcap_mes': Kcap_mes
    }





# In[28]:


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
    UsuXM=data['Pws']['UsuarioXm']
    PwsXM=data['Pws']['PwsXm']

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


    file_path=os.path.join(sPathAE + f"{int(year):00d}" + "-" + f"{int(mes):02d}" ,Carpeta)



    df_pltt=get_data(FechaInicialLP,FechaFinalLP,UsuXM,PwsXM,DownFTP)


    anio = int(yearIniLP)
    fecha = dt.date(anio, 1, 1)
    fecha_str = fecha.strftime("%Y-%m-%d")
    FUTURO_INI = pd.Timestamp(fecha_str)   # horizonte futuro: inicio

    anio = int(yearFinLP)
    fecha = dt.date(anio, 12, 31)
    fecha_str = fecha.strftime("%Y-%m-%d")    
    FUTURO_FIN = pd.Timestamp(fecha_str)   # horizonte futuro: fin

    # =========================================================
    # USO EJEMPLO:
    # =========================================================
    resultados = plan_indisponibilidad(df_pltt,FUTURO_INI,FUTURO_FIN)  # df con ['Fecha','Unidad','flag']
    plan = resultados['plan_intervals']
    print(plan.head())
    print("Clusters detectados:", resultados['clusters'])
    print("Caps por mes:", resultados['Kcap_mes'])


# In[31]:


    file_path=Path(file_path)
    plan.to_csv(file_path.joinpath('Indisponibilidad.csv'),index=False)


    # Crear ventana raíz oculta
    root = tk.Tk()
    root.withdraw()
    root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano
    messagebox.showinfo('Estado del proceso','Se imprimió el archivo de excel con los mmtos correctamente', parent=root)

except:

    root = tk.Tk()
    root.withdraw()
    root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano
    messagebox.showerror('Estado del proceso','Error en el proceso, por favor validar', parent=root) 