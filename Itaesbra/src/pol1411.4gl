#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1411                                                 #
# OBJETIVO: PAR�METROS P/ GERA��O DE DADOS PARA OPCENTER            #
# AUTOR...: IVO                                                     #
# DATA....: 04/01/2021                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           m_panel           VARCHAR(10),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_ies_cons        SMALLINT,
       m_excluiu         SMALLINT

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_folder          VARCHAR(10)
       
DEFINE m_count           INTEGER,
       m_msg             VARCHAR(200),
       m_ind             INTEGER,
       m_sql             VARCHAR(200),
       m_where           VARCHAR(800),
       m_mat_where       VARCHAR(800)

       
DEFINE m_brz_rot         VARCHAR(10),
       m_brz_oper        VARCHAR(10),
       m_fold_rot        VARCHAR(10),
       m_zoom_rot        VARCHAR(10),
       m_lupa_rot        VARCHAR(10),
       m_pan_rot         VARCHAR(10),
       m_op_oper         CHAR(01),
       m_car_rot         SMALLINT,
       m_car_oper        SMALLINT

DEFINE mr_oper           RECORD
       cod_empresa       VARCHAR(02), 
       cod_operac        VARCHAR(05), 
       den_operac        VARCHAR(30)       
END RECORD

DEFINE ma_rot           ARRAY[10000] OF RECORD
       cod_item         LIKE item.cod_item,
       den_item_reduz   LIKE item.den_item_reduz,
       seq_operacao     LIKE man_processo_item.seq_operacao,
       cod_operac       LIKE man_processo_item.operacao,
       den_operac       LIKE operacao.den_operac,
       den_cent_trab    LIKE cent_trabalho.den_cent_trab,
       qtd_tempo_setup  LIKE man_processo_item.qtd_tempo_setup,
       tipo             VARCHAR(15), #'Taxa por Hora'
       qtd_pecas_ciclo  LIKE man_processo_item.qtd_pecas_ciclo,
       descricao        VARCHAR(30), #item_2dig_clientes_970.descricao
       horas            VARCHAR(15), #'Horas 00 Mins'
       cod_peca_princ   LIKE peca_geme_man912.cod_peca_princ,
       cod_item_cliente LIKE cliente_item.cod_item_cliente,
       filler           VARCHAR(01)
END RECORD

DEFINE ma_oper          ARRAY[100] OF RECORD
       cod_empresa      VARCHAR(02), 
       cod_operac       LIKE man_processo_item.operacao,
       den_operac       LIKE operacao.den_operac,
       filler           VARCHAR(01)
END RECORD

DEFINE m_den_operac      VARCHAR(30),
       m_zoom_oper       VARCHAR(10),
       m_lupa_oper       VARCHAR(10),
       m_operacao        VARCHAR(10),
       m_rot_oper_const  VARCHAR(10)
              
DEFINE m_car_rec         SMALLINT,
       m_car_uf          SMALLINT,
       m_den_uf          VARCHAR(30),
       m_zoom_uf         VARCHAR(10),
       m_lupa_uf         VARCHAR(10),
       m_brz_uf          VARCHAR(10),
       m_uni_funcio      VARCHAR(10),
       m_den_funcio      VARCHAR(10),
       m_posicao         VARCHAR(10),
       m_setor           VARCHAR(10),
       m_rec_uf_const    VARCHAR(10)

DEFINE m_brz_rec         VARCHAR(10),
       m_fold_rec        VARCHAR(10),
       m_pan_rec         VARCHAR(10),
       m_op_uf           CHAR(01)

DEFINE mr_uf             RECORD
       cod_empresa       VARCHAR(02), 
       cod_uni_funcio    VARCHAR(10),
       den_uni_funcio    VARCHAR(30),
       posicao           VARCHAR(03), 
       setor             VARCHAR(15)       
END RECORD

DEFINE ma_uf            ARRAY[100] OF RECORD
       cod_empresa      VARCHAR(02), 
       cod_uni_funcio   VARCHAR(10),
       den_uni_funcio   VARCHAR(30),
       posicao           VARCHAR(03), 
       setor             VARCHAR(15),
       filler           VARCHAR(01)       
END RECORD

DEFINE m_cod_posicao     VARCHAR(03),
       m_cod_setor       VARCHAR(15),
       m_lin_uf          INTEGER
       
DEFINE ma_rec            ARRAY[5000] OF RECORD
       cod_equip         LIKE equipamento.cod_equip,
       den_cent_trab     LIKE cent_trabalho.den_cent_trab,
       finito            VARCHAR(10), #fixo
       posicao           VARCHAR(03),
       eficiencia        DECIMAL(2,0), #fixo 85
       setor             VARCHAR(15),
       filler            VARCHAR(01)
END RECORD

DEFINE m_brz_grup        VARCHAR(10),
       m_fold_grup       VARCHAR(10),
       m_pan_grup        VARCHAR(10),
       m_op_grup         CHAR(01)

DEFINE ma_grup           ARRAY[1000] OF RECORD
       den_cent_trab     LIKE cent_trabalho.den_cent_trab,
       filler            VARCHAR(01)
END RECORD

DEFINE m_brz_rgrup       VARCHAR(10),
       m_fold_rgrup      VARCHAR(10),
       m_pan_rgrup       VARCHAR(10),
       m_op_rgrup        CHAR(01)

DEFINE ma_rgrup          ARRAY[1000] OF RECORD
       den_cent_trab     LIKE cent_trabalho.den_cent_trab,
       cod_equip         LIKE equipamento.cod_equip,
       setor             VARCHAR(15),
       filler            VARCHAR(01)
END RECORD

DEFINE mr_ordem          RECORD
       cod_empresa       VARCHAR(02), 
       ies_planejada     VARCHAR(01), 
       ies_firme         VARCHAR(01), 
       ies_aberta        VARCHAR(01), 
       ies_liberada      VARCHAR(01), 
       ies_fechada       VARCHAR(01), 
       ies_cancelada     VARCHAR(01), 
       qtd_dias_entr     DECIMAL(3,0)      
END RECORD

DEFINE m_brz_ordem       VARCHAR(10),
       m_fold_ordem      VARCHAR(10),
       m_pan_ordem       VARCHAR(10),
       m_op_ordem        VARCHAR(01),
       m_car_ordem       VARCHAR(01),
       m_planejada       VARCHAR(10),
       m_firme           VARCHAR(10),
       m_aberta          VARCHAR(10),
       m_liberada        VARCHAR(10),
       m_fechada         VARCHAR(10),
       m_cancelada       VARCHAR(10),
       m_dias_entr       VARCHAR(10),
       m_ordem_const     VARCHAR(10),
       m_ies_ordem       SMALLINT,
       m_ies_situa       VARCHAR(30),
       m_mat_situa       VARCHAR(20),
       m_dat_entrega     DATE

DEFINE ma_ordem          ARRAY[5000] OF RECORD
       dat_entrega       LIKE ordens.dat_entrega,
       num_ordem         LIKE ordens.num_ordem,
       cod_item          LIKE ordens.cod_item,
       ies_situa         LIKE ordens.ies_situa,
       qtd_planej        LIKE ordens.qtd_planej,       
       den_situa         VARCHAR(20),
       setor             VARCHAR(10),
       filler            VARCHAR(01)
END RECORD

DEFINE mr_mat            RECORD
       cod_empresa       VARCHAR(02), 
       ies_produzido     VARCHAR(01), 
       ies_final         VARCHAR(01)
END RECORD

DEFINE m_brz_mat         VARCHAR(10),
       m_fold_mat        VARCHAR(10),
       m_pan_mat         VARCHAR(10),
       m_op_mat          VARCHAR(01),
       m_car_mat         VARCHAR(01),
       m_produzido       VARCHAR(10),
       m_final           VARCHAR(10),
       m_mat_const       VARCHAR(10),
       m_ies_mat         SMALLINT

DEFINE ma_mat            ARRAY[10000] OF RECORD
       item_pai          LIKE item.cod_item,
       item_compon       LIKE item.cod_item,
       qtd_necessaria    LIKE estrut_grade.qtd_necessaria,
       multil            VARCHAR(03),
       ignorar           VARCHAR(03),
       filler            VARCHAR(01)
END RECORD

DEFINE m_brz_estoq       VARCHAR(10),
       m_fold_estoq      VARCHAR(10),
       m_pan_estoq       VARCHAR(10),
       m_op_estoq        CHAR(01)

DEFINE ma_estoq          ARRAY[10000] OF RECORD
       cod_item          LIKE item.cod_item,
       den_item_reduz    LIKE item.den_item_reduz,
       qtd_estoq         DECIMAL(10,3),
       ordem             VARCHAR(15),
       tipo              VARCHAR(07),
       fornecimento      DATE,
       filler            VARCHAR(01)
END RECORD
                   
#-----------------#
FUNCTION pol1411()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1411-12.00.00  "
      
   LET m_car_rot = TRUE
   LET m_car_oper = TRUE
   LET m_car_rec = TRUE
   LET m_car_uf = TRUE
   INITIALIZE mr_oper.* TO NULL
   INITIALIZE mr_uf.* TO NULL
   
   CALL pol1411_menu()

END FUNCTION

#----------------------#
FUNCTION pol1411_menu()#
#----------------------#

    DEFINE l_menubar       VARCHAR(10),
           l_fechar        VARCHAR(10),
           l_panel         VARCHAR(10),
           l_fpanel        VARCHAR(10),
           l_label         VARCHAR(10),
           l_titulo        CHAR(80)

    LET l_titulo = 'PAR�METROS P/ GERA��O DE DAODS PARA OPCENTER - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET m_folder = _ADVPL_create_component(NULL,"LFOLDER",m_dialog)
    CALL _ADVPL_set_property(m_folder,"ALIGN","CENTER")
    
    # FOLDER roteiro 

    LET m_fold_rot = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_rot,"TITLE","Produto/roteiro")
    CALL pol1411_rot(m_fold_rot)

    # FOLDER recursos

    LET m_fold_rec = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_rec,"TITLE","Recursos")
    CALL pol1411_rec(m_fold_rec)

    # FOLDER Grupo (centro de trabalho)

    LET m_fold_grup = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_grup,"TITLE","Grupo")
    CALL pol1411_grup(m_fold_grup)

    # FOLDER Grupo de recursos

    LET m_fold_rgrup = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_rgrup,"TITLE","Recuros por grupo")
    CALL pol1411_rgrup(m_fold_rgrup)

    # FOLDER ordens de produ��o

    LET m_fold_ordem = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_ordem,"TITLE","Ordens produ��o")
    CALL pol1411_ordem(m_fold_ordem)

    # FOLDER materiais

    LET m_fold_mat = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_mat,"TITLE","Materiais")
    CALL pol1411_mat(m_fold_mat)

    # FOLDER estoque

    LET m_fold_estoq = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder)
    CALL _ADVPL_set_property(m_fold_estoq,"TITLE","Estoque")
    CALL pol1411_estoq(m_fold_estoq)

    CALL _ADVPL_set_property(m_folder,"FOLDER_SELECTED",1)
    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
   
#------------------------#
FUNCTION pol1411_fechar()#
#------------------------#

   RETURN TRUE
   
END FUNCTION

#-----------------------------------------#
FUNCTION pol1411_desativa_folder(l_folder)#
#-----------------------------------------#

   DEFINE l_folder             CHAR(01)
             
   CASE l_folder
        WHEN '1' 
           CALL _ADVPL_set_property(m_fold_rec,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_grup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_rgrup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_ordem,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_mat,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_estoq,"ENABLE",FALSE)
        WHEN '2' 
           CALL _ADVPL_set_property(m_fold_rot,"ENABLE",FALSE)      
           CALL _ADVPL_set_property(m_fold_grup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_rgrup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_ordem,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_mat,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_estoq,"ENABLE",FALSE)
        WHEN '3' 
           CALL _ADVPL_set_property(m_fold_rot,"ENABLE",FALSE)      
           CALL _ADVPL_set_property(m_fold_rec,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_rgrup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_ordem,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_mat,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_estoq,"ENABLE",FALSE)
        WHEN '4' 
           CALL _ADVPL_set_property(m_fold_rot,"ENABLE",FALSE)      
           CALL _ADVPL_set_property(m_fold_rec,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_grup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_ordem,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_mat,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_estoq,"ENABLE",FALSE)
        WHEN '5' 
           CALL _ADVPL_set_property(m_fold_rot,"ENABLE",FALSE)      
           CALL _ADVPL_set_property(m_fold_rec,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_grup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_rgrup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_mat,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_estoq,"ENABLE",FALSE)
        WHEN '6' 
           CALL _ADVPL_set_property(m_fold_rot,"ENABLE",FALSE)      
           CALL _ADVPL_set_property(m_fold_rec,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_grup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_rgrup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_ordem,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_estoq,"ENABLE",FALSE)
        WHEN '7' 
           CALL _ADVPL_set_property(m_fold_rot,"ENABLE",FALSE)      
           CALL _ADVPL_set_property(m_fold_rec,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_grup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_rgrup,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_ordem,"ENABLE",FALSE)
           CALL _ADVPL_set_property(m_fold_mat,"ENABLE",FALSE)
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol1411_ativa_folder()#
#------------------------------#

   CALL _ADVPL_set_property(m_fold_rot,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_rec,"ENABLE",TRUE) 
   CALL _ADVPL_set_property(m_fold_grup,"ENABLE",TRUE) 
   CALL _ADVPL_set_property(m_fold_rgrup,"ENABLE",TRUE) 
   CALL _ADVPL_set_property(m_fold_ordem,"ENABLE",TRUE) 
   CALL _ADVPL_set_property(m_fold_mat,"ENABLE",TRUE)
   CALL _ADVPL_set_property(m_fold_estoq,"ENABLE",TRUE)

END FUNCTION


#---Rotinas cadastro de roteiros ----#

#-----------------------------#
FUNCTION pol1411_rot(l_fpanel)#
#-----------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10),
           l_exportar  VARCHAR(10),
           l_visuali   VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1411_rot_oper_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1411_rot_oper_ins")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1411_rot_oper_ins_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1411_rot_oper_ins_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1411_rot_oper_delete")

    LET l_exportar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_exportar,"IMAGE","MAN_EXPORT")     
    CALL _ADVPL_set_property(l_exportar,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_exportar,"TOOLTIP","Exportar dados para OPCENTER")
    CALL _ADVPL_set_property(l_exportar,"EVENT","pol1411_rot_exportar")

    LET l_visuali = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_visuali,"IMAGE","VISUALIZAR_SUP")     
    CALL _ADVPL_set_property(l_visuali,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_visuali,"TOOLTIP","Visualizar exporta��o de dados")
    CALL _ADVPL_set_property(l_visuali,"EVENT","pol1411_rot_vusualizar")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1411_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1411_rot_oper_campo(l_panel)
    CALL pol1411_rot_grade(l_panel)
    
END FUNCTION

#-------------------------------------------#
FUNCTION pol1411_rot_oper_campo(l_container)#
#-------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_pan_cab         VARCHAR(10),
           l_pan_oper        VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_pan_cab = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_pan_cab,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_pan_cab,"HEIGHT",160)

    LET m_pan_rot = _ADVPL_create_component(NULL,"LPANEL",l_pan_cab)
    CALL _ADVPL_set_property(m_pan_rot,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_rot,"HEIGHT",40)
    CALL _ADVPL_set_property(m_pan_rot,"BACKGROUND_COLOR",225,232,232) 
    CALL _ADVPL_set_property(m_pan_rot,"ENABLE",FALSE)    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_rot)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_rot)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",60,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_oper,"cod_empresa")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_rot)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",140,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Opera��o(n�o exportar):")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_operacao = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_rot)     
    CALL _ADVPL_set_property(m_operacao,"POSITION",290,10) 
    CALL _ADVPL_set_property(m_operacao,"LENGTH",5)    
    CALL _ADVPL_set_property(m_operacao,"PICTURE","@E!")  
    CALL _ADVPL_set_property(m_operacao,"VARIABLE",mr_oper,"cod_operac")
    CALL _ADVPL_set_property(m_operacao,"VALID","pol1411_rot_oper_valid")

    LET m_lupa_oper = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_rot)
    CALL _ADVPL_set_property(m_lupa_oper,"POSITION",250,10)     
    CALL _ADVPL_set_property(m_lupa_oper,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_oper,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_oper,"CLICK_EVENT","pol1411_zoom_operacao")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_rot)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",290,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",30)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_oper,"den_operac")

    LET l_pan_oper = _ADVPL_create_component(NULL,"LPANEL",l_pan_cab)
    CALL _ADVPL_set_property(l_pan_oper,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pan_oper)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_oper = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_oper,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_oper,"BEFORE_ROW_EVENT","pol1411_rot_oper_before")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Opera��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_oper)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_oper,"SET_ROWS",ma_oper,1)
    CALL _ADVPL_set_property(m_brz_oper,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_oper,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_oper,"CAN_REMOVE_ROW",FALSE)
             
END FUNCTION

#--------------------------------------#
FUNCTION pol1411_rot_grade(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_rot = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_rot,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item_reduz")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Seq operac")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","seq_operacao")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Opera��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Grupo")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_cent_trab")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Setup")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_tempo_setup")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tipo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pe�a/ciclo")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_pecas_ciclo")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","descricao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Horas")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","horas")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pe�a gemea(Princ)")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_peca_princ")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item_cliente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rot)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_rot,"SET_ROWS",ma_rot,1)
    CALL _ADVPL_set_property(m_brz_rot,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_rot,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_rot,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#---------------------------------#
FUNCTION pol1411_rot_oper_before()#
#---------------------------------#
      
   DEFINE l_linha          INTEGER
   
   LET m_op_oper = 'R'
   
   IF m_car_oper THEN
      RETURN TRUE
   END IF
      
   LET l_linha = _ADVPL_get_property(m_brz_oper,"ROW_SELECTED")

   IF l_linha IS NULL OR l_linha = 0 THEN
      RETURN TRUE
   END IF
   
   CALL pol1411_rot_oper_set_item(l_linha)         
   CALL pol1411_rot_ativa(TRUE)
   CALL _ADVPL_set_property(m_operacao,"GET_FOCUS")
   CALL pol1411_rot_ativa(FALSE)

   RETURN TRUE

END FUNCTION

#------------------------------------------#
FUNCTION pol1411_rot_oper_set_item(l_linha)#
#------------------------------------------#
   
   DEFINE l_linha     INTEGER
   
   LET mr_oper.cod_empresa = ma_oper[l_linha].cod_empresa
   LET mr_oper.cod_operac = ma_oper[l_linha].cod_operac
   LET mr_oper.den_operac = ma_oper[l_linha].den_operac

END FUNCTION

#-----------------------------------#
FUNCTION pol1411_rot_ativa(l_status)#
#-----------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_rot,"ENABLE",l_status)

   IF m_op_oper = 'I' THEN
      CALL _ADVPL_set_property(m_operacao,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_operacao,"ENABLE",FALSE)
   END IF
            
END FUNCTION


#--------------------------------#
FUNCTION pol1411_rot_oper_valid()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF m_op_oper = 'I' THEN
   ELSE
      RETURN TRUE
   END IF
      
   IF mr_oper.cod_operac IS NULL THEN
      LET m_msg = 'Informe o c�digo da opera��o'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT 1
     FROM oper_rot_970
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = mr_oper.cod_operac

   IF STATUS = 0 THEN
      LET m_msg = 'Opera��o j� cadastrada no pol1411'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1411_le_operacao(mr_oper.cod_operac) THEN
      RETURN FALSE
   END IF
   
   LET mr_oper.den_operac = m_den_operac
      
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1411_zoom_operacao()#
#-------------------------------#

    DEFINE l_codigo         LIKE operacao.cod_operac,
           l_descri         LIKE operacao.den_operac,
           l_where_clause   CHAR(300)
    
    IF m_zoom_oper IS NULL THEN
       LET m_zoom_oper = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_oper,"ZOOM","zoom_operacao")
    END IF

    LET l_where_clause = " operacao.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_oper,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_oper,"RETURN_BY_TABLE_COLUMN","operacao","cod_operac")
    LET l_descri = _ADVPL_get_property(m_zoom_oper,"RETURN_BY_TABLE_COLUMN","operacao","den_operac")

    IF l_codigo IS NOT NULL THEN
       LET mr_oper.cod_operac = l_codigo
       LET mr_oper.den_operac = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_operacao,"GET_FOCUS")
    
END FUNCTION

#----------------------------------#
FUNCTION pol1411_le_operacao(l_cod)#
#----------------------------------#
   
   DEFINE l_cod          VARCHAR(05)
   
   SELECT den_operac 
     INTO m_den_operac
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','Logix.operacao')
      RETURN FALSE
   END IF         
   
   RETURN TRUE      

END FUNCTION      
         
#------------------------------#
FUNCTION pol1411_rot_oper_ins()#
#------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   LET m_op_oper = 'I'
   LET m_car_oper = TRUE
   INITIALIZE mr_oper.* TO NULL
   LET mr_oper.cod_empresa = p_cod_empresa
      
   CALL pol1411_desativa_folder("1")
   CALL pol1411_rot_ativa(TRUE)
   CALL _ADVPL_set_property(m_operacao,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1411_rot_oper_ins_canc()#
#-----------------------------------#

   CALL pol1411_rot_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_ativa_folder()
   CALL _ADVPL_set_property(m_brz_oper,"CLEAR")
   INITIALIZE mr_oper.*, ma_oper TO NULL
   LET m_car_oper = FALSE
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1411_rot_oper_ins_conf()#
#-----------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL
   
   IF NOT pol1411_rot_oper_inserir() THEN
      RETURN FALSE
   END IF
   
   CALL pol1411_rot_oper_prepare()
   CALL pol1411_rot_ativa(FALSE)
   CALL pol1411_ativa_folder()
   LET m_car_oper = FALSE
   
   RETURN TRUE

END FUNCTION        
   

#----------------------------------#
FUNCTION pol1411_rot_oper_inserir()#
#----------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO oper_rot_970
    VALUES(mr_oper.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','oper_rot_970')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1411_rot_oper_prepare()#
#----------------------------------#

   DEFINE l_sql_stmt CHAR(2000)
                        
   LET l_sql_stmt =
       " SELECT * ",
    "  FROM oper_rot_970 ",
    " WHERE cod_empresa =  '",p_cod_empresa,"' "

   CALL pol1411_rot_oper_exibe(l_sql_stmt)

END FUNCTION

#------------------------------------------#
FUNCTION pol1411_rot_oper_exibe(l_sql_stmt)#
#------------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   CALL _ADVPL_set_property(m_brz_oper,"CLEAR")
   LET m_car_oper = TRUE
   INITIALIZE ma_oper TO NULL
   LET l_ind = 1
   
    PREPARE var_oper FROM l_sql_stmt

    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","oper_rot_970:PREPARE")
       RETURN FALSE
    END IF

   DECLARE cq_oper CURSOR FOR var_oper
   
   FOREACH cq_oper INTO ma_oper[l_ind].*
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_oper:01')
         EXIT FOREACH
      END IF

      LET l_ind = l_ind + 1
      
      IF l_ind > 100 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_oper,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'N�o h� registros para os par�metros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_oper = FALSE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1411_rot_oper_find()#
#-------------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    LET m_op_oper = 'P'
    
    IF m_rot_oper_const IS NULL THEN
       LET m_rot_oper_const = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_rot_oper_const,"CONSTRUCT_NAME","pol1411_operacao")
       CALL _ADVPL_set_property(m_rot_oper_const,"ADD_VIRTUAL_TABLE","oper_rot_970","parametro")
       CALL _ADVPL_set_property(m_rot_oper_const,"ADD_VIRTUAL_COLUMN","oper_rot_970","cod_operac","Operacao",1 {CHAR},5,0)
       CALL _ADVPL_set_property(m_rot_oper_const,"ADD_VIRTUAL_COLUMN","oper_rot_970","den_operac","Descri��o",1 {CHAR},30,0)
    END IF

    LET l_status = _ADVPL_get_property(m_rot_oper_const,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_rot_oper_const,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_rot_oper_const,"ORDER_BY")
       CALL pol1411_rot_oper_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-------------------------------------------------#
FUNCTION pol1411_rot_oper_cursor(l_where, l_order)#
#-------------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " cod_operac "
    END IF

    
    LET l_sql_stmt = 
       " SELECT * ",
       " FROM oper_rot_970 ",
        " WHERE ",l_where CLIPPED,
        " AND cod_empresa =  '",p_cod_empresa,"' ",
        " ORDER BY ",l_order
   
   CALL pol1411_rot_oper_exibe(l_sql_stmt)
   CALL pol1411_rot_oper_set_item(1)
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1411_rot_oper_prende()#
#----------------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_rot_oper_prende CURSOR FOR
    SELECT 1
      FROM oper_rot_970
     WHERE cod_empresa = mr_oper.cod_empresa
       AND cod_operac = mr_oper.cod_operac
     FOR UPDATE 
    
    OPEN cq_rot_oper_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_rot_oper_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_rot_oper_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_rot_oper_prende")
      CALL LOG_transaction_rollback()
      CLOSE cq_rot_oper_prende
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------#
FUNCTION pol1411_rot_oper_delete()#
#---------------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_oper.cod_operac IS NULL THEN
      LET m_msg = 'Selecione previamente um item na grade'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1411_rot_oper_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM oper_rot_970
     WHERE cod_empresa = mr_oper.cod_empresa
       AND cod_operac = mr_oper.cod_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','oper_rot_970:rod')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_oper.* TO NULL
   ELSE
      CALL LOG_transaction_rollback()     
   END IF
   
   CLOSE cq_rot_oper_prende
   CALL pol1411_rot_oper_prepare()
   
   RETURN l_ret
        
END FUNCTION

#--------------------------------#
FUNCTION pol1411_rot_vusualizar()#
#--------------------------------#
   
   DEFINE l_ind       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   SELECT count(*) INTO m_count
     FROM man_processo_item
          INNER JOIN item
                 ON  item.cod_empresa=man_processo_item.empresa
                AND item.cod_item=man_processo_item.item
                AND item.ies_situacao='A'
          INNER JOIN operacao
                  ON operacao.cod_empresa=man_processo_item.empresa
                 AND operacao.cod_operac=man_processo_item.operacao
          LEFT JOIN cent_trabalho
                 ON cent_trabalho.cod_empresa=man_processo_item.empresa
                AND cent_trabalho.cod_cent_trab=man_processo_item.centro_trabalho
    WHERE man_processo_item.empresa = p_cod_empresa
      AND man_processo_item.validade_final IS NULL
      AND man_processo_item.operacao NOT IN 
          (SELECT cod_operac FROM oper_rot_970 WHERE cod_empresa = p_cod_empresa)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','man_processo_item:contando registros')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1411_rot_exibe","PROCESS")  

   RETURN p_status

END FUNCTION   

#---------------------------#
FUNCTION pol1411_rot_exibe()#
#---------------------------#
   
   DEFINE l_codigo      VARCHAR(02),
          l_desc        VARCHAR(30),
          l_ind         INTEGER,
          l_progres     SMALLINT
   
   CALL _ADVPL_set_property(m_brz_rot,"CLEAR")
   
   LET m_car_rot = TRUE
   INITIALIZE ma_rot TO NULL
   LET l_ind = 1

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   DECLARE cq_le_rot CURSOR FOR
   SELECT man_processo_item.item,           
          item.den_item_reduz,       
          man_processo_item.seq_operacao,       
          man_processo_item.operacao,       
          operacao.den_operac,              
          cent_trabalho.den_cent_trab,      
          man_processo_item.qtd_tempo_setup,
          man_processo_item.qtd_pecas_ciclo          
     FROM man_processo_item
          INNER JOIN item
                 ON  item.cod_empresa=man_processo_item.empresa
                AND item.cod_item=man_processo_item.item
                AND item.ies_situacao='A'
          INNER JOIN operacao
                  ON operacao.cod_empresa=man_processo_item.empresa
                 AND operacao.cod_operac=man_processo_item.operacao
          LEFT JOIN cent_trabalho
                 ON cent_trabalho.cod_empresa=man_processo_item.empresa
                AND cent_trabalho.cod_cent_trab=man_processo_item.centro_trabalho
    WHERE man_processo_item.empresa = p_cod_empresa
      AND man_processo_item.validade_final IS NULL
      AND man_processo_item.operacao NOT IN 
          (SELECT cod_operac FROM oper_rot_970 WHERE cod_empresa = p_cod_empresa)
   
   FOREACH cq_le_rot INTO
      ma_rot[l_ind].cod_item,       
      ma_rot[l_ind].den_item_reduz, 
      ma_rot[l_ind].seq_operacao,
      ma_rot[l_ind].cod_operac,     
      ma_rot[l_ind].den_operac,     
      ma_rot[l_ind].den_cent_trab,  
      ma_rot[l_ind].qtd_tempo_setup,
      ma_rot[l_ind].qtd_pecas_ciclo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','man_processo_item:lendo registros')
         RETURN FALSE
      END IF

      LET ma_rot[l_ind].tipo = 'Taxa por Hora'
      LET ma_rot[l_ind].horas = 'Horas 00 Mins'
      
      LET l_codigo = ma_rot[l_ind].cod_item[1,2]
      LET ma_rot[l_ind].descricao = NULL
      
      DECLARE cq_desc CURSOR FOR
      SELECT descricao 
        FROM item_2dig_clientes_970
       WHERE codigo = l_codigo
      FOREACH cq_desc INTO l_desc

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','item_2dig_clientes_970:lendo descricao')
            RETURN FALSE
         END IF
         
         LET ma_rot[l_ind].descricao = l_desc
         EXIT FOREACH
      
      END FOREACH
      
      LET ma_rot[l_ind].cod_item_cliente = NULL
      
      DECLARE cq_it_cli CURSOR FOR
      SELECT cod_item_cliente 
        FROM cliente_item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_rot[l_ind].cod_item
      FOREACH cq_it_cli INTO l_desc

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','cliente_item')
            RETURN FALSE
         END IF
         
         LET ma_rot[l_ind].cod_item_cliente = l_desc
         EXIT FOREACH
      
      END FOREACH
      
      LET ma_rot[l_ind].cod_peca_princ = NULL
      
      DECLARE cq_gemea CURSOR FOR
      SELECT cod_peca_princ  
        FROM peca_geme_man912
       WHERE cod_empresa = p_cod_empresa
         AND cod_peca_gemea = ma_rot[l_ind].cod_item
      FOREACH cq_gemea INTO l_desc

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','peca_geme_man912')
            RETURN FALSE
         END IF
         
         LET ma_rot[l_ind].cod_peca_princ = l_desc
         EXIT FOREACH
      
      END FOREACH
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 10000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.\n',
                     'Ser�o exibidos somete 10000 registros.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_ind = l_ind - 1
   CALL _ADVPL_set_property(m_brz_rot,"ITEM_COUNT", l_ind)
   
   RETURN TRUE

END FUNCTION
   
#------------------------------#
FUNCTION pol1411_rot_exportar()#
#------------------------------#
   
   DEFINE l_arquivo    VARCHAR(120)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   SELECT count(*) INTO m_count
     FROM man_processo_item
          INNER JOIN item
                 ON  item.cod_empresa=man_processo_item.empresa
                AND item.cod_item=man_processo_item.item
                AND item.ies_situacao='A'
          INNER JOIN operacao
                  ON operacao.cod_empresa=man_processo_item.empresa
                 AND operacao.cod_operac=man_processo_item.operacao
          LEFT JOIN cent_trabalho
                 ON cent_trabalho.cod_empresa=man_processo_item.empresa
                AND cent_trabalho.cod_cent_trab=man_processo_item.centro_trabalho
    WHERE man_processo_item.empresa = p_cod_empresa
      AND man_processo_item.validade_final IS NULL
      AND man_processo_item.operacao NOT IN 
          (SELECT cod_operac FROM oper_rot_970 WHERE cod_empresa = p_cod_empresa)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','man_processo_item:contando registros')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   CALL pol1412_export_prod_rot(m_count) RETURNING p_status, l_arquivo
   
   IF p_status THEN
      LET m_msg = 'Arquivo gerado no caminho\n\n',l_arquivo CLIPPED
   ELSE
      LET m_msg = 'Consulte a tabela de mensagem export_dados_opcenter_970'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')         
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   RETURN p_status

END FUNCTION   

#---Rotinas para cadastro de recursos ----#

#-----------------------------#
FUNCTION pol1411_rec(l_fpanel)#
#-----------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_delete    VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10),
           l_update    VARCHAR(10),
           l_exportar  VARCHAR(10),
           l_visuali   VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1411_rec_uf_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1411_rec_uf_ins")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1411_rec_uf_ins_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1411_rec_uf_ins_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1411_rec_uf_upd")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1411_rec_uf_upd_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1411_rec_uf_upd_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1411_rec_uf_delete")

    LET l_exportar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_exportar,"IMAGE","MAN_EXPORT")     
    CALL _ADVPL_set_property(l_exportar,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_exportar,"TOOLTIP","Exportar dados para OPCENTER")
    CALL _ADVPL_set_property(l_exportar,"EVENT","pol1411_rec_exportar")

    LET l_visuali = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_visuali,"IMAGE","VISUALIZAR_SUP")     
    CALL _ADVPL_set_property(l_visuali,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_visuali,"TOOLTIP","Visualizar exporta��o de dados")
    CALL _ADVPL_set_property(l_visuali,"EVENT","pol1411_rec_vusualizar")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1411_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1411_rec_uf_campo(l_panel)
    CALL pol1411_rec_grade(l_panel)
    
END FUNCTION

#-----------------------------------------#
FUNCTION pol1411_rec_uf_campo(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_pan_cab         VARCHAR(10),
           l_pan_uf          VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_pan_cab = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_pan_cab,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_pan_cab,"HEIGHT",160)

    LET m_pan_rec = _ADVPL_create_component(NULL,"LPANEL",l_pan_cab)
    CALL _ADVPL_set_property(m_pan_rec,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_rec,"HEIGHT",40)
    CALL _ADVPL_set_property(m_pan_rec,"BACKGROUND_COLOR",225,232,232) 
    CALL _ADVPL_set_property(m_pan_rec,"ENABLE",FALSE)    

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_rec)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_rec)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",60,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_uf,"cod_empresa")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_rec)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",130,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Uni funcio:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_uni_funcio = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_rec)     
    CALL _ADVPL_set_property(m_uni_funcio,"POSITION",200,10) 
    CALL _ADVPL_set_property(m_uni_funcio,"LENGTH",10)    
    CALL _ADVPL_set_property(m_uni_funcio,"PICTURE","@E!")  
    CALL _ADVPL_set_property(m_uni_funcio,"VARIABLE",mr_uf,"cod_uni_funcio")
    CALL _ADVPL_set_property(m_uni_funcio,"VALID","pol1411_rec_uf_valid")

    LET m_lupa_oper = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_pan_rec)
    CALL _ADVPL_set_property(m_lupa_oper,"POSITION",300,10)     
    CALL _ADVPL_set_property(m_lupa_oper,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_oper,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_oper,"CLICK_EVENT","pol1411_zoom_uf")

    LET m_den_funcio = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_rec)     
    CALL _ADVPL_set_property(m_den_funcio,"POSITION",350,10) 
    CALL _ADVPL_set_property(m_den_funcio,"LENGTH",30)    
    CALL _ADVPL_set_property(m_den_funcio,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_den_funcio,"VARIABLE",mr_uf,"den_uni_funcio")
    CALL _ADVPL_set_property(m_den_funcio,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_rec)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",650,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Posi��o:")    
    
    LET m_posicao = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_rec)     
    CALL _ADVPL_set_property(m_posicao,"POSITION",700,10) 
    CALL _ADVPL_set_property(m_posicao,"LENGTH",3)    
    CALL _ADVPL_set_property(m_posicao,"PICTURE","@E 999")  
    CALL _ADVPL_set_property(m_posicao,"VARIABLE",mr_uf,"posicao")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_rec)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",750,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Setor:")    

    LET m_setor = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_rec)     
    CALL _ADVPL_set_property(m_setor,"POSITION",800,10) 
    CALL _ADVPL_set_property(m_setor,"LENGTH",15)    
    CALL _ADVPL_set_property(m_setor,"PICTURE","@E!")  
    CALL _ADVPL_set_property(m_setor,"VARIABLE",mr_uf,"setor")

    LET l_pan_uf = _ADVPL_create_component(NULL,"LPANEL",l_pan_cab)
    CALL _ADVPL_set_property(l_pan_uf,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pan_uf)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_uf = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_uf,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_uf,"BEFORE_ROW_EVENT","pol1411_rec_uf_before")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_uf)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_uf)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Uni funcional")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_uni_funcio")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_uf)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_uni_funcio")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_uf)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Posi��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","posicao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_uf)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Setor")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","setor")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_uf)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_uf,"SET_ROWS",ma_uf,1)
    CALL _ADVPL_set_property(m_brz_uf,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_uf,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_uf,"CAN_REMOVE_ROW",FALSE)
             
