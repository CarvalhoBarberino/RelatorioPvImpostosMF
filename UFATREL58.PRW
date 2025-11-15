#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDef.ch"

#DEFINE TESTE_PDF		.T. // True significa que o fonte está sendo utilizado em testes e não usa a impressora, usa apenas a visualização em PDF, pois nos testes em homologação não é possível usar a impressora
//#DEFINE MOSTRA_QUERY
//#DEFINE MOSTRA_GRADE
#DEFINE IMP_SPOOL		2
#DEFINE IMP_PDF			6
#DEFINE SEM_SETUP		.T.
#DEFINE VIEW_PDF		.T.
#DEFINE NOME_DO_FONTE	"UFATREL58.PRW"
#DEFINE PAD_LEFT		0
#DEFINE PAD_RIGHT		1
#DEFINE PAD_CENTER_H	2
#DEFINE PAD_CENTER_V	0
#DEFINE PAD_TOP			1
#DEFINE PAD_BOTTOM		2

#DEFINE DADOS_IT_C5_NUM				1
#DEFINE DADOS_IT_C6_NFORI			2
#DEFINE DADOS_IT_C6_SERIORI			3
#DEFINE DADOS_IT_SB1_REC			4
#DEFINE DADOS_IT_ITEM				5
#DEFINE DADOS_IT_DESCON				6
#DEFINE DADOS_IT_QUANT				7
#DEFINE DADOS_IT_EMB				8
#DEFINE DADOS_IT_UNIDADE			9
#DEFINE DADOS_IT_CODIGO_FAMA		10
#DEFINE DADOS_IT_B1_PESO			11
#DEFINE DADOS_IT_C6_PRODUTO			12
#DEFINE DADOS_IT_C6_TES				13
#DEFINE DADOS_IT_DESCRICAO			14
#DEFINE DADOS_IT_B1_GRUPO			15
#DEFINE DADOS_IT_C6_VALDESC			16
#DEFINE DADOS_IT_VALOR_UNI			17
#DEFINE DADOS_IT_VALOR_TOTAL		18
#DEFINE DADOS_IT_C5_FRETE			19
#DEFINE DADOS_IT_IT_ALIQIPI			20
#DEFINE DADOS_IT_IT_VALIPI			21
#DEFINE DADOS_IT_IT_VALSOL			22
#DEFINE DADOS_IT_VALOR_C_IMPOSTOS	23
#DEFINE DADOS_IT_PESO_TOTAL			24
#DEFINE DADOS_IT_GRUPO_COD			25
#DEFINE DADOS_IT_GRUPO_DESCRI		26
#DEFINE DADOS_IT_DESCONTOS			27
#DEFINE DADOS_IT_C5_CONDPAG			28
#DEFINE DADOS_IT_E4_DESCRI			29
#DEFINE DADOS_IT_DESCONTOS_UMOLART	30

user function UFATREL58()
	local oPrinter
	local cNomeDoArquivo	:= "teste.pdf"
	//local oArial25			:= TFont():New( "Arial",,25,.t.,.T.,,,,,.f. )
	//local oArial15			:= TFont():New( "Arial",,15,.t.,.T.,,,,,.f. )
	//local oArial10			:= TFont():New( "Arial",,10,.t.,.T.,,,,,.f. )
	local cPedido			:= "000011" //	"000011"	"000014"	"000055"	"000031"	"000015"	"000057"
	//local cUFilial			:= "01" //	"01"		"0101"		"0101"		"0101"		"0101"		"0101"
	local cQy
	local cAliasC5			:= "REL58C5"
	local cAliasC6			:= "REL58C6"
	local cAliasC9			:= "REL58C9"
	local aImprimirIt		:= {}
	local aCampos			:= {}
	local aMedidas			:= {}
	local aAlinhamento		:= {}
	local aImprimir			:= {}
	local cArea				:= FWGetArea()
	local nRowBase1			:= 0
	local nColBase1			:= 0
	//local nRowBase2			:= 0
	//local nColBase2			:= 0
	local nI				:= 0
	//local aImpostos			:= {}
	local aDados
	local aDadosIt
	local aGrupPrd
	local aGrupPrd1
	local aGrupPrdS
	local aGrupPrd2
	local aDupl

	cPedido := FWInputBox("Digite o pedido:", cPedido)

	cQy := "SELECT " + CRLF
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
	cQy += "	A3_COD + ' - ' + A3_NOME AS REPRESENTANTE, " + CRLF
	cQy += "	C5_TPFRETE, " + CRLF
	cQy += "	C5_FRETE, " + CRLF
	cQy += "	C5_SEGURO, " + CRLF
	cQy += "	C5_DESPESA, " + CRLF
	cQy += "	C5_DESCONT, " + CRLF
	cQy += "	C5_PDESCAB, " + CRLF
	cQy += "	C5_FRETAUT, " + CRLF
	cQy += "	C5_TRANSP " + CRLF
	cQy += "FROM " + CRLF
	cQy += "	" + RetSQLName("SC5") + " SC5 " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SA1") + " SA1 " + CRLF
	cQy += "		ON C5_CLIENTE = A1_COD " + CRLF
	cQy += "		AND C5_LOJACLI = A1_LOJA " + CRLF
	cQy += "		AND A1_FILIAL = '" + FWxFilial("SA1") + "' " + CRLF
	cQy += "		AND SA1.D_E_L_E_T_ = '' " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SC6") + " SC6 " + CRLF
	cQy += "		ON C5_NUM = C6_NUM " + CRLF
	cQy += "		AND C6_FILIAL = '" + FWxFilial("SC6") + "' " + CRLF
	cQy += "		AND SC6.D_E_L_E_T_ = '' " + CRLF
	cQy += "	LEFT JOIN " + CRLF
	cQy += "		" + RetSQLName("SA3") + " SA3 " + CRLF
	cQy += "		ON C5_VEND1 = A3_COD " + CRLF
	cQy += "		AND A3_FILIAL = '" + FWxFilial("SA3") + "' " + CRLF
	cQy += "		AND SA3.D_E_L_E_T_ = '' " + CRLF
	cQy += "WHERE " + CRLF
	cQy += "	C5_NUM = '" + cPedido + "' " + CRLF
	cQy += "	AND C5_FILIAL = '" + FWxFilial("SC5") + "' " + CRLF
	cQy += "	AND SC5.D_E_L_E_T_ = '' " + CRLF
	#IFDEF MOSTRA_QUERY
		showLog(cQy)
	#ENDIF
	if select(cAliasC5) > 0
		dbSelectArea(cAliasC5)
		(cAliasC5)->(dbCloseArea())
	ENDIF
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasC5, .F., .T.)
	dbSelectArea(cAliasC5)
	(cAliasC5)->(dbGoTop())
	if (cAliasC5)->(eOF())
		MsgAlert("O pedido não foi encontrado", NOME_DO_FONTE)
		FWRestArea(cArea)
		return
	endIf

	cQy := "SELECT " + CRLF
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
	cQy += "	'C6_UDCIDP + C6_UDCVEND + C6_UDCGPPD + C6_UDCCLI' AS DESCONTOS, " + CRLF
	cQy += "	C5_CONDPAG, " + CRLF
	cQy += "	E4_DESCRI, " + CRLF
	cQy += "	'SBM_UMOLART' AS DESCONTOS_UMOLART " + CRLF
	cQy += "FROM " + CRLF
	cQy += "	" + RetSQLName("SC5") + " SC5 " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SC6") + " SC6 " + CRLF
	cQy += "		ON C5_NUM = C6_NUM " + CRLF
	cQy += "		AND C6_FILIAL = '" + FWxFilial("SC6") + "' " + CRLF
	cQy += "		AND SC6.D_E_L_E_T_ = '' " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SB1") + " SB1 " + CRLF
	cQy += "		ON C6_PRODUTO = B1_COD " + CRLF
	cQy += "		AND B1_FILIAL = '" + FWxFilial("SB1") + "' " + CRLF
	cQy += "		AND SB1.D_E_L_E_T_ = '' " + CRLF
	cQy += "	LEFT JOIN " + CRLF
	cQy += "		" + RetSQLName("SBM") + " SBM " + CRLF
	cQy += "		ON B1_GRUPO = BM_GRUPO " + CRLF
	cQy += "		AND BM_FILIAL = '" + FWxFilial("SBM") + "' " + CRLF
	cQy += "		AND SBM.D_E_L_E_T_ = '' " + CRLF
	cQy += "	LEFT JOIN " + CRLF
	cQy += "		" + RetSQLName("SE4") + " SE4 " + CRLF
	cQy += "		ON C5_CONDPAG = E4_CODIGO " + CRLF
	cQy += "		AND E4_FILIAL = '" + FWxFilial("SE4") + "' " + CRLF
	cQy += "		AND SE4.D_E_L_E_T_ = '' " + CRLF
	cQy += "WHERE " + CRLF
	cQy += "	C5_NUM = '" + cPedido + "' " + CRLF
	cQy += "	AND C5_FILIAL = '" + FWxFilial("SC5") + "' " + CRLF
	cQy += "	AND SC5.D_E_L_E_T_ = '' " + CRLF
	cQy += "ORDER BY " + CRLF
	cQy += "	C5_NUM, C6_ITEM " + CRLF
	#IFDEF MOSTRA_QUERY
		showLog(cQy)
	#ENDIF
	if select(cAliasC6) > 0
		dbSelectArea(cAliasC6)
		(cAliasC6)->(dbCloseArea())
	ENDIF
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasC6, .F., .T.)
	dbSelectArea(cAliasC6)
	(cAliasC6)->(dbGoTop())
	if (cAliasC6)->(eOF())
		MsgAlert("O pedido não foi encontrado", NOME_DO_FONTE)
		FWRestArea(cArea)
		return
	endIf

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
	cQy += "		AND A1_FILIAL = '" + FWxFilial("SA1") + "' " + CRLF
	cQy += "		AND SA1.D_E_L_E_T_ = '' " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SC6") + " SC6 " + CRLF
	cQy += "		ON C5_NUM = C6_NUM " + CRLF
	cQy += "		AND C6_FILIAL = '" + FWxFilial("SC6") + "' " + CRLF
	cQy += "		AND SC6.D_E_L_E_T_ = '' " + CRLF
	cQy += "	INNER JOIN " + CRLF
	cQy += "		" + RetSQLName("SC9") + " SC9 " + CRLF
	cQy += "		ON C6_NUM = C9_PEDIDO " + CRLF
	cQy += "		AND C6_PRODUTO = C9_PRODUTO " + CRLF
	cQy += "		AND C6_ITEM = C9_ITEM " + CRLF
	cQy += "		AND C9_FILIAL = '" + FWxFilial("SC9") + "' " + CRLF
	cQy += "		AND SC9.D_E_L_E_T_ = '' " + CRLF
	cQy += "WHERE " + CRLF
	cQy += "	C5_NUM = '" + cPedido + "' " + CRLF
	cQy += "	AND C5_FILIAL = '" + FWxFilial("SC5") + "' " + CRLF
	cQy += "	AND SC5.D_E_L_E_T_ = '' " + CRLF
	cQy += "ORDER BY " + CRLF
	cQy += "	C5_NUM, C9_DATALIB DESC " + CRLF
	#IFDEF MOSTRA_QUERY
		showLog(cQy)
	#ENDIF
	if select(cAliasC9) > 0
		dbSelectArea(cAliasC9)
		(cAliasC9)->(dbCloseArea())
	ENDIF
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,ChangeQuery(cQy)), cAliasC9, .F., .T.)
	dbSelectArea(cAliasC9)
	(cAliasC9)->(dbGoTop())
	if (cAliasC9)->(eOF())
		MsgAlert("Não existem datas de liberação para este pedido", NOME_DO_FONTE)
	endIf

	MaFisIni(;
		(cAliasC5)->C5_CLIENTE, ;
		(cAliasC5)->C5_LOJACLI, ;
		Iif((cAliasC5)->C5_TIPO $ "D;B", "F", "C"), ;
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
	If (cAliasC5)->C5_DESCONT > 0
		MaFisAlt(;
			"NF_DESCONTO", ;
			Min(MaFisRet(, "NF_VALMERC")-0.01, (cAliasC5)->C5_DESCONT+MaFisRet(, "NF_DESCONTO"));
			)
	EndIf
	If (cAliasC5)->C5_PDESCAB > 0
		MaFisAlt(;
			"NF_DESCONTO", ;
			A410Arred(MaFisRet(, "NF_VALMERC") * (cAliasC5)->C5_PDESCAB / 100, "C6_VALOR") + MaFisRet(, "NF_DESCONTO");
			)
	EndIf

	nI := 0
	aImprimir := {}
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
		aAdd(aDados, aDadosIt)

		aImprimirIt := {}
		aAdd(aImprimirIt, (cAliasC6)->ITEM)
		aAdd(aImprimirIt, Alltrim(Transform((cAliasC6)->DESCON, "@E 99.99")))
		aAdd(aImprimirIt, cValToChar((cAliasC6)->QUANT))
		aAdd(aImprimirIt, cValToChar((cAliasC6)->EMB))
		aAdd(aImprimirIt, (cAliasC6)->UNIDADE)
		aAdd(aImprimirIt, Alltrim((cAliasC6)->CODIGO_FAMA))
		aAdd(aImprimirIt, Alltrim((cAliasC6)->DESCRICAO))
		aAdd(aImprimirIt, Alltrim(Transform((cAliasC6)->VALOR_UNI, "@E 9,999.99")))
		aAdd(aImprimirIt, Alltrim(Transform((cAliasC6)->VALOR_TOTAL, "@E 99,999.99")))
		aAdd(aImprimirIt, Alltrim(Transform(aDadosIt[DADOS_IT_IT_ALIQIPI], "@E 99.99")))
		aAdd(aImprimirIt, Alltrim(Transform(aDadosIt[DADOS_IT_IT_VALIPI], "@E 9,999.99")))
		aAdd(aImprimir, aImprimirIt)

		(cAliasC6)->(dbSkip())
	endDo

	MaFisEnd()

	#IFDEF MOSTRA_QUERY
		if !MsgYesNo("Continuar o programa?", NOME_DO_FONTE)
			FWRestArea(cArea)
			return
		endIf
	#ENDIF

	oPrinter := FWMsPrinter():New(;
		cNomeDoArquivo /*cFilePrintert*/, ;
		iif(TESTE_PDF, IMP_PDF, IMP_SPOOL) /*nDevice*/, ;
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
	cabFama(@oPrinter, 1 /*nPaginaAtual*/, 2 /*nPaginaTotal*/)
	cabC5(@oPrinter, cAliasC5)

	aCampos := {"Item", "%Desc", "Qtde Ped.", "Emb", "Un", "Código Fama", "Descrição", "Valor unitário", "Valor Total", "%IPI", "Valor IPI"}
	aMedidas := {29, 38, 38, 33, 24, 65, 176, 52, 57, 29, 45}
	aAlinhamento := {PAD_CENTER_H, PAD_RIGHT, PAD_CENTER_H, PAD_CENTER_H, PAD_CENTER_H, PAD_CENTER_H, PAD_LEFT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
	printTab(nRowBase1 + 221, nColBase1 + 4, 10, aMedidas, aAlinhamento, aCampos, aImprimir, @oPrinter)

	#IFDEF MOSTRA_QUERY
		showLog(VarInfo("aDados", aDados, , .F.))
	#ENDIF

	aGrupPrd := aGroupBy(aDados, DADOS_IT_GRUPO_DESCRI)
	#IFDEF MOSTRA_QUERY
		showLog(VarInfo("aGroupBy", aGrupPrd, , .F.))
	#ENDIF
	aGrupPrd1 := aSelByIndx(aGrupPrd, {;
		DADOS_IT_GRUPO_DESCRI, ;
		DADOS_IT_C6_VALDESC, ;
		DADOS_IT_VALOR_TOTAL, ;
		DADOS_IT_IT_VALIPI, ;
		DADOS_IT_IT_VALSOL, ;
		DADOS_IT_VALOR_C_IMPOSTOS, ;
		DADOS_IT_PESO_TOTAL, ;
		DADOS_IT_QUANT ;
		})
	#IFDEF MOSTRA_QUERY
		showLog(VarInfo("aGrupPrd1", aGrupPrd1, , .F.))
	#ENDIF

	aGrupPrdS := aSelByIndx(aGrupPrd1, {2, 3, 4, 5, 6, 7, 8})
	aGrupPrdS := aGroupBy(aGrupPrdS, 0)
	aGrupPrdS := aToStr(aGrupPrdS, {"", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99"})
	aGrupPrdS[1,1] := "Totais"
	#IFDEF MOSTRA_QUERY
		showLog(VarInfo("aGrupPrdS", aGrupPrdS, , .F.))
	#ENDIF

	(cAliasC9)->(dbGoTop())
	aDupl := Condicao(nSomaCol(aGrupPrd1, 6), (cAliasC5)->CONDICAO_PAG, , sToD(/*(cAliasC5)->DT_ENTREG*/(cAliasC9)->C9_DATALIB))
	aDupl := aEnumera(aDupl, 0)
	aDupl := aImparPar(aClone(aDupl))
	#IFDEF MOSTRA_QUERY
		showLog(VarInfo("aDupl", aDupl, , .F.))
	#ENDIF
	
	rodaPeC5(nRowBase1 + 447, nColBase1 + 4, oPrinter, cPedido, (cAliasC5)->EMISSAO, (cAliasC5)->DT_ENTREG, (cAliasC5)->REPRESENTANTE)

	aGrupPrd1 := aToStr(aGrupPrd1, {"", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99"})
	#IFDEF MOSTRA_QUERY
		showLog(VarInfo("aGrupPrd1", aGrupPrd1, , .F.))
	#ENDIF
	aCampos := {"Grupo", "Descontos", "Valor Liquido", "Valor IPI", "Valor ST", "Total c/ impostos", "Peso(kg)", "Qtde"}
	aMedidas := {154, 54, 74, 56, 56, 93, 54, 41}
	aAlinhamento := {PAD_LEFT, PAD_LEFT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
	printTab(nRowBase1 + 487, nColBase1 + 4, 10, aMedidas, aAlinhamento, aCampos, aGrupPrd1, @oPrinter)

	aMedidas := {208, 74, 56, 56, 93, 54, 41}
	aAlinhamento := {PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
	printTab(nRowBase1 + 487 + (len(aGrupPrd1) + 1) * 10, nColBase1 + 4, 10, aMedidas, aAlinhamento, , aGrupPrdS, @oPrinter)

	aGrupPrd2 := aSelByIndx(aGrupPrd, {;
		DADOS_IT_GRUPO_DESCRI, ;
		DADOS_IT_E4_DESCRI})
	#IFDEF MOSTRA_QUERY
		showLog(VarInfo("aGrupPrd2", aGrupPrd2, , .F.))
	#ENDIF
	aGrupPrd2 := aToStr(aGrupPrd2, {"", ""})
	#IFDEF MOSTRA_QUERY
		showLog(VarInfo("aGrupPrd2", aGrupPrd2, , .F.))
	#ENDIF
	aCampos := {"Grupo", "Cond. Pagamento"}
	aMedidas := {154, 70}
	aAlinhamento := {PAD_LEFT, PAD_RIGHT}
	printTab(nRowBase1 + 584, nColBase1 + 4, 10, aMedidas, aAlinhamento, aCampos, aGrupPrd2, @oPrinter)

	aCampos := {"Nº", "Vencimento", "Valor"}
	aMedidas := {20, 80, 38}
	aAlinhamento := {PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
	printTab(nRowBase1 + 584, nColBase1 + 238, 10, aMedidas, aAlinhamento, aCampos, aToStr(aDupl[1], {"@E 9", "", "@E 99,999.99"}), @oPrinter)
	printTab(nRowBase1 + 584, nColBase1 + 376, 10, aMedidas, aAlinhamento, aCampos, aToStr(aDupl[2], {"@E 9", "", "@E 99,999.99"}), @oPrinter)
	rodaPeFim(@oPrinter, cAliasC5, cAliasC9)

	#IFDEF MOSTRA_GRADE
		oPrinter:Box(500, 500, 600, 600, "-2")
		oPrinter:Say(600, 600, "600x600", oArial10, 15,,)
		oPrinter:Box(400, 400, 500, 500, "-2")
		oPrinter:Say(500, 500, "500x500", oArial10, 15,,)
		oPrinter:Box(300, 300, 400, 400, "-2")
		oPrinter:Say(400, 400, "400x400", oArial10, 15,,)
		oPrinter:Box(200, 200, 300, 300, "-2")
		oPrinter:Say(300, 300, "300x300", oArial10, 15,,)
		oPrinter:Box(100, 100, 200, 200, "-2")
		oPrinter:Say(200, 200, "200x200", oArial10, 15,,)
		oPrinter:Box(700, 100, 730, 300, "-2")
		oPrinter:SayAlign(700, 100, "TEXTO", oArial10, 200, 30, , PAD_CENTER_H, )
	#ENDIF

	oPrinter:EndPage()
	If TESTE_PDF
		MsgAlert("com TESTE_PDF ", NOME_DO_FONTE)
		oPrinter:Setup()
		oPrinter:Preview()
	Else
		oPrinter:Print()
	EndIf
	FreeObj(oPrinter)
	oPrinter := Nil
	FWRestArea(cArea)
return

// lib

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

	oPrinterRec:Box(nRowBase1 + 0, nColBase1, nRowBase1 + nDeltaY1 + nDeltaY2 + 60, nColBase1 + nWidthCab, "-2")
	oPrinterRec:SayAlign(nRowBase1 - 20, nColBase1, cPagina, oArial08, nWidthCab, 20, , PAD_CENTER_H, 1)
	oPrinterRec:SayAlign(nRowBase1 - 20, nColBase1 + round(nWidthCab / 2, 0), cStamp, oArial08, round(nWidthCab / 2, 0), 20, , PAD_RIGHT, 2)
	oPrinterRec:SayAlign(nRowBase1 + 0, nColBase1, "M O L A S   F A M A", oArial18b, nWidthCab, 30, , PAD_CENTER_H, 2)
	oPrinterRec:SayAlign(nRowBase1 + nDeltaY1, nColBase1, "FAMA DO BRASIL IND DE MOLAS E AUTO PECAS LTDA", oArial15, nWidthCab, nDeltaY1, , PAD_CENTER_H, 2)
	oPrinterRec:SayAlign(nRowBase1 + nDeltaY1 + nDeltaY2, nColBase1, "ROD. BR 376 KM 232, S/N SAIDA P/ MARINGA - CAIXA POSTAL 917, APUCARANA/PR - Fone: (43) 3420-9000 Fax: (43) 3420-9001", oArial11, nWidthCab, nDeltaY2, , PAD_CENTER_H, 2)
	oPrinterRec:SayBitmap(nRowBase1 + 0, nColBase1, "\testeLogo.bmp", 90, 36)
	oPrinterRec:SayBitmap(nRowBase1 + 0, nColBase1 + nWidthCab - 90, "\testeLogo.bmp", 90, 36)

return

static function rodaPeC5(nRowBase1, nColBase1, oPrinterRec, cPedido, cEmissao, cDtEntrega, cVendedor)
	local nWidth		:= 586
	local nDeltaY1		:= 10
	local oArial11		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 11 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)

	cEmissao := cValToChar(sToD(cEmissao))
	cDtEntrega := cValToChar(sToD(cDtEntrega))
	oPrinterRec:Box(nRowBase1 , nColBase1, nRowBase1 + 2 * nDeltaY1 + 2, nColBase1 + nWidth, "-2")
	oPrinterRec:SayAlign(nRowBase1 , nColBase1, "Data de emissão: " + cEmissao, oArial11, nWidth, nDeltaY1, , PAD_LEFT, 2)
	oPrinterRec:SayAlign(nRowBase1 , nColBase1 + 220, "Pedido: " + cPedido, oArial11, nWidth, nDeltaY1, , PAD_LEFT, 2)
	oPrinterRec:SayAlign(nRowBase1 + nDeltaY1, nColBase1, "Estimativa de entrega: " + cDtEntrega, oArial11, nWidth, nDeltaY1, , PAD_LEFT, 2)
	oPrinterRec:SayAlign(nRowBase1 + nDeltaY1, nColBase1 + 220, "Representante: " + cVendedor, oArial11, nWidth, nDeltaY1, , PAD_LEFT, 2)
return

static function rodaPeFim(oPrinterRec, cAliasC5, cAliasC9)
	local nRowBase1		:= 640
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

	oPrinterRec:Line(nRowBase1 + 130, nColBase1, nRowBase1 + 130, nColBase1 + nWidSign, , "-2" )
	oPrinterRec:SayAlign(nRowBase1 + 130, nColBase1, "Aprovação do cliente Data: ", oArial18b, nWidSign, 30, , PAD_CENTER_H, 2)

	oPrinterRec:SayAlign(nRowBase1 + 112, nColBase1 + nWidthPe - nWidSign, (cAliasC5)->REPRESENTANTE, oArial18b, nWidSign, 30, , PAD_CENTER_H, 2)
	oPrinterRec:Line(nRowBase1 + 130, nColBase1 + nWidthPe - nWidSign, nRowBase1 + 130, nColBase1 + nWidthPe, , "-2" )
	cDataLib := cValToChar(sTod(((cAliasC9)->C9_DATALIB)))
	oPrinterRec:SayAlign(nRowBase1 + 130, nColBase1 + nWidthPe - nWidSign, "Análise crítica - Data: " + cDataLib, oArial18b, nWidSign, 30, , PAD_CENTER_H, 2)
return

static function cabC5(oPrinterRec, cAliasC5)

	local nRowBase1		:= 132
	local nColBase1		:= 0
	local nWidthCab		:= 590
	local nDeltaY1		:= 10
	local oArial18b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 18 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
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
	oPrinterRec:SayAlign(nRowBase1 + 4 * nDeltaY1 + 9, nColBase1, "Pedido", oArial18b, nWidthCab, 16, , PAD_CENTER_H, 2)

return

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
		If Len(aGroup2D) > 0
			nFoundPos := aScan(aGroup2D, iif(nGroupeBy != 0, {|y| y[nGroupeBy] == cGroupText}, {|y| .T.}))
		EndIf

		If nFoundPos == 0
			aAdd(aGroup2D, aQuant)
		Else
			for nCol := 1 to len(aDados2D[nDadosPos])
				if nCol != nGroupeBy .and. valType(aDados2D[nDadosPos][nCol]) == "N"
					aGroup2D[nFoundPos][nCol] += aQuant[nCol]
				endIf
			next
		EndIf
	Next
return aGroup2D

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
			endIf
		next
	next
return aRet

static function nSomaCol(aDados2D, nCampo)
	local nRow		:= 0
	local nSoma		:= 0

	for nRow := 1 to len(aDados2D)
		if valType(aDados2D[nRow, nCampo]) == "N"
			nSoma += aDados2D[nRow, nCampo]
		endIf
	next
return nSoma

static function aImparPar(aOri)
	local nRow			:= 0
	local aImpar		:= {}
	local aPar			:= {}
	for nRow := 1 to len(aOri)
		if nRow % 2 == 1
			aAdd(aImpar, aOri[nRow])
		else
			aAdd(aPar, aOri[nRow])
		endIf
	next
return {aImpar, aPar}

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

