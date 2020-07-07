#-----------------------------------------------------------------#
#OBJETIVO.: CRUD d tabela LOG_USU_GRUPOS                          #
#VALIDAÇÃO: O usuário deverá constar da tabela USUARIOS e o grupo #
#           deverá constar da tabela LOG_GRUPOS                   #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa LIKE empresa.cod_empresa
    DEFINE p_user        LIKE usuarios.cod_usuario
END GLOBALS

#Variáveis apra armazenar a referencia da janela principal (DIALOG) 
#e a barra de status, a qual ficará no rodapé da DIALOG.

DEFINE m_dialog_reference    VARCHAR(10)
DEFINE m_statusbar_reference VARCHAR(10)

#O componente DIALOG é o prioncipal e deve ser o primeiro a ser criado.
#os demais componentes deverão ser criados dentro do DIALOG, ou sejam,
#serão considerados filhos do DIALOG. Um componente filho também poderá
#ter outros filhos. Por exemplo, podemos criar uma barra de menu dentro
#da DIALOG e dentro da barra de menu criar botões.


#A seguir, a refereência dos componentes. Em forma de ARRAY, fica
#mias fácil habilitá-los ou desabilitá-los, pois
#pemos utilizar um FOR... END FOR, para isso. Da forma que está definido
#abaixo (ARRAY[100]) podemos utilizar essa ARRY para armazenar as
#referências de até 100 componentes.

DEFINE ma_fields_references  ARRAY[100] OF VARCHAR(10)

#records que armazenará o registro corrente e o
#backup do registro, para permitir sua restauração, 
#quando uma edição e cancelada.

DEFINE mr_log_usu_grupos,
       mr_log_usu_grupos_old RECORD
                                 usuario         LIKE log_usu_grupos.usuario,
                                 nom_funcionario LIKE usuarios.nom_funcionario
                             END RECORD

#ARRAY que armazenará os dados da grade

DEFINE ma_log_usu_grupos     ARRAY[100] OF RECORD
                                 grupo           LIKE log_usu_grupos.grupo,
                                 des_grupo       LIKE log_grupos.des_grupo
                             END RECORD

#Variáveis para armazenar as referências do zoom
# do usuáio e zoom do grupo de usuário

DEFINE m_zoom_usuarios_reference   VARCHAR(10)
DEFINE m_zoom_log_grupos_reference VARCHAR(10)

#Variável para armazenar a referência da pesquisa (consulta)

DEFINE m_construct_reference VARCHAR(10)

#funcção principal cujo nome deve ser aquele cadastrado como nome
#do programa no MEN0050 (cadastro de menus). No men0050, o tipo de
#processo deve ser 2 (programa sem MAIN...END MAIN)

#----------------#
FUNCTION tst0001()
#----------------#

    #Referência da barra de menu
    DEFINE l_menubar_reference VARCHAR(10)
    #Referência do painel
    DEFINE l_panel_reference   VARCHAR(10)

    #Referências das opções do programa
    
    DEFINE l_create_reference,
           l_update_reference,
           l_find_reference,
           l_first_reference,
           l_previous_reference,
           l_next_reference,
           l_last_reference,
           l_delete_reference  VARCHAR(10)

    WHENEVER ERROR CONTINUE

    #chamada da log que verifica se o usuário tem acesso ao programa.
    #pode ser substituida pela log001_acessa_usuario("ESPEC999","") 
    
    IF  LOG_initApp("PADRAO") <> 0 THEN
        RETURN
    END IF
    
    #Para testar sem abrir o programa pelo menu, 
    #comentar a função acima e descomentar a função abaixo.
    
    #CALL LOG_connectDatabase("DEFAULT")

    INITIALIZE mr_log_usu_grupos.*,ma_log_usu_grupos TO NULL

    #criação da janela principal e definição de algumas propriedades p/ a mesma
    
    LET m_dialog_reference = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog_reference,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog_reference,"TITLE","Cadastro de grupo por usuários")

    #Criação da barra de status (filha da DIALOG)
    LET m_statusbar_reference = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog_reference)

    #Criacao do menu (filho da DIALOG)
    LET l_menubar_reference = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog_reference)
    CALL _ADVPL_set_property(l_menubar_reference,"HELP_VISIBLE",FALSE)

    #Criação de botões: existem bptões padrões que já possuem uma identidade propria e
    #botões customizados. Botões customizados podem ser criados com a definição para o mesmo.
    #Para saber as imagnes: SELECT DISTINCT resource_name FROM frm_toolbar ORDER BY 1;
    #Criação do botão Incluir. Observe que o mesmo é filho do LMENUBAR
    LET l_create_reference = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar_reference)
    #Definição da FUNCTION que será chamada ao clicar no botão Incluir. Se essa função retornar
    #TRUE, os botões Confirmar e Cancelar serão exibidos. Caso contrário, não.
    CALL _ADVPL_set_property(l_create_reference,"EVENT","tst0001_create")
    #Definição da função a ser chamada quando o usuário CONFIRMAR a inclusção
    CALL _ADVPL_set_property(l_create_reference,"CONFIRM_EVENT","tst0001_create_confirm")
    #Definição da função a ser chamada quando o usuário CANCELAR a inclusção
    CALL _ADVPL_set_property(l_create_reference,"CANCEL_EVENT","tst0001_create_cancel")

    # A seguir, criação/definição dos demais botões
    
    LET l_update_reference = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar_reference)
    CALL _ADVPL_set_property(l_update_reference,"EVENT","tst0001_update")
    CALL _ADVPL_set_property(l_update_reference,"CONFIRM_EVENT","tst0001_update_confirm")
    CALL _ADVPL_set_property(l_update_reference,"CANCEL_EVENT","tst0001_update_cancel")

    LET l_find_reference = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar_reference)
    CALL _ADVPL_set_property(l_find_reference,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find_reference,"EVENT","tst0001_find")

    LET l_first_reference = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar_reference)
    CALL _ADVPL_set_property(l_first_reference,"EVENT","tst0001_first")

    LET l_previous_reference = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar_reference)
    CALL _ADVPL_set_property(l_previous_reference,"EVENT","tst0001_previous")

    LET l_next_reference = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar_reference)
    CALL _ADVPL_set_property(l_next_reference,"EVENT","tst0001_next")

    LET l_last_reference = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar_reference)
    CALL _ADVPL_set_property(l_last_reference,"EVENT","tst0001_last")

    LET l_delete_reference = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar_reference)
    CALL _ADVPL_set_property(l_delete_reference,"EVENT","tst0001_delete")

    #O botão Sair não precisa de função que define sua ação. Automaticamente, fecha a janela.
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar_reference)

    #Criação de um painel, para organizar os campos do cabeçalho e da grade.    
    LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",m_dialog_reference)
    CALL _ADVPL_set_property(l_panel_reference,"ALIGN","CENTER")
    
    #Chama FUNCTION para criação dos campos
    CALL tst0001_create_fields(l_panel_reference)

    #Antes de abrir a janela principal, desabilita os campos, para que o usuário não
    #tenha acesso aos mesmos antes de selecionar a operação.
    CALL tst0001_enable_fields(FALSE)

    #Ativa a janela principal, ou seja, faz com que a mesma seja apresentada ao usuário    
    CALL _ADVPL_set_property(m_dialog_reference,"ACTIVATE",TRUE)
    
END FUNCTION

#Cria os campos de edição dentro do painel passado como parâmetro. Antes, porém,
#serão criados dentro desse pinel recebido mais dois paineis: uma para organizar os
#campos do cabeçalho e outro para organizar os campos (colunas) da grade.

#---------------------------------------------------#
FUNCTION tst0001_create_fields(l_container_reference)
#---------------------------------------------------#

    DEFINE l_container_reference VARCHAR(10)
    DEFINE l_panel_reference     VARCHAR(10)
    DEFINE l_layout_reference    VARCHAR(10)
    DEFINE l_label_reference     VARCHAR(10)
    DEFINE l_field_reference     VARCHAR(10)
    DEFINE l_tabcolumn_reference VARCHAR(10)

    #criação do painel do 1o. painel no topo e com altura de 60 pixeis
    LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",l_container_reference)
    CALL _ADVPL_set_property(l_panel_reference,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel_reference,"HEIGHT",60)
    #Como os campos do cabeçalho são 4 (rótulo e caixa de edição do cod usuário, icone do zoom e
    #descrição do usuário), criaremos, dentro do painel, um componente do tipo LLAYOUT, o qual
    #distribuirá os campos em forma de 4 colunas
    LET l_layout_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference)
    CALL _ADVPL_set_property(l_layout_reference,"COLUMNS_COUNT",4)

    #criação do label (rótulo) do campo
    LET l_label_reference = _ADVPL_create_component(NULL,"LLABEL",l_layout_reference)
    CALL _ADVPL_set_property(l_label_reference,"TEXT","Usuário:")
    #Por ser um campo obrigatório, o texto do mesmo ficará em negrito (TRUE)
    #                                                 tam  cor negrit italic
    CALL _ADVPL_set_property(l_label_reference,"FONT",NULL,NULL,TRUE,FALSE)
    
    #criação/definição da caixa de texto, para entrada do código go usuário. Observe que a
    #variável que guardará a refer~encia é a ARRAY ma_fields_references, o que irá facilitar
    #as ações e habilitar e desabilitar o campo quando conveniente
    LET ma_fields_references[1] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout_reference)
    #definição da qtd máxima de digitos que deverão entrar
    CALL _ADVPL_set_property(ma_fields_references[1],"LENGTH",8)
    #definição da variável que irá receber o conteúdo digitado: record mr_log_usu_grupos e
    #sua propriedade ou campo usuario (mr_log_usu_grupos.usuario)
    CALL _ADVPL_set_property(ma_fields_references[1],"VARIABLE",mr_log_usu_grupos,"usuario")
    #definição da mascara de entrada: @& = letras minúsculas; @! = letras maiusculas
    CALL _ADVPL_set_property(ma_fields_references[1],"PICTURE","@&")
    #FUNCTION para validação da entrada. Se retornar TRUE, a entrada será válida. Se 
    #retornar FALSE, o usuário terá que re-digitar a informação
   #CALL _ADVPL_set_property(ma_fields_references[1],"VALID","tst0001_usuario_valid")

    #criação/definição do icone do zoom
    LET ma_fields_references[2] = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout_reference)
    CALL _ADVPL_set_property(ma_fields_references[2],"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(ma_fields_references[2],"SIZE",24,20)
    CALL _ADVPL_set_property(ma_fields_references[2],"CLICK_EVENT","tst0001_zoom_usuarios")
    #criação/definição do campos para exibir o nome do usuário
    LET l_field_reference = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout_reference)
    CALL _ADVPL_set_property(l_field_reference,"LENGTH",30) 
    CALL _ADVPL_set_property(l_field_reference,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_field_reference,"VARIABLE",mr_log_usu_grupos,"nom_funcionario")

    #criação/definição do painel para organização dos campos da grade
    LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",l_container_reference)
    CALL _ADVPL_set_property(l_panel_reference,"ALIGN","CENTER")

    #Criação do lay-out, para organizar a grade. A grade é considerada uma única coluna, para
    #efeito de acomodação no lay-out. Se quiser colocar a grade diretamente no painel, pode, 
    #porém, colocando-a no lay-out é possivel contralar as margens.
    LET l_layout_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference)
    CALL _ADVPL_set_property(l_layout_reference,"COLUMNS_COUNT",1) #número de colunas
    CALL _ADVPL_set_property(l_layout_reference,"EXPANSIBLE",TRUE) #faz com que a grade utililize todo o espação disponível no lay-out

    #criação/definição da grade (browse)
    LET ma_fields_references[3] = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout_reference)
    CALL _ADVPL_set_property(ma_fields_references[3],"ALIGN","CENTER")
    #definição da FUNCTION que derá chamada antes de criar uma nova linha. O objetivo é validar a
    #linha atual.
    CALL _ADVPL_set_property(ma_fields_references[3],"BEFORE_ADD_ROW_EVENT","tst0001_grupos_after_row")

    #Nossa grade terá 3 colunas, a saber:
    #1a. código do grupo
    LET l_tabcolumn_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",ma_fields_references[3])
    #definição do cabeçalho da coluna. o * (* Grupo) indica que o campo é obrigatório
    CALL _ADVPL_set_property(l_tabcolumn_reference,"HEADER","* Grupo")
    #habilita edição
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDITABLE",TRUE)
    #largura da coluna em pixeis
    CALL _ADVPL_set_property(l_tabcolumn_reference,"COLUMN_WIDTH",200)
    #definição do tipo do campo (campo texto)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_COMPONENT","LTEXTFIELD")
    #número máximo de caracteres que poderá entrar no campo
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_PROPERTY","LENGTH",8)
    #mascara de entrada que converterá o conteúdi para minúsculo
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_PROPERTY","PICTURE","@&")
    #função que será chamada para validação da entrada
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_PROPERTY","VALID","tst0001_grupo_valid")
    #propriedade da ARRAY onde será armazenado o cunteúdo informado pelo usuário
    CALL _ADVPL_set_property(l_tabcolumn_reference,"VARIABLE","grupo")
    
    #2a. icone do zoom (lupa)
    LET l_tabcolumn_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",ma_fields_references[3])
    CALL _ADVPL_set_property(l_tabcolumn_reference,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"BEFORE_EDIT_EVENT","tst0001_zoom_log_grupos")
    
    #3a. descrição do grupo
    LET l_tabcolumn_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",ma_fields_references[3])
    CALL _ADVPL_set_property(l_tabcolumn_reference,"HEADER","Descrição grupo")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"VARIABLE","des_grupo")

    CALL _ADVPL_set_property(ma_fields_references[3],"SET_ROWS",ma_log_usu_grupos,1)
END FUNCTION

#Limpa variáveis e cria uma linha na grade

#-----------------------------#
FUNCTION tst0001_clear_fields()
#-----------------------------#
    INITIALIZE mr_log_usu_grupos.*,ma_log_usu_grupos TO NULL
    CALL _ADVPL_set_property(ma_fields_references[3],"ITEM_COUNT",1)
END FUNCTION

#habilita/desabilita os componentes, dependendo do parâmetro
#recebido estar TRUE ou FALSE
#--------------------------------------#
FUNCTION tst0001_enable_fields(l_enable)
#--------------------------------------#

    DEFINE l_enable SMALLINT
    DEFINE l_ind    SMALLINT
    
    FOR l_ind = 1 TO 100
        IF  ma_fields_references[l_ind] IS NULL THEN
            EXIT FOR
        END IF

        CALL _ADVPL_set_property(ma_fields_references[l_ind],"EDITABLE",l_enable)
    END FOR
END FUNCTION

#Chamada quando o usuário clica no Incluir. Nesse exemplo, apenas
#invoca as funções de limpeza de variáveis e habilitação dos componentes,
#más poderia executar outras ações que determinariam se o usuário poderia ou
#não incluir registros.

#-----------------------#
FUNCTION tst0001_create()
#-----------------------#
    CALL tst0001_clear_fields()
    CALL tst0001_enable_fields(TRUE)
    RETURN TRUE #retornando TRUE, os botoes Confirmar e Cancelar serão habilitados ao usuário
END FUNCTION

#Valida as informações antes da gravação na base

#-------------------------------#
FUNCTION tst0001_create_confirm()
#-------------------------------#
    
    DEFINE l_count        INTEGER,
           l_ind          INTEGER,
           l_grupo        CHAR(10),
           n_ret          INTEGER,
           c_msg          CHAR(30),
           l_row_selected INTEGER
    
    IF  mr_log_usu_grupos.usuario IS NULL THEN
        CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Usuário não informado.")
        CALL _ADVPL_set_property(ma_fields_references[1],"GET_FOCUS")
        RETURN FALSE
    END IF

    #obtem a quantidade de grupos que foi informados p/ o usuário
    LET l_count = _ADVPL_get_property(ma_fields_references[3],"ITEM_COUNT")

    FOR l_ind = 1 TO l_count
        
        LET l_grupo = ma_log_usu_grupos[l_ind].grupo

        IF l_grupo IS NOT NULL THEN
           INSERT INTO log_usu_grupos(usuario, grupo)
            VALUES(mr_log_usu_grupos.usuario, l_grupo)
    
           IF STATUS <> 0 THEN
              CALL log003_err_sql('INSERT','log_usu_grupos')
              RETURN FALSE
           END IF
        END IF
    END FOR
    
    CALL tst0001_enable_fields(FALSE)

    RETURN TRUE
        
END FUNCTION

#Chamada quando o usuário cancela a edição do botão incluir

#------------------------------#
FUNCTION tst0001_create_cancel()
#------------------------------#
    CALL tst0001_enable_fields(FALSE)
    RETURN TRUE
END FUNCTION

#Função para pesquisa (consulta) de registros

#---------------------#
FUNCTION tst0001_find()
#---------------------#
    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(500)
    DEFINE l_order_by     CHAR(200)

    #http://tdn.totvs.com/display/lg/LConstruct#LConstruct
    
    #Montagem dos filtros pelos quais o usuário podera pesquisar
    
    IF  m_construct_reference IS NULL THEN
        #Se é a primeira pesquisa, cria o componente LCONSTRUCT e define os campos para pesquisa
        LET m_construct_reference = _ADVPL_create_component(NULL,"LCONSTRUCT")
        CALL _ADVPL_set_property(m_construct_reference,"CONSTRUCT_NAME","TST0001_FILTER")
        #Adiciona na pesquisa a tabela que contém os campos da pesquisa
        CALL _ADVPL_set_property(m_construct_reference,"ADD_VIRTUAL_TABLE","usuarios","Usuários")
        #Adiciona na pesquisa o campo usuarios.cod_usuario, com posibilidade de utilização do zoom do usuário
        CALL _ADVPL_set_property(m_construct_reference,"ADD_VIRTUAL_COLUMN","usuarios","cod_usuario","Código do usuário",1 {CHAR},8,0,"zoom_usuarios")
        #Adiciona na pesquisa o campo usuarios.nom_usuario
        CALL _ADVPL_set_property(m_construct_reference,"ADD_VIRTUAL_COLUMN","usuarios","nom_usuario","Nome do usuário",1 {CHAR},30,0)

    END IF

    #abre a tela para que o usuário entre com os parâmetroa de pesquisa
    LET l_status = _ADVPL_get_property(m_construct_reference,"INIT_CONSTRUCT")

    IF  l_status THEN
        #Se o usuário cnfirmou a pesquisa, obtém os filtros informados e a ordem selecionada pelo usuário
        LET l_where_clause = _ADVPL_get_property(m_construct_reference,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct_reference,"ORDER_BY")
        #chama função para montagem da query de pesquisa
        CALL tst0001_create_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
END FUNCTION

#Monta a query de pesquisa, cria o cursor de navegação entre os registros encontrados
#na pesquisa e chama função de leitura dos grupos de cada usuário

#-------------------------------------------------------#
FUNCTION tst0001_create_cursor(l_where_clause,l_order_by)
#-------------------------------------------------------#
    DEFINE l_where_clause CHAR(500)
    DEFINE l_order_by     CHAR(200)

    DEFINE l_sql_stmt CHAR(2000)

    IF  l_order_by IS NULL THEN
        LET l_order_by = "1"
    END IF

    LET l_sql_stmt = 'SELECT DISTINCT usuarios.cod_usuario,',
                           ' usuarios.nom_funcionario',
                      ' FROM usuarios,log_usu_grupos',
                     ' WHERE ',l_where_clause CLIPPED,
                       ' AND log_usu_grupos.usuario = usuarios.cod_usuario',
                     ' ORDER BY ',l_order_by

    PREPARE var_usuarios FROM l_sql_stmt
    IF  sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("PREPARE SQL","var_usuarios")
        RETURN FALSE
    END IF

    DECLARE cq_usuarios SCROLL CURSOR WITH HOLD FOR var_usuarios

    IF  sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cq_usuarios")
        RETURN FALSE
    END IF

    FREE var_usuarios

    OPEN cq_usuarios

    IF  sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("OPEN CURSOR","cq_usuarios")
        RETURN FALSE
    END IF

    FETCH cq_usuarios INTO mr_log_usu_grupos.*

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_usuarios")
        ELSE
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
        END IF

        RETURN FALSE
    END IF

    #invoca rotina para leitura dos grupos
    CALL tst0001_load_grupos(mr_log_usu_grupos.usuario)

    RETURN TRUE
END FUNCTION

#Lê os grupos do usuário corrente, para que eles sejam visualizados na consulta. Para
#exibir uma informação, não é necessário dar display. Basta colocar a informação na
#variável correta.

#-------------------------------------#
FUNCTION tst0001_load_grupos(l_usuario)
#-------------------------------------#
    DEFINE l_usuario LIKE log_usu_grupos.usuario
    DEFINE l_ind SMALLINT
    
    INITIALIZE ma_log_usu_grupos TO NULL
    
    DECLARE cq_log_grupos CURSOR FOR
     SELECT log_grupos.grupo,log_grupos.des_grupo
       FROM log_grupos,log_usu_grupos
      WHERE log_usu_grupos.usuario = l_usuario
        AND log_usu_grupos.grupo   = log_grupos.grupo

    IF  sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE CURSOR","cq_log_grupos")
        RETURN FALSE
    END IF

    LET l_ind = 1

    FOREACH cq_log_grupos INTO ma_log_usu_grupos[l_ind].*
        IF  sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("FORACH CURSOR","cq_log_grupos")
            EXIT FOREACH
        END IF

        LET l_ind = l_ind + 1

        IF  l_ind > 100 THEN
            CALL log0030_mensagem("Pesquisa ultrapassou 100 registros.","excl")
            EXIT FOREACH
        END IF
    END FOREACH

    FREE cq_log_grupos

    CALL _ADVPL_set_property(ma_fields_references[3],"ITEM_COUNT",l_ind - 1)

    RETURN TRUE
END FUNCTION

#Localiza e exibe o primeiro registro encontado na pesquisa
#----------------------#
FUNCTION tst0001_first()
#----------------------#

    FETCH FIRST cq_usuarios INTO mr_log_usu_grupos.*

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_usuarios")
        ELSE
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Não existem mais registros nesta direção.")
        END IF

        RETURN FALSE
    END IF

    CALL tst0001_load_grupos(mr_log_usu_grupos.usuario)

    RETURN TRUE
END FUNCTION

#Avança para o próximo registro encontrado na pesquisa

#---------------------#
FUNCTION tst0001_next()
#---------------------#

    FETCH NEXT cq_usuarios INTO mr_log_usu_grupos.*

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_usuarios")
        ELSE
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Não existem mais registros nesta direção.")
        END IF

        RETURN FALSE
    END IF

    CALL tst0001_load_grupos(mr_log_usu_grupos.usuario)

    RETURN TRUE
END FUNCTION

#Volta para o registro anterior

#-------------------------#
FUNCTION tst0001_previous()
#-------------------------#

    FETCH PREVIOUS cq_usuarios INTO mr_log_usu_grupos.*

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_usuarios")
        ELSE
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Não existem mais registros nesta direção.")
        END IF

        RETURN FALSE
    END IF

    CALL tst0001_load_grupos(mr_log_usu_grupos.usuario)

    RETURN TRUE
END FUNCTION

#Localiza e exibe o último registro encontado na pesquisa

#----------------------#
FUNCTION tst0001_last()
#----------------------#

    FETCH LAST cq_usuarios INTO mr_log_usu_grupos.*

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_usuarios")
        ELSE
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Não existem mais registros nesta direção.")
        END IF

        RETURN FALSE
    END IF

    CALL tst0001_load_grupos(mr_log_usu_grupos.usuario)

    RETURN TRUE
END FUNCTION

#valida a entrada do código do usuário
#------------------------------#
FUNCTION tst0001_usuario_valid()
#------------------------------#
    DEFINE l_status  SMALLINT
    DEFINE l_message CHAR(200)

    INITIALIZE mr_log_usu_grupos.nom_funcionario TO NULL

    SELECT nom_funcionario
      INTO mr_log_usu_grupos.nom_funcionario
      FROM usuarios
     WHERE cod_usuario = mr_log_usu_grupos.usuario

    IF  sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
        CALL log003_err_sql("SELECT","usuarios")
        RETURN FALSE
    END IF

    IF  mr_log_usu_grupos.nom_funcionario IS NULL THEN
        LET l_status  = FALSE
        LET l_message = "Usuário ",mr_log_usu_grupos.usuario CLIPPED," não cadastrado."

        CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT",l_message)
    ELSE
        LET l_status = TRUE
        CALL _ADVPL_set_property(m_statusbar_reference,"CLEAR_TEXT")
    END IF

    RETURN l_status
END FUNCTION

#valida a entrada do código do grupo do usuário

#----------------------------#
FUNCTION tst0001_grupo_valid()
#----------------------------#
    DEFINE l_row_selected SMALLINT

    DEFINE l_status  SMALLINT
    DEFINE l_message CHAR(200)

    LET l_row_selected = _ADVPL_get_property(ma_fields_references[3],"ROW_SELECTED")

    INITIALIZE ma_log_usu_grupos[l_row_selected].des_grupo TO NULL

    SELECT des_grupo
      INTO ma_log_usu_grupos[l_row_selected].des_grupo
      FROM log_grupos
     WHERE grupo = ma_log_usu_grupos[l_row_selected].grupo

    IF  sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
        CALL log003_err_sql("SELECT","log_grupos")
        RETURN FALSE
    END IF

    IF  ma_log_usu_grupos[l_row_selected].des_grupo IS NULL THEN
        LET l_status  = FALSE
        LET l_message = "Grupo ",ma_log_usu_grupos[l_row_selected].grupo CLIPPED," não cadastrado."

        CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT",l_message)
    ELSE
        LET l_status = TRUE
        CALL _ADVPL_set_property(m_statusbar_reference,"CLEAR_TEXT")
    END IF
        
    RETURN l_status
    
END FUNCTION

#Verifica se os campos obrigatórios da linha atual foram preenchisdo
#---------------------------------#
FUNCTION tst0001_grupos_after_row()
#---------------------------------#
    DEFINE l_row_selected SMALLINT

    LET l_row_selected = _ADVPL_get_property(ma_fields_references[3],"ROW_SELECTED")

    IF  l_row_selected > 0 THEN
        IF  ma_log_usu_grupos[l_row_selected].grupo IS NULL THEN
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Grupo não informado.")
            RETURN FALSE
        END IF
    END IF

    RETURN TRUE
END FUNCTION


#Zoom do usuário, a partir da tabela usuarios
#Para ver os zoom's disponíveis, tab frm_zoom
#------------------------------#
FUNCTION tst0001_zoom_usuarios()
#------------------------------#
    DEFINE l_cod_item       LIKE item.cod_item
    DEFINE l_den_item_reduz LIKE item.den_item_reduz

    IF  m_zoom_usuarios_reference IS NULL THEN
        #Se chamado pela 1a. vez, cria o zoom
        LET m_zoom_usuarios_reference = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_usuarios_reference,"ZOOM","zoom_usuarios")
    END IF
    
    #exibe a janela do zoom
    CALL _ADVPL_get_property(m_zoom_usuarios_reference,"ACTIVATE")
    
    #obtém o código e nome do usuário da linha atual da grade de zoom
    LET l_cod_item       = _ADVPL_get_property(m_zoom_usuarios_reference,"RETURN_BY_TABLE_COLUMN","usuarios","cod_usuario")
    LET l_den_item_reduz = _ADVPL_get_property(m_zoom_usuarios_reference,"RETURN_BY_TABLE_COLUMN","usuarios","nom_funcionario")

    IF  l_cod_item IS NOT NULL THEN
        LET mr_log_usu_grupos.usuario         = l_cod_item
        LET mr_log_usu_grupos.nom_funcionario = l_den_item_reduz
    END IF
END FUNCTION

#Zoom do grupo do usuário, a partir da tabela log_grupos
#--------------------------------#
FUNCTION tst0001_zoom_log_grupos()
#--------------------------------#
    DEFINE l_grupo     LIKE log_grupos.grupo
    DEFINE l_des_grupo LIKE log_grupos.des_grupo

    DEFINE l_row_selected SMALLINT

    IF  m_zoom_log_grupos_reference IS NULL THEN
        LET m_zoom_log_grupos_reference = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_log_grupos_reference,"ZOOM","zoom_log_grupos")
    END IF

    CALL _ADVPL_get_property(m_zoom_log_grupos_reference,"ACTIVATE")

    LET l_grupo     = _ADVPL_get_property(m_zoom_log_grupos_reference,"RETURN_BY_TABLE_COLUMN","log_grupos","grupo")
    LET l_des_grupo = _ADVPL_get_property(m_zoom_log_grupos_reference,"RETURN_BY_TABLE_COLUMN","log_grupos","des_grupo")

    IF  l_grupo IS NOT NULL THEN
        LET l_row_selected = _ADVPL_get_property(ma_fields_references[3],"ROW_SELECTED")

        LET ma_log_usu_grupos[l_row_selected].grupo     = l_grupo
        LET ma_log_usu_grupos[l_row_selected].des_grupo = l_des_grupo
    END IF
END FUNCTION

#------------------------#
FUNCTION tst0001_update()#
#------------------------#

   CALL _ADVPL_set_property(ma_fields_references[3],"EDITABLE",TRUE)
   CALL _ADVPL_set_property(ma_fields_references[3],"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION

#Valida as informações antes da gravação na base

#-------------------------------#
FUNCTION tst0001_update_confirm()
#-------------------------------#
    
    DEFINE l_count        INTEGER,
           l_ind          INTEGER,
           l_grupo        CHAR(10),
           n_ret          INTEGER,
           c_msg          CHAR(30),
           l_row_selected INTEGER
    
    DELETE FROM log_usu_grupos
     WHERE usuario = mr_log_usu_grupos.usuario

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','log_usu_grupos')
      RETURN FALSE
   END IF
     
    #obtem a quantidade de grupos que foi informados p/ o usuário
    LET l_count = _ADVPL_get_property(ma_fields_references[3],"ITEM_COUNT")

    FOR l_ind = 1 TO l_count
        
        LET l_grupo = ma_log_usu_grupos[l_ind].grupo

        IF l_grupo IS NOT NULL THEN
           INSERT INTO log_usu_grupos(usuario, grupo)
            VALUES(mr_log_usu_grupos.usuario, l_grupo)
    
           IF STATUS <> 0 THEN
              CALL log003_err_sql('INSERT','log_usu_grupos')
              RETURN FALSE
           END IF
        END IF
    END FOR
    
    CALL tst0001_enable_fields(FALSE)

    RETURN TRUE
        
END FUNCTION

#Chamada quando o usuário cancela a edição do modificar

#------------------------------#
FUNCTION tst0001_update_cancel()
#------------------------------#

   CALL tst0001_load_grupos(mr_log_usu_grupos.usuario)

    CALL tst0001_enable_fields(FALSE)
    RETURN TRUE
END FUNCTION

#------------------------------#
FUNCTION tst0001_delete()
#------------------------------#

    DELETE FROM log_usu_grupos
     WHERE usuario = mr_log_usu_grupos.usuario

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','log_usu_grupos')
      RETURN FALSE
   END IF

    INITIALIZE mr_log_usu_grupos.*,ma_log_usu_grupos TO NULL
    CALL tst0001_enable_fields(FALSE)
    
    RETURN TRUE
    
END FUNCTION

{
Atualmente não temos algo do tipo, você teria que criar seu zoom no metadado mesmo. 
A partir da versão 12.1.13 os programas de criação de metadados foram liberados para 
uso externo, ou seja, você poderá criar o zoom metadado normalmente e depois 
referência-lo no seu LCONSTRUCT.
   