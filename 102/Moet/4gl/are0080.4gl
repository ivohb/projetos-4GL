#--------------------------------------------------------------------#
# SISTEMA.: ARE - AUTOMAÇÃO COMERCIAL DE REDES                       #
# PROGRAMA: ARE0080                                                  #
# OBJETIVO: GERA ORCAMENTO DE VENDA.                                 #
# AUTOR...: ALUIZIO FERNANDO HABIZENREUTER                           #
# DATA....: 10/02/2004                                               #
#--------------------------------------------------------------------#
 DATABASE logix

 GLOBALS
     DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
            p_user                 LIKE usuario.nom_usuario,
            p_status               SMALLINT,
            p_msg						       CHAR(300) 

     DEFINE p_ies_impressao        CHAR(001),
            g_tem_config_impress   SMALLINT,
            g_ies_ambiente         CHAR(001),
            p_nom_arquivo          CHAR(100),
            p_nom_arquivo_back     CHAR(100),
            p_arr_cur               SMALLINT,
            p_scr_lin               SMALLINT,
            p_arr_count             SMALLINT,
            p_tela                   SMALLINT

     DEFINE g_ies_grafico          SMALLINT

     DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
 END GLOBALS

#MODULARES
     DEFINE m_den_empresa          LIKE empresa.den_empresa

     DEFINE m_consulta_ativa       SMALLINT

     DEFINE sql_stmt               CHAR(800),
            where_clause           CHAR(400),
            p_item2                  RECORD LIKE item.*

     DEFINE m_comando              CHAR(080)

     DEFINE m_caminho              CHAR(150),
            m_last_row             SMALLINT

     DEFINE mr_sol_orcamento     RECORD LIKE sol_orcamento.*,
            mr_sol_orc_itens     RECORD LIKE sol_orc_itens.*
     DEFINE l_sol_cli_end_ent    RECORD LIKE sol_cli_end_ent.*,
            l_sol_observ_orcam   RECORD LIKE sol_observ_orcam.*,
            m_val_avista         DECIMAL(17,2),
            m_val_aprazo         DECIMAL(17,2)

     DEFINE mr_tela               RECORD
            num_orcamento        LIKE sol_orcamento.num_orcamento,
            ies_situacao         LIKE sol_orcamento.ies_situacao,
            dat_emis_orc         LIKE sol_orcamento.dat_emis_orc,
            cod_repres           LIKE sol_orcamento.cod_repres,
            cod_cliente          LIKE sol_orcamento.cod_cliente,
            nom_cliente          LIKE clientes.nom_cliente,
            cod_nat_oper         LIKE sol_orcamento.cod_nat_oper,
            num_pedido_cli       LIKE sol_orcamento.num_pedido_cli,
            dat_validade_orc     LIKE sol_orcamento.dat_validade_orc,
            cod_moeda            LIKE sol_orcamento.cod_moeda,
            lista_preco          CHAR(01)
                                 END RECORD

     DEFINE mr_tela1              RECORD
            cod_cnd_pgto         LIKE sol_orcamento.cod_cnd_pgto,
            cod_forma_pgto       LIKE sol_forma_pgto_imp.cod_forma_pgto,
            cod_forma_entrada    LIKE sol_orcamento.cod_forma_entrada,
            pct_desc_orc         LIKE sol_orcamento.pct_desc_orc
                                 END RECORD

     DEFINE m_orcamento          ARRAY[999] OF RECORD
            cod_item             LIKE sol_orc_itens.cod_item,
            den_item             LIKE item.den_item,
            qtd_pecas_solic      LIKE sol_orc_itens.qtd_pecas_solic,
            cod_unid_med         LIKE item.cod_unid_med,
            cod_local_ret        LIKE sol_orc_itens.cod_local_retirada,
            den_local_ret        CHAR(22),
            cod_empresa_estoq    LIKE sol_orc_itens.cod_empresa_estoq,
            pre_unit_avista      LIKE sol_orc_itens.pre_unit_avista,
            pre_unit_aprazo      LIKE sol_orc_itens.pre_unit_aprazo,
            prz_entrega          LIKE sol_orc_itens.prz_entrega
                                 END RECORD
 DEFINE p_cab_grade
        RECORD
           den_grade_1            CHAR(10),
           den_grade_2            CHAR(10),
           den_grade_3            CHAR(10),
           den_grade_4            CHAR(10),
           den_grade_5            CHAR(10)
        END RECORD

 DEFINE t_array_grade             ARRAY[500]
        OF RECORD
           cod_grade_1               LIKE ped_dig_itens_grad.cod_grade_1,
           cod_grade_2               LIKE ped_dig_itens_grad.cod_grade_2,
           cod_grade_3               LIKE ped_dig_itens_grad.cod_grade_3,
           cod_grade_4               LIKE ped_dig_itens_grad.cod_grade_4,
           cod_grade_5               LIKE ped_dig_itens_grad.cod_grade_5,
           qtd_pecas                 DECIMAL(13,3)
        END RECORD

 DEFINE t_pedido_dig_grad         ARRAY[500]
        OF RECORD
           num_pedido             LIKE pedido_dig_item.num_pedido,
           num_sequencia          LIKE pedido_dig_item.num_sequencia,
           cod_item               LIKE pedido_dig_item.cod_item,
           cod_grade_1            LIKE ped_dig_itens_grad.cod_grade_1,
           cod_grade_2            LIKE ped_dig_itens_grad.cod_grade_2,
           cod_grade_3            LIKE ped_dig_itens_grad.cod_grade_3,
           cod_grade_4            LIKE ped_dig_itens_grad.cod_grade_4,
           cod_grade_5            LIKE ped_dig_itens_grad.cod_grade_5,
           qtd_pecas_solic        DECIMAL(13,3)
        END RECORD

   DEFINE ma_ctr_grade        ARRAY[5]
          OF RECORD
             descr_cabec_zoom LIKE ctr_grade.descr_cabec_zoom,
             nom_tabela_zoom  LIKE ctr_grade.nom_tabela_zoom,
             descr_col_1_zoom LIKE ctr_grade.descr_col_1_zoom,
             descr_col_2_zoom LIKE ctr_grade.descr_col_2_zoom,
             cod_progr_manut  LIKE ctr_grade.cod_progr_manut,
             ies_ctr_empresa  LIKE ctr_grade.ies_ctr_empresa
          END RECORD

DEFINE m_total_avista            LIKE sol_orc_itens.pre_unit_aprazo,
       m_total_aprazo            LIKE sol_orc_itens.pre_unit_aprazo,
       m_cod_item_barra          LIKE sol_orc_itens.cod_item,
       p_sum_qtd_grade          DECIMAL(13,3),
       m_ind                     SMALLINT,
       m_item_grade              SMALLINT,
       pa_curr                  SMALLINT,
       pa_curr_g                SMALLINT,
       pa_count_g               SMALLINT,
       sc_curr_g                SMALLINT,
       mr_item_ctr_grade        RECORD LIKE item_ctr_grade.*

#END MODULARES

 MAIN
     CALL log0180_conecta_usuario()
     LET p_versao = 'ARE0080-10.02.00' 

     WHENEVER ANY ERROR CONTINUE

     CALL log1400_isolation()
     SET LOCK MODE TO WAIT 120

     WHENEVER ANY ERROR STOP

     DEFER INTERRUPT

     LET m_caminho = log140_procura_caminho('are0080.iem')

     OPTIONS
         PREVIOUS KEY control-b,
         NEXT     KEY control-f,
         DELETE   KEY control-e,
#4gl          INSERT   KEY control-i,
         HELP    FILE m_caminho

     CALL log001_acessa_usuario('ARE','LOGARE')
          RETURNING p_status, p_cod_empresa, p_user

     IF  p_status = 0 THEN
         CALL are0080_controle()
     END IF
 END MAIN

#---------------------------#
 FUNCTION are0080_controle()
#---------------------------#
     CALL log006_exibe_teclas('01', p_versao)

     CALL are0080_inicia_variaveis()

     LET m_caminho = log1300_procura_caminho('are0080','')

     OPEN WINDOW w_are0080 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     MENU 'OPÇÃO'
         COMMAND 'Orçamento'   'Inclui um novo orcamento de venda.'
            # HELP 001
             MESSAGE ''
             IF  log005_seguranca(p_user, 'ARE', 'ARE0080', 'IN') THEN
                 LET m_ind = 0
                 CALL are0080_inclusao_sol_orcamento()
             END IF

         COMMAND 'Listar' 'Lista orçamento de venda.'
            # HELP 007
             MESSAGE ''
             IF  log005_seguranca(p_user, 'ARE', 'ARE0080', 'CO') THEN
                 LET g_tem_config_impress = TRUE
                 IF  log0280_saida_relat(21,38) IS NOT NULL THEN
                     CALL are0080_lista_sol_orcamento()
                 END IF
             END IF

         COMMAND "Sobre" "Exibe a versão do programa"
             CALL are0080_sobre() 		

         COMMAND KEY ("!")
             PROMPT "Digite o comando : " FOR m_comando
             RUN m_comando
             PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

         COMMAND 'Fim'       'Retorna ao menu anterior.'
            # HELP 008
             EXIT MENU
     END MENU

     CLOSE WINDOW w_are0080
 END FUNCTION

#-----------------------#
FUNCTION are0080_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-----------------------------------#
 FUNCTION are0080_inicia_variaveis()
#-----------------------------------#
     LET m_consulta_ativa           = FALSE
     INITIALIZE mr_sol_orcamento.* TO NULL
     INITIALIZE mr_sol_orc_itens.* TO NULL
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0080_inclusao_sol_orcamento()
#-------------------------------------------------------#
 DEFINE l_ind                 SMALLINT,
        l_num_orcamento       LIKE sol_orcamento.num_orcamento,
        l_sol_parametros      RECORD LIKE sol_parametros.*

     SELECT * INTO l_sol_parametros.*
       FROM sol_parametros
     WHERE cod_empresa = p_cod_empresa

     INITIALIZE mr_sol_orcamento.*,l_sol_cli_end_ent.* TO NULL
     CLEAR FORM
     LET m_total_avista  = 0
     LET m_total_aprazo  = 0
     IF  are0080_entrada_dados() THEN
         CALL log085_transacao("BEGIN")
         LET mr_sol_orcamento.num_orcamento      =  mr_tela.num_orcamento
         LET mr_sol_orcamento.cod_cliente        =  mr_tela.cod_cliente
         LET mr_sol_orcamento.dat_emis_orc       =  mr_tela.dat_emis_orc
         LET mr_sol_orcamento.cod_nat_oper       =  mr_tela.cod_nat_oper
         LET mr_sol_orcamento.cod_cnd_pgto       =  mr_tela1.cod_cnd_pgto
         LET mr_sol_orcamento.num_pedido_cli     =  mr_tela.num_pedido_cli
         LET mr_sol_orcamento.ies_situacao       =  mr_tela.ies_situacao
         LET mr_sol_orcamento.cod_repres         =  mr_tela.cod_repres
         LET mr_sol_orcamento.dat_cancel_orc     =  NULL
         LET mr_sol_orcamento.cod_motivo_cancel  =  NULL
         LET mr_sol_orcamento.tip_preco_aprovado =  NULL
         LET mr_sol_orcamento.pct_desc_orc       =  mr_tela1.pct_desc_orc
         IF mr_tela.lista_preco = "S" THEN
            LET mr_sol_orcamento.list_preco_avista  =  l_sol_parametros.list_preco_avista
            LET mr_sol_orcamento.list_preco_aprazo  =  l_sol_parametros.list_preco_aprazo
         ELSE
            LET mr_sol_orcamento.list_preco_avista  =  NULL
            LET mr_sol_orcamento.list_preco_aprazo  =  NULL
         END IF
         LET mr_sol_orcamento.cod_moeda          =  mr_tela.cod_moeda
         LET mr_sol_orcamento.nom_usuar_comerc   =  NULL
         LET mr_sol_orcamento.dat_aprov_comerc   =  NULL
         LET mr_sol_orcamento.nom_usuar_financ   =  NULL
         LET mr_sol_orcamento.dat_aprov_financ   =  NULL
         LET mr_sol_orcamento.dat_validade_orc   =  mr_tela.dat_validade_orc
         LET mr_sol_orcamento.cod_forma_pgto     =  mr_tela1.cod_forma_pgto
         LET mr_sol_orcamento.cod_forma_entrada  =  mr_tela1.cod_forma_entrada
         LET mr_sol_orcamento.ies_tip_desc       =  "G"
         WHENEVER ERROR CONTINUE

         INSERT INTO sol_orcamento VALUES (mr_sol_orcamento.*)
         WHENEVER ERROR STOP
         IF  sqlca.sqlcode = 0 THEN
             FOR l_ind = 1 TO 999
                 IF m_orcamento[l_ind].cod_item IS NOT NULL THEN
                    LET mr_sol_orc_itens.cod_item           =  m_orcamento[l_ind].cod_item
                    SELECT cod_local_estoq, fat_conver
                      INTO mr_sol_orc_itens.cod_local, mr_sol_orc_itens.fat_conver
                      FROM item
                     WHERE cod_empresa = p_cod_empresa
                       AND cod_item = mr_sol_orc_itens.cod_item

                    LET mr_sol_orc_itens.cod_empresa        =  p_cod_empresa
                    LET mr_sol_orc_itens.num_orcamento      =  mr_sol_orcamento.num_orcamento
                    LET mr_sol_orc_itens.num_sequencia      =  l_ind
                    LET mr_sol_orc_itens.qtd_pecas_solic    =  m_orcamento[l_ind].qtd_pecas_solic
                    LET mr_sol_orc_itens.qtd_pecas_digit    =  m_orcamento[l_ind].qtd_pecas_solic
                    LET mr_sol_orc_itens.qtd_pecas_cancel   =  0
                    LET mr_sol_orc_itens.qtd_atendida       =  0
                    LET mr_sol_orc_itens.pre_unit_avista    =  m_orcamento[l_ind].pre_unit_avista
                    LET mr_sol_orc_itens.pre_unit_aprazo    =  m_orcamento[l_ind].pre_unit_aprazo
                    LET mr_sol_orc_itens.pct_desc_item      =  mr_sol_orcamento.pct_desc_orc
                    LET mr_sol_orc_itens.cod_empresa_estoq  =  m_orcamento[l_ind].cod_empresa_estoq
                    LET mr_sol_orc_itens.prz_entrega        =  m_orcamento[l_ind].prz_entrega
                    IF m_orcamento[l_ind].cod_local_ret = 1 THEN
                       IF mr_tela1.cod_forma_pgto = "DUP" THEN
                          LET mr_sol_orc_itens.cod_local_retirada = "9"
                       ELSE
                          LET mr_sol_orc_itens.cod_local_retirada = m_orcamento[l_ind].cod_local_ret
                       END IF
                    ELSE
                       LET mr_sol_orc_itens.cod_local_retirada = m_orcamento[l_ind].cod_local_ret
                    END IF

                    INSERT INTO sol_orc_itens VALUES (mr_sol_orc_itens.*)
                 END IF
             END FOR
             IF l_sol_cli_end_ent.num_sequencia IS NOT NULL THEN
                LET l_sol_cli_end_ent.cod_cliente    =  mr_tela.cod_cliente
                LET l_sol_cli_end_ent.num_orcamento  =  mr_tela.num_orcamento
                LET l_sol_cli_end_ent.cod_empresa    =  p_cod_empresa
                INSERT INTO sol_cli_end_ent VALUES (l_sol_cli_end_ent.*)
                IF sqlca.sqlcode <> 0 THEN
                   CALL log003_err_sql('INCLUSAO','SOL_CLI_END_ENT')
                   RETURN
                END IF
             END IF
             IF l_sol_observ_orcam.tex_observ_1 IS NOT NULL THEN
                LET l_sol_observ_orcam.num_orcamento =  mr_tela.num_orcamento
                LET l_sol_observ_orcam.cod_empresa   =  p_cod_empresa
                INSERT INTO sol_observ_orcam VALUES (l_sol_observ_orcam.*)
             END IF

             IF are0080_inclui_grade() = TRUE THEN
                CALL log085_transacao("COMMIT")
                MESSAGE ' Inclusão efetuada com sucesso. ' ATTRIBUTE(REVERSE)
             ELSE
                CALL log085_transacao("ROLLBACK")
                MESSAGE ' Erro na inclusão do orçamento.' ATTRIBUTE(REVERSE)
             END IF
         ELSE
             CALL log003_err_sql('INCLUSAO','SOL_ORCAMENTO')
         END IF
     ELSE
         ERROR ' Inclusão Cancelada. ' ATTRIBUTE(REVERSE)
     END IF
 END FUNCTION

#----------------------------------------#
 FUNCTION are0080_entrada_dados()
#----------------------------------------#
DEFINE lr_sol_parametros       RECORD LIKE sol_parametros.*

 SELECT * INTO lr_sol_parametros.*
   FROM sol_parametros
  WHERE cod_empresa = p_cod_empresa

 INITIALIZE m_orcamento TO NULL
 INITIALIZE mr_tela.*,mr_tela1.*   TO NULL
 LET mr_sol_orcamento.cod_empresa = p_cod_empresa

 CALL log006_exibe_teclas('01 02 03 07', p_versao)

 CURRENT WINDOW IS w_are0080
 LET int_flag                 = 0
 LET mr_tela.dat_emis_orc     = TODAY
 LET mr_tela.ies_situacao     = "B"
 LET mr_tela1.pct_desc_orc     = 0
 LET mr_tela.lista_preco      = "S"
 LET mr_tela.cod_nat_oper     = lr_sol_parametros.cod_nat_oper_orc
 LET p_tela         = 1

   WHILE TRUE
      CASE
         WHEN p_tela = 1
            IF are0080_entrada_dados_1() = TRUE  THEN
               LET p_tela = 2
            ELSE
               LET p_status = 1
               EXIT WHILE
            END IF

         WHEN p_tela = 2
            IF are0080_entrada_dados_2() = TRUE  THEN
               LET p_tela = 3
            ELSE
              LET p_tela = 1
            END IF

         WHEN p_tela = 3
            IF are0080_entrada_dados_3() = TRUE  THEN
               LET p_tela = 4
            ELSE
              LET p_tela = 2
            END IF

         WHEN p_tela = 4
            IF are0080_entrada_dados_4() = TRUE  THEN
               LET p_status = 0
               EXIT WHILE
            ELSE
              LET p_tela = 3
            END IF

      END CASE
   END WHILE

   IF p_status = 0 THEN
      CURRENT WINDOW IS w_are0080
      DISPLAY '--------' AT 3,61
      SELECT * INTO lr_sol_parametros.*
        FROM sol_parametros
       WHERE cod_empresa = p_cod_empresa

      IF lr_sol_parametros.num_ult_orcamento IS NULL THEN
         LET lr_sol_parametros.num_ult_orcamento = 0
      END IF

      LET lr_sol_parametros.num_ult_orcamento = lr_sol_parametros.num_ult_orcamento + 1

      UPDATE sol_parametros SET sol_parametros.num_ult_orcamento = lr_sol_parametros.num_ult_orcamento
       WHERE cod_empresa = p_cod_empresa
      LET mr_tela.num_orcamento = lr_sol_parametros.num_ult_orcamento
      DISPLAY BY NAME mr_tela.num_orcamento

      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

 END FUNCTION
#----------------------------------------#
 FUNCTION are0080_entrada_dados_1()
#----------------------------------------#
DEFINE l_den_item              LIKE item.den_item,
       l_cod_unid_med          LIKE item.cod_unid_med,
       lr_sol_parametros       RECORD LIKE sol_parametros.*

DEFINE l_ind                 SMALLINT

SELECT * INTO lr_sol_parametros.*
  FROM sol_parametros
  WHERE cod_empresa = p_cod_empresa

  DISPLAY p_cod_empresa TO empresa
  #DISPLAY lr_sol_parametros.num_ult_orcamento  TO num_orcamento

     INPUT BY NAME mr_tela.ies_situacao, mr_tela.dat_emis_orc, mr_tela.cod_repres,
                   mr_tela.cod_cliente, mr_tela.nom_cliente, mr_tela.cod_nat_oper,
                   mr_tela.num_pedido_cli, mr_tela.dat_validade_orc, mr_tela.cod_moeda,
                   mr_tela.lista_preco
                   WITHOUT DEFAULTS

          AFTER FIELD dat_emis_orc
             IF  mr_tela.dat_emis_orc IS NULL THEN
                 CALL log0030_mensagem('Data de emissão do orçamento não pode ser nula.','excl')
                 NEXT FIELD dat_emis_orc
             END IF
             IF  mr_tela.dat_emis_orc > TODAY THEN
                 CALL log0030_mensagem('Data de emissão não pode ser maior que hoje.','excl')
                 NEXT FIELD dat_emis_orc
             END IF
             LET mr_tela.dat_validade_orc = mr_tela.dat_emis_orc
               + lr_sol_parametros.qtd_dias_valid_orc
             DISPLAY BY NAME mr_tela.dat_validade_orc

         BEFORE FIELD cod_repres
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
             ELSE DISPLAY '( Zoom )' AT 3,61
             END IF

          AFTER FIELD cod_repres
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
             ELSE DISPLAY '--------' AT 3,61
             END IF
             IF  mr_tela.cod_repres IS NOT NULL THEN
                 IF  are0080_verifica_cod_repres () = FALSE THEN
                     NEXT FIELD cod_repres
                 END IF
             ELSE
                 CALL log0030_mensagem('Código do vendedor inválido.','excl')
                 NEXT FIELD cod_repres
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD cod_cliente
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
             ELSE DISPLAY '( Zoom )' AT 3,61
             END IF

          AFTER FIELD cod_cliente
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
             ELSE DISPLAY '--------' AT 3,61
             END IF
             IF  mr_tela.cod_cliente IS NOT NULL THEN
                 IF  are0080_verifica_cod_cliente() = FALSE THEN
                     CALL log0030_mensagem('Código cliente não cadastrado.','excl')
                     NEXT FIELD cod_cliente
                 END IF
             ELSE
                 CALL log0030_mensagem('Código cliente não pode ser nulo.','excl')
                 NEXT FIELD cod_cliente
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD cod_nat_oper
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
             ELSE DISPLAY '( Zoom )' AT 3,61
             END IF

          AFTER FIELD cod_nat_oper
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
             ELSE DISPLAY '--------' AT 3,61
             END IF
             IF  mr_tela.cod_nat_oper IS NOT NULL THEN
                 IF  are0080_verifica_nat_oper() = FALSE THEN
                     CALL log0030_mensagem('Código natureza de operação não cadastrado.','excl')
                     NEXT FIELD cod_nat_oper
                 END IF
             ELSE
                 CALL log0030_mensagem('Código de natureza de operação inválido.','excl')
                 NEXT FIELD cod_nat_oper
             END IF
             IF mr_tela.cod_nat_oper <> lr_sol_parametros.cod_nat_oper_orc THEN
                LET mr_tela.ies_situacao = "B"
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD cod_moeda
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
             ELSE DISPLAY '( Zoom )' AT 3,61
             END IF

          AFTER FIELD cod_moeda
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
             ELSE DISPLAY '--------' AT 3,61
             END IF
             IF  mr_tela.cod_moeda IS NOT NULL THEN
                 IF  are0080_verifica_cod_moeda() = FALSE THEN
                     CALL log0030_mensagem('Moeda não cadastrada.','excl')
                     NEXT FIELD cod_moeda
                 END IF
             ELSE
                 CALL log0030_mensagem('Moeda não pode ser nula.','excl')
                 NEXT FIELD cod_moeda
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

          AFTER FIELD lista_preco
             IF  mr_tela.lista_preco IS NULL THEN
                 LET mr_tela.lista_preco = "S"
             END IF
             IF  mr_tela.lista_preco <> "S" AND
                 mr_tela.lista_preco <> "N" THEN
                 CALL log0030_mensagem('Valor inválido, deverá ser (S) ou (N).','excl')
                 NEXT FIELD lista_preco
             END IF
             IF  mr_tela.lista_preco <> "S" THEN
                 LET mr_tela.ies_situacao = "B"
             END IF

          #ON KEY (control-w)
           #  CALL are0080_help()

          AFTER INPUT
             IF  INT_FLAG = 0 THEN
                 IF  mr_tela.dat_emis_orc IS NULL THEN
                     CALL log0030_mensagem('Data de emissão do orçamento não pode ser nula.','excl')
                     NEXT FIELD dat_emis_orc
                 END IF
                 IF  mr_tela.dat_emis_orc > TODAY THEN
                     CALL log0030_mensagem('Data de emissão não pode ser maior que hoje.','excl')
                     NEXT FIELD dat_emis_orc
                 END IF

                 IF  mr_tela.cod_repres IS NOT NULL THEN
                     IF  are0080_verifica_cod_repres () = FALSE THEN
                         NEXT FIELD cod_repres
                     END IF
                 ELSE
                     CALL log0030_mensagem('Código do vendedor inválido.','excl')
                     NEXT FIELD cod_repres
                 END IF

                 IF  mr_tela.cod_cliente IS NOT NULL THEN
                     IF  are0080_verifica_cod_cliente() = FALSE THEN
                         CALL log0030_mensagem('Código cliente não cadastrado.','excl')
                         NEXT FIELD cod_cliente
                     END IF
                 ELSE
                     CALL log0030_mensagem('Código cliente não pode ser nulo.','excl')
                     NEXT FIELD cod_cliente
                 END IF

                 IF  mr_tela.cod_nat_oper IS NOT NULL THEN
                     IF  are0080_verifica_nat_oper() = FALSE THEN
                         CALL log0030_mensagem('Código natureza de operação não cadastrado.','excl')
                         NEXT FIELD cod_nat_oper
                     END IF
                 ELSE
                     CALL log0030_mensagem('Código de natureza de operação inválido.','excl')
                     NEXT FIELD cod_nat_oper
                 END IF
                 IF mr_tela.cod_nat_oper <> lr_sol_parametros.cod_nat_oper_orc THEN
                    LET mr_tela.ies_situacao = "B"
                 END IF

                 IF  mr_tela.cod_moeda IS NOT NULL THEN
                     IF  are0080_verifica_cod_moeda() = FALSE THEN
                         CALL log0030_mensagem('Moeda não cadastrada.','excl')
                         NEXT FIELD cod_moeda
                     END IF
                 ELSE
                     CALL log0030_mensagem('Moeda não pode ser nula.','excl')
                     NEXT FIELD cod_moeda
                 END IF

                 IF  mr_tela.lista_preco IS NULL THEN
                     LET mr_tela.lista_preco = "S"
                 END IF
                 IF  mr_tela.lista_preco <> "S" AND
                     mr_tela.lista_preco <> "N" THEN
                     CALL log0030_mensagem('Valor inválido, deverá ser (S) ou (N).','excl')
                     NEXT FIELD lista_preco
                 END IF

             END IF

          ON KEY (control-z, f4)
             CALL are0080_popup()

     END INPUT

     IF int_flag <> 0 THEN
        LET int_flag = 0
        RETURN FALSE
     END IF
     DISPLAY BY NAME mr_tela.ies_situacao
     RETURN TRUE
 END FUNCTION

#----------------------------------------#
 FUNCTION are0080_entrada_dados_2()
