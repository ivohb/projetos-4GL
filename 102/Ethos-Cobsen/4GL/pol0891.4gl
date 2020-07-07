#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# CLIENTE.: ETHOS                                                   # 
# PROGRAMA: pol0891                                                 #
# OBJETIVO: CADASTRO APONTAMENTO ORDEM DE PRODUCAO                  #
# AUTOR...: MARCELO                                                 #
# DATA....: 21/11/2008                                              #
#         : 27/11/2008 - Se tiver data de atualizacao nao deixar    #
#                        modificar, ja processado                   #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
	DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
	       p_den_empresa        LIKE empresa.den_empresa,
	       p_user               LIKE usuario.nom_usuario,
         p_processando        LIKE proc_apont_man912.processando,
         p_hora_ini           LIKE proc_apont_man912.hor_ini,
         p_hor_atu            LIKE proc_apont_man912.hor_ini,
         p_time               DATETIME HOUR TO SECOND,
         p_hor_proces         CHAR(10),
         p_qtd_segundo        INTEGER,
         p_resp               CHAR(01),        
	       p_erro_critico       SMALLINT,
	       p_last_row           SMALLINT,
	       P_Comprime           CHAR(01),
	       p_descomprime        CHAR(01),
         p_6lpp               CHAR(02),
         p_8lpp               CHAR(02),
         sql_stmt_1           CHAR(300),
         where_clause         CHAR(300),
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
	       p_nom_help           CHAR(200),
	       p_ies_cons           SMALLINT,
	       p_caminho            CHAR(080),
	       p_msg                CHAR(500)             

  DEFINE p_man_apont_547       RECORD LIKE man_apont_547.*,
         p_man_apont_547a      RECORD LIKE man_apont_547.*,
         p_man_apont_hist_547  RECORD LIKE man_apont_hist_547.*         
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 3
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0891-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0891.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0891_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0891_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0891") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0891 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 001
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0891_consulta_547()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0891_modifica_547()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0891_exclui_547()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0891_paginacao_547("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0891_paginacao_547("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 006
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0891","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0891_relat_547 TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0891.tmp'
                     START REPORT pol0891_relat_547  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0891_relat_547 TO p_nom_arquivo
               END IF
               CALL pol0891_emite_relatorio_547()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0891_relat_547   
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0891_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 007
         MESSAGE ""
         LET INT_FLAG = 0
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0891

END FUNCTION
#-------------------------------#
 FUNCTION pol0891_consulta_547()
#-------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa
   LET p_man_apont_547a.* = p_man_apont_547.*

   CONSTRUCT BY NAME where_clause ON
       man_apont_547.item, man_apont_547.num_ordem
          
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0891

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_man_apont_547.* = p_man_apont_547a.*
      CALL pol0891_exibe_dados_547()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt_1 = "SELECT rowid FROM man_apont_547 ",
                    " WHERE ", where_clause CLIPPED,
                    "   AND empresa = '",p_cod_empresa,"' ",
                    "   ORDER BY num_ordem, dat_ini_producao, sequencia_operacao "

   PREPARE var_query1 FROM sql_stmt_1
   DECLARE cq_padrao1 SCROLL CURSOR WITH HOLD FOR var_query1
   OPEN cq_padrao1
   FETCH cq_padrao1 INTO p_rowid
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      SELECT *
        INTO p_man_apont_547.*
        FROM man_apont_547
       WHERE rowid = p_rowid
      CALL pol0891_exibe_dados_547()
   END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION pol0891_entrada_547(p_funcao)
#--------------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0891
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_man_apont_547.* TO NULL
      CALL pol0891_exibe_dados_547()
   END IF

   INPUT BY NAME p_man_apont_547.* 
      WITHOUT DEFAULTS        
      
      AFTER FIELD item
      
      #
      #  SELECT den_item FROM item
      #         WHERE cod_empresa = p_cod_empresa AND
      #               cod_item = p_man_apont_547.item
      #
      #  IF STATUS <> 0 THEN
      #     CALL log0030_mensagem('Código do item não cadastrado!','exclamation')
      #     NEXT FIELD item
      #  END IF              
      # 
      #AFTER FIELD operacao
      #
      #  SELECT den_operac FROM operacao
      #         WHERE cod_empresa = p_cod_empresa AND
      #               cod_operac = p_man_apont_547.operacao
      #
      #  IF STATUS <> 0 THEN
      #     CALL log0030_mensagem('Código de operação não cadastrado!','exclamation')
      #     NEXT FIELD operacao
      #  END IF         
      #
      #AFTER FIELD centro_trabalho     
      #
      #  SELECT den_cent_trab FROM cent_trabalho
      #         WHERE cod_empresa = p_cod_empresa AND
      #               cod_cent_trab = p_man_apont_547.centro_trabalho
      # 
      #  IF STATUS <> 0 THEN
      #     CALL log0030_mensagem('Código do centro de trabalho não cadastrado!','exclamation')
      #     NEXT FIELD centro_trabalho
      #  END IF         
      #  
      #  
      #ON KEY (control-z)
      #   CALL pol0891_popup()         
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0891

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol0891_exibe_dados_547()
#----------------------------------#

   DISPLAY BY NAME p_man_apont_547.*
   
END FUNCTION

#---------------------------------------#
 FUNCTION pol0891_cursor_for_update_547()
#---------------------------------------#

   #IF pol0891_apontando() THEN
   #   RETURN FALSE
   #END IF

   WHENEVER ERROR CONTINUE

   DECLARE cm_padrao1 CURSOR WITH HOLD FOR
   SELECT * INTO p_man_apont_547.*                                              
     FROM man_apont_547  
    WHERE rowid = p_rowid FOR UPDATE 
   CALL log085_transacao("BEGIN")   
   OPEN cm_padrao1
   FETCH cm_padrao1
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","man_apont_547")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#----------------------------------#
 FUNCTION pol0891_modifica_547()
#----------------------------------#

   IF p_man_apont_547.dat_atualiz is not null THEN
       CALL log0030_mensagem('Registro já processado!','exclamation')   
       RETURN
   END IF

   IF p_man_apont_547.num_ordem is null THEN
       RETURN
   END IF          

  IF pol0891_cursor_for_update_547() THEN
     LET p_man_apont_547a.* = p_man_apont_547.*
     IF pol0891_entrada_547("MODIFICACAO") THEN
        WHENEVER ERROR CONTINUE
        UPDATE man_apont_547 
           SET man_apont_547.* = p_man_apont_547.*
         WHERE CURRENT OF cm_padrao1
        IF SQLCA.SQLCODE = 0 THEN
           CALL log085_transacao("COMMIT")
           MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
        ELSE
           CALL log085_transacao("ROLLBACK")
           CALL log003_err_sql("MODIFICACAO","man_apont_547")
        END IF
     ELSE
        CALL log085_transacao("ROLLBACK")
        LET p_man_apont_547.* = p_man_apont_547a.*
        ERROR "Modificacao Cancelada"
        CALL pol0891_exibe_dados_547()
     END IF
     CLOSE cm_padrao1
  END IF

END FUNCTION

#-----------------------#
FUNCTION pol0891_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
   
      WHEN INFIELD(item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0891
         
   	     IF p_codigo IS NOT NULL THEN         
   				   LET p_man_apont_547.item = p_codigo   		
   				   DISPLAY p_codigo TO item
   		   END IF        
                  
      WHEN INFIELD(num_orde)
         CALL log009_popup(8,10,"OP","ordens",
              "num_ordem","cod_item","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0891
          
         IF p_codigo IS NOT NULL THEN
   				   LET p_man_apont_547.num_ordem = p_codigo   		
   				   DISPLAY p_codigo TO num_ordem
         END IF      
         
      WHEN INFIELD(operacao)
         CALL log009_popup(8,10,"OPERACAO","operacao",
              "cod_operac","den_operac","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0891
          
         IF p_codigo IS NOT NULL THEN
   				   LET p_man_apont_547.operacao = p_codigo   		
   				   DISPLAY p_codigo TO operacao
         END IF                      

      WHEN INFIELD(centro_trabalho)
         CALL log009_popup(8,10,"C.TRABALHO","cent_trabalho",
              "cod_cent_trab","den_cent_trab","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0891
          
         IF p_codigo IS NOT NULL THEN
   				   LET p_man_apont_547.centro_trabalho = p_codigo   		
   				   DISPLAY p_codigo TO centro_trabalho
         END IF                      

      WHEN INFIELD(arranjo)
         CALL log009_popup(8,10,"ARRANJO","arranjo",
              "cod_arranjo","den_arranjo","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0891
          
         IF p_codigo IS NOT NULL THEN
   				   LET p_man_apont_547.arranjo = p_codigo   		
   				   DISPLAY p_codigo TO arranjo
         END IF                      

      WHEN INFIELD(locaL)
         CALL log009_popup(8,10,"LOCAL","local",
              "cod_local","den_local","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0891
          
         IF p_codigo IS NOT NULL THEN
   				   LET p_man_apont_547.local = p_codigo   		
   				   DISPLAY p_codigo TO local
         END IF                      

   END CASE
   
END FUNCTION

#---------------------------#
FUNCTION pol0891_apontando()
#---------------------------#

   SELECT processando
     INTO p_processando
     FROM proc_apont_man912

   IF STATUS = 0 THEN
      IF p_processando = 'S' THEN
         CALL log0030_mensagem(
             "No momento, está sendo efetuado o apontamento. Tente mais tarde",
             "exclamation")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE
   
END FUNCTION

#-------------------------------#
 FUNCTION pol0891_exclui_547()
#-------------------------------#
   
   IF p_man_apont_547.num_ordem is null THEN
       RETURN
   END IF          

   IF pol0891_cursor_for_update_547() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         PROMPT 'Excluir (A)pontamento da Tela ou (T)odos da Ordem ?' FOR p_resp
         IF p_resp MATCHES "[Tt]" THEN
            DECLARE cq_man CURSOR FOR
             SELECT rowid
               FROM man_apont_547
              WHERE empresa        = p_cod_empresa
                AND num_ordem = p_man_apont_547.num_ordem
            FOREACH cq_man INTO p_rowid   
               IF pol0891_cursor_for_update_547() THEN
                  IF pol0891_inclui_hist_547() THEN
			               DELETE FROM man_apont_547 
			                WHERE empresa = p_cod_empresa
			                  AND rowid  = p_rowid
			               IF STATUS <> 0 THEN
			                  LET p_houve_erro = TRUE
			                  CALL log003_err_sql("EXCLUSAO","man_apont_547")
			                  EXIT FOREACH
			               END IF
			            ELSE
			               LET p_houve_erro = TRUE	
			               EXIT FOREACH		            
                  END IF
               ELSE
                  LET p_houve_erro = TRUE
                  EXIT FOREACH
               END IF
            END FOREACH
         ELSE
            IF pol0891_inclui_hist_547() THEN
               DELETE FROM man_apont_547
                WHERE empresa = p_cod_empresa
                  AND rowid  = p_rowid         
               IF STATUS <> 0 THEN
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("EXCLUSAO","man_apont_hist_547")
               END IF
            END IF   
         END IF
         IF NOT p_houve_erro THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_man_apont_547.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO empresa
         ELSE
            INITIALIZE p_man_apont_547.* TO NULL
            CLEAR FORM
            CALL log085_transacao("ROLLBACK")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao1
   END IF

END FUNCTION  

#---------------------------------#
 FUNCTION pol0891_inclui_hist_547()
#---------------------------------#

   SELECT * INTO p_man_apont_547.*                                              
     FROM man_apont_547  
    WHERE rowid = p_rowid   		
    
    IF STATUS <> 0 THEN
        CALL log003_err_sql("INCLUSAO","MAN_APONT_HIST_547")
        RETURN FALSE    
    END IF 
  		
   LET p_man_apont_hist_547.empresa = p_cod_empresa
 	 LET p_man_apont_hist_547.dat_ini_producao = p_man_apont_547.dat_ini_producao
   LET p_man_apont_hist_547.dat_fim_producao = p_man_apont_547.dat_fim_producao
   LET p_man_apont_hist_547.item = p_man_apont_547.item
   LET p_man_apont_hist_547.num_ordem = p_man_apont_547.num_ordem
   LET p_man_apont_hist_547.sequencia_operacao = p_man_apont_547.sequencia_operacao
   LET p_man_apont_hist_547.operacao = p_man_apont_547.operacao
   LET p_man_apont_hist_547.centro_trabalho = p_man_apont_547.centro_trabalho
   LET p_man_apont_hist_547.arranjo = p_man_apont_547.arranjo
   LET p_man_apont_hist_547.qtd_refugo = p_man_apont_547.qtd_refugo
   LET p_man_apont_hist_547.qtd_boas = p_man_apont_547.qtd_boas
   LET p_man_apont_hist_547.tip_movto = p_man_apont_547.tip_movto
   LET p_man_apont_hist_547.local = p_man_apont_547.local
   LET p_man_apont_hist_547.qtd_hor = p_man_apont_547.qtd_hor
   LET p_man_apont_hist_547.matricula = p_man_apont_547.matricula
   LET p_man_apont_hist_547.sit_registro_apont = p_man_apont_547.sit_registro_apont
   LET p_man_apont_hist_547.turno = p_man_apont_547.turno
   LET p_man_apont_hist_547.hor_inicial = p_man_apont_547.hor_inicial   
   LET p_man_apont_hist_547.hor_fim = p_man_apont_547.hor_fim
   LET p_man_apont_hist_547.refugo = p_man_apont_547.refugo
   LET p_man_apont_hist_547.parada = p_man_apont_547.parada
   LET p_man_apont_hist_547.hor_ini_parada = p_man_apont_547.hor_ini_parada
   LET p_man_apont_hist_547.hor_fim_parada = p_man_apont_547.hor_fim_parada
   LET p_man_apont_hist_547.unid_funcional = p_man_apont_547.unid_funcional
   LET p_man_apont_hist_547.dat_atualiz = p_man_apont_547.dat_atualiz
   LET p_man_apont_hist_547.terminado = p_man_apont_547.terminado
   LET p_man_apont_hist_547.situacao = 'D'
   LET p_man_apont_hist_547.usuario = 'pol0891'
   LET p_man_apont_hist_547.programa = 'pol0891'  
   
   INSERT INTO man_apont_hist_547
   VALUES(p_man_apont_hist_547.*) 			 

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","MAN_APONT_HIST_547")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0891_paginacao_547(p_funcao)
#---------------------------------------#

   DEFINE p_funcao  CHAR(20)
   DEFINE p_rowida  INTEGER
   IF p_ies_cons THEN
      LET p_man_apont_547a.* = p_man_apont_547.*
      LET p_rowida = p_rowid
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_padrao1 INTO p_rowid
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao1 INTO p_rowid
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_man_apont_547.* = p_man_apont_547a.* 
            LET p_rowid = p_rowida
            EXIT WHILE
         END IF

        SELECT * 
           INTO p_man_apont_547.* 
           FROM man_apont_547
          WHERE rowid = p_rowid        
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0891_exibe_dados_547()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0891_emite_relatorio_547()
#---------------------------------------#
   LET p_count = 0
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   
   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
    
   DECLARE cq_apont1 CURSOR FOR
    SELECT * 
      FROM man_apont_547

   FOREACH cq_apont1 INTO p_man_apont_547.*
   
      OUTPUT TO REPORT pol0891_relat_547() 
  
     LET p_count = p_count + 1
     
  END FOREACH
 
END FUNCTION 

#--------------------------#
 REPORT pol0891_relat_547()
#--------------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 207, "PAG.: ", PAGENO USING "####&"
         PRINT COLUMN 001, 'pol0891',
               COLUMN 065, 'APONTAMENTOS DE ORDEM DE PRODUÇÃO',
               COLUMN 194, 'DATA: ', TODAY USING 'dd/mm/yyyy', ' ', TIME
               
         PRINT COLUMN 001, '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
         PRINT
         PRINT COLUMN 001, '  INI PROD   FIM PROD      ITEM          ORDEM   SEQ  OPER  CT    AR   QT REFUGO   QTDE BOAS MOV LOCAL      QTDE HOR MATRICULA T H. INICIAL H. FINAL       REFUGO     PARADA H.I.PARADA H.F.PARADA  FUNCIONAL DT ATUALIZ T' 
         PRINT COLUMN 001, '---------- ---------- --------------- ---------- --- ----- ----- ----- ---------- ---------- --- ---------- -------- --------- - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- -' 
#                                                                                                   #####&.&&& #####&.&&&
#                           12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678  
#                                    1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20                       
      ON EVERY ROW

         PRINT COLUMN 001, p_man_apont_547.dat_ini_producao,
               COLUMN 012, p_man_apont_547.dat_fim_producao,
               COLUMN 023, p_man_apont_547.item               USING '##############&',
               COLUMN 039, p_man_apont_547.num_ordem     USING '##########',
               COLUMN 050, p_man_apont_547.sequencia_operacao USING '##&',
               COLUMN 054, p_man_apont_547.operacao           USING '####&',               
               COLUMN 060, p_man_apont_547.centro_trabalho    USING '####&',
               COLUMN 066, p_man_apont_547.arranjo            USING '####&',
               COLUMN 072, p_man_apont_547.qtd_refugo         USING '#####&.&&&',               
               COLUMN 083, p_man_apont_547.qtd_boas           USING '#####&.&&&',
               COLUMN 094, p_man_apont_547.tip_movto          USING '&',
               COLUMN 098, p_man_apont_547.local              USING '#########&',
               COLUMN 107, p_man_apont_547.qtd_hor            USING '#####&.&&' ,
               COLUMN 119, p_man_apont_547.matricula          USING '#######&',
               COLUMN 128, p_man_apont_547.turno              USING '&',                                            
               COLUMN 130, p_man_apont_547.hor_inicial,        
               COLUMN 141, p_man_apont_547.hor_fim,
               COLUMN 152, p_man_apont_547.refugo             USING '#########&',
               COLUMN 163, p_man_apont_547.parada             USING '##&',
               COLUMN 174, p_man_apont_547.hor_ini_parada,
               COLUMN 185, p_man_apont_547.hor_fim_parada,                                                            
               COLUMN 196, p_man_apont_547.unid_funcional     USING '#########&',                                                                           
               COLUMN 207, p_man_apont_547.dat_atualiz,                                                                           
               COLUMN 218, p_man_apont_547.terminado          USING '&'
                                                                                                                                                                                                   
      ON LAST ROW
         
         PRINT COLUMN 001, p_descomprime
   
END REPORT

#-----------------------#
 FUNCTION pol0891_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
