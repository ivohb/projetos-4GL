#------------------------------------------------------------------#
# AREA....: ADM. DA PRODUÇÃO                                       #
# MODULO..: ENGENHARIA                                             #
# PROGRAMA: MAN10070 {MAN1130, MAN1137}                            #
# AUTOR...: RONAN A. R. KIENEN                                     #
# DATA....: 06/01/2009                                             #
#------------------------------------------------------------------#
 DATABASE logix
 GLOBALS
     DEFINE p_cod_empresa          LIKE empresa.cod_empresa
     DEFINE p_user                 LIKE usuario.nom_usuario
     DEFINE p_status               SMALLINT
 END GLOBALS
 DEFINE m_formmetadata             VARCHAR(50)
 DEFINE m_status                   SMALLINT
 DEFINE m_page_length              SMALLINT
 DEFINE m_processou                SMALLINT
 DEFINE m_utiliza_grade            CHAR(01)
 DEFINE m_multi_empresa            CHAR(01)
 DEFINE m_panel_grade              VARCHAR(10)
 DEFINE m_reportfile               VARCHAR(250)
 DEFINE m_engenharia_grade         CHAR(01)
 DEFINE mr_estrut_grade          RECORD
                                    cod_empresa          LIKE estrut_grade.cod_empresa,
                                    den_empresa          LIKE empresa.den_empresa,
                                    cod_item_pai         LIKE estrut_grade.cod_item_pai,
                                    num_grade_1          CHAR(15), {Grade do item, NUMERO DA GRADE, 1,2,3...}
                                    num_grade_2          CHAR(30),
                                    num_grade_3          CHAR(15),
                                    num_grade_4          CHAR(30),
                                    num_grade_5          CHAR(15),
                                    den_grade_1          CHAR(15), {Descrição da grade do item, LABEL, COR, TAMANHO....}
                                    den_grade_2          CHAR(30),
                                    den_grade_3          CHAR(15),
                                    den_grade_4          CHAR(30),
                                    den_grade_5          CHAR(15),
                                    cod_grade_1          CHAR(15), {Código da grade do item}
                                    cod_grade_2          CHAR(30),
                                    cod_grade_3          CHAR(15),
                                    cod_grade_4          CHAR(30),
                                    cod_grade_5          CHAR(15),
                                    nom_grade_1          CHAR(15), {Descrição do código da grade do item}
                                    nom_grade_2          CHAR(30),
                                    nom_grade_3          CHAR(15),
                                    nom_grade_4          CHAR(30),
                                    nom_grade_5          CHAR(15),
                                    den_item             LIKE item.den_item_reduz,
                                    btn_grade            CHAR(01),
                                    conteudo_base        CHAR(01),
                                    sumariar_componentes CHAR(01),
                                    estrutura_resumida   CHAR(01),
                                    ies_tip_item         LIKE item.ies_tip_item,
                                    ies_refug            CHAR(01),
                                    dat_efetiv           DATE,
                                    qtd_fator            DECIMAL(8,0),
                                    ies_tipo             CHAR(01),
                                    label_tipo_item      CHAR(01),
                                    ies_comprado         CHAR(01),
                                    ies_produzido        CHAR(01),
                                    ies_beneficiado      CHAR(01),
                                    ies_final            CHAR(01),
                                    ies_fantasma         CHAR(01),
                                    ies_estr_res         CHAR(01),
                                    ies_qtd_neces        CHAR(01)
                                 END RECORD
  DEFINE ma_item                 ARRAY[2000] OF RECORD
                                    num_seq          INTEGER,
                                    num_nivel        DECIMAL(2,0),
                                    btn_ies_tip_item CHAR(01),
                                    cod_item         CHAR(15),
                                    den_item_compon  CHAR(18),
                                    ies_tip_item     LIKE item.ies_tip_item,
                                    cod_unid_med     LIKE item.cod_unid_med,
                                    qtd_necessaria   DECIMAL(14,7),
                                    ies_situacao     CHAR(01),
                                    ies_sofre_baixa  CHAR(01),
                                    planejamento     CHAR(01),
                                    cod_grade_1      LIKE estrut_grade.cod_grade_1,
                                    cod_grade_2      LIKE estrut_grade.cod_grade_2,
                                    cod_grade_3      LIKE estrut_grade.cod_grade_3,
                                    cod_grade_4      LIKE estrut_grade.cod_grade_4,
                                    cod_grade_5      LIKE estrut_grade.cod_grade_5
                                 END RECORD
  DEFINE m_num_seq               INTEGER
  DEFINE m_num_nivel             DECIMAL(2,0)
  DEFINE m_ind                   SMALLINT
  DEFINE m_ordenacao             CHAR(01)
  DEFINE m_pct_refug             LIKE item_man.pct_refug
 #-- END MODULARES
#-------------------#
 FUNCTION man10070()
#-------------------#
 DEFINE l_ind  SMALLINT
  CALL fgl_setenv("ADVPL","1")
  CALL log1400_isolation()
  CALL LOG_connectDatabase("DEFAULT")
  CALL log0180_conecta_usuario()
  CALL log001_acessa_usuario("MANUFAT","LOGERP;LOGLQ2")
       RETURNING m_status,p_cod_empresa,p_user
  FOR l_ind = 1 TO 1000
     INITIALIZE ma_item[l_ind].* TO NULL
  END FOR
  IF NOT m_status THEN
     LET m_formmetadata = _ADVPL_create_component(NULL,"LFORMMETADATA")
     CALL _ADVPL_set_property(m_formmetadata,"INIT_FORM","man10070",mr_estrut_grade, ma_item)
  END IF
 END FUNCTION
#-----------------------------#
 FUNCTION man10070_after_load()
#-----------------------------#
  DEFINE l_panel            VARCHAR(10)
  DEFINE l_table_reference  VARCHAR(10)
  DEFINE l_group_reference  VARCHAR(10)
  DEFINE l_layout           VARCHAR(10)
   CALL man10070_cria_tman10070()
   IF NOT man10070_atribui_cod_empresa() THEN
      RETURN FALSE
   END IF
   CALL man10070_cria_panel_grade()
   LET l_table_reference = LOG_retorna_referencia_tabela(m_formmetadata,"item")
   CALL _ADVPL_set_property(l_table_reference,"WIDTH",750)
   CALL _ADVPL_set_property(m_formmetadata,"WHERE_CLAUSE","cod_empresa = '"||p_cod_empresa||"'")
   LET m_processou = FALSE
   IF m_utiliza_grade = 'S' THEN
      CALL man10070_cria_painel_grade()
   END IF
   RETURN TRUE
 END FUNCTION
#-----------------------------------#
 FUNCTION man10070_cria_panel_grade()
#-----------------------------------#
  DEFINE l_table_reference  VARCHAR(10)
  DEFINE l_group_reference  VARCHAR(10)
  DEFINE l_layout           VARCHAR(10)
  DEFINE l_grades           CHAR(400)
  	{IF m_panel_grade IS NULL OR m_panel_grade = ' ' THEN
  	   CALL LOG_retorna_referencia_grupo_componentes(m_formmetadata,'estrut_grade','cod_empresa')
  	   		   RETURNING l_group_reference
      LET m_panel_grade = _ADVPL_create_component(NULL,"LPanel",l_group_reference)
      CALL _ADVPL_set_property(m_panel_grade,"BOUNDS",700,20,200,120)
      LET l_layout = _ADVPL_create_component(NULL, "LLAYOUTMANAGER", m_panel_grade)
      CALL _ADVPL_set_property(l_layout, "COLUMNS_COUNT", 1)
      CALL _ADVPL_set_property(l_layout, "MARGIN", FALSE)
      CALL _ADVPL_set_property(l_layout, "MAX_SIZE", 200,120)
      CALL man101071_cria_grade(p_cod_empresa,l_layout)
   END IF
   CALL man101071_carrega_grade(mr_estrut_grade.cod_item_pai,
	                               mr_estrut_grade.num_grade_1,
	                               mr_estrut_grade.num_grade_2,
	                               mr_estrut_grade.num_grade_3,
	                               mr_estrut_grade.num_grade_4,
	                               mr_estrut_grade.num_grade_5,
	                               mr_estrut_grade.cod_grade_1,
	                               mr_estrut_grade.cod_grade_2,
	                               mr_estrut_grade.cod_grade_3,
	                               mr_estrut_grade.cod_grade_4,
	                               mr_estrut_grade.cod_grade_5)
   CALL _ADVPL_set_property(m_formmetadata,"REFRESH_COMPONENTS")}
   {LET l_grades = ' '
   IF mr_estrut_grade.cod_item_pai IS NOT NULL AND mr_estrut_grade.cod_item_pai <> ' ' THEN
      LET l_grades = man_grade_monta_texto_grades_item(p_cod_empresa,
                                                       mr_estrut_grade.cod_item_pai,
                                                       mr_estrut_grade.cod_grade_1,
                                                       mr_estrut_grade.cod_grade_2,
                                                       mr_estrut_grade.cod_grade_3,
                                                       mr_estrut_grade.cod_grade_4,
                                                       mr_estrut_grade.cod_grade_5,
                                                       FALSE)
   END IF
   CALL LOG_show_status_bar_text(m_formmetadata,l_grades,"INFO_TEXT")
   CALL LOG_refresh_display()}
   RETURN TRUE
 END FUNCTION
#-------------------------------------------#
 FUNCTION man10070_before_edit_event_grade()
#-------------------------------------------#
  DEFINE l_arr_curr                 SMALLINT,
         l_multi_valued_reference   VARCHAR(50),
         l_grades                   CHAR(500)
   CALL man101071_atribui_valores_pesquisa(mr_estrut_grade.cod_grade_1,
																                           mr_estrut_grade.cod_grade_2,
																                           mr_estrut_grade.cod_grade_3,
																                           mr_estrut_grade.cod_grade_4,
																                           mr_estrut_grade.cod_grade_5)
   IF man10070_busca_grade_item(mr_estrut_grade.cod_item_pai, p_cod_empresa) THEN
      IF NOT m_processou THEN
         CALL man101071_cria_popup_grade(p_cod_empresa,mr_estrut_grade.cod_item_pai,"INCL")
      ELSE
         CALL man101071_cria_popup_grade(p_cod_empresa,mr_estrut_grade.cod_item_pai,"PESQ")
      END IF
      CALL man101071_retorna_conteudo_grades()
			        RETURNING mr_estrut_grade.cod_grade_1,
										           mr_estrut_grade.cod_grade_2,
										           mr_estrut_grade.cod_grade_3,
										           mr_estrut_grade.cod_grade_4,
										           mr_estrut_grade.cod_grade_5
	 	  IF mr_estrut_grade.cod_grade_1 IS NULL THEN
	 	     LET mr_estrut_grade.cod_grade_1 = 1 SPACE
	 	  END IF
	 	  IF mr_estrut_grade.cod_grade_2 IS NULL THEN
	 	     LET mr_estrut_grade.cod_grade_2 = 1 SPACE
	 	  END IF
	 	  IF mr_estrut_grade.cod_grade_3 IS NULL THEN
	 	     LET mr_estrut_grade.cod_grade_3 = 1 SPACE
	 	  END IF
	 	  IF mr_estrut_grade.cod_grade_4 IS NULL THEN
	 	     LET mr_estrut_grade.cod_grade_4 = 1 SPACE
	 	  END IF
	 	  IF mr_estrut_grade.cod_grade_5 IS NULL THEN
	 	     LET mr_estrut_grade.cod_grade_5 = 1 SPACE
	 	  END IF
	 ELSE
   	 CALL LOG_mensagem(m_formmetadata,"O item '"||mr_estrut_grade.cod_item_pai CLIPPED||"' não possui grade.", "AVISO",FALSE)
	 END IF
   IF MAN_grade_busca_grades_item(p_cod_empresa,mr_estrut_grade.cod_item_pai,FALSE,0) THEN
	 	   LET mr_estrut_grade.num_grade_1 = MAN_grade_get_grade_1()
	 	   LET mr_estrut_grade.num_grade_2 = MAN_grade_get_grade_2()
	 	   LET mr_estrut_grade.num_grade_3 = MAN_grade_get_grade_3()
	  	  LET mr_estrut_grade.num_grade_4 = MAN_grade_get_grade_4()
	  	  LET mr_estrut_grade.num_grade_5 = MAN_grade_get_grade_5()
   END IF
   CALL man10070_cria_panel_grade()
   RETURN TRUE
	 RETURN TRUE
 END FUNCTION
#--------------------------------------#
 FUNCTION man10070_before_input_inform()
#--------------------------------------#
  DEFINE l_ind               SMALLINT
  DEFINE l_total             SMALLINT
  DEFINE l_table_reference   VARCHAR(10)
  DEFINE l_panel             VARCHAR(30)
   LET l_table_reference = LOG_retorna_referencia_tabela(m_formmetadata,"item")
   LET l_total = LOG_retorna_total_linhas(m_formmetadata,"item")
   LET m_ind   = 0
   INITIALIZE mr_estrut_grade.* TO NULL
   FOR l_ind = 1 TO l_total
      INITIALIZE ma_item[l_ind].* TO NULL
   END FOR
   IF NOT man10070_atribui_cod_empresa() THEN
      RETURN FALSE
   END IF
   CALL LOG_atribui_foco_campo(m_formmetadata,"estrut_grade","cod_item_pai")
   LET m_processou                     = FALSE
   LET mr_estrut_grade.ies_refug       = 'N'
   LET mr_estrut_grade.dat_efetiv      = TODAY
   LET mr_estrut_grade.qtd_fator       = 1
   LET mr_estrut_grade.ies_tipo        = 'S'
   LET mr_estrut_grade.ies_produzido   = 'S'
   LET mr_estrut_grade.ies_comprado    = 'S'
   LET mr_estrut_grade.ies_beneficiado = 'S'
   LET mr_estrut_grade.ies_final       = 'S'
   LET mr_estrut_grade.ies_fantasma    = 'S'
   LET mr_estrut_grade.ies_estr_res    = 'S'
   CALL man10070_change_event_conteudo_base()
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","cod_item_pai",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","conteudo_base",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","sumariar_componentes",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","estrutura_resumida",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_qtd_neces",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_refug",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","dat_efetiv",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","qtd_fator",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_tipo",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_produzido",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_comprado",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_beneficiado",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_final",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_fantasma",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_estr_res",TRUE)
   IF m_utiliza_grade = 'S' THEN
      CALL LOG_habilita_componente(m_formmetadata,"estrut_grade","btn_grade",TRUE)
      #CALL man_clear_table_grade()
      CALL _ADVPL_set_property(l_table_reference,"CAN_ADD_ROW",FALSE)
      CALL _ADVPL_set_property(l_table_reference,"CAN_REMOVE_ROW",FALSE)
      CALL _ADVPL_set_property(l_table_reference,"ITEM_COUNT",0)
      LET l_panel = _ADVPL_get_property(m_formmetadata,"COMPONENT_REFERENCE","estrut_grade","grade_panel")
      CALL _ADVPL_set_property(l_panel,"VISIBLE",FALSE)
      CALL _ADVPL_set_property(l_table_reference,"ITEM_COUNT",0)
      CALL _ADVPL_set_property(l_table_reference,"REFRESH")
      CALL _ADVPL_set_property(l_table_reference,"VISIBLE",TRUE)
   ELSE
      CALL LOG_habilita_componente(m_formmetadata,"estrut_grade","btn_grade",FALSE)
   END IF
   RETURN TRUE
 END FUNCTION
#-------------------------#
 FUNCTION man10070_cancel()
#-------------------------#
  DEFINE l_ind        SMALLINT
  DEFINE l_total      SMALLINT
  INITIALIZE mr_estrut_grade.* TO NULL
  LET l_total = LOG_retorna_total_linhas(m_formmetadata,"item")
  FOR l_ind = 1 TO l_total
     INITIALIZE ma_item[l_ind].* TO NULL
  END FOR
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","cod_item_pai",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","conteudo_base",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","sumariar_componentes",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","estrutura_resumida",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_qtd_neces",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_refug",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","dat_efetiv",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","qtd_fator",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_tipo",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_produzido",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_comprado",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_beneficiado",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_final",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_fantasma",FALSE)
  CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_estr_res",FALSE)
  IF m_utiliza_grade = 'S' THEN
     #CALL man_clear_table_grade()
  END IF
  RETURN TRUE
 END FUNCTION
#---------------------------------------#
 FUNCTION man10070_atribui_cod_empresa()
#---------------------------------------#
  LET mr_estrut_grade.cod_empresa = p_cod_empresa
  RETURN man10070_valida_cod_empresa()
 END FUNCTION
#--------------------------------------#
 FUNCTION man10070_valida_cod_empresa()
#--------------------------------------#
  IF NOT logm2_empresa_leitura(mr_estrut_grade.cod_empresa,FALSE,1) THEN
     RETURN FALSE
  END IF
  LET mr_estrut_grade.den_empresa = logm2_empresa_get_den_empresa()
  RETURN TRUE
 END FUNCTION
#-------------------------------------#
 FUNCTION man10070_valid_cod_item_pai()
#-------------------------------------#
  CALL LOG_show_status_bar_text(m_formmetadata,"Efetue o processamento previamente.","ERROR_TEXT")
  WHENEVER ERROR CONTINUE
    SELECT den_item_reduz,
           ies_tip_item
      INTO mr_estrut_grade.den_item,
           mr_estrut_grade.ies_tip_item
      FROM item
     WHERE item.cod_empresa = p_cod_empresa
       AND item.cod_item    = mr_estrut_grade.cod_item_pai
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
     CALL LOG_mensagem(m_formmetadata,"Código do item não cadastrado. ","AVISO",FALSE)
     RETURN FALSE
  ELSE
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("SELECT","item")
     END IF
  END IF
  RETURN TRUE
 END FUNCTION
#-------------------------------------#
 FUNCTION man10070_after_cod_item_pai()
#-------------------------------------#
  DEFINE l_panel            VARCHAR(30)
   RETURN TRUE
 END FUNCTION
#-------------------------------------------#
 FUNCTION man10070_before_zoom_cod_item_pai()
#-------------------------------------------#
  DEFINE l_sql   CHAR(100)
   LET l_sql = " item.cod_empresa = '", p_cod_empresa, "'" CLIPPED
   CALL LOG_zoom_set_where_clause(l_sql)
   RETURN TRUE
 END FUNCTION
#------------------------------------------#
 FUNCTION man10070_after_zoom_cod_item_pai()
#------------------------------------------#
 DEFINE l_item    CHAR(15)
   LET l_item = LOG_retorna_valor_zoom_campo(m_formmetadata,"estrut_grade","cod_item_pai","item","cod_item")
   IF  l_item IS NOT NULL AND l_item <> " " THEN
       LET mr_estrut_grade.den_item = LOG_retorna_valor_zoom_campo(m_formmetadata,"estrut_grade","cod_item_pai","item","den_item_reduz")
   END IF
   WHENEVER ERROR CONTINUE
     SELECT ies_tip_item
       INTO mr_estrut_grade.ies_tip_item
       FROM item
      WHERE item.cod_empresa = p_cod_empresa
        AND item.cod_item    = l_item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
      CALL log003_err_sql("SELECT","item")
      RETURN FALSE
   END IF
   RETURN TRUE
 END FUNCTION
#---------------------------------#
 FUNCTION man10070_confirm_inform()
#---------------------------------#
   DEFINE l_panel     VARCHAR(10)
   DEFINE l_component VARCHAR(10)
   LET m_num_nivel = 0
   LET m_num_seq   = 0
   IF (mr_estrut_grade.cod_grade_1 IS NULL OR mr_estrut_grade.cod_grade_1 = ' ')
   AND (mr_estrut_grade.cod_grade_2 IS NULL OR mr_estrut_grade.cod_grade_2 = ' ')
   AND (mr_estrut_grade.cod_grade_3 IS NULL OR mr_estrut_grade.cod_grade_3 = ' ')
   AND (mr_estrut_grade.cod_grade_4 IS NULL OR mr_estrut_grade.cod_grade_4 = ' ')
   AND (mr_estrut_grade.cod_grade_5 IS NULL OR mr_estrut_grade.cod_grade_5 = ' ') THEN
      CALL LOG0030_mensagem('Informe o conteúdo da grade do item ou marque o campo "Conteúdo base".','excl')
      RETURN FALSE
   END IF
   IF  mr_estrut_grade.ies_produzido = 'N'
   AND mr_estrut_grade.ies_comprado = 'N'
   AND mr_estrut_grade.ies_beneficiado = 'N'
   AND mr_estrut_grade.ies_final = 'N'
   AND mr_estrut_grade.ies_fantasma = 'N' THEN
       CALL _ADVPL_message_box("Pelo menos um tipo de item deve ser informado.")
       LET l_component = _ADVPL_get_property(m_formmetadata,"COMPONENT_REFERENCE","estrut_grade","ies_produzido")
       CALL _ADVPL_set_property(l_component,"FORCE_GET_FOCUS")
       RETURN FALSE
   END IF
   RETURN TRUE
END FUNCTION
#-----------------------------------#
 FUNCTION man10070_confirm_process()
#-----------------------------------#
  CALL LOG_set_progress_text('Processando estrutura do item...','PROCESS')
  CALL LOG_progress_start("Montando Consulta","man10070_processa","PROCESS")
  #CALL LOG_habilita_componente(m_formmetadata,"estrut_grade","btn_grade",FALSE)
  LET m_processou = TRUE
  RETURN TRUE
 END FUNCTION
 #---------------------------#
 FUNCTION man10070_processa()
#----------------------------#
 DEFINE l_panel     VARCHAR(10)
 DEFINE l_component VARCHAR(10)
   LET m_num_nivel = 0
   LET m_num_seq   = 0
   CALL man10070_deleta_tman10070()
   IF mr_estrut_grade.dat_efetiv IS NULL THEN
      IF man10070_monta_estrutura(mr_estrut_grade.cod_item_pai,
                                  mr_estrut_grade.cod_grade_1,
                                  mr_estrut_grade.cod_grade_2,
                                  mr_estrut_grade.cod_grade_3,
                                  mr_estrut_grade.cod_grade_4,
                                  mr_estrut_grade.cod_grade_5,
                                  NULL) THEN
         CALL man10070_monta_cursor()
      END IF
   ELSE
      IF man10070_monta_estrut_data(mr_estrut_grade.cod_item_pai,
                                    mr_estrut_grade.cod_grade_1,
                                    mr_estrut_grade.cod_grade_2,
                                    mr_estrut_grade.cod_grade_3,
                                    mr_estrut_grade.cod_grade_4,
                                    mr_estrut_grade.cod_grade_5,
                                    NULL) THEN
         CALL man10070_monta_cursor()
      END IF
   END IF
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","cod_item_pai",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","conteudo_base",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","sumariar_componentes",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","estrutura_resumida",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_qtd_neces",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_refug",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","dat_efetiv",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","qtd_fator",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_tipo",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_produzido",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_comprado",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_beneficiado",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_final",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_fantasma",FALSE)
   CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_estr_res",FALSE)
   LET l_panel = _ADVPL_get_property(m_formmetadata,"COMPONENT_REFERENCE","estrut_grade","grade_panel")
   CALL _ADVPL_set_property(l_panel,"VISIBLE",TRUE)
   CALL _ADVPL_set_property(l_panel,"ENABLE",TRUE)
   CALL man10070_before_row()
   RETURN TRUE
END FUNCTION
#-----------------------------------#
 FUNCTION man10070_deleta_tman10070()
#-----------------------------------#
  WHENEVER ERROR CONTINUE
  DELETE FROM tman10070
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DELETE","tman10070")
     RETURN FALSE
  END IF
 END FUNCTION
#--------------------------------------------#
 FUNCTION man10070_monta_estrutura(l_cod_item,
                                   l_cod_grade_1,
                                   l_cod_grade_2,
                                   l_cod_grade_3,
                                   l_cod_grade_4,
                                   l_cod_grade_5,
                                   l_qtd_neces)
#--------------------------------------------#
  DEFINE l_count, l_ind      INTEGER
  DEFINE sql_stmt            CHAR(1000)
  DEFINE l_cod_item          LIKE item.cod_item
  DEFINE l_cod_grade_1       LIKE estrut_grade.cod_grade_1
  DEFINE l_cod_grade_2       LIKE estrut_grade.cod_grade_2
  DEFINE l_cod_grade_3       LIKE estrut_grade.cod_grade_3
  DEFINE l_cod_grade_4       LIKE estrut_grade.cod_grade_4
  DEFINE l_cod_grade_5       LIKE estrut_grade.cod_grade_5
  DEFINE l_qtd_neces         LIKE estrutura.qtd_necessaria
  DEFINE l_cont_gauge        SMALLINT
  DEFINE l_status            SMALLINT
  DEFINE l_grava             SMALLINT
  DEFINE la_estrut   ARRAY[2000] OF RECORD
                      item_compon   LIKE item.cod_item,
                      qtd_neces     LIKE estrutura.qtd_necessaria,
                      pct_refug     LIKE estrutura.pct_refug,
                      parametros    LIKE estrutura.parametros, #OS 370268 VIVIAN CREMER
                      cod_grade_1   LIKE estrut_grade.cod_grade_1,
                      cod_grade_2   LIKE estrut_grade.cod_grade_2,
                      cod_grade_3   LIKE estrut_grade.cod_grade_3,
                      cod_grade_4   LIKE estrut_grade.cod_grade_4,
                      cod_grade_5   LIKE estrut_grade.cod_grade_5,
                      ies_tip_item  LIKE item.ies_tip_item
                    END RECORD
   INITIALIZE sql_stmt TO NULL
   LET sql_stmt = sql_stmt CLIPPED,
    "SELECT estrut_grade.cod_item_compon, ",
          " estrut_grade.qtd_necessaria, ",
          " estrut_grade.pct_refug, ",
          " estrut_grade.parametros, ",
          " estrut_grade.cod_grade_comp_1, ",
          " estrut_grade.cod_grade_comp_2, ",
          " estrut_grade.cod_grade_comp_3, ",
          " estrut_grade.cod_grade_comp_4, ",
          " estrut_grade.cod_grade_comp_5, ",
          " item.ies_tip_item ",
     " FROM estrut_grade, item, item_man ",
    " WHERE estrut_grade.cod_empresa  = '",p_cod_empresa,"' ",
      " AND estrut_grade.cod_item_pai = '",l_cod_item,"' ",
      " AND item.cod_empresa          = estrut_grade.cod_empresa ",
      " AND item.cod_item             = estrut_grade.cod_item_compon "
   IF l_cod_grade_1 IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND (estrut_grade.cod_grade_1 = '"||l_cod_grade_1||"' OR estrut_grade.cod_grade_1 = ' ') "
   END IF
   IF l_cod_grade_2 IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND (estrut_grade.cod_grade_2 = '"||l_cod_grade_2||"' OR estrut_grade.cod_grade_2 = ' ') "
   END IF
   IF l_cod_grade_3 IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND (estrut_grade.cod_grade_3 = '"||l_cod_grade_3||"' OR estrut_grade.cod_grade_3 = ' ') "
   END IF
   IF l_cod_grade_4 IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND (estrut_grade.cod_grade_4 = '"||l_cod_grade_4||"' OR estrut_grade.cod_grade_4 = ' ') "
   END IF
   IF l_cod_grade_5 IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND (estrut_grade.cod_grade_5 = '"||l_cod_grade_5||"' OR estrut_grade.cod_grade_5 = ' ') "
   END IF
   IF m_ordenacao = 'A' OR m_ordenacao = 'I' THEN
      LET sql_stmt = sql_stmt CLIPPED," ORDER BY estrut_grade.parametros, estrut_grade.cod_item_compon"
   ELSE
      LET sql_stmt = sql_stmt CLIPPED," ORDER BY estrut_grade.cod_item_compon"
   END IF
   PREPARE var_query FROM sql_stmt
   DECLARE cq_estrutura CURSOR WITH HOLD FOR var_query
   LET l_count = 1
   FOREACH cq_estrutura INTO la_estrut[l_count].*

     IF mr_estrut_grade.ies_qtd_neces = 'S' AND l_qtd_neces IS NOT NULL THEN
        LET la_estrut[l_count].qtd_neces = la_estrut[l_count].qtd_neces * l_qtd_neces
     END IF

     LET l_count = l_count + 1
     IF l_count > 2000 THEN
        CALL LOG_mensagem(m_formmetadata," Estrutura com mais de 2000 itens filhos ","AVISO",FALSE)
        RETURN FALSE
     END IF

   END FOREACH
   FREE cq_estrutura
   LET l_count = l_count - 1
   IF m_num_nivel = 0 THEN
      CALL LOG_progress_set_total(l_count,"P","PROCESS")
   END IF
   FOR l_ind = 1 TO l_count
       IF m_num_nivel = 0 THEN
          LET l_status = LOG_progress_increment('PROCESS')
       END IF
       LET m_num_nivel = m_num_nivel + 1
       #LET la_estrut[l_ind].qtd_neces = la_estrut[l_ind].qtd_neces * mr_estrut_grade.qtd_fator
       IF mr_estrut_grade.ies_refug = "I" OR
          mr_estrut_grade.ies_refug = "A" THEN
          IF man10070_busca_pct_refug(la_estrut[l_ind].item_compon) THEN
             LET la_estrut[l_ind].qtd_neces = la_estrut[l_ind].qtd_neces*(100/(100-m_pct_refug))
          ELSE
             LET la_estrut[l_ind].qtd_neces = 0
          END IF
       END IF
       IF mr_estrut_grade.ies_refug = "E" OR
          mr_estrut_grade.ies_refug = "A" THEN
          LET la_estrut[l_ind].qtd_neces = la_estrut[l_ind].qtd_neces*(100/(100-la_estrut[l_ind].pct_refug))
       END IF
       LET l_grava = TRUE
       CASE la_estrut[l_ind].ies_tip_item
         WHEN 'P'
           IF mr_estrut_grade.ies_produzido <> 'S' THEN
             LET l_grava = FALSE
           END IF
         WHEN 'C'
           IF mr_estrut_grade.ies_comprado <> 'S' THEN
              LET l_grava = FALSE
           END IF
         WHEN 'B'
           IF mr_estrut_grade.ies_beneficiado <> 'S' THEN
              LET l_grava = FALSE
           END IF
         WHEN 'F'
           IF mr_estrut_grade.ies_final <> 'S' THEN
              LET l_grava = FALSE
           END IF
         WHEN 'T'
           IF mr_estrut_grade.ies_fantasma <> 'S' THEN
              LET l_grava = FALSE
           END IF
       END CASE
       IF l_grava = TRUE THEN
          IF NOT man10070_grava_tman10070(la_estrut[l_ind].item_compon,
                                          la_estrut[l_ind].qtd_neces,
                                          la_estrut[l_ind].ies_tip_item,
                                          la_estrut[l_ind].cod_grade_1,
                                          la_estrut[l_ind].cod_grade_2,
                                          la_estrut[l_ind].cod_grade_3,
                                          la_estrut[l_ind].cod_grade_4,
                                          la_estrut[l_ind].cod_grade_5) THEN
             RETURN FALSE
          END IF
       END IF
       IF mr_estrut_grade.estrutura_resumida <> 'S' THEN
          IF NOT man10070_monta_estrutura(la_estrut[l_ind].item_compon,
                                          la_estrut[l_ind].cod_grade_1,
                                          la_estrut[l_ind].cod_grade_2,
                                          la_estrut[l_ind].cod_grade_3,
                                          la_estrut[l_ind].cod_grade_4,
                                          la_estrut[l_ind].cod_grade_5,
                                          la_estrut[l_ind].qtd_neces) THEN
             RETURN FALSE
          END IF
       END IF
       LET m_ind = m_ind + 1
       LET m_num_nivel = m_num_nivel - 1
   END FOR
   RETURN TRUE
 END FUNCTION
#-------------------------------------------------#
 FUNCTION man10070_monta_estrut_data(l_cod_item,
                                     l_cod_grade_1,
                                     l_cod_grade_2,
                                     l_cod_grade_3,
                                     l_cod_grade_4,
                                     l_cod_grade_5,
                                     l_qtd_neces)
#-------------------------------------------------#
  DEFINE l_cod_item          LIKE item.cod_item
  DEFINE l_count, l_ind      INTEGER
  DEFINE sql_stmt            CHAR(2000)
  DEFINE l_den_item          LIKE item.den_item
  DEFINE l_cod_unid_med      LIKE item.cod_unid_med
  DEFINE l_ies_tip_item      LIKE item.ies_tip_item
  DEFINE l_table_reference   VARCHAR(10)
  DEFINE l_pct_refug         LIKE estrutura.pct_refug
  DEFINE l_status            SMALLINT
  DEFINE l_grava             SMALLINT
  DEFINE l_cod_grade_1       LIKE estrut_grade.cod_grade_1
  DEFINE l_cod_grade_2       LIKE estrut_grade.cod_grade_2
  DEFINE l_cod_grade_3       LIKE estrut_grade.cod_grade_3
  DEFINE l_cod_grade_4       LIKE estrut_grade.cod_grade_4
  DEFINE l_cod_grade_5       LIKE estrut_grade.cod_grade_5
  DEFINE l_qtd_neces         LIKE estrutura.qtd_necessaria
  DEFINE la_estrut           ARRAY[2000] OF RECORD
                              item_compon   LIKE item.cod_item,
                              qtd_neces     LIKE estrutura.qtd_necessaria,
                              pct_refug     LIKE estrutura.pct_refug,
                              parametros    LIKE estrutura.parametros, #OS 370268 VIVIAN CREMER
                              cod_grade_1   LIKE estrut_grade.cod_grade_1,
                              cod_grade_2   LIKE estrut_grade.cod_grade_2,
                              cod_grade_3   LIKE estrut_grade.cod_grade_3,
                              cod_grade_4   LIKE estrut_grade.cod_grade_4,
                              cod_grade_5   LIKE estrut_grade.cod_grade_5,
                              ies_tip_item  LIKE item.ies_tip_item
                             END RECORD
   INITIALIZE sql_stmt TO NULL
   LET l_table_reference = LOG_retorna_referencia_tabela(m_formmetadata,"item")
   LET sql_stmt = sql_stmt CLIPPED,
   "SELECT estrut_grade.cod_item_compon, ",
         " estrut_grade.qtd_necessaria,  ",
         " estrut_grade.pct_refug,       ",
         " estrut_grade.parametros,      ",
         " estrut_grade.cod_grade_comp_1,     ",
         " estrut_grade.cod_grade_comp_2,     ",
         " estrut_grade.cod_grade_comp_3,     ",
         " estrut_grade.cod_grade_comp_4,     ",
         " estrut_grade.cod_grade_comp_5,     ",
         " item.ies_tip_item  ",
    " FROM estrut_grade, item ",
   " WHERE estrut_grade.cod_empresa  = '",p_cod_empresa,"' ",
     " AND estrut_grade.cod_item_pai = '",l_cod_item,"'  ",
     " AND ((estrut_grade.dat_validade_ini IS NULL AND estrut_grade.dat_validade_fim IS NULL) OR ",
          " (estrut_grade.dat_validade_ini IS NULL AND estrut_grade.dat_validade_fim >= '",mr_estrut_grade.dat_efetiv,"') OR ",
          " (estrut_grade.dat_validade_fim IS NULL AND estrut_grade.dat_validade_ini <= '",mr_estrut_grade.dat_efetiv,"') OR ",
          " ('",mr_estrut_grade.dat_efetiv,"' BETWEEN estrut_grade.dat_validade_ini AND estrut_grade.dat_validade_fim)) ",
    "  AND item.cod_empresa   = estrut_grade.cod_empresa ",
    "  AND item.cod_item      = estrut_grade.cod_item_compon "
   IF l_cod_grade_1 IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND (estrut_grade.cod_grade_1 = '"||l_cod_grade_1||"' OR estrut_grade.cod_grade_1 = ' ') "
   END IF
   IF l_cod_grade_2 IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND (estrut_grade.cod_grade_2 = '"||l_cod_grade_2||"' OR estrut_grade.cod_grade_2 = ' ') "
   END IF
   IF l_cod_grade_3 IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND (estrut_grade.cod_grade_3 = '"||l_cod_grade_3||"' OR estrut_grade.cod_grade_3 = ' ') "
   END IF
   IF l_cod_grade_4 IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND (estrut_grade.cod_grade_4 = '"||l_cod_grade_4||"' OR estrut_grade.cod_grade_4 = ' ') "
   END IF
   IF l_cod_grade_5 IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND (estrut_grade.cod_grade_5 = '"||l_cod_grade_5||"' OR estrut_grade.cod_grade_5 = ' ') "
   END IF
   IF m_ordenacao = 'A' OR
      m_ordenacao = 'I' THEN
      LET sql_stmt = sql_stmt CLIPPED,
       " ORDER BY estrut_grade.parametros, estrut_grade.cod_item_compon"
   ELSE
      LET sql_stmt = sql_stmt CLIPPED,
       " ORDER BY estrut_grade.cod_item_compon"
   END IF
   PREPARE var_query1 FROM sql_stmt
   DECLARE cq_estrut_data CURSOR WITH HOLD FOR var_query1
   LET l_count = 1
   FOREACH cq_estrut_data INTO la_estrut[l_count].*

     IF mr_estrut_grade.ies_qtd_neces = 'S' AND l_qtd_neces IS NOT NULL THEN
        LET la_estrut[l_count].qtd_neces = la_estrut[l_count].qtd_neces * l_qtd_neces
     END IF

     LET l_count = l_count + 1
     IF l_count > 2000 THEN
        CALL LOG_mensagem(m_formmetadata," Estrutura com mais de 2000 itens filhos. ","AVISO",FALSE)
        RETURN FALSE
     END IF

   END FOREACH
   LET l_count = l_count - 1
   IF m_num_nivel = 0 THEN
      CALL LOG_progress_set_total(l_count,"P","PROCESS")
   END IF
   FOR l_ind = 1 TO l_count
       IF m_num_nivel = 0 THEN
          LET l_status = LOG_progress_increment('PROCESS')
       END IF
       LET m_num_nivel = m_num_nivel + 1
       #LET la_estrut[l_ind].qtd_neces = la_estrut[l_ind].qtd_neces * mr_estrut_grade.qtd_fator
       IF mr_estrut_grade.ies_refug = "I" OR
          mr_estrut_grade.ies_refug = "A" THEN
          IF man10070_busca_pct_refug(la_estrut[l_ind].item_compon) THEN
             LET la_estrut[l_ind].qtd_neces = la_estrut[l_ind].qtd_neces*(100/(100-m_pct_refug))
          ELSE
             LET la_estrut[l_ind].qtd_neces = 0
          END IF
       END IF
       IF mr_estrut_grade.ies_refug = "E" OR
          mr_estrut_grade.ies_refug = "A" THEN
          LET la_estrut[l_ind].qtd_neces = la_estrut[l_ind].qtd_neces*(100/(100-la_estrut[l_ind].pct_refug))
       END IF
       LET l_grava = TRUE
       CASE la_estrut[l_ind].ies_tip_item
         WHEN 'P'
           IF mr_estrut_grade.ies_produzido <> 'S' THEN
             LET l_grava = FALSE
           END IF
         WHEN 'C'
           IF mr_estrut_grade.ies_comprado <> 'S' THEN
              LET l_grava = FALSE
           END IF
         WHEN 'B'
           IF mr_estrut_grade.ies_beneficiado <> 'S' THEN
              LET l_grava = FALSE
           END IF
         WHEN 'F'
           IF mr_estrut_grade.ies_final <> 'S' THEN
              LET l_grava = FALSE
           END IF
         WHEN 'T'
           IF mr_estrut_grade.ies_fantasma <> 'S' THEN
              LET l_grava = FALSE
           END IF
       END CASE
       IF l_grava = TRUE THEN
          IF NOT man10070_grava_tman10070(la_estrut[l_ind].item_compon,
                                          la_estrut[l_ind].qtd_neces,
                                          la_estrut[l_ind].ies_tip_item,
                                          la_estrut[l_ind].cod_grade_1,
                                          la_estrut[l_ind].cod_grade_2,
                                          la_estrut[l_ind].cod_grade_3,
                                          la_estrut[l_ind].cod_grade_4,
                                          la_estrut[l_ind].cod_grade_5) THEN
             RETURN FALSE
          END IF
       END IF
       IF mr_estrut_grade.estrutura_resumida <> 'S' THEN
          IF NOT man10070_monta_estrut_data(la_estrut[l_ind].item_compon,
                                            la_estrut[l_ind].cod_grade_1,
                                            la_estrut[l_ind].cod_grade_2,
                                            la_estrut[l_ind].cod_grade_3,
                                            la_estrut[l_ind].cod_grade_4,
                                            la_estrut[l_ind].cod_grade_5,
                                            la_estrut[l_ind].qtd_neces) THEN
             RETURN FALSE
          END IF
       END IF
       LET m_ind = m_ind + 1
       LET m_num_nivel = m_num_nivel - 1
   END FOR
   RETURN TRUE
 END FUNCTION
#--------------------------------------------#
 FUNCTION man10070_busca_pct_refug(l_cod_item)
#--------------------------------------------#
  DEFINE l_cod_item   LIKE item.cod_item
   INITIALIZE m_pct_refug TO NULL
   WHENEVER ERROR CONTINUE
   SELECT pct_refug
     INTO m_pct_refug
     FROM item_man
    WHERE cod_empresa  = p_cod_empresa
      AND cod_item     = l_cod_item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   ELSE
       RETURN TRUE
   END IF
 END FUNCTION
#---------------------------------#
 FUNCTION man10070_cria_tman10070()
#---------------------------------#
  WHENEVER ERROR CONTINUE
   DROP TABLE tman10070;
  WHENEVER ERROR STOP
  WHENEVER ERROR CONTINUE
  CREATE TEMP TABLE tman10070 (num_seq         INTEGER      NOT NULL,
                               cod_item        CHAR(15)      NOT NULL,
                               num_nivel       INTEGER      NOT NULL,
                               den_item        CHAR(18),
                               qtd_necessaria  DECIMAL(14,7)  NOT NULL,
                               cod_unid_med    CHAR(03)      NOT NULL,
                               ies_tip_item    CHAR(01)      NOT NULL,
                               ies_situacao    CHAR(01),
                               ies_sofre_baixa CHAR(01),
                               planejamento    CHAR(01),
                               cod_grade_1     CHAR(15),
                               cod_grade_2     CHAR(15),
                               cod_grade_3     CHAR(15),
                               cod_grade_4     CHAR(15),
                               cod_grade_5     CHAR(15))WITH NO LOG;
   CREATE INDEX ix_tman10070_1 ON tman10070 (num_seq);
   WHENEVER ERROR STOP
 END FUNCTION
#------------------------------------------------#
 FUNCTION man10070_grava_tman10070(l_cod_item,
                                   l_qtd_neces,
                                   l_ies_tip_item,
                                   l_cod_grade_1,
                                   l_cod_grade_2,
                                   l_cod_grade_3,
                                   l_cod_grade_4,
                                   l_cod_grade_5)
#------------------------------------------------#
  DEFINE l_cod_item          LIKE item.cod_item
  DEFINE l_qtd_neces         LIKE estrutura.qtd_necessaria
  DEFINE l_den_item          LIKE item.den_item
  DEFINE l_cod_unid_med      LIKE item.cod_unid_med
  DEFINE l_ies_tip_item      LIKE item.ies_tip_item
  DEFINE l_ies_situacao      CHAR(01)
  DEFINE l_ies_sofre_baixa   CHAR(01)
  DEFINE l_planejamento      CHAR(01)
  DEFINE l_cod_grade_1       LIKE estrut_grade.cod_grade_1
  DEFINE l_cod_grade_2       LIKE estrut_grade.cod_grade_2
  DEFINE l_cod_grade_3       LIKE estrut_grade.cod_grade_3
  DEFINE l_cod_grade_4       LIKE estrut_grade.cod_grade_4
  DEFINE l_cod_grade_5       LIKE estrut_grade.cod_grade_5
  WHENEVER ERROR CONTINUE
  SELECT a.den_item_reduz,
         a.ies_situacao,
         a.cod_unid_med,
         b.ies_sofre_baixa,
         b.ies_planejamento
    INTO l_den_item,
         l_ies_situacao,
         l_cod_unid_med,
         l_ies_sofre_baixa,
         l_planejamento
    FROM item a,item_man b
   WHERE a.cod_empresa = p_cod_empresa
     AND a.cod_item    = l_cod_item
     AND b.cod_item    = a.cod_item
     AND b.cod_empresa = a.cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
     LET l_den_item = " Não Cadastrado "
     LET l_cod_unid_med = "???"
  END IF
  LET m_num_seq = m_num_seq + 1
  IF m_num_nivel IS NULL OR m_num_nivel = " " THEN
     LET m_num_nivel = 0
  END IF
  WHENEVER ERROR CONTINUE
  INSERT INTO tman10070 (num_seq,
                         cod_item,
                         num_nivel,
                         den_item,
                         qtd_necessaria,
                         cod_unid_med,
                         ies_tip_item,
                         ies_situacao,
                         ies_sofre_baixa,
                         planejamento,
                         cod_grade_1,
                         cod_grade_2,
                         cod_grade_3,
                         cod_grade_4,
                         cod_grade_5)
                 VALUES (m_num_seq,
                         l_cod_item,
                         m_num_nivel,
                         l_den_item,
                         l_qtd_neces,
                         l_cod_unid_med,
                         l_ies_tip_item,
                         l_ies_situacao,
                         l_ies_sofre_baixa,
                         l_planejamento,
                         l_cod_grade_1,
                         l_cod_grade_2,
                         l_cod_grade_3,
                         l_cod_grade_4,
                         l_cod_grade_5)
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("INCLUSAO", "tman10070")
     RETURN FALSE
  END IF
  RETURN TRUE
 END FUNCTION
#-------------------------------#
 FUNCTION man10070_monta_cursor()
#-------------------------------#
  DEFINE sql_stmt            CHAR(1000)
  DEFINE l_ind               SMALLINT
  DEFINE l_table_reference   VARCHAR(10)
   INITIALIZE sql_stmt TO NULL
   LET l_table_reference = LOG_retorna_referencia_tabela(m_formmetadata,"item")
   CALL man10070_seta_linha_array(mr_estrut_grade.cod_item_pai,
                                  mr_estrut_grade.qtd_fator,
                                  mr_estrut_grade.ies_tip_item,
                                  mr_estrut_grade.cod_grade_1,
                                  mr_estrut_grade.cod_grade_2,
                                  mr_estrut_grade.cod_grade_3,
                                  mr_estrut_grade.cod_grade_4,
                                  mr_estrut_grade.cod_grade_5,
                                  1)
   IF mr_estrut_grade.sumariar_componentes = 'S' THEN
      LET sql_stmt = " SELECT cod_item, ",
                            " den_item, ",
                            " cod_unid_med, ",
                            " ies_tip_item, ",
                            " ies_situacao, ",
                            " ies_sofre_baixa, ",
                         " planejamento, ",
                         " cod_grade_1, ",
                         " cod_grade_2, ",
                         " cod_grade_3, ",
                         " cod_grade_4, ",
                         " cod_grade_5, ",
                         " SUM(qtd_necessaria) ",
                    " FROM tman10070 ",
                  " GROUP BY cod_item, ",
                           " den_item, ",
                           " cod_unid_med, ",
                           " ies_tip_item, ",
                           " ies_situacao, ",
                           " ies_sofre_baixa, ",
                           " planejamento, ",
                           " cod_grade_1, ",
                           " cod_grade_2, ",
                           " cod_grade_3, ",
                           " cod_grade_4, ",
                           " cod_grade_5 "
   ELSE
      LET sql_stmt = " SELECT num_seq, ",
                            " cod_item, ",
                            " num_nivel, ",
                            " den_item, ",
                            " qtd_necessaria, ",
                            " cod_unid_med, ",
                            " ies_tip_item, ",
                            " ies_situacao, ",
                            " ies_sofre_baixa, ",
                            " planejamento, ",
                            " cod_grade_1, ",
                            " cod_grade_2, ",
                            " cod_grade_3, ",
                            " cod_grade_4, ",
                            " cod_grade_5 ",
                       " FROM tman10070 "
      IF mr_estrut_grade.estrutura_resumida = 'S' THEN
         LET sql_stmt = sql_stmt CLIPPED," ORDER BY cod_item "
      ELSE
         LET sql_stmt = sql_stmt CLIPPED," ORDER BY num_seq "
      END IF
   END IF
   WHENEVER ERROR CONTINUE
   PREPARE var_query FROM sql_stmt
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("PREPARE", "var_query")
      RETURN FALSE
   END IF
   WHENEVER ERROR CONTINUE
   DECLARE cq_tman10070 SCROLL CURSOR WITH HOLD FOR var_query
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE", "cq_tman10070")
      RETURN FALSE
   END IF
   LET l_ind = 2
   IF mr_estrut_grade.sumariar_componentes = 'S' THEN
      WHENEVER ERROR CONTINUE
      FOREACH cq_tman10070 INTO ma_item[l_ind].cod_item,
                                ma_item[l_ind].den_item_compon,
                                ma_item[l_ind].cod_unid_med,
                                ma_item[l_ind].ies_tip_item,
                                ma_item[l_ind].ies_situacao,
                                ma_item[l_ind].ies_sofre_baixa,
                                ma_item[l_ind].planejamento,
                                ma_item[l_ind].cod_grade_1,
                                ma_item[l_ind].cod_grade_2,
                                ma_item[l_ind].cod_grade_3,
                                ma_item[l_ind].cod_grade_4,
                                ma_item[l_ind].cod_grade_5,
                                ma_item[l_ind].qtd_necessaria

         INITIALIZE ma_item[l_ind].num_nivel TO NULL
         LET ma_item[l_ind].btn_ies_tip_item = ma_item[l_ind].ies_tip_item
         LET ma_item[l_ind].qtd_necessaria = ma_item[l_ind].qtd_necessaria * mr_estrut_grade.qtd_fator
         LET l_ind = l_ind + 1

         IF l_ind > 2000 THEN
            CALL LOG_mensagem(m_formmetadata," Item com mais de 2000 componentes. O sistema mostrará apenas os 2000 primeiros registros. ","AVISO",TRUE)
            EXIT FOREACH
         END IF

      END FOREACH
      CLOSE cq_tman10070
      FREE cq_tman10070
      WHENEVER ERROR STOP

   ELSE

      WHENEVER ERROR CONTINUE
      FOREACH cq_tman10070 INTO ma_item[l_ind].num_seq,
                                ma_item[l_ind].cod_item,
                                ma_item[l_ind].num_nivel,
                                ma_item[l_ind].den_item_compon,
                                ma_item[l_ind].qtd_necessaria,
                                ma_item[l_ind].cod_unid_med,
                                ma_item[l_ind].ies_tip_item,
                                ma_item[l_ind].ies_situacao,
                                ma_item[l_ind].ies_sofre_baixa,
                                ma_item[l_ind].planejamento,
                                ma_item[l_ind].cod_grade_1,
                                ma_item[l_ind].cod_grade_2,
                                ma_item[l_ind].cod_grade_3,
                                ma_item[l_ind].cod_grade_4,
                                ma_item[l_ind].cod_grade_5

         LET ma_item[l_ind].btn_ies_tip_item = ma_item[l_ind].ies_tip_item
         LET ma_item[l_ind].qtd_necessaria = ma_item[l_ind].qtd_necessaria * mr_estrut_grade.qtd_fator
         LET l_ind = l_ind + 1

         IF l_ind > 2000 THEN
            CALL LOG_mensagem(m_formmetadata," Item com mais de 2000 componentes. O sistema mostrará apenas os 2000 primeiros registros. ","AVISO",TRUE)
            EXIT FOREACH
         END IF

      END FOREACH
      CLOSE cq_tman10070
      FREE cq_tman10070
      WHENEVER ERROR STOP
   END IF
   LET l_ind = l_ind - 1
   CALL _ADVPL_set_property(l_table_reference,"ITEM_COUNT",l_ind)
   CALL _ADVPL_set_property(l_table_reference,"EDITABLE",TRUE)
   CALL LOG_enable_component(m_formmetadata,NULL,"item","btn_ies_tip_item",TRUE)
   CALL _ADVPL_set_property(l_table_reference,"REFRESH")
 END FUNCTION
#------------------------------#
 FUNCTION man10070_before_row()
#------------------------------#
  DEFINE l_arr_curr          SMALLINT
  DEFINE l_table_reference   VARCHAR(10)
   LET l_table_reference = LOG_retorna_referencia_tabela(m_formmetadata,"item")
	  LET l_arr_curr        = _ADVPL_get_property(l_table_reference,"ITEM_SELECTED")
	  IF l_arr_curr = -1 OR l_arr_curr = 0 THEN
	     LET l_arr_curr = 1
	  END IF
   CALL man10070_grade(l_arr_curr)
 END FUNCTION
#----------------------------------#
 FUNCTION man10070_grade(l_arr_curr)
#----------------------------------#
 DEFINE l_panel               VARCHAR(30)
 DEFINE l_cod_grade_1         CHAR(15),
        l_cod_grade_2         CHAR(15),
        l_cod_grade_3         CHAR(15),
        l_cod_grade_4         CHAR(15),
        l_cod_grade_5         CHAR(15),
        l_arr_curr            SMALLINT
	 IF MAN_grade_busca_grades_item(p_cod_empresa,ma_item[l_arr_curr].cod_item,FALSE,0) = TRUE THEN
	 	  LET l_cod_grade_1 = MAN_grade_get_grade_1()
	 	  LET l_cod_grade_2 = MAN_grade_get_grade_2()
	 	  LET l_cod_grade_3 = MAN_grade_get_grade_3()
	 	  LET l_cod_grade_4 = MAN_grade_get_grade_4()
	 	  LET l_cod_grade_5 = MAN_grade_get_grade_5()
  END IF
  CALL man_carrega_grade(ma_item[l_arr_curr].cod_item,
	                        l_cod_grade_1,
	                        l_cod_grade_2,
	                        l_cod_grade_3,
	                        l_cod_grade_4,
	                        l_cod_grade_5,
	                        ma_item[l_arr_curr].cod_grade_1,
	                        ma_item[l_arr_curr].cod_grade_2,
	                        ma_item[l_arr_curr].cod_grade_3,
	                        ma_item[l_arr_curr].cod_grade_4,
	                        ma_item[l_arr_curr].cod_grade_5)
  RETURN TRUE
 END FUNCTION
#------------------------------------#
 FUNCTION man10070_cria_painel_grade()
#------------------------------------#
 DEFINE l_panel            VARCHAR(30)
 DEFINE l_layout           VARCHAR(30)
  LET l_panel = _ADVPL_get_property(m_formmetadata,"COMPONENT_REFERENCE","estrut_grade","grade_panel")
  LET l_layout = _ADVPL_create_component(NULL, "LLAYOUTMANAGER", l_panel)
  CALL _ADVPL_set_property(l_layout, "COLUMNS_COUNT", 1)
  CALL _ADVPL_set_property(l_layout, "MARGIN", FALSE)
  CALL _ADVPL_set_property(l_layout, "MAX_SIZE", 200,120)
  CALL man_cria_grade(p_cod_empresa,l_layout)
 END FUNCTION
#-------------------------------#
 FUNCTION man1130_busca_par_pcp()
#-------------------------------#
  DEFINE l_parametros    LIKE par_pcp.parametros
   WHENEVER ERROR CONTINUE
     SELECT parametros
       INTO l_parametros
       FROM par_pcp
      WHERE cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP
   LET m_ordenacao = l_parametros[120]
 END FUNCTION
#------------------------------#
 FUNCTION man10070_before_load()
#------------------------------#
   CALL log2250_busca_parametro(p_cod_empresa, "utiliza_engenharia_grade")
        RETURNING m_engenharia_grade, m_status
   IF m_engenharia_grade IS NULL OR m_engenharia_grade = " " THEN
      LET m_engenharia_grade = 'N'
   END IF
   CALL log2250_busca_parametro(p_cod_empresa, "utiliza_grade")
        RETURNING m_utiliza_grade, m_status
   IF m_utiliza_grade IS NULL OR m_utiliza_grade = " " THEN
      LET m_utiliza_grade = 'N'
   END IF
   IF m_utiliza_grade = 'N' THEN
      CALL log2250_busca_parametro(p_cod_empresa,"multi_empresa")
           RETURNING m_multi_empresa, m_status
      IF m_status = FALSE THEN
         LET m_multi_empresa = 'N'
      END IF
   END IF
   RETURN TRUE
 END FUNCTION
#-------------------------------------------------------------#
 FUNCTION man10070_busca_grade_item(l_cod_item, l_cod_empresa)
#-------------------------------------------------------------#
  DEFINE la_grade     ARRAY[5] OF RECORD
                         num_grade    SMALLINT,
                         tipo_grade   CHAR(15),
                         cod_grade    CHAR(15),
                         den_grade    LIKE grade.den_grade
                      END RECORD
  DEFINE l_cod_empresa   LIKE empresa.cod_empresa,
         l_cod_item      LIKE item.cod_item
   CALL MAN_grade_busca_grades_item(l_cod_empresa, l_cod_item,FALSE,0)
   LET la_grade[1].num_grade = MAN_grade_get_grade_1()
   LET la_grade[2].num_grade = MAN_grade_get_grade_2()
   LET la_grade[3].num_grade = MAN_grade_get_grade_3()
   LET la_grade[4].num_grade = MAN_grade_get_grade_4()
   LET la_grade[5].num_grade = MAN_grade_get_grade_5()
   IF (la_grade[1].num_grade IS NULL OR la_grade[1].num_grade = " ") AND
      (la_grade[2].num_grade IS NULL OR la_grade[2].num_grade = " ") AND
      (la_grade[3].num_grade IS NULL OR la_grade[3].num_grade = " ") AND
      (la_grade[4].num_grade IS NULL OR la_grade[4].num_grade = " ") AND
      (la_grade[5].num_grade IS NULL OR la_grade[5].num_grade = " ") THEN
      RETURN FALSE
   END IF
   RETURN TRUE
 END FUNCTION
#---------------------------------------------#
 FUNCTION man10070_change_event_conteudo_base()
#---------------------------------------------#
   IF mr_estrut_grade.conteudo_base = 'S' THEN
      IF mr_estrut_grade.cod_item_pai IS NULL OR mr_estrut_grade.cod_item_pai = ' ' THEN
         LET mr_estrut_grade.conteudo_base = 'N'
         CALL LOG0030_mensagem('Informe o item pai previamente.','excl')
         RETURN FALSE
      END IF
      WHENEVER ERROR CONTINUE
      SELECT conteudo_base_1,
             conteudo_base_2
        INTO mr_estrut_grade.cod_grade_1,
             mr_estrut_grade.cod_grade_2
        FROM man_item_grade
       WHERE empresa = p_cod_empresa
         AND item    = mr_estrut_grade.cod_item_pai
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
         CALL log003_err_sql("SELECT","man_item_grade")
         RETURN FALSE
      END IF
      LET mr_estrut_grade.cod_grade_3 = ' '
      LET mr_estrut_grade.cod_grade_4 = ' '
      LET mr_estrut_grade.cod_grade_5 = ' '
   ELSE
      INITIALIZE mr_estrut_grade.cod_grade_1,
                 mr_estrut_grade.cod_grade_2,
                 mr_estrut_grade.cod_grade_3,
                 mr_estrut_grade.cod_grade_4,
                 mr_estrut_grade.cod_grade_5 TO NULL
   END IF
   IF MAN_grade_busca_grades_item(p_cod_empresa,mr_estrut_grade.cod_item_pai,FALSE,0) THEN
	 	   LET mr_estrut_grade.num_grade_1 = MAN_grade_get_grade_1()
	 	   LET mr_estrut_grade.num_grade_2 = MAN_grade_get_grade_2()
	 	   LET mr_estrut_grade.num_grade_3 = MAN_grade_get_grade_3()
	  	  LET mr_estrut_grade.num_grade_4 = MAN_grade_get_grade_4()
	  	  LET mr_estrut_grade.num_grade_5 = MAN_grade_get_grade_5()
   END IF
   CALL man10070_cria_panel_grade()
   RETURN TRUE
 END FUNCTION
#----------------------------------------------------#
 FUNCTION man10070_change_event_sumariar_componentes()
#----------------------------------------------------#
   IF mr_estrut_grade.sumariar_componentes <> 'S' THEN
      LET mr_estrut_grade.qtd_fator = 1
      CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","qtd_fator",FALSE)
      CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","estrutura_resumida",TRUE)
   ELSE
      CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","qtd_fator",TRUE)
      CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","estrutura_resumida",FALSE)
      LET mr_estrut_grade.estrutura_resumida = 'N'
      LET mr_estrut_grade.qtd_fator = 1
   END IF
   RETURN TRUE
 END FUNCTION
#--------------------------------------------------#
 FUNCTION man10070_change_event_estrutura_resumida()
#--------------------------------------------------#
   IF mr_estrut_grade.estrutura_resumida <> 'S' THEN
      CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","sumariar_componentes",TRUE)
      CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_qtd_neces",TRUE)
   ELSE
      CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","sumariar_componentes",FALSE)
      LET mr_estrut_grade.sumariar_componentes = 'N'

      CALL LOG_enable_component(m_formmetadata,NULL,"estrut_grade","ies_qtd_neces",FALSE)
      LET mr_estrut_grade.ies_qtd_neces = 'N'
   END IF
   RETURN TRUE
 END FUNCTION
#--------------------------------#
 FUNCTION man10070_confirm_print()
#--------------------------------#
   IF LOG_retorna_total_linhas(m_formmetadata,"item") <= 0 THEN
      CALL LOG_show_status_bar_text(m_formmetadata,"Efetue o processamento previamente.","ERROR_TEXT")
      RETURN TRUE
   END IF
   IF mr_estrut_grade.sumariar_componentes = 'S' THEN
     	CALL StartReport("man10070_start_progress_bar","man10070","Explosão da Estrutura Sumariada",220,TRUE,TRUE)
   ELSE
      IF mr_estrut_grade.estrutura_resumida = 'S' THEN
      	  CALL StartReport("man10070_start_progress_bar","man10070","Explosão da Estrutura Resumida por Nível",220,TRUE,TRUE)
      ELSE
         CALL StartReport("man10070_start_progress_bar","man10070","Explosão da Estrutura Detalhada por Nível",220,TRUE,TRUE)
      END IF
   END IF
   RETURN TRUE
 END FUNCTION
#-------------------------------------------------#
 FUNCTION man10070_start_progress_bar(l_reportfile)
#-------------------------------------------------#
  DEFINE l_reportfile   VARCHAR(250)
   LET m_reportfile = l_reportfile
   LET m_page_length = ReportPageLength("man10070")
   CALL LOG_set_progress_text("Processando o relatório...","PROCESS")
   CALL LOG_progress_start(" Processando...","man10070_gera_relatorio","PROCESS")
   RETURN TRUE
 END FUNCTION
#---------------------------------#
 FUNCTION man10070_gera_relatorio()
#---------------------------------#
  DEFINE l_total       INTEGER,
         l_status      SMALLINT,
         l_ind         SMALLINT,
         l_grade       LIKE man_conteudo_grade.grade
  DEFINE l_grade_1     SMALLINT,
         l_grade_2     SMALLINT,
         l_grade_3     SMALLINT,
         l_grade_4     SMALLINT,
         l_grade_5     SMALLINT
  DEFINE l_den_grade_1 CHAR(30),
         l_den_grade_2 CHAR(30),
         l_den_grade_3 CHAR(30),
         l_den_grade_4 CHAR(30),
         l_den_grade_5 CHAR(30)
  DEFINE lr_dados   RECORD
                       cod_empresa          LIKE item.cod_empresa,
                       cod_item_pai         LIKE item.cod_item,
                       den_item_pai         LIKE item.den_item_reduz,
                       cod_unid_med         LIKE item.cod_unid_med,
                       den_unid_med         LIKE unid_med.den_unid_med_30,
                       ies_refug            CHAR(01),
                       dat_efetiv           DATE,
                       qtd_fator            DECIMAL(8,0),
                       ies_tip_item         CHAR(01),
                       estrutura_resumida   CHAR(01),
                       nivel                SMALLINT,
                       cod_item_compon      LIKE item.cod_item,
                       den_item_compon      LIKE item.den_item_reduz,
                       grade_componente     CHAR(200),
                       cod_unid_med_comp    LIKE item.cod_unid_med,
                       ies_tip_item_comp    CHAR(01),
                       ies_situacao_comp    CHAR(01),
                       ies_sofre_baixa_comp CHAR(01),
                       planejamento         CHAR(01),
                       qtd_necessaria_comp  DECIMAL(14,7)
                    END RECORD
   CALL LOG_progress_set_total(LOG_retorna_total_linhas(m_formmetadata,"item"),'P',"PROCESS")
   IF mr_estrut_grade.sumariar_componentes = 'S' THEN
      START REPORT man10070_relatorio_sumariado TO m_reportfile
   ELSE
      START REPORT man10070_relatorio TO m_reportfile
   END IF
   FOR l_ind = 1 TO (LOG_retorna_total_linhas(m_formmetadata,"item"))
      CALL LOG_progress_increment("PROCESS")
           RETURNING l_status
      IF l_status = FALSE THEN
         EXIT FOR
      END IF
      IF ma_item[l_ind].cod_item = mr_estrut_grade.cod_item_pai THEN
         CONTINUE FOR
      END IF
      CALL manm5_item_leitura(p_cod_empresa,mr_estrut_grade.cod_item_pai, FALSE, 1)
           RETURNING l_status
      LET lr_dados.cod_unid_med         = manm5_item_get_cod_unid_med()
      LET lr_dados.ies_tip_item         = manm5_item_get_ies_tip_item()
      LET lr_dados.cod_empresa          = p_cod_empresa
      LET lr_dados.cod_item_pai         = mr_estrut_grade.cod_item_pai
      LET lr_dados.den_item_pai         = mr_estrut_grade.den_item
      LET lr_dados.den_unid_med         = man10070_busca_den_unid_med(lr_dados.cod_unid_med)
      LET lr_dados.ies_refug            = mr_estrut_grade.ies_refug
      LET lr_dados.dat_efetiv           = mr_estrut_grade.dat_efetiv
      LET lr_dados.qtd_fator            = mr_estrut_grade.qtd_fator
      LET lr_dados.estrutura_resumida   = mr_estrut_grade.estrutura_resumida
      LET lr_dados.nivel                = ma_item[l_ind].num_nivel
      LET lr_dados.cod_item_compon      = ma_item[l_ind].cod_item
      LET lr_dados.den_item_compon      = ma_item[l_ind].den_item_compon
      LET lr_dados.cod_unid_med_comp    = ma_item[l_ind].cod_unid_med
      LET lr_dados.ies_tip_item_comp    = ma_item[l_ind].ies_tip_item
      LET lr_dados.ies_situacao_comp    = ma_item[l_ind].ies_situacao
      LET lr_dados.ies_sofre_baixa_comp = ma_item[l_ind].ies_sofre_baixa
      LET lr_dados.planejamento         = ma_item[l_ind].planejamento
      LET lr_dados.qtd_necessaria_comp  = ma_item[l_ind].qtd_necessaria
      LET lr_dados.grade_componente     = man_grade_monta_texto_grades_item(lr_dados.cod_empresa,
                                                                            lr_dados.cod_item_compon,
                                                                            ma_item[l_ind].cod_grade_1,
                                                                            ma_item[l_ind].cod_grade_2,
                                                                            ma_item[l_ind].cod_grade_3,
                                                                            ma_item[l_ind].cod_grade_4,
                                                                            ma_item[l_ind].cod_grade_5,
                                                                            FALSE)
      IF mr_estrut_grade.sumariar_componentes = 'S' THEN
         OUTPUT TO REPORT man10070_relatorio_sumariado(lr_dados.*)
      ELSE
         OUTPUT TO REPORT man10070_relatorio(lr_dados.*)
      END IF
   END FOR
   IF mr_estrut_grade.sumariar_componentes = 'S' THEN
      FINISH REPORT man10070_relatorio_sumariado
   ELSE
      FINISH REPORT man10070_relatorio
   END IF
   CALL FinishReport("man10070")
   IF l_status = FALSE THEN
      CALL LOG_show_status_bar_text(m_formmetadata,"Processamento cancelado pelo usuário.","ERROR_TEXT")
   END IF
   RETURN l_status
 END FUNCTION
#--------------------------------------------#
 REPORT man10070_relatorio_sumariado(lr_dados)
#--------------------------------------------#
  DEFINE lr_dados   RECORD
                       cod_empresa          LIKE item.cod_empresa,
                       cod_item_pai         LIKE item.cod_item,
                       den_item_pai         LIKE item.den_item_reduz,
                       cod_unid_med         LIKE item.cod_unid_med,
                       den_unid_med         LIKE unid_med.den_unid_med_30,
                       ies_refug            CHAR(01),
                       dat_efetiv           DATE,
                       qtd_fator            DECIMAL(8,0),
                       ies_tip_item         CHAR(01),
                       estrutura_resumida   CHAR(01),
                       nivel                SMALLINT,
                       cod_item_compon      LIKE item.cod_item,
                       den_item_compon      LIKE item.den_item_reduz,
                       grade_componente     CHAR(200),
                       cod_unid_med_comp    LIKE item.cod_unid_med,
                       ies_tip_item_comp    CHAR(01),
                       ies_situacao_comp    CHAR(01),
                       ies_sofre_baixa_comp CHAR(01),
                       planejamento         CHAR(01),
                       qtd_necessaria_comp  DECIMAL(14,7)
                    END RECORD
  DEFINE l_grades   CHAR(80)
   OUTPUT
    RIGHT  MARGIN 80
    LEFT   MARGIN 0
    TOP    MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH m_page_length
  FORMAT
     PAGE HEADER
        CALL ReportPageHeader("man10070")
        PRINT COLUMN 001,"Item pai..........:",lr_dados.cod_item_pai CLIPPED,'-',lr_dados.den_item_pai CLIPPED;
        PRINT COLUMN 048,"Unidade de medida.:",lr_dados.cod_unid_med CLIPPED,'-',lr_dados.den_unid_med CLIPPED
        PRINT COLUMN 001,"Grades............:",man_grade_monta_texto_grades_item(p_cod_empresa,
                                                                                 mr_estrut_grade.cod_item_pai,
                                                                                 mr_estrut_grade.cod_grade_1,
                                                                                 mr_estrut_grade.cod_grade_2,
                                                                                 mr_estrut_grade.cod_grade_3,
                                                                                 mr_estrut_grade.cod_grade_4,
                                                                                 mr_estrut_grade.cod_grade_5,
                                                                                 FALSE)
        PRINT COLUMN 001,"Tipo de refugo....:",lr_dados.ies_refug;
        PRINT COLUMN 047,"Data...........:",lr_dados.dat_efetiv
        PRINT COLUMN 001,"Quantidade........:",lr_dados.qtd_fator USING "<<<<<<<<";
        PRINT COLUMN 047,"Tipo do item.:",man10070_retorna_descricao_ies_tip_item(lr_dados.ies_tip_item);
        PRINT COLUMN 075,"Estrutura resumida:",lr_dados.estrutura_resumida
        SKIP 1 LINE
        IF m_engenharia_grade = 'S' THEN
           IF m_multi_empresa = 'S' THEN
              PRINT COLUMN 001,"Empresa Componente      Descrição          Grades                                                                           UM  Tipo do item Situação baixa? Planejamento             Quantidade aplicada"
              PRINT COLUMN 001,"------- --------------- ------------------ -------------------------------------------------------------------------------- --- ------------ -------- ------ ------------------------ -------------------"
           ELSE
              PRINT COLUMN 001,"Componente      Descrição          Grades                                                                           UM  Tipo do item Situação baixa? Planejamento             Quantidade aplicada"
              PRINT COLUMN 001,"--------------- ------------------ -------------------------------------------------------------------------------- --- ------------ -------- ------ ------------------------ -------------------"
           END IF
        ELSE
           IF m_multi_empresa = 'S' THEN
              PRINT COLUMN 001,"Empresa Componente      Descrição          UM  Tipo do item Situação baixa? Planejamento             Quantidade aplicada"
              PRINT COLUMN 001,"------- --------------- ------------------ --- ------------ -------- ------ ------------------------ -------------------"
           ELSE
              PRINT COLUMN 001,"Componente      Descrição          UM  Tipo do item Situação baixa? Planejamento             Quantidade aplicada"
              PRINT COLUMN 001,"--------------- ------------------ --- ------------ -------- ------ ------------------------ -------------------"
           END IF
        END IF
     ON EVERY ROW
        IF m_engenharia_grade = 'S' THEN
           LET l_grades = lr_dados.grade_componente CLIPPED
           IF m_multi_empresa = 'S' THEN
              PRINT COLUMN 001, lr_dados.cod_empresa,
                    COLUMN 008, lr_dados.cod_item_compon,
                    COLUMN 024, lr_dados.den_item_compon,
                    COLUMN 043, l_grades CLIPPED,
                    COLUMN 124, lr_dados.cod_unid_med_comp,
                    COLUMN 128, man10070_retorna_descricao_ies_tip_item(lr_dados.ies_tip_item_comp),
                    COLUMN 141, man10070_retorna_descricao_ies_situacao(lr_dados.ies_situacao_comp),
                    COLUMN 150, "["||lr_dados.ies_sofre_baixa_comp||"]",
                    COLUMN 157, man10070_retorna_descricao_ies_planejamento(lr_dados.planejamento),
                    COLUMN 182, lr_dados.qtd_necessaria_comp USING "<<<<<<&.&&<<<<<"
           ELSE
              PRINT COLUMN 001, lr_dados.cod_item_compon,
                    COLUMN 017, lr_dados.den_item_compon,
                    COLUMN 036, l_grades CLIPPED,
                    COLUMN 117, lr_dados.cod_unid_med_comp,
                    COLUMN 121, man10070_retorna_descricao_ies_tip_item(lr_dados.ies_tip_item_comp),
                    COLUMN 134, man10070_retorna_descricao_ies_situacao(lr_dados.ies_situacao_comp),
                    COLUMN 143, '['||lr_dados.ies_sofre_baixa_comp||']',
                    COLUMN 150, man10070_retorna_descricao_ies_planejamento(lr_dados.planejamento),
                    COLUMN 175, lr_dados.qtd_necessaria_comp USING "<<<<<<&.&&<<<<<"
           END IF
        ELSE
           IF m_multi_empresa = 'S' THEN
              PRINT COLUMN 001, lr_dados.cod_empresa,
                    COLUMN 009, lr_dados.cod_item_compon,
                    COLUMN 025, lr_dados.den_item_compon,
                    COLUMN 044, lr_dados.cod_unid_med_comp,
                    COLUMN 048, man10070_retorna_descricao_ies_tip_item(lr_dados.ies_tip_item_comp),
                    COLUMN 061, man10070_retorna_descricao_ies_situacao(lr_dados.ies_situacao_comp),
                    COLUMN 070, "["||lr_dados.ies_sofre_baixa_comp||"]",
                    COLUMN 078, man10070_retorna_descricao_ies_planejamento(lr_dados.planejamento),
                    COLUMN 102, lr_dados.qtd_necessaria_comp USING "<<<<<<&.&&<<<<<"
              PRINT COLUMN 001, " Grade: ", lr_dados.grade_componente
              PRINT " "
           ELSE
              PRINT COLUMN 001, lr_dados.cod_item_compon,
                    COLUMN 017, lr_dados.den_item_compon,
                    COLUMN 036, lr_dados.cod_unid_med_comp,
                    COLUMN 040, man10070_retorna_descricao_ies_tip_item(lr_dados.ies_tip_item_comp),
                    COLUMN 053, man10070_retorna_descricao_ies_situacao(lr_dados.ies_situacao_comp),
                    COLUMN 062, '['||lr_dados.ies_sofre_baixa_comp||']',
                    COLUMN 069, man10070_retorna_descricao_ies_planejamento(lr_dados.planejamento),
                    COLUMN 094, lr_dados.qtd_necessaria_comp USING "<<<<<<&.&&<<<<<"
              PRINT COLUMN 001, " Grade: ",lr_dados.grade_componente
              PRINT " "
           END IF
        END IF
 END REPORT
#----------------------------------#
 REPORT man10070_relatorio(lr_dados)
#----------------------------------#
  DEFINE lr_dados   RECORD
                       cod_empresa          LIKE item.cod_empresa,
                       cod_item_pai         LIKE item.cod_item,
                       den_item_pai         LIKE item.den_item_reduz,
                       cod_unid_med         LIKE item.cod_unid_med,
                       den_unid_med         LIKE unid_med.den_unid_med_30,
                       ies_refug            CHAR(01),
                       dat_efetiv           DATE,
                       qtd_fator            DECIMAL(8,0),
                       ies_tip_item         CHAR(01),
                       estrutura_resumida   CHAR(01),
                       nivel                SMALLINT,
                       cod_item_compon      LIKE item.cod_item,
                       den_item_compon      LIKE item.den_item_reduz,
                       grade_componente     CHAR(219),
                       cod_unid_med_comp    LIKE item.cod_unid_med,
                       ies_tip_item_comp    CHAR(01),
                       ies_situacao_comp    CHAR(01),
                       ies_sofre_baixa_comp CHAR(01),
                       planejamento         CHAR(01),
                       qtd_necessaria_comp  DECIMAL(14,7)
                    END RECORD
  DEFINE l_grades   CHAR(80)
   OUTPUT
    RIGHT  MARGIN 80
    LEFT   MARGIN 0
    TOP    MARGIN 0
    BOTTOM MARGIN 0
    PAGE LENGTH m_page_length
  FORMAT
     PAGE HEADER
        CALL ReportPageHeader("man10070")
        PRINT COLUMN 001, "Item pai..........:",lr_dados.cod_item_pai CLIPPED,'-',lr_dados.den_item_pai CLIPPED;
        PRINT COLUMN 048, "Unidade de medida.:",lr_dados.cod_unid_med CLIPPED,'-',lr_dados.den_unid_med CLIPPED
        PRINT COLUMN 001,"Grades............:",man_grade_monta_texto_grades_item(p_cod_empresa,
                                                                                 mr_estrut_grade.cod_item_pai,
                                                                                 mr_estrut_grade.cod_grade_1,
                                                                                 mr_estrut_grade.cod_grade_2,
                                                                                 mr_estrut_grade.cod_grade_3,
                                                                                 mr_estrut_grade.cod_grade_4,
                                                                                 mr_estrut_grade.cod_grade_5,
                                                                                 FALSE)
        PRINT COLUMN 001, "Tipo de refugo....:",lr_dados.ies_refug;
        PRINT COLUMN 047, "Data...........:",lr_dados.dat_efetiv
        PRINT COLUMN 001, "Quantidade........:",lr_dados.qtd_fator USING "<<<<<<<<";
        PRINT COLUMN 047, "Tipo do item.:",man10070_retorna_descricao_ies_tip_item(lr_dados.ies_tip_item);
        PRINT COLUMN 075, "Estrutura resumida:",lr_dados.estrutura_resumida
        SKIP 1 LINE
        IF m_engenharia_grade = 'S' THEN
           IF m_multi_empresa = 'S' THEN
              PRINT COLUMN 001, "Empresa Nível Componente      Descrição          Grades                                                                           UM  Tipo do item Situação baixa? Planejamento             Quantidade aplicada"
              PRINT COLUMN 001, "------- ----- --------------- ------------------ -------------------------------------------------------------------------------- --- ------------ -------- ------ ------------------------ -------------------"
           ELSE
              PRINT COLUMN 001, "Nível Componente      Descrição          Grades                                                                           UM  Tipo do item Situação baixa? Planejamento             Quantidade aplicada"
              PRINT COLUMN 001, "----- --------------- ------------------ -------------------------------------------------------------------------------- --- ------------ -------- ------ ------------------------ -------------------"
           END IF
        ELSE
           IF m_multi_empresa = 'S' THEN
              PRINT COLUMN 001, "Empresa Nível Componente      Descrição          UM  Tipo do item Situação baixa? Planejamento             Quantidade aplicada"
              PRINT COLUMN 001, "------- ----- --------------- ------------------ --- ------------ -------- ------ ------------------------ -------------------"
           ELSE
              PRINT COLUMN 001, "Nível Componente      Descrição          UM  Tipo do item Situação baixa? Planejamento             Quantidade aplicada"
              PRINT COLUMN 001, "----- --------------- ------------------ --- ------------ -------- ------ ------------------------ -------------------"
           END IF
        END IF
     ON EVERY ROW
        IF m_engenharia_grade = 'S' THEN
           LET l_grades = lr_dados.grade_componente
           IF m_multi_empresa = 'S' THEN
              PRINT COLUMN 001, lr_dados.cod_empresa,
                    COLUMN 009, lr_dados.nivel USING "<<<<",
                    COLUMN 016, lr_dados.cod_item_compon,
                    COLUMN 032, lr_dados.den_item_compon,
                    COLUMN 051, l_grades,
                    COLUMN 132, lr_dados.cod_unid_med_comp,
                    COLUMN 136, man10070_retorna_descricao_ies_tip_item(lr_dados.ies_tip_item_comp),
                    COLUMN 149, man10070_retorna_descricao_ies_situacao(lr_dados.ies_situacao_comp),
                    COLUMN 158, "["||lr_dados.ies_sofre_baixa_comp||"]",
                    COLUMN 165, man10070_retorna_descricao_ies_planejamento(lr_dados.planejamento),
                    COLUMN 190, lr_dados.qtd_necessaria_comp USING "<<<<<<&.&&<<<<<"
           ELSE
              PRINT COLUMN 001, lr_dados.nivel USING "<<<<",
                    COLUMN 007, lr_dados.cod_item_compon,
                    COLUMN 023, lr_dados.den_item_compon,
                    COLUMN 042, l_grades,
                    COLUMN 123, lr_dados.cod_unid_med_comp,
                    COLUMN 127, man10070_retorna_descricao_ies_tip_item(lr_dados.ies_tip_item_comp),
                    COLUMN 140, man10070_retorna_descricao_ies_situacao(lr_dados.ies_situacao_comp),
                    COLUMN 149, '['||lr_dados.ies_sofre_baixa_comp||']',
                    COLUMN 156, man10070_retorna_descricao_ies_planejamento(lr_dados.planejamento),
                    COLUMN 181, lr_dados.qtd_necessaria_comp USING "<<<<<<&.&&<<<<<"
           END IF
        ELSE
           IF m_multi_empresa = 'S' THEN
              PRINT COLUMN 001, lr_dados.cod_empresa,
                    COLUMN 009, lr_dados.nivel USING "<<<<",
                    COLUMN 015, lr_dados.cod_item_compon,
                    COLUMN 031, lr_dados.den_item_compon,
                    COLUMN 050, lr_dados.cod_unid_med_comp,
                    COLUMN 054, man10070_retorna_descricao_ies_tip_item(lr_dados.ies_tip_item_comp),
                    COLUMN 067, man10070_retorna_descricao_ies_situacao(lr_dados.ies_situacao_comp),
                    COLUMN 076, "["||lr_dados.ies_sofre_baixa_comp||"]",
                    COLUMN 083, man10070_retorna_descricao_ies_planejamento(lr_dados.planejamento),
                    COLUMN 108, lr_dados.qtd_necessaria_comp USING "<<<<<<&.&&<<<<<"
              PRINT COLUMN 001, " Grade: ",lr_dados.grade_componente
              PRINT " "
           ELSE
              PRINT COLUMN 001, lr_dados.nivel USING "<<<<",
                    COLUMN 007, lr_dados.cod_item_compon,
                    COLUMN 023, lr_dados.den_item_compon,
                    COLUMN 042, lr_dados.cod_unid_med_comp,
                    COLUMN 046, man10070_retorna_descricao_ies_tip_item(lr_dados.ies_tip_item_comp),
                    COLUMN 059, man10070_retorna_descricao_ies_situacao(lr_dados.ies_situacao_comp),
                    COLUMN 068, '['||lr_dados.ies_sofre_baixa_comp||']',
                    COLUMN 075, man10070_retorna_descricao_ies_planejamento(lr_dados.planejamento),
                    COLUMN 100, lr_dados.qtd_necessaria_comp USING "<<<<<<&.&&<<<<<"
              PRINT COLUMN 001, " Grade: ",lr_dados.grade_componente
              PRINT " "
           END IF
        END IF
 END REPORT
#---------------------------------------------------------------#
 FUNCTION man10070_retorna_descricao_ies_tip_item(l_ies_tip_item)
#---------------------------------------------------------------#
  DEFINE l_ies_tip_item   LIKE item.ies_tip_item
   CASE l_ies_tip_item
      WHEN 'F'
         RETURN "Final"
      WHEN 'T'
         RETURN "Fantasma"
      WHEN 'B'
         RETURN "Beneficiado"
      WHEN 'P'
         RETURN "Produzido"
      WHEN 'C'
         RETURN "Comprado"
   END CASE
   RETURN "Inexistente"
 END FUNCTION
#---------------------------------------------------------------#
 FUNCTION man10070_retorna_descricao_ies_situacao(l_ies_situacao)
#---------------------------------------------------------------#
  DEFINE l_ies_situacao   LIKE item.ies_situacao
   CASE l_ies_situacao
      WHEN 'A'
         RETURN "Ativo"
      WHEN 'C'
         RETURN "Cancelado"
      WHEN 'I'
         RETURN "Inativo"
   END CASE
   RETURN "Inexistente"
 END FUNCTION
#-----------------------------------------------------------------------#
 FUNCTION man10070_retorna_descricao_ies_planejamento(l_ies_planejamento)
#-----------------------------------------------------------------------#
  DEFINE l_ies_planejamento   LIKE item_man.ies_planejamento
   CASE l_ies_planejamento
      WHEN '1'
         RETURN "Pedido"
      WHEN '2'
         RETURN "Demanda dependente"
      WHEN '3'
         RETURN "Demanda independente"
      WHEN '4'
         RETURN "Plano mestre por projeto"
      WHEN '5'
         RETURN "Plano mestre por demanda"
      WHEN '9'
         RETURN "MRP ignora"
   END CASE
   RETURN "Inexistente"
 END FUNCTION
#---------------------------------------------------#
 FUNCTION man10070_busca_den_unid_med(l_cod_unid_med)
#---------------------------------------------------#
  DEFINE l_cod_unid_med      LIKE unid_med.cod_unid_med,
         l_den_unid_med_30   LIKE unid_med.den_unid_med_30
   WHENEVER ERROR CONTINUE
   SELECT den_unid_med_30
     INTO l_den_unid_med_30
     FROM unid_med
    WHERE cod_unid_med = l_cod_unid_med
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      RETURN 'Inexistente'
   END IF
   RETURN l_den_unid_med_30
 END FUNCTION
#------------------------------------------------#
 FUNCTION man10070_seta_linha_array(l_cod_item,
                                    l_qtd_neces,
                                    l_ies_tip_item,
                                    l_cod_grade_1,
                                    l_cod_grade_2,
                                    l_cod_grade_3,
                                    l_cod_grade_4,
                                    l_cod_grade_5,
                                    l_linha)
#------------------------------------------------#
  DEFINE l_cod_item          LIKE item.cod_item
  DEFINE l_qtd_neces         LIKE estrutura.qtd_necessaria
  DEFINE l_den_item          LIKE item.den_item
  DEFINE l_cod_unid_med      LIKE item.cod_unid_med
  DEFINE l_ies_tip_item      LIKE item.ies_tip_item
  DEFINE l_ies_situacao      CHAR(01)
  DEFINE l_ies_sofre_baixa   CHAR(01)
  DEFINE l_planejamento      CHAR(01)
  DEFINE l_cod_grade_1       LIKE estrut_grade.cod_grade_1
  DEFINE l_cod_grade_2       LIKE estrut_grade.cod_grade_2
  DEFINE l_cod_grade_3       LIKE estrut_grade.cod_grade_3
  DEFINE l_cod_grade_4       LIKE estrut_grade.cod_grade_4
  DEFINE l_cod_grade_5       LIKE estrut_grade.cod_grade_5
  DEFINE l_linha             SMALLINT
  WHENEVER ERROR CONTINUE
  SELECT a.den_item_reduz,
         a.ies_situacao,
         a.cod_unid_med,
         b.ies_sofre_baixa,
         b.ies_planejamento
    INTO l_den_item,
         l_ies_situacao,
         l_cod_unid_med,
         l_ies_sofre_baixa,
         l_planejamento
    FROM item a,item_man b
   WHERE a.cod_empresa = p_cod_empresa
     AND a.cod_item    = l_cod_item
     AND b.cod_item    = a.cod_item
     AND b.cod_empresa = a.cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
     LET l_den_item = " Não Cadastrado "
     LET l_cod_unid_med = "???"
  END IF
  LET m_num_seq = m_num_seq + 1
  IF m_num_nivel IS NULL OR m_num_nivel = " " THEN
     LET m_num_nivel = 0
  END IF
  LET ma_item[l_linha].cod_item        = l_cod_item
  LET ma_item[l_linha].den_item_compon = l_den_item
  LET ma_item[l_linha].cod_unid_med    = l_cod_unid_med
  LET ma_item[l_linha].ies_tip_item    = l_ies_tip_item
  LET ma_item[l_linha].btn_ies_tip_item  = l_ies_tip_item
  LET ma_item[l_linha].ies_situacao    = l_ies_situacao
  LET ma_item[l_linha].ies_sofre_baixa = l_ies_sofre_baixa
  LET ma_item[l_linha].planejamento    = l_planejamento
  LET ma_item[l_linha].cod_grade_1     = l_cod_grade_1
  LET ma_item[l_linha].cod_grade_2     = l_cod_grade_2
  LET ma_item[l_linha].cod_grade_3     = l_cod_grade_3
  LET ma_item[l_linha].cod_grade_4     = l_cod_grade_4
  LET ma_item[l_linha].cod_grade_5     = l_cod_grade_5
  LET ma_item[l_linha].qtd_necessaria  = l_qtd_neces
  IF mr_estrut_grade.sumariar_componentes = 'S' THEN
     INITIALIZE ma_item[l_linha].num_nivel TO NULL
  ELSE
     LET ma_item[l_linha].num_nivel = 0
  END IF
  RETURN TRUE
 END FUNCTION

#---------------------------------------------#
 FUNCTION man10070_version_info()
#---------------------------------------------#

RETURN '$Archive: /logix11R3/adm_producao/manufatura/programas/man10070.4gl $|$Revision: 2 $|$Date: 17/12/10 9:54 $|$Modtime: 15/12/10 16:44 $' #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION
