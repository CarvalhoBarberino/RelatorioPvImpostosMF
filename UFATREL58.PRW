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
#DEFINE PAD_LEFT		0
#DEFINE PAD_RIGHT		1
#DEFINE PAD_CENTER_H	2
#DEFINE PAD_CENTER_V	0
#DEFINE PAD_TOP			1
#DEFINE PAD_BOTTOM		2
#DEFINE IPI_VAL			1
#DEFINE IPI_PORCENT		2
#DEFINE VALSOL			3

user function UFATREL58()
	local oPrinter
	local cNomeDoArquivo	:= "teste.pdf"
	local oArial25			:= TFont():New( "Arial",,25,.t.,.T.,,,,,.f. )
	local oArial15			:= TFont():New( "Arial",,15,.t.,.T.,,,,,.f. )
	local oArial10			:= TFont():New( "Arial",,10,.t.,.T.,,,,,.f. )
	local cPedido			:= "000009" // "000009"		"000014"
	local cFilial			:= "01" // 	"01"		"0101"
	local cQy
	local cAliasC5			:= "REL58C5"
	local cAliasC6			:= "REL58C6"
	local aDadosIt			:= {}
	local aCampos			:= {}
	local aMedidas			:= {}
	local aAlinhamento		:= {}
	local aDados			:= {}
	local cArea				:= FWGetArea()
	local nRowBase1			:= 0
	local nColBase1			:= 0
	local nRowBase2			:= 0
	local nColBase2			:= 0
	local nI				:= 0
	local aImpostos			:= {}

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
	cQy += "	C5_FRETE " + CRLF
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
	if (cAliasC6)->(eOF())
		MsgAlert("O pedido não foi encontrado", NOME_DO_FONTE)
		FWRestArea(cArea)
		return
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
		"MATA461" /*Nome da rotina que esta utilizando a funcao*/;
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
	(cAliasC6)->(dbGoTop())
	aImpostos := {}
	while !(cAliasC6)->(eOF())
		nI++
		aAdd(aImpostos, {})
		aAdd(aImpostos[nI], grupo)
		aAdd(aImpostos[nI], descontos)
		aAdd(aImpostos[nI], valorliquido)
		aAdd(aImpostos[nI], MaFisRet(nI, "IT_ALIQIPI"))
		aAdd(aImpostos[nI], MaFisRet(nI, "IT_VALIPI"))
		aAdd(aImpostos[nI], MaFisRet(nI, "IT_VALSOL"))
		aAdd(aImpostos[nI], totalcomimpostos)
		aAdd(aImpostos[nI], pwsoliquido)
		aAdd(aImpostos[nI], quantidade)
		(cAliasC6)->(dbSkip())
		showLog("IPI_VAL: " + cValToChar((cAliasC6)->IPI_VAL) + CRLF + "IPI_PORCENT: " + cValToChar((cAliasC6)->IPI_PORCENT) + CRLF + "VALSOL: " + cValToChar((cAliasC6)->VALSOL))
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

	aDados := {}
	(cAliasC6)->(dbGoTop())
	while !(cAliasC6)->(eOF())
		aDadosIt := {}
		aAdd(aDadosIt, (cAliasC6)->ITEM)
		aAdd(aDadosIt, Alltrim(Transform((cAliasC6)->DESCON, "@E 99.99")))
		aAdd(aDadosIt, cValToChar((cAliasC6)->QUANT))
		aAdd(aDadosIt, cValToChar((cAliasC6)->EMB))
		aAdd(aDadosIt, (cAliasC6)->UNIDADE)
		aAdd(aDadosIt, Alltrim((cAliasC6)->CODIGO_FAMA))
		aAdd(aDadosIt, Alltrim((cAliasC6)->DESCRICAO))
		aAdd(aDadosIt, Alltrim(Transform((cAliasC6)->VALOR_UNI, "@E 9.999,99")))
		aAdd(aDadosIt, Alltrim(Transform((cAliasC6)->VALOR_TOTAL, "@E 99.999,99")))
		aAdd(aDadosIt, Alltrim(Transform((cAliasC6)->IPI_PORCENT, "@E 99.99")))
		aAdd(aDadosIt, Alltrim(Transform((cAliasC6)->IPI_VAL, "@E 9.999,99")))
		aAdd(aDados, aDadosIt)
		(cAliasC6)->(dbSkip())
	endDo

	aCampos := {"Item", "%Desc", "Qtde Ped.", "Emb", "Un", "Código Fama", "Descrição", "Valor unitário", "Valor Total", "%IPI", "Valor IPI"}
	aMedidas := {29, 38, 38, 33, 24, 65, 176, 52, 57, 29, 45}
	aAlinhamento := {PAD_CENTER_H, PAD_RIGHT, PAD_CENTER_H, PAD_CENTER_H, PAD_CENTER_H, PAD_CENTER_H, PAD_LEFT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT, PAD_RIGHT}
	itensC6(nRowBase1 + 221, nColBase1 + 4, 10, aMedidas, aAlinhamento, aCampos, aDados, @oPrinter)

	#IFDEF MOSTRA_QUERY
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

static function itensC6(nRowInicio, nColInicio, nRowHeight, aWidth, aAlign, aFields, aData, oPrinterRec)
	local nRowCount		:= 1
	local nColCount		:= 1
	local nRow_0		:= nRowInicio
	local nCol_0		:= nColInicio
	local nCol_1
	local nMargemCel	:= 3
	local oArial08		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 8 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial08b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 8 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)

	for nColCount := 1 to len(aFields)
		nCol_1 := nCol_0 + aWidth[nColCount]
		oPrinterRec:Box(nRow_0, nCol_0, nRow_0 - nRowHeight, nCol_1, "-2")
		oPrinterRec:SayAlign(nRow_0 - nRowHeight, nCol_0 + nMargemCel, aFields[nColCount], oArial08b, aWidth[nColCount] - 2 * nMargemCel, nRowHeight, , 2, 0)
		nCol_0 := nCol_1
	next

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
	local nLarguraCab	:= 586
	local nDeltaY1		:= 19.5
	local nDeltaY2		:= 17
	local oArial18b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 18 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial15		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 15 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial08		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 8 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial11		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 11 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local cPagina		:= "Pagina " + cValToChar(nPagina) + "/" + cValToChar(nPaginaTot)
	local cStamp		:= "Impresso em "+ dToC(Date()) + " - " + Time()

	oPrinterRec:Box(nRowBase1 + 0, nColBase1, nRowBase1 + nDeltaY1 + nDeltaY2 + 60, nColBase1 + nLarguraCab - 4, "-2")
	oPrinterRec:SayAlign(nRowBase1 - 20, nColBase1, cPagina, oArial08, nLarguraCab, 20, , PAD_CENTER_H, 1)
	oPrinterRec:SayAlign(nRowBase1 - 20, nColBase1 + round(nLarguraCab / 2, 0), cStamp, oArial08, round(nLarguraCab / 2, 0), 20, , PAD_RIGHT, 2)
	oPrinterRec:SayAlign(nRowBase1 + 0, nColBase1, "M O L A S   F A M A", oArial18b, nLarguraCab, 30, , PAD_CENTER_H, 2)
	oPrinterRec:SayAlign(nRowBase1 + nDeltaY1, nColBase1, "FAMA DO BRASIL IND DE MOLAS E AUTO PECAS LTDA", oArial15, nLarguraCab, nDeltaY1, , PAD_CENTER_H, 2)
	oPrinterRec:SayAlign(nRowBase1 + nDeltaY1 + nDeltaY2, nColBase1, "ROD. BR 376 KM 232, S/N SAIDA P/ MARINGA - CAIXA POSTAL 917, APUCARANA/PR - Fone: (43) 3420-9000 Fax: (43) 3420-9001", oArial11, nLarguraCab, nDeltaY2, , PAD_CENTER_H, 2)

return

static function cabC5(oPrinterRec, cAliasC5)

	local nRowBase1		:= 132
	local nColBase1		:= 0
	local nLarguraCab	:= 586
	local nDeltaY1		:= 10
	local oArial18b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 18 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial12b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 12 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial12		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 12 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)

	oPrinterRec:Box(nRowBase1 + 00, nColBase1 + 4, nRowBase1 + 51, nColBase1 + nLarguraCab, "-2")
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
	oPrinterRec:SayAlign(nRowBase1 + 4 * nDeltaY1 + 17, nColBase1, "Pedido", oArial18b, nLarguraCab, 16, , PAD_CENTER_H, 2)

return


