#-----------------------------------------------------------------#
#OBJETIVO.: CRUD d tabela LOG_USU_GRUPOS                          #
#VALIDA��O: O usu�rio dever� constar da tabela USUARIOS e o grupo #
#           dever� constar da tabela LOG_GRUPOS                   #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa LIKE empresa.cod_empresa
    DEFINE p_user        LIKE usuarios.cod_usuario
END GLOBALS

#Vari�veis apra armazenar a referencia da janela principal (DIALOG) 
#e a barra de status, a qual ficar� no rodap� da DIALOG.

DEFINE m_dialog_reference    VARCHAR(10)
DEFINE m_statusbar_reference VARCHAR(10)

#O componente DIALOG � o prioncipal e deve ser o primeiro a ser criado.
#os demais componentes dever�o ser criados dentro do DIALOG, ou sejam,
#ser�o considerados filhos do DIALOG. Um componente filho tamb�m poder�
#ter outros filhos. Por exemplo, podemos criar uma barra de menu dentro
#da DIALOG e dentro da barra de menu criar bot�es.


#A seguir, a refere�ncia dos componentes. Em forma de ARRAY, fica
#mias f�cil habilit�-los ou desabilit�-los, pois
#pemos utilizar um FOR... END FOR, para isso. Da forma que est� definido
#abaixo (ARRAY[100]) podemos utilizar essa ARRY para armazenar as
#refer�ncias de at� 100 componentes.

DEFINE ma_fields_references  ARRAY[100] OF VARCHAR(10)

#records que armazenar� o registro corrente e o
#backup do registro, para permitir sua restaura��o, 
#quando uma edi��o e cancelada.

DEFINE mr_log_usu_grupos,
       mr_log_usu_grupos_old RECORD
                                 usuario         LIKE log_usu_grupos.usuario,
                                 nom_funcionario LIKE usuarios.nom_funcionario
                             END RECORD

#ARRAY que armazenar� os dados da grade

DEFINE ma_log_usu_grupos     ARRAY[100] OF RECORD
                                 grupo           LIKE log_usu_grupos.grupo,
                                 des_grupo       LIKE log_grupos.des_grupo
                             END RECORD

#Vari�veis para armazenar as refer�ncias do zoom
# do usu�io e zoom do grupo de usu�rio

DEFINE m_zoom_usuarios_reference   VARCHAR(10)
DEFINE m_zoom_log_grupos_reference VARCHAR(10)

#Vari�vel para armazenar a refer�ncia da pesquisa (consulta)

DEFINE m_construct_reference VARCHAR(10)

#func��o principal cujo nome deve ser aquele cadastrado como nome
#do programa no MEN0050 (cadastro de menus). No men0050, o tipo de
#processo deve ser 2 (programa sem MAIN...END MAIN)

#----------------#
FUNCTION tst0001()
#----------------#

    #Refer�ncia da barra de menu
    DEFINE l_menubar_reference VARCHAR(10)
    #Refer�ncia do painel
    DEFINE l_panel_reference   VARCHAR(10)

    #Refer�ncias das op��es do programa
    
    DEFINE l_create_reference,
           l_update_reference,
           l_find_reference,
           l_first_reference,
           l_previous_reference,
           l_next_reference,
           l_last_reference,
           l_delete_reference  VARCHAR(10)

    WHENEVER ERROR CONTINUE

    #chamada da log que verifica se o usu�rio tem acesso ao programa.
    #pode ser substituida pela log001_acessa_usuario("ESPEC999","") 
    
    IF  LOG_initApp("PADRAO") <> 0 THEN
        RETURN
    END IF
    
    #Para testar sem abrir o programa pelo menu, 
    #comentar a fun��o acima e descomentar a fun��o abaixo.
    
    #CALL LOG_connectDatabase("DEFAULT")

    INITIALIZE mr_log_usu_grupos.*,ma_log_usu_grupos TO NULL

    #cria��o da janela principal e defini��o de algumas propriedades p/ a mesma
    
    LET m_dialog_reference = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog_reference,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog_reference,"TITLE","Cadastro de grupo por usu�rios")

    #Cria��o da barra de status (filha da DIALOG)
    LET m_statusbar_reference = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog_reference)

    #Criacao do menu (filho da DIALOG)
    LET l_menubar_reference = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog_reference)
    CALL _ADVPL_set_property(l_menubar_reference,"HELP_VISIBLE",FALSE)

    #Cria��o de bot�es: existem bpt�es padr�es que j� possuem uma identidade propria e
    #bot�es customizados. Bot�es customizados podem ser criados com a defini��o para o mesmo.
    #Para saber as imagnes: SELECT DISTINCT resource_name FROM frm_toolbar ORDER BY 1;
    #Cria��o do bot�o Incluir. Observe que o mesmo � filho do LMENUBAR
    LET l_create_reference = _ADVPL_create_component(NULL,"LCREATEBUTTON",l_menubar_reference)
    #Defini��o da FUNCTION que ser� chamada ao clicar no bot�o Incluir. Se essa fun��o retornar
    #TRUE, os bot�es Confirmar e Cancelar ser�o exibidos. Caso contr�rio, n�o.
    CALL _ADVPL_set_property(l_create_reference,"EVENT","tst0001_create")
    #Defini��o da fun��o a ser chamada quando o usu�rio CONFIRMAR a inclus��o
    CALL _ADVPL_set_property(l_create_reference,"CONFIRM_EVENT","tst0001_create_confirm")
    #Defini��o da fun��o a ser chamada quando o usu�rio CANCELAR a inclus��o
    CALL _ADVPL_set_property(l_create_reference,"CANCEL_EVENT","tst0001_create_cancel")

    # A seguir, cria��o/defini��o dos demais bot�es
    
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

    #O bot�o Sair n�o precisa de fun��o que define sua a��o. Automaticamente, fecha a janela.
    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar_reference)

    #Cria��o de um painel, para organizar os campos do cabe�alho e da grade.    
    LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",m_dialog_reference)
    CALL _ADVPL_set_property(l_panel_reference,"ALIGN","CENTER")
    
    #Chama FUNCTION para cria��o dos campos
    CALL tst0001_create_fields(l_panel_reference)

    #Antes de abrir a janela principal, desabilita os campos, para que o usu�rio n�o
    #tenha acesso aos mesmos antes de selecionar a opera��o.
    CALL tst0001_enable_fields(FALSE)

    #Ativa a janela principal, ou seja, faz com que a mesma seja apresentada ao usu�rio    
    CALL _ADVPL_set_property(m_dialog_reference,"ACTIVATE",TRUE)
    
END FUNCTION

#Cria os campos de edi��o dentro do painel passado como par�metro. Antes, por�m,
#ser�o criados dentro desse pinel recebido mais dois paineis: uma para organizar os
#campos do cabe�alho e outro para organizar os campos (colunas) da grade.

#---------------------------------------------------#
FUNCTION tst0001_create_fields(l_container_reference)
#---------------------------------------------------#

    DEFINE l_container_reference VARCHAR(10)
    DEFINE l_panel_reference     VARCHAR(10)
    DEFINE l_layout_reference    VARCHAR(10)
    DEFINE l_label_reference     VARCHAR(10)
    DEFINE l_field_reference     VARCHAR(10)
    DEFINE l_tabcolumn_reference VARCHAR(10)

    #cria��o do painel do 1o. painel no topo e com altura de 60 pixeis
    LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",l_container_reference)
    CALL _ADVPL_set_property(l_panel_reference,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel_reference,"HEIGHT",60)
    #Como os campos do cabe�alho s�o 4 (r�tulo e caixa de edi��o do cod usu�rio, icone do zoom e
    #descri��o do usu�rio), criaremos, dentro do painel, um componente do tipo LLAYOUT, o qual
    #distribuir� os campos em forma de 4 colunas
    LET l_layout_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference)
    CALL _ADVPL_set_property(l_layout_reference,"COLUMNS_COUNT",4)

    #cria��o do label (r�tulo) do campo
    LET l_label_reference = _ADVPL_create_component(NULL,"LLABEL",l_layout_reference)
    CALL _ADVPL_set_property(l_label_reference,"TEXT","Usu�rio:")
    #Por ser um campo obrigat�rio, o texto do mesmo ficar� em negrito (TRUE)
    #                                                 tam  cor negrit italic
    CALL _ADVPL_set_property(l_label_reference,"FONT",NULL,NULL,TRUE,FALSE)
    
    #cria��o/defini��o da caixa de texto, para entrada do c�digo go usu�rio. Observe que a
    #vari�vel que guardar� a refer~encia � a ARRAY ma_fields_references, o que ir� facilitar
    #as a��es e habilitar e desabilitar o campo quando conveniente
    LET ma_fields_references[1] = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout_reference)
    #defini��o da qtd m�xima de digitos que dever�o entrar
    CALL _ADVPL_set_property(ma_fields_references[1],"LENGTH",8)
    #defini��o da vari�vel que ir� receber o conte�do digitado: record mr_log_usu_grupos e
    #sua propriedade ou campo usuario (mr_log_usu_grupos.usuario)
    CALL _ADVPL_set_property(ma_fields_references[1],"VARIABLE",mr_log_usu_grupos,"usuario")
    #defini��o da mascara de entrada: @& = letras min�sculas; @! = letras maiusculas
    CALL _ADVPL_set_property(ma_fields_references[1],"PICTURE","@&")
    #FUNCTION para valida��o da entrada. Se retornar TRUE, a entrada ser� v�lida. Se 
    #retornar FALSE, o usu�rio ter� que re-digitar a informa��o
   #CALL _ADVPL_set_property(ma_fields_references[1],"VALID","tst0001_usuario_valid")

    #cria��o/defini��o do icone do zoom
    LET ma_fields_references[2] = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout_reference)
    CALL _ADVPL_set_property(ma_fields_references[2],"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(ma_fields_references[2],"SIZE",24,20)
    CALL _ADVPL_set_property(ma_fields_references[2],"CLICK_EVENT","tst0001_zoom_usuarios")
    #cria��o/defini��o do campos para exibir o nome do usu�rio
    LET l_field_reference = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout_reference)
    CALL _ADVPL_set_property(l_field_reference,"LENGTH",30) 
    CALL _ADVPL_set_property(l_field_reference,"EDITABLE",FALSE) #n�o permite edi��o do conte�do
    CALL _ADVPL_set_property(l_field_reference,"VARIABLE",mr_log_usu_grupos,"nom_funcionario")

    #cria��o/defini��o do painel para organiza��o dos campos da grade
    LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",l_container_reference)
    CALL _ADVPL_set_property(l_panel_reference,"ALIGN","CENTER")

    #Cria��o do lay-out, para organizar a grade. A grade � considerada uma �nica coluna, para
    #efeito de acomoda��o no lay-out. Se quiser colocar a grade diretamente no painel, pode, 
    #por�m, colocando-a no lay-out � possivel contralar as margens.
    LET l_layout_reference = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_reference)
    CALL _ADVPL_set_property(l_layout_reference,"COLUMNS_COUNT",1) #n�mero de colunas
    CALL _ADVPL_set_property(l_layout_reference,"EXPANSIBLE",TRUE) #faz com que a grade utililize todo o espa��o dispon�vel no lay-out

    #cria��o/defini��o da grade (browse)
    LET ma_fields_references[3] = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout_reference)
    CALL _ADVPL_set_property(ma_fields_references[3],"ALIGN","CENTER")
    #defini��o da FUNCTION que der� chamada antes de criar uma nova linha. O objetivo � validar a
    #linha atual.
    CALL _ADVPL_set_property(ma_fields_references[3],"BEFORE_ADD_ROW_EVENT","tst0001_grupos_after_row")

    #Nossa grade ter� 3 colunas, a saber:
    #1a. c�digo do grupo
    LET l_tabcolumn_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",ma_fields_references[3])
    #defini��o do cabe�alho da coluna. o * (* Grupo) indica que o campo � obrigat�rio
    CALL _ADVPL_set_property(l_tabcolumn_reference,"HEADER","* Grupo")
    #habilita edi��o
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDITABLE",TRUE)
    #largura da coluna em pixeis
    CALL _ADVPL_set_property(l_tabcolumn_reference,"COLUMN_WIDTH",200)
    #defini��o do tipo do campo (campo texto)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_COMPONENT","LTEXTFIELD")
    #n�mero m�ximo de caracteres que poder� entrar no campo
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_PROPERTY","LENGTH",8)
    #mascara de entrada que converter� o conte�di para min�sculo
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_PROPERTY","PICTURE","@&")
    #fun��o que ser� chamada para valida��o da entrada
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDIT_PROPERTY","VALID","tst0001_grupo_valid")
    #propriedade da ARRAY onde ser� armazenado o cunte�do informado pelo usu�rio
    CALL _ADVPL_set_property(l_tabcolumn_reference,"VARIABLE","grupo")
    
    #2a. icone do zoom (lupa)
    LET l_tabcolumn_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",ma_fields_references[3])
    CALL _ADVPL_set_property(l_tabcolumn_reference,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"BEFORE_EDIT_EVENT","tst0001_zoom_log_grupos")
    
    #3a. descri��o do grupo
    LET l_tabcolumn_reference = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",ma_fields_references[3])
    CALL _ADVPL_set_property(l_tabcolumn_reference,"HEADER","Descri��o grupo")
    CALL _ADVPL_set_property(l_tabcolumn_reference,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn_reference,"VARIABLE","des_grupo")

    CALL _ADVPL_set_property(ma_fields_references[3],"SET_ROWS",ma_log_usu_grupos,1)
