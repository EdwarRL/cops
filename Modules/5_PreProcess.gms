$EOLCOM //


*-------------------------------------------------------------------------------
*              Subsets activation and scaling parameters
*-------------------------------------------------------------------------------

* determine the first periodo

p1(p)      $[ord(p) =       1] = yes ;

* assignment of thermal units, hydro units, and renewables units
*uni_t    (uni) $[tThermalUnitPar  (uni,'ExisUnits' )]     = yes ;
*uni_h    (uni) $[tHydroUnitPar  (uni,'ExisUnits'   )]     = yes ;
*uni_v    (uni) $[tVarUnitPar    (uni,'ExisUnits'   )]     = yes ;

uni_fuel (uni_t,fuel) $[tThermalUnitParFuel(uni_t,fuel,'ExisUnits'   )]     = yes ;
pltt_conf(plt_t,conf) $[tConfParameters(plt_t,conf,'DISP'   )>0]     = yes ;

* assignment of thermal plants, hydro plats, and renewables plants
*plt_t    (plt) $[tThermalPltPar(plt,'ExisUnits'   )]     = yes ;
*plt_h    (plt) $[tHydroPltPar  (plt,'ExisUnits'   )]     = yes ;
*plt_v    (plt) $[tVarPltPar    (plt,'ExisUnits'   )]     = yes ;

* pltt_cc (plt_t) $[tThermalPltPar(plt_t,'CycleType'   ) eq 1]     = yes ;
* pltt_cs (plt_t) $[tThermalPltPar(plt_t,'CycleType'   ) eq 2]     = yes ;

pDayCount=1
loop(p,
   pDayCount = floor((ord(p)-1)/ pNumHours)+1;
   loop(d,
      if( ord(d) eq pDayCount,
         pd(p,d) = Yes;
      );
   );
);



* Assing data to each parameter
pDemandSba         (p,sba ) = tDemand(p,sba);

// Thermal unit parameters
pTMinProd       (      uni_t,fuel        )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'MT');
pMinUpT         (      uni_t,fuel        )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'MinUpT');
pMinDownT       (      uni_t,fuel        )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'MinDownT');
pStartUpxDayFuel(      uni_t,fuel        )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'StartUpxDay');
pStartUpCost    (      uni_t,fuel,'cold' )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'SupCostC');
pStartUpCost    (      uni_t,fuel,'warm' )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'SupCostW');
pStartUpCost    (      uni_t,fuel,'hot'  )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'SupCostH');
pTmStStIni      (      uni_t,fuel,'cold' )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'TOLC_Ini');
pTmStStIni      (      uni_t,fuel,'warm' )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'TOLW_Ini');
pTmStStIni      (      uni_t,fuel,'hot'  )$(uni_fuel(uni_t,fuel))  = 0;
pTmStStFin      (      uni_t,fuel,'cold' )$(uni_fuel(uni_t,fuel))  = 9999;
pTmStStFin      (      uni_t,fuel,'warm' )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'TOLW_fin');
pTmStStFin      (      uni_t,fuel,'hot'  )$(uni_fuel(uni_t,fuel))  = tThermalUnitParFuel(uni_t,fuel,'TOLH_fin');
pUnitType       (      uni_t             )                         = tThermalUnitPar  (uni_t,'TypeUnit');




parameter Nstart;

loop(uni_t,
   pStartUpxDay(uni_t)=0;
   Nstart=0;
   loop(fuel,
      if(uni_fuel(uni_t,fuel) and (pStartUpxDayFuel(uni_t,fuel)>Nstart),
         pStartUpxDay(uni_t)=pStartUpxDayFuel(uni_t,fuel);
         Nstart=pStartUpxDayFuel(uni_t,fuel);

      );
   );
);

// Hydro unit parameters
pHydroMinProd       (      uni_h        )=tHydroUnitPar  (uni_h,'MT'   );

// Variable unit parameters
pVarMinProd       (      uni_v        )=tVarUnitPar  (uni_v,'MT'   );

// Offer parameters
* pThmMaxprodUni      (uni_t,p            ) = tThermalDispU(uni_t,p);
* pHydMaxprodUni      (uni_h,p            ) = tHydroDispU(uni_h,p);
* pVarMaxprodUni      (uni_v,p            ) = tVarDispU(uni_v,p);

pMaxprodUni         (uni,p              ) = tDispU(uni,p);
pThmMaxprodUni      (uni_t,p            ) = tDispU(uni_t,p);
pHydMaxprodUni      (uni_h,p            ) = tDispU(uni_h,p);
pVarMaxprodUni      (uni_v,p            ) = tDispU(uni_v,p);


*Disponibilidad de las pantas térmicas, se calcula con la suma de las undiades
pDispThmPlt(plt_t,p)=sum[uni_t$(plt_uni(plt_t,uni_t)),pThmMaxprodUni(uni_t,p)];

* Disponibildad comercial de las plantas
if(pCasoIDE,
   pDispCom(plt,p) = tDisPltCOM(plt,p);
);

// Thermal unit initial condition
pGenUniIni        (       uni_t       ) = tThermalUniCI(uni_t,'GenIni');
pCountOnUni       (       uni_t       ) = tThermalUniCI(uni_t,'TLIni');
pCountOffUni      (       uni_t       ) = tThermalUniCI(uni_t,'TFLIni');


parameter banLP;
banLP=1;
* if(pLargoPlazo,

*    loop(uni_t,

*       if((sameas(uni_t,'DC_TR_INT_Proy') or sameas(uni_t,'DC_TR_ATL_Proy') or sameas(uni_t,'DC_TR_BOL_Proy') or sameas(uni_t,'DC_TR_GCM_Proy') 
*          or sameas(uni_t,'DC_TR_CS_Proy') or sameas(uni_t,'DC_TR_CRR_Proy') or sameas(uni_t,'DC_TR_INT_Proy_1') or sameas(uni_t,'DC_TR_ATL_Proy_1') 
*          or sameas(uni_t,'DC_TR_BOL_Proy_1') or sameas(uni_t,'DC_TR_GCM_Proy_1') or sameas(uni_t,'DC_TR_CS_Proy_1') or sameas(uni_t,'DC_TR_CRR_Proy_1') or 
*          sameas(uni_t,'DC_TR_INT_Proy_2') or sameas(uni_t,'DC_TR_ATL_Proy_2') or sameas(uni_t,'DC_TR_BOL_Proy_2') or sameas(uni_t,'DC_TR_GCM_Proy_2') or 
*          sameas(uni_t,'DC_TR_CS_Proy_2') or sameas(uni_t,'DC_TR_CRR_Proy_2')) and (1=banLP),

*                pTMinProd(uni_t,'Gas')=max(20,round(pThmMaxprodUni(uni_t,'1')*0.3,0));

*                if(pGenUniIni(uni_t)>0 and pGenUniIni(uni_t)<=pTMinProd(uni_t,'Gas'),
*                   pGenUniIni(uni_t)=pTMinProd(uni_t,'Gas');
*                );

*       );
*    );

* );



* loop(uni_t,
*       loop(p,
*          loop(fuel,
*             if( ((ord(p) eq 1) and (ord(fuel) eq 1)),
*                pGenUniIni(uni_t)=pMinUpT(uni_t,fuel);
*                pCountOnUni(uni_t)=100;
*                pCountOffUni(uni_t)=0;
*             );
*          )
*       );
* );



loop(uni_t,
      loop(p,
         if( ((ord(p) eq 1) and (pThmMaxprodUni(uni_t,p) eq 0)),
            pGenUniIni(uni_t)=0;
            pCountOnUni(uni_t)=0;
            pCountOffUni(uni_t)=72;
         );
      );
);



* pGenUniIni('TERMOEMCALI_1_GAS')=130;
* pCountOnUni('TERMOEMCALI_1_GAS')=24;
* pCountOffUni('TERMOEMCALI_1_GAS')=0;
* pGenUniIni('TERMOEMCALI_1_VAPOR')=20;
* pCountOnUni('TERMOEMCALI_1_VAPOR')=24;
* pCountOffUni('TERMOEMCALI_1_VAPOR')=0;


onoff_t0Uni       (       uni_t       )$(pCountOnUni(uni_t) gt 0) = 1;
L_up_minUni       (       uni_t,fuel        )$(uni_fuel(uni_t,fuel))  = min(card(p), (pMinUpT(uni_t,fuel )-pCountOnUni(uni_t))*onoff_t0Uni(uni_t));
L_down_minUni     (       uni_t,fuel        )$(uni_fuel(uni_t,fuel))  = min(card(p), (pMinDownT(uni_t,fuel )-pCountOffUni(uni_t))*(1-onoff_t0Uni(uni_t)));


// Thermal plant parameters
pThermalCSVarCost      (       plt_t       ) = tThermalPltPar(plt_t,'VarCost');
pThmConf              (plt_t) = tThermalPltPar(plt_t,'Config');

pThermalCCVarCost      (     pltt_cc,conf       )$(pltt_conf(pltt_cc,conf)) = tOfferConfigThermalCC(pltt_cc,conf,'VarCost');
pTrmCCDispConf         (       pltt_cc,conf,p   )$(pltt_conf(pltt_cc,conf)) = tAvalConfigThermalCC(pltt_cc,conf,p);
pTrmPltMinConf          (       plt_t,conf  )$(pltt_conf(plt_t,conf)) = tConfParameters(plt_t,conf,'MT');
pTrmPltMaxConf          (       plt_t,conf  )$(pltt_conf(plt_t,conf)) = tConfParameters(plt_t,conf,'DISP');



// Thermal plant initial condition
pGenPltiIni         (      plt_t       ) = tThermalPltCI(plt_t,'GenIni');
pConfPltIni       (      plt_t        ) = tThermalPltCI(plt_t,'ConfIni');
TypeMod_CI        (     plt_t         ) = tThermalPltCI(plt_t,'TipoModIni');


* if(pLargoPlazo,

*    loop(pltt_cs,

*       if((sameas(pltt_cs,'DC_TR_INT_Proy') or sameas(pltt_cs,'DC_TR_ATL_Proy') or sameas(pltt_cs,'DC_TR_BOL_Proy') or sameas(pltt_cs,'DC_TR_GCM_Proy') 
*          or sameas(pltt_cs,'DC_TR_CS_Proy') or sameas(pltt_cs,'DC_TR_CRR_Proy') or sameas(pltt_cs,'DC_TR_INT_Proy_1') or sameas(pltt_cs,'DC_TR_ATL_Proy_1') 
*          or sameas(pltt_cs,'DC_TR_BOL_Proy_1') or sameas(pltt_cs,'DC_TR_GCM_Proy_1') or sameas(pltt_cs,'DC_TR_CS_Proy_1') or sameas(pltt_cs,'DC_TR_CRR_Proy_1') or 
*          sameas(pltt_cs,'DC_TR_INT_Proy_2') or sameas(pltt_cs,'DC_TR_ATL_Proy_2') or sameas(pltt_cs,'DC_TR_BOL_Proy_2') or sameas(pltt_cs,'DC_TR_GCM_Proy_2') or 
*          sameas(pltt_cs,'DC_TR_CS_Proy_2') or sameas(pltt_cs,'DC_TR_CRR_Proy_2')) and (1=banLP),
         
*          loop(uni_t,
         
*             if(sameas(uni_t,pltt_cs),
*                pTrmPltMaxConf(pltt_cs,'c1')=pThmMaxprodUni(uni_t,'1');
*                pTrmPltMinConf(pltt_cs,'c1')=max(20,round(pThmMaxprodUni(uni_t,'1')*0.3,0));

*                if(pGenUniIni(uni_t)>0 and pGenUniIni(uni_t)<=pTMinProd(uni_t,'Gas'),
*                   pGenPltiIni(pltt_cs)=pTMinProd(uni_t,'Gas');
*                );

*             );
*          );
*       );
*    );

* );


// Ajustar las codiciones iniciales para que las cambie según el requerimiento

loop(plt_t,
      loop(p,
         if( ((ord(p) eq 1) and (pDispThmPlt(plt_t,p) eq 0)),
            pGenPltiIni(plt_t)=0;
            TypeMod_CI(plt_t)=0;
         );
      );
);

$ONTEXT
loop(plt_t,
      if( (sameas(plt_t,'PROELECTRICA_2') or sameas(plt_t,'PROELECTRICA_1')) and (pGenPltiIni(plt_t)=42),
            pGenPltiIni(plt_t)=0;
            TypeMod_CI(plt_t)=0;

            if (sameas(plt_t,'PROELECTRICA_2'),
               pGenUniIni('PROELECTRICA_2')=0;
               pCountOnUni('PROELECTRICA_2')=0;
               pCountOffUni('PROELECTRICA_2')=4;
            else
               pGenUniIni('PROELECTRICA_1')=0;
               pCountOnUni('PROELECTRICA_1')=0;
               pCountOffUni('PROELECTRICA_1')=4;
            );
      );
);
$OFFTEXT


*ThermalState_CI(plt_t) = tThermalPltPar(plt_t,'ThermalState_CI');


pTrmCSMinConf(pltt_cs)=0;
pTrmCSMaxConf(pltt_cs)=0;
loop((pltt_cs,conf)$pltt_conf(pltt_cs,conf),

   if((pThmConf(pltt_cs)=ord(conf)),
      pTrmCSMinConf(pltt_cs) = pTrmPltMinConf(pltt_cs,conf);
      pTrmCSMaxConf(pltt_cs) = pTrmPltMaxConf( pltt_cs,conf);
   );


);



pThmPltNumUniComb(plt_t,conf)$(pltt_conf(plt_t,conf)) = tConfParameters(plt_t,conf,'CombUni'   );
pThmPltNumUniSteam(plt_t,conf)$(pltt_conf(plt_t,conf)) = tConfParameters(plt_t,conf,'SteamUni' );
pThmPltTotalUni(plt_t,conf)$(pltt_conf(plt_t,conf)) = pThmPltNumUniComb(plt_t,conf) + pThmPltNumUniSteam(plt_t,conf);


// Hydro  plant parameters
pHydroVarCost      (        plt_h     ) = tHydroPltPar(plt_h,'VarCost');


// Renewable  plant parameters
pVarVarCost      (     plt_v     ) = tVarPltPar(plt_v,'VarCost');


* Thermal plants ramps parameter
pHotStartUpRampsThmPltConf    ( plt_t,conf,    r  )$(pltt_conf(plt_t,conf)) = tHotstartupM1(plt_t,conf,r);
pWarmStartUpRampsThmPltConf   ( plt_t,conf,    r  )$(pltt_conf(plt_t,conf)) = tWarmstartupM1(plt_t,conf,r);
pColdStartUpRampsThmPltConf   ( plt_t,conf,    r  )$(pltt_conf(plt_t,conf)) = tColdstartupM1(plt_t,conf,r);

pNumBlkHotThmPltConf          (      plt_t,conf       )$(pltt_conf(plt_t,conf)) = sum((r)$(pHotStartUpRampsThmPltConf(plt_t,conf,    r) gt  0),1);
pNumBlkWarmThmPltConf          (      plt_t,conf       )$(pltt_conf(plt_t,conf)) = sum((r)$(pWarmStartUpRampsThmPltConf(plt_t,conf,    r) gt  0),1);
pNumBlkColdThmPltConf          (      plt_t,conf       )$(pltt_conf(plt_t,conf)) = sum((r)$(pColdStartUpRampsThmPltConf(plt_t,conf,    r) gt  0),1);

pNumBlUR_ST_ThmPltConf(plt_t,conf,'hot')$(pltt_conf(plt_t,conf))=pNumBlkHotThmPltConf(plt_t,conf);
pNumBlUR_ST_ThmPltConf(plt_t,conf,'warm')$(pltt_conf(plt_t,conf))=pNumBlkWarmThmPltConf(plt_t,conf);
pNumBlUR_ST_ThmPltConf(plt_t,conf,'cold')$(pltt_conf(plt_t,conf))=pNumBlkColdThmPltConf(plt_t,conf);

pShutdownRampsPltConf   (      plt_t,conf, r   )$(pltt_conf(plt_t,conf)) = tShutdownRampM1(plt_t,conf,r);
pNumBlkDRThmPltConf     (      plt_t,conf      )$(pltt_conf(plt_t,conf)) = sum((r)$(pShutdownRampsPltConf(plt_t,conf,r) gt  0),1);

pPosRampHot         (plt_t,conf, r, p )$((ord(p)+ord(r)<= card(p) and ord(r) <= pNumBlkHotThmPltConf( plt_t,conf)) and (pltt_conf(plt_t,conf))) = ord(p)+ord(r);
pPosRampWarm         (plt_t,conf, r, p )$((ord(p)+ord(r)<= card(p) and ord(r) <= pNumBlkWarmThmPltConf( plt_t,conf)) and (pltt_conf(plt_t,conf)))= ord(p)+ord(r);
pPosRampCold         (plt_t,conf, r, p )$((ord(p)+ord(r)<= card(p) and ord(r) <= pNumBlkColdThmPltConf( plt_t,conf)) and pltt_conf(plt_t,conf)) = ord(p)+ord(r);

pPosRampDR         (plt_t,conf, r, p)$((ord(p)-ord(r)+1 >0 and ord(r)<= pNumBlkDRThmPltConf( plt_t,conf)) and pltt_conf(plt_t,conf)) = ord(p)-ord(r)+1;


// Parameters model 2
pUpRateRmp      ( plt_t,conf,    r   )$(pltt_conf(plt_t,conf))= tUpRampRateM2(plt_t,conf,r);
pLowerUpRate    ( plt_t,conf,    r   )$(pltt_conf(plt_t,conf))= tLowerUpRampM2(plt_t,conf,r);
pUpperUpRate    ( plt_t,conf,    r   )$(pltt_conf(plt_t,conf))= tUpperUpRampM2(plt_t,conf,r);
pDownRateRmp    ( plt_t,conf,    r   )$(pltt_conf(plt_t,conf))= tDownRampRateM2(plt_t,conf,r);
pLowerDownRate  ( plt_t,conf,    r   )$(pltt_conf(plt_t,conf))= tLowerDownRampM2(plt_t,conf,r);
pUpperDownRate  ( plt_t,conf,    r   )$(pltt_conf(plt_t,conf))= tUpperDownRampM2(plt_t,conf,r);

// Parameters model 3
pUpRampMod3     ( plt_t,conf,      l)$(pltt_conf(plt_t,conf))= tUpRampM3(plt_t,conf,l);
pDownRampMod3   ( plt_t,conf,      l)$(pltt_conf(plt_t,conf))= tDownRampM3(plt_t,conf,l);
pURMod3         ( plt_t,conf        )$(pltt_conf(plt_t,conf))= tUpRampM3(plt_t,conf,'UR');
pDRMod3         ( plt_t,conf        )$(pltt_conf(plt_t,conf))= tDownRampM3(plt_t,conf,'DR');


pTrmPltStartConf          ( plt_t,conf )$(pltt_conf(plt_t,conf)) = tConfParameters2(plt_t,conf,'Start');
pTrmPltShutdownConf          ( plt_t,conf )$(pltt_conf(plt_t,conf)) = tConfParameters2(plt_t,conf,'Down');


// Thermal CC transitions parameter
pTrmCCPltTransition(pltt_cc,conf,confAux)$(pltt_conf(pltt_cc,conf) and pltt_conf(pltt_cc,confAux)) = tThmCCTransitionConf(pltt_cc,conf,confAux,'Transition');
pTrmCCPltTULT(pltt_cc,conf,confAux,'cold')$(pltt_conf(pltt_cc,conf) and pltt_conf(pltt_cc,confAux)) = tTULTCC(pltt_cc,conf,confAux,'cold');
pTrmCCPltTULT(pltt_cc,conf,confAux,'warm')$(pltt_conf(pltt_cc,conf) and pltt_conf(pltt_cc,confAux)) = tTULTCC(pltt_cc,conf,confAux,'warm');
pTrmCCPltTULT(pltt_cc,conf,confAux,'hot')$(pltt_conf(pltt_cc,conf) and pltt_conf(pltt_cc,confAux)) = tTULTCC(pltt_cc,conf,confAux,'hot');

pTransitionCC_CI(pltt_cc, confAux, conf, p)$(pltt_conf(pltt_cc,confAux) and pltt_conf(pltt_cc,conf) and ord(confAux)=pConfPltIni(pltt_cc) 
                                                and (pTrmCCPltTransition(pltt_cc,confAux,conf)=1 or (ord(confAux)=ord(conf))) and (ord(p)=1))=1;

// Zones parameter
if(pZonWeightsPer,
   pWeightUnitZone(uni,p,zn)=tUnitWeightsPer(uni,p,zn);
else
   loop(uni,
      loop(p,
         loop(zn,
            pWeightUnitZone(uni,p,zn)=tUnitWeights(uni,zn);
         )
      )
   )
);


pZoneType(zntype,zn)=ttypeZona(zntype,zn);

pUnitZoneReq(zn,p)=tUnitZoneReq(zn,p);

pMWminZoneReq(zn,p)=tMWminZoneReq(zn,p);

pMWmaxZoneReq(zn,p)=tMWmaxZoneReq(zn,p);

pArImportLim(ar,p)=tAreaImportLim(ar,p);

pMinGenPlt(plt,p)=tMinimumGenPlt(plt,p);

pMaxGenPlt(plt,p)=tMaxGenPlt(plt,p);

pMOGenPlt(plt,p)=tMOGenPlt(plt,p);

// Parámetros para las condiciones iniciales

vGenTrmPltM2_CI(plt_t)$[(TypeMod_CI(plt_t)=2) and (pGenPltiIni(plt_t)>0)] = pGenPltiIni(plt_t);

vGenTrmPltURM1_CI(plt_t)$[(TypeMod_CI(plt_t)=12) and (pGenPltiIni(plt_t)>0)] = pGenPltiIni(plt_t);

* pPTDF(ni,Br)=tPTDF(ni,Br);
* pLODF(Br,Brk)=tLODF(Br,Brk);

pPruebasUni(uni,p) = tPruGenUni(uni,p);

pPruUniD (uni) = sum((p),pPruebasUni(uni,p));

pRestUni (uni_t)=0;
* pRestUni (uni_t) = 1$(pPruUniD (uni_t)>0);

pRestPlt (plt_t)=0;
* pRestPlt (pltt_cs)=1$(sum((uni_t)$plt_uni(pltt_cs,uni_t),pPruUniD (uni_t))>0);


* Preproceso para cambiar el PAP de los recruso nuevos de LP que están en un solo elemento




$ONTEXT

if(pLargoPlazo,

   loop(pltt_cs,

      if((sameas(pltt_cs,'DC_TR_INT_Proy') or sameas(pltt_cs,'DC_TR_ATL_Proy') or sameas(pltt_cs,'DC_TR_BOL_Proy') or sameas(pltt_cs,'DC_TR_GCM_Proy') 
         or sameas(pltt_cs,'DC_TR_CS_Proy') or sameas(pltt_cs,'DC_TR_CRR_Proy') or sameas(pltt_cs,'DC_TR_INT_Proy_1') or sameas(pltt_cs,'DC_TR_ATL_Proy_1') 
         or sameas(pltt_cs,'DC_TR_BOL_Proy_1') or sameas(pltt_cs,'DC_TR_GCM_Proy_1') or sameas(pltt_cs,'DC_TR_CS_Proy_1') or sameas(pltt_cs,'DC_TR_CRR_Proy_1') or 
         sameas(pltt_cs,'DC_TR_INT_Proy_2') or sameas(pltt_cs,'DC_TR_ATL_Proy_2') or sameas(pltt_cs,'DC_TR_BOL_Proy_2') or sameas(pltt_cs,'DC_TR_GCM_Proy_2') or 
         sameas(pltt_cs,'DC_TR_CS_Proy_2') or sameas(pltt_cs,'DC_TR_CRR_Proy_2')) and (1=0),
         
         loop(uni_t,
         
            if(sameas(uni_t,pltt_cs),

               pTMinProd(uni_t,'Gas')=max(20,round(pThmMaxprodUni(uni_t,'1')*0.3,0));

               pTrmPltMaxConf(pltt_cs,'c1')=pThmMaxprodUni(uni_t,'1');
               pTrmPltMinConf(pltt_cs,'c1')=max(20,round(pThmMaxprodUni(uni_t,'1')*0.3,0));

               if(pGenUniIni(uni_t)>0 and pGenUniIni(uni_t)<=pTMinProd(uni_t,'Gas'),
                  pGenUniIni(uni_t)=pTMinProd(uni_t,'Gas')+1;
                  pGenPltiIni(pltt_cs)=pTMinProd(uni_t,'Gas')+1;
               );
   
            );
         );
      );
   );

);




pOpReserve     (p,  z          ) = topreserve(p,z);

pSt0           (       t       ) = tThermalGen(t,'St0');

pConfig        (       t       ) = tThermalGen(t,'Config');
pTInertia      (       t       ) = tThermalGen(t,'Inertia');

sc(t,c) $[ord(c) = pConfig(t)] = yes;





;




pud0           (       t       )$[pGt0(t) eq pTMinProd(t)] = 1;




pHInertia      (         h     ) = tHydrogen(h,'Inertia');
pProdFunct     (         h     ) = tHydroGen(h,'ProdFunct')* 1e+6;
pMaxReserve    (e)               = tReservoir (e,'MaxReserve'      );
pMinReserve    (e)               = tReservoir (e,'MinReserve'      );
pIniReserve    (e)               = tReservoir (e,'IniReserve'      )*pMaxReserve(e);
pFinReserve    (e)               = tReservoir (e,'FinalReserve'    )*pMaxReserve(e);
pInflows       (p,e)             = pInflowsCF*tInflows(p,e)*1e-6;
pSysMinReserve (p             ) = tminsysreserve(p,'MinReserve')*sum(e,pMaxReserve(e));


*Minimum reserve energy required

pMinReservereq(e) = sum[euh(e,h), pHMinProd (h)*pInflowsCF*card(p)/pProdFunct(h)];

loop(e,
         if(pIniReserve(e) - pFinReserve(e) + sum[hue(h,e), pHMinProd (h)*pInflowsCF*card(p)/pProdFunct(h)] < pMinReservereq(e),
            pFinReserve(e) =  pIniReserve(e) - pMinReservereq(e) + sum[hue(h,e), pHMinProd (h)*pInflowsCF*card(p)/pProdFunct(h)]);
);

$OFFTEXT


*display pGenUniIni;
