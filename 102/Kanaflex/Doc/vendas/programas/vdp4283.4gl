###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: vdp4283                                               #
#           LOG0060 - LOG0090 - LOG0190 - LOG0270 - LOG1200       #
#           LOG1300 - LOG1400 - VDP0050 - VDP0120 - VDP0140       #
#           VDP0260 - VDP0880 - VDP2670 - VDP3080 - VDP3550       #
#           VDP3362 - VDP4285 - VDP5830 - VDP5960 - PAT0140       #
#           PAT0150 - VDP2430                                     #
# OBJETIVO: DIGITACAO DE PEDIDOS ON-LINE                          #
# AUTOR...: ANDREI DAGOBERTO STREIT                               #
# DATA....: 17/05/2002                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
         p_user                   LIKE usuario.nom_usuario,
         p_cancel                 INTEGER,
         p_status                 SMALLINT,
         g_ies_grafico            SMALLINT,
         p_comando                CHAR(80),
         p_caminho                CHAR(80),
         p_help                   CHAR(80),
         p_nom_tela               CHAR(80),
         p_voltou                 SMALLINT,
         pa_curr                  SMALLINT,
         pa_count                 SMALLINT,
         sc_curr                  SMALLINT,
         p_count                  SMALLINT,
         pa_curr_g                SMALLINT,
         pa_curr_b                SMALLINT,
         pa_count_g               SMALLINT,
         sc_curr_g                SMALLINT,
         sc_curr_b                SMALLINT,
         p_tela                   SMALLINT,
         p_for                    SMALLINT,
         p_flag                   SMALLINT,
         p_houve_erro             SMALLINT,
         p_houve_item_rep         SMALLINT,
         p_num_cgc_cpf            LIKE clientes.num_cgc_cpf,
         p_ins_estadual           LIKE clientes.ins_estadual,
         p_cod_cidade             LIKE clientes.cod_cidade,
         p_qtd_estoque            LIKE estoque.qtd_liberada,
         p_qtd_carteira           LIKE ped_itens.qtd_pecas_solic,
         p_qtd_disponivel         LIKE estoque.qtd_liberada,
         p_cod_uni_feder          CHAR(02)

  DEFINE p_ies_item_em_terc_ped   LIKE par_sup_pad.par_ies,
         p_ies_item_ped           LIKE par_vdp_pad.par_ies,
         p_pct_icm_contrib        LIKE fiscal_par.pct_icm_contrib,
         p_pct_icm_ncontrib       LIKE fiscal_par.pct_icm_ncontrib,
         p_pct_icm_consumo        LIKE fiscal_par.pct_icm_consumo,
         p_pct_icm                LIKE fiscal_par.pct_icm_consumo,
         p_ies_incid_ipi          LIKE fiscal_par.ies_incid_ipi,
         p_pct_ipi                LIKE item.pct_ipi,
         p_pct_desp_finan         LIKE cond_pgto.pct_desp_finan,
         p_pre_unit_ped           LIKE pedido_dig_item.pre_unit,
         p_pre_unit_liq           LIKE ped_itens.pre_unit,
         p_val_cotacao_min        LIKE cotacao.val_cotacao,
         p_pre_unit_min           LIKE pedido_dig_item.pre_unit,
         p_pct_dif                DECIMAL(17,6),
         p_qtd_dias_media         DECIMAL(05,0),
         p_cod_cliente_matriz     LIKE clientes.cod_cliente_matriz,
         p_ies_tip_controle       LIKE nat_operacao.ies_tip_controle,
         p_nom_cliente            LIKE clientes.nom_cliente,
         p_pct_desc_tot           LIKE pedido_dig_mest.pct_desc_adic,
         p_val_cotacao_ped        LIKE cotacao.val_cotacao,
         p_val_dup_aberto         LIKE cli_credito.val_dup_aberto,
         p_val_ped_carteira       LIKE cli_credito.val_ped_carteira,
         p_val_limite_cred_unid   LIKE cli_credito.val_limite_cred,
         p_val_limite_cred_cruz   DECIMAL(15,2),
         p_valor_pedido           DECIMAL(15,2),
         p_valor1                 DECIMAL(15,2),
         p_valor2                 DECIMAL(15,2),
         p_desc_mest              DECIMAL(08,02),
         p_desc_unico_mest        DECIMAL(08,02),
         p_desc_tot_geral         DECIMAL(08,02),
         p_ind                    SMALLINT,
         p_plano                  SMALLINT,
         p_num_sequencia          DECIMAL(05,0),
         p_ies_emite_dupl_nat     CHAR(01),
         ies_incl_txt             CHAR(01),
         p_erro                   CHAR(9),
         p_consist_cred           SMALLINT,
         p_achou                  SMALLINT,
         p_sum_qtd_grade          DECIMAL(13,3),
         p_transp_inat            SMALLINT

  DEFINE p_ctr_meta               RECORD LIKE ctr_meta.*,
         p_juros                  RECORD LIKE juros.*,
         p_preco_minimo           RECORD LIKE preco_minimo.*,
         p_item2                  RECORD LIKE item.*,
         p_pedido_dig_mest        RECORD LIKE pedido_dig_mest.*,
         p_pedido_dig_mestr       RECORD LIKE pedido_dig_mest.*,
         p_ped_itens              RECORD LIKE ped_itens.*,
         p_ped_itens_desc         RECORD LIKE ped_itens_desc.*,
         p_pedido_dig_obs         RECORD LIKE pedido_dig_obs.*,
         p_pedido_dig_obsr        RECORD LIKE pedido_dig_obs.*,
         p_pedido_dig_ent         RECORD LIKE pedido_dig_ent.*,
         p_pedido_dig_entr        RECORD LIKE pedido_dig_ent.*,
         p_pedido_dig_item        RECORD LIKE pedido_dig_item.*,
         p_ped_itens_rem          RECORD LIKE ped_itens_rem.*,
         p_ped_itens_bnf          RECORD LIKE ped_itens_bnf.*,
         p_prev_producao          RECORD LIKE previsao_producao.*,
         p_audit_logix            RECORD LIKE audit_logix.*,
         p_desc_preco_mest        RECORD LIKE desc_preco_mest.*,
         p_par_vdp                RECORD LIKE par_vdp.*,
         p_cli_canal_venda        RECORD LIKE cli_canal_venda.*,
         p_plano_contas           RECORD LIKE plano_contas.*,
         p_ped_item_nat           RECORD LIKE ped_item_nat.*,
         p_vendor_pedido          RECORD LIKE vendor_pedido.*,
         p_vendor_pedidor	  RECORD LIKE vendor_pedido.*

  DEFINE p_valor_item_ipi         LIKE nf_mestre.val_tot_nff,
         p_valor_item_icm         LIKE nf_mestre.val_tot_nff,
         p_valor_item_pis         LIKE nf_mestre.val_tot_nff,
         p_valor_item_comis       LIKE nf_mestre.val_tot_nff

  DEFINE t_ped_itens_desc         ARRAY[500] OF
                       RECORD
         num_pedido               LIKE ped_itens_desc.num_pedido,
         num_sequencia            LIKE ped_itens_desc.num_sequencia,
         pct_desc_1               LIKE ped_itens_desc.pct_desc_1,
         pct_desc_2               LIKE ped_itens_desc.pct_desc_2,
         pct_desc_3               LIKE ped_itens_desc.pct_desc_3,
         pct_desc_4               LIKE ped_itens_desc.pct_desc_4,
         pct_desc_5               LIKE ped_itens_desc.pct_desc_5,
         pct_desc_6               LIKE ped_itens_desc.pct_desc_6,
         pct_desc_7               LIKE ped_itens_desc.pct_desc_7,
         pct_desc_8               LIKE ped_itens_desc.pct_desc_8,
         pct_desc_9               LIKE ped_itens_desc.pct_desc_9,
         pct_desc_10              LIKE ped_itens_desc.pct_desc_10
                       END RECORD

  DEFINE t_pedido_dig_item        ARRAY[500]  OF
                       RECORD
         cod_item                 LIKE pedido_dig_item.cod_item,
         qtd_pecas_solic          LIKE pedido_dig_item.qtd_pecas_solic,
         pre_unit                 LIKE pedido_dig_item.pre_unit,
         pct_desc_adic            LIKE pedido_dig_item.pct_desc_adic,
         prz_entrega              LIKE pedido_dig_item.prz_entrega,
         ies_incl_txt             CHAR(01),
         val_frete_unit           LIKE pedido_dig_item.val_frete_unit,
         val_seguro_unit          LIKE pedido_dig_item.val_seguro_unit,
         parametro_dat            LIKE pedido_dig_item.prz_entrega
                       END RECORD

   DEFINE ma_ped_dig_bnf          ARRAY[500]
          OF RECORD
             cod_item             LIKE ped_dig_item_bnf.cod_item,
             qtd_pecas_solic      LIKE ped_dig_item_bnf.qtd_pecas_solic,
             pre_unit             LIKE ped_dig_item_bnf.pre_unit,
             pct_desc_adic        LIKE ped_dig_item_bnf.pct_desc_adic,
             prz_entrega          LIKE ped_dig_item_bnf.prz_entrega,
             den_item             LIKE item.den_item
          END RECORD

  DEFINE t_ped_itens_rem          ARRAY[500]  OF
                       RECORD
         num_sequencia            LIKE ped_itens_rem.num_sequencia,
         dat_emis_nf_usina        LIKE ped_itens_rem.dat_emis_nf_usina,
         dat_retorno_prev         LIKE ped_itens_rem.dat_retorno_prev,
         cod_motivo_remessa       LIKE ped_itens_rem.cod_motivo_remessa,
         val_estoque              LIKE ped_itens_rem.val_estoque,
         cod_area_negocio         LIKE ped_itens_rem.cod_area_negocio,
         cod_lin_negocio          LIKE ped_itens_rem.cod_lin_negocio,
         num_conta                LIKE ped_itens_rem.num_conta,
         tex_observ               LIKE ped_itens_rem.tex_observ,
         num_pedido_compra        LIKE ped_itens_rem.num_pedido_compra
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

  DEFINE p_total
                       RECORD
         quantidade               DECIMAL(15,3),
         preco                    DECIMAL(17,6),
         desc_adic                DECIMAL(06,2),
         total_val_bru            DECIMAL(15,3),
         total_val_liq            DECIMAL(15,3)
                       END RECORD
  DEFINE p_totalc
                       RECORD
         quantidade               DECIMAL(15,3),
         preco                    DECIMAL(17,6),
         desc_adic                DECIMAL(06,2),
         val_tot_bruto            DECIMAL(15,3),
         val_tot_liquido          DECIMAL(15,3)
                       END RECORD

  DEFINE g_cod_cliente LIKE clientes.cod_cliente

  DEFINE p_versao      CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

   DEFINE m_cod_nat_oper_ref  LIKE nat_oper_refer.cod_nat_oper_ref,
          m_desc_unico_item   DECIMAL(08,02),
          m_pct_desc_adic_max LIKE cli_info_adic.pct_desc_adic_max,
          m_informa_consig_ad     CHAR(01)


   DEFINE ma_ctr_grade        ARRAY[5]
          OF RECORD
             descr_cabec_zoom LIKE ctr_grade.descr_cabec_zoom,
             nom_tabela_zoom  LIKE ctr_grade.nom_tabela_zoom,
             descr_col_1_zoom LIKE ctr_grade.descr_col_1_zoom,
             descr_col_2_zoom LIKE ctr_grade.descr_col_2_zoom,
             cod_progr_manut  LIKE ctr_grade.cod_progr_manut,
             ies_ctr_empresa  LIKE ctr_grade.ies_ctr_empresa
          END RECORD

  DEFINE mr_item_ctr_grade    RECORD LIKE item_ctr_grade.*

  DEFINE m_lead_time          DECIMAL(3,0)

  DEFINE m_cod_repres_3       LIKE pedidos.cod_repres,
         m_pct_comissao_3     LIKE pedidos.pct_comissao,
         m_pct_comissao_2     LIKE pedidos.pct_comissao

  DEFINE m_pct_comis_par_1    LIKE pedidos.pct_comissao,
         m_pct_comis_par_2    LIKE pedidos.pct_comissao,
         m_pct_comis_par_3    LIKE pedidos.pct_comissao

  DEFINE m_linha_produto      LIKE ped_info_compl.parametro_texto,
         m_ies_txt_exped          CHAR(001)   #E# - 469670

  DEFINE m_msg                CHAR(200)
  DEFINE m_consis_trib_pedido CHAR(02)    #773477

   DEFINE ma_tela_consig_ad       ARRAY[500]
      OF RECORD
         cod_consig           LIKE transport.cod_transpor,
         den_consig           LIKE transport.den_transpor,
         cod_tip_frete        CHAR (01),
         den_tip_frete        CHAR (11)
      END RECORD

  DEFINE m_frete_gtc                    CHAR(01),
         mr_ped_info_compl_frete  RECORD LIKE ped_info_compl.*,
         m_transp_inat            SMALLINT,
         m_msg_erro              CHAR(100),
         m_frt_praca_consig             CHAR(01)


MAIN

     CALL log0180_conecta_usuario()

  LET p_versao = "VDP4283-10.02.00p" #Favor nao alterar esta linha (SUPORTE)
  WHENEVER ERROR CONTINUE
  CALL log1400_isolation()
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET  p_help = p_caminho
  OPTIONS
       HELP     FILE p_help,
        INSERT   KEY control-i,
       DELETE   KEY control-e,
       PREVIOUS KEY control-b,
       NEXT     KEY control-f

  CALL log001_acessa_usuario("VDP","LOGERP")
       RETURNING p_status, p_cod_empresa, p_user
  IF   p_status = 0
  THEN CALL vdp4283_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION vdp4283_controle()
#--------------------------#
  INITIALIZE p_pedido_dig_mest.*,
             p_pedido_dig_mestr.*,
             p_pedido_dig_obs.*,
             p_pedido_dig_obsr.*,
             p_pedido_dig_ent.*,
             p_pedido_dig_entr.*,
             p_pedido_dig_item.*,
             p_vendor_pedido.*,
             p_vendor_pedidor.* TO NULL

  CALL  vdp4283_cria_t_mestre()

  WHENEVER ERROR CONTINUE
  CALL log130_procura_caminho("vdp4283") RETURNING p_nom_tela
  OPEN WINDOW w_vdp4283 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  WHENEVER ERROR STOP

  CALL log006_exibe_teclas("01 02", p_versao)

  MENU "OPCAO"
    COMMAND "Incluir" "Inclui Pedido "
      HELP 0001
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","vdp4283","IN")
      THEN CALL vdp4283_inclusao_pedido()
           IF   p_houve_erro = FALSE
           THEN CALL log085_transacao("COMMIT")
                IF   sqlca.sqlcode = 0
                THEN
                ELSE CALL log003_err_sql("INCLUSAO ","PEDIDOS ")
                     CALL log085_transacao("ROLLBACK")
                     IF sqlca.sqlcode <> 0 THEN
                        CALL log003_err_sql("TRANSACAO","ROLLBACK")
                        RETURN
                     END IF
                END IF
           ELSE CALL log085_transacao("ROLLBACK")
                IF sqlca.sqlcode <> 0 THEN
                   CALL log003_err_sql("TRANSACAO","ROLLBACK")
                   RETURN
                END IF
           END IF
      ELSE
         CALL log0030_mensagem("Usuário não autorizado para fazer inclusão. ",
                               "exclamation")
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 0008
      IF   p_par_vdp.par_vdp_txt[22,22] = "S"
      THEN CALL vdp267_atualiza_ctr_meta("INCLUSAO")
      END IF
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  WHENEVER ERROR CONTINUE
  CLOSE WINDOW w_vdp42831
  CLOSE WINDOW w_vdp42832
  CLOSE WINDOW w_vdp42833
  CLOSE WINDOW w_vdp42837
  CLOSE WINDOW w_vdp4283
  WHENEVER ERROR STOP
END FUNCTION

#--------------------------------------------------#
FUNCTION vdp4283_insert_t_mestre(p_num_pedido,
                                 p_cod_repres,
                                 p_cod_nat_oper,
                                 p_cod_cnd_pgto,
                                 p_pct_desc_adic,
                                 p_cod_moeda)
#--------------------------------------------------#
   DEFINE p_num_pedido       LIKE pedidos.num_pedido,
          p_cod_repres       LIKE pedidos.cod_repres,
          p_cod_nat_oper     LIKE pedidos.cod_nat_oper ,
          p_cod_cnd_pgto     LIKE pedidos.cod_cnd_pgto,
          p_pct_desc_adic    LIKE pedidos.pct_desc_adic,
          p_cod_moeda        LIKE pedidos.cod_moeda

   WHENEVER ERROR CONTINUE
   INSERT INTO t_mestre (num_pedido   ,
                         cod_repres   ,
                         cod_nat_oper ,
                         cod_cnd_pgto ,
                         pct_desc_adic,
                         cod_moeda )
                        VALUES (p_num_pedido,
                                p_cod_repres,
                                p_cod_nat_oper,
                                p_cod_cnd_pgto,
                                p_pct_desc_adic,
                                p_cod_moeda );
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("INSERT","T_MESTRE")
     RETURN
  END IF
END FUNCTION


#------------------------------#
FUNCTION vdp4283_cria_t_mestre()
#------------------------------#

   WHENEVER ERROR CONTINUE
   DROP TABLE t_mestre
   DROP TABLE t_item
   DROP TABLE t_item_bnf

   CREATE TEMP  TABLE t_mestre
      (num_pedido            DECIMAL(6,0),
       cod_repres            DECIMAL(4,0),
       cod_nat_oper          INTEGER,
       cod_cnd_pgto          DECIMAL(3,0),
       pct_desc_adic         DECIMAL(4,2),
       cod_moeda             DECIMAL(3,0)
      );

   CREATE TEMP  TABLE t_item
      (num_pedido            DECIMAL(6,0),
       cod_item              CHAR(15),
       num_sequencia         DECIMAL(5,0),
       pre_unit              DECIMAL(17,6),
       qtd_pecas_solic       DECIMAL(10,3),
       prz_entrega           DATE,
       pct_desc_adic         DECIMAL(4,2)
      );

   CREATE TEMP TABLE t_item_bnf
      (num_pedido            DECIMAL(6,0),
       cod_item              CHAR(15),
       num_sequencia         DECIMAL(5,0),
       pre_unit              DECIMAL(17,6),
       qtd_pecas_solic       DECIMAL(10,3),
       prz_entrega           DATE,
       pct_desc_adic         DECIMAL(4,2)
      );

   WHENEVER ERROR STOP
END FUNCTION


#---------------------------------#
 FUNCTION vdp4283_inclusao_pedido()
#---------------------------------#
 #E# - 469670
 CALL vdpy154_cria_w_ped_inf_cpl() # TABELA COPIA DA PED_INFO_COMPL
                                   # PARA GRAVACAO DA OSERVACAO DE EXPEDICAO.
 #E# - 469670


 LET p_houve_erro = FALSE

 WHENEVER ERROR CONTINUE
 SELECT par_vdp.*  INTO p_par_vdp.*
   FROM par_vdp
  WHERE par_vdp.cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP

 IF   sqlca.sqlcode = NOTFOUND
 THEN LET g_ies_grafico = FALSE
--#   CALL fgl_init4js()
--#   LET g_ies_grafico = fgl_fglgui()
      IF NOT g_ies_grafico THEN
         PROMPT " PARAMETROS p/ consist. de pedidos nao encontrados",
                " Tecle ENTER "
         FOR p_comando
         RETURN
      ELSE
         CALL log0030_mensagem("PARAMETROS para consistência de pedidos não encontrados. ","exclamation")
         RETURN
      END IF
 END IF

 IF   p_par_vdp.par_vdp_txt[39,39] = "S"
 THEN
       WHENEVER ERROR CONTINUE
       SELECT juros.*  INTO p_juros.*
        FROM juros
       WHERE juros.cod_empresa = p_cod_empresa
         AND juros.ano_refer   = YEAR(TODAY)
         AND juros.mes_refer   = MONTH(TODAY)
       WHENEVER ERROR STOP
      IF   sqlca.sqlcode = NOTFOUND
      THEN LET g_ies_grafico = FALSE
--#        CALL fgl_init4js()
--#        LET g_ies_grafico = fgl_fglgui()
           IF NOT g_ies_grafico THEN
              PROMPT " JUROS p/ consist. de rentabilidade nao encontrados",
                     " Tecle ENTER "
              FOR p_comando
              RETURN
           ELSE
              CALL log0030_mensagem("JUROS para consistência de rentabilidade não encontrados. ","exclamation")
              RETURN
           END IF
      END IF
 END IF

  {Criar tabelas temporarias para consistencia da configuracao fiscal}
  IF NOT vdpr57_create_temp_tables() THEN
     CALL log0030_mensagem('Erro na criação de tabelas temporárias para consistência da configuração fiscal.','stop')
     EXIT PROGRAM
  END IF

   CALL log2250_busca_parametro(p_cod_empresa,'consist_trib_pedido')
     RETURNING m_consis_trib_pedido, p_status

  IF NOT p_status OR
     m_consis_trib_pedido IS NULL OR m_consis_trib_pedido = ' ' THEN
     LET m_consis_trib_pedido = 'S'
  END IF

  CALL log2250_busca_parametro(p_cod_empresa, 'ies_informa_consignatario')
    RETURNING m_informa_consig_ad, p_status
  IF m_informa_consig_ad IS NULL OR m_informa_consig_ad = " " THEN
    LET m_informa_consig_ad = "N"
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'calc_val_fret_consig')
     RETURNING m_frt_praca_consig, p_status

  IF p_status = FALSE OR m_frt_praca_consig IS NULL OR m_frt_praca_consig = ' ' THEN
     LET m_frt_praca_consig = 'N'
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'utilizar_frete_venda_gtc')
     RETURNING m_frete_gtc, p_status

  IF p_status = FALSE OR m_frete_gtc IS NULL OR m_frete_gtc = ' ' THEN
     LET m_frete_gtc = 'N'
  END IF


 WHENEVER ERROR CONTINUE
 SELECT par_ies INTO p_ies_item_em_terc_ped
   FROM par_sup_pad
  WHERE cod_empresa = p_cod_empresa
    AND cod_parametro = "ies_item_em_terc_ped"
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET p_ies_item_em_terc_ped = " "
 END IF

 IF p_ies_item_em_terc_ped IS NULL OR
    p_ies_item_em_terc_ped = " "   THEN
    LET p_ies_item_em_terc_ped = "N"
 END IF

  WHENEVER ERROR CONTINUE
  SELECT par_ies INTO p_ies_item_ped
   FROM par_vdp_pad
  WHERE cod_empresa = p_cod_empresa
    AND cod_parametro = "ies_item_ped"
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET p_ies_item_ped = " "
 END IF

 IF p_ies_item_ped IS NULL OR
    p_ies_item_ped = " "   THEN
    LET p_ies_item_ped = "S"
 END IF

 LET p_pedido_dig_mestr.* = p_pedido_dig_mest.*
 LET p_pedido_dig_obsr.*  = p_pedido_dig_obs.*
 LET p_pedido_dig_entr.*  = p_pedido_dig_ent.*

 INITIALIZE p_pedido_dig_mest.*,
            p_pedido_dig_obs.*,
            p_pedido_dig_ent.*,
            p_pedido_dig_item.*,
            t_pedido_dig_item,
            t_pedido_dig_grad,
            ma_ped_dig_bnf,
            m_linha_produto,
            ma_tela_consig_ad,
            p_ped_item_nat.*   TO NULL

 INITIALIZE p_ped_itens_desc.* TO NULL

 CALL vdp4283_move_dados()

 LET p_tela         = 1
 LET p_flag         = 1
 LET p_count        = 0
 LET ies_incl_txt   = "N"
 LET m_ies_txt_exped = 'N'   #E# - 469670
 LET p_voltou       = 0
 LET p_erro         = "000000000"
 LET p_consist_cred = FALSE
 LET p_desc_unico_mest = 0
 LET m_desc_unico_item = 0

   WHILE TRUE
      CASE
         WHEN p_tela = 1
            IF vdp4283_entrada_dados_mestr("INCLUSAO") THEN
               LET p_tela = 2
            ELSE
               LET p_status = 1
               EXIT WHILE
            END IF

        WHEN p_tela = 2
            IF m_informa_consig_ad = "S" THEN
              IF vdp4283_abre_tela_consig_adicional() THEN
                LET p_tela = 3
              ELSE
                LET p_tela = 1
              END IF
            ELSE
              LET p_tela = 3
            END IF

        WHEN p_tela = 3
           IF vdp4283_entrada_dados_intermediario() THEN
              LET p_tela = 4
           ELSE
             IF m_informa_consig_ad = "S" THEN
                LET p_tela = 2
              ELSE
                LET p_tela = 1
              END IF
           END IF

        WHEN p_tela = 4
           IF vdp4283_entrada_dados_ent_obs("INCLUSAO") THEN
              LET p_tela = 5
           ELSE
              LET p_tela = 3
           END IF

        WHEN p_tela = 5
           IF vdp4283_entrada_dados_item("INCLUSAO") THEN
              LET p_tela = 7
           ELSE
              LET p_tela = 4
           END IF

        WHEN p_tela = 6
           IF vdp4283_entrada_dados_item_bnf() THEN
              LET p_tela = 7
           ELSE
              LET p_tela = 5
           END IF

        WHEN p_tela = 7
           IF vdp4283_total("INCLUSAO") THEN
              LET p_status = 0
              EXIT WHILE
           ELSE
              LET p_tela = 5
           END IF
      END CASE
   END WHILE

   CALL log085_transacao("BEGIN")

   IF p_status = 0 THEN
      LET p_erro[4,5] = "00"
      FOR pa_curr = 1 TO  500
        IF   t_pedido_dig_item[pa_curr].cod_item IS NOT NULL OR
             t_pedido_dig_item[pa_curr].cod_item  != "               "
        THEN CALL vdp4283_busca_desc_adic_unico(pa_curr,t_pedido_dig_item[pa_curr].pct_desc_adic)
                                                RETURNING m_desc_unico_item
             LET p_desc_tot_geral = 100 - p_desc_mest
             LET p_desc_tot_geral = 100 - (p_desc_tot_geral -
                                          (p_desc_tot_geral *
                                           m_desc_unico_item / 100))

             WHENEVER ERROR CONTINUE
             SELECT pct_desc_adic_max
               INTO m_pct_desc_adic_max
               FROM cli_info_adic
              WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
             WHENEVER ERROR STOP
             IF sqlca.sqlcode = 0 AND
                m_pct_desc_adic_max > 0 THEN
                IF p_desc_tot_geral > m_pct_desc_adic_max THEN
                   LET p_erro[4] = "1"
                END IF
             ELSE
                IF p_desc_tot_geral > p_par_vdp.pct_desc_adic THEN
                   LET p_erro[4] = "1"
                END IF
             END IF
             IF vdp4283_verifica_preco_minimo() = FALSE THEN
               LET p_erro[5] = "1"
             END IF
        END IF
      END FOR
      CALL vdp4283_efetiva_inclusao()
      CURRENT WINDOW IS w_vdp4283
      CALL log006_exibe_teclas("01 02", p_versao)
      CALL vdp4283_exibe_dados()
      IF p_erro = "000000000" THEN
         CALL log0030_mensagem(" Inclusao efetuada com sucesso ","excl")
      ELSE
         CALL log0030_mensagem(" Pedido Consistido ","excl")
      END IF
   ELSE
      LET  p_pedido_dig_mest.* = p_pedido_dig_mestr.*
      LET  p_pedido_dig_obs.*  = p_pedido_dig_obsr.*
      LET  p_pedido_dig_ent.*  = p_pedido_dig_entr.*
      LET  p_pedido_dig_mest.* = p_pedido_dig_mestr.*
      CALL vdp4283_exibe_dados()
      CURRENT WINDOW IS w_vdp4283
      CALL log006_exibe_teclas("01 02", p_versao)
      CALL log0030_mensagem(" Inclusao Cancelada ","excl")
   END IF
 END FUNCTION

#---------------------------------------------#
 FUNCTION vdp4283_entrada_dados_mestr(p_funcao)
#---------------------------------------------#
 DEFINE p_funcao                CHAR(12),
        l_den_transpor          LIKE transport.den_transpor,
        l_den_consig            LIKE transport.den_transpor,
        l_ies_list_pre_obr      LIKE par_vdp_pad.par_ies,
        l_info_cond             SMALLINT

 CALL log006_exibe_teclas("01 02 03 07", p_versao)
 CURRENT WINDOW IS w_vdp4283
 CLEAR FORM

 LET l_info_cond = FALSE

 IF p_pedido_dig_mest.ies_comissao IS NULL THEN
    LET p_pedido_dig_mest.cod_moeda        = 1
    LET p_pedido_dig_mest.ies_comissao     = "S"
    LET p_pedido_dig_mest.ies_preco        = "F"
    LET p_pedido_dig_mest.ies_frete        = 1
    LET p_pedido_dig_mest.ies_tip_entrega  = 3
    LET p_pedido_dig_mest.ies_embal_padrao = 3
 END IF

   WHENEVER ERROR CONTINUE
   SELECT MIN(cod_tip_carteira)
     INTO p_pedido_dig_mest.cod_tip_carteira
     FROM usuario_carteira
    WHERE cod_empresa = p_cod_empresa
      AND nom_usuario = p_user
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      LET p_pedido_dig_mest.cod_tip_carteira = " "
   END IF
      INPUT    p_pedido_dig_mest.cod_empresa,
               p_pedido_dig_mest.num_pedido,
               p_pedido_dig_mest.cod_tip_carteira,
               m_linha_produto,
               p_pedido_dig_mest.cod_cliente,
               p_pedido_dig_mest.cod_nat_oper,
               p_pedido_dig_mest.dat_emis_repres,
               p_pedido_dig_mest.dat_prazo_entrega,
               p_pedido_dig_mest.num_pedido_cli,
               p_pedido_dig_mest.num_pedido_repres,
               p_pedido_dig_mest.cod_repres,
               p_pedido_dig_mest.ies_comissao,
               p_pedido_dig_mest.pct_comissao,
               p_pedido_dig_mest.cod_repres_adic,
               m_pct_comissao_2,
               m_cod_repres_3,
               m_pct_comissao_3,
               p_pedido_dig_mest.num_list_preco,
               p_pedido_dig_mest.ies_preco,
               p_pedido_dig_mest.pct_desc_adic,
               p_pedido_dig_mest.pct_desc_financ,
               p_pedido_dig_mest.cod_cnd_pgto,
               p_pedido_dig_mest.cod_tip_venda,
               p_pedido_dig_mest.ies_frete,
               p_pedido_dig_mest.pct_frete,
               p_pedido_dig_mest.ies_tip_entrega,
               p_pedido_dig_mest.cod_transpor,
               p_pedido_dig_mest.cod_consig,
               p_pedido_dig_mest.ies_finalidade,
               p_vendor_pedido.pct_taxa_negoc,
               p_pedido_dig_mest.ies_embal_padrao,  #E# - 469670
               p_pedido_dig_mest.cod_moeda,
               #E# - 469670 p_pedido_dig_mest.ies_embal_padrao,
               ies_incl_txt,
               m_ies_txt_exped                      #E# - 469670
          WITHOUT DEFAULTS FROM cod_empresa,
                                num_pedido,
                                cod_tip_carteira,
                                parametro_texto,
                                cod_cliente,
                                cod_nat_oper,
                                dat_emis_repres,
                                dat_prazo_entrega,
                                num_pedido_cli,
                                num_pedido_repres,
                                cod_repres,
                                ies_comissao,
                                pct_comissao,
                                cod_repres_adic,
                                pct_comissao_2,
                                cod_repres_3,
                                pct_comissao_3,
                                num_list_preco,
                                ies_preco,
                                pct_desc_adic,
                                pct_desc_financ,
                                cod_cnd_pgto,
                                cod_tip_venda,
                                ies_frete,
                                pct_frete,
                                ies_tip_entrega,
                                cod_transpor,
                                cod_consig,
                                ies_finalidade,
                                pct_taxa_negoc,
                                ies_embal_padrao,  #E# - 469670
                                cod_moeda,
                                #E# - 469670  ies_embal_padrao,
                                ies_incl_txt,
                                ies_txt_exped      #E# - 469670

       BEFORE FIELD num_pedido
              IF   p_voltou = 1
              THEN NEXT FIELD cod_tip_carteira
              END IF
              IF   p_par_vdp.num_prx_pedido <> 0
              THEN LET p_pedido_dig_mest.num_pedido = vdp4283_busca_num_pedido()
                   DISPLAY p_pedido_dig_mest.num_pedido TO num_pedido
                   NEXT FIELD cod_tip_carteira
              END IF

       AFTER  FIELD num_pedido
              IF   vdp4283_verifica_pedido()
              THEN CALL log0030_mensagem(" PEDIDO ja' digitado ","excl")
                   NEXT FIELD num_pedido
              END IF

       BEFORE FIELD cod_nat_oper
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD cod_nat_oper
              IF vdp4283_verifica_natureza_operacao()
              THEN CALL log0030_mensagem(" Natureza da operação não cadastrada. ","excl")
                   NEXT FIELD cod_nat_oper
              ELSE IF vdp4283_verifica_fiscal_par() = FALSE
                   THEN NEXT FIELD cod_nat_oper
                   END IF
              END IF
              IF p_ies_emite_dupl_nat = "S" THEN
                 IF   vdp4283_verifica_credito_cliente() = FALSE
                 THEN LET p_erro[1] = "1"
                 ELSE LET p_erro[1] = "0"
                 END IF
              END IF
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD parametro_texto
              CALL vdp4283_apaga_zoom()

       AFTER  FIELD parametro_texto
              IF  m_linha_produto IS NULL OR
                  m_linha_produto = ' '   THEN
                  CALL log0030_mensagem(" Obrigatório informar linha de produto ","excl")
                  NEXT FIELD parametro_texto
              END IF

       AFTER  FIELD dat_emis_repres
              IF   p_pedido_dig_mest.dat_emis_repres > TODAY
              THEN CALL log0030_mensagem( "Data de emissão inválida ","excl")
                   NEXT FIELD dat_emis_repres
              END IF

       AFTER  FIELD dat_prazo_entrega
              IF   p_pedido_dig_mest.dat_prazo_entrega < TODAY
              THEN CALL log0030_mensagem( " Data entrega menor que a data corrente","excl")
                   NEXT FIELD dat_prazo_entrega
              END IF
              IF   p_pedido_dig_mest.dat_prazo_entrega IS NULL OR
                   p_pedido_dig_mest.dat_prazo_entrega = " "
              THEN CALL log0030_mensagem( " Data de entrega não pode ser Nula ","excl")
                   NEXT FIELD dat_prazo_entrega
              END IF
              IF   vdp4283_confirma_prazo_entrega() = FALSE
              THEN NEXT FIELD dat_prazo_entrega
              END IF

       BEFORE FIELD cod_cliente
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD cod_cliente
              IF vdp4283_verifica_cliente() = TRUE
                 THEN IF vdp4283_busca_repres() = FALSE
                         THEN CALL log0030_mensagem( " Cliente sem Representante","excl")
                              NEXT FIELD cod_cliente
                      END IF
              ELSE NEXT FIELD cod_cliente
              END IF
              WHENEVER ERROR CONTINUE
              SELECT par_cliente_txt[11,13]
                INTO m_lead_time
                FROM par_clientes
               WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 LET m_lead_time = 0
              END IF
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD cod_repres
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD cod_repres
              IF vdp4283_verifica_repres(p_pedido_dig_mest.cod_repres,1) = FALSE
              THEN
                 NEXT FIELD cod_repres
              ELSE
{ O.S.50780-Ju   IF vdp4283_verifica_repres_canal() = FALSE THEN
                    ERROR "Representante nao relacionado com o cliente no ",
                          "canal de vendas."
                    NEXT FIELD cod_repres
                 END IF
}             END IF
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD pct_comissao
              IF p_pedido_dig_mest.ies_comissao = "N" AND
                 FGL_LASTKEY() <> FGL_KEYVAL("UP") AND
                 FGL_LASTKEY() <> FGL_KEYVAL("LEFT") THEN
                 NEXT FIELD cod_repres_adic
              END IF

       BEFORE FIELD cod_repres_adic
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD cod_repres_adic
              IF   vdp4283_verifica_repres(p_pedido_dig_mest.cod_repres_adic,2) = FALSE
              THEN NEXT FIELD cod_repres_adic
              END IF
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD pct_comissao_2
              IF p_pedido_dig_mest.ies_comissao = "N" AND
                 FGL_LASTKEY() <> fgl_keyval("UP") AND
                 fgl_lastkey() <> fgl_keyval("LEFT") THEN
                 NEXT FIELD cod_repres_3
              END IF

              IF p_pedido_dig_mest.ies_comissao = "N" AND
                 (fgl_lastkey() = fgl_keyval("UP") OR
                  fgl_lastkey() = fgl_keyval("LEFT"))  THEN
                 NEXT FIELD ies_comissao
              END IF

      BEFORE FIELD cod_repres_3
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD cod_repres_3
              IF   vdp4283_verifica_repres(m_cod_repres_3,3) = FALSE
              THEN NEXT FIELD cod_repres_3
              END IF
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD pct_comissao_3
              IF p_pedido_dig_mest.ies_comissao = "N" AND
                 fgl_lastkey() <> fgl_keyval("UP") AND
                 fgl_lastkey() <> fgl_keyval("LEFT") THEN
                 NEXT FIELD num_list_preco
              END IF

              IF p_pedido_dig_mest.ies_comissao = "N" AND
                 (fgl_lastkey() = fgl_keyval("UP") OR
                  fgl_lastkey() = fgl_keyval("LEFT"))  THEN
                 NEXT FIELD ies_comissao
              END IF

       BEFORE FIELD num_list_preco
              CALL vdp4283_mostra_zoom()

              WHENEVER ERROR CONTINUE
              SELECT par_cliente_txt[14,17]
                INTO p_pedido_dig_mest.num_list_preco
                FROM par_clientes
               WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 LET p_pedido_dig_mest.num_list_preco = ' '
              END IF

       AFTER  FIELD num_list_preco
#              IF   p_pedido_dig_mest.num_list_preco IS NOT NULL  OR
#                   p_pedido_dig_mest.num_list_preco = 0
#             IF   p_pedido_dig_mest.num_list_preco IS NULL  OR
#                  p_pedido_dig_mest.num_list_preco = 0
#                  THEN ERROR " Lista de preco nao cadastrada. "
#                       NEXT FIELD num_list_preco
#             END IF
              IF   p_pedido_dig_mest.num_list_preco IS NULL OR
                   p_pedido_dig_mest.num_list_preco = 0
              THEN
                    WHENEVER ERROR CONTINUE
                    SELECT par_ies
                     INTO l_ies_list_pre_obr
                     FROM par_vdp_pad
                    WHERE cod_empresa   = p_cod_empresa
                      AND cod_parametro = "ies_list_pre_obr"
                   WHENEVER ERROR STOP
                   IF   sqlca.sqlcode = 0
                   THEN IF   l_ies_list_pre_obr = "S"
                        THEN CALL log0030_mensagem( "Obrigatório informar Lista de Preço","excl")
                             NEXT FIELD num_list_preco
                        END IF
                   END IF
              ELSE IF   vdp4283_verifica_lista_preco()
                   THEN CALL log0030_mensagem( " Lista de preço não cadastrada. ","excl")
                        NEXT FIELD num_list_preco
                   ELSE IF   p_pedido_dig_mest.dat_emis_repres >= p_desc_preco_mest.dat_ini_vig AND
                             p_pedido_dig_mest.dat_emis_repres <= p_desc_preco_mest.dat_fim_vig
                        THEN IF   p_desc_preco_mest.ies_bloq_pedido = "S"
                             THEN LET p_erro[2] = "1"
                             ELSE LET p_erro[2] = "0"
                             END IF
                        ELSE LET p_erro[2] = "1"
                        END IF
                   END IF
              END IF
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD ies_preco
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD ies_preco
              IF   p_pedido_dig_mest.ies_preco = "F"
              THEN DISPLAY "FIRME"       TO den_ies_preco
              ELSE DISPLAY "REAJUSTAVEL" TO den_ies_preco
              END IF
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD pct_desc_adic
              LET p_pct_desc_tot = 0

       AFTER  FIELD pct_desc_adic
              IF   p_pedido_dig_mest.pct_desc_adic IS NULL OR
                   p_pedido_dig_mest.pct_desc_adic = " "
              THEN CALL log0030_mensagem( "Desconto adicional inválido ","excl")
                   NEXT FIELD pct_desc_adic
              END IF
              CALL vdp4283_busca_desc_adic_unico(0,p_pedido_dig_mest.pct_desc_adic)
                                                 RETURNING p_desc_mest
              WHENEVER ERROR CONTINUE
              SELECT pct_desc_adic_max
                INTO m_pct_desc_adic_max
                FROM cli_info_adic
               WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 0 AND
                 m_pct_desc_adic_max > 0 THEN
                 IF p_desc_mest > m_pct_desc_adic_max
                 THEN CALL log0030_mensagem( "Descontos do Pedido Mestre maior que o limite - CLI_INFO_ADIC","excl")
                      LET p_erro[3] = "1"
                 ELSE LET p_erro[3] = "0"
                 END IF
              ELSE
                 IF   p_desc_mest > p_par_vdp.pct_desc_adic
                 THEN CALL log0030_mensagem( "Descontos do Pedido Mestre maior que o limite - PAR_VDP","excl")
                      LET p_erro[3] = "1"
                 ELSE LET p_erro[3] = "0"
                 END IF
              END IF
       AFTER  FIELD pct_desc_financ
              IF   p_pedido_dig_mest.pct_desc_financ IS NULL OR
                   p_pedido_dig_mest.pct_desc_financ = " "
              THEN CALL log0030_mensagem( "Desconto financeiro inválido ","excl")
                   NEXT FIELD pct_desc_financ
              END IF
              IF   p_pedido_dig_mest.pct_desc_financ > p_par_vdp.pct_desc_financ
              THEN CALL log0030_mensagem( "Pct. desconto financeiro maior que limite ","excl")
                   NEXT FIELD pct_desc_financ
              END IF
       BEFORE FIELD cod_cnd_pgto
              CALL vdp4283_mostra_zoom()

              IF l_info_cond = FALSE THEN
                 CALL vdp4283_busca_cli_pgto()
              END IF

       AFTER  FIELD cod_cnd_pgto
	             IF   vdp4283_verifica_cnd_pagamento()
              THEN NEXT FIELD cod_cnd_pgto
              END IF
              CALL vdp4283_apaga_zoom()

              LET l_info_cond = TRUE

       BEFORE FIELD cod_tip_venda
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD cod_tip_venda
              IF   p_pedido_dig_mest.cod_tip_venda IS NULL OR
                   p_pedido_dig_mest.cod_tip_venda = "   "
              THEN CALL log0030_mensagem( " Tipo de venda inválida ","excl")
                   NEXT FIELD cod_tip_venda
              ELSE IF   vdp4283_verifica_tipo_venda()
                   THEN CALL log0030_mensagem( " Tipo de venda não cadastrado. ","excl")
                        NEXT FIELD cod_tip_venda
                   END IF
              END IF
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD ies_tip_entrega
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD ies_tip_entrega
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD ies_frete
              CALL vdp4283_mostra_zoom()
       AFTER  FIELD ies_frete
              CASE
                 WHEN p_pedido_dig_mest.ies_frete = "1"
                      DISPLAY "CIF Pago" TO den_ies_frete
                 WHEN p_pedido_dig_mest.ies_frete = "2"
                      DISPLAY "CIF Cobrado" TO den_ies_frete
                 WHEN p_pedido_dig_mest.ies_frete = "3"
                      DISPLAY "FOB" TO den_ies_frete
                 WHEN p_pedido_dig_mest.ies_frete = "4"
                      DISPLAY "CIF Informado pct." TO den_ies_frete
                 WHEN p_pedido_dig_mest.ies_frete = "5"
                      DISPLAY "CIF Informado unit." TO den_ies_frete
              END CASE

            IF (fgl_lastkey() = FGL_KEYVAL("UP") OR
                fgl_lastkey() = fgl_keyval("LEFT"))  THEN
               NEXT FIELD cod_tip_venda
            END IF

              IF   p_pedido_dig_mest.ies_frete != "4"
              THEN LET p_pedido_dig_mest.pct_frete = 0
                   DISPLAY BY NAME p_pedido_dig_mest.pct_frete
                   NEXT FIELD ies_tip_entrega
              END IF
              CALL vdp4283_apaga_zoom()


        BEFORE FIELD pct_frete
            IF p_pedido_dig_mest.ies_frete <> "4" AND
               fgl_lastkey() <> fgl_keyval("UP") AND
               fgl_lastkey() <> fgl_keyval("LEFT") THEN
               NEXT FIELD ies_tip_entrega
            END IF

            IF p_pedido_dig_mest.ies_frete <> "4" AND
               (fgl_lastkey() = fgl_keyval("UP") OR
                fgl_lastkey() = fgl_keyval("LEFT"))  THEN
               NEXT FIELD ies_frete
            END IF


       AFTER  FIELD pct_frete
            IF   p_pedido_dig_mest.pct_frete    IS NULL OR
                 p_pedido_dig_mest.pct_frete < 0
            THEN CALL log0030_mensagem( " Percentual de frete inválido.","excl")
                 NEXT  FIELD pct_frete
            END IF

       BEFORE FIELD cod_transpor
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD cod_transpor
              LET l_den_transpor = " "
              IF   p_pedido_dig_mest.cod_transpor IS NOT NULL AND
                   p_pedido_dig_mest.cod_transpor <> " "
              THEN IF   vdp4283_verifica_transportadora(p_pedido_dig_mest.cod_transpor) = FALSE
                   THEN
                      IF p_transp_inat = 1 THEN
                         CALL log0030_mensagem( " Transportadora cancelada ou suspensa. ","excl")
                      ELSE
                         CALL log0030_mensagem( " Transportadora não cadastrada ","excl")
                      END IF
                      NEXT FIELD cod_transpor
                   ELSE
                      WHENEVER ERROR CONTINUE
                      SELECT den_transpor
                        INTO l_den_transpor
                        FROM transport
                       WHERE cod_transpor = p_pedido_dig_mest.cod_transpor
                      WHENEVER ERROR STOP
                      IF sqlca.sqlcode = NOTFOUND THEN
                         WHENEVER ERROR CONTINUE
                         SELECT nom_cliente
                           INTO l_den_transpor
                           FROM clientes
                          WHERE cod_cliente = p_pedido_dig_mest.cod_transpor
                         WHENEVER ERROR STOP
                         IF sqlca.sqlcode <> 0 THEN
                            LET l_den_transpor = " "
                         END IF
                      END IF
                   END IF
              END IF
              DISPLAY l_den_transpor TO den_transpor
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD cod_consig
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD cod_consig
              LET l_den_consig = " "
              IF   p_pedido_dig_mest.cod_consig IS NOT NULL AND
                   p_pedido_dig_mest.cod_consig <> " "  THEN
                 IF m_frete_gtc = 'S' AND m_frt_praca_consig = 'S' THEN
                    #Ch.945648
                    IF m_informa_consig_ad = "S" THEN
                       CALL log0030_mensagem ("Consignatário deverá ser informado na tela de consignatários adicionais para calcular o frete consig (TMS).","exclamation")
                    ELSE
                       CALL log0030_mensagem ("Consignatário deverá ser informado na tela de consignatários adicionais para calcular o frete consig (TMS). Favor marcar o parâmetro 'Permitir a informação de mais de um consignatário no processo Vendas?' (LOG2240).","exclamation")
                    END IF
                    NEXT FIELD cod_consig
                 ELSE

                   IF   vdp4283_verifica_transportadora(p_pedido_dig_mest.cod_consig) = FALSE  THEN
                      IF p_transp_inat = 1 THEN
                         CALL log0030_mensagem( " Consignatário cancelado ou suspenso. ","excl")
                      ELSE
                         CALL log0030_mensagem( " Consignatário não cadastrado ","excl")
                      END IF
                      NEXT FIELD cod_consig
                   ELSE
                      WHENEVER ERROR CONTINUE
                      SELECT den_transpor
                        INTO l_den_consig
                        FROM transport
                       WHERE cod_transpor = p_pedido_dig_mest.cod_consig
                      WHENEVER ERROR STOP
                      IF sqlca.sqlcode = NOTFOUND THEN
                         WHENEVER ERROR CONTINUE
                         SELECT nom_cliente
                           INTO l_den_consig
                           FROM clientes
                          WHERE cod_cliente = p_pedido_dig_mest.cod_consig
                         WHENEVER ERROR STOP
                         IF sqlca.sqlcode <> 0 THEN
                            LET l_den_consig = " "
                         END IF
                      END IF
                   END IF
                END IF
              END IF
              DISPLAY l_den_consig TO den_consig
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD ies_finalidade
              CALL vdp4283_mostra_zoom()
       AFTER  FIELD ies_finalidade
              IF vdp4283_verifica_finalidade() = FALSE
              THEN NEXT FIELD ies_finalidade
              END IF
              CALL vdp4283_apaga_zoom()

       AFTER FIELD pct_taxa_negoc
             IF p_vendor_pedido.pct_taxa_negoc IS NULL OR
                p_vendor_pedido.pct_taxa_negoc = " "   OR
                p_vendor_pedido.pct_taxa_negoc < 0     THEN
                LET p_vendor_pedido.pct_taxa_negoc = 0
                DISPLAY p_vendor_pedido.pct_taxa_negoc TO pct_taxa_negoc
             END IF

       BEFORE FIELD cod_moeda
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD cod_moeda
              IF   vdp4283_verifica_moeda() = FALSE
              THEN CALL log0030_mensagem( "Moeda não cadastrada ","excl")
                   NEXT FIELD cod_moeda
              END IF
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD ies_embal_padrao
              CALL vdp4283_mostra_zoom()
       AFTER  FIELD ies_embal_padrao
              CALL vdp4283_apaga_zoom()

       BEFORE FIELD cod_tip_carteira
              CALL vdp4283_mostra_zoom()

       AFTER  FIELD cod_tip_carteira
              IF   vdp4283_verifica_carteira() = FALSE
              THEN CALL log0030_mensagem( "Carteira não cadastrada ","excl")
                   NEXT FIELD cod_tip_carteira
              END IF
              CALL vdp4283_apaga_zoom()

       AFTER  FIELD ies_incl_txt
              IF   ies_incl_txt IS NOT NULL
              THEN IF   ies_incl_txt = "S"
                   THEN IF   vdp243_digita_texto(p_pedido_dig_mest.num_pedido, "0") = FALSE
                        THEN LET ies_incl_txt = "N"
                        END IF
                        CALL log006_exibe_teclas("01 02 07", p_versao)
                        CURRENT WINDOW IS w_vdp4283
                   END IF
              END IF

       AFTER  FIELD ies_txt_exped
              IF  m_ies_txt_exped IS NOT NULL THEN
                  IF  m_ies_txt_exped = "S" THEN
                      IF  NOT vdpy154_digita_texto_exped(p_pedido_dig_mest.num_pedido,'CONSULTA') THEN
                          LET m_ies_txt_exped = "N"
                          DISPLAY m_ies_txt_exped TO ies_txt_exped
                      END IF
                      CALL log006_exibe_teclas("01 02 07", p_versao)
                      CURRENT WINDOW IS w_vdp4283
                  END IF
              END IF


       ON KEY (control-w, f1)
          #lds IF NOT LOG_logix_versao5() THEN
          #lds CONTINUE INPUT
          #lds END IF
              CALL vdp4283_help(1)

       ON KEY (control-z, f4)
              CALL vdp4283_popup(1)
 END INPUT

   LET p_voltou = 1
   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION


#-------------------------------#
 FUNCTION vdp4283_mostra_zoom()
#-------------------------------#
  IF g_ies_grafico THEN
--# CALL fgl_dialog_setkeylabel("control-z","Zoom")
  ELSE
    DISPLAY "( Zoom )" AT 3,68
  END IF
 END FUNCTION

#------------------------------#
 FUNCTION vdp4283_apaga_zoom()
#------------------------------#
  IF g_ies_grafico THEN
--# CALL fgl_dialog_setkeylabel("control-z",NULL)
  ELSE
    DISPLAY "--------" AT 3,68
  END IF
 END FUNCTION

#------------------------------------------#
 FUNCTION vdp4283_confirma_prazo_entrega()
#------------------------------------------#
  IF   p_pedido_dig_mest.dat_prazo_entrega > (TODAY + 30)
  THEN #ERROR " Prazo de entrega e' superior a 30 dias "
       RETURN log0040_confirm(17,40," Prazo de entrega é superior a 30 dias, confirma processo? ")
  END IF
  RETURN TRUE
END FUNCTION


#--------------------------------------------#
FUNCTION vdp4283_entrada_dados_intermediario()
#--------------------------------------------#

   CALL log130_procura_caminho("vdp42838") RETURNING p_nom_tela
   OPEN WINDOW w_vdp42838 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_vdp42838
   DISPLAY p_cod_empresa                 TO cod_empresa
   DISPLAY p_pedido_dig_mest.num_pedido  TO num_pedido

   INPUT p_ped_item_nat.cod_cliente,
         p_ped_item_nat.cod_nat_oper,
         p_ped_item_nat.cod_cnd_pgto,
         p_pedido_dig_mest.cod_local_estoq WITHOUT DEFAULTS
    FROM cod_cliente,
         cod_nat_oper,
         cod_cnd_pgto,
         cod_local_estoq

      BEFORE FIELD cod_cliente
         CALL vdp4283_mostra_zoom()
      AFTER  FIELD cod_cliente
         IF p_ped_item_nat.cod_cliente IS NOT NULL THEN
            IF vdp4283_verifica_cliente_inter() THEN
            ELSE
               NEXT FIELD cod_cliente
            END IF
         ELSE
            NEXT FIELD cod_local_estoq
         END IF
         CALL vdp4283_apaga_zoom()

      BEFORE FIELD cod_nat_oper
         CALL vdp4283_mostra_zoom()

      AFTER  FIELD cod_nat_oper
         IF vdp4283_verifica_nat_oper_inter() THEN
         ELSE
            CALL log0030_mensagem( "Operação não cadastrada ou emite duplicata","excl")
            NEXT FIELD cod_nat_oper
         END IF
         CALL vdp4283_apaga_zoom()

      BEFORE FIELD cod_cnd_pgto
         CALL vdp4283_mostra_zoom()

      AFTER  FIELD cod_cnd_pgto
         IF vdp4283_verifica_cnd_pgto_inter() THEN
         ELSE
            CALL log0030_mensagem( "Condição de Pgto não cadastrada ou emite duplicata","excl")
            NEXT FIELD cod_cnd_pgto
         END IF
         CALL vdp4283_apaga_zoom()

      BEFORE FIELD cod_local_estoq
         CALL vdp4283_mostra_zoom()

      AFTER  FIELD cod_local_estoq
         IF p_pedido_dig_mest.cod_local_estoq IS NULL THEN
         ELSE
            IF vdp4283_verifica_local_estoq() THEN
            ELSE
               CALL log0030_mensagem( "Local de Estoque não cadastrado","excl")
               NEXT FIELD cod_local_estoq
            END IF
         END IF
         CALL vdp4283_apaga_zoom()

      ON KEY (control-w, f1)
         #lds IF NOT LOG_logix_versao5() THEN
         #lds CONTINUE INPUT
         #lds END IF
         CALL vdp4283_help(2)

      ON KEY (control-z, f4)
         CALL vdp4283_popup_intermediario()
   END INPUT

   CLOSE WINDOW w_vdp42838
   CURRENT WINDOW IS w_vdp4283

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------------------#
 FUNCTION vdp4283_verifica_cliente_inter()
#-----------------------------------------#
  DEFINE p_ies_situacao    LIKE clientes.ies_situacao,
         p_nom_cliente     LIKE clientes.nom_cliente

  WHENEVER ERROR CONTINUE
  SELECT nom_cliente,
         ies_situacao
    INTO p_nom_cliente,
         p_ies_situacao
    FROM clientes
   WHERE cod_cliente = p_ped_item_nat.cod_cliente
  WHENEVER ERROR STOP
  IF   sqlca.sqlcode = NOTFOUND
  THEN CALL log0030_mensagem( " Cliente não cadastrado ","excl")
       RETURN FALSE
  END IF

  DISPLAY p_nom_cliente   TO nom_cliente

  IF   p_ies_situacao = "A"
  THEN RETURN TRUE
  ELSE CALL log0030_mensagem( "Cliente cancelado ou suspenso","excl")
       RETURN FALSE
  END IF
END FUNCTION

#------------------------------------------#
 FUNCTION vdp4283_verifica_nat_oper_inter()
#------------------------------------------#
  DEFINE p_den_nat_oper LIKE nat_operacao.den_nat_oper

  WHENEVER ERROR CONTINUE
  SELECT nat_operacao.den_nat_oper
    INTO p_den_nat_oper
    FROM nat_operacao
   WHERE nat_operacao.cod_nat_oper   = p_ped_item_nat.cod_nat_oper
     AND nat_operacao.ies_emite_dupl = "N"
  WHENEVER ERROR STOP
  DISPLAY p_den_nat_oper TO den_nat_oper

  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#------------------------------------------#
 FUNCTION vdp4283_verifica_cnd_pgto_inter()
#------------------------------------------#
  DEFINE p_den_cnd_pgto    LIKE cond_pgto.den_cnd_pgto

  WHENEVER ERROR CONTINUE
  SELECT den_cnd_pgto
    INTO p_den_cnd_pgto
    FROM cond_pgto
   WHERE cond_pgto.cod_cnd_pgto   = p_ped_item_nat.cod_cnd_pgto
     AND cond_pgto.ies_emite_dupl = "N"
  WHENEVER ERROR STOP
  DISPLAY p_den_cnd_pgto TO den_cnd_pgto

  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION


#-------------------------------------#
FUNCTION vdp4283_verifica_local_estoq()
#-------------------------------------#
   WHENEVER ERROR CONTINUE
   SELECT cod_local
     FROM local
    WHERE local.cod_empresa = p_cod_empresa
      AND local.cod_local   = p_pedido_dig_mest.cod_local_estoq
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF
END FUNCTION


#-------------------------------------------------#
 FUNCTION vdp4283_entrada_dados_ent_obs(p_funcao)
#-------------------------------------------------#
 DEFINE p_funcao                CHAR(12)

 WHENEVER ERROR CONTINUE
 CALL log130_procura_caminho("vdp42831") RETURNING p_nom_tela
 OPEN WINDOW w_vdp42831 AT 2,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 WHENEVER ERROR STOP

 CALL log006_exibe_teclas("01 02 03 07", p_versao)
 CURRENT WINDOW IS w_vdp42831

 DISPLAY p_cod_empresa TO cod_empresa
 DISPLAY p_pedido_dig_mest.num_pedido  TO num_pedido

 LET p_pedido_dig_ent.num_pedido  =  p_pedido_dig_mest.num_pedido
 LET p_pedido_dig_obs.num_pedido  =  p_pedido_dig_mest.num_pedido

 INPUT p_num_sequencia,
       p_pedido_dig_ent.end_entrega,
       p_pedido_dig_ent.den_bairro,
       p_pedido_dig_ent.cod_cidade,
       p_pedido_dig_ent.cod_cep,
       p_pedido_dig_ent.num_cgc,
       p_pedido_dig_ent.ins_estadual,
       p_pedido_dig_obs.tex_observ_1,
       p_pedido_dig_obs.tex_observ_2 WITHOUT DEFAULTS
  FROM num_sequencia,
       end_entrega,
       den_bairro,
       cod_cidade,
       cod_cep,
       num_cgc,
       ins_estadual,
       tex_observ_1,
       tex_observ_2

    BEFORE FIELD num_sequencia
           CALL vdp4283_mostra_zoom()

    AFTER  FIELD num_sequencia
	          IF   p_num_sequencia IS NULL
	          THEN
	          ELSE IF   vdp4283_verifica_endeco_entrega()
	               THEN NEXT FIELD tex_observ_1
	               ELSE CALL log0030_mensagem( " Endereço de entrega não cadastrado","excl")
		                   NEXT FIELD num_sequencia
	               END IF
	          END IF
           CALL vdp4283_apaga_zoom()

    AFTER  FIELD den_bairro
           IF   p_pedido_dig_ent.end_entrega IS NULL
           THEN NEXT FIELD tex_observ_1
           END IF

    AFTER  FIELD cod_cep
           IF   p_pedido_dig_ent.cod_cep = "     -   " OR
                p_pedido_dig_ent.cod_cep = "00000-000"
           THEN INITIALIZE p_pedido_dig_ent.cod_cep TO NULL
           END IF

    BEFORE FIELD cod_cidade
           CALL vdp4283_mostra_zoom()

    AFTER  FIELD cod_cidade
           IF   vdp4283_verifica_cidade()
           THEN CALL log0030_mensagem( " Cidade não cadastrado. ","excl")
                NEXT FIELD cod_cidade
           END IF
           CALL vdp4283_apaga_zoom()

    AFTER  FIELD num_cgc
           IF   p_pedido_dig_ent.num_cgc = "   .   .   /    -  " OR
                p_pedido_dig_ent.num_cgc = "000.000.000/0000-00"
           THEN INITIALIZE p_pedido_dig_ent.num_cgc TO NULL
           ELSE IF   log019_verifica_cgc_cpf(p_pedido_dig_ent.num_cgc)
                THEN
                ELSE CALL log0030_mensagem( " C.G.C OU C.P.F inválido","excl")
                     NEXT FIELD num_cgc
                END IF
           END IF

    BEFORE  FIELD tex_observ_1
       CALL vdp4283_apaga_zoom()

    ON KEY (control-w, f1)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
           CALL vdp4283_help(1)

    ON KEY (control-z, f4)
           CALL vdp4283_popup(1)
  END INPUT

   CLOSE WINDOW w_vdp42831
   CURRENT WINDOW IS w_vdp4283

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION


#--------------------------------------#
 FUNCTION vdp4283_verifica_lista_preco()
#--------------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT * INTO p_desc_preco_mest.*
    FROM desc_preco_mest
   WHERE desc_preco_mest.cod_empresa    = p_cod_empresa
     AND desc_preco_mest.num_list_preco = p_pedido_dig_mest.num_list_preco
  WHENEVER ERROR STOP
  IF   sqlca.sqlcode = NOTFOUND OR
       p_pedido_dig_mest.num_list_preco = " "
  THEN
      RETURN TRUE
  ELSE
      RETURN FALSE
  END IF

END FUNCTION

#---------------------------------------------------------#
 FUNCTION vdp4283_verifica_transportadora(p_cod_transpor)
#---------------------------------------------------------#
 DEFINE p_cod_transpor    LIKE pedido_dig_mest.cod_transpor
 DEFINE lr_clientes       RECORD LIKE clientes.*

 LET p_transp_inat = 0
 WHENEVER ERROR CONTINUE
 SELECT *  FROM transport
  WHERE cod_transpor  = p_cod_transpor
 WHENEVER ERROR STOP
 IF   sqlca.sqlcode = NOTFOUND
 THEN
     WHENEVER ERROR CONTINUE
     SELECT *  INTO lr_clientes.*
       FROM clientes
      WHERE cod_cliente  = p_cod_transpor
     WHENEVER ERROR STOP
     IF lr_clientes.ies_situacao <> "A" THEN
         LET p_transp_inat = 1
         RETURN FALSE
     ELSE
         IF SQLCA.sqlcode = 0 THEN
             RETURN TRUE
         ELSE
             RETURN FALSE
         END IF
     END IF
 ELSE
    RETURN TRUE
 END IF

 END FUNCTION

#------------------------------#
 FUNCTION vdp4283_cond_cliente()
#------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT * FROM cli_cond_pgto
   WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
  WHENEVER ERROR STOP
  IF   sqlca.sqlcode = NOTFOUND
  THEN
     RETURN TRUE
  ELSE
       WHENEVER ERROR CONTINUE
       SELECT * FROM cli_cond_pgto
       WHERE cod_cliente  = p_pedido_dig_mest.cod_cliente
         AND cod_cnd_pgto = p_pedido_dig_mest.cod_cnd_pgto
       WHENEVER ERROR STOP
      IF   sqlca.sqlcode = NOTFOUND
      THEN
          RETURN FALSE
      ELSE
          RETURN TRUE
      END IF
  END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION vdp4283_verifica_endeco_entrega()
#-----------------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT cli_end_ent.end_entrega,
         cli_end_ent.den_bairro,
         cli_end_ent.cod_cidade,
         cli_end_ent.cod_cep,
         cli_end_ent.num_cgc,
         cli_end_ent.ins_estadual
    INTO p_pedido_dig_ent.end_entrega,
         p_pedido_dig_ent.den_bairro,
         p_pedido_dig_ent.cod_cidade,
         p_pedido_dig_ent.cod_cep,
         p_pedido_dig_ent.num_cgc,
         p_pedido_dig_ent.ins_estadual
    FROM cli_end_ent
   WHERE cli_end_ent.cod_cliente   = p_pedido_dig_mest.cod_cliente
     AND cli_end_ent.num_sequencia = p_num_sequencia
  WHENEVER ERROR STOP

  IF   sqlca.sqlcode = 0 THEN
       LET p_pedido_dig_ent.num_sequencia = p_num_sequencia
       DISPLAY BY NAME p_pedido_dig_ent.*
       RETURN TRUE
  ELSE
       RETURN FALSE
  END IF

END FUNCTION


#-------------------------------------------#
FUNCTION vdp4283_entrada_dados_item(p_funcao)
#-------------------------------------------#
   DEFINE p_funcao          CHAR(12),
          p_qtd_c_decim     DECIMAL(15,5),
          p_qtd_resto       DECIMAL(15,5),
          p_qtd_s_decim     INTEGER,
          p_desc_adic_m_i   DECIMAL(5,2),
          p_qtd_padr_embal  LIKE item_embalagem.qtd_padr_embal,
          p_pct_desc_m      LIKE ped_itens.pct_desc_adic,
          p_pct_desc_i      LIKE ped_itens.pct_desc_adic,
          p_campo           SMALLINT,
          l_ind             SMALLINT

   DEFINE p_achou           SMALLINT ,
          p_pct_comissao    LIKE comissao_par.pct_comissao


   WHENEVER ERROR CONTINUE
   CALL log130_procura_caminho("vdp42832") RETURNING p_nom_tela
   OPEN WINDOW w_vdp42832 AT 2,02 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   WHENEVER ERROR STOP

   CALL log006_exibe_teclas("01 02 03 05 06 07", p_versao)
   CURRENT WINDOW IS w_vdp42832

   DISPLAY p_cod_empresa                 TO cod_empresa
   DISPLAY p_pedido_dig_mest.num_pedido  TO num_pedido

   LET p_pedido_dig_item.num_pedido  =  p_pedido_dig_mest.num_pedido
   LET p_valor_pedido  = 0
   LET pa_curr         = 1

   LET t_pedido_dig_item[pa_curr].prz_entrega =
       p_pedido_dig_mest.dat_prazo_entrega

   INPUT ARRAY t_pedido_dig_item WITHOUT DEFAULTS
    FROM s_pedido_dig_item.*

      BEFORE ROW
         LET pa_curr  = arr_curr()
         LET sc_curr  = scr_line()
         LET pa_count = arr_count()

      BEFORE FIELD cod_item
         CALL vdp4283_mostra_zoom()

         IF t_pedido_dig_item[pa_curr].cod_item IS NOT NULL AND
            t_pedido_dig_item[pa_curr].cod_item <> " " THEN
            CALL vdp4283_mostra_estoque(t_pedido_dig_item[pa_curr].cod_item)
         END IF

      AFTER FIELD cod_item
         IF t_pedido_dig_item[pa_curr].cod_item IS  NULL
         THEN IF   fgl_lastkey() = fgl_keyval("UP") OR
                   fgl_lastkey() = fgl_keyval("LEFT") OR
                   fgl_lastkey() = fgl_keyval("DOWN")
              THEN CONTINUE INPUT
              ELSE EXIT INPUT
              END IF
         ELSE
         IF NOT p_ies_item_ped = "S" THEN
            FOR l_ind = 1 TO 500
               IF l_ind <> pa_curr THEN
                  IF t_pedido_dig_item[l_ind].cod_item  = t_pedido_dig_item[pa_curr].cod_item  THEN
                     CALL log0030_mensagem( " Item já informado. ","excl")
                     NEXT FIELD cod_item
                  END IF
               END IF
            END FOR
         END IF

         CALL vdp4283_verifica_item()
              RETURNING p_status, p_qtd_padr_embal
         IF p_status = 0 THEN
            NEXT FIELD cod_item
         END IF
         END IF
         CALL vdp4283_apaga_zoom()

         IF p_pedido_dig_mest.ies_comissao = "S" AND
            p_pedido_dig_mest.pct_comissao = 0   THEN
            CALL vdp088_consiste_perc_comissao(p_cod_empresa,
                                           p_pedido_dig_mest.cod_repres,
                                           p_pedido_dig_mest.cod_cliente,
                                           p_pedido_dig_mest.cod_cnd_pgto   ,
                                           t_pedido_dig_item[pa_curr].cod_item,
                                           " " ,
                                           " " ,
                                           " "   ,
                                           " "   ,
                                           " " )
                 RETURNING p_achou,p_pct_comissao
            IF p_achou = FALSE THEN
               CALL log0030_mensagem( " Percentual de comissão não encontrado.","excl")
               NEXT FIELD cod_item
            END IF
         END IF

         INITIALIZE p_sum_qtd_grade TO NULL
         IF vdp4283_verifica_grade() THEN
         ELSE
            NEXT FIELD cod_item
         END IF

      BEFORE FIELD  qtd_pecas_solic
         IF t_pedido_dig_item[pa_curr].qtd_pecas_solic IS NULL THEN
            LET t_pedido_dig_item[pa_curr].qtd_pecas_solic = 0
            DISPLAY t_pedido_dig_item[pa_curr].qtd_pecas_solic TO
                    s_pedido_dig_item[sc_curr].qtd_pecas_solic
         END IF

      AFTER FIELD  qtd_pecas_solic
         LET pa_curr = arr_curr()
         IF t_pedido_dig_item[pa_curr].qtd_pecas_solic IS NULL  OR
            t_pedido_dig_item[pa_curr].qtd_pecas_solic <= 0     THEN
            CALL log0030_mensagem( " Qtd. deve ser maior que zero ","excl")
            NEXT FIELD qtd_pecas_solic
         ELSE
            IF p_pedido_dig_mest.ies_embal_padrao = "1" OR
               p_pedido_dig_mest.ies_embal_padrao = "2" THEN
               LET p_qtd_c_decim = t_pedido_dig_item[pa_curr].qtd_pecas_solic /
                                   p_qtd_padr_embal
               LET p_qtd_s_decim = t_pedido_dig_item[pa_curr].qtd_pecas_solic /
                                   p_qtd_padr_embal
               LET p_qtd_resto    = p_qtd_c_decim - p_qtd_s_decim
               IF p_qtd_resto = 0 THEN
                  IF t_pedido_dig_item[pa_curr].qtd_pecas_solic <
                     p_qtd_padr_embal                               THEN
                     CALL log0030_mensagem( "Qtd  solic. menor que Qtd padrao embal.","excl")
                     NEXT FIELD qtd_pecas_solic
                  END IF
               ELSE
                  CALL log0030_mensagem( "Pedido padrão embal. qtd. pecas não padrao embal.","excl")
                  NEXT FIELD qtd_pecas_solic
               END IF
            END IF
         END IF
         IF p_ies_tip_controle = "2" THEN
            IF vdp4283_entrada_ped_itens_rem() = FALSE THEN
               CALL log0030_mensagem( "Informe as informações da REMESSA corretamente","excl")
               NEXT FIELD qtd_pecas_solic
            END IF
         END IF

         IF p_sum_qtd_grade <> t_pedido_dig_item[pa_curr].qtd_pecas_solic THEN
            CALL log0030_mensagem( "Quantidade do item difere da soma digitada na grade ","excl")
            NEXT FIELD qtd_pecas_solic
         END IF

      BEFORE FIELD pre_unit
         IF t_pedido_dig_item[pa_curr].pre_unit IS NULL THEN
            LET t_pedido_dig_item[pa_curr].pre_unit = 0
            DISPLAY t_pedido_dig_item[pa_curr].pre_unit TO
                    s_pedido_dig_item[sc_curr].pre_unit
         END IF
      AFTER FIELD pre_unit
         IF t_pedido_dig_item[pa_curr].pre_unit IS NULL OR
            t_pedido_dig_item[pa_curr].pre_unit = 0     THEN
            CALL log0030_mensagem( "Preço unitário inválido ","excl")
            NEXT FIELD pre_unit
         END IF
         CALL vdp4283_busca_qtd_decimais()

      BEFORE FIELD pct_desc_adic
         IF t_pedido_dig_item[pa_curr].pct_desc_adic IS NULL THEN
            LET t_pedido_dig_item[pa_curr].pct_desc_adic = 0
            DISPLAY t_pedido_dig_item[pa_curr].pct_desc_adic TO
                    s_pedido_dig_item[sc_curr].pct_desc_adic
         END IF
         CALL vdp4283_mostra_zoom()

      AFTER  FIELD pct_desc_adic
          CALL vdp4283_apaga_zoom()
          LET pa_curr = arr_curr()
         IF t_pedido_dig_item[pa_curr].pct_desc_adic IS NULL THEN
            CALL log0030_mensagem( " Percentual de desconto inválido ","excl")
            NEXT FIELD pct_desc_adic
         ELSE
            CALL vdp4283_busca_desc_adic_unico(pa_curr,t_pedido_dig_item[pa_curr].pct_desc_adic)
                                                 RETURNING m_desc_unico_item
            LET p_desc_tot_geral = 100 - p_desc_mest
            LET p_desc_tot_geral = 100 - (p_desc_tot_geral -
                                         (p_desc_tot_geral *
                                          m_desc_unico_item / 100))
            WHENEVER ERROR CONTINUE
            SELECT pct_desc_adic_max
              INTO m_pct_desc_adic_max
              FROM cli_info_adic
             WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
            WHENEVER ERROR STOP
            IF sqlca.sqlcode = 0 AND
               m_pct_desc_adic_max > 0 THEN
               IF p_desc_tot_geral > m_pct_desc_adic_max
               THEN CALL log0030_mensagem( "Desc.Adic. Mestre + Desc. Adic. Item maior que o limite - CLI_INFO_ADIC","excl")
                    LET p_erro[4] = "1"
               ELSE LET p_erro[4] = "0"
               END IF
            ELSE
               IF p_desc_tot_geral > p_par_vdp.pct_desc_adic THEN
                  CALL log0030_mensagem( "Desc. Adic. Mestre + Desc. Adic. Item maior que o limite - PAR_VDP","excl")
                  LET p_erro[4] = "1"
               ELSE LET p_erro[4] = "0"
               END IF
            END IF
         END IF
         CALL vdp4283_verifica_valor_pedido()
         IF vdp4283_verifica_preco_minimo() = FALSE THEN
            LET p_erro[5] = "1"
         ELSE LET p_erro[5] = "0"
         END IF

        #   PREVISAO - PRODUCAO - INICIO    #
        IF p_par_vdp.par_vdp_txt[14,14] = "S" THEN
           IF vdp4283_verifica_prevprod() = FALSE THEN
              NEXT FIELD qtd_pecas_solic
           END IF
        END IF

        #  PREVISAO - PRODUCAO - FIM   #

     BEFORE FIELD prz_entrega
        IF p_funcao = "INCLUSAO" AND
           t_pedido_dig_item[pa_curr].prz_entrega IS NULL THEN
           LET t_pedido_dig_item[pa_curr].prz_entrega =
               p_pedido_dig_mest.dat_prazo_entrega
        END IF
        LET p_campo = TRUE
     AFTER  FIELD prz_entrega
        IF t_pedido_dig_item[pa_curr].prz_entrega < TODAY THEN
           CALL log0030_mensagem( " DATA menor que a data corrente","excl")
           NEXT FIELD prz_entrega
        END IF
        #   PREVISAO - PRODUCAO - INICIO   #
        IF p_par_vdp.par_vdp_txt[14,14] = "S" THEN
           IF vdp4283_verifica_prevprod() = FALSE THEN
              NEXT FIELD qtd_pecas_solic
           END IF
        END IF
        IF m_lead_time > 0 THEN
           IF t_pedido_dig_item[pa_curr].prz_entrega - m_lead_time < TODAY THEN
              LET m_msg = " Prazo de Entrega menos Lead Time(", m_lead_time USING "<<<"," dias) ",
                    "menor que a data corrente "
              CALL log0030_mensagem( m_msg, "excl")
              NEXT FIELD prz_entrega
           ELSE
              LET t_pedido_dig_item[pa_curr].prz_entrega =
                  t_pedido_dig_item[pa_curr].prz_entrega - m_lead_time
                  DISPLAY t_pedido_dig_item[pa_curr].prz_entrega TO prz_entrega
           END IF
        END IF
        IF p_pedido_dig_mest.ies_tip_entrega = 1 THEN
           FOR l_ind = 1 TO (pa_curr - 1)
              IF t_pedido_dig_item[l_ind].prz_entrega <> t_pedido_dig_item[pa_curr].prz_entrega THEN
                 CALL log0030_mensagem( " Pedido entrega total não pode ter prazos de entrega diferentes ","excl")
                 NEXT FIELD prz_entrega
              END IF
           END FOR
        END IF

     BEFORE FIELD ies_incl_txt
        LET t_pedido_dig_item[pa_curr].ies_incl_txt = "N"
        DISPLAY t_pedido_dig_item[pa_curr].ies_incl_txt TO
                s_pedido_dig_item[sc_curr].ies_incl_txt
     AFTER FIELD ies_incl_txt
         IF t_pedido_dig_item[pa_curr].ies_incl_txt IS NOT NULL THEN
            IF t_pedido_dig_item[pa_curr].ies_incl_txt = "S" THEN
               IF vdp243_digita_texto(p_pedido_dig_item.num_pedido,
                  pa_curr) = FALSE                                   THEN
                  LET t_pedido_dig_item[pa_curr].ies_incl_txt = "N"
                  SLEEP 3
               END IF
            END IF
         END IF

     BEFORE FIELD val_frete_unit
        IF p_pedido_dig_mest.ies_frete = "5" THEN
        ELSE
           LET t_pedido_dig_item[pa_curr].val_frete_unit = 0
           DISPLAY t_pedido_dig_item[pa_curr].val_frete_unit
                TO s_pedido_dig_item[sc_curr].val_frete_unit

           IF (fgl_lastkey() = FGL_KEYVAL("UP") OR
               fgl_lastkey() = fgl_keyval("LEFT"))  THEN
              NEXT FIELD ies_incl_txt
           END IF
           IF (fgl_lastkey() <> FGL_KEYVAL("UP") AND
               fgl_lastkey() <> fgl_keyval("LEFT"))  THEN
              NEXT FIELD val_seguro_unit
           END IF
        END IF

     AFTER  FIELD val_frete_unit
        IF t_pedido_dig_item[pa_curr].val_frete_unit IS NULL OR
           t_pedido_dig_item[pa_curr].val_frete_unit < 0 THEN
           CALL log0030_mensagem( "Valor de Frete Unitário inválido.","excl")
           NEXT FIELD val_frete_unit
        END IF

     BEFORE FIELD val_seguro_unit
        IF p_pedido_dig_mest.ies_frete = "5" THEN
        ELSE
           LET t_pedido_dig_item[pa_curr].val_seguro_unit = 0
           DISPLAY t_pedido_dig_item[pa_curr].val_seguro_unit
                TO s_pedido_dig_item[sc_curr].val_seguro_unit

           IF (fgl_lastkey() = FGL_KEYVAL("UP") OR
               fgl_lastkey() = fgl_keyval("LEFT"))  THEN
              NEXT FIELD val_frete_unit
           END IF
           IF (fgl_lastkey() <> FGL_KEYVAL("UP") AND
               fgl_lastkey() <> fgl_keyval("LEFT"))  THEN
              NEXT FIELD parametro_dat
           END IF
        END IF

     AFTER  FIELD val_seguro_unit
        IF t_pedido_dig_item[pa_curr].val_seguro_unit IS NULL OR
           t_pedido_dig_item[pa_curr].val_seguro_unit < 0 THEN
           CALL log0030_mensagem( "Valor de Seguro Unitário inválido.","excl")
           NEXT FIELD val_seguro_unit
        END IF

     BEFORE FIELD parametro_dat
        IF t_pedido_dig_item[pa_curr].parametro_dat IS NULL THEN
           LET t_pedido_dig_item[pa_curr].parametro_dat = t_pedido_dig_item[pa_curr].prz_entrega
        END IF

     AFTER FIELD parametro_dat
        IF t_pedido_dig_item[pa_curr].parametro_dat < TODAY THEN
           CALL log0030_mensagem( " DATA menor que a data corrente","excl")
           NEXT FIELD parametro_dat
        END IF

        CALL log006_exibe_teclas("01 02 05 06 07", p_versao)
        CURRENT WINDOW IS w_vdp42832

#      AFTER ROW
#
#           IF INT_FLAG = 0 AND
#              t_pedido_dig_item[pa_curr].cod_item IS NOT NULL THEN
#              CALL vdp4283_verifica_item()
#                   RETURNING p_status, p_qtd_padr_embal
#              IF p_status = 0 THEN
#                 NEXT FIELD cod_item
#              END IF
#           END IF

      BEFORE DELETE
         LET pa_curr = arr_curr()
         IF pa_curr > 0 THEN
            # Zera tambem o ARRAY da grade
            FOR p_for = 1 TO 500
               IF t_pedido_dig_grad[p_for].num_sequencia = pa_curr THEN
                  INITIALIZE t_pedido_dig_grad[p_for].* TO NULL
               END IF
               IF t_pedido_dig_grad[p_for].num_sequencia > pa_curr THEN
                  LET t_pedido_dig_grad[p_for].num_sequencia =
                      t_pedido_dig_grad[p_for].num_sequencia - 1
               END IF
            END FOR
         END IF
      AFTER DELETE
         IF pa_count > 0        AND
            pa_count >= pa_curr THEN
            INITIALIZE t_pedido_dig_item[pa_count].* TO NULL
         END IF

     AFTER INPUT
        IF NOT int_flag THEN

           IF p_pedido_dig_mest.ies_tip_entrega = 1 THEN
              FOR l_ind = 2 TO 500
                 IF t_pedido_dig_item[l_ind].prz_entrega IS NULL THEN
                    EXIT FOR
                 END IF

                 IF t_pedido_dig_item[l_ind].prz_entrega <> t_pedido_dig_item[l_ind - 1].prz_entrega THEN
                    CALL log0030_mensagem( " Pedido entrega total não pode ter prazos de entrega diferentes ","excl")
                    NEXT FIELD prz_entrega
                 END IF
              END FOR
           END IF

           IF t_pedido_dig_item[pa_curr].parametro_dat IS NULL THEN
              LET t_pedido_dig_item[pa_curr].parametro_dat = t_pedido_dig_item[pa_curr].prz_entrega
           END IF
           IF t_pedido_dig_item[pa_curr].cod_item IS NOT NULL THEN
              CALL vdp4283_verifica_item()
                   RETURNING p_status, p_qtd_padr_embal
              IF p_status = 0 THEN
                 NEXT FIELD cod_item
              END IF
           END IF


        END IF

      ON KEY (control-w, f1)
         #lds IF NOT LOG_logix_versao5() THEN
         #lds CONTINUE INPUT
         #lds END IF
         CALL vdp4283_help_itens()

      ON KEY (control-z, f4)
         CALL vdp4283_popup(3)
   END INPUT

   LET p_count  = arr_count()

 CLOSE WINDOW w_vdp42832
 CURRENT WINDOW IS w_vdp4283

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#-------------------------------#
FUNCTION vdp4283_verifica_grade()
#-------------------------------#
   WHENEVER ERROR CONTINUE
   SELECT item.*
     INTO p_item2.*
     FROM item,
          item_vdp
    WHERE item.cod_item        = t_pedido_dig_item[pa_curr].cod_item
      AND item.cod_item        = item_vdp.cod_item
      AND item.cod_empresa     = p_cod_empresa
      AND item_vdp.cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = NOTFOUND THEN
      CALL log0030_mensagem( " Produto não cadastrado ","excl")
      LET p_status = 0
      RETURN  FALSE
   END IF
   WHENEVER ERROR CONTINUE
   SELECT UNIQUE cod_empresa
     FROM item_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_lin_prod  = 0
      AND cod_lin_recei = 0
      AND cod_seg_merc  = 0
      AND cod_cla_uso   = 0
      AND cod_item      = t_pedido_dig_item[pa_curr].cod_item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN

      IF vdp4283_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem( " Entrada de grade Cancelada","excl")
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   WHENEVER ERROR CONTINUE
   SELECT UNIQUE cod_empresa
     FROM item_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_lin_prod  = p_item2.cod_lin_prod
      AND cod_lin_recei = p_item2.cod_lin_recei
      AND cod_seg_merc  = p_item2.cod_seg_merc
      AND cod_cla_uso   = p_item2.cod_cla_uso
      AND (cod_item     IS NULL OR
           cod_item     = " ")
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN

      IF vdp4283_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem( " Entrada de grade Cancelada","excl")
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   WHENEVER ERROR CONTINUE
   SELECT UNIQUE cod_empresa
     FROM item_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_lin_prod  = p_item2.cod_lin_prod
      AND cod_lin_recei = p_item2.cod_lin_recei
      AND cod_seg_merc  = p_item2.cod_seg_merc
      AND cod_cla_uso   = 0
      AND (cod_item     IS NULL OR
           cod_item     = " ")
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      LET p_item2.cod_cla_uso  = 0

      IF vdp4283_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem( " Entrada de grade Cancelada","excl")
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   WHENEVER ERROR CONTINUE
   SELECT UNIQUE cod_empresa
     FROM item_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_lin_prod  = p_item2.cod_lin_prod
      AND cod_lin_recei = p_item2.cod_lin_recei
      AND cod_seg_merc  = 0
      AND cod_cla_uso   = 0
      AND (cod_item     IS NULL OR
           cod_item     = " ")
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      LET p_item2.cod_seg_merc  = 0
      LET p_item2.cod_cla_uso   = 0

      IF vdp4283_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem( " Entrada de grade Cancelada","excl")
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   WHENEVER ERROR CONTINUE
   SELECT UNIQUE cod_empresa
     FROM item_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_lin_prod  = p_item2.cod_lin_prod
      AND cod_lin_recei = 0
      AND cod_seg_merc  = 0
      AND cod_cla_uso   = 0
      AND (cod_item     IS NULL OR
           cod_item     = " ")
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      LET p_item2.cod_lin_recei = 0
      LET p_item2.cod_seg_merc  = 0
      LET p_item2.cod_cla_uso   = 0

      IF vdp4283_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem( " Entrada de grade Cancelada","excl")
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------------#
FUNCTION vdp4283_entrada_dados_grad()
#-----------------------------------#
   DEFINE l_for,
          l_count                   SMALLINT

   WHENEVER ERROR CONTINUE
   CALL log130_procura_caminho("vdp42836") RETURNING p_comando
   OPEN WINDOW w_vdp42836 AT 2,2 WITH FORM p_comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   WHENEVER ERROR STOP

   CALL log006_exibe_teclas("01 02 03 05 06 07", p_versao)
   CURRENT WINDOW IS w_vdp42836

   INITIALIZE t_array_grade TO NULL

   DISPLAY p_cod_empresa                       TO cod_empresa
   DISPLAY p_pedido_dig_mest.num_pedido        TO num_pedido
   DISPLAY t_pedido_dig_item[pa_curr].cod_item TO cod_item

   LET p_sum_qtd_grade = 0
   LET l_count = 0

   FOR l_for = 1 TO 500
      IF t_pedido_dig_grad[l_for].num_sequencia = pa_curr   THEN
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

   CALL vdp4283_busca_cab_grade()

   CALL SET_COUNT(l_count)

   INPUT ARRAY t_array_grade WITHOUT DEFAULTS
    FROM s_pedido_dig_grad.*

      BEFORE ROW
         LET pa_curr_g  = arr_curr()
         LET pa_count_g = arr_count()
         LET sc_curr_g  = scr_line()

      BEFORE FIELD cod_grade_1
         CALL vdp4283_mostra_zoom()
      AFTER  FIELD cod_grade_1
         IF (t_array_grade[pa_curr_g].cod_grade_1 IS NULL OR
             t_array_grade[pa_curr_g].cod_grade_1 = " "     ) AND
            fgl_lastkey() <> fgl_keyval("RETURN")             THEN
            EXIT INPUT
         END IF
         IF vdp4283_item_grade(1,t_array_grade[pa_curr_g].cod_grade_1) = FALSE
         THEN
            LET m_msg = " Grade não cadastrada para o item ", p_item2.cod_item
            CALL log0030_mensagem(m_msg,"excl")
            NEXT FIELD cod_grade_1
         END IF
         CALL vdp4283_apaga_zoom()

      BEFORE FIELD cod_grade_2
         IF p_cab_grade.den_grade_2 IS NULL OR
            p_cab_grade.den_grade_2 = " "   THEN
            IF fgl_lastkey() = fgl_keyval("UP")   OR
               fgl_lastkey() = fgl_keyval("LEFT") THEN
               NEXT FIELD cod_grade_1
            ELSE
               NEXT FIELD cod_grade_3
            END IF
         END IF
         CALL vdp4283_mostra_zoom()
      AFTER  FIELD cod_grade_2
         IF vdp4283_item_grade(2,t_array_grade[pa_curr_g].cod_grade_2) = FALSE
         THEN
            LET m_msg = " Grade não cadastrada para o item ", p_item2.cod_item
            CALL log0030_mensagem(m_msg,"excl")
            NEXT FIELD cod_grade_2
         END IF
         CALL vdp4283_apaga_zoom()

      BEFORE FIELD cod_grade_3
         IF p_cab_grade.den_grade_3 IS NULL OR
            p_cab_grade.den_grade_3 = " "   THEN
            IF fgl_lastkey() = fgl_keyval("UP")   OR
               fgl_lastkey() = fgl_keyval("LEFT") THEN
               NEXT FIELD cod_grade_2
            ELSE
               NEXT FIELD cod_grade_4
            END IF
         END IF
         CALL vdp4283_mostra_zoom()
      AFTER  FIELD cod_grade_3
         IF vdp4283_item_grade(3,t_array_grade[pa_curr_g].cod_grade_3) = FALSE
         THEN
            LET m_msg =  " Grade nao cadastrada para o item ", p_item2.cod_item
            CALL log0030_mensagem(m_msg,"excl")
            NEXT FIELD cod_grade_3
         END IF
         CALL vdp4283_apaga_zoom()

      BEFORE FIELD cod_grade_4
         IF p_cab_grade.den_grade_4 IS NULL OR
            p_cab_grade.den_grade_4 = " "   THEN
            IF fgl_lastkey() = fgl_keyval("UP")   OR
               fgl_lastkey() = fgl_keyval("LEFT") THEN
               NEXT FIELD cod_grade_3
            ELSE
               NEXT FIELD cod_grade_5
            END IF
         END IF
         CALL vdp4283_mostra_zoom()
      AFTER  FIELD cod_grade_4
         IF vdp4283_item_grade(4,t_array_grade[pa_curr_g].cod_grade_4) = FALSE
         THEN
            LET m_msg = " Grade não cadastrada para o item ", p_item2.cod_item
            CALL log0030_mensagem(m_msg,"excl")
            NEXT FIELD cod_grade_4
         END IF
         CALL vdp4283_apaga_zoom()

      BEFORE FIELD cod_grade_5
         IF p_cab_grade.den_grade_5 IS NULL OR
            p_cab_grade.den_grade_5 = " "   THEN
            IF fgl_lastkey() = fgl_keyval("UP")   OR
               fgl_lastkey() = fgl_keyval("LEFT") THEN
               NEXT FIELD cod_grade_4
            ELSE
               NEXT FIELD qtd_pecas
            END IF
         END IF
         CALL vdp4283_mostra_zoom()
      AFTER  FIELD cod_grade_5
         IF vdp4283_item_grade(5,t_array_grade[pa_curr_g].cod_grade_5) = FALSE
         THEN
            LET m_msg = " Grade nao cadastrada para o item ", p_item2.cod_item
            CALL log0030_mensagem(m_msg, "excl")
            NEXT FIELD cod_grade_5
         END IF
         CALL vdp4283_apaga_zoom()

      AFTER  FIELD qtd_pecas
         IF t_array_grade[pa_curr_g].qtd_pecas IS NULL OR
            t_array_grade[pa_curr_g].qtd_pecas <= 0    THEN
            CALL log0030_mensagem( "Quantidade deve ser maior que zero ","excl")
            NEXT FIELD qtd_pecas
         END IF

      AFTER DELETE
         IF pa_count_g > 0 AND
            pa_count_g >= pa_curr_g THEN
            INITIALIZE t_array_grade[pa_count_g].* TO NULL
         END IF

      ON KEY (control-z, f4)
         CALL vdp4283_popup(1)

   END INPUT

   CLOSE WINDOW w_vdp42836
   CURRENT WINDOW IS w_vdp42832
   CALL log006_exibe_teclas("01 02 05 06 07", p_versao)

   IF int_flag <> 0 THEN
      LET int_flag  = 0
      RETURN FALSE
   END IF

   CALL vdp4283_grava_alteracoes_grade()
   LET t_pedido_dig_item[pa_curr].qtd_pecas_solic = p_sum_qtd_grade

   RETURN TRUE
END FUNCTION


#--------------------------------#
FUNCTION vdp4283_busca_cab_grade()
#--------------------------------#

   INITIALIZE p_cab_grade.*,
              mr_item_ctr_grade.*,
              ma_ctr_grade           TO NULL

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO mr_item_ctr_grade.*
     FROM item_ctr_grade
    WHERE cod_empresa        = p_cod_empresa
      AND cod_lin_prod       = 0
      AND cod_lin_recei      = 0
      AND cod_seg_merc       = 0
      AND cod_cla_uso        = 0
      AND cod_familia        = 0
      AND cod_item           = t_pedido_dig_item[pa_curr].cod_item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      RETURN
   END IF
   WHENEVER ERROR CONTINUE
   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_1
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_1
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      WHENEVER ERROR CONTINUE
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
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
      END IF
   END IF
   WHENEVER ERROR CONTINUE
   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_2
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_2
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      WHENEVER ERROR CONTINUE
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
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
       END IF
   END IF
   WHENEVER ERROR CONTINUE
   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_3
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_3
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      WHENEVER ERROR CONTINUE
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
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
      END IF
   END IF
   WHENEVER ERROR CONTINUE
   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_4
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_4
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      WHENEVER ERROR CONTINUE
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
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
      END IF
   END IF
   WHENEVER ERROR CONTINUE
   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_5
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_5
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      WHENEVER ERROR CONTINUE
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
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
      END IF
   END IF

   DISPLAY BY NAME p_cab_grade.*

END FUNCTION


#---------------------------------------#
FUNCTION vdp4283_grava_alteracoes_grade()
#---------------------------------------#
   DEFINE l_for,
          l_for_aux                     SMALLINT

   LET p_sum_qtd_grade = 0

   FOR l_for = 1 TO 500
      IF t_pedido_dig_grad[l_for].num_sequencia = pa_curr THEN
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
         LET t_pedido_dig_grad[l_for_aux].num_pedido        =
             p_pedido_dig_mest.num_pedido
         LET t_pedido_dig_grad[l_for_aux].num_sequencia     = pa_curr
         LET t_pedido_dig_grad[l_for_aux].cod_item          =
             t_pedido_dig_item[pa_curr].cod_item
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


#---------------------------------------------------#
FUNCTION vdp4283_item_grade(p_ies_grade, l_cod_grade)
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
FUNCTION vdp4283_entrada_dados_item_bnf()
#---------------------------------------#
   DEFINE l_qtd_c_decim     DECIMAL(15,5),
          l_qtd_resto       DECIMAL(15,5),
          l_qtd_s_decim     INTEGER,
          l_desc_adic_m_i   DECIMAL(5,2),
          l_qtd_padr_embal  LIKE item_embalagem.qtd_padr_embal,
          sc_curr           SMALLINT,
          l_campo           SMALLINT,
          l_pct_comissao    LIKE comissao_par.pct_comissao

   WHENEVER ERROR CONTINUE
   CALL log130_procura_caminho("vdp42839") RETURNING p_nom_tela
   OPEN WINDOW w_vdp42839 AT 2,02 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   WHENEVER ERROR STOP

   CALL log006_exibe_teclas("01 02 05 06 07", p_versao)
   CURRENT WINDOW IS w_vdp42839

   DISPLAY p_cod_empresa                 TO cod_empresa
   DISPLAY p_pedido_dig_mest.num_pedido  TO num_pedido

   INPUT ARRAY ma_ped_dig_bnf  WITHOUT DEFAULTS FROM s_ped_dig_bnf.*

      BEFORE ROW
         LET pa_curr_b = arr_curr()
         LET sc_curr_b = scr_line()

      BEFORE FIELD cod_item
         CALL vdp4283_mostra_zoom()

      AFTER FIELD cod_item
         IF ma_ped_dig_bnf[pa_curr_b].cod_item IS  NULL
         THEN IF   fgl_lastkey() = fgl_keyval("UP") OR
                   fgl_lastkey() = fgl_keyval("LEFT") OR
                   fgl_lastkey() = fgl_keyval("DOWN")
              THEN CONTINUE INPUT
              ELSE EXIT INPUT
              END IF
         ELSE
            CALL vdp4283_verifica_item_bnf()
                 RETURNING p_status, l_qtd_padr_embal
            IF p_status = 0 THEN
               NEXT FIELD cod_item
            END IF
         END IF
         CALL vdp4283_apaga_zoom()

      BEFORE FIELD  qtd_pecas_solic
         IF ma_ped_dig_bnf[pa_curr_b].qtd_pecas_solic IS NULL THEN
            LET ma_ped_dig_bnf[pa_curr_b].qtd_pecas_solic = 0
            DISPLAY ma_ped_dig_bnf[pa_curr_b].qtd_pecas_solic TO
                     s_ped_dig_bnf[sc_curr_b].qtd_pecas_solic
         END IF

      AFTER  FIELD  qtd_pecas_solic
         IF ma_ped_dig_bnf[pa_curr_b].qtd_pecas_solic IS NULL THEN
         ELSE
            IF p_pedido_dig_mest.ies_embal_padrao = "1" OR
               p_pedido_dig_mest.ies_embal_padrao = "2" THEN
               LET l_qtd_c_decim  = ma_ped_dig_bnf[pa_curr_b].qtd_pecas_solic /
                                    l_qtd_padr_embal
               LET l_qtd_s_decim  = ma_ped_dig_bnf[pa_curr_b].qtd_pecas_solic /
                                    l_qtd_padr_embal
               LET l_qtd_resto   = l_qtd_c_decim - l_qtd_s_decim
               IF l_qtd_resto = 0 THEN
                  IF ma_ped_dig_bnf[pa_curr_b].qtd_pecas_solic >=
                     l_qtd_padr_embal THEN
                  ELSE
                     CALL log0030_mensagem( "Qtd  solic. menor que Qtd padrão embal.","excl")
                     NEXT FIELD qtd_pecas_solic
                  END  IF
               ELSE
                  CALL log0030_mensagem( "Pedido padrão embal. qtd. peças não padrão embal.","excl")
                  NEXT FIELD qtd_pecas_solic
               END IF
            END IF
         END IF

      BEFORE FIELD pre_unit
         IF ma_ped_dig_bnf[pa_curr_b].pre_unit IS NULL THEN
            LET ma_ped_dig_bnf[pa_curr_b].pre_unit = 0
            DISPLAY ma_ped_dig_bnf[pa_curr_b].pre_unit TO
                       s_ped_dig_bnf[sc_curr_b].pre_unit
         END IF
         IF p_pedido_dig_mest.num_list_preco <> " " AND
            p_pedido_dig_mest.num_list_preco > 0    THEN
            NEXT FIELD pct_desc_adic
         END IF

      AFTER  FIELD pre_unit
         IF ma_ped_dig_bnf[pa_curr_b].pre_unit IS NULL OR
            ma_ped_dig_bnf[pa_curr_b].pre_unit = 0     THEN
            CALL log0030_mensagem( "Preço unitário inválido ","excl")
            NEXT FIELD pre_unit
         END IF

      BEFORE FIELD pct_desc_adic
         IF ma_ped_dig_bnf[pa_curr_b].pct_desc_adic IS NULL THEN
            LET ma_ped_dig_bnf[pa_curr_b].pct_desc_adic = 0
            DISPLAY ma_ped_dig_bnf[pa_curr_b].pct_desc_adic TO
                     s_ped_dig_bnf[sc_curr_b].pct_desc_adic
         END IF
      AFTER  FIELD pct_desc_adic
         IF ma_ped_dig_bnf[pa_curr_b].pct_desc_adic IS NULL THEN
            CALL log0030_mensagem( " Percentual de desconto inválido ","excl")
            NEXT FIELD pct_desc_adic
         ELSE
            LET l_desc_adic_m_i = 100 - p_pedido_dig_mest.pct_desc_adic
            LET l_desc_adic_m_i = 100 - (l_desc_adic_m_i -
                                        (l_desc_adic_m_i *
                                         ma_ped_dig_bnf[pa_curr_b].pct_desc_adic
                                         / 100))
            WHENEVER ERROR CONTINUE
            SELECT pct_desc_adic_max
              INTO m_pct_desc_adic_max
              FROM cli_info_adic
             WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
            WHENEVER ERROR STOP
            IF sqlca.sqlcode = 0 AND
               m_pct_desc_adic_max > 0 THEN
               IF l_desc_adic_m_i > m_pct_desc_adic_max
               THEN CALL log0030_mensagem( "Desc.Adic. Mestre + Desc. Adic. Item maior que o limite - CLI_INFO_ADIC","excl")
                    LET p_erro[6] = "1"
               ELSE LET p_erro[6] = "0"
               END IF
            ELSE
               IF l_desc_adic_m_i > p_par_vdp.pct_desc_adic THEN
                  CALL log0030_mensagem( "Desc.Adic. Mestre + Desc. Adic. Item maior que o limite - PAR_VDP","excl")
                  LET p_erro[6] = "1"
               ELSE LET p_erro[6] = "0"
               END IF
            END IF
         END IF

      BEFORE FIELD prz_entrega
         IF ma_ped_dig_bnf[pa_curr_b].prz_entrega IS NULL OR
            ma_ped_dig_bnf[pa_curr_b].prz_entrega = " " THEN
            LET ma_ped_dig_bnf[pa_curr_b].prz_entrega =
                p_pedido_dig_mest.dat_prazo_entrega
         END IF
         LET l_campo = TRUE

      AFTER  FIELD prz_entrega
         IF ma_ped_dig_bnf[pa_curr_b].prz_entrega < TODAY THEN
            CALL log0030_mensagem( " DATA menor que a data corrente","excl")
            NEXT FIELD prz_entrega
         END IF
         IF m_lead_time > 0 THEN
            IF ma_ped_dig_bnf[pa_curr_b].prz_entrega - m_lead_time < TODAY THEN
               LET m_msg = " Prazo de Entrega menos Lead Time(",m_lead_time USING "<<<"," dias) ",
                     "menor que a data corrente "
               CALL log0030_mensagem(m_msg,"excl")
               NEXT FIELD prz_entrega
            ELSE
               LET ma_ped_dig_bnf[pa_curr_b].prz_entrega =
                   ma_ped_dig_bnf[pa_curr_b].prz_entrega - m_lead_time
               DISPLAY ma_ped_dig_bnf[pa_curr_b].prz_entrega TO prz_entrega
            END IF
         END IF
         IF p_pedido_dig_mest.ies_tip_entrega = 1 THEN
            FOR pa_curr_b = 1 TO (pa_curr - 1)
               IF ma_ped_dig_bnf[pa_curr_b].prz_entrega <> ma_ped_dig_bnf[pa_curr].prz_entrega THEN
                  CALL log0030_mensagem( " Pedido entrega total não pode ter prazos de entrega diferentes ","excl")
                  NEXT FIELD prz_entrega
               END IF
            END FOR
         END IF

      AFTER INPUT
         IF NOT int_flag THEN
            IF p_pedido_dig_mest.ies_tip_entrega = 1 THEN
              FOR pa_curr_b = 2 TO 500
                 IF ma_ped_dig_bnf[pa_curr_b].prz_entrega IS NULL THEN
                    EXIT FOR
                 END IF

                 IF ma_ped_dig_bnf[pa_curr_b].prz_entrega <> ma_ped_dig_bnf[pa_curr_b - 1].prz_entrega THEN
                    CALL log0030_mensagem( " Pedido entrega total não pode ter prazos de entrega diferentes ","excl")
                    NEXT FIELD prz_entrega
                 END IF
              END FOR
           END IF
        END IF

      ON KEY (control-w, f1)
         #lds IF NOT LOG_logix_versao5() THEN
         #lds CONTINUE INPUT
         #lds END IF
         CALL vdp4283_help_itens_bnf()

      ON KEY (control-z, f4)
         CALL vdp4283_popup(4)

   END INPUT

 CLOSE WINDOW w_vdp42839
 CURRENT WINDOW IS w_vdp4283

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION


#----------------------------------#
FUNCTION vdp4283_verifica_item_bnf()
#----------------------------------#
   DEFINE l_ies_situacao    LIKE item.ies_situacao,
          l_qtd_padr_embal  LIKE item_embalagem.qtd_padr_embal,
          l_pre_unit_liq    LIKE item_vdp.pre_unit_brut,
          l_pre_unit_bruto  LIKE item_vdp.pre_unit_brut,
          l_desc_bruto_tab  LIKE desc_preco_item.pct_desc,
          l_pre_unit_tab    LIKE desc_preco_item.pre_unit,
          l_desc_adic_tab   LIKE desc_preco_item.pct_desc_adic,
          l_cod_lin_prod    LIKE item.cod_lin_prod,
          l_cod_lin_recei   LIKE item.cod_lin_recei,
          l_cod_seg_merc    LIKE item.cod_seg_merc,
          l_cod_cla_uso     LIKE item.cod_cla_uso,
          l_cod_item        LIKE item_vdp.cod_item,
          l_den_item        LIKE item.den_item

   WHENEVER ERROR CONTINUE
   SELECT item.cod_item,
          item.den_item,
          item.ies_situacao,
          item_vdp.pre_unit_brut,
          item.cod_lin_prod,
          item.cod_lin_recei,
          item.cod_seg_merc,
          item.cod_cla_uso
     INTO l_cod_item,
          l_den_item,
          l_ies_situacao,
          l_pre_unit_bruto,
          l_cod_lin_prod,
          l_cod_lin_recei,
          l_cod_seg_merc,
          l_cod_cla_uso
     FROM item,
          item_vdp
    WHERE item.cod_item        = ma_ped_dig_bnf[pa_curr_b].cod_item
      AND item.cod_item        = item_vdp.cod_item
      AND item.cod_empresa     = p_cod_empresa
      AND item_vdp.cod_empresa = p_cod_empresa
   WHENEVER ERROR CONTINUE
   IF sqlca.sqlcode = NOTFOUND THEN
      CALL log0030_mensagem( " Produto não cadastrado ","excl")
      LET p_status = 0
      RETURN  p_status, l_qtd_padr_embal
   END IF

   IF l_ies_situacao = "A" THEN
   ELSE
      CALL log0030_mensagem( "Produto cancelado","excl")
      LET p_status = 0
      RETURN  p_status, l_qtd_padr_embal
   END IF

   IF p_pedido_dig_mest.ies_embal_padrao = "1" THEN
      WHENEVER ERROR CONTINUE
      SELECT qtd_padr_embal
        INTO l_qtd_padr_embal
        FROM item_embalagem
       WHERE item_embalagem.cod_empresa = p_cod_empresa
         AND item_embalagem.cod_item    = ma_ped_dig_bnf[pa_curr_b].cod_item
         AND item_embalagem.ies_tip_embal IN ("N","I")
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = NOTFOUND THEN
         CALL log0030_mensagem( "Item_bnf não cadastrado na tabela item_embalagem","excl")
         LET p_status = 0
         RETURN p_status, l_qtd_padr_embal
      END IF
   ELSE
      IF p_pedido_dig_mest.ies_embal_padrao = "2" THEN
         WHENEVER ERROR CONTINUE
         SELECT qtd_padr_embal
           INTO l_qtd_padr_embal
           FROM item_embalagem
          WHERE item_embalagem.cod_empresa = p_cod_empresa
            AND item_embalagem.cod_item    = ma_ped_dig_bnf[pa_curr_b].cod_item
            AND item_embalagem.ies_tip_embal IN ("E","C")
         WHENEVER ERROR STOP
         IF sqlca.sqlcode = NOTFOUND THEN
            CALL log0030_mensagem( "Item_bnf não cadastrado na tabela item_embalagem","excl")
            LET p_status = 0
            RETURN p_status, l_qtd_padr_embal
         END IF
      END IF
   END IF
   IF p_pedido_dig_mest.num_list_preco = 0     OR
      p_pedido_dig_mest.num_list_preco IS NULL THEN
   ELSE
       CALL vdp1499_busca_preco_lista(p_cod_empresa,
                                      p_pedido_dig_mest.num_list_preco,
                                      p_pedido_dig_mest.cod_cliente,l_cod_item,
                                      l_cod_lin_prod,
                                      l_cod_lin_recei,
                                      l_cod_seg_merc,
                                      l_cod_cla_uso,
                                      0,0,0,
                                    p_cod_uni_feder)
                                      RETURNING p_status,
                                                l_desc_bruto_tab,
                                                l_desc_adic_tab,
                                                l_pre_unit_tab
         IF p_status = 0 THEN
         IF l_pre_unit_tab > 0 THEN
            LET ma_ped_dig_bnf[pa_curr_b].pre_unit = l_pre_unit_tab
            IF ma_ped_dig_bnf[pa_curr_b].pct_desc_adic = 0     OR
               ma_ped_dig_bnf[pa_curr_b].pct_desc_adic IS NULL THEN
               LET ma_ped_dig_bnf[pa_curr_b].pct_desc_adic = l_desc_adic_tab
            END IF
            DISPLAY ma_ped_dig_bnf[pa_curr_b].pre_unit TO
                     s_ped_dig_bnf[sc_curr_b].pre_unit
            DISPLAY ma_ped_dig_bnf[pa_curr_b].pct_desc_adic TO
                     s_ped_dig_bnf[sc_curr_b].pct_desc_adic
            CALL vdp4283_busca_qtd_dec_bnf()
            DISPLAY ma_ped_dig_bnf[pa_curr_b].pre_unit TO
                     s_ped_dig_bnf[sc_curr_b].pre_unit
         ELSE
            CALL vdp4283_calcula_pre_unit(l_pre_unit_bruto,
                                          l_desc_bruto_tab)
                 RETURNING ma_ped_dig_bnf[pa_curr_b].pre_unit
            IF ma_ped_dig_bnf[pa_curr_b].pct_desc_adic = 0     OR
               ma_ped_dig_bnf[pa_curr_b].pct_desc_adic IS NULL THEN
               LET ma_ped_dig_bnf[pa_curr_b].pct_desc_adic = l_desc_adic_tab
            END IF
            DISPLAY ma_ped_dig_bnf[pa_curr_b].pre_unit TO
                     s_ped_dig_bnf[sc_curr_b].pre_unit
            DISPLAY ma_ped_dig_bnf[pa_curr_b].pct_desc_adic TO
                     s_ped_dig_bnf[sc_curr_b].pct_desc_adic
         END IF
      ELSE
         CALL log0030_mensagem( "Produto não cadastrado na lista de preço","excl")
         LET p_status = 0
         RETURN  p_status, l_qtd_padr_embal
      END  IF
   END  IF

   LET ma_ped_dig_bnf[pa_curr_b].den_item  = l_den_item
   DISPLAY ma_ped_dig_bnf[pa_curr_b].den_item TO
            s_ped_dig_bnf[sc_curr_b].den_item

   LET p_status = 1
   WHENEVER ERROR STOP

   RETURN p_status, l_qtd_padr_embal
END FUNCTION

#-------------------------------#
FUNCTION vdp4283_help_itens_bnf()
#-------------------------------#
   CASE
      WHEN INFIELD(cod_item)           CALL SHOWHELP(3046)
      WHEN INFIELD(qtd_pecas_solic)    CALL SHOWHELP(3047)
      WHEN INFIELD(pre_unit)           CALL SHOWHELP(3048)
      WHEN INFIELD(pct_desc_adic)      CALL SHOWHELP(3049)
      WHEN INFIELD(prz_entrega)        CALL SHOWHELP(3050)
      WHEN INFIELD(ies_incl_txt)       CALL SHOWHELP(3045)
   END CASE
END FUNCTION


#-------------------------------------------------------#
 FUNCTION vdp4283_calcula_pre_unit(p_pre_unit,p_pct_desc)
#-------------------------------------------------------#
  DEFINE p_pre_unit_1      DECIMAL(17,1),
         p_pre_unit_2      DECIMAL(17,2),
         p_pre_unit_3      DECIMAL(17,3),
         p_pre_unit_4      DECIMAL(17,4),
         p_pre_unit_5      DECIMAL(17,5),
         p_pre_unit_6      DECIMAL(17,6),
         p_pre_unit        LIKE ped_itens.pre_unit,
         p_pct_desc        LIKE pedidos.pct_desc_adic

 CASE p_par_vdp.par_vdp_txt[43]
   WHEN 1
      LET p_pre_unit_1 = ( p_pre_unit -
                         ( p_pre_unit *
                           p_pct_desc / 100))
      RETURN p_pre_unit_1
   WHEN 2
      LET p_pre_unit_2 = ( p_pre_unit -
                         ( p_pre_unit *
                           p_pct_desc / 100))
      RETURN p_pre_unit_2
   WHEN 3
      LET p_pre_unit_3 = ( p_pre_unit -
                         ( p_pre_unit *
                           p_pct_desc / 100))
      RETURN p_pre_unit_3
   WHEN 4
      LET p_pre_unit_4 = ( p_pre_unit -
                         ( p_pre_unit *
                           p_pct_desc / 100))
      RETURN p_pre_unit_4
   WHEN 5
      LET p_pre_unit_5 = ( p_pre_unit -
                         ( p_pre_unit *
                           p_pct_desc / 100))
      RETURN p_pre_unit_5
   WHEN 6
      LET p_pre_unit_6 = ( p_pre_unit -
                         ( p_pre_unit *
                           p_pct_desc / 100))
      RETURN p_pre_unit_6
 END CASE
END FUNCTION

#---------------------------------------#
 FUNCTION vdp4283_verifica_preco_minimo()
#---------------------------------------#
  DEFINE p_pct_desc_m             LIKE pedidos.pct_desc_adic,
         p_pct_desc_i             LIKE ped_itens.pct_desc_adic,
         p_valor_item_ipi         LIKE nf_mestre.val_tot_nff,
         p_valor_item_icm         LIKE nf_mestre.val_tot_nff,
         p_valor_item_pis         LIKE nf_mestre.val_tot_nff,
         p_valor_item_comis       LIKE nf_mestre.val_tot_nff


  IF   p_ies_emite_dupl_nat               = "S"   AND
       p_par_vdp.par_vdp_txt[39,39]       = "S"
  THEN CALL vdp4283_busca_desc_adic_unico(0,
                                          p_pedido_dig_mest.pct_desc_adic)
            RETURNING p_pct_desc_m

       LET  p_pre_unit_liq      = t_pedido_dig_item[pa_curr].pre_unit -
                                 (p_pct_desc_m *
                                  t_pedido_dig_item[pa_curr].pre_unit / 100)

       CALL vdp4283_busca_desc_adic_unico(pa_curr,
                                       t_pedido_dig_item[pa_curr].pct_desc_adic)
            RETURNING p_pct_desc_i

       LET  p_pre_unit_liq   = p_pre_unit_liq -
                             ( p_pct_desc_i * p_pre_unit_liq / 100)

       CALL vdp583_verifica_analise_rentab(p_cod_empresa,
                                           t_pedido_dig_item[pa_curr].cod_item,
                                           p_juros.pct_j_bruto_merc,
                                           p_juros.pct_j_bruto_imp,
                                           p_juros.pct_j_real,
                                           p_juros.pct_j_vendor,
                                           p_juros.pct_j_comis,
                                           p_juros.pct_j_frete,
                                           p_pct_desp_finan,
                                           p_qtd_dias_media,
                                           p_pct_icm,
                                           p_pct_ipi,
                                           t_pedido_dig_item[pa_curr].qtd_pecas_solic,
                                           p_pre_unit_liq,
                                           t_pedido_dig_item[pa_curr].prz_entrega)
                                 RETURNING p_pre_unit_ped,
                                           p_valor_item_ipi,
                                           p_valor_item_icm,
                                           p_valor_item_pis,
                                           p_valor_item_comis
       WHENEVER ERROR CONTINUE
       SELECT preco_minimo.*
         INTO p_preco_minimo.*
         FROM preco_minimo
        WHERE preco_minimo.cod_empresa = p_cod_empresa
          AND preco_minimo.cod_item    = t_pedido_dig_item[pa_curr].cod_item
      WHENEVER ERROR STOP
       IF   sqlca.sqlcode = 0
       THEN
       ELSE CALL log0030_mensagem( "Item não cadastrado na tabela de PRECO MINIMO","excl")
            RETURN FALSE
       END IF
       WHENEVER ERROR CONTINUE
       SELECT val_cotacao
         INTO p_val_cotacao_min
         FROM cotacao
        WHERE cotacao.cod_moeda = p_preco_minimo.cod_moeda
          AND cotacao.dat_ref   = TODAY
       WHENEVER ERROR STOP
       IF   sqlca.sqlcode = 0
       THEN
       ELSE CALL log0030_mensagem( "Moeda do Preço Mínimo sem cotação para o dia ","excl")
            RETURN FALSE
       END IF

       LET  p_pre_unit_min = p_preco_minimo.pre_unit_min * p_val_cotacao_min
       LET  p_pct_dif      = 100 - ((p_pre_unit_min * 100) / p_pre_unit_ped)
       IF   p_pre_unit_ped < p_pre_unit_min   AND
            p_pct_dif      < 0
       THEN CALL log0030_mensagem( "Preço menor que o Mínimo ","excl")
            RETURN FALSE
       END IF
  END IF
  RETURN TRUE
END FUNCTION

#-----------------------------------#
 FUNCTION vdp4283_verifica_prevprod()
#-----------------------------------#
 DEFINE p_cod_item                 LIKE item.cod_item,
        p_data                     DATE,
        p_semana                   SMALLINT,
        p_semana_aux               SMALLINT,
        p_ano                      SMALLINT,
        p_ano_aux                  SMALLINT,
        p_cont                     SMALLINT,
        p_qtd                      LIKE previsao_producao.qtd_pedido,
        p_qtd_saldo                LIKE previsao_producao.qtd_pedido,
        p_qtd_saldo_aux            LIKE previsao_producao.qtd_pedido,
        p_audit_logix              RECORD LIKE audit_logix.*

 LET p_semana    = log027_numero_semana(p_pedido_dig_mest.dat_prazo_entrega)
 LET p_ano       = YEAR(p_pedido_dig_mest.dat_prazo_entrega)
 LET p_qtd_saldo = t_pedido_dig_item[pa_curr].qtd_pecas_solic
 LET p_cod_item  = t_pedido_dig_item[pa_curr].cod_item
 INITIALIZE p_prev_producao.* TO NULL
 WHENEVER ERROR CONTINUE
 SELECT * INTO p_prev_producao.* FROM previsao_producao
  WHERE previsao_producao.cod_empresa = p_cod_empresa
    AND previsao_producao.cod_item   = p_cod_item
    AND previsao_producao.num_semana = p_semana
    AND previsao_producao.ano        = p_ano
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = NOTFOUND
 THEN INITIALIZE p_audit_logix.texto TO NULL
      LET p_audit_logix.texto = "ITEM SEM PREVISAO DE VENDAS",
          "  PARA A SEMANA ", p_semana, "/", p_ano
      LET m_msg = " ",p_cod_item, " ITEM SEM PREVISAO DE VENDAS"
      CALL log0030_mensagem(m_msg,"excl")
              LET p_prev_producao.num_semana   = p_semana
              LET p_prev_producao.ano          = p_ano
              LET p_prev_producao.qtd_prevista = "0"
              LET p_prev_producao.qtd_pedido   = p_qtd_saldo
              CALL vdp4283_insere_prevprod()
              LET p_audit_logix.cod_empresa = p_cod_empresa
              LET p_audit_logix.texto = "INSERCAO PREVISAO PRODUCAO DO ITEM ",
                                         p_prev_producao.cod_item CLIPPED,
                                        " SEMANA ",p_semana,
                                        " ANO ", p_ano,
                                        " QTD. ",p_prev_producao.qtd_pedido
              LET p_audit_logix.num_programa = "vdp4283"
              LET p_audit_logix.data = TODAY
              LET p_audit_logix.hora = TIME
              LET p_audit_logix.usuario = p_user
              WHENEVER ERROR CONTINUE
              INSERT INTO audit_logix VALUES(p_audit_logix.*)
              WHENEVER ERROR STOP
              RETURN TRUE
 ELSE IF (p_prev_producao.qtd_pedido + p_qtd_saldo) >
          p_prev_producao.qtd_prevista
      THEN INITIALIZE p_audit_logix.texto TO NULL
           LET p_qtd_saldo_aux = p_prev_producao.qtd_prevista -
                                 p_prev_producao.qtd_pedido
           LET p_audit_logix.texto = "SALDO DA PREVISAO DE PRODUCAO = ", p_qtd_saldo_aux,
               "  PARA A SEMANA ", p_semana, "/", p_ano
           LET m_msg = "SALDO DA PREVISAO DE PRODUCAO = ", p_qtd_saldo_aux,
                 "  PARA A SEMANA ", p_semana, "/", p_ano
           CALL log0030_mensagem(m_msg,"excl")
           IF log0040_confirm(10,10,"Confirma processo em andamento?")= FALSE
              THEN RETURN FALSE
           END IF
      END IF
      LET p_prev_producao.qtd_pedido = p_prev_producao.qtd_pedido +
                                       p_qtd_saldo
      CALL vdp4283_atualiza_prevprod()
      LET p_audit_logix.cod_empresa = p_cod_empresa
      LET p_audit_logix.texto = "ATUALIZACAO PREVISAO PRODUCAO DO ITEM ",
                                p_prev_producao.cod_item CLIPPED,
                                " SEMANA ",p_semana,
                                " ANO ", p_ano,
                                " QTD. ",p_prev_producao.qtd_pedido
      LET p_audit_logix.num_programa = "vdp4283"
      LET p_audit_logix.data = TODAY
      LET p_audit_logix.hora = TIME
      LET p_audit_logix.usuario = p_user
      WHENEVER ERROR CONTINUE
      INSERT INTO audit_logix VALUES(p_audit_logix.*)
      WHENEVER ERROR STOP
      RETURN TRUE
 END IF
 END FUNCTION

#--------------------------------#
 FUNCTION vdp4283_busca_repres()
#--------------------------------#
 INITIALIZE p_cli_canal_venda.* TO NULL
 WHENEVER ERROR CONTINUE
 SELECT * INTO p_cli_canal_venda.*
   FROM cli_canal_venda
  WHERE cod_cliente      = p_pedido_dig_mest.cod_cliente
    AND cod_tip_carteira = p_pedido_dig_mest.cod_tip_carteira
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    CASE
         WHEN p_cli_canal_venda.ies_nivel = 1
              LET p_pedido_dig_mest.cod_repres = p_cli_canal_venda.cod_nivel_1
         WHEN p_cli_canal_venda.ies_nivel = 2
              LET p_pedido_dig_mest.cod_repres = p_cli_canal_venda.cod_nivel_2
         WHEN p_cli_canal_venda.ies_nivel = 3
              LET p_pedido_dig_mest.cod_repres = p_cli_canal_venda.cod_nivel_3
         WHEN p_cli_canal_venda.ies_nivel = 4
              LET p_pedido_dig_mest.cod_repres = p_cli_canal_venda.cod_nivel_4
         WHEN p_cli_canal_venda.ies_nivel = 5
              LET p_pedido_dig_mest.cod_repres = p_cli_canal_venda.cod_nivel_5
         WHEN p_cli_canal_venda.ies_nivel = 6
              LET p_pedido_dig_mest.cod_repres = p_cli_canal_venda.cod_nivel_6
         WHEN p_cli_canal_venda.ies_nivel = 7
              LET p_pedido_dig_mest.cod_repres = p_cli_canal_venda.cod_nivel_7
      END CASE
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF
END FUNCTION

#-----------------------------------------------------#
 FUNCTION vdp4283_verifica_repres(p_cod_repres,l_tipo)
#-----------------------------------------------------#
 DEFINE p_cod_repres    LIKE pedido_dig_mest.cod_repres,
        l_nom_repres    LIKE representante.nom_repres,
        l_situacao      LIKE representante.ies_situacao,
        l_tipo          SMALLINT

 IF p_cod_repres IS NULL THEN
    RETURN TRUE
 END IF

  CASE l_tipo
    WHEN 1
       IF p_cod_repres = p_pedido_dig_mest.cod_repres_adic OR
          p_cod_repres = m_cod_repres_3 THEN
          CALL log0030_mensagem( "Representante já cadastrado para o pedido. ","excl")
          RETURN FALSE
       END IF
    WHEN 2
       IF p_cod_repres = p_pedido_dig_mest.cod_repres OR
          p_cod_repres = m_cod_repres_3 THEN
          CALL log0030_mensagem( "Representante já cadastrado para o pedido. ","excl")
          RETURN FALSE
       END IF
    WHEN 3
       IF p_cod_repres = p_pedido_dig_mest.cod_repres OR
          p_cod_repres = p_pedido_dig_mest.cod_repres_adic THEN
          CALL log0030_mensagem( "Representante já cadastrado para o pedido. ","excl")
          RETURN FALSE
       END IF
 END CASE

 WHENEVER ERROR CONTINUE
 SELECT nom_repres, ies_situacao
   INTO l_nom_repres, l_situacao
   FROM representante
  WHERE cod_repres = p_cod_repres
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    IF l_situacao = "B" THEN
       CALL log0030_mensagem( " Representante Bloqueado ","excl")
       RETURN FALSE
    END IF
    RETURN TRUE
 ELSE
    IF l_tipo = 1 THEN
       CALL log0030_mensagem( "Representante não cadastrado ","excl")
    ELSE
       CALL log0030_mensagem( "Representante Adicional não cadastrado ","excl")
    END IF
    RETURN FALSE
 END IF
 END FUNCTION


#--------------------------------------#
FUNCTION vdp4283_verifica_repres_canal()
#--------------------------------------#
   DEFINE sql_stmt       CHAR(200),
          p_cod_campo    CHAR(50)

   CASE
      WHEN p_cli_canal_venda.ies_nivel = 1
           LET p_cod_campo = " cod_nivel_1 "

      WHEN p_cli_canal_venda.ies_nivel = 2
           LET p_cod_campo = " cod_nivel_2 "

      WHEN p_cli_canal_venda.ies_nivel = 3
           LET p_cod_campo = " cod_nivel_3 "

      WHEN p_cli_canal_venda.ies_nivel = 4
           LET p_cod_campo = " cod_nivel_4 "

      WHEN p_cli_canal_venda.ies_nivel = 5
           LET p_cod_campo = " cod_nivel_5 "

      WHEN p_cli_canal_venda.ies_nivel = 6
           LET p_cod_campo = " cod_nivel_6 "

      WHEN p_cli_canal_venda.ies_nivel = 7
           LET p_cod_campo = " cod_nivel_7 "
   END CASE

   LET sql_stmt =
       " SELECT ", p_cod_campo CLIPPED,
         " FROM cli_canal_venda ",
        " WHERE cod_cliente = """, p_pedido_dig_mest.cod_cliente, """ ",
          " AND ", p_cod_campo CLIPPED,
          " = """, p_pedido_dig_mest.cod_repres, """ "

   WHENEVER ERROR CONTINUE
   PREPARE var_query FROM sql_stmt
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("PREPARE","VAR_QUERY")
   END IF
   WHENEVER ERROR CONTINUE
   DECLARE cq_canal_venda CURSOR FOR var_query
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","cq_canal_venda")
   END IF

   WHENEVER ERROR CONTINUE
   OPEN cq_canal_venda
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("OPEN","cq_canal_venda")
   END IF

   WHENEVER ERROR CONTINUE
   FETCH cq_canal_venda
   IF sqlca.sqlcode = 100 THEN
      RETURN FALSE
   END IF
   RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION vdp4283_atualiza_prevprod()
#------------------------------------#
  WHENEVER ERROR CONTINUE
  UPDATE previsao_producao SET qtd_pedido = p_prev_producao.qtd_pedido
   WHERE previsao_producao.cod_empresa = p_cod_empresa
     AND previsao_producao.cod_item    = p_prev_producao.cod_item
     AND previsao_producao.num_semana  = p_prev_producao.num_semana
     AND previsao_producao.ano         = p_prev_producao.ano
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","previsao_producao")
      RETURN
   END IF

 END FUNCTION

#----------------------------------#
 FUNCTION vdp4283_insere_prevprod()
#----------------------------------#
  WHENEVER ERROR CONTINUE
    INSERT INTO previsao_producao VALUES(p_prev_producao.*)
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","previsao_producao")
      RETURN
   END IF
 END FUNCTION
################### PREVISAO - PRODUCAO - FIM    ###################

#-----------------------------#
FUNCTION vdp4283_help(l_status)
#-----------------------------#
   DEFINE l_status            SMALLINT

 CASE
    WHEN infield(num_pedido)         CALL SHOWHELP(3001)
    WHEN INFIELD(cod_tip_carteira)   CALL SHOWHELP(3350)
    WHEN INFIELD(parametro_texto)    CALL SHOWHELP(5817)
    WHEN infield(cod_nat_oper)       CALL SHOWHELP(3002)
    WHEN infield(dat_emis_repres)    CALL SHOWHELP(3003)
    WHEN infield(cod_cliente)
         IF l_status = 1 THEN
            CALL SHOWHELP(3004)
         ELSE
            CALL SHOWHELP(5708)
         END IF
    WHEN infield(cod_repres_3)       CALL SHOWHELP(3005)
    WHEN infield(cod_repres_adic)    CALL SHOWHELP(3005)
    WHEN infield(pct_comissao_2)     CALL SHOWHELP(3007)
    WHEN infield(pct_comissao_3)     CALL SHOWHELP(3007)
    WHEN infield(cod_repres)         CALL SHOWHELP(3005)
    WHEN infield(ies_comissao)       CALL SHOWHELP(3006)
    WHEN infield(ies_finalidade)     CALL SHOWHELP(3008)
    WHEN infield(num_list_preco)     CALL SHOWHELP(3010)
    WHEN infield(cod_cnd_pgto)       CALL SHOWHELP(3011)
    WHEN INFIELD(cod_tip_venda)      CALL SHOWHELP(3025)
    WHEN infield(pct_desc_financ)    CALL SHOWHELP(3012)
    WHEN infield(pct_desc_adic)      CALL SHOWHELP(3013)
    WHEN infield(num_pedido_cli)     CALL SHOWHELP(3014)
    WHEN INFIELD(num_pedido_repres)  CALL SHOWHELP(3015)
    WHEN infield(ies_frete)          CALL SHOWHELP(5681)
    WHEN infield(cod_transpor)       CALL SHOWHELP(3017)
    WHEN infield(cod_consig)         CALL SHOWHELP(3018)
    WHEN infield(ies_embal_padrao)   CALL SHOWHELP(3019)
    WHEN infield(ies_tip_entrega)    CALL SHOWHELP(5683)
    WHEN infield(pct_comissao)       CALL SHOWHELP(3007)
    WHEN infield(num_sequencia)      CALL SHOWHELP(3030)
    WHEN infield(end_entrega)        CALL SHOWHELP(3031)
    WHEN infield(den_bairro)         CALL SHOWHELP(3032)
    WHEN infield(cod_cidade)         CALL SHOWHELP(3033)
    WHEN infield(cod_cep)            CALL SHOWHELP(3034)
    WHEN infield(num_cgc)            CALL SHOWHELP(3035)
    WHEN infield(ins_estadual)       CALL SHOWHELP(3036)
    WHEN infield(tex_observ_1)       CALL SHOWHELP(3037)
    WHEN infield(tex_observ_2)       CALL SHOWHELP(3037)
    WHEN infield(preco)              CALL SHOWHELP(3040)
    WHEN infield(quantidade)         CALL SHOWHELP(3039)
    WHEN infield(cod_moeda)          CALL SHOWHELP(3026)
    WHEN infield(ies_incl_txt)       CALL SHOWHELP(3029)
    WHEN infield(texto_entrega)      CALL SHOWHELP(5682)
    WHEN infield(cod_local_estoq)    CALL SHOWHELP(3056)
    WHEN INFIELD(ies_txt_exped)      CALL SHOWHELP(5819) #E# - 469670
  END CASE

END FUNCTION
#-----------------------------#
 FUNCTION vdp4283_help_itens()
#-----------------------------#
  CASE
    WHEN infield(cod_item)           CALL showhelp(0038)
    WHEN infield(qtd_pecas_solic)    CALL showhelp(0039)
    WHEN infield(pre_unit)           CALL showhelp(0040)
    WHEN infield(pct_desc_adic)      CALL showhelp(0041)
    WHEN infield(prz_entrega)        CALL showhelp(0044)
#   WHEN infield(qtd_item_bonif)     CALL showhelp(0033)
    WHEN INFIELD(val_frete_unit)     CALL SHOWHELP(3043)
    WHEN INFIELD(val_seguro_unit)    CALL SHOWHELP(3042)
    WHEN infield(ies_incl_txt)       CALL showhelp(0045)
  END CASE
END FUNCTION

#----------------------------------#
 FUNCTION vdp4283_busca_num_pedido()
#----------------------------------#
 DEFINE p_num_pedido   LIKE pedido_dig_mest.num_pedido
 LET p_num_pedido = NULL
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT
 DECLARE cm_par_vdp CURSOR FOR
  SELECT num_prx_pedido
    FROM par_vdp
   WHERE par_vdp.cod_empresa = p_cod_empresa
 FOR UPDATE
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","cm_par_vdp")
    RETURN
 END IF

 CALL log085_transacao("BEGIN")
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("TRANSACAO","BEGIN")
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 OPEN cm_par_vdp
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("OPEN","cm_par_vdp")
    RETURN
 END IF
 WHENEVER ERROR CONTINUE
 FETCH cm_par_vdp INTO p_num_pedido
 WHENEVER ERROR STOP
 IF   sqlca.sqlcode = 0
 THEN
       WHENEVER ERROR CONTINUE
       UPDATE par_vdp
         SET num_prx_pedido = p_num_pedido + 1
       WHERE CURRENT OF cm_par_vdp
      WHENEVER ERROR STOP
      IF   sqlca.sqlcode <> 0
      THEN LET p_houve_erro = TRUE
           CALL log003_err_sql("ALTERACAO_1","PAR_VDP")
           CALL log085_transacao("ROLLBACK")
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("TRANSACAO","ROLLBACK")
              RETURN
           END IF
      ELSE CALL log085_transacao("COMMIT")
           IF   sqlca.sqlcode <> 0
           THEN LET p_houve_erro = TRUE
                CALL log003_err_sql("ALTERACAO_2","PAR_VDP")
                CALL log085_transacao("ROLLBACK")
                IF sqlca.sqlcode <> 0 THEN
                   CALL log003_err_sql("TRANSACAO","ROLLBACK")
                   RETURN
                END IF
           END IF
      END IF
 ELSE CALL log085_transacao("ROLLBACK")
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("TRANSACAO","ROLLBACK")
         RETURN
      END IF
 END IF
 CLOSE cm_par_vdp
 WHENEVER ERROR STOP
 RETURN p_num_pedido
 END FUNCTION

#-----------------------------------#
 FUNCTION vdp4283_verifica_pedido()
#-----------------------------------#
 WHENEVER ERROR CONTINUE
 SELECT * FROM pedidos
        WHERE num_pedido  = p_pedido_dig_mest.num_pedido
          AND cod_empresa = p_pedido_dig_mest.cod_empresa
 WHENEVER ERROR STOP
 IF   sqlca.sqlcode = NOTFOUND
 THEN
 ELSE RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT *  FROM pedidos_hist
        WHERE num_pedido  = p_pedido_dig_mest.num_pedido
          AND cod_empresa = p_pedido_dig_mest.cod_empresa
 WHENEVER ERROR STOP
 IF   sqlca.sqlcode = NOTFOUND
 THEN
 ELSE RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT * FROM pedido_dig_mest
        WHERE num_pedido  = p_pedido_dig_mest.num_pedido
          AND cod_empresa = p_pedido_dig_mest.cod_empresa
 WHENEVER ERROR STOP
 IF   sqlca.sqlcode = NOTFOUND
 THEN
 ELSE RETURN TRUE
 END IF

 RETURN FALSE
END FUNCTION

#-------------------------------------------#
 FUNCTION vdp4283_verifica_natureza_operacao()
#-------------------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT nat_operacao.ies_emite_dupl,
         nat_operacao.ies_tip_controle
    INTO p_ies_emite_dupl_nat,
         p_ies_tip_controle
    FROM nat_operacao
    WHERE nat_operacao.cod_nat_oper = p_pedido_dig_mest.cod_nat_oper
  IF sqlca.sqlcode = NOTFOUND
     THEN RETURN true
     ELSE RETURN false
  END IF
  WHENEVER ERROR STOP
END FUNCTION

#------------------------------------#
 FUNCTION vdp4283_verifica_cliente()
#------------------------------------#
 DEFINE p_ies_situacao    LIKE clientes.ies_situacao,
      	 p_tipo_cliente    RECORD LIKE tipo_cliente.*,
        p_cgc_cpf         CHAR(11),
        p_end_cliente     LIKE clientes.end_cliente,
        p_cod_cep         LIKE clientes.cod_cep,
        p_den_cidade      LIKE cidades.den_cidade,
        l_cod_cidade      LIKE cidades.cod_cidade,
        l_cod_consig      LIKE clientes.cod_consig

 WHENEVER ERROR CONTINUE
 LET p_cgc_cpf        = NULL

 SELECT   nom_cliente,   end_cliente,   cod_cep,   ies_situacao,   num_cgc_cpf,
          ins_estadual,   cod_cidade, cod_consig
   INTO p_nom_cliente, p_end_cliente, p_cod_cep, p_ies_situacao, p_num_cgc_cpf,
        p_ins_estadual, l_cod_cidade, l_cod_consig
   FROM clientes
  WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
 WHENEVER ERROR STOP
 IF   sqlca.sqlcode = NOTFOUND
 THEN CALL log0030_mensagem( " Cliente não cadastrado. ","excl")
      RETURN FALSE
 END IF
 WHENEVER ERROR CONTINUE
 SELECT   den_cidade,   cod_uni_feder
   INTO p_den_cidade, p_cod_uni_feder
   FROM cidades
  WHERE cod_cidade = l_cod_cidade
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
 END IF
 DISPLAY p_nom_cliente   TO nom_cliente
 DISPLAY p_end_cliente   TO end_cliente
 DISPLAY p_den_cidade    TO den_cidade
 DISPLAY p_cod_uni_feder TO cod_uni_feder
 DISPLAY p_cod_cep       TO cod_cep
 DISPLAY p_num_cgc_cpf   TO num_cgc_cpf
 DISPLAY p_ins_estadual  TO ins_estadual
 LET p_pedido_dig_mest.cod_consig = l_cod_consig
 DISPLAY p_pedido_dig_mest.cod_consig  TO cod_consig

 IF   p_ies_situacao = "A"
 THEN RETURN TRUE
 ELSE CALL log0030_mensagem( "Cliente cancelado ou suspenso","excl")
      RETURN FALSE
 END IF
END FUNCTION

#-------------------------------------#
 FUNCTION vdp4283_verifica_fiscal_par()
#-------------------------------------#

  IF m_consis_trib_pedido = "S" THEN
     IF NOT vdpr99_nova_funcao_fat() THEN
        IF NOT vdpr99_consiste_fiscal('',
                                       p_cod_empresa,
                                       TODAY,
                                       p_pedido_dig_mest.cod_nat_oper,
                                       p_pedido_dig_mest.cod_cliente,
                                       p_pedido_dig_mest.cod_tip_carteira,
                                       p_pedido_dig_mest.ies_finalidade,
                                       '', # Classificação fiscal
                                       '', # Unidade de medida busca do item
                                       'N',# Bonificação
                                       '', # item
                                       '', # linha de produto
                                       '', # linha de receita
                                       '', # segmento de mercado
                                       '', # classe de uso
                                       '', # Via de transporte
                                       'S',
                                       '',
                                       0) THEN

           RETURN FALSE
        END IF
     END IF
  END IF

 RETURN TRUE

 END FUNCTION

#---------------------------------#
 FUNCTION vdp4283_busca_cli_pgto()
#---------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT MAX(cli_cond_pgto.cod_cnd_pgto)
    INTO p_pedido_dig_mest.cod_cnd_pgto
    FROM cli_cond_pgto
   WHERE cli_cond_pgto.cod_cliente = p_pedido_dig_mest.cod_cliente
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF
  DISPLAY BY NAME p_pedido_dig_mest.cod_cnd_pgto

 END FUNCTION

#------------------------------------------#
 FUNCTION vdp4283_verifica_cnd_pagamento()
#------------------------------------------#
 DEFINE p_den_cnd_pgto            LIKE cond_pgto.den_cnd_pgto,
        p_ies_emite_dupl_cnd      CHAR(01)

 WHENEVER ERROR CONTINUE
 SELECT den_cnd_pgto,
        ies_emite_dupl,
        pct_desp_finan
   INTO p_den_cnd_pgto,
        p_ies_emite_dupl_cnd,
        p_pct_desp_finan
   FROM cond_pgto
  WHERE cond_pgto.cod_cnd_pgto = p_pedido_dig_mest.cod_cnd_pgto
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN

    CALL vdp1981_calcula_media(p_pedido_dig_mest.cod_cnd_pgto)
         RETURNING p_qtd_dias_media

 ELSE CALL log0030_mensagem( " Condição de pagamento não cadastrado. ","excl")
      RETURN TRUE
 END IF
 DISPLAY p_den_cnd_pgto TO den_cnd_pgto
 IF   p_ies_emite_dupl_cnd = p_ies_emite_dupl_nat
 THEN RETURN  FALSE
 ELSE CALL log0030_mensagem( "Cond. de pgto incompatível com a natureza da operação","excl")
      RETURN TRUE
 END IF
 WHENEVER ERROR STOP
 END FUNCTION

#------------------------------------#
 FUNCTION vdp4283_verifica_tipo_venda()
#------------------------------------#
  WHENEVER ERROR CONTINUE

  SELECT cod_tip_venda FROM tipo_venda
   WHERE tipo_venda.cod_tip_venda = p_pedido_dig_mest.cod_tip_venda
  WHENEVER ERROR STOP
  IF   sqlca.sqlcode = NOTFOUND
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF

  WHENEVER ERROR STOP
END FUNCTION

#----------------------------------#
 FUNCTION vdp4283_verifica_moeda()
#----------------------------------#
 DEFINE p_den_moeda    LIKE moeda.den_moeda

  WHENEVER ERROR CONTINUE
 SELECT den_moeda  INTO p_den_moeda
   FROM moeda
  WHERE cod_moeda = p_pedido_dig_mest.cod_moeda
  WHENEVER ERROR STOP

 IF sqlca.sqlcode = NOTFOUND THEN
    RETURN FALSE
 ELSE
    DISPLAY p_den_moeda TO den_moeda
    RETURN TRUE
 END IF

 END FUNCTION

#--------------------------------#
 FUNCTION vdp4283_verifica_cidade()
#--------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT cod_cidade FROM cidades
   WHERE cidades.cod_cidade = p_pedido_dig_ent.cod_cidade
  WHENEVER ERROR STOP

  IF sqlca.sqlcode = NOTFOUND THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF

  WHENEVER ERROR STOP

END FUNCTION

#---------------------------------#
 FUNCTION vdp4283_verifica_item_repres()
#---------------------------------#
  DEFINE p_cod_item        LIKE item_vdp.cod_item

  WHENEVER ERROR CONTINUE

  SELECT item_repres.cod_item INTO p_cod_item
    FROM item, item_vdp, item_embalagem, item_repres
    WHERE item_repres.cod_empresa      = p_cod_empresa
      AND item_repres.cod_item_repres  = t_pedido_dig_item[pa_curr].cod_item
      AND item.cod_empresa             = p_cod_empresa
      AND item_vdp.cod_empresa         = p_cod_empresa
      AND item_repres.cod_item         = item_vdp.cod_item
      AND item.cod_item                = item_repres.cod_item
      AND item_embalagem.cod_item      = item_vdp.cod_item
      AND item_embalagem.cod_empresa   = item_vdp.cod_empresa
      AND (item_embalagem.ies_tip_embal = "N" OR
	   item_embalagem.ies_tip_embal = "I")
  WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0
   THEN
      WHENEVER ERROR CONTINUE
      SELECT item_repres.cod_item
         INTO p_cod_item
         FROM item, item_vdp, item_embalagem, item_repres
         WHERE item_repres.cod_empresa      = p_cod_empresa
           AND item_repres.cod_item_repres  = t_pedido_dig_item[pa_curr].cod_item
           AND item.cod_empresa             = p_cod_empresa
           AND item_vdp.cod_empresa         = p_cod_empresa
           AND item_repres.cod_item         = item_vdp.cod_item
           AND item.cod_item                = item_repres.cod_item
           AND item_embalagem.cod_item      = item_vdp.cod_item
           AND item_embalagem.cod_empresa   = item_vdp.cod_empresa
           AND (item_embalagem.ies_tip_embal = "C" OR
	        item_embalagem.ies_tip_embal = "E")
        WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
           ELSE
             LET t_pedido_dig_item[pa_curr].cod_item = p_cod_item
           END IF
     ELSE
        LET t_pedido_dig_item[pa_curr].cod_item = p_cod_item
     END IF

END FUNCTION

#---------------------------------#
 FUNCTION vdp4283_verifica_item()
#---------------------------------#
 DEFINE      p_ies_situacao    LIKE item.ies_situacao,
             p_qtd_padr_embal  LIKE item_embalagem.qtd_padr_embal,
             p_quantidade      INTEGER,
             p_pre_unit_liq    LIKE item_vdp.pre_unit_brut,
             p_pre_unit_bruto  LIKE item_vdp.pre_unit_brut,
             p_desc_bruto_tab  LIKE desc_preco_item.pct_desc,
             p_pre_unit_tab    LIKE desc_preco_item.pre_unit,
             p_desc_adic_tab   LIKE desc_preco_item.pct_desc_adic,
             p_cod_lin_prod    LIKE item.cod_lin_prod,
             p_cod_lin_recei   LIKE item.cod_lin_recei,
             p_cod_seg_merc    LIKE item.cod_seg_merc,
             p_cod_cla_uso     LIKE item.cod_cla_uso,
             p_cod_item        LIKE item_vdp.cod_item,
             p_den_item        LIKE item.den_item

  DEFINE l_cod_cla_fisc        LIKE item.cod_cla_fisc

  WHENEVER ERROR CONTINUE
  SELECT item.cod_item,
         item.ies_situacao,
         item_vdp.pre_unit_brut,
         item.pct_ipi,
         item.cod_lin_prod,
         item.cod_lin_recei,
         item.cod_seg_merc,
         item.cod_cla_uso,
         item.den_item,
         item.cod_cla_fisc
    INTO p_cod_item,
         p_ies_situacao,
         p_pre_unit_bruto,
         p_pct_ipi,
         p_cod_lin_prod,
         p_cod_lin_recei,
         p_cod_seg_merc,
         p_cod_cla_uso,
         p_den_item,
         l_cod_cla_fisc
    FROM item, item_vdp
    WHERE item.cod_item        = t_pedido_dig_item[pa_curr].cod_item
      AND item.cod_item        = item_vdp.cod_item
      AND item.cod_empresa     = p_cod_empresa
      AND item_vdp.cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF   sqlca.sqlcode = NOTFOUND
  THEN CALL log0030_mensagem( " Produto não cadastrado ","excl")
       LET p_status = 0
       RETURN  p_status, p_qtd_padr_embal
  END IF
  DISPLAY p_den_item TO den_item

  IF vdpr99_encontra_fiscal('ICMS',
                            p_cod_empresa,
                            TODAY,
                            p_pedido_dig_mest.cod_nat_oper,
                            p_pedido_dig_mest.cod_cliente,
                            p_pedido_dig_mest.cod_tip_carteira,
                            p_pedido_dig_mest.ies_finalidade,
                            l_cod_cla_fisc, # Classificação fiscal
                            '', # Unidade de medida busca do item
                            'N',# Bonificação
                            t_pedido_dig_item[pa_curr].cod_item, # item
                            p_cod_lin_prod, # linha de produto
                            p_cod_lin_recei, # linha de receita
                            p_cod_seg_merc, # segmento de mercado
                            p_cod_cla_uso, # classe de uso
                            '', # Via de transporte
                            'S',
                            p_pedido_dig_ent.cod_cidade,
                            1) THEN
     LET p_pct_icm                = vdpr99_fiscal_get_aliquota()
  ELSE
     LET p_pct_icm  = 0
  END IF
  IF vdpr99_encontra_fiscal('IPI',
                             p_cod_empresa,
                             TODAY,
                             p_pedido_dig_mest.cod_nat_oper,
                             p_pedido_dig_mest.cod_cliente,
                             p_pedido_dig_mest.cod_tip_carteira,
                             p_pedido_dig_mest.ies_finalidade,
                             l_cod_cla_fisc, # Classificação fiscal
                             '', # Unidade de medida busca do item
                             'N',# Bonificação
                             t_pedido_dig_item[pa_curr].cod_item, # item
                             p_cod_lin_prod, # linha de produto
                             p_cod_lin_recei, # linha de receita
                             p_cod_seg_merc, # segmento de mercado
                             p_cod_cla_uso, # classe de uso
                             '', # Via de transporte
                             'S',
                             p_pedido_dig_ent.cod_cidade,
                             1) THEN

     LET p_ies_incid_ipi = vdpr99_fiscal_get_incidencia()
  ELSE
     LET p_ies_incid_ipi = 0
  END IF

  IF p_ies_incid_ipi <> 1 THEN
     LET p_pct_ipi = 0
  END IF

  IF   p_ies_situacao = "A"  THEN
  ELSE CALL log0030_mensagem( "Produto cancelado","excl")
       LET p_status = 0
       RETURN  p_status, p_qtd_padr_embal
  END IF

  IF vdp4283_existe_nat_oper_refer() THEN
     IF NOT vdp4283_existe_fiscal_par(l_cod_cla_fisc,p_cod_lin_prod,p_cod_lin_recei,p_cod_seg_merc,p_cod_cla_uso) THEN
        LET p_status = 0
        RETURN p_status, p_qtd_padr_embal
     END IF
  END IF

  CALL vdp4283_mostra_estoque(t_pedido_dig_item[pa_curr].cod_item)
  IF   p_pedido_dig_mest.ies_embal_padrao = "1"
  THEN
       WHENEVER ERROR CONTINUE
       SELECT qtd_padr_embal
         INTO p_qtd_padr_embal
         FROM item_embalagem
        WHERE item_embalagem.cod_empresa = p_cod_empresa
          AND item_embalagem.cod_item    = t_pedido_dig_item[pa_curr].cod_item
          AND item_embalagem.ies_tip_embal IN ("N","I")
        WHENEVER ERROR STOP
         IF   sqlca.sqlcode = NOTFOUND
         THEN CALL log0030_mensagem( "Item não cadastrado na tabela item_embalagem","excl")
              LET p_status = 0
              RETURN p_status, p_qtd_padr_embal
         END IF
  ELSE IF   p_pedido_dig_mest.ies_embal_padrao = "2"
       THEN
             WHENEVER ERROR CONTINUE
             SELECT qtd_padr_embal
              INTO p_qtd_padr_embal
              FROM item_embalagem
             WHERE item_embalagem.cod_empresa = p_cod_empresa
               AND item_embalagem.cod_item    = t_pedido_dig_item[pa_curr].cod_item
               AND item_embalagem.ies_tip_embal IN ("E","C")
             WHENEVER ERROR STOP
               IF   sqlca.sqlcode = NOTFOUND
               THEN CALL log0030_mensagem( "Item não cadastrado na tabela item_embalagem","excl")
                    LET p_status = 0
                    RETURN p_status, p_qtd_padr_embal
               END IF
        END IF
  END IF
  IF   p_pedido_dig_mest.num_list_preco = 0 OR
       p_pedido_dig_mest.num_list_preco IS NULL OR
       p_pedido_dig_mest.num_list_preco = "    "
  THEN
  ELSE CALL vdp1499_busca_preco_lista(p_cod_empresa,
                                      p_pedido_dig_mest.num_list_preco,
                                      p_pedido_dig_mest.cod_cliente,p_cod_item,
                                      p_cod_lin_prod,
                                      p_cod_lin_recei,
                                      p_cod_seg_merc,
                                      p_cod_cla_uso,
                                      0,0,0,
                                      p_cod_uni_feder)
                                      RETURNING p_status,
                                                p_desc_bruto_tab,
                                                p_desc_adic_tab,
                                                p_pre_unit_tab

       IF   p_status = 0
       THEN IF p_pre_unit_tab > 0
            THEN LET t_pedido_dig_item[pa_curr].pre_unit = p_pre_unit_tab
                 IF t_pedido_dig_item[pa_curr].pct_desc_adic  = 0 OR
                    t_pedido_dig_item[pa_curr].pct_desc_adic  IS NULL
                 THEN LET t_pedido_dig_item[pa_curr].pct_desc_adic  = p_desc_adic_tab
                 END IF
                 DISPLAY t_pedido_dig_item[pa_curr].pre_unit TO s_pedido_dig_item[sc_curr].pre_unit
                 DISPLAY t_pedido_dig_item[pa_curr].pct_desc_adic  TO s_pedido_dig_item[sc_curr].pct_desc_adic

            ELSE CALL vdp4283_calcula_pre_unit(p_pre_unit_bruto,
                                              p_desc_bruto_tab)
                      RETURNING t_pedido_dig_item[pa_curr].pre_unit
                 IF t_pedido_dig_item[pa_curr].pct_desc_adic  = 0 OR
                    t_pedido_dig_item[pa_curr].pct_desc_adic  IS NULL
                 THEN LET t_pedido_dig_item[pa_curr].pct_desc_adic  = p_desc_adic_tab
                 END IF
                 DISPLAY t_pedido_dig_item[pa_curr].pre_unit TO s_pedido_dig_item[sc_curr].pre_unit
                 DISPLAY t_pedido_dig_item[pa_curr].pct_desc_adic  TO s_pedido_dig_item[sc_curr].pct_desc_adic
            END IF
       ELSE CALL log0030_mensagem( "Produto não cadastrado na lista de preço","excl")
            LET p_status = 0
            RETURN  p_status, p_qtd_padr_embal
       END  IF
  END  IF
  IF   t_pedido_dig_item[pa_curr].pre_unit = 0
  THEN IF   p_pedido_dig_mest.num_list_preco = 0 OR
            p_pedido_dig_mest.num_list_preco IS NULL OR
            p_pedido_dig_mest.num_list_preco = "    "
       THEN LET p_status = 1
       ELSE CALL log0030_mensagem( "Produto não cadastrado na lista de preço","excl")
            LET p_status = 0
       END IF
  ELSE LET p_status = 1
  END IF
 RETURN p_status, p_qtd_padr_embal

 WHENEVER ERROR STOP

END FUNCTION

#-----------------------------------------#
 FUNCTION vdp4283_verifica_valor_pedido()
#-----------------------------------------#
  DEFINE  p_pre_unit_liq    LIKE item_vdp.pre_unit_brut,
          p_val_cotacao     LIKE cotacao_mes.val_cotacao,
          p_pct_desc_m      LIKE pedidos.pct_desc_adic,
          p_pct_desc_i      LIKE ped_itens.pct_desc_adic,
          p_dep             SMALLINT

  IF p_pedido_dig_mest.cod_moeda > 0 THEN
     WHENEVER ERROR CONTINUE
     SELECT val_cotacao
       INTO p_val_cotacao
       FROM cotacao
      WHERE cotacao.cod_moeda = p_pedido_dig_mest.cod_moeda
       AND cotacao.dat_ref   = TODAY
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
     ELSE
        OPEN WINDOW w_vdp42839 AT 10,10 WITH 5 ROWS, 30 COLUMNS
             ATTRIBUTE(BORDER, PROMPT LINE LAST)
        DISPLAY "Cotacao da moeda ", p_pedido_dig_mest.cod_moeda  AT 1,1
         DISPLAY " para a data corrente nao ca-" AT 2,1
         DISPLAY "dastrada na tabela cotacao" AT  3,1
        ERROR " "
        PROMPT "Tecle ENTER para continuar" FOR p_comando
        CLOSE WINDOW w_vdp42839
        LET p_status = 1
   #     RETURN  p_status
     END IF
  ELSE
     LET p_val_cotacao = 1
  END IF
  LET p_status = 0
  LET p_valor_pedido = 0
  IF p_ies_emite_dupl_nat               = "S" THEN
#    p_pedido_dig_mest.ies_aceite_finan = "N" THEN
     FOR p_dep = 1 to pa_curr
         LET p_pre_unit_liq = t_pedido_dig_item[p_dep].pre_unit *
                              p_val_cotacao
         CALL vdp4283_busca_desc_adic_unico(0,
                                            p_pedido_dig_mest.pct_desc_adic)
         RETURNING p_pct_desc_m
         CALL vdp4283_calcula_pre_unit(p_pre_unit_liq,
                                      p_pct_desc_m)
         RETURNING p_pre_unit_liq
         CALL vdp4283_busca_desc_adic_unico(p_dep,
                                        t_pedido_dig_item[p_dep].pct_desc_adic)
         RETURNING p_pct_desc_i
         CALL vdp4283_calcula_pre_unit(p_pre_unit_liq,
                                      p_pct_desc_i)
         RETURNING p_pre_unit_liq

         LET p_valor_pedido = p_valor_pedido + (t_pedido_dig_item[p_dep].qtd_pecas_solic *
                                                p_pre_unit_liq)
         IF (p_valor_pedido + p_val_dup_aberto + p_val_ped_carteira) >
             p_val_limite_cred_cruz THEN
             OPEN WINDOW w_vdp42838 AT 10,30 WITH 6 ROWS, 40 COLUMNS
                  ATTRIBUTE(BORDER, PROMPT LINE LAST)
              DISPLAY "Item excede ao limite de credito  "          AT 1,1
              DISPLAY "do  cliente.                  "              AT 2,1
              DISPLAY "Limite de credito ", p_val_limite_cred_cruz  AT 3,1
              DISPLAY "Duplicatas abertas ", p_val_dup_aberto       AT 4,1
              DISPLAY "Valor do pedido ate o item ", p_valor_pedido AT 5,1
             ERROR " "
             PROMPT "Tecle ENTER para continuar" FOR p_comando
             CLOSE WINDOW w_vdp42838

             LET p_status = 1
             LET p_erro[7] = "1"
             EXIT FOR
         ELSE LET p_erro[7] = "0"
         END IF
       END FOR
   END IF
#   RETURN  p_status
END FUNCTION


#-----------------------------------#
 FUNCTION vdp4283_efetiva_inclusao()
#-----------------------------------#
 CALL vdp4283_inclui_mestre()
 CALL vdp4283_insert_ped_list()

 IF   p_pedido_dig_ent.end_entrega IS NOT NULL
 THEN CALL vdp4283_inclui_end_entr()
 END IF

 IF   p_pedido_dig_obs.tex_observ_1 IS NOT NULL
 THEN CALL vdp4283_inclui_observ()
 END IF

 CALL vdp4283_inclui_itens()
 CALL vdp4283_inclui_itens_bnf()
 CALL vdp4283_inclui_grade()
 CALL vdp4283_inclui_texto()
 CALL vdp4283_inclui_ped_itens_desc()
 CALL vdp4283_inclui_vendor_pedido()
 CALL vdp4283_inclui_pedido_comis()

 CALL vdp4283_inclui_ped_info_compl()
 CALL vdp4283_inclui_ped_info_compl_consig_ad()

END FUNCTION
#------------------------------------------------#
FUNCTION vdp4283_abre_tela_consig_adicional()
#------------------------------------------------#
   DEFINE l_ind SMALLINT


   WHENEVER ERROR CONTINUE
     CALL log130_procura_caminho("vdp4134d") RETURNING p_nom_tela
     OPEN WINDOW w_vdp4134d AT 2,02 WITH FORM p_nom_tela
     ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   WHENEVER ERROR STOP
   DISPLAY p_cod_empresa                 TO cod_empresa
   LET int_flag = 0

   IF pa_count > 0 THEN
      CALL SET_COUNT(pa_count)
   END IF

   INPUT ARRAY ma_tela_consig_ad WITHOUT DEFAULTS FROM s_consig_ad.*

      BEFORE ROW
         LET pa_curr  = arr_curr()
         LET sc_curr  = scr_line()
         LET pa_count = arr_count()

      BEFORE FIELD cod_consig
         CALL vdp4283_mostra_zoom()

      AFTER FIELD cod_consig

         IF ma_tela_consig_ad[pa_curr].cod_consig IS NOT NULL AND
            ma_tela_consig_ad[pa_curr].cod_consig <> " " THEN
            CALL vdpr15_valida_transportadora(ma_tela_consig_ad[pa_curr].cod_consig,1) RETURNING p_status, m_transp_inat
            IF NOT p_status THEN
               IF m_transp_inat = 1 THEN
                  CALL log0030_mensagem(" Consignatário cancelado ou suspenso.", "exclamation")
               ELSE
                  CALL log0030_mensagem (" Consignatário não cadastrado.","exclamation")
               END IF
               NEXT FIELD cod_consig
            ELSE
               CALL vdpm52_transport_leitura(ma_tela_consig_ad[pa_curr].cod_consig, FALSE, TRUE )
                  RETURNING p_status
               IF p_status THEN
                  CALL vdpm52_transport_get_den_transpor() RETURNING ma_tela_consig_ad[pa_curr].den_consig
               END IF

               IF p_status = FALSE THEN
                  IF vdpm7_clientes_leitura(ma_tela_consig_ad[pa_curr].cod_consig, FALSE, TRUE) THEN
                     CALL vdpm7_clientes_get_nom_cliente() RETURNING ma_tela_consig_ad[pa_curr].den_consig
                  END IF
               END IF
               DISPLAY ma_tela_consig_ad[pa_curr].den_consig TO s_consig_ad[sc_curr].den_consig
            END IF
            IF vdp4283_verifica_dupl_array() THEN
              CALL log0030_mensagem("Consignatário já incluido para este pedido.", "exclamation")
              NEXT FIELD cod_consig
            END IF
         END IF

         IF ma_tela_consig_ad[pa_curr].cod_consig    IS NULL AND
            ma_tela_consig_ad[pa_curr].cod_tip_frete IS NOT NULL THEN
            CALL log0030_mensagem("Consignatário não preenchido.", "exclamation")
            NEXT FIELD cod_consig
         END IF
         CALL vdp4283_apaga_zoom()

      BEFORE FIELD cod_tip_frete
         CALL vdp4283_mostra_zoom()

      AFTER FIELD cod_tip_frete
         #E# - 530071
         IF  ma_tela_consig_ad[pa_curr].cod_consig IS NOT NULL AND
             ma_tela_consig_ad[pa_curr].cod_consig <> ' '      THEN
             IF ma_tela_consig_ad[pa_curr].cod_tip_frete = 1 OR ma_tela_consig_ad[pa_curr].cod_tip_frete = 2 OR
                ma_tela_consig_ad[pa_curr].cod_tip_frete = 3 OR ma_tela_consig_ad[pa_curr].cod_tip_frete = 4 OR
                ma_tela_consig_ad[pa_curr].cod_tip_frete = 5 THEN
             ELSE
                CALL log0030_mensagem("Tipo de frete não cadastrado.", "exclamation")
                NEXT FIELD cod_tip_frete
             END IF
         END IF

         CASE
            WHEN ma_tela_consig_ad[pa_curr].cod_tip_frete = "1"
                 LET ma_tela_consig_ad[pa_curr].den_tip_frete = "CIF Pago"
                 DISPLAY ma_tela_consig_ad[pa_curr].den_tip_frete TO s_consig_ad[sc_curr].den_tip_frete
            WHEN ma_tela_consig_ad[pa_curr].cod_tip_frete = "2"
                 LET ma_tela_consig_ad[pa_curr].den_tip_frete = "CIF Cobrado"
                 DISPLAY ma_tela_consig_ad[pa_curr].den_tip_frete TO s_consig_ad[sc_curr].den_tip_frete
            WHEN ma_tela_consig_ad[pa_curr].cod_tip_frete = "3"
                 LET ma_tela_consig_ad[pa_curr].den_tip_frete = "FOB"
                 DISPLAY ma_tela_consig_ad[pa_curr].den_tip_frete TO s_consig_ad[sc_curr].den_tip_frete
            WHEN ma_tela_consig_ad[pa_curr].cod_tip_frete = "4"
                 LET ma_tela_consig_ad[pa_curr].den_tip_frete = "CIF Inf Pct"
                 DISPLAY ma_tela_consig_ad[pa_curr].den_tip_frete TO s_consig_ad[sc_curr].den_tip_frete
            WHEN ma_tela_consig_ad[pa_curr].cod_tip_frete = "5"
                 LET ma_tela_consig_ad[pa_curr].den_tip_frete = "CIF Inf Unt"
                 DISPLAY ma_tela_consig_ad[pa_curr].den_tip_frete TO s_consig_ad[sc_curr].den_tip_frete
         END CASE

         IF ma_tela_consig_ad[pa_curr].cod_consig    IS NOT NULL AND
            ma_tela_consig_ad[pa_curr].cod_tip_frete IS NULL THEN
            CALL log0030_mensagem("Tipo de frete não preenchido.", "exclamation")
            NEXT FIELD cod_tip_frete
         END IF
         IF ma_tela_consig_ad[pa_curr].cod_consig    IS NULL     AND
            ma_tela_consig_ad[pa_curr].cod_tip_frete IS NOT NULL THEN
           CALL log0030_mensagem("Consignatário não preenchido.", "exclamation")
           NEXT FIELD cod_consig
         END IF
         CALL vdp4283_apaga_zoom()

      AFTER INPUT
        LET pa_count = arr_count()

        IF int_flag = 0 THEN
            FOR l_ind = 1 TO 100
               IF  ma_tela_consig_ad[l_ind].cod_consig    IS NULL AND
                   ma_tela_consig_ad[l_ind].cod_tip_frete IS NULL THEN
                   EXIT FOR
               END IF

               IF (ma_tela_consig_ad[l_ind].cod_consig     IS NULL      AND
                   ma_tela_consig_ad[l_ind].cod_tip_frete  IS NOT NULL) OR
                  (ma_tela_consig_ad[l_ind].cod_consig     IS NOT NULL  AND
                   ma_tela_consig_ad[l_ind].cod_tip_frete  IS NULL)     THEN
                  IF ma_tela_consig_ad[l_ind].cod_consig    IS NULL AND
                     ma_tela_consig_ad[l_ind].cod_tip_frete IS NOT NULL THEN
                     CALL log0030_mensagem("Consignatário não preenchido.", "exclamation")
                     NEXT FIELD cod_consig
                  END IF
                  IF ma_tela_consig_ad[l_ind].cod_consig    IS NOT NULL AND
                     ma_tela_consig_ad[l_ind].cod_tip_frete IS NULL THEN
                     CALL log0030_mensagem("Tipo de frete não preenchido.", "exclamation")
                     NEXT FIELD cod_tip_frete
                  END IF
               END IF
            END FOR
         END IF

      ON KEY (control-w, f1)
         #lds IF NOT LOG_logix_versao5() THEN
         #lds CONTINUE INPUT
         #lds END IF
         CALL vdp4283_help_consig_ad()

      ON KEY (control-z, f4)
         CALL vdp4283_popup_consig_ad()

   END INPUT

   CLOSE WINDOW w_vdp4134d
   CURRENT WINDOW IS w_vdp4283

   IF int_flag = 0 THEN
      RETURN TRUE
   ELSE
      LET int_flag = 0
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION vdp4283_popup_consig_ad()
#----------------------------------#
  DEFINE l_cod_consig    LIKE transport.cod_transpor

  CASE
    WHEN INFIELD(cod_consig)
         LET l_cod_consig = vdp3362_popup_cliente("T")
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF l_cod_consig IS NOT NULL THEN
           LET ma_tela_consig_ad[pa_curr].cod_consig = l_cod_consig
         ELSE
           LET ma_tela_consig_ad[pa_curr].cod_consig = " "
         END IF
         DISPLAY ma_tela_consig_ad[pa_curr].cod_consig TO s_consig_ad[sc_curr].cod_consig

    WHEN INFIELD(cod_tip_frete)
         IF NOT find4glfunction('vdpy57_preve_tip_frete_6') THEN
             LET ma_tela_consig_ad[pa_curr].cod_tip_frete = log0830_list_box(08,52,
                 '1 {CIF Pago}, 2 {CIF Cobrado}, 3 {FOB}, 4 {CIF Infor. Pct.}, 5 {CIF Infor. Unit.}')
             DISPLAY ma_tela_consig_ad[pa_curr].cod_tip_frete TO s_consig_ad[sc_curr].cod_tip_frete
         ELSE
             LET ma_tela_consig_ad[pa_curr].cod_tip_frete = log0830_list_box(08,52,
                 '1 {CIF Pago}, 2 {CIF Cobrado}, 3 {FOB}, 4 {CIF Infor. Pct.}, 5 {CIF Infor. Unit.}, 6 {Item Tot.}')
             DISPLAY ma_tela_consig_ad[pa_curr].cod_tip_frete TO s_consig_ad[sc_curr].cod_tip_frete
         END IF
 END CASE
END FUNCTION

#--------------------------------#
 FUNCTION vdp4283_help_consig_ad()
#--------------------------------#
  CASE
    WHEN INFIELD(cod_consig)    CALL SHOWHELP(177)
    WHEN INFIELD(cod_tip_frete) CALL SHOWHELP(121)
  END CASE
END FUNCTION

#-------------------------------------------------#
 FUNCTION vdp4283_inclui_ped_info_compl_consig_ad()
#-------------------------------------------------#
  DEFINE  l_ind   INTEGER
  DEFINE  l_campo CHAR(30)
  FOR l_ind = 1 TO 100
    IF ma_tela_consig_ad[l_ind].cod_consig IS NOT NULL THEN
      LET l_campo = 'CONSIGNATARIO ', l_ind USING "<<&"

      LET mr_ped_info_compl_frete.empresa         = p_cod_empresa
      LET mr_ped_info_compl_frete.pedido          = p_pedido_dig_mest.num_pedido
      LET mr_ped_info_compl_frete.campo           = l_campo
      LET mr_ped_info_compl_frete.par_existencia  = NULL
      LET mr_ped_info_compl_frete.parametro_texto = ma_tela_consig_ad[l_ind].cod_consig
      LET mr_ped_info_compl_frete.parametro_val   = NULL
      LET mr_ped_info_compl_frete.parametro_qtd   = ma_tela_consig_ad[l_ind].cod_tip_frete
      LET mr_ped_info_compl_frete.parametro_dat   = NULL

      CALL vdpm64_ped_info_compl_set_null()
      CALL vdpm64_ped_info_compl_set_empresa(mr_ped_info_compl_frete.empresa)
      CALL vdpm64_ped_info_compl_set_pedido(mr_ped_info_compl_frete.pedido)
      CALL vdpm64_ped_info_compl_set_campo(mr_ped_info_compl_frete.campo)
      CALL vdpm64_ped_info_compl_set_par_existencia(mr_ped_info_compl_frete.par_existencia)
      CALL vdpm64_ped_info_compl_set_parametro_texto(mr_ped_info_compl_frete.parametro_texto)
      CALL vdpm64_ped_info_compl_set_parametro_val(mr_ped_info_compl_frete.parametro_val)
      CALL vdpm64_ped_info_compl_set_parametro_qtd(mr_ped_info_compl_frete.parametro_qtd)
      CALL vdpm64_ped_info_compl_set_parametro_dat(mr_ped_info_compl_frete.parametro_dat)

      IF NOT vdpt64_ped_info_compl_inclui(TRUE,1) THEN
         LET m_msg_erro = log0030_mensagem_get_texto()
         LET p_houve_erro = TRUE
         ERROR m_msg_erro
         SLEEP 5
      END IF
    ELSE
      EXIT FOR
    END IF
  END FOR
END FUNCTION
#------------------------------------#
FUNCTION vdp4283_verifica_dupl_array()
#------------------------------------#
  DEFINE l_ind SMALLINT
  FOR l_ind = 1 TO 100
    IF ma_tela_consig_ad[l_ind].cod_consig IS NOT NULL THEN
      IF ma_tela_consig_ad[l_ind].cod_consig = ma_tela_consig_ad[pa_curr].cod_consig AND
         l_ind <> pa_curr THEN
        RETURN TRUE
      END IF
    ELSE
      EXIT FOR
    END IF
  END FOR
  RETURN FALSE
END FUNCTION

#----------------------------------------#
 FUNCTION vdp4283_inclui_ped_info_compl()
#----------------------------------------#
     WHENEVER ERROR CONTINUE
       INSERT INTO ped_info_compl (empresa,
                                   pedido,
                                   campo,
                                   parametro_texto)
                           VALUES (p_cod_empresa,
                                   p_pedido_dig_mest.num_pedido,
                                   'linha_produto',
                                   m_linha_produto)
     WHENEVER ERROR STOP

     IF  SQLCA.sqlcode <> 0 THEN
         LET p_houve_erro = TRUE
         CALL log003_err_sql("INCLUSAO","PED_INFO_COMPL")
     END IF

     #E# - 469670
     IF  NOT vdpy154_grava_txt_obs_exped(p_pedido_dig_mest.num_pedido) THEN
         LET p_houve_erro = TRUE
     END IF
     #E# - 469670

 END FUNCTION

#--------------------------------#
 FUNCTION vdp4283_popup(p_status)
#--------------------------------#
DEFINE  p_cod_transpor    LIKE transport.cod_transpor,
        l_den_transpor    LIKE transport.den_transpor,
        p_cod_repres      LIKE representante.cod_repres,
        p_cod_consig      LIKE transport.cod_transpor,
        l_den_consig      LIKE transport.den_transpor,
        p_cod_repres_adic LIKE representante.cod_repres,
        p_lista_preco     LIKE desc_preco_mest.num_list_preco,
        p_cod_cliente     LIKE clientes.cod_cliente,
        p_cod_item_pe     LIKE item.cod_item ,
        p_oper            LIKE nat_operacao.cod_nat_oper,
        p_filtro          CHAR(100),
        p_status          SMALLINT
 CASE
    WHEN infield(cod_tip_carteira)
         CALL log009_popup(6,25,"TIPO CARTEIRA","tipo_carteira",
                          "cod_tip_carteira","den_tip_carteira",
                          "vdp6310","N","") RETURNING p_pedido_dig_mest.cod_tip_carteira
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         DISPLAY BY NAME p_pedido_dig_mest.cod_tip_carteira
    WHEN infield(cod_nat_oper)
         LET g_cod_cliente = p_pedido_dig_mest.cod_cliente
         LET p_oper = vdp2273_popup_nat_oper()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         IF p_oper IS NOT NULL THEN
            LET p_pedido_dig_mest.cod_nat_oper = p_oper
            DISPLAY p_pedido_dig_mest.cod_nat_oper TO cod_nat_oper
         END IF
    WHEN infield(cod_cliente)
         LET p_cod_cliente = vdp3362_popup_cliente("C")
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         IF p_cod_cliente IS NOT NULL
         THEN  LET p_pedido_dig_mest.cod_cliente = p_cod_cliente
               DISPLAY p_pedido_dig_mest.cod_cliente TO cod_cliente
         END IF
    WHEN infield(cod_transpor)
         LET  p_pedido_dig_mest.cod_transpor = vdp3362_popup_cliente("T")
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         LET l_den_transpor = " "
         WHENEVER ERROR CONTINUE
         SELECT den_transpor
           INTO l_den_transpor
           FROM transport
          WHERE cod_transpor = p_pedido_dig_mest.cod_transpor
         WHENEVER ERROR STOP
         IF sqlca.sqlcode = NOTFOUND THEN
            WHENEVER ERROR CONTINUE
            SELECT nom_cliente
              INTO l_den_transpor
              FROM clientes
             WHERE cod_cliente = p_pedido_dig_mest.cod_transpor
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
               LET l_den_transpor = " "
            END IF
         END IF
         DISPLAY BY NAME p_pedido_dig_mest.cod_transpor
         DISPLAY l_den_transpor TO den_transpor
    WHEN infield(cod_cnd_pgto)
         CALL log009_popup(6,25,"COND. PAGAMENTO","cond_pgto",
                          "cod_cnd_pgto","den_cnd_pgto",
                          "vdp0140","N","") RETURNING p_pedido_dig_mest.cod_cnd_pgto
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         DISPLAY p_pedido_dig_mest.cod_cnd_pgto TO cod_cnd_pgto
    WHEN infield(num_list_preco)
         CALL log009_popup(6,25,"LISTA DE PRECO","desc_preco_mest",
                          "num_list_preco","den_list_preco",
                          "vdp0260","S","") RETURNING p_lista_preco
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         IF p_lista_preco IS NOT NULL
         THEN  LET p_pedido_dig_mest.num_list_preco = p_lista_preco
               DISPLAY p_pedido_dig_mest.num_list_preco TO num_list_preco
         END IF
    WHEN infield(cod_tip_venda)
         CALL log009_popup(6,25,"TIPO VENDA","tipo_venda",
                          "cod_tip_venda","den_tip_venda",
                          "vdp0120","N","") RETURNING p_pedido_dig_mest.cod_tip_venda
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         DISPLAY p_pedido_dig_mest.cod_tip_venda TO cod_tip_venda
    WHEN infield(cod_moeda)
         CALL log009_popup(6,25,"MOEDAS","moeda",
                          "cod_moeda","den_moeda",
                          "pat0140","N","") RETURNING p_pedido_dig_mest.cod_moeda
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         DISPLAY p_pedido_dig_mest.cod_moeda TO cod_moeda
    WHEN infield(cod_cidade)
         CALL vdp309_popup_cidades()  RETURNING p_pedido_dig_ent.cod_cidade
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42831
         DISPLAY p_pedido_dig_ent.cod_cidade TO cod_cidade
    WHEN infield(cod_consig)
         LET  p_pedido_dig_mest.cod_consig = vdp3362_popup_cliente("T")
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         LET l_den_consig = " "
         WHENEVER ERROR CONTINUE
         SELECT den_transpor
           INTO l_den_consig
           FROM transport
          WHERE cod_transpor = p_pedido_dig_mest.cod_consig
         WHENEVER ERROR STOP
         IF sqlca.sqlcode = NOTFOUND THEN
            WHENEVER ERROR CONTINUE
            SELECT nom_cliente
              INTO l_den_consig
              FROM clientes
             WHERE cod_cliente = p_pedido_dig_mest.cod_consig
            WHENEVER ERROR CONTINUE
            IF sqlca.sqlcode <> 0 THEN
               LET l_den_consig = " "
            END IF
         END IF
         DISPLAY BY NAME p_pedido_dig_mest.cod_consig
         DISPLAY l_den_consig TO den_consig
    WHEN infield(cod_repres)
         CALL log009_popup(6,25,"REPRESENTANTES","representante",
                          "cod_repres","nom_repres",
                          "vdp3550","N","") RETURNING p_pedido_dig_mest.cod_repres
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         DISPLAY BY NAME p_pedido_dig_mest.cod_repres
    WHEN infield(cod_repres_adic)
         CALL log009_popup(6,25,"REPRESENTANTES","representante",
                          "cod_repres","nom_repres",
                          "","N","") RETURNING p_pedido_dig_mest.cod_repres_adic
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         DISPLAY BY NAME p_pedido_dig_mest.cod_repres_adic

    WHEN INFIELD(cod_repres_3)
         CALL log009_popup(6,25,"REPRESENTANTES","representante",
                          "cod_repres","nom_repres",
                          "","N","") RETURNING m_cod_repres_3
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         DISPLAY m_cod_repres_3 TO cod_repres_3

    WHEN infield(cod_cnd_pgto)
         LET p_filtro = "ORDER BY cod_cnd_pgto "
         CALL log009_popup(6,25,"COND. PAGAMENTO","cond_pgto",
                          "cod_cnd_pgto","den_cnd_pgto",
                          "vdp0140","N",p_filtro) RETURNING p_pedido_dig_mest.cod_cnd_pgto
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         DISPLAY p_pedido_dig_mest.cod_cnd_pgto TO cod_cnd_pgto
    WHEN infield(cod_tip_venda)
         CALL log009_popup(6,25,"TIPO VENDA","tipo_venda",
                          "cod_tip_venda","den_tip_venda",
                          "vdp0120","N","") RETURNING p_pedido_dig_mest.cod_tip_venda
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
         DISPLAY p_pedido_dig_mest.cod_tip_venda TO cod_tip_venda
    WHEN infield(cod_cidade)
         CALL vdp309_popup_cidades()  RETURNING p_pedido_dig_ent.cod_cidade
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42831
         DISPLAY p_pedido_dig_ent.cod_cidade TO cod_cidade
    WHEN infield(cod_item)
         LET pa_curr = arr_curr()
         LET sc_curr = scr_line()
         LET p_cod_item_pe = vdp4285_popup_item(p_cod_empresa)
         IF p_cod_item_pe IS NOT NULL
         THEN  IF   p_status = 4
               THEN
                    CALL log006_exibe_teclas("01 02 03 07", p_versao)
                    CURRENT WINDOW IS w_vdp42839
                    LET ma_ped_dig_bnf[pa_curr_b].cod_item = p_cod_item_pe
                    DISPLAY  ma_ped_dig_bnf[pa_curr_b].cod_item TO s_ped_dig_bnf[sc_curr_b].cod_item
               ELSE
                    CALL log006_exibe_teclas("01 02 03 07", p_versao)
                    CURRENT WINDOW IS w_vdp42832
                    LET t_pedido_dig_item[pa_curr].cod_item = p_cod_item_pe
                    DISPLAY t_pedido_dig_item[pa_curr].cod_item TO s_pedido_dig_item[sc_curr].cod_item
               END IF
         END IF
    WHEN infield(pct_desc_adic) AND p_status = 1
         CALL vdp4283_controle_peditdesc(p_cod_empresa,
                                          p_pedido_dig_mest.num_pedido,
                                          0 )
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4283
    WHEN infield(pct_desc_adic) AND p_status = 3
         CALL vdp4283_controle_peditdesc(p_cod_empresa,
                                          p_pedido_dig_mest.num_pedido,
                                          pa_curr)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42832
    WHEN infield(num_sequencia)
	        LET p_filtro = "cli_end_ent.cod_cliente = '",p_pedido_dig_mest.cod_cliente,"'"
	        CALL log009_popup(6,25,"CLIENTE END. ENTREGA","cli_end_ent",
			                        "num_sequencia","end_entrega",
			                        "vdp3640","N", p_filtro)  RETURNING p_num_sequencia
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42831
         DISPLAY p_num_sequencia TO num_sequencia

    WHEN infield(cod_grade_1)
         CALL log009_popup(6,21,ma_ctr_grade[1].descr_cabec_zoom,
                                ma_ctr_grade[1].nom_tabela_zoom,
                                ma_ctr_grade[1].descr_col_1_zoom,
                                ma_ctr_grade[1].descr_col_2_zoom,
                                ma_ctr_grade[1].cod_progr_manut,"N","")
              RETURNING t_array_grade[pa_curr_g].cod_grade_1
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42836
         DISPLAY t_array_grade[pa_curr_g].cod_grade_1
              TO s_pedido_dig_grad[sc_curr_g].cod_grade_1

    WHEN infield(cod_grade_2)
         CALL log009_popup(6,21,ma_ctr_grade[2].descr_cabec_zoom,
                                ma_ctr_grade[2].nom_tabela_zoom,
                                ma_ctr_grade[2].descr_col_1_zoom,
                                ma_ctr_grade[2].descr_col_2_zoom,
                                ma_ctr_grade[2].cod_progr_manut,"N","")
              RETURNING t_array_grade[pa_curr_g].cod_grade_2
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42836
         DISPLAY t_array_grade[pa_curr_g].cod_grade_2
              TO s_pedido_dig_grad[sc_curr_g].cod_grade_2

   WHEN infield(cod_grade_3)
         CALL log009_popup(6,21,ma_ctr_grade[3].descr_cabec_zoom,
                                ma_ctr_grade[3].nom_tabela_zoom,
                                ma_ctr_grade[3].descr_col_1_zoom,
                                ma_ctr_grade[3].descr_col_2_zoom,
                                ma_ctr_grade[3].cod_progr_manut,"N","")
              RETURNING t_array_grade[pa_curr_g].cod_grade_3
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42836
         DISPLAY t_array_grade[pa_curr_g].cod_grade_3
              TO s_pedido_dig_grad[sc_curr_g].cod_grade_3

   WHEN infield(cod_grade_4)
         CALL log009_popup(6,21,ma_ctr_grade[4].descr_cabec_zoom,
                                ma_ctr_grade[4].nom_tabela_zoom,
                                ma_ctr_grade[4].descr_col_1_zoom,
                                ma_ctr_grade[4].descr_col_2_zoom,
                                ma_ctr_grade[4].cod_progr_manut,"N","")
              RETURNING t_array_grade[pa_curr_g].cod_grade_4
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42836
         DISPLAY t_array_grade[pa_curr_g].cod_grade_4
              TO s_pedido_dig_grad[sc_curr_g].cod_grade_4

   WHEN infield(cod_grade_5)
         CALL log009_popup(6,21,ma_ctr_grade[5].descr_cabec_zoom,
                                ma_ctr_grade[5].nom_tabela_zoom,
                                ma_ctr_grade[5].descr_col_1_zoom,
                                ma_ctr_grade[5].descr_col_2_zoom,
                                ma_ctr_grade[5].cod_progr_manut,"N","")
              RETURNING t_array_grade[pa_curr_g].cod_grade_5
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42836
         DISPLAY t_array_grade[pa_curr_g].cod_grade_5
              TO s_pedido_dig_grad[sc_curr_g].cod_grade_5

   WHEN infield(ies_preco)
        LET p_pedido_dig_mest.ies_preco = log0830_list_box(16,44,
            'F {Firme}, R {Reajustavel}')
        DISPLAY p_pedido_dig_mest.ies_preco TO pedido_dig_mest.ies_preco
   WHEN infield(ies_frete)
        LET p_pedido_dig_mest.ies_frete = log0830_list_box(16,22,
            '1 {CIF Pago}, 2 {CIF Cobrado}, 3 {FOB}, 4 {CIF Infor. Pct.}, 5 {CIF Infor. Unit.}')
        DISPLAY p_pedido_dig_mest.ies_frete TO pedido_dig_mest.ies_frete
   WHEN infield(ies_tip_entrega)
        LET p_pedido_dig_mest.ies_tip_entrega = log0830_list_box(17,42,
            '1 {Total}, 2 {Parcial item total}, 3 {Parcial item parcial}')
        DISPLAY p_pedido_dig_mest.ies_tip_entrega TO pedido_dig_mest.ies_tip_entrega
   WHEN infield(ies_finalidade)
        LET p_pedido_dig_mest.ies_finalidade = log0830_list_box(18,22,
            '1 {Contrib. (Industr/Comerc)}, 2 {Nao Contrib.}, 3 {Contrib. (Uso/Consumo)}')
        DISPLAY p_pedido_dig_mest.ies_finalidade TO pedido_dig_mest.ies_finalidade
   WHEN infield(ies_embal_padrao)
        LET p_pedido_dig_mest.ies_embal_padrao = log0830_list_box(14,40,
            '1 {Padr.Int.}, 2 {Padr.Ext.}, 3 {Sem Padr.}, 4 {Padr.Cx.Int.}, 5 {Padr.Cx.Ext}, 6 {Padr.Pallet}')
        DISPLAY p_pedido_dig_mest.ies_embal_padrao TO pedido_dig_mest.ies_embal_padrao
 END CASE
 END FUNCTION

#------------------------------------#
FUNCTION vdp4283_popup_intermediario()
#------------------------------------#
   DEFINE l_cod_cliente  LIKE clientes.cod_cliente,
          l_cod_nat_oper LIKE nat_operacao.cod_nat_oper

   CASE
      WHEN infield(cod_nat_oper)
         LET g_cod_cliente  = p_ped_item_nat.cod_cliente
         LET l_cod_nat_oper = vdp2273_popup_nat_oper()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42838
         IF l_cod_nat_oper IS NOT NULL THEN
            LET p_ped_item_nat.cod_nat_oper = l_cod_nat_oper
            DISPLAY p_ped_item_nat.cod_nat_oper TO cod_nat_oper
         END IF
      WHEN infield(cod_cliente)
         LET l_cod_cliente = vdp3362_popup_cliente("C")
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42838
         IF l_cod_cliente IS NOT NULL THEN
            LET p_ped_item_nat.cod_cliente = l_cod_cliente
            DISPLAY p_ped_item_nat.cod_cliente TO cod_cliente
         END IF
      WHEN infield(cod_cnd_pgto)
         CALL log009_popup(6,25,"COND. PAGAMENTO","cond_pgto",
                           "cod_cnd_pgto","den_cnd_pgto",
                           "vdp0140","N","") RETURNING p_ped_item_nat.cod_cnd_pgto
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42838
         DISPLAY p_ped_item_nat.cod_cnd_pgto TO cod_cnd_pgto
      WHEN INFIELD (cod_local_estoq)
         CALL log009_popup(6,25,"LOCAL DE ESTOQUE","local",
                           "cod_local","den_local",
                           "man0540","S","") RETURNING p_pedido_dig_mest.cod_local_estoq
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42838
         DISPLAY p_pedido_dig_mest.cod_local_estoq TO cod_local_estoq
   END CASE

END FUNCTION

#----------------------------#
 FUNCTION vdp4283_exibe_dados()
#----------------------------#
 DEFINE ies_incl_txt CHAR(001)
 LET ies_incl_txt = ies_incl_txt
# WHENEVER ERROR CONTINUE
# CALL log130_procura_caminho("vdp4283") RETURNING p_nom_tela
# OPEN WINDOW w_vdp4283 AT 2,02 WITH FORM p_nom_tela
#      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
# WHENEVER ERROR STOP
# CURRENT WINDOW IS w_vdp4283

 DISPLAY BY NAME p_pedido_dig_mest.cod_empresa,
                 p_pedido_dig_mest.num_pedido,
                 p_pedido_dig_mest.cod_nat_oper,
                 p_pedido_dig_mest.dat_emis_repres,
                 p_pedido_dig_mest.dat_prazo_entrega,
                 p_pedido_dig_mest.cod_cliente,
                 p_pedido_dig_mest.num_pedido_cli,
                 p_pedido_dig_mest.num_pedido_repres,
                 p_pedido_dig_mest.cod_repres,
                 p_pedido_dig_mest.ies_comissao,
                 p_pedido_dig_mest.pct_comissao,
                 p_pedido_dig_mest.cod_repres_adic,
                 p_pedido_dig_mest.num_list_preco,
                 p_pedido_dig_mest.ies_preco,
                 p_pedido_dig_mest.pct_desc_adic,
                 p_pedido_dig_mest.pct_desc_financ,
                 p_pedido_dig_mest.cod_cnd_pgto,
                 p_pedido_dig_mest.cod_tip_venda,
                 p_pedido_dig_mest.ies_frete,
                 p_pedido_dig_mest.ies_tip_entrega,
                 p_pedido_dig_mest.cod_transpor,
                 p_pedido_dig_mest.cod_consig,
                 p_pedido_dig_mest.ies_finalidade,
                 p_pedido_dig_mest.cod_moeda,
                 p_vendor_pedido.pct_taxa_negoc,
                 p_pedido_dig_mest.ies_embal_padrao,
                 p_pedido_dig_mest.cod_tip_carteira,
                 ies_incl_txt

     DISPLAY m_ies_txt_exped TO ies_txt_exped     #E# - 469670
     DISPLAY m_linha_produto TO parametro_texto

 END FUNCTION

#------------------------------#
 FUNCTION vdp4283_inclui_mestre()
#------------------------------#
 DEFINE p_pedidos          RECORD LIKE pedidos.*,
        p_nat_operacao     RECORD LIKE nat_operacao.*,
        p_hora             DATETIME HOUR TO SECOND

 LET p_pedidos.cod_empresa         = p_cod_empresa
 LET p_pedido_dig_mest.cod_empresa = p_cod_empresa
 LET p_pedidos.num_pedido          = p_pedido_dig_mest.num_pedido
 LET p_pedidos.cod_cliente         = p_pedido_dig_mest.cod_cliente
 LET p_pedidos.pct_comissao        = p_pedido_dig_mest.pct_comissao
 LET p_pedidos.num_pedido_repres   = p_pedido_dig_mest.num_pedido_repres
 LET p_pedidos.dat_emis_repres     = p_pedido_dig_mest.dat_emis_repres
 LET p_pedidos.cod_nat_oper        = p_pedido_dig_mest.cod_nat_oper
 LET p_pedidos.cod_transpor        = p_pedido_dig_mest.cod_transpor
 LET p_pedidos.cod_consig          = p_pedido_dig_mest.cod_consig
 LET p_pedidos.ies_finalidade      = p_pedido_dig_mest.ies_finalidade
 LET p_pedidos.ies_frete           = p_pedido_dig_mest.ies_frete
 LET p_pedidos.ies_preco           = p_pedido_dig_mest.ies_preco
 LET p_pedidos.cod_cnd_pgto        = p_pedido_dig_mest.cod_cnd_pgto
 LET p_pedidos.pct_desc_financ     = p_pedido_dig_mest.pct_desc_financ
 LET p_pedidos.ies_embal_padrao    = p_pedido_dig_mest.ies_embal_padrao
 LET p_pedidos.ies_tip_entrega     = p_pedido_dig_mest.ies_tip_entrega
 CASE WHEN p_pedido_dig_mest.ies_aceite_finan = "S" AND
           p_pedido_dig_mest.ies_aceite_comer = "S"
           LET p_pedidos.ies_aceite   = "A"
      WHEN p_pedido_dig_mest.ies_aceite_finan = "N" AND
           p_pedido_dig_mest.ies_aceite_comer = "N"
           LET p_pedidos.ies_aceite   = "N"
      WHEN p_pedido_dig_mest.ies_aceite_finan = "S" AND
           p_pedido_dig_mest.ies_aceite_comer = "N"
           LET p_pedidos.ies_aceite   = "F"
      WHEN p_pedido_dig_mest.ies_aceite_finan = "N" AND
           p_pedido_dig_mest.ies_aceite_comer = "S"
           LET p_pedidos.ies_aceite   = "C"
 END CASE
 LET p_pedidos.ies_sit_pedido    = p_pedido_dig_mest.ies_sit_pedido
 LET p_pedidos.dat_pedido        = TODAY
 LET p_pedidos.num_pedido_cli    = p_pedido_dig_mest.num_pedido_cli
 LET p_pedidos.num_pedido_repres = p_pedido_dig_mest.num_pedido_repres
 LET p_pedidos.pct_desc_adic     = p_pedido_dig_mest.pct_desc_adic
 LET p_pedidos.num_list_preco    = p_pedido_dig_mest.num_list_preco
 LET p_pedidos.cod_repres        = p_pedido_dig_mest.cod_repres
 LET p_pedidos.cod_repres_adic   = p_pedido_dig_mest.cod_repres_adic
 LET p_pedidos.dat_alt_sit       = TODAY
 LET p_pedidos.dat_cancel        = TODAY
 LET p_pedidos.cod_tip_carteira  = p_pedido_dig_mest.cod_tip_carteira
 LET p_pedidos.cod_tip_venda     = p_pedido_dig_mest.cod_tip_venda
 LET p_pedidos.cod_moeda         = p_pedido_dig_mest.cod_moeda
 LET p_pedidos.ies_comissao      = p_pedido_dig_mest.ies_comissao
 LET p_pedidos.cod_motivo_can    = 0
 LET p_pedidos.pct_frete         = p_pedido_dig_mest.pct_frete
 LET p_pedidos.num_versao_lista  = p_pedido_dig_mest.num_versao_lista
 LET p_pedidos.cod_local_estoq   = p_pedido_dig_mest.cod_local_estoq
 WHENEVER ERROR CONTINUE
 SELECT * INTO p_nat_operacao.*
        FROM nat_operacao
        WHERE cod_nat_oper = p_pedido_dig_mest.cod_nat_oper
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
 END IF
 IF   p_nat_operacao.ies_tip_controle = "B"
 THEN LET p_erro[8] = "1"     ### bloqueia o pedido para liberacao comercial
      LET p_pedido_dig_mest.ies_aceite_comer = "N"
 ELSE LET p_erro[8] = "0"
 END IF

   IF p_erro = "000000000" THEN
      IF p_consist_cred = TRUE THEN
         LET p_pedidos.ies_sit_pedido = "B"
      END IF
      WHENEVER ERROR CONTINUE
      INSERT INTO pedidos VALUES (p_pedidos.*)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = 0 THEN

         IF p_ped_item_nat.cod_nat_oper IS NOT NULL AND
            p_ped_item_nat.cod_nat_oper <> " "      THEN
            WHENEVER ERROR CONTINUE
            INSERT INTO ped_item_nat VALUES ( p_pedidos.cod_empresa,
                                              p_pedidos.num_pedido,
                                              0,"N","N",
                                              p_ped_item_nat.cod_cliente,
                                              p_ped_item_nat.cod_nat_oper,
                                              p_ped_item_nat.cod_cnd_pgto)
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
               LET p_houve_erro = TRUE
               CALL log003_err_sql("INCLUSAO","PED_ITEM_NAT-MEST")
            END IF
         END IF

         IF p_par_vdp.par_vdp_txt[22,22] = "S" THEN
            CALL vdp4283_insert_t_mestre(p_pedidos.num_pedido,
                                         p_pedidos.cod_repres,
                                         p_pedidos.cod_nat_oper,
                                         p_pedidos.cod_cnd_pgto,
                                         p_pedidos.pct_desc_adic,
                                         p_pedidos.cod_moeda)
         END IF
      ELSE
         LET p_houve_erro = TRUE
         CALL log003_err_sql("INCLUSAO","PEDIDOS")
      END IF
   ELSE
      LET p_hora                                 = CURRENT
      LET p_pedido_dig_mest.hora_digitacao       = p_hora
      LET p_pedido_dig_mest.dat_liberacao_fin    = NULL
      LET p_pedido_dig_mest.hora_liberacao_fin   = NULL
      LET p_pedido_dig_mest.dat_liberacao_com    = NULL
      LET p_pedido_dig_mest.hora_liberacao_com   = NULL
      WHENEVER ERROR CONTINUE
      INSERT INTO pedido_dig_mest VALUES (p_pedido_dig_mest.*)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = 0 THEN
         IF p_ped_item_nat.cod_nat_oper IS NOT NULL AND
            p_ped_item_nat.cod_nat_oper <> " "      THEN
            WHENEVER ERROR CONTINUE
            INSERT INTO ped_dig_it_nat VALUES ( p_pedidos.cod_empresa,
                                                p_pedidos.num_pedido,
                                                0,"N","N",
                                                p_ped_item_nat.cod_cliente,
                                                p_ped_item_nat.cod_nat_oper,
                                                p_ped_item_nat.cod_cnd_pgto)
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("INCLUSAO","ped_dig_it_nat")
            END IF
         END IF
      ELSE
         LET p_houve_erro = TRUE
         CALL log003_err_sql("INCLUSAO","PEDIDOS")
      END IF
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION vdp4283_insert_ped_list()
#----------------------------------#

 IF   p_erro = "000000000" THEN
      WHENEVER ERROR CONTINUE
      INSERT INTO pedido_list VALUES (p_cod_empresa, p_pedido_dig_mest.num_pedido, p_user)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = 0
      THEN
      ELSE LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO","PEDIDO_LIST")
      END IF
 END IF

 END FUNCTION

#----------------------------------#
 FUNCTION vdp4283_inclui_end_entr()
#----------------------------------#
 DEFINE p_ped_end_ent         RECORD LIKE ped_end_ent.*

 IF p_num_sequencia IS NULL THEN
    LET p_num_sequencia = 0
 END IF

 LET p_ped_end_ent.cod_empresa   = p_cod_empresa
 LET p_ped_end_ent.num_pedido    = p_pedido_dig_mest.num_pedido
 LET p_ped_end_ent.num_sequencia = p_num_sequencia
 LET p_ped_end_ent.end_entrega   = p_pedido_dig_ent.end_entrega
 LET p_ped_end_ent.den_bairro    = p_pedido_dig_ent.den_bairro
 LET p_ped_end_ent.cod_cidade    = p_pedido_dig_ent.cod_cidade
 LET p_ped_end_ent.cod_cep       = p_pedido_dig_ent.cod_cep
 LET p_ped_end_ent.num_cgc       = p_pedido_dig_ent.num_cgc
 LET p_ped_end_ent.ins_estadual  = p_pedido_dig_ent.ins_estadual
 LET p_pedido_dig_ent.cod_empresa   = p_cod_empresa
 LET p_pedido_dig_ent.num_pedido    = p_pedido_dig_mest.num_pedido
 LET p_pedido_dig_ent.num_sequencia = p_num_sequencia

 IF   p_erro = "000000000" THEN
      WHENEVER ERROR CONTINUE
      INSERT INTO ped_end_ent VALUES (p_ped_end_ent.*)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = 0
      THEN
      ELSE LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO","PED_END_ENT")
      END IF
 ELSE
      WHENEVER ERROR CONTINUE
      INSERT INTO pedido_dig_ent VALUES (p_pedido_dig_ent.*)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO","PED_END_ENT")
      END IF
 END IF

 END FUNCTION

#--------------------------------#
 FUNCTION vdp4283_inclui_observ()
#--------------------------------#
 DEFINE p_ped_observacao     RECORD LIKE ped_observacao.*

 LET p_ped_observacao.cod_empresa   = p_cod_empresa
 LET p_ped_observacao.num_pedido    = p_pedido_dig_mest.num_pedido
 LET p_ped_observacao.tex_observ_1  = p_pedido_dig_obs.tex_observ_1
 LET p_ped_observacao.tex_observ_2  = p_pedido_dig_obs.tex_observ_2
 LET p_pedido_dig_obs.cod_empresa   = p_cod_empresa
 LET p_pedido_dig_obs.num_pedido    = p_pedido_dig_mest.num_pedido

 IF   p_erro = "000000000" THEN
      WHENEVER ERROR CONTINUE
       INSERT INTO ped_observacao VALUES (p_ped_observacao.*)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = 0
      THEN
      ELSE LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO","PED_OBSERVACAO")
      END IF
 ELSE
      WHENEVER ERROR CONTINUE
      INSERT INTO pedido_dig_obs VALUES (p_pedido_dig_obs.*)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO","pedido_dig_obs")
      END IF

 END IF
 END FUNCTION

#-----------------------------#
 FUNCTION vdp4283_inclui_itens()
#-----------------------------#

 FOR pa_curr = 1 TO  500
    IF   t_pedido_dig_item[pa_curr].cod_item IS NOT NULL OR
         t_pedido_dig_item[pa_curr].cod_item  != "               "
  THEN
    IF p_houve_item_rep THEN
       CALL vdp4283_verifica_item_repres()
    END IF
         LET p_ped_itens.cod_empresa       = p_cod_empresa
         LET p_ped_itens.num_pedido        = p_pedido_dig_mest.num_pedido
         LET p_ped_itens.num_sequencia     = pa_curr
         LET p_ped_itens.cod_item          = t_pedido_dig_item[pa_curr].cod_item
         LET p_ped_itens.pct_desc_adic     = t_pedido_dig_item[pa_curr].pct_desc_adic
         LET p_ped_itens.pre_unit          = t_pedido_dig_item[pa_curr].pre_unit
#        LET p_ped_itens.pre_unit          =
#        (t_pedido_dig_item[pa_curr].qtd_pecas_solic * t_pedido_dig_item[pa_curr].pre_unit) /
#        (t_pedido_dig_item[pa_curr].qtd_pecas_solic + t_pedido_dig_item[pa_curr].qtd_item_bonif)
#        LET p_ped_itens.qtd_pecas_solic   = t_pedido_dig_item[pa_curr].qtd_pecas_solic +
#                                            t_pedido_dig_item[pa_curr].qtd_item_bonif
#
         LET p_ped_itens.qtd_pecas_solic   = t_pedido_dig_item[pa_curr].qtd_pecas_solic
         LET p_ped_itens.qtd_pecas_atend   = 0
         LET p_ped_itens.qtd_pecas_cancel  = 0
         LET p_ped_itens.qtd_pecas_reserv  = 0
         LET p_ped_itens.qtd_pecas_romaneio = 0
         LET p_ped_itens.prz_entrega       = t_pedido_dig_item[pa_curr].prz_entrega
         LET p_ped_itens.val_desc_com_unit = 0
         LET p_ped_itens.val_frete_unit    = t_pedido_dig_item[pa_curr].val_frete_unit
         LET p_ped_itens.val_seguro_unit   = t_pedido_dig_item[pa_curr].val_seguro_unit
         LET p_ped_itens.pct_desc_bruto    = 0
         IF   p_par_vdp.par_vdp_txt[22,22] = "S"
         THEN CALL vdp596_pesquisa_ctr_meta(p_cod_empresa,
                                             p_ped_itens.num_pedido,
                                             p_ped_itens.cod_item ,
                                             p_pedido_dig_mest.cod_repres,
                                             p_pedido_dig_mest.dat_digitacao,
                                             p_ped_itens.qtd_pecas_solic)
                			     RETURNING p_achou, p_ctr_meta.*
              IF   p_achou = TRUE
              THEN IF   p_pedido_dig_mest.ies_aceite_comer = "S" OR
                        p_par_vdp.par_vdp_txt[19,19] = "N"
                   THEN
                   ELSE IF   vdp4283_verifica_meta_venda()
                        THEN
                        END IF
                   END IF
              END IF
         END IF
         IF   p_erro = "000000000" THEN
              WHENEVER ERROR CONTINUE
              INSERT INTO ped_itens VALUES (p_ped_itens.*)
              WHENEVER ERROR STOP
              IF   sqlca.sqlcode = 0
              THEN
              ELSE LET p_houve_erro = TRUE
                   CALL log003_err_sql("INCLUSAO","PED_ITENS")
              END IF
              IF vdp4283_existe_nat_oper_refer() THEN
                 WHENEVER ERROR CONTINUE
                 INSERT INTO ped_item_nat VALUES
                    ( p_cod_empresa, p_pedido_dig_mest.num_pedido, pa_curr, "N", "N",
                      "", m_cod_nat_oper_ref, p_pedido_dig_mest.cod_cnd_pgto )
                 WHENEVER ERROR STOP
                 IF sqlca.sqlcode <> 0 THEN
                    LET p_houve_erro = TRUE
                    CALL log003_err_sql("INCLUSAO","PED_ITEM_NAT")
                 END IF
              END IF
              CALL vdp4283_incl_ped_of_pcp()
       ELSE
              WHENEVER ERROR CONTINUE
              INSERT INTO pedido_dig_item VALUES (p_cod_empresa,
                                                p_pedido_dig_mest.num_pedido,
                                                pa_curr,
                                                t_pedido_dig_item[pa_curr].cod_item,
                                                t_pedido_dig_item[pa_curr].qtd_pecas_solic,
                                                t_pedido_dig_item[pa_curr].pre_unit,
                                                t_pedido_dig_item[pa_curr].pct_desc_adic,
                                                0,
                                                t_pedido_dig_item[pa_curr].prz_entrega,
                                                t_pedido_dig_item[pa_curr].val_frete_unit,
                                                t_pedido_dig_item[pa_curr].val_seguro_unit)
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 LET p_houve_erro = TRUE
                 CALL log003_err_sql("INCLUSAO","pedido_dig_item")
              END IF
              IF vdp4283_existe_nat_oper_refer() THEN
                 WHENEVER ERROR CONTINUE
                 INSERT INTO ped_dig_it_nat VALUES
                    ( p_cod_empresa, p_pedido_dig_mest.num_pedido, pa_curr, "N",
 "N",
                      "", m_cod_nat_oper_ref, p_pedido_dig_mest.cod_cnd_pgto )

                 WHENEVER ERROR STOP
                 IF sqlca.sqlcode <> 0 THEN
                    LET p_houve_erro = TRUE
                    CALL log003_err_sql("INCLUSAO","PED_DIG_IT_NAT")
                 END IF
              END IF
       END IF
       IF   p_ies_tip_controle = "2"
       THEN CALL vdp4283_insert_ped_itens_rem()
       END IF

       WHENEVER ERROR CONTINUE
       INSERT INTO vdp_ped_item_compl (empresa,
                                       pedido ,
                                       sequencia_pedido,
                                       campo ,
                                       parametro_dat)
                            VALUES ( p_cod_empresa,
                                     p_pedido_dig_mest.num_pedido,
                                     pa_curr,
                                     'data_cliente',
                                     t_pedido_dig_item[pa_curr].parametro_dat)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO","vdp_ped_item_compl")
        END IF
   ELSE
       EXIT FOR
   END IF
 END FOR

 END FUNCTION


#---------------------------------#
FUNCTION vdp4283_inclui_itens_bnf()
#---------------------------------#

   FOR pa_curr = 1 TO 99
      IF ma_ped_dig_bnf[pa_curr].cod_item IS NOT NULL THEN

         LET p_ped_itens_bnf.cod_empresa           = p_cod_empresa
         LET p_ped_itens_bnf.num_pedido            =
             p_pedido_dig_mest.num_pedido
         LET p_ped_itens_bnf.num_sequencia         = pa_curr
         LET p_ped_itens_bnf.cod_item              =
             ma_ped_dig_bnf[pa_curr].cod_item
         LET p_ped_itens_bnf.qtd_pecas_solic       =
             ma_ped_dig_bnf[pa_curr].qtd_pecas_solic
         LET p_ped_itens_bnf.pre_unit              =
             ma_ped_dig_bnf[pa_curr].pre_unit
         LET p_ped_itens_bnf.pct_desc_adic         =
             ma_ped_dig_bnf[pa_curr].pct_desc_adic
         LET p_ped_itens_bnf.qtd_pecas_atend       = 0
         LET p_ped_itens_bnf.qtd_pecas_cancel      = 0
         LET p_ped_itens_bnf.qtd_pecas_reserv      = 0
         LET p_ped_itens_bnf.prz_entrega           =
             ma_ped_dig_bnf[pa_curr].prz_entrega
         LET p_ped_itens_bnf.qtd_pecas_romaneio = 0
         LET p_ped_itens_bnf.pct_desc_bruto     = 0

         IF p_erro = "000000000" THEN
            WHENEVER ERROR CONTINUE
            INSERT INTO ped_itens_bnf VALUES (p_ped_itens_bnf.*)
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
               LET p_houve_erro = TRUE
               CALL log003_err_sql("INCLUSAO","PED_ITENS_BNF")
            END IF
         ELSE
            WHENEVER ERROR CONTINUE
            INSERT INTO ped_dig_item_bnf VALUES (p_ped_itens_bnf.cod_empresa,
                                         p_ped_itens_bnf.num_pedido,
                                         p_ped_itens_bnf.num_sequencia,
                                         p_ped_itens_bnf.cod_item,
                                         p_ped_itens_bnf.qtd_pecas_solic,
                                         p_ped_itens_bnf.pre_unit,
                                         p_ped_itens_bnf.pct_desc_adic,
                                         0,
                                         p_ped_itens_bnf.prz_entrega)
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("INCLUSAO", "ITENS_BNF")
               LET p_houve_erro = TRUE
            END IF
         END IF
      ELSE
         EXIT FOR
      END IF
   END FOR
END FUNCTION


#--------------------------------#
 FUNCTION vdp4283_incl_ped_of_pcp()
#--------------------------------#
  DEFINE  p_ped_ord_fabr            RECORD LIKE ped_ord_fabr.*,
          p_ped_pcp                 RECORD LIKE ped_pcp.*
  DEFINE  p_cod_lin_prod            LIKE item.cod_lin_prod,
          p_cod_lin_recei           LIKE item.cod_lin_recei,
          p_cod_seg_merc            LIKE item.cod_seg_merc,
          p_cod_cla_uso             LIKE item.cod_cla_uso,
          p_ies_emite_of            LIKE linha_prod.ies_emite_of,
          p_ped_itens_cod_item      LIKE ped_itens.cod_item,
          p_ped_itens_num_pedido    LIKE ped_itens.num_pedido,
          p_ped_itens_num_sequencia LIKE ped_itens.num_sequencia

 WHENEVER ERROR CONTINUE
 SELECT cod_lin_prod,
        cod_lin_recei,
        cod_seg_merc,
        cod_cla_uso
   INTO p_cod_lin_prod,
        p_cod_lin_recei,
        p_cod_seg_merc,
        p_cod_cla_uso
   FROM item
   WHERE item.cod_item    = p_ped_itens.cod_item
     AND item.cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN
 ELSE RETURN
 END IF
 WHENEVER ERROR CONTINUE
 SELECT ies_emite_of
   INTO p_ies_emite_of
   FROM linha_prod
   WHERE linha_prod.cod_lin_prod  = p_cod_lin_prod
     AND linha_prod.cod_lin_recei = p_cod_lin_recei
     AND linha_prod.cod_seg_merc  = p_cod_seg_merc
     AND linha_prod.cod_cla_uso   = p_cod_cla_uso
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN
 ELSE RETURN
 END IF
 CASE WHEN p_ies_emite_of = "1"
           LET p_ped_ord_fabr.cod_empresa       = p_cod_empresa
           LET p_ped_ord_fabr.num_pedido        = p_ped_itens.num_pedido
           LET p_ped_ord_fabr.num_sequencia     = p_ped_itens.num_sequencia
           LET p_ped_ord_fabr.ies_ord_fabr_nova = "N"
           LET p_ped_ord_fabr.nom_usuario       = p_user
           WHENEVER ERROR CONTINUE
           INSERT INTO ped_ord_fabr VALUES (p_ped_ord_fabr.*)
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0
           THEN RETURN
           ELSE LET p_houve_erro = TRUE
                CALL log003_err_sql("INCLUSAO","PED_ORD_FABR")
           END IF
      WHEN p_ies_emite_of = "2"
           LET p_ped_pcp.cod_empresa       = p_cod_empresa
           LET p_ped_pcp.num_pedido        = p_ped_itens.num_pedido
           LET p_ped_pcp.num_sequencia     = p_ped_itens.num_sequencia
           INITIALIZE p_ped_pcp.qtd_cancelada,
           p_ped_pcp.prz_entrega_ant TO NULL
           LET p_ped_pcp.nom_usuario       = p_user
           LET p_ped_pcp.num_transacao     = 0
           WHENEVER ERROR CONTINUE
           INSERT INTO ped_pcp VALUES (p_ped_pcp.*)
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0
           THEN RETURN
           ELSE LET p_houve_erro = TRUE
                CALL log003_err_sql("INCLUSAO","PED_PCP")
           END IF
 END CASE
END FUNCTION

#---------------------------------#
 FUNCTION vdp4283_total(p_funcao)
#---------------------------------#
 DEFINE p_funcao                CHAR(12),
        p_pct_desc_m            LIKE ped_itens.pct_desc_adic,
        p_pct_desc_i            LIKE ped_itens.pct_desc_adic,
        p_total_val_liq         DECIMAL(15,2) ,
        p_total_val_bru         DECIMAL(15,2)
 DEFINE l_total RECORD
                   quantidade               DECIMAL(15,3),
                   preco                    DECIMAL(17,6),
                   total_val_bru            DECIMAL(15,3)
                END RECORD


 IF   p_par_vdp.par_vdp_txt[20,20] = "N" THEN
     WHENEVER ERROR CONTINUE
     CALL log130_procura_caminho("vdp42833") RETURNING p_nom_tela
     OPEN WINDOW w_vdp42833 AT 2,02 WITH FORM p_nom_tela
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
     WHENEVER ERROR STOP
     CALL log006_exibe_teclas("01 02 07", p_versao)
     CURRENT WINDOW IS w_vdp42833
 ELSE
     WHENEVER ERROR CONTINUE
     CALL log130_procura_caminho("vdp42837") RETURNING p_nom_tela
     OPEN WINDOW w_vdp42837 AT 2,02 WITH FORM p_nom_tela
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
     WHENEVER ERROR STOP
     CALL log006_exibe_teclas("01 02 07", p_versao)
     CURRENT WINDOW IS w_vdp42837
 END IF

 DISPLAY p_cod_empresa TO cod_empresa
 DISPLAY p_pedido_dig_mest.num_pedido  TO num_pedido
 LET p_pre_unit_liq           = 0
 LET p_total_val_liq          = 0
 LET p_total_val_bru          = 0
 LET p_total.quantidade       = 0
 LET p_total.preco            = 0
 LET p_total.desc_adic        = 0
 LET p_totalc.quantidade      = 0
 LET p_totalc.preco           = 0
 LET p_totalc.desc_adic       = 0
 LET p_totalc.val_tot_bruto   = 0
 LET p_totalc.val_tot_liquido = 0
 FOR p_count = 1 TO 500
    IF   t_pedido_dig_item[p_count].cod_item IS NOT NULL
    THEN LET p_totalc.quantidade = p_totalc.quantidade +
                                   t_pedido_dig_item[p_count].qtd_pecas_solic
         LET p_totalc.preco      = p_totalc.preco      +
                                   t_pedido_dig_item[p_count].pre_unit
         LET p_totalc.desc_adic  = p_totalc.desc_adic  +
                                   t_pedido_dig_item[p_count].pct_desc_adic

         LET p_total_val_bru     = p_total_val_bru +
                                   (t_pedido_dig_item[p_count].pre_unit *
                                    t_pedido_dig_item[p_count].qtd_pecas_solic)

         LET p_totalc.val_tot_bruto = p_totalc.val_tot_bruto +
                                      t_pedido_dig_item[p_count].pre_unit *
                                      t_pedido_dig_item[p_count].qtd_pecas_solic
         CALL vdp4283_busca_desc_adic_unico(0,
                                            p_pedido_dig_mest.pct_desc_adic)
             RETURNING p_pct_desc_m
         CALL vdp4283_calcula_pre_unit(t_pedido_dig_item[p_count].pre_unit,
                                       p_pct_desc_m)
             RETURNING p_pre_unit_liq
         CALL vdp4283_busca_desc_adic_unico(p_count,
                                    t_pedido_dig_item[p_count].pct_desc_adic)
             RETURNING p_pct_desc_i
         CALL vdp4283_calcula_pre_unit(p_pre_unit_liq,
                                      p_pct_desc_i)
             RETURNING p_pre_unit_liq
         LET p_totalc.val_tot_liquido = p_totalc.val_tot_liquido +
                                        ( p_pre_unit_liq *
                                        t_pedido_dig_item[p_count].qtd_pecas_solic)

    ELSE EXIT FOR
    END IF
 END FOR

 IF   p_par_vdp.par_vdp_txt[20,20] = "N"
#THEN DISPLAY BY NAME p_totalc.*
 THEN DISPLAY p_totalc.quantidade        TO quantidade
      DISPLAY p_totalc.preco             TO preco
      DISPLAY p_totalc.desc_adic         TO desc_adic
      DISPLAY p_totalc.val_tot_bruto     TO total_val_bru
      DISPLAY p_totalc.val_tot_liquido   TO total_val_liq

      IF log0040_confirm(17,40,"Confirma processo em andamento? ") = TRUE THEN
         RETURN TRUE
      ELSE
         LET int_flag = 0
         RETURN FALSE
      END IF
 END IF

  INPUT BY NAME l_total.* WITHOUT DEFAULTS

  AFTER FIELD quantidade
        IF   p_totalc.quantidade <> l_total.quantidade
        THEN CALL log0030_mensagem( " QUANTIDADE total não confere","excl")
             NEXT FIELD quantidade
        END IF

  BEFORE FIELD preco
        IF p_pedido_dig_mest.num_list_preco IS NOT NULL AND
           fgl_lastkey() <> fgl_keyval("UP")  THEN
           DISPLAY p_totalc.preco TO preco
           NEXT FIELD total_val_bru
        END IF

        IF p_pedido_dig_mest.num_list_preco IS NOT NULL AND
           fgl_lastkey() = fgl_keyval("UP")  THEN
           NEXT FIELD quantidade
        END IF

  AFTER FIELD preco
        IF   l_total.preco IS NULL THEN
             CALL log0030_mensagem( "Informe o preço ","excl")
             NEXT FIELD preco
        END IF

        IF   p_pedido_dig_mest.num_list_preco IS NULL OR
             p_pedido_dig_mest.num_list_preco = 0
        THEN IF   p_totalc.preco <> l_total.preco
             THEN CALL log0030_mensagem( " PREÇO total não confere","excl")
                  NEXT FIELD preco
             END IF
        END IF

  AFTER FIELD total_val_bru
        IF   l_total.total_val_bru IS NULL THEN
             CALL log0030_mensagem( "Informe o valor do pedido ","excl")
             NEXT FIELD total_val_bru
        END IF

        IF (p_totalc.quantidade * p_totalc.preco) <>
            l_total.total_val_bru THEN
            CALL log0030_mensagem( "Preço total não confere","excl")
            NEXT FIELD total_val_bru
        END IF


  ON KEY (f1, control-w)
     #lds IF NOT LOG_logix_versao5() THEN
     #lds CONTINUE INPUT
     #lds END IF
         CALL vdp4283_help(1)
  END INPUT

   IF int_flag <> 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#---------------------------------------------------------------#
 FUNCTION vdp4283_busca_preco_lista(p_cod_item, p_cod_lin_prod,
                                  p_cod_lin_recei, p_cod_seg_merc,
                                  p_cod_cla_uso)
#---------------------------------------------------------------#
 DEFINE      p_cod_item        LIKE item_vdp.cod_item,
             p_cod_lin_prod    LIKE item.cod_lin_prod,
             p_cod_lin_recei   LIKE item.cod_lin_recei,
             p_cod_seg_merc    LIKE item.cod_seg_merc,
             p_cod_cla_uso     LIKE item.cod_cla_uso,
             p_desc_bruto_tab  LIKE desc_preco_item.pct_desc,
             p_pre_unit_tab    LIKE desc_preco_item.pre_unit,
             p_desc_adic_tab   LIKE desc_preco_item.pct_desc_adic

 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder = " " OR
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = 0
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND desc_preco_item.cod_cliente    = p_pedido_dig_mest.cod_cliente
     AND desc_preco_item.cod_item       = p_cod_item
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder = " " OR
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = p_cod_cla_uso
     AND desc_preco_item.cod_cliente    = p_pedido_dig_mest.cod_cliente
     AND (desc_preco_item.cod_item      IS NULL OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF
 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder = " " OR
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = 0
     AND desc_preco_item.cod_cliente    = p_pedido_dig_mest.cod_cliente
     AND (desc_preco_item.cod_item      IS NULL OR
          desc_preco_item.cod_item      = "               ")
  WHENEVER ERROR STOP
IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF
 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder = " " OR
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND desc_preco_item.cod_cliente    = p_pedido_dig_mest.cod_cliente
     AND (desc_preco_item.cod_item      IS NULL OR
          desc_preco_item.cod_item      = "               ")
  WHENEVER ERROR STOP
IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

  WHENEVER ERROR CONTINUE
SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder = " " OR
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND desc_preco_item.cod_cliente    = p_pedido_dig_mest.cod_cliente
     AND (desc_preco_item.cod_item      IS NULL OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder = " " OR
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = 0
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND desc_preco_item.cod_cliente    = p_pedido_dig_mest.cod_cliente
     AND (desc_preco_item.cod_item      IS NULL OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

WHENEVER ERROR CONTINUE
SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = 0
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND desc_preco_item.cod_item       = p_cod_item
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

WHENEVER ERROR CONTINUE
SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder  IS NULL  OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = 0
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND desc_preco_item.cod_item       = p_cod_item
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

WHENEVER ERROR CONTINUE
SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = p_cod_cla_uso
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL  OR
          desc_preco_item.cod_item      = "               ")
  WHENEVER ERROR STOP
IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

WHENEVER ERROR CONTINUE
SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL  OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL  OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL  OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = 0
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL  OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF
 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder  IS NULL OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = p_cod_cla_uso
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder  IS NULL OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder  IS NULL OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder  IS NULL OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_desc,
        pre_unit,
        pct_desc_adic
   INTO p_desc_bruto_tab,
        p_pre_unit_tab,
        p_desc_adic_tab
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_pedido_dig_mest.num_list_preco
     AND (desc_preco_item.cod_uni_feder  IS NULL OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = 0
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL OR
          desc_preco_item.cod_item      = "               ")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 ELSE LET p_status = 1
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF
 END FUNCTION

#-------------------------------------#
 FUNCTION vdp4283_verifica_finalidade()
#-------------------------------------#
 DEFINE     p_filial       CHAR(04)
 LET p_filial = p_num_cgc_cpf[13,16]
 IF p_pedido_dig_mest.ies_finalidade = "2" AND
    p_filial = "0000"
 THEN RETURN true
 ELSE  IF p_pedido_dig_mest.ies_finalidade = "2" AND
          (p_ins_estadual = " " OR
           p_ins_estadual IS NULL)
       THEN RETURN true
       ELSE IF (p_pedido_dig_mest.ies_finalidade = "1" OR
                p_pedido_dig_mest.ies_finalidade = "3")
            THEN IF    p_ins_estadual IS NOT NULL
                 THEN RETURN true
                 ELSE CALL log0030_mensagem( " Finalidade incorreta para o cliente. ","excl")
                      RETURN false
                 END IF
            ELSE CALL log0030_mensagem( " Finalidade incorreta para o cliente. ","excl")
                 RETURN false
            END IF
       END IF
 END IF
 END FUNCTION

#-----------------------------------------#
 FUNCTION vdp4283_verifica_credito_cliente()
#-----------------------------------------#
 DEFINE     p_qtd_dias_atr_dupl    LIKE cli_credito.qtd_dias_atr_dupl,
            p_qtd_dias_atr_med     LIKE cli_credito.qtd_dias_atr_med,
            p_ies_nota_debito      LIKE cli_credito.ies_nota_debito,
            p_val_cotacao          LIKE cotacao_mes.val_cotacao,
            p_dat_val_lmt_cr       LIKE cli_credito.dat_val_lmt_cr

IF   p_par_vdp.par_vdp_txt[40,40] = "S"
THEN
     WHENEVER ERROR CONTINUE
     SELECT cod_cliente_matriz  INTO p_cod_cliente_matriz
            FROM clientes
            WHERE clientes.cod_cliente = p_pedido_dig_mest.cod_cliente
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET p_cod_cliente_matriz = " "
     END IF
     IF   p_cod_cliente_matriz IS NULL OR p_cod_cliente_matriz = " "
     THEN LET p_cod_cliente_matriz = p_pedido_dig_mest.cod_cliente
     END IF
ELSE LET p_cod_cliente_matriz = p_pedido_dig_mest.cod_cliente
END IF
 WHENEVER ERROR CONTINUE
SELECT qtd_dias_atr_dupl,
       qtd_dias_atr_med,
       val_ped_carteira,
       val_dup_aberto,
       val_limite_cred,
       ies_nota_debito,
       dat_val_lmt_cr
  INTO p_qtd_dias_atr_dupl,
       p_qtd_dias_atr_med,
       p_val_ped_carteira,
       p_val_dup_aberto,
       p_val_limite_cred_unid,
       p_ies_nota_debito,
       p_dat_val_lmt_cr
  FROM cli_credito
  WHERE cli_credito.cod_cliente = p_cod_cliente_matriz
 WHENEVER ERROR STOP
 IF   sqlca.sqlcode <> 0 THEN
      CALL log0030_mensagem( " Cliente sem dados de crédito. ","excl")
      RETURN false
 END IF
 IF   p_ies_nota_debito = "S"
 THEN CALL log0030_mensagem( " Cliente com nota de débito em aberto. ","excl")
      RETURN false
 END IF
 IF   p_qtd_dias_atr_dupl > p_par_vdp.qtd_dias_atr_dupl
 THEN CALL log0030_mensagem( " Cliente com duplicata em atraso. ","excl")
      RETURN false
 END IF
 IF   p_qtd_dias_atr_med > p_par_vdp.qtd_dias_atr_med
 THEN CALL log0030_mensagem( " Cliente com atraso médio de duplicata. ","excl")
      RETURN false
 END IF

 IF   p_dat_val_lmt_cr  < TODAY
 THEN CALL log0030_mensagem( " Data de limite de crédito Expirada  ","excl")
      RETURN false
 END IF

 WHENEVER ERROR CONTINUE
 SELECT val_cotacao
   INTO p_val_cotacao
   FROM cotacao
  WHERE cotacao.cod_moeda = p_par_vdp.cod_moeda
    AND cotacao.dat_ref   = TODAY
 WHENEVER ERROR STOP
 IF   sqlca.sqlcode <> 0
 THEN WHENEVER ERROR CONTINUE
      CURRENT WINDOW IS w_vdp42831
      OPEN WINDOW w_vdp42831 AT 10,10 WITH 5 ROWS, 30 COLUMNS
           ATTRIBUTE(BORDER, PROMPT LINE LAST)
      WHENEVER ERROR STOP
       DISPLAY "Cotacao da moeda para calculo"  AT 1,1
       DISPLAY "do limite de credito do clien-" AT 2,1
       DISPLAY "te do  mes corrente nao cadas-" AT  3,1
       DISPLAY "trado" AT 4,1
      ERROR " "
      PROMPT "Tecle ENTER para continuar" FOR p_comando
      CLOSE WINDOW w_vdp42831
      RETURN false
 END IF
 LET p_val_limite_cred_cruz = p_val_limite_cred_unid * p_val_cotacao
 RETURN true
 END FUNCTION

#-----------------------------#
FUNCTION vdp4283_inclui_grade()
#-----------------------------#

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

         IF p_erro = "000000000" THEN
            WHENEVER ERROR CONTINUE
            INSERT INTO ped_itens_grade VALUES (p_cod_empresa,
                                                t_pedido_dig_grad[pa_curr_g].*,
                                                0,0,0,0)
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
               LET p_houve_erro = TRUE
               CALL log003_err_sql("INCLUSAO","PED_ITENS_GRADE")
            END IF
         ELSE
            WHENEVER ERROR CONTINUE
            INSERT INTO ped_dig_itens_grad VALUES (p_cod_empresa,
                                                t_pedido_dig_grad[pa_curr_g].*)
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
               LET p_houve_erro = TRUE
               CALL log003_err_sql("INCLUSAO","PED_DIG_ITENS_GRADE")
            END IF
         END IF
      END IF
   END FOR
END FUNCTION


#------------------------------#
 FUNCTION vdp4283_inclui_texto()
#------------------------------#
   DEFINE p_ped_itens_txt    RECORD LIKE ped_itens_texto.*

   IF   p_erro = "000000000"
   THEN
   ELSE RETURN
   END IF

   INITIALIZE p_ped_itens_txt.* TO NULL

   WHENEVER ERROR CONTINUE
   DECLARE cq_ped_txt CURSOR FOR
    SELECT * FROM pedido_dig_texto
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_pedido_dig_mest.num_pedido
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","cq_ped_txt")
      RETURN
   END IF

   WHENEVER ERROR CONTINUE
   FOREACH cq_ped_txt INTO p_ped_itens_txt.*
      IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("FOREACH","cq_ped_txt")
         RETURN
      END IF
     WHENEVER ERROR CONTINUE
     SELECT * FROM ped_itens_texto
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_ped_itens_txt.num_pedido
        AND num_sequencia = p_ped_itens_txt.num_sequencia
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = NOTFOUND
        THEN INSERT INTO ped_itens_texto VALUES (p_ped_itens_txt.*)
     ELSE
        WHENEVER ERROR CONTINUE
        UPDATE ped_itens_texto SET ped_itens_texto.* = p_ped_itens_txt.*
         WHERE ped_itens_texto.cod_empresa = p_cod_empresa
           AND ped_itens_texto.num_pedido  = p_ped_itens_txt.num_pedido
           AND ped_itens_texto.num_sequencia = p_ped_itens_txt.num_sequencia
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("UPDATE","ped_itens_texto")
           RETURN
        END IF
     END IF
     WHENEVER ERROR CONTINUE
   END FOREACH
   WHENEVER ERROR STOP
   FREE cq_ped_txt

   WHENEVER ERROR CONTINUE
   DELETE FROM pedido_dig_texto
    WHERE pedido_dig_texto.cod_empresa   = p_cod_empresa
      AND pedido_dig_texto.num_pedido    = p_pedido_dig_mest.num_pedido
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","pedido_dig_texto")
      RETURN
   END IF
 END FUNCTION

#-------------------------------------#
 FUNCTION vdp4283_verifica_meta_venda()
#-------------------------------------#
 IF (p_pedido_dig_item.qtd_pecas_solic + p_ctr_meta.qtd_venda) >
     p_ctr_meta.qtd_remanejada
 THEN CALL log0030_mensagem( "QTDE PEDIDO EXCEDEU META DE VENDA","excl")
      LET p_erro[9] = "1"
      RETURN FALSE
 ELSE LET p_erro[9] = "0"
 END IF
 RETURN TRUE
 END FUNCTION

#------------------------------#
 FUNCTION vdp4283_move_dados()
#------------------------------#
 LET p_pedido_dig_mest.cod_empresa        = p_cod_empresa
 LET p_pedido_dig_mest.pct_desc_bruto     = 0
 LET p_pedido_dig_mest.pct_desc_adic      = 0
 LET p_pedido_dig_mest.pct_desc_financ    = 0
 LET p_pedido_dig_mest.pct_comissao       = 0
 LET p_pedido_dig_mest.dat_emis_repres    = TODAY
 LET p_pedido_dig_mest.dat_prazo_entrega  = TODAY
 LET p_pedido_dig_mest.ies_sit_pedido     = "N"
 LET p_pedido_dig_mest.ies_aceite_finan   = "N"
 LET p_pedido_dig_mest.ies_aceite_comer   = "N"
 LET p_pedido_dig_mest.pct_frete          = 0
 LET p_pedido_dig_mest.nom_usuario        = p_user
 LET p_pedido_dig_mest.num_versao_lista   = 0
 LET p_pedido_dig_mest.cod_tip_carteira   = "01"
 LET p_pedido_dig_mest.dat_digitacao      = TODAY
 LET p_pedido_dig_mest.ies_sit_informacao = "D"
 LET p_pedido_dig_obs.cod_empresa         = p_cod_empresa
 LET p_pedido_dig_ent.cod_empresa         = p_cod_empresa
 LET p_pedido_dig_item.cod_empresa        = p_cod_empresa
 LET p_pedido_dig_item.pct_desc_bruto     = 0
 LET p_pedido_dig_item.val_seguro_unit    = 0
 LET p_pedido_dig_item.val_frete_unit     = 0
 LET p_totalc.desc_adic                   = 0

 LET p_ped_itens_desc.pct_desc_1    = 0
 LET p_ped_itens_desc.pct_desc_2    = 0
 LET p_ped_itens_desc.pct_desc_3    = 0
 LET p_ped_itens_desc.pct_desc_4    = 0
 LET p_ped_itens_desc.pct_desc_5    = 0
 LET p_ped_itens_desc.pct_desc_6    = 0
 LET p_ped_itens_desc.pct_desc_7    = 0
 LET p_ped_itens_desc.pct_desc_8    = 0
 LET p_ped_itens_desc.pct_desc_9    = 0
 LET p_ped_itens_desc.pct_desc_10   = 0

 LET p_vendor_pedido.pct_taxa_negoc = 0

 LET m_pct_comissao_2 = 0
 LET m_pct_comissao_3 = 0
 LET m_cod_repres_3   = NULL

 FOR p_ind = 1 TO 500
  INITIALIZE t_ped_itens_desc[p_ind].* TO NULL
 END FOR

 LET p_ind = 0
 END FUNCTION

#-----------------------------------------------#
 FUNCTION vdp4283_mostra_estoque(p_cod_item_est)
#-----------------------------------------------#
DEFINE    p_cod_item_est    LIKE pedido_dig_item.cod_item

 MESSAGE "Calculando estoque ... "  ATTRIBUTE(REVERSE)

LET p_qtd_estoque    = 0
LET p_qtd_carteira   = 0
LET p_qtd_disponivel = 0
WHENEVER ERROR CONTINUE
SELECT qtd_liberada
  INTO p_qtd_estoque
  FROM estoque
 WHERE estoque.cod_empresa = p_cod_empresa
   AND estoque.cod_item    = p_cod_item_est
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET p_qtd_estoque    = 0
 END IF
 IF   p_qtd_estoque IS NULL OR
      p_qtd_estoque < 0
 THEN LET p_qtd_estoque   = 0
 END IF

WHENEVER ERROR CONTINUE
 SELECT SUM(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel)
   INTO p_qtd_carteira
   FROM ped_itens
  WHERE ped_itens.cod_empresa = p_cod_empresa
    AND ped_itens.cod_item    = p_cod_item_est
    AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel) > 0
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET p_qtd_carteira    = 0
 END IF
 IF   p_qtd_carteira IS NULL OR
      p_qtd_carteira < 0
 THEN LET p_qtd_carteira   = 0
 END IF

 LET p_qtd_disponivel  = p_qtd_estoque - p_qtd_carteira
 DISPLAY p_qtd_estoque TO qtd_estoque
 DISPLAY p_qtd_carteira TO qtd_carteira
 DISPLAY p_qtd_disponivel TO qtd_disponivel

 MESSAGE ""

END FUNCTION

#------------------------------------------------------------------#
FUNCTION vdp4283_controle_peditdesc(p_cod_emp, p_num_ped, p_num_seq)
#------------------------------------------------------------------#
   DEFINE p_cod_emp           LIKE empresa.cod_empresa,
          p_num_ped           LIKE pedidos.num_pedido,
          p_num_seq           SMALLINT,
          p_aux               SMALLINT,
          p_ja_atualizou      SMALLINT,
          p_cod_lin_prod      LIKE item.cod_lin_prod,
          p_cod_lin_recei     LIKE item.cod_lin_recei,
          p_cod_lin_prodr     LIKE item.cod_lin_prod,
          p_cod_lin_receir    LIKE item.cod_lin_recei,
          p_desc_tot          DECIMAL(8,2)

   INITIALIZE p_nom_tela TO NULL

   LET p_ind = 1
   LET p_ja_atualizou = FALSE

   CALL log130_procura_caminho("vdp42834") RETURNING p_nom_tela
   OPEN WINDOW w_vdp42834 AT 2,2  WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_vdp42834

   LET p_ped_itens_desc.cod_empresa   = p_cod_empresa
   LET p_ped_itens_desc.num_pedido    = p_num_ped
   LET p_ped_itens_desc.num_sequencia = p_num_seq
   LET p_ped_itens_desc.pct_desc_1    = 0
   LET p_ped_itens_desc.pct_desc_2    = 0
   LET p_ped_itens_desc.pct_desc_3    = 0
   LET p_ped_itens_desc.pct_desc_4    = 0
   LET p_ped_itens_desc.pct_desc_5    = 0
   LET p_ped_itens_desc.pct_desc_6    = 0
   LET p_ped_itens_desc.pct_desc_7    = 0
   LET p_ped_itens_desc.pct_desc_8    = 0
   LET p_ped_itens_desc.pct_desc_9    = 0
   LET p_ped_itens_desc.pct_desc_10   = 0

   FOR p_aux = 1 TO 500
      IF t_ped_itens_desc[p_aux].num_pedido    = p_ped_itens_desc.num_pedido AND
         t_ped_itens_desc[p_aux].num_sequencia = p_ped_itens_desc.num_sequencia
      THEN
         LET p_ped_itens_desc.pct_desc_1  = t_ped_itens_desc[p_aux].pct_desc_1
         LET p_ped_itens_desc.pct_desc_2  = t_ped_itens_desc[p_aux].pct_desc_2
         LET p_ped_itens_desc.pct_desc_3  = t_ped_itens_desc[p_aux].pct_desc_3
         LET p_ped_itens_desc.pct_desc_4  = t_ped_itens_desc[p_aux].pct_desc_4
         LET p_ped_itens_desc.pct_desc_5  = t_ped_itens_desc[p_aux].pct_desc_5
         LET p_ped_itens_desc.pct_desc_6  = t_ped_itens_desc[p_aux].pct_desc_6
         LET p_ped_itens_desc.pct_desc_7  = t_ped_itens_desc[p_aux].pct_desc_7
         LET p_ped_itens_desc.pct_desc_8  = t_ped_itens_desc[p_aux].pct_desc_8
         LET p_ped_itens_desc.pct_desc_9  = t_ped_itens_desc[p_aux].pct_desc_9
         LET p_ped_itens_desc.pct_desc_10 = t_ped_itens_desc[p_aux].pct_desc_10
         EXIT FOR
      END IF
   END FOR

   DISPLAY BY NAME p_ped_itens_desc.num_pedido
   DISPLAY BY NAME p_ped_itens_desc.cod_empresa
   DISPLAY BY NAME p_ped_itens_desc.num_sequencia

   INPUT BY NAME p_ped_itens_desc.* WITHOUT DEFAULTS
      BEFORE FIELD num_sequencia
            NEXT FIELD pct_desc_1
   END INPUT

   FOR p_aux = 1 TO 500
      IF t_ped_itens_desc[p_aux].num_pedido    = p_num_ped AND
         t_ped_itens_desc[p_aux].num_sequencia = p_num_seq THEN
         INITIALIZE t_ped_itens_desc[p_aux].* TO NULL
         EXIT FOR
      END IF
   END FOR

   FOR p_aux = 1 TO 500
      IF t_ped_itens_desc[p_aux].num_sequencia IS NULL OR
         t_ped_itens_desc[p_aux].num_sequencia = " "   THEN
         LET t_ped_itens_desc[p_aux].num_pedido    = p_num_ped
         LET t_ped_itens_desc[p_aux].num_sequencia = p_num_seq
         LET t_ped_itens_desc[p_aux].pct_desc_1   = p_ped_itens_desc.pct_desc_1
         LET t_ped_itens_desc[p_aux].pct_desc_2   = p_ped_itens_desc.pct_desc_2
         LET t_ped_itens_desc[p_aux].pct_desc_3   = p_ped_itens_desc.pct_desc_3
         LET t_ped_itens_desc[p_aux].pct_desc_4   = p_ped_itens_desc.pct_desc_4
         LET t_ped_itens_desc[p_aux].pct_desc_5   = p_ped_itens_desc.pct_desc_5
         LET t_ped_itens_desc[p_aux].pct_desc_6   = p_ped_itens_desc.pct_desc_6
         LET t_ped_itens_desc[p_aux].pct_desc_7   = p_ped_itens_desc.pct_desc_7
         LET t_ped_itens_desc[p_aux].pct_desc_8   = p_ped_itens_desc.pct_desc_8
         LET t_ped_itens_desc[p_aux].pct_desc_9   = p_ped_itens_desc.pct_desc_9
         LET t_ped_itens_desc[p_aux].pct_desc_10  = p_ped_itens_desc.pct_desc_10
         EXIT FOR
      END IF
   END FOR

   CLOSE WINDOW w_vdp42834
   LET int_flag = 0
END FUNCTION

#---------------------------------------#
 FUNCTION vdp4283_inclui_ped_itens_desc()
#---------------------------------------#
 DEFINE p_padesc     SMALLINT

 FOR p_padesc = 1 TO 500
     IF (t_ped_itens_desc[p_padesc].num_sequencia IS NOT NULL OR
         t_ped_itens_desc[p_padesc].num_sequencia <> " ") AND
        (t_ped_itens_desc[p_padesc].pct_desc_1 > 0) THEN
        LET p_ped_itens_desc.cod_empresa   = p_cod_empresa
        LET p_ped_itens_desc.num_pedido    = p_pedido_dig_mest.num_pedido
        LET p_ped_itens_desc.num_sequencia =
            t_ped_itens_desc[p_padesc].num_sequencia
        LET p_ped_itens_desc.pct_desc_1 = t_ped_itens_desc[p_padesc].pct_desc_1
        LET p_ped_itens_desc.pct_desc_2 = t_ped_itens_desc[p_padesc].pct_desc_2
        LET p_ped_itens_desc.pct_desc_3 = t_ped_itens_desc[p_padesc].pct_desc_3
        LET p_ped_itens_desc.pct_desc_4 = t_ped_itens_desc[p_padesc].pct_desc_4
        LET p_ped_itens_desc.pct_desc_5 = t_ped_itens_desc[p_padesc].pct_desc_5
        LET p_ped_itens_desc.pct_desc_6 = t_ped_itens_desc[p_padesc].pct_desc_6
        LET p_ped_itens_desc.pct_desc_7 = t_ped_itens_desc[p_padesc].pct_desc_7
        LET p_ped_itens_desc.pct_desc_8 = t_ped_itens_desc[p_padesc].pct_desc_8
        LET p_ped_itens_desc.pct_desc_9 = t_ped_itens_desc[p_padesc].pct_desc_9
        LET p_ped_itens_desc.pct_desc_10= t_ped_itens_desc[p_padesc].pct_desc_10
        IF p_erro = "000000000" THEN
           WHENEVER ERROR CONTINUE
           INSERT INTO ped_itens_desc VALUES (p_ped_itens_desc.* )
           WHENEVER ERROR STOP
           IF sqlca.sqlcode  = 0 THEN
           ELSE
              LET p_houve_erro = TRUE
              CALL log003_err_sql("INCLUSAO","PED_ITENS_DESC")
           END IF
        ELSE
           WHENEVER ERROR CONTINUE
           INSERT INTO ped_dig_item_desc VALUES (p_ped_itens_desc.*)
           WHENEVER ERROR STOP
           IF sqlca.sqlcode  = 0 THEN
           ELSE
              LET p_houve_erro = TRUE
              CALL log003_err_sql("INCLUSAO","ped_dig_item_desc")
           END IF

      END IF
   END IF
 END FOR
END FUNCTION

#-------------------------------------#
 FUNCTION vdp4283_verifica_carteira()
#-------------------------------------#
WHENEVER ERROR CONTINUE
 SELECT * FROM tipo_carteira
        WHERE cod_tip_carteira = p_pedido_dig_mest.cod_tip_carteira
WHENEVER ERROR STOP
 IF   sqlca.sqlcode = 0
 THEN RETURN TRUE
 ELSE RETURN FALSE
 END IF
 END FUNCTION

#----------------------------------------#
 FUNCTION vdp4283_existe_nat_oper_refer()
#----------------------------------------#
   WHENEVER ERROR CONTINUE
   SELECT cod_nat_oper_ref INTO m_cod_nat_oper_ref FROM nat_oper_refer
    WHERE cod_empresa  = p_cod_empresa
      AND cod_nat_oper = p_pedido_dig_mest.cod_nat_oper
      AND cod_item     = t_pedido_dig_item[pa_curr].cod_item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0
      THEN RETURN TRUE
      ELSE RETURN FALSE
   END IF
END FUNCTION

#------------------------------------#
 FUNCTION vdp4283_existe_fiscal_par(l_cod_cla_fisc,
                                    l_cod_lin_prod,
                                    l_cod_lin_recei,
                                    l_cod_seg_merc,
                                    l_cod_cla_uso)
#------------------------------------#
  DEFINE l_cod_cla_fisc        LIKE item.cod_cla_fisc,
         l_cod_lin_prod        LIKE item.cod_lin_prod,
         l_cod_lin_recei       LIKE item.cod_lin_recei,
         l_cod_seg_merc        LIKE item.cod_seg_merc,
         l_cod_cla_uso         LIKE item.cod_cla_uso


  IF m_consis_trib_pedido = "S" THEN
     IF NOT vdpr99_nova_funcao_fat() THEN
        IF NOT vdpr99_consiste_fiscal('',
                                       p_cod_empresa,
                                       TODAY,
                                       m_cod_nat_oper_ref,
                                       p_pedido_dig_mest.cod_cliente,
                                       p_pedido_dig_mest.cod_tip_carteira,
                                       p_pedido_dig_mest.ies_finalidade,
                                       l_cod_cla_fisc, # Classificação fiscal
                                       '', # Unidade de medida busca do item
                                       'N',# Bonificação
                                       t_pedido_dig_item[pa_curr].cod_item, # item
                                       l_cod_lin_prod, # linha de produto
                                       l_cod_lin_recei, # linha de receita
                                       l_cod_seg_merc, # segmento de mercado
                                       l_cod_cla_uso, # classe de uso
                                       '', # Via de transporte
                                       'S',
                                       p_pedido_dig_ent.cod_cidade,
                                       0) THEN

           RETURN FALSE
        END IF
     END IF
  END IF

 RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION vdp4283_insert_ped_itens_rem()
#---------------------------------------#
  LET p_ped_itens_rem.cod_empresa        = p_cod_empresa
  LET p_ped_itens_rem.num_pedido         = p_pedido_dig_mest.num_pedido
  LET p_ped_itens_rem.num_sequencia      = pa_curr
  LET p_ped_itens_rem.dat_emis_nf_usina  = t_ped_itens_rem[pa_curr].dat_emis_nf_usina
  LET p_ped_itens_rem.dat_retorno_prev   = t_ped_itens_rem[pa_curr].dat_retorno_prev
  LET p_ped_itens_rem.cod_motivo_remessa = t_ped_itens_rem[pa_curr].cod_motivo_remessa
  LET p_ped_itens_rem.val_estoque        = t_ped_itens_rem[pa_curr].val_estoque
  LET p_ped_itens_rem.cod_area_negocio   = t_ped_itens_rem[pa_curr].cod_area_negocio
  LET p_ped_itens_rem.cod_lin_negocio    = t_ped_itens_rem[pa_curr].cod_lin_negocio
  LET p_ped_itens_rem.num_conta          = t_ped_itens_rem[pa_curr].num_conta
  LET p_ped_itens_rem.tex_observ         = t_ped_itens_rem[pa_curr].tex_observ
  LET p_ped_itens_rem.num_pedido_compra  = t_ped_itens_rem[pa_curr].num_pedido_compra
WHENEVER ERROR CONTINUE
  INSERT INTO ped_itens_rem VALUES (p_ped_itens_rem.*)
WHENEVER ERROR STOP
  IF   sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("INCLUSAO","PED_ITENS_REM")
  END IF
END FUNCTION

#--------------------------------------#
FUNCTION vdp4283_entrada_ped_itens_rem()
#--------------------------------------#
  INITIALIZE p_ped_itens_rem.*   TO NULL

  LET p_ped_itens_rem.num_pedido_compra = 0
  LET p_ped_itens_rem.cod_empresa   = p_cod_empresa
  LET p_ped_itens_rem.num_pedido    = p_pedido_dig_mest.num_pedido
  LET p_ped_itens_rem.num_sequencia = pa_curr

  IF   t_ped_itens_rem[pa_curr].num_sequencia > 0       AND
       t_ped_itens_rem[pa_curr].num_sequencia = pa_curr
  THEN LET p_ped_itens_rem.dat_emis_nf_usina  = t_ped_itens_rem[pa_curr].dat_emis_nf_usina
       LET p_ped_itens_rem.dat_retorno_prev   = t_ped_itens_rem[pa_curr].dat_retorno_prev
       LET p_ped_itens_rem.cod_motivo_remessa = t_ped_itens_rem[pa_curr].cod_motivo_remessa
       LET p_ped_itens_rem.val_estoque        = t_ped_itens_rem[pa_curr].val_estoque
       LET p_ped_itens_rem.cod_area_negocio   = t_ped_itens_rem[pa_curr].cod_area_negocio
       LET p_ped_itens_rem.cod_lin_negocio    = t_ped_itens_rem[pa_curr].cod_lin_negocio
       LET p_ped_itens_rem.num_conta          = t_ped_itens_rem[pa_curr].num_conta
       LET p_ped_itens_rem.tex_observ         = t_ped_itens_rem[pa_curr].tex_observ
       LET p_ped_itens_rem.num_pedido_compra  = t_ped_itens_rem[pa_curr].num_pedido_compra
  END IF

  WHENEVER ERROR CONTINUE
  CALL log130_procura_caminho("vdp42835") RETURNING p_comando
  OPEN WINDOW w_vdp42835 AT 2,2 WITH FORM p_comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  WHENEVER ERROR STOP
  CALL log006_exibe_teclas("01 02 03 07", p_versao)
  CURRENT WINDOW IS w_vdp42835

  DISPLAY t_pedido_dig_item[pa_curr].cod_item TO cod_item
  DISPLAY p_pedido_dig_mest.cod_cliente       TO cod_cliente
  DISPLAY p_nom_cliente                       TO nom_cliente
  DISPLAY BY NAME p_ped_itens_rem.*

  CALL vdp4283_verifica_motivo_remessa()      RETURNING p_status
  CALL vdp4283_verifica_area_negocio()        RETURNING p_status
  CALL vdp4283_verifica_linha_negocio()       RETURNING p_status

  INPUT BY NAME p_ped_itens_rem.* WITHOUT DEFAULTS

    AFTER FIELD num_sequencia
           IF p_ped_itens_rem.num_sequencia IS NULL
           OR p_ped_itens_rem.num_sequencia <= 0
           THEN CALL log0030_mensagem( " Sequência Inválida.","excl")
                NEXT FIELD num_sequencia
           END IF

    BEFORE FIELD dat_emis_nf_usina
           CALL vdp4283_apaga_zoom()
    AFTER  FIELD dat_emis_nf_usina
           IF   p_ped_itens_rem.dat_emis_nf_usina > TODAY
           THEN CALL log0030_mensagem( " Data de Emissao da NF maior que data atual. ","excl")
                NEXT FIELD dat_emis_nf_usina
           END IF

    BEFORE FIELD cod_motivo_remessa
           CALL vdp4283_mostra_zoom()
    AFTER  FIELD cod_motivo_remessa
           IF   vdp4283_verifica_motivo_remessa() = FALSE
           THEN CALL log0030_mensagem( " Motivo não cadastrado.","excl")
                NEXT FIELD cod_motivo_remessa
           END IF
           IF p_ped_itens_rem.cod_motivo_remessa IS NULL THEN
              LET p_ped_itens_rem.cod_motivo_remessa = " "
           END IF
           CALL vdp4283_apaga_zoom()

    AFTER  FIELD val_estoque
           IF   p_ped_itens_rem.val_estoque IS NULL
           THEN CALL log0030_mensagem( " Valor Estoque Inválido ","excl")
                NEXT FIELD val_estoque
           END IF

    BEFORE FIELD cod_area_negocio
           CALL vdp4283_mostra_zoom()
    AFTER  FIELD cod_area_negocio
           IF   p_ped_itens_rem.cod_area_negocio IS NULL
           THEN CALL log0030_mensagem( " Código Área Negócio Inválido ","excl")
                NEXT FIELD cod_area_negocio
           END IF
           IF   vdp4283_verifica_area_negocio() = FALSE
           THEN CALL log0030_mensagem( " Área de Negócio não cadastrada ","excl")
                NEXT FIELD cod_area_negocio
           END IF
           CALL vdp4283_apaga_zoom()

    BEFORE FIELD cod_lin_negocio
           CALL vdp4283_mostra_zoom()
    AFTER  FIELD cod_lin_negocio
           IF   p_ped_itens_rem.cod_lin_negocio IS NULL
           THEN CALL log0030_mensagem( " Código Linha Negócio Inválido ","excl")
                NEXT FIELD cod_lin_negocio
           END IF
           IF   vdp4283_verifica_linha_negocio() = FALSE
           THEN CALL log0030_mensagem( " Linha de Negócio não cadastrada ","excl")
                NEXT FIELD cod_lin_negocio
           END IF
           IF   vdp4283_verifica_area_lin_negocio() = FALSE
           THEN CALL log0030_mensagem( " Relacionamento Area x Linha de negócio não cadastrado ","excl")
                NEXT FIELD cod_lin_negocio
           END IF
           CALL vdp4283_apaga_zoom()

    BEFORE FIELD num_conta
           CALL vdp4283_mostra_zoom()
    AFTER  FIELD num_conta
           IF   p_ped_itens_rem.num_conta IS NOT NULL
           THEN CALL con088_verifica_cod_conta(p_cod_empresa,
                                               p_ped_itens_rem.num_conta,
                                               "S",
                                               " ")
                     RETURNING p_plano_contas.*, p_plano
                IF   p_plano = FALSE
                THEN CALL log0030_mensagem( "Conta Contábil não Cadastrada","excl")
                     NEXT FIELD num_conta
                END IF
           END IF
           CALL vdp4283_apaga_zoom()

    AFTER  FIELD num_pedido_compra
           IF   p_ies_item_em_terc_ped = "S"
           THEN IF   vdp4283_verifica_pedido_compra() = FALSE
                THEN NEXT FIELD num_pedido_compra
                END IF
           END IF
           IF p_ped_itens_rem.num_pedido_compra IS NULL THEN
              LET p_ped_itens_rem.num_pedido_compra = 0
           END IF

    ON KEY (control-w, f1)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
           CALL vdp4283_help_rem()

    ON KEY (control-z, f4)
           CALL vdp4283_popup_rem()
  END INPUT

  CLOSE WINDOW w_vdp42835
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp42832

  IF   int_flag <> 0
  THEN LET INT_FLAG = 0
       RETURN FALSE
  END IF

  LET t_ped_itens_rem[pa_curr].num_sequencia      = p_ped_itens_rem.num_sequencia
  LET t_ped_itens_rem[pa_curr].dat_emis_nf_usina  = p_ped_itens_rem.dat_emis_nf_usina
  LET t_ped_itens_rem[pa_curr].dat_retorno_prev   = p_ped_itens_rem.dat_retorno_prev
  LET t_ped_itens_rem[pa_curr].cod_motivo_remessa = p_ped_itens_rem.cod_motivo_remessa
  LET t_ped_itens_rem[pa_curr].val_estoque        = p_ped_itens_rem.val_estoque
  LET t_ped_itens_rem[pa_curr].cod_area_negocio   = p_ped_itens_rem.cod_area_negocio
  LET t_ped_itens_rem[pa_curr].cod_lin_negocio    = p_ped_itens_rem.cod_lin_negocio
  LET t_ped_itens_rem[pa_curr].num_conta          = p_ped_itens_rem.num_conta
  LET t_ped_itens_rem[pa_curr].tex_observ         = p_ped_itens_rem.tex_observ
  LET t_ped_itens_rem[pa_curr].num_pedido_compra  = p_ped_itens_rem.num_pedido_compra
  RETURN TRUE
END FUNCTION

#---------------------------#
 FUNCTION vdp4283_help_rem()
#---------------------------#
  CASE
    WHEN INFIELD(dat_emis_nf_usina)             CALL SHOWHELP(3171)
    WHEN INFIELD(dat_retorno_prev)              CALL SHOWHELP(3172)
    WHEN INFIELD(cod_motivo_remessa)            CALL SHOWHELP(3141)
    WHEN INFIELD(val_estoque)                   CALL SHOWHELP(3173)
    WHEN INFIELD(cod_area_negocio)              CALL SHOWHELP(3174)
    WHEN INFIELD(cod_lin_negocio)               CALL SHOWHELP(3175)
    WHEN INFIELD(num_conta)                     CALL SHOWHELP(3176)
    WHEN INFIELD(tex_observ)                    CALL SHOWHELP(3045)
  END CASE
END FUNCTION

#----------------------------#
 FUNCTION vdp4283_popup_rem()
#----------------------------#
  DEFINE p_mot_rem      LIKE ped_itens_rem.cod_motivo_remessa

  CASE
    WHEN infield(cod_motivo_remessa)
         LET p_mot_rem = sup260_popup_motivo_remessa(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_vdp42835
         IF   p_mot_rem IS NOT NULL
         THEN LET p_ped_itens_rem.cod_motivo_remessa = p_mot_rem
              DISPLAY BY NAME p_ped_itens_rem.cod_motivo_remessa
         END IF

    WHEN infield(cod_area_negocio)
         CALL log009_popup(6,25,"AREA DE NEGOCIO","area_negocio",
                           "cod_area_negocio","den_area_negocio",
                           "sup0730","S","") RETURNING p_ped_itens_rem.cod_area_negocio
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42835
         DISPLAY p_ped_itens_rem.cod_area_negocio TO cod_area_negocio

    WHEN infield(cod_lin_negocio)
         CALL log009_popup(6,25,"LINHA DE NEGOCIO","linha_negocio",
                           "cod_lin_negocio","den_lin_negocio",
                           "sup0750","S","") RETURNING p_ped_itens_rem.cod_lin_negocio
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42835
         DISPLAY p_ped_itens_rem.cod_lin_negocio TO cod_lin_negocio

    WHEN infield(num_conta)
         CALL log009_popup(6,25,"CONTA","plano_contas",
                           "num_conta","den_conta",
                           "con0010","S","") RETURNING p_ped_itens_rem.num_conta
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42835
         DISPLAY p_ped_itens_rem.num_conta TO num_conta

  END CASE
END FUNCTION

#------------------------------------------#
 FUNCTION vdp4283_verifica_motivo_remessa()
#------------------------------------------#
   DEFINE p_den_motivo_remessa LIKE motivo_remessa.den_motivo_remessa

   INITIALIZE p_den_motivo_remessa TO NULL
   WHENEVER ERROR CONTINUE
   SELECT den_motivo_remessa
     INTO p_den_motivo_remessa
     FROM motivo_remessa
    WHERE motivo_remessa.cod_empresa        = p_cod_empresa
      AND motivo_remessa.cod_motivo_remessa = p_ped_itens_rem.cod_motivo_remessa
   WHENEVER ERROR STOP
   DISPLAY p_den_motivo_remessa TO den_motivo_remessa

   IF   sqlca.sqlcode = 0
   THEN RETURN TRUE
   ELSE RETURN FALSE
   END IF
END FUNCTION

#----------------------------------------#
 FUNCTION vdp4283_verifica_area_negocio()
#----------------------------------------#
  DEFINE p_den_area_negocio LIKE area_negocio.den_area_negocio

  INITIALIZE p_den_area_negocio TO NULL
   WHENEVER ERROR CONTINUE
  SELECT den_area_negocio
    INTO p_den_area_negocio
    FROM area_negocio
    WHERE area_negocio.cod_empresa  = p_cod_empresa
      AND area_negocio.cod_area_negocio = p_ped_itens_rem.cod_area_negocio
  DISPLAY p_den_area_negocio TO den_area_negocio
   WHENEVER ERROR STOP
  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#-----------------------------------------#
 FUNCTION vdp4283_verifica_linha_negocio()
#-----------------------------------------#
  DEFINE p_den_lin_negocio LIKE linha_negocio.den_lin_negocio

  INITIALIZE p_den_lin_negocio TO NULL
   WHENEVER ERROR CONTINUE
  SELECT den_lin_negocio
    INTO p_den_lin_negocio
    FROM linha_negocio
    WHERE linha_negocio.cod_empresa     = p_cod_empresa
      AND linha_negocio.cod_lin_negocio = p_ped_itens_rem.cod_lin_negocio
  DISPLAY p_den_lin_negocio TO den_lin_negocio
   WHENEVER ERROR STOP
  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#--------------------------------------------#
 FUNCTION vdp4283_verifica_area_lin_negocio()
#--------------------------------------------#
  DEFINE l_soma    SMALLINT
  LET l_soma = 0
   WHENEVER ERROR CONTINUE
  SELECT count(*) INTO l_soma
     FROM area_lin_negocio
    WHERE area_lin_negocio.cod_empresa        = p_cod_empresa
      AND area_lin_negocio.cod_area_negocio   = p_ped_itens_rem.cod_area_negocio
      AND area_lin_negocio.cod_lin_negocio    = p_ped_itens_rem.cod_lin_negocio
    WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF
 IF l_soma > 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#-----------------------------------------#
 FUNCTION vdp4283_verifica_pedido_compra()
#-----------------------------------------#
   DEFINE p_cgc_fornecedor              LIKE clientes.num_cgc_cpf,
          p_cod_fornecedor              LIKE fornecedor.cod_fornecedor,
          p_qtd_saldo_item_terc         LIKE ordem_sup.qtd_solic
   WHENEVER ERROR CONTINUE

   SELECT num_cgc_cpf
     INTO p_cgc_fornecedor
     FROM clientes
    WHERE cod_cliente  = p_pedido_dig_mest.cod_cliente
   WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF
   WHENEVER ERROR CONTINUE
   SELECT cod_fornecedor
     INTO p_cod_fornecedor
     FROM fornecedor
    WHERE num_cgc_cpf = p_cgc_fornecedor
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log0030_mensagem( "Fornecedor nao cadastrado na tabela de fornecedores.","excl")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   SELECT UNIQUE cod_empresa
     FROM pedido_sup
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = p_ped_itens_rem.num_pedido_compra
      AND cod_fornecedor = p_cod_fornecedor
      AND ies_situa_ped  IN ("R","A")
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log0030_mensagem( "Pedido/Fornecedor nao cadastrado na tabela pedido_sup.","excl")
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   SELECT SUM(qtd_solic - qtd_recebida)
     INTO p_qtd_saldo_item_terc
     FROM ordem_sup
    WHERE cod_empresa      = p_cod_empresa
      AND num_pedido       = p_ped_itens_rem.num_pedido_compra
      AND cod_item         = t_pedido_dig_item[pa_curr].cod_item
      AND ies_versao_atual = "S"
   WHENEVER ERROR STOP
   IF p_qtd_saldo_item_terc IS NULL OR
      p_qtd_saldo_item_terc = " "   THEN
      LET p_qtd_saldo_item_terc = 0
      CALL log0030_mensagem( "Item do Ped. Comp. nao cadastrado na tabela ordem_sup.","excl")
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#------------------------------------------------------------#
FUNCTION vdp4283_busca_desc_adic_unico(l_num_sequencia,l_desc)
#------------------------------------------------------------#
   DEFINE l_num_sequencia SMALLINT,
          l_ind           SMALLINT,
          l_desc_unico    DECIMAL(10,6),
          l_desc          DECIMAL(10,6)

   LET l_desc_unico  = l_desc

   FOR l_ind = 1 TO 500
      IF t_ped_itens_desc[l_ind].num_sequencia = l_num_sequencia THEN
         LET l_desc = 100    - ( 100    * l_desc / 100 )
         LET l_desc = l_desc - ( l_desc *
                                 t_ped_itens_desc[l_ind].pct_desc_1 / 100 )
         LET l_desc = l_desc - ( l_desc *
                                 t_ped_itens_desc[l_ind].pct_desc_2 / 100 )
         LET l_desc = l_desc - ( l_desc *
                                 t_ped_itens_desc[l_ind].pct_desc_3 / 100 )
         LET l_desc = l_desc - ( l_desc *
                                 t_ped_itens_desc[l_ind].pct_desc_4 / 100 )
         LET l_desc = l_desc - ( l_desc *
                                 t_ped_itens_desc[l_ind].pct_desc_5 / 100 )
         LET l_desc = l_desc - ( l_desc *
                                 t_ped_itens_desc[l_ind].pct_desc_6 / 100 )
         LET l_desc = l_desc - ( l_desc *
                                 t_ped_itens_desc[l_ind].pct_desc_7 / 100 )
         LET l_desc = l_desc - ( l_desc *
                                 t_ped_itens_desc[l_ind].pct_desc_8 / 100 )
         LET l_desc = l_desc - ( l_desc *
                                 t_ped_itens_desc[l_ind].pct_desc_9 / 100 )
         LET l_desc = l_desc - ( l_desc *
                                 t_ped_itens_desc[l_ind].pct_desc_10 / 100 )
         LET l_desc_unico = 100 - l_desc
         EXIT FOR
      END IF
   END FOR
   RETURN l_desc_unico

END FUNCTION

#-------------------------------------#
 FUNCTION vdp4283_busca_qtd_decimais()
#-------------------------------------#
   DEFINE l_cod_tip_carteira LIKE tipo_carteira.cod_tip_carteira,
          l_qtd_decimais     LIKE tipo_carteira.qtd_dec_preco_unit

   WHENEVER ERROR CONTINUE
   SELECT cod_tip_carteira
     INTO l_cod_tip_carteira
     FROM item_vdp
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = t_pedido_dig_item[pa_curr].cod_item
    WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF

   WHENEVER ERROR CONTINUE
   SELECT qtd_dec_preco_unit
     INTO l_qtd_decimais
     FROM tipo_carteira
    WHERE cod_tip_carteira = l_cod_tip_carteira
    WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF
   IF l_qtd_decimais > 0 THEN
   ELSE
      WHENEVER ERROR CONTINUE
      SELECT par_vdp_txt[43,43]
        INTO l_qtd_decimais
        FROM par_vdp
       WHERE cod_empresa = p_cod_empresa
   END IF
    WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF

   CALL vdp1519_calcula_pre_unit( t_pedido_dig_item[pa_curr].pre_unit, 0,
                                  l_qtd_decimais )
                                  RETURNING t_pedido_dig_item[pa_curr].pre_unit

   DISPLAY t_pedido_dig_item[pa_curr].pre_unit TO
           s_pedido_dig_item[sc_curr].pre_unit

END FUNCTION

#-------------------------------------#
 FUNCTION vdp4283_busca_qtd_dec_bnf()
#-------------------------------------#
   DEFINE l_cod_tip_carteira LIKE tipo_carteira.cod_tip_carteira,
          l_qtd_decimais     LIKE tipo_carteira.qtd_dec_preco_unit

   WHENEVER ERROR CONTINUE
   SELECT cod_tip_carteira
     INTO l_cod_tip_carteira
     FROM item_vdp
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = t_pedido_dig_item[pa_curr].cod_item
    WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF

   WHENEVER ERROR CONTINUE
   SELECT qtd_dec_preco_unit
     INTO l_qtd_decimais
     FROM tipo_carteira
    WHERE cod_tip_carteira = l_cod_tip_carteira
    WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF
   IF l_qtd_decimais > 0 THEN
   ELSE
      WHENEVER ERROR CONTINUE
      SELECT par_vdp_txt[43,43]
        INTO l_qtd_decimais
        FROM par_vdp
       WHERE cod_empresa = p_cod_empresa
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
      END IF
   END IF
   CALL vdp1519_calcula_pre_unit( ma_ped_dig_bnf[pa_curr_b].pre_unit, 0,
                                  l_qtd_decimais )
                                  RETURNING ma_ped_dig_bnf[pa_curr_b].pre_unit

   DISPLAY ma_ped_dig_bnf[pa_curr_b].pre_unit TO
            s_ped_dig_bnf[sc_curr_b].pre_unit

END FUNCTION

#-------------------------------------#
 FUNCTION vdp4283_inclui_vendor_pedido()
#-------------------------------------#
  DEFINE p_ies_tipo                  LIKE cond_pgto.ies_tipo

   WHENEVER ERROR CONTINUE
   SELECT ies_tipo
     INTO p_ies_tipo
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_pedido_dig_mest.cod_cnd_pgto
    WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF

   IF p_par_vdp.par_vdp_txt[343] = "S" AND
      p_ies_tipo                 = "E" THEN
   ELSE
      RETURN
   END IF

   LET p_vendor_pedido.cod_empresa      = p_cod_empresa
   LET p_vendor_pedido.num_pedido       = p_pedido_dig_mest.num_pedido
   LET p_vendor_pedido.ies_cnd_vendor   = "L"
   LET p_vendor_pedido.dat_cnd_vendor   = TODAY

   IF p_vendor_pedido.pct_taxa_negoc IS NULL OR
      p_vendor_pedido.pct_taxa_negoc  = " "   THEN
      LET p_vendor_pedido.pct_taxa_negoc = 0
   END IF
   WHENEVER ERROR CONTINUE
   INSERT INTO vendor_pedido VALUES (p_vendor_pedido.*)
    WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      LET p_houve_erro = TRUE
      CALL log003_err_sql("INCLUSAO","VENDOR_PEDIDO")
   END IF

END FUNCTION

#--------------------------------------#
 FUNCTION vdp4283_inclui_pedido_comis()
#--------------------------------------#
 DEFINE lr_pedido_comis  RECORD LIKE pedido_comis.*

 IF p_pedido_dig_mest.ies_comissao = 'S' THEN
    IF p_pedido_dig_mest.cod_repres_adic IS NOT NULL THEN

       LET lr_pedido_comis.cod_empresa    = p_cod_empresa
       LET lr_pedido_comis.num_pedido     = p_pedido_dig_mest.num_pedido
       LET lr_pedido_comis.pct_comissao_2 = m_pct_comissao_2

       IF m_cod_repres_3 IS NOT NULL THEN
          LET lr_pedido_comis.cod_repres_3   = m_cod_repres_3
          LET lr_pedido_comis.pct_comissao_3 = m_pct_comissao_3
       ELSE
          LET lr_pedido_comis.cod_repres_3   = 0
          LET lr_pedido_comis.pct_comissao_3 = 0
       END IF
       WHENEVER ERROR CONTINUE
       INSERT INTO pedido_comis VALUES (lr_pedido_comis.*)
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          LET p_houve_erro = TRUE
          CALL log003_err_sql('INSERT','PEDIDO_COMIS')
       END IF
    END IF
 END IF

END FUNCTION

#-------------------------------#
 FUNCTION vdp4283_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/kanaflex_sa_industria_de_plasticos/vendas/vendas/programas/vdp4283.4gl $|$Revision: 5 $|$Date: 15/09/11 08:25 $|$Modtime: 31/05/11 11:08 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION
 