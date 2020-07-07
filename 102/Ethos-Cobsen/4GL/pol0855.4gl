DATABASE logix

GLOBALS

  DEFINE 
         p_cod_empresa          CHAR(02),
         p_cancel               INTEGER,
         p_cod_item             LIKE item.cod_item,
         p_den_item             LIKE item.den_item,
         p_cod_item_pai         LIKE item.cod_item,
         p_cod_lin_prod         LIKE item.cod_lin_prod,
         p_cod_lin_recei        LIKE item.cod_lin_recei, 
         p_cod_seg_merc         LIKE item.cod_seg_merc,
         p_qtd_liberada         LIKE estoque.qtd_liberada,
         p_qtd_reservada        LIKE estoque.qtd_reservada,
         p_ies_comum            CHAR(01),
         p_ies_processou        SMALLINT,
         comando                CHAR(80),
         p_ies_possui           CHAR(01),
         p_count                SMALLINT,
         p_resposta             CHAR(1),
         p_versao               CHAR(18),               
         p_cod_local_estoq      LIKE item.cod_local_estoq,
         p_ies_impressao        CHAR(01),
         g_ies_ambiente         CHAR(01),
         p_nom_arquivo          CHAR(100),
         p_caminho              CHAR(080),
         p_negrito              CHAR(02),
         p_normal               CHAR(02),
         p_comprime             CHAR(01),
         p_descomprime          CHAR(01),
         p_expande              CHAR(01),
         p_8lpp                 CHAR(02),
         p_msg                  CHAR(500)
         

 DEFINE p_user            LIKE usuario.nom_usuario,
        p_status          SMALLINT,
        p_ies_situa       SMALLINT,
        p_nom_help        CHAR(200),
        p_nom_tela        CHAR(080),
        p_wfat            RECORD LIKE fat_nf_mestre.*    
        
DEFINE p_relat         RECORD 
       num_via            INTEGER, 
       cod_item           LIKE item.cod_item,
       den_item           LIKE item.den_item,
       qtd_liberada       LIKE estoque.qtd_liberada,
       qtd_reservada      LIKE estoque.qtd_reservada,
       ies_comum          CHAR(01)
END RECORD
        
END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT 
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0855-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0855.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

    CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL pol0855_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0855_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0855") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol08550 AT 7,13 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Processar" "Processa baixa de estoque"
      HELP 001
      MESSAGE ""
      LET p_ies_situa  = 0
      LET int_flag = 0
      IF log0280_saida_relat(18,35) IS NOT NULL THEN
         IF p_ies_impressao = "S" THEN
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0855.tmp'
            START REPORT pol0855_relat  TO p_caminho
         ELSE
            START REPORT pol0855_relat TO p_nom_arquivo
         END IF
      
         IF pol0855_processa() THEN
            ERROR "Processamento Efetuado com Sucesso"
            NEXT OPTION "Fim"
         ELSE
            ERROR "Processamento Cancelado"
         END IF    
      END IF
    
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0855_sobre()
     
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim" "Sai do programa"
      IF p_ies_processou = FALSE THEN
         ERROR "Funcao deve ser processada"
         NEXT OPTION "Processar"
      ELSE
         EXIT MENU
      END IF
  END MENU
  CLOSE WINDOW w_pol08550
END FUNCTION

#-----------------------------#
 FUNCTION pol0855_processa()
#-----------------------------#
MESSAGE "Gerando base para relatorio"

CALL pol0855_cria_temp()

LET p_ies_processou = TRUE
DECLARE cq_itc CURSOR FOR 
   SELECT cod_item  
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND ies_tip_item = 'C'     
FOREACH cq_itc INTO p_cod_item
  
   DISPLAY " Item : "  AT  7,5
   DISPLAY p_cod_item AT 7,12
   LET p_ies_possui = 'N'

   DECLARE cq_ite CURSOR FOR
     SELECT DISTINCT cod_item_pai
       FROM estrutura
      WHERE cod_empresa = p_cod_empresa 
        AND cod_item_compon = p_cod_item 
   FOREACH cq_ite INTO p_cod_item_pai
      SELECT cod_lin_prod, cod_lin_recei, cod_seg_merc
        INTO p_cod_lin_prod, p_cod_lin_recei, p_cod_seg_merc
        FROM item  
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item_pai
      IF p_cod_lin_prod = 20 AND 
         p_cod_lin_recei = 3  AND 
         p_cod_seg_merc = 0 THEN
         LET p_ies_possui = 'S'
      END IF        
      IF p_cod_lin_prod = 20 AND 
         p_cod_lin_recei = 3  AND 
         p_cod_seg_merc = 4 THEN
         LET p_ies_possui = 'S'
      END IF        
      IF p_cod_lin_prod = 2  AND 
         p_cod_lin_recei = 4  THEN
         LET p_ies_possui = 'S'
      END IF        
   END FOREACH
   IF p_ies_possui = 'N' THEN 
      LET p_count = 0 
      SELECT COUNT(*) 
        INTO p_count 
        FROM estrutura 
       WHERE cod_empresa = p_cod_empresa 
         AND cod_item_compon = p_cod_item
      IF p_count > 0 THEN     
         INSERT INTO w_pol0855 VALUES (p_cod_item,'N')
      END IF    
   ELSE
      LET p_count = 0 
      SELECT COUNT(*) 
        INTO p_count 
        FROM estrutura 
       WHERE cod_empresa = '06'
         AND cod_item_compon = p_cod_item
      IF p_count > 0 THEN     
         INSERT INTO w_pol0855 VALUES (p_cod_item,'S')
      END IF    
      LET p_ies_possui = 'N'
   END IF     
END FOREACH        

CALL pol0855_emite_relat()
   
RETURN TRUE  

END FUNCTION  

#----------------------------#
 FUNCTION pol0855_cria_temp()
#----------------------------#

WHENEVER ERROR CONTINUE
DROP TABLE w_pol0855;

 CREATE  TEMP   TABLE w_pol0855
 (cod_item         CHAR(15),
  ies_comum        CHAR(01));
 WHENEVER ERROR STOP

 DELETE FROM w_pol0855

END FUNCTION

#-----------------------------#
 FUNCTION pol0855_emite_relat()
#-----------------------------#
MESSAGE "Processando extracao de relatorio"

LET p_comprime    = ascii 15
LET p_descomprime = ascii 18
LET p_negrito     = ascii 27, "E"
LET p_normal      = ascii 27, "F"
LET p_expande     = ascii 14
LET p_8lpp        = ascii 27, "0"

DECLARE cq_relat CURSOR FOR
  SELECT * 
    FROM w_pol0855
   ORDER BY cod_item
FOREACH cq_relat INTO p_cod_item,p_ies_comum 

  SELECT den_item 
    INTO p_den_item 
    FROM item 
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = p_cod_item 
     
  SELECT qtd_liberada,qtd_reservada
    INTO p_qtd_liberada, p_qtd_reservada
    FROM estoque 
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = p_cod_item 
  IF SQLCA.sqlcode <> 0 THEN
     LET p_qtd_liberada = 0    
     LET p_qtd_reservada = 0
  END IF    

  LET p_relat.num_via   = 1
  LET p_relat.cod_item  = p_cod_item
  LET p_relat.den_item  = p_den_item
  LET p_relat.qtd_liberada  = p_qtd_liberada
  LET p_relat.qtd_reservada  = p_qtd_reservada
  IF p_ies_comum = 'S' THEN
     LET p_relat.ies_comum  = '*'
  ELSE
     LET p_relat.ies_comum  = ' '
  END IF   

  OUTPUT TO REPORT pol0855_relat(p_relat.*)


END FOREACH 

MESSAGE "Relatorio Processado com Sucesso" ATTRIBUTE(REVERSE)

END FUNCTION

#-----------------------------#
REPORT pol0855_relat(p_relat)
#-----------------------------#

DEFINE p_relat         RECORD 
       num_via            INTEGER,
       cod_item           LIKE item.cod_item,
       den_item           LIKE item.den_item,
       qtd_liberada       LIKE estoque.qtd_liberada,
       qtd_reservada      LIKE estoque.qtd_reservada,
       ies_comum          CHAR(01)
END RECORD

 OUTPUT LEFT   MARGIN   1 
        TOP    MARGIN   0
        BOTTOM MARGIN   0
        PAGE   LENGTH   60
   
      ORDER EXTERNAL BY p_relat.num_via,p_relat.cod_item
          
   FORMAT

      PAGE HEADER
   
         PRINT COLUMN 001, p_8lpp
         PRINT COLUMN 001,  p_cod_empresa,"                            EMISSAO : ", TODAY USING "DD/MM/YYYY"
         PRINT COLUMN 001, "POL0855",
               COLUMN 010, "ITENS COMPRADOS NAO PERTENCENTES A EST. LINHA DE PRODUTO 20..",
               COLUMN 063, "PAG: ", PAGENO USING "&&&"
         PRINT
               
         PRINT COLUMN 001, '______________________________________________________________________________________________________'
         PRINT
         PRINT COLUMN 001,'ITEM              DESCRICAO                                             QTD LIBERADA   QTD RESERVADA  A'
         PRINT COLUMN 001,'_______________________________________________________________________________________________________'

      BEFORE GROUP OF p_relat.num_via
      
         SKIP TO TOP OF PAGE
         
      ON EVERY ROW

      PRINT  COLUMN 001, p_relat.cod_item,
             COLUMN 018, p_relat.den_item[1,50],
             COLUMN 070, p_relat.qtd_liberada USING '####,##&.&&&&&',
             COLUMN 086, p_relat.qtd_reservada USING '####,##&.&&&&&',
             COLUMN 103, p_relat.ies_comum

      AFTER GROUP OF p_relat.num_via
         PRINT COLUMN 051, 'TOTAL : ',
               COLUMN 062, GROUP COUNT(*) USING '######'


END REPORT

#-----------------------#
 FUNCTION pol0855_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION