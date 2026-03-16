$title Configuration Based CCGT Model

option   lp     = cplex ;
option  mip     = cplex ;
option rmip     = cplex ;
option limrow   = 100;
option limcol   = 100;
option solprint = on;
option sysout   = on;

set

p periods /p1*p24/
u generation units /u1*u4/
g generators /g1*g2/
c configuration /c1*c5/
ts thermal state /cold, warm, hot/

unig(g,u) "units belogn to generator" /g1 . u1
                                       g1 . u2
                                       g1 . u3
                                       g2 . u4 /

ccgt(g,c) "generator configurations"  /g1 . c1
                                       g1 . c2
                                       g1 . c3
                                       g1 . c4
                                       g1 . c5
                                       g2 . c1
                                       g2 . c2/

;

Alias (c,cc), (p,j)
;


Parameters

pM         "Up limit"                  /9999/

pDemand(p) "energy demand by period p" /p1  400
                                        p2  400
                                        p3  330
                                        p4  280
                                        p5  300
                                        p6  280
                                        p7  290
                                        p8  280
                                        p9  340
                                        p10 380
                                        p11 400
                                        p12 460
                                        p13 500
                                        p14 520
                                        p15 500
                                        p16 480
                                        p17 440
                                        p18 480
                                        p19 550
                                        p20 600
                                        p21 620
                                        p22 600
                                        p23 580
                                        p24 550/


pTCC(g) "define if the thermal plant is a combined cicle  [0-1]" /g1 1
                                                                  g2 0/


pVariableCost(g,c) "Marginal Production Cost" / g1 . c1 100
                                                g1 . c2 100
                                                g1 . c3 100
                                                g1 . c4 100
                                                g1 . c5 100
                                                g2 . c1 500
                                                g2 . c2 500/


pMaxCapacityByConfig(g,c) "capacity by configuration" /g1 . c1 0
                                                       g1 . c2 179
                                                       g1 . c3 358
                                                       g1 . c4 260
                                                       g1 . c5 555
                                                       g2 . c1 0
                                                       g2 . c2 200/

pMinCapacityByConfig(g,c) "minimum by configuration" / g1 . c1 0
                                                       g1 . c2 125
                                                       g1 . c3 250
                                                       g1 . c4 176
                                                       g1 . c5 330
                                                       g2 . c1 0
                                                       g2 . c2 10/


pF(g,c,c) "Feasible transition by generator" / g1 . c1 . c1  0
                                               g1 . c1 . c2  1
                                               g1 . c1 . c3  1
                                               g1 . c1 . c4  1
                                               g1 . c1 . c5  1
                                               g1 . c2 . c1  1
                                               g1 . c2 . c2  0
                                               g1 . c2 . c3  1
                                               g1 . c2 . c4  1
                                               g1 . c2 . c5  0
                                               g1 . c3 . c1  1
                                               g1 . c3 . c2  1 
                                               g1 . c3 . c3  0
                                               g1 . c3 . c4  0
                                               g1 . c3 . c5  1
                                               g1 . c4 . c1  1
                                               g1 . c4 . c2  1
                                               g1 . c4 . c3  0
                                               g1 . c4 . c4  0
                                               g1 . c4 . c5  1
                                               g1 . c5 . c1  0
                                               g1 . c5 . c2  0
                                               g1 . c5 . c3  1
                                               g1 . c5 . c4  1
                                               g1 . c5 . c5  0
                                               g2 . c1 . c1  0
                                               g2 . c1 . c2  1
                                               g2 . c2 . c1  1
                                               g2 . c2 . c2  0/                                                  

pConfigT0(g,c) "Configuration at t0" /g1 . c1 1
                                      g1 . c2 0
                                      g1 . c3 0
                                      g1 . c4 0
                                      g1 . c5 0
                                      g2 . c1 1
                                      g2 . c2 0/
                                                

pUnitStatust0(g,u) "units status at t0" /g1 . u1 0
                                         g1 . u2 0
                                         g1 . u3 0
                                         g2 . u4 0/

