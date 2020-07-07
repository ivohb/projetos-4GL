#-----------------------------------------------------------------#
# SISTEMA.: VENDAS DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0185                                               #
# MODULOS.: POL0185 - LOG0010 - LOG0030 - LOG0040 - LOG0050       #
#           LOG0060 - LOG0090 - LOG0190 - LOG0270 - LOG1200       #
#           LOG1300 - LOG1400 - VDP0050 - VDP0120 - VDP0140       #
#           VDP0260 - VDP0880 - VDP2670 - VDP3080 - VDP3550       #
#           VDP3720 - VDP3730 - VDP5830 - VDP5960 - PAT0140       #
#           PAT0150 - VDP2430                                     #
# OBJETIVO: DIGITACAO DE PEDIDOS ON-LINE                          #
# AUTOR...: DENISE BOEGERSHAUSEN                                  #
# DATA....: 30/06/2000                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_ped_itens             RECORD LIKE ped_itens.*,
         p_houve_erro            SMALLINT,
         p_houve_item_rep        SMALLINT,  
         p_msg                   CHAR(100),
         p_ant                   SMALLINT,  
         p_prev_producao         RECORD LIKE previsao_producao.*,
         p_audit_logix           RECORD LIKE audit_logix.*
  DEFINE p_pedido_dig_mest       RECORD LIKE pedido_dig_mest.*,
         p_pedido_dig_mestr      RECORD LIKE pedido_dig_mest.*,
         p_ped_itens_desc        RECORD LIKE ped_itens_desc.*,
         p_pedido_dig_obs        RECORD LIKE pedido_dig_obs.*,
         p_pedido_dig_obsr       RECORD LIKE pedido_dig_obs.*,
         p_pedido_dig_ent        RECORD LIKE pedido_dig_ent.*,
         p_pedido_dig_entr       RECORD LIKE pedido_dig_ent.*,
         p_pedido_dig_item       RECORD LIKE pedido_dig_item.*,
         p_ped_itens_rem         RECORD LIKE ped_itens_rem.*,
#        p_ped_itens_bnf         RECORD LIKE ped_itens_bnf.*,
         p_ped_agrupa            RECORD LIKE ped_agrupa_albras.*,
         p_desc_preco_mest       RECORD LIKE desc_preco_mest.*,
         p_par_vdp               RECORD LIKE par_vdp.*,
         p_cli_canal_venda       RECORD LIKE cli_canal_venda.*,
         p_plano_contas          RECORD LIKE plano_contas.*,
         p_cod_empresa_plano     LIKE par_con.cod_empresa_plano,
         p_nom_cliente           LIKE clientes.nom_cliente,
         p_nom_trans             LIKE clientes.nom_cliente,
         p_val_cotacao_ped       LIKE cotacao.val_cotacao,
         p_val_dup_aberto        LIKE cli_credito.val_dup_aberto,
         p_val_ped_carteira      LIKE cli_credito.val_ped_carteira,
         p_val_limite_cred_unid  LIKE cli_credito.val_limite_cred,
         p_cod_moeda_cons        LIKE pedidos.cod_moeda,
         p_val_limite_cred_cruz  DECIMAL(15,2),
         p_valor_pedido          DECIMAL(15,2),
         p_valor1                DECIMAL(15,2),
         p_valor2                DECIMAL(15,2),  
         p_desc_geral            DECIMAL(08,02),
         p_desc_mest             DECIMAL(08,02),
         p_desc_seq0             DECIMAL(08,02),
         p_desc_unico_mest       DECIMAL(08,02),
         p_desc_tot_geral        DECIMAL(08,02),
         p_ind                   SMALLINT,
         p_plano                 SMALLINT,
         p_num_sequencia         DECIMAL(05,0),
         p_pct_desc_tot          LIKE pedido_dig_mest.pct_desc_adic,
         p_usuario_carteira      RECORD LIKE usuario_carteira.*,
         p_ies_emite_dupl_cnd    CHAR(01),
         p_ies_emite_dupl_nat    CHAR(01),
         ies_incl_txt            CHAR(01),
         p_passou_ok             SMALLINT,
         pa_currdes              SMALLINT,
         p_ies_cli_prefer        CHAR(01),
         p_ies_minimo            CHAR(01),
         p_ies_desconto          CHAR(01),
         p_ies_faturado          CHAR(01),
         p_ies_cond              CHAR(01),
         p_ies_cond_cli          CHAR(01),
         p_erro                  SMALLINT,
         p_consist_cred          SMALLINT,
         p_achou                 SMALLINT,
       	 p_cod_tip_cli           LIKE tipo_cliente.cod_tip_cli,
         p_nom_guerra            LIKE representante.nom_guerra
  DEFINE p_valor_item_ipi        LIKE nf_mestre.val_tot_nff,
         p_valor_item_icm        LIKE nf_mestre.val_tot_nff,
         p_valor_item_pis        LIKE nf_mestre.val_tot_nff,
         p_valor_item_comis      LIKE nf_mestre.val_tot_nff ,
       	 p_ind3                  INTEGER,
       	 p_padesc                INTEGER,
	 p_desc_1                LIKE ped_itens.pct_desc_adic,
       	 p_desc_i                INTEGER 
  DEFINE p_num_pedido            LIKE pedidos.num_pedido,
         p_num_pedidor           LIKE pedidos.num_pedido,
         p_num_sequencia_desc    LIKE ped_itens.num_sequencia,
         p_ies_cons_itens        SMALLINT,
         p_resposta              CHAR(01),
         p_comando               CHAR(80),
         p_nom_tela              CHAR(80),
         p_pre_unit_real         LIKE pedido_dig_item.pre_unit,
         p_ult_pre               DECIMAL(17,6),
         p_pre_minimo            DECIMAL(15,6),
         p_max_desc              DECIMAL(5,3),
         p_max_desc_ped          DECIMAL(5,3),
         p_val_max_ped           decimal(15,2),
         p_cod_cnd_pgto          decimal(3,0),
         p_flag_max_ped          SMALLINT 

  DEFINE t_ped_itens_desc  ARRAY[500] OF RECORD
                              num_pedido    LIKE ped_itens_desc.num_pedido,
                              num_sequencia LIKE ped_itens_desc.num_sequencia,
                              pct_desc_1    LIKE ped_itens_desc.pct_desc_1, 
                              pct_desc_2    LIKE ped_itens_desc.pct_desc_2,
                              pct_desc_3    LIKE ped_itens_desc.pct_desc_3,
                              pct_desc_4    LIKE ped_itens_desc.pct_desc_4,
                              pct_desc_5    LIKE ped_itens_desc.pct_desc_5,
                              pct_desc_6    LIKE ped_itens_desc.pct_desc_6,
                              pct_desc_7    LIKE ped_itens_desc.pct_desc_7,
                              pct_desc_8    LIKE ped_itens_desc.pct_desc_8,
                              pct_desc_9    LIKE ped_itens_desc.pct_desc_9,
                              pct_desc_10   LIKE ped_itens_desc.pct_desc_10
                           END RECORD
  DEFINE t_pedido_dig_item ARRAY[500]  OF RECORD
                      cod_item             LIKE pedido_dig_item.cod_item,
                      qtd_pecas_solic      LIKE pedido_dig_item.qtd_pecas_solic,
                      pre_unit             LIKE pedido_dig_item.pre_unit,
                      pct_desc_adic        LIKE pedido_dig_item.pct_desc_adic,
                      prz_entrega          LIKE pedido_dig_item.prz_entrega, 
                      ies_incl_txt         CHAR(01),
                      ies_agrupa           SMALLINT,
                      den_item             CHAR(75) 
                           END RECORD
  DEFINE t_ped_itens_rem   ARRAY[500]  OF RECORD
                      num_sequencia       LIKE ped_itens_rem.num_sequencia,
                      dat_emis_nf_usina   LIKE ped_itens_rem.dat_emis_nf_usina,
                      dat_retorno_prev    LIKE ped_itens_rem.dat_retorno_prev,
                      cod_motivo_remessa  LIKE ped_itens_rem.cod_motivo_remessa,
                      val_estoque         LIKE ped_itens_rem.val_estoque,
                      cod_area_negocio    LIKE ped_itens_rem.cod_area_negocio,
                      cod_lin_negocio     LIKE ped_itens_rem.cod_lin_negocio,
                      num_conta           LIKE ped_itens_rem.num_conta,
                      tex_observ          LIKE ped_itens_rem.tex_observ,
                      num_pedido_compra   LIKE ped_itens_rem.num_pedido_compra
                           END RECORD
  DEFINE p_total           RECORD
                              quantidade            DECIMAL(15,3),
                              preco                 DECIMAL(17,6),
                              desc_adic             DECIMAL(06,2),
                              val_tot_bruto         DECIMAL(15,3),
                              val_tot_liquido       DECIMAL(15,3) 
                           END RECORD
  DEFINE p_totalc          RECORD
                              quantidade            DECIMAL(15,3),
                              preco                 DECIMAL(17,6),
                              desc_adic             DECIMAL(06,2),
                              val_tot_bruto         DECIMAL(15,3),
                              val_tot_liquido       DECIMAL(15,3) 
                           END RECORD
  DEFINE p_cod_empresa     LIKE empresa.cod_empresa,
         p_user            LIKE usuario.nom_usuario,
         p_ies_cons        SMALLINT,
         p_last_row        SMALLINT,
         p_status          SMALLINT,
         p_voltou          SMALLINT,
         pa_curr           SMALLINT,
         sc_curr           SMALLINT,
         p_count           SMALLINT,
         p_tela            SMALLINT,
         p_flag            SMALLINT,
         p_pula_campo      SMALLINT,
         p_num_cgc_cpf     LIKE clientes.num_cgc_cpf,
         p_ins_estadual    LIKE clientes.ins_estadual,
         p_cod_cidade      LIKE clientes.cod_cidade,
         p_qtd_estoque     LIKE estoque.qtd_liberada,
         p_qtd_carteira    LIKE ped_itens.qtd_pecas_solic,
         p_qtd_disponivel  LIKE ped_itens.qtd_pecas_solic,
         p_cod_uni_feder   CHAR(02)
  
 #alterado
  DEFINE p_ies_item_em_terc_ped   LIKE par_sup_pad.par_ies 
##DEFINE p_ctr_meta               RECORD LIKE ctr_meta.*,
  DEFINE p_juros                  RECORD LIKE juros.*,
         p_preco_minimo           RECORD LIKE preco_minimo.*,
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
         p_qtd_dias_entrega       DECIMAL(05,0),
         p_cliente_matriz_credito CHAR(01),
         p_cod_cliente_matriz     LIKE clientes.cod_cliente_matriz,
         p_ies_tip_controle       LIKE nat_operacao.ies_tip_controle
  
# DEFINE p_comando                CHAR(80),
  DEFINE p_caminho                CHAR(80),
#        p_nom_tela               CHAR(80),
         p_help                   CHAR(80),
         p_cancel                 INTEGER
# DEFINE p_versao       CHAR(17) #Favor Nao Alterar esta linha (SUPORTE)
  DEFINE p_versao       CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS
  DEFINE m_cod_nat_oper_ref LIKE nat_oper_refer.cod_nat_oper_ref

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0185-10.02.01" #Favor nao alterar esta linha (SUPORTE)
  WHENEVER ANY ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
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
  
  CALL log001_acessa_usuario("ESPEC999","")
     RETURNING p_status, p_cod_empresa, p_user

  IF p_status = 0 THEN 
     CALL pol0185_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0185_controle()
#--------------------------#
  INITIALIZE p_pedido_dig_mest.*,
             p_pedido_dig_mestr.*,
             p_pedido_dig_obs.*,
             p_pedido_dig_obsr.*,
             p_pedido_dig_ent.*,
             p_pedido_dig_entr.*,
             p_pedido_dig_item.* TO NULL

  CALL  pol0185_cria_t_mestre()

  CALL log006_exibe_teclas("01 02", p_versao)
  WHENEVER ERROR CONTINUE
  CALL log130_procura_caminho("pol0185") RETURNING p_nom_tela
  OPEN WINDOW w_pol0185 AT 2,02 WITH FORM p_nom_tela    
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  WHENEVER ERROR STOP  
  
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui Pedido "
      HELP 0001
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","pol0185","IN")     
      THEN LET p_cod_moeda_cons = 0 
           CALL pol0185_inclusao_pedido()
           IF p_houve_erro = FALSE THEN 
              CALL log085_transacao("COMMIT")
           #  COMMIT WORK
              IF sqlca.sqlcode = 0 THEN 
              ELSE CALL log003_err_sql("INCLUSAO ","PEDIDOS ")
                   CALL log085_transacao("ROLLBACK")
              #    ROLLBACK WORK
              END IF
           ELSE 
              CALL log085_transacao("ROLLBACK")
           #  ROLLBACK WORK
           END IF
      ELSE ERROR " Usuario nao autorizado para fazer inclusao "
      END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0185_sobre() 
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
  END MENU
  WHENEVER ANY ERROR CONTINUE  
  CLOSE WINDOW w_pol0185 
  WHENEVER ANY ERROR STOP
END FUNCTION

#-----------------------#
FUNCTION pol0185_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#----------------------------------------------------------------------#
 FUNCTION  pol0185_insert_t_mestre(p_num_pedido,      p_cod_nat_oper,
                                   p_cod_cnd_pgto,    p_pct_desc_adic,
                                   p_pct_desc_financ, p_cod_moeda)
#----------------------------------------------------------------------#
 DEFINE p_num_pedido       LIKE pedidos.num_pedido,
        p_cod_nat_oper     LIKE pedidos.cod_nat_oper ,
        p_cod_cnd_pgto     LIKE pedidos.cod_cnd_pgto,
        p_pct_desc_adic    LIKE pedidos.pct_desc_adic,
        p_pct_desc_financ  LIKE pedidos.pct_desc_financ,
        p_cod_moeda        LIKE pedidos.cod_moeda
  
 INSERT INTO t_mestre VALUES (p_num_pedido,    p_cod_nat_oper,    p_cod_cnd_pgto,
                              p_pct_desc_adic, p_pct_desc_financ, p_cod_moeda );
 END FUNCTION

#-------------------------------#
 FUNCTION pol0185_cria_t_mestre()
#-------------------------------#
 WHENEVER ERROR CONTINUE
 DROP TABLE t_mestre
 DROP TABLE t_item
 WHENEVER ERROR STOP
  
 CREATE TEMP  TABLE t_mestre
      ( num_pedido            DECIMAL(6,0),
        cod_nat_oper          INTEGER,        
        cod_cnd_pgto          DECIMAL(3,0),
        pct_desc_adic         DECIMAL(4,2),
        pct_desc_financ       DECIMAL(4,2),
        cod_moeda             DECIMAL(3,0)  );
  
 CREATE TEMP  TABLE t_item
      ( num_pedido            DECIMAL(6,0),
        cod_item              CHAR(15),
        num_sequencia         DECIMAL(5,0),
        pre_unit              DECIMAL(17,6),
        qtd_pecas_solic       DECIMAL(10,3), 
        prz_entrega           DATE,
        pct_desc_adic         DECIMAL(4,2),
        qtd_pecas_bnf         DECIMAL(10,3)   );
 END FUNCTION

#---------------------------------#
 FUNCTION pol0185_inclusao_pedido()
#---------------------------------#
 LET p_houve_erro = FALSE
 CALL log085_transacao("BEGIN")
#BEGIN WORK
  
 SELECT par_vdp.*  INTO p_par_vdp.*
        FROM par_vdp
        WHERE par_vdp.cod_empresa = p_cod_empresa
 IF   sqlca.sqlcode = NOTFOUND
 THEN PROMPT " PARAMETROS para consistencia de pedidos nao encontrados Tecle ENTER "
      FOR p_comando
      RETURN
 END IF
 IF   p_par_vdp.par_vdp_txt[39,39] = "S"
 THEN SELECT juros.*  INTO p_juros.*
             FROM juros
             WHERE juros.cod_empresa = p_cod_empresa
               AND juros.ano_refer   = YEAR(TODAY)
               AND juros.mes_refer   = MONTH(TODAY)
      IF   sqlca.sqlcode = NOTFOUND
      THEN PROMPT " JUROS p/ consistencia de rentabilidade nao encontrados Tecle ENTER "
           FOR p_comando 
           RETURN
      END IF
 END IF
 
 SELECT par_ies
   INTO p_ies_item_em_terc_ped
   FROM par_sup_pad
  WHERE cod_empresa = p_cod_empresa
    AND cod_parametro = "ies_item_em_terc_ped"
 IF p_ies_item_em_terc_ped IS NULL OR
    p_ies_item_em_terc_ped = " "   THEN 
    LET p_ies_item_em_terc_ped = "N"
 END IF 
 
 LET p_pedido_dig_mestr.* = p_pedido_dig_mest.*
 LET p_pedido_dig_obsr.*  = p_pedido_dig_obs.*
 LET p_pedido_dig_entr.*  = p_pedido_dig_ent.*
  
 INITIALIZE p_pedido_dig_mest.*,
            p_pedido_dig_obs.*,
            p_pedido_dig_ent.*,
            p_pedido_dig_item.*,
            t_pedido_dig_item   TO NULL

 INITIALIZE p_ped_itens_desc.* TO NULL

 CALL pol0185_move_dados()

 LET p_tela         = 1
 LET p_flag         = 1
 LET p_count        = 0
 LET ies_incl_txt   = "N"
 LET p_voltou       = 0
 LET p_erro         = FALSE
 LET p_consist_cred = FALSE
  
 WHILE p_flag = 1
    CASE
      WHEN p_tela = 1
           CALL pol0185_entrada_dados_mestr("INCLUSAO")   RETURNING p_status
      WHEN p_tela = 2
           CALL pol0185_entrada_dados_ent_obs("INCLUSAO") RETURNING p_status
      WHEN p_tela = 3
           CALL pol0185_entrada_dados_item("INCLUSAO")    RETURNING p_status
      WHEN p_tela = 4
           CALL pol0185_total("INCLUSAO")                 RETURNING p_status
    END CASE
 END WHILE
  
 IF   p_status = 0
 THEN CALL pol0185_efetiva_inclusao()
      CALL log006_exibe_teclas("01 02", p_versao)
      CURRENT WINDOW IS w_pol0185
      CALL pol0185_exibe_dados()
      IF   p_erro = FALSE
      THEN MESSAGE " Inclusao efetuada com sucesso " ATTRIBUTE(REVERSE)
      ELSE MESSAGE " Pedido Consistido " ATTRIBUTE(REVERSE)
      END IF
 ELSE LET  p_pedido_dig_mest.* = p_pedido_dig_mestr.*
      LET  p_pedido_dig_obs.*  = p_pedido_dig_obsr.*
      LET  p_pedido_dig_ent.*  = p_pedido_dig_entr.*
      LET  p_pedido_dig_mest.* = p_pedido_dig_mestr.*
      CALL pol0185_exibe_dados()
      CALL log006_exibe_teclas("01 02", p_versao)
      CURRENT WINDOW IS w_pol0185
      ERROR " Inclusao Cancelada "
 END IF
 END FUNCTION

#---------------------------------------------#
 FUNCTION pol0185_entrada_dados_mestr(p_funcao)
#---------------------------------------------#
 DEFINE p_funcao                CHAR(12) 

 CALL log006_exibe_teclas("01 02 07", p_versao)
 WHENEVER ERROR CONTINUE
 CALL log130_procura_caminho("pol0185") RETURNING p_nom_tela
 OPEN WINDOW w_pol0185 AT 2,02 WITH FORM p_nom_tela    
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 WHENEVER ERROR STOP  
 CURRENT WINDOW IS w_pol0185

 LET p_pedido_dig_mest.cod_moeda        = 1
 LET p_pedido_dig_mest.ies_comissao     = "S"
 LET p_pedido_dig_mest.ies_preco        = "R"
 LET p_pedido_dig_mest.ies_frete        = 3
 LET p_pedido_dig_mest.ies_tip_entrega  = 3
 LET p_pedido_dig_mest.ies_embal_padrao = 1
 LET p_ies_minimo    = "N" 
 LET p_ies_desconto  = "N"  
 LET p_ies_faturado  = "N" 
 LET p_ies_cond      = "N" 
  
 INPUT BY NAME p_pedido_dig_mest.cod_empresa,
               p_pedido_dig_mest.num_pedido,
               p_pedido_dig_mest.cod_tip_carteira,
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
               p_pedido_dig_mest.num_list_preco,
               p_pedido_dig_mest.ies_preco,
               p_pedido_dig_mest.pct_desc_adic, 
               p_pedido_dig_mest.pct_desc_financ,
               p_pedido_dig_mest.cod_cnd_pgto,
               p_pedido_dig_mest.ies_frete,
               p_pedido_dig_mest.ies_tip_entrega,
               p_pedido_dig_mest.cod_transpor,
               p_pedido_dig_mest.cod_consig,
               p_pedido_dig_mest.ies_finalidade,
               p_pedido_dig_mest.cod_moeda,
               p_pedido_dig_mest.ies_embal_padrao,
               ies_incl_txt                         WITHOUT DEFAULTS
               
       BEFORE FIELD num_pedido
              IF   p_voltou = 1
              THEN NEXT FIELD cod_tip_carteira
              END IF
              IF   p_par_vdp.num_prx_pedido <> 0 
              THEN LET p_pedido_dig_mest.num_pedido = pol0185_busca_num_pedido()
                   DISPLAY p_pedido_dig_mest.num_pedido TO num_pedido
                   NEXT FIELD cod_tip_carteira
              END IF

       AFTER  FIELD num_pedido
              IF   pol0185_verifica_pedido()
              THEN ERROR " PEDIDO ja' digitado "
                   NEXT FIELD num_pedido
              END IF
       
       BEFORE FIELD cod_nat_oper
              CALL pol0185_mostra_zoom()

       AFTER  FIELD cod_nat_oper
              IF p_pedido_dig_mest.cod_nat_oper < 100 THEN
                 ERROR " Natureza da operacao deve ser maior que 100."
                 NEXT FIELD cod_nat_oper
              END IF
              IF pol0185_verifica_natureza_operacao()
              THEN ERROR " Natureza da operacao nao cadastrada. "
                   NEXT FIELD cod_nat_oper
              ELSE IF pol0185_verifica_fiscal_par() = FALSE
                   THEN NEXT FIELD cod_nat_oper
                   END IF
              END IF
              CALL pol0185_apaga_zoom()

       AFTER  FIELD dat_emis_repres
              IF   p_pedido_dig_mest.dat_emis_repres > TODAY
              THEN ERROR "Data de emissao invalida "
                   NEXT FIELD dat_emis_repres
              END IF

       AFTER  FIELD dat_prazo_entrega
              IF   p_pedido_dig_mest.dat_prazo_entrega < TODAY
              THEN ERROR " Data entrega menor que a data corrente"
                   NEXT FIELD dat_prazo_entrega
              END IF
              IF   p_pedido_dig_mest.dat_prazo_entrega IS NULL OR 
                   p_pedido_dig_mest.dat_prazo_entrega = " "
              THEN ERROR " Data de entrega nao pode ser Nula "
                   NEXT FIELD dat_prazo_entrega
              END IF
              IF   pol0185_confirma_prazo_entrega() = FALSE
              THEN NEXT FIELD dat_prazo_entrega
              END IF
    
       BEFORE FIELD cod_cliente
              CALL pol0185_mostra_zoom()

       AFTER  FIELD cod_cliente
              IF pol0185_verifica_cliente() = TRUE
                 THEN IF pol0185_busca_repres() = FALSE
                         THEN ERROR " Cliente sem Representante"
                              NEXT FIELD cod_cliente
                      END IF
              ELSE NEXT FIELD cod_cliente
              END IF
              IF   pol0185_verifica_credito_cliente() = FALSE
              THEN LET p_erro = TRUE
              END IF
              CALL pol0185_apaga_zoom()
              IF p_pedido_dig_mest.cod_cliente IS NOT NULL THEN
                 SELECT cod_transpor
                    INTO p_pedido_dig_mest.cod_transpor
                 FROM praca_cli_transp
                 WHERE praca_cli_transp.cod_cliente = p_pedido_dig_mest.cod_cliente
                 IF SQLCA.SQLCODE = 0 THEN
                    DISPLAY BY NAME p_pedido_dig_mest.cod_transpor 
                    SELECT nom_cliente into p_nom_trans
                      FROM clientes 
                     WHERE cod_cliente = p_pedido_dig_mest.cod_transpor 
                    DISPLAY p_nom_trans at 19,23
                 END IF
# osvaldo
                 SELECT  cod_nat_oper
                   INTO  p_pedido_dig_mest.cod_nat_oper
                 FROM cli_oper_albras
                 WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
            #    IF SQLCA.SQLCODE = 0 THEN
            #       DISPLAY BY NAME p_pedido_dig_mest.cod_nat_oper 
            #       NEXT FIELD dat_emis_repres
            #    END IF
# osvaldo
              END IF

       BEFORE FIELD cod_repres
              CALL pol0185_mostra_zoom()
  
       AFTER  FIELD cod_repres
             IF   p_par_vdp.num_prx_pedido <> 0  
             THEN IF pol0185_verifica_pedido_repres()
                  THEN ERROR " PEDIDO_REPRESENTANTE ja digitado. "
                       NEXT FIELD num_pedido_repres
                  END IF 
             END IF 
             IF pol0185_verifica_repres(p_pedido_dig_mest.cod_repres) = FALSE
             THEN 
                ERROR "Representante nao cadastrado "
                NEXT FIELD cod_repres
             ELSE
{ O.S.50780-Ju   IF pol0185_verifica_repres_canal() = FALSE THEN
                    ERROR "Representante nao relacionado com o cliente no ",
                          "canal de vendas."
                    NEXT FIELD cod_repres
                 END IF
}             END IF
              CALL pol0185_apaga_zoom()
  
       BEFORE FIELD pct_comissao
              IF   p_pedido_dig_mest.ies_comissao = "N"
              THEN NEXT FIELD cod_repres_adic
              END IF
 
       BEFORE FIELD cod_repres_adic
              CALL pol0185_mostra_zoom()
  
       AFTER  FIELD cod_repres_adic
              IF   pol0185_verifica_repres(p_pedido_dig_mest.cod_repres_adic) = FALSE
              THEN ERROR "Representante adicional nao cadastrado "
                   NEXT FIELD cod_repres_adic
              END IF
              CALL pol0185_apaga_zoom()

       BEFORE FIELD num_list_preco
              CALL pol0185_mostra_zoom()
 
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
              ELSE IF   pol0185_verifica_lista_preco() 
                   THEN ERROR " Lista de preco nao cadastrada. "
                        NEXT FIELD num_list_preco
                   ELSE IF   p_pedido_dig_mest.dat_emis_repres >= p_desc_preco_mest.dat_ini_vig AND  
                             p_pedido_dig_mest.dat_emis_repres <= p_desc_preco_mest.dat_fim_vig
                        THEN IF   p_desc_preco_mest.ies_bloq_pedido = "S"
                             THEN LET p_erro = TRUE  
                             END IF
                        ELSE LET p_erro = TRUE
                        END IF
                   END IF
              END IF
              CALL pol0185_apaga_zoom()

       AFTER  FIELD ies_preco 
              IF   p_pedido_dig_mest.ies_preco = "F"
              THEN DISPLAY "FIRME"       TO den_ies_preco
              ELSE DISPLAY "REAJUSTAVEL" TO den_ies_preco            
              END IF

       BEFORE FIELD pct_desc_adic
              LET p_pct_desc_tot = 0

       AFTER  FIELD pct_desc_adic
              IF   p_pedido_dig_mest.pct_desc_adic IS NULL OR               
                   p_pedido_dig_mest.pct_desc_adic = " "
              THEN ERROR "Desconto adicional invalido "
                   NEXT FIELD pct_desc_adic
              END IF
              IF   p_pedido_dig_mest.pct_desc_adic > p_par_vdp.pct_desc_adic
              THEN ERROR "Pct. desconto adicional maior que limite "
                   LET p_erro = TRUE
              END IF
              IF   p_pedido_dig_mest.pct_desc_adic > 0
              THEN LET p_desc_mest = 100 - p_pedido_dig_mest.pct_desc_adic
                   LET p_desc_mest = 100 - (p_desc_mest -
                                          ( p_desc_mest *
                                            p_desc_unico_mest / 100))
                   LET p_desc_unico_mest = p_desc_mest
                   IF   p_desc_mest > p_par_vdp.pct_desc_adic
                   THEN ERROR "Descontos do Pedido Mestre maior que o limite"
                        LET p_erro = TRUE
                   END IF
              END IF 
       AFTER  FIELD pct_desc_financ
              IF   p_pedido_dig_mest.pct_desc_financ IS NULL OR               
                   p_pedido_dig_mest.pct_desc_financ = " "
              THEN ERROR "Desconto financeiro invalido "
                   NEXT FIELD pct_desc_financ
              END IF
              IF   p_pedido_dig_mest.pct_desc_financ > p_par_vdp.pct_desc_financ
              THEN ERROR "Pct. desconto financeiro maior que limite " 
                   NEXT FIELD pct_desc_financ #LET p_erro = TRUE
              END IF
       BEFORE FIELD cod_cnd_pgto
              CALL pol0185_mostra_zoom()

       AFTER  FIELD cod_cnd_pgto
	             IF   pol0185_verifica_cnd_pagamento()
              THEN NEXT FIELD cod_cnd_pgto
              END IF
              CALL pol0185_apaga_zoom()

       AFTER FIELD num_pedido_repres
             IF   p_par_vdp.num_prx_pedido <> 0  
             THEN IF pol0185_verifica_pedido_repres()
                  THEN ERROR " PEDIDO_REPRESENTANTE ja digitado. "
                       NEXT FIELD num_pedido_repres
                  END IF 
             END IF 

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

       BEFORE FIELD cod_transpor
              CALL pol0185_mostra_zoom()

       AFTER  FIELD cod_transpor
              IF   p_pedido_dig_mest.cod_transpor IS NOT NULL AND
                   p_pedido_dig_mest.cod_transpor <> " "
              THEN IF   pol0185_verifica_transportadora(p_pedido_dig_mest.cod_transpor) = FALSE
                   THEN ERROR " Transportadora nao cadastrada "
                        NEXT FIELD cod_transpor
                   END IF
              END IF
              CALL pol0185_apaga_zoom()

       BEFORE FIELD cod_consig
              CALL pol0185_mostra_zoom()

       AFTER  FIELD cod_consig  
              IF   p_pedido_dig_mest.cod_consig IS NOT NULL AND
                   p_pedido_dig_mest.cod_consig <> " "
              THEN IF   pol0185_verifica_transportadora(p_pedido_dig_mest.cod_consig) = FALSE
                   THEN ERROR " Consignatario nao cadastrado "
                        NEXT FIELD cod_consig
                   END IF
              END IF
              CALL pol0185_apaga_zoom()
 
       AFTER FIELD ies_finalidade 
              IF pol0185_verifica_finalidade() = FALSE
              THEN NEXT FIELD ies_finalidade
              END IF

       BEFORE FIELD cod_moeda
              CALL pol0185_mostra_zoom()
   
       AFTER  FIELD cod_moeda
              IF   pol0185_verifica_moeda() = FALSE
              THEN ERROR "Moeda nao cadastrada "
                   NEXT FIELD cod_moeda
              END IF
              CALL pol0185_apaga_zoom()
    
       BEFORE FIELD cod_tip_carteira
              IF p_cod_empresa = "01" OR 
                 p_cod_empresa = "03"
              THEN LET p_pedido_dig_mest.cod_tip_carteira = "01"
              ELSE IF p_cod_empresa = "05"
                   THEN LET p_pedido_dig_mest.cod_tip_carteira = "03"
                   END IF
              END IF
              CALL pol0185_mostra_zoom()
   
      AFTER FIELD cod_tip_carteira
            IF pol0185_verifica_carteira() = FALSE
            THEN ERROR "Carteira nao cadastrada "
               NEXT FIELD cod_tip_carteira
            END IF
            CALL pol0185_apaga_zoom()

      AFTER FIELD ies_incl_txt
         IF ies_incl_txt IS NOT NULL THEN 
            IF ies_incl_txt = "S" THEN
               IF vdp243_digita_texto(p_pedido_dig_mest.num_pedido, "0") = FALSE
                  THEN 
                  LET ies_incl_txt = "N"
               END IF
               CALL log006_exibe_teclas("01 02 07", p_versao)
                  CURRENT WINDOW IS w_pol0185
            END IF
         END IF
    
       ON KEY (control-w, f1)
              CALL pol0185_help()
    
       ON KEY (control-z)
              CALL pol0185_popup(1)
 END INPUT
 IF   int_flag = 0
 THEN LET p_status = 0
      LET p_tela = 2
      RETURN p_status
 ELSE LET p_status = 1
      LET p_tela = 0
      LET p_flag = 0
      LET int_flag = 0
      RETURN p_status
 END IF
END FUNCTION

#-------------------------------#
 FUNCTION pol0185_mostra_zoom()
#-------------------------------#
 DISPLAY "( Zoom )" AT 3,68
 END FUNCTION

#------------------------------#
 FUNCTION pol0185_apaga_zoom()
#------------------------------#
 DISPLAY "--------" AT 3,68
 END FUNCTION

#------------------------------------------#
 FUNCTION pol0185_confirma_prazo_entrega()
#------------------------------------------#
  IF   p_pedido_dig_mest.dat_prazo_entrega > (TODAY + 30)
  THEN ERROR " Prazo de entrega e' superior a 30 dias "
       RETURN log004_confirm(17,40)
  END IF 
  RETURN TRUE
END FUNCTION

#-------------------------------------------------#
 FUNCTION pol0185_entrada_dados_ent_obs(p_funcao)
#-------------------------------------------------#
 DEFINE p_funcao                CHAR(12)
  
 CALL log006_exibe_teclas("01 02 07", p_versao)
 WHENEVER ERROR CONTINUE
 CALL log130_procura_caminho("pol01851") RETURNING p_nom_tela
 OPEN WINDOW w_pol01851 AT 2,02 WITH FORM p_nom_tela     
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 WHENEVER ERROR STOP  
 CURRENT WINDOW IS w_pol01851
 #DISPLAY FORM f_pol01851 
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
           CALL pol0185_mostra_zoom()

    AFTER  FIELD num_sequencia
	          IF   p_num_sequencia IS NULL
	          THEN 
	          ELSE IF   pol0185_verifica_endeco_entrega()
	               THEN NEXT FIELD tex_observ_1
	               ELSE ERROR " Endereco de entrega nao cadastrado"
		                   NEXT FIELD num_sequencia
	               END IF
	          END IF
           CALL pol0185_apaga_zoom()
    
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
           CALL pol0185_mostra_zoom()
    AFTER  FIELD cod_cidade
           IF   pol0185_verifica_cidade()
           THEN ERROR " Cidade nao cadastrado. "
                NEXT FIELD cod_cidade
           END IF
           CALL pol0185_apaga_zoom()
    
    AFTER  FIELD num_cgc
           IF   p_pedido_dig_ent.num_cgc = "   .   .   /    -  " OR
                p_pedido_dig_ent.num_cgc = "000.000.000/0000-00"
           THEN INITIALIZE p_pedido_dig_ent.num_cgc TO NULL
           ELSE IF   log019_verifica_cgc_cpf(p_pedido_dig_ent.num_cgc)
                THEN 
                ELSE ERROR " C.G.C OU C.P.F invalido"
                     NEXT FIELD num_cgc
                END IF
           END IF
    
    ON KEY (control-w, f1)
           CALL pol0185_help()
    
    ON KEY (control-z)
           CALL pol0185_popup(1)
  END INPUT
  IF   int_flag = 0
  THEN LET p_status = 0
       LET p_tela = 3
       RETURN p_status
  ELSE LET p_status = 1
       LET p_voltou = 1
       LET p_tela = 1
       LET int_flag = 0
       RETURN p_status
  END IF
END FUNCTION

#--------------------------------------#
 FUNCTION pol0185_verifica_lista_preco()
#--------------------------------------#
  SELECT *
    INTO p_desc_preco_mest.*
    FROM desc_preco_mest
   WHERE desc_preco_mest.cod_empresa    = p_cod_empresa
     AND desc_preco_mest.num_list_preco = p_pedido_dig_mest.num_list_preco
  IF   sqlca.sqlcode = NOTFOUND OR
       p_pedido_dig_mest.num_list_preco = " "
  THEN RETURN true
  ELSE RETURN false
  END IF
END FUNCTION

#---------------------------------------------------------#
 FUNCTION pol0185_verifica_transportadora(p_cod_transpor)
#---------------------------------------------------------#
 DEFINE p_cod_transpor    LIKE pedido_dig_mest.cod_transpor

 SELECT *  FROM transport
        WHERE cod_transpor  = p_cod_transpor
 IF   sqlca.sqlcode = NOTFOUND
 THEN SELECT *  FROM clientes
             WHERE cod_cliente  = p_cod_transpor
      IF   sqlca.sqlcode = 0
      THEN RETURN TRUE
      ELSE RETURN FALSE
      END IF
 ELSE RETURN TRUE
 END IF
 END FUNCTION

#------------------------------#
 FUNCTION pol0185_cond_cliente()
#------------------------------#
  SELECT * 
    FROM cli_cond_pgto
   WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
  IF   sqlca.sqlcode = NOTFOUND 
  THEN RETURN TRUE
  ELSE SELECT * 
         FROM cli_cond_pgto
	       WHERE cod_cliente  = p_pedido_dig_mest.cod_cliente
          AND cod_cnd_pgto = p_pedido_dig_mest.cod_cnd_pgto
       IF   sqlca.sqlcode = NOTFOUND
       THEN RETURN FALSE
       ELSE RETURN TRUE
       END IF
  END IF
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0185_verifica_endeco_entrega()
#-----------------------------------------#
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
  IF   sqlca.sqlcode = 0
  THEN LET p_pedido_dig_ent.num_sequencia = p_num_sequencia
       DISPLAY BY NAME p_pedido_dig_ent.*
       RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#----------------------------------------------#
 FUNCTION pol0185_entrada_dados_item(p_funcao)
#----------------------------------------------#
 DEFINE p_funcao          CHAR(12),  
        p_qtd_c_decim     DECIMAL(15,5),
        p_qtd_resto       DECIMAL(15,5),
        p_qtd_s_decim     INTEGER,
        p_desc_adic_m_i   DECIMAL(5,2),                
        p_qtd_padr_embal  LIKE item_embalagem.qtd_padr_embal,
        p_pct_desc_m      LIKE ped_itens.pct_desc_adic,
        p_pct_desc_i      LIKE ped_itens.pct_desc_adic,
        p_campo           SMALLINT
 DEFINE p_achou           SMALLINT ,
        p_pct_comissao    LIKE comissao_par.pct_comissao
  
 CALL log006_exibe_teclas("01 02 05 06 07", p_versao)
 WHENEVER ERROR CONTINUE
 CALL log130_procura_caminho("pol01852") RETURNING p_nom_tela
 OPEN WINDOW w_pol01852 AT 2,02 WITH FORM p_nom_tela    
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 WHENEVER ERROR STOP  
 CURRENT WINDOW IS w_pol01852
 #DISPLAY FORM f_pol01852 

 DISPLAY p_cod_empresa                 TO cod_empresa
 DISPLAY p_pedido_dig_mest.num_pedido  TO num_pedido
  
 LET p_pedido_dig_item.num_pedido  =  p_pedido_dig_mest.num_pedido
 LET p_valor_pedido  = 0
 LET pa_curr         = 1
 LET t_pedido_dig_item[pa_curr].prz_entrega = p_pedido_dig_mest.dat_prazo_entrega
  
 INPUT ARRAY t_pedido_dig_item WITHOUT DEFAULTS FROM s_pedido_dig_item.*
    
       BEFORE ROW
              LET pa_curr = arr_curr()
              LET sc_curr = scr_line()
    
       BEFORE FIELD cod_item
              CALL pol0185_mostra_zoom()
              CALL pol0185_mostra_estoque(t_pedido_dig_item[pa_curr].cod_item)
