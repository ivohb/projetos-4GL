#-------------------------------------------------------------------#
# PROGRAMA: pol0743                                                 #
# MODULOS.: pol0743-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: PARAMETROS PARA FICHA TÉCNICA - TORO                    #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 18/02/2008                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_raz_social         LIKE fornecedor.raz_social,
          p_den_gru_ctr_estoq  LIKE grupo_ctr_estoq.den_gru_ctr_estoq,
          #p_cod_item           LIKE item_ppte_req_159.cod_item,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_trim               CHAR(10),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          pr_index2            SMALLINT,  
          sr_index2            SMALLINT,
          p_campo              CHAR(10),
          p_data               DATE,
          p_hora               CHAR(08),
          p_texto              CHAR(200),
          ans                  CHAR(01), 
          p_msg                CHAR(500)
          
          
   DEFINE p_item_ppte_req_159   RECORD LIKE item_ppte_req_159.*,
          p_item_ppte_req_159a  RECORD LIKE item_ppte_req_159.* 
          
          
          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0743-10.02.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0743.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0743_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0743_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0743") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0743 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0743_inclusao() THEN
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
            IF pol0743_modificacao() THEN
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
            IF pol0743_exclusao() THEN
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
         CALL pol0743_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0743_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0743_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	    	 CALL pol0743_sobre()
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
   CLOSE WINDOW w_pol0743

END FUNCTION

#--------------------------#
 FUNCTION pol0743_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
  
   INITIALIZE p_item_ppte_req_159.* TO NULL
   LET p_item_ppte_req_159.cod_empresa = p_cod_empresa

   IF pol0743_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO item_ppte_req_159 VALUES (p_item_ppte_req_159.*)
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
 FUNCTION pol0743_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0743

  INPUT BY NAME p_item_ppte_req_159.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_grp_ctr_estoq
        IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD ies_den_mat_prima
      END IF 
 
    LET p_item_ppte_req_159.ies_qtd_pecas_emb  = 'S'
    LET p_item_ppte_req_159.ies_qtd_etiq_emb   = 'S'
    LET p_item_ppte_req_159.ies_den_mat_prima  = 'N'  
    LET p_item_ppte_req_159.ies_comprimento    = 'N'
    LET p_item_ppte_req_159.ies_tol_compr      = 'N'
    LET p_item_ppte_req_159.ies_largura        = 'N'
    LET p_item_ppte_req_159.ies_tol_largura    = 'N'
    LET p_item_ppte_req_159.ies_espessura      = 'N'
    LET p_item_ppte_req_159.ies_tol_espessura  = 'N'
    LET p_item_ppte_req_159.ies_gramatura      = 'N'
    LET p_item_ppte_req_159.ies_gramatura_min  = 'N'
    LET p_item_ppte_req_159.ies_gramatura_max  = 'N'
    LET p_item_ppte_req_159.ies_peso           = 'N'
    LET p_item_ppte_req_159.ies_peso_min       = 'N'
    LET p_item_ppte_req_159.ies_peso_max       = 'N'
    LET p_item_ppte_req_159.ies_lado_corte     = 'N'
    LET p_item_ppte_req_159.ies_compr_lamina   = 'N'
    LET p_item_ppte_req_159.ies_largura_lamina = 'N'
    LET p_item_ppte_req_159.ies_batidas_hora   = 'N'
    LET p_item_ppte_req_159.ies_cavidade       = 'N'
    LET p_item_ppte_req_159.ies_pecas_pacote   = 'N'
    LET p_item_ppte_req_159.ies_area_aplicacao = 'N'
    LET p_item_ppte_req_159.ies_alt_aplicacao  = 'N'
    LET p_item_ppte_req_159.ies_tol_resina     = 'N'
    LET p_item_ppte_req_159.ies_cod_tip_mat    = 'N'
    LET p_item_ppte_req_159.ies_observacao     = 'N'
    LET p_item_ppte_req_159.ies_fornecedor     = 'N'
    LET p_item_ppte_req_159.ies_dia_validade   = 'S'
       
      
      AFTER FIELD cod_grp_ctr_estoq
        IF p_item_ppte_req_159.cod_grp_ctr_estoq IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD cod_grp_ctr_estoq
        ELSE 
          SELECT den_gru_ctr_estoq
          INTO p_den_gru_ctr_estoq
          FROM grupo_ctr_estoq
          WHERE gru_ctr_estoq = p_item_ppte_req_159.cod_grp_ctr_estoq
            and cod_empresa = p_cod_empresa

         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Grupo nao Cadastrado na Tabela grupo_ctr_estoq !!!" 
            NEXT FIELD cod_grp_ctr_estoq
         END IF
               
              SELECT cod_grp_ctr_estoq
              FROM  item_ppte_req_159
              WHERE cod_grp_ctr_estoq = p_item_ppte_req_159.cod_grp_ctr_estoq
                and cod_empresa = p_cod_empresa
                
              IF STATUS = 0 THEN
             ERROR "Codigo do Grupo ja Cadastrado na Tabela grupo_ctr_estoq !!!" 
             NEXT FIELD cod_grp_ctr_estoq
             END IF 
               
         DISPLAY p_item_ppte_req_159.cod_grp_ctr_estoq TO cod_grp_ctr_estoq         
         DISPLAY p_den_gru_ctr_estoq TO den_gru_ctr_estoq 
          
       END IF  
          
        
     
     PROMPT "Deseja selecionar todos os itens? (S/N)"
     FOR CHAR ans
      
      IF ( ans = "s" OR ans = "S" ) THEN
    LET p_item_ppte_req_159.ies_qtd_pecas_emb  = 'S'
    LET p_item_ppte_req_159.ies_qtd_etiq_emb   = 'S'
    LET p_item_ppte_req_159.ies_den_mat_prima  = 'S'  
    LET p_item_ppte_req_159.ies_comprimento    = 'S'
    LET p_item_ppte_req_159.ies_tol_compr      = 'S'
    LET p_item_ppte_req_159.ies_largura        = 'S'
    LET p_item_ppte_req_159.ies_tol_largura    = 'S'
    LET p_item_ppte_req_159.ies_espessura      = 'S'
    LET p_item_ppte_req_159.ies_tol_espessura  = 'S'
    LET p_item_ppte_req_159.ies_gramatura      = 'S'
    LET p_item_ppte_req_159.ies_gramatura_min  = 'S'
    LET p_item_ppte_req_159.ies_gramatura_max  = 'S'
    LET p_item_ppte_req_159.ies_peso           = 'S'
    LET p_item_ppte_req_159.ies_peso_min       = 'S'
    LET p_item_ppte_req_159.ies_peso_max       = 'S'
    LET p_item_ppte_req_159.ies_lado_corte     = 'S'
    LET p_item_ppte_req_159.ies_compr_lamina   = 'S'
    LET p_item_ppte_req_159.ies_largura_lamina = 'S'
    LET p_item_ppte_req_159.ies_batidas_hora   = 'S'
    LET p_item_ppte_req_159.ies_cavidade       = 'S'
    LET p_item_ppte_req_159.ies_pecas_pacote   = 'S'
    LET p_item_ppte_req_159.ies_area_aplicacao = 'S'
    LET p_item_ppte_req_159.ies_alt_aplicacao  = 'S'
    LET p_item_ppte_req_159.ies_tol_resina     = 'S'
    LET p_item_ppte_req_159.ies_cod_tip_mat    = 'S'
    LET p_item_ppte_req_159.ies_observacao     = 'S'
    LET p_item_ppte_req_159.ies_fornecedor     = 'S'
    LET p_item_ppte_req_159.ies_dia_validade   = 'S'
      
    DISPLAY p_item_ppte_req_159.ies_qtd_pecas_emb  TO ies_qtd_pecas_emb
    DISPLAY p_item_ppte_req_159.ies_qtd_etiq_emb   TO ies_qtd_etiq_emb
    DISPLAY p_item_ppte_req_159.ies_den_mat_prima  TO ies_den_mat_prima 
    DISPLAY p_item_ppte_req_159.ies_comprimento    TO ies_comprimento 
    DISPLAY p_item_ppte_req_159.ies_tol_compr      TO ies_tol_compr
    DISPLAY p_item_ppte_req_159.ies_largura        TO ies_largura
    DISPLAY p_item_ppte_req_159.ies_tol_largura    TO ies_tol_largura
    DISPLAY p_item_ppte_req_159.ies_espessura      TO ies_espessura
    DISPLAY p_item_ppte_req_159.ies_tol_espessura  TO ies_tol_espessura
    DISPLAY p_item_ppte_req_159.ies_gramatura      TO ies_gramatura
    DISPLAY p_item_ppte_req_159.ies_gramatura_min  TO ies_gramatura_min 
    DISPLAY p_item_ppte_req_159.ies_gramatura_max  TO ies_gramatura_max
    DISPLAY p_item_ppte_req_159.ies_peso           TO ies_peso 
    DISPLAY p_item_ppte_req_159.ies_peso_min       TO ies_peso_min
    DISPLAY p_item_ppte_req_159.ies_peso_max       TO ies_peso_max
    DISPLAY p_item_ppte_req_159.ies_lado_corte     TO ies_lado_corte
    DISPLAY p_item_ppte_req_159.ies_compr_lamina   TO ies_compr_lamina
    DISPLAY p_item_ppte_req_159.ies_largura_lamina TO ies_largura_lamina
    DISPLAY p_item_ppte_req_159.ies_batidas_hora   TO ies_batidas_hora
    DISPLAY p_item_ppte_req_159.ies_cavidade       TO ies_cavidade
    DISPLAY p_item_ppte_req_159.ies_pecas_pacote   TO ies_pecas_pacote
    DISPLAY p_item_ppte_req_159.ies_area_aplicacao TO ies_area_aplicacao
    DISPLAY p_item_ppte_req_159.ies_alt_aplicacao  TO ies_alt_aplicacao
    DISPLAY p_item_ppte_req_159.ies_tol_resina     TO ies_tol_resina
    DISPLAY p_item_ppte_req_159.ies_cod_tip_mat    TO ies_cod_tip_mat
    DISPLAY p_item_ppte_req_159.ies_observacao     TO ies_observacao
    DISPLAY p_item_ppte_req_159.ies_fornecedor     TO ies_fornecedor
    DISPLAY p_item_ppte_req_159.ies_dia_validade   TO ies_dia_validade
 
         
      
     END IF
        
                       
   LET p_campo = "pol0743"
   LET p_data = TODAY
   LET p_hora = TIME
   LET p_texto = "Inclusão do Grupo de estoque",p_item_ppte_req_159.cod_grp_ctr_estoq
   
  INSERT INTO audit_ppte_159 
  VALUES(p_cod_empresa,
         p_item_ppte_req_159.cod_grp_ctr_estoq, 
         p_campo,
         p_data,
         p_hora,
         p_user,
         p_texto)      
                   
     
          
      ON KEY (control-z)
          CALL pol0743_popup()
                          
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0743

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE 
   END IF 