#----------------------------------------#
DEFINE l_ind                 SMALLINT
DEFINE l_den_item              LIKE item.den_item,
       l_cod_unid_med          LIKE item.cod_unid_med,
       l_vlr_desc_avista       DECIMAL(17,2),
       l_vlr_desc_aprazo       DECIMAL(17,2)

  LET m_caminho = log1300_procura_caminho('are00801','')
  OPEN WINDOW w_are00801 AT 4,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
   CALL log006_exibe_teclas('01', p_versao)
   CURRENT WINDOW IS w_are00801

   DISPLAY p_cod_empresa TO empresa

   LET m_total_avista = 0
   LET m_total_aprazo = 0

   INPUT ARRAY m_orcamento WITHOUT DEFAULTS FROM s_orcamento.*
       BEFORE ROW
         LET p_arr_cur = arr_curr()
         LET p_scr_lin = scr_line()
         LET p_arr_count = arr_count()
         LET m_total_avista = 0
         LET m_total_aprazo = 0

         FOR l_ind = 1 TO 999
             IF m_orcamento[l_ind].qtd_pecas_solic > 0 THEN
                LET m_total_avista   = m_total_avista +
               (m_orcamento[l_ind].qtd_pecas_solic*m_orcamento[l_ind].pre_unit_avista)
                LET m_total_aprazo   = m_total_aprazo +
               (m_orcamento[l_ind].qtd_pecas_solic*m_orcamento[l_ind].pre_unit_aprazo)
            END IF
        END FOR

        DISPLAY m_total_avista     TO total_avista
        DISPLAY m_total_aprazo     TO total_aprazo

            BEFORE FIELD cod_item
     	        IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
             ELSE DISPLAY '( Zoom )' AT 3,61
             END IF

             AFTER FIELD cod_item
                IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
             ELSE DISPLAY '--------' AT 3,61
             END IF
                IF  m_orcamento[p_arr_cur].cod_item IS NOT NULL THEN
                    CALL are0080_verifica_cod_item(m_orcamento[p_arr_cur].cod_item)
                          RETURNING l_den_item,l_cod_unid_med
                    IF l_den_item IS NULL THEN
                        CALL log0030_mensagem('Produto não cadastrado.','excl')
                        NEXT FIELD cod_item
                    END IF
                    LET m_orcamento[p_arr_cur].den_item = l_den_item
                    LET m_orcamento[p_arr_cur].cod_unid_med = l_cod_unid_med
                    DISPLAY m_orcamento[p_arr_cur].den_item TO s_orcamento[p_scr_lin].den_item
                    DISPLAY m_orcamento[p_arr_cur].cod_unid_med  TO s_orcamento[p_scr_lin].cod_unid_med
                ELSE
                   IF FGL_LASTKEY() = 2016 THEN
                       EXIT INPUT
                    END IF
                   IF FGL_LASTKEY() <> FGL_KEYVAL("UP") THEN
                      CALL log0030_mensagem('Item não pode ser nulo.','excl')
                      NEXT FIELD cod_item
                   END IF
                END IF

   --#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

             BEFORE FIELD qtd_pecas_solic
     	       LET m_item_grade = FALSE
               IF are0080_verifica_grade() THEN
               ELSE
                  NEXT FIELD cod_item
               END IF

             AFTER FIELD qtd_pecas_solic
                IF  m_orcamento[p_arr_cur].qtd_pecas_solic IS NULL OR
                    m_orcamento[p_arr_cur].qtd_pecas_solic <= 0 THEN
                    CALL log0030_mensagem('Quantidade de peças inválida.','excl')
                    NEXT FIELD qtd_pecas_solic
                END IF
                IF m_item_grade = TRUE THEN
                   IF m_orcamento[p_arr_cur].qtd_pecas_solic <> p_sum_qtd_grade THEN
                      CALL log0030_mensagem('Quantidade de peças da grade difere do orçamento.','excl')
                      NEXT FIELD qtd_pecas_solic
                   END IF
                END IF
     	
             AFTER FIELD cod_local_ret
                IF m_orcamento[p_arr_cur].cod_local_ret IS NULL OR
                   m_orcamento[p_arr_cur].cod_local_ret <> 1 AND
                   m_orcamento[p_arr_cur].cod_local_ret <> 2 AND
                   m_orcamento[p_arr_cur].cod_local_ret <> 3 AND
                   m_orcamento[p_arr_cur].cod_local_ret <> 9 THEN
                   CALL log0030_mensagem('Código de local inválido.','excl')
                   NEXT FIELD cod_local_ret
                END IF

                IF m_orcamento[p_arr_cur].cod_local_ret = 1 THEN
                   IF  m_orcamento[p_arr_cur].cod_empresa_estoq <> p_cod_empresa THEN
                       CALL log0030_mensagem('Este item não pode ser vendido no CAIXA.','excl')
                       NEXT FIELD cod_local_ret
                   END IF
                   DISPLAY "CAIXA"    TO s_orcamento[p_scr_lin].den_local_ret
                ELSE
                   IF m_orcamento[p_arr_cur].cod_local_ret = 2 THEN
                      DISPLAY "NF A RETIRAR."    TO s_orcamento[p_scr_lin].den_local_ret
                   ELSE
                      IF m_orcamento[p_arr_cur].cod_local_ret = 3 THEN
                         DISPLAY "NF A ENTREGAR."    TO s_orcamento[p_scr_lin].den_local_ret
                      ELSE
                         DISPLAY "CAIXA DUP/NF."    TO s_orcamento[p_scr_lin].den_local_ret
                      END IF
                   END IF
                END IF

             BEFORE FIELD cod_empresa_estoq
                IF FGL_LASTKEY() = FGL_KEYVAL("UP") THEN
                    NEXT FIELD cod_local_ret
                END IF
                IF  m_orcamento[p_arr_cur].cod_local_ret = 1 THEN
                    IF  m_orcamento[p_arr_cur].cod_empresa_estoq IS NULL THEN
                        LET m_orcamento[p_arr_cur].cod_empresa_estoq = p_cod_empresa
                    END IF
                    DISPLAY m_orcamento[p_arr_cur].cod_empresa_estoq TO s_orcamento[p_scr_lin].cod_empresa_estoq
                    NEXT FIELD pre_unit_avista
                END IF

             AFTER FIELD cod_empresa_estoq
                IF  m_orcamento[p_arr_cur].cod_empresa_estoq IS NOT NULL THEN
                    IF are0080_verifica_empresa() = FALSE THEN
                       CALL log0030_mensagem('Empresa não cadastrada.','excl')
                       NEXT FIELD cod_empresa_estoq
                    END IF
                ELSE
                    CALL log0030_mensagem('Código de empresa não pode ser nulo.','excl')
                    NEXT FIELD cod_empresa_estoq
                END IF

            BEFORE FIELD pre_unit_avista
      	        IF mr_tela.lista_preco = "S" THEN
                   IF are0080_busca_preco_unit() = FALSE THEN
                      NEXT FIELD prz_entrega
                    END IF
                ELSE
                   IF are0080_busca_preco_unit() = FALSE THEN
                    END IF
                END IF

     	        IF mr_tela.lista_preco = "S" THEN
                   NEXT FIELD prz_entrega
                END IF

             AFTER FIELD pre_unit_avista
                IF  m_orcamento[p_arr_cur].pre_unit_avista IS NULL OR
                    m_orcamento[p_arr_cur].pre_unit_avista <= 0 THEN
                    CALL log0030_mensagem('Preço inválido para produto.','excl')
                    NEXT FIELD pre_unit_avista
                END IF

            BEFORE FIELD pre_unit_aprazo
     	        IF mr_tela.lista_preco = "S" THEN
                   NEXT FIELD prz_entrega
                END IF

             AFTER FIELD pre_unit_aprazo
                IF  m_orcamento[p_arr_cur].pre_unit_aprazo IS NULL OR
                    m_orcamento[p_arr_cur].pre_unit_aprazo <= 0 THEN
                    CALL log0030_mensagem('Preço inválido para produto.','excl')
                    NEXT FIELD pre_unit_aprazo
                END IF

             BEFORE FIELD prz_entrega
                IF m_orcamento[p_arr_cur].prz_entrega IS NULL OR
                   m_orcamento[p_arr_cur].prz_entrega = "" THEN
                   LET m_orcamento[p_arr_cur].prz_entrega = TODAY
                   DISPLAY m_orcamento[p_arr_cur].prz_entrega TO s_orcamento[p_scr_lin].prz_entrega
                END IF

             AFTER FIELD prz_entrega
                IF FGL_LASTKEY() = FGL_KEYVAL("UP") THEN
     	           IF mr_tela.lista_preco = "S" THEN
                      NEXT FIELD cod_empresa_estoq
                   ELSE
                      NEXT  FIELD pre_unit_aprazo
                   END IF
                END IF

                IF  m_orcamento[p_arr_cur].prz_entrega IS NULL OR
                    m_orcamento[p_arr_cur].prz_entrega < TODAY THEN
                    CALL log0030_mensagem('Prazo entrega inválido, não pode ser nulo ou menor que hoje.','excl')
                    NEXT FIELD prz_entrega
                END IF
                FOR l_ind = 1 to p_arr_cur
                    IF l_ind <> p_arr_cur THEN
                       IF m_orcamento[p_arr_cur].cod_item = m_orcamento[l_ind].cod_item THEN
                          IF m_orcamento[p_arr_cur].prz_entrega = m_orcamento[l_ind].prz_entrega THEN
                             IF m_orcamento[p_arr_cur].cod_local_ret = m_orcamento[l_ind].cod_local_ret THEN
                                CALL log0030_mensagem('Item já passado pelo orçamento e com mesma data de entrega.','excl')
                                NEXT FIELD prz_entrega
                             END IF
                          END IF
                       END IF
                    END IF
                END FOR


             AFTER DELETE
                  LET m_orcamento[p_arr_count].cod_item          = NULL
                  LET m_orcamento[p_arr_count].den_item          = NULL
                  LET m_orcamento[p_arr_count].qtd_pecas_solic   = NULL
                  LET m_orcamento[p_arr_count].cod_empresa_estoq = NULL
                  LET m_orcamento[p_arr_count].cod_unid_med      = NULL
                  LET m_orcamento[p_arr_count].pre_unit_avista   = NULL
                  LET m_orcamento[p_arr_count].pre_unit_aprazo   = NULL
                  LET m_orcamento[p_arr_count].prz_entrega       = NULL
                  LET m_orcamento[p_arr_count].cod_local_ret     = NULL
                  LET m_orcamento[p_arr_count].den_local_ret     = NULL

             AFTER INPUT
                IF  INT_FLAG = 0 THEN
                    IF  m_orcamento[p_arr_cur].cod_item IS NOT NULL THEN
                        CALL are0080_verifica_cod_item(m_orcamento[p_arr_cur].cod_item)
                             RETURNING l_den_item,l_cod_unid_med
                        IF l_den_item IS NULL THEN
                            CALL log0030_mensagem('Produto não cadastrado.','excl')
                            NEXT FIELD cod_item
                        END IF
                        LET m_orcamento[p_arr_cur].den_item = l_den_item
                        LET m_orcamento[p_arr_cur].cod_unid_med = l_cod_unid_med
                        DISPLAY m_orcamento[p_arr_cur].den_item TO s_orcamento[p_scr_lin].den_item
                        DISPLAY m_orcamento[p_arr_cur].cod_unid_med  TO s_orcamento[p_scr_lin].cod_unid_med
                    ELSE
                        IF FGL_LASTKEY() = 2016 THEN
                           IF  m_orcamento[1].cod_item IS NULL THEN
                               CALL log0030_mensagem('Item não pode ser nulo','excl')
                               NEXT FIELD cod_item
                           ELSE
                               EXIT INPUT
                           END IF
                        END IF
                        IF FGL_LASTKEY() <> FGL_KEYVAL("UP") THEN
                           CALL log0030_mensagem('Item não pode ser nulo','excl')
                           NEXT FIELD cod_item
                        END IF
                    END IF

                    IF  m_orcamento[p_arr_cur].qtd_pecas_solic IS NULL OR
                        m_orcamento[p_arr_cur].qtd_pecas_solic <= 0 THEN
                        CALL log0030_mensagem('Quantidade de peças inválida.','excl')
                        NEXT FIELD qtd_pecas_solic
                    END IF
                    IF m_orcamento[p_arr_cur].qtd_pecas_solic <> p_sum_qtd_grade THEN
                       CALL log0030_mensagem('Quantidade de peças da grade difere do orçamento.','excl')
                       NEXT FIELD qtd_pecas_solic
                    END IF

                    IF  m_orcamento[p_arr_cur].cod_empresa_estoq IS NOT NULL THEN
                        IF are0080_verifica_empresa() = FALSE THEN
                           CALL log0030_mensagem('Empresa não cadastrada.','excl')
                           NEXT FIELD cod_empresa_estoq
                        END IF
                    ELSE
                        CALL log0030_mensagem('Código de empresa não pode ser nulo.','excl')
                        NEXT FIELD cod_empresa_estoq
                    END IF

                    IF  m_orcamento[p_arr_cur].prz_entrega IS NULL OR
                        m_orcamento[p_arr_cur].prz_entrega < TODAY THEN
                        CALL log0030_mensagem('Prazo entrega inválido, não pode ser nulo ou menor que hoje.','excl')
                        NEXT FIELD prz_entrega
                    END IF

                    IF m_orcamento[p_arr_cur].cod_local_ret IS NULL OR
                       m_orcamento[p_arr_cur].cod_local_ret <> 1 AND
                       m_orcamento[p_arr_cur].cod_local_ret <> 2 AND
                       m_orcamento[p_arr_cur].cod_local_ret <> 3 AND
                       m_orcamento[p_arr_cur].cod_local_ret <> 9 THEN
                       CALL log0030_mensagem('Código de local inválido.','excl')
                       NEXT FIELD cod_local_ret
                    END IF

                END IF

             ON KEY (control-z, f4)
                CALL are0080_popup()

        END INPUT

   IF INT_FLAG = 0 THEN
      FOR p_arr_cur = 1 TO 999
         IF m_orcamento[p_arr_cur].cod_item IS NOT NULL THEN
            LET m_val_avista = (m_orcamento[p_arr_cur].qtd_pecas_solic * m_orcamento[p_arr_cur].pre_unit_avista)
            LET m_val_aprazo = (m_orcamento[p_arr_cur].qtd_pecas_solic * m_orcamento[p_arr_cur].pre_unit_aprazo)
         END IF
      END FOR

      INPUT BY NAME mr_tela1.* WITHOUT DEFAULTS
         BEFORE FIELD cod_cnd_pgto
     	      IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
             ELSE DISPLAY '( Zoom )' AT 3,61
             END IF

          AFTER FIELD cod_cnd_pgto
              IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
             ELSE DISPLAY '--------' AT 3,61
             END IF
             IF  mr_tela1.cod_cnd_pgto IS NOT NULL THEN
                 IF  are0080_verifica_cod_cnd_pgto() = FALSE THEN
                     CALL log0030_mensagem('Condição de pagamento não cadastrada.','excl')
                     NEXT FIELD cod_cnd_pgto
                 END IF
             ELSE
                 CALL log0030_mensagem('Condição de pagamento inválida.','excl')
                 NEXT FIELD cod_cnd_pgto
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD cod_forma_pgto
     	      IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
             ELSE DISPLAY '( Zoom )' AT 3,61
             END IF

          AFTER FIELD cod_forma_pgto
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
             ELSE DISPLAY '--------' AT 3,61
             END IF
             IF  mr_tela1.cod_forma_pgto IS NOT NULL THEN
                 IF  are0080_verifica_forma_pgto() = FALSE THEN
                     CALL log0030_mensagem('Forma de pagamento não cadastrada.','excl')
                     NEXT FIELD cod_forma_pgto
                 END IF
             ELSE
                 CALL log0030_mensagem('Forma de pagamento não pode ser nula','excl')
                 NEXT FIELD cod_forma_pgto
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD cod_forma_entrada
          LET mr_tela1.cod_forma_entrada = NULL
          DISPLAY BY NAME mr_tela1.cod_forma_entrada
          DISPLAY ""    TO den_forma_entrada
          IF FGL_LASTKEY() = FGL_KEYVAL("UP") THEN
             NEXT FIELD cod_forma_pgto
          END IF
          IF mr_tela1.cod_forma_pgto = "DUP" THEN
     	      IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
             ELSE DISPLAY '( Zoom )' AT 3,61
             END IF
          ELSE
             NEXT FIELD pct_desc_orc
          END IF

          AFTER FIELD cod_forma_entrada
              IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
             ELSE DISPLAY '--------' AT 3,61
             END IF
             IF  mr_tela1.cod_forma_entrada IS NOT NULL THEN
                 IF  are0080_verifica_forma_entrada() = FALSE THEN
                     CALL log0030_mensagem('Forma de pagamento não cadastrada.','excl')
                     NEXT FIELD cod_forma_entrada
                 END IF
             ELSE
                 CALL log0030_mensagem('Forma de pagamento não pode ser nula.','excl')
                 NEXT FIELD cod_forma_entrada
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

          AFTER FIELD pct_desc_orc
             IF  mr_tela1.pct_desc_orc IS NULL OR
                 mr_tela1.pct_desc_orc < 0 THEN
                 CALL log0030_mensagem('Percentual de desconto inválido.','excl')
                 NEXT FIELD pct_desc_orc
             END IF
             IF  mr_tela1.pct_desc_orc > 0 THEN
                 LET l_vlr_desc_avista = m_val_avista - ((m_val_avista * mr_tela1.pct_desc_orc)/100)
                 LET l_vlr_desc_aprazo = m_val_aprazo - ((m_val_aprazo * mr_tela1.pct_desc_orc)/100)
                 DISPLAY l_vlr_desc_avista    TO vlr_desc_avista
                 DISPLAY l_vlr_desc_aprazo    TO vlr_desc_aprazo
             END IF

     AFTER INPUT
       IF INT_FLAG = 0 THEN
           IF  mr_tela1.cod_cnd_pgto IS NOT NULL THEN
               IF  are0080_verifica_cod_cnd_pgto() = FALSE THEN
                   CALL log0030_mensagem('Condição de pagamento não cadastrada.','excl')
                   NEXT FIELD cod_cnd_pgto
               END IF
           ELSE
               CALL log0030_mensagem('Condição de pagamento inválida.','excl')
               NEXT FIELD cod_cnd_pgto
           END IF

           IF  mr_tela1.cod_forma_pgto IS NOT NULL THEN
               IF  are0080_verifica_forma_pgto() = FALSE THEN
                   CALL log0030_mensagem('Forma de pagamento não cadastrada.','excl')
                   NEXT FIELD cod_forma_pgto
               END IF
           ELSE
               CALL log0030_mensagem('Forma de pagamento não pode ser nula','excl')
               NEXT FIELD cod_forma_pgto
           END IF

             IF  mr_tela1.pct_desc_orc IS NULL OR
                 mr_tela1.pct_desc_orc < 0 THEN
                 CALL log0030_mensagem('Percentual de desconto inválido.','excl')
                 NEXT FIELD pct_desc_orc
             END IF
       END IF

       ON KEY (control-z, f4)
          CALL are0080_popup()


     END INPUT
   END IF

  CLOSE WINDOW w_are00801
  CALL log006_exibe_teclas('01', p_versao)

  IF INT_FLAG <> 0 THEN
     LET INT_FLAG = 0
     CURRENT WINDOW IS w_are0080
     RETURN FALSE
   END IF

  RETURN TRUE
 END FUNCTION


