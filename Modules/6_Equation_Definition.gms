$EOLCOM //


equations
eTotalCost                          total system variable cost                       [USD]

*  equations for DC power flow
eBalance(p)                         load generation balance              [MW]

* Unit constraints
eThermalUniDisp    (uni_t,p            )     availability of thermal unit                   [MW]
eThermalMTUni    (uni_t,p            )       min output of thermal unit                   [MW]

*Restriccines mayor que cero
* Unit constraints
eThermalUniDispMC    (uni_t,p            )     availability of thermal unit                   [MW]
eThermalMCUni    (uni_t,p            )       min output of thermal unit                   [MW]
eUpDownRatioMC  (uni_t, p        )     StartUp and ShutDown ratio                             [0-1]
eUpDownRatioCIMC(uni_t, p       )      StartUp and ShutDown ratio in the initial condition    [0-1]
eUpDownSingularityMC(uni_t, p   )     StartUp and ShutDown singularity
eDnFuelRatioMC(uni_t, p)                Realtion between unit ShutDown and Fuel

* Plantas mayor que cero
eThmDispGenMC(plt_t,p)
eThmMinGenMC(plt_t,p)
eUpDownRatioPltMC  (plt_t, p        ) 
eUpDownRatioPltCIMC  (plt_t, p        ) 
eUpDownSingularityThmPltMC(plt_t, p)
eCmmitUniCommitPltRelationMC(uni_t,p )



eCmmitUniCommitPltRelation(uni_t,p )

eTotalThmOutPutUni(uni_t,p)

eCommitUniFuel(uni_t,p)                 relation between unit commitment and unit-fuel commitment

eHydroUniDisp    (uni_h,p            )     availability of hydro unit                   [MW]
eHydroMTUni    (uni_h,p            )       min output of hydro unit                   [MW]

eVarUniDisp    (uni_v,p            )     availability of variable unit                   [MW]
eVarMTUni    (uni_v,p            )       min output of variable unit                   [MW]


ePruUni(uni,p)  obligar generación de la unidad cuando está en pruebas

eGenPlantUni(plt,p)                       realtion Plant-unit

eGenPlantUniM2(plt_t,p)                       realtion Plant-unit
eGenPlantUniM1StartUp(plt_t,p)                       realtion Plant-unit
eGenPlantUniM1ShutDoww(plt_t,p)                       realtion Plant-unit

eUpDownRatio  (uni_t, p        )     StartUp and ShutDown ratio                             [0-1]
eUpDownRatioCI(uni_t, p       )      StartUp and ShutDown ratio in the initial condition    [0-1]



eUpDownSingularity(uni_t, p   )     StartUp and ShutDown singularity


eStFuelRatio(uni_t, p)                Realtion between unit StartUp and Fuel
eStFuelTERatio(uni_t,fuel, p)                Realtion between unit StartUp and Fuel

eStFuelRatio_MC(uni_t, p)     Realtion between unit StartUp and Fuel when generation greater than zero

eDnFuelRatio(uni_t, p)                Realtion between unit ShutDown and Fuel

eMTL_CI  (uni_t, fuel, p )         minimum up time for thermal unit at initial condition                 [hours]
eMTFL_CI  (uni_t, fuel, p )         minimum down time for thermal unit at initial condition                 [hours]
eMTL  (uni_t, fuel, p )              minimum up time for thermal unit                  [hours]
* eMTLMC  (uni_t, fuel, p )              minimum up time for thermal unit                  [hours]
eMTFL  (uni_t, fuel, p )             minimum down time for thermal unit                [hours]
eMTL_MC (uni_t,fuel, p )


eMaxStartupxDay(uni_t,d )     maximum startups per day for thermal unit              [p.u.]

* Ecuación temporal mientras se ajusta que la MC no haga stwich en la unidad
eMaxStartupxDayMC(uni_t,d )

eHotStartUniFuel (uni_t, fuel, p )       Thermal Unit activation of hot start
eWarmStartUniFuel (uni_t, fuel, p )       Thermal Unit activation of warm start
eColdStartUniFuel (uni_t, fuel, p )       Thermal Unit activation of warm start

* eRelOnOffMC_Starup_Cold(uni_t,fuel,tstate,p,pltt_cc,conf)
* eRelOnOffMC_Starup_Warm(uni_t,fuel,tstate,p,pltt_cc,conf)
* eRelOnOffMC_Starup_Hot(uni_t,fuel,tstate,p,pltt_cc,conf)

* Plant Contraints
eThermalGenConfCC(pltt_cc,conf,p)                Thermal Generation Ouptput of CC plants  [MW]
eThermalGenCS(pltt_cs,p)              Thermal Generation Ouptput of CS plants  [MW]
eHydroGen(plt_h,p)                  Hydro Generation Ouptput  [MW]
eVariableGen(plt_v,p)               Variable Generation Ouptput  [MW]

// Thermal CC constraints
eGenTrmCCConfM2(pltt_cc,p)               relation between Gen CC and Gen CC Conf
eDispTrmCCConfM2(pltt_cc,conf,p)         avaliability of CC thermal plant per configuration
eMinTrmCCConfM2(pltt_cc,conf,p)          minimum of CC thermal plant per configuration
eSingularityThrmCCM2(pltt_cc,p)          Singularitu of configuration per period

eGenTrmCCConfM1UR(pltt_cc,p)               relation between Gen CC and Gen CC Conf
eGenThmCCStartupM1Max(pltt_cc,conf,p         )     startup thermal plant output maximum                                  [MW]
eGenThmCCStartupM1Min(pltt_cc,conf,p         )
eSingularityThrmCCM1UR(pltt_cc,p)

eOnOffM1UR(pltt_cc, conf,tstate, p, pp)
eOnOffM1DR(pltt_cc, conf, p, pp)

eGenTrmCCConfM1DR(pltt_cc,p)
eGenThmCCShutDwnM1Max(pltt_cc,conf,p        )     shutdown thermal plant output                                  [MW]
eGenThmCCShutDwnM1Min(pltt_cc,conf,p        ) 
eSingularityThrmCCM1DR(pltt_cc,p)

ePltUR_DR_SingularityCC(pltt_cc,conf,p )

eUpDownRatioPltCC  (pltt_cc,conf,p)
eUpDownRatioPltCICC  (pltt_cc,conf,p)

eUpDownSingularityCC(pltt_cc,conf, p)

eUniPltConfRelationCCComb(pltt_cc,p)
eUniPltConfRelationCCComb_M1(pltt_cc,p)
eUniPltConfRelationCCSteam(pltt_cc,p)
eUniPltConfRelationCCSteam_M1(pltt_cc,p)

eUniCombGTSteam(pltt_cc,p)



// Ramps constraints
eTotalThmOutPut(plt_t,p        )      total thermal plant output                  [MW]

// Cicle Simple constraints
eThmCSDispGen(pltt_cs,p)               avaliability of CS thermal plants
eThmCSDispGenConf(pltt_cs,p)               avaliability of CS thermal plants
eThmCSMinGen(pltt_cs,p)                minimum of CS thermal plants

eGenThmCSStartupM1Max (pltt_cs,p         )     startup thermal plant output maximum                                  [MW]
eGenThmCSStartupM1Min (pltt_cs,p         ) 
eGenThmCSShutDwnM1Max(pltt_cs,p         )     shutdown thermal plant output                                  [MW]
eGenThmCSShutDwnM1Min(pltt_cs,p         )

ePltUR_DR_Singularity(plt_t,p)

eUpDownRatioPlt  (plt_t, p        ) 
eUpDownRatioPltCI  (plt_t, p        ) 

eUpDownSingularityThmPlt(plt_t, p)

