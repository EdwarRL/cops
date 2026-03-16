$EOLCOM //

// TODO: El tiempo fuera de linea se debe contant es con el commitmen de la unidad teniendo en cuenta la bandera > 0 y no la de firme
// TODO: Para determinar el estado térmico con el que arranca la planta se tiene en cuenta el estado térmico de las unidades cuando quedan en firme y no en el momento del pasan de cero a un valor
//       lo anterior teniendo en cuenta que la unica certeza de que todas las unidades arrancan es en ese momento y no antes dado que que la planta va arrancando undiades y la información de cómo se
//       da este arranque no se tiene. Una puede ser determinar el estado térmico de todas las unidades en el momento  que la planta de cero a un valor y alicar las rampas a partir de ese periodo con el estado
//       térmico de la planta determinado por el estado térmico de las undiades. Otra opción  más compleja es que vaya arrancando unidades e ir determinando el estado térmico a medidad que se encienden.
//       TODO: Agragar restricción que relacione las unidades que debe llevar cada configuración tanto de combustión como de vapor

// TODO: Agregar restricción para cuando una planta hace rampas tiene que tener cero en el periodo despues de terminar las rampas
// TODO: Agregar restricción para que sólo se active bandera de rampas o en firme para las unidades
// TODO: Agregar restrción para que los el on-off en firme esté distanciado exactamente el valor de las rampas de cuando entra o cuando sale
// TODO: Agregar restricción para que el on-off de las rampas de entrada se tomen de acuerdo a la configuración que está entrando o saliendo

* mathematical formulation

eTotalCost ..
   vTotalCost
   =e=
   sum[(pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf)), pThermalCCVarCost(pltt_cc,conf)*vGenThermalPltConfCC(pltt_cc,conf,p )]+
   sum[(pltt_cs,p), pThermalCSVarCost(pltt_cs)*vGenThermalPltCS(pltt_cs,p )]+
   sum[(plt_h,p  ), pHydroVarCost   (      plt_h       )*vGenHydroPlt (plt_h,p           )]+
   sum[(plt_v,p  ), pVarVarCost   (      plt_v       )*vGenVarPlt (plt_v,p           )]+
   sum[(uni_t,fuel,tstate,p)$uni_fuel(uni_t,fuel),pStartUpCost(uni_t,fuel,tstate)*vStartUpUniFuelTE(uni_t,fuel,tstate,p)]+
   sum[(p,sba    ), pENSCost*vENS(p,sba)]
*   sum[(p), pENSCost*vENS(p)]
;


parameter
bMC /1/;

parameter
banAux /1/;

// General Equations *********************************************************************
eBalance(p) ..
   sum[plt, vGenPlt(plt,p)] =e= sum[sba,pDemandSba(p,sba)-vENS(p,sba)]
*sum[plt, vGenPlt(plt,p)] -vENS(p) =e= sum[sba,pDemandSba(p,sba)]
;

eHydroGen(plt_h,p) ..
   vGenHydroPlt (plt_h,p ) =e=  vGenPlt(plt_h,p)
;

eVariableGen(plt_v,p) ..
   vGenVarPlt (plt_v,p ) =e=  vGenPlt(plt_v,p)
;


// Unit constraitns *******************************************************


eThermalUniDisp    (uni_t,p        )  ..
   vGenUniM2        (uni_t,p)         =l= pThmMaxprodUni(uni_t,p)*vCommitmentUni(uni_t,p)
;

eThermalMTUni   (uni_t,p         )$(banAux=1)  ..
   vGenUniM2        (uni_t,p)         =g= sum[(fuel)$uni_fuel (uni_t,fuel),pTMinProd(uni_t,fuel)*vCommitmentUniFuel(uni_t,fuel,p)]$(not pCasoPID)
                                        - sum[(plt_t)$plt_uni(plt_t,uni_t) ,pThmMaxprodUni(uni_t,p)*(1-vCommitTrmPlt(plt_t,p))]$(not pCasoPID)
                                        + sum[(fuel)$uni_fuel (uni_t,fuel),0.001*vCommitmentUniFuel(uni_t,fuel,p)]$(pCasoPID)
                                        - sum[(plt_t)$plt_uni(plt_t,uni_t) ,pThmMaxprodUni(uni_t,p)*(1-vCommitTrmPlt(plt_t,p))]$(pCasoPID)
;

eCmmitUniCommitPltRelation(uni_t,p)..
  vCommitmentUni(uni_t,p) =l= sum[(plt_t)$plt_uni(plt_t,uni_t),vCommitTrmPlt(plt_t,p)]
;


eTotalThmOutPutUni(uni_t,p)..
   vGenUni(uni_t,p) =e= [vGenUniM2(uni_t,p) + vGenUniURM1(uni_t,p) + vGenUniDRM1(uni_t,p)]$(not pCasoPID)
                       + [vGenUniM2(uni_t,p)]$(pCasoPID)
;

eCommitUniFuel(uni_t,p)..
   vCommitmentUni(uni_t,p) =e= sum[(fuel)$uni_fuel (uni_t,fuel),vCommitmentUniFuel(uni_t,fuel,p)]

;

eHydroUniDisp    (uni_h,p          )  ..
   vGenUni        (uni_h,p) =l= pHydMaxprodUni(uni_h,p) * vCommitmentUni(uni_h,p)
;

eHydroMTUni   (uni_h,p         )  ..
   vGenUni(uni_h,p) =g= [pHydroMinProd(uni_h) * vCommitmentUni(uni_h,p)]$(not pCasoPID)
                        + [0.001 * vCommitmentUni(uni_h,p)]$(pCasoPID)
;

eVarUniDisp    (uni_v,p         )  ..
   vGenUni        (uni_v,p)         =l= pVarMaxprodUni(uni_v,p)*vCommitmentUni(uni_v,p)
;

eVarMTUni   (uni_v,p          )  ..
   vGenUni(uni_v,p)  =g= [pVarMinProd(uni_v) * vCommitmentUni(uni_v,p)]$(not pCasoPID)
                        + [0.01 * vCommitmentUni(uni_v,p)]$(pCasoPID)
;

eThermalUniDispMC(uni_t,p)$(bMC=1 and not pCasoPID) ..
   vGenUni(uni_t,p) =l= pThmMaxprodUni(uni_t,p) * vCommitmentUniMC(uni_t,p)
;

eThermalMCUni(uni_t,p)$(bMC=1 and not pCasoPID)..
   vGenUni(uni_t,p) =g= 0.1*vCommitmentUniMC(uni_t,p)
;

* Plant-unit relationship total
eGenPlantUni(plt,p)..
   vGenPlt(plt,p) =e= sum[(uni)$plt_uni(plt,uni),vGenUni(uni,p)]
;

// TODO: Cuadrar esta ecuación para que la identificación de los CS con más de una unidad no haga doble iteración en pltt_cs y para que se incluyan las unidades hidráulicas y de cc
//       también quitar pltt_cs1 que está como alias
ePruUni(uni,p)$(pPruebasUni(uni,p)>0 and not pCasoPID and 0=1)..
   vGenUni(uni,p)=e=pMaxprodUni(uni,p)$(not pCasoIDE)
                  + min(sum((pltt_cs)$(plt_uni(pltt_cs,uni) and sum((pltt_cs1)$plt_uni(pltt_cs1,uni),1)=1),pDispCom(pltt_cs,p)),pMaxprodUni(uni,p))$(pCasoIDE)
;


eDispCOM(plt,p)$(pCasoIDE and 1=0)..
   vGenPlt(plt,p)=l=pDispCom(plt,p)
;

// **********************************************************************************************

// Startup and Shutdown constrints (M1 and M2) *************************************************************

// Ramps constraints
eTotalThmOutPut(plt_t,p)  ..
   vGenPlt(plt_t,p) =e= [vGenTrmPltM2(plt_t,p) + vGenTrmPltURM1(plt_t,p) + vGenTrmPltDRM1(plt_t,p)]$(not pCasoPID)
                     + [vGenTrmPltM2(plt_t,p)]$(pCasoPID)
;

* Plant-unit ratio M2
eGenPlantUniM2(plt_t,p)..
   vGenTrmPltM2(plt_t,p) =e= sum[(uni_t)$plt_uni(plt_t,uni_t),vGenUniM2(uni_t,p)]
;

* Plant-unit ratio M1 StartUp
eGenPlantUniM1StartUp(plt_t,p)$(not pCasoPID)..
   vGenTrmPltURM1(plt_t,p) =e= sum[(uni_t)$plt_uni(plt_t,uni_t),vGenUniURM1(uni_t,p)]
;

* Plant-unit ratio ShutDown
eGenPlantUniM1ShutDoww(plt_t,p)$(not pCasoPID)..
   vGenTrmPltDRM1(plt_t,p) =e= sum[(uni_t)$plt_uni(plt_t,uni_t),vGenUniDRM1(uni_t,p)]
;

eUpDownRatio(uni_t,p)$[ord(p) gt 1] ..
   vCommitmentUni(uni_t,p) - vCommitmentUni(uni_t,p-1) =e= vStartUpUni(uni_t,p) - vShutDownUni(uni_t,p)
;

// TODO: Validar si el 1 aplica con el tiempo en línea y la generación, esto debido a que es posible que haciendo la rampa cuente cono si estuviera en línea
eUpDownRatioCI(uni_t,p)$[ord(p) eq 1 ] ..
   vCommitmentUni(uni_t,p) - [onoff_t0Uni(uni_t)]$( not pCasoPID) - 1$(pCasoPID and pGenUniIni(uni_t)>0) =e= vStartUpUni(uni_t,p) - vShutDownUni(uni_t,p)
;

eUpDownRatioMC(uni_t,p)$[ord(p) gt 1 and (bMC=1) and (not pCasoPID)] ..
   vCommitmentUniMC(uni_t,p) - vCommitmentUniMC(uni_t,p-1) =e= vStartUpUniMC(uni_t,p) - vShutDownUniMC(uni_t,p)
;

// TODO: Validar si el 1 aplica con el tiempo en línea y la generación, esto debido a que es posible que haciendo la rampa cuente cono si estuviera en línea
eUpDownRatioCIMC(uni_t,p)$[ord(p) eq 1 and (bMC=1) and (not pCasoPID)] ..
   vCommitmentUniMC(uni_t,p) - 1$(pGenUniIni(uni_t)>0) =e= vStartUpUniMC(uni_t,p) - vShutDownUniMC(uni_t,p)
;

eUpDownSingularity(uni_t, p) ..
   vStartUpUni(uni_t,p) + vShutDownUni(uni_t,p) =l= 1
;


eUpDownSingularityMC(uni_t, p)$(bMC=1 and (not pCasoPID)) ..
   vStartUpUniMC(uni_t,p) + vShutDownUniMC(uni_t,p) =l= 1
;


//*******************************************************************************************************

// Thermal unit constraints *****************************************************************************

*Realtion between unit StartUp and Fuel
eStFuelRatio(uni_t, p)..
   vStartUpUni(uni_t,p)=e=sum[(fuel)$uni_fuel (uni_t,fuel),vStartUpUniFuel(uni_t,fuel,p)]
;

*Realtion between unit StartUp and Fuel
eStFuelRatio_MC(uni_t, p)..
   vStartUpUniMC(uni_t,p)=e=sum[(fuel)$uni_fuel (uni_t,fuel),vStartUpUniFuelMC(uni_t,fuel,p)]
;

eStFuelTERatio(uni_t,fuel, p)$(uni_fuel (uni_t,fuel))..
   vStartUpUniFuel(uni_t,fuel,p)=e=sum[(tstate),vStartUpUniFuelTE(uni_t,fuel,tstate,p)]
;

eDnFuelRatio(uni_t, p)$(not pCasoPID)..
   vShutDownUni(uni_t,p)=e=sum[(fuel)$uni_fuel(uni_t,fuel),vShutDownUniFuel(uni_t,fuel,p)]
;

eDnFuelRatioMC(uni_t, p)$(bMC=1 and (not pCasoPID))..
   vShutDownUniMC(uni_t,p)=e=sum[(fuel)$uni_fuel(uni_t,fuel),vShutDownUniFuelMC(uni_t,fuel,p)]
;

* // TODO:  Hacer pruebas unitarias y poner la condición inicial, revisar fronteras como p=1
* eMTL  (uni_t, fuel, p)$(uni_fuel(uni_t,fuel) and pMinUpT(uni_t,fuel)>0) ..
*    sum[pp$([ord(pp) ge (ord(p) - pMinUpT(uni_t,fuel) + 1)] and [ord(pp) le ord(p)]), vStartUpUniFuel(uni_t,fuel,pp)] =l= vCommitmentUni(uni_t,p)
* ;

* // TODO:  Hacer pruebas unitarias y poner la condición inicial, revisar fronteras como p=1
*  eMTFL(uni_t, fuel, p )$(uni_fuel(uni_t,fuel) and pMinDownT(uni_t,fuel))..
*    sum[pp$([ord(pp) ge (ord(p) - pMinDownT(uni_t,fuel) + 1)] and [ord(pp) le ord(p)]), vShutDownUniFuel(uni_t,fuel,pp)] =l= 1 - vCommitmentUni(uni_t,p)
*;

// TODO:  Esta restricción es para dejar en línea fuera de linea la undiad según el tiempo que le falta y como venga en la condición inicla
eMTL_CI(uni_t, fuel, p)$[L_up_minUni(uni_t,fuel) gt 0 and ord(p) le L_up_minUni(uni_t,fuel) and uni_fuel(uni_t,fuel) and pRestUni(uni_t)=0 and 1=1 and (not pCasoPID)] ..
   vCommitmentUni(uni_t,p)=e= onoff_t0Uni(uni_t)
;

eMTFL_CI(uni_t, fuel, p)$[L_down_minUni(uni_t,fuel) gt 0 and ord(p) le L_down_minUni(uni_t,fuel) and uni_fuel(uni_t,fuel) and pRestUni(uni_t)=0 and 1=1 and (not pCasoPID)] ..
   vCommitmentUniMC(uni_t,p)=e= onoff_t0Uni(uni_t)
;

eMTL(uni_t, fuel, p)$ (uni_fuel(uni_t,fuel) and pRestUni(uni_t)=0 and (not pCasoPID)) ..
   sum[pp$[ord(pp) ge ord(p) - pMinUpT(uni_t,fuel) + pCountOnUni(uni_t)$[ord(pp) eq 1] + 1 and ord(pp) le ord(p)], vStartUpUniFuel(uni_t,fuel,pp)] =l= vCommitmentUni(uni_t,p)
;

eMTL_MC(uni_t, fuel,p)$ (pRestUni(uni_t)=0 and (not pCasoPID)) ..
   sum[pp$[ord(pp) ge ord(p) - pMinUpT(uni_t,fuel) + 1 and ord(pp) le ord(p)], vStartUpUniFuelMC(uni_t,fuel,pp)] =l= vCommitmentUniMC(uni_t,p)
;

* eMTFL(uni_t, fuel, p)$ (uni_fuel(uni_t,fuel) and (sameas(uni_t,'FLORES_1_GAS') or sameas(uni_t,'FLORES_1_VAPOR'))) ..
eMTFL(uni_t, fuel, p)$ (uni_fuel(uni_t,fuel) and pRestUni(uni_t)=0 and (not pCasoPID)) ..
   sum[pp$[ (ord(pp) ge ord(p)-pMinDownT(uni_t,fuel)+1) and (ord(pp) le ord(p))], vShutDownUniFuelMC(uni_t,fuel,pp)] =l= 1-vCommitmentUniMC(uni_t,p)
;

eMaxStartupxDay(uni_t, d)$((pRestUni(uni_t)=0 and not pCasoPID))  ..
   sum[p$pd(p,d), vStartUpUni(uni_t,p)] =l= pStartUpxDay(uni_t)
;

eMaxStartupxDayMC(uni_t,d)$((not pCasoPID and pRestUni(uni_t)=0))  ..
   sum[p$pd(p,d), vStartUpUniMC(uni_t,p)] =l= 1
;

// TODO: Haver el cambio para que el estado térmico de la unidad se tenga en cuenta con la variable mayor que cero y cambiar las ecuaciones para que calcule la bandera de arranque
// con la variable mayor que cero

// TODO: Probar la condición inicial sin la segunda suma
eHotStartUniFuel (uni_t, fuel, p )$ (uni_fuel(uni_t,fuel) and (not pCasoPID))..
   vStartUpUniFuelTE(uni_t,fuel,'hot',p) =l= sum[(pp)$(((ord(p)-ord(pp)) >= 1) and (ord(pp)<= pTmStStFin(uni_t,fuel,'hot'))), vShutDownUniFuelMC(uni_t,fuel,p-ord(pp))]
                                             + 1$(pCountOnUni(uni_t)=0 and pCountOffUni(uni_t)>0 and (pCountOffUni(uni_t)+ord(p)-1)<=pTmStStFin(uni_t,fuel,'hot'))
;

eWarmStartUniFuel (uni_t, fuel, p )$ (uni_fuel(uni_t,fuel) and (not pCasoPID))..
   vStartUpUniFuelTE(uni_t,fuel,'warm',p) =l= sum[(pp)$(((ord(p)-ord(pp)) >= 1) and (ord(pp)<= pTmStStFin(uni_t,fuel,'warm')) and (ord(pp)>= pTmStStFin(uni_t,fuel,'hot')+1)), vShutDownUniFuelMC(uni_t,fuel,p-ord(pp))]
                                             + 1$(pCountOnUni(uni_t)=0 and pCountOffUni(uni_t)>0 and (pCountOffUni(uni_t)+ord(p)-1)>pTmStStFin(uni_t,fuel,'hot') and (pCountOffUni(uni_t)+ord(p)-1)<=pTmStStFin(uni_t,fuel,'warm'))
;

eColdStartUniFuel (uni_t, fuel, p )$ (uni_fuel(uni_t,fuel) and (not pCasoPID))..
   vStartUpUniFuelTE(uni_t,fuel,'cold',p) =l= sum[(pp)$(((ord(p)-ord(pp)) >= 1) and (ord(pp)<= card(p)) and (ord(pp)>= pTmStStFin(uni_t,fuel,'warm')+1)),vShutDownUniFuelMC(uni_t,fuel,p-ord(pp))]
                                             + 1$(pCountOnUni(uni_t)=0 and pCountOffUni(uni_t)>0 and (pCountOffUni(uni_t)+ord(p)-1)>pTmStStFin(uni_t,fuel,'warm'))
;


* eRelOnOffMC_Starup_Cold(uni_t,fuel,tstate,p,pltt_cc,conf)$(uni_fuel(uni_t,fuel) and plt_uni(pltt_cc,uni_t) and pltt_conf(pltt_cc,conf) and sameas(tstate,'cold') and sameas(pltt_cc,'TEBSAB_CC') and (not pCasoPID))..
*    sum[pp$[(ord(pp) gt ord(p)) and (ord(pp) le (ord(p)+ pNumBlkColdThmPltConf(pltt_cc,conf))) and ((ord(p)+ pNumBlkColdThmPltConf(pltt_cc,conf)-1) le card(p))],
*       vStartUpUniFuelTE(uni_t,fuel,'cold',pp)-(1-vStartUpThmPltCCTE(pltt_cc,conf,'cold',pp ))]  =l= vCommitmentUniMC(uni_t,p)
* ;

* eRelOnOffMC_Starup_Warm(uni_t,fuel,tstate,p,pltt_cc,conf)$(uni_fuel(uni_t,fuel) and plt_uni(pltt_cc,uni_t) and pltt_conf(pltt_cc,conf) and sameas(tstate,'warm') and sameas(pltt_cc,'TEBSAB_CC') and (not pCasoPID))..
*    sum[pp$[(ord(pp) gt ord(p)) and (ord(pp) le (ord(p)+ pNumBlkWarmThmPltConf(pltt_cc,conf))) and ((ord(p)+ pNumBlkWarmThmPltConf(pltt_cc,conf)-1) le card(p))],
*       vStartUpUniFuelTE(uni_t,fuel,'warm',pp)-(1-vStartUpThmPltCCTE(pltt_cc,conf,'warm',pp ))]  =l= vCommitmentUniMC(uni_t,p)
* ;

* eRelOnOffMC_Starup_Hot(uni_t,fuel,tstate,p,pltt_cc,conf)$(uni_fuel(uni_t,fuel) and plt_uni(pltt_cc,uni_t) and pltt_conf(pltt_cc,conf) and sameas(tstate,'hot') and sameas(pltt_cc,'TEBSAB_CC') and (not pCasoPID))..
*    sum[pp$[(ord(pp) gt ord(p)) and (ord(pp) le (ord(p)+ pNumBlkHotThmPltConf(pltt_cc,conf))) and ((ord(p)+ pNumBlkHotThmPltConf(pltt_cc,conf)-1) le card(p))],
*       vStartUpUniFuelTE(uni_t,fuel,'hot',pp)-(1-vStartUpThmPltCCTE(pltt_cc,conf,'hot',pp ))]  =l= vCommitmentUniMC(uni_t,p)
;
// *****************************************************************************************************************

eThmDispGenMC(plt_t,p)$(bMC=1)..
   vGenPlt(plt_t,p) =l= pDispThmPlt(plt_t,p) * vCommitTrmPltMC(plt_t,p)
;

eThmMinGenMC(plt_t,p)$(bMC=1 and (not pCasoPID))..
   vGenPlt(plt_t,p) =g= 0.1 * vCommitTrmPltMC(plt_t,p)
;

eUpDownRatioPltMC(plt_t, p)$(ord(p) > 1 and (bMC=1) and (not pCasoPID))..
    vCommitTrmPltMC(plt_t,p) - vCommitTrmPltMC(plt_t,p-1) =e= vStartUpThmPltMC(plt_t,p ) - vShutDownThmPltMC(plt_t,p)
;

eUpDownRatioPltCIMC(plt_t, p)$(ord(p) = 1 and (bMC=1) and (not pCasoPID))..
    vCommitTrmPltMC(plt_t,p) - 1$(pGenPltiIni(plt_t)>0) =e= vStartUpThmPltMC(plt_t,p ) - vShutDownThmPltMC(plt_t,p)
;

eUpDownSingularityThmPltMC(plt_t,p)$((bMC=1) and (not pCasoPID)) ..
  vStartUpThmPltMC(plt_t,p ) + vShutDownThmPltMC(plt_t,p) =l= 1
;


eCmmitUniCommitPltRelationMC(uni_t,p )$((bMC=1) and (not pCasoPID))..
  vCommitmentUniMC(uni_t,p) =l= sum[(plt_t)$plt_uni(plt_t,uni_t),vCommitTrmPltMC(plt_t,p)]
;


// Cicle simple constraints *************************************************************************************

eThermalGenCS(pltt_cs,p)  ..
 vGenThermalPltCS  (pltt_cs,p           )=e=  vGenPlt(pltt_cs,p)
;

eThmCSDispGen(pltt_cs,p)..
   vGenTrmPltM2(pltt_cs,p) =l= sum[(uni_t)$plt_uni(pltt_cs,uni_t),pThmMaxprodUni(uni_t,p)] * vCommitTrmPlt(pltt_cs,p)
;

eThmCSDispGenConf(pltt_cs,p) ..
   vGenTrmPltM2(pltt_cs,p) =l= pTrmCSMaxConf(pltt_cs)  * vCommitTrmPlt(pltt_cs,p)
;

eThmCSMinGen(pltt_cs,p)$(banAux=1)..
   vGenTrmPltM2(pltt_cs,p) =g= [pTrmCSMinConf(pltt_cs) * vCommitTrmPlt(pltt_cs,p)]$(not pCasoPID)
                              + [vCommitTrmPlt(pltt_cs,p)]$(pCasoPID)
;

eGenThmCSStartupM1Max (pltt_cs,p)$(not pCasoPID)  ..
   vGenTrmPltURM1 (pltt_cs,p) =l= vCommitTrmPltM1UR(pltt_cs,p)*pTrmCSMinConf(pltt_cs)
;

eGenThmCSStartupM1Min (pltt_cs,p)$(not pCasoPID)  ..
   vGenTrmPltURM1 (pltt_cs,p) =g= vCommitTrmPltM1UR(pltt_cs,p)
;

eGenThmCSShutDwnM1Max(pltt_cs,p)$(not pCasoPID)  ..
   vGenTrmPltDRM1(pltt_cs,p) =l= vCommitTrmPltM1DR(pltt_cs,p)*pTrmCSMinConf(pltt_cs)
;

eGenThmCSShutDwnM1Min(pltt_cs,p)$(not pCasoPID)  ..
   vGenTrmPltDRM1(pltt_cs,p) =g= vCommitTrmPltM1DR(pltt_cs,p)
;

ePltUR_DR_Singularity(plt_t,p)$(not pCasoPID) ..
    vCommitTrmPltM1UR(plt_t,p) + vCommitTrmPltM1DR(plt_t,p) =l= [1 - vCommitTrmPlt(plt_t,p)]
;

eUpDownRatioPlt  (plt_t, p)$(ord(p) > 1)..
    vCommitTrmPlt(plt_t,p) - vCommitTrmPlt(plt_t,p-1) =e= vStartUpThmPlt(plt_t,p ) - vShutDownThmPlt(plt_t,p)
;

eUpDownRatioPltCI  (plt_t, p)$(ord(p) = 1)..
    vCommitTrmPlt(plt_t,p) - 1$((pGenPltiIni(plt_t)>0) and (TypeMod_CI(plt_t)=2) and (not pCasoPID)) - 1$((pGenPltiIni(plt_t)>0) and (pCasoPID))
      =e= vStartUpThmPlt(plt_t,p ) - vShutDownThmPlt(plt_t,p)
;

eUpDownSingularityThmPlt(plt_t,p) ..
  vStartUpThmPlt(plt_t,p ) +vShutDownThmPlt(plt_t,p) =l= 1
;

eUniPltConfRelationCS(pltt_cs,p)..
   sum[(conf)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs))),pThmPltNumUniComb(pltt_cs,conf)]* vCommitTrmPlt(pltt_cs,p)
   =e= sum[(uni_t)$(plt_uni(pltt_cs,uni_t) and pUnitType(uni_t)=1),vCommitmentUni(uni_t,p)]
;

// CC Thermal plant configuration equation  ***********************************************************

// TODO: Agragar varible que sea la suma de las variables de configuración en firme y en rampa (si se quiere en una sola variable), adicoinalmente se debe agregar que la configuración
// de la entrada debe coindidir con las rampas de entrada y configuración de salida con la de salida


eThermalGenConfCC(pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf)) ..
   vGenThermalPltConfCC (pltt_cc,conf,p ) =e=  vGenThmCCConfM2(pltt_cc,conf,p) + [vGenThmCCConfM1UR(pltt_cc,conf,p) + vGenThmCCConfM1DR(pltt_cc,conf,p)]$(not pCasoPID)

;

eGenTrmCCConfM2(pltt_cc,p)..
   vGenTrmPltM2 (pltt_cc,p )=e=sum[(conf)$pltt_conf(pltt_cc,conf), vGenThmCCConfM2(pltt_cc,conf,p)]
;

eDispTrmCCConfM2(pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf))..
   vGenThmCCConfM2(pltt_cc,conf,p) =l= pTrmCCDispConf(pltt_cc,conf,p) * vCommitTrmCC(pltt_cc,conf,p)
;

eMinTrmCCConfM2(pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf))..
   vGenThmCCConfM2(pltt_cc,conf,p) =g= [pTrmPltMinConf(pltt_cc,conf) * vCommitTrmCC(pltt_cc,conf,p)]$(not pCasoPID)
                                       + [vCommitTrmCC(pltt_cc,conf,p)]$(pCasoPID)
;

eSingularityThrmCCM2(pltt_cc,p)..
   sum[(conf)$pltt_conf(pltt_cc,conf), vCommitTrmCC(pltt_cc,conf,p)] =e= vCommitTrmPlt(pltt_cc,p)
;

eGenTrmCCConfM1UR (pltt_cc,p)$(not pCasoPID)  ..
   vGenTrmPltURM1 (pltt_cc,p) =e= sum[(conf)$pltt_conf(pltt_cc,conf), vGenThmCCConfM1UR(pltt_cc,conf,p)]
;

eGenThmCCStartupM1Max (pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf) and (not pCasoPID))..
  vGenThmCCConfM1UR(pltt_cc,conf,p) =l= vCommitTrmPltCCM1UR(pltt_cc,conf,p)*pTrmPltMinConf(pltt_cc,conf)
;

eGenThmCCStartupM1Min (pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf) and (not pCasoPID))..
  vGenThmCCConfM1UR(pltt_cc,conf,p) =g= vCommitTrmPltCCM1UR(pltt_cc,conf,p)
;

eSingularityThrmCCM1UR(pltt_cc,p)$(not pCasoPID)..
   sum[(conf)$pltt_conf(pltt_cc,conf), vCommitTrmPltCCM1UR(pltt_cc,conf,p)] =e= vCommitTrmPltM1UR(pltt_cc,p)
;

eGenTrmCCConfM1DR (pltt_cc,p)$(not pCasoPID)  ..
   vGenTrmPltDRM1 (pltt_cc,p) =e= sum[(conf)$pltt_conf(pltt_cc,conf), vGenThmCCConfM1DR(pltt_cc,conf,p)]
;

eGenThmCCShutDwnM1Max(pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf) and (not pCasoPID))  ..
   vGenThmCCConfM1DR(pltt_cc,conf,p) =l= vCommitTrmPltCCM1DR(pltt_cc,conf,p)*pTrmPltMinConf(pltt_cc,conf)
;

eGenThmCCShutDwnM1Min(pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf) and (not pCasoPID))  ..
   vGenThmCCConfM1DR(pltt_cc,conf,p) =g= vCommitTrmPltCCM1DR(pltt_cc,conf,p)
;
eSingularityThrmCCM1DR(pltt_cc,p)$(not pCasoPID)..
   sum[(conf)$pltt_conf(pltt_cc,conf), vCommitTrmPltCCM1DR(pltt_cc,conf,p)] =e= vCommitTrmPltM1DR(pltt_cc,p)
;

ePltUR_DR_SingularityCC(pltt_cc,conf,p )$(pltt_conf(pltt_cc,conf) and (not pCasoPID))  ..
    vCommitTrmPltCCM1UR(pltt_cc,conf,p) + vCommitTrmPltCCM1DR(pltt_cc,conf,p) =l= [1 - vCommitTrmCC(pltt_cc,conf,p)]
;


eUpDownRatioPltCC  (pltt_cc,conf,p)$((ord(p) > 1) and pltt_conf(pltt_cc,conf))..
    vCommitTrmCC(pltt_cc,conf,p) -vCommitTrmCC(pltt_cc,conf,p-1) =e= vStartUpThmPltCC(pltt_cc,conf,p ) - vShutDownThmPltCC(pltt_cc,conf,p)
;


eUpDownRatioPltCICC  (pltt_cc,conf,p)$((ord(p) = 1) and pltt_conf(pltt_cc,conf))..
     vCommitTrmCC(pltt_cc,conf,p) - 1$((pGenPltiIni(pltt_cc)>0) and (TypeMod_CI(pltt_cc)=2) and pConfPltIni(pltt_cc)=ord(conf) and (not pCasoPID)) - 1$((pGenPltiIni(pltt_cc)>0) and pConfPltIni(pltt_cc)=ord(conf) and (pCasoPID))
      =e= vStartUpThmPltCC(pltt_cc,conf,p ) - vShutDownThmPltCC(pltt_cc,conf,p)
;

eUpDownSingularityCC(pltt_cc,conf,p)$pltt_conf(pltt_cc,conf)  ..
   vStartUpThmPltCC(pltt_cc,conf,p) + vShutDownThmPltCC(pltt_cc,conf,p) =l= 1
;

eUniPltConfRelationCCComb(pltt_cc,p) ..
   sum[conf$pltt_conf(pltt_cc,conf),pThmPltNumUniComb(pltt_cc,conf)* vCommitTrmCC(pltt_cc,conf,p)]
   =e= sum[(uni_t)$(plt_uni(pltt_cc,uni_t) and pUnitType(uni_t)=1),vCommitmentUni(uni_t,p)]
;

eUniPltConfRelationCCComb_M1(pltt_cc,p) ..
   sum[conf$pltt_conf(pltt_cc,conf),pThmPltNumUniComb(pltt_cc,conf)* (vCommitTrmPltCCM1UR(pltt_cc,conf,p)+vCommitTrmPltCCM1DR(pltt_cc,conf,p))]
   =l= sum[(uni_t)$(plt_uni(pltt_cc,uni_t) and pUnitType(uni_t)=1),vCommitmentUniMC(uni_t,p)]
;

eUniPltConfRelationCCSteam(pltt_cc,p)..
    sum[conf$pltt_conf(pltt_cc,conf),pThmPltNumUniSteam(pltt_cc,conf)* vCommitTrmCC(pltt_cc,conf,p)]
   =e= sum[(uni_t)$(plt_uni(pltt_cc,uni_t) and pUnitType(uni_t)=2),vCommitmentUni(uni_t,p)]
;

eUniPltConfRelationCCSteam_M1(pltt_cc,p)..
    sum[conf$pltt_conf(pltt_cc,conf),pThmPltNumUniSteam(pltt_cc,conf)* (vCommitTrmPltCCM1UR(pltt_cc,conf,p)+vCommitTrmPltCCM1DR(pltt_cc,conf,p))]
   =l= sum[(uni_t)$(plt_uni(pltt_cc,uni_t) and pUnitType(uni_t)=2),vCommitmentUniMC(uni_t,p)]
;

eUniCombGTSteam(pltt_cc,p)..
   sum[(uni_t)$(plt_uni(pltt_cc,uni_t) and pUnitType(uni_t)=1),vCommitmentUniMC(uni_t,p)]
   =g= sum[(uni_t)$(plt_uni(pltt_cc,uni_t) and pUnitType(uni_t)=2),vCommitmentUniMC(uni_t,p)]
;

//************************************************************************************************

 //******************************************************************************************************

// Definition of OnOff of thermal state plant
eStartupThmPltUniHotMax(plt_t,p )$(not pCasoPID) ..
   vOnOffThmPltTE(plt_t,'hot',p)
   =l= sum[(uni_t,fuel)$(plt_uni(plt_t,uni_t) and uni_fuel(uni_t,fuel)),vStartUpUniFuelTE(uni_t,fuel,'hot',p)]