#-------------------------------------------------------#
 FUNCTION are0080_verifica_cod_repres()
#-------------------------------------------------------#
DEFINE l_raz_social        LIKE representante.raz_social

     SELECT raz_social  INTO l_raz_social
       FROM representante
      WHERE cod_repres = mr_tela.cod_repres

     IF  sqlca.sqlcode = 0 THEN
         DISPLAY l_raz_social      TO raz_social
         RETURN TRUE
     ELSE
         RETURN FALSE
     END IF
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0080_verifica_cod_cliente()
#-------------------------------------------------------#
 DEFINE l_nom_cliente         LIKE clientes.nom_cliente

     SELECT nom_cliente INTO l_nom_cliente
       FROM clientes
      WHERE cod_cliente = mr_tela.cod_cliente

     IF  sqlca.sqlcode = 0 THEN
         DISPLAY l_nom_cliente          TO nom_cliente
         RETURN TRUE
     ELSE
         CALL log0030_mensagem('Cliente não cadastrado.','excl')
         RETURN FALSE
     END IF

 END FUNCTION

#--------------------------------------#
 FUNCTION are0080_verifica_forma_pgto()
#--------------------------------------#
DEFINE l_den_pgto      LIKE sol_forma_pgto_imp.den_forma_pgto

     SELECT den_forma_pgto INTO l_den_pgto
       FROM sol_forma_pgto_imp
      WHERE cod_forma_pgto = mr_tela1.cod_forma_pgto

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_mensagem('Forma de pagamento não cadastrada.','excl')
        RETURN FALSE
     END IF
     DISPLAY l_den_pgto   TO den_forma_pgto
     RETURN TRUE

 END FUNCTION

#--------------------------------------#
 FUNCTION are0080_verifica_forma_entrada()
#--------------------------------------#
DEFINE l_den_pgto      LIKE sol_forma_pgto_imp.den_forma_pgto

     SELECT den_forma_pgto INTO l_den_pgto
       FROM sol_forma_pgto_imp
      WHERE cod_forma_pgto = mr_tela1.cod_forma_entrada

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_mensagem('Forma de pagamento não cadastrada.','excl')
        RETURN FALSE
     END IF
     DISPLAY l_den_pgto   TO den_forma_entrada
     RETURN TRUE

 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0080_verifica_nat_oper()
#-------------------------------------------------------#
     SELECT * FROM nat_operacao
      WHERE cod_nat_oper = mr_tela.cod_nat_oper

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_mensagem('Natureza de operação não cadastrada.','excl')
        RETURN FALSE
     END IF
     RETURN TRUE

 END FUNCTION

#----------------------------------------#
 FUNCTION are0080_verifica_cod_cnd_pgto()
#----------------------------------------#
DEFINE l_den_cnd_pgto     LIKE cond_pgto.den_cnd_pgto

     SELECT den_cnd_pgto  INTO l_den_cnd_pgto
       FROM cond_pgto
      WHERE cod_cnd_pgto = mr_tela1.cod_cnd_pgto

     IF  sqlca.sqlcode = 0 THEN
         RETURN TRUE
     ELSE
         RETURN FALSE
     END IF
 END FUNCTION

#------------------------------------#
 FUNCTION are0080_verifica_cod_moeda()
#------------------------------------#

     SELECT den_moeda
       FROM moeda
      WHERE cod_moeda = mr_tela.cod_moeda

     IF  sqlca.sqlcode = 0 THEN
         RETURN TRUE
     ELSE
         RETURN FALSE
     END IF
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0080_verifica_cod_item(l_cod_item)
#-------------------------------------------------------#

 DEFINE l_den_item             LIKE item.den_item,
        l_cod_unid_med         LIKE item.cod_unid_med,
        l_cod_item             LIKE item.cod_item ,
        l_fat_conver           LIKE item.fat_conver,
        l_list_preco_avista    LIKE sol_parametros.list_preco_avista,
        l_list_preco_aprazo    LIKE sol_parametros.list_preco_aprazo,
        l_pre_unit_avista      LIKE desc_preco_item.pre_unit,
        l_pre_unit_aprazo      LIKE desc_preco_item.pre_unit

    SELECT cod_item, den_item,cod_unid_med
      INTO m_cod_item_barra,l_den_item,l_cod_unid_med
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = l_cod_item

    IF sqlca.sqlcode <> 0 THEN
       SELECT sol_item_loja_bar1.cod_item, den_item,
              sol_item_loja_bar2.cod_unid_med
         INTO m_cod_item_barra, l_den_item, l_cod_unid_med
         FROM sol_item_loja_bar1,sol_item_loja_bar2,item
        WHERE sol_item_loja_bar2.cod_empresa    = p_cod_empresa
          AND sol_item_loja_bar2.cod_item_barra = l_cod_item
          AND sol_item_loja_bar1.cod_empresa   = sol_item_loja_bar2.cod_empresa
          AND sol_item_loja_bar1.num_sequencia  = sol_item_loja_bar2.num_sequencia
          AND item.cod_empresa  = sol_item_loja_bar1.cod_empresa
          AND item.cod_item     = sol_item_loja_bar1.cod_item

       IF sqlca.sqlcode <> 0 THEN
           LET l_den_item = NULL
       END IF
    END IF
    LET m_orcamento[p_arr_cur].cod_item = m_cod_item_barra
    RETURN l_den_item,l_cod_unid_med

 END FUNCTION

#------------------------------------#
 FUNCTION are0080_verifica_empresa()
#------------------------------------#

     SELECT den_empresa
       FROM empresa
      WHERE cod_empresa = m_orcamento[p_arr_cur].cod_empresa_estoq

     IF  sqlca.sqlcode = 0 THEN
         RETURN TRUE
     ELSE
         RETURN FALSE
     END IF
 END FUNCTION

#----------------------------------#
 FUNCTION are0080_busca_preco_unit()
#----------------------------------#
DEFINE lr_sol_parametros       RECORD LIKE sol_parametros.*

WHENEVER ERROR CONTINUE

 SELECT * INTO lr_sol_parametros.*
   FROM sol_parametros
  WHERE cod_empresa = p_cod_empresa

 SELECT pre_unit INTO m_orcamento[p_arr_cur].pre_unit_avista FROM desc_preco_item
  WHERE cod_empresa = m_orcamento[p_arr_cur].cod_empresa_estoq
    AND num_list_preco = lr_sol_parametros.list_preco_promoc
    AND cod_item  = m_cod_item_barra

 IF sqlca.sqlcode <> 0 THEN
    SELECT pre_unit INTO m_orcamento[p_arr_cur].pre_unit_avista FROM desc_preco_item
     WHERE cod_empresa = m_orcamento[p_arr_cur].cod_empresa_estoq
       AND num_list_preco = lr_sol_parametros.list_preco_avista
       AND cod_item  = m_cod_item_barra

WHENEVER ERROR STOP

    IF mr_tela.lista_preco = "S" THEN
       IF sqlca.sqlcode <> 0 THEN
          CALL log0030_mensagem('Não existe preço para item nesta lista de preço à vista','excl')
          RETURN FALSE
       END IF
    END IF
 END IF

 SELECT pre_unit INTO m_orcamento[p_arr_cur].pre_unit_aprazo FROM desc_preco_item
  WHERE cod_empresa = m_orcamento[p_arr_cur].cod_empresa_estoq
    AND num_list_preco = lr_sol_parametros.list_preco_aprazo
    AND cod_item  = m_cod_item_barra

IF mr_tela.lista_preco = "S" THEN
   IF sqlca.sqlcode <> 0 THEN
      CALL log0030_mensagem('Não existe preço para item nesta lista de preço a prazo','excl')
      RETURN FALSE
   END IF
END IF

 DISPLAY m_orcamento[p_arr_cur].pre_unit_avista TO s_orcamento[p_scr_lin].pre_unit_avista
 DISPLAY m_orcamento[p_arr_cur].pre_unit_aprazo TO s_orcamento[p_scr_lin].pre_unit_aprazo
 RETURN TRUE
 END FUNCTION

#------------------------#
 FUNCTION are0080_popup()
