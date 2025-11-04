#INCLUDE "protheus.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDef.ch"

#DEFINE TESTE_PDF		.T. // True significa que o fonte está sendo utilizado em testes e não usa a impressora, usa apenas a visualização em PDF, pois nos testes em homologação não é possível usar a impressora
#DEFINE IMP_SPOOL		2
#DEFINE IMP_PDF			6
#DEFINE SEM_SETUP		.T.
#DEFINE VIEW_PDF		.T.
#DEFINE NOME_DO_FONTE	"UFATREL58.PRW"

user function UFATREL58()
	local oPrinter
	local cNomeDoArquivo	:= "teste.pdf"
	local oArial25			:= TFont():New( "Arial",,25,.t.,.T.,,,,,.f. )
	local aDados			:= {}
	local aCampos			:= {}
	local aMedida			:= {}
	local aDados			:= {}

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
	oPrinter:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:cPathPDF := "C:\TEMP\" // Caso seja utilizada impressï¿½o em IMP_SPOOL
	oPrinter:StartPage()
	/*
	aCampor := {"Item", "% Desc.", "Qtde Ped."}
	aMedidas := {150, 200, 200}
	aDados := {{"1", "10%", "200"}}
	*/
	aCampos := {"Item", "% Desc.", "Qtde Ped."}
	aMedidas := {40, 50, 60}
	aDados := {{"1", "10%", "200"}, {"2", "9%", "300"}, {"3", "10%", "200"}, {"4", "15%", "150"}}

	tabela(100, 100, 25, aMedidas, aCampos, aDados, oPrinter, oArial25)

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
return

static function tabela(nRowInicio, nColInicio, nRowHeight, aWidth, aFields, aData, oPrinterRec, oFontRec)
	local nRowCount		:= 1
	local nColCount		:= 1
	local nRow_0		:= nRowInicio
	local nCol_0		:= nColInicio
	local nRow_1
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
