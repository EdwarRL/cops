#!/usr/bin/env python
# coding: utf-8
from pathlib import Path 
import json
import os
import tkinter as tk
from tkinter import messagebox

def DownloadMmtosSIO(FechaInicial: str, FechaFinal: str, Carpeta: str,year: str,mes:str, usuarioSIO:str,pws:str,sPathAE:str) -> str:

        from selenium import webdriver
        from selenium.webdriver.chrome.service import Service
        from selenium.webdriver.common.by import By
        from selenium.webdriver.chrome.options import Options
        # from webdriver_manager.chrome import ChromeDriverManager
        from selenium.webdriver.support.ui import WebDriverWait, Select
        from selenium.webdriver.support import expected_conditions as EC
        from selenium.webdriver.common.keys import Keys
        import time
        import shutil
        import datetime as dt

        options = Options()


        def getMes(Fecha):
            # Convert to datetime object
            oDate = dt.datetime.strptime(Fecha,'%d/%m/%Y')

            # Get month as number
            month_number = oDate.month
            iyear=oDate.year
            # print("Month number:", month_number)

            if month_number == 1:
                sMes='ene.'
            elif month_number == 2:
                sMes='feb.'
            elif month_number == 3:
                sMes='mar.'
            elif month_number == 4:
                sMes='abr.'
            elif month_number == 5:
                sMes='may.'
            elif month_number == 6:
                sMes='jun.'
            elif month_number == 7:
                sMes='jul.'
            elif month_number == 8:
                sMes='ago.'
            elif month_number == 9:
                sMes='sept.'
            elif month_number == 10:
                sMes='oct.'
            elif month_number == 11:
                sMes='nov.'
            elif month_number == 12:
                sMes='dic.'
            else:
                sMes='No se encontró el mes'


            return sMes, month_number, iyear


        # In[ ]:


        #Obtener informaón de cada fecha
        sMesIni, iMesIni, iyearIni = getMes(FechaInicial)
        sMesFin, iMesFin, iyearFin = getMes(FechaFinal)

        print(sMesIni,sMesFin)


        # In[4]:


        file_path = r'C:\Users\eramirez\Downloads\Mangen.xlsx'  # Replace with your path

        # Check if file exists before deleting
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"✅ File deleted: {file_path}")
        else:
            print(f"❌ File not found: {file_path}")


        # In[5]:


        # Configurar navegador
        options = Options()
        options.add_argument("--start-maximized")
        driver = webdriver.Chrome(options=options)

        # # Crear el navegador con ChromeDriver automáticamente
        # driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

        # URL de login
        driver.get("https://sio.xm.com.co")  # Reemplaza por la URL que necesitas

        # Esperar que el input de usuario esté presente
        wait = WebDriverWait(driver, 30)


        # In[6]:


        # Localizar e ingresar el usuario
        usuario = driver.find_element(By.ID, "login")  # también puedes usar By.CSS_SELECTOR con [formcontrolname='user']
        usuario.clear()
        usuario.send_keys(usuarioSIO)

        # Localizar e ingresar la contraseña (ajusta el selector según el campo real)
        contrasena = driver.find_element(By.ID, "password")  # ← Cambia esto si el campo tiene otro ID
        contrasena.clear()
        contrasena.send_keys(pws)


        # In[7]:


        # Hacer clic en el botón de login (ajusta el selector si es diferente)
        boton_login = driver.find_element(By.XPATH, '//*[@id="single-spa-application:@sio/login"]/sio-login-root/div/div/div/div/div[1]/form/button')
        boton_login.click()


        # In[8]:


        # Seleccionar la compañía del desplegable
        select_element = wait.until(EC.presence_of_element_located((By.ID, "selectCompanies")))
        select = Select(select_element)
        select.select_by_visible_text("TERMOBARRANQUILLA S.A. EMPRESA DE SERVICIOS PUBLICOS")


        # In[9]:


        # Seleccionar la compañía del desplegable
        select_element = wait.until(EC.presence_of_element_located((By.ID, "selectRol")))
        select = Select(select_element)
        select.select_by_visible_text("Transportador/Generador")


        # In[10]:


        # Hacer clic en el botón de login (ajusta el selector si es diferente)
        boton_Aceptar= driver.find_element(By.XPATH, '//*[@id="btnFormCompanies"]')
        boton_Aceptar.click()


        # In[11]:


        wait.until(EC.visibility_of_element_located((By.XPATH, "//div[contains(@class, 'sio-card-dashboard')]//a[text()=' Reportes ']")))
        time.sleep(20) 


        # In[12]:


        botones = driver.find_elements(By.CSS_SELECTOR, "button.ico-arrow-botton")
        botones[1].click() 


        # In[13]:


        wait.until(EC.element_to_be_clickable((By.XPATH, "//span[text()='Mangen - Progman - Pruebas de generación']"))).click()


        # In[14]:


        wait.until(EC.visibility_of_element_located((
            By.XPATH,
            "//h1[text()='Reportes / Mangen - Progman - Pruebas de generación']"
        )))

        time.sleep(20)  # pequeña pausa para que Syncfusion actualice el chip


        # In[15]:


        checkboxes = driver.find_elements(By.CSS_SELECTOR, "span.e-ripple-container")
        checkboxes[0].click()
        checkboxes[3].click()


        # In[16]:


        # 1. Abrir calendario del campo startDate
        calendario = wait.until(EC.element_to_be_clickable((
            By.XPATH,
            "//sio-date-reactive[@formcontrolname='startDate']//span[contains(@class, 'k-select')]"
        )))
        calendario.click()

        wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "kendo-calendar .k-button"))).click()
        wait.until(EC.element_to_be_clickable((By.XPATH, "//td//span[contains(text(), '" + sMesIni + "')]"))).click()

        # Selección de día
        input_fecha = wait.until(EC.presence_of_element_located((
            By.XPATH,
            "//sio-date-reactive[@formcontrolname='startDate']//input[contains(@class, 'k-input')]"
        )))

        # Establecer fecha
        # input_fecha.clear()
        input_fecha.send_keys(FechaInicial)
        input_fecha.send_keys(Keys.ENTER)  # Aceptar la fecha (si es necesario)


        # In[17]:


        # 1. Abrir calendario del campo startDate
        calendario = wait.until(EC.element_to_be_clickable((
            By.XPATH,
            "//sio-date-reactive[@formcontrolname='endDate']//span[contains(@class, 'k-select')]"
        )))
        calendario.click()

        wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "kendo-calendar .k-button"))).click()
        wait.until(EC.element_to_be_clickable((By.XPATH, "//td//span[contains(text(), '" + sMesFin + "')]"))).click()

        # Selección de día
        input_fecha = wait.until(EC.presence_of_element_located((
            By.XPATH,
            "//sio-date-reactive[@formcontrolname='endDate']//input[contains(@class, 'k-input')]"
        )))

        # Establecer fecha
        # input_fecha.clear()
        input_fecha.send_keys(FechaFinal)
        input_fecha.send_keys(Keys.ENTER)  # Aceptar la fecha (si es necesario)



        # In[18]:


        from selenium.webdriver.common.by import By
        from selenium.webdriver.support import expected_conditions as EC
        from selenium.webdriver.common.keys import Keys
        import time

        # Buscar el input en cada iteración (ya que puede re-renderizarse)
        input_field = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "input.e-dropdownbase")))

        driver.execute_script("""
            var multiselect = document.querySelector('#siomultiselect').ej2_instances[0];
            multiselect.value = [];
            multiselect.dataBind();
        """)
        # Lista de opciones a seleccionar
        opciones = ["Analisis CND",'Aprobada','EnEjecucion','Ingresada','Solicitada']

        for opcion in opciones:

            input_field.send_keys(opcion)
            input_field.send_keys(Keys.ENTER)
            time.sleep(30)  # pequeña pausa para que Syncfusion actualice el chip


        # In[19]:


        checkboxes[0].click()


        # In[20]:


        # Esperar a que el botón esté visible y habilitado
        boton_consultar = wait.until(EC.element_to_be_clickable((By.ID, "filtroconsignements")))

        # Hacer clic en el botón
        boton_consultar.click()

        time.sleep(30) 


        # In[21]:


        # 1. Guardar ventana original
        ventana_original = driver.current_window_handle

        # 2. Guardar ventanas antes del clic
        ventanas_antes = set(driver.window_handles)


        # In[22]:


        # Esperar a que el botón esté visible y habilitado
        boton_reporte = wait.until(EC.element_to_be_clickable((By.ID, "btnReporteMangen")))

        # Hacer clic en el botón
        boton_reporte.click()

        time.sleep(20) 


        # In[23]:


        # 3. Esperar y obtener la nueva ventana
        wait.until(lambda d: len(set(d.window_handles) - ventanas_antes) == 1)
        nueva_ventana = list(set(driver.window_handles) - ventanas_antes)[0]

        # 4. Cambiar a la nueva ventana
        driver.switch_to.window(nueva_ventana)


        # In[24]:


        # Esperar a que el botón de exportar esté clickeable
        boton_exportar = wait.until(EC.element_to_be_clickable((By.ID, "reportViewer_Control_toolbar_export")))

        # Hacer clic
        boton_exportar.click()


        # In[25]:


        opcion_excel = wait.until(EC.element_to_be_clickable((
            By.XPATH,
            "//li[normalize-space()='Excel']"
        )))
        opcion_excel.click()

        time.sleep(30) 


        # In[26]:


        # Cerrar la ventana del reporte
        driver.close()


        # In[27]:


        # Volver a la ventana principal (la que habías guardado antes)
        driver.switch_to.window(ventana_original)


        # In[28]:


        # Cerrar la ventana del reporte
        driver.close()


        # In[ ]:


        # Get the current user's Downloads folder
        downloads_path = Path.home() / "Downloads"

        # Define source and destination paths
        source_path = os.path.join(downloads_path,'Mangen.xlsx')

        destination_path = sPathAE + f"{int(year):00d}" + "-" + f"{int(mes):02d}" +  r"\\" + Carpeta + r"\\Mangen.xlsx"


        # Check if file exists before deleting
        if not os.path.exists(destination_path):
            # Copy the file
            shutil.copy(source_path, destination_path)
            os.remove(source_path)
            msj=print(f"✅ File copied to: {destination_path}")
        else:
            msj=print(f"❌ File already exist: {destination_path}")


        return msj
# In[ ]:

if 1==1:
# try:
    # Ruta del archivo
    sFile=r"Parametros.json"
    script_dir = Path(__file__).resolve()
    script_dir=script_dir.parent.parent.parent
    sPathfile=os.path.join(script_dir,r"Modules\Utils\ArchivosAux",sFile)
    sPathfile

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
    sPathAE=data['Paths']['AEnerPath']

    msj=DownloadMmtosSIO(FechaInicial, FechaFinal, Carpeta,year,mes,usuarioSIO,pws,sPathAE)

    # Crear ventana raíz oculta
    root = tk.Tk()
    root.withdraw()
    root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano
    messagebox.showinfo('Estado del proceso','Se descargaron los matenimientos', parent=root)

# except:
    
#     root = tk.Tk()
#     root.withdraw()
#     root.attributes("-topmost", True)  # ✅ Hace que los messagebox estén en primer plano
#     messagebox.showerror('Estado del proceso','Error en el proceso de descarga de información de SIO, por favor validar', parent=root)  