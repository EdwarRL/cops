$title Colombian Power System Optimization Model (COPS)
$ontext
The purpose of this model is to represent the Colombian power system in a
mathematical optimization model in order to evaluate the realiability and the
resilence with the integration of renewable energy resources to the system.

Developed by
  Mauro Gonzalez
  maurogzsa@gmail.com

  Edwar Ramírez
  alejandro23788@gmail.com

$offtext

*-------------------------------------------------------------------------------
*                                 Options
*-------------------------------------------------------------------------------


* optimizer definition
option  lp   = cplex  ;
option  mip   = cplex ;
option rmip   = cplex ;
option rmiqcp = cplex ;
option  miqcp = cplex ;


option limrow=1000000;
option limcol=1000000;
option solprint=on;
option sysout=on;
option optcr =  1E-4;
option profile=1;

* Tiempo de ejecución
option reslim   =  1;

* option reslim   =  1;

*option profileTol = 0.01 ;

* option timing = 1;