;

eStartupThmPltUniWarmMax(plt_t,p )$(not pCasoPID) ..
   vOnOffThmPltTE(plt_t,'warm',p)
   =l= sum[(uni_t,fuel)$(plt_uni(plt_t,uni_t) and uni_fuel(uni_t,fuel)),vStartUpUniFuelTE(uni_t,fuel,'warm',p)]
;

eStartupThmPltUniColdMax(plt_t,p )$(not pCasoPID) ..
   vOnOffThmPltTE(plt_t,'cold',p)
   =l= sum[(uni_t,fuel)$(plt_uni(plt_t,uni_t) and uni_fuel(uni_t,fuel)),vStartUpUniFuelTE(uni_t,fuel,'cold',p)]
;

eStartupThmPltUniHotMin(plt_t,p )$(not pCasoPID)..
   vOnOffThmPltTE(plt_t,'hot',p)* 12
   =g= sum[(uni_t,fuel)$(plt_uni(plt_t,uni_t) and uni_fuel(uni_t,fuel)),vStartUpUniFuelTE(uni_t,fuel,'hot',p)]
;

eStartupThmPltUniWarmMin(plt_t,p )$(not pCasoPID)..
   vOnOffThmPltTE(plt_t,'warm',p)* 12
   =g= sum[(uni_t,fuel)$(plt_uni(plt_t,uni_t) and uni_fuel(uni_t,fuel)),vStartUpUniFuelTE(uni_t,fuel,'warm',p)]
;

eStartupThmPltUniColdMin(plt_t,p )$(not pCasoPID)..
   vOnOffThmPltTE(plt_t,'cold',p)* 12
   =g= sum[(uni_t,fuel)$(plt_uni(plt_t,uni_t) and uni_fuel(uni_t,fuel)),vStartUpUniFuelTE(uni_t,fuel,'cold',p)]
;


// Start up of plant defined per the On_Off thermal state of plants
// TODO: Hacer pruebas cuando dos unidades llegan en un estado diferente
eStartupOnOffThmPltCold(plt_t,p)$(not pCasoPID)..
   vStartUpThmPltTE(plt_t,'cold',p) =l= vOnOffThmPltTE(plt_t,'cold',p)
;

eStartupOnOffThmPltWarm(plt_t,p)$(not pCasoPID)..
   vStartUpThmPltTE(plt_t,'hot',p) =l= 1 - vOnOffThmPltTE(plt_t,'warm',p)
;

eStartupOnOffThmPltHot(plt_t,p)$(not pCasoPID)..
   vStartUpThmPltTE(plt_t,'hot',p) +  vStartUpThmPltTE(plt_t,'warm',p) =l= 1 - vOnOffThmPltTE(plt_t,'cold',p)
;

eStartupThmPlt(plt_t,p )$(not pCasoPID)..
   vStartUpThmPlt(plt_t,p ) =e= sum[(tstate), vStartUpThmPltTE(plt_t,tstate,p)]
;


// Start to CC thermal plants
eStartupCCThmPlt(pltt_cc,p )$(not pCasoPID)..
   vStartUpThmPlt(pltt_cc,p ) =e= sum[(conf,tstate)$pltt_conf(pltt_cc,conf), vStartUpThmPltCCTE(pltt_cc,conf,tstate,p)]
;

eStartupCCThmPltConf(pltt_cc,conf,p )$(pltt_conf(pltt_cc,conf) and (not pCasoPID))..
   sum[tstate,vStartUpThmPltCCTE(pltt_cc,conf,tstate,p)] =g= vStartUpThmPltCC(pltt_cc,conf,p) - pM*(1-vStartUpThmPlt(pltt_cc,p ))
;

eStartupCCThmPltCold(pltt_cc,p)$(not pCasoPID)..
   vStartUpThmPltTE(pltt_cc,'cold',p) =l= sum[conf$pltt_conf(pltt_cc,conf),vStartUpThmPltCCTE(pltt_cc,conf,'cold',p)]
;

eStartupCCThmPltWarm(pltt_cc,p)$(not pCasoPID)..
   vStartUpThmPltTE(pltt_cc,'warm',p) =l= sum[conf$pltt_conf(pltt_cc,conf),vStartUpThmPltCCTE(pltt_cc,conf,'warm',p)]
;

eStartupCCThmPltHot(pltt_cc,p)$(not pCasoPID)..
   vStartUpThmPltTE(pltt_cc,'hot',p) =l= sum[conf$pltt_conf(pltt_cc,conf),vStartUpThmPltCCTE(pltt_cc,conf,'hot',p)]
;

// Shutdown to CC thermal plants ******************************************
eShutdownCCThmPlt(pltt_cc,p)$(not pCasoPID)..
   vShutDownThmPlt(pltt_cc,p) =e= sum[(conf)$pltt_conf(pltt_cc,conf), vShutDownThmPltCCM1(pltt_cc,conf,p)]
;

eShutdownCCThmPltConf(pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf) and (not pCasoPID))..
   vShutDownThmPltCCM1(pltt_cc,conf,p) =g= vShutDownThmPltCC(pltt_cc,conf,p) - vCommitTrmPlt(pltt_cc,p)
;


//****************************************************************************

// TODO: Validar todos los casos en las condiciones iniciales que se pueden dar como por ejemplo:
//       Arrancar debiendo bloques del día anterior, esto se debe acotar con otra restriccción
// *Model 1 Equations ************************************************************************************

parameter
banMod1 /1/;

eCSThmPltUpRamps (pltt_cs,p)$(not pCasoPID and pRestPlt(pltt_cs)=0)..
   vGenTrmPltURM1(pltt_cs,p) =e= sum[(conf,r,pp)$[(ord(r) le pNumBlkWarmThmPltConf(pltt_cs,conf)) and (ord(pp) eq pPosRampWarm(pltt_cs,conf, r, p)) and pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs))],
                                       pWarmStartUpRampsThmPltConf( pltt_cs,conf,r  )* vStartUpThmPltTE(pltt_cs,'warm',pp)]
                                 + sum[(conf,r,pp)$[(ord(r) le pNumBlkHotThmPltConf(pltt_cs,conf)) and (ord(pp) eq pPosRampHot(pltt_cs,conf, r, p)) and pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs))],
                                        pHotStartUpRampsThmPltConf( pltt_cs,conf,r  )* vStartUpThmPltTE(pltt_cs,'hot',pp)]
                                 + sum[(conf,r,pp)$[(ord(r) le pNumBlkColdThmPltConf(pltt_cs,conf)) and (ord(pp) eq pPosRampCold(pltt_cs,conf, r, p)) and pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs))],
                                        pColdStartUpRampsThmPltConf( pltt_cs,conf,r  )* vStartUpThmPltTE(pltt_cs,'cold',pp)]
;

eCCThmPltUpRamps (pltt_cc,p) $(banMod1=1 and (not pCasoPID))..
   vGenTrmPltURM1(pltt_cc,p) =e= sum[(conf,r,pp)$[(ord(r) le pNumBlkWarmThmPltConf(pltt_cc,conf)) and (ord(pp) eq pPosRampWarm(pltt_cc,conf, r, p)) and pltt_conf(pltt_cc,conf)],
                                       pWarmStartUpRampsThmPltConf( pltt_cc,conf,r  )* vStartUpThmPltCCTE(pltt_cc,conf,'warm',pp)]
                                 + sum[(conf,r,pp)$[(ord(r) le pNumBlkHotThmPltConf(pltt_cc,conf)) and (ord(pp) eq pPosRampHot(pltt_cc,conf, r, p)) and pltt_conf(pltt_cc,conf)],
                                        pHotStartUpRampsThmPltConf( pltt_cc,conf,r  )* vStartUpThmPltCCTE(pltt_cc,conf,'hot',pp)]
                                 + sum[(conf,r,pp)$[(ord(r) le pNumBlkColdThmPltConf(pltt_cc,conf)) and (ord(pp) eq pPosRampCold(pltt_cc,conf, r, p)) and pltt_conf(pltt_cc,conf)],
                                        pColdStartUpRampsThmPltConf( pltt_cc,conf,r  )* vStartUpThmPltCCTE(pltt_cc,conf,'cold',pp)]
;

// TODO: Agegar parada especial partiedo la parada en normal y mayor que el MT
eCSThmPltDRRamps(pltt_cs,p)$(not pCasoPID and pRestPlt(pltt_cs)=0) ..
   vGenTrmPltDRM1(pltt_cs,p) =e= sum[(conf,r,pp)$((ord(r) le pNumBlkDRThmPltConf(pltt_cs,conf)) and (ord(pp) eq pPosRampDR(pltt_cs,conf, r, p)) and pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs))),
                                    pShutdownRampsPltConf(pltt_cs,conf,r)*vShutDownThmPlt(pltt_cs,pp)]
;

eCCThmPltDRRamps(pltt_cc,p)$(banMod1=1 and (not pCasoPID)) ..
   vGenTrmPltDRM1(pltt_cc,p) =e= sum[(conf,r,pp)$((ord(r) le pNumBlkDRThmPltConf(pltt_cc,conf)) and (ord(pp) eq pPosRampDR(pltt_cc,conf, r, p)) and pltt_conf(pltt_cc,conf) ),
                                    pShutdownRampsPltConf(pltt_cc,conf,r)* vShutDownThmPltCCM1(pltt_cc,conf,pp)]
;

//*************************************************************************************************************************

//Up ramp - model 2 CS thermal plants******************************************************************************
parameter
banMod2CS /1/
bCI /1/;

eUpRampMod21CS(pltt_cs,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0] ..
   vGenTrmPltM2(pltt_cs,p+1) =l= vGenTrmPltM2(pltt_cs,p) + vDeltaU(pltt_cs,p) + vGenTrmPltURM1(pltt_cs,p) + pM*[vbUpMT (pltt_cs,p)]
;

eUpRampMod22CS(pltt_cs,p)$(not pltt_m3(pltt_cs) and (not pCasoPID) and pRestPlt(pltt_cs)=0)                     ..
   vDeltaU(pltt_cs,p)
  =l= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs)) ),pUpRateRmp( pltt_cs,conf,r)*vbUR(pltt_cs,r,p)]
;

eUpRampMod23CS(pltt_cs,p)$(not pltt_m3(pltt_cs) and (not pCasoPID) and pRestPlt(pltt_cs)=0)                     ..
   sum[r,vbUR(pltt_cs,r,p)]
  =l= 1
;

eUpRampMod24CS(pltt_cs,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0] ..
   vGenTrmPltM2(pltt_cs,p) + vGenTrmPltURM1(pltt_cs,p) + pM*[1 - vCommitTrmPlt(pltt_cs,p+1)] + pM*[vbUpMT (pltt_cs,p)]
   =g= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs)) ),pLowerUpRate(pltt_cs,conf,r)*vbUR(pltt_cs,r,p)]
;

eUpRampMod25CS(pltt_cs,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0] ..
  vGenTrmPltM2(pltt_cs,p) + vGenTrmPltURM1(pltt_cs,p) - pM*[1 - vCommitTrmPlt(pltt_cs,p+1)] - pM*[vbUpMT (pltt_cs,p)]
  =l= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs)) ),pUpperUpRate(pltt_cs,conf,r)*vbUR(pltt_cs,r,p)]
;

//**************************************************************
// Condicones iniciales para el modelo 2 de subida planta CS

