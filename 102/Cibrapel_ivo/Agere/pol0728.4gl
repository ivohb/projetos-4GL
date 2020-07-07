#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0728                                                 #
# MODULOS.: pol0728-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO:                                                         #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 24/01/2008                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_cnd_pgto           LIKE cond_pgto.den_cnd_pgto,
          p_user               LIKE usuario.nom_usuario,
          p_num_pedido         LIKE pedido_sup_885.num_pedido,
          p_pct_desc           LIKE desc_ped_sup_885.pct_desc,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
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
          p_cod_formulario     CHAR(03),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          pr_indez             SMALLINT,
          sr_indez             SMALLINT,
          p_cod_tipo           CHAR(15)
          
   DEFINE p_pedido_sup_885   RECORD LIKE pedido_sup_885.*,
          p_pedido_sup_885a  RECORD LIKE pedido_sup_885.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0728-05.10.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0728.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0728_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0728_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0728") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0728 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0728_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0728_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0728_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0728_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0728_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0728_paginacao("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0728

END FUNCTION

#--------------------------#
 FUNCTION pol0728_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_pedido_sup_885.* TO NULL
   LET p_pedido_sup_885.cod_empresa = p_cod_empresa

   IF pol0728_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO pedido_sup_885 VALUES (p_pedido_sup_885.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0728_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0728

   INPUT BY NAME p_pedido_sup_885.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD num_pedido
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD cod_tipo
      END IF 
      
      AFTER FIELD num_pedido
      IF p_pedido_sup_885.num_pedido IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD num_pedido
      ELSE
                
         SELECT num_pedido
           FROM pedido_sup_885
          WHERE cod_empresa    = p_cod_empresa
            AND num_pedido = p_pedido_sup_885.num_pedido
          
         IF STATUS = 0 THEN
            ERROR "Código já Cadastrado na Tabela pedido_sup_885 !!!"
            NEXT FIELD num_pedido
         
         ELSE 
         NEXT FIELD cod_tipo
         END IF
      END IF
         
      AFTER FIELD cod_tipo
      IF p_pedido_sup_885.cod_tipo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_tipo
      ELSE 
       SELECT pct_desc
       INTO p_pct_desc
       FROM desc_ped_sup_885
       WHERE cod_empresa = p_cod_empresa
       AND cod_tipo = p_pedido_sup_885.cod_tipo
        
        DISPLAY p_pct_desc TO pct_desc  
         NEXT FIELD cnd_pgto
      END IF 
            
      AFTER FIELD cnd_pgto
      IF p_pedido_sup_885.cnd_pgto IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cnd_pgto
      END IF
   SELECT des_cnd_pgto
   INTO p_cnd_pgto
   FROM cond_pgto_cap
   WHERE cnd_pgto = p_pedido_sup_885.cnd_pgto
           
           DISPLAY p_cnd_pgto TO den_cnd_pgto
           
            ON KEY (control-z)
               CASE
                WHEN INFIELD(num_pedido)     
             LET p_num_pedido = pol0728_carrega_empresa() 
            IF p_num_pedido IS NOT NULL THEN
               LET p_pedido_sup_885.num_pedido = p_num_pedido CLIPPED
               CURRENT WINDOW IS w_pol0728
               DISPLAY p_pedido_sup_885.num_pedido TO num_pedido
               
            END IF  
          END CASE 
                     
               CASE WHEN INFIELD (cod_tipo)
              LET p_cod_tipo = pol0728_carrega_tipo() 
            IF p_cod_tipo IS NOT NULL THEN
               LET p_pedido_sup_885.cod_tipo = p_cod_tipo CLIPPED
               CURRENT WINDOW IS w_pol0728
               DISPLAY p_pedido_sup_885.cod_tipo TO cod_tipo
               
            END IF
            END CASE 
                   
          CALL pol0728_popup()
      
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0728

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0728_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_pedido_sup_885a.* = p_pedido_sup_885.*

   CONSTRUCT BY NAME where_clause ON pedido_sup_885.num_pedido
  
      ON KEY (control-z)
                 LET p_num_pedido = pol0728_carrega_empresa() 
            IF p_num_pedido IS NOT NULL THEN
               LET p_pedido_sup_885.num_pedido = p_num_pedido CLIPPED
               CURRENT WINDOW IS w_pol0728
               DISPLAY p_pedido_sup_885.num_pedido TO num_pedido
               
            END IF 


             LET p_cod_tipo = pol0728_carrega_tipo() 
            IF p_cod_tipo IS NOT NULL THEN
               LET p_pedido_sup_885.cod_tipo = p_cod_tipo CLIPPED
               CURRENT WINDOW IS w_pol0728
               DISPLAY p_pedido_sup_885.cod_tipo TO cod_tipo
               
            END IF 

   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0728

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_pedido_sup_885.* = p_pedido_sup_885a.*
      CALL pol0728_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM pedido_sup_885 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY num_pedido "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_pedido_sup_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0728_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0728_exibe_dados()
#------------------------------#
   SELECT des_cnd_pgto
   INTO p_cnd_pgto
   FROM cond_pgto_cap
   WHERE cnd_pgto = p_pedido_sup_885.cnd_pgto
   
   SELECT pct_desc
   INTO p_pct_desc
   FROM desc_ped_sup_885
   WHERE cod_empresa = p_cod_empresa
   AND cod_tipo = p_pedido_sup_885.cod_tipo
        
   
           
   DISPLAY BY NAME p_pedido_sup_885.*
   DISPLAY p_pct_desc TO pct_desc 
   DISPLAY p_cnd_pgto TO den_cnd_pgto
 
END FUNCTION

#-----------------------------------#
 FUNCTION pol0728_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_pedido_sup_885.*                                              
     FROM pedido_sup_885
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido = p_pedido_sup_885.num_pedido
      #FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","pedido_sup_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0728_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0728_cursor_for_update() THEN
      LET p_pedido_sup_885a.* = p_pedido_sup_885.*
      IF pol0728_entrada_dados("MODIFICACAO") THEN
         UPDATE pedido_sup_885
            SET cnd_pgto = p_pedido_sup_885.cnd_pgto,
                cod_tipo = p_pedido_sup_885.cod_tipo
            WHERE cod_empresa = p_cod_empresa
            AND num_pedido = p_pedido_sup_885.num_pedido    
         # WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","pedido_sup_885")
         END IF
      ELSE
         LET p_pedido_sup_885.* = p_pedido_sup_885a.*
         CALL pol0728_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol0728_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0728_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM pedido_sup_885
         WHERE cod_empresa = p_cod_empresa
         AND num_pedido = p_pedido_sup_885.num_pedido
         #WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_pedido_sup_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","pedido_sup_885")
         END IF
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#-------------------------------#   
 FUNCTION pol0728_carrega_empresa() 
#-------------------------------#
 
    DEFINE pr_empresa       ARRAY[3000]
     OF RECORD
         raz_social_reduz  LIKE fornecedor.raz_social_reduz,
         num_pedido        LIKE pedido_sup.num_pedido,
         dat_emis          LIKE pedido_sup.dat_emis
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07281") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07281 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_empresa CURSOR FOR 
   SELECT num_pedido,raz_social_reduz,dat_emis
   FROM   pedido_sup, fornecedor
   WHERE  pedido_sup.cod_fornecedor = fornecedor.cod_fornecedor
   AND cod_empresa = p_cod_empresa
   AND ies_versao_atual='S'
   AND ies_situa_ped='R'
   ORDER BY num_pedido

   LET pr_index = 1

   FOREACH cq_empresa INTO pr_empresa[pr_index].num_pedido,
                           pr_empresa[pr_index].raz_social_reduz,
                           pr_empresa[pr_index].dat_emis 
                         
    {    SELECT den_empresa
        INTO pr_empresa[pr_index].den_empresa
        FROM empresa
       WHERE cod_empresa = pr_empresa[pr_index].cod_emp_gerencial    }                            

      LET pr_index = pr_index + 1
       IF pr_index > 3000 THEN
         ERROR "Limit e de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_empresa TO sr_empresa.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
  CLOSE WINDOW w_pol0728
  
   RETURN pr_empresa[pr_index].num_pedido
      
END FUNCTION 

#-------------------------------#   
 FUNCTION pol0728_carrega_tipo() 
#-------------------------------#
 
    DEFINE pr_tipo       ARRAY[3000]
     OF RECORD
         cod_tipo       LIKE desc_ped_sup_885.cod_tipo,
         pct_desc       LIKE desc_ped_sup_885.pct_desc
         
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07282") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07282 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_tipo CURSOR FOR 
   SELECT cod_tipo,pct_desc
   FROM   desc_ped_sup_885
   WHERE cod_empresa = p_cod_empresa
   #AND cod_tipo = p_pedido_sup_885.cod_tipo
   LET pr_indez = 1

   FOREACH cq_tipo INTO pr_tipo[pr_indez].cod_tipo,
                           pr_tipo[pr_indez].pct_desc
                            
                         
    {    SELECT den_empresa
        INTO pr_empresa[pr_index].den_empresa
        FROM empresa
       WHERE cod_empresa = pr_empresa[pr_index].cod_emp_gerencial    }                            

      LET pr_indez = pr_indez + 1
       IF pr_indez > 3000 THEN
         ERROR "Limit e de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_indez - 1)

   DISPLAY ARRAY pr_tipo TO sr_tipo.*

   LET pr_indez = ARR_CURR()
   LET sr_indez = SCR_LINE() 
      
  CLOSE WINDOW w_pol0728
  
   RETURN pr_tipo[pr_indez].cod_tipo
      
END FUNCTION 

#-----------------------------------#
 FUNCTION pol0728_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_pedido_sup_885a.* = p_pedido_sup_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_pedido_sup_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_pedido_sup_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_pedido_sup_885.* = p_pedido_sup_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_pedido_sup_885.*
           FROM pedido_sup_885
          WHERE cod_empresa    = p_cod_empresa
            AND num_pedido = p_pedido_sup_885.num_pedido
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0728_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------#
FUNCTION pol0728_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

 {   CASE
      WHEN INFIELD(cod_tipo)
         CALL log009_popup(5,12,"CODIGO TIPO","desc_ped_sup_885",
              "cod_tipo","pct_desc","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0728
         IF p_codigo IS NOT NULL THEN
           LET p_pedido_sup_885.cod_tipo = p_codigo CLIPPED
           DISPLAY p_codigo TO cod_tipo
         END IF 
            END CASE }
            
     CASE
      WHEN INFIELD(cnd_pgto)
         CALL log009_popup(5,12,"CONDIÇÃO DE PAGAMENTO","cond_pgto_cap",
              "cnd_pgto","des_cnd_pgto","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0728
         IF p_codigo IS NOT NULL THEN
           LET p_pedido_sup_885.cnd_pgto = p_codigo CLIPPED
           DISPLAY p_codigo TO cnd_pgto
         END IF 
            END CASE    
           
            
            
END FUNCTION 



#-------------------------------- FIM DE PROGRAMA -----------------------------#

