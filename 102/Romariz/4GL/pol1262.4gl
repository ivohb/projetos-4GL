#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1262                                                 #
# OBJETIVO: TIPOS DE ESTOQUE/RESTRICAO                              #
# DATA....: 12/08/14                                                #
# FUNÇÕES.: FUNC002                                                 #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080),
          p_last_row           SMALLINT
END GLOBALS

DEFINE   p_6lpp               CHAR(100),   
         p_8lpp               CHAR(100),   
         p_msg                CHAR(500),   
         p_nom_tela           CHAR(200),   
         p_ies_cons           SMALLINT,    
         p_salto              SMALLINT,    
         p_erro               CHAR(06),    
         p_existencia         SMALLINT,    
         p_num_seq            SMALLINT,    
         P_Comprime           CHAR(01),    
         p_descomprime        CHAR(01),    
         p_rowid              INTEGER,     
         p_retorno            SMALLINT,    
         p_index              SMALLINT,    
         s_index              SMALLINT,    
         p_ind                SMALLINT,    
         s_ind                SMALLINT,    
         p_count              SMALLINT,    
         p_houve_erro         SMALLINT,    
         p_opcao              CHAR(01),    
         p_excluiu            SMALLINT     
         
DEFINE p_descricao            CHAR(40)

DEFINE p_tip_estoque       RECORD LIKE tip_estoque_915.*,
       p_tip_estoquea      RECORD LIKE tip_estoque_915.*,
       p_relat             RECORD LIKE tip_estoque_915.*
       
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1262-10.02.01  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '11'; LET p_user = 'admlog'; LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1262_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1262_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1262") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1262 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1262_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1262_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1262_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1262_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1262_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1262_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1262_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1262

END FUNCTION

