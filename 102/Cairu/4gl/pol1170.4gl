# SISTEMA.: COMERCIAL                                               #
# PROGRAMA: pol1170                                                 #
# MODULOS.: pol1170 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: RELATORIO - EMISSAO DE ETIQUETAS DE FATURAMENTO         #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_num_nff_ant       LIKE nf_mestre.num_nff,
         p_num_nff           LIKE nf_mestre.num_nff,
         p_cod_transpor      LIKE nf_mestre.cod_transpor,
         p_nf_mestre         RECORD LIKE fat_nf_mestre.*,
         p_clientes          RECORD LIKE clientes.*,
         p_transp            RECORD LIKE clientes.*,
         p_status            SMALLINT,
         p_erro              SMALLINT,
         p_count             SMALLINT,
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
         p_ies_cons          SMALLINT,
         p_primeira_vez      SMALLINT,
         p_last_row          SMALLINT,
         p_cont              DECIMAL(2,0),
         p_msg               char(300)


   DEFINE p_comprime, p_descomprime  CHAR(01),
          p_6lpp                     CHAR(02),
          p_8lpp                     CHAR(02)


  DEFINE p_tela         RECORD
                          cod_empresa      LIKE empresa.cod_empresa,
                          num_nff_ini      LIKE nf_mestre.num_nff,
                          num_etiq         DECIMAL (5,0),         
                          etiq_de          DECIMAL (5,0),         
                          etiq_ate         DECIMAL (5,0)          
                        END RECORD

  DEFINE p_relat    RECORD
           nom_cliente       CHAR(30),                      
           end_cli           CHAR(36),                      
           bairro_cli        CHAR(19),                      
           cidade_cli        CHAR(30),                      
           cep_cli           CHAR(09),                      
           uf_cli            CHAR(02),                      
           num_nff           LIKE nf_mestre.num_nff,	
           cod_embal         LIKE ordem_montag_embal.cod_embal_int,
           qtd_embal         LIKE ordem_montag_embal.qtd_embal_int,
           num_pedido        LIKE nf_item.num_pedido,                     
           impress           SMALLINT
                    END RECORD

END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
    SET LOCK MODE TO WAIT 300
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao="POL1170-10.02.01"
  INITIALIZE p_nom_help TO NULL
  CALL log140_procura_caminho("pol1170.iem") RETURNING p_nom_help
  LET p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help   ,
      NEXT KEY control-f,
      PREVIOUS KEY control-b


  CALL log001_acessa_usuario("ESPEC999","")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL pol1170_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol1170_controle()
#--------------------------#
 CALL log006_exibe_teclas("01",p_versao)
 INITIALIZE p_nom_tela TO NULL
 CALL log130_procura_caminho("pol1170") RETURNING p_nom_tela
 LET  p_nom_tela = p_nom_tela CLIPPED
 OPEN WINDOW w_pol1170 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 MENU "OPCAO"

   COMMAND "Listar" "Lista dados na tela e para relatorio. "
      HELP 000
      MESSAGE ""
      LET int_flag = 0
      CALL pol1170_consulta()
   COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1170_sobre() 
      COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 000
      MESSAGE ""
      EXIT MENU
 END MENU
 CLOSE WINDOW w_pol1170
 END FUNCTION

#-----------------------#
FUNCTION pol1170_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------------------#
 FUNCTION pol1170_consulta()
#---------------------------------------#
 DEFINE where_clause, sql_stmt CHAR(500),
        p_cod_item             LIKE mov_est_fis.cod_item

 INITIALIZE p_tela.*   TO NULL
 CALL log006_exibe_teclas("02 07",p_versao)
 CURRENT WINDOW IS w_pol1170
 CLEAR FORM
 LET p_tela.cod_empresa = p_cod_empresa
 LET p_tela.etiq_de     = 1             
 DISPLAY BY NAME p_tela.cod_empresa

 INPUT BY NAME p_tela.* WITHOUT DEFAULTS

    AFTER FIELD num_nff_ini

       IF p_tela.num_nff_ini IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD num_nff_ini
       END IF

        SELECT count(nota_fiscal)
          INTO p_count
          FROM fat_nf_mestre 
         WHERE empresa     = p_cod_empresa 
           AND nota_fiscal = p_tela.num_nff_ini 
       
       if p_count = 0 then
          error 'NF inexistente!'
          NEXT FIELD num_nff_ini
       end if
       
    BEFORE FIELD num_etiq
    
        SELECT SUM(b.qtd_volume)
          INTO p_tela.num_etiq
          FROM fat_nf_mestre a, fat_nf_embalagem b
         WHERE a.empresa     = p_cod_empresa 
           AND b.empresa  = a.empresa
           AND a.nota_fiscal = p_tela.num_nff_ini 
           AND b.trans_nota_fiscal = a.trans_nota_fiscal 
        
        if p_tela.num_etiq is null then
           let p_tela.num_etiq = 0
        end if
        
    LET p_tela.etiq_ate = p_tela.num_etiq
 
    AFTER FIELD num_etiq     
       
       IF p_tela.num_etiq    IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD num_etiq    
       END IF 

    AFTER FIELD etiq_de      
       
       IF p_tela.etiq_de     IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD etiq_de     
       END IF

    AFTER FIELD etiq_ate     
       
       IF p_tela.etiq_ate    IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD etiq_ate    
       END IF
       
END INPUT

IF int_flag <> 0 THEN
   ERROR "Funcao Cancelada"
   INITIALIZE p_tela.* TO NULL
   RETURN
END IF

CURRENT WINDOW IS w_pol1170

IF log0280_saida_relat(13,29) IS NOT NULL THEN
   ERROR "Processando a extracao do relatorio ..."ATTRIBUTE(REVERSE)
   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U"  THEN
         START REPORT pol1170_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1170.tmp'
         START REPORT pol1170_relat TO p_caminho 
      END IF
   ELSE
      START REPORT pol1170_relat TO p_nom_arquivo
   END IF
END IF 

 CURRENT WINDOW IS w_pol1170

LET p_relat.impress = p_tela.etiq_de 

LET p_comprime    = ascii 15
LET p_descomprime = ascii 18
LET p_6lpp        = ascii 27, "2"
LET p_8lpp        = ascii 27, "0"

DECLARE cq_consulta CURSOR FOR
    SELECT *                            
      FROM fat_nf_mestre
     WHERE nota_fiscal = p_tela.num_nff_ini
       AND empresa     = p_cod_empresa
       
FOREACH cq_consulta INTO p_nf_mestre.*                                

  IF status <> 0 THEN
     CALL log003_err_sql('Lendo','fat_nf_mestre')
     EXIT FOREACH
  END IF
  
  LET p_relat.num_nff = p_nf_mestre.nota_fiscal 

  SELECT a.nom_cliente,
         b.den_cidade,
         a.end_cliente,
         a.den_bairro,
         a.cod_cep,
         b.cod_uni_feder 
    INTO p_relat.nom_cliente,p_relat.cidade_cli,p_relat.end_cli,
         p_relat.bairro_cli,p_relat.cep_cli,p_relat.uf_cli 
    FROM clientes a,cidades b 
   WHERE a.cod_cliente = p_nf_mestre.cliente
     AND a.cod_cidade = b.cod_cidade

   LET  p_relat.cod_embal = "CX1"
   LET  p_relat.qtd_embal = p_tela.etiq_ate  

   DECLARE cq_pedido   CURSOR FOR
    SELECT distinct pedido                   
      FROM fat_nf_item    
     WHERE trans_nota_fiscal = p_nf_mestre.trans_nota_fiscal
       AND empresa = p_nf_mestre.empresa
   
   FOREACH cq_pedido INTO p_relat.num_pedido 
      EXIT FOREACH
   END FOREACH 

  OUTPUT TO REPORT pol1170_relat(p_relat.*) 

END FOREACH

FINISH REPORT pol1170_relat  

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
 REPORT pol1170_relat(p_relat)
#----------------------------#
  DEFINE p_relat    RECORD
         nom_cliente       CHAR(30),                      
         end_cli           CHAR(36),                      
         bairro_cli        CHAR(19),                      
         cidade_cli        CHAR(30),                      
         cep_cli           CHAR(09),                      
         uf_cli            CHAR(02),                      
         num_nff           LIKE nf_mestre.num_nff,	
         cod_embal         LIKE ordem_montag_embal.cod_embal_int,
         qtd_embal         LIKE ordem_montag_embal.qtd_embal_int,
         num_pedido        LIKE nf_item.num_pedido,                     
         impress           SMALLINT
       END RECORD

  DEFINE p_total        DECIMAL(14,6),
         p_contador     SMALLINT

 OUTPUT LEFT   MARGIN 0
        TOP    MARGIN 0
        BOTTOM MARGIN 1
        PAGE LENGTH  15
FORMAT

   FIRST PAGE HEADER
	  
	    PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

    BEFORE GROUP OF p_relat.num_nff 
   
    WHILE p_relat.impress <= p_relat.qtd_embal  
       SKIP TO TOP OF PAGE  

       PRINT COLUMN 001,"N"   
##       PRINT COLUMN 001,"S2"  
##       PRINT COLUMN 001,"D5"  
##       PRINT COLUMN 001,"ZT"         
##       PRINT COLUMN 001,"R0,0" 
       PRINT COLUMN 001,"A35,005,0,4,1,2,N,",'"',p_relat.nom_cliente CLIPPED,'"'
       PRINT COLUMN 001,"A35,060,0,4,1,1,N,",'"',p_relat.end_cli CLIPPED,'"'
       PRINT COLUMN 001,"A35,100,0,4,1,1,N,",'"',p_relat.bairro_cli CLIPPED,'"'
       PRINT COLUMN 001,"A35,140,0,4,1,1,N,",'"',p_relat.cidade_cli CLIPPED," ",p_relat.cep_cli CLIPPED," ",p_relat.uf_cli,'"'
       PRINT COLUMN 001,"A35,185,0,4,2,2,N,",'"',"NOTA FISCAL N. ", p_relat.num_nff CLIPPED,'"'
       PRINT COLUMN 001,"A85,240,0,4,2,2,N,",'"',"CONTROLE ", p_relat.num_pedido CLIPPED,'"'
       PRINT COLUMN 001,"A85,295,0,4,2,2,N,",'"',"VOLUME ", p_relat.impress USING "###&"," / ",p_tela.num_etiq,'"'
       PRINT COLUMN 001,"P1"  

       LET  p_relat.impress = p_relat.impress + 1

    END WHILE
    
END REPORT