eUniPltConfRelationCS(pltt_cs,p)

eStartupThmPltUniHotMax(plt_t,p )          hot startup of thermal plant when unit is hot max value
eStartupThmPltUniWarmMax(plt_t,p )          warm startup of thermal plant when unit is warm max value
eStartupThmPltUniColdMax(plt_t,p )          cold startup of thermal plant when unit is cold max value
eStartupThmPltUniHotMin(plt_t,p )          hot startup of thermal plant when unit is hot min value
eStartupThmPltUniWarmMin(plt_t,p )          warm startup of thermal plant when unit is warm min value
eStartupThmPltUniColdMin(plt_t,p )          cold startup of thermal plant when unit is cold min value


eStartupOnOffThmPltCold(plt_t,p)          Cold state Relation between StartUp and OnOff of thermal plants
eStartupOnOffThmPltWarm(plt_t,p)          Warm state Relation between StartUp and OnOff of thermal plants
eStartupOnOffThmPltHot(plt_t,p)           Hot state Relation between StartUp and OnOff of thermal plants

eStartupThmPlt(plt_t,p )                startup of thermal plant relation with thermal state

eStartupCCThmPlt(pltt_cc,p )                startup of CC thermal plant relation with thermal state
eStartupCCThmPltConf(pltt_cc,conf,p )
eStartupCCThmPltCold(pltt_cc,p )
eStartupCCThmPltWarm(pltt_cc,p )
eStartupCCThmPltHot(pltt_cc,p )

eShutdownCCThmPlt(pltt_cc,p)                shutdown of thermal plant relation
eShutdownCCThmPltConf(pltt_cc,conf,p)                shutdown of thermal plant relation



*Model 1 Equations
eCSThmPltUpRamps (pltt_cs,p)            Warm start up ramps of CS thermal plants                           [MW]

eCCThmPltUpRamps (pltt_cc,p)            Warm start up ramps of CC thermal plants                           [MW]

eCSThmPltDRRamps (pltt_cs,p)            Warm start up ramps of CS thermal plants                           [MW]
eCCThmPltDRRamps (pltt_cc,p)            Warm start up ramps of CS thermal plants                           [MW]


* Up ramp - model 2 CS thermal plants
eUpRampMod21CS   (pltt_cs,p)     Up ramp model 2 for t > 1                        [MW]
eUpRampMod22CS   (pltt_cs,p)     Up ramp model 2 for t > 1                        [MW]
eUpRampMod23CS   (pltt_cs,p)     Up ramp model 2 for t > 1                        [MW]
eUpRampMod24CS   (pltt_cs,p)     Up ramp model 2 for t > 1                        [MW]
eUpRampMod25CS   (pltt_cs,p)     Up ramp model 2 for t > 1                        [MW]

* Up ramp - model 2 CS thermal plants initial condition
eUpRampMod21CS_CI   (pltt_cs,p)     Up ramp model 2 for t = 1                        [MW]
eUpRampMod22CS_CI   (pltt_cs)     Up ramp model 2 for t = 1                        [MW]
eUpRampMod23CS_CI   (pltt_cs)     Up ramp model 2 for t = 1                        [MW]
eUpRampMod24CS_CI   (pltt_cs,p)     Up ramp model 2 for t = 1                        [MW]
eUpRampMod25CS_CI   (pltt_cs,p)     Up ramp model 2 for t = 1                        [MW]

* Up ramp - model 2 CC thermal plants
eUpRampMod21CC   (pltt_cc,p)     Up ramp model 2 for t > 1                        [MW]
eUpRampMod22CC   (pltt_cc,p)     Up ramp model 2 for t > 1                        [MW]
eUpRampMod23CC   (pltt_cc,conf,p)     Up ramp model 2 for t > 1                        [MW]
eUpRampMod24CC   (pltt_cc,p)     Up ramp model 2 for t > 1                        [MW]
eUpRampMod25CC   (pltt_cc,p)     Up ramp model 2 for t > 1                        [MW]

* Up ramp - model 2 CC thermal plants initial condition
eUpRampMod21CC_CI   (pltt_cc,p)     Up ramp model 2 for t = 1                        [MW]
eUpRampMod22CC_CI   (pltt_cc)     Up ramp model 2 for t = 1                        [MW]
eUpRampMod23CC_CI   (pltt_cc,conf)     Up ramp model 2 for t = 1                        [MW]
eUpRampMod24CC_CI   (pltt_cc,p)     Up ramp model 2 for t = 1                        [MW]
eUpRampMod25CC_CI   (pltt_cc,p)     Up ramp model 2 for t = 1                        [MW]


* Down ramp - model 2 CS thermal plants
eDwnRampMod21CS  (pltt_cs,p)     Up ramp model 2 for t > 1                        [MW]
eDwnRampMod22CS  (pltt_cs,p)     Up ramp model 2 for t > 1                        [MW]
eDwnRampMod23CS  (pltt_cs,p)     Up ramp model 2 for t > 1                        [MW]
eDwnRampMod24CS  (pltt_cs,p)     Up ramp model 2 for t > 1                        [MW]
eDwnRampMod25CS  (pltt_cs,p)     Up ramp model 2 for t > 1                        [MW]

* Down ramp - model 2 CS thermal plants initial condition
eDwnRampMod21CS_CI  (pltt_cs,p)     Up ramp model 2 for t = 1                        [MW]
eDwnRampMod22CS_CI  (pltt_cs,p)     Up ramp model 2 for t = 1                        [MW]
eDwnRampMod23CS_CI  (pltt_cs,p)     Up ramp model 2 for t = 1                        [MW]
eDwnRampMod24CS_CI  (pltt_cs,p)     Up ramp model 2 for t = 1                        [MW]
eDwnRampMod25CS_CI  (pltt_cs,p)     Up ramp model 2 for t = 1                        [MW]

* Down ramp - model 2 CC thermal plants
eDwnRampMod21CC  (pltt_cc,p)     Up ramp model 2 for t > 1                        [MW]
eDwnRampMod22CC  (pltt_cc,p)     Up ramp model 2 for t > 1                        [MW]
eDwnRampMod23CC  (pltt_cc,conf,p)     Up ramp model 2 for t > 1                        [MW]
eDwnRampMod24CC  (pltt_cc,p)     Up ramp model 2 for t > 1                        [MW]
eDwnRampMod25CC  (pltt_cc,p)     Up ramp model 2 for t > 1                        [MW]

eDwnRampMod21CC_CI  (pltt_cc,p)     Up ramp model 2 for t = 1                        [MW]
eDwnRampMod22CC_CI  (pltt_cc,p)     Up ramp model 2 for t = 1                        [MW]
eDwnRampMod23CC_CI  (pltt_cc,conf,p)     Up ramp model 2 for t = 1                        [MW]
eDwnRampMod24CC_CI  (pltt_cc,p)     Up ramp model 2 for t = 1                        [MW]
eDwnRampMod25CC_CI  (pltt_cc,p)     Up ramp model 2 for t = 1                        [MW]


* Down ramp - model 3 CS thermal plants
eUpRampMod31CS   (pltt_cs,p,l,l,conf)     Up ramp model 3 for t > 1                        [MW]
eUpRampMod32CS   (pltt_cs,p,l,l,conf)     Up ramp model 3 for t = 1                        [MW]
eDwnRampMod31CS  (pltt_cs,p,l,l,conf)     Up ramp model 3 for t > 1                        [MW]
eDwnRampMod32CS  (pltt_cs,p,l,l,conf)     Up ramp model 3 for t = 1                        [MW]

eStartTrmPltCCAllowed(pltt_cc,conf,p)
eShutdownTrmPltCCAllowed(pltt_cc,conf,p)

* Therma CC Transition
* eFeasibleTransitionCC(pltt_cc,conf,p)

eTransitionAllowed(pltt_cc, conf, conf, p)   Allowed transitions
eConfigurationConsistency(pltt_cc, conf, p)  Configuration consistency
eExclusionTransition(pltt_cc,p)

eConfigurationConsistencyCI(pltt_cc, conf, p)

eTULT(pltt_cc, conf, confAux, tstate,uni_t, fuel, p, pp)

eMinUnitZones(zn,p)
eMinMWZones(zn,p)
eMaxMWZones(zn,p)

eMinMWZonesDay(zn)

eAreaImportLimit(ar,p)

eMinGenPlt(plt,p)

eMaxGenPlt(plt,p)

eMOGenPlt(plt,p)

eDispCOM(plt,p)

eEqMT1CS(pltt_cs,p)
eEqMT2CS(pltt_cs,p)
eEqMT3CS(pltt_cs,p)

eEqMT1CS_CI(pltt_cs)
eEqMT2CS_CI(pltt_cs)
eEqMT3CS_CI(pltt_cs)

eEqMT1CC(pltt_cc,conf,p)
eEqMT2CC(pltt_cc,conf,p)
eEqMT3CC(pltt_cc,conf,p)

eMTCC(pltt_cc,p)

eMenvCommitDn(plt_t,p)
eMenvMTDn(plt_t,p)
eDownMTDn(plt_t,p)

eMenvCommitDn_CI(plt_t,p)
eMenvMTDn_CI(plt_t)
eDownMTDn_CI(plt_t,p)




eMenvCommitUp(plt_t,p)
eMenvMTUp(plt_t,p)
eDownMTUp(plt_t,p)

eMenvCommitUp_CI(plt_t)
eMenvMTUp_CI(plt_t,p)
eDownMTUp_CI(plt_t,p)

eConfigPltCC(pltt_cc,p)
eConfigPltCS(pltt_cs,p)

eConf3F4(pltt_cc,conf,p)

eConf2F4(pltt_cc,conf,p)


eCI_PltTermNoM2_P_1_eq0(plt_t,p)  Restrcción para que no la encienda en modelo 2 si está apagada en le periodo p-1
// Ecuaciones de red

*eBranchFlow(Br,p)


EqAux(p);




;


$ONTEXT
*   eOpReserve      (p,z            )    operating reserve                                [MW]
   eWtReserve      (p,e            )    water reserve                                    [hm3]
   eInertia        (p              )    Inertia requirement                              [sec]
   eWtReserveTarget(p,e            )    Reserve target at the end of the horizont        [hm3]
   eMinSysReserve  (p              )    Minimum system reserve required                  [p.u.]



   eUpRampMod21t0 (p,    g        )     Up ramp model 2 for t = 1                        [MW]
   eUpRampMod22t0 (      g,   r   )     Up ramp model 2 for t = 1                        [MW]
   eUpRampMod23t0 (      g        )     Up ramp model 2 for t = 1                        [MW]
   eUpRampMod24t0 (p,    g,   r   )     Up ramp model 2 for t = 1                        [MW]
   eUpRampMod25t0 (p,    g,   r   )     Up ramp model 2 for t = 1                        [MW]






   eDwnRampMod21t0(p,    g        )     Up ramp model 2 for t = 1                        [MW]
   eDwnRampMod22t0(p,    g        )     Up ramp model 2 for t = 1                        [MW]
   eDwnRampMod23t0(      g        )     Up ramp model 2 for t = 1                        [MW]
   eDwnRampMod24t0(      g        )     Up ramp model 2 for t = 1                        [MW]
   eDwnRampMod25t0(p,    g        )     Up ramp model 2 for t = 1                        [MW]
   eDwnRampMod26t0(p,    g        )     Up ramp model 2 for t = 1                        [MW]

$OFFTEXT

