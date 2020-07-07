#------------------------------------------------------------------------------#
# PROGRAMA: EXE0001                                                            #
# OBJETIVO: MANUTENÇÂO DE EMPRESA E DOS FORNECEDORES POR EMPRESA               #
# AUTOR(A): RUBENS DOS SANTOS FILHO                                            #
# DATA....: 21/11/2016                                                         #
# VERSÃO..: 12.1.14                                                            #
#------------------------------------------------------------------------------#
DATABASE logix

# Define as globais padrões do Logix com o código do usuário e empresa.
GLOBALS
    DEFINE p_user        LIKE usuarios.cod_usuario
    DEFINE p_cod_empresa LIKE empresa.cod_empresa
END GLOBALS

# Modular com os valores informados pelo usuário nos campos mestres (empresa).
DEFINE mr_empresa,
       mr_empresa_old RECORD
                          cod_empresa      LIKE empresa.cod_empresa,
                          den_empresa      LIKE empresa.den_empresa,
                          den_reduz        LIKE empresa.den_reduz,
                          end_empresa      LIKE empresa.end_empresa,
                          den_bairro       LIKE empresa.den_bairro,
                          den_munic        LIKE empresa.den_munic,
                          uni_feder        LIKE empresa.uni_feder,
                          ins_estadual     LIKE empresa.ins_estadual,
                          num_cgc          LIKE empresa.num_cgc,
                          num_caixa_postal LIKE empresa.num_caixa_postal,
                          cod_cep          LIKE empresa.cod_cep,
                          num_telefone     LIKE empresa.num_telefone,
                          num_telex        LIKE empresa.num_telex,
                          num_fax          LIKE empresa.num_fax,
                          end_telegraf     LIKE empresa.end_telegraf,
                          num_reg_junta    LIKE empresa.num_reg_junta,
                          dat_inclu_junta  LIKE empresa.dat_inclu_junta,
                          ies_filial       LIKE empresa.ies_filial,
                          dat_fundacao     LIKE empresa.dat_fundacao,
                          cod_cliente      LIKE empresa.cod_cliente,
                          nom_cliente      LIKE clientes.nom_cliente
                      END RECORD

# Modular com os valores informados pelo usuário nos campos detalhe (fornecedores).
DEFINE ma_fornecedores,
       ma_fornecedores_old ARRAY[999] OF
                           RECORD
                               cod_fornecedor LIKE fornecedor.cod_fornecedor,
                               raz_social     LIKE fornecedor.raz_social
                           END RECORD

# ARRAY das referências dos campos FREEFORM e a variável de controle.
DEFINE ma_components   ARRAY[999,2] OF VARCHAR(50)
DEFINE m_idx_component SMALLINT

# Modulares das referências de componentes FREEFORM.
DEFINE m_dialog_reference VARCHAR(10)
DEFINE m_menubr_reference VARCHAR(10)
DEFINE m_status_reference VARCHAR(10)
DEFINE m_folder_reference VARCHAR(10)
DEFINE m_browse_reference VARCHAR(10)
DEFINE m_constc_reference VARCHAR(10)

# Modular que controla se a pesquisa está ou não ativa.
DEFINE m_pesquisa_ativa SMALLINT

# Modular que guarda a quantidade de fornecedores encontrados na pesquisa.
DEFINE m_fornecedores INTEGER

# Modular das referências dos zoom que serão utilizados.
DEFINE m_zoom_clientes   VARCHAR(10)
DEFINE m_zoom_fornecedor VARCHAR(10)

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001
Programa FREEFORM de manutenção de empresas e fornecedores por empresa.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001()
#------------------------------------------------------------------------------#
    DEFINE l_btn_reference VARCHAR(10)

    # Executa a função LOG_initApp. Esta função é responsável por diversas
    # verificações padrões do produto como: conexão com banco de dados, carga
    # das globais e eventos padrões, validação de permissão do usuário, consumo
    # da licença etc. A chave de sistema informada para consumo de licença pode
    # ser obtida no programa MEN0040. Cada módulo possui uma chave específica
    # para consumo correto de licença.
    IF  LOG_initApp("[CHAVE SISTEMA]") = 0 THEN
        # Enquanto a janela está sendo criada, trava a execução de outros
        # programas no menu.
        CALL APPLICATION_showLoadingMessage(TRUE,NULL)

        # Inicializa as variáveis que serão utilizadas.
        LET m_idx_component = 0
        INITIALIZE mr_empresa.*, ma_fornecedores, ma_components TO NULL

        # Cria a janela modal do programa, através do componente LDIALOG, e
        # define alguns métodos como:
        # * SIZE: tamanho inicial da janela
        # * ENABLE_ESC_CLOSE: habilita/desabilita ESC para fechar a janela
        # * TITLE: título da janela
        LET m_dialog_reference = _ADVPL_create_component(NULL,"LDIALOG")
        CALL _ADVPL_set_property(m_dialog_reference,"SIZE",800,600)
        CALL _ADVPL_set_property(m_dialog_reference,"ENABLE_ESC_CLOSE",FALSE)
        CALL _ADVPL_set_property(m_dialog_reference,"TITLE","Manutenção de Empresa e Fornecedores x Empresa")

        # Cria a barra de ferramentas do programa.
        LET m_menubr_reference = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog_reference)

        # Cria a operação padrão de inclusão.
        LET l_btn_reference = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_menubr_reference)
        CALL _ADVPL_set_property(l_btn_reference,"EVENT","exe0001_create_event")
        CALL _ADVPL_set_property(l_btn_reference,"CONFIRM_EVENT","exe0001_create_confirm_event")
        CALL _ADVPL_set_property(l_btn_reference,"CANCEL_EVENT","exe0001_create_cancel_event")
        CALL _ADVPL_set_property(l_btn_reference,"ENABLE",LOG_operacao_autorizada(p_cod_empresa,p_user,"exe0001","IN",1))

        # Cria a operação padrão de modificação.
        LET l_btn_reference = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_menubr_reference)
        CALL _ADVPL_set_property(l_btn_reference,"EVENT","exe0001_update_event")
        CALL _ADVPL_set_property(l_btn_reference,"CONFIRM_EVENT","exe0001_update_confirm_event")
        CALL _ADVPL_set_property(l_btn_reference,"CANCEL_EVENT","exe0001_update_cancel_event")
        CALL _ADVPL_set_property(l_btn_reference,"ENABLE",LOG_operacao_autorizada(p_cod_empresa,p_user,"exe0001","MO",1))

        # Cria a operação padrão de cópia.
        LET l_btn_reference = _ADVPL_create_component(NULL,"LCOPYBUTTON",m_menubr_reference)
        CALL _ADVPL_set_property(l_btn_reference,"EVENT","exe0001_copy_event")
        CALL _ADVPL_set_property(l_btn_reference,"CONFIRM_EVENT","exe0001_copy_confirm_event")
        CALL _ADVPL_set_property(l_btn_reference,"CANCEL_EVENT","exe0001_copy_cancel_event")
        CALL _ADVPL_set_property(l_btn_reference,"ENABLE",LOG_operacao_autorizada(p_cod_empresa,p_user,"exe0001","IN",1))

        # Cria a operação padrão de exclusão.
        LET l_btn_reference = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_menubr_reference)
        CALL _ADVPL_set_property(l_btn_reference,"EVENT","exe0001_delete_event")
        CALL _ADVPL_set_property(l_btn_reference,"ENABLE",LOG_operacao_autorizada(p_cod_empresa,p_user,"exe0001","EX",1))

        # Cria a operação padrão de pesquisa.
        LET l_btn_reference = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menubr_reference)
        CALL _ADVPL_set_property(l_btn_reference,"EVENT","exe0001_find_event")
        CALL _ADVPL_set_property(l_btn_reference,"TYPE","NO_CONFIRM")
        CALL _ADVPL_set_property(l_btn_reference,"ENABLE",LOG_operacao_autorizada(p_cod_empresa,p_user,"exe0001","CO",1))

        # Cria a operação padrão de navegação para o primeiro registro.
        LET l_btn_reference = _ADVPL_create_component(NULL,"LFIRSTBUTTON",m_menubr_reference)
        CALL _ADVPL_set_property(l_btn_reference,"EVENT","exe0001_first_event")
        CALL _ADVPL_set_property(l_btn_reference,"ENABLE",LOG_operacao_autorizada(p_cod_empresa,p_user,"exe0001","CO",1))

        # Cria a operação padrão de navegação para o registro anterior.
        LET l_btn_reference = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",m_menubr_reference)
        CALL _ADVPL_set_property(l_btn_reference,"EVENT","exe0001_previous_event")
        CALL _ADVPL_set_property(l_btn_reference,"ENABLE",LOG_operacao_autorizada(p_cod_empresa,p_user,"exe0001","CO",1))

        # Cria a operação padrão de navegação para o registro seguinte.
        LET l_btn_reference = _ADVPL_create_component(NULL,"LNEXTBUTTON",m_menubr_reference)
        CALL _ADVPL_set_property(l_btn_reference,"EVENT","exe0001_next_event")
        CALL _ADVPL_set_property(l_btn_reference,"ENABLE",LOG_operacao_autorizada(p_cod_empresa,p_user,"exe0001","CO",1))

        # Cria a operação padrão de navegação para o último registro.
        LET l_btn_reference = _ADVPL_create_component(NULL,"LLASTBUTTON",m_menubr_reference)
        CALL _ADVPL_set_property(l_btn_reference,"EVENT","exe0001_last_event")
        CALL _ADVPL_set_property(l_btn_reference,"ENABLE",LOG_operacao_autorizada(p_cod_empresa,p_user,"exe0001","CO",1))

        # Cria a operação padrão de relatório se houver o programa de exemplo de
        # emissão de relatório no RPO.
        IF  Find4GLFunction("exe0003") THEN
            LET l_btn_reference = _ADVPL_create_component(NULL,"LPRINTBUTTON",m_menubr_reference)
            CALL _ADVPL_set_property(l_btn_reference,"EVENT","exe0001_print_event")
            CALL _ADVPL_set_property(l_btn_reference,"ENABLE",LOG_operacao_autorizada(p_cod_empresa,p_user,"exe0001","CO",1))
        END IF

        # Cria o botão de sair.
        CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menubr_reference)

        # Executa a criação dos campos mestres e detalhe.
        CALL exe0001_create_form_fields()
        CALL exe0001_create_detail_fields()

        # Cria a barra de status do programa.
        LET m_status_reference = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog_reference)

        # Seleciona por padrão a primeira aba do FOLDER.
        CALL _ADVPL_set_property(m_folder_reference,"FOLDER_SELECTED",1)

        # Antes de ativar a janela, destrava a execução dos programas no menu.
        CALL APPLICATION_showLoadingMessage(FALSE,NULL)

        # Ativa a janela do programa.
        CALL _ADVPL_set_property(m_dialog_reference,"ACTIVATE",TRUE)
    END IF
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_create_form_fields
Cria os campos mestres, de manutenção da empresa.

@protected
@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14
/}
#------------------------------------------------------------------------------#
PRIVATE FUNCTION exe0001_create_form_fields()
#------------------------------------------------------------------------------#
    DEFINE l_pnl_reference VARCHAR(10)
    DEFINE l_lay_reference VARCHAR(10)
    DEFINE l_lbl_reference VARCHAR(10)
    DEFINE l_cmp_reference VARCHAR(10)

    # Cria o painél agrupador dos campos mestres. Este painél ficará alinhado
    # ao topo da janela, onde ficarão os campos mestres.
    LET l_pnl_reference = _ADVPL_create_component(NULL,"LPANEL",m_dialog_reference)
    CALL _ADVPL_set_property(l_pnl_reference,"ALIGN","TOP")

    # Cria o gerenciador de leiaute dos campos mestres (LLAYOUTMANAGER). Com
    # este componente não será necessário posicionar os campos manualmente na
    # tela. Basta definir a quantidade de colunas e adicionar os componentes.
    # * COLUMNS_COUNT: define a quantidade de colunas de distribuição dos campos
    # * MARGIN: criará uma pequena margem entre os campos e as bordas da tela
    LET l_lay_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pnl_reference)
    CALL _ADVPL_set_property(l_lay_reference,"COLUMNS_COUNT",2)
    CALL _ADVPL_set_property(l_lay_reference,"MARGIN",TRUE)

    # Inicia a criação dos campos. Para cada campo da tela será criado um rótulo,
    # para os campos obrigatórios o rótulo terá a fonte em negrito. Os métodos
    # minímos que serão definidos para os campos são:
    # * TOOLTIP: texto de ajuda exibido ao posicionar o mouse no campo
    # * ENABLE: habilita/desabilita o campo
    # * LENGTH: quantidade máxima de caracteres permitidos no campo
    # * PICTURE: máscara de formatação do campo conforme máscaras disponível no
    #   ADVPL em: http://tdn.totvs.com.br/pages/releaseview.action?pageId=5265071

    # COD_EMPRESA --------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Empresa:")
    CALL _ADVPL_set_property(l_lbl_reference,"FONT",NULL,NULL,TRUE,FALSE,FALSE)

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "cod_empresa"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Código da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",2)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","@!")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"cod_empresa")

    # DEN_EMPRESA --------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Descrição:")
    CALL _ADVPL_set_property(l_lbl_reference,"FONT",NULL,NULL,TRUE,FALSE,FALSE)

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "den_empresa"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Descrição da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",36)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","@!")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"den_empresa")

    # DEN_REDUZ ----------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Descrição reduzida:")
    CALL _ADVPL_set_property(l_lbl_reference,"FONT",NULL,NULL,TRUE,FALSE,FALSE)

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "den_reduz"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Descrição reduzida da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",10)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","@!")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"den_reduz")

    # Cria dois FOLDERs para agrupar os campos.
    LET m_folder_reference = _ADVPL_create_component(NULL,"LFOLDER",m_dialog_reference)
    CALL _ADVPL_set_property(m_folder_reference,"ALIGN","TOP")

    # FOLDER Endereço ----------------------------------------------------------
    LET l_pnl_reference = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder_reference)
    CALL _ADVPL_set_property(l_pnl_reference,"TITLE","Endereço")

    # Cria um LLAYOUTMANAGER para controlar os campos da primeira aba.
    LET l_lay_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pnl_reference)
    CALL _ADVPL_set_property(l_lay_reference,"COLUMNS_COUNT",2)
    CALL _ADVPL_set_property(l_lay_reference,"MARGIN",TRUE)

    # END_EMPRESA --------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Endereço:")
    CALL _ADVPL_set_property(l_lbl_reference,"FONT",NULL,NULL,TRUE,FALSE,FALSE)

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "end_empresa"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Endereço da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",36)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","@!")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"end_empresa")

    # DEN_BAIRRO ---------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Bairro:")

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "den_bairro"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Bairro da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",19)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","@!")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"den_bairro")

    # DEN_MUNIC ----------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Cidade:")
    CALL _ADVPL_set_property(l_lbl_reference,"FONT",NULL,NULL,TRUE,FALSE,FALSE)

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "den_munic"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Cidade da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",30)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","@!")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"den_munic")

    # UNI_FEDER ----------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Estado:")
    CALL _ADVPL_set_property(l_lbl_reference,"FONT",NULL,NULL,TRUE,FALSE,FALSE)

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "uni_feder"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LCOMBOBOX",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Estado da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","AC","Acre")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","AL","Alagoas")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","AP","Amapá")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","AM","Amazonas")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","BA","Bahia")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","CE","Ceará")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","DF","Distrito Federal")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","ES","Espírito Santo")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","GO","Goiás")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","MA","Maranhão")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","MT","Mato Grosso")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","MS","Mato Grosso do Sul")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","MG","Minas Gerais")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","PA","Pará")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","PB","Paraíba")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","PR","Paraná")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","PE","Pernambuco")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","PI","Piauí")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","RJ","Rio de Janeiro")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","RN","Rio Grande do Norte")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","RS","Rio Grande do Sul")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","RO","Rondônia")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","RR","Roraima")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","SC","Santa Catarina")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","SP","São Paulo")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","SE","Sergipe")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ADD_ITEM","TO","Tocantins")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"uni_feder")

    # NUM_CAIXA_POSTAL ---------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Caixa Postal:")

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "num_caixa_postal"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Número da caixa postal da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",5)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","#####")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"num_caixa_postal")

    # COD_CEP ------------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","CEP:")
    CALL _ADVPL_set_property(l_lbl_reference,"FONT",NULL,NULL,TRUE,FALSE,FALSE)

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "cod_cep"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Código CEP da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",9)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","#####-###")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"cod_cep")

    # NUM_TELEFONE -------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Telefone:")

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "num_telefone"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Número de telefone da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",9)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","@R (##) ####-####")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"num_telefone")

    # FOLDER Informações Complementares ----------------------------------------
    LET l_pnl_reference = _ADVPL_create_component(NULL,"LFOLDERPANEL",m_folder_reference)
    CALL _ADVPL_set_property(l_pnl_reference,"TITLE","Informações Complementares")

    # Cria um LLAYOUTMANAGER para controlar os campos da segunda aba.
    LET l_lay_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pnl_reference)
    CALL _ADVPL_set_property(l_lay_reference,"COLUMNS_COUNT",2)
    CALL _ADVPL_set_property(l_lay_reference,"MARGIN",TRUE)

    # INS_ESTADUAL -------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Inscrição Estadual:")
    CALL _ADVPL_set_property(l_lbl_reference,"FONT",NULL,NULL,TRUE,FALSE,FALSE)

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "ins_estadual"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Código de inscrição estadual da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",16)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","@!")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"ins_estadual")

    # NUM_CGC ------------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","CNPJ:")
    CALL _ADVPL_set_property(l_lbl_reference,"FONT",NULL,NULL,TRUE,FALSE,FALSE)

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "num_cgc"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","CNPJ da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",19)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","###.###.###/####-##")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VALID","exe0001_num_cgc_valid")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"num_cgc")

    # NUM_TELEX ----------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Inscrição Municipal:")

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "num_telex"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Código de inscrição municipal da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",15)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","@!")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"num_telex")

    # NUM_REG_JUNTA ------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Junta comercial:")

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "num_reg_junta"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Registro da junta comercial da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",15)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","###############")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"num_reg_junta")

    # DAT_INCLU_JUNTA ----------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Data junta comercial:")

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "dat_inclu_junta"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LDATEFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Data de inclusão da junta comercial da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"dat_inclu_junta")

    # IES_FILIAL ---------------------------------------------------------------
    CALL _ADVPL_set_property(l_lay_reference,"ADD_EMPTY_COLUMN")

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "ies_filial"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LCHECKBOX",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VALUE_CHECKED","S")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VALUE_NCHECKED","N")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TEXT","Filial?")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Indica se a empresa é filial.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"ies_filial")

    # DAT_FUNDACAO -------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Data fundação:")

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "dat_fundacao"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LDATEFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Data de fundação da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"dat_fundacao")

    # COD_CLIENTE --------------------------------------------------------------
    LET l_lbl_reference = _ADVPL_create_component(NULL,"LLABEL",l_lay_reference)
    CALL _ADVPL_set_property(l_lbl_reference,"TEXT","Cliente:")

    # Cria um painél para agrupar o campo cliente, pois terá zoom e descrição.
    LET l_pnl_reference = _ADVPL_create_component(NULL,"LPANEL",l_lay_reference)

    LET l_lay_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pnl_reference)
    CALL _ADVPL_set_property(l_lay_reference,"COLUMNS_COUNT",3)
    CALL _ADVPL_set_property(l_lay_reference,"MARGIN",FALSE)

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "cod_cliente"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"TOOLTIP","Código de cliente da empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LENGTH",15)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"PICTURE","@!")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"HOTKEY","F4","exe0001_zoom_clientes","Zoom Clientes",TRUE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"LOST_FOCUS_EVENT","exe0001_load_nom_cliente")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE",mr_empresa,"cod_cliente")

    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "btn_zoom_clientes"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_lay_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ENABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"SIZE",24,20)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"CLICK_EVENT","exe0001_zoom_clientes")

    # DEN_CLIENTE --------------------------------------------------------------
    LET l_cmp_reference = _ADVPL_create_component(NULL,"LTEXTFIELD",l_lay_reference)
    CALL _ADVPL_set_property(l_cmp_reference,"TOOLTIP","Descrição do cliente da empresa.")
    CALL _ADVPL_set_property(l_cmp_reference,"ENABLE",FALSE)
    CALL _ADVPL_set_property(l_cmp_reference,"LENGTH",36)
    CALL _ADVPL_set_property(l_cmp_reference,"PICTURE","@!")
    CALL _ADVPL_set_property(l_cmp_reference,"VARIABLE",mr_empresa,"nom_cliente")
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_create_detail_fields
Cria os campos detalhes, de manutenção dos fornecedores ligados a empresa.

@protected
@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14
/}
#------------------------------------------------------------------------------#
PRIVATE FUNCTION exe0001_create_detail_fields()
#------------------------------------------------------------------------------#
    DEFINE l_pnl_reference VARCHAR(10)
    DEFINE l_lay_reference VARCHAR(10)

    # Cria o painél agrupador da GRID. Este painél ficará alinhado centralizado
    # na janela para ocupar toda a área útil restante da tela.
    LET l_pnl_reference = _ADVPL_create_component(NULL,"LPANEL",m_dialog_reference)
    CALL _ADVPL_set_property(l_pnl_reference,"ALIGN","CENTER")

    # Cria o gerenciador de leiaute da GRID (LLAYOUTMANAGER). O componente GRID
    # ocupa somente uma coluna, porém iremos definir que ela será expansível.
    LET l_lay_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_pnl_reference)
    CALL _ADVPL_set_property(l_lay_reference,"COLUMNS_COUNT",1)
    CALL _ADVPL_set_property(l_lay_reference,"MARGIN",TRUE)
    CALL _ADVPL_set_property(l_lay_reference,"EXPANSIBLE",TRUE)

    # Inicia a criação da GRID com os campos detalhes. A GRID nativamente não
    # aceita edição, portanto será necessário criar componentes secundários para
    # permitir a edição das colunas da GRID. Estes campos secundários são
    # criados através do método EDIT_COMPONENT e EDIT_PROPERTY do componente
    # LTABLECOLUMNEX, que são as colunas da GRID.
    LET m_browse_reference = _ADVPL_create_component(NULL,"LBROWSEEX",l_lay_reference)
    CALL _ADVPL_set_property(m_browse_reference,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_browse_reference,"ALIGN","CENTER")

    # COD_FORNECEDOR -----------------------------------------------------------
    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "cod_fornecedor"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"EDITABLE",TRUE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"HEADER","* Fornecedor")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ORDER",TRUE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"EDIT_PROPERTY","TOOLTIP","Código do fornecedor ligado a empresa.")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"EDIT_PROPERTY","LENGTH",15)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"EDIT_PROPERTY","HOTKEY","F4","exe0001_zoom_fornecedor","Zoom Fornecedores",TRUE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"EDIT_PROPERTY","LOST_FOCUS_EVENT","exe0001_cod_fornecedor_after_field")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE","cod_fornecedor")

    # ZOOM_FORNECEDOR ----------------------------------------------------------
    # Cria a coluna para exibir o botão de zoom do fornecedor.
    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "btn_zoom_fornecedor"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"NO_VARIABLE")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"EDITABLE",TRUE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"COLUMN_SIZE",10)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ORDER",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"BEFORE_EDIT_EVENT","exe0001_zoom_fornecedor")

    # RAZ_SOCIAL ---------------------------------------------------------------
    LET m_idx_component = m_idx_component + 1
    LET ma_components[m_idx_component,1] = "raz_social"
    LET ma_components[m_idx_component,2] = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse_reference)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"EDITABLE",FALSE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"HEADER","Razão Social")
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"ORDER",TRUE)
    CALL _ADVPL_set_property(ma_components[m_idx_component,2],"VARIABLE","raz_social")

    # Define o ARRAY OF RECORD que será controlado pela GRID.
    CALL _ADVPL_set_property(m_browse_reference,"SET_ROWS",ma_fornecedores,1)
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_zoom_clientes
Executa o zoom de clientes.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_zoom_clientes()
#------------------------------------------------------------------------------#
    DEFINE l_cod_cliente LIKE clientes.cod_cliente
    DEFINE l_nom_cliente LIKE clientes.nom_cliente

    DEFINE l_cmp_reference VARCHAR(10)

    # Recupera a referência do componente FREEFORM do campo COD_CLIENTE para
    # utilizá-lo no zoom.
    LET l_cmp_reference = exe0001_get_field_reference("cod_cliente")

    # Cria o zoom de clientes, utiliza a modular para não precisar recuperar os
    # dados do metadado cada vez que o usuário utilizar o zoom, isso fará com
    # que o zoom carregue bem mais rápido a partir da segunda execução e não irá
    # utilizar recursos desnecessariamente.
    IF  m_zoom_clientes IS NULL THEN
        LET m_zoom_clientes = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_clientes,"ZOOM","zoom_clientes")

        # Define o componente que utilizará o zoom. É preciso informar a
        # referência do componente, o tipo, o tamanho e precisão.
        # Os tipos disponíveis são: 1-CHAR, 2-SMALLINT, 3-INTEGER, 4-DECIMAL,
        # 5-DATE, 6-DATETIME e 7-VARCHAR.
        CALL _ADVPL_set_property(m_zoom_clientes,"ZOOM_COMPONENT",l_cmp_reference,1,15,0)
    END IF

    # Ativa o zoom.
    CALL _ADVPL_get_property(m_zoom_clientes,"ACTIVATE")

    # Recupera os valores selecionados no zoom.
    LET l_cod_cliente = _ADVPL_get_property(m_zoom_clientes,"RETURN_BY_TABLE_COLUMN","clientes","cod_cliente")
    LET l_nom_cliente = _ADVPL_get_property(m_zoom_clientes,"RETURN_BY_TABLE_COLUMN","clientes","nom_cliente")

    # Se o usuário cancelou o zoom, os valores virão nulos, portanto não é
    # necessário substituir os valores que estão em tela.
    IF  l_cod_cliente IS NOT NULL THEN
        LET mr_empresa.cod_cliente = l_cod_cliente
        LET mr_empresa.nom_cliente = l_nom_cliente
    END IF

    # Define o foco para o campo COD_CLIENTE.
    CALL _ADVPL_set_property(l_cmp_reference,"GET_FOCUS")
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_zoom_fornecedor
Executa o zoom de fornecedores.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_zoom_fornecedor()
#------------------------------------------------------------------------------#
    DEFINE l_cod_fornecedor LIKE fornecedor.cod_fornecedor
    DEFINE l_raz_social     LIKE fornecedor.raz_social

    DEFINE l_cmp_reference VARCHAR(10)
    DEFINE l_row_selected  SMALLINT

    # Recupera a referência do componente FREEFORM da coluna da GRID
    # COD_FORNECEDOR para utilizá-la no zoom.
    LET l_cmp_reference = exe0001_get_field_reference("cod_fornecedor")

    # Cria o zoom de fornecedores, utiliza a modular para não precisar recuperar
    # os dados do metadado cada vez que o usuário utilizar o zoom, isso fará com
    # que o zoom carregue bem mais rápido a partir da segunda execução e não irá
    # utilizar recursos desnecessariamente.
    IF  m_zoom_fornecedor IS NULL THEN
        LET m_zoom_fornecedor = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_fornecedor,"ZOOM","zoom_fornecedor")

        # Define o componente que utilizará o zoom. É preciso informar a
        # referência do componente, o tipo, o tamanho e precisão.
        # Os tipos disponíveis são: 1-CHAR, 2-SMALLINT, 3-INTEGER, 4-DECIMAL,
        # 5-DATE, 6-DATETIME e 7-VARCHAR.
        CALL _ADVPL_set_property(m_zoom_fornecedor,"ZOOM_COMPONENT",l_cmp_reference,1,15,0)
    END IF

    # Ativa o zoom.
    CALL _ADVPL_get_property(m_zoom_fornecedor,"ACTIVATE")

    # Recupera os valores selecionados no zoom.
    LET l_cod_fornecedor = _ADVPL_get_property(m_zoom_fornecedor,"RETURN_BY_TABLE_COLUMN","fornecedor","cod_fornecedor")
    LET l_raz_social = _ADVPL_get_property(m_zoom_fornecedor,"RETURN_BY_TABLE_COLUMN","fornecedor","raz_social")

    # Se o usuário cancelou o zoom, os valores virão nulos, portanto não é
    # necessário substituir os valores que estão em tela.
    IF  l_cod_fornecedor IS NOT NULL THEN
        # Recupera a linha da GRID onde foi ativado o zoom.
        LET l_row_selected = _ADVPL_get_property(m_browse_reference,"ROW_SELECTED")

        LET ma_fornecedores[l_row_selected].cod_fornecedor = l_cod_fornecedor
        LET ma_fornecedores[l_row_selected].raz_social = l_raz_social
    END IF

    # Define o foco para o campo COD_FORNECEDOR.
    CALL _ADVPL_set_property(l_cmp_reference,"GET_FOCUS")
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_num_cgc_valid
Valida o CNPJ informado.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se o CNPJ é valido.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_num_cgc_valid()
#------------------------------------------------------------------------------#
    IF  NOT LOG_validateCNPJ(mr_empresa.num_cgc) THEN
        CALL log0030_processa_mensagem("CNPJ informado é inválido.","exclamation",0)
        RETURN FALSE
    END IF

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_load_nom_cliente
Carrega o nome do cliente informado.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se o nome do cliente foi carregado com sucesso.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_load_nom_cliente()
#------------------------------------------------------------------------------#
    INITIALIZE mr_empresa.nom_cliente TO NULL

    IF  mr_empresa.cod_cliente IS NOT NULL THEN
        IF  NOT vdpm7_clientes_leitura(mr_empresa.cod_cliente,FALSE,1) THEN
            RETURN FALSE
        END IF

        LET mr_empresa.nom_cliente = vdpm7_clientes_get_nom_cliente()
    END IF

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_cod_fornecedor_after_field
Evento acionado após o usuário informar o código do fornecedor.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_cod_fornecedor_after_field()
#------------------------------------------------------------------------------#
    DEFINE l_row_selected SMALLINT

    LET l_row_selected = _ADVPL_get_property(m_browse_reference,"ROW_SELECTED")

    INITIALIZE ma_fornecedores[l_row_selected].raz_social TO NULL

    IF  ma_fornecedores[l_row_selected].cod_fornecedor IS NOT NULL THEN
        CALL exe0001_load_raz_social(l_row_selected)
    END IF
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_load_raz_social
Carrega a razão social do fornecedor informado.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@param l_row_selected, SMALLINT, Linha selecionada da GRID.
@return SMALLINT, Verdadeiro se a razão social foi carregada com sucesso.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_load_raz_social(l_row_selected)
#------------------------------------------------------------------------------#
    DEFINE l_row_selected SMALLINT

    IF  NOT supm2_fornecedor_leitura(ma_fornecedores[l_row_selected].cod_fornecedor,FALSE,1) THEN
        RETURN FALSE
    END IF

    LET ma_fornecedores[l_row_selected].raz_social = supm2_fornecedor_get_raz_social()

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_create_event
Executa o evento de inclusão.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se permite a inclusão de um novo registro.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_create_event()
#------------------------------------------------------------------------------#
    # Ao ativar a inclusão, desativa a pesquisa atual.
    LET m_pesquisa_ativa = FALSE

    # Limpa os campos da tela e inicializa a GRID.
    INITIALIZE mr_empresa.*,ma_fornecedores TO NULL
    CALL _ADVPL_set_property(m_browse_reference,"ITEM_COUNT",1)

    # Define alguns valores padrões de inclusão.
    LET mr_empresa.num_cgc = "000.000.000/0000-00"
    LET mr_empresa.dat_inclu_junta = TODAY
    LET mr_empresa.ies_filial = "N"
    LET mr_empresa.dat_fundacao = TODAY

    # Habilita os campos para edição.
    CALL exe0001_enable_fields(TRUE)

    # Define o foco para o primeiro campo.
    CALL _ADVPL_set_property(ma_components[1,2],"GET_FOCUS")

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_create_confirm_event
Confirma a inclusão do registro.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se o registro foi incluído com sucesso.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_create_confirm_event()
#------------------------------------------------------------------------------#
    DEFINE l_status SMALLINT
    DEFINE l_ind    SMALLINT
    DEFINE l_count  SMALLINT

    LET l_status = TRUE

    # Inicia uma transação com o banco de dados.
    CALL LOG_transaction_begin()

    # Carrega os valores da empresa via DML.
    CALL logm2_empresa_set_default()
    CALL logm2_empresa_set_cod_empresa(mr_empresa.cod_empresa)
    CALL logm2_empresa_set_den_empresa(mr_empresa.den_empresa)
    CALL logm2_empresa_set_den_reduz(mr_empresa.den_reduz)
    CALL logm2_empresa_set_end_empresa(mr_empresa.end_empresa)
    CALL logm2_empresa_set_den_bairro(mr_empresa.den_bairro)
    CALL logm2_empresa_set_den_munic(mr_empresa.den_munic)
    CALL logm2_empresa_set_uni_feder(mr_empresa.uni_feder)
    CALL logm2_empresa_set_ins_estadual(mr_empresa.ins_estadual)
    CALL logm2_empresa_set_num_cgc(mr_empresa.num_cgc)
    CALL logm2_empresa_set_num_caixa_postal(mr_empresa.num_caixa_postal)
    CALL logm2_empresa_set_cod_cep(mr_empresa.cod_cep)
    CALL logm2_empresa_set_num_telefone(mr_empresa.num_telefone)
    CALL logm2_empresa_set_num_telex(mr_empresa.num_telex)
    CALL logm2_empresa_set_num_fax(mr_empresa.num_fax)
    CALL logm2_empresa_set_end_telegraf(mr_empresa.end_telegraf)
    CALL logm2_empresa_set_num_reg_junta(mr_empresa.num_reg_junta)
    CALL logm2_empresa_set_dat_inclu_junta(mr_empresa.dat_inclu_junta)
    CALL logm2_empresa_set_ies_filial(mr_empresa.ies_filial)
    CALL logm2_empresa_set_dat_fundacao(mr_empresa.dat_fundacao)
    CALL logm2_empresa_set_cod_cliente(mr_empresa.cod_cliente)

    # Efetua a inclusão da empresa via RNT. Se houver algum problema, efetua o
    # ROLLBACK da transação e posiciona no primeiro campo da tela.
    IF  NOT logt2_empresa_inclui(TRUE,0) THEN
        CALL LOG_transaction_rollback()
        CALL _ADVPL_set_property(ma_components[1,2],"GET_FOCUS")
        RETURN FALSE
    END IF

    # Dependendo da quantidade de fornecedores é preciso dar um FEEDBACK ao
    # usuário para informar que está processando a inclusão alterando o cursor
    # do mouse (ampulheta).
    CALL _ADVPL_cursor_wait()

    # Recupera a quantidade de fornecedores informados.
    LET l_count = _ADVPL_get_property(m_browse_reference,"ITEM_COUNT")

    # Efetua a inclusão dos fornecedores relacionados a empresa via RNT.
    FOR l_ind = 1 TO l_count
        CALL supm320_fornec_x_empresa_set_default()
        CALL supm320_fornec_x_empresa_set_cod_empresa(mr_empresa.cod_empresa)
        CALL supm320_fornec_x_empresa_set_cod_fornecedor(ma_fornecedores[l_ind].cod_fornecedor)

        IF  NOT supt320_fornec_x_empresa_inclui(TRUE,0) THEN
            LET l_status = FALSE
            EXIT FOR
        END IF
    END FOR

    # Retorna o cursor do mouse ao normal (seta).
    CALL _ADVPL_cursor_arrow()

    # Se houve algum problema, efetua o ROLLBACK da transação e posiciona na
    # linha onde ocorreu o problema.
    IF  NOT l_status THEN
        CALL LOG_transaction_rollback()
        CALL _ADVPL_set_property(m_browse_reference,"SELECT_ITEM",l_ind)
        RETURN FALSE
    END IF

    # Desabilita os campos.
    CALL exe0001_enable_fields(FALSE)

    # Efetua COMMIT da transação.
    CALL LOG_transaction_commit()

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_create_cancel_event
Cancela a inclusão do registro.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se permitido o cancelamento da inclusão.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_create_cancel_event()
#------------------------------------------------------------------------------#
    # Limpa os campos da tela e inicializa a GRID.
    INITIALIZE mr_empresa.*,ma_fornecedores TO NULL
    CALL _ADVPL_set_property(m_browse_reference,"ITEM_COUNT",1)

    # Desabilita os campos.
    CALL exe0001_enable_fields(FALSE)

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_update_event
Executa o evento de modificação.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se permite a modificação do registro em tela.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_update_event()
#------------------------------------------------------------------------------#
    DEFINE l_cmp_reference VARCHAR(10)

    # Para modificar é preciso que tenha um registro pesquisa em tela.
    IF  NOT m_pesquisa_ativa THEN
        CALL _ADVPL_set_property(m_status_reference,"WARNING_TEXT","Efetue primeiramente a pesquisa.")
        RETURN FALSE
    END IF

    # Inicia uma transação com o banco de dados.
    CALL LOG_transaction_begin()

    # Efetua o bloqueio dos registros selecionados, se o registro já está
    # bloqueado por outro usuário, ficará aguardando a liberação.
    IF  NOT exe0001_lock_data() THEN
        CALL LOG_transaction_rollback()
        RETURN FALSE
    END IF

    # Refaz a leitura do registro, pois o mesmo pode ter sido modificado ou
    # excluído neste intervalo.
    IF  NOT exe0001_load_empresa(mr_empresa.cod_empresa) THEN
        CALL _ADVPL_set_property(m_status_reference,"WARNING_TEXT","Os dados da pesquisa foram alterados, efetue uma nova pesquisa.")
        RETURN FALSE
    END IF

    # Recarrega os fornecedores da empresa atual.
    CALL exe0001_load_fornecedores(mr_empresa.cod_empresa)

    # Habilita os campos para edição.
    CALL exe0001_enable_fields(TRUE)

    # Recupera a referência do campo COD_EMPRESA e desabilita a edição do mesmo.
    LET l_cmp_reference = exe0001_get_field_reference("cod_empresa")
    CALL _ADVPL_set_property(l_cmp_reference,"ENABLE",FALSE)

    # Recupera a referência do campo DEN_EMPRESA e define o foco do mesmo.
    LET l_cmp_reference = exe0001_get_field_reference("den_empresa")
    CALL _ADVPL_set_property(l_cmp_reference,"GET_FOCUS")

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_update_confirm_event
Confirma a modificação do registro.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se a modificação foi efetuada com sucesso.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_update_confirm_event()
#------------------------------------------------------------------------------#
    DEFINE l_status SMALLINT
    DEFINE l_ind_1  SMALLINT
    DEFINE l_ind_2  SMALLINT
    DEFINE l_count  SMALLINT
    DEFINE l_delete SMALLINT

    DEFINE l_action CHAR(02)

    # Efetua a leitura do registro na DML para efetuar a modificação.
    IF  NOT logm2_empresa_leitura(mr_empresa.cod_empresa,TRUE,0) THEN
        RETURN FALSE
    END IF

    # Define os valores da empresa.
    CALL logm2_empresa_set_cod_empresa(mr_empresa.cod_empresa)
    CALL logm2_empresa_set_den_empresa(mr_empresa.den_empresa)
    CALL logm2_empresa_set_den_reduz(mr_empresa.den_reduz)
    CALL logm2_empresa_set_end_empresa(mr_empresa.end_empresa)
    CALL logm2_empresa_set_den_bairro(mr_empresa.den_bairro)
    CALL logm2_empresa_set_den_munic(mr_empresa.den_munic)
    CALL logm2_empresa_set_uni_feder(mr_empresa.uni_feder)
    CALL logm2_empresa_set_ins_estadual(mr_empresa.ins_estadual)
    CALL logm2_empresa_set_num_cgc(mr_empresa.num_cgc)
    CALL logm2_empresa_set_num_caixa_postal(mr_empresa.num_caixa_postal)
    CALL logm2_empresa_set_cod_cep(mr_empresa.cod_cep)
    CALL logm2_empresa_set_num_telefone(mr_empresa.num_telefone)
    CALL logm2_empresa_set_num_telex(mr_empresa.num_telex)
    CALL logm2_empresa_set_num_fax(mr_empresa.num_fax)
    CALL logm2_empresa_set_end_telegraf(mr_empresa.end_telegraf)
    CALL logm2_empresa_set_num_reg_junta(mr_empresa.num_reg_junta)
    CALL logm2_empresa_set_dat_inclu_junta(mr_empresa.dat_inclu_junta)
    CALL logm2_empresa_set_ies_filial(mr_empresa.ies_filial)
    CALL logm2_empresa_set_dat_fundacao(mr_empresa.dat_fundacao)
    CALL logm2_empresa_set_cod_cliente(mr_empresa.cod_cliente)

    # Efetiva a modificação do registro. Se ocorreu algum erro durante a
    # modificação, força o cancelamento da operação.
    IF  NOT logt2_empresa_modifica(TRUE,0) THEN
        CALL _ADVPL_get_property(m_menubr_reference,"DO_CANCEL")
        RETURN FALSE
    END IF

    # Dependendo da quantidade de fornecedores é preciso dar um FEEDBACK ao
    # usuário para informar que está processando a inclusão alterando o cursor
    # do mouse (ampulheta).
    CALL _ADVPL_cursor_wait()

    # Verifica a quantidade de registros existentes na GRID.
    LET l_count  = _ADVPL_get_property(m_browse_reference,"ITEM_COUNT")
    LET l_status = TRUE

    # Adiciona/modifica os fornecedores.
    FOR l_ind_1 = 1 TO l_count
        # Se o fornecedor da linha atual não foi informado, ignora esta linha.
        IF  ma_fornecedores[l_ind_1].cod_fornecedor IS NULL THEN
            CONTINUE FOR
        END IF

        # Verificar se o fornecedor atual foi incluído ou modificado.
        IF  supm320_fornec_x_empresa_leitura(mr_empresa.cod_empresa,ma_fornecedores[l_ind_1].cod_fornecedor,TRUE,1) THEN
            LET l_action = "MO"
        ELSE
            LET l_action = "IN"
            CALL supm320_fornec_x_empresa_set_default()
        END IF

        CALL supm320_fornec_x_empresa_set_cod_empresa(mr_empresa.cod_empresa)
        CALL supm320_fornec_x_empresa_set_cod_fornecedor(ma_fornecedores[l_ind_1].cod_fornecedor)

        IF  l_action = "IN" THEN
            IF  NOT supt320_fornec_x_empresa_inclui(TRUE,0) THEN
                LET l_status = FALSE
                EXIT FOR
            END IF
        ELSE
            IF  NOT supt320_fornec_x_empresa_modifica(TRUE,0) THEN
                LET l_status = FALSE
                EXIT FOR
            END IF
        END IF
    END FOR

    # Exclui os fornecedores removidos. Para isto será utilizada a variável de
    # backup.
    FOR l_ind_1 = 1 TO 999
        LET l_delete = TRUE

        IF  ma_fornecedores_old[l_ind_1].cod_fornecedor IS NULL THEN
            EXIT FOR
        END IF

        # Verifica se o fornecedor foi removido.
        FOR l_ind_2 = 1 TO l_count
            IF  ma_fornecedores_old[l_ind_1].cod_fornecedor = ma_fornecedores[l_ind_2].cod_fornecedor THEN
                LET l_delete = FALSE
                EXIT FOR
            END IF
        END FOR

        IF  l_delete THEN
            IF  NOT supt320_fornec_x_empresa_exclui(mr_empresa.cod_empresa,ma_fornecedores_old[l_ind_1].cod_fornecedor,TRUE,TRUE,0) THEN
                LET l_status = FALSE
                EXIT FOR
            END IF
        END IF
    END FOR

    # Retorna o cursor do mouse ao normal (seta).
    CALL _ADVPL_cursor_arrow()

    # Se ocorreu algum erro na modificação, força o cancelamento da operação.
    IF  NOT l_status THEN
        CALL _ADVPL_get_property(m_menubr_reference,"DO_CANCEL")
        RETURN FALSE
    END IF

    # Desabilita os campos.
    CALL exe0001_enable_fields(FALSE)

    # Efetua COMMIT da transação.
    CALL LOG_transaction_commit()

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_update_cancel_event
Cancela a modificação do registro.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se permitido o cancelamento da modificação.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_update_cancel_event()
#------------------------------------------------------------------------------#
    # Desabilita os campos.
    CALL exe0001_enable_fields(FALSE)

    # Efetua o ROLLBACK, liberando os registros que foram bloqueados.
    CALL LOG_transaction_rollback()

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_copy_event
Executa o evento de cópia.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se permite a cópia do registro em tela.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_copy_event()
#------------------------------------------------------------------------------#
    # Para copiar é preciso que tenha um registro pesquisa em tela.
    IF  NOT m_pesquisa_ativa THEN
        CALL _ADVPL_set_property(m_status_reference,"WARNING_TEXT","Efetue primeiramente a pesquisa.")
        RETURN FALSE
    END IF

    # Ao ativar a cópia, desativa a pesquisa atual.
    LET m_pesquisa_ativa = FALSE

    # Habilita os campos para edição.
    CALL exe0001_enable_fields(TRUE)

    # Define o foco para o primeiro campo.
    CALL _ADVPL_set_property(ma_components[1,2],"GET_FOCUS")

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_copy_confirm_event
Confirma a cópia do registro.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se o registro foi copiado com sucesso.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_copy_confirm_event()
#------------------------------------------------------------------------------#
    RETURN exe0001_create_confirm_event()
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_copy_cancel_event
Cancela a cópia do registro.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se permitido o cancelamento da cópia.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_copy_cancel_event()
#------------------------------------------------------------------------------#
    RETURN exe0001_create_cancel_event()
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_delete_event
Executa o evento de exclusão.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se permite a exclusão do registro em tela.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_delete_event()
#------------------------------------------------------------------------------#
    DEFINE l_message      CHAR(200)
    DEFINE l_where_clause CHAR(200)

    # Para excluir é preciso que tenha um registro pesquisa em tela.
    IF  NOT m_pesquisa_ativa THEN
        CALL _ADVPL_set_property(m_status_reference,"WARNING_TEXT","Efetue primeiramente a pesquisa.")
        RETURN FALSE
    END IF

    # Pergunta ao usuário se confirma a exclusão dos registros.
    LET l_message = "Confirma a exclusão da empresa ",mr_empresa.cod_empresa CLIPPED,
        " e dos fornecedores relacionados a ela?"

    IF  NOT LOG_question(l_message) THEN
        CALL _ADVPL_set_property(m_status_reference,"WARNING_TEXT","Exclusão cancelada.")
        RETURN FALSE
    END IF

    # Inicia uma transação com o banco de dados.
    CALL LOG_transaction_begin()

    # Efetua a exclusão da empresa selecionada, em modo cascata se não houver
    # impedimentos.
    IF  NOT logt2_empresa_exclui(mr_empresa.cod_empresa,TRUE,TRUE,0) THEN
        CALL LOG_transaction_rollback()
        RETURN FALSE
    END IF

    # Dependendo da quantidade de fornecedores é preciso dar um FEEDBACK ao
    # usuário para informar que está processando a exclusão alterando o cursor
    # do mouse (ampulheta).
    CALL _ADVPL_cursor_wait()

    # Efetua a exclusão dos fornecedores relacionados a empresa selecionada, em
    # modo cascata se não houver impedimentos.
    LET l_where_clause = "fornec_x_empresa.cod_empresa='",mr_empresa.cod_empresa CLIPPED,"'"

    IF  NOT supt320_fornec_x_empresa_exclui_condicional(l_where_clause,TRUE,TRUE,0) THEN
        CALL LOG_transaction_rollback()
        CALL _ADVPL_cursor_arrow()
        RETURN FALSE
    END IF

    # Efetua COMMIT da transação.
    CALL LOG_transaction_commit()

    # Tenta navegar para o próximo registro da pesquisa, se não conseguiu
    # significa que foi excluída o último registro válido do CURSOR, neste caso
    # desativa a pesquisa atual.
    IF  NOT exe0001_next_event() THEN
        LET m_pesquisa_ativa = FALSE

        # Limpa os campos da tela e inicializa a GRID.
        INITIALIZE mr_empresa.*,ma_fornecedores TO NULL
        CALL _ADVPL_set_property(m_browse_reference,"ITEM_COUNT",1)
    END IF

    # Retorna o cursor do mouse ao normal (seta).
    CALL _ADVPL_cursor_arrow()

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_find_event
Executa o evento de pesquisa.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se a pesquisa foi confirmada pelo usuário.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_find_event()
#------------------------------------------------------------------------------#
    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(500)
    DEFINE l_order_by     CHAR(100)

    # Limpa os campos da tela e inicializa a GRID.
    INITIALIZE mr_empresa.*,ma_fornecedores TO NULL
    CALL _ADVPL_set_property(m_browse_reference,"ITEM_COUNT",1)

    # Força a limpeza dos campos da tela, isto é necessário pois abaixo é aberta
    # a janela de filtro de pesquisa, com a abertura desta janela a atualização
    # da tela do programa fica "congelada" até que a janela de filtro seja
    # encerrada.
    CALL exe0001_refresh_fields()

    # Cria o componente LCONSTRUCT, que permite a inserção de filtros de
    # pesquisa pelo usuário.
    IF  m_constc_reference IS NULL THEN
        LET m_constc_reference = _ADVPL_create_component(NULL,"LCONSTRUCT")

        # Adiciona a tabela empresa (do metadado) no filtro.
        CALL _ADVPL_set_property(m_constc_reference,"ADD_TABLE","empresa")

        # Adiciona as colunas da tabela empresa (do metadado) no filtro.
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","cod_empresa",NULL,"zoom_empresa")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","den_empresa")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","den_reduz")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","end_empresa")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","den_bairro")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","den_munic")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","uni_feder")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","num_caixa_postal")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","cod_cep")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","num_telefone")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","ins_estadual")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","num_cgc")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","num_telex")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","num_fax")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","end_telegraf")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","num_reg_junta")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","dat_inclu_junta")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","ies_filial")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","dat_fundacao")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","empresa","cod_cliente")

        # Adiciona a tabela fornecedor (do metadado) no filtro.
        CALL _ADVPL_set_property(m_constc_reference,"ADD_TABLE","fornecedor")

        # Adiciona as colunas da tabela fornecedor (do metadado) no filtro.
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","fornecedor","cod_fornecedor",NULL,"zoom_fornecedor")
        CALL _ADVPL_set_property(m_constc_reference,"ADD_COLUMN","fornecedor","raz_social")
    END IF

    # Inicia o filtro de pesquisa e verifica se o usuário confirmou os filtros.
    LET l_status = _ADVPL_get_property(m_constc_reference,"INIT_CONSTRUCT")

    IF  NOT l_status THEN
        CALL _ADVPL_set_property(m_status_reference,"WARNING_TEXT","Pesquisa cancelada.")
        RETURN FALSE
    END IF

    # Recupera o WHERE_CLAUSE e o ORDER_BY conforme filtros e ordenação
    # informados pelo usuário para a tabela empresa.
    LET l_where_clause = _ADVPL_get_property(m_constc_reference,"WHERE_CLAUSE_BY_TABLE","empresa")
    LET l_order_by = _ADVPL_get_property(m_constc_reference,"ORDER_BY_TABLE","empresa")

    IF  l_where_clause IS NULL THEN
        LET l_where_clause = "1=1"
    END IF

    IF  l_order_by IS NULL THEN
        LET l_order_by = "empresa.cod_empresa"
    END IF

    LET l_status = exe0001_execute_query(l_where_clause,l_order_by)

    RETURN l_status
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_first_event
Navega para o primeiro registro.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se a paginação foi efetuada com sucesso.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_first_event()
#------------------------------------------------------------------------------#
    RETURN exe0001_execute_fetch("FIRST")
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_previous_event
Navega para o registro anterior.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se a paginação foi efetuada com sucesso.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_previous_event()
#------------------------------------------------------------------------------#
    RETURN exe0001_execute_fetch("PREVIOUS")
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_next_event
Navega para o registro seguinte.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se a paginação foi efetuada com sucesso.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_next_event()
#------------------------------------------------------------------------------#
    RETURN exe0001_execute_fetch("NEXT")
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_last_event
Navega para o último registro.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se a paginação foi efetuada com sucesso.
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_last_event()
#------------------------------------------------------------------------------#
    RETURN exe0001_execute_fetch("LAST")
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_print_event
Executa o programa de geração de relatório.

@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14
/}
#------------------------------------------------------------------------------#
FUNCTION exe0001_print_event()
#------------------------------------------------------------------------------#
    CALL LOG_ADVPL_application_run("exe0003","")
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_execute_query
Executa a pesquisa dos registros no banco de dados conforme filtros informados
pelo usuário.

@protected
@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@param l_where_clause, CHAR, Cláusula WHERE SQL conforme filtro informado.
@param l_order_by, CHAR, Cláusula ORDER BY SQL conforme ordenação informada.

@return SMALLINT, Verdadeiro se a pesquisa foi efetuada com sucesso.
/}
#------------------------------------------------------------------------------#
PRIVATE FUNCTION exe0001_execute_query(l_where_clause,l_order_by)
#------------------------------------------------------------------------------#
    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(500)
    DEFINE l_order_by     CHAR(100)

    DEFINE l_sql_stmt     CHAR(2000)
    DEFINE l_cod_empresa  LIKE empresa.cod_empresa

    # Monta o SQL para criar o CURSOR de pesquisa. Seleciona apenas o código da
    # empresa, pois será utilizada a DML para carregar o restante dos campos.
    LET l_sql_stmt = "SELECT empresa.cod_empresa",
                     "  FROM empresa",
                     " WHERE ",l_where_clause CLIPPED,
                     " ORDER BY ",l_order_by

    # Prepara o SQL montado acima.
    WHENEVER ERROR CONTINUE
    PREPARE vr_query1_exe0001 FROM l_sql_stmt
    WHENEVER ERROR STOP
    IF  sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("PREPARE SQL","vr_query1_exe0001",0)
        RETURN FALSE
    END IF

    # Declara o CURSOR de pesquisa (SCROLL) para o SQL preparado acima.
    # Será utilizado o WITH HOLD, pois o programa possui operação de modificação
    # com controle de transação. Sem o WITH HOLD ao abrir a transação o CURSOR
    # é excluído da memória.
    WHENEVER ERROR CONTINUE
    DECLARE cq_query_exe0001 SCROLL CURSOR WITH HOLD FOR vr_query1_exe0001
    WHENEVER ERROR STOP
    IF  sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("DECLARE CURSOR","cq_query_exe0001",0)
        RETURN FALSE
    END IF

    # Abre o CURSOR declarado acima.
    WHENEVER ERROR CONTINUE
    OPEN cq_query_exe0001
    WHENEVER ERROR STOP
    IF  sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("OPEN CURSOR","cq_query_exe0001",0)
        RETURN FALSE
    END IF

    # Efetua o FETCH da pesquisa nas variáveis da tela. Valida se o FETCH
    # retornou SQLCODE diferente de NOTFOUND.
    WHENEVER ERROR CONTINUE
    FETCH cq_query_exe0001 INTO l_cod_empresa
    WHENEVER ERROR STOP
    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode = NOTFOUND THEN
            CALL _ADVPL_set_property(m_status_reference,"WARNING_TEXT","Argumentos de pesquisa não encontrados.")
        ELSE
            CALL log0030_processa_err_sql("FETCH CURSOR","cq_query_exe0001",0)
        END IF

        LET m_pesquisa_ativa = FALSE
    ELSE
        LET m_pesquisa_ativa = TRUE

        # Carrega o restante dos campos da empresa encontrada na pesquisa e
        # também os fornecedores relacionados a empresa encontrada.
        CALL exe0001_load_empresa(l_cod_empresa)
        CALL exe0001_load_fornecedores(l_cod_empresa)

        # Carrega as descrições dos campos de chave estrangeira.
        CALL exe0001_load_nom_cliente()

        # Carrega as variáveis de backup.
        LET mr_empresa_old.* = mr_empresa.*
        LET ma_fornecedores_old = ma_fornecedores

        CALL _ADVPL_set_property(m_status_reference,"INFO_TEXT","Pesquisa efetuada com sucesso.")
    END IF

    RETURN m_pesquisa_ativa
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_execute_fetch
Executa a paginação do registro para a direção informada.

@protected
@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@param l_fetch, CHAR, Direção da paginação.
@return SMALLINT, Verdadeiro se a paginação foi efetuada com sucesso.
/}
#------------------------------------------------------------------------------#
PRIVATE FUNCTION exe0001_execute_fetch(l_fetch)
#------------------------------------------------------------------------------#
    DEFINE l_fetch CHAR(08)
    DEFINE l_cod_empresa LIKE empresa.cod_empresa

    DEFINE l_status SMALLINT

    # Verifica se a pesquisa está ativa.
    IF  NOT m_pesquisa_ativa THEN
        CALL _ADVPL_set_property(m_status_reference,"WARNING_TEXT","Efetue primeiramente a pesquisa.")
        RETURN FALSE
    END IF

    LET l_status = TRUE

    # Carrega as variáveis de backup.
    LET mr_empresa_old.* = mr_empresa.*
    LET ma_fornecedores_old = ma_fornecedores

    WHILE TRUE
        CASE l_fetch
            WHEN "FIRST"
                WHENEVER ERROR CONTINUE
                FETCH FIRST cq_query_exe0001 INTO l_cod_empresa
                WHENEVER ERROR STOP
            WHEN "PREVIOUS"
                WHENEVER ERROR CONTINUE
                FETCH PREVIOUS cq_query_exe0001 INTO l_cod_empresa
                WHENEVER ERROR STOP
            WHEN "NEXT"
                WHENEVER ERROR CONTINUE
                FETCH NEXT cq_query_exe0001 INTO l_cod_empresa
                WHENEVER ERROR STOP
           WHEN "LAST"
                WHENEVER ERROR CONTINUE
                FETCH LAST cq_query_exe0001 INTO l_cod_empresa
                WHENEVER ERROR STOP
        END CASE
        IF  sqlca.sqlcode <> 0 THEN
            LET l_status = FALSE
            EXIT WHILE
        END IF

        # Verifica se a empresa encontrada na paginação é diferente da que já
        # encontra-se na tela e carrega o restante dos campos da tabela empresa
        # encontrada na pesquisa e também os fornecedores relacionados a empresa
        # encontrada.
        IF  mr_empresa_old.cod_empresa <> l_cod_empresa THEN
            IF  exe0001_load_empresa(l_cod_empresa) THEN
                # Carrega os fornecedores da empresa.
                CALL exe0001_load_fornecedores(l_cod_empresa)

                # Carrega as descrições dos campos de chave estrangeira.
                CALL exe0001_load_nom_cliente()

                # Carrega as variáveis de backup.
                LET mr_empresa_old.* = mr_empresa.*
                LET ma_fornecedores_old = ma_fornecedores

                EXIT WHILE
            END IF
        END IF

        # Se a empresa não foi encontrada no banco de dados, repete o processo
        # de paginação.
        CASE l_fetch
            WHEN "FIRST" LET l_fetch = "NEXT"
            WHEN "LAST"  LET l_fetch = "PREVIOUS"
        END CASE
    END WHILE

    # Se foi realizada todas as tentivas de navegação e nenhum registro do
    # CURSOR foi encontrado no banco de dados, exibe a mensagem.
    IF  NOT l_status THEN
        CALL _ADVPL_set_property(m_status_reference,"WARNING_TEXT","Não existem mais dados nesta direção.")
    END IF

    RETURN l_status
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_load_empresa
Carrega as informações em tela da empresa informada.

@protected
@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@param l_cod_empresa, CHAR, Código da empresa.
/}
#------------------------------------------------------------------------------#
PRIVATE FUNCTION exe0001_load_empresa(l_cod_empresa)
#------------------------------------------------------------------------------#
    DEFINE l_cod_empresa LIKE empresa.cod_empresa

    IF  NOT logm2_empresa_leitura(l_cod_empresa,TRUE,1) THEN
        RETURN FALSE
    END IF

    LET mr_empresa.cod_empresa = logm2_empresa_get_cod_empresa()
    LET mr_empresa.den_empresa = logm2_empresa_get_den_empresa()
    LET mr_empresa.den_reduz = logm2_empresa_get_den_reduz()
    LET mr_empresa.end_empresa = logm2_empresa_get_end_empresa()
    LET mr_empresa.den_bairro = logm2_empresa_get_den_bairro()
    LET mr_empresa.den_munic = logm2_empresa_get_den_munic()
    LET mr_empresa.uni_feder = logm2_empresa_get_uni_feder()
    LET mr_empresa.ins_estadual = logm2_empresa_get_ins_estadual()
    LET mr_empresa.num_cgc = logm2_empresa_get_num_cgc()
    LET mr_empresa.num_caixa_postal = logm2_empresa_get_num_caixa_postal()
    LET mr_empresa.cod_cep = logm2_empresa_get_cod_cep()
    LET mr_empresa.num_telefone = logm2_empresa_get_num_telefone()
    LET mr_empresa.num_telex = logm2_empresa_get_num_telex()
    LET mr_empresa.num_fax = logm2_empresa_get_num_fax()
    LET mr_empresa.end_telegraf = logm2_empresa_get_end_telegraf()
    LET mr_empresa.num_reg_junta = logm2_empresa_get_num_reg_junta()
    LET mr_empresa.dat_inclu_junta = logm2_empresa_get_dat_inclu_junta()
    LET mr_empresa.ies_filial = logm2_empresa_get_ies_filial()
    LET mr_empresa.dat_fundacao = logm2_empresa_get_dat_fundacao()
    LET mr_empresa.cod_cliente = logm2_empresa_get_cod_cliente()

    RETURN TRUE
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_load_fornecedores
Carrega as informações em tela dos fornecedores ligados a empresa informada.

@protected
@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@param l_cod_empresa, CHAR, Código da empresa.
/}
#------------------------------------------------------------------------------#
PRIVATE FUNCTION exe0001_load_fornecedores(l_cod_empresa)
#------------------------------------------------------------------------------#
    DEFINE l_cod_empresa LIKE empresa.cod_empresa

    DEFINE l_where_clause CHAR(0500)
    DEFINE l_order_by     CHAR(0100)
    DEFINE l_sql_stmt     CHAR(5000)

    DEFINE l_ind     SMALLINT
    DEFINE l_status  SMALLINT

    DEFINE l_message CHAR(200)

    # Dependendo da quantidade de fornecedores é preciso dar um FEEDBACK ao
    # usuário para informar que está processando a pesquisa alterando o cursor
    # do mouse (ampulheta).
    CALL _ADVPL_cursor_wait()

    # Inicializa a variável dos fornecedores.
    INITIALIZE ma_fornecedores TO NULL
    LET l_status = TRUE

    # Recupera o filtro informado para a tabela de fornecedores.
    IF  m_pesquisa_ativa AND m_constc_reference IS NOT NULL THEN
        LET l_where_clause = _ADVPL_get_property(m_constc_reference,"WHERE_CLAUSE_BY_TABLE","fornecedor")
        LET l_order_by = _ADVPL_get_property(m_constc_reference,"ORDER_BY_TABLE","fornecedor")
    END IF

    IF  l_where_clause IS NULL THEN
        LET l_where_clause = "1=1"
    END IF

    IF  l_order_by IS NULL THEN
        LET l_order_by = "fornecedor.cod_fornecedor"
    END IF

    # Monta o SQL para pesquisa dos fornecedores.
    LET l_sql_stmt = "SELECT fornecedor.cod_fornecedor,fornecedor.raz_social",
                     "  FROM fornecedor,fornec_x_empresa",
                     " WHERE fornec_x_empresa.cod_fornecedor = fornecedor.cod_fornecedor",
                     "   AND fornec_x_empresa.cod_empresa = '",l_cod_empresa CLIPPED,"'",
                     "   AND ",l_where_clause CLIPPED,
                     " ORDER BY ",l_order_by

    # Prepara o SQL montado acima.
    WHENEVER ERROR CONTINUE
    PREPARE vr_query2_exe0001 FROM l_sql_stmt
    WHENEVER ERROR STOP
    IF  sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("PREPARE SQL","vr_query2_exe0001",0)
        RETURN FALSE
    END IF

    # Declara o CURSOR para o SQL preparado acima. Não é necessário utilizar
    # SCROLL ou WITH HOLD, pois iremos utilizar o CURSOR e logo em seguida
    # liberá-lo da memória.
    WHENEVER ERROR CONTINUE
    DECLARE cq_query2_exe0001 CURSOR FOR vr_query2_exe0001
    WHENEVER ERROR STOP
    IF  sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("DECLARE CURSOR","cq_query2_exe0001",0)
        RETURN FALSE
    END IF

    # Efetua o FOREACH do CURSOR acima carregando o resultado no ARRAY.
    LET l_ind = 1

    WHENEVER ERROR CONTINUE
    FOREACH cq_query2_exe0001 INTO ma_fornecedores[l_ind].cod_fornecedor,
                                   ma_fornecedores[l_ind].raz_social
        # Verifica se houve algum erro na leitura do CURSOR.
        IF  sqlca.sqlcode <> 0 THEN
            CALL log0030_processa_err_sql("FOREACH CURSOR","cq_query2_exe0001",0)
            LET l_ind = 1
            LET l_status = FALSE
            EXIT FOREACH
        END IF

        # Incrementa o índice que controla a carga do ARRAY.
        LET l_ind = l_ind + 1

        # Se foi encontrado mais fornecedores que o permitido no ARRAY, emite ao
        # usuário mensagem pedindo para refinar os filtros de pesquisa.
        IF  l_ind > 999 THEN
            LET l_message = "Quantidade máxima de exibição de fornecedores atingido. Por gentileza, refine o resultando utilizando os filtro de pesquisa."
            CALL log0030_processa_mensagem(l_message,"exclamation",0)
            EXIT FOREACH
        END IF
    END FOREACH

    # Libera o CURSOR da memória.
    FREE cq_query2_exe0001
    WHENEVER ERROR STOP

    # Retira o último índice extra adicionado no último laço do FOREACH.
    LET l_ind = l_ind - 1
    CALL _ADVPL_set_property(m_browse_reference,"ITEM_COUNT",l_ind)

    # Retorna o cursor do mouse ao normal (seta).
    CALL _ADVPL_cursor_arrow()

    RETURN l_status
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_enable_fields
Habilita/desabilita os campos.

@protected
@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@param l_enable, SMALLINT, Verdadeiro para habilitar os campos.
/}
#------------------------------------------------------------------------------#
PRIVATE FUNCTION exe0001_enable_fields(l_enable)
#------------------------------------------------------------------------------#
    DEFINE l_enable SMALLINT
    DEFINE l_ind    SMALLINT

    FOR l_ind = 1 TO m_idx_component
        CALL _ADVPL_set_property(ma_components[l_ind,2],"ENABLE",l_enable)
    END FOR

    CALL _ADVPL_set_property(m_browse_reference,"EDITABLE",TRUE)
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_get_field_reference
Retorna a referência do componente FREEFORM criado para o campo informado.

@protected
@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@param l_field, CHAR, Nome do campo da tela.
@return VARCHAR, Refêrencia do componente FREEFORM do campo informado.
/}
#------------------------------------------------------------------------------#
PRIVATE FUNCTION exe0001_get_field_reference(l_field)
#------------------------------------------------------------------------------#
    DEFINE l_field CHAR(50)
    DEFINE l_refer VARCHAR(10)

    DEFINE l_ind   SMALLINT

    FOR l_ind = 1 TO m_idx_component
        IF  UPSHIFT(ma_components[l_ind,1]) = UPSHIFT(l_field) THEN
            LET l_refer = ma_components[l_ind,2]
            EXIT FOR
        END IF
    END FOR

    RETURN l_refer
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_refresh_fields
Força a atualização dos campos em tela.

@protected
@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14
/}
#------------------------------------------------------------------------------#
PRIVATE FUNCTION exe0001_refresh_fields()
#------------------------------------------------------------------------------#
    DEFINE l_ind SMALLINT

    FOR l_ind = 1 TO m_idx_component
        CALL _ADVPL_set_property(ma_components[l_ind,2],"REFRESH")
    END FOR

    CALL _ADVPL_set_property(m_browse_reference,"REFRESH")
END FUNCTION

#------------------------------------------------------------------------------#
{/*Protheus.doc*/ exe0001_lock_data
Efetua o bloqueio dos registrosna modificação e na exclusão.

@protected
@type function
@author Rubens Dos Santos Filho
@since 21/11/2016
@version 12.1.14

@return SMALLINT, Verdadeiro se os registros foram bloqueados com sucesso.
/}
#------------------------------------------------------------------------------#
PRIVATE FUNCTION exe0001_lock_data()
#------------------------------------------------------------------------------#
    DEFINE l_status SMALLINT
    DEFINE l_ind    SMALLINT
    DEFINE l_count  SMALLINT

    # Efetua o bloqueio da empresa selecionada.
    IF  NOT logm2_empresa_bloqueio_registro(mr_empresa.cod_empresa,0) THEN
        RETURN FALSE
    END IF

    LET l_status = TRUE

    # Dependendo da quantidade de fornecedores é preciso dar um FEEDBACK ao
    # usuário para informar que está processando o bloqueio alterando o cursor
    # do mouse (ampulheta).
    CALL _ADVPL_cursor_wait()

    # Efetua o bloqueio de todos os fornecedores selecionados.
    LET l_count = _ADVPL_get_property(m_browse_reference,"ITEM_COUNT")

    FOR l_ind = 1 TO l_count
        IF  NOT supm320_fornec_x_empresa_bloqueio_registro(mr_empresa.cod_empresa,ma_fornecedores[l_ind].cod_fornecedor,0) THEN
            LET l_status = FALSE
            EXIT FOR
        END IF
    END FOR

    # Retorna o cursor do mouse ao normal (seta).
    CALL _ADVPL_cursor_arrow()

    RETURN l_status
END FUNCTION

#------------------------------------------------------------------------------#
FUNCTION exe0001_version_info()
#------------------------------------------------------------------------------#
    RETURN "$Archive: exe001.4gl $|$Revision: 1 $|$Date: 21/11/2016 00:00 $|$Modtime: 21/11/2016 00:00 $"
END FUNCTION
