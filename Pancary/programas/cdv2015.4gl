###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE VIAGENS                                   #
# PROGRAMA: cdv2015                                               #
# OBJETIVO: MANUTENÇÃO DA cdv_par_padrao - Unidade Funcional x AEN#
# AUTOR...: ALINE FRANCINI LUIZ                                   #
# DATA....: 23/05/2005                                            #
#-----------------------------------------------------------------#
 DATABASE logix

 GLOBALS
     DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
            p_user                 LIKE usuario.nom_usuario,
            p_status               SMALLINT

     DEFINE p_ies_impressao        CHAR(001),
            g_ies_ambiente         CHAR(001),
            p_nom_arquivo          CHAR(100),
            p_nom_arquivo_back     CHAR(100)

     DEFINE g_ies_grafico          SMALLINT

     DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
 END GLOBALS

#MODULARES
     DEFINE m_den_empresa          LIKE empresa.den_empresa

     DEFINE m_consulta_ativa       SMALLINT

     DEFINE sql_stmt               CHAR(800),
            where_clause           CHAR(400)

     DEFINE m_comando              CHAR(080),
            m_last_row             SMALLINT

     DEFINE m_caminho              CHAR(150)

     DEFINE mr_cdv_par_padrao  RECORD
            parametro           CHAR(10),
            parametro_numerico  DECIMAL(2,0)
     END RECORD

     DEFINE mr_cdv_par_padraor RECORD
            parametro           CHAR(10),
            parametro_numerico  DECIMAL(2,0)
     END RECORD

     DEFINE m_den_estr_linprod     LIKE linha_prod.den_estr_linprod,
            m_den_uni_funcio       LIKE unidade_funcional.den_uni_funcio,
            m_empresa_atendida_pamcary LIKE empresa.cod_empresa

#END MODULARES

 MAIN

     CALL log0180_conecta_usuario()

     LET p_versao = "CDV2015-10.02.00p" #Favor nao alterar esta linha (SUPORTE)

     WHENEVER ERROR CONTINUE

     CALL log1400_isolation()
     SET LOCK MODE TO WAIT 120

     WHENEVER ERROR STOP

     DEFER INTERRUPT

     LET m_caminho = log140_procura_caminho('cdv2015.iem')

     OPTIONS
         FIELD ORDER UNCONSTRAINED,
         HELP    FILE m_caminho,
         PREVIOUS KEY control-b,
         NEXT     KEY control-f


     CALL log001_acessa_usuario("CDV","LOGERP")
          RETURNING p_status, p_cod_empresa, p_user

     IF p_status = 0 THEN
         CALL cdv2015_controle()
     END IF
 END MAIN

#---------------------------#
 FUNCTION cdv2015_controle()
#---------------------------#
     CALL log006_exibe_teclas('01', p_versao)

     CALL cdv2015_inicia_variaveis()

     LET m_caminho = log1300_procura_caminho('cdv2015','')
     OPEN WINDOW w_cdv2015 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

     DISPLAY p_cod_empresa TO cod_empresa
     MENU 'OPÇÃO'
         COMMAND 'Incluir'   'Inclui um novo registro.'
             HELP 001
             MESSAGE ''
             IF log005_seguranca(p_user, 'CDV', 'cdv2015', 'IN') THEN
                 CALL cdv2015_inclusao_unidade_funcional_viajante()
             END IF

         COMMAND 'Modificar' 'Modifica um registro existente.'
             HELP 002
             MESSAGE ''
             IF m_consulta_ativa THEN
                 IF log005_seguranca(p_user, 'CDV', 'cdv2015', 'MO') THEN
                     CALL cdv2015_modificacao_unidade_funcional_viajante()
                 END IF
             ELSE
                 CALL log0030_mensagem('Consulte previamente para fazer a modificação.','exclamation')
             END IF

         COMMAND 'Excluir'   'Exclui um registro existente.'
             HELP 003
             MESSAGE ''
             IF m_consulta_ativa THEN
                 IF log005_seguranca(p_user, 'CDV', 'cdv2015', 'EX') THEN
                     CALL cdv2015_exclusao_unidade_funcional_viajante()
                 END IF
             ELSE
                 CALL log0030_mensagem('Consulte previamente para fazer a exclusão.','exclamation')
             END IF

         COMMAND 'Consultar' 'Consulta registro.'
             HELP 004
             MESSAGE ''
             IF log005_seguranca(p_user, 'CDV' , 'cdv2015', 'CO') THEN
                 CALL cdv2015_consulta_unidade_funcional_viajante()
             END IF

         COMMAND 'Seguinte'  'Exibe o próximo item encontrado na pesquisa.'
             HELP 005
             MESSAGE ''
             IF m_consulta_ativa THEN
                 CALL cdv2015_paginacao('SEGUINTE')
             ELSE
                 CALL log0030_mensagem('Não existe nenhuma consulta ativa.','exclamation')
             END IF

         COMMAND 'Anterior'  'Exibe o item anterior encontrado na pesquisa.'
             HELP 006
             MESSAGE ''
             IF m_consulta_ativa THEN
                 CALL cdv2015_paginacao('ANTERIOR')
             ELSE
                 CALL log0030_mensagem('Não existe nenhuma consulta ativa.','exclamation')
             END IF

         COMMAND 'Listar'    'Lista os dados da tabela.'
             HELP 007
             MESSAGE ''
             IF log005_seguranca(p_user, 'CDV', 'cdv2015', 'CO') THEN
                 IF log0280_saida_relat(16,30) IS NOT NULL THEN
                     CALL cdv2015_lista_unidade_funcional_viajante()
                 END IF
             END IF

         COMMAND KEY ("!")
             PROMPT "Digite o comando : " FOR m_comando
             RUN m_comando
             PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

         COMMAND 'Fim'       'Retorna ao menu anterior.'
             HELP 008
             EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

     END MENU

     CLOSE WINDOW w_cdv2015
 END FUNCTION

