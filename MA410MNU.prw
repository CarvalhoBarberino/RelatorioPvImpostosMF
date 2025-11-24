#include 'protheus.ch'
#include 'parmtype.ch'
  
user function MA410MNU()
	aadd(aRotina,{'Rel.Pv c/Impostos','U_FTREL581(.T.)' , 0 , 1,0,NIL})
	aadd(aRotina,{'Rel.Pv s/Impostos','U_FTREL581(.F.)' , 0 , 1,0,NIL})
return
