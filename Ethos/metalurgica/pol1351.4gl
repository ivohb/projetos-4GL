#-------------------------------------------------------------------#
# SISTEMA.: LOGIX      ETHOS INDUSTRIAL/METALÚRGICA                 #
# PROGRAMA: pol1351                                                 #
# OBJETIVO: INVENTÁRIO FÍSICO                                       #
# AUTOR...: IVO                                                     #
# DATA....: 21/11/2018                                              #
#-------------------------------------------------------------------#
# Alterações                                                        #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003),
           g_msg           CHAR(150),
           p_nom_arquivo   CHAR(100),
           p_caminho       CHAR(080),
           p_comando       CHAR(200)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_panel           VARCHAR(10),
       m_label_caminho   VARCHAR(10),
       m_dlg_motivo      VARCHAR(10),
       m_txt_arquivo     VARCHAR(10)

DEFINE m_menu_invent          VARCHAR(10),
       m_menu_diverg          VARCHAR(10),
       m_menu_carga_nova      VARCHAR(10),
       m_menu_contados        VARCHAR(10),
       m_menu_cont_loc_lot    VARCHAR(10),
       m_menu_num_loc_out_nao VARCHAR(10),
       m_menu_s_cont_c_estoq  VARCHAR(10),
       m_menu_cont_mais_1vez  VARCHAR(10),
       m_menu_cont_manual     VARCHAR(10),
       m_menu_finali_invent   VARCHAR(10),
       m_cpo_motivo           VARCHAR(10),
       m_ger_arq              VARCHAR(10),
       m_zoom_it              VARCHAR(10),
       m_zoom_local           VARCHAR(10),
       m_tip_invent           VARCHAR(10),
       m_cab_invent           VARCHAR(10)
       
DEFINE m_panel_aba            VARCHAR(10),
       m_panel_dados          VARCHAR(10),
       m_panel_invent         VARCHAR(10),
       m_panel_diverg         VARCHAR(10),
       m_panel_carga_nova     VARCHAR(10),
       m_panel_contados       VARCHAR(10),
       m_panel_grad_carga     VARCHAR(10),
       m_panel_loc_lot        VARCHAR(10),
       m_panel_num_loc_out_nao VARCHAR(10),
       m_panel_s_cont_c_estoq  VARCHAR(10),
       m_panel_cont_mais_1vez  VARCHAR(10),
       m_panel_cont_manual     VARCHAR(10),
       m_panel_finali_invent   VARCHAR(10)

DEFINE m_aba_invent            VARCHAR(10),
       m_aba_diverg            VARCHAR(10),
       m_aba_carga_nova        VARCHAR(10),       
       m_aba_contado           VARCHAR(10),
       m_aba_cont_loc_lot      VARCHAR(10),
       m_aba_num_loc_out_nao   VARCHAR(10),
       m_aba_s_cont_c_estoq    VARCHAR(10),
       m_aba_cont_mais_de_1vez VARCHAR(10),
       m_aba_cont_manual       VARCHAR(10),
       m_aba_finaliza          VARCHAR(10),
       m_arq_manual            VARCHAR(10),
       m_sel_arquivo           VARCHAR(10),
       m_brz_finali            VARCHAR(10),
       m_removeu               SMALLINT,
       m_pesq_nao_cont         SMALLINT,
       m_cons_finali           SMALLINT,
       m_ies_situacao          CHAR(01),
       m_ctr_lote              CHAR(01),
       m_ies_div_ger           SMALLINT,
       m_lin_atu               INTEGER,
       m_arq_dest              CHAR(100),
       m_arq_arigem            CHAR(100)
       

DEFINE m_browse_invent         VARCHAR(10)

DEFINE m_inv_construct         VARCHAR(10)

DEFINE mr_invent               RECORD
   cod_empresa                 CHAR(02),
   num_invent                  INTEGER,
   dat_invent                  CHAR(10),    
   hor_invent                  CHAR(08),    
   cod_usuario                 CHAR(08),    
   sit_invent                  CHAR(15),    
   qtd_carga                   INTEGER, 
   nom_caminho                 CHAR(80),
   tip_invent                  CHAR(01)
END RECORD

DEFINE ma_invent               ARRAY[100] OF RECORD
       cod_empresa             CHAR(02),
       num_invent              INTEGER,
       dat_invent              CHAR(10),
       hor_invent              CHAR(08),
       cod_usuario             CHAR(08),
       sit_invent              CHAR(15),
       qtd_carga               INTEGER, 
       nom_caminho             CHAR(80)
END RECORD

DEFINE m_ind                   INTEGER,
       m_msg                   CHAR(150),
       m_carregando            SMALLINT,
       m_caminho               CHAR(80),
       m_ies_ambiente          CHAR(01),
       m_comando               CHAR(100),
       m_qtd_arq               INTEGER,
       m_linha                 CHAR(80),
       m_nom_arquivo           CHAR(40),
       m_id_arquivoa           CHAR(30),
       m_contagem              CHAR(03),
       m_cod_local             CHAR(10),       
       m_cod_item              CHAR(15),
       m_ies_tip_item          CHAR(01),
       m_num_lote              CHAR(15),
       m_ies_situa_qtd         CHAR(01),
       m_origem                CHAR(01),
       m_qtd_contagem          DECIMAL(10,3),
       m_qtd_erro              INTEGER,
       m_count                 INTEGER,
       m_ies_ctr_lote          CHAR(01),
       m_id_registro           INTEGER,
       m_id_arquivo            INTEGER,
       m_dat_carga             CHAR(10),
       m_hor_carga             CHAR(08),
       m_tip_coletor           VARCHAR(10),
       m_ies_situa             CHAR(01),
       m_qtd_item              INTEGER,
       m_ies_contagem          CHAR(01),
       m_arq_gerar             CHAR(35)
   

DEFINE ma_files ARRAY[500] OF CHAR(100)

DEFINE m_zoom_it_diverg        VARCHAR(10),
       m_lupa_it_diverg        VARCHAR(10),
       m_it_diverg             VARCHAR(10),
       m_div_estoq             VARCHAR(10),
       m_div_contag            VARCHAR(10),
       m_div_reserva           VARCHAR(10),
       m_brz_div_estoq         VARCHAR(10),
       m_brz_div_reser         VARCHAR(10),
       m_brz_div_cont          VARCHAR(10)
       
DEFINE m_info_div              SMALLINT,
       m_info_carga            SMALLINT
       
DEFINE mr_diverg               RECORD
       cod_item                CHAR(15),
       ies_estoque             CHAR(01),
       ies_contagem            CHAR(01),
       ies_reserva             CHAR(01)
END RECORD

DEFINE ma_div_estoq            ARRAY[3000] OF RECORD
       cod_item                CHAR(15),
       den_item                CHAR(50),
       ies_tip_item            CHAR(01),
       cod_local               CHAR(10),
       num_lote                CHAR(15),
       ies_situa_qtd           CHAR(01),
       qtd_saldo               DECIMAL(10,3),
       cod_unid_med             CHAR(03)
END RECORD       

DEFINE ma_div_reserva          ARRAY[3000] OF RECORD
       cod_item                CHAR(15),
       den_item                CHAR(50),
       ies_tip_item            CHAR(01)
END RECORD       

DEFINE ma_div_contagem         ARRAY[3000] OF RECORD
       cod_item                CHAR(15),
       den_item                CHAR(50),
       ies_tip_item            CHAR(01)
END RECORD       

DEFINE m_cont_estoq      INTEGER,
       m_cont_contag     INTEGER,
       m_cont_reserv     INTEGER,
       m_tot_diverg      INTEGER

DEFINE m_browse_carga         VARCHAR(10),
       m_carga_panel_param    VARCHAR(10),
       m_carga_panel_carga    VARCHAR(10),
       m_carga_panel_consu    VARCHAR(10)

DEFINE mr_arquivo_coletor     RECORD
       tip_coletor            CHAR(01),
       cont_filho             CHAR(01),
       nom_arquivo            CHAR(100),
       num_contagem           CHAR(01),
       cod_usuario            CHAR(08),
       dat_carga              CHAR(10),
       hor_carga              CHAR(08),
       processado             CHAR(08),
       arquivo                CHAR(40)
END RECORD

DEFINE mr_arquivo_antes       RECORD
       tip_coletor            CHAR(01),
       cont_filho             CHAR(01),
       nom_arquivo            CHAR(100),
       num_contagem           CHAR(03),
       cod_usuario            CHAR(08),
       dat_carga              CHAR(10),
       hor_carga              CHAR(08),
       arquivo                CHAR(40)
END RECORD

DEFINE ma_carga_nova          ARRAY[3000] OF RECORD
       ies_ativo              CHAR(01),       
       ies_situa              CHAR(01),       
       cod_usuario            CHAR(08),
       cod_item               CHAR(15),
       den_item               CHAR(50),
       ies_tipo               CHAR(01),
       cod_local              CHAR(10),
       cod_control            CHAR(01),
       qtd_contada            DECIMAL(10,2),
       text_diverg            CHAR(200),
       origem                 CHAR(01),
       reg_pai                DECIMAL(12,0),
       registro               DECIMAL(12,0),
       num_lote               CHAR(15),
       ies_ctr_lote           CHAR(01),
       totaliza               CHAR(01),
       contagem               CHAR(03),
       ies_situa_qtd          CHAR(01)
END RECORD       

DEFINE m_coletor          VARCHAR(10),
       m_filho            VARCHAR(10),
       m_arquivo          VARCHAR(10),
       m_lupa_arq         VARCHAR(10),
       m_zoom_arq         VARCHAR(10),
       m_num_contagem     VARCHAR(10),
       m_user_cantagem    VARCHAR(10),
       m_lupa_user        VARCHAR(10),
       m_zoom_user        VARCHAR(10),       
       m_user_cont        VARCHAR(10),
       m_dialog_user      VARCHAR(10),
       m_browse_user      VARCHAR(10)

DEFINE ma_user_invent     ARRAY[1000] OF RECORD
       cod_usuario        CHAR(08)
END RECORD

DEFINE m_cod_usuario      CHAR(08),
       m_excluiu          SMALLINT,
       m_consu_info       SMALLINT

DEFINE m_cons_carga       VARCHAR(10)

DEFINE mr_motivo       RECORD
       motivo          CHAR(100)
END RECORD

DEFINE ma_erro        ARRAY[100] OF RECORD
       den_erro       CHAR(80)
END RECORD
   
DEFINE mr_contados    RECORD
       cod_item       CHAR(15),
       ies_pesquisar  CHAR(01)
END RECORD

DEFINE m_brz_contados VARCHAR(10),
       m_zoom_cont_it VARCHAR(10),
       m_cont_panel   VARCHAR(10),
       m_cont_item    VARCHAR(10)


DEFINE ma_contados    ARRAY[5000] OF RECORD
       cod_item       CHAR(15),
       den_item       CHAR(40),
       ies_tipo       CHAR(01),
       cod_unid       CHAR(03),
       qtd_estoque    DECIMAL(10,3),
       qtd_contada    DECIMAL(10,3),
       qtd_difer      DECIMAL(10,3),
       cust_unit      DECIMAL(10,2),
       val_difer      DECIMAL(10,2),
       contagem       CHAR(10),
       filler         CHAR(01)
END RECORD

DEFINE m_qtd_pri_cont DECIMAL(10,3),
       m_qtd_seg_cont DECIMAL(10,3),
       m_qtd_ter_cont DECIMAL(10,3),
       m_qtd_estoque  DECIMAL(10,3)
       

DEFINE mr_loc_lot     RECORD
       cod_item       CHAR(15),
       cod_local      CHAR(10),
       num_lote       CHAR(15),
       ies_pesquisar  CHAR(01)
END RECORD

DEFINE m_brz_loc_lot        VARCHAR(10),
       m_loc_lot_zoom_it    VARCHAR(10),
       m_loc_lot_zoom_local VARCHAR(10),
       m_loc_lot_panel      VARCHAR(10),
       m_loc_lot_item       VARCHAR(10),
       m_loc_lot_local      VARCHAR(10)

DEFINE ma_loc_lot     ARRAY[5000] OF RECORD
       id_registro    INTEGER,
       cod_item       CHAR(15),
       den_item       CHAR(40),
       ies_tipo       CHAR(01),
       cod_local      CHAR(10),
       num_lote       CHAR(15),
       cod_unid       CHAR(03),
       qtd_estoque    DECIMAL(10,3),
       qtd_pri_cont   DECIMAL(10,3),
       qtd_seg_cont   DECIMAL(10,3),
       qtd_ter_cont   DECIMAL(10,3),
       qtd_difer      DECIMAL(10,3),
       divergencia    CHAR(40)
END RECORD

DEFINE mr_num_loc     RECORD
       cod_item       CHAR(15),
       cod_local      CHAR(10),
       num_lote       CHAR(15),
       ies_pesquisar  CHAR(01)
END RECORD

DEFINE m_brz_num_loc        VARCHAR(10),
       m_num_loc_zoom_it    VARCHAR(10),
       m_num_loc_zoom_local VARCHAR(10),
       m_num_loc_panel      VARCHAR(10),
       m_num_loc_item       VARCHAR(10),
       m_num_loc_local      VARCHAR(10)

DEFINE ma_num_loc      ARRAY[5000] OF RECORD
       cod_item       CHAR(15),
       den_item       CHAR(40),
       ies_tipo       CHAR(01),
       cod_local      CHAR(10),
       num_lote       CHAR(15),
       cod_unid       CHAR(03),
       qtd_estoque    DECIMAL(10,3),
       cust_unit      DECIMAL(10,2),
       val_estoq      DECIMAL(10,2),
       filler         CHAR(01)
END RECORD

DEFINE mr_sem_cont    RECORD
       nom_ger_arq    CHAR(40),
       cod_item       CHAR(15),
       cod_familia    CHAR(05),
       cod_local      CHAR(10),
       num_lote       CHAR(15),
       tip_coletor    CHAR(01)
END RECORD

DEFINE m_brz_sem_cont        VARCHAR(10),
       m_sem_cont_zoom_fa    VARCHAR(10),
       m_sem_cont_zoom_it    VARCHAR(10),
       m_sem_cont_zoom_local VARCHAR(10),
       m_sem_cont_panel      VARCHAR(10),
       m_mais_1vez_panel     VARCHAR(10),
       m_param_manual_panel  VARCHAR(10),
       m_grade_manual_panel  VARCHAR(10),
       m_sem_cont_fami       VARCHAR(10),
       m_sem_cont_item       VARCHAR(10),
       m_sem_cont_local      VARCHAR(10)

DEFINE ma_sem_cont    ARRAY[5000] OF RECORD
       cod_item       CHAR(15),
       den_item       CHAR(40),
       ies_tipo       CHAR(01),
       cod_local      CHAR(10),
       num_lote       CHAR(15),
       cod_unid       CHAR(03),
       qtd_estoque    DECIMAL(10,3),
       cust_unit      DECIMAL(10,2),
       val_estoq      DECIMAL(10,2),
       filler         CHAR(01)
END RECORD

DEFINE m_lupa_s_cont_item       VARCHAR(10),
       m_lupa_s_cont_fami       VARCHAR(10),
       m_lupa_s_cont_local      VARCHAR(10)

DEFINE mr_mais_1vez    RECORD
       cod_item        CHAR(15)
END RECORD

DEFINE m_brz_mais_1vez      VARCHAR(10),
       m_brz_1vez_rodape    VARCHAR(10),
       m_mais_1vez_item     VARCHAR(10),
       m_mais_1vez_zoom_it  VARCHAR(10)

DEFINE ma_mais_1vez   ARRAY[500] OF RECORD
       cod_item       CHAR(15),
       den_item       CHAR(40),
       ies_tipo       CHAR(01),
       cod_local      CHAR(10),
       num_lote       CHAR(15),
       cod_unid       CHAR(03),
       contagem       CHAR(03),
       num_vez        DECIMAL(2,0)
END RECORD

DEFINE ma_1vez_rodape ARRAY[20] OF RECORD
       nom_arquivo    CHAR(30),
       cod_usuario    CHAR(08),
       qtd_contada    DECIMAL(10,3)
END RECORD

DEFINE mr_cont_manual    RECORD
       cod_usuario       CHAR(08),
       sel_arquivo       CHAR(100),
       nom_arquivo       CHAR(30),
       num_contagem      CHAR(30),
       tip_coletor       CHAR(01)       
END RECORD

DEFINE ma_cont_manual    ARRAY[200] OF RECORD
       cod_local         CHAR(10),
       den_local         CHAR(30),
       cod_item          CHAR(15),
       den_item          CHAR(40),
       qtd_contada       DECIMAL(10,3),
       num_lote          CHAR(15),
       filler            CHAR(01)
END RECORD

DEFINE m_brz_cont_manual        VARCHAR(10),
       m_info_manual            SMALLINT,
       m_num_cont_manual        VARCHAR(10)

DEFINE ma_finaliza    ARRAY[5000] OF RECORD
       id_registro    INTEGER,
       cod_item       CHAR(15),
       den_item       CHAR(18),
       cod_unid       CHAR(03),
       ies_tipo       CHAR(01),
       cod_local      CHAR(10),
       num_lote       CHAR(15),
       qtd_pri_cont   DECIMAL(10,3),
       qtd_seg_cont   DECIMAL(10,3),
       qtd_ter_cont   DECIMAL(10,3),
       divergencia    CHAR(100)
END RECORD

DEFINE mr_itens_invent      RECORD
       cod_empresa          char(02),      
       cod_item             char(15),      
       cod_local            char(10),      
       num_lote             char(15),      
       qtd_pri_cont         decimal(12,3), 
       qtd_seg_cont         decimal(12,3), 
       qtd_ter_cont         decimal(12,3),
       num_invent           integer,
       id_registro          integer,
       ies_situa_qtd        char(01)
END RECORD

DEFINE mr_totais            RECORD
       tot_val1             DECIMAL(10,3),
       tot_val2             DECIMAL(10,3),
       tot_val3             DECIMAL(12,2),
       tot_val4             DECIMAL(12,2)
END RECORD

DEFINE m_lb_tot2            VARCHAR(10)
       
#-----------------#
FUNCTION pol1351()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "POL1351-12.00.02  "
   CALL func002_versao_prg(p_versao)
   LET m_carregando = TRUE
   CALL pol1351_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1351_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_invent,
           l_operacao  VARCHAR(10),
           l_titulo    CHAR(80)
    
    LET l_titulo = 'INVENTÁRIO FÍSICO - ', p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"FONT",NULL,11,FALSE,TRUE)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"INIT_EVENT","pol1351_ativa_cor")

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_menu_invent = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_invent,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_invent,"VISIBLE",FALSE)

    LET m_menu_diverg = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_diverg,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_diverg,"VISIBLE",FALSE)

    LET m_menu_carga_nova = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_carga_nova,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_carga_nova,"VISIBLE",FALSE)

    LET m_menu_contados = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_contados,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_contados,"VISIBLE",FALSE)

    LET m_menu_cont_loc_lot = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_cont_loc_lot,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_cont_loc_lot,"VISIBLE",FALSE)

    LET m_menu_num_loc_out_nao = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_num_loc_out_nao,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_num_loc_out_nao,"VISIBLE",FALSE)

    LET m_menu_s_cont_c_estoq = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_s_cont_c_estoq,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_s_cont_c_estoq,"VISIBLE",FALSE)

    LET m_menu_cont_mais_1vez = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_cont_mais_1vez,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_cont_mais_1vez,"VISIBLE",FALSE)

    LET m_menu_cont_manual = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_cont_manual,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_cont_manual,"VISIBLE",FALSE)

    LET m_menu_finali_invent = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(m_menu_finali_invent,"HELP_VISIBLE",FALSE)
    CALL _ADVPL_set_property(m_menu_finali_invent,"VISIBLE",FALSE)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1351_paineis(l_panel)
    CALL pol1351_cria_abas()
    
    CALL pol1351_menu_invent()
    CALL pol1351_dados_invent()
    CALL pol1351_le_invent_aberto()

    CALL pol1351_menu_diverg()
    CALL pol1351_dados_diverg()

    CALL pol1351_menu_carga_nova()
    CALL pol1351_dados_carga_nova()

    CALL pol1351_menu_contados()
    CALL pol1351_dados_contados()

    CALL pol1351_menu_cont_loc_lot()
    CALL pol1351_dados_cont_loc_lot()

    CALL pol1351_menu_num_loc_out_nao()
    CALL pol1351_dados_num_loc_out_nao()

    CALL pol1351_menu_s_cont_c_estoq()
    CALL pol1351_dados_s_cont_c_estoq()

    CALL pol1351_menu_cont_mais_1vez()
    CALL pol1351_dados_cont_mais_1vez()

    CALL pol1351_menu_cont_manual()
    CALL pol1351_dados_cont_manual()

    CALL pol1351_menu_finali_invent()
    CALL pol1351_dados_finali_invent()
    
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#--------------------------------#
FUNCTION pol1351_paineis(l_panel)#
#--------------------------------#

    DEFINE l_panel        VARCHAR(10)

    LET m_panel_aba = _ADVPL_create_component(NULL,"LPANEL",l_panel)
    #LET m_panel_aba = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_panel)
    CALL _ADVPL_set_property(m_panel_aba,"ALIGN","LEFT")
    CALL _ADVPL_set_property(m_panel_aba,"WIDTH",210)
    CALL _ADVPL_set_property(m_panel_aba,"FONT",NULL,11,FALSE,TRUE)
    CALL _ADVPL_set_property(m_panel_aba,"BACKGROUND_COLOR",210,210,210)

    LET m_panel_dados = _ADVPL_create_component(NULL,"LPANEL",l_panel)
    CALL _ADVPL_set_property(m_panel_dados,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_panel_dados,"BACKGROUND_COLOR",231,237,237)

    LET m_panel_invent = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_invent,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_invent,"VISIBLE",FALSE)

    LET m_panel_diverg = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_diverg,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_diverg,"VISIBLE",FALSE)

    LET m_panel_carga_nova = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_carga_nova,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_carga_nova,"VISIBLE",FALSE)

    LET m_panel_contados = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_contados,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_contados,"VISIBLE",FALSE)

    LET m_panel_loc_lot = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_loc_lot,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_loc_lot,"VISIBLE",FALSE)

    LET m_panel_num_loc_out_nao = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_num_loc_out_nao,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_num_loc_out_nao,"VISIBLE",FALSE)

    LET m_panel_s_cont_c_estoq = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_s_cont_c_estoq,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_s_cont_c_estoq,"VISIBLE",FALSE)

    LET m_panel_cont_mais_1vez = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_cont_mais_1vez,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_cont_mais_1vez,"VISIBLE",FALSE)

    LET m_panel_cont_manual = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_cont_manual,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_cont_manual,"VISIBLE",FALSE)
    
    LET m_panel_finali_invent = _ADVPL_create_component(NULL,"LPANEL",m_panel_dados)
    CALL _ADVPL_set_property(m_panel_finali_invent,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_finali_invent,"VISIBLE",FALSE)

END FUNCTION

#---------------------------#
FUNCTION pol1351_cria_abas()#
#---------------------------#

    DEFINE l_label      VARCHAR(10),
           l_invent     VARCHAR(10),
           l_diverg     VARCHAR(10),
           l_carga      VARCHAR(10)
        

    LET m_aba_invent = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_invent,"POSITION",10,10)
    CALL _ADVPL_set_property(m_aba_invent,"TEXT","> Inventários")  
    CALL _ADVPL_set_property(m_aba_invent,"CLICK_EVENT","pol1351_invent_click")

    LET m_aba_diverg = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_diverg,"POSITION",10,40)
    CALL _ADVPL_set_property(m_aba_diverg,"TEXT","> Divergent estoq/contag/reserva")  
    CALL _ADVPL_set_property(m_aba_diverg,"CLICK_EVENT","pol1351_diverg_click")
     
    LET m_aba_carga_nova = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_carga_nova,"POSITION",10,70)
    CALL _ADVPL_set_property(m_aba_carga_nova,"TEXT","> Cargas de arquivos")  
    CALL _ADVPL_set_property(m_aba_carga_nova,"CLICK_EVENT","pol1351_carga_nova_click")

    LET m_aba_cont_manual = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_cont_manual,"POSITION",10,100)
    CALL _ADVPL_set_property(m_aba_cont_manual,"TEXT","> Contados manualmente")  
    CALL _ADVPL_set_property(m_aba_cont_manual,"CLICK_EVENT","pol1351_cont_manual_click")

    LET m_aba_contado = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_contado,"POSITION",10,130)
    CALL _ADVPL_set_property(m_aba_contado,"TEXT","> Contados sumarizados por item")  
    CALL _ADVPL_set_property(m_aba_contado,"CLICK_EVENT","pol1351_contado_click")

    LET m_aba_cont_loc_lot = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_cont_loc_lot,"POSITION",10,160)
    CALL _ADVPL_set_property(m_aba_cont_loc_lot,"TEXT","> Contados por local/lote")  
    CALL _ADVPL_set_property(m_aba_cont_loc_lot,"CLICK_EVENT","pol1351_cont_loc_lot_click")

    LET m_aba_num_loc_out_nao = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_num_loc_out_nao,"POSITION",10,190)
    CALL _ADVPL_set_property(m_aba_num_loc_out_nao,"TEXT","> Contados num local em outro não")  
    CALL _ADVPL_set_property(m_aba_num_loc_out_nao,"CLICK_EVENT","pol1351_num_loc_out_nao_click")

    LET m_aba_s_cont_c_estoq = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_s_cont_c_estoq,"POSITION",10,220)
    CALL _ADVPL_set_property(m_aba_s_cont_c_estoq,"TEXT","> Não Contados e com estoque")  
    CALL _ADVPL_set_property(m_aba_s_cont_c_estoq,"CLICK_EVENT","pol1351_s_cont_c_estoq_click")

    LET m_aba_cont_mais_de_1vez = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_cont_mais_de_1vez,"POSITION",10,250)
    CALL _ADVPL_set_property(m_aba_cont_mais_de_1vez,"TEXT","> Contados mais de uma vez")  
    CALL _ADVPL_set_property(m_aba_cont_mais_de_1vez,"CLICK_EVENT","pol1351_cont_mais_1vez_click")

    LET m_aba_finaliza = _ADVPL_create_component(NULL,"LLABEL",m_panel_aba)
    CALL _ADVPL_set_property(m_aba_finaliza,"POSITION",10,280)
    CALL _ADVPL_set_property(m_aba_finaliza,"TEXT","> Finalizar inventário")  
    CALL _ADVPL_set_property(m_aba_finaliza,"CLICK_EVENT","pol1351_finalizar_click")

END FUNCTION

#----------------------------#
FUNCTION pol1351_inv_aberto()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   IF mr_invent.sit_invent = 'ABERTO' THEN
      RETURN TRUE
   ELSE
      LET m_msg = 'Recurso disponível somente para inventário com status ABERTO.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
END FUNCTION

#------------------------------#
FUNCTION pol1351_checa_proces()#
#------------------------------#
   
   DEFINE l_arquivos          CHAR(800),
          l_id_arquivo        INTEGER,
          l_nom_arq           CHAR(40)
   
   LET l_arquivos = NULL
   
   DECLARE cq_nao_proces CURSOR FOR
    SELECT DISTINCT id_arquivo 
      FROM carga_coletor_547 
     WHERE cod_empresa = p_cod_empresa 
       AND num_invent = mr_invent.num_invent
       AND ies_ativo = 'S' 
       AND ies_situa <> 'P'
   
   FOREACH cq_nao_proces INTO l_id_arquivo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_nao_proces')
         RETURN FALSE
      END IF
      
      SELECT arquivo INTO l_nom_arq
        FROM arquivo_coletor_547
       WHERE cod_empresa = p_cod_empresa 
         AND id_arquivo = l_id_arquivo
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','arquivo_coletor_547')
         RETURN FALSE
      END IF
      
      IF l_arquivos IS NULL THEN
         LET l_arquivos = 'Arquivo(s) comtém registro(s) não processado(s):\n'
      END IF
      
      LET l_arquivos = l_arquivos CLIPPED, l_nom_arq CLIPPED, '\n'      
          
   END FOREACH
   
   IF l_arquivos IS NOT NULL THEN
      CALL log0030_mensagem(l_arquivos,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION      
      
#---------------------------#
FUNCTION pol1351_ativa_cor()#
#---------------------------#

   CALL _ADVPL_set_property(m_aba_invent,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_diverg,"FOREGROUND_COLOR",255,0,0)  
   CALL _ADVPL_set_property(m_aba_carga_nova,"FOREGROUND_COLOR",255,0,0) 
   CALL _ADVPL_set_property(m_aba_contado,"FOREGROUND_COLOR",255,0,0) 
   CALL _ADVPL_set_property(m_aba_cont_loc_lot,"FOREGROUND_COLOR",255,0,0) 
   CALL _ADVPL_set_property(m_aba_num_loc_out_nao,"FOREGROUND_COLOR",255,0,0) 
   CALL _ADVPL_set_property(m_aba_s_cont_c_estoq,"FOREGROUND_COLOR",255,0,0) 
   CALL _ADVPL_set_property(m_aba_cont_mais_de_1vez,"FOREGROUND_COLOR",255,0,0) 
   CALL _ADVPL_set_property(m_aba_cont_manual,"FOREGROUND_COLOR",255,0,0) 
   CALL _ADVPL_set_property(m_aba_finaliza,"FOREGROUND_COLOR",255,0,0) 
   
   CALL pol1351_invent_click()
   
 RETURN TRUE
       
END FUNCTION

#------------------------------#
FUNCTION pol1351_desativa_cor()#
#------------------------------#

   CALL _ADVPL_set_property(m_aba_invent,"FOREGROUND_COLOR",0,0,0)
   CALL _ADVPL_set_property(m_aba_invent,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_diverg,"FOREGROUND_COLOR",0,0,0)  
   CALL _ADVPL_set_property(m_aba_diverg,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_carga_nova,"FOREGROUND_COLOR",0,0,0) 
   CALL _ADVPL_set_property(m_aba_carga_nova,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_contado,"FOREGROUND_COLOR",0,0,0) 
   CALL _ADVPL_set_property(m_aba_contado,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_cont_loc_lot,"FOREGROUND_COLOR",0,0,0) 
   CALL _ADVPL_set_property(m_aba_cont_loc_lot,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_num_loc_out_nao,"FOREGROUND_COLOR",0,0,0) 
   CALL _ADVPL_set_property(m_aba_num_loc_out_nao,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_s_cont_c_estoq,"FOREGROUND_COLOR",0,0,0) 
   CALL _ADVPL_set_property(m_aba_s_cont_c_estoq,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_cont_mais_de_1vez,"FOREGROUND_COLOR",0,0,0) 
   CALL _ADVPL_set_property(m_aba_cont_mais_de_1vez,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_cont_manual,"FOREGROUND_COLOR",0,0,0) 
   CALL _ADVPL_set_property(m_aba_cont_manual,"FONT",NULL,NULL,FALSE,TRUE)
   CALL _ADVPL_set_property(m_aba_finaliza,"FOREGROUND_COLOR",0,0,0) 
   CALL _ADVPL_set_property(m_aba_finaliza,"FONT",NULL,NULL,FALSE,TRUE)

   RETURN TRUE
       
END FUNCTION

#---------------------------------#
FUNCTION pol1351_enib_menu_panel()#
#---------------------------------#

   CALL _ADVPL_set_property(m_menu_invent,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_diverg,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_carga_nova,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_contados,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_cont_loc_lot,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_num_loc_out_nao,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_s_cont_c_estoq,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_cont_mais_1vez,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_cont_manual,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_menu_finali_invent,"VISIBLE",FALSE)


   CALL _ADVPL_set_property(m_panel_invent,"VISIBLE",FALSE)   
   CALL _ADVPL_set_property(m_panel_diverg,"VISIBLE",FALSE)   
   CALL _ADVPL_set_property(m_panel_carga_nova,"VISIBLE",FALSE)   
   CALL _ADVPL_set_property(m_panel_contados,"VISIBLE",FALSE)   
   CALL _ADVPL_set_property(m_panel_loc_lot,"VISIBLE",FALSE)   
   CALL _ADVPL_set_property(m_panel_num_loc_out_nao,"VISIBLE",FALSE)   
   CALL _ADVPL_set_property(m_panel_s_cont_c_estoq,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_panel_cont_mais_1vez,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_panel_cont_manual,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_panel_finali_invent,"VISIBLE",FALSE)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

END FUNCTION


#--------------------------------------------------------#
# Funções para criação e consulta dos inventários        #
#--------------------------------------------------------#

#------------------------------#
FUNCTION pol1351_invent_click()#
#------------------------------#
   
   CALL pol1351_desativa_cor()
   CALL _ADVPL_set_property(m_aba_invent,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_invent,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1351_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_invent,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_panel_invent,"VISIBLE",TRUE)
   
   RETURN TRUE
       
END FUNCTION

#-----------------------------#
FUNCTION pol1351_menu_invent()#
#-----------------------------#

    DEFINE l_create,
           l_find,
           l_delete VARCHAR(10)

    LET l_create = _ADVPL_create_component(NULL,"LMENUBUTTON",m_menu_invent)     
    CALL _ADVPL_set_property(l_create,"IMAGE","NEW_EX")         
    CALL _ADVPL_set_property(l_create,"TOOLTIP","Iniciar um novo inventário")
    CALL _ADVPL_set_property(l_create,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_create,"EVENT","pol1351_sel_invent")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1351_criar_invent")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1351_canc_invent")
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_invent)
    CALL _ADVPL_set_property(l_find,"TOOLTIP","Abrir um inventário")
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1351_abrir_invent")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_menu_invent)
    CALL _ADVPL_set_property(l_delete,"TOOLTIP","Excluir inventário aberto")
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1351_excluir_invent")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_invent)


