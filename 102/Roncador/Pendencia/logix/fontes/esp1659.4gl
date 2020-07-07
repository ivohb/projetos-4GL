###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# PROGRAMA: ESP1659                                               #
# OBJETIVO: CADASTRO PARÂMETROS BALANÇA                           #
# AUTOR...: ANA PAULA CASAS DE ALMEIDA                            #
# DATA....: 18/07/2013                                            #
#-----------------------------------------------------------------#
DATABASE logix

 GLOBALS

  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         m_den_empresa          LIKE empresa.den_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT,
         g_ies_ambiente         CHAR(001),
         p_nom_arquivo          CHAR(100),
         p_ies_impressao        CHAR(001),
         p_caminho              CHAR(100),
         comando                CHAR(80),
         g_ies_grafico          SMALLINT

  DEFINE p_versao               CHAR(18)

 END GLOBALS

  DEFINE m_comando_sup      CHAR(150),
         sql_stmt           CHAR(1000),
         where_clause       CHAR(500)

  DEFINE m_consulta_ativa   SMALLINT

  DEFINE mr_tela            RECORD
                               cod_balanca      LIKE esp_par_balanca.cod_balanca,
                               den_balanca      LIKE esp_par_balanca.den_balanca,
                               bat              LIKE esp_par_balanca.bat,
                               porta            LIKE esp_par_balanca.porta,
                               veloc_balanca    LIKE esp_par_balanca.veloc_balanca,
                               time_out         LIKE esp_par_balanca.time_out,
                               tamanho_bit      LIKE esp_par_balanca.tamanho_bit,
                               paridade         LIKE esp_par_balanca.paridade,
                               stopbits         LIKE esp_par_balanca.stopbits
                            END RECORD

MAIN

 CALL log0180_conecta_usuario()

 LET p_versao = "ESP1659-10.02.02"

 WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
 WHENEVER ERROR STOP

 DEFER INTERRUPT

 CALL log001_acessa_usuario("SUPRIMEN","LOGERP")
      RETURNING p_status, p_cod_empresa, p_user

 IF p_status = 0 THEN
    CALL esp1659_controle()
 END IF

END MAIN

#--------------------------#
 FUNCTION esp1659_controle()
#--------------------------#
 DEFINE l_comando       CHAR(80)

 CALL log006_exibe_teclas("01",p_versao)

 IF NOT log0150_verifica_se_tabela_existe("esp_par_balanca") THEN
    CALL log0030_mensagem("Favor executar o SQL esp1659.sql para criação da tabela.","excl")
    RETURN
 END IF

 CALL log130_procura_caminho("esp1659") RETURNING m_comando_sup
 OPEN WINDOW w_esp1659 AT 2,2 WITH FORM m_comando_sup
      ATTRIBUTE (BORDER,MESSAGE LINE LAST , PROMPT LINE LAST )

 DISPLAY p_cod_empresa TO cod_empresa

 MENU "OPÇÃO"
   COMMAND "Incluir"    "Inclui registro na tabela."
       HELP 001
       MESSAGE ""
       LET int_flag = 0
       IF log005_seguranca(p_user,"SUPRIMEN","esp1659","IN") THEN
          CALL esp1659_inclusao()
          LET m_consulta_ativa = FALSE
       END IF

   COMMAND "Modificar"  "Modifica registro da tabela."
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF m_consulta_ativa THEN
          IF log005_seguranca(p_user,"SUPRIMEN","esp1659","MO") THEN
             CALL esp1659_modificacao()
          END IF
       ELSE
          CALL log0030_mensagem(" Consulte previamente para fazer a modificação. ","info")
       END IF

   COMMAND "Excluir"  "Exclui registro da tabela."
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF m_consulta_ativa THEN
          IF log005_seguranca(p_user, 'SUPRIMEN', 'esp1659', 'EX') THEN
             CALL esp1659_exclusao()
          END IF
       ELSE
          CALL log0030_mensagem(" Consulte previamente para fazer a exclusão. ","info")
       END IF

   COMMAND "Consultar"  "Consulta registros da tabela."
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF log005_seguranca(p_user,"SUPRIMEN","esp1659","CO") THEN
          IF esp1659_consulta() THEN
             CALL esp1659_prepara_consulta()
             CALL esp1659_exibe_dados()
          END IF
       END IF

   COMMAND 'Seguinte'  'Exibe o próximo item encontrado na pesquisa.'
       HELP 005
       MESSAGE ''
       IF m_consulta_ativa THEN
          CALL esp1659_paginacao('SEGUINTE')
       ELSE
          ERROR ' Não existe nenhuma consulta ativa. '
       END IF

   COMMAND 'Anterior'  'Exibe o item anterior encontrado na pesquisa.'
       HELP 006
       MESSAGE ''
       IF m_consulta_ativa THEN
          CALL esp1659_paginacao('ANTERIOR')
       ELSE
          ERROR ' Não existe nenhuma consulta ativa. '
       END IF

   COMMAND "Listar"      "Lista os registros da tabela."
       HELP 007
       MESSAGE ""
       IF log005_seguranca(p_user, "SUPRIMEN", "esp1659", "CO") THEN
          IF log0280_saida_relat(19,17) IS NOT NULL THEN
             CALL esp1659_listar()
          END IF
       END IF

   COMMAND KEY ("!")
       PROMPT "Digite o comando : " FOR m_comando_sup
       RUN m_comando_sup
       PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando_sup
       LET int_flag = 0

   COMMAND "Fim" "Retorna ao menu anterior."
       HELP 008
       EXIT MENU

  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL ESP_info_sobre(sourceName(),p_versao)

 END MENU

 CLOSE WINDOW w_esp1659

 END FUNCTION

#-----------------------------#
 FUNCTION esp1659_inclusao()
#-----------------------------#
 INITIALIZE mr_tela.* TO NULL
 CLEAR FORM

 IF esp1659_entrada_dados("INCLUSAO") THEN
    CALL log085_transacao("BEGIN")
    WHENEVER ERROR CONTINUE
     INSERT INTO esp_par_balanca (cod_empresa,
                                  cod_balanca,
                                  den_balanca,
                                  bat,
                                  porta,
                                  veloc_balanca,
                                  time_out,
                                  tamanho_bit,
                                  paridade,
                                  stopbits)
                          VALUES (p_cod_empresa,
                                  mr_tela.cod_balanca,
                                  mr_tela.den_balanca,
                                  mr_tela.bat,
                                  mr_tela.porta,
                                  mr_tela.veloc_balanca,
                                  mr_tela.time_out,
                                  mr_tela.tamanho_bit,
                                  mr_tela.paridade,
                                  mr_tela.stopbits)
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","esp_par_balanca")
       CALL log085_transacao("ROLLBACK")
       RETURN
    END IF

    MESSAGE "Inclusão efetuada com sucesso." ATTRIBUTE(REVERSE)

    WHENEVER ERROR CONTINUE
    CALL log085_transacao("COMMIT")
    WHENEVER ERROR STOP

 ELSE
    INITIALIZE mr_tela.* TO NULL
    CLEAR FORM
    CALL esp1659_exibe_dados()
    ERROR "Inclusão cancelada."
 END IF

 END FUNCTION

#-----------------------------------------#
 FUNCTION esp1659_entrada_dados(l_funcao)
#-----------------------------------------#
 DEFINE l_funcao     CHAR(20)

 CALL log006_exibe_teclas("01 02 03", p_versao)
 CURRENT WINDOW IS w_esp1659

 IF l_funcao = "INCLUSAO" THEN
    CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa
 END IF

 INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

   BEFORE FIELD cod_balanca
      IF l_funcao = "MODIFICACAO" THEN
         NEXT FIELD den_balanca
      END IF

   AFTER FIELD cod_balanca
      IF mr_tela.cod_balanca IS NULL THEN
         CALL log0030_mensagem("Balança deve ser informada.","excl")
         NEXT FIELD cod_balanca
      ELSE
         IF l_funcao = "INCLUSAO" THEN
            IF esp1659_verifica_inclusao() THEN
               NEXT FIELD cod_balanca
            END IF
         END IF
      END IF

   AFTER FIELD den_balanca
      IF mr_tela.den_balanca IS NULL THEN
         CALL log0030_mensagem("Descrição da balança deve ser informada.","excl")
         NEXT FIELD den_balanca
      END IF

   AFTER FIELD bat
      IF mr_tela.bat IS NULL THEN
         CALL log0030_mensagem("BAT deve ser informada.","info")
         NEXT FIELD bat
      END IF

   AFTER INPUT
      IF NOT int_flag THEN
         IF mr_tela.cod_balanca IS NULL THEN
            CALL log0030_mensagem("Balança deve ser informada.","excl")
            NEXT FIELD cod_balanca
         ELSE
            IF l_funcao = "INCLUSAO" THEN
               IF esp1659_verifica_inclusao() THEN
                  NEXT FIELD cod_balanca
               END IF
            END IF
         END IF

         IF mr_tela.den_balanca IS NULL THEN
            CALL log0030_mensagem("Descrição da balança deve ser informada.","excl")
            NEXT FIELD den_balanca
         END IF

         IF mr_tela.bat IS NULL THEN
            CALL log0030_mensagem("BAT deve ser informada.","info")
            NEXT FIELD bat
         END IF

      END IF

 END INPUT

 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_esp1659

 IF int_flag <> 0 THEN
    LET int_flag = 0
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------------#
 FUNCTION esp1659_verifica_inclusao()
#------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT cod_balanca
    FROM esp_par_balanca
   WHERE cod_empresa  = p_cod_empresa
     AND cod_balanca  = mr_tela.cod_balanca
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    CALL log0030_mensagem("Balança já cadastrada.","excl")
    RETURN TRUE
 END IF

 RETURN FALSE

 END FUNCTION

#-------------------------------#
 FUNCTION esp1659_exibe_dados()
#-------------------------------#
 DISPLAY BY NAME mr_tela.*

 END FUNCTION

#-------------------------------#
 FUNCTION esp1659_modificacao()
#-------------------------------#
 IF esp1659_cursor_for_update() THEN
    IF esp1659_entrada_dados('MODIFICACAO') THEN
       CALL log085_transacao("BEGIN")
       WHENEVER ERROR CONTINUE
        UPDATE esp_par_balanca
           SET den_balanca   = mr_tela.den_balanca,
               bat           = mr_tela.bat,
               porta         = mr_tela.porta,
               veloc_balanca = mr_tela.veloc_balanca,
               time_out      = mr_tela.time_out,
               tamanho_bit   = mr_tela.tamanho_bit,
               paridade      = mr_tela.paridade,
               stopbits      = mr_tela.stopbits
         WHERE cod_empresa   = p_cod_empresa
           AND cod_balanca   = mr_tela.cod_balanca
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("UPDATE","esp_par_balanca")
          CALL log085_transacao("ROLLBACK")
          RETURN
       END IF

       MESSAGE 'Modificação efetuada com sucesso. ' ATTRIBUTE(REVERSE)

       WHENEVER ERROR CONTINUE
       CALL log085_transacao("COMMIT")
       WHENEVER ERROR STOP
    ELSE
       INITIALIZE mr_tela.* TO NULL
       ERROR 'Modificação cancelada. '
    END IF
 END IF

 CALL esp1659_exibe_dados()

 END FUNCTION

#------------------------------------#
 FUNCTION esp1659_cursor_for_update()
#------------------------------------#
 DECLARE cl_balanca CURSOR FOR
  SELECT cod_balanca
    FROM esp_par_balanca
   WHERE cod_empresa  = p_cod_empresa
     AND cod_balanca  = mr_tela.cod_balanca
 FOR UPDATE
 CALL log085_transacao("BEGIN")

 WHENEVER ERROR CONTINUE
   OPEN cl_balanca
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
     FETCH cl_balanca INTO mr_tela.cod_balanca
    WHENEVER ERROR STOP

    CASE sqlca.sqlcode
         WHEN 0          RETURN TRUE
         WHEN -250       CALL log0030_mensagem(' Registro sendo atualizado por outro usuário. Aguarde e tente novamente. ', 'exclamation')
         WHEN -243       CALL log0030_mensagem(" Registro sendo atualizado por outro usuario. Aguarde e tente novamente. ","info")
         WHEN NOTFOUND   CALL log0030_mensagem(' Registro não existe mais na tabela. \nExecute a consulta novamente. ', 'exclamation')
         OTHERWISE       CALL log003_err_sql('LEITURA','esp_par_balanca')
    END CASE

    WHENEVER ERROR CONTINUE
      CLOSE cl_balanca
      FREE  cl_balanca
    WHENEVER ERROR STOP
 ELSE
    CALL log003_err_sql('LEITURA','esp_par_balanca')
 END IF

 CALL log085_transacao("ROLLBACK")

 RETURN FALSE

 END FUNCTION

#-----------------------------#
 FUNCTION esp1659_exclusao()
#-----------------------------#
 IF esp1659_cursor_for_update() THEN
    IF log004_confirm(21,44)  THEN
       CALL log085_transacao("BEGIN")

       WHENEVER ERROR CONTINUE
       DELETE FROM esp_par_balanca
        WHERE cod_empresa = p_cod_empresa
          AND cod_balanca = mr_tela.cod_balanca
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode = 0 THEN
          INITIALIZE mr_tela.* TO NULL
          CLEAR FORM
          MESSAGE ' Exclusão efetuada com sucesso. ' ATTRIBUTE(REVERSE)

          CALL log085_transacao("COMMIT")
          CALL esp1659_exibe_dados()
       ELSE
          CALL log003_err_sql("DELETE","esp_par_balanca")
          CALL log085_transacao("ROLLBACK")
       END IF
    ELSE
       ERROR "Exclusão cancelada."
    END IF
 END IF

 END FUNCTION

#----------------------------#
 FUNCTION esp1659_consulta()
#----------------------------#
 CALL log006_exibe_teclas('01 02 03', p_versao)
 CURRENT WINDOW IS w_esp1659

 LET where_clause =  NULL
 LET INT_FLAG = FALSE

 INITIALIZE mr_tela.* TO NULL
 CLEAR FORM
 DISPLAY p_cod_empresa TO cod_empresa

 CONSTRUCT BY NAME where_clause ON cod_balanca, den_balanca, bat, porta, veloc_balanca,
                                   time_out, tamanho_bit, paridade, stopbits

 END CONSTRUCT

 CALL log006_exibe_teclas('01', p_versao)
 CURRENT WINDOW IS w_esp1659

 IF INT_FLAG THEN
    LET int_flag = FALSE
    ERROR 'Consulta cancelada. '
    RETURN FALSE
 END IF

 CALL log006_exibe_teclas('01 09', p_versao)
 CURRENT WINDOW IS w_esp1659

 RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION esp1659_prepara_consulta()
#-----------------------------------#
 LET sql_stmt = "SELECT cod_balanca, den_balanca, bat, porta, veloc_balanca,time_out, tamanho_bit, paridade, stopbits ",
                "  FROM esp_par_balanca ",
                " WHERE ",where_clause CLIPPED,
                " ORDER BY cod_balanca "

 CALL log0810_prepare_sql(sql_stmt) RETURNING sql_stmt

 WHENEVER ERROR CONTINUE
 PREPARE var_balanca FROM sql_stmt
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("PREPARE","VAR_BALANCA")
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cl_balanca SCROLL CURSOR WITH HOLD FOR var_balanca
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("declare","CL_BALANCA")
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 OPEN  cl_balanca
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("OPEN","CL_BALANCA")
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 FETCH cl_balanca INTO mr_tela.cod_balanca, mr_tela.den_balanca, mr_tela.bat, mr_tela.porta, mr_tela.veloc_balanca,
                       mr_tela.time_out, mr_tela.tamanho_bit, mr_tela.paridade, mr_tela.stopbits
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    MESSAGE 'Consulta efetuada com sucesso. ' ATTRIBUTE (REVERSE)
    LET m_consulta_ativa = TRUE
 ELSE
    LET m_consulta_ativa = FALSE
    CALL log0030_mensagem('Argumentos de pesquisa não encontrados. ','info')
 END IF

 END FUNCTION

