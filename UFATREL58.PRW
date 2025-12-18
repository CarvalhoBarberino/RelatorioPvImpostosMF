#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDef.ch"
#include 'parmtype.ch'

#DEFINE IMP_SPOOL		2
#DEFINE IMP_PDF			6
#DEFINE SEM_SETUP		.T.
#DEFINE VIEW_PDF		.T.
#DEFINE NOME_DO_FONTE	"MA410MNU.PRW"
#DEFINE PAD_LEFT		0
#DEFINE PAD_RIGHT		1
#DEFINE PAD_CENTER_H	2
#DEFINE PAD_CENTER_V	0
#DEFINE PAD_TOP			1
#DEFINE PAD_BOTTOM		2

// Numeracao dentro do array aDadosIt
#DEFINE DA_C5_NUM				1
#DEFINE DA_C6_NFORI				2
#DEFINE DA_C6_SERIORI			3
#DEFINE DA_SB1_REC				4
#DEFINE DA_ITEM					5
#DEFINE DA_DESCON				6
#DEFINE DA_QUANT				7
#DEFINE DA_EMB					8
#DEFINE DA_UNIDADE				9
#DEFINE DA_CODIGO_FAMA			10
#DEFINE DA_B1_PESO				11
#DEFINE DA_C6_PRODUTO			12
#DEFINE DA_C6_TES				13
#DEFINE DA_DESCRICAO			14
#DEFINE DA_B1_GRUPO				15
#DEFINE DA_C6_VALDESC			16
#DEFINE DA_VALOR_UNI			17
#DEFINE DA_VALOR_TOTAL			18
#DEFINE DA_C5_FRETE				19
#DEFINE DA_IT_ALIQIPI			20
#DEFINE DA_IT_VALIPI			21
#DEFINE DA_IT_VALSOL			22
#DEFINE DA_VALOR_C_IMPOSTOS		23
#DEFINE DA_PESO_TOTAL			24
#DEFINE DA_GRUPO_COD			25
#DEFINE DA_GRUPO_DESCRI			26
#DEFINE DA_DESCONTOS			27
#DEFINE DA_C5_CONDPAG			28
#DEFINE DA_E4_DESCRI			29
#DEFINE DA_D_UMOLA				30
#DEFINE DA_COMIS1				31

user function MA410MNU()
	aadd(aRotina,{'Rel.Pv c/Impostos','U_FTREL581(.T.)' , 0 , 1,0,NIL})
	aadd(aRotina,{'Rel.Pv s/Impostos','U_FTREL581(.F.)' , 0 , 1,0,NIL})
return

user function jukTeste()
	local aDados		:= { ;
		{"0101", "molas", 15}, ;
		{"0101", "artefatos", 16}, ;
		{"0102", "molas", 17}, ;
		{"0102", "sucatas", 18}, ;
		{"0103", "aco", 40}, ;
		{"0103", "helicid", 35}, ;
		{"0103", "sucatas", 27} ;
		}
	local aFiliais
	local aGrupos
	local aTab			:= aPivot2D(aDados, 2, 1, 3)

	aFiliais := aSelByIndx(aDados, {1})
	aFiliais := aGroupBy(aFiliais, 1)
	aFiliais := aTranspose(aFiliais)
	aFiliais := aAppendCol({{" "}}, aFiliais)

	aGrupos := aSelByIndx(aDados, {2})
	aGrupos := aGroupBy(aGrupos, 1)

	aTab := aAppendCol(aGrupos, aTab)
	aTab := aAppendLin(aFiliais, aTab)
	showLog(VarInfo("aTab", aTab, , .F.))
return

user function FTREL583()
	local oPrinter
	local cArea				:= FWGetArea()
	local cAliasRes			:= "REL58RES"
	local cAliasCom			:= "REL58COM"
	local dIni				:= sToD("20240101")
	local dFim				:= sToD("20270101")
	local aDadosVal			:= {}
	local aDadosPes			:= {}
	local aItVal
	local aItPes
	local aTabVal
	local aTabPes
	local aTotFilVal
	local aTotFilPes
	local aTotGruVal
	local aTotGruPes
	local aTotVal
	local aTotPes
	local aValMed
	local aFiliais
	local aGrupos
	local cNomeDoArquivo	:= "ResumoVendas.pdf"
	local aMedidas
	local aAlinhamen
	local aMascara			:= {}
	local nI
	local nWidthFil
	local oArial18b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 18 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial11		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 11 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local aPergs		:= {}
	local aComisFret

	aAdd(aPergs, {1, "Data De",		dIni,	"", ".T.", "", ".T.", 80,	.F.})
	aAdd(aPergs, {1, "Data Até",	dFim,	"", ".T.", "", ".T.", 80,	.F.})
	If !ParamBox(aPergs, "Informe os parâmetros")
		msgAlert("Falha ao carregar parametros", NOME_DO_FONTE)
		FWRestArea(cArea)
		return
	else
		dIni := MV_PAR01
		dFim := MV_PAR02
	EndIf

	cQy := queryResum(dIni, dFim)
	if select(cAliasRes) > 0
		dbSelectArea(cAliasRes)
		(cAliasRes)->(dbCloseArea())
	endIf
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasRes, .F., .T.)
	dbSelectArea(cAliasRes)
	if (cAliasRes)->(eOF())
		MsgAlert("O intervalo entre datas não possui dados", NOME_DO_FONTE)
		FWRestArea(cArea)
		return
	endIf

	while !(cAliasRes)->(eOF())
		aItVal := {}
		aItPes := {}

		aAdd(aItVal, (cAliasRes)->NAME_FIL)
		aAdd(aItVal, (cAliasRes)->BM_DESC)
		aAdd(aItVal, (cAliasRes)->SUM_D2_TOT)

		aAdd(aItPes, (cAliasRes)->NAME_FIL)
		aAdd(aItPes, (cAliasRes)->BM_DESC)
		aAdd(aItPes, (cAliasRes)->SUM_PESO)

		aAdd(aDadosVal, aItVal)
		aAdd(aDadosPes, aItPes)

		(cAliasRes)->(dbSkip())
	endDo

	aFiliais := aAppendCol({{"VENDAS"}}, aTranspose(aGroupBy(aSelByIndx(aDadosVal, {1}), 1)))
	aGrupos := aGroupBy(aSelByIndx(aDadosVal, {2}), 1)
	aTabVal := aPivot2D(aDadosVal, 2, 1, 3)
	aTotFilVal := aGroupBy(aTabVal, 0)
	aTotGruVal := aTranspose(aGroupBy(aTranspose(aTabVal), 0))
	aTotVal := aGroupBy(aTotGruVal, 0)
	aTabVal := aAppendCol(aGrupos, aTabVal)
	aTabVal := aAppendLin(aFiliais, aTabVal)
	for nI := 1 to len(aTabVal[1])
		aAdd(aMascara, "@E 9,999,999.99")
	next
	aTabVal := aToStr(aTabVal, aMascara)
	aTabPes := aPivot2D(aDadosPes, 2, 1, 3)
	aTotFilPes := aGroupBy(aTabPes, 0)
	aTotGruPes := aTranspose(aGroupBy(aTranspose(aTabPes), 0))
	aValMed := {}
	for nI := 1 to len(aTotGruVal)
		aAdd(aValMed, {})
		aAdd(aValMed[nI], aTotGruVal[nI, 1] / aTotGruPes[nI, 1])
	next
	aTotPes := aGroupBy(aTotGruPes, 0)
	aTabPes := aAppendCol(aGrupos, aTabPes)
	aTabPes := aAppendLin(aFiliais, aTabPes)
	aTabPes[1, 1] := "PESOS"
	aTabPes := aToStr(aTabPes, aMascara)

	aMedidas := {100}
	aAlinhamen := {PAD_CENTER_H}
	nWidthFil := round((586 - 100) / (len(aTabVal[1]) - 1), 0) - 1
	for nI := 2 to len(aTabVal[1])
		aAdd(aMedidas, nWidthFil)
		aAdd(aAlinhamen, PAD_CENTER_H)
	next

	cQy := queryComis(dIni, dFim)
	if select(cAliasCom) > 0
		dbSelectArea(cAliasCom)
		(cAliasCom)->(dbCloseArea())
	endIf
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasCom, .F., .T.)
	dbSelectArea(cAliasCom)
	if (cAliasCom)->(eOF())
		MsgAlert("O intervalo entre datas não possui dados", NOME_DO_FONTE)
		FWRestArea(cArea)
		return
	endIf

	aComisFret := {{(cAliasCom)->SUM_COMIS1}, {(cAliasCom)->SUM_COMIS2}, {(cAliasCom)->SUM_FRETE}}

	// Inicio da parte gráfica
	oPrinter := FWMsPrinter():New(;
		cNomeDoArquivo /*cFilePrintert*/, ;
		IMP_PDF /*nDevice*/, ;
		.F. /*lAdjustToLegacy*/, ;
		/*cPathInServer*/, ;
		SEM_SETUP /*lDisabeSetup */, ;
		/*lTReport*/, ;
		@oPrinter /*@oPrintSetup*/, ;
		/*cPrinter*/, ;
		/*lServer*/, ;
		/*compatibilidade*/, ;
		/*lRaw*/, ;
		VIEW_PDF/*lViewPDF*/, ;
		/*nQtdCopy*/)
		oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(3,10,3,10) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:cPathPDF := "C:\TEMP\" // Caso seja utilizada impressï¿½o em IMP_SPOOL
	oPrinter:StartPage()

	cabFama(@oPrinter, 1/*nPagina*/, 1/*nPaginaTot*/)

	oPrinter:SayAlign(138, 4, "Relatório de Resumo de Vendas Mensal DFs", oArial18b, 586, 20, , PAD_CENTER_H, 2)
	oPrinter:SayAlign(138 + 18, 4, "Peridodo de: " + dToC(dIni) + " - Periodo até: " + dToC(dFim), oArial11, 586, 20, , PAD_CENTER_H, 2)

	printTab(190, 4, 15, aMedidas, aAlinhamen, /*aCampos*/, aTabVal, @oPrinter)
	printTab(190 + 15 * len(aTabVal), 4, 15, aMedidas, aAlinhamen, /*aCampos*/, aToStr(aAppendCol({{"TOTAL"}}, aTotFilVal), aMascara), @oPrinter)

	printTab(390, 4, 15, aMedidas, aAlinhamen, /*aCampos*/, aTabPes, @oPrinter)
	printTab(390 + 15 * len(aTabPes), 4, 15, aMedidas, aAlinhamen, /*aCampos*/, aToStr(aAppendCol({{"TOTAL"}}, aTotFilPes), aMascara), @oPrinter)

	printTab(590, 4, 15, {146, 147, 146, 147}, {PAD_CENTER_H, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}, /*aCampos*/, aToStr(aAppendCol(aAppendCol(aAppendCol(aGrupos, aTotGruVal), aTotGruPes), aValMed), {"", "@E 9,999,999.99", "@E 9,999,999.99", "@E 9,999,999.99"}), @oPrinter)

		/*
	comissao + frete.
	comissão vem do SD2 e frete vem do SF2. Isso vai dar problema
	*/
	// comissao + frete printTab(790, 4, 15, {140, 70}, {PAD_CENTER_H, PAD_CENTER_H}, /*aCampos*/, aTabPes, @oPrinter)

	printTab(790, 332, 15, {140, 70}, {PAD_CENTER_H, PAD_CENTER_H}, /*aCampos*/, aToStr(aAppendCol({{"TOTAL GERAL VENDAS"}, {"TOTAL GERAL PESO"}}, aAppendLin(aTotGruVal, aTotGruPes)), {"", "@E 9,999,999.99"}), @oPrinter)


	oPrinter:EndPage()
	oPrinter:Setup()
	oPrinter:Preview()
	FreeObj(oPrinter)
	oPrinter := Nil
	FWRestArea(cArea)
