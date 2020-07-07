# SISTEMA.: COMERCIAL                                               #
# PROGRAMA: pol0178                                                 #
# MODULOS.: pol0178 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: RELATORIO - EMISSAO DE ETIQUETAS INCA - PRODUTOS        #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_cod_item          LIKE item.cod_item,      
         p_status            SMALLINT,
         p_erro              SMALLINT,
         comando             CHAR(80),
         p_nom_arquivo       CHAR(100),
         p_caminho           CHAR(080),
         p_nom_tela          CHAR(200),
         p_nom_help          CHAR(200),
         p_ies_impressao     CHAR(01),
         g_ies_ambiente      CHAR(01),
         p_versao            CHAR(18),
         p_ind               SMALLINT,
         i                   SMALLINT,
         pa_curr, sc_curr    SMALLINT,
         p_ano_lote          CHAR(04),
         m_lote              CHAR(06),
         m_qtd_peca          CHAR(05),
         p_ies_cons          SMALLINT,
         p_primeira_vez      SMALLINT,
         p_last_row          SMALLINT,
         p_cont              DECIMAL(2,0),
         p_msg               CHAR(300)

   DEFINE p_comprime, p_descomprime  CHAR(01),
          p_6lpp                     CHAR(02),
          p_8lpp                     CHAR(02)


  DEFINE p_tela         RECORD
                          cod_empresa      LIKE empresa.cod_empresa,
                          cod_item         LIKE item.cod_item, 
                          den_item         LIKE item.den_item, 
                          qtd_pecas        DECIMAL (5,0),         
                          qtd_etiq         DECIMAL (5,0)          
                        END RECORD

  DEFINE p_relat    RECORD
           den_item1         CHAR(36),                      
           den_item2         CHAR(36),                                 
           qtd_pecas         DECIMAL(5,0),
           dia_lote          CHAR(02),         
           mes_lote          CHAR(02),         
           ano_lote          CHAR(02),         
           cod_item_barra    CHAR(15),                                 
           qtd_etiqueta      CHAR(05),
           des_esp_item      CHAR(36),
           prz_validade      CHAR(36),
           composicao        CHAR(36)
END RECORD

END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "pol0178-10.02.12"
  INITIALIZE p_nom_help TO NULL
  CALL log140_procura_caminho("pol0178.iem") RETURNING p_nom_help
  LET p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0178_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0178_controle()
#--------------------------#
 CALL log006_exibe_teclas("01",p_versao)
 INITIALIZE p_nom_tela TO NULL
 CALL log130_procura_caminho("pol0178") RETURNING p_nom_tela
 LET  p_nom_tela = p_nom_tela CLIPPED
 OPEN WINDOW w_pol0178 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 MENU "OPCAO"

      COMMAND "Listar" "Lista dados na tela e para relatorio. "
      HELP 000
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0178","CO")  THEN
          CALL pol0178_consulta()
      END IF
      COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0178_sobre() 

      COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 000
      MESSAGE ""
      EXIT MENU
 END MENU
 CLOSE WINDOW w_pol0178
 END FUNCTION

#-----------------------#
FUNCTION pol0178_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------------------#
 FUNCTION pol0178_consulta()
#---------------------------------------#
 DEFINE where_clause, sql_stmt CHAR(500),
        p_cod_item             LIKE mov_est_fis.cod_item

 INITIALIZE p_tela.*   TO NULL
 CALL log006_exibe_teclas("02 07",p_versao)
 CURRENT WINDOW IS w_pol0178
 CLEAR FORM
 LET p_tela.cod_empresa = p_cod_empresa
 DISPLAY BY NAME p_tela.cod_empresa
 INPUT BY NAME p_tela.* WITHOUT DEFAULTS

    AFTER FIELD cod_item    
       IF p_tela.cod_item IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD cod_item    
       END IF

     SELECT den_item_reduz,cod_item_barra_dig
       INTO  p_relat.den_item1,p_relat.cod_item_barra               
       FROM item a,item_barra b    
      WHERE a.cod_item = p_tela.cod_item  
        AND a.cod_empresa = p_cod_empresa
        AND a.cod_empresa = b.cod_empresa 
        AND a.cod_item = b.cod_item 

     IF sqlca.sqlcode <> 0 THEN 
        ERROR "ITEM INEXISTENTE" 
        LET p_tela.den_item = '' 
         NEXT FIELD cod_item    
     ELSE 
        LET p_tela.den_item = p_relat.den_item1
        DISPLAY BY NAME p_tela.*
     END IF 

    CALL pol0178_le_espcif()
    
    IF NOT pol0178_le_validade() THEN
       NEXT FIELD cod_item    
    END IF

    AFTER FIELD qtd_pecas
       IF p_tela.qtd_pecas  IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio" 
         NEXT FIELD qtd_pecas   
       END IF 

    LET p_tela.qtd_etiq = p_tela.qtd_pecas

    AFTER FIELD qtd_etiq     
       IF p_tela.qtd_etiq    IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD qtd_etiq    
       END IF 

END INPUT

IF int_flag <> 0 THEN
   ERROR "Funcao Cancelada"
   INITIALIZE p_tela.* TO NULL
   RETURN
END IF

CURRENT WINDOW IS w_pol0178

IF log028_saida_relat(17,35) IS NOT NULL THEN
   ERROR "Processando a extracao do relatorio ..."ATTRIBUTE(REVERSE)
   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U"  THEN
         START REPORT pol0178_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol0178.tmp'
         START REPORT pol0178_relat TO p_caminho 
      END IF
   ELSE
      START REPORT pol0178_relat TO p_nom_arquivo
   END IF
END IF 

 CURRENT WINDOW IS w_pol0178

LET p_comprime    = ascii 15
LET p_descomprime = ascii 18
LET p_6lpp        = ascii 27, "2"
LET p_8lpp        = ascii 27, "0"

  LET p_relat.dia_lote = DAY(TODAY)                    
  LET p_relat.mes_lote = month(TODAY)                    
  LET p_ano_lote = year(TODAY)
  LET p_relat.ano_lote = p_ano_lote[3,4]
  LET p_relat.qtd_pecas= p_tela.qtd_pecas         
  LET p_relat.qtd_etiqueta = p_tela.qtd_etiq          
  LET m_lote = p_relat.ano_lote, p_relat.mes_lote, p_relat.dia_lote
  LET m_qtd_peca = p_relat.qtd_pecas

  OUTPUT TO REPORT pol0178_relat(p_relat.*) 
FINISH REPORT pol0178_relat  



 IF  p_ies_impressao = "S" THEN
     MESSAGE "Relatorio impresso na impressora ", p_nom_arquivo
              ATTRIBUTE(REVERSE)
     IF g_ies_ambiente = "W" THEN
        LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
        RUN comando
     END IF
 ELSE
     MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo, " " ATTRIBUTE(REVERSE)
 END IF

LET comando = 'lpdos.bat ' ,p_caminho CLIPPED, ' ', p_nom_arquivo CLIPPED
RUN comando
END FUNCTION


#----------------------------#
 REPORT pol0178_relat(p_relat)
#----------------------------#
  DEFINE p_relat    RECORD
           den_item1         CHAR(36),                      
           den_item2         CHAR(36),                      
           qtd_pecas         DECIMAL(5,0),
           dia_lote          CHAR(02),         
           mes_lote          CHAR(02),         
           ano_lote          CHAR(02),         
           cod_item_barra    CHAR(15),
           qtd_etiqueta      CHAR(05),
           des_esp_item      CHAR(36),
           prz_validade      CHAR(36),
           composicao        CHAR(36)
  END RECORD

  DEFINE p_total        DECIMAL(14,6),
         p_contador     SMALLINT,
         p_count        SMALLINT,
         p_prz_validade CHAR(36)

 OUTPUT LEFT   MARGIN 0
        TOP    MARGIN 0
        BOTTOM MARGIN 1
        PAGE LENGTH  20
FORMAT

    BEFORE GROUP OF p_relat.den_item1   
       
       LET p_prz_validade = p_relat.prz_validade
       
       SKIP TO TOP OF PAGE  

       PRINT COLUMN 001,"N"     
       PRINT COLUMN 001,"N"     
       PRINT COLUMN 001,"D8"    
       PRINT COLUMN 001,"S2"    
       PRINT COLUMN 001,"R30,10"
       PRINT COLUMN 001,"ZT"    
       PRINT COLUMN 001,"A25,0,0,4,1,1,N,",        p_relat.den_item1 CLIPPED
       PRINT COLUMN 001,"A25,24,0,2,1,1,N,",       p_relat.den_item2 CLIPPED
       PRINT COLUMN 001,"A26,44,0,1,1,1,N,",       p_relat.composicao CLIPPED
       PRINT COLUMN 001,"A26,63,0,1,1,1,N,",       p_prz_validade
       PRINT COLUMN 001,"A375,80,1,1,2,1,N,",      "Lote ", m_lote
       PRINT COLUMN 001,"A0,80,0,2,5,4,N,",        m_qtd_peca
       PRINT COLUMN 001,"A20,85,0,2,1,1,N,",       " Qtd "
       PRINT COLUMN 001,"A230,90,0,2,1,1,N,",      " pc"
       PRINT COLUMN 001,"B10,138,0,E30,3,3,80,B,", p_relat.cod_item_barra CLIPPED
       PRINT COLUMN 001,"A420,0,0,4,1,1,N,",       p_relat.den_item1 CLIPPED     
       PRINT COLUMN 001,"A420,24,0,2,1,1,N,",      p_relat.den_item2 CLIPPED     
       PRINT COLUMN 001,"A421,44,0,1,1,1,N,",      p_relat.composicao CLIPPED    
       PRINT COLUMN 001,"A421,63,0,1,1,1,N,",      p_prz_validade                
       PRINT COLUMN 001,"A775,80,1,1,2,1,N,",      "Lote ", m_lote               
       PRINT COLUMN 001,"A405,80,0,2,5,4,N,",      m_qtd_peca                    
       PRINT COLUMN 001,"A420,90,0,2,1,1,N,",      " Qtd "                       
       PRINT COLUMN 001,"A638,90,0,2,1,1,N,",      " pc"                         
       PRINT COLUMN 001,"B430,138,0,E30,3,3,80,B,",p_relat.cod_item_barra CLIPPED
       PRINT COLUMN 001,"P1"

   ON LAST ROW

       LET p_last_row = TRUE
        
END REPORT

#---------------------------#
FUNCTION pol0178_le_espcif()
#---------------------------#
   
   DEFINE l_texto      CHAR(800),
          l_ind        INTEGER,
          l_carac      CHAR(01),
          l_desc       CHAR(36),
          l_qtd        CHAR(15),
          l_chave      CHAR(08),
          l_comp       CHAR(100)
 
    SELECT des_espf_item 
     INTO l_texto
     FROM man_espf_it_cad 
    WHERE empresa = p_cod_empresa 
      AND item = p_tela.cod_item 
      AND seq_especificacao = 99

   IF STATUS <> 0 OR l_texto IS NULL THEN
      LET p_relat.des_esp_item = "                         "
      LET p_tela.qtd_pecas = 0
      RETURN
   END IF
   
   #LET l_texto = '<desc>13 X 16 - ABR RSF</desc><quant>00100</quant><comp>Aço SAE 1020</comp>'
   
   LET l_texto = UPSHIFT(l_texto CLIPPED)
   LET l_texto = l_texto[7,LENGTH(l_texto)]
   
   LET l_desc = ''
   LET l_qtd = ''
   
   FOR l_ind = 1 TO LENGTH(l_texto)
       LET l_carac = l_texto[l_ind]
       IF l_carac = '<' THEN
          IF l_ind > 1 THEN
             LET l_desc = l_texto[1,l_ind-1]
          END IF
          LET l_ind = l_ind + 14
          EXIT FOR
       END IF
   END FOR
  
   FOR l_ind = l_ind TO LENGTH(l_texto)
       LET l_carac = l_texto[l_ind]
       IF l_carac = '<' THEN
          LET l_ind = l_ind + 14
          EXIT FOR
       ELSE
          LET l_qtd = l_qtd CLIPPED, l_carac  
       END IF
   END FOR

   FOR l_ind = l_ind TO LENGTH(l_texto)
       LET l_carac = l_texto[l_ind]
       IF l_carac = '<' THEN
          EXIT FOR
       ELSE
          LET l_comp = l_comp CLIPPED, l_carac  
       END IF
   END FOR

   LET p_relat.des_esp_item = l_desc
   LET p_tela.qtd_pecas = l_qtd
   LET p_relat.den_item2 = l_desc
   LET p_relat.Composicao = l_comp

END FUNCTION

   
#------------------------------#
FUNCTION pol0178_le_validade()
#------------------------------#
   
   SELECT parametro_texto
     INTO p_relat.prz_validade
     FROM min_par_modulo 
    WHERE empresa = p_cod_empresa
      AND parametro = 'PRAZO_DE_VALIDADE'
   
   IF STATUS = 100 THEN
      LET p_relat.prz_validade = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','min_par_modulo')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
    
END FUNCTION
