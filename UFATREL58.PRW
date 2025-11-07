#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDef.ch"

#DEFINE TESTE_PDF		.T. // True significa que o fonte está sendo utilizado em testes e não usa a impressora, usa apenas a visualização em PDF, pois nos testes em homologação não é possível usar a impressora
#DEFINE MOSTRA_QUERY
#DEFINE IMP_SPOOL		2
#DEFINE IMP_PDF			6
#DEFINE SEM_SETUP		.T.
#DEFINE VIEW_PDF		.T.
#DEFINE NOME_DO_FONTE	"UFATREL58.PRW"

user function UFATREL58()
	local oPrinter
	local cNomeDoArquivo	:= "teste.pdf"
	local oArial25			:= TFont():New( "Arial",,25,.t.,.T.,,,,,.f. )
	local oArial15			:= TFont():New( "Arial",,15,.t.,.T.,,,,,.f. )
	local cPedido			:= "000014" // "000009"		"000014"
	local cFilial			:= "0101" // 	"01"		"0101"
	local cQy
	local cAliasC5			:= "REL58C5"
	local cAliasC6			:= "REL58C6"
	local aDadosIt			:= {}
	local aCampos			:= {}
	local aMedidas			:= {}
	local aDados			:= {}
	local cArea				:= getArea()

	cPedido := FWInputBox("Digite o pedido:", cPedido)

	cQy := "SELECT " + CRLF
	cQy += "	C5_NUM, " + CRLF
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
	cQy += "	END AS DATA_ENTREGA, " + CRLF
	cQy += "	CASE " + CRLF
	cQy += "		WHEN C5_FECENT <> '' " + CRLF
	cQy += "		THEN 'C5_FECENT' " + CRLF
	cQy += "		ELSE " + CRLF
	cQy += "			CASE " + CRLF
	cQy += "				WHEN C5_SUGENT <> '' " + CRLF
	cQy += "				THEN 'C5_SUGENT' " + CRLF
	cQy += "				ELSE 'C6_ENTREG' " + CRLF
	cQy += "			END " + CRLF
	cQy += "	END AS DATA_ENTREGA_ORI, " + CRLF
	cQy += "	A3_COD + ' - ' + A3_NOME AS REPRESENTANTE, " + CRLF
	cQy += "	C5_TPFRETE, " + CRLF
	cQy += "	C5_FRETE, " + CRLF
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

	cQy := "SELECT " + CRLF
	cQy += "	C5_NUM, " + CRLF
	cQy += "	C6_ITEM AS ITEM, " + CRLF
	cQy += "	C6_DESCONT AS DESCON, " + CRLF
	cQy += "	C6_QTDVEN AS QUANT, " + CRLF
	cQy += "	B1_QE AS EMB, " + CRLF
	cQy += "	C6_UM AS UNIDADE, " + CRLF
	cQy += "	B1_COD AS CODIGO_FAMA, " + CRLF
	cQy += "	B1_DESC AS DESCRICAO, " + CRLF
	cQy += "	C6_PRCVEN AS VALOR_UNI, " + CRLF
	cQy += "	C6_VALOR AS VALOR_TOTAL, " + CRLF
	cQy += "	0.00 AS IPI_PORCENT, " + CRLF
	cQy += "	0.00 AS IPI_VAL " + CRLF
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
	aDados := {}
	aCampos := {"Item", "%Desc", "Qtde Ped.", "Emb", "Un", "Código Fama", "Descrição", "Valor unitário", "Valor Total", "%IPI", "Valor IPI"}
	aMedidas := {23, 30, 30, 30, 15, 46, 108, 38, 38, 15, 23}
	while !(cAliasC6)->(eOF())
		aDadosIt := {}
		aAdd(aDadosIt, (cAliasC6)->ITEM)
		aAdd(aDadosIt, cValToChar((cAliasC6)->DESCON))
		aAdd(aDadosIt, cValToChar((cAliasC6)->QUANT))
		aAdd(aDadosIt, cValToChar((cAliasC6)->EMB))
		aAdd(aDadosIt, (cAliasC6)->UNIDADE)
		aAdd(aDadosIt, (cAliasC6)->CODIGO_FAMA)
		aAdd(aDadosIt, (cAliasC6)->DESCRICAO)
		aAdd(aDadosIt, cValToChar((cAliasC6)->VALOR_UNI))
		aAdd(aDadosIt, cValToChar((cAliasC6)->VALOR_TOTAL))
		aAdd(aDadosIt, cValToChar((cAliasC6)->IPI_PORCENT))
		aAdd(aDadosIt, cValToChar((cAliasC6)->IPI_VAL))
		aAdd(aDados, aDadosIt)
		(cAliasC6)->(dbSkip())
	endDo

	#IFDEF MOSTRA_QUERY
		if !MsgYesNo("Continuar o programa?", NOME_DO_FONTE)
			restArea(cArea)
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
	oPrinter:SetMargin(10,10,10,10) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:cPathPDF := "C:\TEMP\" // Caso seja utilizada impressï¿½o em IMP_SPOOL
	oPrinter:StartPage()

	oPrinter:Say(200, 100, (cAliasC5)->CLI_NOME, oArial15, 15,,)
	oPrinter:Say(220, 100, (cAliasC5)->CLI_ENDERECO, oArial15, 15,,)
	oPrinter:Say(220, 500, (cAliasC5)->CLI_CEP, oArial15, 15,,)
	oPrinter:Say(240, 100, (cAliasC5)->CLI_MUNICIPIO, oArial15, 15,,)
	oPrinter:Say(240, 300, (cAliasC5)->CLI_UF, oArial15, 15,,)
	oPrinter:Say(240, 500, (cAliasC5)->CLI_TELEFONE, oArial15, 15,,)
	oPrinter:Say(260, 100, (cAliasC5)->CLI_CNPJ, oArial15, 15,,)
	oPrinter:Say(260, 200, (cAliasC5)->CLI_IE, oArial15, 15,,)
	oPrinter:Say(260, 400, (cAliasC5)->CLI_EMAIL, oArial15, 15,,)

	jukTab(500, 100, 25, aMedidas, aCampos, aDados, @oPrinter, @oArial15)

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
	restArea(cArea)
return

static function jukTab(nRowInicio, nColInicio, nRowHeight, aWidth, aFields, aData, oPrinterRec, oFontRec)
	local nRowCount		:= 1
	local nColCount		:= 1
	local nRow_0		:= nRowInicio
	local nCol_0		:= nColInicio
	//local nRow_1
	local nCol_1

	for nColCount := 1 to len(aFields)
		nCol_1 := nCol_0 + aWidth[nColCount]
		oPrinterRec:Box(nRow_0, nCol_0, nRow_0 - nRowHeight, nCol_1, "-2")
		oPrinterRec:Say(nRow_0, nCol_0, aFields[nColCount], oFontRec, nRowHeight,,)
		nCol_0 := nCol_1
	next

	nCol_0 := nColInicio
	for nRowCount := 1 to len(aData)
		nRow_0 += nRowHeight
		for nColCount := 1 to len(aData[nRowCount])
			nCol_1 := nCol_0 + aWidth[nColCount]
			oPrinterRec:Box(nRow_0, nCol_0, nRow_0 - nRowHeight, nCol_1, "-2")
			oPrinterRec:Say(nRow_0, nCol_0, aData[nRowCount][nColCount], oFontRec, nRowHeight,,)
			nCol_0 := nCol_1
		next
		nCol_0 := nColInicio
	next

return
