model cops / all / ;
*cops.SolPrint = 1 ; cops.HoldFixed = 1 ;

cops.optfile =1; 


* solve hydrothermal unit commitment model
solve cops using mip minimizing vTotalCost;