eUpRampMod21CS_CI(pltt_cs,p)$[(ord(p) = 1) and (not pltt_m3(pltt_cs)) and bCI=1 and (not pCasoPID) and pRestPlt(pltt_cs)=0] ..
   vGenTrmPltM2(pltt_cs,p) =l= vGenTrmPltM2_CI(pltt_cs) + vDeltaU_CI(pltt_cs) + vGenTrmPltURM1_CI(pltt_cs) + pM*[vbUpMT_CI(pltt_cs)]
;

eUpRampMod22CS_CI(pltt_cs)$(not pltt_m3(pltt_cs) and bCI=1 and (not pCasoPID) and pRestPlt(pltt_cs)=0)                     ..
   vDeltaU_CI(pltt_cs)
  =l= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pConfPltIni(pltt_cs)) ),pUpRateRmp( pltt_cs,conf,r)*vbUR_CI(pltt_cs,r)]
;

eUpRampMod23CS_CI(pltt_cs)$(not pltt_m3(pltt_cs) and bCI=1 and (not pCasoPID) and pRestPlt(pltt_cs)=0)                     ..
   sum[r,vbUR_CI(pltt_cs,r)]
  =l= 1
;

eUpRampMod24CS_CI(pltt_cs,p)$[(ord(p) = 1) and (not pltt_m3(pltt_cs)) and bCI=1 and (not pCasoPID) and pRestPlt(pltt_cs)=0] ..
   vGenTrmPltM2_CI(pltt_cs) + vGenTrmPltURM1_CI(pltt_cs) + pM*[1 - vCommitTrmPlt(pltt_cs,p)] + pM*[vbUpMT_CI(pltt_cs)]
   =g= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pConfPltIni(pltt_cs)) ),pLowerUpRate(pltt_cs,conf,r)*vbUR_CI(pltt_cs,r)]
;

eUpRampMod25CS_CI(pltt_cs,p)$[(ord(p) = 1) and (not pltt_m3(pltt_cs)) and bCI=1 and (not pCasoPID) and pRestPlt(pltt_cs)=0] ..
  vGenTrmPltM2_CI(pltt_cs) + vGenTrmPltURM1_CI(pltt_cs) - pM*[1 - vCommitTrmPlt(pltt_cs,p)] - pM*[vbUpMT_CI (pltt_cs)]
  =l= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pConfPltIni(pltt_cs)) ),pUpperUpRate(pltt_cs,conf,r)*vbUR_CI(pltt_cs,r)]
;


//*****************************************************************************************************************************

//***** Up ramp - model 2 CC thermal plants******************************************************************************

parameter
banMod2 /1/;

eUpRampMod21CC(pltt_cc,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cc)) and banMod2=1 and (not pCasoPID)] ..
   vGenTrmPltM2(pltt_cc,p+1) =l= vGenTrmPltM2(pltt_cc,p) + vDeltaU(pltt_cc,p) + vGenTrmPltURM1(pltt_cc,p) + pM*[vbUpMT(pltt_cc,p)]
;

eUpRampMod22CC(pltt_cc,p)$(not pltt_m3(pltt_cc) and banMod2=1 and (not pCasoPID))                     ..
   vDeltaU(pltt_cc,p)
  =l= sum[(conf,r)$(pltt_conf(pltt_cc,conf)),pUpRateRmp( pltt_cc,conf,r)*vbURCC(pltt_cc,conf,r,p)]
;

eUpRampMod23CC(pltt_cc,conf,p)$(not pltt_m3(pltt_cc) and pltt_conf(pltt_cc,conf) and banMod2=1 and (not pCasoPID))                     ..
   sum[r,vbURCC(pltt_cc,conf,r,p)]
  =l= vCommitTrmCC(pltt_cc,conf,p) + vCommitTrmPltCCM1UR(pltt_cc,conf,p)
;

// TODO: validar si se necesita vGenTrmPltURM1 ya que queda inactivo con el commit de la planta dada la singularidad con vGenTrmPltM2
eUpRampMod24CC(pltt_cc,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cc)) and banMod2=1 and (not pCasoPID)] ..
   vGenTrmPltM2(pltt_cc,p) + vGenTrmPltURM1(pltt_cc,p) + pM*[1 - vCommitTrmPlt(pltt_cc,p+1)] + pM*[vbUpMT (pltt_cc,p)]
   =g= sum[(conf,r)$(pltt_conf(pltt_cc,conf)),pLowerUpRate(pltt_cc,conf,r)*vbURCC(pltt_cc,conf,r,p)]
;

eUpRampMod25CC(pltt_cc,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cc)) and banMod2=1 and (not pCasoPID)] ..
  vGenTrmPltM2(pltt_cc,p) + vGenTrmPltURM1(pltt_cc,p) - pM*[1 - vCommitTrmPlt(pltt_cc,p+1)] - pM*[vbUpMT (pltt_cc,p)]
  =l= sum[(conf,r)$(pltt_conf(pltt_cc,conf) ),pUpperUpRate(pltt_cc,conf,r)*vbURCC(pltt_cc,conf,r,p)]
;

// ****************************************************************************************************
// Condiciones iniciales para el modelo 2 de entrada plantas CC

eUpRampMod21CC_CI(pltt_cc,p)$[(ord(p)=1) and (not pltt_m3(pltt_cc)) and (not pCasoPID)] ..
   vGenTrmPltM2(pltt_cc,p) =l= vGenTrmPltM2_CI(pltt_cc) + vDeltaU_CI(pltt_cc) + vGenTrmPltURM1_CI(pltt_cc) + pM*[vbUpMT_CI(pltt_cc)]
;

eUpRampMod22CC_CI(pltt_cc)$(not pltt_m3(pltt_cc) and (not pCasoPID))                     ..
   vDeltaU_CI(pltt_cc)
  =l= sum[(conf,r)$(pltt_conf(pltt_cc,conf)),pUpRateRmp( pltt_cc,conf,r)*vbURCC_CI(pltt_cc,conf,r)]
;

eUpRampMod23CC_CI(pltt_cc,conf)$(not pltt_m3(pltt_cc) and pltt_conf(pltt_cc,conf) and (not pCasoPID))                     ..
   sum[r,vbURCC_CI(pltt_cc,conf,r)]
  =l= 1$[(TypeMod_CI(pltt_cc)=2) and (pGenPltiIni(pltt_cc)>0) and pConfPltIni(pltt_cc)=ord(conf)] + 1$[(TypeMod_CI(pltt_cc)=12) and (pGenPltiIni(pltt_cc)>0) and pConfPltIni(pltt_cc)=ord(conf)]
;

eUpRampMod24CC_CI(pltt_cc,p)$[(ord(p) =1 ) and (not pltt_m3(pltt_cc)) and (not pCasoPID)] ..
   vGenTrmPltM2_CI(pltt_cc) + vGenTrmPltURM1_CI(pltt_cc) + pM*[1 - vCommitTrmPlt(pltt_cc,p)] + pM*[vbUpMT_CI(pltt_cc)]
   =g= sum[(conf,r)$(pltt_conf(pltt_cc,conf)),pLowerUpRate(pltt_cc,conf,r)*vbURCC_CI(pltt_cc,conf,r)]
;

eUpRampMod25CC_CI(pltt_cc,p)$[(ord(p) =1 ) and (not pltt_m3(pltt_cc)) and (not pCasoPID)] ..
  vGenTrmPltM2_CI(pltt_cc) + vGenTrmPltURM1_CI(pltt_cc) - pM*[1 - vCommitTrmPlt(pltt_cc,p)] - pM*[vbUpMT_CI (pltt_cc)]
  =l= sum[(conf,r)$(pltt_conf(pltt_cc,conf) ),pUpperUpRate(pltt_cc,conf,r)*vbURCC_CI(pltt_cc,conf,r)]
;


//**************************************************************************************************************************

// TODO:  Se retira el condicional de MT> 0, validar que sucede en este caso (No hay plantas térmicas que tengan esta condición)
//* Down ramp CS - model 2 ********************************************************************************************************


eDwnRampMod21CS (pltt_cs,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cs)) and banMod2CS=1 and (not pCasoPID) and pRestPlt(pltt_cs)=0] ..
   vGenTrmPltM2(pltt_cs,p+1) + vGenTrmPltDRM1(pltt_cs,p+1) =g= vGenTrmPltM2(pltt_cs,p) - vDeltaD(pltt_cs,p) - pM*[vbDownMT (pltt_cs,p)]
;

eDwnRampMod22CS (pltt_cs,p)$(not pltt_m3(pltt_cs) and banMod2CS=1 and (not pCasoPID) and pRestPlt(pltt_cs)=0)                                                              ..
   vDeltaD(pltt_cs,p)
   =l= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs)) ),pDownRateRmp(pltt_cs,conf,r)*vbDR(pltt_cs,r,p)]
;

eDwnRampMod23CS (pltt_cs,p)$(not pltt_m3(pltt_cs) and banMod2CS=1 and (not pCasoPID) and pRestPlt(pltt_cs)=0)                                                              ..
  sum[r,vbDR(pltt_cs,r,p)]
 =l= 1
;

eDwnRampMod24CS (pltt_cs,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cs)) and banMod2CS=1 and (not pCasoPID) and pRestPlt(pltt_cs)=0]                                         ..
   vGenTrmPltM2(pltt_cs,p) + pM*[1 - vCommitTrmPlt(pltt_cs,p+1)]
  =g= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs)) ),pLowerDownRate(pltt_cs,conf,r)*vbDR(pltt_cs,r,p)]
;

eDwnRampMod25CS (pltt_cs,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cs)) and banMod2CS=1 and (not pCasoPID) and pRestPlt(pltt_cs)=0]                                         ..
   vGenTrmPltM2(pltt_cs,p) - pM*[1 - vCommitTrmPlt(pltt_cs,p+1)]
  =l= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs)) ),pUpperDownRate(pltt_cs,conf,r)*vbDR(pltt_cs,r,p)]
;

//***************************************************************
// Condición inicial para el modelo 2 de bajada palnta CS

eDwnRampMod21CS_CI (pltt_cs,p)$[(ord(p) =1) and (not pltt_m3(pltt_cs)) and (pDispThmPlt(pltt_cs,p)>0) and (not pCasoPID) and pRestPlt(pltt_cs)=0] ..
   vGenTrmPltM2(pltt_cs,p) + vGenTrmPltDRM1(pltt_cs,p) =g= vGenTrmPltM2_CI(pltt_cs) - vDeltaD_CI(pltt_cs) - pM*[vbDownMT_CI(pltt_cs)]
;

eDwnRampMod22CS_CI (pltt_cs,p)$((ord(p) =1) and (not pltt_m3(pltt_cs)) and (pDispThmPlt(pltt_cs,p)>0) and (not pCasoPID) and pRestPlt(pltt_cs)=0)                                                              ..
   vDeltaD_CI(pltt_cs)
   =l= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pConfPltIni(pltt_cs)) ),pDownRateRmp(pltt_cs,conf,r)*vbDR_CI(pltt_cs,r)]
;

eDwnRampMod23CS_CI (pltt_cs,p)$( (ord(p) =1) and (not pltt_m3(pltt_cs)) and (pDispThmPlt(pltt_cs,p)>0) and (not pCasoPID) and pRestPlt(pltt_cs)=0)                                                              ..
  sum[r,vbDR_CI(pltt_cs,r)]
 =l= 1
;

eDwnRampMod24CS_CI (pltt_cs,p)$[(ord(p)=1) and (not pltt_m3(pltt_cs)) and (pDispThmPlt(pltt_cs,p)>0) and (not pCasoPID) and pRestPlt(pltt_cs)=0]                                         ..
   vGenTrmPltM2_CI(pltt_cs) + pM*[1 - vCommitTrmPlt(pltt_cs,p)]
  =g= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pConfPltIni(pltt_cs)) ),pLowerDownRate(pltt_cs,conf,r)*vbDR_CI(pltt_cs,r)]
