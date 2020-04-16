#-------------------------------------------------------------------#
# PROGRAMA: pol0779                                                 #
# OBJETIVO: CADASTRO DE PARAMETROS - CIBRAPEL                       #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 19/03/2008                                              #
# CONVERSÃO 10.02: 16/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_cod_operacao       LIKE estoque_operac.cod_operacao,
          p_cod_usuario        LIKE usuarios.cod_usuario,
          p_den_operacao       LIKE estoque_operac.den_operacao,
          p_nom_usuario        LIKE usuarios.nom_funcionario,
          p_user               LIKE usuario.nom_usuario,
          p_den_item           LIKE item.den_item,
          p_tip_trim           LIKE empresas_885.tip_trim,
          p_ies_tipo           LIKE estoque_operac.ies_tipo,
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
          pr_index2            SMALLINT,  
          sr_index2            SMALLINT,
          p_codigo             CHAR(15),
          p_msg                CHAR(100)
          
END GLOBALS

   DEFINE p_parametros_885   RECORD LIKE parametros_885.*,
          p_parametros_885a  RECORD LIKE parametros_885.* 
          

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0779-10.02.02  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0779.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0779_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0779_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0779") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0779 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    DISPLAY p_cod_empresa TO cod_empresa

   SELECT *
     INTO p_parametros_885.*
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 0 THEN
      LET p_ies_cons = TRUE
      CALL pol0779_exibe_dados()
   ELSE
      LET p_ies_cons = FALSE
   END IF   
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF NOT p_ies_cons THEN
            IF pol0779_inclusao() THEN
               MESSAGE 'Inclusão efetuada com sucesso !!!'
               LET p_ies_cons = FALSE
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR 'A empresa corrente já possui os parâmetros!!!'
         END IF
       COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0779_modificacao() THEN
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
            IF pol0779_exclusao() THEN
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
         CALL pol0779_consulta()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0779

END FUNCTION