#             DISPLAY ""   TO qtd_disponivel
#             DISPLAY ""   TO qtd_carteira
              DISPLAY "                "  AT 5,20
              DISPLAY "Desconto pedido:"  at 5,3
              DISPLAY p_desc_unico_mest at 5,20   
              IF p_desc_unico_mest IS NULL THEN
                 LET p_desc_seq0 =0                  
              ELSE
                 LET p_desc_seq0 = p_desc_unico_mest 
              END IF
 
       AFTER  FIELD cod_item
              LET pa_curr = arr_curr()
              LET sc_curr = scr_line()
              LET p_num_sequencia_desc = pa_curr
              IF   t_pedido_dig_item[pa_curr].cod_item IS  NULL     
              THEN EXIT INPUT
              ELSE CALL pol0185_verifica_item() 
                        RETURNING p_status, p_qtd_padr_embal
                   IF   p_status = 0
                   THEN NEXT FIELD cod_item
                   END IF
              END IF
              CALL pol0185_apaga_zoom()
              IF   p_pedido_dig_mest.ies_comissao = "S" AND 
                   p_pedido_dig_mest.pct_comissao = 0 
              THEN CALL vdp088_consiste_perc_comissao(p_cod_empresa,
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
                   IF   p_achou = FALSE 
                   THEN ERROR " Percentual de comissao nao encontrado."
                        NEXT FIELD cod_item
                   END IF
              END IF
    
       BEFORE FIELD  qtd_pecas_solic
              IF   t_pedido_dig_item[pa_curr].qtd_pecas_solic IS NULL 
              THEN LET t_pedido_dig_item[pa_curr].qtd_pecas_solic = 0
                   DISPLAY t_pedido_dig_item[pa_curr].qtd_pecas_solic TO
                           s_pedido_dig_item[sc_curr].qtd_pecas_solic
              END IF

       AFTER  FIELD  qtd_pecas_solic
              LET  pa_curr = arr_curr()
              IF   t_pedido_dig_item[pa_curr].qtd_pecas_solic IS NULL  OR
                   t_pedido_dig_item[pa_curr].qtd_pecas_solic <= 0
              THEN ERROR " Qtd. deve ser maior que zero "
                   NEXT FIELD qtd_pecas_solic
              ELSE IF   p_pedido_dig_mest.ies_embal_padrao = "1" OR   
                        p_pedido_dig_mest.ies_embal_padrao = "2"
                   THEN LET p_qtd_c_decim = t_pedido_dig_item[pa_curr].qtd_pecas_solic /
                                            p_qtd_padr_embal
                        LET p_qtd_s_decim = t_pedido_dig_item[pa_curr].qtd_pecas_solic /
                                             p_qtd_padr_embal
                        LET p_qtd_resto    = p_qtd_c_decim - p_qtd_s_decim
                        IF   p_qtd_resto = 0
                        THEN IF   t_pedido_dig_item[pa_curr].qtd_pecas_solic < p_qtd_padr_embal
                             THEN ERROR "Qtd  solic. menor que Qtd padrao embal."
                                  NEXT FIELD qtd_pecas_solic
                             END IF
                        ELSE ERROR "Pedido padrao embal. qtd. pecas nao padrao embal."
                             NEXT FIELD qtd_pecas_solic
                        END IF
                   END IF
              END IF
              IF   p_ies_tip_controle = "2"
              THEN IF   pol0185_entrada_ped_itens_rem() = FALSE
                   THEN ERROR "Informe as informacoes da REMESSA corretamente"
                        NEXT FIELD qtd_pecas_solic
                   END IF
              END IF  
    
       BEFORE FIELD pre_unit
#          IF   (fgl_lastkey() = fgl_keyval("left"))  
#            THEN NEXT FIELD qtd_pecas_solic    
#            ELSE NEXT FIELD pct_desc_adic1
#          END IF 
    IF t_pedido_dig_item[pa_curr].pre_unit IS NULL THEN
       LET t_pedido_dig_item[pa_curr].pre_unit = 0
       DISPLAY t_pedido_dig_item[pa_curr].pre_unit TO
               s_pedido_dig_item[sc_curr].pre_unit
    END IF

       AFTER  FIELD pre_unit
              IF   t_pedido_dig_item[pa_curr].pre_unit IS NULL    
              THEN ERROR "Preco unitario invalido "
                   NEXT FIELD pre_unit      
              END IF

       BEFORE FIELD pct_desc_adic 
              IF   t_pedido_dig_item[pa_curr].pct_desc_adic IS NULL 
              THEN LET t_pedido_dig_item[pa_curr].pct_desc_adic = 0
                   DISPLAY t_pedido_dig_item[pa_curr].pct_desc_adic TO
                           s_pedido_dig_item[sc_curr].pct_desc_adic
              END IF
              LET p_num_sequencia_desc = arr_curr()
              CALL pol0185_mostra_zoom()

       AFTER  FIELD pct_desc_adic 
              DISPLAY "--------" AT 3,68
              LET pa_curr = arr_curr()
              IF   t_pedido_dig_item[pa_curr].pct_desc_adic IS NULL   
              THEN ERROR " Percentual de desconto invalido "
                   NEXT FIELD pct_desc_adic 
              ELSE LET p_desc_adic_m_i = 100 - p_pedido_dig_mest.pct_desc_adic
                   LET p_desc_adic_m_i = 100 - (p_desc_adic_m_i - 
                                         ( p_desc_adic_m_i * 
                                          t_pedido_dig_item[pa_curr].pct_desc_adic  
                                         / 100))
                   IF   p_desc_adic_m_i > p_par_vdp.pct_desc_adic
                   THEN ERROR "Desc. Adic. Mestre + Desc. Adic. Item maior que o limite"
                        LET p_erro = TRUE          
                   END IF
                   LET p_desc_tot_geral = 100 - p_desc_mest
                   LET p_desc_tot_geral = 100 - (p_desc_tot_geral -
                                                   ( p_desc_tot_geral *
                                                     p_desc_adic_m_i / 100))

                   IF   p_desc_tot_geral > p_par_vdp.pct_desc_adic
                   THEN ERROR "Desc. Adic. Mestre + Desc. Adic. Item maior que o limite"
                        LET p_erro = TRUE
                   END IF
              END IF
              IF   t_pedido_dig_item[pa_curr].pct_desc_adic IS NULL
              THEN LET t_pedido_dig_item[pa_curr].pct_desc_adic = 0
              END IF
#  osvaldo
              
               CALL pol0185_calcula_desc_geral()    

               IF p_desc_geral > 0 THEN
                  LET p_pre_unit_real = t_pedido_dig_item[pa_curr].pre_unit -
                                        (t_pedido_dig_item[pa_curr].pre_unit *
                                        (p_desc_geral / 100))
               ELSE 
                  LET p_pre_unit_real = t_pedido_dig_item[pa_curr].pre_unit 
               END IF

               SELECT pre_unit
                  INTO p_ult_pre
               FROM ult_pre_cli_alb
               WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
                 AND cod_item = t_pedido_dig_item[pa_curr].cod_item
               IF SQLCA.SQLCODE = 0 THEN
                  IF p_pre_unit_real < p_ult_pre THEN
                     ERROR "Preco Unitario Menor que Ultimo Preco Praticado"
                     LET p_erro = TRUE            
                     LET p_ies_faturado = "S"      
                  END IF
               ELSE
                   LET p_ies_faturado = "N"
               END IF

               SELECT pre_minimo
                  INTO p_pre_minimo 
               FROM pre_min_albras
               WHERE cod_empresa = p_cod_empresa                  
                 AND cod_uni_feder = p_cod_uni_feder
                 AND cod_item = t_pedido_dig_item[pa_curr].cod_item
               IF SQLCA.SQLCODE = 0 THEN
                  IF p_pre_unit_real < p_pre_minimo THEN
                     ERROR "Preco Unitario Menor que Preco Minimo Praticado"
                     LET p_ies_minimo = "S"        
                     LET p_erro = TRUE            
                  END IF
               END IF

               SELECT max_desc  
                  INTO p_max_desc   
               FROM desc_cli_albras
               WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
                 AND cod_item = t_pedido_dig_item[pa_curr].cod_item
                 AND cod_cnd_pgto = p_pedido_dig_mest.cod_cnd_pgto
               IF SQLCA.SQLCODE = 0 THEN
                  IF p_desc_geral > p_max_desc THEN
                     ERROR "Percentual de Desconto Maior que Permitido"
                     LET p_ies_desconto = "S"      
                     LET p_erro = TRUE            
                  END IF
               END IF
#  osvaldo

               CALL pol0185_verifica_valor_pedido() 
{
    LET p_pre_unit_liq      = t_pedido_dig_item[pa_curr].pre_unit *
                                     p_val_cotacao_ped
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (p_pedido_dig_mest.pct_desc_adic *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[1].pct_desc_1 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[1].pct_desc_2 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[1].pct_desc_3 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[1].pct_desc_4 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[1].pct_desc_5 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[1].pct_desc_6 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[1].pct_desc_7 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[1].pct_desc_8 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[1].pct_desc_9 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[1].pct_desc_10 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_pedido_dig_item[pa_curr].pct_desc_adic *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[pa_curr + 1].pct_desc_1 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[pa_curr + 1].pct_desc_2 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[pa_curr + 1].pct_desc_3 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[pa_curr + 1].pct_desc_4 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[pa_curr + 1].pct_desc_5 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[pa_curr + 1].pct_desc_6 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[pa_curr + 1].pct_desc_7 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[pa_curr + 1].pct_desc_8 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[pa_curr + 1].pct_desc_9 *
                              p_pre_unit_liq / 100)
    LET p_pre_unit_liq      = p_pre_unit_liq -
                              (t_ped_itens_desc[pa_curr + 1].pct_desc_10 *
                              p_pre_unit_liq / 100)
}
     IF p_ies_emite_dupl_nat = "S" AND
        p_par_vdp.par_vdp_txt[39,39] = "S"
     THEN CALL vdp583_verifica_analise_rentab(p_cod_empresa,
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
                                              p_pedido_dig_mest.dat_prazo_entrega)
                                             RETURNING p_pre_unit_ped, p_valor_item_ipi,
                                                       p_valor_item_icm, p_valor_item_pis,p_valor_item_comis
         
         SELECT preco_minimo.*
           INTO p_preco_minimo.*
           FROM preco_minimo
          WHERE preco_minimo.cod_empresa = p_cod_empresa
            AND preco_minimo.cod_item    = t_pedido_dig_item[pa_curr].cod_item
         IF sqlca.sqlcode = 0
         THEN
         ELSE LET p_erro = TRUE                                
         END IF
         SELECT val_cotacao
           INTO p_val_cotacao_min
           FROM cotacao
          WHERE cotacao.cod_moeda = p_preco_minimo.cod_moeda
            AND cotacao.dat_ref   = TODAY
         IF sqlca.sqlcode = 0
         THEN
         ELSE LET p_erro = TRUE                                    
         END IF
         LET p_pre_unit_min = p_preco_minimo.pre_unit_min * p_val_cotacao_min
         LET p_pct_dif = 100 - ((p_pre_unit_min * 100) / p_pre_unit_ped)
         IF p_pre_unit_ped < p_pre_unit_min AND
            p_pct_dif < 0
         THEN LET p_erro = TRUE                                    
         END IF
     END IF 

################### PREVISAO - PRODUCAO - INICIO  ###################
    IF p_par_vdp.par_vdp_txt[14,14] = "S" THEN
       IF pol0185_verifica_prevprod()= FALSE
          THEN NEXT FIELD qtd_pecas_solic
       END IF
    END IF
################### PREVISAO - PRODUCAO - FIM     ###################
 
  BEFORE FIELD prz_entrega
    IF p_funcao = "INCLUSAO" THEN
       LET pa_curr = arr_curr()
       LET t_pedido_dig_item[pa_curr].prz_entrega = p_pedido_dig_mest.dat_prazo_entrega
    END IF
    LET p_campo = TRUE 

  AFTER  FIELD prz_entrega
    LET pa_curr = arr_curr()
    IF t_pedido_dig_item[pa_curr].prz_entrega < TODAY
       THEN ERROR " DATA menor que a data corrente"
       NEXT FIELD prz_entrega
    END IF
################### PREVISAO - PRODUCAO - INICIO  ###################
    IF p_par_vdp.par_vdp_txt[14,14] = "S" THEN
       IF pol0185_verifica_prevprod()= FALSE
          THEN NEXT FIELD qtd_pecas_solic
       END IF
    END IF

    LET p_qtd_dias_entrega = t_pedido_dig_item[pa_curr].prz_entrega - p_pedido_dig_mest.dat_emis_repres 
    IF  p_qtd_dias_entrega < 3 THEN                         
        IF t_pedido_dig_item[pa_curr].qtd_pecas_solic > p_qtd_estoque THEN
           ERROR " ITEM sem ESTOQUE para entrega IMEDIATA "
           NEXT FIELD prz_entrega    
        END IF
    END IF


    BEFORE FIELD ies_incl_txt
           LET pa_curr = arr_curr()
           LET sc_curr = scr_line()
           LET t_pedido_dig_item[pa_curr].ies_incl_txt = "N" 
           DISPLAY t_pedido_dig_item[pa_curr].ies_incl_txt TO
                   s_pedido_dig_item[sc_curr].ies_incl_txt
    AFTER  FIELD ies_incl_txt
           LET pa_curr = arr_curr()
           LET sc_curr = scr_line()
           IF t_pedido_dig_item[pa_curr].ies_incl_txt IS NOT NULL THEN 
              IF t_pedido_dig_item[pa_curr].ies_incl_txt = "S" THEN 
                 IF vdp243_digita_texto(p_pedido_dig_item.num_pedido,
                    pa_curr) = FALSE 
                 THEN 
                    LET t_pedido_dig_item[pa_curr].ies_incl_txt = "N"
                    SLEEP 3
                 END IF
                 CALL log006_exibe_teclas("01 02 05 06 07", p_versao)
                 CURRENT WINDOW IS w_pol01852
              END IF
           END IF

    AFTER  FIELD ies_agrupa  
           LET pa_curr = arr_curr()
           LET sc_curr = scr_line()
           IF t_pedido_dig_item[pa_curr].ies_agrupa   IS  NULL THEN  
              ERROR "Agrupamento invalido"     
              NEXT FIELD ies_agrupa   
           END IF   
    
       ON KEY (control-w, f1)
              CALL pol0185_help_itens()
    
       ON KEY (control-z)
              CALL pol0185_popup(3)

 END INPUT 

  IF   int_flag = 0
  THEN LET p_status = 0
       LET p_count  = arr_count()
       IF   p_count > 0
       THEN LET p_tela = 4
            RETURN p_status
       ELSE LET p_tela = 3
            RETURN p_status
       END IF
  ELSE LET p_status = 1
       LET p_count  = arr_count()
       LET p_tela = 2
       LET int_flag = 0
       RETURN p_status
  END IF
END FUNCTION

#-------------------------------------------------------#
 FUNCTION pol0185_calcula_desc_geral()    
#-------------------------------------------------------#
       DEFINE p_desc_tot    DECIMAL(15,2)

         LET p_pct_desc_tot = p_desc_seq0 +                 
                              t_pedido_dig_item[pa_curr].pct_desc_adic + 
                              p_pedido_dig_mest.pct_desc_adic  
         LET p_desc_tot = p_pct_desc_tot

         LET p_desc_tot = 100 - 
                         (100 * p_desc_seq0 / 100 )
         LET p_desc_tot = p_desc_tot - 
                         (p_desc_tot * t_pedido_dig_item[pa_curr].pct_desc_adic / 100)
         LET p_desc_tot = p_desc_tot - 
                         (p_desc_tot * p_pedido_dig_mest.pct_desc_adic / 100 )
         LET p_desc_geral  = 100 - p_desc_tot

END FUNCTION
#-------------------------------------------------------#
 FUNCTION pol0185_calcula_pre_unit(p_pre_unit,p_pct_desc)
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
 FUNCTION pol0185_verifica_preco_minimo()
#---------------------------------------#
  DEFINE p_pct_desc_m             LIKE pedidos.pct_desc_adic,
         p_pct_desc_i             LIKE ped_itens.pct_desc_adic,
         p_valor_item_ipi         LIKE nf_mestre.val_tot_nff,
         p_valor_item_icm         LIKE nf_mestre.val_tot_nff,
         p_valor_item_pis         LIKE nf_mestre.val_tot_nff,
         p_valor_item_comis       LIKE nf_mestre.val_tot_nff 
  
  IF   p_ies_emite_dupl_nat               = "S"   AND
       p_par_vdp.par_vdp_txt[39,39]       = "S"   
  THEN CALL vdp784_busca_desc_adic_unico(p_cod_empresa,
                                         p_pedido_dig_mest.num_pedido,
                                         0,p_pedido_dig_mest.pct_desc_adic) 
            RETURNING p_pct_desc_m
       
       LET  p_pre_unit_liq      = t_pedido_dig_item[pa_curr].pre_unit -
                                 (p_pct_desc_m * 
                                  t_pedido_dig_item[pa_curr].pre_unit / 100)
       
       CALL vdp784_busca_desc_adic_unico(p_cod_empresa,
                                         p_pedido_dig_mest.num_pedido,
                                         pa_curr,
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
       
       SELECT preco_minimo.*
         INTO p_preco_minimo.*
         FROM preco_minimo
        WHERE preco_minimo.cod_empresa = p_cod_empresa
          AND preco_minimo.cod_item    = t_pedido_dig_item[pa_curr].cod_item
       
       IF   sqlca.sqlcode = 0
       THEN
       ELSE ERROR "Item nao cadastrado na tabela de PRECO MINIMO"
            RETURN FALSE
       END IF
       
       SELECT val_cotacao
         INTO p_val_cotacao_min
         FROM cotacao
        WHERE cotacao.cod_moeda = p_preco_minimo.cod_moeda
          AND cotacao.dat_ref   = TODAY
       
       IF   sqlca.sqlcode = 0
       THEN
       ELSE ERROR "Moeda do Preco Minimo sem cotacao para o dia "
            RETURN FALSE
       END IF
       
       LET  p_pre_unit_min = p_preco_minimo.pre_unit_min * p_val_cotacao_min
       LET  p_pct_dif      = 100 - ((p_pre_unit_min * 100) / p_pre_unit_ped)
       IF   p_pre_unit_ped < p_pre_unit_min   AND
            p_pct_dif      < 0
       THEN ERROR "Preco menor que o Minimo "
            RETURN FALSE
       END IF
  END IF
  return true
END FUNCTION

#-----------------------------------#
 FUNCTION pol0185_verifica_prevprod()
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
{
 FOR p_cont = 1 TO arr_count()
  IF t_pedido_dig_item[p_cont].cod_item = p_cod_item AND
     p_cont <> pa_curr THEN
   LET p_semana_aux = log027_numero_semana(p_pedido_dig_mest.dat_prazo_entrega)
   LET p_ano_aux = YEAR(p_pedido_dig_mest.dat_prazo_entrega)
   IF p_semana_aux = p_semana AND
      p_ano_aux    = p_ano    THEN
      LET p_qtd_saldo = p_qtd_saldo + t_pedido_dig_item[p_cont].qtd_pecas_solic
   END IF
  END IF
 END FOR
}
 SELECT * INTO p_prev_producao.* FROM previsao_producao
  WHERE previsao_producao.cod_empresa = p_cod_empresa
    AND previsao_producao.cod_item   = p_cod_item
    AND previsao_producao.num_semana = p_semana
    AND previsao_producao.ano        = p_ano

 IF sqlca.sqlcode = NOTFOUND
 THEN INITIALIZE p_audit_logix.texto TO NULL
      LET p_audit_logix.texto = "ITEM SEM PREVISAO DE VENDAS",
          "  PARA A SEMANA ", p_semana, "/", p_ano
      ERROR " ",p_cod_item, " ITEM SEM PREVISAO DE VENDAS"
              LET p_prev_producao.num_semana   = p_semana
              LET p_prev_producao.ano          = p_ano
              LET p_prev_producao.qtd_prevista = "0"
              LET p_prev_producao.qtd_pedido   = p_qtd_saldo
              CALL pol0185_insere_prevprod()
              LET p_audit_logix.cod_empresa = p_cod_empresa
              LET p_audit_logix.texto = "INSERCAO PREVISAO PRODUCAO DO ITEM ",
                                         p_prev_producao.cod_item CLIPPED,
                                        " SEMANA ",p_semana,
                                        " ANO ", p_ano,
                                        " QTD. ",p_prev_producao.qtd_pedido 
              LET p_audit_logix.num_programa = "VDP0070"
              LET p_audit_logix.data = TODAY
              LET p_audit_logix.hora = TIME
              LET p_audit_logix.usuario = p_user
              INSERT INTO audit_logix VALUES(p_audit_logix.*)
              RETURN TRUE
 ELSE IF (p_prev_producao.qtd_pedido + p_qtd_saldo) >
          p_prev_producao.qtd_prevista
      THEN INITIALIZE p_audit_logix.texto TO NULL
           LET p_qtd_saldo_aux = p_prev_producao.qtd_prevista - 
                                 p_prev_producao.qtd_pedido
           LET p_audit_logix.texto = "SALDO DA PREVISAO DE PRODUCAO = ", p_qtd_saldo_aux,
               "  PARA A SEMANA ", p_semana, "/", p_ano
           ERROR "SALDO DA PREVISAO DE PRODUCAO = ", p_qtd_saldo_aux,
                 "  PARA A SEMANA ", p_semana, "/", p_ano
           IF log004_confirm(10,10)= FALSE
              THEN RETURN FALSE
           END IF
      END IF
      LET p_prev_producao.qtd_pedido = p_prev_producao.qtd_pedido +
                                       p_qtd_saldo
      CALL pol0185_atualiza_prevprod()
      LET p_audit_logix.cod_empresa = p_cod_empresa
      LET p_audit_logix.texto = "ATUALIZACAO PREVISAO PRODUCAO DO ITEM ",
                                p_prev_producao.cod_item CLIPPED,
                                " SEMANA ",p_semana,
                                " ANO ", p_ano,
                                " QTD. ",p_prev_producao.qtd_pedido 
      LET p_audit_logix.num_programa = "VDP0070"
      LET p_audit_logix.data = TODAY
      LET p_audit_logix.hora = TIME
      LET p_audit_logix.usuario = p_user
      INSERT INTO audit_logix VALUES(p_audit_logix.*)
      RETURN TRUE
 END IF
 END FUNCTION

#--------------------------------#
 FUNCTION pol0185_busca_repres()
#--------------------------------#
 INITIALIZE p_cli_canal_venda.* TO NULL 

 SELECT *
   INTO p_cli_canal_venda.*           
   FROM cli_canal_venda
  WHERE cod_cliente      = p_pedido_dig_mest.cod_cliente
    AND cod_tip_carteira = p_pedido_dig_mest.cod_tip_carteira

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


#-----------------------------------------------#
 FUNCTION pol0185_verifica_repres(p_cod_repres)
#-----------------------------------------------#
 DEFINE p_cod_repres    LIKE pedido_dig_mest.cod_repres
 
 IF p_cod_repres IS NULL THEN 
    RETURN TRUE
 END IF
 
 SELECT * 
   FROM representante
  WHERE cod_repres = p_cod_repres
 IF sqlca.sqlcode = 0 THEN  
    RETURN TRUE
 ELSE 
    RETURN FALSE
 END IF
 END FUNCTION 


#--------------------------------------#
FUNCTION pol0185_verifica_repres_canal()
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

   PREPARE var_query FROM sql_stmt
   DECLARE cq_canal_venda CURSOR FOR var_query
   OPEN cq_canal_venda
   FETCH cq_canal_venda
   IF sqlca.sqlcode = 100 THEN
      RETURN FALSE
   END IF
   RETURN TRUE
END FUNCTION


#----------------------------------#
 FUNCTION pol0185_atualiza_prevprod()
#----------------------------------#
  WHENEVER ERROR CONTINUE
  UPDATE previsao_producao SET qtd_pedido = p_prev_producao.qtd_pedido
   WHERE previsao_producao.cod_empresa = p_cod_empresa
     AND previsao_producao.cod_item    = p_prev_producao.cod_item
     AND previsao_producao.num_semana  = p_prev_producao.num_semana
     AND previsao_producao.ano         = p_prev_producao.ano       
  WHENEVER ERROR STOP
 END FUNCTION

#----------------------------------#
 FUNCTION pol0185_insere_prevprod()
#----------------------------------#
  WHENEVER ERROR CONTINUE
    INSERT INTO previsao_producao VALUES(p_prev_producao.*)
  WHENEVER ERROR STOP
 END FUNCTION
################### PREVISAO - PRODUCAO - FIM    ###################

#---------------------#
 FUNCTION pol0185_help() 
#---------------------#
  CASE
    WHEN infield(num_pedido)         CALL showhelp(0001)
    WHEN infield(cod_nat_oper)       CALL showhelp(0002)
    WHEN infield(dat_emis_repres)    CALL showhelp(0003)
    WHEN infield(cod_cliente)        CALL showhelp(0004)
    WHEN infield(cod_repres)         CALL showhelp(0005)
    WHEN infield(ies_finalidade)     CALL showhelp(0006)
    WHEN infield(ies_preco)          CALL showhelp(0007)
    WHEN infield(num_list_preco)     CALL showhelp(0008)
    WHEN infield(cod_cnd_pgto)       CALL showhelp(0009)
    WHEN infield(pct_desc_financ)    CALL showhelp(0010)
    WHEN infield(pct_desc_adic)      CALL showhelp(0011)
    WHEN infield(num_pedido_cli)     CALL showhelp(0012)
    WHEN infield(num_pedido_repres)  CALL showhelp(3015)
    WHEN infield(ies_frete)          CALL showhelp(0020)
    WHEN infield(cod_repres_adic)    CALL showhelp(0013)
    WHEN infield(cod_transpor)       CALL showhelp(0015)
    WHEN infield(ies_tip_entrega)    CALL showhelp(0016)
    WHEN infield(dat_prazo_entrega)  CALL showhelp(0017)
    WHEN infield(ies_sit_pedido)     CALL showhelp(0018)
    WHEN infield(cod_tip_venda)      CALL showhelp(0019)
    WHEN infield(ies_incl_txt)       CALL showhelp(0021)
    WHEN infield(num_sequencia)      CALL showhelp(0022)
    WHEN infield(end_entrega)        CALL showhelp(0023)
    WHEN infield(den_bairro)         CALL showhelp(0024)
    WHEN infield(cod_cidade)         CALL showhelp(0025)
    WHEN infield(cod_cep)            CALL showhelp(0026)
    WHEN infield(num_cgc)            CALL showhelp(0027)
    WHEN infield(ins_estadual)       CALL showhelp(0028)
    WHEN infield(tex_observ_1)       CALL showhelp(0029)
    WHEN infield(tex_observ_2)       CALL showhelp(0029)
    WHEN infield(quantidade)         CALL showhelp(0030)
    WHEN infield(preco)              CALL showhelp(0031)
    WHEN infield(desc_adic)          CALL showhelp(0032)
  END CASE
END FUNCTION
#---------------------------#
 FUNCTION pol0185_help_itens() 
#---------------------------#
  CASE
    WHEN infield(cod_item)           CALL showhelp(0038)
    WHEN infield(qtd_pecas_solic)    CALL showhelp(0039)
    WHEN infield(pre_unit)           CALL showhelp(0040)
    WHEN infield(pct_desc_adic)      CALL showhelp(0041)
    WHEN infield(prz_entrega)        CALL showhelp(0044)
#   WHEN infield(qtd_item_bonif)     CALL showhelp(0033)
    WHEN infield(ies_incl_txt)       CALL showhelp(0045)
  END CASE
END FUNCTION

#----------------------------------#
 FUNCTION pol0185_busca_num_pedido()
#----------------------------------#
 DEFINE p_num_pedido   LIKE pedido_dig_mest.num_pedido
 LET p_num_pedido = NULL
 WHENEVER ERROR CONTINUE
 SET LOCK MODE TO WAIT
 DECLARE cm_par_vdp CURSOR WITH HOLD FOR
  SELECT num_prx_pedido 
    FROM par_vdp
   WHERE par_vdp.cod_empresa = p_cod_empresa
 FOR UPDATE
 OPEN cm_par_vdp
 FETCH cm_par_vdp INTO p_num_pedido
 IF   sqlca.sqlcode = 0
 THEN UPDATE par_vdp 
         SET num_prx_pedido = p_num_pedido + 1
       WHERE CURRENT OF cm_par_vdp
      IF   sqlca.sqlcode <> 0
      THEN LET p_houve_erro = TRUE
           CALL log003_err_sql("ALTERACAO_1","PAR_VDP")     
      ELSE 
           CALL log085_transacao("COMMIT")
      #    COMMIT WORK
           IF   sqlca.sqlcode <> 0
           THEN LET p_houve_erro = TRUE
                CALL log003_err_sql("ALTERACAO_2","PAR_VDP")     
           ELSE 
                CALL log085_transacao("BEGIN")
           #    BEGIN WORK
           END IF
      END IF
 END IF
 CLOSE cm_par_vdp
 WHENEVER ERROR STOP
 RETURN p_num_pedido
 END FUNCTION

#-----------------------------------#
 FUNCTION pol0185_verifica_pedido()
#-----------------------------------#
 SELECT * FROM pedidos
        WHERE num_pedido  = p_pedido_dig_mest.num_pedido 
          AND cod_empresa = p_pedido_dig_mest.cod_empresa
 IF   sqlca.sqlcode = NOTFOUND
 THEN 
 ELSE RETURN TRUE 
 END IF

 SELECT *  FROM pedidos_hist
        WHERE num_pedido  = p_pedido_dig_mest.num_pedido 
          AND cod_empresa = p_pedido_dig_mest.cod_empresa
 IF   sqlca.sqlcode = NOTFOUND
 THEN 
 ELSE RETURN TRUE
 END IF

 SELECT * FROM pedido_dig_mest
        WHERE num_pedido  = p_pedido_dig_mest.num_pedido 
          AND cod_empresa = p_pedido_dig_mest.cod_empresa
 IF   sqlca.sqlcode = NOTFOUND
 THEN 
 ELSE RETURN TRUE
 END IF

 RETURN FALSE  
END FUNCTION

#-------------------------------------------#
 FUNCTION pol0185_verifica_natureza_operacao()
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
 FUNCTION pol0185_verifica_cliente()
#------------------------------------#
 DEFINE p_ies_situacao    LIKE clientes.ies_situacao,
      	 p_tipo_cliente    RECORD LIKE tipo_cliente.*,
        p_cgc_cpf         CHAR(11),
        p_end_cliente     LIKE clientes.end_cliente,
        p_cod_cep         LIKE clientes.cod_cep,
        p_den_cidade      LIKE cidades.den_cidade
 

 WHENEVER ERROR CONTINUE
 LET p_ies_cli_prefer = NULL
 LET p_cgc_cpf        = NULL
  
 SELECT clientes.nom_cliente,  clientes.end_cliente,
        clientes.cod_cep,      cidades.den_cidade,
        cidades.cod_uni_feder, ies_situacao,
        num_cgc_cpf, ins_estadual
        INTO p_nom_cliente,   p_end_cliente,
             p_cod_cep,       p_den_cidade,
             p_cod_uni_feder, p_ies_situacao,
             p_num_cgc_cpf, p_ins_estadual
        FROM clientes, OUTER cidades
        WHERE clientes.cod_cliente = p_pedido_dig_mest.cod_cliente
          AND cidades.cod_cidade   = clientes.cod_cidade
 IF   sqlca.sqlcode = NOTFOUND
 THEN ERROR " Cliente nao cadastrado. "
      RETURN FALSE
 END IF
 DISPLAY p_nom_cliente   TO nom_cliente
 DISPLAY p_end_cliente   TO end_cliente
 DISPLAY p_den_cidade    TO den_cidade
 DISPLAY p_cod_uni_feder TO cod_uni_feder
 DISPLAY p_cod_cep       TO cod_cep
 DISPLAY p_num_cgc_cpf   TO num_cgc_cpf
 DISPLAY p_ins_estadual  TO ins_estadual

 IF   p_ies_situacao = "A"
 THEN RETURN TRUE
 ELSE ERROR "Cliente cancelado ou suspenso"
      RETURN FALSE
 END IF
END FUNCTION

#-------------------------------------#
 FUNCTION pol0185_verifica_fiscal_par()
#-------------------------------------#
 WHENEVER ERROR CONTINUE
 SELECT pct_icm_contrib, pct_icm_ncontrib, pct_icm_consumo, ies_incid_ipi
        INTO p_pct_icm_contrib, p_pct_icm_ncontrib, p_pct_icm_consumo,
             p_ies_incid_ipi
        FROM fiscal_par
        WHERE fiscal_par.cod_empresa   = p_cod_empresa
          AND fiscal_par.cod_nat_oper  = p_pedido_dig_mest.cod_nat_oper
          AND fiscal_par.cod_uni_feder = p_cod_uni_feder    
 IF   sqlca.sqlcode <> 0
 THEN SELECT pct_icm_contrib, pct_icm_ncontrib, pct_icm_consumo,
             ies_incid_ipi
             INTO p_pct_icm_contrib, p_pct_icm_ncontrib,
                  p_pct_icm_consumo, p_ies_incid_ipi
             FROM fiscal_par
             WHERE fiscal_par.cod_empresa    = p_cod_empresa
               AND fiscal_par.cod_nat_oper   = p_pedido_dig_mest.cod_nat_oper
               AND fiscal_par.cod_uni_feder IS NULL   
      IF   sqlca.sqlcode <> 0
      THEN ERROR "Parametros Fiscais nao cadastrada para o Estado do cliente"
           RETURN FALSE
      END IF
 END IF
 IF   p_pedido_dig_mest.ies_finalidade = 1
 THEN LET p_pct_icm = p_pct_icm_contrib
 ELSE IF p_pedido_dig_mest.ies_finalidade = 2
      THEN LET p_pct_icm = p_pct_icm_ncontrib
      ELSE LET p_pct_icm = p_pct_icm_consumo
      END IF
 END IF
 RETURN TRUE

 END FUNCTION

#-------------------------------------#
 FUNCTION pol0185_consiste_nat_oper()
#-------------------------------------#
    CASE
        WHEN  p_cod_cidade = "AM000"
              IF p_pedido_dig_mest.cod_nat_oper = 12 OR 
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE 
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 12"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "AM071"
              IF p_pedido_dig_mest.cod_nat_oper = 12 OR  
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE 
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 12"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "AM069"
              IF p_pedido_dig_mest.cod_nat_oper = 12 OR  
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE 
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 12"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "AP011"
              IF p_pedido_dig_mest.cod_nat_oper = 14 OR   
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 14"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "AP016"
              IF p_pedido_dig_mest.cod_nat_oper = 14 OR   
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 14"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "RR009"
              IF p_pedido_dig_mest.cod_nat_oper = 14 OR  
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 14"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "RO012"
              IF p_pedido_dig_mest.cod_nat_oper = 14 OR  
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 14"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "AM080"
              IF p_pedido_dig_mest.cod_nat_oper = 14 OR  
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 14"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "RR003"
              IF p_pedido_dig_mest.cod_nat_oper = 14 OR  
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 14"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "AC002" 
              IF p_pedido_dig_mest.cod_nat_oper = 16 OR  
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 16"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "AC005" 
              IF p_pedido_dig_mest.cod_nat_oper = 16 OR  
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 16"
                 RETURN FALSE
              END IF
        WHEN  p_cod_cidade = "AC020" 
              IF p_pedido_dig_mest.cod_nat_oper = 16 OR  
                 p_pedido_dig_mest.cod_nat_oper = 32 THEN
                 RETURN TRUE
              ELSE
                 ERROR "Codigo da Natur. de Operacao deve ser igual a 16"
                 RETURN FALSE
              END IF
        OTHERWISE
              IF p_cod_cidade[1,2] = "AC" OR
                 p_cod_cidade[1,2] = "AM" OR
                 p_cod_cidade[1,2] = "RR" OR
                 p_cod_cidade[1,2] = "RO" THEN
                 IF p_pedido_dig_mest.cod_nat_oper = 18 OR     
                    p_pedido_dig_mest.cod_nat_oper = 32 THEN
                    RETURN TRUE
                 ELSE
                    ERROR "Codigo da Natur. de Operacao deve ser igual a 18"
                    RETURN FALSE
                 END IF   
              ELSE RETURN TRUE
              END IF
    END CASE
END FUNCTION

#------------------------------------------#
 FUNCTION pol0185_verifica_cnd_pagamento()
#------------------------------------------#
 DEFINE p_den_cnd_pgto    LIKE cond_pgto.den_cnd_pgto
 WHENEVER ERROR CONTINUE
 SELECT den_cnd_pgto, 
        ies_emite_dupl,
        pct_desp_finan
   INTO p_den_cnd_pgto, 
        p_ies_emite_dupl_cnd, 
        p_pct_desp_finan
   FROM cond_pgto
  WHERE cond_pgto.cod_cnd_pgto = p_pedido_dig_mest.cod_cnd_pgto
 IF sqlca.sqlcode = 0 THEN

      {  CALL vdp1981_calcula_media(p_pedido_dig_mest.cod_cnd_pgto)
         RETURNING p_qtd_dias_media   }

 ELSE ERROR " Condicao de pagamento nao cadastrado. "
      RETURN TRUE
 END IF
 DISPLAY p_den_cnd_pgto TO den_cnd_pgto
 IF   p_ies_emite_dupl_cnd = p_ies_emite_dupl_nat     
 THEN RETURN  FALSE
 ELSE ERROR "Cond. de pgto incompativel com a natureza da operacao"
      RETURN TRUE 
 END IF
 WHENEVER ERROR STOP
 END FUNCTION

#---------------------------------------#
 FUNCTION pol0185_verifica_pedido_repres()
#---------------------------------------#
  WHENEVER ERROR CONTINUE
   SELECT pedidos.num_pedido 
     FROM pedidos
    WHERE pedidos.num_pedido_repres = p_pedido_dig_mest.num_pedido_repres
      AND pedidos.cod_repres        = p_pedido_dig_mest.cod_repres
      AND pedidos.cod_empresa       = p_cod_empresa
      AND pedidos.ies_sit_pedido   <> "9"
  IF   sqlca.sqlcode = NOTFOUND
  THEN
  ELSE RETURN TRUE
  END IF
   SELECT pedido_dig_mest.num_pedido
     FROM pedido_dig_mest 
    WHERE num_pedido_repres = p_pedido_dig_mest.num_pedido_repres
      AND cod_repres        = p_pedido_dig_mest.cod_repres
      AND cod_empresa       = p_cod_empresa
  IF   sqlca.sqlcode = NOTFOUND
  THEN
  ELSE RETURN TRUE
  END IF
  SELECT pedidos_hist.num_pedido 
    FROM pedidos_hist
   WHERE pedidos_hist.num_pedido_repres = p_pedido_dig_mest.num_pedido_repres
     AND pedidos_hist.cod_repres        = p_pedido_dig_mest.cod_repres
     AND pedidos_hist.cod_empresa       = p_cod_empresa
     AND pedidos_hist.ies_sit_pedido   <> "9"
  IF   sqlca.sqlcode = NOTFOUND
  THEN RETURN FALSE
  ELSE RETURN TRUE
  END IF
  WHENEVER ERROR STOP
END FUNCTION

#------------------------------------#
 FUNCTION pol0185_verifica_tipo_venda()
#------------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT cod_tip_venda FROM tipo_venda
    WHERE tipo_venda.cod_tip_venda = p_pedido_dig_mest.cod_tip_venda
  IF sqlca.sqlcode = NOTFOUND
     THEN RETURN true
     ELSE RETURN false
  END IF
  WHENEVER ERROR STOP
END FUNCTION

#----------------------------------#
 FUNCTION pol0185_verifica_moeda()
#----------------------------------#
 DEFINE p_den_moeda    LIKE moeda.den_moeda

 SELECT den_moeda  INTO p_den_moeda
        FROM moeda 
        WHERE cod_moeda = p_pedido_dig_mest.cod_moeda
 IF   sqlca.sqlcode = NOTFOUND
 THEN RETURN FALSE 
 ELSE DISPLAY p_den_moeda TO den_moeda
      RETURN TRUE 
 END IF
 END FUNCTION

#--------------------------------#
 FUNCTION pol0185_verifica_cidade()
#--------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT cod_cidade FROM cidades
    WHERE cidades.cod_cidade = p_pedido_dig_ent.cod_cidade
  IF sqlca.sqlcode = NOTFOUND
     THEN RETURN true
     ELSE RETURN false
  END IF
  WHENEVER ERROR STOP
END FUNCTION

#---------------------------------#
 FUNCTION vdp808_verifica_item_repres()
#---------------------------------#
 DEFINE      p_cod_item        LIKE item_vdp.cod_item
  
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
      AND (item_embalagem.ies_tip_embal = "N" OR
	   item_embalagem.ies_tip_embal = "I")
  IF sqlca.sqlcode <> 0
  THEN SELECT item_repres.cod_item
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
           IF sqlca.sqlcode <> 0 THEN
           ELSE
             LET t_pedido_dig_item[pa_curr].cod_item = p_cod_item 
           END IF
     ELSE
       LET t_pedido_dig_item[pa_curr].cod_item = p_cod_item 
     END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0185_verifica_item()
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
  WHENEVER ERROR CONTINUE
  SELECT item.cod_item,
         item.ies_situacao,
         item_vdp.pre_unit_brut,
         item.pct_ipi,
         item.cod_lin_prod,
         item.cod_lin_recei,
         item.cod_seg_merc,
         item.cod_cla_uso,
         item.den_item        
    INTO p_cod_item,
         p_ies_situacao,
         p_pre_unit_bruto,
         p_pct_ipi,
         p_cod_lin_prod,
         p_cod_lin_recei,
         p_cod_seg_merc,
         p_cod_cla_uso,
         p_den_item        
    FROM item, item_vdp
    WHERE item.cod_item        = t_pedido_dig_item[pa_curr].cod_item
      AND item.cod_item        = item_vdp.cod_item
      AND item.cod_empresa     = p_cod_empresa
      AND item_vdp.cod_empresa = p_cod_empresa
  IF   sqlca.sqlcode = NOTFOUND
  THEN ERROR " Produto nao cadastrado "
       LET p_status = 0
       RETURN  p_status, p_qtd_padr_embal
  END IF
  LET t_pedido_dig_item[pa_curr].den_item = p_den_item
  DISPLAY t_pedido_dig_item[pa_curr].den_item TO s_pedido_dig_item[sc_curr].den_item          
  IF p_ies_incid_ipi <> 1
  THEN LET p_pct_ipi = 0
  END IF
  IF   p_ies_situacao = "A"
  THEN
  ELSE ERROR "Produto cancelado"
       LET p_status = 0
       RETURN  p_status, p_qtd_padr_embal
  END IF
  IF pol0185_existe_nat_oper_refer() THEN
     IF NOT pol0185_existe_fiscal_par() THEN
        ERROR " Nao ha parametros fiscais cadastrados para a Operacao ",
              m_cod_nat_oper_ref, " do item "
        LET p_status = 0
        RETURN p_status, p_qtd_padr_embal
     END IF
  END IF
  CALL pol0185_mostra_estoque(t_pedido_dig_item[pa_curr].cod_item)
  IF   p_pedido_dig_mest.ies_embal_padrao = "1"
  THEN SELECT qtd_padr_embal
         INTO p_qtd_padr_embal
         FROM item_embalagem
        WHERE item_embalagem.cod_empresa = p_cod_empresa
          AND item_embalagem.cod_item    = t_pedido_dig_item[pa_curr].cod_item
          AND item_embalagem.ies_tip_embal IN ("N","I") 
         IF   sqlca.sqlcode = NOTFOUND
         THEN ERROR "Item nao cadastrado na tabela item_embalagem"
              LET p_status = 0
              RETURN p_status, p_qtd_padr_embal
         END IF
  ELSE IF   p_pedido_dig_mest.ies_embal_padrao = "2"
       THEN SELECT qtd_padr_embal
              INTO p_qtd_padr_embal
              FROM item_embalagem
             WHERE item_embalagem.cod_empresa = p_cod_empresa
               AND item_embalagem.cod_item    = t_pedido_dig_item[pa_curr].cod_item
               AND item_embalagem.ies_tip_embal IN ("E","C") 
               IF   sqlca.sqlcode = NOTFOUND
               THEN ERROR "Item nao cadastrado na tabela item_embalagem"
                    LET p_status = 0
                    RETURN p_status, p_qtd_padr_embal
               END IF
        END IF
  END IF
  IF   p_pedido_dig_mest.num_list_preco = 0 OR
       p_pedido_dig_mest.num_list_preco IS NULL OR
       p_pedido_dig_mest.num_list_preco = "    "
  THEN
  ELSE CALL pol0185_busca_preco_lista(p_cod_item, p_cod_lin_prod,
                                  p_cod_lin_recei, p_cod_seg_merc,
                                  p_cod_cla_uso) RETURNING p_status,
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
            ELSE CALL pol0185_calcula_pre_unit(p_pre_unit_bruto,
                                              p_desc_bruto_tab)
                      RETURNING t_pedido_dig_item[pa_curr].pre_unit
                 IF t_pedido_dig_item[pa_curr].pct_desc_adic  = 0 OR
                    t_pedido_dig_item[pa_curr].pct_desc_adic  IS NULL
                 THEN LET t_pedido_dig_item[pa_curr].pct_desc_adic  = p_desc_adic_tab
                 END IF
                 DISPLAY t_pedido_dig_item[pa_curr].pre_unit TO s_pedido_dig_item[sc_curr].pre_unit
                 DISPLAY t_pedido_dig_item[pa_curr].pct_desc_adic  TO s_pedido_dig_item[sc_curr].pct_desc_adic 
            END IF
       ELSE ERROR "Produto nao cadastrado na lista de preco"
            LET p_status = 0
            RETURN  p_status, p_qtd_padr_embal
       END  IF
  END  IF
  IF   t_pedido_dig_item[pa_curr].pre_unit = 0 
  THEN IF   p_pedido_dig_mest.num_list_preco = 0 OR
            p_pedido_dig_mest.num_list_preco IS NULL OR
            p_pedido_dig_mest.num_list_preco = "    "
       THEN LET p_status = 1
       ELSE ERROR "Produto nao cadastrado na lista de preco"
            LET p_status = 0
       END IF
  ELSE LET p_status = 1
  END IF
 RETURN p_status, p_qtd_padr_embal
 WHENEVER ERROR STOP
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0185_verifica_valor_pedido()
#-----------------------------------------#
  DEFINE  p_pre_unit_liq    LIKE item_vdp.pre_unit_brut,
          p_val_cotacao     LIKE cotacao_mes.val_cotacao,
          p_pct_desc_m      LIKE pedidos.pct_desc_adic,
          p_pct_desc_i      LIKE ped_itens.pct_desc_adic,
          p_dep             SMALLINT

  IF p_pedido_dig_mest.cod_moeda > 0 THEN 
     SELECT val_cotacao
       INTO p_val_cotacao
       FROM cotacao
      WHERE cotacao.cod_moeda = p_pedido_dig_mest.cod_moeda
       AND cotacao.dat_ref   = TODAY
     IF sqlca.sqlcode = 0 THEN
     ELSE 
        OPEN WINDOW w_pol01857 AT 10,10 WITH 5 ROWS, 30 COLUMNS
             ATTRIBUTE(BORDER, PROMPT LINE LAST)
        DISPLAY "Cotacao da moeda ", p_pedido_dig_mest.cod_moeda  AT 1,1
        DISPLAY " para a data corrente nao ca-" AT 2,1
        DISPLAY "dastrada na tabela cotacao" AT  3,1
        ERROR " "
        PROMPT "Tecle ENTER para continuar" FOR p_comando
        CLOSE WINDOW w_pol01857 
        LET p_status = 1
        RETURN  p_status
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
         CALL vdp784_busca_desc_adic_unico(p_cod_empresa,
                                           p_pedido_dig_mest.num_pedido,
                                           0,
                                           p_pedido_dig_mest.pct_desc_adic) 
         RETURNING p_pct_desc_m
         CALL pol0185_calcula_pre_unit(p_pre_unit_liq,
                                      p_pct_desc_m)
         RETURNING p_pre_unit_liq
         CALL vdp784_busca_desc_adic_unico(p_cod_empresa,
                                           p_pedido_dig_mest.num_pedido,
                                           0,
                                           t_pedido_dig_item[p_dep].pct_desc_adic) 
         RETURNING p_pct_desc_i
         CALL pol0185_calcula_pre_unit(p_pre_unit_liq,
                                      p_pct_desc_i)
         RETURNING p_pre_unit_liq
             
         LET p_valor_pedido = p_valor_pedido + (t_pedido_dig_item[p_dep].qtd_pecas_solic *
                                                p_pre_unit_liq)
         IF (p_valor_pedido + p_val_dup_aberto + p_val_ped_carteira) > 
             p_val_limite_cred_cruz THEN 
             OPEN WINDOW w_pol01858 AT 10,30 WITH 6 ROWS, 40 COLUMNS
                  ATTRIBUTE(BORDER, PROMPT LINE LAST)
             DISPLAY "Item excede ao limite de credito  "          AT 1,1
             DISPLAY "do  cliente.                  "              AT 2,1
             DISPLAY "Limite de credito ", p_val_limite_cred_cruz  AT 3,1
             DISPLAY "Duplicatas abertas ", p_val_dup_aberto       AT 4,1
             DISPLAY "Valor do pedido ate o item ", p_valor_pedido AT 5,1
             ERROR " "
             PROMPT "Tecle ENTER para continuar" FOR p_comando
             CLOSE WINDOW w_pol01858 
             LET p_status = 1
             LET p_erro = TRUE
             EXIT FOR
          END IF
       END FOR
   END IF
#   RETURN  p_status
END FUNCTION


#---------------------------------#
 FUNCTION pol0185_efetiva_inclusao()
#---------------------------------#
 CALL pol0185_inclui_mestre()
 CALL pol0185_insert_ped_list()
 IF   p_pedido_dig_ent.end_entrega IS NOT NULL
 THEN CALL pol0185_inclui_end_entr()
 END IF
 IF   p_pedido_dig_obs.tex_observ_1 IS NOT NULL
 THEN CALL pol0185_inclui_observ()
 END IF
 CALL pol0185_inclui_itens()
 CALL vdp106_inclui_texto()  
#CALL pol0185_inclui_itens_bnf()
 CALL pol0185_inclui_ped_itens_desc()
 END FUNCTION

#--------------------------------#
 FUNCTION pol0185_popup(p_status)
#--------------------------------#
DEFINE  p_cod_transpor    LIKE transport.cod_transpor,
        p_cod_repres      LIKE representante.cod_repres,
        p_cod_consig      LIKE transport.cod_transpor,
        p_cod_repres_adic LIKE representante.cod_repres,
        p_lista_preco     LIKE desc_preco_mest.num_list_preco,
        p_cod_cliente     LIKE clientes.cod_cliente,
        p_cod_item_pe     LIKE item.cod_item ,
        p_filtro          CHAR(100),
        p_status          SMALLINT 
 CASE
    WHEN infield(cod_tip_carteira)
         CALL log009_popup(6,25,"TIPO CARTEIRA","tipo_carteira",
                          "cod_tip_carteira","den_tip_carteira",
                          "","N","") RETURNING p_pedido_dig_mest.cod_tip_carteira
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY BY NAME p_pedido_dig_mest.cod_tip_carteira
    WHEN infield(cod_nat_oper)
         CALL log009_popup(6,25,"NAT. OPERACAO","nat_operacao",
                          "cod_nat_oper","tex_observacao",
                          "vdp0050","N","") RETURNING p_pedido_dig_mest.cod_nat_oper
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY p_pedido_dig_mest.cod_nat_oper TO cod_nat_oper
    WHEN infield(cod_cliente)   
         LET p_cod_cliente = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         IF p_cod_cliente IS NOT NULL
         THEN  LET p_pedido_dig_mest.cod_cliente = p_cod_cliente
               DISPLAY p_pedido_dig_mest.cod_cliente TO cod_cliente
         END IF
    WHEN infield(cod_transpor)  
         LET  p_pedido_dig_mest.cod_transpor = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY BY NAME p_pedido_dig_mest.cod_transpor 
    WHEN infield(cod_cnd_pgto)
         CALL log009_popup(6,25,"COND. PAGAMENTO","cond_pgto",
                          "cod_cnd_pgto","den_cnd_pgto",
                          "vdp0140","N","") RETURNING p_pedido_dig_mest.cod_cnd_pgto
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY p_pedido_dig_mest.cod_cnd_pgto TO cod_cnd_pgto
    WHEN infield(num_list_preco)
         CALL log009_popup(6,25,"LISTA DE PRECO","desc_preco_mest",
                          "num_list_preco","den_list_preco",
                          "vdp0260","N","") RETURNING p_lista_preco
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         IF p_lista_preco IS NOT NULL
         THEN  LET p_pedido_dig_mest.num_list_preco = p_lista_preco
               DISPLAY p_pedido_dig_mest.num_list_preco TO num_list_preco
         END IF
    WHEN infield(cod_tip_venda)
         CALL log009_popup(6,25,"TIPO VENDA","tipo_venda",
                          "cod_tip_venda","den_tip_venda",
                          "vdp0120","N","") RETURNING p_pedido_dig_mest.cod_tip_venda
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY p_pedido_dig_mest.cod_tip_venda TO cod_tip_venda
    WHEN infield(cod_moeda)
         CALL log009_popup(6,25,"MOEDAS","moeda",
                          "cod_moeda","den_moeda",
                          "pat0140","N","") RETURNING p_pedido_dig_mest.cod_moeda
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY p_pedido_dig_mest.cod_moeda TO cod_moeda    
    WHEN infield(cod_cidade)
         CALL vdp309_popup_cidades()  RETURNING p_pedido_dig_ent.cod_cidade
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol01851
         DISPLAY p_pedido_dig_ent.cod_cidade TO cod_cidade
    WHEN infield(cod_cliente)   
         LET p_cod_cliente = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         IF p_cod_cliente IS NOT NULL
         THEN  LET p_pedido_dig_mest.cod_cliente = p_cod_cliente
               DISPLAY p_pedido_dig_mest.cod_cliente TO cod_cliente
         END IF
    WHEN infield(cod_consig)  
         LET  p_pedido_dig_mest.cod_consig = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY BY NAME p_pedido_dig_mest.cod_consig   
    WHEN infield(cod_repres)
         CALL log009_popup(6,25,"REPRESENTANTES","representante",
                          "cod_repres","nom_repres",
                          "","N","") RETURNING p_pedido_dig_mest.cod_repres
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY BY NAME p_pedido_dig_mest.cod_repres
    WHEN infield(cod_repres_adic)
         CALL log009_popup(6,25,"REPRESENTANTES","representante",
                          "cod_repres","nom_repres",
                          "","N","") RETURNING p_pedido_dig_mest.cod_repres_adic
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY BY NAME p_pedido_dig_mest.cod_repres_adic
    WHEN infield(cod_cnd_pgto)
         CALL log009_popup(6,25,"COND. PAGAMENTO","cond_pgto",
                          "cod_cnd_pgto","den_cnd_pgto",
                          "vdp0140","N","") RETURNING p_pedido_dig_mest.cod_cnd_pgto
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY p_pedido_dig_mest.cod_cnd_pgto TO cod_cnd_pgto
    WHEN infield(cod_tip_venda)
         CALL log009_popup(6,25,"TIPO VENDA","tipo_venda",
                          "cod_tip_venda","den_tip_venda",
                          "vdp0120","N","") RETURNING p_pedido_dig_mest.cod_tip_venda
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
         DISPLAY p_pedido_dig_mest.cod_tip_venda TO cod_tip_venda
    WHEN infield(cod_cidade)
         CALL vdp309_popup_cidades()  RETURNING p_pedido_dig_ent.cod_cidade
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol01851
         DISPLAY p_pedido_dig_ent.cod_cidade TO cod_cidade
    WHEN infield(cod_item)
         LET pa_curr = arr_curr() 
         LET sc_curr = scr_line()
         LET p_cod_item_pe = vdp373_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol01852
         IF p_cod_item_pe IS NOT NULL
         THEN  LET t_pedido_dig_item[pa_curr].cod_item = p_cod_item_pe
               DISPLAY t_pedido_dig_item[pa_curr].cod_item TO s_pedido_dig_item[sc_curr].cod_item
         END IF
    WHEN infield(pct_desc_adic) AND p_status = 1
         CALL pol0185_controle_peditdesc(p_cod_empresa,
                                         p_pedido_dig_mest.num_pedido,
                                         0 )
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0185
    WHEN infield(pct_desc_adic) AND p_status = 3 
         CALL pol0185_controle_peditdesc(p_cod_empresa,
                                         p_pedido_dig_mest.num_pedido,
                                         pa_curr) 
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol01852
    WHEN infield(num_sequencia)
	        LET p_filtro = "cli_end_ent.cod_cliente = '",p_pedido_dig_mest.cod_cliente,"'" 
	        CALL log009_popup(6,25,"CLIENTE END. ENTREGA","cli_end_ent",
			                        "num_sequencia","end_entrega",
			                        "vdp3640","N", p_filtro)  RETURNING p_num_sequencia
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol01851
         DISPLAY p_num_sequencia TO num_sequencia
 END CASE
 END FUNCTION

#----------------------------#
 FUNCTION pol0185_exibe_dados()
#----------------------------#
 DEFINE ies_incl_txt CHAR(001)
 LET ies_incl_txt = ies_incl_txt
 WHENEVER ERROR CONTINUE
 CALL log130_procura_caminho("pol0185") RETURNING p_nom_tela
 OPEN WINDOW w_pol0185 AT 2,02 WITH FORM p_nom_tela     
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 WHENEVER ERROR STOP  
 CURRENT WINDOW IS w_pol0185 
#DISPLAY FORM f_pol0185

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
                 p_pedido_dig_mest.ies_frete,         
                 p_pedido_dig_mest.ies_tip_entrega,   
                 p_pedido_dig_mest.cod_transpor,      
                 p_pedido_dig_mest.cod_consig,        
                 p_pedido_dig_mest.ies_finalidade,    
                 p_pedido_dig_mest.cod_moeda,         
                 p_pedido_dig_mest.ies_embal_padrao,  
                 p_pedido_dig_mest.cod_tip_carteira,  
                 ies_incl_txt                         
               
 END FUNCTION

#------------------------------#
 FUNCTION pol0185_inclui_mestre()
#------------------------------#
 DEFINE p_pedidos          RECORD LIKE pedidos.*,
        p_nat_operacao     RECORD LIKE nat_operacao.*
 DEFINE p_hora             DATETIME HOUR TO SECOND
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
 SELECT * INTO p_nat_operacao.*
        FROM nat_operacao
        WHERE cod_nat_oper = p_pedido_dig_mest.cod_nat_oper
 IF   p_nat_operacao.ies_tip_controle = "B"
 THEN LET p_erro = TRUE     ### bloqueia o pedido para liberacao comercial
      LET p_pedido_dig_mest.ies_aceite_comer = "N"
 END IF

 IF   p_erro = FALSE
 THEN IF   p_consist_cred = TRUE 
      THEN LET p_pedidos.ies_sit_pedido = "B"
      END IF 
      IF p_cod_moeda_cons > 0 THEN 
         LET p_pedidos.cod_moeda = p_cod_moeda_cons
      END IF
      INSERT INTO pedidos VALUES (p_pedidos.*)
      IF   sqlca.sqlcode = 0
      THEN IF   p_par_vdp.par_vdp_txt[22,22] = "S"
           THEN CALL pol0185_insert_t_mestre(p_pedidos.num_pedido,
                                            p_pedidos.cod_nat_oper,
                                            p_pedidos.cod_cnd_pgto,
                                            p_pedidos.pct_desc_adic,
                                            p_pedidos.pct_desc_financ,
                                            p_pedidos.cod_moeda)
           END IF
      ELSE LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO","PEDIDOS")
      END IF
 ELSE LET p_hora                                 = CURRENT
      LET p_pedido_dig_mest.hora_digitacao       = p_hora
      LET p_pedido_dig_mest.dat_liberacao_fin    = NULL 
      LET p_pedido_dig_mest.hora_liberacao_fin   = NULL 
      LET p_pedido_dig_mest.dat_liberacao_com    = NULL 
      LET p_pedido_dig_mest.hora_liberacao_com   = NULL 
      IF p_cod_moeda_cons > 0 THEN 
         LET p_pedido_dig_mest.cod_moeda = p_cod_moeda_cons
      END IF
      INSERT INTO pedido_dig_mest VALUES (p_pedido_dig_mest.*)
 END IF
 END FUNCTION

#--------------------------------#
 FUNCTION pol0185_insert_ped_list()
#--------------------------------#
 WHENEVER ERROR CONTINUE
 IF   p_erro = FALSE
 THEN INSERT INTO pedido_list VALUES (p_cod_empresa, p_pedido_dig_mest.num_pedido, p_user)
      IF sqlca.sqlcode = 0
      THEN
      ELSE LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO","PEDIDO_LIST")
      END IF
 END IF
 WHENEVER ERROR STOP
 END FUNCTION

#--------------------------------#
 FUNCTION pol0185_inclui_end_entr()
#---------------------------------#
 DEFINE p_ped_end_ent         RECORD LIKE ped_end_ent.*
 LET p_ped_end_ent.cod_empresa   = p_cod_empresa
 LET p_ped_end_ent.num_pedido    = p_pedido_dig_mest.num_pedido
 LET p_ped_end_ent.num_sequencia = p_num_sequencia
 LET p_ped_end_ent.end_entrega   = p_pedido_dig_ent.end_entrega
 LET p_ped_end_ent.den_bairro    = p_pedido_dig_ent.den_bairro
 LET p_ped_end_ent.cod_cidade    = p_pedido_dig_ent.cod_cidade
 LET p_ped_end_ent.cod_cep       = p_pedido_dig_ent.cod_cep
 LET p_ped_end_ent.num_cgc       = p_pedido_dig_ent.num_cgc
 LET p_ped_end_ent.ins_estadual  = p_pedido_dig_ent.ins_estadual
 LET p_pedido_dig_ent.cod_empresa = p_cod_empresa
 LET p_pedido_dig_ent.num_pedido  = p_pedido_dig_mest.num_pedido 

 IF   p_erro = FALSE
 THEN INSERT INTO ped_end_ent VALUES (p_ped_end_ent.*)

      IF sqlca.sqlcode = 0
      THEN
      ELSE LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO","PED_END_ENT")
      END IF
 ELSE INSERT INTO pedido_dig_ent VALUES (p_pedido_dig_ent.*)
 END IF
 END FUNCTION

#------------------------------#
 FUNCTION pol0185_inclui_observ()
#------------------------------#
 DEFINE p_ped_observacao     RECORD LIKE ped_observacao.*
 LET p_ped_observacao.cod_empresa   = p_cod_empresa
 LET p_ped_observacao.num_pedido    = p_pedido_dig_mest.num_pedido
 LET p_ped_observacao.tex_observ_1  = p_pedido_dig_obs.tex_observ_1
 LET p_ped_observacao.tex_observ_2  = p_pedido_dig_obs.tex_observ_2
 LET p_pedido_dig_obs.cod_empresa   = p_cod_empresa
 LET p_pedido_dig_obs.num_pedido    = p_pedido_dig_mest.num_pedido

 IF   p_erro = FALSE
 THEN INSERT INTO ped_observacao VALUES (p_ped_observacao.*)

      IF sqlca.sqlcode = 0
      THEN
      ELSE LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO","PED_OBSERVACAO")
      END IF
 ELSE INSERT INTO pedido_dig_obs VALUES (p_pedido_dig_obs.*)
 END IF
 END FUNCTION

#-----------------------------#
 FUNCTION pol0185_inclui_itens()
#-----------------------------#
 FOR pa_curr = 1 TO  500 
    IF   t_pedido_dig_item[pa_curr].cod_item IS NOT NULL OR
         t_pedido_dig_item[pa_curr].cod_item  != "               "
  THEN 
    IF p_houve_item_rep THEN
       CALL vdp808_verifica_item_repres() 
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
         LET p_ped_itens.val_frete_unit    = 0
         LET p_ped_itens.val_seguro_unit   = 0
         LET p_ped_itens.pct_desc_bruto    = 0

{        IF   p_par_vdp.par_vdp_txt[22,22] = "S"
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
                   ELSE IF   pol0185_verifica_meta_venda()
                        THEN 
                        END IF
                   END IF
              END IF
         END IF 
}
         IF   p_erro = FALSE
         THEN INSERT INTO ped_itens VALUES (p_ped_itens.*)
              IF   sqlca.sqlcode = 0
              THEN 
              ELSE LET p_houve_erro = TRUE
                   CALL log003_err_sql("INCLUSAO","PED_ITENS")
              END IF
              IF pol0185_existe_nat_oper_refer() THEN
                 INSERT INTO ped_item_nat VALUES
                    ( p_cod_empresa, p_pedido_dig_mest.num_pedido, pa_curr, "N", "N",
                      "", m_cod_nat_oper_ref, p_pedido_dig_mest.cod_cnd_pgto )
 
                 IF sqlca.sqlcode <> 0 THEN
                    LET p_houve_erro = TRUE
                    CALL log003_err_sql("INCLUSAO","PED_ITEM_NAT")
                 END IF
              END IF
              CALL pol0185_incl_ped_of_pcp()
#        ELSE LET p_valor1 = t_pedido_dig_item[pa_curr].qtd_pecas_solic + 
#                            t_pedido_dig_item[pa_curr].qtd_item_bonif 
#             LET p_valor2 = (t_pedido_dig_item[pa_curr].qtd_pecas_solic * 
#                             t_pedido_dig_item[pa_curr].pre_unit) / 
#                            (t_pedido_dig_item[pa_curr].qtd_pecas_solic + 
#                             t_pedido_dig_item[pa_curr].qtd_item_bonif)
#             INSERT INTO pedido_dig_item VALUES (p_cod_empresa,
#                                                 p_pedido_dig_mest.num_pedido,
#                                                 pa_curr,
#                                                 t_pedido_dig_item[pa_curr].cod_item,
#                                                 p_valor1, 
#                                                 p_valor2,
#					                                            t_pedido_dig_item[pa_curr].pct_desc_adic,
#                                                 0,
#                                                 t_pedido_dig_item[pa_curr].prz_entrega,
#                                                 0,0)
#             END IF
#        ELSE EXIT FOR
#        END IF
#END FOR
       ELSE INSERT INTO pedido_dig_item VALUES (p_cod_empresa,
                                                p_pedido_dig_mest.num_pedido,
                                                pa_curr,
                                                t_pedido_dig_item[pa_curr].cod_item,
                                                t_pedido_dig_item[pa_curr].qtd_pecas_solic,
	        	 		        t_pedido_dig_item[pa_curr].pre_unit,
 					        t_pedido_dig_item[pa_curr].pct_desc_adic,
                                                0,
                                                t_pedido_dig_item[pa_curr].prz_entrega,
                                                0,0)   
            IF pol0185_existe_nat_oper_refer() THEN
               INSERT INTO ped_dig_it_nat VALUES
                  (p_cod_empresa, p_pedido_dig_mest.num_pedido, pa_curr, "N", 
                   "N","",
                   m_cod_nat_oper_ref, p_pedido_dig_mest.cod_cnd_pgto)

               IF sqlca.sqlcode <> 0 THEN
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("INCLUSAO","PED_ITEM_NAT")
               END IF
            END IF
       END IF
       IF   p_ies_tip_controle = "2"
       THEN CALL pol0185_insert_ped_itens_rem()
       END IF 
   
       LET p_ped_agrupa.cod_empresa      = p_cod_empresa
       LET p_ped_agrupa.num_pedido       = p_pedido_dig_mest.num_pedido
       LET p_ped_agrupa.num_sequencia    = pa_curr 
       LET p_ant = pa_curr - 1 
       IF p_ant = 0 THEN  
          LET p_ped_agrupa.cod_item  = t_pedido_dig_item[pa_curr].cod_item
       ELSE 
          IF t_pedido_dig_item[pa_curr].ies_agrupa = t_pedido_dig_item[p_ant].ies_agrupa THEN
             LET p_ped_agrupa.cod_item  = t_pedido_dig_item[p_ant].cod_item
          ELSE 
             LET p_ped_agrupa.cod_item  = t_pedido_dig_item[pa_curr].cod_item
          END IF
       END IF
       LET p_ped_agrupa.pre_unit         = t_pedido_dig_item[pa_curr].pre_unit
       LET p_ped_agrupa.num_agrup        = t_pedido_dig_item[pa_curr].ies_agrupa
 
       INSERT INTO ped_agrupa_albras VALUES (p_ped_agrupa.*)

   ELSE EXIT FOR
   END IF
 END FOR

 END FUNCTION

#-----------------------------------#
#FUNCTION pol0185_inclui_itens_bnf()
#-----------------------------------#
#FOR pa_curr = 1 TO  99  
#  IF   t_pedido_dig_item[pa_curr].cod_item IS NOT NULL
#  THEN IF   t_pedido_dig_item[pa_curr].qtd_item_bonif <= 0
#       THEN CONTINUE FOR
#       END IF
#       LET p_ped_itens_bnf.cod_empresa        = p_cod_empresa
#       LET p_ped_itens_bnf.num_pedido         = p_pedido_dig_mest.num_pedido
#       LET p_ped_itens_bnf.num_sequencia      = pa_curr
#       LET p_ped_itens_bnf.cod_item           = t_pedido_dig_item[pa_curr].cod_item
#       LET p_ped_itens_bnf.pct_desc_adic      = t_pedido_dig_item[pa_curr].pct_desc_adic 
#       LET p_ped_itens_bnf.pre_unit           = t_pedido_dig_item[pa_curr].pre_unit
#       LET p_ped_itens_bnf.qtd_pecas_solic    = t_pedido_dig_item[pa_curr].qtd_item_bonif   
#       LET p_ped_itens_bnf.qtd_pecas_atend    = 0
#       LET p_ped_itens_bnf.qtd_pecas_cancel   = t_pedido_dig_item[pa_curr].qtd_item_bonif     
#       LET p_ped_itens_bnf.qtd_pecas_reserv   = 0
#       LET p_ped_itens_bnf.prz_entrega        = t_pedido_dig_item[pa_curr].prz_entrega
#       LET p_ped_itens_bnf.qtd_pecas_romaneio = 0
#       LET p_ped_itens_bnf.pct_desc_bruto     = 0
#
#       IF   p_par_vdp.par_vdp_txt[22,22] = "S"
#       THEN CALL vdp596_pesquisa_ctr_meta(p_cod_empresa,
#                                          p_ped_itens_bnf.num_pedido,
#                                          p_ped_itens_bnf.cod_item ,
#                                          p_pedido_dig_mest.cod_repres,
#                                          p_pedido_dig_mest.dat_digitacao,
#                                          p_ped_itens_bnf.qtd_pecas_solic)
#                 RETURNING p_achou, p_ctr_meta.*
#            IF   p_achou = TRUE
#            THEN IF   p_pedido_dig_mest.ies_aceite_comer = "S" OR
#                      p_par_vdp.par_vdp_txt[19,19] = "N" 
#                 THEN
#                 ELSE IF   pol0185_verifica_meta_venda()
#                      THEN 
#                      END IF
#                 END IF
#            END IF
#       END IF
#       IF   p_erro = FALSE
#       THEN INSERT INTO ped_itens_bnf VALUES (p_ped_itens_bnf.*)
#            IF   sqlca.sqlcode = 0
#            THEN 
#            ELSE LET p_houve_erro = TRUE
#                 CALL log003_err_sql("INCLUSAO","PED_ITENS")
#            END IF
#            CALL pol0185_incl_ped_of_pcp()
#       ELSE INSERT INTO ped_dig_item_bnf VALUES (p_cod_empresa,
#                                                 p_pedido_dig_mest.num_pedido,
#                                            pa_curr,
#                                            t_pedido_dig_item[pa_curr].cod_item,
#                                            t_pedido_dig_item[pa_curr].qtd_item_bonif,
#                                 			 		     t_pedido_dig_item[pa_curr].pre_unit,
#					                                       t_pedido_dig_item[pa_curr].pct_desc_adic,
#                                            0,
#                                            t_pedido_dig_item[pa_curr].prz_entrega)
#      END IF
#  ELSE EXIT FOR
#  END IF
#END FOR
#END FUNCTION
#

#--------------------------------#
 FUNCTION pol0185_incl_ped_of_pcp()
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
 IF sqlca.sqlcode = 0
 THEN
 ELSE RETURN
 END IF
 SELECT ies_emite_of
   INTO p_ies_emite_of
   FROM linha_prod
   WHERE linha_prod.cod_lin_prod  = p_cod_lin_prod
     AND linha_prod.cod_lin_recei = p_cod_lin_recei
     AND linha_prod.cod_seg_merc  = p_cod_seg_merc
     AND linha_prod.cod_cla_uso   = p_cod_cla_uso
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
           INSERT INTO ped_ord_fabr VALUES (p_ped_ord_fabr.*)
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
           INSERT INTO ped_pcp VALUES (p_ped_pcp.*)
           IF sqlca.sqlcode = 0
           THEN RETURN
           ELSE LET p_houve_erro = TRUE
                CALL log003_err_sql("INCLUSAO","PED_PCP")
           END IF
 END CASE
END FUNCTION

#---------------------------------#
 FUNCTION pol0185_total(p_funcao)
#---------------------------------#
 DEFINE p_funcao                CHAR(12),
        p_pct_desc_m            LIKE ped_itens.pct_desc_adic,
        p_pct_desc_i            LIKE ped_itens.pct_desc_adic,
        p_total_val_liq         DECIMAL(15,2) ,
        p_total_val_bru         DECIMAL(15,2) 
          
 CALL log006_exibe_teclas("01 02 07", p_versao)
 WHENEVER ERROR CONTINUE
 CALL log130_procura_caminho("pol01853") RETURNING p_nom_tela
 OPEN WINDOW w_pol01853 AT 2,02 WITH FORM p_nom_tela    
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 WHENEVER ERROR STOP  
 CURRENT WINDOW IS w_pol01853
 #DISPLAY FORM f_pol01853 
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
         CALL vdp784_busca_desc_adic_unico(p_cod_empresa,
                                           p_pedido_dig_mest.num_pedido,
                                           0,
                                           p_pedido_dig_mest.pct_desc_adic) 
             RETURNING p_pct_desc_m
         CALL pol0185_calcula_pre_unit(t_pedido_dig_item[p_count].pre_unit,
                                      p_pct_desc_m)
             RETURNING p_pre_unit_liq
         CALL vdp784_busca_desc_adic_unico(p_cod_empresa,
                                           p_pedido_dig_mest.num_pedido,
                                           p_count,
                                           t_pedido_dig_item[p_count].pct_desc_adic) 
             RETURNING p_pct_desc_i
         CALL pol0185_calcula_pre_unit(p_pre_unit_liq,
                                      p_pct_desc_i)
             RETURNING p_pre_unit_liq
         LET p_totalc.val_tot_liquido = p_totalc.val_tot_liquido +
                                        ( p_pre_unit_liq * 
                                        t_pedido_dig_item[p_count].qtd_pecas_solic)

    ELSE EXIT FOR
    END IF
 END FOR

 IF p_par_vdp.par_vdp_txt[20,20] = "N" THEN
#   DISPLAY BY NAME p_totalc.*
    DISPLAY p_totalc.quantidade        TO quantidade                    
    DISPLAY p_totalc.preco             TO preco
    DISPLAY p_totalc.desc_adic         TO desc_adic
    DISPLAY p_totalc.val_tot_bruto     TO total_val_bru    
    DISPLAY p_totalc.val_tot_liquido   TO total_val_liq

#  osvaldo
      SELECT val_max_ped
         INTO p_val_max_ped
      FROM max_cond_pgto_alb
      WHERE cod_empresa = p_cod_empresa
        AND cod_cnd_pgto = p_pedido_dig_mest.cod_cnd_pgto
      IF SQLCA.SQLCODE = 0 THEN 
         IF p_totalc.val_tot_liquido < p_val_max_ped THEN
            LET p_ies_cond = "S"      
            LET p_erro = TRUE            
         END IF
      END IF
      SELECT cod_cnd_pgto
         INTO p_cod_cnd_pgto
      FROM cli_oper_albras   
      WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
      IF SQLCA.SQLCODE = 0 THEN 
         IF p_pedido_dig_mest.cod_cnd_pgto <> p_cod_cnd_pgto THEN
            LET p_ies_cond_cli = "S"
            LET p_erro = TRUE            
         ELSE
            LET p_ies_cond_cli = "N"
         END IF 
      ELSE
         LET p_ies_cond_cli = "N"
      END IF
#  osvaldo

      IF (p_ies_cond = "S" OR p_ies_cond_cli = "S") AND 
         p_ies_faturado =  "S" AND 
         p_ies_desconto =  "S" AND 
         p_ies_minimo   =  "S" THEN 
         LET p_cod_moeda_cons = 84
      END IF 

      IF (p_ies_cond = "S" OR p_ies_cond_cli = "S") AND 
         p_ies_faturado =  "N" AND 
         p_ies_desconto =  "S" AND 
         p_ies_minimo   =  "S" THEN 
         LET p_cod_moeda_cons = 85
      END IF 

      IF (p_ies_cond = "S" OR p_ies_cond_cli = "S") AND 
         p_ies_faturado =  "S" AND 
         p_ies_desconto =  "S" AND 
         p_ies_minimo   =  "N" THEN 
         LET p_cod_moeda_cons = 86
      END IF 

      IF (p_ies_cond = "S" OR p_ies_cond_cli = "S") AND 
         p_ies_faturado =  "S" AND 
         p_ies_desconto =  "N" AND 
         p_ies_minimo   =  "S" THEN 
         LET p_cod_moeda_cons = 87
      END IF 

      IF (p_ies_cond = "N" AND p_ies_cond_cli = "N") AND 
         p_ies_faturado =  "S" AND 
         p_ies_desconto =  "S" AND 
         p_ies_minimo   =  "S" THEN 
         LET p_cod_moeda_cons = 88
      END IF 

      IF (p_ies_cond = "S" OR p_ies_cond_cli = "S") AND 
         p_ies_faturado =  "N" AND 
         p_ies_desconto =  "S" AND 
         p_ies_minimo   =  "N" THEN 
         LET p_cod_moeda_cons = 89
      END IF 

      IF (p_ies_cond = "S" OR p_ies_cond_cli = "S") AND 
         p_ies_faturado =  "N" AND 
         p_ies_desconto =  "N" AND 
         p_ies_minimo   =  "S" THEN 
         LET p_cod_moeda_cons = 90
      END IF 

      IF (p_ies_cond = "N" AND p_ies_cond_cli = "N") AND 
         p_ies_faturado =  "N" AND 
         p_ies_desconto =  "S" AND 
         p_ies_minimo   =  "S" THEN 
         LET p_cod_moeda_cons = 91
      END IF 

      IF (p_ies_cond = "S" OR p_ies_cond_cli = "S") AND 
         p_ies_faturado =  "S" AND 
         p_ies_desconto =  "N" AND 
         p_ies_minimo   =  "N" THEN 
         LET p_cod_moeda_cons = 92
      END IF 

      IF (p_ies_cond = "N" AND p_ies_cond_cli = "N") AND 
         p_ies_faturado =  "S" AND 
         p_ies_desconto =  "S" AND 
         p_ies_minimo   =  "N" THEN 
         LET p_cod_moeda_cons = 93
      END IF 

      IF (p_ies_cond = "N" AND p_ies_cond_cli = "N") AND 
         p_ies_faturado =  "S" AND 
         p_ies_desconto =  "N" AND 
         p_ies_minimo   =  "S" THEN 
         LET p_cod_moeda_cons = 94
      END IF 

      IF (p_ies_cond = "S" OR p_ies_cond_cli = "S") AND 
         p_ies_faturado =  "N" AND 
         p_ies_desconto =  "N" AND 
         p_ies_minimo   =  "N" THEN 
         LET p_cod_moeda_cons = 95
      END IF 

      IF (p_ies_cond = "N" AND p_ies_cond_cli = "N") AND 
         p_ies_faturado =  "N" AND 
         p_ies_desconto =  "S" AND 
         p_ies_minimo   =  "N" THEN 
         LET p_cod_moeda_cons = 96
      END IF 

      IF (p_ies_cond = "N" AND p_ies_cond_cli = "N") AND 
         p_ies_faturado =  "N" AND 
         p_ies_desconto =  "N" AND 
         p_ies_minimo   =  "S" THEN 
         LET p_cod_moeda_cons = 97
      END IF 

      IF (p_ies_cond = "N" AND p_ies_cond_cli = "N") AND 
         p_ies_faturado =  "S" AND 
         p_ies_desconto =  "N" AND 
         p_ies_minimo   =  "N" THEN 
         LET p_cod_moeda_cons = 98
      END IF 

      IF log004_confirm(17,40) = TRUE 
      THEN LET p_status = 0
           LET p_tela = 0
           LET p_flag = 0
           RETURN p_status
      ELSE LET p_status = 1
           LET p_tela = 3
           LET int_flag = 0
           RETURN p_status
      END IF
 END IF
 LET p_tela = 0
 LET p_flag = 0
 RETURN TRUE
END FUNCTION

#---------------------------------------------------------------#
 FUNCTION pol0185_busca_preco_lista(p_cod_item, p_cod_lin_prod,
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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF

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
 IF sqlca.sqlcode = 0
 THEN LET p_status = 0
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 ELSE LET p_status = 1
      RETURN p_status, p_desc_bruto_tab, p_desc_adic_tab, p_pre_unit_tab
 END IF
 END FUNCTION

#----------------------------------------------#
 FUNCTION pol0185_verifica_finalidade_tipo_cli()
#----------------------------------------------#
  SELECT ies_finalidade
    INTO p_pedido_dig_mest.ies_finalidade 
    FROM tipo_cli_finalid
   WHERE cod_tip_cli = p_cod_tip_cli
  IF   sqlca.sqlcode = NOTFOUND 
  THEN RETURN TRUE
  ELSE RETURN TRUE
  END IF
END FUNCTION

#-------------------------------------#
 FUNCTION pol0185_verifica_finalidade()
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
                 ELSE ERROR " Finalidade incorreta para o cliente. "
                      RETURN false
                 END IF
            ELSE ERROR " Finalidade incorreta para o cliente. "
                 RETURN false
            END IF
       END IF
 END IF
 END FUNCTION

#-----------------------------------------#
 FUNCTION pol0185_verifica_credito_cliente()
#-----------------------------------------#
 DEFINE     p_qtd_dias_atr_dupl    LIKE cli_credito.qtd_dias_atr_dupl,
            p_qtd_dias_atr_med     LIKE cli_credito.qtd_dias_atr_med,
            p_ies_nota_debito      LIKE cli_credito.ies_nota_debito,
            p_val_cotacao          LIKE cotacao_mes.val_cotacao,
            p_dat_val_lmt_cr       LIKE cli_credito.dat_val_lmt_cr

IF   p_par_vdp.par_vdp_txt[40,40] = "S"
THEN SELECT cod_cliente_matriz  INTO p_cod_cliente_matriz
            FROM clientes
            WHERE clientes.cod_cliente = p_pedido_dig_mest.cod_cliente
     IF   p_cod_cliente_matriz IS NULL OR p_cod_cliente_matriz = " "
     THEN LET p_cod_cliente_matriz = p_pedido_dig_mest.cod_cliente
     END IF
ELSE LET p_cod_cliente_matriz = p_pedido_dig_mest.cod_cliente
END IF
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
 IF   sqlca.sqlcode <> 0
 THEN ERROR " Cliente sem dados de credito. "
      RETURN false
 END IF
 IF   p_ies_nota_debito = "S"
 THEN ERROR " Cliente com nota de debito em aberto. "
      RETURN false
 END IF
 IF   p_qtd_dias_atr_dupl > p_par_vdp.qtd_dias_atr_dupl
 THEN ERROR " Cliente com duplicata em atrazo. "
      RETURN false
 END IF
 IF   p_qtd_dias_atr_med > p_par_vdp.qtd_dias_atr_med
 THEN ERROR " Cliente com atrazo medio de duplicata. "
      RETURN false
 END IF

 IF   p_dat_val_lmt_cr  < TODAY
 THEN ERROR " Data de limite de credito Expirada  "
      RETURN false
 END IF

 SELECT val_cotacao
   INTO p_val_cotacao
   FROM cotacao
  WHERE cotacao.cod_moeda = p_par_vdp.cod_moeda
    AND cotacao.dat_ref   = TODAY
 IF   sqlca.sqlcode <> 0
 THEN WHENEVER ERROR CONTINUE
      CURRENT WINDOW IS w_pol01851
      OPEN WINDOW w_pol01851 AT 10,10 WITH 5 ROWS, 30 COLUMNS
           ATTRIBUTE(BORDER, PROMPT LINE LAST)
      WHENEVER ERROR STOP
      DISPLAY "Cotacao da moeda para calculo"  AT 1,1
      DISPLAY "do limite de credito do clien-" AT 2,1
      DISPLAY "te do  mes corrente nao cadas-" AT  3,1
      DISPLAY "trado" AT 4,1
      ERROR " "
      PROMPT "Tecle ENTER para continuar" FOR p_comando
      CLOSE WINDOW w_pol01851 
      RETURN false
 END IF
 LET p_val_limite_cred_cruz = p_val_limite_cred_unid * p_val_cotacao
 RETURN true
 END FUNCTION

#------------------------------#
 FUNCTION vdp106_inclui_texto()
#------------------------------#
   DEFINE p_ped_itens_txt    RECORD LIKE ped_itens_texto.*
   INITIALIZE p_ped_itens_txt.* TO NULL
   DECLARE cq_ped_txt CURSOR WITH HOLD FOR
    SELECT * FROM pedido_dig_texto
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_pedido_dig_mest.num_pedido
   FOREACH cq_ped_txt INTO p_ped_itens_txt.*
     WHENEVER ERROR CONTINUE
     SELECT * FROM ped_itens_texto 
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_ped_itens_txt.num_pedido
        AND num_sequencia = p_ped_itens_txt.num_sequencia
     IF sqlca.sqlcode = NOTFOUND 
        THEN INSERT INTO ped_itens_texto VALUES (p_ped_itens_txt.*)
     ELSE 
        UPDATE ped_itens_texto SET ped_itens_texto.* = p_ped_itens_txt.*
         WHERE ped_itens_texto.cod_empresa = p_cod_empresa
           AND ped_itens_texto.num_pedido  = p_ped_itens_txt.num_pedido
           AND ped_itens_texto.num_sequencia = p_ped_itens_txt.num_sequencia
     END IF 
     WHENEVER ERROR STOP
   END FOREACH
   WHENEVER ERROR CONTINUE
   DELETE FROM pedido_dig_texto
    WHERE pedido_dig_texto.cod_empresa   = p_cod_empresa
      AND pedido_dig_texto.num_pedido    = p_pedido_dig_mest.num_pedido
   WHENEVER ERROR STOP
 END FUNCTION

#-------------------------------------#
 FUNCTION pol0185_verifica_meta_venda()
#-------------------------------------#
#IF (p_pedido_dig_item.qtd_pecas_solic + p_ctr_meta.qtd_venda) >
#    p_ctr_meta.qtd_remanejada
#THEN ERROR "QTDE PEDIDO EXCEDEU META DE VENDA"
#     LET p_erro = TRUE
#     RETURN FALSE
#END IF
 RETURN TRUE
 END FUNCTION

#------------------------------#
 FUNCTION pol0185_move_dados()
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
 LET p_pedido_dig_mest.cod_tip_venda      = "01"
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

 FOR p_ind = 1 TO 500 
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

  LET t_ped_itens_desc[p_ind].pct_desc_1 = 0
  LET t_ped_itens_desc[p_ind].pct_desc_2 = 0
  LET t_ped_itens_desc[p_ind].pct_desc_3 = 0
  LET t_ped_itens_desc[p_ind].pct_desc_4 = 0
  LET t_ped_itens_desc[p_ind].pct_desc_5 = 0
  LET t_ped_itens_desc[p_ind].pct_desc_6 = 0
  LET t_ped_itens_desc[p_ind].pct_desc_7 = 0
  LET t_ped_itens_desc[p_ind].pct_desc_8 = 0
  LET t_ped_itens_desc[p_ind].pct_desc_9 = 0
  LET t_ped_itens_desc[p_ind].pct_desc_10 = 0
 END FOR

 END FUNCTION

#--------------------------------------------#
#FUNCTION pol0185_mostra_estoque(p_cod_item)
#--------------------------------------------#
#DEFINE p_cod_item     LIKE ped_itens.cod_item,
#       p_qtd_liberada LIKE estoque.qtd_liberada,
#       p_qtd_carteira LIKE ped_itens.qtd_pecas_solic,
#       p_qtd_estoque  LIKE estoque.qtd_liberada 
#
#MESSAGE "Calculando estoque ... "  ATTRIBUTE(REVERSE)
#
#SELECT (qtd_liberada - qtd_reservada), qtd_liberada
#  INTO p_qtd_liberada, p_qtd_estoque
#  FROM estoque
# WHERE cod_empresa = p_cod_empresa
#   AND cod_item    = p_cod_item
#
#SELECT SUM(qtd_pecas_solic)  INTO p_qtd_carteira
#  FROM ped_itens
# WHERE cod_empresa = p_cod_empresa
#   AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel) > 0
#
#MESSAGE ""
#
#END FUNCTION
 
#-----------------------------------------------#
 FUNCTION pol0185_mostra_estoque(p_cod_item_est)
#-----------------------------------------------#
DEFINE    p_cod_item_est    LIKE pedido_dig_item.cod_item 

 MESSAGE "Calculando estoque ... "  ATTRIBUTE(REVERSE)

LET p_qtd_estoque    = 0
LET p_qtd_carteira   = 0
LET p_qtd_disponivel = 0

SELECT qtd_liberada
  INTO p_qtd_estoque
  FROM estoque
 WHERE estoque.cod_empresa = p_cod_empresa
   AND estoque.cod_item    = p_cod_item_est 
 IF   p_qtd_estoque IS NULL OR
      p_qtd_estoque < 0
 THEN LET p_qtd_estoque   = 0 
 END IF
 
 SELECT SUM(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel)
   INTO p_qtd_carteira
   FROM ped_itens
  WHERE ped_itens.cod_empresa = p_cod_empresa
    AND ped_itens.cod_item    = p_cod_item_est
    AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel) > 0
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
FUNCTION pol0185_controle_peditdesc(p_cod_emp, p_num_ped, p_num_seq)
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
 
   INITIALIZE p_nom_tela,
              p_desc_mest  TO NULL

   LET p_ind = 1  
   LET p_ja_atualizou = FALSE

   CALL log130_procura_caminho("pol01854") RETURNING p_nom_tela
   OPEN WINDOW w_pol01854 AT 2,2  WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   CURRENT WINDOW IS w_pol01854
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol01854

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

      AFTER INPUT
         LET p_pct_desc_tot = p_ped_itens_desc.pct_desc_1 +
                              p_ped_itens_desc.pct_desc_2 +
                              p_ped_itens_desc.pct_desc_3 +
                              p_ped_itens_desc.pct_desc_4 +
                              p_ped_itens_desc.pct_desc_5 +
                              p_ped_itens_desc.pct_desc_6 +
                              p_ped_itens_desc.pct_desc_7 +
                              p_ped_itens_desc.pct_desc_8 +
                              p_ped_itens_desc.pct_desc_10
         LET p_desc_tot = p_pct_desc_tot

         LET p_desc_tot = 100 - 
                         (100 * p_ped_itens_desc.pct_desc_1 / 100 )
         LET p_desc_tot = p_desc_tot - 
                         (p_desc_tot * p_ped_itens_desc.pct_desc_2 / 100 )
         LET p_desc_tot = p_desc_tot - 
                         (p_desc_tot * p_ped_itens_desc.pct_desc_3 / 100 )
         LET p_desc_tot = p_desc_tot - 
                         (p_desc_tot * p_ped_itens_desc.pct_desc_4 / 100 )
         LET p_desc_tot = p_desc_tot -
                         (p_desc_tot * p_ped_itens_desc.pct_desc_5 / 100 )
         LET p_desc_tot = p_desc_tot -
                         (p_desc_tot * p_ped_itens_desc.pct_desc_6 / 100 )
         LET p_desc_tot = p_desc_tot -
                         (p_desc_tot * p_ped_itens_desc.pct_desc_7 / 100 )
         LET p_desc_tot = p_desc_tot -
                         (p_desc_tot * p_ped_itens_desc.pct_desc_8 / 100 )
         LET p_desc_tot = p_desc_tot -
                         (p_desc_tot * p_ped_itens_desc.pct_desc_9 / 100 )
         LET p_desc_tot = p_desc_tot - 
                         (p_desc_tot * p_ped_itens_desc.pct_desc_10 / 100)
         LET p_desc_unico_mest = 100 - p_desc_tot
         IF p_desc_unico_mest > p_par_vdp.pct_desc_adic THEN 
            ERROR "Pct. desconto adicional maior que limite "
            LET p_erro = TRUE
            NEXT FIELD pct_desc_1
         END IF

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

   CLOSE WINDOW w_pol01854
   LET int_flag = 0
END FUNCTION

#---------------------------------------#
 FUNCTION pol0185_inclui_ped_itens_desc()
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
        IF p_erro = FALSE THEN 
           INSERT INTO ped_itens_desc VALUES (p_ped_itens_desc.* )
           IF sqlca.sqlcode  = 0 THEN 
           ELSE    
              LET p_houve_erro = TRUE
              CALL log003_err_sql("INCLUSAO","PED_ITENS_DESC")
           END IF
        ELSE
           INSERT INTO ped_dig_item_desc VALUES (p_ped_itens_desc.*)
      END IF
   END IF
 END FOR
END FUNCTION

#------------------------------------------------------#
 FUNCTION pol0185_busca_desc_adic_unico(p_num_sequencia,
				       p_desc)
#------------------------------------------------------#
 DEFINE  p_ped_itens_desc     RECORD LIKE ped_itens_desc.*,
         p_desc_unico         DECIMAL(8,0), 
         p_cod_empresa        LIKE empresa.cod_empresa,
         p_num_pedido         LIKE pedidos.num_pedido,
         p_num_sequencia      LIKE ped_itens.num_sequencia,
         p_desc               LIKE wfat_item.pct_desc_adic,
         p_desc_i             SMALLINT

  INITIALIZE p_desc_unico TO NULL
  LET p_desc_unico = p_desc
  FOR p_desc_i = 1 TO pa_currdes 
  IF t_ped_itens_desc[p_desc_i].num_sequencia = p_num_sequencia AND 
    (t_ped_itens_desc[p_desc_i].pct_desc_1 > 0 ) THEN
    LET  p_desc = 100    - ( 100    * p_desc / 100 )
    LET  p_desc = p_desc - ( p_desc * t_ped_itens_desc[p_desc_i].pct_desc_1 / 100 )
    LET  p_desc = p_desc - ( p_desc * t_ped_itens_desc[p_desc_i].pct_desc_2 / 100 )  
    LET  p_desc = p_desc - ( p_desc * t_ped_itens_desc[p_desc_i].pct_desc_3 / 100 )
    LET  p_desc = p_desc - ( p_desc * t_ped_itens_desc[p_desc_i].pct_desc_4 / 100 )
    LET  p_desc = p_desc - ( p_desc * t_ped_itens_desc[p_desc_i].pct_desc_5 / 100 )
    LET  p_desc = p_desc - ( p_desc * t_ped_itens_desc[p_desc_i].pct_desc_6 / 100 )
    LET  p_desc = p_desc - ( p_desc * t_ped_itens_desc[p_desc_i].pct_desc_7 / 100 )
    LET  p_desc = p_desc - ( p_desc * t_ped_itens_desc[p_desc_i].pct_desc_8 / 100 )
    LET  p_desc = p_desc - ( p_desc * t_ped_itens_desc[p_desc_i].pct_desc_9 / 100 )
    LET  p_desc = p_desc - ( p_desc * t_ped_itens_desc[p_desc_i].pct_desc_10 / 100 )
    LET p_passou_ok = TRUE
    END IF
END FOR
  IF p_passou_ok = FALSE THEN 
     RETURN p_desc_unico 
  END IF
  LET p_passou_ok = FALSE
  LET p_desc_unico = 100 - p_desc
  IF p_desc_unico > 99 THEN 
     LET p_desc_unico = 0
  END IF

  RETURN p_desc_unico
END FUNCTION

#-------------------------------------#
 FUNCTION pol0185_verifica_carteira()
#-------------------------------------#
 SELECT * FROM tipo_carteira
        WHERE cod_tip_carteira = p_pedido_dig_mest.cod_tip_carteira
 IF   sqlca.sqlcode = 0
 THEN RETURN TRUE
 ELSE RETURN FALSE
 END IF 
 END FUNCTION 

#----------------------------------------#
 FUNCTION pol0185_existe_nat_oper_refer()
#----------------------------------------#
   SELECT cod_nat_oper_ref INTO m_cod_nat_oper_ref FROM nat_oper_refer
    WHERE cod_empresa  = p_cod_empresa
      AND cod_nat_oper = p_pedido_dig_mest.cod_nat_oper
      AND cod_item     = t_pedido_dig_item[pa_curr].cod_item

   IF sqlca.sqlcode = 0
      THEN RETURN TRUE
      ELSE RETURN FALSE
   END IF
END FUNCTION

#------------------------------------#
 FUNCTION pol0185_existe_fiscal_par()
#------------------------------------#
   SELECT * FROM fiscal_par
    WHERE cod_empresa   = p_cod_empresa
      AND cod_nat_oper  = m_cod_nat_oper_ref
      AND cod_uni_feder = p_cod_uni_feder

   IF sqlca.sqlcode <> 0 THEN
      SELECT * FROM fiscal_par
       WHERE cod_empresa    = p_cod_empresa
         AND cod_nat_oper   = m_cod_nat_oper_ref
         AND cod_uni_feder IS NULL
   END IF

   IF sqlca.sqlcode = 0
      THEN RETURN TRUE
      ELSE RETURN FALSE
   END IF
END FUNCTION

#---------------------------------------#
 FUNCTION pol0185_insert_ped_itens_rem()
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
  
  INSERT INTO ped_itens_rem VALUES (p_ped_itens_rem.*)
  IF   sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("INCLUSAO","PED_ITENS_REM")
  END IF
END FUNCTION

#--------------------------------------#
FUNCTION pol0185_entrada_ped_itens_rem()
#--------------------------------------#
  INITIALIZE p_ped_itens_rem.*   TO NULL
  
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
  
  CALL log006_exibe_teclas("01 02 07", p_versao)
  WHENEVER ERROR CONTINUE
  CALL log130_procura_caminho("pol01855") RETURNING p_comando
  OPEN WINDOW w_pol01855 AT 2,2 WITH FORM p_comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  WHENEVER ERROR STOP
  CURRENT WINDOW IS w_pol01855
  
  DISPLAY t_pedido_dig_item[pa_curr].cod_item TO cod_item
  DISPLAY p_pedido_dig_mest.cod_cliente       TO cod_cliente
  DISPLAY p_nom_cliente                       TO nom_cliente
  DISPLAY BY NAME p_ped_itens_rem.*
  
  CALL pol0185_verifica_motivo_remessa()      RETURNING p_status
  CALL pol0185_verifica_area_negocio()        RETURNING p_status
  CALL pol0185_verifica_linha_negocio()       RETURNING p_status
  
  INPUT BY NAME p_ped_itens_rem.* WITHOUT DEFAULTS
    
    AFTER FIELD dat_emis_nf_usina
          IF   p_ped_itens_rem.dat_emis_nf_usina > TODAY
          THEN ERROR " Data de Emissao da NF maior que data atual. "
               NEXT FIELD dat_emis_nf_usina
          END IF
    
    BEFORE FIELD cod_motivo_remessa
           DISPLAY "( Zoom )" AT 3,68
    AFTER  FIELD cod_motivo_remessa
           IF   pol0185_verifica_motivo_remessa() = FALSE
           THEN ERROR " Motivo nao cadastrado."
                NEXT FIELD cod_motivo_remessa 
           END IF
           DISPLAY "--------" AT 3,68
    
    AFTER  FIELD val_estoque
           IF   p_ped_itens_rem.val_estoque IS NULL
           THEN ERROR " Valor Estoque Invalido "
                NEXT FIELD val_estoque       
           END IF
    
    BEFORE FIELD cod_area_negocio
           DISPLAY "( Zoom )" AT 3,68
    AFTER  FIELD cod_area_negocio
           IF   p_ped_itens_rem.cod_area_negocio IS NULL
           THEN ERROR " Codigo Area Negocio Invalido "
                NEXT FIELD cod_area_negocio   
           END IF
           IF   pol0185_verifica_area_negocio() = FALSE
           THEN ERROR " Area de Negocio nao cadastrada "
                NEXT FIELD cod_area_negocio   
           END IF
           DISPLAY "--------" AT 3,68
    
    BEFORE FIELD cod_lin_negocio
           DISPLAY "( Zoom )" AT 3,68
    AFTER  FIELD cod_lin_negocio
           IF   p_ped_itens_rem.cod_lin_negocio IS NULL
           THEN ERROR " Codigo Linha Negocio Invalido "
                NEXT FIELD cod_lin_negocio   
           END IF
           IF   pol0185_verifica_linha_negocio() = FALSE
           THEN ERROR " Linha de Negocio nao cadastrada "
                NEXT FIELD cod_lin_negocio   
           END IF
           IF   pol0185_verifica_area_lin_negocio() = FALSE
           THEN ERROR " Relacionamento Area x Linha de negocio nao cadastrado "
                NEXT FIELD cod_lin_negocio
           END IF 
           DISPLAY "--------" AT 3,68
    
    BEFORE FIELD num_conta
           DISPLAY "( Zoom )" AT 3,68
    AFTER  FIELD num_conta          
           IF   p_ped_itens_rem.num_conta IS NOT NULL THEN
                CALL con088_verifica_cod_conta(p_cod_empresa,
                                               p_ped_itens_rem.num_conta, 
                                               "S",
                                               " ")
                     RETURNING p_plano_contas.*, p_plano 
                IF   p_plano = FALSE
                THEN ERROR "Conta Contabil nao Cadastrada"
                     NEXT FIELD num_conta         
                END IF       
           END IF           
           DISPLAY "--------" AT 3,68
    
    AFTER  FIELD num_pedido_compra  
           IF   p_ies_item_em_terc_ped = "S"
           THEN IF   pol0185_verifica_pedido_compra() = FALSE
                THEN NEXT FIELD num_pedido_compra
                END IF
           END IF 
    
    ON KEY (control-w, f1)
           CALL pol0185_help_rem()
    
    ON KEY (control-z)
           CALL pol0185_popup_rem()
  END INPUT
  
  CLOSE WINDOW w_pol01855
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_pol01852
  
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
 FUNCTION pol0185_help_rem()
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

#---------------------------#
 FUNCTION pol0185_popup_rem()
#---------------------------#

   DEFINE p_mot_rem LIKE ped_itens_rem.cod_motivo_remessa
  
   CASE
      WHEN INFIELD(cod_motivo_remessa)
         LET p_mot_rem = sup260_popup_motivo_remessa(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol01855
         IF p_mot_rem IS NOT NULL THEN 
            LET p_ped_itens_rem.cod_motivo_remessa = p_mot_rem
            DISPLAY BY NAME p_ped_itens_rem.cod_motivo_remessa
         END IF
   END CASE

END FUNCTION

#------------------------------------------#
 FUNCTION pol0185_verifica_motivo_remessa()
#------------------------------------------#
   DEFINE p_den_motivo_remessa LIKE motivo_remessa.den_motivo_remessa
   
   INITIALIZE p_den_motivo_remessa TO NULL
   SELECT den_motivo_remessa
     INTO p_den_motivo_remessa
     FROM motivo_remessa
    WHERE motivo_remessa.cod_empresa        = p_cod_empresa
      AND motivo_remessa.cod_motivo_remessa = p_ped_itens_rem.cod_motivo_remessa
      
   DISPLAY p_den_motivo_remessa TO den_motivo_remessa
   
   IF   sqlca.sqlcode = 0
   THEN RETURN TRUE
   ELSE RETURN FALSE
   END IF
END FUNCTION

#----------------------------------------#
 FUNCTION pol0185_verifica_area_negocio()
#----------------------------------------#
  DEFINE p_den_area_negocio LIKE area_negocio.den_area_negocio
  
  INITIALIZE p_den_area_negocio TO NULL
  SELECT den_area_negocio               
    INTO p_den_area_negocio 
    FROM area_negocio 
    WHERE area_negocio.cod_empresa  = p_cod_empresa       
      AND area_negocio.cod_area_negocio = p_ped_itens_rem.cod_area_negocio
  DISPLAY p_den_area_negocio TO den_area_negocio
  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0185_verifica_linha_negocio()
#-----------------------------------------#
  DEFINE p_den_lin_negocio LIKE linha_negocio.den_lin_negocio
  
  INITIALIZE p_den_lin_negocio TO NULL
  SELECT den_lin_negocio               
    INTO p_den_lin_negocio 
    FROM linha_negocio 
    WHERE linha_negocio.cod_empresa     = p_cod_empresa       
      AND linha_negocio.cod_lin_negocio = p_ped_itens_rem.cod_lin_negocio
  DISPLAY p_den_lin_negocio TO den_lin_negocio
  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#--------------------------------------------#
 FUNCTION pol0185_verifica_area_lin_negocio()
#--------------------------------------------#
  DEFINE l_soma    SMALLINT
  LET l_soma = 0 
  SELECT count(*) INTO l_soma
     FROM area_lin_negocio
    WHERE area_lin_negocio.cod_empresa        = p_cod_empresa
      AND area_lin_negocio.cod_area_negocio   = p_ped_itens_rem.cod_area_negocio
      AND area_lin_negocio.cod_lin_negocio    = p_ped_itens_rem.cod_lin_negocio
  IF l_soma > 0
  THEN RETURN TRUE
  ELSE RETURN FALSE 
  END IF
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0185_verifica_pedido_compra()
#-----------------------------------------#
   DEFINE p_cgc_fornecedor              LIKE clientes.num_cgc_cpf,
          p_cod_fornecedor              LIKE fornecedor.cod_fornecedor,
          p_qtd_saldo_item_terc         LIKE ordem_sup.qtd_solic 

   SELECT num_cgc_cpf
     INTO p_cgc_fornecedor
     FROM clientes
    WHERE cod_cliente  = p_pedido_dig_mest.cod_cliente

   SELECT cod_fornecedor
     INTO p_cod_fornecedor
     FROM fornecedor
    WHERE num_cgc_cpf = p_cgc_fornecedor
   IF sqlca.sqlcode <> 0 THEN
      ERROR "Fornecedor nao cadastrado na tabela de fornecedores."
      RETURN FALSE
   END IF 

   SELECT UNIQUE cod_empresa
     FROM pedido_sup
    WHERE cod_empresa    = p_cod_empresa
      AND num_pedido     = p_ped_itens_rem.num_pedido_compra
      AND cod_fornecedor = p_cod_fornecedor
      AND ies_situa_ped  IN ("R","A") 
   IF sqlca.sqlcode <> 0 THEN
      ERROR "Pedido/Fornecedor nao cadastrado na tabela pedido_sup."
      RETURN FALSE
   END IF 

   SELECT SUM(qtd_solic - qtd_recebida)
     INTO p_qtd_saldo_item_terc
     FROM ordem_sup
    WHERE cod_empresa      = p_cod_empresa
      AND num_pedido       = p_ped_itens_rem.num_pedido_compra
      AND cod_item         = t_pedido_dig_item[pa_curr].cod_item
      AND ies_versao_atual = "S"
   IF p_qtd_saldo_item_terc IS NULL OR 
      p_qtd_saldo_item_terc = " "   THEN
      LET p_qtd_saldo_item_terc = 0
      ERROR "Item do Ped. Comp. nao cadastrado na tabela ordem_sup."
      RETURN FALSE 
   END IF 
     
   RETURN TRUE
END FUNCTION 