END FUNCTION

#--------------------------------------#
FUNCTION pol1411_rec_grade(l_container)#
#--------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_rec = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_rec,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rec)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Recurso")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_equip")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rec)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_cent_trab")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rec)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Finito/infinito")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","finito")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rec)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Posi��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","posicao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rec)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Efici�ncia")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","eficiencia")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rec)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Setor")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","setor")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rec)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_rec,"SET_ROWS",ma_rec,1)
    CALL _ADVPL_set_property(m_brz_rec,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_rec,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_rec,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#--------------------------------#
FUNCTION pol1411_rec_uf_valid()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF m_op_uf = 'I' THEN
   ELSE
      RETURN TRUE
   END IF
      
   IF mr_uf.cod_uni_funcio IS NULL THEN
      LET m_msg = 'Informe a unidade funcional'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT 1
     FROM uni_funcio_970
    WHERE cod_empresa = p_cod_empresa
      AND cod_uni_funcio = mr_uf.cod_uni_funcio

   IF STATUS = 0 THEN
      LET m_msg = 'Unidade funcional j� cadastrada no pol1411'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1411_le_uni_funcio(mr_uf.cod_uni_funcio) THEN
      RETURN FALSE
   END IF
   
   LET mr_uf.den_uni_funcio = m_den_uf
      
   RETURN TRUE

END FUNCTION   

#------------------------------------#
FUNCTION pol1411_le_uni_funcio(l_cod)#
#------------------------------------#
   
   DEFINE l_cod          VARCHAR(10),
          l_dat_atu      DATE
   
   LET l_dat_atu = TODAY
   
   SELECT den_uni_funcio 
     INTO m_den_uf
     FROM uni_funcional
    WHERE cod_empresa = p_cod_empresa
      AND cod_uni_funcio = l_cod
      AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)     
       OR  (dat_validade_ini IS NULL AND dat_validade_fim >= l_dat_atu)     
       OR  (dat_validade_fim IS NULL AND dat_validade_ini <= l_dat_atu)     
       OR  (dat_validade_ini <= l_dat_atu AND dat_validade_fim IS NULL)     
       OR  (l_dat_atu BETWEEN dat_validade_ini AND dat_validade_fim))       
   
   IF STATUS = 100 THEN
      LET m_msg = 'Unidade funcional n�o existe\n ou est� fora da validade.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','Logix.uni_funcional')
         RETURN FALSE
      END IF
   END IF         
   
   RETURN TRUE      

END FUNCTION      

#-------------------------#
FUNCTION pol1411_zoom_uf()#
#-------------------------#

    DEFINE l_codigo         LIKE uni_funcional.cod_uni_funcio,
           l_descri         LIKE uni_funcional.den_uni_funcio,
           l_where_clause   CHAR(300)
    
    IF m_zoom_uf IS NULL THEN
       LET m_zoom_uf = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_uf,"ZOOM","zoom_uni_funcional")
    END IF

    LET l_where_clause = " uni_funcional.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_uf,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_uf,"RETURN_BY_TABLE_COLUMN","uni_funcional","cod_uni_funcio")
    LET l_descri = _ADVPL_get_property(m_zoom_uf,"RETURN_BY_TABLE_COLUMN","uni_funcional","den_uni_funcio")

    IF l_codigo IS NOT NULL THEN
       LET mr_uf.cod_uni_funcio = l_codigo
       LET mr_uf.den_uni_funcio = l_descri
    END IF        
    
    CALL _ADVPL_set_property(m_uni_funcio,"GET_FOCUS")
    
END FUNCTION


#-------------------------------#
FUNCTION pol1411_rec_uf_before()#
#-------------------------------#
           
   LET m_op_uf = 'R'
   
   IF m_car_uf THEN
      RETURN TRUE
   END IF
      
   LET m_lin_uf = _ADVPL_get_property(m_brz_uf,"ROW_SELECTED")
   
   IF m_lin_uf IS NULL OR m_lin_uf = 0 THEN
      RETURN TRUE
   END IF
   
   CALL pol1411_rec_uf_set_item(m_lin_uf)         
   CALL pol1411_rec_ativa(TRUE)
   CALL _ADVPL_set_property(m_uni_funcio,"GET_FOCUS")
   CALL pol1411_rec_ativa(FALSE)

   RETURN TRUE

END FUNCTION

#----------------------------------------#
FUNCTION pol1411_rec_uf_set_item(l_linha)#
#----------------------------------------#
   
   DEFINE l_linha     INTEGER
   
   LET mr_uf.cod_empresa = ma_uf[l_linha].cod_empresa
   LET mr_uf.cod_uni_funcio = ma_uf[l_linha].cod_uni_funcio
   LET mr_uf.den_uni_funcio = ma_uf[l_linha].den_uni_funcio
   LET mr_uf.posicao = ma_uf[l_linha].posicao
   LET mr_uf.setor = ma_uf[l_linha].setor

END FUNCTION

#------------------------------------#
FUNCTION pol1411_rec_ativa(l_status)#
#------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_rec,"ENABLE",l_status)

   IF m_op_uf = 'I' THEN
      CALL _ADVPL_set_property(m_uni_funcio,"ENABLE",l_status)
   ELSE
      CALL _ADVPL_set_property(m_uni_funcio,"ENABLE",FALSE)
   END IF
            
END FUNCTION

#----------------------------#
FUNCTION pol1411_rec_uf_ins()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   LET m_op_uf = 'I'
   LET m_car_uf = TRUE
   INITIALIZE mr_uf.* TO NULL
   LET mr_uf.cod_empresa = p_cod_empresa
      
   CALL pol1411_desativa_folder("2")
   CALL pol1411_rec_ativa(TRUE)
   CALL _ADVPL_set_property(m_uni_funcio,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1411_rec_uf_ins_canc()#
#-----------------------------------#

   CALL pol1411_rec_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_ativa_folder()
   CALL _ADVPL_set_property(m_brz_uf,"CLEAR")
   INITIALIZE mr_uf.*, ma_uf TO NULL
   LET m_car_uf = FALSE
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1411_rec_uf_ins_conf()#
#-----------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL
   
   IF NOT pol1411_rec_uf_inserir() THEN
      RETURN FALSE
   END IF
   
   CALL pol1411_rec_uf_prepare()
   CALL pol1411_rec_ativa(FALSE)
   CALL pol1411_ativa_folder()
   LET m_car_uf = FALSE
   
   RETURN TRUE

END FUNCTION        
   
#--------------------------------#
FUNCTION pol1411_rec_uf_inserir()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   INSERT INTO uni_funcio_970
    VALUES(mr_uf.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','uni_funcio_970')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1411_rec_uf_prepare()#
#----------------------------------#

   DEFINE l_sql_stmt CHAR(2000)
                        
   LET l_sql_stmt =
       " SELECT * ",
    "  FROM uni_funcio_970 ",
    " WHERE cod_empresa =  '",p_cod_empresa,"' "

   CALL pol1411_rec_uf_exibe(l_sql_stmt)

END FUNCTION

#----------------------------------------#
FUNCTION pol1411_rec_uf_exibe(l_sql_stmt)#
#----------------------------------------#
   
   DEFINE l_sql_stmt   CHAR(2000),
          l_ind        INTEGER

   LET m_car_uf = TRUE
   CALL _ADVPL_set_property(m_brz_uf,"CLEAR")
   INITIALIZE ma_uf TO NULL
   LET l_ind = 1
   
    PREPARE var_uf FROM l_sql_stmt

    IF STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","uni_funcio_970:PREPARE")
       RETURN FALSE
    END IF

   DECLARE cq_uf CURSOR FOR var_uf
   
   FOREACH cq_uf INTO ma_uf[l_ind].*
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('SELECT','cq_uf:01')
         EXIT FOREACH
      END IF

      LET l_ind = l_ind + 1
      
      IF l_ind > 100 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF 
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   IF l_ind > 0 THEN
      CALL _ADVPL_set_property(m_brz_uf,"ITEM_COUNT", l_ind)
   ELSE
      LET m_msg = 'N�o h� registros para os par�metros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

   LET m_car_uf = FALSE
        
END FUNCTION

#-------------------------------#
FUNCTION pol1411_rec_uf_find()#
#-------------------------------#

    DEFINE l_status       SMALLINT,
           l_where        CHAR(500),
           l_order        CHAR(200)
    
    LET m_op_uf = 'P'
    
    IF m_rec_uf_const IS NULL THEN
       LET m_rec_uf_const = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_rec_uf_const,"CONSTRUCT_NAME","pol1411_uni_func")
       CALL _ADVPL_set_property(m_rec_uf_const,"ADD_VIRTUAL_TABLE","uni_funcio_970","parametro")
       CALL _ADVPL_set_property(m_rec_uf_const,"ADD_VIRTUAL_COLUMN","uni_funcio_970","cod_uni_funcio","C�digo",1 {CHAR},10,0)
       CALL _ADVPL_set_property(m_rec_uf_const,"ADD_VIRTUAL_COLUMN","uni_funcio_970","den_uni_funcio","Descri��o",1 {CHAR},30,0)
    END IF

    LET l_status = _ADVPL_get_property(m_rec_uf_const,"INIT_CONSTRUCT")

    IF l_status THEN
       LET l_where = _ADVPL_get_property(m_rec_uf_const,"WHERE_CLAUSE")
       LET l_order = _ADVPL_get_property(m_rec_uf_const,"ORDER_BY")
       CALL pol1411_rec_uf_cursor(l_where,l_order)
    ELSE
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
END FUNCTION

#-----------------------------------------------#
FUNCTION pol1411_rec_uf_cursor(l_where, l_order)#
#-----------------------------------------------#
    
    DEFINE l_where     CHAR(500)
    DEFINE l_order     CHAR(200)
    DEFINE l_sql_stmt CHAR(2000)
    DEFINE l_ind        INTEGER

    IF l_order IS NULL THEN
       LET l_order = " cod_uni_funcio "
    END IF

    
    LET l_sql_stmt = 
       " SELECT * ",
       " FROM uni_funcio_970 ",
        " WHERE ",l_where CLIPPED,
        " AND cod_empresa =  '",p_cod_empresa,"' ",
        " ORDER BY ",l_order
   
   CALL pol1411_rec_uf_exibe(l_sql_stmt)
   LET m_lin_uf = 1
   CALL pol1411_rec_uf_set_item(1)
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1411_rec_uf_prende()#
#----------------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_rec_uf_prende CURSOR FOR
    SELECT 1
      FROM uni_funcio_970
     WHERE cod_empresa = mr_uf.cod_empresa
       AND cod_uni_funcio = mr_uf.cod_uni_funcio
     FOR UPDATE 
    
    OPEN cq_rec_uf_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_rec_uf_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_rec_uf_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_rec_uf_prende")
      CALL LOG_transaction_rollback()
      CLOSE cq_rec_uf_prende
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1411_rec_uf_upd()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_uf.cod_uni_funcio IS NULL THEN
      LET m_msg = 'Execute a consulta previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1411_rec_uf_prende() THEN
      RETURN FALSE
   END IF

   LET m_op_uf = 'M'
   LET m_cod_posicao = mr_uf.posicao
   LET m_cod_setor = mr_uf.setor

   CALL pol1411_desativa_folder("2")
   CALL pol1411_rec_ativa(TRUE)
   CALL _ADVPL_set_property(m_setor,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1411_rec_uf_upd_canc()#
#---------------------------------#
   
   CALL LOG_transaction_rollback()  
   CLOSE cq_rec_uf_prende
   LET mr_uf.posicao = m_cod_posicao
   LET mr_uf.setor = m_cod_setor
   CALL pol1411_rec_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1411_rec_uf_upd_conf()#
#---------------------------------#
   
   UPDATE uni_funcio_970
      SET posicao = mr_uf.posicao,
          setor = mr_uf.setor
    WHERE cod_empresa = p_cod_empresa
      AND cod_uni_funcio = mr_uf.cod_uni_funcio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','uni_funcio_970')
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_brz_uf,"COLUMN_VALUE","posicao",m_lin_uf,mr_uf.posicao)
   CALL _ADVPL_set_property(m_brz_uf,"COLUMN_VALUE","setor",m_lin_uf,mr_uf.setor)

   CALL pol1411_rec_ativa(FALSE)
   CALL pol1411_ativa_folder()
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1411_rec_uf_delete()#
#-------------------------------#
   
   DEFINE l_ret   SMALLINT

   IF mr_uf.cod_uni_funcio IS NULL THEN
      LET m_msg = 'Selecione previamente um item na grade'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1411_rec_uf_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM uni_funcio_970
     WHERE cod_empresa = mr_uf.cod_empresa
       AND cod_uni_funcio = mr_uf.cod_uni_funcio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','uni_funcio_970:rud')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_oper.* TO NULL
   ELSE
      CALL LOG_transaction_rollback()     
   END IF
   
   CLOSE cq_rec_uf_prende
   CALL pol1411_rec_uf_prepare()
   
   RETURN l_ret
        
END FUNCTION

--------------------------------#
FUNCTION pol1411_rec_vusualizar()#
#--------------------------------#
   
   DEFINE l_ind       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_rec_count_reg()
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1411_rec_exibe","PROCESS")  

   RETURN p_status

END FUNCTION   

--------------------------------#
FUNCTION pol1411_rec_count_reg()#
#--------------------------------#

   SELECT COUNT(*) INTO m_count
     FROM equipamento 
          INNER JOIN cent_trabalho
             ON cent_trabalho.cod_empresa=equipamento.cod_empresa
            AND cent_trabalho.cod_cent_trab=equipamento.cod_cent_trab
          INNER JOIN uni_funcio_970
             ON uni_funcio_970.cod_empresa = equipamento.cod_empresa
            AND uni_funcio_970.cod_uni_funcio = equipamento.cod_uni_funcio            
          INNER JOIN min_eqpto_compl
             ON equipamento.cod_empresa = min_eqpto_compl.empresa
            AND equipamento.cod_equip = min_eqpto_compl.eqpto
            AND min_eqpto_compl.val_logico = 'S'
            AND min_eqpto_compl.campo = 'ATIVO'   
    WHERE equipamento.cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','equipamento:contando registros')
      LET m_count = 0
   END IF

END FUNCTION

#---------------------------#
FUNCTION pol1411_rec_exibe()#
#---------------------------#
   
   DEFINE l_codigo      VARCHAR(02),
          l_desc        VARCHAR(30),
          l_ind         INTEGER,
          l_progres     SMALLINT,
          l_cent_trab   VARCHAR(15)
   
   CALL _ADVPL_set_property(m_brz_rec,"CLEAR")
   
   LET m_car_rec = TRUE
   INITIALIZE ma_rec TO NULL
   LET l_ind = 1

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   DECLARE cq_le_rec CURSOR FOR
   SELECT equipamento.cod_equip, 
          cent_trabalho.den_cent_trab, 
          uni_funcio_970.posicao,
          uni_funcio_970.setor,
          cent_trabalho.cod_cent_trab
     FROM equipamento 
          INNER JOIN cent_trabalho
             ON cent_trabalho.cod_empresa=equipamento.cod_empresa
            AND cent_trabalho.cod_cent_trab=equipamento.cod_cent_trab
          INNER JOIN uni_funcio_970
             ON uni_funcio_970.cod_empresa = equipamento.cod_empresa
            AND uni_funcio_970.cod_uni_funcio = equipamento.cod_uni_funcio            
          INNER JOIN min_eqpto_compl
             ON equipamento.cod_empresa = min_eqpto_compl.empresa
            AND equipamento.cod_equip = min_eqpto_compl.eqpto
            AND min_eqpto_compl.val_logico = 'S'
            AND min_eqpto_compl.campo = 'ATIVO'   
    WHERE equipamento.cod_empresa = p_cod_empresa
    ORDER BY uni_funcio_970.setor, cent_trabalho.cod_cent_trab DESC
       
   FOREACH cq_le_rec INTO
      ma_rec[l_ind].cod_equip,       
      ma_rec[l_ind].den_cent_trab, 
      ma_rec[l_ind].posicao,     
      ma_rec[l_ind].setor,
      l_cent_trab

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','equipamento:lendo registros')
         RETURN FALSE
      END IF

      LET ma_rec[l_ind].finito = 'FINITO'
      LET ma_rec[l_ind].eficiencia  = 85

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.\n',
                     'Ser�o exibidos somete 5000 registros.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_ind = l_ind - 1
   CALL _ADVPL_set_property(m_brz_rec,"ITEM_COUNT", l_ind)
   
   RETURN TRUE

END FUNCTION
   
#------------------------------#
FUNCTION pol1411_rec_exportar()#
#------------------------------#
   
   DEFINE l_arquivo    VARCHAR(120)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_rec_count_reg()
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   CALL pol1413_export_rec(m_count) RETURNING p_status, l_arquivo
   
   IF p_status THEN
      LET m_msg = 'Arquivo gerado no caminho\n\n',l_arquivo CLIPPED
   ELSE
      LET m_msg = 'Consulte a tabela de mensagem export_dados_opcenter_970'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')         
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   RETURN p_status

END FUNCTION   

#---Rotinas para exporta��o de grupo ----#

#------------------------------#
FUNCTION pol1411_grup(l_fpanel)#
#------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_exportar  VARCHAR(10),
           l_visuali   VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_exportar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_exportar,"IMAGE","MAN_EXPORT")     
    CALL _ADVPL_set_property(l_exportar,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_exportar,"TOOLTIP","Exportar dados para OPCENTER")
    CALL _ADVPL_set_property(l_exportar,"EVENT","pol1411_grup_exportar")

    LET l_visuali = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_visuali,"IMAGE","VISUALIZAR_SUP")     
    CALL _ADVPL_set_property(l_visuali,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_visuali,"TOOLTIP","Visualizar exporta��o de dados")
    CALL _ADVPL_set_property(l_visuali,"EVENT","pol1411_grup_vusualizar")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1411_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1411_grup_campo(l_panel)
    CALL pol1411_grup_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1411_grup_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_pan_cab         VARCHAR(10),
           l_pan_uf          VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pan_grup = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_grup,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_grup,"HEIGHT",30)

END FUNCTION

#---------------------------------------#
FUNCTION pol1411_grup_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_grup = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_grup,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_grup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Grupo")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_cent_trab")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",250)
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_grup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_grup,"SET_ROWS",ma_grup,1)
    CALL _ADVPL_set_property(m_brz_grup,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_grup,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_grup,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

----------------------------------#
FUNCTION pol1411_grup_vusualizar()#
#---------------------------------#
   
   DEFINE l_ind       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_grup_count_reg()
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1411_grup_exibe","PROCESS")  

   RETURN p_status

END FUNCTION   

---------------------------------#
FUNCTION pol1411_grup_count_reg()#
#--------------------------------#

   SELECT COUNT(*) INTO m_count
     FROM cent_trabalho
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cent_trabalho:contando registros')
      LET m_count = 0
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1411_grup_exibe()#
#----------------------------#
   
   DEFINE l_codigo      VARCHAR(02),
          l_desc        VARCHAR(30),
          l_ind         INTEGER,
          l_progres     SMALLINT,
          l_cent_trab   VARCHAR(15)
   
   CALL _ADVPL_set_property(m_brz_grup,"CLEAR")
   
   INITIALIZE ma_grup TO NULL
   LET l_ind = 1

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   DECLARE cq_le_grup CURSOR FOR
    SELECT DISTINCT den_cent_trab 
      FROM cent_trabalho
     WHERE cod_empresa = p_cod_empresa
     ORDER BY den_cent_trab
       
   FOREACH cq_le_grup INTO
      ma_grup[l_ind].den_cent_trab       

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cent_trabalho:lendo registros')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.\n',
                     'Ser�o exibidos somete 1000 registros.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_ind = l_ind - 1
   CALL _ADVPL_set_property(m_brz_grup,"ITEM_COUNT", l_ind)
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1411_grup_exportar()#
#-------------------------------#
   
   DEFINE l_arquivo    VARCHAR(120)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_grup_count_reg()
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   CALL pol1414_export_grup(m_count) RETURNING p_status, l_arquivo
   
   IF p_status THEN
      LET m_msg = 'Arquivo gerado no caminho\n\n',l_arquivo CLIPPED
   ELSE
      LET m_msg = 'Consulte a tabela de mensagem export_dados_opcenter_970'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')         
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   RETURN p_status

END FUNCTION   

#---Rotinas para exporta��o de recursos por grupo ----#

#-------------------------------#
FUNCTION pol1411_rgrup(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_exportar  VARCHAR(10),
           l_visuali   VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_exportar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_exportar,"IMAGE","MAN_EXPORT")     
    CALL _ADVPL_set_property(l_exportar,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_exportar,"TOOLTIP","Exportar dados para OPCENTER")
    CALL _ADVPL_set_property(l_exportar,"EVENT","pol1411_rgrup_exportar")

    LET l_visuali = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_visuali,"IMAGE","VISUALIZAR_SUP")     
    CALL _ADVPL_set_property(l_visuali,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_visuali,"TOOLTIP","Visualizar exporta��o de dados")
    CALL _ADVPL_set_property(l_visuali,"EVENT","pol1411_rgrup_vusualizar")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1411_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1411_rgrup_campo(l_panel)
    CALL pol1411_rgrup_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1411_rgrup_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_pan_cab         VARCHAR(10),
           l_pan_uf          VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pan_rgrup = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_rgrup,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_rgrup,"HEIGHT",30)

END FUNCTION

#---------------------------------------#
FUNCTION pol1411_rgrup_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_rgrup = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_rgrup,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rgrup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Grupo")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_cent_trab")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",180)
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rgrup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Recurso")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_equip")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rgrup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Setor")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","setor")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_rgrup)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_rgrup,"SET_ROWS",ma_rgrup,1)
    CALL _ADVPL_set_property(m_brz_rgrup,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_rgrup,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_rgrup,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

----------------------------------#
FUNCTION pol1411_rgrup_vusualizar()#
#---------------------------------#
   
   DEFINE l_ind       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_rgrup_count_reg()
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1411_rgrup_exibe","PROCESS")  

   RETURN p_status

END FUNCTION   

---------------------------------#
FUNCTION pol1411_rgrup_count_reg()#
#--------------------------------#

   SELECT COUNT(*) INTO m_count
     FROM equipamento
         INNER JOIN cent_trabalho
            ON cent_trabalho.cod_empresa = equipamento.cod_empresa
           AND cent_trabalho.cod_cent_trab = equipamento.cod_cent_trab
         INNER JOIN uni_funcio_970
            ON uni_funcio_970.cod_empresa = equipamento.cod_empresa
           AND uni_funcio_970.cod_uni_funcio = equipamento.cod_uni_funcio
    WHERE equipamento.cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','equipamento:contando registros')
      LET m_count = 0
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1411_rgrup_exibe()#
#----------------------------#
   
   DEFINE l_codigo      VARCHAR(02),
          l_desc        VARCHAR(30),
          l_ind         INTEGER,
          l_progres     SMALLINT,
          l_cent_trab   VARCHAR(15)
   
   CALL _ADVPL_set_property(m_brz_rgrup,"CLEAR")
   
   INITIALIZE ma_rgrup TO NULL
   LET l_ind = 1

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   DECLARE cq_le_rgrup CURSOR FOR
    SELECT cent_trabalho.den_cent_trab,
           equipamento.cod_equip,
           uni_funcio_970.setor
      FROM equipamento
         INNER JOIN cent_trabalho
            ON cent_trabalho.cod_empresa = equipamento.cod_empresa
           AND cent_trabalho.cod_cent_trab = equipamento.cod_cent_trab
         INNER JOIN uni_funcio_970
            ON uni_funcio_970.cod_empresa = equipamento.cod_empresa
           AND uni_funcio_970.cod_uni_funcio = equipamento.cod_uni_funcio
     WHERE equipamento.cod_empresa = p_cod_empresa
     ORDER BY cent_trabalho.den_cent_trab
       
   FOREACH cq_le_rgrup INTO
      ma_rgrup[l_ind].den_cent_trab,
      ma_rgrup[l_ind].cod_equip,
      ma_rgrup[l_ind].setor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','equipamento:lendo registros')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 1000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.\n',
                     'Ser�o exibidos somete 1000 registros.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_ind = l_ind - 1
   CALL _ADVPL_set_property(m_brz_rgrup,"ITEM_COUNT", l_ind)
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1411_rgrup_exportar()#
#-------------------------------#
   
   DEFINE l_arquivo    VARCHAR(120)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_rgrup_count_reg()
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   CALL pol1415_export_rgrup(m_count) RETURNING p_status, l_arquivo
   
   IF p_status THEN
      LET m_msg = 'Arquivo gerado no caminho\n\n',l_arquivo CLIPPED
   ELSE
      LET m_msg = 'Consulte a tabela de mensagem export_dados_opcenter_970'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')         
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   RETURN p_status

END FUNCTION   

#---Rotinas para exporta��o ordens de produ��o ----#

#-------------------------------#
FUNCTION pol1411_ordem(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_exportar  VARCHAR(10),
           l_visuali   VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10),
           l_update    VARCHAR(10),
           l_delete    VARCHAR(10)
           
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1411_ordem_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1411_ordem_ins")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1411_ordem_ins_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1411_ordem_ins_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1411_ordem_upd")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1411_ordem_upd_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1411_ordem_upd_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1411_ordem_delete")
       
    LET l_exportar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_exportar,"IMAGE","MAN_EXPORT")     
    CALL _ADVPL_set_property(l_exportar,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_exportar,"TOOLTIP","Exportar dados para OPCENTER")
    CALL _ADVPL_set_property(l_exportar,"EVENT","pol1411_ordem_exportar")

    LET l_visuali = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_visuali,"IMAGE","VISUALIZAR_SUP")     
    CALL _ADVPL_set_property(l_visuali,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_visuali,"TOOLTIP","Visualizar exporta��o de dados")
    CALL _ADVPL_set_property(l_visuali,"EVENT","pol1411_ordem_vusualizar")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1411_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1411_ordem_campo(l_panel)
    CALL pol1411_ordem_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1411_ordem_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_pan_cab         VARCHAR(10),
           l_pan_uf          VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pan_ordem = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_ordem,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_ordem,"HEIGHT",30)
    CALL _ADVPL_set_property(m_pan_ordem,"ENABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_ordem)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",5,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_ordem)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",55,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_ordem,"cod_empresa")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_ordem)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",110,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Exportar Ordens")    

    LET m_planejada = _ADVPL_create_component(NULL,"LCHECKBOX",m_pan_ordem)
    CALL _ADVPL_set_property(m_planejada,"POSITION",210,10)  
    CALL _ADVPL_set_property(m_planejada,"TEXT","Planejadas")   
    CALL _ADVPL_set_property(m_planejada,"VARIABLE",mr_ordem,"ies_planejada")
    CALL _ADVPL_set_property(m_planejada,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_planejada,"VALUE_NCHECKED","N")     

    LET m_firme = _ADVPL_create_component(NULL,"LCHECKBOX",m_pan_ordem)
    CALL _ADVPL_set_property(m_firme,"POSITION",300,10)  
    CALL _ADVPL_set_property(m_firme,"TEXT","Firmes")   
    CALL _ADVPL_set_property(m_firme,"VARIABLE",mr_ordem,"ies_firme")
    CALL _ADVPL_set_property(m_firme,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_firme,"VALUE_NCHECKED","N")     

    LET m_aberta = _ADVPL_create_component(NULL,"LCHECKBOX",m_pan_ordem)
    CALL _ADVPL_set_property(m_aberta,"POSITION",370,10)  
    CALL _ADVPL_set_property(m_aberta,"TEXT","Abertas")   
    CALL _ADVPL_set_property(m_aberta,"VARIABLE",mr_ordem,"ies_aberta")
    CALL _ADVPL_set_property(m_aberta,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_aberta,"VALUE_NCHECKED","N")     

    LET m_liberada = _ADVPL_create_component(NULL,"LCHECKBOX",m_pan_ordem)
    CALL _ADVPL_set_property(m_liberada,"POSITION",440,10)  
    CALL _ADVPL_set_property(m_liberada,"TEXT","Liberada")   
    CALL _ADVPL_set_property(m_liberada,"VARIABLE",mr_ordem,"ies_liberada")
    CALL _ADVPL_set_property(m_liberada,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_liberada,"VALUE_NCHECKED","N")     

    LET m_fechada = _ADVPL_create_component(NULL,"LCHECKBOX",m_pan_ordem)
    CALL _ADVPL_set_property(m_fechada,"POSITION",510,10)  
    CALL _ADVPL_set_property(m_fechada,"TEXT","Fechada")   
    CALL _ADVPL_set_property(m_fechada,"VARIABLE",mr_ordem,"ies_fechada")
    CALL _ADVPL_set_property(m_fechada,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_fechada,"VALUE_NCHECKED","N")     

    LET m_cancelada = _ADVPL_create_component(NULL,"LCHECKBOX",m_pan_ordem)
    CALL _ADVPL_set_property(m_cancelada,"POSITION",580,10)  
    CALL _ADVPL_set_property(m_cancelada,"TEXT","Cancelada")   
    CALL _ADVPL_set_property(m_cancelada,"VARIABLE",mr_ordem,"ies_cancelada")
    CALL _ADVPL_set_property(m_cancelada,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_cancelada,"VALUE_NCHECKED","N")     

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_ordem)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",700,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Qtd dias ap�s dat entrega")    

    LET m_dias_entr = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pan_ordem)
    CALL _ADVPL_set_property(m_dias_entr,"POSITION",840,10)  
    CALL _ADVPL_set_property(m_dias_entr,"LENGTH",3)    
    CALL _ADVPL_set_property(m_dias_entr,"VARIABLE",mr_ordem,"qtd_dias_entr")

END FUNCTION

#---------------------------------------#
FUNCTION pol1411_ordem_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_ordem = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_ordem,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Planejado")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_planej")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Situa��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_situa")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_situa")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Setor")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","setor")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_ordem)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_ordem,"SET_ROWS",ma_ordem,1)
    CALL _ADVPL_set_property(m_brz_ordem,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_ordem,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_ordem,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1411_ordem_ativa(l_status)#
#-------------------------------------#

   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_ordem,"ENABLE",l_status)
            
END FUNCTION

#---------------------------#
FUNCTION pol1411_ordem_ins()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   SELECT cod_empresa
     FROM ordem_status_970
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 0 THEN
      LET m_msg = 'Par�metros j� existe para a empresa corrente. Consulte e modifique.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_ies_ordem = FALSE
   LET m_op_ordem = 'I'
   
   INITIALIZE mr_ordem.* TO NULL
   LET mr_ordem.cod_empresa = p_cod_empresa
   LET mr_ordem.ies_planejada = 'S'
   LET mr_ordem.ies_firme = 'S'
   LET mr_ordem.ies_aberta = 'S'
   LET mr_ordem.ies_liberada = 'S'
   LET mr_ordem.ies_fechada = 'N'
   LET mr_ordem.ies_cancelada = 'N'
         
   CALL pol1411_desativa_folder("5")
   CALL pol1411_ordem_ativa(TRUE)
   CALL _ADVPL_set_property(m_planejada,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1411_ordem_ins_canc()#
#--------------------------------#

   CALL pol1411_ordem_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_ativa_folder()
   INITIALIZE mr_ordem.* TO NULL
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1411_ordem_ins_conf()#
#--------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL
   
   IF mr_ordem.qtd_dias_entr IS NULL OR
      mr_ordem.qtd_dias_entr < 0 THEN
      LET m_msg = 'Informe a quantidade de dias ap�s data de entrega'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dias_entr,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF NOT pol1411_ordem_inserir() THEN
      RETURN FALSE
   END IF
   
   LET m_ies_ordem = TRUE
   
   RETURN TRUE

END FUNCTION        
   
#-------------------------------#
FUNCTION pol1411_ordem_inserir()#
#-------------------------------#
         
   INSERT INTO ordem_status_970
    VALUES(mr_ordem.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ordem_status_970')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1411_ordem_find()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   LET m_ies_ordem = FALSE
   
   SELECT * INTO mr_ordem.*
     FROM ordem_status_970
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      LET m_msg = 'N�o h� par�metros cadastrados para a empresa corrente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','ordem_status_970')
         RETURN FALSE
      END IF
   END IF   
   
   LET m_ies_ordem = TRUE
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1411_ordem_prende()#
#------------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_ordem_prende CURSOR FOR
   SELECT 1
     FROM ordem_status_970
    WHERE cod_empresa = mr_ordem.cod_empresa
     FOR UPDATE 
    
    OPEN cq_ordem_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_ordem_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_ordem_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_ordem_prende")
      CALL LOG_transaction_rollback()
      CLOSE cq_ordem_prende
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------#
FUNCTION pol1411_ordem_upd()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT m_ies_ordem THEN
      LET m_msg = 'Execute a consulta previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1411_ordem_prende() THEN
      RETURN FALSE
   END IF

   LET m_op_ordem = 'M'
            
   CALL pol1411_desativa_folder("5")
   CALL pol1411_ordem_ativa(TRUE)
   CALL _ADVPL_set_property(m_dias_entr,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1411_ordem_upd_canc()#
#--------------------------------#
   
   CALL LOG_transaction_rollback()  
   CLOSE cq_ordem_prende
   LET p_status = pol1411_ordem_find()   
   CALL pol1411_ordem_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1411_ordem_upd_conf()#
#--------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL
   
   IF mr_ordem.qtd_dias_entr IS NULL OR
      mr_ordem.qtd_dias_entr < 0 THEN
      LET m_msg = 'Informe a quantidade de dias ap�s data de entrega'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dias_entr,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF NOT pol1411_ordem_update() THEN
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()     
   
   CLOSE cq_ordem_prende
   
   RETURN TRUE

END FUNCTION        

#------------------------------#
FUNCTION pol1411_ordem_update()#
#------------------------------#
   
   UPDATE ordem_status_970
      SET ies_planejada = mr_ordem.ies_planejada,
          ies_firme = mr_ordem.ies_firme,
          ies_aberta = mr_ordem.ies_aberta,
          ies_liberada = mr_ordem.ies_liberada,
          ies_fechada = mr_ordem.ies_fechada,
          ies_cancelada = mr_ordem.ies_cancelada,
          qtd_dias_entr = mr_ordem.qtd_dias_entr
    WHERE cod_empresa = mr_ordem.cod_empresa

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('UPDATE','ordem_status_970')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1411_ordem_delete()#
#------------------------------#
   
   DEFINE l_ret   SMALLINT

   IF NOT m_ies_ordem THEN
      LET m_msg = 'Execute a consulta previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1411_ordem_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM ordem_status_970
     WHERE cod_empresa = mr_ordem.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','ordem_status_970:pod')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_ordem.* TO NULL
      LET m_ies_ordem = FALSE
   ELSE
      CALL LOG_transaction_rollback()     
   END IF
   
   CLOSE cq_ordem_prende
   
   RETURN l_ret
        
END FUNCTION
   
#----------------------------------#
FUNCTION pol1411_ordem_vusualizar()#
#---------------------------------#
   
   DEFINE l_ind       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT pol1411_ordem_count_reg() THEN
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1411_ordem_exibe","PROCESS")  

   RETURN p_status

END FUNCTION   

#---------------------------------#
FUNCTION pol1411_ordem_count_reg()#
#--------------------------------#
   
   DEFINE l_sql_where       VARCHAR(1000)
   
   IF NOT pol1411_ordem_find() THEN
      RETURN FALSE
   END IF
   
   LET m_ies_situa = "('0'"
   
   IF mr_ordem.ies_planejada = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'1'"
   END IF
   
   IF mr_ordem.ies_firme = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'2'"
   END IF

   IF mr_ordem.ies_aberta = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'3'"
   END IF

   IF mr_ordem.ies_liberada = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'4'"
   END IF

   IF mr_ordem.ies_fechada = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'5'"
   END IF

   IF mr_ordem.ies_cancelada = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'9'"
   END IF

   LET m_ies_situa = m_ies_situa CLIPPED,")"
   
   LET m_dat_entrega = TODAY + mr_ordem.qtd_dias_entr
                          
   LET m_sql = "SELECT COUNT(*) FROM ordens "
   
   LET m_where =
    " WHERE ordens.cod_empresa = '",p_cod_empresa,"' ",
      "AND ordens.ies_situa IN ",m_ies_situa,
      "AND ordens.dat_entrega <= '",m_dat_entrega,"' ",                                 
      "AND ordens.num_ordem NOT IN ",                                          
          "(SELECT ord_oper.num_ordem FROM ord_oper ",                            
            "WHERE ord_oper.cod_empresa = ordens.cod_empresa ",                   
              "AND ord_oper.num_ordem = ordens.num_ordem ",
              "AND cod_operac IN ",                   
                  "(SELECT oper_rot_970.cod_operac FROM oper_rot_970 ",
                    "WHERE oper_rot_970.cod_empresa = ord_oper.cod_empresa)) "
   
   LET l_sql_where = m_sql CLIPPED, m_where CLIPPED
   
   PREPARE var_count FROM l_sql_where
                                                                                                                                                              
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','ordens:contando registros(PREPARE)')
      RETURN FALSE
   END IF
   
   DECLARE cq_count CURSOR FOR var_count
   
   OPEN cq_count

   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','ordens:contando registros(OPEN)')
      RETURN FALSE
   END IF
   
   FETCH cq_count INTO m_count
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','ordens:contando registros(FETCH)')
      RETURN FALSE
   END IF
      
END FUNCTION

#----------------------------#
FUNCTION pol1411_ordem_exibe()#
#----------------------------#
   
   DEFINE l_codigo      VARCHAR(02),
          l_desc        VARCHAR(30),
          l_ind         INTEGER,
          l_progres     SMALLINT,
          l_cent_trab   VARCHAR(15),
          l_count       INTEGER,
          l_planj       DECIMAL(10,3),
          l_boas        DECIMAL(10,3),
          l_refug       DECIMAL(10,3),
          l_sucata       DECIMAL(10,3)
   
   DEFINE l_sql_where   VARCHAR(1000)
   
   CALL _ADVPL_set_property(m_brz_ordem,"CLEAR")
   
   INITIALIZE ma_ordem TO NULL
   LET l_ind = 1

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   LET m_sql = 
    "SELECT ordens.dat_entrega, ordens.num_ordem, ordens.cod_item, ordens.ies_situa, ",
    " ordens.qtd_planej, ordens.qtd_boas, ordens.qtd_refug, ordens.qtd_sucata FROM ordens "

 
   LET l_sql_where = m_sql CLIPPED, m_where CLIPPED, " ORDER BY ordens.dat_entrega "
   
   PREPARE var_ordens FROM l_sql_where
                                                                                                                                                              
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','ordens:lendo registros(PREPARE)')
      RETURN FALSE
   END IF
   
   DECLARE cq_ordens CURSOR FOR var_ordens

   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','ordens:lendo registros(DECLARE)')
      RETURN FALSE
   END IF
       
   FOREACH cq_ordens INTO
      ma_ordem[l_ind].dat_entrega,
      ma_ordem[l_ind].num_ordem,
      ma_ordem[l_ind].cod_item,
      ma_ordem[l_ind].ies_situa,
      l_planj, l_boas, l_refug, l_sucata      
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordens:lendo registros(FOREACH)')
         RETURN FALSE
      END IF
      
      LET ma_ordem[l_ind].qtd_planej = l_planj - l_boas - l_refug - l_sucata

      CASE ma_ordem[l_ind].ies_situa
           WHEN '1' LET ma_ordem[l_ind].den_situa = "PLANEJADA"  
           WHEN '2' LET ma_ordem[l_ind].den_situa = "FIRME"      
           WHEN '3' LET ma_ordem[l_ind].den_situa = "ABERTA"     
           WHEN '4' LET ma_ordem[l_ind].den_situa = "LIBERADA"   
           WHEN '5' LET ma_ordem[l_ind].den_situa = "FECHADA"    
           WHEN '9' LET ma_ordem[l_ind].den_situa = "CANCELADA"  
      END CASE

      SELECT setatual INTO ma_ordem[l_ind].setor
        FROM ciclo_peca_970
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_ordem[l_ind].cod_item

      IF STATUS = 100 THEN
         LET ma_ordem[l_ind].setor = ''
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ciclo_peca_970')
            RETURN FALSE
         END IF
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 5000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.\n',
                     'Ser�o exibidos somete 5000 registros.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_ind = l_ind - 1
   CALL _ADVPL_set_property(m_brz_ordem,"ITEM_COUNT", l_ind)
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1411_ordem_exportar()#
#-------------------------------#
   
   DEFINE l_arquivo    VARCHAR(120)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1411_ordem_count_reg() THEN
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   CALL pol1416_export_ordem(m_count) RETURNING p_status, l_arquivo
   
   IF p_status THEN
      LET m_msg = 'Arquivo gerado no caminho\n\n',l_arquivo CLIPPED
   ELSE
      LET m_msg = 'Consulte a tabela de mensagem export_dados_opcenter_970'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')         
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   RETURN p_status

END FUNCTION   

#---Rotinas para exporta��o de materiais ----#

#-------------------------------#
FUNCTION pol1411_mat(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_exportar  VARCHAR(10),
           l_visuali   VARCHAR(10),
           l_find      VARCHAR(10),
           l_create    VARCHAR(10),
           l_update    VARCHAR(10),
           l_delete    VARCHAR(10)
           
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1411_mat_find")

    LET l_create = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_create,"EVENT","pol1411_mat_ins")
    CALL _ADVPL_set_property(l_create,"CONFIRM_EVENT","pol1411_mat_ins_conf")
    CALL _ADVPL_set_property(l_create,"CANCEL_EVENT","pol1411_mat_ins_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1411_mat_upd")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1411_mat_upd_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1411_mat_upd_canc")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1411_mat_delete")
       
    LET l_exportar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_exportar,"IMAGE","MAN_EXPORT")     
    CALL _ADVPL_set_property(l_exportar,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_exportar,"TOOLTIP","Exportar dados para OPCENTER")
    CALL _ADVPL_set_property(l_exportar,"EVENT","pol1411_mat_exportar")

    LET l_visuali = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_visuali,"IMAGE","VISUALIZAR_SUP")     
    CALL _ADVPL_set_property(l_visuali,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_visuali,"TOOLTIP","Visualizar exporta��o de dados")
    CALL _ADVPL_set_property(l_visuali,"EVENT","pol1411_mat_vusualizar")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1411_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1411_mat_campo(l_panel)
    CALL pol1411_mat_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1411_mat_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_pan_cab         VARCHAR(10),
           l_pan_uf          VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pan_mat = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_mat,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_mat,"HEIGHT",30)
    CALL _ADVPL_set_property(m_pan_mat,"ENABLE",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_mat)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",5,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pan_mat)     
    CALL _ADVPL_set_property(l_caixa,"POSITION",55,10) 
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)    
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_mat,"cod_empresa")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pan_mat)
    CALL _ADVPL_set_property(l_label,"TRANSPARENT",TRUE)
    CALL _ADVPL_set_property(l_label,"POSITION",110,10)  
    CALL _ADVPL_set_property(l_label,"TEXT","Tipo de item")    

    LET m_produzido = _ADVPL_create_component(NULL,"LCHECKBOX",m_pan_mat)
    CALL _ADVPL_set_property(m_produzido,"POSITION",170,10)  
    CALL _ADVPL_set_property(m_produzido,"TEXT","Produzido")   
    CALL _ADVPL_set_property(m_produzido,"VARIABLE",mr_mat,"ies_produzido")
    CALL _ADVPL_set_property(m_produzido,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_produzido,"VALUE_NCHECKED","N")     

    LET m_final = _ADVPL_create_component(NULL,"LCHECKBOX",m_pan_mat)
    CALL _ADVPL_set_property(m_final,"POSITION",260,10)  
    CALL _ADVPL_set_property(m_final,"TEXT","Final")   
    CALL _ADVPL_set_property(m_final,"VARIABLE",mr_mat,"ies_final")
    CALL _ADVPL_set_property(m_final,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_final,"VALUE_NCHECKED","N")     

END FUNCTION

#---------------------------------------#
FUNCTION pol1411_mat_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_mat = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_mat,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item pai")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item_pai")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Componente")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item_compon")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Necessidade")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_necessaria")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Multil")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","multil")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ignorar")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ignorar")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_mat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_mat,"SET_ROWS",ma_mat,1)
    CALL _ADVPL_set_property(m_brz_mat,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_mat,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_mat,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1411_mat_ativa(l_status)#
#-------------------------------------#

   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pan_mat,"ENABLE",l_status)
            
END FUNCTION

#-------------------------#
FUNCTION pol1411_mat_ins()#
#-------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   SELECT cod_empresa
     FROM mat_status_970
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 0 THEN
      LET m_msg = 'Par�metros j� existe para a empresa corrente. Consulte e modifique.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_ies_mat = FALSE
   LET m_op_mat = 'I'
   
   INITIALIZE mr_mat.* TO NULL
   LET mr_mat.cod_empresa = p_cod_empresa
   LET mr_mat.ies_produzido = 'S'
   LET mr_mat.ies_final = 'S'
         
   CALL pol1411_desativa_folder("6")
   CALL pol1411_mat_ativa(TRUE)
   CALL _ADVPL_set_property(m_produzido,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1411_mat_ins_canc()#
#--------------------------------#

   CALL pol1411_mat_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_ativa_folder()
   INITIALIZE mr_mat.* TO NULL
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1411_mat_ins_conf()#
#--------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL
      
   IF NOT pol1411_mat_inserir() THEN
      RETURN FALSE
   END IF
   
   LET m_ies_mat = TRUE
   
   RETURN TRUE

END FUNCTION        
   
#-------------------------------#
FUNCTION pol1411_mat_inserir()#
#-------------------------------#
         
   INSERT INTO mat_status_970
    VALUES(mr_mat.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','mat_status_970')
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1411_mat_find()#
#----------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   LET m_ies_mat = FALSE
   
   SELECT * INTO mr_mat.*
     FROM mat_status_970
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      LET m_msg = 'N�o h� par�metros cadastrados para a empresa corrente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','mat_status_970')
         RETURN FALSE
      END IF
   END IF   
   
   LET m_ies_mat = TRUE
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1411_mat_prende()#
#------------------------------#
   
   CALL  LOG_transaction_begin()
   
   DECLARE cq_mat_prende CURSOR FOR
   SELECT 1
     FROM mat_status_970
    WHERE cod_empresa = mr_mat.cod_empresa
     FOR UPDATE 
    
    OPEN cq_mat_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_mat_prende")
       CALL LOG_transaction_rollback()
       RETURN FALSE
    END IF
    
   FETCH cq_mat_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_mat_prende")
      CALL LOG_transaction_rollback()
      CLOSE cq_mat_prende
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------#
FUNCTION pol1411_mat_upd()#
#-------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT m_ies_mat THEN
      LET m_msg = 'Execute a consulta previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF NOT pol1411_mat_prende() THEN
      RETURN FALSE
   END IF

   LET m_op_mat = 'M'
            
   CALL pol1411_desativa_folder("6")
   CALL pol1411_mat_ativa(TRUE)
   CALL _ADVPL_set_property(m_produzido,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1411_mat_upd_canc()#
#--------------------------------#
   
   CALL LOG_transaction_rollback()  
   CLOSE cq_mat_prende
   LET p_status = pol1411_mat_find()   
   CALL pol1411_mat_ativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_ativa_folder()
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1411_mat_upd_conf()#
#------------------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET m_msg = NULL
      
   IF NOT pol1411_mat_update() THEN
      RETURN FALSE
   END IF

   CALL LOG_transaction_commit()     
   
   CLOSE cq_mat_prende
   
   RETURN TRUE

END FUNCTION        

#----------------------------#
FUNCTION pol1411_mat_update()#
#----------------------------#
   
   UPDATE mat_status_970
      SET ies_produzido = mr_mat.ies_produzido,
          ies_final = mr_mat.ies_final
    WHERE cod_empresa = mr_mat.cod_empresa

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('UPDATE','mat_status_970')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1411_mat_delete()#
#------------------------------#
   
   DEFINE l_ret   SMALLINT

   IF NOT m_ies_mat THEN
      LET m_msg = 'Execute a consulta previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   IF NOT LOG_question("Confirma a exclus�o do registro?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1411_mat_prende() THEN
      RETURN FALSE
   END IF

   DELETE FROM mat_status_970
     WHERE cod_empresa = mr_mat.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','mat_status_970:pmd')
      LET l_ret = FALSE
   ELSE
      LET l_ret = TRUE
   END IF
   
   IF l_ret THEN
      CALL LOG_transaction_commit()
      INITIALIZE mr_mat.* TO NULL
      LET m_ies_mat = FALSE
   ELSE
      CALL LOG_transaction_rollback()     
   END IF
   
   CLOSE cq_mat_prende
   
   RETURN l_ret
        
END FUNCTION

#--------------------------------#
FUNCTION pol1411_mat_vusualizar()#
#--------------------------------#
   
   DEFINE l_ind       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT pol1411_mat_count_reg() THEN
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1411_mat_exibe","PROCESS")  

   RETURN p_status

END FUNCTION   

#---------------------------------#
FUNCTION pol1411_mat_count_reg()#
#--------------------------------#
   
   DEFINE l_sql_where       VARCHAR(1000)
   
   IF NOT pol1411_mat_find() THEN
      RETURN FALSE
   END IF
   
   LET m_mat_situa = "('0'"
   
   IF mr_mat.ies_produzido = 'S' THEN
      LET m_mat_situa = m_mat_situa CLIPPED,",'P'"
   END IF
   
   IF mr_mat.ies_final = 'S' THEN
      LET m_mat_situa = m_mat_situa CLIPPED,",'F'"
   END IF

   LET m_mat_situa = m_mat_situa CLIPPED,")"
                                
   LET m_sql = "SELECT COUNT(*) FROM item "
   
   LET m_mat_where =
    " WHERE item.cod_empresa = '",p_cod_empresa,"' ",
      "AND item.ies_tip_item IN ",m_mat_situa,
      "AND item.ies_situacao = 'A' "
   
   LET l_sql_where = m_sql CLIPPED, m_mat_where CLIPPED
   
   PREPARE var_count FROM l_sql_where
                                                                                                                                                              
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','item:contando registros(PREPARE)')
      RETURN FALSE
   END IF
   
   DECLARE cq_count CURSOR FOR var_count
   
   OPEN cq_count

   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','item:contando registros(OPEN)')
      RETURN FALSE
   END IF
   
   FETCH cq_count INTO m_count
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','item:contando registros(FETCH)')
      RETURN FALSE
   END IF
      
END FUNCTION

#----------------------------#
FUNCTION pol1411_mat_exibe()#
#----------------------------#
   
   DEFINE l_codigo      VARCHAR(02),
          l_desc        VARCHAR(30),
          l_ind         INTEGER,
          l_progres     SMALLINT,
          l_cent_trab   VARCHAR(15),
          l_count       INTEGER,
          l_dat_atu     DATE
   
   DEFINE l_sql_where   VARCHAR(1000)
   
   CALL _ADVPL_set_property(m_brz_mat,"CLEAR")   
   INITIALIZE ma_mat TO NULL
   LET l_ind = 1
   LET l_dat_atu = TODAY

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   LET m_sql = 
    "SELECT item.cod_item FROM item "

   LET l_sql_where = m_sql CLIPPED, m_mat_where CLIPPED
   
   PREPARE var_itens FROM l_sql_where
                                                                                                                                                              
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','item:lendo registros(PREPARE)')
      RETURN FALSE
   END IF
   
   DECLARE cq_itens CURSOR FOR var_itens

   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','item:lendo registros(DECLARE)')
      RETURN FALSE
   END IF
       
   FOREACH cq_itens INTO
      ma_mat[l_ind].item_pai

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item:lendo registros(FOREACH)')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      DECLARE cq_estrut CURSOR FOR
       SELECT cod_item_compon, qtd_necessaria           
         FROM estrut_grade
        WHERE cod_empresa = p_cod_empresa
          AND cod_item_pai = ma_mat[l_ind].item_pai
          AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
           OR  (dat_validade_ini IS NULL AND dat_validade_fim >= l_dat_atu)
           OR  (dat_validade_fim IS NULL AND dat_validade_ini <= l_dat_atu)
           OR  (dat_validade_ini <= l_dat_atu AND dat_validade_fim IS NULL)
           OR  (l_dat_atu BETWEEN dat_validade_ini AND dat_validade_fim))
   
      FOREACH cq_estrut INTO ma_mat[l_ind].item_compon, ma_mat[l_ind].qtd_necessaria
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT', 'estrut_grade:cq_estrut')
            RETURN FALSE
         END IF
         
         LET ma_mat[l_ind].multil = 'SIM'
         LET ma_mat[l_ind].ignorar = 'NAO'
      
         LET l_ind = l_ind + 1
      
         IF l_ind > 10000 THEN
            LET m_msg = 'Limite de linhas da grade ultrapassou.\n',
                        'Ser�o exibidos somete 10000 registros.'
            CALL log0030_mensagem(m_msg,'info')
            EXIT FOREACH
         END IF
      
      END FOREACH

      IF l_ind > 10000 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   CALL _ADVPL_set_property(m_brz_mat,"ITEM_COUNT", l_ind)
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1411_mat_exportar()#
#-------------------------------#
   
   DEFINE l_arquivo    VARCHAR(120)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF NOT pol1411_mat_count_reg() THEN
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   CALL pol1417_export_mat(m_count) RETURNING p_status, l_arquivo
   
   IF p_status THEN
      LET m_msg = 'Arquivo gerado no caminho\n\n',l_arquivo CLIPPED
   ELSE
      LET m_msg = 'Consulte a tabela de mensagem export_dados_opcenter_970'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')         
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   RETURN p_status

END FUNCTION   


#---Rotinas para exporta��o de estoque ----#

#-------------------------------#
FUNCTION pol1411_estoq(l_fpanel)#
#-------------------------------#

    DEFINE l_fpanel    VARCHAR(10),
           l_menubar   VARCHAR(10),
           l_panel     VARCHAR(10),
           l_fechar    VARCHAR(10),
           l_exportar  VARCHAR(10),
           l_visuali   VARCHAR(10)
        
    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_fpanel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_exportar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_exportar,"IMAGE","MAN_EXPORT")     
    CALL _ADVPL_set_property(l_exportar,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_exportar,"TOOLTIP","Exportar dados para OPCENTER")
    CALL _ADVPL_set_property(l_exportar,"EVENT","pol1411_estoq_exportar")

    LET l_visuali = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_visuali,"IMAGE","VISUALIZAR_SUP")     
    CALL _ADVPL_set_property(l_visuali,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_visuali,"TOOLTIP","Visualizar exporta��o de dados")
    CALL _ADVPL_set_property(l_visuali,"EVENT","pol1411_estoq_vusualizar")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1411_fechar")

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_fpanel)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")   
    
    CALL pol1411_estoq_campo(l_panel)
    CALL pol1411_estoq_grade(l_panel)
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1411_estoq_campo(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_pan_cab         VARCHAR(10),
           l_pan_uf          VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pan_estoq = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pan_estoq,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pan_estoq,"HEIGHT",30)

END FUNCTION

#---------------------------------------#
FUNCTION pol1411_estoq_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_brz_estoq = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_estoq,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item_reduz")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Saldo")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_estoq")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tipo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fornecimento")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","fornecimento")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_estoq)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_estoq,"SET_ROWS",ma_estoq,1)
    CALL _ADVPL_set_property(m_brz_estoq,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_brz_estoq,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_estoq,"CAN_REMOVE_ROW",FALSE)
   
END FUNCTION

----------------------------------#
FUNCTION pol1411_estoq_vusualizar()#
#---------------------------------#
   
   DEFINE l_ind       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_estoq_count_reg()
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET p_status = LOG_progresspopup_start(
       "Lendo dados...","pol1411_estoq_exibe","PROCESS")  

   RETURN p_status

END FUNCTION   

---------------------------------#
FUNCTION pol1411_estoq_count_reg()#
#--------------------------------#

   SELECT COUNT(*) INTO m_count
     FROM estoque
          INNER JOIN item 
             ON item.cod_empresa = estoque.cod_empresa
            AND item.cod_item = estoque.cod_item 
            AND item.ies_situacao = 'A'
    WHERE estoque.cod_empresa= p_cod_empresa
      AND ((estoque.qtd_liberada + estoque.qtd_impedida) -
           (estoque.qtd_rejeitada + estoque.qtd_lib_excep + 
            estoque.qtd_disp_venda + estoque.qtd_reservada) > 0 )

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque:contando registros')
      LET m_count = 0
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1411_estoq_exibe()#
#----------------------------#
   
   DEFINE l_codigo      VARCHAR(02),
          l_desc        VARCHAR(30),
          l_ind         INTEGER,
          l_progres     SMALLINT,
          l_cent_trab   VARCHAR(15)
   
   CALL _ADVPL_set_property(m_brz_estoq,"CLEAR")
   
   INITIALIZE ma_estoq TO NULL
   LET l_ind = 1

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   DECLARE cq_le_estoq CURSOR FOR
    SELECT estoque.cod_item, item.den_item_reduz,
           ((estoque.qtd_liberada + estoque.qtd_impedida) - 
             (estoque.qtd_rejeitada + estoque.qtd_lib_excep + 
              estoque.qtd_disp_venda + estoque.qtd_reservada))
      FROM estoque
           INNER JOIN item 
             ON item.cod_empresa = estoque.cod_empresa
            AND item.cod_item = estoque.cod_item 
            AND item.ies_situacao = 'A'
    WHERE estoque.cod_empresa = p_cod_empresa
      AND ((estoque.qtd_liberada + estoque.qtd_impedida) -
           (estoque.qtd_rejeitada + estoque.qtd_lib_excep + 
            estoque.qtd_disp_venda + estoque.qtd_reservada) > 0 )
       
   FOREACH cq_le_estoq INTO
      ma_estoq[l_ind].cod_item,
      ma_estoq[l_ind].den_item_reduz,
      ma_estoq[l_ind].qtd_estoq

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque:lendo registros')
         RETURN FALSE
      END IF
      
      LET ma_estoq[l_ind].ordem = ma_estoq[l_ind].cod_item
      LET ma_estoq[l_ind].tipo = 'Estoque'
      LET ma_estoq[l_ind].fornecimento = TODAY - 1
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 10000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.\n',
                     'Ser�o exibidos somete 10000 registros.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_ind = l_ind - 1
   CALL _ADVPL_set_property(m_brz_estoq,"ITEM_COUNT", l_ind)
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1411_estoq_exportar()#
#-------------------------------#
   
   DEFINE l_arquivo    VARCHAR(120)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1411_estoq_count_reg()
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� dados a exportar. Verifique os par�metros.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF      
   
   CALL pol1418_export_estoq(m_count) RETURNING p_status, l_arquivo
   
   IF p_status THEN
      LET m_msg = 'Arquivo gerado no caminho\n\n',l_arquivo CLIPPED
   ELSE
      LET m_msg = 'Consulte a tabela de mensagem export_dados_opcenter_970'
   END IF
   
   CALL log0030_mensagem(m_msg,'info')         
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   RETURN p_status

END FUNCTION   