END FUNCTION

#------------------------------#
FUNCTION pol1351_dados_invent()#
#------------------------------#

    DEFINE l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_cab_invent = _ADVPL_create_component(NULL,"LPANEL",m_panel_invent)
    CALL _ADVPL_set_property(m_cab_invent,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_cab_invent,"HEIGHT",90)
    CALL _ADVPL_set_property(m_cab_invent,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(m_cab_invent,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cab_invent)
    CALL _ADVPL_set_property(l_label,"POSITION",350,5)  
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"TEXT","INVENTÁRIO")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cab_invent)
    CALL _ADVPL_set_property(l_label,"POSITION",10,35)     
    CALL _ADVPL_set_property(l_label,"TEXT","Data:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",0,0,0) 

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cab_invent)
    CALL _ADVPL_set_property(l_caixa,"POSITION",60,35)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_invent,"dat_invent")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cab_invent)
    CALL _ADVPL_set_property(l_label,"POSITION",175,35)     
    CALL _ADVPL_set_property(l_label,"TEXT","Hora:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",0,0,0) 

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cab_invent)
    CALL _ADVPL_set_property(l_caixa,"POSITION",225,35)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_invent,"hor_invent")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cab_invent)
    CALL _ADVPL_set_property(l_label,"POSITION",355,35)     
    CALL _ADVPL_set_property(l_label,"TEXT","Usuário:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",0,0,0) 

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cab_invent)
    CALL _ADVPL_set_property(l_caixa,"POSITION",420,35)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_invent,"cod_usuario")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cab_invent)
    CALL _ADVPL_set_property(l_label,"POSITION",540,35)     
    CALL _ADVPL_set_property(l_label,"TEXT","Status:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",0,0,0) 

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cab_invent)
    CALL _ADVPL_set_property(l_caixa,"POSITION",605,35)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_invent,"sit_invent")    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cab_invent)
    CALL _ADVPL_set_property(l_label,"POSITION",725,35)     
    CALL _ADVPL_set_property(l_label,"TEXT","Num invent:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",0,0,0) 

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cab_invent)
    CALL _ADVPL_set_property(l_caixa,"POSITION",810,35)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",5) 
    CALL _ADVPL_set_property(l_caixa,"FONT",NULL,11,TRUE,TRUE) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_invent,"num_invent")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cab_invent)
    CALL _ADVPL_set_property(l_label,"POSITION",885,35)     
    CALL _ADVPL_set_property(l_label,"TEXT","Cargas:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",0,0,0) 

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cab_invent)
    CALL _ADVPL_set_property(l_caixa,"POSITION",945,35)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_invent,"qtd_carga")  
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)  
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cab_invent)
    CALL _ADVPL_set_property(l_label,"POSITION",10,65)     
    CALL _ADVPL_set_property(l_label,"TEXT","Caminho dos arquivos textos:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",0,0,0) 

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cab_invent)
    CALL _ADVPL_set_property(l_caixa,"POSITION",205,65)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",80) 
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_invent,"nom_caminho")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cab_invent)
    CALL _ADVPL_set_property(l_label,"POSITION",875,65)     
    CALL _ADVPL_set_property(l_label,"TEXT","Tip invent:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",0,0,0) 

    LET m_tip_invent = _ADVPL_create_component(NULL,"LCOMBOBOX",m_cab_invent)
    CALL _ADVPL_set_property(m_tip_invent,"POSITION",945,65)
    CALL _ADVPL_set_property(m_tip_invent,"ADD_ITEM","0","      ")     
    CALL _ADVPL_set_property(m_tip_invent,"ADD_ITEM","N","Normal")     
    CALL _ADVPL_set_property(m_tip_invent,"ADD_ITEM","R","Rotativo")     
    CALL _ADVPL_set_property(m_tip_invent,"VARIABLE",mr_invent,"tip_invent")
    CALL _ADVPL_set_property(m_tip_invent,"EDITABLE",FALSE)
    
    # CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW") 

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_panel_invent)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_browse_invent = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse_invent,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_browse_invent,"BEFORE_ROW_EVENT","pol1351_set_caminho")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_invent)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","EMPRESA")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_invent)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DATA")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LDATEFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_invent")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_invent)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","HORA")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","hor_invent")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",FALSE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_invent)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","USUÁRIO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_usuario")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_invent)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","STATUS")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","sit_invent")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_invent)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CARGA")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_carga")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_invent)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CAMINHO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_caminho")

    CALL _ADVPL_set_property(m_browse_invent,"SET_ROWS",ma_invent,1)
    CALL _ADVPL_set_property(m_browse_invent,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse_invent,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#----------------------------------#
FUNCTION pol1351_le_invent_aberto()#
#----------------------------------#
   
   DEFINE l_dat_envent      CHAR(10)
   
   SELECT * INTO mr_invent.*
     FROM invent_547
    WHERE cod_empresa = p_cod_empresa
      AND sit_invent = 'ABERTO'
   
   IF STATUS = 100 THEN
      INITIALIZE mr_invent.* TO NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'invent_547')
      ELSE
         IF g_tipo_sgbd = 'MSV' THEN #sql server
         END IF      
      END IF             
   END IF

END FUNCTION   

#------------------------------#
FUNCTION pol1351_abrir_invent()#
#------------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
                   
    IF m_inv_construct IS NULL THEN
       LET m_inv_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_inv_construct,"CONSTRUCT_NAME","pol1351_invent")
       CALL _ADVPL_set_property(m_inv_construct,"ADD_VIRTUAL_TABLE","invent_547","Inventario")
       CALL _ADVPL_set_property(m_inv_construct,"ADD_VIRTUAL_COLUMN","invent_547","dat_invent","Data",1 {CHAR},10,0)
       CALL _ADVPL_set_property(m_inv_construct,"ADD_VIRTUAL_COLUMN","invent_547","cod_usuario","Usuário",1 {CHAR},8,0,"zoom_usuarios")
       CALL _ADVPL_set_property(m_inv_construct,"ADD_VIRTUAL_COLUMN","invent_547","sit_invent","Status",1 {CHAR},15,0)       	
    END IF

    LET l_status = _ADVPL_get_property(m_inv_construct,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_inv_construct,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_inv_construct,"ORDER_BY")
       CALL pol1351_inv_pesquisa(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#----------------------------------------------#
FUNCTION pol1351_inv_pesquisa(l_where, l_order)#
#----------------------------------------------#

    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    INITIALIZE ma_invent TO NULL
    #CALL _ADVPL_set_property(m_browse_invent,"CLEAR")
    
    IF l_order IS NULL THEN
       LET l_order = "dat_invent DESC"
    END IF
    
    LET l_sql_stmt = "SELECT * ",
                      " FROM invent_547",
                     " WHERE ",l_where CLIPPED,
                     "   AND cod_empresa = '",p_cod_empresa,"' ",
                     " ORDER BY ",l_order

    PREPARE var_inv_pesq FROM l_sql_stmt
    
    IF STATUS <> 0 THEN
       CALL log0030_processa_err_sql("PREPARE","var_inv_pesq",0)
       RETURN FALSE
    END IF

    DECLARE cq_inv_pesq CURSOR FOR var_inv_pesq

    IF  STATUS <> 0 THEN
        CALL log0030_processa_err_sql("DECLARE","cq_inv_pesq",0)
        RETURN FALSE
    END IF

    FREE var_inv_pesq
    
    LET m_ind = 1
    LET m_carregando = TRUE

    FOREACH cq_inv_pesq INTO ma_invent[m_ind].*

       IF STATUS <> 0 THEN
          CALL log0030_processa_err_sql("FOREACH","cq_inv_pesq",0)
          RETURN FALSE
       END IF
    
       LET m_ind = m_ind + 1
       
      IF m_ind > 100 THEN
         LET m_msg = 'Limite de linhas da grade\n de clientes ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
    
    END FOREACH
    
   LET m_ind = m_ind - 1

   IF m_ind = 0 THEN
      LET m_msg = "Não há inventários para os parãmetros informados"
      CALL _ADVPL_set_property(m_statusbar,"WARNING_TEXT",m_msg)
   ELSE
      CALL _ADVPL_set_property(m_browse_invent,"ITEM_COUNT", m_ind)
      LET m_carregando = FALSE
   END IF    
    
    RETURN TRUE
    
END FUNCTION

#----------------------------#
FUNCTION pol1351_sel_invent()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_invent.sit_invent = 'ABERTO' THEN
      LET m_msg = 'Já existe um inventário em andamento.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT pol1351_le_caminho() THEN
      RETURN FALSE
   END IF      
   
   INITIALIZE mr_invent.* TO NULL
   LET mr_invent.tip_invent = '0'
   
   CALL _ADVPL_set_property(m_cab_invent,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_tip_invent,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_tip_invent,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1351_canc_invent()#
#-----------------------------#
   
   CALL _ADVPL_set_property(m_cab_invent,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_tip_invent,"EDITABLE",FALSE)
   
   RETURN FALSE

END FUNCTION
   
#------------------------------#
FUNCTION pol1351_criar_invent()#
#------------------------------#

   DEFINE l_data            CHAR(10),
          l_caminho         CHAR(80)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF mr_invent.tip_invent = '0' THEN
      LET m_msg = 'Informe o tipo de inventário.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET l_caminho = m_caminho
   LET l_data = EXTEND(CURRENT, YEAR TO DAY)
   LET m_caminho = m_caminho CLIPPED, l_data
   
   IF m_ies_ambiente = 'W' THEN
      LET m_comando = 'MD ', m_caminho
   ELSE
      LET m_comando = 'MD ', m_caminho
   END IF
   
   RUN m_comando RETURNING p_status
   
   IF p_status THEN
      LET m_msg = 'Não foi possivel criar a sub-pasta: ',l_data,'\n',
                  'a partir do caminho: ',l_caminho CLIPPED
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
         
   LET mr_invent.cod_empresa = p_cod_empresa
   LET mr_invent.dat_invent =  TODAY
   LET mr_invent.hor_invent = TIME
   LET mr_invent.cod_usuario = p_user
   LET mr_invent.sit_invent = 'ABERTO'
   LET mr_invent.nom_caminho = m_caminho CLIPPED,'\\'
   LET mr_invent.qtd_carga = 0

   IF NOT pol1351_ins_invent() THEN
      INITIALIZE mr_invent.* TO NULL
      RETURN FALSE
   END IF   
   
   CALL _ADVPL_set_property(m_cab_invent,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_tip_invent,"EDITABLE",FALSE)

   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1351_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "INV"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema INV não cadastrado na LOG1100.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo","path_logix_v2")
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION
   
#----------------------------#   
FUNCTION pol1351_ins_invent()#
#----------------------------#
   
   SELECT MAX(num_invent) 
     INTO mr_invent.num_invent
     FROM invent_547
    WHERE cod_empresa = mr_invent.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("SELECT","invent_547")
      RETURN FALSE
   END IF
   
   IF mr_invent.num_invent IS NULL THEN
      LET mr_invent.num_invent = 0
   END IF
   
   LET mr_invent.num_invent = mr_invent.num_invent + 1   
   
   INSERT INTO invent_547 VALUES(mr_invent.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERT","invent_547")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1351_excluir_invent() #
#---------------------------------#
   
   DEFINE l_qtd_arq      INTEGER
   
   IF mr_invent.sit_invent IS NULL THEN
      LET m_msg = 'Não há inventário aberto a ser excluído.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF mr_invent.sit_invent = 'REALIZADO' THEN
      LET m_msg = 'Somente inventário aberto pode ser excluído.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF mr_invent.qtd_carga > 0 THEN
      LET m_msg = 'Esse inventário já possui carga e não pode ser excluído.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET p_caminho = mr_invent.nom_caminho,'\\'
   LET l_qtd_arq = LOG_file_getListCount(p_caminho,"*.txt",FALSE,FALSE,TRUE)
   
   IF l_qtd_arq > 0 THEN
      LET m_msg = 'A pasta desse inventário já possui arquivos do coletor.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET m_msg = "Confirma a exclusão do inventáio ?"

   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1351_exc_invent() THEN
       CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF

   IF NOT POL1351_exc_pasta() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   INITIALIZE mr_invent.* TO NULL
   
   RETURN TRUE
   
END FUNCTION
   
#----------------------------#   
FUNCTION pol1351_exc_invent()#
#----------------------------#
     
   DELETE FROM invent_547 
    WHERE cod_empresa = mr_invent.cod_empresa
      AND num_invent = mr_invent.num_invent

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELETE","invent_547")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION POL1351_exc_pasta()#
#---------------------------#
   
   DEFINE l_data           CHAR(10)
   
   LET l_data = mr_invent.dat_invent
   
   IF m_ies_ambiente = 'W' THEN
      LET m_comando = 'RD ', mr_invent.nom_caminho
   ELSE
      LET m_comando = 'RD ', mr_invent.nom_caminho
   END IF
   
   RUN m_comando RETURNING p_status
   
   IF p_status THEN
      LET m_msg = 'Não foi possivel remover a sub-pasta: ',l_data
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------FIM INVENTÁRIO--------------------------#

#--------------------------------------------------------#
# Funções para apresntação dos itens com divergèncias    #
#--------------------------------------------------------#

#------------------------------#
FUNCTION pol1351_diverg_click()#
#------------------------------#

   CALL pol1351_desativa_cor()
   CALL _ADVPL_set_property(m_aba_diverg,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_diverg,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1351_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_diverg,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_panel_diverg,"VISIBLE",TRUE)
   
   RETURN TRUE
       
END FUNCTION

#-----------------------------#
FUNCTION pol1351_menu_diverg()#
#-----------------------------#

    DEFINE l_create, l_panel,
           l_find, l_inform, 
           l_delete VARCHAR(10)

    LET l_inform = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_diverg)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1351_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1351_info_conf")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1351_info_canc")
    
    {LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_diverg)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1351_find_diverg")}

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_diverg)

END FUNCTION

#------------------------------#
FUNCTION pol1351_dados_diverg()#
#------------------------------#

   CALL pol1351_div_param(m_panel_diverg)
   CALL pol1351_div_grade(m_panel_diverg)
   
   CALL POL1351_set_diverg(FALSE)

END FUNCTION

#--------------------------------------#
FUNCTION pol1351_div_param(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    CALL pol1351_limpa_diverg("N")
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",300,5)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",255,0,0)    
    CALL _ADVPL_set_property(l_label,"TEXT","CONSULTA DE ITENS COM DIVERGÊNCIAS")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET m_it_diverg = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_it_diverg,"POSITION",55,30)     
    CALL _ADVPL_set_property(m_it_diverg,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_it_diverg,"PICTURE","@!")
    CALL _ADVPL_set_property(m_it_diverg,"VARIABLE",mr_diverg,"cod_item")
    CALL _ADVPL_set_property(m_it_diverg,"VALID","pol1351_valid_item")

    LET m_lupa_it_diverg = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_it_diverg,"POSITION",190,30)     
    CALL _ADVPL_set_property(m_lupa_it_diverg,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it_diverg,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it_diverg,"CLICK_EVENT","pol1351_zoom_item")

    LET m_div_estoq = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel)
    CALL _ADVPL_set_property(m_div_estoq,"POSITION",270,30)     
    CALL _ADVPL_set_property(m_div_estoq,"TEXT","De estoque (Grade 1)")     
    CALL _ADVPL_set_property(m_div_estoq,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_div_estoq,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_div_estoq,"VARIABLE",mr_diverg,"ies_estoque")
    CALL _ADVPL_set_property(m_div_estoq,"FONT",NULL,11,FALSE,TRUE)

    LET m_div_contag = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel)
    CALL _ADVPL_set_property(m_div_contag,"POSITION",440,30)     
    CALL _ADVPL_set_property(m_div_contag,"TEXT","De contagem (Grade 2)")     
    CALL _ADVPL_set_property(m_div_contag,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_div_contag,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_div_contag,"VARIABLE",mr_diverg,"ies_contagem")
    CALL _ADVPL_set_property(m_div_contag,"FONT",NULL,11,FALSE,TRUE)

    LET m_div_reserva = _ADVPL_create_component(NULL,"LCHECKBOX",l_panel)
    CALL _ADVPL_set_property(m_div_reserva,"POSITION",620,30)     
    CALL _ADVPL_set_property(m_div_reserva,"TEXT","De reserva (Grade 3)")     
    CALL _ADVPL_set_property(m_div_reserva,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_div_reserva,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_div_reserva,"VARIABLE",mr_diverg,"ies_reserva")
    CALL _ADVPL_set_property(m_div_reserva,"FONT",NULL,11,FALSE,TRUE)

END FUNCTION

#--------------------------------------#
FUNCTION pol1351_div_grade(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL pol1351_div_estoq(l_panel)
    CALL pol1351_div_reserva(l_panel)
    CALL pol1351_div_contagem(l_panel)
    
END FUNCTION

#--------------------------------------#
FUNCTION pol1351_div_estoq(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"MAX_HEIGHT",120)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_div_estoq = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_div_estoq,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DESCRIÇÃO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",360)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TIPO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tip_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOCAL")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOTE")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","SIT")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_situa_qtd")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","SALDO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","UNID")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid_med")

    CALL _ADVPL_set_property(m_brz_div_estoq,"SET_ROWS",ma_div_estoq,1)
    CALL _ADVPL_set_property(m_brz_div_estoq,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_div_estoq,"CAN_REMOVE_ROW",FALSE)
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1351_div_reserva(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"MAX_HEIGHT",120)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_div_reser = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_div_reser,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_reser)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_reser)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DESCRIÇÃO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",360)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_reser)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TIPO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tip_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    CALL _ADVPL_set_property(m_brz_div_reser,"SET_ROWS",ma_div_reserva,1)
    CALL _ADVPL_set_property(m_brz_div_reser,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_div_reser,"CAN_REMOVE_ROW",FALSE)
    
END FUNCTION

#-----------------------------------------#
FUNCTION pol1351_div_contagem(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_div_cont = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_div_cont,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DESCRIÇÃO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",360)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_div_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TIPO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tip_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    CALL _ADVPL_set_property(m_brz_div_cont,"SET_ROWS",ma_div_contagem,1)
    CALL _ADVPL_set_property(m_brz_div_cont,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_div_cont,"CAN_REMOVE_ROW",FALSE)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1351_limpa_diverg(l_ies_div)#
#---------------------------------------#
   
    DEFINE l_ies_div CHAR(01)
   
    INITIALIZE mr_diverg.* TO NULL
    LET mr_diverg.ies_estoque = l_ies_div
    LET mr_diverg.ies_contagem = l_ies_div
    LET mr_diverg.ies_reserva = l_ies_div

END FUNCTION

#------------------------------------#
FUNCTION POL1351_set_diverg(l_status)#
#------------------------------------#
   
   DEFINE l_status        SMALLINT

   CALL _ADVPL_set_property(m_it_diverg,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_it_diverg,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_div_estoq,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_div_contag,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_div_reserva,"EDITABLE",l_status)

END FUNCTION

#---------------------------#
FUNCTION pol1351_zoom_item()#
#---------------------------#
    
   DEFINE l_codigo      CHAR(15),
          l_filtro      CHAR(300)

   IF m_zoom_it_diverg IS NULL THEN
      LET m_zoom_it_diverg = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_it_diverg,"ZOOM","zoom_item")
   END IF

   LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_zoom_it_diverg,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_it_diverg,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_diverg.cod_item = l_codigo
      LET p_status = pol1351_valid_item()
   END IF
   
   CALL _ADVPL_set_property(m_lupa_it_diverg,"GET_FOCUS")
   
END FUNCTION

#-----------------------------#
FUNCTION pol1351_valid_item()#
#-----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_diverg.cod_item IS NULL THEN
      RETURN TRUE
   END IF

   SELECT den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_diverg.cod_item
   
   IF STATUS = 100 THEN
      LET m_msg = 'Produto inexistente no Logix.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE            
      END IF 
   END IF
      
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1351_informar()#
#--------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   CALL pol1351_set_diverg(TRUE)   
   CALL pol1351_limpa_diverg("S")
   CALL _ADVPL_set_property(m_it_diverg,"GET_FOCUS")
   LET m_carregando = FALSE
   LET m_info_div = FALSE
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",FALSE)
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1351_info_canc()#
#---------------------------#

   CALL pol1351_limpa_diverg("N")  
   CALL pol1351_set_diverg(FALSE)
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1351_info_conf()#
#---------------------------#
   
   IF mr_diverg.ies_estoque = 'S' OR
       mr_diverg.ies_contagem = 'S' OR
       mr_diverg.ies_reserva = 'S' THEN
   ELSE
      LET m_msg = 'Pelo menos um tipo de divergência deve ser selecionado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   CALL pol1351_set_diverg(FALSE)
   
   LET m_info_div = TRUE

   IF NOT pol1351_find_diverg() THEN
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
   
   RETURN TRUE   
    
END FUNCTION

#-----------------------------#
FUNCTION pol1351_find_diverg()#
#-----------------------------#
   
   IF NOT m_info_div THEN
      LET m_msg = 'Informe previamente os parãmetors.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   LET m_carregando = TRUE

   LET p_status = LOG_progresspopup_start("Carregando...","pol1351_le_diverg","PROCESS") 
   
   RETURN p_status

END FUNCTION

#---------------------------#
FUNCTION pol1351_le_diverg()#
#---------------------------#
      
   CALL _ADVPL_set_property(m_brz_div_estoq,"CLEAR")
   CALL _ADVPL_set_property(m_brz_div_cont,"CLEAR")
   CALL _ADVPL_set_property(m_brz_div_reser,"CLEAR")
   
   INITIALIZE ma_div_estoq, ma_div_contagem, ma_div_reserva TO NULL
   
   SELECT COUNT(cod_empresa)
     INTO m_cont_estoq 
     FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND ies_situa_qtd <> 'L'
      AND qtd_saldo > 0
      AND ((cod_item = mr_diverg.cod_item AND mr_diverg.cod_item IS NOT NULL) OR
           (1=1 AND mr_diverg.cod_item IS NULL))
      AND (1=1 AND mr_diverg.ies_estoque = 'S')
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote:COUNT')
      RETURN FALSE
   END IF
   
   SELECT COUNT(cod_empresa)
     INTO m_cont_contag 
     FROM aviso_rec
    WHERE cod_empresa = p_cod_empresa
      AND ies_liberacao_cont=  'N'
      AND ies_item_estoq =  'S'
      AND ((cod_item = mr_diverg.cod_item AND mr_diverg.cod_item IS NOT NULL) OR
           (1=1 AND mr_diverg.cod_item IS NULL))
      AND (1=1 AND mr_diverg.ies_contagem = 'S')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','aviso_rec:COUNT')
      RETURN FALSE
   END IF
       
   SELECT COUNT(cod_empresa)
     INTO m_cont_reserv 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND qtd_reservada > 0
      AND ((cod_item = mr_diverg.cod_item AND mr_diverg.cod_item IS NOT NULL) OR
           (1=1 AND mr_diverg.cod_item IS NULL))
      AND (1=1 AND mr_diverg.ies_reserva = 'S')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_loc_reser:COUNT')
      RETURN FALSE
   END IF
   
   LET m_tot_diverg = m_cont_estoq + m_cont_contag + m_cont_reserv

   IF m_tot_diverg = 0 THEN
      LET m_msg = 'Não há divergências de estoque,\n contagem ou reserva.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN TRUE
   END IF

   IF m_cont_estoq > 0 THEN
      IF NOT pol1351_le_div_estoq() THEN
         RETURN FALSE
      END IF
   END IF

   IF m_cont_contag > 0 THEN
      IF NOT pol1351_le_div_contag() THEN
         RETURN FALSE
      END IF
   END IF

   IF m_cont_reserv > 0 THEN
      IF NOT pol1351_le_div_reser() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1351_le_div_estoq()#
#------------------------------#
   
   DEFINE l_progres         SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_cont_estoq)
   
   LET m_ind = 1
   
   DECLARE cq_est_lote CURSOR FOR
    SELECT DISTINCT e.cod_item,  i.den_item, i.ies_tip_item,
           e.cod_local, e.num_lote, e.ies_situa_qtd,
           e.qtd_saldo, i.cod_unid_med
      FROM estoque_lote e, item i
     WHERE e.cod_empresa = p_cod_empresa
       AND e.ies_situa_qtd <> 'L'
       AND e.qtd_saldo > 0
       AND e.cod_empresa = i.cod_empresa
       AND e.cod_item = i.cod_item
       AND i.ies_situacao = 'A'
      AND ((e.cod_item = mr_diverg.cod_item AND mr_diverg.cod_item IS NOT NULL) OR
           (1=1 AND mr_diverg.cod_item IS NULL))

   FOREACH cq_est_lote INTO ma_div_estoq[m_ind].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_lote e, item i')    
         RETURN FALSE
      END IF
            
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      LET m_ind = m_ind + 1
   
      IF m_ind > 3000 THEN
         LET m_msg = 'Limite de linhas da grade\n de estoque ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
    END FOREACH
    
   LET m_ind = m_ind - 1

   IF m_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_div_estoq,"ITEM_COUNT", m_ind)
   END IF    
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1351_le_div_contag()#
#-------------------------------#
   
   DEFINE l_progres         SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_cont_contag)
   
   LET m_ind = 1
   
   DECLARE cq_aviso CURSOR FOR
    SELECT DISTINCT a.cod_item,  i.den_item, i.ies_tip_item
      FROM aviso_rec a, item i
     WHERE a.cod_empresa = p_cod_empresa
       AND a.ies_liberacao_cont=  'N'
       AND a.ies_item_estoq =  'S'
       AND a.cod_empresa = i.cod_empresa
       AND a.cod_item = i.cod_item
       AND i.ies_situacao = 'A'
      AND ((a.cod_item = mr_diverg.cod_item AND mr_diverg.cod_item IS NOT NULL) OR
           (1=1 AND mr_diverg.cod_item IS NULL))

   FOREACH cq_aviso INTO ma_div_contagem[m_ind].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','aviso_rec a, item i')    
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET m_ind = m_ind + 1
   
      IF m_ind > 3000 THEN
         LET m_msg = 'Limite de linhas da grade\n de contagem ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
    END FOREACH
    
   LET m_ind = m_ind - 1

   IF m_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_div_cont,"ITEM_COUNT", m_ind)
   END IF    
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1351_le_div_reser()#
#------------------------------#
   
   DEFINE l_progres         SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_cont_reserv)
   
   LET m_ind = 1
   
   DECLARE cq_aviso CURSOR FOR
    SELECT DISTINCT e.cod_item,  i.den_item, i.ies_tip_item
      FROM estoque_loc_reser e, item i
     WHERE e.cod_empresa = p_cod_empresa
       AND e.qtd_reservada > 0
       AND e.cod_empresa = i.cod_empresa
       AND e.cod_item = i.cod_item
       AND i.ies_situacao = 'A'
      AND ((e.cod_item = mr_diverg.cod_item AND mr_diverg.cod_item IS NOT NULL) OR
           (1=1 AND mr_diverg.cod_item IS NULL))

   FOREACH cq_aviso INTO ma_div_reserva[m_ind].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_loc_reser e, item i')    
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET m_ind = m_ind + 1
   
      IF m_ind > 3000 THEN
         LET m_msg = 'Limite de linhas da grade\n de reserva ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
    END FOREACH
    
   LET m_ind = m_ind - 1

   IF m_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_div_reser,"ITEM_COUNT", m_ind)
   END IF    
   
   RETURN TRUE

