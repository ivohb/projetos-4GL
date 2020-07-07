#---------------------------------------------------------------------------#
# SISTEMA.: ESPECIFICO                                                      #
# PROGRAMA: ESP1556                                                         #
# OBJETIVO: PROCESSO DE PESAGEM SAIDA                                       #
# AUTOR...: RAFAEL LEITE DOS SANTOS                                         #
#---------------------------------------------------------------------------#
DATABASE logix

GLOBALS

   DEFINE p_cod_empresa          LIKE empresa.cod_empresa
        , p_user                 CHAR(8)
        , p_den_empresa          LIKE empresa.den_empresa
        , p_status               SMALLINT
        , comando                CHAR(80)
        , m_caminho              CHAR(80)
        , p_last_row             SMALLINT
        , p_ies_impressao        CHAR(01)
        , g_ies_grafico          SMALLINT
        , p_nom_arquivo          CHAR(100)
        , m_nom_help             CHAR(150)
        , g_ies_ambiente         CHAR(01)
        , p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

#MODULARES
   DEFINE m_ind                  SMALLINT
   DEFINE m_nom_tela1            CHAR(200),
          m_comando              CHAR(200)

   DEFINE mr_tela,mr_telar       RECORD
                des_situacao        CHAR(20),
                nom_motorista       LIKE esp_balanca_motorista.nom_motorista,
                placa               LIKE esp_balanca_veiculo.placa,
                veic_ntrac1         LIKE esp_balanca_compl.veic_ntrac1,
                placa1              LIKE esp_balanca_veiculo.placa,
                veic_ntrac2         LIKE esp_balanca_compl.veic_ntrac2,
                placa2              LIKE esp_balanca_veiculo.placa,
                veic_ntrac3         LIKE esp_balanca_compl.veic_ntrac3,
                placa3              LIKE esp_balanca_veiculo.placa,
                veic_ntrac4         LIKE esp_balanca_compl.veic_ntrac4,
                placa4              LIKE esp_balanca_veiculo.placa
                                 END RECORD

   DEFINE mr_tela1               RECORD
             num_om                 LIKE ordem_montag_grade.num_om
                                 END RECORD

   DEFINE mr_esp_balanca         RECORD LIKE esp_balanca.*
   DEFINE mr_esp_balancar        RECORD LIKE esp_balanca.*

   DEFINE m_arr_count            SMALLINT
   DEFINE m_consulta_ativa       SMALLINT
   DEFINE m_update               SMALLINT
   DEFINE m_quantidade           LIKE esp_balanca.peso_bruto
   DEFINE where_clause           CHAR(1000),
          sql_stmt               CHAR(2000)

   DEFINE ma_tela,ma_telar       ARRAY[999] OF RECORD
          num_om1                   LIKE ordem_montag_grade.num_om,
          num_pesagem1              LIKE esp_balanca.num_pesagem,
          num_pedido                LIKE ordem_montag_grade.num_pedido,
          num_sequencia             LIKE ordem_montag_grade.num_sequencia,
          cod_item                  LIKE ordem_montag_grade.cod_item,
          data_entrega              LIKE esp_balanca.dat_pesagem,
          cod_unid_med              LIKE item.cod_unid_med,
          qtd_reservada             LIKE ordem_montag_grade.qtd_reservada,
          peso_liquido2             LIKE esp_balanca.peso_liquido,
          peso_liquido2_ton         LIKE esp_balanca.peso_liquido
                                 END RECORD

   DEFINE ma_tela3               ARRAY[999] OF RECORD
          pes_unit                  LIKE item.pes_unit
                                 END RECORD

   DEFINE ma_relat               ARRAY[999] OF RECORD
             num_om                 LIKE esp_balanca_om.num_om,
             num_pedido             LIKE esp_balanca_om.num_pedido,
             num_sequencia          LIKE esp_balanca_om.num_sequencia,
             cod_item               LIKE esp_balanca_om.cod_item,
             cod_unid_med           LIKE esp_balanca_om.cod_unid_med,
             peso_liquido           LIKE esp_balanca_om.peso_liquido
                                 END RECORD

   DEFINE ma_encerra             ARRAY[999] OF RECORD
          num_pesagem               LIKE esp_balanca.num_pesagem
                                 END RECORD

   DEFINE p_erro                 SMALLINT
   DEFINE m_arg_num              DECIMAL(15,5) #LIKE tran_arg.arg_num

   DEFINE mr_tela3               RECORD
          tp_balanca                LIKE esp_balanca_compl.tp_balanca,
          desc_tp_balanca           CHAR(20),
          pesagem_2                 CHAR(01)
                                 END RECORD

   DEFINE m_encerra              SMALLINT

   DEFINE m_total_peso_liquido   LIKE esp_balanca.peso_liquido
   DEFINE m_num_pesagem          LIKE esp_balanca_om.num_pesagem

   DEFINE m_total_peso_liquido_ton LIKE esp_balanca.peso_liquido

   DEFINE m_cod_categoria          LIKE esp_balanca_veiculo.cod_categoria,
          m_perc_tolerancia        LIKE esp_categ_veiculos.perc_tolerancia,
          m_bloq_pesagem           LIKE esp_categ_veiculos.bloq_pesagem,
          m_peso_bruto_categ       LIKE esp_categ_veiculos.peso_bruto,
          m_bat                    LIKE esp_par_balanca.bat

#END MODULARES

MAIN
   LET p_versao = "ESP1556-10.00.18" #Favor nao alterar esta linha (SUPORTE)

   WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
   WHENEVER ERROR STOP

   DEFER INTERRUPT
   CALL log140_procura_caminho("esp1556.iem") RETURNING comando
   OPTIONS
      FIELD    ORDER UNCONSTRAINED,
      HELP     FILE  comando,
      HELP     KEY   control-w,
      NEXT     KEY   control-f,
      PREVIOUS KEY   control-b

   CALL log001_acessa_usuario("VDP", "LICLIB")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL esp1556_controle()
   END IF

END MAIN