pOnTimeByConfigt0(g,c) "Number of hours the configuration has been online at t0" /g1 . c1 0
                                                                                  g1 . c2 0
                                                                                  g1 . c3 0
                                                                                  g1 . c4 0
                                                                                  g1 . c5 0
                                                                                  g2 . c1 0
                                                                                  g2 . c2 0/
;


Table tI(g,c,u) "units by configuration of each generator"
           
         u1 u2 u3 u4
g1 . c1   0  0  0  0
g1 . c2   1  0  0  0 
g1 . c3   1  1  0  0
g1 . c4   1  0  1  0
g1 . c5   1  1  1  0
g2 . c1   0  0  0  0
g2 . c2   0  0  0  1
;

Table tSU(g,c,c,u) "startup for upward transition"

             u1 u2 u3 u4
g1 . c1 . c1  0  0  0  0
g1 . c1 . c2  1  0  0  0
g1 . c1 . c3  1  1  0  0
g1 . c1 . c4  1  0  1  0
g1 . c1 . c5  1  1  1  0
g1 . c2 . c1  0  0  0  0
g1 . c2 . c2  0  0  0  0
g1 . c2 . c3  0  1  0  0
g1 . c2 . c4  0  0  1  0
g1 . c2 . c5  0  0  0  0
g1 . c3 . c1  0  0  0  0
g1 . c3 . c2  0  0  0  0
g1 . c3 . c3  0  0  0  0
g1 . c3 . c4  0  0  0  0
g1 . c3 . c5  0  0  1  0
g1 . c4 . c1  0  0  0  0
g1 . c4 . c2  0  0  0  0
g1 . c4 . c3  0  0  0  0
g1 . c4 . c4  0  0  0  0
g1 . c4 . c5  0  1  0  0
g1 . c5 . c1  0  0  0  0
g1 . c5 . c2  0  0  0  0
g1 . c5 . c3  0  0  0  0
g1 . c5 . c4  0  0  0  0
g1 . c5 . c5  0  0  0  0
g2 . c1 . c1  0  0  0  0
g2 . c1 . c2  0  0  0  1
g2 . c2 . c1  0  0  0  0
g2 . c2 . c2  0  0  0  0
;

Table tSD(g,c,c,u) "Shutdown for doward transition"

             u1 u2 u3 u4
g1 . c1 . c1  0  0  0  0
g1 . c1 . c2  0  0  0  0
g1 . c1 . c3  0  0  0  0  
g1 . c1 . c4  0  0  0  0 
g1 . c1 . c5  0  0  0  0
g1 . c2 . c1  1  0  0  0
g1 . c2 . c2  0  0  0  0
g1 . c2 . c3  0  0  0  0
g1 . c2 . c4  0  0  0  0
g1 . c2 . c5  0  0  0  0
g1 . c3 . c1  1  1  0  0
g1 . c3 . c2  0  1  0  0
g1 . c3 . c3  0  0  0  0
g1 . c3 . c4  0  0  0  0
g1 . c3 . c5  0  0  0  0
g1 . c4 . c1  1  0  1  0
g1 . c4 . c2  0  0  1  0
g1 . c4 . c3  0  0  0  0
g1 . c4 . c4  0  0  0  0
g1 . c4 . c5  0  0  0  0
g1 . c5 . c1  0  0  0  0
g1 . c5 . c2  0  0  0  0
g1 . c5 . c3  0  0  1  0
g1 . c5 . c4  0  1  0  0
g1 . c5 . c5  0  0  0  0
g2 . c1 . c1  0  0  0  0
g2 . c1 . c2  0  0  0  0
g2 . c2 . c1  0  0  0  1
g2 . c2 . c2  0  0  0  0
;

Table tHeatingTime(g,u,ts) "Heating time per unit"
        
        cold warm  hot
g1 . u1    3    2    1
g1 . u2    3    2    1
g1 . u3    3    2    1
g2 . u4    1    1    1
;