return

user function FTREL582()
	local oPrinter
	local cArea				:= FWGetArea()
	local nI				:= 0
	local cQy
	local cAliasC5			:= "REL58C5"
	local cAliasC6			:= "REL58C6"
	local cAliasC9			:= "REL58C9"
	local oArial12			:= TFont():New("Arial" /*cName*/, /*uPar2*/, 12 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial12b			:= TFont():New("Arial" /*cName*/, /*uPar2*/, 12 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	//local oArial15			:= TFont():New("Arial" /*cName*/, /*uPar2*/, 15 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial15b			:= TFont():New("Arial" /*cName*/, /*uPar2*/, 15 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial20			:= TFont():New("Arial" /*cName*/, /*uPar2*/, 20 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local nRowBase1			:= 0
	local nColBase1			:= 0
	local nRowDelta			:= 0
	local cPedido			:= "000057" // 		"000009"	"000057"	"000011"	"000014"	"000055"	"000031"	"000015"	"000057"
	local cFilPV			:= "0101" //		"01"		"0101"		"0101"		"0101"		"0101"		"0101"
	local cNomeDoArquivo	:= "PV" + cPedido + ".pdf"
	local aImpIT			:= {}
	local aDados			:= {}
	local aDadosIt			:= {}
	local aImpITCol			:= {}
	local nLimitJus			:= 33
	local nLimitFol			:= 63
	local nLinha
	local nItPag
	local aItPorPag			:= {{}}
	local aGrupPrd
	local aGrupPrdI
	local aGrupPrdS
	local aGrpMolArt
	local nLinMol
	local nLinArt
	local aCampos
	local aMedidas
	local aAlinhamento

	cQy := queryC5(cPedido, cFilPV)
	if select(cAliasC5) > 0
		dbSelectArea(cAliasC5)
		(cAliasC5)->(dbCloseArea())
	endIf
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasC5, .F., .T.)
	dbSelectArea(cAliasC5)
	if (cAliasC5)->(eOF())
		MsgAlert("O pedido não foi encontrado", NOME_DO_FONTE)
		FWRestArea(cArea)
		return
	endIf

	cQy := queryC6(cPedido, cFilPV)
	if select(cAliasC6) > 0
		dbSelectArea(cAliasC6)
		(cAliasC6)->(dbCloseArea())
	endIf
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasC6, .F., .T.)
	dbSelectArea(cAliasC6)
	if (cAliasC6)->(eOF())
		MsgAlert("O pedido não foi encontrado", NOME_DO_FONTE)
		FWRestArea(cArea)
		return
	endIf

	cQy := queryC9(cPedido, cFilPV)
	if select(cAliasC9) > 0
		dbSelectArea(cAliasC9)
		(cAliasC9)->(dbCloseArea())
	endIf
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasC9, .F., .T.)
	dbSelectArea(cAliasC9)
	if (cAliasC9)->(eOF())
		MsgAlert("Não existem datas de liberação para este pedido", NOME_DO_FONTE)
	endIf

	MaFisIni(;
		(cAliasC5)->C5_CLIENTE, ;
		(cAliasC5)->C5_LOJACLI, ;
		iif((cAliasC5)->C5_TIPO $ "D;B", "F", "C"), ;
		(cAliasC5)->C5_TIPO, ;
		(cAliasC5)->C5_TIPOCLI, ;
		MaFisRelImp("MT100", {"SF2", "SD2"}) /*Relacao de Impostos que suportados no arquivo*/, ;
		/*Tipo de complemento*/, ;
		/*Permite Incluir Impostos no Rodape .T./.F.*/, ;
		"SB1" /*Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)*/, ;
		"MATA410" /*Nome da rotina que esta utilizando a funcao*/;
		)

	nI := 0
	(cAliasC6)->(dbGoTop())
	while !(cAliasC6)->(eOF())
		nI++
		MaFisAdd(;
			(cAliasC6)->C6_PRODUTO, ;
			(cAliasC6)->C6_TES, ;
			(cAliasC6)->QUANT, ;
			(cAliasC6)->VALOR_UNI, ;
			(cAliasC6)->C6_VALDESC, ;
			(cAliasC6)->C6_NFORI, ;
			(cAliasC6)->C6_SERIORI, ;
			0 /*RecNo da NF Original no arq SD1/SD2*/,;
			0 /*Valor do Frete do Item               ( Opcional )*/, ;
			0 /*Valor da Despesa do item             ( Opcional )*/, ;
			0 /*Valor do Seguro do item              ( Opcional )*/, ;
			0 /*Valor do Frete Autonomo              ( Opcional )*/, ;
			(cAliasC6)->VALOR_TOTAL /*Valor da Mercadoria                  ( Obrigatorio )*/, ;
			0 /*Valor da Embalagem                   ( Opcional )*/, ;
			(cAliasC6)->SB1_REC /*RecNo do SB1*/, ;
			0 /*RecNo do SF4*/)
		MaFisLoad("IT_VALMERC", (cAliasC6)->VALOR_TOTAL, nI)
		MaFisAlt("IT_PESO", (cAliasC6)->B1_PESO, nI)
		(cAliasC6)->(dbSkip())
	endDo

	MaFisAlt("NF_FRETE", (cAliasC5)->C5_FRETE)
	MaFisAlt("NF_SEGURO", (cAliasC5)->C5_SEGURO)
	MaFisAlt("NF_DESPESA", (cAliasC5)->C5_DESPESA)
	MaFisAlt("NF_AUTONOMO", (cAliasC5)->C5_FRETAUT)
	if (cAliasC5)->C5_DESCONT > 0
		MaFisAlt(;
			"NF_DESCONTO", ;
			Min(MaFisRet(, "NF_VALMERC")-0.01, (cAliasC5)->C5_DESCONT+MaFisRet(, "NF_DESCONTO"));
			)
	endIf
	if (cAliasC5)->C5_PDESCAB > 0
		MaFisAlt(;
			"NF_DESCONTO", ;
			A410Arred(MaFisRet(, "NF_VALMERC") * (cAliasC5)->C5_PDESCAB / 100, "C6_VALOR") + MaFisRet(, "NF_DESCONTO");
			)
	endIf

	nI := 0
	aImpIT := {}
	aDados := {}
	(cAliasC6)->(dbGoTop())
	while !(cAliasC6)->(eOF())
		nI++
		aDadosIt := {}
		aAdd(aDadosIt, (cAliasC6)->C5_NUM)
		aAdd(aDadosIt, (cAliasC6)->C6_NFORI)
		aAdd(aDadosIt, (cAliasC6)->C6_SERIORI)
		aAdd(aDadosIt, (cAliasC6)->SB1_REC)
		aAdd(aDadosIt, (cAliasC6)->ITEM)
		aAdd(aDadosIt, (cAliasC6)->DESCON)
		aAdd(aDadosIt, (cAliasC6)->QUANT)
		aAdd(aDadosIt, (cAliasC6)->EMB)
		aAdd(aDadosIt, (cAliasC6)->UNIDADE)
		aAdd(aDadosIt, (cAliasC6)->CODIGO_FAMA)
		aAdd(aDadosIt, (cAliasC6)->B1_PESO)
		aAdd(aDadosIt, (cAliasC6)->C6_PRODUTO)
		aAdd(aDadosIt, (cAliasC6)->C6_TES)
		aAdd(aDadosIt, (cAliasC6)->DESCRICAO)
		aAdd(aDadosIt, (cAliasC6)->B1_GRUPO)
		aAdd(aDadosIt, (cAliasC6)->C6_VALDESC)
		aAdd(aDadosIt, (cAliasC6)->VALOR_UNI)
		aAdd(aDadosIt, (cAliasC6)->VALOR_TOTAL)
		aAdd(aDadosIt, (cAliasC6)->C5_FRETE)
		aAdd(aDadosIt, MaFisRet(nI, "IT_ALIQIPI"))
		aAdd(aDadosIt, MaFisRet(nI, "IT_VALIPI"))
		aAdd(aDadosIt, MaFisRet(nI, "IT_VALSOL"))
		aAdd(aDadosIt, (cAliasC6)->VALOR_TOTAL + MaFisRet(nI, "IT_ALIQIPI") + MaFisRet(nI, "IT_VALIPI") + MaFisRet(nI, "IT_VALSOL"))
		aAdd(aDadosIt, (cAliasC6)->QUANT * (cAliasC6)->B1_PESO)
		aAdd(aDadosIt, (cAliasC6)->GRUPO_COD)
		aAdd(aDadosIt, (cAliasC6)->GRUPO_DESCRI)
		aAdd(aDadosIt, (cAliasC6)->DESCONTOS)
		aAdd(aDadosIt, (cAliasC6)->C5_CONDPAG)
		aAdd(aDadosIt, (cAliasC6)->E4_DESCRI)
		aAdd(aDadosIt, (cAliasC6)->DESCONTOS_UMOLART)
		aAdd(aDadosIt, (cAliasC6)->C6_COMIS1)
		aAdd(aDados, aDadosIt)

		aImpITCol := {}
		aAdd(aImpITCol, (cAliasC6)->ITEM)
		aAdd(aImpITCol, Alltrim(Transform((cAliasC6)->DESCON, "@E 99.99")))
		aAdd(aImpITCol, cValToChar((cAliasC6)->QUANT))
		aAdd(aImpITCol, cValToChar((cAliasC6)->EMB))
		aAdd(aImpITCol, (cAliasC6)->UNIDADE)
		aAdd(aImpITCol, Alltrim((cAliasC6)->CODIGO_FAMA))
		aAdd(aImpITCol, Alltrim((cAliasC6)->DESCRICAO))
		aAdd(aImpITCol, Alltrim(Transform((cAliasC6)->VALOR_UNI, "@E 9,999.99")))
		aAdd(aImpITCol, Alltrim(Transform((cAliasC6)->VALOR_TOTAL, "@E 99,999.99")))
		aAdd(aImpITCol, Alltrim(Transform(aDadosIt[DA_IT_ALIQIPI], "@E 99.99")))
		aAdd(aImpITCol, Alltrim(Transform(aDadosIt[DA_IT_VALIPI], "@E 9,999.99")))
		aAdd(aImpIT, aImpITCol)

		(cAliasC6)->(dbSkip())
	endDo
	MaFisEnd()

	// Separa itens por página
	nLinha := 1
	nItPag := 1
	for nI := 1 to len(aImpIT)
		if nLinha <= nLimitJus
			aAdd(aItPorPag[nItPag], aImpIT[nI])
			nLinha++
		else
			if len(aImpIT) == nI .or. nLimitFol < nLinha
				nItPag++
				nI--
				nLinha := 1
				aAdd(aItPorPag, {})
			else
				aAdd(aItPorPag[nItPag], aImpIT[nI])
				nLinha++
			endIf
		endIf
	next

	// Agrupa por grupo de produto
	aGrupPrd := aGroupBy(aDados, DA_GRUPO_DESCRI)
	aGrupPrdI := aSelByIndx(aGrupPrd, {;
		DA_GRUPO_DESCRI, ;
		DA_DESCONTOS, ;
		DA_VALOR_TOTAL, ;
		DA_IT_VALIPI, ;
		DA_IT_VALSOL, ;
		DA_VALOR_C_IMPOSTOS, ;
		DA_PESO_TOTAL, ;
		DA_QUANT ;
		})

	// Calcula Total de agrupamento por produto
	aGrupPrdS := aSelByIndx(aGrupPrdI, {2, 3, 4, 5, 6, 7, 8})
	aGrupPrdS := aGroupBy(aGrupPrdS, 0)
	aGrupPrdS := aToStr(aGrupPrdS, {"", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99"})
	aGrupPrdS[1,1] := "Totais"

	// Transforma grupo de produto em string
	aGrupPrdI := aToStr(aGrupPrdI, {"", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99"})

	// Totaliza valor e peso de cada categoria SBM_UMOLART
	aGrpMolArt := aSelByIndx(aDados, {DA_D_UMOLA, DA_VALOR_TOTAL, DA_PESO_TOTAL})
	aGrpMolArt := aGroupBy(aDados, 1)

	// Inicio da parte gráfica
	oPrinter := FWMsPrinter():New(;
		cNomeDoArquivo /*cFilePrintert*/, ;
		IMP_PDF /*nDevice*/, ;
		.F. /*lAdjustToLegacy*/, ;
		/*cPathInServer*/, ;
		SEM_SETUP /*lDisabeSetup */, ;
		/*lTReport*/, ;
		@oPrinter /*@oPrintSetup*/, ;
		/*cPrinter*/, ;
		/*lServer*/, ;
		/*compatibilidade*/, ;
		/*lRaw*/, ;
		VIEW_PDF/*lViewPDF*/, ;
		/*nQtdCopy*/)
		oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(3,10,3,10) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:cPathPDF := "C:\TEMP\" // Caso seja utilizada impressï¿½o em IMP_SPOOL
	oPrinter:StartPage()

	cabC5(16, 0, @oPrinter, cAliasC5)
	grade(67, 4, {98, 81, 81}, {240, 346}, @oPrinter)

	nRowBase1 := 67
	nColBase1 := 8
	nRowDelta := 15
	oPrinter:Say(nRowBase1 + 1 * nRowDelta, nColBase1 + 0, "Data Entrada:", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 1 * nRowDelta, nColBase1 + 77, "____/____/________", oArial12, 15,,)

	oPrinter:Say(nRowBase1 + 2 * nRowDelta, nColBase1 + 0, "Data Digitado:", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 2 * nRowDelta, nColBase1 + 77, cValToChar(sTod(((cAliasC5)->EMISSAO))), oArial12, 15,,)

	oPrinter:Say(nRowBase1 + 3 * nRowDelta, nColBase1 + 0, "Data Validado:", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 3 * nRowDelta, nColBase1 + 77, cValToChar(sTod(((cAliasC9)->C9_DATALIB))), oArial12, 15,,)

	oPrinter:Say(nRowBase1 + 4 * nRowDelta, nColBase1 + 0, "Data Liberado:", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 4 * nRowDelta, nColBase1 + 77, "____/____/________", oArial12, 15,,)

	oPrinter:Say(nRowBase1 + 5 * nRowDelta, nColBase1 + 0, "Data Confirmado:", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 5 * nRowDelta, nColBase1 + 77, cValToChar(sTod(((cAliasC9)->C9_DATALIB))), oArial12, 15,,)

	oPrinter:Say(nRowBase1 + 6 * nRowDelta, nColBase1 + 0, "Data NF:", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 6 * nRowDelta, nColBase1 + 39, "____/____/________  Nro NF: ____________", oArial12, 15,,)

	nRowBase1 := 67
	nColBase1 := 248
	nRowDelta := 15
	oPrinter:Say(nRowBase1 + 1 * nRowDelta, nColBase1 + 50, iif((cAliasC5)->A1_UPARC == "Sim", "CPF(X)", "CPF( )"), oArial12b, 15,,)
	oPrinter:Say(nRowBase1 + 1 * nRowDelta, nColBase1 + 180, "Pedido: " + cPedido, oArial20, 15,,)
	oPrinter:Say(nRowBase1 + 2 * nRowDelta, nColBase1 + 70, iif((cAliasC5)->C5_UPROGIME == "1", "(X) PROGRAMADO", "( ) PROGRAMADO"), oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 2 * nRowDelta, nColBase1 + 170, iif((cAliasC5)->C5_UPROGIME == "2", "(X) IMEDIATO", "( ) IMEDIATO"), oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 3 * nRowDelta, nColBase1 + 0, "Representante: ", oArial12b, 15,,)
	oPrinter:Say(nRowBase1 + 3 * nRowDelta, nColBase1 + 75, "XXXXXXXXXXXXXXX", oArial12b, 15,,)
	oPrinter:Say(nRowBase1 + 4 * nRowDelta, nColBase1 + 0, "Artefatos: ", oArial12b, 15,,)
	oPrinter:Say(nRowBase1 + 4 * nRowDelta, nColBase1 + 75, "3,00%", oArial12b, 15,,)
	oPrinter:Say(nRowBase1 + 4 * nRowDelta, nColBase1 + 250, "DF MG", oArial20, 15,,)
	oPrinter:Say(nRowBase1 + 5 * nRowDelta, nColBase1 + 0, "Planas: ", oArial12b, 15,,)
	oPrinter:Say(nRowBase1 + 5 * nRowDelta, nColBase1 + 75, "3,00%", oArial12b, 15,,)
	oPrinter:Say(nRowBase1 + 6 * nRowDelta, nColBase1 + 0, "Helicoidais: ", oArial12b, 15,,)
	oPrinter:Say(nRowBase1 + 6 * nRowDelta, nColBase1 + 75, "3,00%", oArial12b, 15,,)

	nRowBase1 := 165
	nColBase1 := 8
	nRowDelta := 15
	oPrinter:Say(nRowBase1 + 1 * nRowDelta, nColBase1 + 0, "Data Reconf.:  ____/____/____     Hrs: ___________", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 2 * nRowDelta, nColBase1 + 0, "Obs:  _______________________________________", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 3 * nRowDelta, nColBase1 + 0, "____________________________________________", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 4 * nRowDelta, nColBase1 + 0, "____________________________________________", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 5 * nRowDelta, nColBase1 + 0, "____________________________________________", oArial12, 15,,)

	nRowBase1 := 165
	nColBase1 := 248
	nRowDelta := 15
	oPrinter:Say(nRowBase1 + 1 * nRowDelta, nColBase1 + 151, "Frete", oArial20, 15,,)
	oPrinter:Say(nRowBase1 + 2 * nRowDelta, nColBase1 + 0, "( )FOB MG   FOB/CIF   ( )CIF 1   (X)CIF 2   ( )CIF Grande BH", oArial15b, 15,,)
	oPrinter:Say(nRowBase1 + 3 * nRowDelta, nColBase1 + 0, "Transp. Despacho: " + (cAliasC5)->A4_NOME, oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 4 * nRowDelta, nColBase1 + 0, "Transp. Redespacho:", oArial12, 15,,)
	oPrinter:Say(nRowBase1 + 5 * nRowDelta, nColBase1 + 0, "Valor a ser cobrado na NF: R$ " + cValToChar((cAliasC5)->C5_FRETE) + "", oArial12, 15,,)

	nRowBase1 := 246
	nColBase1 := 8
	nRowDelta := 15
	nLinMol := 1
	oPrinter:Say(nRowBase1 + 1 * nRowDelta, nColBase1 + 59, "Desconto Molas", oArial20, 15,,)
	for nI := 1 to len(aGrupPrd)
		if aGrupPrd[nI, DA_D_UMOLA] == "1"
			nLinMol++
			oPrinter:Say(nRowBase1 + nLinMol * nRowDelta, nColBase1 + 0, Alltrim(aGrupPrd[nI, DA_GRUPO_DESCRI]) + ": " + Alltrim(aGrupPrd[nI, DA_DESCONTOS]) + " - R$" + Alltrim(Transform(aGrupPrd[nI, DA_VALOR_TOTAL] / aGrupPrd[nI, DA_PESO_TOTAL], "@E 9,999.99")), oArial12, 15,,)
		endIf
	next
	oPrinter:Say(nRowBase1 + 5 * nRowDelta, nColBase1 + 0, "Cond. Pgto: " + aDados[1, DA_E4_DESCRI], oArial12, 15,,)
	for nI := 1 to len(aGrpMolArt)
		if aGrpMolArt[nI, 1] == "1"
			oPrinter:Say(nRowBase1 + 5 * nRowDelta, nColBase1 + 0, " - Líquido R$" + Alltrim(Transform(aGrpMolArt[nI, 1], "@E 99.999.99")) + " - " + Alltrim(Transform(aGrpMolArt[nI, 3], "@E 9,999.99")) + " Kg", oArial12, 15,,)
		endIf
	next

	nRowBase1 := 246
	nColBase1 := 248
	nRowDelta := 15
	nLinArt := 1
	oPrinter:Say(nRowBase1 + 1 * nRowDelta, nColBase1 + 102, "Desconto Artefatos", oArial20, 15,,)
	for nI := 1 to len(aGrupPrd)
		if aGrupPrd[nI, DA_D_UMOLA] == "2"
			nLinArt++
			oPrinter:Say(nRowBase1 + nLinArt * nRowDelta, nColBase1 + 0, Alltrim(aGrupPrd[nI, DA_GRUPO_DESCRI]) + ": " + Alltrim(aGrupPrd[nI, DA_DESCONTOS]) + " - R$" + Alltrim(Transform(aGrupPrd[nI, DA_VALOR_TOTAL] / aGrupPrd[nI, DA_PESO_TOTAL], "@E 9,999.99")), oArial12, 15,,)
		endIf
	next
	oPrinter:Say(nRowBase1 + 5 * nRowDelta, nColBase1 + 0, "Cond. Pgto: " + aDados[1, DA_E4_DESCRI], oArial12, 15,,)
	for nI := 1 to len(aGrpMolArt)
		if aGrpMolArt[nI, 1] == "2"
			oPrinter:Say(nRowBase1 + 5 * nRowDelta, nColBase1 + 0, " - Líquido R$" + Alltrim(Transform(aGrpMolArt[nI, 1], "@E 99.999.99")) + " - " + Alltrim(Transform(aGrpMolArt[nI, 3], "@E 9,999.99")) + " Kg", oArial12, 15,,)
		endIf
	next

	// Imprime lista de itens
	aCampos := {"Item", "%Desc", "Qtde Ped.", "Emb", "Un", "Código Fama", "Descrição", "Valor unitário", "Valor Total", "%IPI", "Valor IPI"}
	aMedidas := {29, 38, 38, 33, 24, 65, 176, 52, 57, 29, 45}
	aAlinhamento := {PAD_CENTER_H, PAD_RIGHT, PAD_CENTER_H, PAD_CENTER_H, PAD_CENTER_H, PAD_CENTER_H, PAD_LEFT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
	nI := 1 // provisoriamente enquanto não implementa o for da quebra de página
	printTab(351, 4, 10, aMedidas, aAlinhamento, aCampos, aItPorPag[nI], @oPrinter)

	// Imprime por grupo de produtos
	aCampos := {"Grupo", "Descontos", "Valor Liquido", "Valor IPI", "Valor ST", "Total c/ impostos", "Peso(kg)", "Qtde"}
	aMedidas := {112, 115, 69, 56, 56, 83, 54, 41}
	aAlinhamento := {PAD_LEFT, PAD_LEFT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
	printTab(530, 4, 10, aMedidas, aAlinhamento, aCampos, aGrupPrdI, @oPrinter)

	// Imprime totais
	aMedidas := {227, 69, 56, 56, 83, 54, 41}
	aAlinhamento := {PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
	printTab(530 + (len(aGrupPrdI) + 1) * 10, 4, 10, aMedidas, aAlinhamento, , aGrupPrdS, @oPrinter)

	oPrinter:EndPage()
	oPrinter:Setup()
	oPrinter:Preview()
	FreeObj(oPrinter)
	oPrinter := Nil
	FWRestArea(cArea)
return

/*/{Protheus.doc} UFINR85
	Funcao que gera relatorios de pedido de vendas com impostos e sem impostos
	@type user function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
user function FTREL581(lComMaFis)
	local oPrinter
	local oArial18b			:= TFont():New("Arial" /*cName*/, /*uPar2*/, 18 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local cPedido			:= SC5->C5_NUM
	local cFilPV			:= SC5->C5_FILIAL
	local cNomeDoArquivo	:= "PV" + cPedido + iif(lComMaFis, "f", "")
	local cQy
	local cAliasC5			:= "REL58C5"
	local cAliasC6			:= "REL58C6"
	local cAliasC9			:= "REL58C9"
	local aImpITCol			:= {}
	local aCampos			:= {}
	local aMedidas			:= {}
	local aAlinhamento		:= {}
	local aImpIT			:= {}
	local cArea				:= FWGetArea()
	local nRowBase1			:= 0
	local nColBase1			:= 0
	local nI				:= 0
	local nLimitJus			:= 33
	local nLimitFol			:= 63
	local nLinha
	local nItPag
	local aDados
	local aDadosIt
	local aGrupPrd
	local aGrupPrdI
	local aGrupPrdS
	local aGrupPrdCP
	local aDupl
	local aItPorPag			:= {{}}

	cQy := queryC5(cPedido, cFilPV)
	if select(cAliasC5) > 0
		dbSelectArea(cAliasC5)
		(cAliasC5)->(dbCloseArea())
	endIf
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasC5, .F., .T.)
	dbSelectArea(cAliasC5)
	if (cAliasC5)->(eOF())
		MsgAlert("O pedido não foi encontrado", NOME_DO_FONTE)
		FWRestArea(cArea)
		return
	endIf

	cQy := queryC6(cPedido, cFilPV)
	if select(cAliasC6) > 0
		dbSelectArea(cAliasC6)
		(cAliasC6)->(dbCloseArea())
	endIf
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasC6, .F., .T.)
	dbSelectArea(cAliasC6)
	if (cAliasC6)->(eOF())
		MsgAlert("O pedido não foi encontrado", NOME_DO_FONTE)
		FWRestArea(cArea)
		return
	endIf

	cQy := queryC9(cPedido, cFilPV)
	if select(cAliasC9) > 0
		dbSelectArea(cAliasC9)
		(cAliasC9)->(dbCloseArea())
	endIf
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasC9, .F., .T.)
	dbSelectArea(cAliasC9)
	if (cAliasC9)->(eOF())
		MsgAlert("Não existem datas de liberação para este pedido", NOME_DO_FONTE)
	endIf

	if lComMaFis
		MaFisIni(;
			(cAliasC5)->C5_CLIENTE, ;
			(cAliasC5)->C5_LOJACLI, ;
			iif((cAliasC5)->C5_TIPO $ "D;B", "F", "C"), ;
			(cAliasC5)->C5_TIPO, ;
			(cAliasC5)->C5_TIPOCLI, ;
			MaFisRelImp("MT100", {"SF2", "SD2"}) /*Relacao de Impostos que suportados no arquivo*/, ;
		/*Tipo de complemento*/, ;
		/*Permite Incluir Impostos no Rodape .T./.F.*/, ;
			"SB1" /*Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)*/, ;
			"MATA410" /*Nome da rotina que esta utilizando a funcao*/;
			)

		nI := 0
		(cAliasC6)->(dbGoTop())
		while !(cAliasC6)->(eOF())
			nI++
			MaFisAdd(;
				(cAliasC6)->C6_PRODUTO, ;
				(cAliasC6)->C6_TES, ;
				(cAliasC6)->QUANT, ;
				(cAliasC6)->VALOR_UNI, ;
				(cAliasC6)->C6_VALDESC, ;
				(cAliasC6)->C6_NFORI, ;
				(cAliasC6)->C6_SERIORI, ;
				0 /*RecNo da NF Original no arq SD1/SD2*/,;
				0 /*Valor do Frete do Item               ( Opcional )*/, ;
				0 /*Valor da Despesa do item             ( Opcional )*/, ;
				0 /*Valor do Seguro do item              ( Opcional )*/, ;
				0 /*Valor do Frete Autonomo              ( Opcional )*/, ;
				(cAliasC6)->VALOR_TOTAL /*Valor da Mercadoria                  ( Obrigatorio )*/, ;
				0 /*Valor da Embalagem                   ( Opcional )*/, ;
				(cAliasC6)->SB1_REC /*RecNo do SB1*/, ;
				0 /*RecNo do SF4*/)
			MaFisLoad("IT_VALMERC", (cAliasC6)->VALOR_TOTAL, nI)
			MaFisAlt("IT_PESO", (cAliasC6)->B1_PESO, nI)
			(cAliasC6)->(dbSkip())
		endDo

		MaFisAlt("NF_FRETE", (cAliasC5)->C5_FRETE)
		MaFisAlt("NF_SEGURO", (cAliasC5)->C5_SEGURO)
		MaFisAlt("NF_DESPESA", (cAliasC5)->C5_DESPESA)
		MaFisAlt("NF_AUTONOMO", (cAliasC5)->C5_FRETAUT)
		if (cAliasC5)->C5_DESCONT > 0
			MaFisAlt(;
				"NF_DESCONTO", ;
				Min(MaFisRet(, "NF_VALMERC")-0.01, (cAliasC5)->C5_DESCONT+MaFisRet(, "NF_DESCONTO"));
				)
		endIf
		if (cAliasC5)->C5_PDESCAB > 0
			MaFisAlt(;
				"NF_DESCONTO", ;
				A410Arred(MaFisRet(, "NF_VALMERC") * (cAliasC5)->C5_PDESCAB / 100, "C6_VALOR") + MaFisRet(, "NF_DESCONTO");
				)
		endIf
	endIf

	nI := 0
	aImpIT := {}
	aDados := {}
	(cAliasC6)->(dbGoTop())
	while !(cAliasC6)->(eOF())
		nI++
		aDadosIt := {}
		aAdd(aDadosIt, (cAliasC6)->C5_NUM)
		aAdd(aDadosIt, (cAliasC6)->C6_NFORI)
		aAdd(aDadosIt, (cAliasC6)->C6_SERIORI)
		aAdd(aDadosIt, (cAliasC6)->SB1_REC)
		aAdd(aDadosIt, (cAliasC6)->ITEM)
		aAdd(aDadosIt, (cAliasC6)->DESCON)
		aAdd(aDadosIt, (cAliasC6)->QUANT)
		aAdd(aDadosIt, (cAliasC6)->EMB)
		aAdd(aDadosIt, (cAliasC6)->UNIDADE)
		aAdd(aDadosIt, (cAliasC6)->CODIGO_FAMA)
		aAdd(aDadosIt, (cAliasC6)->B1_PESO)
		aAdd(aDadosIt, (cAliasC6)->C6_PRODUTO)
		aAdd(aDadosIt, (cAliasC6)->C6_TES)
		aAdd(aDadosIt, (cAliasC6)->DESCRICAO)
		aAdd(aDadosIt, (cAliasC6)->B1_GRUPO)
		aAdd(aDadosIt, (cAliasC6)->C6_VALDESC)
		aAdd(aDadosIt, (cAliasC6)->VALOR_UNI)
		aAdd(aDadosIt, (cAliasC6)->VALOR_TOTAL)
		aAdd(aDadosIt, (cAliasC6)->C5_FRETE)
		if lComMaFis
			aAdd(aDadosIt, MaFisRet(nI, "IT_ALIQIPI"))
			aAdd(aDadosIt, MaFisRet(nI, "IT_VALIPI"))
			aAdd(aDadosIt, MaFisRet(nI, "IT_VALSOL"))
			aAdd(aDadosIt, (cAliasC6)->VALOR_TOTAL + MaFisRet(nI, "IT_ALIQIPI") + MaFisRet(nI, "IT_VALIPI") + MaFisRet(nI, "IT_VALSOL"))
		else
			aAdd(aDadosIt, 0)
			aAdd(aDadosIt, 0)
			aAdd(aDadosIt, 0)
			aAdd(aDadosIt, (cAliasC6)->VALOR_TOTAL)
		endIf
		aAdd(aDadosIt, (cAliasC6)->QUANT * (cAliasC6)->B1_PESO)
		aAdd(aDadosIt, (cAliasC6)->GRUPO_COD)
		aAdd(aDadosIt, (cAliasC6)->GRUPO_DESCRI)
		aAdd(aDadosIt, (cAliasC6)->DESCONTOS)
		aAdd(aDadosIt, (cAliasC6)->C5_CONDPAG)
		aAdd(aDadosIt, (cAliasC6)->E4_DESCRI)
		aAdd(aDadosIt, (cAliasC6)->DESCONTOS_UMOLART)
		aAdd(aDadosIt, (cAliasC6)->C6_COMIS1)
		aAdd(aDados, aDadosIt)

		aImpITCol := {}
		aAdd(aImpITCol, (cAliasC6)->ITEM)
		aAdd(aImpITCol, Alltrim(Transform((cAliasC6)->DESCON, "@E 99.99")))
		aAdd(aImpITCol, cValToChar((cAliasC6)->QUANT))
		aAdd(aImpITCol, cValToChar((cAliasC6)->EMB))
		aAdd(aImpITCol, (cAliasC6)->UNIDADE)
		aAdd(aImpITCol, Alltrim((cAliasC6)->CODIGO_FAMA))
		aAdd(aImpITCol, Alltrim((cAliasC6)->DESCRICAO))
		aAdd(aImpITCol, Alltrim(Transform((cAliasC6)->VALOR_UNI, "@E 9,999.99")))
		aAdd(aImpITCol, Alltrim(Transform((cAliasC6)->VALOR_TOTAL, "@E 99,999.99")))
		aAdd(aImpITCol, Alltrim(Transform(aDadosIt[DA_IT_ALIQIPI], "@E 99.99")))
		aAdd(aImpITCol, Alltrim(Transform(aDadosIt[DA_IT_VALIPI], "@E 9,999.99")))
		aAdd(aImpIT, aImpITCol)

		(cAliasC6)->(dbSkip())
	endDo
	if lComMaFis
		MaFisEnd()
	endIf

	// Separa itens por página
	nLinha := 1
	nItPag := 1
	for nI := 1 to len(aImpIT)
		if nLinha <= nLimitJus
			aAdd(aItPorPag[nItPag], aImpIT[nI])
			nLinha++
		else
			if len(aImpIT) == nI .or. nLimitFol < nLinha
				nItPag++
				nI--
				nLinha := 1
				aAdd(aItPorPag, {})
			else
				aAdd(aItPorPag[nItPag], aImpIT[nI])
				nLinha++
			endIf
		endIf
	next

	// Agrupa por grupo de produto
	aGrupPrd := aGroupBy(aDados, DA_GRUPO_DESCRI)
	aGrupPrdI := aSelByIndx(aGrupPrd, {;
		DA_GRUPO_DESCRI, ;
		DA_DESCONTOS, ;
		DA_VALOR_TOTAL, ;
		DA_IT_VALIPI, ;
		DA_IT_VALSOL, ;
		DA_VALOR_C_IMPOSTOS, ;
		DA_PESO_TOTAL, ;
		DA_QUANT ;
		})

	// Calcula Total de agrupamento por produto
	aGrupPrdS := aSelByIndx(aGrupPrdI, {2, 3, 4, 5, 6, 7, 8})
	aGrupPrdS := aGroupBy(aGrupPrdS, 0)
	aGrupPrdS := aToStr(aGrupPrdS, {"", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99"})
	aGrupPrdS[1,1] := "Totais"

	// Calcula condicoes de pagamento
	(cAliasC9)->(dbGoTop())
	aDupl := Condicao(nSomaCol(aGrupPrdI, 6), (cAliasC5)->CONDICAO_PAG, , sToD((cAliasC9)->C9_DATALIB))
	aDupl := aEnumera(aDupl, 0)
	aDupl := aImparPar(aDupl)

	// Calcula condicao de pagamento por grupo de produto
	aGrupPrdCP := aSelByIndx(aGrupPrd, {;
		DA_GRUPO_DESCRI, ;
		DA_E4_DESCRI})
	aGrupPrdCP := aToStr(aGrupPrdCP, {"", ""})

	// Transforma grupo de produto em string
	aGrupPrdI := aToStr(aGrupPrdI, {"", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99"})

	// Inicio da parte gráfica
	oPrinter := FWMsPrinter():New(;
		cNomeDoArquivo /*cFilePrintert*/, ;
		IMP_PDF /*nDevice*/, ;
		.F. /*lAdjustToLegacy*/, ;
		/*cPathInServer*/, ;
		SEM_SETUP /*lDisabeSetup */, ;
		/*lTReport*/, ;
		@oPrinter /*@oPrintSetup*/, ;
		/*cPrinter*/, ;
		/*lServer*/, ;
		/*compatibilidade*/, ;
		/*lRaw*/, ;
		VIEW_PDF/*lViewPDF*/, ;
		/*nQtdCopy*/)
		oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(3,10,3,10) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:cPathPDF := "C:\TEMP\" // Caso seja utilizada impressï¿½o em IMP_SPOOL
	oPrinter:StartPage()

	nItPag := len(aItPorPag)
	for nI := 1 to nItPag
		cabFama(@oPrinter, nI /*nPaginaAtual*/, nItPag /*nPaginaTotal*/)
		cabC5(132, 0, @oPrinter, cAliasC5)
		oPrinter:SayAlign(132 + 49, 0, "Pedido", oArial18b, 590, 16, , PAD_CENTER_H, 2)

		aCampos := {"Item", "%Desc", "Qtde Ped.", "Emb", "Un", "Código Fama", "Descrição", "Valor unitário", "Valor Total", "%IPI", "Valor IPI"}
		aMedidas := {29, 38, 38, 33, 24, 65, 176, 52, 57, 29, 45}
		aAlinhamento := {PAD_CENTER_H, PAD_RIGHT, PAD_CENTER_H, PAD_CENTER_H, PAD_CENTER_H, PAD_CENTER_H, PAD_LEFT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
		printTab(nRowBase1 + 210, nColBase1 + 4, 10, aMedidas, aAlinhamento, aCampos, aItPorPag[nI], @oPrinter)

		if nI != nItPag
			oPrinter:EndPage()
			oPrinter:StartPage()
		else
			rodaPeC5(nRowBase1 + 550, nColBase1 + 4, oPrinter, cPedido, cAliasC5)

			// Imprime por grupo de produtos
			aCampos := {"Grupo", "Descontos", "Valor Liquido", "Valor IPI", "Valor ST", "Total c/ impostos", "Peso(kg)", "Qtde"}
			aMedidas := {112, 111, 69, 56, 56, 83, 54, 41}
			aAlinhamento := {PAD_LEFT, PAD_LEFT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
			printTab(nRowBase1 + 590, nColBase1 + 4, 10, aMedidas, aAlinhamento, aCampos, aGrupPrdI, @oPrinter)

			// Imprime totais
			aMedidas := {223, 69, 56, 56, 83, 54, 41}
			aAlinhamento := {PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
			printTab(nRowBase1 + 590 + (len(aGrupPrdI) + 1) * 10, nColBase1 + 4, 10, aMedidas, aAlinhamento, , aGrupPrdS, @oPrinter)

			// Imprime condicoes de pagamento por grupo de produto
			aCampos := {"Grupo", "Cond. Pagamento"}
			aMedidas := {154, 70}
			aAlinhamento := {PAD_LEFT, PAD_RIGHT}
			printTab(nRowBase1 + 657, nColBase1 + 4, 10, aMedidas, aAlinhamento, aCampos, aGrupPrdCP, @oPrinter)

			// Imprime Parcelas e vencimentos
			aCampos := {"Nº", "Vencimento", "Valor"}
			aMedidas := {20, 80, 38}
			aAlinhamento := {PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
			printTab(nRowBase1 + 657, nColBase1 + 238, 10, aMedidas, aAlinhamento, aCampos, aToStr(aDupl[1], {"@E 9", "", "@E 99,999.99"}), @oPrinter)
			printTab(nRowBase1 + 657, nColBase1 + 376, 10, aMedidas, aAlinhamento, aCampos, aToStr(aDupl[2], {"@E 9", "", "@E 99,999.99"}), @oPrinter)

			// Imprime roda pé final
			rodaPeFim(@oPrinter, cAliasC5, cAliasC9)
		endIf
	next

	oPrinter:EndPage()
	oPrinter:Setup()
	oPrinter:Preview()
	FreeObj(oPrinter)
	oPrinter := Nil
	FWRestArea(cArea)
return

/*/{Protheus.doc} queryC5
	Funcao que gera monta query dos dados de cabeçalho
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
	@return cQy
/*/
static function queryC5(cPedido, cFilPV)
	local cQy := ""

	cQy += "SELECT " + CRLF
	cQy += "	C5_NUM, " + CRLF
	cQy += "	C5_CLIENTE, " + CRLF
	cQy += "	C5_LOJACLI, " + CRLF
	cQy += "	C5_TIPOCLI, " + CRLF
	cQy += "	A1_NOME AS CLI_NOME, " + CRLF
	cQy += "	A1_END AS CLI_ENDERECO, " + CRLF
	cQy += "	A1_CEP AS CLI_CEP, " + CRLF
	cQy += "	A1_MUN AS CLI_MUNICIPIO, " + CRLF
	cQy += "	A1_EST AS CLI_UF, " + CRLF
	cQy += "	A1_TEL AS CLI_TELEFONE, " + CRLF
	cQy += "	A1_CGC AS CLI_CNPJ, " + CRLF
	cQy += "	A1_INSCR AS CLI_IE, " + CRLF
	cQy += "	A1_EMAIL AS CLI_EMAIL, " + CRLF
	cQy += "	C5_EMISSAO AS EMISSAO, " + CRLF
	cQy += "	C5_NUM AS PEDIDO, " + CRLF
	cQy += "	C5_TIPO, " + CRLF
	cQy += "	C5_CONDPAG AS CONDICAO_PAG, " + CRLF
	cQy += "	CASE " + CRLF
	cQy += "		WHEN C5_FECENT <> '' " + CRLF
	cQy += "		THEN C5_FECENT " + CRLF
	cQy += "		ELSE " + CRLF
	cQy += "			CASE " + CRLF
	cQy += "				WHEN C5_SUGENT <> '' " + CRLF
	cQy += "				THEN C5_SUGENT " + CRLF
	cQy += "				ELSE C6_ENTREG " + CRLF
	cQy += "			END " + CRLF
	cQy += "	END AS DT_ENTREG, " + CRLF
	cQy += "	CASE " + CRLF
	cQy += "		WHEN C5_FECENT <> '' " + CRLF
	cQy += "		THEN 'C5_FECENT' " + CRLF
	cQy += "		ELSE " + CRLF
	cQy += "			CASE " + CRLF
	cQy += "				WHEN C5_SUGENT <> '' " + CRLF
	cQy += "				THEN 'C5_SUGENT' " + CRLF
	cQy += "				ELSE 'C6_ENTREG' " + CRLF
	cQy += "			END " + CRLF
	cQy += "	END AS DT_ENTREGO, " + CRLF
	cQy += "	A3_COD || ' - ' || A3_NOME AS REPRESENTANTE, " + CRLF
	cQy += "	C5_TPFRETE, " + CRLF
	cQy += "	C5_FRETE, " + CRLF
	cQy += "	C5_SEGURO, " + CRLF
	cQy += "	C5_DESPESA, " + CRLF
	cQy += "	C5_DESCONT, " + CRLF
	cQy += "	C5_PDESCAB, " + CRLF
	cQy += "	C5_FRETAUT, " + CRLF
	cQy += "	C5_TRANSP, " + CRLF
	cQy += "	A1_UPARC, " + CRLF
	cQy += "	A4_NOME, " + CRLF
	cQy += "	'C5_UPROGIME' AS C5_UPROGIME " + CRLF
	cQy += "FROM " + CRLF
	cQy += "	" + RetSQLName("SC5") + " SC5 " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SA1") + " SA1 " + CRLF
	cQy += "		ON C5_CLIENTE = A1_COD " + CRLF
	cQy += "		AND C5_LOJACLI = A1_LOJA " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SA1") + " " + CRLF
	cQy += "		AND SA1.D_E_L_E_T_ = '' " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SC6") + " SC6 " + CRLF
	cQy += "		ON C5_NUM = C6_NUM " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SC6") + " " + CRLF
	cQy += "		AND SC6.D_E_L_E_T_ = '' " + CRLF
	cQy += "	LEFT JOIN " + CRLF
	cQy += "		" + RetSQLName("SA3") + " SA3 " + CRLF
	cQy += "		ON C5_VEND1 = A3_COD " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SA3") + " " + CRLF
	cQy += "		AND SA3.D_E_L_E_T_ = '' " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SA4") + " SA4 " + CRLF
	cQy += "		ON A4_COD = C5_TRANSP " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SA4") + " " + CRLF
	cQy += "		AND SA4.D_E_L_E_T_ = '' " + CRLF
	cQy += "WHERE " + CRLF
	cQy += "	C5_NUM = '" + cPedido + "' " + CRLF
	cQy += "	AND C5_FILIAL = '" + cFilPV + "' " + CRLF
	cQy += "	AND SC5.D_E_L_E_T_ = '' " + CRLF
return cQy

/*/{Protheus.doc} queryC6
	Funcao que gera monta query dos dados de itens
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
	@return cQy
/*/
static function queryC6(cPedido, cFilPV)
	local cQy := ""

	cQy += "SELECT " + CRLF
	cQy += "	C5_NUM, " + CRLF
	cQy += "	C6_NFORI, " + CRLF
	cQy += "	C6_SERIORI, " + CRLF
	cQy += "	SB1.R_E_C_N_O_ AS SB1_REC, " + CRLF
	cQy += "	C6_ITEM AS ITEM, " + CRLF
	cQy += "	C6_DESCONT AS DESCON, " + CRLF
	cQy += "	C6_QTDVEN AS QUANT, " + CRLF
	cQy += "	B1_QE AS EMB, " + CRLF
	cQy += "	C6_UM AS UNIDADE, " + CRLF
	cQy += "	B1_COD AS CODIGO_FAMA, " + CRLF
	cQy += "	B1_PESO, " + CRLF
	cQy += "	C6_PRODUTO, " + CRLF
	cQy += "	C6_TES, " + CRLF
	cQy += "	B1_DESC AS DESCRICAO, " + CRLF
	cQy += "	B1_GRUPO, " + CRLF
	cQy += "	C6_VALDESC, " + CRLF
	cQy += "	C6_PRCVEN AS VALOR_UNI, " + CRLF
	cQy += "	C6_VALOR AS VALOR_TOTAL, " + CRLF
	cQy += "	C5_FRETE, " + CRLF
	cQy += "	B1_GRUPO AS GRUPO_COD, " + CRLF
	cQy += "	BM_DESC AS GRUPO_DESCRI, " + CRLF
	cQy += "	TRIM(TO_CHAR(C6_UDCIDP, '99G999D00')) || '+' || TRIM(TO_CHAR(C6_UDCVEND, '99G999D00')) || '+' || TRIM(TO_CHAR(C6_UDCGPPD, '99G999D00')) || '+' || TRIM(TO_CHAR(C6_UDCCLI, '99G999D00')) AS DESCONTOS, " + CRLF
	cQy += "	C5_CONDPAG, " + CRLF
	cQy += "	E4_DESCRI, " + CRLF
	cQy += "	'2' AS DESCONTOS_UMOLART, " + CRLF
	cQy += "	C6_COMIS1 " + CRLF
	cQy += "FROM " + CRLF
	cQy += "	" + RetSQLName("SC5") + " SC5 " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SC6") + " SC6 " + CRLF
	cQy += "		ON C5_NUM = C6_NUM " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SC6") + " " + CRLF
	cQy += "		AND SC6.D_E_L_E_T_ = '' " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SB1") + " SB1 " + CRLF
	cQy += "		ON C6_PRODUTO = B1_COD " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SB1") + " " + CRLF
	cQy += "		AND SB1.D_E_L_E_T_ = '' " + CRLF
	cQy += "	LEFT JOIN " + CRLF
	cQy += "		" + RetSQLName("SBM") + " SBM " + CRLF
	cQy += "		ON B1_GRUPO = BM_GRUPO " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SBM") + " " + CRLF
	cQy += "		AND SBM.D_E_L_E_T_ = '' " + CRLF
	cQy += "	LEFT JOIN " + CRLF
	cQy += "		" + RetSQLName("SE4") + " SE4 " + CRLF
	cQy += "		ON C5_CONDPAG = E4_CODIGO " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SE4") + " " + CRLF
	cQy += "		AND SE4.D_E_L_E_T_ = '' " + CRLF
	cQy += "WHERE " + CRLF
	cQy += "	C5_NUM = '" + cPedido + "' " + CRLF
	cQy += "	AND C5_FILIAL = '" + cFilPV + "' " + CRLF
	cQy += "	AND SC5.D_E_L_E_T_ = '' " + CRLF
	cQy += "ORDER BY " + CRLF
	cQy += "	C5_NUM, C6_ITEM " + CRLF
return cQy

/*/{Protheus.doc} queryC9
	Funcao que gera monta query dos dados de liberação
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
	@return cQy
/*/
static function queryC9(cPedido, cFilPV)
	local cQy := ""

	cQy := "SELECT " + CRLF
	cQy += "	C5_NUM AS PEDIDO, " + CRLF
	cQy += "	C6_ITEM, " + CRLF
	cQy += "	C9_DATALIB, " + CRLF
	cQy += "	C5_EMISSAO AS EMISSAO " + CRLF
	cQy += "FROM " + CRLF
	cQy += "	" + RetSQLName("SC5") + " SC5 " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SA1") + " SA1 " + CRLF
	cQy += "		ON C5_CLIENTE = A1_COD " + CRLF
	cQy += "		AND C5_LOJACLI = A1_LOJA " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SA1") + " " + CRLF
	cQy += "		AND SA1.D_E_L_E_T_ = '' " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SC6") + " SC6 " + CRLF
	cQy += "		ON C5_NUM = C6_NUM " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SC6") + " " + CRLF
	cQy += "		AND SC6.D_E_L_E_T_ = '' " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SC9") + " SC9 " + CRLF
	cQy += "		ON C6_NUM = C9_PEDIDO " + CRLF
	cQy += "		AND C6_PRODUTO = C9_PRODUTO " + CRLF
	cQy += "		AND C6_ITEM = C9_ITEM " + CRLF
	cQy += "		AND " + FWJoinFilial("SC5", "SC9") + " " + CRLF
	cQy += "		AND SC9.D_E_L_E_T_ = '' " + CRLF
	cQy += "WHERE " + CRLF
	cQy += "	C5_NUM = '" + cPedido + "' " + CRLF
	cQy += "	AND C5_FILIAL = '" + cFilPV + "' " + CRLF
	cQy += "	AND SC5.D_E_L_E_T_ = '' " + CRLF
	cQy += "ORDER BY " + CRLF
	cQy += "	C5_NUM, C9_DATALIB DESC " + CRLF
return cQy

/*/{Protheus.doc} queryResum
	Funcao que monta a query do resumo de vendas
	@type static function
	@author Julio Carvalho Barberino
	@since 08/12/2025
	@version 0
/*/
static function queryResum(dIni, dFim)
	local cQy := ""
	local cIni		:= dToS(dIni)
	local cFim		:= dToS(dFim)

	cQy := "SELECT " + CRLF
	cQy += "	CASE " + CRLF
	cQy += "		WHEN M0_NOMECOM = 'DF RIBEIRAO PRETO' " + CRLF
	cQy += "		THEN 'DF Rb' " + CRLF
	cQy += "		ELSE " + CRLF
	cQy += "			CASE " + CRLF
	cQy += "				WHEN M0_NOMECOM = 'DF UBERLANDIA' " + CRLF
	cQy += "				THEN 'DF Ub' " + CRLF
	cQy += "				ELSE M0_NOMECOM " + CRLF
	cQy += "			END " + CRLF
	cQy += "	END AS NAME_FIL, " + CRLF
	cQy += "	BM_DESC, " + CRLF
	cQy += "	SUM(D2_TOTAL) AS SUM_D2_TOT, " + CRLF
	cQy += "	SUM(D2_QUANT * B1_PESO) AS SUM_PESO " + CRLF
	cQy += "FROM " + CRLF
	cQy += "	" + RetSQLName("SD2") + " SD2 " + CRLF
	cQy += "	INNER JOIN " + RetSQLName("SB1") + " SB1 " + CRLF
	cQy += "	ON D2_COD = B1_COD " + CRLF
	cQy += "	AND SB1.D_E_L_E_T_ = '' " + CRLF
	cQy += "	INNER JOIN " + RetSQLName("SBM") + " SBM" + CRLF
	cQy += "	ON D2_GRUPO = BM_GRUPO " + CRLF
	cQy += "	INNER JOIN SYS_COMPANY M0 " + CRLF
	cQy += "	ON M0_CODFIL = D2_FILIAL " + CRLF
	cQy += "	INNER JOIN " + RetSQLName("SF4") + " SF4 " + CRLF
	cQy += "	ON D2_TES = F4_CODIGO " + CRLF
	cQy += "	AND " + FWJoinFilial("SD2", "SF4") + " " + CRLF
	cQy += "WHERE " + CRLF
	cQy += "	D2_FILIAL IN('0101', '0301', '0401', '0501', '0601', '0701', '0801', '0901', '1001', '1101', '1201', '1301') " + CRLF // AVISO retirar a filial '0101', esta sendo usada apenas como teste
	cQy += "	AND D2_EMISSAO BETWEEN '" + cIni + "' AND '" + cFim + "' " + CRLF
	cQy += "	AND SD2.D_E_L_E_T_ = '' " + CRLF
	cQy += "	AND SF4.F4_DUPLIC = 'S' " + CRLF
	cQy += "GROUP BY " + CRLF
	cQy += "	M0_NOMECOM, BM_DESC " + CRLF
	cQy += "ORDER BY " + CRLF
	cQy += "	M0_NOMECOM, BM_DESC " + CRLF
	showLog(cQy)
return cQy

/*/{Protheus.doc} queryComis
	Funcao que monta a query do resumo de comissao
	@type static function
	@author Julio Carvalho Barberino
	@since 15/12/2025
	@version 0
/*/
static function queryComis(dIni, dFim)
	local cQy
	local cIni		:= dToS(dIni)
	local cFim		:= dToS(dFim)

	cQy := "SELECT " + CRLF
	cQy += "	SUM(D2_COMIS1) AS SUM_COMIS1, " + CRLF
	cQy += "	SUM(D2_COMIS2) AS SUM_COMIS2 " + CRLF
	cQy += "FROM " + CRLF
	cQy += "	" + RetSQLName("SD2") + " SD2 " + CRLF
	cQy += "	INNER JOIN " + RetSQLName("SF4") + " SF4 " + CRLF
	cQy += "	ON D2_TES = F4_CODIGO " + CRLF
	cQy += "	AND " + FWJoinFilial("SD2", "SF4") + " " + CRLF
	cQy += "WHERE " + CRLF
	cQy += "	D2_FILIAL IN('0101', '0301', '0401', '0501', '0601', '0701', '0801', '0901', '1001', '1101', '1201', '1301') " + CRLF // AVISO retirar a filial '0101', esta sendo usada apenas como teste
	cQy += "	AND D2_EMISSAO BETWEEN '" + cIni + "' AND '" + cFim + "' " + CRLF
	cQy += "	AND SD2.D_E_L_E_T_ = '' " + CRLF
	cQy += "	AND SF4.F4_DUPLIC = 'S' " + CRLF
return cQy

/*/{Protheus.doc} queryFrete
	Funcao que monta a query do resumo de comissao
	@type static function
	@author Julio Carvalho Barberino
	@since 15/12/2025
	@version 0
/*/
static function queryFrete(dIni, dFim)
	local cQy
	local cIni		:= dToS(dIni)
	local cFim		:= dToS(dFim)

	cQy := "SELECT " + CRLF
	cQy += "	SUM(D2_COMIS1) AS SUM_COMIS1, " + CRLF
	cQy += "	SUM(D2_COMIS2) AS SUM_COMIS2 " + CRLF
	cQy += "FROM " + CRLF
	cQy += "	" + RetSQLName("SD2") + " SD2 " + CRLF
	cQy += "	INNER JOIN " + RetSQLName("SF4") + " SF4 " + CRLF
	cQy += "	ON D2_TES = F4_CODIGO " + CRLF
	cQy += "	AND " + FWJoinFilial("SD2", "SF4") + " " + CRLF
	cQy += "WHERE " + CRLF
	cQy += "	D2_FILIAL IN('0101', '0301', '0401', '0501', '0601', '0701', '0801', '0901', '1001', '1101', '1201', '1301') " + CRLF // AVISO retirar a filial '0101', esta sendo usada apenas como teste
	cQy += "	AND D2_EMISSAO BETWEEN '" + cIni + "' AND '" + cFim + "' " + CRLF
	cQy += "	AND SD2.D_E_L_E_T_ = '' " + CRLF
	cQy += "	AND SF4.F4_DUPLIC = 'S' " + CRLF
return cQy

/*/{Protheus.doc} printTab
	Funcao que imprime tabela
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function printTab(nRowInicio, nColInicio, nRowHeight, aWidth, aAlign, aFields, aData, oPrinterRec)
	local nRowCount		:= 1
	local nColCount		:= 1
	local nRow_0		:= nRowInicio
	local nCol_0		:= nColInicio
	local nCol_1
	local nMargemCel	:= 3
	local oArial08		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 8 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial08b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 8 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)

	if valType(aFields) != "U"
		for nColCount := 1 to len(aFields)
			nCol_1 := nCol_0 + aWidth[nColCount]
			oPrinterRec:Box(nRow_0, nCol_0, nRow_0 - nRowHeight, nCol_1, "-2")
			oPrinterRec:SayAlign(nRow_0 - nRowHeight, nCol_0 + nMargemCel, aFields[nColCount], oArial08b, aWidth[nColCount] - 2 * nMargemCel, nRowHeight, , 2, 0)
			nCol_0 := nCol_1
		next
	else
		nRow_0 -= nRowHeight
	endIf

	nCol_0 := nColInicio
	for nRowCount := 1 to len(aData)
		nRow_0 += nRowHeight
		for nColCount := 1 to len(aData[nRowCount])
			nCol_1 := nCol_0 + aWidth[nColCount]
			oPrinterRec:Box(nRow_0, nCol_0, nRow_0 - nRowHeight, nCol_1, "-2")
			oPrinterRec:SayAlign(nRow_0 - nRowHeight, nCol_0 + nMargemCel, aData[nRowCount][nColCount], oArial08, aWidth[nColCount] - 2 * nMargemCel, nRowHeight, , aAlign[nColCount], 0)
			nCol_0 := nCol_1
		next
		nCol_0 := nColInicio
	next
return

/*/{Protheus.doc} cabFama
	Funcao que imprime cabeçalho molas Fama
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function cabFama(oPrinterRec, nPagina, nPaginaTot)
	local nRowBase1		:= 76
	local nColBase1		:= 4
	local nWidthCab		:= 586
	local nDeltaY1		:= 19.5
	local nDeltaY2		:= 17
	local oArial18b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 18 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial15		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 15 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial08		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 8 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial11		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 11 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local cPagina		:= "Pagina " + cValToChar(nPagina) + "/" + cValToChar(nPaginaTot)
	local cStamp		:= "Impresso em "+ dToC(Date()) + " - " + Time()

	oPrinterRec:Box(nRowBase1 + 0, nColBase1, nRowBase1 + nDeltaY1 + nDeltaY2 + 60 - 40.5, nColBase1 + nWidthCab, "-2")
	oPrinterRec:SayAlign(nRowBase1 - 20, nColBase1, cPagina, oArial08, nWidthCab, 20, , PAD_CENTER_H, 1)
	oPrinterRec:SayAlign(nRowBase1 - 20, nColBase1 + round(nWidthCab / 2, 0), cStamp, oArial08, round(nWidthCab / 2, 0), 20, , PAD_RIGHT, 2)
	oPrinterRec:SayAlign(nRowBase1 + 0, nColBase1, "M O L A S   F A M A", oArial18b, nWidthCab, 30, , PAD_CENTER_H, 2)
	oPrinterRec:SayAlign(nRowBase1 + nDeltaY1, nColBase1, "FAMA DO BRASIL IND DE MOLAS E AUTO PECAS LTDA", oArial15, nWidthCab, nDeltaY1, , PAD_CENTER_H, 2)
	oPrinterRec:SayAlign(nRowBase1 + nDeltaY1 + nDeltaY2, nColBase1, "ROD. BR 376 KM 232, S/N SAIDA P/ MARINGA - CAIXA POSTAL 917, APUCARANA/PR - Fone: (43) 3420-9000 Fax: (43) 3420-9001", oArial11, nWidthCab, nDeltaY2, , PAD_CENTER_H, 2)
	oPrinterRec:SayBitmap(nRowBase1 + 0, nColBase1, "\testeLogo.bmp", 90, 36)
	oPrinterRec:SayBitmap(nRowBase1 + 0, nColBase1 + nWidthCab - 90, "\testeLogo.bmp", 90, 36)
return

/*/{Protheus.doc} rodaPeC5
	Funcao que imprime rodapé
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function rodaPeC5(nRowBase1, nColBase1, oPrinterRec, cPedido, cAliasC5)
	local nWidth		:= 586
	local nDeltaY1		:= 10
	local oArial11		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 11 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local cEmissao		:= cValToChar(sToD((cAliasC5)->EMISSAO))
	local cDtEntrega	:= cValToChar(sToD((cAliasC5)->DT_ENTREG))
	local cVendedor		:= cValToChar((cAliasC5)->REPRESENTANTE)

	oPrinterRec:Box(nRowBase1 , nColBase1, nRowBase1 + 2 * nDeltaY1 + 2, nColBase1 + nWidth, "-2")
	oPrinterRec:SayAlign(nRowBase1 , nColBase1, "Data de emissão: " + cEmissao, oArial11, nWidth, nDeltaY1, , PAD_LEFT, 2)
	oPrinterRec:SayAlign(nRowBase1 , nColBase1 + 220, "Pedido: " + cPedido, oArial11, nWidth, nDeltaY1, , PAD_LEFT, 2)
	oPrinterRec:SayAlign(nRowBase1 + nDeltaY1, nColBase1, "Estimativa de entrega: " + cDtEntrega, oArial11, nWidth, nDeltaY1, , PAD_LEFT, 2)
	oPrinterRec:SayAlign(nRowBase1 + nDeltaY1, nColBase1 + 220, "Representante: " + cVendedor, oArial11, nWidth, nDeltaY1, , PAD_LEFT, 2)
return

/*/{Protheus.doc} rodaPeFim
	Funcao que imprime roda pé final
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function rodaPeFim(oPrinterRec, cAliasC5, cAliasC9)
	local nRowBase1		:= 713
	local nColBase1		:= 4
	local nWidthPe		:= 586
	local nDeltaY1		:= 10
	local nWidSign		:= 255
	local cDataLib
	local oArial18b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 18 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial14		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 14 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)

	oPrinterRec:Box(nRowBase1 + 0, nColBase1, nRowBase1 + 6 * nDeltaY1 + 12, nColBase1 + nWidthPe, "-2")
	oPrinterRec:SayAlign(nRowBase1 + 0, nColBase1, "Observações", oArial18b, nWidthPe, 30, , PAD_CENTER_H, 2)
	oPrinterRec:SayAlign(nRowBase1 + 1 * nDeltaY1, nColBase1, "* Frete pago até São Paulo.", oArial14, nWidthPe, 30, , PAD_LEFT, 2)
	oPrinterRec:SayAlign(nRowBase1 + 2 * nDeltaY1, nColBase1, "* As mercadorias viajam por conta e risco do comprado.", oArial14, nWidthPe, 30, , PAD_LEFT, 2)
	oPrinterRec:SayAlign(nRowBase1 + 3 * nDeltaY1, nColBase1, "* Não aceitaremos devoluções posteriores", oArial14, nWidthPe, 30, , PAD_LEFT, 2)
	oPrinterRec:SayAlign(nRowBase1 + 4 * nDeltaY1, nColBase1, "* Consideramos o Pedido aceito caso não tenhamos um retorno documentando em 24 horas!", oArial14, nWidthPe, 30, , PAD_LEFT, 2)
	oPrinterRec:SayAlign(nRowBase1 + 5 * nDeltaY1, nColBase1, "* Os impostos, se incidentes, serão acrecidos quando do faturamento, observada a aliquota vigente na data e no estado!", oArial14, nWidthPe, 30, , PAD_LEFT, 2)

	oPrinterRec:Line(nRowBase1 + 110, nColBase1, nRowBase1 + 110, nColBase1 + nWidSign, , "-2" )
	oPrinterRec:SayAlign(nRowBase1 + 110, nColBase1, "Aprovação do cliente Data: ", oArial18b, nWidSign, 30, , PAD_CENTER_H, 2)

	oPrinterRec:SayAlign(nRowBase1 + 92, nColBase1 + nWidthPe - nWidSign, cValToChar((cAliasC5)->REPRESENTANTE), oArial18b, nWidSign, 30, , PAD_CENTER_H, 2)
	oPrinterRec:Line(nRowBase1 + 110, nColBase1 + nWidthPe - nWidSign, nRowBase1 + 110, nColBase1 + nWidthPe, , "-2" )
	cDataLib := cValToChar(sTod(((cAliasC9)->C9_DATALIB)))
	oPrinterRec:SayAlign(nRowBase1 + 110, nColBase1 + nWidthPe - nWidSign, "Análise crítica - Data: " + cDataLib, oArial18b, nWidSign, 30, , PAD_CENTER_H, 2)
return

/*/{Protheus.doc} cabC5
	Funcao que imprime cabeçalho do PV
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function cabC5(nRowBase1, nColBase1, oPrinterRec, cAliasC5)

	local nWidthCab		:= 590
	local nDeltaY1		:= 10
	local oArial12b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 12 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial12		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 12 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)

	oPrinterRec:Box(nRowBase1 + 00, nColBase1 + 4, nRowBase1 + 51, nColBase1 + nWidthCab, "-2")
	oPrinterRec:Say(nRowBase1 + nDeltaY1, nColBase1 + 8, "Cliente: ", oArial12b, 15,,)
	oPrinterRec:Say(nRowBase1 + nDeltaY1, nColBase1 + 8 + 53, (cAliasC5)->CLI_NOME, oArial12, 15,,)
	oPrinterRec:Say(nRowBase1 + 2 * nDeltaY1, nColBase1 + 8, "Endereço", oArial12b, 15,,)
	oPrinterRec:Say(nRowBase1 + 2 * nDeltaY1, nColBase1 + 8 + 53, (cAliasC5)->CLI_ENDERECO, oArial12, 15,,)
	oPrinterRec:Say(nRowBase1 + 2 * nDeltaY1, nColBase1 + 480, "Cep: ", oArial12b, 15,,)
	oPrinterRec:Say(nRowBase1 + 2 * nDeltaY1, nColBase1 + 480 + 46 - 18, Alltrim(Transform((cAliasC5)->CLI_CEP, "@R 99999-999")), oArial12, 15,,)
	oPrinterRec:Say(nRowBase1 + 3 * nDeltaY1, nColBase1 + 8, "Cidade: ", oArial12b, 15,,)
	oPrinterRec:Say(nRowBase1 + 3 * nDeltaY1, nColBase1 + 8 + 53, (cAliasC5)->CLI_MUNICIPIO, oArial12, 15,,)
	oPrinterRec:Say(nRowBase1 + 3 * nDeltaY1, nColBase1 + 300, "Estado: ", oArial12b, 0,,)
	oPrinterRec:Say(nRowBase1 + 3 * nDeltaY1, nColBase1 + 338, (cAliasC5)->CLI_UF, oArial12, 0,,)
	oPrinterRec:Say(nRowBase1 + 3 * nDeltaY1, nColBase1 + 408, "Fone/Fax: ", oArial12b, 15,,)
	oPrinterRec:Say(nRowBase1 + 3 * nDeltaY1, nColBase1 + 408 + 46 + 15, Alltrim(Transform((cAliasC5)->CLI_TELEFONE, "@R (99) 9 9999-9999")), oArial12, 15,,)
	oPrinterRec:Say(nRowBase1 + 4 * nDeltaY1, nColBase1 + 8, "CNPJ: ", oArial12b, 15,,)
	oPrinterRec:Say(nRowBase1 + 4 * nDeltaY1, nColBase1 + 8 + 53, Alltrim(Transform((cAliasC5)->CLI_CNPJ, "@R 99.999.999/9999-99")), oArial12, 15,,)
	oPrinterRec:Say(nRowBase1 + 4 * nDeltaY1, nColBase1 + 8 + 194, "Inscrição: ", oArial12b, 15,,)
	oPrinterRec:Say(nRowBase1 + 4 * nDeltaY1, nColBase1 + 249, (cAliasC5)->CLI_IE, oArial12, 15,,)
	oPrinterRec:Say(nRowBase1 + 4 * nDeltaY1, nColBase1 + 357, "E-mail: ", oArial12b, 15,,)
	oPrinterRec:Say(nRowBase1 + 4 * nDeltaY1, nColBase1 + 392, (cAliasC5)->CLI_EMAIL, oArial12, 15,,)
return

/*/{Protheus.doc} aGroupBy
	Funcao que agrupa
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function aGroupBy(aDados2D as array, nGroupeBy as Numeric)
	local aGroup2D			:= {} As Array
	local cGroupText		:= "" As Character
	local nFoundPos			:= 0 As Numeric
	local nDadosPos			:= 0 As Numeric
	local nCol
	local aQuant

	For nDadosPos := 1 To Len(aDados2D)
		cGroupText := iif(nGroupeBy != 0, aDados2D[nDadosPos][nGroupeBy], "")
		aQuant := {}

		for nCol := 1 to len(aDados2D[nDadosPos])
			aAdd(aQuant, aDados2D[nDadosPos][nCol])
		next

		nFoundPos := 0
		if Len(aGroup2D) > 0
			nFoundPos := aScan(aGroup2D, iif(nGroupeBy != 0, {|y| y[nGroupeBy] == cGroupText}, {|y| .T.}))
		endIf

		if nFoundPos == 0
			aAdd(aGroup2D, aQuant)
		Else
			for nCol := 1 to len(aDados2D[nDadosPos])
				if nCol != nGroupeBy .and. valType(aDados2D[nDadosPos][nCol]) == "N"
					aGroup2D[nFoundPos][nCol] += aQuant[nCol]
				else
					aGroup2D[nFoundPos][nCol] := aQuant[nCol]
				endIf
			next
		endIf
	Next
return aGroup2D

/*/{Protheus.doc} aSelByIndx
	Funcao que seleciona colunas
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function aSelByIndx(aOrig2D, aIndex)
	local aRet		:= {}
	local aItem		:= {}
	local nRow
	local nCol
	local nIndex

	for nRow := 1 to len(aOrig2D)
		aItem := {}
		for nIndex := 1 to len(aIndex)
			for nCol := 1 to len(aOrig2D[nRow])
				if aIndex[nIndex] == nCol
					aAdd(aItem, aOrig2D[nRow, nCol])
				endIf
			next
		next
		aAdd(aRet, aItem)
	next
return aRet

/*/{Protheus.doc} aToStr
	Funcao que transforma em string
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function aToStr(aDados2D, aMascara)
	local nRow
	local nCol
	local aRet := aClone(aDados2D)

	for nRow := 1 to len(aDados2D)
		for nCol := 1 to len(aDados2D[nRow])
			if valType(aDados2D[nRow, nCol]) == "N"
				aRet[nRow, nCol] := iif(!empty(aMascara[nCol]), Alltrim(Transform(aDados2D[nRow, nCol], aMascara[nCol])), Alltrim(cValToChar(aDados2D[nRow, nCol])))
			elseIf valType(aDados2D[nRow, nCol]) == "D"
				aRet[nRow, nCol] := allTrim(dToC(aDados2D[nRow, nCol]))
			elseIf valType(aDados2D[nRow, nCol]) == "C"
				aRet[nRow, nCol] := allTrim(aDados2D[nRow, nCol])
			endIf
		next
	next
return aRet

/*/{Protheus.doc} nSomaCol
	Funcao que soma coluna
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function nSomaCol(aDados2D, nCampo)
	local nRow		:= 0
	local nSoma		:= 0

	for nRow := 1 to len(aDados2D)
		if valType(aDados2D[nRow, nCampo]) == "N"
			nSoma += aDados2D[nRow, nCampo]
		endIf
	next
return nSoma

/*/{Protheus.doc} aImparPar
	Funcao que separa condicoes de pagamento esquerda direita
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function aImparPar(aRec)
	local aOri		:= aClone(aRec)
	local nRow		:= 0
	local aImpar	:= {}
	local aPar		:= {}
	for nRow := 1 to len(aOri)
		if nRow % 2 == 1
			aAdd(aImpar, aOri[nRow])
		else
			aAdd(aPar, aOri[nRow])
		endIf
	next
return {aImpar, aPar}

/*/{Protheus.doc} aEnumera
	Funcao que cria coluna enumerada
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function aEnumera(aOri, nShift)
	local aRet		:= {}
	local nRow		:= 0
	local nCol		:= 0

	for nRow := 1 to len(aOri)
		aAdd(aRet, {nRow + nShift})
		for nCol := 1 to len(aOri[nRow])
			aAdd(aRet[nRow], aOri[nRow, nCol])
		next
	next
return aRet

/*/{Protheus.doc} grade
	Funcao que imprime grade
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function grade(nRowBase, nColBase, aHeights, aWidths, oPrinterRec)
	local nHeiTot	:= 0
	local nWidTot	:= 0
	local nI
	local nHeiAux	:= 0
	local nWidAux	:= 0

	for nI := 1 to len(aHeights)
		nHeiTot += aHeights[nI]
	next
	for nI := 1 to len(aWidths)
		nWidTot += aWidths[nI]
	next

	oPrinterRec:Line(nRowBase, nColBase, nRowBase, nColBase + nWidTot, , "-2" )
	for nI := 1 to len(aHeights)
		nHeiAux += aHeights[nI]
		oPrinterRec:Line(nRowBase + nHeiAux, nColBase, nRowBase + nHeiAux, nColBase + nWidTot, , "-2" )
	next

	oPrinterRec:Line(nRowBase, nColBase, nRowBase + nHeiTot, nColBase, , "-2" )
	for nI := 1 to len(aWidths)
		nWidAux += aWidths[nI]
		oPrinterRec:Line(nRowBase, nColBase + nWidAux, nRowBase + nHeiTot, nColBase + nWidAux, , "-2" )
	next
return

/*/{Protheus.doc} grade
	Funcao que pivoteia uma tabela
	@type static function
	@author Julio Carvalho Barberino
	@since 08/12/2025
	@version 0
/*/
static function aPivot2D(aEntrada, nOrdLin, nOrdCol, nColTarget)
	local aColunas	:= aGroupBy(aSelByIndx(aEntrada, {nOrdCol}), 1)
	local aLinhas	:= aGroupBy(aSelByIndx(aEntrada, {nOrdLin}), 1)
	local aPivotado	:= {}
	local nEnt		:= 1
	local nRow		:= 1
	local nCol		:= 1

	for nRow := 1 to len(aLinhas)
		aAdd(aPivotado, {})
		for nCol := 1 to len(aColunas)
			aAdd(aPivotado[nRow], 0)
			for nEnt := 1 to len(aEntrada)
				if aEntrada[nEnt, nOrdCol] == aColunas[nCol, 1] .and. aEntrada[nEnt, nOrdLin] == aLinhas[nRow, 1]
					aPivotado[nRow, nCol] := aEntrada[nEnt, nColTarget]
				endIf
			next
		next
	next
return aPivotado

static function aAppendCol(aTabOriE, aTabOriD)
	local aRet := aClone(aTabOriE)
	local nRow
	local nCol

	for nRow := 1 to len(aRet)
		for nCol := 1 to len(aTabOriD[nRow])
			aAdd(aRet[nRow], aTabOriD[nRow, nCol])
		next
	next
return aRet

static function aAppendLin(aTabOriUp, aTabOriDow)
	local aRet := aClone(aTabOriUp)
	local nRow

	for nRow := 1 to len(aTabOriDow)
		aAdd(aRet, aTabOriDow[nRow])
	next
return aRet

static function aTranspose(aRec)
	local aRet := {}
	local nCol
	local nRow

	for nCol := 1 to len(aRec[1])
		aAdd(aRet, {})
		for nRow := 1 to len(aRec)
			aAdd(aRet[nCol], aRec[nRow, nCol])
		next
	next
return aRet
