# PROGRAMA: pol1305                                                            #
# OBJETIVO: EXPORTAÇÃO DO LOGIX P/ PC_FACTORY                                  #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 11/08/2016                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_versao               CHAR(18),
          comando                CHAR(080),
          m_comando              CHAR(080),
          p_caminho              CHAR(150),
          m_caminho              CHAR(150),
          g_tipo_sgbd            CHAR(003),
          g_msg                  CHAR(150)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_construct       VARCHAR(10),
       m_dat_ini         VARCHAR(10),
       m_dat_fim         VARCHAR(10)

DEFINE mr_cabec          RECORD
       dat_inicial       DATE,
       dat_final         DATE
END RECORD
 
DEFINE ma_erro          ARRAY[5000] OF RECORD
       num_ordem        INTEGER,
       mensagem         CHAR(150)
END RECORD
        
DEFINE    m_msg                  CHAR(150),
          m_erro                 CHAR(10),
          m_ies_info             SMALLINT,
          m_count                INTEGER,
          m_index                INTEGER,
          m_integra              SMALLINT,
          m_del_queue            SMALLINT,
          m_qtd_op               INTEGER

DEFINE    m_cod_item             LIKE item.cod_item,
          m_num_ordem            LIKE ordens.num_ordem,
          m_ies_situa            LIKE ordens.ies_situa,
          m_ies_oper_final       LIKE ord_oper.ies_oper_final,
          m_ies_impressao        LIKE ord_oper.ies_impressao,
          m_cod_operac           LIKE ord_oper.cod_operac,
          m_num_seq_operac       LIKE ord_oper.num_seq_operac,
          m_dat_entrega          LIKE ordens.dat_entrega,
          m_dat_abert            LIKE ordens.dat_abert,
          m_dat_ini_planej       LIKE man_oper_compl.dat_ini_planejada,
          m_dat_fim_planej       LIKE man_oper_compl.dat_trmn_planejada,
          m_qtd_planej           LIKE ordens.qtd_planej,
          m_num_docum            LIKE ordens.num_docum,
          m_peca_hora            LIKE ord_oper.qtd_horas,
          m_qtd_horas            LIKE ord_oper.qtd_horas


DEFINE    mr_complete            RECORD LIKE TBLInWOComplete.*,
          mr_product             RECORD LIKE TBLInProduct.*,
          mr_queue               RECORD LIKE TBLInWOQueue.*,
          mr_item                RECORD LIKE item.*

DEFINE    m_ini_prod           DATE,
          m_export             CHAR(01)

DEFINE m_dat_fecha_ult_man     LIKE ordens.dat_liberac

#-----------------#
FUNCTION pol1305()#
#-----------------#

   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "POL1305-12.00.21  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1305_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1305_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_ordem       VARCHAR(10),
           l_ferram      VARCHAR(10),
           l_inform      VARCHAR(10),
           l_erro        VARCHAR(10),
           l_titulo      CHAR(43)
    
    LET l_titulo = "EXPORTAÇÃO DE DADOS PARA O PPI - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1305_informar")
    CALL _ADVPL_set_property(l_inform,"TOOLTIP","Informar período p/ exportaçãoa de OP")
    CALL _ADVPL_set_property(l_inform,"CONFIRM_EVENT","pol1305_confirmar")
    CALL _ADVPL_set_property(l_inform,"CANCEL_EVENT","pol1305_cancelar")

    LET l_ordem = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_ordem,"IMAGE","ORDENS")     
    CALL _ADVPL_set_property(l_ordem,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_ordem,"TOOLTIP","Exportar ordens")
    CALL _ADVPL_set_property(l_ordem,"EVENT","pol1305_ordem")

    LET l_ferram = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_ferram,"IMAGE","FERRAMEN")     
    CALL _ADVPL_set_property(l_ferram,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_ferram,"TOOLTIP","Exportar ferramental")
    CALL _ADVPL_set_property(l_ferram,"EVENT","pol1305_ferramental")

    LET l_erro = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_erro,"IMAGE","ZOOM_ERROS")     
    CALL _ADVPL_set_property(l_erro,"TYPE","NO_CONFIRM")     
    CALL _ADVPL_set_property(l_erro,"TOOLTIP","Exibe os erros de exportação")
    CALL _ADVPL_set_property(l_erro,"EVENT","pol1305_erros")

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1305_cria_campos(l_panel)
   CALL pol1305_grade_erro(l_panel)
   
   CALL pol1305_ativa_desativa(FALSE)
   CALL pol1305_limpa_campos()

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1305_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_panel           VARCHAR(10),
           l_label           VARCHAR(10),
           l_cod_item        VARCHAR(10),
           l_den_item        VARCHAR(10),
           l_unidade         VARCHAR(10),
           l_status          VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP") 
    CALL _ADVPL_set_property(l_panel,"HEIGHT",100)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",5)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Da de liberaão de:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_ini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_ini,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_dat_ini,"VARIABLE",mr_cabec,"dat_inicial")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Até:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_fim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_dat_fim,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_dat_fim,"VARIABLE",mr_cabec,"dat_final")

END FUNCTION

#---------------------------------------#
FUNCTION pol1305_grade_erro(l_container)#
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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",130)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ordem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")    
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##########")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",250)
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_erro,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1305_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_dat_ini,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_dat_fim,"EDITABLE",l_status)

END FUNCTION

#-----------------------------#
FUNCTION pol1305_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   
END FUNCTION

#--------------------------#
FUNCTION pol1305_informar()#
#--------------------------#
         
   CALL pol1305_ativa_desativa(TRUE)
   CALL pol1305_limpa_campos()

   SELECT dat_fecha_ult_man
     INTO mr_cabec.dat_inicial
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_estoque')
      RETURN FALSE
   END IF
      
   CALL _ADVPL_set_property(m_dat_ini,"GET_FOCUS")
      
   RETURN TRUE 
    
END FUNCTION

#---------------------------#
FUNCTION pol1305_confirmar()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,'CLEAR_TEXT')   
   
   IF mr_cabec.dat_inicial IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe a data inicial.")
      CALL _ADVPL_set_property(m_dat_ini,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_cabec.dat_final IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe a data final.")
      CALL _ADVPL_set_property(m_dat_fim,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_cabec.dat_final < mr_cabec.dat_inicial THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Data Inicial nao pode ser maior que data Final.")
      CALL _ADVPL_set_property(m_dat_ini,"GET_FOCUS")
      RETURN FALSE
   END IF

   CALL pol1305_ativa_desativa(FALSE)
   LET m_ies_info = TRUE
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1305_cancelar()#
#--------------------------#

    CALL pol1305_limpa_campos()
    CALL pol1305_ativa_desativa(FALSE)
    LET m_ies_info = FALSE
    RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1305_ordem()#
#-----------------------#

   CALL _ADVPL_set_property(m_statusbar,'CLEAR_TEXT')   
   
   IF NOT m_ies_info THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe o período previamente.")
      CALL _ADVPL_set_property(m_dat_ini,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   LET m_export = 'O'
   LET m_index = 0

   CALL _ADVPL_set_property(m_browse,"CLEAR")

   CALL LOG_progresspopup_start("Lendo ordens...","pol1305_ordens","PROCESS")   

   CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_erro,m_index)

   LET m_ies_info = FALSE
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
END FUNCTION

#------------------------#
FUNCTION pol1305_ordens()#
#------------------------#

   IF NOT pol1305_exp_ordens() THEN
      LET m_msg = 'Opeação cancelada.'
      RETURN
   END IF

   IF m_integra THEN
      IF NOT pol1305_chama_delphi() THEN
         RETURN 
      END IF
   END IF
   
   IF m_index > 0 THEN
      IF NOT pol1305_grava_erro() THEN 
         RETURN
      END IF
      
      LET m_msg = m_index USING '<<<<<<'
      LET m_msg = m_msg CLIPPED, ' Ordens foram criticadas.\n Consulte os erros.'
   ELSE
      LET m_msg = 'Operação efetuada com sucesso.'
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1305_exp_ordens()#
#----------------------------#
   
   DEFINE c_num_ordem      CHAR(10),
          l_progres        SMALLINT
   
   
   LET m_integra = FALSE
   LET m_del_queue = TRUE
   LET m_msg = NULL

    SELECT COUNT(*)
      INTO m_qtd_op
      FROM ordens
     WHERE cod_empresa = p_cod_empresa
       AND ies_situa in ('4','5','9')
       AND dat_liberac >= mr_cabec.dat_inicial
       AND dat_liberac <= mr_cabec.dat_final
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens:count')
      RETURN FALSE
   END IF
   
   IF m_qtd_op = 0 THEN
      LET m_msg = 'Não há ordens para exportar\n',
                  'para o período informado.'
      RETURN TRUE
   END IF
   
   DELETE FROM erros_pol1305
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','erros_pol1305')
      RETURN FALSE
   END IF
   
   
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_op)
   
   DECLARE cq_ordens CURSOR WITH HOLD FOR 
    SELECT num_ordem,
           cod_item,
           dat_abert,
           dat_entrega,
           qtd_planej,
           ies_situa,
           num_docum,
           dat_ini
      FROM ordens
     WHERE cod_empresa = p_cod_empresa
       AND ies_situa in ('4','5','9')
       AND dat_liberac >= mr_cabec.dat_inicial
       AND dat_liberac <= mr_cabec.dat_final

   FOREACH cq_ordens INTO 
           m_num_ordem,
           m_cod_item,
           m_dat_abert,
           m_dat_entrega,
           m_qtd_planej,
           m_ies_situa,
           m_num_docum,
           m_ini_prod
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ordens:cq_ordens')
         RETURN FALSE
      END IF
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      IF m_ini_prod IS NOT NULL THEN
         LET m_msg = 'Ordem já possui apontamentos.'
         CALL pol1305_guarda_erro()
         CONTINUE FOREACH
      END IF
      
      IF m_ies_situa = '4' THEN
      ELSE      
         SELECT num_ordem 
           FROM ordens_export_912
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem = m_num_ordem
            AND ies_situa = '4'
         IF STATUS = 100 THEN
            CONTINUE FOREACH
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','ordens_export_912')
               RETURN FALSE
            END IF
         END IF
      END IF
      
      INITIALIZE mr_complete.* TO NULL      
      
      LET mr_complete.WOSituation = '-10'
      
      LET c_num_ordem  = m_num_ordem
                       
      LET mr_complete.ProcListCode = m_num_docum
      LET mr_complete.TotalQty = m_qtd_planej
      LET mr_complete.ProductCode = m_cod_item
      LET mr_complete.WoCode = p_cod_empresa, c_num_ordem
      LET mr_complete.DtIssue = m_dat_abert
      LET mr_complete.DtDue = m_dat_entrega
      IF mr_complete.DtDue IS NULL THEN
         LET mr_complete.DtDue = TODAY
      END IF
      
      LET mr_complete.BaseQty = 1         #Quantidade base para o cálculo de consumo de material   
      LET mr_complete.FlgEng = 0          #Determina o tipo de Ordem da tabela TBLWOHD             
      LET mr_complete.Excluded = 0        #Registro excluído no ERP                                
      LET mr_complete.Integrated = 0      #Status do registro(liberado para ser integrado)         
      LET mr_complete.Selected = 0        #Campo destinado ao uso no Filemanager                   

      IF m_ies_situa = '4' THEN
         LET mr_complete.Status = 20
      ELSE
         IF m_ies_situa = '9' THEN
            LET mr_complete.Status = 70
         ELSE
            IF m_ies_situa = '5' THEN
               LET mr_complete.Status = 50
            ELSE
               LET mr_complete.Status = 0
            END IF
         END IF
      END IF
   
      SELECT *
        INTO mr_item.*
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = m_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item:cq_ordens')
         RETURN FALSE
      END IF
      
      LET mr_complete.Unit1Code = mr_item.cod_unid_med
      
      SELECT COUNT(a.cod_operac)
         INTO m_count
         FROM ord_oper a, operacao b
        WHERE a.cod_empresa = p_cod_empresa
          AND a.cod_empresa = b.cod_empresa
          AND a.cod_operac  = b.cod_operac
          AND a.num_ordem   = m_num_ordem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ord_oper:cq_ordens')
         RETURN FALSE
      END IF

      IF m_count = 0 THEN
         LET m_msg = 'Ordem sem operações para exportar.'
         CALL pol1305_guarda_erro()
         CONTINUE FOREACH
      END IF
      
      BEGIN WORK
      
      IF NOT pol1305_exp_operacoes() THEN
         ROLLBACK WORK
         RETURN FALSE
      END IF
      
      IF NOT pol1305_ins_product() THEN
         ROLLBACK WORK
         RETURN FALSE
      END IF
      
      IF NOT pol1305_ins_ordens_912() THEN
         ROLLBACK WORK
         RETURN FALSE
      END IF
      
      COMMIT WORK
      
      LET m_integra = TRUE
      
   END FOREACH
   
   FREE cq_ordens
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
END FUNCTION

#-------------------------------#
FUNCTION pol1305_exp_operacoes()#
#-------------------------------#

  DEFINE  l_arranjo        LIKE ord_oper.cod_arranjo,
          l_num_processo   INTEGER,
          l_qtd_cavidades  DECIMAL(8,4)

   DECLARE cq_operacoes CURSOR WITH HOLD FOR 
    SELECT a.cod_operac,      #código da operação
           a.num_seq_operac,
           b.den_operac,      #Nome da operação
           a.qtd_horas_setup, #Tempo de set-up na unidade definida pelo campo SetupTimeFormat
           a.ies_oper_final,
           a.ies_impressao,
           a.qtd_planejada,    #Quantidade prevista para essa operação
           a.qtd_horas,
           a.cod_arranjo,
           a.num_processo 
      FROM ord_oper a, operacao b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.cod_empresa = b.cod_empresa
       AND a.cod_operac  = b.cod_operac
       AND a.num_ordem   = m_num_ordem
     ORDER BY a.num_seq_operac

   FOREACH cq_operacoes INTO
           m_cod_operac,
           m_num_seq_operac,
           mr_complete.WODetName,
           mr_complete.SetUpTime,
           m_ies_oper_final,
           m_ies_impressao,
           mr_complete.Qty,
           m_qtd_horas,
           l_arranjo,
           l_num_processo            

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ord_oper/operacao')
         RETURN FALSE
      END IF
         
      LET mr_complete.ResourceCode = l_arranjo      
      LET mr_complete.WODetCode = m_cod_operac
      LET mr_complete.SetUpTimeFormat = 3  #Formato de apresentação tempo de set-up (Hr)
      LET mr_complete.FlgQCInspection = 0  #Indica se a operação sofrerá inspeção por amostragem
         
      IF m_qtd_horas > 0 THEN
         LET m_peca_hora = (1/m_qtd_horas) / 3600
         IF m_peca_hora <= 0 THEN
            LET m_peca_hora = 1
         END IF
      ELSE
         LET m_peca_hora = 1
      END IF
         
      SELECT qtd_cavidades
        INTO l_qtd_cavidades
        FROM man_ferramenta_processo
       WHERE empresa = p_cod_empresa
         AND seq_processo = l_num_processo
         
      IF STATUS <> 0 THEN
         LET l_qtd_cavidades = 1
      END IF
         
      LET mr_complete.Unit1Factor = l_qtd_cavidades
         
      LET mr_complete.StdSpeed = m_peca_hora
      LET mr_complete.StdSpeedFormat = 3

      IF m_ies_oper_final = 'S' THEN
         LET mr_complete.ReportTrigger = 1
      ELSE
         LET mr_complete.ReportTrigger = 0
      END IF

      IF m_ies_impressao = 'S' THEN
         LET mr_complete.DisablePrint = 1
      ELSE
         LET mr_complete.DisablePrint = 0
      END IF

      LET mr_complete.DtCreation = CURRENT
         
      IF m_ies_situa = '4' THEN
         LET mr_complete.WODetStatus = 20
      ELSE
         LET mr_complete.WODetStatus = 60
      END IF
         
      LET mr_complete.ManagerGrpCode = 'IMP'
      LET mr_complete.DefaultOrigin = 0 
      LET mr_complete.DefaultType = 2
      LET mr_complete.PlanType = 2
         
      SELECT dat_ini_planejada,
             dat_trmn_planejada
        INTO m_dat_ini_planej,
             m_dat_fim_planej
        FROM man_oper_compl
       WHERE empresa = p_cod_empresa
         AND ordem_producao = m_num_ordem
         AND operacao = m_cod_operac
         AND sequencia_operacao = m_num_seq_operac

      IF STATUS = 100 THEN
         LET m_dat_ini_planej = m_dat_entrega
         LET m_dat_fim_planej = m_dat_entrega
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','man_oper_compl')
            RETURN FALSE
         END IF
      END IF
          
      LET mr_complete.DtPlanStart = m_dat_ini_planej  #Data Planejada de Inicio da ordem
      LET mr_complete.DtPlanEnd = m_dat_fim_planej    #Data Planejada de Fim da ordem
      LET mr_complete.WoTypeCode = '-10'
      IF m_num_ordem = 11411432 then
         CALL log0030_mensagem(m_dat_ini_planej,'info')
         CALL log0030_mensagem(mr_complete.DtPlanStart,'info')
      END IF
      IF NOT pol1305_ins_complete() THEN
         RETURN FALSE
      END IF

      IF m_del_queue THEN
         DELETE FROM TBLInWOQueue
         LET m_del_queue = FALSE
      END IF      

      IF NOT pol1305_ins_queue() THEN
         RETURN FALSE
      END IF

   END FOREACH
   
   FREE cq_operacoes
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1305_ins_complete()#
#------------------------------#
   
   DELETE FROM TBLInWOComplete
    WHERE WoCode = mr_complete.WoCode
   
   LET mr_complete.IDInWOComplete = 0
   LET mr_complete.DefaultFactorOrigin = 1
   
   INSERT INTO TBLInWOComplete (
      IDInWOComplete,
      WoCode,                   
      ProductCode,              
      WOSituation,              
      ExtCode,                  
      Auxcode1,                 
      Auxcode2,                 
      WoTypeCode,               
      DtIssue,                  
      DtDue,                    
      DtPlanStart,              
      DtPlanEnd,                
      TotalQty,                 
      Status,                   
      Comments,                 
      TechDoc,                  
      ProcListCode,             
      FlgPrinted,               
      WODetCode,                
      WODetName,                
      WODetExtCode,             
      WODetAuxCode1,            
      WODetAuxCode2,            
      WODetTechDoc,             
      StdSpeed,                 
      StdSpeedFormat,           
      ResourceCode,             
      WODetStatus,              
      WODetDtPlanStart,         
      WODetDtPlanEnd,           
      ManagerGrpCode,           
      DefaultOrigin,           
      DefaultType,              
      SetUpTime,                
      SetUpTimeFormat,          
      StdCrew,                  
      PlanType,                 
      Unit1Factor,              
      ReportTrigger,            
      DisablePrint,             
      BaseQty,                  
      MatListCode,              
      Qty,                      
      Unit1Code,                
      Unit2Factor,              
      Unit2Code,                
      Unit3Factor,              
      Unit3Code,                
      LabelCode,                
      FlgQCInspection,          
      DefaultAddressCode,       
      ConsAddressCode,          
      ProdAddressCode,          
      ScrapAddressCode,         
      ReWorkAddressCode,        
      Yield,                    
      Unit1FactorScrap,         
      Unit1FactorReWork,        
      MPSPlanHDCode,            
      WOCodeOrigin,             
      BackFlushType,            
      LotCodeBackFlushType,     
      DefaultFactorOrigin,      
      DefaultFactorScrapOrigin, 
      DefaultFactorReWorkOrigin,
      StdCycleTime,             
      StdCycleTimeOrigin,       
      DefaultCycleTimeOrigin,   
      CommittedStdSpeed,        
      FlgEng,                   
      ToolingTypeCode,          
      Excluded,                 
      Integrated,               
      DtCreation,               
      DtIntegration,            
      ErrDescription,           
      Selected,                 
      DataOrigin,               
      DtTimeStampImp)
   VALUES(mr_complete.IDInWOComplete,
          mr_complete.WoCode,                   
          mr_complete.ProductCode,              
          mr_complete.WOSituation,              
          mr_complete.ExtCode,                  
          mr_complete.Auxcode1,                 
          mr_complete.Auxcode2,                     
          mr_complete.WoTypeCode,               
          mr_complete.DtIssue,                  
          mr_complete.DtDue,                    
          mr_complete.DtPlanStart,              
          mr_complete.DtPlanEnd,                    
          mr_complete.TotalQty,                 
          mr_complete.Status,                   
          mr_complete.Comments,                 
          mr_complete.TechDoc,                  
          mr_complete.ProcListCode,                 
          mr_complete.FlgPrinted,               
          mr_complete.WODetCode,                
          mr_complete.WODetName,                
          mr_complete.WODetExtCode,             
          mr_complete.WODetAuxCode1,                
          mr_complete.WODetAuxCode2,            
          mr_complete.WODetTechDoc,             
          mr_complete.StdSpeed,                 
          mr_complete.StdSpeedFormat,           
          mr_complete.ResourceCode,                 
          mr_complete.WODetStatus,              
          mr_complete.WODetDtPlanStart,         
          mr_complete.WODetDtPlanEnd,           
          mr_complete.ManagerGrpCode,           
          mr_complete.DefaultOrigin,                
          mr_complete.DefaultType,              
          mr_complete.SetUpTime,                
          mr_complete.SetUpTimeFormat,          
          mr_complete.StdCrew,                  
          mr_complete.PlanType,                     
          mr_complete.Unit1Factor,              
          mr_complete.ReportTrigger,            
          mr_complete.DisablePrint,             
          mr_complete.BaseQty,                  
          mr_complete.MatListCode,                  
          mr_complete.Qty,                      
          mr_complete.Unit1Code,                
          mr_complete.Unit2Factor,              
          mr_complete.Unit2Code,                
          mr_complete.Unit3Factor,                  
          mr_complete.Unit3Code,                
          mr_complete.LabelCode,                
          mr_complete.FlgQCInspection,          
          mr_complete.DefaultAddressCode,       
          mr_complete.ConsAddressCode,              
          mr_complete.ProdAddressCode,          
          mr_complete.ScrapAddressCode,         
          mr_complete.ReWorkAddressCode,        
          mr_complete.Yield,                    
          mr_complete.Unit1FactorScrap,             
          mr_complete.Unit1FactorReWork,        
          mr_complete.MPSPlanHDCode,            
          mr_complete.WOCodeOrigin,             
          mr_complete.BackFlushType,            
          mr_complete.LotCodeBackFlushType,         
          mr_complete.DefaultFactorOrigin,      
          mr_complete.DefaultFactorScrapOrigin, 
          mr_complete.DefaultFactorReWorkOrigin,
          mr_complete.StdCycleTime,             
          mr_complete.StdCycleTimeOrigin,           
          mr_complete.DefaultCycleTimeOrigin,   
          mr_complete.CommittedStdSpeed,        
          mr_complete.FlgEng,                   
          mr_complete.ToolingTypeCode,          
          mr_complete.Excluded,                     
          mr_complete.Integrated,               
          mr_complete.DtCreation,               
          mr_complete.DtIntegration,            
          mr_complete.ErrDescription,           
          mr_complete.Selected,                     
          mr_complete.DataOrigin,               
          mr_complete.DtTimeStampImp)           
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','TBLInWOComplete')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1305_ins_queue()#
#---------------------------#

   INITIALIZE mr_queue TO NULL
   
   LET mr_queue.IDInWOQueue = 0
   LET mr_queue.ResourceCode = mr_complete.ResourceCode
   LET mr_queue.Sequence = m_num_seq_operac
   LET mr_queue.WOCode = mr_complete.WoCode
   LET mr_queue.WODetCode = m_cod_operac
   LET mr_queue.WOEngCode = ' '
   LET mr_queue.Qty = m_qtd_planej
   LET mr_queue.DtStart = m_dat_ini_planej
   LET mr_queue.DtEnd = m_dat_fim_planej
   LET mr_queue.Excluded = 0
   LET mr_queue.Integrated = 0
   LET mr_queue.DtCreation = CURRENT
   LET mr_queue.Selected = 0   
      
   INSERT INTO TBLInWOQueue(
      IDInWOQueue,
      ManagerGrpCode,
      ResourceCode,  
      Sequence,      
      WOCode,        
      WODetCode,     
      WOEngCode,     
      Qty,           
      DtStart,       
      DtEnd,         
      Excluded,      
      Integrated,    
      DtCreation,    
      DtIntegration, 
      ErrDescription,
      Selected,      
      DataOrigin,    
      DtTimeStampImp)
   VALUES(mr_queue.IDInWOQueue,
          mr_queue.ManagerGrpCode, 
          mr_queue.ResourceCode,   
          mr_queue.Sequence,       
          mr_queue.WOCode,         
          mr_queue.WODetCode,      
          mr_queue.WOEngCode,      
          mr_queue.Qty,            
          mr_queue.DtStart,        
          mr_queue.DtEnd,          
          mr_queue.Excluded,       
          mr_queue.Integrated,     
          mr_queue.DtCreation,     
          mr_queue.DtIntegration,  
          mr_queue.ErrDescription, 
          mr_queue.Selected,       
          mr_queue.DataOrigin,     
          mr_queue.DtTimeStampImp) 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','TBLInWOQueue')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1305_ins_product()#
#-----------------------------#

   INITIALIZE mr_product TO NULL
   
   LET mr_product.IDInProduct = 0
   LET mr_product.PlantCode = '-10'
   LET mr_product.ProductTypeCode = mr_item.ies_tip_item
   LET mr_product.Code = mr_item.cod_item
   LET mr_product.Name = mr_item.den_item
   LET mr_product.Unit1Code = mr_item.cod_unid_med
   LET mr_product.FlgEnable = 1
   LET mr_product.FlgPrintP00 = 0 
   LET mr_product.FlgPrintP01 = 0 
   LET mr_product.FlgPrintP02 = 0 
   LET mr_product.FlgPrintP03 = 0 
   LET mr_product.FlgPrintP04 = 0 
   LET mr_product.FlgPrintP05 = 0 
   LET mr_product.FlgPrintP06 = 0 
   LET mr_product.FlgPrintP07 = 0 
   LET mr_product.FlgPrintP08 = 0 
   LET mr_product.FlgPrintP09 = 0 
   LET mr_product.FlgPrintP10 = 0 
   LET mr_product.FlgPrintP11 = 0 
   LET mr_product.FlgprintP12 = 0 
   LET mr_product.FlgBackFlush = 0
   LET mr_product.Excluded = 0
   LET mr_product.Integrated = 0
   LET mr_product.DtCreation = CURRENT
   LET mr_product.Selected = 0
   
   DELETE FROM TBLInProduct 
    WHERE Code = mr_item.cod_item
   
   INSERT INTO TBLInProduct (
      IDInProduct,
      PlantCode,            
      ProductTypeCode,      
      Code,                 
      Name,                 
      Description,          
      Unit1Code,            
      Unit2Code,            
      Unit2Factor,          
      Unit3Code,            
      Unit3Factor,          
      ExtCode,              
      FlgEnable,            
      FlgPrintP00,          
      FlgPrintP01,          
      FlgPrintP02,          
      FlgPrintP03,          
      FlgPrintP04,          
      FlgPrintP05,          
      FlgPrintP06,          
      FlgPrintP07,          
      FlgPrintP08,          
      FlgPrintP09,          
      FlgPrintP10,          
      FlgPrintP11,          
      FlgprintP12,          
      QtyPackage,           
      QtyProdReport,        
      QtyCEP,               
      QtyQC,                
      ValiditPeriod,        
      ValPeriodUnit,        
      ProductLabelCode,     
      QualityLabelCode,     
      BUnitCode,            
      Yield,                
      WOCriteria,           
      MinLot,               
      EconomicLot,          
      LogLeadTime,          
      QueueLeadTime,        
      CostCenterCode,       
      QtdBillMatCons,       
      DefaultAddressCode,   
      FlgBackFlush,         
      BackFlushType,        
      LotBackFlushType,     
      AddressBackFlushType, 
      SecondName,           
      FamilyProductCode,    
      FamilyProductName,    
      ValueScrap,           
      Label_ItemCode,       
      ReportByLot,          
      BackFlushTypeOrigin,  
      ScrapBFlush,          
      FlgTooling,           
      Excluded,             
      Integrated,           
      DtCreation,           
      DtIntegration,        
      ErrDescription,       
      Selected,             
      DataOrigin,           
      DtTimeStampImp)       
   VALUES(mr_product.IDInProduct,
          mr_product.PlantCode,            
          mr_product.ProductTypeCode,      
          mr_product.Code,                 
          mr_product.Name,                 
          mr_product.Description,          
          mr_product.Unit1Code,            
          mr_product.Unit2Code,            
          mr_product.Unit2Factor,          
          mr_product.Unit3Code,            
          mr_product.Unit3Factor,          
          mr_product.ExtCode,              
          mr_product.FlgEnable,            
          mr_product.FlgPrintP00,          
          mr_product.FlgPrintP01,          
          mr_product.FlgPrintP02,          
          mr_product.FlgPrintP03,          
          mr_product.FlgPrintP04,          
          mr_product.FlgPrintP05,          
          mr_product.FlgPrintP06,          
          mr_product.FlgPrintP07,          
          mr_product.FlgPrintP08,          
          mr_product.FlgPrintP09,          
          mr_product.FlgPrintP10,          
          mr_product.FlgPrintP11,          
          mr_product.FlgprintP12,          
          mr_product.QtyPackage,           
          mr_product.QtyProdReport,        
          mr_product.QtyCEP,               
          mr_product.QtyQC,                
          mr_product.ValiditPeriod,        
          mr_product.ValPeriodUnit,        
          mr_product.ProductLabelCode,     
          mr_product.QualityLabelCode,     
          mr_product.BUnitCode,            
          mr_product.Yield,                
          mr_product.WOCriteria,           
          mr_product.MinLot,               
          mr_product.EconomicLot,          
          mr_product.LogLeadTime,          
          mr_product.QueueLeadTime,        
          mr_product.CostCenterCode,       
          mr_product.QtdBillMatCons,       
          mr_product.DefaultAddressCode,   
          mr_product.FlgBackFlush,         
          mr_product.BackFlushType,        
          mr_product.LotBackFlushType,     
          mr_product.AddressBackFlushType, 
          mr_product.SecondName,           
          mr_product.FamilyProductCode,    
          mr_product.FamilyProductName,    
          mr_product.ValueScrap,           
          mr_product.Label_ItemCode,       
          mr_product.ReportByLot,          
          mr_product.BackFlushTypeOrigin,  
          mr_product.ScrapBFlush,          
          mr_product.FlgTooling,           
          mr_product.Excluded,             
          mr_product.Integrated,           
          mr_product.DtCreation,           
          mr_product.DtIntegration,        
          mr_product.ErrDescription,       
          mr_product.Selected,             
          mr_product.DataOrigin,           
          mr_product.DtTimeStampImp)       

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','TBLInProduct')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
   
#--------------------------------#
FUNCTION pol1305_ins_ordens_912()#
#--------------------------------#

   DELETE FROM ordens_export_912
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,
         ' DELETANDO DADOS DA TABELA ordens_export_912.'
      RETURN FALSE
   END IF

   INSERT INTO ordens_export_912 (
      cod_empresa, 
      num_ordem,   
      qtd_planej,  
      dat_entrega,
      ies_situa)
   VALUES(p_cod_empresa,
          m_num_ordem,
          m_qtd_planej,
          m_dat_entrega,
          m_ies_situa)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ordens_export_912')
      RETURN FALSE
   END IF
              
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1305_chama_delphi()#
#------------------------------#

   CALL LOG_progresspopup_start("Exportando para o PPI...","pol1305_delphi","PROCESS") 
   
   RETURN p_status

END FUNCTION

#------------------------#
FUNCTION pol1305_delphi()#
#------------------------#

   IF NOT pol1305_exp_para_ppi() THEN
      LET p_status = FALSE
   ELSE
      LET p_status = TRUE
   END IF

END FUNCTION

#------------------------------#
FUNCTION pol1305_exp_para_ppi()#
#------------------------------#

   DEFINE l_param         CHAR(05),
          p_comando       CHAR(200),
          l_proces        CHAR(01),
          l_caminho       CHAR(150),
          l_progres       SMALLINT,
          l_dat_atu       CHAR(20)
   
   LET l_dat_atu = CURRENT
           
   LET p_caminho = NULL
   LET l_param = p_cod_empresa, ' ', m_export
  
   DECLARE cq_caminho CURSOR FOR
    SELECT nom_caminho
      FROM path_logix_v2
     WHERE cod_empresa = p_cod_empresa
       AND cod_sistema = 'DPH'

   FOREACH cq_caminho INTO l_caminho
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','path_logix_v2')
         RETURN FALSE
      END IF
      
      LET p_caminho = l_caminho
      
      EXIT FOREACH
   END FOREACH
  
   IF p_caminho IS NULL THEN
      LET p_caminho = 'Caminho do sistema DPH não en-\n',
                      'contrado. Consulte a log1100.'
      CALL log0030_mensagem(p_caminho,'Info')
      RETURN FALSE
   END IF

   SELECT proces_export
     FROM proces_export_factory
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS = 100 THEN
      
      INSERT INTO proces_export_factory(
        cod_empresa, proces_export, proces_import,
        proces_apont, dat_proces)
       VALUES(p_cod_empresa,'s','N','N',l_dat_atu)
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','proces_export_factory')
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','proces_export_factory')
         RETURN FALSE
      END IF
   END IF
   
   LET l_proces = 'S'
   
   UPDATE proces_export_factory
      SET proces_export = l_proces,
          dat_proces = l_dat_atu
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','proces_export_factory')
      RETURN FALSE
   END IF

   LET p_comando = p_caminho CLIPPED, 'pgi1309.exe ', l_param

   CALL conout(p_comando)                            

   CALL runOnClient(p_comando)                       
   
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_op)
   
   WHILE l_proces = 'S'
      
      SELECT proces_export
        INTO l_proces
        FROM proces_export_factory
       WHERE cod_empresa = p_cod_empresa
      
       IF STATUS <> 0 THEN
          LET l_proces = 'N'
       END IF      
       
       LET l_progres = LOG_progresspopup_increment("PROCESS")
       
   END WHILE          
      
   RETURN TRUE
   
END FUNCTION   

#-----------------------------#
FUNCTION pol1305_guarda_erro()#
#-----------------------------#

   IF m_index < 5000 THEN
      LET m_index = m_index + 1
      LET ma_erro[m_index].num_ordem = m_num_ordem
      LET ma_erro[m_index].mensagem = m_msg
   END IF
   
END FUNCTION

#----------------------------#
FUNCTION pol1305_grava_erro()#
#----------------------------#
   
   DEFINE l_ind     INTEGER
         
   FOR l_ind = 1 TO m_index
       INSERT INTO erros_pol1305(cod_empresa, num_ordem, mensagem)
        VALUES(p_cod_empresa, ma_erro[l_ind].num_ordem, ma_erro[l_ind].mensagem)
       IF STATUS <> 0 THEN
          CALL log003_err_sql('INSERT','erros_pol1305')
          RETURN FALSE
       END IF
       IF l_ind >= 5000 THEN
          EXIT FOR
       END IF
   END FOR

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1305_ferramental()#
#-----------------------------#

   LET m_export = 'F'
   IF NOT pol1305_chama_delphi() THEN
      LET m_msg = 'Operação cancelada.'
   ELSE
      LET m_msg = 'Operação efetuada com sicesso.'
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
END FUNCTION

#-----------------------#
FUNCTION pol1305_erros()#
#-----------------------#

   DEFINE l_ind     INTEGER
   
   INITIALIZE ma_erro TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   
   LET l_ind = 1
   
   DECLARE cq_erros CURSOR FOR 
    SELECT num_ordem, mensagem
      FROM erros_pol1305
     WHERE cod_empresa = p_cod_empresa

   FOREACH cq_erros INTO ma_erro[l_ind].num_ordem, ma_erro[l_ind].mensagem
    
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_erros')
         EXIT FOREACH
      END IF
    
      LET l_ind = l_ind + 1
    
      IF l_ind > 5000 THEN
         LET m_msg = 'Numero de erros ultrapassou a capacidade da grade'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_ind = l_ind - 1
   
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", l_ind)

END FUNCTION
   