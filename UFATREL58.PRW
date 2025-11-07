#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDef.ch"

#DEFINE TESTE_PDF		.T. // True significa que o fonte está sendo utilizado em testes e não usa a impressora, usa apenas a visualização em PDF, pois nos testes em homologação não é possível usar a impressora
//#DEFINE MOSTRA_QUERY
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
	local aAlinhamento		:= {}
	local aDados			:= {}
	local cArea				:= getArea()
	local nRowBase1			:= 0
	local nColBase1			:= 0
	local nRowBase2			:= 0
	local nColBase2			:= 0

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
	aMedidas := {29, 38, 38, 33, 24, 66, 177, 53, 58, 29, 45}
	aAlinhamento := {2, 1, 2, 2, 2, 2, 0, 1, 1, 1, 1}
	while !(cAliasC6)->(eOF())
		aDadosIt := {}
		aAdd(aDadosIt, (cAliasC6)->ITEM)
		aAdd(aDadosIt, Alltrim(Transform((cAliasC6)->DESCON, "@E 99.99")))
		aAdd(aDadosIt, cValToChar((cAliasC6)->QUANT))
		aAdd(aDadosIt, cValToChar((cAliasC6)->EMB))
		aAdd(aDadosIt, (cAliasC6)->UNIDADE)
		aAdd(aDadosIt, (cAliasC6)->CODIGO_FAMA)
		aAdd(aDadosIt, (cAliasC6)->DESCRICAO)
		aAdd(aDadosIt, Alltrim(Transform((cAliasC6)->VALOR_UNI, "@E 9.999,99")))
		aAdd(aDadosIt, Alltrim(Transform((cAliasC6)->VALOR_TOTAL, "@E 99.999,99")))
		aAdd(aDadosIt, Alltrim(Transform((cAliasC6)->IPI_PORCENT, "@E 99.99")))
		aAdd(aDadosIt, Alltrim(Transform((cAliasC6)->IPI_VAL, "@E 9.999,99")))
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
	oPrinter:SetMargin(3,10,3,10) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:cPathPDF := "C:\TEMP\" // Caso seja utilizada impressï¿½o em IMP_SPOOL
	oPrinter:StartPage()

	nRowBase1 := 0
	nColBase1 := 0
	nColBase2 := 590
	oPrinter:Box(nRowBase1 + 76, nColBase1 + 4, nRowBase1 + 136, nColBase1 + nColBase2, "-2")
	oPrinter:SayAlign(nRowBase1 + 76, nColBase1 + 4, "MOLAS FAMA", oArial15, nColBase2, 30, , 2, 2)
	oPrinter:SayAlign(nRowBase1 + 93, nColBase1 + 4, "FAMA DO BRASIL IND DE MOLAS E AUTO PECAS LTDA", oArial15, nColBase2, 30, , 2, 2)
	oPrinter:SayAlign(nRowBase1 + 106, nColBase1 + 4, "ROD. BR 376 KM 232, S/N SAIDA P/ MARINGA - CAIXA POSTAL 917, APUCARANA/PR - Fone: (43) 3420-9000 Fax: (43) 3420-9001", oArial15, nColBase2, 30, , 2, 2)

	nRowBase1 := 160
	nColBase1 := 0
	nColBase2 := 590
	oPrinter:Box(nRowBase1 + 00, nColBase1 + 4, nRowBase1 + 83, nColBase1 + nColBase2, "-2")
	oPrinter:Say(nRowBase1 + 12, nColBase1 + 8, "Cliente: ", oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 12, nColBase1 + 8 + 46, (cAliasC5)->CLI_NOME, oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 32, nColBase1 + 8, "Endereço", oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 32, nColBase1 + 8 + 46 + 12, (cAliasC5)->CLI_ENDERECO, oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 32, nColBase1 + 480, "Cep: ", oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 32, nColBase1 + 480 + 46 - 18, Alltrim(Transform((cAliasC5)->CLI_CEP, "@R 99999-999")), oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 52, nColBase1 + 8, "Cidade: ", oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 52, nColBase1 + 8 + 46, (cAliasC5)->CLI_MUNICIPIO, oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 52, nColBase1 + 300, "Estado: ", oArial15, 0,,)
	oPrinter:Say(nRowBase1 + 52, nColBase1 + 300 + 46, (cAliasC5)->CLI_UF, oArial15, 0,,)
	oPrinter:Say(nRowBase1 + 52, nColBase1 + 408, "Fone/Fax: ", oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 52, nColBase1 + 408 + 46 + 15, Alltrim(Transform((cAliasC5)->CLI_TELEFONE, "@R (99) 9 9999-9999")), oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 72, nColBase1 + 8, "CNPJ: ", oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 72, nColBase1 + 8 + 46 - 10, Alltrim(Transform((cAliasC5)->CLI_CNPJ, "@R 99.999.999/9999-99")), oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 72, nColBase1 + 319, "Inscrição estadual: ", oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 72, nColBase1 + 319 + 46 + 64, (cAliasC5)->CLI_IE, oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 72, nColBase1 + 357, "E-mail: ", oArial15, 15,,)
	oPrinter:Say(nRowBase1 + 72, nColBase1 + 357 + 46, (cAliasC5)->CLI_EMAIL, oArial15, 15,,)

	jukTab(nRowBase1 + 123, nColBase1 + 4, 25, aMedidas, aAlinhamento, aCampos, aDados, @oPrinter, @oArial15)

	#IFDEF MOSTRA_QUERY
		oPrinter:Box(500, 500, 600, 600, "-2")
		oPrinter:Say(600, 600, "600x600", oArial15, 15,,)
		oPrinter:Box(400, 400, 500, 500, "-2")
		oPrinter:Say(500, 500, "500x500", oArial15, 15,,)
		oPrinter:Box(300, 300, 400, 400, "-2")
		oPrinter:Say(400, 400, "400x400", oArial15, 15,,)
		oPrinter:Box(200, 200, 300, 300, "-2")
		oPrinter:Say(300, 300, "300x300", oArial15, 15,,)
		oPrinter:Box(100, 100, 200, 200, "-2")
		oPrinter:Say(200, 200, "200x200", oArial15, 15,,)
		oPrinter:Box(700, 10, 700 + 20, 300, "-2")
		oPrinter:SayAlign(700, 10, "align:700x10x300", oArial15, 300, 20, , 2, 2)
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
	restArea(cArea)
return

static function jukTab(nRowInicio, nColInicio, nRowHeight, aWidth, aAlign, aFields, aData, oPrinterRec, oFontRec)
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
			oPrinterRec:SayAlign(nRow_0 - nRowHeight, nCol_0, aData[nRowCount][nColCount], oFontRec, aWidth[nColCount], nRowHeight, , aAlign[nColCount], 0)
			nCol_0 := nCol_1
		next
		nCol_0 := nColInicio
	next

return
