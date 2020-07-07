#---------------------------------------------------------------------------#
# SISTEMA.: ESPECIFICO                                                      #
# PROGRAMA: ESP1554                                                         #
# OBJETIVO: CADASTRO DE VEICULOS GRUPO RONCADOR                             #
# AUTOR...: LUCAS HENRIQUE                                                  #
# DATA....: 16/01/2012                                                      #
#---------------------------------------------------------------------------#
DATABASE logix

GLOBALS

   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          comando                  CHAR(80)

   DEFINE p_versao                 CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

#MODULARES

 DEFINE m_consulta_ativa         SMALLINT

 DEFINE mr_tela,mr_telar  RECORD
                        veiculo            LIKE esp_balanca_veiculo.veiculo
                       ,placa              LIKE esp_balanca_veiculo.placa
                       ,modelo             LIKE esp_balanca_veiculo.modelo
                       ,tara               LIKE esp_balanca_veiculo.tara
                       ,cod_categoria      LIKE esp_categ_veiculos.cod_categoria
                       ,den_categoria      LIKE esp_categ_veiculos.den_categoria
                       ,veic_ntrac1        LIKE esp_balanca_veiculo.veic_ntrac1
                       ,placa1             LIKE esp_balanca_veiculo.placa1
                       ,veic_ntrac2        LIKE esp_balanca_veiculo.veic_ntrac2
                       ,placa2             LIKE esp_balanca_veiculo.placa2
                       ,veic_ntrac3        LIKE esp_balanca_veiculo.veic_ntrac3
                       ,placa3             LIKE esp_balanca_veiculo.placa3
                       ,veic_ntrac4        LIKE esp_balanca_veiculo.veic_ntrac4
                       ,placa4             LIKE esp_balanca_veiculo.placa4
                       ,nom_proprietario   LIKE esp_balanca_veiculo.nom_proprietario
                       ,observacao_veiculo LIKE esp_balanca_veiculo.observacao_veiculo
                       ,veiculo_tracionad  LIKE esp_balanca_veiculo.veiculo_tracionad
                     END RECORD

 DEFINE m_veiculo LIKE esp_balanca_veiculo.veiculo
 DEFINE m_placa   LIKE esp_balanca_veiculo.placa
#END MODULARES

MAIN

   LET p_versao = "ESP1554-10.00.10" #Favor nao alterar esta linha (SUPORTE)

   CALL log1400_isolation()

   DEFER INTERRUPT
   CALL log140_procura_caminho("esp1554.iem") RETURNING comando
   OPTIONS
      FIELD    ORDER UNCONSTRAINED,
      HELP     FILE  comando,
      HELP     KEY   control-w,
      NEXT     KEY   control-f,
      PREVIOUS KEY   control-b

   CALL log001_acessa_usuario("VDP", "LOGERP")
     RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL esp1554_controle()
   END IF

END MAIN

#----------------------------#
FUNCTION esp1554_controle()
#----------------------------#

   CALL log006_exibe_teclas("01 03",p_versao)
   INITIALIZE comando TO NULL
   LET m_consulta_ativa = FALSE
   CALL log130_procura_caminho("esp1554") RETURNING comando

   OPEN WINDOW w_esp1554 AT 2,2 WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPÇÃO"
      COMMAND "Incluir" " Inclui novos veículos. "
         HELP 001
         MESSAGE ""
         IF  log005_seguranca(p_user,"SUP","esp1554","IN") THEN
            CALL esp1554_incluir()
         END IF
      COMMAND "Modificar" " Modifica veículos cadastrados. "
         HELP 002
         MESSAGE ""
         IF  log005_seguranca(p_user,"SUP","esp1554","MO") THEN
           IF m_consulta_ativa THEN
              CALL esp1554_modificar()
           ELSE
              CALL log0030_mensagem( " Execute uma consulta previamente. ","info")
           END IF
         END IF
      COMMAND "Excluir"  "Exclui veículos. "
         HELP 003
         MESSAGE ""
         IF  log005_seguranca(p_user,"SUP","esp1554","EX") THEN
           IF m_consulta_ativa THEN
              CALL esp1554_excluir()
           ELSE
              CALL log0030_mensagem( " Execute uma consulta previamente. ","info")
           END IF
         END IF
      COMMAND "Consultar"    "Consultar veículos cadastrados. "
         HELP 004
         MESSAGE ""
         IF  log005_seguranca(p_user,"SUP","esp1554","CO") THEN
            CALL esp1554_consulta()
         END IF
      COMMAND "Seguinte" "Exibe próximo registro."
         MESSAGE ""
         LET INT_FLAG = 0
         IF m_consulta_ativa THEN
            CALL esp1554_paginacao('SEGUINTE')
         ELSE
             CALL log0030_mensagem("Efetue a Consulta Previamente", "info")
            NEXT OPTION "Consultar"
         END IF
      COMMAND "Anterior" "Exibe registro anterior."
         LET INT_FLAG = 0
         MESSAGE ""
         IF m_consulta_ativa THEN
            CALL esp1554_paginacao('ANTERIOR')
         ELSE
             CALL log0030_mensagem("Efetue a Consulta Previamente", "info")
            NEXT OPTION "Consultar"
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim"        "Retorna ao menu anterior."
         HELP 007
      EXIT MENU

#lds COMMAND KEY ("control-F1") "Sobre" "Informações sobre a aplicação (CTRL-F1)."
#lds CALL esp_info_sobre(sourceName(),p_versao)

   END MENU
   CLOSE WINDOW w_esp1554

END FUNCTION

#--------------------------------#
FUNCTION esp1554_incluir()
#--------------------------------#

   DEFINE lr_tela         RECORD LIKE esp_balanca_veiculo.*
   DEFINE l_erro                        SMALLINT


   INITIALIZE mr_tela.* TO NULL
   INITIALIZE lr_tela.* TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   IF esp1554_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")

      LET lr_tela.cod_empresa        = p_cod_empresa
      LET lr_tela.veiculo            = mr_tela.veiculo
      LET lr_tela.placa              = mr_tela.placa
      LET lr_tela.modelo             = mr_tela.modelo
      LET lr_tela.tara               = mr_tela.tara
      LET lr_tela.veiculo_tracionad  = mr_tela.veiculo_tracionad
      LET lr_tela.veic_ntrac1        = mr_tela.veic_ntrac1
      LET lr_tela.placa1             = mr_tela.placa1
      LET lr_tela.veic_ntrac2        = mr_tela.veic_ntrac2
      LET lr_tela.placa2             = mr_tela.placa2
      LET lr_tela.veic_ntrac3        = mr_tela.veic_ntrac3
      LET lr_tela.placa3             = mr_tela.placa3
      LET lr_tela.veic_ntrac4        = mr_tela.veic_ntrac4
      LET lr_tela.placa4             = mr_tela.placa4
      LET lr_tela.nom_proprietario   = mr_tela.nom_proprietario
      LET lr_tela.observacao_veiculo = mr_tela.observacao_veiculo
      LET lr_tela.cod_categoria      = mr_tela.cod_categoria

         WHENEVER ERROR CONTINUE
         INSERT INTO esp_balanca_veiculo  VALUES (lr_tela.*)
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INCLUSAO","esp_balanca_veiculo")
            LET l_erro = TRUE
         END IF

      IF l_erro = TRUE THEN
         CALL log085_transacao("ROLLBACK")
         CALL log0030_mensagem("Inclusão cancelada.","info")
         RETURN FALSE
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE " Inclusao efetuada com sucesso. " ATTRIBUTE(REVERSE)
         LET m_consulta_ativa = FALSE
         RETURN TRUE
      END IF
   ELSE
      CALL esp1554_exibe_dados()
      CALL log0030_mensagem("Inclusão cancelada.","info")
      LET m_consulta_ativa = FALSE
      CLEAR FORM
      CURRENT WINDOW IS w_esp1554
   END IF
END FUNCTION

#----------------------------------------#
 FUNCTION esp1554_entrada_dados(l_funcao)
#----------------------------------------#

   DEFINE l_funcao 		           CHAR(20)
   DEFINE l_cod_veiculo         INTEGER

   IF l_funcao = "INCLUSAO" THEN
      INITIALIZE mr_tela.* TO NULL
   END IF

   CALL log006_exibe_teclas("01 02 03 07", p_versao)
   CURRENT WINDOW IS w_esp1554

   DISPLAY p_cod_empresa TO cod_empresa
   LET l_cod_veiculo = 0

   INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

      BEFORE INPUT
       IF l_funcao = "MODIFICAR" THEN
          NEXT FIELD placa
       END IF

   BEFORE FIELD veiculo
      IF l_funcao = 'INCLUSAO' THEN
         SELECT DISTINCT max(veiculo)
           INTO l_cod_veiculo
           FROM esp_balanca_veiculo
          WHERE cod_empresa = p_cod_empresa

          IF l_cod_veiculo IS NULL
          OR l_cod_veiculo = 0 THEN
             LET mr_tela.veiculo = 1
             DISPLAY mr_tela.veiculo TO veiculo
             NEXT FIELD placa
          ELSE
             LET mr_tela.veiculo = l_cod_veiculo + 1
             DISPLAY mr_tela.veiculo TO veiculo
             NEXT FIELD placa
          END IF
      END IF

      AFTER FIELD placa
       IF mr_tela.placa IS NULL
       OR mr_tela.placa = " " THEN
          CALL log0030_mensagem("Informe o campo PLACA.","info")
          NEXT FIELD placa
       END IF

      IF l_funcao = "INCLUSAO" THEN
       SELECT placa
         FROM esp_balanca_veiculo
        WHERE cod_empresa = p_cod_empresa
          AND placa = mr_tela.placa
       IF sqlca.sqlcode = 0 THEN
          CALL log0030_mensagem("PLACA ja cadastrado para empresa. ","info")
          NEXT FIELD placa
       END IF
     END IF

     IF l_funcao = "MODIFICAR" THEN
        IF mr_tela.placa <> m_placa THEN
          SELECT placa
            FROM esp_balanca_veiculo
           WHERE cod_empresa = p_cod_empresa
             AND placa = mr_tela.placa
           IF sqlca.sqlcode = 0 THEN
              CALL log0030_mensagem("PLACA ja cadastrado para empresa. ","info")
              NEXT FIELD placa
           END IF
        END IF
     END IF

     AFTER FIELD tara
       IF mr_tela.tara IS NULL
       OR mr_tela.tara = " " THEN
          CALL log0030_mensagem("Informe o campo TARA.","info")
          NEXT FIELD tara
       END IF

     BEFORE FIELD cod_categoria
        CALL esp1554_zoom(TRUE)

     AFTER FIELD cod_categoria
        CALL esp1554_zoom(FALSE)

        IF mr_tela.cod_categoria IS NOT NULL THEN
           IF NOT esp1554_verifica_categoria() THEN
              CALL log0030_mensagem("Categoria não cadastrada.","info")
              NEXT FIELD cod_categoria
           END IF
        ELSE
           CALL log0030_mensagem("Categoria deve ser informada.","info")
           NEXT FIELD cod_categoria
        END IF

     BEFORE FIELD veiculo_tracionad
       IF mr_tela.tara IS NULL
       OR mr_tela.tara = " " THEN
          CALL log0030_mensagem("Informe o campo TARA.","info")
          NEXT FIELD tara
       END IF

     AFTER FIELD veiculo_tracionad
          IF mr_tela.veiculo_tracionad IS NULL
          OR mr_tela.veiculo_tracionad = " " THEN
            CALL log0030_mensagem("Informe o campo VEIC TRAC.","info")
            NEXT FIELD veiculo_tracionad
          END IF

          IF mr_tela.veiculo_tracionad = 'N' THEN
             LET mr_tela.veic_ntrac1 = NULL
             LET mr_tela.placa1      = NULL
             LET mr_tela.veic_ntrac2 = NULL
             LET mr_tela.placa2      = NULL
             LET mr_tela.veic_ntrac3 = NULL
             LET mr_tela.placa3      = NULL
             LET mr_tela.veic_ntrac4 = NULL
             LET mr_tela.placa4      = NULL

             DISPLAY BY NAME mr_tela.veic_ntrac1
             DISPLAY BY NAME mr_tela.placa1
             DISPLAY BY NAME mr_tela.veic_ntrac2
             DISPLAY BY NAME mr_tela.placa2
             DISPLAY BY NAME mr_tela.veic_ntrac3
             DISPLAY BY NAME mr_tela.placa3
             DISPLAY BY NAME mr_tela.veic_ntrac4
             DISPLAY BY NAME mr_tela.placa4

             NEXT FIELD nom_proprietario
          END IF

     BEFORE FIELD veic_ntrac1
        CALL esp1554_zoom(TRUE)

     AFTER FIELD veic_ntrac1
       IF mr_tela.veiculo_tracionad = 'S' THEN
          IF mr_tela.veic_ntrac1 IS NULL
          OR mr_tela.veic_ntrac1 = "" THEN
            CALL log0030_mensagem("VEIC TRAC 1 deve ser informo...","info")
            NEXT FIELD veic_ntrac1
          END IF
       END IF

          IF mr_tela.veic_ntrac1 IS NOT NULL
          OR mr_tela.veic_ntrac1 <> " " THEN
             SELECT placa
               INTO mr_tela.placa1
               FROM esp_balanca_veiculo
              WHERE cod_empresa = p_cod_empresa
                AND veiculo     = mr_tela.veic_ntrac1
                AND veiculo_tracionad = 'N'
             IF sqlca.sqlcode = 0 THEN
                DISPLAY BY NAME mr_tela.placa1
                NEXT FIELD veic_ntrac2
             ELSE
               CALL log0030_mensagem("VEIC TRAC 1 nao encontrado","info")
               NEXT FIELD veic_ntrac1
             END IF
          END IF

      AFTER FIELD placa1
       IF mr_tela.veiculo_tracionad = 'S' THEN
          IF mr_tela.placa1 IS NULL
          OR mr_tela.placa1 = " " THEN
                CALL log0030_mensagem("PLACA nao pode ser nulo.","info")
                NEXT FIELD veic_ntrac1
          END IF
       END IF

        IF mr_tela.placa1 IS NOT NULL
        OR mr_tela.placa1 <> ' '  THEN
           SELECT veiculo
             INTO mr_tela.veic_ntrac1
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND placa  = mr_tela.placa1
              AND veiculo_tracionad = 'N'

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_mensagem("VEICULO nao encontrado.","info")
              NEXT FIELD veic_ntrac1
           ELSE
              DISPLAY BY NAME mr_tela.veic_ntrac1
           END IF
        END IF

     BEFORE FIELD veic_ntrac2
       IF mr_tela.veic_ntrac1 IS NULL
       OR mr_tela.veic_ntrac1 = " " THEN
          CALL log0030_mensagem("VEIC TRAC 1 nao pode ser nulo.","info")
          NEXT FIELD veic_ntrac1
       END IF
       CALL esp1554_zoom(TRUE)

     AFTER FIELD veic_ntrac2
       IF mr_tela.veic_ntrac2 = mr_tela.veic_ntrac1 THEN
          CALL log0030_mensagem("VEIC TRAC 2 nao pode ser o mesmo","info")
          NEXT FIELD veic_ntrac2
       END IF

       IF mr_tela.veic_ntrac2 IS NOT NULL
       OR mr_tela.veic_ntrac2 <> " " THEN
          SELECT placa
            INTO mr_tela.placa2
            FROM esp_balanca_veiculo
           WHERE cod_empresa = p_cod_empresa
             AND veiculo     = mr_tela.veic_ntrac2
             AND veiculo_tracionad = 'N'
          IF sqlca.sqlcode = 0 THEN
             DISPLAY BY NAME mr_tela.placa2
             NEXT FIELD veic_ntrac3
          ELSE
            CALL log0030_mensagem("VEIC TRAC 2 nao encontrado","info")
            NEXT FIELD veic_ntrac2
          END IF
       END IF

     AFTER FIELD placa2
        IF mr_tela.placa2 = mr_tela.placa1 THEN
              CALL log0030_mensagem("VEIC TRAC 2 nao pode ser o mesmo","info")
              NEXT FIELD veic_ntrac2
        END IF

        IF mr_tela.placa2 IS NOT NULL
        OR mr_tela.placa2 <> ' '  THEN
           SELECT veiculo
             INTO mr_tela.veic_ntrac2
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND placa  = mr_tela.placa2
              AND veiculo_tracionad = 'N'

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_mensagem("VEICULO nao encontrado.","info")
              NEXT FIELD veic_ntrac2
           ELSE
              DISPLAY BY NAME mr_tela.veic_ntrac2
           END IF
        END IF

     BEFORE FIELD veic_ntrac3
        CALL esp1554_zoom(TRUE)

     AFTER FIELD veic_ntrac3
       IF mr_tela.veic_ntrac3 = mr_tela.veic_ntrac1
       OR mr_tela.veic_ntrac3 = mr_tela.veic_ntrac2  THEN
          CALL log0030_mensagem("VEIC TRAC 3 nao pode ser o mesmo","info")
          NEXT FIELD veic_ntrac3
       END IF

       IF mr_tela.veic_ntrac3 IS NOT NULL
       OR mr_tela.veic_ntrac3 <> " " THEN
          SELECT placa
            INTO mr_tela.placa3
            FROM esp_balanca_veiculo
           WHERE cod_empresa = p_cod_empresa
             AND veiculo     = mr_tela.veic_ntrac3
             AND veiculo_tracionad = 'N'
          IF sqlca.sqlcode = 0 THEN
             DISPLAY BY NAME mr_tela.placa3
             NEXT FIELD veic_ntrac4
          ELSE
            CALL log0030_mensagem("VEIC TRAC 3 nao encontrado","info")
            NEXT FIELD veic_ntrac3
          END IF
      END IF

     AFTER FIELD placa3
        IF mr_tela.placa3 = mr_tela.placa1
        OR mr_tela.placa3 = mr_tela.placa2 THEN
              CALL log0030_mensagem("VEIC TRAC 3 nao pode ser o mesmo","info")
              NEXT FIELD veic_ntrac3
        END IF

        IF mr_tela.placa3 IS NOT NULL
        OR mr_tela.placa3 <> ' '  THEN
           SELECT veiculo
             INTO mr_tela.veic_ntrac3
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND placa  = mr_tela.placa3
              AND veiculo_tracionad = 'N'

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_mensagem("VEICULO nao encontrado.","info")
              NEXT FIELD veic_ntrac3
           ELSE
              DISPLAY BY NAME mr_tela.veic_ntrac3
           END IF
        END IF

     BEFORE FIELD veic_ntrac4
        CALL esp1554_zoom(TRUE)

     AFTER FIELD veic_ntrac4
      IF mr_tela.veic_ntrac4 = mr_tela.veic_ntrac1
      OR mr_tela.veic_ntrac4 = mr_tela.veic_ntrac2
      OR mr_tela.veic_ntrac4 = mr_tela.veic_ntrac3 THEN
         CALL log0030_mensagem("VEIC TRAC 4 nao pode ser o mesmo","info")
         NEXT FIELD veic_ntrac4
      END IF

       IF mr_tela.veic_ntrac4 IS NOT NULL
       OR mr_tela.veic_ntrac4 <> " " THEN
          SELECT placa
            INTO mr_tela.placa4
            FROM esp_balanca_veiculo
           WHERE cod_empresa = p_cod_empresa
             AND veiculo     = mr_tela.veic_ntrac4
             AND veiculo_tracionad = 'N'
          IF sqlca.sqlcode = 0 THEN
             DISPLAY BY NAME mr_tela.placa4
#             NEXT FIELD veic_ntrac4
          ELSE
            CALL log0030_mensagem("VEIC TRAC 4 nao encontrado","info")
            NEXT FIELD veic_ntrac4
          END IF
      END IF

     BEFORE FIELD placa4
       IF mr_tela.veiculo_tracionad = 'N' THEN
          NEXT FIELD nom_proprietario
       END IF

     AFTER FIELD placa4
        IF mr_tela.placa4 = mr_tela.placa1
        OR mr_tela.placa4 = mr_tela.placa2
        OR mr_tela.placa4 = mr_tela.placa3 THEN
              CALL log0030_mensagem("VEIC TRAC 4 nao pode ser o mesmo","info")
              NEXT FIELD veic_ntrac4
        END IF

        IF mr_tela.placa4 IS NOT NULL
        OR mr_tela.placa4 <> ' '  THEN
           SELECT veiculo
             INTO mr_tela.veic_ntrac4
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND placa  = mr_tela.placa4
              AND veiculo_tracionad = 'N'

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_mensagem("VEICULO nao encontrado.","info")
              NEXT FIELD veic_ntrac4
           ELSE
              DISPLAY BY NAME mr_tela.veic_ntrac4
           END IF
        END IF


   AFTER INPUT

    IF NOT INT_FLAG THEN
       IF l_funcao = 'INCLUSAO' THEN

         IF mr_tela.placa IS NULL
         OR mr_tela.placa = " " THEN
            CALL log0030_mensagem("Informe o campo PLACA","info")
            NEXT FIELD placa
         END IF

         IF mr_tela.tara IS NULL
         OR mr_tela.tara = " " THEN
            CALL log0030_mensagem("Informe o campo TARA","info")
            NEXT FIELD tara
         END IF

         IF mr_tela.veiculo_tracionad IS NULL
         OR mr_tela.veiculo_tracionad = " " THEN
            CALL log0030_mensagem("Informe o campo VEIC TRAC","info")
            NEXT FIELD veiculo_tracionad
         END IF

       IF mr_tela.veiculo_tracionad = 'S' THEN
          IF mr_tela.veic_ntrac1 IS NULL
          OR mr_tela.veic_ntrac1 = " "
          AND mr_tela.placa1 IS NULL
          OR mr_tela.placa1 = " " THEN
             CALL log0030_mensagem("VEICULO/PLACA nao pode ser nulo.","info")
             NEXT FIELD veic_ntrac1
          END IF
       END IF
    END IF

 END IF

    IF mr_tela.placa1 IS NOT NULL OR mr_tela.placa1 <> " " THEN
       SELECT placa
        INTO mr_tela.placa1
        FROM esp_balanca_veiculo
       WHERE cod_empresa = p_cod_empresa
        AND veiculo     = mr_tela.veic_ntrac1
        AND veiculo_tracionad = 'N'
       IF sqlca.sqlcode = 0 THEN
          DISPLAY BY NAME mr_tela.placa1
       ELSE
          CALL log0030_mensagem("VEIC TRAC 1 nao encontrado","info")
          NEXT FIELD veic_ntrac1
       END IF
    END IF

    IF mr_tela.placa2 IS NOT NULL OR mr_tela.placa2 <> " " THEN
       SELECT placa
        INTO mr_tela.placa2
        FROM esp_balanca_veiculo
       WHERE cod_empresa = p_cod_empresa
        AND veiculo     = mr_tela.veic_ntrac2
        AND veiculo_tracionad = 'N'
       IF sqlca.sqlcode = 0 THEN
          DISPLAY BY NAME mr_tela.placa2
       ELSE
          CALL log0030_mensagem("VEIC TRAC 2 nao encontrado","info")
          NEXT FIELD veic_ntrac2
       END IF

    IF mr_tela.placa3 IS NOT NULL OR mr_tela.placa3 <> " " THEN
       SELECT placa
        INTO mr_tela.placa3
        FROM esp_balanca_veiculo
       WHERE cod_empresa = p_cod_empresa
        AND veiculo     = mr_tela.veic_ntrac3
        AND veiculo_tracionad = 'N'
       IF sqlca.sqlcode = 0 THEN
          DISPLAY BY NAME mr_tela.placa3
       ELSE
          CALL log0030_mensagem("VEIC TRAC 3 nao encontrado","info")
          NEXT FIELD veic_ntrac3
       END IF
    END IF

    IF mr_tela.placa4 IS NOT NULL OR mr_tela.placa4 <> " " THEN
       SELECT placa
        INTO mr_tela.placa4
        FROM esp_balanca_veiculo
       WHERE cod_empresa = p_cod_empresa
        AND veiculo     = mr_tela.veic_ntrac4
        AND veiculo_tracionad = 'N'
       IF sqlca.sqlcode = 0 THEN
          DISPLAY BY NAME mr_tela.placa4
       ELSE
          CALL log0030_mensagem("VEIC TRAC 4 nao encontrado","info")
           NEXT FIELD veic_ntrac4
       END IF
    END IF
 END IF

    ON KEY (control-z)
       CALL esp1554_popup()

   END INPUT

   IF INT_FLAG = TRUE THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION esp1554_zoom(l_ativa)
#-------------------------------#
 DEFINE l_ativa    SMALLINT

 IF l_ativa THEN
    --# CALL fgl_dialog_setkeylabel('control-z',"Zoom")
 ELSE
    --# CALL fgl_dialog_setkeylabel('control-z',"")
 END IF

 END FUNCTION

#---------------------------------------#
 FUNCTION esp1554_verifica_categoria()
#---------------------------------------#
 LET mr_tela.den_categoria = NULL

 WHENEVER ERROR CONTINUE
  SELECT den_categoria
    INTO mr_tela.den_categoria
    FROM esp_categ_veiculos
   WHERE cod_empresa   = p_cod_empresa
     AND cod_categoria = mr_tela.cod_categoria
 WHENEVER ERROR STOP

 DISPLAY BY NAME mr_tela.den_categoria

 IF SQLCA.SQLCODE <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#-----------------------------#
FUNCTION esp1554_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_tela.*

   LET m_veiculo = mr_tela.veiculo
   LET m_placa   = mr_tela.placa

   CALL esp1554_verifica_categoria() RETURNING p_status

END FUNCTION

#------------------------------#
FUNCTION esp1554_consulta()
#------------------------------#
 DEFINE l_where_clause, l_sql_stmt   CHAR(500)

   INITIALIZE l_where_clause, l_sql_stmt TO NULL

   CALL log006_exibe_teclas("01 02",p_versao)
   CURRENT WINDOW IS w_esp1554
   LET INT_FLAG = FALSE
   LET mr_telar.* = mr_tela.*
   INITIALIZE mr_tela.* TO NULL
   CLEAR FORM

   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME l_where_clause ON esp_balanca_veiculo.veiculo,
                                       esp_balanca_veiculo.placa

   END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp1554

   IF INT_FLAG = TRUE THEN
      LET INT_FLAG = 0
      LET mr_tela.* = mr_telar.*
      ERROR "Consulta Cancelada"
      INITIALIZE mr_tela.* TO NULL
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET m_consulta_ativa = FALSE
      RETURN
   END IF

    LET l_sql_stmt = "SELECT veiculo, placa, modelo, tara, veiculo_tracionad, ",
                     " veic_ntrac1, placa1, veic_ntrac2, placa2, ",
                     " veic_ntrac3, placa3, veic_ntrac4, placa4, ",
                     " nom_proprietario, observacao_veiculo, cod_categoria ",
                    "  FROM esp_balanca_veiculo ",
                    " WHERE cod_empresa = ", log0800_string(p_cod_empresa),
                    "   AND ", l_where_clause CLIPPED,
                    " ORDER BY veiculo "

   PREPARE var_query FROM l_sql_stmt
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_consulta
   FETCH cq_consulta INTO mr_tela.veiculo
                         ,mr_tela.placa
                         ,mr_tela.modelo
                         ,mr_tela.tara
                         ,mr_tela.veiculo_tracionad
                         ,mr_tela.veic_ntrac1
                         ,mr_tela.placa1
                         ,mr_tela.veic_ntrac2
                         ,mr_tela.placa2
                         ,mr_tela.veic_ntrac3
                         ,mr_tela.placa3
                         ,mr_tela.veic_ntrac4
                         ,mr_tela.placa4
                         ,mr_tela.nom_proprietario
                         ,mr_tela.observacao_veiculo
                         ,mr_tela.cod_categoria

   IF sqlca.sqlcode = NOTFOUND  THEN
      CALL log0030_mensagem( " Argumentos de pesquisa nao encontrados. ","info")
      LET m_consulta_ativa = FALSE
      RETURN
   ELSE
      LET m_consulta_ativa = TRUE
      CALL esp1554_exibe_dados()
      CALL log0030_mensagem("Consulta efetuada com sucesso. ","info")
   END IF

END FUNCTION

#----------------------------------#
FUNCTION esp1554_cursor_for_update()
#----------------------------------#

   DECLARE cq_update CURSOR FOR
    SELECT *
      FROM esp_balanca_veiculo
     WHERE cod_empresa = p_cod_empresa
       AND veiculo     = mr_tela.veiculo
   FOR UPDATE

   CALL log085_transacao("BEGIN")
   OPEN cq_update
   FETCH cq_update
   CASE
      WHEN sqlca.sqlcode = 0
         RETURN TRUE
      WHEN sqlca.sqlcode = -250
         CALL log0030_mensagem("Registro sendo atualizado por outro usuario. Aguarde e tente novamente.", "exclamation")
      WHEN sqlca.sqlcode = 100
         CALL log0030_mensagem("Registro não encontrado, efetue a consulta novamente", "exclamation")
      OTHERWISE
         CALL log003_err_sql("FETCH","esp_balanca_veiculo")
   END CASE

   CLOSE cq_update
   CALL log085_transacao("ROLLBACK")
   RETURN FALSE

END FUNCTION

#----------------------------#
FUNCTION esp1554_modificar()
#----------------------------#

 DEFINE l_erro    SMALLINT

   IF esp1554_cursor_for_update() = TRUE THEN
     LET mr_telar.* = mr_tela.*

     IF esp1554_entrada_dados("MODIFICAR") THEN
        CALL log085_transacao("BEGIN")
        WHENEVER ERROR CONTINUE
          DELETE FROM esp_balanca_veiculo
           WHERE cod_empresa = p_cod_empresa
             AND veiculo = m_veiculo
        WHENEVER ERROR STOP

        WHENEVER ERROR CONTINUE
         INSERT INTO esp_balanca_veiculo VALUES (p_cod_empresa
                                                ,mr_tela.veiculo
                                                ,mr_tela.placa
                                                ,mr_tela.modelo
                                                ,mr_tela.tara
                                                ,mr_tela.veiculo_tracionad
                                                ,mr_tela.veic_ntrac1
                                                ,mr_tela.placa1
                                                ,mr_tela.veic_ntrac2
                                                ,mr_tela.placa2
                                                ,mr_tela.veic_ntrac3
                                                ,mr_tela.placa3
                                                ,mr_tela.veic_ntrac4
                                                ,mr_tela.placa4
                                                ,mr_tela.nom_proprietario
                                                ,mr_tela.observacao_veiculo
                                                ,mr_tela.cod_categoria )
        WHENEVER ERROR STOP

         IF sqlca.sqlcode = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE " Modificação efetuada com sucesso. " ATTRIBUTE(REVERSE)
            DISPLAY BY NAME mr_tela.*
         ELSE
            CALL log003_err_sql("MODIFICAR","esp_balanca_veiculo")
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         CALL esp1554_exibe_dados()
         ERROR " MODIFICAR Cancelada. "
      END IF
   END IF

END FUNCTION

#----------------------------#
 FUNCTION esp1554_excluir()
#----------------------------#

   IF log0040_confirm(10,10,'Confirma exclusão?' ) = FALSE THEN
      ERROR "Exclusao cancelada."
      RETURN
   END IF

   WHENEVER ERROR CONTINUE
   DELETE FROM esp_balanca_veiculo
    WHERE cod_empresa = p_cod_empresa
      AND veiculo = mr_tela.veiculo
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('DELETE','esp_balanca_veiculo')
      CALL log085_transacao('ROLLBACK')
      MESSAGE ' '
   ELSE
      CALL log085_transacao('COMMIT')
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET m_consulta_ativa = FALSE
      MESSAGE 'Exclusão efetuada com sucesso.'
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION esp1554_paginacao(l_funcao)
#----------------------------------------#
   DEFINE l_funcao             CHAR(15)

   WHILE TRUE
      IF l_funcao = 'SEGUINTE' THEN
         FETCH NEXT cq_consulta  INTO mr_tela.*
      ELSE
         FETCH PREVIOUS cq_consulta  INTO mr_tela.*
      END IF

      IF sqlca.sqlcode = 0 THEN
         SELECT veiculo, placa, modelo, tara, veiculo_tracionad,
                veic_ntrac1, placa1, veic_ntrac2, placa2,
                veic_ntrac3, placa3, veic_ntrac4, placa4,
                nom_proprietario, observacao_veiculo, cod_categoria
           INTO mr_tela.veiculo, mr_tela.placa, mr_tela.modelo, mr_tela.tara,
                mr_tela.veiculo_tracionad, mr_tela.veic_ntrac1, mr_tela.placa1,
                mr_tela.veic_ntrac2, mr_tela.placa2, mr_tela.veic_ntrac3, mr_tela.placa3,
                mr_tela.veic_ntrac4, mr_tela.placa4, mr_tela.nom_proprietario,
                mr_tela.observacao_veiculo, mr_tela.cod_categoria
          FROM esp_balanca_veiculo
          WHERE cod_empresa = p_cod_empresa
            AND veiculo     = mr_tela.veiculo

         IF sqlca.sqlcode <> 0 THEN
            CONTINUE WHILE
         END IF
         CALL esp1554_exibe_dados()
         EXIT WHILE
      ELSE
         CALL log0030_mensagem("Não existem mais dados nesta direção.","info")
         LET mr_telar.* = mr_tela.*
         EXIT WHILE
      END IF
   END WHILE
END FUNCTION

#-------------------------#
 FUNCTION esp1554_popup()
#-------------------------#
   DEFINE l_veiculo     LIKE esp_balanca_veiculo.veiculo,
          l_condicao    CHAR(100)
  CASE
     WHEN INFIELD(veic_ntrac1)
        LET l_condicao = " veiculo_tracionad = 'N' "
        LET l_veiculo  = esp1662_popup_veiculo(l_condicao)
        CURRENT WINDOW IS w_esp1554

        IF l_veiculo IS NOT NULL THEN
           LET mr_tela.veic_ntrac1 = l_veiculo
           SELECT placa
             INTO mr_tela.placa1
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo = l_veiculo
           DISPLAY BY NAME mr_tela.placa1
           DISPLAY BY NAME mr_tela.veic_ntrac1
        END IF

     WHEN INFIELD(veic_ntrac2)
        LET l_condicao = " veiculo_tracionad = 'N' "
        LET l_veiculo  = esp1662_popup_veiculo(l_condicao)
        CURRENT WINDOW IS w_esp1554

        IF l_veiculo IS NOT NULL THEN
           LET mr_tela.veic_ntrac2 = l_veiculo
           SELECT placa
             INTO mr_tela.placa2
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo = l_veiculo
           DISPLAY BY NAME mr_tela.placa2
           DISPLAY BY NAME mr_tela.veic_ntrac2
        END IF

     WHEN INFIELD(veic_ntrac3)
        LET l_condicao = " veiculo_tracionad = 'N' "
        LET l_veiculo  = esp1662_popup_veiculo(l_condicao)
        CURRENT WINDOW IS w_esp1554

        IF l_veiculo IS NOT NULL THEN
           LET mr_tela.veic_ntrac3 = l_veiculo
           SELECT placa
             INTO mr_tela.placa3
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo = l_veiculo
           DISPLAY BY NAME mr_tela.placa3
           DISPLAY BY NAME mr_tela.veic_ntrac3
        END IF

     WHEN INFIELD(veic_ntrac4)
        LET l_condicao = " veiculo_tracionad = 'N' "
        LET l_veiculo  = esp1662_popup_veiculo(l_condicao)
        CURRENT WINDOW IS w_esp1554

        IF l_veiculo IS NOT NULL THEN
           LET mr_tela.veic_ntrac4 = l_veiculo
           SELECT placa
             INTO mr_tela.placa4
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo = l_veiculo
           DISPLAY BY NAME mr_tela.placa4
           DISPLAY BY NAME mr_tela.veic_ntrac4
        END IF

     WHEN INFIELD(cod_categoria)
        LET mr_tela.cod_categoria = log009_popup(8,12,'CATEGORIA',
                                        'esp_categ_veiculos',
                                        'cod_categoria',
                                        'den_categoria',
                                        'esp1660',
                                        'S',
                                        '')

        CURRENT WINDOW IS w_esp1554

        IF mr_tela.cod_categoria IS NOT NULL THEN
           DISPLAY BY NAME mr_tela.cod_categoria
        END IF

    END CASE
END FUNCTION

#-------------------------------#
 FUNCTION esp1554_version_info()
#-------------------------------#
  RETURN "$Archive: esp1554.4gl $|$Revision: 10 $|$Date: 16/01/12 17:12 $|$Modtime: 21/07/13 16:54 $"

 END FUNCTION