#-----------------------------------#
 FUNCTION cdv2015_inicia_variaveis()
#-----------------------------------#
     LET m_consulta_ativa           = FALSE

     INITIALIZE mr_cdv_par_padrao.*  TO NULL
     INITIALIZE mr_cdv_par_padrao.* TO NULL
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2015_inclusao_unidade_funcional_viajante()
#-------------------------------------------------------#
     LET mr_cdv_par_padraor.*         = mr_cdv_par_padrao.*

     INITIALIZE mr_cdv_par_padrao.* TO NULL

     CLEAR FORM

     IF cdv2015_entrada_dados('INCLUSAO') THEN
         WHENEVER ERROR CONTINUE
         INSERT INTO cdv_par_padrao VALUES (p_cod_empresa,
                                            mr_cdv_par_padrao.parametro,
                                            'UNIDADE FUNCIONAL X LINHA NEGÓCIO',
                                            '',
                                            '',
                                            '',
                                            mr_cdv_par_padrao.parametro_numerico,
                                            '')
         WHENEVER ERROR STOP

         IF sqlca.sqlcode = 0 THEN
             MESSAGE 'Inclusão efetuada com sucesso.'
                 ATTRIBUTE(REVERSE)
         ELSE
             CALL log003_err_sql('INCLUSAO','cdv_par_padrao')
         END IF
     ELSE
         LET mr_cdv_par_padrao.*     = mr_cdv_par_padraor.*

         CALL cdv2015_exibe_dados()

         CALL log0030_mensagem('Inclusão cancelada.','exclamatio')
     END IF
 END FUNCTION

#----------------------------------------#
 FUNCTION cdv2015_entrada_dados(l_funcao)
#----------------------------------------#
     DEFINE l_funcao              CHAR(015)

     IF l_funcao = 'INCLUSAO' THEN
         CALL log006_exibe_teclas('01 02 03 07', p_versao)
     ELSE
         CALL log006_exibe_teclas('01 02 07', p_versao)
     END IF

     CURRENT WINDOW IS w_cdv2015

     LET int_flag = FALSE

     DISPLAY p_cod_empresa TO cod_empresa

     INPUT BY NAME mr_cdv_par_padrao.* WITHOUT DEFAULTS

         BEFORE FIELD parametro
             IF l_funcao = 'MODIFICACAO' THEN
                 NEXT FIELD parametro_numerico
             END IF
           IF g_ies_grafico THEN
               --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
               CURRENT WINDOW IS w_cdv2015
           ELSE
               DISPLAY '( Zoom )' AT 3,68
               CURRENT WINDOW IS w_cdv2015
           END IF

          AFTER FIELD parametro
             IF mr_cdv_par_padrao.parametro IS NOT NULL THEN
                 IF NOT cdv2015_verifica_unidade_funcional() THEN
                    NEXT FIELD parametro
                 END IF
             END IF

         BEFORE FIELD parametro_numerico
           IF g_ies_grafico THEN
               --# CALL fgl_dialog_setkeylabel('control-z', '')
               CURRENT WINDOW IS w_cdv2015
           ELSE
               DISPLAY '--------' AT 3,68
               CURRENT WINDOW IS w_cdv2015
           END IF

           AFTER FIELD parametro_numerico
              IF NOT cdv2015_den_linha_negocio() THEN
                 DISPLAY m_den_estr_linprod TO den_estr_linprod
                 CALL log0030_mensagem('Linha negócio não cadastrada.','info')
                 NEXT FIELD parametro_numerico
              END IF

              DISPLAY m_den_estr_linprod TO den_estr_linprod

          ON KEY (control-w,f1)
             #lds IF NOT LOG_logix_versao5() THEN
             #lds CONTINUE INPUT
             #lds END IF
             CALL cdv2015_help()

          ON KEY (control-z, f4)
             CALL cdv2015_popup()

          AFTER INPUT
             IF NOT int_flag THEN
                IF mr_cdv_par_padrao.parametro IS NULL THEN
                   CALL log0030_mensagem('Unidade funcional não informada.','exclamation')
                   NEXT FIELD parametro
                END IF
                IF l_funcao = 'INCLUSAO' THEN
                   IF NOT cdv2015_verifica_unidade_funcional() THEN
                      NEXT FIELD parametro
                   END IF
                END IF
                IF mr_cdv_par_padrao.parametro_numerico IS NULL THEN
                   CALL log0030_mensagem('Linha negócio não informada.','exclamation')
                   NEXT FIELD parametro_numerico
                ELSE
                   IF NOT cdv2015_den_linha_negocio() THEN
                      NEXT FIELD parametro_numerico
                   END IF
                END IF
             END IF
     END INPUT

    IF g_ies_grafico THEN
    ELSE
        DISPLAY '--------' AT 3,68
        CURRENT WINDOW IS w_cdv2015
    END IF

     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_cdv2015

     IF int_flag THEN
         LET int_flag = FALSE

         RETURN FALSE
     ELSE
         RETURN TRUE
     END IF
 END FUNCTION


#-------------------------------------------------------#
 FUNCTION cdv2015_verifica_unidade_funcional()
#-------------------------------------------------------#

   IF NOT cdv2015_den_unidade_funcional() THEN
      CALL log0030_mensagem('Unidade funcional não cadastrada.','exclamation')
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   SELECT parametro
     FROM cdv_par_padrao
    WHERE empresa = p_cod_empresa
      AND parametro[1,10] = mr_cdv_par_padrao.parametro
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      CALL log0030_mensagem('Relacionamento já cadastrado para esta unidade funcional.','exclamation')
      RETURN FALSE
   END IF

   DISPLAY m_den_uni_funcio TO den_uni_funcio
   RETURN TRUE

 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2015_den_unidade_funcional()
#-----------------------------------------#

    WHENEVER ERROR CONTINUE
     SELECT den_uni_funcio
       INTO m_den_uni_funcio
       FROM unidade_funcional
      WHERE cod_empresa    = p_cod_empresa
        AND cod_uni_funcio = mr_cdv_par_padrao.parametro
        AND dat_validade_fim > TODAY
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      INITIALIZE m_den_uni_funcio TO NULL
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
#---------------------------------------------------#
 FUNCTION cdv2015_busca_empresa_atendida_pamcary()
#---------------------------------------------------#
   DEFINE l_status SMALLINT

   CALL log2250_busca_parametro(p_cod_empresa,'empresa_atendida_pamcary')
      RETURNING m_empresa_atendida_pamcary, l_status
   IF NOT l_status OR m_empresa_atendida_pamcary IS NULL THEN
      CALL log0030_mensagem('Primeiro nível empresa atendida não cadastrado.','exclamation')
   END IF

END FUNCTION

#-------------------------------------#
 FUNCTION cdv2015_den_linha_negocio()
#-------------------------------------#
   DEFINE l_empresa_atendida_pamcary LIKE empresa.cod_empresa

   CALL cdv2015_busca_empresa_atendida_pamcary()

   WHENEVER ERROR CONTINUE
    SELECT linha_prod.den_estr_linprod
      INTO m_den_estr_linprod
      FROM linha_prod
     WHERE linha_prod.cod_lin_prod  = m_empresa_atendida_pamcary
       AND linha_prod.cod_lin_recei = mr_cdv_par_padrao.parametro_numerico
       AND linha_prod.cod_seg_merc  = 0
       AND linha_prod.cod_cla_uso   = 0
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      INITIALIZE m_den_estr_linprod TO NULL
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------#
 FUNCTION cdv2015_help()
#------------------------#
     CASE
         WHEN INFIELD(parametro)       CALL showhelp(101)
         WHEN INFIELD(parametro_numerico) CALL showhelp(102)
     END CASE
 END FUNCTION

#------------------------#
 FUNCTION cdv2015_popup()
#------------------------#
     DEFINE l_unidade_funcional  LIKE cdv_par_padrao.parametro,
            l_linha_negocio      DECIMAL(2,0),
            l_den_linprod        CHAR(30)

     DEFINE l_condicao            CHAR(300)

     LET l_condicao = NULL

     CASE
         WHEN infield(parametro)
           LET l_unidade_funcional = rhu053_popup_uni_funcional(p_cod_empresa)
           CURRENT WINDOW IS w_cdv2015
           IF l_unidade_funcional IS NOT NULL THEN
              LET mr_cdv_par_padrao.parametro = l_unidade_funcional
              DISPLAY mr_cdv_par_padrao.parametro TO parametro
           END IF

        WHEN infield(parametro_numerico)
           CALL cdv2015_busca_empresa_atendida_pamcary()
           CALL cdv2015_linha_produto(2, m_empresa_atendida_pamcary, 0, 0, 0)
             RETURNING l_linha_negocio, l_den_linprod
           IF l_linha_negocio IS NOT NULL THEN
              LET mr_cdv_par_padrao.parametro_numerico = l_linha_negocio
              LET m_den_estr_linprod = l_den_linprod
              DISPLAY mr_cdv_par_padrao.parametro_numerico TO parametro_numerico
              DISPLAY m_den_estr_linprod TO den_estr_linprod
           END IF
     END CASE

     CALL log006_exibe_teclas('01 02 03 07', p_versao)
     CURRENT WINDOW IS w_cdv2015
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2015_bloqueia_unidade_funcional_viajante()
#-------------------------------------------------------#
  WHENEVER ERROR CONTINUE
     DECLARE cm_unidade_funcional_viajante CURSOR FOR
      SELECT parametro, parametro_numerico
        FROM cdv_par_padrao
       WHERE empresa = p_cod_empresa
         AND parametro = mr_cdv_par_padrao.parametro

  FOR UPDATE
  WHENEVER ERROR STOP
     CALL log085_transacao("BEGIN")

     WHENEVER ERROR CONTINUE
     OPEN  cm_unidade_funcional_viajante
     WHENEVER ERROR STOP

     IF SQLCA.sqlcode = 0 THEN
         WHENEVER ERROR CONTINUE
         FETCH cm_unidade_funcional_viajante INTO mr_cdv_par_padrao.*
         WHENEVER ERROR STOP

         CASE
             WHEN sqlca.sqlcode = 0
                 RETURN TRUE

             WHEN sqlca.sqlcode = NOTFOUND
                 CALL log0030_mensagem('Registro não mais existe na tabela.\nExecute a consulta  novamente. ', 'exclamation')

             OTHERWISE
                 CALL log003_err_sql('LEITURA','cdv_par_padrao')
         END CASE

         WHENEVER ERROR CONTINUE
         CLOSE cm_unidade_funcional_viajante
         FREE  cm_unidade_funcional_viajante
         WHENEVER ERROR STOP
     ELSE
         CALL log003_err_sql('LEITURA','cdv_par_padrao')
     END IF

     CALL log085_transacao("ROLLBACK")

     RETURN FALSE
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2015_modificacao_unidade_funcional_viajante()
#-------------------------------------------------------#
     LET mr_cdv_par_padraor.* = mr_cdv_par_padrao.*

     IF cdv2015_bloqueia_unidade_funcional_viajante() THEN
         CALL cdv2015_exibe_dados()

         IF cdv2015_entrada_dados('MODIFICACAO') THEN
             WHENEVER ERROR CONTINUE
             UPDATE cdv_par_padrao
                SET cdv_par_padrao.parametro = mr_cdv_par_padrao.parametro,
                    cdv_par_padrao.parametro_numerico = mr_cdv_par_padrao.parametro_numerico
              WHERE CURRENT OF cm_unidade_funcional_viajante
             WHENEVER ERROR STOP

             IF sqlca.sqlcode = 0 THEN
                 CLOSE cm_unidade_funcional_viajante

                 CALL log085_transacao("COMMIT")

                 MESSAGE ' Modificacao efetuada com sucesso. '
                     ATTRIBUTE(REVERSE)
             ELSE
                 CALL log003_err_sql('MODIFICACAO','cdv_par_padrao')

                 CLOSE cm_unidade_funcional_viajante

                 CALL log085_transacao("ROLLBACK")

                 LET mr_cdv_par_padrao.* = mr_cdv_par_padraor.*

                 CALL cdv2015_exibe_dados()
             END IF
         ELSE
             CLOSE cm_unidade_funcional_viajante

             CALL log085_transacao("ROLLBACK")

             LET mr_cdv_par_padrao.* = mr_cdv_par_padraor.*

             CALL cdv2015_exibe_dados()

             CALL log0030_mensagem('Modificação cancelada.','exclamation')
         END IF
     END IF
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2015_exclusao_unidade_funcional_viajante()
#-------------------------------------------------------#
     IF cdv2015_bloqueia_unidade_funcional_viajante() THEN
         CALL cdv2015_exibe_dados()

         IF NOT cdv2015_verifica_info_viajante() THEN
            IF log004_confirm(17,45)  THEN
                WHENEVER ERROR CONTINUE
                DELETE FROM cdv_par_padrao
                 WHERE CURRENT OF cm_unidade_funcional_viajante
                WHENEVER ERROR STOP

                IF sqlca.sqlcode = 0 THEN
                    CLOSE cm_unidade_funcional_viajante

                    CALL log085_transacao("COMMIT")

                    MESSAGE 'Exclusão efetuada com sucesso.'
                        ATTRIBUTE(REVERSE)

                    INITIALIZE mr_cdv_par_padrao.* TO NULL

                    CALL cdv2015_exibe_dados()
                ELSE
                    CALL log003_err_sql('EXCLUSAO','cdv_par_padrao')

                    CLOSE cm_unidade_funcional_viajante

                    CALL log085_transacao("ROLLBACK")
                END IF
            ELSE
                CLOSE cm_unidade_funcional_viajante

                CALL log085_transacao("ROLLBACK")

                CALL log0030_mensagem('Exclusão cancelada.','exclamation')
            END IF
         ELSE
            CLOSE cm_unidade_funcional_viajante

            CALL log085_transacao("ROLLBACK")

            CALL log0030_mensagem('Este registro está sendo utilizado pelo sistema, não pode ser excluído.','exclamation')
         END IF
     END IF
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2015_consulta_unidade_funcional_viajante()
#-------------------------------------------------------#
     CALL log006_exibe_teclas('01 02 07 08', p_versao)
     CURRENT WINDOW IS w_cdv2015

     LET where_clause       =  NULL

     CLEAR FORM

     DISPLAY p_cod_empresa TO cod_empresa

     LET int_flag           = FALSE

     CONSTRUCT BY NAME where_clause ON cdv_par_padrao.parametro,
                                       cdv_par_padrao.parametro_numerico
         BEFORE FIELD parametro
     	    IF g_ies_grafico THEN
               --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
               CURRENT WINDOW IS w_cdv2015
           ELSE
               DISPLAY '( Zoom )' AT 3,68
               CURRENT WINDOW IS w_cdv2015
           END IF

          AFTER FIELD parametro
     	    IF g_ies_grafico THEN
               --# CALL fgl_dialog_setkeylabel('control-z', null)
               CURRENT WINDOW IS w_cdv2015
           ELSE
               DISPLAY '--------' AT 3,68
               CURRENT WINDOW IS w_cdv2015
           END IF

          ON KEY (control-w,f1)
             #lds IF NOT LOG_logix_versao5() THEN
             #lds CONTINUE CONSTRUCT
             #lds END IF
             CALL cdv2015_help()

          ON KEY (control-z, f4)
             CALL cdv2015_popup()
     END CONSTRUCT

     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_cdv2015

     IF int_flag THEN
         LET int_flag         = FALSE

         CALL log0030_mensagem('Consulta cancelada.','exclamation')
     ELSE
         CALL cdv2015_prepara_consulta()
     END IF

     CALL cdv2015_exibe_dados()

     CALL log006_exibe_teclas('01 09', p_versao)
     CURRENT WINDOW IS w_cdv2015
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2015_prepara_consulta()
#-------------------------------------------------------#
     LET sql_stmt = "SELECT parametro, parametro_numerico ",
                    " FROM cdv_par_padrao ",
                    " WHERE empresa = '", p_cod_empresa, "' ",
                    "   AND des_parametro = 'UNIDADE FUNCIONAL X LINHA NEGÓCIO'",
                    "   AND ", where_clause CLIPPED,
                 " ORDER BY parametro"

     WHENEVER ERROR CONTINUE
     PREPARE var_query FROM sql_stmt
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DECLARE cq_unidade_funcional_viajante SCROLL CURSOR WITH HOLD FOR var_query
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     OPEN  cq_unidade_funcional_viajante
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     FETCH cq_unidade_funcional_viajante INTO mr_cdv_par_padrao.*
     WHENEVER ERROR STOP

     IF sqlca.sqlcode = 0 THEN
         MESSAGE 'Consulta efetuada com sucesso.'
             ATTRIBUTE (REVERSE)

         LET m_consulta_ativa = TRUE
     ELSE
         LET m_consulta_ativa = FALSE

         CALL log0030_mensagem('Argumentos de pesquisa não encontrados. ','info')
     END IF
 END FUNCTION

