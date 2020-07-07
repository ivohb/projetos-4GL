#-------------------------------------------------------------------#
# PROGRAMA: pol1083                                                 #
# OBJETIVO: FRETE DE SAIDA - CIBRAPEL                               #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 18/03/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_val_liq            LIKE fat_nf_item.val_liquido_item,
          p_retorno            SMALLINT,
          p_val_icms_c         DECIMAL(10,2),
          p_imprimiu           SMALLINT,
          p_msg                CHAR(300),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_normal             CHAR(02),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_ies_conf           SMALLINT,
          p_caminho            CHAR(080),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_query              CHAR(600),
          where_clause         CHAR(500),
          p_trans_nf           INTEGER,
		  p_cod_status         CHAR(05),
		  p_erro			    SMALLINT,
          p_mensagem           CHAR(30)
		  
		  
	   DEFINE l_fat_nf_item_fisc    RECORD LIKE fat_nf_item_fisc.*,
          p_mest_fisc               RECORD LIKE fat_mestre_fiscal.*,
          p_bc_tributo_tot          LIKE  fat_nf_item_fisc.bc_tributo_tot,
          p_seq_item_nf	            LIKE  fat_nf_item_fisc.seq_item_nf	  
          
   DEFINE p_tela               RECORD
      cod_nat_oper             INTEGER,
      den_nat_oper             CHAR(30),
      dat_ini                  DATE,
      dat_fim                  DATE
   END RECORD 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1083-10.02.04"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1083.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1083_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1083_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1083") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1083 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para o processamento"
         CALL pol1083_informar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            NEXT OPTION 'Processar'
         ELSE
            LET p_ies_cons = FALSE
         END IF
      COMMAND "Processar" "Processa o acerto da base de cálculo"
         IF log005_seguranca(p_user,"VDP","pol1083","IN")  THEN
            IF p_ies_cons THEN
			
			   CALL log085_transacao('BEGIN')   
               CALL pol1083_processar() RETURNING p_status
               IF p_status THEN
			       CALL log085_transacao('COMMIT')   
                  ERROR 'Operação efetuada com sucesso !!!'
               ELSE
			      CALL log085_transacao('ROLLBACK') 
                  ERROR 'Operação cancelada !!!'
               END IF
            ELSE
               ERROR 'Informe os parâmetros previamente !!!'
            END IF
         END IF 
         MESSAGE ''
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1083_sobre() 			
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1083

END FUNCTION

#-----------------------#
FUNCTION pol1083_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1083_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL

END FUNCTION

#--------------------------#
FUNCTION pol1083_informar()
#--------------------------#

   CALL pol1083_limpa_tela()
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
      
         
      AFTER FIELD cod_nat_oper
      
         IF p_tela.cod_nat_oper IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD cod_nat_oper
         END IF
         
         SELECT den_nat_oper                              
           INTO p_tela.den_nat_oper                          
           FROM nat_operacao                                 
          WHERE cod_nat_oper = p_tela.cod_nat_oper           
                                                             
         IF STATUS <> 0 THEN                                 
            CALL log003_err_sql('Lendo','item')              
            NEXT FIELD cod_nat_oper                          
         END IF                                              
         DISPLAY p_tela.den_nat_oper TO den_nat_oper         
            
      AFTER INPUT
         IF NOT INT_FLAG THEN   
            IF p_tela.dat_ini IS NULL THEN
               ERROR 'Informe a data inicial !!!'
               NEXT FIELD dat_ini
            END IF
            IF p_tela.dat_fim IS NULL THEN
               ERROR 'Informe a data final !!!'
               NEXT FIELD dat_fim
            END IF
            IF p_tela.dat_fim > TODAY THEN
               ERROR 'Data final deve ser menor ou igual a data de hoje !!!'
               NEXT FIELD dat_fim
            END IF
            IF p_tela.dat_ini > p_tela.dat_fim THEN
               ERROR "Data Inicial nao pode ser maior que data Final"
               NEXT FIELD dat_ini
            END IF 
            {IF p_tela.dat_fim - p_tela.dat_ini > 365 THEN 
               ERROR "Periodo nao pode ser maior que 720 Dias"
               NEXT FIELD dat_ini
            END IF}
         END IF

      ON KEY (control-z)
         CALL pol1083_popup()
         
   END INPUT
   
   IF INT_FLAG THEN
      CALL pol1083_limpa_tela()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1083_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
   
      WHEN INFIELD(cod_nat_oper)
         CALL log009_popup(8,25,"NATUREZA DE OPERAÇÃO","nat_operacao",
                     "cod_nat_oper","den_nat_oper","","N"," 1=1 order by den_nat_oper") 
            RETURNING p_codigo
         
         CALL log006_exibe_teclas("01", p_versao)
         CURRENT WINDOW IS w_pol1083
         
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_nat_oper = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_nat_oper
         END IF

   END CASE
   

END FUNCTION

#--------------------------#
FUNCTION pol1083_processar()
#--------------------------#

   IF NOT log004_confirm(06,05) THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_nf CURSOR WITH HOLD FOR
    SELECT trans_nota_fiscal
      FROM fat_nf_mestre
     WHERE empresa = p_cod_empresa
       AND natureza_operacao = p_tela.cod_nat_oper
	   and cliente= '060620366000195'
       AND DATE (dat_hor_emissao) BETWEEN p_tela.dat_ini AND p_tela.dat_fim
   
   FOREACH cq_nf INTO p_trans_nf    

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_nf')
         RETURN FALSE
      END IF
      
      LET p_mensagem = 'Processando! ', p_trans_nf
      MESSAGE p_mensagem 
      
	  CALL  pol1083_acerta_item()
	   
	  CALL  pol1083_acerta_total()
      

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1083_acerta_item()
#--------------------------#


	DECLARE cq_it CURSOR WITH HOLD FOR
    SELECT seq_item_nf,
	       bc_tributo_tot	   
      FROM fat_nf_item_fisc
     WHERE empresa = p_cod_empresa
	   AND trans_nota_fiscal=p_trans_nf
	   AND tributo_benef='IPI'
	   
   FOREACH cq_it INTO p_seq_item_nf, p_bc_tributo_tot    
	  
	  INITIALIZE l_fat_nf_item_fisc   TO  NULL


#----Acerta PIS 
	  
	  SELECT * 
	  INTO   l_fat_nf_item_fisc.*
	  FROM fat_nf_item_fisc
     WHERE empresa          = p_cod_empresa
	   AND trans_nota_fiscal= p_trans_nf
	   AND seq_item_nf      = p_seq_item_nf
	   AND tributo_benef    ='PIS_REC'
	   
	  LET  l_fat_nf_item_fisc.bc_trib_mercadoria = p_bc_tributo_tot
	  LET  l_fat_nf_item_fisc.bc_tributo_tot     = p_bc_tributo_tot
	  LET  l_fat_nf_item_fisc.val_trib_merc      = p_bc_tributo_tot * (l_fat_nf_item_fisc.aliquota / 100)
	  LET  l_fat_nf_item_fisc.val_tributo_tot    = p_bc_tributo_tot * (l_fat_nf_item_fisc.aliquota / 100)
	  
      UPDATE  FAT_NF_ITEM_FISC
	     SET  	
		 bc_trib_mercadoria = l_fat_nf_item_fisc.bc_trib_mercadoria,
	     bc_tributo_tot     = l_fat_nf_item_fisc.bc_tributo_tot, 
	     val_trib_merc      = l_fat_nf_item_fisc.val_trib_merc,
	     val_tributo_tot    = l_fat_nf_item_fisc.val_tributo_tot
     WHERE empresa = p_cod_empresa
	   AND trans_nota_fiscal=p_trans_nf
	   AND seq_item_nf      = p_seq_item_nf 
	   AND tributo_benef='PIS_REC'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Update','fat_nf_item_fisc - PIS_REC')
         RETURN FALSE
      END IF
      

#----Acerta COFINS  
	  
	  SELECT * 
	  INTO   l_fat_nf_item_fisc.*
	  FROM fat_nf_item_fisc
     WHERE empresa          = p_cod_empresa
	   AND trans_nota_fiscal=p_trans_nf
	   AND seq_item_nf      = p_seq_item_nf
	   AND tributo_benef    ='COFINS_REC'
	   
	  LET  l_fat_nf_item_fisc.bc_trib_mercadoria = p_bc_tributo_tot
	  LET  l_fat_nf_item_fisc.bc_tributo_tot     = p_bc_tributo_tot
	  LET  l_fat_nf_item_fisc.val_trib_merc      = p_bc_tributo_tot * (l_fat_nf_item_fisc.aliquota / 100)
	  LET  l_fat_nf_item_fisc.val_tributo_tot    = p_bc_tributo_tot * (l_fat_nf_item_fisc.aliquota / 100)
	  
      UPDATE  FAT_NF_ITEM_FISC 	     SET  	
		 bc_trib_mercadoria = l_fat_nf_item_fisc.bc_trib_mercadoria,
	     bc_tributo_tot     = l_fat_nf_item_fisc.bc_tributo_tot, 
	     val_trib_merc      = l_fat_nf_item_fisc.val_trib_merc,
	     val_tributo_tot    = l_fat_nf_item_fisc.val_tributo_tot
     WHERE empresa = p_cod_empresa
	   AND trans_nota_fiscal=p_trans_nf
	   AND seq_item_nf      = p_seq_item_nf 
	   AND tributo_benef='COFINS_REC'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Update','fat_nf_item_fisc - COFINS_REC')
         RETURN FALSE
      END IF	  
	  
    END FOREACH  
	  
END FUNCTION
#--------------------------#
FUNCTION pol1083_acerta_total()
#--------------------------#

    DECLARE cq_sum CURSOR FOR
       SELECT tributo_benef,
           SUM(bc_trib_mercadoria),
           SUM(bc_tributo_tot),
           SUM(val_trib_merc),
           SUM(val_tributo_tot)
      FROM fat_nf_item_fisc
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = p_trans_nf
	   AND tributo_benef in('COFINS_REC', 'PIS_REC', 'IPI')
     GROUP BY tributo_benef

    FOREACH cq_sum INTO 
           p_mest_fisc.tributo_benef,
           p_mest_fisc.bc_trib_mercadoria,
           p_mest_fisc.bc_tributo_tot,
           p_mest_fisc.val_trib_merc,
           p_mest_fisc.val_tributo_tot
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_item_fisc')
         RETURN FALSE
      END IF

	  
	  IF p_mest_fisc.tributo_benef = 'IPI'  THEN 
	  
          UPDATE fat_mestre_fiscal set 
               bc_trib_mercadoria = p_mest_fisc.bc_trib_mercadoria,
               bc_tributo_tot = p_mest_fisc.bc_tributo_tot,
               val_trib_merc = p_mest_fisc.val_trib_merc,
               val_tributo_tot = p_mest_fisc.val_tributo_tot
           WHERE empresa = p_cod_empresa
           AND trans_nota_fiscal = p_trans_nf
    	   AND tributo_benef = 'IPI'	   
    
          IF STATUS <> 0 THEN
             LET p_msg = 'ERRO ', p_cod_status, 'INSERINDO DADOS DA TABELA FAT_MESTRE_FISCAL 1'
             CALL pol0989_imprime_erros(p_msg)
	           LET p_erro = TRUE 
             RETURN FALSE
          END IF
	   END IF 
	   
	  

	  IF p_mest_fisc.tributo_benef = 'COFINS_REC'  THEN 
	  
          UPDATE fat_mestre_fiscal set 
               bc_trib_mercadoria = p_mest_fisc.bc_trib_mercadoria,
               bc_tributo_tot = p_mest_fisc.bc_tributo_tot,
               val_trib_merc = p_mest_fisc.val_trib_merc,
               val_tributo_tot = p_mest_fisc.val_tributo_tot
           WHERE empresa = p_cod_empresa
           AND trans_nota_fiscal = p_trans_nf
    	   AND tributo_benef = 'COFINS_REC'	   
    
          IF STATUS <> 0 THEN
             LET p_msg = 'ERRO ', p_cod_status, 'INSERINDO DADOS DA TABELA FAT_MESTRE_FISCAL 2'
             CALL pol0989_imprime_erros(p_msg)
	           LET p_erro = TRUE 
             RETURN FALSE
          END IF
	   END IF 
	   
	   
      IF p_mest_fisc.tributo_benef = 'PIS_REC' THEN 
         UPDATE fat_mestre_fiscal set 
               bc_trib_mercadoria = p_mest_fisc.bc_trib_mercadoria,
               bc_tributo_tot = p_mest_fisc.bc_tributo_tot,
               val_trib_merc = p_mest_fisc.val_trib_merc,
               val_tributo_tot = p_mest_fisc.val_tributo_tot
           WHERE empresa = p_cod_empresa
           AND trans_nota_fiscal = p_trans_nf
    	   AND tributo_benef='PIS_REC'	   
    
          IF STATUS <> 0 THEN
             LET p_msg = 'ERRO ', p_cod_status, 'UPDATE PIS_REC DADOS DA TABELA FAT_MESTRE_FISCAL 3'
             CALL pol0989_imprime_erros(p_msg)
	           LET p_erro = TRUE 
             RETURN FALSE
          END IF
       END IF 		  
   
     END FOREACH
END FUNCTION