END FUNCTION

#--------------------------#
 FUNCTION pol0743_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause  CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_item_ppte_req_159.* TO NULL
   LET p_item_ppte_req_159a.* = p_item_ppte_req_159.*

   CONSTRUCT BY NAME where_clause ON item_ppte_req_159.cod_grp_ctr_estoq 
  
      ON KEY (control-z)
         CALL pol0743_popup()

          
   END CONSTRUCT      
    
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0743

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_item_ppte_req_159.* = p_item_ppte_req_159a.*
      CALL pol0743_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM item_ppte_req_159 ",
                  " where ", where_clause CLIPPED, 
                  "   and cod_empresa = '",p_cod_empresa,"' ",                
                  "ORDER BY cod_grp_ctr_estoq "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_item_ppte_req_159.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0743_exibe_dados()
   END IF

END FUNCTION



#------------------------------#
 FUNCTION pol0743_exibe_dados()
#------------------------------#
  SELECT den_gru_ctr_estoq
  INTO p_den_gru_ctr_estoq
  FROM grupo_ctr_estoq
  WHERE gru_ctr_estoq = p_item_ppte_req_159.cod_grp_ctr_estoq
    and cod_empresa = p_cod_empresa

 DISPLAY BY NAME p_item_ppte_req_159.*
 DISPLAY p_den_gru_ctr_estoq TO den_gru_ctr_estoq 

   
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0743_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_item_ppte_req_159.*                                              
     FROM item_ppte_req_159
        #WHERE cod_empresa = p_item_ppte_req_159.cod_empresa
        WHERE cod_grp_ctr_estoq = p_item_ppte_req_159.cod_grp_ctr_estoq
          and cod_empresa = p_cod_empresa
        
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","item_ppte_req_159")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0743_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0743_cursor_for_update() THEN
      LET p_item_ppte_req_159a.* = p_item_ppte_req_159.*
      IF pol0743_entrada_dados("MODIFICACAO") THEN
         UPDATE item_ppte_req_159
            SET #cod_grp_ctr_estoq = p_item_ppte_req_159.cod_grp_ctr_estoq
                ies_den_mat_prima = p_item_ppte_req_159.ies_den_mat_prima,
                ies_comprimento   = p_item_ppte_req_159.ies_comprimento,
                ies_tol_compr     = p_item_ppte_req_159.ies_tol_compr,
                ies_largura       = p_item_ppte_req_159.ies_largura,
                ies_tol_largura   = p_item_ppte_req_159.ies_tol_largura,
                ies_espessura     = p_item_ppte_req_159.ies_espessura,
                ies_tol_espessura = p_item_ppte_req_159.ies_tol_espessura,
                ies_gramatura     = p_item_ppte_req_159.ies_gramatura,
                ies_gramatura_min = p_item_ppte_req_159.ies_gramatura_min,
                ies_gramatura_max = p_item_ppte_req_159.ies_gramatura_max,
                ies_peso          = p_item_ppte_req_159.ies_peso,
                ies_peso_min      = p_item_ppte_req_159.ies_peso_min,
                ies_peso_max      = p_item_ppte_req_159.ies_peso_max,
                ies_lado_corte    = p_item_ppte_req_159.ies_lado_corte,
                ies_compr_lamina  = p_item_ppte_req_159.ies_compr_lamina,
                ies_largura_lamina= p_item_ppte_req_159.ies_largura_lamina,
                ies_batidas_hora  = p_item_ppte_req_159.ies_batidas_hora,
                ies_cavidade      = p_item_ppte_req_159.ies_cavidade,
                ies_qtd_pecas_emb = p_item_ppte_req_159.ies_qtd_pecas_emb,
                ies_qtd_etiq_emb  = p_item_ppte_req_159.ies_qtd_etiq_emb,
                ies_pecas_pacote  = p_item_ppte_req_159.ies_pecas_pacote,
                ies_area_aplicacao= p_item_ppte_req_159.ies_area_aplicacao,
                ies_alt_aplicacao = p_item_ppte_req_159.ies_alt_aplicacao,
                ies_tol_resina    = p_item_ppte_req_159.ies_tol_resina,
                ies_cod_tip_mat   = p_item_ppte_req_159.ies_cod_tip_mat,
                ies_observacao    = p_item_ppte_req_159.ies_observacao,
                ies_fornecedor    = p_item_ppte_req_159.ies_fornecedor,
                ies_dia_validade  = p_item_ppte_req_159.ies_dia_validade
             
              WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","item_ppte_req_159")
         END IF
      ELSE
         LET p_item_ppte_req_159.* = p_item_ppte_req_159a.*
         CALL pol0743_exibe_dados()
      END IF
 
      CLOSE cm_padrao
   END IF
   
     LET p_campo = "pol0743"
   LET p_data = TODAY
   LET p_hora = TIME
   LET p_texto = "Modificação do Grupo de estoque",p_item_ppte_req_159.cod_grp_ctr_estoq
   
  INSERT INTO audit_ppte_159 
  VALUES(p_cod_empresa,
         p_item_ppte_req_159.cod_grp_ctr_estoq, 
         p_campo,
         p_data,
         p_hora,
         p_user,
         p_texto)  

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION 

#--------------------------#
 FUNCTION pol0743_exclusao()
#--------------------------#
   
    LET p_campo = "pol0743"
   LET p_data = TODAY
   LET p_hora = TIME
   LET p_texto = "Exclusão do Grupo de estoque",p_item_ppte_req_159.cod_grp_ctr_estoq
   
  INSERT INTO audit_ppte_159 
  VALUES(p_cod_empresa,
         p_item_ppte_req_159.cod_grp_ctr_estoq, 
         p_campo,
         p_data,
         p_hora,
         p_user,
         p_texto)  

   LET p_retorno = FALSE
   IF pol0743_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM item_ppte_req_159
        WHERE cod_empresa = p_item_ppte_req_159.cod_empresa
          AND cod_grp_ctr_estoq = p_item_ppte_req_159.cod_grp_ctr_estoq
        
        
         
         #AND CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_item_ppte_req_159.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","item_ppte_req_159")
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

#-----------------------------------#
 FUNCTION pol0743_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_item_ppte_req_159a.* = p_item_ppte_req_159.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_item_ppte_req_159.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_item_ppte_req_159.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_item_ppte_req_159.* = p_item_ppte_req_159a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_item_ppte_req_159.*
           FROM item_ppte_req_159
          WHERE cod_empresa = p_item_ppte_req_159.cod_empresa 
            AND cod_grp_ctr_estoq = p_item_ppte_req_159.cod_grp_ctr_estoq
            and cod_empresa = p_cod_empresa
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0743_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------#
FUNCTION pol0743_popup()
#-----------------------#
    DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_grp_ctr_estoq)
         CALL log009_popup(8,10,"GRUPO DE ESTOQUE","grupo_ctr_estoq",
              "gru_ctr_estoq","den_gru_ctr_estoq","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0702
          
         IF p_codigo IS NOT NULL THEN
           LET p_item_ppte_req_159.cod_grp_ctr_estoq = p_codigo CLIPPED
           DISPLAY p_codigo TO cod_grp_ctr_estoq
         END IF 
      
         
   END CASE
         

END FUNCTION 

#-----------------------#
 FUNCTION pol0743_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#