#-------------------------#
FUNCTION esp1556_controle()
#-------------------------#
 DEFINE l_nom_programa        CHAR(200)
 DEFINE l_ind                 SMALLINT
 DEFINE l_num_om              LIKE ordem_montag_mest.num_om

   CALL log006_exibe_teclas('01', p_versao)

   INITIALIZE m_nom_tela1 TO NULL

   CALL log130_procura_caminho('esp1556') RETURNING m_nom_tela1
   OPEN WINDOW w_esp1556 AT 2,2 WITH FORM m_nom_tela1
      ATTRIBUTE (BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND 'Incluir' 'Incluir pesagem.'
         MESSAGE ''
         ERROR ''
         CLEAR FORM
         LET INT_FLAG = FALSE
         IF esp1556_incluir() THEN
         END IF

      COMMAND "Consultar"    "Consultar pesagem."
         MESSAGE ""
         LET INT_FLAG = FALSE
         LET m_consulta_ativa = FALSE
         CALL esp1556_consultar()

     COMMAND KEY ("P") "Pesagem docum."
         IF m_consulta_ativa THEN
            CALL esp1556_controle_pesagem()
            CALL esp1556_atualiza_tela1()
         ELSE
            CALL log0030_mensagem("Execute a consulta previamente.","info")
         END IF

      COMMAND 'Excluir' 'Excluir pesagem.'
         IF m_consulta_ativa THEN
            IF mr_esp_balanca.ies_situacao = '1' THEN
               CALL log0030_mensagem("Pesagem já encerrada.","info")
            ELSE
               CALL esp1556_deleta_pesagem()
            END IF
         ELSE
            CALL log0030_mensagem("Execute a consulta previamente.","info")
         END IF

     COMMAND KEY ("B") "Abrir pesagem."
         IF m_consulta_ativa THEN
            IF mr_esp_balanca.ies_situacao = '0' THEN
               CALL log0030_mensagem("Pesagem pendente.","info")
            ELSE
              DECLARE cq_om_teste CURSOR FOR
              SELECT UNIQUE a.num_om
                FROM esp_balanca_om a, ordem_montag_mest b
               WHERE a.cod_empresa = p_cod_empresa
                 AND a.num_pesagem = mr_esp_balanca.num_pesagem
                 AND b.cod_empresa = a.cod_empresa
                 AND b.num_om = a.num_om
                 AND b.ies_sit_om = 'F'

              OPEN cq_om_teste
              FETCH cq_om_teste INTO l_num_om
              IF sqlca.sqlcode = 0 THEN
                 CALL log0030_mensagem("OM's já faturadas.","info")
              ELSE
                 UPDATE esp_balanca SET ies_situacao = '0'
                  WHERE cod_empresa = p_cod_empresa
                    AND num_pesagem = mr_esp_balanca.num_pesagem

                 IF sqlca.sqlcode = 0 THEN
                    CALL log0030_mensagem("Operação efetuada com sucesso.","info")
                    DISPLAY '0' TO ies_situacao
                    LET m_consulta_ativa = FALSE
                 END IF
              END IF
            END IF
         ELSE
            CALL log0030_mensagem("Execute a consulta previamente.","info")
         END IF

     COMMAND KEY ("E") "Encerrar pesagem."
         IF m_consulta_ativa THEN
            IF mr_esp_balanca.ies_situacao = '1' THEN
               CALL log0030_mensagem("Pesagem já encerrada.","info")
               LET m_consulta_ativa = FALSE
            ELSE
               IF mr_esp_balanca.ies_situacao = '2' THEN
                  CALL log0030_mensagem("Pesagem cancelada.","info")
                  LET m_consulta_ativa = FALSE
               ELSE
                  IF log0040_confirm(10,30,"Deseja finalizar?") THEN
                     CALL esp1556_finaliza_pesagem() RETURNING p_status
                  ELSE
                     CALL log0030_mensagem("Encerramento cancelado.","info")
                  END IF
               END IF
            END IF
         ELSE
            CALL log0030_mensagem("Execute a consulta previamente.","info")
         END IF

{     COMMAND KEY ("R") "Relatorio"
         IF m_consulta_ativa THEN
            CALL esp1556_listar()
         ELSE
         END IF
}
      COMMAND KEY ("T") "Cad. Motorista."
         HELP 001
         MESSAGE ""
         CALL log120_procura_caminho("esp1559") RETURNING l_nom_programa
         RUN l_nom_programa

      COMMAND KEY ("V") "Cad. Veiculo."
         HELP 001
         MESSAGE ""
         CALL log120_procura_caminho("esp1554") RETURNING l_nom_programa
         RUN l_nom_programa

      COMMAND "Anterior"  "Exibe o item anterior encontrado na pesquisa."
         IF m_consulta_ativa = TRUE THEN
            CALL esp1556_paginacao("ANTERIOR")
         ELSE
            CALL log0030_mensagem("Execute a consulta previamente.","info")
         END IF

      COMMAND "Seguinte"  "Exibe o próximo item encontrado na pesquisa."
         IF m_consulta_ativa = TRUE THEN
            CALL esp1556_paginacao("SEGUINTE")
         ELSE
             CALL log0030_mensagem("Execute a consulta previamente.","info")
         END IF

      COMMAND "Listar" "Lista os relacionamentos. "
         HELP 0001
         MESSAGE ""
         CALL esp1556_listar()

       COMMAND KEY ('!')
         PROMPT 'Digite o comando: ' FOR CHAR m_comando
         RUN m_comando
         PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando
         LET INT_FLAG = 0

      COMMAND "Fim"   "Retorna ao menu anterior."
         EXIT MENU

#lds COMMAND KEY ("control-F1") "Sobre" "Informações sobre a aplicação (CTRL-F1)."
#lds CALL esp_info_sobre(sourceName(),p_versao)

   END MENU

   CLOSE WINDOW w_esp1556
END FUNCTION

#--------------------------------#
FUNCTION esp1556_incluir()
#--------------------------------#
  DEFINE l_erro          SMALLINT,
         l_ind           SMALLINT,
         l_hora_pesagem  CHAR(08)

  INITIALIZE mr_tela.* TO NULL
  INITIALIZE mr_esp_balanca.* TO NULL
  INITIALIZE mr_telar.* TO NULL
  CALL log130_procura_caminho('esp1556') RETURNING m_nom_tela1

  IF esp1556_entrada_dados() THEN

     SELECT cod_empresa
       FROM esp_param_aux
      WHERE cod_empresa  = p_cod_empresa
      IF sqlca.sqlcode = 100 THEN
        INSERT INTO esp_param_aux
        VALUES (p_cod_empresa,0,0,0,'AJQ+','AJQ-',1,TODAY, p_user)
      END IF

     SELECT num_contr_pesag
       INTO mr_esp_balanca.num_pesagem
       FROM esp_param_aux
      WHERE cod_empresa = p_cod_empresa
      IF mr_esp_balanca.num_pesagem IS NULL THEN
          LET mr_esp_balanca.num_pesagem = 1
      ELSE
         LET mr_esp_balanca.num_pesagem = mr_esp_balanca.num_pesagem + 1
      END IF

      UPDATE esp_param_aux
         SET num_contr_pesag = mr_esp_balanca.num_pesagem
       WHERE cod_empresa = p_cod_empresa

     DISPLAY BY NAME mr_esp_balanca.num_pesagem
     LET l_hora_pesagem = TIME

     CALL log085_transacao("BEGIN")
     INSERT INTO esp_balanca VALUES(p_cod_empresa,
                                    mr_esp_balanca.num_pesagem,
                                    mr_esp_balanca.dat_pesagem,
                                    0,
                                    'S',
                                    mr_esp_balanca.cod_motorista,
                                    mr_esp_balanca.veiculo,
                                    mr_esp_balanca.peso_bruto,
                                    mr_esp_balanca.tara,
                                    mr_esp_balanca.peso_liquido,
                                    mr_esp_balanca.ton_peso_bruto,
                                    mr_esp_balanca.ton_tara,
                                    mr_esp_balanca.ton_peso_liquido,
                                    mr_esp_balanca.observacao,
                                    mr_esp_balanca.ies_situacao,
                                    mr_esp_balanca.dat_pesagem,
                                    p_user,
                                    NULL,
                                    NULL,
                                    mr_esp_balanca.pesagem_1,
                                    l_hora_pesagem,
                                    '',
                                    '',
                                    mr_esp_balanca.peso_bruto_manual,
                                    mr_esp_balanca.tara_manual,
                                    mr_esp_balanca.peso_liquido_manual,
                                    mr_esp_balanca.ton_peso_bruto_manual,
                                    mr_esp_balanca.ton_tara_manual,
                                    mr_esp_balanca.ton_peso_liquido_manual,
                                    mr_esp_balanca.pesagem_2)
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("INCLUSAO","esp_balanca")
        LET l_erro = TRUE
     END IF

     IF mr_tela.veic_ntrac1 IS NOT NULL AND NOT l_erro THEN
        IF mr_tela.veic_ntrac2 IS NOT NULL AND NOT l_erro THEN
           IF mr_tela.veic_ntrac3 IS NOT NULL AND NOT l_erro THEN
              IF mr_tela.veic_ntrac4 IS NOT NULL AND NOT l_erro THEN
                 INSERT INTO esp_balanca_compl VALUES(p_cod_empresa,
                                                      mr_esp_balanca.num_pesagem,
                                                      mr_esp_balanca.veiculo,
                                                      mr_tela.veic_ntrac1,
                                                      mr_tela.veic_ntrac2,
                                                      mr_tela.veic_ntrac3,
                                                      mr_tela.veic_ntrac4,
                                                      mr_tela3.tp_balanca)
                 IF sqlca.sqlcode <> 0 THEN
                    CALL log003_err_sql("INCLUSAO","esp_balanca_compl_1")
                    LET l_erro = TRUE
                 END IF
              ELSE
                 INSERT INTO esp_balanca_compl VALUES(p_cod_empresa,
                                        mr_esp_balanca.num_pesagem,
                                        mr_esp_balanca.veiculo,
                                        mr_tela.veic_ntrac1,
                                        mr_tela.veic_ntrac2,
                                        mr_tela.veic_ntrac3,
                                        NULL,
                                        mr_tela3.tp_balanca)
                 IF sqlca.sqlcode <> 0 THEN
                    CALL log003_err_sql("INCLUSAO","esp_balanca_compl_2")
                    LET l_erro = TRUE
                 END IF
              END IF
           ELSE
              INSERT INTO esp_balanca_compl VALUES(p_cod_empresa,
                                     mr_esp_balanca.num_pesagem,
                                     mr_esp_balanca.veiculo,
                                     mr_tela.veic_ntrac1,
                                     mr_tela.veic_ntrac2,
                                     NULL,
                                     NULL,
                                     mr_tela3.tp_balanca)
              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("INCLUSAO","esp_balanca_compl_3")
                 LET l_erro = TRUE
              END IF
           END IF
        ELSE
           INSERT INTO esp_balanca_compl VALUES(p_cod_empresa,
                                                mr_esp_balanca.num_pesagem,
                                                mr_esp_balanca.veiculo,
                                                mr_tela.veic_ntrac1,
                                                NULL,
                                                NULL,
                                                NULL,
                                                mr_tela3.tp_balanca)
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("INCLUSAO","esp_balanca_compl_4")
              LET l_erro = TRUE
           END IF
        END IF
     ELSE
        INSERT INTO esp_balanca_compl VALUES(p_cod_empresa,
                                             mr_esp_balanca.num_pesagem,
                                             mr_esp_balanca.veiculo,
                                             NULL,
                                             NULL,
                                             NULL,
                                             NULL,
                                             mr_tela3.tp_balanca)
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("INCLUSAO","esp_balanca_compl_5")
              LET l_erro = TRUE
           END IF
     END IF

     IF NOT l_erro THEN
         CALL log085_transacao("COMMIT")
         CALL log0030_mensagem("Inclusão efetuada com sucesso. ","info")
         RETURN TRUE
     ELSE
        CALL log085_transacao("ROLLBACK")
        RETURN FALSE
     END IF
  ELSE
     CALL log0030_mensagem( "Inclusão cancelada. ","info")
     LET mr_tela.* = mr_telar.*
     RETURN FALSE
  END IF

END FUNCTION

#--------------------------------------#
 FUNCTION esp1556_entrada_dados()
#--------------------------------------#
   DEFINE l_tara                LIKE esp_balanca.tara,
          l_veiculo_tracionad   LIKE esp_balanca_veiculo.veiculo_tracionad

  DISPLAY p_cod_empresa TO cod_empresa

  CURRENT WINDOW IS w_esp1556

  CLEAR FORM
  INITIALIZE mr_tela3.* TO NULL

  LET mr_esp_balanca.ies_situacao = '0'
  CALL esp1556_carrega_situacao(1)
  LET mr_esp_balanca.dat_pesagem = TODAY

  LET mr_esp_balanca.num_pesagem = 0
  LET mr_esp_balanca.cod_empresa = p_cod_empresa
  DISPLAY BY NAME mr_esp_balanca.num_pesagem
  DISPLAY BY NAME mr_esp_balanca.cod_empresa
  DISPLAY BY NAME mr_esp_balanca.dat_pesagem

  LET mr_esp_balanca.pesagem_1 = "N"
  LET mr_esp_balanca.pesagem_2 = "N"

  INPUT BY NAME mr_tela3.tp_balanca,
                mr_esp_balanca.pesagem_1,
                mr_esp_balanca.cod_motorista,
                mr_esp_balanca.veiculo,
                mr_tela.placa,
                mr_tela.veic_ntrac1,
                mr_tela.placa1,
                mr_tela.veic_ntrac2,
                mr_tela.placa2,
                mr_tela.veic_ntrac3,
                mr_tela.placa3,
                mr_tela.veic_ntrac4,
                mr_tela.placa4,
                mr_esp_balanca.observacao WITHOUT DEFAULTS

    AFTER FIELD tp_balanca
       IF mr_tela3.tp_balanca IS NULL OR mr_tela3.tp_balanca = " " THEN
           CALL log0030_mensagem("Balança deve ser informada.","info")
           NEXT FIELD tp_balanca
       END IF

       IF mr_tela3.tp_balanca IS NOT NULL OR mr_tela3.tp_balanca <> " " THEN
          CALL esp1556_carrega_balanca(mr_tela3.tp_balanca)
               RETURNING p_status, mr_tela3.desc_tp_balanca

          IF NOT p_status THEN
             CALL log0030_mensagem("Balança não cadastrada.","info")
             NEXT FIELD tp_balanca
          END IF
          DISPLAY mr_tela3.desc_tp_balanca TO desc_tp_balanca
       END IF

       IF NOT esp1556_pop_pesagem() THEN
          NEXT FIELD tp_balanca
       END IF

       CALL esp1556_seta_valores()

       IF mr_esp_balanca.tara_manual IS NOT NULL AND mr_esp_balanca.tara_manual > 0 THEN
          NEXT FIELD cod_motorista
       ELSE
          NEXT FIELD pesagem_1
       END IF

     BEFORE FIELD pesagem_1
        IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
           FGL_LASTKEY() = FGL_KEYVAL("left") THEN
            NEXT FIELD tp_balanca
        END IF

     AFTER FIELD pesagem_1
        IF mr_esp_balanca.pesagem_1 IS NOT NULL THEN
           IF mr_esp_balanca.pesagem_1 = "S" THEN
              IF esp1556_entrada_dados2() THEN
                 CALL esp1556_seta_valores()
              END IF
           END IF
        END IF

     AFTER FIELD cod_motorista
        IF mr_esp_balanca.cod_motorista IS NOT NULL
        OR mr_esp_balanca.cod_motorista <> ' '  THEN
        SELECT nom_motorista
          INTO mr_tela.nom_motorista
          FROM esp_balanca_motorista
         WHERE cod_empresa = p_cod_empresa
           AND motorista = mr_esp_balanca.cod_motorista

         IF sqlca.sqlcode = 0 THEN
            DISPLAY BY NAME mr_tela.nom_motorista
            NEXT FIELD veiculo
         ELSE
            CALL log0030_mensagem("Codigo de motorista nao encontrado.","info")
            NEXT FIELD cod_motorista
         END IF
      END IF

     AFTER FIELD veiculo
        IF mr_esp_balanca.veiculo IS NOT NULL
        OR mr_esp_balanca.veiculo <> ' '  THEN
           SELECT placa,veic_ntrac1,placa1,veiculo_tracionad
             INTO mr_tela.placa, mr_tela.veic_ntrac1, mr_tela.placa1, l_veiculo_tracionad
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo     = mr_esp_balanca.veiculo

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_mensagem("Veículo não encontrado.","info")
              NEXT FIELD veiculo
           END IF

           WHENEVER ERROR CONTINUE
            SELECT a.cod_categoria
              FROM esp_balanca_veiculo a, esp_categ_veiculos b
             WHERE a.cod_empresa   = p_cod_empresa
               AND b.cod_empresa   = a.cod_empresa
               AND a.veiculo       = mr_esp_balanca.veiculo
               AND a.cod_categoria = b.cod_categoria
           WHENEVER ERROR STOP

           IF SQLCA.SQLCODE <> 0 THEN
              CALL log0030_mensagem("Veículo sem categoria informada.","info")
              NEXT FIELD veiculo
           END IF

           DISPLAY BY NAME mr_tela.placa
           DISPLAY BY NAME mr_tela.veic_ntrac1
           DISPLAY BY NAME mr_tela.placa1
           NEXT FIELD veic_ntrac1
        END IF

     AFTER FIELD placa
        IF mr_tela.placa IS NOT NULL
        OR mr_tela.placa <> ' '  THEN
           SELECT veiculo
             INTO mr_esp_balanca.veiculo
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND placa  = mr_tela.placa
              AND veiculo_tracionad = 'N'

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_mensagem("Veiculo nao encontrado.","info")
              INITIALIZE mr_tela.placa TO NULL
              NEXT FIELD veiculo
           ELSE
              DISPLAY BY NAME mr_esp_balanca.veiculo
           END IF
        END IF

        NEXT FIELD veic_ntrac1

     BEFORE FIELD veic_ntrac1
        IF mr_tela.placa IS NULL
        OR mr_tela.placa = " " THEN
           CALL log0030_mensagem("Veiculo/Placa nao pode ser nulo","info")
           NEXT FIELD veiculo
        END IF

     AFTER FIELD veic_ntrac1
        IF l_veiculo_tracionad = 'S' THEN
           IF mr_tela.veic_ntrac1 IS NULL
           OR mr_tela.veic_ntrac1 = ''  THEN
              CALL log0030_mensagem('N TRAC1 nao pode ser nulo','info')
              NEXT FIELD veic_ntrac1
           END IF
        END IF

        IF mr_tela.veic_ntrac1 IS NOT NULL
        OR mr_tela.veic_ntrac1 <> ' '  THEN
           SELECT placa
             INTO mr_tela.placa1
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo = mr_tela.veic_ntrac1
              AND veiculo_tracionad = 'N'
           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_mensagem("Veiculo nao tracionado nao encontrado.","info")
              NEXT FIELD veic_ntrac1
           ELSE
              DISPLAY BY NAME mr_tela.placa1
              NEXT FIELD veic_ntrac2
           END IF
        END IF

     AFTER FIELD placa1
        IF l_veiculo_tracionad = 'S' THEN
           IF mr_tela.placa1 IS NULL
           OR mr_tela.placa1 = ''  THEN
              CALL log0030_mensagem('PLACA N TRAC1 nao pode ser nulo','info')
              NEXT FIELD placa1
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
              CALL log0030_mensagem("Veiculo nao encontrado.","info")
              NEXT FIELD placa1
           ELSE
              DISPLAY BY NAME mr_tela.veic_ntrac1
           END IF
        END IF

     AFTER FIELD veic_ntrac2
           IF mr_tela.veic_ntrac2 IS NOT NULL
           OR mr_tela.veic_ntrac2 <> ' '  THEN
              SELECT placa
                INTO mr_tela.placa2
                FROM esp_balanca_veiculo
               WHERE veiculo = mr_tela.veic_ntrac2
                 AND veiculo_tracionad = 'N'
              IF sqlca.sqlcode <> 0 THEN
                 CALL log0030_mensagem("Veiculo nao tracionado nao encontrado.","info")
                 NEXT FIELD veic_ntrac2
              ELSE
                 DISPLAY BY NAME mr_tela.placa2
                 NEXT FIELD veic_ntrac3
              END IF
           END IF

     AFTER FIELD placa2
        IF mr_tela.placa2 IS NOT NULL
        OR mr_tela.placa2 <> ' '  THEN
           SELECT veiculo
             INTO mr_tela.veic_ntrac2
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND placa  = mr_tela.placa2
              AND veiculo_tracionad = 'N'

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_mensagem("Veiculo nao encontrado.","info")
              NEXT FIELD placa2
           ELSE
              DISPLAY BY NAME mr_tela.veic_ntrac2
           END IF
        END IF

     AFTER FIELD veic_ntrac3
        IF mr_tela.veic_ntrac2 IS NOT NULL
        OR mr_tela.veic_ntrac2 <> " "
        OR mr_tela.placa2 IS NOT NULL
        OR mr_tela.placa2 <> ' ' THEN

          IF mr_tela.veic_ntrac3 IS NOT NULL
           OR mr_tela.veic_ntrac3 <> ' '  THEN
              SELECT placa
                INTO mr_tela.placa3
                FROM esp_balanca_veiculo
               WHERE veiculo = mr_tela.veic_ntrac3
                 AND veiculo_tracionad = 'N'
              IF sqlca.sqlcode <> 0 THEN
                 CALL log0030_mensagem("Veiculo nao tracionado nao encontrado.","info")
                 NEXT FIELD veic_ntrac3
              ELSE
                 DISPLAY BY NAME mr_tela.placa3
                 NEXT FIELD veic_ntrac4
              END IF
           END IF
        END IF

     AFTER FIELD placa3
        IF mr_tela.placa3 IS NOT NULL
        OR mr_tela.placa3 <> ' '  THEN
           SELECT veiculo
             INTO mr_tela.veic_ntrac3
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND placa  = mr_tela.placa3
              AND veiculo_tracionad = 'N'

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_mensagem("Veiculo nao encontrado.","info")
              NEXT FIELD placa3
           ELSE
              DISPLAY BY NAME mr_tela.veic_ntrac3
           END IF
        END IF

     AFTER FIELD veic_ntrac4
        IF mr_tela.veic_ntrac3 IS NOT NULL
        OR mr_tela.veic_ntrac3 <> " "
        OR mr_tela.placa3 IS NOT NULL
        OR mr_tela.placa3 <> ' ' THEN

           IF mr_tela.veic_ntrac4 IS NOT NULL
           OR mr_tela.veic_ntrac4 <> ' '  THEN
              SELECT placa
                INTO mr_tela.placa4
                FROM esp_balanca_veiculo
               WHERE veiculo = mr_tela.veic_ntrac4
                 AND veiculo_tracionad = 'N'
              IF sqlca.sqlcode <> 0 THEN
                 CALL log0030_mensagem("Veiculo nao tracionado nao encontrado.","info")
                 NEXT FIELD veic_ntrac4
              ELSE
                 DISPLAY BY NAME mr_tela.placa4
                 NEXT FIELD observacao
              END IF
           END IF
        END IF

      AFTER FIELD placa4
        IF mr_tela.placa4 IS NOT NULL
        OR mr_tela.placa4 <> ' '  THEN
           SELECT veiculo
             INTO mr_tela.veic_ntrac4
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND placa  = mr_tela.placa4
              AND veiculo_tracionad = 'N'

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_mensagem("Veiculo nao encontrado.","info")
              NEXT FIELD placa4
           ELSE
              DISPLAY BY NAME mr_tela.veic_ntrac4
           END IF
        END IF

     AFTER FIELD tara
        IF mr_esp_balanca.pesagem_1 = "N" THEN
           IF mr_esp_balanca.tara IS NOT NULL OR mr_esp_balanca.tara > 0 THEN
              ######### Apenas informar que o peso tara esta diferente do informado
              SELECT DISTINCT tara
                INTO l_tara
                FROM esp_balanca_veiculo
               WHERE cod_empresa = p_cod_empresa
                 AND veiculo = mr_esp_balanca.veiculo

              IF sqlca.sqlcode = 0 THEN
                 IF l_tara <>  mr_esp_balanca.tara THEN
                    CALL log0030_mensagem("TARA informada difere do cadastro do veiculo", "info")
                 END IF
              END IF
              LET mr_esp_balanca.ton_tara = mr_esp_balanca.tara / 1000
              DISPLAY BY NAME mr_esp_balanca.ton_tara
           END IF
        END IF

     AFTER INPUT
        IF NOT INT_FLAG THEN

           IF mr_tela3.tp_balanca IS NULL
           OR mr_tela3.tp_balanca = " " THEN
               CALL log0030_mensagem("Favor informar a Balança","info")
               NEXT FIELD tp_balanca
           END IF

           IF mr_esp_balanca.cod_motorista IS NULL
           OR mr_esp_balanca.cod_motorista = ' '  THEN
              CALL log0030_mensagem("Motorista deve ser informado.", "info")
           NEXT FIELD cod_motorista
           END IF

           IF mr_esp_balanca.veiculo IS NULL
           OR mr_esp_balanca.veiculo = ' '  THEN
              CALL log0030_mensagem("Veiculo nulo invalido.", "info")
              NEXT FIELD veiculo
           END IF

           IF mr_tela.veic_ntrac1 IS NULL
           OR mr_tela.veic_ntrac1 = " " THEN
              SELECT DISTINCT cod_empresa
                FROM esp_balanca_compl
               WHERE cod_empresa = p_cod_empresa
                 AND num_pesagem = mr_esp_balanca.num_pesagem
                 AND veiculo     = mr_esp_balanca.veiculo

              IF sqlca.sqlcode = 0 THEN
                 CALL log0030_mensagem('Controle de Pesagem ja cadastrado para esse veiculo','info')
                 NEXT FIELD veiculo
              END IF
           ELSE
              SELECT DISTINCT cod_empresa
                FROM esp_balanca_compl
               WHERE cod_empresa = p_cod_empresa
                 AND num_pesagem = mr_esp_balanca.num_pesagem
                 AND veiculo     = mr_esp_balanca.veiculo
                 AND veic_ntrac1 = mr_tela.veic_ntrac1

              IF sqlca.sqlcode = 0 THEN
                 CALL log0030_mensagem('Controle de Pesagem ja cadastrado para esse veiculo','info')
                 NEXT FIELD veiculo
              END IF
           END IF

           IF mr_esp_balanca.pesagem_1 = "N" THEN
              IF mr_esp_balanca.tara <= 0 THEN
                 CALL log0030_mensagem("Tara igual ou menos que 0.","info")
                 NEXT FIELD tara
              END IF
           END IF
        ELSE
           CLEAR FORM
        END IF

     ON KEY(control-z)
        CALL esp1556_popup("1")
  END INPUT

  IF INT_FLAG THEN
     CLEAR FORM
     LET INT_FLAG = 0
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF
END FUNCTION

#------------------------------------------#
 FUNCTION esp1556_carrega_situacao(l_case)
#------------------------------------------#
 DEFINE l_case          SMALLINT

 CASE l_case
    WHEN 1
       IF mr_esp_balanca.ies_situacao = '0' THEN
          LET mr_tela.des_situacao = 'PENDENTE'
          ELSE
             IF mr_esp_balanca.ies_situacao = '1' THEN
                LET mr_tela.des_situacao = 'ENCERRADA'
          ELSE
             IF mr_esp_balanca.ies_situacao = '2' THEN
                LET mr_tela.des_situacao = 'CANCELADA'
             END IF
          END IF
       END IF

       DISPLAY BY NAME mr_esp_balanca.ies_situacao
       DISPLAY BY NAME mr_tela.des_situacao

    WHEN 2
       LET mr_esp_balanca.ies_situacao = '1'
 END CASE

END FUNCTION

#------------------------------#
FUNCTION esp1556_deleta_pesagem()
#------------------------------#
  IF log0040_confirm(10,30,"Confirma a exclusão?") THEN
     CALL log085_transacao("BEGIN")

     WHENEVER ERROR CONTINUE
     DELETE FROM esp_balanca
      WHERE cod_empresa = p_cod_empresa
        AND num_pesagem = mr_esp_balanca.num_pesagem
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("INSERT","esp_balanca")
        CALL log085_transacao("ROLLBACK")
        RETURN
     END IF

     WHENEVER ERROR CONTINUE
     DELETE FROM esp_balanca_om
      WHERE cod_empresa   = p_cod_empresa
        AND num_pesagem   = mr_esp_balanca.num_pesagem
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("INSERT","esp_balanca_om")
        CALL log085_transacao("ROLLBACK")
        RETURN
     END IF

     CALL log085_transacao("COMMIT")
     CLEAR FORM
     MESSAGE " Exclusão efetuada com sucesso. " ATTRIBUTE(REVERSE)
  ELSE
     MESSAGE " Exclusão cancelada. " ATTRIBUTE(REVERSE)
  END IF

END FUNCTION

#--------------------------------------#
FUNCTION esp1556_consultar()
#--------------------------------------#

   LET m_consulta_ativa = FALSE

   CLEAR FORM
   INITIALIZE mr_tela.* TO NULL

   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT where_clause ON esp_balanca.num_pesagem,
                             esp_balanca.ies_situacao,
                             esp_balanca.dat_pesagem,
                             esp_balanca.cod_motorista,
                             esp_balanca.veiculo,
                             esp_balanca.peso_bruto,
                             esp_balanca.tara,
                             esp_balanca.peso_liquido
                        FROM num_pesagem,
                             ies_situacao,
                             dat_pesagem,
                             cod_motorista,
                             veiculo,
                             peso_bruto,
                             tara,
                             peso_liquido

   IF INT_FLAG = TRUE THEN
      LET INT_FLAG = FALSE
      CLEAR FORM
      CALL log0030_mensagem("Consulta cancelada.","info")
      RETURN
   END IF

   LET sql_stmt = " SELECT num_pesagem",
                  "   FROM esp_balanca ",
                  "  where cod_empresa = ", log0800_string(p_cod_empresa),
                  "   AND ", where_clause CLIPPED,
                  " ORDER BY num_pesagem desc "

   PREPARE var_query_consulta FROM sql_stmt
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_query_consulta
   OPEN cq_consulta

   FETCH FIRST cq_consulta INTO mr_esp_balanca.num_pesagem

   IF sqlca.sqlcode <> 0 THEN
      INITIALIZE mr_tela.* TO NULL
      CALL log0030_mensagem("Argumentos de pesquisa nao encontrados.","info")
      DISPLAY p_cod_empresa TO cod_empresa  RETURN FALSE
   ELSE
      SELECT *
        INTO mr_esp_balanca.*
        FROM esp_balanca
       WHERE cod_empresa = p_cod_empresa
         AND num_pesagem = mr_esp_balanca.num_pesagem

      LET m_consulta_ativa = TRUE
      CALL esp1556_exibe_dados()
   END IF
END FUNCTION

#--------------------------------------#
FUNCTION esp1556_exibe_dados()
#--------------------------------------#
  INITIALIZE mr_tela.* TO NULL
  INITIALIZE mr_tela3.* TO NULL

  CURRENT WINDOW IS w_esp1556

  SELECT b.placa, c.nom_motorista
    INTO mr_tela.placa, mr_tela.nom_motorista
    FROM esp_balanca a, esp_balanca_veiculo b, esp_balanca_motorista c
   WHERE a.cod_empresa   = b.cod_empresa
     AND a.veiculo       = b.veiculo
     AND a.cod_empresa   = c.cod_empresa
     AND a.cod_motorista = c.motorista
     AND a.cod_empresa   = p_cod_empresa
     AND a.num_pesagem   = mr_esp_balanca.num_pesagem

   SELECT veic_ntrac1, veic_ntrac2, veic_ntrac3, veic_ntrac4, tp_balanca
    INTO mr_tela.veic_ntrac1, mr_tela.veic_ntrac2, mr_tela.veic_ntrac3, mr_tela.veic_ntrac4, mr_tela3.tp_balanca
    FROM esp_balanca_compl
   WHERE cod_empresa = p_cod_empresa
     AND num_pesagem = mr_esp_balanca.num_pesagem
     AND veiculo     = mr_esp_balanca.veiculo

  IF mr_tela.veic_ntrac1 IS NOT NULL
  OR mr_tela.veic_ntrac1 <> " " THEN

     SELECT esp_balanca_veiculo.placa
      INTO mr_tela.placa1
      FROM esp_balanca_veiculo
     WHERE esp_balanca_veiculo.cod_empresa  = p_cod_empresa
       AND esp_balanca_veiculo.veiculo      = mr_tela.veic_ntrac1
  END IF

  IF mr_tela.veic_ntrac2 IS NOT NULL
  OR mr_tela.veic_ntrac2 <> " " THEN
     SELECT esp_balanca_veiculo.placa
      INTO mr_tela.placa2
      FROM esp_balanca_veiculo
     WHERE esp_balanca_veiculo.cod_empresa  = p_cod_empresa
       AND esp_balanca_veiculo.veiculo      = mr_tela.veic_ntrac2
  END IF

  IF mr_tela.veic_ntrac3 IS NOT NULL
  OR mr_tela.veic_ntrac3 <> " " THEN

     SELECT esp_balanca_veiculo.placa
      INTO mr_tela.placa3
      FROM esp_balanca_veiculo
     WHERE esp_balanca_veiculo.cod_empresa  = p_cod_empresa
       AND esp_balanca_veiculo.veiculo      = mr_tela.veic_ntrac3
  END IF

   IF mr_tela.veic_ntrac4 IS NOT NULL
   OR mr_tela.veic_ntrac4 <> " " THEN

      SELECT esp_balanca_veiculo.placa
       INTO mr_tela.placa4
       FROM esp_balanca_veiculo
      WHERE esp_balanca_veiculo.cod_empresa  = p_cod_empresa
        AND esp_balanca_veiculo.veiculo      = mr_tela.veic_ntrac4
  END IF

  IF mr_tela3.tp_balanca IS NOT NULL
  OR mr_tela3.tp_balanca <> "" THEN
     CALL esp1556_carrega_balanca(mr_tela3.tp_balanca) RETURNING p_status, mr_tela3.desc_tp_balanca
  END IF

  CALL esp1556_carrega_situacao(1)

  IF mr_esp_balanca.peso_bruto IS NULL OR
     mr_esp_balanca.peso_bruto = ' ' THEN
     LET mr_esp_balanca.peso_bruto = 0
  END IF

  IF mr_esp_balanca.tara IS NULL OR
     mr_esp_balanca.tara = ' ' THEN
     LET mr_esp_balanca.tara = 0
  END IF

  IF mr_esp_balanca.peso_liquido IS NULL OR
     mr_esp_balanca.peso_liquido = ' ' THEN
     LET mr_esp_balanca.peso_liquido = 0
  END IF

  DISPLAY BY NAME mr_esp_balanca.pesagem_1
  DISPLAY BY NAME mr_esp_balanca.num_pesagem
  DISPLAY BY NAME mr_esp_balanca.ies_situacao
  DISPLAY BY NAME mr_esp_balanca.dat_pesagem
  DISPLAY BY NAME mr_esp_balanca.cod_motorista
  DISPLAY BY NAME mr_tela.nom_motorista
  DISPLAY BY NAME mr_esp_balanca.veiculo
  DISPLAY BY NAME mr_tela.placa
  DISPLAY BY NAME mr_tela.veic_ntrac1
  DISPLAY BY NAME mr_tela.placa1
  DISPLAY BY NAME mr_tela.veic_ntrac2
  DISPLAY BY NAME mr_tela.placa2
  DISPLAY BY NAME mr_tela.veic_ntrac3
  DISPLAY BY NAME mr_tela.placa3
  DISPLAY BY NAME mr_tela.veic_ntrac4
  DISPLAY BY NAME mr_tela.placa4
  DISPLAY BY NAME mr_esp_balanca.observacao
  DISPLAY BY NAME mr_esp_balanca.peso_bruto
  DISPLAY BY NAME mr_esp_balanca.tara
  DISPLAY BY NAME mr_esp_balanca.peso_liquido

  DISPLAY BY NAME mr_esp_balanca.ton_peso_bruto
  DISPLAY BY NAME mr_esp_balanca.ton_tara
  DISPLAY BY NAME mr_esp_balanca.ton_peso_liquido

  DISPLAY BY NAME mr_esp_balanca.peso_bruto_manual
  DISPLAY BY NAME mr_esp_balanca.tara_manual
  DISPLAY BY NAME mr_esp_balanca.peso_liquido_manual
  DISPLAY BY NAME mr_esp_balanca.ton_peso_bruto_manual
  DISPLAY BY NAME mr_esp_balanca.ton_tara_manual
  DISPLAY BY NAME mr_esp_balanca.ton_peso_liquido_manual

  DISPLAY mr_tela3.tp_balanca TO tp_balanca
  DISPLAY mr_tela3.desc_tp_balanca TO desc_tp_balanca

  LET mr_telar.* = mr_telar.*

  WHENEVER ERROR CONTINUE
   SELECT a.cod_categoria, b.perc_tolerancia, b.bloq_pesagem, b.peso_bruto
     INTO m_cod_categoria, m_perc_tolerancia, m_bloq_pesagem, m_peso_bruto_categ
     FROM esp_balanca_veiculo a, esp_categ_veiculos b
    WHERE a.cod_empresa   = p_cod_empresa
      AND b.cod_empresa   = a.cod_empresa
      AND a.veiculo       = mr_esp_balanca.veiculo
      AND a.cod_categoria = b.cod_categoria
  WHENEVER ERROR STOP

 END FUNCTION

#--------------------------------------------#
 FUNCTION esp1556_carrega_array(l_arr_curr)
#--------------------------------------------#
   DEFINE l_ind           SMALLINT
   DEFINE l_peso_liquido  LIKE esp_balanca.peso_liquido
   DEFINE l_arr_curr      SMALLINT

   LET l_ind = l_arr_curr
   LET l_peso_liquido = 0

   DECLARE cq_carga CURSOR FOR
    SELECT ordem_montag_item.num_pedido,
           ordem_montag_item.num_sequencia, ordem_montag_item.cod_item,
           TODAY, item.cod_unid_med, SUM(ordem_montag_item.qtd_reservada) as qtd_reservada,
           item.pes_unit, pedidos.dat_pedido
      FROM ordem_montag_item, item, pedidos
     WHERE ordem_montag_item.cod_empresa = item.cod_empresa
       AND ordem_montag_item.cod_item    = item.cod_item
       AND ordem_montag_item.cod_empresa = pedidos.cod_empresa
       AND ordem_montag_item.num_pedido  = pedidos.num_pedido
       AND ordem_montag_item.cod_empresa = p_cod_empresa
       AND ordem_montag_item.num_om      = ma_tela[l_arr_curr].num_om1
       GROUP BY ordem_montag_item.num_pedido,
                ordem_montag_item.num_sequencia, ordem_montag_item.cod_item,
                item.cod_unid_med,item.pes_unit, pedidos.dat_pedido
       ORDER BY ordem_montag_item.num_sequencia

   FOREACH cq_carga INTO  ma_tela[l_ind].num_pedido,
                          ma_tela[l_ind].num_sequencia,
                          ma_tela[l_ind].cod_item,
                          ma_tela[l_ind].data_entrega,
                          ma_tela[l_ind].cod_unid_med,
                          ma_tela[l_ind].qtd_reservada,
                          ma_tela3[l_ind].pes_unit

        LET ma_tela[l_ind].num_pesagem1  = mr_esp_balanca.num_pesagem
        LET ma_tela[l_ind].num_om1       = ma_tela[l_arr_curr].num_om1

        IF l_ind > 1 THEN
           IF ma_tela[l_ind].num_om1 IS NULL
           OR ma_tela[l_ind].num_om1 = " " THEN
              LET ma_tela[l_ind].peso_liquido2 = 0
           END IF
        END IF
        LET l_ind = l_ind + 1
   END FOREACH
   LET l_ind = l_ind - 1
   LET m_ind = l_ind

   CALL esp1556_recarrega(l_ind)

END FUNCTION

#--------------------------------#
 FUNCTION esp1556_popup(l_ind)
#--------------------------------#
  DEFINE l_condicao    CHAR(100),
         l_cod_item    LIKE item.cod_item,
         l_ind         CHAR(01)

  CASE
     WHEN INFIELD(cod_motorista)
        LET mr_esp_balanca.cod_motorista = esp1662_popup_motorista()
        CURRENT WINDOW IS w_esp1556

        IF mr_esp_balanca.cod_motorista IS NOT NULL THEN
           SELECT nom_motorista
             INTO mr_tela.nom_motorista
             FROM esp_balanca_motorista
            WHERE cod_empresa = p_cod_empresa
              AND motorista   = mr_esp_balanca.cod_motorista

            DISPLAY BY NAME mr_esp_balanca.cod_motorista
            DISPLAY BY NAME mr_tela.nom_motorista
        END IF

     WHEN INFIELD(veiculo)
        LET l_condicao = NULL
        LET mr_esp_balanca.veiculo = esp1662_popup_veiculo(l_condicao)
        CURRENT WINDOW IS w_esp1556

        IF mr_esp_balanca.veiculo IS NOT NULL THEN
           SELECT placa
             INTO mr_tela.placa
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo     = mr_esp_balanca.veiculo

           DISPLAY BY NAME mr_tela.placa
           DISPLAY BY NAME mr_esp_balanca.veiculo
        END IF

     WHEN INFIELD(veic_ntrac1)
        LET l_condicao = " veiculo_tracionad = 'N' "
        LET mr_tela.veic_ntrac1 = esp1662_popup_veiculo(l_condicao)
        CURRENT WINDOW IS w_esp1556

        IF mr_tela.veic_ntrac1 IS NOT NULL THEN
           SELECT placa
             INTO mr_tela.placa1
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo     = mr_tela.veic_ntrac1

           DISPLAY BY NAME mr_tela.placa1
           DISPLAY BY NAME mr_tela.veic_ntrac1
        END IF

     WHEN INFIELD(veic_ntrac2)
        LET l_condicao = " veiculo_tracionad = 'N' "
        LET mr_tela.veic_ntrac2  = esp1662_popup_veiculo(l_condicao)
        CURRENT WINDOW IS w_esp1556

        IF mr_tela.veic_ntrac2 IS NOT NULL THEN
           SELECT placa
             INTO mr_tela.placa2
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo = mr_tela.veic_ntrac2

           DISPLAY BY NAME mr_tela.placa2
           DISPLAY BY NAME mr_tela.veic_ntrac2
        END IF

     WHEN INFIELD(veic_ntrac3)
         LET l_condicao = " veiculo_tracionad = 'N' "
         LET mr_tela.veic_ntrac3  = esp1662_popup_veiculo(l_condicao)
         CURRENT WINDOW IS w_esp1556

        IF mr_tela.veic_ntrac3 IS NOT NULL THEN
           SELECT placa
             INTO mr_tela.placa3
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo = mr_tela.veic_ntrac3

           DISPLAY BY NAME mr_tela.placa3
           DISPLAY BY NAME mr_tela.veic_ntrac3
        END IF

     WHEN INFIELD(veic_ntrac4)
        LET l_condicao = " veiculo_tracionad = 'N' "
        LET mr_tela.veic_ntrac4  = esp1662_popup_veiculo(l_condicao)
        CURRENT WINDOW IS w_esp1556

        IF mr_tela.veic_ntrac4 IS NOT NULL THEN
           SELECT placa
             INTO mr_tela.placa4
             FROM esp_balanca_veiculo
            WHERE cod_empresa = p_cod_empresa
              AND veiculo = mr_tela.veic_ntrac4

           DISPLAY BY NAME mr_tela.placa4
           DISPLAY BY NAME mr_tela.veic_ntrac4
        END IF

     WHEN INFIELD(cod_item)
        LET l_cod_item = min071_popup_item(p_cod_empresa)
        CURRENT WINDOW IS w_esp15561

        IF l_cod_item IS NOT NULL THEN
           LET mr_tela.cod_item = l_cod_item
           DISPLAY BY NAME mr_tela.cod_item
        END IF

     WHEN INFIELD(tp_balanca)
        LET mr_tela3.tp_balanca = log009_popup(8,12,'BALANÇA',
                                        'esp_par_balanca',
                                        'cod_balanca',
                                        'den_balanca',
                                        'esp1659',
                                        'S',
                                        '')

        IF l_ind = "1" THEN
           CURRENT WINDOW IS w_esp1556
        ELSE
           CURRENT WINDOW IS w_esp15561
        END IF

        IF mr_tela3.tp_balanca IS NOT NULL THEN
           DISPLAY BY NAME mr_tela3.tp_balanca
        END IF

  END CASE
END FUNCTION

#--------------------------------#
 REPORT esp1556_relat_om(lr_relat)
#--------------------------------#
 DEFINE l_ind  SMALLINT
 DEFINE l_opcao    CHAR(10)

DEFINE lr_relat       RECORD
       num_pesagem       LIKE esp_balanca.num_pesagem,
       dat_pesagem       LIKE esp_balanca.dat_pesagem ,
       cod_motorista     LIKE esp_balanca.cod_motorista,
       nom_motorista     LIKE esp_balanca_motorista.nom_motorista,
       veiculo           LIKE esp_balanca.cod_motorista,
       placa             LIKE esp_balanca_veiculo.placa,
       veic_ntrac1       LIKE esp_balanca_compl.veic_ntrac1,
       placa1            LIKE esp_balanca_veiculo.placa,
       veic_ntrac2       LIKE esp_balanca_compl.veic_ntrac2,
       placa2            LIKE esp_balanca_veiculo.placa,
       veic_ntrac3       LIKE esp_balanca_compl.veic_ntrac3,
       placa3            LIKE esp_balanca_veiculo.placa,
       veic_ntrac4       LIKE esp_balanca_compl.veic_ntrac4 ,
       placa4            LIKE esp_balanca_veiculo.placa,
       num_nff           LIKE ordem_montag_mest.num_nff,
       cod_transpor      LIKE ordem_montag_mest.cod_transpor,
       den_transpor      LIKE transport.den_transpor,
       cod_cliente       LIKE pedidos.cod_cliente,
       nom_cliente       LIKE clientes.nom_cliente,
       peso_bruto        LIKE esp_balanca.peso_bruto,
       tara              LIKE esp_balanca.tara,
       peso_liquido      LIKE esp_balanca.peso_liquido,
       num_om1           LIKE ordem_montag_grade.num_om,
       num_pedido        LIKE ordem_montag_grade.num_pedido,
       num_sequencia     LIKE esp_balanca_om.num_sequencia,
       cod_item          LIKE esp_balanca_om.cod_item,
       cod_unid_med      LIKE esp_balanca_om.cod_unid_med,
       peso_liquido1     LIKE esp_balanca_om.peso_liquido,
       saldo_pedido      LIKE esp_balanca_om.peso_liquido,
       data_1_pesagem    DATE,
       hora_1_pesagem    CHAR(08),
       data_2_pesagem    DATE,
       hora_2_pesagem    CHAR(08)
                     END RECORD

DEFINE l_om              LIKE ordem_montag_grade.num_om,
       l_des_situacao    CHAR(30),
       l_ies_situacao    LIKE esp_balanca.ies_situacao,
       l_den_item        LIKE item.den_item

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 4
          PAGE   LENGTH 66
   FORMAT
   PAGE HEADER

      PRINT COLUMN 001, p_den_empresa
      PRINT COLUMN 001, "ESP1556",
            COLUMN 081, "FL. ", PAGENO USING "####"
      PRINT COLUMN 001, "USUARIO: ",p_user ,
            COLUMN 054, "EXTRAIDO EM ", TODAY USING "dd/mm/yy",
            COLUMN 075, "AS ", TIME," HRS."
      SKIP 1 LINE
      PRINT COLUMN 042, " PESAGEM BALANCA"
      SKIP 1 LINE

   BEFORE GROUP OF lr_relat.num_pesagem
   SKIP TO TOP OF PAGE

      SELECT ies_situacao INTO l_ies_situacao
        FROM esp_balanca
       WHERE cod_empresa = p_cod_empresa
         AND num_pesagem = lr_relat.num_pesagem

         IF l_ies_situacao = '0' THEN
            LET l_des_situacao = 'PENDENTE'
            ELSE
               IF l_ies_situacao = '1' THEN
                  LET l_des_situacao = 'ENCERRADA'
            ELSE
               IF l_ies_situacao = '2' THEN
                  LET l_des_situacao = 'CANCELADA'
               END IF
            END IF
         END IF

      PRINT COLUMN 01, "    CONTROLE: " , lr_relat.num_pesagem   USING '#########',
            COLUMN 37, "    SITUACAO: " , l_des_situacao         CLIPPED
      PRINT COLUMN 01, "DATA/PESAGEM: ", lr_relat.dat_pesagem    CLIPPED
      PRINT COLUMN 01, "   MOTORISTA: " , lr_relat.cod_motorista USING '############',
            COLUMN 29, lr_relat.nom_motorista                    CLIPPED
      PRINT COLUMN 01, "     VEICULO: " , lr_relat.veiculo       CLIPPED ,
            COLUMN 21, lr_relat.placa                            CLIPPED

      IF lr_relat.veic_ntrac1 IS NOT NULL
      OR lr_relat.veic_ntrac1 <> " " THEN
         IF lr_relat.veic_ntrac2 IS NOT NULL
         OR lr_relat.veic_ntrac2 <> " " THEN
            PRINT COLUMN 01, "    TRACAO 1: " , lr_relat.veic_ntrac1 CLIPPED,
                  COLUMN 21, lr_relat.placa1 CLIPPED,
                  COLUMN 31, "    TRACAO 2: " , lr_relat.veic_ntrac2 CLIPPED,
                  COLUMN 48,  lr_relat.placa2 CLIPPED
         ELSE
            PRINT COLUMN 01, "    TRACAO 1: " , lr_relat.veic_ntrac1 CLIPPED,
                  COLUMN 21, lr_relat.placa1 CLIPPED
         END IF
      END IF

      IF lr_relat.veic_ntrac3 IS NOT NULL
      OR lr_relat.veic_ntrac3 <> " " THEN
         IF lr_relat.veic_ntrac4 IS NOT NULL
         OR lr_relat.veic_ntrac4 <> " " THEN
            PRINT COLUMN 01, "    TRACAO 3: " , lr_relat.veic_ntrac3 CLIPPED,
                  COLUMN 21, lr_relat.placa3  CLIPPED,
                  COLUMN 31, "    TRACAO 4: " , lr_relat.veic_ntrac4 CLIPPED,
                  COLUMN 48, lr_relat.placa4  CLIPPED
         ELSE
            PRINT COLUMN 31, "    TRACAO 4: " , lr_relat.veic_ntrac4 CLIPPED,
                  COLUMN 48, lr_relat.placa4  CLIPPED
         END IF
      END IF

      SKIP 1 LINE

      PRINT COLUMN 01, "OM        PEDIDO      SEQ. ITEM            U.M PESO LIQUIDO SALDO PEDIDO "
      PRINT COLUMN 01, "--------- ---------- ----- --------------- --- ------------ -------------"

ON EVERY ROW
   PRINT COLUMN 001,lr_relat.num_om1         CLIPPED,
         COLUMN 011,lr_relat.num_pedido      CLIPPED,
         COLUMN 022,lr_relat.num_sequencia   USING '##&&&',
         COLUMN 028,lr_relat.cod_item        CLIPPED,
         COLUMN 044,lr_relat.cod_unid_med    CLIPPED,
         COLUMN 048,lr_relat.peso_liquido1   USING '####,##&.&&&',
         COLUMN 061,lr_relat.saldo_pedido    USING '####,##&.&&&'

   SELECT den_item INTO l_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = lr_relat.cod_item

   PRINT COLUMN 28, l_den_item

      AFTER GROUP OF lr_relat.num_pesagem

      SKIP 1 LINE
      PRINT COLUMN 03, "PESO BRUTO: ",
            COLUMN 16, lr_relat.peso_bruto,
            COLUMN 37, "DATA PESAGEM: ", lr_relat.data_2_pesagem,
            COLUMN 64, "HORA PESAGEM: ", lr_relat.hora_2_pesagem

      PRINT COLUMN 09, "TARA: ",
            COLUMN 16, lr_relat.tara,
            COLUMN 37, "DATA PESAGEM: ", lr_relat.data_1_pesagem,
            COLUMN 64, "HORA PESAGEM: ", lr_relat.hora_1_pesagem
      PRINT COLUMN 01, "PESO LIQUIDO: ",
            COLUMN 16, lr_relat.peso_liquido
      SKIP 1 LINE

      PRINT COLUMN 1, "     NF: " , lr_relat.num_nff CLIPPED
      PRINT COLUMN 1, "CLIENTE: " , lr_relat.cod_cliente CLIPPED ,
            COLUMN 20, ' - ',lr_relat.nom_cliente CLIPPED
      PRINT COLUMN 1, " TRANSP: ", lr_relat.cod_transpor CLIPPED,
            COLUMN 20, ' - ',lr_relat.den_transpor CLIPPED
      SKIP 4 LINE

     PRINT COLUMN 1 , "_____________________________" ,
           COLUMN 50, "_____________________________"
     PRINT COLUMN 1 , lr_relat.nom_motorista,
           COLUMN 50 , p_den_empresa

   ON LAST ROW
      LET p_last_row = true
  PAGE TRAILER
      IF p_last_row = true THEN
         PRINT "* * * ULTIMA FOLHA * * *"
      ELSE
         PRINT " "
      END IF

END REPORT

#--------------------------------#
 FUNCTION esp1556_controle_pesagem()
#--------------------------------#
  DEFINE l_situacao     CHAR(1)

  INITIALIZE m_nom_tela1 TO NULL
  LET m_total_peso_liquido = 0

  CALL log130_procura_caminho('esp15561') RETURNING m_nom_tela1
  OPEN WINDOW w_esp15561 AT 2,2 WITH FORM m_nom_tela1
     ATTRIBUTE (BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  CURRENT WINDOW IS w_esp15561

  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY BY NAME mr_esp_balanca.num_pesagem
  DISPLAY BY NAME mr_esp_balanca.dat_pesagem

  SELECT ies_situacao
    INTO l_situacao
    FROM esp_balanca
   WHERE cod_empresa = p_cod_empresa
     AND num_pesagem = mr_esp_balanca.num_pesagem

   MENU "OPCAO"
       BEFORE MENU
          CALL esp1556_pesagem_consultar()

       COMMAND "Incluir"   "Incluir pesagem. "
         IF l_situacao = '1' THEN
            CALL log0030_mensagem("Pesagem já encerrada.","info")
         ELSE
            IF l_situacao = '2' THEN
               CALL log0030_mensagem("Pesagem cancelada. ","info")
               LET m_consulta_ativa = FALSE
            ELSE
               IF esp1556_pesagem_inclui() THEN
                  CALL esp1556_finaliza_pesagem() RETURNING p_status
               END IF
            END IF
         END IF

      COMMAND "Consultar"   "Consulta pesagem "
         CALL esp1556_pesagem_consultar()

      COMMAND 'Modificar' 'Modificar pesagem'
         IF l_situacao = '1' THEN
            CALL log0030_mensagem("Pesagem já encerrada.","info")
         ELSE
            IF esp1556_modificar_array() THEN
               CALL esp1556_finaliza_pesagem() RETURNING p_status
            END IF
        END IF

      COMMAND 'Excluir' 'Excluir pesagem'
        IF mr_esp_balanca.ies_situacao = '1' THEN
           CALL log0030_mensagem("Pesagem já encerrada.","info")
        ELSE
           CALL esp1556_deleta_array()
        END IF

{
     COMMAND KEY ("C") "Cancelar Pesagem"
           IF m_consulta_ativa = TRUE THEN
              #IF mr_esp_balanca.ies_situacao = '1' THEN
              #   CALL log0030_mensagem("Pesagem ja encerrada","info")
              #   LET m_consulta_ativa = FALSE
              #ELSE
                 IF mr_esp_balanca.ies_situacao = '2' THEN
                    CALL log0030_mensagem("Pesagem JÁ Cancelada ","info")
                    LET m_consulta_ativa = FALSE
                 ELSE
                    CALL esp1556_cancelar()
                 END IF
              #END IF
           ELSE
              CALL log0030_mensagem( " Execute uma consulta previamente. ","info")
           END IF
}
       COMMAND "Fim" "Retorna ao menu anterior."
          MESSAGE ""
          EXIT MENU

   END MENU
    CLOSE WINDOW w_esp15561
    CURRENT WINDOW IS w_esp1556

END FUNCTION

#--------------------------------#
 FUNCTION esp1556_pesagem_inclui()
#--------------------------------#
 DEFINE l_ind               SMALLINT,
        l_hora_pesagem  CHAR(08)

 INITIALIZE mr_esp_balancar TO NULL
 INITIALIZE ma_telar TO NULL

 LET mr_esp_balancar.* = mr_esp_balanca.*
 LET ma_telar.* = ma_tela.*

 IF esp1556_entrada_pesagem_man_aut('INCLUSAO') THEN
    IF esp1556_entrada_dados_array('INCLUSAO') THEN
       LET l_hora_pesagem = TIME
       CALL log085_transacao("BEGIN")

       WHENEVER ERROR CONTINUE
       DELETE FROM esp_balanca_om
        WHERE cod_empresa = p_cod_empresa
          AND num_pesagem = mr_esp_balanca.num_pesagem
          AND seq_pesagem = 1
       WHENEVER ERROR STOP

       FOR l_ind = 1 to 999
          IF ma_tela[l_ind].num_om1 IS NOT NULL THEN
             INSERT INTO esp_balanca_om VALUES (p_cod_empresa,
                                                ma_tela[l_ind].num_pesagem1,
                                                1,   #sequencia verificar
                                                ma_tela[l_ind].num_om1,
                                                ma_tela[l_ind].num_pedido,
                                                ma_tela[l_ind].num_sequencia,
                                                ma_tela[l_ind].cod_item,
                                                ma_tela[l_ind].data_entrega,
                                                ma_tela[l_ind].cod_unid_med,
                                                ma_tela[l_ind].qtd_reservada,
                                                ma_tela[l_ind].peso_liquido2_ton,
                                                NULL)

              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("INSERT","esp_balanca_om")
                 RETURN FALSE
              END IF
          END IF
       END FOR

       WHENEVER ERROR CONTINUE
       UPDATE esp_balanca
          SET ton_tara                = mr_esp_balanca.ton_tara,
              ton_peso_bruto          = mr_esp_balanca.ton_peso_bruto,
              ton_peso_liquido        = mr_esp_balanca.ton_peso_liquido,
              peso_liquido            = mr_esp_balanca.peso_liquido,
              peso_bruto              = mr_esp_balanca.peso_bruto,
              tara                    = mr_esp_balanca.tara,
              peso_bruto_manual       = mr_esp_balanca.peso_bruto_manual,
              tara_manual             = mr_esp_balanca.tara_manual,
              peso_liquido_manual     = mr_esp_balanca.peso_liquido_manual,
              ton_peso_bruto_manual   = mr_esp_balanca.ton_peso_bruto_manual,
              ton_tara_manual         = mr_esp_balanca.ton_tara_manual,
              ton_peso_liquido_manual = mr_esp_balanca.ton_peso_liquido_manual,
              data_2_pesagem          = TODAY,
              hora_2_pesagem          = l_hora_pesagem,
              pesagem_2               = mr_esp_balanca.pesagem_2
        WHERE cod_empresa = p_cod_empresa
          AND num_pesagem = mr_esp_balanca.num_pesagem
       WHENEVER ERROR STOP

       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("UPDATE","esp_balanca")
          RETURN FALSE
       END IF

       CALL log085_transacao("COMMIT")
       CALL log0030_mensagem("Inclusão efetuada com sucesso. ","info")
       RETURN TRUE
    ELSE
       CALL log0030_mensagem("Inclusao cancelada.","info")
       INITIALIZE ma_tela, mr_tela3.* TO NULL
       RETURN FALSE
    END IF
 ELSE
    CALL log0030_mensagem("Inclusao cancelada.","info")
    INITIALIZE ma_tela, mr_tela3.* TO NULL
    RETURN FALSE
 END IF

END FUNCTION

#--------------------------------------#
 FUNCTION esp1556_pesagem_consultar()
#--------------------------------------#
  DEFINE l_tp_balanca   LIKE esp_balanca_compl.tp_balanca,
         l_den_balanca  CHAR(30)

  SELECT sum(peso_liquido)
    INTO m_total_peso_liquido
    FROM esp_balanca_om
   WHERE cod_empresa = p_cod_empresa
     AND num_pesagem = mr_esp_balanca.num_pesagem
     AND seq_pesagem = 1

  LET m_total_peso_liquido_ton = m_total_peso_liquido
  LET m_total_peso_liquido     = m_total_peso_liquido * 1000

  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY BY NAME mr_esp_balanca.num_pesagem
  DISPLAY BY NAME mr_esp_balanca.dat_pesagem
  DISPLAY BY NAME mr_esp_balanca.peso_bruto
  DISPLAY BY NAME mr_esp_balanca.tara
  DISPLAY BY NAME mr_esp_balanca.peso_liquido
  DISPLAY BY NAME mr_esp_balanca.ton_peso_bruto
  DISPLAY BY NAME mr_esp_balanca.ton_tara
  DISPLAY BY NAME mr_esp_balanca.ton_peso_liquido

  LET mr_tela3.pesagem_2 = "N"
  IF mr_esp_balanca.tara_manual > 0 THEN
     LET mr_tela3.pesagem_2 = "S"
  END IF

  DISPLAY mr_tela3.pesagem_2 TO pesagem_2

  DISPLAY BY NAME mr_esp_balanca.peso_bruto_manual
  DISPLAY BY NAME mr_esp_balanca.tara_manual
  DISPLAY BY NAME mr_esp_balanca.peso_liquido_manual
  DISPLAY BY NAME mr_esp_balanca.ton_peso_bruto_manual
  DISPLAY BY NAME mr_esp_balanca.ton_tara_manual
  DISPLAY BY NAME mr_esp_balanca.ton_peso_liquido_manual

  DISPLAY m_total_peso_liquido TO total_peso_liquido
  DISPLAY m_total_peso_liquido_ton TO total_peso_liquido_ton

  SELECT tp_balanca
    INTO l_tp_balanca
    FROM esp_balanca_compl
   WHERE cod_empresa = p_cod_empresa
     AND num_pesagem = mr_esp_balanca.num_pesagem

  IF l_tp_balanca IS NOT NULL
  OR l_tp_balanca <> " " THEN
     CALL esp1556_carrega_balanca(l_tp_balanca) RETURNING p_status, l_den_balanca
     DISPLAY l_tp_balanca  TO tp_balanca
     DISPLAY l_den_balanca TO desc_tp_balanca
  END IF

  CALL esp1556_exibe_array()

END FUNCTION

#--------------------------------------#
 FUNCTION esp1556_entrada_dados2()
#--------------------------------------#
  LET INT_FLAG = FALSE

  # Primeira pesagem
  IF DOWNSHIFT(m_nom_tela1) = "esp1556" THEN
     IF m_arg_num IS NULL OR m_arg_num = " " THEN
        LET mr_esp_balanca.tara             = 0
        LET mr_esp_balanca.peso_liquido     = 0
        LET mr_esp_balanca.ton_tara         = 0
        LET mr_esp_balanca.ton_peso_liquido = 0
     END IF

     LET mr_esp_balanca.peso_bruto       = 0
     LET mr_esp_balanca.ton_peso_bruto   = 0

     LET mr_esp_balanca.peso_bruto_manual       = 0
     LET mr_esp_balanca.peso_liquido_manual     = 0
     LET mr_esp_balanca.ton_peso_bruto_manual   = 0
     LET mr_esp_balanca.ton_tara_manual         = 0
     LET mr_esp_balanca.ton_peso_liquido_manual = 0

     DISPLAY BY NAME mr_esp_balanca.peso_bruto
     DISPLAY BY NAME mr_esp_balanca.tara
     DISPLAY BY NAME mr_esp_balanca.peso_liquido
     DISPLAY BY NAME mr_esp_balanca.ton_peso_bruto
     DISPLAY BY NAME mr_esp_balanca.ton_tara
     DISPLAY BY NAME mr_esp_balanca.ton_peso_liquido
     DISPLAY BY NAME mr_esp_balanca.peso_bruto_manual
     DISPLAY BY NAME mr_esp_balanca.peso_liquido_manual
     DISPLAY BY NAME mr_esp_balanca.ton_peso_bruto_manual
     DISPLAY BY NAME mr_esp_balanca.ton_tara_manual
     DISPLAY BY NAME mr_esp_balanca.ton_peso_liquido_manual

     INPUT BY NAME mr_esp_balanca.tara_manual WITHOUT DEFAULTS

     AFTER INPUT
        IF NOT INT_FLAG THEN
           IF mr_esp_balanca.tara_manual IS NULL
           OR mr_esp_balanca.tara_manual = " " THEN
              IF m_arg_num IS NULL OR m_arg_num = " " THEN
                 CALL log0030_mensagem("Tara deve ser informada.", "info")
                 NEXT FIELD tara_manual
              ELSE
                 LET mr_esp_balanca.tara_manual     = 0
                 LET mr_esp_balanca.ton_tara_manual = 0
              END IF
           END IF

           IF mr_esp_balanca.tara_manual <= 0  THEN
               IF m_arg_num IS NULL OR m_arg_num = " " THEN
                  CALL log0030_mensagem("Tara deve ser maior que zero.","info")
                  NEXT FIELD tara_manual
               END IF
           END IF
        END IF

     ON KEY(control-z)
        CALL esp1556_popup("2")

     END INPUT
  END IF

  IF INT_FLAG THEN
     RETURN FALSE
  END IF

  # Segunda pesagem
  IF DOWNSHIFT(m_nom_tela1) = "esp15561" THEN
     IF m_arg_num IS NULL OR m_arg_num = " " THEN
        LET mr_esp_balanca.peso_bruto     = 0
        LET mr_esp_balanca.ton_peso_bruto = 0
     END IF

     LET mr_esp_balanca.peso_bruto_manual     = 0
     LET mr_esp_balanca.ton_peso_bruto_manual = 0

     LET mr_esp_balanca.pesagem_2 = "S"
     LET mr_tela3.pesagem_2 = "S"

     CURRENT WINDOW IS w_esp15561
     DISPLAY mr_tela3.pesagem_2 TO pesagem_2

     IF mr_esp_balanca.pesagem_1 = "N" THEN
        LET mr_esp_balanca.tara_manual = mr_esp_balanca.tara
     END IF

     DISPLAY BY NAME mr_esp_balanca.peso_bruto
     DISPLAY BY NAME mr_esp_balanca.peso_liquido
     DISPLAY BY NAME mr_esp_balanca.ton_peso_bruto
     DISPLAY BY NAME mr_esp_balanca.ton_peso_liquido
     DISPLAY BY NAME mr_esp_balanca.tara
     DISPLAY BY NAME mr_esp_balanca.ton_tara

     DISPLAY BY NAME mr_esp_balanca.peso_bruto_manual
     DISPLAY BY NAME mr_esp_balanca.peso_liquido_manual
     DISPLAY BY NAME mr_esp_balanca.ton_peso_bruto_manual
     DISPLAY BY NAME mr_esp_balanca.ton_peso_liquido_manual
     DISPLAY BY NAME mr_esp_balanca.tara_manual
     DISPLAY BY NAME mr_esp_balanca.ton_tara_manual

     INPUT BY NAME mr_esp_balanca.peso_bruto_manual WITHOUT DEFAULTS

     AFTER INPUT
        IF NOT INT_FLAG THEN
           IF mr_esp_balanca.peso_bruto_manual IS NULL
           OR mr_esp_balanca.peso_bruto_manual = " " THEN
              IF m_arg_num IS NULL OR m_arg_num = " " THEN
                 CALL log0030_mensagem("Peso bruto deve ser informado.", "info")
                 NEXT FIELD peso_bruto_manual
              ELSE
                 LET mr_esp_balanca.peso_bruto_manual     = 0
                 LET mr_esp_balanca.ton_peso_bruto_manual = 0
              END IF
           END IF

           IF mr_esp_balanca.peso_bruto_manual <= 0  THEN
               IF m_arg_num IS NULL OR m_arg_num = " " THEN
                  CALL log0030_mensagem("Peso bruto deve ser maior que zero.","info")
                  NEXT FIELD peso_bruto_manual
               END IF
           END IF

           IF NOT esp1556_valida_categoria(mr_esp_balanca.peso_bruto_manual) THEN
              NEXT FIELD peso_bruto_manual
           END IF

           IF NOT esp1556_calcula_pesos() THEN
              NEXT FIELD peso_bruto_manual
           END IF
        END IF
     END INPUT
  END IF

  IF INT_FLAG THEN
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION esp1556_calcula_pesos()
#----------------------------------#
 DEFINE l_peso_liquido       LIKE esp_balanca.peso_liquido

 IF mr_esp_balanca.peso_bruto_manual IS NOT NULL
 OR mr_esp_balanca.peso_bruto_manual <> " " THEN
    IF mr_esp_balanca.tara_manual = 0 OR mr_esp_balanca.tara_manual IS NULL THEN
       LET mr_esp_balanca.tara_manual = 0
    END IF

    LET mr_esp_balanca.peso_liquido_manual = mr_esp_balanca.peso_bruto_manual - mr_esp_balanca.tara_manual
 END IF

 LET mr_esp_balanca.ton_peso_bruto_manual = mr_esp_balanca.peso_bruto_manual / 1000

 IF mr_esp_balanca.peso_liquido_manual IS NULL OR mr_esp_balanca.peso_liquido_manual = 0 THEN
    LET mr_esp_balanca.ton_tara_manual = mr_esp_balanca.ton_tara_manual - mr_esp_balanca.tara_manual

    IF mr_esp_balanca.ton_tara_manual IS NULL OR mr_esp_balanca.ton_tara_manual = 0 THEN
       LET mr_esp_balanca.ton_tara_manual = 0
    END IF
    LET mr_esp_balanca.ton_peso_liquido_manual = mr_esp_balanca.ton_peso_bruto_manual - mr_esp_balanca.ton_tara_manual
 ELSE
    IF mr_esp_balanca.peso_liquido_manual > mr_esp_balanca.peso_bruto_manual - mr_esp_balanca.tara_manual THEN
       CALL log0030_mensagem("Peso bruto menor que líquido.","info")
       RETURN FALSE
    END IF
    LET mr_esp_balanca.peso_liquido_manual = mr_esp_balanca.peso_bruto_manual - mr_esp_balanca.tara_manual
    LET mr_esp_balanca.ton_peso_liquido_manual = mr_esp_balanca.ton_peso_bruto_manual - mr_esp_balanca.ton_tara_manual
 END IF

 IF mr_esp_balanca.peso_liquido_manual < 0 THEN
    LET l_peso_liquido = 0
    LET l_peso_liquido = mr_esp_balanca.peso_liquido_manual * -1
 END IF

 IF mr_esp_balanca.peso_bruto_manual <= l_peso_liquido THEN
    CALL log0030_mensagem("Peso bruto menor ou igual que líquido.","info")
    RETURN FALSE
 END IF

 IF mr_esp_balanca.peso_liquido_manual = 0 THEN
    CALL log0030_mensagem("Peso bruto inválido.","info")
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#--------------------------------------------#
 FUNCTION esp1556_valida_categoria(l_peso)
#--------------------------------------------#
 DEFINE l_peso          LIKE esp_balanca.peso_bruto,
        l_peso_bruto    LIKE esp_balanca.peso_bruto

 IF m_bloq_pesagem = "S" THEN
    IF m_peso_bruto_categ > 0 THEN
       LET l_peso_bruto = m_peso_bruto_categ
       IF m_perc_tolerancia > 0 THEN
          LET l_peso_bruto = m_peso_bruto_categ + ((m_peso_bruto_categ * m_perc_tolerancia) / 100)
       END IF

       IF l_peso > l_peso_bruto THEN
          CALL log0030_mensagem("Peso ultrapassou o peso bruto da categoria.","info")
          RETURN FALSE
       END IF
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------------------#
 FUNCTION esp1556_paginacao(l_funcao)
#---------------------------------------#
   DEFINE l_funcao             CHAR(15)

   WHILE TRUE
      IF l_funcao = 'SEGUINTE' THEN
         FETCH NEXT cq_consulta  INTO mr_esp_balanca.num_pesagem
      ELSE
         FETCH PREVIOUS cq_consulta  INTO mr_esp_balanca.num_pesagem
      END IF

      IF sqlca.sqlcode = 0 THEN

         SELECT pesagem_1, num_pesagem, ies_situacao, dat_pesagem,
                cod_motorista, veiculo, observacao, peso_bruto, tara,
                peso_liquido, ton_peso_bruto, ton_tara, ton_peso_liquido,
                peso_bruto_manual, tara_manual, peso_liquido_manual,
                ton_peso_bruto_manual, ton_tara_manual, ton_peso_liquido_manual
           INTO mr_esp_balanca.pesagem_1, mr_esp_balanca.num_pesagem,
                mr_esp_balanca.ies_situacao, mr_esp_balanca.dat_pesagem,
                mr_esp_balanca.cod_motorista, mr_esp_balanca.veiculo,
                mr_esp_balanca.observacao, mr_esp_balanca.peso_bruto,
                mr_esp_balanca.tara, mr_esp_balanca.peso_liquido,
                mr_esp_balanca.ton_peso_bruto, mr_esp_balanca.ton_tara,
                mr_esp_balanca.ton_peso_liquido, mr_esp_balanca.peso_bruto_manual,
                mr_esp_balanca.tara_manual, mr_esp_balanca.peso_liquido_manual,
                mr_esp_balanca.ton_peso_bruto_manual, mr_esp_balanca.ton_tara_manual,
                mr_esp_balanca.ton_peso_liquido_manual
           FROM esp_balanca
          WHERE cod_empresa = p_cod_empresa
            AND num_pesagem = mr_esp_balanca.num_pesagem

         IF sqlca.sqlcode <> 0 THEN
            CONTINUE WHILE
         END IF
         CALL esp1556_exibe_dados()
         EXIT WHILE
      ELSE
         CALL log0030_mensagem("Nao existem mais dados nesta direcao,","info")
         LET mr_telar.* = mr_tela.*
         EXIT WHILE
      END IF
   END WHILE
END FUNCTION

#---------------------------------#
 FUNCTION esp1556_atualiza_tela1()
#---------------------------------#
 SELECT peso_bruto, tara, peso_liquido
   INTO mr_esp_balanca.peso_bruto, mr_esp_balanca.tara, mr_esp_balanca.peso_liquido
   FROM esp_balanca
  WHERE cod_empresa  = p_cod_empresa
    AND num_pesagem  = mr_esp_balanca.num_pesagem

 CURRENT WINDOW IS w_esp1556

 DISPLAY BY NAME mr_esp_balanca.peso_bruto
 DISPLAY BY NAME mr_esp_balanca.tara
 DISPLAY BY NAME mr_esp_balanca.peso_liquido

END FUNCTION

#-------------------------#
 FUNCTION esp1556_exibe_array()
#-------------------------#
 DEFINE l_ind           SMALLINT

 INITIALIZE ma_tela TO NULL

 CURRENT WINDOW IS w_esp15561

 IF mr_esp_balanca.num_pesagem <> 0 THEN
    DECLARE cq_exibe CURSOR FOR
     SELECT DISTINCT num_om, num_pesagem, num_pedido, num_sequencia,
            cod_item, data_entrega, cod_unid_med,qtd_reservada,peso_liquido
       FROM esp_balanca_om
      WHERE cod_empresa  = p_cod_empresa
        AND num_pesagem  = mr_esp_balanca.num_pesagem
        AND seq_pesagem = 1

    LET l_ind = 1

    FOREACH cq_exibe INTO  ma_tela[l_ind].num_om1,
                           ma_tela[l_ind].num_pesagem1 ,
                           ma_tela[l_ind].num_pedido,
                           ma_tela[l_ind].num_sequencia,
                           ma_tela[l_ind].cod_item,
                           ma_tela[l_ind].data_entrega,
                           ma_tela[l_ind].cod_unid_med ,
                           ma_tela[l_ind].qtd_reservada,
                           ma_tela[l_ind].peso_liquido2

       LET ma_tela[l_ind].peso_liquido2_ton = ma_tela[l_ind].peso_liquido2
       LET ma_tela[l_ind].peso_liquido2     = ma_tela[l_ind].peso_liquido2 * 1000
       LET l_ind = l_ind + 1
    END FOREACH

    CALL SET_COUNT(l_ind)

    IF l_ind <= 05 THEN
        FOR l_ind = 1 TO 05
           DISPLAY ma_tela[l_ind].* TO sr_esp15561[l_ind].*
        END FOR
    ELSE
       DISPLAY ARRAY ma_tela TO sr_esp15561.*
    END IF

 END IF

 LET mr_esp_balancar.* = mr_esp_balanca.*
 LET ma_telar.* = ma_tela.*

END FUNCTION

#--------------------------------------#
FUNCTION esp1556_finaliza_pesagem()
#--------------------------------------#
   DEFINE lr_final               RECORD
             num_om                 LIKE esp_balanca_om.num_om,
             peso_liquido           LIKE esp_balanca_om.peso_liquido,
             cod_item               LIKE esp_balanca_om.cod_item,
             num_pedido             LIKE esp_balanca_om.num_pedido,
             num_sequencia          LIKE esp_balanca_om.num_sequencia
                                 END RECORD

   DEFINE l_saldo_pedido         LIKE ped_itens.qtd_pecas_solic

 CALL log085_transacao("BEGIN")

 DECLARE cq_final CURSOR FOR
 SELECT num_om, peso_liquido, cod_item, num_pedido, num_sequencia
   FROM esp_balanca_om
  WHERE cod_empresa = p_cod_empresa
    AND num_pesagem = mr_esp_balanca.num_pesagem

 FOREACH cq_final INTO lr_final.*
       IF esp1556_finaliza_pesagem_geral(lr_final.num_om, lr_final.peso_liquido, lr_final.cod_item, lr_final.num_pedido, lr_final.num_sequencia) = FALSE THEN
          CALL log085_transacao("ROLLBACK")
          EXIT FOREACH
       END IF

        SELECT SUM(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_reserv - qtd_pecas_romaneio)
          INTO l_saldo_pedido
          FROM ped_itens
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido = lr_final.num_pedido
           AND num_sequencia =  lr_final.num_sequencia

        UPDATE esp_balanca_om SET saldo_pedido = l_saldo_pedido
         WHERE cod_empresa = p_cod_empresa
           AND num_pesagem = mr_esp_balanca.num_pesagem
           AND cod_item  = lr_final.cod_item
           AND num_pedido = lr_final.num_pedido
           AND num_sequencia = lr_final.num_sequencia

        IF sqlca.sqlcode <> 0 THEN
           CALL log085_transacao("ROLLBACK")
           CALL log0030_mensagem("Problema a alterar o saldo do pedido.","info")
           RETURN FALSE
        END IF
 END FOREACH

 IF m_encerra = TRUE THEN
    UPDATE esp_balanca SET ies_situacao = 1
     WHERE cod_empresa = p_cod_empresa
       AND num_pesagem = mr_esp_balanca.num_pesagem

    IF sqlca.sqlcode = 0 THEN
       CALL log085_transacao("COMMIT")
       CALL log0030_mensagem("Pesagem finalizada com sucesso. ","info")
       RETURN TRUE
    ELSE
       CALL log085_transacao("ROLLBACK")
       CALL log0030_mensagem("Processo de finalização da pesagem cancelada.","info")
       RETURN FALSE
    END IF
 ELSE
    CALL log085_transacao("ROLLBACK")
    CALL log0030_mensagem("Processo de finalização da pesagem cancelada.","info")
    RETURN FALSE
 END IF

END FUNCTION

#--------------------------------------------------------------------------------------------------#
 FUNCTION esp1556_finaliza_pesagem_geral(l_num_om,l_peso,l_cod_item,l_num_pedido, l_num_sequencia)
#--------------------------------------------------------------------------------------------------#
   DEFINE l_erro              SMALLINT
   DEFINE lr_estoque          RECORD LIKE estoque.*
   DEFINE l_num_om            DECIMAL(6,0)
   DEFINE l_peso              DECIMAL(10,3)
   DEFINE l_num_reserva       INTEGER
   DEFINE l_cod_item          CHAR(15)
   DEFINE l_qtd_volume_om     DECIMAL(15,3)
   DEFINE l_qtd_padr_embal    DECIMAL(12,3)
   DEFINE l_vol_padr_embal    DECIMAL(14,8)
   DEFINE l_qtd_embal_item    DECIMAL(15,3)
   DEFINE l_qtd_reservada     DECIMAL(15,3)
   DEFINE lr_ordem_montag_item RECORD LIKE ordem_montag_item.*

  DEFINE l_num_pedido          LIKE pedidos.num_pedido,
         l_num_sequencia       LIKE ped_itens.num_sequencia

   DEFINE l_saldo              DECIMAL(10,3)
   DEFINE l_txt                CHAR(500)

   DEFINE l_saldo_om           LIKE esp_balanca_om.peso_liquido,
          l_qtd_saldo          LIKE ped_itens.qtd_pecas_solic

   LET m_encerra = FALSE

   IF l_peso IS NULL OR l_peso = 0 THEN
      RETURN TRUE
   END IF

   IF l_num_om IS NULL OR l_num_om = 0 THEN
      RETURN TRUE
   END IF

   INITIALIZE lr_ordem_montag_item.* TO NULL
   DECLARE cq_fecha0 CURSOR FOR
   SELECT *
     FROM ordem_montag_item
    WHERE cod_empresa  = p_cod_empresa
      AND num_om       = l_num_om
      AND num_pedido   = l_num_pedido
      AND num_sequencia = l_num_sequencia

   OPEN cq_fecha0
   FETCH cq_fecha0 INTO lr_ordem_montag_item.*
   IF sqlca.sqlcode <> 0 THEN
      CALL log0030_mensagem('OM nao encontrado da tabela ORDEM_MONTAG_ITEM','info')
      RETURN FALSE
   END IF

   INITIALIZE l_num_reserva TO NULL
   DECLARE cq_fecha1 CURSOR FOR
   SELECT num_reserva
     FROM ordem_montag_grade
    WHERE cod_empresa   = p_cod_empresa
      AND num_om        = l_num_om
      AND num_pedido    = lr_ordem_montag_item.num_pedido
      AND num_sequencia = lr_ordem_montag_item.num_sequencia
      AND cod_item      = lr_ordem_montag_item.cod_item

   OPEN cq_fecha1
   FETCH cq_fecha1 INTO l_num_reserva
   IF sqlca.sqlcode <> 0 THEN
      CALL log0030_mensagem('OM nao encontrado da tabela ORDEM_MONTAG_GRADE','info')
      RETURN FALSE
   END IF

   INITIALIZE l_qtd_reservada TO NULL
   INITIALIZE l_cod_item TO NULL

   DECLARE cq_fecha2 CURSOR FOR
   SELECT qtd_reservada, cod_item
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND num_reserva = l_num_reserva

   OPEN cq_fecha2
   FETCH cq_fecha2 INTO l_qtd_reservada, l_cod_item

   IF sqlca.sqlcode <> 0 THEN
      CALL log0030_mensagem('QTD RESEV nao encontrado da tabela ESTOQUE_LOC_RESER','info')
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO lr_estoque.*
     FROM estoque
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = lr_ordem_montag_item.cod_item
   WHENEVER ERROR STOP

   IF l_peso > (lr_estoque.qtd_liberada + l_qtd_reservada - lr_estoque.qtd_reservada) THEN
      CALL log0030_mensagem('Saldo insuficiente para atender a OM.','info')
      RETURN FALSE
   END IF

   INITIALIZE l_qtd_padr_embal TO NULL
   INITIALIZE l_vol_padr_embal TO NULL

   DECLARE cq_fecha3 cursor for
   SELECT qtd_padr_embal, vol_padr_embal
     FROM item_embalagem
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = l_cod_item
      AND ies_tip_embal = 'N'

   OPEN cq_fecha3
   FETCH cq_fecha3 INTO l_qtd_padr_embal, l_vol_padr_embal

   IF sqlca.sqlcode <> 0 THEN
     LET l_qtd_padr_embal = 1
     LET l_vol_padr_embal = 1
   END IF

   IF l_qtd_padr_embal IS NULL THEN
      LET l_qtd_padr_embal = 1
   END IF

   IF l_vol_padr_embal IS NULL THEN
      LET l_vol_padr_embal = 1
   END IF

   LET l_qtd_volume_om = (l_peso / l_qtd_padr_embal) * l_vol_padr_embal
   LET l_qtd_embal_item = (l_peso / l_qtd_padr_embal)

   {## verifica saldo OM com saldo do array da balança
      LET l_saldo_om = 0
      SELECT sum(peso_liquido)
        INTO l_saldo_om
        FROM esp_balanca_om
       WHERE cod_empresa = p_cod_empresa
         AND num_pesagem = mr_esp_balanca.num_pesagem

      IF l_saldo_om < mr_esp_balanca.peso_liquido THEN
         INITIALIZE l_txt TO NULL
         LET l_txt = 'Peso Liquido:',l_saldo_om CLIPPED,' das OM difere do Peso liquido informado:',mr_esp_balanca.peso_liquido CLIPPED
         CALL log0030_mensagem(l_txt,'info')
         RETURN
      END IF

}

   ###atualiza pedido NO vdp2510

   LET l_saldo = 0
   IF lr_ordem_montag_item.qtd_reservada <> l_peso THEN
#      IF lr_ordem_montag_item.qtd_reservada < l_peso THEN
         LET l_saldo = l_peso - lr_ordem_montag_item.qtd_reservada
#     ELSE
#        LET l_saldo = lr_ordem_montag_item.qtd_reservada - l_peso
#     END IF

      WHENEVER ERROR CONTINUE
      UPDATE ped_itens
         SET qtd_pecas_romaneio = qtd_pecas_romaneio + l_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = lr_ordem_montag_item.num_pedido
         AND num_sequencia = lr_ordem_montag_item.num_sequencia
         AND cod_item      = lr_ordem_montag_item.cod_item
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("UPDATE","PED_ITENS")
         RETURN FALSE
      END IF
   END IF

   WHENEVER ERROR CONTINUE
   UPDATE ordem_montag_mest
      SET qtd_volume_om =   l_qtd_volume_om
    WHERE cod_empresa   = p_cod_empresa
      AND num_om        = l_num_om
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","ORDEM_MONTAG_MEST")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   UPDATE ordem_montag_item
      SET qtd_reservada   = l_peso,
          qtd_volume_item = l_qtd_volume_om
    WHERE cod_empresa     = p_cod_empresa
      AND num_om          = l_num_om
      AND num_pedido      = lr_ordem_montag_item.num_pedido
      AND num_sequencia   = lr_ordem_montag_item.num_sequencia
      AND cod_item        = lr_ordem_montag_item.cod_item
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","ORDEM_MONTAG_ITEM")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   UPDATE ordem_montag_embal
      SET qtd_pecas     = l_peso,
          qtd_embal_int = l_qtd_embal_item
    WHERE cod_empresa   = p_cod_empresa
      AND num_om        = l_num_om
      AND num_sequencia = lr_ordem_montag_item.num_sequencia
      AND cod_item      = lr_ordem_montag_item.cod_item
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","ORDEM_MONTAG_EMBAL")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   UPDATE ordem_montag_grade
      SET qtd_reservada = l_peso
    WHERE cod_empresa   = p_cod_empresa
      AND num_om        = l_num_om
      AND num_pedido    = lr_ordem_montag_item.num_pedido
      AND num_sequencia = lr_ordem_montag_item.num_sequencia
      AND cod_item      = lr_ordem_montag_item.cod_item
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","ORDEM_MONTAG_GRADE")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   UPDATE estoque
      SET qtd_reservada = qtd_reservada - l_qtd_reservada
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = lr_ordem_montag_item.cod_item
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","ESTOQUE")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   UPDATE estoque_loc_reser
      SET qtd_reservada = l_peso
    WHERE cod_empresa   = p_cod_empresa
      AND num_reserva   = l_num_reserva
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","ESTOQUE_LOC_ENDER")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   UPDATE sup_resv_lote_est
      SET qtd_reservada = l_peso
    WHERE empresa            = p_cod_empresa
      AND num_trans_resv_est = l_num_reserva
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","SUP_RESV_LOTE_EST")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   UPDATE estoque
      SET qtd_reservada = qtd_reservada + l_peso
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = lr_ordem_montag_item.cod_item
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","ESTOQUE")
      RETURN FALSE
   END IF

   LET m_encerra = TRUE

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION esp1556_listar()
#------------------------------#
DEFINE lr_relat       RECORD
       num_pesagem               LIKE esp_balanca.num_pesagem,
       dat_pesagem               LIKE esp_balanca.dat_pesagem ,
       cod_motorista             LIKE esp_balanca.cod_motorista,
       nom_motorista             LIKE esp_balanca_motorista.nom_motorista,
       veiculo                   LIKE esp_balanca.cod_motorista,
       placa                     LIKE esp_balanca_veiculo.placa,
       veic_ntrac1               LIKE esp_balanca_compl.veic_ntrac1,
       placa1                    LIKE esp_balanca_veiculo.placa,
       veic_ntrac2               LIKE esp_balanca_compl.veic_ntrac2,
       placa2                    LIKE esp_balanca_veiculo.placa,
       veic_ntrac3               LIKE esp_balanca_compl.veic_ntrac3,
       placa3                    LIKE esp_balanca_veiculo.placa,
       veic_ntrac4               LIKE esp_balanca_compl.veic_ntrac4 ,
       placa4                    LIKE esp_balanca_veiculo.placa,
       num_nff                   LIKE ordem_montag_mest.num_nff,
       cod_transpor              LIKE ordem_montag_mest.cod_transpor,
       den_transpor              LIKE transport.den_transpor,
       cod_cliente               LIKE pedidos.cod_cliente,
       nom_cliente               LIKE clientes.nom_cliente,
       peso_bruto                LIKE esp_balanca.peso_bruto,
       tara                      LIKE esp_balanca.tara,
       peso_liquido              LIKE esp_balanca.peso_liquido,
       num_om1                   LIKE ordem_montag_grade.num_om,
       num_pedido                LIKE ordem_montag_grade.num_pedido,
       num_sequencia             LIKE esp_balanca_om.num_sequencia,
       cod_item                  LIKE esp_balanca_om.cod_item,
       cod_unid_med              LIKE esp_balanca_om.cod_unid_med,
       peso_liquido1             LIKE esp_balanca_om.peso_liquido,
       saldo_pedido              LIKE esp_balanca_om.peso_liquido,
       data_1_pesagem            DATE,
       hora_1_pesagem            CHAR(08),
       data_2_pesagem            DATE,
       hora_2_pesagem            CHAR(08)
                     END RECORD

 DEFINE l_peso_bruto_manual         LIKE esp_balanca.peso_bruto_manual,
        l_tara_manual               LIKE esp_balanca.tara_manual,
        l_peso_liquido_manual       LIKE esp_balanca.peso_liquido_manual,
        l_peso_bruto                LIKE esp_balanca.peso_bruto,
        l_tara                      LIKE esp_balanca.tara,
        l_peso_liquido              LIKE esp_balanca.peso_liquido,
        l_pesagem_1                 LIKE esp_balanca.pesagem_1,
        l_pesagem_2                 LIKE esp_balanca.pesagem_2

DEFINE l_num_pesagem    LIKE esp_balanca_om.num_pesagem
DEFINE l_parametro      CHAR(1000),
       l_impressao      SMALLINT,
       l_sql_stmt       CHAR(2000),
       l_sql_stmt2      CHAR(500),
       l_msg            CHAR(100)

DEFINE lr_tela          RECORD
       num_pesagem_de   LIKE esp_balanca.num_pesagem,
       num_pesagem_ate LIKE esp_balanca.num_pesagem,
       num_om_de       LIKE esp_balanca_om.num_om,
       num_om_ate      LIKE esp_balanca_om.num_om
                        END RECORD

  CALL log130_procura_caminho('esp15564') RETURNING m_nom_tela1
  OPEN WINDOW w_esp15564 AT 2,2 WITH FORM m_nom_tela1
     ATTRIBUTE (BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  CURRENT WINDOW IS w_esp15554
  INITIALIZE lr_tela.* TO NULL

  DISPLAY p_cod_empresa TO cod_empresa

     INPUT BY NAME lr_tela.* WITHOUT DEFAULTS

     AFTER INPUT
         IF NOT INT_FLAG THEN
            IF lr_tela.num_pesagem_de IS NOT NULL AND lr_tela.num_pesagem_ate IS NOT NULL THEN
               IF lr_tela.num_pesagem_de > lr_tela.num_pesagem_ate THEN
                  CALL log0030_mensagem("Pesagem inicial deve ser menor que pesagem final.","info")
                  NEXT FIELD num_pesagem_de
               END IF
            END IF
            IF lr_tela.num_om_de IS NOT NULL AND lr_tela.num_om_ate IS NOT NULL THEN
               IF lr_tela.num_om_de > lr_tela.num_om_ate THEN
                  CALL log0030_mensagem("OM inicial deve ser menor que OM final.","info")
                  NEXT FIELD num_om_de
               END IF
            END IF
         END IF

     END INPUT

  IF INT_FLAG <> 0 THEN
     CLOSE WINDOW w_esp15564
     CURRENT WINDOW IS w_esp1556
     LET INT_FLAG = 0
     CALL log0030_mensagem("Entrada de dados cancelado.","info")
     RETURN
  END IF

  IF log0280_saida_relat(18,41) IS NULL THEN
     RETURN
  END IF

  SELECT den_empresa
    INTO p_den_empresa
    FROM empresa
   WHERE empresa.cod_empresa = p_cod_empresa

  MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)

  IF p_ies_impressao = 'S' THEN
      IF g_ies_ambiente = 'W' THEN
          CALL log150_procura_caminho('LST')
          RETURNING m_caminho
          LET m_caminho = m_caminho CLIPPED, 'esp1556.tmp'
          START REPORT esp1556_relat_om to m_caminho
      ELSE
          START REPORT esp1556_relat_om to PIPE p_nom_arquivo
      END IF
  ELSE
      START REPORT esp1556_relat_om TO p_nom_arquivo
  END IF

 LET l_impressao = FALSE
 LET l_sql_stmt =
  " SELECT esp_balanca.num_pesagem, esp_balanca.dat_pesagem, ",
  "        esp_balanca.cod_motorista, esp_balanca.veiculo, ",
  "        esp_balanca_compl.veic_ntrac1,esp_balanca_compl.veic_ntrac2, ",
  "        esp_balanca_compl.veic_ntrac3, esp_balanca_compl.veic_ntrac4, ",
  "        esp_balanca.peso_bruto, esp_balanca.tara, esp_balanca.peso_liquido, ",
  "        dat_inclusao, hora_1_pesagem, data_2_pesagem, hora_2_pesagem, ",
  "        peso_bruto_manual, tara_manual, peso_liquido_manual, esp_balanca.pesagem_1, ",
  "        esp_balanca.pesagem_2 ",
  "   FROM esp_balanca, esp_balanca_compl ",
  "  WHERE esp_balanca.cod_empresa   = ", log0800_string(p_cod_empresa)

 IF lr_tela.num_pesagem_de IS NOT NULL THEN
    LET l_sql_stmt = l_sql_stmt CLIPPED, "   AND esp_balanca.num_pesagem   >= '",lr_tela.num_pesagem_de,"' "
 END IF

 IF lr_tela.num_pesagem_ate IS NOT NULL THEN
    LET l_sql_stmt = l_sql_stmt CLIPPED, "   AND esp_balanca.num_pesagem   <= '",lr_tela.num_pesagem_ate,"' "
 END IF

   LET l_sql_stmt = l_sql_stmt CLIPPED,
  "     AND esp_balanca_compl.cod_empresa   = esp_balanca.cod_empresa ",
  "     AND esp_balanca_compl.num_pesagem   = esp_balanca.num_pesagem ",
  "     ORDER BY esp_balanca.num_pesagem "

  PREPARE var_query2  FROM l_sql_stmt
  DECLARE cq_relat CURSOR FOR var_query2

  FOREACH cq_relat INTO lr_relat.num_pesagem, lr_relat.dat_pesagem,
                        lr_relat.cod_motorista, lr_relat.veiculo,
                        lr_relat.veic_ntrac1, lr_relat.veic_ntrac2,
                        lr_relat.veic_ntrac3, lr_relat.veic_ntrac4,
                        l_peso_bruto, l_tara, l_peso_liquido, lr_relat.data_1_pesagem,
                        lr_relat.hora_1_pesagem,lr_relat.data_2_pesagem,
                        lr_relat.hora_2_pesagem, l_peso_bruto_manual, l_tara_manual,
                        l_peso_liquido_manual, l_pesagem_1, l_pesagem_2

     SELECT placa
       INTO lr_relat.placa
       FROM esp_balanca_veiculo
      WHERE cod_empresa = p_cod_empresa
        AND veiculo     =  lr_relat.veiculo

     SELECT nom_motorista
       INTO lr_relat.nom_motorista
       FROM esp_balanca_motorista
      WHERE cod_empresa = p_cod_empresa
        AND motorista   =  lr_relat.cod_motorista

     IF lr_relat.veic_ntrac1 IS NOT NULL
     OR lr_relat.veic_ntrac1 <> " " THEN
        SELECT placa
          INTO lr_relat.placa1
          FROM esp_balanca_veiculo
         WHERE cod_empresa = p_cod_empresa
           AND veiculo     =  lr_relat.veic_ntrac1
           AND veiculo_tracionad = 'N'
      END IF

     IF lr_relat.veic_ntrac2 IS NOT NULL
     OR lr_relat.veic_ntrac2 <> " " THEN
        SELECT placa
          INTO lr_relat.placa2
          FROM esp_balanca_veiculo
         WHERE cod_empresa = p_cod_empresa
           AND veiculo     =  lr_relat.veic_ntrac2
           AND veiculo_tracionad = 'N'
     END IF

     IF lr_relat.veic_ntrac3 IS NOT NULL
     OR lr_relat.veic_ntrac3 <> " " THEN
        SELECT placa
          INTO lr_relat.placa3
          FROM esp_balanca_veiculo
         WHERE cod_empresa = p_cod_empresa
           AND veiculo     =  lr_relat.veic_ntrac3
           AND veiculo_tracionad = 'N'
     END IF

     IF lr_relat.veic_ntrac4 IS NOT NULL
     OR lr_relat.veic_ntrac4 <> " " THEN
        SELECT placa
          INTO lr_relat.placa4
          FROM esp_balanca_veiculo
         WHERE cod_empresa = p_cod_empresa
           AND veiculo     =  lr_relat.veic_ntrac4
           AND veiculo_tracionad = 'N'
     END IF

     IF l_pesagem_2 IS NOT NULL THEN
        IF l_pesagem_2 = "S" THEN
           LET lr_relat.peso_bruto   = l_peso_bruto_manual
           LET lr_relat.tara         = l_tara_manual
           LET lr_relat.peso_liquido = l_peso_liquido_manual
        ELSE
           LET lr_relat.peso_bruto   = l_peso_bruto
           LET lr_relat.tara         = l_tara
           LET lr_relat.peso_liquido = l_peso_liquido
        END IF
     ELSE
        IF l_pesagem_1 = "S" THEN
           LET lr_relat.peso_bruto   = l_peso_bruto_manual
           LET lr_relat.tara         = l_tara_manual
           LET lr_relat.peso_liquido = l_peso_liquido_manual
        ELSE
           LET lr_relat.peso_bruto   = l_peso_bruto
           LET lr_relat.tara         = l_tara
           LET lr_relat.peso_liquido = l_peso_liquido
        END IF
     END IF

     LET l_sql_stmt2 =
       " SELECT num_om, num_pedido, num_sequencia, cod_item, cod_unid_med, peso_liquido, saldo_pedido ",
         " FROM esp_balanca_om ",
        " WHERE cod_empresa =  '",p_cod_empresa,"' ",
          " AND num_pesagem =  '",lr_relat.num_pesagem,"' "

     IF lr_tela.num_om_de IS NOT NULL THEN
        LET l_sql_stmt2 = l_sql_stmt2 CLIPPED, "   AND num_om >= '",lr_tela.num_om_de,"' "
     END IF

     IF lr_tela.num_om_ate IS NOT NULL THEN
        LET l_sql_stmt2 = l_sql_stmt2 CLIPPED, "   AND num_om <= '",lr_tela.num_om_ate,"' "
     END IF

     PREPARE var_qry FROM l_sql_stmt2
     DECLARE cq_relat2 CURSOR FOR var_qry
     FOREACH cq_relat2 INTO lr_relat.num_om1, lr_relat.num_pedido,
                            lr_relat.num_sequencia,lr_relat.cod_item,
                            lr_relat.cod_unid_med, lr_relat.peso_liquido1,
                            lr_relat.saldo_pedido

        SELECT a.num_nff, c.transportadora, b.nom_cliente
          INTO lr_relat.num_nff, lr_relat.cod_transpor, lr_relat.den_transpor
          FROM ordem_montag_mest a, OUTER clientes b, fat_nf_mestre c
         WHERE a.cod_empresa  = p_cod_empresa
           AND a.num_om       = lr_relat.num_om1
           and c.empresa = a.cod_empresa
           and c.nota_fiscal  = a.num_nff
           AND b.cod_cliente = c.transportadora

        SELECT a.cod_cliente, b.nom_cliente
          INTO lr_relat.cod_cliente, lr_relat.nom_cliente
          FROM pedidos a, clientes b
         WHERE a.cod_cliente = b.cod_cliente
           AND a.cod_empresa = p_cod_empresa
           AND a.num_pedido  = lr_relat.num_pedido

        LET l_impressao = TRUE
        OUTPUT TO REPORT esp1556_relat_om(lr_relat.*)

     END FOREACH
  END FOREACH

  FINISH REPORT esp1556_relat_om

  MESSAGE " "

  IF g_ies_ambiente = "W" AND p_ies_impressao = "S"  THEN
     LET m_comando = "lpdos.bat ", m_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
     RUN m_comando
  END IF

  IF l_impressao = TRUE THEN
     IF p_ies_impressao = "S" THEN
        LET l_msg = "Relatório impresso com sucesso."
        CALL log0030_mensagem(l_msg, "info")
     ELSE
        LET l_msg = "Relatorio gravado no arquivo ", p_nom_arquivo CLIPPED
        CALL log0030_mensagem(l_msg, "info")
     END IF
  ELSE
     CALL log0030_mensagem("Não existem dados para serem listados.","info")
  END IF

END FUNCTION

#------------------------------------------------#
 FUNCTION esp1556_entrada_pesagem_man_aut(l_flag)
#------------------------------------------------#
DEFINE l_peso_bruto     LIKE esp_balanca.peso_bruto,
       l_peso_liquido   LIKE esp_balanca.peso_liquido,
       l_tara           LIKE esp_balanca.tara,
       l_ind            DECIMAL(17,0),
       l_flag           CHAR(15)

   IF l_flag = 'INCLUSAO' THEN
      SELECT COUNT(*) INTO l_ind
        FROM esp_balanca_om
       WHERE cod_empresa = p_cod_empresa
         AND num_pesagem = mr_esp_balanca.num_pesagem

      IF l_ind IS NOT NULL THEN
         IF l_ind > 0 THEN
            CALL log0030_mensagem('Já existe registro incluido, favor efetuar modificação.','info')
            RETURN FALSE
         END IF
      END IF
   END IF

   CURRENT WINDOW IS w_esp15561
   INPUT BY NAME mr_tela3.tp_balanca, mr_tela3.pesagem_2 WITHOUT DEFAULTS

      AFTER FIELD tp_balanca
         IF mr_tela3.tp_balanca IS NULL
         OR mr_tela3.tp_balanca = " " THEN
             CALL log0030_mensagem("Balança deve ser informada.","info")
             NEXT FIELD tp_balanca
         END IF

         IF mr_tela3.tp_balanca IS NOT NULL
         OR mr_tela3.tp_balanca <> " " THEN
            CALL esp1556_carrega_balanca(mr_tela3.tp_balanca)
                 RETURNING p_status, mr_tela3.desc_tp_balanca

            IF NOT p_status THEN
               CALL log0030_mensagem("Balança não cadastrada.","info")
               NEXT FIELD tp_balanca
            END IF
            DISPLAY mr_tela3.desc_tp_balanca TO desc_tp_balanca
         END IF

         IF NOT esp1556_pop_pesagem() THEN
            NEXT FIELD tp_balanca
         END IF

         CURRENT WINDOW IS w_esp15561
         CALL esp1556_seta_valores()

         IF mr_esp_balanca.peso_bruto_manual IS NOT NULL AND mr_esp_balanca.peso_bruto_manual > 0 THEN
            EXIT INPUT
         ELSE
            NEXT FIELD pesagem_2
         END IF

      AFTER FIELD pesagem_2
         IF mr_tela3.pesagem_2 IS NOT NULL THEN
            IF mr_tela3.pesagem_2 = "S" THEN
               IF esp1556_entrada_dados2() THEN
                  CALL esp1556_seta_valores()
               END IF
            END IF
         END IF

   ON KEY(control-z)
      CALL esp1556_popup("2")

   END INPUT

   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------------#
 FUNCTION esp1556_seta_valores()
#----------------------------------------#
 IF m_arg_num IS NOT NULL OR m_arg_num <> " " THEN
    IF DOWNSHIFT(m_nom_tela1) = "esp1556" THEN
       LET mr_esp_balanca.tara = m_arg_num
       LET mr_esp_balanca.peso_bruto = 0
    ELSE
       LET mr_esp_balanca.peso_bruto = m_arg_num
    END IF
 END IF

 IF DOWNSHIFT(m_nom_tela1) = "esp1556" THEN
    CURRENT WINDOW IS w_esp1556
 ELSE
    CURRENT WINDOW IS w_esp15561
 END IF

 IF m_arg_num IS NOT NULL OR m_arg_num <> " " THEN
    IF DOWNSHIFT(m_nom_tela1) = "esp1556" THEN
       IF mr_esp_balanca.tara_manual IS NOT NULL AND mr_esp_balanca.tara_manual > 0 THEN
          LET mr_esp_balanca.pesagem_1 = "S"
       ELSE
          LET mr_esp_balanca.pesagem_1 = "N"
       END IF
       DISPLAY BY NAME mr_esp_balanca.pesagem_1
    ELSE
       IF mr_esp_balanca.peso_bruto_manual IS NOT NULL AND mr_esp_balanca.peso_bruto_manual > 0 THEN
          LET mr_tela3.pesagem_2 = "S"
       ELSE
          LET mr_tela3.pesagem_2 = "N"
       END IF
       DISPLAY mr_tela3.pesagem_2 TO pesagem_2
       LET mr_esp_balanca.pesagem_2 = mr_tela3.pesagem_2
    END IF
 END IF

 IF m_arg_num IS NULL OR m_arg_num = " " THEN
    IF DOWNSHIFT(m_nom_tela1) = "esp1556" THEN
       LET mr_esp_balanca.pesagem_1 = "S"
       DISPLAY BY NAME mr_esp_balanca.pesagem_1
    ELSE
       LET mr_tela3.pesagem_2 = "S"
       DISPLAY mr_tela3.pesagem_2 TO pesagem_2
       LET mr_esp_balanca.pesagem_2 = mr_tela3.pesagem_2
    END IF
 END IF

 # se a primeira pesagem é automática e a segunda manual:
 IF mr_esp_balanca.pesagem_1 = "N" AND mr_esp_balanca.pesagem_2 = "S" THEN
    LET mr_esp_balanca.tara_manual = mr_esp_balanca.tara
 END IF

 # se a primeira pesagem é manual e a segunda automática:
 IF mr_esp_balanca.pesagem_1 = "S" AND mr_esp_balanca.pesagem_2 = "N" THEN
    IF DOWNSHIFT(m_nom_tela1) = "esp15561" THEN
       LET mr_esp_balanca.tara = mr_esp_balanca.tara_manual
    END IF
 END IF

 LET mr_esp_balanca.peso_liquido             = mr_esp_balanca.peso_bruto - mr_esp_balanca.tara
 LET mr_esp_balanca.ton_peso_bruto           = mr_esp_balanca.peso_bruto / 1000
 LET mr_esp_balanca.ton_tara                 = mr_esp_balanca.tara / 1000
 LET mr_esp_balanca.ton_peso_liquido         = mr_esp_balanca.ton_peso_bruto - mr_esp_balanca.ton_tara

 LET mr_esp_balanca.peso_liquido_manual     = mr_esp_balanca.peso_bruto_manual - mr_esp_balanca.tara_manual
 LET mr_esp_balanca.ton_peso_bruto_manual   = mr_esp_balanca.peso_bruto_manual / 1000
 LET mr_esp_balanca.ton_tara_manual         = mr_esp_balanca.tara_manual / 1000
 LET mr_esp_balanca.ton_peso_liquido_manual = mr_esp_balanca.ton_peso_bruto_manual - mr_esp_balanca.ton_tara_manual

 DISPLAY BY NAME mr_esp_balanca.tara
 DISPLAY BY NAME mr_esp_balanca.ton_tara
 DISPLAY BY NAME mr_esp_balanca.peso_bruto
 DISPLAY BY NAME mr_esp_balanca.peso_liquido
 DISPLAY BY NAME mr_esp_balanca.ton_peso_bruto
 DISPLAY BY NAME mr_esp_balanca.ton_peso_liquido

 DISPLAY BY NAME mr_esp_balanca.tara_manual
 DISPLAY BY NAME mr_esp_balanca.peso_bruto_manual
 DISPLAY BY NAME mr_esp_balanca.peso_liquido_manual
 DISPLAY BY NAME mr_esp_balanca.ton_peso_bruto_manual
 DISPLAY BY NAME mr_esp_balanca.ton_tara_manual
 DISPLAY BY NAME mr_esp_balanca.ton_peso_liquido_manual

 END FUNCTION

#-----------------------------#
 FUNCTION esp1556_pop_pesagem()
#-----------------------------#
   DEFINE l_arquivo      CHAR(150),
          l_var          SMALLINT

   DEFINE l_comando          CHAR(150),
          l_num_programa     LIKE tran_arg.num_programa,
          l_status           SMALLINT

   LET m_arg_num = NULL
   LET l_var     = 0

   ###CHAMADA DE PROGRAMA EXTERNO
   LET l_num_programa = "JAVA",mr_tela3.tp_balanca CLIPPED

   WHENEVER ERROR CONTINUE
    DELETE FROM tran_arg
     WHERE num_programa = l_num_programa
   WHENEVER ERROR STOP

   #lds LET l_arquivo = m_bat
   #MESSAGE l_arquivo ATTRIBUTE(REVERSE)
   #lds CALL runOnClient(l_arquivo)

   LET l_status = TRUE

   WHILE TRUE
      MESSAGE '' SLEEP 1

      WHENEVER ERROR CONTINUE
       SELECT arg_num
         INTO m_arg_num
         FROM tran_arg
        WHERE num_programa = l_num_programa
      WHENEVER ERROR STOP

      IF m_arg_num IS NOT NULL OR m_arg_num <> " " THEN
         EXIT WHILE
      END IF

      IF l_var = 30 THEN

         IF log0040_confirm(10,30,"Peso não importado, deseja incluir manual?") THEN
            CALL esp1556_entrada_dados2() RETURNING l_status
            EXIT WHILE
         ELSE
            LET l_var = 0
         END IF
      END IF

      LET l_var = l_var + 1
   END WHILE

   IF NOT l_status THEN
      RETURN FALSE
   END IF

   IF m_arg_num IS NOT NULL OR m_arg_num <> " " THEN
      IF NOT esp1556_valida_categoria(m_arg_num) THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

{
#--------------------------------------------#
FUNCTION esp1556_cancelar()
#--------------------------------------------#
   IF log0040_confirm(10,10,'Deseja Realmente Cancelar ' ) = FALSE THEN
      ERROR "Cancelamento Cancelada"
      RETURN
   END IF

   UPDATE esp_balanca SET ies_situacao = '2',
                          peso_bruto = '0',
                          peso_liquido = '0',
                          tara = '0',
                       _alteracao = TODAY,
                          usu_alteracao = p_user
    WHERE cod_empresa = p_cod_empresa
      AND num_pesagem = mr_esp_balanca.num_pesagem

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('UPDATE','esp_balanca')
      CALL log085_transacao('ROLLBACK')
      MESSAGE ' '
      ERROR 'Falha ao cancelar'
   ELSE
      CALL log085_transacao('COMMIT')
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET m_consulta_ativa = FALSE
      MESSAGE 'Cancelamento efetuado com sucesso'
   END IF

END FUNCTION
}
#--------------------------------------------#
FUNCTION esp1556_entrada_dados_array(l_funcao)
#--------------------------------------------#
DEFINE l_ind          SMALLINT,
       l_arr_curr     SMALLINT,
       l_scr_line     SMALLINT,
       l_arr_count    SMALLINT,
       l_funcao       CHAR(15),
       l_qtd_reservada LIKE ordem_montag_item.qtd_reservada,
       l_saldo        LIKE estoque.qtd_liberada,
       l_qtd_om       LIKE estoque.qtd_liberada,
       l_qtd_saldo    LIKE ped_itens.qtd_pecas_solic,
       l_qtd_pecas    LIKE ped_itens.qtd_pecas_solic,
       l_msg          CHAR(100)

   LET INT_FLAG = 0
   LET m_total_peso_liquido = 0
   LET m_total_peso_liquido_ton = 0

   IF l_funcao = "INCLUSAO" THEN
      LET m_ind = 0
      INITIALIZE ma_tela TO NULL
   ELSE
      SELECT COUNT(*)
        INTO m_ind
        FROM esp_balanca_om
       WHERE cod_empresa = p_cod_empresa
         AND num_pesagem = mr_esp_balanca.num_pesagem
   END IF

   LET m_ind = m_ind + 1

   CALL SET_COUNT(m_ind)
   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM sr_esp15561.*

      AFTER  DELETE
         LET m_total_peso_liquido = 0
         LET m_total_peso_liquido_ton = 0
         FOR l_ind = 1 TO 999
               IF ma_tela[l_ind].num_om1 IS NOT  NULL
               OR ma_tela[l_ind].num_om1 <> ' ' THEN
                  LET m_total_peso_liquido = m_total_peso_liquido + ma_tela[l_ind].peso_liquido2
                  LET m_total_peso_liquido_ton = m_total_peso_liquido /1000
               ELSE
                  EXIT FOR
               END IF
            END FOR
            DISPLAY m_total_peso_liquido      TO total_peso_liquido
            DISPLAY m_total_peso_liquido_ton  TO total_peso_liquido_ton

      BEFORE ROW

         LET l_arr_curr   = ARR_CURR()
         LET l_scr_line   = SCR_LINE()
         LET l_arr_count  = ARR_COUNT()

      AFTER FIELD num_om1
       IF ma_tela[l_arr_curr].num_om1 IS NOT NULL
       OR ma_tela[l_arr_curr].num_om1 <> " " THEN

         FOR l_ind = 1 TO 999
            IF l_arr_curr <> l_ind THEN
               IF ma_tela[l_arr_curr].num_om1 = ma_tela[l_ind].num_om1 THEN
                  CALL log0030_mensagem("OM já informada.","info")
                  NEXT FIELD num_om1
               END IF
            END IF
         END FOR

         SELECT num_om
           FROM esp_balanca_om
          WHERE cod_empresa = p_cod_empresa
            AND num_om      = ma_tela[l_arr_curr].num_om1
            AND num_pesagem <> mr_esp_balanca.num_pesagem

         IF sqlca.sqlcode = 0 THEN
            CALL log0030_mensagem("OM já informada.","info")
            NEXT FIELD num_om1
         END IF

         WHENEVER ERROR CONTINUE
         SELECT UNIQUE num_om
           FROM ordem_montag_mest
          WHERE cod_empresa = p_cod_empresa
            AND num_om      = ma_tela[l_arr_curr].num_om1
            AND ies_sit_om  = 'F'
         WHENEVER ERROR STOP

         IF sqlca.sqlcode = 0 THEN
            CALL log0030_mensagem("OM já faturada.","info")
            NEXT FIELD num_om1
         END IF

         WHENEVER ERROR CONTINUE
         SELECT distinct(ordem_montag_item.cod_empresa)
           FROM ordem_montag_item, item, pedidos
          WHERE ordem_montag_item.cod_empresa = p_cod_empresa
            AND ordem_montag_item.num_om      = ma_tela[l_arr_curr].num_om1
            AND item.cod_empresa    = p_cod_empresa
            AND item.cod_item       = ordem_montag_item.cod_item
            AND pedidos.cod_empresa = ordem_montag_item.cod_empresa
            AND pedidos.num_pedido  = ordem_montag_item.num_pedido
         WHENEVER ERROR STOP

         IF sqlca.sqlcode = NOTFOUND THEN
            CALL log0030_mensagem("OM nao cadastrada","info")
            NEXT FIELD num_om1
         END IF

         WHENEVER ERROR CONTINUE
          SELECT SUM(a.qtd_pecas_solic - a.qtd_pecas_atend - a.qtd_pecas_cancel - a.qtd_pecas_reserv - a.qtd_pecas_romaneio)
            INTO l_qtd_saldo
            FROM ped_itens a, ordem_montag_item b, item c, pedidos d
           WHERE b.cod_empresa = p_cod_empresa
             AND b.num_om      = ma_tela[l_arr_curr].num_om1
             AND c.cod_empresa = p_cod_empresa
             AND c.cod_item    = b.cod_item
             AND d.cod_empresa = b.cod_empresa
             AND d.num_pedido  = b.num_pedido
             AND a.cod_empresa = p_cod_empresa
             AND a.num_pedido  = d.num_pedido
         WHENEVER ERROR STOP

         IF SQLCA.SQLCODE = 0 THEN
            IF l_qtd_saldo < 0 THEN
               CALL log0030_mensagem('Saldo insuficiente para atender a OM.','info')
               NEXT FIELD num_om1
            END IF
         END IF

         CALL esp1556_carrega_array(ARR_CURR())
       END IF

       IF l_arr_curr = 1 THEN
          IF mr_tela3.pesagem_2 = "S" THEN
             LET ma_tela[l_arr_curr].peso_liquido2 = mr_esp_balanca.peso_liquido_manual
          ELSE
             LET ma_tela[l_arr_curr].peso_liquido2 = mr_esp_balanca.peso_liquido
          END IF
          DISPLAY ma_tela[l_arr_curr].peso_liquido2 TO sr_esp15561[l_scr_line].peso_liquido2
       END IF

       LET ma_tela[l_arr_curr].peso_liquido2_ton = ma_tela[l_arr_curr].peso_liquido2 / 1000
       DISPLAY ma_tela[l_arr_curr].peso_liquido2_ton TO sr_esp15561[l_scr_line].peso_liquido2_ton

       LET m_total_peso_liquido     = m_total_peso_liquido + ma_tela[l_arr_curr].peso_liquido2
       LET m_total_peso_liquido_ton = m_total_peso_liquido /1000

       DISPLAY m_total_peso_liquido     TO total_peso_liquido
       DISPLAY m_total_peso_liquido_ton TO total_peso_liquido_ton

       IF ma_tela[l_arr_curr].num_om1 IS NOT NULL THEN
          SELECT (a.qtd_pecas_solic - a.qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_reserv - a.qtd_pecas_romaneio)
            INTO l_qtd_pecas
            FROM ped_itens a, ordem_montag_item b
           WHERE a.cod_empresa   = p_cod_empresa
             AND a.cod_item      = ma_tela[l_arr_curr].cod_item
             AND b.cod_empresa   = a.cod_empresa
             AND b.num_om        = ma_tela[l_arr_curr].num_om1
             AND b.cod_item      = a.cod_item
             AND b.num_pedido    = a.num_pedido
             AND b.num_sequencia = a.num_sequencia

          IF (l_qtd_pecas + ma_tela[l_arr_curr].qtd_reservada - m_total_peso_liquido_ton) < 0 THEN
             CALL log0030_mensagem("Peso da OM maior que SALDO DO PEDIDO do item.","info")
             NEXT FIELD num_om1
          END IF
       END IF

   AFTER INPUT
      IF INT_FLAG = 0 THEN
         FOR l_ind = 1 TO 999
            IF ma_tela[l_ind].num_om1 IS NOT NULL
            OR ma_tela[l_ind].num_om1 <> ' ' THEN
               IF ma_tela[l_arr_curr].peso_liquido2 IS NOT NULL
               OR ma_tela[l_arr_curr].peso_liquido2 <> " "
               OR ma_tela[l_arr_curr].peso_liquido2 <> 0 THEN

                  LET ma_tela[l_arr_curr].peso_liquido2_ton = 0
                  LET ma_tela[l_arr_curr].peso_liquido2_ton = ma_tela[l_arr_curr].peso_liquido2 / 1000

                  LET m_total_peso_liquido = 0
                  LET m_total_peso_liquido_ton = 0
                  FOR l_ind = 1 TO 999
                     IF ma_tela[l_ind].num_om1 IS NOT  NULL
                     OR ma_tela[l_ind].num_om1 <> ' ' THEN
                        LET m_total_peso_liquido = m_total_peso_liquido + ma_tela[l_ind].peso_liquido2
                        LET m_total_peso_liquido_ton = m_total_peso_liquido / 1000
                     ELSE
                        EXIT FOR
                     END IF
                  END FOR

                  DISPLAY ma_tela[l_arr_curr].peso_liquido2_ton TO peso_liquido2_ton
                  DISPLAY m_total_peso_liquido                  TO total_peso_liquido
                  DISPLAY m_total_peso_liquido_ton              TO total_peso_liquido_ton

               END IF
            ELSE
               EXIT FOR
            END IF
         END FOR
      END IF

   END INPUT

  IF INT_FLAG = 0 THEN
     RETURN TRUE
  ELSE
     LET INT_FLAG = 0
     LET  ma_tela[l_arr_curr].peso_liquido2 = " "
     RETURN FALSE
  END IF

END FUNCTION

#-----------------------------------------------#
 FUNCTION esp1556_carrega_balanca(l_tp_balanca)
#-----------------------------------------------#
 DEFINE l_tp_balanca     CHAR(05),
        l_den_balanca    CHAR(30)

 WHENEVER ERROR CONTINUE
  SELECT den_balanca, bat
    INTO l_den_balanca, m_bat
    FROM esp_par_balanca
   WHERE cod_empresa = p_cod_empresa
     AND cod_balanca = l_tp_balanca
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    RETURN FALSE, l_den_balanca
 END IF

 RETURN TRUE, l_den_balanca

END FUNCTION

#-------------------------------#
 FUNCTION esp1556_exibe_array1(l_ind)
#-------------------------------#
 DEFINE l_ind  SMALLINT

 IF l_ind <= 05 THEN
     FOR l_ind = 1 TO 05
        DISPLAY ma_tela[l_ind].* TO sr_esp15561[l_ind].*
     END FOR
 ELSE
    DISPLAY ARRAY ma_tela TO sr_esp15561.*
 END IF

END FUNCTION

#--------------------------------#
 FUNCTION esp1556_atualiza_valores()
#--------------------------------#
 DEFINE l_peso_bruto     LIKE esp_balanca.peso_bruto,
        l_peso_liquido   LIKE esp_balanca.peso_liquido,
        l_tara           LIKE esp_balanca.tara

 INITIALIZE l_peso_bruto, l_peso_liquido, l_tara TO NULL

 SELECT peso_bruto, peso_liquido, tara
  INTO l_peso_bruto, l_peso_liquido, l_tara
  FROM esp_balanca
 WHERE cod_empresa = p_cod_empresa
   AND num_pesagem = mr_esp_balanca.num_pesagem

  IF l_peso_bruto IS NOT NULL
  OR l_peso_bruto <> " " THEN
     DISPLAY l_peso_bruto   TO peso_bruto
     DISPLAY l_peso_liquido TO peso_liquido
     DISPLAY l_tara         TO tara
  END IF

END FUNCTION

#--------------------------------#
 FUNCTION esp1556_recarrega(l_ind)
#--------------------------------#
 DEFINE l_ind                 SMALLINT

 IF l_ind > 5 THEN
    LET m_num_pesagem = ma_tela[l_ind].num_pesagem1
    CALL SET_COUNT(l_ind)
    DISPLAY ARRAY ma_tela TO sr_esp15561.*
 ELSE
    FOR l_ind = 1 TO 999
       IF ma_tela[l_ind].num_om1 IS NULL
       OR ma_tela[l_ind].num_om1 = ' ' THEN
          EXIT FOR
       END IF
       DISPLAY ma_tela[l_ind].* TO sr_esp15561[l_ind].*
       LET m_num_pesagem = ma_tela[l_ind].num_pesagem1
    END FOR
 END IF

END FUNCTION

#------------------------------#
 FUNCTION esp1556_exibe_espelho(l_ind)
#------------------------------#
 DEFINE l_ind             SMALLINT

 LET mr_esp_balanca.* = mr_esp_balancar.*
 LET ma_tela.* = ma_telar.*

 SELECT peso_bruto,tara, peso_liquido
   INTO mr_esp_balanca.peso_bruto, mr_esp_balanca.tara, mr_esp_balanca.peso_liquido
   FROM esp_balanca
  WHERE cod_empresa = p_cod_empresa
    AND num_pesagem = mr_esp_balanca.num_pesagem

 DISPLAY BY NAME mr_esp_balanca.peso_bruto
 DISPLAY BY NAME mr_esp_balanca.tara
 DISPLAY BY NAME mr_esp_balanca.peso_liquido

 IF l_ind <= 05 THEN
    FOR l_ind = 1 TO 05
       DISPLAY ma_tela[l_ind].* TO sr_esp15561[l_ind].*
    END FOR
 ELSE
    DISPLAY ARRAY ma_tela TO sr_esp15561.*
 END IF

END FUNCTION

#------------------------------#
 FUNCTION esp1556_modificar_array()
#------------------------------#
  DEFINE l_erro    SMALLINT
  DEFINE l_ind     SMALLINT

  LET l_erro = FALSE

  IF NOT esp1556_cursor_for_update() THEN
     RETURN FALSE
  END IF

  LET mr_esp_balanca.* = mr_esp_balancar.*
  LET ma_telar.* = ma_tela.*

  IF esp1556_entrada_pesagem_man_aut('MODIFICACAO') THEN
     IF esp1556_entrada_dados_array("MODIFICACAO") THEN
        CALL log085_transacao("BEGIN")

        UPDATE esp_balanca
           SET ton_tara                = mr_esp_balanca.ton_tara,
               ton_peso_bruto          = mr_esp_balanca.ton_peso_bruto,
               ton_peso_liquido        = mr_esp_balanca.ton_peso_liquido,
               peso_liquido            = mr_esp_balanca.peso_liquido,
               peso_bruto              = mr_esp_balanca.peso_bruto,
               tara                    = mr_esp_balanca.tara,
               peso_bruto_manual       = mr_esp_balanca.peso_bruto_manual,
               tara_manual             = mr_esp_balanca.tara_manual,
               peso_liquido_manual     = mr_esp_balanca.peso_liquido_manual,
               ton_peso_bruto_manual   = mr_esp_balanca.ton_peso_bruto_manual,
               ton_tara_manual         = mr_esp_balanca.ton_tara_manual,
               ton_peso_liquido_manual = mr_esp_balanca.ton_peso_liquido_manual,
               pesagem_2               = mr_esp_balanca.pesagem_2
         WHERE cod_empresa = p_cod_empresa
           AND num_pesagem = mr_esp_balanca.num_pesagem

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("ALTERACAO","esp_balanca")
           LET l_erro = TRUE
           RETURN FALSE
        END IF

        DELETE FROM esp_balanca_om
         WHERE cod_empresa   = p_cod_empresa
           AND num_pesagem   = mr_esp_balanca.num_pesagem

        FOR l_ind = 1 to 999
           IF ma_tela[l_ind].num_om1 IS NOT NULL THEN
              INSERT INTO esp_balanca_om VALUES (p_cod_empresa,
                                                 ma_tela[l_ind].num_pesagem1,
                                                 1,
                                                 ma_tela[l_ind].num_om1,
                                                 ma_tela[l_ind].num_pedido,
                                                 ma_tela[l_ind].num_sequencia,
                                                 ma_tela[l_ind].cod_item,
                                                 ma_tela[l_ind].data_entrega,
                                                 ma_tela[l_ind].cod_unid_med,
                                                 ma_tela[l_ind].qtd_reservada,
                                                 ma_tela[l_ind].peso_liquido2_ton,
                                                 NULL)

              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("MODIFICACAO","esp_balanca_om")
                 CALL log085_transacao("ROLLBACK")
                 RETURN FALSE
              END IF
           END IF
        END FOR

        DISPLAY BY NAME mr_esp_balanca.dat_pesagem

        CALL log085_transacao("COMMIT")
        CALL log0030_mensagem( "Modificação efetuada com sucesso. ","info")
     ELSE # entrada array
       CALL log085_transacao("ROLLBACK")
       CALL log0030_mensagem("Modificação cancelada.","info")
       RETURN FALSE
     END IF
  ELSE # verifica pesagem
    CALL log0030_mensagem("Modificação cancelada.","info")
    RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION esp1556_deleta_array()
#------------------------------#
 DEFINE l_ind       SMALLINT

 IF esp1556_cursor_for_update() = TRUE THEN

    LET mr_esp_balanca.* = mr_esp_balancar.*
    LET ma_telar.* = ma_tela.*

    IF log0040_confirm(10,30,"Confirma a exclusão?") THEN

       DELETE FROM esp_balanca_om
        WHERE cod_empresa   = p_cod_empresa
          AND num_pesagem   = mr_esp_balanca.num_pesagem

       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("INSERT","esp_balanca_om")
          CALL log085_transacao("ROLLBACK")
          RETURN
       END IF

       CALL log085_transacao("COMMIT")
       INITIALIZE ma_tela TO NULL
       FOR l_ind = 1 TO 05
          DISPLAY ma_tela[l_ind].* TO sr_esp15561[l_ind].*
       END FOR

       MESSAGE " Exclusão efetuada com sucesso. " ATTRIBUTE(REVERSE)

       CALL esp1556_atualiza_valores()
    ELSE
       CALL log085_transacao("ROLLBACK")
       MESSAGE " Exclusao Cancelada... " ATTRIBUTE(REVERSE)
    END IF
 END IF

END FUNCTION

#----------------------------------#
FUNCTION esp1556_cursor_for_update()
#----------------------------------#

   DECLARE cq_update CURSOR FOR SELECT *
                                  FROM esp_balanca_om
                                  FOR UPDATE

   CALL log085_transacao("BEGIN")
   OPEN cq_update
   FETCH cq_update
   CASE
      WHEN sqlca.sqlcode = 0
         RETURN TRUE
      WHEN sqlca.sqlcode = -250
         CALL log0030_mensagem("Registro Sendo Atualizado Por Outro Usuario. Aguarde e Tente Novamente.", "exclamation")
      WHEN sqlca.sqlcode = 100
         CALL log0030_mensagem("Registro Nao Encontrado, Efetue a Consulta Novamente", "exclamation")
      OTHERWISE
         CALL log003_err_sql("FETCH","esp_balanca_om")
   END CASE

   CLOSE cq_update
   CALL log085_transacao("ROLLBACK")
   RETURN FALSE

END FUNCTION

#-------------------------------#
 FUNCTION esp1556_version_info()
#-------------------------------#
  RETURN "$Archive: esp1556.4gl $|$Revision: 18 $|$Date: 26/09/13 14:53 $|$Modtime: 18/06/13 14:53 $"

 END FUNCTION
