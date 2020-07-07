#-----------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                       #
# PROGRAMA: pol1107                                                     #
# OBJETIVO: Informações Adicionais de Planejamento para Itens Comprados #
# AUTOR...: PAULO CESAR MARTINEZ                                        #
# DATA....: 29/08/2011                                                  #
#-----------------------------------------------------------------------#

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
          p_opcao              CHAR(01),
          p_den_item_reduz     CHAR(34),
          p_den_origem         CHAR(30),
          p_den_ref            CHAR(30),
          p_cod_item           CHAR(15),
          p_nom_cliente        CHAR(36),
          p_cod_cliente        CHAR(15),
          p_cod_exibe          CHAR(7),
          p_ies_tip_item       CHAR(1),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_excluiu            SMALLINT
         
  
   DEFINE p_man_par_prog_454   RECORD LIKE man_par_prog_454.*

   DEFINE p_item               LIKE man_par_prog_454.item,
          p_item_ant           LIKE man_par_prog_454.item
          
   DEFINE p_relat              RECORD LIKE man_par_prog_454.*      
          
END GLOBALS

DEFINE p_origem      RECORD
   cod_lin_prod         decimal(2,0),
   qtd_periodo_firme    INTEGER
END RECORD

DEFINE   p_den_linha    char(20)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1107-10.02.06"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1107_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1107_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1107") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1107 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1107_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1107_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1107_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1107_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1107_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cfop_orig TO cfop_orig
               DISPLAY p_cfop_ref TO cfop_ref
               
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1107_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1107_listagem()
      COMMAND "Período firme" "Alteração de período firme"
         IF pol1107_periodo_firme() THEN
            ERROR 'Operação efetuada com sucesso'
         ELSE
            ERROR 'Operação cancelada'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	    	CALL pol1107_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1107

END FUNCTION

#--------------------------#
 FUNCTION pol1107_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cod_cliente TO NULL
   INITIALIZE p_man_par_prog_454.* TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1107_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      LET p_man_par_prog_454.empresa = p_cod_empresa
      INSERT INTO man_par_prog_454 VALUES (p_man_par_prog_454.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","man_par_prog_454")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1107_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT p_man_par_prog_454.item,   
         p_man_par_prog_454.cod_frequencia,
         p_man_par_prog_454.qtd_periodo_firme,
         p_man_par_prog_454.qtd_lote_minimo,
         p_man_par_prog_454.qtd_lote_multiplo,
         p_man_par_prog_454.qtd_periodo_antec
      WITHOUT DEFAULTS
         FROM item,
              cod_frequencia,
              qtd_periodo_firme,
              qtd_lote_minimo,
              qtd_lote_multiplo,
              qtd_periodo_antec
                       
      BEFORE FIELD item
      IF p_funcao = "M" THEN
         NEXT FIELD cod_frequencia
      END IF
      
      AFTER FIELD item
      IF p_man_par_prog_454.item IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD item   
      END IF
          
      SELECT cod_item
        INTO p_man_par_prog_454.item
        FROM item
       WHERE cod_item = p_man_par_prog_454.item
       AND cod_empresa = p_cod_empresa
         
      IF STATUS = 100 THEN 
         ERROR 'Código do Item não cadastrado na tabela Item!!!'
         NEXT FIELD Item
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','item')
            RETURN FALSE
         END IF 
      END IF  
     
      SELECT item
        FROM man_par_prog_454
       WHERE item = p_man_par_prog_454.item
       AND empresa = p_cod_empresa
       

      
      IF STATUS = 0 THEN
         ERROR "item já cadastrado!!!"
         NEXT FIELD cfop_orig
      ELSE 
         IF STATUS <> 100 THEN   
            CALL log003_err_sql('lendo','man_par_prog_454')
            RETURN FALSE
         END IF 
      END IF    

   		SELECT den_item_reduz, ies_tip_item
     	INTO p_den_origem, p_ies_tip_item
     	FROM item
    	WHERE cod_item = p_man_par_prog_454.item
    	AND cod_empresa = p_cod_empresa
   		DISPLAY p_den_origem TO den_item   

      IF p_ies_tip_item <> 'B' THEN
      	IF p_ies_tip_item <> 'C' THEN
         	ERROR "Item Inválido não é Beneficiado e nem Comprado!!!"
         	NEXT FIELD item
        END IF 	
      END IF    

      AFTER FIELD cod_frequencia
      IF p_man_par_prog_454.cod_frequencia IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_frequencia   
      END IF
      
      IF p_man_par_prog_454.cod_frequencia > '5' THEN 
         ERROR "Código de frequencia inválido!!!"
         NEXT FIELD cod_frequencia   
      END IF
      
      IF p_man_par_prog_454.cod_frequencia = '1' THEN
      	LET p_den_ref = 'Diária'
      END IF
      IF p_man_par_prog_454.cod_frequencia = '2' THEN
      	LET p_den_ref = 'Semanal'
      END IF
      IF p_man_par_prog_454.cod_frequencia = '3' THEN
      	LET p_den_ref = 'Decendial'
      END IF
      IF p_man_par_prog_454.cod_frequencia = '4' THEN
      	LET p_den_ref = 'Quinzenal'
      END IF
      IF p_man_par_prog_454.cod_frequencia = '5' THEN
      	LET p_den_ref = 'Mensal'
      END IF

      DISPLAY p_den_ref TO den_frequencia

          
      AFTER FIELD qtd_periodo_firme
      IF p_man_par_prog_454.qtd_periodo_firme IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD qtd_periodo_firme   
      END IF

      AFTER FIELD qtd_lote_minimo
      IF p_man_par_prog_454.qtd_lote_minimo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD qtd_lote_minimo   
      END IF

      AFTER FIELD qtd_lote_multiplo
      IF p_man_par_prog_454.qtd_lote_multiplo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD qtd_lote_multiplo   
      END IF

      AFTER FIELD qtd_periodo_antec
      IF p_man_par_prog_454.qtd_periodo_antec IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD qtd_periodo_antec   
      END IF

     
      
      ON KEY (control-z)
         CALL pol1107_popup()
           

   END INPUT 
   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
  FUNCTION pol1107_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)


   CASE
      WHEN INFIELD(item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1107
         IF p_codigo IS NOT NULL THEN
           LET p_man_par_prog_454.item = p_codigo
           DISPLAY p_codigo TO item
   				 SELECT den_item_reduz
     			 INTO p_den_origem
     			 FROM item
    			 WHERE cod_item = p_codigo
    			 AND cod_empresa = p_cod_empresa
   				 DISPLAY p_den_origem TO den_item   
         END IF

      WHEN INFIELD(cod_lin_prod)
         CALL log009_popup(8,5,"LINHA DE PRODUTO","linha_prod",
            "cod_lin_prod","den_estr_linprod","","N",
            " 1=1 and cod_lin_recei = 0 and cod_seg_merc = 0 and cod_cla_uso = 0") 
            RETURNING p_codigo
         CURRENT WINDOW IS w_pol1107a
         IF p_codigo IS NOT NULL THEN
            LET p_origem.cod_lin_prod = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_lin_prod
         END IF

   END CASE 


END FUNCTION 

#--------------------------#
 FUNCTION pol1107_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_item_ant = p_item
   LET p_item_ant = p_item
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      man_par_prog_454.item
      ON KEY (control-z)
         CALL pol1107_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_item = p_item_ant
            LET p_item = p_item_ant
            CALL pol1107_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   IF (p_item IS NOT NULL)  THEN
   		LET sql_stmt = "SELECT item, cod_frequencia,qtd_periodo_firme,qtd_lote_minimo,qtd_lote_multiplo,qtd_periodo_antec ",
                  	 "  FROM man_par_prog_454 ",
                     " WHERE ", where_clause CLIPPED,
                     " ORDER BY item"
  ELSE                   
   		LET sql_stmt = "SELECT item, cod_frequencia,qtd_periodo_firme,qtd_lote_minimo,qtd_lote_multiplo,qtd_periodo_antec ",
                  	 "  FROM man_par_prog_454 ",
                     " ORDER BY item"
 	END IF
   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_item

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1107_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1107_exibe_dados()
#------------------------------#
   LET p_cod_exibe = ""
   
   SELECT item, 
          cod_frequencia,
          qtd_periodo_firme,
          qtd_lote_minimo,
          qtd_lote_multiplo,
          qtd_periodo_antec
     INTO p_man_par_prog_454.item,
          p_man_par_prog_454.cod_frequencia,
          p_man_par_prog_454.qtd_periodo_firme,
          p_man_par_prog_454.qtd_lote_minimo,
          p_man_par_prog_454.qtd_lote_multiplo,
          p_man_par_prog_454.qtd_periodo_antec
     FROM man_par_prog_454
    WHERE item = p_item
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "man_par_prog_454")
      RETURN FALSE
   END IF
   
	 DISPLAY p_man_par_prog_454.item              TO Item
	 DISPLAY p_man_par_prog_454.cod_frequencia    TO cod_frequencia
	 DISPLAY p_man_par_prog_454.qtd_periodo_firme TO qtd_periodo_firme
	 DISPLAY p_man_par_prog_454.qtd_lote_minimo   TO qtd_lote_minimo
	 DISPLAY p_man_par_prog_454.qtd_lote_multiplo TO qtd_lote_multiplo
	 DISPLAY p_man_par_prog_454.qtd_periodo_antec TO qtd_periodo_antec
   
   
   SELECT den_item_reduz
   INTO p_den_origem
   FROM item
   WHERE cod_item = p_man_par_prog_454.item
   AND cod_empresa = p_cod_empresa
   DISPLAY p_den_origem TO den_item   

   IF p_man_par_prog_454.cod_frequencia = '1' THEN
   		LET p_den_ref = 'Diária'
   END IF
   IF p_man_par_prog_454.cod_frequencia = '2' THEN
      LET p_den_ref = 'Semanal'
   END IF
   IF p_man_par_prog_454.cod_frequencia = '3' THEN
   		LET p_den_ref = 'Decendial'
   END IF
   IF p_man_par_prog_454.cod_frequencia = '4' THEN
     	LET p_den_ref = 'Quinzenal'
   END IF
   IF p_man_par_prog_454.cod_frequencia = '5' THEN
      LET p_den_ref = 'Mensal'
   END IF

   DISPLAY p_den_ref TO den_frequencia

      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1107_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_item_ant = p_item
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_item
      
      END CASE

      IF STATUS = 0 THEN
   			SELECT item, 
          		 cod_frequencia,
          		 qtd_periodo_firme,
               qtd_lote_minimo,
               qtd_lote_multiplo,
               qtd_periodo_antec
        FROM man_par_prog_454
        WHERE item = p_item
        AND empresa = p_cod_empresa

            
         IF STATUS = 0 THEN
            CALL pol1107_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_item = p_item_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1107_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
   	SELECT item, 
           cod_frequencia,
           qtd_periodo_firme,
           qtd_lote_minimo,
           qtd_lote_multiplo,
           qtd_periodo_antec
    FROM man_par_prog_454
    WHERE item = p_item
    AND empresa = p_cod_empresa
    FOR UPDATE 
    
    OPEN cq_prende
    FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","man_par_prog_454")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1107_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_item    = p_man_par_prog_454.item
   
   IF pol1107_prende_registro() THEN
      IF pol1107_edita_dados("M") THEN
         
         UPDATE man_par_prog_454
            SET item              = p_man_par_prog_454.item,
                cod_frequencia    = p_man_par_prog_454.cod_frequencia,
                qtd_periodo_firme = p_man_par_prog_454.qtd_periodo_firme,
                qtd_lote_minimo   = p_man_par_prog_454.qtd_lote_minimo,
                qtd_lote_multiplo = p_man_par_prog_454.qtd_lote_multiplo,
                qtd_periodo_antec = p_man_par_prog_454.qtd_periodo_antec
          WHERE item  = p_item
          AND empresa = p_cod_empresa
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "man_par_prog_454")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1107_exibe_dados() RETURNING p_status
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol1107_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   LET p_item = p_man_par_prog_454.item

   IF pol1107_prende_registro() THEN
      DELETE FROM man_par_prog_454
			WHERE item  = p_item
			AND empresa = p_cod_empresa

      IF STATUS = 0 THEN               
         INITIALIZE p_man_par_prog_454 TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","man_par_prog_454")
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#--------------------------#
 FUNCTION pol1107_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1107_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1107_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT empresa,
   				item,
   				cod_frequencia,
   				qtd_periodo_firme,
   				qtd_lote_minimo,
   				qtd_lote_multiplo,
   				qtd_periodo_antec
     FROM man_par_prog_454
 ORDER BY item                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT den_item_reduz
      INTO p_den_origem
      FROM item
      WHERE cod_item = p_relat.item
      AND cod_empresa = p_cod_empresa
      

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'man_par_prog_454')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1107_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1107_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1107_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1107.tmp"
         START REPORT pol1107_relat TO p_caminho
      ELSE
         START REPORT pol1107_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1107_le_den_empresa()
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

#---------------------#
 REPORT pol1107_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1107",
               COLUMN 005, "Informações Adicionais de Planejamento para Itens Comprados",
               COLUMN 075, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "-------------------------------------------------------------------------------------"
         PRINT
#                                   1         2         3         4         5         6         7         8  
#                          123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 002, '     Item              Descrição           Freq   Per.     Lote        Lote     Per. '
         PRINT COLUMN 002, '                                                 Firme     Min.        Mult.   Antec.'
         PRINT COLUMN 002, '--------------- -------------------------- ---- ------- ----------  ---------- ------'
                            
      ON EVERY ROW

         PRINT COLUMN 002, p_relat.item [1,15],
               COLUMN 018, p_den_origem [1,26],
               COLUMN 047, p_relat.cod_frequencia,
               COLUMN 051, p_relat.qtd_periodo_firme USING '#####',
               COLUMN 056, p_relat.qtd_lote_minimo, #USING '#######,###',
               COLUMN 066, p_relat.qtd_lote_multiplo, #USING '#######,###',
               COLUMN 081, p_relat.qtd_periodo_antec USING '#####'
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------#   
 FUNCTION pol1107_carrega_item() 
#-------------------------------#
 
    DEFINE pr_item       ARRAY[3000]
     OF RECORD
         cod_item          LIKE item.cod_item,
         den_item          LIKE item.den_item
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol11071") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol11071 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_item CURSOR FOR 
   SELECT i.cod_item,i.den_item
   FROM   ped_itens p, item i
   WHERE  p.num_pedido = p_pedido_volvo_512.num_pedido
   AND i.cod_empresa   = p_cod_empresa
   AND p.cod_empresa   = i.cod_empresa
   AND p.cod_item      = i.cod_item
   ORDER BY i.den_item

   LET pr_index = 1

   FOREACH cq_item INTO pr_item[pr_index].cod_item,
                        pr_item[pr_index].den_item
                         
      LET pr_index = pr_index + 1
       IF pr_index > 3000 THEN
         ERROR "Limit e de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_item TO sr_item.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
  CLOSE WINDOW w_pol11071

   RETURN pr_item[pr_index].cod_item
      
END FUNCTION 


#-----------------------#
 FUNCTION pol1107_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
FUNCTION pol1107_periodo_firme()#
#-------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1107a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1107a AT 06,12 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_status = FALSE
   
   IF pol1107_info_origem() THEN
      CALL log085_transacao("BEGIN")
      IF NOT pol1107_grava_periodo() THEN
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         LET p_status = TRUE
      END IF
   END IF
         
   CLOSE WINDOW w_pol1107a
   
   RETURN p_status
   
END FUNCTION

#-----------------------------#
FUNCTION pol1107_info_origem()#
#-----------------------------#

   LET INT_FLAG = FALSE
   INITIALIZE p_origem TO NULL
   
   INPUT BY NAME p_origem.*
     WITHOUT DEFAULTS

   AFTER FIELD cod_lin_prod
      
      CALL pol1107_le_linha(p_origem.cod_lin_prod, 0, 0, 0)
      
      IF p_den_linha IS NULL THEN
         ERROR 'Linha de produção inexistente'
         NEXT FIELD cod_lin_prod
      END IF
      
      DISPLAY p_den_linha TO den_linha
      
      ON KEY (Control-z)
         CALL pol1107_popup()
      
      AFTER INPUT
      
         IF NOT INT_FLAG THEN
            IF p_origem.qtd_periodo_firme IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório.'
               NEXT FIELD qtd_periodo_firme
            END IF
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   RETURN TRUE

END FUNCTION

#--------------------------------------------------------------------#
FUNCTION pol1107_le_linha(p_cod_lin, p_cod_rec, p_cod_seg, p_cod_cla)#
#--------------------------------------------------------------------#

   DEFINE p_cod_lin, p_cod_rec, p_cod_seg, p_cod_cla DECIMAL(2,0)
   
   SELECT den_estr_linprod
     INTO p_den_linha
     FROM linha_prod
    WHERE cod_lin_prod = p_cod_lin
      AND cod_lin_recei = p_cod_rec
      AND cod_seg_merc = p_cod_seg
      AND cod_cla_uso = p_cod_cla
   
   IF STATUS <> 0 THEN
      LET p_den_linha = NULL
   END IF
   
END FUNCTION

#-------------------------------#      
FUNCTION pol1107_grava_periodo()#
#-------------------------------#

   DECLARE cq_peri CURSOR FOR
    SELECT m.item
      FROM man_par_prog_454 m, item i
     WHERE i.cod_empresa = p_cod_empresa
       AND i.cod_empresa = m.empresa
       AND i.cod_item = m.item
       AND i.cod_lin_prod = p_origem.cod_lin_prod
   
   FOREACH cq_peri INTO p_cod_item
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_peri')
         RETURN FALSE
      END IF
      
      UPDATE man_par_prog_454
         SET qtd_periodo_firme = p_origem.qtd_periodo_firme
       WHERE empresa = p_cod_empresa
         AND item    = p_cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','man_par_prog_454')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#-------------------------------- FIM DE PROGRAMA -----------------------------#