#-------------------------------------#
 FUNCTION esp1659_paginacao(l_funcao)
#-------------------------------------#
 DEFINE l_funcao  CHAR(010)

 WHILE TRUE
     IF l_funcao = 'SEGUINTE' THEN
        FETCH NEXT     cl_balanca INTO mr_tela.cod_balanca, mr_tela.den_balanca, mr_tela.bat, mr_tela.porta, mr_tela.veloc_balanca,
                                       mr_tela.time_out, mr_tela.tamanho_bit, mr_tela.paridade, mr_tela.stopbits
     ELSE
        FETCH PREVIOUS cl_balanca INTO mr_tela.cod_balanca, mr_tela.den_balanca, mr_tela.bat, mr_tela.porta, mr_tela.veloc_balanca,
                                       mr_tela.time_out, mr_tela.tamanho_bit, mr_tela.paridade, mr_tela.stopbits
     END IF

     IF sqlca.sqlcode = 0 THEN
        WHENEVER ERROR CONTINUE
         SELECT cod_balanca, den_balanca, bat, porta, veloc_balanca,time_out, tamanho_bit, paridade, stopbits
           INTO mr_tela.cod_balanca, mr_tela.den_balanca, mr_tela.bat, mr_tela.porta, mr_tela.veloc_balanca,
                mr_tela.time_out, mr_tela.tamanho_bit, mr_tela.paridade, mr_tela.stopbits
           FROM esp_par_balanca
          WHERE cod_empresa = p_cod_empresa
            AND cod_balanca = mr_tela.cod_balanca
          ORDER BY cod_balanca
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode = 0 THEN
           EXIT WHILE
        END IF
     ELSE
        ERROR ' Não existem mais itens nesta direção. '
        EXIT WHILE
     END IF
 END WHILE
 CALL esp1659_exibe_dados()

 END FUNCTION

#----------------------------#
 FUNCTION esp1659_listar()
#----------------------------#
 DEFINE lr_relat    RECORD
                       cod_balanca      LIKE esp_par_balanca.cod_balanca,
                       den_balanca      LIKE esp_par_balanca.den_balanca,
                       bat              LIKE esp_par_balanca.bat,
                       porta            LIKE esp_par_balanca.porta,
                       veloc_balanca    LIKE esp_par_balanca.veloc_balanca,
                       time_out         LIKE esp_par_balanca.time_out,
                       tamanho_bit      LIKE esp_par_balanca.tamanho_bit,
                       paridade         LIKE esp_par_balanca.paridade,
                       stopbits         LIKE esp_par_balanca.stopbits
                    END RECORD

 DEFINE l_tot_reg   SMALLINT,
        l_mensagem  CHAR(200)

 MESSAGE " Processando a extração do relatório ... " ATTRIBUTE(REVERSE)

 IF p_ies_impressao = "S" THEN
    IF g_ies_ambiente = "W" THEN
       CALL log150_procura_caminho("LST") RETURNING p_caminho
       LET p_caminho = p_caminho CLIPPED, "esp1659.tmp"
       START REPORT esp1659_relat TO p_caminho
    ELSE
       START REPORT esp1659_relat TO PIPE p_nom_arquivo
    END IF
 ELSE
    START REPORT esp1659_relat TO p_nom_arquivo
 END IF

 WHENEVER ERROR CONTINUE
  SELECT den_empresa
    INTO m_den_empresa
    FROM empresa
   WHERE cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP

 LET l_tot_reg = 0

 WHENEVER ERROR CONTINUE
 DECLARE cl_balanca2 CURSOR FOR
   SELECT cod_balanca, den_balanca, bat, porta, veloc_balanca,time_out, tamanho_bit, paridade, stopbits
     FROM esp_par_balanca
    WHERE cod_empresa = p_cod_empresa
    ORDER BY cod_balanca
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 FOREACH cl_balanca2 INTO lr_relat.cod_balanca, lr_relat.den_balanca, lr_relat.bat, lr_relat.porta, lr_relat.veloc_balanca,
                          lr_relat.time_out, lr_relat.tamanho_bit, lr_relat.paridade, lr_relat.stopbits
 WHENEVER ERROR STOP

      OUTPUT TO REPORT esp1659_relat(lr_relat.*)
      LET l_tot_reg = l_tot_reg + 1

 END FOREACH
 FREE cl_balanca2

 FINISH REPORT esp1659_relat

 IF g_ies_ambiente = "W" AND p_ies_impressao = "S"  THEN
    LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
    RUN comando
 END IF

 MESSAGE " "

 IF l_tot_reg > 0 THEN
    IF p_ies_impressao = 'S' THEN
       CALL log0030_mensagem('Relatório impresso com sucesso.','info')
    ELSE
       LET  l_mensagem = 'Relatório gravado no arquivo ',p_nom_arquivo CLIPPED
       CALL log0030_mensagem(l_mensagem,'info')
    END IF
 ELSE
    INITIALIZE lr_relat.* TO NULL
    CALL log0030_mensagem(' Não existem dados para serem listados. ' ,'info')
 END IF

 END FUNCTION

#-------------------------------#
 REPORT esp1659_relat(lr_relat)
#-------------------------------#
 DEFINE lr_relat    RECORD
                       cod_balanca      LIKE esp_par_balanca.cod_balanca,
                       den_balanca      LIKE esp_par_balanca.den_balanca,
                       bat              LIKE esp_par_balanca.bat,
                       porta            LIKE esp_par_balanca.porta,
                       veloc_balanca    LIKE esp_par_balanca.veloc_balanca,
                       time_out         LIKE esp_par_balanca.time_out,
                       tamanho_bit      LIKE esp_par_balanca.tamanho_bit,
                       paridade         LIKE esp_par_balanca.paridade,
                       stopbits         LIKE esp_par_balanca.stopbits
                    END RECORD

 DEFINE l_last_row            SMALLINT

 OUTPUT LEFT MARGIN 0
        TOP MARGIN 0
        BOTTOM MARGIN 0
        PAGE LENGTH 66

 FORMAT
     PAGE HEADER
       PRINT log5211_retorna_configuracao(PAGENO,66,100) CLIPPED;
       PRINT COLUMN 001, m_den_empresa
       PRINT COLUMN 001, 'ESP1659',
             COLUMN 036, 'RELATORIO PARAMETROS BALANCA',
             COLUMN 092, 'FL. ', PAGENO USING '####'
       PRINT COLUMN 061, 'EXTRAIDO EM ', TODAY USING 'dd/mm/yyyy', ' AS ', TIME, ' HRS.'
       SKIP 1 LINE
       PRINT COLUMN 001, "BALANCA DENOMINACAO                    PORTA VELOC BALANCA   TIME OUT TAM BIT PARIDADE   STOP BITS"
       PRINT COLUMN 001, "------- ------------------------------ ----- ------------- ---------- ------- ---------- ----------"

     ON EVERY ROW
       PRINT COLUMN 001, lr_relat.cod_balanca       CLIPPED,
             COLUMN 009, lr_relat.den_balanca       CLIPPED,
             COLUMN 040, lr_relat.bat               CLIPPED,
             COLUMN 056, lr_relat.porta             CLIPPED,
             COLUMN 062, lr_relat.veloc_balanca     USING "#########&",
             COLUMN 076, lr_relat.time_out          USING "#########&",
             COLUMN 087, lr_relat.tamanho_bit       USING "####&",
             COLUMN 095, lr_relat.paridade          CLIPPED,
             COLUMN 106, lr_relat.stopbits          CLIPPED

     ON LAST ROW
       LET l_last_row = TRUE

     PAGE TRAILER
       IF l_last_row THEN
          PRINT '* * * ULTIMA FOLHA * * *'
       ELSE
          PRINT ' '
       END IF

 END REPORT

#-------------------------------#
 FUNCTION esp1659_version_info()
#-------------------------------#
  RETURN "$Archive: esp1659.4gl $|$Revision: 2 $|$Date: 18/07/13 17:12 $|$Modtime: 18/07/13 16:54 $"

 END FUNCTION