Table tTULT(g,c,c,ts) "Time for transition between configurations"

             cold warm  hot
g1 . c1 . c1    0    0    0
g1 . c1 . c2    3    2    2
g1 . c1 . c3    3    2    2  
g1 . c1 . c4    5    3    2 
g1 . c1 . c5    5    4    3
g1 . c2 . c1    1    1    1
g1 . c2 . c2    0    0    0
g1 . c2 . c3    2    2    2
g1 . c2 . c4    4    2    2
g1 . c2 . c5    0    0    0
g1 . c3 . c1    1    1    1
g1 . c3 . c2    1    1    1
g1 . c3 . c3    0    0    0
g1 . c3 . c4    0    0    0
g1 . c3 . c5    4    3    2
g1 . c4 . c1    1    1    1
g1 . c4 . c2    1    1    1
g1 . c4 . c3    0    0    0
g1 . c4 . c4    0    0    0
g1 . c4 . c5    3    2    2
g1 . c5 . c1    0    0    0
g1 . c5 . c2    0    0    0
g1 . c5 . c3    4    4    4
g1 . c5 . c4    4    4    4
g1 . c5 . c5    0    0    0
g2 . c1 . c1    0    0    0
g2 . c1 . c2    0    0    0
g2 . c2 . c1    0    0    0
g2 . c2 . c2    0    0    0
;


Variables
z
;

positive variables
vGenOut(g,c,p)
;

Binary Variables
vConfiguration(g,c,p)
vTransition(g,c,c,p)
vUnitStatus(g,u,p)
vStartUpStatus(g,u,p)
vShutDownStatus(g,u,p)
vTULT(g,c,c,ts,p)
;

Equations
obj
eSN_BalanceP(p)
eConfigExclusion(p,g)
eConfigCap(g,c,p)
eConfigMin(g,c,p)
eFeasibleTransitiont0(g,c,p)
eFeasibleTransition(g,c,p)
eConfigurationTransitiont0(g,u,p)
eConfigurationTransition(g,u,p)
eExclusionTransition(g,p)
eUnitStatus(g,u,p)
eStartUpShutDownLogict0(g,u,p)
eStartUpShutDownLogic(g,u,p)
*eThermalTransitionExclusion(g,c,c,p)
*eTULTHot(g,c,c,ts,p)
*eTULTWarm(g,c,c,ts,p)
*eTULTCold(g,c,c,ts,p)
;


obj.. z =e= sum((g,c,p)$[ccgt(g,c)], pVariableCost(g,c) * vGenOut(g,c,p));

eSN_BalanceP(p)..
sum((g,c)$[ccgt(g,c)], vGenOut(g,c,p)) =e= pDemand(p)
;

eConfigExclusion(p,g)..
sum(c,vConfiguration(g,c,p)) =e= 1 
;

eConfigCap(g,c,p)..
vGenOut(g,c,p) =l= pMaxCapacityByConfig(g,c)*vConfiguration(g,c,p)
;

eConfigMin(g,c,p)..
vGenOut(g,c,p) =g= pMinCapacityByConfig(g,c)*vConfiguration(g,c,p)
;

eFeasibleTransitiont0(g,c,p)$[ord(p) eq 1 and pTCC(g) eq 1]..
vConfiguration(g,c,p) - pConfigT0(g,c) =e=
sum((cc)$[ord(c) <> ord(cc) and pF(g,cc,c) eq 1], vTransition(g,cc,c,p)) - sum((cc)$[ord(c) <> ord(cc) and pF(g,c,cc) eq 1], vTransition(g,c,cc,p))
;

eFeasibleTransition(g,c,p)$[ord(p) gt 1 and pTCC(g) eq 1]..
vConfiguration(g,c,p) - vConfiguration(g,c,p-1) =e=
sum((cc)$[ord(c) <> ord(cc) and pF(g,cc,c) eq 1], vTransition(g,cc,c,p)) - sum((cc)$[ord(c) <> ord(cc) and pF(g,c,cc) eq 1], vTransition(g,c,cc,p))
;

eConfigurationTransitiont0(g,u,p)$[ord(p) eq 1 and pTCC(g) eq 1] ..
sum(c$[tI(g,c,u)], vConfiguration(g,c,p)) - sum(c$[tI(g,c,u)], pConfigT0(g,c))
=e= sum((c,cc)$[ord(c) <> ord(cc) and tSU(g,c,cc,u) eq 1], vTransition(g,c,cc,p)) - sum((c,cc)$[ord(c) <> ord(cc) and tSD(g,c,cc,u) eq 1], vTransition(g,c,cc,p))
;

eConfigurationTransition(g,u,p)$[ord(p) gt 1 and pTCC(g) eq 1] ..
sum(c$[tI(g,c,u)], vConfiguration(g,c,p)) - sum(c$[tI(g,c,u)], vConfiguration(g,c,p-1))
=e= sum((c,cc)$[ord(c) <> ord(cc) and tSU(g,c,cc,u) eq 1], vTransition(g,c,cc,p)) - sum((c,cc)$[ord(c) <> ord(cc) and tSD(g,c,cc,u) eq 1], vTransition(g,c,cc,p))
;

eExclusionTransition(g,p)..
sum((c,cc)$[ord(c) <> ord(cc) and pF(g,c,cc) eq 1], vTransition(g,c,cc,p)) =l= 1
;

eUnitStatus(g,u,p)$[unig(g,u)]..
vUnitStatus(g,u,p) =e= sum(c$[tI(g,c,u)], vConfiguration(g,c,p))
;

eStartUpShutDownLogict0(g,u,p)$[ord(p) eq 1 and unig(g,u)]..
vUnitStatus(g,u,p) - pUnitStatust0(g,u) =e= vStartUpStatus(g,u,p) - vShutDownStatus(g,u,p)
;

eStartUpShutDownLogic(g,u,p)$[ord(p) gt 1 and unig(g,u)]..
vUnitStatus(g,u,p) - vUnitStatus(g,u,p-1) =e= vStartUpStatus(g,u,p) - vShutDownStatus(g,u,p)
;

*eThermalTransitionExclusion(g,c,cc,p)$[pF(g,c,cc) and pTCC(g) eq 1]..
*vTransition(g,c,cc,p) =e= sum(ts, vTULT(g,c,cc,ts,p))
*;

*eTULTHot(g,c,cc,'hot',p)$[pF(g,c,cc) and pTCC(g) eq 1 and ord(p) gt tTULT(g,c,cc,'hot')]..
*vTULT(g,c,cc,'hot',p) =l= pOnTimeByConfigt0(g,c) + sum((j)$[ord(j) ge ord(p) - tTULT(g,c,cc,'hot') and ord(j) le ord(p) - 1], vConfiguration(g,cc,p));

*eTULTWarm(g,c,cc,'warm',p)$[pF(g,c,cc) and pTCC(g) eq 1 and ord(p) gt tTULT(g,c,cc,'warm')]..
*vTULT(g,c,cc,'warm',p) =l= pOnTimeByConfigt0(g,c) + sum((j)$[ord(j) ge ord(p) - tTULT(g,c,cc,'warm') and ord(j) le ord(p) - 1], vConfiguration(g,cc,p));

*eTULTCold(g,c,cc,'cold',p)$[pF(g,c,cc) and pTCC(g) eq 1 and ord(p) gt tTULT(g,c,cc,'cold')]..
*vTULT(g,c,cc,'cold',p) =l= pOnTimeByConfigt0(g,c) + sum((j)$[ord(j) ge ord(p) - tTULT(g,c,cc,'cold') and ord(j) le ord(p) - 1], vConfiguration(g,cc,p));

model cfbm / all / ;

* Set options to generate LP file
option solvelink = 5;

solve cfbm using MIP minimizing z;

* Command to write the LP file directly
execute 'gdxdump cfbm.gdx cplex=model.lp';


