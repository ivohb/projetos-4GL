###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE DESPESAS DE VIAGENS                       #
# PROGRAMA: CDV2016                                               #
# OBJETIVO: CADASTRO RESPONSÁVEL ADMINISTRATIVO PARA GRUPO DE     #
#           VIAJANTES/APROVANTES                                  #
#           (ESPECIFICO PAMCARY SIST. GER. RISCO)                 #
# AUTOR...: MAJARA PAULA SCHNEIDER DE SOUZA                       #
# DATA....: 10/09/2011                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_cod_empresa         LIKE empresa.cod_empresa,
         p_user                LIKE usuario.nom_usuario

  DEFINE g_ies_ambiente        CHAR(1),
         g_ies_grafico         SMALLINT

  #----------------------------------------------------------------------#
  #--# Variaveis utilizadas quando programa possui opção para gerar relatório
  #--# utilizando função log0280

  DEFINE p_ies_impressao       CHAR(1),
         p_nom_arquivo         CHAR(100),
         g_num_programa_impres CHAR(8),
         g_usa_visualizador    SMALLINT
  #----------------------------------------------------------------------#

  DEFINE p_versao              CHAR(18) #Favor não Alterar esta linha (SUPORTE)

END GLOBALS

#--# MODULARES #--#

  DEFINE m_consulta_ativa       SMALLINT

  DEFINE m_comando              CHAR(250),
         m_caminho              CHAR(150),
         m_status               SMALLINT,
         m_msg                  CHAR(300)

  DEFINE ma_resp_apr_viaj       ARRAY[10000] OF RECORD
                                  aprov_viajante          CHAR(09),
                                  login_apr_viajante      LIKE cdv_resp_apr_viaj_1125.login_apr_viajante,
                                  nom_aprov_viajante      LIKE usuarios.nom_funcionario
                                END RECORD

  DEFINE ma_resp_apr_viajr      ARRAY[10000] OF RECORD
                                  aprov_viajante          CHAR(09),
                                  login_apr_viajante      LIKE cdv_resp_apr_viaj_1125.login_apr_viajante,
                                  nom_aprov_viajante      LIKE usuarios.nom_funcionario
                                END RECORD


  DEFINE mr_resp_adm             RECORD
                                   empresa              LIKE cdv_resp_apr_viaj_1125.empresa, # campos tela
                                   login_resp_adm       LIKE cdv_resp_apr_viaj_1125.login_resp_adm,
                                   nom_resp_adm         LIKE usuarios.nom_funcionario
                                END RECORD

  DEFINE mr_resp_admr            RECORD
                                   empresa              LIKE cdv_resp_apr_viaj_1125.empresa, # campos tela
                                   login_resp_adm       LIKE cdv_resp_apr_viaj_1125.login_resp_adm,
                                   nom_resp_adm         LIKE usuarios.nom_funcionario
                                END RECORD

  #--#CONTROLE DO ARRAY#--#
  DEFINE m_cont                 SMALLINT,
         ma_curr                SMALLINT,
         m_scr_curr             SMALLINT


#--# END MODULARES #--#

MAIN

  LET p_versao = "CDV2016-10.02.00" #Favor não alterar esta linha (SUPORTE)

  CALL log0180_conecta_usuario()

  CALL log1400_isolation()

  WHENEVER ERROR CONTINUE
     SET LOCK MODE TO WAIT
  WHENEVER ERROR STOP

  DEFER INTERRUPT

  CALL log001_acessa_usuario("TREIN","LOGERP")
     RETURNING m_status, p_cod_empresa, p_user
  IF NOT m_status THEN
     CALL cdv2016_controle()
  END IF

END MAIN

#--------------------------#
 FUNCTION cdv2016_controle()
#--------------------------#

  LET g_num_programa_impres = "cdv2016"
  LET g_usa_visualizador    = TRUE
  LET m_consulta_ativa      = FALSE

  CALL log006_exibe_teclas("01",p_versao)
  CALL log130_procura_caminho("cdv2016")
     RETURNING m_caminho

  OPEN WINDOW w_cdv2016 AT 2,2 WITH FORM m_caminho
     ATTRIBUTE(BORDER,MESSAGE LINE LAST,PROMPT LINE LAST)

  CALL cdv2016_ativa_help()

  MENU "OPÇÃO"
  COMMAND "Incluir"   "Inclusão de responsável administrativo e grupo de aprovantes/viajantes."
     HELP 001
     MESSAGE ""
     IF log005_seguranca(p_user,"TREIN","cdv2016","IN") THEN
        CALL cdv2016_menu_incluir()
     END IF

   COMMAND "Consultar" "Consulta de responsável administrativo e grupo de aprovantes/viajantes."
     HELP 004
     MESSAGE ""
     IF log005_seguranca(p_user,"TREIN" ,"cdv2016","CO") THEN
        CALL cdv2016_menu_consultar()
     END IF

  COMMAND "Modificar" "Modificação de responsável administrativo e grupo de aprovantes/viajantes já cadastrados."
     HELP 002
     MESSAGE ""
     IF log005_seguranca(p_user,"TREIN","cdv2016","MO") THEN
        CALL cdv2016_menu_modificar()
     END IF

  COMMAND "Excluir"   "Exclusão de responsável administrativo e grupo de aprovantes/viajantes cadastrado."
     HELP 003
     MESSAGE ""
     IF log005_seguranca(p_user,"TREIN","cdv2016","EX") THEN
        CALL cdv2016_menu_excluir()
     END IF

  COMMAND "Anterior"  "Exibe o responsável administrativo anterior encontrado na consulta."
     HELP 006
     MESSAGE ""
     CALL cdv2016_menu_paginacao("ANTERIOR")

  COMMAND "Seguinte"  "Exibe o próximo de responsável administrativo encontrado na consulta."
     HELP 005
     MESSAGE ""
     CALL cdv2016_menu_paginacao("SEGUINTE")

  COMMAND "Listar"  "Lista os responsáveis administrativos e seus grupos de aprovantes/viajantes."
      HELP 007
      MESSAGE ""
      CALL cdv2016_lista_dados()

  COMMAND KEY ("!")
     PROMPT "Digite o comando: " FOR m_comando
     RUN m_comando
     PROMPT "\nTecle <ENTER> para continuar..." FOR CHAR m_comando

  COMMAND "Fim"       "Retorna ao menu anterior."
     HELP 008
     EXIT MENU

  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

  CLOSE WINDOW w_cdv2016

END FUNCTION

#-------------------------------#
 FUNCTION cdv2016_inicializacao()
#-------------------------------#

  INITIALIZE ma_resp_apr_viaj,
             ma_resp_apr_viajr,
             mr_resp_adm.*
             TO NULL

END FUNCTION

#------------------------------#
 FUNCTION cdv2016_menu_incluir()
#------------------------------#
  LET m_cont = 1
  CALL SET_COUNT(m_cont)

  IF cdv2016_entrada_dados("INCLUSAO") THEN
     IF cdv2016_entrada_array("Inclusão") THEN

        WHENEVER ERROR CONTINUE
            CALL log085_transacao("BEGIN")
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("TRANSAÇÃO","BEGIN")
        END IF

        CALL cdv2016_grava_resp_aprov_viaj("INCLUSÃO")

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("INCLUSÃO","departamento")

           WHENEVER ERROR CONTINUE
               CALL log085_transacao("ROLLBACK")
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("TRANSACAO","ROLLBACK")
           END IF
        ELSE
           WHENEVER ERROR CONTINUE
               CALL log085_transacao("COMMIT")
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("TRANSACAO","COMMIT")
           END IF
           MESSAGE "Inclusão efetuada com sucesso." ATTRIBUTE (REVERSE)
        END IF

        LET m_consulta_ativa = FALSE
      ELSE
         MESSAGE "Inclusão cancelada." ATTRIBUTE (REVERSE)
      END IF
  ELSE
     MESSAGE "Inclusão cancelada." ATTRIBUTE (REVERSE)
  END IF

END FUNCTION

#---------------------------------------#
 FUNCTION cdv2016_entrada_dados(l_funcao)
#---------------------------------------#
  DEFINE l_funcao           CHAR(015)

  LET mr_resp_admr.* = mr_resp_adm.*

  IF l_funcao = "INCLUSAO" THEN
     CLEAR FORM
     INITIALIZE ma_resp_apr_viaj,
                mr_resp_adm.*
                TO NULL

  END IF

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_cdv2016

  LET int_flag = FALSE

  INPUT BY NAME mr_resp_adm.empresa,
                mr_resp_adm.login_resp_adm
                 WITHOUT DEFAULTS

     BEFORE FIELD login_resp_adm
        IF l_funcao = "MODIFICACAO" THEN
           EXIT INPUT
        END IF
        LET mr_resp_adm.empresa = p_cod_empresa
        DISPLAY mr_resp_adm.empresa TO empresa

     AFTER FIELD login_resp_adm
        IF NOT cdv2016_verifica_login(mr_resp_adm.login_resp_adm) THEN
           ERROR " Login não encontrado. "
           NEXT FIELD login_resp_adm
        ELSE
           IF cdv2016_verifica_dupl_resp_adm(mr_resp_adm.login_resp_adm) THEN
              ERROR "Responsável administrativo já cadastrado. "
              NEXT FIELD login_resp_adm
           END IF
        END IF
        CALL cdv2016_exibe_dados()

     ON KEY (control-w, f1)
        CALL cdv2016_help()

     AFTER INPUT

        IF int_flag = FALSE THEN
           IF l_funcao = "INCLUSAO" THEN
              IF NOT cdv2016_verifica_login(mr_resp_adm.login_resp_adm) THEN
                 ERROR " Login não encontrado. "
                 NEXT FIELD login_resp_adm
              ELSE
                 IF cdv2016_verifica_dupl_resp_adm(mr_resp_adm.login_resp_adm) THEN
                    ERROR "Responsável administrativo já cadastrado. "
                    NEXT FIELD login_resp_adm
                 END IF
              END IF
              CALL cdv2016_exibe_dados()
           END IF

        END IF

     ON KEY (control-z,f4)
        CALL cdv2016_popups()

  END INPUT

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_cdv2016

  IF int_flag = 0 THEN
     RETURN TRUE
  ELSE
     LET mr_resp_adm.* = mr_resp_admr.*
     CALL cdv2016_exibe_dados()
     RETURN FALSE
  END IF

END FUNCTION

#---------------------------------------#
 FUNCTION cdv2016_entrada_array(l_funcao)
#---------------------------------------#
  DEFINE l_funcao    CHAR(12)
  DEFINE l_ct_aux    SMALLINT,
         l_achou     SMALLINT,
         l_ind       INTEGER

  CALL log006_exibe_teclas("01 02 05 06 07", p_versao)

  LET ma_resp_apr_viajr.* = ma_resp_apr_viaj.*

  CALL set_count(m_cont)

  INPUT ARRAY  ma_resp_apr_viaj WITHOUT DEFAULTS FROM sr_resp_apr_viaj.*

     BEFORE ROW
        LET m_cont = ARR_COUNT()
        LET ma_curr = ARR_CURR()
        LET m_scr_curr = SCR_LINE()

     BEFORE FIELD aprov_viajante
       NEXT FIELD login_apr_viajante

     BEFORE FIELD login_apr_viajante
        --# CALL fgl_dialog_setkeylabel("control-z","Zoom")
        IF NOT g_ies_grafico THEN
           DISPLAY "( Zoom )" AT 3,68
        END IF

     AFTER FIELD login_apr_viajante
        IF NOT g_ies_grafico THEN
           DISPLAY "--------" at 3,68
        END IF
        IF ma_resp_apr_viaj[ma_curr].login_apr_viajante IS NOT NULL AND  ma_resp_apr_viaj[ma_curr].login_apr_viajante <> "  " THEN
           IF NOT cdv2016_verifica_login(ma_resp_apr_viaj[ma_curr].login_apr_viajante) THEN
              ERROR "Login inválido."
              NEXT FIELD login_apr_viajante
           ELSE
              IF cdv2016_verifica_dupl_aprov_viaj(ma_resp_apr_viaj[ma_curr].login_apr_viajante) THEN
                 NEXT FIELD login_apr_viajante
              END IF
           END IF
           CALL cdv_2016_exibe_item_array()
           LET ma_resp_apr_viaj[ma_curr].aprov_viajante = cdv2016_busca_eh_aprov_viajante(ma_resp_apr_viaj[ma_curr].login_apr_viajante)
           IF ma_resp_apr_viaj[ma_curr].aprov_viajante IS NULL THEN
              NEXT FIELD login_apr_viajante
           END IF
        END IF

     ON KEY (control-z,f4)
        CALL cdv2016_popups()

  AFTER INPUT

      IF int_flag = 0 THEN

         FOR l_ind = 1 TO 10000
            IF ma_resp_apr_viaj[l_ind].login_apr_viajante IS NULL OR ma_resp_apr_viaj[l_ind].login_apr_viajante = "  " THEN
            ELSE
               IF NOT cdv2016_verifica_login(ma_resp_apr_viaj[l_ind].login_apr_viajante) THEN
                  ERROR "Login inválido."
                  NEXT FIELD login_apr_viajante
               END IF
            END IF
         END FOR

      END IF

      ON KEY (control-w, f1)
        CALL cdv2016_help()

  END INPUT

  IF NOT g_ies_grafico THEN
        DISPLAY "--------" at 3,68
  END IF

  CURRENT WINDOW IS w_cdv2016

  IF int_flag THEN
     LET ma_resp_apr_viaj.* = ma_resp_apr_viajr.*
     CALL cdv2016_exibe_dados()
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

 END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2016_grava_resp_aprov_viaj(l_funcao)
#-----------------------------------------------#
   DEFINE l_funcao            CHAR(012)
   DEFINE ct_aux              SMALLINT
   DEFINE lr_resp_apr_viaj    RECORD
                              empresa                LIKE cdv_resp_apr_viaj_1125.empresa,
                              login_resp_adm         LIKE cdv_resp_apr_viaj_1125.login_resp_adm,
                              eh_aprov_viajante      LIKE cdv_resp_apr_viaj_1125.eh_apr_viajante,
                              login_aprov_viajante   LIKE cdv_resp_apr_viaj_1125.login_apr_viajante
                              END RECORD

   IF l_funcao = "MODIFICACAO" THEN
      IF NOT cdv2016_exclui_itens() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   END IF

   FOR ct_aux = 1 TO m_cont
      IF ma_resp_apr_viaj[ct_aux].login_apr_viajante IS NULL THEN
         EXIT FOR
      END IF

      LET lr_resp_apr_viaj.empresa            = p_cod_empresa
      LET lr_resp_apr_viaj.login_resp_adm     = mr_resp_adm.login_resp_adm

      LET lr_resp_apr_viaj.login_resp_adm     = mr_resp_adm.login_resp_adm
      IF ma_resp_apr_viaj[ct_aux].aprov_viajante = "APROVANTE" THEN
         LET lr_resp_apr_viaj.eh_aprov_viajante     = 'A'
      ELSE
         LET lr_resp_apr_viaj.eh_aprov_viajante     = 'V'
      END IF
      LET lr_resp_apr_viaj.login_aprov_viajante     =  ma_resp_apr_viaj[ct_aux].login_apr_viajante
      WHENEVER ERROR CONTINUE
         INSERT INTO cdv_resp_apr_viaj_1125 VALUES (lr_resp_apr_viaj.*)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('INSERT','cdv_resp_apr_viaj_1125')
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF

   END FOR

   RETURN TRUE
END FUNCTION

#------------------------------------------#
 FUNCTION cdv2016_bloqueio_registro_tabela()
#------------------------------------------#
  DEFINE lr_cdv_resp_apr_viaj RECORD LIKE cdv_resp_apr_viaj_1125.*

  WHENEVER ERROR CONTINUE
   DECLARE cm_resp_adm CURSOR FOR
    SELECT *
      FROM cdv_resp_apr_viaj_1125
     WHERE empresa = p_cod_empresa
       AND login_resp_adm = mr_resp_adm.login_resp_adm
       FOR UPDATE
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","cm_depart")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
      OPEN cm_resp_adm
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("OPEN","cm_depart")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
     FETCH cm_resp_adm INTO lr_cdv_resp_apr_viaj.*
  WHENEVER ERROR STOP

  CASE sqlca.sqlcode
     WHEN 0    RETURN TRUE
     WHEN 100  CALL log0030_mensagem ("Registro não encontrado. Consulte-o novamente.","exclamation")
     WHEN -284 RETURN TRUE
     OTHERWISE CALL log003_err_sql("SELECT","departamento")
  END CASE

  RETURN FALSE

END FUNCTION

#--------------------------------#
 FUNCTION cdv2016_menu_modificar()
#--------------------------------#

  IF NOT m_consulta_ativa THEN
     CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
     RETURN
  END IF

  LET ma_resp_apr_viajr = ma_resp_apr_viaj

  WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("TRANSAÇÃO","BEGIN")
  END IF

  IF NOT cdv2016_bloqueio_registro_tabela() THEN

     WHENEVER ERROR CONTINUE
         CALL log085_transacao("ROLLBACK")
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("TRANSAÇÃO","ROLLBACK")
     END IF

     ERROR "Modificação cancelada."
     RETURN
  END IF

  CALL cdv2016_exibe_dados()
  IF NOT cdv2016_entrada_array("MODIFICACAO") THEN
     WHENEVER ERROR CONTINUE
         CALL log085_transacao("ROLLBACK")
     WHENEVER ERROR STOP
  	  IF sqlca.sqlcode <> 0 THEN
  	     CALL log003_err_sql("TRANSAÇÃO","ROLLBACK")
  	  END IF

     LET ma_resp_apr_viaj = ma_resp_apr_viajr

     CALL cdv2016_exibe_dados()
     ERROR "Modificação cancelada."
     RETURN
  END IF

  IF  cdv2016_grava_resp_aprov_viaj("MODIFICACAO") THEN
      WHENEVER ERROR CONTINUE
          CALL log085_transacao("COMMIT")
      WHENEVER ERROR STOP
  	   IF sqlca.sqlcode <> 0 THEN
  	      CALL log003_err_sql("TRANSAÇÃO","COMMIT")
  	   ELSE
         MESSAGE "Modificação efetuada com sucesso." ATTRIBUTE(REVERSE)
      END IF
  END IF

END FUNCTION

#------------------------------#
 FUNCTION cdv2016_menu_excluir()
#------------------------------#

  IF NOT m_consulta_ativa THEN
     CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
     RETURN
  END IF

  IF log004_confirm(20,43) THEN

     CALL log085_transacao("BEGIN")

     IF cdv2016_exclui_itens() THEN
        CALL log085_transacao("COMMIT")
        IF sqlca.sqlcode = 0 THEN
           CLEAR FORM
           INITIALIZE mr_resp_adm.* TO NULL
           INITIALIZE ma_resp_apr_viaj TO NULL
           CALL cdv2016_exibe_dados()
           CALL log0030_mensagem("Exclusão efetuada com sucesso.","info")
        ELSE
           CALL log003_err_sql("COMMIT TRANSACTION","cap2500C")
           CALL log085_transacao("ROLLBACK")
        END IF
     ELSE
        CALL log085_transacao("ROLLBACK")
        CALL log0030_mensagem("Exclusao Cancelada.","info")
     END IF
  ELSE
     CALL log0030_mensagem("Exclusão Cancelada.","info")
  END IF

  CLEAR FORM

END FUNCTION

#------------------------------#
 FUNCTION cdv2016_exclui_itens()
#------------------------------#

 WHENEVER ERROR CONTINUE
    DELETE FROM cdv_resp_apr_viaj_1125
       WHERE empresa = p_cod_empresa
         AND login_resp_adm = mr_resp_adm.login_resp_adm
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
 ELSE
    CALL log003_err_sql("DELETE","cdv_resp_apr_viaj_1125")
    RETURN FALSE
 END IF

END FUNCTION


#--------------------------------#
 FUNCTION cdv2016_menu_consultar()
#--------------------------------#

  DEFINE sql_stmt               CHAR(2000),
         where_clause           CHAR(1000)


  LET m_consulta_ativa = FALSE

  CALL cdv2016_inicializacao()

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_cdv2016

  CLEAR FORM

  LET mr_resp_adm.empresa = p_cod_empresa
  DISPLAY mr_resp_adm.empresa  TO empresa

  LET int_flag = FALSE

  CONSTRUCT BY NAME where_clause ON login_resp_adm

     ON KEY (control-w, f1)
        CALL cdv2016_help()

     ON KEY (control-z, f4)
        CALL cdv2016_popups()

  END CONSTRUCT

  CALL log006_exibe_teclas("01",p_versao)

  CURRENT WINDOW IS w_cdv2016

  IF int_flag THEN
     ERROR "Consulta cancelada."
     RETURN
  END IF

  MESSAGE "Processando a consulta..." ATTRIBUTE(REVERSE)

  LET sql_stmt =
      "SELECT  empresa, login_resp_adm ",
       "FROM cdv_resp_apr_viaj_1125 ",
       "WHERE ",where_clause CLIPPED,
       "  AND empresa = """,p_cod_empresa,""" ",
       " GROUP BY empresa, login_resp_adm ",
       " ORDER BY  empresa, login_resp_adm "

  WHENEVER ERROR CONTINUE
   PREPARE resp_apr_viaj FROM sql_stmt
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
	    CALL log003_err_sql("PREPARE","resp_apr_viaj")
	    RETURN
  END IF

  LET m_cont = 0
  INITIALIZE ma_resp_apr_viaj TO NULL

  WHENEVER ERROR CONTINUE
   DECLARE cq_resp_apr_viaj SCROLL CURSOR WITH HOLD FOR resp_apr_viaj
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
	    CALL log003_err_sql("DECLARE","cq_resp_apr_viaj")
	    RETURN
  END IF

  WHENEVER ERROR CONTINUE
      OPEN cq_resp_apr_viaj
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("OPEN","cq_resp_apr_viaj")
     RETURN
  END IF

  WHENEVER ERROR CONTINUE
     FETCH cq_resp_apr_viaj INTO mr_resp_adm.empresa,
                                 mr_resp_adm.login_resp_adm
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     LET mr_resp_adm.nom_resp_adm = cdv2016_busca_nom_usuario(mr_resp_adm.login_resp_adm)
     CALL cdv2016_seleciona_itens()
     CALL cdv2016_exibe_dados()
  ELSE
     CALL log0030_mensagem("Argumentos de pesquisa não encontrados","info")
  END IF

  LET m_consulta_ativa = TRUE
  MESSAGE "Consulta efetuada com sucesso." ATTRIBUTE(REVERSE)

END FUNCTION

#----------------------------------------#
 FUNCTION cdv2016_menu_paginacao(l_funcao)
#----------------------------------------#

  DEFINE l_funcao CHAR(10)

  IF NOT m_consulta_ativa THEN
     CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
     RETURN
  END IF

  LET mr_resp_admr.* = mr_resp_adm.*

  WHENEVER ERROR CONTINUE
     CASE l_funcao
        WHEN "SEGUINTE" FETCH NEXT     cq_resp_apr_viaj INTO mr_resp_adm.*
        WHEN "ANTERIOR" FETCH PREVIOUS cq_resp_apr_viaj INTO mr_resp_adm.*
     END CASE
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     ERROR "Não existem mais dados nesta direção."
     LET mr_resp_adm.* = mr_resp_admr.*
  ELSE
     CALL cdv2016_seleciona_itens()
     CALL cdv2016_exibe_dados()
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION cdv2016_seleciona_itens()
#---------------------------------#
 DEFINE lr_resp_apr_viaj       RECORD
                               eh_apr_viajante        LIKE cdv_resp_apr_viaj_1125.eh_apr_viajante,
                               login_apr_viajante     LIKE cdv_resp_apr_viaj_1125.login_apr_viajante
                               END RECORD

 INITIALIZE ma_resp_apr_viaj TO NULL

 WHENEVER ERROR CONTINUE
  DECLARE cq_itens CURSOR FOR
   SELECT eh_apr_viajante,login_apr_viajante
     FROM cdv_resp_apr_viaj_1125
    WHERE empresa   = mr_resp_adm.empresa
      AND login_resp_adm = mr_resp_adm.login_resp_adm
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","cq_itens")
    RETURN
 END IF

 LET m_cont = 0
 WHENEVER ERROR CONTINUE
 FOREACH cq_itens INTO lr_resp_apr_viaj.*
 WHENEVER ERROR STOP
     LET m_cont = m_cont + 1

     IF m_cont > 10000 THEN
       ERROR "Limite do Array estourado. "
       EXIT FOREACH
     END IF
     IF lr_resp_apr_viaj.eh_apr_viajante = 'A' THEN
        LET ma_resp_apr_viaj[m_cont].aprov_viajante = "APROVANTE"
     ELSE
        LET ma_resp_apr_viaj[m_cont].aprov_viajante = "VIAJANTE"
     END IF
     LET ma_resp_apr_viaj[m_cont].login_apr_viajante = lr_resp_apr_viaj.login_apr_viajante
     LET ma_resp_apr_viaj[m_cont].nom_aprov_viajante = cdv2016_busca_nom_usuario(lr_resp_apr_viaj.login_apr_viajante)

  END FOREACH
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("FOREACH","cq_itens")
     RETURN
  END IF

  IF m_cont  = 0 THEN
     CALL log0030_mensagem("Argumentos de pesquisa não encontrados.","info")
  END IF

 END FUNCTION


#-----------------------------#
 FUNCTION cdv2016_exibe_dados()
#-----------------------------#
  DEFINE l_ind  INTEGER

  CLEAR FORM
  DISPLAY BY NAME mr_resp_adm.*


  IF m_cont IS NOT NULL THEN
    CALL SET_COUNT(m_cont)
    IF m_cont > 10 THEN
       DISPLAY ARRAY ma_resp_apr_viaj TO sr_resp_apr_viaj.*
    ELSE
       FOR l_ind = 1 TO m_cont
          DISPLAY ma_resp_apr_viaj[l_ind].* TO sr_resp_apr_viaj[l_ind].*
       END FOR
    END IF
 END IF

END FUNCTION

#----------------------------#
 FUNCTION cdv2016_ativa_help()
#----------------------------#

  DEFINE l_arquivo_help CHAR(100)

  LET l_arquivo_help = log140_procura_caminho("cdv2016.iem")
  OPTIONS HELP FILE l_arquivo_help

END FUNCTION

#----------------------#
 FUNCTION cdv2016_help()
#----------------------#

  CASE
     WHEN infield(login_resp_adm) CALL showhelp(101)
  END CASE

END FUNCTION

#------------------------------------#
 FUNCTION cdv2016_busca_nom_resp_adm()
#------------------------------------#
 DEFINE l_nom_func  LIKE usuarios.nom_funcionario

 WHENEVER ERROR CONTINUE
    SELECT nom_funcionario INTO l_nom_func
     FROM usuarios
     WHERE cod_usuario = mr_resp_adm.login_resp_adm
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("SELECT","usuarios")
     RETURN " "
  END IF

 RETURN  l_nom_func

 END FUNCTION

#------------------------#
 FUNCTION cdv2016_popups()
#------------------------#

 CASE
    WHEN INFIELD(aprov_viajante)
       LET ma_resp_apr_viaj[ma_curr].aprov_viajante = log0830_list_box(14,24, 'APROVANTE {Aprovante} , VIAJANTE {Viajante}')
       CURRENT WINDOW IS w_cdv2016
       DISPLAY ma_resp_apr_viaj[ma_curr].aprov_viajante TO sr_resp_apr_viaj[m_scr_curr].aprov_viajante

    WHEN INFIELD(login_apr_viajante)
       LET ma_resp_apr_viaj[ma_curr].login_apr_viajante = cap343_popup_usuario_cap(TRUE)
       CURRENT WINDOW IS w_cdv2016
       DISPLAY ma_resp_apr_viaj[ma_curr].login_apr_viajante TO sr_resp_apr_viaj[m_scr_curr].login_apr_viajante

    WHEN INFIELD(login_resp_adm)
       LET mr_resp_adm.login_resp_adm = cap343_popup_usuario_cap(TRUE)
       CURRENT WINDOW IS w_cdv2016
       DISPLAY mr_resp_adm.login_resp_adm TO login_resp_adm

 END CASE

 END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2016_verifica_empresa(l_cod_empresa)
#-----------------------------------------------#
 DEFINE l_cod_empresa LIKE empresa.cod_empresa

 WHENEVER ERROR CONTINUE
    SELECT 1
     FROM empresa
     WHERE cod_empresa = l_cod_empresa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","empresa")
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------------------#
 FUNCTION cdv2016_verifica_login(l_login)
#---------------------------------------#
 DEFINE l_login  CHAR(30),
        l_nom_funcionario  CHAR(30)

 LET l_nom_funcionario = cdv2016_busca_nom_usuario(l_login)
 IF l_nom_funcionario IS NULL OR l_nom_funcionario = " " THEN
    RETURN FALSE
 ELSE
    IF INFIELD(login_resp_adm) THEN
       LET mr_resp_adm.nom_resp_adm = l_nom_funcionario
    END IF
    IF INFIELD(login_apr_viajante) THEN
       IF ma_resp_apr_viaj[ma_curr].aprov_viajante = "VIAJANTE" THEN
          WHENEVER ERROR CONTINUE
             SELECT 1
              FROM cdv_info_viajante
              WHERE usuario_logix = l_login
               AND empresa=p_cod_empresa
          WHENEVER ERROR STOP
          IF sqlca.sqlcode = 100 THEN
             CALL log0030_mensagem(" Aprovante/Viajante não cadastrado na tabela de viajantes. " ,"exclamation")
             RETURN FALSE
          END IF
       END IF
       LET ma_resp_apr_viaj[ma_curr].nom_aprov_viajante = l_nom_funcionario
    END IF

    RETURN TRUE
 END IF

 END FUNCTION

#------------------------------------------------#
 FUNCTION cdv2016_busca_nom_usuario(l_cod_usuario)
#------------------------------------------------#
 DEFINE l_cod_usuario  LIKE usuarios.cod_usuario,
        l_nom_usuario  LIKE usuarios.nom_funcionario

 WHENEVER ERROR CONTINUE
    SELECT nom_funcionario
           INTO l_nom_usuario
     FROM usuarios
     WHERE cod_usuario = l_cod_usuario
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("SELECT","usuario")
    RETURN " "
 END IF

 RETURN l_nom_usuario

 END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2016_valida_aprovante_viajante(l_aprov_viaj)
#-------------------------------------------------------#
 DEFINE l_aprov_viaj   CHAR(09)

 CASE l_aprov_viaj
    WHEN "APROVANTE"
       RETURN TRUE
    WHEN "VIAJANTE"
       RETURN TRUE
    OTHERWISE RETURN FALSE
 END CASE

 END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2016_verifica_dupl_resp_adm(l_login)
#-----------------------------------------------#
 DEFINE l_login   LIKE usuarios.cod_usuario

 WHENEVER ERROR CONTINUE
    SELECT 1
     FROM cdv_resp_apr_viaj_1125
     WHERE login_resp_adm = l_login
      AND empresa=p_cod_empresa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 OR sqlca.sqlcode = -284 THEN
    CALL log0030_mensagem("Responsável administrativo já cadastrado","exclamation")
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv2016_verifica_dupl_aprov_viaj(l_login)
#-------------------------------------------------#
 DEFINE l_login      LIKE usuarios.cod_usuario,
        l_ct_aux            SMALLINT,
        l_aprov_viaj        CHAR(09),
        l_msg               CHAR(300)

 FOR l_ct_aux = 1 TO m_cont #verifica se está no array
     IF ma_resp_apr_viaj[l_ct_aux].login_apr_viajante IS NULL THEN
        EXIT FOR
     END IF
     IF l_ct_aux <> ma_curr AND  ma_resp_apr_viaj[l_ct_aux].login_apr_viajante = l_login THEN
        LET l_msg = " Login já cadastrado . "
        CALL log0030_mensagem(l_msg,"exclamation")
        ERROR " Login já cadastrado. "
        RETURN TRUE
     END IF
 END FOR

 WHENEVER ERROR CONTINUE #verificar se existe na tabela com outro responsável administrativo
    SELECT 1
     FROM cdv_resp_apr_viaj_1125
     WHERE login_apr_viajante = l_login
     AND login_resp_adm <> mr_resp_adm.login_resp_adm
     AND empresa = p_cod_empresa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    LET l_msg = " Login já cadastrado para outro responsável administrativo. "
    CALL log0030_mensagem(l_msg,"exclamation")
    ERROR " Login já cadastrado. "
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#-----------------------------#
 FUNCTION cdv2016_lista_dados()
#-----------------------------#
  DEFINE l_msg                CHAR(100),
         lr_dados             RECORD LIKE cdv_resp_apr_viaj_1125.*,
         l_comand_rel         CHAR(150)




  IF log0280_saida_relat(20,40) IS NOT NULL THEN

     MESSAGE " Processando a extração do relatório ... " ATTRIBUTE(REVERSE)
     SLEEP 1

     IF g_ies_ambiente = "W" THEN
        IF p_ies_impressao = "S" THEN
           CALL log150_procura_caminho("LST") RETURNING l_comand_rel
           LET l_comand_rel = l_comand_rel CLIPPED, "cdv2016.tmp"
           START REPORT cdv2016_relat TO l_comand_rel
        ELSE
           START REPORT cdv2016_relat TO p_nom_arquivo
        END IF
     ELSE
        IF p_ies_impressao = "S" THEN
           START REPORT cdv2016_relat TO PIPE p_nom_arquivo
        ELSE
           START REPORT cdv2016_relat TO p_nom_arquivo
        END IF
     END IF

     WHENEVER ERROR CONTINUE
      DECLARE cq_lista CURSOR FOR
       SELECT *
         FROM cdv_resp_apr_viaj_1125
        WHERE empresa   = p_cod_empresa
        ORDER BY login_apr_viajante
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE","cq_lista")
        RETURN
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_lista INTO lr_dados.*
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("FOREACH","cq_lista")
        RETURN
     END IF
        OUTPUT TO REPORT cdv2016_relat(lr_dados.*)
     END FOREACH

     FINISH REPORT cdv2016_relat

     IF g_ies_ambiente = "W" AND p_ies_impressao = "S"  THEN
         LET l_comand_rel = "lpdos.bat ",l_comand_rel CLIPPED," ",p_nom_arquivo CLIPPED
         RUN l_comand_rel
     END IF

     MESSAGE " "

     IF p_ies_impressao = "S" THEN
        CALL log0030_mensagem("Relatorio impresso com sucesso.","info")
     ELSE
        LET l_msg = "Relatorio gravado no arquivo ",p_nom_arquivo CLIPPED ,"."
        CALL log0030_mensagem(l_msg,"info")
     END IF

  ELSE
     CALL log0030_mensagem("Listagem Cancelada.","info")
  END IF

END FUNCTION

#------------------------------------------------#
 FUNCTION cdv2016_busca_eh_aprov_viajante(l_login)
#------------------------------------------------#
 DEFINE l_login       LIKE usuarios.cod_usuario,
        l_retorno     CHAR(10)

 LET l_retorno = 'N' #variável que diz se login é de aprovante ou viajante

 WHENEVER ERROR CONTINUE
    SELECT 1
     FROM cdv_info_viajante
     WHERE usuario_logix = l_login
     AND empresa = p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 100 THEN
    CALL log0030_mensagem("Login não cadastrado como viajante.","info")
    RETURN NULL
 END IF
 IF sqlca.sqlcode = 0 OR sqlca.sqlcode=-284 THEN
    LET l_retorno = 'V'
 END IF

 WHENEVER ERROR CONTINUE
    SELECT 1
     FROM usu_nivel_aut_cap
     WHERE cod_usuario = l_login
      AND ies_versao_atual = "S"
      AND ies_ativo="S"
      AND cod_empresa=p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 OR sqlca.sqlcode=-284 THEN
    LET l_retorno = 'A'
 END IF

 IF l_retorno = 'A' THEN
    LET l_retorno = 'APROVANTE'
 END IF
 IF l_retorno = 'V' THEN
    LET l_retorno = 'VIAJANTE'
 END IF

 IF l_retorno = 'N' THEN
    RETURN NULL
 ELSE
    RETURN l_retorno
 END IF

 END FUNCTION

#-----------------------------#
 REPORT cdv2016_relat(lr_dados)
#-----------------------------#
  DEFINE lr_dados            RECORD LIKE cdv_resp_apr_viaj_1125.*,
         l_last_row          SMALLINT,
         l_nom_resp_adm      LIKE usuarios.nom_funcionario,
         l_nom_aprov_viaj    LIKE usuarios.nom_funcionario,
         l_status            SMALLINT,
         l_msg               CHAR(100),
         l_aprov_viajante    CHAR(10)

  OUTPUT LEFT MARGIN 0
         TOP MARGIN 0
         BOTTOM MARGIN 1

{
CDV2016

          RESPONSÁVEL ADMINISTRATIVO VIAJANTE/APROVANTE                                      FL.       1
          ---------------------------------------------          EXTRAIDO EM 15/09/2011 AS 09:29:51 HRS.
                                                                                   PELO USUARIO admlog
01-TIMAC AGRO IND.COM.FERT.LTDA

 LOGIN      APROV/VIAJANTE  NOME                             LOGIN RESP. NOME RESPONSAVEL ADMINISTRATIVO
 ---------  --------------  ------------------------------   ----------  --------------------------------
* * * ULTIMA FOLHA * * *
}

  FORMAT

    PAGE HEADER
      PRINT log5211_retorna_configuracao(PAGENO,66,100) CLIPPED;
      IF logm2_empresa_leitura(p_cod_empresa,TRUE,TRUE) THEN
         PRINT logm2_empresa_get_den_empresa()
      ELSE
         PRINT "EMPRESA NÃO CADASTRADA"
      END IF

      PRINT COLUMN 001, "CDV2016"
      PRINT COLUMN 001, ""
      PRINT COLUMN 001, "          RESPONSÁVEL ADMINISTRATIVO VIAJANTE/APROVANTE                                      FL.    ", PAGENO USING "###&"
      PRINT COLUMN 001, "          ---------------------------------------------          EXTRAIDO EM ", TODAY," AS ", TIME, " HRS."
      PRINT COLUMN 001, "                                                                                   PELO USUARIO admlog"

      SKIP 1 LINE

      PRINT COLUMN 001, " LOGIN      APROV/VIAJANTE  NOME                             LOGIN RESP. NOME RESPONSAVEL ADMINISTRATIVO"
      PRINT COLUMN 001, " ---------  --------------  ------------------------------   ----------  --------------------------------"

    ON EVERY ROW
       CASE lr_dados.eh_apr_viajante
          WHEN 'A'  LET l_aprov_viajante = "APROVANTE"
          WHEN 'V'  LET l_aprov_viajante = "VIAJANTE"
       END CASE
       LET l_nom_aprov_viaj = cdv2016_busca_nom_usuario(lr_dados.login_apr_viajante)
       LET l_nom_resp_adm = cdv2016_busca_nom_usuario(lr_dados.login_resp_adm)
       PRINT COLUMN 002, lr_dados.login_apr_viajante,
             COLUMN 013, l_aprov_viajante,
             COLUMN 029, l_nom_aprov_viaj,
             COLUMN 062, lr_dados.login_resp_adm,
             COLUMN 074, l_nom_resp_adm

    ON LAST ROW
      LET l_last_row = TRUE

    PAGE TRAILER
      IF l_last_row = TRUE THEN
         PRINT "* * * ULTIMA FOLHA * * *",
               log5211_termino_impressao() CLIPPED
      ELSE
         PRINT " "
      END IF

END REPORT

#------------------------------------#
 FUNCTION cdv_2016_exibe_item_array()
#------------------------------------#
 DEFINE l_scr_line          SMALLINT

 LET l_scr_line = SCR_LINE()

 DISPLAY ma_resp_apr_viaj[ma_curr].* TO sr_resp_apr_viaj[l_scr_line].*

 END FUNCTION
#------------------------------#
 FUNCTION cdv2016_version_info()
#------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2016.4gl $|$Revision: 23 $|$Date: 23/12/11 12:23 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION