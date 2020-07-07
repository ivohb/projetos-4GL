DEFINE mr_wizard RECORD
                     terms CHAR(999),
                     agree CHAR(001),
                     steps CHAR(050)
                 END RECORD
 
DEFINE m_wiz_reference VARCHAR(10)
DEFINE m_prg_reference VARCHAR(10)
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD()
#------------------------------------------------------------------------------#
    INITIALIZE mr_wizard.* TO NULL
 
    LET m_wiz_reference = _ADVPL_create_component(NULL,"LWIZARD")
    CALL _ADVPL_set_property(m_wiz_reference,"TITLE","Wizard de Exemplo")
    CALL _ADVPL_set_property(m_wiz_reference,"CANCEL_EVENT","LWIZARD_cancel")
    CALL _ADVPL_set_property(m_wiz_reference,"ADD_ACTION","Ação 1","LWIZARD_action1")
    CALL _ADVPL_set_property(m_wiz_reference,"ADD_ACTION","Ação 2","LWIZARD_action2")
 
    # Etapa de boas vindas.
    CALL _ADVPL_set_property(m_wiz_reference,"ADD_STEP","WELCOME","Componente LWIZARD","Este é um exemplo de uso do componente para criação de Wizards.","LWIZARD_stepWelcome")
    CALL _ADVPL_set_property(m_wiz_reference,"STEP_EVENT","WELCOME","LWIZARD_stepWelcomeEvent")
    CALL _ADVPL_set_property(m_wiz_reference,"STEP_VALID","WELCOME","LWIZARD_stepWelcomeValid")
 
    # Etapa de seleção.
    CALL _ADVPL_set_property(m_wiz_reference,"ADD_STEP","SELECT","Selecionar Etapa","O componente permite que você alterne entre as etapas existentes.","LWIZARD_stepSelect")
    CALL _ADVPL_set_property(m_wiz_reference,"STEP_NEXT","SELECT","LWIZARD_stepSelectNext")
 
    # Etapa de processamento.
    CALL _ADVPL_set_property(m_wiz_reference,"ADD_STEP","PROCESS","Processando","Etapa em processamento, não permite interações até que a etapa seja finalizada.","LWIZARD_stepProcess")
    CALL _ADVPL_set_property(m_wiz_reference,"STEP_EVENT","PROCESS","LWIZARD_stepProcessEvent")
 
    # Etapa de finalização.
    CALL _ADVPL_set_property(m_wiz_reference,"ADD_STEP","FINISH","Sucesso","Processo finalizado com sucesso.","LWIZARD_stepFinish")
    CALL _ADVPL_set_property(m_wiz_reference,"STEP_BACK","FINISH","LWIZARD_stepFinishBack")
    CALL _ADVPL_set_property(m_wiz_reference,"ACTIVATE",TRUE)
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_cancel()
#------------------------------------------------------------------------------#
    RETURN LOG_question("Confirma o cancelamento do Wizard?")
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_action1()
#------------------------------------------------------------------------------#
    CALL log0030_processa_mensagem("Clicou na ação 1","exclamation",0)
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_action2()
#------------------------------------------------------------------------------#
    CALL log0030_processa_mensagem("Clicou na ação 2","exclamation",0)
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_stepWelcome()
#------------------------------------------------------------------------------#
    DEFINE l_wiz_container VARCHAR(10)
    DEFINE l_pnl_reference VARCHAR(10)
    DEFINE l_ltm_reference VARCHAR(10)
    DEFINE l_lbl_reference VARCHAR(10)
    DEFINE l_cmp_reference VARCHAR(10)
 
    # Recupera a referência do painél onde será criado o painél da etapa atual.
    LET l_wiz_container = _ADVPL_get_property(m_wiz_reference,"WIZARD_CONTAINER_REFERENCE")
 
    LET l_pnl_reference = _ADVPL_create_component(NULL,"LPANEL",l_wiz_container)
    CALL _ADVPL_set_property(l_pnl_reference,"ALIGN","CENTER")
 
    LET l_ltm_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pnl_reference)
    CALL _ADVPL_set_property(l_ltm_reference,"MARGIN",TRUE)
    CALL _ADVPL_set_property(l_ltm_reference,"COLUMNS_COUNT",1)
 
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_ltm_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Leia atentamente os termos de uso abaixo:")
 
    # Indica que o próximo componente será expansível.
    CALL _ADVPL_set_property(l_ltm_reference,"EXPANSIBLE",TRUE)
 
    LET l_cmp_reference = _ADVPL_create_component(NULL,"LTEXTAREA",l_ltm_reference)
    CALL _ADVPL_set_property(l_cmp_reference,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_cmp_reference,"ENABLE",TRUE)
    CALL _ADVPL_set_property(l_cmp_reference,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_cmp_reference,"VARIABLE",mr_wizard,"terms")
 
    LET l_cmp_reference = _ADVPL_create_component(NULL,"LCHECKBOX",l_ltm_reference)
    CALL _ADVPL_set_property(l_cmp_reference,"TEXT","Eu li e concordo com os termos de uso")
    CALL _ADVPL_set_property(l_cmp_reference,"VALUE_CHECKED","S")
    CALL _ADVPL_set_property(l_cmp_reference,"VALUE_NCHECKED","N")
    CALL _ADVPL_set_property(l_cmp_reference,"ENABLE",TRUE)
    CALL _ADVPL_set_property(l_cmp_reference,"VARIABLE",mr_wizard,"agree")
 
    # Aplica o leiaute.
    CALL _ADVPL_set_property(l_ltm_reference,"APPLY_LAYOUT")
 
    RETURN l_pnl_reference
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_stepWelcomeEvent()
#------------------------------------------------------------------------------#
    IF  mr_wizard.terms IS NULL THEN
        LET mr_wizard.terms = "Lorem ipsum dolor sit amet, id odio suscipit mel. ",
                              "Alii nominati cu eos, dolor congue postulant sed in. ",
                              "Qui primis voluptaria in. Option timeam conceptam et mea. ",
                              "Sit cu quas facilis, partem cotidieque nam ut, te sea commune antiopam.\n\n",
                              "Minim veritus an eos, vim ad viris persius consulatu. ",
                              "Vis eruditi concludaturque ex, fuisset mentitum expetenda eum in. ",
                              "Pro quas ridens no, ea iudico veritus consetetur usu, dicit suscipit elaboraret at per. ",
                              "Per ad rebum appellantur, pro ne graeco consequuntur, cu vim viris persequeris eloquentiam.\n\n",
                              "Quis audire aliquam ad nam, virtute dolorum pri in, liber tempor sea ne. ",
                              "Sit ei saepe petentium, et pro tempor reprimique mediocritatem, eirmod nostrud scriptorem vix id. ",
                              "Ex nec lorem fugit, sea et integre platonem, ei sit putant utamur. ",
                              "Duo prompta feugait menandri eu, ex nonumy ignota usu, et cum mazim affert utinam."
    END IF
 
    IF  mr_wizard.agree IS NULL THEN
        LET mr_wizard.agree = "N"
    END IF
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_stepWelcomeValid()
#------------------------------------------------------------------------------#
    IF  mr_wizard.agree = "N" THEN
        CALL log0030_processa_mensagem("Para continuar é preciso que você leia e aceite os termos de uso.","exclamation",0)
        RETURN FALSE
    END IF
 
    RETURN TRUE
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_stepSelect()
#------------------------------------------------------------------------------#
    DEFINE l_wiz_container VARCHAR(10)
    DEFINE l_pnl_reference VARCHAR(10)
    DEFINE l_ltm_reference VARCHAR(10)
    DEFINE l_lbl_reference VARCHAR(10)
    DEFINE l_cmp_reference VARCHAR(10)
 
    # Recupera a referência do painél onde será criado o painél da etapa atual.
    LET l_wiz_container = _ADVPL_get_property(m_wiz_reference,"WIZARD_CONTAINER_REFERENCE")
 
    LET l_pnl_reference = _ADVPL_create_component(NULL,"LPANEL",l_wiz_container)
    CALL _ADVPL_set_property(l_pnl_reference,"ALIGN","CENTER")
 
    LET l_ltm_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pnl_reference)
    CALL _ADVPL_set_property(l_ltm_reference,"MARGIN",TRUE)
    CALL _ADVPL_set_property(l_ltm_reference,"COLUMNS_COUNT",1)
 
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_ltm_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Selecione a próxima etapa:")
 
    LET l_cmp_reference = _ADVPL_create_component(NULL,"LRADIOGROUP",l_ltm_reference)
    CALL _ADVPL_set_property(l_cmp_reference,"ADD_ITEM","PROCESS","Etapa de Processamento")
    CALL _ADVPL_set_property(l_cmp_reference,"ADD_ITEM","FINISH","Etapa de Finalização")
    CALL _ADVPL_set_property(l_cmp_reference,"ENABLE",TRUE)
    CALL _ADVPL_set_property(l_cmp_reference,"VARIABLE",mr_wizard,"steps")
 
    # Aplica o leiaute.
    CALL _ADVPL_set_property(l_ltm_reference,"APPLY_LAYOUT")
 
    RETURN l_pnl_reference
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_stepSelectNext()
#------------------------------------------------------------------------------#
    RETURN mr_wizard.steps
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_stepProcess()
#------------------------------------------------------------------------------#
    DEFINE l_wiz_container VARCHAR(10)
    DEFINE l_pnl_reference VARCHAR(10)
    DEFINE l_ltm_reference VARCHAR(10)
    DEFINE l_lbl_reference VARCHAR(10)
    DEFINE l_cmp_reference VARCHAR(10)
 
    # Recupera a referência do painél onde será criado o painél da etapa atual.
    LET l_wiz_container = _ADVPL_get_property(m_wiz_reference,"WIZARD_CONTAINER_REFERENCE")
 
    LET l_pnl_reference = _ADVPL_create_component(NULL,"LPANEL",l_wiz_container)
    CALL _ADVPL_set_property(l_pnl_reference,"ALIGN","CENTER")
 
    LET l_ltm_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pnl_reference)
    CALL _ADVPL_set_property(l_ltm_reference,"MARGIN",TRUE)
    CALL _ADVPL_set_property(l_ltm_reference,"COLUMNS_COUNT",1)
 
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_ltm_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Processando, por favor aguarde.")
 
    # Indica que o próximo componente será expansível.
    CALL _ADVPL_set_property(l_ltm_reference,"EXPANSIBLE",TRUE)
 
    LET l_cmp_reference = _ADVPL_create_component(NULL,"LPANEL",l_ltm_reference)
    CALL _ADVPL_set_property(l_cmp_reference,"ALIGN","CENTER")
 
    LET m_prg_reference = _ADVPL_create_component(NULL,"LPROGRESSBAR",l_cmp_reference)
    CALL _ADVPL_set_property(m_prg_reference,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_prg_reference,"HEIGHT",40)
    CALL _ADVPL_set_property(m_prg_reference,"MAX_VALUE",3)
 
    # Aplica o leiaute.
    CALL _ADVPL_set_property(l_ltm_reference,"APPLY_LAYOUT")
 
    RETURN l_pnl_reference
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_stepProcessEvent()
#------------------------------------------------------------------------------#
    DEFINE l_ind SMALLINT
 
    CALL _ADVPL_set_property(m_wiz_reference,"ENABLE_ALL_BUTTONS",FALSE)
 
    # Reinicializa a barra de progresso.
    CALL _ADVPL_set_property(m_prg_reference,"VALUE",0)
 
    FOR l_ind = 1 TO 3
        SLEEP 2
        CALL _ADVPL_set_property(m_prg_reference,"VALUE",l_ind)
        CALL _ADVPL_LOG_refreshDisplay()
    END FOR
 
    CALL _ADVPL_set_property(m_wiz_reference,"ENABLE_ALL_BUTTONS",TRUE)
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_stepFinish()
#------------------------------------------------------------------------------#
    DEFINE l_wiz_container VARCHAR(10)
    DEFINE l_pnl_reference VARCHAR(10)
    DEFINE l_ltm_reference VARCHAR(10)
    DEFINE l_lbl_reference VARCHAR(10)
 
    # Recupera a referência do painél onde será criado o painél da etapa atual.
    LET l_wiz_container = _ADVPL_get_property(m_wiz_reference,"WIZARD_CONTAINER_REFERENCE")
 
    LET l_pnl_reference = _ADVPL_create_component(NULL,"LPANEL",l_wiz_container)
    CALL _ADVPL_set_property(l_pnl_reference,"ALIGN","CENTER")
 
    LET l_ltm_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pnl_reference)
    CALL _ADVPL_set_property(l_ltm_reference,"MARGIN",TRUE)
    CALL _ADVPL_set_property(l_ltm_reference,"COLUMNS_COUNT",1)
 
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_ltm_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Mais informações sobre este componente você encontra na TDN em:")
 
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_ltm_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","http://tdn.totvs.com.br/display/FRAMJOI/LGX+-+LWIZARD")
    CALL _ADVPL_set_property(l_lbl_reference,"CLICK_EVENT","LWIZARD_openTDN")
    CALL _ADVPL_set_property(l_ltm_reference,"ADD_EMPTY_ROW")
 
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_ltm_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Obs.: você poderá clicar em ""Voltar"" para recomeçar o processamento.")
 
    # Aplica o leiaute.
    CALL _ADVPL_set_property(l_ltm_reference,"APPLY_LAYOUT")
 
    RETURN l_pnl_reference
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_stepFinishBack()
#------------------------------------------------------------------------------#
    RETURN "WELCOME"
END FUNCTION
 
#------------------------------------------------------------------------------#
FUNCTION LWIZARD_openTDN()
#------------------------------------------------------------------------------#
    CALL LOG_previewInBrowser("http://tdn.totvs.com.br/display/FRAMJOI/LGX+-+LWIZARD")
END FUNCTION