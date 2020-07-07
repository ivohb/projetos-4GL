#-----------------------------------------------------------------#
# SISTEMA.: Levorin                                               #
# PROGRAMA: pol0616                                               #
# OBJETIVO: Libera ordens de producao                             #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
    DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
           p_user                 LIKE usuario.nom_usuario,
           p_status               SMALLINT,
           p_count                SMALLINT,
           p_ies_cons             SMALLINT,
           l_entrou               SMALLINT,
           l_ind                  INTEGER,
           p_msg                  CHAR(500)
           
    DEFINE p_ies_impressao        CHAR(001),
           g_ies_ambiente         CHAR(001),
           p_nom_arquivo          CHAR(100),
           p_nom_arquivo_back     CHAR(100),
           comando                CHAR(80),
           p_efetiva              CHAR(001),
           p_houve_erro           SMALLINT

    DEFINE g_ies_grafico          SMALLINT,
           g_usa_visualizador     SMALLINT 

    DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
    
    DEFINE p_ordem_montag_mest    RECORD LIKE ordem_montag_mest.*,
           p_lib_om_levorin       RECORD LIKE lib_om_levorin.*,
           p_msn                  CHAR(30),
           p_ind_t1               INTEGER,
           p_ind_t2               INTEGER, 
           p_grava                CHAR(1)

END GLOBALS

#MODULARES
    DEFINE m_den_empresa          LIKE empresa.den_empresa
    DEFINE m_consulta_ativa       SMALLINT,
           m_informa_zoom         SMALLINT,
           m_count                SMALLINT,
           pa_curr                SMALLINT,
           sc_curr                SMALLINT,
           pa_curr2               SMALLINT,
           sc_curr2               SMALLINT,
           p_cod_item_pe          LIKE item.cod_item

    DEFINE sql_stmt               CHAR(500),
           m_last_row             SMALLINT,
           where_clause           CHAR(400)

    DEFINE m_comando              CHAR(080)

    DEFINE m_caminho              CHAR(150)

    DEFINE m_camh_help            CHAR(150),
           m_informou             SMALLINT 

  DEFINE p_wrelat        RECORD
         num_om            DECIMAL(6,0),      
         dat_ocor          DATE, 
         hor_ocor          CHAR(08),  
         cod_cliente       CHAR(15),                 
         val_om            DECIMAL(15,2),            
         ies_limite        CHAR(01),                 
         ies_duplic        CHAR(01),                 
         ies_data          CHAR(01),                 
         ies_liber         CHAR(01)                  
  END RECORD

  DEFINE lr_dados        RECORD
         num_om            DECIMAL(6,0),             
         dat_om            DATE,
         dat_ocor          DATE, 
         hor_ocor          CHAR(08),
         cod_cliente       CHAR(15),
         nom_cliente       CHAR(40),                 
         val_om            DECIMAL(15,2),            
         ies_liber         CHAR(01),
         ies_limite        CHAR(01),                 
         ies_duplic        CHAR(01),                 
         ies_data          CHAR(01),                 
         des_cond          CHAR(09)                  
  END RECORD

  DEFINE mr_tela              RECORD
         cod_empresa          CHAR(02),
         dat_inicio           DATE,
         dat_fim              DATE,
         cod_tip_carteira     LIKE pedidos.cod_tip_carteira,
         cod_cli_om           CHAR(15),
         nom_cli_om           CHAR(35),
         ies_liberadas        CHAR(01)
   END RECORD

  DEFINE ma_tela1            ARRAY[5000] OF RECORD
         ies_acao                 CHAR(01),
         num_om                   LIKE ordem_montag_mest.num_om,
         dat_emissao              LIKE ordem_montag_mest.dat_emis,
         cod_cliente              LIKE pedidos.cod_cliente,
         nom_cliente              CHAR(19),
         val_om                   DECIMAL(13,2),
         ies_limite               CHAR(01),
         ies_duplic               CHAR(01),
         ies_data                 CHAR(01)   
  END RECORD

MAIN
	  LET p_versao = "pol0616-10.02.00"

    WHENEVER ANY ERROR CONTINUE

    CALL log1400_isolation()
    SET LOCK MODE TO WAIT 120

    WHENEVER ANY ERROR STOP

    DEFER INTERRUPT

    LET m_camh_help = log140_procura_caminho('pol0616.iem')

    OPTIONS

        PREVIOUS KEY control-b,
        NEXT     KEY control-f,
        HELP     FILE m_camh_help

    CALL log001_acessa_usuario("ESPEC999","")
         RETURNING p_status, p_cod_empresa, p_user

    IF  p_status = 0 THEN
        CALL pol0616_controle()
    END IF
END MAIN

#---------------------------#
FUNCTION pol0616_controle()
#---------------------------#
    CALL log006_exibe_teclas('01', p_versao)
    
    LET g_usa_visualizador = TRUE 
    
    SELECT den_empresa
      INTO m_den_empresa
      FROM empresa
     WHERE cod_empresa = p_cod_empresa
     
    LET m_caminho = log1300_procura_caminho('pol0616','pol0616')
    OPEN WINDOW w_pol0616 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Informa" "Informa dados"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","pol0616","IN") THEN
         CALL pol0616_informar()
         CALL pol0616_cria_temp()
         CALL pol0616_monta_dados()
         NEXT OPTION "Imprimir" 
      END IF

    COMMAND "Imprimir" "Imprime dados"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      CALL pol0616_imprime()
      NEXT OPTION "Fim"      
     
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
      CALL pol0616_sobre()
         
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET INT_FLAG = 0
         
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  
  CLOSE WINDOW w_pol0616
END FUNCTION

#----------------------------#
 FUNCTION pol0616_informar()
#----------------------------#
DEFINE l_count    INTEGER

  INITIALIZE mr_tela.*,
             ma_tela1 TO NULL

  CALL log006_exibe_teclas("01 03 02 07",p_versao)
  CURRENT WINDOW IS w_pol0616
  CLEAR FORM

   INPUT mr_tela.dat_inicio,      
         mr_tela.dat_fim,         
         mr_tela.cod_tip_carteira,
         mr_tela.cod_cli_om,      
         mr_tela.ies_liberadas
         WITHOUT DEFAULTS
    FROM dat_inicio,      
         dat_fim,         
         cod_tip_carteira,
         cod_cli_om,      
         ies_liberadas   


    BEFORE FIELD dat_inicio 
       LET mr_tela.cod_empresa = p_cod_empresa
       DISPLAY mr_tela.cod_empresa TO  cod_empresa

    AFTER FIELD dat_fim
      IF mr_tela.dat_fim IS NOT NULL THEN
         IF mr_tela.dat_inicio IS NULL THEN
            ERROR 'Informe data inicio'
            NEXT FIELD dat_inicio
         ELSE
            IF mr_tela.dat_inicio >  mr_tela.dat_fim THEN
               ERROR 'Periodo invalido, data final deve ser maior ou igual inicial'
               NEXT FIELD dat_inicio
            END IF 
         END IF 
      END IF 

   AFTER FIELD cod_cli_om
      IF mr_tela.cod_cli_om IS NOT NULL THEN
         SELECT nom_cliente
           INTO mr_tela.nom_cli_om 
           FROM clientes
          WHERE cod_cliente =  mr_tela.cod_cli_om
         IF sqlca.sqlcode <> 0 THEN 
            ERROR 'CLIENTE INIXISTENTE'
            NEXT FIELD cod_cli_om
         END IF 
      END IF    
            
    AFTER FIELD cod_tip_carteira 
      IF mr_tela.cod_tip_carteira  IS NOT NULL THEN
         SELECT * 
           FROM tipo_carteira
          WHERE cod_tip_carteira  = mr_tela.cod_tip_carteira 
         IF sqlca.sqlcode <> 0 THEN 
            ERROR "Carteira Nao Cadastrada   "
         END IF 
      END IF

   ON KEY (control-z)
        CALL pol0616_popup()

  END INPUT

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_pol0616

  IF INT_FLAG THEN
     ERROR "Inclusao Cancelada. "
     LET INT_FLAG = FALSE
  END IF

END FUNCTION

#---------------------------#
FUNCTION pol0616_cria_temp()
#---------------------------#
   WHENEVER ERROR CONTINUE
   BEGIN WORK

   LOCK TABLE wrelat  IN EXCLUSIVE MODE

   COMMIT WORK 

    DROP TABLE wrelat;

   IF sqlca.sqlcode <> 0 THEN 
      DELETE FROM wrelat;
   END IF

   CREATE TEMP TABLE wrelat
     (	
        num_om                 DECIMAL(6,0),           
	dat_ocor               DATE, 
	hor_ocor               CHAR(08),
	cod_cliente            CHAR(15),           
	val_om                 DECIMAL(15,2),           
	ies_limite             CHAR(01),
	ies_duplic             CHAR(01),           
	ies_data               CHAR(01),
	ies_liber              CHAR(01)
     ) WITH NO LOG;
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-WRELAT")
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0616_monta_dados()
#-----------------------------#

  DEFINE l_cod_item           LIKE ped_itens.cod_item,
         l_qtd_pecas_solic    LIKE ped_itens.qtd_pecas_solic,
         l_count              INTEGER,
         l_num_pedido         LIKE ped_itens.num_pedido,
         l_cod_tip_carteira   LIKE pedidos.cod_tip_carteira,
         l_cli_credito        RECORD LIKE cli_credito.*,
         l_par_vdp            RECORD LIKE par_vdp.*,
         l_credcad_cli        RECORD LIKE credcad_cli.*,
         l_cod_cliente        LIKE clientes.cod_cliente,
         l_cod_pais           LIKE cli_dist_geog.cod_pais,
         l_cod_cnd_pgto       LIKE pedidos.cod_cnd_pgto,
         l_ind                INTEGER,
         l_entrou             SMALLINT,
         l_datetime           CHAR(19), 
         sql_stmt             CHAR(200)

 LET sql_stmt = NULL

 LET sql_stmt = "SELECT * from lib_om_levorin "


 LET sql_stmt = sql_stmt CLIPPED,
     " WHERE 1 = 1 "

 IF mr_tela.dat_inicio IS NOT NULL THEN 
    LET sql_stmt = sql_stmt CLIPPED,
          " AND DATE(dat_ocor) >= """, mr_tela.dat_inicio, """ ",
          " AND DATE(dat_ocor) <= """, mr_tela.dat_fim, """ "
 END IF

 IF mr_tela.cod_cli_om IS NOT NULL THEN 
    LET sql_stmt = sql_stmt CLIPPED,
          " AND cod_cliente = """, mr_tela.cod_cli_om, """ "
 END IF

 IF mr_tela.cod_tip_carteira IS NOT NULL THEN 
    LET sql_stmt = sql_stmt CLIPPED,
          " AND cod_tip_carteira = """, mr_tela.cod_tip_carteira, """ "
 END IF

 LET sql_stmt = sql_stmt CLIPPED,
          " order by num_om "
 
  LET l_ind = 1 

 PREPARE var_query FROM sql_stmt
 DECLARE cv_item CURSOR FOR var_query

 FOREACH cv_item INTO p_lib_om_levorin.*

    IF mr_tela.ies_liberadas = 'S' THEN 
       IF p_lib_om_levorin.ies_liber <> 'S' THEN 
          CONTINUE FOREACH
       END IF 
    END IF 
    
    LET ma_tela1[l_ind].ies_acao      =  p_lib_om_levorin.ies_liber 
    LET ma_tela1[l_ind].num_om        =  p_lib_om_levorin.num_om
    LET ma_tela1[l_ind].dat_emissao   =  p_lib_om_levorin.dat_ocor
    LET ma_tela1[l_ind].cod_cliente   =  p_lib_om_levorin.cod_cliente
    
    SELECT nom_cliente[1,18]
      INTO ma_tela1[l_ind].nom_cliente
      FROM clientes
     WHERE cod_cliente =  p_lib_om_levorin.cod_cliente

    LET ma_tela1[l_ind].val_om = p_lib_om_levorin.val_om
    LET l_datetime             =  p_lib_om_levorin.dat_ocor  
    
    LET ma_tela1[l_ind].ies_limite = p_lib_om_levorin.ies_bl_limit
    LET ma_tela1[l_ind].ies_duplic = p_lib_om_levorin.ies_bl_dupl
    LET ma_tela1[l_ind].ies_data   = p_lib_om_levorin.ies_bl_dat

    LET p_wrelat.ies_liber     =  p_lib_om_levorin.ies_liber      
    LET p_wrelat.num_om        =  p_lib_om_levorin.num_om
    LET p_wrelat.dat_ocor      =  p_lib_om_levorin.dat_ocor
    LET p_wrelat.hor_ocor      =  l_datetime[12,19]
    LET p_wrelat.cod_cliente   =  p_lib_om_levorin.cod_cliente
    LET p_wrelat.val_om        =  p_lib_om_levorin.val_om
    LET p_wrelat.ies_limite    =  p_lib_om_levorin.ies_bl_limit
    LET p_wrelat.ies_duplic    =  p_lib_om_levorin.ies_bl_dupl
    LET p_wrelat.ies_data      =  p_lib_om_levorin.ies_bl_dat

    INSERT INTO wrelat VALUES (p_wrelat.*)

    LET l_ind = l_ind + 1 
        
 END FOREACH     
        
 CALL SET_COUNT(l_ind - 1)   
 DISPLAY ARRAY ma_tela1 TO s_processo.*              
 
 END FUNCTION

#-----------------------#
 FUNCTION pol0616_popup()
#-----------------------#

  CASE
    WHEN infield(cod_cli_om)
         LET  mr_tela.cod_cli_om = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0616   
         DISPLAY BY NAME mr_tela.cod_cli_om
  END CASE
END FUNCTION

#-----------------------------#
 FUNCTION pol0616_imprime()
#-----------------------------#
  DEFINE l_ind                INTEGER
        
    LET m_last_row = FALSE 
    
    LET p_nom_arquivo = p_nom_arquivo CLIPPED
    
    IF log028_saida_relat(17,40) IS NOT NULL THEN
       IF p_ies_impressao = "S" THEN
          IF g_ies_ambiente = "W"  THEN
             CALL log150_procura_caminho('LST')
             RETURNING m_caminho
             LET m_caminho = m_caminho CLIPPED, 'pol0616.tmp'
             START REPORT pol0616_relat TO m_caminho
          ELSE
             START REPORT pol0616_relat TO PIPE p_nom_arquivo
          END IF
       ELSE
          START REPORT pol0616_relat TO p_nom_arquivo
       END IF                      
    END IF 
    
    INITIALIZE lr_dados.* TO NULL
 
    LET l_ind = 0        
    DECLARE cq_relat CURSOR FOR 
       SELECT *
         FROM wrelat  
        ORDER BY num_om,dat_ocor,hor_ocor
        
    FOREACH cq_relat INTO p_wrelat.*
       
        LET lr_dados.num_om      = p_wrelat.num_om     
        LET lr_dados.dat_ocor    = p_wrelat.dat_ocor
        LET lr_dados.hor_ocor    = p_wrelat.hor_ocor
        LET lr_dados.cod_cliente = p_wrelat.cod_cliente
        LET lr_dados.val_om      = p_wrelat.val_om     
        LET lr_dados.ies_limite  = p_wrelat.ies_limite 
        LET lr_dados.ies_duplic  = p_wrelat.ies_duplic 
        LET lr_dados.ies_data    = p_wrelat.ies_data   
        LET lr_dados.ies_liber   = p_wrelat.ies_liber
        
        LET l_ind = l_ind + 1        
        
 	SELECT nom_cliente 
	  INTO lr_dados.nom_cliente
	  FROM clientes 
	 WHERE cod_cliente =  p_wrelat.cod_cliente

       SELECT * 
         FROM lib_om_levorin
        WHERE cod_empresa = p_cod_empresa
          AND num_om      = p_wrelat.num_om  	 
          AND ies_liber   = 'S'
       IF sqlca.sqlcode = 0 THEN 
          LET  lr_dados.des_cond = 'LIBERADA'
       ELSE                                  
          LET  lr_dados.des_cond = 'BLOQUEADA'
       END IF    
       
       SELECT dat_emis
         INTO lr_dados.dat_om 
         FROM ordem_montag_mest 
        WHERE cod_empresa = p_cod_empresa
          AND num_om      = p_wrelat.num_om  	 
       
       OUTPUT TO REPORT pol0616_relat(lr_dados.*)
     
    END FOREACH 
    
    FINISH REPORT pol0616_relat
    
    IF l_ind > 0 THEN
        LET l_entrou = TRUE
    ELSE
        LET l_entrou = FALSE
    END IF
    
    IF l_entrou = FALSE THEN 
       CALL log0030_mensagem("Não existe dados para gerar o relatório.","info")
       RETURN 
    END IF 
    
    IF g_ies_ambiente = "W"  AND p_ies_impressao = "S" THEN
       LET m_comando = "LPDOS.BAT ",m_caminho CLIPPED,' ',p_nom_arquivo CLIPPED
       RUN m_comando
    END IF
    
    IF p_ies_impressao = "S" THEN
       CALL log0030_mensagem("Relatório gravado com sucesso.","info")
    ELSE
       MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo, 
          " " ATTRIBUTE(REVERSE)
          
       #LET l_mensagem = "Relatório gravado no arquivo.", p_nom_arquivo
       #CALL log0030_mensagem(l_mensagem,"info")
    END IF
    
    IF p_ies_impressao = 'V' THEN
       CALL log028_visualiza_arquivo(p_nom_arquivo)
    END IF

END FUNCTION

#-----------------------------#
 REPORT pol0616_relat(lr_dados)
#-----------------------------#
    
  DEFINE lr_dados        RECORD
         num_om            DECIMAL(6,0),             
         dat_om            DATE,
         dat_ocor          DATE, 
         hor_ocor          CHAR(08),
         cod_cliente       CHAR(15),
         nom_cliente       CHAR(40),                 
         val_om            DECIMAL(15,2),            
         ies_liber         CHAR(01),
         ies_limite        CHAR(01),                 
         ies_duplic        CHAR(01),                 
         ies_data          CHAR(01),                 
         des_cond          CHAR(09)                  
  END RECORD
  
    OUTPUT LEFT   MARGIN 0 
           TOP    MARGIN 0 
           BOTTOM MARGIN 1 
           PAGE   LENGTH 66
    
    ORDER EXTERNAL BY lr_dados.num_om,
                      lr_dados.dat_ocor,
                      lr_dados.hor_ocor 
    FORMAT
       PAGE HEADER 
          PRINT log500_determina_cpp(132) CLIPPED;
          PRINT log500_condensado(true)
          PRINT m_den_empresa
          PRINT COLUMN 001, "POL0616",
                COLUMN 049, "LOGS DE LIBERACAO DE OMS ",
                COLUMN 120, "FL. ", PAGENO USING "###&"
          PRINT COLUMN 089, "EXTRAIDO EM ", today," AS ", time, " HRS."
          PRINT COLUMN 001,'____________________________________________________________________________________________________________________________________'
          PRINT COLUMN 001,' Num.Om  Data om   Cliente                                                          Valor  Bloqueios  Situacao  Data Ocor.'
          PRINT COLUMN 001,'                                                                                          DPL LIM VAL'   

{                             999999 99/99/9999 xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 99.999.999,99  S   S   S  XXXXXXXXX 99/99/9999
                             2      9          19              35                                                 86            101  105 109 112      122           }                             

       BEFORE GROUP OF lr_dados.num_om
       
          SKIP 1 LINE 
       
       ON EVERY ROW
          
          PRINT COLUMN 002, lr_dados.num_om USING "######",
                COLUMN 010, lr_dados.dat_om, 
                COLUMN 021, lr_dados.cod_cliente,
                COLUMN 037, lr_dados.nom_cliente, 
                COLUMN 078, lr_dados.val_om USING "##,###,###.##", 
                COLUMN 093, lr_dados.ies_duplic, 
                COLUMN 097, lr_dados.ies_limite,
                COLUMN 101, lr_dados.ies_data,
                COLUMN 103, lr_dados.des_cond,
                COLUMN 114, lr_dados.dat_ocor,
                COLUMN 125, lr_dados.hor_ocor
        
       ON LAST ROW                             
         LET m_last_row = TRUE                 
                                               
       PAGE TRAILER                            
         IF m_last_row = TRUE THEN             
            PRINT "* * * ULTIMA FOLHA * * *"   
         ELSE                                  
            PRINT " "                          
         END IF                                
      
END REPORT 

#-----------------------#
 FUNCTION pol0616_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION