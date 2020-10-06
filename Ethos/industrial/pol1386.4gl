#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1386                                                 #
# OBJETIVO: PROGRAMAÇÃO DE PRODUÇÃO DAS OPS                         #
# DATA....: 08/09/2020                                              #
#-------------------------------------------------------------------#

{
   LET m_query = 
   "select cod_cliente ",
   "  from [10.10.0.5].[logixprd].[logix].[pedidos] ",
   " where cod_empresa = '02' and num_pedido = 4 "
   
   PREPARE var_query FROM m_query 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','var_query:PREPARE')
   ELSE
      DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DECLARE','cq_padrao:DECLARE')
      ELSE
         OPEN cq_padrao
         FETCH cq_padrao INTO p_msg
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FETCH','cq_padrao:FETCH')
         ELSE
            CALL log0030_mensagem(p_msg,'info')
         END IF
      END IF
   END IF   
      
}

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_brz_item        VARCHAR(10),
       m_pnl_cabec       VARCHAR(10),
       m_pnl_item        VARCHAR(10)


DEFINE m_dat_de          VARCHAR(10),
       m_dat_ate         VARCHAR(10),
       m_ini_de          VARCHAR(10),
       m_ini_ate         VARCHAR(10),
       m_compon          VARCHAR(10),
       m_descri          VARCHAR(10),
       m_pedido          VARCHAR(10),
       m_operacao        VARCHAR(10),
       m_em_prod         VARCHAR(10)
              
DEFINE mr_cabec          RECORD
       empresa           CHAR(02),
       dat_de            DATE,
       dat_ate           DATE,
       ini_de            DATE,
       ini_ate           DATE,
       compon            VARCHAR(15),
       descri            VARCHAR(30),
       pedido            CHAR(15),
       operacao          CHAR(05),
       em_producao       CHAR(01)
END RECORD
       

DEFINE ma_item           ARRAY[5000] OF RECORD
       pedido            INTEGER,
       ordem             INTEGER,
       item              CHAR(15),
       descricao         CHAR(18),
       situacao          CHAR(01),
       quantidade        DECIMAL(10,3),
       entrega           DATE,
       iniciar           DATE,
       item_pai          CHAR(15),
       componente        CHAR(15),
       desc_comon        CHAR(18),
       operacao          CHAR(05),
       desc_operac       CHAR(18),
       sequencia         INTEGER,
       roteiro           CHAR(15),
       desc_rot          CHAR(30),
       em_producao       CHAR(01),
       filler            CHAR(01)
END RECORD

DEFINE ma_oper           ARRAY[100] OF RECORD
       operacao          CHAR(05),
       descricao         CHAR(30),
       componente        CHAR(15)
END RECORD

DEFINE m_ies_cons        SMALLINT,
       m_excluiu         SMALLINT,
       m_qtd_item        INTEGER,
       m_msg             CHAR(120),
       m_ies_info        smallint,
       m_query           VARCHAR(1200),
       m_ind             INTEGER,
       m_dat_atu         DATE
       
#-----------------#
FUNCTION pol1386()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1386-12.00.02  "
   CALL func002_versao_prg(p_versao)

   IF NOT log0150_verifica_se_tabela_existe("programacao_op_547") THEN 
      CALL LOG_transaction_begin()
      IF NOT pol1386_cria_tabela() THEN
         CALL LOG_transaction_rollback()
         RETURN FALSE
      END IF
      CALL LOG_transaction_commit()
   END IF
   
   CALL pol1386_menu()

END FUNCTION

#-----------------------------#
FUNCTION pol1386_cria_tabela()#
#-----------------------------#
   
   DEFINE l_data      DATE
   
   CREATE TABLE programacao_op_547 (      
    empresa          CHAR(02),             
    ordem            INTEGER,              
    operacao         CHAR(05),
    sequencia        INTEGER,
    data             DATE              
   );              

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','tabela programacao_op_405')
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_programacao_op_547
    ON programacao_op_547(empresa, ordem, sequencia);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','index ix_programacao_op_547')
      RETURN FALSE
   END IF
      
   INSERT INTO programacao_op_547(empresa, ordem, operacao, sequencia, data)
    SELECT cod_empresa, num_ordem, cod_operac, num_seq_operac, dat_inicio
     FROM ord_oper WHERE cod_empresa = p_cod_empresa
      AND dat_inicio IS NOT NULL AND dat_inicio > '01/01/2020'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','index programacao_op_547')
      RETURN FALSE
   END IF
      
   RETURN TRUE      
   
END FUNCTION

#----------------------#
FUNCTION pol1386_menu()#
#----------------------#

    DEFINE l_menubar,
           l_create,
           l_update,
           l_find,
           l_panel,
           l_titulo  VARCHAR(80)

    LET l_titulo = 'PROGRAMAÇÃO DE PRODUÇÃO DAS OPS - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1386_find")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1386_find_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1386_find_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1386_update")
    CALL _ADVPL_set_property(l_update,"CONFIRM_EVENT","pol1386_update_conf")
    CALL _ADVPL_set_property(l_update,"CANCEL_EVENT","pol1386_update_canc")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1386_monta_cabec(l_panel)
    CALL pol1386_monta_item(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1386_monta_cabec(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET m_pnl_cabec = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_cabec,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_cabec,"HEIGHT",80)
    CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",FALSE) 
    #CALL _ADVPL_set_property(m_panel,"BACKGROUND_COLOR",231,237,237)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_cabec)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",12)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Entrega de:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_de = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_de,"VARIABLE",mr_cabec,"dat_de")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_ate = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_ate,"VARIABLE",mr_cabec,"dat_ate")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Iniciar de:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_ini_de = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_ini_de,"VARIABLE",mr_cabec,"ini_de")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_ini_ate = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_ini_ate,"VARIABLE",mr_cabec,"ini_ate")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Componente:")    

    LET m_compon = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_compon,"VARIABLE",mr_cabec,"compon")
    CALL _ADVPL_set_property(m_compon,"LENGTH",15)
    CALL _ADVPL_set_property(m_compon,"PICTURE","@!")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Descrição:")    

    LET m_descri = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_descri,"VARIABLE",mr_cabec,"descri")
    CALL _ADVPL_set_property(m_descri,"LENGTH",25)
    CALL _ADVPL_set_property(m_descri,"PICTURE","@!")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Pedido:")    

    LET m_pedido = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_pedido,"VARIABLE",mr_cabec,"pedido")
    CALL _ADVPL_set_property(m_pedido,"LENGTH",9)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Operação:")    

    LET m_operacao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_operacao,"VARIABLE",mr_cabec,"operacao")
    CALL _ADVPL_set_property(m_operacao,"LENGTH",5)
    CALL _ADVPL_set_property(m_operacao,"PICTURE","@!")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Em produção:")    
    
    LET m_em_prod = _ADVPL_create_component(NULL,"LCOMBOBOX",l_layout)     
    CALL _ADVPL_set_property(m_em_prod,"POSITION",70,10)     
    CALL _ADVPL_set_property(m_em_prod,"ADD_ITEM","N","Não")
    CALL _ADVPL_set_property(m_em_prod,"ADD_ITEM","S","Sim")
    CALL _ADVPL_set_property(m_em_prod,"ADD_ITEM","T","Todos")
    CALL _ADVPL_set_property(m_em_prod,"VARIABLE",mr_cabec,"em_producao")
    
END FUNCTION

#---------------------------------------#
FUNCTION pol1386_monta_item(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pnl_item = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_item,"ALIGN","CENTER")
          
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_item)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_item,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_brz_item,"BEFORE_ADD_ROW_EVENT","pol1386_before_add_row")
    #CALL _ADVPL_set_property(m_brz_item,"AFTER_ROW_EVENT","pol1386_after_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CONFIRM_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",30)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","em_producao")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    #CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1386_exc_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pedido")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pedido")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","descricao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Status")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","situacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","quantidade")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Entrega")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","entrega")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Iniciar")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","iniciar")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item ai")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","item_pai")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Componente")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","componente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","desc_comon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Operacao")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","operacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrião")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","desc_operac")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Roteiro")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","roteiro")

    CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_item,1)
    CALL _ADVPL_set_property(m_brz_item,"EDITABLE",FALSE)

END FUNCTION

#------------------------------------#
FUNCTION pol1386_set_compon(l_status)#
#------------------------------------#
   
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",l_status)

END FUNCTION

#----------------------#
FUNCTION pol1386_find()#
#----------------------#

   INITIALIZE mr_cabec.*, ma_item TO NULL
   CALL pol1386_set_compon(TRUE)
   LET m_ies_info = FALSE
   LET mr_cabec.Operacao = '00005'
   CALL _ADVPL_set_property(m_dat_de,"GET_FOCUS")
    
END FUNCTION

#---------------------------#
FUNCTION pol1386_find_canc()#
#---------------------------#
   
   INITIALIZE mr_cabec.*, ma_item TO NULL
   CALL pol1386_set_compon(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1386_find_conf()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   CALL pol1386_monta_select()
   LET m_msg = NULL
   
   IF NOT pol1386_exec_select() THEN
      IF m_msg IS NOT NULL THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN FALSE
   END IF

   LET m_ies_info = LOG_progresspopup_start(
       "Lendo ordens... ","pol1386_exibe_dados","PROCESS")  

   CALL pol1386_set_compon(FALSE)
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1386_monta_select()#
#------------------------------#
      
   LET m_query =
    " SELECT distinct a.num_docum, a.num_ordem, a.cod_item_pai, a.cod_item, a.cod_roteiro, ",
    " a.dat_entrega, a.qtd_planej, a.ies_situa, b.cod_item_compon, c.cod_operac, c.num_seq_operac ",
    " FROM ordens a, ord_compon b, ord_oper c WHERE a.cod_empresa = '",p_cod_empresa,"' ",
    "  and a.cod_empresa = b.cod_empresa and a.num_ordem = b.num_ordem and a.ies_situa in ('3','4') ",
    "  and a.cod_empresa = c.cod_empresa and a.num_ordem = c.num_ordem and a.cod_item = c.cod_item"
                            
    IF mr_cabec.dat_de IS NOT NULL THEN
       LET m_query = m_query, " AND a.dat_entrega >= '",mr_cabec.dat_de,"' "
    END IF

    IF mr_cabec.dat_ate IS NOT NULL THEN
       LET m_query = m_query, " AND a.dat_entrega <= '",mr_cabec.dat_ate,"' "
    END IF

    IF mr_cabec.ini_de IS NOT NULL THEN
       LET m_query = m_query, " AND (a.dat_entrega - 15) >= '",mr_cabec.ini_de,"' "
    END IF

    IF mr_cabec.ini_ate IS NOT NULL THEN
       LET m_query = m_query, " AND (a.dat_entrega - 15) <= '",mr_cabec.ini_ate,"' "
    END IF

    IF mr_cabec.pedido IS NOT NULL THEN
       LET m_query = m_query, " AND a.num_docum = '",mr_cabec.pedido,"' "
    END IF

    IF mr_cabec.compon IS NOT NULL THEN
       LET m_query = m_query, " AND b.cod_item_compon = '",mr_cabec.compon,"' "
    END IF

    IF mr_cabec.operacao IS NOT NULL THEN
       LET m_query = m_query, " AND c.cod_operac = '",mr_cabec.operacao,"' "
    END IF

    LET m_query = m_query, " order by a.dat_entrega, a.cod_item  "                            
        
END FUNCTION

#-----------------------------#
FUNCTION pol1386_exec_select()#
#-----------------------------#

   PREPARE var_pesquisa FROM m_query
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","prepare:var_pesquisa")
       RETURN FALSE
   END IF   

   DECLARE cq_query CURSOR FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_query:DECLARE")
       RETURN FALSE
   END IF

   FREE var_pesquisa

   OPEN cq_query

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_query:open")
       RETURN FALSE
   END IF

   LET m_ind = 1

   FETCH cq_query INTO 
      ma_item[m_ind].pedido,
      ma_item[m_ind].ordem,
      ma_item[m_ind].item_pai,
      ma_item[m_ind].item,
      ma_item[m_ind].roteiro,
      ma_item[m_ind].entrega,
      ma_item[m_ind].quantidade,
      ma_item[m_ind].situacao,
      ma_item[m_ind].componente,
      ma_item[m_ind].operacao,
      ma_item[m_ind].sequencia

   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cq_query:fetch")
      ELSE
         LET m_msg = 'Não a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1386_exibe_dados()#
#-----------------------------#

   DEFINE l_progres   SMALLINT,
          l_em_prog   SMALLINT,
          l_descri    VARCHAR(30)

   CALL LOG_progresspopup_set_total("PROCESS",5000)

   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   CALL _ADVPL_set_property(m_brz_item,"CLEAR_ALL_LINE_FONT_COLOR")
   INITIALIZE ma_itens TO NULL
   
   LET m_ind = 1
      
   FOREACH cq_query INTO 
      ma_item[m_ind].pedido,
      ma_item[m_ind].ordem,
      ma_item[m_ind].item_pai,
      ma_item[m_ind].item,
      ma_item[m_ind].roteiro,
      ma_item[m_ind].entrega,
      ma_item[m_ind].quantidade,
      ma_item[m_ind].situacao,
      ma_item[m_ind].componente,
      ma_item[m_ind].operacao,
      ma_item[m_ind].sequencia
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_query:FOREACH')
         RETURN FALSE
      END IF

      IF mr_cabec.descri IS NOT NULL THEN
         LET l_descri = '%',mr_cabec.descri CLIPPED,'%'
         SELECT 1 FROM Item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = ma_item[m_ind].componente
            AND ies_situacao = 'A'
            AND den_item LIKE l_descri
            
         IF STATUS = 100 THEN
            CONTINUE FOREACH
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','cq_query:Item')
               RETURN FALSE
            END IF
         END IF

      END IF
      
      LET ma_item[m_ind].em_producao = 'N'
      
      LET l_em_prog = FALSE
      
      SELECT 1 FROM programacao_op_547
       WHERE empresa = p_cod_empresa
         AND ordem = ma_item[m_ind].ordem
         AND sequencia = ma_item[m_ind].sequencia

      IF STATUS = 0 THEN
         LET l_em_prog = TRUE
         LET ma_item[m_ind].em_producao = 'S'
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('SELECT','programacao_op_547:cq_query')
            RETURN FALSE
         END IF
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")

      IF mr_cabec.em_producao = 'N' AND l_em_prog THEN
         CONTINUE FOREACH
      END IF

      IF mr_cabec.em_producao = 'S' AND NOT l_em_prog THEN
         CONTINUE FOREACH
      END IF
            
      LET ma_item[m_ind].iniciar = ma_item[m_ind].entrega - 15
      
      IF ma_item[m_ind].iniciar < TODAY THEN
         CALL _ADVPL_set_property(m_brz_item,"LINE_FONT_COLOR",m_ind,197,16,26)
      ELSE
         CALL _ADVPL_set_property(m_brz_item,"LINE_FONT_COLOR",m_ind,0,0,0)
      END IF
      
      LET ma_item[m_ind].descricao = pol1386_le_item(ma_item[m_ind].item)
      LET ma_item[m_ind].desc_comon = pol1386_le_item(ma_item[m_ind].componente)
      LET ma_item[m_ind].desc_operac = pol1386_le_operacao(ma_item[m_ind].operacao)
            
      LET m_ind = m_ind + 1
      
      IF m_ind > 5000 THEN
         LET m_msg = 'Limite previsto de itens ultrapassou\n',
                     'Serão exibidos somente 5000 itens.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   LET m_qtd_item = m_ind - 1 
   CALL _ADVPL_set_property(m_brz_item,"ITEM_COUNT", m_qtd_item)
   
   IF m_qtd_item > 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------#
FUNCTION pol1386_le_item(l_codigo)#
#---------------------------------#

   DEFINE l_codigo      LIKE item.cod_item,
          l_desc        LIKE item.den_item

   SELECT den_item_reduz 
     INTO l_desc
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_codigo

   IF STATUS = 100 THEN
      LET l_desc = 'Produto não cadastrado'
   ELSE
      IF STATUS <> 0 THEN
         LET m_msg = STATUS
         LET l_desc = 'Erro ',m_msg CLIPPED,
             ' lendo descrição do produto'
      END IF
   END IF
   
   RETURN l_desc

END FUNCTION
 
#-------------------------------------#
FUNCTION pol1386_le_operacao(l_codigo)#
#-------------------------------------#

   DEFINE l_codigo      LIKE operacao.cod_operac,
          l_desc        LIKE operacao.den_operac


   SELECT den_operac 
     INTO l_desc
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = l_codigo

   IF STATUS = 100 THEN
      LET l_desc = 'Operação não cadastrada'
   ELSE
      IF STATUS <> 0 THEN
         LET m_msg = STATUS
         LET l_desc = 'Erro ',m_msg CLIPPED,
             ' lendo descrição da operação'
      END IF
   END IF
   
   RETURN l_desc

END FUNCTION

#------------------------#
FUNCTION pol1386_update()#
#------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT m_ies_info THEN
      LET m_msg = 'Efetue a consulta previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_brz_item,"EDITABLE",TRUE)
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1386_update_canc()#
#-----------------------------#

   CALL _ADVPL_set_property(m_brz_item,"CLEAR")
   CALL _ADVPL_set_property(m_brz_item,"CLEAR_ALL_LINE_FONT_COLOR")
   INITIALIZE ma_itens TO NULL
   LET m_ies_info = FALSE
   CALL _ADVPL_set_property(m_brz_item,"EDITABLE",FALSE)
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION pol1386_update_conf()#
#-----------------------------#
   
   DEFINE l_erro       SMALLINT
          
   LET l_erro = FALSE
   LET m_dat_atu = TODAY
   
   CALL LOG_transaction_begin()
   
   FOR m_ind = 1 TO m_qtd_item
       IF ma_item[m_ind].ordem IS NOT NULL THEN
          IF NOT pol1386_grav_ordem() THEN
             CALL LOG_transaction_rollback()
             LET l_erro = TRUE
             EXIT FOR
          END IF
       END IF
   END FOR
   
   IF l_erro THEN
      LET m_msg = 'Operação cancelada.'
   ELSE
      CALL LOG_transaction_commit()
      LET m_msg = 'Operação efetuada com sucesso.'
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   CALL log0030_mensagem(m_msg,'info')
   
   RETURN TRUE

END FUNCTION

#----------------------------#   
FUNCTION pol1386_grav_ordem()#
#----------------------------#
   
   SELECT 1 FROM programacao_op_547
    WHERE empresa = p_cod_empresa
      AND ordem = ma_item[m_ind].ordem
      AND sequencia = ma_item[m_ind].sequencia
   
   IF STATUS = 0 THEN
      IF ma_item[m_ind].em_producao = 'N' THEN
         DELETE FROM programacao_op_547 
          WHERE empresa = p_cod_empresa
            AND ordem = ma_item[m_ind].ordem
            AND sequencia = ma_item[m_ind].sequencia
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF ma_item[m_ind].em_producao = 'S' THEN
            INSERT INTO programacao_op_547 
             VALUES(p_cod_empresa, 
                   ma_item[m_ind].ordem, 
                   ma_item[m_ind].operacao,
                   ma_item[m_ind].sequencia, 
                   m_dat_atu)
            IF STATUS <> 0 THEN
               CALL log003_err_sql('INSERT','programacao_op_547')
               RETURN FALSE
            END IF
         END IF
      ELSE
         CALL log003_err_sql('SELECT','programacao_op_547')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE   

END FUNCTION
   