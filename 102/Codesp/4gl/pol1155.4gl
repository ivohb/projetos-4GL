#-----------------------------------------------------------#
#	PROGRAMA:	pol1155																					#
#	CLIENTE.:	CODESP																					#
#	OBJETIVO:	LAN�AMENTOS CONT�BEIS   												#
#	AUTOR...:	IVO   																					#
#	DATA....:	05/06/2012																			#
#-----------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01)
   
   DEFINE p_texto     				CHAR(300),
          p_num_conta_reduz   CHAR(10)		
   
END GLOBALS

DEFINE p_entrada RECORD 
				dat_movto_ini			DATE,				
				dat_movto_fim			DATE,
				num_conta_ini			CHAR(23),
				num_conta_fim			CHAR(23)
END RECORD 

DEFINE p_diario RECORD
				den_sistema_ger				LIKE	lancamentos.den_sistema_ger, 
				per_contabil					LIKE	lancamentos.per_contabil,	
				cod_seg_periodo				LIKE	lancamentos.cod_seg_periodo,
				num_lote							LIKE	lancamentos.num_lote,
				dat_movto							LIKE	lancamentos.dat_movto, 
				ies_tip_lanc					LIKE	lancamentos.ies_tip_lanc, 
				num_conta							LIKE	lancamentos.num_conta,
				num_lanc							LIKE	lancamentos.num_lanc, 
				num_relacionto				LIKE	lanctos_compl.num_relacionto,
				val_lanc							LIKE  ctb_lanc_ctbl_ctb.val_lancto
END RECORD 

DEFINE p_relat RECORD
		num_seq      INTEGER,
		dat_movto    DATE,
		mes_movto    INTEGER,
		conta_deb    CHAR(23),
		conta_red_d  CHAR(10),
		conta_cred   CHAR(23),
		conta_red_c  CHAR(10),
		den_hist     CHAR(50),
		num_relac    INTEGER,
		val_deb      DECIMAL(12,2),
		val_cred     DECIMAL(12,2)
END RECORD

   DEFINE pr_men               ARRAY[1] OF RECORD    
          mensagem             CHAR(60)
   END RECORD


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1155-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1155_menu()
   END IF
END MAIN
 
#-----------------------#
FUNCTION  pol1155_menu()#
#-----------------------#

	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol1155") RETURNING comando
	OPEN WINDOW w_pol1155 AT 2,2 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	
 	DISPLAY p_cod_empresa TO cod_empresa
	LET p_ies_cons = FALSE 

	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
		   CALL pol1155_informar() RETURNING p_ies_cons
		   IF p_ies_cons THEN
		      ERROR 'Opera��o efetuada com sucesso!'
   			  NEXT OPTION "Listar"
   		 ELSE
   		    ERROR 'Opera��o cancelada!'  
   		 END IF
		COMMAND "Listar"  "Lista dados"
		   IF p_ies_cons THEN
          CALL pol1155_listar()
       ELSE
          ERROR 'Informe os par�metros previamente!'
          NEXT OPTION "Informar"
       END IF
    COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
	 		 CALL pol1155_sobre()
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			EXIT MENU
	END MENU

	CLOSE WINDOW w_pol1155

END FUNCTION

#-----------------------#
 FUNCTION pol1155_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               "LOGIX 10.02 ","\n\n",
               "Autor: Ivo H Barbosa\n",
               "Email: ivohb.me@gmail.com\n\n",
               "Home page: www.grupoaceex.com.br\n",
               "(0xx11) 4991-6667\n\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION  pol1155_informar()#
#---------------------------#

	CLEAR FORM 
 	DISPLAY p_cod_empresa TO cod_empresa
  LET INT_FLAG = FALSE
	LET p_entrada.dat_movto_ini = TODAY
 	LET p_entrada.dat_movto_fim = TODAY
   	 	
 	INPUT BY NAME p_entrada.* WITHOUT DEFAULTS

 		AFTER FIELD num_conta_ini
 		
 			IF p_entrada.num_conta_ini IS NOT NULL THEN 
 				IF NOT pol1155_verifica_conta(p_entrada.num_conta_ini) THEN
 					ERROR"Conta invalida digite o numero da conta novamente" 
 					NEXT FIELD num_conta_ini
 				END IF 
 			END IF
 			
 		BEFORE  FIELD num_conta_fim
 			
 			IF p_entrada.num_conta_ini IS NULL THEN
 			   INITIALIZE p_entrada.num_conta_fim TO NULL
 			   DISPLAY ' ' TO num_conta_fim
 				 EXIT INPUT
 			END IF
 			
 		AFTER FIELD num_conta_fim
 		
 			IF p_entrada.num_conta_fim IS NULL THEN
 		 		 ERROR"Campo de Preenchimento Obraigat�rio"
 				 NEXT FIELD num_conta_fim
 			ELSE  
 				 IF NOT pol1155_verifica_conta(p_entrada.num_conta_fim) THEN 
 					  ERROR"Conta invalida digite o numero da conta novamente" 
 					  NEXT FIELD num_conta_fim
 				 END IF 
 			END IF
 	
 	 AFTER INPUT
 			
 			IF NOT INT_FLAG THEN

    		 IF p_entrada.dat_movto_ini IS NULL THEN
  	   			ERROR"Campo de Prenchimento Obrigat�rio!"
  			  	NEXT FIELD dat_movto_ini
 			   END IF 

			   IF p_entrada.dat_movto_fim IS NULL THEN
 				    ERROR"Campo de Prenchimento Obrigat�rio!"
 				    NEXT FIELD dat_movto_fim
 	       END IF

 				 IF p_entrada.dat_movto_fim < p_entrada.dat_movto_ini THEN
 					  ERROR"Data Final n�o pode ser menor que a data inicial"
 					  NEXT FIELD dat_movto_fim
 				 END IF
 				 
 				 IF NOT  pol1155_valida_data() THEN 
 						ERROR"Periodo de datas nao podem ser de meses diferentes"
 						NEXT FIELD dat_movto_fim
 				 END IF 

 			END IF 

 		ON KEY (control-z)
    	CALL pol1155_popup()  

 	END INPUT

 	IF int_flag THEN
		 CLEAR FORM
		 DISPLAY p_cod_empresa TO cod_empresa
		 RETURN FALSE
	END IF

	RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1155_verifica_conta(l_num)#
#-------------------------------------#

	DEFINE 	l_den  	LIKE plano_contas.den_conta,
					l_num		LIKE plano_contas.num_conta
	
	SELECT  DEN_CONTA
	  INTO l_den
	  FROM PLANO_CONTAS
	 WHERE COD_EMPRESA = p_cod_empresa
	 AND NUM_CONTA 		= l_num
	
	IF SQLCA.SQLCODE <> 0 THEN 
		RETURN FALSE
	ELSE
		IF INFIELD(num_conta_ini) THEN 
			 DISPLAY l_den TO den_conta_ini
		ELSE
			 DISPLAY  l_den TO den_conta_fim
		END IF 
		
		RETURN TRUE 
	
	END IF 
	
END FUNCTION

#------------------------#
FUNCTION  pol1155_popup()#
#------------------------#
   
   DEFINE p_codigo CHAR(25)
	 
	 IF INFIELD(num_conta_ini) OR INFIELD(num_conta_fim) THEN 
		   CALL log009_popup(8,10,"CONTAS","plano_contas",
		      "num_conta","den_conta","","S","") 
		         RETURNING p_codigo

		CALL log006_exibe_teclas("01 02 07", p_versao)

		CURRENT WINDOW IS w_pol1155

		IF p_codigo IS NOT NULL THEN
			 IF INFIELD(num_conta_ini) THEN 
				  LET p_entrada.num_conta_ini = p_codigo CLIPPED
				  DISPLAY p_codigo TO num_conta_ini
			 ELSE
				  LET p_entrada.num_conta_fim = p_codigo CLIPPED
				  DISPLAY p_codigo TO num_conta_fim
			 END IF 
		END IF
		
	END IF 

END FUNCTION

#------------------------------#
FUNCTION  pol1155_valida_data()#
#------------------------------#

	DEFINE l_con SMALLINT
	
	SELECT COUNT(PER_CONTABIL)
	  INTO l_con
	  FROM periodos
	 WHERE cod_empresa = p_cod_empresa
	   AND dat_ini_seg_per <= p_entrada.dat_movto_ini
	   AND dat_fim_seg_per >= p_entrada.dat_movto_fim
	
	IF l_con > 0 THEN 
		RETURN TRUE
	ELSE
		RETURN FALSE 
	END IF 
	
END FUNCTION

#-------------------------------------#
FUNCTION pol1155_pega_texto(l_num_rel)#
#-------------------------------------#

   DEFINE	l_num_rel				INTEGER,
				  l_seq						SMALLINT,
				  l_texto					CHAR(50),
				  l_texto1				CHAR(300)
	
   LET l_texto1 = ''
	
	 DECLARE cq_texto  CURSOR FOR 	
	  SELECT UNIQUE num_seq_linha, tex_hist
			FROM hist_compl, ctb_lanc_ctbl_ctb
		 WHERE hist_compl.cod_empresa		  =	p_cod_empresa
			 AND hist_compl.den_sistema_ger	=	p_diario.den_sistema_ger
			 AND hist_compl.per_contabil		=	p_diario.per_contabil
			 AND hist_compl.cod_seg_periodo	=	p_diario.cod_seg_periodo
			 AND hist_compl.num_lote				=	p_diario.num_lote
			 AND num_relacionto 						= l_num_rel
			 AND empresa                    = hist_compl.cod_empresa
			 AND sistema_gerador            = hist_compl.den_sistema_ger
			 AND periodo_contab             = hist_compl.per_contabil
			 AND segmto_periodo             = hist_compl.cod_seg_periodo
			 AND lote_contab                = hist_compl.num_lote
			 AND num_lancto                 = hist_compl.num_lanc
		 ORDER BY hist_compl.num_seq_linha
	
	FOREACH cq_texto INTO l_seq, l_texto  
	
	  IF STATUS <> 0 THEN
	     CALL log003_err_sql('Lendo','texto hit�rico')
	     RETURN FALSE
	  END IF
	  
		LET l_texto1 = l_texto1 CLIPPED,' ',l_texto CLIPPED
	
	END FOREACH
	
	LET p_texto = l_texto1

	RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION  pol1155_listar()#
#-------------------------#    

   DEFINE	l_per_contabil				INTEGER,
				  l_cod_seg_periodo			INTEGER,
				  l_num_rel							INTEGER,
				  l_cod_empresa_plano		CHAR(02),
				  l_sql									CHAR(100),
				  sql_stmt        			CHAR(2000)
				
   DROP TABLE lanc_temp
   
   CREATE  TABLE lanc_temp(
		num_seq      INTEGER,
		dat_movto    DATE,
		mes_movto    INTEGER,
		conta_deb    CHAR(23),
		conta_red_d  CHAR(10),
		conta_cred   CHAR(23),
		conta_red_c  CHAR(10),
		den_hist     CHAR(50),
		num_relac    INTEGER,
		val_deb      DECIMAL(12,2),
		val_cred     DECIMAL(12,2)
		)

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIACAO","LANC_TEMP")
			RETURN 
	 END IF
     
																										
	LET l_num_rel = 0		
	INITIALIZE p_relat TO NULL 															
	
	LET p_count = 0

	IF p_entrada.num_conta_ini IS NOT NULL THEN 
		 LET l_sql=" AND a.num_conta 	BETWEEN '" ,p_entrada.num_conta_ini,"' AND '",p_entrada.num_conta_fim,"' "
	ELSE
  	 LET l_sql = ' '
	END IF 
	
	LET sql_stmt = 	
	    "SELECT UNIQUE a.den_sistema_ger, a.per_contabil,	a.cod_seg_periodo,a.num_lote, a.dat_movto, ",
			"   a.ies_tip_lanc, a.num_conta,a.num_lanc, a.val_lanc, b.num_relacionto ",
			" FROM lancamentos a, ctb_lanc_ctbl_ctb b, plano_contas c ",
			"WHERE a.cod_empresa = '",p_cod_empresa,"' ",
				"AND a.dat_movto BETWEEN '",p_entrada.dat_movto_ini,"' AND '",p_entrada.dat_movto_fim,"' ",
				l_sql CLIPPED,
				" AND b.empresa = a.cod_empresa ",				
				"AND b.sistema_gerador = a.den_sistema_ger ",
				"AND b.periodo_contab = a.per_contabil ",
				"AND b.segmto_periodo = a.cod_seg_periodo ",
				"AND b.lote_contab = a.num_lote ",
				"AND b.num_lancto = a.num_lanc ",
				"AND a.cod_empresa = c.cod_empresa ",
				"AND a.num_conta= c.num_conta ",
				"ORDER BY a.dat_movto, b.num_relacionto , a.num_lanc "
	
	PREPARE var_queri FROM sql_stmt  
	DECLARE cq_conta SCROLL CURSOR WITH HOLD FOR var_queri
																								
													
	FOREACH cq_conta INTO 
					p_diario.den_sistema_ger,   							
					p_diario.per_contabil,	    							
					p_diario.cod_seg_periodo,   									
					p_diario.num_lote,												
					p_diario.dat_movto,         							
					p_diario.ies_tip_lanc,      							
					p_diario.num_conta,         							
					p_diario.num_lanc,          							
					p_diario.val_lanc,          							
					p_diario.num_relacionto   							

    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo', 'cursor cq_conta')
       RETURN
    END IF
    
    LET pr_men[1].mensagem = p_diario.num_conta
    CALL pol1155_exib_mensagem()

    SELECT num_conta_reduz
			INTO p_num_conta_reduz           																			
			FROM plano_contas
		 WHERE cod_empresa = p_cod_empresa
		   AND num_conta = p_diario.num_conta

    IF STATUS <> 0 THEN
       LET p_num_conta_reduz = NULL
    END IF
    
    IF l_num_rel <> 0 THEN
  	   IF l_num_rel <> p_diario.num_relacionto THEN 
 			    IF NOT pol1155_ins_temp() THEN
 			       RETURN FALSE
 			    END IF
    		  LET l_num_rel = 0
		   END IF  
    END IF
    
    IF l_num_rel = 0 THEN
 			 LET l_num_rel = p_diario.num_relacionto
			 CALL pol1155_pega_texto(l_num_rel)
			 LET p_relat.den_hist    = p_texto
       LET p_relat.dat_movto   = p_diario.dat_movto
       LET p_relat.mes_movto   = p_diario.cod_seg_periodo
       LET p_relat.num_relac   = p_diario.num_relacionto
 		END IF 

 		IF p_diario.ies_tip_lanc = 'D' THEN
       LET p_relat.conta_deb = p_diario.num_conta
       LET p_relat.val_deb = p_diario.val_lanc
       LET p_relat.conta_red_d = p_num_conta_reduz
    ELSE
       LET p_relat.conta_cred = p_diario.num_conta
       LET p_relat.val_cred = p_diario.val_lanc
       LET p_relat.conta_red_c = p_num_conta_reduz
    END IF
               
	END FOREACH

 	SELECT COUNT(num_seq)
 	  INTO p_count
 	  FROM lanc_temp

  IF STATUS <> 0 THEN
     CALL log003_err_sql('LENDO','LANC_TEMP')
     RETURN
  END IF
  
  IF p_count = 0 THEN
     LET p_msg = 'N�o h� lan�amentos, para\n',
                 'o per�odo informado.'
	   CALL log0030_mensagem(p_msg,'exclamation')
	   RETURN
	END IF
	
	CALL pol1155_listagem()
	   
END FUNCTION

#--------------------------#
FUNCTION pol1155_ins_temp()#
#--------------------------#
   
   LET p_count = p_count + 1
   
   LET p_relat.num_seq = p_count
   
   INSERT INTO lanc_temp
    VALUES(p_relat.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','LANC_TEMP')
      RETURN FALSE
   END IF
   
   INITIALIZE p_relat TO NULL
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1155_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men WITHOUT DEFAULTS FROM sr_men.*
    ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
    
      BEFORE INPUT
         EXIT INPUT
         
   END INPUT

END FUNCTION

#--------------------------#
FUNCTION pol1155_listagem()#
#--------------------------#

   IF NOT pol1155_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1155_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT * 
     FROM lanc_temp 
    ORDER BY dat_movto
  
   FOREACH cq_impressao INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      OUTPUT TO REPORT pol1155_relat(p_relat.dat_movto) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1155_relat   
   
   IF p_count = 0 THEN
      ERROR "N�o existem dados h� serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relat�rio impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relat�rio gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relat�rio gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1155_escolhe_saida()
#-------------------------------#

   #IF log0280_saida_relat(16,32) IS NULL THEN
   #   RETURN FALSE
   #END IF

   IF log028_saida_relat(18,35) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1155_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1155.tmp'
         START REPORT pol1155_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1155_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1155_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
 REPORT pol1155_relat(p_dat_movto)#
#---------------------------------#
    
   DEFINE p_dat_movto DATE
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_cod_empresa, ' - ', p_den_empresa, 
               COLUMN 058, "LANCAMENTOS CONTABEIS",
               COLUMN 124, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 001, p_versao,
               COLUMN 058, "PERIODO: ", p_entrada.dat_movto_ini, ' - ', p_entrada.dat_movto_fim,
               COLUMN 103, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 001, "             C O N T A                                                                                          V A L O R"
         PRINT COLUMN 001, "D E B I T O             C R E D I T O           H I S T O R I C O                                       D E B I T O    C R E D I T O"
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------"

      BEFORE GROUP OF p_dat_movto
         
         PRINT
         PRINT COLUMN 001, p_relat.dat_movto
         PRINT
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.conta_deb,
               COLUMN 025, p_relat.conta_cred, 
               COLUMN 049, p_relat.den_hist,
               COLUMN 100, p_relat.val_deb  USING '#,###,###,##&.&&',
               COLUMN 117, p_relat.val_cred USING '#,###,###,##&.&&'
      
      AFTER GROUP OF p_dat_movto
      
         PRINT
         PRINT COLUMN 086, 'Total do dia:', 
               COLUMN 100, GROUP SUM(p_relat.val_deb)  USING '#,###,###,##&.&&',
               COLUMN 117, GROUP SUM(p_relat.val_cred) USING '#,###,###,##&.&&'
                              
      ON LAST ROW 

         PRINT
         PRINT COLUMN 082, 'Total do periodo:', 
               COLUMN 100, SUM(p_relat.val_deb)  USING '#,###,###,##&.&&',
               COLUMN 117, SUM(p_relat.val_cred) USING '#,###,###,##&.&&'

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#
