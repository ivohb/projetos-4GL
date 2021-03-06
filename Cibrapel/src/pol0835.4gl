#-----------------------------------------------#
# OBJETIVO: RELATORIO NOTAS FISCAIS DE ENTRADA  #
# FUN��ES: FUNC002                              #
#-----------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          p_status             SMALLINT,
          p_count              SMALLINT,
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_normal             CHAR(02),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_expande            CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),
          p_tot_cli            DECIMAL(15,2),
          p_8lpp               CHAR(02),
          p_tot_ger            DECIMAL(15,2)
          
   DEFINE p_tela        RECORD
      dat_ini           DATE,
      qtd_vias          INTEGER,
      em_transito       CHAR(01)
   END RECORD 

   DEFINE p_fornecedor     RECORD
      cod_fornecedor    LIKE fornecedor.cod_fornecedor,
      nom_fornecedor    LIKE fornecedor.raz_social
   END RECORD

   DEFINE p_w_receb         RECORD 
           num_nf            DECIMAL(9,0),
           dat_emissao       DATE,
           nom_fornecedor    CHAR(50),
           val_nf            DECIMAL(15,2),
           ies_origem        CHAR(01)
   END RECORD

   DEFINE p_relat         RECORD 
          dat_entrada_nf     LIKE nf_sup.dat_entrada_nf,
          num_nf             LIKE nf_sup.num_nf,
          dat_emis_nf        LIKE nf_sup.dat_emis_nf,
          cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          nom_fornecedor     LIKE fornecedor.raz_social,
          val_tot_nf_c       LIKE nf_sup.val_tot_nf_c,
          num_via            INTEGER 
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "POL0835-10.02.07  "
   CALL func002_versao_prg(p_versao)
   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("SUPRIMEN","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol0835_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0835_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0835") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0835 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar Par�metros p/ Listagem"
         HELP 001 
         MESSAGE ""
         LET p_ies_cons = FALSE
         IF pol0835_informar() THEN
            LET p_ies_cons = TRUE
            NEXT OPTION "Listar"
         ELSE
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            ERROR "Opera��o Cancelada !!!"
         END IF
         
      COMMAND "Listar" "Lista Notas Fiscais de Entrada"
         MESSAGE ""
         IF log0280_saida_relat(18,35) IS NOT NULL THEN
            IF p_ies_impressao = "S" THEN
               CALL log150_procura_caminho ('LST') RETURNING p_caminho
               LET p_caminho = p_caminho CLIPPED, 'pol0835.tmp'
               START REPORT pol0835_relat  TO p_caminho
            ELSE
               START REPORT pol0835_relat TO p_nom_arquivo
            END IF
            MESSAGE " Processando a Extracao do Relatorio..." 
            CALL pol0835_emite_relatorio()   
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL func002_exibe_versao(p_versao)
         
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
         
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
  
   CLOSE WINDOW w_pol0835

END FUNCTION

#--------------------------#
FUNCTION pol0835_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   LET p_tela.em_transito = 'N'

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_ini    
      IF p_tela.dat_ini IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_ini 
      END IF 

      BEFORE FIELD qtd_vias
        LET p_tela.qtd_vias = 1    

      AFTER FIELD qtd_vias    
      IF p_tela.qtd_vias < 0 THEN
         ERROR "Qtde deve ser maior que 0"
         NEXT FIELD qtd_vias
      ELSE
         CALL pol0835_cria_temp()         
      END IF 

      AFTER INPUT
        
        IF NOT INT_FLAG THEN
         IF p_tela.em_transito MATCHES '[SN]' THEN
         ELSE
            ERROR 'Campo com preenchimento obrigat�rio.'
            NEXT FIELD em_transito
         END IF
        END IF
        
         
      
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol0835_cria_temp()
#----------------------------#

WHENEVER ERROR CONTINUE
DROP TABLE w_receb

 CREATE  TEMP   TABLE w_receb
 (num_nf            DECIMAL(9,0),
  dat_emissao       DATE,
  nom_fornecedor    CHAR(50),
  val_nf            DECIMAL(15,2),
  ies_origem        CHAR(01)
 );
WHENEVER ERROR STOP

 DELETE FROM w_receb

END FUNCTION

#---------------------------------#
 FUNCTION pol0835_emite_relatorio()
#---------------------------------#
  DEFINE l_qtd_rel           INTEGER,
         p_ies_nf_aguard_nfe CHAR(01)

   SELECT den_empresa 
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_negrito     = ascii 27, "E"
   LET p_normal      = ascii 27, "F"
   LET p_expande     = ascii 14
   LET p_8lpp        = ascii 27, "0"

   
   DECLARE cq_nf_sup CURSOR FOR
    SELECT nf_sup.num_nf,
           nf_sup.dat_emis_nf,
           nf_sup.cod_fornecedor,
           nf_sup.val_tot_nf_c,
           ies_nf_aguard_nfe
      FROM nf_sup
     WHERE nf_sup.cod_empresa = p_cod_empresa
       AND nf_sup.dat_entrada_nf = p_tela.dat_ini 
     ORDER BY nf_sup.cod_fornecedor
     
   FOREACH cq_nf_sup INTO
           p_relat.num_nf,
           p_relat.dat_emis_nf,
           p_relat.cod_fornecedor,
           p_relat.val_tot_nf_c,
           p_ies_nf_aguard_nfe

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_nf_sup')
         EXIT FOREACH
      END IF
      
      IF p_ies_nf_aguard_nfe = '7' AND p_tela.em_transito = 'N' THEN
         CONTINUE FOREACH
      END IF
   
      SELECT raz_social
        INTO p_relat.nom_fornecedor
        FROM fornecedor
       WHERE cod_fornecedor  = p_relat.cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fornecedor')
         EXIT FOREACH
      END IF

      INSERT INTO w_receb VALUES (p_relat.num_nf,
                                  p_relat.dat_emis_nf,
                                  p_relat.nom_fornecedor,
                                  p_relat.val_tot_nf_c,
                                  'A')

   END FOREACH

   DECLARE cq_fr_sup CURSOR FOR
    SELECT frete_sup.num_conhec,
           frete_sup.dat_emis_conhec,
           frete_sup.cod_transpor,
           frete_sup.val_frete
      FROM frete_sup
     WHERE frete_sup.cod_empresa = p_cod_empresa
       AND frete_sup.dat_entrada_conhec = p_tela.dat_ini 
     ORDER BY frete_sup.cod_transpor
     
   FOREACH cq_fr_sup INTO
           p_relat.num_nf,
           p_relat.dat_emis_nf,
           p_relat.cod_fornecedor,
           p_relat.val_tot_nf_c

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_fr_sup')
         EXIT FOREACH
      END IF
   
      SELECT raz_social
        INTO p_relat.nom_fornecedor
        FROM fornecedor
       WHERE cod_fornecedor  = p_relat.cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fornecedor')
         EXIT FOREACH
      END IF

      INSERT INTO w_receb VALUES (p_relat.num_nf,
                                  p_relat.dat_emis_nf,
                                  p_relat.nom_fornecedor,
                                  p_relat.val_tot_nf_c,
                                  'F')
     
   END FOREACH

   LET l_qtd_rel = 1 
   
   WHILE l_qtd_rel <= p_tela.qtd_vias 
   
      DECLARE cq_rel CURSOR FOR
        SELECT * 
          FROM w_receb
         ORDER BY ies_origem,
                  dat_emissao   
      FOREACH cq_rel INTO p_w_receb.*
         LET p_relat.num_nf         = p_w_receb.num_nf
         LET p_relat.dat_emis_nf    = p_w_receb.dat_emissao
         LET p_relat.nom_fornecedor = p_w_receb.nom_fornecedor
         LET p_relat.val_tot_nf_c   = p_w_receb.val_nf 
         LET p_relat.num_via        = l_qtd_rel
      
         OUTPUT TO REPORT pol0835_relat(p_relat.*)
         
         LET p_count = p_count + 1
          
      END FOREACH
      
      LET l_qtd_rel = l_qtd_rel + 1
   END WHILE 

   IF p_count > 0 THEN
      MESSAGE "Relatorio Processado com Sucesso" ATTRIBUTE(REVERSE)
   ELSE
      MESSAGE "N�o existem dados para os par�metros informados" ATTRIBUTE(REVERSE)
   END IF
   
   FINISH REPORT pol0835_relat   

   IF p_ies_impressao = "S" THEN
      ERROR "Relatorio Impresso na Impressora ", p_nom_arquivo
      LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
      RUN comando
   ELSE
      ERROR "Relatorio Gravado no Arquivo ",p_nom_arquivo
   END IF
   
END FUNCTION 

#-----------------------------#
REPORT pol0835_relat(p_relat)
#-----------------------------#

   DEFINE p_relat         RECORD 
          dat_entrada_nf     LIKE nf_sup.dat_entrada_nf,
          num_nf             LIKE nf_sup.num_nf,
          dat_emis_nf        LIKE nf_sup.dat_emis_nf,
          cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          nom_fornecedor     LIKE fornecedor.raz_social,
          val_tot_nf_c       LIKE nf_sup.val_tot_nf_c,
          num_via            INTEGER 
   END RECORD

 OUTPUT LEFT   MARGIN   1 
        TOP    MARGIN   0
        BOTTOM MARGIN   0
        PAGE   LENGTH   60
   
      ORDER EXTERNAL BY p_relat.dat_entrada_nf
          
   FORMAT

      PAGE HEADER
   
         PRINT COLUMN 001, p_8lpp
         PRINT COLUMN 001,  p_den_empresa,"    IT-00-SUP-200   -  EMISSAO : ", TODAY USING "DD/MM/YYYY"
         PRINT COLUMN 001, "pol0835",
               COLUMN 010, "RELACAO DE ENTRADA DE NOTAS FISCAIS - FORNECEDORES",
               COLUMN 062, "Via: ", p_relat.num_via USING "&&",
               COLUMN 070, "PAG: ", PAGENO USING "&&&"
         PRINT
         PRINT COLUMN 001, "RECEBIMENTO: ", p_tela.dat_ini, "  VISTO  ", "____________"
               
         PRINT COLUMN 001, '__________________________________________________________________________________'
         PRINT
         PRINT COLUMN 0001,'NUM NF    DT EMISSAO  RAZ SOCIAL                                         VALOR NF'
         PRINT COLUMN 0001,'__________________________________________________________________________________'

      BEFORE GROUP OF p_relat.num_via
      
         SKIP TO TOP OF PAGE
         
      ON EVERY ROW

      PRINT  COLUMN 001, p_relat.num_nf USING '#########',
             COLUMN 011, p_relat.dat_emis_nf,
             COLUMN 023, p_relat.nom_fornecedor[1,40],
             COLUMN 065, p_relat.val_tot_nf_c USING '####,###,##&.&&'

      AFTER GROUP OF p_relat.num_via
         PRINT COLUMN 051, 'TOTAL : ',
               COLUMN 062, GROUP SUM(p_relat.val_tot_nf_c) USING '####,###,##&.&&'
         PRINT COLUMN 001,'_______________________________________________________________________________'
         PRINT         
         PRINT COLUMN 001, 'ALMOXARIFADO                                         DEP. FINANCEIRO'
         PRINT
         PRINT COLUMN 001, '___/___/______  ____:____                            ___/___/______  ____:____'
         PRINT
         PRINT
         PRINT COLUMN 001, '_________________________                            _________________________' 
         PRINT
         PRINT
         PRINT COLUMN 001, 'CONTABILIDADE'
         PRINT
         PRINT COLUMN 001, '___/___/______  ____:____'
         PRINT
         PRINT
         PRINT COLUMN 001, '_________________________' 
END REPORT