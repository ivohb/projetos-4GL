#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1319                                                 #
# OBJETIVO: IMPRESSÃO DE NOTAS DE DÉBITO                            #
# AUTOR...: IVO                                                     #
# DATA....: 18/12/16                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_den_empresa   LIKE empresa.den_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003)
           
END GLOBALS

DEFINE m_den_empresa     LIKE empresa.den_empresa
DEFINE mr_empresa        RECORD LIKE empresa.*

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_construct       VARCHAR(10),
       m_ceo             VARCHAR(10),
       m_deo             VARCHAR(10),
       m_nnd             VARCHAR(10),
       m_emissao         VARCHAR(10),
       m_vencto          VARCHAR(10),
       m_valor           VARCHAR(10)

DEFINE m_ies_cons        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_dat_atu         DATE,
       m_opcao           CHAR(01),
       m_id_rateio       INTEGER,
       m_id_rateioa      INTEGER,
       m_carregando      SMALLINT,
       m_qtd_linha       INTEGER,
       m_index           INTEGER


DEFINE mr_cabec          RECORD
       cod_emp_orig      CHAR(02),
       den_emp_orig      CHAR(40),
       nota_debito       CHAR(14),
       emissao           CHAR(10),
       vencto            CHAR(10),
       valor             DECIMAL(12,2)
END RECORD

DEFINE ma_itens          ARRAY[300] OF RECORD
       cod_emp_dest      CHAR(02),
       den_emp_dest      VARCHAR(36),
       cod_tip_desp      DECIMAL(4,0),
       nom_tip_desp      CHAR(30),
       num_ad            DECIMAL(6,0),
       emissao           DATE,
       vencto            DATE,
       valor             DECIMAL(12,2),
       docum_orig        INTEGER,
       filler            CHAR(80)
END RECORD

DEFINE m_caminho  LIKE path_logix_v2.nom_caminho,
       m_comando  LIKE path_logix_v2.nom_caminho

DEFINE mr_nota_imp   RECORD
     num_nota     char(14),     
     cod_orig     char(02),     
     raz_orig     char(36),     
     end_orig     char(40),     
     cid_orig     char(30),     
     est_orig     char(02),     
     cep_orig     char(09),     
     cgc_orig     char(19),     
     cod_dest     char(02),     
     raz_dest     char(36),     
     end_dest     char(40),     
     cid_dest     char(30),     
     est_dest     char(02),     
     cep_dest     char(09),     
     cgc_dest     char(19),     
     dat_emis     char(10),     
     dat_venc     char(10),     
     nom_cont     char(30),     
     crc_cont     char(15),     
     val_nota     decimal(12,2)
   END RECORD      

#-----------------#
FUNCTION pol1319()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 11
   DEFER INTERRUPT
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_versao = "pol1319-12.00.01  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1319_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1319_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_find,
           l_first,
           l_previous,
           l_next,
           l_last,
           l_print  VARCHAR(10)
    
    CALL pol1319_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","IMPRESSÃO DE NOTAS DE DÉBITO")
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1319_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1319_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1319_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1319_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1319_last")

    LET l_print = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_print,"EVENT","pol1319_print")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1319_cria_campos(l_panel)
    CALL pol1319_cria_grade(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION
     
#-----------------------------#
FUNCTION pol1319_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1319_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",100)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",16)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW") 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa origem:")    

    LET m_ceo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_ceo,"LENGTH",2)
    CALL _ADVPL_set_property(m_ceo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_ceo,"VARIABLE",mr_cabec,"cod_emp_orig")
    
    LET m_deo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_deo,"LENGTH",36) 
    CALL _ADVPL_set_property(m_deo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_deo,"VARIABLE",mr_cabec,"den_emp_orig")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Nota débito:")    

    LET m_nnd = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_nnd,"LENGTH",12)
    CALL _ADVPL_set_property(m_nnd,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nnd,"VARIABLE",mr_cabec,"nota_debito")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Emissão:")    

    LET m_emissao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_emissao,"LENGTH",10)
    CALL _ADVPL_set_property(m_emissao,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_emissao,"VARIABLE",mr_cabec,"emissao")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Vencto:")    

    LET m_vencto = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_vencto,"LENGTH",10)
    CALL _ADVPL_set_property(m_vencto,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_vencto,"VARIABLE",mr_cabec,"vencto")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Valor:")    

    LET m_valor = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_valor,"LENGTH",12,2)
    CALL _ADVPL_set_property(m_valor,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_valor,"PICTURE","@E ##,###,###.##")
    CALL _ADVPL_set_property(m_valor,"VARIABLE",mr_cabec,"valor")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")


END FUNCTION

#---------------------------------------#
FUNCTION pol1319_cria_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_emp_dest")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",2)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome da empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",270)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_emp_dest")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tip desp")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_tip_desp")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",4,0)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome da despesa")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",280)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_tip_desp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num AD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ad")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",6,0)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Emissão")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","emissao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Vencto")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","vencto")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Valor")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","valor")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",12,2)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##,###,###.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Docum orig")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","docum_orig")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",6,0)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")
  
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    #CALL _ADVPL_set_property(m_browse,"CLEAR")


END FUNCTION

#----------------------#
FUNCTION pol1319_find()#
#----------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)
    
    LET m_id_rateioa = m_id_rateio
    
    IF m_construct IS NULL THEN
       LET m_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_construct,"CONSTRUCT_NAME","PESQUISA DE NOTA DE DÉBITO")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_TABLE","nota_deb_orig_912","Nota")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","nota_deb_orig_912","empresa_orig","Empresa origem",1 {CHAR},2,0,"zoom_empresa")
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","nota_deb_orig_912","num_nota_deb","Nota de débito",1 {CHAR},14,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","nota_deb_orig_912","dat_emissao","Emissão",1 {DATE},10,0)
       CALL _ADVPL_set_property(m_construct,"ADD_VIRTUAL_COLUMN","nota_deb_orig_912","dat_vencto","Vencto",1 {DATE},10,0)
    END IF

    LET l_status = _ADVPL_get_property(m_construct,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_construct,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct,"ORDER_BY")
        CALL pol1319_cria_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
    
    LET m_id_rateio = m_id_rateioa
    
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1319_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800)
   DEFINE l_order_by     CHAR(200)

   DEFINE l_sql_stmt     CHAR(2000)

    IF  l_order_by IS NULL THEN
        LET l_order_by = "empresa_orig, num_nota_deb"
    END IF

   LET l_sql_stmt = "SELECT id_rateio, empresa_orig, num_nota_deb, dat_emissao, ",
                     " dat_vencto FROM nota_deb_orig_912 ",
                    " WHERE ", l_where_clause CLIPPED,
                    " ORDER BY ", l_order_by

   PREPARE var_pesquisa FROM l_sql_stmt
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","var_pesquisa")
       RETURN 
   END IF

   DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_cons")
       RETURN 
   END IF

   FREE var_pesquisa

   OPEN cq_cons

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cons")
       RETURN 
   END IF
   
   LET m_ies_cons = FALSE
   
   FETCH cq_cons INTO m_id_rateio


   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cq_cons")
      ELSE
         LET m_msg = 'Não a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN 
   END IF

    IF NOT pol1319_exibe_dados() THEN
       LET m_msg = 'Operação cancelada'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN 
    END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
    
   LET m_ies_cons = TRUE
   
   LET m_id_rateioa = m_id_rateio
   
END FUNCTION

#-----------------------------#
FUNCTION pol1319_exibe_dados()#
#-----------------------------#

   DEFINE l_prod, l_recei, l_merc, l_uso CHAR(02),
          l_id   INTEGER
   
   CALL pol1319_limpa_campos()

   SELECT empresa_orig,
          num_nota_deb, 
          dat_emissao,       
          dat_vencto,
          val_nota        
     INTO mr_cabec.cod_emp_orig,
          mr_cabec.nota_debito,
          mr_cabec.emissao,
          mr_cabec.vencto,
          mr_cabec.valor          
    FROM nota_deb_orig_912
   WHERE id_rateio = m_id_rateio

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','nota_deb_orig_912:ED')
      RETURN FALSE 
   END IF
         
   CALL pol1319_le_empresa(mr_cabec.cod_emp_orig) 
   LET mr_cabec.den_emp_orig = m_den_empresa

   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",TRUE)
   LET m_carregando = TRUE
   LET p_status = pol1319_le_itens()
   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
   LET m_carregando = FALSE
      
   RETURN p_status

END FUNCTION

#------------------------------------#
FUNCTION pol1319_le_empresa(l_codigo)#
#------------------------------------#

   DEFINE l_codigo LIKE empresa.cod_empresa  
   
   LET m_msg = ''
   
   SELECT den_empresa
     INTO m_den_empresa
     FROM empresa
    WHERE cod_empresa = l_codigo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      LET m_den_empresa = ''
   END IF
   
END FUNCTION

#--------------------------#  
FUNCTION pol1319_le_itens()#
#--------------------------#
   
   DEFINE l_ind       SMALLINT
   
   INITIALIZE ma_itens TO NULL
   LET l_ind = 1
      
   DECLARE cq_itens CURSOR FOR
    SELECT empresa_dest, 
           num_ad,
           val_ad,
           docum_orig
      FROM nota_deb_dest_912
     WHERE num_nota_deb = mr_cabec.nota_debito
      ORDER BY empresa_dest, num_ad

   FOREACH cq_itens INTO 
      ma_itens[l_ind].cod_emp_dest,
      ma_itens[l_ind].num_ad,
      ma_itens[l_ind].valor,
      ma_itens[l_ind].docum_orig
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_itens')
         RETURN FALSE
      END IF

       IF ma_itens[l_ind].docum_orig IS NULL OR
           ma_itens[l_ind].docum_orig = '' THEN
          LET ma_itens[l_ind].docum_orig = 0
       END IF
      
      CALL pol1319_le_empresa(ma_itens[l_ind].cod_emp_dest) 
      LET ma_itens[l_ind].den_emp_dest = m_den_empresa

      SELECT cod_tip_despesa,
             dat_emis_nf,
             dat_venc
        INTO ma_itens[l_ind].cod_tip_desp,
             ma_itens[l_ind].emissao,
             ma_itens[l_ind].vencto
        FROM ad_mestre
       WHERE cod_empresa = ma_itens[l_ind].cod_emp_dest
         AND num_ad = ma_itens[l_ind].num_ad
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ad_mestre')
      ELSE
         SELECT nom_tip_despesa
           INTO ma_itens[l_ind].nom_tip_desp
           FROM tipo_despesa
          WHERE cod_empresa = ma_itens[l_ind].cod_emp_dest
            AND cod_tip_despesa = ma_itens[l_ind].cod_tip_desp
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','tipo_despesa')
         END IF
      END IF
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 300 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   FREE cq_itens
   
   LET m_ind = l_ind - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_ind)
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1319_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1319_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1319_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_id_rateioa = m_id_rateio

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_id_rateio
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_id_rateio
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_id_rateio
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_id_rateio
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_id_rateio = m_id_rateioa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM nota_deb_orig_912
          WHERE id_rateio = m_id_rateio
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1319_exibe_dados()
               LET l_achou = TRUE
               EXIT WHILE
            ELSE 
               CALL log003_err_sql("FETCH CURSOR","cq_cons")
               EXIT WHILE
            END IF
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-----------------------#
FUNCTION pol1319_first()#
#-----------------------#

   IF NOT pol1319_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1319_next()#
#----------------------#

   IF NOT pol1319_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1319_previous()#
#--------------------------#

   IF NOT pol1319_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1319_last()#
#----------------------#

   IF NOT pol1319_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#-----------------------#
FUNCTION pol1319_print()#
#-----------------------#

   IF NOT pol1319_ies_cons() THEN
      RETURN FALSE
   END IF

   SELECT nom_caminho
     INTO m_caminho
     FROM path_logix_v2
    WHERE cod_empresa = mr_cabec.cod_emp_orig 
      AND cod_sistema = 'DPH'
  
   IF m_caminho IS NULL THEN
      LET m_caminho = 'Caminho do sistema DPH não en-\n',
                      'contrado. Consulte a log1100.'
      CALL log0030_mensagem(m_caminho,'Info')
      RETURN FALSE
   END IF
   
   LET m_comando = m_caminho CLIPPED, 'nota.txt'
   START REPORT pol1319_nota TO m_comando
 
   IF NOT pol1319_ins_nota_imp() THEN
      RETURN FALSE
   END IF
   
   FINISH REPORT pol1319_nota 

   LET m_comando = m_caminho CLIPPED, 'ads.txt'
   START REPORT pol1319_ads TO m_comando
     
   IF NOT pol1319_ins_ad_imp() THEN
      RETURN FALSE
   END IF

   FINISH REPORT pol1319_ads 
   
   IF NOT pol1319_chama_delphi() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1319_ins_nota_imp()#
#------------------------------#      

   DELETE FROM nota_imp_912
   DELETE FROM ad_imp_912
   
   LET mr_nota_imp.num_nota = mr_cabec.nota_debito
   LET mr_nota_imp.cod_orig = mr_cabec.cod_emp_orig
   LET mr_nota_imp.dat_emis = mr_cabec.emissao
   LET mr_nota_imp.dat_venc = mr_cabec.vencto
   LET mr_nota_imp.val_nota = mr_cabec.valor

   LET mr_nota_imp.dat_emis = mr_nota_imp.dat_emis[9,10],'/',
           mr_nota_imp.dat_emis[6,7],'/',
           mr_nota_imp.dat_emis[1,4]

   LET mr_nota_imp.dat_venc = mr_nota_imp.dat_venc[9,10],'/',
           mr_nota_imp.dat_venc[6,7],'/',
           mr_nota_imp.dat_venc[1,4]
   
   IF NOT pol1319_empresa(mr_cabec.cod_emp_orig) THEN
      RETURN FALSE
   END IF

   LET mr_nota_imp.raz_orig = mr_empresa.den_empresa
   LET mr_nota_imp.end_orig = mr_empresa.end_empresa
   LET mr_nota_imp.cid_orig = mr_empresa.den_munic
   LET mr_nota_imp.est_orig = mr_empresa.uni_feder
   LET mr_nota_imp.cep_orig = mr_empresa.cod_cep
   LET mr_nota_imp.cgc_orig = mr_empresa.num_cgc
      
   LET mr_nota_imp.cod_dest = ma_itens[1].cod_emp_dest

   IF NOT pol1319_empresa(mr_nota_imp.cod_dest) THEN
      RETURN FALSE
   END IF

   LET mr_nota_imp.raz_dest = mr_empresa.den_empresa 
   LET mr_nota_imp.end_dest = mr_empresa.end_empresa 
   LET mr_nota_imp.cid_dest = mr_empresa.den_munic   
   LET mr_nota_imp.est_dest = mr_empresa.uni_feder   
   LET mr_nota_imp.cep_dest = mr_empresa.cod_cep     
   LET mr_nota_imp.cgc_dest = mr_empresa.num_cgc     

   SELECT parametro_texto
     INTO mr_nota_imp.crc_cont 
     FROM min_par_modulo
    WHERE empresa = mr_nota_imp.cod_orig 
      AND parametro = 'CRC_DO_CONTADOR'     

   IF STATUS = 100 THEN
      LET mr_nota_imp.crc_cont = ''
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','min_par_modulo')
         RETURN FALSE
      END IF
   END IF
   
   SELECT parametro_texto
     INTO mr_nota_imp.nom_cont 
     FROM min_par_modulo
    WHERE empresa = mr_nota_imp.cod_orig 
      AND parametro = 'NOME_DO_CONTADOR'     

   IF STATUS = 100 THEN
      LET mr_nota_imp.nom_cont = ''
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','min_par_modulo')
         RETURN FALSE
      END IF
   END IF
   
   INSERT INTO nota_imp_912
    VALUES(mr_nota_imp.*)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','nota_imp_912')
      RETURN FALSE
   END IF
   
   OUTPUT TO REPORT pol1319_nota()
   
   RETURN TRUE

