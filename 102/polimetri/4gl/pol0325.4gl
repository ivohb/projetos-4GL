#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0325                                                 #
# MODULOS.: POL0325 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA CTA_CONT_POLIMETRI                 #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 14/02/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa LIKE empresa.cod_empresa,
          p_den_empresa LIKE empresa.den_empresa,  
          p_user        LIKE usuario.nom_usuario,
          p_den_conta   LIKE plano_contas.den_conta,
          p_status      SMALLINT,
          p_houve_erro  SMALLINT,
          comando       CHAR(80),
      #   p_versao      CHAR(17),
          p_versao      CHAR(18),
          p_nom_tela    CHAR(080),
          p_nom_help    CHAR(200),
          p_ies_cons    SMALLINT,
          p_last_row    SMALLINT,
          p_msg         CHAR(500)

   DEFINE p_cta_cont_polimetri  RECORD LIKE cta_cont_polimetri.*,
          p_cta_cont_polimetrii RECORD LIKE cta_cont_polimetri.*,
          p_hist_padrao         RECORD LIKE hist_padrao.* 
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0325-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0325.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

# CALL log001_acessa_usuario("VDP")
  CALL log001_acessa_usuario("ESPEC999","")
     RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL pol0325_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0325_controle()
#--------------------------#

  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("POL0325") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0325 AT 2,2 WITH FORM p_nom_tela 
    ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","pol0325","IN") THEN
        CALL pol0325_inclusao() RETURNING p_status
      END IF
    COMMAND "Excluir" "Exclui dados da tabela"
      HELP 003
      MESSAGE ""
      LET int_flag = 0
      IF  p_cta_cont_polimetri.cod_empresa IS NOT NULL THEN
          IF  log005_seguranca(p_user,"VDP","pol0325","EX") THEN
              CALL pol0325_exclusao()
          END IF
      ELSE
          ERROR " Consulte Previamente para fazer a Exclusao"
      END IF 
    COMMAND "Consultar" "Consulta dados da tabela"
      HELP 004
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0325","CO") THEN
          CALL pol0325_consulta()
          IF p_ies_cons = TRUE THEN
             NEXT OPTION "Seguinte"
          END IF
      END IF
    COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
      HELP 005
      MESSAGE ""
      LET int_flag = 0
      CALL pol0325_paginacao("SEGUINTE")
    COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
      HELP 006
      MESSAGE ""
      LET int_flag = 0
      CALL pol0325_paginacao("ANTERIOR") 
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0325_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0325

END FUNCTION

#--------------------------------------#
 FUNCTION pol0325_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
  CLEAR FORM
  IF pol0325_entrada_dados() THEN
     CALL log085_transacao("BEGIN")
  #  BEGIN WORK
     LET p_cta_cont_polimetri.cod_empresa = p_cod_empresa
     INSERT INTO cta_cont_polimetri VALUES (p_cta_cont_polimetri.*)
     IF sqlca.sqlcode <> 0 THEN 
        CALL log085_transacao("ROLLBACK")
     #  ROLLBACK WORK 
	LET p_houve_erro = TRUE
	CALL log003_err_sql("INCLUSAO","CTA_CONT_POLIMETRI")
     ELSE
        CALL log085_transacao("COMMIT")
     #  COMMIT WORK 
        MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
        LET p_ies_cons = FALSE
     END IF
  ELSE
     CLEAR FORM
     ERROR " Inclusao Cancelada"
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0325_entrada_dados()
#-------------------------------#

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0325
  INITIALIZE p_cta_cont_polimetri.*, p_hist_padrao.*,
             p_den_conta TO NULL
  DISPLAY BY NAME p_cta_cont_polimetri.*
  DISPLAY p_den_conta TO den_conta   
  DISPLAY p_cod_empresa TO cod_empresa 

  INPUT BY NAME p_cta_cont_polimetri.num_conta,
                p_cta_cont_polimetri.cod_hist
    WITHOUT DEFAULTS  

    AFTER FIELD num_conta  
      IF p_cta_cont_polimetri.num_conta IS NULL THEN
         ERROR "O Campo Conta Contabil nao pode ser Nulo"
         NEXT FIELD num_conta  
      ELSE
         SELECT den_conta   
            INTO p_den_conta   
         FROM plano_contas
         WHERE cod_empresa = p_cod_empresa 
           AND num_conta = p_cta_cont_polimetri.num_conta   
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Conta Contabil nao Cadastrada"
            NEXT FIELD num_conta  
         END IF
         IF pol0325_verifica_dupl() THEN
            ERROR "Conta Contabil Já Cadastrada"
            NEXT FIELD num_conta  
         END IF
         DISPLAY p_den_conta TO den_conta  
      END IF

      AFTER FIELD cod_hist      
      IF p_cta_cont_polimetri.cod_hist IS NULL THEN
         ERROR "O Campo Codigo do Historico nao pode ser Nulo"
         NEXT FIELD cod_hist   
      ELSE
         SELECT tex_hist
            INTO p_hist_padrao.tex_hist
         FROM hist_padrao   
	 WHERE cod_empresa = p_cod_empresa   
	   AND cod_hist = p_cta_cont_polimetri.cod_hist
	 IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Codigo do Historico nao Cadastrado"
            NEXT FIELD cod_hist   
         END IF
         DISPLAY BY NAME p_hist_padrao.tex_hist
      END IF

      ON KEY (control-z)
         IF INFIELD(num_conta) THEN 
         #  LET p_cta_cont_polimetri.num_conta = 
         #  con010_popup_selecao_plano_contas(p_cod_empresa)
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0325 
            IF p_cta_cont_polimetri.num_conta IS NOT NULL THEN
               DISPLAY BY NAME p_cta_cont_polimetri.num_conta
            END IF
         END IF
         IF INFIELD(cod_hist) THEN 
            CALL log009_popup(6,25,"HISTORICO","hist_padrao","cod_hist",
                             "tex_hist","","N","") 
               RETURNING p_cta_cont_polimetri.cod_hist
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0325 
            IF p_cta_cont_polimetri.cod_hist IS NOT NULL THEN
               DISPLAY BY NAME p_cta_cont_polimetri.cod_hist
            END IF
         END IF   

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0325
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0325_consulta()
#--------------------------#

 DEFINE sql_stmt, 
        where_clause  CHAR(300)  
 CLEAR FORM
 DISPLAY p_cod_empresa TO cod_empresa 

 CONSTRUCT BY NAME where_clause ON cta_cont_polimetri.num_conta,    
                                   cta_cont_polimetri.cod_hist     

 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0325
 IF INT_FLAG THEN
   LET INT_FLAG = 0 
   LET p_cta_cont_polimetri.* = p_cta_cont_polimetrii.*
   CALL pol0325_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM cta_cont_polimetri ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY num_conta "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_cta_cont_polimetri.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0325_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0325_exibe_dados()
#-----------------------------#

   SELECT den_conta   
      INTO p_den_conta   
   FROM plano_contas
   WHERE cod_empresa = p_cod_empresa
     AND num_conta = p_cta_cont_polimetri.num_conta

   SELECT tex_hist
      INTO p_hist_padrao.tex_hist
   FROM hist_padrao   
   WHERE cod_empresa = p_cod_empresa   
     AND cod_hist = p_cta_cont_polimetri.cod_hist

   DISPLAY BY NAME p_cta_cont_polimetri.num_conta,
                   p_cta_cont_polimetri.cod_hist 
   DISPLAY p_den_conta TO den_conta  
   DISPLAY BY NAME p_hist_padrao.tex_hist

END FUNCTION

#-----------------------------------#
 FUNCTION pol0325_paginacao(p_funcao)
#-----------------------------------#

  DEFINE p_funcao CHAR(20)

  IF p_ies_cons THEN
     LET p_cta_cont_polimetrii.* = p_cta_cont_polimetri.*
     WHILE TRUE
        CASE
           WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_cta_cont_polimetri.*
           WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_cta_cont_polimetri.*
        END CASE
     
        IF SQLCA.SQLCODE = NOTFOUND THEN
           ERROR "Nao Existem mais Registros nesta Direcao"
           LET p_cta_cont_polimetri.* = p_cta_cont_polimetrii.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_cta_cont_polimetri.* FROM cta_cont_polimetri    
        WHERE cod_empresa = p_cta_cont_polimetri.cod_empresa 
          AND num_conta = p_cta_cont_polimetri.num_conta   
  
        IF SQLCA.SQLCODE = 0 THEN 
           CALL pol0325_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao Existe Nenhuma Consulta Ativa"
  END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0325_cursor_for_update()
#-----------------------------------#

  WHENEVER ERROR CONTINUE
  DECLARE cm_padrao CURSOR WITH HOLD FOR
  SELECT *                            
    INTO p_cta_cont_polimetri.*                                              
  FROM cta_cont_polimetri      
  WHERE cod_empresa = p_cta_cont_polimetri.cod_empresa 
    AND num_conta = p_cta_cont_polimetri.num_conta   
  FOR UPDATE 
  CALL log085_transacao("BEGIN")
# BEGIN WORK
  OPEN cm_padrao
  FETCH cm_padrao
  CASE SQLCA.SQLCODE
     WHEN    0 RETURN TRUE 
     WHEN -250 ERROR " Registro sendo Atualizado por outro Usua",
                     "rio. Aguarde e tente Novamente"
     WHEN  100 ERROR " Registro nao mais Existe na Tabela. Exec",
                      "ute a Consulta Novamente"
     OTHERWISE CALL log003_err_sql("LEITURA","CTA_CONT_POLIMETRI")
  END CASE
  WHENEVER ERROR STOP

  RETURN FALSE

END FUNCTION

#--------------------------#
 FUNCTION pol0325_exclusao()
#--------------------------#

   IF pol0325_cursor_for_update() THEN
      IF log004_confirm(12,44) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM cta_cont_polimetri    
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","CTA_CONT_POLIMETRI")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE p_cta_cont_polimetri.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","CTA_CONT_POLIMETRI")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-------------------------------#
 FUNCTION pol0325_verifica_dupl()
#-------------------------------#

   SELECT *
   FROM cta_cont_polimetri
   WHERE cod_empresa = p_cod_empresa
     AND num_conta = p_cta_cont_polimetri.num_conta   
   IF SQLCA.SQLCODE = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION 

#-----------------------#
 FUNCTION pol0325_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#
