###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# PROGRAMA: ESP1660                                               #
# OBJETIVO: CADASTRO CATEGORIA VEÍCULOS                           #
# AUTOR...: ANA PAULA CASAS DE ALMEIDA                            #
# DATA....: 21/07/2013                                            #
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
                               cod_categoria    LIKE esp_categ_veiculos.cod_categoria,
                               den_categoria    LIKE esp_categ_veiculos.den_categoria,
                               peso_bruto       LIKE esp_categ_veiculos.peso_bruto,
                               perc_tolerancia  LIKE esp_categ_veiculos.perc_tolerancia,
                               bloq_pesagem     LIKE esp_categ_veiculos.bloq_pesagem
                            END RECORD

MAIN

 CALL log0180_conecta_usuario()

 LET p_versao = "ESP1660-10.02.01"

 WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
 WHENEVER ERROR STOP

 DEFER INTERRUPT

 CALL log001_acessa_usuario("SUPRIMEN","LOGERP")
      RETURNING p_status, p_cod_empresa, p_user

 IF p_status = 0 THEN
    CALL esp1660_controle()
 END IF

END MAIN

#--------------------------#
 FUNCTION esp1660_controle()
#--------------------------#
 DEFINE l_comando       CHAR(80)

 CALL log006_exibe_teclas("01",p_versao)

 IF NOT log0150_verifica_se_tabela_existe("esp_categ_veiculos") THEN
    CALL log0030_mensagem("Favor executar o SQL esp1659.sql para criação da tabela.","excl")
    RETURN
 END IF

 CALL log130_procura_caminho("esp1660") RETURNING m_comando_sup
 OPEN WINDOW w_esp1660 AT 2,2 WITH FORM m_comando_sup
      ATTRIBUTE (BORDER,MESSAGE LINE LAST , PROMPT LINE LAST )

 DISPLAY p_cod_empresa TO cod_empresa

 MENU "OPÇÃO"
   COMMAND "Incluir"    "Inclui registro na tabela."
       HELP 001
       MESSAGE ""
       LET int_flag = 0
       IF log005_seguranca(p_user,"SUPRIMEN","esp1660","IN") THEN
          CALL esp1660_inclusao()
          LET m_consulta_ativa = FALSE
       END IF

   COMMAND "Modificar"  "Modifica registro da tabela."
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF m_consulta_ativa THEN
          IF log005_seguranca(p_user,"SUPRIMEN","esp1660","MO") THEN
             CALL esp1660_modificacao()
          END IF
       ELSE
          CALL log0030_mensagem(" Consulte previamente para fazer a modificação. ","info")
       END IF

   COMMAND "Excluir"  "Exclui registro da tabela."
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF m_consulta_ativa THEN
          IF log005_seguranca(p_user, 'SUPRIMEN', 'esp1660', 'EX') THEN
             CALL esp1660_exclusao()
          END IF
       ELSE
          CALL log0030_mensagem(" Consulte previamente para fazer a exclusão. ","info")
       END IF

   COMMAND "Consultar"  "Consulta registros da tabela."
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF log005_seguranca(p_user,"SUPRIMEN","esp1660","CO") THEN
          IF esp1660_consulta() THEN
             CALL esp1660_prepara_consulta()
             CALL esp1660_exibe_dados()
          END IF
       END IF

   COMMAND 'Seguinte'  'Exibe o próximo item encontrado na pesquisa.'
       HELP 005
       MESSAGE ''
       IF m_consulta_ativa THEN
          CALL esp1660_paginacao('SEGUINTE')
       ELSE
          ERROR ' Não existe nenhuma consulta ativa. '
       END IF

   COMMAND 'Anterior'  'Exibe o item anterior encontrado na pesquisa.'
       HELP 006
       MESSAGE ''
       IF m_consulta_ativa THEN
          CALL esp1660_paginacao('ANTERIOR')
       ELSE
          ERROR ' Não existe nenhuma consulta ativa. '
       END IF

   COMMAND "Listar"      "Lista os registros da tabela."
       HELP 007
       MESSAGE ""
       IF log005_seguranca(p_user, "SUPRIMEN", "esp1660", "CO") THEN
          IF log0280_saida_relat(19,17) IS NOT NULL THEN
             CALL esp1660_listar()
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

 CLOSE WINDOW w_esp1660

 END FUNCTION

#-----------------------------#
 FUNCTION esp1660_inclusao()
#-----------------------------#
 INITIALIZE mr_tela.* TO NULL
 CLEAR FORM

 IF esp1660_entrada_dados("INCLUSAO") THEN
    CALL log085_transacao("BEGIN")
    WHENEVER ERROR CONTINUE
     INSERT INTO esp_categ_veiculos (cod_empresa,
                                     cod_categoria,
                                     den_categoria,
                                     peso_bruto,
                                     perc_tolerancia,
                                     bloq_pesagem)
                             VALUES (p_cod_empresa,
                                     mr_tela.cod_categoria,
                                     mr_tela.den_categoria,
                                     mr_tela.peso_bruto,
                                     mr_tela.perc_tolerancia,
                                     mr_tela.bloq_pesagem)
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","esp_categ_veiculos")
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
    DISPLAY p_cod_empresa TO cod_empresa
    CALL esp1660_exibe_dados()
    ERROR "Inclusão cancelada."
 END IF

 END FUNCTION

#-----------------------------------------#
 FUNCTION esp1660_entrada_dados(l_funcao)
#-----------------------------------------#
 DEFINE l_funcao     CHAR(20)

 CALL log006_exibe_teclas("01 02 03", p_versao)
 CURRENT WINDOW IS w_esp1660

 IF l_funcao = "INCLUSAO" THEN
    CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa
    LET mr_tela.bloq_pesagem = "N"
 END IF

 INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

   BEFORE FIELD cod_categoria
      IF l_funcao = "MODIFICACAO" THEN
         NEXT FIELD den_categoria
      END IF

   AFTER FIELD cod_categoria
      IF mr_tela.cod_categoria IS NULL THEN
         CALL log0030_mensagem("Categoria deve ser informada.","excl")
         NEXT FIELD cod_categoria
      ELSE
         IF l_funcao = "INCLUSAO" THEN
            IF esp1660_verifica_inclusao() THEN
               NEXT FIELD cod_categoria
            END IF
         END IF
      END IF

   AFTER FIELD den_categoria
      IF mr_tela.den_categoria IS NULL THEN
         CALL log0030_mensagem("Descrição da categoria deve ser informada.","excl")
         NEXT FIELD den_categoria
      END IF

   AFTER FIELD peso_bruto
      IF mr_tela.peso_bruto IS NULL THEN
         CALL log0030_mensagem("Peso bruto deve ser informado.","excl")
         NEXT FIELD peso_bruto
      ELSE
         IF mr_tela.peso_bruto < 0 THEN
            CALL log0030_mensagem("Peso bruto deve ser maior que zero.","info")
            NEXT FIELD peso_bruto
         END IF
      END IF

   AFTER FIELD perc_tolerancia
      IF mr_tela.perc_tolerancia IS NOT NULL THEN
         IF mr_tela.perc_tolerancia < 0 OR mr_tela.perc_tolerancia > 100 THEN
            CALL log0030_mensagem("Percentual de tolerância inválido. ","info")
            NEXT FIELD perc_tolerancia
         END IF
      END IF

   AFTER FIELD bloq_pesagem
      IF mr_tela.bloq_pesagem IS NOT NULL THEN
         IF mr_tela.bloq_pesagem <> "S" AND mr_tela.bloq_pesagem <> "N" THEN
            CALL log0030_mensagem("Indicador de bloqueio de pesagem inválido. Informe 'S' ou 'N'","info")
            NEXT FIELD bloq_pesagem
         END IF
      END IF

   AFTER INPUT
      IF NOT int_flag THEN
         IF mr_tela.cod_categoria IS NULL THEN
            CALL log0030_mensagem("Categoria deve ser informada.","excl")
            NEXT FIELD cod_categoria
         ELSE
            IF l_funcao = "INCLUSAO" THEN
               IF esp1660_verifica_inclusao() THEN
                  NEXT FIELD cod_categoria
               END IF
            END IF
         END IF

         IF mr_tela.den_categoria IS NULL THEN
            CALL log0030_mensagem("Descrição da categoria deve ser informada.","excl")
            NEXT FIELD den_categoria
         END IF

         IF mr_tela.peso_bruto IS NULL THEN
            CALL log0030_mensagem("Peso bruto deve ser informado.","excl")
            NEXT FIELD peso_bruto
         ELSE
            IF mr_tela.peso_bruto < 0 THEN
               CALL log0030_mensagem("Peso bruto deve ser maior que zero.","info")
               NEXT FIELD peso_bruto
            END IF
         END IF

         IF mr_tela.perc_tolerancia IS NOT NULL THEN
            IF mr_tela.perc_tolerancia < 0 OR mr_tela.perc_tolerancia > 100 THEN
               CALL log0030_mensagem("Percentual de tolerância inválido. ","info")
               NEXT FIELD perc_tolerancia
            END IF
         END IF

         IF mr_tela.bloq_pesagem IS NOT NULL THEN
            IF mr_tela.bloq_pesagem <> "S" AND mr_tela.bloq_pesagem <> "N" THEN
               CALL log0030_mensagem("Indicador de bloqueio de pesagem inválido. Informe 'S' ou 'N'","info")
               NEXT FIELD bloq_pesagem
            END IF
         END IF

      END IF

 END INPUT

 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_esp1660

 IF int_flag <> 0 THEN
    LET int_flag = 0
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------------#
 FUNCTION esp1660_verifica_inclusao()
#------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT cod_categoria
    FROM esp_categ_veiculos
   WHERE cod_empresa   = p_cod_empresa
     AND cod_categoria = mr_tela.cod_categoria
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    CALL log0030_mensagem("Categoria já cadastrada.","excl")
    RETURN TRUE
 END IF

 RETURN FALSE

 END FUNCTION

#-------------------------------#
 FUNCTION esp1660_exibe_dados()
#-------------------------------#
 DISPLAY BY NAME mr_tela.*
 DISPLAY p_cod_empresa TO cod_empresa

 END FUNCTION

#-------------------------------#
 FUNCTION esp1660_modificacao()
#-------------------------------#
 IF esp1660_cursor_for_update() THEN
    IF esp1660_entrada_dados('MODIFICACAO') THEN
       CALL log085_transacao("BEGIN")
       WHENEVER ERROR CONTINUE
        UPDATE esp_categ_veiculos
           SET den_categoria   = mr_tela.den_categoria,
               peso_bruto      = mr_tela.peso_bruto,
               perc_tolerancia = mr_tela.perc_tolerancia,
               bloq_pesagem    = mr_tela.bloq_pesagem
         WHERE cod_empresa   = p_cod_empresa
           AND cod_categoria = mr_tela.cod_categoria
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("UPDATE","esp_categ_veiculos")
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

 CALL esp1660_exibe_dados()

 END FUNCTION

#------------------------------------#
 FUNCTION esp1660_cursor_for_update()
#------------------------------------#
 DECLARE cl_categoria CURSOR FOR
  SELECT cod_categoria
    FROM esp_categ_veiculos
   WHERE cod_empresa   = p_cod_empresa
     AND cod_categoria = mr_tela.cod_categoria
 FOR UPDATE
 CALL log085_transacao("BEGIN")

 WHENEVER ERROR CONTINUE
   OPEN cl_categoria
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
     FETCH cl_categoria INTO mr_tela.cod_categoria
    WHENEVER ERROR STOP

    CASE sqlca.sqlcode
         WHEN 0          RETURN TRUE
         WHEN -250       CALL log0030_mensagem(' Registro sendo atualizado por outro usuário. Aguarde e tente novamente. ', 'exclamation')
         WHEN -243       CALL log0030_mensagem(" Registro sendo atualizado por outro usuario. Aguarde e tente novamente. ","info")
         WHEN NOTFOUND   CALL log0030_mensagem(' Registro não existe mais na tabela. \nExecute a consulta novamente. ', 'exclamation')
         OTHERWISE       CALL log003_err_sql('LEITURA','esp_categ_veiculos')
    END CASE

    WHENEVER ERROR CONTINUE
      CLOSE cl_categoria
      FREE  cl_categoria
    WHENEVER ERROR STOP
 ELSE
    CALL log003_err_sql('LEITURA','esp_categ_veiculos')
 END IF

 CALL log085_transacao("ROLLBACK")

 RETURN FALSE

 END FUNCTION

#-----------------------------#
 FUNCTION esp1660_exclusao()
#-----------------------------#
 IF esp1660_cursor_for_update() THEN
    IF log004_confirm(21,44)  THEN
       CALL log085_transacao("BEGIN")

       WHENEVER ERROR CONTINUE
       DELETE FROM esp_categ_veiculos
        WHERE cod_empresa   = p_cod_empresa
          AND cod_categoria = mr_tela.cod_categoria
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode = 0 THEN
          INITIALIZE mr_tela.* TO NULL
          CLEAR FORM
          MESSAGE ' Exclusão efetuada com sucesso. ' ATTRIBUTE(REVERSE)

          CALL log085_transacao("COMMIT")
          CALL esp1660_exibe_dados()
       ELSE
          CALL log003_err_sql("DELETE","esp_categ_veiculos")
          CALL log085_transacao("ROLLBACK")
       END IF
    ELSE
       ERROR "Exclusão cancelada."
    END IF
 END IF

 END FUNCTION

#----------------------------#
 FUNCTION esp1660_consulta()
#----------------------------#
 CALL log006_exibe_teclas('01 02 03', p_versao)
 CURRENT WINDOW IS w_esp1660

 LET where_clause =  NULL
 LET INT_FLAG = FALSE

 INITIALIZE mr_tela.* TO NULL
 CLEAR FORM
 DISPLAY p_cod_empresa TO cod_empresa

 CONSTRUCT BY NAME where_clause ON cod_categoria, den_categoria, peso_bruto

 END CONSTRUCT

 CALL log006_exibe_teclas('01', p_versao)
 CURRENT WINDOW IS w_esp1660

 IF INT_FLAG THEN
    LET int_flag = FALSE
    ERROR 'Consulta cancelada. '
    RETURN FALSE
 END IF

 CALL log006_exibe_teclas('01 09', p_versao)
 CURRENT WINDOW IS w_esp1660

 RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION esp1660_prepara_consulta()
#-----------------------------------#
 LET sql_stmt = "SELECT cod_categoria, den_categoria, peso_bruto, perc_tolerancia, bloq_pesagem ",
                "  FROM esp_categ_veiculos ",
                " WHERE cod_empresa = """,p_cod_empresa, """ ",
                "   AND ",where_clause CLIPPED,
                " ORDER BY cod_categoria "

 CALL log0810_prepare_sql(sql_stmt) RETURNING sql_stmt

 WHENEVER ERROR CONTINUE
 PREPARE var_categoria FROM sql_stmt
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("PREPARE","VAR_CATEGORIA")
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cl_categoria SCROLL CURSOR WITH HOLD FOR var_categoria
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("declare","CL_CATEGORIA")
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 OPEN  cl_categoria
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("OPEN","CL_CATEGORIA")
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 FETCH cl_categoria INTO mr_tela.cod_categoria, mr_tela.den_categoria, mr_tela.peso_bruto,
                         mr_tela.perc_tolerancia, mr_tela.bloq_pesagem
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
 FUNCTION esp1660_paginacao(l_funcao)
#-------------------------------------#
 DEFINE l_funcao  CHAR(010)

 WHILE TRUE
     IF l_funcao = 'SEGUINTE' THEN
        FETCH NEXT     cl_categoria INTO mr_tela.cod_categoria, mr_tela.den_categoria, mr_tela.peso_bruto,
                                         mr_tela.perc_tolerancia, mr_tela.bloq_pesagem
     ELSE
        FETCH PREVIOUS cl_categoria INTO mr_tela.cod_categoria, mr_tela.den_categoria, mr_tela.peso_bruto,
                                         mr_tela.perc_tolerancia, mr_tela.bloq_pesagem
     END IF

     IF sqlca.sqlcode = 0 THEN
        WHENEVER ERROR CONTINUE
         SELECT cod_categoria, den_categoria, peso_bruto, perc_tolerancia, bloq_pesagem
           INTO mr_tela.cod_categoria, mr_tela.den_categoria, mr_tela.peso_bruto,
                mr_tela.perc_tolerancia, mr_tela.bloq_pesagem
           FROM esp_categ_veiculos
          WHERE cod_empresa   = p_cod_empresa
            AND cod_categoria = mr_tela.cod_categoria
          ORDER BY cod_categoria
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode = 0 THEN
           EXIT WHILE
        END IF
     ELSE
        ERROR ' Não existem mais itens nesta direção. '
        EXIT WHILE
     END IF
 END WHILE
 CALL esp1660_exibe_dados()

 END FUNCTION

#----------------------------#
 FUNCTION esp1660_listar()
#----------------------------#
 DEFINE lr_relat    RECORD
                      cod_categoria    LIKE esp_categ_veiculos.cod_categoria,
                      den_categoria    LIKE esp_categ_veiculos.den_categoria,
                      peso_bruto       LIKE esp_categ_veiculos.peso_bruto,
                      perc_tolerancia  LIKE esp_categ_veiculos.perc_tolerancia,
                      bloq_pesagem     LIKE esp_categ_veiculos.bloq_pesagem
                    END RECORD

 DEFINE l_tot_reg   SMALLINT,
        l_mensagem  CHAR(200)

 MESSAGE " Processando a extração do relatório ... " ATTRIBUTE(REVERSE)

 IF p_ies_impressao = "S" THEN
    IF g_ies_ambiente = "W" THEN
       CALL log150_procura_caminho("LST") RETURNING p_caminho
       LET p_caminho = p_caminho CLIPPED, "esp1660.tmp"
       START REPORT esp1660_relat TO p_caminho
    ELSE
       START REPORT esp1660_relat TO PIPE p_nom_arquivo
    END IF
 ELSE
    START REPORT esp1660_relat TO p_nom_arquivo
 END IF

 WHENEVER ERROR CONTINUE
  SELECT den_empresa
    INTO m_den_empresa
    FROM empresa
   WHERE cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP

 LET l_tot_reg = 0

 WHENEVER ERROR CONTINUE
 DECLARE cl_categoria2 CURSOR FOR
  SELECT cod_categoria, den_categoria, peso_bruto, perc_tolerancia, bloq_pesagem
    FROM esp_categ_veiculos
   WHERE cod_empresa   = p_cod_empresa
   ORDER BY cod_categoria
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 FOREACH cl_categoria2 INTO lr_relat.cod_categoria, lr_relat.den_categoria, lr_relat.peso_bruto,
                            lr_relat.perc_tolerancia, lr_relat.bloq_pesagem
 WHENEVER ERROR STOP

      OUTPUT TO REPORT esp1660_relat(lr_relat.*)
      LET l_tot_reg = l_tot_reg + 1

 END FOREACH
 FREE cl_balanca2

 FINISH REPORT esp1660_relat

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
 REPORT esp1660_relat(lr_relat)
#-------------------------------#
 DEFINE lr_relat    RECORD
                      cod_categoria    LIKE esp_categ_veiculos.cod_categoria,
                      den_categoria    LIKE esp_categ_veiculos.den_categoria,
                      peso_bruto       LIKE esp_categ_veiculos.peso_bruto,
                      perc_tolerancia  LIKE esp_categ_veiculos.perc_tolerancia,
                      bloq_pesagem     LIKE esp_categ_veiculos.bloq_pesagem
                    END RECORD

 DEFINE l_last_row  SMALLINT,
        l_bloq      CHAR(03)

 OUTPUT LEFT MARGIN 0
        TOP MARGIN 0
        BOTTOM MARGIN 0
        PAGE LENGTH 66

 FORMAT
     PAGE HEADER
       PRINT log5211_retorna_configuracao(PAGENO,66,85) CLIPPED;
       PRINT COLUMN 001, m_den_empresa
       PRINT COLUMN 001, 'ESP1660',
             COLUMN 028, 'RELATORIO CATEGORIA VEICULOS',
             COLUMN 076, 'FL. ', PAGENO USING '####'
       PRINT COLUMN 045, 'EXTRAIDO EM ', TODAY USING 'dd/mm/yyyy', ' AS ', TIME, ' HRS.'
       SKIP 1 LINE
       PRINT COLUMN 001, "CATEGORIA DESCRICAO CATEGORIA                       PESO BRUTO % TOLER BLOQ PESAGEM"
       PRINT COLUMN 001, "--------- ---------------------------------------- ----------- ------- ------------"

     ON EVERY ROW
       IF lr_relat.bloq_pesagem = "S" THEN
          LET l_bloq = "SIM"
       ELSE
          LET l_bloq = "NAO"
       END IF

       PRINT COLUMN 001, lr_relat.cod_categoria     CLIPPED,
             COLUMN 011, lr_relat.den_categoria     CLIPPED,
             COLUMN 052, lr_relat.peso_bruto        USING "#######&.&&",
             COLUMN 064, lr_relat.perc_tolerancia   USING "##&.&&",
             COLUMN 076, l_bloq

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
 FUNCTION esp1660_version_info()
#-------------------------------#
  RETURN "$Archive: esp1660.4gl $|$Revision: 1 $|$Date: 21/07/13 17:12 $|$Modtime: 21/07/13 16:54 $"

 END FUNCTION
