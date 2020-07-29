DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(03),
           g_ies_ambiente  CHAR(01)           
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10)

DEFINE ma_config_pdf     ARRAY[500] OF RECORD
       linha             CHAR(1000)
END RECORD

DEFINE where_clause      VARCHAR(500), 
       m_diretorio_pdf   VARCHAR(150),
       m_diretorio_img   VARCHAR(150),
       m_ind             INTEGER,
       m_nome_arquivo    VARCHAR(200),
       m_date            VARCHAR(10),
       m_hora            VARCHAR(08),
       m_linha           INTEGER,
       m_coluna          INTEGER

#-----------------#
FUNCTION pol1395()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1395-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1395_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1395_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_carga       VARCHAR(10),
           l_find        VARCHAR(10),
           l_fechar      VARCHAR(10),
           l_titulo      VARCHAR(100)
    
    LET l_titulo = "GERAÇÃO DE TÍTULOS - INTEGRAÇÃO CONCUR - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Proessa a geração do arquivo")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1395_processar")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1395_fechar")

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#------------------------#
FUNCTION pol1395_fechar()#
#------------------------#

   RETURN TRUE

END FUNCTION      

#---------------------------#
FUNCTION pol1395_processar()#
#---------------------------#

   CALL pol1395_inicializa_pdf()
 
   CALL pol1395_layout_pdf()
 
   CALL pol1395_relat_gera_pdf()

   CALL log0030_mensagem("Relatorio extraido com sucesso","info")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#                                                                       
FUNCTION pol1395_inicializa_pdf()#                                                                 
#--------------------------------#                                                                       
                                                                                                                  
   DEFINE l_arquivo_remove   CHAR(150)                                                                            
   DEFINE l_diretorio_config CHAR(150)                                                                            
                                                                                                                  
   DEFINE l_tamanho          SMALLINT,                                                                            
          l_indice           SMALLINT,                                                                            
          l_diretorio        CHAR(100)                                                                            
                                                                                                                  
   LET m_ind = 0                                                                                                  
   INITIALIZE ma_config_pdf, m_diretorio_pdf TO NULL                                                              
                                                                                                                  
   CALL log150_procura_caminho('PDF') RETURNING m_diretorio_pdf                                                   
   CALL log150_procura_caminho('IMG') RETURNING m_diretorio_img                                                   
   
   LET m_date = TODAY                                                                                             
   LET m_date = log0800_replace(m_date,'/','_')                                                                   
                                                                                                                  
   LET m_hora = TIME                                                                                              
   LET m_hora = log0800_replace(m_hora,':','_')                                                                   
                                                                                                                   
   LET l_diretorio_config = m_diretorio_pdf CLIPPED, m_date,'_',m_hora,'_',p_user CLIPPED,'_','config.txt' 
                                                                                                                  
   IF g_ies_ambiente = "W" THEN                                                                                   
      LET l_arquivo_remove = 'del ',l_diretorio_config CLIPPED                                                    
   ELSE                                                                                                           
      LET l_arquivo_remove = 'rm ',l_diretorio_config CLIPPED                                                     
   END IF                                                                                                         
                                                                                                                  
   RUN l_arquivo_remove                                                                                           
                                                                                                                                                                                                                                   
   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha = "concatenar=nao;"   
                                                             
   LET m_nome_arquivo =  m_diretorio_pdf CLIPPED,m_date,'_',m_hora,'_',p_user CLIPPED,'_','.pdf'                  
                                                                                                                  
   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha ="caminho=", m_nome_arquivo CLIPPED                                             
                                                                                                                  
   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha = "temporario=",m_nome_arquivo CLIPPED                                          

   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha = "debug=true"                                                                  

   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha = "weight=842"                                                                  

   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha = "height=595"                                                                  

   LET m_ind = m_ind + 1
   LET ma_config_pdf[m_ind].linha = "easypdf=criarNovaPagina;"

END FUNCTION                                                                                           

#----------------------------#
FUNCTION pol1395_layout_pdf()#
#----------------------------#
   
   DEFINE l_diretorio_img     VARCHAR(150),
          l_texto             VARCHAR(80),
          l_valor             DECIMAL(12,2)
   
   LET m_coluna = 780
   LET m_linha = 595
   LET l_diretorio_img = log150_procura_caminho('IMG') CLIPPED, 'pedido.jpg'

   LET m_ind = m_ind + 1
   LET ma_config_pdf[m_ind].linha = "easypdf=adicionaImagem(",l_diretorio_img CLIPPED," ; ","854"," ; ","580"," ; ","5"," ; ","5"," );"
       
   LET m_ind = m_ind + 1
   LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Courier","; 10);"
   
    let m_linha = 550
 
    LET m_coluna = 385
    LET m_ind = m_ind + 1
    LET l_texto = '100'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 700
    LET m_ind = m_ind + 1
    LET l_texto = 'Ivo H Barbosa'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"
    
    let m_linha = 555
    LET m_coluna = 650
    LET m_ind = m_ind + 1
    LET l_texto = 'A VISTA'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  

    let m_linha = 515
 
    LET m_coluna = 35
    LET m_ind = m_ind + 1
    LET l_texto = '428003 - COPERION LTDA'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 405
    LET m_ind = m_ind + 1
    LET l_texto = 'BASELL POLIOLEFINAS LTDA'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    let m_linha = 505
 
    LET m_coluna = 35
    LET m_ind = m_ind + 1
    LET l_texto = 'Rua Arinos, 1000 - Industrial Anhanguera'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 405
    LET m_ind = m_ind + 1
    LET l_texto = 'AV. JULIO DE PAULA CLARO, 687 Q A - LOT INDL FEITAL'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    let m_linha = 495
 
    LET m_coluna = 35
    LET m_ind = m_ind + 1
    LET l_texto = 'São Paulo - 06.276-032 - SP - Brasil'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 405
    LET m_ind = m_ind + 1
    LET l_texto = 'PINDAMONHANGABA - 12.441-400 - SP - Brasil'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    let m_linha = 485
 
    LET m_coluna = 35
    LET m_ind = m_ind + 1
    LET l_texto = 'Telefone: 011-3874-2740 - Fax:'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 405
    LET m_ind = m_ind + 1
    LET l_texto = 'Telefone: - Fax:'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    let m_linha = 475
 
    LET m_coluna = 35
    LET m_ind = m_ind + 1
    LET l_texto = 'C.N.P.J.: 04.632.172/0001-39 - Insc. Est.: 492.738.219.119'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 405
    LET m_ind = m_ind + 1
    LET l_texto = 'C.N.P.J.: 13.583.323/0001-05 - Insc. Est.: 528.135.207.113'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

   LET m_ind = m_ind + 1
   LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Courier","; 8);"

    let m_linha = 455
 
    LET m_coluna = 31
    LET m_ind = m_ind + 1
    LET l_texto = '000538391-1'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 90
    LET m_ind = m_ind + 1
    LET l_texto = 'PMPREV - Serviço Tecnico de Calibração do Limitador de torque'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 460
    LET m_ind = m_ind + 1
    LET l_texto = 'SV'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 500
    LET m_ind = m_ind + 1
    LET l_texto = '1.00'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 600
    LET m_ind = m_ind + 1
    LET l_valor = 4295.50
    LET l_texto = l_valor USING '#.###.###.##'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 680
    LET m_ind = m_ind + 1
    LET l_texto = '0.00'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 720
    LET m_ind = m_ind + 1
    LET l_texto = '4,295.50'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    LET m_coluna = 785
    LET m_ind = m_ind + 1
    LET l_texto = '03/09/2020'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    let m_linha = 97

    LET m_coluna = 720
    LET m_ind = m_ind + 1
    LET l_texto = '4,295.50'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    let m_linha = 87

    LET m_coluna = 740
    LET m_ind = m_ind + 1
    LET l_texto = '0.00'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

    let m_linha = 77

    LET m_coluna = 740
    LET m_ind = m_ind + 1
    LET l_texto = '0.00'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

   LET m_ind = m_ind + 1
   LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Courier","; 13);"

    let m_linha = 62

    LET m_coluna = 690
    LET m_ind = m_ind + 1
    LET l_texto = '4,295.50'
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"

END FUNCTION

#--------------------------------#
FUNCTION pol1395_relat_gera_pdf()
#--------------------------------#

   DEFINE l_ind     SMALLINT 
   DEFINE l_tst SMALLINT
   define l_comando char(200)

   DEFINE l_diretorio_config CHAR(100),
          l_diretorio_pdf    CHAR(100),
          l_caminho_pdf      CHAR(100),
          l_caminho_imp      CHAR(200)

   DEFINE l_mensagem         CHAR(100),
          l_arquivo          CHAR(30)


   LET l_diretorio_config = m_diretorio_pdf CLIPPED,m_date,'_',m_hora,'_',p_user CLIPPED,'_','config.txt' 
   CALL log4070_channel_open_file("configuracao",l_diretorio_config,"w")
   CALL log4070_channel_set_delimiter("configuracao","")

   FOR l_ind = 1 TO m_ind
      CALL log4070_channel_write("configuracao",ma_config_pdf[l_ind].linha)
   END FOR

   CALL log4070_channel_close("configuracao")
   LET l_comando = "java -Dfile.encoding=ISO-8859-1 easyPDF ",l_diretorio_config
   
   call conout(l_comando)

   RUN l_comando CLIPPED
   CALL _advpl_LOG_file_previewInClient(m_nome_arquivo,FALSE,NULL)

END FUNCTION   

{sites
- https://tdn.totvs.com/pages/releaseview.action?pageId=416847728