END FUNCTION

#Limpa vari�veis e cria uma linha na grade

#-----------------------------#
FUNCTION tst0001_clear_fields()
#-----------------------------#
    INITIALIZE mr_log_usu_grupos.*,ma_log_usu_grupos TO NULL
    CALL _ADVPL_set_property(ma_fields_references[3],"ITEM_COUNT",1)
END FUNCTION

#habilita/desabilita os componentes, dependendo do par�metro
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

#Chamada quando o usu�rio clica no Incluir. Nesse exemplo, apenas
#invoca as fun��es de limpeza de vari�veis e habilita��o dos componentes,
#m�s poderia executar outras a��es que determinariam se o usu�rio poderia ou
#n�o incluir registros.

#-----------------------#
FUNCTION tst0001_create()
#-----------------------#
    CALL tst0001_clear_fields()
    CALL tst0001_enable_fields(TRUE)
    RETURN TRUE #retornando TRUE, os botoes Confirmar e Cancelar ser�o habilitados ao usu�rio
END FUNCTION

#Valida as informa��es antes da grava��o na base

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
        CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Usu�rio n�o informado.")
        CALL _ADVPL_set_property(ma_fields_references[1],"GET_FOCUS")
        RETURN FALSE
    END IF

    #obtem a quantidade de grupos que foi informados p/ o usu�rio
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

#Chamada quando o usu�rio cancela a edi��o do bot�o incluir

#------------------------------#
FUNCTION tst0001_create_cancel()
#------------------------------#
    CALL tst0001_enable_fields(FALSE)
    RETURN TRUE
END FUNCTION

#Fun��o para pesquisa (consulta) de registros

#---------------------#
FUNCTION tst0001_find()
#---------------------#
    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(500)
    DEFINE l_order_by     CHAR(200)

    #http://tdn.totvs.com/display/lg/LConstruct#LConstruct
    
    #Montagem dos filtros pelos quais o usu�rio podera pesquisar
    
    IF  m_construct_reference IS NULL THEN
        #Se � a primeira pesquisa, cria o componente LCONSTRUCT e define os campos para pesquisa
        LET m_construct_reference = _ADVPL_create_component(NULL,"LCONSTRUCT")
        CALL _ADVPL_set_property(m_construct_reference,"CONSTRUCT_NAME","TST0001_FILTER")
        #Adiciona na pesquisa a tabela que cont�m os campos da pesquisa
        CALL _ADVPL_set_property(m_construct_reference,"ADD_VIRTUAL_TABLE","usuarios","Usu�rios")
        #Adiciona na pesquisa o campo usuarios.cod_usuario, com posibilidade de utiliza��o do zoom do usu�rio
        CALL _ADVPL_set_property(m_construct_reference,"ADD_VIRTUAL_COLUMN","usuarios","cod_usuario","C�digo do usu�rio",1 {CHAR},8,0,"zoom_usuarios")
        #Adiciona na pesquisa o campo usuarios.nom_usuario
        CALL _ADVPL_set_property(m_construct_reference,"ADD_VIRTUAL_COLUMN","usuarios","nom_usuario","Nome do usu�rio",1 {CHAR},30,0)

    END IF

    #abre a tela para que o usu�rio entre com os par�metroa de pesquisa
    LET l_status = _ADVPL_get_property(m_construct_reference,"INIT_CONSTRUCT")

    IF  l_status THEN
        #Se o usu�rio cnfirmou a pesquisa, obt�m os filtros informados e a ordem selecionada pelo usu�rio
        LET l_where_clause = _ADVPL_get_property(m_construct_reference,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_construct_reference,"ORDER_BY")
        #chama fun��o para montagem da query de pesquisa
        CALL tst0001_create_cursor(l_where_clause,l_order_by)
    ELSE
        CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Pesquisa cancelada.")
    END IF
END FUNCTION

#Monta a query de pesquisa, cria o cursor de navega��o entre os registros encontrados
#na pesquisa e chama fun��o de leitura dos grupos de cada usu�rio

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
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Argumentos de pesquisa n�o encontrados.")
        END IF

        RETURN FALSE
    END IF

    #invoca rotina para leitura dos grupos
    CALL tst0001_load_grupos(mr_log_usu_grupos.usuario)

    RETURN TRUE
END FUNCTION

#L� os grupos do usu�rio corrente, para que eles sejam visualizados na consulta. Para
#exibir uma informa��o, n�o � necess�rio dar display. Basta colocar a informa��o na
#vari�vel correta.

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
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","N�o existem mais registros nesta dire��o.")
        END IF

        RETURN FALSE
    END IF

    CALL tst0001_load_grupos(mr_log_usu_grupos.usuario)

    RETURN TRUE
END FUNCTION

#Avan�a para o pr�ximo registro encontrado na pesquisa

#---------------------#
FUNCTION tst0001_next()
#---------------------#

    FETCH NEXT cq_usuarios INTO mr_log_usu_grupos.*

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_usuarios")
        ELSE
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","N�o existem mais registros nesta dire��o.")
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
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","N�o existem mais registros nesta dire��o.")
        END IF

        RETURN FALSE
    END IF

    CALL tst0001_load_grupos(mr_log_usu_grupos.usuario)

    RETURN TRUE
END FUNCTION

#Localiza e exibe o �ltimo registro encontado na pesquisa

#----------------------#
FUNCTION tst0001_last()
#----------------------#

    FETCH LAST cq_usuarios INTO mr_log_usu_grupos.*

    IF  sqlca.sqlcode <> 0 THEN
        IF  sqlca.sqlcode <> NOTFOUND THEN
            CALL log003_err_sql("FETCH CURSOR","cq_usuarios")
        ELSE
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","N�o existem mais registros nesta dire��o.")
        END IF

        RETURN FALSE
    END IF

    CALL tst0001_load_grupos(mr_log_usu_grupos.usuario)

    RETURN TRUE
END FUNCTION

#valida a entrada do c�digo do usu�rio
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
        LET l_message = "Usu�rio ",mr_log_usu_grupos.usuario CLIPPED," n�o cadastrado."

        CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT",l_message)
    ELSE
        LET l_status = TRUE
        CALL _ADVPL_set_property(m_statusbar_reference,"CLEAR_TEXT")
    END IF

    RETURN l_status
END FUNCTION

#valida a entrada do c�digo do grupo do usu�rio

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
        LET l_message = "Grupo ",ma_log_usu_grupos[l_row_selected].grupo CLIPPED," n�o cadastrado."

        CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT",l_message)
    ELSE
        LET l_status = TRUE
        CALL _ADVPL_set_property(m_statusbar_reference,"CLEAR_TEXT")
    END IF
        
    RETURN l_status
    
END FUNCTION

#Verifica se os campos obrigat�rios da linha atual foram preenchisdo
#---------------------------------#
FUNCTION tst0001_grupos_after_row()
#---------------------------------#
    DEFINE l_row_selected SMALLINT

    LET l_row_selected = _ADVPL_get_property(ma_fields_references[3],"ROW_SELECTED")

    IF  l_row_selected > 0 THEN
        IF  ma_log_usu_grupos[l_row_selected].grupo IS NULL THEN
            CALL _ADVPL_set_property(m_statusbar_reference,"ERROR_TEXT","Grupo n�o informado.")
            RETURN FALSE
        END IF
    END IF

    RETURN TRUE
END FUNCTION


#Zoom do usu�rio, a partir da tabela usuarios
#Para ver os zoom's dispon�veis, tab frm_zoom
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
    
    #obt�m o c�digo e nome do usu�rio da linha atual da grade de zoom
    LET l_cod_item       = _ADVPL_get_property(m_zoom_usuarios_reference,"RETURN_BY_TABLE_COLUMN","usuarios","cod_usuario")
    LET l_den_item_reduz = _ADVPL_get_property(m_zoom_usuarios_reference,"RETURN_BY_TABLE_COLUMN","usuarios","nom_funcionario")

    IF  l_cod_item IS NOT NULL THEN
        LET mr_log_usu_grupos.usuario         = l_cod_item
        LET mr_log_usu_grupos.nom_funcionario = l_den_item_reduz
    END IF
END FUNCTION

#Zoom do grupo do usu�rio, a partir da tabela log_grupos
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

#Valida as informa��es antes da grava��o na base

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
     
    #obtem a quantidade de grupos que foi informados p/ o usu�rio
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

#Chamada quando o usu�rio cancela a edi��o do modificar

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
Atualmente n�o temos algo do tipo, voc� teria que criar seu zoom no metadado mesmo. 
A partir da vers�o 12.1.13 os programas de cria��o de metadados foram liberados para 
uso externo, ou seja, voc� poder� criar o zoom metadado normalmente e depois 
refer�ncia-lo no seu LCONSTRUCT.
   