END FUNCTION

#----------------FIM DAS DIVERGÊNCIAS--------------------#

#--------------------------------------------------------#
# Funções para a carga dos arquivos gerados pelo coletor#
#--------------------------------------------------------#

#----------------------------------#
FUNCTION pol1351_carga_nova_click()#
#----------------------------------#
   
   IF NOT pol1351_inv_aberto() THEN
      RETURN FALSE
   END IF
   
   CALL pol1351_desativa_cor()
   CALL _ADVPL_set_property(m_aba_carga_nova,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_carga_nova,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1351_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_carga_nova,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_panel_carga_nova,"VISIBLE",TRUE)

   RETURN TRUE
       
END FUNCTION

#---------------------------------#
FUNCTION pol1351_menu_carga_nova()#
#---------------------------------#
   
    DEFINE l_panel, l_carga, l_proces, l_find, l_update,
           l_first, l_previous, l_next,  l_last,
           l_ativa, l_desativa, l_delete, l_enviar, l_consist VARCHAR(10)
            
    LET l_carga = _ADVPL_create_component(NULL,"LMENUBUTTON",m_menu_carga_nova)     
    CALL _ADVPL_set_property(l_carga,"IMAGE","CARREGAR_DADOS")     
    CALL _ADVPL_set_property(l_carga,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_carga,"TOOLTIP","Carregar um novo arquivo")
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1351_carga_informar")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1351_carga_info_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1351_carga_info_canc")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_carga_nova)
    CALL _ADVPL_set_property(l_find,"TOOLTIP","Pesquisar arquivo carregado")
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1351_carga_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",m_menu_carga_nova)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1351_carga_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",m_menu_carga_nova)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1351_carga_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",m_menu_carga_nova)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1351_carga_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",m_menu_carga_nova)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1351_carga_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_menu_carga_nova)
    CALL _ADVPL_set_property(l_delete,"TOOLTIP","Excluir arquivo carregado")
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1351_carga_exclui")

    LET l_desativa = _ADVPL_create_component(NULL,"LMENUBUTTON",m_menu_carga_nova)     
    CALL _ADVPL_set_property(l_desativa,"IMAGE","inativar")     
    CALL _ADVPL_set_property(l_desativa,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_desativa,"TOOLTIP","Inativa a contagem do item")
    CALL _ADVPL_set_property(l_desativa,"EVENT","pol1351_carga_desativar")

    LET l_ativa = _ADVPL_create_component(NULL,"LMENUBUTTON",m_menu_carga_nova)     
    CALL _ADVPL_set_property(l_ativa,"IMAGE","REATIVA_OPER")     
    CALL _ADVPL_set_property(l_ativa,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_ativa,"TOOLTIP","Reativa a contagem do item")
    CALL _ADVPL_set_property(l_ativa,"EVENT","pol1351_carga_reativar")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",m_menu_carga_nova)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Checa os dados e bloqueia o item")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1301_consiste")
    
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_carga_nova)

END FUNCTION

#--------------------------------#
FUNCTION pol1351_carga_informar()#
#--------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_invent.sit_invent = 'ABERTO' THEN
   ELSE
      LET m_msg = 'O inventário selecionado não está com status ABERTO'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1351_cria_temp() THEN
      RETURN FALSE
   END IF
   
   LET mr_arquivo_antes.* = mr_arquivo_coletor.*
   CALL pol1351_limpa_carga()
   LET m_carregando = FALSE
   CALL pol1351_carrega_lista()
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_carga_panel_carga,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_txt_arquivo,"VISIBLE",FALSE) 
   CALL _ADVPL_set_property(m_arquivo,"VISIBLE",TRUE) 
   CALL _ADVPL_set_property(m_num_contagem,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1351_cria_temp()#
#---------------------------#
   
   DROP TABLE invent_carga_547;
   
   CREATE TEMP TABLE invent_carga_547 (
     contagem         CHAR(60)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','invent_carga_547')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1351_carrega_lista()#
#-------------------------------#     

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03)

   CALL _ADVPL_set_property(m_arquivo,"CLEAR") 
   CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","    ") 
   
   LET p_caminho = mr_invent.nom_caminho,'\\'
   LET m_qtd_arq = LOG_file_getListCount(p_caminho,"*.txt",FALSE,FALSE,TRUE)
   
   IF m_qtd_arq = 0 THEN
      LET m_msg = 'Nenhum arquivo foi encontrado no caminho ', mr_invent.nom_caminho
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN
   END IF
   
   INITIALIZE ma_files TO NULL
   
   FOR l_ind = 1 TO m_qtd_arq
       LET t_ind = l_ind
       LET ma_files[l_ind] = LOG_file_getFromList(l_ind)
       CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM",t_ind,ma_files[l_ind])                    
   END FOR
    
END FUNCTION

#---------------------------------#
FUNCTION pol1351_carrega_arquivo()#
#---------------------------------#     

   DEFINE l_ind     INTEGER
   
   DEFINE ma_files ARRAY[500] OF CHAR(200)


   LET m_qtd_arq = LOG_file_getListCount("C:\\Temp\\","*.txt",FALSE,FALSE,TRUE)
   
   FOR l_ind = 1 TO m_qtd_arq
       IF l_ind > 500 THEN
          LET m_msg = 'Número previsto de arquivos ultrapassou.'
          CALL log0030_mensagem(m_msg,'info')
          EXIT FOR
       END IF

       LET ma_files[l_ind] = LOG_file_getFromList(l_ind)
               
   END FOR

   RETURN ma_files
    
END FUNCTION

#---------------------------------#
FUNCTION pol1351_carga_info_canc()#
#---------------------------------#

   LET mr_arquivo_coletor.* = mr_arquivo_antes.* 
   CALL _ADVPL_set_property(m_arquivo,"VISIBLE",FALSE) 
   CALL _ADVPL_set_property(m_txt_arquivo,"VISIBLE",TRUE) 
   CALL _ADVPL_set_property(m_carga_panel_carga,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1351_carga_info_conf()#
#---------------------------------#
   
   DEFINE l_contagem        CHAR(01)
   
   IF NOT pol1351_valid_coletor() THEN
      RETURN FALSE
   END IF

   IF NOT pol1351_valid_user() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1351_valid_arquivo() THEN
      RETURN FALSE
   END IF

   LET l_contagem = p_nom_arquivo[1]
   
   IF l_contagem MATCHES '[123]' THEN
      LET mr_arquivo_coletor.num_contagem = l_contagem
   ELSE
      LET mr_arquivo_coletor.num_contagem = '0'
   END IF

   IF NOT pol1351_valid_contagem() THEN
      RETURN FALSE
   END IF

   LET m_info_carga = FALSE
   
   IF NOT pol1351_le_contagem() THEN
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_arquivo,"VISIBLE",FALSE) 
   CALL _ADVPL_set_property(m_txt_arquivo,"VISIBLE",TRUE)    
   LET mr_arquivo_coletor.arquivo = p_nom_arquivo
   CALL _ADVPL_set_property(m_carga_panel_carga,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
   
   RETURN TRUE   
    
END FUNCTION

#----------------------------------#
FUNCTION pol1351_dados_carga_nova()#
#----------------------------------#

   CALL pol1351_carga_nova_param(m_panel_carga_nova)
   CALL pol1351_carga_nova_grade(m_panel_carga_nova)
      
END FUNCTION

#---------------------------------------------#
FUNCTION pol1351_carga_nova_param(l_container)#
#---------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)
       
    
    LET m_carga_panel_carga = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_carga_panel_carga,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_carga_panel_carga,"HEIGHT",100)
    CALL _ADVPL_set_property(m_carga_panel_carga,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(m_carga_panel_carga,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_label,"POSITION",350,10)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",255,0,0)    
    CALL _ADVPL_set_property(l_label,"TEXT","CARGA DE ARQUIVOS")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_label,"POSITION",10,40)     
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"TEXT","Coletor Lucas 9000 ou PDT:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)     

    LET m_coletor = _ADVPL_create_component(NULL,"LCOMBOBOX",m_carga_panel_carga)
    CALL _ADVPL_set_property(m_coletor,"POSITION",195,40)
    CALL _ADVPL_set_property(m_coletor,"ADD_ITEM","L","    ")     
    CALL _ADVPL_set_property(m_coletor,"ADD_ITEM","N","Lucas")     
    CALL _ADVPL_set_property(m_coletor,"ADD_ITEM","P","PDT")     
    CALL _ADVPL_set_property(m_coletor,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_coletor,"VALID","pol1351_valid_coletor")
    CALL _ADVPL_set_property(m_coletor,"VARIABLE",mr_arquivo_coletor,"tip_coletor")
    CALL _ADVPL_set_property(m_coletor,"FONT",NULL,11,TRUE,FALSE)

    LET m_filho = _ADVPL_create_component(NULL,"LCHECKBOX",m_carga_panel_carga)
    CALL _ADVPL_set_property(m_filho,"POSITION",270,40)     
    CALL _ADVPL_set_property(m_filho,"TEXT","Contagem do filho:")     
    CALL _ADVPL_set_property(m_filho,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_filho,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_filho,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_filho,"VARIABLE",mr_arquivo_coletor,"cont_filho")
    CALL _ADVPL_set_property(m_filho,"FONT",NULL,11,FALSE,TRUE)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_label,"POSITION",460,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Número da contagem:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_num_contagem = _ADVPL_create_component(NULL,"LCOMBOBOX",m_carga_panel_carga)
    CALL _ADVPL_set_property(m_num_contagem,"POSITION",600,40)
    CALL _ADVPL_set_property(m_num_contagem,"ADD_ITEM","0","   ")     
    CALL _ADVPL_set_property(m_num_contagem,"ADD_ITEM","1","001")     
    CALL _ADVPL_set_property(m_num_contagem,"ADD_ITEM","2","002")     
    CALL _ADVPL_set_property(m_num_contagem,"ADD_ITEM","3","003")     
    CALL _ADVPL_set_property(m_num_contagem,"VARIABLE",mr_arquivo_coletor,"num_contagem")
    CALL _ADVPL_set_property(m_num_contagem,"ENABLE",FALSE)  
    CALL _ADVPL_set_property(m_num_contagem,"FONT",NULL,11,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_label,"POSITION",670,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Realizada por:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_user_cantagem = _ADVPL_create_component(NULL,"LTEXTFIELD",m_carga_panel_carga)
    CALL _ADVPL_set_property(m_user_cantagem,"POSITION",760,40)     
    CALL _ADVPL_set_property(m_user_cantagem,"LENGTH",8,0)
    CALL _ADVPL_set_property(m_user_cantagem,"VARIABLE",mr_arquivo_coletor,"cod_usuario")
    CALL _ADVPL_set_property(m_user_cantagem,"FONT",NULL,11,TRUE,FALSE)
    
    LET m_lupa_user = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_carga_panel_carga)
    CALL _ADVPL_set_property(m_lupa_user,"POSITION",850,40)     
    CALL _ADVPL_set_property(m_lupa_user,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_user,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_user,"CLICK_EVENT","pol1351_zoom_user")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_label,"POSITION",890,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Processado:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)   
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_caixa,"POSITION",970,40)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",8,0)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_arquivo_coletor,"processado")
    CALL _ADVPL_set_property(l_caixa,"FONT",NULL,11,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_label,"POSITION",10,70)     
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_arquivo = _ADVPL_create_component(NULL,"LCOMBOBOX",m_carga_panel_carga)     
    CALL _ADVPL_set_property(m_arquivo,"POSITION",70,70)     
    CALL _ADVPL_set_property(m_arquivo,"VARIABLE",mr_arquivo_coletor,"nom_arquivo")
    CALL _ADVPL_set_property(m_arquivo,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_arquivo,"VISIBLE",FALSE) 

    LET m_txt_arquivo = _ADVPL_create_component(NULL,"LTEXTFIELD",m_carga_panel_carga)
    CALL _ADVPL_set_property(m_txt_arquivo,"POSITION",70,70)     
    CALL _ADVPL_set_property(m_txt_arquivo,"LENGTH",30,0)
    CALL _ADVPL_set_property(m_txt_arquivo,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_txt_arquivo,"CAN_GOT_FOCUS",FALSE)
    CALL _ADVPL_set_property(m_txt_arquivo,"VARIABLE",mr_arquivo_coletor,"arquivo")
    CALL _ADVPL_set_property(m_txt_arquivo,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_txt_arquivo,"VISIBLE",TRUE) 
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_label,"POSITION",630,70)     
    CALL _ADVPL_set_property(l_label,"TEXT","Dat carga:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_caixa,"POSITION",700,70)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",10,0)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_arquivo_coletor,"dat_carga")
    CALL _ADVPL_set_property(l_caixa,"FONT",NULL,11,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_label,"POSITION",820,70)     
    CALL _ADVPL_set_property(l_label,"TEXT","Hor carga:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_carga_panel_carga)
    CALL _ADVPL_set_property(l_caixa,"POSITION",890,70)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",8,0)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_arquivo_coletor,"hor_carga")
    CALL _ADVPL_set_property(l_caixa,"FONT",NULL,11,TRUE,FALSE)
    
END FUNCTION

#-------------------------------#
FUNCTION pol1351_valid_coletor()#
#-------------------------------#
   
   DEFINE l_count    INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_arquivo_coletor.tip_coletor = 'N' THEN
      LET m_msg = 'Selecione um coletor.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_coletor,"GET_FOCUS") 
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_filho,"ENABLE",FALSE)    
   LET mr_arquivo_coletor.cont_filho = 'N'       
   
   SELECT COUNT(*) INTO l_count FROM invent_user_547
    WHERE cod_empresa = p_cod_empresa
   
   IF l_count = 0 THEN
      CALL _ADVPL_set_property(m_lupa_user,"ENABLE",FALSE) 
   ELSE
      CALL _ADVPL_set_property(m_lupa_user,"ENABLE",TRUE) 
   END IF

   IF mr_arquivo_coletor.tip_coletor MATCHES '[LP]' THEN
      CALL _ADVPL_set_property(m_num_contagem,"ENABLE",FALSE) 
      LET mr_arquivo_coletor.num_contagem = '0'
      CALL _ADVPL_set_property(m_user_cantagem,"GET_FOCUS") 
   ELSE
      CALL _ADVPL_set_property(m_num_contagem,"ENABLE",TRUE) 
      CALL _ADVPL_set_property(m_num_contagem,"GET_FOCUS") 
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1351_valid_contagem()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_arquivo_coletor.num_contagem = '0' THEN
      IF mr_arquivo_coletor.tip_coletor = 'L' THEN
         LET m_msg = 'Selecione uma contagem.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_num_contagem,"ENABLE",TRUE) 
         CALL _ADVPL_set_property(m_num_contagem,"GET_FOCUS") 
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1351_valid_user()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_arquivo_coletor.cod_usuario IS NULL THEN
      LET m_msg = 'Informe o usuário que realizou a contagem.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_user_cantagem,"GET_FOCUS") 
      RETURN FALSE
   END IF
      
   SELECT 1 FROM invent_user_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_usuario = mr_arquivo_coletor.cod_usuario
   
   IF STATUS = 100 THEN

      INSERT INTO invent_user_547(
        cod_empresa,
        cod_usuario) VALUES (
           p_cod_empresa,
           mr_arquivo_coletor.cod_usuario)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','invent_user_547')
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('selecionado','invent_user_547')
         RETURN FALSE
      END IF
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1351_valid_arquivo()#
#-------------------------------#
   
   DEFINE l_arquivo      CHAR(100),
          l_tamanho      INTEGER
   
   LET l_tamanho = LENGTH(mr_invent.nom_caminho CLIPPED) + 1
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_arquivo_coletor.nom_arquivo = '0' THEN
      LET m_msg = 'Selecione um arquivo para carga.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF
   
   LET m_count = mr_arquivo_coletor.nom_arquivo
   LET mr_arquivo_coletor.nom_arquivo = ma_files[m_count]
   
   LET l_arquivo = mr_arquivo_coletor.nom_arquivo CLIPPED
   LET p_nom_arquivo = l_arquivo[l_tamanho, LENGTH(l_arquivo)]

   IF pol1351_ja_carregou() THEN
      CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF

   DELETE FROM invent_carga_547
      
   LOAD FROM l_arquivo INSERT INTO invent_carga_547
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("LOAD","arq_banco.txt")
      RETURN FALSE
   END IF
   
   DELETE FROM invent_carga_547 WHERE contagem IS NULL
   
   SELECT COUNT(*) INTO m_count FROM invent_carga_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','invent_carga_547')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'O arquivo ',l_arquivo CLIPPED, ' está vazio.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF        
   
   LET m_arq_arigem = l_arquivo
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1351_ja_carregou()#
#-----------------------------#   

   SELECT COUNT(arquivo) INTO m_count
     FROM arquivo_coletor_547
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent
      AND arquivo = p_nom_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_coletor_547')
      RETURN TRUE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Esse arquivo já foi carregado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN TRUE
   END IF
   
   RETURN FALSE

END FUNCTION   

#-----------------------------#
FUNCTION pol1351_le_contagem()#
#-----------------------------#

   SELECT MAX(registro) INTO m_id_registro
     FROM carga_coletor_547
    WHERE cod_empresa = p_cod_empresa    

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','carga_coletor_547')
      RETURN FALSE
   END IF
   
   IF m_id_registro IS NULL THEN
      LET m_id_registro = 0
   END IF

   SELECT MAX(id_arquivo) INTO m_id_arquivo
     FROM arquivo_coletor_547
    WHERE cod_empresa = p_cod_empresa    

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_coletor_547')
      RETURN FALSE
   END IF
   
   IF m_id_arquivo IS NULL THEN
      LET m_id_arquivo = 0
   END IF
   
   LET m_id_arquivo = m_id_arquivo + 1
   LET m_dat_carga = TODAY
   LET m_hor_carga = TIME
   
   CALL LOG_transaction_begin()
   
   LET p_status = LOG_progresspopup_start("Lendo registros...","pol1351_proc_leitura","PROCESS")  
   
   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
   ELSE
      CALL LOG_transaction_commit()
   END IF
   
   RETURN p_status

END FUNCTION

#------------------------------#
FUNCTION pol1351_proc_leitura()#
#------------------------------#
   
   DEFINE l_progres         SMALLINT,
          l_num_cont        INTEGER,
          l_qtd_cont        CHAR(09)

   IF mr_arquivo_coletor.tip_coletor = 'L' THEN
      LET l_num_cont = mr_arquivo_coletor.num_contagem 
      LET m_contagem = func002_strzero(l_num_cont,3)
   ELSE
      DECLARE cq_pri_regi CURSOR FOR
       SELECT contagem FROM invent_carga_547
      FOREACH cq_pri_regi INTO m_linha
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_pri_regi')
            RETURN FALSE
         END IF
         LET l_num_cont = m_linha[1,3]
         LET mr_arquivo_coletor.num_contagem = l_num_cont
         EXIT FOREACH
      END FOREACH      
   END IF
   
   IF NOT pol1351_ins_arquivo() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE ma_carga_nova TO NULL
   LET m_ind = 1

   CALL _ADVPL_set_property(m_browse_carga,"CLEAR")
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_cont CURSOR FOR
    SELECT contagem FROM invent_carga_547
   
   FOREACH cq_cont INTO m_linha
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_cont')
         RETURN FALSE
      END IF

      IF m_linha IS NULL OR m_linha = '' THEN
         CONTINUE FOREACH
      END IF
            
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET ma_carga_nova[m_ind].ies_situa = 'C'
      LET ma_carga_nova[m_ind].ies_situa_qtd = 'L'
      LET ma_carga_nova[m_ind].text_diverg = ""
      
      IF mr_arquivo_coletor.tip_coletor = 'L' THEN
         LET l_qtd_cont = m_linha[36,44]
         IF l_qtd_cont = '999999,99' THEN
            CONTINUE FOREACH
         END IF                   
         IF NOT pol1351_separa_lucas() THEN
            RETURN FALSE
         END IF
      ELSE
         LET l_qtd_cont = m_linha[49,54],',',m_linha[55,57]  
         IF l_qtd_cont = '999999,99' THEN
            CONTINUE FOREACH
         END IF                   
         IF NOT pol1351_separa_pdt() THEN
            RETURN FALSE
         END IF
      END IF            
      
      IF ma_carga_nova[m_ind].ies_ativo = 'N' THEN
         LET ma_carga_nova[m_ind].text_diverg = "CONTAGEM CANCELADA PELO USUARIO DO COLETOR"
      END IF
      
      LET m_id_registro = m_id_registro + 1
      LET ma_carga_nova[m_ind].registro = m_id_registro
      
      IF p_nom_arquivo[1,8] = 'POL1351_' THEN
         LET ma_carga_nova[m_ind].origem = 'A'
      ELSE
         IF p_nom_arquivo[2,10] = 'cont_manu' THEN
            LET ma_carga_nova[m_ind].origem = 'M'
         ELSE
            LET ma_carga_nova[m_ind].origem = 'C'
         END IF
      END IF
      
      LET ma_carga_nova[m_ind].contagem = m_contagem
            
      IF NOT pol1351_ins_carga() THEN
         RETURN FALSE
      END IF
      
      LET m_ind = m_ind + 1    
      
      IF m_ind > 3000 THEN
         LET m_msg = 'Limite de linhas da\n grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
        
   END FOREACH

   IF NOT pol1351_atu_invent(1) THEN
      RETURN FALSE
   END IF

   LET m_ind = m_ind - 1      
   CALL _ADVPL_set_property(m_browse_carga,"ITEM_COUNT", m_ind)
   
   LET mr_arquivo_coletor.dat_carga = m_dat_carga
   LET mr_arquivo_coletor.hor_carga = m_hor_carga
   LET m_nom_arquivo = p_nom_arquivo CLIPPED
   
   IF NOT pol1351_move_arquivo() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1351_separa_lucas()#
#------------------------------#

   DEFINE l_local          CHAR(10),
          l_qtd_cont       CHAR(09),
          l_den_item       CHAR(40),
          l_ies_situacao   CHAR(01)

   LET m_cod_local = m_linha[1,10]
   LET m_cod_item = m_linha[11,25]
   LET l_qtd_cont = m_linha[36,44]
   
   SELECT cod_local_estoq, 
          ies_tip_item,
          ies_ctr_lote,
          den_item,
          ies_situacao
     INTO l_local, 
          m_ies_tip_item,
          m_ies_ctr_lote,
          l_den_item,
          l_ies_situacao
     FROM item WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      LET ma_carga_nova[m_ind].text_diverg = "Item não cadastro no Logix."   
      LET l_den_item = ''
      LET m_ies_tip_item = ""
      LET m_ies_ctr_lote = ""
   ELSE
      IF l_ies_situacao <> 'A' THEN
         LET ma_carga_nova[m_ind].text_diverg = "Item não está ativo." 
      END IF
   END IF   
            
   LET ma_carga_nova[m_ind].cod_usuario = mr_arquivo_coletor.cod_usuario
   LET ma_carga_nova[m_ind].cod_local = m_cod_local
   LET ma_carga_nova[m_ind].cod_item = m_cod_item
   LET ma_carga_nova[m_ind].den_item = l_den_item
   LET ma_carga_nova[m_ind].num_lote = NULL 
   LET ma_carga_nova[m_ind].ies_ctr_lote = m_ies_ctr_lote
   LET ma_carga_nova[m_ind].ies_tipo = m_ies_tip_item  
   LET ma_carga_nova[m_ind].cod_control = m_linha[26]
   LET ma_carga_nova[m_ind].qtd_contada = l_qtd_cont   
   
   IF l_qtd_cont = '999999,99' THEN
      LET ma_carga_nova[m_ind].ies_ativo = 'N'
   ELSE
      LET ma_carga_nova[m_ind].ies_ativo = 'S'
   END IF

   IF ma_carga_nova[m_ind].cod_control = '0' THEN
      LET ma_carga_nova[m_ind].reg_pai = 0
   ELSE
      #LET ma_carga_nova[m_ind].reg_pai =       
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------------#
FUNCTION pol1351_ve_se_eh_op(l_op, l_local)#
#------------------------------------------#
   
   DEFINE l_op              INTEGER,
          l_local           CHAR(10)

   LET m_cod_local = l_local
   
   SELECT cod_local_prod INTO l_local
     FROM ordens WHERE cod_empresa = p_cod_empresa
      AND num_ordem = l_op
   
   IF STATUS = 0 THEN
      LET m_cod_local = l_local
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','ordens')
         RETURN FALSE
      END IF
   END IF  
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1351_separa_pdt()#
#----------------------------#

   DEFINE l_local          CHAR(10),
          l_qtd_cont       CHAR(09),
          l_den_item       CHAR(40),
          l_ies_situacao   CHAR(01)
   
   LET m_contagem = m_linha[1,3]
   LET m_num_lote = m_linha[4,18] CLIPPED
   LET m_cod_local = m_linha[19,33]
   LET m_cod_item = m_linha[34,48]
   LET l_qtd_cont = m_linha[49,54],',',m_linha[55,57]

   IF m_num_lote = ' ' THEN
      LET m_num_lote = NULL
   END IF

   SELECT cod_local_estoq, 
          ies_tip_item,
          ies_ctr_lote,
          den_item,
          ies_situacao
     INTO l_local, 
          m_ies_tip_item,
          m_ies_ctr_lote,
          l_den_item,
          l_ies_situacao
     FROM item WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      LET ma_carga_nova[m_ind].text_diverg = "Item não cadastro no Logix."   
      LET l_den_item = ''
      LET m_ies_tip_item = ""
      LET m_ies_ctr_lote = ""
   ELSE
      IF l_ies_situacao <> 'A' THEN
         LET ma_carga_nova[m_ind].text_diverg = "Item não está ativo." 
      END IF
   END IF   
            
   LET ma_carga_nova[m_ind].cod_usuario = mr_arquivo_coletor.cod_usuario
   LET ma_carga_nova[m_ind].cod_local = m_cod_local
   LET ma_carga_nova[m_ind].cod_item = m_cod_item
   LET ma_carga_nova[m_ind].den_item = l_den_item
   LET ma_carga_nova[m_ind].num_lote = m_num_lote 
   LET ma_carga_nova[m_ind].ies_ctr_lote = m_ies_ctr_lote
   LET ma_carga_nova[m_ind].ies_tipo = m_ies_tip_item  
   LET ma_carga_nova[m_ind].cod_control = '0'
   LET ma_carga_nova[m_ind].qtd_contada = l_qtd_cont   
   
   IF l_qtd_cont = '999999,99' THEN
      LET ma_carga_nova[m_ind].ies_ativo = 'N'
   ELSE
      LET ma_carga_nova[m_ind].ies_ativo = 'S'
   END IF

   IF ma_carga_nova[m_ind].cod_control = '0' THEN
      LET ma_carga_nova[m_ind].reg_pai = 0
   ELSE
      #LET ma_carga_nova[m_ind].reg_pai =       
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1351_ins_arquivo()#
#-----------------------------#
   
   INSERT INTO arquivo_coletor_547 (
       cod_empresa, 
       id_arquivo,  
       num_invent,  
       dat_carga,   
       hor_carga,   
       arquivo,     
       tip_coletor, 
       contagem,    
       cod_usuario)
    VALUES(p_cod_empresa, 
           m_id_arquivo,
           mr_invent.num_invent,
           m_dat_carga,
           m_hor_carga,
           p_nom_arquivo,
           mr_arquivo_coletor.tip_coletor,
           mr_arquivo_coletor.num_contagem,
           mr_arquivo_coletor.cod_usuario)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','arquivo_coletor_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE        

END FUNCTION                 

#---------------------------#
FUNCTION pol1351_ins_carga()#
#---------------------------#

   INSERT INTO carga_coletor_547 (
      cod_empresa, 
      id_arquivo,  
      cod_item,    
      cod_local,   
      num_lote,    
      controle,    
      qtde,        
      ies_ativo,   
      ies_situa,   
      tex_diverg,  
      reg_pai,     
      registro,    
      cod_usuario,
      origem,
      contagem,
      num_invent,
      ies_situa_qtd)
   VALUES(p_cod_empresa,                  
       m_id_arquivo,                      
       ma_carga_nova[m_ind].cod_item,         
       ma_carga_nova[m_ind].cod_local,        
       ma_carga_nova[m_ind].num_lote,         
       ma_carga_nova[m_ind].cod_control,      
       ma_carga_nova[m_ind].qtd_contada,      
       ma_carga_nova[m_ind].ies_ativo,       
       ma_carga_nova[m_ind].ies_situa,       
       ma_carga_nova[m_ind].text_diverg,       
       ma_carga_nova[m_ind].reg_pai,          
       ma_carga_nova[m_ind].registro,       
       ma_carga_nova[m_ind].cod_usuario,
       ma_carga_nova[m_ind].origem,
       ma_carga_nova[m_ind].contagem,
       mr_invent.num_invent,
       ma_carga_nova[m_ind].ies_situa_qtd) 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','carga_coletor_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE        

END FUNCTION                 

#---------------------------------#
FUNCTION pol1351_atu_invent(l_qtd)#
#---------------------------------#
   
   DEFINE l_qtd         INTEGER
   
   SELECT qtd_carga INTO mr_invent.qtd_carga
     FROM invent_547
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','invent_547')
      RETURN FALSE      
   END IF
   
   LET mr_invent.qtd_carga = mr_invent.qtd_carga + l_qtd
   
   UPDATE invent_547 
      SET qtd_carga = mr_invent.qtd_carga
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','invent_547')
      RETURN FALSE      
   END IF
   
   RETURN TRUE

END FUNCTION
   
#------------------------------#
FUNCTION pol1351_move_arquivo()#
#------------------------------#
   
   DEFINE l_arquivo        CHAR(100),
          l_tamanho        INTEGER
   
   IF NOT pol1351_le_caminho() THEN
      RETURN 
   END IF
   
   LET l_tamanho = LENGTH(m_arq_arigem CLIPPED) - 3
   LET l_arquivo = m_arq_arigem[1,l_tamanho]
   
   LET m_arq_dest = l_arquivo CLIPPED,'proc'

   IF m_ies_ambiente = 'W' THEN
      LET p_comando = 'move ', m_arq_arigem CLIPPED, ' ', m_arq_dest
   ELSE
      LET p_comando = 'mv ', m_arq_arigem CLIPPED, ' ', m_arq_dest
   END IF
 
   RUN p_comando RETURNING p_status
   
   IF p_status = 1 THEN
      LET m_msg = 'Não foi possivel renomear o arquivo de .txt para .txt-proces'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION
         
