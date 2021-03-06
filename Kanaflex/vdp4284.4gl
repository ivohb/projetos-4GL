###PARSER-N�o remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: vdp4284                                               #
# MODULOS.: vdp4284 - LOG0010 - LOG0030 - LOG0040 - LOG0050       #
#           LOG0060 - LOG0090 - LOG0190 - LOG1200 - LOG1300       #
#           LOG1400 - VDP0120 - VDP0140 - VDP2430 - VDP3080       #
#           VDP3550 - VDP3720 - VDP4285                           #
# OBJETIVO: DIGITACAO DE PEDIDOS BATCH                            #
# AUTOR...: ANDREI DAGOBERTO STREIT                               #
# DATA....: 17/05/2002                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_pedido_dig_mest             RECORD LIKE pedido_dig_mest.*,
         p_pedido_dig_mestr            RECORD LIKE pedido_dig_mest.*,
         p_pedido_dig_obs              RECORD LIKE pedido_dig_obs.*,
         p_pedido_dig_obsr             RECORD LIKE pedido_dig_obs.*,
         p_pedido_dig_ent              RECORD LIKE pedido_dig_ent.*,
         p_pedido_dig_entr             RECORD LIKE pedido_dig_ent.*,
         p_pedido_dig_grad             RECORD LIKE ped_dig_itens_grad.*,
         p_ped_itens_grade             RECORD LIKE ped_itens_grade.*,
         p_pedido_dig_item             RECORD LIKE pedido_dig_item.*,
         p_ped_dig_item_bnf            RECORD LIKE ped_dig_item_bnf.*,
         p_ped_dig_item_desc           RECORD LIKE ped_dig_item_desc.*,
         p_ped_itens_rem               RECORD LIKE ped_itens_rem.*,
         p_ped_item_nat                RECORD LIKE ped_item_nat.*,
         p_audit_vdp                   RECORD LIKE audit_vdp.*,
         p_par_vdp                     RECORD LIKE par_vdp.*,
         p_plano_contas                RECORD LIKE plano_contas.*,
         p_vendor_pedido               RECORD LIKE vendor_pedido.*,
         p_vendor_pedidor	       RECORD LIKE vendor_pedido.*,
         p_cod_empresa_plano           LIKE par_con.cod_empresa_plano,
         p_nom_cliente                 LIKE clientes.nom_cliente,
	 p_num_cgc_cpf                 LIKE clientes.num_cgc_cpf,
	 p_ins_estadual                LIKE clientes.ins_estadual,
         p_pct_desc_tot                LIKE pedido_dig_mest.pct_desc_adic,
         p_ies_incid_ipi               LIKE fiscal_par.ies_incid_ipi,
         p_pct_ipi                     LIKE item.pct_ipi,
         p_cod_uni_feder               CHAR(02),
         g_ies_grafico                 SMALLINT


  DEFINE t_ped_dig_item_desc  ARRAY[500] OF RECORD
                   num_pedido          LIKE ped_dig_item_desc.num_pedido,
                   num_sequencia       LIKE ped_dig_item_desc.num_sequencia,
                   pct_desc_1          LIKE ped_dig_item_desc.pct_desc_1,
                   pct_desc_2          LIKE ped_dig_item_desc.pct_desc_2,
                   pct_desc_3          LIKE ped_dig_item_desc.pct_desc_3,
                   pct_desc_4          LIKE ped_dig_item_desc.pct_desc_4,
                   pct_desc_5          LIKE ped_dig_item_desc.pct_desc_5,
                   pct_desc_6          LIKE ped_dig_item_desc.pct_desc_6,
                   pct_desc_7          LIKE ped_dig_item_desc.pct_desc_7,
                   pct_desc_8          LIKE ped_dig_item_desc.pct_desc_8,
                   pct_desc_9          LIKE ped_dig_item_desc.pct_desc_9,
                   pct_desc_10         LIKE ped_dig_item_desc.pct_desc_10
                           END RECORD
  DEFINE t_pedido_dig_item ARRAY[500]
                                 OF RECORD
                   cod_item            LIKE pedido_dig_item.cod_item,
                   qtd_pecas_solic     LIKE pedido_dig_item.qtd_pecas_solic,
                   pre_unit            LIKE pedido_dig_item.pre_unit,
                   pct_desc_adic       LIKE pedido_dig_item.pct_desc_adic,
                   prz_entrega         LIKE pedido_dig_item.prz_entrega,
                   ies_incl_txt        CHAR(01),
                   val_frete_unit      LIKE pedido_dig_item.val_frete_unit,
                   val_seguro_unit     LIKE pedido_dig_item.val_seguro_unit,
                   parametro_dat       LIKE pedido_dig_item.prz_entrega
                           END RECORD

   DEFINE t_ped_dig_bnf                ARRAY[1000]
          OF RECORD
             cod_item                  LIKE ped_dig_item_bnf.cod_item,
             qtd_pecas_solic           LIKE ped_dig_item_bnf.qtd_pecas_solic,
             pre_unit                  LIKE ped_dig_item_bnf.pre_unit,
             pct_desc_adic             LIKE ped_dig_item_bnf.pct_desc_adic,
             prz_entrega               LIKE ped_dig_item_bnf.prz_entrega,
             den_item                  LIKE item.den_item
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
                   quantidade          DECIMAL(15,3),
                   preco               DECIMAL(15,2),
                   desc_adic           DECIMAL(06,2),
                   val_tot_bruto       DECIMAL(15,3),
                   val_tot_liquido     DECIMAL(15,3)
                           END RECORD
  DEFINE p_totalc          RECORD
                   quantidade          DECIMAL(15,3),
                   preco               DECIMAL(15,2),
                   desc_adic           DECIMAL(06,2),
                   val_tot_bruto       DECIMAL(15,3),
                   val_tot_liquido     DECIMAL(15,3)
                           END RECORD
  DEFINE p_cod_empresa                 LIKE empresa.cod_empresa,
         p_user                        LIKE usuario.nom_usuario,
         p_ies_cons, p_last_row        SMALLINT,
         p_status                      SMALLINT,
         pa_curr                       SMALLINT,
         pa_count                      SMALLINT,
         sc_curr                       SMALLINT,
         p_count                       SMALLINT,
         p_count_bnf                   SMALLINT,
         p_tela                        SMALLINT,
         p_for                         SMALLINT,
         p_aux                         SMALLINT,
         p_passou_ok                   SMALLINT,
         pa_currdes                    SMALLINT,
         p_flag                        SMALLINT,
         p_pula_campo                  SMALLINT,
         p_occur_1                     SMALLINT,
         p_occur_2                     SMALLINT,
         p_erro                        SMALLINT,
         p_houve_erro                  SMALLINT,
         p_qtd_item                    SMALLINT,
         p_pre_unit_liq                LIKE ped_itens.pre_unit,
         p_pre_unit_ped                LIKE pedido_dig_item.pre_unit,
         p_ies_tip_controle            LIKE nat_operacao.ies_tip_controle,
         p_ies_item_em_terc_ped        LIKE par_sup_pad.par_ies,
         p_ies_item_ped                LIKE par_vdp_pad.par_ies

  DEFINE p_item2                       RECORD LIKE item.*,
         p_sum_qtd_grade               DECIMAL(13,3),
         pa_curr_g                     SMALLINT,
         pa_count_g                    SMALLINT,
         pa_curr_bnf                   SMALLINT,
         sc_curr_g                     SMALLINT,
         sc_curr_bnf                   SMALLINT,
         p_qtd_grade                   SMALLINT

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

  DEFINE p_comando                     CHAR(80),
         p_caminho                     CHAR(80),
         p_nom_tela                    CHAR(80),
         p_help                        CHAR(80),
         p_cancel                      INTEGER,
         p_ind                         SMALLINT,
         p_plano                       SMALLINT

  DEFINE p_versao                      CHAR(18)
END GLOBALS

  DEFINE m_cod_nat_oper_ref            LIKE nat_oper_refer.cod_nat_oper_ref

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

  DEFINE m_linha_produto      LIKE ped_info_compl.parametro_texto
  DEFINE m_ies_txt_exped      CHAR(1)

  DEFINE m_msg                CHAR(200) #os 773477
  DEFINE m_consis_trib_pedido CHAR(02)    #773477
  DEFINE ma_tela_consig_ad ARRAY[500] OF RECORD
                                       cod_consig    LIKE transport.cod_transpor,
                                       den_consig    LIKE transport.den_transpor,
                                       cod_tip_frete CHAR (01),
                                       den_tip_frete CHAR (11)
                                       END RECORD
  DEFINE m_informa_consig_ad           CHAR(01),
         p_qtd_consig                  SMALLINT
   DEFINE m_opcao                      CHAR(01),
          m_existe_lista               SMALLINT
          
  DEFINE p_transp_inat                 SMALLINT,
         l_preco_minimo                DECIMAL(17,2)


MAIN

     CALL log0180_conecta_usuario()

  LET p_versao = "VDP4284-10.02.00p"
  WHENEVER ERROR CONTINUE
  CALL log1400_isolation()
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho
  OPTIONS
    HELP FILE    p_help,
     INSERT KEY   control-i,
    DELETE KEY   control-e,
    PREVIOUS KEY control-b,
    NEXT KEY     control-f

  CALL log001_acessa_usuario("VDP","LOGERP")
       RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0
     THEN CALL vdp4284_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION vdp4284_controle()
#--------------------------#
  CALL log006_exibe_teclas("01 02", p_versao)

  CALL vdpy154_cria_w_ped_inf_cpl()
  CALL vdpy154_set_usar_modular_texto()

  INITIALIZE p_pedido_dig_mest.*,
             p_pedido_dig_mestr.*,
             p_pedido_dig_obs.*,
             p_pedido_dig_obsr.*,
             p_pedido_dig_ent.*,
             p_pedido_dig_entr.*,
             p_pedido_dig_item.*,
             p_ped_dig_item_bnf.*,
             m_linha_produto,
             p_vendor_pedido.*,
             p_vendor_pedidor.* TO NULL

  FOR p_aux = 1 to 500
      INITIALIZE t_pedido_dig_item[p_aux].*,
                 t_pedido_dig_grad[p_aux].*,
                 t_array_grade[p_aux].*      TO NULL
  END FOR

  LET p_occur_1 = 0
  LET p_occur_2 = 0
  LET p_erro = FALSE

  WHENEVER ERROR CONTINUE
  SELECT par_ies
    INTO p_ies_item_em_terc_ped
    FROM par_sup_pad
   WHERE cod_empresa = p_cod_empresa
     AND cod_parametro = "ies_item_em_terc_ped"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     INITIALIZE p_ies_item_em_terc_ped TO NULL
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
     INITIALIZE p_ies_item_ped TO NULL
  END IF

  IF p_ies_item_ped IS NULL OR
     p_ies_item_ped = " "   THEN
     LET p_ies_item_ped = "S"
  END IF

  WHENEVER ERROR CONTINUE
  SELECT * INTO p_par_vdp.* FROM par_vdp
   WHERE par_vdp.cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     INITIALIZE p_par_vdp.* TO NULL
  END IF

  {Criar tabelas temporarias para consistencia da configuracao fiscal}
  IF NOT vdpr57_create_temp_tables() THEN
     CALL log0030_mensagem('Erro na cria��o de tabelas tempor�rias para consist�ncia da configura��o fiscal.','stop')
     EXIT PROGRAM
  END IF

   CALL log2250_busca_parametro(p_cod_empresa,'consist_trib_pedido')
     RETURNING m_consis_trib_pedido, p_status

  IF NOT p_status OR
     m_consis_trib_pedido IS NULL OR m_consis_trib_pedido = ' ' THEN
     LET m_consis_trib_pedido = 'S'
  END IF

  CALL log130_procura_caminho("vdp4284") RETURNING p_nom_tela
  OPEN WINDOW w_vdp4284 AT 2,2 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Incluir" "Inclui Pedido "
      HELP  0001
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","vdp4284","IN")
         THEN CALL vdp4284_inclusao_pedido()
          {IF   p_houve_erro = FALSE
          THEN CALL log085_transacao("COMMIT")
               IF   sqlca.sqlcode = 0
               THEN
               ELSE CALL log003_err_sql("INCLUSAO ","PEDIDOS ")
                    CALL log085_transacao("ROLLBACK")
               END IF
          ELSE CALL log085_transacao("ROLLBACK")
          END IF}
      ELSE
         CALL log0030_mensagem("Usuario nao autorizado para fazer inclusao. ",
                               "exclamation")
      END IF
    COMMAND "Modificar" "Modifica Pedido selecionado"
      HELP 0002
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","vdp4284","MO")
         THEN CALL vdp4284_modificacao_pedido()
      ELSE
         CALL log0030_mensagem("Usuario n�o autorizado para fazer modifica��o. "                              ,"exclamation")
      END IF
    COMMAND "Excluir"  "Exclui Pedido selecionado"
      HELP 0003
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","vdp4284","MO")
         THEN CALL vdp4284_exclusao_pedido()
      ELSE
         CALL log0030_mensagem("Usuario n�o autorizado para fazer exclus�o. ",
                               "exclanation")
      END IF
    COMMAND "Consultar"    "Consulta tabela de Pedidos"
      HELP 0004
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","vdp4284","CO")
         THEN CALL vdp4284_query_pedido()
      END IF
    COMMAND "Seguinte"   "Exibe Pedido seguinte "
      HELP 0005
      MESSAGE ""
      CALL vdp4284_paginacao("SEGUINTE")
    COMMAND "Anterior"   "Exibe Pedido Anterior "
      HELP 0006
      MESSAGE ""
      CALL vdp4284_paginacao("ANTERIOR")
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  WHENEVER ERROR CONTINUE
  CLOSE WINDOW w_vdp42843
  CLOSE WINDOW w_vdp42842
  CLOSE WINDOW w_vdp42841
  CLOSE WINDOW w_vdp4284
  WHENEVER ERROR STOP
END FUNCTION
#-------------------------------------------#
 FUNCTION vdp4284_busca_parametro_consig_ad()
#-------------------------------------------#
  CALL log2250_busca_parametro(p_cod_empresa, "ies_informa_consignatario")
     RETURNING m_informa_consig_ad, p_status

  IF p_status = FALSE OR m_informa_consig_ad IS NULL OR m_informa_consig_ad = " " THEN
     LET m_informa_consig_ad = "N"
  END IF

END FUNCTION

#---------------------------------#
 FUNCTION vdp4284_help_consig_ad()
#---------------------------------#
  CASE
    WHEN INFIELD(cod_consig)    CALL SHOWHELP(126)
    WHEN INFIELD(cod_tip_frete) CALL SHOWHELP(120)
  END CASE
END FUNCTION

#------------------------------------#
 FUNCTION vdp4284_mostra_zoom_consig()
#------------------------------------#
  IF g_ies_grafico THEN
--# CALL fgl_dialog_setkeylabel("control-z","Zoom")
  ELSE
    DISPLAY "( Zoom )" AT 3,68
  END IF

 END FUNCTION

#-----------------------------------#
 FUNCTION vdp4284_apaga_zoom_consig()
#-----------------------------------#
  IF g_ies_grafico THEN
--# CALL fgl_dialog_setkeylabel("control-z",NULL)
  ELSE
    DISPLAY "--------" AT 3,68
  END IF
 END FUNCTION

#-------------------------------------------#
FUNCTION vdp4284_abre_tela_consig_adicional()
#-------------------------------------------#
   DEFINE l_ind SMALLINT
   WHENEVER ERROR CONTINUE
   CALL log130_procura_caminho("vdp3135f") RETURNING p_nom_tela
   OPEN WINDOW w_vdp3135f AT 2,02 WITH FORM p_nom_tela
   ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   WHENEVER ERROR STOP
   CURRENT WINDOW IS w_vdp3135f
   DISPLAY p_cod_empresa TO cod_empresa
   IF p_qtd_consig IS NULL THEN
     LET p_qtd_consig = 0
   END IF
   IF m_opcao = "M" THEN
     CALL vdp4284_carrega_dados_consig()
   END IF
   CALL log006_exibe_teclas("01 03", p_versao)
   CURRENT WINDOW IS w_vdp3135f
   CALL set_count(p_qtd_consig)
   LET int_flag = 0
   INPUT ARRAY ma_tela_consig_ad WITHOUT DEFAULTS FROM s_consig_ad.*
     BEFORE ROW
       LET pa_curr  = arr_curr()
       LET sc_curr  = scr_line()
       LET pa_count = arr_count()
       LET p_qtd_consig = pa_count

     BEFORE FIELD cod_consig
       CALL vdp4284_mostra_zoom_consig()

     AFTER FIELD cod_consig
       IF ma_tela_consig_ad[pa_curr].cod_consig IS NOT NULL AND
          ma_tela_consig_ad[pa_curr].cod_consig <> " " THEN
         IF vdp4284_verifica_transportadora(ma_tela_consig_ad[pa_curr].cod_consig) = FALSE THEN
           IF p_transp_inat = 1 THEN
             CALL log0030_mensagem("Consignat�rio cancelado ou suspenso.", "exclamation")
           ELSE
             CALL log0030_mensagem("Consignat�rio n�o cadastrado.", "exclamation")
           END IF
           NEXT FIELD cod_consig
         ELSE
           LET ma_tela_consig_ad[pa_curr].den_consig = vdp4284_busca_den_consig_ad()
           DISPLAY ma_tela_consig_ad[pa_curr].den_consig TO s_consig_ad[sc_curr].den_consig
         END IF
         IF vdp4284_verifica_dupl_array() THEN
           CALL log0030_mensagem("Consignat�rio j� inclu�do para este pedido.", "exclamation")
           NEXT FIELD cod_consig
         END IF
       END IF
       IF ma_tela_consig_ad[pa_curr].cod_consig    IS NULL AND
          ma_tela_consig_ad[pa_curr].cod_tip_frete IS NOT NULL THEN
         CALL log0030_mensagem("Consignat�rio deve ser informado.", "exclamation")
         NEXT FIELD cod_consig
       END IF
       CALL vdp4284_apaga_zoom_consig()

     BEFORE FIELD cod_tip_frete
       CALL vdp4284_mostra_zoom_consig()

     AFTER FIELD cod_tip_frete
       IF ma_tela_consig_ad[pa_curr].cod_tip_frete = 1 OR ma_tela_consig_ad[pa_curr].cod_tip_frete = 2 OR
          ma_tela_consig_ad[pa_curr].cod_tip_frete = 3 OR ma_tela_consig_ad[pa_curr].cod_tip_frete = 4 OR
          ma_tela_consig_ad[pa_curr].cod_tip_frete = 5 THEN
       ELSE
         CALL log0030_mensagem("Tipo de frente n�o cadastrado.", "exclamation")
         NEXT FIELD cod_tip_frete
       END IF
       CASE
         WHEN ma_tela_consig_ad[pa_curr].cod_tip_frete = "1"
              LET ma_tela_consig_ad[pa_curr].den_tip_frete = "CIF Pago"
              DISPLAY ma_tela_consig_ad[pa_curr].den_tip_frete TO s_consig_ad[pa_curr].den_tip_frete
         WHEN ma_tela_consig_ad[pa_curr].cod_tip_frete = "2"
              LET ma_tela_consig_ad[pa_curr].den_tip_frete = "CIF Cobrado"
              DISPLAY ma_tela_consig_ad[pa_curr].den_tip_frete TO s_consig_ad[pa_curr].den_tip_frete
         WHEN ma_tela_consig_ad[pa_curr].cod_tip_frete = "3"
              LET ma_tela_consig_ad[pa_curr].den_tip_frete = "FOB"
              DISPLAY ma_tela_consig_ad[pa_curr].den_tip_frete TO s_consig_ad[pa_curr].den_tip_frete
         WHEN ma_tela_consig_ad[pa_curr].cod_tip_frete = "4"
              LET ma_tela_consig_ad[pa_curr].den_tip_frete = "CIF Inf Pct"
              DISPLAY ma_tela_consig_ad[pa_curr].den_tip_frete TO s_consig_ad[pa_curr].den_tip_frete
         WHEN ma_tela_consig_ad[pa_curr].cod_tip_frete = "5"
              LET ma_tela_consig_ad[pa_curr].den_tip_frete = "CIF Inf Unt"
              DISPLAY ma_tela_consig_ad[pa_curr].den_tip_frete TO s_consig_ad[pa_curr].den_tip_frete
       END CASE
       IF ma_tela_consig_ad[pa_curr].cod_consig    IS NOT NULL AND
          ma_tela_consig_ad[pa_curr].cod_tip_frete IS NULL THEN
         CALL log0030_mensagem("Tipo de frete deve ser informado.", "exclamation")
         NEXT FIELD cod_tip_frete
       END IF
       IF ma_tela_consig_ad[pa_curr].cod_consig    IS NULL AND
          ma_tela_consig_ad[pa_curr].cod_tip_frete IS NOT NULL THEN
         CALL log0030_mensagem("Consignat�rio deve ser informado.", "exclamation")
         NEXT FIELD cod_consig
       END IF
       CALL vdp4284_apaga_zoom_consig()

     AFTER INPUT
       IF int_flag = 0 THEN
         FOR l_ind = 1 TO 500
           IF (ma_tela_consig_ad[l_ind].cod_consig     IS NULL      AND
               ma_tela_consig_ad[l_ind].cod_tip_frete  IS NOT NULL) OR
              (ma_tela_consig_ad[l_ind].cod_consig     IS NOT NULL  AND
               ma_tela_consig_ad[l_ind].cod_tip_frete  IS NULL)     THEN
             IF ma_tela_consig_ad[l_ind].cod_consig    IS NULL AND
                ma_tela_consig_ad[l_ind].cod_tip_frete IS NOT NULL THEN
               CALL log0030_mensagem("Consignat�rio deve ser informado.", "exclamation")
               NEXT FIELD cod_consig
             END IF
             IF ma_tela_consig_ad[l_ind].cod_consig    IS NOT NULL AND
                ma_tela_consig_ad[l_ind].cod_tip_frete IS NULL THEN
               CALL log0030_mensagem("Tipo de frete deve ser informado.", "exclamation")
               NEXT FIELD cod_tip_frete
             END IF
           END IF
         END FOR
       END IF

     ON KEY ('control-w', f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL vdp4284_help_consig_ad()

     ON KEY ('control-z',f4)
        CALL vdp4284_popup_consig_ad()

   END INPUT
   CLOSE WINDOW w_vdp3135f

   IF int_flag = 0 THEN
      RETURN TRUE
   ELSE
     RETURN FALSE
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION vdp4284_popup_consig_ad()
#---------------------------------#
  DEFINE l_cod_consig             LIKE transport.cod_transpor

  CASE
     WHEN INFIELD(cod_consig)
        LET l_cod_consig = vdp3362_popup_cliente("T")
        CALL log006_exibe_teclas("01 02 03 07", p_versao)
        CURRENT WINDOW IS w_vdp3135f

        IF l_cod_consig IS NOT NULL THEN
           LET ma_tela_consig_ad[pa_curr].cod_consig = l_cod_consig
        ELSE
           LET ma_tela_consig_ad[pa_curr].cod_consig = " "
        END IF

        DISPLAY ma_tela_consig_ad[pa_curr].cod_consig TO s_consig_ad[sc_curr].cod_consig

     WHEN infield(cod_tip_frete)
        LET ma_tela_consig_ad[pa_curr].cod_tip_frete = log0830_list_box(08,52,
                              '1 {CIF Pago}, 2 {CIF Cobrado}, 3 {FOB}, 4 {CIF Infor. Pct.}, 5 {CIF Infor. Unit.}, 6 {Item Tot.}')
        DISPLAY ma_tela_consig_ad[pa_curr].cod_tip_frete TO s_consig_ad[pa_curr].cod_tip_frete
  END CASE

END FUNCTION

#------------------------------------#
FUNCTION vdp4284_busca_den_consig_ad()
#------------------------------------#
  DEFINE l_den_consig_ad LIKE transport.den_transpor

  WHENEVER ERROR CONTINUE
  SELECT den_transpor
    INTO l_den_consig_ad
    FROM transport
   WHERE cod_transpor = ma_tela_consig_ad[pa_curr].cod_consig
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    WHENEVER ERROR CONTINUE
    SELECT nom_cliente
      INTO l_den_consig_ad
      FROM clientes
     WHERE cod_cliente = ma_tela_consig_ad[pa_curr].cod_consig
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
      LET l_den_consig_ad = " "
    END IF
  END IF
  RETURN l_den_consig_ad
END FUNCTION

#------------------------------------------------------#
 FUNCTION vdp4284_inclui_ped_info_compl_consig_ad(p_funcao)
#------------------------------------------------------#
   DEFINE p_funcao       CHAR(12)
   DEFINE l_campo     CHAR(40),
          l_ind       INTEGER
   IF p_funcao <> 'INCLUSAO' THEN
     WHENEVER ERROR CONTINUE
     SELECT empresa
       FROM ped_info_compl
      WHERE empresa = p_cod_empresa
        AND pedido  = p_pedido_dig_mest.num_pedido
        AND campo   LIKE 'CONSIGNATARIO%'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 100 THEN
       WHENEVER ERROR CONTINUE
       DELETE
         FROM ped_info_compl
        WHERE empresa = p_cod_empresa
          AND pedido  = p_pedido_dig_mest.num_pedido
          AND campo   LIKE 'CONSIGNATARIO%'
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('DELETE', 'PED_INFO_COMPL')
       END IF
     END IF
   END IF
   FOR l_ind = 1 TO 500
     IF ma_tela_consig_ad[l_ind].cod_consig IS NOT NULL THEN
       LET l_campo = 'CONSIGNATARIO ', l_ind USING "<<&"
       WHENEVER ERROR CONTINUE
       INSERT INTO ped_info_compl
         (empresa, pedido, campo, par_existencia, parametro_texto, parametro_val, parametro_qtd,
          parametro_dat)
       VALUES
         (p_cod_empresa, p_pedido_dig_mest.num_pedido, l_campo, NULL,
          ma_tela_consig_ad[l_ind].cod_consig, NULL, ma_tela_consig_ad[l_ind].cod_tip_frete, NULL)
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
         IF sqlca.sqlcode <> -268 THEN
            CALL log003_err_sql('INSERT', 'PED_INFO_COMPL')
         END IF
       END IF
     ELSE
       EXIT FOR
     END IF
  END FOR
END FUNCTION

#-------------------------------------#
FUNCTION vdp4284_carrega_dados_consig()
#-------------------------------------#
  DEFINE lr_consig_ad       RECORD
                            parametro_texto LIKE ped_info_compl.parametro_texto,
                            parametro_qtd   LIKE ped_info_compl.parametro_qtd
                            END RECORD
   WHENEVER ERROR CONTINUE
   DECLARE cq_consig_ad CURSOR FOR
    SELECT parametro_texto, parametro_qtd
      FROM ped_info_compl
     WHERE empresa = p_cod_empresa
       AND pedido  = p_pedido_dig_mest.num_pedido
       AND campo   LIKE "CONSIGNATARIO%"
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
     LET p_qtd_consig = 1
     WHENEVER ERROR CONTINUE
     FOREACH cq_consig_ad INTO lr_consig_ad.parametro_texto, lr_consig_ad.parametro_qtd
     WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
         EXIT FOREACH
       END IF
       LET ma_tela_consig_ad[p_qtd_consig].cod_consig = lr_consig_ad.parametro_texto
       LET ma_tela_consig_ad[p_qtd_consig].cod_tip_frete = lr_consig_ad.parametro_qtd
       WHENEVER ERROR CONTINUE
       SELECT den_transpor
         INTO ma_tela_consig_ad[p_qtd_consig].den_consig
         FROM transport
        WHERE cod_transpor = lr_consig_ad.parametro_texto
       WHENEVER ERROR STOP
       LET p_qtd_consig = p_qtd_consig + 1
       CASE
         WHEN ma_tela_consig_ad[p_qtd_consig].cod_tip_frete = "1"
              LET ma_tela_consig_ad[p_qtd_consig].den_tip_frete = "CIF Pago"
         WHEN ma_tela_consig_ad[p_qtd_consig].cod_tip_frete = "2"
              LET ma_tela_consig_ad[p_qtd_consig].den_tip_frete = "CIF Cobrado"
         WHEN ma_tela_consig_ad[p_qtd_consig].cod_tip_frete = "3"
              LET ma_tela_consig_ad[p_qtd_consig].den_tip_frete = "FOB"
         WHEN ma_tela_consig_ad[p_qtd_consig].cod_tip_frete = "4"
              LET ma_tela_consig_ad[p_qtd_consig].den_tip_frete = "CIF Inf Pct"
         WHEN ma_tela_consig_ad[p_qtd_consig].cod_tip_frete = "5"
              LET ma_tela_consig_ad[p_qtd_consig].den_tip_frete = "CIF Inf Unt"
       END CASE
     END FOREACH
   END IF
END FUNCTION

#------------------------------------#
FUNCTION vdp4284_verifica_dupl_array()
#------------------------------------#
  DEFINE l_ind SMALLINT
  FOR l_ind = 1 TO 500
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

#---------------------------------------------------------#
 FUNCTION vdp4284_verifica_transportadora(p_cod_transpor)
#---------------------------------------------------------#
 DEFINE p_cod_transpor    LIKE pedido_dig_mest.cod_transpor
 DEFINE lr_clientes       RECORD LIKE clientes.*

 LET p_transp_inat = 0
 WHENEVER ERROR CONTINUE
 SELECT cod_transpor
   FROM transport
  WHERE cod_transpor  = p_cod_transpor
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = NOTFOUND THEN
   WHENEVER ERROR CONTINUE
   SELECT cod_cliente, cod_class, nom_cliente, end_cliente, den_bairro,
          cod_cidade, cod_cep, num_caixa_postal, num_telefone, num_fax,
          num_telex, num_suframa, cod_tip_cli, den_marca, nom_reduzido,
          den_frete_posto, num_cgc_cpf, ins_estadual, cod_portador,
          ies_tip_portador, cod_cliente_matriz, cod_consig, ies_cli_forn,
          ies_zona_franca, ies_situacao, cod_rota, cod_praca, dat_cadastro,
          dat_atualiz, nom_contato, dat_fundacao, cod_local
     INTO lr_clientes.cod_cliente, lr_clientes.cod_class, lr_clientes.nom_cliente,
          lr_clientes.end_cliente, lr_clientes.den_bairro, lr_clientes.cod_cidade,
          lr_clientes.cod_cep, lr_clientes.num_caixa_postal, lr_clientes.num_telefone,
          lr_clientes.num_fax, lr_clientes.num_telex, lr_clientes.num_suframa,
          lr_clientes.cod_tip_cli, lr_clientes.den_marca, lr_clientes.nom_reduzido,
          lr_clientes.den_frete_posto, lr_clientes.num_cgc_cpf, lr_clientes.ins_estadual,
          lr_clientes.cod_portador, lr_clientes.ies_tip_portador, lr_clientes.cod_cliente_matriz,
          lr_clientes.cod_consig, lr_clientes.ies_cli_forn, lr_clientes.ies_zona_franca,
          lr_clientes.ies_situacao, lr_clientes.cod_rota, lr_clientes.cod_praca, lr_clientes.dat_cadastro,
          lr_clientes.dat_atualiz, lr_clientes.nom_contato, lr_clientes.dat_fundacao, lr_clientes.cod_local
     FROM clientes
    WHERE cod_cliente  = p_cod_transpor
    WHENEVER ERROR STOP
    IF lr_clientes.ies_situacao <> "A" THEN
      LET p_transp_inat = 1
      RETURN FALSE
    ELSE
      IF sqlca.sqlcode = 0 THEN
        RETURN TRUE
      ELSE
        RETURN FALSE
      END IF
    END IF
 ELSE
    RETURN TRUE
 END IF

 END FUNCTION

#----------------------------------------#
 FUNCTION vdp4284_inclusao_pedido()
#----------------------------------------#
 LET p_houve_erro = FALSE

  LET p_pedido_dig_mestr.* = p_pedido_dig_mest.*
  LET p_pedido_dig_obsr.*  = p_pedido_dig_obs.*
  LET p_pedido_dig_entr.*  = p_pedido_dig_ent.*
  LET p_vendor_pedidor.*   = p_vendor_pedido.*
  LET m_ies_txt_exped = 'N'

  INITIALIZE p_pedido_dig_mest.*,
             p_pedido_dig_obs.*,
             p_pedido_dig_ent.*,
             p_pedido_dig_item.*,
             p_pedido_dig_grad.*,
             p_ped_itens_grade.*,
             p_ped_dig_item_bnf.*,
             p_vendor_pedido.*,
             m_linha_produto,
             t_pedido_dig_item,
             ma_tela_consig_ad,
             t_ped_dig_bnf          TO NULL

  CLEAR FORM
  CALL vdp4284_move_dados()

   LET p_erro   = TRUE  {?}
   LET p_tela   = 1

   WHILE TRUE
      CASE
         WHEN p_tela = 1
              IF vdp4284_entrada_dados_mestr("INCLUSAO") THEN
                 LET p_tela = 2
              ELSE
                 LET p_status = 1
                 EXIT WHILE
              END IF
      WHEN p_tela = 2
        CALL vdp4284_busca_parametro_consig_ad()
        IF m_informa_consig_ad = 'S' THEN
           IF vdp4284_abre_tela_consig_adicional() THEN
             LET p_tela = 4 #3
           ELSE
             LET p_tela = 1
           END IF
        ELSE
           LET p_tela = 4 #3
        END IF

         WHEN p_tela = 3
              IF vdp4284_entrada_dados_intermediario() THEN
                 LET p_tela = 4
              ELSE
                 IF m_informa_consig_ad = "S" THEN
                   LET p_tela = 2
                 ELSE
                   LET p_tela = 1
                 END IF
              END IF

         WHEN p_tela = 4
              IF vdp4284_entrada_dados_ent_obs("INCLUSAO") THEN
                 LET p_tela = 5
              ELSE
                 LET p_tela = 2 #3
              END IF

         WHEN p_tela = 5
              IF vdp4284_entrada_dados_item("INCLUSAO") THEN
                 LET p_tela = 7
              ELSE
                 LET p_tela = 4
              END IF

         WHEN p_tela = 6
              IF vdp4284_entrada_dados_item_bnf("INCLUSAO") THEN
                 LET p_tela = 7
              ELSE
                 LET p_tela = 5
              END IF

         WHEN p_tela = 7
              IF vdp4284_total("INCLUSAO") THEN
                 LET p_status = 0
                 EXIT WHILE
              ELSE
                 LET p_tela = 5
              END IF
      END CASE
   END WHILE

   IF p_status = 0 THEN
     CALL log085_transacao("BEGIN")
     IF vdp4284_efetiva_inclusao("INCLUSAO") THEN
        CALL log006_exibe_teclas("01 02", p_versao)
        CURRENT WINDOW IS w_vdp4284
        CALL vdp4284_exibe_dados()

        CALL log085_transacao("COMMIT")
        IF sqlca.sqlcode = 0 THEN
           MESSAGE " Inclusao efetuada com sucesso " ATTRIBUTE(REVERSE)
           LET p_audit_vdp.texto = "INCLUSAO - PEDIDOS NO LOTE  "
           CALL vdp876_monta_audit_vdp(p_cod_empresa,
                                             p_pedido_dig_mest.num_pedido,
                                            "M",
                                            "I",
                                            p_audit_vdp.texto,
                                            "vdp4284",
                                            TODAY,
                                            TIME,
                                            p_user)
        ELSE
           CALL log003_err_sql("INCLUSAO  ","PEDIDO  ")
           CALL log085_transacao("ROLLBACK")
        END IF
     ELSE
        CALL log085_transacao("ROLLBACK")
     END IF
  ELSE
     LET p_pedido_dig_mest.* = p_pedido_dig_mestr.*
     LET p_pedido_dig_obs.*  = p_pedido_dig_obsr.*
     LET p_pedido_dig_ent.*  = p_pedido_dig_entr.*
     LET p_pedido_dig_mest.* = p_pedido_dig_mestr.*
     LET p_vendor_pedido.* = p_vendor_pedidor.*
     CALL vdp4284_exibe_dados()
     CALL log006_exibe_teclas("01 02", p_versao)
     CURRENT WINDOW IS w_vdp4284
     CALL log0030_mensagem(" Inclusao Cancelada ","excl")
  END IF
END FUNCTION

#--------------------------------------------#
 FUNCTION vdp4284_entrada_dados_mestr(p_funcao)
#--------------------------------------------#
  DEFINE p_funcao                CHAR(12),
         p_ies_incl_txt          CHAR(01),
         l_den_transpor          LIKE transport.den_transpor,
         l_den_consig            LIKE transport.den_transpor,
         l_ies_list_pre_obr      LIKE par_vdp_pad.par_ies

  LET INT_FLAG = 0
  CALL log006_exibe_teclas("01 02 03 07", p_versao)
  CURRENT WINDOW IS w_vdp4284
  IF p_funcao = "MODIFICACAO"
  THEN
  ELSE
     LET p_pedido_dig_mest.ies_comissao = "N"
  END IF
  LET p_ies_incl_txt  = 'N'
  DISPLAY p_cod_empresa TO cod_empresa

  INPUT p_pedido_dig_mest.num_pedido,
        p_pedido_dig_mest.cod_nat_oper,
        p_pedido_dig_mest.dat_emis_repres,
        p_pedido_dig_mest.dat_prazo_entrega,
        p_pedido_dig_mest.cod_tip_carteira,
        m_linha_produto,
        p_pedido_dig_mest.cod_cliente,
        p_pedido_dig_mest.num_pedido_cli,
        p_pedido_dig_mest.num_pedido_repres,
        p_vendor_pedido.pct_taxa_negoc,
        p_pedido_dig_mest.ies_comissao,
        p_pedido_dig_mest.cod_repres,
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
        p_pedido_dig_mest.ies_frete,
        p_pedido_dig_mest.pct_frete,
        p_pedido_dig_mest.cod_tip_venda,
        p_pedido_dig_mest.ies_tip_entrega,
        p_pedido_dig_mest.ies_sit_pedido,
        p_pedido_dig_mest.cod_transpor,
        p_pedido_dig_mest.cod_consig,
        p_pedido_dig_mest.ies_finalidade,
        p_pedido_dig_mest.cod_moeda ,
        p_pedido_dig_mest.ies_embal_padrao,
        p_ies_incl_txt,
        m_ies_txt_exped WITHOUT DEFAULTS
        FROM num_pedido,
             cod_nat_oper,
             dat_emis_repres,
             dat_prazo_entrega,
             cod_tip_carteira,
             parametro_texto,
             cod_cliente,
             num_pedido_cli,
             num_pedido_repres,
             pct_taxa_negoc,
             ies_comissao,
             cod_repres,
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
             ies_frete,
             pct_frete,
             cod_tip_venda,
             ies_tip_entrega,
             ies_sit_pedido,
             cod_transpor,
             cod_consig,
             ies_finalidade,
             cod_moeda,
             ies_embal_padrao,
             ies_incl_txt,
             ies_txt_exped

    BEFORE INPUT

      LET p_pedido_dig_mest.ies_aceite_finan = "N"
      LET p_pedido_dig_mest.ies_aceite_comer = "N"

    BEFORE FIELD num_pedido
      IF p_funcao = "MODIFICACAO"  THEN
         NEXT FIELD cod_nat_oper
      END IF


      IF p_par_vdp.num_prx_pedido <> 0 THEN
         LET p_pedido_dig_mest.num_pedido = vdp4284_busca_num_pedido()
         DISPLAY p_pedido_dig_mest.num_pedido TO num_pedido
         NEXT FIELD cod_nat_oper
      END IF



    AFTER  FIELD num_pedido
      IF p_funcao = "INCLUSAO"  THEN
         IF vdp4284_verifica_pedido()
            THEN CALL log0030_mensagem( " PEDIDO j� digitado ","excl")
            NEXT FIELD num_pedido
         END IF
      END IF

    BEFORE FIELD cod_nat_oper
      CALL vdp4284_mostra_zoom()
    AFTER  FIELD cod_nat_oper
      CALL vdp4284_apaga_zoom()
              IF vdp4284_verifica_natureza_operacao()
              THEN
              END IF

    AFTER  FIELD dat_prazo_entrega
      IF p_pedido_dig_mest.dat_prazo_entrega < TODAY
         THEN CALL log0030_mensagem( " DATA ENTREGA menor que a data corrente","excl")
              NEXT FIELD dat_prazo_entrega
      END IF

    BEFORE FIELD cod_tip_carteira
      CALL vdp4284_mostra_zoom()

    AFTER FIELD cod_tip_carteira
      IF vdp4284_verifica_carteira() = FALSE THEN
         CALL log0030_mensagem( "Carteira n�o cadastrada. ","excl")
         NEXT FIELD cod_tip_carteira
      END IF
      CALL vdp4284_apaga_zoom()

    AFTER  FIELD parametro_texto
           IF  m_linha_produto IS NULL OR
               m_linha_produto = ' '   THEN
               CALL log0030_mensagem( " Obrigat�rio informar linha de produto ","excl")
               NEXT FIELD parametro_texto
           END IF


    BEFORE FIELD cod_cliente
      CALL vdp4284_mostra_zoom()
    AFTER  FIELD cod_cliente
      CALL vdp4284_apaga_zoom()
              IF vdp4284_verifica_cliente() = TRUE
              THEN
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

    AFTER FIELD pct_taxa_negoc
         IF p_vendor_pedido.pct_taxa_negoc IS NULL OR
            p_vendor_pedido.pct_taxa_negoc = " "   OR
            p_vendor_pedido.pct_taxa_negoc < 0     THEN
            LET p_vendor_pedido.pct_taxa_negoc = 0
            DISPLAY p_vendor_pedido.pct_taxa_negoc TO pct_taxa_negoc
         END IF

    AFTER FIELD ies_comissao
      IF p_pedido_dig_mest.ies_comissao = "N"
      THEN LET p_pula_campo = TRUE
           LET p_pedido_dig_mest.pct_comissao = 0
           DISPLAY BY NAME p_pedido_dig_mest.pct_comissao
      ELSE LET p_pula_campo = FALSE
      END IF

       BEFORE FIELD cod_repres
              CALL vdp4284_mostra_zoom()

       AFTER  FIELD cod_repres
              IF vdp4284_verifica_repres(p_pedido_dig_mest.cod_repres,1) = FALSE
              THEN
                 NEXT FIELD cod_repres
              ELSE
{ O.S.50780-Ju   IF vdp4284_verifica_repres_canal() = FALSE THEN
                    ERROR "Representante nao relacionado com o cliente no ",
                          "canal de vendas."
                    NEXT FIELD cod_repres
                 END IF
}             END IF
              CALL vdp4284_apaga_zoom()

       BEFORE FIELD pct_comissao
              IF p_pedido_dig_mest.ies_comissao = "N" AND
                 FGL_LASTKEY() <> FGL_KEYVAL("UP") AND
                 FGL_LASTKEY() <> FGL_KEYVAL("LEFT") THEN
                 NEXT FIELD cod_repres_adic
              END IF

              {IF p_pedido_dig_mest.ies_comissao = "N" AND
                 (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                  FGL_LASTKEY() = FGL_KEYVAL("LEFT"))  THEN
                 NEXT FIELD ies_comissao
              END IF}

       BEFORE FIELD cod_repres_adic
              CALL vdp4284_mostra_zoom()

       AFTER  FIELD cod_repres_adic
              IF   vdp4284_verifica_repres(p_pedido_dig_mest.cod_repres_adic,2) = FALSE
              THEN NEXT FIELD cod_repres_adic
              END IF
              CALL vdp4284_apaga_zoom()

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
              CALL vdp4284_mostra_zoom()

       AFTER  FIELD cod_repres_3
              IF   vdp4284_verifica_repres(m_cod_repres_3,3) = FALSE
              THEN NEXT FIELD cod_repres_3
              END IF
              CALL vdp4284_apaga_zoom()

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

     {BEFORE FIELD cod_repres
       DISPLAY "( Zoom )" AT 3,68
--#    CALL fgl_dialog_setkeylabel('control-z','Zoom')

     AFTER  FIELD cod_repres
         DISPLAY "--------" AT 3,68
--#      CALL fgl_dialog_setkeylabel('control-z', NULL)
{        IF vdp4284_verifica_repres_canal() = FALSE THEN
           NEXT FIELD cod_repres
         END IF}

     {BEFORE FIELD pct_comissao
       CASE WHEN p_pula_campo AND p_pedido_dig_mest.ies_comissao = "N"
             NEXT FIELD cod_repres
           WHEN p_pedido_dig_mest.ies_comissao = "N"
             NEXT FIELD ies_comissao
       END CASE

     AFTER FIELD pct_comissao
      IF p_pedido_dig_mest.ies_comissao = "N"
         AND p_pedido_dig_mest.pct_comissao > 0
      THEN ERROR " Percentual de comissao invalido pelo Tipo."
           NEXT FIELD pct_comissao
      END IF

    BEFORE FIELD cod_repres_adic
      DISPLAY "( Zoom )" AT 3,68
--#   CALL fgl_dialog_setkeylabel('control-z','Zoom')

    AFTER  FIELD cod_repres_adic
      DISPLAY "--------" AT 3,68
--#   CALL fgl_dialog_setkeylabel('control-z', NULL)

     BEFORE FIELD pct_comissao_2
       CASE WHEN p_pula_campo AND p_pedido_dig_mest.ies_comissao = "N"
             NEXT FIELD cod_repres_3
           WHEN p_pedido_dig_mest.ies_comissao = "N"
             NEXT FIELD ies_comissao
       END CASE

     AFTER FIELD pct_comissao_2
       IF p_pedido_dig_mest.ies_comissao = "N"
         AND p_pedido_dig_mest.pct_comissao > 0
       THEN ERROR " Percentual de comissao invalido pelo Tipo."
           NEXT FIELD pct_comissao_2
       END IF

 BEFORE FIELD cod_repres_3
      DISPLAY "( Zoom )" AT 3,68
--#   CALL fgl_dialog_setkeylabel('control-z','Zoom')

    AFTER  FIELD cod_repres_3
      DISPLAY "--------" AT 3,68
--#   CALL fgl_dialog_setkeylabel('control-z', NULL)

     BEFORE FIELD pct_comissao_3
       CASE WHEN p_pula_campo AND p_pedido_dig_mest.ies_comissao = "N"
             NEXT FIELD cod_repres_3
           WHEN p_pedido_dig_mest.ies_comissao = "N"
             NEXT FIELD ies_comissao
       END CASE

     AFTER FIELD pct_comissao_3
       IF p_pedido_dig_mest.ies_comissao = "N"
         AND p_pedido_dig_mest.pct_comissao > 0
       THEN ERROR " Percentual de comissao invalido pelo Tipo."
           NEXT FIELD pct_comissao_3
       END IF
      }
     BEFORE FIELD num_list_preco
      CALL vdp4284_mostra_zoom()

      WHENEVER ERROR CONTINUE
      SELECT par_cliente_txt[14,17]
        INTO p_pedido_dig_mest.num_list_preco
        FROM par_clientes
       WHERE cod_cliente = p_pedido_dig_mest.cod_cliente
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         LET p_pedido_dig_mest.num_list_preco = " "
      END IF

    AFTER  FIELD num_list_preco
      IF   p_pedido_dig_mest.num_list_preco IS NULL OR
           p_pedido_dig_mest.num_list_preco = 0  THEN
           WHENEVER ERROR CONTINUE
           SELECT par_ies
             INTO l_ies_list_pre_obr
             FROM par_vdp_pad
            WHERE cod_empresa   = p_cod_empresa
              AND cod_parametro = "ies_list_pre_obr"
           WHENEVER ERROR STOP
           IF   sqlca.sqlcode = 0
           THEN IF   l_ies_list_pre_obr = "S"
                THEN CALL log0030_mensagem( "Obrigat�rio informar Lista de Pre�o","excl")
                     NEXT FIELD num_list_preco
                END IF
           END IF
      END IF

      CALL vdp4284_apaga_zoom()

    BEFORE FIELD ies_preco
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD ies_preco
      CALL vdp4284_apaga_zoom()

    BEFORE FIELD pct_desc_adic
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD pct_desc_adic
      CALL vdp4284_apaga_zoom()

    BEFORE FIELD cod_cnd_pgto
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD cod_cnd_pgto
      CALL vdp4284_apaga_zoom()

    BEFORE FIELD ies_frete
      CALL vdp4284_mostra_zoom()
    AFTER  FIELD ies_frete
      IF p_pedido_dig_mest.ies_frete != 4
      THEN LET p_pedido_dig_mest.pct_frete = 0
           DISPLAY BY NAME p_pedido_dig_mest.pct_frete
           NEXT FIELD pct_frete
      END IF
      CALL vdp4284_apaga_zoom()

    AFTER  FIELD pct_frete
      IF   p_pedido_dig_mest.pct_frete    IS NULL OR
           p_pedido_dig_mest.pct_frete < 0
      THEN CALL log0030_mensagem( " Percentual de frete inv�lido.","excl")
           NEXT  FIELD pct_frete
      END IF

    BEFORE FIELD pct_frete
      IF p_pedido_dig_mest.ies_frete <> "4" AND
         fgl_lastkey() <> fgl_keyval("UP") AND
         fgl_lastkey() <> fgl_keyval("LEFT") THEN
         NEXT FIELD cod_tip_venda
      END IF

      IF p_pedido_dig_mest.ies_frete <> "4" AND
         (fgl_lastkey() = fgl_keyval("UP") OR
          fgl_lastkey() = fgl_keyval("LEFT"))  THEN
         NEXT FIELD ies_frete
      END IF

    BEFORE FIELD cod_tip_venda
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD cod_tip_venda
      CALL vdp4284_apaga_zoom()

    BEFORE FIELD ies_tip_entrega
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD ies_tip_entrega
      CALL vdp4284_apaga_zoom()

    BEFORE FIELD ies_sit_pedido
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD ies_sit_pedido
      CALL vdp4284_apaga_zoom()

    BEFORE FIELD cod_transpor
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD cod_transpor
      CALL vdp4284_apaga_zoom()
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
      DISPLAY l_den_transpor TO den_transpor

    BEFORE FIELD cod_consig
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD cod_consig
      CALL vdp4284_apaga_zoom()
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
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
            LET l_den_consig = " "
         END IF
      END IF
      DISPLAY l_den_consig TO den_consig

     BEFORE FIELD ies_finalidade
    	CALL vdp4284_mostra_zoom()
    	LET p_pula_campo = FALSE
     AFTER  FIELD ies_finalidade
        IF vdp4284_verifica_finalidade() = FALSE
          THEN NEXT FIELD ies_finalidade
         END IF
         CALL vdp4284_apaga_zoom()
#--------------------------------------------------
#      CALL vdp4284_mostra_zoom()
#      LET p_pula_campo = FALSE
#     AFTER FIELD ies_finalidade
#      CALL vdp4284_apaga_zoom()

   BEFORE FIELD cod_moeda
      CALL vdp4284_mostra_zoom()

   AFTER  FIELD cod_moeda
      CALL vdp4284_apaga_zoom()

   BEFORE FIELD ies_embal_padrao
      CALL vdp4284_mostra_zoom()

   AFTER  FIELD ies_embal_padrao
      CALL vdp4284_apaga_zoom()

   BEFORE FIELD ies_incl_txt
      LET p_ies_incl_txt = "N"
      DISPLAY p_ies_incl_txt TO ies_incl_txt
   AFTER FIELD ies_incl_txt
      IF p_ies_incl_txt IS NOT NULL THEN
         IF p_ies_incl_txt = "S" THEN
            IF vdp243_digita_texto(p_pedido_dig_mest.num_pedido, "0") = FALSE
               THEN LET p_ies_incl_txt = "N"
            END IF
            CALL log006_exibe_teclas("01 02 07", p_versao)
            CURRENT WINDOW IS w_vdp4284
         END IF
      END IF


   AFTER INPUT
         IF m_ies_txt_exped IS NULL OR
           (m_ies_txt_exped <> 'S' AND
            m_ies_txt_exped <> 'N') THEN
            NEXT FIELD ies_txt_exped
         END IF

      IF INT_FLAG = 0 THEN
         IF m_ies_txt_exped <> 'N' THEN
#            IF NOT vdpy154_digita_texto_exped(p_pedido_dig_mest.num_pedido,'CONSULTA') THEN
            IF NOT vdpy154_digita_texto_exped(p_pedido_dig_mest.num_pedido,p_funcao) THEN
               NEXT FIELD ies_txt_exped
            END IF
         END IF
      END IF

  ON KEY (control-w, f1)
     #lds IF NOT LOG_logix_versao5() THEN
     #lds CONTINUE INPUT
     #lds END IF
           CALL vdp4284_help(1)
  ON KEY (control-z, f4)
           CALL vdp4284_popup(1)
  END  INPUT

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------------------------------#
 FUNCTION vdp4284_verifica_repres(p_cod_repres,l_tipo)
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
          ERROR 'Representante ja cadastrado para o pedido. '
          RETURN FALSE
       END IF
    WHEN 2
       IF p_cod_repres = p_pedido_dig_mest.cod_repres OR
          p_cod_repres = m_cod_repres_3 THEN
          ERROR 'Representante ja cadastrado para o pedido. '
          RETURN FALSE
       END IF
    WHEN 3
       IF p_cod_repres = p_pedido_dig_mest.cod_repres OR
          p_cod_repres = p_pedido_dig_mest.cod_repres_adic THEN
          ERROR 'Representante ja cadastrado para o pedido. '
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
       CALL log0030_mensagem( "Representante n�o cadastrado ","excl")
    ELSE
       CALL log0030_mensagem( "Representante Adicional n�o cadastrado ","excl")
    END IF
    RETURN FALSE
 END IF
 END FUNCTION

#--------------------------------------#
FUNCTION vdp4284_verifica_repres_canal()
#--------------------------------------#
   DEFINE p_cli_canal_venda    RECORD LIKE cli_canal_venda.*,
          sql_stmt             CHAR(200),
          p_cod_campo          CHAR(50)

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_cli_canal_venda.*
     FROM cli_canal_venda
    WHERE cod_cliente      = p_pedido_dig_mest.cod_cliente
      AND cod_tip_carteira = p_pedido_dig_mest.cod_tip_carteira
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 100 THEN
      CALL log0030_mensagem( " Tipo de carteira n�o existe no canal de venda do cliente","excl")
      RETURN FALSE
   END IF

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
   PREPARE var_query_1 FROM sql_stmt
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("PREPARE","VAR_QUERY_1")
      RETURN
   END IF

   WHENEVER ERROR CONTINUE
   DECLARE cq_canal_venda CURSOR FOR var_query_1
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_CANAL_VENDA")
      RETURN
   END IF

   WHENEVER ERROR CONTINUE
   OPEN cq_canal_venda
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("OPEN","CQ_CANAL_VENDA")
      RETURN
   END IF

   WHENEVER ERROR CONTINUE
   FETCH cq_canal_venda
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 100 THEN
      CALL log0030_mensagem( "Representante n�o relacionado com o cliente no canal de vendas.","excl")
      RETURN FALSE
   END IF
   RETURN TRUE

END FUNCTION


#--------------------------------------------#
FUNCTION vdp4284_entrada_dados_intermediario()
#--------------------------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CALL log130_procura_caminho("vdp42848") RETURNING p_nom_tela
   OPEN WINDOW w_vdp42848 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CURRENT WINDOW IS w_vdp42848
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
      CALL vdp4284_mostra_zoom()
      AFTER  FIELD cod_cliente
         IF p_ped_item_nat.cod_cliente IS NOT NULL THEN
            IF vdp4284_verifica_cliente_inter() THEN
            ELSE
               NEXT FIELD cod_cliente
            END IF
         ELSE
            NEXT FIELD cod_local_estoq
         END IF
      CALL vdp4284_apaga_zoom()

      BEFORE FIELD cod_nat_oper
      CALL vdp4284_mostra_zoom()
      AFTER  FIELD cod_nat_oper
         IF vdp4284_verifica_nat_oper_inter() THEN
         ELSE
            CALL log0030_mensagem( "Opera��o n�o cadastrada ou emite duplicata","excl")
            NEXT FIELD cod_nat_oper
         END IF
      CALL vdp4284_apaga_zoom()

      BEFORE FIELD cod_cnd_pgto
      CALL vdp4284_mostra_zoom()
      AFTER  FIELD cod_cnd_pgto
         IF vdp4284_verifica_cnd_pgto_inter() THEN
         ELSE
            CALL log0030_mensagem( "Condi��o de Pgto n�o cadastrada ou emite duplicata","excl")
            NEXT FIELD cod_cnd_pgto
         END IF
      CALL vdp4284_apaga_zoom()

      BEFORE FIELD cod_local_estoq
      CALL vdp4284_mostra_zoom()
      AFTER  FIELD cod_local_estoq
         IF p_pedido_dig_mest.cod_local_estoq IS NULL THEN
         ELSE
            IF vdp4284_verifica_local_estoq() THEN
            ELSE
               CALL log0030_mensagem( "Local de Estoque n�o cadastrado","excl")
               NEXT FIELD cod_local_estoq
            END IF
         END IF
      CALL vdp4284_apaga_zoom()

      ON KEY (control-w, f1)
         #lds IF NOT LOG_logix_versao5() THEN
         #lds CONTINUE INPUT
         #lds END IF
         CALL vdp4284_help(2)

      ON KEY (control-z, f4)
         CALL vdp4284_popup(2)
   END INPUT

   CLOSE WINDOW w_vdp42848
   CURRENT WINDOW IS w_vdp4284

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION


#---------------------------------------#
FUNCTION vdp4284_verifica_cliente_inter()
#---------------------------------------#
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

   IF sqlca.sqlcode = NOTFOUND THEN
      CALL log0030_mensagem( " Cliente n�o cadastrado ","excl")
      RETURN FALSE
   END IF

   DISPLAY p_nom_cliente   TO nom_cliente

   IF p_ies_situacao = "A" THEN
      RETURN TRUE
   ELSE
      CALL log0030_mensagem( "Cliente cancelado ou suspenso","excl")
      RETURN FALSE
   END IF
END FUNCTION


#------------------------------------------#
 FUNCTION vdp4284_verifica_nat_oper_inter()
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
 FUNCTION vdp4284_verifica_cnd_pgto_inter()
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
FUNCTION vdp4284_verifica_local_estoq()
#-------------------------------------#
  WHENEVER ERROR CONTINUE
   SELECT *
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


#----------------------------------------------#
 FUNCTION vdp4284_entrada_dados_ent_obs(p_funcao)
#----------------------------------------------#
  DEFINE p_funcao                CHAR(12)

  CALL log006_exibe_teclas("01 02 07", p_versao)
  WHENEVER ERROR CONTINUE
  CALL log130_procura_caminho("vdp42841") RETURNING p_nom_tela
  OPEN WINDOW w_vdp42841 AT 2,2 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  WHENEVER ERROR STOP
  CURRENT WINDOW IS w_vdp42841

  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY p_pedido_dig_mest.num_pedido  TO num_pedido

 { IF p_funcao = "INCLUSAO"
  THEN LET p_pedido_dig_ent.num_sequencia = 0
  END IF }
  LET p_pedido_dig_ent.num_pedido  =  p_pedido_dig_mest.num_pedido
  LET p_pedido_dig_obs.num_pedido  =  p_pedido_dig_mest.num_pedido

  INPUT p_pedido_dig_ent.num_sequencia,
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
      CALL vdp4284_apaga_zoom()
    AFTER FIELD num_sequencia
          IF p_pedido_dig_ent.num_sequencia IS NULL OR
             p_pedido_dig_ent.num_sequencia = " "
          THEN #NEXT FIELD tex_observ_1
          ELSE IF   vdp4284_verifica_endeco_entrega()
               THEN NEXT FIELD tex_observ_1
               ELSE CALL log0030_mensagem( " Endere�o de entrega n�o cadastrado","excl")
                    NEXT FIELD num_sequencia
               END IF
          END IF

    AFTER FIELD end_entrega
          IF p_pedido_dig_ent.end_entrega IS NULL
             THEN NEXT FIELD tex_observ_1
          END IF
    BEFORE FIELD cod_cidade
      CALL vdp4284_mostra_zoom()
    AFTER  FIELD cod_cidade
      CALL vdp4284_apaga_zoom()
    AFTER FIELD cod_cep
          IF p_pedido_dig_ent.cod_cep = "     -   " OR
             p_pedido_dig_ent.cod_cep = "00000-000"
             THEN INITIALIZE p_pedido_dig_ent.cod_cep TO NULL
          END IF
 {   BEFORE FIELD ins_estadual
        IF p_pedido_dig_ent.num_sequencia > 0
        THEN NEXT FIELD num_sequencia
        END IF
 }
    AFTER FIELD num_cgc
          IF p_pedido_dig_ent.num_cgc = "   .   .   /    -  " OR
             p_pedido_dig_ent.num_cgc = "000.000.000/0000-00"
             THEN INITIALIZE p_pedido_dig_ent.num_cgc TO NULL
             ELSE IF log019_verifica_cgc_cpf(p_pedido_dig_ent.num_cgc)
                     THEN
                     ELSE CALL log0030_mensagem( " C.G.C OU C.P.F inv�lido","excl")
                          NEXT FIELD num_cgc
                  END IF
          END IF
    AFTER FIELD tex_observ_1
          IF p_pedido_dig_obs.tex_observ_1 IS NULL
             THEN EXIT INPUT
          END IF
    ON KEY (control-w, f1)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
           CALL vdp4284_help(1)
    ON KEY (control-z, f4)
           CALL vdp4284_popup(1)
  END  INPUT

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------------------#
 FUNCTION vdp4284_verifica_endeco_entrega()
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
     AND cli_end_ent.num_sequencia = p_pedido_dig_ent.num_sequencia
  WHENEVER ERROR STOP
  IF   sqlca.sqlcode = 0
  THEN LET p_pedido_dig_ent.num_sequencia = p_pedido_dig_ent.num_sequencia
       DISPLAY BY NAME p_pedido_dig_ent.*
       RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#-------------------------------------------#
 FUNCTION vdp4284_entrada_dados_item(p_funcao)
#-------------------------------------------#
  DEFINE p_funcao                CHAR(12),
         p_campo                 SMALLINT,
         p_qtd_padr_embal        LIKE item_embalagem.qtd_padr_embal,
         p_ies_incl_txt          CHAR(01),
         l_ind                   SMALLINT

  CALL log006_exibe_teclas("01 02 03 05 06 07", p_versao)
  WHENEVER ERROR CONTINUE
  CALL log130_procura_caminho("vdp42842") RETURNING p_nom_tela
  OPEN WINDOW w_vdp42842 AT 2,2 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  WHENEVER ERROR STOP
  CURRENT WINDOW IS w_vdp42842

  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY p_pedido_dig_mest.num_pedido  TO num_pedido

  LET p_pedido_dig_item.num_pedido  =  p_pedido_dig_mest.num_pedido

  LET pa_curr = 1

  IF p_funcao = "INCLUSAO" AND p_count = 0
  THEN CALL set_count(0)
  ELSE
     IF p_funcao = "INCLUSAO" AND p_count <> 0
     THEN
     ELSE
          CALL set_count(p_qtd_item)
    END IF
  END IF

  INPUT ARRAY t_pedido_dig_item WITHOUT DEFAULTS FROM s_pedido_dig_item.*

  BEFORE ROW
      LET pa_curr  = arr_curr()
      LET pa_count = ARR_COUNT()
      LET sc_curr  = scr_line()

  BEFORE FIELD cod_item
      CALL vdp4284_mostra_zoom()

  AFTER FIELD cod_item
      CALL vdp4284_apaga_zoom()

    IF t_pedido_dig_item[pa_curr].cod_item IS NOT NULL OR
       t_pedido_dig_item[pa_curr].cod_item <> " "
    THEN
        IF NOT p_ies_item_ped = "S" THEN
           FOR l_ind = 1 TO 500
              IF l_ind <> pa_curr THEN
                 IF t_pedido_dig_item[l_ind].cod_item  = t_pedido_dig_item[pa_curr].cod_item  THEN
                    CALL log0030_mensagem( " Item j� informado. ","excl")
                    NEXT FIELD cod_item
                 END IF
              END IF
           END FOR
        END IF

#      IF vdp4284_existe_nat_oper_refer() THEN
#         IF NOT vdp4284_existe_fiscal_par() THEN
#            ERROR " Nao ha parametros fiscais cadastrados para a Operacao ",
#                  m_cod_nat_oper_ref, " do item "
#            NEXT FIELD cod_item
#         END IF
#      END IF
         CALL vdp4284_verifica_item()
              RETURNING p_status, p_qtd_padr_embal

       IF p_status = 0 THEN
          NEXT FIELD cod_item
       END IF

     {---grade---}
      INITIALIZE p_sum_qtd_grade TO NULL
      IF  vdp4284_verifica_grade()  THEN
      ELSE
          NEXT FIELD cod_item
      END IF
     {------------}
    END IF


  BEFORE FIELD qtd_pecas_solic
    IF t_pedido_dig_item[pa_curr].qtd_pecas_solic IS NULL THEN
       LET t_pedido_dig_item[pa_curr].qtd_pecas_solic = 0
       DISPLAY t_pedido_dig_item[pa_curr].qtd_pecas_solic TO
               s_pedido_dig_item[sc_curr].qtd_pecas_solic
    END IF
  AFTER FIELD qtd_pecas_solic
        IF   p_ies_tip_controle = "2"
        THEN IF   vdp4284_entrada_ped_itens_rem() = FALSE
             THEN CALL log0030_mensagem( "Informe as informa��es da REMESSA corretamente","excl")
                  NEXT FIELD qtd_pecas_solic
             END IF
        END IF

        IF   p_sum_qtd_grade <> t_pedido_dig_item[pa_curr].qtd_pecas_solic
              THEN CALL log0030_mensagem( "Quantidade do item difere da soma digitada na grade ","excl")
                   NEXT FIELD qtd_pecas_solic
        END IF


  BEFORE FIELD pre_unit
    IF t_pedido_dig_item[pa_curr].pre_unit IS NULL THEN
       LET t_pedido_dig_item[pa_curr].pre_unit = 0
       DISPLAY t_pedido_dig_item[pa_curr].pre_unit TO
               s_pedido_dig_item[sc_curr].pre_unit
    END IF
#   IF   p_pedido_dig_mest.num_list_preco <> 0
#   THEN LET pa_curr = arr_curr()
#        LET t_pedido_dig_item[pa_curr].pre_unit = 0
#        NEXT FIELD pct_desc_adic
#   END IF

  AFTER  FIELD pre_unit
       IF   t_pedido_dig_item[pa_curr].pre_unit IS NULL OR
            t_pedido_dig_item[pa_curr].pre_unit = 0
       THEN CALL log0030_mensagem( "Preco unit�rio inv�lido ","excl")
            NEXT FIELD pre_unit
       END IF
       CALL vdp4284_busca_qtd_decimais()

  BEFORE FIELD pct_desc_adic
    IF t_pedido_dig_item[pa_curr].pct_desc_adic IS NULL THEN
       LET t_pedido_dig_item[pa_curr].pct_desc_adic = 0
       DISPLAY t_pedido_dig_item[pa_curr].pct_desc_adic TO
               s_pedido_dig_item[sc_curr].pct_desc_adic
    END IF
    IF p_funcao = "INCLUSAO" THEN
       LET pa_curr = arr_curr()
       LET t_pedido_dig_item[pa_curr].pct_desc_adic  = 0
    END IF

  AFTER FIELD pct_desc_adic
      CALL vdp4284_apaga_zoom()

  BEFORE FIELD prz_entrega
    IF p_funcao = "INCLUSAO" AND
       t_pedido_dig_item[pa_curr].prz_entrega IS NULL THEN
       LET pa_curr = arr_curr()
       LET t_pedido_dig_item[pa_curr].prz_entrega =
           p_pedido_dig_mest.dat_prazo_entrega
    END IF
    LET p_campo = TRUE

  AFTER  FIELD prz_entrega
    LET pa_curr = arr_curr()
    IF t_pedido_dig_item[pa_curr].prz_entrega < TODAY
       THEN CALL log0030_mensagem( " DATA menor que a data corrente","excl")
       NEXT FIELD prz_entrega
    END IF
    IF m_lead_time > 0 THEN
       IF t_pedido_dig_item[pa_curr].prz_entrega - m_lead_time < TODAY THEN
          LET m_msg = " Prazo de Entrega menos Lead Time(", m_lead_time USING "<<<"," dias) ",
                "menor que a data corrente "
          CALL log0030_mensagem(m_msg,"excl")
          NEXT FIELD prz_entrega
       ELSE
          LET t_pedido_dig_item[pa_curr].prz_entrega =
              t_pedido_dig_item[pa_curr].prz_entrega - m_lead_time
              DISPLAY t_pedido_dig_item[pa_curr].prz_entrega TO prz_entrega
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
          IF vdp243_digita_texto(p_pedido_dig_item.num_pedido,pa_curr) = FALSE
             THEN LET t_pedido_dig_item[pa_curr].ies_incl_txt = "N"
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
       CALL log0030_mensagem( "Valor de Frete Unit�rio inv�lido.","excl")
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
       CALL log0030_mensagem( "Valor de Seguro Unit�rio inv�lido.","excl")
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
     CURRENT WINDOW IS w_vdp42842


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

   ON KEY (control-w, f1)
      #lds IF NOT LOG_logix_versao5() THEN
      #lds CONTINUE INPUT
      #lds END IF
          CALL vdp4284_help_itens()
   ON KEY (control-z, f4)
          CALL vdp4284_popup(3)

 END INPUT

   LET p_count  = arr_count()

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION


#-----------------------------------------------#
FUNCTION vdp4284_entrada_dados_item_bnf(p_funcao)
#-----------------------------------------------#
   DEFINE p_funcao                CHAR(12),
          p_qtd_c_decim           DECIMAL(15,5),
          p_qtd_resto             DECIMAL(15,5),
          p_qtd_s_decim           INTEGER,
          p_qtd_padr_embal        LIKE item_embalagem.qtd_padr_embal

   CALL log006_exibe_teclas("01 02 05 06 07", p_versao)
   CALL log130_procura_caminho("vdp42849") RETURNING p_nom_tela
   OPEN WINDOW w_vdp42849 AT 2,2 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   CURRENT WINDOW IS w_vdp42849

   DISPLAY p_cod_empresa                 TO cod_empresa
   DISPLAY p_pedido_dig_mest.num_pedido  TO num_pedido

   LET p_ped_dig_item_bnf.num_pedido  =  p_pedido_dig_mest.num_pedido

   CALL SET_COUNT(p_count_bnf)

   INPUT ARRAY t_ped_dig_bnf WITHOUT DEFAULTS
    FROM s_ped_dig_bnf.*

      BEFORE ROW
         LET pa_curr_bnf = arr_curr()
         LET sc_curr_bnf = scr_line()

      BEFORE FIELD cod_item
      CALL vdp4284_mostra_zoom()
      AFTER  FIELD cod_item
         IF t_ped_dig_bnf[pa_curr_bnf].cod_item IS NOT NULL THEN
            CALL vdp4284_verifica_item_bnf()
                 RETURNING p_status, p_qtd_padr_embal
            IF p_status = 0 THEN
               NEXT FIELD cod_item
            END IF
         END IF
      CALL vdp4284_apaga_zoom()

      AFTER FIELD qtd_pecas_solic
         IF t_ped_dig_bnf[pa_curr_bnf].qtd_pecas_solic IS NULL THEN
            LET t_ped_dig_bnf[pa_curr_bnf].qtd_pecas_solic = 0
            DISPLAY t_ped_dig_bnf[pa_curr_bnf].qtd_pecas_solic TO
                    s_ped_dig_bnf[sc_curr_bnf].qtd_pecas_solic
         ELSE
            IF p_pedido_dig_mest.ies_embal_padrao = "1" OR
               p_pedido_dig_mest.ies_embal_padrao = "2" THEN
               LET p_qtd_c_decim  = t_ped_dig_bnf[pa_curr_bnf].qtd_pecas_solic /
                                    p_qtd_padr_embal
               LET p_qtd_s_decim  = t_ped_dig_bnf[pa_curr_bnf].qtd_pecas_solic /
                                    p_qtd_padr_embal
               LET p_qtd_resto   = p_qtd_c_decim - p_qtd_s_decim
               IF p_qtd_resto = 0 THEN
                  IF t_ped_dig_bnf[pa_curr_bnf].qtd_pecas_solic >=
                     p_qtd_padr_embal THEN
                  ELSE
                     CALL log0030_mensagem( "Qtd  solic. menor que Qtd padr�o embal.","excl")
                     NEXT FIELD qtd_pecas_solic
                  END  IF
               ELSE
                  CALL log0030_mensagem( "Pedido padr�o embal. qtd. pe�as n�o padr�o embal.","excl")
                  NEXT FIELD qtd_pecas_solic
               END IF
            END IF
         END IF

      BEFORE FIELD pre_unit
         IF t_ped_dig_bnf[pa_curr_bnf].pre_unit IS NULL THEN
            LET t_ped_dig_bnf[pa_curr_bnf].pre_unit = 0
            DISPLAY t_ped_dig_bnf[pa_curr_bnf].pre_unit TO
                    s_ped_dig_bnf[sc_curr_bnf].pre_unit
         END IF
         IF p_pedido_dig_mest.num_list_preco <> 0 THEN
            LET pa_curr_bnf = arr_curr()
            LET t_ped_dig_bnf[pa_curr_bnf].pre_unit = 0
            NEXT FIELD pct_desc_adic
         END IF

      BEFORE FIELD pct_desc_adic
         IF t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic IS NULL THEN
            LET t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic = 0
            DISPLAY t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic TO
                    s_ped_dig_bnf[sc_curr_bnf].pct_desc_adic
         END IF
         IF p_funcao = "INCLUSAO" THEN
            LET pa_curr_bnf = arr_curr()
            LET t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic  = 0
         END IF
      AFTER FIELD pct_desc_adic
      CALL vdp4284_apaga_zoom()

      BEFORE FIELD prz_entrega
         IF p_funcao = "INCLUSAO" AND
            t_ped_dig_bnf[pa_curr_bnf].prz_entrega IS NULL THEN
            LET pa_curr_bnf = arr_curr()
            LET t_ped_dig_bnf[pa_curr_bnf].prz_entrega =
                p_pedido_dig_mest.dat_prazo_entrega
         END IF

      AFTER  FIELD prz_entrega
         IF t_ped_dig_bnf[pa_curr_bnf].prz_entrega < TODAY THEN
            CALL log0030_mensagem( " DATA menor que a data corrente","excl")
            NEXT FIELD prz_entrega
         END IF
         IF m_lead_time > 0 THEN
            IF t_ped_dig_bnf[pa_curr_bnf].prz_entrega - m_lead_time < TODAY THEN
               LET m_msg =  " Prazo de Entrega menos Lead Time(",m_lead_time USING "<<<"," dias) ",
                     "menor que a data corrente "
               CALL log0030_mensagem(m_msg,"excl")
               NEXT FIELD prz_entrega
            ELSE
               LET t_ped_dig_bnf[pa_curr_bnf].prz_entrega =
                   t_ped_dig_bnf[pa_curr_bnf].prz_entrega - m_lead_time
               DISPLAY t_ped_dig_bnf[pa_curr_bnf].prz_entrega TO prz_entrega
            END IF
         END IF

      ON KEY (control-w, f1)
         #lds IF NOT LOG_logix_versao5() THEN
         #lds CONTINUE INPUT
         #lds END IF
         CALL vdp4284_help_itens_bnf()

      ON KEY (control-z, f4)
         CALL vdp4284_popup(4)
   END INPUT

   CLOSE WINDOW w_vdp42849
   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_vdp4284

   LET p_count_bnf  = arr_count()

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#---------------------------------#
 FUNCTION vdp4284_verifica_item()
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
             p_den_item        LIKE item.den_item,
             p_funcao          CHAR (12)

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
  THEN CALL log0030_mensagem( " Produto n�o cadastrado ","excl")
       LET p_status = 0
       RETURN  p_status, p_qtd_padr_embal
  END IF
#  DISPLAY p_den_item TO den_item

  IF p_ies_incid_ipi <> 1
  THEN LET p_pct_ipi = 0
  END IF
  IF   p_ies_situacao = "A"
  THEN
  ELSE CALL log0030_mensagem( "Produto cancelado","excl")
       LET p_status = 0
       RETURN  p_status, p_qtd_padr_embal
  END IF
  IF vdp4284_existe_nat_oper_refer() THEN
     IF NOT vdp4284_existe_fiscal_par(l_cod_cla_fisc,p_cod_lin_prod,p_cod_lin_recei,p_cod_seg_merc,p_cod_cla_uso) THEN
        LET p_status = 0
        RETURN p_status, p_qtd_padr_embal
     END IF
  END IF
  #CALL vdP4284_mostra_estoque(t_pedido_dig_item[pa_curr].cod_item)
  IF   p_pedido_dig_mest.ies_embal_padrao = "1"  THEN
        WHENEVER ERROR CONTINUE
        SELECT qtd_padr_embal
         INTO p_qtd_padr_embal
         FROM item_embalagem
        WHERE item_embalagem.cod_empresa = p_cod_empresa
          AND item_embalagem.cod_item    = t_pedido_dig_item[pa_curr].cod_item
          AND item_embalagem.ies_tip_embal IN ("N","I")
         WHENEVER ERROR STOP
         IF   sqlca.sqlcode = NOTFOUND
         THEN CALL log0030_mensagem( "Item n�o cadastrado na tabela item_embalagem","excl")
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
               THEN CALL log0030_mensagem( "Item n�o cadastrado na tabela item_embalagem","excl")
                    LET p_status = 0
                    RETURN p_status, p_qtd_padr_embal
               END IF
        END IF
  END IF
  IF   p_pedido_dig_mest.num_list_preco = 0 OR
       p_pedido_dig_mest.num_list_preco IS NULL OR
       p_pedido_dig_mest.num_list_preco = "    " AND
       p_funcao = 'MODIFICACAO' AND
       t_pedido_dig_item[pa_curr].pre_unit <> 0 OR
       t_pedido_dig_item[pa_curr].pre_unit IS NOT NULL
  THEN
  ELSE CALL vdp1499_busca_preco_lista(p_cod_empresa,
                                      p_pedido_dig_mest.num_list_preco,
                                      p_pedido_dig_mest.cod_cliente,p_cod_item,
                                      p_cod_lin_prod,
                                      p_cod_lin_recei,
                                      p_cod_seg_merc,
                                      p_cod_cla_uso,
                                      0,0,0,
                                      p_cod_uni_feder,0,1)
                                      RETURNING p_status,
                                                p_desc_bruto_tab,
                                                p_desc_adic_tab,
                                                p_pre_unit_tab,
                                                l_preco_minimo

       IF   p_status = 0
       THEN IF p_pre_unit_tab > 0
            THEN LET t_pedido_dig_item[pa_curr].pre_unit = p_pre_unit_tab
                 IF t_pedido_dig_item[pa_curr].pct_desc_adic  = 0 OR
                    t_pedido_dig_item[pa_curr].pct_desc_adic  IS NULL
                 THEN LET t_pedido_dig_item[pa_curr].pct_desc_adic  = p_desc_adic_tab
                 END IF
                 DISPLAY t_pedido_dig_item[pa_curr].pre_unit TO s_pedido_dig_item[sc_curr].pre_unit
                 DISPLAY t_pedido_dig_item[pa_curr].pct_desc_adic  TO s_pedido_dig_item[sc_curr].pct_desc_adic

            ELSE CALL vdp4284_calcula_pre_unit(p_pre_unit_bruto,
                                              p_desc_bruto_tab)
                      RETURNING t_pedido_dig_item[pa_curr].pre_unit
                 IF t_pedido_dig_item[pa_curr].pct_desc_adic  = 0 OR
                    t_pedido_dig_item[pa_curr].pct_desc_adic  IS NULL
                 THEN LET t_pedido_dig_item[pa_curr].pct_desc_adic  = p_desc_adic_tab
                 END IF
                 DISPLAY t_pedido_dig_item[pa_curr].pre_unit TO s_pedido_dig_item[sc_curr].pre_unit
                 DISPLAY t_pedido_dig_item[pa_curr].pct_desc_adic  TO s_pedido_dig_item[sc_curr].pct_desc_adic
            END IF
       ELSE CALL log0030_mensagem( "Produto n�o cadastrado na lista de pre�o","excl")
            LET p_status = 0
            RETURN  p_status, p_qtd_padr_embal
       END  IF
  END  IF
  IF   t_pedido_dig_item[pa_curr].pre_unit = 0
  THEN IF   p_pedido_dig_mest.num_list_preco = 0 OR
            p_pedido_dig_mest.num_list_preco IS NULL OR
            p_pedido_dig_mest.num_list_preco = "    "
       THEN LET p_status = 1
       ELSE CALL log0030_mensagem( "Produto n�o cadastrado na lista de pre�o","excl")
            LET p_status = 0
       END IF
  ELSE LET p_status = 1
  END IF
 RETURN p_status, p_qtd_padr_embal

 WHENEVER ERROR STOP

END FUNCTION

#-------------------------------#
FUNCTION vdp4284_help_itens_bnf()
#-------------------------------#
   CASE
       WHEN INFIELD(cod_item)           CALL SHOWHELP(3046)
       WHEN INFIELD(qtd_pecas_solic)    CALL SHOWHELP(3047)
       WHEN INFIELD(pre_unit)           CALL SHOWHELP(3048)
       WHEN INFIELD(pct_desc_adic)      CALL SHOWHELP(3049)
       WHEN INFIELD(prz_entrega)        CALL SHOWHELP(3050)
   END CASE
END FUNCTION

#----------------------------------#
FUNCTION vdp4284_verifica_item_bnf()
#----------------------------------#
   DEFINE p_ies_situacao    LIKE item.ies_situacao,
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
          l_den_item        LIKE item.den_item

   LET p_status  = 1

   WHENEVER ERROR CONTINUE
   SELECT item.cod_item,
          item.den_item,
          item.ies_situacao,
          item_vdp.pre_unit_brut,
          item.cod_lin_prod,
          item.cod_lin_recei,
          item.cod_seg_merc,
          item.cod_cla_uso
     INTO p_cod_item,
          l_den_item,
          p_ies_situacao,
          p_pre_unit_bruto,
          p_cod_lin_prod,
          p_cod_lin_recei,
          p_cod_seg_merc,
          p_cod_cla_uso
     FROM item,
          item_vdp
    WHERE item.cod_item        = t_ped_dig_bnf[pa_curr_bnf].cod_item
      AND item.cod_item        = item_vdp.cod_item
      AND item.cod_empresa     = p_cod_empresa
      AND item_vdp.cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = NOTFOUND THEN
      CALL log0030_mensagem( " Produto n�o cadastrado ","excl")
      LET p_status = 0
      RETURN  p_status, p_qtd_padr_embal
   END IF

   IF p_ies_situacao = "A" THEN
   ELSE
      CALL log0030_mensagem( "Produto cancelado","excl")
      LET p_status = 0
      RETURN  p_status, p_qtd_padr_embal
   END IF

   IF p_pedido_dig_mest.ies_embal_padrao = "1" THEN

      WHENEVER ERROR CONTINUE
      SELECT qtd_padr_embal
        INTO p_qtd_padr_embal
        FROM item_embalagem
       WHERE item_embalagem.cod_empresa = p_cod_empresa
         AND item_embalagem.cod_item    = t_ped_dig_bnf[pa_curr_bnf].cod_item
         AND item_embalagem.ies_tip_embal IN ("N","I")
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = NOTFOUND THEN
         CALL log0030_mensagem( "Item_bnf n�o cadastrado na tabela item_embalagem","excl")
         LET p_status = 0
         RETURN p_status, p_qtd_padr_embal
      END IF
   ELSE
      IF p_pedido_dig_mest.ies_embal_padrao = "2" THEN

         WHENEVER ERROR CONTINUE
         SELECT qtd_padr_embal
           INTO p_qtd_padr_embal
           FROM item_embalagem
          WHERE item_embalagem.cod_empresa = p_cod_empresa
            AND item_embalagem.cod_item    = t_ped_dig_bnf[pa_curr_bnf].cod_item
            AND item_embalagem.ies_tip_embal IN ("E","C")
         WHENEVER ERROR STOP
         IF sqlca.sqlcode = NOTFOUND THEN
            CALL log0030_mensagem( "Item_bnf n�o cadastrado na tabela item_embalagem","excl")
            LET p_status = 0
            RETURN p_status, p_qtd_padr_embal
         END IF
      END IF
   END IF

   IF p_pedido_dig_mest.num_list_preco = 0     OR
      p_pedido_dig_mest.num_list_preco IS NULL THEN
   ELSE
      CALL vdp1499_busca_preco_lista(p_cod_empresa,
                                      p_pedido_dig_mest.num_list_preco,
                                      p_pedido_dig_mest.cod_cliente,p_cod_item,
                                      p_cod_lin_prod,
                                      p_cod_lin_recei,
                                      p_cod_seg_merc,
                                      p_cod_cla_uso,
                                      0,0,0,
                                    p_cod_uni_feder,0,1)
                                      RETURNING p_status,
                                                p_desc_bruto_tab,
                                                p_desc_adic_tab,
                                                p_pre_unit_tab,
                                                l_preco_minimo
         IF p_status = 0 THEN
         IF p_pre_unit_tab > 0 THEN
            LET t_ped_dig_bnf[pa_curr_bnf].pre_unit = p_pre_unit_tab
            IF  t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic = 0     OR
                t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic IS NULL THEN
               LET t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic = p_desc_adic_tab
            END IF
            DISPLAY t_ped_dig_bnf[pa_curr_bnf].pre_unit TO
                     s_ped_dig_bnf[sc_curr_bnf].pre_unit
            DISPLAY t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic TO
                     s_ped_dig_bnf[sc_curr_bnf].pct_desc_adic
            #CALL vdp4284_busca_qtd_dec_bnf()
            DISPLAY t_ped_dig_bnf[pa_curr_bnf].pre_unit TO
                     s_ped_dig_bnf[sc_curr_bnf].pre_unit
         ELSE
            CALL vdp4284_calcula_pre_unit(p_pre_unit_bruto,
                                          p_desc_bruto_tab)
                 RETURNING t_ped_dig_bnf[pa_curr_bnf].pre_unit
            IF t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic = 0     OR
               t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic IS NULL THEN
               LET t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic = p_desc_adic_tab
            END IF
            DISPLAY t_ped_dig_bnf[pa_curr_bnf].pre_unit TO
                     s_ped_dig_bnf[sc_curr_bnf].pre_unit
            DISPLAY t_ped_dig_bnf[pa_curr_bnf].pct_desc_adic TO
                     s_ped_dig_bnf[sc_curr_bnf].pct_desc_adic
         END IF
      ELSE
         CALL log0030_mensagem( "Produto n�o cadastrado na lista de pre�o","excl")
         LET p_status = 0
         RETURN  p_status, p_qtd_padr_embal
      END  IF
   END  IF

   LET t_ped_dig_bnf[pa_curr_bnf].den_item  = l_den_item
   DISPLAY t_ped_dig_bnf[pa_curr_bnf].den_item TO
            s_ped_dig_bnf[sc_curr_bnf].den_item

   LET p_status = 1
   WHENEVER ERROR STOP

   RETURN p_status, p_qtd_padr_embal
END FUNCTION

#-------------------------------------------------------#
 FUNCTION vdp4284_calcula_pre_unit(p_pre_unit,p_pct_desc)
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

 RETURN p_pre_unit

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION vdp4284_busca_desc_adic_unico(p_num_sequencia,p_desc)
#--------------------------------------------------------------#
 DEFINE  p_desc_unico         DECIMAL(8,0),
         p_cod_empresa        LIKE empresa.cod_empresa,
         p_num_pedido         LIKE pedidos.num_pedido,
         p_num_sequencia      LIKE ped_itens.num_sequencia,
         p_desc               LIKE wfat_item.pct_desc_adic,
         p_desc_i             SMALLINT

 INITIALIZE p_desc_unico TO NULL
 LET p_desc_unico = p_desc

 FOR p_desc_i = 1 TO pa_currdes
  IF t_ped_dig_item_desc[p_desc_i].num_sequencia = p_num_sequencia AND
     (t_ped_dig_item_desc[p_desc_i].pct_desc_1 > 0 ) THEN
     LET  p_desc = 100    - ( 100    * p_desc / 100 )
     LET  p_desc = p_desc - ( p_desc * t_ped_dig_item_desc[p_desc_i].pct_desc_1 / 100 )
     LET  p_desc = p_desc - ( p_desc * t_ped_dig_item_desc[p_desc_i].pct_desc_2 / 100 )
     LET  p_desc = p_desc - ( p_desc * t_ped_dig_item_desc[p_desc_i].pct_desc_3 / 100 )
     LET  p_desc = p_desc - ( p_desc * t_ped_dig_item_desc[p_desc_i].pct_desc_4 / 100 )
     LET  p_desc = p_desc - ( p_desc * t_ped_dig_item_desc[p_desc_i].pct_desc_5 / 100 )
     LET  p_desc = p_desc - ( p_desc * t_ped_dig_item_desc[p_desc_i].pct_desc_6 / 100 )
     LET  p_desc = p_desc - ( p_desc * t_ped_dig_item_desc[p_desc_i].pct_desc_7 / 100 )
     LET  p_desc = p_desc - ( p_desc * t_ped_dig_item_desc[p_desc_i].pct_desc_8 / 100 )
     LET  p_desc = p_desc - ( p_desc * t_ped_dig_item_desc[p_desc_i].pct_desc_9 / 100 )
     LET  p_desc = p_desc - ( p_desc * t_ped_dig_item_desc[p_desc_i].pct_desc_10 / 100 )
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

#------------------------------#
 FUNCTION vdp4284_total(p_funcao)
#------------------------------#
  DEFINE p_funcao                CHAR(12),
         p_pct_desc_m            LIKE ped_itens.pct_desc_adic,
         p_pct_desc_i            LIKE ped_itens.pct_desc_adic,
         p_total_val_liq         DECIMAL(15,2) ,
         p_total_val_bru         DECIMAL(15,2)

  CALL log006_exibe_teclas("01 02 07", p_versao)
  WHENEVER ERROR CONTINUE
  CALL log130_procura_caminho("vdp42843") RETURNING p_nom_tela
  OPEN WINDOW w_vdp42843 AT 2,2 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  WHENEVER ERROR STOP
  CURRENT WINDOW IS w_vdp42843

  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY p_pedido_dig_mest.num_pedido  TO num_pedido

  LET p_total.quantidade       = 0
  LET p_total.preco            = 0
  LET p_total.desc_adic        = 0
  LET p_total_val_liq          = 0
  LET p_total_val_bru          = 0
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
         CALL vdp4284_calcula_pre_unit(t_pedido_dig_item[p_count].pre_unit,
                                      p_pct_desc_m)
             RETURNING p_pre_unit_liq
         CALL vdp784_busca_desc_adic_unico(p_cod_empresa,
                                       p_pedido_dig_mest.num_pedido,
                                       p_count,
                                       t_pedido_dig_item[p_count].pct_desc_adic)
             RETURNING p_pct_desc_i
         CALL vdp4284_calcula_pre_unit(p_pre_unit_liq,
                                      p_pct_desc_i)
             RETURNING p_pre_unit_liq
         LET p_totalc.val_tot_liquido = p_totalc.val_tot_liquido +
                                     ( p_pre_unit_liq *
                                     t_pedido_dig_item[p_count].qtd_pecas_solic)

    ELSE EXIT FOR
    END IF
 END FOR

 IF   p_par_vdp.par_vdp_txt[20,20] = "N"
 THEN DISPLAY p_totalc.quantidade      TO quantidade
      DISPLAY p_totalc.preco           TO preco
      DISPLAY p_totalc.desc_adic       TO desc_adic
      DISPLAY p_totalc.val_tot_bruto   TO val_tot_bruto
      DISPLAY p_totalc.val_tot_liquido TO val_tot_liquido
      IF log004_confirm(17,40) THEN
         RETURN TRUE
      ELSE
         LET int_flag = 0
         RETURN FALSE
      END IF
 END IF
{
 LET p_tela = 0
 LET p_flag = 0
 RETURN p_status
}
 WHENEVER ERROR CONTINUE
 SELECT * INTO p_par_vdp.* FROM par_vdp
  WHERE par_vdp.cod_empresa   = p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_par_vdp.*  TO NULL
 END IF

 INPUT BY NAME p_total.* WITHOUT DEFAULTS

  AFTER FIELD quantidade
    IF p_totalc.quantidade = p_total.quantidade THEN
       ELSE CALL log0030_mensagem( " QUANTIDADE total n�o confere","excl")
            NEXT FIELD quantidade
    END IF

  AFTER FIELD preco
    IF p_totalc.preco = p_total.preco THEN
       ELSE CALL log0030_mensagem( " PRE�O total n�o confere","excl")
            NEXT FIELD preco
    END IF

    ON KEY (f1, control-w)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
           CALL vdp4284_help(1)
 END INPUT

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION


#-----------------------------#
FUNCTION vdp4284_help(l_status)
#-----------------------------#
   DEFINE l_status    SMALLINT

   CASE
      WHEN infield(num_pedido)         CALL showhelp(3001)
      WHEN infield(cod_nat_oper)       CALL showhelp(3002)
      WHEN INFIELD(parametro_texto)    CALL SHOWHELP(5817)
      WHEN infield(dat_emis_repres)    CALL showhelp(3003)
      WHEN infield(cod_tip_carteira)   CALL showhelp(3350)
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
      WHEN infield(cod_repres)         CALL showhelp(3005)
      WHEN infield(ies_comissao)       CALL showhelp(3006)
      WHEN infield(ies_finalidade)     CALL showhelp(3008)
      WHEN infield(ies_preco)          CALL showhelp(3009)
      WHEN infield(num_list_preco)     CALL showhelp(3010)
      WHEN infield(cod_cnd_pgto)       CALL showhelp(3011)
      WHEN infield(pct_desc_financ)    CALL showhelp(3012)
      WHEN infield(pct_desc_adic)      CALL showhelp(3013)
      WHEN infield(num_pedido_cli)     CALL showhelp(3014)
      WHEN infield(num_pedido_repres)  CALL showhelp(3015)
      WHEN infield(ies_frete)          CALL showhelp(3027)
      WHEN infield(pct_frete)          CALL showhelp(3028)
      WHEN infield(cod_repres_adic)    CALL showhelp(3016)
      WHEN infield(cod_transpor)       CALL showhelp(3017)
      WHEN infield(cod_consig)         CALL showhelp(3018)
      WHEN infield(ies_embal_padrao)   CALL showhelp(3019)
      WHEN infield(ies_tip_entrega)    CALL showhelp(3020)
      WHEN infield(dat_prazo_entrega)  CALL showhelp(3023)
      WHEN infield(pct_comissao)       CALL showhelp(3007)
      WHEN infield(ies_sit_pedido)     CALL showhelp(3024)
      WHEN infield(cod_tip_venda)      CALL showhelp(3025)
      WHEN infield(num_sequencia)      CALL showhelp(3030)
      WHEN infield(end_entrega)        CALL showhelp(3031)
      WHEN infield(den_bairro)         CALL showhelp(3032)
      WHEN infield(cod_cidade)         CALL showhelp(3033)
      WHEN infield(cod_cep)            CALL showhelp(3034)
      WHEN infield(num_cgc)            CALL showhelp(3035)
      WHEN infield(ins_estadual)       CALL showhelp(3036)
      WHEN infield(tex_observ_1)       CALL showhelp(3037)
      WHEN infield(tex_observ_2)       CALL showhelp(3037)
      WHEN infield(preco)              CALL showhelp(3040)
      WHEN infield(quantidade)         CALL showhelp(3039)
      WHEN infield(desc_adic)          CALL showhelp(3054)
      WHEN infield(cod_moeda)          CALL showhelp(3026)
      WHEN infield(ies_incl_txt)       CALL showhelp(3029)
   END CASE
END FUNCTION

#---------------------------#
 FUNCTION vdp4284_help_itens()
#---------------------------#
  CASE
    WHEN infield(cod_item)           CALL showhelp(3038)
    WHEN infield(qtd_pecas_solic)    CALL showhelp(3039)
    WHEN infield(pre_unit)           CALL showhelp(3040)
    WHEN infield(pct_desc_adic)      CALL showhelp(3041)
    WHEN infield(prz_entrega)        CALL showhelp(3044)
    WHEN infield(ies_incl_txt)       CALL showhelp(3045)
  END CASE
END FUNCTION

#--------------------------------#
 FUNCTION vdp4284_popup(p_status)
#--------------------------------#
DEFINE  p_cod_transpor    LIKE transport.cod_transpor,
        l_den_transpor    LIKE transport.den_transpor,
        p_cod_repres      LIKE representante.cod_repres,
        p_cod_consig      LIKE transport.cod_transpor,
        l_den_consig      LIKE transport.den_transpor,
        p_cod_repres_adic LIKE representante.cod_repres,
        p_lista_preco     LIKE desc_preco_mest.num_list_preco,
        p_cod_cliente     LIKE clientes.cod_cliente,
        p_cod_item_pe     LIKE item.cod_item,
        p_cod_repres_3    LIKE representante.cod_repres,
        p_status          SMALLINT
 CASE
    WHEN infield(cod_nat_oper)
         CALL log009_popup(6,25,"NAT. OPERACAO","nat_operacao",
                          "cod_nat_oper","den_nat_oper",
                          "vdp0050","N","") RETURNING p_pedido_dig_mest.cod_nat_oper
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         DISPLAY p_pedido_dig_mest.cod_nat_oper TO cod_nat_oper
    WHEN infield(cod_tip_carteira)
         CALL log009_popup(6,25,"TIPO CARTEIRA","tipo_carteira",
                          "cod_tip_carteira","den_tip_carteira",
                          "vdp6310","N","") RETURNING p_pedido_dig_mest.cod_tip_carteira
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         DISPLAY BY NAME p_pedido_dig_mest.cod_tip_carteira
    WHEN infield(cod_cliente)
         LET p_cod_cliente = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         IF p_cod_cliente IS NOT NULL
         THEN  LET p_pedido_dig_mest.cod_cliente = p_cod_cliente
               DISPLAY p_pedido_dig_mest.cod_cliente TO cod_cliente
         END IF
    WHEN infield(cod_repres)
         CALL log009_popup(6,25,"REPRESENTANTE","representante",
                          "cod_repres","raz_social",
                          "vdp3550","N","") RETURNING p_cod_repres
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         IF p_cod_repres IS NOT NULL
         THEN  LET p_pedido_dig_mest.cod_repres = p_cod_repres
               DISPLAY p_pedido_dig_mest.cod_repres TO cod_repres
         END IF
    WHEN infield(cod_cnd_pgto)
         CALL log009_popup(6,25,"COND. PAGAMENTO","cond_pgto",
                          "cod_cnd_pgto","den_cnd_pgto",
                          "vdp0140","N","") RETURNING p_pedido_dig_mest.cod_cnd_pgto
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         DISPLAY p_pedido_dig_mest.cod_cnd_pgto TO cod_cnd_pgto
    WHEN infield(cod_repres_adic)
         CALL log009_popup(6,25,"REPRESENTANTE","representante",
                          "cod_repres","raz_social",
                          "vdp3550","N","") RETURNING p_cod_repres_adic
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         IF p_cod_repres_adic IS NOT NULL
         THEN  LET p_pedido_dig_mest.cod_repres_adic = p_cod_repres_adic
               DISPLAY p_pedido_dig_mest.cod_repres_adic TO cod_repres_adic
         END IF
    WHEN infield(cod_repres_3)
         CALL log009_popup(6,25,"REPRESENTANTE","representante",
                          "cod_repres","raz_social",
                          "vdp3550","N","") RETURNING p_cod_repres_3
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         IF p_cod_repres_3 IS NOT NULL
         THEN  LET m_cod_repres_3 = p_cod_repres_3
               DISPLAY m_cod_repres_3 TO cod_repres_3
         END IF
    WHEN infield(num_list_preco)
         CALL log009_popup(6,25,"LISTA DE PRECOS","desc_preco_mest",
                          "num_list_preco","den_list_preco",
                          "vdp0260","N","") RETURNING p_lista_preco
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         IF p_lista_preco IS NOT NULL
         THEN  LET p_pedido_dig_mest.num_list_preco = p_lista_preco
               DISPLAY p_pedido_dig_mest.num_list_preco TO num_list_preco
         END IF
    WHEN infield(cod_transpor)
         LET p_cod_transpor = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         IF p_cod_transpor IS NOT NULL
         THEN  LET l_den_transpor = " "
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
               DISPLAY l_den_transpor TO den_transpor
               LET p_pedido_dig_mest.cod_transpor = p_cod_transpor
               DISPLAY p_pedido_dig_mest.cod_transpor TO cod_transpor
         END IF
    WHEN infield(cod_consig)
         LET p_cod_consig = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         IF p_cod_consig IS NOT NULL
         THEN  LET l_den_consig = " "
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
               DISPLAY l_den_consig TO den_consig
               LET p_pedido_dig_mest.cod_consig = p_cod_consig
               DISPLAY p_pedido_dig_mest.cod_consig TO cod_consig
         END IF
    WHEN infield(cod_tip_venda)
         CALL log009_popup(6,25,"TIPO VENDA","tipo_venda",
                          "cod_tip_venda","den_tip_venda",
                          "vdp0120","N","") RETURNING p_pedido_dig_mest.cod_tip_venda
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         DISPLAY p_pedido_dig_mest.cod_tip_venda TO cod_tip_venda
    WHEN infield(cod_moeda)
         CALL log009_popup(6,25,"MOEDAS","moeda",
                          "cod_moeda","den_moeda",
                          "pat0140","N","") RETURNING p_pedido_dig_mest.cod_moeda
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
         DISPLAY p_pedido_dig_mest.cod_moeda TO cod_moeda
    WHEN infield(cod_cidade)
         CALL vdp309_popup_cidades() RETURNING p_pedido_dig_ent.cod_cidade
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42841
         DISPLAY p_pedido_dig_ent.cod_cidade TO cod_cidade
    WHEN infield(cod_item)
         LET pa_curr = arr_curr()
         LET sc_curr = scr_line()
         LET p_cod_item_pe = vdp4285_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_cod_item_pe IS NOT NULL
         THEN  IF   p_status = 4
               THEN CURRENT WINDOW IS w_vdp42849
                    LET t_ped_dig_bnf[pa_curr_bnf].cod_item = p_cod_item_pe
                    DISPLAY  t_ped_dig_bnf[pa_curr_bnf].cod_item TO s_ped_dig_bnf[sc_curr_bnf].cod_item
               ELSE CURRENT WINDOW IS w_vdp42842
                    LET t_pedido_dig_item[pa_curr].cod_item = p_cod_item_pe
                    DISPLAY t_pedido_dig_item[pa_curr].cod_item TO s_pedido_dig_item[sc_curr].cod_item
               END IF
         END IF
    WHEN infield(pct_desc_adic) AND p_status = 1
      #  CALL log120_procura_caminho("PAT0150") RETURNING p_comando
      #  RUN p_comando RETURNING p_cancel
      #  LET p_cancel = p_cancel / 256
      #  IF p_cancel = 0
      #  THEN
      #  ELSE PROMPT "\nTecle ENTER para continuar" FOR p_comando
      #       RETURN FALSE
      #  END IF
         CALL vdp4284_controle_peditdesc(p_cod_empresa,
                                         p_pedido_dig_mest.num_pedido,
                                         0 )
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp4284
    WHEN infield(pct_desc_adic) AND p_status = 3
         CALL vdp4284_controle_peditdesc(p_cod_empresa,
                                         p_pedido_dig_mest.num_pedido,
                                         pa_curr)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_vdp42842

    WHEN infield(cod_grade_1)
          CALL log009_popup(6,21,ma_ctr_grade[1].descr_cabec_zoom,
                                 ma_ctr_grade[1].nom_tabela_zoom,
                                 ma_ctr_grade[1].descr_col_1_zoom,
                                 ma_ctr_grade[1].descr_col_2_zoom,
                                 ma_ctr_grade[1].cod_progr_manut,"N","")
               RETURNING t_array_grade[pa_curr_g].cod_grade_1
          CALL log006_exibe_teclas("01 02 03 07", p_versao)
          CURRENT WINDOW IS w_vdp42846
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
          CURRENT WINDOW IS w_vdp42846
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
          CURRENT WINDOW IS w_vdp42846
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
          CURRENT WINDOW IS w_vdp42846
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
          CURRENT WINDOW IS w_vdp42846
          DISPLAY t_array_grade[pa_curr_g].cod_grade_5
               TO s_pedido_dig_grad[sc_curr_g].cod_grade_5

    WHEN infield(ies_preco)
         LET p_pedido_dig_mest.ies_preco = log0830_list_box(15,45,
             'F {Firme}, R {Reajustavel}')
         DISPLAY p_pedido_dig_mest.ies_preco TO ies_preco
    WHEN infield(ies_frete)
         LET p_pedido_dig_mest.ies_frete = log0830_list_box(14,22,
             '1 {CIF Pago}, 2 {CIF Cobrado}, 3 {FOB}, 4 {CIF Infor. Pct.}, 5 {CIF Infor. Unit.}')
         DISPLAY p_pedido_dig_mest.ies_frete TO ies_frete
    WHEN infield(ies_tip_entrega)
         LET p_pedido_dig_mest.ies_tip_entrega = log0830_list_box(16,52,
             '1 {Total}, 2 {Parcial item total}, 3 {Parcial item parcial}')
         DISPLAY p_pedido_dig_mest.ies_tip_entrega TO ies_tip_entrega
    WHEN infield(ies_sit_pedido)
         LET p_pedido_dig_mest.ies_sit_pedido = log0830_list_box(16,53,
             'N {Normal}, B {Bloqueado}, P {Provisorio}, L {Licenciado}')
         DISPLAY p_pedido_dig_mest.ies_sit_pedido TO ies_sit_pedido
    WHEN infield(ies_finalidade)
         LET p_pedido_dig_mest.ies_finalidade = log0830_list_box(17,22,
             '1 {Contrib.(Industr/Comerc)}, 2 {Nao Contrib.}, 3 {Contrib.(Uso/Consumo)}')
         DISPLAY p_pedido_dig_mest.ies_finalidade TO ies_finalidade
    WHEN infield(ies_embal_padrao)
         LET p_pedido_dig_mest.ies_embal_padrao = log0830_list_box(15,56,
             '1 {Padr.Int.}, 2 {Padr.Ext.}, 3 {Sem Padr.}, 4 {Padr.Cx.Int.}, 5 {Padr.Cx.Ext.}, 6 {Padr.Pallet}')
         DISPLAY p_pedido_dig_mest.ies_embal_padrao TO ies_embal_padrao
 END CASE
 END FUNCTION

#----------------------------------#
 FUNCTION vdp4284_busca_num_pedido()
#----------------------------------#
 DEFINE p_num_pedido LIKE pedido_dig_mest.num_pedido

 LET p_num_pedido = NULL

 WHENEVER ERROR CONTINUE
 DECLARE cm_par_vdp CURSOR {WITH HOLD} FOR
 SELECT num_prx_pedido FROM par_vdp
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
    RETURN FALSE
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

 IF sqlca.sqlcode = 0 THEN
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
            RETURN FALSE
         END IF
    ELSE CALL log085_transacao("COMMIT")
         IF   sqlca.sqlcode = 0
         THEN
         ELSE LET p_houve_erro = TRUE
              CALL log003_err_sql("ALTERACAO_2","PAR_VDP")
              CALL log085_transacao("ROLLBACK")
              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("TRANSACAO","ROLLBACK")
                 RETURN FALSE
              END IF
         END IF
    END IF
 ELSE CALL log085_transacao("ROLLBACK")
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("TRANSACAO","ROLLBACK")
         RETURN FALSE
      END IF
 END IF

 CLOSE cm_par_vdp

 WHENEVER ERROR STOP

 RETURN p_num_pedido

 END FUNCTION

#--------------------------------#
 FUNCTION vdp4284_verifica_pedido()
#--------------------------------#
  WHENEVER ERROR CONTINUE

  SELECT pedido_dig_mest.num_pedido FROM pedido_dig_mest
   WHERE pedido_dig_mest.num_pedido = p_pedido_dig_mest.num_pedido AND
         pedido_dig_mest.cod_empresa = p_cod_empresa

  IF sqlca.sqlcode = NOTFOUND
     THEN RETURN false
     ELSE RETURN true
  END IF

  WHENEVER ERROR STOP

END FUNCTION

#-------------------------------------------#
 FUNCTION vdp4284_verifica_natureza_operacao()
#-------------------------------------------#
  WHENEVER ERROR CONTINUE

  SELECT nat_operacao.ies_tip_controle INTO p_ies_tip_controle
    FROM nat_operacao
   WHERE nat_operacao.cod_nat_oper = p_pedido_dig_mest.cod_nat_oper

  IF sqlca.sqlcode = NOTFOUND
  THEN
      RETURN TRUE
  ELSE
      RETURN FALSE
  END IF

  WHENEVER ERROR STOP

END FUNCTION

#------------------------------------#
 FUNCTION vdp4284_verifica_carteira()
#------------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT cod_tip_carteira
    FROM tipo_carteira
   WHERE cod_tip_carteira = p_pedido_dig_mest.cod_tip_carteira
   WHENEVER ERROR STOP

  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF

END FUNCTION

#-------------------------------------#
 FUNCTION vdp4284_verifica_finalidade()
#-------------------------------------#
# altera��o 07/01/2016		      #
# controle eh_contribuinte            #
# para finalidade 2                   #
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
       ELSE IF p_pedido_dig_mest.ies_finalidade = "2" AND
               vdp4283_verifica_neh_contribuinte()
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
 END IF
 END FUNCTION

#-----------------------------------------#
 FUNCTION vdp4284_verifica_neh_contribuinte()
#-----------------------------------------#
# criado em 22/12/2015                    #
#-----------------------------------------#
 DEFINE   p_tip_parametro   CHAR(01)
  WHENEVER ERROR CONTINUE
 
   SELECT vdp_cli_parametro.tip_parametro
      INTO p_tip_parametro
      FROM vdp_cli_parametro
      WHERE vdp_cli_parametro.cliente = p_pedido_dig_mest.cod_cliente and
            vdp_cli_parametro.parametro = "eh_contribuinte     "
      IF sqlca.sqlcode = NOTFOUND
         THEN CALL log0030_mensagem( " Nao Cadastrado na tabela vdp3294. ","excl")
         RETURN false
      ELSE
            IF p_tip_parametro <> "N"
            THEN RETURN false
            ELSE
               RETURN true
            END IF
      END IF   
      WHENEVER ERROR STOP
   
 END FUNCTION     

#------------------------------------#
 FUNCTION vdp4284_verifica_cliente()
#------------------------------------#
 WHENEVER ERROR CONTINUE

 SELECT clientes.nom_cliente,
        cidades.cod_uni_feder,
        clientes.num_cgc_cpf,
        clientes.ins_estadual
   INTO p_nom_cliente,
        p_cod_uni_feder,
        p_num_cgc_cpf,
        p_ins_estadual
   FROM clientes, OUTER cidades
  WHERE clientes.cod_cliente = p_pedido_dig_mest.cod_cliente
    AND cidades.cod_cidade   = clientes.cod_cidade
   WHENEVER ERROR STOP

 IF sqlca.sqlcode = NOTFOUND
 THEN RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION vdp4284_efetiva_inclusao(p_funcao)
#---------------------------------#
 DEFINE p_hora      DATETIME HOUR TO SECOND
 DEFINE p_funcao                CHAR(12)


 WHENEVER ERROR CONTINUE

  DELETE FROM pedido_dig_mest
   WHERE pedido_dig_mest.num_pedido = p_pedido_dig_mest.num_pedido AND
         pedido_dig_mest.cod_empresa = p_cod_empresa

  IF sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("EXCLUSAO", "MESTRE")
       RETURN FALSE
  END IF

  DELETE FROM pedido_dig_obs
   WHERE pedido_dig_obs.num_pedido = p_pedido_dig_mest.num_pedido AND
         pedido_dig_obs.cod_empresa = p_cod_empresa

  IF sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("EXCLUSAO", "OBSERVACAO")
       RETURN FALSE
  END IF

  DELETE FROM pedido_dig_ent
   WHERE pedido_dig_ent.num_pedido = p_pedido_dig_mest.num_pedido AND
         pedido_dig_ent.cod_empresa = p_cod_empresa

  IF sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("EXCLUSAO", "ENTREGA")
       RETURN FALSE
  END IF

  DELETE FROM pedido_dig_item
   WHERE pedido_dig_item.num_pedido = p_pedido_dig_mest.num_pedido AND
         pedido_dig_item.cod_empresa = p_cod_empresa
  IF sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("EXCLUSAO", "ITENS")
       RETURN FALSE
  END IF

  DELETE
    FROM ped_dig_item_bnf
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_pedido_dig_mest.num_pedido
  IF sqlca.sqlcode <> 0 THEN
     LET p_houve_erro = TRUE
     CALL log003_err_sql("EXCLUSAO", "ITENS")
     RETURN FALSE
  END IF

  DELETE FROM ped_itens_rem
   WHERE ped_itens_rem.num_pedido = p_pedido_dig_mest.num_pedido AND
         ped_itens_rem.cod_empresa = p_cod_empresa

  IF sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("EXCLUSAO", "ITENS_REMESSA")
       RETURN FALSE
  END IF

  DELETE
    FROM ped_dig_it_nat
   WHERE num_pedido  = p_pedido_dig_mest.num_pedido
     AND cod_empresa = p_cod_empresa
  IF sqlca.sqlcode <> 0 THEN
     LET p_houve_erro = TRUE
     CALL log003_err_sql("EXCLUSAO", "ITENS_NAT")
     RETURN FALSE
  END IF

  DELETE FROM ped_dig_item_desc
   WHERE ped_dig_item_desc.num_pedido  = p_pedido_dig_mest.num_pedido
     AND ped_dig_item_desc.cod_empresa = p_cod_empresa

  IF sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("EXCLUSAO", "PEDIDO_DIG_ITEM_DESC")
       RETURN FALSE
  END IF

  DELETE FROM pedido_dig_comis
      WHERE pedido_dig_comis.cod_empresa = p_cod_empresa
     AND  pedido_dig_comis.num_pedido = p_pedido_dig_mest.num_pedido
     #AND pedido_dig_comis.cod_repres_3 = m_cod_repres_3
   #pedido_dig_comis

  DELETE FROM vendor_pedido
  WHERE vendor_pedido.cod_empresa = p_cod_empresa
    AND vendor_pedido.num_pedido  = p_pedido_dig_mest.num_pedido

  IF sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("EXCLUSAO", "VENDOR_PEDIDO")
       RETURN FALSE
  END IF

  DELETE FROM vdp_ped_item_compl
  WHERE empresa = p_cod_empresa
    AND pedido  = p_pedido_dig_mest.num_pedido

  IF sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("EXCLUSAO", "VDP_PED_ITEM_COMPL")
       RETURN FALSE
  END IF

  LET p_hora                               = CURRENT
  LET p_pedido_dig_mest.hora_digitacao     = p_hora
  LET p_pedido_dig_mest.dat_liberacao_fin  = NULL
  LET p_pedido_dig_mest.hora_liberacao_fin = NULL
  LET p_pedido_dig_mest.dat_liberacao_com  = NULL
  LET p_pedido_dig_mest.hora_liberacao_com = NULL
  LET p_pedido_dig_mest.pct_desc_bruto     = 0
  LET p_pedido_dig_mest.num_versao_lista   = 0
  LET p_pedido_dig_mest.nom_usuario        = p_user

  WHENEVER ERROR CONTINUE
  INSERT INTO pedido_dig_mest VALUES (p_pedido_dig_mest.*)
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("INCLUSAO", "MESTRE")
       RETURN FALSE
  END IF

  CALL vdp4284_inclui_pedido_dig_comis()

  IF p_ped_item_nat.cod_nat_oper IS NOT NULL AND
     p_ped_item_nat.cod_nat_oper <> " "      AND
     p_ped_item_nat.cod_cnd_pgto IS NOT NULL AND
     p_ped_item_nat.cod_cnd_pgto <> " "      THEN

     WHENEVER ERROR CONTINUE
     INSERT INTO ped_dig_it_nat VALUES ( p_pedido_dig_mest.cod_empresa,
                                         p_pedido_dig_mest.num_pedido,
                                         0,"N","N",
                                         p_ped_item_nat.cod_cliente,
                                         p_ped_item_nat.cod_nat_oper,
                                         p_ped_item_nat.cod_cnd_pgto)
     WHENEVER ERROR STOP
     IF SQLCA.sqlcode <> 0 THEN
        LET p_houve_erro = TRUE
        CALL log003_err_sql("INCLUSAO","PED_DIG_IT_NAT")
        RETURN FALSE
     END IF
  END IF

  IF p_pedido_dig_ent.num_sequencia IS NULL AND
     p_pedido_dig_ent.end_entrega   IS NULL
  THEN
  ELSE IF   p_pedido_dig_ent.num_sequencia IS NULL
       THEN LET p_pedido_dig_ent.num_sequencia = 0
       END IF
       LET p_pedido_dig_ent.cod_empresa = p_pedido_dig_mest.cod_empresa
       LET p_pedido_dig_ent.num_pedido  = p_pedido_dig_mest.num_pedido

       WHENEVER ERROR CONTINUE
       INSERT INTO pedido_dig_ent VALUES (p_pedido_dig_ent.*)
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0
       THEN LET p_houve_erro = TRUE
            CALL log003_err_sql("INCLUSAO", "ENTREGA")
            RETURN FALSE
       END IF
  END IF

  IF p_pedido_dig_obs.tex_observ_1 IS NULL AND
     p_pedido_dig_obs.tex_observ_2 IS NULL
  THEN
  ELSE LET p_pedido_dig_obs.cod_empresa = p_pedido_dig_mest.cod_empresa
       LET p_pedido_dig_obs.num_pedido  = p_pedido_dig_mest.num_pedido

       WHENEVER ERROR CONTINUE
       INSERT INTO pedido_dig_obs VALUES (p_pedido_dig_obs.*)
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0
       THEN LET p_houve_erro = TRUE
            CALL log003_err_sql("INCLUSAO", "OBSERVACAO")
            RETURN FALSE
       END IF
  END IF

  CALL vdp4284_inclui_ped_dig_item_desc()

  LET p_count = 0
  FOR pa_curr = 1 TO 500
     IF t_pedido_dig_item[pa_curr].cod_item IS NOT NULL AND
        t_pedido_dig_item[pa_curr].cod_item <> " " THEN
        LET p_pedido_dig_item.num_sequencia   = pa_curr
        LET p_pedido_dig_item.cod_item        =
            t_pedido_dig_item[pa_curr].cod_item
        LET p_pedido_dig_item.qtd_pecas_solic =
            t_pedido_dig_item[pa_curr].qtd_pecas_solic
        LET p_pedido_dig_item.pre_unit        =
            t_pedido_dig_item[pa_curr].pre_unit
        LET p_pedido_dig_item.pct_desc_adic   =
            t_pedido_dig_item[pa_curr].pct_desc_adic
        LET p_pedido_dig_item.prz_entrega     =
            t_pedido_dig_item[pa_curr].prz_entrega
        LET p_pedido_dig_item.val_seguro_unit =
            t_pedido_dig_item[pa_curr].val_seguro_unit
        LET p_pedido_dig_item.val_frete_unit  =
            t_pedido_dig_item[pa_curr].val_frete_unit
#       LET p_pedido_dig_item.val_seguro_unit = 0
#       LET p_pedido_dig_item.val_frete_unit  = 0

        IF p_pedido_dig_item.qtd_pecas_solic IS NULL THEN
           LET p_pedido_dig_item.qtd_pecas_solic = 0
        END IF

        IF p_pedido_dig_item.pre_unit        IS NULL THEN
           LET p_pedido_dig_item.pre_unit        = 0
        END IF

        IF p_pedido_dig_item.pct_desc_adic   IS NULL THEN
           LET p_pedido_dig_item.pct_desc_adic   = 0
        END IF

        IF p_pedido_dig_item.pct_desc_bruto  IS NULL THEN
           LET p_pedido_dig_item.pct_desc_bruto  = 0
        END IF

        LET p_pedido_dig_item.cod_empresa = p_cod_empresa

        WHENEVER ERROR CONTINUE
        INSERT INTO pedido_dig_item VALUES (p_pedido_dig_item.*)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO", "ITENS")
           RETURN FALSE
        END IF

        IF vdp4284_existe_nat_oper_refer() THEN
           WHENEVER ERROR CONTINUE
           INSERT INTO ped_dig_it_nat VALUES
              ( p_cod_empresa, p_pedido_dig_mest.num_pedido, pa_curr, "N", "N",
                "", m_cod_nat_oper_ref, p_pedido_dig_mest.cod_cnd_pgto )
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              LET p_houve_erro = TRUE
              CALL log003_err_sql("INCLUSAO","PED_ITEM_NAT")
              RETURN FALSE
           END IF
        END IF

        IF   p_ies_tip_controle = "2"  THEN
             IF   vdp4284_insert_ped_itens_rem() THEN
             ELSE
                  RETURN FALSE
             END IF
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
           RETURN FALSE
        END IF

     ELSE EXIT FOR
     END IF
  END FOR

  FOR pa_curr = 1 TO 99
     IF t_ped_dig_bnf[pa_curr].cod_item IS NOT NULL THEN

        WHENEVER ERROR CONTINUE
        INSERT INTO ped_dig_item_bnf VALUES (p_pedido_dig_mest.cod_empresa,
                                     p_pedido_dig_mest.num_pedido,
                                     pa_curr,
                                     t_ped_dig_bnf[pa_curr].cod_item,
                                     t_ped_dig_bnf[pa_curr].qtd_pecas_solic,
                                     t_ped_dig_bnf[pa_curr].pre_unit,
                                     t_ped_dig_bnf[pa_curr].pct_desc_adic,
                                     0,
                                     t_ped_dig_bnf[pa_curr].prz_entrega)
           WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("INCLUSAO", "ITENS_BNF")
           LET p_houve_erro = TRUE
        END IF
      ELSE
         EXIT FOR
      END IF
   END FOR

  IF NOT  vdp4284_inclui_grade() THEN
      RETURN FALSE
  END IF

  CALL vdp4284_inclui_vendor_pedido()

  IF  NOT vdp4284_inclui_ped_info_compl(p_funcao) THEN
      RETURN FALSE
  END IF
  IF m_informa_consig_ad = 'S' THEN
     CALL vdp4284_inclui_ped_info_compl_consig_ad(p_funcao)
  END IF

  WHENEVER ERROR STOP
  RETURN TRUE
END FUNCTION

#----------------------------------------#
 FUNCTION vdp4284_inclui_ped_info_compl(p_funcao)
#----------------------------------------#
  DEFINE p_funcao   CHAR(12)
     WHENEVER ERROR CONTINUE
       SELECT 1
         FROM ped_info_compl
        WHERE empresa         = p_cod_empresa
          AND pedido          = p_pedido_dig_mest.num_pedido
          AND campo           = 'linha_produto'
     WHENEVER ERROR STOP

     IF  SQLCA.sqlcode <> 0 THEN
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
             RETURN FALSE
         END IF
     ELSE
         WHENEVER ERROR CONTINUE
           UPDATE ped_info_compl
              SET parametro_texto = m_linha_produto
            WHERE empresa = p_cod_empresa
              AND pedido  = p_pedido_dig_mest.num_pedido
              AND campo   = 'linha_produto'
         WHENEVER ERROR STOP

         IF  SQLCA.sqlcode <> 0 THEN
             LET p_houve_erro = TRUE
             CALL log003_err_sql("ATUALIZACAO","PED_INFO_COMPL")
             RETURN FALSE
         END IF
     END IF

IF p_funcao = 'INCLUSAO' THEN
     CALL vdpy154_exclui_ped_info_txt_expedicao(p_pedido_dig_mest.num_pedido)

     IF m_ies_txt_exped = 'S' THEN
        IF NOT vdpy154_grava_txt_obs_exped(p_pedido_dig_mest.num_pedido) THEN
           RETURN FALSE
        END IF
     END IF
END if
     RETURN TRUE
 END FUNCTION

#-------------------------------#
 FUNCTION vdp4284_inclui_grade()
#-------------------------------#
  WHENEVER ERROR CONTINUE
   DELETE FROM ped_dig_itens_grad
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_pedido_dig_mest.num_pedido

   IF sqlca.sqlcode <> 0
   THEN LET p_houve_erro = TRUE
        CALL log003_err_sql("EXCLUSAO", "PED_DIG_ITENS_GRADE")
        RETURN FALSE
   END IF
  WHENEVER ERROR STOP

  FOR pa_curr_g = 1 TO  500
      IF   t_pedido_dig_grad[pa_curr_g].cod_grade_1 IS NOT NULL AND
           t_pedido_dig_grad[pa_curr_g].cod_grade_1 != "               "
      THEN
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
          INSERT INTO ped_dig_itens_grad VALUES (p_cod_empresa,
                                                 t_pedido_dig_grad[pa_curr_g].*)
          WHENEVER ERROR STOP
          IF   sqlca.sqlcode <> 0
          THEN
               LET p_houve_erro = TRUE
               CALL log003_err_sql("INCLUSAO","PED_DIG_ITENS_GRADE")
               RETURN FALSE
          END IF

      END IF
  END FOR

RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION vdp4284_insert_ped_itens_rem()
#---------------------------------------#
  LET p_ped_itens_rem.cod_empresa               = p_cod_empresa
  LET p_ped_itens_rem.num_pedido                = p_pedido_dig_mest.num_pedido
  LET p_ped_itens_rem.num_sequencia             = pa_curr
  LET p_ped_itens_rem.dat_emis_nf_usina         =
      t_ped_itens_rem[pa_curr].dat_emis_nf_usina
  LET p_ped_itens_rem.dat_retorno_prev          =
      t_ped_itens_rem[pa_curr].dat_retorno_prev
  LET p_ped_itens_rem.cod_motivo_remessa        =
      t_ped_itens_rem[pa_curr].cod_motivo_remessa
  LET p_ped_itens_rem.val_estoque               =
      t_ped_itens_rem[pa_curr].val_estoque
  LET p_ped_itens_rem.cod_area_negocio          =
      t_ped_itens_rem[pa_curr].cod_area_negocio
  LET p_ped_itens_rem.cod_lin_negocio           =
      t_ped_itens_rem[pa_curr].cod_lin_negocio
  LET p_ped_itens_rem.num_conta                 =
      t_ped_itens_rem[pa_curr].num_conta
  LET p_ped_itens_rem.tex_observ                =
      t_ped_itens_rem[pa_curr].tex_observ
  LET p_ped_itens_rem.num_pedido_compra         =
      t_ped_itens_rem[pa_curr].num_pedido_compra
  WHENEVER ERROR CONTINUE
  INSERT INTO ped_itens_rem VALUES (p_ped_itens_rem.*)
  WHENEVER ERROR STOP
  IF   sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       CALL log003_err_sql("INCLUSAO","PED_ITENS_REM")
       RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION

#--------------------------------------#
FUNCTION vdp4284_entrada_ped_itens_rem()
#--------------------------------------#
  INITIALIZE p_ped_itens_rem.*   TO NULL

  LET p_ped_itens_rem.cod_empresa   = p_cod_empresa
  LET p_ped_itens_rem.num_pedido    = p_pedido_dig_mest.num_pedido
  LET p_ped_itens_rem.num_sequencia = pa_curr

  IF   t_ped_itens_rem[pa_curr].num_sequencia > 0       AND
       t_ped_itens_rem[pa_curr].num_sequencia = pa_curr
  THEN LET p_ped_itens_rem.dat_emis_nf_usina  =
           t_ped_itens_rem[pa_curr].dat_emis_nf_usina
       LET p_ped_itens_rem.dat_retorno_prev   =
           t_ped_itens_rem[pa_curr].dat_retorno_prev
       LET p_ped_itens_rem.cod_motivo_remessa =
           t_ped_itens_rem[pa_curr].cod_motivo_remessa
       LET p_ped_itens_rem.val_estoque        =
           t_ped_itens_rem[pa_curr].val_estoque
       LET p_ped_itens_rem.cod_area_negocio   =
           t_ped_itens_rem[pa_curr].cod_area_negocio
       LET p_ped_itens_rem.cod_lin_negocio    =
           t_ped_itens_rem[pa_curr].cod_lin_negocio
       LET p_ped_itens_rem.num_conta          =
           t_ped_itens_rem[pa_curr].num_conta
       LET p_ped_itens_rem.tex_observ         =
           t_ped_itens_rem[pa_curr].tex_observ
       LET p_ped_itens_rem.num_pedido_compra  =
           t_ped_itens_rem[pa_curr].num_pedido_compra
  END IF

  CALL log006_exibe_teclas("01 02 03 07", p_versao)
  WHENEVER ERROR CONTINUE
  CALL log130_procura_caminho("vdp42845") RETURNING p_comando
  OPEN WINDOW w_vdp42845 AT 2,2 WITH FORM p_comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  WHENEVER ERROR STOP
  CURRENT WINDOW IS w_vdp42845

  DISPLAY t_pedido_dig_item[pa_curr].cod_item TO cod_item
  DISPLAY p_pedido_dig_mest.cod_cliente       TO cod_cliente
  DISPLAY p_nom_cliente                       TO nom_cliente
  DISPLAY BY NAME p_ped_itens_rem.*

  CALL vdp4284_verifica_motivo_remessa()      RETURNING p_status
  CALL vdp4284_verifica_area_negocio()        RETURNING p_status
  CALL vdp4284_verifica_linha_negocio()       RETURNING p_status

  INPUT BY NAME p_ped_itens_rem.* WITHOUT DEFAULTS

    BEFORE FIELD dat_emis_nf_usina
      CALL vdp4284_apaga_zoom()
    AFTER FIELD dat_emis_nf_usina
          IF   p_ped_itens_rem.dat_emis_nf_usina > TODAY
          THEN CALL log0030_mensagem( " Data de Emiss�o da NF maior que data atual. ","excl")
               NEXT FIELD dat_emis_nf_usina
          END IF

    BEFORE FIELD cod_motivo_remessa
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD cod_motivo_remessa
           IF   vdp4284_verifica_motivo_remessa() = FALSE
           THEN CALL log0030_mensagem( " Motivo n�o cadastrado.","excl")
                NEXT FIELD cod_motivo_remessa
           END IF
      CALL vdp4284_apaga_zoom()

    AFTER  FIELD val_estoque
           IF   p_ped_itens_rem.val_estoque IS NULL
           THEN CALL log0030_mensagem( " Valor Estoque Inv�lido ","excl")
                NEXT FIELD val_estoque
           END IF

    BEFORE FIELD cod_area_negocio
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD cod_area_negocio
           IF   p_ped_itens_rem.cod_area_negocio IS NULL
           THEN CALL log0030_mensagem( " C�digo �rea Neg�cio Inv�lido ","excl")
                NEXT FIELD cod_area_negocio
           END IF
           IF   vdp4284_verifica_area_negocio() = FALSE
           THEN CALL log0030_mensagem( " �rea de Neg�cio n�o cadastrada ","excl")
                NEXT FIELD cod_area_negocio
           END IF
      CALL vdp4284_apaga_zoom()

    BEFORE FIELD cod_lin_negocio
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD cod_lin_negocio
           IF   p_ped_itens_rem.cod_lin_negocio IS NULL
           THEN CALL log0030_mensagem( " C�digo Linha Neg�cio Inv�lido ","excl")
                NEXT FIELD cod_lin_negocio
           END IF
           IF   vdp4284_verifica_linha_negocio() = FALSE
           THEN CALL log0030_mensagem( " Linha de Neg�cio n�o cadastrada ","excl")
                NEXT FIELD cod_lin_negocio
           END IF
           IF   vdp4284_verifica_area_lin_negocio() = FALSE
           THEN CALL log0030_mensagem( " Relacionamento �rea x Linha de neg�cio n�o cadastrado ","excl")
                NEXT FIELD cod_lin_negocio
           END IF
      CALL vdp4284_apaga_zoom()

    BEFORE FIELD num_conta
      CALL vdp4284_mostra_zoom()

    AFTER  FIELD num_conta
           IF   p_ped_itens_rem.num_conta IS NOT NULL
           THEN CALL con088_verifica_cod_conta(p_cod_empresa,
                                               p_ped_itens_rem.num_conta,
                                               "S",
                                               " ")
                     RETURNING p_plano_contas.*, p_plano
                IF   p_plano = FALSE
                THEN CALL log0030_mensagem( "Conta Cont�bil n�o Cadastrada","excl")
                     NEXT FIELD num_conta
                END IF
           END IF
      CALL vdp4284_apaga_zoom()

    AFTER  FIELD num_pedido_compra
           IF   p_ies_item_em_terc_ped = "S"
           THEN IF   vdp4284_verifica_pedido_compra() = FALSE
                THEN NEXT FIELD num_pedido_compra
                END IF
           END IF

    ON KEY (control-w, f1)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
           CALL vdp4284_help_rem()

    ON KEY (control-z, f4)
           CALL vdp4284_popup_rem()
  END INPUT

  CLOSE WINDOW w_vdp42845
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp42842

  IF int_flag <> 0 THEN
     LET int_flag = 0
     RETURN FALSE
  END IF

  LET t_ped_itens_rem[pa_curr].num_sequencia      =
      p_ped_itens_rem.num_sequencia
  LET t_ped_itens_rem[pa_curr].dat_emis_nf_usina  =
      p_ped_itens_rem.dat_emis_nf_usina
  LET t_ped_itens_rem[pa_curr].dat_retorno_prev   =
      p_ped_itens_rem.dat_retorno_prev
  LET t_ped_itens_rem[pa_curr].cod_motivo_remessa =
      p_ped_itens_rem.cod_motivo_remessa
  LET t_ped_itens_rem[pa_curr].val_estoque        =
      p_ped_itens_rem.val_estoque
  LET t_ped_itens_rem[pa_curr].cod_area_negocio   =
      p_ped_itens_rem.cod_area_negocio
  LET t_ped_itens_rem[pa_curr].cod_lin_negocio    =
      p_ped_itens_rem.cod_lin_negocio
  LET t_ped_itens_rem[pa_curr].num_conta          =
      p_ped_itens_rem.num_conta
  LET t_ped_itens_rem[pa_curr].tex_observ         =
      p_ped_itens_rem.tex_observ
  LET t_ped_itens_rem[pa_curr].num_pedido_compra  =
      p_ped_itens_rem.num_pedido_compra

  RETURN TRUE
END FUNCTION

#---------------------------#
 FUNCTION vdp4284_help_rem()
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
 FUNCTION vdp4284_popup_rem()
#----------------------------#
  DEFINE p_mot_rem      LIKE ped_itens_rem.cod_motivo_remessa

  CASE
    WHEN infield(cod_motivo_remessa)
         LET p_mot_rem = sup260_popup_motivo_remessa(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_vdp42845
         IF   p_mot_rem IS NOT NULL
         THEN LET p_ped_itens_rem.cod_motivo_remessa = p_mot_rem
              DISPLAY BY NAME p_ped_itens_rem.cod_motivo_remessa
         END IF
  END CASE
END FUNCTION

#------------------------------------------#
 FUNCTION vdp4284_verifica_motivo_remessa()
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
 FUNCTION vdp4284_verifica_area_negocio()
#----------------------------------------#
  DEFINE p_den_area_negocio LIKE area_negocio.den_area_negocio

  INITIALIZE p_den_area_negocio TO NULL

  WHENEVER ERROR CONTINUE
  SELECT den_area_negocio INTO p_den_area_negocio
    FROM area_negocio
   WHERE area_negocio.cod_empresa  = p_cod_empresa
     AND area_negocio.cod_area_negocio = p_ped_itens_rem.cod_area_negocio
  WHENEVER ERROR STOP

  IF   sqlca.sqlcode = 0
  THEN
      DISPLAY p_den_area_negocio TO den_area_negocio
  ELSE
      RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION
#-----------------------------------------#
 FUNCTION vdp4284_verifica_linha_negocio()
#-----------------------------------------#
  DEFINE p_den_lin_negocio LIKE linha_negocio.den_lin_negocio

  INITIALIZE p_den_lin_negocio TO NULL

  WHENEVER ERROR CONTINUE
  SELECT den_lin_negocio INTO p_den_lin_negocio
    FROM linha_negocio
   WHERE linha_negocio.cod_empresa     = p_cod_empresa
     AND linha_negocio.cod_lin_negocio = p_ped_itens_rem.cod_lin_negocio
  WHENEVER ERROR STOP

  IF   sqlca.sqlcode = 0
  THEN
       DISPLAY p_den_lin_negocio TO den_lin_negocio
  ELSE
       RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION

#--------------------------------------------#
 FUNCTION vdp4284_verifica_area_lin_negocio()
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
      LET l_soma = 0
   END IF

  IF l_soma > 0
  THEN
      RETURN TRUE
  ELSE
      RETURN FALSE
  END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION vdp4284_verifica_pedido_compra()
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
      INITIALIZE p_cgc_fornecedor  TO NULL
   END IF

   WHENEVER ERROR CONTINUE
   SELECT cod_fornecedor
     INTO p_cod_fornecedor
     FROM fornecedor
    WHERE num_cgc_cpf = p_cgc_fornecedor
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log0030_mensagem( "Fornecedor n�o cadastrado na tabela de fornecedores.","excl")
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
      CALL log0030_mensagem( "Pedido/Fornecedor n�o cadastrado na tabela pedido_sup.","excl")
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
   IF sqlca.sqlcode <> 0 THEN
      INITIALIZE p_qtd_saldo_item_terc  TO NULL
   END IF

   IF p_qtd_saldo_item_terc IS NULL OR
      p_qtd_saldo_item_terc = " "   THEN
      LET p_qtd_saldo_item_terc = 0
      CALL log0030_mensagem( "Item do Ped. Comp. n�o cadastrado na tabela ordem_sup.","excl")
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#---------------------------------------#
 FUNCTION vdp4284_modificacao_pedido()
#---------------------------------------#

  IF vdp4284_cursor_for_update() THEN
    LET p_pedido_dig_mestr.* = p_pedido_dig_mest.*
    LET p_pedido_dig_obsr.*  = p_pedido_dig_obs.*
    LET p_pedido_dig_entr.*  = p_pedido_dig_ent.*
    LET p_tela               = 1
    LET p_flag               = 1
    LET p_erro               = TRUE

    CALL vdpy154_carrega_txt_expedicao(p_pedido_dig_mest.num_pedido, 'ped_info_compl')

    CALL vdp4284_carrega_dados()

    WHILE TRUE
      CASE
         WHEN p_tela = 1
              IF vdp4284_entrada_dados_mestr("MODIFICACAO") THEN
                 LET p_tela = 3 #2
              ELSE
                 LET p_status = 1
                 EXIT WHILE
              END IF

         WHEN p_tela = 2
              IF vdp4284_entrada_dados_intermediario() THEN
                 LET p_tela = 3
              ELSE
                 LET p_tela = 1
              END IF

         WHEN p_tela = 3
              IF vdp4284_entrada_dados_ent_obs("MODIFICACAO") THEN
                 LET p_tela = 4
              ELSE
                 LET p_tela = 1 #2
              END IF

         WHEN p_tela = 4
              IF vdp4284_entrada_dados_item("MODIFICACAO") THEN
                 LET p_tela = 6 #5
              ELSE
                 LET p_tela = 3
              END IF

         WHEN p_tela = 5
              IF vdp4284_entrada_dados_item_bnf("MODIFICACAO") THEN
                 LET p_tela = 6
              ELSE
                 LET p_tela = 4
              END IF

         WHEN p_tela = 6
              IF vdp4284_total("MODIFICACAO") THEN
                 LET p_status = 0
                 EXIT WHILE
              ELSE
                 LET p_tela = 4 #5
              END IF
      END CASE
    END WHILE

    IF p_status = 0 THEN
       IF vdp4284_efetiva_inclusao("MODIFICACAO") THEN
          CALL log006_exibe_teclas("01 02", p_versao)
          CURRENT WINDOW IS w_vdp4284
          CALL vdp4284_exibe_dados()
          CALL log085_transacao("COMMIT")
          IF sqlca.sqlcode = 0 THEN
             LET p_audit_vdp.texto = "ALTERACAO - PEDIDOS NO LOTE "
             CALL vdp876_monta_audit_vdp(p_cod_empresa,
                                         p_pedido_dig_mest.num_pedido,
                                         "M",
                                         "A",
                                         p_audit_vdp.texto,
                                         "vdp4284",
                                         TODAY,
                                         TIME,
                                         p_user)
             MESSAGE " Modificacao efetuada com sucesso " ATTRIBUTE(REVERSE)
          ELSE
             CALL log003_err_sql("ALTERACAO ","PEDIDOS  ")
             CALL log085_transacao("ROLLBACK")
          END IF
       ELSE
          CALL log0030_mensagem( " Modificacao Cancelada 1","excl")
          CALL log085_transacao("ROLLBACK")
       END IF
    ELSE
       LET p_pedido_dig_mest.* = p_pedido_dig_mestr.*
       LET p_pedido_dig_obs.*  = p_pedido_dig_obsr.*
       LET p_pedido_dig_ent.*  = p_pedido_dig_entr.*
       CALL log006_exibe_teclas("01 02", p_versao)
       CURRENT WINDOW IS w_vdp4284
       LET p_pedido_dig_mest.*   = p_pedido_dig_mestr.*
       CALL vdp4284_exibe_dados()
       CALL log0030_mensagem( " Modificacao Cancelada 2","excl")
       CALL log085_transacao("ROLLBACK")
    END IF
  ELSE
     CALL log006_exibe_teclas("01 02", p_versao)
     CURRENT WINDOW IS w_vdp4284
     LET p_pedido_dig_mest.*   = p_pedido_dig_mestr.*
     CALL vdp4284_exibe_dados()
     CALL log0030_mensagem( " Modificacao Cancelada 3","excl")
     CALL log085_transacao("ROLLBACK")
  END IF
END FUNCTION

#-------------------------------#
 FUNCTION vdp4284_carrega_dados()
#-------------------------------#
  INITIALIZE  t_pedido_dig_item,
              t_ped_itens_rem,
              t_array_grade   TO NULL
 WHENEVER ERROR CONTINUE
 SELECT parametro_texto
   INTO m_linha_produto
   FROM ped_info_compl
  WHERE empresa = p_cod_empresa
    AND pedido  = p_pedido_dig_mest.num_pedido
    AND campo   = 'linha_produto'
 WHENEVER ERROR STOP
 IF  SQLCA.sqlcode <> 0 THEN
     LET m_linha_produto = " "
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pedido_dig_ent.* INTO p_pedido_dig_ent.*
   FROM pedido_dig_ent
  WHERE pedido_dig_ent.num_pedido = p_pedido_dig_mest.num_pedido AND
        pedido_dig_ent.cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_pedido_dig_ent.*  TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pedido_dig_obs.* INTO p_pedido_dig_obs.*
   FROM pedido_dig_obs
  WHERE pedido_dig_obs.num_pedido = p_pedido_dig_mest.num_pedido AND
        pedido_dig_obs.cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_pedido_dig_obs.*  TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 SELECT vendor_pedido.* INTO p_vendor_pedido.*
   FROM vendor_pedido
  WHERE vendor_pedido.cod_empresa = p_cod_empresa
    AND vendor_pedido.num_pedido = p_pedido_dig_mest.num_pedido
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_vendor_pedido.*  TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 SELECT *
   INTO p_ped_item_nat.*
   FROM ped_dig_it_nat
  WHERE cod_empresa    = p_cod_empresa
    AND num_pedido     = p_pedido_dig_mest.num_pedido
    AND num_sequencia  = 0
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_ped_item_nat.*  TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cq_ped_dig_item_desc CURSOR FOR
  SELECT num_pedido,
         num_sequencia,
         pct_desc_1 ,
         pct_desc_2 ,
         pct_desc_3 ,
         pct_desc_4 ,
         pct_desc_5 ,
         pct_desc_6 ,
         pct_desc_7 ,
         pct_desc_8 ,
         pct_desc_9 ,
         pct_desc_10
    FROM ped_dig_item_desc
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_pedido_dig_mest.num_pedido
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","cq_ped_dig_item_desc")
    RETURN
 END IF

 LET p_qtd_item = 1

 WHENEVER ERROR CONTINUE
 FOREACH cq_ped_dig_item_desc INTO t_ped_dig_item_desc[p_qtd_item].*
   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
      CALL log003_err_sql("FOREACH","cq_ped_dig_item_desc")
      RETURN
   END IF
   LET p_qtd_item = p_qtd_item + 1
   WHENEVER ERROR CONTINUE
 END FOREACH
 WHENEVER ERROR STOP
 FREE cq_ped_dig_item_desc

 WHENEVER ERROR CONTINUE
 DECLARE c_pedido_dig_item CURSOR FOR
  SELECT * FROM pedido_dig_item
   WHERE pedido_dig_item.num_pedido  = p_pedido_dig_mest.num_pedido AND
         pedido_dig_item.cod_empresa = p_cod_empresa
   ORDER BY num_sequencia
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","c_pedido_dig_item")
    RETURN
 END IF

 CALL set_count(0)
 LET p_qtd_item = 1

 WHENEVER ERROR CONTINUE
 FOREACH c_pedido_dig_item INTO p_pedido_dig_item.*
      IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("FOREACH","c_pedido_dig_item")
         RETURN
      END IF
  LET t_pedido_dig_item[p_qtd_item].cod_item        =
      p_pedido_dig_item.cod_item
  LET t_pedido_dig_item[p_qtd_item].qtd_pecas_solic =
      p_pedido_dig_item.qtd_pecas_solic
  LET t_pedido_dig_item[p_qtd_item].pre_unit        =
      p_pedido_dig_item.pre_unit
  LET t_pedido_dig_item[p_qtd_item].pct_desc_adic   =
      p_pedido_dig_item.pct_desc_adic
  LET t_pedido_dig_item[p_qtd_item].prz_entrega     =
      p_pedido_dig_item.prz_entrega
  LET t_pedido_dig_item[p_qtd_item].val_frete_unit  =
      p_pedido_dig_item.val_frete_unit
  LET t_pedido_dig_item[p_qtd_item].val_seguro_unit =
      p_pedido_dig_item.val_seguro_unit

   WHENEVER ERROR CONTINUE
  SELECT num_sequencia,
         dat_emis_nf_usina,
         dat_retorno_prev,
         cod_motivo_remessa,
         val_estoque,
         cod_area_negocio,
         cod_lin_negocio,
         num_conta,
         tex_observ,
         num_pedido_compra
    INTO t_ped_itens_rem[p_qtd_item].num_sequencia,
         t_ped_itens_rem[p_qtd_item].dat_emis_nf_usina,
         t_ped_itens_rem[p_qtd_item].dat_retorno_prev,
         t_ped_itens_rem[p_qtd_item].cod_motivo_remessa,
         t_ped_itens_rem[p_qtd_item].val_estoque,
         t_ped_itens_rem[p_qtd_item].cod_area_negocio,
         t_ped_itens_rem[p_qtd_item].cod_lin_negocio,
         t_ped_itens_rem[p_qtd_item].num_conta,
         t_ped_itens_rem[p_qtd_item].tex_observ,
         t_ped_itens_rem[p_qtd_item].num_pedido_compra
    FROM ped_itens_rem
   WHERE cod_empresa   = p_pedido_dig_item.cod_empresa
     AND num_pedido    = p_pedido_dig_item.num_pedido
     AND num_sequencia = p_pedido_dig_item.num_sequencia
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      INITIALIZE t_ped_itens_rem[p_qtd_item].num_sequencia,
           t_ped_itens_rem[p_qtd_item].dat_emis_nf_usina,
           t_ped_itens_rem[p_qtd_item].dat_retorno_prev,
           t_ped_itens_rem[p_qtd_item].cod_motivo_remessa,
           t_ped_itens_rem[p_qtd_item].val_estoque,
           t_ped_itens_rem[p_qtd_item].cod_area_negocio,
           t_ped_itens_rem[p_qtd_item].cod_lin_negocio,
           t_ped_itens_rem[p_qtd_item].num_conta,
           t_ped_itens_rem[p_qtd_item].tex_observ,
           t_ped_itens_rem[p_qtd_item].num_pedido_compra  TO NULL
   END IF

  LET p_qtd_item = p_qtd_item + 1
   WHENEVER ERROR CONTINUE

 END FOREACH
   WHENEVER ERROR STOP
   FREE c_pedido_dig_item

   WHENEVER ERROR CONTINUE
   DECLARE cq_itens_bnf CURSOR FOR
    SELECT *
      FROM ped_dig_item_bnf
     WHERE cod_empresa    = p_cod_empresa
       AND num_pedido     = p_pedido_dig_mest.num_pedido
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","cq_itens_bnf")
      RETURN
   END IF

   LET p_count_bnf  = 0
   WHENEVER ERROR CONTINUE
   FOREACH cq_itens_bnf INTO p_ped_dig_item_bnf.*
      IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("FOREACH","cq_itens_bnf")
         RETURN
      END IF
      LET p_count_bnf  = p_count_bnf + 1

      LET t_ped_dig_bnf[p_count_bnf].cod_item         =
          p_ped_dig_item_bnf.cod_item
      LET t_ped_dig_bnf[p_count_bnf].qtd_pecas_solic  =
          p_ped_dig_item_bnf.qtd_pecas_solic
      LET t_ped_dig_bnf[p_count_bnf].pre_unit         =
          p_ped_dig_item_bnf.pre_unit
      LET t_ped_dig_bnf[p_count_bnf].pct_desc_adic    =
          p_ped_dig_item_bnf.pct_desc_adic
      LET t_ped_dig_bnf[p_count_bnf].prz_entrega      =
          p_ped_dig_item_bnf.prz_entrega

      WHENEVER ERROR CONTINUE
      SELECT den_item
        INTO t_ped_dig_bnf[p_count_bnf].den_item
        FROM item
       WHERE cod_empresa    = p_cod_empresa
         AND cod_item       = p_ped_dig_item_bnf.cod_item
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         LET t_ped_dig_bnf[p_count_bnf].den_item = " "
      END IF

      WHENEVER ERROR CONTINUE
   END FOREACH
   WHENEVER ERROR STOP
   FREE cq_itens_bnf

  WHENEVER ERROR CONTINUE
  DECLARE c_ped_dig_itens_gr CURSOR FOR
   SELECT *
     FROM ped_dig_itens_grad
    WHERE ped_dig_itens_grad.num_pedido  = p_pedido_dig_mest.num_pedido
      AND ped_dig_itens_grad.cod_empresa = p_cod_empresa
    ORDER BY num_sequencia
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","c_ped_dig_itens_gr")
      RETURN
   END IF

  LET p_qtd_grade = 1

  FOREACH c_ped_dig_itens_gr INTO p_pedido_dig_grad.*
     LET t_pedido_dig_grad[p_qtd_grade].num_pedido         =
         p_pedido_dig_grad.num_pedido
     LET t_pedido_dig_grad[p_qtd_grade].num_sequencia      =
         p_pedido_dig_grad.num_sequencia
     LET t_pedido_dig_grad[p_qtd_grade].cod_item           =
         p_pedido_dig_grad.cod_item
     LET t_pedido_dig_grad[p_qtd_grade].cod_grade_1        =
         p_pedido_dig_grad.cod_grade_1
     LET t_pedido_dig_grad[p_qtd_grade].cod_grade_2        =
         p_pedido_dig_grad.cod_grade_2
     LET t_pedido_dig_grad[p_qtd_grade].cod_grade_3        =
         p_pedido_dig_grad.cod_grade_3
     LET t_pedido_dig_grad[p_qtd_grade].cod_grade_4        =
         p_pedido_dig_grad.cod_grade_4
     LET t_pedido_dig_grad[p_qtd_grade].cod_grade_5        =
         p_pedido_dig_grad.cod_grade_5
     LET t_pedido_dig_grad[p_qtd_grade].qtd_pecas_solic    =
         p_pedido_dig_grad.qtd_pecas_solic
     LET p_qtd_grade = p_qtd_grade + 1
  END FOREACH

 END FUNCTION
#-----------------------------------#
 FUNCTION vdp4284_cursor_for_update()
#-----------------------------------#
  WHENEVER ERROR CONTINUE
  DECLARE cm_pedido_dig_mest CURSOR {WITH HOLD} FOR
    SELECT * INTO p_pedido_dig_mest.*
      FROM pedido_dig_mest
     WHERE pedido_dig_mest.num_pedido = p_pedido_dig_mest.num_pedido AND
           pedido_dig_mest.cod_empresa = p_cod_empresa
       FOR UPDATE
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","cm_pedido_dig_mest")
      RETURN
   END IF

  CALL log085_transacao("BEGIN")
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("TRANSACAO","BEGIN")
      RETURN
   END IF
  WHENEVER ERROR CONTINUE
  OPEN cm_pedido_dig_mest
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("OPEN","cm_pedido_dig_mest")
      RETURN
   END IF
  WHENEVER ERROR CONTINUE
  FETCH cm_pedido_dig_mest
  WHENEVER ERROR STOP

  CASE
    WHEN sqlca.sqlcode = 0
         RETURN true
    WHEN sqlca.sqlcode = -250
         CALL log0030_mensagem("Registro sendo atualizado por outro usuario. \nAguarde e tente novamente. ","exclamation")
         RETURN FALSE
    WHEN sqlca.sqlcode =  100
         CALL log0030_mensagem("Registro nao mais existente na tabela. \nExecute o QUERY novamente. ","exclamation")
    OTHERWISE
         CALL log003_err_sql("LEITURA","MESTRE")
  END CASE

  WHENEVER ERROR STOP

  RETURN FALSE
END FUNCTION

#------------------------------------#
 FUNCTION vdp4284_exclusao_pedido()
#------------------------------------#
 CALL log085_transacao("BEGIN")

  CALL vdp4284_exibe_dados()
  IF   log004_confirm(7,43)
  THEN IF   vdp4284_deleta()
       THEN CALL log085_transacao("COMMIT")
            IF   sqlca.sqlcode = 0
            THEN CLEAR FORM
                 MESSAGE " Exclusao efetuada com sucesso " ATTRIBUTE(REVERSE)
                 LET p_audit_vdp.texto = "EXCLUSAO - PEDIDOS NO LOTE "
                 CALL vdp876_monta_audit_vdp(p_cod_empresa,
                                             p_pedido_dig_mest.num_pedido,
                                            "M",
                                            "E",
                                            p_audit_vdp.texto,
                                            "vdp4284",
                                            TODAY,
                                            TIME,
                                            p_user)
            ELSE CALL log003_err_sql("EXCLUSAO ","PEDIDOS  ")
                 CALL log085_transacao("ROLLBACK")
            END IF
       ELSE LET p_pedido_dig_mest.* = p_pedido_dig_mestr.*
            CALL vdp4284_exibe_dados()
            CALL log085_transacao("ROLLBACK")
       END IF
  ELSE CALL log085_transacao("ROLLBACK")
  END IF

END FUNCTION

#-----------------------#
 FUNCTION vdp4284_deleta()
#-----------------------#
  WHENEVER ERROR CONTINUE
  DELETE FROM pedido_dig_mest
   WHERE pedido_dig_mest.num_pedido = p_pedido_dig_mest.num_pedido AND
         pedido_dig_mest.cod_empresa = p_cod_empresa

  IF sqlca.sqlcode <> 0
  THEN CALL log003_err_sql("EXCLUSAO", "MESTRE")
  END IF

  DELETE FROM pedido_dig_obs
   WHERE pedido_dig_obs.num_pedido = p_pedido_dig_mest.num_pedido AND
         pedido_dig_obs.cod_empresa = p_cod_empresa
  IF sqlca.sqlcode <> 0
  THEN CALL log003_err_sql("EXCLUSAO", "OBSERVACAO")
  END IF

  DELETE FROM pedido_dig_ent
   WHERE pedido_dig_ent.num_pedido = p_pedido_dig_mest.num_pedido AND
         pedido_dig_ent.cod_empresa = p_cod_empresa
  IF sqlca.sqlcode <> 0
  THEN CALL log003_err_sql("EXCLUSAO", "ENTREGA")
  END IF

  DELETE FROM pedido_dig_item
   WHERE pedido_dig_item.num_pedido = p_pedido_dig_mest.num_pedido AND
         pedido_dig_item.cod_empresa = p_cod_empresa
  IF sqlca.sqlcode <> 0
  THEN CALL log003_err_sql("EXCLUSAO", "ITENS")
  END IF

  DELETE FROM vendor_pedido
  WHERE vendor_pedido.cod_empresa = p_cod_empresa
    AND vendor_pedido.num_pedido = p_pedido_dig_mest.num_pedido
  IF sqlca.sqlcode <> 0
  THEN CALL log003_err_sql("EXCLUSAO", "VENDOR")
  END IF

  DELETE FROM ped_itens_rem
   WHERE ped_itens_rem.num_pedido = p_pedido_dig_mest.num_pedido AND
         ped_itens_rem.cod_empresa = p_cod_empresa
  IF sqlca.sqlcode <> 0
  THEN CALL log003_err_sql("EXCLUSAO", "ITENS_REMESSA")
  END IF

  DELETE FROM ped_dig_it_nat
   WHERE num_pedido = p_pedido_dig_mest.num_pedido AND
         cod_empresa = p_cod_empresa
  IF sqlca.sqlcode <> 0
  THEN CALL log003_err_sql("EXCLUSAO", "ITENS_NAT")
  END IF

  DELETE FROM ped_dig_item_desc
   WHERE ped_dig_item_desc.num_pedido  = p_pedido_dig_mest.num_pedido
     AND ped_dig_item_desc.cod_empresa = p_cod_empresa
  IF sqlca.sqlcode <> 0
  THEN CALL log003_err_sql("EXCLUSAO", "PEDIDO_DIG_ITEM_DESC")
       RETURN FALSE
  END IF

  DELETE FROM pedido_msg
   WHERE pedido_msg.num_pedido  = p_pedido_dig_mest.num_pedido
     AND pedido_msg.cod_empresa = p_cod_empresa
  IF sqlca.sqlcode <> 0
  THEN CALL log003_err_sql("EXCLUSAO", "PEDIDO_MSG")
       RETURN FALSE
  END IF

  DELETE FROM ped_info_compl
   WHERE empresa = p_cod_empresa
     AND pedido  = p_pedido_dig_mest.num_pedido
     AND campo   = 'linha_produto'
  IF  sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("EXCLUSAO", "PED_INFO_COMPL")
      RETURN FALSE
  END IF

  CALL vdpy154_exclui_ped_info_txt_expedicao(p_pedido_dig_mest.num_pedido)

  WHENEVER ERROR STOP

  RETURN TRUE
 END FUNCTION

#---------------------------------#
 FUNCTION vdp4284_query_pedido()
#---------------------------------#
  DEFINE where_clause, sql_stmt   CHAR(500)

  LET p_pedido_dig_mestr.*   = p_pedido_dig_mest.*

  INITIALIZE p_pedido_dig_mest.*,
             p_pedido_dig_obs.*,
             m_linha_produto,
             p_pedido_dig_ent.* TO NULL

  FOR p_aux = 1 to 500
      INITIALIZE t_pedido_dig_item[p_aux].*,
                 t_pedido_dig_grad[p_aux].*,
                 t_array_grade[p_aux].*      TO NULL
  END FOR

  LET p_pedido_dig_mest.ies_aceite_finan = "N"
  LET p_pedido_dig_mest.ies_aceite_comer = "N"

  CALL log006_exibe_teclas("02 07", p_versao)
  CURRENT WINDOW IS w_vdp4284
  CLEAR FORM

  DISPLAY p_cod_empresa TO cod_empresa
  CONSTRUCT BY NAME where_clause ON num_pedido,
                                    cod_nat_oper,
                                    dat_emis_repres,
                                    dat_prazo_entrega,
                                    cod_tip_carteira,
                                    ped_info_compl.parametro_texto,
                                    cod_cliente,
                                    num_pedido_cli,
                                    num_pedido_repres,
                                    ies_comissao,
                                    pct_comissao,
                                    cod_repres,
                                    cod_repres_adic,
                                    pct_comissao_2,
                                    cod_repres_3,
                                    pct_comissao_3,
                                    num_list_preco,
                                    ies_preco,
                                    pct_desc_financ,
                                    cod_cnd_pgto,
                                    ies_frete,
                                    cod_tip_venda,
                                    ies_tip_entrega,
                                    ies_sit_pedido,
                                    cod_transpor,
                                    cod_consig,
                                    ies_finalidade,
                                    ies_embal_padrao

      AFTER FIELD parametro_texto
            LET m_linha_produto = GET_FLDBUF(parametro_texto)

  END CONSTRUCT

  IF int_flag THEN
     LET int_flag = 0
     LET p_pedido_dig_mest.*        = p_pedido_dig_mest.*
     CALL log006_exibe_teclas("01 02", p_versao)

     CURRENT WINDOW IS w_vdp4284

     LET p_pedido_dig_mest.*   = p_pedido_dig_mestr.*

     CALL vdp4284_exibe_dados()
     CALL log0030_mensagem( " Consulta Cancelada ","excl")
     RETURN
  END IF

  IF  m_linha_produto IS NOT NULL AND
      m_linha_produto <> ' '      THEN
      LET sql_stmt =
            "SELECT pedido_dig_mest.* ",
              "FROM pedido_dig_mest, ped_info_compl ",
             "WHERE pedido_dig_mest.cod_empresa = '", p_cod_empresa ,"'",
              " AND ", where_clause CLIPPED,
              " AND ped_info_compl.empresa = pedido_dig_mest.cod_empresa ",
              " AND ped_info_compl.pedido  = pedido_dig_mest.num_pedido ",
              " AND ped_info_compl.campo   = 'linha_produto' "

  ELSE
      LET sql_stmt =
            "SELECT pedido_dig_mest.* ",
              "FROM pedido_dig_mest WHERE pedido_dig_mest.cod_empresa = """,
                    p_cod_empresa ,""" AND ", where_clause CLIPPED
  END IF

  WHENEVER ERROR CONTINUE
  PREPARE var_query FROM sql_stmt
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("PREPARE","VAR_QUERY")
     RETURN
  END IF
  WHENEVER ERROR CONTINUE
  DECLARE cq_pedido_dig_mest SCROLL CURSOR WITH HOLD FOR var_query
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","cq_pedido_dig_mest")
     RETURN
  END IF
  WHENEVER ERROR CONTINUE
  OPEN cq_pedido_dig_mest
  WHENEVER ERROR STOP

  IF  SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql('OPEN','CQ_PEDIDO_DIG_MEST')
  END IF

  WHENEVER ERROR CONTINUE
  FETCH cq_pedido_dig_mest INTO p_pedido_dig_mest.*

  WHENEVER ERROR STOP

  IF   sqlca.sqlcode = NOTFOUND
  THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados. ",
                             "exclamation")
       LET p_ies_cons = false
   #   LET p_pedido_dig_mest.*   = p_pedido_dig_mestr.*
   #   CALL vdp4284_exibe_dados()
       CLEAR FORM
  ELSE LET p_ies_cons = true
       CALL vdp4284_exibe_dados_consulta()
       CALL log006_exibe_teclas("01 02", p_versao)
       CURRENT WINDOW IS w_vdp4284
       CALL vdp4284_exibe_dados()
       LET int_flag = 0
  END IF

END FUNCTION

#----------------------------#
 FUNCTION vdp4284_exibe_dados()
#----------------------------#
 CURRENT WINDOW IS w_vdp4284

 INITIALIZE p_vendor_pedido.* TO NULL

 WHENEVER ERROR CONTINUE
 SELECT pct_comissao_2 INTO m_pct_comissao_2
      FROM pedido_dig_comis
     WHERE pedido_dig_comis.cod_empresa = p_cod_empresa
     AND  pedido_dig_comis.num_pedido = p_pedido_dig_mest.num_pedido
     #AND pedido_dig_comis.cod_repres_3 = m_cod_repres_3
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  m_pct_comissao_2 TO NULL
 END IF
      DISPLAY m_pct_comissao_2 TO pct_comissao_2

 WHENEVER ERROR CONTINUE
 SELECT cod_repres_3 INTO m_cod_repres_3
      FROM pedido_dig_comis
     WHERE pedido_dig_comis.cod_empresa = p_cod_empresa
     AND  pedido_dig_comis.num_pedido = p_pedido_dig_mest.num_pedido
     #AND pedido_dig_comis.cod_repres_3 = m_cod_repres_3
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  m_cod_repres_3 TO NULL
 END IF
      DISPLAY m_cod_repres_3 TO cod_repres_3

 WHENEVER ERROR CONTINUE
 SELECT pct_comissao_3 INTO m_pct_comissao_3
      FROM pedido_dig_comis
      WHERE pedido_dig_comis.cod_empresa = p_cod_empresa
     AND  pedido_dig_comis.num_pedido = p_pedido_dig_mest.num_pedido
     #AND pedido_dig_comis.cod_repres_3 = m_cod_repres_3
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  m_pct_comissao_3 TO NULL
 END IF
       DISPLAY m_pct_comissao_3 TO pct_comissao_3

 WHENEVER ERROR CONTINUE
 SELECT vendor_pedido.* INTO p_vendor_pedido.*
   FROM vendor_pedido
  WHERE vendor_pedido.cod_empresa = p_cod_empresa
    AND vendor_pedido.num_pedido = p_pedido_dig_mest.num_pedido
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  p_vendor_pedido.* TO NULL
 END IF


 DISPLAY BY NAME p_pedido_dig_mest.cod_empresa,
                 p_pedido_dig_mest.num_pedido,
                 p_pedido_dig_mest.cod_nat_oper,
                 p_pedido_dig_mest.dat_emis_repres,
                 p_pedido_dig_mest.cod_tip_carteira,
                 p_pedido_dig_mest.cod_cliente,
                 p_pedido_dig_mest.cod_repres,
                 p_pedido_dig_mest.ies_comissao,
                 p_pedido_dig_mest.ies_finalidade,
                 p_pedido_dig_mest.ies_preco,
                 p_pedido_dig_mest.num_list_preco,
                 p_pedido_dig_mest.cod_cnd_pgto,
                 p_pedido_dig_mest.pct_desc_financ,
                 p_pedido_dig_mest.pct_desc_adic,
                 p_pedido_dig_mest.num_pedido_cli,
                 p_pedido_dig_mest.num_pedido_repres,
                 p_vendor_pedido.pct_taxa_negoc,
                 p_pedido_dig_mest.ies_frete,
                 p_pedido_dig_mest.cod_repres_adic,
                 p_pedido_dig_mest.cod_transpor,
                 p_pedido_dig_mest.cod_consig,
                 p_pedido_dig_mest.ies_embal_padrao,
                 p_pedido_dig_mest.ies_tip_entrega,
                 p_pedido_dig_mest.dat_prazo_entrega,
                 p_pedido_dig_mest.pct_comissao,
                 p_pedido_dig_mest.ies_sit_pedido,
                 p_pedido_dig_mest.cod_tip_venda,
                 p_pedido_dig_mest.cod_moeda

     DISPLAY m_linha_produto TO parametro_texto

 END FUNCTION

#----------------------------------#
 FUNCTION vdp4284_paginacao(p_funcao)
#----------------------------------#
  DEFINE p_funcao           CHAR(20)

  IF p_ies_cons THEN
     LET p_pedido_dig_mestr.* = p_pedido_dig_mest.*
     WHILE TRUE
       CASE
         WHEN p_funcao = "SEGUINTE"
              FETCH NEXT     cq_pedido_dig_mest INTO p_pedido_dig_mest.*
         WHEN p_funcao = "ANTERIOR"
              FETCH PREVIOUS cq_pedido_dig_mest INTO p_pedido_dig_mest.*
       END CASE

       IF sqlca.sqlcode = NOTFOUND  THEN
          LET p_pedido_dig_mest.* = p_pedido_dig_mestr.*
          LET p_pedido_dig_mest.*   = p_pedido_dig_mestr.*

          CALL vdp4284_exibe_dados()
          CALL log0030_mensagem( " N�o existem mais itens nesta dire��o ","excl")
          EXIT WHILE
       END IF

       WHENEVER ERROR CONTINUE
       SELECT parametro_texto
         INTO m_linha_produto
         FROM ped_info_compl
        WHERE empresa = p_cod_empresa
          AND pedido  = p_pedido_dig_mest.num_pedido
          AND campo   = 'linha_produto'
       WHENEVER ERROR STOP

       IF  SQLCA.sqlcode <> 0 THEN
           INITIALIZE m_linha_produto TO NULL
       END IF


       WHENEVER ERROR CONTINUE
       SELECT * INTO p_pedido_dig_mest.* FROM pedido_dig_mest
         WHERE pedido_dig_mest.num_pedido = p_pedido_dig_mest.num_pedido AND
               pedido_dig_mest.cod_empresa = p_cod_empresa
       WHENEVER ERROR STOP
       IF sqlca.sqlcode = 0  THEN
          IF p_pedido_dig_mest.num_pedido = p_pedido_dig_mestr.num_pedido
             THEN
             ELSE CALL vdp4284_exibe_dados_consulta()
                  EXIT WHILE
          END IF
       END IF

     END WHILE

  ELSE
     CALL log0030_mensagem( " N�o existe nenhuma consulta ativa ","excl")
  END IF
END FUNCTION

#-------------------------------------#
 FUNCTION vdp4284_exibe_dados_consulta()
#-------------------------------------#
 DEFINE l_den_transpor, l_den_consig  LIKE transport.den_transpor

 LET l_den_transpor = " "
 LET l_den_consig   = " "

 INITIALIZE p_vendor_pedido.* TO NULL

 WHENEVER ERROR CONTINUE
 SELECT den_transpor INTO l_den_transpor
   FROM transport
  WHERE cod_transpor = p_pedido_dig_mest.cod_transpor
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = NOTFOUND THEN
    WHENEVER ERROR CONTINUE
    SELECT nom_cliente INTO l_den_transpor
      FROM clientes
     WHERE cod_cliente = p_pedido_dig_mest.cod_transpor
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       INITIALIZE  l_den_transpor TO NULL
    END IF
 END IF
 DISPLAY l_den_transpor TO den_transpor

 WHENEVER ERROR CONTINUE
 SELECT den_transpor INTO l_den_consig
   FROM transport
  WHERE cod_transpor = p_pedido_dig_mest.cod_consig
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = NOTFOUND THEN
    WHENEVER ERROR CONTINUE
    SELECT nom_cliente INTO l_den_consig
      FROM clientes
     WHERE cod_cliente = p_pedido_dig_mest.cod_consig
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       INITIALIZE  l_den_consig TO NULL
    END IF
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_comissao_2 INTO m_pct_comissao_2
      FROM pedido_dig_comis
      WHERE pedido_dig_comis.cod_empresa = p_cod_empresa
     AND  pedido_dig_comis.num_pedido = p_pedido_dig_mest.num_pedido
     #AND pedido_dig_comis.cod_repres_3 = m_cod_repres_3
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  m_pct_comissao_2 TO NULL
 END IF

     DISPLAY m_pct_comissao_2 TO pct_comissao_2

 WHENEVER ERROR CONTINUE
 SELECT cod_repres_3 INTO m_cod_repres_3
      FROM pedido_dig_comis
     WHERE pedido_dig_comis.cod_empresa = p_cod_empresa
     AND  pedido_dig_comis.num_pedido = p_pedido_dig_mest.num_pedido
     #AND pedido_dig_comis.cod_repres_3 = m_cod_repres_3
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  m_cod_repres_3 TO NULL
 END IF

      DISPLAY m_cod_repres_3 TO cod_repres_3

 WHENEVER ERROR CONTINUE
 SELECT pct_comissao_3 INTO m_pct_comissao_3
      FROM pedido_dig_comis
      WHERE pedido_dig_comis.cod_empresa = p_cod_empresa
     AND  pedido_dig_comis.num_pedido = p_pedido_dig_mest.num_pedido
     #AND pedido_dig_comis.cod_repres_3 = m_cod_repres_3
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  m_pct_comissao_3 TO NULL
 END IF

     DISPLAY m_pct_comissao_3 TO pct_comissao_3

 WHENEVER ERROR CONTINUE
 SELECT vendor_pedido.* INTO p_vendor_pedido.*
   FROM vendor_pedido
  WHERE vendor_pedido.cod_empresa = p_cod_empresa
    AND vendor_pedido.num_pedido = p_pedido_dig_mest.num_pedido
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  p_vendor_pedido.* TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 SELECT parametro_texto
   INTO m_linha_produto
   FROM ped_info_compl
  WHERE empresa = p_cod_empresa
    AND pedido  = p_pedido_dig_mest.num_pedido
    AND campo   = 'linha_produto'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  m_linha_produto TO NULL
 END IF

 DISPLAY BY NAME p_pedido_dig_mest.cod_empresa,
                 p_pedido_dig_mest.num_pedido,
                 p_pedido_dig_mest.cod_nat_oper,
                 p_pedido_dig_mest.dat_emis_repres,
                 p_pedido_dig_mest.cod_tip_carteira,
                 p_pedido_dig_mest.cod_cliente,
                 p_pedido_dig_mest.cod_repres,
                 p_pedido_dig_mest.ies_comissao,
                 p_pedido_dig_mest.ies_finalidade,
                 p_pedido_dig_mest.ies_preco,
                 p_pedido_dig_mest.num_list_preco,
                 p_pedido_dig_mest.cod_cnd_pgto,
                 p_pedido_dig_mest.pct_desc_financ,
                 p_pedido_dig_mest.pct_desc_adic,
                 p_pedido_dig_mest.num_pedido_cli,
                 p_pedido_dig_mest.num_pedido_repres,
                 p_pedido_dig_mest.ies_frete,
                 p_pedido_dig_mest.cod_repres_adic,
                 p_pedido_dig_mest.cod_transpor,
                 p_pedido_dig_mest.cod_consig,
                 p_pedido_dig_mest.ies_embal_padrao,
                 p_pedido_dig_mest.ies_tip_entrega,
                 p_pedido_dig_mest.dat_prazo_entrega,
                 p_pedido_dig_mest.pct_comissao,
                 p_pedido_dig_mest.ies_sit_pedido,
                 p_pedido_dig_mest.cod_tip_venda,
                 p_pedido_dig_mest.cod_moeda,
                 p_vendor_pedido.pct_taxa_negoc

  DISPLAY m_linha_produto TO parametro_texto

  LET m_ies_txt_exped = vdpy154_possui_texto_expedicao(p_pedido_dig_mest.num_pedido)

  DISPLAY m_ies_txt_exped TO ies_txt_exped

  MENU "OPCAO"
    COMMAND "End_entr/obs" "Exibe o ENDERECO DE ENTREGA / OBSERVACOES"
      HELP 030
      MESSAGE ""
      CALL vdp4284_exibe_ent_obs()
    COMMAND KEY("I") "Itens" "Exibe os ITENS "
      HELP 031
      MESSAGE ""
      CALL vdp4284_exibe_itens()
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 032
      MESSAGE ""
      CALL vdp4284_exibe_dados()
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
 END FUNCTION

#------------------------------#
 FUNCTION vdp4284_exibe_ent_obs()
#------------------------------#
 INITIALIZE  p_pedido_dig_ent.* TO NULL
 INITIALIZE  p_pedido_dig_obs.* TO NULL
 WHENEVER ERROR CONTINUE

 SELECT pedido_dig_ent.* INTO p_pedido_dig_ent.* FROM pedido_dig_ent
  WHERE pedido_dig_ent.num_pedido = p_pedido_dig_mest.num_pedido AND
        pedido_dig_ent.cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  p_pedido_dig_ent.* TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pedido_dig_obs.* INTO p_pedido_dig_obs.* FROM pedido_dig_obs
  WHERE pedido_dig_obs.num_pedido = p_pedido_dig_mest.num_pedido AND
        pedido_dig_obs.cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE  p_pedido_dig_obs.* TO NULL
 END IF

 WHENEVER ERROR CONTINUE

  CALL log130_procura_caminho("vdp42841") RETURNING p_nom_tela
  OPEN WINDOW w_vdp42841 AT 2,2 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 WHENEVER ERROR STOP

 CURRENT WINDOW IS w_vdp42841

 DISPLAY p_pedido_dig_ent.cod_empresa,
         p_pedido_dig_ent.num_pedido  TO cod_empresa, num_pedido

 DISPLAY BY NAME p_pedido_dig_ent.end_entrega,
                 p_pedido_dig_ent.den_bairro,
                 p_pedido_dig_ent.cod_cidade,
                 p_pedido_dig_ent.cod_cep,
                 p_pedido_dig_ent.num_cgc,
                 p_pedido_dig_ent.ins_estadual,
                 p_pedido_dig_obs.tex_observ_1,
                 p_pedido_dig_obs.tex_observ_2

# PROMPT "\nTecle ENTER para continuar" FOR p_comando
MENU "OPCAO"
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

END FUNCTION

#------------------------------#
 FUNCTION vdp4284_exibe_itens()
#------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE e_pedido_dig_item CURSOR FOR
  SELECT * FROM pedido_dig_item
   WHERE pedido_dig_item.num_pedido  = p_pedido_dig_mest.num_pedido AND
         pedido_dig_item.cod_empresa = p_cod_empresa
   ORDER BY num_sequencia
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","e_pedido_dig_item")
    RETURN
 END IF
 CALL set_count(0)
 LET p_count = 1

 WHENEVER ERROR CONTINUE
 FOREACH e_pedido_dig_item INTO p_pedido_dig_item.*
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("FOREACH","e_pedido_dig_item")
       RETURN
    END IF
    CALL set_count(p_count)
   # LET t_pedido_dig_item[p_count].num_sequencia   =
   #     p_pedido_dig_item.num_sequencia
     LET t_pedido_dig_item[p_count].cod_item        =
         p_pedido_dig_item.cod_item
     LET t_pedido_dig_item[p_count].qtd_pecas_solic =
         p_pedido_dig_item.qtd_pecas_solic
     LET t_pedido_dig_item[p_count].pre_unit        =
         p_pedido_dig_item.pre_unit
     LET t_pedido_dig_item[p_count].pct_desc_adic   =
         p_pedido_dig_item.pct_desc_adic
     LET t_pedido_dig_item[p_count].prz_entrega     =
         p_pedido_dig_item.prz_entrega
     LET t_pedido_dig_item[p_count].val_frete_unit  =
         p_pedido_dig_item.val_frete_unit
     LET t_pedido_dig_item[p_count].val_seguro_unit =
         p_pedido_dig_item.val_seguro_unit

     WHENEVER ERROR CONTINUE
     SELECT parametro_dat
     INTO t_pedido_dig_item[p_count].parametro_dat
     FROM vdp_ped_item_compl
     WHERE empresa = p_cod_empresa
     AND   pedido  = p_pedido_dig_mest.num_pedido
     AND   sequencia_pedido = p_pedido_dig_item.num_sequencia
     AND   campo  = 'data_cliente'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        INITIALIZE t_pedido_dig_item[p_count].parametro_dat TO NULL
     END IF

     LET p_count = p_count + 1
   WHENEVER ERROR CONTINUE
 END FOREACH
 WHENEVER ERROR STOP
 FREE e_pedido_dig_item

 WHENEVER ERROR CONTINUE

 CALL log130_procura_caminho("vdp42842") RETURNING p_nom_tela
 OPEN WINDOW w_vdp42842 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 WHENEVER ERROR STOP

 CURRENT WINDOW IS w_vdp42842

 DISPLAY p_pedido_dig_item.cod_empresa,
         p_pedido_dig_item.num_pedido TO cod_empresa, num_pedido

 DISPLAY ARRAY t_pedido_dig_item TO s_pedido_dig_item.*

 LET int_flag = 0

 END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp4284_controle_peditdesc(p_cod_emp, p_num_ped, p_num_seq)
#---------------------------------------------------------------------#
  DEFINE p_cod_emp           LIKE empresa.cod_empresa,
         p_num_ped           LIKE pedidos.num_pedido,
         p_num_seq           LIKE ped_itens.num_sequencia

  INITIALIZE p_nom_tela TO NULL

  CALL log006_exibe_teclas("01 02 07", p_versao)
  WHENEVER ERROR CONTINUE

  CURRENT WINDOW IS w_vdp42844
  CALL log130_procura_caminho("vdp42844") RETURNING p_nom_tela
  OPEN WINDOW w_vdp42844 AT 2,2  WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  WHENEVER ERROR STOP

  CURRENT WINDOW IS w_vdp42844

  WHENEVER ERROR CONTINUE
  SELECT *
    INTO p_ped_dig_item_desc.*
    FROM ped_dig_item_desc
   WHERE num_pedido = p_pedido_dig_mest.num_pedido
     AND cod_empresa = p_cod_empresa
     AND num_sequencia = p_num_seq
   WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     LET p_ped_dig_item_desc.cod_empresa   = p_cod_empresa
     LET p_ped_dig_item_desc.num_pedido    = p_num_ped
     LET p_ped_dig_item_desc.num_sequencia = p_num_seq
     LET p_ped_dig_item_desc.pct_desc_1    = 0
     LET p_ped_dig_item_desc.pct_desc_2    = 0
     LET p_ped_dig_item_desc.pct_desc_3    = 0
     LET p_ped_dig_item_desc.pct_desc_4    = 0
     LET p_ped_dig_item_desc.pct_desc_5    = 0
     LET p_ped_dig_item_desc.pct_desc_6    = 0
     LET p_ped_dig_item_desc.pct_desc_7    = 0
     LET p_ped_dig_item_desc.pct_desc_8    = 0
     LET p_ped_dig_item_desc.pct_desc_9    = 0
     LET p_ped_dig_item_desc.pct_desc_10   = 0
  END IF

  FOR p_aux = 1 TO 500
    IF t_ped_dig_item_desc[p_aux].num_pedido    =
       p_ped_dig_item_desc.num_pedido
    AND
       t_ped_dig_item_desc[p_aux].num_sequencia =
       p_ped_dig_item_desc.num_sequencia
    THEN
       LET p_ped_dig_item_desc.pct_desc_1  =
           t_ped_dig_item_desc[p_aux].pct_desc_1
       LET p_ped_dig_item_desc.pct_desc_2  =
           t_ped_dig_item_desc[p_aux].pct_desc_2
       LET p_ped_dig_item_desc.pct_desc_3  =
           t_ped_dig_item_desc[p_aux].pct_desc_3
       LET p_ped_dig_item_desc.pct_desc_4  =
           t_ped_dig_item_desc[p_aux].pct_desc_4
       LET p_ped_dig_item_desc.pct_desc_5  =
           t_ped_dig_item_desc[p_aux].pct_desc_5
       LET p_ped_dig_item_desc.pct_desc_6  =
           t_ped_dig_item_desc[p_aux].pct_desc_6
       LET p_ped_dig_item_desc.pct_desc_7  =
           t_ped_dig_item_desc[p_aux].pct_desc_7
       LET p_ped_dig_item_desc.pct_desc_8  =
           t_ped_dig_item_desc[p_aux].pct_desc_8
       LET p_ped_dig_item_desc.pct_desc_9  =
           t_ped_dig_item_desc[p_aux].pct_desc_9
       LET p_ped_dig_item_desc.pct_desc_10 =
           t_ped_dig_item_desc[p_aux].pct_desc_10
       EXIT FOR
    END IF
  END FOR

  DISPLAY BY NAME p_ped_dig_item_desc.num_pedido
  DISPLAY BY NAME p_ped_dig_item_desc.cod_empresa
  DISPLAY BY NAME p_ped_dig_item_desc.num_sequencia

  INPUT BY NAME p_ped_dig_item_desc.* WITHOUT DEFAULTS
       BEFORE FIELD num_sequencia
           NEXT FIELD pct_desc_1
       AFTER INPUT
           LET p_pct_desc_tot = p_ped_dig_item_desc.pct_desc_1 +
                                p_ped_dig_item_desc.pct_desc_2 +
                                p_ped_dig_item_desc.pct_desc_3 +
                                p_ped_dig_item_desc.pct_desc_4 +
                                p_ped_dig_item_desc.pct_desc_5 +
                                p_ped_dig_item_desc.pct_desc_6 +
                                p_ped_dig_item_desc.pct_desc_7 +
                                p_ped_dig_item_desc.pct_desc_8 +
                                p_ped_dig_item_desc.pct_desc_9 +
                                p_ped_dig_item_desc.pct_desc_10
  END INPUT

  FOR p_aux = 1 TO 500
     IF t_ped_dig_item_desc[p_aux].num_pedido    = p_num_ped AND
        t_ped_dig_item_desc[p_aux].num_sequencia = p_num_seq THEN
        INITIALIZE t_ped_dig_item_desc[p_aux].* TO NULL
        EXIT FOR
     END IF
  END FOR

  FOR p_aux = 1 TO 500
     IF t_ped_dig_item_desc[p_aux].num_sequencia IS NULL OR
        t_ped_dig_item_desc[p_aux].num_sequencia = " "   THEN
        LET t_ped_dig_item_desc[p_aux].num_pedido    = p_num_ped
        LET t_ped_dig_item_desc[p_aux].num_sequencia = p_num_seq
        LET t_ped_dig_item_desc[p_aux].pct_desc_1    =
            p_ped_dig_item_desc.pct_desc_1
        LET t_ped_dig_item_desc[p_aux].pct_desc_2    =
            p_ped_dig_item_desc.pct_desc_2
        LET t_ped_dig_item_desc[p_aux].pct_desc_3    =
            p_ped_dig_item_desc.pct_desc_3
        LET t_ped_dig_item_desc[p_aux].pct_desc_4    =
            p_ped_dig_item_desc.pct_desc_4
        LET t_ped_dig_item_desc[p_aux].pct_desc_5    =
            p_ped_dig_item_desc.pct_desc_5
        LET t_ped_dig_item_desc[p_aux].pct_desc_6    =
            p_ped_dig_item_desc.pct_desc_6
        LET t_ped_dig_item_desc[p_aux].pct_desc_7    =
            p_ped_dig_item_desc.pct_desc_7
        LET t_ped_dig_item_desc[p_aux].pct_desc_8    =
            p_ped_dig_item_desc.pct_desc_8
        LET t_ped_dig_item_desc[p_aux].pct_desc_9    =
            p_ped_dig_item_desc.pct_desc_9
        LET t_ped_dig_item_desc[p_aux].pct_desc_10   =
            p_ped_dig_item_desc.pct_desc_10
        EXIT FOR
     END IF
  END FOR

  CLOSE WINDOW w_vdp42844
  LET int_flag = 0

END FUNCTION

#-------------------------------------------#
 FUNCTION vdp4284_inclui_ped_dig_item_desc()
#-------------------------------------------#
 DEFINE p_padesc     SMALLINT

 FOR p_padesc = 1 TO 500
     IF (t_ped_dig_item_desc[p_padesc].num_sequencia IS NOT NULL OR
         t_ped_dig_item_desc[p_padesc].num_sequencia <> " ") #AND
        #(t_ped_dig_item_desc[p_padesc].pct_desc_1 > 0)
     THEN
        LET p_ped_dig_item_desc.cod_empresa   = p_cod_empresa
        LET p_ped_dig_item_desc.num_pedido    = p_pedido_dig_mest.num_pedido
        LET p_ped_dig_item_desc.num_sequencia =
            t_ped_dig_item_desc[p_padesc].num_sequencia
        LET p_ped_dig_item_desc.pct_desc_1 =
            t_ped_dig_item_desc[p_padesc].pct_desc_1
        LET p_ped_dig_item_desc.pct_desc_2 =
            t_ped_dig_item_desc[p_padesc].pct_desc_2
        LET p_ped_dig_item_desc.pct_desc_3 =
            t_ped_dig_item_desc[p_padesc].pct_desc_3
        LET p_ped_dig_item_desc.pct_desc_4 =
            t_ped_dig_item_desc[p_padesc].pct_desc_4
        LET p_ped_dig_item_desc.pct_desc_5 =
            t_ped_dig_item_desc[p_padesc].pct_desc_5
        LET p_ped_dig_item_desc.pct_desc_6 =
            t_ped_dig_item_desc[p_padesc].pct_desc_6
        LET p_ped_dig_item_desc.pct_desc_7 =
            t_ped_dig_item_desc[p_padesc].pct_desc_7
        LET p_ped_dig_item_desc.pct_desc_8 =
            t_ped_dig_item_desc[p_padesc].pct_desc_8
        LET p_ped_dig_item_desc.pct_desc_9 =
            t_ped_dig_item_desc[p_padesc].pct_desc_9
        LET p_ped_dig_item_desc.pct_desc_10=
            t_ped_dig_item_desc[p_padesc].pct_desc_10

         WHENEVER ERROR CONTINUE
        INSERT INTO ped_dig_item_desc VALUES (p_ped_dig_item_desc.*)
         WHENEVER ERROR STOP
        IF sqlca.sqlcode  <> 0 THEN
        CALL log003_err_sql("INCLUSAO","PED_DIG_ITENS_DESC")
        END IF
     END IF
 END FOR

END FUNCTION
#----------------------------------------#
 FUNCTION vdp4284_existe_nat_oper_refer()
#----------------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT cod_nat_oper_ref INTO m_cod_nat_oper_ref
   FROM nat_oper_refer
  WHERE cod_empresa  = p_cod_empresa
    AND cod_nat_oper = p_pedido_dig_mest.cod_nat_oper
    AND cod_item     = t_pedido_dig_item[pa_curr].cod_item
 WHENEVER ERROR STOP
 IF SQLCA.sqlcode <> 0
    THEN RETURN FALSE
 END IF

 RETURN TRUE
END FUNCTION

#------------------------------------#
 FUNCTION vdp4284_existe_fiscal_par(l_cod_cla_fisc,
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

#   WHENEVER ERROR CONTINUE
#   SELECT * FROM fiscal_par
#    WHERE cod_empresa   = p_cod_empresa
#      AND cod_nat_oper  = m_cod_nat_oper_ref
#      AND cod_uni_feder = p_cod_uni_feder
#   WHENEVER ERROR STOP
#
#   IF sqlca.sqlcode <> 0 THEN
#      SELECT * FROM fiscal_par
#       WHERE cod_empresa    = p_cod_empresa
#         AND cod_nat_oper   = m_cod_nat_oper_ref
#         AND cod_uni_feder IS NULL
#   END IF
#
#   IF sqlca.sqlcode = 0
#      THEN RETURN TRUE
#      ELSE RETURN FALSE
#   END IF

  IF m_consis_trib_pedido = "S" THEN
     IF NOT vdpr99_nova_funcao_fat() THEN
        IF NOT vdpr99_consiste_fiscal('',
                                       p_cod_empresa,
                                       TODAY,
                                       m_cod_nat_oper_ref,
                                       p_pedido_dig_mest.cod_cliente,
                                       p_pedido_dig_mest.cod_tip_carteira,
                                       p_pedido_dig_mest.ies_finalidade,
                                       l_cod_cla_fisc, # Classifica��o fiscal
                                       '', # Unidade de medida busca do item
                                       'N',# Bonifica��o
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

#-------------------------------#
FUNCTION vdp4284_verifica_grade()
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
      CALL log0030_mensagem( " Produto n�o cadastrado ","excl")
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

      IF vdp4284_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem( " Entrada de grade Cancelada","excl")
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   WHENEVER ERROR STOP
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

      IF vdp4284_entrada_dados_grad() = FALSE THEN
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

      IF vdp4284_entrada_dados_grad() = FALSE THEN
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
      LET p_item2.cod_seg_merc = 0
      LET p_item2.cod_cla_uso  = 0

      IF vdp4284_entrada_dados_grad() = FALSE THEN
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

      IF vdp4284_entrada_dados_grad() = FALSE THEN
         CALL log0030_mensagem( " Entrada de grade Cancelada","excl")
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------------#
FUNCTION vdp4284_entrada_dados_grad()
#-----------------------------------#
   DEFINE l_for,
          l_count                   SMALLINT

   CALL log006_exibe_teclas("01 02 03 05 06 07", p_versao)

   WHENEVER ERROR CONTINUE
   CALL log130_procura_caminho("vdp42846") RETURNING p_comando
   OPEN WINDOW w_vdp42846 AT 2,2 WITH FORM p_comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   WHENEVER ERROR STOP

   CURRENT WINDOW IS w_vdp42846

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

   CALL vdp4284_busca_cab_grade()

   CALL SET_COUNT(l_count)

   INPUT ARRAY t_array_grade WITHOUT DEFAULTS
    FROM s_pedido_dig_grad.*

      BEFORE ROW
         LET pa_curr_g   = arr_curr()
         LET pa_count_g  = arr_count()
         LET sc_curr_g   = scr_line()

      BEFORE FIELD cod_grade_1
      CALL vdp4284_mostra_zoom()
      AFTER  FIELD cod_grade_1
         IF (t_array_grade[pa_curr_g].cod_grade_1 IS NULL OR
             t_array_grade[pa_curr_g].cod_grade_1 = " "     ) AND
            fgl_lastkey() <> fgl_keyval("RETURN")             THEN
            EXIT INPUT
         END IF
         IF vdp4284_item_grade(1,t_array_grade[pa_curr_g].cod_grade_1) = FALSE
         THEN
            LET m_msg = " Grade nao cadastrada para o item ", p_item2.cod_item
            CALL log0030_mensagem(m_msg,"excl")
            NEXT FIELD cod_grade_1
         END IF

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
      CALL vdp4284_mostra_zoom()
      AFTER  FIELD cod_grade_2
         IF vdp4284_item_grade(2,t_array_grade[pa_curr_g].cod_grade_2) = FALSE
         THEN
            LET m_msg = " Grade nao cadastrada para o item ", p_item2.cod_item
            CALL log0030_mensagem(m_msg,"excl")
            NEXT FIELD cod_grade_2
         END IF
      CALL vdp4284_apaga_zoom()

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
      CALL vdp4284_mostra_zoom()
      AFTER  FIELD cod_grade_3
         IF vdp4284_item_grade(3,t_array_grade[pa_curr_g].cod_grade_3) = FALSE
         THEN
            LET m_msg = " Grade nao cadastrada para o item ", p_item2.cod_item
            CALL log0030_mensagem(m_msg,"excl")
            NEXT FIELD cod_grade_3
         END IF
      CALL vdp4284_apaga_zoom()

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
      CALL vdp4284_mostra_zoom()
      AFTER  FIELD cod_grade_4
         IF vdp4284_item_grade(4,t_array_grade[pa_curr_g].cod_grade_4) = FALSE
         THEN
            LET m_msg = " Grade nao cadastrada para o item ", p_item2.cod_item
            CALL log0030_mensagem(m_msg,"excl")
            NEXT FIELD cod_grade_4
         END IF
      CALL vdp4284_apaga_zoom()

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
      CALL vdp4284_mostra_zoom()
      AFTER  FIELD cod_grade_5
         IF vdp4284_item_grade(5,t_array_grade[pa_curr_g].cod_grade_5) = FALSE
         THEN
            LET m_msg = " Grade nao cadastrada para o item ", p_item2.cod_item
            CALL log0030_mensagem(m_msg,"excl")
            NEXT FIELD cod_grade_5
         END IF
      CALL vdp4284_apaga_zoom()

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
         CALL vdp4284_popup(1)

   END INPUT

   CLOSE WINDOW w_vdp42846
   CALL log006_exibe_teclas("01 02 05 06 07", p_versao)
   CURRENT WINDOW IS w_vdp42842

   IF int_flag <> 0 THEN
      LET int_flag  = 0
      RETURN FALSE
   END IF

   CALL vdp4284_grava_alteracoes_grade()
   LET t_pedido_dig_item[pa_curr].qtd_pecas_solic = p_sum_qtd_grade

   RETURN TRUE
END FUNCTION


#--------------------------------#
FUNCTION vdp4284_busca_cab_grade()
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
        INITIALIZE ma_ctr_grade[1].descr_cabec_zoom,
             ma_ctr_grade[1].nom_tabela_zoom,
             ma_ctr_grade[1].descr_col_1_zoom,
             ma_ctr_grade[1].descr_col_2_zoom,
             ma_ctr_grade[1].cod_progr_manut,
             ma_ctr_grade[1].ies_ctr_empresa TO NULL
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
        INITIALIZE ma_ctr_grade[2].descr_cabec_zoom,
             ma_ctr_grade[2].nom_tabela_zoom,
             ma_ctr_grade[2].descr_col_1_zoom,
             ma_ctr_grade[2].descr_col_2_zoom,
             ma_ctr_grade[2].cod_progr_manut,
             ma_ctr_grade[2].ies_ctr_empresa TO NULL
      END IF
   END IF

   WHENEVER ERROR CONTINUE
   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_3
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_3
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
        INITIALIZE ma_ctr_grade[3].descr_cabec_zoom,
             ma_ctr_grade[3].nom_tabela_zoom,
             ma_ctr_grade[3].descr_col_1_zoom,
             ma_ctr_grade[3].descr_col_2_zoom,
             ma_ctr_grade[3].cod_progr_manut,
             ma_ctr_grade[3].ies_ctr_empresa TO NULL
      END IF
   END IF

   WHENEVER ERROR CONTINUE
   SELECT den_grade_reduz
     INTO p_cab_grade.den_grade_4
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_4
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
        INITIALIZE ma_ctr_grade[4].descr_cabec_zoom,
             ma_ctr_grade[4].nom_tabela_zoom,
             ma_ctr_grade[4].descr_col_1_zoom,
             ma_ctr_grade[4].descr_col_2_zoom,
             ma_ctr_grade[4].cod_progr_manut,
             ma_ctr_grade[4].ies_ctr_empresa TO NULL
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
        INITIALIZE ma_ctr_grade[5].descr_cabec_zoom,
             ma_ctr_grade[5].nom_tabela_zoom,
             ma_ctr_grade[5].descr_col_1_zoom,
             ma_ctr_grade[5].descr_col_2_zoom,
             ma_ctr_grade[5].cod_progr_manut,
             ma_ctr_grade[5].ies_ctr_empresa TO NULL
      END IF
   END IF

   DISPLAY BY NAME p_cab_grade.*

END FUNCTION


#---------------------------------------#
FUNCTION vdp4284_grava_alteracoes_grade()
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
FUNCTION vdp4284_item_grade(p_ies_grade, l_cod_grade)
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


#------------------------------#
 FUNCTION vdp4284_move_dados()
#------------------------------#
  LET p_pedido_dig_mest.cod_empresa     = p_cod_empresa
  LET p_pedido_dig_obs.cod_empresa      = p_cod_empresa
  LET p_pedido_dig_ent.cod_empresa      = p_cod_empresa
  LET p_pedido_dig_item.cod_empresa     = p_cod_empresa
  LET p_pedido_dig_mest.num_list_preco  = 0
  LET p_pedido_dig_mest.pct_desc_financ = 0
  LET p_pedido_dig_mest.pct_comissao    = 0
  LET p_pedido_dig_grad.cod_empresa     = p_cod_empresa
  LET p_pedido_dig_mest.pct_desc_adic   = 0
  LET p_pedido_dig_item.pct_desc_bruto  = 0
  LET p_pedido_dig_mest.cod_tip_venda   = NULL
  LET p_totalc.desc_adic                = 0
  LET p_totalc.quantidade               = 0
  LET p_totalc.preco                    = 0
  LET p_totalc.desc_adic                = 0
  LET p_totalc.val_tot_bruto            = 0
  LET p_totalc.val_tot_liquido          = 0
  LET p_total.val_tot_bruto             = 0
  LET p_total.val_tot_liquido           = 0
  LET p_tela                            = 1
  LET p_flag                            = 1
  LET p_count                           = 0
  LET p_pedido_dig_mest.dat_digitacao    = TODAY
  LET p_pedido_dig_mest.cod_tip_carteira   = "01"
  LET p_pedido_dig_mest.ies_sit_informacao = "D"

 FOR p_ind = 1 TO 500
  LET p_ped_dig_item_desc.pct_desc_1    = 0
  LET p_ped_dig_item_desc.pct_desc_2    = 0
  LET p_ped_dig_item_desc.pct_desc_3    = 0
  LET p_ped_dig_item_desc.pct_desc_4    = 0
  LET p_ped_dig_item_desc.pct_desc_5    = 0
  LET p_ped_dig_item_desc.pct_desc_6    = 0
  LET p_ped_dig_item_desc.pct_desc_7    = 0
  LET p_ped_dig_item_desc.pct_desc_8    = 0
  LET p_ped_dig_item_desc.pct_desc_9    = 0
  LET p_ped_dig_item_desc.pct_desc_10   = 0

  LET t_ped_dig_item_desc[p_ind].pct_desc_1  = 0
  LET t_ped_dig_item_desc[p_ind].pct_desc_2  = 0
  LET t_ped_dig_item_desc[p_ind].pct_desc_3  = 0
  LET t_ped_dig_item_desc[p_ind].pct_desc_4  = 0
  LET t_ped_dig_item_desc[p_ind].pct_desc_5  = 0
  LET t_ped_dig_item_desc[p_ind].pct_desc_6  = 0
  LET t_ped_dig_item_desc[p_ind].pct_desc_7  = 0
  LET t_ped_dig_item_desc[p_ind].pct_desc_8  = 0
  LET t_ped_dig_item_desc[p_ind].pct_desc_9  = 0
  LET t_ped_dig_item_desc[p_ind].pct_desc_10 = 0

 LET m_pct_comissao_2 = 0
 LET m_pct_comissao_3 = 0
 LET m_cod_repres_3   = NULL

 END FOR
  LET p_ind = 0

 END FUNCTION

#-------------------------------------#
 FUNCTION vdp4284_busca_qtd_decimais()
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
      LET l_cod_tip_carteira = ' '
   END IF

   WHENEVER ERROR CONTINUE
   SELECT qtd_dec_preco_unit
     INTO l_qtd_decimais
     FROM tipo_carteira
    WHERE cod_tip_carteira = l_cod_tip_carteira
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      LET l_qtd_decimais = 0
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
         LET l_qtd_decimais = 0
      END IF
   END IF

   CALL vdp1519_calcula_pre_unit( t_pedido_dig_item[pa_curr].pre_unit, 0,
                                  l_qtd_decimais )
                                  RETURNING t_pedido_dig_item[pa_curr].pre_unit

   DISPLAY t_pedido_dig_item[pa_curr].pre_unit TO
           s_pedido_dig_item[sc_curr].pre_unit

END FUNCTION

#-------------------------------------#
 FUNCTION vdp4284_inclui_vendor_pedido()
#-------------------------------------#

  DEFINE p_ies_tipo                  LIKE cond_pgto.ies_tipo

   WHENEVER ERROR CONTINUE
   SELECT ies_tipo
     INTO p_ies_tipo
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_pedido_dig_mest.cod_cnd_pgto
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      LET p_ies_tipo = " "
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
 FUNCTION vdp4284_inclui_pedido_dig_comis()
#--------------------------------------#
 DEFINE lr_pedido_dig_comis  RECORD LIKE pedido_dig_comis.*

 IF p_pedido_dig_mest.ies_comissao = 'S' THEN
    IF p_pedido_dig_mest.cod_repres_adic IS NOT NULL THEN

       LET lr_pedido_dig_comis.cod_empresa    = p_cod_empresa
       LET lr_pedido_dig_comis.num_pedido     = p_pedido_dig_mest.num_pedido
       LET lr_pedido_dig_comis.pct_comissao_2 = m_pct_comissao_2

       IF m_cod_repres_3 IS NOT NULL THEN
          LET lr_pedido_dig_comis.cod_repres_3   = m_cod_repres_3
          LET lr_pedido_dig_comis.pct_comissao_3 = m_pct_comissao_3
       ELSE
          LET lr_pedido_dig_comis.cod_repres_3   = 0
          LET lr_pedido_dig_comis.pct_comissao_3 = 0
       END IF

       WHENEVER ERROR CONTINUE
       INSERT INTO pedido_dig_comis VALUES (lr_pedido_dig_comis.*)
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          LET p_houve_erro = TRUE
          CALL log003_err_sql('INSERT','pedido_dig_comis')
       END IF
    END IF
 END IF

END FUNCTION

#-------------------------------#
 FUNCTION vdp4284_mostra_zoom()
#-------------------------------#
  IF g_ies_grafico THEN
--# CALL fgl_dialog_setkeylabel("control-z","Zoom")
  ELSE
    DISPLAY "( Zoom )" AT 3,68
  END IF
 END FUNCTION

#------------------------------#
 FUNCTION vdp4284_apaga_zoom()
#------------------------------#
  IF g_ies_grafico THEN
--# CALL fgl_dialog_setkeylabel("control-z",NULL)
  ELSE
    DISPLAY "--------" AT 3,68
  END IF
 END FUNCTION

#-------------------------------#
 FUNCTION vdp4284_version_info()
#-------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/kanaflex_sa_industria_de_plasticos/vendas/vendas/programas/vdp4284.4gl $|$Revision: 4 $|$Date: 15/09/11 08:25 $|$Modtime: $" #Informa��es do controle de vers�o do SourceSafe - N�o remover esta linha (FRAMEWORK)

END FUNCTION
