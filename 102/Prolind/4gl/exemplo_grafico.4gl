#------------------#
  FUNCTION exemplolchart()
#------------------#
    DEFINE l_form    VARCHAR(50)
    DEFINE l_layout  VARCHAR(50)
    DEFINE l_grafico VARCHAR(50)

    #Cria a tela
    LET l_form = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(l_form,"TITLE","Teste Gráfico")
    CALL _ADVPL_set_property(l_form,"SIZE",800,800)

    #Cria o layout da tela
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_form)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",2)
    CALL _ADVPL_set_property(l_layout,"MARGIN",FALSE)

    #Gráfico de Barras Verticais
    LET l_grafico = _ADVPL_create_component(NULL,"LBARCHART",l_layout)
    CALL _ADVPL_set_property(l_grafico,"SIZE",400,400)
    CALL _ADVPL_set_property(l_grafico,"TITLE","Habitantes no Brasil","CENTER")

    CALL _ADVPL_set_property(l_grafico,"ADD_COLOR_BEGIN","DEGRADE_VERDE",0,0,255)
    CALL _ADVPL_set_property(l_grafico,"ADD_COLOR_END"  ,"DEGRADE_VERDE",255,0,0)

    #Adicionando valores ao gráfico de barra
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","1998",162.20,255,65,58)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","1999",164.55)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","2000",168,0)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","2001",171.1)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","2002",173.62)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","2003",176.23)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","2004",179.29)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","2005",181.87)

    #Mostrando o gráfico
    CALL _ADVPL_set_property(l_grafico,"DISPLAY")

    #Gráfico do tipo pizza
    LET l_grafico = _ADVPL_create_component(NULL,"LPIECHART",l_layout)
    CALL _ADVPL_set_property(l_grafico,"SIZE",400,400)
    CALL _ADVPL_set_property(l_grafico,"TITLE","Habitantes por idade","CENTER")

    CALL _ADVPL_set_property(l_grafico,"ADD_COLOR_BEGIN","DEGRADE_VERDE",128,255,128)
    CALL _ADVPL_set_property(l_grafico,"ADD_COLOR_END"  ,"DEGRADE_VERDE",64,128,128)

    #Adicionando valores ao gráfico do tipo pizza
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","até 12 anos",38.35)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","até 18 anos",34.91)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","entre 18 e 21 anos",55.57)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","entre 21 e 35 anos",43.2)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","entre 35 e 50 anos",24.45)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","entre 50 e 65 anos",20.34)
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","mais de 65 anos",15.97)

    #Mostrando o gráfico
    CALL _ADVPL_set_property(l_grafico,"DISPLAY")

    #Gráfico do tipo linha
    LET l_grafico = _ADVPL_create_component(NULL,"LLINECHART",l_layout)
    CALL _ADVPL_set_property(l_grafico,"SIZE",400,400)
    CALL _ADVPL_set_property(l_grafico,"TITLE","Número de habitantes","CENTER")

    #Adicionando série ao gráfico
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","Brasil")

    #Adicionando pontos a série
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",1,"2002",173.62)
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",1,"2003",176.23)
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",1,"2004",179.29)
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",1,"2005",181.87)

    #Adicionando série ao gráfico
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","México")

    #Adicionando pontos a série
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",2,"2002",56.62)
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",2,"2003",58.23)
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",2,"2004",60.29)
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",2,"2005",61.87)

    #Mostrando o gráfico
    CALL _ADVPL_set_property(l_grafico,"DISPLAY")

    #Gráfico do tipo linha
    LET l_grafico = _ADVPL_create_component(NULL,"LLINECHART",l_layout)
    CALL _ADVPL_set_property(l_grafico,"SIZE",400,400)
    CALL _ADVPL_set_property(l_grafico,"TITLE","Variação do iBovespa","LEFT")
    CALL _ADVPL_set_property(l_grafico,"LEGEND",NULL)

    #Adicionando série ao gráfico
    CALL _ADVPL_set_property(l_grafico,"ADD_SERIE","Indice")

    #Adicionando pontos a série
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",1,"08:00",164.6)
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",1,"09:00",166.2)
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",1,"10:00",163.2)
    CALL _ADVPL_set_property(l_grafico,"ADD_ITEM",1,"11:00",168.8)

    #Mostrando o gráfico
    CALL _ADVPL_set_property(l_grafico,"DISPLAY")

    CALL _ADVPL_set_property(l_form,"ACTIVATE",TRUE)
END FUNCTION