#------------------------#
     DEFINE l_cod_repres          LIKE representante.cod_repres,
            l_cod_cliente         LIKE clientes.cod_cliente,
            l_cod_forma_pgto      LIKE sol_forma_pgto_imp.cod_forma_pgto,
            l_cod_nat_oper        LIKE nat_operacao.cod_nat_oper,
            l_cod_cnd_pgto        LIKE cond_pgto.cod_cnd_pgto,
            l_cod_empresa         LIKE empresa.cod_empresa,
            l_cod_moeda           LIKE moeda.cod_moeda,
            l_cod_item            LIKE item.cod_item,
            l_num_sequencia       LIKE cli_end_ent.num_sequencia,
            l_filtro              CHAR(80)

     DEFINE l_condicao            CHAR(300)

     LET l_condicao = NULL
     CASE
         WHEN infield(cod_forma_entrada)
             LET l_cod_forma_pgto = log009_popup(8,20,
                                               'FORMA DE PAGAMENTO',
                                               'sol_forma_pgto_imp',
                                               'cod_forma_pgto',
                                               'den_forma_pgto',
                                               '',
                                               'N',
                                                l_condicao)

             IF  l_cod_forma_pgto IS NOT NULL THEN
                 LET mr_tela1.cod_forma_entrada = l_cod_forma_pgto
                 CURRENT WINDOW IS w_are00801
                 DISPLAY BY NAME mr_tela1.cod_forma_entrada
             END IF

         WHEN infield(cod_forma_pgto)
             LET l_cod_forma_pgto = log009_popup(8,20,
                                               'FORMA DE PAGAMENTO',
                                               'sol_forma_pgto_imp',
                                               'cod_forma_pgto',
                                               'den_forma_pgto',
                                               '',
                                               'N',
                                                l_condicao)

             IF  l_cod_forma_pgto IS NOT NULL THEN
                 LET mr_tela1.cod_forma_pgto = l_cod_forma_pgto
                 CURRENT WINDOW IS w_are00801
                 DISPLAY BY NAME mr_tela1.cod_forma_pgto
             END IF

         WHEN infield(cod_repres)
             LET l_cod_repres = log009_popup(8,20,
                                               'VENDEDORES',
                                               'representante',
                                               'cod_repres',
                                               'raz_social',
                                               'vdp3550',
                                               'N',
                                                l_condicao)

             IF  l_cod_repres IS NOT NULL THEN
                 LET mr_tela.cod_repres = l_cod_repres
                 CURRENT WINDOW IS w_are0080
                 DISPLAY BY NAME mr_tela.cod_repres
             END IF

         WHEN infield(cod_nat_oper)
             LET l_cod_nat_oper  = log009_popup(8,20,
                                               'NATUREZA OPERAÇÃO',
                                               'nat_operacao',
                                               'cod_nat_oper',
                                               'den_nat_oper',
                                               'vdp0050',
                                               'N',
                                                l_condicao)

             IF  l_cod_nat_oper IS NOT NULL THEN
                 LET mr_tela.cod_nat_oper = l_cod_nat_oper
                 CURRENT WINDOW IS w_are0080
                 DISPLAY BY NAME mr_tela.cod_nat_oper
             END IF

         WHEN infield(cod_cnd_pgto)
             LET l_cod_cnd_pgto   = log009_popup(8,20,
                                               'CONDIÇÕES DE PAGAMENTO',
                                               'cond_pgto',
                                               'cod_cnd_pgto',
                                               'den_cnd_pgto',
                                               'vdp0140',
                                               'N',
                                                l_condicao)

             IF  l_cod_cnd_pgto IS NOT NULL THEN
                 LET mr_tela1.cod_cnd_pgto = l_cod_cnd_pgto
                 CURRENT WINDOW IS w_are00801
                 DISPLAY BY NAME mr_tela1.cod_cnd_pgto
             END IF

         WHEN infield(cod_moeda)
             LET l_cod_moeda  = log009_popup(8,20,
                                               'MOEDAS',
                                               'moeda',
                                               'cod_moeda',
                                               'den_moeda',
                                               'pat0140',
                                               'N',
                                                l_condicao)

             IF  l_cod_moeda IS NOT NULL THEN
                 LET mr_tela.cod_moeda = l_cod_moeda
                 CURRENT WINDOW IS w_are0080
                 DISPLAY BY NAME mr_tela.cod_moeda
             END IF

         WHEN infield(qtd_pecas_solic)
             LET l_cod_empresa  = are0090_estoque(m_cod_item_barra)
             IF  l_cod_empresa IS NOT NULL THEN
                 LET m_orcamento[p_arr_cur].cod_empresa_estoq = l_cod_empresa
                 CURRENT WINDOW IS w_are00801
                 DISPLAY m_orcamento[p_arr_cur].cod_empresa_estoq  TO s_orcamento[p_scr_lin].cod_empresa_estoq
             END IF

         WHEN infield(cod_cliente)
             LET l_cod_cliente = vdp372_popup_cliente()
             CALL log006_exibe_teclas("01 02 03 07", p_versao)
             CURRENT WINDOW IS w_are0080
             IF   l_cod_cliente IS NOT NULL
             THEN LET mr_tela.cod_cliente = l_cod_cliente
                  DISPLAY BY NAME mr_tela.cod_cliente
             END IF

         WHEN infield(cod_item)
             LET l_cod_item = min071_popup_item(p_cod_empresa)
             CURRENT WINDOW IS w_are00801
             IF l_cod_item IS NOT NULL THEN
                LET m_orcamento[p_arr_cur].cod_item = l_cod_item
                DISPLAY m_orcamento[p_arr_cur].cod_item TO s_orcamento[p_scr_lin].cod_item
             END IF
             RETURN

         WHEN infield(num_sequencia)
	        LET l_filtro = "cli_end_ent.cod_cliente = '",mr_tela.cod_cliente,"'"
	        CALL log009_popup(6,25,"CLIENTE END. ENTREGA","cli_end_ent",
			                        "num_sequencia","end_entrega",
			                        "vdp3640","N", l_filtro)  RETURNING l_num_sequencia
             CALL log006_exibe_teclas("01 02 03 07", p_versao)
             CURRENT WINDOW IS w_are00803
             LET l_sol_cli_end_ent.num_sequencia = l_num_sequencia
             DISPLAY l_num_sequencia TO num_sequencia
             RETURN


    WHEN infield(cod_grade_1)
         CALL log009_popup(6,21,ma_ctr_grade[1].descr_cabec_zoom,
                                ma_ctr_grade[1].nom_tabela_zoom,
                                ma_ctr_grade[1].descr_col_1_zoom,
                                ma_ctr_grade[1].descr_col_2_zoom,
                                ma_ctr_grade[1].cod_progr_manut,"N","")
              RETURNING t_array_grade[pa_curr_g].cod_grade_1
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_are00805
         DISPLAY t_array_grade[pa_curr_g].cod_grade_1
              TO s_grade[sc_curr_g].cod_grade_1

    WHEN infield(cod_grade_2)
         CALL log009_popup(6,21,ma_ctr_grade[2].descr_cabec_zoom,
                                ma_ctr_grade[2].nom_tabela_zoom,
                                ma_ctr_grade[2].descr_col_1_zoom,
                                ma_ctr_grade[2].descr_col_2_zoom,
                                ma_ctr_grade[2].cod_progr_manut,"N","")
              RETURNING t_array_grade[pa_curr_g].cod_grade_2
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_are00805
         DISPLAY t_array_grade[pa_curr_g].cod_grade_2
              TO s_grade[sc_curr_g].cod_grade_2

   WHEN infield(cod_grade_3)
         CALL log009_popup(6,21,ma_ctr_grade[3].descr_cabec_zoom,
                                ma_ctr_grade[3].nom_tabela_zoom,
                                ma_ctr_grade[3].descr_col_1_zoom,
                                ma_ctr_grade[3].descr_col_2_zoom,
                                ma_ctr_grade[3].cod_progr_manut,"N","")
              RETURNING t_array_grade[pa_curr_g].cod_grade_3
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_are00805
         DISPLAY t_array_grade[pa_curr_g].cod_grade_3
              TO s_grade[sc_curr_g].cod_grade_3

   WHEN infield(cod_grade_4)
         CALL log009_popup(6,21,ma_ctr_grade[4].descr_cabec_zoom,
                                ma_ctr_grade[4].nom_tabela_zoom,
                                ma_ctr_grade[4].descr_col_1_zoom,
                                ma_ctr_grade[4].descr_col_2_zoom,
                                ma_ctr_grade[4].cod_progr_manut,"N","")
              RETURNING t_array_grade[pa_curr_g].cod_grade_4
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_are00805
         DISPLAY t_array_grade[pa_curr_g].cod_grade_4
              TO s_grade[sc_curr_g].cod_grade_4

   WHEN infield(cod_grade_5)
         CALL log009_popup(6,21,ma_ctr_grade[5].descr_cabec_zoom,
                                ma_ctr_grade[5].nom_tabela_zoom,
                                ma_ctr_grade[5].descr_col_1_zoom,
                                ma_ctr_grade[5].descr_col_2_zoom,
                                ma_ctr_grade[5].cod_progr_manut,"N","")
              RETURNING t_array_grade[pa_curr_g].cod_grade_5
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_are00805
         DISPLAY t_array_grade[pa_curr_g].cod_grade_5
              TO s_grade[sc_curr_g].cod_grade_5


        END CASE

     CALL log006_exibe_teclas('01 02 03 07', p_versao)
     CURRENT WINDOW IS w_are0080
 END FUNCTION

#------------------------#
 FUNCTION are0080_help()
#------------------------#
     CASE
         WHEN infield(cod_repres)
             CALL SHOWHELP(101)

         WHEN infield(cod_cliente)
             CALL SHOWHELP(102)
     END CASE
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0080_lista_sol_orcamento()
#-------------------------------------------------------#
    DEFINE l_num_orcamento        LIKE sol_orcamento.num_orcamento
    DEFINE l_clientes             RECORD LIKE clientes.*
    DEFINE l_mensagem             CHAR(100)
    DEFINE lr_relat               RECORD
           num_orcamento          LIKE sol_orcamento.num_orcamento,
           cod_cliente            LIKE clientes.cod_cliente,
           nom_cliente            LIKE clientes.nom_cliente,
           end_cliente            LIKE clientes.end_cliente,
           cod_cep                LIKE clientes.cod_cep,
           num_telefone           LIKE clientes.num_telefone,
           den_bairro             LIKE clientes.den_bairro,
           den_cidade             LIKE cidades.den_cidade,
           cod_uni_feder          LIKE cidades.cod_uni_feder,
           num_pedido_cli         LIKE sol_orcamento.num_pedido_cli,
           den_nat_oper           LIKE nat_operacao.den_nat_oper,
           den_cnd_pgto           LIKE cond_pgto.den_cnd_pgto,
           den_moeda              LIKE moeda.den_moeda,
           dat_validade_orc       LIKE sol_orcamento.dat_validade_orc,
           list_preco_avista      LIKE sol_orcamento.list_preco_avista,
           list_preco_aprazo      LIKE sol_orcamento.list_preco_aprazo,
           raz_social             LIKE representante.raz_social,
           situacao               CHAR(30),
           pre_unit_avista        LIKE sol_orc_itens.pre_unit_avista,
           pre_unit_aprazo        LIKE sol_orc_itens.pre_unit_aprazo,
           pct_desc_orc           LIKE sol_orcamento.pct_desc_orc,
           total_desconto         DECIMAL(17,2),
           cod_forma_pgto         LIKE sol_orcamento.cod_forma_pgto
                                  END RECORD

    LET m_caminho = log1300_procura_caminho('are00802','')
    OPEN WINDOW w_are00802 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are00802

     INPUT BY NAME l_num_orcamento WITHOUT DEFAULTS
          AFTER FIELD l_num_orcamento
            SELECT * FROM sol_orcamento
             WHERE cod_empresa = p_cod_empresa
               AND num_orcamento = l_num_orcamento

            IF sqlca.sqlcode <> 0 THEN
               CALL log0030_mensagem('Número do orçamento não existe.','excl')
               NEXT FIELD l_num_orcamento
            END IF
    END INPUT

    IF INT_FLAG <> 0 THEN
       LET INT_FLAG = 0
       CALL log0030_mensagem('Parâmetro cancelado.','excl')
       RETURN
    END IF
    CLOSE WINDOW w_are00802
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0080

    MESSAGE ' Processando a extração do relatório ... ' ATTRIBUTE(REVERSE)

    IF  p_ies_impressao = 'S' THEN
        IF  g_ies_ambiente = 'U' THEN
            START REPORT are0080_relat TO PIPE p_nom_arquivo
        ELSE
            CALL log150_procura_caminho('LST') RETURNING m_caminho
            LET m_caminho = m_caminho CLIPPED, 'are0080.tmp'
            START REPORT are0080_relat TO m_caminho
        END IF
    ELSE
        START REPORT are0080_relat TO p_nom_arquivo
    END IF

    DECLARE cl_sol_orcamento CURSOR FOR
     SELECT * INTO mr_sol_orcamento.*
       FROM sol_orcamento
      WHERE sol_orcamento.cod_empresa = p_cod_empresa
        AND sol_orcamento.num_orcamento = l_num_orcamento

    OPEN  cl_sol_orcamento
    FETCH cl_sol_orcamento

    IF  sqlca.sqlcode = 0 THEN
        WHILE sqlca.sqlcode = 0
           SELECT * INTO l_clientes.*
             FROM clientes
           WHERE cod_cliente = mr_sol_orcamento.cod_cliente

           SELECT den_cidade,cod_uni_feder
             INTO lr_relat.den_cidade, lr_relat.cod_uni_feder
             FROM cidades
           WHERE cod_cidade = l_clientes.cod_cidade

           SELECT den_nat_oper INTO lr_relat.den_nat_oper
             FROM nat_operacao
           WHERE cod_nat_oper = mr_sol_orcamento.cod_nat_oper

           SELECT den_cnd_pgto INTO lr_relat.den_cnd_pgto
             FROM cond_pgto
           WHERE cod_cnd_pgto = mr_sol_orcamento.cod_cnd_pgto

           SELECT den_moeda INTO lr_relat.den_moeda
             FROM moeda
           WHERE cod_moeda = mr_sol_orcamento.cod_moeda

           SELECT raz_social INTO lr_relat.raz_social
             FROM representante
           WHERE cod_repres = mr_sol_orcamento.cod_repres

           CASE
             WHEN mr_sol_orcamento.ies_situacao = "N"
                 LET lr_relat.situacao = "NORMAL"
             WHEN mr_sol_orcamento.ies_situacao = "B"
                 LET lr_relat.situacao = "BLOQUEADO"
             WHEN mr_sol_orcamento.ies_situacao = "L"
                 LET lr_relat.situacao = "LIBERADO P/ VENDA"
             WHEN mr_sol_orcamento.ies_situacao = "C"
                 LET lr_relat.situacao = "CANCELADO"
             WHEN mr_sol_orcamento.ies_situacao = "R"
                 LET lr_relat.situacao = "REALIZADO"
           END CASE

           LET lr_relat.num_orcamento          = mr_sol_orcamento.num_orcamento
           LET lr_relat.cod_cliente            = mr_sol_orcamento.cod_cliente
           LET lr_relat.nom_cliente            = l_clientes.nom_cliente
           LET lr_relat.end_cliente            = l_clientes.end_cliente
           LET lr_relat.cod_cep                = l_clientes.cod_cep
           LET lr_relat.num_telefone           = l_clientes.num_telefone
           LET lr_relat.den_bairro             = l_clientes.den_bairro
           LET lr_relat.num_pedido_cli         = mr_sol_orcamento.num_pedido_cli
           LET lr_relat.dat_validade_orc       = mr_sol_orcamento.dat_validade_orc
           LET lr_relat.list_preco_avista      = mr_sol_orcamento.list_preco_avista
           LET lr_relat.list_preco_aprazo      = mr_sol_orcamento.list_preco_aprazo
           LET lr_relat.pct_desc_orc           = mr_sol_orcamento.pct_desc_orc
           LET lr_relat.cod_forma_pgto         = mr_sol_orcamento.cod_forma_pgto

            OUTPUT TO REPORT are0080_relat(lr_relat.*)
            FETCH cl_sol_orcamento
        END WHILE
    ELSE
        INITIALIZE lr_relat.* TO NULL
        OUTPUT TO REPORT are0080_relat(lr_relat.*)
        CALL log0030_mensagem(' Não existem dados para serem listados. ' ,'excl')
    END IF
    CLOSE cl_sol_orcamento

    FINISH REPORT are0080_relat
    IF  g_ies_ambiente = 'W'   AND
        p_ies_impressao = 'S'  THEN
        LET m_comando = 'lpdos.bat ',
                        m_caminho CLIPPED, ' ', p_nom_arquivo CLIPPED
        RUN m_comando
    END IF

    IF  p_ies_impressao = 'S' THEN
        CALL log0030_mensagem('Relatório gravado com sucesso','excl')
        MESSAGE 'Fim de Processamento.' ATTRIBUTE(REVERSE)
    ELSE
        LET  l_mensagem = 'Relatório gravado no arquivo ',p_nom_arquivo CLIPPED
        CALL log0030_mensagem(l_mensagem,'excl')
        MESSAGE 'Fim de Processamento.' ATTRIBUTE(REVERSE)
    END IF

END FUNCTION

#-------------------------------------------------------#
 REPORT are0080_relat(lr_relat)
#-------------------------------------------------------#
    DEFINE lr_relat               RECORD
           num_orcamento          LIKE sol_orcamento.num_orcamento,
           cod_cliente            LIKE clientes.cod_cliente,
           nom_cliente            LIKE clientes.nom_cliente,
           end_cliente            LIKE clientes.end_cliente,
           cod_cep                LIKE clientes.cod_cep,
           num_telefone           LIKE clientes.num_telefone,
           den_bairro             LIKE clientes.den_bairro,
           den_cidade             LIKE cidades.den_cidade,
           cod_uni_feder          LIKE cidades.cod_uni_feder,
           num_pedido_cli         LIKE sol_orcamento.num_pedido_cli,
           den_nat_oper           LIKE nat_operacao.den_nat_oper,
           den_cnd_pgto           LIKE cond_pgto.den_cnd_pgto,
           den_moeda              LIKE moeda.den_moeda,
           dat_validade_orc       LIKE sol_orcamento.dat_validade_orc,
           list_preco_avista      LIKE sol_orcamento.list_preco_avista,
           list_preco_aprazo      LIKE sol_orcamento.list_preco_aprazo,
           raz_social             LIKE representante.raz_social,
           situacao               CHAR(30),
           pre_unit_avista        LIKE sol_orc_itens.pre_unit_avista,
           pre_unit_aprazo        LIKE sol_orc_itens.pre_unit_aprazo,
           pct_desc_orc           LIKE sol_orcamento.pct_desc_orc,
           total_desconto         DECIMAL(17,2),
           cod_forma_pgto         LIKE sol_orcamento.cod_forma_pgto
                                  END RECORD,
           l_den_item             LIKE item.den_item ,
           l_cod_unid_med         LIKE item.cod_unid_med
DEFINE l_preco_avista            LIKE sol_orc_itens.pre_unit_aprazo,
       l_preco_aprazo            LIKE sol_orc_itens.pre_unit_aprazo,
       l_den_cidade              LIKE cidades.den_cidade,
       l_den_local_retirada      CHAR(22),
       l_den_forma_pgto          LIKE sol_forma_pgto_imp.den_forma_pgto,
       lr_sol_orc_itens          RECORD LIKE sol_orc_itens.*,
       l_sol_observ_orcam        RECORD LIKE sol_observ_orcam.*,
       l_sol_cli_end_ent         RECORD LIKE sol_cli_end_ent.*,
       l_empresa                RECORD LIKE empresa.*

    OUTPUT
        LEFT MARGIN 0
        TOP MARGIN 0
        BOTTOM MARGIN 1
{
Layout

}

    FORMAT
        PAGE HEADER
            SELECT * INTO l_empresa.*
              FROM empresa
             WHERE cod_empresa = p_cod_empresa

            PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
            PRINT COLUMN 001, l_empresa.den_empresa
            PRINT COLUMN 001, l_empresa.end_empresa CLIPPED, "  Bairro: ",
                              l_empresa.den_bairro
            PRINT COLUMN 001, l_empresa.den_munic CLIPPED, " - ",
                              l_empresa.uni_feder
            PRINT COLUMN 001, 'C.G.C.: ',l_empresa.num_cgc CLIPPED,
                              "  I.E.: ", l_empresa.ins_estadual
            PRINT COLUMN 001, 'Telefone: ',l_empresa.num_telefone
            SKIP 1 LINE
            PRINT COLUMN 001, 'ARE0080',
                  COLUMN 042, 'ORÇAMENTO - ', lr_relat.num_orcamento USING "#####",
                  COLUMN 125, 'FL. ', PAGENO USING '####'
            PRINT COLUMN 093, 'EXTRAIDO EM ', TODAY USING 'dd/mm/yyyy',
                  COLUMN 117, 'AS ', TIME,
                  COLUMN 129, 'HRS.'
            SKIP 1 LINE

            PRINT COLUMN 001,"CLIENTE    : ",lr_relat.cod_cliente," - ",lr_relat.nom_cliente
            PRINT COLUMN 001,"ENDERECO   : ",lr_relat.end_cliente,
                  COLUMN 080," CEP   : ",lr_relat.cod_cep,
                  COLUMN 110,"TELEFONE: ",lr_relat.num_telefone
            PRINT COLUMN 001,"BAIRRO     : ",lr_relat.den_bairro,
                  COLUMN 080," CIDADE: ",lr_relat.den_cidade[1,22],
                  COLUMN 110,"ESTADO  : ",lr_relat.cod_uni_feder
            PRINT COLUMN 001,"PED.CLIENTE: ",lr_relat.num_pedido_cli
            PRINT COLUMN 001,"OPERAÇÃO   : ",lr_relat.den_nat_oper
            PRINT COLUMN 001,"-----------------------------------------------------------------------------------------------------------------------------------"
            PRINT COLUMN 001,"COD. PRODUTO    DENOMINAÇÃO                                       QUANTIDADE U.M.     PRECO A VISTA     PRECO A PRAZO PRAZO ENTREGA"
            PRINT COLUMN 001,"--------------- ----------------------------------------------- ------------ ---- ----------------- ----------------- -------------"

        ON EVERY ROW
           DECLARE cq_rel CURSOR FOR
           SELECT * INTO lr_sol_orc_itens.*
             FROM sol_orc_itens
            WHERE cod_empresa = p_cod_empresa
              AND num_orcamento = lr_relat.num_orcamento
            ORDER BY num_sequencia

          LET l_preco_avista = 0
          LET l_preco_aprazo = 0

          FOREACH cq_rel
            SELECT den_item,cod_unid_med INTO l_den_item,l_cod_unid_med
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item = lr_sol_orc_itens.cod_item

            IF lr_sol_orc_itens.cod_local_retirada = 1 THEN
               LET l_den_local_retirada = "CAIXA "
            ELSE
               IF lr_sol_orc_itens.cod_local_retirada = 2 THEN
                  LET l_den_local_retirada = "NF A RETIRAR."
               ELSE
                  IF lr_sol_orc_itens.cod_local_retirada = 3 THEN
                     LET l_den_local_retirada = "NF A ENTREGAR."
                  ELSE
                     LET l_den_local_retirada = "CAIXA DUP/NF."
                  END IF
               END IF
            END IF

            PRINT COLUMN 001, lr_sol_orc_itens.cod_item,
                  COLUMN 017, l_den_item[1,48],
                  COLUMN 065, lr_sol_orc_itens.qtd_pecas_solic USING "#####,##&.&&",
                  COLUMN 079, l_cod_unid_med,
                  COLUMN 084, lr_sol_orc_itens.pre_unit_avista USING "##,###,###,##&.&&",
                  COLUMN 102, lr_sol_orc_itens.pre_unit_aprazo USING "##,###,###,##&.&&",
                  COLUMN 121, lr_sol_orc_itens.prz_entrega
            PRINT COLUMN 001, "LOCAL RETIRADA: ", lr_sol_orc_itens.cod_local_retirada USING "#",
                              " - ", l_den_local_retirada

            LET l_preco_avista = l_preco_avista + (lr_sol_orc_itens.pre_unit_avista*lr_sol_orc_itens.qtd_pecas_solic)
            LET l_preco_aprazo = l_preco_aprazo + (lr_sol_orc_itens.pre_unit_aprazo*lr_sol_orc_itens.qtd_pecas_solic)
          END FOREACH

            SKIP 2 LINES
            PRINT COLUMN 001,"COND. PAGAMENTO     : ",lr_relat.den_cnd_pgto,
                  COLUMN 060,"MOEDA: ",lr_relat.den_moeda,
                  COLUMN 110,"VALIDADE: ",lr_relat.dat_validade_orc

            SELECT den_forma_pgto INTO l_den_forma_pgto
              FROM sol_forma_pgto_imp
             WHERE cod_forma_pgto = lr_relat.cod_forma_pgto

            PRINT COLUMN 001,"    FORMA PAGAMENTO : ",lr_relat.cod_forma_pgto," - ",l_den_forma_pgto

            PRINT COLUMN 060,"VENDEDOR: ",lr_relat.raz_social,
                  COLUMN 110,"SITUACAO: ",lr_relat.situacao

            SKIP 1 LINE
            PRINT COLUMN 001,"TOTAL PREÇO À VISTA : ",l_preco_avista USING "##,###,###,##&.&&"
            PRINT COLUMN 001,"TOTAL PREÇO A PRAZO : ",l_preco_aprazo USING "##,###,###,##&.&&"
            PRINT COLUMN 001,"DESCONTO ADICIONAL  : ",lr_relat.pct_desc_orc," %"
            SKIP 1 LINE
            PRINT COLUMN 001,"TOTAL ORÇAM À VISTA : ",l_preco_avista - (l_preco_avista*lr_relat.pct_desc_orc/100) USING "##,###,###,##&.&&"
            PRINT COLUMN 001,"TOTAL ORÇAM A PRAZO : ",l_preco_aprazo - (l_preco_aprazo*lr_relat.pct_desc_orc/100) USING "##,###,###,##&.&&"

        ON LAST ROW
            SELECT * INTO l_sol_cli_end_ent.*
              FROM sol_cli_end_ent
             WHERE cod_empresa  = p_cod_empresa
               AND num_orcamento = lr_relat.num_orcamento

            IF sqlca.sqlcode = 0 THEN
               SELECT den_cidade INTO l_den_cidade
                 FROM cidades
                WHERE cod_cidade = l_sol_cli_end_ent.cod_cidade
               SKIP 1 LINE
               PRINT COLUMN 001," ENDERECO : ",l_sol_cli_end_ent.end_entrega
               PRINT COLUMN 001,"   BAIRRO : ",l_sol_cli_end_ent.den_bairro
               PRINT COLUMN 001,"   CIDADE : ",l_den_cidade," C.E.P. ",l_sol_cli_end_ent.cod_cep
            END IF
            SELECT * INTO l_sol_observ_orcam.*
              FROM sol_observ_orcam
             WHERE cod_empresa  = p_cod_empresa
               AND num_orcamento = lr_relat.num_orcamento

            IF sqlca.sqlcode = 0 THEN
               SKIP 1 LINE
               PRINT COLUMN 001,"OBSERVAÇÃO: ",l_sol_observ_orcam.tex_observ_1
               PRINT COLUMN 001,"            ",l_sol_observ_orcam.tex_observ_2
            END IF

            LET m_last_row = true

        PAGE TRAILER
            IF  m_last_row = true
            THEN PRINT '* * * ULTIMA FOLHA * * *'
            ELSE PRINT ' '
            END IF
 END REPORT

#--------------------------------------#
 FUNCTION  are0080_entrada_dados_3()
#--------------------------------------#

     LET m_caminho = log1300_procura_caminho('are00803','')

     OPEN WINDOW w_are00803 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are00803

     DISPLAY mr_tela.num_orcamento  TO num_orcamento
     DISPLAY p_cod_empresa TO empresa

     INPUT l_sol_cli_end_ent.num_sequencia,
           l_sol_cli_end_ent.end_entrega,
           l_sol_cli_end_ent.den_bairro,
           l_sol_cli_end_ent.cod_cidade,
           l_sol_cli_end_ent.cod_cep,
           l_sol_cli_end_ent.num_cgc,
           l_sol_cli_end_ent.ins_estadual WITHOUT DEFAULTS
      FROM num_sequencia,
           end_entrega,
           den_bairro,
           cod_cidade,
           cod_cep,
           num_cgc,
           ins_estadual

      BEFORE FIELD num_sequencia
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','Zoom')
         ELSE DISPLAY '( Zoom )' AT 3,61
         END IF

      AFTER  FIELD num_sequencia
            IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','')
         ELSE DISPLAY '--------' AT 3,61
         END IF
            IF   l_sol_cli_end_ent.num_sequencia IS NULL THEN
                 EXIT INPUT
            ELSE IF   are0080_verifica_endeco_entrega()
                 THEN EXIT INPUT
                 ELSE CALL log0030_mensagem('Endereço de entrega não cadastrado.','excl')
  	              NEXT FIELD num_sequencia
                 END IF
            END IF

--#        CALL fgl_dialog_setkeylabel('control-z', NULL)

      ON KEY (control-z, f4)
         CALL are0080_popup()

    END INPUT

    CLOSE WINDOW w_are00803
    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_are0080

  IF INT_FLAG <> 0 THEN
    LET INT_FLAG = 0
    RETURN FALSE
  END IF
  RETURN TRUE

 END FUNCTION

#-----------------------------------------#
 FUNCTION are0080_verifica_endeco_entrega()
#-----------------------------------------#
  SELECT cli_end_ent.end_entrega,
         cli_end_ent.den_bairro,
         cli_end_ent.cod_cidade,
         cli_end_ent.cod_cep,
         cli_end_ent.num_cgc,
         cli_end_ent.ins_estadual
    INTO l_sol_cli_end_ent.end_entrega,
         l_sol_cli_end_ent.den_bairro,
         l_sol_cli_end_ent.cod_cidade,
         l_sol_cli_end_ent.cod_cep,
         l_sol_cli_end_ent.num_cgc,
         l_sol_cli_end_ent.ins_estadual
    FROM cli_end_ent
   WHERE cli_end_ent.cod_cliente   = mr_tela.cod_cliente
     AND cli_end_ent.num_sequencia = l_sol_cli_end_ent.num_sequencia

  IF   sqlca.sqlcode = 0 THEN
       DISPLAY BY NAME l_sol_cli_end_ent.end_entrega
       DISPLAY BY NAME l_sol_cli_end_ent.den_bairro
       DISPLAY BY NAME l_sol_cli_end_ent.cod_cidade
       DISPLAY BY NAME l_sol_cli_end_ent.cod_cep
       DISPLAY BY NAME l_sol_cli_end_ent.num_cgc
       DISPLAY BY NAME l_sol_cli_end_ent.ins_estadual
       RETURN TRUE
  ELSE
       RETURN FALSE
  END IF

END FUNCTION

#--------------------------------------#
 FUNCTION  are0080_entrada_dados_4()
#--------------------------------------#

     LET m_caminho = log1300_procura_caminho('are00804','')

     OPEN WINDOW w_are00804 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are00804

     INPUT l_sol_observ_orcam.tex_observ_1,
           l_sol_observ_orcam.tex_observ_2 WITHOUT DEFAULTS
      FROM tex_observ_1,
           tex_observ_2

#   END INPUT

 IF INT_FLAG <> 0 THEN
    CLOSE WINDOW w_are00804
    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_are0080
    LET INT_FLAG = 0
    RETURN FALSE
 END IF

 CLOSE WINDOW w_are00804
 CALL log006_exibe_teclas('01', p_versao)
 CURRENT WINDOW IS w_are0080
 RETURN TRUE

 END FUNCTION

#-------------------------------#
FUNCTION are0080_verifica_grade()
#-------------------------------#

   SELECT item.*
     INTO p_item2.*
     FROM item,
          item_vdp
    WHERE item.cod_item        = m_orcamento[p_arr_cur].cod_item
      AND item.cod_item        = item_vdp.cod_item
      AND item.cod_empresa     = p_cod_empresa
      AND item_vdp.cod_empresa = p_cod_empresa
   IF sqlca.sqlcode = NOTFOUND THEN
      CALL log0030_mensagem('Produto não cadastrado.','excl')
      LET p_status = 0
      RETURN  FALSE
   END IF

   SELECT UNIQUE cod_empresa
     FROM item_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_lin_prod  = 0
      AND cod_lin_recei = 0
      AND cod_seg_merc  = 0
      AND cod_cla_uso   = 0
      AND cod_item      = m_orcamento[p_arr_cur].cod_item
   IF sqlca.sqlcode = 0 THEN
      LET m_item_grade = TRUE
      IF are0080_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem('Entrada de grade Cancelada.','excl')
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   SELECT UNIQUE cod_empresa
     FROM item_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_lin_prod  = p_item2.cod_lin_prod
      AND cod_lin_recei = p_item2.cod_lin_recei
      AND cod_seg_merc  = p_item2.cod_seg_merc
      AND cod_cla_uso   = p_item2.cod_cla_uso
      AND (cod_item     IS NULL OR
           cod_item     = " ")
   IF sqlca.sqlcode = 0 THEN

      LET m_item_grade = TRUE
      IF are0080_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem('Entrada de grade Cancelada.','excl')
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   SELECT UNIQUE cod_empresa
     FROM item_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_lin_prod  = p_item2.cod_lin_prod
      AND cod_lin_recei = p_item2.cod_lin_recei
      AND cod_seg_merc  = p_item2.cod_seg_merc
      AND cod_cla_uso   = 0
      AND (cod_item     IS NULL OR
           cod_item     = " ")
   IF sqlca.sqlcode = 0 THEN
      LET p_item2.cod_cla_uso  = 0

      LET m_item_grade = TRUE
      IF are0080_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem('Entrada de grade Cancelada.','excl')
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   SELECT UNIQUE cod_empresa
     FROM item_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_lin_prod  = p_item2.cod_lin_prod
      AND cod_lin_recei = p_item2.cod_lin_recei
      AND cod_seg_merc  = 0
      AND cod_cla_uso   = 0
      AND (cod_item     IS NULL OR
           cod_item     = " ")
   IF sqlca.sqlcode = 0 THEN
      LET p_item2.cod_seg_merc  = 0
      LET p_item2.cod_cla_uso   = 0

      LET m_item_grade = TRUE
      IF are0080_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem('Entrada de grade Cancelada','excl')
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   SELECT UNIQUE cod_empresa
     FROM item_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_lin_prod  = p_item2.cod_lin_prod
      AND cod_lin_recei = 0
      AND cod_seg_merc  = 0
      AND cod_cla_uso   = 0
      AND (cod_item     IS NULL OR
           cod_item     = " ")
   IF sqlca.sqlcode = 0 THEN
      LET p_item2.cod_lin_recei = 0
      LET p_item2.cod_seg_merc  = 0
      LET p_item2.cod_cla_uso   = 0

      LET m_item_grade = TRUE
      IF are0080_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem('Entrada de grade Cancelada','excl')
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------------#
FUNCTION are0080_entrada_dados_grad()
#-----------------------------------#
   DEFINE l_for,
          l_count                   SMALLINT

   CALL log006_exibe_teclas("01 02 03 05 06 07", p_versao)

   WHENEVER ERROR CONTINUE
   CALL log130_procura_caminho("are00805") RETURNING m_comando
   OPEN WINDOW w_are00805 AT 2,2 WITH FORM m_comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   CALL log0010_close_window_screen()
   WHENEVER ERROR STOP

   CURRENT WINDOW IS w_are00805

   INITIALIZE t_array_grade TO NULL

   LET p_sum_qtd_grade = 0
   LET l_count = 0

   FOR l_for = 1 TO 500
      IF t_pedido_dig_grad[l_for].num_sequencia = p_arr_cur   THEN
         LET l_count                              = l_count + 1
         LET t_array_grade[l_count]. cod_grade_1  =
             t_pedido_dig_grad[l_for].cod_grade_1
         LET t_array_grade[l_count]. cod_grade_2  =
             t_pedido_dig_grad[l_for].cod_grade_2
         LET t_array_grade[l_count]. cod_grade_3  =
             t_pedido_dig_grad[l_for].cod_grade_3
         LET t_array_grade[l_count]. cod_grade_4  =
             t_pedido_dig_grad[l_for].cod_grade_4
         LET t_array_grade[l_count]. cod_grade_5  =
             t_pedido_dig_grad[l_for].cod_grade_5
         LET t_array_grade[l_count]. qtd_pecas    =
             t_pedido_dig_grad[l_for].qtd_pecas_solic

         LET p_sum_qtd_grade        = p_sum_qtd_grade  +
                                      t_pedido_dig_grad[l_for].qtd_pecas_solic
      END IF
   END FOR

   CALL are0080_busca_cab_grade()

   CALL SET_COUNT(l_count)

   INPUT ARRAY t_array_grade WITHOUT DEFAULTS
    FROM s_grade.*

      BEFORE ROW
         LET pa_curr_g  = arr_curr()
         LET pa_count_g = arr_count()
         LET sc_curr_g  = scr_line()

      BEFORE FIELD cod_grade_1
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','Zoom')
         ELSE DISPLAY '( Zoom )' AT 3,61
         END IF

      AFTER  FIELD cod_grade_1
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','')
         ELSE DISPLAY '--------' AT 3,61
         END IF
         IF (t_array_grade[pa_curr_g].cod_grade_1 IS NULL OR
             t_array_grade[pa_curr_g].cod_grade_1 = " "     ) AND
            fgl_lastkey() <> fgl_keyval("RETURN")             THEN
            EXIT INPUT
         END IF
         IF are0080_item_grade(1,t_array_grade[pa_curr_g].cod_grade_1) = FALSE
         THEN
            CALL log0030_mensagem('Grade não cadastrada para este item.','excl')
            NEXT FIELD cod_grade_1
         END IF

      BEFORE FIELD cod_grade_2
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','Zoom')
         ELSE DISPLAY '( Zoom )' AT 3,61
         END IF
         IF p_cab_grade.den_grade_2 IS NULL OR
            p_cab_grade.den_grade_2 = " "   THEN
            IF fgl_lastkey() = fgl_keyval("UP")   OR
               fgl_lastkey() = fgl_keyval("LEFT") THEN
               NEXT FIELD cod_grade_1
            ELSE
               NEXT FIELD cod_grade_3
            END IF
         END IF

      AFTER  FIELD cod_grade_2
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','')
         ELSE DISPLAY '--------' AT 3,61
         END IF
         IF are0080_item_grade(2,t_array_grade[pa_curr_g].cod_grade_2) = FALSE
         THEN
            CALL log0030_mensagem('Grade não cadastrada para este item','excl')
            NEXT FIELD cod_grade_2
         END IF

      BEFORE FIELD cod_grade_3
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','Zoom')
         ELSE DISPLAY '( Zoom )' AT 3,61
         END IF
         IF p_cab_grade.den_grade_3 IS NULL OR
            p_cab_grade.den_grade_3 = " "   THEN
            IF fgl_lastkey() = fgl_keyval("UP")   OR
               fgl_lastkey() = fgl_keyval("LEFT") THEN
               NEXT FIELD cod_grade_2
            ELSE
               NEXT FIELD cod_grade_4
            END IF
         END IF

      AFTER  FIELD cod_grade_3
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','')
         ELSE DISPLAY '--------' AT 3,61
         END IF
         IF are0080_item_grade(3,t_array_grade[pa_curr_g].cod_grade_3) = FALSE
         THEN
            CALL log0030_mensagem('Grade não cadastrada para o item','excl')
            NEXT FIELD cod_grade_3
         END IF

      BEFORE FIELD cod_grade_4
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','Zoom')
         ELSE DISPLAY '( Zoom )' AT 3,61
         END IF
         IF p_cab_grade.den_grade_4 IS NULL OR
            p_cab_grade.den_grade_4 = " "   THEN
            IF fgl_lastkey() = fgl_keyval("UP")   OR
               fgl_lastkey() = fgl_keyval("LEFT") THEN
               NEXT FIELD cod_grade_3
            ELSE
               NEXT FIELD cod_grade_5
            END IF
         END IF

      AFTER  FIELD cod_grade_4
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','')
         ELSE DISPLAY '--------' AT 3,61
         END IF
         IF are0080_item_grade(4,t_array_grade[pa_curr_g].cod_grade_4) = FALSE
         THEN
            CALL log0030_mensagem('Grade não cadastrada para o item','excl')
            NEXT FIELD cod_grade_4
         END IF

      BEFORE FIELD cod_grade_5
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','Zoom')
         ELSE DISPLAY '( Zoom )' AT 3,61
         END IF
         IF p_cab_grade.den_grade_5 IS NULL OR
            p_cab_grade.den_grade_5 = " "   THEN
            IF fgl_lastkey() = fgl_keyval("UP")   OR
               fgl_lastkey() = fgl_keyval("LEFT") THEN
               NEXT FIELD cod_grade_4
            ELSE
               NEXT FIELD qtd_pecas
            END IF
         END IF

      AFTER  FIELD cod_grade_5
         IF g_ies_grafico THEN
--#      CALL fgl_dialog_setkeylabel('control-z','')
         ELSE DISPLAY '--------' AT 3,61
         END IF
         IF are0080_item_grade(5,t_array_grade[pa_curr_g].cod_grade_5) = FALSE
         THEN
            CALL log0030_mensagem('Grade não cadastrada para o item','excl')
            NEXT FIELD cod_grade_5
         END IF

      AFTER  FIELD qtd_pecas
         IF t_array_grade[pa_curr_g].qtd_pecas IS NULL OR
            t_array_grade[pa_curr_g].qtd_pecas <= 0    THEN
            CALL log0030_mensagem('Quantidade deve ser maior que zero.','excl')
            NEXT FIELD qtd_pecas
         END IF

      AFTER DELETE
         IF pa_count_g > 0 AND
            pa_count_g >= pa_curr_g THEN
            INITIALIZE t_array_grade[pa_count_g].* TO NULL
         END IF

      ON KEY (control-z, f4)
         CALL are0080_popup()

   END INPUT

   CLOSE WINDOW w_are00805
   CALL log006_exibe_teclas("01 02 05 06 07", p_versao)
   CURRENT WINDOW IS w_are00801

   IF int_flag <> 0 THEN
      LET int_flag  = 0
      RETURN FALSE
   END IF

   CALL are0080_grava_alteracoes_grade()
   LET m_orcamento[p_arr_cur].qtd_pecas_solic = p_sum_qtd_grade

   RETURN TRUE
END FUNCTION

#--------------------------------#
FUNCTION are0080_busca_cab_grade()
#--------------------------------#

   INITIALIZE p_cab_grade.*,
              mr_item_ctr_grade.*,
              ma_ctr_grade           TO NULL

   SELECT *
     INTO mr_item_ctr_grade.*
     FROM item_ctr_grade
    WHERE cod_empresa        = p_cod_empresa
      AND cod_lin_prod       = 0
      AND cod_lin_recei      = 0
      AND cod_seg_merc       = 0
      AND cod_cla_uso        = 0
      AND cod_familia        = 0
      AND cod_item           = m_orcamento[p_arr_cur].cod_item
   IF sqlca.sqlcode <> 0 THEN
      RETURN
   END IF

   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_1
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_1
   IF sqlca.sqlcode = 0 THEN

      SELECT descr_cabec_zoom,
             nom_tabela_zoom,
             descr_col_1_zoom,
             descr_col_2_zoom,
             cod_progr_manut,
             ies_ctr_empresa
        INTO ma_ctr_grade[1].descr_cabec_zoom,
             ma_ctr_grade[1].nom_tabela_zoom,
             ma_ctr_grade[1].descr_col_1_zoom,
             ma_ctr_grade[1].descr_col_2_zoom,
             ma_ctr_grade[1].cod_progr_manut,
             ma_ctr_grade[1].ies_ctr_empresa
        FROM ctr_grade
       WHERE cod_empresa   = p_cod_empresa
         AND cod_grade     = mr_item_ctr_grade.num_grade_1
   END IF

   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_2
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_2
   IF sqlca.sqlcode = 0 THEN

      SELECT descr_cabec_zoom,
             nom_tabela_zoom,
             descr_col_1_zoom,
             descr_col_2_zoom,
             cod_progr_manut,
             ies_ctr_empresa
        INTO ma_ctr_grade[2].descr_cabec_zoom,
             ma_ctr_grade[2].nom_tabela_zoom,
             ma_ctr_grade[2].descr_col_1_zoom,
             ma_ctr_grade[2].descr_col_2_zoom,
             ma_ctr_grade[2].cod_progr_manut,
             ma_ctr_grade[2].ies_ctr_empresa
        FROM ctr_grade
       WHERE cod_empresa   = p_cod_empresa
         AND cod_grade     = mr_item_ctr_grade.num_grade_2
   END IF

   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_3
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_3
   IF sqlca.sqlcode = 0 THEN

      SELECT descr_cabec_zoom,
             nom_tabela_zoom,
             descr_col_1_zoom,
             descr_col_2_zoom,
             cod_progr_manut,
             ies_ctr_empresa
        INTO ma_ctr_grade[3].descr_cabec_zoom,
             ma_ctr_grade[3].nom_tabela_zoom,
             ma_ctr_grade[3].descr_col_1_zoom,
             ma_ctr_grade[3].descr_col_2_zoom,
             ma_ctr_grade[3].cod_progr_manut,
             ma_ctr_grade[3].ies_ctr_empresa
        FROM ctr_grade
       WHERE cod_empresa   = p_cod_empresa
         AND cod_grade     = mr_item_ctr_grade.num_grade_3
   END IF

   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_4
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_4
   IF sqlca.sqlcode = 0 THEN

      SELECT descr_cabec_zoom,
             nom_tabela_zoom,
             descr_col_1_zoom,
             descr_col_2_zoom,
             cod_progr_manut,
             ies_ctr_empresa
        INTO ma_ctr_grade[4].descr_cabec_zoom,
             ma_ctr_grade[4].nom_tabela_zoom,
             ma_ctr_grade[4].descr_col_1_zoom,
             ma_ctr_grade[4].descr_col_2_zoom,
             ma_ctr_grade[4].cod_progr_manut,
             ma_ctr_grade[4].ies_ctr_empresa
        FROM ctr_grade
       WHERE cod_empresa   = p_cod_empresa
         AND cod_grade     = mr_item_ctr_grade.num_grade_4
   END IF

   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_5
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_5
   IF sqlca.sqlcode = 0 THEN

      SELECT descr_cabec_zoom,
             nom_tabela_zoom,
             descr_col_1_zoom,
             descr_col_2_zoom,
             cod_progr_manut,
             ies_ctr_empresa
        INTO ma_ctr_grade[5].descr_cabec_zoom,
             ma_ctr_grade[5].nom_tabela_zoom,
             ma_ctr_grade[5].descr_col_1_zoom,
             ma_ctr_grade[5].descr_col_2_zoom,
             ma_ctr_grade[5].cod_progr_manut,
             ma_ctr_grade[5].ies_ctr_empresa
        FROM ctr_grade
       WHERE cod_empresa   = p_cod_empresa
         AND cod_grade     = mr_item_ctr_grade.num_grade_5
   END IF

   DISPLAY BY NAME p_cab_grade.*

END FUNCTION

#---------------------------------------------------#
FUNCTION are0080_item_grade(p_ies_grade, l_cod_grade)
#---------------------------------------------------#
   DEFINE p_ies_grade        SMALLINT,
          l_cod_grade        LIKE grupo_grade.cod_grade

   CASE
      WHEN p_ies_grade = 1
           LET p_ies_grade   = mr_item_ctr_grade.num_grade_1
      WHEN p_ies_grade = 2
           LET p_ies_grade   = mr_item_ctr_grade.num_grade_2
      WHEN p_ies_grade = 3
           LET p_ies_grade   = mr_item_ctr_grade.num_grade_3
      WHEN p_ies_grade = 4
           LET p_ies_grade   = mr_item_ctr_grade.num_grade_4
      WHEN p_ies_grade = 5
           LET p_ies_grade   = mr_item_ctr_grade.num_grade_5
   END CASE


   WHENEVER ERROR CONTINUE
   SELECT *
     FROM item_grade
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item2.cod_item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0    OR
      sqlca.sqlcode = -284 THEN

      WHENEVER ERROR CONTINUE
      SELECT *
        FROM item_grade
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_item2.cod_item
         AND num_grade   = p_ies_grade
         AND cod_grade   = l_cod_grade
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = 0  THEN
      ELSE

         WHENEVER ERROR CONTINUE
         SELECT *
           FROM item_grade,
                grupo_grade
          WHERE item_grade.cod_empresa      = p_cod_empresa
            AND item_grade.cod_item         = p_item2.cod_item
            AND item_grade.num_grade        = p_ies_grade
            AND grupo_grade.cod_empresa     = p_cod_empresa
            AND grupo_grade.num_grade       = p_ies_grade
            AND grupo_grade.cod_grupo_grade = item_grade.cod_grupo_grade
            AND grupo_grade.cod_grade       = l_cod_grade
          WHENEVER ERROR STOP
          IF sqlca.sqlcode = 0    OR
             sqlca.sqlcode = -284 THEN
          ELSE
             RETURN FALSE
          END IF
       END IF
    ELSE

       WHENEVER ERROR CONTINUE
       SELECT *
         FROM item_grade
        WHERE cod_empresa   = p_cod_empresa
          AND cod_lin_prod  = p_item2.cod_lin_prod
          AND cod_lin_recei = p_item2.cod_lin_recei
          AND cod_seg_merc  = p_item2.cod_seg_merc
          AND cod_cla_uso   = p_item2.cod_cla_uso
          AND (cod_item     IS NULL OR
               cod_item     = " ")
       WHENEVER ERROR STOP
       IF sqlca.sqlcode = 0    OR
          sqlca.sqlcode = -284 THEN

          WHENEVER ERROR CONTINUE
          SELECT *
            FROM item_grade
           WHERE cod_empresa   = p_cod_empresa
             AND cod_lin_prod  = p_item2.cod_lin_prod
             AND cod_lin_recei = p_item2.cod_lin_recei
             AND cod_seg_merc  = p_item2.cod_seg_merc
             AND cod_cla_uso   = p_item2.cod_cla_uso
             AND (cod_item     IS NULL OR
                  cod_item     = " ")
             AND num_grade     = p_ies_grade
             AND cod_grade     = l_cod_grade
          WHENEVER ERROR STOP
          IF sqlca.sqlcode = 0 THEN
          ELSE

             WHENEVER ERROR CONTINUE
             SELECT *
               FROM item_grade, grupo_grade
              WHERE item_grade.cod_empresa      = p_cod_empresa
                AND item_grade.cod_lin_prod     = p_item2.cod_lin_prod
                AND item_grade.cod_lin_recei    = p_item2.cod_lin_recei
                AND item_grade.cod_seg_merc     = p_item2.cod_seg_merc
                AND item_grade.cod_cla_uso      = p_item2.cod_cla_uso
                AND (item_grade.cod_item        IS NULL OR
                     item_grade.cod_item        = " ")
                AND item_grade.num_grade        = p_ies_grade
                AND grupo_grade.cod_empresa     = p_cod_empresa
                AND grupo_grade.num_grade       = p_ies_grade
                AND grupo_grade.cod_grupo_grade = item_grade.cod_grupo_grade
                AND grupo_grade.cod_grade       = l_cod_grade
             WHENEVER ERROR STOP
             IF sqlca.sqlcode = 0    OR
                sqlca.sqlcode = -284 THEN
             ELSE
                RETURN FALSE
             END IF
          END IF
       ELSE
          RETURN FALSE
       END IF
   END IF

   RETURN TRUE
END FUNCTION

#---------------------------------------#
FUNCTION are0080_grava_alteracoes_grade()
#---------------------------------------#
   DEFINE l_for,
          l_for_aux                     SMALLINT

   LET p_sum_qtd_grade = 0

   FOR l_for = 1 TO 500
      IF t_pedido_dig_grad[l_for].num_sequencia = p_arr_cur THEN
         INITIALIZE t_pedido_dig_grad[l_for].* TO NULL
      END IF
   END FOR

   FOR l_for = 1 TO 500
      IF t_array_grade[l_for].cod_grade_1 IS NULL OR
         t_array_grade[l_for].cod_grade_1 = " "   OR
         t_array_grade[l_for].qtd_pecas   IS NULL OR
         t_array_grade[l_for].qtd_pecas   = " "   THEN
         CONTINUE FOR
      END IF

      FOR l_for_aux = 1 TO 500
         IF t_pedido_dig_grad[l_for_aux].num_sequencia > 0 THEN
            CONTINUE FOR
         END IF
         LET t_pedido_dig_grad[l_for_aux].num_pedido        = 0
         LET t_pedido_dig_grad[l_for_aux].num_sequencia     = p_arr_cur
         LET t_pedido_dig_grad[l_for_aux].cod_item          =
             m_orcamento[p_arr_cur].cod_item
         LET t_pedido_dig_grad[l_for_aux].cod_grade_1       =
             t_array_grade[l_for].cod_grade_1
         LET t_pedido_dig_grad[l_for_aux].cod_grade_2       =
             t_array_grade[l_for].cod_grade_2
         LET t_pedido_dig_grad[l_for_aux].cod_grade_3       =
             t_array_grade[l_for].cod_grade_3
         LET t_pedido_dig_grad[l_for_aux].cod_grade_4       =
             t_array_grade[l_for].cod_grade_4
         LET t_pedido_dig_grad[l_for_aux].cod_grade_5       =
             t_array_grade[l_for].cod_grade_5
         LET t_pedido_dig_grad[l_for_aux].qtd_pecas_solic   =
             t_array_grade[l_for].qtd_pecas
         LET p_sum_qtd_grade  = p_sum_qtd_grade +
                                t_array_grade[l_for].qtd_pecas
         EXIT FOR
      END FOR
   END FOR

END FUNCTION
#-----------------------------#
FUNCTION are0080_inclui_grade()
#-----------------------------#
DEFINE l_sol_orc_itens_grade    RECORD LIKE sol_orc_itens_grd.*

   FOR pa_curr_g = 1 TO  500
      IF t_pedido_dig_grad[pa_curr_g].cod_grade_1 IS NOT NULL          AND
         t_pedido_dig_grad[pa_curr_g].cod_grade_1 != "               " THEN
         IF t_pedido_dig_grad[pa_curr_g].cod_grade_2 IS NULL THEN
            LET t_pedido_dig_grad[pa_curr_g].cod_grade_2 = " "
         END IF

         IF t_pedido_dig_grad[pa_curr_g].cod_grade_3 IS NULL THEN
            LET t_pedido_dig_grad[pa_curr_g].cod_grade_3 = " "
         END IF

         IF t_pedido_dig_grad[pa_curr_g].cod_grade_4 IS NULL THEN
            LET t_pedido_dig_grad[pa_curr_g].cod_grade_4 = " "
         END IF

         IF t_pedido_dig_grad[pa_curr_g].cod_grade_5 IS NULL THEN
            LET t_pedido_dig_grad[pa_curr_g].cod_grade_5 = " "
         END IF

         WHENEVER ERROR CONTINUE
         INSERT INTO sol_orc_itens_grd VALUES (p_cod_empresa,
                                                 mr_tela.num_orcamento,
                                                 t_pedido_dig_grad[pa_curr_g].num_sequencia,
                                                 t_pedido_dig_grad[pa_curr_g].cod_item,
                                                 t_pedido_dig_grad[pa_curr_g].cod_grade_1,
                                                 t_pedido_dig_grad[pa_curr_g].cod_grade_2,
                                                 t_pedido_dig_grad[pa_curr_g].cod_grade_3,
                                                 t_pedido_dig_grad[pa_curr_g].cod_grade_4,
                                                 t_pedido_dig_grad[pa_curr_g].cod_grade_5,
                                                 t_pedido_dig_grad[pa_curr_g].qtd_pecas_solic,
                                                 0,0)
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INCLUSAO","SOL_ORC_ITENS_GRD")
            RETURN FALSE
         END IF
      END IF
   END FOR
   RETURN TRUE
END FUNCTION
