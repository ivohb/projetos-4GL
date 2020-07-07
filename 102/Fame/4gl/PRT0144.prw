
//http://advpl-protheus.blogspot.com.br/2011/03/conectar-o-protheus-outra-base-de-dados.html

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณu_PRT0144 บAutor  ณDouglas Gregorio    บ Data ณ  13/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Integrao RH com Cont bil ERP Oracle                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Cliente Toyota                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PRT0144()
Local cPerg	:= "MV_PRT144"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณChama a funo de perguntas  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX1_0144(cPerg)
If !Pergunte(cPerg,.T.)
	Return
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicia di logo de progresso do processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Processa({|| PrPRT144()},"Processamento sendo executado...","Realizando consulta na movimenta็ใo contแbil")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |PrPRT144  บAutor  ณDouglas Gregorio    บ Data ณ  29/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Processamento                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPRT0144                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PrPRT144()
Local cQuery	  := "" 
Local cQryInsert  := ""
Local cQryValues  := ""
Local cQryFlag	  := ""
Local cQryPRT144  := ""
Local lRet		  := .T.
Local nHndConOra  := Nil
Local nHndConERP  := AdvConnection()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณScript de consulta tabela de lanamento de contas Protheus CT2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Consulta a tabela CT2
cQuery += " SELECT CT2.CT2_FILIAL,CT2.CT2_CCC,CT2.CT2_CREDIT,CT2.CT2_ITEMC,CT2.CT2_CCD,CT2.CT2_DEBITO,CT2.CT2_ITEMD,"
cQuery += "	CT2.CT2_VALOR,CT2.CT2_DATA,CT2.CT2_HIST,CT2.R_E_C_N_O_"
cQuery += " FROM "+RETSQLNAME("CT2")+" CT2 "
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND CT2.CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cQuery += " AND CT2.CT2_ENVORA <> 'S'" 		//Caso seja criado flag para marcar como Enviado, tirar coment rios

//Executa filtros de Filiais
If !Empty(MV_PAR03) .AND. Empty(MV_PAR04)
	cQuery += "    AND CT2.CT2_FILIAL = '"+MV_PAR04+"' "
ElseIf !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
	cQuery += "    AND CT2.CT2_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria tabela tempor ria de movimentao de contasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
