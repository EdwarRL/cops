$EOLCOM //

*Llamar el archivo con el sql2gams
$call =sql2gms @DatosBD_COPS.txt

Parameters
**  Informaci�n para el UC **
GenPru(plt,t) Carga de genración para prueba
;

**Carga de la informacion al GDX
$gdxin DatosBD_COPS.gdx
$load GenPru