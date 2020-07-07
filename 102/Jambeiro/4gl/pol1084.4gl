#-------------------------------------------------------------------#
# PROGRAMA: pol1084                                                 #
# OBJETIVO: MRP POR DEMANDA DE PEDIOS                               #
# CLIENTE.: JAMBEIRO                                                #
# DATA....: 27/07/2018                                              #
# DATA   ALTERA��O                                                  #
#
#-------------------------------------------------------------------#

{
CREATE TABLE ped_item_5000 (
 cod_empresa       CHAR(02) not null,
 num_pedido        INTEGER  not null,
 num_seq           INTEGER  not null,
 num_ordem         INTEGER  not null
);

CREATE index ix_ped_item_5000 on
 ped_item_50009(cod_empresa, num_pedido, num_seq);

CREATE TABLE demanda_erro_5000(
  cod_empresa  CHAR(02),
  num_pedido   INTEGER, 
  num_seq      INTEGER,
  den_erro     CHAR(300),
  dat_proces CHAR(19)
);


CREATE index ix_demanda_erro_5000 on
 demanda_erro_5000(cod_empresa, num_pedido, num_seq);
   
}

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           g_tipo_sgbd     CHAR(003),
           g_msg           CHAR(150)
END GLOBALS

DEFINE   p_den_empresa        VARCHAR(36),
         p_index              SMALLINT,
         s_index              SMALLINT,
         p_ind                SMALLINT,
         s_ind                SMALLINT,
         p_msg                CHAR(300),
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_rowid              SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
         p_nom_tela           CHAR(200),
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
         p_versao             CHAR(18),
         sql_stmt             CHAR(500),
         where_clause         CHAR(500),
         p_ies_info           SMALLINT,
         m_ies_cons           SMALLINT,
         p_query              CHAR(1000),
         m_num_pedido         INTEGER,
         m_count              INTEGER,
         m_ind                INTEGER,
         m_dat_atu            DATE,
         m_num_ordem          INTEGER,
         m_ies_proces         SMALLINT,
         m_carregando         SMALLINT,
         m_opcao              CHAR(01),
         p_ies_roteiro        SMALLINT


   DEFINE p_txt_aux           CHAR(30),
          p_dat_liberac       DATE,
          p_dat_abertura      DATE,
          p_dat_atu           DATE,
          p_dat_proces        CHAR(19)

   DEFINE p_parametros        LIKE par_pcp.parametros,
          p_cod_lin_prod      LIKE item.cod_lin_prod, 
          p_cod_lin_recei     LIKE item.cod_lin_recei,       
          p_cod_seg_merc      LIKE item.cod_seg_merc,        
          p_cod_cla_uso       LIKE item.cod_cla_uso,
          p_num_ordem         LIKE ordens.num_ordem,
          p_num_neces         LIKE ordens.num_neces,
          m_num_neces         LIKE ordens.num_neces,
          p_dat_entrega       LIKE ordens.dat_entrega,
          p_qtd_planej        LIKE ordens.qtd_planej, 
          p_ies_situa         LIKE ordens.ies_situa,
          p_cod_item          LIKE item.cod_item,
          p_cod_item_pai      LIKE item.cod_item,
          p_prz_entrega       LIKE ped_dem.prz_entrega,
          p_cod_local_estoq   LIKE item.cod_local_estoq,
          p_cod_local_prod    LIKE item.cod_local_estoq,
          p_cod_local_baixa   LIKE item.cod_local_estoq,
          p_num_lote          LIKE estoque_lote.num_lote,
          p_qtd_dias_horizon  LIKE horizonte.qtd_dias_horizon,
          p_cod_cent_trab     LIKE ord_compon.cod_cent_trab,
          p_ies_tip_item      LIKE item.ies_tip_item
                   
   
   DEFINE p_ordens            RECORD LIKE ordens.*,
          p_necessidades      RECORD LIKE necessidades.*,
          p_ord_compon        RECORD LIKE ord_compon.*,
          p_ord_oper          RECORD LIKE ord_oper.*,
          p_item_man          RECORD LIKE item_man.*

   DEFINE p_ped_dem           RECORD 
          id_registro         INTEGER,
          cod_empresa         CHAR(2),          
          num_projeto         CHAR(08),         
          num_pedido          DECIMAL(6,0),     
          num_seq             DECIMAL(3,0),     
          cod_item_pai        CHAR(15),         
          num_op_pai          INTEGER,          
          prz_entrega         DATE,             
          qtd_saldo           DECIMAL(10,3)     
   END RECORD

DEFINE ma_demanda        ARRAY[2000] OF RECORD
          id_registro         INTEGER,          
          num_projeto         CHAR(08),         
          num_pedido          DECIMAL(6,0),     
          num_seq             DECIMAL(3,0),     
          cod_item            CHAR(15),  
          den_item            CHAR(18),       
          qtd_saldo           DECIMAL(10,3),     
          prz_entrega         DATE,             
          num_ordem           INTEGER,
          ies_situa           CHAR(01),
          nom_cliente         CHAR(40)
END RECORD

DEFINE ma_op_filha        ARRAY[50] OF RECORD
          num_ordem           INTEGER,
          ies_situa           CHAR(01),
          cod_item            CHAR(15),  
          den_item            CHAR(18),       
          qtd_planej          DECIMAL(10,3),     
          dat_entrega         DATE           
END RECORD   
      
DEFINE mr_cabec          RECORD
       dat_ini           DATE,
       dat_fim           DATE,
       ies_demanda       CHAR(01),
       num_pedido        INTEGER,
       cod_item          CHAR(15),
       num_ordem         INTEGER       
END RECORD

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_panel           VARCHAR(10),
       m_browse          VARCHAR(10),
       m_brz_filha       VARCHAR(10),
       m_pedido          VARCHAR(10),
       m_lupa_ped        VARCHAR(10),
       m_zoom_ped        VARCHAR(10),
       m_item            VARCHAR(10),
       m_lupa_it         VARCHAR(10),
       m_zoom_it         VARCHAR(10),
       m_ordem           VARCHAR(10),
       m_lupa_op         VARCHAR(10),
       m_zoom_op         VARCHAR(10),
       m_apont           VARCHAR(10),
       m_demanda         VARCHAR(10),
       m_encerrada       VARCHAR(10),
       m_cancelada       VARCHAR(10),
       m_quantidade      VARCHAR(10),
       m_tempo           VARCHAR(10),
       m_lib_op          VARCHAR(10),
       m_datini          VARCHAR(10),
       m_datfim          VARCHAR(10),
       m_construct       VARCHAR(10)
             
#-----------------#
FUNCTION pol1084()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1084-12.00.08  "
   CALL func002_versao_prg(p_versao)
   
   LET m_dat_atu = TODAY
   
   CALL pol1084_menu()
    
END FUNCTION
 
#----------------------#
FUNCTION pol1084_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_transfer    VARCHAR(10),
           l_inform      VARCHAR(10),
           l_ordem       VARCHAR(10),
           l_find        VARCHAR(10),      
           l_titulo      CHAR(43)

    
    LET l_titulo = "MRP POR DEMANDA DE PEDIDO"
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"TOOLTIP","Informar par�metros para gera��o de ordens")
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1084_informar")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1084_info_conf")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1084_info_cancel")

    LET l_ordem = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_ordem,"IMAGE","ORDENS") 
    CALL _ADVPL_set_property(l_ordem,"TOOLTIP","Gerar ordens de produ��o")
    CALL _ADVPL_set_property(l_ordem,"TYPE","NO_CONFIRM")    
    CALL _ADVPL_set_property(l_ordem,"EVENT","pol1084_gerar")
    #CALL _ADVPL_set_property(l_ordem,"ENABLE",m_enable)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TOOLTIP","Consultar demanda com ordens")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1084_pesquisar")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1084_pesq_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1084_pesq_cancel")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
   LET m_carregando = TRUE
   CALL pol1084_cria_campos(l_panel)
   CALL pol1084_cria_grd_pai(l_panel)
   CALL pol1084_cria_grd_filha(l_panel)
   
   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
 
#----------------------------------------#
FUNCTION pol1084_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_item        VARCHAR(10),
           l_planejada       VARCHAR(10),
           l_saldo           VARCHAR(10),
           l_status          VARCHAR(10)

    LET m_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_panel,"HEIGHT",60)
    CALL _ADVPL_set_property(m_panel,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",20,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","Per�odo de:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_datini = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_datini,"POSITION",90,20)     
    CALL _ADVPL_set_property(m_datini,"VARIABLE",mr_cabec,"dat_ini")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",220,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","At�:")
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)
    
    LET m_datfim = _ADVPL_create_component(NULL,"LDATEFIELD",m_panel)
    CALL _ADVPL_set_property(m_datfim,"POSITION",260,20)     
    CALL _ADVPL_set_property(m_datfim,"VARIABLE",mr_cabec,"dat_fim")

    LET m_demanda = _ADVPL_create_component(NULL,"LCHECKBOX",m_panel)
    CALL _ADVPL_set_property(m_demanda,"POSITION",400,20)     
    CALL _ADVPL_set_property(m_demanda,"TEXT","S� demanda para pedido")     
    CALL _ADVPL_set_property(m_demanda,"VALUE_CHECKED","S")     
    CALL _ADVPL_set_property(m_demanda,"VALUE_NCHECKED","N")     
    CALL _ADVPL_set_property(m_demanda,"VARIABLE",mr_cabec,"ies_demanda")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",580,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","N�m pedido:")    

    LET m_pedido = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_pedido,"POSITION",650,20)     
    CALL _ADVPL_set_property(m_pedido,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_pedido,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_pedido,"VARIABLE",mr_cabec,"num_pedido")
    CALL _ADVPL_set_property(m_pedido,"VALID","pol1084_valid_pedido")

    LET m_lupa_ped = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_ped,"POSITION",740,20)     
    CALL _ADVPL_set_property(m_lupa_ped,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_ped,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_ped,"CLICK_EVENT","pol1084_zoom_pedido")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",780,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","Item do pedido:")    

    LET m_item = _ADVPL_create_component(NULL,"LTEXTFIELD",m_panel)
    CALL _ADVPL_set_property(m_item,"POSITION",860,20)     
    CALL _ADVPL_set_property(m_item,"LENGTH",15)
    CALL _ADVPL_set_property(m_item,"PICTURE","@!")
    CALL _ADVPL_set_property(m_item,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_item,"VARIABLE",mr_cabec,"cod_item")

    LET m_lupa_it = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_it,"POSITION",990,20)     
    CALL _ADVPL_set_property(m_lupa_it,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_it,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_it,"CLICK_EVENT","pol1084_zoom_item")
    CALL _ADVPL_set_property(m_lupa_it,"EDITABLE",FALSE)
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",1050,20)     
    CALL _ADVPL_set_property(l_label,"TEXT","Ordem pai:")    

    LET m_ordem = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_panel)
    CALL _ADVPL_set_property(m_ordem,"POSITION",1120,20)     
    CALL _ADVPL_set_property(m_ordem,"LENGTH",10,0)
    CALL _ADVPL_set_property(m_ordem,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_ordem,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_ordem,"VARIABLE",mr_cabec,"num_ordem")

    LET m_lupa_op = _ADVPL_create_component(NULL,"LIMAGEBUTTON",m_panel)
    CALL _ADVPL_set_property(m_lupa_op,"POSITION",1220,20)     
    CALL _ADVPL_set_property(m_lupa_op,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_op,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_lupa_op,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_op,"CLICK_EVENT","pol1084_zoom_ordem")

END FUNCTION

#-----------------------------------------#
FUNCTION pol1084_cria_grd_pai(l_container)#
#-----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_browse,"BEFORE_ROW_EVENT","pol1084_before_row")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Projeto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_projeto")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Sequencia")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_seq")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Produto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Quantidade")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_saldo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","prz_entrega")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","St")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_situa")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_demanda,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#-------------------------------------------#
FUNCTION pol1084_cria_grd_filha(l_container)#
#-------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_filha = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_filha,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_brz_filha,"AFTER_ROW_EVENT","pol1084_limpa_status")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_filha)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_filha)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","St")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ies_situa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_filha)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Produto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_filha)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_filha)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Quant")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_planej")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_filha)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_entrega")

    CALL _ADVPL_set_property(m_brz_filha,"SET_ROWS",ma_op_filha,1)
    CALL _ADVPL_set_property(m_brz_filha,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_brz_filha,"EDITABLE",FALSE)

END FUNCTION

#-----------------------------#
FUNCTION pol1084_zoom_pedido()#
#-----------------------------#
    
   DEFINE l_pedido       LIKE pedidos.num_pedido,
          l_filtro      CHAR(300)

   IF m_zoom_ped IS NULL THEN
      LET m_zoom_ped = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_ped,"ZOOM","zoom_pedidos")
   END IF

    LET l_filtro = " pedidos.cod_empresa = '",p_cod_empresa CLIPPED,"' "

    IF p_parametros[115] = "S" THEN
      LET l_filtro = l_filtro CLIPPED,
          " AND pedidos.ies_sit_pedido NOT IN ('S','P','9') "
    ELSE
      LET l_filtro = l_filtro CLIPPED,
          " AND pedidos.ies_sit_pedido NOT IN ('S','B','P','9') "
    END IF
    
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_zoom_ped,"ACTIVATE")

   LET l_pedido = _ADVPL_get_property(m_zoom_ped,"RETURN_BY_TABLE_COLUMN","pedidos","num_pedido")
   
   IF l_pedido IS NOT NULL THEN
      LET mr_cabec.num_pedido = l_pedido
   END IF
   
   CALL _ADVPL_set_property(m_pedido,"GET_FOCUS")
   
END FUNCTION

#------------------------------#
FUNCTION pol1084_valid_pedido()#
#------------------------------#

   DEFINE l_ies_situacao    CHAR(01)
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.num_pedido IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT ies_sit_pedido INTO l_ies_situacao
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = mr_cabec.num_pedido

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('SELECT','pedidos')
      RETURN FALSE
   END IF
   
   LET p_msg = NULL
   
   IF p_parametros[115] = "S" THEN
      IF l_ies_situacao MATCHES "[SP9]" THEN
         LET p_msg = 'Pedido com status n�o permitido - ',l_ies_situacao
      END IF      
   ELSE
      IF l_ies_situacao MATCHES "[SBP9]" THEN
         LET p_msg = 'Pedido com status n�o permitido - ',l_ies_situacao
      END IF
   END IF
   
   IF p_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",p_msg)
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO m_count 
    FROM pedidos a, ped_itens b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.num_pedido = mr_cabec.num_pedido
      AND b.cod_empresa = a.cod_empresa
      AND b.num_pedido = a.num_pedido
      AND b.qtd_pecas_atend = 0 
      AND b.qtd_pecas_romaneio = 0

   IF m_count = 0 THEN
      LET p_msg = 'Todos os itens desse pedido j� possuem faturamento.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",p_msg)
      RETURN FALSE
   END IF

   LET m_num_pedido = mr_cabec.num_pedido
   INITIALIZE mr_cabec.* TO NULL
   LET mr_cabec.num_pedido =  m_num_pedido
   CALL _ADVPL_set_property(m_panel,"EDITABLE",FALSE)
            
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1084_zoom_ordem()#
#----------------------------#
    
   DEFINE l_ordem       LIKE ordens.num_ordem,
          l_filtro      CHAR(300)

   IF m_zoom_op IS NULL THEN
      LET m_zoom_op = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_op,"ZOOM","zoom_ordem_producao")
   END IF

    LET l_filtro = " ordens.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_zoom_op,"ACTIVATE")

   LET l_ordem = _ADVPL_get_property(m_zoom_op,"RETURN_BY_TABLE_COLUMN","ordens","num_ordem")
   
   IF l_ordem IS NOT NULL THEN
      LET mr_cabec.num_ordem = l_ordem
   END IF
   
   CALL _ADVPL_set_property(m_ordem,"GET_FOCUS")
   
END FUNCTION

#---------------------------#
FUNCTION pol1084_zoom_item()#
#---------------------------#
    
   DEFINE l_item        LIKE item.cod_item,
          l_desc        LIKE item.den_item,
          l_filtro      CHAR(300)
          
   IF m_zoom_it IS NULL THEN
      LET m_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
      CALL _ADVPL_set_property(m_zoom_it,"ZOOM","zoom_item")
   END IF

    LET l_filtro = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_filtro CLIPPED)

   CALL _ADVPL_get_property(m_zoom_it,"ACTIVATE")

   LET l_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")
   LET l_desc = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","den_item")

   IF l_item IS NOT NULL THEN
      LET mr_cabec.cod_item = l_item
      #LET mr_cabec.den_item = func002_le_den_item(l_item)       
   END IF
   
   CALL _ADVPL_set_property(m_item,"GET_FOCUS")
   
END FUNCTION

#------------------------------#
FUNCTION pol1084_limpa_campos()#
#------------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_demanda TO NULL
   INITIALIZE ma_op_filha TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   CALL _ADVPL_set_property(m_brz_filha,"CLEAR")

END FUNCTION

#----------------------------------------#
FUNCTION pol1084_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status      SMALLINT
   
   CALL _ADVPL_set_property(m_panel,"EDITABLE",l_status)
   
   IF m_opcao = 'P' THEN
      CALL _ADVPL_set_property(m_item,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_it,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_ordem,"EDITABLE",l_status)
      CALL _ADVPL_set_property(m_lupa_op,"EDITABLE",l_status)
   END IF
   
END FUNCTION

#--------------------------#
FUNCTION pol1084_informar()#
#--------------------------#
      
   IF NOT pol1084_cria_tab_tmp() THEN
      RETURN FALSE
   END IF
   
   SELECT parametros
     INTO p_parametros 
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("SELECT","PAR_PCP")
      RETURN FALSE
   END IF
      
   CALL pol1084_limpa_campos() 
   LET p_ies_info = FALSE
   LET m_ies_cons = FALSE
   CALL pol1084_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
   LET m_opcao = 'I'

   RETURN TRUE 
    
END FUNCTION

#-----------------------------#
FUNCTION pol1084_info_cancel()#
#-----------------------------#

   CALL pol1084_limpa_campos()
   CALL pol1084_ativa_desativa(FALSE)
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1084_info_conf()#
#---------------------------#
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")

   IF mr_cabec.num_pedido IS NULL THEN
      IF mr_cabec.dat_ini IS NULL THEN
         LET p_msg = 'Informe a data inicial.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",p_msg)
         CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
         RETURN FALSE
      END IF

      IF mr_cabec.dat_fim IS NULL THEN
         LET p_msg = 'Informe a data final.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",p_msg)
         CALL _ADVPL_set_property(m_datfim,"GET_FOCUS")
         RETURN FALSE
      END IF
      
      IF mr_cabec.dat_ini > mr_cabec.dat_fim THEN
         LET p_msg = 'Per�odo inv�lido.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",p_msg)
         CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
         RETURN FALSE
      END IF
   END IF
   
   CALL pol1084_monta_select()
   
   LET m_count = 0
   
   LET p_status = LOG_progresspopup_start("Carregando...","pol1084_le_demanda","PROCESS") 
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET p_msg = 'N�o a demanda para os par�metros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",p_msg)
      RETURN FALSE
   END IF
   
   LET p_ies_info = TRUE
   CALL pol1084_ativa_desativa(FALSE)

   RETURN TRUE
    
END FUNCTION


#------------------------------#
FUNCTION pol1084_cria_tab_tmp()
#------------------------------#
   
   DROP TABLE ops_tmp_5000;
   CREATE TEMP TABLE ops_tmp_5000 (
      num_op INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','ops_tmp_5000')
      RETURN FALSE
   END IF
   
   DROP TABLE neces_tmp_5000
   CREATE TEMP TABLE neces_tmp_5000 (
      num_neces INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','neces_tmp_5000')
      RETURN FALSE
   END IF

   DROP TABLE ped_dem_temp;
   CREATE TEMP TABLE ped_dem_temp (
    id_registro  INTEGER NOT NULL,
    cod_empresa  CHAR(2) NOT NULL,
    num_projeto  CHAR(08) NOT NULL,
    num_pedido   DECIMAL(6,0) NOT NULL,
    num_seq      DECIMAL(3,0) NOT NULL,
    cod_item_pai CHAR(15) NOT NULL,
    num_op_pai   INTEGER,
    prz_entrega  DATE NOT NULL,
    qtd_saldo    DECIMAL(10,3) NOT NULL
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','tabela:ped_dem_temp')
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_ped_dem_temp ON 
     ped_dem_temp(cod_empresa,num_pedido,num_seq);   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','indice:ix_ped_dem_temp')
      RETURN FALSE
   END IF

   DROP TABLE ops_filha_5000;
   CREATE TEMP TABLE ops_filha_5000 (
      num_ordem      INTEGER NOT NULL,
      cod_item_pai   CHAR(15) NOT NULL
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','ops_filha_5000')
      RETURN FALSE
   END IF
     
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1084_monta_select()
#------------------------------#
   
   INITIALIZE p_query TO NULL

   LET p_query = 
       " SELECT pedidos.cod_empresa, ",
       " pedidos.num_pedido, ",
       " ped_itens.num_sequencia, ",
       " ped_itens.cod_item, ",
       " ped_itens.prz_entrega, ",
       "(ped_itens.qtd_pecas_solic  - ",
       " ped_itens.qtd_pecas_atend  - ",
       " ped_itens.qtd_pecas_cancel - ",
       " ped_itens.qtd_pecas_romaneio) ",
       " FROM pedidos, ped_itens "

   IF p_parametros[210,210] = "S" THEN
     LET p_query = p_query CLIPPED, ", nat_operacao "
   END IF

   LET p_query = p_query CLIPPED," WHERE pedidos.cod_empresa = '",p_cod_empresa,"'"

   IF p_parametros[115,115] = "S" THEN
      LET p_query = p_query CLIPPED,
          " AND pedidos.ies_sit_pedido NOT IN ('S','P','9')"
   ELSE
      LET p_query = p_query CLIPPED,
          " AND pedidos.ies_sit_pedido NOT IN ('S','B','P','9')"
   END IF

   IF p_parametros[210,210] = "S" THEN
      LET p_query = p_query CLIPPED, 
          " AND nat_operacao.cod_nat_oper = pedidos.cod_nat_oper ",
          " AND nat_operacao.cod_movto_estoq IS NOT NULL"
   END IF

   LET p_query = p_query CLIPPED,
       " AND ped_itens.cod_empresa = pedidos.cod_empresa "

   LET p_query = p_query CLIPPED,
       " AND ped_itens.num_pedido = pedidos.num_pedido "
   
   IF mr_cabec.num_pedido IS NOT NULL THEN
      LET p_query = p_query CLIPPED, ' AND pedidos.num_pedido = ', mr_cabec.num_pedido
   ELSE   
      IF p_parametros[200,200] = "I" THEN                                 
         LET p_query = p_query CLIPPED,                                   
             " AND pedidos.dat_emis_repres >= '",mr_cabec.dat_ini,"'",    
             " AND pedidos.dat_emis_repres <= '",mr_cabec.dat_fim,"'"     
      ELSE                                                                
         LET p_query = p_query CLIPPED,                                   
             " AND ped_itens.prz_entrega >= '",mr_cabec.dat_ini,"'",      
             " AND ped_itens.prz_entrega <= '",mr_cabec.dat_fim,"'"       
      END IF                                                              
                                                                          
      IF mr_cabec.ies_demanda = "N" THEN                                  
         LET p_query = p_query CLIPPED,                                   
             " AND EXISTS (SELECT cod_item FROM item_man ",               
             " WHERE item_man.cod_empresa = '",p_cod_empresa,"'",         
             " AND item_man.cod_item = ped_itens.cod_item) "              
      ELSE                                                                
         LET p_query = p_query CLIPPED,                                   
             " AND EXISTS (SELECT cod_item FROM item_man",                
             " WHERE item_man.cod_empresa = '",p_cod_empresa,"'",         
             " AND item_man.cod_item = ped_itens.cod_item",               
             " AND item_man.ies_planejamento = '1')"                      
      END IF                                                              
   END IF
   
   LET p_query = p_query CLIPPED,
       " AND ped_itens.qtd_pecas_atend = 0 AND ped_itens.qtd_pecas_romaneio = 0 "

END FUNCTION

#----------------------------#
FUNCTION pol1084_le_demanda()#
#----------------------------#

   DEFINE l_progres         SMALLINT

   LET m_count = 0
   LET m_carregando = TRUE
   CALL LOG_progresspopup_set_total("PROCESS",1000)
   
   PREPARE var_select FROM p_query
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','var_select')
      RETURN FALSE
   END IF
          
   DECLARE cq_demanda CURSOR FOR var_select

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DECLARE','DECLARE:cq_demanda')
      RETURN FALSE
   END IF
   
   FOREACH cq_demanda INTO
           p_ped_dem.cod_empresa,
           p_ped_dem.num_pedido,
           p_ped_dem.num_seq,
           p_ped_dem.cod_item_pai,
           p_ped_dem.prz_entrega,
           p_ped_dem.qtd_saldo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','FOREACH:cq_demanda')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET p_cod_item = p_ped_dem.cod_item_pai
      LET p_ped_dem.num_projeto = pol1084_le_aen()
      LET p_ped_dem.num_op_pai = NULL
      LET m_count = m_count + 1
      LET p_ped_dem.id_registro = m_count
      
      SELECT num_op_pai
        INTO p_ped_dem.num_op_pai
        FROM ped_dem_5000
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = p_ped_dem.num_pedido
         AND num_seq = p_ped_dem.num_seq

      IF STATUS = 100 THEN
         LET p_ped_dem.num_op_pai = NULL
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ped_dem_5000.num_op_pai')
            RETURN FALSE
         END IF
      END IF
       
      INSERT INTO ped_dem_temp
       VALUES(p_ped_dem.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','ped_dem_temp')
         RETURN FALSE
      END IF
            
      LET ma_demanda[m_count].den_item = pol1084_le_den_item(p_ped_dem.cod_item_pai)
      LET ma_demanda[m_count].nom_cliente = pol1084_le_nom_cliente(p_ped_dem.num_pedido)            
      LET ma_demanda[m_count].id_registro = m_count
      LET ma_demanda[m_count].num_projeto = p_ped_dem.num_projeto
      LET ma_demanda[m_count].num_pedido = p_ped_dem.num_pedido
      LET ma_demanda[m_count].num_seq = p_ped_dem.num_seq
      LET ma_demanda[m_count].cod_item = p_ped_dem.cod_item_pai
      LET ma_demanda[m_count].qtd_saldo = p_ped_dem.qtd_saldo
      LET ma_demanda[m_count].prz_entrega = p_ped_dem.prz_entrega
      LET ma_demanda[m_count].num_ordem = p_ped_dem.num_op_pai
      LET ma_demanda[m_count].ies_situa = pol1084_le_situa_op(p_ped_dem.num_op_pai)
      
   END FOREACH
   
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_count)

   IF m_count > 0 THEN
      CALL pol1084_le_op_filha(1) RETURNING p_status
   END IF
   
   LET m_carregando = FALSE
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1084_le_situa_op(l_op)#
#---------------------------------#

   DEFINE  l_ies_situa       CHAR(01),
           l_op              INTEGER

   SELECT ies_situa 
     INTO l_ies_situa 
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = l_op
      
   IF STATUS <> 0 THEN
      LET l_ies_situa = ''
   END IF
   
   RETURN l_ies_situa

END FUNCTION

#----------------------------#
FUNCTION pol1084_before_row()#
#----------------------------#

   DEFINE l_lin_atu       INTEGER
   
   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF l_lin_atu <= 0 OR l_lin_atu IS NULL THEN
      RETURN TRUE
   END IF
   
   LET p_status = pol1084_le_op_filha(l_lin_atu)
  
   RETURN p_status

END FUNCTION   

#----------------------------------#
FUNCTION pol1084_le_den_item(l_cod)#
#----------------------------------#
   DEFINE l_cod        CHAR(15),
          l_den_item   CHAR(18)
   
   SELECT den_item_reduz
     INTO l_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod
      
   IF STATUS <> 0 THEN
      LET l_den_item = NULL
   END IF
   
   RETURN l_den_item

END FUNCTION

#-------------------------------------#
FUNCTION pol1084_le_nom_cliente(l_ped)#
#-------------------------------------#
   DEFINE l_ped        INTEGER,
          l_cod_cli    CHAR(15),
          l_nom_cli    CHAR(40)
   
   SELECT cod_cliente
     INTO l_cod_cli
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = l_ped
      
   IF STATUS <> 0 THEN
      LET l_nom_cli = NULL
   ELSE
      SELECT nom_cliente
        INTO l_nom_cli FROM clientes
       WHERE cod_cliente = l_cod_cli
      IF STATUS <> 0 THEN
         LET l_nom_cli = NULL
      END IF
   END IF
   
   RETURN l_nom_cli

END FUNCTION
   
            
#------------------------#
FUNCTION pol1084_le_aen()
#------------------------#

   DEFINE p_projeto CHAR(10)
   
   SELECT cod_lin_prod,                          
          cod_lin_recei,                            
          cod_seg_merc,                             
          cod_cla_uso                               
     INTO p_cod_lin_prod,                           
          p_cod_lin_recei,                          
          p_cod_seg_merc,                           
          p_cod_cla_uso                             
     FROM item                                      
    WHERE cod_empresa = p_cod_empresa               
      AND cod_item    = p_cod_item                  
                                                 
   IF STATUS <> 0 THEN      
      LET p_projeto = NULL                        
      CALL log003_err_sql('Lendo','item:AEN')       
   ELSE                                                    
      LET p_projeto =                      
          p_cod_lin_prod  USING '&&',               
          p_cod_lin_recei USING '&&',               
          p_cod_seg_merc  USING '&&',               
          p_cod_cla_uso   USING '&&'                
   END IF
   
   RETURN(p_projeto)

END FUNCTION

#-----------------------#
FUNCTION pol1084_gerar()#
#-----------------------#
      
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")
   
   IF NOT p_ies_info THEN
      LET p_msg = 'Informe previamente os par�metros - bot�o Informar'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",p_msg)
      RETURN FALSE
   END IF
      
   LET p_msg = 'Deseja mesmo gerar ordens de produ��o\n para os pedidos da grade ?'
   
   IF NOT LOG_question(p_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Opera��o cancelada.")
      RETURN FALSE
   END IF
    
   LET p_status = LOG_progresspopup_start("Carregando...","pol1084_processa","PROCESS") 
   
   LET p_ies_info = FALSE
   
   IF p_status THEN
      LET p_msg = 'Processamento de ordens\n efetuado com sucesso.'
      CALL log0030_mensagem(p_msg,'info')
   END IF
   
   RETURN p_status
   
END FUNCTION   

#--------------------------#
FUNCTION pol1084_ins_erro()#
#--------------------------#
   
   INSERT INTO demanda_erro_5000
    VALUES(p_cod_empresa,
           p_ped_dem.num_pedido, 
           p_ped_dem.num_seq,
           p_msg, p_dat_proces)

END FUNCTION

#--------------------------#
FUNCTION pol1084_processa()#
#--------------------------#

   DEFINE l_progres         SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   LET p_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)
   
   DECLARE cq_pedidos CURSOR WITH HOLD FOR 
    SELECT * FROM ped_dem_temp

   FOREACH cq_pedidos INTO p_ped_dem.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_pedidos')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
            
      SELECT COUNT(*) INTO m_count
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND ies_situa IN ('4','5')
         AND num_ordem IN (SELECT num_ordem FROM ped_item_5000
       WHERE cod_empresa = p_cod_empresa 
         AND num_pedido = p_ped_dem.num_pedido 
         AND num_seq = p_ped_dem.num_seq)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordens / ped_item_5000')
         RETURN FALSE
      END IF

      IF m_count > 0 THEN
         LET p_msg = 'Item j� possui ordens liberadas e/ou encerradas'
         CALL pol1084_ins_erro()
         CONTINUE FOREACH
      END IF
      
      LET p_ies_roteiro = TRUE
      
      IF NOT pol1084_ve_roteiro(p_ped_dem.cod_item_pai) THEN
         RETURN FALSE
      END IF
      
      IF NOT p_ies_roteiro THEN
         LET p_msg = 'Item ',p_ped_dem.cod_item_pai CLIPPED,' n�o possui roteiro no MAN10243'
         CALL pol1084_ins_erro()
         CONTINUE FOREACH
      END IF
            
      CALL log085_transacao("BEGIN")
      
      SELECT num_op_pai,
             cod_item_pai,
             prz_entrega
        INTO p_num_ordem,
             p_cod_item,
             p_prz_entrega
        FROM ped_dem_5000
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ped_dem.num_pedido
         AND num_seq     = p_ped_dem.num_seq
      
      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','ped_dem_5000:op')
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      IF STATUS = 0 THEN

         SELECT dat_entrega,
                qtd_planej,
                ies_situa   
           INTO p_dat_entrega,
                p_qtd_planej, 
                p_ies_situa  
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_num_ordem
         
         IF STATUS = 0 THEN
            IF p_ies_situa = '3' THEN
               IF p_dat_entrega = p_ped_dem.prz_entrega AND
                  p_qtd_planej  = p_ped_dem.qtd_saldo  THEN
                  CALL log085_transacao("ROLLBACK")
                  CONTINUE FOREACH
               END IF
            END IF            
            
            IF NOT pol1084_del_ordens() THEN
               CALL log085_transacao("ROLLBACK")
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('Lendo','ordens')
               CALL log085_transacao("ROLLBACK")
               RETURN FALSE
            END IF
         END IF

         IF NOT pol1084_del_ped_dem() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
         
      END IF

      LET p_cod_item = p_ped_dem.cod_item_pai
            
      LET p_cod_item_pai = '0'
      LET m_num_neces = 0
      LET p_qtd_planej = p_ped_dem.qtd_saldo

      IF NOT pol1084_prx_num_op_nec() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
         
      IF NOT pol1084_gera_op() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF      
      
      LET p_ped_dem.num_op_pai = p_num_ordem
      
      IF NOT pol1084_ins_ped_dem() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF

      LET m_ind = p_ped_dem.id_registro
      LET ma_demanda[m_ind].num_ordem = p_num_ordem
      
      IF NOT pol1084_ord_filhas() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF

      IF NOT pol1084_atu_par_pcp() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      CALL log085_transacao("COMMIT")
      
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1084_atu_par_pcp()#
#-----------------------------#

   UPDATE par_mrp
      SET prx_num_neces = p_num_neces,
          prx_num_ordem = p_num_ordem
    WHERE cod_empresa   = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','par_mrp')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1084_del_ordens()
#----------------------------#

   IF NOT pol1084_ins_op() THEN
      RETURN FALSE
   END IF
   
   LET p_count = 1
      
   WHILE p_count > 0

      DECLARE cq_temp_op CURSOR FOR
       SELECT num_op FROM ops_tmp_5000
      
      FOREACH cq_temp_op INTO p_num_ordem
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_ops')  
            RETURN FALSE
         END IF
         
         DECLARE cq_le_neces CURSOR FOR
          SELECT num_neces 
            FROM necessidades
           WHERE cod_empresa = p_cod_empresa
             AND num_ordem   = p_num_ordem
         
         FOREACH cq_le_neces INTO p_num_neces

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','cq_ops')  
               RETURN FALSE
            END IF
            
            IF NOT pol1084_ins_neces_tmp() THEN
               RETURN FALSE
            END IF
         
         END FOREACH

         IF NOT pol1084_del_tabs() THEN
            RETURN FALSE
         END IF
                  
      END FOREACH
      
      IF NOT pol1084_del_ops_tmp() THEN
         RETURN FALSE
      END IF
      
      LET p_count = 0
      
      DECLARE cq_neces_temp CURSOR FOR
       SELECT num_neces FROM neces_tmp_5000
      
      FOREACH cq_neces_temp INTO p_num_neces

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_neces_temp')  
            RETURN FALSE
         END IF
      
         SELECT num_ordem
           INTO p_num_ordem
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_neces   = p_num_neces

         IF STATUS = 0 THEN
            IF NOT pol1084_ins_op() THEN
               RETURN FALSE
            END IF
            LET p_count = 1
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('Lendo','cq_neces_temp')  
               RETURN FALSE
            END IF
         END IF
         
      END FOREACH

      IF NOT pol1084_del_neces_tmp() THEN
         RETURN FALSE
      END IF
      
   END WHILE
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1084_del_neces_tmp()
#------------------------------#

   DELETE FROM neces_tmp_5000
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','neces_tmp_5000')  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1084_del_ops_tmp()
#------------------------------#

   DELETE FROM ops_tmp_5000 
                  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ops_tmp_5000')  
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1084_ins_neces_tmp()
#------------------------------#

   INSERT INTO neces_tmp_5000 VALUES(p_num_neces)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','neces_tmp_5000')  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1084_ins_op()
#------------------------#

   INSERT INTO ops_tmp_5000 VALUES(p_num_ordem)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ops_tmp_5000')  
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1084_del_tabs()
#--------------------------#
 
   DELETE FROM ordens 
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordens')  
      RETURN FALSE
   END IF
   
   DELETE FROM ordens_complement
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordens_complement')  
      RETURN FALSE
   END IF

   DELETE FROM neces_complement
    WHERE cod_empresa = p_cod_empresa 
      AND num_neces IN (SELECT num_neces FROM necessidades
                         WHERE cod_empresa = p_cod_empresa 
                           AND num_ordem   = p_num_ordem)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELETE","neces_complement")
      RETURN FALSE
   END IF           
   
   DELETE FROM necessidades 
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','necessidades')  
      RETURN FALSE
   END IF

   DELETE FROM ord_compon 
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ord_compon')  
      RETURN FALSE
   END IF

   DELETE FROM  man_recurso_operacao_ordem                     
    WHERE empresa = p_cod_empresa                                      
      AND seq_processo IN                                              
      (SELECT seq_processo FROM ord_oper                               
        WHERE cod_empresa = p_cod_empresa                              
          AND num_ordem   = p_num_ordem)                               
                                                               
   IF STATUS <> 0 THEN                                                 
     CALL log003_err_sql("DELETE","man_recurso_operacao_ordem")        
     RETURN FALSE                                                      
   END IF                                                              
                                                                       
   DELETE FROM ord_oper
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ord_oper')  
      RETURN FALSE
   END IF


   DELETE FROM man_oper_compl 
    WHERE empresa = p_cod_empresa
      AND ordem_producao = p_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','man_oper_compl')  
      RETURN FALSE
   END IF

   DELETE FROM man_op_componente_operacao 
    WHERE empresa = p_cod_empresa
      AND ordem_producao = p_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','man_op_componente_operacao')  
      RETURN FALSE
   END IF

   DELETE FROM ord_oper_txt 
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ord_oper_txt')  
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
   
 
#-----------------------------#
FUNCTION pol1084_del_ped_dem()
#-----------------------------#

   LET p_ped_dem.num_projeto = pol1084_le_aen()
      
   IF p_ped_dem.num_projeto IS NULL THEN
      RETURN FALSE
   END IF

   DELETE FROM ped_dem
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_dem.num_projeto
      AND cod_item    = p_cod_item
      AND prz_entrega = p_prz_entrega

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ped_dem')
      RETURN FALSE
   END IF

   DELETE FROM ped_dem_5000
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_dem.num_pedido
      AND num_seq     = p_ped_dem.num_seq
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ped_dem_5000')
      RETURN FALSE
   END IF
   
   IF NOT pol1084_del_ped_item() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1084_ins_ped_dem()
#-----------------------------#

   INSERT INTO ped_dem_5000
       VALUES(p_ped_dem.cod_empresa,
              p_ped_dem.num_projeto,
              p_ped_dem.num_pedido,
              p_ped_dem.num_seq,
              p_ped_dem.cod_item_pai,
              p_ped_dem.num_op_pai,
              p_ped_dem.prz_entrega,
              p_ped_dem.qtd_saldo)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ped_dem_5000')
      RETURN FALSE
   END IF

   SELECT cod_empresa
     FROM ped_dem
    WHERE cod_empresa = p_ped_dem.cod_empresa
      AND num_pedido  = p_ped_dem.num_projeto
      AND cod_item    = p_ped_dem.cod_item_pai
      AND prz_entrega = p_ped_dem.prz_entrega

   IF STATUS = 100 THEN
      INSERT INTO ped_dem
       VALUES(p_ped_dem.cod_empresa,
              p_ped_dem.num_projeto,
              p_ped_dem.cod_item_pai,
              p_ped_dem.prz_entrega,
              p_ped_dem.qtd_saldo)
   ELSE
      IF STATUS = 0 THEN
         UPDATE ped_dem
            SET qtd_saldo = p_ped_dem.qtd_saldo
          WHERE cod_empresa = p_ped_dem.cod_empresa
            AND num_pedido  = p_ped_dem.num_projeto
            AND cod_item    = p_ped_dem.cod_item_pai
            AND prz_entrega = p_ped_dem.prz_entrega
      ELSE
         CALL log003_err_sql('Lendo','ped_dem')
         RETURN FALSE
      END IF
   END IF
                  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','ped_dem')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1084_ins_ped_item()
#-----------------------------#
   
   INSERT INTO ped_item_5000
       VALUES(p_ped_dem.cod_empresa,
              p_ped_dem.num_pedido,
              p_ped_dem.num_seq,
              m_num_ordem)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('inserindo','ped_item_5000')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1084_del_ped_item()
#-----------------------------#
   
   DELETE FROM ped_item_5000
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = p_ped_dem.num_pedido
         AND num_seq =  p_ped_dem.num_seq
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('deletando','ped_item_5000')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1084_ve_roteiro(l_item)#
#----------------------------------#

   DEFINE l_item        LIKE item.cod_item
   
   LET p_dat_atu = TODAY
   
   SELECT cod_roteiro, num_altern_roteiro
     INTO p_item_man.cod_roteiro,
          p_item_man.num_altern_roteiro
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = l_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_man')
      RETURN FALSE
   END IF
   
   SELECT COUNT(*) INTO m_count
     FROM man_processo_item
    WHERE empresa         = p_cod_empresa
      AND item            = l_item
      AND roteiro         = p_item_man.cod_roteiro
      AND roteiro_alternativo  = p_item_man.num_altern_roteiro
      AND ((validade_inicial IS NULL AND validade_final IS NULL)
       OR  (validade_inicial IS NULL AND validade_final >= p_dat_atu)
       OR  (validade_final IS NULL AND validade_inicial <= p_dat_atu)
       OR  (p_dat_atu BETWEEN validade_inicial AND validade_final))
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','man_processo_item')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET p_ies_roteiro = FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1084_le_item_man()
#-----------------------------#

   SELECT *
     INTO p_item_man.*
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_man')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1084_le_horizonte()
#------------------------------#

   SELECT qtd_dias_horizon
     INTO p_qtd_dias_horizon
     FROM horizonte
    WHERE cod_empresa = p_cod_empresa
      AND cod_horizon = p_item_man.cod_horizon

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','horizonte')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1084_le_item()
#-------------------------#

   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:local')
      RETURN FALSE
   END IF

   IF p_cod_local_estoq IS NULL THEN
      LET p_cod_local_estoq = ' ' 
   END IF
   
  RETURN TRUE
  
END FUNCTION

#------------------------#
FUNCTION pol1084_gera_op()
#------------------------#

   IF NOT pol1084_ins_ordem() THEN
      RETURN FALSE
   END IF

   LET p_num_ordem = p_num_ordem + 1
   
   IF NOT pol1084_ins_necessidades() THEN
      RETURN FALSE
   END IF

   IF NOT pol1084_ins_roteiro() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol1084_prx_num_op_nec()#
#---------------------------------#
   
   DECLARE cq_prende CURSOR FOR
   SELECT prx_num_ordem, prx_num_neces
    FROM par_mrp
   WHERE cod_empresa = p_cod_empresa
     FOR UPDATE 

    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','par_mrp:OPEN')
       RETURN FALSE
    END IF
    
   FETCH cq_prende INTO p_num_ordem, p_num_neces

      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_mrp:FETCH')
      CLOSE cq_prende
      RETURN FALSE
   END IF

   IF p_num_neces IS NULL THEN
      LET p_num_neces = 0
   END IF

   IF p_num_ordem IS NULL THEN
      LET p_num_ordem = 0
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1084_ins_ordem()
#---------------------------#

   DEFINE p_op_compl RECORD LIKE ordens_complement.*
   
   IF NOT pol1084_le_item_man() THEN
      RETURN FALSE
   END IF

   #IF NOT pol1084_le_horizonte() THEN
   #   RETURN FALSE
   #END IF

   #IF NOT pol1084_le_horizonte() THEN
   #   RETURN FALSE
   #END IF

   IF NOT pol1084_le_item() THEN
      RETURN FALSE
   END IF
   
   IF p_cod_item_pai = '0' THEN
      LET p_cod_local_estoq = p_ped_dem.num_projeto
      LET p_cod_local_prod = p_ped_dem.num_projeto
   ELSE
      LET p_cod_local_prod = p_item_man.cod_local_prod
   END IF
   
   LET p_num_lote = p_ped_dem.num_pedido 
   LET p_num_lote = p_num_lote CLIPPED, '/'
   LET p_txt_aux  = p_ped_dem.num_seq
   LET p_num_lote = p_num_lote CLIPPED, p_txt_aux
   LET p_dat_liberac = TODAY #p_ped_dem.prz_entrega - p_item_man.tmp_ressup
   LET p_dat_abertura = TODAY #p_dat_liberac - p_qtd_dias_horizon
      
   INITIALIZE p_ordens TO NULL

   LET p_ordens.cod_empresa        = p_cod_empresa
   LET p_ordens.num_ordem          = p_num_ordem
   LET p_ordens.num_neces          = m_num_neces
   LET p_ordens.num_versao         = 0
   LET p_ordens.cod_item           = p_cod_item
   LET p_ordens.cod_item_pai       = p_cod_item_pai
   LET p_ordens.dat_entrega        = p_ped_dem.prz_entrega
   LET p_ordens.dat_liberac        = p_dat_liberac
   LET p_ordens.dat_abert          = p_dat_abertura 
   LET p_ordens.qtd_planej         = p_qtd_planej
   LET p_ordens.pct_refug          = 0
   LET p_ordens.qtd_boas           = 0
   LET p_ordens.qtd_refug          = 0
   LET p_ordens.qtd_sucata         = 0
   LET p_ordens.cod_local_prod     = p_cod_local_prod 
   LET p_ordens.cod_local_estoq    = p_cod_local_estoq 
   LET p_ordens.num_docum          = p_ped_dem.num_projeto
   LET p_ordens.ies_lista_ordem    = p_item_man.ies_lista_ordem
   LET p_ordens.ies_lista_roteiro  = p_item_man.ies_lista_roteiro
   LET p_ordens.ies_origem         = '1'
   LET p_ordens.ies_situa          = '3'
   LET p_ordens.ies_abert_liber    = p_item_man.ies_abert_liber
   LET p_ordens.ies_baixa_comp     = p_item_man.ies_baixa_comp
   LET p_ordens.ies_apontamento    = p_item_man.ies_apontamento
   LET p_ordens.dat_atualiz        = TODAY
   LET p_ordens.num_lote           = p_num_lote
   LET p_ordens.cod_roteiro        = p_item_man.cod_roteiro
   LET p_ordens.num_altern_roteiro = p_item_man.num_altern_roteiro

   INSERT INTO ordens VALUES (p_ordens.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','Ordens')
      RETURN FALSE
   END IF

   INITIALIZE p_op_compl  TO NULL

   LET p_op_compl.cod_empresa    = p_ordens.cod_empresa
   LET p_op_compl.num_ordem      = p_ordens.num_ordem
   LET p_op_compl.cod_grade_1    = " "
   LET p_op_compl.cod_grade_2    = " "
   LET p_op_compl.cod_grade_3    = " "
   LET p_op_compl.cod_grade_4    = " "
   LET p_op_compl.cod_grade_5    = " "
   LET p_op_compl.num_lote       = p_ordens.num_lote
   LET p_op_compl.ies_tipo       = "N"
   LET p_op_compl.num_prioridade = 9999
   LET p_op_compl.ordem_producao_pai = NULL #essa n�o tem pai

   INSERT INTO ordens_complement VALUES (p_op_compl.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','ordens_complement')
      RETURN  FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1084_ins_necessidades()
#-------------------------------------#

   DEFINE p_cod_item_compon LIKE estrutura.cod_item_compon, 
          p_qtd_necessaria  LIKE estrutura.qtd_necessaria,  
          p_pct_refug       LIKE estrutura.pct_refug,
          p_tem_strut       SMALLINT,
          l_num_sequen      INTEGER

   INITIALIZE p_necessidades TO NULL     

   LET p_necessidades.cod_empresa      = p_ordens.cod_empresa                   
   LET p_necessidades.num_versao       = p_ordens.num_versao                    
   LET p_necessidades.cod_item_pai     = p_ordens.cod_item                      
   LET p_necessidades.num_ordem        = p_ordens.num_ordem                     
   LET p_necessidades.qtd_saida        = 0                                      
   LET p_necessidades.num_docum        = p_ordens.num_docum                     
   LET p_necessidades.dat_neces        = p_ordens.dat_entrega                   
   LET p_necessidades.ies_origem       = p_ordens.ies_origem                    
   LET p_necessidades.ies_situa        = p_ordens.ies_situa                     
  
   LET p_tem_strut = FALSE           
   LET p_cod_cent_trab = p_ordens.cod_local_prod
   
   DECLARE cq_estrut CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           pct_refug,
           num_sequencia
      FROM estrut_grade
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_cod_item
       AND (dat_validade_ini IS NULL OR dat_validade_ini <= p_dat_liberac) 
       AND (dat_validade_fim IS NULL OR dat_validade_fim >= p_dat_liberac) 
     ORDER BY num_sequencia

   FOREACH cq_estrut INTO 
           p_cod_item_compon, 
           p_qtd_necessaria,  
           p_pct_refug,
           l_num_sequen       
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estrut_grade:cq_estrut')
         RETURN FALSE
      END IF
      
      LET p_tem_strut = TRUE
      LET p_num_neces = p_num_neces + 1
      LET p_necessidades.num_neces        = p_num_neces                                                                                                                 
      LET p_necessidades.cod_item         = p_cod_item_compon                      
      LET p_necessidades.qtd_necessaria   = p_ordens.qtd_planej * p_qtd_necessaria 
      LET p_necessidades.num_neces_consol = 0                                      

      INSERT INTO necessidades  VALUES (p_necessidades.*)                          
                                                                                   
      IF STATUS <> 0 THEN                                                   
         CALL log003_err_sql('Inserindo','Necessidades')                           
         RETURN FALSE                                                              
      END IF         

      INSERT INTO neces_complement (
        cod_empresa, 
        num_neces, 
        cod_grade_1, 
        cod_grade_2, 
        cod_grade_3, 
        cod_grade_4, 
        cod_grade_5, 
        ordem_producao_pai,
        sequencia_it_operacao, 
        seq_processo) 
      VALUES(p_cod_empresa, p_necessidades.num_neces ,' ',' ',' ',' ',' ',NULL, 0, 0)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','neces_complement')  
         RETURN FALSE
      END IF

      SELECT ies_tip_item
        INTO p_ies_tip_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item_compon
         
      IF STATUS <> 0 THEN                                                   
         CALL log003_err_sql('Lendo','item:tipo')                           
         RETURN FALSE                                                              
      END IF         

      IF p_ordens.ies_baixa_comp  = "1" THEN
         LET p_cod_local_baixa  = p_ordens.cod_local_prod
      ELSE
         LET p_cod_local_baixa  = p_ordens.cod_local_estoq
      END IF
        
      INSERT INTO ord_compon(
         cod_empresa,      
         num_ordem,        
         cod_item_pai,     
         cod_item_compon,  
         ies_tip_item,     
         dat_entrega,      
         qtd_necessaria,   
         cod_local_baixa,  
         cod_cent_trab,    
         pct_refug) VALUES(  
                     p_necessidades.cod_empresa,
                     p_necessidades.num_ordem,
                     p_necessidades.num_neces,
                     p_necessidades.cod_item,
                     p_ies_tip_item,
                     p_necessidades.dat_neces,
                     p_qtd_necessaria,
                     p_cod_local_baixa,
                     p_cod_cent_trab,
                     p_pct_refug)
   
      IF STATUS <> 0 THEN                                                   
         CALL log003_err_sql('Inserindo','Necessidades')                           
         RETURN FALSE                                                              
      END IF         
         
   END FOREACH       

   IF NOT p_tem_strut THEN
      LET p_msg = 'Item ', p_cod_item CLIPPED, ' sem estrutura!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1084_ins_roteiro()
#-----------------------------#

   DEFINE p_tem_roteiro   SMALLINT,
          p_seq_comp      DECIMAL(10,0),
          l_num_seq       INTEGER,
          l_seq_processo  INTEGER,
          l_parametro     CHAR(07),
          l_seq_texto     CHAR(20),
          l_tipo          CHAR(01),
          l_linha         INTEGER,
          l_texto         CHAR(70),
          l_seq_comp      INTEGER,       
          l_compon        CHAR(15),          
          l_qtd_neces     DECIMAL(10,3),     
          l_pct_refugo    DECIMAL(5,2),      
          l_ies_tip_item  CHAR(01)           
          
   DEFINE lr_recurso RECORD LIKE man_recurso_processo.*

   DEFINE lr_man_estrut_oper  RECORD
   			  empresa             char(2),
			    item_componente     char(15),
			    ies_tip_item        char(01),
			    qtd_necess          decimal(14,7),
			    pct_refugo          decimal(6,3),
			    parametro_geral     char(20)
   END RECORD
   
   LET p_tem_roteiro = FALSE
   LET p_cod_cent_trab = NULL

   INITIALIZE p_ord_oper.* TO NULL
   
   LET p_ord_oper.cod_empresa   = p_cod_empresa        
   LET p_ord_oper.num_ordem     = p_ordens.num_ordem      
   LET p_ord_oper.cod_item      = p_ordens.cod_item       
   LET p_ord_oper.dat_entrega   = p_ordens.dat_entrega    
   LET p_ord_oper.dat_inicio    = p_ordens.dat_ini        
   LET p_ord_oper.qtd_planejada = p_ordens.qtd_planej     
   LET p_ord_oper.qtd_boas      = p_ordens.qtd_boas       
   LET p_ord_oper.qtd_refugo    = p_ordens.qtd_refug      
   LET p_ord_oper.qtd_sucata    = p_ordens.qtd_sucata      
   
   DECLARE cq_roteiro CURSOR FOR 
    SELECT seq_operacao,
           operacao,
           centro_trabalho,
           arranjo,
           centro_custo,
           qtd_tempo,
           qtd_tempo_setup,
           seq_processo,
           apontar_operacao,
           imprimir_operacao,
           operacao_final,
           pct_retrabalho,
           qtd_tempo
      FROM man_processo_item
        WHERE empresa         = p_cod_empresa
          AND item            = p_ordens.cod_item
          AND roteiro         = p_ordens.cod_roteiro
          AND roteiro_alternativo  = p_ordens.num_altern_roteiro
          AND ((validade_inicial IS NULL AND validade_final IS NULL)
           OR  (validade_inicial IS NULL AND validade_final >= p_dat_liberac)
           OR  (validade_final IS NULL AND validade_inicial <= p_dat_liberac)
           OR  (p_dat_liberac BETWEEN validade_inicial AND validade_final))
      
   FOREACH cq_roteiro INTO 
           p_ord_oper.num_seq_operac,
           p_ord_oper.cod_operac,
           p_ord_oper.cod_cent_trab,
           p_ord_oper.cod_arranjo,
           p_ord_oper.cod_cent_cust,
           p_ord_oper.qtd_horas,
           p_ord_oper.qtd_horas_setup,
           l_seq_processo,
           p_ord_oper.ies_apontamento,
           p_ord_oper.ies_impressao,
           p_ord_oper.ies_oper_final,
           p_ord_oper.pct_refug,
           p_ord_oper.tmp_producao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_roteiro')
         RETURN FALSE
      END IF
      
      LET l_parametro = l_seq_processo USING '<<<<<<<'
      LET p_ord_oper.num_processo = l_parametro
      
      LET p_tem_roteiro = TRUE
      LET p_cod_cent_trab = p_ord_oper.cod_cent_trab
      LET p_ord_oper.seq_processo = 0
                               
      INSERT INTO ord_oper(
         cod_empresa,      
         num_ordem,        
         cod_item,         
         cod_operac,       
         num_seq_operac,   
         cod_cent_trab,    
         cod_arranjo,      
         cod_cent_cust,    
         dat_entrega,      
         dat_inicio,       
         qtd_planejada,    
         qtd_boas,         
         qtd_refugo,       
         qtd_sucata,       
         qtd_horas,        
         qtd_horas_setup,  
         ies_apontamento,  
         ies_impressao,    
         ies_oper_final,   
         pct_refug,        
         tmp_producao,     
         num_processo)     
            VALUES(p_ord_oper.cod_empresa,    
                   p_ord_oper.num_ordem,      
                   p_ord_oper.cod_item,       
                   p_ord_oper.cod_operac,     
                   p_ord_oper.num_seq_operac, 
                   p_ord_oper.cod_cent_trab,  
                   p_ord_oper.cod_arranjo,    
                   p_ord_oper.cod_cent_cust,  
                   p_ord_oper.dat_entrega,    
                   p_ord_oper.dat_inicio,     
                   p_ord_oper.qtd_planejada,  
                   p_ord_oper.qtd_boas,       
                   p_ord_oper.qtd_refugo,     
                   p_ord_oper.qtd_sucata,     
                   p_ord_oper.qtd_horas,      
                   p_ord_oper.qtd_horas_setup,
                   p_ord_oper.ies_apontamento,
                   p_ord_oper.ies_impressao,  
                   p_ord_oper.ies_oper_final, 
                   p_ord_oper.pct_refug,      
                   p_ord_oper.tmp_producao,   
                   p_ord_oper.num_processo)                      
                    
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','ord_oper')
         RETURN FALSE
      END IF
      
      LET l_num_seq = SQLCA.SQLERRD[2]

      DECLARE cq_recurso CURSOR FOR                                                        
       SELECT *                                                                               
         FROM man_recurso_processo                                                            
        WHERE empresa = p_cod_empresa                                                         
          AND seq_processo = l_seq_processo                                                   
      FOREACH cq_recurso INTO lr_recurso.*                                                    
                                                                                              
        IF STATUS <> 0 THEN                                                                   
           CALL log003_err_sql('FOREACH','cq_recurso')       
           RETURN FALSE                                                                       
        END IF                                                                                
                                                                                              
        LET lr_recurso.seq_processo = l_num_seq                                               
                                                                                              
        INSERT INTO man_recurso_operacao_ordem                                                
        VALUES(lr_recurso.*)                                                                  
                                                                                           
        IF STATUS <> 0 THEN                                                                   
           CALL log003_err_sql('Inserindo','man_recurso_operacao_ordem')     
           RETURN FALSE                                                                       
        END IF                                                                                
                                                                                              
      END FOREACH                                                                             
      
      SELECT empresa 
        FROM man_oper_compl
       WHERE empresa = p_cod_empresa
         AND ordem_producao = p_ord_oper.num_ordem
         AND operacao = p_ord_oper.cod_operac
         AND sequencia_operacao = p_ord_oper.num_seq_operac
      
      IF STATUS = 100 THEN        
         INSERT INTO man_oper_compl(
            empresa,
            ordem_producao,
            operacao,
            sequencia_operacao)
         VALUES (p_cod_empresa,
                 p_ord_oper.num_ordem,
                 p_ord_oper.cod_operac,
                 p_ord_oper.num_seq_operac)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','man_oper_compl')
            RETURN FALSE
         END IF
      END IF

      DECLARE cq_cons_txt CURSOR FOR
       SELECT tip_texto,                                                                          
              seq_texto_processo,                                                                 
              texto_processo[1,70]                                                                  
         FROM man_texto_processo                                                                    
        WHERE empresa  = p_cod_empresa                                                              
          AND seq_processo = l_seq_processo                                           
                                                                                                     
      FOREACH cq_cons_txt INTO l_tipo, l_linha, l_texto                                             
                                                                                                     
         IF STATUS <> 0 THEN                                                                      
            CALL log003_err_sql('FOREACH','cq_cons_txt')            
            RETURN FALSE                                                                            
         END IF                                                                                     
                                                                                                    
         INSERT INTO ord_oper_txt                                                                   
           VALUES (p_cod_empresa,                                                                    
                   p_ord_oper.num_ordem,                                                              
                   l_parametro,                                                                      
                   l_tipo,                                                                           
                   l_linha,                                                                          
                   l_texto,NULL)                                                                     
                                                                                                     
         IF STATUS <> 0  THEN                                                              
            CALL log003_err_sql('INSERT','ord_oper_txt')   
            RETURN FALSE                                                                         
         END IF                                                                                  
                                                                                                     
      END FOREACH                                                                                   
         
      DECLARE cq_estr_oper CURSOR WITH HOLD FOR                                                           
       SELECT seq_componente,                                                                                
              item_componente,                                                                               
              qtd_necessaria,                                                                                
              pct_refugo                                                                                     
         FROM man_estrutura_operacao                                                                         
        WHERE empresa      = p_cod_empresa                                                                   
          AND item_pai     = p_ord_oper.cod_item                                                         
          AND seq_processo = l_seq_processo                                                    
                                                                                                          
      FOREACH cq_estr_oper INTO l_seq_comp, l_compon, l_qtd_neces, l_pct_refugo                                   
                                                                                                          
         IF STATUS <> 0 THEN                                                                                 
            CALL log003_err_sql('FOREACH','cq_estr_oper')                   
            RETURN FALSE                                                                                     
         END IF                                                                                              
                                                                                                             
         SELECT ies_tip_item                                                                                 
           INTO l_ies_tip_item                                                                               
           FROM item                                                                                         
          WHERE cod_empresa = p_cod_empresa                                                                  
            AND cod_item = l_compon                                                                          
                                                                                                             
         IF STATUS <> 0 THEN                                                                                 
            CALL log003_err_sql('SELECT','item:cq_estr_oper')                                        
            RETURN FALSE                                                                                     
         END IF                                                                                              

         SELECT num_neces INTO l_seq_comp FROM necessidades
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem = p_ordens.num_ordem
            AND cod_item_pai = p_ord_oper.cod_item
            AND cod_item = l_compon
                                                    
         INSERT INTO man_op_componente_operacao                                                               
          VALUES (p_cod_empresa,                                                                              
                  p_ordens.num_ordem,                                                                        
                  p_ordens.cod_roteiro ,                                                                     
                  p_ordens.num_altern_roteiro,                                                               
                  p_ord_oper.num_seq_operac,                                                     
                  p_ord_oper.cod_item,                                                                   
                  l_compon,                                                                                   
                  l_ies_tip_item,                                                                             
                  p_ordens.dat_entrega,                                                                      
                  l_qtd_neces,                                                                                
                  p_cod_local_baixa,                                                                   
                  p_ord_oper.cod_cent_trab,                                                                                  
                  l_pct_refugo,                                                                               
                  l_seq_comp,                                                                                      
                  l_num_seq)                             
                                                                                                             
         IF STATUS <> 0 THEN                                                                          
            CALL log003_err_sql('Inserindo','man_op_componente_operacao') 
            RETURN FALSE                                                                                     
         END IF                                                                                              
                                                                                                             
      END FOREACH                                                                                            

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1084_op_filha_ins()#
#------------------------------#

   INSERT INTO ops_filha_5000
    VALUES(m_num_ordem, p_cod_item)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ops_filha_5000')
      RETURN FALSE
   END IF

   IF NOT pol1084_ins_ped_item() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1084_limpa_ops()#
#---------------------------#

   DELETE FROM ops_filha_5000
   
   SELECT COUNT(*) INTO m_count
    FROM ops_filha_5000
    
   IF m_count > 0 THEN
      LET p_msg = 'N�o foi possivel limpar a tabela ops_filha_5000'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
     
#----------------------------#    
FUNCTION pol1084_ord_filhas()#
#----------------------------#
   
   IF NOT pol1084_limpa_ops() THEN
      RETURN FALSE
   END IF

   LET m_num_ordem = p_num_ordem

   IF NOT pol1084_op_filha_ins() THEN
      RETURN FALSE
   END IF
   
   LET p_count = 1
      
   WHILE p_count > 0
      
      LET p_count = 0
            
      DECLARE cq_op_tmp CURSOR FOR
       SELECT num_ordem, cod_item_pai
         FROM ops_filha_5000
      
      FOREACH cq_op_tmp INTO m_num_ordem, p_cod_item_pai
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_op_tmp')  
            RETURN FALSE
         END IF
         
         DELETE FROM ops_filha_5000 
          WHERE num_ordem = m_num_ordem

         IF STATUS <> 0 THEN
            CALL log003_err_sql('DELETE','ops_filha_5000')  
            RETURN FALSE
         END IF
         
         DECLARE cq_neces_op CURSOR FOR
          SELECT n.num_neces,
                 n.qtd_necessaria,
                 o.cod_item_compon                  
            FROM necessidades n, ord_compon o
           WHERE n.cod_empresa = p_cod_empresa
             AND n.num_ordem   = m_num_ordem
             AND o.cod_empresa = n.cod_empresa
             AND o.num_ordem = n.num_ordem
             AND o.cod_item_pai = n.num_neces
             AND o.ies_tip_item IN ('P','F')
         
         FOREACH cq_neces_op INTO m_num_neces, 
            p_qtd_planej, p_cod_item

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','cq_ops')  
               RETURN FALSE
            END IF

            LET p_ies_roteiro = TRUE
      
            IF NOT pol1084_ve_roteiro(p_cod_item) THEN
               RETURN FALSE
            END IF
      
            IF NOT p_ies_roteiro THEN
               LET p_msg = 'Item ',p_cod_item CLIPPED,' n�o possui roteiro no MAN10243'
               CALL pol1084_ins_erro()
               CONTINUE FOREACH
            END IF

            LET p_count = 1
               
            IF NOT pol1084_gera_op() THEN
               RETURN FALSE
            END IF
            
            LET m_num_ordem = p_num_ordem
            
            IF NOT pol1084_op_filha_ins() THEN
               RETURN FALSE
            END IF
         
         END FOREACH
                  
      END FOREACH
      
   END WHILE

   RETURN TRUE

END FUNCTION




#Rotinas para pesquisa de 
#demandas j� processadas

#---------------------------#
FUNCTION pol1084_pesquisar()#
#---------------------------#
   
   LET m_opcao = 'P'
   CALL pol1084_limpa_campos() 
   LET p_ies_info = FALSE
   LET m_ies_cons = FALSE
   CALL pol1084_ativa_desativa(TRUE)
   CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1084_pesq_cancel()#
#-----------------------------#

   CALL pol1084_limpa_campos()
   CALL pol1084_ativa_desativa(FALSE)
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1084_pesq_conf()#
#---------------------------#
    
   INITIALIZE p_query TO NULL

   LET p_query = 
       " SELECT num_projeto, num_pedido, num_seq, cod_item_pai, ",
       "  qtd_saldo, prz_entrega, num_op_pai FROM ped_dem_5000 ",
       " WHERE cod_empresa = '",p_cod_empresa,"'"
       
   IF mr_cabec.dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND prz_entrega >= '",mr_cabec.dat_ini,"'"
   END IF      

   IF mr_cabec.dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND prz_entrega <= '",mr_cabec.dat_fim,"'"
   END IF      

   IF mr_cabec.num_pedido IS NOT NULL THEN
      LET p_query = p_query CLIPPED, ' AND num_pedido = ', mr_cabec.num_pedido
   END IF
   
   IF mr_cabec.cod_item IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND cod_item_pai = '",mr_cabec.cod_item,"'"
   END IF      

   IF mr_cabec.num_ordem IS NOT NULL THEN
      LET p_query = p_query CLIPPED, ' AND num_op_pai = ', mr_cabec.num_ordem
   END IF
   
   LET m_ind = 0
   
   LET p_status = LOG_progresspopup_start("Carregando...","pol1084_consulta","PROCESS") 
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   IF m_ind = 0 THEN
      LET p_msg = 'N�o a dados para os par�metros informados'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",p_msg)
      RETURN FALSE
   END IF
   
   LET m_ies_cons = TRUE
   CALL pol1084_ativa_desativa(FALSE)

END FUNCTION

#--------------------------#
FUNCTION pol1084_consulta()#
#--------------------------#

   DEFINE l_progres         SMALLINT,
          l_empresa         CHAR(02)

   LET m_ind = 1
   LET m_carregando = TRUE
   CALL LOG_progresspopup_set_total("PROCESS",1000)

   PREPARE var_cons FROM p_query
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','var_cons')
      RETURN FALSE
   END IF
          
   DECLARE cq_cons CURSOR FOR var_cons

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DECLARE','DECLARE:cq_cons')
      RETURN FALSE
   END IF

   FOREACH cq_cons INTO        
       ma_demanda[m_ind].num_projeto,
       ma_demanda[m_ind].num_pedido, 
       ma_demanda[m_ind].num_seq,
       ma_demanda[m_ind].cod_item,      
       ma_demanda[m_ind].qtd_saldo,
       ma_demanda[m_ind].prz_entrega,
       ma_demanda[m_ind].num_ordem

       IF STATUS <> 0 THEN
          CALL log003_err_sql("FOREACH","FOREACH:cq_cons")
          RETURN FALSE
       END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")

      LET ma_demanda[m_ind].den_item = pol1084_le_den_item(ma_demanda[m_ind].cod_item)
      LET ma_demanda[m_ind].ies_situa = pol1084_le_situa_op(ma_demanda[m_ind].num_ordem)
       
      LET m_ind = m_ind + 1
      
      IF m_ind > 2000 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(p_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH

   IF m_ind = 1 THEN
      LET p_msg = 'N�o h� dados para os par�metros informados.'
      CALL log0030_mensagem(p_msg,'info')
   END IF
     
   LET m_ind = m_ind - 1
      
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_ind)
   
   IF m_ind > 0 THEN
      CALL pol1084_le_op_filha(1) RETURNING p_status
   END IF
   
   LET m_carregando = FALSE
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1084_le_op_filha(l_index)#
#------------------------------------#

   DEFINE l_index       INTEGER,
          l_ind         INTEGER
   
   LET l_ind = 1
   
   INITIALIZE ma_op_filha TO NULL
   CALL _ADVPL_set_property(m_brz_filha,"CLEAR")
   
   DECLARE cq_op_filha CURSOR FOR
    SELECT o.num_ordem, o.ies_situa, o.cod_item,
           o.qtd_planej, o.dat_entrega
      FROM ordens o, ped_item_5000 p
     WHERE o.cod_empresa = p_cod_empresa
       AND o.cod_empresa = p.cod_empresa
       AND o.num_ordem = p.num_ordem
       AND p.num_pedido = ma_demanda[l_index].num_pedido
       AND p.num_seq = ma_demanda[l_index].num_seq
       AND o.cod_item_pai <> '0'
   
   FOREACH cq_op_filha INTO 
      ma_op_filha[l_ind].num_ordem,   
      ma_op_filha[l_ind].ies_situa,   
      ma_op_filha[l_ind].cod_item,    
      ma_op_filha[l_ind].qtd_planej,  
      ma_op_filha[l_ind].dat_entrega 

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_op_filha')
         RETURN FALSE
      END IF
          
      LET ma_op_filha[l_ind].den_item = 
           pol1084_le_den_item(ma_op_filha[l_ind].cod_item)
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 50 THEN
         LET p_msg = 'Limite de lonhas da grade\n de OPs filha ultrapassou.'
         CALL log0030_mensagem(p_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_ind = l_ind - 1
      
   CALL _ADVPL_set_property(m_brz_filha,"ITEM_COUNT", l_ind)
   
   RETURN TRUE

END FUNCTION
   