VerTabela("TMPRT0144")
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPRT0144",.F.,.T.)
ProcRegua(RecCount())
TMPRT0144->(DbGoTop())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLoop de processamento da rotina               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do While !TMPRT0144->(EOF())
	dDataMovto := cValToChar(STOD(TMPRT0144->CT2_DATA))
	cContaCont := Iif(!Empty(AllTrim(TMPRT0144->CT2_CREDIT)),TMPRT0144->CT2_CREDIT,TMPRT0144->CT2_DEBITO)
	IncProc(" Data da movimenta็ใo: " + dDataMovto + CRLF + "      Conta sendo processada: " +cContaCont)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtribuio dos valores para query de incluso ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_STATUS		:= "NEW"
	LEDGER_ID	:= "2021"
	ACCOU_DATE	:= TMPRT0144->CT2_DATA
	CURRE_CODE	:= "BRL"
	DATE_CREAT	:= dDatabase
	CREATED_BY	:= "1137"
	ACTUA_FLAG	:= "A"
	USER_JE_CN	:= "TBDB - Folha"
	USER_JE_SN	:= "TBDB - Folha"
	SEGMENT1	:= "5002"
	SEGMENT4	:= "00"
	SEGMENT6	:= "0000"
	SEGMENT7	:= "00000"
	TRANS_DATE	:= TMPRT0144->CT2_DATA
	REFERENC10	:= TMPRT0144->CT2_HIST
	PERIO_NAME	:= MesExtenso(SUBSTR(Alltrim(TMPRT0144->CT2_DATA),5,2))+"-"+SUBSTR(Alltrim(TMPRT0144->CT2_DATA),3,2)
	CHART_A_ID	:= "50348"
	SET_BOOKID	:= "2021"
	
	nHndConOra  := ConectaSvr()
	If nHndConOra < 0
		lRet := .F.
		Exit
	ElseIf !Empty(Alltrim(TMPRT0144->CT2_CREDIT)) .And. !Empty(Alltrim(TMPRT0144->CT2_DEBITO))  //so vamos considerar partida dobrada 
		
		//--------CREDITO------------------------------------------------------------
		SEGMENT2	 := TMPRT0144->CT2_CCC
		SEGMENT3	 := TMPRT0144->CT2_CREDIT
		SEGMENT5	 := TMPRT0144->CT2_ITEMC
		ENTERED_DR	 := "0"
		ENTERED_CR	 := cValToChar(TMPRT0144->CT2_VALOR)
		ACCOUNT_DR	 := "0"
		ACCOUNT_CR   := cValToChar(TMPRT0144->CT2_VALOR)

     	//para as contas que iniciam com 1,2 o centro de custo deverแ vir zerado
	    IF SUBSTR(AllTrim(SEGMENT3),1,1) == '1' .Or. SUBSTR(AllTrim(SEGMENT3),1,1) == '2'
			SEGMENT2 := "000"
			SEGMENT5 := "000"
		Endif
		
		IncProc("Data da movimenta็ใo: " + dDataMovto + CRLF + "        Conta sendo importada: " + cContaCont )
		cQryInsert := ""
		cQryInsert += "INSERT INTO GL_INTERFACE ("
		cQryInsert += "STATUS"
		cQryInsert += ", LEDGER_ID"
		cQryInsert += ", ACCOUNTING_DATE"
		cQryInsert += ", CURRENCY_CODE"
		cQryInsert += ", DATE_CREATED"
		cQryInsert += ", CREATED_BY"
		cQryInsert += ", ACTUAL_FLAG"
		cQryInsert += ", USER_JE_CATEGORY_NAME"
		cQryInsert += ", USER_JE_SOURCE_NAME"
		//	cQryInsert += ", CURRENCY_CONVERSION_DATE"
		//	cQryInsert += ", ENCUMBRANCE_TYPE_ID"
		//	cQryInsert += ", BUDGET_VERSION_ID"
		//	cQryInsert += ", USER_CURRENCY_CONVERSION_TYPE"
		//	cQryInsert += ", CURRENCY_CONVERSION_RATE"
		//	cQryInsert += ", AVERAGE_JOURNAL_FLAG"
		//	cQryInsert += ", ORIGINATING_BAL_SEG_VALUE"
		cQryInsert += ", SEGMENT1"
		cQryInsert += ", SEGMENT2"
		cQryInsert += ", SEGMENT3"
		cQryInsert += ", SEGMENT4"
		cQryInsert += ", SEGMENT5"
		cQryInsert += ", SEGMENT6"
		cQryInsert += ", SEGMENT7"
		//	cQryInsert += ", SEGMENT8"
		//	cQryInsert += ", SEGMENT9"
		//	cQryInsert += ", SEGMENT10"
		//	cQryInsert += ", SEGMENT11"
		//	cQryInsert += ", SEGMENT12"
		//	cQryInsert += ", SEGMENT13"
		//	cQryInsert += ", SEGMENT14"
		//	cQryInsert += ", SEGMENT15"
		//	cQryInsert += ", SEGMENT16"
		//	cQryInsert += ", SEGMENT17"
		//	cQryInsert += ", SEGMENT18"
		//	cQryInsert += ", SEGMENT19"
		//	cQryInsert += ", SEGMENT20"
		//	cQryInsert += ", SEGMENT21"
		//	cQryInsert += ", SEGMENT22"
		//	cQryInsert += ", SEGMENT23"
		//	cQryInsert += ", SEGMENT24"
		//	cQryInsert += ", SEGMENT25"
		//	cQryInsert += ", SEGMENT26"
		//	cQryInsert += ", SEGMENT27"
		//	cQryInsert += ", SEGMENT28"
		//	cQryInsert += ", SEGMENT29"
		//	cQryInsert += ", SEGMENT30"
		cQryInsert += ", ENTERED_DR"
		cQryInsert += ", ENTERED_CR"
		cQryInsert += ", ACCOUNTED_DR"
		cQryInsert += ", ACCOUNTED_CR"
		cQryInsert += ", TRANSACTION_DATE"
		//	cQryInsert += ", REFERENCE1"
		//	cQryInsert += ", REFERENCE2"
		//	cQryInsert += ", REFERENCE3"
		//	cQryInsert += ", REFERENCE4"
		//	cQryInsert += ", REFERENCE5"
		//	cQryInsert += ", REFERENCE6"
		//	cQryInsert += ", REFERENCE7"
		//	cQryInsert += ", REFERENCE8"
		//	cQryInsert += ", REFERENCE9"
		cQryInsert += ", REFERENCE10"
		//	cQryInsert += ", REFERENCE11"
		//	cQryInsert += ", REFERENCE12"
		//	cQryInsert += ", REFERENCE13"
		//	cQryInsert += ", REFERENCE14"
		//	cQryInsert += ", REFERENCE15"
		//	cQryInsert += ", REFERENCE16"
		//	cQryInsert += ", REFERENCE17"
		//	cQryInsert += ", REFERENCE18"
		//	cQryInsert += ", REFERENCE19"
		//	cQryInsert += ", REFERENCE20"
		//	cQryInsert += ", REFERENCE21"
		//	cQryInsert += ", REFERENCE22"
		//	cQryInsert += ", REFERENCE23"
		//	cQryInsert += ", REFERENCE24"
		//	cQryInsert += ", REFERENCE25"
		//	cQryInsert += ", REFERENCE26"
		//	cQryInsert += ", REFERENCE27"
		//	cQryInsert += ", REFERENCE28"
		//	cQryInsert += ", REFERENCE29"
		//	cQryInsert += ", REFERENCE30"
		//	cQryInsert += ", JE_BATCH_ID"
		cQryInsert += ", PERIOD_NAME"
		//	cQryInsert += ", JE_HEADER_ID"
		//	cQryInsert += ", JE_LINE_NUM"
		cQryInsert += ", CHART_OF_ACCOUNTS_ID"
		//	cQryInsert += ", FUNCTIONAL_CURRENCY_CODE"
		//	cQryInsert += ", CODE_COMBINATION_ID"
		//	cQryInsert += ", DATE_CREATED_IN_GL"
		//	cQryInsert += ", WARNING_CODE"
		//	cQryInsert += ", STATUS_DESCRIPTION"
		//	cQryInsert += ", STAT_AMOUNT"
		//	cQryInsert += ", GROUP_ID"
		//	cQryInsert += ", REQUEST_ID"
		//	cQryInsert += ", SUBLEDGER_DOC_SEQUENCE_ID"
		//	cQryInsert += ", SUBLEDGER_DOC_SEQUENCE_VALUE"
		//	cQryInsert += ", ATTRIBUTE1"
		//	cQryInsert += ", ATTRIBUTE2"
		//	cQryInsert += ", GL_SL_LINK_ID"
		//	cQryInsert += ", GL_SL_LINK_TABLE"
		//	cQryInsert += ", ATTRIBUTE3"
		//	cQryInsert += ", ATTRIBUTE4"
		//	cQryInsert += ", ATTRIBUTE5"
		//	cQryInsert += ", ATTRIBUTE6"
		//	cQryInsert += ", ATTRIBUTE7"
		//	cQryInsert += ", ATTRIBUTE8"
		//	cQryInsert += ", ATTRIBUTE9"
		//	cQryInsert += ", ATTRIBUTE10"
		//	cQryInsert += ", ATTRIBUTE11"
		//	cQryInsert += ", ATTRIBUTE12"
		//	cQryInsert += ", ATTRIBUTE13"
		//	cQryInsert += ", ATTRIBUTE14"
		//	cQryInsert += ", ATTRIBUTE15"
		//	cQryInsert += ", ATTRIBUTE16"
		//	cQryInsert += ", ATTRIBUTE17"
		//	cQryInsert += ", ATTRIBUTE18"
		//	cQryInsert += ", ATTRIBUTE19"
		//	cQryInsert += ", ATTRIBUTE20"
		//	cQryInsert += ", CONTEXT"
		//	cQryInsert += ", CONTEXT2"
		//	cQryInsert += ", INVOICE_DATE"
		//	cQryInsert += ", TAX_CODE"
		//	cQryInsert += ", INVOICE_IDENTIFIER"
		//	cQryInsert += ", INVOICE_AMOUNT"
		//	cQryInsert += ", CONTEXT3"
		//	cQryInsert += ", USSGL_TRANSACTION_CODE"
		//	cQryInsert += ", DESCR_FLEX_ERROR_MESSAGE"
		//	cQryInsert += ", JGZZ_RECON_REF"
		//	cQryInsert += ", REFERENCE_DATE"
		cQryInsert += ", SET_OF_BOOKS_ID"
		//	cQryInsert += ", BALANCING_SEGMENT_VALUE"
		//	cQryInsert += ", MANAGEMENT_SEGMENT_VALUE"
		//	cQryInsert += ", FUNDS_RESERVED_FLAG"
		cQryInsert += ")"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIncluso dos valores no query ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQryValues := ""
		cQryValues += " VALUES "
		cQryValues += "("
		cQryValues += "'"+_STATUS+"'"											//STATUS
		cQryValues += ","+LEDGER_ID+" "			 								//LEDGER_ID
		cQryValues += ",TO_DATE('"+DTOC(STOD(ACCOU_DATE))+"','DD-MM-YY')"   	//ACCOUNTING_DATE
		cQryValues += ",'"+CURRE_CODE+"'"										//CURRENCY_CODE
		cQryValues += ",TO_DATE('"+DTOC(DATE_CREAT)+"','DD-MM-YY')" 		   	//DATE_CREATED
		cQryValues += ",'"+CREATED_BY+"'"										//CREATED_BY
		cQryValues += ",'"+ACTUA_FLAG+"'" 										//ACTUAL_FLAG
		cQryValues += ",'"+USER_JE_CN+"'" 										//USER_JE_CATEGORY_NAME
		cQryValues += ",'"+USER_JE_SN+"'"										//USER_JE_SOURCE_NAME
		//	cQryValues += ",''"					   	 							//CURRENCY_CONVERSION_DATE
		//	cQryValues += ",''"													//ENCUMBRANCE_TYPE_ID
		//	cQryValues += ",''"	  			   									//BUDGET_VERSION_ID
		//	cQryValues += ",''"	  			   									//USER_CURRENCY_CONVERSION_TYPE
		//	cQryValues += ",''"	  			  		   							//CURRENCY_CONVERSION_RATE
		//	cQryValues += ",''"	  			  		  							//AVERAGE_JOURNAL_FLAG
		//	cQryValues += ",''"	   			  		  							//ORIGINATING_BAL_SEG_VALUE
		cQryValues += ",'"+AllTrim(SEGMENT1)+"' "								//SEGMENT1
		cQryValues += ",'"+AllTrim(SEGMENT2)+"'"								//SEGMENT2
		cQryValues += ",'"+AllTrim(SEGMENT3)+"'"								//SEGMENT3
		cQryValues += ",'"+AllTrim(SEGMENT4)+"' "								//SEGMENT4
		cQryValues += ",'"+AllTrim(SEGMENT5)+"'"								//SEGMENT5
		cQryValues += ",'"+AllTrim(SEGMENT6)+"' "		   						//SEGMENT6
		cQryValues += ",'"+AllTrim(SEGMENT7)+"' "								//SEGMENT7
		//	cQryValues += ",''"	   					  							//SEGMENT8
		//	cQryValues += ",''"	   					  							//SEGMENT9
		//	cQryValues += ",''"	  				 								//SEGMENT10
		//	cQryValues += ",''"	 												//SEGMENT11
		//	cQryValues += ",''"							 		 				//SEGMENT12
		//	cQryValues += ",''"													//SEGMENT13
		//	cQryValues += ",''"													//SEGMENT14
		//	cQryValues += ",''"													//SEGMENT15
		//	cQryValues += ",''"		   											//SEGMENT16
		//	cQryValues += ",''"		   											//SEGMENT17
		//	cQryValues += ",''"													//SEGMENT18
		//	cQryValues += ",''"						  							//SEGMENT19
		//	cQryValues += ",''"						  							//SEGMENT20
		//	cQryValues += ",''"		  											//SEGMENT21
		//	cQryValues += ",''"						   							//SEGMENT22
		//	cQryValues += ",''"		   							   				//SEGMENT23
		//	cQryValues += ",''"	   					   							//SEGMENT24
		//	cQryValues += ",''"		   				   							//SEGMENT25
		//	cQryValues += ",''"			 										//SEGMENT26
		//	cQryValues += ",''"						  							//SEGMENT27
		//	cQryValues += ",''"			   		   								//SEGMENT28
		//	cQryValues += ",''"			  										//SEGMENT29
		//	cQryValues += ",''"			  					  					//SEGMENT30
		cQryValues += ","+ENTERED_DR+" "    									//ENTERED_DR
		cQryValues += ","+ENTERED_CR+" "   								   		//ENTERED_CR
		cQryValues += ","+ACCOUNT_DR+" "	  	   								//ACCOUNTED_DR
		cQryValues += ","+ACCOUNT_CR+" "   										//ACCOUNTED_CR
		cQryValues += ",TO_DATE('"+DTOC(STOD(TRANS_DATE))+"','DD-MM-YY')"	    //TRANSACTION_DATE
		//	cQryValues += ",''"	  					   							//REFERENCE1
		//	cQryValues += ",''"	  		 										//REFERENCE2
		//	cQryValues += ",''"	  	   											//REFERENCE3
		//	cQryValues += ",''"	  		 										//REFERENCE4
		//	cQryValues += ",''"	  												//REFERENCE5
		//	cQryValues += ",''"		 											//REFERENCE6
		//	cQryValues += ",''"		 											//REFERENCE7
		//	cQryValues += ",''"		  											//REFERENCE8
		//	cQryValues += ",''"		  											//REFERENCE9
		cQryValues += ",'"+REFERENC10+"'"										//REFERENCE10
		//	cQryValues += ",''"			 										//REFERENCE11
		//	cQryValues += ",''"													//REFERENCE12
		//	cQryValues += ",''"			 										//REFERENCE13
		//	cQryValues += ",''"													//REFERENCE14
		//	cQryValues += ",''"			  										//REFERENCE15
		//	cQryValues += ",''"													//REFERENCE16
		//	cQryValues += ",''"			 										//REFERENCE17
		//	cQryValues += ",''"													//REFERENCE18
		//	cQryValues += ",''"			 										//REFERENCE19
		//	cQryValues += ",''"													//REFERENCE20
		//	cQryValues += ",''"													//REFERENCE21
		//	cQryValues += ",''"													//REFERENCE22
		//	cQryValues += ",''"													//REFERENCE23
		//	cQryValues += ",''"													//REFERENCE24
		//	cQryValues += ",''"					 								//REFERENCE25
		//	cQryValues += ",''"													//REFERENCE26
		//	cQryValues += ",''"		  											//REFERENCE27
		//	cQryValues += ",''"			  										//REFERENCE28
		//	cQryValues += ",''"		 	 										//REFERENCE29
		//	cQryValues += ",''"			 										//REFERENCE30
		//	cQryValues += ",''"	   				  	   							//JE_BATCH_ID
		cQryValues += ",'"+PERIO_NAME+"'"										//PERIOD_NAME
		//	cQryValues += ",''"		 											//JE_HEADER_ID
		//	cQryValues += ",''"		   											//JE_LINE_NUM
		cQryValues += ","+CHART_A_ID+" "										//CHART_OF_ACCOUNTS_ID
		//	cQryValues += ",''"			  										//FUNCTIONAL_CURRENCY_CODE
		//	cQryValues += ",''"		  											//CODE_COMBINATION_ID
		//	cQryValues += ",''"		 											//DATE_CREATED_IN_GL
		//	cQryValues += ",''"		 											//WARNING_CODE
		//	cQryValues += ",''"	   		  										//STATUS_DESCRIPTION
		//	cQryValues += ",''"	 	 											//STAT_AMOUNT
		//	cQryValues += ",''"	   		   										//GROUP_ID
		//	cQryValues += ",''"		  											//REQUEST_ID
		//	cQryValues += ",''"		  											//SUBLEDGER_DOC_SEQUENCE_ID
		//	cQryValues += ",''"	   	  											//SUBLEDGER_DOC_SEQUENCE_VALUE
		//	cQryValues += ",''"		  											//ATTRIBUTE1
		//	cQryValues += ",''"		 											//ATTRIBUTE2
		//	cQryValues += ",''"	   	  											//GL_SL_LINK_ID
		//	cQryValues += ",''"	  	 											//GL_SL_LINK_TABLE
		//	cQryValues += ",''"		  	 										//ATTRIBUTE3
		//	cQryValues += ",''"	   	 											//ATTRIBUTE4
		//	cQryValues += ",''"	   	 											//ATTRIBUTE5
		//	cQryValues += ",''"	   			   									//ATTRIBUTE6
		//	cQryValues += ",''"		   											//ATTRIBUTE7
		//	cQryValues += ",''"	   												//ATTRIBUTE8
		//	cQryValues += ",''"													//ATTRIBUTE9
		//	cQryValues += ",''"													//ATTRIBUTE10
		//	cQryValues += ",''"													//ATTRIBUTE11
		//	cQryValues += ",''"													//ATTRIBUTE12
		//	cQryValues += ",''"													//ATTRIBUTE13
		//	cQryValues += ",''"													//ATTRIBUTE14
		//	cQryValues += ",''"													//ATTRIBUTE15
		//	cQryValues += ",''"													//ATTRIBUTE16
		//	cQryValues += ",''"													//ATTRIBUTE17
		//	cQryValues += ",''"													//ATTRIBUTE18
		//	cQryValues += ",''"													//ATTRIBUTE19
		//	cQryValues += ",''"													//ATTRIBUTE20
		//	cQryValues += ",''"													//CONTEXT
		//	cQryValues += ",''"													//CONTEXT2
		//	cQryValues += ",''"													//INVOICE_DATE
		//	cQryValues += ",''"													//TAX_CODE
		//	cQryValues += ",''"													//INVOICE_IDENTIFIER
		//	cQryValues += ",''"			   										//INVOICE_AMOUNT
		//	cQryValues += ",''"			  										//CONTEXT3
		//	cQryValues += ",''"			  										//USSGL_TRANSACTION_CODE
		//	cQryValues += ",''"			 										//DESCR_FLEX_ERROR_MESSAGE
		//	cQryValues += ",''"			  										//JGZZ_RECON_REF
		//	cQryValues += ",''"	   		   										//REFERENCE_DATE
		cQryValues += ","+SET_BOOKID+" "					  					//SET_OF_BOOKS_ID
		//	cQryValues += ",''"	  												//BALANCING_SEGMENT_VALUE
		//	cQryValues += ",''"		  											//MANAGEMENT_SEGMENT_VALUE
		//	cQryValues += ",''"		  											//FUNDS_RESERVED_FLAG
		cQryValues += ")"
		cQryPRT144 := cQryInsert+cQryValues 
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExecuta comando SQL, e retorna erro ou encerra rotinaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nRetSql := TcSqlExec(cQryPRT144)
		If nRetSql != 0
			MsgAlert("Falha na realiza็ใo da inclusใo: Data da movimenta็ใo: " + dDataMovto + CRLF +;
					 " Conta: " + cContaCont + " "+TCSQLERROR())  
			MsgAlert(TCSQLError())
			lRet := .F.
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณDesconecto do servidor caso de falha na execuo do "Insert" ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			lDes	:= DesconSvr(nHndConOra)
			If !lDes
				tcSetConn(nHndConERP)
			EndIf
			Exit
		EndIf
		
		//--------DEBITO------------------------------------------------------------
		SEGMENT2	 := TMPRT0144->CT2_CCD
		SEGMENT3	 := TMPRT0144->CT2_DEBITO
		SEGMENT5	 := TMPRT0144->CT2_ITEMD
		ENTERED_DR	 := cValToChar(TMPRT0144->CT2_VALOR)
		ENTERED_CR	 := "0"
		ACCOUNT_DR	 := cValToChar(TMPRT0144->CT2_VALOR)
		ACCOUNT_CR	 := "0"

		//para as contas que iniciam com 1,2 o centro de custo deverแ vir zerado
		IF SUBSTR(AllTrim(SEGMENT3),1,1) == '1' .Or. SUBSTR(AllTrim(SEGMENT3),1,1) == '2'
	    	SEGMENT2 := "000"
		    SEGMENT5 := "000"
	    Endif

		IncProc("Data da movimenta็ใo: " + dDataMovto + CRLF + "        Conta sendo importada: " + cContaCont )
		cQryInsert := ""
		cQryInsert += "INSERT INTO GL_INTERFACE ("
		cQryInsert += "STATUS"
		cQryInsert += ", LEDGER_ID"
		cQryInsert += ", ACCOUNTING_DATE"
		cQryInsert += ", CURRENCY_CODE"
		cQryInsert += ", DATE_CREATED"
		cQryInsert += ", CREATED_BY"
		cQryInsert += ", ACTUAL_FLAG"
		cQryInsert += ", USER_JE_CATEGORY_NAME"
		cQryInsert += ", USER_JE_SOURCE_NAME"
		//	cQryInsert += ", CURRENCY_CONVERSION_DATE"
		//	cQryInsert += ", ENCUMBRANCE_TYPE_ID"
		//	cQryInsert += ", BUDGET_VERSION_ID"
		//	cQryInsert += ", USER_CURRENCY_CONVERSION_TYPE"
		//	cQryInsert += ", CURRENCY_CONVERSION_RATE"
		//	cQryInsert += ", AVERAGE_JOURNAL_FLAG"
		//	cQryInsert += ", ORIGINATING_BAL_SEG_VALUE"
		cQryInsert += ", SEGMENT1"
		cQryInsert += ", SEGMENT2"
		cQryInsert += ", SEGMENT3"
		cQryInsert += ", SEGMENT4"
		cQryInsert += ", SEGMENT5"
		cQryInsert += ", SEGMENT6"
		cQryInsert += ", SEGMENT7"
		//	cQryInsert += ", SEGMENT8"
		//	cQryInsert += ", SEGMENT9"
		//	cQryInsert += ", SEGMENT10"
		//	cQryInsert += ", SEGMENT11"
		//	cQryInsert += ", SEGMENT12"
		//	cQryInsert += ", SEGMENT13"
		//	cQryInsert += ", SEGMENT14"
		//	cQryInsert += ", SEGMENT15"
		//	cQryInsert += ", SEGMENT16"
		//	cQryInsert += ", SEGMENT17"
		//	cQryInsert += ", SEGMENT18"
		//	cQryInsert += ", SEGMENT19"
		//	cQryInsert += ", SEGMENT20"
		//	cQryInsert += ", SEGMENT21"
		//	cQryInsert += ", SEGMENT22"
		//	cQryInsert += ", SEGMENT23"
		//	cQryInsert += ", SEGMENT24"
		//	cQryInsert += ", SEGMENT25"
		//	cQryInsert += ", SEGMENT26"
		//	cQryInsert += ", SEGMENT27"
		//	cQryInsert += ", SEGMENT28"
		//	cQryInsert += ", SEGMENT29"
		//	cQryInsert += ", SEGMENT30"
		cQryInsert += ", ENTERED_DR"
		cQryInsert += ", ENTERED_CR"
		cQryInsert += ", ACCOUNTED_DR"
		cQryInsert += ", ACCOUNTED_CR"
		cQryInsert += ", TRANSACTION_DATE"
		//	cQryInsert += ", REFERENCE1"
		//	cQryInsert += ", REFERENCE2"
		//	cQryInsert += ", REFERENCE3"
		//	cQryInsert += ", REFERENCE4"
		//	cQryInsert += ", REFERENCE5"
		//	cQryInsert += ", REFERENCE6"
		//	cQryInsert += ", REFERENCE7"
		//	cQryInsert += ", REFERENCE8"
		//	cQryInsert += ", REFERENCE9"
		cQryInsert += ", REFERENCE10"
		//	cQryInsert += ", REFERENCE11"
		//	cQryInsert += ", REFERENCE12"
		//	cQryInsert += ", REFERENCE13"
		//	cQryInsert += ", REFERENCE14"
		//	cQryInsert += ", REFERENCE15"
		//	cQryInsert += ", REFERENCE16"
		//	cQryInsert += ", REFERENCE17"
		//	cQryInsert += ", REFERENCE18"
		//	cQryInsert += ", REFERENCE19"
		//	cQryInsert += ", REFERENCE20"
		//	cQryInsert += ", REFERENCE21"
		//	cQryInsert += ", REFERENCE22"
		//	cQryInsert += ", REFERENCE23"
		//	cQryInsert += ", REFERENCE24"
		//	cQryInsert += ", REFERENCE25"
		//	cQryInsert += ", REFERENCE26"
		//	cQryInsert += ", REFERENCE27"
		//	cQryInsert += ", REFERENCE28"
		//	cQryInsert += ", REFERENCE29"
		//	cQryInsert += ", REFERENCE30"
		//	cQryInsert += ", JE_BATCH_ID"
		cQryInsert += ", PERIOD_NAME"
		//	cQryInsert += ", JE_HEADER_ID"
		//	cQryInsert += ", JE_LINE_NUM"
		cQryInsert += ", CHART_OF_ACCOUNTS_ID"
		//	cQryInsert += ", FUNCTIONAL_CURRENCY_CODE"
		//	cQryInsert += ", CODE_COMBINATION_ID"
		//	cQryInsert += ", DATE_CREATED_IN_GL"
		//	cQryInsert += ", WARNING_CODE"
		//	cQryInsert += ", STATUS_DESCRIPTION"
		//	cQryInsert += ", STAT_AMOUNT"
		//	cQryInsert += ", GROUP_ID"
		//	cQryInsert += ", REQUEST_ID"
		//	cQryInsert += ", SUBLEDGER_DOC_SEQUENCE_ID"
		//	cQryInsert += ", SUBLEDGER_DOC_SEQUENCE_VALUE"
		//	cQryInsert += ", ATTRIBUTE1"
		//	cQryInsert += ", ATTRIBUTE2"
		//	cQryInsert += ", GL_SL_LINK_ID"
		//	cQryInsert += ", GL_SL_LINK_TABLE"
		//	cQryInsert += ", ATTRIBUTE3"
		//	cQryInsert += ", ATTRIBUTE4"
		//	cQryInsert += ", ATTRIBUTE5"
		//	cQryInsert += ", ATTRIBUTE6"
		//	cQryInsert += ", ATTRIBUTE7"
		//	cQryInsert += ", ATTRIBUTE8"
		//	cQryInsert += ", ATTRIBUTE9"
		//	cQryInsert += ", ATTRIBUTE10"
		//	cQryInsert += ", ATTRIBUTE11"
		//	cQryInsert += ", ATTRIBUTE12"
		//	cQryInsert += ", ATTRIBUTE13"
		//	cQryInsert += ", ATTRIBUTE14"
		//	cQryInsert += ", ATTRIBUTE15"
		//	cQryInsert += ", ATTRIBUTE16"
		//	cQryInsert += ", ATTRIBUTE17"
		//	cQryInsert += ", ATTRIBUTE18"
		//	cQryInsert += ", ATTRIBUTE19"
		//	cQryInsert += ", ATTRIBUTE20"
		//	cQryInsert += ", CONTEXT"
		//	cQryInsert += ", CONTEXT2"
		//	cQryInsert += ", INVOICE_DATE"
		//	cQryInsert += ", TAX_CODE"
		//	cQryInsert += ", INVOICE_IDENTIFIER"
		//	cQryInsert += ", INVOICE_AMOUNT"
		//	cQryInsert += ", CONTEXT3"
		//	cQryInsert += ", USSGL_TRANSACTION_CODE"
		//	cQryInsert += ", DESCR_FLEX_ERROR_MESSAGE"
		//	cQryInsert += ", JGZZ_RECON_REF"
		//	cQryInsert += ", REFERENCE_DATE"
		cQryInsert += ", SET_OF_BOOKS_ID"
		//	cQryInsert += ", BALANCING_SEGMENT_VALUE"
		//	cQryInsert += ", MANAGEMENT_SEGMENT_VALUE"
		//	cQryInsert += ", FUNDS_RESERVED_FLAG"
		cQryInsert += ")"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIncluso dos valores no query ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQryValues := ""
		cQryValues += " VALUES "
		cQryValues += "("
		cQryValues += "'"+_STATUS+"'"											//STATUS
		cQryValues += ","+LEDGER_ID+" "			 								//LEDGER_ID
		cQryValues += ",TO_DATE('"+DTOC(STOD(ACCOU_DATE))+"','DD-MM-YY')" 	    //ACCOUNTING_DATE
		cQryValues += ",'"+CURRE_CODE+"'"										//CURRENCY_CODE
		cQryValues += ",TO_DATE('"+DTOC(DATE_CREAT)+"','DD-MM-YY')" 		   	//DATE_CREATED
		cQryValues += ",'"+CREATED_BY+"'"										//CREATED_BY
		cQryValues += ",'"+ACTUA_FLAG+"'" 										//ACTUAL_FLAG
		cQryValues += ",'"+USER_JE_CN+"'" 										//USER_JE_CATEGORY_NAME
		cQryValues += ",'"+USER_JE_SN+"'"										//USER_JE_SOURCE_NAME
		//	cQryValues += ",''"					   	 							//CURRENCY_CONVERSION_DATE
		//	cQryValues += ",''"													//ENCUMBRANCE_TYPE_ID
		//	cQryValues += ",''"	  			   									//BUDGET_VERSION_ID
		//	cQryValues += ",''"	  			   									//USER_CURRENCY_CONVERSION_TYPE
		//	cQryValues += ",''"	  			  		   							//CURRENCY_CONVERSION_RATE
		//	cQryValues += ",''"	  			  		  							//AVERAGE_JOURNAL_FLAG
		//	cQryValues += ",''"	   			  		  							//ORIGINATING_BAL_SEG_VALUE
		cQryValues += ",'"+AllTrim(SEGMENT1)+"' "								//SEGMENT1
		cQryValues += ",'"+AllTrim(SEGMENT2)+"'"								//SEGMENT2
		cQryValues += ",'"+AllTrim(SEGMENT3)+"'"								//SEGMENT3
		cQryValues += ",'"+AllTrim(SEGMENT4)+"' "								//SEGMENT4
		cQryValues += ",'"+AllTrim(SEGMENT5)+"'"								//SEGMENT5
		cQryValues += ",'"+AllTrim(SEGMENT6)+"' "		   						//SEGMENT6
		cQryValues += ",'"+AllTrim(SEGMENT7)+"' "								//SEGMENT7
		//	cQryValues += ",''"	   					  							//SEGMENT8
		//	cQryValues += ",''"	   					  							//SEGMENT9
		//	cQryValues += ",''"	  				 								//SEGMENT10
		//	cQryValues += ",''"	 												//SEGMENT11
		//	cQryValues += ",''"							 		 				//SEGMENT12
		//	cQryValues += ",''"													//SEGMENT13
		//	cQryValues += ",''"													//SEGMENT14
		//	cQryValues += ",''"													//SEGMENT15
		//	cQryValues += ",''"		   											//SEGMENT16
		//	cQryValues += ",''"		   											//SEGMENT17
		//	cQryValues += ",''"													//SEGMENT18
		//	cQryValues += ",''"						  							//SEGMENT19
		//	cQryValues += ",''"						  							//SEGMENT20
		//	cQryValues += ",''"		  											//SEGMENT21
		//	cQryValues += ",''"						   							//SEGMENT22
		//	cQryValues += ",''"		   							   				//SEGMENT23
		//	cQryValues += ",''"	   					   							//SEGMENT24
		//	cQryValues += ",''"		   				   							//SEGMENT25
		//	cQryValues += ",''"			 										//SEGMENT26
		//	cQryValues += ",''"						  							//SEGMENT27
		//	cQryValues += ",''"			   		   								//SEGMENT28
		//	cQryValues += ",''"			  										//SEGMENT29
		//	cQryValues += ",''"			  					  					//SEGMENT30
		cQryValues += ","+ENTERED_DR+" "    									//ENTERED_DR
		cQryValues += ","+ENTERED_CR+" "   								   		//ENTERED_CR
		cQryValues += ","+ACCOUNT_DR+" "	  	   								//ACCOUNTED_DR
		cQryValues += ","+ACCOUNT_CR+" "   										//ACCOUNTED_CR
		cQryValues += ",TO_DATE('"+DTOC(STOD(TRANS_DATE))+"','DD-MM-YY')"	    //TRANSACTION_DATE
		//	cQryValues += ",''"	  					   							//REFERENCE1
		//	cQryValues += ",''"	  		 										//REFERENCE2
		//	cQryValues += ",''"	  	   											//REFERENCE3
		//	cQryValues += ",''"	  		 										//REFERENCE4
		//	cQryValues += ",''"	  												//REFERENCE5
		//	cQryValues += ",''"		 											//REFERENCE6
		//	cQryValues += ",''"		 											//REFERENCE7
		//	cQryValues += ",''"		  											//REFERENCE8
		//	cQryValues += ",''"		  											//REFERENCE9
		cQryValues += ",'"+REFERENC10+"'"										//REFERENCE10
		//	cQryValues += ",''"			 										//REFERENCE11
		//	cQryValues += ",''"													//REFERENCE12
		//	cQryValues += ",''"			 										//REFERENCE13
		//	cQryValues += ",''"													//REFERENCE14
		//	cQryValues += ",''"			  										//REFERENCE15
		//	cQryValues += ",''"													//REFERENCE16
		//	cQryValues += ",''"			 										//REFERENCE17
		//	cQryValues += ",''"													//REFERENCE18
		//	cQryValues += ",''"			 										//REFERENCE19
		//	cQryValues += ",''"													//REFERENCE20
		//	cQryValues += ",''"													//REFERENCE21
		//	cQryValues += ",''"													//REFERENCE22
		//	cQryValues += ",''"													//REFERENCE23
		//	cQryValues += ",''"													//REFERENCE24
		//	cQryValues += ",''"					 								//REFERENCE25
		//	cQryValues += ",''"													//REFERENCE26
		//	cQryValues += ",''"		  											//REFERENCE27
		//	cQryValues += ",''"			  										//REFERENCE28
		//	cQryValues += ",''"		 	 										//REFERENCE29
		//	cQryValues += ",''"			 										//REFERENCE30
		//	cQryValues += ",''"	   				  	   							//JE_BATCH_ID
		cQryValues += ",'"+PERIO_NAME+"'"										//PERIOD_NAME
		//	cQryValues += ",''"		 											//JE_HEADER_ID
		//	cQryValues += ",''"		   											//JE_LINE_NUM
		cQryValues += ","+CHART_A_ID+" "										//CHART_OF_ACCOUNTS_ID
		//	cQryValues += ",''"			  										//FUNCTIONAL_CURRENCY_CODE
		//	cQryValues += ",''"		  											//CODE_COMBINATION_ID
		//	cQryValues += ",''"		 											//DATE_CREATED_IN_GL
		//	cQryValues += ",''"		 											//WARNING_CODE
		//	cQryValues += ",''"	   		  										//STATUS_DESCRIPTION
		//	cQryValues += ",''"	 	 											//STAT_AMOUNT
		//	cQryValues += ",''"	   		   										//GROUP_ID
		//	cQryValues += ",''"		  											//REQUEST_ID
		//	cQryValues += ",''"		  											//SUBLEDGER_DOC_SEQUENCE_ID
		//	cQryValues += ",''"	   	  											//SUBLEDGER_DOC_SEQUENCE_VALUE
		//	cQryValues += ",''"		  											//ATTRIBUTE1
		//	cQryValues += ",''"		 											//ATTRIBUTE2
		//	cQryValues += ",''"	   	  											//GL_SL_LINK_ID
		//	cQryValues += ",''"	  	 											//GL_SL_LINK_TABLE
		//	cQryValues += ",''"		  	 										//ATTRIBUTE3
		//	cQryValues += ",''"	   	 											//ATTRIBUTE4
		//	cQryValues += ",''"	   	 											//ATTRIBUTE5
		//	cQryValues += ",''"	   			   									//ATTRIBUTE6
		//	cQryValues += ",''"		   											//ATTRIBUTE7
		//	cQryValues += ",''"	   												//ATTRIBUTE8
		//	cQryValues += ",''"													//ATTRIBUTE9
		//	cQryValues += ",''"													//ATTRIBUTE10
		//	cQryValues += ",''"													//ATTRIBUTE11
		//	cQryValues += ",''"													//ATTRIBUTE12
		//	cQryValues += ",''"													//ATTRIBUTE13
		//	cQryValues += ",''"													//ATTRIBUTE14
		//	cQryValues += ",''"													//ATTRIBUTE15
		//	cQryValues += ",''"													//ATTRIBUTE16
		//	cQryValues += ",''"													//ATTRIBUTE17
		//	cQryValues += ",''"													//ATTRIBUTE18
		//	cQryValues += ",''"													//ATTRIBUTE19
		//	cQryValues += ",''"													//ATTRIBUTE20
		//	cQryValues += ",''"													//CONTEXT
		//	cQryValues += ",''"													//CONTEXT2
		//	cQryValues += ",''"													//INVOICE_DATE
		//	cQryValues += ",''"													//TAX_CODE
		//	cQryValues += ",''"													//INVOICE_IDENTIFIER
		//	cQryValues += ",''"			   										//INVOICE_AMOUNT
		//	cQryValues += ",''"			  										//CONTEXT3
		//	cQryValues += ",''"			  										//USSGL_TRANSACTION_CODE
		//	cQryValues += ",''"			 										//DESCR_FLEX_ERROR_MESSAGE
		//	cQryValues += ",''"			  										//JGZZ_RECON_REF
		//	cQryValues += ",''"	   		   										//REFERENCE_DATE
		cQryValues += ","+SET_BOOKID+" "					  					//SET_OF_BOOKS_ID
		//	cQryValues += ",''"	  												//BALANCING_SEGMENT_VALUE
		//	cQryValues += ",''"		  											//MANAGEMENT_SEGMENT_VALUE
		//	cQryValues += ",''"		  											//FUNDS_RESERVED_FLAG
		cQryValues += ")"
		cQryPRT144 := cQryInsert+cQryValues 
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExecuta comando SQL, e retorna erro ou encerra rotinaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nRetSql := TcSqlExec(cQryPRT144)
		If nRetSql != 0
			MsgAlert("Falha na realiza็ใo da inclusใo: Data da movimenta็ใo: " + dDataMovto + CRLF +;
					 " Conta: " + cContaCont + " "+TCSQLERROR())  
			MsgAlert(TCSQLError())
			lRet := .F.
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณDesconecto do servidor caso de falha na execuo do "Insert" ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			lDes	:= DesconSvr(nHndConOra)
			If !lDes
				tcSetConn(nHndConERP)
			EndIf
			Exit
		EndIf
				
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEncerra conexo com base externaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lDes	:= DesconSvr(nHndConOra)
		If !lDes
			tcSetConn(nHndConERP)
		EndIf 
		
		
		//A rotina abaixo foi comentada, pois, ser  necess rio verificar com consultores se haver  necessidade
		//de marcar os registro da SE2 como Enviados/Integrados.
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualizo status de envio na CT2 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQryFlag := ""
		cQryFlag += " UPDATE " + RetSqlName("CT2")+" CT2 "
		cQryFlag += " SET CT2.CT2_ENVORA = 'S' "
		cQryFlag += " WHERE CT2.R_E_C_N_O_= '"+cValToChar(TMPRT0144->R_E_C_N_O_)+"' "
		
		nRetFlag := TcSqlExec(cQryFlag)
		If nRetFlag != 0
			MsgAlert("Falha na atualiza็ใo da conta: " +cContaCont+ " Erro: " +TCSQLERROR())
			lRet	:= .F.
			Exit
		EndIf
		
	EndIf
	TMPRT0144->(DbSkip())
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFecha tabela tempor ria de movimentao de contasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
TMPRT0144->(DbCloseArea())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEncerramento da rotina PRT0144  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If lRet
	MsgInfo("Processo Finalizado! ","PRT0144 - Integra็ใo Concluํda. ")
Else
	MsgAlert("Falha no processamento, Integra็ใo nใo realizada! ")
EndIf

//Confirmo a conexo para o Banco do Protheus, ฃtil no caso de falha durante a integrao
tcSetConn(nHndConERP)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |ConectaSvrบAutor  |Douglas Gregorio    บ Data ณ  24/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuno que realiza a conexo com servidor externo oracle viaบฑฑ
ฑฑบ          ณODBC, e cria script de insero a partir de matriz de data  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ConectaSvr()
Local cAlias 	 := ""				//Nome do ambiente no DBACCESS
Local cServidor  := ""	  			//IP, nome, ou endereo do servidor de BD
Local nPorta 	 := ""				//Porta de conexo do DBACCESS
Local nHndConOra := 0
Local lCon		 := .F.
Local lRet		 := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObtm dados dos parametros de conexo com base externaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cAlias	   := AllTrim(GetMv("MV_SRVALIA", .F.))
cServidor  := AllTrim(GetMv("MV_SRVEXTR", .F.))
nPorta	   := Val(GetMv( "MV_SRVPORT", .F.))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFuno que estabelece link com servidor externo ao Protheus   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHndConOra := TCLink(cAlias,cServidor,nPorta)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApresenta mensagem caso ocorra falha na conexoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nHndConOra < 0
	MsgAlert("Falha ao estabelecer conexใo com servidor Oracle para Integra็ใo! Resultado : " + cValToChar(nHndConOra))
	lRet   := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAlterna conexo ativa para a base de dados externaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	lCon := TCSetConn(nHndConOra)
	If !lCon
		MsgAlert("Falha ao alterar conexใo ativa para Integra็ใo! ")
		nHndConOra	:=	Val("-1")
	EndIf
EndIf
Return(nHndConOra)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |DesconSvr บAutor  |Douglas Gregorio    บ Data ณ  11/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuno que encerra a conexo com servidor externo oracle viaบฑฑ
ฑฑบ          ณODBC                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DesconSvr(nHndConOra)
Local lDes := .T.
Local lRet := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFuno que desconecta do link com servidor externo ao Protheusณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lDes := TCUnlink(nHndConOra)
If !lDes
	MsgAlert("Falha ao encerrar conexใo ativa, verifique se integra็ใo foi concluํda! ")
	lRet := .F.
EndIf

Return(lRet)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria Grupo de Perguntas no SX1 e Limpa conteudo se encontradasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function SX1_0144(cPerg)
Local aArea := GetArea()
Local nI

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLimpa o conteฃdo de pergunta existenteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX1")
DbSetOrder(1)
For nI := 1 To 4
	If DbSeek(PADR(cPerg,10)+PADL(cValtoChar(nI),2,"0"))
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := ""
		SX1->(MsUnlock())
	EndIf
Next
DbCloseArea("SX1")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ Para tirar obrigatoriedade no preenchimento da pergunta, retirar
//ณCria Grupos de perguntas na tabela SX1ณ o conteฃdo do parametro 12 : "!Empty(mv_par01)"
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PutSX1(cPerg,"01","De dia:     "," "," ","mv_ch1","D",8,0,0,"G","","!Empty(mv_par01)","","","mv_par01","","","","","","","","","","","","",""," "," "," ",{"Data Inicial"},{""},{""})
PutSX1(cPerg,"02","At้ dia:    "," "," ","mv_ch2","D",8,0,0,"G","","!Empty(mv_par02)","","","mv_par02","","","","","","","","","","","","",""," "," "," ",{"Data Final "},{""},{""})
PutSx1(cPerg,"03","De Filial:  "," "," ","mv_ch3","C",15,0,0,"G","","SM0","","","mv_par03","","","","","","","","","","","","",""," "," "," ",{"Empresa/Filial, "},{""},{""})
PutSx1(cPerg,"04","At้ Filial: "," "," ","mv_ch4","C",15,0,0,"G","","SM0","","","mv_par04","","","","","","","","","","","","",""," "," "," ",{"Empresa/Filial"},{""},{""})

RestArea(aArea)
Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA partir de ms, retorna nome do ms abreviadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function MesExtenso(mes)
Local cDescrMes := ""
Do Case
	Case mes == "01"
		cDescrMes := "JAN"
	Case mes == "02"
		cDescrMes := "FEV"
	Case mes == "03"
		cDescrMes := "MAR"
	Case mes == "04"
		cDescrMes := "ABR"
	Case mes == "05"
		cDescrMes := "MAI"
	Case mes == "06"
		cDescrMes := "JUN"
	Case mes == "07"
		cDescrMes := "JUL"
	Case mes == "08"
		cDescrMes := "AGO"
	Case mes == "09"
		cDescrMes := "SET"
	Case mes == "10"
		cDescrMes := "OUT"
	Case mes == "11"
		cDescrMes := "NOV"
	Case mes == "12"
		cDescrMes := "DEZ"
Endcase
Return(cDescrMes)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConfere se tabela (Tab) esta abertaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function VerTabela(Tab)
If Select(Tab) > 0
	DbSelectArea(Tab)
	DbCloseArea(Tab)
EndIf
Return()
