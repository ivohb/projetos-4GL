#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# MÓDULO..: INTEGRAÇÃO LOGIX X OMC                                  #
# PROGRAMA: pol1147                                                 #
# OBJETIVO: APONTAMENTOS CRITICADOS                                 #
# AUTOR...: Willians                                                #
# DATA....: 09/05/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_critica_demis      INTEGER,
          p_mensagem           CHAR(60),
          p_num_seq            INTEGER,
          p_num_reg            CHAR(6),
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
          p_comando            CHAR(200),
          comando              CHAR(200),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_arq_origem         CHAR(100),
          p_arq_destino        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT

   DEFINE p_excluiu            SMALLINT,
          p_ordem_producao     INTEGER, 
          p_item               CHAR(15),   
          p_den_item_reduz     CHAR(18),
          p_dat_inicio         DATE, 
          p_hor_inicio         CHAR(08), 
          p_dat_fim            DATE,
          p_hor_fim            CHAR(08), 
          p_turno              DECIMAL(3,0), 
          p_operacao           CHAR(05), 
          p_qtd_boas           DECIMAL(10,3), 
          p_qtd_refugo         DECIMAL(10,3), 
          p_local_producao     CHAR(10), 
          p_local_estoque      CHAR(10), 
          p_centro_trabalho    CHAR(05),
          p_arranjo            CHAR(05), 
          p_ferramental        CHAR(15), 
          p_equipamento        CHAR(15), 
          p_operador           CHAR(15), 
          p_dat_producao       DATE
          
   DEFINE p_consulta           RECORD
          ordem_producao       INTEGER,
          seq_registro         INTEGER
   END RECORD
   
   DEFINE p_consulta_ant       RECORD
          ordem_producao       INTEGER,
          seq_registro         INTEGER
   END RECORD
   
   DEFINE pr_motivo            ARRAY[100] OF RECORD      
          texto_resumo         CHAR(70)
   END RECORD
   
   DEFINE p_man_apo_prod_arq   RECORD LIKE man_apo_prod_arq.*
   
                   
END GLOBALS
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1147-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1147_menu()
   END IF

END MAIN

#----------------------#
 FUNCTION pol1147_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1147") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1147 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
     
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1147_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1147_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1147_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
     COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1147_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1147_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1147

END FUNCTION

#-----------------------#
 FUNCTION pol1147_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION     

#----------------------------#
FUNCTION pol1147_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
END FUNCTION


#--------------------------#
FUNCTION pol1147_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1147_limpa_tela()
   LET p_consulta_ant.* = p_consulta.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      man_apo_prod_arq.ordem_producao,
      man_apo_prod_arq.item,
      man_apo_prod_arq.dat_inicio,
      man_apo_prod_arq.hor_inicio,
      man_apo_prod_arq.dat_fim,
      man_apo_prod_arq.hor_fim
      
      ON KEY (control-z)
         CALL pol1147_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1147_limpa_tela()
         ELSE
            LET p_consulta.* = p_consulta_ant.*
            CALL pol1147_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT a.ordem_producao, a.seq_registro",                      
                  "  FROM man_apo_prod_arq a, man_log_apo_prod b ",               
                  " WHERE ", where_clause CLIPPED,                                
                  "   AND a.empresa = '",p_cod_empresa,"' ",                      
                  "   AND a.empresa = b.empresa ",                                
                  "   AND a.ordem_producao = b.ordem_producao ",                  
                  "   AND a.seq_registro = b.seq_reg_arquivo ",                   
                  " ORDER BY a.ordem_producao, a.seq_registro"                    
                  
   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_consulta.*

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1147_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1147_exibe_dados()
#------------------------------#
   
   SELECT item,            
          dat_inicio,     
          hor_inicio,     
          dat_fim,        
          hor_fim,        
          turno,          
          operacao,       
          qtd_boas,       
          qtd_refugo,     
          local_producao, 
          local_estoque,  
          centro_trabalho,
          arranjo,        
          ferramental,    
          equipamento,    
          operador,       
          dat_producao   
     INTO p_item,           
          p_dat_inicio,     
          p_hor_inicio,    
          p_dat_fim,        
          p_hor_fim,        
          p_turno,          
          p_operacao,       
          p_qtd_boas,       
          p_qtd_refugo,     
          p_local_producao, 
          p_local_estoque,  
          p_centro_trabalho,
          p_arranjo,        
          p_ferramental,    
          p_equipamento,    
          p_operador,       
          p_dat_producao      
     FROM man_apo_prod_arq
    WHERE empresa        = p_cod_empresa 
      AND ordem_producao = p_consulta.ordem_producao
      AND seq_registro   = p_consulta.seq_registro
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "man_apo_prod_arq")
      RETURN FALSE
   END IF
   
   SELECT den_item_reduz
     INTO p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item
   
   IF STATUS <> 0 THEN
      DISPLAY " " TO den_item_reduz
   END IF
   
   LET p_ordem_producao = p_consulta.ordem_producao
      
   DISPLAY p_ordem_producao  TO ordem_producao
   DISPLAY p_item            TO item
   DISPLAY p_den_item_reduz  TO den_item_reduz
   DISPLAY p_dat_inicio      TO dat_inicio     
   DISPLAY p_hor_inicio      TO hor_inicio     
   DISPLAY p_dat_fim         TO dat_fim        
   DISPLAY p_hor_fim         TO hor_fim        
   DISPLAY p_turno           TO turno          
   DISPLAY p_operacao        TO operacao       
   DISPLAY p_qtd_boas        TO qtd_boas       
   DISPLAY p_qtd_refugo      TO qtd_refugo     
   DISPLAY p_local_producao  TO local_producao 
   DISPLAY p_local_estoque   TO local_estoque  
   DISPLAY p_centro_trabalho TO centro_trabalho
   DISPLAY p_arranjo         TO arranjo        
   DISPLAY p_ferramental     TO ferramental    
   DISPLAY p_equipamento     TO equipamento    
   DISPLAY p_operador        TO operador       
   DISPLAY p_dat_producao    TO dat_producao       
                                       
   CALL pol1147_le_motivo()
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1147_le_motivo()
#--------------------------#

   INITIALIZE pr_motivo to null
   LET p_ind = 1
   
   DECLARE cq_mot CURSOR FOR
    SELECT texto_resumo
      FROM man_log_apo_prod
     WHERE empresa         = p_cod_empresa 
       AND ordem_producao  = p_consulta.ordem_producao
       AND seq_reg_arquivo = p_consulta.seq_registro
  ORDER BY texto_resumo

   FOREACH cq_mot 
      INTO pr_motivo[p_ind].texto_resumo
   
      IF STATUS <> 0 THEN
        CALL log003_err_sql('LENDO','CQ_MOT')       
        RETURN
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 100 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassou!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
   
   END FOREACH

   CALL SET_COUNT(p_ind - 1)

   IF p_ind > 10 THEN
      DISPLAY ARRAY pr_motivo TO sr_motivo.*
   ELSE
      INPUT ARRAY pr_motivo WITHOUT DEFAULTS FROM sr_motivo.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF
   
END FUNCTION
   
#-----------------------------------#
 FUNCTION pol1147_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_consulta_ant.* = p_consulta.*
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_consulta.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_consulta.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT ordem_producao
           FROM man_apo_prod_arq
          WHERE empresa        = p_cod_empresa 
            AND ordem_producao = p_consulta.ordem_producao
            AND seq_registro   = p_consulta.seq_registro
            
         IF STATUS = 0 THEN
            CALL pol1147_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_consulta.* = p_consulta_ant.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#-----------------------#
FUNCTION pol1147_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1147
         IF p_codigo IS NOT NULL THEN
            LET p_item = p_codigo
            DISPLAY p_codigo TO item
         END IF

   END CASE   

END FUNCTION

#----------------------------------#
 FUNCTION pol1147_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT ordem_producao 
      FROM man_apo_prod_arq  
     WHERE empresa        = p_cod_empresa 
       AND ordem_producao = p_consulta.ordem_producao
       AND seq_registro   = p_consulta.seq_registro
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH","CQ_PRENDE")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1147_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1147_prende_registro() THEN
      
      SELECT * 
        INTO p_man_apo_prod_arq.*
        FROM man_apo_prod_arq
       WHERE empresa        = p_cod_empresa 
         AND ordem_producao = p_consulta.ordem_producao
         AND seq_registro   = p_consulta.seq_registro         
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "man_apo_prod_arq")
         RETURN FALSE
      END IF 
      
      INSERT INTO man_apo_prod_hist
           VALUES(p_man_apo_prod_arq.*)
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql("inserindo", "man_apo_prod_hist")
         RETURN FALSE
      END IF
      
      DELETE FROM man_apo_prod_arq
		     WHERE empresa        = p_cod_empresa 
           AND ordem_producao = p_consulta.ordem_producao
           AND seq_registro   = p_consulta.seq_registro

      IF STATUS = 0 THEN               
         
         DELETE FROM man_log_apo_prod
          WHERE empresa         = p_cod_empresa 
            AND ordem_producao  = p_consulta.ordem_producao
            AND seq_reg_arquivo = p_consulta.seq_registro 
         
         IF STATUS = 0 THEN        
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
            LET p_excluiu = TRUE                     
         ELSE
            CALL log003_err_sql("Excluindo","man_log_apo_prod")
         END IF
      ELSE
         CALL log003_err_sql("Excluindo","man_apo_prod_arq")
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