END FUNCTION   
   
#------------------------------#
FUNCTION pol1319_empresa(l_cod)#
#------------------------------#
   
   DEFINE l_cod        CHAR(02)
   
   SELECT * 
     INTO mr_empresa.*
     FROM empresa
    WHERE cod_empresa = l_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION       

#----------------------------#
FUNCTION pol1319_ins_ad_imp()#
#----------------------------#

   FOR m_index  = 1 to m_ind
       
       INSERT INTO ad_imp_912
        VALUES(ma_itens[m_index].num_ad,
               ma_itens[m_index].cod_tip_desp,
               ma_itens[m_index].nom_tip_desp,
               ma_itens[m_index].valor)
               
       IF STATUS <> 0 THEN
          CALL log003_err_sql('INSERT','ad_imp_912')
          RETURN FALSE
       END IF
              
       OUTPUT TO REPORT pol1319_ads()

   END FOR
   
   RETURN TRUE

END FUNCTION       
   
#------------------------------#
FUNCTION pol1319_chama_delphi()#
#------------------------------#

   DEFINE l_param    CHAR(80),
          l_comando  CHAR(200)
   
   LET l_comando = m_caminho CLIPPED, 'pgi1317.exe ' #, p_param

   CALL conout(l_comando)

   CALL runOnClient(l_comando)
   
   RETURN TRUE
   
END FUNCTION   

#--------------------#
REPORT pol1319_nota()#
#--------------------#
   

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
   FORMAT
                 
      ON EVERY ROW
         PRINT '|',mr_nota_imp.num_nota, "|;",
               '|',mr_nota_imp.cod_orig, "|;",
               '|',mr_nota_imp.raz_orig, "|;",
               '|',mr_nota_imp.end_orig, "|;",
               '|',mr_nota_imp.cid_orig, "|;",
               '|',mr_nota_imp.est_orig, "|;",
               '|',mr_nota_imp.cep_orig, "|;",
               '|',mr_nota_imp.cgc_orig, "|;",
               '|',mr_nota_imp.cod_dest, "|;",
               '|',mr_nota_imp.raz_dest, "|;",
               '|',mr_nota_imp.end_dest, "|;",
               '|',mr_nota_imp.cid_dest, "|;",
               '|',mr_nota_imp.est_dest, "|;",
               '|',mr_nota_imp.cep_dest, "|;",
               '|',mr_nota_imp.cgc_dest, "|;",
               '|',mr_nota_imp.dat_emis, "|;",
               '|',mr_nota_imp.dat_venc, "|;",
               '|',mr_nota_imp.nom_cont, "|;",
               '|',mr_nota_imp.crc_cont, "|;",
               '|',mr_nota_imp.val_nota, "|;"
         
END REPORT                            

#-------------------#
REPORT pol1319_ads()#
#-------------------#
   

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
   FORMAT
                 
      ON EVERY ROW
         PRINT '|',ma_itens[m_index].docum_orig,"|;",
               '|',ma_itens[m_index].num_ad,"|;",
               '|',ma_itens[m_index].cod_tip_desp,"|;",
               '|',ma_itens[m_index].nom_tip_desp,"|;",
               '|',ma_itens[m_index].valor, "|;"
         
END REPORT                            