;

eDwnRampMod25CS_CI (pltt_cs,p)$[(ord(p)=1) and (not pltt_m3(pltt_cs)) and (pDispThmPlt(pltt_cs,p)>0) and (not pCasoPID) and pRestPlt(pltt_cs)=0]                                         ..
   vGenTrmPltM2_CI(pltt_cs) - pM*[1 - vCommitTrmPlt(pltt_cs,p)]
  =l= sum[(conf,r)$(pltt_conf(pltt_cs,conf) and (ord(conf)=pConfPltIni(pltt_cs)) ),pUpperDownRate(pltt_cs,conf,r)*vbDR_CI(pltt_cs,r)]
;



//**************************************************************************************************************************

// TODO:  Se retira el condicional de MT> 0, validar que sucede en este caso (No hay plantas térmicas que tengan esta condición)
// Down ramp CC - model 2 *************************************************************************************************

eDwnRampMod21CC (pltt_cc,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cc)) and banMod2=1 and (not pCasoPID)] ..
   vGenTrmPltM2(pltt_cc,p+1) + vGenTrmPltDRM1(pltt_cc,p+1) =g= vGenTrmPltM2(pltt_cc,p) - vDeltaD(pltt_cc,p) - pM*[vbDownMT (pltt_cc,p)]
   //vGenTrmPltM2(pltt_cc,p+1) + vGenTrmPltDRM1(pltt_cc,p+1) =g= vGenTrmPltM2(pltt_cc,p) - vDeltaD(pltt_cc,p) - pM*[1 - vCommitTrmPlt(pltt_cc,p+1)]
;

eDwnRampMod22CC (pltt_cc,p)$(not pltt_m3(pltt_cc) and banMod2=1 and (not pCasoPID))                                                              ..
   vDeltaD(pltt_cc,p)
   =l= sum[(conf,r)$(pltt_conf(pltt_cc,conf)),pDownRateRmp(pltt_cc,conf,r)*vbDRCC(pltt_cc,conf,r,p)]
;

eDwnRampMod23CC (pltt_cc,conf,p)$(not pltt_m3(pltt_cc) and pltt_conf(pltt_cc,conf) and banMod2=1 and (not pCasoPID))                                                              ..
  sum[r,vbDRCC(pltt_cc,conf,r,p)]
 =l= vCommitTrmCC(pltt_cc,conf,p)
;

// TODO: validar la condición p+1 para la variable de hogura
eDwnRampMod24CC (pltt_cc,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cc)) and banMod2=1 and (not pCasoPID)]                                         ..
   vGenTrmPltM2(pltt_cc,p) + pM*[1 - vCommitTrmPlt(pltt_cc,p+1)]
  =g= sum[(conf,r)$(pltt_conf(pltt_cc,conf) ),pLowerDownRate(pltt_cc,conf,r)*vbDRCC(pltt_cc,conf,r,p)]
;

eDwnRampMod25CC (pltt_cc,p)$[(ord(p) lt card(p)) and (not pltt_m3(pltt_cc)) and banMod2=1 and (not pCasoPID)]                                         ..
   vGenTrmPltM2(pltt_cc,p) - pM*[1 - vCommitTrmPlt(pltt_cc,p+1)]
  =l= sum[(conf,r)$(pltt_conf(pltt_cc,conf)),pUpperDownRate(pltt_cc,conf,r)*vbDRCC(pltt_cc,conf,r,p)]
;

// **********************************************************************************
// Condición inicial para el modelo 2 de bajada palnta CC
eDwnRampMod21CC_CI (pltt_cc,p)$[(ord(p)=1) and (not pltt_m3(pltt_cc)) and (pDispThmPlt(pltt_cc,p)>0) and (not pCasoPID)] ..
   vGenTrmPltM2(pltt_cc,p) + vGenTrmPltDRM1(pltt_cc,p) =g= vGenTrmPltM2_CI(pltt_cc) - vDeltaD_CI(pltt_cc) - pM*[vbDownMT_CI (pltt_cc)]
;

eDwnRampMod22CC_CI (pltt_cc,p)$( (ord(p)=1) and (not pltt_m3(pltt_cc)) and (pDispThmPlt(pltt_cc,p)>0) and (not pCasoPID))                                                              ..
   vDeltaD_CI(pltt_cc)
   =l= sum[(conf,r)$(pltt_conf(pltt_cc,conf)),pDownRateRmp(pltt_cc,conf,r)*vbDRCC_CI(pltt_cc,conf,r)]
;

eDwnRampMod23CC_CI (pltt_cc,conf,p)$( (ord(p)=1) and (not pltt_m3(pltt_cc)) and pltt_conf(pltt_cc,conf) and (pDispThmPlt(pltt_cc,p)>0) and (not pCasoPID))                                                              ..
  sum[r,vbDRCC_CI(pltt_cc,conf,r)]
 =l= 1$[(TypeMod_CI(pltt_cc)=2) and (pGenPltiIni(pltt_cc)>0) and pConfPltIni(pltt_cc)=ord(conf)]
;

eDwnRampMod24CC_CI (pltt_cc,p)$[(ord(p) =1) and (not pltt_m3(pltt_cc)) and (pDispThmPlt(pltt_cc,p)>0) and (not pCasoPID)]                                         ..
   vGenTrmPltM2_CI(pltt_cc) + pM*[1 - vCommitTrmPlt(pltt_cc,p)]
  =g= sum[(conf,r)$(pltt_conf(pltt_cc,conf) ),pLowerDownRate(pltt_cc,conf,r)*vbDRCC_CI(pltt_cc,conf,r)]
;

eDwnRampMod25CC_CI (pltt_cc,p)$[(ord(p)=1) and (not pltt_m3(pltt_cc)) and (pDispThmPlt(pltt_cc,p)>0) and (not pCasoPID)]                                         ..
   vGenTrmPltM2_CI(pltt_cc) - pM*[1 - vCommitTrmPlt(pltt_cc,p)]
  =l= sum[(conf,r)$(pltt_conf(pltt_cc,conf)),pUpperDownRate(pltt_cc,conf,r)*vbDRCC_CI(pltt_cc,conf,r)]
;


//**************************************************************************************************************************

// Model 3 *****************************************************************************************************************

* Up ramp model 3

eUpRampMod31CS(pltt_cs,p,l,ll,conf)$[(ord(p) gt 1) and pltt_m3(pltt_cs) and (ord(l) eq 1) and (ord(ll) eq 2) and pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0]..
   pUpRampMod3(pltt_cs,conf,l)*vGenTrmPltM2(pltt_cs,p)
   - pUpRampMod3(pltt_cs,conf,ll)*[vGenTrmPltM2(pltt_cs,p-1) + vGenTrmPltURM1(pltt_cs,p-1)]
  =l= pURMod3(pltt_cs,conf)
;

eUpRampMod32CS(pltt_cs,p,l,ll,conf)$[(ord(p) eq 1) and pltt_m3(pltt_cs) and (ord(l) eq 1) and (ord(ll) eq 2) and pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0]..
  pUpRampMod3(pltt_cs,conf,l)*vGenTrmPltM2(pltt_cs,p)  - pUpRampMod3(pltt_cs,conf,ll)*pGenPltiIni(pltt_cs)
  =l= pURMod3(pltt_cs,conf)
;

* Down ramp model 3
eDwnRampMod31CS(pltt_cs,p,l,ll,conf)$[(ord(p) gt 1) and pltt_m3(pltt_cs) and (ord(l) eq 1) and (ord(ll) eq 2) and pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0]..
   pDownRampMod3(pltt_cs,conf,l)*vGenTrmPltM2(pltt_cs,p-1)  - pDownRampMod3(pltt_cs,conf,ll)*[vGenTrmPltM2(pltt_cs,p) + vGenTrmPltDRM1(pltt_cs,p)]
  =l= pDRMod3(pltt_cs,conf)
;

eDwnRampMod32CS(pltt_cs,p,l,ll,conf)$[(ord(p) eq 1) and pltt_m3(pltt_cs) and (ord(l) eq 1) and (ord(ll) eq 2) and pltt_conf(pltt_cs,conf) and (ord(conf)=pThmConf(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0]..
   pDownRampMod3(pltt_cs,conf,l)*pGenPltiIni(pltt_cs)  - pDownRampMod3(pltt_cs,conf,ll)*[vGenTrmPltM2(pltt_cs,p) + vGenTrmPltDRM1(pltt_cs,p)]
  =l= pDRMod3(pltt_cs,conf)
;


//**************************************************************************************************************************

// Transitiosn equations **************************************************************************************************
parameter
banTrs /1/;

// StartUp configuration allowed
eStartTrmPltCCAllowed(pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf) and banTrs=1 and (not pCasoPID)) ..
   sum[tstate,vStartUpThmPltCCTE(pltt_cc,conf,tstate,p)] =l= pTrmPltStartConf( pltt_cc,conf )
;

// Shutdown configuration allowed
eShutdownTrmPltCCAllowed(pltt_cc,conf,p)$(pltt_conf(pltt_cc,conf) and banTrs=1 and (not pCasoPID)) ..
   vShutDownThmPltCCM1(pltt_cc,conf,p) =l=  pTrmPltShutdownConf ( pltt_cc,conf )
;

* Ensure transitions are only allowed if they are in the set of allowed transitions
eTransitionAllowed(pltt_cc, conf, confAux, p)$((pTrmCCPltTransition(pltt_cc,conf,confAux)=1 or ord(conf)=ord(confAux)) and pltt_conf(pltt_cc,conf)
                                                and pltt_conf(pltt_cc,confAux) and banTrs=1 and (not pCasoPID)) ..
    vTransitionCC(pltt_cc, conf, confAux, p) =l= vCommitTrmCC(pltt_cc, conf, p)
;

* Ensure configuration consistency at time p+1 based on transitions at time p
eConfigurationConsistency(pltt_cc, conf, p)$[(ord(p) < card(p)) and pltt_conf(pltt_cc,conf) and banTrs=1 and (not pCasoPID)] ..
    vCommitTrmCC(pltt_cc, conf, p+1) =l=
    sum[(confAux)$(pTrmCCPltTransition(pltt_cc,confAux,conf)=1 or ord(conf)=ord(confAux) and pltt_conf(pltt_cc,confAux)),
                     vTransitionCC(pltt_cc, confAux, conf, p)] + pM*[1-vCommitTrmPlt(pltt_cc,p)]
;

eExclusionTransition(pltt_cc,p)$(banTrs=1 and (not pCasoPID))..
   sum((conf,confAux)$[(pTrmCCPltTransition(pltt_cc,conf,confAux) eq 1 or ord(conf)=ord(confAux) and pltt_conf(pltt_cc,conf) and pltt_conf(pltt_cc,confAux))],
         vTransitionCC(pltt_cc,conf,confAux,p))
   =l= 1
;

*Condición inicial en la transición
eConfigurationConsistencyCI(pltt_cc, conf, p)$[(ord(p)=1) and pltt_conf(pltt_cc,conf) and banTrs=1 and (not pCasoPID) and TypeMod_CI(pltt_cc)=2 and  1=1] ..
    vCommitTrmCC(pltt_cc, conf, p) =l=
    sum[(confAux)$(pTrmCCPltTransition(pltt_cc,confAux,conf)=1 or ord(conf)=ord(confAux) and pltt_conf(pltt_cc,confAux)),
                     pTransitionCC_CI(pltt_cc, confAux, conf, p)]
;

//**************************************************************************************************************************

// Zones equations **************************************************************************************************
parameter
banZn /1/
banZnD /1/
;


eMinUnitZones(zn,p)$( pUnitZoneReq(zn,p) > 0 and pZoneType('uni',zn)=1 and banZn=1 and (not pCasoPID) and (not pCasoIDE))..
   sum[uni$(pWeightUnitZone(uni,p,zn)>0 and (pPruebasUni(uni,p)<1 )),pWeightUnitZone(uni,p,zn)*vCommitmentUni(uni,p)] =g= pUnitZoneReq(zn,p)
;

eMinMWZones(zn,p)$( pMWminZoneReq(zn,p) > 0 and pZoneType('min',zn)=1 and banZn=1 and not sameas(zn,'Z_MinTer') and (not pCasoPID) and (not pCasoIDE))..
   sum[uni_t$(pWeightUnitZone(uni_t,p,zn)>0 and (pPruebasUni(uni_t,p)<1 )), vGenUniM2(uni_t,p) ] + sum[uni_h$(pWeightUnitZone(uni_h,p,zn)>0 and (pPruebasUni(uni_h,p)<1 )), vGenUni(uni_h,p) ]
   + sum[uni_v$(pWeightUnitZone(uni_v,p,zn)>0 and (pPruebasUni(uni_v,p)<1 )), vGenUni(uni_v,p) ]
   =g= pMWminZoneReq(zn,p)
;

eMaxMWZones(zn,p)$( pMWmaxZoneReq(zn,p) > 0 and pMWmaxZoneReq(zn,p) < 9999 and pZoneType('max',zn)=1 and banZn=1 and (not pCasoPID) and (not pCasoIDE))..
   sum[uni$(pWeightUnitZone(uni,p,zn)>0),vGenUni(uni,p)] =l= pMWmaxZoneReq(zn,p)
;

eMinMWZonesDay(zn)$(pZoneType('min',zn)=1 and sameas(zn,'Z_MinTer') and (pTermicaDia>0)  and banZnD=1 and (not pCasoPID) and (not pCasoIDE))..
   sum[(uni_t,p)$(pWeightUnitZone(uni_t,p,zn)>0 and (pPruebasUni(uni_t,p)<1 )), vGenUniM2(uni_t,p) ] + sum[(uni_h,p)$(pWeightUnitZone(uni_h,p,zn)>0 and (pPruebasUni(uni_h,p)<1 )), vGenUni(uni_h,p) ]
   + sum[(uni_v,p)$(pWeightUnitZone(uni_v,p,zn)>0 and (pPruebasUni(uni_v,p)<1 )), vGenUni(uni_v,p) ]
   =g= pTermicaDia * 1000
;

eAreaImportLimit(ar,p)$(pArImportLim(ar,p)<9999 and banZn=1 and (not pCasoPID) and (not pCasoIDE))..
   sum[sba$(ar_sba(ar,sba)),pDemandSba(p,sba)-vENS(p,sba)]-
*   sum[sba$(ar_sba(ar,sba)),pDemandSba(p,sba)]-
   (sum[(uni_t,sba)$(uni_sba(uni_t,sba) and ar_sba(ar,sba) and (pPruebasUni(uni_t,p)<1 )), vGenUniM2(uni_t,p)]
   +sum[(uni_h,sba)$(uni_sba(uni_h,sba) and ar_sba(ar,sba) and (pPruebasUni(uni_h,p)<1 )),vGenUni(uni_h,p)]
   +sum[(uni_v,sba)$(uni_sba(uni_v,sba) and ar_sba(ar,sba) and (pPruebasUni(uni_v,p)<1 )),vGenUni(uni_v,p)])
   =l= pArImportLim(ar,p)
;

eMinGenPlt(plt,p)$(pMinGenPlt(plt,p)>0 and banZn=1 and (not pCasoPID) and (not pCasoIDE))..
   vGenPlt(plt,p)=g=pMinGenPlt(plt,p)
;

eMaxGenPlt(plt,p)$(pMaxGenPlt(plt,p)<9999 and pMaxGenPlt(plt,p)>0  and banZn=1 and (not pCasoPID) and (not pCasoIDE))..
   vGenPlt(plt,p)=l=pMaxGenPlt(plt,p)
;

eMOGenPlt(plt,p)$(pMOGenPlt(plt,p)>0 and (not pCasoPID))..
   vGenPlt(plt,p)=g=pMOGenPlt(plt,p)
;

parameter
banAux2 /1/;

// Ecuaciones para determinar cuando la planta está en el mínimo técnico en firme para ciclo simple
eEqMT1CS(pltt_cs,p)$[(not pltt_m3(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0]..
   vGenTrmPltM2(pltt_cs,p) =l= pTrmCSMinConf(pltt_cs)  + pM*[1 - vbMT(pltt_cs,p)]
;

eEqMT2CS(pltt_cs,p)$[(not pltt_m3(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0]..
   vGenTrmPltM2(pltt_cs,p) =g= pTrmCSMinConf(pltt_cs)*vbMT(pltt_cs,p)
;

eEqMT3CS(pltt_cs,p)$[(not pltt_m3(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0 and 1=1]..
   vbMT(pltt_cs,p) =g= vCommitTrmPlt(pltt_cs,p) - pM*[ vGenTrmPltM2(pltt_cs,p)-[pTrmCSMinConf(pltt_cs)*vCommitTrmPlt(pltt_cs,p)]]
;

// Condición inicial para detectar si está en el mínimo ténico
eEqMT1CS_CI(pltt_cs)$[(not pltt_m3(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0]..
   vGenTrmPltM2_CI(pltt_cs) =l= pTrmCSMinConf(pltt_cs)  + pM*[1 - vbMT_CI(pltt_cs)]
;

eEqMT2CS_CI(pltt_cs)$[(not pltt_m3(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0]..
   vGenTrmPltM2_CI(pltt_cs) =g= pTrmCSMinConf(pltt_cs)*vbMT_CI(pltt_cs)
;

eEqMT3CS_CI(pltt_cs)$[(not pltt_m3(pltt_cs)) and (not pCasoPID) and pRestPlt(pltt_cs)=0]..
   vbMT_CI(pltt_cs) =g=
   1$[(TypeMod_CI(pltt_cs)=2) and (pGenPltiIni(pltt_cs)>0)] - pM*[ vGenTrmPltM2_CI(pltt_cs)-[pTrmCSMinConf(pltt_cs) * 1$[(TypeMod_CI(pltt_cs)=2) and (pGenPltiIni(pltt_cs)>0)]]]
;


// Ecuaciones para determinar cuando la planta está en el mínimo técnico en firme para ciclo combiando
eEqMT1CC(pltt_cc,conf,p)$[(not pltt_m3(pltt_cc)) and pltt_conf(pltt_cc,conf) and (not pCasoPID)]..
   vGenThmCCConfM2(pltt_cc,conf,p) =l= pTrmPltMinConf(pltt_cc,conf)  + pM*[1 - vbMTCC(pltt_cc,conf,p)]
;

eEqMT2CC(pltt_cc,conf,p)$[(not pltt_m3(pltt_cc)) and pltt_conf(pltt_cc,conf) and (not pCasoPID)]..
    vGenThmCCConfM2(pltt_cc,conf,p) =g= pTrmPltMinConf(pltt_cc,conf)*vbMTCC(pltt_cc,conf,p)
;

eEqMT3CC(pltt_cc, conf ,p)$[(not pltt_m3(pltt_cc)) and pltt_conf(pltt_cc,conf) and (not pCasoPID)]..
   vbMTCC(pltt_cc,conf,p) =g= vCommitTrmCC(pltt_cc,conf,p) - pM*[vGenThmCCConfM2(pltt_cc,conf,p)-[pTrmPltMinConf(pltt_cc,conf)*vCommitTrmCC(pltt_cc,conf,p)]]
;


eMTCC(pltt_cc,p)$(not pCasoPID)..
   sum[(conf)$pltt_conf(pltt_cc,conf), vbMTCC(pltt_cc,conf,p)] =e= vbMT(pltt_cc,p)
;


// Ecuaciones para activar la bandera de bajada del mínimo técnico cuando la planta toca el valor del mínimo técnico y está de salida
eMenvCommitDn(plt_t,p)$[(ord(p) lt card(p)) and (not pltt_m3(plt_t)) and banAux2=1 and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbDownMT (plt_t,p) =l= 1- vCommitTrmPlt(plt_t,p+1)
;

eMenvMTDn(plt_t,p)$[(not pltt_m3(plt_t)) and banAux2=1 and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbDownMT(plt_t,p) =l= vbMT(plt_t,p)
;

eDownMTDn(plt_t,p)$[(ord(p) lt card(p)) and (not pltt_m3(plt_t)) and banAux2=1 and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbDownMT (plt_t,p) =g= [1-vCommitTrmPlt(plt_t,p+1)] + vbMT(plt_t,p) - 1
;

// Condición inicial para la bandera de bajada
eMenvCommitDn_CI(plt_t,p)$[(ord(p) =1) and (not pltt_m3(plt_t)) and bCI=1 and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbDownMT_CI(plt_t) =l= 1- vCommitTrmPlt(plt_t,p)
;

eMenvMTDn_CI(plt_t)$[(not pltt_m3(plt_t)) and bCI=1 and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbDownMT_CI(plt_t) =l= vbMT_CI(plt_t)
;

eDownMTDn_CI(plt_t,p)$[(ord(p) =1) and (not pltt_m3(plt_t)) and bCI=1 and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbDownMT_CI (plt_t) =g= [1-vCommitTrmPlt(plt_t,p)] + vbMT_CI(plt_t) - 1
;


// Ecuaciones para activar la bandera de subida del mínimo técnico cuando la planta está de entrada y va a tocar el valor del mínimo técnico en el periodo siguiente
eMenvCommitUp(plt_t,p)$[(not pltt_m3(plt_t)) and banAux2=1 and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbUpMT (plt_t,p) =l= 1- vCommitTrmPlt(plt_t,p)
;

eMenvMTUp(plt_t,p)$[(ord(p) lt card(p)) and (not pltt_m3(plt_t)) and banAux2=1 and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbUpMT(plt_t,p) =l= vbMT(plt_t,p+1)
;

eDownMTUp(plt_t,p)$[(ord(p) lt card(p)) and (not pltt_m3(plt_t)) and banAux2=1 and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbUpMT (plt_t,p) =g= [1-vCommitTrmPlt(plt_t,p)] + vbMT(plt_t,p+1) - 1
;

// Condición inicial para la bandera de subida

eMenvCommitUp_CI(plt_t)$[(not pltt_m3(plt_t)) and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbUpMT_CI (plt_t) =l= 1- 1$[(TypeMod_CI(plt_t)=2) and (pGenPltiIni(plt_t)>0)]
;

eMenvMTUp_CI(plt_t,p)$[(ord(p)=1) and (not pltt_m3(plt_t)) and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbUpMT_CI(plt_t) =l= vbMT(plt_t,p)
;

eDownMTUp_CI(plt_t,p)$[(ord(p) =1) and (not pltt_m3(plt_t)) and (not pCasoPID) and pRestPlt(plt_t)=0]..
   vbUpMT_CI (plt_t) =g= [1-1$[(TypeMod_CI(plt_t)=2) and (pGenPltiIni(plt_t)>0)]] + vbMT(plt_t,p) - 1
;


*eConfigPltCC(pltt_cc,p)$(not pCasoPID)..
*   vCommitTrmConf(pltt_cc,p)=e=sum[(conf)$(pltt_conf(pltt_cc,conf)), vCommitTrmCC(pltt_cc,conf,p) * ord(conf) ]
*;

eConfigPltCC(pltt_cc,p)$(not pCasoPID)..
   vCommitTrmConf(pltt_cc,p)=e=sum[(conf)$(pltt_conf(pltt_cc,conf)), vCommitTrmCC(pltt_cc,conf,p) * ord(conf) ]
                              +sum[(conf)$(pltt_conf(pltt_cc,conf)), vCommitTrmPltCCM1UR(pltt_cc,conf,p) * ord(conf) ]
                              +sum[(conf)$(pltt_conf(pltt_cc,conf)), vCommitTrmPltCCM1DR(pltt_cc,conf,p) * ord(conf) ]
;


eConfigPltCS(pltt_cs,p)$(not pCasoPID)..
   vCommitTrmConf(pltt_cs,p)=e=pThmConf(pltt_cs)
;


//Ecuaciones para el TULT
parameter
banTULT /1/;

eTULT(pltt_cc, conf, confAux, tstate,uni_t, fuel, p, pp)$(pltt_conf(pltt_cc, conf) and pltt_conf(pltt_cc, confAux) and plt_uni(pltt_cc,uni_t) and not pCasoPID
         and pTrmCCPltTransition(pltt_cc,conf,confAux)=1 and uni_fuel(uni_t,fuel) and pTrmCCPltTULT(pltt_cc, conf, confAux, tstate)>1 and ord(pp)<=pTrmCCPltTULT(pltt_cc, conf, confAux, tstate)
         and ((ord(p) + ord(pp)) le card(p)) and banTULT=1) ..
    vStartUpUniFuelTE(uni_t, fuel, tstate, p + ord(pp) )-[1- vTransitionCC(pltt_cc, conf, confAux, p+(ord(pp)-1))]
    =l= vCommitTrmCC(pltt_cc, conf, p)
;

* Restricción para asignar la configuración a las rampas de subida
eOnOffM1UR(pltt_cc, conf,tstate, p, pp)$(pltt_conf(pltt_cc, conf) and pNumBlUR_ST_ThmPltConf(pltt_cc,conf,tstate)>1 and ord(pp)<=pNumBlUR_ST_ThmPltConf(pltt_cc,conf,tstate)
         and ((ord(p) + ord(pp)) le card(p)) and not pCasoPID) ..
    vStartUpThmPltCCTE(pltt_cc,conf,tstate,p + ord(pp))
    =l= vCommitTrmPltCCM1UR(pltt_cc,conf,p)
;

* Restricción para asignar la configuración a las rampas de bajada
eOnOffM1DR(pltt_cc, conf, p, pp)$(pltt_conf(pltt_cc, conf) and pNumBlkDRThmPltConf(pltt_cc,conf)>1 and ord(pp)<=pNumBlkDRThmPltConf(pltt_cc,conf)
         and ((ord(p) + pNumBlkDRThmPltConf(pltt_cc,conf)) le card(p)) and ((ord(p) + ord(pp)) le card(p)) and not pCasoPID) ..
    vShutDownThmPltCCM1(pltt_cc,conf,p + ord(pp))
    =l= vCommitTrmPltCCM1DR(pltt_cc,conf,p + pNumBlkDRThmPltConf(pltt_cc,conf) )
;

* Obligar la unidad Flores 2 en Flores 4 si tiene encendida al configuración 2

eConf3F4(pltt_cc,conf,p)$(pltt_conf(pltt_cc, conf) and sameas(pltt_cc,'FLORES_4_CC') and sameas(conf,'c3') and not pCasoPID)..
   vCommitTrmCC(pltt_cc,conf,p)=l=2-sum[uni_t$(plt_uni(pltt_cc,uni_t) and (sameas(uni_t,'FLORES_2') or sameas(uni_t,'FLORES_4'))),vCommitmentUni(uni_t,p)]
;

eConf2F4(pltt_cc,conf,p)$(pltt_conf(pltt_cc, conf) and sameas(pltt_cc,'FLORES_4_CC') and sameas(conf,'c2') and not pCasoPID)..
   vCommitTrmCC(pltt_cc,conf,p)=l=2-sum[uni_t$(plt_uni(pltt_cc,uni_t) and (sameas(uni_t,'FLORES_3') or sameas(uni_t,'FLORES_4'))),vCommitmentUni(uni_t,p)]
;

parameter
banArrIni /1/;

eCI_PltTermNoM2_P_1_eq0(plt_t,p)$((not pCasoPID) and ord(p)=1 and TypeMod_CI(plt_t) ne 2 and banArrIni=1 and (sameas(plt_t,'TEBSAB_CC') or sameas(plt_t,'TERMOCANDELARIA_CC')
                                 or sameas(plt_t,'BARRANQUILLA_3') or sameas(plt_t,'BARRANQUILLA_4') or sameas(plt_t,'FLORES_I_CC') or sameas(plt_t,'FLORES_4_CC')))..
     vGenPlt(plt_t,p)=l=0
;

*eBranchFlow(Br,p)..

*vBranchFlow(Br,p)=e=sum[(ni,uni),PTDF(ni,Br)* vGenUni(uni,p)]-sum[(ni,sba),PTDF(ni,Br)*pDemandSba(p,sba)*FacNodo(ni,sba)]

* vGenPlt.fx('FLORES_4_CC','12')=120;
* vGenPlt.fx('FLORES_4_CC','1')=0;
* vCommitTrmCC.fx('FLORES_4_CC','c3','17')=1;

* vGenPlt.fx('FLORES_I_CC','21')=65;
* vGenPlt.fx('FLORES_4_CC','20')=120;
* vGenPlt.fx('FLORES_4_CC','15')=120;
* vGenPlt.fx('FLORES_4_CC','24')=0;

* vGenPlt.lo('TEBSAB_CC','21')=20;
* vCommitTrmCC.fx('TEBSAB_CC','c2','21')=1;
* vCommitTrmCC.fx('TEBSAB_CC','c1','20')=1;
* vCommitTrmCC.fx('TEBSAB_CC','c11','4')=1;


* vGenPlt.fx('FLORES_4_CC','13')=220;
* vGenPlt.fx('FLORES_4_CC','15')=0;
* vGenPlt.fx('GECELCA_32','1')=0;

* vGenPlt.lo('GUAJIRA_2','21')=72;
* vGenPlt.lo('GUAJIRA_1','21')=72;

* vStartUpUniFuelTE.fx('TEBSA_24','Gas','cold','21')=1;
* vCommitmentUni.fx('TEBSA_24','21')=1;
* vCommitmentUni.fx('TEBSA_11','21')=1;
* vGenPlt.lo('TEBSAB_CC','19')=210;
* vGenPlt.fx('TEBSAB_CC','11')=210;
* vGenPlt.up('TEBSAB_CC','24')=0;
* vGenPlt.fx('BARRANQUILLA_3','11')=33;

* vCommitTrmCC.fx('FLORES_4_CC','c3','21')=1;
* vCommitTrmCC.fx('TERMOCANDELARIA_CC','c3','21')=1;

* vCommitmentUni.fx('PROELECTRICA_1','20')=1;
* vCommitmentUni.fx('PROELECTRICA_1','24')=1;

* vGenPlt.lo('DC_TR_BOL_Proy','19')=100;
* vGenPlt.fx('TERMOCANDELARIA_CC','10')=0;

* vGenUni.fx('TERMOCANDELARIA_CC_2','15')=0;
* vGenUni.lo('TERMOCANDELARIA_CC_2','16')=0.1; 
* vGenUni.fx('TERMOCANDELARIA_CC_2','17')=0;

* vGenUni.fx('TEBSA_21','19')=50;

* vGenUni.lo('TERMOCANDELARIA_CC_1','21')=0.1; 

* vGenPlt.fx('DC_TR_BOL_Proy','1')=0;
* vGenPlt.lo('DC_TR_BOL_Proy','19')=1;

* vGenTrmPltURM1.fx('TERMOCANDELARIA_CC','16')=37;


EqAux(p)$(ord(p)>=1 and 0=1)..
vGenPlt('TEBSAB_CC',p)=g=210;
*vCommitTrmCC('TEBSAB_CC','c7',p)=e=1
* vGenPlt('TEBSAB_CC',p)  =l=0
;


$ONTEXT

*vGenPlt.fx('BARRANQUILLA_3','p04')=15;
*vGenTrmPltURM1.fx('BARRANQUILLA_3','p05')=33;
vGenUni.fx('BARRANQUILLA_3','p01')=0;
vGenPlt.fx('BARRANQUILLA_3','p06')=50;

vGenPlt.fx('GECELCA_32','p01')=0;
vGenPlt.fx('GECELCA_32','p11')=270;
*vGenPlt.fx('GECELCA_32','p26')=131;

vGenPlt.fx('CARTAGENA_1','p15')=52;

vGenPlt.fx('CARTAGENA_3','p15')=66;

vGenPlt.fx('TERMONORTE','p15')=17;


vGenPlt.fx('FLORES_4_CC','p15')=445;
*vGenUni.fx('FLORES_2','p02')=80;
*vCommitTrmCC.fx('FLORES_4_CC','c1','p21')=1;
*vCommitTrmCC.fx('FLORES_4_CC','c1','p04')=1;
*vGenPlt.fx('FLORES_4_CC','p23')=0;
*vGenPlt.fx('FLORES_4_CC','p50')=445;


vGenPlt.fx('TERMOCANDELARIA_CC','p01')=0;
vGenPlt.fx('TERMOCANDELARIA_CC','p16')=550;
*vCommitTrmCC.fx('TERMOCANDELARIA_CC','c2','p05')=1;
*vGenPlt.fx('TERMOCANDELARIA_CC','p66')=550;
*vStartUpThmPltCCTE.fx('TERMOCANDELARIA_CC','c1','warm','p05')=1;
*vShutDownThmPltCCM1.fx('TERMOCANDELARIA_CC','c1','p24')=1;
*vGenPlt.fx('TERMOCANDELARIA_CC','p59')=550;


*vGenPlt.fx('TEBSAB_CC','p16')=790;
*vGenPlt.fx('TEBSAB_CC','p23')=0;
*vGenPlt.fx('TEBSAB_CC','p37')=790;

*vGenPlt.fx('TEBSAB_CC','p66')=790;


*vGenPlt.fx('TERMOSIERRA_CC','p17')=360;
*vGenPlt.fx('TERMOSIERRA_CC','p45')=360;



eInertia(p) ..
   + sum[t, vCommitment(p,t)*pTInertia(t)]
   + sum[h, vCommitment(p,h)*pHInertia(h)]
  =g=
   pInertia
;

eWtReserve(p,e)$[Not pTightPoolSim] ..  vWtReserve(p-1,e) + pIniReserve(e) $p1(p) - vWtReserve(p,e) +
                                        pInflows(p,e) - vSpillage(p,e) + sum[eue(ee,e), vSpillage(p,ee)] +
                                        sum[hue(h,e), pInflowsCF*vTotalOutPut (p,h)/pProdFunct(h)] -
                                        sum[euh(e,h), pInflowsCF*vTotalOutPut (p,h)/pProdFunct(h)] =e= 0
;
eWtReserveTarget(p,e)$[ord(p) = card(p)] .. vWtReserve(p,e) =g= pFinReserve(e);

eMinSysReserve  (p) ..  sum(e, vWtReserve(p,e)) + vSlackReserve(p) =g= pSysMinReserve(p);



$OFFTEXT