#--------------------------#
 FUNCTION pol0779_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
  
   INITIALIZE p_parametros_885.* TO NULL
   LET p_parametros_885.cod_empresa = p_cod_empresa
      
   IF pol0779_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO parametros_885 
         VALUES (p_parametros_885.*)

      IF SQLCA.SQLCODE <> 0 THEN         
         CALL log003_err_sql("LENDO", "PARAMETROS_885_1")
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
 FUNCTION pol0779_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_parametros_885.* 
      WITHOUT DEFAULTS           
                    
      AFTER FIELD cod_item_sucata_dq
      
         IF p_parametros_885.cod_item_sucata_dq IS NOT NULL THEN
            IF NOT pol0779_le_item(p_parametros_885.cod_item_sucata_dq) THEN
               ERROR "Item inválido!!!"
               NEXT FIELD cod_item_sucata_dq
            END IF
         ELSE
            LET p_den_item = NULL
         END IF
         
         DISPLAY p_den_item TO den_item_sucata_dq

      AFTER FIELD cod_faturista
        
        IF p_parametros_885.cod_faturista IS NOT NULL THEN 

           SELECT nom_funcionario
             INTO p_nom_usuario
             FROM usuarios
            WHERE cod_usuario = p_parametros_885.cod_faturista
            
           IF SQLCA.sqlcode <> 0 THEN
              ERROR "Faturista nao Cadastrado na Tabela USUARIOS !!!"
              NEXT FIELD cod_faturista
           END IF     
        ELSE
           LET p_nom_usuario = ''
        END IF
        
        DISPLAY p_nom_usuario TO nom_usuario

      AFTER FIELD cod_item_refugo
         
         IF p_parametros_885.cod_item_refugo IS NOT NULL THEN
            IF NOT pol0779_le_item(p_parametros_885.cod_item_refugo) THEN
               ERROR "Item inválido!!!"
               NEXT FIELD cod_item_refugo
            END IF
         ELSE
            LET p_den_item = NULL
         END IF
         
         DISPLAY p_den_item TO den_item_refugo
         
      AFTER FIELD cod_item_sucata
         
         IF p_parametros_885.cod_item_sucata IS NOT NULL THEN
            IF NOT pol0779_le_item(p_parametros_885.cod_item_sucata) THEN
               ERROR "Item inválido!!!"
               NEXT FIELD cod_item_sucata
            END IF
         ELSE
            LET p_den_item = NULL
         END IF
         
         DISPLAY p_den_item TO den_item_sucata

      AFTER FIELD cod_item_retrab
         
         IF p_parametros_885.cod_item_retrab IS NOT NULL THEN
            IF NOT pol0779_le_item(p_parametros_885.cod_item_retrab) THEN
               ERROR "Item inválido!!!"
               NEXT FIELD cod_item_retrab
            END IF
         ELSE
            LET p_den_item = NULL
         END IF
         
         DISPLAY p_den_item TO den_item_retrab

      AFTER FIELD oper_sai_tp_refugo
      
         IF p_parametros_885.oper_sai_tp_refugo IS NOT NULL THEN 
            IF NOT pol0779_le_operacao(p_parametros_885.oper_sai_tp_refugo) THEN
               ERROR "Operação inválido!!!"
               NEXT FIELD oper_sai_tp_refugo
            END IF
         ELSE
            LET p_den_operacao = ''
         END IF
      
      DISPLAY p_den_operacao TO den_oper_sai_tp_refugo

      AFTER FIELD oper_ent_tp_refugo
      
         IF p_parametros_885.oper_ent_tp_refugo IS NOT NULL THEN 
            IF NOT pol0779_le_operacao(p_parametros_885.oper_ent_tp_refugo) THEN
               ERROR "Operação inválido!!!"
               NEXT FIELD oper_ent_tp_refugo
            END IF
         ELSE
            LET p_den_operacao = ''
         END IF
      
      DISPLAY p_den_operacao TO den_oper_ent_tp_refugo

      AFTER FIELD oper_entr_sucata
      
         IF p_parametros_885.oper_entr_sucata IS NOT NULL THEN 
            IF NOT pol0779_le_operacao(p_parametros_885.oper_entr_sucata) THEN
               ERROR "Operação inválido!!!"
               NEXT FIELD oper_entr_sucata
            END IF
         ELSE
            LET p_den_operacao = ''
         END IF
      
      DISPLAY p_den_operacao TO den_oper_entr_sucata

      AFTER FIELD oper_sucateamento
      
         IF p_parametros_885.oper_sucateamento IS NOT NULL THEN 
            IF NOT pol0779_le_operacao(p_parametros_885.oper_sucateamento) THEN
               ERROR "Operação inválido!!!"
               NEXT FIELD oper_sucateamento
            END IF
         ELSE
            LET p_den_operacao = ''
         END IF
      
      DISPLAY p_den_operacao TO den_oper_sucateamento

      ON KEY (control-z)
           CALL pol0779_popup()

      AFTER INPUT
        
       IF NOT INT_FLAG THEN
       
         IF p_parametros_885.cod_item_sucata_dq IS NULL THEN
            ERROR 'Campo obrigatório.'
            NEXT FIELD cod_item_sucata_dq
         ELSE
            IF NOT pol0779_ctr_lote(p_parametros_885.cod_item_sucata_dq) THEN
               LET p_parametros_885.num_lote_sucata_dq = NULL
            ELSE
               IF p_parametros_885.num_lote_sucata_dq IS NULL THEN
                  ERROR 'Campo obrigatório.'
                  NEXT FIELD num_lote_sucata_dq
               END IF
            END IF
         END IF
         
         IF p_parametros_885.cod_item_refugo IS NULL THEN
            IF p_cod_empresa = '02' THEN
               ERROR 'Campo obrigatório.'
               NEXT FIELD cod_item_refugo
            END IF
         ELSE
            IF NOT pol0779_ctr_lote(p_parametros_885.cod_item_refugo) THEN
               LET p_parametros_885.num_lote_refugo = NULL
            ELSE
               IF p_parametros_885.num_lote_refugo IS NULL THEN
                  ERROR 'Campo obrigatório.'
                  NEXT FIELD num_lote_refugo
               END IF
            END IF
         END IF

         IF p_parametros_885.cod_item_sucata IS NULL THEN
            ERROR 'Campo obrigatório.'
            NEXT FIELD cod_item_sucata
         ELSE
            IF NOT pol0779_ctr_lote(p_parametros_885.cod_item_sucata) THEN
               LET p_parametros_885.num_lote_sucata = NULL
            ELSE
               IF p_parametros_885.num_lote_sucata IS NULL THEN
                  ERROR 'Campo obrigatório.'
                  NEXT FIELD num_lote_sucata
               END IF
            END IF
         END IF

         IF p_parametros_885.cod_item_retrab IS NULL THEN
            ERROR 'Campo obrigatório.'
            NEXT FIELD cod_item_retrab
         ELSE
            IF NOT pol0779_ctr_lote(p_parametros_885.cod_item_retrab) THEN
               LET p_parametros_885.num_lote_retrab = NULL
            ELSE
               IF p_parametros_885.num_lote_retrab IS NULL THEN
                  ERROR 'Campo obrigatório.'
                  NEXT FIELD num_lote_retrab
               END IF
            END IF
         END IF
         
         IF p_parametros_885.tol_bx_aparas IS NULL OR
              p_parametros_885.tol_bx_aparas = ' ' THEN
            LET p_parametros_885.tol_bx_aparas = 0
         END IF
       
       END IF 
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol0779_ctr_lote(p_codigo)#
#----------------------------------#
   
   DEFINE p_codigo       CHAR(15),
          p_ies_ctr_lote CHAR(01)
   
   SELECT ies_ctr_lote
     INTO p_ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_codigo
   
   IF p_ies_ctr_lote = 'S' THEN 
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol0779_le_item(p_cod_item)
#----------------------------------#

   DEFINE p_cod_item CHAR(15)
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa  = p_cod_empresa
      AND cod_item     = p_cod_item
      
   IF STATUS <> 0 THEN
      INITIALIZE p_den_item TO NULL
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0779_le_operacao(p_cod_oper)
#--------------------------------------#
   
   DEFINE p_cod_oper LIKE estoque_operac.cod_operacao
   
   SELECT den_operacao
     INTO p_den_operacao
     FROM estoque_operac
    WHERE cod_operacao = p_cod_oper
      AND  cod_empresa = p_cod_empresa
         
   IF STATUS <> 0 THEN
      LET p_den_operacao = NULL
   END IF   

END FUNCTION

#-----------------------#
FUNCTION pol0779_popup()
#-----------------------#
   DEFINE p_codigo  CHAR(15),
          p_codigo2 CHAR(15)
     
   CASE

      WHEN INFIELD(cod_faturista)
         CALL log009_popup(8,10,"USUARIOS","usuarios",
              "cod_usuario","nom_funcionario","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0779 
         
          
         IF p_codigo IS NOT NULL THEN
           LET p_parametros_885.cod_faturista = p_codigo CLIPPED
           DISPLAY p_codigo TO cod_faturista
         END IF 
   
      WHEN INFIELD(cod_item_sucata_dq)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CURRENT WINDOW IS w_pol0779
         LET p_parametros_885.cod_item_sucata_dq = p_codigo
         DISPLAY p_codigo TO cod_item_sucata_dq

      WHEN INFIELD(cod_item_refugo)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CURRENT WINDOW IS w_pol0779
         LET p_parametros_885.cod_item_refugo = p_codigo
         DISPLAY p_codigo TO cod_item_refugo

      WHEN INFIELD(cod_item_sucata)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CURRENT WINDOW IS w_pol0779
         LET p_parametros_885.cod_item_sucata = p_codigo
         DISPLAY p_codigo TO cod_item_sucata
   
      WHEN INFIELD(cod_item_retrab)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CURRENT WINDOW IS w_pol0779
         LET p_parametros_885.cod_item_retrab = p_codigo
         DISPLAY p_codigo TO cod_item_retrab
            
      WHEN INFIELD(oper_sai_tp_refugo)
         CALL log009_popup(8,10,"CODIGO OPERACAO","estoque_operac",
              "cod_operacao","den_operacao","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0779
          
         IF p_codigo IS NOT NULL THEN
           LET p_parametros_885.oper_sai_tp_refugo = p_codigo CLIPPED
           DISPLAY p_codigo TO oper_sai_tp_refugo
         END IF 

      WHEN INFIELD(oper_ent_tp_refugo)
         CALL log009_popup(8,10,"CODIGO OPERACAO","estoque_operac",
              "cod_operacao","den_operacao","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0779
          
         IF p_codigo IS NOT NULL THEN
           LET p_parametros_885.oper_ent_tp_refugo = p_codigo CLIPPED
           DISPLAY p_codigo TO oper_ent_tp_refugo
         END IF 

      WHEN INFIELD(oper_entr_sucata)
         CALL log009_popup(8,10,"CODIGO OPERACAO","estoque_operac",
              "cod_operacao","den_operacao","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0779
          
         IF p_codigo IS NOT NULL THEN
           LET p_parametros_885.oper_entr_sucata = p_codigo CLIPPED
           DISPLAY p_codigo TO oper_entr_sucata
         END IF 
      
      WHEN INFIELD(oper_sucateamento)
         CALL log009_popup(8,10,"CODIGO OPERACAO","estoque_operac",
              "cod_operacao","den_operacao","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0779
          
         IF p_codigo IS NOT NULL THEN
           LET p_parametros_885.oper_sucateamento = p_codigo CLIPPED
           DISPLAY p_codigo TO oper_sucateamento
         END IF 

   END CASE
            
END FUNCTION 

#--------------------------#
 FUNCTION pol0779_consulta()
#--------------------------#

   SELECT *
     INTO p_parametros_885.*
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 0 THEN
      CALL pol0779_exibe_dados()
      LET p_ies_cons = TRUE
   ELSE
      ERROR 'Empresa corrente não possui parâmetros cadastrados!!!'
      LET p_ies_cons = FALSE
   END IF
   
END FUNCTION

#------------------------------#
 FUNCTION pol0779_exibe_dados()
#------------------------------#
   
   CLEAR FORM
   
   DISPLAY BY NAME p_parametros_885.*
   
   SELECT nom_funcionario
     INTO p_nom_usuario
     FROM usuarios
     WHERE cod_usuario = p_parametros_885.cod_faturista

   IF STATUS <> 0 THEN
      LET p_nom_usuario = NULL
   END IF
   
   DISPLAY p_nom_usuario TO nom_usuario
   
   CALL pol0779_le_item(p_parametros_885.cod_item_sucata_dq) RETURNING p_status
   DISPLAY p_den_item TO den_item_sucata_dq
   
   CALL pol0779_le_item(p_parametros_885.cod_item_refugo) RETURNING p_status
   DISPLAY p_den_item TO den_item_refugo

   CALL pol0779_le_item(p_parametros_885.cod_item_sucata) RETURNING p_status
   DISPLAY p_den_item TO den_item_sucata
   
   CALL pol0779_le_item(p_parametros_885.cod_item_retrab) RETURNING p_status
   DISPLAY p_den_item TO den_item_retrab

   CALL pol0779_le_item(p_parametros_885.cod_item_sucata) RETURNING p_status
   DISPLAY p_den_item TO den_item_sucata
   
   CALL pol0779_le_operacao(p_parametros_885.oper_ent_tp_refugo)
   DISPLAY p_den_operacao TO den_oper_ent_tp_refugo
         
   CALL pol0779_le_operacao(p_parametros_885.oper_sai_tp_refugo)
   DISPLAY p_den_operacao TO den_oper_sai_tp_refugo
   
   CALL pol0779_le_operacao(p_parametros_885.oper_entr_sucata)
   DISPLAY p_den_operacao TO den_oper_entr_sucata
   
   CALL pol0779_le_operacao(p_parametros_885.oper_sucateamento)
   DISPLAY p_den_operacao TO den_oper_sucateamento
       
END FUNCTION

#-----------------------------------#
 FUNCTION pol0779_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_parametros_885.*                                              
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa  
   FOR UPDATE
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","parametros_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0779_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0779_cursor_for_update() THEN
      LET p_parametros_885a.* = p_parametros_885.*
      IF pol0779_entrada_dados("MODIFICACAO") THEN
               
         UPDATE parametros_885
            SET parametros_885.* = p_parametros_885.*
          WHERE cod_empresa  = p_cod_empresa
              
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","parametros_885:M")
         END IF
      ELSE
         LET p_parametros_885.* = p_parametros_885a.*
         CALL pol0779_exibe_dados()
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
 FUNCTION pol0779_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0779_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
      
        DELETE FROM parametros_885
        WHERE cod_empresa = p_cod_empresa
        
         IF STATUS = 0 THEN
            INITIALIZE p_parametros_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","parametros_885")
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



#-------------------------------- FIM DE PROGRAMA -----------------------------#

