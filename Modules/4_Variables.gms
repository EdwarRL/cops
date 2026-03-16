$EOLCOM //


variables
   vTotalCost                          Total system operation cost                      [USD]
;

positive variables
vGenUni    (uni,p        )    unit generation output                  [MW]
vGenPlt    (plt,p        )    plant generation output                  [MW]

vGenThermalPltConfCC  (pltt_cc,conf,p           )  CC thermal plant generation output                  [MW]
vGenThermalPltCS  (pltt_cs,p           )  CS thermal plant generation output                  [MW]

vGenThmCCConfM2(pltt_cc,conf,p)                CC thermal plant generation output per configuration in model 2
vGenThmCCConfM1UR(pltt_cc,conf,p)                CC thermal plant generation output per configuration in model 1 UR
vGenThmCCConfM1DR(pltt_cc,conf,p)                CC thermal plant generation output per configuration in model 1 DR



vGenHydroPlt    (plt_h,p           )  hydro plant generation output                  [MW]
vGenVarPlt    (plt_v,p           )  Variable plant generation output                  [MW]

*vPrueba(pltt_cc,p)

vENS            (p,sba)    energy non served                                [MW]
*vENS            (p)

vGenTrmPltM2    (plt_t,p         )    thermal generation output                        [MW]
vGenTrmPltURM1 (plt_t,p         )    thermal startup ramp output                      [MW]
vGenTrmPltDRM1(plt_t,p        )    thermal shut down ramp output                    [MW]

vGenUniM2    (uni_t,p        )    unit generation output                  [MW]
vGenUniURM1    (uni_t,p        )    unit generation output                  [MW]
vGenUniDRM1    (uni_t,p        )    unit generation output                  [MW]

vDeltaU         (plt_t,    p        )    increase of power output between periods         [MW]
vDeltaD         (plt_t,    p       )    decrease of power output between periods         [MW]

vDeltaU_CI(plt_t)
vDeltaD_CI(plt_t)

vTransitionCC(pltt_cc,conf,conf,p)
;

integer variables
vCommitTrmConf(plt_t,p) Configuración para cada planta térmica y cada periodo
;
*vBranchFlow(Br,p)

$ONTEXT


   vDeltaU0        (      g        )    increase of power output from t0 to t1           [MW]

   vDeltaR0        (      g        )    decrease of power output from t0 to t1           [MW]



   vWtReserve      (p,e            )    water reserve at end of period                   [hm3]
   vSpillage       (p,e            )    spillage                                         [hm3]
   vSlackReserve   (p              )    Slack variable for the system reserve            [hm3]
$OFFTEXT

;

binary variables 

vCommitmentUni     (uni,p        )    commitment of the unit                           [0-1]
vCommitmentUniFuel     (uni_t,fuel,p        )    commitment of the unit                           [0-1]

vCommitmentUniMC(uni_t,p)

vStartUpUni        (uni_t,p        )    startup    of the thermal unit                           [0-1]
vShutDownUni       (uni_t,p         )    shutdown   of the thermal unit                           [0-1]

vStartUpUniMC        (uni_t,p        )    startup    of the thermal unit                           [0-1]
vShutDownUniMC       (uni_t,p         )    shutdown   of the thermal unit                           [0-1]

vStartUpUniFuel    (uni_t,fuel,p)       startup of the thermal unit on a fuel
vStartUpUniFuelTE  (uni_t,fuel,tstate,p)       startup of the thermal unit on a fuel and thermal state

vStartUpUniFuelMC (uni_t,fuel,p)       startup of the thermal unit on a fuel when generation greater than zero

vShutDownUniFuel    (uni_t,fuel,p)       Shutdown of the thermal unit on a fuel
vShutDownUniFuelMC    (uni_t,fuel,p)       Shutdown of the thermal unit on a fuel

vStartUpThmPlt        (plt_t,p        )            startup    of the thermal plant                           [0-1]
vShutDownThmPlt        (plt_t,p        )            startup    of the thermal plant                           [0-1]
vStartUpThmPltTE        (plt_t,tstate,p        )   startup    of the thermal plant per thermal state
vOnOffThmPltTE        (plt_t,tstate,p)     on-off of the thermal plant per thermal state

vCommitTrmPlt(plt_t,p)                 commitment of the thermal plant
vCommitTrmPltM1UR(plt_t,p)
vCommitTrmPltM1DR(plt_t,p)

vCommitTrmPltMC(plt_t,p)
vStartUpThmPltMC        (plt_t,p        )            startup    of the thermal plant                           [0-1]
vShutDownThmPltMC        (plt_t,p        )            startup    of the thermal plant     

vCommitTrmCC(pltt_cc,conf,p)           commitment of the thermal plant per configuration
vCommitTrmPltCCM1UR(pltt_cc,conf,p)
vCommitTrmPltCCM1DR(pltt_cc,conf,p)
vStartUpThmPltCC(plt_t,conf,p )
vShutDownThmPltCC(plt_t,conf,p)

vStartUpThmPltCCTE(pltt_cc,conf,tstate,p )
vShutDownThmPltCCM1(pltt_cc,conf,p)




vbUR             (pltt_cs,r,p)    up ramp status                                   [0-1]
vbDR             (pltt_cs,r,p)    down ramp status                                 [0-1]
vbUR_CI(pltt_cs,r)
vbDR_CI(pltt_cs,r)

vbURCC             (pltt_cc,conf,r,p)    up ramp status                                   [0-1]
vbDRCC             (pltt_cc,conf,r,p)    down ramp status                                 [0-1]
vbURCC_CI             (pltt_cc,conf,r)
vbDRCC_CI             (pltt_cc,conf,r)

vbMT(plt_t,p)
vbMTCC(pltt_cc,conf,p)
vbDownMT (plt_t,p)
vbDownMT_CI(plt_t)

vbMT_CI(plt_t)
vbUpMT (plt_t,p)
vbUpMT_CI(plt_t)





;
$ONTEXT

   vUR0            (      g,    r  )    up ramp status at t0                             [0-1]

   vDR0            (      g,    r  )    down ramp status at t0                           [0-1]

   vud             (p,    g        )    shutdown status                                  [0-1]

$OFFTEXT
