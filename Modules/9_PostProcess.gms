* data output to xls file


pProductUni(uni,p) = vGenUni.l(uni,p) + eps;
pProductPlt(plt,p) = vGenPlt.l(plt,p) + eps;
pCommitTrmConf(plt_t,p) = vCommitTrmConf.l(plt_t,p) + eps;
pCommitmentUni(uni,p) = vCommitmentUni.l (uni,p) + eps;

pGenTrmPltM2(plt_t,p) = vGenTrmPltM2.l(plt_t,p)     + eps;
pGenTrmPltURM1(plt_t,p) = vGenTrmPltURM1.l(plt_t,p) + eps;
pGenTrmPltDRM1(plt_t,p) = vGenTrmPltDRM1.l(plt_t,p) + eps;


pMarginal(p)=eBalance.m(p);

* pENS(p) = vENS.l(p) + eps;

* parameter
* CostoMarginal(p)
* CosMar_Z_EcuTer(p)
* ;

* CostoMarginal(p)=eBalance.m(p);

* CosMar_Z_EcuTer(p)=eMinMWZones.m('Z_EcuTer',p);


* put logFile 'Generation model time:' cops.resGen /;

* put logFile 'Solution model time:' cops.resUsd /;

* * Close the log file
* putclose logFile;

*pReserve(p,e) =   vWtReserve.l(p,e) + eps;

*display pProductUni, pCommitUni, pProductPlt, pENS, vTotalCost.l, vGenThermalPltCS.l, vGenThermalPltCC.l, pThermalCCVarCost;
