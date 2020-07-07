#-----------------------------------------------#
# OBJETIVO: RELATORIO NOTAS FISCAIS DE APARAS   #
# FUNÇÕES: FUNC002                              #
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
          p_comprime           CHAR(01),
          p_diferenca          DECIMAL(12,3),
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
      dat_fim           DATE
   END RECORD 

   DEFINE p_fornecedor     RECORD
      cod_fornecedor    LIKE fornecedor.cod_fornecedor,
      nom_fornecedor    LIKE fornecedor.raz_social
   END RECORD

   DEFINE p_w_receb         RECORD 
           num_nf            DECIMAL(6,0),
           dat_emis_nf       DATE,
           dat_entrada_nf    DATE,
           nom_fornecedor    CHAR(50),
           cod_item          CHAR(15),
           qtd_item          DECIMAL(12,3),
           qtd_contag        DECIMAL(12,3)
   END RECORD

   DEFINE p_relat         RECORD 
          dat_emis_nf        LIKE nf_sup.dat_entrada_nf, 
          dat_entrada_nf     LIKE nf_sup.dat_entrada_nf,
          num_nf             LIKE nf_sup.num_nf,
          nom_fornecedor     LIKE fornecedor.raz_social,
          cod_item           LIKE aviso_rec.cod_item,
          qtd_item           LIKE aviso_rec.qtd_declarad_nf,
          qtd_contag         LIKE aviso_rec.qtd_declarad_nf,
          qtd_diferenca      LIKE aviso_rec.qtd_declarad_nf
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "POL1040-10.02.01"
   CALL func002_versao_prg(p_versao)

   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("SUPRIMEN","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol1040_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1040_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1040") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1040 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Listagem"
         HELP 001 
         MESSAGE ""
         LET p_ies_cons = FALSE
         IF pol1040_informar() THEN
            LET p_ies_cons = TRUE
            NEXT OPTION "Listar"
         ELSE
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            ERROR "Operação Cancelada !!!"
         END IF
         
      COMMAND "Listar" "Lista Notas Fiscais de Entrada"
         MESSAGE ""
         IF log0280_saida_relat(18,35) IS NOT NULL THEN
            IF p_ies_impressao = "S" THEN
               CALL log150_procura_caminho ('LST') RETURNING p_caminho
               LET p_caminho = p_caminho CLIPPED, 'pol1040.tmp'
               START REPORT pol1040_relat  TO p_caminho
            ELSE
               START REPORT pol1040_relat TO p_nom_arquivo
            END IF
            MESSAGE " Processando a Extracao do Relatorio..." 
            CALL pol1040_emite_relatorio()   
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
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
  
   CLOSE WINDOW w_pol1040

END FUNCTION

#--------------------------#
FUNCTION pol1040_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_ini    
      IF p_tela.dat_ini IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_ini 
      END IF 

      AFTER FIELD dat_fim    
      IF p_tela.dat_fim IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_fim 
      ELSE
         IF p_tela.dat_ini > p_tela.dat_fim  THEN
            ERROR "Data inicio deve ser menor ou igual data final"
            NEXT FIELD dat_fim 
         ELSE
            CALL pol1040_cria_temp()
         END IF            
      END IF 
      
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol1040_cria_temp()
#----------------------------#

WHENEVER ERROR CONTINUE
DROP TABLE w_receb

 CREATE  TEMP   TABLE w_receb
  (num_nf            DECIMAL(6,0),
   dat_emis_nf       DATE,
   dat_entrada_nf    DATE,
   nom_fornecedor    CHAR(50),
   cod_item          CHAR(15),
   qtd_item          DECIMAL(12,3),
   qtd_contag        DECIMAL(12,3)
 );
WHENEVER ERROR STOP

 DELETE FROM w_receb

END FUNCTION

#---------------------------------#
 FUNCTION pol1040_emite_relatorio()
#---------------------------------#
  DEFINE l_qtd_rel         INTEGER,
         l_num_seq         INTEGER,
         l_num_aviso_rec   LIKE aviso_rec.num_aviso_rec,
         l_count_reg       INTEGER  

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

   LET l_count_reg = 0
   DECLARE cq_nf_sup CURSOR FOR
    SELECT a.num_aviso_rec,
           a.num_nf,
           a.dat_emis_nf,
           a.dat_entrada_nf,
           a.cod_fornecedor,
           b.cod_item,
           b.num_seq,
           b.qtd_declarad_nf
      FROM nf_sup a, aviso_rec b, item c, ar_aparas_885 d 
     WHERE a.cod_empresa = p_cod_empresa
       AND a.dat_entrada_nf BETWEEN p_tela.dat_ini AND p_tela.dat_fim
       AND a.cod_empresa = b.cod_empresa 
       AND a.num_aviso_rec = b.num_aviso_rec
       AND b.cod_empresa = c.cod_empresa
       AND b.cod_item   =  c.cod_item 
       AND c.cod_familia = '004'  
       AND d.cod_empresa = a.cod_empresa
       AND d.cod_status  = 'P'
       AND d.num_aviso_rec = a.num_aviso_rec
     
   FOREACH cq_nf_sup INTO
           l_num_aviso_rec,
           p_relat.num_nf,
           p_relat.dat_emis_nf,
           p_relat.dat_entrada_nf,
           p_cod_fornecedor,
           p_relat.cod_item,
           l_num_seq,
           p_relat.qtd_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_nf_sup')
         EXIT FOREACH
      END IF
   
      SELECT raz_social
        INTO p_relat.nom_fornecedor
        FROM fornecedor
       WHERE cod_fornecedor  = p_cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fornecedor')
         EXIT FOREACH
      END IF

      SELECT SUM(qtd_liber + qtd_liber_excep + qtd_rejeit)
        INTO p_relat.qtd_contag
        FROM cont_aparas_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = l_num_aviso_rec
         AND num_seq_ar    = l_num_seq  

      IF STATUS <> 0 THEN
         LET p_relat.qtd_contag = 0
      END IF 

      INSERT INTO w_receb VALUES (p_relat.num_nf,
                                  p_relat.dat_emis_nf,
                                  p_relat.dat_entrada_nf,
                                  p_relat.nom_fornecedor,
                                  p_relat.cod_item,
                                  p_relat.qtd_item,
                                  p_relat.qtd_contag)
      LET l_count_reg = l_count_reg + 1                            

   END FOREACH

   IF l_count_reg = 0 THEN
     
   ELSE
      DECLARE cq_rel CURSOR FOR
        SELECT * 
          FROM w_receb
         ORDER BY dat_entrada_nf, 
                  nom_fornecedor   
      FOREACH cq_rel INTO p_w_receb.*
      
          LET p_relat.dat_emis_nf       =  p_w_receb.dat_emis_nf
          LET p_relat.dat_entrada_nf    =  p_w_receb.dat_entrada_nf
          LET p_relat.num_nf            =  p_w_receb.num_nf
          LET p_relat.nom_fornecedor    =  p_w_receb.nom_fornecedor
          LET p_relat.cod_item          =  p_w_receb.cod_item
          LET p_relat.qtd_item          =  p_w_receb.qtd_item
          LET p_relat.qtd_contag        =  p_w_receb.qtd_contag
          LET p_relat.qtd_diferenca = p_relat.qtd_item - p_relat.qtd_contag    
      
         OUTPUT TO REPORT pol1040_relat(p_relat.*)
         
         LET p_count = p_count + 1
          
      END FOREACH
   END IF

   IF p_count > 0 THEN
      MESSAGE "Relatorio Processado com Sucesso" ATTRIBUTE(REVERSE)
   ELSE
      MESSAGE "Não existem dados para os parâmetros informados" ATTRIBUTE(REVERSE)
   END IF
   
   FINISH REPORT pol1040_relat   

   IF p_ies_impressao = "S" THEN
      ERROR "Relatorio Impresso na Impressora ", p_nom_arquivo
      LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
      RUN comando
   ELSE
      ERROR "Relatorio Gravado no Arquivo ",p_nom_arquivo
   END IF
   
END FUNCTION 

#-----------------------------#
REPORT pol1040_relat(p_relat)
#-----------------------------#

   DEFINE p_relat         RECORD 
          dat_emis_nf        LIKE nf_sup.dat_entrada_nf, 
          dat_entrada_nf     LIKE nf_sup.dat_entrada_nf,
          num_nf             LIKE nf_sup.num_nf,
          nom_fornecedor     LIKE fornecedor.raz_social,
          cod_item           LIKE aviso_rec.cod_item,
          qtd_item           LIKE aviso_rec.qtd_declarad_nf,
          qtd_contag         LIKE aviso_rec.qtd_declarad_nf,
          qtd_diferenca      LIKE aviso_rec.qtd_declarad_nf
   END RECORD

 OUTPUT LEFT   MARGIN   1 
        TOP    MARGIN   0
        BOTTOM MARGIN   0
        PAGE   LENGTH   66
   
      ORDER EXTERNAL BY p_relat.dat_entrada_nf
          
   FORMAT

      PAGE HEADER
   
         PRINT COLUMN 001, p_8lpp
         PRINT COLUMN 001,  p_den_empresa,"                             CONTAGEM x NOTA                           EMISSAO : ", TODAY USING "DD/MM/YYYY"
         PRINT COLUMN 001, "POL1040                        RELACAO DE ENTRADA DE NOTAS FISCAIS - APARAS                      PAG: ", PAGENO USING "&&&"
         PRINT
         PRINT COLUMN 001, "  PERIODO: ", p_tela.dat_ini, " ATE ", p_tela.dat_fim
               
         PRINT COLUMN 001, '_________________________________________________________________________________________________________________________________'
         PRINT
         PRINT COLUMN 001, 'NUM NF DT ENTRADA DT EMISSAO FORNECEDOR                                ITEM                 PESO NOTA  PESO BALANCA     DIFERENCA'
         PRINT COLUMN 001, '_________________________________________________________________________________________________________________________________'

      BEFORE GROUP OF p_relat.dat_entrada_nf
      
         
      ON EVERY ROW

      PRINT  COLUMN 001, p_relat.num_nf USING '######',
             COLUMN 008, p_relat.dat_entrada_nf,
             COLUMN 019, p_relat.dat_emis_nf,
             COLUMN 030, p_relat.nom_fornecedor[1,40],
             COLUMN 072, p_relat.cod_item,
             COLUMN 089, p_relat.qtd_item USING '#,###,##&.&&&',
             COLUMN 103, p_relat.qtd_contag USING '#,###,##&.&&&',
             COLUMN 117, p_relat.qtd_diferenca USING '-,---,--&.&&&'

      AFTER GROUP OF p_relat.dat_entrada_nf
         PRINT
         PRINT COLUMN 030, 'TOTAL : ', p_relat.dat_entrada_nf,
               COLUMN 089, GROUP SUM(p_relat.qtd_item) USING '#,###,##&.&&&',
               COLUMN 103, GROUP SUM(p_relat.qtd_contag) USING '#,###,##&.&&&',
               COLUMN 117, GROUP SUM(p_relat.qtd_diferenca) USING '-,---,--&.&&&'
         PRINT
         
      ON LAST ROW

         SKIP 1 LINE          
         PRINT COLUMN 030, "TOTAL GERAL: ",        
               COLUMN 089, SUM(p_relat.qtd_item) USING '#,###,##&.&&&',
               COLUMN 103, SUM(p_relat.qtd_contag) USING '#,###,##&.&&&',
               COLUMN 117, SUM(p_relat.qtd_diferenca) USING '-,---,--&.&&&'

               
END REPORT