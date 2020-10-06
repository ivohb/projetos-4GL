#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: BAIXA MANUAL DE DOCUMENTOS (ON-LINE)                  #
# PROGRAMA: geo1017  (COPIA ADAPTADA/AUTOMATIZADA DE cre03600)    #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 13/03/2016                                            #
#-----------------------------------------------------------------#

DATABASE logix

  GLOBALS

   DEFINE p_cod_empresa                LIKE empresa.cod_empresa,
          p_den_empresa                LIKE empresa.den_empresa,
          p_user                       LIKE usuario.nom_usuario,
          p_versao                     CHAR(18), #Favor Nao Alterar esta linha (SUPORTE)
          p_status                     SMALLINT,
          g_ies_grafico                SMALLINT,
          p_ies_impressao              CHAR(01),
          p_val_a_pagar                DECIMAL(15,2),
          p_ja_sub_desp                SMALLINT,
          p_val_juro_a_pag             DECIMAL(15,2),
          p_msg			                     CHAR(100),
          p_docum               RECORD LIKE docum.*,
          p_caminho                    CHAR(80),
          p_pct_desc                   LIKE adocum.pct_desc,
          p_ies_despesas               CHAR(01),
          p_par_banc_desp              CHAR(01),
          p_forma_desp                 CHAR(02),
          p_num_lote_conc              DECIMAL(5,0),
          p_num_lote_concx             CHAR(05),
          p_par_banc_nc                CHAR(01),
          p_val_multa_a_pag            DECIMAL(15,2),
          p_qtd_lotes                  DECIMAL(1,0),
          p_nom_arquivo                CHAR(100),
          p_val_pago                   LIKE docum.val_bruto,
          p_ies_cotacao                CHAR(03),
          p_val_nc                     LIKE pgto_det.val_titulo,
          p_num_docum                  LIKE pgto_det.num_docum,
          p_ies_tip_docum              LIKE pgto_det.ies_tip_docum,
          pr_docum_pgto_trb     RECORD LIKE docum_pgto.*,
          p_docum_estorno       RECORD LIKE docum_estorno.*,
          p_docum_estorno_trb   RECORD LIKE docum_estorno_trb.*,
          pr_conc_pgto_trb      RECORD LIKE conc_pgto.*,
          pr_creconc            RECORD LIKE creconc.*,
          p_docum_pgto_txt      RECORD LIKE docum_pgto_txt.*,
          p_adocum_pgto         RECORD LIKE adocum_pgto.*,
          p_docum_pgto          RECORD LIKE docum_pgto.*,
          p_par_cre             RECORD LIKE par_cre.*,
          g_ies_ambiente               CHAR(01),
          p_par_tip_docum              LIKE pgto_det.ies_tip_docum,
          p_val_titulo                 LIKE pgto_det.val_titulo,
          p_cod_portador               LIKE adocum_pgto_capa.cod_portador,
          p_cod_port_corresp           LIKE port_corresp.cod_port_corresp,
          p_val_tarifa                 LIKE docum.val_bruto,
          p_val_despesas               LIKE pgto_det.val_titulo,
          p_nom_programa               CHAR(08),
          p_num_lote_trb               DECIMAL(5,0),
          p_ind                        INTEGER,
          p_ies_docpgtxt               SMALLINT,
          g_cod_prg_chamador           CHAR(08),
          g_num_lote_pgto              DECIMAL(8,0)

   DEFINE p_lotes               ARRAY[5] OF RECORD
          num_lote_compl          LIKE conc_pgto.num_lote_compl_1
                                END RECORD

   DEFINE gr_cre_tit_cob_esp    RECORD LIKE cre_tit_cob_esp.*

   DEFINE p_wcre1581            RECORD
          num_lote                     LIKE adocum_pgto.num_lote,
          cod_portador                 LIKE adocum_pgto_capa.cod_portador,
          ies_tip_portador             LIKE adocum_pgto_capa.ies_tip_portador,
          cod_empresa                  LIKE adocum_pgto.cod_empresa,
          num_docum                    LIKE adocum_pgto.num_docum,
          ies_tip_docum                LIKE adocum_pgto.ies_tip_docum,
          ies_tip_pgto                 LIKE adocum_pgto.ies_tip_pgto,
          dat_pgto                     LIKE adocum_pgto.dat_pgto,
          dat_credito                  LIKE adocum_pgto.dat_credito,
          dat_lanc                     LIKE adocum_pgto.dat_lanc,
          val_titulo                   LIKE adocum_pgto.val_titulo,
          val_juro                     LIKE adocum_pgto.val_juro,
          val_desc                     LIKE adocum_pgto.val_desc,
          val_abat                     LIKE adocum_pgto.val_abat,
          des_mensagem                 CHAR(70)
   END RECORD

   DEFINE p_conc_pgt            ARRAY[100] OF RECORD
          cod_empresa                  LIKE conc_pgto.cod_empresa,
          num_seq_conc                 LIKE conc_pgto.num_seq_conc,
          dat_cred                     LIKE conc_pgto.dat_cred,
          val_concil                   LIKE conc_pgto.val_concil,
          deb_cred                     LIKE conc_pgto.deb_cred,
          val_estorno                  LIKE conc_pgto.val_concil
                                END RECORD

   DEFINE p_conc_pgt1           ARRAY[100] OF RECORD
          val_despesas                 LIKE conc_pgto.val_concil
                                END RECORD

   DEFINE p_par_cre_txt         RECORD LIKE par_cre_txt.*   # os439463

   DEFINE g_total_val_var_cambial_maior  LIKE cre_pagto_det_cpl.parametro_val,
          g_total_val_var_cambial_menor  LIKE cre_pagto_det_cpl.parametro_val

 END GLOBALS
  # MODULARES #

   DEFINE m_consulta_ativa             SMALLINT     ,
          m_comando                    CHAR(080)    ,
          where_clause                 CHAR(2000)   ,
          sql_stmt                     CHAR(2000)   ,
          m_num_lot                    DECIMAL(8,0) ,
          m_som_val_titulo             DECIMAL(15,2),
          m_port_cre                   DECIMAL(4,0) ,
          m_caminho                    CHAR(150)    ,
          m_parametro                  CHAR(500)    ,
          m_qtd_dias_difer             DECIMAL(5,0) ,
          m_informou_dados             SMALLINT     ,
          m_pct_desc                   LIKE adocum.pct_desc,
          m_dat_vencto                 DATE        ,
          m_dat_aux                    DATE        ,
          m_dat_lancamento             DATE        ,
          m_forma_desp                 CHAR(02)    ,
          m_mensagem                   CHAR(80)    ,
          m_ies_conc_bco_cxa           CHAR(01)    ,
          m_som_dat_pgto               DECIMAL(8,0),
          m_som_dat_lanc               DECIMAL(8,0),
          m_som_dat_cred               DECIMAL(8,0),
          m_ies_ctr_cotacao            LIKE empresa_cre.ies_ctr_cotacao,
          m_cod_moeda_1                LIKE empresa_cre.cod_moeda_1  ,
          m_val_saldo_urv              LIKE docum.val_saldo ,
          m_val_saldo                  LIKE docum_cotacao.val_saldo ,
          m_area_livre                 LIKE par_con.area_livre,
          m_area                       LIKE empresa.cod_empresa,
          m_ult_num_per_fech           LIKE par_con.ult_num_per_fech,
          m_num_lote_trb               DECIMAL(5,0)                 ,
          m_ult_num_seg_fech           LIKE par_con.ult_num_seg_fech,
          m_ies_tip_cobr_juro          LIKE par_cre.ies_tip_cobr_juro,
          m_situa_docum                CHAR(01)             ,
          m_val_variacao               LIKE docum.val_saldo ,
          m_ies_ctr_dat_prorr          LIKE empresa_cre.ies_ctr_dat_prorr,
          m_cre_cncl_pagto_det  RECORD LIKE cre_cncl_pagto_det.*  ,
          m_des_cnd_pgto               LIKE cond_pgto_cre.des_cnd_pgto,
          m_status                     SMALLINT,
          m_mesg_fcx                   CHAR(80),
          m_i                          INTEGER,
          m_dat_vencto_s_desc          DATE,
          m_som_val_juros              DECIMAL(15,2),
          m_som_val_desc               DECIMAL(15,2),
          m_som_val_abat               DECIMAL(15,2),
          m_som_qtd_docum              DECIMAL(15,2),
          m_cancela                    SMALLINT

   DEFINE m_diferenca                  LIKE conc_pgto.val_concil,
          m_diferenca_nc               LIKE pgto_det.val_titulo,
          m_ies_forma_pgto             LIKE pgto_capa.ies_forma_pgto,
          m_dat_emissao                DATE,
          m_val_pago_moeda             LIKE pgto_det.val_titulo,
          m_val_desp1_moeda            LIKE pgto_det.val_titulo,
          m_val_nc_desc                LIKE pgto_det.val_titulo,
          m_val_nc_desc_lote           LIKE pgto_det.val_titulo,
          m_val_tarifa_acum            LIKE docum.val_bruto,
          m_val_desp_acum              LIKE docum.val_bruto

   DEFINE m_val_cotacao                DECIMAL(18,9),
          m_ies_ctr_moeda              CHAR(01),
          m_cod_moeda                  CHAR(02),
          mr_par_con            RECORD LIKE par_con.*,
          m_msg                        CHAR(80),
          m_lote_atual                 DECIMAL(8,0)


   DEFINE m_dat_char08                 CHAR(08),
          m_dat_char10                 CHAR(10),
          m_dat_dec08                  DECIMAL(8,0)

   DEFINE mr_docum_txt          RECORD LIKE docum_txt.*

   DEFINE ma_glosa              ARRAY[100] OF RECORD
          val_glosa                    DECIMAL(15,2)
                                END RECORD

   DEFINE mr_tela               RECORD
          cod_empresa                  LIKE adocum_pgto.cod_empresa     ,
          num_docum                    LIKE docum.num_docum             ,
          ies_tip_docum                LIKE docum.ies_tip_docum         ,
          ies_tip_pgto                 LIKE docum_pgto.ies_tip_pgto     ,
          ies_forma_pgto               LIKE docum_pgto.ies_forma_pgto   ,
          cod_portador                 LIKE docum.cod_portador          ,
          ies_tip_portador             LIKE docum.ies_tip_portador      ,
          dat_pgto                     LIKE docum_pgto.dat_pgto         ,
          dat_credito                  LIKE docum_pgto.dat_credito      ,
          val_saldo                    LIKE docum.val_saldo             ,
          val_desc_conc                LIKE docum_pgto.val_desc_conc    ,
          val_juro_pago                LIKE docum_pgto.val_juro_pago    ,
          ies_abono_juros              CHAR(01)                         ,
          val_desp_cartorio            LIKE docum_pgto.val_desp_cartorio,
          val_despesas                 LIKE docum_pgto.val_despesas     ,
          val_multa                    DECIMAL(15,2)                    ,
          val_glosa                    DECIMAL(15,2)
                                END RECORD


   DEFINE mr_telar              RECORD
          cod_empresa                  LIKE empresa.cod_empresa         ,
          num_docum                    LIKE docum.num_docum             ,
          ies_tip_docum                LIKE docum.ies_tip_docum         ,
          ies_tip_pgto                 LIKE docum_pgto.ies_tip_pgto     ,
          ies_forma_pgto               LIKE docum_pgto.ies_forma_pgto   ,
          cod_portador                 LIKE docum.cod_portador          ,
          ies_tip_portador             LIKE docum.ies_tip_portador      ,
          dat_pgto                     LIKE docum_pgto.dat_pgto         ,
          dat_credito                  LIKE docum_pgto.dat_credito      ,
          val_saldo                    LIKE docum.val_saldo             ,
          val_desc_conc                LIKE docum_pgto.val_desc_conc    ,
          val_juro_pago                LIKE docum_pgto.val_juro_pago    ,
          ies_abono_juros              CHAR(01)                         ,
          val_desp_cartorio            LIKE docum_pgto.val_desp_cartorio,
          val_despesas                 LIKE docum_pgto.val_despesas     ,
          val_multa                    DECIMAL(15,2)                    ,
          val_glosa                    DECIMAL(15,2)
                                END RECORD

   DEFINE mr_docum_aberto       RECORD
          cod_empresa                  LIKE docum.cod_empresa,
          num_docum                    LIKE docum.num_docum,
          ies_tip_docum                LIKE docum.ies_tip_docum,
          dat_emis                     LIKE docum.dat_emis,
          dat_vencto_s_desc            LIKE docum.dat_vencto_s_desc,
          cod_cliente                  LIKE docum.cod_cliente,
          cod_portador                 LIKE docum.cod_portador,
          ies_tip_portador             LIKE docum.ies_tip_portador,
          num_cgc_cpf                  LIKE clientes.num_cgc_cpf,
          cod_tip_cli                  LIKE clientes.cod_tip_cli,
          den_tip_cli                  CHAR(15)
                                END RECORD

   DEFINE mr_docum              RECORD LIKE docum.*

   DEFINE mr_dados_pagto        RECORD
          portador1                    LIKE docum_pgto.cod_portador,
          tip_portador1                LIKE docum_pgto.ies_tip_portador,
          dat_lanc                     DATE,
          forma_pgto                   LIKE docum_pgto.ies_forma_pgto
                                END RECORD

   DEFINE mr_adocum_pgto        RECORD LIKE adocum_pgto.*

   DEFINE ma_dados_cred_valor   ARRAY[100] OF RECORD
          dat_credito                  LIKE docum_pgto.dat_credito,
          val_a_pagar                  LIKE docum_pgto.val_a_pagar
                                END RECORD

   DEFINE ma_principal          ARRAY[4000] OF RECORD
          empresa                      LIKE docum.cod_empresa,
          docum                        LIKE docum.num_docum,
          tip_docum                    LIKE docum.ies_tip_docum,
          dat_pgto                     DATE,
          val_saldo                    LIKE docum.val_saldo,
          val_desc                     DECIMAL(15,2),
          val_juros                    DECIMAL(15,2),
          marcado                      CHAR(01)
                                END RECORD

   DEFINE ma_principal_aux      ARRAY[4000] OF RECORD
            ies_desabilita_contrato SMALLINT
          END RECORD

   DEFINE ma_principal_obs      ARRAY[4000] OF RECORD
            observacao CHAR(78)
          END RECORD

   DEFINE ma_outros             ARRAY[100] OF RECORD
          dat_cred                     DATE,
          tot_pagto                    DECIMAL(15,2)
                                END RECORD

   DEFINE ma_outros_conc_pgto   ARRAY[200] OF RECORD
          empresa                  LIKE  conc_pgto.cod_empresa,
          lote                     LIKE  conc_pgto.num_lote,
          portador                 LIKE  conc_pgto.cod_portador,
          tip_portador             LIKE  conc_pgto.ies_tip_portador,
          sequencia                LIKE  conc_pgto.num_seq_conc
                                END RECORD

   DEFINE mr_empresa_cre        RECORD LIKE empresa_cre.*,
          mr_docum_cotacao      RECORD LIKE docum_cotacao.*,
          mr_emp_cre_txt        RECORD LIKE empresa_cre_txt.*,
          m_conc_pgto           RECORD LIKE conc_pgto.*

   DEFINE m_existe_dado                SMALLINT,
          m_ind                        SMALLINT,
          m_ind_outros                 SMALLINT,
          m_count_principal            SMALLINT,
          m_count_outros               SMALLINT,
          msc_curr                     SMALLINT,
          m_dat_pgto                   DATE,
          m_valor_pagar                DECIMAL(15,2),
          m_juros_pagar                DECIMAL(15,2),
          m_desc_conceder              DECIMAL(15,2),
          m_total_saldo                DECIMAL(15,2),
          m_total_juro                 DECIMAL(15,2),
          m_total_desc                 DECIMAL(15,2),
          m_val_difer                  DECIMAL(15,2),
          m_total_a_pagar              DECIMAL(15,2),
          m_tem_dados                  SMALLINT,
          m_qtd_concil                 SMALLINT,
          m_val_concil                 DECIMAL(13,3),
          m_valor                      LIKE docum_pgto.val_pago,
          m_integrou_trb               SMALLINT,
          m_cod_portador               LIKE portador.cod_portador,
          m_esta_na_consulta           SMALLINT,
          m_cre_fma_pg_glosa           CHAR(02),
          m_cre_port_bxa_glosa         DECIMAL(4,0),
          m_cre_tip_port_glosa         CHAR(01),
          m_total                      DECIMAL(15,2),
          m_ies_processou              SMALLINT

   DEFINE m_cre_most_tela_doc          CHAR(01)  # log2240 - 'cre_most_tela_doc'
   DEFINE m_dat_cre_capa_cncl          CHAR(01)  # log2240 - 'dat_cre_capa_cncl'

   DEFINE mr_contas_aux          RECORD LIKE contas_aux.*
   DEFINE m_cod_tip_cli          LIKE clientes.cod_tip_cli
   DEFINE m_num_cgc_cpf          LIKE clientes.num_cgc_cpf
   DEFINE m_abre_tela_especifica SMALLINT

   DEFINE m_empresa_trb         LIKE conc_pgto.cod_empresa
   DEFINE m_num_seq_conc_trb    LIKE conc_pgto.num_seq_conc

   DEFINE m_dados_array         SMALLINT ### OS 590916

  #Parâmetros de portador
  DEFINE mr_params_portador RECORD
           ies_detalhar_vendor_trb     SMALLINT,
           val_tolerancia_pagam_vendor LIKE cre_compl_portador.parametro_val,
           iof_por_conta_vendor        CHAR(01),
           qtd_dias_venc_vendor        SMALLINT
         END RECORD

  DEFINE m_arquivo_texto               SMALLINT

  DEFINE mr_consulta_aux RECORD
         tipo_ordenacao CHAR(01)
         END RECORD

  # END MODULARES #

#-------------------------------#
 FUNCTION geo1017_version_info()
#-------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Sustentacao/10R2-11R0/10R2-11R0/financeiro/contas_receber/programas/geo1017.4gl $|$Revision: 39 $|$Date: 08/01/13 09:50 $|$Modtime: 12/04/11 8:52 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION

#---------------------------#
 FUNCTION geo1017_controle(lr_tela)
#---------------------------#
   DEFINE lr_tela               RECORD
          cod_empresa                  LIKE adocum_pgto.cod_empresa     ,
          num_docum                    LIKE docum.num_docum             ,
          ies_tip_docum                LIKE docum.ies_tip_docum         ,
          ies_tip_pgto                 LIKE docum_pgto.ies_tip_pgto     ,
          ies_forma_pgto               LIKE docum_pgto.ies_forma_pgto   ,
          cod_portador                 LIKE docum.cod_portador          ,
          ies_tip_portador             LIKE docum.ies_tip_portador      ,
          dat_pgto                     LIKE docum_pgto.dat_pgto         ,
          dat_credito                  LIKE docum_pgto.dat_credito      ,
          val_saldo                    LIKE docum.val_saldo             ,
          val_desc_conc                LIKE docum_pgto.val_desc_conc    ,
          val_juro_pago                LIKE docum_pgto.val_juro_pago    ,
          ies_abono_juros              CHAR(01)                         ,
          val_desp_cartorio            LIKE docum_pgto.val_desp_cartorio,
          val_despesas                 LIKE docum_pgto.val_despesas     ,
          val_multa                    DECIMAL(15,2)                    ,
          val_glosa                    DECIMAL(15,2)
                                END RECORD
   DEFINE l_ies_pgto_docum      LIKE docum.ies_pgto_docum
   
   ### CRE03600 ADAPTADO COMO FUNCAO RECEBENDO PARAMETROS PARA BAIXA DE TITULOS
   SELECT DISTINCT ies_pgto_docum
     INTO l_ies_pgto_docum
     FROM docum
    WHERE cod_empresa    = lr_tela.cod_empresa
      AND num_docum      = lr_tela.num_docum
      AND ies_tip_docum = lr_tela.ies_tip_docum
      
   IF l_ies_pgto_docum = 'T' THEN
      #CALL _ADVPL_message_box("O título "||lr_tela.num_docum||" já está integralmente baixado")
      RETURN TRUE
   END IF 
   
   INITIALIZE p_val_a_pagar    TO NULL
   INITIALIZE pr_docum_pgto_trb.*,
               p_docum_estorno.*,
               p_docum_estorno_trb.*,
               pr_conc_pgto_trb.*,
               pr_creconc.*,
               p_docum_pgto_txt.*,
               p_adocum_pgto.*,
               p_docum_pgto.*,
               p_par_cre.*,
               p_ies_docpgtxt TO NULL
    
    WHENEVER ERROR CONTINUE
        SELECT parametro
         INTO m_parametro
         FROM par_cre_txt

       SELECT ies_tip_cobr_juro, ies_conc_bco_cxa
         INTO m_ies_tip_cobr_juro, m_ies_conc_bco_cxa
         FROM par_cre
    WHENEVER ERROR STOP

    LET p_nom_programa = 'CRE0360'
#  os439463 ----
    LET p_par_cre_txt.parametro = m_parametro
#  os439463 ----
    
    INITIALIZE mr_docum_aberto.*,
               mr_dados_pagto.*,
               ma_outros TO NULL

    LET p_ies_docpgtxt = FALSE

    LET m_som_val_juros = 0
    LET m_som_val_desc  = 0
    LET m_som_val_abat  = 0
    LET m_som_qtd_docum = 0
    LET m_cancela = FALSE
    LET m_total         = 0
    
   LET g_cod_prg_chamador = "CRE03600"
   LET m_val_tarifa_acum  = 0

   IF geo1017_cria_tabela_temp() = FALSE THEN
      CALL log0030_mensagem ('Problema ao criar tabelas temporárias', 'exclamation')
   END IF

   #OS 404764

   IF   geo1017_busca_log2250(p_cod_empresa) = FALSE
   THEN
   END IF
   CALL geo1017_par_con()

   LET m_arquivo_texto = FALSE

   
   LET mr_tela.* = lr_tela.*
   
   LET mr_dados_pagto.portador1 = lr_tela.cod_portador
   LET mr_dados_pagto.tip_portador1 = lr_tela.ies_tip_portador
   LET mr_dados_pagto.dat_lanc = lr_tela.dat_pgto
   LET mr_dados_pagto.forma_pgto = lr_tela.ies_forma_pgto
       
   #ma_outros
   
   LET m_ind = 1
   LET ma_principal[m_ind].empresa   = lr_tela.cod_empresa
   LET ma_principal[m_ind].docum     = lr_tela.num_docum
   LET ma_principal[m_ind].tip_docum = lr_tela.ies_tip_docum
   LET ma_principal[m_ind].dat_pgto  = lr_tela.dat_pgto
   LET ma_principal[m_ind].val_saldo = lr_tela.val_saldo
   LET ma_principal[m_ind].val_desc  = lr_tela.val_desc_conc
   LET ma_principal[m_ind].val_juros = lr_tela.val_juro_pago
   LET ma_principal[m_ind].marcado   = 'X'
   
   LET ma_outros[m_ind].dat_cred     = lr_tela.dat_credito
   LET ma_outros[m_ind].tot_pagto    = lr_tela.val_saldo
   
   
   CALL geo1017_soma_selecionados()
   
   IF geo1017_organiza_dados() THEN
      IF geo1017_processa() THEN
         RETURN TRUE
      ELSE
         RETURN FALSE
      END IF 
   ELSE
      RETURN FALSE
   END IF 
   

END FUNCTION

#------------------------------------------#
 FUNCTION geo1017_consulta_docum_aberto()
#------------------------------------------#
 DEFINE l_digitou SMALLINT

 LET l_digitou = FALSE
 LET m_dados_array = FALSE ### OS 590916

   #:::::::::::::::::::::: ATENÇÃO - NÃO EXCLUIR ESTE COMENTARIO
   #:::: SEMPRE QUE FOR ALTERADA A TELA PADRÃO, DEVE-SE VERIFICAR A NECESSIDADE DE ALTERAÇÃO
   #:::: DAS TELAS ESPECIFICAS TAMBEM.
   #:::: A FUNÇÃO cre0360y_open_window_principal É UM PONTO DE ENTRADA PARA ABERTURA DE TELAS
   #:::: ESPECIFICAS.
   #::::
   #::::::: CLIENTES QUE ESTÃO UTILIZANDO ESTE PONTO DE ENTRADA.
   #:::: ( Caso outros clientes comecem a utilizar este ponto de entrada favor inclui-lo na lista abaixo )
   #::::
   #:::: -> 784 - COMIL ONIBUS
   {IF LOG_existe_epl("cre0360y_open_window_principal") THEN

      CALL LOG_setVar( "caminho_tela_especifica", " " )

      CALL cre0360y_open_window_principal()

      LET m_comando = LOG_getVar( "caminho_tela_especifica" )

   ELSE
      CALL log1300_procura_caminho('cre03602','cre03602') RETURNING m_comando
   END IF

   CALL log006_exibe_teclas('01',p_versao)}

   {OPEN WINDOW w_cre03602 AT 2,2 WITH FORM m_comando
   ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU 'OPÇÃO'

   BEFORE MENU
     IF Find4GLFunction("crey42_abre_tela_especifica_1132") THEN #OS 594370
        LET m_abre_tela_especifica = crey42_abre_tela_especifica_1132()
     ELSE
        LET m_abre_tela_especifica = FALSE
     END IF

   COMMAND 'Consultar'    'Consulta documentos em aberto.'
      HELP 004
      MESSAGE ' '
      IF log005_seguranca(p_user,'CRECEBER','geo1017','CO')  THEN
         LET m_tem_dados = FALSE

         IF m_abre_tela_especifica THEN
            #Não precisa chamar Find4GLFunction, poir já valida a variável M_ABRE_TELA_ESPECIFICA
            CALL crey42_deleta_tabela_temp()
         END IF

         IF log_existe_epl( "geo1017y_deleta_tabela_temp" ) THEN
            CALL geo1017y_deleta_tabela_temp()
         END IF
         WHENEVER ERROR CONTINUE
         DELETE FROM wmarcados;
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('DELETE','WMARCADOS')
         END IF
         CALL geo1017_consulta_docuns()
         LET l_digitou = FALSE
         NEXT OPTION 'Modificar'
      END IF

   COMMAND 'Modificar'    'Modifica dados pagamento.'
      HELP 002
      MESSAGE ' '
      IF log005_seguranca(p_user,'CRECEBER','geo1017','MO')  THEN
         IF m_ind > 0 THEN
            IF geo1017_entrada_dados_pgto() THEN
               CALL geo1017_exibe_array()
            END IF
            IF mr_dados_pagto.portador1 IS NOT NULL AND
               mr_dados_pagto.portador1 <> ' ' THEN
               LET l_digitou = TRUE
               NEXT OPTION 'Lote'
            ELSE
               CALL log0030_mensagem('Informe os dados de pagamento.','exclamation')
               LET l_digitou = FALSE
               NEXT OPTION 'Modificar'
            END IF
         ELSE
            CALL log0030_mensagem('Não existem dados para serem modificados, efetue a consulta.','exclamation')
            NEXT OPTION 'Consultar'
         END IF
      END IF

   COMMAND 'Lote'    'Manutenção dados pagamento.'
      HELP 011
      MESSAGE ' '
      IF log005_seguranca(p_user,'CRECEBER','geo1017','CO')  THEN
         IF m_val_difer <> 0 THEN
            CALL log0030_mensagem('Lote com diferença, é necessário fazer ajuste.','exclamation')
            NEXT OPTION 'Consultar'
         ELSE
            LET m_esta_na_consulta = FALSE
            IF l_digitou THEN
               IF m_dados_array THEN ### OS 590916
                  CALL geo1017_controle_2()
               ELSE ### OS 590916
                  CALL log0030_mensagem('Não foram selecionados documentos para liquidação.','excl')
                  NEXT OPTION 'Modificar'
               END IF
            ELSE
               CALL log0030_mensagem('Informe os dados de pagamento.','exclamation')
               NEXT OPTION 'Modificar'
            END IF
         END IF
      END IF

   COMMAND KEY ('!')
      PROMPT 'Digite o comando : ' FOR m_comando
      RUN m_comando
      PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando

    COMMAND 'Fim'        'Retorna ao Menu Anterior'
      HELP 008
      EXIT MENU

  #lds COMMAND KEY ("control-F1") "Sobre" "Informações sobre a aplicação (CTRL-F1)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

   END MENU

   CLOSE WINDOW w_cre03602
   }
 END FUNCTION
#-------------------------------#
 FUNCTION geo1017_controle_2()
#-------------------------------#

   DEFINE l_resp            CHAR(01)
   DEFINE l_mensagem        CHAR(100)

   LET m_ies_processou = FALSE
   INITIALIZE l_resp TO NULL

   CALL log130_procura_caminho('cre03601') RETURNING m_comando

   CALL log006_exibe_teclas('01',p_versao)

  {OPEN WINDOW w_geo1017 AT 2,2 WITH FORM m_comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU 'OPÇÃO'
  BEFORE MENU

     IF Find4GLFunction("crey42_abre_tela_especifica_1132") THEN #OS 594370
        LET m_abre_tela_especifica = crey42_abre_tela_especifica_1132()
     ELSE
        LET m_abre_tela_especifica = FALSE
     END IF

     IF m_abre_tela_especifica THEN
        IF mr_tela.ies_tip_pgto = "S" OR mr_tela.ies_tip_pgto = "N" THEN
           HIDE OPTION "coNhec_frete"
           CALL crey42_cria_temp_conhecimento()
           RETURNING p_status
        ELSE
           CALL crey42_cria_temp_conhecimento()
           RETURNING p_status
        END IF
     ELSE
        IF log_existe_epl( "geo1017y_cria_temp_conhecimento" ) THEN
           IF mr_tela.ies_tip_pgto = "S" OR mr_tela.ies_tip_pgto = "N" THEN
              HIDE OPTION "coNhec_frete"
           END IF
           CALL geo1017y_cria_temp_conhecimento() RETURNING p_status
        ELSE
        HIDE OPTION "coNhec_frete"
        END IF
     END IF

      IF m_cre_most_tela_doc = 'S' OR m_arquivo_texto = TRUE THEN
         HIDE OPTION 'Incluir'
      END IF

      IF LOG_getVar("efetua_leitura_txt") THEN
         HIDE OPTION 'Incluir'
      END IF


   COMMAND 'Incluir'    'Inclui um novo pagamento.'
      HELP 001
      MESSAGE ' '
      IF mr_dados_pagto.portador1 IS NULL OR mr_dados_pagto.dat_lanc IS NULL THEN
         IF log005_seguranca(p_user,'CRECEBER','geo1017','IN') THEN
            IF m_informou_dados = TRUE THEN
               PROMPT "Dados informados não foram efetivados. Processar? (S/N)." FOR l_resp
               IF l_resp = 'S' or l_resp = 's' THEN
                  NEXT OPTION 'Processar'
               ELSE
                 LET m_tem_dados = FALSE
                 IF geo1017_inclusao() THEN
                    LET m_informou_dados = TRUE
                    MESSAGE "Inclusão efetuada com sucesso" ATTRIBUTE(REVERSE)
                    NEXT OPTION 'Processar'
                 ELSE
                    LET m_informou_dados = FALSE
                 END IF
               END IF
            ELSE
               IF geo1017_inclusao() THEN
                  LET m_informou_dados = TRUE
                  MESSAGE "Inclusão efetuada com sucesso" ATTRIBUTE(REVERSE)
                  NEXT OPTION 'Processar'
               ELSE
                  LET m_informou_dados = FALSE
               END IF
            END IF
         END IF
      ELSE
         IF geo1017_inclusao() THEN
            LET m_consulta_ativa = TRUE
            LET m_informou_dados = TRUE
            MESSAGE  "Inclusão efetuada com sucesso" ATTRIBUTE(REVERSE)
            NEXT OPTION 'Processar'
         END IF
      END IF

   COMMAND 'Modificar' 'Modifica um pagamento existente.'
      HELP 002
      MESSAGE ' '
      IF m_consulta_ativa THEN
         IF log005_seguranca(p_user,'CRECEBER','geo1017','MO') THEN
            CALL geo1017_modificacao()
            NEXT OPTION 'Processar'
         END IF
      ELSE
        CALL log0030_mensagem(' Consulte previamente. ','exclamation')
      END IF

    COMMAND 'Consultar' 'Consulta por pagamentos.'
      HELP 004
      MESSAGE ' '
      IF log005_seguranca(p_user,'CRECEBER','CRE00005','CO')  THEN
         LET m_tem_dados = FALSE
         IF geo1017_consulta() THEN
            LET m_consulta_ativa = TRUE
            LET m_informou_dados = TRUE
         END IF
      END IF

    COMMAND 'Seguinte'   'Exibe o próximo pagamento da consulta'
      HELP 005
      MESSAGE ' '
      IF m_consulta_ativa THEN
         CALL geo1017_paginacao('SEGUINTE')
         IF m_tem_dados THEN
            NEXT OPTION 'Modificar'
         END IF
      ELSE
         CALL log0030_mensagem(' Consulte previamente. ','exclamation')
      END IF

    COMMAND 'Anterior'   'Exibe o pagamento anterior encontrado na consulta'
      HELP 006
      MESSAGE ''
      IF m_consulta_ativa THEN
         CALL geo1017_paginacao('ANTERIOR')
         IF m_tem_dados THEN
            NEXT OPTION 'Modificar'
         END IF
      ELSE
         CALL log0030_mensagem(' Consulte previamente. ','exclamation')
      END IF

    COMMAND 'Listar'  'Lista erro no pagamento'
        HELP 009
        MESSAGE ''
        LET INT_FLAG = 0
        IF m_ies_processou = TRUE THEN
           IF log0280_saida_relat(16,30) IS NOT NULL THEN
              CALL geo1017_listagem()
           END IF
        ELSE
           CALL log0030_mensagem('Não existe pagamento para listar.','exclamation')
        END IF

     COMMAND 'Processar'   'Processa o pagamento do documento informado '
        HELP 010
        MESSAGE ''
        LET INT_FLAG = 0
        IF m_informou_dados = TRUE THEN
           IF log0040_confirm(17,25,'Confirma processamento?') THEN
              IF geo1017_processa() THEN
                 LET m_ies_processou = TRUE
                 LET m_informou_dados = FALSE
                 LET l_mensagem = 'Processamento do lote ',m_num_lot USING "<<<<<<<&",' efetuado com sucesso.'
                 CALL log0030_mensagem(l_mensagem, 'excl')
                 #MESSAGE  'Processamento efetuado com sucesso' ATTRIBUTE(REVERSE)

                 IF mr_dados_pagto.portador1 IS NOT NULL AND
                    mr_dados_pagto.portador1 <> ' ' AND
                    mr_dados_pagto.dat_lanc IS NOT NULL THEN
                 ELSE
                    INITIALIZE mr_tela.* TO NULL
                 END IF
                 INITIALIZE m_num_lot TO NULL
                 CLEAR FORM
                 IF m_tem_dados THEN
                    NEXT OPTION 'Seguinte'
                 ELSE
                    NEXT OPTION 'Fim'
                 END IF
              ELSE
                 IF m_cancela THEN
                    CALL log0030_mensagem('Processamento cancelado.','exclamation')
                    NEXT OPTION 'Fim'
                 ELSE
                    CALL log0030_mensagem('Erro no processamento. Acessar a opção listar para verificar os erros.','stop') #OS 603292
                    NEXT OPTION 'Listar'
                 END IF
              END IF
           ELSE
              CALL log0030_mensagem('Processamento cancelado.','exclamation')
           END IF
        ELSE
           CALL log0030_mensagem('Informe os dados do documento primeiramente','info')
        END IF

    COMMAND KEY ("N") "coNhec_frete" "Conhecimento de frete"
       MESSAGE ""
       IF Find4GLFunction("crey42_entrada_dados_conhecimentos") THEN #OS 594370
          CALL crey42_entrada_dados_conhecimentos(mr_tela.cod_empresa  ,
                                                  mr_tela.num_docum    ,
                                                  mr_tela.ies_tip_docum,
                                                  mr_tela.ies_tip_pgto ,
                                                  m_num_lot            )
          RETURNING p_status
          CURRENT WINDOW IS w_geo1017
       END IF

       IF log_existe_epl("geo1017y_entrada_dados_conhecimentos") THEN
          CALL LOG_setVar( "PRG_cod_empresa",      mr_tela.cod_empresa   )
          CALL LOG_setVar( "PRG_num_docum",        mr_tela.num_docum     )
          CALL LOG_setVar( "PRG_ies_tip_docum",    mr_tela.ies_tip_docum )
          CALL LOG_setVar( "PRG_ies_tip_pgto",     mr_tela.ies_tip_pgto  )
          CALL LOG_setVar( "PRG_num_lote",         m_num_lot             )

          CALL geo1017y_entrada_dados_conhecimentos() RETURNING p_status

          CURRENT WINDOW IS w_geo1017
       END IF
    COMMAND KEY ('!')
      PROMPT 'Digite o comando : ' FOR m_comando
      RUN m_comando
      PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando

    COMMAND 'Fim'        'Retorna ao Menu Anterior'
      HELP 008
      EXIT MENU

  #lds COMMAND KEY ("control-F1") "Sobre" "Informações sobre a aplicação (CTRL-F1)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

   END MENU

   CLOSE WINDOW w_geo1017
}
 END FUNCTION

#---------------------------#
 FUNCTION geo1017_inclusao()
#---------------------------#

  LET m_i = 0

  LET m_num_lot = 0

  IF m_parametro[92,98] IS NOT NULL AND m_parametro[92,98] <> ' '  THEN
     LET m_num_lot = m_parametro[92,99]
  END IF

  LET m_num_lot = m_num_lot + 1
  LET m_parametro[92,99] = m_num_lot USING "&&&&&&&&"

  WHENEVER ERROR CONTINUE
   UPDATE par_cre_txt
   SET parametro = m_parametro
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('UPDATE','PAR_CRE_TXT')
  END IF

  IF geo1017_inclui() THEN
  ELSE
     LET m_num_lot = m_num_lot - 1
     LET m_parametro[92,99] = m_num_lot USING "&&&&&&&&"
     WHENEVER ERROR CONTINUE
      UPDATE par_cre_txt
         SET parametro = m_parametro
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('UPDATE','PAR_CRE_TXT')
     END IF
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION geo1017_inclui()
#--------------------------#

 IF geo1017_entrada_dados('INCLUSAO') THEN

     CALL log085_transacao('BEGIN')
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('BEGIN','ENTRADA DADOS')
     END IF

     IF NOT geo1017_grava_dados()THEN
        CALL log085_transacao('ROLLBACK')
        RETURN FALSE
     ELSE
        CALL log085_transacao('COMMIT')
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('COMMIT','ENTRADA DADOS')
        END IF
     END IF
  ELSE
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION geo1017_consulta_docuns()
#-----------------------------------#
 INITIALIZE ma_principal, ma_principal_aux, ma_principal_obs TO NULL


 LET m_total_a_pagar = 0
 LET m_valor_pagar   = 0
 LET m_juros_pagar   = 0
 LET m_desc_conceder = 0
 LET m_total_saldo   = 0
 LET m_total_juro    = 0
 LET m_total_desc    = 0
 LET m_val_difer     = 0
 INITIALIZE mr_docum_aberto.* ,
            mr_dados_pagto.*  ,
            mr_consulta_aux.* TO NULL

 DELETE FROM cre0270_clientes
  WHERE nom_usuario  = p_user
    AND cod_programa = p_nom_programa

 WHENEVER ERROR CONTINUE
  SELECT *
    INTO p_par_cre.*
    FROM par_cre
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('SELECT','PAR_CRE')
    INITIALIZE p_par_cre.* TO NULL
 END IF

 IF geo1017_entrada_docum_aberto() THEN         # Entrada dados DOCUM
    IF geo1017_entrada_dados_tipo_ordenacao() THEN
       CALL geo1017_busca_documentos()
    END IF
 END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION geo1017_entrada_docum_aberto()
#-----------------------------------------#

  DEFINE l_cont          SMALLINT,
         l_ind           SMALLINT,
         l_filtro_aux    SMALLINT,
         l_ind2          SMALLINT,
         l_texto         VARCHAR(500),
         l_texto_aux     VARCHAR(500)

  DEFINE l_ies_tip_docum VARCHAR(10),
         l_status        SMALLINT,
         l_msg           VARCHAR(200),
         l_cod_empresa   LIKE empresa.cod_empresa,
         l_between       SMALLINT,
         l_contador      SMALLINT


  LET INT_FLAG = FALSE

  CLEAR FORM
  INITIALIZE mr_docum_aberto.*,
             mr_dados_pagto.* TO NULL

  LET m_existe_dado = FALSE
  #CALL log006_exibe_teclas('01 03 07',p_versao)
  #CURRENT WINDOW IS w_cre03602

  #::: Função utilizada somente para inicializar as variaveis do INPUT ESPECIFICO.
  #IF LOG_existe_epl("cre0360y_before_input") THEN
  #   CALL cre0360y_before_input()
  #END IF

{
  CONSTRUCT BY NAME where_clause ON docum.cod_empresa,
                                    docum.num_docum,
                                    docum.ies_tip_docum,
                                    docum.dat_emis,
                                    docum.dat_vencto_s_desc,
                                    docum.cod_cliente,
                                    docum.cod_portador,
                                    docum.ies_tip_portador,
                                    clientes.num_cgc_cpf,
                                    clientes.cod_tip_cli

    BEFORE FIELD cod_empresa
      IF m_parametro[217] = "S" THEN
         DISPLAY p_cod_empresa TO cod_empresa
         NEXT FIELD NEXT
      END IF
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD cod_empresa
      CALL GET_FLDBUF(cod_empresa) RETURNING l_cod_empresa
      CALL geo1017_ativa_zoom(FALSE)

    BEFORE FIELD ies_tip_docum
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD ies_tip_docum
      CALL GET_FLDBUF(ies_tip_docum) RETURNING l_ies_tip_docum
      CALL fin85000_verifica_titulo_expo(l_cod_empresa, l_ies_tip_docum) RETURNING l_status, l_msg
      IF l_status = TRUE THEN
          ERROR l_msg
          NEXT FIELD ies_tip_docum
      END IF
      CALL geo1017_ativa_zoom(FALSE)

    AFTER FIELD dat_vencto_s_desc
       CALL GET_FLDBUF(dat_vencto_s_desc) RETURNING m_dat_vencto_s_desc

    BEFORE FIELD cod_cliente
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD cod_cliente
      CALL geo1017_ativa_zoom(FALSE)

    BEFORE FIELD cod_portador
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD cod_portador
      CALL geo1017_ativa_zoom(FALSE)

    BEFORE FIELD ies_tip_portador
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD ies_tip_portador
      CALL geo1017_ativa_zoom(FALSE)

    AFTER FIELD num_cgc_cpf
       CALL get_fldbuf(num_cgc_cpf) RETURNING m_num_cgc_cpf

    BEFORE FIELD cod_tip_cli
       CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD cod_tip_cli
       IF fgl_lastkey() = fgl_keyval("UP")
       OR FGL_LASTKEY() = fgl_keyval("LEFT") THEN
          NEXT FIELD num_cgc_cpf
       END IF

       CALL GET_FLDBUF(cod_tip_cli) RETURNING m_cod_tip_cli
       CALL geo1017_ativa_zoom(FALSE)

       IF m_cod_tip_cli IS NOT NULL AND m_cod_tip_cli <> " " THEN
          LET mr_docum_aberto.cod_tip_cli = m_cod_tip_cli
          IF geo1017_verifica_cod_tip_cli() = FALSE THEN
             NEXT FIELD cod_tip_cli
          END IF
       END IF


      IF LOG_existe_epl("cre0360y_after_field_cod_tip_cli") THEN

         CALL LOG_setVar( "int_flag"    , int_flag )
         CALL LOG_setVar( "fgl_lastkey" , " " )

         CALL cre0360y_after_field_cod_tip_cli()

         LET int_flag = LOG_getVar( "int_flag" )

         IF int_flag = 0 THEN
            IF LOG_getVar( "fgl_lastkey" ) = "UP" THEN
               NEXT FIELD cod_tip_cli
            END IF
         END IF

      END IF

    ON KEY (control-z, f4)
      CALL geo1017_zoom_2()

    IF NOT INT_FLAG THEN
    ELSE
       LET int_flag = 0
       #MESSAGE " Consulta cancelada. " ATTRIBUTE(REVERSE)
       #CALL log006_exibe_teclas("01",p_versao)
       #CURRENT WINDOW IS w_cre03602
       RETURN
    END IF
  END CONSTRUCT

  # Considerar a data prorrogada na consulta também.
  IF where_clause LIKE '%docum.dat_vencto_s_desc%' THEN

     FOR l_ind = 1 TO LENGTH(where_clause)
        IF where_clause[l_ind,l_ind + 22] = 'docum.dat_vencto_s_desc' THEN
           #LET l_ind = l_ind+24
           EXIT FOR
        END IF

     END FOR

     LET l_filtro_aux = FALSE
     LET l_between    = FALSE
     LET l_contador   = 0

     FOR l_ind2 = (l_ind + 22) TO LENGTH(where_clause)
        IF UPSHIFT(where_clause[l_ind2,l_ind2 + 6]) = 'BETWEEN' THEN
           LET l_between = TRUE
        END IF

        IF UPSHIFT(where_clause[l_ind2,l_ind2 + 2]) = 'AND' THEN
           IF l_between THEN
              LET l_contador = 1
              LET l_between = FALSE
           ELSE
              LET l_contador = 2
           END IF

           IF l_contador = 2 THEN
              LET l_texto_aux  = where_clause[l_ind, l_ind2 -1]
              IF l_ind > 1 THEN
                 LET where_clause = where_clause[1,l_ind - 1],' ',where_clause[l_ind2 + 3,LENGTH(where_clause)]
              ELSE
                 LET where_clause = where_clause[l_ind2 + 3,LENGTH(where_clause)]
              END IF
              LET l_filtro_aux = TRUE

              EXIT FOR
           END IF

        END IF
     END FOR

     IF NOT l_filtro_aux THEN
        LET l_texto_aux  = where_clause[l_ind,l_ind + 199]
        IF l_ind > 1 THEN
           LET where_clause = where_clause[1,l_ind - 1]
        ELSE
           INITIALIZE where_clause TO NULL
        END IF
     END IF

     LET l_texto = l_texto_aux

     CALL log0800_replace(l_texto,'docum.dat_vencto_s_desc','docum.dat_prorrogada') RETURNING l_texto

     LET l_texto = '((docum.dat_prorrogada IS NULL AND ',l_texto_aux CLIPPED,') OR (docum.dat_prorrogada IS NOT NULL AND ',l_texto CLIPPED, '))'

     IF l_filtro_aux THEN
        LET l_texto = ' AND ',l_texto CLIPPED
     END IF

     LET where_clause = where_clause CLIPPED,' ',l_texto
  END IF


  #CALL log006_exibe_teclas('01',p_versao)
  #CURRENT WINDOW IS w_cre03602

  IF int_flag THEN
     LET int_flag = FALSE
     MESSAGE " Consulta cancelada. " ATTRIBUTE(REVERSE)
     RETURN FALSE
  ELSE}
     RETURN TRUE
  #END IF

END FUNCTION

#--------------------------------------#
 FUNCTION geo1017_entrada_dados_pgto()
#--------------------------------------#
 DEFINE l_ind                   SMALLINT

 #CALL log006_exibe_teclas('01 03 07',p_versao)
 #CURRENT WINDOW IS w_cre03602
 LET int_flag = 0

 {INPUT mr_dados_pagto.portador1,
       mr_dados_pagto.tip_portador1,
       mr_dados_pagto.dat_lanc,
       mr_dados_pagto.forma_pgto WITHOUT DEFAULTS
  FROM
       portador1,
       tip_portador1,
       dat_lanc,
       forma_pgto

    BEFORE FIELD portador1
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD portador1
      CALL geo1017_ativa_zoom(FALSE)
      IF mr_dados_pagto.portador1 IS NULL THEN
         CALL log0030_mensagem('Portador inválido. Digite novamente.','exclamation')
         NEXT FIELD portador1
      END IF

    BEFORE FIELD tip_portador1
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD tip_portador1
      IF fgl_lastkey() = fgl_keyval("UP") THEN
         NEXT FIELD portador1
      END IF
      CALL geo1017_ativa_zoom(FALSE)
      IF mr_dados_pagto.tip_portador1 IS NOT NULL AND
         mr_dados_pagto.tip_portador1 <> ' ' THEN
         IF NOT geo1017_verifica_portador(mr_dados_pagto.portador1,mr_dados_pagto.tip_portador1) THEN
            CALL log0030_mensagem ('Portador ou tipo portador inválido', 'exclamation')
            NEXT FIELD portador1
         END IF
      ELSE
         CALL log0030_mensagem('Tipo de portador inválido.Digite novamente.','exclamation')
         NEXT FIELD tip_portador1
      END IF

    AFTER FIELD dat_lanc
       IF fgl_lastkey() = fgl_keyval("UP") THEN
          NEXT FIELD tip_portador1
       END IF
       IF mr_dados_pagto.dat_lanc IS NULL THEN
          CALL log0030_mensagem('Data lançamento inválida. Digite novamente.','exclamation')
          NEXT FIELD dat_lanc
       END IF
       IF m_dat_cre_capa_cncl <> "S" THEN
          FOR l_ind = 1 TO 100
              IF ma_outros[l_ind].dat_cred IS NULL OR ma_outros[l_ind].dat_cred = ' ' THEN
                 EXIT FOR
              END IF
              LET ma_outros[l_ind].dat_cred = mr_dados_pagto.dat_lanc
          END FOR
       END IF

    BEFORE FIELD forma_pgto
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD forma_pgto
      IF fgl_lastkey() = fgl_keyval("UP") THEN
          NEXT FIELD dat_lanc
      END IF
      CALL geo1017_ativa_zoom(FALSE)
      IF mr_dados_pagto.forma_pgto IS NOT NULL AND
         mr_dados_pagto.forma_pgto <> ' ' THEN
         IF NOT geo1017_verifica_forma_pgto(mr_dados_pagto.forma_pgto) THEN
            CALL log0030_mensagem ('Forma de pagamento não cadastrada.','exclamation')
            NEXT FIELD forma_pgto
         END IF

         ### OS 590916
         IF m_ies_conc_bco_cxa = "S" AND
           (mr_dados_pagto.forma_pgto = "BC" OR
            mr_dados_pagto.forma_pgto = "CA") THEN
            CALL log0030_mensagem("As formas de pagamento BC e CA não podem ser incluídas manualmente.","excl")
            NEXT FIELD forma_pgto
         END IF
         ## OS 590916
      ELSE
         CALL log0030_mensagem('Forma de pagamento inválida.Digite novamente.','exclamation')
         NEXT FIELD forma_pgto
      END IF

    ON KEY (control-z, f4)
       CALL geo1017_zoom_2()


    AFTER INPUT
      IF INT_FLAG = FALSE THEN
         IF mr_dados_pagto.tip_portador1 IS NOT NULL AND
            mr_dados_pagto.tip_portador1 <> ' ' THEN
            IF NOT geo1017_verifica_portador(mr_dados_pagto.portador1,mr_dados_pagto.tip_portador1) THEN
               CALL log0030_mensagem ('Portador ou tipo portador inválido', 'exclamation')
               NEXT FIELD portador1
            END IF
         END IF
         IF mr_dados_pagto.forma_pgto IS NOT NULL AND
            mr_dados_pagto.forma_pgto <> ' ' THEN
            IF NOT geo1017_verifica_forma_pgto(mr_dados_pagto.forma_pgto) THEN
               CALL log0030_mensagem ('Forma de pagamento não cadastrada na tabela','exclamation')
               NEXT FIELD forma_pgto
            END IF

            ### OS 590916
            IF m_ies_conc_bco_cxa = "S" AND
              (mr_dados_pagto.forma_pgto = "BC" OR
               mr_dados_pagto.forma_pgto = "CA") THEN
               CALL log0030_mensagem("As formas de pagamento BC e CA não podem ser incluídas manualmente.","excl")
               NEXT FIELD forma_pgto
            END IF
            ### OS 590916
         END IF

         IF NOT geo1017_entrada_outros() THEN
            NEXT FIELD portador1
         END IF

      END IF
  END INPUT

  CALL log006_exibe_teclas('01',p_versao)
  CURRENT WINDOW IS w_cre03602}

  IF int_flag = TRUE  THEN
     RETURN FALSE
     LET int_flag = FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#---------------------------------#
 FUNCTION geo1017_entrada_outros()
#---------------------------------#
 DEFINE l_ind        SMALLINT,
        l_tem_dados  SMALLINT
{
 LET m_ind_outros = 1

 IF ma_outros[m_ind_outros].dat_cred IS NULL THEN
    LET ma_outros[m_ind_outros].dat_cred = mr_dados_pagto.dat_lanc
    LET m_count_outros = 1
 END IF

 CALL set_count(m_count_outros)

 LET int_flag = FALSE

 INPUT ARRAY ma_outros WITHOUT DEFAULTS FROM s_tela1.*

   BEFORE ROW
        LET m_ind_outros    = ARR_CURR()
        LET m_count_outros  = ARR_COUNT()
        LET msc_curr        = SCR_LINE()
        IF m_dat_cre_capa_cncl <> "S" THEN
           LET ma_outros[m_ind_outros].dat_cred = mr_dados_pagto.dat_lanc
           DISPLAY ma_outros[m_ind_outros].dat_cred TO s_tela1[msc_curr].dat_cred
        END IF


   BEFORE FIELD dat_cred
        IF m_dat_cre_capa_cncl <> "S" THEN
           LET ma_outros[m_ind_outros].dat_cred = mr_dados_pagto.dat_lanc
           DISPLAY ma_outros[m_ind_outros].dat_cred TO s_tela1[msc_curr].dat_cred
           NEXT FIELD tot_pagto
        END IF

   AFTER FIELD dat_cred
      IF fgl_lastkey() = fgl_keyval("UP") THEN
         IF m_ind_outros = 1 THEN
            RETURN FALSE
         END IF
      END IF
      IF ma_outros[m_ind_outros].dat_cred IS NOT NULL THEN
         IF ma_outros[m_ind_outros].dat_cred > p_par_cre.dat_proces_bxa THEN
            CALL log0030_mensagem('Data de crédito fora dos limites.','exclamation')
            NEXT FIELD dat_cred
         END IF
      ELSE
         IF m_ind_outros = 1 THEN
            CALL log0030_mensagem('Data de crédito inválida. Digite novamente.','exclamation')
            NEXT FIELD dat_cred
         END IF
      END IF

   AFTER FIELD tot_pagto
      IF fgl_lastkey() = fgl_keyval("UP") THEN
         IF m_ind_outros = 1 THEN
            RETURN FALSE
         END IF
      END IF
      IF ma_outros[1].tot_pagto IS NULL OR
         ma_outros[1].tot_pagto = 0 THEN
         CALL log0030_mensagem('Valor de pagamento inválido. Digite novamente.','exclamation')
         NEXT FIELD tot_pagto
      END IF
      IF ma_outros[m_ind_outros].tot_pagto IS NOT NULL AND
         ma_outros[m_ind_outros].tot_pagto = 0 THEN
         LET ma_outros[m_ind_outros].dat_cred = NULL
         DISPLAY ma_outros[m_ind_outros].dat_cred TO s_tela1[msc_curr].dat_cred
      END IF

   AFTER INPUT
     IF int_flag = FALSE THEN
        LET l_tem_dados = FALSE
        IF m_ind_outros = 1 THEN
        ELSE
           FOR l_ind = 1 TO m_count_outros
              IF ma_outros[l_ind].dat_cred IS NOT NULL THEN
                 LET l_tem_dados = TRUE
              END IF
           END FOR
           IF l_tem_dados = FALSE THEN
              CALL log0030_mensagem('Data de crédito não informada.','exclamation')
              NEXT FIELD dat_cred
           END IF
           LET l_tem_dados = FALSE
           FOR l_ind = 1 TO m_count_outros
              IF ma_outros[l_ind].tot_pagto IS NOT NULL THEN
                 LET l_tem_dados = TRUE
              END IF
           END FOR
           IF l_tem_dados = FALSE THEN
              CALL log0030_mensagem('Valor de pagamento não informado.','exclamation')
              NEXT FIELD tot_pagto
           END IF
        END IF
     END IF
 END INPUT

 CALL geo1017_calcula_total_pag()
}
 RETURN TRUE

END FUNCTION

#--------------------------------------#
 FUNCTION geo1017_calcula_total_pag()
#--------------------------------------#
  DEFINE l_ind    SMALLINT

  LET m_total_a_pagar = 0
  FOR l_ind = 1 TO 100
     IF ma_outros[l_ind].tot_pagto IS NOT NULL THEN
        LET m_total_a_pagar = m_total_a_pagar + ma_outros[l_ind].tot_pagto
     END IF
  END FOR


END FUNCTION

#-----------------------------#
 FUNCTION geo1017_grava_dados()
#------------------------------#

  DEFINE l_num_seq INTEGER

     LET l_num_seq = 0

     WHENEVER ERROR CONTINUE
     SELECT cod_empresa
       FROM adocum_pgto
      WHERE cod_empresa      = mr_tela.cod_empresa
        AND cod_portador     = mr_tela.cod_portador
        AND ies_tip_portador = mr_tela.ies_tip_portador
        AND num_lote         = m_num_lot
        AND num_docum        = mr_tela.num_docum
        AND ies_tip_docum    = mr_tela.ies_tip_docum
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
        WHENEVER ERROR CONTINUE
        UPDATE adocum_pgto SET ies_sit_docum     = 'I',
                               ies_tip_pgto      = mr_tela.ies_tip_pgto,
                               ies_forma_pgto    = mr_tela.ies_forma_pgto,
                               dat_pgto          = mr_tela.dat_pgto,
                               dat_credito       = mr_tela.dat_credito,
                               dat_lanc          = m_dat_lancamento,
                               val_titulo        = mr_tela.val_saldo,
                               val_juro          = mr_tela.val_juro_pago,
                               val_desc          = mr_tela.val_desc_conc,
                               val_abat          = 0,
                               val_desp_cartorio = mr_tela.val_desp_cartorio,
                               val_despesas      = mr_tela.val_despesas,
                               ies_abono_juros   = mr_tela.ies_abono_juros,
                               val_multa         = mr_tela.val_multa,
                               val_ir            = 0
         WHERE cod_empresa      = mr_tela.cod_empresa
           AND cod_portador     = mr_tela.cod_portador
           AND ies_tip_portador = mr_tela.ies_tip_portador
           AND num_lote         = m_num_lot
           AND num_docum        = mr_tela.num_docum
           AND ies_tip_docum    = mr_tela.ies_tip_docum
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('ALTERACAO','ADOCUM_PGTO')
           RETURN FALSE
        END IF
     ELSE
        WHENEVER ERROR CONTINUE
        INSERT INTO adocum_pgto
               VALUES(mr_tela.cod_portador     ,
                      mr_tela.ies_tip_portador ,
                      m_num_lot                ,
                      mr_tela.cod_empresa      ,
                      mr_tela.num_docum        ,
                      mr_tela.ies_tip_docum    ,
                      'I'                      ,
                      mr_tela.ies_tip_pgto     ,
                      mr_tela.ies_forma_pgto   ,
                      mr_tela.dat_pgto         ,
                      mr_tela.dat_credito      ,
                      m_dat_lancamento         ,
                      mr_tela.val_saldo        ,
                      mr_tela.val_juro_pago    ,
                      mr_tela.val_desc_conc    ,
                      0                        ,
                      mr_tela.val_desp_cartorio,
                      mr_tela.val_despesas     ,
                      mr_tela.ies_abono_juros  ,
                      mr_tela.val_multa        ,
                      0)
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
            IF cre1590_monta_wcre1591('Erro na gravação da preparação da baixa (ADOCUM_PGTO)') = FALSE THEN
               RETURN FALSE
            END IF
            RETURN FALSE
        END IF
     END IF

     IF NOT geo1017_atualiza_vendor(mr_tela.cod_empresa  ,
                                     mr_tela.num_docum    ,
                                     mr_tela.ies_tip_docum,
                                     mr_tela.dat_pgto     ,
                                     mr_tela.ies_tip_pgto ) THEN
        RETURN FALSE
     END IF

     LET m_som_dat_lanc = 0
     LET m_som_dat_pgto = 0
     LET m_som_dat_cred = 0

     CALL geo1017_busca_dat_decimal()

     LET m_som_dat_lanc = m_som_dat_lanc + m_dat_dec08
     LET m_som_dat_pgto = m_som_dat_pgto + m_dat_dec08
     LET m_som_dat_cred = m_som_dat_cred + m_dat_dec08
     LET m_som_val_titulo= 0
     LET m_som_val_titulo= mr_tela.val_saldo + mr_tela.val_juro_pago

     IF m_som_dat_lanc IS NULL THEN
        LET m_som_dat_lanc = m_dat_dec08
     END IF

     IF m_som_dat_pgto IS NULL THEN
        LET m_som_dat_pgto = m_dat_dec08
     END IF

     IF m_som_dat_cred IS NULL THEN
        LET m_som_dat_cred = m_dat_dec08
     END IF

     WHENEVER ERROR CONTINUE
      SELECT cod_empresa
        FROM adocum_pgto_capa
       WHERE cod_empresa      = mr_tela.cod_empresa
         AND cod_portador     = mr_tela.cod_portador
         AND ies_tip_portador = mr_tela.ies_tip_portador
         AND num_lote         = m_num_lot
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
        WHENEVER ERROR CONTINUE
        UPDATE adocum_pgto_capa SET ies_sit_lote   = 'I',
                                    som_dat_pgto   =  m_som_dat_pgto,
                                    som_dat_cred   =  m_som_dat_cred,
                                    som_dat_lanc   =  m_som_dat_lanc,
                                    som_val_titulo =  m_som_val_titulo,
                                    som_val_juros  =  mr_tela.val_juro_pago,
                                    som_val_desc   =  mr_tela.val_desc_conc,
                                    som_val_abat   =  '0',
                                    som_qtd_docum  =  '1'
         WHERE cod_empresa      = mr_tela.cod_empresa
           AND cod_portador     = mr_tela.cod_portador
           AND ies_tip_portador = mr_tela.ies_tip_portador
           AND num_lote         = m_num_lot
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('UPDATE','ADOCUM_PGTO_CAPA')
        END IF
     ELSE
        WHENEVER ERROR CONTINUE
        INSERT INTO adocum_pgto_capa
               VALUES(mr_tela.cod_empresa      ,
                      mr_tela.cod_portador     ,
                      mr_tela.ies_tip_portador ,
                      m_num_lot                ,
                      'I'                      ,
                      m_som_dat_pgto           ,
                      m_som_dat_cred           ,
                      m_som_dat_lanc           ,
                      m_som_val_titulo         ,
                      mr_tela.val_juro_pago    ,
                      mr_tela.val_desc_conc    ,
                      0                        ,
                      1)
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           IF cre1590_monta_wcre1591('Erro na gravação da capa do lote da baixa (ADOCUM_PGTO_CAPA).') = FALSE THEN
              RETURN FALSE
           END IF
        END IF
     END IF

     IF mr_tela.val_glosa > 0 THEN
        # OS 404764 - Grava campo glosa
        WHENEVER ERROR CONTINUE
        SELECT MAX(sequencia_docum)
          INTO l_num_seq
          FROM cre_info_adic_doc
         WHERE cre_info_adic_doc.empresa          = mr_tela.cod_empresa
           AND cre_info_adic_doc.docum            = mr_tela.num_docum
           AND cre_info_adic_doc.tip_docum        = mr_tela.ies_tip_docum
           AND cre_info_adic_doc.campo            = 'VALOR GLOSA'
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           LET l_num_seq = 1
        ELSE
           IF l_num_seq IS NULL THEN
              LET l_num_seq = 1
           ELSE
              LET l_num_seq = l_num_seq + 1
           END IF
        END IF

        WHENEVER ERROR CONTINUE
        INSERT INTO cre_info_adic_doc VALUES (mr_tela.cod_empresa,
                                              mr_tela.num_docum,
                                              mr_tela.ies_tip_docum,
                                              l_num_seq,
                                              'VALOR GLOSA',
                                              NULL,
                                              NULL,
                                              mr_tela.val_glosa,
                                              NULL,
                                              NULL)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           IF cre1590_monta_wcre1591('Erro na gravação da glosa (CRE_INFO_ADIC_DOC).') = FALSE THEN
              RETURN FALSE
           END IF
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
         SELECT docum
           FROM wglosa
          WHERE empresa   = mr_tela.cod_empresa
            AND docum     = mr_tela.num_docum
            AND tip_docum = mr_tela.ies_tip_docum
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           WHENEVER ERROR CONTINUE
            UPDATE wglosa
               SET val_glosa = mr_tela.val_glosa,
                   tip_pgto  = mr_tela.ies_tip_pgto
             WHERE empresa   = mr_tela.cod_empresa
               AND docum     = mr_tela.num_docum
               AND tip_docum = mr_tela.ies_tip_docum
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql('UPDATE','WGLOSA')
           END IF
        ELSE
           WHENEVER ERROR CONTINUE
            INSERT INTO wglosa VALUES (mr_tela.cod_empresa,
                                       mr_tela.num_docum,
                                       mr_tela.ies_tip_docum ,
                                       mr_tela.ies_tip_pgto,
                                       mr_tela.val_glosa)
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql('INSERT','WGLOSA')
           END IF
        END IF
     END IF


     RETURN TRUE

END FUNCTION
#-----------------------------------#
 FUNCTION geo1017_busca_dat_decimal()
#-----------------------------------#

 LET m_dat_char08  = ' '
 LET m_dat_char10  = ' '
 LET m_dat_dec08   = 0

 LET m_dat_char10   = mr_tela.dat_pgto
 LET m_dat_char08   = m_dat_char10[1,2],m_dat_char10[4,5],m_dat_char10[7,10]
 LET m_dat_dec08    = m_dat_char08
 #LET m_som_dat_pgto = m_dat_dec08


 LET m_dat_char10   = m_dat_lancamento
 LET m_dat_char08   = m_dat_char10[1,2],m_dat_char10[4,5],m_dat_char10[7,10]
 LET m_dat_dec08    = m_dat_char08
 #LET m_som_dat_lanc = m_dat_dec08


 LET m_dat_char10   = mr_tela.dat_credito
 LET m_dat_char08   = m_dat_char10[1,2],m_dat_char10[4,5],m_dat_char10[7,10]
 LET m_dat_dec08    = m_dat_char08
 #LET m_som_dat_cred = m_dat_dec08


END FUNCTION

#----------------------------------------#
 FUNCTION geo1017_entrada_dados(l_funcao)
#----------------------------------------#
  DEFINE l_funcao          CHAR(15),
         l_soma            DECIMAL(15,2),
         l_erro            SMALLINT,
         l_ind             INTEGER,
         l_informou        SMALLINT

  DEFINE l_status          SMALLINT
  DEFINE l_msg             VARCHAR(200)

  LET INT_FLAG = FALSE
  LET l_erro   = FALSE
  LET l_ind    = 0
  LET l_informou = FALSE

  IF l_funcao = 'INCLUSAO' THEN
     CLEAR FORM
     INITIALIZE mr_tela.*  TO NULL

     LET mr_tela.cod_empresa       = p_cod_empresa
     LET mr_tela.ies_tip_docum     = 'DP'
     LET mr_tela.ies_abono_juros   = 'N'
     LET mr_tela.val_multa         =  0
     LET mr_tela.val_desp_cartorio =  0
     LET mr_tela.val_juro_pago     =  0
     LET mr_tela.ies_tip_portador  = 'B'
     LET mr_tela.val_despesas      =  0
     LET mr_tela.val_desc_conc     =  0
     LET mr_tela.dat_credito       = ma_outros[1].dat_cred

     IF mr_tela.dat_credito IS NULL THEN
        LET mr_tela.dat_credito = p_par_cre.dat_proces_doc
     END IF

     LET mr_tela.val_glosa         =  0
     LET mr_tela.ies_forma_pgto    = 'OP'
  END IF

 IF NOT m_arquivo_texto THEN
    IF mr_dados_pagto.portador1 IS NULL OR
       mr_dados_pagto.portador1 = ' ' OR
       mr_dados_pagto.dat_lanc IS NULL THEN
       CALL geo1017_busca_dat_proces()
    ELSE
       LET m_dat_lancamento = mr_dados_pagto.dat_lanc
    END IF
 END IF

  #CALL log006_exibe_teclas('01 03 07',p_versao)
  #CURRENT WINDOW IS w_geo1017


  {INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

    BEFORE FIELD cod_empresa
      IF l_funcao = "MODIFICACAO" THEN
         NEXT FIELD NEXT
      END IF

      IF m_parametro[217] = "S" THEN
         LET mr_tela.cod_empresa = p_cod_empresa
         DISPLAY BY NAME mr_tela.cod_empresa
         NEXT FIELD NEXT
      END IF
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD cod_empresa
      CALL geo1017_ativa_zoom(FALSE)

    BEFORE FIELD num_docum
      IF l_funcao = "MODIFICACAO" THEN
         NEXT FIELD NEXT
      END IF

    BEFORE FIELD ies_tip_docum
      IF l_funcao = "MODIFICACAO" THEN
         NEXT FIELD NEXT
      END IF
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD ies_tip_docum

      CALL fin85000_verifica_titulo_expo(mr_tela.cod_empresa , mr_tela.ies_tip_docum ) RETURNING l_status, l_msg
      IF l_status = TRUE THEN
         ERROR l_msg
         NEXT FIELD ies_tip_docum
      END IF

      IF mr_tela.ies_tip_docum IS NOT NULL THEN
         IF geo1017_docum_existe() THEN
            CALL log0030_mensagem("O Documento já está cadastrado.","exclamation")
            NEXT FIELD ies_tip_docum
         END IF
      END IF

      CALL geo1017_ativa_zoom(FALSE)
      CALL geo1017_busca_dados_doc()
      IF geo1017_busca_val_saldo_docum() THEN
      END IF
      CALL geo1017_verifica_desc()
      IF mr_tela.val_saldo = 0 THEN
         CALL log0030_mensagem('Documento sem saldo para pagamento','info')
         NEXT FIELD num_docum
      END IF
      IF NOT  geo1017_seleciona_docum() THEN
         NEXT FIELD num_docum
      END IF

    BEFORE FIELD ies_tip_pgto
      IF mr_tela.ies_tip_pgto IS NULL OR
         mr_tela.ies_tip_pgto = ' ' THEN
         CALL geo1017_busca_tip_pgto()
         DISPLAY BY NAME mr_tela.ies_tip_pgto
      END IF

    BEFORE FIELD ies_forma_pgto
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD ies_forma_pgto
      CALL geo1017_ativa_zoom(FALSE)

      ### OS 590916
      IF m_ies_conc_bco_cxa = "S" AND
        (mr_tela.ies_forma_pgto = "BC" OR
         mr_tela.ies_forma_pgto = "CA") THEN
         CALL log0030_mensagem("As formas de pagamento BC e CA não podem ser incluídas manualmente.","excl")
         NEXT FIELD ies_forma_pgto
      END IF
      ### OS 590916

    AFTER FIELD val_desc_conc
       #459797
       IF NOT geo1017_valida_desconto(mr_tela.cod_empresa,
          mr_tela.val_desc_conc) THEN
          LET mr_tela.val_desc_conc = 0
          NEXT FIELD val_desc_conc
       END IF

      IF mr_dados_pagto.portador1 IS NULL OR
         mr_dados_pagto.portador1 = ' ' OR
         mr_dados_pagto.dat_lanc IS NULL THEN
         CALL geo1017_gerencia_calc_juro(mr_tela.cod_empresa,
                                          mr_tela.dat_pgto,
                                          mr_tela.val_juro_pago,
                                          mr_tela.val_desc_conc)

         IF p_val_juro_a_pag > 0 THEN
            LET mr_tela.val_juro_pago = p_val_juro_a_pag
         ELSE
            LET mr_tela.val_juro_pago =  0
         END IF

         IF p_val_multa_a_pag > 0 THEN
            LET mr_tela.val_multa = p_val_multa_a_pag
         ELSE
            LET mr_tela.val_multa = 0
         END IF

         DISPLAY BY NAME mr_tela.val_juro_pago
         DISPLAY BY NAME mr_tela.val_multa
      END IF

    BEFORE FIELD cod_portador
      IF l_funcao = "MODIFICACAO" THEN
         IF fgl_lastkey() = fgl_keyval("up") OR
            fgl_lastkey() = fgl_keyval("left") THEN
            NEXT FIELD PREVIOUS
         ELSE
            NEXT FIELD NEXT
         END IF
      END IF
      CALL geo1017_ativa_zoom(TRUE)

    AFTER FIELD cod_portador
      CALL geo1017_ativa_zoom(FALSE)

      #Quando não abre tela de consulta, deve atribuir o portador para ser utilizado na integração com o TRB
      IF m_cre_most_tela_doc <> "S" THEN
         LET mr_dados_pagto.portador1     = mr_tela.cod_portador
         LET mr_dados_pagto.tip_portador1 = mr_tela.ies_tip_portador
      END IF

    BEFORE FIELD ies_tip_portador
      IF l_funcao = "MODIFICACAO" THEN
         IF fgl_lastkey() = fgl_keyval("up") OR
            fgl_lastkey() = fgl_keyval("left") THEN
            NEXT FIELD PREVIOUS
         ELSE
            NEXT FIELD NEXT
         END IF
      END IF

    AFTER FIELD ies_tip_portador
      #Quando não abre tela de consulta, deve atribuir o portador para ser utilizado na integração com o TRB
      IF m_cre_most_tela_doc <> "S" THEN
         LET mr_dados_pagto.portador1     = mr_tela.cod_portador
         LET mr_dados_pagto.tip_portador1 = mr_tela.ies_tip_portador
      END IF

      IF NOT geo1017_consiste_portador() THEN
         CALL log0030_mensagem ('Portador ou tipo portador inválido', 'info')
         NEXT FIELD cod_portador
      END IF

    AFTER FIELD dat_pgto
      IF mr_tela.dat_pgto IS NOT NULL THEN
         IF NOT geo1017_verifica_cotacao(mr_tela.cod_empresa,
                                          mr_tela.num_docum,
                                          mr_tela.ies_tip_docum,
                                          mr_tela.dat_pgto,
                                          mr_tela.val_saldo) THEN
            NEXT FIELD dat_pgto
         END IF
      END IF

    BEFORE FIELD dat_credito
           IF m_dat_cre_capa_cncl <> "S" AND mr_dados_pagto.dat_lanc IS NOT NULL THEN
              LET mr_tela.dat_credito = mr_dados_pagto.dat_lanc
              DISPLAY BY NAME mr_tela.dat_credito
              NEXT FIELD val_saldo
           END IF

    AFTER FIELD dat_credito
          IF mr_tela.dat_credito IS NOT NULL THEN
             IF ma_outros[1].dat_cred IS NOT NULL THEN
                FOR l_ind = 1 TO 100
                   IF ma_outros[l_ind].dat_cred IS NULL OR ma_outros[l_ind].dat_cred = ' ' THEN
                      LET mr_tela.dat_credito = NULL
                      EXIT FOR
                   END IF
                   IF ma_outros[l_ind].dat_cred  =  mr_tela.dat_credito THEN
                      EXIT FOR
                   END IF
                END FOR
             END IF
          END IF
          IF mr_tela.dat_credito IS NULL THEN
             CALL log0030_mensagem('Data de crédito difere da(s) data(s) digitada(s) na conciliação bancária.','exclamation')
             NEXT FIELD dat_credito
          END IF

    AFTER FIELD val_saldo
          IF fgl_lastkey() = fgl_keyval("UP")  THEN
             IF m_dat_cre_capa_cncl <> "S" AND mr_dados_pagto.dat_lanc IS NOT NULL THEN
                NEXT FIELD dat_pgto
             END IF
          END IF

    AFTER FIELD ies_abono_juros
       IF mr_tela.ies_abono_juros = 'S' THEN
          LET mr_tela.val_juro_pago = 0
          DISPLAY BY NAME mr_tela.val_juro_pago
       END IF

    AFTER FIELD val_glosa
       IF mr_tela.val_glosa IS NOT NULL THEN
          IF mr_tela.val_glosa > mr_tela.val_saldo THEN
             CALL log0030_mensagem('Valor de glosa não pode ultrapassar o valor título.','exclamation')
             NEXT FIELD val_glosa
          END IF
       END IF

    ON KEY (control-z, f4)
       CALL geo1017_zoom()

    AFTER INPUT

       IF NOT int_flag THEN

          IF mr_tela.cod_empresa IS NOT NULL OR mr_tela.cod_empresa <> ' ' THEN
             IF NOT geo1017_verifica_empresa_cre(mr_tela.cod_empresa)THEN
                CALL log0030_mensagem ('Empresa não cadastrada na tabela empresa_cre', 'exclamation')
                NEXT FIELD cod_empresa
             END IF
          ELSE
             CALL log0030_mensagem ('Campo empresa não preenchido', 'exclamation')
             NEXT FIELD cod_empresa
          END IF

          IF NOT mr_tela.ies_tip_pgto MATCHES '[PSN]' THEN
             CALL log0030_mensagem ('Tipo pagamento inválido', 'exclamation')
             NEXT FIELD ies_tip_pgto
          END IF


          IF mr_tela.num_docum IS NULL OR mr_tela.num_docum = ' ' THEN
             CALL log0030_mensagem (' Campo documento não preenchido', 'exclamation')
             NEXT FIELD num_docum
          END IF

          IF mr_tela.ies_tip_docum IS NULL OR mr_tela.ies_tip_docum  = ' ' THEN
             CALL log0030_mensagem (' Tipo documento não preenchido', 'exclamation')
             NEXT FIELD ies_tip_docum
          ELSE
             IF NOT geo1017_seleciona_docum()THEN
                NEXT FIELD num_docum
             END IF
          END IF

          IF mr_tela.ies_tip_portador IS NULL OR  mr_tela.ies_tip_portador = ' ' THEN
             CALL log0030_mensagem ('Tipo portador não Preenchido', 'exclamation')
             NEXT FIELD ies_tip_portador
          END IF


          IF NOT mr_tela.ies_tip_portador MATCHES '[BCRE]' THEN
             CALL log0030_mensagem ('Tipo portador inválido', 'exclamation')
             NEXT FIELD ies_tip_portador
          ELSE
             IF NOT geo1017_consiste_portador() THEN
                CALL log0030_mensagem ('Portador ou tipo portador inválido', 'exclamation')
                NEXT FIELD cod_portador
             END IF
          END IF


          # INICIO CONSISTENCIAS DO CAMPO DAT-PGTO #
          IF p_docum.val_bruto <> mr_tela.val_saldo THEN
             IF mr_tela.ies_tip_pgto = 'I' THEN
                CALL log0030_mensagem ('Valor do documento não confere ', 'exclamation')
                NEXT FIELD ies_tip_pgto
             END IF
          END IF

          IF p_docum.ies_pgto_docum <> 'P' AND mr_tela.ies_tip_pgto = 'S' THEN
             CALL log0030_mensagem ('Pagamento saldo para documento sem parcela', 'exclamation')
             NEXT FIELD ies_tip_pgto
          END IF

          IF (p_docum.val_saldo <> mr_tela.val_saldo) AND mr_tela.ies_tip_pgto = 'S' THEN
             CALL log0030_mensagem ('Valor para pagamento do saldo não confere ', 'exclamation')
             NEXT FIELD ies_tip_pgto
          END IF

          IF (mr_tela.val_saldo >= p_docum.val_saldo) AND mr_tela.ies_tip_pgto = 'P' THEN
             CALL log0030_mensagem ('Valor do pagamento parte indevido ', 'exclamation')
             NEXT FIELD ies_tip_pgto
          END IF

          IF mr_tela.ies_tip_pgto = 'N' AND p_docum.ies_pgto_docum = 'P' THEN
             CALL log0030_mensagem ('Pagamento total para documento que já possui pagamento parcial', 'exclamation')
             NEXT FIELD ies_tip_pgto
          END IF
          # FIM CONSISTENCIAS DO CAMPO IES_TIP_PGTO #

          # INICIO CONSISTENCIAS DO CAMPO DAT-PGTO #
          IF m_parametro[24,24] = 'S' OR m_parametro[24,24] = 's' THEN
             CALL geo1017_par_con()

             IF  (YEAR (mr_tela.dat_pgto)  = m_ult_num_per_fech
             AND MONTH (mr_tela.dat_pgto) <= m_ult_num_seg_fech)
             OR  YEAR  (mr_tela.dat_pgto)  < m_ult_num_per_fech THEN
                 CALL log0030_mensagem ('Data de pagamento fora dos limites contábeis','exclamation')
                 NEXT FIELD dat_pgto
             END IF
          END IF

          IF mr_tela.dat_pgto IS NOT NULL THEN
             IF mr_tela.dat_pgto < p_docum.dat_emis THEN
                CALL log0030_mensagem ('Data de pagamento anterior a data de emissão','exclamation')
                NEXT FIELD dat_pgto
             END IF

             IF mr_tela.dat_pgto > p_par_cre.dat_proces_bxa THEN
                CALL log0030_mensagem ('Data de pagamento fora dos limites de baixa','exclamation')
                NEXT FIELD dat_pgto
             END IF
          END IF
          # FIM CONSISTENCIAS DO CAMPO DAT-PGTO #

          # INICIO CONSISTENCIAS DO CAMPO DAT_CREDITO#
          IF m_parametro[24,24] = 'S' OR m_parametro[24,24] = 's' THEN
             IF mr_empresa_cre.ies_dat_contabil = 'C' THEN
                IF mr_dados_pagto.portador1 IS NOT NULL AND
                   m_tem_dados THEN
                   FOR l_ind = 1 TO 100
                      IF ma_outros[l_ind].dat_cred IS NOT NULL THEN
                         IF  (YEAR  (ma_outros[l_ind].dat_cred)  = m_ult_num_per_fech
                         AND MONTH  (ma_outros[l_ind].dat_cred) <= m_ult_num_seg_fech)
                         OR  YEAR   (ma_outros[l_ind].dat_cred) < m_ult_num_per_fech THEN
                             LET l_erro = TRUE
                         ELSE
                            LET mr_tela.dat_credito = ma_outros[l_ind].dat_cred
                            LET l_erro = FALSE
                            EXIT FOR
                         END IF
                      END IF
                   END FOR
                   IF l_erro THEN
                       CALL log0030_mensagem ('Data de crédito fora dos limites contábeis','info')
                       NEXT FIELD dat_credito
                   END IF
                ELSE
                   IF  (YEAR  (mr_tela.dat_credito)  = m_ult_num_per_fech
                   AND MONTH  (mr_tela.dat_credito) <= m_ult_num_seg_fech)
                   OR  YEAR   (mr_tela.dat_credito)  < m_ult_num_per_fech THEN
                      CALL log0030_mensagem ('Data de crédito fora dos limites contábeis','info')
                      NEXT FIELD dat_credito
                   END IF
                END IF
             END IF
          END IF

          LET l_erro = FALSE
          IF mr_dados_pagto.portador1 IS NOT NULL AND
             m_tem_dados AND
             l_informou = FALSE THEN
             FOR l_ind = 1 TO 100
                IF ma_outros[l_ind].dat_cred < mr_tela.dat_pgto THEN
                   LET l_erro = TRUE
                ELSE
                   LET l_erro = FALSE
                   EXIT FOR
                END IF
             END FOR
             IF l_erro THEN
                CALL log0030_mensagem ('Data de crédito anterior a data de pagamento','info')
                LET l_informou = TRUE
                NEXT FIELD dat_credito
             END IF
          ELSE
             IF mr_tela.dat_credito < mr_tela.dat_pgto THEN
                CALL log0030_mensagem ('Data de crédito anterior a data de pagamento','info')
                NEXT FIELD dat_credito
             END IF
          END IF
          # FIM CONSISTENCIAS DO CAMPO DAT_CREDITO #

          # INICIO CONSISTENCIAS DO CAMPO val_desc_conc #
          IF mr_tela.val_desc_conc > mr_tela.val_saldo THEN
             CALL log0030_mensagem ('Valor do desconto maior que o valor do título','info')
             NEXT FIELD val_desc_conc
          END IF
          # FIM CONSISTENCIAS DO CAMPO val_desc_conc #

          # INICIO CONSISTENCIAS DO CAMPO IES_FORMA_PGTO #
          IF NOT geo1017_verifica_forma_pgto(mr_tela.ies_forma_pgto) THEN
             CALL log0030_mensagem ('Forma de pagamento não cadastrada na tabela','info')
             NEXT FIELD ies_forma_pgto
          END IF
          # FIM CONSISTENCIAS DO CAMPO IES_FORMA_PGTO #

          IF m_ies_conc_bco_cxa = "S" AND
             (mr_tela.ies_forma_pgto = "BC" OR
              mr_tela.ies_forma_pgto = "CA") THEN
              CALL log0030_mensagem("As formas de pagamento BC e CA não podem ser incluídas manualmente.","excl")
              NEXT FIELD ies_forma_pgto
          END IF

          IF (mr_tela.ies_forma_pgto = "AB" OR
              mr_tela.ies_forma_pgto = "DV") THEN
              ERROR "Esta forma de pagamento só pode ser utilizada através do CRE0700."
              NEXT FIELD ies_forma_pgto
          END IF

          IF mr_tela.val_glosa IS NOT NULL THEN
             IF mr_tela.val_glosa > mr_tela.val_saldo THEN
                CALL log0030_mensagem('Valor de glosa não pode ultrapassar o valor do saldo.','exclamation')
                NEXT FIELD val_glosa
             END IF
             #LET l_soma = (mr_tela.val_glosa + mr_tela.val_saldo) + mr_tela.val_desc_conc
             #IF l_soma >= p_docum.val_saldo THEN
             #ELSE
             #   CALL log0030_mensagem('Valor título + desconto + glosa maior que valor saldo.','exclamation')
             #   NEXT FIELD val_saldo
             #END IF
          END IF
       END IF
  END INPUT

  CALL log006_exibe_teclas('01',p_versao)
  CURRENT WINDOW IS w_geo1017}


  IF INT_FLAG THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION
#--------------------------------#
 FUNCTION geo1017_verifica_desc()
#--------------------------------#

 IF mr_dados_pagto.portador1 IS NULL OR
    mr_dados_pagto.portador1 = ' ' OR
    mr_dados_pagto.dat_lanc IS NULL THEN
    IF p_docum.dat_vencto_c_desc IS NOT NULL THEN
      LET mr_tela.val_desc_conc = 0
      IF m_parametro[198,198] = "S" AND p_docum.ies_pgto_docum = "A" THEN
         LET mr_tela.val_desc_conc   = p_docum.val_liquido   * p_pct_desc / 100
      ELSE
         LET mr_tela.val_desc_conc   = p_docum.val_saldo     * p_pct_desc / 100
      END IF

      #DISPLAY BY NAME mr_tela.val_desc_conc

    END IF
 END IF

 END FUNCTION


#------------------------------------#
 FUNCTION geo1017_consiste_portador()
#------------------------------------#

  WHENEVER ERROR CONTINUE
  SELECT *
    FROM portador
   WHERE cod_portador    = mr_tela.cod_portador
     AND ies_tip_portador= mr_tela.ies_tip_portador
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#----------------------------------------------#
 FUNCTION geo1017_verifica_portador(l_portador,
                                     l_tip_portador)
#----------------------------------------------#
 DEFINE l_portador     LIKE portador.cod_portador,
        l_tip_portador LIKE portador.ies_tip_portador

  WHENEVER ERROR CONTINUE
  SELECT cod_portador
    FROM portador
   WHERE cod_portador    = l_portador
     AND ies_tip_portador= l_tip_portador
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION geo1017_verifica_empresa()
#------------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT cod_empresa
   FROM empresa_cre
  WHERE cod_empresa = mr_docum_aberto.cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION geo1017_busca_dados_doc()
#---------------------------------#

  IF mr_tela.num_docum IS NOT NULL OR mr_tela.num_docum <> ' ' THEN

     IF geo1017_dados_doc() THEN
        IF mr_dados_pagto.portador1 IS NULL OR
           mr_dados_pagto.portador1 = ' ' OR
           mr_dados_pagto.dat_lanc IS NULL THEN
           #DISPLAY BY NAME mr_tela.val_saldo, mr_tela.cod_portador, mr_tela.ies_tip_portador
        END IF
     END IF
  END IF

END FUNCTION
#----------------------------#
 FUNCTION geo1017_dados_doc()
#----------------------------#


    IF mr_dados_pagto.portador1 IS NULL OR
       mr_dados_pagto.portador1 = ' ' OR
       mr_dados_pagto.dat_lanc IS NULL THEN
       WHENEVER ERROR CONTINUE
       SELECT docum.val_saldo,
              docum.cod_portador, docum.ies_tip_portador
         INTO mr_tela.val_saldo, mr_tela.cod_portador,
              mr_tela.ies_tip_portador
         FROM docum
        WHERE docum.cod_empresa   = mr_tela.cod_empresa
          AND docum.num_docum     = mr_tela.num_docum
          AND docum.ies_tip_docum = mr_tela.ies_tip_docum
       WHENEVER ERROR STOP

       IF sqlca.sqlcode<> 0 THEN
          RETURN FALSE
       END IF
    END IF

    RETURN TRUE

END FUNCTION

#--------------------------------------#
 FUNCTION geo1017_busca_dat_proces()
#--------------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT *
    INTO p_par_cre.*
    FROM par_cre
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('SELECT','P_PAR_CRE')
  END IF

  IF mr_dados_pagto.portador1 IS NOT NULL AND
     mr_dados_pagto.portador1 <> ' ' AND
     mr_dados_pagto.dat_lanc IS NOT NULL THEN
     LET m_dat_lancamento = mr_dados_pagto.dat_lanc
  ELSE
     LET m_dat_lancamento    = p_par_cre.dat_proces_doc
  END IF

  IF mr_tela.dat_pgto IS NULL THEN
     LET mr_tela.dat_pgto    = p_par_cre.dat_proces_bxa
  END IF

  IF mr_tela.dat_credito IS NULL THEN
     LET mr_tela.dat_credito = p_par_cre.dat_proces_bxa
  END IF


END FUNCTION

#------------------------------------#
 FUNCTION geo1017_ativa_zoom(l_ativa)
#------------------------------------#

   DEFINE l_ativa           SMALLINT,
          l_ies_manut       CHAR(01)
{

   IF l_ativa THEN
      IF g_ies_grafico THEN
         #Ativação do botão de zoom no ambiente gráfico
         --# #CALL fgl_dialog_setkeylabel('control-z','Zoom')
      ELSE
         #Apresentação fixa no canto superior direito da tela
         #DISPLAY '( Zoom )' AT 3,65
      END IF
   ELSE
      IF g_ies_grafico THEN
         #Desativação do botão de zoom no ambiente gráfico
         --# CALL fgl_dialog_setkeylabel('control-z',NULL)
      ELSE
         #Retirar texto fixo de zoom no canto superior direito da tela
         DISPLAY '--------' AT 3,65
      END IF
   END IF
}
END FUNCTION
#--------------------------------#
 FUNCTION geo1017_busca_tip_pgto()
#--------------------------------#
 DEFINE l_ies_pgto_docum   CHAR(01)

 WHENEVER ERROR CONTINUE
 SELECT ies_pgto_docum
   INTO l_ies_pgto_docum
   FROM docum
  WHERE cod_empresa    = mr_tela.cod_empresa
    AND num_docum      = mr_tela.num_docum
    AND ies_tip_docum  = mr_tela.ies_tip_docum
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('SELECT','DOCUM')
    LET l_ies_pgto_docum = ' '
 END IF

 CASE l_ies_pgto_docum
   WHEN 'A'
      LET mr_tela.ies_tip_pgto = 'N'

   WHEN 'P'
      LET mr_tela.ies_tip_pgto = 'S'

   OTHERWISE
      LET mr_tela.ies_tip_pgto = NULL

 END CASE

END FUNCTION


#--------------------------------------#
 FUNCTION geo1017_busca_docum_aberto()
#--------------------------------------#
  DEFINE l_sql_stmt CHAR(500)


  LET m_tem_dados = TRUE
  LET l_sql_stmt =
  'SELECT empresa,   ',
  '       docum,     ',
  '       tip_docum, ',
  '       dat_pgto,  ',
  '       val_saldo, ',
  '       val_desc,  ',
  '       val_juros   ',
  '   FROM wmarcados ',
  '  WHERE marcado = "X" ',
  '  ORDER BY marcado,empresa,docum '

  WHENEVER ERROR CONTINUE
  PREPARE var_query2  FROM l_sql_stmt
  IF sqlca.sqlcode = 0 THEN
  ELSE
     CALL log003_err_sql('PREPARE','WMARCADOS')
  END IF

  DECLARE cq_dados_abertos SCROLL CURSOR WITH HOLD FOR var_query2
  IF sqlca.sqlcode = 0 THEN
  ELSE
     CALL log003_err_sql('DECLARE','CQ_DADOS_ABERTOS')
  END IF

  OPEN cq_dados_abertos
  IF sqlca.sqlcode = 0 THEN
  ELSE
     CALL log003_err_sql('OPEN','CQ_DADOS_ABERTOS')
  END IF
  FETCH cq_dados_abertos INTO mr_tela.cod_empresa,
                              mr_tela.num_docum,
                              mr_tela.ies_tip_docum,
                              mr_tela.dat_pgto,
                              mr_tela.val_saldo,
                              mr_tela.val_desc_conc,
                              mr_tela.val_juro_pago

   WHENEVER ERROR STOP
  IF sqlca.sqlcode < 0 THEN
     CALL log003_err_sql('FETCH','CQ_DADOS_ABERTOS')
  END IF

  IF sqlca.sqlcode = 100 THEN
     CALL log0030_mensagem ("Não foram encontrados documentos em aberto. ","exclamation")
  END IF

END FUNCTION

#-----------------------#
 FUNCTION geo1017_zoom()
#-----------------------#
{
CASE

   WHEN INFIELD (cod_empresa)
        CALL cre307_popup_empresa()    RETURNING mr_tela.cod_empresa
        CURRENT WINDOW IS w_geo1017
        DISPLAY BY NAME mr_tela.cod_empresa

   WHEN INFIELD (ies_tip_docum)
        CALL cre304_popup_tip_docum()  RETURNING mr_tela.ies_tip_docum
        CURRENT WINDOW IS w_geo1017
        DISPLAY BY NAME mr_tela.ies_tip_docum

   WHEN INFIELD (ies_forma_pgto)
        CALL cre328_popup_forma_pgto() RETURNING mr_tela.ies_forma_pgto
        CURRENT WINDOW IS w_geo1017
        DISPLAY BY NAME mr_tela.ies_forma_pgto

   WHEN INFIELD (cod_portador)
        CALL cre305_popup_portador() RETURNING mr_tela.cod_portador,
                                               mr_tela.ies_tip_portador
        CURRENT WINDOW IS w_geo1017
        DISPLAY BY NAME mr_tela.cod_portador, mr_tela.ies_tip_portador

 END CASE
}
END FUNCTION

#---------------------------#
 FUNCTION geo1017_zoom_2()
#---------------------------#

DEFINE l_forma_pgto   LIKE forma_pgto.cod_forma_pgto,
       l_portador     LIKE docum.cod_portador,
       l_tip_portador LIKE docum.ies_tip_portador,
       l_cliente      LIKE clientes.cod_cliente,
       l_cont         SMALLINT
{
 CASE

    WHEN INFIELD(cod_empresa)
       LET mr_docum_aberto.cod_empresa = cre307_popup_empresa()
       CALL log006_exibe_teclas("01 02 03 07", p_versao)
       CURRENT WINDOW IS w_cre03602

       IF mr_docum_aberto.cod_empresa IS NOT NULL THEN
          DISPLAY BY NAME mr_docum_aberto.cod_empresa
       END IF


    WHEN INFIELD (ies_tip_docum)
       CALL cre304_popup_tip_docum()  RETURNING mr_docum_aberto.ies_tip_docum
       CURRENT WINDOW IS w_cre03602
       DISPLAY BY NAME mr_docum_aberto.ies_tip_docum

    WHEN infield(cod_cliente)
      IF cre027_gerencia_entrada_dados(7, 40,p_user,p_nom_programa, "CLIENTES") = TRUE THEN
         WHENEVER ERROR CONTINUE
           SELECT COUNT(*)
             INTO l_cont
             FROM cre0270_clientes
            WHERE cre0270_clientes.nom_usuario   = p_user
              AND cre0270_clientes.cod_programa  = p_nom_programa
         WHENEVER ERROR STOP
         IF l_cont = 1 THEN
            SELECT cod_cliente
              INTO mr_docum_aberto.cod_cliente
              FROM cre0270_clientes
             WHERE cre0270_clientes.nom_usuario   = p_user
               AND cre0270_clientes.cod_programa  = p_nom_programa
         ELSE
            LET mr_docum_aberto.cod_cliente = ' '
         END IF
         DISPLAY BY NAME mr_docum_aberto.cod_cliente
      END IF
      CURRENT WINDOW IS w_cre03602

    WHEN infield(forma_pgto)
        LET l_forma_pgto = cre328_popup_forma_pgto()
        IF l_forma_pgto IS NOT NULL THEN
           CURRENT WINDOW IS w_cre03602
           LET mr_dados_pagto.forma_pgto = l_forma_pgto
           DISPLAY BY NAME mr_dados_pagto.forma_pgto
        END IF

    WHEN infield(cod_portador)
        CALL cre305_popup_portador() RETURNING l_portador,
                                               l_tip_portador
        CALL log006_exibe_teclas("01 07 02 03",p_versao)
        CURRENT WINDOW IS w_cre03602
        IF l_portador IS NOT NULL THEN
           LET mr_docum_aberto.cod_portador = l_portador
           LET mr_docum_aberto.ies_tip_portador = l_tip_portador
           DISPLAY BY NAME mr_docum_aberto.cod_portador
           DISPLAY BY NAME mr_docum_aberto.ies_tip_portador
        END IF

    WHEN infield(ies_tip_portador)
         LET mr_docum_aberto.ies_tip_portador = log0830_list_box(09,45,
 {        CURRENT WINDOW IS w_cre03602
         DISPLAY BY NAME mr_docum_aberto.ies_tip_portador

     WHEN infield(portador1)
        CALL cre305_popup_portador() RETURNING l_portador,
                                               l_tip_portador
        CALL log006_exibe_teclas("01 07 02 03",p_versao)
        CURRENT WINDOW IS w_cre03602
        IF l_portador IS NOT NULL THEN
           LET mr_dados_pagto.portador1 = l_portador
           LET mr_dados_pagto.tip_portador1 = l_tip_portador
           DISPLAY BY NAME mr_dados_pagto.portador1
           DISPLAY BY NAME mr_dados_pagto.tip_portador1
        END IF

   WHEN infield(tip_portador1)
        LET mr_dados_pagto.tip_portador1 = log0830_list_box(09,45,
        
        CURRENT WINDOW IS w_cre03602
        DISPLAY BY NAME mr_dados_pagto.tip_portador1

   WHEN infield(cod_tip_cli)
      CALL log009_popup(6             ,
                        25            ,
                        "TIPO CLIENTE",
                        "tipo_cliente",
                        "cod_tip_cli" ,
                        "den_tip_cli" ,
                        "vdp3370"     ,
                        "N"           ,
                        ""            ) RETURNING m_cod_tip_cli

      CALL log006_exibe_teclas("01 02 03 07", p_versao)
      CURRENT WINDOW IS w_cre03602

      IF m_cod_tip_cli  IS NOT NULL  THEN
         LET mr_docum_aberto.cod_tip_cli = m_cod_tip_cli
         DISPLAY BY NAME mr_docum_aberto.cod_tip_cli
         CALL geo1017_verifica_cod_tip_cli() RETURNING p_status
      END IF

 END CASE
}
END FUNCTION

#---------------------------------------#
 FUNCTION geo1017_busca_val_saldo_docum()
#---------------------------------------#
  DEFINE l_dat_atraso            DECIMAL(2,0),
         l_dat_atraso_cnd        DECIMAL(3,0),
         l_clientes_cre_txt      RECORD LIKE clientes_cre_txt.*,
         l_cond_pgto_cre_txt     RECORD LIKE cond_pgto_cre_txt.*


  INITIALIZE l_dat_atraso, l_dat_atraso_cnd, p_docum    TO NULL
  INITIALIZE l_clientes_cre_txt.*, l_cond_pgto_cre_txt.* TO NULL


  IF m_esta_na_consulta THEN
     CALL geo1017_carrega_p_docum(ma_principal[m_ind].empresa,
                                   ma_principal[m_ind].docum,
                                   ma_principal[m_ind].tip_docum)
  ELSE
     CALL geo1017_carrega_p_docum(mr_tela.cod_empresa,
                                   mr_tela.num_docum,
                                   mr_tela.ies_tip_docum)
  END IF
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  ELSE
     IF mr_dados_pagto.portador1 IS NULL OR
        mr_dados_pagto.portador1 = ' ' OR
        mr_dados_pagto.dat_lanc IS NULL THEN
        LET  mr_tela.val_saldo = p_docum.val_saldo
        #DISPLAY BY NAME mr_tela.val_saldo
     END IF

     IF p_docum.dat_prorrogada IS NULL THEN
        LET m_dat_vencto = p_docum.dat_vencto_s_desc
     ELSE
        LET m_dat_vencto = p_docum.dat_prorrogada
     END IF


     LET m_pct_desc       = p_docum.pct_desc

     IF m_parametro[102,102] = '2' THEN


        IF m_esta_na_consulta THEN
           WHENEVER ERROR CONTINUE
           SELECT parametro[1,6]
             INTO m_pct_desc
             FROM docum_txt
            WHERE cod_empresa   = ma_principal[m_ind].empresa
              AND num_docum     = ma_principal[m_ind].docum
              AND ies_tip_docum = ma_principal[m_ind].tip_docum
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
           ELSE
              LET m_pct_desc = 0
           END IF
        ELSE
           WHENEVER ERROR CONTINUE
           SELECT parametro[1,6]
             INTO m_pct_desc
             FROM docum_txt
            WHERE cod_empresa   = mr_tela.cod_empresa
              AND num_docum     = mr_tela.num_docum
              AND ies_tip_docum = mr_tela.ies_tip_docum
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
           ELSE
              LET m_pct_desc = 0
           END IF
        END IF
     END IF
        INITIALIZE l_clientes_cre_txt TO NULL

        WHENEVER ERROR CONTINUE
        SELECT *
          INTO l_clientes_cre_txt.*
          FROM clientes_cre_txt
         WHERE clientes_cre_txt.cod_cliente = p_docum.cod_cliente
        WHENEVER ERROR STOP

         IF   l_clientes_cre_txt.parametro[1,2] IS NOT NULL  AND  l_clientes_cre_txt.parametro[1,2] > 0
         AND  sqlca.sqlcode = 0 THEN
              LET l_dat_atraso = l_clientes_cre_txt.parametro[1,2]

              IF p_docum.dat_prorrogada IS NOT NULL THEN
                 LET p_docum.dat_prorrogada    = p_docum.dat_prorrogada    + l_dat_atraso UNITS DAY
              ELSE
                 LET p_docum.dat_vencto_s_desc = p_docum.dat_vencto_s_desc + l_dat_atraso UNITS DAY
              END IF
         ELSE
              INITIALIZE l_cond_pgto_cre_txt TO NULL

              WHENEVER ERROR CONTINUE
              SELECT *
                INTO l_cond_pgto_cre_txt.*
                FROM cond_pgto_cre_txt
               WHERE cond_pgto_cre_txt.cod_cnd_pgto = p_docum.cod_cnd_pgto
              WHENEVER ERROR STOP

              IF   l_cond_pgto_cre_txt.parametros[2,4] IS NOT NULL  AND  l_cond_pgto_cre_txt.parametros[2,4] > 0
              AND  sqlca.sqlcode = 0 THEN
                   LET l_dat_atraso_cnd = l_cond_pgto_cre_txt.parametros[2,4]

                   IF p_docum.dat_prorrogada IS NOT NULL THEN
                      LET p_docum.dat_prorrogada  = p_docum.dat_prorrogada        + l_dat_atraso_cnd UNITS DAY
                   ELSE
                      LET p_docum.dat_vencto_s_desc = p_docum.dat_vencto_s_desc   + l_dat_atraso_cnd UNITS DAY
                   END IF
              END IF
         END IF

         LET p_pct_desc  = p_docum.pct_desc

         IF m_parametro[102,102] = "2" THEN

           IF m_esta_na_consulta THEN
              WHENEVER ERROR CONTINUE
              SELECT parametro[1,6]
                INTO p_pct_desc
                FROM docum_txt
               WHERE cod_empresa   = ma_principal[m_ind].empresa
                 AND num_docum     = ma_principal[m_ind].docum
                 AND ies_tip_docum = ma_principal[m_ind].tip_docum
              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 0 THEN
              ELSE
                 LET p_pct_desc = 0
              END IF
           ELSE
              WHENEVER ERROR CONTINUE
              SELECT parametro[1,6]
                INTO p_pct_desc
                FROM docum_txt
               WHERE cod_empresa   = mr_tela.cod_empresa
                 AND num_docum     = mr_tela.num_docum
                 AND ies_tip_docum = mr_tela.ies_tip_docum
              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 0 THEN
              ELSE
                 LET p_pct_desc = 0
              END IF
           END IF
         END IF

         RETURN TRUE
  END IF

END FUNCTION

#---------------------------------#
FUNCTION geo1017_carrega_p_docum(l_empresa,
                                  l_docum,
                                  l_ies_tip_docum)
#---------------------------------#
  DEFINE l_empresa             CHAR(02),
         l_docum               CHAR(14),
         l_ies_tip_docum       CHAR(02)

  DEFINE l_val_saldo_cliente   LIKE cre_tit_cob_esp.val_parcela_cliente,
         l_status              SMALLINT

  WHENEVER ERROR CONTINUE
    SELECT docum.*
      INTO p_docum.*
      FROM docum
     WHERE docum.cod_empresa   = l_empresa
       AND docum.num_docum     = l_docum
       AND docum.ies_tip_docum = l_ies_tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     INITIALIZE p_docum.* TO NULL
  END IF

  IF p_docum.ies_tip_cobr = "V" AND p_docum.cod_portador > 0 THEN
     CALL geo1017_busca_cre_tit_cob_esp(l_empresa      ,
                                         l_docum        ,
                                         l_ies_tip_docum,
                                         p_docum.ies_tip_cobr)
     RETURNING l_val_saldo_cliente
  ELSE
     LET l_val_saldo_cliente = 0
  END IF

  IF l_val_saldo_cliente > 0 THEN
     LET p_docum.val_saldo = l_val_saldo_cliente
  END IF

  CALL geo1017_verifica_docum_equalizacao(l_empresa      ,
                                           l_docum        ,
                                           l_ies_tip_docum,
                                           p_docum.val_saldo,
                                           TRUE)
       RETURNING p_docum.val_saldo, l_status

  IF l_status = FALSE THEN
     INITIALIZE p_docum.* TO NULL
     LET sqlca.sqlcode = 100
  END IF

END FUNCTION

#------------------------------------#
FUNCTION geo1017_gerencia_calc_juro(l_cod_empresa,
                                     l_data_pgto,
                                     l_val_juro_pago,
                                     l_val_desc_conc)
#------------------------------------#
DEFINE l_ies_prorr          SMALLINT ,
       l_salva_dat_pgto     DATE,
       l_cod_empresa        CHAR(02),
       l_data_pgto          DATE,
       l_val_juro_pago      DECIMAL(15,2),
       l_val_desc_conc      DECIMAL(15,2)
   LET m_qtd_dias_difer  = 0


   LET p_val_juro_a_pag  = 0

   LET l_ies_prorr       = FALSE

   WHENEVER ERROR CONTINUE
   SELECT ies_ctr_dat_prorr, ies_dat_contabil
     INTO m_ies_ctr_dat_prorr, mr_empresa_cre.ies_dat_contabil
     FROM empresa_cre
    WHERE cod_empresa = l_cod_empresa
   WHENEVER ERROR CONTINUE
   IF sqlca.sqlcode = 0 THEN
   ELSE
      LET m_ies_ctr_dat_prorr = ' '
      LET mr_empresa_cre.ies_dat_contabil = ' '
   END IF

   IF m_ies_ctr_dat_prorr = 'S' AND p_docum.dat_prorrogada IS NOT NULL THEN
      LET l_ies_prorr     = TRUE
   ELSE
      LET m_dat_aux       = p_docum.dat_vencto_s_desc
   END IF


   IF l_ies_prorr THEN

      IF p_docum.ies_cobr_juros = 'S' THEN

         WHENEVER ERROR CONTINUE
         SELECT cond_pgto_cre.des_abrev_cnd_pgto
           INTO m_des_cnd_pgto
           FROM cond_pgto_cre
          WHERE cond_pgto_cre.cod_cnd_pgto = p_docum.cod_cnd_pgto
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            LET m_des_cnd_pgto = 'NORMAL'
         END IF

         LET m_dat_aux = p_docum.dat_vencto_s_desc

         IF l_data_pgto > m_dat_aux THEN
            CALL geo1017_calcula_qtd_dias_difer(l_data_pgto)
         ELSE
            LET m_qtd_dias_difer = 0
         END IF

         IF m_qtd_dias_difer > 0 THEN
            CALL geo1017_calcula_juro(l_data_pgto,
                                       l_val_desc_conc)
         ELSE
            LET p_val_juro_a_pag = 0
         END IF

      ELSE

         LET m_dat_aux = p_docum.dat_prorrogada

         IF l_data_pgto > m_dat_aux THEN
            CALL geo1017_calcula_qtd_dias_difer(l_data_pgto)
         ELSE
            LET m_qtd_dias_difer = 0
         END IF

         IF m_qtd_dias_difer > 0 THEN
            CALL geo1017_calcula_juro_1(l_cod_empresa,
                                         l_data_pgto,
                                         l_val_juro_pago,
                                         l_val_desc_conc)
         END IF

         LET l_val_juro_pago  = p_val_juro_a_pag

     END IF

   ELSE
      IF l_data_pgto > m_dat_aux THEN
         CALL geo1017_calcula_qtd_dias_difer(l_data_pgto)
      ELSE
         LET m_qtd_dias_difer = 0
      END IF

      IF m_qtd_dias_difer > 0 THEN
         CALL geo1017_calcula_juro(l_data_pgto,
                                    l_val_desc_conc)
      END IF

   END IF
   CALL geo1017_calcula_multa()

END FUNCTION

#----------------------------------------#
 FUNCTION geo1017_calcula_qtd_dias_difer(l_data_pgto)
#----------------------------------------#

   DEFINE l_qtd_dias_fim       DECIMAL (5,0),
          l_cod_cidade         LIKE cidades.cod_cidade,
          l_qtd_dias_reserva   DECIMAL (5,0),
          l_qtd_dias_cidade    DECIMAL (5,0),
          l_data_pgto          DATE

   LET l_qtd_dias_fim     = 0
   LET l_qtd_dias_cidade  = 0
   LET l_qtd_dias_reserva = 0

   INITIALIZE l_cod_cidade TO NULL

   WHENEVER ERROR CONTINUE
   SELECT cod_cidade
     INTO l_cod_cidade
     FROM clientes
    WHERE cod_cliente = p_docum.cod_cliente
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
   ELSE
      LET l_cod_cidade = ' '
   END IF

   INITIALIZE l_qtd_dias_fim TO NULL

   WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_qtd_dias_fim
     FROM calendario
    WHERE calendario.dat_calend        >= m_dat_aux
      AND calendario.dat_calend        <  l_data_pgto
      AND calendario.ies_dia_util_banc =  'S'
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 OR l_qtd_dias_fim = 0 OR l_qtd_dias_fim IS NULL THEN

      WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_qtd_dias_fim
        FROM calendario_cidades
       WHERE calendario_cidades.dat_calend  >= m_dat_aux
         AND calendario_cidades.dat_calend  <  l_data_pgto
         AND calendario_cidades.cod_cidade  =  l_cod_cidade
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 OR l_qtd_dias_fim = 0 OR l_qtd_dias_fim IS NULL THEN
         LET l_qtd_dias_fim = 0
      END IF

      LET l_qtd_dias_reserva = l_data_pgto - m_dat_aux

      IF l_qtd_dias_reserva  = l_qtd_dias_fim THEN
         LET m_qtd_dias_difer = 0
      ELSE
         LET m_qtd_dias_difer = l_qtd_dias_reserva
        END IF
   ELSE
      WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
          INTO l_qtd_dias_cidade
          FROM calendario_cidades
         WHERE calendario_cidades.dat_calend >= m_dat_aux
           AND calendario_cidades.dat_calend < l_data_pgto
           AND calendario_cidades.cod_cidade = l_cod_cidade
      WHENEVER ERROR STOP

      IF sqlca.sqlcode = 0 OR l_qtd_dias_cidade <> 0 OR l_qtd_dias_cidade IS NOT NULL THEN
         LET l_qtd_dias_fim = l_qtd_dias_fim + l_qtd_dias_cidade
      END IF

      LET l_qtd_dias_reserva = l_data_pgto - m_dat_aux

      IF l_qtd_dias_reserva = l_qtd_dias_fim THEN
         LET m_qtd_dias_difer = 0
      ELSE
         LET m_qtd_dias_difer = l_qtd_dias_reserva
        END IF
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION geo1017_calcula_juro(l_data_pgto,
                                l_val_desc_conc)
#-------------------------------#

 DEFINE l_num_cgc_cpf      CHAR(019),
        l_ies_tip_cliente  CHAR(001),
        l_orig_juros       CHAR(001),
        l_tip_variacao     CHAR(001),
        l_cod_variacao     CHAR(002),
        l_param            CHAR(400),
        l_pct_var          DECIMAL(03,2),
        l_pct_ini          DECIMAL(03,2),
        l_pct_final        DECIMAL(03,2),
        l_pct_juro         DECIMAL(05,2),
        l_pct_juro1        DECIMAL(07,2),
        l_val_documento    DECIMAL(15,2),
        l_data_pgto        DATE,
        l_val_desc_conc    DECIMAL(15,2)

   INITIALIZE l_num_cgc_cpf, l_ies_tip_cliente, l_param TO NULL

   WHENEVER ERROR CONTINUE
   SELECT num_cgc_cpf
     INTO l_num_cgc_cpf
     FROM clientes
    WHERE clientes.cod_cliente = p_docum.cod_cliente
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
   ELSE
      LET l_num_cgc_cpf = ' '
   END IF

   IF l_num_cgc_cpf[13,16] = '0000' THEN
      LET l_ies_tip_cliente = 'F'
   ELSE
      LET l_ies_tip_cliente = 'J'
   END IF

   WHENEVER ERROR CONTINUE
   SELECT parametros
    INTO l_param
     FROM empresa_cre_txt
    WHERE cod_empresa = p_docum.cod_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
   ELSE
      LET l_param = ' '
   END IF
   IF l_ies_tip_cliente = 'F' THEN
      LET l_orig_juros   = l_param[359,359]
      LET l_pct_juro1    = l_param[360,366]
      LET l_tip_variacao = l_param[367,367]
      LET l_cod_variacao = l_param[368,369]
   ELSE
      LET l_orig_juros   = l_param[371,371]
      LET l_pct_juro1    = l_param[372,378]
      LET l_tip_variacao = l_param[379,379]
      LET l_cod_variacao = l_param[380,381]
   END IF

   IF l_orig_juros IS NULL  OR l_orig_juros = ' ' THEN
      LET l_orig_juros = '1'
   END IF

   LET l_pct_juro = l_pct_juro1 / 100

   LET l_pct_var   = 0
   LET l_pct_ini   = 0
   LET l_pct_final = 0

   IF l_tip_variacao  = '2' THEN

      WHENEVER ERROR CONTINUE
      SELECT val_cotacao
        INTO l_pct_ini
        FROM cotacao
       WHERE cotacao.cod_moeda  = l_cod_variacao
         AND cotacao.dat_ref    = p_docum.dat_vencto_s_desc
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         LET l_pct_ini = 1
      END IF

      WHENEVER ERROR CONTINUE
      SELECT val_cotacao
        INTO l_pct_final
        FROM cotacao
       WHERE cotacao.cod_moeda = l_cod_variacao
         AND cotacao.dat_ref   = l_data_pgto
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         LET l_pct_final = 1
      END IF

      LET l_pct_var = (l_pct_final / l_pct_ini) - 1
   END IF

   IF l_pct_var < 0 THEN
      LET l_pct_var = 0
   END IF

   IF m_ies_tip_cobr_juro = 'S' THEN
      IF p_ies_cotacao = 'CR$' THEN

         LET l_val_documento = p_docum.val_saldo - l_val_desc_conc

         IF l_tip_variacao = '2' THEN
            LET l_val_documento = l_val_documento + (l_val_documento * l_pct_var)
         END IF

         IF l_orig_juros = '1' THEN
            LET p_val_juro_a_pag = (p_docum.pct_juro_mora / 3000) * (l_val_documento * m_qtd_dias_difer )
         ELSE
            LET p_val_juro_a_pag = (l_pct_juro / 3000) *  (l_val_documento * m_qtd_dias_difer )
         END IF

      ELSE
         LET p_val_juro_a_pag = (p_docum.pct_juro_mora / 3000) *
                              ((m_val_saldo_urv / m_val_cotacao) - (l_val_desc_conc / m_val_cotacao) ) * m_qtd_dias_difer
        LET p_val_juro_a_pag = p_val_juro_a_pag * m_val_cotacao
      END IF

   END IF

 END FUNCTION

 #--------------------------------#
 FUNCTION geo1017_calcula_juro_1(l_cod_empresa,
                                  l_data_pgto,
                                  l_val_juro_pago,
                                  l_val_desc_conc)
#--------------------------------#
 DEFINE l_num_cgc_cpf      CHAR(019),
        l_ies_tip_cliente  CHAR(001),
        l_orig_juros       CHAR(001),
        l_tip_variacao     CHAR(001),
        l_cod_variacao     CHAR(002),
        l_param            CHAR(400),
        l_pct_var          DECIMAL(03,2),
        l_pct_ini          DECIMAL(03,2),
        l_pct_final        DECIMAL(03,2),
        l_pct_juro         DECIMAL(05,2),
        l_pct_juro1        DECIMAL(07,2),
        l_val_documento    DECIMAL(15,2),
        l_cod_empresa      CHAR(02),
        l_data_pgto        DATE,
        l_val_juro_pago    DECIMAL(15,2),
        l_val_desc_conc    DECIMAL(15,2)

 INITIALIZE l_num_cgc_cpf, l_ies_tip_cliente, l_param TO NULL

 WHENEVER ERROR CONTINUE
 SELECT num_cgc_cpf
   INTO l_num_cgc_cpf
   FROM clientes
  WHERE clientes.cod_cliente = p_docum.cod_cliente
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
 ELSE
    LET l_num_cgc_cpf = ' '
 END IF

 IF l_num_cgc_cpf[13,16] = '0000' THEN
    LET l_ies_tip_cliente = 'F'
 ELSE
    LET l_ies_tip_cliente = 'J'
 END IF

 WHENEVER ERROR CONTINUE
 SELECT parametros INTO l_param
   FROM empresa_cre_txt
  WHERE cod_empresa = l_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
 ELSE
    LET l_param = ' '
 END IF

 IF l_ies_tip_cliente = 'F' THEN
    LET l_orig_juros   = l_param[359,359]
    LET l_pct_juro1    = l_param[360,366]
    LET l_tip_variacao = l_param[367,367]
    LET l_cod_variacao = l_param[368,369]
 ELSE
    LET l_orig_juros   = l_param[371,371]
    LET l_pct_juro1    = l_param[372,378]
    LET l_tip_variacao = l_param[379,379]
    LET l_cod_variacao = l_param[380,381]
 END IF

 LET l_pct_juro = l_pct_juro1 / 100

 LET l_pct_var = 0
 LET l_pct_ini = 0
 LET l_pct_final = 0

 IF l_tip_variacao  = '2' THEN

    WHENEVER ERROR CONTINUE
    SELECT val_cotacao
      INTO l_pct_ini
      FROM cotacao
     WHERE cotacao.cod_moeda = l_cod_variacao
       AND cotacao.dat_ref   = p_docum.dat_vencto_s_desc
    WHENEVER ERROR CONTINUE

    IF sqlca.sqlcode <> 0 THEN
       LET l_pct_ini = 1
    END IF

    WHENEVER ERROR CONTINUE
    SELECT val_cotacao
      INTO l_pct_final
      FROM cotacao
     WHERE cotacao.cod_moeda = l_cod_variacao
       AND cotacao.dat_ref   = l_data_pgto
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       LET l_pct_final = 1
    END IF

    LET l_pct_var = (l_pct_final / l_pct_ini) - 1

 END IF

   IF l_pct_var < 0 THEN
      LET l_pct_var = 0
   END IF

   IF m_ies_tip_cobr_juro = 'S' THEN
      IF p_ies_cotacao = 'CR$' THEN
         LET l_val_documento = p_docum.val_saldo + l_val_juro_pago  -  l_val_desc_conc

         IF l_tip_variacao = '2' THEN
            LET l_val_documento = l_val_documento + (l_val_documento * l_pct_var)
         END IF

         IF l_orig_juros = '1' THEN
            LET p_val_juro_a_pag = (p_docum.pct_juro_mora / 3000) * (l_val_documento * m_qtd_dias_difer )
         ELSE
            LET p_val_juro_a_pag = (l_pct_juro / 3000) * (l_val_documento * m_qtd_dias_difer )
         END IF

      ELSE
         LET p_val_juro_a_pag = (p_docum.pct_juro_mora / 3000) *   (((m_val_saldo_urv / m_val_cotacao)
                           +  l_val_juro_pago / m_val_cotacao)
                           - (l_val_desc_conc / m_val_cotacao) ) *  m_qtd_dias_difer
         LET p_val_juro_a_pag = p_val_juro_a_pag * m_val_cotacao
      END IF
   END IF

 END FUNCTION

#--------------------------------#
 FUNCTION geo1017_calcula_multa()
#--------------------------------#

 DEFINE l_num_cgc_cpf      CHAR(019),
        l_ies_tip_cliente  CHAR(001),
        l_orig_multa       CHAR(001),
        l_tip_multa        CHAR(001),
        l_tip_variacao     CHAR(001),
        l_cod_variacao     CHAR(002),
        l_param            CHAR(400),
        l_taxa_multa       DECIMAL(05,2),
        l_val_documento    DECIMAL(15,2)

 DEFINE l_multa    RECORD LIKE multa_cli_atraso.*

 INITIALIZE l_num_cgc_cpf, l_ies_tip_cliente, l_param TO NULL

 WHENEVER ERROR CONTINUE
 SELECT num_cgc_cpf
   INTO l_num_cgc_cpf
   FROM clientes
  WHERE clientes.cod_cliente = p_docum.cod_cliente
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
 ELSE
    LET l_num_cgc_cpf = ' '
 END IF

 IF l_num_cgc_cpf[13,16] = '0000' THEN
    LET l_ies_tip_cliente = 'F'
 ELSE
    LET l_ies_tip_cliente = 'J'
 END IF

 WHENEVER ERROR CONTINUE
 SELECT parametros
   INTO l_param
   FROM empresa_cre_txt
  WHERE cod_empresa = p_docum.cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
 ELSE
    LET l_param = ' '
 END IF

 IF l_ies_tip_cliente = 'F' THEN
    LET l_orig_multa   = l_param[359,359]
    LET l_tip_variacao = l_param[367,367]
    LET l_cod_variacao = l_param[368,369]
    LET l_tip_multa    = l_param[370,370]
 ELSE
    LET l_orig_multa   = l_param[371,371]
    LET l_tip_variacao = l_param[379,379]
    LET l_cod_variacao = l_param[380,381]
    LET l_tip_multa    = l_param[382,382]
 END IF

 LET p_val_multa_a_pag = 0

 IF l_tip_multa = '1' THEN
    LET l_val_documento = p_docum.val_saldo
 ELSE
    LET l_val_documento = p_docum.val_saldo + p_val_juro_a_pag
 END IF

 INITIALIZE l_multa TO NULL

 LET l_taxa_multa = 0

 WHENEVER ERROR CONTINUE
 SELECT multa_cli_atraso.*
   INTO l_multa.*
   FROM multa_cli_atraso
  WHERE multa_cli_atraso.cod_empresa     = p_docum.cod_empresa
    AND multa_cli_atraso.ies_tip_cliente = l_ies_tip_cliente
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
 ELSE
    INITIALIZE l_multa.* TO NULL
 END IF

    IF m_qtd_dias_difer >= l_multa.dias_atraso_ini AND m_qtd_dias_difer <= l_multa.dias_atraso_final THEN
       LET l_taxa_multa  = l_multa.taxa_multa
    END IF

 LET p_val_multa_a_pag = l_val_documento * l_taxa_multa / 100

 END FUNCTION

#----------------------------------#
 FUNCTION geo1017_seleciona_docum()
#----------------------------------#
  DEFINE l_ies_situa_docum     CHAR(01),
         l_ies_pgto_docum      CHAR(01),
         l_ies_tip_cobr        CHAR(01){,
         l_desabilita_contrato SMALLINT}

  WHENEVER ERROR CONTINUE
  SELECT ies_situa_docum, ies_pgto_docum, ies_tip_cobr
    INTO l_ies_situa_docum, l_ies_pgto_docum, l_ies_tip_cobr
    FROM docum
   WHERE cod_empresa    = mr_tela.cod_empresa
     AND ies_tip_docum  = mr_tela.ies_tip_docum
     AND num_docum      = mr_tela.num_docum
  WHENEVER ERROR STOP

  IF sqlca.sqlcode = 100 THEN
     CALL log0030_mensagem('Documento não cadastrado. ','info')
     RETURN FALSE
  ELSE
     IF l_ies_situa_docum = 'C' THEN
        CALL log0030_mensagem('Documento cancelado.','info')
        RETURN FALSE
     END IF

     IF l_ies_pgto_docum  = 'T' THEN
        CALL log0030_mensagem('Documento sem saldo para pagamento.','info')
        RETURN FALSE
     END IF
  END IF

  {LET l_desabilita_contrato = FALSE

  IF l_ies_tip_cobr = "V" THEN
     CALL geo1017_consiste_vendor(mr_tela.cod_empresa,
                                   mr_tela.num_docum,
                                   mr_tela.ies_tip_docum,
                                   l_ies_tip_cobr,
                                   "INCLUSAO")
       RETURNING m_status, l_desabilita_contrato

     IF NOT m_status THEN
        RETURN FALSE
     END IF

     IF l_desabilita_contrato THEN
        WHENEVER ERROR CONTINUE
        INSERT INTO t_docum_desabilitar VALUES (mr_tela.cod_empresa   ,
                                                mr_tela.num_docum     ,
                                                mr_tela.ies_tip_docum ,
                                                l_ies_tip_cobr)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("INSERT","T_DOCUM_DESABILITAR")
           RETURN FALSE
        END IF
     END IF
  END IF}

  RETURN TRUE

END FUNCTION

#-------------------------#
 FUNCTION geo1017_par_con()
#-------------------------#

  WHENEVER ERROR CONTINUE
  SELECT area_livre, cod_moeda_padrao
    INTO m_area_livre, mr_par_con.cod_moeda_padrao
    FROM par_con
   WHERE cod_empresa = mr_tela.cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET m_area_livre = ' '
  END IF

  IF m_area_livre[3,4] IS NULL
  OR m_area_livre[3,4] = ' '
  OR m_area_livre[3,4] = '  ' THEN
     LET m_area = mr_tela.cod_empresa
  ELSE
     LET m_area  = m_area_livre[3,4]
  END IF

  WHENEVER ERROR CONTINUE
  SELECT ult_num_per_fech, ult_num_seg_fech
    INTO m_ult_num_per_fech, m_ult_num_seg_fech
    FROM par_con
   WHERE par_con.cod_empresa = m_area
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET m_ult_num_per_fech = ' '
     LET m_ult_num_seg_fech = ' '
  END IF

END FUNCTION

#---------------------------------------------#
 FUNCTION geo1017_verifica_forma_pgto(l_forma)
#---------------------------------------------#
  DEFINE l_forma LIKE forma_pgto.cod_forma_pgto

  WHENEVER ERROR CONTINUE
  SELECT cod_forma_pgto
    FROM forma_pgto
   WHERE forma_pgto.cod_forma_pgto  = l_forma
  WHENEVER ERROR STOP

  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  ELSE
    RETURN FALSE
  END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION geo1017_verifica_cliente(l_cliente)
#--------------------------------------------#
  DEFINE l_nom_cliente  LIKE clientes.nom_cliente,
         l_cliente      LIKE clientes.cod_cliente

  WHENEVER ERROR CONTINUE
  SELECT nom_cliente
    INTO l_nom_cliente
    FROM clientes
   WHERE clientes.cod_cliente = l_cliente
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

  RETURN TRUE
END FUNCTION
#----------------------------------#
FUNCTION geo1017_verifica_cotacao(l_empresa,
                                   l_num_docum,
                                   l_ies_tip_docum,
                                   l_dat_pgto,
                                   l_val_saldo)
#----------------------------------#
  DEFINE l_empresa        LIKE docum.cod_empresa,
         l_num_docum      LIKE docum.num_docum,
         l_ies_tip_docum  LIKE docum.ies_tip_docum,
         l_dat_pgto       DATE,
         l_val_saldo      DECIMAL(15,2)

  LET m_val_cotacao  = 0
  LET m_val_saldo    = 0

 INITIALIZE m_val_cotacao,m_val_saldo  TO NULL

 LET  m_val_saldo_urv = 0

 WHENEVER ERROR CONTINUE
 SELECT docum_cotacao.*
   INTO mr_docum_cotacao.*
   FROM docum_cotacao
  WHERE docum_cotacao.cod_empresa   = l_empresa
    AND docum_cotacao.num_docum     = l_num_docum
    AND docum_cotacao.ies_tip_docum = l_ies_tip_docum
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
   LET p_ies_cotacao   = 'CR$'
   LET m_val_variacao  = 0
   LET m_val_saldo_urv = 0
   RETURN TRUE

 ELSE
    WHENEVER ERROR CONTINUE
    SELECT val_cotacao
      INTO m_val_cotacao
      FROM cotacao
     WHERE cotacao.cod_moeda  = m_cod_moeda_1
       AND cotacao.dat_ref    = l_dat_pgto
    WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF sqlca.sqlcode = 100 THEN
         CALL log0030_mensagem('Falta a cotação para data de pagamento.','exclamation')
         RETURN FALSE
      ELSE
         CALL log003_err_sql('CONSULTA','COTACAO')
         RETURN FALSE
      END IF
   ELSE
      LET m_val_saldo_urv = mr_docum_cotacao.val_saldo * m_val_cotacao
      LET p_ies_cotacao = 'URV'

      IF m_val_saldo_urv > 0 THEN
         LET m_val_variacao = m_val_saldo_urv - l_val_saldo
      ELSE
         LET m_val_variacao = 0
      END IF

      #LET p_pgto_det.val_var_calc = m_val_variacao

   END IF

 END IF

 RETURN TRUE

END FUNCTION

#------------------------------------------------#
 FUNCTION geo1017_verifica_empresa_cre(l_empresa)
#------------------------------------------------#
  DEFINE l_empresa   CHAR(02)

  INITIALIZE m_cod_moeda_1 TO NULL

   WHENEVER ERROR CONTINUE
   SELECT parametros[287,288]
     INTO m_forma_desp
     FROM empresa_cre_txt
    WHERE cod_empresa  =  l_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
   ELSE
      LET m_forma_desp = ' '
   END IF

   WHENEVER ERROR CONTINUE
   SELECT empresa_cre.cod_moeda_1, empresa_cre.ies_ctr_cotacao
     INTO m_cod_moeda_1, m_ies_ctr_cotacao
     FROM empresa_cre,empresa
    WHERE empresa_cre.cod_empresa = l_empresa
      AND empresa.cod_empresa     = empresa_cre.cod_empresa
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
 FUNCTION geo1017_processa()
#----------------------------#
  DEFINE l_qtd_carta           SMALLINT ,
         l_cancel              SMALLINT ,
         l_programa            CHAR(08),
         l_msg                 CHAR(100),
         l_ind                 INTEGER,
         l_val_glosa           DECIMAL(15,2),
         l_sequencia           INTEGER,
         l_val_desc            DECIMAL(15,2)

  WHENEVER ERROR CONTINUE
    DELETE FROM wcre1582
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('DELETE','wcre1582')
  END IF


  IF geo1017_verifica_valores() = FALSE THEN
     RETURN FALSE
  END IF

  CALL crer37_ctbl_online_create_temp_table(1) #1-Tabela Documentos
  CALL crer37_ctbl_online_create_temp_table(2) #2-Tabela Pagamento

  #546058 Adicionado para criar as tabelas temporárias para cálculo de comissão da Roullier
  #IF Find4GLFunction("crey34_cria_tabela_temporaria") THEN #OS 594370
  #   IF NOT crey34_cria_tabela_temporaria() THEN
  #      RETURN FALSE
  #   END IF
  #END IF

  LET l_val_desc = 0

  INITIALIZE mr_adocum_pgto.*, m_empresa_trb TO NULL
  LET l_val_glosa = 0

  WHENEVER ERROR CONTINUE
  SELECT *
    INTO p_par_cre.*
    FROM par_cre
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('SELECT','P_PAR_CRE')
     RETURN FALSE
  END IF

  CALL log085_transacao('BEGIN')
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("BEGIN TRANSACTION","geo1017_PROCESSA-1")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DELETE FROM adocum_pgto_capa
         WHERE num_lote = m_num_lot
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     CALL log085_transacao('COMMIT')
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("COMMIT TRANSACTION","geo1017_PROCESSA-1")
        RETURN FALSE
     END IF
  ELSE
     CALL log085_transacao('ROLLBACK')
  END IF

  CALL log085_transacao('BEGIN')
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("BEGIN TRANSACTION","geo1017_PROCESSA-2")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_docuns CURSOR WITH HOLD FOR
    SELECT *
      FROM adocum_pgto
     WHERE num_lote = m_num_lot
     AND ies_sit_docum   = 'I'
     ORDER BY cod_empresa, num_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE CURSOR","CQ_DOCUNS")
     CALL log085_transacao('ROLLBACK')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  FOREACH cq_docuns INTO mr_adocum_pgto.*
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("FOREACH CURSOR","CQ_DOCUNS")
     CALL log085_transacao('ROLLBACK')
     RETURN FALSE
  END IF

     LET l_ind = l_ind + 1

     WHENEVER ERROR CONTINUE
      SELECT val_glosa
        INTO l_val_glosa
        FROM wglosa
       WHERE empresa = mr_adocum_pgto.cod_empresa
         AND docum   = mr_adocum_pgto.num_docum
         AND tip_docum = mr_adocum_pgto.ies_tip_docum
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 AND l_val_glosa > 0 THEN
        IF m_cre_fma_pg_glosa   IS NULL OR m_cre_fma_pg_glosa   = ' ' OR
           m_cre_port_bxa_glosa IS NULL OR m_cre_port_bxa_glosa = ' ' OR
           m_cre_tip_port_glosa IS NULL OR m_cre_tip_port_glosa = ' ' THEN
           CALL log0030_mensagem('Os parâmetros de glosa não estão cadastrados corretamente.','exclamation')
           CALL log085_transacao('ROLLBACK')
           LET m_cancela = TRUE
           RETURN FALSE
        END IF
     ELSE
        LET l_val_glosa = 0
     END IF

     WHENEVER ERROR CONTINUE
     SELECT parametros[499]
       INTO m_ies_ctr_moeda
       FROM empresa_cre_txt
      WHERE cod_empresa  = mr_adocum_pgto.cod_empresa
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET m_ies_ctr_moeda = "N"
     END IF

     IF m_arquivo_texto THEN
        LET m_dat_lancamento = mr_adocum_pgto.dat_lanc
     ELSE
        IF mr_dados_pagto.portador1 IS NULL OR
           mr_dados_pagto.portador1 = ' ' OR
           mr_dados_pagto.dat_lanc IS NULL THEN
           CALL geo1017_busca_dat_proces()
        ELSE
           LET m_dat_lancamento = mr_dados_pagto.dat_lanc
        END IF
     END IF

     CALL geo1017_grava_adocum_pgto_capa()

     LET  p_adocum_pgto.cod_portador      =    mr_adocum_pgto.cod_portador
     LET  p_adocum_pgto.ies_tip_portador  =    mr_adocum_pgto.ies_tip_portador
     LET  p_adocum_pgto.num_lote          =    m_num_lot
     LET  p_adocum_pgto.cod_empresa       =    mr_adocum_pgto.cod_empresa
     LET  p_adocum_pgto.num_docum         =    mr_adocum_pgto.num_docum
     LET  p_adocum_pgto.ies_tip_docum     =    mr_adocum_pgto.ies_tip_docum
     LET  p_adocum_pgto.ies_sit_docum     =    'I'
     LET  p_adocum_pgto.ies_tip_pgto      =    mr_adocum_pgto.ies_tip_pgto
     LET  p_adocum_pgto.ies_forma_pgto    =    mr_adocum_pgto.ies_forma_pgto
     LET  p_adocum_pgto.dat_pgto          =    mr_adocum_pgto.dat_pgto
     LET  p_adocum_pgto.dat_credito       =    mr_adocum_pgto.dat_credito
     LET  p_adocum_pgto.dat_lanc           =   m_dat_lancamento
     LET  p_adocum_pgto.val_titulo        =    mr_adocum_pgto.val_titulo - l_val_glosa
     LET  p_adocum_pgto.val_juro          =    mr_adocum_pgto.val_juro
     LET  p_adocum_pgto.val_desc          =    mr_adocum_pgto.val_desc
     LET  p_adocum_pgto.val_abat          =    '0'
     LET  p_adocum_pgto.val_desp_cartorio =    mr_adocum_pgto.val_desp_cartorio
     LET  p_adocum_pgto.val_despesas      =    mr_adocum_pgto.val_despesas
     LET  p_adocum_pgto.ies_abono_juros   =    mr_adocum_pgto.ies_abono_juros
     LET  p_adocum_pgto.val_multa         =    mr_adocum_pgto.val_multa
     LET  p_adocum_pgto.val_ir            =    '0'
     LET  p_val_pago                      =    mr_adocum_pgto.val_titulo
     LET  g_total_val_var_cambial_menor   = 0
     LET  g_total_val_var_cambial_maior   = 0

     WHENEVER ERROR CONTINUE
       SELECT *
         INTO p_docum.*
         FROM docum
        WHERE cod_empresa   = mr_adocum_pgto.cod_empresa
          AND num_docum     = mr_adocum_pgto.num_docum
          AND ies_tip_docum = mr_adocum_pgto.ies_tip_docum
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('SELECT','DOCUM')
        CALL log085_transacao('ROLLBACK')
        RETURN FALSE
     END IF

     CALL geo1017_carrega_p_docum(mr_adocum_pgto.cod_empresa,
                                   mr_adocum_pgto.num_docum,
                                   mr_adocum_pgto.ies_tip_docum)

     INITIALIZE gr_cre_tit_cob_esp.* TO NULL

     #OS 603292
     IF NOT cre1590_atualiza_dados() THEN
     
        CALL log085_transacao('ROLLBACK')
        LET m_ies_processou = TRUE
        IF p_wcre1581.des_mensagem IS NOT NULL AND
           p_wcre1581.des_mensagem <> " " THEN
           #LET p_wcre1581.des_mensagem = p_wcre1581.des_mensagem[1,50] #OS 606437
           IF cre1590_monta_wcre1591(p_wcre1581.des_mensagem) = FALSE THEN
           
              RETURN FALSE
           END IF
        END IF
        
        RETURN FALSE
     END IF

     #OS 603292
     {IF Find4GLFunction("crey42_grava_conhecimentos") THEN #OS 594370
        IF NOT crey42_grava_conhecimentos(mr_adocum_pgto.cod_empresa  ,
                                          mr_adocum_pgto.num_docum    ,
                                          mr_adocum_pgto.ies_tip_docum) THEN

           WHENEVER ERROR CONTINUE
              CALL log085_transacao('ROLLBACK')
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
              CALL log003_err_sql("TRANSACAO","ROLLBACK")
           END IF
           RETURN FALSE
        END IF
     END IF}

    {IF log_existe_epl("geo1017y_grava_conhecimentos") THEN

       CALL LOG_setVar( "PRG_cod_empresa",      mr_adocum_pgto.cod_empresa     )
       CALL LOG_setVar( "PRG_num_docum",        mr_adocum_pgto.num_docum       )
       CALL LOG_setVar( "PRG_ies_tip_docum",    mr_adocum_pgto.ies_tip_docum   )

       IF NOT geo1017y_grava_conhecimentos() THEN

          WHENEVER ERROR CONTINUE
             CALL log085_transacao('ROLLBACK')
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("TRANSACAO","ROLLBACK")
          END IF
          RETURN FALSE
       END IF

    END IF}
     # Gravação de 2 registros de pagamento:

     IF l_val_glosa > 0 THEN

        WHENEVER ERROR CONTINUE
        DECLARE cl_verifica_glosa CURSOR FOR
         SELECT *
           FROM docum_pgto
          WHERE cod_empresa      = mr_adocum_pgto.cod_empresa
            AND num_docum        = mr_adocum_pgto.num_docum
            AND ies_tip_docum    = mr_adocum_pgto.ies_tip_docum
            AND ies_forma_pgto   = m_cre_fma_pg_glosa
            AND cod_portador     = m_cre_port_bxa_glosa
            AND ies_tip_portador = m_cre_tip_port_glosa
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("DECLARE CURSOR","CL_VERIFICA_GLOSA")
           CALL log085_transacao('ROLLBACK')
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
        OPEN cl_verifica_glosa
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('OPEN CURSOR','CL_VERIFICA_GLOSA')
           CALL log085_transacao('ROLLBACK')
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
        FETCH cl_verifica_glosa INTO p_docum_pgto.*
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           IF l_val_glosa > 0 THEN
              LET l_val_desc = p_docum_pgto.val_desc_conc
              LET l_msg = 'Valor ', p_docum_pgto.val_desc_conc USING "<<<<&.&&", ' lançado como glosa, confirma processamento?' CLIPPED
              IF log0040_confirm(17,25,l_msg) THEN
                 CALL geo1017_pesquisa_empresa_cre()
                 IF geo1017_verifica_trb() = FALSE THEN
                    CALL log085_transacao('ROLLBACK')
                    RETURN FALSE
                 END IF
                 IF p_docum_pgto.num_lote_lanc_cont > 0 THEN
                    IF log0040_confirm(17,25,'Valor glosa já contabilizado, confirma alteração?') THEN
                       IF geo1017_estorna_pgto() = FALSE THEN
                          CALL log085_transacao('ROLLBACK')
                          RETURN FALSE
                       END IF

                       IF m_parametro[407,407] = "S" THEN
                          CALL fcl1180_integracao_cre_fcx(p_docum_pgto.cod_empresa,
                                                          "DP",
                		                                        p_docum_pgto.ies_tip_docum,
                    	                                     p_docum_pgto.num_docum,
                       	                                  p_docum_pgto.num_seq_docum,
                          	                               p_docum.cod_cliente,
                             	                            "EX") RETURNING m_status, m_mesg_fcx #VER IN or EX
                          IF NOT m_status THEN
                	            CALL log0030_mensagem("Erro na integração no CRECEBER com FLUXO DE CAIXA.","info")
                         	   CALL log085_transacao('ROLLBACK')
                         	   RETURN FALSE
                          END IF
                       END IF
                    END IF
                 END IF
                 IF l_val_glosa IS NOT NULL AND
                    l_val_glosa > 0 THEN
                    WHENEVER ERROR CONTINUE
                     DELETE FROM docum_pgto
                      WHERE cod_empresa      = mr_adocum_pgto.cod_empresa
                        AND num_docum        = mr_adocum_pgto.num_docum
                        AND ies_tip_docum    = mr_adocum_pgto.ies_tip_docum
                        AND ies_forma_pgto   = m_cre_fma_pg_glosa
                        AND cod_portador     = m_cre_port_bxa_glosa
                        AND ies_tip_portador = m_cre_tip_port_glosa
                    WHENEVER ERROR STOP
                    IF sqlca.sqlcode <> 0 THEN
                       CALL log003_err_sql('DELETE','DOCUM_PGTO')
                       CALL log085_transacao('ROLLBACK')
                       RETURN FALSE
                    END IF
                    LET p_adocum_pgto.cod_portador      = m_cre_port_bxa_glosa
                    LET p_adocum_pgto.ies_tip_portador  = m_cre_tip_port_glosa
                    LET p_adocum_pgto.ies_forma_pgto    = m_cre_fma_pg_glosa
                    LET p_adocum_pgto.val_desc          = l_val_glosa
                    LET p_adocum_pgto.val_titulo        = 0
                    LET p_adocum_pgto.val_juro          = 0
                    LET g_num_lote_pgto                 = p_adocum_pgto.num_lote
                    # Alteração da tabela docum
                    IF geo1017_altera_docum(l_val_desc,p_adocum_pgto.val_desc) THEN
                    ELSE
                       CALL log085_transacao('ROLLBACK')
                       RETURN FALSE
                    END IF
                    # fim
                    IF cre9480_inclui_pgto(p_adocum_pgto.cod_empresa, p_adocum_pgto.num_docum,
                                           p_adocum_pgto.ies_tip_docum, p_adocum_pgto.val_desc) = FALSE THEN
                       CALL log0030_mensagem("Erro na liquidação do documento.","exclamation")
                       CALL log085_transacao('ROLLBACK')
                       RETURN FALSE
                    ELSE
                       CALL geo1017_inclui_glosa_info_adic()
                    END IF
                 END IF
              ELSE
                 LET m_cancela = TRUE
                 CALL log085_transacao('ROLLBACK')
                 RETURN FALSE
              END IF
           END IF
        ELSE
           IF l_val_glosa IS NOT NULL AND
              l_val_glosa > 0 THEN
              LET p_adocum_pgto.cod_portador      = m_cre_port_bxa_glosa
              LET p_adocum_pgto.ies_tip_portador  = m_cre_tip_port_glosa
              LET p_adocum_pgto.ies_forma_pgto    = m_cre_fma_pg_glosa
              LET p_adocum_pgto.val_desc          = l_val_glosa
              LET p_adocum_pgto.val_titulo        = 0
              LET p_adocum_pgto.val_juro          = 0
              LET g_num_lote_pgto                 = p_adocum_pgto.num_lote
              IF cre9480_inclui_pgto(p_adocum_pgto.cod_empresa, p_adocum_pgto.num_docum,
                                     p_adocum_pgto.ies_tip_docum, p_adocum_pgto.val_desc) = FALSE THEN
                 CALL log0030_mensagem("Erro na liquidação do documento.","exclamation")
                 CALL log085_transacao('ROLLBACK')
                 RETURN FALSE
              ELSE
                 CALL geo1017_inclui_glosa_info_adic()
              END IF

              # Alteração da tabela docum
              #IF geo1017_altera_docum(l_val_desc,p_adocum_pgto.val_desc) THEN
              #LSE
              #   RETURN FALSE
              #END IF
              # fim
           END IF
        END IF
        WHENEVER ERROR CONTINUE
         CLOSE cl_verifica_glosa
          FREE cl_verifica_glosa
        WHENEVER ERROR STOP

     END IF
     IF geo1017_verifica_nota_deb() THEN
        IF NOT geo1017_verifica_cotacao(mr_adocum_pgto.cod_empresa,
                                         mr_adocum_pgto.num_docum,
                                         mr_adocum_pgto.ies_tip_docum,
                                         mr_adocum_pgto.dat_pgto,
                                         mr_adocum_pgto.val_titulo) THEN
           LET p_ies_cotacao = 'CR$'
        END IF
        IF cre1600_grava_nota_deb() THEN
        END IF
     END IF

     IF NOT geo1017_atualiza_adocum_pgto_capa() THEN
        CALL log085_transacao('ROLLBACK')
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
     SELECT COUNT(*)
       INTO l_qtd_carta
       FROM carta_anuencia
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET l_qtd_carta = 0
     END IF

     IF l_qtd_carta > 0 THEN
        INITIALIZE l_programa TO NULL
        LET l_programa = m_parametro[31,38]
        INITIALIZE m_comando TO NULL
        CALL log120_procura_caminho(l_programa) RETURNING m_comando
        RUN m_comando RETURNING l_cancel
     END IF

     WHENEVER ERROR CONTINUE
     DELETE FROM carta_anuencia
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('DELETE','CARTA_ANUENCIA')
     END IF

     IF NOT geo1017_grava_tabelas() THEN
        CALL log085_transacao('ROLLBACK')
        RETURN FALSE
     END IF

     {IF log_existe_epl( "geo1017y_valida_valores" ) THEN
        IF mr_adocum_pgto.ies_tip_pgto = "P" THEN
           CALL LOG_setVar( "PRG_cod_empresa"       , mr_adocum_pgto.cod_empresa      )
           CALL LOG_setVar( "PRG_num_docum"         , mr_adocum_pgto.num_docum        )
           CALL LOG_setVar( "PRG_ies_tip_docum"     , mr_adocum_pgto.ies_tip_docum    )
           CALL LOG_setVar( "PRG_val_titulo"        , mr_adocum_pgto.val_titulo       )
           CALL LOG_setVar( "PRG_val_desp_cartorio" , mr_adocum_pgto.val_desp_cartorio)
           CALL LOG_setVar( "PRG_val_despesas"      , mr_adocum_pgto.val_despesas     )
           CALL LOG_setVar( "PRG_val_desc"          , mr_adocum_pgto.val_desc         )
           CALL LOG_setVar( "PRG_val_abat"          , mr_adocum_pgto.val_abat         )


           CALL geo1017y_valida_valores() RETURNING p_status

           IF p_status = FALSE THEN
              CALL log085_transacao('ROLLBACK')
              RETURN FALSE
           END IF
        END IF
     END IF}
     IF NOT geo1017_consiste_conhecimento() THEN
        CALL log085_transacao('ROLLBACK')
        RETURN FALSE
     END IF
  END FOREACH

  WHENEVER ERROR CONTINUE
  CLOSE cq_docuns
  FREE cq_docuns
  WHENEVER ERROR STOP

  IF mr_dados_pagto.tip_portador1 = "B" THEN
     IF NOT geo1017_grava_conc_pgto() THEN
        CALL log085_transacao('ROLLBACK')
        RETURN FALSE
     END IF
  END IF

  {IF m_arquivo_texto THEN
     #EPL crey65 específico do cliente EXATA.
     IF Find4GLFunction("crey65_verifica_grava_conc_pgto") THEN
        IF crey65_verifica_grava_conc_pgto() THEN
           LET m_empresa_trb                = crey65_get_empresa_cre()
           LET m_num_lot                    = crey65_get_num_lote_pgto()
           LET mr_dados_pagto.portador1     = crey65_get_portador()
           LET mr_dados_pagto.tip_portador1 = crey65_get_tip_portador()
           LET m_num_seq_conc_trb           = crey65_get_seq_conc_trb()

           IF mr_dados_pagto.tip_portador1 = "B" AND
              m_ies_conc_bco_cxa           = "S" AND
              m_parametro[413]             = "S" THEN
              CALL geo1017_integra_trb()
           END IF

           LET mr_dados_pagto.portador1     = NULL
           LET mr_dados_pagto.tip_portador1 = NULL
        ELSE
           CALL log085_transacao("ROLLBACK")
           RETURN FALSE
        END IF
     END IF
  END IF}

  #::: Utilizado pelo Cliente 407 - Penske
  {IF LOG_getVar("efetua_leitura_txt") THEN
     IF LOG_existe_epl("geo1017y_grava_conc_pgto") THEN

        IF geo1017y_grava_conc_pgto() THEN

           LET m_empresa_trb                = LOG_getVar( "codigo_empresa"   )
           LET m_num_lot                    = LOG_getVar( "num_lote_pgto"    )
           LET mr_dados_pagto.portador1     = LOG_getVar( "codigo_portador"  )
           LET mr_dados_pagto.tip_portador1 = LOG_getVar( "tipo_portador"    )
           LET m_num_seq_conc_trb           = LOG_getVar( "num_seq_conc_trb" )

           IF mr_dados_pagto.tip_portador1 = "B" AND
              m_ies_conc_bco_cxa           = "S" AND
              m_parametro[413]             = "S" THEN
              CALL geo1017_integra_trb()
           END IF

           LET mr_dados_pagto.portador1     = NULL
           LET mr_dados_pagto.tip_portador1 = NULL
        ELSE
           CALL log085_transacao("ROLLBACK")
           RETURN FALSE
        END IF
     END IF
  END IF}

  CALL log085_transacao('COMMIT')
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("COMMIT TRANSACTION","geo1017_PROCESSA-2")
     RETURN FALSE
  END IF

  CALL crer37_contabilizacao_online_temp_table(1,"geo1017",0)
  CALL crer37_contabilizacao_online_temp_table(2,"geo1017",0)

  #546058 Elimina as tabelas temporárias usadas no cálculo de comissão da Roullier. Caso haja algum erro e as funções acima retornem false, a tabela não será eliminada
  #IF Find4GLFunction("crey34_elimina_tabela_temporaria") THEN #OS 594370
  #   IF NOT crey34_elimina_tabela_temporaria() THEN
  #   END IF
  #END IF
  
  UPDATE docum_pgto
     SET dat_atualiz = dat_pgto
   WHERE cod_empresa      = mr_adocum_pgto.cod_empresa
     AND num_docum        = mr_adocum_pgto.num_docum
     AND ies_tip_docum    = mr_adocum_pgto.ies_tip_docum
     
  UPDATE docum_obs
     SET dat_obs = mr_dados_pagto.dat_lanc,
         dat_atualiz = mr_dados_pagto.dat_lanc
   WHERE cod_empresa      = mr_adocum_pgto.cod_empresa
     AND num_docum        = mr_adocum_pgto.num_docum
     AND ies_tip_docum    = mr_adocum_pgto.ies_tip_docum
     AND dat_atualiz = TODAY

  RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION geo1017_grava_tabelas()
#---------------------------------#
 DEFINE l_num_seq         LIKE pgto_det.num_seq

 WHENEVER ERROR CONTINUE
 SELECT MAX(num_seq)
   INTO l_num_seq
   FROM pgto_det
  WHERE pgto_det.cod_empresa      = mr_adocum_pgto.cod_empresa
    AND pgto_det.num_lote         = m_num_lot
    AND pgto_det.cod_portador     = mr_adocum_pgto.cod_portador
    AND pgto_det.ies_tip_portador = mr_adocum_pgto.ies_tip_portador
 WHENEVER ERROR STOP

 IF sqlca.sqlcode  <> 0 THEN
    LET l_num_seq = 1
 ELSE
    IF l_num_seq IS NULL THEN
       LET l_num_seq = 1
    ELSE
       LET l_num_seq = l_num_seq + 1
    END IF
 END IF

 WHENEVER ERROR CONTINUE
 SELECT dat_lanc
   INTO m_dat_lancamento
   FROM adocum_pgto
  WHERE cod_empresa     = mr_adocum_pgto.cod_empresa
    AND cod_portador    = mr_adocum_pgto.cod_portador
    AND ies_tip_docum   = mr_adocum_pgto.ies_tip_docum
    AND num_docum       = mr_adocum_pgto.num_docum
    AND num_lote        = m_num_lot
    AND ies_sit_docum   = 'I'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
 ELSE
    LET m_dat_lancamento = ' '
 END IF

 WHENEVER ERROR CONTINUE
 SELECT som_val_titulo
   INTO m_som_val_titulo
   FROM adocum_pgto_capa
  WHERE cod_empresa      = mr_adocum_pgto.cod_empresa
    AND cod_portador     = mr_adocum_pgto.cod_portador
    AND ies_tip_portador = mr_adocum_pgto.ies_tip_portador
    AND num_lote         = m_num_lot
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET m_som_val_titulo = 0
 END IF

  WHENEVER ERROR CONTINUE
  INSERT INTO pgto_det
         VALUES ( mr_adocum_pgto.cod_empresa      ,
                  m_num_lot                       ,
                  mr_adocum_pgto.cod_portador     ,
                  mr_adocum_pgto.ies_tip_portador ,
                  mr_adocum_pgto.cod_empresa      ,
                  mr_adocum_pgto.num_docum        ,
                  mr_adocum_pgto.ies_tip_docum    ,
                  l_num_seq                       ,
                  p_docum.ies_pgto_docum          ,
                  mr_adocum_pgto.dat_pgto         ,
                  mr_adocum_pgto.val_titulo       ,
                  0                               ,
                  0                               ,
                  mr_adocum_pgto.val_multa        ,
                  p_val_multa_a_pag               ,
                  0                               ,
                  p_val_juro_a_pag                ,
                  0                               ,
                  mr_adocum_pgto.val_juro         ,
                  0                               ,
                  mr_adocum_pgto.val_desc         ,
                  0                               ,
                  mr_adocum_pgto.val_desp_cartorio,
                  mr_adocum_pgto.val_despesas     ,
                  mr_adocum_pgto.ies_abono_juros  )
 WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        IF cre1590_monta_wcre1591('Erro na gravação dos detalhes da baixa(PGTO_DET).') = FALSE THEN
           RETURN FALSE
        END IF
        RETURN FALSE
     END IF

     IF m_dat_cre_capa_cncl = "S" THEN
        IF NOT geo1017_insert_cre_pagto_det_cpl(m_num_lot,l_num_seq,NULL,mr_adocum_pgto.dat_credito,"") THEN
           RETURN FALSE
        END IF
     END IF

     IF m_empresa_trb IS NULL THEN
        LET m_empresa_trb = mr_adocum_pgto.cod_empresa
     END IF

     IF NOT geo1017_insert_cre_pagto_det_cpl(m_num_lot,l_num_seq,"empresa_trb",NULL,m_empresa_trb) THEN
        RETURN FALSE
     END IF

 LET m_dat_lancamento    = p_par_cre.dat_proces_doc
 WHENEVER ERROR CONTINUE
 SELECT cod_empresa
   FROM pgto_capa
  WHERE cod_empresa      = mr_adocum_pgto.cod_empresa
    AND num_lote         = m_num_lot
    AND cod_portador     = mr_adocum_pgto.cod_portador
    AND ies_tip_portador = mr_adocum_pgto.ies_tip_portador
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
     UPDATE pgto_capa
        SET ies_sit_lote    = 'A',
            dat_cred        = mr_adocum_pgto.dat_credito,
            dat_lanc        = m_dat_lancamento,
            ies_forma_pgto  = mr_adocum_pgto.ies_forma_pgto,
            total_lote      = m_som_val_titulo,
            ies_proces_lote = 'S'
      WHERE cod_empresa      = mr_adocum_pgto.cod_empresa
        AND num_lote         = m_num_lot
        AND cod_portador     = mr_adocum_pgto.cod_portador
        AND ies_tip_portador = mr_adocum_pgto.ies_tip_portador
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('ALTERACAO','PGTO_CAPA')
        RETURN FALSE
    END IF
 ELSE
    WHENEVER ERROR CONTINUE
    INSERT INTO pgto_capa
           VALUES (mr_adocum_pgto.cod_empresa        ,
                   m_num_lot                         ,
                   mr_adocum_pgto.cod_portador       ,
                   mr_adocum_pgto.ies_tip_portador   ,
                   'A'                               ,
                   mr_adocum_pgto.dat_credito        ,
                   m_dat_lancamento                  ,
                   mr_adocum_pgto.ies_forma_pgto     ,
                   m_som_val_titulo                  ,
                   'S'                        )
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       IF cre1590_monta_wcre1591('Erro na gravação da capa do lote da baixa (PGTO_CAPA).') = FALSE THEN
          RETURN FALSE
       END IF
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION geo1017_verifica_nota_deb()
#----------------------------------#
  DEFINE l_qtd_nota_deb DECIMAL (3,0)

  INITIALIZE l_qtd_nota_deb TO NULL

  WHENEVER ERROR CONTINUE
  SELECT COUNT(*)
    INTO l_qtd_nota_deb
    FROM wcre1582
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_qtd_nota_deb = 0
  END IF

  IF l_qtd_nota_deb = 0 THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION

#----------------------------------#
 FUNCTION geo1017_cria_tabela_temp()
#----------------------------------#
  WHENEVER ERROR CONTINUE
  DROP TABLE wcre1582;
  DROP TABLE t_geo1017_1;
  DROP TABLE wcre1591;
  DROP TABLE t_nc;
  DROP TABLE wcre158inst
  DROP TABLE wglosa;
  DROP TABLE wmarcados;

  CREATE TEMP TABLE wmarcados
   ( indice     SMALLINT,
     empresa    CHAR(02),
     docum      CHAR(14),
     tip_docum  CHAR(02),
     dat_pgto   DATE,
     val_saldo  DECIMAL(15,2),
     val_desc   DECIMAL(15,2),
     val_juros  DECIMAL(15,2),
     marcado    CHAR(01)
   ) WITH NO LOG ;

  CREATE TEMP TABLE wglosa
   ( empresa    CHAR(02),
     docum      CHAR(14),
     tip_docum  CHAR(02),
     tip_pgto   CHAR(01),
     val_glosa  DECIMAL(15,2)
   ) WITH NO LOG ;

  CREATE TEMP TABLE wcre1582
    (
     cod_empresa              CHAR(02),
     num_duplicata            CHAR(14)
    )
  WITH NO LOG

  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('CREATE','WCRE1582')
     RETURN FALSE
  END IF

  CREATE TEMP TABLE t_geo1017_1
  (
  cod_empresa          CHAR(2),
  cod_portador         DECIMAL(3,0),
  num_docum            CHAR(13),
  num_conta            CHAR(15),
  agencia_bancaria     CHAR(06),
  ies_tip_docum        CHAR(2),
  val_docum            DECIMAL(15,2),
  dat_emissao          DATE,
  num_lote_conc        DECIMAL(5,0),
  sequencia_lote       INTEGER,
  deb_cre              CHAR(1),
  sequencia            INTEGER,
  portador_docum       DECIMAL(4,0)
  )
 WITH NO LOG
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('CREATE','T_geo1017_1')
    RETURN FALSE
 END IF

 CREATE TEMP TABLE wcre1591
   (
   cod_empresa     CHAR(02),
   num_docum       CHAR(14),
   ies_tip_docum   CHAR(02),
   num_seq_docum   DECIMAL(02,0),
   dat_pgto        DATE,
   val_pago        DECIMAL(15,2),
   val_juro_pago   DECIMAL(15,2),
   val_desc_conc   DECIMAL(15,2),
   val_abat        DECIMAL(15,2),
   mensagem        CHAR(90)
   )
 WITH NO LOG
 IF sqlca.sqlcode<> 0 THEN
    CALL log003_err_sql('CREATE','WCRE1591')
    RETURN FALSE
 END IF


 CREATE TEMP TABLE t_nc
 (
 cod_empresa           CHAR(02),
 num_docum             CHAR(14)
 )
 WITH NO LOG;

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('CREATE','T_NC')
    RETURN FALSE
 END IF

 SELECT *
   FROM docum_instr
  WHERE cod_empresa IS NULL
   INTO TEMP wcre158inst
 WHENEVER ERROR STOP

 IF sqlca.sqlcode  <> 0 THEN
    CALL log003_err_sql('CREATE','WCRE158INST')
    RETURN FALSE
 END IF

  RETURN TRUE

END FUNCTION

#---------------------------------------------#
 FUNCTION geo1017_atualiza_adocum_pgto_capa()
#---------------------------------------------#

  WHENEVER ERROR CONTINUE
  UPDATE adocum_pgto_capa
     SET adocum_pgto_capa.ies_sit_lote = 'A'
   WHERE cod_empresa      = mr_adocum_pgto.cod_empresa
     AND cod_portador     = mr_adocum_pgto.cod_portador
     AND ies_tip_portador = mr_adocum_pgto.ies_tip_portador
     AND num_lote         = m_num_lot
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("UPDATE","ADOCUM_PGTO_CAPA")
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#--------------------------------------#
 FUNCTION geo1017_processa_lotes_compl()
#--------------------------------------#
 DEFINE l_ind         SMALLINT
 DEFINE l_valor       LIKE conc_pgto.val_concil,
        l_valor_nc    LIKE pgto_det.val_titulo


    LET p_qtd_lotes     = 0
    LET p_lotes[1].num_lote_compl = pr_conc_pgto_trb.num_lote_compl_1
    LET p_lotes[2].num_lote_compl = pr_conc_pgto_trb.num_lote_compl_2
    LET p_lotes[3].num_lote_compl = pr_conc_pgto_trb.num_lote_compl_3
    LET p_lotes[4].num_lote_compl = pr_conc_pgto_trb.num_lote_compl_4
    LET p_lotes[5].num_lote_compl = pr_conc_pgto_trb.num_lote_compl_5

    FOR l_ind =1 TO 5
        IF p_lotes[l_ind].num_lote_compl IS NOT NULL THEN
           IF p_lotes[l_ind].num_lote_compl > 0 THEN
              LET p_qtd_lotes = p_qtd_lotes + 1
              CALL geo1017_busca_nc_conc(p_lotes[l_ind].num_lote_compl, TRUE)
           END IF
        END IF
    END FOR

    IF  p_qtd_lotes > 1 THEN
        LET l_valor                     =  pr_conc_pgto_trb.val_concil
        LET pr_conc_pgto_trb.val_concil =  pr_conc_pgto_trb.val_concil / p_qtd_lotes
        LET m_diferenca                 = (pr_conc_pgto_trb.val_concil * p_qtd_lotes) - l_valor

        LET l_valor_nc     =  p_val_nc
        LET p_val_nc       =  p_val_nc / p_qtd_lotes
        LET m_diferenca_nc = (p_val_nc * p_qtd_lotes) - l_valor_nc

    END IF

END FUNCTION

#------------------------------------------------------------#
 FUNCTION geo1017_busca_nc_conc(l_num_lote, l_soma_true_false)
#------------------------------------------------------------#
    DEFINE l_num_lote          LIKE docum_pgto.num_lote_pgto
    DEFINE l_soma_true_false   SMALLINT

    DEFINE l_nc          RECORD
           cod_empresa      LIKE docum.cod_empresa,
           num_docum        LIKE docum.num_docum,
           ies_tip_docum    LIKE docum.ies_tip_docum,
           val_bruto        LIKE docum.val_bruto
                         END RECORD
    DEFINE l_chave       RECORD
           cod_empresa      LIKE docum_pgto.cod_empresa,
           num_docum        LIKE docum_pgto.num_docum,
           ies_tip_docum    LIKE docum_pgto.ies_tip_docum,
           num_seq_docum    LIKE docum_pgto.num_seq_docum
                         END RECORD

    INITIALIZE l_nc.* TO NULL

    WHENEVER ERROR CONTINUE
    DECLARE cq_dp_nc CURSOR FOR
     SELECT cod_empresa  ,
            num_docum    ,
            ies_tip_docum,
            num_seq_docum
       FROM docum_pgto
      WHERE docum_pgto.cod_empresa      = pr_conc_pgto_trb.cod_empresa
        AND docum_pgto.num_lote_pgto    = l_num_lote
        AND docum_pgto.cod_portador     = pr_conc_pgto_trb.cod_portador
        AND docum_pgto.ies_tip_portador = 'B'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('SELECT','DOCUM_PGTO')
     END IF

     WHENEVER ERROR CONTINUE
     OPEN cq_dp_nc
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('OPEN','CQ_DP_NC')
     END IF

     WHENEVER ERROR CONTINUE
     FETCH cq_dp_nc INTO l_chave.*
     WHENEVER ERROR STOP

      IF sqlca.sqlcode = 0 THEN

         WHILE sqlca.sqlcode = 0

            WHENEVER ERROR CONTINUE
            DECLARE cq_val_nc_conc CURSOR FOR
             SELECT cod_empresa  ,
                    num_docum    ,
                    ies_tip_docum,
                    val_bruto
               FROM docum
              WHERE docum.cod_empresa        = l_chave.cod_empresa
                AND docum.num_docum_origem   = l_chave.num_docum
                AND docum.ies_tip_docum_orig = l_chave.ies_tip_docum
                AND docum.ies_tip_docum      = 'NC'
             WHENEVER ERROR STOP
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql('SELECT','DOCUM_PGTO')
             END IF

             WHENEVER ERROR CONTINUE
             OPEN cq_val_nc_conc
             WHENEVER ERROR STOP
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql('OPEN','CQ_VAL_NC_CONC')
             END IF

             WHENEVER ERROR CONTINUE
             FETCH cq_val_nc_conc INTO l_nc.*
             WHENEVER ERROR STOP
               IF sqlca.sqlcode = 0 THEN

                   WHILE sqlca.sqlcode = 0
                      WHENEVER ERROR CONTINUE
                      SELECT docum_txt.parametro[456,460]
                        INTO m_num_lote_trb
                        FROM docum_txt
                       WHERE docum_txt.cod_empresa     = l_nc.cod_empresa
                         AND docum_txt.num_docum       = l_nc.num_docum
                         AND docum_txt.ies_tip_docum   = l_nc.ies_tip_docum
                      WHENEVER ERROR STOP
                      IF sqlca.sqlcode = 100 THEN
                         IF l_soma_true_false THEN
                             LET p_val_nc = p_val_nc + l_nc.val_bruto
                         END IF

                         WHENEVER ERROR CONTINUE
                         INSERT INTO t_nc VALUES ( l_nc.cod_empresa, l_nc.num_docum )
                         WHENEVER ERROR STOP

                         IF sqlca.sqlcode <> 0 THEN
                            CALL log003_err_sql('INSERT','T_NC')
                            EXIT WHILE
                         END IF
                      ELSE
                         IF sqlca.sqlcode = 0 THEN
                            IF m_num_lote_trb IS NULL OR m_num_lote_trb = 0 THEN
                               IF l_soma_true_false THEN
                                   LET p_val_nc = p_val_nc + l_nc.val_bruto
                               END IF

                               WHENEVER ERROR CONTINUE
                               INSERT INTO t_nc VALUES ( l_nc.cod_empresa, l_nc.num_docum )
                               WHENEVER ERROR STOP

                               IF sqlca.sqlcode <> 0 THEN
                                  CALL log003_err_sql('INSERT','T_NC')
                                  EXIT WHILE
                               END IF
                            END IF
                         END IF
                      END IF
                      WHENEVER ERROR CONTINUE
                      FETCH cq_val_nc_conc INTO l_nc.*
                      WHENEVER ERROR STOP
                      IF sqlca.sqlcode = 0 THEN
                      ELSE
                         CALL log003_err_sql('FETCH','CQ_VAL_NC_CONC')
                      END IF
                   END WHILE
               END IF
               WHENEVER ERROR CONTINUE
               FETCH cq_dp_nc INTO l_chave.*
               WHENEVER ERROR STOP
               IF sqlca.sqlcode <> 0 THEN
                  IF sqlca.sqlcode <> 100 THEN
                     CALL log003_err_sql('FETCH','CQ_DP_NC')
                  END IF
                  EXIT WHILE
               END IF
         END WHILE
  END IF

 WHENEVER ERROR CONTINUE
  CLOSE cq_val_nc_conc
   FREE cq_val_nc_conc
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
  CLOSE cq_dp_nc
   FREE cq_dp_nc
 WHENEVER ERROR STOP

END FUNCTION

#-----------------------------------------------------#
 FUNCTION geo1017_busca_tarifa(l_dat_credito,l_cod_port)
#-----------------------------------------------------#
    DEFINE l_dat_credito    DATE,
           l_cod_port       DECIMAL(4,0)

    ####### Utilizaremos o campo ies_proces_lote, como indicador do que ja foi
    ####### Integrado com o t.r.b., ja que em funcao da forma de pagamento
    ####### este lote nao sera incluido na adocum_pgto, s'o  servira para o
    ####### lancamento de despesas.

    WHENEVER ERROR CONTINUE
    SELECT SUM(val_lancamento)
      INTO p_val_tarifa
      FROM pgto_capa, contas_aux
     WHERE pgto_capa.cod_empresa       = m_empresa_trb
       AND pgto_capa.cod_portador      = mr_adocum_pgto.cod_portador
       AND pgto_capa.ies_tip_portador  = 'B'
       AND pgto_capa.dat_cred          = mr_adocum_pgto.dat_credito
       AND pgto_capa.ies_forma_pgto    = p_forma_desp
       AND pgto_capa.ies_proces_lote   = 'N'
       AND contas_aux.cod_empresa      = pgto_capa.cod_empresa
       AND contas_aux.num_lote         = pgto_capa.num_lote
       AND contas_aux.cod_portador     = pgto_capa.cod_portador
       AND contas_aux.ies_tip_portador = pgto_capa.ies_tip_portador
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
    ELSE
       LET p_val_tarifa = 0
    END IF
       IF p_val_tarifa IS NOT NULL AND p_val_tarifa > 0 THEN

           WHENEVER ERROR CONTINUE
           UPDATE pgto_capa SET ies_proces_lote = 'S'
            WHERE pgto_capa.cod_empresa        = m_empresa_trb
              AND pgto_capa.cod_portador       = mr_adocum_pgto.cod_portador
              AND pgto_capa.ies_tip_portador   = 'B'
              AND pgto_capa.dat_cred           = mr_adocum_pgto.dat_credito
              AND pgto_capa.ies_forma_pgto     = p_forma_desp
              AND pgto_capa.ies_proces_lote    = 'N'
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql('ATUALIZACAO', 'PGTO_CAPA')
           END IF
       ELSE
           LET p_val_tarifa = 0
       END IF

END FUNCTION

#---------------------------------------------#
 FUNCTION geo1017_busca_par_banc(l_cod_banco)
#---------------------------------------------#
  DEFINE l_cod_banco    LIKE par_banc.cod_banco

    WHENEVER ERROR CONTINUE
    SELECT par_banc.ies_sum_dp_nc, par_banc.ies_desc_tarifa
      INTO p_par_banc_nc, p_par_banc_desp
      FROM par_banc
     WHERE par_banc.cod_banco = l_cod_banco
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       LET p_par_banc_nc   = 'N'
       LET p_par_banc_desp = 'S'
    END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION geo1017_pesquisa_docum_pgto_txt()
#-----------------------------------------#

  WHENEVER ERROR CONTINUE
  SELECT docum_pgto_txt.parametros[53,57]
    INTO p_num_lote_trb
    FROM docum_pgto_txt
   WHERE docum_pgto_txt.cod_empresa     = mr_adocum_pgto.cod_empresa
     AND docum_pgto_txt.num_docum       = mr_adocum_pgto.num_docum
     AND docum_pgto_txt.ies_tip_docum   = mr_adocum_pgto.ies_tip_docum
     AND docum_pgto_txt.num_seq_docum   = p_docum_pgto.num_seq_docum
  WHENEVER ERROR STOP

       IF  sqlca.sqlcode = 100 THEN
           RETURN TRUE
       ELSE
           IF  sqlca.sqlcode = 0 THEN
               IF  p_num_lote_trb IS NULL OR p_num_lote_trb = 0 THEN
                   RETURN TRUE, 0
               ELSE
                   RETURN FALSE, p_num_lote_trb
              END IF
           END IF
       END IF

END FUNCTION

#--------------------------#
 FUNCTION geo1017_consulta()
#--------------------------#

   DEFINE l_ind           SMALLINT,
          l_val_glosa     DECIMAL(15,2)

   DEFINE l_status        SMALLINT
         ,l_msg           VARCHAR(200)

{   CALL log006_exibe_teclas('01 02 07', p_versao)
   CURRENT WINDOW IS w_geo1017
   CLEAR FORM

   LET where_clause  =  NULL
   LET INT_FLAG = FALSE

   CALL fin85000_verifica_titulo_expo(mr_tela.cod_empresa , mr_tela.ies_tip_docum ) RETURNING l_status, l_msg
   IF l_status = TRUE THEN
      ERROR l_msg
      RETURN FALSE
   END IF

   IF mr_dados_pagto.portador1 IS NOT NULL AND
      mr_dados_pagto.portador1 <> ' ' THEN
      LET mr_tela.ies_forma_pgto   = mr_dados_pagto.forma_pgto
      LET mr_tela.cod_portador     = mr_dados_pagto.portador1
      LET mr_tela.ies_tip_portador = mr_dados_pagto.tip_portador1
      LET mr_tela.dat_credito      = ma_outros[1].dat_cred
      IF mr_tela.dat_credito IS NULL THEN
         LET mr_tela.dat_credito = p_par_cre.dat_proces_doc
      END IF
      IF m_tem_dados THEN
      ELSE
         CALL geo1017_busca_docum_aberto()
      END IF

      LET mr_tela.ies_abono_juros   = 'N'
      LET mr_tela.val_multa         =  0
      LET mr_tela.val_desp_cartorio =  0
      LET mr_tela.val_despesas      =  0
      LET mr_tela.val_glosa         =  0
      WHENEVER ERROR CONTINUE
      SELECT tip_pgto
        INTO mr_tela.ies_tip_pgto
        FROM wglosa
       WHERE empresa   = mr_tela.cod_empresa
         AND docum     = mr_tela.num_docum
         AND tip_docum = mr_tela.ies_tip_docum
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = 0 THEN
      END IF
      CALL geo1017_busca_val_glosa(mr_tela.cod_empresa,
                                    mr_tela.num_docum,
                                    mr_tela.ies_tip_docum) RETURNING l_val_glosa
      LET mr_tela.val_glosa = l_val_glosa

      CALL geo1017_carrega_dados_tela()

      DISPLAY BY NAME mr_tela.*
   ELSE
      CONSTRUCT BY NAME where_clause ON adocum_pgto.cod_empresa     ,
   		   		                              adocum_pgto.num_docum       ,
                                        adocum_pgto.ies_tip_docum   ,
                                        adocum_pgto.ies_tip_pgto    ,
                                        adocum_pgto.ies_forma_pgto  ,
                                        adocum_pgto.cod_portador    ,
                                        adocum_pgto.ies_tip_portador,
                                        adocum_pgto.dat_pgto        ,
                                        adocum_pgto.dat_credito

         BEFORE FIELD cod_empresa
            IF m_parametro[217] = "S" THEN
               DISPLAY p_cod_empresa TO cod_empresa
               NEXT FIELD NEXT
            END IF

         ON KEY (control-z, f4)
            CALL geo1017_zoom()

      END CONSTRUCT

      IF INT_FLAG THEN
         LET INT_FLAG = FALSE
         ERROR ' Consulta cancelada. '
         CLEAR FORM
         RETURN FALSE
      END IF

        LET sql_stmt =
         ' SELECT adocum_pgto.cod_empresa, ',
                ' adocum_pgto.num_docum, ',
                ' adocum_pgto.ies_tip_docum, ',
                ' adocum_pgto.ies_tip_pgto, ',
                ' adocum_pgto.ies_forma_pgto, ',
                ' adocum_pgto.cod_portador, ',
                ' adocum_pgto.ies_tip_portador, ',
                ' adocum_pgto.dat_pgto, ',
                ' adocum_pgto.dat_credito, ',
                ' adocum_pgto.dat_lanc, ',
                ' adocum_pgto.val_titulo, ',
                ' adocum_pgto.val_desc, ',
                ' adocum_pgto.val_juro, ',
                ' adocum_pgto.ies_abono_juros, ',
                ' adocum_pgto.val_desp_cartorio, ',
                ' adocum_pgto.val_despesas, ',
                ' adocum_pgto.val_multa, ',
                ' adocum_pgto.num_lote ',
           ' FROM adocum_pgto, docum, adocum_pgto_capa '              ,
          ' WHERE ', where_clause CLIPPED,' '

     IF m_parametro[217] = "S" THEN
        LET sql_stmt = sql_stmt CLIPPED," AND adocum_pgto.cod_empresa = '",p_cod_empresa,"' "
     END IF

     LET sql_stmt = sql_stmt CLIPPED,
         ' AND adocum_pgto.cod_empresa    = docum.cod_empresa ' ,
         ' AND adocum_pgto.num_docum      = docum.num_docum ',
         ' AND adocum_pgto.ies_tip_docum  = docum.ies_tip_docum ',
         ' AND adocum_pgto.ies_sit_docum  = "I" ',
         ' AND docum.ies_pgto_docum NOT IN ("T","C") ',
         ' AND docum.val_saldo  > 0 '                ,
         ' AND adocum_pgto.cod_portador = adocum_pgto_capa.cod_portador ',
         ' AND adocum_pgto.ies_tip_portador = adocum_pgto_capa.ies_tip_portador ',
         ' AND adocum_pgto.num_lote = adocum_pgto_capa.num_lote '

      IF m_arquivo_texto THEN
         IF Find4GLFunction("crey65_get_empresa_cre") THEN
            LET sql_stmt = sql_stmt CLIPPED," AND adocum_pgto.cod_empresa = '",crey65_get_empresa_cre(),"' ",
                                            " AND adocum_pgto.num_lote = '",crey65_get_num_lote_pgto(),"' ",
                                            " AND adocum_pgto.cod_portador = '",crey65_get_portador(),"' ",
                                            " AND adocum_pgto.ies_tip_portador = '",crey65_get_tip_portador(),"' "
         END IF
      END IF

      #::: Utilizado pelo Cliente 407 - Penske
      IF LOG_getVar("efetua_leitura_txt") THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND adocum_pgto.cod_empresa      = '", LOG_getVar( "codigo_empresa"   ) ,"' ",
                                          " AND adocum_pgto.num_lote         = '", LOG_getVar( "num_lote_pgto"    ) ,"' ",
                                          " AND adocum_pgto.cod_portador     = '", LOG_getVar( "codigo_portador"  ) ,"' ",
                                          " AND adocum_pgto.ies_tip_portador = '", LOG_getVar( "tipo_portador"    ) ,"' ",
                                          " AND adocum_pgto.ies_forma_pgto   = '", LOG_getVar( "forma_pagamento"  ) ,"' "
      END IF

      LET sql_stmt = sql_stmt CLIPPED, " ORDER BY docum.dat_vencto_s_desc, docum.cod_empresa "

      WHENEVER ERROR CONTINUE
      PREPARE var_query  FROM sql_stmt
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('PREPARE', 'VAR_QUERY')
      END IF

      WHENEVER ERROR CONTINUE
      DECLARE cq_docum SCROLL CURSOR WITH HOLD FOR var_query
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('DECLARE', 'CQ_DOCUM')
      END IF

      WHENEVER ERROR CONTINUE
      OPEN cq_docum
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('OPEN', 'CQ_DOCUM')
      END IF

      WHENEVER ERROR CONTINUE
      FETCH cq_docum INTO mr_tela.cod_empresa       ,
                          mr_tela.num_docum         ,
                          mr_tela.ies_tip_docum     ,
                          mr_tela.ies_tip_pgto      ,
                          mr_tela.ies_forma_pgto    ,
                          mr_tela.cod_portador      ,
                          mr_tela.ies_tip_portador  ,
                          mr_tela.dat_pgto          ,
                          mr_tela.dat_credito       ,
                          m_dat_lancamento          ,
                          mr_tela.val_saldo         ,
                          mr_tela.val_desc_conc     ,
                          mr_tela.val_juro_pago     ,
                          mr_tela.ies_abono_juros   ,
                          mr_tela.val_desp_cartorio ,
                          mr_tela.val_despesas      ,
                          mr_tela.val_multa         ,
                          m_num_lot

      WHENEVER ERROR STOP

      IF sqlca.sqlcode = 0 THEN
         MESSAGE ' Consulta efetuada com sucesso. ' ATTRIBUTE (REVERSE)
         LET m_consulta_ativa = TRUE
         CALL geo1017_carrega_p_docum(mr_tela.cod_empresa,
                                       mr_tela.num_docum,
                                       mr_tela.ies_tip_docum)
         CALL geo1017_gerencia_calc_juro(mr_tela.cod_empresa,
                                          mr_tela.dat_pgto,
                                          mr_tela.val_juro_pago,
                                          mr_tela.val_desc_conc)

         IF mr_tela.val_juro_pago IS NULL OR mr_tela.val_juro_pago = " " THEN
            LET mr_tela.val_juro_pago = 0
         END IF

         IF mr_tela.val_multa IS NULL OR mr_tela.val_multa = " " THEN
            LET mr_tela.val_multa = 0
         END IF

         IF NOT m_arquivo_texto THEN
            IF mr_dados_pagto.portador1 IS NULL OR
               mr_dados_pagto.portador1 <> ' ' OR
               mr_dados_pagto.dat_lanc IS NULL THEN
               CALL geo1017_busca_dat_proces()
            ELSE
               LET m_dat_lancamento = mr_dados_pagto.dat_lanc
            END IF
         END IF

         WHENEVER ERROR CONTINUE
          SELECT tip_pgto
            INTO mr_tela.ies_tip_pgto
            FROM wglosa
           WHERE empresa   = mr_tela.cod_empresa
             AND docum     = mr_tela.num_docum
             AND tip_docum = mr_tela.ies_tip_docum
         WHENEVER ERROR STOP
         IF sqlca.sqlcode = 0 THEN
         END IF
         CALL geo1017_busca_val_glosa(mr_tela.cod_empresa,
                                       mr_tela.num_docum,
                                       mr_tela.ies_tip_docum) RETURNING l_val_glosa

         LET mr_tela.val_glosa = l_val_glosa
         DISPLAY BY NAME mr_tela.*
         RETURN TRUE
      ELSE
         CLEAR FORM
         CALL log0030_mensagem(' Argumentos de pesquisa não encontrados. ','exclamation')
         RETURN FALSE
      END IF
   END IF
}
   RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION geo1017_paginacao(l_funcao)
#------------------------------------#

  DEFINE l_funcao             CHAR(010),
         l_ind                SMALLINT,
         l_val_glosa          DECIMAL(15,2)
{
   LET mr_telar.* = mr_tela.*
   INITIALIZE mr_tela.* TO NULL

   WHILE TRUE

     IF m_tem_dados THEN
        IF l_funcao = 'SEGUINTE' THEN
            WHENEVER ERROR CONTINUE
            FETCH cq_dados_abertos INTO mr_tela.cod_empresa,
                                        mr_tela.num_docum,
                                        mr_tela.ies_tip_docum,
                                        mr_tela.dat_pgto,
                                        mr_tela.val_saldo,
                                        mr_tela.val_desc_conc,
                                        mr_tela.val_juro_pago
            WHENEVER ERROR STOP
            IF sqlca.sqlcode = 0 THEN
               LET mr_tela.ies_abono_juros   = 'N'
               LET mr_tela.val_multa         =  0
               LET mr_tela.val_desp_cartorio =  0
               LET mr_tela.val_despesas      =  0
            END IF
        ELSE
           WHENEVER ERROR CONTINUE
           FETCH PREVIOUS cq_dados_abertos INTO mr_tela.cod_empresa,
                                                mr_tela.num_docum,
                                                mr_tela.ies_tip_docum,
                                                mr_tela.dat_pgto,
                                                mr_tela.val_saldo,
                                                mr_tela.val_desc_conc,
                                                mr_tela.val_juro_pago
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
              LET mr_tela.ies_abono_juros   = 'N'
              LET mr_tela.val_multa         =  0
              LET mr_tela.val_desp_cartorio =  0
              LET mr_tela.val_despesas      =  0
           END IF
        END IF
        LET mr_tela.ies_forma_pgto   = mr_dados_pagto.forma_pgto
        LET mr_tela.cod_portador     = mr_dados_pagto.portador1
        LET mr_tela.ies_tip_portador = mr_dados_pagto.tip_portador1
        LET mr_tela.dat_credito      = ma_outros[1].dat_cred
        CALL geo1017_busca_val_glosa(mr_tela.cod_empresa,
                                      mr_tela.num_docum,
                                      mr_tela.ies_tip_docum) RETURNING l_val_glosa
        LET mr_tela.val_glosa = l_val_glosa
        WHENEVER ERROR CONTINUE
         SELECT tip_pgto
           INTO mr_tela.ies_tip_pgto
           FROM wglosa
          WHERE empresa   = mr_tela.cod_empresa
            AND docum     = mr_tela.num_docum
            AND tip_docum = mr_tela.ies_tip_docum
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
        END IF
        IF sqlca.sqlcode = NOTFOUND THEN
           LET mr_tela.*  = mr_telar.*
           MESSAGE 'Não existem mais itens nesta direção.' ATTRIBUTE(REVERSE)
           DISPLAY BY NAME mr_tela.*
           EXIT WHILE
        END IF
        IF sqlca.sqlcode = 0 THEN
           CALL geo1017_carrega_dados_tela()
           DISPLAY BY NAME mr_tela.*
           EXIT WHILE
        END IF
     ELSE
        IF l_funcao = 'SEGUINTE' THEN
           WHENEVER ERROR CONTINUE
           FETCH cq_docum INTO mr_tela.cod_empresa       ,
                               mr_tela.num_docum         ,
                               mr_tela.ies_tip_docum     ,
                               mr_tela.ies_tip_pgto      ,
                               mr_tela.ies_forma_pgto    ,
                               mr_tela.cod_portador      ,
                               mr_tela.ies_tip_portador  ,
                               mr_tela.dat_pgto          ,
                               mr_tela.dat_credito       ,
                               m_dat_lancamento          ,
                               mr_tela.val_saldo         ,
                               mr_tela.val_desc_conc     ,
                               mr_tela.val_juro_pago     ,
                               mr_tela.ies_abono_juros   ,
                               mr_tela.val_desp_cartorio ,
                               mr_tela.val_despesas      ,
                               mr_tela.val_multa         ,
                               m_num_lot
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
           END IF
        ELSE
           WHENEVER ERROR CONTINUE
           FETCH PREVIOUS cq_docum INTO mr_tela.cod_empresa       ,
                                        mr_tela.num_docum         ,
                                        mr_tela.ies_tip_docum     ,
                                        mr_tela.ies_tip_pgto      ,
                                        mr_tela.ies_forma_pgto    ,
                                        mr_tela.cod_portador      ,
                                        mr_tela.ies_tip_portador  ,
                                        mr_tela.dat_pgto          ,
                                        mr_tela.dat_credito       ,
                                        m_dat_lancamento          ,
                                        mr_tela.val_saldo         ,
                                        mr_tela.val_desc_conc     ,
                                        mr_tela.val_juro_pago     ,
                                        mr_tela.ies_abono_juros   ,
                                        mr_tela.val_desp_cartorio ,
                                        mr_tela.val_despesas      ,
                                        mr_tela.val_multa         ,
                                        m_num_lot
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
           END IF
        END IF

        IF sqlca.sqlcode = NOTFOUND THEN
            MESSAGE 'Não existem mais itens nesta direção.' ATTRIBUTE(REVERSE)
            LET mr_tela.* = mr_telar.*
            DISPLAY BY NAME mr_tela.*
            EXIT WHILE
        END IF

        IF sqlca.sqlcode = 0 THEN

           WHENEVER ERROR CONTINUE
            SELECT *
             FROM adocum_pgto
            WHERE adocum_pgto.cod_portador      = mr_tela.cod_portador
              AND adocum_pgto.ies_tip_portador  = mr_tela.ies_tip_portador
              AND adocum_pgto.num_lote          = m_num_lot
              AND adocum_pgto.cod_empresa       = mr_tela.cod_empresa
              AND adocum_pgto.num_docum         = mr_tela.num_docum
              AND adocum_pgto.ies_sit_docum     = 'I'
           WHENEVER ERROR STOP

           IF sqlca.sqlcode= 0 THEN
              CALL geo1017_busca_val_glosa(mr_tela.cod_empresa,
                                            mr_tela.num_docum,
                                            mr_tela.ies_tip_docum) RETURNING l_val_glosa
              LET mr_tela.val_glosa = l_val_glosa
              WHENEVER ERROR CONTINUE
               SELECT tip_pgto
                 INTO mr_tela.ies_tip_pgto
                 FROM wglosa
                WHERE empresa   = mr_tela.cod_empresa
                  AND docum     = mr_tela.num_docum
                  AND tip_docum = mr_tela.ies_tip_docum
              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 0 THEN
              END IF
              DISPLAY BY NAME mr_tela.*
              LET m_informou_dados = TRUE
              EXIT WHILE
           END IF

        END IF

     END IF

   END WHILE
}
{
WHENEVER ERROR CONTINUE
 CLOSE cq_docum
  FREE cq_docum
WHENEVER ERROR STOP

WHENEVER ERROR CONTINUE
 CLOSE cq_dados_abertos
  FREE cq_dados_abertos
WHENEVER ERROR STOP
}

END FUNCTION

#------------------------------------#
 FUNCTION geo1017_cursor_for_update()
#------------------------------------#

  WHENEVER ERROR CONTINUE
  DECLARE cm_docum CURSOR FOR
   SELECT cod_portador     ,
          ies_tip_portador ,
          num_lote         ,
          cod_empresa      ,
          num_docum        ,
          ies_tip_docum    ,
          ies_sit_docum    ,
          ies_tip_pgto     ,
          ies_forma_pgto   ,
          dat_pgto         ,
          dat_credito      ,
          dat_lanc         ,
          val_titulo       ,
          val_juro         ,
          val_desc         ,
          val_abat         ,
          val_desp_cartorio,
          val_despesas     ,
          ies_abono_juros  ,
          val_multa        ,
          val_ir
     FROM adocum_pgto
    WHERE adocum_pgto.cod_empresa   = mr_tela.cod_empresa
      AND adocum_pgto.num_docum     = mr_tela.num_docum
      AND adocum_pgto.ies_tip_docum = mr_tela.ies_tip_docum
      AND adocum_pgto.num_lote      = m_num_lot
  FOR UPDATE
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("SELECT","ADOCUM_PGTO")
  END IF

  CALL log085_transacao('BEGIN')
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("BEGIN TRANSACTION","geo1017_CURSOR_FOR_UPDATE")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  OPEN cm_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('OPEN','CM_DOCUM')
  END IF

  WHENEVER ERROR CONTINUE
  FETCH cm_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('FETCH','CM_DOCUM')
  END IF

  CASE sqlca.sqlcode
    WHEN     0 RETURN TRUE
    WHEN  -250 CALL log0030_mensagem( ' Registro sendo atualizado por outro usuario. Aguarde e tente novamente. ','exclamation')
    WHEN   100 CALL log0030_mensagem( ' Registro não mais existe na tabela. Execute a CONSULTA novamente. ','exclamation')
    OTHERWISE  CALL log003_err_sql  ('LEITURA','ADOCUM_PGTO')
  END CASE
  CALL log085_transacao('ROLLBACK')

  RETURN FALSE

END FUNCTION
#------------------------------#
 FUNCTION geo1017_modificacao()
#------------------------------#
 DEFINE l_flag_update    SMALLINT,
        l_num_seq        INTEGER

 LET l_flag_update= FALSE

 IF geo1017_cursor_for_update() THEN
     LET mr_telar.* = mr_tela.*

     IF geo1017_entrada_dados('MODIFICACAO')  THEN

        CALL geo1017_guarda_valores()

        WHENEVER ERROR CONTINUE

        UPDATE adocum_pgto SET cod_portador         = mr_tela.cod_portador     ,
                               ies_tip_portador     = mr_tela.ies_tip_portador ,
                               num_lote             = m_num_lot                ,
                               cod_empresa          = mr_tela.cod_empresa      ,
                               num_docum            = mr_tela.num_docum        ,
                               ies_tip_docum        = mr_tela.ies_tip_docum    ,
                               ies_sit_docum        = 'I'                      ,
                               ies_tip_pgto         = mr_tela.ies_tip_pgto     ,
                               ies_forma_pgto       = mr_tela.ies_forma_pgto   ,
                               dat_pgto             = mr_tela.dat_pgto         ,
                               dat_credito          = mr_tela.dat_credito      ,
                               dat_lanc             = m_dat_lancamento         ,
                               val_titulo           = mr_tela.val_saldo        ,
                               val_juro             = mr_tela.val_juro_pago    ,
                               val_desc             = mr_tela.val_desc_conc    ,
                               val_abat             = '0'                      ,
                               val_desp_cartorio    = mr_tela.val_desp_cartorio,
                               val_despesas         = mr_tela.val_despesas     ,
                               ies_abono_juros      = mr_tela.ies_abono_juros  ,
                               val_multa            = mr_tela.val_multa        ,
                               val_ir               = '0'
          WHERE CURRENT OF cm_docum

        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0  THEN
           CALL log003_err_sql('MODIFICACAO','ADOCUM_PGTO')
           CALL log085_transacao('ROLLBACK')
        ELSE

           LET l_flag_update = TRUE

           WHENEVER ERROR CONTINUE
            UPDATE wmarcados
               SET dat_pgto  = mr_tela.dat_pgto,
                   val_saldo = mr_tela.val_saldo,
                   val_desc  = mr_tela.val_desc_conc,
                   val_juros = mr_tela.val_juro_pago
             WHERE empresa   = mr_tela.cod_empresa
               AND docum     = mr_tela.num_docum
               AND tip_docum = mr_tela.ies_tip_docum
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("UPDATE","WMARCADOS")
           END IF

           WHENEVER ERROR CONTINUE
            SELECT val_glosa
              FROM wglosa
             WHERE empresa       = mr_tela.cod_empresa
               AND docum         = mr_tela.num_docum
               AND tip_docum     = mr_tela.ies_tip_docum
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
              WHENEVER ERROR CONTINUE
              UPDATE wglosa SET val_glosa = mr_tela.val_glosa,
                                tip_pgto  = mr_tela.ies_tip_pgto
               WHERE empresa       = mr_tela.cod_empresa
                 AND docum         = mr_tela.num_docum
                 AND tip_docum     = mr_tela.ies_tip_docum
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                  CALL log003_err_sql("UPDATE","WGLOSA")
              END IF
           ELSE
              WHENEVER ERROR CONTINUE
                INSERT INTO wglosa VALUES (mr_tela.cod_empresa,
                                           mr_tela.num_docum,
                                           mr_tela.ies_tip_docum,
                                           mr_tela.ies_tip_pgto,
                                           mr_tela.val_glosa)
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                  CALL log003_err_sql("INSERT","WGLOSA")
              END IF
           END IF
        END IF

        IF sqlca.sqlcode = 0 AND l_flag_update = TRUE THEN
           CALL log085_transacao('COMMIT')
           IF sqlca.sqlcode = 0 THEN
              MESSAGE 'Modificação efetuada com sucesso' ATTRIBUTE(REVERSE)
           ELSE
           END IF
        END IF
     END IF
  END IF

END FUNCTION



#---------------------------#
 FUNCTION geo1017_listagem()
#---------------------------#
 DEFINE l_wcre1591       RECORD
        cod_empresa             LIKE docum_pgto.cod_empresa,
        num_docum               LIKE docum_pgto.num_docum,
        ies_tip_docum           LIKE docum_pgto.ies_tip_docum,
        num_seq_docum           LIKE docum_pgto.num_seq_docum,
        dat_pgto                LIKE docum_pgto.dat_pgto,
        val_pago                LIKE docum_pgto.val_pago,
        val_juro_pago           LIKE docum_pgto.val_juro_pago,
        val_desc_conc           LIKE docum_pgto.val_desc_conc,
        val_abat                LIKE docum_pgto.val_abat,
        mensagem                CHAR(70) #OS 606437
                         END RECORD

  INITIALIZE p_msg, l_wcre1591.* TO NULL

 { CALL log006_exibe_teclas('01','geo1017')
  CURRENT WINDOW IS w_geo1017

  MESSAGE ' Processando a extração do relatório ... ' ATTRIBUTE(REVERSE)

  IF g_ies_ambiente = 'W' THEN
     IF p_ies_impressao = 'S' THEN
        CALL log150_procura_caminho('LST') RETURNING p_caminho
        LET p_caminho = p_caminho CLIPPED, 'geo1017.tmp'
        START REPORT geo1017_relat TO p_caminho
     ELSE
        START REPORT geo1017_relat TO p_nom_arquivo
     END IF
  ELSE
     IF p_ies_impressao = 'S' THEN
        START REPORT geo1017_relat TO PIPE p_nom_arquivo
     ELSE
        START REPORT geo1017_relat TO p_nom_arquivo
     END IF
  END IF

 WHENEVER ERROR CONTINUE
 DECLARE cq_relat1 CURSOR FOR
  SELECT cod_empresa   ,
         num_docum     ,
         ies_tip_docum ,
         num_seq_docum ,
         dat_pgto      ,
         val_pago      ,
         val_juro_pago ,
         val_desc_conc ,
         val_abat      ,
         mensagem
    FROM wcre1591
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('SELECT','WCRE1591')
 END IF



  FOREACH cq_relat1 INTO l_wcre1591.*
  IF sqlca.sqlcode = 100 THEN

  END IF
    SELECT den_empresa
      INTO p_den_empresa
      FROM empresa
     WHERE cod_empresa = p_cod_empresa

    IF sqlca.sqlcode <> 0 THEN
       LET p_den_empresa = 'EMPRESA NÃO CADASTRADA.'
    END IF

    OUTPUT TO REPORT geo1017_relat(l_wcre1591.*)

  END FOREACH
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     MESSAGE "Não existem dados para serem listados." ATTRIBUTE(REVERSE)
  END IF

  WHENEVER ERROR CONTINUE
  CLOSE cq_relat1
  FREE cq_relat1
  WHENEVER ERROR STOP

  FINISH REPORT geo1017_relat


  WHENEVER ERROR CONTINUE
    SELECT cod_empresa
      FROM wcre1591
  WHENEVER ERROR STOP
  IF NOT sqlca.sqlcode = 100 THEN
     IF g_ies_ambiente = 'W' AND p_ies_impressao = 'S'  THEN
        LET m_comando = 'lpdos.bat ', p_caminho CLIPPED, ' ', p_nom_arquivo CLIPPED
        RUN m_comando
     END IF

     IF p_ies_impressao <> 'S' THEN
        LET p_msg = 'Relatório gravado no arquivo ',p_nom_arquivo CLIPPED,'.'
        CALL log0030_mensagem(p_msg,'info')
     ELSE
        CALL log0030_mensagem(' Impressão do relatório concluída ','info')
     END IF
  ELSE
     CALL log0030_mensagem('Não existem erros para serem listados. Caso a necessidade seja listar as baixas deste lote, utilize o CRE3800.','info')
  END IF
}
END FUNCTION

#-------------------------------#
 REPORT geo1017_relat(l_wcre1591)
#-------------------------------#

  DEFINE p_last_row             SMALLINT,
         l_wcre1591             RECORD
         cod_empresa                   LIKE docum_pgto.cod_empresa,
         num_docum                     LIKE docum_pgto.num_docum,
         ies_tip_docum                 LIKE docum_pgto.ies_tip_docum,
         num_seq_docum                 LIKE docum_pgto.num_seq_docum,
         dat_pgto                      LIKE docum_pgto.dat_pgto,
         val_pago                      LIKE docum_pgto.val_pago,
         val_juro_pago                 LIKE docum_pgto.val_juro_pago,
         val_desc_conc                 LIKE docum_pgto.val_desc_conc,
         val_abat                      LIKE docum_pgto.val_abat,
         mensagem                      CHAR(70) #OS 606437
                                END RECORD
  DEFINE l_val_glosa            DECIMAL(15,2)

  OUTPUT # REPORT TO 'geo1017.lst' #OS 606437
         LEFT MARGIN   0
         TOP MARGIN    0
         BOTTOM MARGIN 1
         PAGE LENGTH   66

    FORMAT
    {
    EMPRESA

    geo1017             LISTAGEM DE ERROS NA LIQUIDACAO                                 FL.    1

                                                          EXTRAIDO EM 03/06/2005 AS 09:44:59 HRS.

    EM DUPLICATA      TP SQ DATA PAGTO          VALOR PAGO          VALOR JURO     VALOR DESCONTO        VALOR GLOSA
    -- -------------- -- -- ---------- ------------------- ------------------- ------------------ ------------------
    01 XXXXXX         DP 01 02/06/2005             9999,99               99,99               9,99               9,99

    ***** ATENCAO - PARCELA MENOR EM ABERTO *****
    }


    PAGE HEADER
      PRINT log5211_retorna_configuracao(PAGENO,66,115) CLIPPED;
      PRINT p_den_empresa
      PRINT
      PRINT COLUMN 001, 'geo1017                         LISTAGEM DE ERROS NA LIQUIDACAO              ',
            COLUMN 105, 'FL. ', pageno USING '###&'
      SKIP 1 LINE
      PRINT COLUMN 074, 'EXTRAIDO EM ', TODAY ,  ' AS ', TIME , ' HRS.'
      SKIP 1 LINE
      PRINT COLUMN 001, 'EM DUPLICATA      TP SQ DATA PAGTO          VALOR PAGO          VALOR JURO     VALOR DESCONTO        VALOR GLOSA'
      PRINT COLUMN 001, '-- -------------- -- -- ---------- ------------------- ------------------- ------------------ ------------------'


    ON EVERY ROW
      PRINT COLUMN 001, l_wcre1591.cod_empresa,
            COLUMN 004, l_wcre1591.num_docum,
            COLUMN 019, l_wcre1591.ies_tip_docum,
            COLUMN 022, l_wcre1591.num_seq_docum     USING '##',
            COLUMN 025, l_wcre1591.dat_pgto          USING 'dd/mm/yyyy',
            COLUMN 036, l_wcre1591.val_pago          USING '####,###,###,##&.&&',
            COLUMN 056, l_wcre1591.val_juro_pago     USING '####,###,###,##&.&&',
            COLUMN 075, l_wcre1591.val_desc_conc     USING '####,###,###,##&.&&';
            IF geo1017_verifica_glosa(l_wcre1591.cod_empresa,
                                       l_wcre1591.num_docum,
                                       l_wcre1591.ies_tip_docum) THEN
               CALL geo1017_busca_val_glosa(l_wcre1591.cod_empresa,
                                             l_wcre1591.num_docum,
                                             l_wcre1591.ies_tip_docum) RETURNING l_val_glosa
               PRINT COLUMN 094, l_val_glosa               USING '####,###,###,##&.&&'
            ELSE
               LET l_val_glosa = 0
               PRINT COLUMN 094, l_val_glosa               USING '####,###,###,##&.&&'
            END IF
      PRINT COLUMN 001, l_wcre1591.mensagem

    ON LAST ROW
      LET p_last_row = TRUE

    PAGE TRAILER
      IF p_last_row = TRUE THEN
         PRINT '* * * ULTIMA FOLHA * * *'
      ELSE
          PRINT ' '
      END IF

END REPORT

#---------------------------------------#
 FUNCTION geo1017_consulta_port_corresp()
#---------------------------------------#
 INITIALIZE p_cod_port_corresp TO NULL

   WHENEVER ERROR CONTINUE
    SELECT cod_port_corresp
      INTO p_cod_port_corresp
      FROM port_corresp
     WHERE port_corresp.cod_portador = p_cod_portador
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION
#-----------------------------#
 FUNCTION geo1017_busca_conta()
#-----------------------------#
 DEFINE l_port_corresp     LIKE port_corresp.cod_port_corresp,
        l_empresa          LIKE creconc.cod_empresa,
        l_empresa_receb    LIKE portador_complemen.empresa_receb,
        l_utiliza_mutuo    LIKE portador_complemen.utiliza_mutuo,
        l_empresa_aux      LIKE empresa.cod_empresa

 INITIALIZE l_utiliza_mutuo, l_empresa_receb TO NULL

 LET l_empresa = pr_creconc.cod_empresa

 WHENEVER ERROR CONTINUE
 SELECT utiliza_mutuo,
        empresa_receb
   INTO l_utiliza_mutuo,
        l_empresa_receb
   FROM portador_complemen
  WHERE cod_portador     = p_cod_portador
    AND ies_tip_portador = "B"
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100  THEN
    CALL log003_err_sql('SELECT','PORTADOR_COMPLEMEN')
    RETURN FALSE
 END IF

 IF  sqlca.sqlcode = 0
 AND l_utiliza_mutuo = "S"
 AND l_empresa_receb IS NOT NULL THEN
    LET l_empresa = l_empresa_receb
 END IF

 IF l_utiliza_mutuo IS NULL
 OR l_utiliza_mutuo = "N" THEN
    CALL geo1017_busca_empresa_destino(l_empresa) RETURNING l_empresa_aux
    LET l_empresa = l_empresa_aux
 END IF

 IF (pr_creconc.ies_tip_docum IS NULL) THEN
    WHENEVER ERROR CONTINUE
       DECLARE cq_contas CURSOR FOR
        SELECT num_conta,
               num_agencia,
               ies_tip_docum
          FROM portador_banco
         WHERE cod_empresa   = l_empresa
           AND cod_portador  = p_cod_portador
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('DECLARE','CQ_CONTAS')
       RETURN FALSE
    END IF

    WHENEVER ERROR CONTINUE
       OPEN cq_contas
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('OPEN','CQ_CONTAS')
       RETURN FALSE
    END IF

    WHENEVER ERROR CONTINUE
       FETCH cq_contas
        INTO pr_creconc.num_conta       ,
             pr_creconc.agencia_bancaria,
             pr_creconc.ies_tip_docum
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('FETCH','CQ_CONTAS')
       RETURN FALSE
    END IF
    WHENEVER ERROR CONTINUE
    CLOSE cq_contas
    FREE cq_contas
    WHENEVER ERROR STOP

    INITIALIZE l_port_corresp TO NULL
    WHENEVER ERROR CONTINUE
       SELECT port_corresp.cod_port_corresp INTO l_port_corresp
         FROM port_corresp
        WHERE port_corresp.cod_portador = p_cod_portador
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       IF p_cod_portador > 999 THEN #
          LET m_msg = "Portador ", p_cod_portador CLIPPED, "não localizado no TRB0590"
          CALL log0030_mensagem(m_msg,"info")
          RETURN FALSE
       END IF
    ELSE
       LET p_cod_portador = l_port_corresp
    END IF

    WHENEVER ERROR CONTINUE
       SELECT agencia_bco.cod_banco
         FROM agencia_bco,agencia_bc_item
        WHERE agencia_bco.num_agencia        = pr_creconc.agencia_bancaria
          AND agencia_bco.cod_agen_bco       = agencia_bc_item.cod_agen_bco
          AND agencia_bco.cod_banco          = p_cod_portador
          AND agencia_bc_item.cod_empresa    = l_empresa
          AND agencia_bc_item.num_conta_banc = pr_creconc.num_conta
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       LET m_msg = "Conta/Agência não cadastradas no CONTAS A PAGAR "
       CALL log0030_mensagem(m_msg,"info")
       RETURN FALSE
    END IF

    IF (pr_creconc.num_conta IS NULL) THEN
       LET m_msg = "Conta não cadastrada no CRE0350 "
       CALL log0030_mensagem(m_msg,"info")
       RETURN FALSE
    ELSE
       RETURN TRUE
    END IF
 ELSE
    WHENEVER ERROR CONTINUE
       SELECT num_conta,
              num_agencia
         INTO pr_creconc.num_conta,
              pr_creconc.agencia_bancaria
         FROM portador_banco
        WHERE cod_empresa   = l_empresa
          AND cod_portador  = p_cod_portador
          AND ies_tip_docum = pr_creconc.ies_tip_docum
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET m_msg = "Conta não cadastrada no CRE0350 "
        CALL log0030_mensagem(m_msg,"info")
        RETURN FALSE
     END IF

     INITIALIZE l_port_corresp TO NULL
     WHENEVER ERROR CONTINUE
        SELECT port_corresp.cod_port_corresp INTO l_port_corresp
          FROM port_corresp
         WHERE port_corresp.cod_portador = p_cod_portador
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        IF p_cod_portador > 999 THEN
           LET m_msg = "Portador ", p_cod_portador CLIPPED, "não localizado no TRB0590"
           CALL log0030_mensagem(m_msg,"info")
           RETURN FALSE
        END IF
     ELSE
       LET p_cod_portador = l_port_corresp
     END IF

     WHENEVER ERROR CONTINUE
       SELECT agencia_bco.cod_banco
         FROM agencia_bco,agencia_bc_item
        WHERE agencia_bco.num_agencia        = pr_creconc.agencia_bancaria
          AND agencia_bco.cod_agen_bco       = agencia_bc_item.cod_agen_bco
          AND agencia_bco.cod_banco          = p_cod_portador
          AND agencia_bc_item.cod_empresa    = l_empresa
          AND agencia_bc_item.num_conta_banc = pr_creconc.num_conta
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       LET m_msg = "Conta/Agência não cadastradas no CONTAS A PAGAR "
       CALL log0030_mensagem(m_msg,"info")
       RETURN FALSE
    END IF

    IF pr_creconc.num_conta IS NULL THEN
       LET m_msg = "Conta não cadastrada no CRE0350 "
       CALL log0030_mensagem(m_msg,"info")
       RETURN FALSE
    ELSE
       RETURN TRUE
    END IF

 END IF

END FUNCTION

#-------------------------------------------------#
 FUNCTION geo1017_busca_empresa_destino(l_empresa)
#-------------------------------------------------#
 DEFINE l_empresa            LIKE empresa.cod_empresa
 DEFINE l_cod_empresa_destin LIKE emp_orig_destino.cod_empresa_destin

 WHENEVER ERROR CONTINUE
   SELECT cod_empresa_destin
     INTO l_cod_empresa_destin
     FROM emp_orig_destino
    WHERE emp_orig_destino.cod_empresa_orig = l_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 AND l_cod_empresa_destin IS NOT NULL THEN
    RETURN l_cod_empresa_destin
 ELSE
    RETURN l_empresa
 END IF

 END FUNCTION
#-----------------------------------------------------------------------------#
FUNCTION geo1017_grava_docum_obs_TRB(l_cod_empresa,l_num_docum,l_ies_tip_docum,
                                      l_tex_obs_1, l_tex_obs_2, l_tex_obs_3)
#-----------------------------------------------------------------------------#
 DEFINE l_cod_empresa    LIKE docum_obs.cod_empresa,
        l_num_docum      LIKE docum_obs.num_docum,
        l_ies_tip_docum  LIKE docum_obs.ies_tip_docum,
        l_tex_obs_1      LIKE docum_obs.tex_obs_1,
        l_tex_obs_2      LIKE docum_obs.tex_obs_2,
        l_tex_obs_3      LIKE docum_obs.tex_obs_3,
        l_num_seq_docum  LIKE docum_obs.num_seq_docum

 IF l_num_docum = 'MudarLoteDocum' THEN

    WHENEVER ERROR CONTINUE
     DECLARE cq_cursor4 CURSOR FOR
      SELECT DISTINCT empresa_docum,
                     num_docum    ,
                     ies_tip_docum
        FROM pgto_det
       WHERE cod_empresa       = mr_tela.cod_empresa
         AND cod_portador      = mr_tela.cod_portador
         AND ies_tip_portador  = mr_tela.ies_tip_portador
         AND num_lote          = m_num_lot
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('SELECT','PGTO_DET')
    END IF

    WHENEVER ERROR CONTINUE
     FOREACH cq_cursor4
        INTO l_cod_empresa  ,
             l_num_docum    ,
             l_ies_tip_docum
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('FOREACH','CQ_CURSOR4')
    END IF

       WHENEVER ERROR CONTINUE
       SELECT MAX(num_seq_docum)
         INTO l_num_seq_docum
         FROM docum_obs
        WHERE cod_empresa   = l_cod_empresa
          AND num_docum     = l_num_docum
          AND ies_tip_docum = l_ies_tip_docum
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql('SELECT','DOCUM_OBS')
       END IF

          IF l_num_seq_docum IS NULL
          OR l_num_seq_docum = 0 THEN
             LET l_num_seq_docum = 1
          ELSE
             LET l_num_seq_docum = l_num_seq_docum + 1
          END IF

          WHENEVER ERROR CONTINUE
          INSERT INTO docum_obs
               VALUES(l_cod_empresa,
                      l_num_docum,
                      l_ies_tip_docum,
                      l_num_seq_docum,
                      mr_dados_pagto.dat_lanc,
                      l_tex_obs_1,
                      l_tex_obs_2,
                      l_tex_obs_3,
                      TODAY)
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             IF cre1590_monta_wcre1591('Erro na gravação da observação dos títulos (DOCUM_OBS).') = FALSE THEN
                RETURN FALSE
             END IF
             EXIT FOREACH
          END IF

     END FOREACH

     WHENEVER ERROR CONTINUE
     CLOSE cq_cursor4
     FREE cq_cursor4
     WHENEVER ERROR STOP

 ELSE
    WHENEVER ERROR CONTINUE
     SELECT MAX(num_seq_docum)
       INTO l_num_seq_docum
       FROM docum_obs
      WHERE cod_empresa   = l_cod_empresa
        AND num_docum     = l_num_docum
        AND ies_tip_docum = l_ies_tip_docum
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('SELECT','DOCUM_OBS')
     END IF

     IF l_num_seq_docum IS NULL
     OR l_num_seq_docum = 0 THEN
        LET l_num_seq_docum = 1
     ELSE
        LET l_num_seq_docum = l_num_seq_docum + 1
     END IF

     WHENEVER ERROR CONTINUE
     INSERT INTO docum_obs
         VALUES(l_cod_empresa,
                l_num_docum,
                l_ies_tip_docum,
                l_num_seq_docum,
                mr_dados_pagto.dat_lanc,
                l_tex_obs_1,
                l_tex_obs_2,
                l_tex_obs_3,
                TODAY)
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        IF cre1590_monta_wcre1591('Erro na gravação da observação dos títulos (DOCUM_OBS).') = FALSE THEN
           RETURN FALSE
        END IF
     END IF

 END IF

END FUNCTION


#-------------------------------#
 FUNCTION geo1017_integra_trb()
#-------------------------------#
  DEFINE l_ind             SMALLINT

  DEFINE lr_creconc        RECORD LIKE creconc.*,
         p_num_sequencia   INTEGER,
         l_tex_obs_1       LIKE docum_obs.tex_obs_1,
         l_tex_obs_2       LIKE docum_obs.tex_obs_2,
         l_tex_obs_3       LIKE docum_obs.tex_obs_3,
         l_true_false      SMALLINT,
         l_existe_info_trb SMALLINT,
         l_mensagem        CHAR(80),
         p_sqlcode         SMALLINT

  DEFINE lr_param_trb   RECORD
         cod_empresa       LIKE creconc.cod_empresa,
         num_docum         LIKE creconc.num_docum,
         dat_emissao       LIKE creconc.dat_emissao
                        END RECORD

  DEFINE l_count           SMALLINT,
         l_portador_docum  LIKE docum.cod_portador

  INITIALIZE lr_creconc, p_num_sequencia, l_tex_obs_1, l_tex_obs_2    TO NULL
  INITIALIZE l_tex_obs_3, l_true_false, l_existe_info_trb, l_mensagem TO NULL
  INITIALIZE lr_param_trb.*                                           TO NULL
  INITIALIZE l_portador_docum TO NULL

  LET l_existe_info_trb = FALSE
  LET l_count           = 0
  LET m_val_desp_acum   = 0
  LET m_val_tarifa_acum = 0

  WHENEVER ERROR CONTINUE
    SELECT parametros[259,259], parametros[287,288], parametros[353,354]
      INTO p_ies_despesas, p_forma_desp, p_par_tip_docum
      FROM empresa_cre_txt
     WHERE cod_empresa = m_empresa_trb
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     LET p_ies_despesas = 'N'
  END IF

  WHENEVER ERROR CONTINUE
  DELETE FROM t_geo1017_1
   WHERE 1 = 1
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DELETE","T_geo1017_1-TEMP")
     RETURN
  END IF

   WHENEVER ERROR CONTINUE
     SELECT conc_pgto.cod_empresa,
            conc_pgto.num_lote,
            conc_pgto.cod_portador,
            conc_pgto.ies_tip_portador,
            conc_pgto.num_seq_conc,
            conc_pgto.num_lote_compl_1,
            conc_pgto.num_lote_compl_2,
            conc_pgto.num_lote_compl_3,
            conc_pgto.num_lote_compl_4,
            conc_pgto.num_lote_compl_5,
            conc_pgto.dat_cred,
            conc_pgto.val_concil,
            conc_pgto.deb_cred,
            conc_pgto.num_lote_trb
       INTO pr_conc_pgto_trb.cod_empresa,
            pr_conc_pgto_trb.num_lote,
            pr_conc_pgto_trb.cod_portador,
            pr_conc_pgto_trb.ies_tip_portador,
            pr_conc_pgto_trb.num_seq_conc,
            pr_conc_pgto_trb.num_lote_compl_1,
            pr_conc_pgto_trb.num_lote_compl_2,
            pr_conc_pgto_trb.num_lote_compl_3,
            pr_conc_pgto_trb.num_lote_compl_4,
            pr_conc_pgto_trb.num_lote_compl_5,
            pr_conc_pgto_trb.dat_cred,
            pr_conc_pgto_trb.val_concil,
            pr_conc_pgto_trb.deb_cred,
            pr_conc_pgto_trb.num_lote_trb
       FROM conc_pgto
      WHERE cod_empresa       = m_empresa_trb
        AND num_lote          = m_num_lot
        AND cod_portador      = mr_dados_pagto.portador1
        AND ies_tip_portador  = mr_dados_pagto.tip_portador1
        AND num_seq_conc      = m_num_seq_conc_trb
        AND (conc_pgto.num_lote_trb IS NULL OR conc_pgto.num_lote_trb = 0)
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 100 THEN
        LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
        LET l_tex_obs_2 = ''
        LET l_tex_obs_3 = ''

        CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                         'MudarLoteDocum', #pr_creconc.num_docum,
                                          pr_creconc.ies_tip_docum,
                                          l_tex_obs_1,
                                          l_tex_obs_2,
                                          l_tex_obs_3)
     END IF

     LET p_val_nc       = 0
     LET p_val_despesas = 0
     LET m_port_cre     = pr_conc_pgto_trb.cod_portador

     CALL geo1017_processa_lotes_compl()

     IF p_qtd_lotes >= 1 THEN

        FOR l_ind = 1 TO p_qtd_lotes

           IF m_diferenca IS NULL THEN
              LET m_diferenca = 0
           END IF

           IF m_diferenca_nc IS NULL THEN
              LET m_diferenca_nc = 0
           END IF

           IF l_ind = p_qtd_lotes THEN
              IF m_diferenca > 0 THEN
                 LET pr_conc_pgto_trb.val_concil = pr_conc_pgto_trb.val_concil - m_diferenca
              ELSE
                 IF m_diferenca <> 0 THEN
                    LET pr_conc_pgto_trb.val_concil = pr_conc_pgto_trb.val_concil + (m_diferenca * -1)
                 END IF
              END IF

              IF m_diferenca_nc > 0 THEN
                 LET p_val_nc = p_val_nc - m_diferenca_nc
              ELSE
                 IF m_diferenca_nc <> 0 THEN
                    LET p_val_nc = p_val_nc + (m_diferenca_nc * -1 )
                 END IF
              END IF
           END IF

           LET pr_creconc.cod_empresa      = pr_conc_pgto_trb.cod_empresa
           LET pr_creconc.cod_portador     = pr_conc_pgto_trb.cod_portador
           LET p_cod_portador              = pr_conc_pgto_trb.cod_portador
           LET pr_creconc.num_docum        = pr_conc_pgto_trb.num_lote
           LET pr_creconc.num_conta        = 0
           LET pr_creconc.val_docum        = pr_conc_pgto_trb.val_concil
           LET pr_creconc.dat_emissao      = pr_conc_pgto_trb.dat_cred
           LET pr_creconc.num_lote_conc    = 0
           LET pr_creconc.sequencia_lote   = 0
           LET pr_creconc.deb_cre          = 'C'

           IF geo1017_pesquisa_pgto_capa() THEN
              IF geo1017_busca_conta() THEN
                 IF geo1017_consulta_port_corresp() THEN
                    LET p_cod_portador = p_cod_port_corresp
                    LET pr_creconc.cod_portador = p_cod_portador
                 ELSE
                    IF p_cod_portador > 999 THEN
                       LET m_mensagem = 'Portador ',p_cod_portador CLIPPED, ' nao cadastrado na PORT_CORRESP'
                       CALL log0030_mensagem(m_mensagem, 'exclamation')

                       LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
                       LET l_tex_obs_2 = m_mensagem
                       LET l_tex_obs_3 = ''

                       CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                                        'MudarLoteDocum', #pr_creconc.num_docum,
                                                         pr_creconc.ies_tip_docum,
                                                         l_tex_obs_1,
                                                         l_tex_obs_2,
                                                         l_tex_obs_3)
                    ELSE
                       LET pr_creconc.cod_portador = p_cod_portador
                    END IF
                 END IF

                 #### PARAMETRO P/ NAO CONSIDERAR OS VALORES DE DESPESAS POR BANCO

                 CALL geo1017_busca_par_banc(mr_dados_pagto.portador1)

                 IF p_ja_sub_desp = FALSE THEN
                    IF p_par_banc_desp = 'S' THEN
                       CALL geo1017_busca_tarifa(pr_creconc.dat_emissao, m_port_cre)
                       LET pr_creconc.val_docum = pr_creconc.val_docum - p_val_tarifa
                    END IF
                 END IF

                 #### PARAMETRO P/ ADICIONAR O VALOR DA NC NA DP
                 IF p_par_banc_nc = 'S' THEN
                    LET pr_creconc.val_docum = pr_creconc.val_docum + p_val_nc
                 END IF

                 WHENEVER ERROR CONTINUE
                   SELECT COUNT(*)
                     INTO l_count
                     FROM trb_dp_fma_pagto
                    WHERE empresa_origem = pr_creconc.cod_empresa
                      AND fma_pagto      = m_ies_forma_pgto
                 WHENEVER ERROR STOP

                 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                    LET m_mensagem = 'PROBLEMA SELECT TRB_DP_FMA_PAGTO2 '
                    CALL log0030_mensagem(m_mensagem, 'exclamation')
                    LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
                    LET l_tex_obs_2 = m_mensagem
                    LET l_tex_obs_3 = ''

                    CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                                     'MudarLoteDocum', #pr_creconc.num_docum,
                                                      pr_creconc.ies_tip_docum,
                                                      l_tex_obs_1,
                                                      l_tex_obs_2,
                                                      l_tex_obs_3)
                 END IF

                 {Se existir sumarização para esta forma de pagamento, será
                  adicionado ao campo 'num_docum', a forma de pagamento}
                 IF l_count > 0 THEN
                    LET pr_creconc.num_docum = m_ies_forma_pgto, pr_creconc.num_docum
                 END IF

                 WHENEVER ERROR CONTINUE
                   INSERT INTO t_geo1017_1 (cod_empresa,
                                             cod_portador,
                                             num_docum,
                                             num_conta,
                                             agencia_bancaria,
                                             ies_tip_docum,
                                             val_docum,
                                             dat_emissao,
                                             num_lote_conc,
                                             sequencia_lote,
                                             deb_cre,
                                             sequencia,
                                             portador_docum)
                         VALUES(pr_creconc.cod_empresa       ,
                                pr_creconc.cod_portador      ,
                                pr_creconc.num_docum         ,
                                pr_creconc.num_conta         ,
                                pr_creconc.agencia_bancaria  ,
                                pr_creconc.ies_tip_docum     ,
                                pr_creconc.val_docum         ,
                                pr_creconc.dat_emissao       ,
                                pr_creconc.num_lote_conc     ,
                                pr_creconc.sequencia_lote    ,
                                pr_creconc.deb_cre           ,
                                pr_conc_pgto_trb.num_seq_conc,
                                pr_conc_pgto_trb.cod_portador)
                 WHENEVER ERROR STOP
                 IF sqlca.sqlcode <> 0 THEN
                    LET m_mensagem = 'PROBLEMA INSERT T_geo1017_1 '
                    CALL log0030_mensagem(m_mensagem, 'exclamation')
                    LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
                    LET l_tex_obs_2 = m_mensagem
                    LET l_tex_obs_3 = ''

                    CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                                     'MudarLoteDocum', #pr_creconc.num_docum,
                                                      pr_creconc.ies_tip_docum,
                                                      l_tex_obs_1,
                                                      l_tex_obs_2,
                                                      l_tex_obs_3)
                 ELSE
                    LET l_existe_info_trb = TRUE
                 END IF
              ELSE
                 LET l_existe_info_trb = FALSE
              END IF
           ELSE
              LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
              LET l_tex_obs_2 = m_mensagem
              LET l_tex_obs_3 = ''
              CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                               'MudarLoteDocum', #pr_creconc.num_docum,
                                                pr_creconc.ies_tip_docum,
                                                l_tex_obs_1,
                                                l_tex_obs_2,
                                                l_tex_obs_3)
           END IF
        END FOR
     ELSE
        LET pr_creconc.cod_empresa     = pr_conc_pgto_trb.cod_empresa
        LET pr_creconc.cod_portador    = pr_conc_pgto_trb.cod_portador
        LET p_cod_portador             = pr_conc_pgto_trb.cod_portador
        LET pr_creconc.num_docum       = pr_conc_pgto_trb.num_lote
        LET pr_creconc.num_conta       = 0
        LET pr_creconc.val_docum       = pr_conc_pgto_trb.val_concil
        LET pr_creconc.dat_emissao     = pr_conc_pgto_trb.dat_cred
        LET pr_creconc.deb_cre         = pr_conc_pgto_trb.deb_cred
        LET pr_creconc.num_lote_conc   = 0
        LET pr_creconc.sequencia_lote  = 0
        LET pr_creconc.deb_cre         = 'C'

        IF geo1017_pesquisa_pgto_capa() THEN
           IF geo1017_busca_conta() THEN
              IF geo1017_consulta_port_corresp() THEN
                 LET p_cod_portador = p_cod_port_corresp
                 LET pr_creconc.cod_portador = p_cod_portador
              ELSE
                 IF p_cod_portador > 999 THEN
                    LET m_mensagem = 'Portador ',mr_adocum_pgto.cod_portador CLIPPED, ' nao cadastrado na PORT_CORRESP'
                    CALL log0030_mensagem(m_mensagem, 'exclamation')
                    LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
                    LET l_tex_obs_2 = m_mensagem
                    LET l_tex_obs_3 = ''
                    CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                                      'MudarLoteDocum', #pr_creconc.num_docum,
                                                       pr_creconc.ies_tip_docum,
                                                       l_tex_obs_1,
                                                       l_tex_obs_2,
                                                       l_tex_obs_3)

                 ELSE
                    LET pr_creconc.cod_portador = p_cod_portador
                 END IF
              END IF

              #### PARAMETRO P/ NAO CONSIDERAR OS VALORES DE DESPESAS POR BANCO

              CALL geo1017_busca_par_banc(mr_adocum_pgto.cod_portador)
              IF p_ja_sub_desp = FALSE THEN
                 IF p_par_banc_desp = 'S' THEN
                    CALL geo1017_busca_tarifa(pr_creconc.dat_emissao, m_port_cre)
                    LET pr_creconc.val_docum  = pr_creconc.val_docum - p_val_tarifa
                 END IF
              END IF

              #### PARAMETRO P/ ADICIONAR O VALOR DA NC NA DP
              IF  p_par_banc_nc = 'S' THEN
                  CALL geo1017_busca_nc_conc(pr_conc_pgto_trb.num_lote, TRUE)
                  LET pr_creconc.val_docum = pr_creconc.val_docum + p_val_nc
              END IF

              LET l_count = 0

              {Verifica se existe efetua a sumarização por empresa
              para esta forma de pagamento.}
              WHENEVER ERROR CONTINUE
                SELECT COUNT(*)
                  INTO l_count
                  FROM trb_dp_fma_pagto
                 WHERE empresa_origem = pr_creconc.cod_empresa
                   AND fma_pagto      = m_ies_forma_pgto
              WHENEVER ERROR STOP

              IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                 LET m_mensagem = 'PROBLEMA SELECT TRB_DP_FMA_PAGTO1 '
                 CALL log0030_mensagem(m_mensagem, 'exclamation')
                 LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
                 LET l_tex_obs_2 = m_mensagem
                 LET l_tex_obs_3 = ''

                 CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                                  'MudarLoteDocum', #pr_creconc.num_docum,
                                                   pr_creconc.ies_tip_docum,
                                                   l_tex_obs_1,
                                                   l_tex_obs_2,
                                                   l_tex_obs_3)
              END IF

              {Se existir sumarização para esta forma de pagamento, será
               adicionado ao campo 'num_docum', a forma de pagamento}
              IF l_count > 0 THEN
                 LET pr_creconc.num_docum = m_ies_forma_pgto, pr_creconc.num_docum
              END IF

              WHENEVER ERROR CONTINUE
              INSERT INTO t_geo1017_1 (cod_empresa,
                                        cod_portador,
                                        num_docum,
                                        num_conta,
                                        agencia_bancaria,
                                        ies_tip_docum,
                                        val_docum,
                                        dat_emissao,
                                        num_lote_conc,
                                        sequencia_lote,
                                        deb_cre,
                                        sequencia,
                                        portador_docum)
                    VALUES(pr_creconc.cod_empresa       ,
                           pr_creconc.cod_portador      ,
                           pr_creconc.num_docum         ,
                           pr_creconc.num_conta         ,
                           pr_creconc.agencia_bancaria  ,
                           pr_creconc.ies_tip_docum     ,
                           pr_creconc.val_docum         ,
                           pr_creconc.dat_emissao       ,
                           pr_creconc.num_lote_conc     ,
                           pr_creconc.sequencia_lote    ,
                           pr_creconc.deb_cre           ,
                           pr_conc_pgto_trb.num_seq_conc,
                           pr_conc_pgto_trb.cod_portador)
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 LET m_mensagem = 'PROBLEMA INSERT T_geo1017_2 '
                 CALL log0030_mensagem(m_mensagem, 'exclamation')
                 LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
                 LET l_tex_obs_2 = m_mensagem
                 LET l_tex_obs_3 = ''

                 CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                                  'MudarLoteDocum', #pr_creconc.num_docum,
                                                   pr_creconc.ies_tip_docum,
                                                   l_tex_obs_1,
                                                   l_tex_obs_2,
                                                   l_tex_obs_3)
              ELSE
                 LET l_existe_info_trb = TRUE
              END IF
           ELSE
              LET l_existe_info_trb = FALSE
           END IF

        ELSE
           LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
           LET l_tex_obs_2 = m_mensagem
           LET l_tex_obs_3 = ''
           CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                            'MudarLoteDocum', #pr_creconc.num_docum,
                                             pr_creconc.ies_tip_docum,
                                             l_tex_obs_1,
                                             l_tex_obs_2,
                                             l_tex_obs_3)
        END IF
     END IF

     INITIALIZE pr_creconc.*, p_cod_portador TO NULL
####################################################################################

  IF l_existe_info_trb = TRUE THEN

     WHENEVER ERROR CONTINUE
     DECLARE cq_cursor3 CURSOR FOR
      SELECT cod_empresa     ,
             cod_portador    ,
             num_docum       ,
             num_conta       ,
             agencia_bancaria,
             ies_tip_docum   ,
             val_docum       ,
             dat_emissao     ,
             num_lote_conc   ,
             sequencia_lote  ,
             deb_cre         ,
             sequencia       ,
             portador_docum
        FROM t_geo1017_1
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","CQ_CURSOR3")
        RETURN
     END IF

     WHENEVER ERROR CONTINUE
     FOREACH cq_cursor3 INTO lr_creconc.cod_empresa     ,
                             lr_creconc.cod_portador    ,
                             lr_creconc.num_docum       ,
                             lr_creconc.num_conta       ,
                             lr_creconc.agencia_bancaria,
                             lr_creconc.ies_tip_docum   ,
                             lr_creconc.val_docum       ,
                             lr_creconc.dat_emissao     ,
                             lr_creconc.num_lote_conc   ,
                             lr_creconc.sequencia_lote  ,
                             lr_creconc.deb_cre         ,
                             p_num_sequencia            ,
                             l_portador_docum
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("FOREACH CURSOR","CQ_CURSOR3")
        EXIT FOREACH
     END IF

       WHENEVER ERROR CONTINUE
       INSERT INTO creconc
         VALUES (lr_creconc.cod_empresa,
                 lr_creconc.cod_portador,
                 lr_creconc.num_docum,
                 lr_creconc.num_conta,
                 lr_creconc.agencia_bancaria,
                 lr_creconc.ies_tip_docum,
                 lr_creconc.val_docum,
                 lr_creconc.dat_emissao,
                 0,
                 lr_creconc.sequencia_lote,
                 lr_creconc.deb_cre)

       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          LET p_sqlcode = sqlca.sqlcode
          CALL log003_err_sql('INCLUSAO', 'CRECONC')
          LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
          LET l_tex_obs_2 = 'ERRO DE INCLUSAO NA TABELA CRECONC'
          LET l_tex_obs_3 = 'SQLCODE = ', p_sqlcode

          CALL geo1017_grava_docum_obs_TRB(lr_creconc.cod_empresa,
                                            'MudarLoteDocum', #lr_creconc.num_docum,
                                            lr_creconc.ies_tip_docum,
                                            l_tex_obs_1,
                                            l_tex_obs_2,
                                            l_tex_obs_3)

          IF cre1590_monta_wcre1591('Erro na gravação da conciliação deste lote de baixa (CRECONC).') = FALSE THEN
             RETURN FALSE
          END IF

          LET l_true_false = FALSE
          EXIT FOREACH
       END IF

       LET lr_param_trb.cod_empresa = lr_creconc.cod_empresa
       LET lr_param_trb.num_docum   = lr_creconc.num_docum
       LET lr_param_trb.dat_emissao = lr_creconc.dat_emissao

       CALL trb112_integra_cre_trb(lr_param_trb.*) RETURNING l_true_false, l_mensagem

       IF l_true_false = FALSE THEN

          CALL log0030_mensagem(l_mensagem, 'exclamation')
          LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
          LET l_tex_obs_2 = 'ERRO NA FUNCAO TRB1120'
          LET l_tex_obs_3 = l_mensagem

          CALL geo1017_grava_docum_obs_TRB(lr_creconc.cod_empresa,
                                            'MudarLoteDocum', #lr_creconc.num_docum,
                                            lr_creconc.ies_tip_docum,
                                            l_tex_obs_1,
                                            l_tex_obs_2,
                                            l_tex_obs_3)
          EXIT FOREACH
       ELSE
          LET p_num_lote_concx = l_mensagem[1,5]
          LET p_num_lote_conc  = p_num_lote_concx USING '&&&&&'
          LET l_tex_obs_1 = 'EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO NO LOTE ', p_num_lote_conc
          LET l_tex_obs_2 = 'NA DATA ',TODAY,', AS ',TIME,' h '
          LET l_tex_obs_3 = 'PELO LOGIN ',p_user CLIPPED,' .'

          CALL geo1017_atualiza_conc_pgto(lr_creconc.cod_empresa,
                                           lr_creconc.num_docum,
                                           l_portador_docum,
                                           'B',
                                           p_num_sequencia)

         CALL geo1017_atualiza_t_nc()
       END IF
    END FOREACH

    IF l_true_false = TRUE THEN
       LET l_tex_obs_1 = 'EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO NO LOTE ', p_num_lote_conc
       LET l_tex_obs_2 = 'NA DATA ',TODAY,', AS ',TIME,' h '
       LET l_tex_obs_3 = 'PELO LOGIN ',p_user CLIPPED,' .'

       CALL geo1017_grava_docum_obs_TRB(lr_creconc.cod_empresa,
                                         'MudarLoteDocum', #lr_creconc.num_docum,
                                          lr_creconc.ies_tip_docum,
                                          l_tex_obs_1,
                                          l_tex_obs_2,
                                          l_tex_obs_3)

    END IF

 ELSE
    CALL log0030_mensagem('Não existem dados para conciliação bancária. ', 'exclamation')
 END IF

END FUNCTION

#----------------------------------------------------------------------------#
 FUNCTION geo1017_nc_origem_sup_e_vinc_dp(l_empresa, l_num_docum, l_tip_docum)
#----------------------------------------------------------------------------#
# Função retorna verdadeiro se a NC for originada no SUP e
# se tiver alguma DP vinculada (se a NC foi usada para dar
# desconto em alguma duplicata)

  DEFINE l_retorno SMALLINT
  DEFINE l_empresa   LIKE docum.cod_empresa,
         l_num_docum LIKE docum.num_docum,
         l_tip_docum LIKE docum.ies_tip_docum

  LET l_retorno = FALSE

  IF p_par_cre_txt.parametro[309] MATCHES '[sS]' THEN
     IF geo1017_nc_origem_sup(l_empresa, l_num_docum, l_tip_docum) THEN
        IF geo1017_nc_vinc_dp(l_empresa, l_num_docum, l_tip_docum) THEN
           LET l_retorno = TRUE
        END IF
     END IF
  END IF

  RETURN  l_retorno
END FUNCTION

#------------------------------------------------------------------#
 FUNCTION geo1017_nc_origem_sup(l_empresa, l_num_docum, l_tip_docum)
#------------------------------------------------------------------#
  DEFINE l_tex_obs_1       LIKE docum_obs.tex_obs_1,
         l_tex_obs_2       LIKE docum_obs.tex_obs_2,
         l_tex_obs_3       LIKE docum_obs.tex_obs_3
# Verifica se a Nota de Crédito foi criada pelo SUP
# Possui 2 finalidades:
# 1)
# Caso tenha sido criada pelo SUP, documentos desse tipo são ignorados
# da gravação do TRB.
# 2)
# Também usado para retornar a variável p_val_nc, com o valor bruto da NC,
# que é deduzido do valor da DP para criar o registro com o valor correto no TRB

  DEFINE l_empresa   LIKE docum.cod_empresa,
         l_num_docum LIKE docum.num_docum,
         l_tip_docum LIKE docum.ies_tip_docum

  LET m_val_nc_desc = 0

  WHENEVER ERROR CONTINUE
    SELECT docum.val_bruto
      INTO m_val_nc_desc
      FROM docum, par_sup_pad
     WHERE docum.cod_empresa         = l_empresa
       AND docum.num_docum           = l_num_docum
       AND docum.ies_tip_docum       = l_tip_docum
       AND par_sup_pad.cod_empresa   = docum.cod_empresa
       AND par_sup_pad.cod_parametro = 'cod_abat_cre'
       AND par_sup_pad.par_num       = docum.cod_deb_cred_cl
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  ELSE
     IF sqlca.sqlcode <> NOTFOUND THEN
        LET m_mensagem = 'PROBLEMA SELEÇÃO PAR_SUP_PAD '
        CALL log0030_mensagem(m_mensagem, 'exclamation')
        LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
        LET l_tex_obs_2 = m_mensagem
        LET l_tex_obs_3 = ''

        CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                         'MudarLoteDocum', #pr_creconc.num_docum,
                                          pr_creconc.ies_tip_docum,
                                          l_tex_obs_1,
                                          l_tex_obs_2,
                                          l_tex_obs_3)
        RETURN FALSE
     END IF

     RETURN FALSE
  END IF

END FUNCTION

#---------------------------------------------------------------#
 FUNCTION geo1017_nc_vinc_dp(l_empresa, l_num_docum, l_tip_docum)
#---------------------------------------------------------------#
# Função verifica se a NC foi usada para dedução do valor de alguma duplicata

  DEFINE l_empresa   LIKE docum.cod_empresa,
         l_num_docum LIKE docum.num_docum,
         l_tip_docum LIKE docum.ies_tip_docum

  DEFINE l_tex_obs_1       LIKE docum_obs.tex_obs_1,
         l_tex_obs_2       LIKE docum_obs.tex_obs_2,
         l_tex_obs_3       LIKE docum_obs.tex_obs_3

  WHENEVER ERROR CONTINUE
    SELECT cod_empresa
      FROM docum_posterior
     WHERE cod_empresa        = l_empresa
       AND num_docum          = l_num_docum
       AND ies_tip_docum      = l_tip_docum
       AND ies_tip_docum_post = 'DP'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  ELSE
     IF sqlca.sqlcode <> NOTFOUND THEN
        LET l_tex_obs_1 = "Erro na seleção da Duplicata Posterior a NC"
        LET l_tex_obs_2 = ''
        LET l_tex_obs_3 = ''
        CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                          'MudarLoteDocum', #pr_creconc.num_docum,
                                           pr_creconc.ies_tip_docum,
                                           l_tex_obs_1,
                                           l_tex_obs_2,
                                           l_tex_obs_3)

        LET p_wcre1581.des_mensagem = "Erro na seleção da Duplicata Posterior a NC"
        RETURN FALSE
     END IF

     RETURN FALSE
  END IF

END FUNCTION

#----------------------------------------------------------------------#
 FUNCTION geo1017_dp_possui_vinc_nc(l_empresa, l_num_docum, l_tip_docum)
#----------------------------------------------------------------------#
# Função verifica se a duplicata selecionada possui alguma
# Nota de crédito vinculada a ela, ou seja, que foi usada
# para deduzir o saldo devido da duplicata

  DEFINE l_retorno      SMALLINT,
         l_empresa   LIKE docum.cod_empresa,
         l_num_docum LIKE docum.num_docum,
         l_tip_docum LIKE docum.ies_tip_docum,
         l_empresa_nc   LIKE docum.cod_empresa,
         l_num_docum_nc LIKE docum.num_docum,
         l_tip_docum_nc LIKE docum.ies_tip_docum

  DEFINE l_tex_obs_1       LIKE docum_obs.tex_obs_1,
         l_tex_obs_2       LIKE docum_obs.tex_obs_2,
         l_tex_obs_3       LIKE docum_obs.tex_obs_3

  LET l_retorno      = FALSE
  LET m_val_nc_desc  = 0

  IF p_par_cre_txt.parametro[309] MATCHES '[sS]' THEN
     # Verifica se alguma NC foi usada na DP em questão
     WHENEVER ERROR CONTINUE
       SELECT cod_empresa, num_docum, ies_tip_docum
         INTO l_empresa_nc, l_num_docum_nc, l_tip_docum_nc
         FROM docum_posterior
        WHERE cod_empresa        = l_empresa
          AND num_docum_post     = l_num_docum
          AND ies_tip_docum_post = l_tip_docum
          AND ies_tip_docum      = 'NC'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
        # A função seta em m_val_nc_desc o valor bruto da NC
        IF geo1017_nc_origem_sup(l_empresa_nc, l_num_docum_nc, l_tip_docum_nc) THEN
           LET l_retorno = TRUE
        END IF
     ELSE
        IF sqlca.sqlcode <> NOTFOUND THEN

           LET m_mensagem = 'PROBLEMA SELEÇÃO PAR_SUP_PAD '
           CALL log0030_mensagem(m_mensagem, 'exclamation')
           LET l_tex_obs_1 = 'NAO FOI EFETUADA CONCILIACAO BANCARIA DO PAGTO DESTE DOCTO'
           LET l_tex_obs_2 = m_mensagem
           LET l_tex_obs_3 = ''

           CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                            'MudarLoteDocum', #pr_creconc.num_docum,
                                             pr_creconc.ies_tip_docum,
                                             l_tex_obs_1,
                                             l_tex_obs_2,
                                             l_tex_obs_3)
           RETURN FALSE
        END IF
     END IF
  END IF

  RETURN l_retorno

END FUNCTION

#-------------------------------------#
 FUNCTION geo1017_pesquisa_pgto_capa()
#-------------------------------------#
  DEFINE l_ies_proces_lote  LIKE pgto_capa.ies_proces_lote

  DEFINE l_tex_obs_1       LIKE docum_obs.tex_obs_1,
         l_tex_obs_2       LIKE docum_obs.tex_obs_2,
         l_tex_obs_3       LIKE docum_obs.tex_obs_3

    INITIALIZE m_ies_forma_pgto, m_mensagem TO NULL

    WHENEVER ERROR CONTINUE
    SELECT ies_forma_pgto, ies_proces_lote
      INTO m_ies_forma_pgto ,
           l_ies_proces_lote
      FROM pgto_capa
     WHERE pgto_capa.cod_empresa      = pr_conc_pgto_trb.cod_empresa
       AND pgto_capa.num_lote         = pr_conc_pgto_trb.num_lote
       AND pgto_capa.cod_portador     = pr_conc_pgto_trb.cod_portador
       AND pgto_capa.ies_tip_portador = pr_conc_pgto_trb.ies_tip_portador
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
    ELSE
       LET m_ies_forma_pgto  = ' '
       LET l_ies_proces_lote = ' '
    END IF

    LET m_mensagem = 'VALORES PAGOS NAO FECHAM COM VALOR DO LOTE'

    IF l_ies_proces_lote = 'S' THEN
       IF m_ies_forma_pgto = 'BC' OR m_ies_forma_pgto = 'CA' THEN
          IF geo1017_pesquisa_contas_aux() THEN
             RETURN TRUE
          ELSE
             RETURN FALSE
          END IF
       ELSE
          IF m_ies_forma_pgto = 'AD' THEN
             RETURN FALSE
          ELSE
             WHENEVER ERROR CONTINUE
               SELECT cod_empresa
                 FROM par_integ_trb
                WHERE par_integ_trb.cod_empresa = pr_conc_pgto_trb.cod_empresa
                  AND par_integ_trb.origem_docum = "R"
                  AND par_integ_trb.tipo_docum   = m_ies_forma_pgto
             WHENEVER ERROR STOP
             IF sqlca.sqlcode <> 0 THEN
                LET m_mensagem =  'FORMA ',m_ies_forma_pgto,' NAO PARAMETRIZADO PARA INTEGRACAO NA EMPRESA ',pr_conc_pgto_trb.cod_empresa
                RETURN FALSE
             ELSE
                IF geo1017_pesquisa_pgto_det() THEN
                   RETURN TRUE
                ELSE
                   RETURN FALSE
                END IF
             END IF
          END IF
       END IF
    ELSE
        RETURN FALSE
    END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION geo1017_pesquisa_contas_aux()
#-----------------------------------------#
 DEFINE l_ies_ctaux     CHAR(01),
        l_tot_contas    LIKE contas_aux.val_lancamento

 INITIALIZE l_ies_ctaux TO NULL

 LET l_tot_contas = 0

 WHENEVER ERROR CONTINUE
 SELECT empresa_cre_txt.parametros[6,6]
   INTO l_ies_ctaux
   FROM empresa_cre_txt
  WHERE empresa_cre_txt.cod_empresa = p_cod_empresa ### OS 590916
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = NOTFOUND  OR l_ies_ctaux IS NULL  OR   l_ies_ctaux   = ' ' THEN
    LET l_ies_ctaux = 'N'
 END IF

 IF l_ies_ctaux = 'N' THEN
    WHENEVER ERROR CONTINUE
     SELECT DISTINCT(contas_aux.val_lancamento)
        FROM contas_aux
       WHERE (contas_aux.cod_empresa        = pr_conc_pgto_trb.cod_empresa
         AND contas_aux.cod_portador        = pr_conc_pgto_trb.cod_portador
         AND contas_aux.ies_tip_portador    = pr_conc_pgto_trb.ies_tip_portador
         AND contas_aux.val_lancamento      = pr_conc_pgto_trb.val_concil
         AND contas_aux.num_lote            = pr_conc_pgto_trb.num_lote)
         AND contas_aux.num_lote NOT IN
     (SELECT DISTINCT(pgto_det.num_lote)
        FROM pgto_det
       WHERE pgto_det.cod_empresa      = contas_aux.cod_empresa
         AND pgto_det.num_lote         = contas_aux.num_lote
         AND pgto_det.cod_portador     = contas_aux.cod_portador
         AND pgto_det.ies_tip_portador = contas_aux.ies_tip_portador
         AND pgto_det.num_docum        = contas_aux.num_docum
         AND pgto_det.ies_tip_docum    = contas_aux.ies_tip_docum)
    WHENEVER ERROR STOP

    IF SQLCA.SQLCODE = 0 THEN
      RETURN TRUE
    ELSE
      RETURN FALSE
    END IF
 ELSE
    WHENEVER ERROR CONTINUE
    SELECT SUM(val_lancamento)
      INTO l_tot_contas
      FROM contas_aux
     WHERE contas_aux.cod_empresa       = pr_conc_pgto_trb.cod_empresa
       AND contas_aux.cod_portador      = pr_conc_pgto_trb.cod_portador
       AND contas_aux.ies_tip_portador  = pr_conc_pgto_trb.ies_tip_portador
       AND contas_aux.num_lote          = pr_conc_pgto_trb.num_lote
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
    ELSE
       LET l_tot_contas = 0
    END IF

    WHENEVER ERROR CONTINUE
    SELECT * FROM contas_aux
     WHERE (contas_aux.cod_empresa      = pr_conc_pgto_trb.cod_empresa
       AND contas_aux.cod_portador      = pr_conc_pgto_trb.cod_portador
       AND contas_aux.ies_tip_portador  = pr_conc_pgto_trb.ies_tip_portador
       AND contas_aux.val_lancamento    = l_tot_contas
       AND contas_aux.num_lote          = pr_conc_pgto_trb.num_lote)
       AND contas_aux.num_lote NOT IN
     (SELECT DISTINCT(pgto_det.num_lote)
        FROM pgto_det
       WHERE pgto_det.cod_empresa      = contas_aux.cod_empresa
         AND pgto_det.num_lote         = contas_aux.num_lote
         AND pgto_det.cod_portador     = contas_aux.cod_portador
         AND pgto_det.ies_tip_portador = contas_aux.ies_tip_portador
         AND pgto_det.num_docum        = contas_aux.num_docum
         AND pgto_det.ies_tip_docum    = contas_aux.ies_tip_docum)
     WHENEVER ERROR STOP

     IF sqlca.sqlcode = 0 THEN
        RETURN TRUE
     ELSE
        RETURN FALSE
     END IF
  END IF

END FUNCTION


#------------------------------------#
 FUNCTION geo1017_pesquisa_pgto_det()
#------------------------------------#

 DEFINE l_cont_conc             SMALLINT,
        l_tipo_desp             DECIMAL(1,0),
        l_val_tarifa_parc       LIKE docum.val_bruto,
        l_val_desp_parc         LIKE docum.val_bruto,
        p_val_concil            LIKE docum.val_bruto,
        p_val_pago              LIKE docum.val_bruto,
        l_val_desp              LIKE docum.val_bruto,
        l_val_desp1             LIKE docum.val_bruto,
        l_val_multa             LIKE docum.val_bruto,
        l_val_ir                LIKE docum.val_bruto,
        l_val_desp_tot          LIKE docum.val_bruto,
        l_pgtodet_empresa       LIKE pgto_det.cod_empresa,
        l_pgtodet_empresa_docum LIKE pgto_det.empresa_docum,
        l_pgtodet_num_seq       LIKE pgto_det.num_seq,
        l_empresa_trb           LIKE docum.cod_empresa,
        l_tot_contas            LIKE contas_aux.val_lancamento,
        l_ha_det                SMALLINT,
        l_cont                  SMALLINT,
        l_sql_stmt              CHAR(600)

  DEFINE l_tex_obs_1       LIKE docum_obs.tex_obs_1,
         l_tex_obs_2       LIKE docum_obs.tex_obs_2,
         l_tex_obs_3       LIKE docum_obs.tex_obs_3

 DEFINE l_tot_contas_negativas    LIKE contas_aux.val_lancamento,
        l_par_existencia          LIKE cre_cta_aux_compl.par_existencia,
        l_par_existencia2         LIKE cre_cta_aux_compl.par_existencia

 DEFINE l_num_seq INTEGER

 LET l_num_seq         = 0
 LET l_ha_det          = FALSE
 LET l_val_tarifa_parc = 0
 LET l_val_desp_parc   = 0
 LET p_val_titulo      = 0
 LET p_val_concil      = 0
 LET p_val_pago        = 0
 LET l_tot_contas      = 0
 LET l_val_desp        = 0
 LET l_val_desp1       = 0
 LET l_val_desp_tot    = 0
 LET m_val_pago_moeda  = 0
 LET m_val_desp1_moeda = 0
 LET l_val_multa       = 0
 LET l_val_ir          = 0

 INITIALIZE p_num_docum TO NULL

 WHENEVER ERROR CONTINUE
 SELECT SUM(val_concil),
        COUNT(*)
   INTO p_val_concil,
        l_cont_conc
   FROM conc_pgto
  WHERE conc_pgto.cod_empresa       = pr_conc_pgto_trb.cod_empresa
    AND conc_pgto.num_lote          = pr_conc_pgto_trb.num_lote
    AND conc_pgto.cod_portador      = pr_conc_pgto_trb.cod_portador
    AND conc_pgto.ies_tip_portador  = pr_conc_pgto_trb.ies_tip_portador
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
 END IF

 IF  p_ies_despesas = 'S' THEN
     LET l_tipo_desp = 2
 ELSE
     LET l_tipo_desp = 3
 END IF

 WHENEVER ERROR CONTINUE
   SELECT COUNT(*) INTO l_cont
     FROM cre_cncl_pagto_det
    WHERE empresa          = pr_conc_pgto_trb.cod_empresa
      AND lote             = pr_conc_pgto_trb.num_lote
      AND portador         = pr_conc_pgto_trb.cod_portador
      AND tip_portador     = pr_conc_pgto_trb.ies_tip_portador
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql('SELECT','CRE_CNCL_PAGTO_DET')
 END IF

 IF l_cont > 0 THEN
    LET l_sql_stmt = " SELECT empresa_docum FROM cre_cncl_pagto_det ",
                       "WHERE empresa      = """,pr_conc_pgto_trb.cod_empresa,""" ",
                        " AND lote         = """,pr_conc_pgto_trb.num_lote,""" ",
                        " AND portador     = """,pr_conc_pgto_trb.cod_portador,""" ",
                        " AND tip_portador = """,pr_conc_pgto_trb.ies_tip_portador,""" ",
                      " GROUP BY empresa_docum "
 ELSE
    LET l_sql_stmt = " SELECT cod_empresa FROM conc_pgto ",
                       "WHERE cod_empresa       = """,pr_conc_pgto_trb.cod_empresa,""" ",
                        " AND num_lote          = """,pr_conc_pgto_trb.num_lote,""" ",
                        " AND cod_portador      = """,pr_conc_pgto_trb.cod_portador,""" ",
                        " AND ies_tip_portador  = """,pr_conc_pgto_trb.ies_tip_portador,""" ",
                      " GROUP BY cod_empresa "
 END IF

 WHENEVER ERROR CONTINUE
  PREPARE var_query8 FROM l_sql_stmt
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('PREPARE','VAR_QUERY8')
 END IF

 WHENEVER ERROR CONTINUE
  DECLARE cq_cre_pagto_det CURSOR FOR var_query8
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('DECLARE','CQ_CRE_PAGTO_DET')
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_cre_pagto_det INTO m_cre_cncl_pagto_det.empresa_docum
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('FOREACH','CQ_CRE_PAGTO_DET')
 END IF

    WHENEVER ERROR CONTINUE
     DECLARE cq_pgto_det1 CURSOR FOR
      SELECT cod_empresa,
             empresa_docum,
             num_docum,
             ies_tip_docum,
             num_seq,
             (val_titulo + val_juro_pago - val_abat - val_desc),
             val_despesas,
             val_desp_cartorio,
             val_multa_paga,
             val_ir_pago
        FROM pgto_det
       WHERE pgto_det.num_lote         = pr_conc_pgto_trb.num_lote
         AND pgto_det.cod_portador     = pr_conc_pgto_trb.cod_portador
         AND pgto_det.ies_tip_portador = pr_conc_pgto_trb.ies_tip_portador
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('DECLARE','CQ_PGTO_DET1')
    END IF

    WHENEVER ERROR CONTINUE
        OPEN cq_pgto_det1
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('OPEN','CQ_PGTO_DET1')
    END IF

    WHENEVER ERROR CONTINUE
     FOREACH cq_pgto_det1 INTO l_pgtodet_empresa,
                               l_pgtodet_empresa_docum,
                               p_num_docum,
                               p_ies_tip_docum,
                               l_pgtodet_num_seq,
                               p_val_titulo,
                               l_val_desp,
                               l_val_desp1,
                               l_val_multa,
                               l_val_ir
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('FETCH','CQ_PGTO_DET1')
       EXIT FOREACH
    END IF

       IF l_tipo_desp = 2 THEN
          LET p_val_titulo = p_val_titulo + l_val_desp + l_val_desp1
       END IF

       WHENEVER ERROR CONTINUE
         SELECT parametro_texto
           INTO l_empresa_trb
           FROM cre_pagto_det_cpl
          WHERE empresa         = l_pgtodet_empresa
            AND lote            = pr_conc_pgto_trb.num_lote
            AND portador        = pr_conc_pgto_trb.cod_portador
            AND tip_portador    = pr_conc_pgto_trb.ies_tip_portador
            AND empresa_docum   = l_pgtodet_empresa_docum
            AND docum           = p_num_docum
            AND tip_docum       = p_ies_tip_docum
            AND seq_pagto_docum = l_pgtodet_num_seq
            AND campo_refer     = 'empresa_trb'
       WHENEVER ERROR STOP
       IF sqlca.sqlcode = 0 THEN
          LET m_cre_cncl_pagto_det.empresa_docum = l_pgtodet_empresa_docum
          IF l_empresa_trb <> pr_conc_pgto_trb.cod_empresa THEN
             CONTINUE FOREACH
          END IF
       ELSE
          IF l_pgtodet_empresa <> pr_conc_pgto_trb.cod_empresa OR
             l_pgtodet_empresa_docum <> m_cre_cncl_pagto_det.empresa_docum THEN
             CONTINUE FOREACH
          END IF
       END IF

       CALL geo1017_busca_sequencia_pagamento( l_pgtodet_empresa_docum      ,
                                                p_num_docum                  ,
                                                p_ies_tip_docum              ,
                                                pr_conc_pgto_trb.num_lote    )
          RETURNING l_num_seq

       IF geo1017_pesquisa_docum_pgto_trb( l_num_seq )THEN
          IF m_ies_ctr_moeda = "S" THEN
             WHENEVER ERROR CONTINUE
               SELECT docum.dat_emis
                 INTO m_dat_emissao
                 FROM docum
                WHERE docum.cod_empresa     = l_pgtodet_empresa_docum
                  AND docum.num_docum       = p_num_docum
                  AND docum.ies_tip_docum   = p_ies_tip_docum
             WHENEVER ERROR STOP
             IF sqlca.sqlcode <> 0 THEN
             END IF

             WHENEVER ERROR CONTINUE
               SELECT docum_txt.parametro
                 INTO mr_docum_txt.parametro
                 FROM docum_txt
                WHERE docum_txt.cod_empresa     = l_pgtodet_empresa_docum
                  AND docum_txt.num_docum       = p_num_docum
                  AND docum_txt.ies_tip_docum   = p_ies_tip_docum
             WHENEVER ERROR STOP
             IF sqlca.sqlcode <> 0
             OR mr_docum_txt.parametro[444,445] = "  "
             OR mr_docum_txt.parametro[444,445] IS NULL THEN
                LET m_cod_moeda = mr_par_con.cod_moeda_padrao
             ELSE
                LET m_cod_moeda = mr_docum_txt.parametro[444,445]
             END IF

             IF m_cod_moeda <> mr_par_con.cod_moeda_padrao THEN
                WHENEVER ERROR CONTINUE
                  SELECT val_cotacao INTO m_val_cotacao
                    FROM cotacao
                   WHERE cod_moeda = m_cod_moeda
                     AND dat_ref   = m_dat_emissao
                WHENEVER ERROR STOP
                IF sqlca.sqlcode <> 0 THEN
                   LET m_mensagem = "01 - Cotação da Moeda não encontrada"
                   CALL log0030_mensagem(m_mensagem, "exclamation")
                   LET l_tex_obs_1 = "NAO FOI EFETUADA CONCILIACAO BANCARIA DESTE DOCTO"
                   LET l_tex_obs_2 = m_mensagem
                   LET l_tex_obs_3 = ""
                   CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                                    "MudarLoteDocum",
                                                     pr_creconc.ies_tip_docum,
                                                     l_tex_obs_1,l_tex_obs_2,l_tex_obs_3)
                   RETURN FALSE
                ELSE
                   LET m_val_pago_moeda  = m_val_pago_moeda
                                        + (p_val_titulo * m_val_cotacao)
                   LET m_val_desp1_moeda = m_val_desp1_moeda
                                        + (l_val_desp   * m_val_cotacao)
                END IF
             ELSE LET m_val_pago_moeda  = m_val_pago_moeda  + p_val_titulo
                  LET m_val_desp1_moeda = m_val_desp1_moeda + l_val_desp
                  LET m_val_cotacao = 1
             END IF
          END IF
          LET p_val_pago     = p_val_pago + p_val_titulo + l_val_multa + l_val_ir
          LET l_val_desp_tot = l_val_desp_tot + l_val_desp + l_val_desp1
          LET pr_creconc.ies_tip_docum = p_ies_tip_docum

          IF l_tipo_desp <> 2 THEN
             LET p_val_pago = p_val_pago + l_val_desp + l_val_desp1
          END IF

       END IF

    END FOREACH

    WHENEVER ERROR CONTINUE
    FREE cq_pgto_det1
    WHENEVER ERROR STOP

    LET l_ha_det = TRUE

 END FOREACH

 IF l_ha_det = FALSE THEN
     RETURN FALSE
 END IF

 IF p_val_pago <> p_val_concil THEN

    #LET p_val_pago = p_val_pago - m_val_nc_desc_lote

    WHENEVER ERROR CONTINUE
     DECLARE cq_integrar_trb CURSOR FOR
      SELECT par_existencia
        FROM cre_cta_aux_compl
       WHERE empresa        = pr_conc_pgto_trb.cod_empresa
         AND portador       = pr_conc_pgto_trb.cod_portador
         AND tip_portador   = pr_conc_pgto_trb.ies_tip_portador
         AND lote           = pr_conc_pgto_trb.num_lote
         AND campo          = 'integrar_trb'
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('DECLARE CURSOR','CQ_INTEGRAR_TRB')
       RETURN FALSE
    END IF

    WHENEVER ERROR CONTINUE
        OPEN cq_integrar_trb
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('OPEN CURSOR','CQ_INTEGRAR_TRB')
       RETURN FALSE
    END IF

    WHENEVER ERROR CONTINUE
       FETCH cq_integrar_trb INTO l_par_existencia
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql('FETCH CURSOR','CQ_INTEGRAR_TRB')
       RETURN FALSE
    ELSE
       IF sqlca.sqlcode = 100 THEN
          WHENEVER ERROR CONTINUE
            SELECT SUM(val_lancamento)
              INTO l_tot_contas
              FROM contas_aux
             WHERE contas_aux.cod_empresa       = pr_conc_pgto_trb.cod_empresa
               AND contas_aux.cod_portador      = pr_conc_pgto_trb.cod_portador
               AND contas_aux.ies_tip_portador  = pr_conc_pgto_trb.ies_tip_portador
               AND contas_aux.num_lote          = pr_conc_pgto_trb.num_lote
               AND NOT EXISTS (
                       SELECT 0
                         FROM cre_cta_aux_compl
                        WHERE cre_cta_aux_compl.empresa        = pr_conc_pgto_trb.cod_empresa
                          AND cre_cta_aux_compl.portador       = pr_conc_pgto_trb.cod_portador
                          AND cre_cta_aux_compl.tip_portador   = pr_conc_pgto_trb.ies_tip_portador
                          AND cre_cta_aux_compl.lote           = pr_conc_pgto_trb.num_lote
                          AND cre_cta_aux_compl.sequencia_lote = contas_aux.num_seq
                          AND cre_cta_aux_compl.tip_docum      = contas_aux.ies_tip_docum
                          AND cre_cta_aux_compl.campo          = 'desconta_valor_do_trb'
                          AND cre_cta_aux_compl.par_existencia = 'S')
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
          END IF

          IF l_tot_contas IS NULL THEN
             LET l_tot_contas = 0
          END IF

          WHENEVER ERROR CONTINUE
            SELECT SUM(contas_aux.val_lancamento)
              INTO l_tot_contas_negativas
              FROM contas_aux, cre_cta_aux_compl
             WHERE contas_aux.cod_empresa           = pr_conc_pgto_trb.cod_empresa
               AND contas_aux.cod_portador          = pr_conc_pgto_trb.cod_portador
               AND contas_aux.ies_tip_portador      = pr_conc_pgto_trb.ies_tip_portador
               AND contas_aux.num_lote              = pr_conc_pgto_trb.num_lote
               AND cre_cta_aux_compl.empresa        = contas_aux.cod_empresa
               AND cre_cta_aux_compl.portador       = contas_aux.cod_portador
               AND cre_cta_aux_compl.tip_portador   = contas_aux.ies_tip_portador
               AND cre_cta_aux_compl.lote           = contas_aux.num_lote
               AND cre_cta_aux_compl.sequencia_lote = contas_aux.num_seq
               AND cre_cta_aux_compl.tip_docum      = contas_aux.ies_tip_docum
               AND cre_cta_aux_compl.campo          = 'desconta_valor_do_trb'
               AND cre_cta_aux_compl.par_existencia = 'S'
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
          END IF

          IF l_tot_contas_negativas IS NULL THEN
             LET l_tot_contas_negativas = 0
          END IF

          LET l_tot_contas = l_tot_contas - l_tot_contas_negativas
       ELSE
          WHENEVER ERROR CONTINUE
           DECLARE cq_contas_aux_tot CURSOR WITH HOLD FOR
            SELECT cod_empresa        , cod_portador       ,
                   ies_tip_portador   , num_lote           ,
                   num_seq            , ies_tip_docum      ,
                   num_docum          , num_cta_deb_reduz  ,
                   cod_his_deb        , des_cta_deb        ,
                   num_cta_cred_reduz , cod_his_cred       ,
                   des_cta_cred       , val_lancamento     ,
                   ies_lanc_cont      , num_lanc_cont
              FROM contas_aux
             WHERE contas_aux.cod_empresa      = pr_conc_pgto_trb.cod_empresa
               AND contas_aux.cod_portador     = pr_conc_pgto_trb.cod_portador
               AND contas_aux.ies_tip_portador = pr_conc_pgto_trb.ies_tip_portador
               AND contas_aux.num_lote         = pr_conc_pgto_trb.num_lote
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql('DECLARE CURSOR','CQ_CONTAS_AUX_TOT')
             RETURN FALSE
          END IF

          INITIALIZE mr_contas_aux TO NULL

          WHENEVER ERROR CONTINUE
          FOREACH cq_contas_aux_tot INTO mr_contas_aux.*
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql('FOREACH CURSOR','CQ_CONTAS_AUX_TOT')
             RETURN FALSE
          END IF

             IF l_par_existencia = 'S' AND l_par_existencia IS NOT NULL THEN

                WHENEVER ERROR CONTINUE
                 DECLARE cq_integrar_trb_2 CURSOR FOR
                  SELECT par_existencia
                    FROM cre_cta_aux_compl
                   WHERE empresa        = pr_conc_pgto_trb.cod_empresa
                     AND portador       = pr_conc_pgto_trb.cod_portador
                     AND tip_portador   = pr_conc_pgto_trb.ies_tip_portador
                     AND lote           = pr_conc_pgto_trb.num_lote
                     AND campo          = 'desconta_valor_do_trb'
                WHENEVER ERROR STOP
                IF sqlca.sqlcode <> 0 THEN
                   CALL log003_err_sql('DECLARE CURSOR','CQ_INTEGRAR_TRB_2')
                   RETURN FALSE
                END IF

                WHENEVER ERROR CONTINUE
                 FOREACH cq_integrar_trb_2 INTO l_par_existencia2
                WHENEVER ERROR STOP
                IF sqlca.sqlcode <> 0 THEN
                   CALL log003_err_sql('FOREACH CURSOR','CQ_INTEGRAR_TRB_2')
                   RETURN FALSE
                END IF

                   IF mr_contas_aux.val_lancamento IS NOT NULL THEN
                      LET l_tot_contas = l_tot_contas + mr_contas_aux.val_lancamento
                   END IF

                   IF l_par_existencia2 = 'S' AND l_par_existencia2 IS NOT NULL THEN

                      WHENEVER ERROR CONTINUE
                      SELECT SUM(contas_aux.val_lancamento)
                        INTO l_tot_contas_negativas
                        FROM contas_aux, cre_cta_aux_compl
                       WHERE contas_aux.cod_empresa           = pr_conc_pgto_trb.cod_empresa
                         AND contas_aux.cod_portador          = pr_conc_pgto_trb.cod_portador
                         AND contas_aux.ies_tip_portador      = pr_conc_pgto_trb.ies_tip_portador
                         AND contas_aux.num_lote              = pr_conc_pgto_trb.num_lote
                         AND cre_cta_aux_compl.empresa        = contas_aux.cod_empresa
                         AND cre_cta_aux_compl.portador       = contas_aux.cod_portador
                         AND cre_cta_aux_compl.tip_portador   = contas_aux.ies_tip_portador
                         AND cre_cta_aux_compl.lote           = contas_aux.num_lote
                         AND cre_cta_aux_compl.sequencia_lote = contas_aux.num_seq
                         AND cre_cta_aux_compl.tip_docum      = contas_aux.ies_tip_docum
                         AND cre_cta_aux_compl.campo          = 'desconta_valor_do_trb'
                         AND cre_cta_aux_compl.par_existencia = 'S'
                      WHENEVER ERROR STOP
                      IF sqlca.sqlcode <> 0 THEN
                         CALL log003_err_sql('SELECT','CONTAS_AUX')
                         RETURN FALSE
                      END IF

                      IF l_tot_contas_negativas IS NULL THEN
                         LET l_tot_contas_negativas = 0
                      END IF

                      LET l_tot_contas = l_tot_contas - l_tot_contas_negativas

                   ELSE

                      WHENEVER ERROR CONTINUE
                        SELECT SUM(contas_aux.val_lancamento)
                          INTO l_tot_contas_negativas
                          FROM contas_aux, cre_cta_aux_compl
                         WHERE contas_aux.cod_empresa           = pr_conc_pgto_trb.cod_empresa
                           AND contas_aux.cod_portador          = pr_conc_pgto_trb.cod_portador
                           AND contas_aux.ies_tip_portador      = pr_conc_pgto_trb.ies_tip_portador
                           AND contas_aux.num_lote              = pr_conc_pgto_trb.num_lote
                           AND cre_cta_aux_compl.empresa        = contas_aux.cod_empresa
                           AND cre_cta_aux_compl.portador       = contas_aux.cod_portador
                           AND cre_cta_aux_compl.tip_portador   = contas_aux.ies_tip_portador
                           AND cre_cta_aux_compl.lote           = contas_aux.num_lote
                           AND cre_cta_aux_compl.sequencia_lote = contas_aux.num_seq
                           AND cre_cta_aux_compl.tip_docum      = contas_aux.ies_tip_docum
                           AND cre_cta_aux_compl.campo          = 'desconta_valor_do_trb'
                           AND cre_cta_aux_compl.par_existencia = 'N'
                      WHENEVER ERROR STOP
                      IF sqlca.sqlcode <> 0 THEN
                         CALL log003_err_sql('select','contas_aux')
                         RETURN FALSE
                      END IF

                      IF l_tot_contas_negativas IS NULL THEN
                         LET l_tot_contas_negativas = 0
                      END IF

                      LET l_tot_contas = l_tot_contas + l_tot_contas_negativas

                   END IF

                END FOREACH

                WHENEVER ERROR CONTINUE
                FREE cq_integrar_trb_2
                WHENEVER ERROR STOP

             END IF

          END FOREACH

          WHENEVER ERROR CONTINUE
          FREE cq_contas_aux_tot
          WHENEVER ERROR STOP

       END IF
    END IF

    WHENEVER ERROR CONTINUE
    FREE cq_integrar_trb
    WHENEVER ERROR STOP

    IF p_par_tip_docum IS NOT NULL AND p_par_tip_docum <> "  " THEN
       LET pr_creconc.ies_tip_docum = p_par_tip_docum
    END IF

    LET p_val_pago = p_val_pago + l_tot_contas

 IF p_val_pago <> p_val_concil THEN

       LET m_mensagem = "01 - Há diferença no valor da conciliação do lote."
       CALL log0030_mensagem(m_mensagem, "exclamation")
       LET l_tex_obs_1 = "NAO FOI EFETUADA CONCILIACAO BANCARIA DESTE DOCTO"
       LET l_tex_obs_2 = m_mensagem
       LET l_tex_obs_3 = ""
       CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                        "MudarLoteDocum",
                                        pr_creconc.ies_tip_docum,
                                        l_tex_obs_1,l_tex_obs_2,l_tex_obs_3)
       RETURN FALSE
    END IF

    IF m_ies_ctr_moeda = "S" THEN
       IF p_val_pago = 0 THEN
          LET m_val_pago_moeda = m_val_pago_moeda + l_tot_contas
       ELSE
          WHENEVER ERROR CONTINUE
            SELECT val_cotacao INTO m_val_cotacao
              FROM cotacao
             WHERE cod_moeda = m_cod_moeda
               AND dat_ref   = pr_creconc.dat_emissao
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             LET m_mensagem = "03 - Cotação da Moeda não encontrada"
             CALL log0030_mensagem(m_mensagem, "exclamation")
             LET l_tex_obs_1 = "NAO FOI EFETUADA CONCILIACAO BANCARIA DESTE DOCTO"
             LET l_tex_obs_2 = m_mensagem
             LET l_tex_obs_3 = ""
             CALL geo1017_grava_docum_obs_TRB(pr_creconc.cod_empresa,
                                              "MudarLoteDocum",
                                              pr_creconc.ies_tip_docum,
                                              l_tex_obs_1,l_tex_obs_2,l_tex_obs_3)
             RETURN FALSE
          ELSE
             LET m_val_pago_moeda  = m_val_pago_moeda
                                  + (l_tot_contas * m_val_cotacao)
          END IF
       END IF
    ELSE
       LET m_val_cotacao = 1
    END IF
 END IF

 ###  SUBTRAI O VALOR DAS DESPESAS DO VALOR TOTAL DO LOTE  ###

 IF p_ies_despesas = 'N' THEN

    LET l_val_desp_parc = ((pr_conc_pgto_trb.val_concil / p_val_concil)
                         * l_val_desp_tot)

    IF l_cont_conc = pr_conc_pgto_trb.num_seq_conc THEN    #arredondamento
       LET l_val_desp_parc = l_val_desp_tot - m_val_desp_acum
       LET m_val_desp_acum = 0
    ELSE
       LET m_val_desp_acum = m_val_desp_acum + l_val_desp_parc
    END IF

    LET pr_creconc.val_docum = pr_conc_pgto_trb.val_concil - l_val_desp_parc

 END IF


 ###  SUBTRAI O VALOR DAS DESPESAS DO PAGAMENTO

 CALL geo1017_busca_par_banc(pr_conc_pgto_trb.cod_portador)

 IF p_par_banc_desp = 'S' THEN
    LET p_val_tarifa = 0
      WHENEVER ERROR CONTINUE
      SELECT SUM(val_despesas + val_desp_cartorio)
        INTO p_val_tarifa
        FROM pgto_det
       WHERE pgto_det.cod_empresa       = pr_conc_pgto_trb.cod_empresa
         AND pgto_det.num_lote          = pr_conc_pgto_trb.num_lote
         AND pgto_det.cod_portador      = pr_conc_pgto_trb.cod_portador
         AND pgto_det.ies_tip_portador  = pr_conc_pgto_trb.ies_tip_portador
         AND pgto_det.empresa_docum     = m_cre_cncl_pagto_det.empresa_docum
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 OR p_val_tarifa IS NULL THEN
         LET p_val_tarifa = 0
      ELSE
         LET l_val_tarifa_parc = ((pr_conc_pgto_trb.val_concil / p_val_concil)
                                * p_val_tarifa)
      END IF

      IF pr_conc_pgto_trb.num_seq_conc = l_cont_conc THEN   #arredondamento
         LET l_val_tarifa_parc = p_val_tarifa - m_val_tarifa_acum
         LET m_val_tarifa_acum = 0
      ELSE
         LET m_val_tarifa_acum = m_val_tarifa_acum + l_val_tarifa_parc
      END IF

      LET pr_creconc.val_docum = pr_creconc.val_docum - l_val_tarifa_parc
      LET p_ja_sub_desp = TRUE

 END IF

 RETURN TRUE

END FUNCTION

#-------------------------------------------------------------------------------------------------#
 FUNCTION geo1017_atualiza_docum_pgto_txt(l_cod_empresa,l_num_docum,l_ies_tip_docum,l_num_seq_docum)
#-------------------------------------------------------------------------------------------------#
 DEFINE l_cod_empresa    LIKE docum_obs.cod_empresa  ,
        l_num_docum      LIKE docum_obs.num_docum    ,
        l_ies_tip_docum  LIKE docum_obs.ies_tip_docum,
        l_num_seq_docum  INTEGER                     ,
        p_parametro LIKE docum_pgto_txt.parametros

 INITIALIZE p_parametro TO NULL

 WHENEVER ERROR CONTINUE
 SELECT parametros
   INTO p_parametro
   FROM docum_pgto_txt
  WHERE docum_pgto_txt.cod_empresa     = l_cod_empresa
    AND docum_pgto_txt.num_docum       = l_num_docum
    AND docum_pgto_txt.ies_tip_docum   = l_ies_tip_docum
    AND docum_pgto_txt.num_seq_docum   = l_num_seq_docum
 WHENEVER ERROR STOP

  IF sqlca.sqlcode = 0 THEN
     LET p_parametro[53,57] = p_num_lote_conc USING '&&&&&'

     WHENEVER ERROR CONTINUE
         UPDATE docum_pgto_txt
            SET docum_pgto_txt.parametros      = p_parametro
          WHERE docum_pgto_txt.cod_empresa     = l_cod_empresa
            AND docum_pgto_txt.num_docum       = l_num_docum
            AND docum_pgto_txt.ies_tip_docum   = l_ies_tip_docum
            AND docum_pgto_txt.num_seq_docum   = l_num_seq_docum
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('ATUALIZACAO','DOCUM_PGTO_TXT')
     END IF
  ELSE
    LET p_parametro[53,57] = p_num_lote_conc USING '&&&&&'

    WHENEVER ERROR CONTINUE
    INSERT INTO docum_pgto_txt
         VALUES (l_cod_empresa,
                 l_num_docum,
                 l_ies_tip_docum,
                 l_num_seq_docum,
                 p_parametro,
                 TODAY)
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('INCLUSAO','DOCUM_PGTO_TXT')
    END IF
 END IF

END FUNCTION

#--------------------------------------------------------------------------#
FUNCTION geo1017_atualiza_conc_pgto(l_cod_empresa,l_num_lote,l_cod_portador,
                                   l_ies_tip_portador, l_num_seq_conc)
#--------------------------------------------------------------------------#
 DEFINE l_cod_empresa       LIKE conc_pgto.cod_empresa,
        l_num_lote          LIKE conc_pgto.num_lote,
        l_cod_portador      LIKE conc_pgto.cod_portador,
        l_ies_tip_portador  LIKE conc_pgto.ies_tip_portador,
        l_num_seq_conc      LIKE conc_pgto.num_seq_conc


 WHENEVER ERROR CONTINUE
 UPDATE conc_pgto
    SET conc_pgto.num_lote_trb       = p_num_lote_conc
  WHERE conc_pgto.cod_empresa        = l_cod_empresa
    AND conc_pgto.num_lote           = l_num_lote
    AND conc_pgto.cod_portador       = l_cod_portador
    AND conc_pgto.ies_tip_portador   = l_ies_tip_portador
    AND conc_pgto.num_seq_conc       = l_num_seq_conc
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('ATUALIZACAO','CONC_PGTO')
 END IF

END FUNCTION


#---------------------------------#
 FUNCTION geo1017_atualiza_t_nc()
#---------------------------------#
 DEFINE l_nc_empresa      LIKE docum.cod_empresa   ,
        l_nc_docum        LIKE docum.num_docum     ,
        l_parametro       LIKE docum_txt.parametro

 INITIALIZE l_parametro   TO NULL

 WHENEVER ERROR CONTINUE
 DECLARE cq_t_nc CURSOR FOR
  SELECT *
    FROM t_nc
   GROUP BY cod_empresa, num_docum
 IF sqlca.sqlcode = 0 THEN
 END IF
 FOREACH cq_t_nc INTO l_nc_empresa, l_nc_docum
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
 END IF

     WHENEVER ERROR CONTINUE
     SELECT *
       FROM docum_txt
      WHERE docum_txt.cod_empresa     = l_nc_empresa
        AND docum_txt.num_docum       = l_nc_docum
        AND docum_txt.ies_tip_docum   = 'NC'
     WHENEVER ERROR STOP

     IF sqlca.sqlcode = 0 THEN

        WHENEVER ERROR CONTINUE
         SELECT parametro
           INTO l_parametro
           FROM docum_txt
          WHERE docum_txt.cod_empresa     = l_nc_empresa
            AND docum_txt.num_docum       = l_nc_docum
            AND docum_txt.ies_tip_docum   = 'NC'
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
        ELSE
           LET l_parametro = ' '
        END IF
        LET l_parametro[456,460] = p_num_lote_conc USING '&&&&&'

        WHENEVER ERROR CONTINUE
        UPDATE docum_txt
            SET docum_txt.parametro     = l_parametro
          WHERE docum_txt.cod_empresa   = l_nc_empresa
            AND docum_txt.num_docum     = l_nc_docum
            AND docum_txt.ies_tip_docum = 'NC'
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('ATUALIZACAO', 'DOCUM_TXT')
        END IF
     ELSE
        LET l_parametro[456,460] = p_num_lote_conc USING '&&&&&'

        WHENEVER ERROR CONTINUE
        INSERT INTO docum_txt VALUES (l_nc_empresa,
                                      l_nc_docum,
                                      'NC',
                                      l_parametro,
                                      TODAY)
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('INCLUSAO', 'DOCUM_TXT')
        END IF
     END IF

 END FOREACH

END FUNCTION


#------------------------------------------------------#
 FUNCTION geo1017_pesquisa_docum_pgto_trb( l_num_seq )
#------------------------------------------------------#
 DEFINE l_num_seq LIKE pgto_det.num_seq
    DEFINE l_tipo_desp       DECIMAL(1,0)

    IF  p_ies_despesas = 'S' THEN
        LET l_tipo_desp = 2
    ELSE
        LET l_tipo_desp = 3
    END IF

  # 478820
  # Se for DP e tiver NC vinculada, subtrai o valor da NC
  # O valor da NC foi calculado na funcoes chamadas por nc_origem_sup
  # Se for tipo NC, efetua a validação para ignorar ou não documentos do tipo NC

    CASE p_ies_tip_docum
       WHEN 'DP'
          IF l_num_seq = 1 THEN
             IF geo1017_dp_possui_vinc_nc(m_cre_cncl_pagto_det.empresa_docum, p_num_docum, p_ies_tip_docum) THEN
                #LET m_val_nc_desc_lote = m_val_nc_desc_lote + m_val_nc_desc
             END IF
          END IF

       WHEN 'NC'

          IF l_num_seq = 1 THEN
             IF geo1017_nc_origem_sup_e_vinc_dp(m_cre_cncl_pagto_det.empresa_docum, p_num_docum, p_ies_tip_docum) THEN
                RETURN FALSE
             END IF
          END IF
    END CASE

    CASE l_tipo_desp
       WHEN 2
            WHENEVER ERROR CONTINUE
            DECLARE cq_docum1 CURSOR FOR
             SELECT num_docum
               FROM docum_pgto
              WHERE docum_pgto.cod_empresa      = m_cre_cncl_pagto_det.empresa_docum
                AND docum_pgto.num_docum        = p_num_docum
                AND docum_pgto.ies_tip_docum    = p_ies_tip_docum
                AND (docum_pgto.val_pago + docum_pgto.val_despesas + docum_pgto.val_desp_cartorio)
                                                = p_val_titulo
                AND docum_pgto.cod_portador     = pr_conc_pgto_trb.cod_portador
                AND docum_pgto.ies_tip_portador = pr_conc_pgto_trb.ies_tip_portador
                AND docum_pgto.num_lote_pgto    = pr_conc_pgto_trb.num_lote
              IF sqlca.sqlcode = 0 THEN
              END IF
              OPEN cq_docum1
              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql('OPEN','CQ_DOCUM1')
                 RETURN FALSE
              END IF
              FETCH cq_docum1
              IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                 CALL log003_err_sql('FETCH','CQ_DOCUM1')
                 RETURN FALSE
              END IF

              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 0 THEN
                  CLOSE cq_docum1
                   FREE cq_docum1
                 RETURN TRUE
              ELSE
                  CLOSE cq_docum1
                   FREE cq_docum1
                 RETURN FALSE
              END IF


       OTHERWISE

            WHENEVER ERROR CONTINUE
            DECLARE cq_docum2 CURSOR FOR
             SELECT num_docum
               FROM docum_pgto
              WHERE docum_pgto.cod_empresa      = m_cre_cncl_pagto_det.empresa_docum
                AND docum_pgto.num_docum        = p_num_docum
                AND docum_pgto.ies_tip_docum    = p_ies_tip_docum
                AND docum_pgto.val_pago         = p_val_titulo
                AND docum_pgto.cod_portador     = pr_conc_pgto_trb.cod_portador
                AND docum_pgto.ies_tip_portador = pr_conc_pgto_trb.ies_tip_portador
                AND docum_pgto.num_lote_pgto    = pr_conc_pgto_trb.num_lote
              IF sqlca.sqlcode = 0 THEN
              END IF
            OPEN cq_docum2
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql('OPEN','CQ_DOCUM2')
               RETURN FALSE
            END IF
            FETCH cq_docum2
            IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
               CALL log003_err_sql('FETCH','CQ_DOCUM2')
               RETURN FALSE
            END IF
            WHENEVER ERROR STOP
            IF sqlca.sqlcode = 0 THEN
               CLOSE cq_docum2
               FREE cq_docum2
               RETURN TRUE
            ELSE
               CLOSE cq_docum2
               FREE cq_docum2
               RETURN FALSE
            END IF

       END CASE
END FUNCTION
#-------------------------------#
FUNCTION geo1017_docum_existe()
#-------------------------------#
 WHENEVER ERROR CONTINUE
   SELECT num_docum
     FROM adocum_pgto
    WHERE adocum_pgto.cod_empresa   = mr_tela.cod_empresa
      AND adocum_pgto.num_docum     = mr_tela.num_docum
      AND adocum_pgto.ies_tip_docum = mr_tela.ies_tip_docum
      AND adocum_pgto.num_lote      = m_num_lot
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql('SELECT','ADOCUM_PGTO')
     RETURN FALSE
  ELSE
     IF sqlca.sqlcode = 0 THEN
        RETURN TRUE
     ELSE
        RETURN FALSE
      END IF
   END IF

END FUNCTION
#-------------------------------------#
 FUNCTION geo1017_busca_documentos()
#-------------------------------------#
 DEFINE l_sql_stmt            CHAR(5000),
        l_sql_where           CHAR(5000),
        l_valor_selecao       DECIMAL(15,2),
        l_inicializa          INTEGER,
        l_cont                INTEGER,
        l_dat_vencto          DATE,
        l_dat_prorrogada      DATE,
        l_cod_cliente         LIKE docum.cod_cliente,
        l_nom_cliente         LIKE clientes.nom_cliente,
        l_desabilita_contrato SMALLINT,
        l_status              SMALLINT

 DEFINE l_ies_tip_cobr        LIKE docum.ies_tip_cobr
 DEFINE l_cod_portador        LIKE docum.cod_portador
 DEFINE l_val_saldo_cliente   LIKE cre_tit_cob_esp.val_parcela_cliente

 DEFINE l_arr_curr            SMALLINT
 DEFINE l_scr_line            SMALLINT
 DEFINE l_arr_count           SMALLINT

 INITIALIZE ma_outros TO NULL

 LET l_valor_selecao = 0

 LET l_sql_stmt =
 " SELECT docum.cod_empresa,       ",
        " docum.num_docum,         ",
        " docum.ies_tip_docum,     ",
        " docum.val_saldo,         ",
        " docum.dat_vencto_s_desc, ",
        " docum.dat_prorrogada,    ",
        " docum.ies_tip_cobr,      ",
        " docum.cod_portador,      ",
        " docum.cod_cliente,       ",
        " clientes.nom_cliente     "

 LET l_sql_stmt = l_sql_stmt CLIPPED," FROM docum, clientes "

 LET l_sql_where =
  " WHERE docum.val_saldo         > 0   ",
    " AND docum.ies_pgto_docum   <> 'T' ",
    " AND docum.ies_situa_docum  <> 'C' ",
    " AND docum.cod_cliente       = clientes.cod_cliente ",
    " AND docum.ies_tip_docum    NOT IN (SELECT cre_tip_doc_compl.tip_docum ",
                                         " FROM  cre_tip_doc_compl ",
                                         " WHERE cre_tip_doc_compl.empresa = docum.cod_empresa ",
                                         " AND cre_tip_doc_compl.campo = 'titulo_exportacao' ",
                                         " AND par_existencia = 'S' )"

 IF m_parametro[217] = "S" THEN
    LET l_sql_where = l_sql_where CLIPPED, " AND docum.cod_empresa = '",p_cod_empresa,"' "
 END IF

 IF where_clause IS NOT NULL THEN
    LET l_sql_where = l_sql_where CLIPPED, " AND ", where_clause CLIPPED
 END IF

 IF LOG_existe_epl("cre0360y_monta_where_clause_docum") THEN

    CALL LOG_setVar("where_clause_docum", " " )

    CALL cre0360y_monta_where_clause_docum()

    LET l_sql_where = l_sql_where CLIPPED, LOG_getVar( "where_clause_docum" )

 END IF

  WHENEVER ERROR CONTINUE
    SELECT COUNT(*)
      INTO l_cont
      FROM cre0270_clientes
     WHERE cre0270_clientes.nom_usuario   = p_user
       AND cre0270_clientes.cod_programa  = p_nom_programa
  WHENEVER ERROR STOP
     IF l_cont > 0 THEN
         #Tabela worder_cli é temporaria e criada pela funcao cre0270 para
         #armazenar a ordem de clientes digitada pelo usuario.
         LET l_sql_stmt  = l_sql_stmt  CLIPPED, ", cre0270_clientes, worder_cli"
         LET l_sql_where = l_sql_where CLIPPED,
         " AND cre0270_clientes.nom_usuario   = """,p_user,""" ",
         " AND cre0270_clientes.cod_programa  = """,p_nom_programa,""" ",
         " AND cre0270_clientes.cod_cliente   = docum.cod_cliente ",
         " AND worder_cli.cod_cliente         = cre0270_clientes.cod_cliente "
     END IF

     IF mr_consulta_aux.tipo_ordenacao = "2" THEN
        IF l_cont > 0 THEN
           LET l_sql_where = l_sql_where CLIPPED, " ORDER BY worder_cli.indice, ",
                                                           " docum.dat_vencto_s_desc, ",
                                                           " docum.num_docum, ",
                                                           " docum.ies_tip_docum "
        ELSE
           LET l_sql_where = l_sql_where CLIPPED, " ORDER BY docum.cod_cliente, ",
                                                           " docum.dat_vencto_s_desc, ",
                                                           " docum.num_docum, ",
                                                           " docum.ies_tip_docum "
        END IF
     ELSE
        LET l_sql_where = l_sql_where CLIPPED, " ORDER BY docum.dat_vencto_s_desc, ",
                                                        " docum.num_docum, ",
                                                        " docum.ies_tip_docum "
     END IF

 LET l_sql_stmt = l_sql_stmt CLIPPED, l_sql_where CLIPPED
 LET m_ind = 1

 WHENEVER ERROR CONTINUE
 PREPARE l_var_query FROM l_sql_stmt
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('PREPARE','L_VAR_QUERY ')
 END IF
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 DECLARE cq_documento CURSOR FOR l_var_query
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('DECLARE','CQ_DOCUMENTO')
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_documento
    INTO ma_principal[m_ind].empresa  ,
         ma_principal[m_ind].docum    ,
         ma_principal[m_ind].tip_docum,
         ma_principal[m_ind].val_saldo,
         l_dat_vencto                 ,
         l_dat_prorrogada             ,
         l_ies_tip_cobr               ,
         l_cod_portador               ,
         l_cod_cliente                ,
         l_nom_cliente
 WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('FOREACH','CQ_DOCUMENTO')
    END IF

    IF l_dat_prorrogada IS NOT NULL AND l_dat_prorrogada <> " " THEN
       LET ma_principal_obs[m_ind].observacao = "Vencimento: ", l_dat_prorrogada, " Cliente: ", l_cod_cliente CLIPPED, " - ", l_nom_cliente
    ELSE
       LET ma_principal_obs[m_ind].observacao = "Vencimento: ", l_dat_vencto, " Cliente: ", l_cod_cliente CLIPPED, " - ", l_nom_cliente
    END IF

    IF l_ies_tip_cobr = "V" AND l_cod_portador > 0 THEN
       CALL geo1017_busca_cre_tit_cob_esp(ma_principal[m_ind].empresa  ,
                                           ma_principal[m_ind].docum    ,
                                           ma_principal[m_ind].tip_docum,
                                           l_ies_tip_cobr)
       RETURNING l_val_saldo_cliente
    ELSE
       LET l_val_saldo_cliente = 0
    END IF

    IF l_val_saldo_cliente > 0 THEN
       LET ma_principal[m_ind].val_saldo = l_val_saldo_cliente
    END IF

    CALL geo1017_verifica_docum_equalizacao(ma_principal[m_ind].empresa  ,
                                             ma_principal[m_ind].docum    ,
                                             ma_principal[m_ind].tip_docum,
                                             ma_principal[m_ind].val_saldo,
                                             FALSE)
         RETURNING ma_principal[m_ind].val_saldo, l_status

    IF l_status = FALSE THEN
       INITIALIZE ma_principal[m_ind].* TO NULL
    ELSE
       LET m_ind = m_ind + 1
    END IF

    IF m_ind > 4000 THEN
       CALL log0030_mensagem('Não foi possível apresentar todos os documentos.','exclamation')
       EXIT FOREACH
    END IF
 END FOREACH

 IF m_ind > 1 THEN
    LET m_ind              = m_ind - 1
    LET m_count_principal  = m_ind
    CALL set_count(m_count_principal)
    LET m_existe_dado = TRUE
    IF m_ind > 6 THEN
       #DISPLAY ARRAY ma_principal TO s_tela.*
    ELSE
       #INPUT ARRAY ma_principal WITHOUT DEFAULTS FROM s_tela.*
       #   BEFORE INPUT
       #   EXIT INPUT
       #END INPUT
    END IF
 ELSE
    ERROR "Não existem dados para os parâmetros informados."
    INITIALIZE mr_docum_aberto.*,
               mr_dados_pagto.* TO NULL

    CALL geo1017_exibe_dados()
 END IF

END FUNCTION

#-------------------------------#
 FUNCTION geo1017_exibe_array()
#-------------------------------#
 DEFINE lr_docum           RECORD LIKE docum.*
 DEFINE l_val_desconto     DECIMAL(15,2),
        l_val_dif_desc     DECIMAL(15,2),
        l_ind              SMALLINT,
        l_dat_emis         LIKE docum.dat_emis,
        l_dat_default      DATE,
        l_i                INTEGER,
        l_ok               SMALLINT,
        l_credito          INTEGER,
        l_val_saldo        DECIMAL(15,2),
        l_entrou           SMALLINT,
        l_desabilita_contrato SMALLINT,
        l_status              SMALLINT

 DEFINE l_ies_tip_cobr      LIKE docum.ies_tip_cobr
 DEFINE l_cod_portador      LIKE docum.cod_portador
 DEFINE l_val_saldo_cliente LIKE cre_tit_cob_esp.val_parcela_cliente
 DEFINE l_val_saldo_transf  LIKE docum.val_saldo
 DEFINE l_observacao        CHAR(78)

 DEFINE l_val_bruto_nc LIKE docum.val_saldo
 DEFINE l_msg          CHAR(100)
 CALL SET_COUNT(m_count_principal)
 LET l_dat_default = ' '
 LET l_ok = FALSE
 LET l_entrou = FALSE

 LET m_esta_na_consulta = TRUE

 CALL geo1017_cria_temp_total()
{
 INPUT ARRAY ma_principal WITHOUT DEFAULTS FROM s_tela.*
    BEFORE ROW
      LET m_ind              = ARR_CURR()
      LET m_count_principal  = ARR_COUNT()
      LET msc_curr           = SCR_LINE()

      #CALL log_refresh_display()

    IF  ma_principal[m_ind].empresa IS NOT NULL
    AND ma_principal[m_ind].empresa <> ' ' THEN
       IF NOT geo1017_verifica_empresa_cre(ma_principal[m_ind].empresa) THEN
          CALL log0030_mensagem ('Empresa não cadastrada na tabela empresa_cre', 'info')
       END IF
    END IF

    IF geo1017_busca_val_saldo_docum() THEN
    END IF

    BEFORE FIELD dat_pgto
       IF ma_principal[m_ind].empresa IS NOT NULL THEN
          IF l_dat_default IS NOT NULL THEN
             LET ma_principal[m_ind].dat_pgto = l_dat_default
             DISPLAY ma_principal[m_ind].dat_pgto TO s_tela[msc_curr].dat_pgto
          END IF
       END IF

      LET l_observacao = ma_principal_obs[m_ind].observacao
      ERROR l_observacao

    AFTER FIELD dat_pgto
       IF ma_principal[m_ind].dat_pgto IS NOT NULL THEN
          IF NOT geo1017_verifica_cotacao(ma_principal[m_ind].empresa   ,
                                           ma_principal[m_ind].docum     ,
                                           ma_principal[m_ind].tip_docum ,
                                           ma_principal[m_ind].dat_pgto  ,
                                           m_total_a_pagar) THEN
             LET p_ies_cotacao = 'CR$'
             NEXT FIELD dat_pgto
          END IF

          LET l_dat_default = ma_principal[m_ind].dat_pgto
          LET l_ok          = FALSE

          FOR l_credito = 1 TO 100
             IF ma_outros[l_credito].dat_cred IS NULL
             OR ma_outros[l_credito].dat_cred = ' ' THEN
                EXIT FOR
             END IF

             IF ma_outros[l_credito].dat_cred >= ma_principal[m_ind].dat_pgto THEN
                LET l_ok = TRUE
             END IF
          END FOR

          IF l_ok = FALSE THEN
             CALL log0030_mensagem('Data de pagamento maior que data de crédito.','exclamation')
             NEXT FIELD dat_pgto
          END IF

          INITIALIZE l_dat_emis TO NULL

          WHENEVER ERROR CONTINUE
           SELECT dat_emis
             INTO l_dat_emis
             FROM docum
            WHERE cod_empresa   = ma_principal[m_ind].empresa
              AND num_docum     = ma_principal[m_ind].docum
              AND ies_tip_docum = ma_principal[m_ind].tip_docum
          WHENEVER ERROR STOP
          IF sqlca.sqlcode = 0 THEN
             IF ma_principal[m_ind].dat_pgto < l_dat_emis THEN
                CALL log0030_mensagem ('Data de pagamento anterior à data de emissão.','exclamation')
                NEXT FIELD dat_pgto
             END IF
          END IF
       ELSE
          IF ma_principal[m_ind].marcado = 'X' THEN
             CALL log0030_mensagem('Data de pagamento não informada','exclamation')
             NEXT FIELD dat_pgto
          END IF
       END IF

       IF ma_principal[m_ind].dat_pgto IS NOT NULL THEN

          IF ma_principal[m_ind].dat_pgto > mr_dados_pagto.dat_lanc THEN
            CALL log0030_mensagem('Data de pagamento maior que data de lançamento.','exclamation')
            NEXT FIELD dat_pgto
          END IF

          LET m_dat_pgto = ma_principal[m_ind].dat_pgto

          IF ma_principal[m_ind].val_juros IS NULL
          OR ma_principal[m_ind].val_juros = 0 THEN

             IF NOT geo1017_realiza_calculo_especifico_juros() THEN
                CALL geo1017_gerencia_calc_juro_aberto()
             END IF

             IF p_val_juro_a_pag > 0 THEN
                LET ma_principal[m_ind].val_juros = p_val_juro_a_pag
             END IF

             DISPLAY ma_principal[m_ind].val_juros TO s_tela[msc_curr].val_juros
          END IF
       END IF

    AFTER FIELD val_saldo
       WHENEVER ERROR CONTINUE
        SELECT val_saldo  , ies_tip_cobr, cod_portador
          INTO l_val_saldo, l_ies_tip_cobr, l_cod_portador
          FROM docum
         WHERE cod_empresa   = ma_principal[m_ind].empresa
           AND num_docum     = ma_principal[m_ind].docum
           AND ies_tip_docum = ma_principal[m_ind].tip_docum
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          LET l_val_saldo = 0
       END IF

       IF l_ies_tip_cobr = "V" AND l_cod_portador > 0 THEN
          CALL geo1017_busca_cre_tit_cob_esp(ma_principal[m_ind].empresa  ,
                                              ma_principal[m_ind].docum    ,
                                              ma_principal[m_ind].tip_docum,
                                              l_ies_tip_cobr)
          RETURNING l_val_saldo_cliente
       ELSE
          LET l_val_saldo_cliente = 0
       END IF

       IF l_val_saldo_cliente > 0 THEN
          LET l_val_saldo = l_val_saldo_cliente
       END IF

       CALL geo1017_verifica_docum_equalizacao(ma_principal[m_ind].empresa  ,
                                                ma_principal[m_ind].docum    ,
                                                ma_principal[m_ind].tip_docum,
                                                l_val_saldo                  ,
                                                FALSE)
            RETURNING l_val_saldo_transf, l_status

       IF l_val_saldo_transf > 0 THEN
          LET l_val_saldo = l_val_saldo_transf
       END IF

       IF ma_principal[m_ind].val_saldo > l_val_saldo THEN
          CALL log0030_mensagem('Valor informado maior que o saldo do documento.','exclamation')
          NEXT FIELD val_saldo
       END IF

       IF p_par_cre_txt.parametro[309] MATCHES '[sS]' THEN
          CALL geo1017_verifica_dp_possui_nc()
          RETURNING l_val_bruto_nc

          IF l_val_bruto_nc > ma_principal[m_ind].val_saldo THEN
             LET l_msg = "Valor informado deve ser maior ou igual ao valor da NC R$ ", l_val_bruto_nc USING "<<<<<<<<<<<<<<<"
             CALL log0030_mensagem(l_msg, "Info")
             NEXT FIELD val_saldo
          END IF

          LET ma_principal[m_ind].val_desc = l_val_bruto_nc

          DISPLAY ma_principal[m_ind].val_desc TO s_tela[msc_curr].val_desc
       END IF


    AFTER FIELD val_juros
       IF ma_principal[m_ind].val_juros IS NULL THEN
          LET ma_principal[m_ind].val_juros = 0
          DISPLAY ma_principal[m_ind].val_juros TO s_tela[msc_curr].val_juros
       END IF

    BEFORE FIELD val_desc
       WHENEVER ERROR CONTINUE
         SELECT pct_desc
           INTO lr_docum.pct_desc
           FROM docum
          WHERE cod_empresa   = ma_principal[m_ind].empresa
            AND num_docum     = ma_principal[m_ind].docum
            AND ies_tip_docum = ma_principal[m_ind].tip_docum
       WHENEVER ERROR STOP
       IF sqlca.sqlcode = 0 THEN
          LET p_pct_desc  = lr_docum.pct_desc
       ELSE
          LET lr_docum.pct_desc = 0
          LET p_pct_desc = 0
       END IF
       IF m_parametro[102,102] = "2" THEN
          WHENEVER ERROR CONTINUE
          SELECT parametro[1,6]
            INTO p_pct_desc
            FROM docum_txt
           WHERE cod_empresa   = ma_principal[m_ind].empresa
             AND num_docum     = ma_principal[m_ind].docum
             AND ies_tip_docum = ma_principal[m_ind].tip_docum
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             LET p_pct_desc = 0
          END IF
       END IF
       CALL geo1017_verifica_desc_doc_aberto()
       IF ma_principal[m_ind].val_desc IS NULL THEN
          LET ma_principal[m_ind].val_desc = 0
          DISPLAY ma_principal[m_ind].val_desc TO s_tela[msc_curr].val_desc
       END IF

    AFTER FIELD val_desc
       IF ma_principal[m_ind].val_desc IS NULL THEN
          LET ma_principal[m_ind].val_desc = 0
          DISPLAY ma_principal[m_ind].val_desc TO s_tela[msc_curr].val_desc
       END IF

       IF ma_principal[m_ind].val_desc > ma_principal[m_ind].val_saldo THEN
          CALL log0030_mensagem("Valor de desconto maior que valor saldo.","exclamation")
          NEXT FIELD val_desc
       END IF

       #459797
       IF NOT geo1017_valida_desconto(ma_principal[m_ind].empresa,
          ma_principal[m_ind].val_desc) THEN
          LET ma_principal[m_ind].val_desc = 0
          NEXT FIELD val_desc
       END IF

       IF ma_principal[m_ind].val_juros IS NULL
       OR ma_principal[m_ind].val_juros = 0 THEN

          IF NOT geo1017_realiza_calculo_especifico_juros() THEN
             CALL geo1017_gerencia_calc_juro_aberto()
          END IF

          IF p_val_juro_a_pag > 0 THEN
             LET ma_principal[m_ind].val_juros = p_val_juro_a_pag
          END IF
          DISPLAY ma_principal[m_ind].val_juros TO s_tela[msc_curr].val_juros
       END IF

       IF  p_docum.dat_vencto_c_desc IS NOT NULL
       AND ma_principal[m_ind].val_desc > 0 THEN
          IF mr_dados_pagto.forma_pgto = "BC" THEN
             IF p_docum.dat_vencto_c_desc <= ma_principal[m_ind].dat_pgto THEN
                IF ma_principal[m_ind].val_desc > 0 THEN
                   LET l_val_desconto = p_docum.val_saldo * p_pct_desc / 100
                   LET l_val_dif_desc = ma_principal[m_ind].val_desc - l_val_desconto
                   IF l_val_dif_desc > 0 THEN
                      IF mr_empresa_cre.val_abat_desc < l_val_dif_desc THEN
                         CALL log0030_mensagem("Valor do desconto maior que desconto permitido.","exclamation")
                         NEXT FIELD val_desc
                      END IF
                   END IF
                END IF
             END IF
          END IF
       END IF

       IF  p_docum.val_desc_dia > 0
       AND ma_principal[m_ind].val_desc > 0 THEN
          IF mr_dados_pagto.forma_pgto = "BC" THEN
             IF ma_principal[m_ind].val_desc > 0 THEN
                IF p_docum.dat_prorrogada IS NOT NULL THEN
                   LET p_docum.dat_vencto_s_desc = p_docum.dat_prorrogada
                END IF
                LET l_val_desconto = (p_docum.dat_vencto_s_desc
                                      - ma_principal[m_ind].dat_pgto)
                                      * p_docum.val_desc_dia
                LET l_val_dif_desc = ma_principal[m_ind].val_desc - l_val_desconto
                IF l_val_dif_desc > 0 THEN
                   IF mr_empresa_cre.val_abat_desc < l_val_dif_desc THEN
                      CALL log0030_mensagem("Valor do desconto maior que desconto permitido.","exclamation")
                   END IF
                END IF
             END IF
          END IF
       END IF

    BEFORE FIELD marcado
       MESSAGE "Marque com X os documentos que serão pagos." ATTRIBUTE(REVERSE)

    AFTER FIELD marcado
       IF ma_principal[m_ind].empresa IS NOT NULL THEN
          IF ma_principal[m_ind].marcado IS NOT NULL AND
             ma_principal[m_ind].marcado <> 'X' THEN
             CALL log0030_mensagem("Para selecionar este documento, marque o campo.","exclamation")
             NEXT FIELD marcado
          ELSE
             IF ma_principal[m_ind].marcado IS NOT NULL AND
                ma_principal[m_ind].marcado = 'X' THEN
                IF p_docum.val_saldo = 0 OR
                   p_docum.ies_pgto_docum = 'T' THEN
                   CALL log0030_mensagem('Documento sem saldo para pagamento','exclamation')
                   NEXT FIELD dat_pgto
                END IF
                IF ma_principal[m_ind].dat_pgto IS NULL OR
                   ma_principal[m_ind].dat_pgto = ' ' THEN
                   CALL log0030_mensagem('Data de pagamento não informada.','exclamation')
                   NEXT FIELD dat_pgto
                END IF
             END IF
             CALL geo1017_soma_selecionados()
          END IF
       ELSE
       END IF

       LET l_desabilita_contrato = FALSE

       ### OS 590916
       IF ma_principal[m_ind].marcado = 'X' THEN
          LET m_dados_array = TRUE

          WHENEVER ERROR CONTINUE
            SELECT ies_tip_cobr
              INTO l_ies_tip_cobr
              FROM docum
             WHERE cod_empresa    = ma_principal[m_ind].empresa
               AND ies_tip_docum  = ma_principal[m_ind].tip_docum
               AND num_docum      = ma_principal[m_ind].docum
          WHENEVER ERROR STOP
          IF sqlca.sqlcode = 100 THEN
             CALL log0030_mensagem('Documento não cadastrado. ','info')
             RETURN FALSE
          END IF

          IF l_ies_tip_cobr = "V" THEN
             CALL geo1017_consiste_vendor(ma_principal[m_ind].empresa,
                                           ma_principal[m_ind].docum,
                                           ma_principal[m_ind].tip_docum,
                                           l_ies_tip_cobr)
               RETURNING m_status, l_desabilita_contrato

             LET ma_principal_aux[m_ind].ies_desabilita_contrato = l_desabilita_contrato

             IF NOT m_status THEN
                NEXT FIELD marcado
             END IF
          END IF
       END IF
       ### OS 590916

    AFTER INPUT

       IF NOT INT_FLAG THEN
         { FOR l_ind = 1 TO 4000
             IF ma_principal[l_ind].marcado = "X" THEN
                LET l_entrou = TRUE

                IF ma_principal[l_ind].dat_pgto IS NOT NULL AND
                   ma_principal[l_ind].dat_pgto <> ' ' THEN
                   WHENEVER ERROR CONTINUE
                    SELECT dat_emis
                      INTO l_dat_emis
                      FROM docum
                     WHERE cod_empresa   = ma_principal[l_ind].empresa
                       AND num_docum     = ma_principal[l_ind].docum
                       AND ies_tip_docum = ma_principal[l_ind].tip_docum
                   WHENEVER ERROR STOP

                   IF sqlca.sqlcode = 0 THEN

                   END IF

                   IF ma_principal[l_ind].dat_pgto < l_dat_emis THEN
                      CALL log0030_mensagem ('Data de pagamento anterior a data de emissão','info')
                      NEXT FIELD dat_pgto
                   END IF

                   FOR l_credito = 1 TO 100
                      IF ma_outros[l_credito].dat_cred IS NULL OR
                         ma_outros[l_credito].dat_cred = ' ' THEN
                         EXIT FOR
                      END IF
                      IF ma_outros[l_credito].dat_cred >= ma_principal[l_ind].dat_pgto THEN
                         LET l_ok = TRUE
                      END IF
                   END FOR

                   IF l_ok = FALSE THEN
                      CALL log0030_mensagem('Data de pagamento maior que data de crédito','exclamation')
                      NEXT FIELD dat_pgto
                   END IF
                ELSE

                   CALL log0030_mensagem('Data de pagamento não informada.','exclamation')
                   NEXT FIELD dat_pgto
                END IF
             END IF
          END FOR}

       #   CALL geo1017_soma_selecionados()
{
          IF m_total_a_pagar = m_val_difer THEN
             CALL log0030_mensagem('Nenhum documento foi marcado.','exclamation')
             NEXT FIELD marcado
          END IF

          IF m_val_difer <> 0 THEN
             CALL log0030_mensagem('Lote com diferença, é necessário fazer ajuste.','exclamation')
             NEXT FIELD dat_pgto
          END IF

          ### OS 590916
          IF ma_principal[m_ind].marcado = 'X' THEN
             LET m_dados_array = TRUE
          END IF
          ### OS 590916
       END IF
 END INPUT

 IF INT_FLAG = FALSE  THEN
    CALL geo1017_organiza_dados()
 END IF

 IF int_flag = TRUE   THEN
    LET int_flag = FALSE
 END IF
 }

END FUNCTION


#----------------------------------#
 FUNCTION geo1017_cria_temp_total()
#----------------------------------#

  WHENEVER ERROR CONTINUE
      DROP TABLE t_marcados
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
    CREATE TEMP TABLE t_marcados
           (
           indice     SMALLINT      ,
           val_juros  DECIMAL(15,2) ,
           val_desc   DECIMAL(15,2) ,
           val_saldo  DECIMAL(15,2)
           )
  WHENEVER ERROR STOP

  IF sqlca.sqlcode < 0 THEN
     CALL log003_err_sql('Criação','t_marcados')
  END IF


END FUNCTION
#--------------------------------#
 FUNCTION geo1017_valida_desconto(l_cod_emp, l_val_desc)
#--------------------------------#
 DEFINE l_cod_emp          LIKE docum_pgto.cod_empresa,
        l_val_desc         LIKE docum_pgto.val_desc_conc,
        l_aprov_elet_desc  CHAR(01),
        l_usu_pode_desc    SMALLINT,
        l_val_lim_max_desc LIKE cre_par_aprov_abat.val_lim_max_abat

 IF l_val_desc = 0 THEN
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
   SELECT parametros [346,346]
     INTO l_aprov_elet_desc
     FROM empresa_cre_txt
    WHERE cod_empresa = l_cod_emp
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
    CALL log003_err_sql("SELEÇÃO","EMPRESA_CRE_TXT")
    RETURN FALSE
 END IF

 IF l_aprov_elet_desc MATCHES "[sS]" THEN
    WHENEVER ERROR CONTINUE
      SELECT val_lim_max_abat
        INTO l_val_lim_max_desc
        FROM cre_par_aprov_abat
       WHERE empresa     = l_cod_emp
         AND nom_usuario = p_user
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
       LET l_usu_pode_desc = TRUE
    ELSE
       LET l_usu_pode_desc = FALSE
       LET l_val_lim_max_desc = 0
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("SELEÇÃO","CRE_PAR_APROV_ABAT")
          RETURN FALSE
       END IF
    END IF

    IF NOT l_usu_pode_desc THEN
       CALL log0030_mensagem("Usuário não autorizado (CRE4420). Utilize a rotina de aprovação eletrônica.","exclamation")
       RETURN FALSE
    ELSE
       IF l_val_desc > l_val_lim_max_desc THEN
          CALL log0030_mensagem("Limite de desconto ultrapassado (CRE4420). Utilize a rotina de aprovação eletrônica.","exclamation")
          RETURN FALSE
       END IF
    END IF
 END IF

 RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION geo1017_verifica_dados()
#--------------------------------#
  DEFINE l_clientes_cre_txt     RECORD LIKE clientes_cre_txt.*,
         l_cond_pgto_cre_txt    RECORD LIKE cond_pgto_cre_txt.*

  DEFINE l_dat_atraso                  DECIMAL(2,0),
         l_dat_atraso_cnd              DECIMAL(3,0),
         l_dat_prorrogada              LIKE docum.dat_prorrogada,
         l_cod_cliente                 LIKE docum.cod_cliente,
         l_cod_cnd_pgto                LIKE docum.cod_cnd_pgto,
         l_dat_vencto_s_desc           LIKE docum.dat_vencto_s_desc,
         l_pct_desc                    CHAR(06)

  WHENEVER ERROR CONTINUE
   SELECT cod_cliente      ,
          cod_cnd_pgto     ,
          dat_prorrogada   ,
          dat_vencto_s_desc
     INTO l_cod_cliente      ,
          l_cod_cnd_pgto     ,
          l_dat_prorrogada   ,
          l_dat_vencto_s_desc
     FROM docum
    WHERE cod_empresa   = ma_principal[m_ind].empresa
      AND num_docum     = ma_principal[m_ind].docum
      AND ies_tip_docum = ma_principal[m_ind].tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('SELECT','DOCUM')
  END IF

  IF m_parametro[102,102] = "2" THEN
     WHENEVER ERROR CONTINUE
     SELECT parametro[1,6]
       INTO l_pct_desc
       FROM docum_txt
      WHERE cod_empresa   = ma_principal[m_ind].empresa
        AND num_docum     = ma_principal[m_ind].docum
        AND ies_tip_docum = ma_principal[m_ind].tip_docum
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET l_pct_desc = 0
     END IF
  END IF

  INITIALIZE l_clientes_cre_txt TO NULL
  WHENEVER ERROR CONTINUE
   SELECT *
     INTO l_clientes_cre_txt.*
     FROM clientes_cre_txt
    WHERE clientes_cre_txt.cod_cliente = l_cod_cliente
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     INITIALIZE l_clientes_cre_txt.* TO NULL
  END IF

  IF  l_clientes_cre_txt.parametro[1,2] IS NOT NULL
  AND l_clientes_cre_txt.parametro[1,2] > 0
  AND sqlca.sqlcode = 0 THEN
     LET l_dat_atraso = l_clientes_cre_txt.parametro[1,2]
     IF l_dat_prorrogada IS NOT NULL THEN
        LET l_dat_prorrogada    = l_dat_prorrogada
                                + l_dat_atraso UNITS DAY
     ELSE
        LET l_dat_vencto_s_desc = l_dat_vencto_s_desc
                                + l_dat_atraso UNITS DAY
     END IF

  ELSE

     INITIALIZE l_cond_pgto_cre_txt TO NULL

     WHENEVER ERROR CONTINUE
     SELECT *
       INTO l_cond_pgto_cre_txt.*
       FROM cond_pgto_cre_txt
      WHERE cond_pgto_cre_txt.cod_cnd_pgto = l_cod_cnd_pgto
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('SELECT','COND_PGTO_CRE_TXT')
     END IF

     IF  l_cond_pgto_cre_txt.parametros[2,4] IS NOT NULL
     AND l_cond_pgto_cre_txt.parametros[2,4] > 0
     AND sqlca.sqlcode = 0 THEN
        LET l_dat_atraso_cnd = l_cond_pgto_cre_txt.parametros[2,4]
        IF l_dat_prorrogada IS NOT NULL THEN
           LET l_dat_prorrogada    = l_dat_prorrogada
                                   + l_dat_atraso_cnd UNITS DAY
        ELSE
           LET l_dat_vencto_s_desc = l_dat_vencto_s_desc
                                   + l_dat_atraso_cnd UNITS DAY
        END IF
     END IF
  END IF

  RETURN l_dat_prorrogada,l_dat_vencto_s_desc,l_pct_desc

 END FUNCTION


#---------------------------------------------#
 FUNCTION geo1017_gerencia_calc_juro_aberto()
#---------------------------------------------#
DEFINE l_ies_prorr          CHAR(03) ,
       l_salva_dat_pgto     DATE,
       l_ies_ctr_dat_prorr  LIKE empresa_cre.ies_ctr_dat_prorr,
       l_des_cnd_pgto       LIKE cond_pgto_cre.des_cnd_pgto

 LET m_qtd_dias_difer  = 0
 LET p_val_juro_a_pag  = 0
 LET l_ies_prorr       = "NAO"

 WHENEVER ERROR CONTINUE
 SELECT ies_ctr_dat_prorr
   INTO l_ies_ctr_dat_prorr
   FROM empresa_cre
  WHERE cod_empresa = ma_principal[m_ind].empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET l_ies_ctr_dat_prorr = ' '
 END IF

 IF  l_ies_ctr_dat_prorr = "S"
 AND p_docum.dat_prorrogada IS NOT NULL THEN
    LET l_ies_prorr  = "SIM" {LET m_dat_aux = p_docum.dat_prorrogada  }
 ELSE
    LET m_dat_aux = p_docum.dat_vencto_s_desc
 END IF

 IF l_ies_prorr = "SIM" THEN
    IF p_docum.ies_cobr_juros = "S" THEN
       WHENEVER ERROR CONTINUE
       SELECT cond_pgto_cre.des_abrev_cnd_pgto
         INTO l_des_cnd_pgto
         FROM cond_pgto_cre
        WHERE cond_pgto_cre.cod_cnd_pgto = p_docum.cod_cnd_pgto
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          LET l_des_cnd_pgto = "NORMAL"
       END IF

       IF l_des_cnd_pgto = "S.E.P." THEN
          IF ma_principal[m_ind].dat_pgto > p_docum.dat_vencto_s_desc THEN
             LET m_dat_aux                    = p_docum.dat_vencto_s_desc
             LET l_salva_dat_pgto             = ma_principal[m_ind].dat_pgto
             #LET ma_principal[m_ind].dat_pgto = p_docum.dat_prorrogada

             IF ma_principal[m_ind].dat_pgto > m_dat_aux THEN
                CALL geo1017_calcula_qtd_dias_difer(ma_principal[m_ind].dat_pgto)
             ELSE
                LET m_qtd_dias_difer = 0
             END IF
             IF m_qtd_dias_difer > 0 THEN
                CALL geo1017_calcula_juro(ma_principal[m_ind].dat_pgto,
                                           ma_principal[m_ind].val_desc)
             END IF

             LET ma_principal[m_ind].val_juros = p_val_juro_a_pag
             LET m_dat_aux                     = p_docum.dat_prorrogada
             #LET ma_principal[m_ind].dat_pgto  = l_salva_dat_pgto

             IF ma_principal[m_ind].dat_pgto > m_dat_aux THEN
                CALL geo1017_calcula_qtd_dias_difer(ma_principal[m_ind].dat_pgto)
             ELSE
                LET m_qtd_dias_difer = 0
             END IF

             IF m_qtd_dias_difer > 0 THEN
                CALL geo1017_calcula_juro_1(ma_principal[m_ind].empresa,
                                             ma_principal[m_ind].dat_pgto,
                                             ma_principal[m_ind].val_juros,
                                             ma_principal[m_ind].val_desc)
                LET ma_principal[m_ind].val_juros = p_val_juro_a_pag
             ELSE
                LET ma_principal[m_ind].val_juros = p_val_juro_a_pag
             END IF
          ELSE
             LET p_val_juro_a_pag = 0
             LET ma_principal[m_ind].val_juros = 0
          END IF
       ELSE
          LET m_dat_aux = p_docum.dat_vencto_s_desc
          IF ma_principal[m_ind].dat_pgto > m_dat_aux THEN
             CALL geo1017_calcula_qtd_dias_difer(ma_principal[m_ind].dat_pgto)
          ELSE
             LET m_qtd_dias_difer = 0
          END IF
          IF m_qtd_dias_difer > 0 THEN
             CALL geo1017_calcula_juro(ma_principal[m_ind].dat_pgto,
                                        ma_principal[m_ind].val_desc)
          END IF
          LET ma_principal[m_ind].val_juros = p_val_juro_a_pag
       END IF
    ELSE
       LET m_dat_aux = p_docum.dat_prorrogada
       IF ma_principal[m_ind].dat_pgto > m_dat_aux THEN
          CALL geo1017_calcula_qtd_dias_difer(ma_principal[m_ind].dat_pgto)
       ELSE
          LET m_qtd_dias_difer = 0
       END IF
       IF m_qtd_dias_difer > 0 THEN
          CALL geo1017_calcula_juro(ma_principal[m_ind].dat_pgto,
                                     ma_principal[m_ind].val_desc)
       END IF
       LET ma_principal[m_ind].val_juros = p_val_juro_a_pag
    END IF
 ELSE
    IF ma_principal[m_ind].dat_pgto > m_dat_aux THEN
       CALL geo1017_calcula_qtd_dias_difer(ma_principal[m_ind].dat_pgto)
    ELSE
       LET m_qtd_dias_difer = 0
    END IF
    IF m_qtd_dias_difer > 0 THEN
       CALL geo1017_calcula_juro(ma_principal[m_ind].dat_pgto,
                                  ma_principal[m_ind].val_desc)
    END IF
    LET ma_principal[m_ind].val_juros = p_val_juro_a_pag
 END IF

 IF p_val_juro_a_pag > 0 THEN
    IF NOT geo1017_cli_cre_txt_calcula_juros() THEN
       ERROR "Valor do juros cálculado ",p_val_juro_a_pag USING "<<<<<<<<<<<<&.&&",". ",
             "Cliente parametrizado para não calcular juros."

       LET p_val_juro_a_pag = 0
       LET ma_principal[m_ind].val_juros = 0
    END IF
 END IF

END FUNCTION

#---------------------------------------------#
 FUNCTION geo1017_cli_cre_txt_calcula_juros()
#---------------------------------------------#
{OBJETIVO: Verificar se o cliente do documento está parâmetros para cálcular ou não
           o valor de juros. Porgrama cre6960.
           Regra copiada da função cre159_cli_cre_txt().
}
  DEFINE l_parametro CHAR(500)

  INITIALIZE l_parametro TO NULL

  WHENEVER ERROR CONTINUE
  SELECT parametro
    INTO l_parametro
    FROM clientes_cre_txt
   WHERE cod_cliente = p_docum.cod_cliente
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0
  OR l_parametro[11,11] = "S"
  OR l_parametro[11,11] IS NULL
  OR l_parametro[11,11] = " " THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF

END FUNCTION

#---------------------------------------------#
 FUNCTION geo1017_verifica_desc_doc_aberto()
#---------------------------------------------#

 IF p_docum.dat_vencto_c_desc IS NOT NULL THEN
   LET ma_principal[m_ind].val_desc = 0
   IF m_parametro[198,198] = "S" AND p_docum.ies_pgto_docum = "A" THEN
      LET ma_principal[m_ind].val_desc  = p_docum.val_liquido * p_pct_desc / 100
   ELSE
      LET ma_principal[m_ind].val_desc  = p_docum.val_saldo   * p_pct_desc / 100
   END IF

   #DISPLAY ma_principal[m_ind].val_desc TO s_tela[msc_curr].val_desc

 END IF

 END FUNCTION

#------------------------------------#
 FUNCTION geo1017_soma_selecionados()
#------------------------------------#

 LET m_valor_pagar     = 0
 LET m_juros_pagar     = 0
 LET m_desc_conceder   = 0
 LET m_total_saldo     = 0
 LET m_total_juro      = 0
 LET m_total_desc      = 0

 IF ma_principal[m_ind].marcado = 'X' THEN
    WHENEVER ERROR CONTINUE
      DELETE FROM wmarcados
       WHERE indice  = m_ind
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('DELETE','wmarcados-1')
    END IF

    IF ma_principal[m_ind].val_desc IS NULL THEN
       LET ma_principal[m_ind].val_desc = 0
    END IF
    IF ma_principal[m_ind].val_juros IS NULL THEN
       LET ma_principal[m_ind].val_juros = 0
    END IF

    WHENEVER ERROR CONTINUE
      INSERT INTO wmarcados (indice     ,
                             empresa    ,
                             docum      ,
                             tip_docum  ,
                             dat_pgto   ,
                             val_saldo  ,
                             val_desc   ,
                             val_juros  ,
                             marcado    )
                     VALUES (m_ind                         ,
                             ma_principal[m_ind].empresa   ,
                             ma_principal[m_ind].docum     ,
                             ma_principal[m_ind].tip_docum ,
                             ma_principal[m_ind].dat_pgto  ,
                             ma_principal[m_ind].val_saldo ,
                             ma_principal[m_ind].val_desc  ,
                             ma_principal[m_ind].val_juros ,
                             ma_principal[m_ind].marcado   )
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('INCLUSÃO','wmarcados')
    END IF

 ELSE
    WHENEVER ERROR CONTINUE
      DELETE FROM wmarcados
       WHERE indice  = m_ind
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('DELETE','wmarcados')
    END IF

 END IF

 WHENEVER ERROR CONTINUE
   SELECT SUM(val_juros)     ,
          SUM(val_desc )     ,
          SUM(val_saldo)
     INTO m_total_juro       ,
          m_total_desc       ,
          m_total_saldo
     FROM wmarcados
  WHENEVER ERROR STOP

  IF sqlca.sqlcode < 0 THEN
     CALL log003_err_sql('Seleção','wmarcados-1')
  END IF

  CALL geo1017_calcula_difer()

  #CALL geo1017_exibe_tela()

END FUNCTION

#------------------------------#
 FUNCTION geo1017_exibe_tela()
#------------------------------#

  {DISPLAY m_val_difer,
          m_total_saldo,
          m_total_desc,
          m_total_juro
      TO  val_difer,
          val_total_saldo,
          val_total_desc,
          val_total_juro}

END FUNCTION

#--------------------------------#
 FUNCTION geo1017_calcula_difer()
#--------------------------------#

   LET m_val_difer =  m_total_a_pagar - (m_total_saldo + m_total_juro - m_total_desc)

   #DISPLAY m_val_difer TO val_difer

END FUNCTION

#----------------------------------#
 FUNCTION geo1017_organiza_dados()
#----------------------------------#
 DEFINE l_tip_pgto                LIKE adocum_pgto.ies_tip_pgto,
        l_val_saldo               LIKE docum.val_saldo,
        l_achou                   SMALLINT,
        l_val_pago                LIKE docum_pgto.val_pago,
        l_pgto_docum              LIKE docum.ies_pgto_docum

 DEFINE l_array_indice            INTEGER,
        l_array_empresa           LIKE docum_pgto.cod_empresa,
        l_array_docum             LIKE docum_pgto.num_docum,
        l_array_tip_docum         LIKE docum_pgto.ies_tip_docum,
        l_array_dat_pgto          LIKE docum_pgto.dat_pgto,
        l_array_val_saldo         LIKE docum.val_saldo,
        l_array_val_desc          LIKE docum_pgto.val_desc_conc,
        l_array_val_juros         LIKE docum_pgto.val_juro_pago

 DEFINE l_ies_tip_cobr      LIKE docum.ies_tip_cobr
 DEFINE l_cod_portador      LIKE docum.cod_portador
 DEFINE l_val_saldo_cliente LIKE cre_tit_cob_esp.val_parcela_cliente

 LET l_tip_pgto       = ' '
 LET l_val_saldo      = 0
 LET m_som_dat_pgto   = 0
 LET m_som_dat_cred   = 0
 LET m_som_val_titulo = 0
 LET m_som_val_desc   = 0
 LET m_som_qtd_docum  = 0
 LET m_som_dat_lanc   = 0
 LET m_som_val_juros  = 0
 LET m_som_val_abat   = 0
 LET m_num_lot        = 0

 IF NOT geo1017_busca_atualiza_lote_pagamento() THEN
    LET int_flag = TRUE
    RETURN
 END IF

 CALL log085_transacao('BEGIN')
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('BEGIN TRANSACTION','geo1017_ORGANIZA_DADOS-2')
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
  DECLARE cl_marcados CURSOR FOR
   SELECT indice      ,
          empresa     ,
          docum       ,
          tip_docum   ,
          dat_pgto    ,
          val_saldo   ,
          val_desc    ,
          val_juros
     FROM wmarcados
    WHERE marcado = 'X'
    ORDER BY empresa,docum
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('SELECT','WMARCADOS')
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cl_marcados INTO l_array_indice    ,
                          l_array_empresa   ,
                          l_array_docum     ,
                          l_array_tip_docum ,
                          l_array_dat_pgto  ,
                          l_array_val_saldo ,
                          l_array_val_desc  ,
                          l_array_val_juros
 WHENEVER ERROR STOP
 
 
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('FOREACH','CL_MARCADOS')
    EXIT FOREACH
 END IF

    IF l_array_val_desc IS NULL THEN
       LET l_array_val_desc = 0
    END IF
    IF l_array_val_juros IS NULL THEN
       LET l_array_val_juros = 0
    END IF

    IF l_array_empresa IS NOT NULL THEN

       #Aqui inserir dados na adocum_pgto
       WHENEVER ERROR CONTINUE
        SELECT val_saldo, ies_pgto_docum, ies_tip_cobr, cod_portador
          INTO l_val_saldo, l_pgto_docum, l_ies_tip_cobr, l_cod_portador
          FROM docum
         WHERE docum.cod_empresa   = l_array_empresa
           AND docum.num_docum     = l_array_docum
           AND docum.ies_tip_docum = l_array_tip_docum
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          LET l_val_saldo = 0
       END IF

       IF l_ies_tip_cobr = "V" AND l_cod_portador > 0 THEN
          CALL geo1017_busca_cre_tit_cob_esp(l_array_empresa  ,
                                              l_array_docum    ,
                                              l_array_tip_docum,
                                              l_ies_tip_cobr)
          RETURNING l_val_saldo_cliente
       ELSE
          LET l_val_saldo_cliente = 0
       END IF

       IF l_val_saldo_cliente > 0 THEN
          LET l_val_saldo = l_val_saldo_cliente
       END IF

       IF l_array_val_saldo = l_val_saldo AND l_pgto_docum = 'A' THEN
          LET l_tip_pgto = 'N'
       ELSE
          IF l_array_val_saldo = l_val_saldo AND l_pgto_docum = 'P' THEN
             LET l_tip_pgto = 'S'
          ELSE
             IF l_array_val_saldo < l_val_saldo THEN
                LET l_tip_pgto  = 'P'
             END IF
          END IF
       END IF

       WHENEVER ERROR CONTINUE
       SELECT cod_empresa
         FROM adocum_pgto
        WHERE cod_empresa      = mr_tela.cod_empresa
          AND cod_portador     = mr_tela.cod_portador
          AND ies_tip_portador = mr_tela.ies_tip_portador
          AND num_lote         = m_num_lot
          AND num_docum        = l_array_docum
          AND ies_tip_docum    = l_array_tip_docum
       WHENEVER ERROR STOP
       IF sqlca.sqlcode = 0 THEN

          WHENEVER ERROR CONTINUE
          UPDATE adocum_pgto
             SET ies_sit_docum     = 'I',
                 ies_tip_pgto      = l_tip_pgto,
                 ies_forma_pgto    = mr_dados_pagto.forma_pgto,
                 dat_pgto          = l_array_dat_pgto,
                 dat_credito       = ma_outros[1].dat_cred,
                 dat_lanc          = mr_dados_pagto.dat_lanc,
                 val_titulo        = l_array_val_saldo,
                 val_juro          = l_array_val_juros,
                 val_desc          = l_array_val_desc,
                 val_abat          = 0,
                 val_desp_cartorio = 0,
                 val_despesas      = 0,
                 ies_abono_juros   = 'N',
                 val_multa         = 0,
                 val_ir            = 0
           WHERE cod_empresa      = mr_tela.cod_empresa
             AND cod_portador     = mr_tela.cod_portador
             AND ies_tip_portador = mr_tela.ies_tip_portador
             AND num_lote         = m_num_lot
             AND num_docum        = l_array_docum
             AND ies_tip_docum    = l_array_tip_docum
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql('ALTERACAO','ADOCUM_PGTO')
             RETURN
          END IF

       ELSE

           WHENEVER ERROR CONTINUE
           INSERT INTO adocum_pgto
                VALUES (mr_dados_pagto.portador1     ,
                        mr_dados_pagto.tip_portador1 ,
                        m_num_lot                    ,
                        l_array_empresa              ,
                        l_array_docum                ,
                        l_array_tip_docum            ,
                        'I'                          ,
                        l_tip_pgto                   ,
                        mr_dados_pagto.forma_pgto    ,
                        l_array_dat_pgto             ,
                        ma_outros[1].dat_cred        ,
                        mr_dados_pagto.dat_lanc      ,
                        l_array_val_saldo            ,
                        l_array_val_juros,
                        l_array_val_desc ,
                        0,0,0,'N',0,0                )
          WHENEVER ERROR STOP
          
          IF sqlca.sqlcode = 0 OR
             sqlca.sqlcode = -239 THEN
             LET l_achou = TRUE
          ELSE
              IF cre1590_monta_wcre1591('Erro na gravação da preparação da baixa (ADOCUM_PGTO)') = FALSE THEN
                 RETURN FALSE
              END IF
             CALL log003_err_sql('INCLUSAO','ADOCUM_PGTO')
             LET l_achou = FALSE
          END IF
       END IF

       LET mr_tela.dat_pgto       = l_array_dat_pgto
       LET m_dat_lancamento       = mr_dados_pagto.dat_lanc
       LET mr_tela.dat_credito    = ma_outros[1].dat_cred
       LET mr_tela.val_saldo      = l_array_val_saldo
       LET mr_tela.val_juro_pago  = l_array_val_juros
       LET mr_tela.val_desc_conc  = l_array_val_desc

       WHENEVER ERROR CONTINUE
        SELECT som_dat_pgto  ,
               som_dat_cred  ,
               som_dat_lanc  ,
               som_val_titulo,
               som_val_juros ,
               som_val_desc  ,
               som_val_abat  ,
               som_qtd_docum
          INTO m_som_dat_pgto  ,
               m_som_dat_cred  ,
               m_som_dat_lanc  ,
               m_som_val_titulo,
               m_som_val_juros ,
               m_som_val_desc  ,
               m_som_val_abat  ,
               m_som_qtd_docum
          FROM adocum_pgto_capa
         WHERE cod_empresa      = l_array_empresa
           AND cod_portador     = mr_dados_pagto.portador1
           AND ies_tip_portador = mr_dados_pagto.tip_portador1
           AND num_lote         = m_num_lot
       WHENEVER ERROR STOP
       IF sqlca.sqlcode = 0 THEN

          CALL geo1017_busca_dat_decimal()

          LET m_som_dat_lanc = m_som_dat_lanc + m_dat_dec08
          LET m_som_dat_pgto = m_som_dat_pgto + m_dat_dec08
          LET m_som_dat_cred = m_som_dat_cred + m_dat_dec08

          LET m_som_val_titulo = m_som_val_titulo + mr_tela.val_saldo
                                                  + mr_tela.val_juro_pago
          LET m_som_val_juros  = m_som_val_juros  + mr_tela.val_juro_pago
          LET m_som_val_desc   = m_som_val_desc   + mr_tela.val_desc_conc
          LET m_som_val_abat   = m_som_val_abat   + 0
          LET m_som_qtd_docum  = m_som_qtd_docum  + 1

          IF m_som_dat_lanc IS NULL THEN
             LET m_som_dat_lanc = m_dat_dec08
          END IF

          IF m_som_dat_pgto IS NULL THEN
             LET m_som_dat_pgto = m_dat_dec08
          END IF

          IF m_som_dat_cred IS NULL THEN
             LET m_som_dat_cred = m_dat_dec08
          END IF

          WHENEVER ERROR CONTINUE
          UPDATE adocum_pgto_capa
             SET ies_sit_lote   = 'I',
                 som_dat_pgto   =  m_som_dat_pgto,
                 som_dat_cred   =  m_som_dat_cred,
                 som_dat_lanc   =  m_som_dat_lanc,
                 som_val_titulo =  m_som_val_titulo,
                 som_val_juros  =  m_som_val_juros,
                 som_val_desc   =  m_som_val_desc,
                 som_val_abat   =  m_som_val_abat,
                 som_qtd_docum  =  m_som_qtd_docum
           WHERE cod_empresa      = l_array_empresa
             AND cod_portador     = mr_dados_pagto.portador1
             AND ies_tip_portador = mr_dados_pagto.tip_portador1
             AND num_lote         = m_num_lot
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql('UPDATE','ADOCUM_PGTO_CAPA')
          END IF
       ELSE
          CALL geo1017_busca_dat_decimal()

          LET m_som_dat_pgto   = 0
          LET m_som_dat_cred   = 0
          LET m_som_val_titulo = 0
          LET m_som_val_desc   = 0
          LET m_som_qtd_docum  = 0
          LET m_som_dat_lanc   = 0
          LET m_som_val_juros  = 0
          LET m_som_val_abat   = 0

          LET m_som_dat_lanc = m_som_dat_lanc + m_dat_dec08
          LET m_som_dat_pgto = m_som_dat_pgto + m_dat_dec08
          LET m_som_dat_cred = m_som_dat_cred + m_dat_dec08

          LET m_som_val_titulo = m_som_val_titulo + mr_tela.val_saldo
                                                  + mr_tela.val_juro_pago
          LET m_som_val_juros  = m_som_val_juros  + mr_tela.val_juro_pago
          LET m_som_val_desc   = m_som_val_desc   + mr_tela.val_desc_conc
          LET m_som_val_abat   = m_som_val_abat   + 0
          LET m_som_qtd_docum  = m_som_qtd_docum  + 1

          IF m_som_dat_lanc IS NULL THEN
             LET m_som_dat_lanc = m_dat_dec08
          END IF

          IF m_som_dat_pgto IS NULL THEN
             LET m_som_dat_pgto = m_dat_dec08
          END IF

          IF m_som_dat_cred IS NULL THEN
             LET m_som_dat_cred = m_dat_dec08
          END IF

          WHENEVER ERROR CONTINUE
          INSERT INTO adocum_pgto_capa
               VALUES (l_array_empresa  ,
                       mr_dados_pagto.portador1     ,
                       mr_dados_pagto.tip_portador1 ,
                       m_num_lot                    ,
                       'I'                          ,
                       m_som_dat_pgto               ,
                       m_som_dat_cred               ,
                       m_som_dat_lanc               ,
                       m_som_val_titulo             ,
                       m_som_val_juros              ,
                       m_som_val_desc               ,
                       0                            ,
                       1                            )
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             IF cre1590_monta_wcre1591('Erro na gravação da capa do lote da baixa (ADOCUM_PGTO_CAPA).') = FALSE THEN
                RETURN FALSE
             END IF
          END IF
       END IF

       WHENEVER ERROR CONTINUE
        SELECT val_saldo  ,ies_tip_cobr, cod_portador
          INTO l_val_saldo,l_ies_tip_cobr, l_cod_portador
          FROM docum
         WHERE docum.cod_empresa   = l_array_empresa
           AND docum.num_docum     = l_array_docum
           AND docum.ies_tip_docum = l_array_tip_docum
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          LET l_val_saldo = 0
       END IF

       IF l_ies_tip_cobr = "V" AND l_cod_portador > 0 THEN
          CALL geo1017_busca_cre_tit_cob_esp(l_array_empresa  ,
                                              l_array_docum    ,
                                              l_array_tip_docum,
                                              l_ies_tip_cobr)
          RETURNING l_val_saldo_cliente
       ELSE
          LET l_val_saldo_cliente = 0
       END IF

       IF l_val_saldo_cliente > 0 THEN
          LET l_val_saldo = l_val_saldo_cliente
       END IF

       WHENEVER ERROR CONTINUE
        SELECT SUM(val_pago)
          INTO l_val_pago
          FROM docum_pgto
         WHERE docum_pgto.cod_empresa   = l_array_empresa
           AND docum_pgto.num_docum     = l_array_docum
           AND docum_pgto.ies_tip_docum = l_array_tip_docum
       WHENEVER ERROR STOP

       IF l_val_pago IS NULL THEN
          LET l_val_pago = 0
       END IF

       IF sqlca.sqlcode = 0 AND l_val_pago > 0 THEN
          IF l_val_pago = l_val_saldo THEN
             LET mr_tela.ies_tip_pgto = 'S'
          ELSE
             IF l_val_pago < l_val_saldo THEN
                LET mr_tela.ies_tip_pgto = 'P'
             END IF
          END IF
       ELSE
          LET l_val_pago = 0
          IF mr_tela.val_saldo = l_val_saldo THEN
             LET mr_tela.ies_tip_pgto = 'N'
          ELSE
             IF mr_tela.val_saldo < l_val_saldo THEN
                LET mr_tela.ies_tip_pgto = 'P'
             END IF
          END IF
       END IF

       IF mr_tela.ies_tip_pgto IS NULL THEN
          LET mr_tela.ies_tip_pgto = l_tip_pgto
       END IF

       WHENEVER ERROR CONTINUE
        SELECT val_glosa
          FROM wglosa
         WHERE empresa       = l_array_empresa
           AND docum         = l_array_docum
           AND tip_docum     = l_array_tip_docum
       WHENEVER ERROR STOP
       IF sqlca.sqlcode = 0 THEN
          WHENEVER ERROR CONTINUE
          UPDATE wglosa SET val_glosa = 0,
                            tip_pgto  = mr_tela.ies_tip_pgto
           WHERE empresa       = l_array_empresa
             AND docum         = l_array_docum
             AND tip_docum     = l_array_tip_docum
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("UPDATE","WGLOSA")
          END IF
       ELSE
          WHENEVER ERROR CONTINUE
            INSERT INTO wglosa (empresa   ,
                                docum     ,
                                tip_docum ,
                                tip_pgto  ,
                                val_glosa )
                        VALUES (l_array_empresa,
                                l_array_docum,
                                l_array_tip_docum,
                                mr_tela.ies_tip_pgto,
                                0)
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("INSERT","WGLOSA")
          END IF
       END IF

       IF ma_principal_aux[l_array_indice].ies_desabilita_contrato THEN
          IF NOT crer44_desabilita_contrato_documento_alterado(l_array_empresa  ,
                                                               l_array_docum    ,
                                                               l_array_tip_docum,
                                                               'V',0)  THEN
          END IF
       END IF
    END IF

 END FOREACH
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
  CLOSE cl_marcados
   FREE cl_marcados
 WHENEVER ERROR STOP

 IF l_achou THEN
    CALL log085_transacao('COMMIT')
    IF sqlca.sqlcode = 0 THEN
    END IF
    RETURN TRUE
 ELSE
    CALL log085_transacao('ROLLBACK')
    IF sqlca.sqlcode = 0 THEN
    END IF
    RETURN FALSE
 END IF

END FUNCTION

#-------------------------------#
 FUNCTION geo1017_exibe_dados()
#-------------------------------#

  DEFINE l_inicializa INTEGER

  #DISPLAY BY NAME mr_docum_aberto.*
  #DISPLAY BY NAME mr_dados_pagto.*

  #FOR l_inicializa = 1 TO 100
  #   DISPLAY ARRAY ma_outros TO s_tela1.*
  #END FOR

END FUNCTION

# OS 404764

#--------------------------------#
 FUNCTION geo1017_estorna_pgto()
#--------------------------------#
 DEFINE l_data LIKE docum_pgto.dat_pgto #OS 342848

 WHENEVER ERROR CONTINUE
 SELECT MAX(num_seq_docum)
   INTO p_docum_estorno.num_seq_docum
   FROM docum_estorno
  WHERE docum_estorno.cod_empresa   = p_docum_pgto.cod_empresa
    AND docum_estorno.num_docum     = p_docum_pgto.num_docum
    AND docum_estorno.ies_tip_docum = p_docum_pgto.ies_tip_docum
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET p_docum_estorno.num_seq_docum = 0
 END IF

 IF p_docum_estorno.num_seq_docum IS NULL THEN
    LET p_docum_estorno.num_seq_docum = 0
 END IF

 LET p_docum_estorno.num_seq_docum  = p_docum_estorno.num_seq_docum + 1
 LET p_docum_estorno.cod_empresa    = p_docum_pgto.cod_empresa
 LET p_docum_estorno.num_docum      = p_docum_pgto.num_docum
 LET p_docum_estorno.ies_tip_docum  = p_docum_pgto.ies_tip_docum
 LET p_docum_estorno.dat_pgto       = p_docum_pgto.dat_pgto
 LET p_docum_estorno.dat_credito    = p_docum_pgto.dat_credito
 LET p_docum_estorno.dat_lanc       = p_docum_pgto.dat_lanc

 IF mr_empresa_cre.ies_dat_contabil = "P" THEN
    LET p_docum_estorno.dat_pgto         = p_par_cre.dat_proces_bxa
 ELSE
    IF mr_empresa_cre.ies_dat_contabil  = "L" THEN
       LET p_docum_estorno.dat_lanc    = p_par_cre.dat_proces_bxa
    ELSE
       LET p_docum_estorno.dat_credito = p_par_cre.dat_proces_bxa
    END IF
 END IF

 LET p_docum_estorno.val_pago           = p_docum_pgto.val_pago
 LET p_docum_estorno.val_a_pagar        = p_docum_pgto.val_a_pagar
 LET p_docum_estorno.val_juro_pago      = p_docum_pgto.val_juro_pago
 LET p_docum_estorno.val_juro_a_pagar   = p_docum_pgto.val_juro_a_pagar
 LET p_docum_estorno.val_desc_conc      = p_docum_pgto.val_desc_conc
 LET p_docum_estorno.val_desc_a_conc    = p_docum_pgto.val_desc_a_conc
 LET p_docum_estorno.val_abat           = p_docum_pgto.val_abat
 LET p_docum_estorno.val_desp_cartorio  = p_docum_pgto.val_desp_cartorio
 LET p_docum_estorno.val_despesas       = p_docum_pgto.val_despesas
 LET p_docum_estorno.val_var_moeda      = p_docum_pgto.val_var_moeda
 LET p_docum_estorno.val_var_moeda_cont = p_docum_pgto.val_var_moeda_cont
 LET p_docum_estorno.val_multa_paga     = p_docum_pgto.val_multa_paga
 LET p_docum_estorno.val_multa_a_pagar  = p_docum_pgto.val_multa_a_pagar
 LET p_docum_estorno.val_ir_pago        = p_docum_pgto.val_ir_pago
 LET p_docum_estorno.ies_tip_pgto       = p_docum_pgto.ies_tip_pgto
 LET p_docum_estorno.ies_forma_pgto     = p_docum_pgto.ies_forma_pgto
 LET p_docum_estorno.cod_portador       = p_docum_pgto.cod_portador
 LET p_docum_estorno.ies_tip_portador   = p_docum_pgto.ies_tip_portador
 LET p_docum_estorno.num_lote_lanc_cont = p_docum_pgto.num_lote_lanc_cont
 LET p_docum_estorno.num_lote_pgto      = p_docum_pgto.num_lote_pgto
 LET p_docum_estorno.dat_atualiz        = p_docum_pgto.dat_atualiz
 LET p_docum_estorno.num_lote_contabil  = 0

 WHENEVER ERROR CONTINUE
 INSERT INTO docum_estorno VALUES (p_docum_estorno.*)
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("INCLUSAO","DOCUM_ESTORNO")
    RETURN FALSE
 END IF

 #342848
 IF mr_empresa_cre.ies_dat_contabil = "P" THEN
    LET l_data = p_docum_pgto.dat_pgto
 ELSE
    IF mr_empresa_cre.ies_dat_contabil  = "L" THEN
       LET l_data = p_docum_pgto.dat_lanc
    ELSE
       LET l_data = p_docum_pgto.dat_credito
    END IF
 END IF

 WHENEVER ERROR CONTINUE
 INSERT INTO cre_doc_estr_aux VALUES (p_docum_estorno.cod_empresa,
                                      p_docum_estorno.num_docum,
                                      p_docum_estorno.ies_tip_docum,
                                      p_docum_estorno.num_seq_docum,
                                      l_data)
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("INCLUSÃO","CRE_DOC_ESTR_AUX")
    RETURN FALSE
 END IF
 #fim

 RETURN TRUE

 END FUNCTION


#-----------------------------#
 FUNCTION geo1017_verifica_trb()
#-----------------------------#
 DEFINE l_empresa           LIKE conc_pgto.cod_empresa,
        l_lote              LIKE conc_pgto.num_lote,
        l_portador          LIKE conc_pgto.cod_portador,
        l_tip_portador      LIKE conc_pgto.ies_tip_portador,
        l_lote_trb          LIKE conc_pgto.num_lote_trb,
        l_mensagem          CHAR(70)

 DEFINE l_qtd_lote_trb      INTEGER

 INITIALIZE l_empresa, l_lote, l_portador, l_tip_portador, l_lote_trb,
            l_qtd_lote_trb, l_mensagem TO NULL

  IF m_ies_conc_bco_cxa = "S" AND
     p_docum_pgto.ies_tip_portador = "B" THEN
     IF m_parametro[413,413] = "S" THEN
        IF NOT geo1017_verifica_portador_banco() THEN
           LET l_mensagem = "Portador ", p_docum_pgto.cod_portador USING "<<<&",
           " nao cadastrado na PORTADOR_BANCO para a empresa ", p_docum_pgto.cod_empresa
           CALL log0030_mensagem(l_mensagem,"exclamation")
           RETURN FALSE
        END IF
     END IF

     LET m_integrou_trb = FALSE

     IF p_docum_pgto.ies_forma_pgto = "BC"
     OR p_docum_pgto.ies_forma_pgto = "CA" THEN
        WHENEVER ERROR CONTINUE
        SELECT *
          INTO p_docum_pgto_txt.*
          FROM docum_pgto_txt
         WHERE cod_empresa   = p_docum_pgto.cod_empresa
           AND num_docum     = p_docum_pgto.num_docum
           AND ies_tip_docum = p_docum_pgto.ies_tip_docum
           AND num_seq_docum = p_docum_pgto.num_seq_docum
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           IF p_docum_pgto_txt.parametros[53,57] > 0 THEN
              LET m_integrou_trb = TRUE
           END IF
        ELSE
           IF sqlca.sqlcode <> 100 THEN
              CALL log003_err_sql('SELECT','DOCUM_PGTO_TXT')
              RETURN FALSE
           ELSE
              LET m_integrou_trb = FALSE
           END IF
        END IF
     ELSE
        WHENEVER ERROR CONTINUE
        DECLARE cq_cons_conc_p CURSOR FOR
         SELECT DISTINCT
                cod_empresa, num_lote,
                cod_portador, ies_tip_portador,
                num_lote_trb, COUNT(*)
           FROM conc_pgto
          WHERE cod_empresa      = p_docum_pgto.cod_empresa
            AND num_lote         = p_docum_pgto.num_lote_pgto
            AND cod_portador     = p_docum_pgto.cod_portador
            AND ies_tip_portador = p_docum_pgto.ies_tip_portador
            AND num_lote_trb     > 0
          GROUP BY cod_empresa, num_lote, cod_portador, ies_tip_portador, num_lote_trb
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('SELECT','CONC_PGTO')
        END IF

        WHENEVER ERROR CONTINUE
           OPEN  cq_cons_conc_p
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('OPEN','CQ_CONS_CONC_P')
        END IF

        WHENEVER ERROR CONTINUE
           FETCH cq_cons_conc_p
            INTO l_empresa     ,
                 l_lote        ,
                 l_portador    ,
                 l_tip_portador,
                 l_lote_trb    ,
                 l_qtd_lote_trb
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           LET m_integrou_trb = TRUE
        END IF
     END IF
     IF m_integrou_trb THEN
        LET p_cod_portador = p_docum_pgto.cod_portador
        IF NOT geo1017_consulta_port_corresp() THEN
           IF p_docum_pgto.cod_portador > 999 THEN
              LET l_mensagem = "Portador ", p_docum_pgto.cod_portador CLIPPED,
              " nao cadastrado na PORT_CORRESP "
              CALL log0030_mensagem(l_mensagem,"exclamation")
              RETURN FALSE
           END IF
           LET p_cod_port_corresp = p_docum_pgto.cod_portador
        END IF
     END IF

  END IF

  RETURN TRUE

 END FUNCTION

#------------------------------------------#
 FUNCTION geo1017_verifica_portador_banco()
#------------------------------------------#
 WHENEVER ERROR CONTINUE
 SELECT *
   FROM portador_banco
  WHERE cod_empresa   = p_docum_pgto.cod_empresa
    AND cod_portador  = p_docum_pgto.cod_portador
    AND ies_tip_docum = p_docum_pgto.ies_tip_docum
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

END FUNCTION


#----------------------------------------#
 FUNCTION geo1017_pesquisa_empresa_cre()
#----------------------------------------#
 INITIALIZE mr_empresa_cre.*, mr_emp_cre_txt.* TO NULL

  WHENEVER ERROR CONTINUE
  SELECT *
    INTO mr_empresa_cre.*
    FROM empresa_cre
   WHERE cod_empresa = p_docum_pgto.cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     INITIALIZE mr_empresa_cre.* TO NULL
  END IF

  WHENEVER ERROR CONTINUE
  SELECT *
    INTO mr_emp_cre_txt.*
    FROM empresa_cre_txt
   WHERE cod_empresa = p_docum_pgto.cod_empresa
  IF sqlca.sqlcode <> 0 THEN
     INITIALIZE mr_emp_cre_txt.* TO NULL
  END IF
  WHENEVER ERROR STOP

END FUNCTION

#----------------------------------#
 FUNCTION geo1017_verifica_glosa(l_empresa,
                                  l_docum,
                                  l_tip_docum)
#----------------------------------#

 DEFINE l_empresa       LIKE docum_pgto.cod_empresa,
        l_docum         LIKE docum_pgto.num_docum,
        l_tip_docum     LIKE docum_pgto.ies_tip_docum,
        l_seq_docum     LIKE docum_pgto.num_seq_docum,
        l_forma_pgto    LIKE docum_pgto.ies_forma_pgto,
        l_cod_portador  LIKE docum_pgto.cod_portador,
        l_tip_portador  LIKE docum_pgto.ies_tip_portador,
        l_tem_glosa     SMALLINT

  LET l_tem_glosa = FALSE

  WHENEVER ERROR CONTINUE
   DECLARE cq_dados_pgto CURSOR FOR
   SELECT ies_forma_pgto,
          cod_portador,
          ies_tip_portador
     FROM docum_pgto
    WHERE cod_empresa    = l_empresa
      AND num_docum      = l_docum
      AND ies_tip_docum  = l_tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('SELECT','DOCUM_PGTO')
  END IF
  WHENEVER ERROR CONTINUE
  FOREACH cq_dados_pgto INTO l_forma_pgto,l_cod_portador,l_tip_portador
  WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
        IF l_forma_pgto   = m_cre_fma_pg_glosa AND
           l_cod_portador = m_cre_port_bxa_glosa AND
           l_tip_portador = m_cre_tip_port_glosa THEN
           LET l_tem_glosa = TRUE
        END IF
     ELSE
       RETURN FALSE
     END IF
  END FOREACH

  IF l_tem_glosa THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF

END FUNCTION

#------------------------------------------------------#
 FUNCTION geo1017_altera_docum(l_val_desc,l_val_glosa)
#------------------------------------------------------#
 DEFINE l_val_saldo_docum   DECIMAL(15,2),
        l_val_desc          DECIMAL(15,2),
        l_val_pago          DECIMAL(15,2),
        l_val_glosa         DECIMAL(15,2),
        l_tipo              INTEGER,
        l_seq_docum         INTEGER

  WHENEVER ERROR CONTINUE
   SELECT val_saldo
     INTO l_val_saldo_docum
     FROM docum
    WHERE cod_empresa   = p_adocum_pgto.cod_empresa
      AND num_docum     = p_adocum_pgto.num_docum
      AND ies_tip_docum = p_adocum_pgto.ies_tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_val_saldo_docum = 0
  END IF

  WHENEVER ERROR CONTINUE
   UPDATE docum SET val_saldo = (l_val_saldo_docum + l_val_desc)
    WHERE cod_empresa   = p_adocum_pgto.cod_empresa
      AND num_docum     = p_adocum_pgto.num_docum
      AND ies_tip_docum = p_adocum_pgto.ies_tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('MODIFICACAO','DOCUM')
     RETURN FALSE
  END IF

#  WHENEVER ERROR CONTINUE
#   SELECT MAX(num_seq_docum)
#     INTO l_seq_docum
#     FROM docum_pgto
#    WHERE cod_empresa   = p_adocum_pgto.cod_empresa
#      AND num_docum     = p_adocum_pgto.num_docum
#      AND ies_tip_docum = p_adocum_pgto.ies_tip_docum
#      AND num_lote_pgto = p_adocum_pgto.num_lote
#  WHENEVER ERROR STOP
#  IF sqlca.sqlcode = 0 THEN
#  END IF
#
#  LET l_seq_docum = l_seq_docum - 1
#
#  WHENEVER ERROR CONTINUE
#   SELECT val_pago
#     INTO l_val_pago
#     FROM docum_pgto
#    WHERE cod_empresa   = p_adocum_pgto.cod_empresa
#      AND num_docum     = p_adocum_pgto.num_docum
#      AND ies_tip_docum = p_adocum_pgto.ies_tip_docum
#      AND num_seq_docum = l_seq_docum
#  WHENEVER ERROR STOP
#  IF sqlca.sqlcode = 0 THEN
#  END IF
#
#  WHENEVER ERROR CONTINUE
#   UPDATE docum_pgto
#      SET val_pago = (l_val_pago - l_val_glosa)
#    WHERE cod_empresa   = p_adocum_pgto.cod_empresa
#      AND num_docum     = p_adocum_pgto.num_docum
#      AND ies_tip_docum = p_adocum_pgto.ies_tip_docum
#      AND num_seq_docum = l_seq_docum
#  WHENEVER ERROR STOP
#  IF sqlca.sqlcode = 0 THEN
#  END IF

  RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION geo1017_busca_val_glosa(l_cod_empresa,
                                   l_num_docum,
                                   l_ies_tip_docum)
#----------------------------------#
  DEFINE l_sequencia       INTEGER,
         l_val_glosa       DECIMAL(15,2),
         l_cod_empresa     CHAR(02),
         l_num_docum       CHAR(14),
         l_ies_tip_docum   CHAR(02)


  WHENEVER ERROR CONTINUE
   SELECT val_glosa
     INTO l_val_glosa
     FROM wglosa
    WHERE empresa    = l_cod_empresa
      AND docum      = l_num_docum
      AND tip_docum  = l_ies_tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 AND
     l_val_glosa IS NOT NULL AND
     l_val_glosa > 0 THEN
  ELSE
     LET l_sequencia = 0
     WHENEVER ERROR CONTINUE
     SELECT MAX(sequencia_docum)
       INTO l_sequencia
       FROM cre_info_adic_doc
      WHERE empresa   = l_cod_empresa
        AND docum     = l_num_docum
        AND tip_docum = l_ies_tip_docum
        AND campo     = "VALOR GLOSA"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET l_sequencia = 0
     END IF
     WHENEVER ERROR CONTINUE
      SELECT parametro_val
        INTO l_val_glosa
        FROM cre_info_adic_doc
       WHERE empresa   = l_cod_empresa
         AND docum     = l_num_docum
         AND tip_docum = l_ies_tip_docum
         AND sequencia_docum = l_sequencia
         AND campo     = "VALOR GLOSA"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET l_val_glosa = 0
     END IF
  END IF

  IF l_val_glosa IS NULL THEN
     LET l_val_glosa = 0
  END IF

  RETURN l_val_glosa

END FUNCTION

#------------------------------------------#
 FUNCTION geo1017_grava_adocum_pgto_capa()
#------------------------------------------#

  LET m_som_dat_pgto   = 0
  LET m_som_dat_cred   = 0
  LET m_som_val_titulo = 0
  LET m_som_val_desc   = 0
  LET m_som_qtd_docum  = 0
  LET m_som_dat_lanc   = 0
  LET m_som_val_juros  = 0
  LET m_som_val_abat   = 0

  WHENEVER ERROR CONTINUE
  SELECT som_dat_pgto, som_dat_cred, som_dat_lanc, som_val_titulo, som_val_juros,
         som_val_desc, som_val_abat, som_qtd_docum
    INTO m_som_dat_pgto,
         m_som_dat_cred,   m_som_dat_lanc,
         m_som_val_titulo, m_som_val_juros,
         m_som_val_desc,   m_som_val_abat,
         m_som_qtd_docum
    FROM adocum_pgto_capa
   WHERE cod_empresa      = mr_adocum_pgto.cod_empresa
     AND cod_portador     = mr_adocum_pgto.cod_portador
     AND ies_tip_portador = mr_adocum_pgto.ies_tip_portador
     AND num_lote         = mr_adocum_pgto.num_lote
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN

    LET mr_tela.dat_pgto = mr_adocum_pgto.dat_pgto
    LET mr_tela.dat_credito = mr_adocum_pgto.dat_credito

    CALL geo1017_busca_dat_decimal()

    LET m_som_dat_lanc = m_som_dat_lanc + m_dat_dec08
    LET m_som_dat_pgto = m_som_dat_pgto + m_dat_dec08
    LET m_som_dat_cred = m_som_dat_cred + m_dat_dec08

    LET m_som_val_titulo = m_som_val_titulo + mr_adocum_pgto.val_titulo
                                            + mr_adocum_pgto.val_juro
    LET m_som_val_juros  = m_som_val_juros  + mr_adocum_pgto.val_juro
    LET m_som_val_desc   = m_som_val_desc   + mr_adocum_pgto.val_desc
    LET m_som_val_abat   = m_som_val_abat   + 0
    LET m_som_qtd_docum  = m_som_qtd_docum  + 1

    IF m_som_dat_lanc IS NULL THEN
       LET m_som_dat_lanc = m_dat_dec08
    END IF

    IF m_som_dat_pgto IS NULL THEN
       LET m_som_dat_pgto = m_dat_dec08
    END IF

    IF m_som_dat_cred IS NULL THEN
       LET m_som_dat_cred = m_dat_dec08
    END IF

    WHENEVER ERROR CONTINUE
    UPDATE adocum_pgto_capa SET ies_sit_lote   = 'I',
                                som_dat_pgto   =  m_som_dat_pgto,
                                som_dat_cred   =  m_som_dat_cred,
                                som_dat_lanc   =  m_som_dat_lanc,
                                som_val_titulo =  m_som_val_titulo,
                                som_val_juros  =  m_som_val_juros,
                                som_val_desc   =  m_som_val_desc,
                                som_val_abat   =  m_som_val_abat,
                                som_qtd_docum  =  m_som_qtd_docum
     WHERE cod_empresa      = mr_adocum_pgto.cod_empresa
       AND cod_portador     = mr_adocum_pgto.cod_portador
       AND ies_tip_portador = mr_adocum_pgto.ies_tip_portador
       AND num_lote         = mr_adocum_pgto.num_lote
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
    END IF
 ELSE
    LET mr_tela.dat_pgto = mr_adocum_pgto.dat_pgto
    LET mr_tela.dat_credito = mr_adocum_pgto.dat_credito

    CALL geo1017_busca_dat_decimal()

    LET m_som_dat_pgto   = 0
    LET m_som_dat_cred   = 0
    LET m_som_val_titulo = 0
    LET m_som_val_desc   = 0
    LET m_som_qtd_docum  = 0
    LET m_som_dat_lanc   = 0
    LET m_som_val_juros  = 0
    LET m_som_val_abat   = 0

    LET m_som_dat_lanc = m_som_dat_lanc + m_dat_dec08
    LET m_som_dat_pgto = m_som_dat_pgto + m_dat_dec08
    LET m_som_dat_cred = m_som_dat_cred + m_dat_dec08

    LET m_som_val_titulo = m_som_val_titulo + mr_adocum_pgto.val_titulo
                                            + mr_adocum_pgto.val_juro
    LET m_som_val_juros  = m_som_val_juros  + mr_adocum_pgto.val_juro
    LET m_som_val_desc   = m_som_val_desc   + mr_adocum_pgto.val_desc
    LET m_som_val_abat   = m_som_val_abat   + 0
    LET m_som_qtd_docum  = m_som_qtd_docum  + 1

    IF m_som_dat_lanc IS NULL THEN
       LET m_som_dat_lanc = m_dat_dec08
    END IF

    IF m_som_dat_pgto IS NULL THEN
       LET m_som_dat_pgto = m_dat_dec08
    END IF

    IF m_som_dat_cred IS NULL THEN
       LET m_som_dat_cred = m_dat_dec08
    END IF

    WHENEVER ERROR CONTINUE
    INSERT INTO adocum_pgto_capa
           VALUES(mr_adocum_pgto.cod_empresa      ,
                  mr_adocum_pgto.cod_portador     ,
                  mr_adocum_pgto.ies_tip_portador ,
                  mr_adocum_pgto.num_lote         ,
                  'I'                             ,
                  m_som_dat_pgto                  ,
                  m_som_dat_cred                  ,
                  m_som_dat_lanc                  ,
                  m_som_val_titulo                ,
                  m_som_val_juros                 ,
                  m_som_val_desc                  ,
                  m_som_val_abat                  ,
                  m_som_qtd_docum)
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       IF cre1590_monta_wcre1591('Erro na gravação da capa do lote da baixa (ADOCUM_PGTO_CAPA).') = FALSE THEN
          RETURN FALSE
       END IF
    END IF
 END IF

 IF m_empresa_trb IS NULL THEN
    LET m_empresa_trb = mr_adocum_pgto.cod_empresa
 END IF

END FUNCTION

#---------------------------------#
 FUNCTION geo1017_guarda_valores()
#---------------------------------#
 LET m_total = 0

  LET m_total =  ((mr_tela.val_saldo + mr_tela.val_juro_pago + mr_tela.val_desp_cartorio + mr_tela.val_despesas +
                   mr_tela.val_multa) - mr_tela.val_desc_conc - mr_tela.val_glosa)


END FUNCTION

#-----------------------------------#
 FUNCTION geo1017_verifica_valores()
#-----------------------------------#
  DEFINE l_total  DECIMAL(15,2)

  IF m_total IS NULL OR
     m_total = 0 THEN
     RETURN TRUE
  ELSE
     LET l_total = (m_total_saldo - m_total_desc) + m_total_juro
     IF l_total <> m_total THEN
        CALL log0030_mensagem('Lote não fechou.','exclamation')
        LET m_total = 0
        RETURN FALSE
     ELSE
        RETURN TRUE
     END IF
  END IF

END FUNCTION

#-------------------------------------------#
 FUNCTION geo1017_inclui_glosa_info_adic()
#-------------------------------------------#
  DEFINE  l_num_seq         INTEGER

  WHENEVER ERROR CONTINUE
   SELECT MAX(sequencia_docum)
     INTO l_num_seq
     FROM cre_info_adic_doc
    WHERE cre_info_adic_doc.empresa          = p_adocum_pgto.cod_empresa
      AND cre_info_adic_doc.docum            = p_adocum_pgto.num_docum
      AND cre_info_adic_doc.tip_docum        = p_adocum_pgto.ies_tip_docum
      AND cre_info_adic_doc.campo            = 'VALOR GLOSA'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_num_seq = 1
  ELSE
     IF l_num_seq IS NULL THEN
        LET l_num_seq = 1
     ELSE
        LET l_num_seq = l_num_seq + 1
     END IF
  END IF

  WHENEVER ERROR CONTINUE
  INSERT INTO cre_info_adic_doc VALUES (p_adocum_pgto.cod_empresa,
                                        p_adocum_pgto.num_docum,
                                        p_adocum_pgto.ies_tip_docum,
                                        l_num_seq,
                                        'VALOR GLOSA',
                                        NULL,
                                        NULL,
                                        p_adocum_pgto.val_desc,
                                        NULL,
                                        NULL)
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF cre1590_monta_wcre1591('Erro na gravação da glosa (CRE_INFO_ADIC_DOC).') = FALSE THEN
        RETURN FALSE
     END IF
  END IF

END FUNCTION

#------------------------------------------------------------------------------#
 FUNCTION geo1017_insert_cre_pagto_det_cpl(l_num_lot,l_num_seq,l_campo,l_dat_cre_det,l_empresa_trb)
#------------------------------------------------------------------------------#
  DEFINE l_num_lot             LIKE cre_pagto_det_cpl.lote,
         l_num_seq             LIKE cre_pagto_det_cpl.seq_pagto_docum,
         l_dat_cre_det         LIKE cre_pagto_det_cpl.parametro_dat,
         l_campo               LIKE cre_pagto_det_cpl.campo_refer,
         l_empresa_trb         LIKE docum.cod_empresa,
         lr_cre_pagto_det_cpl  RECORD LIKE cre_pagto_det_cpl.*

  LET lr_cre_pagto_det_cpl.empresa            = mr_adocum_pgto.cod_empresa
  LET lr_cre_pagto_det_cpl.lote               = l_num_lot
  LET lr_cre_pagto_det_cpl.portador           = mr_adocum_pgto.cod_portador
  LET lr_cre_pagto_det_cpl.tip_portador       = mr_adocum_pgto.ies_tip_portador
  LET lr_cre_pagto_det_cpl.empresa_docum      = mr_adocum_pgto.cod_empresa
  LET lr_cre_pagto_det_cpl.docum              = mr_adocum_pgto.num_docum
  LET lr_cre_pagto_det_cpl.tip_docum          = mr_adocum_pgto.ies_tip_docum
  LET lr_cre_pagto_det_cpl.seq_pagto_docum    = l_num_seq

  IF l_campo IS NULL THEN
     LET lr_cre_pagto_det_cpl.campo_refer     = NULL
     LET lr_cre_pagto_det_cpl.parametro_texto = NULL
     LET lr_cre_pagto_det_cpl.parametro_dat   = l_dat_cre_det
  ELSE
     LET lr_cre_pagto_det_cpl.campo_refer     = l_campo
     LET lr_cre_pagto_det_cpl.parametro_texto = l_empresa_trb
     LET lr_cre_pagto_det_cpl.parametro_dat   = NULL
  END IF

  WHENEVER ERROR CONTINUE
    INSERT INTO cre_pagto_det_cpl (cre_pagto_det_cpl.empresa         ,
                                   cre_pagto_det_cpl.lote            ,
                                   cre_pagto_det_cpl.portador        ,
                                   cre_pagto_det_cpl.tip_portador    ,
                                   cre_pagto_det_cpl.empresa_docum   ,
                                   cre_pagto_det_cpl.docum           ,
                                   cre_pagto_det_cpl.tip_docum       ,
                                   cre_pagto_det_cpl.seq_pagto_docum ,
                                   cre_pagto_det_cpl.campo_refer     ,
                                   cre_pagto_det_cpl.parametro_texto ,
                                   cre_pagto_det_cpl.parametro_dat   )
        VALUES (lr_cre_pagto_det_cpl.empresa          ,
                lr_cre_pagto_det_cpl.lote             ,
                lr_cre_pagto_det_cpl.portador         ,
                lr_cre_pagto_det_cpl.tip_portador     ,
                lr_cre_pagto_det_cpl.empresa_docum    ,
                lr_cre_pagto_det_cpl.docum            ,
                lr_cre_pagto_det_cpl.tip_docum        ,
                lr_cre_pagto_det_cpl.seq_pagto_docum  ,
                lr_cre_pagto_det_cpl.campo_refer      ,
                lr_cre_pagto_det_cpl.parametro_texto  ,
                lr_cre_pagto_det_cpl.parametro_dat    )
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("INSERT","CRE_PAGTO_DET_CPL")
     RETURN FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#------------------------------------------#
 FUNCTION geo1017_busca_log2250(l_cod_emp)
#------------------------------------------#
  DEFINE l_cod_emp                   LIKE empresa.cod_empresa
  DEFINE l_status                    SMALLINT
  DEFINE l_msg                       CHAR(160)

  # Verifica parametro e caso esteje setado: 'cre_most_tela_doc'
  INITIALIZE m_cre_most_tela_doc,l_status TO NULL
  CALL log2250_busca_parametro(l_cod_emp,'cre_most_tela_doc')  RETURNING m_cre_most_tela_doc, l_status
  IF   l_status = FALSE OR m_cre_most_tela_doc IS NULL OR m_cre_most_tela_doc = ' '
  THEN LET m_cre_most_tela_doc = 'S'
  END IF


  # Busca parâmetro para verificar se a empresa utiliza controle de data de crédito na capa ou detalhe pagamento
  INITIALIZE m_dat_cre_capa_cncl,l_status TO NULL
  CALL log2250_busca_parametro(l_cod_emp,'dat_cre_capa_cncl')  RETURNING m_dat_cre_capa_cncl, l_status
  IF   l_status = FALSE OR m_dat_cre_capa_cncl IS NULL OR m_dat_cre_capa_cncl = " "
  THEN LET m_dat_cre_capa_cncl = "N"
  END IF

  # busca forma, portador e tipo de portador do cre para o GLOSA.
  INITIALIZE m_cre_fma_pg_glosa,l_status TO NULL
  CALL log2250_busca_parametro(l_cod_emp,'cre_fma_pg_glosa')   RETURNING m_cre_fma_pg_glosa, l_status
  IF   l_status = FALSE OR m_cre_fma_pg_glosa  IS NULL OR m_cre_fma_pg_glosa   = ' '
  THEN INITIALIZE m_cre_fma_pg_glosa TO NULL
  END IF
  INITIALIZE m_cre_port_bxa_glosa,l_status TO NULL
  CALL log2250_busca_parametro(l_cod_emp,'cre_port_bxa_glosa') RETURNING m_cre_port_bxa_glosa, l_status
  IF   l_status = FALSE OR m_cre_port_bxa_glosa IS NULL OR m_cre_port_bxa_glosa = ' '
  THEN INITIALIZE m_cre_port_bxa_glosa TO NULL
  END IF
  INITIALIZE m_cre_tip_port_glosa,l_status TO NULL
  CALL log2250_busca_parametro(l_cod_emp,'cre_tip_port_glosa') RETURNING m_cre_tip_port_glosa, l_status
  IF   l_status = FALSE OR m_cre_tip_port_glosa IS NULL OR m_cre_tip_port_glosa = ' '
  THEN INITIALIZE m_cre_tip_port_glosa TO NULL
  END IF

  {IF (m_cre_fma_pg_glosa   IS NULL OR m_cre_fma_pg_glosa   = ' ') OR
     (m_cre_port_bxa_glosa IS NULL OR m_cre_port_bxa_glosa = ' ') OR
     (m_cre_tip_port_glosa IS NULL OR m_cre_tip_port_glosa = ' ') THEN
     LET l_msg = "Os parâmetros de glosa não estão cadastrados corretamente para empresa ", l_cod_emp, "."
     CALL log0030_mensagem(l_msg CLIPPED,'exclamation')
     RETURN FALSE
   END IF}

 RETURN TRUE

 END FUNCTION

#----------------------------------------#
 FUNCTION geo1017_verifica_cod_tip_cli()
#----------------------------------------#
 DEFINE l_den_tip_cli LIKE tipo_cliente.den_tip_cli

 LET l_den_tip_cli = NULL

 WHENEVER ERROR CONTINUE
   SELECT den_tip_cli
     INTO l_den_tip_cli
     FROM tipo_cliente
    WHERE tipo_cliente.cod_tip_cli = mr_docum_aberto.cod_tip_cli
 WHENEVER ERROR STOP
 CASE sqlca.sqlcode
    WHEN 0
       #DISPLAY l_den_tip_cli TO den_tip_cli
       RETURN TRUE
    WHEN 100
       CALL log0030_mensagem("Tipo de cliente não cadastrado.","Info")
       RETURN FALSE

    OTHERWISE
       CALL log003_err_sql("SELECT","TIPO_CLIENTE")
       RETURN FALSE

 END CASE

 END FUNCTION

#-----------------------------------#
 FUNCTION geo1017_grava_conc_pgto()
#-----------------------------------#
{USO INTERNO
 OBJETIVO: Efetuar gravação da Concialiação do Pagamento com o TRB na tabela
           CONC_PGTO.

           Os valores a serem conciliados, são informados na tela principal, e não
           possuem empresa de cada de lote, igual ao cre3580, será utilizado a
           primeira empresa da pgto_capa.
}
  DEFINE l_ind             SMALLINT,
         l_val_concil      LIKE conc_pgto.val_concil,
         l_dat_credito     LIKE conc_pgto.dat_cred

  IF m_empresa_trb IS NULL OR m_empresa_trb = " " THEN
     LET m_empresa_trb = p_cod_empresa
  END IF

  INITIALIZE m_num_seq_conc_trb TO NULL

  WHENEVER ERROR CONTINUE
  SELECT MAX(num_seq_conc)
    INTO m_num_seq_conc_trb
    FROM conc_pgto
   WHERE conc_pgto.cod_empresa      = m_empresa_trb
     AND conc_pgto.num_lote         = m_num_lot
     AND conc_pgto.cod_portador     = mr_dados_pagto.portador1
     AND conc_pgto.ies_tip_portador = mr_dados_pagto.tip_portador1
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("SELECT MAX","CONC_PGTO")
     RETURN FALSE
  END IF

  IF m_num_seq_conc_trb IS NULL THEN
     LET m_num_seq_conc_trb = 0
  END IF

  #Quando não abre tela de consulta, deve ser utilizado os dados da tela na integração com o TRB pois não temos o array da tela principal
  IF m_cre_most_tela_doc <> "S" THEN

     LET l_val_concil = mr_tela.val_saldo
                        + (mr_tela.val_juro_pago +
                           mr_tela.val_desp_cartorio +
                           mr_tela.val_despesas +
                           mr_tela.val_multa)
                        - (mr_tela.val_desc_conc +
                           mr_tela.val_glosa)

     IF l_val_concil > 0 THEN

        LET m_num_seq_conc_trb = m_num_seq_conc_trb + 1
        LET l_dat_credito      = mr_tela.dat_credito

        WHENEVER ERROR CONTINUE
        INSERT INTO conc_pgto (cod_empresa       ,
                               num_lote          ,
                               cod_portador      ,
                               ies_tip_portador  ,
                               num_seq_conc      ,
                               dat_cred          ,
                               val_concil        ,
                               deb_cred          ,
                               num_lote_trb      )
                       VALUES (m_empresa_trb                ,
                               m_num_lot                    ,
                               mr_dados_pagto.portador1     ,
                               mr_dados_pagto.tip_portador1 ,
                               m_num_seq_conc_trb           ,
                               l_dat_credito                ,
                               l_val_concil                 ,
                               'C'                          ,
                               0                            )
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           IF cre1590_monta_wcre1591('Erro na gravação da conciliação deste lote de baixa (CONC_PGTO).') = FALSE THEN
              RETURN FALSE
           END IF
           RETURN FALSE
        END IF

        IF m_ies_conc_bco_cxa = 'S' AND m_parametro[413] = 'S' THEN
           #Integração online com o TRB
           CALL geo1017_integra_trb()
        END IF
     END IF
  ELSE
     INITIALIZE ma_outros_conc_pgto TO NULL

     FOR l_ind=1 TO 100

        IF ma_outros[l_ind].dat_cred  IS NOT NULL AND
           ma_outros[l_ind].tot_pagto IS NOT NULL AND
           ma_outros[l_ind].tot_pagto > 0         THEN

           LET m_num_seq_conc_trb = m_num_seq_conc_trb + 1
           LET l_val_concil       = ma_outros[l_ind].tot_pagto
           LET l_dat_credito      = ma_outros[l_ind].dat_cred

           WHENEVER ERROR CONTINUE
           INSERT INTO conc_pgto (cod_empresa       ,
                                  num_lote          ,
                                  cod_portador      ,
                                  ies_tip_portador  ,
                                  num_seq_conc      ,
                                  dat_cred          ,
                                  val_concil        ,
                                  deb_cred          ,
                                  num_lote_trb      )
                          VALUES (m_empresa_trb                ,
                                  m_num_lot                    ,
                                  mr_dados_pagto.portador1     ,
                                  mr_dados_pagto.tip_portador1 ,
                                  m_num_seq_conc_trb           ,
                                  l_dat_credito                ,
                                  l_val_concil                 ,
                                  'C'                          ,
                                  0                            )
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              IF cre1590_monta_wcre1591('Erro na gravação da conciliação deste lote de baixa (CONC_PGTO).') = FALSE THEN
                 RETURN FALSE
              END IF
              RETURN FALSE
           END IF

           LET ma_outros_conc_pgto[l_ind].empresa      = m_empresa_trb
           LET ma_outros_conc_pgto[l_ind].lote         = m_num_lot
           LET ma_outros_conc_pgto[l_ind].portador     = mr_dados_pagto.portador1
           LET ma_outros_conc_pgto[l_ind].tip_portador = mr_dados_pagto.tip_portador1
           LET ma_outros_conc_pgto[l_ind].sequencia    = m_num_seq_conc_trb

        ELSE
           EXIT FOR
        END IF
     END FOR

     IF m_ies_conc_bco_cxa = 'S' AND m_parametro[413] = 'S' THEN
        FOR l_ind=1 TO 100
           IF ma_outros_conc_pgto[l_ind].empresa IS NULL THEN
              EXIT FOR
           END IF

           LET m_empresa_trb                = ma_outros_conc_pgto[l_ind].empresa
           LET m_num_lot                    = ma_outros_conc_pgto[l_ind].lote
           LET mr_dados_pagto.portador1     = ma_outros_conc_pgto[l_ind].portador
           LET mr_dados_pagto.tip_portador1 = ma_outros_conc_pgto[l_ind].tip_portador
           LET m_num_seq_conc_trb           = ma_outros_conc_pgto[l_ind].sequencia
           #A integração tem que ser executada após TODOS os inserts na CONC_PGTO

           #Integração online com o TRB
           CALL geo1017_integra_trb()

        END FOR
     END IF
  END IF

  RETURN TRUE

 END FUNCTION
#------------------------------------------#
 FUNCTION geo1017_consiste_conhecimento()
#------------------------------------------#

 IF m_abre_tela_especifica = TRUE THEN

    #Se o tipo de pagamento for saldo ou integral, não vai ser aberto a entrada de dados
    #para escolher os registros, neste caso todos os registros serão considerados liquidados.
    IF mr_adocum_pgto.ies_tip_pgto = "S" OR mr_adocum_pgto.ies_tip_pgto = "N" THEN

       #Não precisa chamar Find4GLFunction, poir já valida a variável M_ABRE_TELA_ESPECIFICA
       IF NOT crey42_carrega_conhecimento(mr_adocum_pgto.cod_empresa  ,
                                          mr_adocum_pgto.num_docum    ,
                                          mr_adocum_pgto.ies_tip_docum,
                                          mr_adocum_pgto.ies_tip_pgto ,
                                          m_num_lot                   ) THEN

          WHENEVER ERROR CONTINUE
              CALL log085_transacao('ROLLBACK')
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("TRANSACAO","ROLLBACK")
          END IF

          RETURN FALSE
       END IF

       #Não precisa chamar Find4GLFunction, poir já valida a variável M_ABRE_TELA_ESPECIFICA
       IF NOT crey42_grava_temp_conhecimento(mr_adocum_pgto.cod_empresa  ,
                                             mr_adocum_pgto.num_docum    ,
                                             mr_adocum_pgto.ies_tip_docum) THEN

          WHENEVER ERROR CONTINUE
              CALL log085_transacao('ROLLBACK')
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("TRANSACAO","ROLLBACK")
          END IF

          RETURN FALSE
       END IF

    END IF

    #Não precisa chamar Find4GLFunction, poir já valida a variável M_ABRE_TELA_ESPECIFICA
    IF NOT crey42_grava_cre_pagto_det_cpl(mr_adocum_pgto.cod_empresa     ,
                                          m_num_lot                      ,
                                          mr_adocum_pgto.cod_portador    ,
                                          mr_adocum_pgto.ies_tip_portador,
                                          mr_adocum_pgto.cod_empresa     ,
                                          mr_adocum_pgto.num_docum       ,
                                          mr_adocum_pgto.ies_tip_docum   ) THEN
       WHENEVER ERROR CONTINUE
           CALL log085_transacao('ROLLBACK')
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("TRANSACAO","ROLLBACK")
       END IF

       RETURN FALSE
    END IF
 END IF
 #Se o tipo de pagamento for saldo ou integral, não vai ser aberto a entrada de dados
 #para escolher os registros, neste caso todos os registros serão considerados liquidados.
 IF mr_adocum_pgto.ies_tip_pgto = "S" OR mr_adocum_pgto.ies_tip_pgto = "N" THEN

    IF log_existe_epl("geo1017y_carrega_conhecimento") THEN

       CALL LOG_setVar( "PRG_cod_empresa",      mr_adocum_pgto.cod_empresa     )
       CALL LOG_setVar( "PRG_num_docum",        mr_adocum_pgto.num_docum       )
       CALL LOG_setVar( "PRG_ies_tip_docum",    mr_adocum_pgto.ies_tip_docum   )
       CALL LOG_setVar( "PRG_ies_tip_pgto",     mr_adocum_pgto.ies_tip_pgto    )
       CALL LOG_setVar( "PRG_num_lote",         m_num_lot                      )

       IF NOT geo1017y_carrega_conhecimento() THEN
          WHENEVER ERROR CONTINUE
              CALL log085_transacao('ROLLBACK')
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("TRANSACAO","ROLLBACK")
          END IF

          RETURN
       END IF
    END IF
    IF log_existe_epl("geo1017y_grava_temp_conhecimento") THEN

       CALL LOG_setVar( "PRG_cod_empresa",      mr_adocum_pgto.cod_empresa     )
       CALL LOG_setVar( "PRG_num_docum",        mr_adocum_pgto.num_docum       )
       CALL LOG_setVar( "PRG_ies_tip_docum",    mr_adocum_pgto.ies_tip_docum   )

       IF NOT geo1017y_grava_temp_conhecimento() THEN
          WHENEVER ERROR CONTINUE
              CALL log085_transacao('ROLLBACK')
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("TRANSACAO","ROLLBACK")
          END IF

          RETURN
       END IF
    END IF
 END IF
 IF log_existe_epl("geo1017y_grava_cre_pagto_det_cpl") THEN

    CALL LOG_setVar( "PRG_cod_empresa",      mr_adocum_pgto.cod_empresa     )
    CALL LOG_setVar( "PRG_num_lote",         m_num_lot                      )
    CALL LOG_setVar( "PRG_cod_portador",     mr_adocum_pgto.cod_portador    )
    CALL LOG_setVar( "PRG_ies_tip_portador", mr_adocum_pgto.ies_tip_portador)
    CALL LOG_setVar( "PRG_empresa_docum",    mr_adocum_pgto.cod_empresa    )
    CALL LOG_setVar( "PRG_num_docum",        mr_adocum_pgto.num_docum       )
    CALL LOG_setVar( "PRG_ies_tip_docum",    mr_adocum_pgto.ies_tip_docum   )

    IF NOT geo1017y_grava_cre_pagto_det_cpl() THEN
       WHENEVER ERROR CONTINUE
           CALL log085_transacao('ROLLBACK')
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("TRANSACAO","ROLLBACK")
       END IF

       RETURN
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#--------------------------------------#
 FUNCTION geo1017_carrega_dados_tela()
#--------------------------------------#
  DEFINE l_ies_forma_pgto      LIKE adocum_pgto.ies_forma_pgto   ,
         l_dat_pgto            LIKE adocum_pgto.dat_pgto         ,
         l_dat_credito         LIKE adocum_pgto.dat_credito      ,
         l_val_titulo          LIKE adocum_pgto.val_titulo       ,
         l_val_desc_conc       LIKE adocum_pgto.val_desc         ,
         l_val_juro_pago       LIKE adocum_pgto.val_juro         ,
         l_ies_abono_juros     LIKE adocum_pgto.ies_abono_juros  ,
         l_val_desp_cartorio   LIKE adocum_pgto.val_desp_cartorio,
         l_val_despesas        LIKE adocum_pgto.val_despesas     ,
         l_val_multa           LIKE adocum_pgto.val_multa

  INITIALIZE l_ies_forma_pgto   ,
             l_dat_pgto         ,
             l_dat_credito      ,
             l_val_titulo       ,
             l_val_desc_conc    ,
             l_val_juro_pago    ,
             l_ies_abono_juros  ,
             l_val_desp_cartorio,
             l_val_despesas     ,
             l_val_multa        TO NULL

  WHENEVER ERROR CONTINUE
     SELECT ies_forma_pgto   ,
            dat_pgto         ,
            dat_credito      ,
            val_titulo       ,
            val_desc         ,
            val_juro         ,
            ies_abono_juros  ,
            val_desp_cartorio,
            val_despesas     ,
            val_multa
       INTO l_ies_forma_pgto   ,
            l_dat_pgto         ,
            l_dat_credito      ,
            l_val_titulo       ,
            l_val_desc_conc    ,
            l_val_juro_pago    ,
            l_ies_abono_juros  ,
            l_val_desp_cartorio,
            l_val_despesas     ,
            l_val_multa
       FROM adocum_pgto
      WHERE cod_empresa      = mr_tela.cod_empresa
        AND cod_portador     = mr_tela.cod_portador
        AND ies_tip_portador = mr_tela.ies_tip_portador
        AND num_lote         = m_num_lot
        AND num_docum        = mr_tela.num_docum
        AND ies_tip_docum    = mr_tela.ies_tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN

     LET mr_tela.ies_forma_pgto    = l_ies_forma_pgto
     LET mr_tela.dat_pgto          = l_dat_pgto
     LET mr_tela.dat_credito       = l_dat_credito
     LET mr_tela.val_saldo         = l_val_titulo
     LET mr_tela.val_desc_conc     = l_val_desc_conc
     LET mr_tela.val_juro_pago     = l_val_juro_pago
     LET mr_tela.ies_abono_juros   = l_ies_abono_juros
     LET mr_tela.val_desp_cartorio = l_val_desp_cartorio
     LET mr_tela.val_despesas      = l_val_despesas
     LET mr_tela.val_multa         = l_val_multa

  ELSE
     IF sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("SELECT","DOCUM_PGTO-TELA")
     END IF
  END IF

 END FUNCTION

#-------------------------------------------------#
 FUNCTION geo1017_busca_atualiza_lote_pagamento()
#-------------------------------------------------#
  DEFINE l_parametro     LIKE par_cre_txt.parametro

  INITIALIZE l_parametro TO NULL

  WHENEVER ERROR CONTINUE
  DECLARE cq_par_lote CURSOR FOR
    SELECT parametro
      FROM par_cre_txt
      FOR UPDATE
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('SELECT','PAR_CRE_TXT')
  END IF

  CALL log085_transacao("BEGIN")
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('BEGIN','PAR_CRE_TXT')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  OPEN cq_par_lote
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('OPEN CURSOR','CQ_PAR_LOTE')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  FETCH cq_par_lote INTO l_parametro
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN

     IF  l_parametro[92,99] IS NOT NULL
     AND l_parametro[92,99] <> ' '  THEN
        LET m_num_lot = l_parametro[92,99]
     ELSE
        LET m_num_lot = 0
     END IF

     LET m_num_lot = m_num_lot + 1
     LET l_parametro[92,99] = m_num_lot USING "&&&&&&&&"

     WHENEVER ERROR CONTINUE
      UPDATE par_cre_txt
         SET parametro = l_parametro
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
        CALL log085_transacao("COMMIT")
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('COMMIT','PAR_CRE_TXT')
           CALL log085_transacao("ROLLBACK")
           RETURN FALSE
        END IF
     ELSE
        CALL log003_err_sql('UPDATE','PAR_CRE_TXT')
        CALL log085_transacao("ROLLBACK")
        RETURN FALSE
     END IF
  ELSE
     CASE sqlca.sqlcode
        WHEN  -250 CALL log0030_mensagem( 'Registro sendo atualizado por outro usuario. Aguarde e tente novamente. ','exclamation')
        WHEN   100 CALL log0030_mensagem( 'Registro não mais existe na tabela. Execute a CONSULTA novamente. ','exclamation')
        OTHERWISE  CALL log003_err_sql  ('LEITURA','ADOCUM_PGTO')
     END CASE
     CALL log085_transacao("ROLLBACK")
     RETURN FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#-----------------------------------------------------------#
 FUNCTION geo1017_busca_cre_tit_cob_esp(l_cod_empresa  ,
                                         l_num_docum    ,
                                         l_ies_tip_docum,
                                         l_ies_tip_cobr)
#-----------------------------------------------------------#
  DEFINE l_cod_empresa         LIKE docum.cod_empresa
  DEFINE l_num_docum           LIKE docum.num_docum
  DEFINE l_ies_tip_docum       LIKE docum.ies_tip_docum
  DEFINE l_ies_tip_cobr        LIKE docum.ies_tip_cobr

  DEFINE l_val_saldo_cliente   LIKE cre_tit_cob_esp.val_saldo_cliente
  DEFINE l_val_parcela_cliente LIKE cre_tit_cob_esp.val_parcela_cliente

  WHENEVER ERROR CONTINUE
    SELECT val_parcela_cliente,
           val_saldo_cliente
      INTO l_val_parcela_cliente,
           l_val_saldo_cliente
      FROM cre_tit_cob_esp
     WHERE empresa      = l_cod_empresa
       AND docum        = l_num_docum
       AND tip_docum    = l_ies_tip_docum
       AND tip_cobranca = l_ies_tip_cobr
       AND ativo        = "S"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("SELECT","CRE_TIT_COB_ESP")
  END IF

  IF l_val_parcela_cliente IS NULL THEN
     LET l_val_parcela_cliente = 0
  END IF

  IF l_val_saldo_cliente IS NULL THEN
     LET l_val_saldo_cliente = 0
  END IF

  RETURN l_val_saldo_cliente

 END FUNCTION

#--------------------------------------------------#
 FUNCTION geo1017_atualiza_vendor(l_empresa      ,
                                   l_docum        ,
                                   l_tip_docum    ,
                                   l_pgto_dat_pgto,
                                   l_ies_tip_pgto )
#--------------------------------------------------#
  DEFINE l_empresa            LIKE docum.cod_empresa
  DEFINE l_docum              LIKE docum.num_docum
  DEFINE l_tip_docum          LIKE docum.ies_tip_docum
  DEFINE l_pgto_dat_pgto      DATE
  DEFINE l_ies_tip_pgto       LIKE docum_pgto.ies_tip_pgto
  DEFINE l_dat_vencto_s_desc  DATE
  DEFINE l_dat_prorrogada     DATE
  DEFINE l_dat_vencto         DATE
  DEFINE l_tip_pgto_vendor    SMALLINT
  DEFINE l_ies_tip_cobr       LIKE docum.ies_tip_cobr
  DEFINE l_cod_cliente        LIKE docum.cod_cliente
  DEFINE lr_cre_tit_cob_esp   RECORD LIKE cre_tit_cob_esp.*
  DEFINE l_msg                CHAR(200)

  WHENEVER ERROR CONTINUE
    SELECT ies_tip_cobr, dat_vencto_s_desc, dat_prorrogada, cod_cliente
      INTO l_ies_tip_cobr, l_dat_vencto_s_desc, l_dat_prorrogada, l_cod_cliente
      FROM docum
     WHERE cod_empresa   = l_empresa
       AND num_docum     = l_docum
       AND ies_tip_docum = l_tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR l_ies_tip_cobr IS NULL THEN
     LET l_ies_tip_cobr = "S"
  END IF

  IF l_dat_prorrogada IS NOT NULL THEN
     LET l_dat_vencto = l_dat_prorrogada
  ELSE
     LET l_dat_vencto = l_dat_vencto_s_desc
  END IF

  IF l_ies_tip_cobr = "V" THEN
     CALL geo1017_leitura_params_portador()

     CALL geo1017_verifica_liquidacao_vendor(l_dat_vencto   ,
                                              l_cod_cliente  ,
                                              l_pgto_dat_pgto)
     RETURNING l_tip_pgto_vendor

     CASE l_tip_pgto_vendor
        WHEN 1 #Pagto antecipado
           #Calcula os novos valores devidos, e cria um registro na cre_vendor_titulo
           IF NOT crer44_recalcula_valores_vendor(l_empresa      ,
                                                  l_docum        ,
                                                  l_tip_docum    ,
                                                  l_pgto_dat_pgto,
                                                  NULL           ,
                                                  NULL           ,
                                                  NULL           ,
                                                  NULL           ,
                                                  0              ,
                                                  'A'            ) THEN
              LET l_msg = log0030_mensagem_get_texto()
              CALL log0030_mensagem(l_msg,"Exclamation")
              RETURN FALSE
           END IF

           CALL crer44_get_cre_tit_cob_esp() RETURNING lr_cre_tit_cob_esp.*

           IF NOT lr_cre_tit_cob_esp.versao IS NULL THEN
              #LET lr_cre_vendor_titulo.sit_tit_cobranca = "L"
              LET lr_cre_tit_cob_esp.lote_pagamento    = m_num_lot

              IF NOT crer44_inclui_cre_tit_cob_esp(lr_cre_tit_cob_esp.*) THEN
                 LET l_msg = log0030_mensagem_get_texto()
                 CALL log0030_mensagem(l_msg,"Exclamation")
                 RETURN FALSE
              END IF

              #Lê o novo registro da cre_vendor_titulo calculado pela RNL crer44
              CALL crer44_get_cre_tit_cob_esp() RETURNING lr_cre_tit_cob_esp.*

              IF l_ies_tip_pgto = "N"
              OR l_ies_tip_pgto = "S" THEN
                 LET lr_cre_tit_cob_esp.sit_tit_cobranca = "T"
              ELSE
                 LET lr_cre_tit_cob_esp.sit_tit_cobranca = "P"
              END IF

              LET lr_cre_tit_cob_esp.lote_pagamento    = m_num_lot

              IF NOT crer44_inclui_cre_tit_cob_esp(lr_cre_tit_cob_esp.*) THEN
                 LET l_msg = log0030_mensagem_get_texto()
                 CALL log0030_mensagem(l_msg,"Exclamation")
                 RETURN FALSE
              END IF
           END IF

        WHEN 2 #No prazo
           CALL crer44_leitura_cre_tit_cob_esp(l_empresa  ,
                                               l_docum    ,
                                               l_tip_docum,
                                               l_ies_tip_cobr,0) RETURNING lr_cre_tit_cob_esp.*

           IF NOT lr_cre_tit_cob_esp.versao IS NULL THEN
              IF l_ies_tip_pgto = "N"
              OR l_ies_tip_pgto = "S" THEN
                 LET lr_cre_tit_cob_esp.sit_tit_cobranca = "T"
              ELSE
                 LET lr_cre_tit_cob_esp.sit_tit_cobranca = "P"
              END IF

              LET lr_cre_tit_cob_esp.lote_pagamento    = m_num_lot

              IF NOT crer44_inclui_cre_tit_cob_esp(lr_cre_tit_cob_esp.*) THEN
                 LET l_msg = log0030_mensagem_get_texto()
                 CALL log0030_mensagem(l_msg,"Exclamation")
                 RETURN FALSE
              END IF
           END IF

        WHEN 3 #Atrasado, dentro do prazo de tolerância do banco
           #Calcula os novos valores devidos, e cria um registro na cre_vendor_titulo
           IF NOT crer44_recalcula_valores_vendor(l_empresa                ,
                                                  l_docum                  ,
                                                  l_tip_docum              ,
                                                  l_pgto_dat_pgto          ,
                                                  NULL                     ,
                                                  NULL                     ,
                                                  NULL                     ,
                                                  NULL                     ,
                                                  0                        ,
                                                  'T'                      ) THEN
              LET l_msg = log0030_mensagem_get_texto()
              CALL log0030_mensagem(l_msg,"Exclamation")
              RETURN FALSE
           END IF

           CALL crer44_get_cre_tit_cob_esp() RETURNING lr_cre_tit_cob_esp.*

           IF NOT lr_cre_tit_cob_esp.versao IS NULL THEN
              #LET lr_cre_vendor_titulo.sit_tit_cobranca = "L"
              LET lr_cre_tit_cob_esp.lote_pagamento    = m_num_lot

              IF NOT crer44_inclui_cre_tit_cob_esp(lr_cre_tit_cob_esp.*) THEN
                 LET l_msg = log0030_mensagem_get_texto()
                 CALL log0030_mensagem(l_msg,"Exclamation")
                 RETURN FALSE
              END IF

              #Lê o novo registro da cre_vendor_titulo calculado pela RNL crer44
              CALL crer44_get_cre_tit_cob_esp() RETURNING lr_cre_tit_cob_esp.*

              IF l_ies_tip_pgto = "N"
              OR l_ies_tip_pgto = "S" THEN
                 LET lr_cre_tit_cob_esp.sit_tit_cobranca = "T"
              ELSE
                 LET lr_cre_tit_cob_esp.sit_tit_cobranca = "P"
              END IF
              LET lr_cre_tit_cob_esp.lote_pagamento    = m_num_lot

              IF NOT crer44_inclui_cre_tit_cob_esp(lr_cre_tit_cob_esp.*) THEN
                 LET l_msg = log0030_mensagem_get_texto()
                 CALL log0030_mensagem(l_msg,"Exclamation")
                 RETURN FALSE
              END IF
           END IF

        OTHERWISE
           LET l_msg = 'Pagamento fora do limite de tolerância'
           CALL log0030_mensagem(l_msg,"Exclamation")
           RETURN FALSE
     END CASE
  END IF

  RETURN TRUE

 END FUNCTION

#-------------------------------------------------------------#
 FUNCTION geo1017_verifica_liquidacao_vendor(l_dat_vencto   ,
                                              l_cod_cliente  ,
                                              l_pgto_dat_pgto)
#-------------------------------------------------------------#
  DEFINE l_dat_vencto    DATE
  DEFINE l_cod_cliente   LIKE docum.cod_cliente
  DEFINE l_pgto_dat_pgto DATE

  DEFINE l_cod_cidade  LIKE clientes.cod_cidade,
         l_dias_atraso SMALLINT

  DEFINE l_tip_pgto_vendor SMALLINT

  WHENEVER ERROR CONTINUE
    SELECT cod_cidade
      INTO l_cod_cidade
      FROM clientes
     WHERE cod_cliente = l_cod_cliente
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
     CALL log003_err_sql('SELECT','DOCUM')
     RETURN FALSE
  END IF

  LET l_tip_pgto_vendor = 0

  IF l_dat_vencto > l_pgto_dat_pgto THEN
     LET l_tip_pgto_vendor = 1 #Antecipado
  ELSE
     IF l_dat_vencto = l_pgto_dat_pgto THEN
        LET l_tip_pgto_vendor = 2 #No prazo
     ELSE
        CALL cre026_pesquisa_calend(l_dat_vencto, l_pgto_dat_pgto, l_cod_cidade)
        RETURNING l_dias_atraso, l_dat_vencto

        #Não houve atraso. O vencimento ocorreu em dia não útil.
        IF l_dias_atraso = 0 THEN
           LET l_tip_pgto_vendor = 2 #No prazo
        ELSE
           IF l_dias_atraso <= mr_params_portador.qtd_dias_venc_vendor THEN
              LET l_tip_pgto_vendor = 3 #Em atraso, mas dentro do prazo de tolerância
           ELSE
              LET l_tip_pgto_vendor = 4 #Em atraso e fora do prazo de tolerância
           END IF
        END IF
     END IF
  END IF

  RETURN l_tip_pgto_vendor

 END FUNCTION

#-------------------------------------------#
 FUNCTION geo1017_leitura_params_portador()
#-------------------------------------------#

  WHENEVER ERROR CONTINUE
    SELECT parametro_texto
      INTO mr_params_portador.ies_detalhar_vendor_trb
      FROM cre_compl_portador
     WHERE portador     = mr_tela.cod_portador
       AND tip_portador = mr_tela.ies_tip_portador
       AND campo        = "detalhar_vendor_trb"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
     CALL log003_err_sql('SELECT DETALHAR_VENDOR_TRB','CRE_COMPL_PORTADOR')
     RETURN
  END IF

  IF mr_params_portador.ies_detalhar_vendor_trb IS NULL OR
     mr_params_portador.ies_detalhar_vendor_trb = ' ' THEN
     LET mr_params_portador.ies_detalhar_vendor_trb = 'N'
  END IF

  #572487 Efetua a leitura da margem de tolerância para pagamentos vendor.
  WHENEVER ERROR CONTINUE
    SELECT parametro_val
      INTO mr_params_portador.val_tolerancia_pagam_vendor
      FROM cre_compl_portador
     WHERE portador     = mr_tela.cod_portador
       AND tip_portador = mr_tela.ies_tip_portador
       AND campo        = "margem_pagto"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
     CALL log003_err_sql('SELECT MARGEM_PAGTO','CRE_COMPL_PORTADOR')
     RETURN
  END IF

  IF mr_params_portador.val_tolerancia_pagam_vendor IS NULL THEN
     LET mr_params_portador.val_tolerancia_pagam_vendor = 0
  END IF

  WHENEVER ERROR CONTINUE
    SELECT parametro_texto
      INTO mr_params_portador.iof_por_conta_vendor
      FROM cre_compl_portador
     WHERE portador     = mr_tela.cod_portador
       AND tip_portador = mr_tela.ies_tip_portador
       AND campo        = "iof_por_conta"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     LET mr_params_portador.iof_por_conta_vendor = 'E'
     CALL log003_err_sql("SELECT IOF_POR_CONTA","CRE_COMPL_PORTADOR")
     RETURN
  END IF

  WHENEVER ERROR CONTINUE
    SELECT parametro_qtd
      INTO mr_params_portador.qtd_dias_venc_vendor
      FROM cre_compl_portador
     WHERE portador     = mr_tela.cod_portador
       AND tip_portador = mr_tela.ies_tip_portador
       AND campo        = "qtd_dia_venci_vnd"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("SELECT QTD_DIA_VENCI_VND","CRE_COMPL_PORTADOR")
     RETURN
  END IF

  IF mr_params_portador.qtd_dias_venc_vendor IS NULL THEN
     LET mr_params_portador.qtd_dias_venc_vendor = 0
  END IF

 END FUNCTION

#--------------------------------------------------#
 FUNCTION geo1017_consiste_vendor(l_cod_empresa  ,
                                   l_num_docum    ,
                                   l_ies_tip_docum,
                                   l_ies_tip_cobr )
#--------------------------------------------------#
  DEFINE l_status              SMALLINT,
         l_permite_manutencao  SMALLINT,
         l_desabilita_contrato SMALLINT

  DEFINE l_cod_empresa       LIKE docum.cod_empresa
  DEFINE l_num_docum         LIKE docum.num_docum
  DEFINE l_ies_tip_docum     LIKE docum.ies_tip_docum
  DEFINE l_ies_tip_cobr      LIKE docum.ies_tip_cobr
  DEFINE l_sit_tit_cobranca  LIKE cre_tit_cob_esp.sit_tit_cobranca
  DEFINE l_contrato_cobranca LIKE cre_tit_cob_esp.contrato_cobranca
  DEFINE l_msg               CHAR(200)
  DEFINE l_modo_exibicao     SMALLINT

  IF l_ies_tip_cobr = 'V' THEN
     CALL crer44_permite_manutencao_cre_tit_cob_esp(l_cod_empresa,
                                                    l_num_docum,
                                                    l_ies_tip_docum,
                                                    l_ies_tip_cobr,0)
          RETURNING l_status, l_permite_manutencao, l_desabilita_contrato

     IF NOT l_status OR NOT l_permite_manutencao THEN
        RETURN FALSE, l_desabilita_contrato
     END IF
  END IF

  RETURN TRUE, l_desabilita_contrato

 END FUNCTION

#-----------------------------------------#
 FUNCTION geo1017_verifica_dp_possui_nc()
#-----------------------------------------#
 DEFINE l_num_docum    LIKE docum_posterior.num_docum
 DEFINE l_val_bruto_nc LIKE docum.val_bruto

 WHENEVER ERROR CONTINUE
   SELECT num_docum
     INTO l_num_docum
     FROM docum_posterior
    WHERE cod_empresa        = ma_principal[m_ind].empresa
      AND num_docum_post     = ma_principal[m_ind].docum
      AND ies_tip_docum_post = ma_principal[m_ind].tip_docum
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
      SELECT val_saldo
        INTO l_val_bruto_nc
        FROM docum
       WHERE cod_empresa   = ma_principal[m_ind].empresa
         AND num_docum     = l_num_docum
         AND ies_tip_docum = "NC"
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("SELECT","VAL_BRUTO")
    END IF

    IF l_val_bruto_nc IS NULL THEN
       LET l_val_bruto_nc = 0
    END IF

    RETURN l_val_bruto_nc

 END IF

 RETURN 0

 END FUNCTION

#-----------------------------------------------------------#
 FUNCTION geo1017_busca_sequencia_pagamento( l_cod_empresa ,
                                              l_num_docum   ,
                                              l_tip_docum   ,
                                              l_lote        )
#-----------------------------------------------------------#
 DEFINE l_cod_empresa LIKE docum_pgto.cod_empresa
 DEFINE l_num_docum   LIKE docum_pgto.num_docum
 DEFINE l_tip_docum   LIKE docum_pgto.ies_tip_docum
 DEFINE l_lote        LIKE docum_pgto.num_lote_pgto
 DEFINE l_seq_docum   LIKE docum_pgto.num_seq_docum

 WHENEVER ERROR CONTINUE
   SELECT MIN(num_seq_docum)
     INTO l_seq_docum
     FROM docum_pgto
    WHERE cod_empresa   = l_cod_empresa
      AND num_docum     = l_num_docum
      AND ies_tip_docum = l_tip_docum
      AND num_lote_pgto = l_lote
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","DOCUM_PGTO")
 END IF

 IF l_seq_docum IS NULL THEN
    LET l_seq_docum = 0
 END IF

 RETURN l_seq_docum

 END FUNCTION

#--------------------------------------------------------------------------------------------------------#
 FUNCTION geo1017_verifica_docum_equalizacao(l_empresa, l_docum, l_tip_docum, l_val_saldo, l_display_msg)
#--------------------------------------------------------------------------------------------------------#
 {OBJETIVO: verifica se o documento gerou um documento de equalização ou se o documento é de equalização.}
  DEFINE l_empresa            LIKE docum.cod_empresa,
         l_docum              LIKE docum.num_docum,
         l_tip_docum          LIKE docum.ies_tip_docum,
         l_val_saldo          LIKE docum.val_saldo,
         l_display_msg        SMALLINT

  DEFINE lr_docum_equalizacao RECORD
                                 empresa                LIKE docum.cod_empresa,
                                 docum                  LIKE docum.num_docum,
                                 tip_docum              LIKE docum.ies_tip_docum,
                                 val_saldo              LIKE docum.val_saldo
                              END RECORD

  INITIALIZE lr_docum_equalizacao.* TO NULL

  {Verifica se o documento foi criado a partir da transferência de outro documento de vendor para simples,
   para cobrança do valor de equalização. Se sim, não pode ser informado para baixa. Deve ser informado o
   título principal.}
  WHENEVER ERROR CONTINUE
    SELECT empresa
      FROM cre_docum_compl
     WHERE empresa        = l_empresa
       AND docum          = l_docum
       AND tip_docum      = l_tip_docum
       AND campo          = 'titulo_transferencia_vendor'
       AND par_existencia = 'S'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     IF l_display_msg THEN
        CALL log0030_mensagem("Este título teve origem na transferência de Vendor para Simples. Para a baixa deve ser informado o título principal.","Exclamation")
     END IF

     RETURN l_val_saldo, FALSE
  END IF

  #Indica que o documento não foi criado para cobrança de equalização,
  #então será verificado se o documento originou outro documento para cobrança de equalização
  WHENEVER ERROR CONTINUE
    SELECT cod_empresa, num_docum_post, ies_tip_docum_post
      INTO lr_docum_equalizacao.empresa,
           lr_docum_equalizacao.docum,
           lr_docum_equalizacao.tip_docum
      FROM docum_posterior
     WHERE cod_empresa   = l_empresa
       AND num_docum     = l_docum
       AND ies_tip_docum = l_tip_docum
       AND EXISTS (SELECT empresa
                     FROM cre_docum_compl
                    WHERE empresa        = docum_posterior.cod_empresa
                      AND docum          = docum_posterior.num_docum_post
                      AND tip_docum      = docum_posterior.ies_tip_docum_post
                      AND campo          = 'titulo_transferencia_vendor'
                      AND par_existencia = 'S')
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     WHENEVER ERROR CONTINUE
     SELECT val_saldo
       INTO lr_docum_equalizacao.val_saldo
       FROM docum
      WHERE cod_empresa   = lr_docum_equalizacao.empresa
        AND num_docum     = lr_docum_equalizacao.docum
        AND ies_tip_docum = lr_docum_equalizacao.tip_docum
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 OR lr_docum_equalizacao.val_saldo < 0 THEN
        LET lr_docum_equalizacao.val_saldo = 0
     END IF

     LET l_val_saldo = l_val_saldo + lr_docum_equalizacao.val_saldo
  END IF

  RETURN l_val_saldo, TRUE

 END FUNCTION

#------------------------------------------------------------------------#
 FUNCTION geo1017_inicializar_variaveis_processo_leitura_arquivo_texto()
#------------------------------------------------------------------------#

 #CALL LOG_setVar("efetua_leitura_txt", FALSE )
 #CALL LOG_setVar("codigo_empresa"    , NULL )
 #CALL LOG_setVar("num_lote_pgto"     , NULL )
 #CALL LOG_setVar("codigo_portador"   , NULL )
 #CALL LOG_setVar("tipo_portador"     , NULL )
 #CALL LOG_setVar("num_seq_conc_trb"  , NULL )
 #CALL LOG_setVar("forma_pagamento"   , NULL )

 END FUNCTION

#----------------------------------------------------#
 FUNCTION geo1017_realiza_calculo_especifico_juros()
#----------------------------------------------------#

 #::: UTILIZADO PELO CLIENTE:
 #::: 852 - VANGUARDA DO BRASIL LTDA
 IF LOG_existe_epl("cre0360y_busca_valor_de_juros") THEN
    CALL LOG_setVar( "prog_cod_empresa"       , ma_principal[m_ind].empresa   )
    CALL LOG_setVar( "prog_num_docum"         , ma_principal[m_ind].docum     )
    CALL LOG_setVar( "prog_ies_tip_docum"     , ma_principal[m_ind].tip_docum )
    CALL LOG_setVar( "prog_dat_pgto"          , ma_principal[m_ind].dat_pgto  )
    CALL LOG_setVar( "prog_cod_cliente"       , p_docum.cod_cliente           )
    CALL LOG_setVar( "prog_ies_tip_cobr_juro" , m_ies_tip_cobr_juro           )
    CALL LOG_setVar( "prog_ies_cotacao"       , p_ies_cotacao                 )
    CALL LOG_setVar( "prog_val_saldo"         , p_docum.val_saldo             )
    CALL LOG_setVar( "prog_val_desc"          , ma_principal[m_ind].val_desc  )
    CALL LOG_setVar( "prog_val_saldo_urv"     , m_val_saldo_urv               )
    CALL LOG_setVar( "prog_val_cotacao"       , m_val_cotacao                 )

    CALL LOG_setVar( "epl_qtd_dias_difer" , 0     ) #::: Inicialização das variaveis que serão retornadas da EPL.
    CALL LOG_setVar( "epl_val_juro_a_pag" , 0     ) #::: Inicialização das variaveis que serão retornadas da EPL.
    CALL LOG_setVar( "epl_status_retorno" , FALSE ) #::: Inicialização das variaveis que serão retornadas da EPL.

    CALL cre0360y_busca_valor_de_juros()

    #::: SE NÃO ACHAR VALOR DE JUROS NA FUNÇÃO ESPECIFICA ENTÃO DEVE BUSCA NA FUNÇÃO PADRÃO
    #::: ( Por isso tem o RETURN FALSE )
    IF NOT LOG_getVar( "epl_status_retorno" ) THEN
       RETURN FALSE
    ELSE

       LET m_qtd_dias_difer = LOG_getVar( "epl_qtd_dias_difer" )
       LET p_val_juro_a_pag = LOG_getVar( "epl_val_juro_a_pag" )

       LET ma_principal[m_ind].val_juros = p_val_juro_a_pag

       RETURN TRUE
    END IF

 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#------------------------------------------------#
 FUNCTION geo1017_entrada_dados_tipo_ordenacao()
#------------------------------------------------#

 LET int_flag = 0
 {INPUT BY NAME mr_consulta_aux.tipo_ordenacao WITHOUT DEFAULTS

 AFTER FIELD tipo_ordenacao
    IF mr_consulta_aux.tipo_ordenacao IS NULL OR mr_consulta_aux.tipo_ordenacao = " " THEN
       CALL log0030_mensagem("Tipo de ordenação deve ser informado.","Info")
       NEXT FIELD tipo_ordenacao
    END IF

    IF mr_consulta_aux.tipo_ordenacao NOT MATCHES "[12]" THEN
       CALL log0030_mensagem("Informe uma opção válida.","Info")
       NEXT FIELD tipo_ordenacao
    END IF


 ON KEY (control-z, f4)
 CALL geo1017_popup()

 AFTER INPUT
    IF int_flag = 0 THEN
       IF mr_consulta_aux.tipo_ordenacao IS NULL OR mr_consulta_aux.tipo_ordenacao = " " THEN
          CALL log0030_mensagem("Tipo de ordenação deve ser informado.","Info")
          NEXT FIELD tipo_ordenacao
       END IF

       IF mr_consulta_aux.tipo_ordenacao NOT MATCHES "[12]" THEN
          CALL log0030_mensagem("Informe uma opção válida.","Info")
          NEXT FIELD tipo_ordenacao
       END IF
    END IF

 END INPUT}

 IF int_flag = 0 THEN
    RETURN TRUE
 ELSE
    LET int_flag = 0
    #MESSAGE " Consulta cancelada. " ATTRIBUTE(REVERSE)
    RETURN FALSE
 END IF

 END FUNCTION

#-------------------------#
 FUNCTION geo1017_popup()
#-------------------------#

 LET mr_consulta_aux.tipo_ordenacao = log0830_list_box(10,40,'1 {Vencto-Docto-Tipo}, 2 {Cli-Vencto-Docto-Tipo}')

 #CALL log006_exibe_teclas('01 03 07',p_versao)
 #CURRENT WINDOW IS w_cre03602
 #DISPLAY BY NAME mr_consulta_aux.tipo_ordenacao

 END FUNCTION        
 

 