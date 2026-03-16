file TMP / Modules\InputData\tmp_WriteFormat.txt /
put TMP putclose 'par=pProductUni rdim=1 rng=OutputUni!a1' / 'par=pCommitUni rdim=1 rng=UC!a1' / 'par=pProductPlt rdim=1 rng=OutputPlt!a1' /
                 'par=pENS rdim=1 rng=ENS!a1'  /
;

*execute          'gdxxrw Modules\OutputData\tmp_cops.gdx SQ=n EpsOut=0 O=Modules\OutputData\tmp_cops.xlsx @Modules\InputData\tmp_WriteFormat.txt'
*;

execute_unload   'Modules\OutputData\ResultsGAMS.gdx'  pProductUni pProductPlt pThermalCSVarCost pHydroVarCost pThermalCCVarCost pCommitTrmConf pCommitmentUni  
                                                       pThermalCSVarCost pHydroVarCost  pThermalCCVarCost pThmMaxprodUni uni_t uni_h uni_v sba plt_t plt_h pGenTrmPltM2
                                                       pGenTrmPltURM1  pGenTrmPltDRM1 pltt_cc pWeightUnitZone TypeMod_CI 
                                                       pMarginal pTMinProd pTrmPltMinConf pTrmCSMinConf pGenUniIni pGenPltiIni pTrmCSMaxConf pColdStartUpRampsThmPltConf pNumBlkColdThmPltConf
                                                       pPosRampCold
;

execute '=gdx2access  Modules\OutputData\ResultsGAMS.gdx'
;

*$else.OptSkipExcelOutput
*$  log Excel output skipped
*$endif.OptSkipExcelOutput
*execute          'del Modules\InputData\tmp_"%gams.user1%".txt'

$OnListing
