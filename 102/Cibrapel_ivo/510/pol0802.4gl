#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: pol0802                                               #
# MODULOS.: pol0802                                               #
# OBJETIVO: DIGITACAO DA SOLICITACAO DE FATURAMENTO               #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_ordem_montag_lote  RECORD LIKE ordem_montag_lote.*,
         p_par_vdp            RECORD LIKE par_vdp.*,
         p_desc_nat_oper_885i RECORD LIKE desc_nat_oper_885.*,
         p_desc_nat_oper_885  RECORD LIKE desc_nat_oper_885.*,
         p_empresas_885       RECORD LIKE empresas_885.*,  
         p_tip_err            CHAR(1),               
         p_num_om             LIKE nf_solicit.num_om,
         p_num_lote_om        INTEGER,    
         p_ind_om             INTEGER,
         p_cod_empresa        LIKE empresa.cod_empresa,
         p_user               LIKE usuario.nom_usuario,
         p_nom_usuario        LIKE usuario.nom_usuario,
         p_den_via_transp     LIKE via_transporte.den_via_transporte,
         p_den_transpor       LIKE transport.den_transpor,
         p_num_solicit        LIKE nf_solicit.num_solicit,
         p_dat_refer          LIKE nf_solicit.dat_refer,
         p_cod_transpor       LIKE transport.cod_transpor,
         p_num_placa          LIKE nf_solicit.num_placa,
         p_uf_placa           CHAR(02),
         p_cod_tip_carteira   LIKE tipo_carteira.cod_tip_carteira,
         p_cod_entrega        LIKE entregas.cod_entrega,
         p_status             SMALLINT,
         p_ies_cons           SMALLINT,
         p_last_row           SMALLINT,
         pa_curr              SMALLINT,
         sc_curr              SMALLINT,
         p_ind                SMALLINT,
         p_prim_item_eh_wis   SMALLINT,
         p_prim_item_eh_wms   SMALLINT,
         p_den_empresa        CHAR(36),
         p_ies_impressao      CHAR(01),
         p_val_frete          LIKE nf_solicit.val_frete,
         p_val_seguro         LIKE nf_solicit.val_seguro,
         p_pes_tot_bruto      LIKE nf_solicit.pes_tot_bruto,
         p_pes_tot_liquido    LIKE nf_solicit.pes_tot_liquido

   DEFINE p_nf_solicit         RECORD
          cod_empresa          char(2),
          num_solicit          decimal(4,0),
          dat_refer            DATE,
          cod_via_transporte   decimal(2,0),
          cod_entrega          decimal(4,0),
          cod_mercado          char(2),
          cod_local_embarque   decimal(3,0),
          ies_mod_embarque     decimal(2,0),
          ies_tip_solicit      char(1),
          ies_lotes_geral      char(1),
          cod_tip_carteira     char(2),
          num_lote_om          decimal(6,0),
          num_om               decimal(6,0),
          num_controle         decimal(3,0),
          num_texto_1          decimal(3,0),
          num_texto_2          decimal(3,0),
          num_texto_3          decimal(3,0),
          val_frete            decimal(15,2),
          val_seguro           decimal(15,2),
          val_frete_ex         decimal(15,2),
          val_seguro_ex        decimal(15,2),
          pes_tot_bruto        decimal(13,4),
          ies_situacao         char(1),
          num_sequencia        SMALLINT,
          nom_usuario          char(8),
          cod_transpor         char(15),
          num_placa            char(7),
          num_volume           decimal(6,0),
          cod_embal_1          char(3),
          qtd_embal_1          decimal(6,0),
          cod_embal_2          char(3),
          qtd_embal_2          decimal(4,0),
          cod_embal_3          char(3),
          qtd_embal_3          decimal(4,0),
          cod_embal_4          char(3),
          qtd_embal_4          decimal(4,0),
          cod_embal_5          char(3),
          qtd_embal_5          decimal(4,0),
          cod_cnd_pgto         decimal(3,0),
          pes_tot_liquido      decimal(13,4),
          qtd_dias_acr_dupl    decimal(3,0)
   END RECORD

   DEFINE p_nf_solicitr        RECORD
          cod_empresa          char(2),
          num_solicit          decimal(4,0),
          dat_refer            DATE,
          cod_via_transporte   decimal(2,0),
          cod_entrega          decimal(4,0),
          cod_mercado          char(2),
          cod_local_embarque   decimal(3,0),
          ies_mod_embarque     decimal(2,0),
          ies_tip_solicit      char(1),
          ies_lotes_geral      char(1),
          cod_tip_carteira     char(2),
          num_lote_om          decimal(6,0),
          num_om               decimal(6,0),
          num_controle         decimal(3,0),
          num_texto_1          decimal(3,0),
          num_texto_2          decimal(3,0),
          num_texto_3          decimal(3,0),
          val_frete            decimal(15,2),
          val_seguro           decimal(15,2),
          val_frete_ex         decimal(15,2),
          val_seguro_ex        decimal(15,2),
          pes_tot_bruto        decimal(13,4),
          ies_situacao         char(1),
          num_sequencia        SMALLINT,
          nom_usuario          char(8),
          cod_transpor         char(15),
          num_placa            char(7),
          num_volume           decimal(6,0),
          cod_embal_1          char(3),
          qtd_embal_1          decimal(6,0),
          cod_embal_2          char(3),
          qtd_embal_2          decimal(4,0),
          cod_embal_3          char(3),
          qtd_embal_3          decimal(4,0),
          cod_embal_4          char(3),
          qtd_embal_4          decimal(4,0),
          cod_embal_5          char(3),
          qtd_embal_5          decimal(4,0),
          cod_cnd_pgto         decimal(3,0),
          pes_tot_liquido      decimal(13,4),
          qtd_dias_acr_dupl    decimal(3,0)
   END RECORD

         
         
  DEFINE p_wsolicit       RECORD
            cod_cliente       CHAR(15),
            num_pedido        DECIMAL(6,0), 
            num_om            LIKE nf_solicit.num_om,
            num_controle      LIKE nf_solicit.num_controle,
            cod_cnd_pgto      LIKE nf_solicit.cod_cnd_pgto,
            qtd_dias_acr_dupl LIKE nf_solicit.qtd_dias_acr_dupl,
            num_texto_1       LIKE nf_solicit.num_texto_1,
            num_texto_2       LIKE nf_solicit.num_texto_2,
            num_texto_3       LIKE nf_solicit.num_texto_3,
            num_volume        LIKE nf_solicit.num_volume,
            ies_frete_seguro  CHAR(01),
            val_frete         LIKE nf_solicit.val_frete,
            val_seguro        LIKE nf_solicit.val_seguro,
            pes_tot_liquido   LIKE nf_solicit.pes_tot_liquido,
            pes_tot_bruto     LIKE nf_solicit.pes_tot_bruto
         END RECORD

  DEFINE t1_nf_solicit       ARRAY[200] OF RECORD
                               cod_cliente    CHAR(15),
                               num_pedido     DECIMAL(6,0), 
                               num_om         LIKE nf_solicit.num_om,
                               num_controle   LIKE nf_solicit.num_controle,
                               cod_cnd_pgto   LIKE nf_solicit.cod_cnd_pgto,
                               qtd_dias_acr_dupl  LIKE nf_solicit.qtd_dias_acr_dupl,
                               num_texto_1    LIKE nf_solicit.num_texto_1,
                               num_texto_2    LIKE nf_solicit.num_texto_2,
                               num_texto_3    LIKE nf_solicit.num_texto_3,
                               num_volume     LIKE nf_solicit.num_volume,
                               ies_frete_seguro CHAR(01)
                             END RECORD

  DEFINE t1_frete_seguro     ARRAY[200] OF RECORD
                               num_solicit      LIKE nf_solicit.num_solicit,
                               num_sequencia    LIKE nf_solicit.num_sequencia,
                               val_frete        LIKE nf_solicit.val_frete,
                               val_seguro       LIKE nf_solicit.val_seguro,
                               pes_tot_liquido  LIKE nf_solicit.pes_tot_liquido,
                               pes_tot_bruto    LIKE nf_solicit.pes_tot_bruto
                             END RECORD

  DEFINE t2_qtd_embal        ARRAY[500] OF RECORD
                               cod_embal      LIKE nf_solicit.cod_embal_1,
                               qtd_embal      DECIMAL(05,0)
                             END RECORD

  DEFINE t_ordens            ARRAY[200] OF RECORD
                               num_om         LIKE ordem_montag_mest.num_om
                             END RECORD

  DEFINE t_om_item          ARRAY[100] OF RECORD
                              cod_item       LIKE ordem_montag_item.cod_item,
                              den_item_reduz LIKE item.den_item_reduz,
                              qtd_reservada  LIKE ordem_montag_item.qtd_reservada,
                              pes_total_item LIKE ordem_montag_item.pes_total_item
                            END RECORD

  DEFINE p_nom_arquivo       CHAR(100),
         p_msg               CHAR(100),
         g_ies_ambiente      CHAR(01),
         p_comando           CHAR(080),
         p_caminho           CHAR(080),
         p_nom_tela          CHAR(080),
         p_help              CHAR(080),
         p_cancel            INTEGER,
         comando             CHAR(080)
  DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

DEFINE  p_contador               SMALLINT,
        p_count                  SMALLINT

MAIN
LET p_versao = "POL0802-10.02.00" #Favor nao alterar esta linha (SUPORTE)
  CALL log0180_conecta_usuario()

  WHENEVER ERROR CONTINUE
  CALL log1400_isolation()              
  SET LOCK MODE TO WAIT
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho CLIPPED
  OPTIONS
    HELP     FILE p_help ,
    INSERT   KEY  control-i,
    DELETE   KEY  control-e,
    NEXT     KEY  control-f,
    PREVIOUS KEY  control-b

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user

  IF p_status = 0 THEN
     SELECT par_vdp.* INTO p_par_vdp.*
       FROM par_vdp
      WHERE par_vdp.cod_empresa = p_cod_empresa
     CALL pol0802_cria_temp()  
     CALL pol0802_controle()
  END IF
END MAIN

#---------------------------#
 FUNCTION pol0802_cria_temp()
#---------------------------#

   WHENEVER ERROR CONTINUE

   DROP TABLE wsolicit
   CREATE TEMP TABLE wsolicit
     (
      cod_cliente    CHAR(15),
      num_pedido     DECIMAL(6,0), 
      num_om         DECIMAL(6,0), 
      num_controle   DECIMAL(6,0), 
      cod_cnd_pgto   DECIMAL(3,0), 
      qtd_dias_acr_dupl  DECIMAL(3,0), 
      num_texto_1    DECIMAL(3,0), 
      num_texto_2    DECIMAL(3,0), 
      num_texto_3    DECIMAL(3,0), 
      num_volume     DECIMAL(7,0), 
      ies_frete_seguro CHAR(01),
      val_frete       DECIMAL(15,2),
      val_seguro      DECIMAL(15,2),
      pes_tot_liquido DECIMAL(17,6),
      pes_tot_bruto   DECIMAL(17,6)
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-wsolicit")
   END IF
   
   DROP TABLE wfrete
   CREATE TEMP TABLE wfrete
     (
      num_controle   DECIMAL(6,0), 
      val_frete      DECIMAL(15,2)
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-wfrete")
   END IF

   DROP TABLE sol_tmp
   CREATE TEMP TABLE sol_tmp
     (
      num_om         DECIMAL(6,0), 
      num_controle   DECIMAL(6,0),
      num_pedido     DECIMAL(6,0) 
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-sol_tmp")
   END IF

   
END FUNCTION

#-------------------------#
 FUNCTION pol0802_controle()
#-------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  INITIALIZE p_nf_solicit.*,
             p_nf_solicitr.* TO NULL

  CALL log130_procura_caminho("pol0802") RETURNING p_nom_tela
  OPEN WINDOW w_pol08020 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Incluir" "Inclui Solicitacao de Faturamento"
      HELP 0001
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","pol0802","IN")
      THEN CALL pol0802_digitacao_nf_solicit()
      END IF
    COMMAND "Modificar"  "Modifica Solicitacao de Faturamento selecionada"
      HELP 0002
      MESSAGE ""
      IF   p_nf_solicit.num_om  IS NOT NULL
      THEN IF   log005_seguranca(p_user,"VDP","pol0802","MO")
           THEN CALL pol0802_modificacao_solicitacao()
           END IF
      ELSE
       CALL log0030_mensagem("Consulte previamente para fazer a modificacao. "
                              ,"exclamation")
      END IF
    COMMAND "Excluir"  "Exclui Solicitacao de Faturamento selecionada"
      HELP 0003
      MESSAGE ""
      IF   p_nf_solicit.num_om  IS NOT NULL
      THEN IF   log005_seguranca(p_user,"VDP","pol0802","EX")
           THEN CALL pol0802_exclusao_solicitacao()
           END IF
      ELSE
           CALL log0030_mensagem("Consulte previamente para fazer a exclusao. ",
                                 "exclamation")
      END IF
    COMMAND "Consultar"  "Consulta tabela de Solicitacao de Faturamento"
      HELP 0004
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","pol0802","CO")
      THEN CALL pol0802_query_solicitacao()
      END IF
    COMMAND "Seguinte"   "Exibe item seguinte"
      HELP 0005
      MESSAGE ""
      CALL pol0802_paginacao("SEGUINTE")
    COMMAND "Anterior"   "Exibe item anterior"
      HELP 0006
      MESSAGE ""
      CALL pol0802_paginacao("ANTERIOR")
    COMMAND "Listar"     "Lista tabela de Solicitacao de Faturamento"
      HELP 0007
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","pol0802","CO")
      THEN CALL pol0802_den_empresa()
           CALL pol0802_lista_solicitacao()
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0802_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
    # DATABASE logix
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol08020
END FUNCTION

#--------------------------------------#
 FUNCTION pol0802_digitacao_nf_solicit()
#--------------------------------------#
  LET p_nf_solicitr.* = p_nf_solicit.*
  CLEAR FORM
  INITIALIZE p_nf_solicit.*,
             p_ordem_montag_lote.*,
             t1_nf_solicit,
             t_ordens,         
             t1_frete_seguro,
             p_wsolicit.* TO NULL
             
  LET p_nf_solicit.cod_empresa        = p_cod_empresa
  LET p_nf_solicit.dat_refer          = TODAY
  LET p_nf_solicit.ies_tip_solicit    = "R"
  LET p_nf_solicit.ies_lotes_geral    = "N"
  LET p_nf_solicit.num_lote_om        = 0
  LET p_nf_solicit.cod_via_transporte = 1
  LET p_nf_solicit.cod_entrega        = 1
  LET p_nf_solicit.cod_tip_carteira   = "01"
  LET p_nf_solicit.cod_local_embarque = NULL
  LET p_nf_solicit.ies_mod_embarque   = NULL
  LET p_nf_solicit.cod_mercado        = NULL
  LET p_nf_solicit.val_frete          = 0
  LET p_nf_solicit.val_seguro         = 0
  LET p_nf_solicit.val_frete_ex       = 0
  LET p_nf_solicit.val_seguro_ex      = 0
  LET p_nf_solicit.pes_tot_bruto      = 0
  LET p_nf_solicit.pes_tot_liquido    = 0
  DISPLAY p_nf_solicit.cod_empresa TO cod_empresa
  DISPLAY p_nf_solicit.dat_refer   TO dat_refer

  IF pol0802_dados_mestre("INCLUSAO") THEN 
     IF pol0802_dados_solicitacao("INCLUSAO") THEN 
        IF pol0802_efetiva_inclusao() THEN
           CALL pol0802_atualiza_frete() 
           LET p_ies_cons = FALSE
           CALL set_count(0)
           CALL log085_transacao("COMMIT")
           IF SQLCA.sqlcode = 0 THEN 
              MESSAGE " Inclusao efetuada com sucesso " ATTRIBUTE(REVERSE)
           ELSE 
              CALL log003_err_sql("INCLUSAO","NF_SOLICIT")
              CALL log085_transacao("ROLLBACK")
           END IF
        ELSE 
           CALL log085_transacao("ROLLBACK")
        END IF
        RETURN
     END IF
  END IF
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_pol08020
  LET  int_flag = 0
  LET  p_nf_solicit.* = p_nf_solicitr.*
  CALL pol0802_exibe_dados_solicitacao()
  ERROR " Inclusao Cancelada "
END FUNCTION

#--------------------------------------#
 FUNCTION pol0802_dados_mestre(p_funcao)
#--------------------------------------#
 DEFINE p_funcao  CHAR(12)

  CALL log006_exibe_teclas("01 02 03 07", p_versao)
  CURRENT WINDOW IS w_pol08020

  INPUT BY NAME p_nf_solicit.num_solicit,
                p_nf_solicit.dat_refer,
                p_nf_solicit.cod_via_transporte,
                p_nf_solicit.cod_transpor,
                p_nf_solicit.num_placa,
                p_nf_solicit.cod_tip_carteira,
                p_nf_solicit.cod_entrega WITHOUT DEFAULTS

    BEFORE FIELD num_solicit
           LET p_contador = 0 
           IF   p_funcao = "MODIFICACAO"
           THEN NEXT FIELD dat_refer
           END IF
           DISPLAY "--------" AT 3,68

    AFTER  FIELD num_solicit
           IF   pol0802_verifica_num_solicit()
           THEN ERROR " Solicitacao ja' digitada - Use Modificao "
                NEXT FIELD num_solicit
           END IF

    BEFORE FIELD dat_refer
           DISPLAY "--------" AT 3,68

    AFTER FIELD dat_refer
           IF   pol0802_verifica_data()
           THEN IF   log004_confirm(10,32)
                THEN
                ELSE NEXT FIELD dat_refer
                END IF
           ELSE IF   p_nf_solicit.dat_refer <> TODAY
                THEN ERROR "Data de referencia diferente da data corrente. Verifique parametros (VDP2330)"
                     IF   p_par_vdp.par_vdp_txt[326] = "S"
                     THEN IF   log004_confirm(10,32)
                          THEN
                          ELSE NEXT FIELD dat_refer
                          END IF
                     ELSE NEXT FIELD dat_refer
                     END IF
                END IF
           END IF

    BEFORE FIELD cod_via_transporte
           DISPLAY "( Zoom )" AT 3,68

    AFTER  FIELD cod_via_transporte
           IF   p_nf_solicit.cod_via_transporte IS NULL
           THEN
           ELSE IF   pol0802_verifica_via_transporte()
                THEN
                ELSE ERROR " Via de Transporte nao cadastrada "
                     NEXT FIELD cod_via_transporte
                END IF
           END IF
           DISPLAY "--------" AT 3,68

    BEFORE FIELD cod_transpor
           DISPLAY "( Zoom )" AT 3,68

    AFTER  FIELD cod_transpor
           IF p_nf_solicit.cod_transpor IS NOT NULL THEN 
              IF pol0802_verifica_cod_transpor() THEN
              ELSE
                  ERROR " Codigo da Transportadora NAO cadastrado "
                  NEXT FIELD cod_transpor
              END IF
           END IF
           DISPLAY "--------" AT 3,68
#--        CALL dialog.keysetlabel('control-z', NULL)

    BEFORE FIELD cod_entrega
           DISPLAY "( Zoom )" AT 3,68
#--        CALL dialog.keysetlabel('control-z','Zoom')
    AFTER  FIELD cod_entrega
           IF   p_nf_solicit.cod_entrega IS NULL
           THEN ERROR " Campo deve ser preenchido "
                NEXT FIELD cod_entrega
           ELSE IF   pol0802_verifica_cod_entrega()
                THEN
                ELSE ERROR " Entrega NAO cadastrada "
                     NEXT FIELD cod_entrega
                END IF
           END IF
           DISPLAY "--------" AT 3,68
#--        CALL dialog.keysetlabel('control-z', NULL)

    AFTER FIELD num_placa 
           IF p_nf_solicit.num_placa IS NOT NULL THEN 
              IF p_uf_placa IS NULL THEN 
                 ERROR " UF PLACA INVALIDO "
                 NEXT FIELD num_placa
              END IF 
           END IF
                 
    BEFORE FIELD cod_tip_carteira
           DISPLAY "( Zoom )" AT 3,68
#--        CALL dialog.keysetlabel('control-z','Zoom')
    AFTER  FIELD cod_tip_carteira
           IF   p_nf_solicit.cod_tip_carteira IS NULL
           THEN ERROR " Campo deve ser preenchido "
                NEXT FIELD cod_tip_carteira
           ELSE IF   pol0802_verifica_cod_tip_cart()
                THEN
                ELSE ERROR " Carteira NAO cadastrada "
                     NEXT FIELD cod_tip_carteira
                END IF
           END IF
           DISPLAY "--------" AT 3,68
#--        CALL dialog.keysetlabel('control-z', NULL)

    ON KEY (control-z,f4)
           CALL pol0802_popup()

    ON KEY (control-w,f1)
           CALL pol0802_help()
  END INPUT
  DISPLAY "--------" AT 3,68
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_pol08020

  IF   int_flag = 0
  THEN LET p_num_solicit      = p_nf_solicit.num_solicit
       LET p_dat_refer        = p_nf_solicit.dat_refer
       LET p_cod_transpor     = p_nf_solicit.cod_transpor
       LET p_num_placa        = p_nf_solicit.num_placa
       LET p_cod_tip_carteira = p_nf_solicit.cod_tip_carteira
       LET p_cod_entrega      = p_nf_solicit.cod_entrega
       RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#----------------------------------#
  FUNCTION pol0802_verifica_data()
#----------------------------------#
  DEFINE p_dat_ult_fat     DATE,
         p_num_solicit     LIKE nf_solicit.num_solicit,
         p_nom_usuario     LIKE nf_solicit.nom_usuario,
         p_dat_refer       LIKE nf_solicit.dat_refer

  INITIALIZE p_dat_ult_fat,
             p_num_solicit,
             p_nom_usuario,
             p_dat_refer  TO NULL

   SELECT dat_ult_fat INTO p_dat_ult_fat
     FROM fat_numero
    WHERE fat_numero.cod_empresa = p_cod_empresa

   IF   sqlca.sqlcode = 0
   THEN IF   p_dat_ult_fat > p_nf_solicit.dat_refer
        THEN OPEN  WINDOW w_pol08021 at 10,30 WITH 5 rows, 35 columns
               ATTRIBUTE (BORDER, PROMPT LINE LAST)
             DISPLAY " Data de referencia menor que a" AT 01,01
             DISPLAY " ultima nota fiscal emitida. " at 02,01
             DISPLAY " Data da ultima nota ",p_dat_ult_fat using "dd/mm/yyyy" AT 03,01
             DISPLAY " " AT 04,01
             PROMPT " Tecle enter p/ continuar " FOR comando
             CLOSE WINDOW w_pol08021
             RETURN TRUE
        END IF
   ELSE RETURN FALSE
   END IF
   DECLARE c_ver_data CURSOR WITH HOLD FOR
   SELECT nf_solicit.nom_usuario,
          MAX(nf_solicit.num_solicit),
          MAX(nf_solicit.dat_refer)
     INTO p_nom_usuario,
          p_num_solicit,
          p_dat_refer
     FROM nf_solicit
     WHERE nf_solicit.cod_empresa = p_cod_empresa
       AND nf_solicit.dat_refer <> p_nf_solicit.dat_refer
     GROUP BY nf_solicit.nom_usuario
    FOREACH c_ver_data
    IF   p_num_solicit > 0
    THEN OPEN  WINDOW w_pol08021 at 10,20 WITH 5 rows, 40 columns
               ATTRIBUTE (BORDER, PROMPT LINE LAST)
         DISPLAY " Data de referencia diferente que " AT 01,01
         DISPLAY " data de referencia da solicitacao " at 02,01
         DISPLAY p_num_solicit USING "####&",
                 " do usuario(a) ",p_nom_usuario," - ",
                 p_dat_refer USING "DD/MM/YYYY"  AT 03,01
         DISPLAY " " AT 04,01
         PROMPT " Tecle enter p/ continuar " FOR comando
         CLOSE WINDOW w_pol08021
         RETURN TRUE
    END IF
 END FOREACH
    RETURN FALSE
END FUNCTION

#-----------------------#
 FUNCTION pol0802_popup()
#-----------------------#
  DEFINE p_cod_transpor        LIKE nf_solicit.cod_transpor,
         p_cod_via_transporte  LIKE nf_solicit.cod_via_transporte,
         p_cod_tip_carteira    LIKE nf_solicit.cod_tip_carteira,
         p_cod_entrega         LIKE nf_solicit.cod_entrega,
         p_cnd_pgto            LIKE nf_solicit.cod_cnd_pgto
  CASE
    WHEN infield(cod_transpor)
         LET  p_cod_transpor = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol08020
         IF   p_cod_transpor IS NOT NULL
         THEN LET p_nf_solicit.cod_transpor = p_cod_transpor
              DISPLAY p_nf_solicit.cod_transpor TO cod_transpor
         END IF
    WHEN infield(cod_via_transporte)
         CALL log009_popup(6,25,"VIA TRANSPORTE","via_transporte",
                          "cod_via_transporte","den_via_transporte",
                          "vdp2520","N","") RETURNING p_cod_via_transporte
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol08020
         IF   p_cod_via_transporte IS NOT NULL
         THEN LET p_nf_solicit.cod_via_transporte = p_cod_via_transporte
              DISPLAY BY NAME p_nf_solicit.cod_via_transporte
         END IF
    WHEN infield(cod_cnd_pgto)
         CALL log009_popup(6,25,"CONDICAO PAGAMENTO","cond_pgto",
                          "cod_cnd_pgto","den_cnd_pgto",
                          "vdp0140","N","") RETURNING p_cnd_pgto
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol08020
         IF   p_cnd_pgto IS NOT NULL
         THEN LET t1_nf_solicit[pa_curr].cod_cnd_pgto = p_cnd_pgto
              DISPLAY t1_nf_solicit[pa_curr].cod_cnd_pgto TO
                       s_nf_solicit[sc_curr].cod_cnd_pgto
         END IF
    WHEN infield(cod_entrega)
        CALL log009_popup(6,25,"ENTREGAS","entregas",
                          "cod_entrega","den_entrega",
                          "vdp0780","N","") RETURNING p_cod_entrega
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol08020
         #CALL vdp710_delim_fields()
         IF   p_cod_entrega IS NOT NULL
         THEN LET p_nf_solicit.cod_entrega = p_cod_entrega
              DISPLAY BY NAME p_nf_solicit.cod_entrega
         END IF
    WHEN infield(cod_tip_carteira)
          CALL log009_popup(6,25,"CARTEIRA","tipo_carteira",
                            "cod_tip_carteira","den_tip_carteira",
                            "vdp6310","N","") RETURNING p_cod_tip_carteira
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol08020
         #CALL vdp710_delim_fields()
         IF   p_cod_tip_carteira IS NOT NULL
         THEN LET p_nf_solicit.cod_tip_carteira = p_cod_tip_carteira
              DISPLAY BY NAME p_nf_solicit.cod_tip_carteira
         END IF
    WHEN infield(num_texto_1)
          CALL log009_popup(6,25,"TEXTO NF","texto_nf",
                            "cod_texto","des_texto",
                            "vdp0390","N","") RETURNING t1_nf_solicit[pa_curr].num_texto_1
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol08020
         #CALL vdp710_delim_fields()
         DISPLAY t1_nf_solicit[pa_curr].num_texto_1 TO s_nf_solicit[sc_curr].num_texto_1
    WHEN infield(num_texto_2)
         CALL log009_popup(6,25,"TEXTO NF","texto_nf",
                          "cod_texto","des_texto",
                          "vdp0390","N","") RETURNING t1_nf_solicit[pa_curr].num_texto_2
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol08020
         #CALL vdp710_delim_fields()
         DISPLAY t1_nf_solicit[pa_curr].num_texto_2 TO s_nf_solicit[sc_curr].num_texto_2
    WHEN infield(num_texto_3)
        CALL log009_popup(6,25,"TEXTO NF","texto_nf",
                         "cod_texto","des_texto",
                         "vdp0390","N","") RETURNING t1_nf_solicit[pa_curr].num_texto_3
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol08020
         #CALL vdp710_delim_fields()
         DISPLAY t1_nf_solicit[pa_curr].num_texto_3 TO s_nf_solicit[sc_curr].num_texto_3
  END CASE
END FUNCTION

#---------------------#
 FUNCTION pol0802_help()
#---------------------#
  CASE
    WHEN infield(num_solicit)          CALL showhelp(3245)
    WHEN infield(dat_refer)            CALL showhelp(3238)
    WHEN infield(cod_via_transporte)   CALL showhelp(3246)
    WHEN infield(cod_transpor)         CALL showhelp(3247)
    WHEN infield(num_placa)            CALL showhelp(3248)
    WHEN infield(cod_tip_carteira)     CALL showhelp(3249)
    WHEN infield(cod_entrega)          CALL showhelp(3250)
    WHEN infield(num_om)               CALL showhelp(3251)
    WHEN infield(num_controle)         CALL showhelp(3252)
    WHEN infield(cod_cnd_pgto)         CALL showhelp(2185)
    WHEN infield(qtd_dias_acr_dupl)    CALL showhelp(5465)
    WHEN infield(num_texto_1)          CALL showhelp(3239)
    WHEN infield(num_texto_2)          CALL showhelp(3239)
    WHEN infield(num_texto_3)          CALL showhelp(3239)
    WHEN infield(num_volume)           CALL showhelp(3253)
    WHEN infield(ies_frete_seguro)     CALL showhelp(3256)
    WHEN infield(val_frete)            CALL showhelp(3351)
    WHEN infield(val_seguro)           CALL showhelp(3352)
    WHEN infield(pes_tot_liquido)      CALL showhelp(5416)
    WHEN infield(pes_tot_bruto)        CALL showhelp(3353)
  END CASE
END FUNCTION

#--------------------------------------#
 FUNCTION pol0802_verifica_num_solicit()
#--------------------------------------#
 SELECT UNIQUE num_solicit FROM nf_solicit
  WHERE nf_solicit.cod_empresa = p_cod_empresa
    AND nf_solicit.num_solicit = p_nf_solicit.num_solicit
    AND nf_solicit.nom_usuario = p_user
 IF   sqlca.sqlcode = 0
 THEN RETURN TRUE
 ELSE RETURN FALSE
 END IF
 END FUNCTION

#-----------------------------------------#
 FUNCTION pol0802_verifica_via_transporte()
#-----------------------------------------#
  SELECT den_via_transporte INTO p_den_via_transp FROM via_transporte
   WHERE via_transporte.cod_via_transporte = p_nf_solicit.cod_via_transporte
  IF   sqlca.sqlcode = 0
  THEN DISPLAY p_den_via_transp TO den_via_transporte
       RETURN true
  ELSE RETURN false
  END IF
END FUNCTION

#---------------------------------------#
 FUNCTION pol0802_verifica_cod_transpor()
#---------------------------------------#
  SELECT den_transpor INTO p_den_transpor FROM transport
   WHERE transport.cod_transpor = p_nf_solicit.cod_transpor
  IF   sqlca.sqlcode = 0
  THEN DISPLAY p_den_transpor TO den_transpor
       RETURN true
  ELSE SELECT nom_cliente INTO p_den_transpor FROM clientes
        WHERE clientes.cod_cliente  = p_nf_solicit.cod_transpor
       DISPLAY p_den_transpor TO den_transpor
       IF   sqlca.sqlcode = 0
       THEN RETURN TRUE
       ELSE RETURN false
       END IF
  END IF
END FUNCTION

#---------------------------------------#
 FUNCTION pol0802_verifica_cod_tip_cart()
#---------------------------------------#
  SELECT * FROM tipo_carteira
   WHERE tipo_carteira.cod_tip_carteira = p_nf_solicit.cod_tip_carteira

  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#----------------------------------------#
 FUNCTION pol0802_verifica_cod_entrega()
#----------------------------------------#
  SELECT * FROM entregas
   WHERE cod_entrega = p_nf_solicit.cod_entrega

  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0802_dados_solicitacao(p_oper)
#-----------------------------------------#
  DEFINE p_oper         CHAR(11)

  DEFINE l_num_om       LIKE nf_solicit.num_om

  CALL log006_exibe_teclas("01 02 07", p_versao)
  CURRENT WINDOW IS w_pol08020
  LET p_nom_usuario = NULL

  INPUT ARRAY t1_nf_solicit WITHOUT DEFAULTS
         FROM s_nf_solicit.*

   BEFORE ROW
   
     LET pa_curr  = ARR_CURR()
     LET sc_curr  = SCR_LINE()   


   BEFORE FIELD num_om
   
     LET l_num_om = t1_nf_solicit[pa_curr].num_om  
   
     IF t_ordens[pa_curr].num_om > 0 THEN
        LET t1_nf_solicit[pa_curr].num_om = t_ordens[pa_curr].num_om
        DISPLAY t1_nf_solicit[pa_curr].num_om             
     END IF

     IF t1_nf_solicit[1].num_om IS NULL AND
        t1_nf_solicit[2].num_om IS NULL THEN
        INITIALIZE p_prim_item_eh_wis TO NULL
        INITIALIZE p_prim_item_eh_wms TO NULL
     END IF
     DISPLAY "--------" AT 3,68
--#  CALL dialog.keysetlabel('control-z', NULL)

   AFTER  FIELD num_om

       IF t1_nf_solicit[pa_curr].num_om IS NOT NULL THEN
          IF pol0802_om_ja_digitada() THEN
              ERROR "Ordem de Montagem ja' digitada pelo usuario ",p_nom_usuario
              NEXT FIELD num_om
          ELSE
             SELECT *
               FROM ordem_montag_mest
              WHERE ordem_montag_mest.cod_empresa = p_cod_empresa
                AND ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
             IF sqlca.sqlcode = NOTFOUND THEN
                ERROR " Ordem de Montagem nao cadastrada "
                NEXT FIELD num_om
             ELSE
                IF p_oper = "INCLUSAO" THEN 
                   CALL pol0802_busca_cliente()
                END IF     
                IF pol0802_verifica_om_bloqueada() = FALSE THEN
                   ERROR " Ordem de Montagem Bloqueada. "
                   NEXT FIELD num_om
                END IF
                IF pol0802_verifica_om_embalagem() = FALSE THEN
                   ERROR " Ordem de Montagem em Embalagem. "
                   NEXT FIELD num_om
                END IF
                IF pol0802_verifica_om_vendas() = FALSE THEN
                   ERROR " Ordem de Montagem em Vendas. "
                   NEXT FIELD num_om
                END IF
                IF pol0802_verifica_om_fiscal() = FALSE THEN
                   ERROR " Ordem de Montagem no Fiscal. "
                   NEXT FIELD num_om
                END IF
                IF pol0802_verifica_om_faturada() = FALSE THEN
                   ERROR " Ordem de Montagem Ja' Faturada "
                   NEXT FIELD num_om
                END IF
                IF pol0802_verifica_om_cancelada() = FALSE THEN
                   ERROR " Ordem de Montagem Cancelada "
                   NEXT FIELD num_om
                END IF
             END IF
          END IF    
       END IF

    BEFORE FIELD num_controle
      IF t1_nf_solicit[pa_curr].num_om IS NULL
      THEN NEXT FIELD num_om
      END IF

    AFTER FIELD num_controle
      IF t1_nf_solicit[pa_curr].num_controle IS NOT NULL THEN
         IF NOT pol0802_consiste_controle() THEN
            MESSAGE 'INFORME OUTRO NUMERO DE CONTROLE'
            NEXT FIELD num_controle
         END IF    
      END IF

    BEFORE FIELD cod_cnd_pgto
       IF   p_par_vdp.par_vdp_txt[288,288] = "N"
       THEN NEXT FIELD num_texto_1
       ELSE DISPLAY "( Zoom )" AT 3,68
--#         CALL dialog.keysetlabel('control-z','Zoom')
            LET pa_curr = arr_curr()
            LET sc_curr = scr_line()
       END IF
       
    AFTER  FIELD cod_cnd_pgto
       IF t1_nf_solicit[pa_curr].cod_cnd_pgto IS NOT NULL
       THEN SELECT * FROM  cond_pgto
             WHERE  cond_pgto.cod_cnd_pgto =
                    t1_nf_solicit[pa_curr].cod_cnd_pgto
              IF sqlca.sqlcode = NOTFOUND
              THEN ERROR " Condicao de Pagamento nao cadastrada "
                   NEXT FIELD cod_cnd_pgto
              END IF
       END IF
       DISPLAY "--------" AT 3,68
--#    CALL dialog.keysetlabel('control-z', NULL)

    BEFORE FIELD num_texto_1
       DISPLAY "( Zoom )" AT 3,68
--#    CALL dialog.keysetlabel('control-z','Zoom')
    AFTER  FIELD num_texto_1
       IF t1_nf_solicit[pa_curr].num_texto_1 IS NOT NULL
       THEN SELECT * FROM  texto_nf
                WHERE  texto_nf.cod_texto = t1_nf_solicit[pa_curr].num_texto_1
              IF sqlca.sqlcode = NOTFOUND
              THEN ERROR " Texto-1 nao cadastrado "
                   NEXT FIELD num_texto_1
              END IF
       ELSE NEXT FIELD num_volume
       END IF
       DISPLAY "--------" AT 3,68
--#    CALL dialog.keysetlabel('control-z', NULL)

    BEFORE FIELD num_texto_2
       DISPLAY "( Zoom )" AT 3,68
--#    CALL dialog.keysetlabel('control-z','Zoom')
    AFTER  FIELD num_texto_2
       IF t1_nf_solicit[pa_curr].num_texto_2 IS NOT NULL
       THEN SELECT * FROM  texto_nf
                WHERE  texto_nf.cod_texto = t1_nf_solicit[pa_curr].num_texto_2
              IF sqlca.sqlcode = NOTFOUND
              THEN ERROR " Texto-2 nao cadastrado "
                   NEXT FIELD num_texto_2
              END IF
       END IF
       DISPLAY "--------" AT 3,68
--#    CALL dialog.keysetlabel('control-z', NULL)

    BEFORE FIELD num_texto_3
       DISPLAY "( Zoom )" AT 3,68
--#    CALL dialog.keysetlabel('control-z','Zoom')
    AFTER  FIELD num_texto_3
       IF t1_nf_solicit[pa_curr].num_texto_3 IS NOT NULL
       THEN SELECT * FROM  texto_nf
                WHERE  texto_nf.cod_texto = t1_nf_solicit[pa_curr].num_texto_3
              IF sqlca.sqlcode = NOTFOUND
              THEN ERROR " Texto0-3 nao cadastrado "
                   NEXT FIELD num_texto_3
              END IF
       END IF
       DISPLAY "--------" AT 3,68
       
    AFTER FIELD num_volume
       IF t1_nf_solicit[pa_curr].num_volume IS NULL THEN
          ERROR "Campo obrigat�rio!"
          NEXT FIELD num_volume
       END IF

    AFTER FIELD ies_frete_seguro
       IF   t1_nf_solicit[pa_curr].ies_frete_seguro = "S"
       THEN CALL pol0802_frete_seguro(pa_curr,
                                     p_nf_solicit.num_solicit)
            LET t1_frete_seguro[pa_curr].val_frete  = p_val_frete
            LET t1_frete_seguro[pa_curr].val_seguro = p_val_seguro
            LET t1_frete_seguro[pa_curr].pes_tot_bruto = p_pes_tot_bruto
            LET t1_frete_seguro[pa_curr].pes_tot_liquido = p_pes_tot_liquido
       ELSE LET t1_frete_seguro[pa_curr].val_frete  = 0
            LET t1_frete_seguro[pa_curr].val_seguro = 0
            LET t1_frete_seguro[pa_curr].pes_tot_bruto = 0
            LET t1_frete_seguro[pa_curr].pes_tot_liquido = 0
       END IF

    ON KEY (control-w,f1)
           CALL pol0802_help()
    ON KEY (control-z,f4)
           CALL pol0802_popup()
    ON KEY (control-o)
           CALL pol0802_exibe_item(t1_nf_solicit[pa_curr].num_om)
  AFTER INPUT
  END INPUT
  IF int_flag = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF

END FUNCTION

#-------------------------------------#
 FUNCTION pol0802_consiste_controle()
#-------------------------------------#
  DEFINE l_ind  INTEGER,
         l_num_pedido       LIKE pedidos.num_pedido,
         l_ies_itens_nff    LIKE tipo_carteira.ies_itens_nff,
         l_cod_tip_carteira LIKE tipo_carteira.cod_tip_carteira
  
  SELECT * 
    INTO p_empresas_885.*
    FROM empresas_885
   WHERE cod_emp_oficial = p_cod_empresa
  IF SQLCA.sqlcode <> 0 THEN
     LET p_empresas_885.cod_emp_gerencial = p_cod_empresa
  END IF      
  
  SELECT MAX(num_pedido)
    INTO l_num_pedido
    FROM ordem_montag_item
   WHERE cod_empresa = p_cod_empresa
     AND num_om      = t1_nf_solicit[pa_curr].num_om 
  
  SELECT * 
    INTO p_desc_nat_oper_885.*
    FROM desc_nat_oper_885
   WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
     AND num_pedido  = l_num_pedido 
  
  FOR l_ind = 1 TO 200 
    IF t1_nf_solicit[l_ind].num_om IS NULL THEN
       EXIT FOR
    END IF 	   

    IF t1_nf_solicit[pa_curr].num_controle = t1_nf_solicit[l_ind].num_controle THEN
       IF l_ind <> pa_curr THEN
          SELECT MAX(num_pedido)
            INTO l_num_pedido
            FROM ordem_montag_item
           WHERE cod_empresa = p_cod_empresa
             AND num_om      = t1_nf_solicit[l_ind].num_om 
          
          SELECT * 
            INTO p_desc_nat_oper_885i.*
            FROM desc_nat_oper_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
             AND num_pedido  = l_num_pedido 

          SELECT cod_tip_carteira 
            INTO l_cod_tip_carteira 
            FROM pedidos
           WHERE cod_empresa = p_cod_empresa
             AND num_pedido  = l_num_pedido
             
          SELECT ies_itens_nff
            INTO l_ies_itens_nff
            FROM tipo_carteira 
           WHERE cod_tip_carteira = l_cod_tip_carteira
           
          IF l_ies_itens_nff = 'S' THEN       
             ERROR 'Tipo de carteira do pedido permite somente um item por nota para om ',t1_nf_solicit[l_ind].num_om
             RETURN FALSE
          END IF               

          SELECT MAX(num_pedido)
            INTO l_num_pedido
            FROM ordem_montag_item
           WHERE cod_empresa = p_cod_empresa
             AND num_om      = t1_nf_solicit[pa_curr].num_om 
             
          SELECT cod_tip_carteira 
            INTO l_cod_tip_carteira 
            FROM pedidos
           WHERE cod_empresa = p_cod_empresa
             AND num_pedido  = l_num_pedido
             
          SELECT ies_itens_nff
            INTO l_ies_itens_nff
            FROM tipo_carteira 
           WHERE cod_tip_carteira = l_cod_tip_carteira
           
          IF l_ies_itens_nff = 'S' THEN       
             ERROR 'Tipo de carteira do pedido permite somente um item por nota para om ',t1_nf_solicit[pa_curr].num_om 
             RETURN FALSE
          END IF               

          IF p_desc_nat_oper_885.pct_desc_valor <>  p_desc_nat_oper_885i.pct_desc_valor OR 
             p_desc_nat_oper_885.pct_desc_qtd   <> p_desc_nat_oper_885i.pct_desc_qtd THEN
             ERROR 'Pedidos incompativeis para juntar em uma unica nota'
             RETURN FALSE
          END IF               
       
          IF t1_nf_solicit[pa_curr].cod_cliente <>  t1_nf_solicit[l_ind].cod_cliente THEN 
             ERROR 'Controle nao pode ser o mesmo para clientes diferentes'
             RETURN FALSE
          END IF              
          
          IF t1_nf_solicit[pa_curr].cod_cnd_pgto <>  t1_nf_solicit[l_ind].cod_cnd_pgto THEN 
             ERROR 'Controle nao pode ser o mesmo para condicao de pagamento diferente'
             RETURN FALSE
          END IF     
          
       END IF
    END IF        
  END FOR
  RETURN TRUE 
END FUNCTION

#-------------------------------------#
 FUNCTION pol0802_consiste_controle_ef()
#-------------------------------------#
  DEFINE l_ind  INTEGER,
         l_indi INTEGER,
         l_num_pedido  LIKE pedidos.num_pedido
  
  SELECT * 
    INTO p_empresas_885.*
    FROM empresas_885
   WHERE cod_emp_oficial = p_cod_empresa
  IF SQLCA.sqlcode <> 0 THEN
     LET p_empresas_885.cod_emp_gerencial = p_cod_empresa
  END IF      

  FOR l_indi = 1 TO 200 
  
     SELECT MAX(num_pedido)
       INTO l_num_pedido
       FROM ordem_montag_item
      WHERE cod_empresa = p_cod_empresa
        AND num_om      = t1_nf_solicit[l_indi].num_om 
  
     SELECT * 
       INTO p_desc_nat_oper_885.*
       FROM desc_nat_oper_885
      WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
        AND num_pedido  = l_num_pedido 
  
     FOR l_ind = 1 TO 200 
       IF t1_nf_solicit[l_ind].num_om IS NULL THEN
          EXIT FOR
       END IF 	   
     
       IF t1_nf_solicit[l_indi].num_controle = t1_nf_solicit[l_ind].num_controle THEN
          IF l_ind <> l_indi THEN
             SELECT MAX(num_pedido)
               INTO l_num_pedido
               FROM ordem_montag_item
              WHERE cod_empresa = p_cod_empresa
                AND num_om      = t1_nf_solicit[l_ind].num_om 
             
             SELECT * 
               INTO p_desc_nat_oper_885i.*
               FROM desc_nat_oper_885
              WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
                AND num_pedido  = l_num_pedido 
     
             IF p_desc_nat_oper_885.pct_desc_valor <>  p_desc_nat_oper_885i.pct_desc_valor OR 
                p_desc_nat_oper_885.pct_desc_qtd   <> p_desc_nat_oper_885i.pct_desc_qtd THEN
                ERROR 'Pedidos incompativeis para juntar em uma unica nota, oms ', t1_nf_solicit[l_indi].num_om, ' e ',t1_nf_solicit[l_ind].num_om
                RETURN FALSE
             END IF               
          
             IF t1_nf_solicit[l_indi].cod_cliente <>  t1_nf_solicit[l_ind].cod_cliente THEN 
                ERROR 'Controle nao pode ser o mesmo para clientes diferentes, oms', t1_nf_solicit[l_indi].num_om, ' e ',t1_nf_solicit[l_ind].num_om
                RETURN FALSE
             END IF              
             
             IF t1_nf_solicit[l_indi].cod_cnd_pgto <>  t1_nf_solicit[l_ind].cod_cnd_pgto THEN 
                ERROR 'Controle nao pode ser o mesmo para condicao de pagamento diferente, oms', t1_nf_solicit[l_indi].num_om, ' e ',t1_nf_solicit[l_ind].num_om
                RETURN FALSE
             END IF     
          END IF
       END IF        
     END FOR
  END FOR   
  RETURN TRUE 
END FUNCTION

#-------------------------------------#
 FUNCTION pol0802_busca_cliente()
#-------------------------------------#
  SELECT MAX(num_pedido)
    INTO t1_nf_solicit[pa_curr].num_pedido
    FROM ordem_montag_item 
   WHERE cod_empresa = p_cod_empresa
     AND num_om      = t1_nf_solicit[pa_curr].num_om
  
  SELECT cod_cliente
    INTO t1_nf_solicit[pa_curr].cod_cliente
    FROM pedidos
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = t1_nf_solicit[pa_curr].num_pedido 
      
  DISPLAY t1_nf_solicit[pa_curr].cod_cliente TO s_nf_solicit[sc_curr].cod_cliente    
  DISPLAY t1_nf_solicit[pa_curr].num_pedido  TO s_nf_solicit[sc_curr].num_pedido    
      
 END FUNCTION
 
#-------------------------------------#
 FUNCTION pol0802_verifica_om_bloqueada()
#-------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "B"

    IF sqlca.sqlcode = 0 THEN
       RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#-------------------------------------#
 FUNCTION pol0802_verifica_om_embalagem()
#-------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "E"

    IF sqlca.sqlcode = 0 THEN
       RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#-------------------------------------#
 FUNCTION pol0802_verifica_om_vendas()
#-------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "V"

    IF sqlca.sqlcode = 0 THEN
       RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#-------------------------------------#
 FUNCTION pol0802_verifica_om_fiscal()
#-------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "I"

    IF sqlca.sqlcode = 0 THEN
       RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#-------------------------------------#
 FUNCTION pol0802_verifica_om_faturada()
#-------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "F"

    IF sqlca.sqlcode = 0
    THEN RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#-------------------------------------#
 FUNCTION pol0802_verifica_om_cancelada()
#-------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "C"

    IF sqlca.sqlcode = 0
    THEN RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#------------------------------------------------------#
 FUNCTION pol0802_frete_seguro(p_num_seq,p_num_solic)
#------------------------------------------------------#
  DEFINE p_num_solic LIKE nf_solicit.num_solicit,
         p_num_seq   LIKE nf_solicit.num_sequencia

  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol080201") RETURNING p_nom_tela
  OPEN WINDOW w_pol080201 AT 5,30 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  CURRENT WINDOW IS w_pol080201
  CALL log006_exibe_teclas("01 02 07", p_versao)
  CURRENT WINDOW IS w_pol080201
  IF   t1_frete_seguro[p_num_seq].val_frete > 0
  THEN LET p_val_frete = t1_frete_seguro[p_num_seq].val_frete
  ELSE LET p_val_frete = 0
  END IF
  IF   t1_frete_seguro[p_num_seq].val_seguro > 0
  THEN LET p_val_seguro = t1_frete_seguro[p_num_seq].val_seguro
  ELSE LET p_val_seguro = 0
  END IF
  IF   t1_frete_seguro[p_num_seq].pes_tot_bruto > 0
  THEN LET p_pes_tot_bruto = t1_frete_seguro[p_num_seq].pes_tot_bruto
  ELSE LET p_pes_tot_bruto = 0
  END IF
  IF   t1_frete_seguro[p_num_seq].pes_tot_liquido > 0
  THEN LET p_pes_tot_liquido = t1_frete_seguro[p_num_seq].pes_tot_liquido
  ELSE LET p_pes_tot_liquido = 0
  END IF
  DISPLAY p_val_frete   TO val_frete
  DISPLAY p_val_seguro  TO val_seguro
  DISPLAY p_pes_tot_bruto TO pes_tot_bruto
  DISPLAY p_pes_tot_liquido TO pes_tot_liquido
  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY p_num_seq     TO num_sequencia
  DISPLAY p_num_solic   TO num_solicit

    INPUT p_val_frete,
          p_val_seguro,
          p_pes_tot_liquido,
          p_pes_tot_bruto WITHOUT DEFAULTS
     FROM val_frete,
          val_seguro,
          pes_tot_liquido,
          pes_tot_bruto

     AFTER FIELD pes_tot_bruto
        IF p_pes_tot_bruto < p_pes_tot_liquido THEN
           ERROR "Peso bruto nao pode ser menor que o peso liquido. "
           NEXT FIELD pes_tot_bruto
        END IF

     ON KEY (control-w,f1)
        CALL pol0802_help()
     END INPUT
CALL log006_exibe_teclas("01", p_versao)

CURRENT WINDOW IS w_pol080201
CLOSE WINDOW w_pol080201
CURRENT WINDOW IS w_pol08020
END FUNCTION

#--------------------------------#
 FUNCTION pol0802_om_ja_digitada()
#--------------------------------#
  DEFINE p_subs    INTEGER
  LET p_subs = 0
  FOR p_subs = 1 TO (pa_curr - 1)
      IF t1_nf_solicit[p_subs].num_om  = t1_nf_solicit[pa_curr].num_om
      THEN RETURN TRUE
      END IF
  END FOR
  SELECT nom_usuario INTO p_nom_usuario FROM nf_solicit
   WHERE nf_solicit.cod_empresa  = p_cod_empresa
     AND nf_solicit.num_om       = t1_nf_solicit[pa_curr].num_om
     AND nf_solicit.nom_usuario <> p_user
  IF sqlca.sqlcode = 0
  THEN RETURN TRUE
  END IF
  SELECT nom_usuario INTO p_nom_usuario FROM nf_solicit
   WHERE nf_solicit.cod_empresa  = p_cod_empresa
     AND nf_solicit.num_om       = t1_nf_solicit[pa_curr].num_om
     AND nf_solicit.num_solicit <> p_nf_solicit.num_solicit
     AND nf_solicit.nom_usuario  = p_user
  IF sqlca.sqlcode = 0
  THEN RETURN TRUE
  END IF
  RETURN FALSE
  END FUNCTION

#---------------------------------#
 FUNCTION pol0802_efetiva_inclusao()
#---------------------------------#
 DEFINE l_count         INTEGER,
        l_val_frete     DECIMAL(15,2),
        l_num_om        DECIMAL(6,0),
        l_num_controle  DECIMAL(6,0),
        l_num_pedido    DECIMAL(6,0),
        l_num_ped_min   DECIMAL(6,0),
        l_qtd_ct        INTEGER       
 
IF pol0802_consiste_controle_ef() THEN 
   BEGIN WORK

   DELETE FROM wfrete 

   DELETE FROM nf_solicit
    WHERE nf_solicit.cod_empresa = p_cod_empresa
      AND nf_solicit.num_solicit = p_nf_solicit.num_solicit
      AND nf_solicit.nom_usuario = p_user
    IF sqlca.sqlcode <> 0
    THEN CALL log003_err_sql("EXCLUSAO", "NF_SOLCIT")
         RETURN FALSE
    END IF
    LET p_count = 0
   
   LET p_nf_solicit.ies_situacao  = "C"
   
   FOR pa_curr = 1 TO 200
       IF t1_nf_solicit[pa_curr].num_om IS NOT NULL THEN
          LET p_count = p_count + 1
          LET p_nf_solicit.num_sequencia     = p_count
          LET p_nf_solicit.cod_empresa       = p_cod_empresa
          LET p_nf_solicit.num_solicit       = p_num_solicit
          LET p_nf_solicit.dat_refer         = p_dat_refer
          LET p_nf_solicit.cod_transpor      = p_cod_transpor
          LET p_nf_solicit.num_placa         = p_num_placa
          LET p_nf_solicit.cod_tip_carteira  = '01'
          LET p_nf_solicit.cod_entrega       = p_cod_entrega
          LET p_nf_solicit.num_om            = t1_nf_solicit[pa_curr].num_om
          LET p_nf_solicit.num_controle      = t1_nf_solicit[pa_curr].num_controle
          LET p_nf_solicit.cod_cnd_pgto      = t1_nf_solicit[pa_curr].cod_cnd_pgto
          LET p_nf_solicit.qtd_dias_acr_dupl = t1_nf_solicit[pa_curr].qtd_dias_acr_dupl
          LET p_nf_solicit.num_texto_1       = t1_nf_solicit[pa_curr].num_texto_1
          LET p_nf_solicit.num_texto_2       = t1_nf_solicit[pa_curr].num_texto_2
          LET p_nf_solicit.num_texto_3       = t1_nf_solicit[pa_curr].num_texto_3
          LET p_nf_solicit.qtd_embal_1       = t1_nf_solicit[pa_curr].num_volume 
          LET p_nf_solicit.nom_usuario       = p_user
          SELECT val_frete
            INTO l_val_frete
            FROM frete_roma_885
           WHERE cod_empresa = p_cod_empresa
             AND num_om      = t1_nf_solicit[pa_curr].num_om
          IF SQLCA.sqlcode = 0 THEN
             LET  t1_frete_seguro[pa_curr].val_frete = l_val_frete
          END IF    
          IF t1_frete_seguro[pa_curr].val_frete > 0 THEN 
             LET p_nf_solicit.val_frete = t1_frete_seguro[pa_curr].val_frete
          ELSE 
             LET p_nf_solicit.val_frete = 0
          END IF
          IF t1_frete_seguro[pa_curr].val_seguro > 0 THEN 
             LET p_nf_solicit.val_seguro = t1_frete_seguro[pa_curr].val_seguro
          ELSE 
             LET p_nf_solicit.val_seguro = 0
          END IF
          IF t1_frete_seguro[pa_curr].pes_tot_bruto > 0 THEN 
             LET p_nf_solicit.pes_tot_bruto = t1_frete_seguro[pa_curr].pes_tot_bruto
          ELSE 
             LET p_nf_solicit.pes_tot_bruto = 0
          END IF
          IF t1_frete_seguro[pa_curr].pes_tot_liquido > 0 THEN 
             LET p_nf_solicit.pes_tot_liquido = t1_frete_seguro[pa_curr].pes_tot_liquido
          ELSE 
             LET p_nf_solicit.pes_tot_liquido = 0
          END IF
   
          SELECT num_lote_om
            INTO p_num_lote_om
            FROM ordem_montag_mest
            WHERE cod_empresa = p_nf_solicit.cod_empresa
              AND num_om      = p_nf_solicit.num_om
   
          SELECT * FROM nf_solicit WHERE cod_empresa = p_nf_solicit.cod_empresa
                                     AND num_om      = p_nf_solicit.num_om
          IF SQLCA.sqlcode = 0 THEN
          ELSE 
             IF p_num_lote_om > 0 THEN
                SELECT num_lote_om
                  FROM ordem_montag_lote
                 WHERE cod_empresa  = p_cod_empresa
                   AND num_lote_om  = p_num_lote_om
                   AND ies_sit_lote = "N"
                IF SQLCA.sqlcode = 0 THEN
                   INSERT INTO nf_solicit VALUES (p_nf_solicit.*)
                   IF sqlca.sqlcode = 0 OR sqlca.sqlcode = -268 THEN
                      IF p_nf_solicit.val_frete > 0 THEN     
                         LET l_count = 0
                         SELECT COUNT(*)
                           INTO l_count
                           FROM wfrete
                          WHERE num_controle =  p_nf_solicit.num_controle
                         IF l_count > 0 THEN 
                            UPDATE wfrete SET val_frete = val_frete + p_nf_solicit.val_frete
                         ELSE
                            INSERT INTO wfrete VALUES (p_nf_solicit.num_controle,p_nf_solicit.val_frete)
                         END IF  
                      END IF    
                   ELSE 
                      CALL log003_err_sql("INCLUSAO", "NF_SOLICIT")
                      RETURN FALSE
                   END IF
                ELSE
                   ERROR "Registro nao encontrado na tabela ORDEM_MONTAG_LOTE, Lote OM --> ",p_num_lote_om
                END IF
             ELSE 
                INSERT INTO nf_solicit VALUES (p_nf_solicit.*)
                IF sqlca.sqlcode = 0 OR sqlca.sqlcode = -268 THEN 
                   IF p_nf_solicit.val_frete > 0 THEN 
                      LET l_count = 0
                      SELECT COUNT(*)
                        INTO l_count
                        FROM wfrete
                       WHERE num_controle =  p_nf_solicit.num_controle
                      IF l_count > 0 THEN 
                         UPDATE wfrete SET val_frete = val_frete + p_nf_solicit.val_frete
                      ELSE
                         INSERT INTO wfrete VALUES (p_nf_solicit.num_controle,p_nf_solicit.val_frete)
                      END IF  
                   END IF    
                ELSE CALL log003_err_sql("INCLUSAO", "NF_SOLICIT")
                   RETURN FALSE
                END IF
             END IF
          END IF
       END IF
   END FOR
   
   DECLARE cq_atp1 CURSOR FOR 
     SELECT DISTINCT  a.num_om,a.num_controle,b.num_pedido
       FROM nf_solicit a, ordem_montag_item b
      WHERE a.num_solicit = p_nf_solicit.num_solicit
        AND a.cod_empresa = p_cod_empresa
        AND a.num_om      = b.num_om
        AND a.cod_empresa = b.cod_empresa
   FOREACH cq_atp1 INTO l_num_om,l_num_controle,l_num_pedido
     INSERT INTO sol_tmp VALUES (l_num_om, l_num_controle, l_num_pedido)
   END FOREACH 
   
   DECLARE cq_atp2 CURSOR FOR 
     SELECT num_controle,count(*)
       FROM nf_solicit
      WHERE cod_empresa = p_cod_empresa
        AND num_solicit = p_nf_solicit.num_solicit
      GROUP BY num_controle
      HAVING count(*) > 1
   FOREACH cq_atp2 INTO l_num_controle,l_qtd_ct 
      SELECT MIN(num_pedido) 
        INTO l_num_ped_min
        FROM sol_tmp
      DECLARE cq_atp3 CURSOR FOR   
         SELECT num_pedido 
           FROM sol_tmp
          WHERE num_pedido > l_num_ped_min   
      FOREACH cq_atp3 INTO l_num_pedido
          UPDATE ped_itens_texto SET den_texto_1=NULL,
                                     den_texto_2=NULL,
                                     den_texto_3=NULL,
                                     den_texto_4=NULL,
                                     den_texto_5=NULL 
           WHERE num_sequencia = 0 
             AND num_pedido    = l_num_pedido
             AND cod_empresa   = p_cod_empresa
       END FOREACH 
   END FOREACH    
ELSE
   RETURN FALSE   
END IF    
RETURN TRUE
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0802_modificacao_solicitacao()
#-----------------------------------------#

 LET p_nf_solicitr.* = p_nf_solicit.*
 IF pol0802_carrega_tabela() THEN 
    IF pol0802_dados_mestre("MODIFICACAO") THEN 
       IF pol0802_dados_solicitacao("MODIFICACAO") THEN 
          IF log004_confirm(7,43) THEN 
             IF pol0802_efetiva_inclusao() THEN 
                CALL pol0802_atualiza_frete()
                CALL log085_transacao("COMMIT")
                IF SQLCA.sqlcode = 0 THEN 
                   MESSAGE " Modificacao efetuada com sucesso " ATTRIBUTE(REVERSE)
                ELSE 
                   CALL log003_err_sql("MODIFICACAO","NF_SOLICIT")
                   CALL log085_transacao("ROLLBACK")
                END IF
             ELSE 
                CALL log085_transacao("ROLLBACK")
             END IF
          END IF
       ELSE 
          LET p_nf_solicit.* = p_nf_solicitr.*
          CALL pol0802_exibe_dados_solicitacao()
          ERROR " Modificacao Cancelada "
          RETURN
       END IF
    ELSE 
       LET p_nf_solicit.* = p_nf_solicitr.*
       CALL pol0802_exibe_dados_solicitacao()
       ERROR " Modificacao Cancelada "
       RETURN
    END IF
 ELSE 
    ERROR " Nao existem dados para a chave informada "
 END IF
 END FUNCTION

#-----------------------------------------#
 FUNCTION pol0802_carrega_tabela()
#-----------------------------------------#

 FOR p_count = 1 TO 200
   INITIALIZE t1_nf_solicit[p_count].* TO NULL
 END FOR

 DELETE FROM wsolicit
 DELETE FROM wfrete 

 DECLARE cq_nf_solicit  CURSOR FOR
 SELECT * FROM nf_solicit
  WHERE nf_solicit.cod_empresa = p_cod_empresa
    AND nf_solicit.num_solicit = p_nf_solicit.num_solicit
    AND nf_solicit.nom_usuario = p_user
    ORDER BY nf_solicit.num_controle, nf_solicit.num_sequencia

 LET p_count = 0

 FOREACH cq_nf_solicit INTO p_nf_solicit.*
    LET p_count = p_count + 1
    LET p_num_solicit         =  p_nf_solicit.num_solicit
    LET p_wsolicit.num_om     =  p_nf_solicit.num_om 

    SELECT MAX(num_pedido)
      INTO p_wsolicit.num_pedido
      FROM ordem_montag_item
     WHERE cod_empresa = p_cod_empresa
       AND num_om      = p_nf_solicit.num_om  
       
    SELECT cod_cliente
      INTO p_wsolicit.cod_cliente
      FROM pedidos
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_wsolicit.num_pedido

    LET p_wsolicit.num_controle       =  p_nf_solicit.num_controle
    LET p_wsolicit.cod_cnd_pgto       =  p_nf_solicit.cod_cnd_pgto
    LET p_wsolicit.qtd_dias_acr_dupl  =  p_nf_solicit.qtd_dias_acr_dupl
    LET p_wsolicit.num_texto_1        =  p_nf_solicit.num_texto_1
    LET p_wsolicit.num_texto_2        =  p_nf_solicit.num_texto_2
    LET p_wsolicit.num_texto_3        =  p_nf_solicit.num_texto_3
    LET p_wsolicit.num_volume         =  p_nf_solicit.qtd_embal_1
    LET p_wsolicit.val_frete          =  p_nf_solicit.val_frete
    LET p_wsolicit.val_seguro         =  p_nf_solicit.val_seguro
    LET p_wsolicit.pes_tot_bruto      =  p_nf_solicit.pes_tot_bruto
    LET p_wsolicit.pes_tot_liquido    = p_nf_solicit.pes_tot_liquido
    IF p_nf_solicit.val_frete  > 0 OR
       p_nf_solicit.val_seguro > 0 OR 
       p_nf_solicit.pes_tot_bruto > 0 OR 
       p_nf_solicit.pes_tot_liquido > 0 THEN
       LET p_wsolicit.ies_frete_seguro = "S"
    END IF
    INSERT INTO wsolicit VALUES (p_wsolicit.*)
    
 END FOREACH  
 
 LET p_count = 0
 
 DECLARE cq_sol CURSOR FOR
  SELECT *
    FROM wsolicit
   ORDER BY cod_cliente, num_pedido 
 FOREACH cq_sol INTO p_wsolicit.*
    LET p_count = p_count + 1
    LET t1_nf_solicit[p_count].num_om            =  p_wsolicit.num_om 
    LET t1_nf_solicit[p_count].num_controle      =  p_wsolicit.num_controle
    LET t1_nf_solicit[p_count].cod_cnd_pgto      =  p_wsolicit.cod_cnd_pgto
    LET t1_nf_solicit[p_count].qtd_dias_acr_dupl =  p_wsolicit.qtd_dias_acr_dupl
    LET t1_nf_solicit[p_count].num_texto_1       =  p_wsolicit.num_texto_1
    LET t1_nf_solicit[p_count].num_texto_2       =  p_wsolicit.num_texto_2
    LET t1_nf_solicit[p_count].num_texto_3       =  p_wsolicit.num_texto_3
    LET t1_nf_solicit[p_count].num_volume        =  p_wsolicit.num_volume
    LET t1_nf_solicit[p_count].cod_cliente       =  p_wsolicit.cod_cliente    
    LET t1_nf_solicit[p_count].num_pedido        =  p_wsolicit.num_pedido
    LET t1_frete_seguro[p_count].val_frete       =  p_wsolicit.val_frete
    LET t1_frete_seguro[p_count].val_seguro      =  p_wsolicit.val_seguro
    LET t1_frete_seguro[p_count].pes_tot_bruto   =  p_wsolicit.pes_tot_bruto
    LET t1_frete_seguro[p_count].pes_tot_liquido =  p_wsolicit.pes_tot_liquido
    LET t1_nf_solicit[p_count].ies_frete_seguro  =  p_wsolicit.ies_frete_seguro
    
 END FOREACH

 IF p_count = 0 THEN
    RETURN FALSE
 ELSE
    CALL set_count(p_count)
    RETURN TRUE
 END IF
 END FUNCTION

#--------------------------------------#
 FUNCTION pol0802_exclusao_solicitacao()
#--------------------------------------#
  LET p_nf_solicitr.* = p_nf_solicit.*

  SELECT UNIQUE num_solicit
    FROM nf_solicit
   WHERE nf_solicit.cod_empresa = p_cod_empresa
     AND nf_solicit.num_solicit = p_nf_solicit.num_solicit
     AND nf_solicit.nom_usuario = p_user

  IF   sqlca.sqlcode = 0
  THEN IF   log004_confirm(7,43)
       THEN BEGIN WORK
            DELETE FROM nf_solicit
             WHERE nf_solicit.cod_empresa = p_cod_empresa
               AND nf_solicit.num_solicit = p_nf_solicit.num_solicit
               AND nf_solicit.nom_usuario = p_user
            IF   sqlca.sqlcode = 0
            THEN CALL log085_transacao("COMMIT")
                 IF   sqlca.sqlcode = 0
                 THEN MESSAGE " Exclusao efetuada com sucesso " ATTRIBUTE(REVERSE)
                 ELSE CALL log003_err_sql("EXCLUSAO","NF_SOLICIT")
                      CALL log085_transacao("ROLLBACK")
                 END IF
            ELSE CALL log003_err_sql("EXCLUSAO","NF_SOLICIT")
                 CALL log085_transacao("ROLLBACK")
            END IF
       ELSE LET p_nf_solicit.* = p_nf_solicitr.*
            CALL pol0802_exibe_dados_solicitacao()
            ERROR " Exclusao Cancelada "
            RETURN
       END IF
  ELSE ERROR " Nao existem dados para a chave informada "
  END IF
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0802_query_solicitacao()
#-----------------------------------------#
 DEFINE where_clause, sql_stmt  CHAR(250)
 LET p_nf_solicitr.* = p_nf_solicit.*
 INITIALIZE p_nf_solicit.* TO NULL
 CLEAR FORM
 DISPLAY p_cod_empresa TO nf_solicit.cod_empresa
 CONSTRUCT BY NAME  where_clause ON num_solicit, dat_refer, cod_transpor,
                                    num_placa, cod_entrega 
 IF int_flag <> 0
 THEN LET int_flag = 0
      ERROR " Consulta Cancelada "
      LET p_nf_solicit.* = p_nf_solicitr.*
      CALL pol0802_exibe_dados_solicitacao()
      RETURN
 END IF
 LET sql_stmt = "SELECT UNIQUE num_solicit ",
                "FROM nf_solicit WHERE nf_solicit.cod_empresa = """,
                p_cod_empresa ,""" AND ",
                " nf_solicit.nom_usuario = """, p_user , """ AND ",
                  where_clause CLIPPED
 PREPARE var_query FROM sql_stmt
 DECLARE cq_solicitacao2 SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_solicitacao2
 FETCH cq_solicitacao2 INTO p_nf_solicit.num_solicit
 IF sqlca.sqlcode = NOTFOUND THEN
    CALL log0030_mensagem("Argumentos de pesquisa nao encontrados. ",
            "exclamation")
      LET p_ies_cons = FALSE
      CLEAR FORM
 ELSE LET p_ies_cons = TRUE
      SELECT UNIQUE dat_refer, cod_via_transporte, cod_transpor, num_placa, cod_entrega
             INTO p_nf_solicit.dat_refer, p_nf_solicit.cod_via_transporte,
                  p_nf_solicit.cod_transpor, p_nf_solicit.num_placa,
                  p_nf_solicit.cod_entrega 
        FROM nf_solicit
       WHERE nf_solicit.cod_empresa   = p_cod_empresa
         AND nf_solicit.num_solicit   = p_nf_solicit.num_solicit
         AND nf_solicit.nom_usuario   = p_user
      IF sqlca.sqlcode  = 0 THEN
         CALL pol0802_exibe_dados_solicitacao()
      END IF
 END IF
 END FUNCTION

#-----------------------------------------#
 FUNCTION pol0802_exibe_dados_solicitacao()
#-----------------------------------------#
 CLEAR FORM
 DISPLAY p_nf_solicit.num_solicit      TO num_solicit
 DISPLAY p_nf_solicit.dat_refer        TO dat_refer
 DISPLAY p_nf_solicit.cod_via_transporte TO cod_via_transporte
 
 IF pol0802_verifica_via_transporte() THEN
 END IF  
 
 SELECT DISTINCT parametro_texto[1,2] 
   INTO p_uf_placa
   FROM fat_solic_ser_comp
  WHERE empresa = p_cod_empresa 
    AND solicitacao_fatura = p_nf_solicit.num_solicit
  
 DISPLAY p_nf_solicit.cod_transpor     TO cod_transpor
 DISPLAY p_uf_placa                    TO uf_placa
 DISPLAY p_nf_solicit.num_placa        TO num_placa
 DISPLAY p_nf_solicit.cod_tip_carteira TO cod_tip_carteira
 DISPLAY p_nf_solicit.cod_entrega      TO cod_entrega
 CALL pol0802_verifica_cod_transpor() RETURNING p_status
 CALL pol0802_carrega_tabela() RETURNING p_status
 IF p_status = FALSE
 THEN RETURN
 END IF
 DISPLAY ARRAY t1_nf_solicit TO s_nf_solicit.*
 LET int_flag = 0
 END FUNCTION

#-----------------------------------------#
 FUNCTION pol0802_paginacao(p_funcao)
#-----------------------------------------#
 DEFINE p_funcao      CHAR(20)
 IF p_ies_cons
 THEN WHILE TRUE
      LET p_nf_solicitr.* = p_nf_solicit.*
      CASE
        WHEN p_funcao = "SEGUINTE"
             FETCH NEXT     cq_solicitacao2 INTO p_nf_solicit.num_solicit
        WHEN p_funcao = "ANTERIOR"
             FETCH PREVIOUS cq_solicitacao2 INTO p_nf_solicit.num_solicit
      END CASE
      IF sqlca.sqlcode = NOTFOUND
      THEN ERROR " Nao existem mais itens nesta direcao "
           LET p_nf_solicit.* = p_nf_solicitr.*
           EXIT WHILE
      END IF

      SELECT UNIQUE dat_refer, cod_transpor, num_placa,cod_entrega 
             INTO p_nf_solicit.dat_refer, p_nf_solicit.cod_transpor, 
                  p_nf_solicit.num_placa, p_nf_solicit.cod_entrega 
                   
        FROM nf_solicit
       WHERE nf_solicit.cod_empresa   = p_cod_empresa
         AND nf_solicit.num_solicit   = p_nf_solicit.num_solicit
         AND nf_solicit.nom_usuario   = p_user
      IF sqlca.sqlcode  = 0
      THEN CALL pol0802_exibe_dados_solicitacao()
           EXIT WHILE
      END IF
      END WHILE
 ELSE ERROR " Nao existe nenhuma consulta ativa "
 END IF
 END FUNCTION

#------------------------------------#
 FUNCTION pol0802_den_empresa()
#------------------------------------#
 SELECT den_empresa INTO p_den_empresa
   FROM empresa
  WHERE cod_empresa = p_cod_empresa

 END FUNCTION

#--------------------------------#
 FUNCTION pol0802_exibe_item(p_om)
#--------------------------------#

   DEFINE p_om LIKE ordem_montag_item.num_om,
          p_i  SMALLINT   

   CALL log006_exibe_teclas("01", p_versao)
   INITIALIZE t_om_item TO NULL

   CALL log130_procura_caminho("pol080203") RETURNING p_nom_tela
   OPEN WINDOW w_pol080203 AT 3,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa 

   DECLARE cq_om_item CURSOR FOR
   SELECT cod_item,
          qtd_reservada,
          pes_total_item
   FROM ordem_montag_item   
   WHERE cod_empresa = p_cod_empresa
     AND num_om = p_om                        

   LET p_i = 1
   FOREACH cq_om_item INTO t_om_item[p_i].cod_item,
                           t_om_item[p_i].qtd_reservada,
                           t_om_item[p_i].pes_total_item

      SELECT den_item_reduz
         INTO t_om_item[p_i].den_item_reduz
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = t_om_item[p_i].cod_item

      LET p_i = p_i + 1

   END FOREACH 

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   IF p_i > 0 THEN
      DISPLAY ARRAY t_om_item TO s_om_item.* 
      END DISPLAY 
   END IF

   CLOSE WINDOW w_pol080203
   CURRENT WINDOW IS w_pol08020

END FUNCTION

#---------------------------------#
 FUNCTION pol0802_atualiza_frete()
#---------------------------------#
  DEFINE l_num_controle   LIKE nf_solicit.num_controle,
         l_val_frete      LIKE nf_solicit.val_frete
         
  DECLARE cq_fret CURSOR FOR 
    SELECT num_controle,val_frete
      FROM wfrete 
  FOREACH cq_fret INTO l_num_controle,l_val_frete 
  
    UPDATE nf_solicit SET val_frete = l_val_frete  
     WHERE num_controle = l_num_controle
  
  END FOREACH 
 
END FUNCTION

#------------------------------------#
 FUNCTION pol0802_lista_solicitacao()
#------------------------------------#
  DEFINE l_solicitacao       RECORD LIKE nf_solicit.*

  INITIALIZE p_msg TO NULL

  IF   log028_saida_relat(21,40) IS NOT NULL
  THEN ERROR " Processando a extracao do relatorio ... "
     IF g_ies_ambiente = "W"
     THEN IF p_ies_impressao = "S"
          THEN CALL log150_procura_caminho("LST") RETURNING p_caminho
               LET p_caminho = p_caminho CLIPPED, "pol08020.tmp"
               START REPORT pol0802_relat TO p_caminho
          ELSE START REPORT pol0802_relat TO p_nom_arquivo
          END IF
     ELSE
          IF p_ies_impressao = "S"
          THEN START REPORT pol0802_relat TO PIPE p_nom_arquivo
          ELSE START REPORT pol0802_relat TO p_nom_arquivo
          END IF
     END IF

     DECLARE cl_solicitacao  CURSOR FOR
       SELECT * INTO l_solicitacao.* FROM nf_solicit
         WHERE nf_solicit.cod_empresa = p_cod_empresa
           AND nf_solicit.nom_usuario  = p_user
         ORDER BY num_solicit, num_sequencia
     FOREACH cl_solicitacao
       OUTPUT TO REPORT pol0802_relat(l_solicitacao.*)
     END FOREACH
     FINISH REPORT pol0802_relat
         IF  g_ies_ambiente = "W" AND
             p_ies_impressao = "S"  THEN
             LET p_comando = "lpdos.bat ",
                 p_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
             RUN p_comando
         END IF
         IF  p_ies_impressao = "S" THEN
             CALL log0030_mensagem("Relatorio impresso com sucesso. ","info")
         ELSE
             LET p_msg = "Relatorio gravado no arquivo ",
             p_nom_arquivo CLIPPED,"."
             CALL log0030_mensagem(p_msg,"info")
         END IF
         ERROR "Fim de processamento. "
  END IF
END FUNCTION

#-------------------------------#
 REPORT pol0802_relat(p_nf_solicit)
#-------------------------------#
  DEFINE p_nf_solicit     RECORD LIKE nf_solicit.*
  OUTPUT LEFT MARGIN 0
         TOP MARGIN 0
         BOTTOM MARGIN 1
         PAGE LENGTH 66
  FORMAT
    PAGE HEADER
#     PRINT log500_determina_cpp(132) CLIPPED;
      PRINT COLUMN   1, p_den_empresa
      PRINT COLUMN   1, "pol0802",
            COLUMN  13, "LISTAGEM DAS SOLICITACOES DE FATURAMENTO ",
            COLUMN 125, "FL. ", PAGENO USING "####"
      PRINT COLUMN 001, "USUARIO : ",p_user,
            COLUMN  94, "EXTRAIDO EM ", TODAY USING "dd/mm/yyyy",
            COLUMN 117, "AS ", TIME,
            COLUMN 129, "HRS."
      SKIP 1 LINE

      PRINT COLUMN  1, "SOLICIT DAT.REFER. TRANS  PLACA  CART. ENT.   O.M. CON CND ",
            COLUMN 49, " TEXTOS  NR.VOL.  EMB QTD  EMB QTD  EMB QTD  EMB ",
            COLUMN 98, "QTD  EMB QTD  SEQUENCIA"

      PRINT COLUMN  1, "------- ---------- ----- ------- ----- ---- ------ --- --- ",
            COLUMN 59, "-------- -------  --- ---  --- ---  --- ---  --- ",
            COLUMN 108, "---  --- ---  ---------"

{
EMPRESA MODELO S/A
pol0802     LISTAGEM DAS SOLICITACOES DE FATURAMENTO                                                                        FL. XXXX
USUARIO : XXXXXXXX                                                                            EXTRAIDO EM XX/XX/XXXX AS XX.XX.XX HRS.

SOLICIT DAT.REFER. TRANS  PLACA  CART. ENT.   O.M. CON CND  TEXTOS   VOLUME  EMB QTD  EMB QTD  EMB QTD  EMB QTD  EMB QTD  SEQUENCIA
------- ---------- ----- ------- ----- ---- ------ --- --- -------- -------  --- ---  --- ---  --- ---  --- ---  --- ---  ---------
  ZZZZ  ZZ/ZZ/ZZZZ  ZZZZ XXXXXXX    XX ZZZZ ZZZZZZ ZZZ ZZZ ZZ ZZ ZZ ZZZZZZZ  ZZZ ZZZ  ZZZ ZZZ  ZZZ ZZZ  ZZZ ZZZ  ZZZ ZZZ  ZZZZZZZZZ
}

    ON EVERY ROW
      PRINT COLUMN  2, p_nf_solicit.num_solicit USING "####",
            COLUMN  9, p_nf_solicit.dat_refer USING "dd/mm/yyyy",
            COLUMN 21, p_nf_solicit.cod_transpor USING "####",
            COLUMN 26, p_nf_solicit.num_placa,
            COLUMN 36, p_nf_solicit.cod_tip_carteira,
            COLUMN 39, p_nf_solicit.cod_entrega USING "####",
            COLUMN 44, p_nf_solicit.num_om USING "######",
            COLUMN 51, p_nf_solicit.num_controle USING "###",
            COLUMN 59, p_nf_solicit.num_texto_1 USING "##",
            COLUMN 62, p_nf_solicit.num_texto_2 USING "##",
            COLUMN 65, p_nf_solicit.num_texto_3 USING "##",
            COLUMN 68, p_nf_solicit.num_volume USING "#######",
            COLUMN 77, p_nf_solicit.cod_embal_1 USING "###",
            COLUMN 81, p_nf_solicit.qtd_embal_1 USING "###",
            COLUMN 86, p_nf_solicit.cod_embal_2 USING "###",
            COLUMN 90, p_nf_solicit.qtd_embal_2 USING "###",
            COLUMN 95, p_nf_solicit.cod_embal_3 USING "###",
            COLUMN 99, p_nf_solicit.qtd_embal_3 USING "###",
            COLUMN 104, p_nf_solicit.cod_embal_4 USING "###",
            COLUMN 108, p_nf_solicit.qtd_embal_4 USING "###",
            COLUMN 113, p_nf_solicit.cod_embal_5 USING "###",
            COLUMN 117, p_nf_solicit.qtd_embal_5 USING "###",
            COLUMN 122, p_nf_solicit.num_sequencia
    ON LAST ROW
      LET p_last_row = true
    PAGE TRAILER
      IF p_last_row = true
         THEN PRINT "* * * ULTIMA FOLHA * * *"
         ELSE PRINT " "
      END IF
END REPORT

#-----------------------#
 FUNCTION pol0802_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION