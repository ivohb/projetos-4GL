#-----------------------------------------------------------------------#
# PROGRAMA: pol0785                                                     #
# OBJETIVO: RELATORIO DE NF                                             #
# AUTOR...: POLO INFORMATICA - BRUNO                                    #
# DATA....: 01/04/2008                                                  #
#                                                                       #
# CONVERSÃO 10.02: 07/08/2014 - IVO                                     #
# FUNÇÕES: FUNC002                                                      #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_item2          CHAR(15),
          p_lin_imp            SMALLINT,
          p_salto              SMALLINT,
          p_nom_usuario        CHAR(08),       
          p_ies_cons           SMALLINT,
          p_rowid              INTEGER,
          sql_stmt             CHAR(500),
          where_clause         CHAR(200),  
          p_count              INTEGER,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_status             SMALLINT,
          p_sobe               DECIMAL(1,0),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_tela2          CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_caminho            CHAR(080),
          p_msg                CHAR(100)


   DEFINE pr_item              ARRAY[5000] OF RECORD
         num_aviso_rec         LIKE nf_sup.num_aviso_rec,
         num_nf                LIKE nf_sup.num_nf,
         dat_entrada_nf        LIKE nf_sup.dat_entrada_nf,
         cod_fornecedor        LIKE nf_sup.cod_fornecedor,
         raz_social_reduz      LIKE fornecedor.raz_social_reduz 

   END RECORD

   DEFINE p_nf_sup  RECORD LIKE nf_sup.*
   
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0785-10.02.00  "
   CALL func002_versao_prg(p_versao)
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0785.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0785_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0785_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0785") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0785 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
      
   MENU "OPCAO"
      COMMAND 'Consultar' 'Consulta as auditorias gravadas'
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
            CALL pol0785_consultar()
      COMMAND 'Listar' 'Lista as informações da tela'
         HELP 001
         MESSAGE ''

		         IF log005_seguranca(p_user,"VDP","pol0785","MO") THEN
		            IF log028_saida_relat(18,35) IS NOT NULL THEN
		               MESSAGE " Processando a Extracao do Relatorio..." 
		                  ATTRIBUTE(REVERSE)
		               IF p_ies_impressao = "S" THEN
		                  IF g_ies_ambiente = "U" THEN
		                     START REPORT pol0785_relat TO PIPE p_nom_arquivo
		                  ELSE
		                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
		                     LET p_caminho = p_caminho CLIPPED, 'pol0785.tmp'
		                     START REPORT pol0785_relat  TO p_caminho
		                  END IF
		               ELSE
		                  START REPORT pol0785_relat TO p_nom_arquivo
		               END IF
		               CALL pol0785_listar()   
		               IF p_count = 0 THEN
		                  ERROR "Nao Existem Dados para serem Listados" 
		               ELSE
		                  ERROR "Relatorio Processado com Sucesso" 
		               END IF
		               FINISH REPORT pol0785_relat   
		            ELSE
		               CONTINUE MENU
		            END IF                                                     
		            IF p_ies_impressao = "S" THEN
		               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
		                  ATTRIBUTE(REVERSE)
		               IF g_ies_ambiente = "W" THEN
		                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
		                                p_nom_arquivo
		                  RUN comando
		               END IF
		            ELSE
		               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
		                  " " ATTRIBUTE(REVERSE)
		            END IF                              
		         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0785

END FUNCTION

#----------------------------#
 FUNCTION pol0785_consultar()
#----------------------------#

          SELECT COUNT (*)
            INTO p_count      
            FROM nf_sup a, fornecedor b
           WHERE a.cod_empresa = p_cod_empresa
           AND a.cod_fornecedor = b.cod_fornecedor
           AND a.num_aviso_rec NOT IN(SELECT num_aviso_rec FROM ar_proces_885
                                            WHERE cod_empresa = p_cod_empresa)

   IF NOT pol0785_carrega_dados() THEN
      RETURN
   END IF
   
   IF p_count > 14 THEN
      DISPLAY ARRAY pr_item TO  sr_item.* 
   ELSE
      INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0785_carrega_dados()
#---------------------------------#

   DEFINE p_opcao CHAR(01)
   
   LET p_index = 1

      LET sql_stmt = 
          "SELECT a.num_aviso_rec,
                  a.num_nf,
                  a.dat_entrada_nf,
                  a.cod_fornecedor,
                  b.raz_social_reduz",
          "  FROM nf_sup a, fornecedor b",
          " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
          " AND a.cod_fornecedor = b.cod_fornecedor",
          " AND a.num_aviso_rec not in(select num_aviso_rec from ar_proces_885
                                            where  cod_empresa = ",p_cod_empresa,")",
          " ORDER BY a.num_aviso_rec"
    
   PREPARE var_query FROM sql_stmt      
   DECLARE cq_op CURSOR FOR var_query
   FOREACH cq_op INTO pr_item[p_index].*
 
      LET p_index = p_index + 1
      
   END FOREACH
    
   CALL SET_COUNT(p_index - 1)

   RETURN TRUE
   
END FUNCTION

#-------------------------#
 FUNCTION pol0785_listar()
#-------------------------#

   IF NOT pol0785_carrega_dados() THEN
      RETURN
   END IF 
  
   FOR p_index = 1 TO p_count

      OUTPUT TO REPORT pol0785_relat() 

   END FOR

END FUNCTION

#----------------------#
 REPORT pol0785_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         LET p_lin_imp = 7
         
         PRINT COLUMN 015, "RELATORIO DE NF",
               COLUMN 040, "PAG:", PAGENO USING "#&"
               
         PRINT COLUMN 001, "pol0785",
               COLUMN 015, "ORDEM: ", p_user,
               COLUMN 040, TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "---------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'Av. Receb  Num. NF    DATA       Fornecedor      Razao Social  '   
         PRINT COLUMN 001, '---------  ------- ----------- ---------------  ---------------'
         PRINT               
         
      ON EVERY ROW

         PRINT COLUMN 001, pr_item[p_index].num_aviso_rec, 
               COLUMN 010, pr_item[p_index].num_nf, 
               COLUMN 020, pr_item[p_index].dat_entrada_nf,
               COLUMN 032, pr_item[p_index].cod_fornecedor, 
               COLUMN 049, pr_item[p_index].raz_social_reduz
               
               
               
         
         LET p_lin_imp = p_lin_imp + 1
         SKIP 001 LINES
         
      ON LAST ROW
         
         PRINT COLUMN 030, '* * * ULTIMA FOLHA * * *'
         
         
                        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#