#---------------------------#
FUNCTION pol1262_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1262_inclusao()
#--------------------------#

   CALL pol1262_limpa_tela()
   
   INITIALIZE p_tip_estoque TO NULL
   LET p_tip_estoque.cod_empresa = p_cod_empresa
   
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1262_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1262_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1262_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1262_insere()
#------------------------#

   INSERT INTO tip_estoque_915 VALUES (p_tip_estoque.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","tip_estoque_915")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1262_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tip_estoque.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD tip_estoq_insp

         IF p_funcao = "M" THEN
            NEXT FIELD status_liberado
         END IF
      
      AFTER FIELD tip_estoq_insp

         IF p_tip_estoque.tip_estoq_insp IS NULL THEN 
            LET p_descricao = NULL
         ELSE
            CALL pol1262_le_desc_estoque(p_tip_estoque.tip_estoq_insp)
            IF p_descricao IS NULL THEN
               ERROR "Tipo de estoque inexistente."
               NEXT FIELD tip_estoq_insp   
            END IF
         END IF
         
         DISPLAY p_descricao TO des_estoque

      BEFORE FIELD restricao_insp

         IF p_funcao = "M" THEN
            NEXT FIELD status_liberado
         END IF
      
      AFTER FIELD restricao_insp

         IF p_tip_estoque.restricao_insp IS NULL THEN 
            LET p_descricao = NULL
         ELSE
            CALL pol1262_le_desc_restricao(p_tip_estoque.restricao_insp)
            IF p_descricao IS NULL THEN
               ERROR "Tipo de restrição inexistente."
               NEXT FIELD restricao_insp   
            END IF
         END IF
         
         DISPLAY p_descricao TO des_restricao
         
         IF pol1262_reg_existe() THEN
            NEXT FIELD tip_estoq_insp
         END IF

         IF NOT pol1262_sit_insp_existe() THEN
            NEXT FIELD tip_estoq_insp
         END IF

      AFTER FIELD tip_estoq_liber 
         
         IF p_tip_estoque.tip_estoq_liber IS NULL THEN 
            LET p_descricao = NULL
         ELSE
            CALL pol1262_le_desc_estoque(p_tip_estoque.tip_estoq_liber)
            IF p_descricao IS NULL THEN
               ERROR "Tipo de estoque inexistente."
               NEXT FIELD tip_estoq_liber   
            END IF
         END IF
            
         DISPLAY p_descricao TO des_estoque_liber

      AFTER FIELD restricao_liber 
         
         IF p_tip_estoque.restricao_liber IS NULL THEN 
            LET p_descricao = NULL
         ELSE
            CALL pol1262_le_desc_restricao(p_tip_estoque.restricao_liber)
            IF p_descricao IS NULL THEN
               ERROR "Tipo de restricao inexistente."
               NEXT FIELD restricao_liber   
            END IF
         END IF
            
         DISPLAY p_descricao TO des_restricao_liber

      AFTER FIELD tip_estoque_rejei 
         
         IF p_tip_estoque.tip_estoque_rejei IS NULL THEN 
            LET p_descricao = NULL
         ELSE
            CALL pol1262_le_desc_estoque(p_tip_estoque.tip_estoque_rejei)
            IF p_descricao IS NULL THEN
               ERROR "Tipo de estoque inexistente."
               NEXT FIELD tip_estoque_rejei   
            END IF
         END IF
            
         DISPLAY p_descricao TO des_estoque_rejei

      AFTER FIELD restricao_rejei 
         
         IF p_tip_estoque.restricao_rejei IS NULL THEN 
            LET p_descricao = NULL
         ELSE
            CALL pol1262_le_desc_restricao(p_tip_estoque.restricao_rejei)
            IF p_descricao IS NULL THEN
               ERROR "Tipo de restricao inexistente."
               NEXT FIELD restricao_rejei   
            END IF
         END IF
            
         DISPLAY p_descricao TO des_restricao_rejei
                  
      ON KEY (control-z)
         CALL pol1262_popup()
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1262_le_desc_estoque(p_cod)#
#--------------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   LET p_descricao = NULL
   
   SELECT des_tip_estoque
     INTO p_descricao
     FROM wms_tip_estoque
    WHERE empresa = p_cod_empresa 
      AND tip_estoque = p_cod
         
   IF STATUS <> 0 AND STATUS <> 100 THEN 
      CALL log003_err_sql('SELECT','wms_tip_estoque')
   END IF  

END FUNCTION

#----------------------------------------#
FUNCTION pol1262_le_desc_restricao(p_cod)#
#----------------------------------------#
   
   DEFINE p_cod CHAR(15)
   
   LET p_descricao = NULL
   
   SELECT des_restricao
     INTO p_descricao
     FROM wms_restricao_estoque
    WHERE empresa = p_cod_empresa 
      AND restricao = p_cod
         
   IF STATUS <> 0 AND STATUS <> 100 THEN 
      CALL log003_err_sql('SELECT','wms_restricao_estoque')
   END IF  

END FUNCTION


#----------------------------#
FUNCTION pol1262_reg_existe()#
#----------------------------#

   SELECT COUNT(cod_empresa)
     INTO p_count
     FROM tip_estoque_915
    WHERE cod_empresa = p_cod_empresa
      AND tip_estoq_insp = p_tip_estoque.tip_estoq_insp
      AND restricao_insp = p_tip_estoque.restricao_insp
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','tip_estoque_915')
      RETURN TRUE
   END IF
   
   IF p_count > 0 THEN
      ERROR 'Tipo de estoque/restrição já cadastrados no pol1262'
      RETURN TRUE
   END IF   
   
   RETURN FALSE

END FUNCTION

#---------------------------------#
FUNCTION pol1262_sit_insp_existe()#
#---------------------------------#

   SELECT COUNT(empresa)
     INTO p_count
     FROM wms_tip_estoque_restricao
    WHERE empresa = p_cod_empresa
      AND tip_estoque = p_tip_estoque.tip_estoq_insp
      AND restricao = p_tip_estoque.restricao_insp
      AND sit_erp = 'I'
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','wms_tip_estoque_restricao')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      ERROR 'Tipo de estoque/restrição não é um tipo previsto p/ inspeção.'
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION
   
#-----------------------#
 FUNCTION pol1262_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(tip_estoq_insp)
         CALL pol1262_sel_tipo()
         CALL log006_exibe_teclas("01 02 07", p_versao)

      WHEN INFIELD(restricao_insp)
         CALL pol1262_sel_tipo()
         CALL log006_exibe_teclas("01 02 07", p_versao)

      WHEN INFIELD(tip_estoq_liber)
         CALL log009_popup(8,10,"TIPO DE ESTOQUE","wms_tip_estoque",
              "tip_estoque","des_tip_estoque","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tip_estoque.tip_estoq_liber = p_codigo CLIPPED
            DISPLAY p_codigo TO tip_estoq_liber
         END IF

      WHEN INFIELD(restricao_liber)
         CALL log009_popup(8,10,"TIPO DE RESTRIÇÃO","wms_restricao_estoque",
              "restricao","des_restricao","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tip_estoque.restricao_liber = p_codigo CLIPPED
            DISPLAY p_codigo TO restricao_liber
         END IF

      WHEN INFIELD(tip_estoque_rejei)
         CALL log009_popup(8,10,"TIPO DE ESTOQUE","wms_tip_estoque",
              "tip_estoque","des_tip_estoque","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tip_estoque.tip_estoque_rejei = p_codigo CLIPPED
            DISPLAY p_codigo TO tip_estoque_rejei
         END IF

      WHEN INFIELD(restricao_rejei)
         CALL log009_popup(8,10,"TIPO DE RESTRIÇÃO","wms_restricao_estoque",
              "restricao","des_restricao","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tip_estoque.restricao_rejei = p_codigo CLIPPED
            DISPLAY p_codigo TO restricao_rejei
         END IF
                   
   END CASE 

END FUNCTION 

#---------------------------#
 FUNCTION pol1262_sel_tipo()#
#---------------------------#

   DEFINE pr_tipo  ARRAY[200] OF RECORD
          tip_estoque  LIKE wms_tip_estoque_restricao.tip_estoque,
          restricao    LIKE wms_tip_estoque_restricao.restricao,
          sit_erp      LIKE wms_tip_estoque_restricao.sit_erp
   END RECORD
   
   INITIALIZE p_nom_tela, pr_tipo TO NULL
   CALL log130_procura_caminho("pol1262a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1262a AT 8,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_tipo CURSOR FOR
   
    SELECT a.tip_estoque, 
           a.restricao, a.sit_erp
      FROM wms_tip_estoque_restricao a,
           wms_tip_estoque b,
           wms_restricao_estoque c
     WHERE a.empresa = p_cod_empresa
       AND a.sit_erp = 'I'
       AND b.empresa = a.empresa
       AND b.tip_estoque = a.tip_estoque
       AND c.empresa = a.empresa
       AND c.restricao = a.restricao
       AND c.avaria = 'N'
     ORDER BY a.tip_estoque, a.restricao

   FOREACH cq_tipo INTO 
      pr_tipo[p_ind].tip_estoque,   
      pr_tipo[p_ind].restricao,
      pr_tipo[p_ind].sit_erp

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_tipo')
         EXIT FOREACH
      END IF
             
      LET p_ind = p_ind + 1
      
      IF p_ind > 200 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_tipo TO sr_tipo.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol1262a
   
   IF NOT INT_FLAG THEN
      LET p_tip_estoque.tip_estoq_insp = pr_tipo[p_ind].tip_estoque
      DISPLAY p_tip_estoque.tip_estoq_insp TO tip_estoq_insp
      LET p_tip_estoque.restricao_insp = pr_tipo[p_ind].restricao
      DISPLAY p_tip_estoque.restricao_insp TO restricao_insp
   END IF
   
END FUNCTION

#--------------------------#
 FUNCTION pol1262_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(800)  

   CALL pol1262_limpa_tela()
   LET p_tip_estoquea.* = p_tip_estoque.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      tip_estoque_915.tip_estoq_insp,     
      tip_estoque_915.restricao_insp
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1262_limpa_tela()
         ELSE
            LET p_tip_estoque.* = p_tip_estoquea.*
            CALL pol1262_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM tip_estoque_915 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY tip_estoq_insp, restricao_insp"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_tip_estoque.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1262_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1262_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_tip_estoque.*
   
   CALL pol1262_le_desc_estoque(p_tip_estoque.tip_estoq_insp)
   DISPLAY p_descricao TO des_estoque

   CALL pol1262_le_desc_restricao(p_tip_estoque.restricao_insp)
   DISPLAY p_descricao TO des_restricao

   CALL pol1262_le_desc_estoque(p_tip_estoque.tip_estoq_liber)
   DISPLAY p_descricao TO des_estoque_liber

   CALL pol1262_le_desc_restricao(p_tip_estoque.restricao_liber)
   DISPLAY p_descricao TO des_restricao_liber

   CALL pol1262_le_desc_estoque(p_tip_estoque.tip_estoque_rejei)
   DISPLAY p_descricao TO des_estoque_rejei

   CALL pol1262_le_desc_restricao(p_tip_estoque.restricao_rejei)
   DISPLAY p_descricao TO des_restricao_rejei
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1262_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao       CHAR(01),
          p_estoque      LIKE tip_estoque_915.tip_estoq_insp,
          p_restricao    LIKE tip_estoque_915.restricao_insp

   LET p_tip_estoquea.* = p_tip_estoque.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_tip_estoque.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_tip_estoque.*
      
      END CASE

      IF STATUS = 0 THEN
         LET p_estoque = p_tip_estoque.tip_estoq_insp
         LET p_restricao = p_tip_estoque.restricao_insp
         
         SELECT *
           INTO p_tip_estoque.*
           FROM tip_estoque_915
          WHERE cod_empresa = p_cod_empresa
            AND tip_estoq_insp = p_estoque
            AND restricao_insp = p_restricao
            
         IF STATUS = 0 THEN
            IF pol1262_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_tip_estoque.* = p_tip_estoquea.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1262_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa
      FROM tip_estoque_915  
     WHERE cod_empresa = p_cod_empresa
       AND tip_estoq_insp = p_tip_estoque.tip_estoq_insp
       AND restricao_insp = p_tip_estoque.restricao_insp
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","tip_estoque_915")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1262_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET p_tip_estoquea.* = p_tip_estoque.*
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1262_prende_registro() THEN
      IF pol1262_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         LET p_tip_estoque.* = p_tip_estoquea.*
         CALL pol1262_exibe_dados() RETURNING p_status
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
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE tip_estoque_915
      SET status_liberado   = p_tip_estoque.status_liberado,  
          tip_estoq_liber   = p_tip_estoque.tip_estoq_liber,  
          restricao_liber   = p_tip_estoque.restricao_liber,  
          status_rejeitado  = p_tip_estoque.status_rejeitado, 
          tip_estoque_rejei = p_tip_estoque.tip_estoque_rejei,
          restricao_rejei   = p_tip_estoque.restricao_rejei  
    WHERE cod_empresa = p_cod_empresa
      AND tip_estoq_insp = p_tip_estoque.tip_estoq_insp
      AND restricao_insp = p_tip_estoque.restricao_insp

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "tip_estoque_915")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1262_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1262_prende_registro() THEN
      IF pol1262_deleta() THEN
         INITIALIZE p_tip_estoque TO NULL
         CALL pol1262_limpa_tela()
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
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

#------------------------#
FUNCTION pol1262_deleta()
#------------------------#

   DELETE FROM tip_estoque_915
    WHERE cod_empresa = p_cod_empresa
      AND tip_estoq_insp = p_tip_estoque.tip_estoq_insp
      AND restricao_insp = p_tip_estoque.restricao_insp

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","tip_estoque_915")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1262_listagem()
#--------------------------#     

   IF NOT pol1262_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1262_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT *
      FROM tip_estoque_915
     ORDER BY tip_estoq_insp, restricao_insp
  
   FOREACH cq_impressao INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'cq_impressao')
         RETURN
      END IF 
      
      OUTPUT TO REPORT pol1262_relat() 
      
      LET p_count = 1
      
   END FOREACH

   CALL pol1262_finaliza_relat()

   RETURN
     
END FUNCTION 
      
#-------------------------------#
 FUNCTION pol1262_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1262_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1262.tmp'
         START REPORT pol1262_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1262_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1262_le_den_empresa()
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

#--------------------------------#
FUNCTION pol1262_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1262_relat   

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

END FUNCTION

#----------------------#
 REPORT pol1262_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 071, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "POL1262",
               COLUMN 010, "TIPOS DE ESTOQUE/RESTRICAO",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, '----------------------------------------------------------------------------------'
         PRINT
         PRINT COLUMN 001, 'ESTOQ INSP RESTRIC INSP SIT LIB ESTOQ LIB RESTIC LIB SIT REJ ESTOQ REJ RESTRIC REJ'
         PRINT COLUMN 001, '---------- ------------ ------- --------- ---------- ------- --------- -----------'

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 076, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, '----------------------------------------------------------------------------------'
         PRINT
         PRINT COLUMN 001, 'ESTOQ INSP RESTRIC INSP SIT LIB ESTOQ LIB RESTIC LIB SIT REJ ESTOQ REJ RESTRIC REJ'
         PRINT COLUMN 001, '---------- ------------ ------- --------- ---------- ------- --------- -----------'

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.tip_estoq_insp,
               COLUMN 012, p_relat.restricao_insp,
               COLUMN 028, p_relat.status_liberado,
               COLUMN 033, p_relat.tip_estoq_liber,
               COLUMN 043, p_relat.restricao_liber,
               COLUMN 057, p_relat.status_rejeitado,
               COLUMN 062, p_relat.tip_estoque_rejei,
               COLUMN 072, p_relat.restricao_rejei
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT
                  

#-------------------------------- FIM DE PROGRAMA BL-----------------------------#
