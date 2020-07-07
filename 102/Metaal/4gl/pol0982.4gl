#-----------------------------------------------------------#
# SISTEMA.:CHAMA PROCESSAMENTO DE APONTAMENTO DE PARADAS		#
#	PROGRAMA:	pol0982																					#
#	CLIENTE.:	METAAL																					#
#	OBJETIVO:	CHAMAR PROCESSAR OS APONTAMENTOS DA METAAL		  #
#																														#
#	AUTOR...:	THIAGO																					#
#	DATA....:	05/06/2009																			#
#-----------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE 
   				p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          comando                  CHAR(80),
          p_versao                 CHAR(18),
          p_nom_tela 							 CHAR(200),
          p_index									 SMALLINT,
          p_qtd_saldo       LIKE estoque_lote.qtd_saldo
          
END GLOBALS
MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0982-10.02.05"
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP

   DEFER INTERRUPT
   CALL log140_procura_caminho("vdp.iem") RETURNING comando
   OPTIONS
      HELP FILE comando

#  CALL log001_acessa_usuario("VDP")
   #CALL log001_acessa_usuario("VDP","LIC_LIB")
    #  RETURNING p_status, p_cod_empresa, p_user
    
    LET p_status			= 0
    LET p_cod_empresa = '01'
    LET p_user 				= 'admlog'
    
   IF p_status = 0 THEN
   	CALL pol0982_controle()
   END IF
END MAIN

#--------------------------#
FUNCTION pol0982_controle()#
#--------------------------#
	
	CALL log120_procura_caminho('pol0941') RETURNING comando
	LET comando = comando clipped, ' pol0982'
	RUN comando RETURNING p_status
	
END FUNCTION