#---------------------------#
FUNCTION pol1351_zoom_user()#
#---------------------------#
   
    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_confirma    VARCHAR(10),
           l_cancela     VARCHAR(10),
           l_label       VARCHAR(10)
           

    LET m_dialog_user = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog_user,"SIZE",900,500) #400
    CALL _ADVPL_set_property(m_dialog_user,"TITLE","USUARIO DA CONTAGEM")
    CALL _ADVPL_set_property(m_dialog_user,"ENABLE_ESC_CLOSE",FALSE)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog_user)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1351_conf_zoom_user")  

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1351_canc_zoom_user")     

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog_user)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    CALL pol13_51_grade_user(l_panel)
    CALL pol13_51_le_user()
    
    CALL _ADVPL_set_property(m_dialog_user,"ACTIVATE",TRUE)
            
    RETURN TRUE
    
END FUNCTION

#--------------------------------#
FUNCTION pol1351_canc_zoom_user()#
#--------------------------------#

   CALL _ADVPL_set_property(m_dialog_user,"ACTIVATE",FALSE)
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1351_conf_zoom_user()#
#--------------------------------#

   LET mr_arquivo_coletor.cod_usuario = m_cod_usuario
   CALL _ADVPL_set_property(m_dialog_user,"ACTIVATE",FALSE)
   LET mr_cont_manual.cod_usuario = m_cod_usuario
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol13_51_grade_user(l_panel)#
#------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_browse_user = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse_user,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_browse_user,"BEFORE_ROW_EVENT","pol1351_sel_user")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_user)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","USUARIO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_usuario")

    CALL _ADVPL_set_property(m_browse_user,"SET_ROWS",ma_user_invent,1)
    CALL _ADVPL_set_property(m_browse_user,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse_user,"CAN_REMOVE_ROW",FALSE)

END FUNCTION

#--------------------------#
FUNCTION pol13_51_le_user()#
#--------------------------#
    
    DEFINE l_sql_stmt    CHAR(2000)
    
    INITIALIZE ma_user_invent TO NULL
    CALL _ADVPL_set_property(m_browse_user,"CLEAR")
    
    LET l_sql_stmt = "SELECT cod_usuario ",
                      " FROM invent_user_547",
                     " WHERE cod_empresa = '",p_cod_empresa,"' ",
                     " ORDER BY cod_usuario "

    PREPARE var_user_invent FROM l_sql_stmt
    
    IF STATUS <> 0 THEN
       CALL log0030_processa_err_sql("PREPARE","var_user_invent",0)
       RETURN 
    END IF

    LET m_ind = 1

    DECLARE cq_user_invent CURSOR FOR var_user_invent

    FOREACH cq_user_invent INTO ma_user_invent[m_ind].cod_usuario

       IF STATUS <> 0 THEN
          CALL log0030_processa_err_sql("FOREACH","cq_user_invent",0)
          RETURN 
       END IF
    
       LET m_ind = m_ind + 1
       
      IF m_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da grade\n de clientes ultrapasou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
    
    END FOREACH
    
   LET m_ind = m_ind - 1

   CALL _ADVPL_set_property(m_browse_user,"ITEM_COUNT", m_ind)
        
END FUNCTION

#--------------------------#
FUNCTION pol1351_sel_user()#
#--------------------------#

   DEFINE l_lin_atu     INTEGER
   
   LET l_lin_atu = _ADVPL_get_property(m_browse_user,"ROW_SELECTED")
   LET m_cod_usuario = ma_user_invent[l_lin_atu].cod_usuario   

   RETURN TRUE

END FUNCTION


#---------------------------------------------#
FUNCTION pol1351_carga_nova_grade(l_container)#
#---------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_panel_grad_carga = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel_grad_carga,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_panel_grad_carga,"EDITABLE",TRUE)
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_panel_grad_carga)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_browse_carga = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse_carga,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_browse_carga,"AFTER_ROW_EVENT","pol1351_after_row")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ativo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_ativo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sit")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_situa")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DESCRIÇÃO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",140)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TP")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOCAL")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")
       
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTADA")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_contada")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTR") #cont. do pai(0) ou filho(1)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_control")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","MOTIVO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","text_diverg")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CTR LOT")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_ctr_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOTE")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","USUÁRIO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_usuario")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ORIGEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","origem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONT")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","CONTAGEM")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_carga)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","REGISTRO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","registro")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ############")

    
    CALL _ADVPL_set_property(m_browse_carga,"SET_ROWS",ma_carga_nova,1)
    CALL _ADVPL_set_property(m_browse_carga,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse_carga,"CAN_REMOVE_ROW",FALSE) 
    #CALL _ADVPL_set_property(m_browse_carga,"EDITABLE",FALSE)
    
END FUNCTION

#---------------------------#
FUNCTION pol1351_after_row()#
#---------------------------#
   
   DEFINE l_lin_atu, l_col_atu   INTEGER
   
   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET l_lin_atu = _ADVPL_get_property(m_browse_carga,"ROW_SELECTED")
   LET l_col_atu = _ADVPL_get_property(m_browse_carga,"COLUMN_SELECTED")
      
   IF l_col_atu = 3 THEN
      IF ma_carga_nova[l_lin_atu].ies_ativo = 'S' THEN
         LET ma_carga_nova[l_lin_atu].text_diverg = ' '
         CALL _ADVPL_set_property(m_browse_carga,"COLUMN_VALUE","text_diverg",l_lin_atu," ")
         RETURN TRUE
      ELSE
         IF ma_carga_nova[l_lin_atu].text_diverg IS NULL OR 
              ma_carga_nova[l_lin_atu].text_diverg = ' ' THEN
            CALL _ADVPL_set_property(m_browse_carga,"SELECT_COLUMN",12) 
            RETURN FALSE 
         ELSE
            RETURN TRUE
         END IF
      END IF
   END IF
      
   IF ma_carga_nova[l_lin_atu].ies_ativo = 'S' THEN
      LET ma_carga_nova[l_lin_atu].text_diverg = ' '
      CALL _ADVPL_set_property(m_browse_carga,"COLUMN_VALUE","text_diverg",l_lin_atu," ")
      RETURN TRUE
   END IF
   
   IF ma_carga_nova[l_lin_atu].text_diverg IS NULL OR 
        ma_carga_nova[l_lin_atu].text_diverg = ' ' THEN
      LET m_msg = 'Para desativar uma contegem, é obrigat´roio informar o motivo.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_browse_carga,"SELECT_COLUMN",12) 
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1351_limpa_carga()#
#-----------------------------#
   
    INITIALIZE mr_arquivo_coletor.* TO NULL
    LET mr_arquivo_coletor.tip_coletor = 'L' #'N'
    LET mr_arquivo_coletor.num_contagem = '0'
    
END FUNCTION


#----------------------------#
FUNCTION pol1351_carga_find()#
#----------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    IF m_cons_carga IS NULL THEN
       LET m_cons_carga = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_cons_carga,"CONSTRUCT_NAME","pol1351_FILTER")
       CALL _ADVPL_set_property(m_cons_carga,"ADD_VIRTUAL_TABLE","arquivo_coletor_547","arquivo")
       CALL _ADVPL_set_property(m_cons_carga,"ADD_VIRTUAL_COLUMN","arquivo_coletor_547","cod_usuario","Usuário",1 {CHAR},08,0)
       CALL _ADVPL_set_property(m_cons_carga,"ADD_VIRTUAL_COLUMN","arquivo_coletor_547","arquivo","Arquivo",1 {CHAR},40,0)
       CALL _ADVPL_set_property(m_cons_carga,"ADD_VIRTUAL_COLUMN","arquivo_coletor_547","dat_carga","Data",1 {CHAR},10,0)
       CALL _ADVPL_set_property(m_cons_carga,"ADD_VIRTUAL_COLUMN","arquivo_coletor_547","tip_coletor","Coletor",1 {CHAR},1,0)
       CALL _ADVPL_set_property(m_cons_carga,"ADD_VIRTUAL_COLUMN","arquivo_coletor_547","contagem","Contagem",1 {CHAR},1,0)
    END IF

    LET l_status = _ADVPL_get_property(m_cons_carga,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_cons_carga,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_cons_carga,"ORDER_BY")
       CALL pol1351_carga_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#----------------------------------------------#
FUNCTION pol1351_carga_cursor(l_where, l_order)#
#----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)

    IF l_order IS NULL THEN
       LET l_order = " id_arquivo "
    END IF
    
    LET m_info_carga = FALSE

    LET l_sql_stmt = "SELECT DISTINCT id_arquivo ",
                      " FROM arquivo_coletor_547",
                     " WHERE ",l_where CLIPPED,
                     " AND cod_empresa = '",p_cod_empresa,"' ",
                     " AND num_invent = ", mr_invent.num_invent,
                     " ORDER BY ",l_order

    PREPARE var_carga FROM l_sql_stmt
    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","arquivo_coletor_547")
       RETURN FALSE
    END IF

    DECLARE cq_carga SCROLL CURSOR WITH HOLD FOR var_carga

    IF  STATUS <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cq_carga")
        RETURN FALSE
    END IF

    FREE var_carga

    OPEN cq_carga

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_carga")
       RETURN FALSE
    END IF

    FETCH cq_carga INTO m_id_arquivo

    IF STATUS <> 0 THEN
       IF sqlca.sqlcode <> NOTFOUND THEN
          CALL log003_err_sql("FETCH CURSOR","cq_carga")
       ELSE
          LET m_msg = "Argumentos de pesquisa não encontrados."
          CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       END IF
       RETURN FALSE
    END IF
    
    IF NOT pol1351_carga_exibe() THEN
       RETURN FALSE
    END IF
    
    LET m_info_carga = TRUE
    LET m_id_arquivoa = m_id_arquivo
    
    RETURN TRUE
    
END FUNCTION

#-----------------------------#
FUNCTION pol1351_carga_exibe()#
#-----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   INITIALIZE mr_arquivo_coletor.* TO NULL
   
   SELECT dat_carga,    
          hor_carga,    
          arquivo,      
          tip_coletor,  
          contagem,     
          cod_usuario  
     INTO mr_arquivo_coletor.dat_carga, 
          mr_arquivo_coletor.hor_carga,
          mr_arquivo_coletor.arquivo,
          mr_arquivo_coletor.tip_coletor,
          mr_arquivo_coletor.num_contagem,
          mr_arquivo_coletor.cod_usuario
     FROM arquivo_coletor_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','arquivo_coletor_547')
      RETURN FALSE
   END IF

   IF NOT pol1351_processado() THEN
      RETURN FALSE
   END IF
   
   LET m_carregando = TRUE
   
   LET p_status = LOG_progresspopup_start("Lendo registros...","pol1351_item_carga","PROCESS")  

   LET m_carregando = FALSE

   LET m_excluiu = FALSE
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1351_processado()#
#----------------------------#

   DEFINE l_qtd_proc, l_qtd_reg INTEGER
   
   SELECT COUNT(registro) INTO l_qtd_proc
     FROM carga_coletor_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo
      AND ies_ativo = 'S'
      AND ies_situa = 'P'
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','carga_coletor_547:qtd_proc')
      RETURN FALSE
   END IF
   
   SELECT COUNT(registro) INTO l_qtd_reg
     FROM carga_coletor_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo
      AND ies_ativo = 'S'
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','carga_coletor_547:qtd_reg')
      RETURN FALSE
   END IF
   
   IF l_qtd_reg  = l_qtd_proc THEN
      LET mr_arquivo_coletor.processado = 'TOTAL'
   ELSE
      IF l_qtd_proc = 0 THEN
         LET mr_arquivo_coletor.processado = 'NÃO'
      ELSE
         LET mr_arquivo_coletor.processado = 'PARCIAL'
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1351_item_carga()#
#----------------------------#

   DEFINE l_progres         SMALLINT
   
   INITIALIZE ma_carga_nova TO NULL
   LET m_ind = 1
   
   SELECT COUNT(registro) INTO m_count
     FROM carga_coletor_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','carga_coletor_547')
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_browse_carga,"CLEAR")
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_it_carga CURSOR FOR
    SELECT cod_usuario,
           cod_item,   
           cod_local,  
           num_lote,   
           controle,   
           qtde,       
           ies_ativo,  
           ies_situa,  
           tex_diverg, 
           reg_pai,    
           registro,   
           origem,
           totaliza,
           contagem   
    FROM carga_coletor_547
     WHERE cod_empresa = p_cod_empresa
       AND id_arquivo = m_id_arquivo
       
   FOREACH cq_it_carga INTO 
      ma_carga_nova[m_ind].cod_usuario,  
      ma_carga_nova[m_ind].cod_item,     
      ma_carga_nova[m_ind].cod_local,    
      ma_carga_nova[m_ind].num_lote,     
      ma_carga_nova[m_ind].cod_control,  
      ma_carga_nova[m_ind].qtd_contada,  
      ma_carga_nova[m_ind].ies_ativo,    
      ma_carga_nova[m_ind].ies_situa,    
      ma_carga_nova[m_ind].text_diverg,  
      ma_carga_nova[m_ind].reg_pai,      
      ma_carga_nova[m_ind].registro,     
      ma_carga_nova[m_ind].origem,  
      ma_carga_nova[m_ind].totaliza,  
      ma_carga_nova[m_ind].contagem           
                        
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_it_carga')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      IF ma_carga_nova[m_ind].cod_control = '0' THEN
         LET mr_arquivo_coletor.cont_filho = 'N'
      ELSE
         LET mr_arquivo_coletor.cont_filho = 'S'
      END IF

      SELECT ies_tip_item,
             ies_ctr_lote,
             den_item
        INTO ma_carga_nova[m_ind].ies_tipo,
             ma_carga_nova[m_ind].ies_ctr_lote,
             ma_carga_nova[m_ind].den_item      
        FROM item 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_carga_nova[m_ind].cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
      END IF
                                                            
      LET m_ind = m_ind + 1    
      
      IF m_ind > 3000 THEN
         LET m_msg = 'Limite de linhas da\n grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
        
   END FOREACH

   LET m_ind = m_ind - 1      
   CALL _ADVPL_set_property(m_browse_carga,"ITEM_COUNT", m_ind)
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1351_carga_informou()#
#--------------------------------#

   IF NOT m_info_carga THEN
      LET m_msg = 'Pesquise uma carga previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1351_carga_pagina(l_opcao)#
#-------------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1351_carga_informou() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_id_arquivoa = m_id_arquivo

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_carga INTO m_id_arquivo
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_carga INTO m_id_arquivo
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_carga INTO m_id_arquivo
         WHEN 'P' 
            FETCH PREVIOUS cq_carga INTO m_id_arquivo
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_carga")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_id_arquivo = m_id_arquivoa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM arquivo_coletor_547
          WHERE cod_empresa = p_cod_empresa
            AND num_invent = mr_invent.num_invent
            AND id_arquivo = m_id_arquivo
         IF STATUS = 0 THEN
            CALL pol1351_carga_exibe() RETURNING p_status
            LET l_achou = TRUE
            EXIT WHILE
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-----------------------------#
FUNCTION pol1351_carga_first()#
#-----------------------------#

   IF NOT pol1351_carga_pagina('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------------#
FUNCTION pol1351_carga_next()#
#----------------------------#

   IF NOT pol1351_carga_pagina('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------------#
FUNCTION pol1351_carga_previous()#
#--------------------------------#

   IF NOT pol1351_carga_pagina('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------#
FUNCTION pol1351_carga_last()#
#----------------------------#

   IF NOT pol1351_carga_pagina('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------------#
 FUNCTION pol1351_prende_registro()#
#----------------------------------#
   
   CALL LOG_transaction_begin()
   
   DECLARE cq_prende CURSOR FOR
    SELECT *      
    FROM arquivo_coletor_547
   WHERE cod_empresa = p_cod_empresa
     AND num_invent = mr_invent.num_invent
     AND id_arquivo = m_id_arquivo
     FOR UPDATE 
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_prende
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------#
FUNCTION pol1351_carga_exclui()#
#------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT pol1351_carga_informou() THEN
      RETURN FALSE
   END IF
   
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF pol1351_ja_processou() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol1351_prende_registro() THEN
      RETURN FALSE
   END IF
   
   LET m_msg = "Confirma a exclusão da carga da tela ?"

   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()

   IF NOT pol1351_del_carga() THEN
      CALL LOG_transaction_rollback()
      RETURN FALSE
   END IF
      
   CALL LOG_transaction_commit()

   LET m_excluiu = TRUE
   INITIALIZE ma_carga_nova, mr_arquivo_coletor.* TO NULL
   CALL _ADVPL_set_property(m_browse_carga,"CLEAR")
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1351_ja_processou()#
#------------------------------#   

   SELECT COUNT(cod_item) INTO m_count
     FROM carga_coletor_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo
      AND ies_situa = 'P'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','carga_coletor_547')
      RETURN TRUE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Arquivo já processado não pode ser exlcuido.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN TRUE
   END IF
   
   RETURN FALSE

END FUNCTION   

#---------------------------#
FUNCTION pol1351_del_carga()#
#---------------------------#   

   DELETE FROM arquivo_coletor_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','arquivo_coletor_547')
      RETURN FALSE
   END IF

   DELETE FROM carga_coletor_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','carga_coletor_547')
      RETURN FALSE
   END IF

   IF NOT pol1351_atu_invent(-1) THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol1351_carga_desativar()#
#---------------------------------#
   
   DEFINE l_lin_atu, l_qtde   INTEGER,
          l_motivo            CHAR(80)
   
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT pol1351_carga_informou() THEN
      RETURN 
   END IF
   
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN 
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_browse_carga,"ROW_SELECTED")
      
   IF ma_carga_nova[l_lin_atu].ies_ativo = 'N' THEN
      LET m_msg = 'Item de inventário já está desativado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN 
   END IF         

   IF ma_carga_nova[l_lin_atu].ies_situa = 'P' THEN
      LET m_msg = 'Item já processado não pode ser destivado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN 
   END IF         

   CALL pol1351_motivo()
   
   LET m_msg = 'Operaçaõ cancelada.'
   
   IF mr_motivo.motivo IS NOT NULL THEN
      IF pol1351_atu_carga(l_lin_atu, 'N') THEN
         LET m_msg = 'Operaçaõ efetuada com sucesso.'
      END IF      
   END IF
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)   
      
   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1351_atu_carga(l_lin, l_ativ)#
#----------------------------------------#
   
   DEFINE l_lin      INTEGER,
          l_ativ     CHAR(01)
   
   UPDATE carga_coletor_547
      SET ies_ativo = l_ativ,
          tex_diverg = mr_motivo.motivo,
          cod_usuario = p_user   
    WHERE cod_empresa = p_cod_empresa
      AND registro = ma_carga_nova[l_lin].registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','carga_coletor_547')
      RETURN FALSE
   END IF
         
   LET ma_carga_nova[l_lin].ies_ativo = l_ativ
   LET ma_carga_nova[l_lin].text_diverg = mr_motivo.motivo
   
   RETURN TRUE

END FUNCTION
   
#------------------------#
FUNCTION pol1351_motivo()#
#------------------------#
   
    DEFINE l_panel         VARCHAR(10),
           l_label         VARCHAR(10),
           l_menubar       VARCHAR(10),
           l_confirma      VARCHAR(10),
           l_cancela       VARCHAR(10)
           
    LET m_dlg_motivo = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dlg_motivo,"SIZE",900,300) #400
    CALL _ADVPL_set_property(m_dlg_motivo,"TITLE","MOTIVO")
    CALL _ADVPL_set_property(m_dlg_motivo,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dlg_motivo,"INIT_EVENT","pol1351_posi_motiv")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_motivo)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_label = _ADVPL_create_component(NULL,"LCLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,15)     
    CALL _ADVPL_set_property(l_label,"TEXT","Motivo da desativação do item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cpo_motivo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_cpo_motivo,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_cpo_motivo,"POSITION",20,45)     
    CALL _ADVPL_set_property(m_cpo_motivo,"LENGTH",100) 
    CALL _ADVPL_set_property(m_cpo_motivo,"VARIABLE",mr_motivo,"motivo")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_motivo)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1351_conf_motivo")  

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1351_canc_motivo")     

   CALL _ADVPL_set_property(m_dlg_motivo,"ACTIVATE",TRUE)
            
   RETURN TRUE
    
END FUNCTION

#----------------------------#
FUNCTION pol1351_posi_motiv()#
#----------------------------#

   CALL _ADVPL_set_property(m_cpo_motivo,"GET_FOCUS")

END FUNCTION   

#-----------------------------#
FUNCTION pol1351_conf_motivo()#
#-----------------------------#
   
   IF mr_motivo.motivo IS NULL THEN
      CALL log0030_mensagem('Infome o motivo.','info')
      CALL _ADVPL_set_property(m_cpo_motivo,"GET_FOCUS")
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_dlg_motivo,"ACTIVATE",FALSE)
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1351_canc_motivo()#
#-----------------------------#

   LET mr_motivo.motivo = NULL
   CALL _ADVPL_set_property(m_dlg_motivo,"ACTIVATE",FALSE)
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1351_carga_reativar() #
#---------------------------------#
   
   DEFINE l_lin_atu, l_qtde   INTEGER
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT pol1351_carga_informou() THEN
      RETURN 
   END IF
   
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN 
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_browse_carga,"ROW_SELECTED")
   
   LET l_qtde = ma_carga_nova[l_lin_atu].qtd_contada

   IF ma_carga_nova[l_lin_atu].ies_ativo = 'S' THEN
      LET m_msg = 'Item de inventário já está ativo.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN TRUE
   END IF         

   IF l_qtde = 999999 THEN
      LET m_msg = 'Item desativado no coletor não pode ser reativado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN TRUE
   END IF

   LET m_msg = 'Operaçaõ cancelada.'
   
   LET mr_motivo.motivo = NULL
   
   IF pol1351_atu_carga(l_lin_atu, 'S') THEN
      LET m_msg = 'Operaçaõ efetuada com sucesso.'
   END IF      
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)   

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_consiste()#
#--------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF m_id_arquivo IS NULL OR m_id_arquivo <= 0 THEN  
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Pesquise uma carga previamente.")
      RETURN 
   END IF
   
   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN 
   END IF

   SELECT COUNT(registro)
     INTO m_count
     FROM carga_coletor_547
    WHERE cod_empresa = p_cod_empresa
      AND id_arquivo = m_id_arquivo
      AND ies_ativo = 'S'
      AND ies_situa <> 'P'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','carga_coletor_547:count')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Esse arquivo não possui regostros pendentes de consistência'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN 
   END IF
         
   LET m_msg = "Confirma a consistência dos dados  ?"

   IF NOT LOG_question(m_msg) THEN
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start("Carregando...","pol1351_le_dados","PROCESS")
   
   IF p_status THEN  
      LET m_msg = 'Processamento efetuado com sucesso.'
   ELSE
      LET m_msg = 'Operação cancelada.'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')

   CALL pol1351_processado() RETURNING p_status

END FUNCTION

#--------------------------#   
FUNCTION pol1351_le_dados()#
#--------------------------#
   
   DEFINE l_progres     SMALLINT
   
   LET m_count = _ADVPL_get_property(m_browse_carga,"ITEM_COUNT")
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_consist CURSOR WITH HOLD FOR
    SELECT cod_item,   
           cod_local,  
           num_lote,   
           ies_situa_qtd,
           qtde,
           registro,
           origem 
      FROM carga_coletor_547
     WHERE cod_empresa = p_cod_empresa
       AND id_arquivo = m_id_arquivo
       AND ies_ativo = 'S'
       AND ies_situa <> 'P'

   FOREACH cq_consist INTO
      m_cod_item, m_cod_local, m_num_lote, m_ies_situa_qtd, 
      m_qtd_contagem, m_id_registro, m_origem
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','carga_coletor_547:cq_consist')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      LET m_num_lote = m_num_lote CLIPPED
      
      IF m_num_lote = '' THEN
         LET m_num_lote = NULL
      END IF
      
      LET m_qtd_erro = 0

      CALL LOG_transaction_begin()
      
      IF NOT pol1351_exec_consist() THEN
         CALL LOG_transaction_rollback()
         RETURN FALSE
      END IF
      
      IF m_qtd_erro = 0 THEN
         IF NOT pol1351_ins_constagem() THEN
            CALL LOG_transaction_rollback()
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1351_gra_carga('D') THEN
            CALL LOG_transaction_rollback()
            RETURN FALSE
         END IF
      END IF
      
      CALL LOG_transaction_commit()
      
   END FOREACH

   CALL pol1351_item_carga() RETURN p_status
         
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1351_exec_consist()#
#------------------------------#   
   
   SELECT ies_situacao, 
          ies_ctr_lote
     INTO m_ies_situa, m_ies_ctr_lote
     FROM item WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS = 100 THEN
      LET m_msg = 'Item não cadastrado no Logix'
      CALL pol1351_add_erro()
      RETURN TRUE
   ELSE  
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE  
      END IF
   END IF
             
   IF m_ies_situa <> 'A' THEN                                          
      LET m_msg = 'Item não está ativo'                                      
      CALL pol1351_add_erro()                                                
   END IF         
                                                              
   IF m_ies_ctr_lote = 'N' AND m_num_lote IS NOT NULL THEN                   
      LET m_msg = 'Informação de lote para item que não controla lote'       
      CALL pol1351_add_erro()                                                
   END IF                      
                                                 
   IF m_ies_ctr_lote = 'S' AND m_num_lote IS NULL THEN                       
      LET m_msg = 'Desinformação de lote para item que controla lote'        
      CALL pol1351_add_erro()                                                
   END IF                                                                    
   
   IF m_cod_local IS NULL THEN
      LET m_msg = 'O local da contagem não foi informado'        
      CALL pol1351_add_erro()                                                
   ELSE
      SELECT 1 FROM local
       WHERE cod_empresa = p_cod_empresa
         AND cod_local = m_cod_local
      
      IF STATUS = 100 THEN 
         LET m_msg = 'O local informado não existe no Logix'        
         CALL pol1351_add_erro()                                                
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','lcoal')
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF m_qtd_contagem IS NULL OR m_qtd_contagem < 0 THEN
      LET m_msg = 'A quantidade contada não é válida'        
      CALL pol1351_add_erro()                                                
   END IF

   IF m_ies_situa_qtd MATCHES "[LER]" THEN
   ELSE
      LET m_msg = 'A situação do estoque não é valida.'        
      CALL pol1351_add_erro()                                                
   END IF
   
   IF NOT pol1351_consist_diverg() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1351_add_erro()#
#--------------------------#

   IF m_qtd_erro < 100 THEN
      LET m_qtd_erro = m_qtd_erro + 1
      LET ma_erro[m_qtd_erro].den_erro = m_msg
   END IF
   
END FUNCTION   

#-------------------------------#  
FUNCTION pol1351_ins_constagem()#
#-------------------------------#  
   
   DEFINE l_inc_alt          CHAR(01)
   
   IF NOT pol1351_gra_carga('P') THEN
      RETURN FALSE
   END IF
   
   SELECT * INTO mr_itens_invent.*
    FROM itens_invent_547
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent
      AND cod_item = m_cod_item
      AND cod_local = m_cod_local
      AND ies_situa_qtd = m_ies_situa_qtd
      AND ((m_num_lote IS NOT NULL AND num_lote = m_num_lote) OR
           (m_num_lote IS NULL AND num_lote IS NULL))
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('SELECT','itens_invent_547:lpii')
      RETURN FALSE
   END IF   
   
   IF STATUS = 100 THEN
      LET l_inc_alt = 'I'
      INITIALIZE mr_itens_invent.* TO NULL
      LET mr_itens_invent.cod_empresa = p_cod_empresa  
      LET mr_itens_invent.cod_item = m_cod_item    
      LET mr_itens_invent.cod_local = m_cod_local    
      LET mr_itens_invent.num_lote = m_num_lote  
      LET mr_itens_invent.ies_situa_qtd = 'L'
      LET mr_itens_invent.num_invent = mr_invent.num_invent  
   ELSE
      LET l_inc_alt = 'A'
   END IF

   IF m_origem = 'A' THEN
      LET mr_itens_invent.qtd_pri_cont = m_qtd_contagem
      LET mr_itens_invent.qtd_seg_cont = m_qtd_contagem
      LET mr_itens_invent.qtd_ter_cont = NULL
   ELSE   
      IF mr_arquivo_coletor.num_contagem = '1' THEN
         LET mr_itens_invent.qtd_pri_cont = m_qtd_contagem
      ELSE
         IF mr_arquivo_coletor.num_contagem = '2' THEN
            LET mr_itens_invent.qtd_seg_cont = m_qtd_contagem
         ELSE
            LET mr_itens_invent.qtd_ter_cont = m_qtd_contagem
         END IF
      END IF      
   END IF      
   
   IF l_inc_alt = 'I' THEN     
      SELECT MAX(id_registro) INTO m_count
        FROM itens_invent_547
       WHERE cod_empresa = p_cod_empresa
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','itens_invent_547:max')
         RETURN FALSE
      END IF   
      IF m_count IS NULL THEN
         LET m_count = 0
      END IF
      LET mr_itens_invent.id_registro = m_count + 1
      INSERT INTO itens_invent_547 VALUES(mr_itens_invent.*)
   ELSE
      UPDATE itens_invent_547 
         SET qtd_pri_cont = mr_itens_invent.qtd_pri_cont,
             qtd_seg_cont = mr_itens_invent.qtd_seg_cont,
             qtd_ter_cont = mr_itens_invent.qtd_ter_cont
       WHERE cod_empresa = p_cod_empresa
         AND num_invent = mr_invent.num_invent 
         AND cod_item = m_cod_item
         AND cod_local = m_cod_local
         AND ((m_num_lote IS NOT NULL AND num_lote = m_num_lote) OR
              (m_num_lote IS NULL AND num_lote IS NULL))
   END IF
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Gravando','itens_invent_547:gpii')
      RETURN FALSE
   END IF
   
   IF NOT pol1351_grava_invent_logix('E') THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1351_gra_carga(l_status)#
#-----------------------------------#  

   DEFINE l_status     CHAR(01),
          l_texto      CHAR(200),
          l_ind        INTEGER
   
   LET l_texto = ''
   
   FOR l_ind = 1 TO m_qtd_erro
       LET l_texto = l_texto CLIPPED, ma_erro[l_ind].den_erro CLIPPED,';'
   END FOR
   
   UPDATE carga_coletor_547
      SET ies_situa = l_status, tex_diverg = l_texto
    WHERE cod_empresa = p_cod_empresa
      AND registro = m_id_registro
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','carga_coletor_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------------------------#
FUNCTION pol1351_grava_invent_logix(l_ies_situacao)#
#--------------------------------------------------#
   
   DEFINE l_ies_situacao   CHAR(01),
          l_ies_tipo       CHAR(01),
          l_dat_selec      DATE,
          l_hor_selec      CHAR(08),
          l_num_cartao     DECIMAL(8,0),
          l_num_seq        INTEGER
          
   
   LET l_dat_selec = TODAY
   LET l_hor_selec = TIME
   LET l_num_cartao = 0
   LET l_num_seq = 1
   
   SELECT ies_tip_item
     INTO l_ies_tipo
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_itens_invent.cod_item
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
     
   SELECT SUM(qtd_saldo) 
     INTO m_qtd_estoque
     FROM estoque_lote 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_itens_invent.cod_item 
      AND cod_local = mr_itens_invent.cod_local 
      AND ies_situa_qtd = mr_itens_invent.ies_situa_qtd
      AND ((num_lote = mr_itens_invent.num_lote AND mr_itens_invent.num_lote IS NOT NULL) 
          OR  (1=1 AND mr_itens_invent.num_lote IS NULL))            

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote')
      RETURN FALSE
   END IF
  
   IF m_qtd_estoque IS NULL THEN
      LET m_qtd_estoque = 0
   END IF
        
   DELETE FROM itens_invent
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_itens_invent.cod_item
      AND cod_local_estoq = mr_itens_invent.cod_local
      AND ies_situa_qtd = mr_itens_invent.ies_situa_qtd
      AND ((m_num_lote IS NOT NULL AND num_lote = mr_itens_invent.num_lote) OR
           (m_num_lote IS NULL AND mr_itens_invent.num_lote IS NULL))
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','itens_invent')
      RETURN FALSE
   END IF
    
   INSERT INTO itens_invent (
      cod_empresa,     
      cod_item,        
      ies_tip_item,    
      cod_local_estoq, 
      cod_sublocacao,  
      num_lote,        
      ies_situa_qtd,   
      qtd_estoque_sist,
      qtd_estoque_cont,
      dat_selecao,     
      hor_selecao,     
      num_cartao,      
      num_seq,         
      ies_situacao,    
      num_cartao_orig, 
      num_seq_orig) VALUES (
      mr_itens_invent.cod_empresa,          
      mr_itens_invent.cod_item,
      l_ies_tipo,
      mr_itens_invent.cod_local,  
      mr_itens_invent.cod_local,
      mr_itens_invent.num_lote,   
      mr_itens_invent.ies_situa_qtd,
      m_qtd_estoque,
      m_qtd_contagem,
      l_dat_selec,
      l_hor_selec,
      l_num_cartao,
      l_num_seq,
      l_ies_situacao,
      l_num_cartao,
      l_num_seq)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','itens_invent')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------------#
FUNCTION pol1351_consist_diverg()#
#--------------------------------#
  
   SELECT COUNT(cod_empresa)
     INTO m_cont_estoq 
     FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item
      AND cod_local = m_cod_local
      AND ies_situa_qtd <> 'L'
      AND qtd_saldo > 0
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote:pcd')
      LET m_cont_estoq = 0
      RETURN FALSE
   END IF
   
   IF m_cont_estoq > 0 THEN
      LET m_msg = 'Item possui estoque com situação diferente de L (liberado)'        
      CALL pol1351_add_erro()                                                
   END IF
      
   SELECT COUNT(cod_empresa)
     INTO m_cont_contag 
     FROM aviso_rec
    WHERE cod_empresa = p_cod_empresa
      AND ies_liberacao_cont = 'N'
      AND ies_item_estoq =  'S'
      AND cod_item = m_cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','aviso_rec:pcd')
      LET m_cont_contag = 0
      RETURN FALSE
   END IF

   IF m_cont_contag > 0 THEN
      LET m_msg = 'Item possui entrada no SUP3760 ainda sem contagem/inspeção'        
      CALL pol1351_add_erro()                                                
   END IF
       
   SELECT COUNT(cod_empresa)
     INTO m_cont_reserv 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND qtd_reservada > 0
      AND cod_item = m_cod_item
      AND cod_local = m_cod_local
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_loc_reser:pcd')
      LET m_cont_reserv = 0
      RETURN FALSE
   END IF

   IF m_cont_reserv > 0 THEN
      LET m_msg = 'Item possui reserva de estoque.'        
      CALL pol1351_add_erro()                                                
   END IF
  
  RETURN TRUE
  
END FUNCTION  


#-----FIM DAS ROTINAS PARA CARAGAS--------#

#-----------------------------------------#
# Funções para consulta dos itens contados#
#-----------------------------------------#

#--------------------------------#
FUNCTION pol1351_contado_click() #
#--------------------------------#

   IF NOT pol1351_inv_aberto() THEN
      RETURN FALSE
   END IF

   IF NOT pol1351_checa_proces() THEN
      RETURN FALSE
   END IF

   CALL pol1351_desativa_cor()
   CALL _ADVPL_set_property(m_aba_contado,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_contado,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1351_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_contados,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_panel_contados,"VISIBLE",TRUE)
   CALL pol1351_contados_limpa()
   
   RETURN TRUE
       
END FUNCTION

#-------------------------------#
FUNCTION pol1351_menu_contados()#
#-------------------------------#
   
    DEFINE l_panel, l_find    VARCHAR(10)
            
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_contados)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_find,"EVENT","pol1351_contados_informar")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1351_contados_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1351_contados_canc")
    
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_contados)

END FUNCTION

#--------------------------------#
FUNCTION pol1351_dados_contados()#
#--------------------------------#

   CALL pol1351_contados_param(m_panel_contados)
   CALL pol1351_contados_grade(m_panel_contados)
      
END FUNCTION

#-------------------------------------------#
FUNCTION pol1351_contados_param(l_container)#
#-------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa            VARCHAR(10),
           l_pesquisa        VARCHAR(10),
           l_filho           VARCHAR(10)
           
    LET m_cont_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_cont_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_cont_panel,"HEIGHT",60)
    CALL _ADVPL_set_property(m_cont_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(m_cont_panel,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cont_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",300,5)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",255,0,0)    
    CALL _ADVPL_set_property(l_label,"TEXT","CONSULTA DE CONTAGENS SUMARIZADAS POR ITEM")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cont_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET m_cont_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_cont_panel)
    CALL _ADVPL_set_property(m_cont_item,"POSITION",55,30)     
    CALL _ADVPL_set_property(m_cont_item,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_cont_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cont_item,"VARIABLE",mr_contados,"cod_item")
    CALL _ADVPL_set_property(m_cont_item,"VALID","pol1351_valid_cont_item")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_cont_panel)
    CALL _ADVPL_set_property(l_lupa,"POSITION",190,30)     
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1351_cont_zoom_item")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_cont_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",240,30)     
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"TEXT","Pesquisar itens:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)     

    LET l_pesquisa = _ADVPL_create_component(NULL,"LCOMBOBOX",m_cont_panel)
    CALL _ADVPL_set_property(l_pesquisa,"POSITION",370,30)
    CALL _ADVPL_set_property(l_pesquisa,"ADD_ITEM","T","Todos")     
    CALL _ADVPL_set_property(l_pesquisa,"ADD_ITEM","D","Com divergência")     
    CALL _ADVPL_set_property(l_pesquisa,"ADD_ITEM","S","Sem divergência")     
    CALL _ADVPL_set_property(l_pesquisa,"VARIABLE",mr_contados,"ies_pesquisar")
    CALL _ADVPL_set_property(l_pesquisa,"FONT",NULL,11,TRUE,FALSE)
    
END FUNCTION

#---------------------------------------------#
FUNCTION pol1351_contados_grade(l_container)#
#---------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE)
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_contados = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_contados,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DESCRIÇÃO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",240)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TP")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","UND")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ESTOQUE")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")
       
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTADO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_contada")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DIFEREÇA") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_difer")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CUST UNIT") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cust_unit")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","VAL DIFER") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","val_difer")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTAGEM") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","contagem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E!")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_contados)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","") 
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    
    CALL _ADVPL_set_property(m_brz_contados,"SET_ROWS",ma_contados,1)
    CALL _ADVPL_set_property(m_brz_contados,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_contados,"CAN_REMOVE_ROW",FALSE) 
    #CALL _ADVPL_set_property(m_brz_contados,"EDITABLE",FALSE)
    
END FUNCTION

#--------------------------------#
FUNCTION pol1351_cont_zoom_item()#
#--------------------------------#
    
   DEFINE l_codigo         CHAR(15),
          l_filtro         CHAR(300)

   IF m_zoom_cont_it IS NULL THEN
      LET m_zoom_cont_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_cont_it,"ZOOM","zoom_item")
   END IF

   LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_zoom_cont_it,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_cont_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_contados.cod_item = l_codigo
      LET p_status = pol1351_valid_cont_item()
   END IF
   
   CALL _ADVPL_set_property(m_lupa_it_diverg,"GET_FOCUS")
   
END FUNCTION

#---------------------------------#
FUNCTION pol1351_valid_cont_item()#
#---------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_contados.cod_item IS NULL THEN
      RETURN TRUE
   END IF

   SELECT COUNT(cod_item)
     INTO m_count
     FROM itens_invent_547
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent
      AND cod_item = mr_contados.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','itens_invent_547')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Item sem contagem no inventário atual.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
          
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1351_contados_informar()#
#-----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   CALL pol1351_contados_limpa()
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_cont_panel,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_cont_item,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1351_contados_limpa()#
#--------------------------------#

   INITIALIZE mr_contados.* TO NULL
   INITIALIZE ma_contados TO NULL
   LET mr_contados.ies_pesquisar = "T"
   #CALL _ADVPL_set_property(m_brz_contados,"CLEAR")
   CALL _ADVPL_set_property(m_brz_contados,"SET_ROWS",ma_contados,1)
   
END FUNCTION
   
#-------------------------------#
FUNCTION pol1351_contados_canc()#
#-------------------------------#

   CALL pol1351_contados_limpa()
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_cont_panel,"EDITABLE",FALSE)
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1351_contados_conf()#
#-------------------------------#
   
   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1351_le_contados","PROCESS") 

   IF p_status THEN
      CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
      CALL _ADVPL_set_property(m_cont_panel,"EDITABLE",FALSE)
   END IF
     
   RETURN p_status

END FUNCTION

#-----------------------------#
FUNCTION pol1351_le_contados()#
#-----------------------------#

   DEFINE l_progres    SMALLINT 

    SELECT COUNT(DISTINCT cod_item) INTO m_count 
      FROM itens_invent_547
     WHERE cod_empresa = p_cod_empresa
       AND num_invent = mr_invent.num_invent

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','itens_invent_547:count')
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   LET m_ind = 1
   LET mr_totais.tot_val1 = 0
   LET mr_totais.tot_val2 = 0
   
   DECLARE cq_cont CURSOR FOR
    SELECT cod_item, 
           SUM(qtd_pri_cont), 
           SUM(qtd_seg_cont), 
           SUM(qtd_ter_cont)
      FROM itens_invent_547
     WHERE cod_empresa = p_cod_empresa
       AND num_invent = mr_invent.num_invent
       AND ((cod_item = mr_contados.cod_item AND mr_contados.cod_item IS NOT NULL) 
        OR  (1=1 AND mr_contados.cod_item IS  NULL))            
     GROUP BY cod_item

   FOREACH cq_cont INTO m_cod_item,
      m_qtd_pri_cont, m_qtd_seg_cont, m_qtd_ter_cont 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_cont')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")

      SELECT SUM(qtd_saldo) INTO m_qtd_estoque
        FROM estoque_lote WHERE cod_empresa = p_cod_empresa
         AND cod_item = m_cod_item AND ies_situa_qtd = 'L'
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_lote')
         RETURN FALSE
      END IF
      
      IF m_qtd_estoque IS NULL THEN
         LET m_qtd_estoque = 0
      END IF
      
      IF m_qtd_ter_cont IS NOT NULL THEN
         LET ma_contados[m_ind].qtd_contada = m_qtd_ter_cont
         LET ma_contados[m_ind].contagem = 'TERCEIRA'
      ELSE
         IF m_qtd_seg_cont IS NOT NULL THEN
            LET ma_contados[m_ind].qtd_contada = m_qtd_seg_cont
            LET ma_contados[m_ind].contagem = 'SEGUNDA'
         ELSE
            LET ma_contados[m_ind].qtd_contada = m_qtd_pri_cont
            LET ma_contados[m_ind].contagem = 'PRIMEIRA'
         END IF
      END IF
      
      IF mr_contados.ies_pesquisar = 'T' THEN
      ELSE
         IF mr_contados.ies_pesquisar = 'D' THEN
            IF ma_contados[m_ind].qtd_contada = m_qtd_estoque THEN
               CONTINUE FOREACH
            END IF
         ELSE
            IF ma_contados[m_ind].qtd_contada <> m_qtd_estoque THEN
               CONTINUE FOREACH
            END IF
         END IF
      END IF
      
      LET ma_contados[m_ind].qtd_estoque = m_qtd_estoque
      LET ma_contados[m_ind].cod_item = m_cod_item
      
      IF NOT pol1351_le_info_compl() THEN
         RETURN FALSE
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   IF m_ind > 1 THEN
      LET ma_contados[m_ind].cod_item = 'TOTAL:'
      LET ma_contados[m_ind].qtd_difer = mr_totais.tot_val1
      LET ma_contados[m_ind].val_difer = mr_totais.tot_val2
      CALL _ADVPL_set_property(m_brz_contados,"LINE_FONT_COLOR",m_ind,215,0,0)
      CALL _ADVPL_set_property(m_brz_contados,"ITEM_COUNT", m_ind)
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1351_le_info_compl()#
#-------------------------------#

   SELECT den_item, ies_tip_item, cod_unid_med
     INTO ma_contados[m_ind].den_item,
          ma_contados[m_ind].ies_tipo,
          ma_contados[m_ind].cod_unid
     FROM Item WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','Item')
      RETURN FALSE
   END IF
      
   LET ma_contados[m_ind].qtd_difer = 
       ma_contados[m_ind].qtd_contada - ma_contados[m_ind].qtd_estoque
   
   IF ma_contados[m_ind].qtd_difer < 0 THEN
      LET ma_contados[m_ind].qtd_difer = ma_contados[m_ind].qtd_difer * (-1)
   END IF
   
   LET mr_totais.tot_val1 = mr_totais.tot_val1 + ma_contados[m_ind].qtd_difer

   SELECT cus_unit_medio INTO ma_contados[m_ind].cust_unit
     FROM item_custo WHERE cod_empresa = p_cod_empresa
      AND cod_item = ma_contados[m_ind].cod_item

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('SELECT','Item')
      RETURN FALSE
   END IF
   
   IF STATUS = 100 THEN
      LET ma_contados[m_ind].cust_unit = NULL
   END IF
   
   IF ma_contados[m_ind].cust_unit IS NULL THEN
      LET ma_contados[m_ind].val_difer = NULL
   ELSE
      LET ma_contados[m_ind].val_difer = 
          ma_contados[m_ind].qtd_difer * ma_contados[m_ind].cust_unit
      LET mr_totais.tot_val2 = mr_totais.tot_val2 + ma_contados[m_ind].val_difer
   END IF
      
   RETURN TRUE

END FUNCTION

#-----FIM DAS ROTINAS PARA ITENS CONTADOS--------#

#--------------------------------------------------------#
# Funções para consulta dos itens contados por local/lote#
#--------------------------------------------------------#

#------------------------------------#
FUNCTION pol1351_cont_loc_lot_click()#
#------------------------------------#

   IF NOT pol1351_inv_aberto() THEN
      RETURN FALSE
   END IF

   IF NOT pol1351_checa_proces() THEN
      RETURN FALSE
   END IF

   CALL pol1351_desativa_cor()
   CALL _ADVPL_set_property(m_aba_cont_loc_lot,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_cont_loc_lot,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1351_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_cont_loc_lot,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_panel_loc_lot,"VISIBLE",TRUE)
   CALL pol1351_loc_lot_limpa()
   
   RETURN TRUE
       
END FUNCTION

#-----------------------------------#
FUNCTION pol1351_menu_cont_loc_lot()#
#-----------------------------------#
   
    DEFINE l_panel, l_find      VARCHAR(10),
           l_desativa, l_ativa  VARCHAR(10)
            
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_cont_loc_lot)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_find,"EVENT","pol1351_loc_lot_informar")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1351_loc_lot_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1351_loc_lot_canc")

    LET l_desativa = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_menu_cont_loc_lot)     
    CALL _ADVPL_set_property(l_desativa,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_desativa,"TOOLTIP","Exclui item do inventário")
    CALL _ADVPL_set_property(l_desativa,"EVENT","pol1351_loc_lot_exc_item")
    
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_cont_loc_lot)

END FUNCTION

#------------------------------------#
FUNCTION pol1351_dados_cont_loc_lot()#
#------------------------------------#

   CALL pol1351_loc_lot_param(m_panel_loc_lot)
   CALL pol1351_loc_lot_grade(m_panel_loc_lot)
      
END FUNCTION

#------------------------------------------#
FUNCTION pol1351_loc_lot_param(l_container)#
#------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa            VARCHAR(10),
           l_pesquisa        VARCHAR(10),
           l_filho           VARCHAR(10)
           
    LET m_loc_lot_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_loc_lot_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_loc_lot_panel,"HEIGHT",60)
    CALL _ADVPL_set_property(m_loc_lot_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(m_loc_lot_panel,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_loc_lot_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",300,5)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",255,0,0)    
    CALL _ADVPL_set_property(l_label,"TEXT","CONSULTA DE ITENS CONTADOS POR LOCAL/LOTE")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_loc_lot_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET m_loc_lot_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_loc_lot_panel)
    CALL _ADVPL_set_property(m_loc_lot_item,"POSITION",55,30)     
    CALL _ADVPL_set_property(m_loc_lot_item,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_loc_lot_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_loc_lot_item,"VARIABLE",mr_loc_lot,"cod_item")
    CALL _ADVPL_set_property(m_loc_lot_item,"VALID","pol1351_loc_lot_valid_item")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_loc_lot_panel)
    CALL _ADVPL_set_property(l_lupa,"POSITION",190,30)     
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1351_loc_lot_zoom_item")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_loc_lot_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",240,30)     
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"TEXT","Pesquisar itens com:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)     

    LET l_pesquisa = _ADVPL_create_component(NULL,"LCOMBOBOX",m_loc_lot_panel)
    CALL _ADVPL_set_property(l_pesquisa,"POSITION",370,30)
    CALL _ADVPL_set_property(l_pesquisa,"ADD_ITEM","T","Todos")     
    CALL _ADVPL_set_property(l_pesquisa,"ADD_ITEM","D","Divergência")     
    CALL _ADVPL_set_property(l_pesquisa,"ADD_ITEM","S","Sem divergência")     
    CALL _ADVPL_set_property(l_pesquisa,"VARIABLE",mr_loc_lot,"ies_pesquisar")
    CALL _ADVPL_set_property(l_pesquisa,"FONT",NULL,11,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_loc_lot_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",535,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Local:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET m_loc_lot_local = _ADVPL_create_component(NULL,"LTEXTFIELD",m_loc_lot_panel)
    CALL _ADVPL_set_property(m_loc_lot_local,"POSITION",590,30)     
    CALL _ADVPL_set_property(m_loc_lot_local,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_loc_lot_local,"PICTURE","@!")
    CALL _ADVPL_set_property(m_loc_lot_local,"VARIABLE",mr_loc_lot,"cod_local")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_loc_lot_panel)
    CALL _ADVPL_set_property(l_lupa,"POSITION",680,30)     
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1351_loc_lot_zoom_local")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_loc_lot_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",730,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Lote:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_loc_lot_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",780,30)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",15,0)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@!")
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_loc_lot,"num_lote")
    
    
END FUNCTION

#------------------------------------------#
FUNCTION pol1351_loc_lot_grade(l_container)#
#------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE)
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_loc_lot = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_loc_lot,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DESCRIÇÃO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",240)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TP")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOCAL")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOTE")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","UND")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ESTOQUE")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")
       
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTAGEM 1")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_pri_cont")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTAGEM 2")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_seg_cont")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTAGEM 3")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_ter_cont")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DIFEREÇA") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_difer")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_loc_lot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DIVERGÊNCIA") 
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","divergencia")
    
    CALL _ADVPL_set_property(m_brz_loc_lot,"SET_ROWS",ma_loc_lot,1)
    CALL _ADVPL_set_property(m_brz_loc_lot,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_loc_lot,"CAN_REMOVE_ROW",FALSE) 
    #CALL _ADVPL_set_property(m_brz_loc_lot,"EDITABLE",FALSE)
    
END FUNCTION

#-----------------------------------#
FUNCTION pol1351_loc_lot_zoom_item()#
#-----------------------------------#
    
   DEFINE l_codigo         CHAR(15),
          l_filtro         CHAR(300)

   IF m_loc_lot_zoom_it IS NULL THEN
      LET m_loc_lot_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_loc_lot_zoom_it,"ZOOM","zoom_item")
   END IF

   LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_loc_lot_zoom_it,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_loc_lot_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_loc_lot.cod_item = l_codigo
      LET p_status = pol1351_loc_lot_valid_item()
   END IF
   
   CALL _ADVPL_set_property(m_lupa_it_diverg,"GET_FOCUS")
   
END FUNCTION

#------------------------------------#
FUNCTION pol1351_loc_lot_valid_item()#
#------------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_loc_lot.cod_item IS NULL THEN
      RETURN TRUE
   END IF

   SELECT COUNT(cod_item)
     INTO m_count
     FROM itens_invent_547
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent
      AND cod_item = mr_loc_lot.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','itens_invent_547')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Item sem contagem no inventário atual.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
          
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1351_loc_lot_zoom_local()#
#------------------------------------#
    
   DEFINE l_codigo         CHAR(15),
          l_filtro         CHAR(300)

   IF m_loc_lot_zoom_local IS NULL THEN
      LET m_loc_lot_zoom_local = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_loc_lot_zoom_local,"ZOOM","zoom_local")
   END IF

   LET l_filtro = " local.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_loc_lot_zoom_local,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_loc_lot_zoom_local,"RETURN_BY_TABLE_COLUMN","local","cod_local")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_loc_lot.cod_local = l_codigo
   END IF
   
   CALL _ADVPL_set_property(m_lupa_it_diverg,"GET_FOCUS")
   
END FUNCTION

#----------------------------------#
FUNCTION pol1351_loc_lot_informar()#
#----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   CALL pol1351_loc_lot_limpa()
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_loc_lot_panel,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_loc_lot_item,"GET_FOCUS")   
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1351_loc_lot_limpa()#
#-------------------------------#

   INITIALIZE mr_loc_lot.* TO NULL
   INITIALIZE ma_loc_lot TO NULL
   LET mr_loc_lot.ies_pesquisar = "T"
   #CALL _ADVPL_set_property(m_brz_loc_lot,"CLEAR")
   CALL _ADVPL_set_property(m_brz_loc_lot,"SET_ROWS",ma_loc_lot,1)

END FUNCTION
   
#-------------------------------#
FUNCTION pol1351_loc_lot_canc()#
#-------------------------------#

   CALL pol1351_loc_lot_limpa()
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_loc_lot_panel,"EDITABLE",FALSE)
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1351_loc_lot_conf()#
#------------------------------#
   
   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1351_le_loc_lot","PROCESS") 

   IF p_status THEN
      CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
      CALL _ADVPL_set_property(m_loc_lot_panel,"EDITABLE",FALSE)
   END IF
     
   RETURN p_status

END FUNCTION

#----------------------------#
FUNCTION pol1351_le_loc_lot()#
#----------------------------#

   DEFINE l_progres     SMALLINT,
          l_qtd_contada DECIMAL(10,3)

    SELECT COUNT(DISTINCT cod_item) INTO m_count 
      FROM itens_invent_547
     WHERE cod_empresa = p_cod_empresa
       AND num_invent = mr_invent.num_invent
       AND ((cod_item = mr_loc_lot.cod_item AND mr_loc_lot.cod_item IS NOT NULL) 
        OR  (1=1 AND mr_loc_lot.cod_item IS  NULL))            
       AND ((cod_local = mr_loc_lot.cod_local AND mr_loc_lot.cod_local IS NOT NULL) 
        OR  (1=1 AND mr_loc_lot.cod_local IS  NULL))            
       AND ((num_lote = mr_loc_lot.num_lote AND mr_loc_lot.num_lote IS NOT NULL) 
        OR  (1=1 AND mr_loc_lot.num_lote IS  NULL))            

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','itens_invent_547:count')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não a contagem para os \n parãmetros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   LET m_ind = 1
   LET mr_totais.tot_val1 = 0
   
   DECLARE cq_loc_lot CURSOR FOR
    SELECT id_registro, cod_item, cod_local, num_lote,
           qtd_pri_cont, qtd_seg_cont, qtd_ter_cont
      FROM itens_invent_547
     WHERE cod_empresa = p_cod_empresa
       AND num_invent = mr_invent.num_invent
       AND ((cod_item = mr_loc_lot.cod_item AND mr_loc_lot.cod_item IS NOT NULL) 
        OR  (1=1 AND mr_loc_lot.cod_item IS  NULL))            
       AND ((cod_local = mr_loc_lot.cod_local AND mr_loc_lot.cod_local IS NOT NULL) 
        OR  (1=1 AND mr_loc_lot.cod_local IS  NULL))            
       AND ((num_lote = mr_loc_lot.num_lote AND mr_loc_lot.num_lote IS NOT NULL) 
        OR  (1=1 AND mr_loc_lot.num_lote IS NULL))            
     ORDER BY cod_item, cod_local, num_lote
     
   FOREACH cq_loc_lot INTO 
      ma_loc_lot[m_ind].id_registro,
      ma_loc_lot[m_ind].cod_item,
      ma_loc_lot[m_ind].cod_local,
      ma_loc_lot[m_ind].num_lote,
      ma_loc_lot[m_ind].qtd_pri_cont,
      ma_loc_lot[m_ind].qtd_seg_cont,
      ma_loc_lot[m_ind].qtd_ter_cont

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','itens_invent_547:cq_loc_lot')
         RETURN FALSE
      END IF
      
      SELECT den_item, ies_tip_item, cod_unid_med
        INTO ma_loc_lot[m_ind].den_item,
             ma_loc_lot[m_ind].ies_tipo,
             ma_loc_lot[m_ind].cod_unid
        FROM Item
       WHERE cod_empresa = p_cod_empresa
         AND item.cod_item = ma_loc_lot[m_ind].cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','Item:cq_loc_lot')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      LET m_num_lote = ma_loc_lot[m_ind].num_lote
      
      SELECT qtd_saldo INTO m_qtd_estoque
        FROM estoque_lote WHERE cod_empresa = p_cod_empresa
         AND ies_situa_qtd = 'L'
         AND cod_item = ma_loc_lot[m_ind].cod_item 
         AND cod_local = ma_loc_lot[m_ind].cod_local 
         AND ((num_lote = m_num_lote AND m_num_lote IS NOT NULL) 
          OR  (1=1 AND m_num_lote IS NULL))            
               
      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','estoque_lote')
         RETURN FALSE
      END IF
      
      IF STATUS = 100 OR m_qtd_estoque IS NULL THEN
         LET m_qtd_estoque = 0
      END IF
                  
      IF ma_loc_lot[m_ind].qtd_ter_cont IS NOT NULL THEN
         LET l_qtd_contada = ma_loc_lot[m_ind].qtd_ter_cont
      ELSE
         IF ma_loc_lot[m_ind].qtd_seg_cont IS NOT NULL THEN
            LET l_qtd_contada = ma_loc_lot[m_ind].qtd_seg_cont
         ELSE
            LET l_qtd_contada = ma_loc_lot[m_ind].qtd_pri_cont
         END IF
      END IF

      IF mr_loc_lot.ies_pesquisar = 'T' THEN
      ELSE
         IF mr_loc_lot.ies_pesquisar = 'D' THEN
            IF l_qtd_contada = m_qtd_estoque THEN
               CONTINUE FOREACH
            END IF
         ELSE
            IF l_qtd_contada <> m_qtd_estoque THEN
               CONTINUE FOREACH
            END IF
         END IF
      END IF
      
      LET ma_loc_lot[m_ind].qtd_estoque = m_qtd_estoque
      LET ma_loc_lot[m_ind].qtd_difer = m_qtd_estoque - l_qtd_contada
      
      IF ma_loc_lot[m_ind].qtd_difer < 0 THEN
         LET ma_loc_lot[m_ind].qtd_difer = ma_loc_lot[m_ind].qtd_difer * (-1)
      END IF
      
      LET mr_totais.tot_val1 = mr_totais.tot_val1 + ma_loc_lot[m_ind].qtd_difer
      
      LET g_msg = NULL
      
      IF ma_loc_lot[m_ind].qtd_ter_cont IS NULL THEN
         IF ma_loc_lot[m_ind].qtd_seg_cont IS NULL THEN
            LET g_msg = g_msg CLIPPED, 'Só uma contagem;'
         ELSE
           IF ma_loc_lot[m_ind].qtd_pri_cont IS NULL THEN
               LET g_msg = g_msg CLIPPED, 'Efetuar 1a. contagem;'
            ELSE
               IF ma_loc_lot[m_ind].qtd_seg_cont <> ma_loc_lot[m_ind].qtd_pri_cont THEN
                  LET g_msg = g_msg CLIPPED, 'Contagens diferentes;'
               END IF
            END IF
         END IF
      ELSE
         IF ma_loc_lot[m_ind].qtd_pri_cont IS NULL THEN
            LET g_msg = g_msg CLIPPED, 'Efetuar 1a. contagem;'
         END IF
         IF ma_loc_lot[m_ind].qtd_seg_cont IS NULL THEN
            LET g_msg = g_msg CLIPPED, 'Efetuar 2a. contagem;'
         END IF
      END IF
      
      LET ma_loc_lot[m_ind].divergencia = g_msg
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   IF m_ind > 1 THEN
      LET ma_loc_lot[m_ind].cod_item = 'TOTAL:'
      LET ma_loc_lot[m_ind].qtd_difer = mr_totais.tot_val1
      CALL _ADVPL_set_property(m_brz_loc_lot,"LINE_FONT_COLOR",m_ind,215,0,0)
      CALL _ADVPL_set_property(m_brz_loc_lot,"ITEM_COUNT", m_ind)
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1351_loc_lot_exc_item()#
#----------------------------------#
            
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_lin_atu = _ADVPL_get_property(m_brz_loc_lot,"ROW_SELECTED")
   
   IF m_lin_atu IS NULL OR m_lin_atu <= 0 THEN
      RETURN FALSE
   END IF
   
   IF ma_loc_lot[m_lin_atu].id_registro IS NULL THEN
      LET m_msg = 'Não há itens na grade a serem excluídos.'      
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   LET p_status = pol1351_exc_item_invent(ma_loc_lot[m_lin_atu].id_registro)

   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
      LET m_msg = 'Operaçaõ cancelada.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   ELSE
      CALL LOG_transaction_commit()
      CALL _ADVPL_set_property(m_brz_loc_lot,"CAN_REMOVE_ROW",TRUE)
      CALL _ADVPL_set_property(m_brz_loc_lot,"REMOVE_ROW",m_lin_atu)
      CALL _ADVPL_set_property(m_brz_loc_lot,"CAN_REMOVE_ROW",FALSE) 
      LET m_msg = 'Operaçaõ efetuada com sucesso.'
      CALL log0030_mensagem(m_msg,'info')
   END IF         
   
   RETURN p_status

END FUNCTION

#-------------------------------------#
FUNCTION pol1351_exc_item_invent(l_id)#
#-------------------------------------#
   
   DEFINE l_id              INTEGER
   
   CALL pol1351_motivo()
   
   IF mr_motivo.motivo IS NULL THEN
      RETURN FALSE
   END IF
      
   DELETE FROM itens_invent_547
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = l_id

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','itens_invent_547')
      RETURN FALSE
   END IF
      
   LET m_num_lote = ma_loc_lot[m_lin_atu].num_lote
   
   UPDATE carga_coletor_547
      SET ies_ativo = 'N',
          tex_diverg = mr_motivo.motivo,
          cod_usuario = p_user   
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = ma_loc_lot[m_lin_atu].cod_item 
      AND cod_local = ma_loc_lot[m_lin_atu].cod_local 
      AND ((num_lote = m_num_lote AND m_num_lote IS NOT NULL) 
            OR  (1=1 AND m_num_lote IS NULL))            

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','carga_coletor_547')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----FIM DAS ROTINAS CONTADOS POR LOCAL/LOTE--------#

#---------------------------------------------------------------#
# Funções para consulta dos contados por local/lote e outros não#
#---------------------------------------------------------------#

#---------------------------------------#
FUNCTION pol1351_num_loc_out_nao_click()#
#---------------------------------------#

   IF NOT pol1351_inv_aberto() THEN
      RETURN FALSE
   END IF

   IF NOT pol1351_checa_proces() THEN
      RETURN FALSE
   END IF

   CALL pol1351_desativa_cor()
   CALL _ADVPL_set_property(m_aba_num_loc_out_nao,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_num_loc_out_nao,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1351_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_num_loc_out_nao,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_panel_num_loc_out_nao,"VISIBLE",TRUE)
   CALL pol1351_num_loc_limpa()
   
   RETURN TRUE
       
END FUNCTION

#--------------------------------------#
FUNCTION pol1351_menu_num_loc_out_nao()#
#--------------------------------------#
   
    DEFINE l_panel, l_find    VARCHAR(10)
            
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_num_loc_out_nao)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_find,"EVENT","pol1351_num_loc_informar")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1351_num_loc_info_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1351_num_loc_info_canc")
    
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_num_loc_out_nao)

END FUNCTION

#---------------------------------------#
FUNCTION pol1351_dados_num_loc_out_nao()#
#---------------------------------------#

   CALL pol1351_num_out_nao_param(m_panel_num_loc_out_nao)
   CALL pol1351_num_out_nao_grade(m_panel_num_loc_out_nao)
      
END FUNCTION

#----------------------------------------------#
FUNCTION pol1351_num_out_nao_param(l_container)#
#----------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa            VARCHAR(10),
           l_pesquisa        VARCHAR(10),
           l_filho           VARCHAR(10)
           
    LET m_num_loc_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_num_loc_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_num_loc_panel,"HEIGHT",60)
    CALL _ADVPL_set_property(m_num_loc_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(m_num_loc_panel,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_num_loc_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",300,5)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",255,0,0)    
    CALL _ADVPL_set_property(l_label,"TEXT","LOCAIS COM ESTOQ E NÃO CONTADOS P/ ITENS JÁ CONTADOS")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_num_loc_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET m_num_loc_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_num_loc_panel)
    CALL _ADVPL_set_property(m_num_loc_item,"POSITION",55,30)     
    CALL _ADVPL_set_property(m_num_loc_item,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_num_loc_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_num_loc_item,"VARIABLE",mr_num_loc,"cod_item")
    CALL _ADVPL_set_property(m_num_loc_item,"VALID","pol1351_num_loc_valid_item")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_num_loc_panel)
    CALL _ADVPL_set_property(l_lupa,"POSITION",190,30)     
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1351_num_loc_zoom_item")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_num_loc_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",400,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Local:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET m_loc_lot_local = _ADVPL_create_component(NULL,"LTEXTFIELD",m_num_loc_panel)
    CALL _ADVPL_set_property(m_loc_lot_local,"POSITION",455,30)     
    CALL _ADVPL_set_property(m_loc_lot_local,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_loc_lot_local,"PICTURE","@!")
    CALL _ADVPL_set_property(m_loc_lot_local,"VARIABLE",mr_num_loc,"cod_local")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_num_loc_panel)
    CALL _ADVPL_set_property(l_lupa,"POSITION",550,30)     
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1351_num_loc_zoom_local")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_num_loc_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",730,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Lote:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_num_loc_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",780,30)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",15,0)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@!")
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_num_loc,"num_lote")
                    

END FUNCTION

#----------------------------------------------#
FUNCTION pol1351_num_out_nao_grade(l_container)#
#----------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE)
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_num_loc = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_num_loc,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_num_loc)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_num_loc)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DESCRIÇÃO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",240)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_num_loc)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TP")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_num_loc)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOCAL")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_num_loc)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOTE")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_num_loc)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","UND")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_num_loc)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ESTOQUE")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_num_loc)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CUST UNIT") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cust_unit")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_num_loc)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","VAL ESTOQUE") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","val_estoq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_num_loc)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","") 
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    
    CALL _ADVPL_set_property(m_brz_num_loc,"SET_ROWS",ma_num_loc,1)
    CALL _ADVPL_set_property(m_brz_num_loc,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_num_loc,"CAN_REMOVE_ROW",FALSE) 
    #CALL _ADVPL_set_property(m_brz_num_loc,"EDITABLE",FALSE)

END FUNCTION

#-----------------------------------#
FUNCTION pol1351_num_loc_zoom_item()#
#-----------------------------------#
    
   DEFINE l_codigo         CHAR(15),
          l_filtro         CHAR(300)

   IF m_num_loc_zoom_it IS NULL THEN
      LET m_num_loc_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_num_loc_zoom_it,"ZOOM","zoom_item")
   END IF

   LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_num_loc_zoom_it,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_num_loc_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_num_loc.cod_item = l_codigo
      LET p_status = pol1351_num_loc_valid_item()
   END IF
   
   CALL _ADVPL_set_property(m_lupa_it_diverg,"GET_FOCUS")
   
END FUNCTION

#------------------------------------#
FUNCTION pol1351_num_loc_valid_item()#
#------------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_num_loc.cod_item IS NULL THEN
      RETURN TRUE
   END IF

   SELECT COUNT(cod_item)
     INTO m_count
     FROM itens_invent_547
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent
      AND cod_item = mr_num_loc.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','itens_invent_547')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Item sem contagem no inventário atual.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
          
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1351_num_loc_zoom_local()#
#------------------------------------#
    
   DEFINE l_codigo         CHAR(15),
          l_filtro         CHAR(300)

   IF m_num_loc_zoom_local IS NULL THEN
      LET m_num_loc_zoom_local = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_num_loc_zoom_local,"ZOOM","zoom_local")
   END IF

   LET l_filtro = " local.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_num_loc_zoom_local,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_num_loc_zoom_local,"RETURN_BY_TABLE_COLUMN","local","cod_local")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_num_loc.cod_local = l_codigo
   END IF
   
   CALL _ADVPL_set_property(m_lupa_it_diverg,"GET_FOCUS")
   
END FUNCTION

#----------------------------------#
FUNCTION pol1351_num_loc_informar()#
#----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   CALL pol1351_num_loc_limpa()
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_num_loc_panel,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_num_loc_item,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1351_num_loc_limpa()#
#-------------------------------#

   INITIALIZE mr_num_loc.* TO NULL
   INITIALIZE ma_num_loc TO NULL
   LET mr_num_loc.ies_pesquisar = "T"
   #CALL _ADVPL_set_property(m_brz_num_loc,"CLEAR")
   CALL _ADVPL_set_property(m_brz_num_loc,"SET_ROWS",ma_num_loc,1)

END FUNCTION
   
#-----------------------------------#
FUNCTION pol1351_num_loc_info_canc()#
#-----------------------------------#

   CALL pol1351_num_loc_limpa()
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_num_loc_panel,"EDITABLE",FALSE)
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1351_num_loc_info_conf()#
#-----------------------------------#
   
   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1351_le_num_loc","PROCESS") 

   IF p_status THEN
      CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
      CALL _ADVPL_set_property(m_num_loc_panel,"EDITABLE",FALSE)
   END IF
     
   RETURN p_status

END FUNCTION

#----------------------------#
FUNCTION pol1351_le_num_loc()#
#----------------------------#
                    
   DEFINE l_progres     SMALLINT,
          l_qtd_contada DECIMAL(10,3)


   SELECT COUNT(*) INTO m_count
     FROM estoque_lote e 
          INNER JOIN item i  
             ON i.cod_empresa = e.cod_empresa
            AND i.cod_item = e.cod_item 
            AND i.ies_situacao = 'A'
    WHERE e.cod_empresa = p_cod_empresa  
      AND e.qtd_saldo > 0 
      AND e.ies_situa_qtd = 'L'
      AND e.cod_item IN (
          SELECT inv1.cod_item FROM itens_invent_547 inv1
           WHERE inv1.cod_empresa = e.cod_empresa 
             AND inv1.num_invent = mr_invent.num_invent)
      AND ((e.cod_local NOT IN (
          SELECT inv2.cod_local  FROM itens_invent_547 inv2
           WHERE inv2.cod_empresa = e.cod_empresa 
             AND inv2.num_invent = mr_invent.num_invent
             AND inv2.cod_item = e.cod_item ) ) 
              OR (e.num_lote NOT IN (
                 SELECT inv3.num_lote  FROM itens_invent_547 inv3
                  WHERE inv3.cod_empresa = e.cod_empresa 
                    AND inv3.num_invent = mr_invent.num_invent
                    AND inv3.cod_item = e.cod_item ) ) )
       AND ((e.cod_item = mr_num_loc.cod_item AND mr_num_loc.cod_item IS NOT NULL) 
        OR  (1=1 AND mr_num_loc.cod_item IS  NULL))            
       AND ((e.cod_local = mr_num_loc.cod_local AND mr_num_loc.cod_local IS NOT NULL) 
        OR  (1=1 AND mr_num_loc.cod_local IS  NULL))            
       AND ((e.num_lote = mr_num_loc.num_lote AND mr_num_loc.num_lote IS NOT NULL) 
        OR  (1=1 AND mr_num_loc.num_lote IS  NULL))            

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','itens_invent_547:count')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não a contagem para os \n parãmetros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
      
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   LET m_ind = 1
   LET mr_totais.tot_val3 = 0
   
   DECLARE cq_num_loc CURSOR FOR
   SELECT e.cod_item, i.den_item, i.ies_tip_item,
          e.cod_local, e.num_lote, i.cod_unid_med
     FROM estoque_lote e 
          INNER JOIN item i  
             ON i.cod_empresa = e.cod_empresa
            AND i.cod_item = e.cod_item 
            AND i.ies_situacao = 'A'
    WHERE e.cod_empresa = p_cod_empresa  
      AND e.qtd_saldo > 0 
      AND e.ies_situa_qtd = 'L'
      AND e.cod_item IN (
          SELECT inv1.cod_item FROM itens_invent_547 inv1
           WHERE inv1.cod_empresa = e.cod_empresa 
             AND inv1.num_invent = mr_invent.num_invent)
      AND ((e.cod_local NOT IN (
          SELECT inv2.cod_local  FROM itens_invent_547 inv2
           WHERE inv2.cod_empresa = e.cod_empresa
             AND inv2.num_invent = mr_invent.num_invent
             AND inv2.cod_item = e.cod_item ) ) 
              OR (e.num_lote NOT IN (
                 SELECT inv3.num_lote  FROM itens_invent_547 inv3
                  WHERE inv3.cod_empresa = e.cod_empresa
                    AND inv3.num_invent = mr_invent.num_invent
                    AND inv3.cod_item = e.cod_item ) ) )
       AND ((e.cod_item = mr_num_loc.cod_item AND mr_num_loc.cod_item IS NOT NULL) 
        OR  (1=1 AND mr_num_loc.cod_item IS  NULL))            
       AND ((e.cod_local = mr_num_loc.cod_local AND mr_num_loc.cod_local IS NOT NULL) 
        OR  (1=1 AND mr_num_loc.cod_local IS  NULL))            
       AND ((e.num_lote = mr_num_loc.num_lote AND mr_num_loc.num_lote IS NOT NULL) 
        OR  (1=1 AND mr_num_loc.num_lote IS  NULL))            

   FOREACH cq_num_loc INTO 
      ma_num_loc[m_ind].cod_item,
      ma_num_loc[m_ind].den_item,
      ma_num_loc[m_ind].ies_tipo,
      ma_num_loc[m_ind].cod_local,
      ma_num_loc[m_ind].num_lote,
      ma_num_loc[m_ind].cod_unid

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_num_loc')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      LET m_num_lote = ma_num_loc[m_ind].num_lote
      
      SELECT qtd_saldo 
        INTO m_qtd_estoque
        FROM estoque_lote 
       WHERE cod_empresa = p_cod_empresa
         AND ies_situa_qtd = 'L'
         AND cod_item = ma_num_loc[m_ind].cod_item 
         AND cod_local = ma_num_loc[m_ind].cod_local 
         AND ((num_lote = m_num_lote AND m_num_lote IS NOT NULL) 
          OR  (1=1 AND m_num_lote IS NULL))            
               
      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','estoque_lote')
         RETURN FALSE
      END IF
      
      IF STATUS = 100 OR m_qtd_estoque IS NULL THEN
         LET m_qtd_estoque = 0
      END IF
                        
      LET ma_num_loc[m_ind].qtd_estoque = m_qtd_estoque

      SELECT cus_unit_medio 
        INTO ma_num_loc[m_ind].cust_unit
        FROM item_custo 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_num_loc[m_ind].cod_item

      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','Item')
         RETURN FALSE
      END IF
   
      IF STATUS = 100 THEN
         LET ma_num_loc[m_ind].cust_unit = NULL
         LET ma_num_loc[m_ind].val_estoq = NULL
      ELSE
         LET ma_num_loc[m_ind].val_estoq = m_qtd_estoque * ma_num_loc[m_ind].cust_unit
         LET mr_totais.tot_val3 = mr_totais.tot_val3 + ma_num_loc[m_ind].val_estoq
      END IF
            
      LET m_ind = m_ind + 1
      
      IF m_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   IF m_ind > 1 THEN
      LET ma_num_loc[m_ind].cod_item = 'TOTAL:'
      LET ma_num_loc[m_ind].val_estoq = mr_totais.tot_val3
      CALL _ADVPL_set_property(m_brz_num_loc,"LINE_FONT_COLOR",m_ind,215,0,0)
      CALL _ADVPL_set_property(m_brz_num_loc,"ITEM_COUNT", m_ind)
   END IF
   
   RETURN TRUE

END FUNCTION

#--FIM DAS ROTINAS CONTADOS NUM LOCAL E OUTORS NÃO--#

#---------------------------------------------------#
# Funções para consulta dos não contados com estoque#
#---------------------------------------------------#

#--------------------------------------#
FUNCTION pol1351_s_cont_c_estoq_click()#
#--------------------------------------#

   IF NOT pol1351_inv_aberto() THEN
      RETURN FALSE
   END IF

   IF NOT pol1351_checa_proces() THEN
      RETURN FALSE
   END IF

   CALL pol1351_desativa_cor()
   CALL _ADVPL_set_property(m_aba_s_cont_c_estoq,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_s_cont_c_estoq,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1351_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_s_cont_c_estoq,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_panel_s_cont_c_estoq,"VISIBLE",TRUE)
   CALL pol1351_sem_cont_limpa()
   LET m_pesq_nao_cont = FALSE                

   RETURN TRUE
       
END FUNCTION
                    
#-------------------------------------#
FUNCTION pol1351_menu_s_cont_c_estoq()#
#-------------------------------------#
   
    DEFINE l_panel, l_find, l_zero, l_igual_estoq    VARCHAR(10)
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_s_cont_c_estoq)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_find,"EVENT","pol1351_sem_cont_informar")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1351_sem_cont_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1351_sem_cont_canc")

    LET l_zero = _ADVPL_create_component(NULL,"LMENUBUTTON",m_menu_s_cont_c_estoq)     
    CALL _ADVPL_set_property(l_zero,"IMAGE","NEW_AUTOMATIC")     
    CALL _ADVPL_set_property(l_zero,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_zero,"TOOLTIP","Contar com saldo Zero")
    CALL _ADVPL_set_property(l_zero,"EVENT","pol1351_contar_com_zero")
    CALL _ADVPL_set_property(l_zero,"CONFIRM_EVENT","pol1351_cont_zero_conf")
    CALL _ADVPL_set_property(l_zero,"CANCEL_EVENT","pol1351_cont_zero_canc")

    LET l_igual_estoq = _ADVPL_create_component(NULL,"LMENUBUTTON",m_menu_s_cont_c_estoq)     
    CALL _ADVPL_set_property(l_igual_estoq,"IMAGE","sincronizar")     
    CALL _ADVPL_set_property(l_igual_estoq,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_igual_estoq,"TOOLTIP","Contar com saldo do Estoque")
    CALL _ADVPL_set_property(l_igual_estoq,"EVENT","pol1351_contar_igual_estoq")
    CALL _ADVPL_set_property(l_igual_estoq,"CONFIRM_EVENT","pol1351_cont_estoq_conf")
    CALL _ADVPL_set_property(l_igual_estoq,"CANCEL_EVENT","pol1351_cont_estoq_canc")
    
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_s_cont_c_estoq)

END FUNCTION

#--------------------------------------#
FUNCTION pol1351_dados_s_cont_c_estoq()#
#--------------------------------------#

   CALL pol1351_sem_cont_param(m_panel_s_cont_c_estoq)
   CALL pol1351_sem_cont_grade(m_panel_s_cont_c_estoq)
 
END FUNCTION

#------------------------------------------#
FUNCTION pol1351_sem_cont_param(l_container)#
#------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa            VARCHAR(10),
           l_filho           VARCHAR(10)
           
    LET m_sem_cont_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_sem_cont_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_sem_cont_panel,"HEIGHT",60)
    CALL _ADVPL_set_property(m_sem_cont_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(m_sem_cont_panel,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_sem_cont_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",240,5)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",255,0,0)    
    CALL _ADVPL_set_property(l_label,"TEXT","NÃO CONTADOS E COM ESTOQUE")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_sem_cont_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",665,5)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",255,0,0)    
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET m_ger_arq = _ADVPL_create_component(NULL,"LTEXTFIELD",m_sem_cont_panel)
    CALL _ADVPL_set_property(m_ger_arq,"POSITION",730,5)     
    CALL _ADVPL_set_property(m_ger_arq,"LENGTH",32,0)
    CALL _ADVPL_set_property(m_ger_arq,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_ger_arq,"VARIABLE",mr_sem_cont,"nom_ger_arq")
    CALL _ADVPL_set_property(m_ger_arq,"VALID","pol1351_nom_ger_arq")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_sem_cont_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,30)     
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"TEXT","Família:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)     

    LET m_sem_cont_fami = _ADVPL_create_component(NULL,"LTEXTFIELD",m_sem_cont_panel)
    CALL _ADVPL_set_property(m_sem_cont_fami,"POSITION",70,30)     
    CALL _ADVPL_set_property(m_sem_cont_fami,"LENGTH",5,0)
    CALL _ADVPL_set_property(m_sem_cont_fami,"PICTURE","@!")
    CALL _ADVPL_set_property(m_sem_cont_fami,"VARIABLE",mr_sem_cont,"cod_familia")
    CALL _ADVPL_set_property(m_sem_cont_fami,"VALID","pol1351_sem_cont_valid_fami")

    LET m_lupa_s_cont_fami = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_sem_cont_panel)
    CALL _ADVPL_set_property(m_lupa_s_cont_fami,"POSITION",120,30)     
    CALL _ADVPL_set_property(m_lupa_s_cont_fami,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_s_cont_fami,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_s_cont_fami,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_lupa_s_cont_fami,"CLICK_EVENT","pol1351_sem_cont_zoom_fami")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_sem_cont_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",180,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET m_sem_cont_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_sem_cont_panel)
    CALL _ADVPL_set_property(m_sem_cont_item,"POSITION",228,30)     
    CALL _ADVPL_set_property(m_sem_cont_item,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_sem_cont_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_sem_cont_item,"VARIABLE",mr_sem_cont,"cod_item")
    CALL _ADVPL_set_property(m_sem_cont_item,"VALID","pol1351_sem_cont_valid_item")

    LET m_lupa_s_cont_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_sem_cont_panel)
    CALL _ADVPL_set_property(m_lupa_s_cont_item,"POSITION",360,30)     
    CALL _ADVPL_set_property(m_lupa_s_cont_item,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_s_cont_item,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_s_cont_item,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_lupa_s_cont_item,"CLICK_EVENT","pol1351_sem_cont_zoom_item")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_sem_cont_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",485,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Local:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET m_loc_lot_local = _ADVPL_create_component(NULL,"LTEXTFIELD",m_sem_cont_panel)
    CALL _ADVPL_set_property(m_loc_lot_local,"POSITION",540,30)     
    CALL _ADVPL_set_property(m_loc_lot_local,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_loc_lot_local,"PICTURE","@!")
    CALL _ADVPL_set_property(m_loc_lot_local,"VARIABLE",mr_sem_cont,"cod_local")

    LET m_lupa_s_cont_local = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_sem_cont_panel)
    CALL _ADVPL_set_property(m_lupa_s_cont_local,"POSITION",630,30)     
    CALL _ADVPL_set_property(m_lupa_s_cont_local,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_s_cont_local,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_s_cont_local,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_lupa_s_cont_local,"CLICK_EVENT","pol1351_sem_cont_zoom_local")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_sem_cont_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",680,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Lote:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_sem_cont_panel)
    CALL _ADVPL_set_property(l_caixa,"POSITION",730,30)     
    CALL _ADVPL_set_property(l_caixa,"LENGTH",15,0)
    CALL _ADVPL_set_property(l_caixa,"PICTURE","@!")
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_sem_cont,"num_lote")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_sem_cont_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",910,30)     
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"TEXT","Coletor:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)     

    LET m_tip_coletor = _ADVPL_create_component(NULL,"LCOMBOBOX",m_sem_cont_panel)
    CALL _ADVPL_set_property(m_tip_coletor,"POSITION",990,30)
    CALL _ADVPL_set_property(m_tip_coletor,"ADD_ITEM","L","    ")     
    CALL _ADVPL_set_property(m_tip_coletor,"ADD_ITEM","N","Lucas")     
    CALL _ADVPL_set_property(m_tip_coletor,"ADD_ITEM","P","PDT")     
    CALL _ADVPL_set_property(m_tip_coletor,"ENABLE",FALSE)    
    CALL _ADVPL_set_property(m_tip_coletor,"VARIABLE",mr_sem_cont,"tip_coletor")
    CALL _ADVPL_set_property(m_tip_coletor,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_tip_coletor,"VALID","pol1351_valida_coletor") 
        
END FUNCTION

#-------------------------------------------#
FUNCTION pol1351_sem_cont_grade(l_container)#
#-------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE)
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_sem_cont = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_sem_cont,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sem_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sem_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DESCRIÇÃO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",240)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sem_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TP")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sem_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOCAL")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sem_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOTE")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sem_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","UND")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sem_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ESTOQUE")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_estoque")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sem_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CUST UNIT") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cust_unit")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sem_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","VAL ESTOQUE") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","val_estoq")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_sem_cont)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","") 
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    
    CALL _ADVPL_set_property(m_brz_sem_cont,"SET_ROWS",ma_sem_cont,1)
    CALL _ADVPL_set_property(m_brz_sem_cont,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_sem_cont,"CAN_REMOVE_ROW",FALSE) 
    #CALL _ADVPL_set_property(m_brz_sem_cont,"EDITABLE",FALSE)

END FUNCTION

#-----------------------------#
FUNCTION pol1351_nom_ger_arq()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_sem_cont.nom_ger_arq IS NULL THEN
      LET m_msg = 'Informe o nome do arquivo.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_ger_arq,"GET_FOCUS")
      RETURN FALSE
   END IF

   LET m_arq_gerar = 'POL1351_', mr_sem_cont.nom_ger_arq  CLIPPED
   
   LET p_caminho = mr_invent.nom_caminho,'\\'
   LET m_count = LOG_file_getListCount(p_caminho,m_arq_gerar,FALSE,FALSE,TRUE)
   
   IF m_count > 0 THEN
      LET m_msg = 'O arquivo ', m_arq_gerar CLIPPED, ' já existe.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_sem_cont.nom_ger_arq = m_arq_gerar
   
   CALL _ADVPL_set_property(m_sem_cont_panel,"EDITABLE",FALSE)
   
   RETURN TRUE

END FUNCTION   

#------------------------------------#
FUNCTION pol1351_sem_cont_zoom_fami()#
#------------------------------------#
    
   DEFINE l_codigo         CHAR(15),
          l_filtro         CHAR(300)

   IF m_sem_cont_zoom_fa IS NULL THEN
      LET m_sem_cont_zoom_fa = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_sem_cont_zoom_fa,"ZOOM","zoom_familia")
   END IF

   LET l_filtro = " familia.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_sem_cont_zoom_fa,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_sem_cont_zoom_fa,"RETURN_BY_TABLE_COLUMN","familia","cod_familia")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_sem_cont.cod_familia = l_codigo
      LET p_status = pol1351_sem_cont_valid_item()
   END IF
   
   CALL _ADVPL_set_property(m_lupa_it_diverg,"GET_FOCUS")
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1351_sem_cont_valid_fami()#
#-------------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_sem_cont.cod_familia IS NULL THEN
      RETURN TRUE
   END IF

   SELECT COUNT(cod_familia)
     INTO m_count
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = mr_sem_cont.cod_familia
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','familia')
      RETURN FALSE
      CALL _ADVPL_set_property(m_sem_cont_fami,"GET_FOCUS")
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Familia não existe.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_sem_cont_fami,"GET_FOCUS")
      RETURN FALSE
   END IF
          
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1351_sem_cont_zoom_item()#
#------------------------------------#
    
   DEFINE l_codigo         CHAR(15),
          l_filtro         CHAR(300)

   IF m_sem_cont_zoom_it IS NULL THEN
      LET m_sem_cont_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_sem_cont_zoom_it,"ZOOM","zoom_item")
   END IF

   LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_sem_cont_zoom_it,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_sem_cont_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_sem_cont.cod_item = l_codigo
      LET p_status = pol1351_sem_cont_valid_item()
   END IF
   
   CALL _ADVPL_set_property(m_lupa_it_diverg,"GET_FOCUS")
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1351_sem_cont_valid_item()#
#-------------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_sem_cont.cod_item IS NULL THEN
      RETURN TRUE
   END IF

   SELECT COUNT(cod_item)
     INTO m_count
     FROM itens_invent_547
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent
      AND cod_item = mr_sem_cont.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','itens_invent_547')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Esse item tem contagem no inventário atual.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   SELECT COUNT(cod_item)
     INTO m_count
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_sem_cont.cod_item
      AND ies_situacao = 'A'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Item não existe ou não está ativo.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
          
   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1351_sem_cont_zoom_local()#
#-------------------------------------#
    
   DEFINE l_codigo         CHAR(15),
          l_filtro         CHAR(300)

   IF m_sem_cont_zoom_local IS NULL THEN
      LET m_sem_cont_zoom_local = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_sem_cont_zoom_local,"ZOOM","zoom_local")
   END IF

   LET l_filtro = " local.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_sem_cont_zoom_local,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_sem_cont_zoom_local,"RETURN_BY_TABLE_COLUMN","local","cod_local")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_sem_cont.cod_local = l_codigo
   END IF
   
   CALL _ADVPL_set_property(m_lupa_it_diverg,"GET_FOCUS")
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1351_sem_cont_informar()#
#-----------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   CALL pol1351_sem_cont_limpa()
   CALL pol1351_set_info(TRUE)
   CALL _ADVPL_set_property(m_sem_cont_fami,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1351_set_info(l_status)#
#----------------------------------#

   DEFINE l_status     SMALLINT,
          l_aba        SMALLINT
   
   LET l_aba = NOT l_status
   
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",l_aba)
   CALL _ADVPL_set_property(m_sem_cont_panel,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_s_cont_fami,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_s_cont_item,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_s_cont_local,"ENABLE",l_status)   

END FUNCTION

#--------------------------------#
FUNCTION pol1351_sem_cont_limpa()#
#--------------------------------#

   INITIALIZE mr_sem_cont.* TO NULL
   INITIALIZE ma_sem_cont TO NULL
   #CALL _ADVPL_set_property(m_brz_sem_cont,"CLEAR")
   CALL _ADVPL_set_property(m_brz_sem_cont,"SET_ROWS",ma_sem_cont,1)

END FUNCTION
   
#-------------------------------#
FUNCTION pol1351_sem_cont_canc()#
#-------------------------------#

   CALL pol1351_sem_cont_limpa()
   CALL pol1351_set_info(FALSE)
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1351_sem_cont_conf()#
#-------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_sem_cont.cod_familia IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Informe a familia')
      CALL _ADVPL_set_property(m_sem_cont_fami,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1351_le_sem_cont","PROCESS") 

   IF p_status THEN
      LET m_pesq_nao_cont = TRUE
      CALL pol1351_set_info(FALSE)
   END IF
     
   RETURN p_status

END FUNCTION

#-----------------------------#
FUNCTION pol1351_le_sem_cont()#
#-----------------------------#

   DEFINE l_progres     SMALLINT,
          l_qtd_contada DECIMAL(10,3)


   SELECT count(*) INTO m_count
     FROM estoque_lote e 
          INNER JOIN item i  
             ON i.cod_empresa = e.cod_empresa
            AND i.cod_item = e.cod_item 
            AND i.ies_situacao = 'A'
            AND i.cod_familia = mr_sem_cont.cod_familia
    WHERE e.cod_empresa = p_cod_empresa  
      AND e.qtd_saldo > 0 
      AND e.ies_situa_qtd = 'L'
      AND e.cod_item NOT IN (
           SELECT cod_item FROM itens_invent_547 
            WHERE cod_empresa = p_cod_empresa AND num_invent = mr_invent.num_invent)
      AND ((e.cod_item = mr_sem_cont.cod_item AND mr_sem_cont.cod_item IS NOT NULL) 
       OR  (1=1 AND mr_sem_cont.cod_item IS  NULL))            
      AND ((e.cod_local = mr_sem_cont.cod_local AND mr_sem_cont.cod_local IS NOT NULL) 
       OR  (1=1 AND mr_sem_cont.cod_local IS  NULL))            
      AND ((e.num_lote = mr_sem_cont.num_lote AND mr_sem_cont.num_lote IS NOT NULL) 
       OR  (1=1 AND mr_sem_cont.num_lote IS  NULL))            

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote:count')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não a registros para os \n parãmetros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   LET m_ind = 1
   LET mr_totais.tot_val3 = 0
   
   DECLARE cq_sem_cont CURSOR FOR
   SELECT e.cod_item, i.den_item, i.ies_tip_item,
          e.cod_local, e.num_lote, i.cod_unid_med
     FROM estoque_lote e 
          INNER JOIN item i  
             ON i.cod_empresa = e.cod_empresa
            AND i.cod_item = e.cod_item 
            AND i.ies_situacao = 'A'
            AND i.cod_familia = mr_sem_cont.cod_familia
    WHERE e.cod_empresa = p_cod_empresa  
      AND e.qtd_saldo > 0 
      AND e.ies_situa_qtd = 'L'
      AND e.cod_item NOT IN (
           SELECT cod_item FROM itens_invent_547 
            WHERE cod_empresa = p_cod_empresa AND num_invent = mr_invent.num_invent)
      AND ((e.cod_item = mr_sem_cont.cod_item AND mr_sem_cont.cod_item IS NOT NULL) 
       OR  (1=1 AND mr_sem_cont.cod_item IS  NULL))            
      AND ((e.cod_local = mr_sem_cont.cod_local AND mr_sem_cont.cod_local IS NOT NULL) 
       OR  (1=1 AND mr_sem_cont.cod_local IS  NULL))            
      AND ((e.num_lote = mr_sem_cont.num_lote AND mr_sem_cont.num_lote IS NOT NULL) 
       OR  (1=1 AND mr_sem_cont.num_lote IS  NULL))            
     ORDER BY e.cod_item, e.cod_local, e.num_lote
     
   FOREACH cq_sem_cont INTO 
      ma_sem_cont[m_ind].cod_item,
      ma_sem_cont[m_ind].den_item,
      ma_sem_cont[m_ind].ies_tipo,
      ma_sem_cont[m_ind].cod_local,
      ma_sem_cont[m_ind].num_lote,
      ma_sem_cont[m_ind].cod_unid

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_sem_cont')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      LET m_num_lote = ma_sem_cont[m_ind].num_lote
      
      SELECT qtd_saldo 
        INTO m_qtd_estoque
        FROM estoque_lote 
       WHERE cod_empresa = p_cod_empresa
         AND ies_situa_qtd = 'L'
         AND cod_item = ma_sem_cont[m_ind].cod_item 
         AND cod_local = ma_sem_cont[m_ind].cod_local 
         AND ((num_lote = m_num_lote AND m_num_lote IS NOT NULL) 
          OR  (1=1 AND m_num_lote IS NULL))            
               
      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','estoque_lote')
         RETURN FALSE
      END IF
      
      IF STATUS = 100 OR m_qtd_estoque IS NULL THEN
         LET m_qtd_estoque = 0
      END IF
                        
      LET ma_sem_cont[m_ind].qtd_estoque = m_qtd_estoque

      SELECT cus_unit_medio 
        INTO ma_sem_cont[m_ind].cust_unit
        FROM item_custo 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_sem_cont[m_ind].cod_item

      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','Item')
         RETURN FALSE
      END IF
   
      IF STATUS = 100 THEN
         LET ma_sem_cont[m_ind].cust_unit = NULL
         LET ma_sem_cont[m_ind].val_estoq = NULL
      ELSE
         LET ma_sem_cont[m_ind].val_estoq = m_qtd_estoque * ma_sem_cont[m_ind].cust_unit
         LET mr_totais.tot_val3 = mr_totais.tot_val3 + ma_sem_cont[m_ind].val_estoq
      END IF
            
      LET m_ind = m_ind + 1
      
      IF m_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   IF m_ind > 1 THEN
      LET ma_sem_cont[m_ind].cod_item = 'TOTAL:'
      LET ma_sem_cont[m_ind].val_estoq = mr_totais.tot_val3
      CALL _ADVPL_set_property(m_brz_sem_cont,"LINE_FONT_COLOR",m_ind,215,0,0)
      CALL _ADVPL_set_property(m_brz_sem_cont,"ITEM_COUNT", m_ind)
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1351_valida_coletor()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_sem_cont.tip_coletor = 'N' THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Selecione o coletor.')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#---------------------------------#
FUNCTION pol1351_contar_com_zero()#
#---------------------------------#

   IF NOT pol1351_ve_pesquisa() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1351_ve_pesquisa()#
#-----------------------------#   

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT m_pesq_nao_cont THEN
      LET m_msg = 'Execute a pesquisa previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET  mr_sem_cont.tip_coletor = 'L' #'N'
   
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_sem_cont_panel,"EDITABLE",TRUE)   
   CALL _ADVPL_set_property(m_ger_arq,"ENABLE",TRUE)  
   CALL _ADVPL_set_property(m_ger_arq,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1351_cont_zero_conf()#
#--------------------------------#
   
   LET m_ies_contagem = 'Z'

   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1351_gera_arquivo","PROCESS") 

   CALL pol1351_set_componentes()
  
   RETURN p_status

END FUNCTION

#---------------------------------#
FUNCTION pol1351_set_componentes()#
#---------------------------------#

   CALL _ADVPL_set_property(m_sem_cont_panel,"EDITABLE",FALSE)
   CALL _ADVPL_set_property(m_ger_arq,"ENABLE",FALSE)  
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)

END FUNCTION


#--------------------------------#
FUNCTION pol1351_cont_zero_canc()#
#--------------------------------#

   CALL pol1351_set_componentes()
   INITIALIZE mr_sem_cont.nom_ger_arq TO NULL
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Operação cancelada.')
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1351_contar_igual_estoq()#
#------------------------------------#

   IF NOT pol1351_ve_pesquisa() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1351_cont_estoq_conf()#
#---------------------------------#
      
   LET m_ies_contagem = 'E'

   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1351_gera_arquivo","PROCESS") 

   CALL pol1351_set_componentes()
     
   RETURN p_status

END FUNCTION

#---------------------------------#
FUNCTION pol1351_cont_estoq_canc()#
#---------------------------------#
   
   CALL pol1351_set_componentes()
   INITIALIZE mr_sem_cont.nom_ger_arq TO NULL
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'Operação cancelada.')
   RETURN TRUE
   
END FUNCTION
      
#------------------------------#
FUNCTION pol1351_gera_arquivo()#
#------------------------------#
   
   DEFINE l_arq_gerar      CHAR(120),
          l_nom_compl      CHAR(20)
   
   LET p_caminho = mr_invent.nom_caminho,'\\'
   LET m_count = LOG_file_getListCount(p_caminho,m_arq_gerar,FALSE,FALSE,TRUE)
   
   IF m_count > 0 THEN
      LET m_msg = 'O arquivo ', m_arq_gerar CLIPPED, ' já existe.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN TRUE
   END IF
   
   LET l_arq_gerar = mr_invent.nom_caminho CLIPPED, m_arq_gerar CLIPPED
   
   START REPORT pol1351_gerarq TO l_arq_gerar
   
   IF mr_sem_cont.tip_coletor = 'L' THEN
      CALL pol1351_ger_arq_lucas()
   ELSE
      CALL pol1351_ger_arq_pdt()
   END IF
   
   FINISH REPORT pol1351_gerarq
   
   LET m_msg =  'Arquivo ', m_arq_gerar CLIPPED,
      ' gerado no caminho ', mr_invent.nom_caminho
   CALL log0030_mensagem(m_msg, 'info')
   
   LET m_pesq_nao_cont = FALSE
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1351_ger_arq_lucas()#
#-------------------------------#
   
   DEFINE l_ctr       CHAR(10),
          l_quant     CHAR(09),
          l_estoque   DECIMAL(10,2)
   
   LET l_ctr = '0         '
   LET l_quant = '000000,00'
   
   FOR m_ind = 1 TO m_qtd_item
       
       IF m_ies_contagem = 'E' THEN
          LET l_estoque = ma_sem_cont[m_ind].qtd_estoque
          LET l_quant = func002_dec_strzero(l_estoque, 9)           
       END IF
         
       LET m_linha = ma_sem_cont[m_ind].cod_local, ma_sem_cont[m_ind].cod_item, l_ctr, l_quant
       
       LET m_linha = m_linha CLIPPED
       
       OUTPUT TO REPORT pol1351_gerarq()
       
   END FOR

END FUNCTION

#-----------------------------#
FUNCTION pol1351_ger_arq_pdt()#
#-----------------------------#
   
   DEFINE l_cont      CHAR(03),
          l_quant     CHAR(09),
          l_estoque   CHAR(10),
          l_estoq_int INTEGER,
          l_local     CHAR(15),
          l_lote      CHAR(15),
          l_item      CHAR(15)
   
   LET l_cont = '001'
   LET l_quant = '000000000'
   
   FOR m_ind = 1 TO m_qtd_item
       
       LET l_local = ma_sem_cont[m_ind].cod_local
       LET l_lote = ma_sem_cont[m_ind].num_lote
       LET l_item = ma_sem_cont[m_ind].cod_item
       
       IF m_ies_contagem = 'E' THEN
          LET l_estoque = ma_sem_cont[m_ind].qtd_estoque
          LET l_estoq_int = func002_tira_formato(l_estoque)
          LET l_quant = func002_strzero(l_estoq_int, 9)           
       END IF
         
       LET m_linha = l_cont, l_lote, l_local, l_item, l_quant
       
       LET m_linha = m_linha CLIPPED
       
       OUTPUT TO REPORT pol1351_gerarq()
       
   END FOR

END FUNCTION

#-----------------------#
 REPORT pol1351_gerarq()#
#-----------------------#
       
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
          
   FORMAT
          
      ON EVERY ROW

         PRINT COLUMN 001, m_linha
                                      
END REPORT
                  
   

#-----FIM DAS ROTINAS NÃO CONTADOS COM ESTOQUE--------#

#-----------------------------------------------------#
# Funções para consulta dos contados mais de uma vez  #
#-----------------------------------------------------#

#--------------------------------------#
FUNCTION pol1351_cont_mais_1vez_click()#
#--------------------------------------#

   IF NOT pol1351_inv_aberto() THEN
      RETURN FALSE
   END IF

   IF NOT pol1351_checa_proces() THEN
      RETURN FALSE
   END IF

   CALL pol1351_desativa_cor()
   CALL _ADVPL_set_property(m_aba_cont_mais_de_1vez,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_cont_mais_de_1vez,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1351_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_cont_mais_1vez,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_panel_cont_mais_1vez,"VISIBLE",TRUE)
   CALL pol1351_mais_1vez_limpa()

   RETURN TRUE
       
END FUNCTION

#-------------------------------------#
FUNCTION pol1351_menu_cont_mais_1vez()#
#-------------------------------------#
   
    DEFINE l_find           VARCHAR(10)
    
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_cont_mais_1vez)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_find,"EVENT","pol1351_mais_1vez_informar")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1351_mais_1vez_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1351_mais_1vez_canc")
    
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_cont_mais_1vez)

END FUNCTION

#--------------------------------------#
FUNCTION pol1351_dados_cont_mais_1vez()#
#--------------------------------------#

   CALL pol1351_cont_mais_1vez_param(m_panel_cont_mais_1vez)
   CALL pol1351_cont_mais_1vez_grade(m_panel_cont_mais_1vez)
   CALL pol1351_cont_mais_1vez_radape(m_panel_cont_mais_1vez)
 
END FUNCTION

#-------------------------------------------------#
FUNCTION pol1351_cont_mais_1vez_param(l_container)#
#-------------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa            VARCHAR(10)
           
    LET m_mais_1vez_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_mais_1vez_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_mais_1vez_panel,"HEIGHT",40)
    CALL _ADVPL_set_property(m_mais_1vez_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(m_mais_1vez_panel,"EDITABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_mais_1vez_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",240,10)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",255,0,0)    
    CALL _ADVPL_set_property(l_label,"TEXT","CONTADOS MAIS DE UMA VEZ")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_mais_1vez_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",650,10)     
    CALL _ADVPL_set_property(l_label,"TEXT","Item:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET m_mais_1vez_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_mais_1vez_panel)
    CALL _ADVPL_set_property(m_mais_1vez_item,"POSITION",730,10)     
    CALL _ADVPL_set_property(m_mais_1vez_item,"LENGTH",15,0)
    CALL _ADVPL_set_property(m_mais_1vez_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_mais_1vez_item,"VARIABLE",mr_mais_1vez,"cod_item")
    CALL _ADVPL_set_property(m_mais_1vez_item,"VALID","pol1351_mais_1vez_valid_item")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_mais_1vez_panel)
    CALL _ADVPL_set_property(l_lupa,"POSITION",870,10)     
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1351_mais_1vez_zoom_item")
        
END FUNCTION

#-------------------------------------------------#
FUNCTION pol1351_cont_mais_1vez_grade(l_container)#
#-------------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    #CALL _ADVPL_set_property(l_panel,"EDITABLE",FALSE)
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_mais_1vez = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_mais_1vez,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_mais_1vez,"BEFORE_ROW_EVENT","pol1351_before_row")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mais_1vez)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mais_1vez)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DESCRIÇÃO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",240)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mais_1vez)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TP")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mais_1vez)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOCAL")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mais_1vez)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOTE")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mais_1vez)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","UND")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mais_1vez)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTAGEM")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","contagem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mais_1vez)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","NUM VEZ") 
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_vez")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##")
    
    CALL _ADVPL_set_property(m_brz_mais_1vez,"SET_ROWS",ma_mais_1vez,1)
    CALL _ADVPL_set_property(m_brz_mais_1vez,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_mais_1vez,"CAN_REMOVE_ROW",FALSE) 
    #CALL _ADVPL_set_property(m_brz_mais_1vez,"EDITABLE",FALSE)

END FUNCTION

#--------------------------------------------------#
FUNCTION pol1351_cont_mais_1vez_radape(l_container)#
#--------------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_1vez_rodape = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_1vez_rodape,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_1vez_rodape)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ARQUIVO CARREGADO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_arquivo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_1vez_rodape)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","USUÁRIO")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_usuario")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_1vez_rodape)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","QTD CONTADA")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_contada")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")
        
    CALL _ADVPL_set_property(m_brz_1vez_rodape,"SET_ROWS",ma_1vez_rodape,1)
    CALL _ADVPL_set_property(m_brz_1vez_rodape,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_1vez_rodape,"CAN_REMOVE_ROW",FALSE) 
    #CALL _ADVPL_set_property(m_brz_1vez_rodape,"EDITABLE",FALSE)

END FUNCTION

#-------------------------------------#
FUNCTION pol1351_mais_1vez_zoom_item()#
#-------------------------------------#
    
   DEFINE l_codigo         CHAR(15),
          l_filtro         CHAR(300)

   IF m_mais_1vez_zoom_it IS NULL THEN
      LET m_mais_1vez_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_mais_1vez_zoom_it,"ZOOM","zoom_item")
   END IF

   LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
   CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_mais_1vez_zoom_it,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_mais_1vez_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   
   IF l_codigo IS NOT NULL THEN
      LET mr_mais_1vez.cod_item = l_codigo
      LET p_status = pol1351_mais_1vez_valid_item()
   END IF
   
   CALL _ADVPL_set_property(m_lupa_it_diverg,"GET_FOCUS")
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1351_mais_1vez_valid_item()#
#--------------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_mais_1vez.cod_item IS NULL THEN
      RETURN TRUE
   END IF

   SELECT COUNT(cod_item)
     INTO m_count
     FROM itens_invent_547
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent
      AND cod_item = mr_mais_1vez.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','itens_invent_547')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Esse item tem contagem no inventário atual.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   SELECT COUNT(cod_item)
     INTO m_count
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_mais_1vez.cod_item
      AND ies_situacao = 'A'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Item não existe ou não está ativo.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
          
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1351_mais_1vez_informar()#
#------------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   CALL pol1351_mais_1vez_limpa()
   CALL pol1351_config_1vez(TRUE)
   CALL _ADVPL_set_property(m_mais_1vez_item,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1351_mais_1vez_limpa()#
#---------------------------------#

   INITIALIZE mr_mais_1vez.* TO NULL
   INITIALIZE ma_mais_1vez TO NULL
   INITIALIZE ma_1vez_rodape TO NULL
   #CALL _ADVPL_set_property(m_brz_mais_1vez,"CLEAR")
   CALL _ADVPL_set_property(m_brz_mais_1vez,"SET_ROWS",ma_mais_1vez,1)
   #CALL _ADVPL_set_property(m_brz_1vez_rodape,"CLEAR")
   CALL _ADVPL_set_property(m_brz_1vez_rodape,"SET_ROWS",ma_1vez_rodape,1)

END FUNCTION

#-------------------------------------#
FUNCTION pol1351_config_1vez(l_status)#
#-------------------------------------#

   DEFINE l_status     SMALLINT,
          l_aba        SMALLINT
   
   LET l_aba = NOT l_status
   
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",l_aba)
   CALL _ADVPL_set_property(m_mais_1vez_panel,"EDITABLE",l_status)

END FUNCTION
   
#--------------------------------#
FUNCTION pol1351_mais_1vez_canc()#
#--------------------------------#

   CALL pol1351_mais_1vez_limpa()
   CALL pol1351_config_1vez(FALSE)
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1351_mais_1vez_conf()#
#--------------------------------#
   
   LET m_carregando = TRUE
   
   LET p_status = LOG_progresspopup_start(
     "Pesquisando...","pol1351_le_cont_mais_1vez","PROCESS") 
   
   IF p_status THEN
      CALL pol1351_config_1vez(FALSE)
   ELSE
      LET m_msg = 'Operação cancelada.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
   
   LET m_carregando = FALSE
   
   RETURN p_status

END FUNCTION

#-----------------------------------#
FUNCTION pol1351_le_cont_mais_1vez()#
#-----------------------------------#
   
   DEFINE l_progres         SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",15)
   LET m_ind = 1
   
   DECLARE cq_mais_vez CURSOR FOR    
    SELECT cod_item, cod_local, num_lote, contagem, count(*) 
      FROM carga_coletor_547  
     WHERE cod_empresa = p_cod_empresa
       AND num_invent = mr_invent.num_invent
     GROUP BY cod_item, cod_local, num_lote, contagem  
    HAVING count(*) > 1
   
   FOREACH cq_mais_vez INTO
           ma_mais_1vez[m_ind].cod_item, 
           ma_mais_1vez[m_ind].cod_local,
           ma_mais_1vez[m_ind].num_lote, 
           ma_mais_1vez[m_ind].contagem, 
           ma_mais_1vez[m_ind].num_vez  

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_mais_vez')
         RETURN FALSE
      END IF
                    
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      SELECT den_item, cod_unid_med, ies_tip_item
        INTO ma_mais_1vez[m_ind].den_item,
             ma_mais_1vez[m_ind].cod_unid,
             ma_mais_1vez[m_ind].ies_tipo
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_mais_1vez[m_ind].cod_item 
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 500 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   IF m_ind > 1 THEN
      LET m_ind = m_ind - 1
      CALL _ADVPL_set_property(m_brz_mais_1vez,"ITEM_COUNT", m_ind)
      CALL pol1351_le_arquivo(1)
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1351_before_row()#
#----------------------------#

   DEFINE l_linha    integer
   
   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
         
   LET l_linha = _ADVPL_get_property(m_brz_mais_1vez,"ROW_SELECTED")
   LET m_num_lote = ma_mais_1vez[l_linha].num_lote
   
   CALL pol1351_le_arquivo(l_linha)
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#   
FUNCTION pol1351_le_arquivo(l_linha)#
#-----------------------------------#
  
   DEFINE l_linha    integer
      
   INITIALIZE ma_1vez_rodape TO NULL
   CALL _ADVPL_set_property(m_brz_1vez_rodape,"CLEAR")
  
   LET m_ind = 1
   
   DECLARE cq_le_arq CURSOR FOR
   SELECT a.arquivo, a.cod_usuario, c.qtde
     FROM arquivo_coletor_547 a, carga_coletor_547 c
    WHERE a.cod_empresa = p_cod_empresa
      AND a.num_invent = mr_invent.num_invent
      AND c.cod_empresa = a.cod_empresa
      AND c.id_arquivo = a.id_arquivo
      AND c.cod_item = ma_mais_1vez[l_linha].cod_item
      AND c.contagem = ma_mais_1vez[l_linha].contagem
      AND c.cod_local = ma_mais_1vez[l_linha].cod_local
      AND ((c.num_lote IS NULL AND m_num_lote IS NULL) 
            OR (c.num_lote = m_num_lote AND m_num_lote IS NOT NULL))      
   
   FOREACH cq_le_arq INTO
      ma_1vez_rodape[m_ind].nom_arquivo,
      ma_1vez_rodape[m_ind].cod_usuario,
      ma_1vez_rodape[m_ind].qtd_contada
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_le_arq')
         RETURN FALSE
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 20 THEN
         LET m_msg = 'Limite de linhas da array \n ma_1vez_rodape ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   IF m_ind > 1 THEN
      LET m_ind = m_ind - 1
      CALL _ADVPL_set_property(m_brz_1vez_rodape,"ITEM_COUNT", m_ind)
   END IF
   
   RETURN TRUE

END FUNCTION


#---FIM DAS ROTINAS PARA CONTAGEM MAIS DE UMA VEZ----#

#---ROTINAS PARA CONTAGEM MANUAL---------------------#

#-----------------------------------#
FUNCTION pol1351_cont_manual_click()#
#-----------------------------------#

   IF NOT pol1351_inv_aberto() THEN
      RETURN FALSE
   END IF

   CALL pol1351_desativa_cor()
   CALL _ADVPL_set_property(m_aba_cont_manual,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_cont_manual,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1351_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_cont_manual,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_panel_cont_manual,"VISIBLE",TRUE)
   CALL pol1351_cont_manual_limpa()

   RETURN TRUE
       
END FUNCTION

#----------------------------------#
FUNCTION pol1351_menu_cont_manual()#
#----------------------------------#
   
    DEFINE l_find           VARCHAR(10),
           l_abrir          VARCHAR(10),
           l_update         VARCHAR(10)
           
    
    LET m_info_manual = FALSE
    
    LET l_find = _ADVPL_create_component(NULL,"LINFORMBUTTON",m_menu_cont_manual)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_find,"EVENT","pol1351_cont_manual_informar")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1351_cont_manual_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1351_cont_manual_canc")
 
    LET l_abrir = _ADVPL_create_component(NULL,"LMENUBUTTON",m_menu_cont_manual)
    CALL _ADVPL_set_property(l_abrir,"IMAGE","REABRIR")   
    CALL _ADVPL_set_property(l_abrir,"TOOLTIP","Abrir arquivo para edição")   
    CALL _ADVPL_set_property(l_abrir,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_abrir,"EVENT","pol1351_abre_cont_manu")
    CALL _ADVPL_set_property(l_abrir,"CONFIRM_EVENT","pol1351_abre_cont_manu_conf")
    CALL _ADVPL_set_property(l_abrir,"CANCEL_EVENT","pol1351_abre_cont_manu_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_menu_cont_manual)
    CALL _ADVPL_set_property(l_update,"TOOLTIP","Modificar arquivo de contagem")   
    CALL _ADVPL_set_property(l_update,"EVENT","pol1351_edita_cont_manu")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1351_edita_cont_manu_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1351_edita_cont_manu_canc")
        
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_cont_manual)

END FUNCTION

#-----------------------------------#
FUNCTION pol1351_dados_cont_manual()#
#-----------------------------------#

   CALL pol1351_cont_manual_param(m_panel_cont_manual)
   CALL pol1351_cont_manual_grade(m_panel_cont_manual)
 
END FUNCTION

#----------------------------------------------#
FUNCTION pol1351_cont_manual_param(l_container)#
#----------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa            VARCHAR(10)
           
    LET m_param_manual_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_param_manual_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_param_manual_panel,"HEIGHT",55)
    CALL _ADVPL_set_property(m_param_manual_panel,"BACKGROUND_COLOR",231,237,237)
    CALL _ADVPL_set_property(m_param_manual_panel,"ENABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_param_manual_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",350,5)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",255,0,0)    
    CALL _ADVPL_set_property(l_label,"TEXT","CONTAGEM MANUAL")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_param_manual_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",10,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Usuário:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)

    LET m_user_cont = _ADVPL_create_component(NULL,"LTEXTFIELD",m_param_manual_panel)
    CALL _ADVPL_set_property(m_user_cont,"POSITION",70,30)     
    CALL _ADVPL_set_property(m_user_cont,"LENGTH",8,0)
    CALL _ADVPL_set_property(m_user_cont,"VARIABLE",mr_cont_manual,"cod_usuario")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_param_manual_panel)
    CALL _ADVPL_set_property(l_lupa,"POSITION",150,30)     
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1351_zoom_user")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_param_manual_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",180,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_sel_arquivo = _ADVPL_create_component(NULL,"LCOMBOBOX",m_param_manual_panel)     
    CALL _ADVPL_set_property(m_sel_arquivo,"POSITION",240,30) 
    CALL _ADVPL_set_property(m_sel_arquivo,"VARIABLE",mr_cont_manual,"sel_arquivo")
    CALL _ADVPL_set_property(m_sel_arquivo,"FONT",NULL,11,TRUE,FALSE)
    CALL _ADVPL_set_property(m_sel_arquivo,"VISIBLE",FALSE) 

    LET m_arq_manual = _ADVPL_create_component(NULL,"LTEXTFIELD",m_param_manual_panel)     
    CALL _ADVPL_set_property(m_arq_manual,"POSITION",240,30) 
    CALL _ADVPL_set_property(m_arq_manual,"LENGTH",30,0)    
    CALL _ADVPL_set_property(m_arq_manual,"VARIABLE",mr_cont_manual,"nom_arquivo")
    CALL _ADVPL_set_property(m_arq_manual,"VISIBLE",TRUE) 
    CALL _ADVPL_set_property(m_arq_manual,"VALID","pol1351_ck_nom_arq") 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_param_manual_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",780,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Contagem:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_num_cont_manual = _ADVPL_create_component(NULL,"LCOMBOBOX",m_param_manual_panel)
    CALL _ADVPL_set_property(m_num_cont_manual,"POSITION",860,30)
    CALL _ADVPL_set_property(m_num_cont_manual,"ADD_ITEM","1","001")     
    CALL _ADVPL_set_property(m_num_cont_manual,"ADD_ITEM","2","002")     
    CALL _ADVPL_set_property(m_num_cont_manual,"ADD_ITEM","3","003")    
    CALL _ADVPL_set_property(m_num_cont_manual,"ENABLE",FALSE)   
    CALL _ADVPL_set_property(m_num_cont_manual,"VARIABLE",mr_cont_manual,"num_contagem")
    CALL _ADVPL_set_property(m_num_cont_manual,"FONT",NULL,11,TRUE,FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_param_manual_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",940,30)     
    CALL _ADVPL_set_property(l_label,"TEXT","Coletor:")    
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,FALSE,TRUE)

    LET m_coletor = _ADVPL_create_component(NULL,"LCOMBOBOX",m_param_manual_panel)
    CALL _ADVPL_set_property(m_coletor,"POSITION",1000,30)
    CALL _ADVPL_set_property(m_coletor,"ADD_ITEM","L","Lucas")     
    CALL _ADVPL_set_property(m_coletor,"ADD_ITEM","P","PDT")     
    CALL _ADVPL_set_property(m_coletor,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_coletor,"VALID","pol1351_valid_coletor")
    CALL _ADVPL_set_property(m_coletor,"VARIABLE",mr_cont_manual,"tip_coletor")
    CALL _ADVPL_set_property(m_coletor,"FONT",NULL,11,TRUE,FALSE)
        
END FUNCTION

#----------------------------------------------#
FUNCTION pol1351_cont_manual_grade(l_container)#
#----------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_grade_manual_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_grade_manual_panel,"ALIGN","CENTER")    
    #CALL _ADVPL_set_property(m_grade_manual_panel,"ENABLE",FALSE)
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_grade_manual_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_cont_manual = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_cont_manual,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_cont_manual,"BEFORE_ADD_ROW_EVENT","pol1351_before_add_row")
    CALL _ADVPL_set_property(m_brz_cont_manual,"AFTER_ROW_EVENT","pol1351_apos_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cont_manual)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOCAL")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",10)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cont_manual)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1351_cm_zoom_local")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cont_manual)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_local")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cont_manual)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cont_manual)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1351_cm_zoom_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cont_manual)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cont_manual)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","QUANTIDADE") 
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_contada")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",10,2)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E #######.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cont_manual)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOTE")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_cont_manual)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","  ")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
    
    CALL _ADVPL_set_property(m_brz_cont_manual,"SET_ROWS",ma_cont_manual,1)    
    CALL _ADVPL_set_property(m_brz_cont_manual,"EDITABLE",FALSE)

END FUNCTION

#--------------------------------------#
FUNCTION pol1351_cont_manual_informar()#
#--------------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   CALL pol1351_cont_manual_limpa()
   CALL pol1351_config_manual(TRUE)
   CALL _ADVPL_set_property(m_arq_manual,"LENGTH",18,0)
   CALL _ADVPL_set_property(m_sel_arquivo,"VISIBLE",FALSE)
   CALL _ADVPL_set_property(m_arq_manual,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_user_cont,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1351_cont_manual_limpa()#
#-----------------------------------#

   INITIALIZE mr_cont_manual.* TO NULL
   INITIALIZE ma_cont_manual TO NULL
   LET m_info_manual = FALSE
   CALL _ADVPL_set_property(m_brz_cont_manual,"ITEM_COUNT", 1)
   
END FUNCTION

#----------------------------#
FUNCTION pol1351_ck_nom_arq()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_cont_manual.nom_arquivo IS NULL THEN
      LET m_msg = 'Informe o nome do arquivo'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_cont_manual.num_contagem = mr_cont_manual.nom_arquivo[1]
   
   IF mr_cont_manual.num_contagem MATCHES '[123]' THEN
   ELSE
      LET m_msg = 'O primeiro dígito deve indicar o número da conegem.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1351_config_manual(l_status)#
#---------------------------------------#

   DEFINE l_status     SMALLINT,
          l_aba        SMALLINT
   
   LET l_aba = NOT l_status
   
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",l_aba)
   CALL _ADVPL_set_property(m_param_manual_panel,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_arq_manual,"LENGTH",30,0)
   
END FUNCTION

#----------------------------------#
FUNCTION pol1351_cont_manual_canc()#
#----------------------------------#

   CALL pol1351_cont_manual_limpa()
   CALL pol1351_config_manual(FALSE)
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1351_cont_manual_conf()#
#----------------------------------#
   
   IF NOT pol1351_valid_info() THEN
      RETURN FALSE
   END IF
   
   CALL pol1351_config_manual(FALSE)
   LET m_info_manual = TRUE
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1351_valid_info()#
#----------------------------#

   DEFINE l_arq_gerar      CHAR(30),
          l_arq_txt        CHAR(120)

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = ''
   
   IF mr_cont_manual.cod_usuario IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe o usuário; '
   END IF

   IF mr_cont_manual.nom_arquivo IS NULL THEN
      LET m_msg = m_msg CLIPPED, ' - Informe o arquivo; '
   END IF

   IF mr_cont_manual.num_contagem IS NULL THEN
      LET m_msg = m_msg CLIPPED, ' - Informe a contagem; '
   END IF
   
   IF m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
     
   LET l_arq_gerar = mr_cont_manual.num_contagem CLIPPED, "cont_manu_", 
       mr_cont_manual.nom_arquivo[2,18] CLIPPED
   
   LET p_caminho = mr_invent.nom_caminho,'\\'
   LET m_count = LOG_file_getListCount(p_caminho,l_arq_gerar,FALSE,FALSE,TRUE)
   
   IF m_count > 0 THEN
      LET m_msg = 'O arquivo ', l_arq_gerar CLIPPED, ' já existe.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET mr_cont_manual.nom_arquivo = l_arq_gerar

   LET l_arq_txt = mr_invent.nom_caminho CLIPPED, l_arq_gerar
      
   START REPORT pol1351_gerarq TO l_arq_txt
      
   FINISH REPORT pol1351_gerarq
   
   LET m_msg =  'Arquivo gerado: ', l_arq_txt CLIPPED
   CALL log0030_mensagem(m_msg, 'info')
     
   RETURN TRUE
   
END FUNCTION      

#--------------------------------#
FUNCTION pol1351_abre_cont_manu()#
#--------------------------------#

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03)

   LET p_caminho = mr_invent.nom_caminho,'\\'
   LET m_qtd_arq = LOG_file_getListCount(p_caminho,"?cont_manu*.txt",FALSE,FALSE,TRUE)
   
   IF m_qtd_arq = 0 THEN
      LET m_msg = 'Nenhum arquivo de contagem manual foi encontrado em ', mr_invent.nom_caminho
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   INITIALIZE ma_files TO NULL
   CALL _ADVPL_set_property(m_sel_arquivo,"CLEAR") 
   CALL _ADVPL_set_property(m_sel_arquivo,"ADD_ITEM","0","    ") 

   FOR l_ind = 1 TO m_qtd_arq
       LET t_ind = l_ind
       LET ma_files[l_ind] = LOG_file_getFromList(l_ind)
       CALL _ADVPL_set_property(m_sel_arquivo,"ADD_ITEM",t_ind,ma_files[l_ind])                    
   END FOR
   
   CALL pol1351_set_arq_config(TRUE)
   LET m_info_manual = FALSE
   INITIALIZE mr_cont_manual.* TO NULL
   CALL _ADVPL_set_property(m_sel_arquivo,"GET_FOCUS")
   
   RETURN TRUE
    
END FUNCTION

#-------------------------------------#
FUNCTION pol1351_abre_cont_manu_canc()#
#-------------------------------------#

   INITIALIZE mr_cont_manual.* TO NULL
   CALL pol1351_set_arq_config(FALSE)
   
   RETURN TRUE

END FUNCTION   
   
#----------------------------------------#
FUNCTION pol1351_set_arq_config(l_status)#
#----------------------------------------#
   
   DEFINE l_status, l_aba         SMALLINT
   
   LET l_aba = NOT l_status
   
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",l_aba)
   CALL _ADVPL_set_property(m_param_manual_panel,"ENABLE",l_status)
   CALL _ADVPL_set_property(m_user_cont,"ENABLE",l_aba)
   CALL _ADVPL_set_property(m_num_cont_manual,"ENABLE",FALSE)   
   CALL _ADVPL_set_property(m_arq_manual,"VISIBLE",l_aba)
   CALL _ADVPL_set_property(m_sel_arquivo,"VISIBLE",l_status)
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1351_abre_cont_manu_conf()#
#-------------------------------------#

   DEFINE l_arquivo      CHAR(100),
          l_tamanho      INTEGER
      
   LET l_tamanho = LENGTH(mr_invent.nom_caminho CLIPPED) + 1
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cont_manual.sel_arquivo = '0' THEN
      LET m_msg = 'Selecione um arquivo para abrir.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_sel_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF
   
   LET m_count = mr_cont_manual.sel_arquivo
   LET l_arquivo = ma_files[m_count] CLIPPED
   
   LET p_nom_arquivo = l_arquivo[l_tamanho, LENGTH(l_arquivo)]

   IF pol1351_ja_carregou() THEN
      CALL _ADVPL_set_property(m_sel_arquivo,"GET_FOCUS") 
      RETURN FALSE
   END IF

   IF NOT pol1351_cria_temp() THEN
      RETURN
   END IF
      
   LOAD FROM l_arquivo INSERT INTO invent_carga_547
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("LOAD","arq_banco.txt")
      RETURN FALSE
   END IF
   
   DELETE FROM invent_carga_547 WHERE contagem IS NULL
   
   SELECT COUNT(*) INTO m_count FROM invent_carga_547
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','invent_carga_547')
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_brz_cont_manual,"CLEAR")
   INITIALIZE ma_cont_manual TO NULL   
   
   IF m_count > 0 THEN
      LET m_carregando = TRUE
      LET p_status = LOG_progresspopup_start("Carregando...","pol1351_le_registro","PROCESS")
      LET m_carregando = FALSE
   ELSE
      CALL _ADVPL_set_property(m_brz_cont_manual,"SET_ROWS",ma_cont_manual,1) 
   END IF        
   
   CALL pol1351_set_arq_config(FALSE)
   LET mr_cont_manual.nom_arquivo = p_nom_arquivo
   LET m_info_manual = TRUE

   LET m_msg = 'Operação efetuada com sucesso.'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1351_le_registro()#
#-----------------------------#
   
   DEFINE l_progres     SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)   
   LET m_ind = 1
   
   DECLARE cq_larq CURSOR FOR
    SELECT contagem FROM invent_carga_547
   
   FOREACH cq_larq INTO m_linha
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_larq')
         RETURN FALSE
      END IF
      
      IF m_linha IS NULL OR m_linha = '' THEN
         CONTINUE FOREACH
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      #IF mr_cont_manual.tip_coletor = 'L' THEN
         CALL pol1351_carrega_lucas() 
      #ELSE
      #   CALL pol1351_carrega_pdt() 
      #END IF            
                  
      LET m_ind = m_ind + 1    
      
      IF m_ind > 200 THEN
         LET m_msg = 'Limite de linhas da\n grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
        
   END FOREACH

   LET m_ind = m_ind - 1      
   CALL _ADVPL_set_property(m_brz_cont_manual,"ITEM_COUNT", m_ind)
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1351_carrega_lucas()#
#-------------------------------#

   DEFINE l_local          CHAR(10),
          l_qtd_cont       CHAR(09),
          l_den_item       CHAR(40),
          l_ies_situacao   CHAR(01)

   LET m_cod_local = m_linha[1,10]
   LET m_cod_item = m_linha[11,25]
   LET l_qtd_cont = m_linha[36,44]

   LET ma_cont_manual[m_ind].cod_local = m_cod_local
   LET ma_cont_manual[m_ind].cod_item = m_cod_item
   LET ma_cont_manual[m_ind].qtd_contada = l_qtd_cont   
   LET ma_cont_manual[m_ind].num_lote = NULL   
   
   CALL pol1351_le_descricao()
      
END FUNCTION

#------------------------------#
FUNCTION pol1351_le_descricao()#
#------------------------------#
   
   SELECT den_local
     INTO ma_cont_manual[m_ind].den_local
     FROM local
    WHERE cod_empresa = p_cod_empresa
      AND cod_local = ma_cont_manual[m_ind].cod_local

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','local')
      LET ma_cont_manual[m_ind].den_local = ''
      RETURN 
   END IF

   SELECT den_item
     INTO ma_cont_manual[m_ind].den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = ma_cont_manual[m_ind].cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','local')
      LET ma_cont_manual[m_ind].den_item = ''
      RETURN 
   END IF

END FUNCTION

#---------------------------------#
FUNCTION pol1351_edita_cont_manu()#
#---------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT m_info_manual THEN
      LET m_msg = 'Informe os parâmetros ou reabra um arquivo previmante.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_carregando = FALSE

   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",FALSE)
   CALL _ADVPL_set_property(m_brz_cont_manual,"EDITABLE",TRUE)
   
END FUNCTION

#--------------------------------#
FUNCTION pol1351_before_add_row()#
#--------------------------------#

   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   CALL _ADVPL_set_property(m_brz_cont_manual,"REMOVE_EMPTY_ROWS")
   
   LET m_count = _ADVPL_get_property(m_brz_cont_manual,"ITEM_COUNT")
   
   IF m_count >= 200 THEN
      RETURN FALSE
   END IF
         
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1351_apos_linha()#
#----------------------------#
   
   DEFINE l_lin_atu        INTEGER
   
   IF m_carregando THEN
      RETURN TRUE
   END IF
     
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   LET l_lin_atu = _ADVPL_get_property(m_brz_cont_manual,"ROW_SELECTED")

   IF l_lin_atu < 0 THEN
      RETURN TRUE
   END IF
   
   IF NOT pol1351_valida_linaha(l_lin_atu) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
  
END FUNCTION

#----------------------------------------#
FUNCTION pol1351_valida_linaha(l_lin_atu)#
#----------------------------------------#
   
   DEFINE l_lin_atu        INTEGER
   
   IF ma_cont_manual[l_lin_atu].cod_local IS NULL AND
      ma_cont_manual[l_lin_atu].cod_item IS NULL AND
      ma_cont_manual[l_lin_atu].qtd_contada IS NULL THEN
      RETURN TRUE
   END IF

   LET m_msg = ''
      
   IF ma_cont_manual[l_lin_atu].cod_local IS NULL THEN
      LET m_msg = '- Informe o local.'
   END IF
      
   IF ma_cont_manual[l_lin_atu].cod_item IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Informe o item.'
   END IF

   IF ma_cont_manual[l_lin_atu].qtd_contada IS NULL OR
         ma_cont_manual[l_lin_atu].qtd_contada <= 0 THEN
      LET m_msg = m_msg CLIPPED, '- Informe a quantidade.'
   END IF
   
   IF m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT den_local
     INTO ma_cont_manual[l_lin_atu].den_local
     FROM local
    WHERE cod_empresa = p_cod_empresa
      AND cod_local = ma_cont_manual[l_lin_atu].cod_local

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','local')
      RETURN FALSE
   END IF

   SELECT den_item
     INTO ma_cont_manual[l_lin_atu].den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = ma_cont_manual[l_lin_atu].cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1351_cm_zoom_local()#
#-------------------------------#

    DEFINE l_codigo         LIKE local.cod_local,
           l_descri         LIKE local.den_local,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_local IS NULL THEN
       LET m_zoom_local = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_local,"ZOOM","zoom_local")
    END IF

    LET l_where_clause = " local.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_local,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_local,"RETURN_BY_TABLE_COLUMN","local","cod_local")
    LET l_descri = _ADVPL_get_property(m_zoom_local,"RETURN_BY_TABLE_COLUMN","local","den_local")

    IF l_codigo IS NOT NULL THEN
       LET l_lin_atu = _ADVPL_get_property(m_brz_cont_manual,"ROW_SELECTED")
       LET ma_cont_manual[l_lin_atu].cod_local = l_codigo
       LET ma_cont_manual[l_lin_atu].den_local = l_descri
    END IF        
    
END FUNCTION

#------------------------------#
FUNCTION pol1351_cm_zoom_item()#
#------------------------------#

    DEFINE l_codigo         LIKE item.cod_item,
           l_descri         LIKE item.den_item,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_it IS NULL THEN
       LET m_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_it,"ZOOM","zoom_item")
    END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_it,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")

    IF l_codigo IS NOT NULL THEN
       LET l_lin_atu = _ADVPL_get_property(m_brz_cont_manual,"ROW_SELECTED")
       LET ma_cont_manual[l_lin_atu].cod_item = l_codigo
    END IF        
    
END FUNCTION

#--------------------------------------#
FUNCTION pol1351_edita_cont_manu_conf()#
#--------------------------------------#

   DEFINE l_lin_atu        INTEGER

   LET l_lin_atu = _ADVPL_get_property(m_brz_cont_manual,"ROW_SELECTED")        

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT pol1351_valida_linaha(l_lin_atu) THEN
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_brz_cont_manual,"REMOVE_EMPTY_ROWS")
   
   LET m_count = _ADVPL_get_property(m_brz_cont_manual,"ITEM_COUNT")
   
   IF m_count = 0 THEN
      LET m_msg = 'Informe pelo menos um item.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_brz_cont_manual,"SET_ROWS",ma_cont_manual,1)
      RETURN FALSE
   END IF
   
   IF NOT pol1351_grava_arquivo() THEN
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_brz_cont_manual,"EDITABLE",FALSE)
   
   LET m_msg = 'Operação  efetuada  com sucesso.\n',
               'Use a pasta Carga, para carregar\n',
               'e Processar o arquivo.'
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1351_edita_cont_manu_canc()#
#--------------------------------------#

   CALL _ADVPL_set_property(m_brz_cont_manual,"EDITABLE",FALSE)
   LET m_info_manual = FALSE
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1351_grava_arquivo()#
#-------------------------------#
   
   DEFINE l_arq_txt        CHAR(120)
   
   LET l_arq_txt = mr_invent.nom_caminho CLIPPED, mr_cont_manual.nom_arquivo
      
   START REPORT pol1351_gerarq TO l_arq_txt

   #IF mr_cont_manual.tip_coletor = 'L' THEN
      CALL pol1351_arq_manu_lucas()
   #ELSE
   #   CALL pol1351_arq_manu_pdt()
   #END IF
         
   FINISH REPORT pol1351_gerarq
      
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1351_arq_manu_lucas()#
#--------------------------------#
   
   DEFINE l_ctr       CHAR(10),
          l_quant     CHAR(09),
          l_contada   DECIMAL(10,2)
   
   LET l_ctr = '0         '
   
   FOR m_ind = 1 TO m_count
       
       LET l_contada = ma_cont_manual[m_ind].qtd_contada
       LET l_quant = func002_dec_strzero(l_contada, 9)           
         
       LET m_linha = ma_cont_manual[m_ind].cod_local, ma_cont_manual[m_ind].cod_item, l_ctr, l_quant
       
       LET m_linha = m_linha CLIPPED
       
       OUTPUT TO REPORT pol1351_gerarq()
       
   END FOR

END FUNCTION

#------------------------------#
FUNCTION pol1351_arq_manu_pdt()#
#------------------------------#
   
   DEFINE l_cont      CHAR(03),
          l_quant     CHAR(09),
          l_contada   CHAR(10),
          l_cont_int  INTEGER,
          l_local     CHAR(15),
          l_lote      CHAR(15),
          l_item      CHAR(15)
   
   LET l_cont = mr_cont_manual.num_contagem
   
   FOR m_ind = 1 TO m_count
       
       LET l_local = ma_cont_manual[m_ind].cod_local
       LET l_lote = ma_cont_manual[m_ind].num_lote
       LET l_item = ma_cont_manual[m_ind].cod_item
       
       LET l_contada = ma_cont_manual[m_ind].qtd_contada
       LET l_cont_int = func002_tira_formato(l_contada)
       LET l_quant = func002_strzero(l_cont_int, 9)           
         
       LET m_linha = l_cont, l_lote, l_local, l_item, l_quant
       
       LET m_linha = m_linha CLIPPED
       
       OUTPUT TO REPORT pol1351_gerarq()
       
   END FOR

END FUNCTION
   
#---FIM DAS ROTINAS PARA CONTAGEM MANUAL----#

#---ROTINAS PARA FINALIZAR INVENTÁRIO-------#

#---------------------------------#
FUNCTION pol1351_finalizar_click()#
#---------------------------------#

   IF NOT pol1351_inv_aberto() THEN
      RETURN FALSE
   END IF

   IF NOT pol1351_checa_proces() THEN
      RETURN FALSE
   END IF

   CALL pol1351_desativa_cor()
   CALL _ADVPL_set_property(m_aba_finaliza,"FOREGROUND_COLOR",255,0,0)
   CALL _ADVPL_set_property(m_aba_finaliza,"FONT",NULL,NULL,TRUE,TRUE)

   CALL pol1351_enib_menu_panel()
   CALL _ADVPL_set_property(m_menu_finali_invent,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(m_panel_finali_invent,"VISIBLE",TRUE)
   CALL pol1351_finaliza_limpa()

   RETURN TRUE
       
END FUNCTION

#--------------------------------#
FUNCTION pol1351_finaliza_limpa()#
#--------------------------------#

   LET m_cons_finali = FALSE
   LET m_ies_div_ger = FALSE
   INITIALIZE ma_finaliza TO NULL
   CALL _ADVPL_set_property(m_brz_finali,"SET_ROWS",ma_finaliza,1)

END FUNCTION

#------------------------------------#
FUNCTION pol1351_menu_finali_invent()#
#------------------------------------#
   
    DEFINE l_proces          VARCHAR(10),
           l_enviar          VARCHAR(10),
           l_consist         VARCHAR(10),
           l_desativa        VARCHAR(10)
               
    LET l_consist = _ADVPL_create_component(NULL,"LMENUBUTTON",m_menu_finali_invent)
    CALL _ADVPL_set_property(l_consist,"IMAGE","CONSISTIR_EX")     
    CALL _ADVPL_set_property(l_consist,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_consist,"TOOLTIP","Processa consistência geral dos dados")
    CALL _ADVPL_set_property(l_consist,"EVENT","pol1351_proces_consit")

    LET l_enviar = _ADVPL_create_component(NULL,"LMENUBUTTON",m_menu_finali_invent)     
    CALL _ADVPL_set_property(l_enviar,"IMAGE","ENVIAR_DOC")     
    CALL _ADVPL_set_property(l_enviar,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_enviar,"TOOLTIP","Enviar ao Logix (SUP5470)")
    CALL _ADVPL_set_property(l_enviar,"EVENT","pol1351_enviar_logix")

    LET l_desativa = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_menu_finali_invent)     
    CALL _ADVPL_set_property(l_desativa,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_desativa,"TOOLTIP","Exclui item do inventário")
    CALL _ADVPL_set_property(l_desativa,"EVENT","pol1351_finaliza_exc_item")
             
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_finali_invent)

END FUNCTION

#-------------------------------------#
FUNCTION pol1351_dados_finali_invent()#
#-------------------------------------#

   CALL pol1351_finali_grade(m_panel_finali_invent)
 
END FUNCTION

#-----------------------------------------#
FUNCTION pol1351_finali_grade(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",30)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",231,237,237)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",350,15)  
    CALL _ADVPL_set_property(l_label,"FOREGROUND_COLOR",255,0,0)    
    CALL _ADVPL_set_property(l_label,"TEXT","FINALIZAR INVENTÁEIO")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,11,TRUE,TRUE)  

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
        
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)

    LET m_brz_finali = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_finali,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_finali)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","ITEM")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_finali)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DESCRIÇÃO")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",130)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_finali)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","UND")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_unid")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_finali)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","TP")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_finali)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOCAL")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_local")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_finali)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","LOTE")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_lote")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_finali)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTAGEM 1")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_pri_cont")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_finali)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTAGEM 2")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_seg_cont")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_finali)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","CONTAGEM 3")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_ter_cont")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ######.###")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_finali)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","DIVERGÊNCIA") 
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","divergencia")
    
    CALL _ADVPL_set_property(m_brz_finali,"SET_ROWS",ma_finaliza,1)
    CALL _ADVPL_set_property(m_brz_finali,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_finali,"CAN_REMOVE_ROW",FALSE) 
    
END FUNCTION

#-------------------------------#
FUNCTION pol1351_proces_consit()#
#-------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT pol1351_inv_aberto() THEN
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",FALSE)

   CALL pol1351_finaliza_limpa()
   
   LET p_status = LOG_progresspopup_start("Carregando...","pol1351_consist_geral","PROCESS")
   
   IF p_status THEN
      LET m_cons_finali = TRUE
      CALL log0030_mensagem(m_msg,'info')
   ELSE
      LET m_msg = 'Operação cancelada.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
      
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1351_cont_registro()#
#-------------------------------#

   SELECT COUNT(*) INTO m_count
     FROM itens_invent_547
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent

   IF STATUS <> 0 THEN
      CALL log003_err_sql('FOREACH','info')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
      
#-------------------------------#
FUNCTION pol1351_consist_geral()#
#-------------------------------#
   
   DEFINE l_progres     SMALLINT
   
   IF NOT pol1351_cont_registro() THEN
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   LET m_ind = 1
   
   DECLARE cq_consist_ger CURSOR FOR
    SELECT id_registro, cod_item, cod_local, num_lote, 
           qtd_pri_cont, qtd_seg_cont, qtd_ter_cont
      FROM itens_invent_547
     WHERE cod_empresa = p_cod_empresa
       AND num_invent = mr_invent.num_invent
   
   FOREACH cq_consist_ger INTO
      ma_finaliza[m_ind].id_registro,
      ma_finaliza[m_ind].cod_item,  
      ma_finaliza[m_ind].cod_local,
      ma_finaliza[m_ind].num_lote,
      ma_finaliza[m_ind].qtd_pri_cont, 
      ma_finaliza[m_ind].qtd_seg_cont, 
      ma_finaliza[m_ind].qtd_ter_cont 
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','info')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET g_msg = NULL
      LET m_cod_item  = ma_finaliza[m_ind].cod_item 
      LET m_cod_local = ma_finaliza[m_ind].cod_local
      LET m_num_lote  = ma_finaliza[m_ind].num_lote
      
      SELECT 
          ies_tip_item,
          den_item,
          cod_unid_med,
          ies_ctr_lote,
          ies_situacao
     INTO ma_finaliza[m_ind].ies_tipo, 
          ma_finaliza[m_ind].den_item,
          ma_finaliza[m_ind].cod_unid,
          m_ctr_lote,
          m_ies_situacao
     FROM item WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

      IF STATUS = 100 THEN
         LET g_msg = 'Item não existe;'
      ELSE
         IF STATUS = 0 THEN
            CALL pol1351_checa_deverg()
         ELSE
            CALL log003_err_sql('FOREACH','info')
            RETURN FALSE
         END IF
      END IF
  
      IF g_msg IS NULL THEN
         CONTINUE FOREACH
      END IF
      
      LET ma_finaliza[m_ind].divergencia = g_msg
      LET m_ind = m_ind + 1
      
      IF m_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH

   IF m_ind > 1 THEN
      LET m_ies_div_ger = TRUE
      LET m_ind = m_ind - 1      
      CALL _ADVPL_set_property(m_brz_finali,"ITEM_COUNT", m_ind)
      LET m_msg = 'Foram encontrados ', m_ind USING '<<<<'
      LET m_msg = m_msg CLIPPED, ' itens com divergência.'
   ELSE
      LET m_msg = 'Não há item com divergência.'
      INITIALIZE ma_finaliza TO NULL
      LET m_ies_div_ger = FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1351_checa_deverg()#
#------------------------------#
   
   LET g_msg = ''
   
   IF m_ies_situacao <> 'A' THEN
      LET g_msg = g_msg CLIPPED, 'Item inativo;'
   END IF
   
   IF m_ctr_lote = 'N' THEN
      IF ma_finaliza[m_ind].num_lote IS NOT NULL THEN
         LET g_msg = g_msg CLIPPED, 'Lote p/ intem que não controla;'
      END IF
   ELSE
      IF ma_finaliza[m_ind].num_lote IS NULL THEN
         LET g_msg = g_msg CLIPPED, 'Faltou lote no inventário;'
      END IF
   END IF

   SELECT 1 FROM Local
    WHERE cod_empresa = p_cod_empresa
      AND cod_local = m_cod_local

   IF STATUS <> 0 THEN
      LET g_msg = g_msg CLIPPED, 'Local não existe;'
   END IF

   IF ma_finaliza[m_ind].qtd_ter_cont IS NULL THEN
      IF ma_finaliza[m_ind].qtd_seg_cont IS NULL THEN
         IF mr_invent.tip_invent = 'N' THEN
            LET g_msg = g_msg CLIPPED, 'Só uma contagem;'
         END IF
      ELSE
         IF ma_finaliza[m_ind].qtd_pri_cont IS NULL THEN
            LET g_msg = g_msg CLIPPED, 'Efetuar 1a. contagem;'
         ELSE
            IF ma_finaliza[m_ind].qtd_seg_cont <> ma_finaliza[m_ind].qtd_pri_cont THEN
               LET g_msg = g_msg CLIPPED, 'Contagens diferentes;'
            END IF
         END IF
      END IF
   ELSE
      IF ma_finaliza[m_ind].qtd_pri_cont IS NULL THEN
         LET g_msg = g_msg CLIPPED, 'Efetuar 1a. contagem;'
      END IF
      IF ma_finaliza[m_ind].qtd_seg_cont IS NULL THEN
         LET g_msg = g_msg CLIPPED, 'Efetuar 2a. contagem;'
      END IF
   END IF
      
   CALL pol1351_consist_diverg() RETURNING p_status
   
   IF m_cont_estoq > 0 THEN
      LET g_msg = g_msg CLIPPED, 'Divergência de estoq;'
   END IF
   
   IF m_cont_contag > 0 THEN
      LET g_msg = g_msg CLIPPED, 'Divergência de contagem;'
   END IF
   
   IF m_cont_reserv > 0 THEN
      LET g_msg = g_msg CLIPPED, 'Divergência de reserva;'
   END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol1351_finaliza_exc_item()#
#-----------------------------------#
            
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_lin_atu = _ADVPL_get_property(m_brz_finali,"ROW_SELECTED")
   
   IF m_lin_atu IS NULL OR m_lin_atu <= 0 THEN
      RETURN FALSE
   END IF
   
   IF ma_finaliza[m_lin_atu].id_registro IS NULL THEN
      LET m_msg = 'consulte previamente.'      
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   LET p_status = pol1351_exc_item_invent(ma_loc_lot[m_lin_atu].id_registro)

   IF NOT p_status THEN
      CALL LOG_transaction_rollback()
      LET m_msg = 'Operaçaõ cancelada.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   ELSE
      CALL LOG_transaction_commit()
      CALL _ADVPL_set_property(m_brz_finali,"CAN_REMOVE_ROW",TRUE)
      CALL _ADVPL_set_property(m_brz_finali,"REMOVE_ROW",m_lin_atu)
      CALL _ADVPL_set_property(m_brz_finali,"CAN_REMOVE_ROW",FALSE) 
      LET m_msg = 'Operaçaõ efetuada com sucesso.'
      CALL log0030_mensagem(m_msg,'info')
   END IF         
   
   RETURN p_status

END FUNCTION

#------------------------------#
FUNCTION pol1351_enviar_logix()#
#------------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT m_cons_finali THEN
      LET m_msg = 'Processa a consitência previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF m_ies_div_ger THEN
      LET m_msg = 'Corrija as divergências previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
         
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",FALSE)

   LET p_status = LOG_progresspopup_start("Carregando...","pol1351_proc_envio","PROCESS")
   
   IF p_status THEN
      LET mr_invent.sit_invent = 'FINALIZADO'
      LET m_cons_finali = FALSE
      LET m_msg = 'Inventário finalizado com sucesso.'
      CALL log0030_mensagem(m_msg,'info')
   ELSE
      LET m_msg = 'Operação cancelada.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
      
   CALL _ADVPL_set_property(m_panel_aba,"ENABLE",TRUE)
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1351_proc_envio()#
#----------------------------#

   DEFINE l_progres    SMALLINT
   
   IF NOT pol1351_cont_registro() THEN
      RETURN FALSE
   END IF
   
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
      
   DECLARE cq_proc_env CURSOR FOR
    SELECT *
      FROM itens_invent_547
     WHERE cod_empresa = p_cod_empresa
       AND num_invent = mr_invent.num_invent
   
   FOREACH cq_proc_env INTO mr_itens_invent.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_proc_env')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET m_qtd_contagem = mr_itens_invent.qtd_ter_cont
      
      IF m_qtd_contagem IS NULL THEN
         LET m_qtd_contagem = mr_itens_invent.qtd_seg_cont
      END IF

      IF m_qtd_contagem IS NULL THEN
         LET m_qtd_contagem = mr_itens_invent.qtd_pri_cont
      END IF

      IF NOT pol1351_grava_invent_logix('D') THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   UPDATE invent_547 SET sit_invent = 'FINALIZADO'
    WHERE cod_empresa = p_cod_empresa
      AND num_invent = mr_invent.num_invent

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','invent_547:FINALIZ')
      RETURN FALSE      
   END IF
   
   RETURN TRUE

END FUNCTION