#------------------------------------#
 FUNCTION cdv2015_paginacao(l_funcao)
#------------------------------------#
     DEFINE l_funcao            CHAR(010)

     LET mr_cdv_par_padraor.* = mr_cdv_par_padrao.*

     WHILE TRUE
         WHENEVER ERROR CONTINUE
         IF l_funcao = 'SEGUINTE' THEN
             FETCH NEXT     cq_unidade_funcional_viajante INTO mr_cdv_par_padrao.*
         ELSE
             FETCH PREVIOUS cq_unidade_funcional_viajante INTO mr_cdv_par_padrao.*
         END IF
         WHENEVER ERROR STOP

         IF sqlca.sqlcode = 0 THEN
             WHENEVER ERROR CONTINUE
             SELECT parametro, parametro_numerico
               INTO mr_cdv_par_padrao.*
               FROM cdv_par_padrao
              WHERE empresa = p_cod_empresa
                AND parametro = mr_cdv_par_padrao.parametro
             WHENEVER ERROR STOP
             IF SQLCA.sqlcode = 0 THEN
                 LET mr_cdv_par_padraor.* = mr_cdv_par_padrao.*

                 EXIT WHILE
             END IF
         ELSE
             CALL log0030_mensagem('Não existem mais itens nesta direção.','exclamation')
             LET mr_cdv_par_padrao.* = mr_cdv_par_padraor.*
             EXIT WHILE
         END IF
     END WHILE

     CALL cdv2015_exibe_dados()
 END FUNCTION

#------------------------------#
 FUNCTION cdv2015_exibe_dados()
#------------------------------#
     DEFINE l_status              SMALLINT

     DISPLAY BY NAME mr_cdv_par_padrao.*

     CALL cdv2015_den_linha_negocio()
       RETURNING l_status

     CALL cdv2015_den_unidade_funcional()
       RETURNING l_status

     DISPLAY m_den_uni_funcio TO den_uni_funcio
     DISPLAY m_den_estr_linprod TO den_estr_linprod

 END FUNCTION
#------------------------------------------#
 FUNCTION cdv2015_verifica_info_viajante()
#------------------------------------------#
 DEFINE l_count SMALLINT

 WHENEVER ERROR CONTINUE
 SELECT COUNT(*)
   INTO l_count
   FROM cdv_par_viajante
  WHERE parametro = 'unidade_funcional_viajante'
   AND  parametro = mr_cdv_par_padrao.parametro
 WHENEVER ERROR STOP
 IF SQLCA.SQLCODE <> 0 THEN
    RETURN FALSE
 ELSE
    IF l_count = 0 THEN
       RETURN FALSE
    END IF
 END IF


   RETURN TRUE

 END FUNCTION
#-------------------------------------------------------#
 FUNCTION cdv2015_lista_unidade_funcional_viajante()
#-------------------------------------------------------#
    DEFINE l_status SMALLINT

    DEFINE l_mensagem             CHAR(100)

    MESSAGE ' Processando a extração do relatório ... ' ATTRIBUTE(REVERSE)

    IF p_ies_impressao = 'S' THEN
        IF g_ies_ambiente = 'U' THEN
            START REPORT cdv2015_relat TO PIPE p_nom_arquivo
        ELSE
            CALL log150_procura_caminho('LST') RETURNING m_caminho
            LET m_caminho = m_caminho CLIPPED, 'cdv2015.tmp'
            START REPORT cdv2015_relat TO m_caminho
        END IF
    ELSE
        START REPORT cdv2015_relat TO p_nom_arquivo
    END IF


    WHENEVER ERROR CONTINUE
    SELECT den_empresa
      INTO m_den_empresa
      FROM empresa
     WHERE cod_empresa = p_cod_empresa
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('LEITURA','EMPRESA')
    END IF

    WHENEVER ERROR CONTINUE
    DECLARE cl_unidade_funcional_viajante CURSOR FOR
     SELECT parametro, parametro_numerico
       INTO mr_cdv_par_padrao.*
       FROM cdv_par_padrao
      WHERE empresa = p_cod_empresa
       AND des_parametro = "UNIDADE FUNCIONAL X LINHA NEGÓCIO"
      ORDER BY cdv_par_padrao.parametro
    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('DECLARE','cl_unidade_funcional_viajante')
    END IF
    OPEN  cl_unidade_funcional_viajante
    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('OPEN','cl_unidade_funcional_viajante')
    END IF
    FETCH cl_unidade_funcional_viajante INTO mr_cdv_par_padrao.*

    IF sqlca.sqlcode = 0 THEN
        WHILE sqlca.sqlcode = 0
            CALL cdv2015_den_linha_negocio()
               RETURNING l_status

            CALL cdv2015_den_unidade_funcional()
               RETURNING l_status
            OUTPUT TO REPORT cdv2015_relat(mr_cdv_par_padrao.*)
            FETCH cl_unidade_funcional_viajante INTO mr_cdv_par_padrao.*
        END WHILE
    ELSE
        INITIALIZE mr_cdv_par_padrao.* TO NULL
        OUTPUT TO REPORT cdv2015_relat(mr_cdv_par_padrao.*)
        CALL log0030_mensagem('Não existem dados para serem listados. ' ,'info')
    END IF
    CLOSE cl_unidade_funcional_viajante
    WHENEVER ERROR STOP

    FINISH REPORT cdv2015_relat
    IF g_ies_ambiente = 'W'   AND
        p_ies_impressao = 'S'  THEN
        LET m_comando = 'lpdos.bat ',
                        m_caminho CLIPPED, ' ', p_nom_arquivo CLIPPED
        RUN m_comando
    END IF

    IF p_ies_impressao = 'S' THEN
        CALL log0030_mensagem('Relatório gravado com sucesso.','info')
    ELSE
        LET  l_mensagem = 'Relatório gravado no arquivo ',p_nom_arquivo CLIPPED
        CALL log0030_mensagem(l_mensagem,'info')
    END IF

END FUNCTION

#-------------------------------------------------------#
 REPORT cdv2015_relat(l_relat)
#-------------------------------------------------------#
    DEFINE l_relat RECORD
           parametro           LIKE cdv_par_padrao.parametro,
           parametro_numerico  DECIMAL(2,0)
    END RECORD

    OUTPUT
        LEFT MARGIN 0
        TOP MARGIN 0
        BOTTOM MARGIN 1
{
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
cdv2015                     Listagem Unidade Funcional X Linha negócio                         FL. ###&
                                                                 EXTRAIDO EM DD/MM/YYYY AS &&.&&.&& HRS.

UNIDADE    LINHA NEGOCIO
---------- ------------------------------------

XXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

*** ULTIMA FOLHA ***
}

    FORMAT
        PAGE HEADER
            PRINT log5211_retorna_configuracao(PAGENO,66,136) CLIPPED;
            PRINT COLUMN 001, m_den_empresa
            PRINT COLUMN 001, 'cdv2015',
                  COLUMN 021, 'UNIDADE FUNCIONAL X LINHA NEGOCIO',
                  COLUMN 068, 'FL. ', PAGENO USING '####'
            PRINT COLUMN 037, 'EXTRAIDO EM ', TODAY USING 'dd/mm/yyyy',
                  COLUMN 060, 'AS ', TIME,
                  COLUMN 072, 'HRS.'
            SKIP 1 LINE
            PRINT COLUMN 001, 'UNIDADE FUNCIONAL                         LINHA NEGOCIO                   '
            PRINT COLUMN 001, '---------- ------------------------------ -- ------------------------------'
        ON EVERY ROW
            PRINT COLUMN 001,l_relat.parametro[1,10],
                  COLUMN 012,m_den_uni_funcio,
                  COLUMN 043,l_relat.parametro_numerico USING "&&",
                  COLUMN 046,m_den_estr_linprod
        ON LAST ROW
            LET m_last_row = true
        PAGE TRAILER
            IF m_last_row = true
            THEN PRINT '* * * ULTIMA FOLHA * * *',
                      log5211_termino_impressao() CLIPPED
            ELSE PRINT ' '
            END IF
 END REPORT

#-----------------------------------------------------#
   FUNCTION cdv2015_linha_produto(m_parametro,
                                 m_cod_lin_prod,
                                 m_cod_lin_recei,
                                 m_cod_seg_merc,
                                 m_cod_cla_uso)
#-----------------------------------------------------#

   DEFINE  m_parametro		       SMALLINT,
           m_cod_lin_prod	     LIKE linha_prod.cod_lin_prod,
           m_cod_lin_recei	    LIKE linha_prod.cod_lin_recei,
           m_cod_seg_merc	     LIKE linha_prod.cod_seg_merc,
           m_cod_cla_uso	      LIKE linha_prod.cod_cla_uso

   DEFINE  p_especif         ARRAY [500] OF RECORD
                               p_cod_linprod  DECIMAL(2,0),
                               p_den_linprod  LIKE linha_prod.den_estr_linprod
                             END RECORD

   DEFINE   p_ind            SMALLINT,
            p_cont           DECIMAL(3,0),
            p_cod_linprod    DECIMAL(2,0),
            p_den_linprod    LIKE linha_prod.den_estr_linprod,
            sql_stmt         CHAR(500),
            p_alt            CHAR(03),
            p_nom_tela       CHAR(200),
            l_sem_uso1       DECIMAL(2,0),
            l_sem_uso2       DECIMAL(2,0),
            l_sem_uso3       DECIMAL(2,0)


  OPTIONS
    NEXT KEY control-f,
    PREVIOUS KEY control-b


  LET p_ind = 1
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("cdv20151") RETURNING p_nom_tela
  OPEN WINDOW w_cdv20151 AT 04,25 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)


   CALL log0010_close_window_screen()
 IF int_flag
 THEN LET int_flag = 0
      CLOSE WINDOW w_cdv20151 RETURN p_cod_linprod, p_den_linprod
 END IF

 IF  m_parametro = 1 THEN
     LET sql_stmt = " SELECT UNIQUE cod_lin_prod, den_estr_linprod ",
                      " FROM linha_prod ",
                     " WHERE cod_lin_recei = 0 ",
                       " AND cod_seg_merc  = 0 ",
                       " AND cod_cla_uso   = 0 ",
                     " ORDER BY cod_lin_prod "
 END IF

 IF  m_parametro = 2 THEN
     LET sql_stmt = " SELECT UNIQUE cod_lin_recei, den_estr_linprod, cod_lin_prod, cod_seg_merc, cod_cla_uso ",
                      " FROM linha_prod ",
                     " WHERE cod_lin_prod  = ",m_cod_lin_prod,"",
                       " AND cod_seg_merc  = 0 ",
                       " AND cod_cla_uso   = 0 ",
                     " ORDER BY cod_lin_prod "
 END IF

 IF  m_parametro = 3 THEN
     LET sql_stmt = " SELECT UNIQUE cod_seg_merc, den_estr_linprod, cod_lin_prod, cod_lin_recei, cod_cla_uso ",
                      " FROM linha_prod ",
                     " WHERE cod_lin_prod  = ",m_cod_lin_prod,"",
                       " AND cod_lin_recei = ",m_cod_lin_recei,"",
                       " AND cod_cla_uso   = 0 ",
                     " ORDER BY cod_lin_prod "
 END IF

 IF  m_parametro = 4 THEN
     LET sql_stmt = " SELECT UNIQUE cod_cla_uso, den_estr_linprod, cod_lin_prod, cod_lin_recei, cod_seg_merc ",
                      " FROM linha_prod ",
                     " WHERE cod_lin_prod  = ",m_cod_lin_prod,  "",
                       " AND cod_lin_recei = ",m_cod_lin_recei, "",
                       " AND cod_seg_merc  = ",m_cod_seg_merc,  "",
                     " ORDER BY cod_lin_prod "
 END IF


 MESSAGE "Aguarde Processando . . .     " ATTRIBUTE(REVERSE)
 PREPARE var_query FROM  sql_stmt
 DECLARE cq_linprod CURSOR FOR var_query
 FOREACH cq_linprod INTO p_especif[p_ind].*, l_sem_uso1, l_sem_uso2, l_sem_uso3
   LET p_ind = p_ind + 1
   IF p_ind >500
   THEN EXIT FOREACH
   END IF
 END FOREACH
 MESSAGE "                              "
 CALL set_count(p_ind - 1)
 IF p_ind = 1
 THEN CLEAR FORM
      ERROR "    Argumentos de Pesquisa nao Encontrado "
 ELSE DISPLAY ARRAY p_especif TO s_etg.*
      IF int_flag
      THEN LET int_flag = 0
      ELSE LET p_ind = arr_curr()
           LET p_cod_linprod = p_especif[p_ind].p_cod_linprod
           LET p_den_linprod = p_especif[p_ind].p_den_linprod
      END IF
 END IF
 CLOSE cq_linprod
 CLOSE WINDOW w_cdv20151
 RETURN p_cod_linprod, p_den_linprod
END FUNCTION


#-------------------------------#
 FUNCTION cdv2015_version_info()
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2015.4gl $|$Revision: 7 $|$Date: 24/04/12 10:25 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION

    