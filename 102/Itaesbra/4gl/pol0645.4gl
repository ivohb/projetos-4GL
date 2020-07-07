#-----------------------------------------------------------------------#
# PROGRAMA: pol0645                                                     #
# OBJETIVO: RESERVA DE MATERIAL PARA ORDEM DE PRODUÇÃO NA OP_LOTE       #
# AUTOR...: POLO INFORMATICA - IVO                                      #
# DATA....: 02/10/2007                                                  #
#EDITADO..: 12/12/2007 - BRUNO                                          #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_item2          LIKE op_lote.cod_item_compon,
          p_lin_imp            SMALLINT,
          p_salto              SMALLINT,
          p_num_ordem          INTEGER,       
          p_ies_cons           SMALLINT,
          p_rowid              INTEGER,
          sql_stmt             CHAR(300),
          where_clause         CHAR(300),  
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
          p_msg                CHAR(500)

   DEFINE p_cabec              RECORD
          num_ordem2           LIKE op_lote.num_ordem,
          cod_item2            LIKE op_lote.cod_item_compon,
          exib_reser           CHAR(01)
   END RECORD

   DEFINE pr_item              ARRAY[300] OF RECORD
          cod_item             LIKE op_lote.cod_item_compon,
          num_ordem            LIKE op_lote.num_ordem,
          num_lote             LIKE op_lote.num_lote,
          cod_local            LIKE op_lote.cod_local_baixa,
          endereco             LIKE op_lote.endereco,
          qtd_transf           LIKE op_lote.qtd_transf,
          qtd_cons             LIKE op_lote.qtd_cons,
          saldo                LIKE op_lote.qtd_cons
   END RECORD

   DEFINE p_op_lote  RECORD LIKE op_lote.*
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0645-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0645.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0645_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0645_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0645") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0645 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
      
   MENU "OPCAO"
      COMMAND 'Informar' 'Informa parãmetros para consulta/listagem'
         HELP 001
         MESSAGE ""
         LET INT_FLAG = FALSE
         IF pol0645_informar() THEN
            ERROR 'Parâmetros Informados c/ Sucesso!'
            NEXT OPTION 'Consultar'
         ELSE
            ERROR "Operação Cancelada"
         END IF
      COMMAND 'Consultar' 'Consulta as reservas da ordem da tela'
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0645_consultar()
         ELSE
            ERROR 'Informe previamente os parâmetros'
            NEXT OPTION 'Informar'
         END IF
      COMMAND 'Listar' 'Lista as reservada da tela'
         HELP 001
         MESSAGE ''
         IF p_ies_cons THEN
		         IF log005_seguranca(p_user,"VDP","pol0645","MO") THEN
		            IF log028_saida_relat(18,35) IS NOT NULL THEN
		               MESSAGE " Processando a Extracao do Relatorio..." 
		                  ATTRIBUTE(REVERSE)
		               IF p_ies_impressao = "S" THEN
		                  IF g_ies_ambiente = "U" THEN
		                     START REPORT pol0645_relat TO PIPE p_nom_arquivo
		                  ELSE
		                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
		                     LET p_caminho = p_caminho CLIPPED, 'pol0645.tmp'
		                     START REPORT pol0645_relat  TO p_caminho
		                  END IF
		               ELSE
		                  START REPORT pol0645_relat TO p_nom_arquivo
		               END IF
		               CALL pol0645_listar()   
		               IF p_count = 0 THEN
		                  ERROR "Nao Existem Dados para serem Listados" 
		               ELSE
		                  ERROR "Relatorio Processado com Sucesso" 
		               END IF
		               FINISH REPORT pol0645_relat   
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
         ELSE
            ERROR 'Informe previamente os parâmetros'
            NEXT OPTION 'Informar'
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0645_sobre()
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

   CLOSE WINDOW w_pol0645

END FUNCTION

#---------------------------#
 FUNCTION pol0645_informar()
#---------------------------#

   CLEAR FORM 
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE pr_item TO NULL

   INITIALIZE p_cabec.num_ordem2 TO NULL
   INITIALIZE p_cabec.cod_item2  TO NULL
   INITIALIZE p_cabec.exib_reser TO NULL

   INPUT BY NAME p_cabec.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD num_ordem2
         INITIALIZE p_cabec.num_ordem2 TO NULL
         INITIALIZE p_cabec.cod_item2  TO NULL
         INITIALIZE p_cabec.exib_reser TO NULL
      
      AFTER FIELD num_ordem2
         IF SQLCA.sqlcode = 0 THEN
            NEXT FIELD cod_item2
         END IF   

      AFTER FIELD cod_item2
         IF p_cabec.cod_item2 IS NULL 
         AND p_cabec.num_ordem2 IS NULL THEN
            ERROR 'Informe o Número da Ordem de Produção Ou Do Componente!'
            NEXT FIELD num_ordem2
          END IF
            IF SQLCA.sqlcode = 0 THEN
            NEXT FIELD exib_reser
         END IF
          
      AFTER FIELD exib_reser
         IF p_cabec.exib_reser MATCHES "[ST]" THEN
          ELSE
            ERROR 'Valor ilegal para o campo!'
            NEXT FIELD exib_reser          
         END IF
           
      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            IF  (p_cabec.exib_reser = 'S') 
            AND (p_cabec.num_ordem2 IS NULL) 
            AND (p_cabec.cod_item2 IS NOT NULL) THEN
               SELECT COUNT(num_ordem)
                 INTO p_count
                 FROM op_lote
                WHERE cod_empresa = p_cod_empresa
                  AND cod_item_compon = p_cabec.cod_item2
                  AND qtd_transf  > qtd_cons
            END IF 
            
             IF (p_cabec.exib_reser = 'S') 
            AND (p_cabec.num_ordem2 IS NOT NULL) 
            AND (p_cabec.cod_item2 IS NULL) THEN     
                  SELECT COUNT(num_ordem)
                 INTO p_count
                 FROM op_lote
                WHERE cod_empresa = p_cod_empresa
                 AND num_ordem   = p_cabec.num_ordem2
                 AND qtd_transf  > qtd_cons  
              END IF   
              
             IF (p_cabec.exib_reser = 'S') 
            AND (p_cabec.num_ordem2 IS NOT NULL) 
            AND (p_cabec.cod_item2 IS NOT NULL) THEN
               SELECT COUNT(num_ordem)
                 INTO p_count
                 FROM op_lote
                WHERE cod_empresa = p_cod_empresa
                  AND cod_item_compon = p_cabec.cod_item2
                  AND num_ordem   = p_cabec.num_ordem2
                  AND qtd_transf  > qtd_cons
            END IF 
                                         
            IF  (p_cabec.exib_reser = 'T') 
            AND (p_cabec.num_ordem2 IS NULL) 
            AND (p_cabec.cod_item2 IS NOT NULL ) THEN
               SELECT COUNT(num_ordem)
                 INTO p_count
                 FROM op_lote
                WHERE cod_empresa = p_cod_empresa
                 AND cod_item_compon = p_cabec.cod_item2                 
            END IF 
            
            IF  (p_cabec.exib_reser = 'T') 
            AND (p_cabec.num_ordem2 IS NOT NULL) 
            AND (p_cabec.cod_item2 IS NULL) THEN
               SELECT COUNT(num_ordem)
                 INTO p_count
                 FROM op_lote
                WHERE cod_empresa = p_cod_empresa
                  AND num_ordem   = p_cabec.num_ordem2
                 END IF
                 
                 
             IF (p_cabec.exib_reser = 'T' )
            AND (p_cabec.num_ordem2 IS NOT NULL )
            AND (p_cabec.cod_item2 IS NOT NULL ) THEN
               SELECT COUNT(num_ordem)
                 INTO p_count
                 FROM op_lote
                WHERE cod_empresa = p_cod_empresa
                 AND cod_item_compon = p_cabec.cod_item2
                 AND num_ordem   = p_cabec.num_ordem2                 
            END IF 
             
                        
            IF STATUS <> 0 THEN
               CALL log003_err_sql("LEITURA","op_lote")
               LET INT_FLAG = TRUE
            ELSE
               IF p_count = 0 THEN
                  ERROR 'Não há reservas para essa Ordem!'
                  NEXT FIELD num_ordem2
               END IF
            END IF
            
         END IF
         
          ON KEY (control-z)
          LET p_cod_item2 = pol0645_carrega_item()
            IF p_cod_item2 IS NOT NULL THEN
               LET p_cabec.cod_item2 = p_cod_item2 CLIPPED
               CURRENT WINDOW IS w_pol0645
               DISPLAY p_cabec.cod_item2 TO cod_item2
            END IF     
            
   END INPUT

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE
   END IF

   RETURN p_ies_cons
   
  END FUNCTION

#----------------------------#
 FUNCTION pol0645_Consultar()
#----------------------------#

   IF NOT pol0645_carrega_dados() THEN
      RETURN
   END IF
   
   IF p_count > 11 THEN
      DISPLAY ARRAY pr_item TO  sr_item.* 
   ELSE
      INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0645_carrega_dados()
#---------------------------------#

   DEFINE p_opcao CHAR(01)
   
   LET p_index = 1

   IF p_cabec.exib_reser = 'T' 
   AND p_cabec.num_ordem2 IS NULL 
   AND p_cabec.cod_item2 IS NOT NULL THEN
      LET sql_stmt = 
          "SELECT cod_item_compon,num_ordem,num_lote,cod_local_baixa,endereco,qtd_transf,qtd_cons,qtd_transf-qtd_cons as saldo",
          "  FROM op_lote ",
          " WHERE cod_empresa = '",p_cod_empresa,"' ",
          " AND cod_item_compon = '",p_cabec.cod_item2,"'",          
          " ORDER BY cod_item_compon "
           
   END IF 
   
     IF p_cabec.exib_reser = 'T' 
     AND p_cabec.num_ordem2 IS NOT NULL 
     AND p_cabec.cod_item2 IS NULL THEN
         LET sql_stmt = 
          "SELECT cod_item_compon,num_ordem,num_lote,cod_local_baixa,endereco,qtd_transf,qtd_cons,qtd_transf-qtd_cons as saldo",
          "  FROM op_lote ",
          " WHERE cod_empresa = '",p_cod_empresa,"' ",
          "   AND num_ordem   = '",p_cabec.num_ordem2,"' ",
          " ORDER BY cod_item_compon "
           
   END IF 
   
      IF p_cabec.exib_reser = 'T' 
   AND p_cabec.num_ordem2 IS NOT NULL 
   AND p_cabec.cod_item2 IS NOT NULL THEN
      LET sql_stmt = 
          "SELECT cod_item_compon,num_ordem,num_lote,cod_local_baixa,endereco,qtd_transf,qtd_cons,qtd_transf-qtd_cons as saldo",
          "  FROM op_lote ",
          " WHERE cod_empresa = '",p_cod_empresa,"' ",
          "   AND num_ordem   = '",p_cabec.num_ordem2,"' ",
          " AND cod_item_compon = '",p_cabec.cod_item2,"'",          
          " ORDER BY cod_item_compon "
       END IF 
       
                   
         IF p_cabec.exib_reser = 'S' 
         AND p_cabec.num_ordem2 IS NULL 
         AND p_cabec.cod_item2 IS NOT NULL THEN
      LET sql_stmt = 
          "SELECT cod_item_compon,num_ordem,num_lote,cod_local_baixa,endereco,qtd_transf,qtd_cons,qtd_transf-qtd_cons as saldo",
          "  FROM op_lote ",
          " WHERE cod_empresa = '",p_cod_empresa,"' ",
          " AND cod_item_compon = '",p_cabec.cod_item2,"'",
          " AND qtd_transf  > qtd_cons ",
          " ORDER BY cod_item_compon "
           
   END IF
   
         IF p_cabec.exib_reser = 'S' 
         AND p_cabec.num_ordem2 IS NOT NULL 
         AND p_cabec.cod_item2 IS NULL THEN
      LET sql_stmt = 
          "SELECT cod_item_compon,num_ordem,num_lote,cod_local_baixa,endereco,qtd_transf,qtd_cons,qtd_transf-qtd_cons as saldo",
          "  FROM op_lote ",
          " WHERE cod_empresa = '",p_cod_empresa,"' ",
          "   AND num_ordem   = '",p_cabec.num_ordem2,"' ",
          "   AND qtd_transf  > qtd_cons ",
          " ORDER BY cod_item_compon "  
           
       END IF 
       
       IF p_cabec.exib_reser = 'S' 
         AND p_cabec.num_ordem2 IS NOT NULL 
         AND p_cabec.cod_item2 IS NOT NULL THEN
      LET sql_stmt = 
          "SELECT cod_item_compon,num_ordem,num_lote,cod_local_baixa,endereco,qtd_transf,qtd_cons,qtd_transf-qtd_cons as saldo",
          "  FROM op_lote ",
          " WHERE cod_empresa = '",p_cod_empresa,"' ",
          " AND cod_item_compon = '",p_cabec.cod_item2,"'",
          " AND num_ordem   = '",p_cabec.num_ordem2,"' ",
          " AND qtd_transf  > qtd_cons ",
          " ORDER BY cod_item_compon "
          
        END IF   
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","op_lote")
      RETURN FALSE
   END IF

   PREPARE var_query FROM sql_stmt      
   DECLARE cq_op CURSOR FOR var_query
   FOREACH cq_op INTO pr_item[p_index].*
 
      LET p_index = p_index + 1
      IF p_index > 100 THEN
         ERROR 'Limite de linhas ultrapassado!'
         EXIT FOREACH
      END IF
      
   END FOREACH
    
   CALL SET_COUNT(p_index - 1)

   RETURN TRUE
   
END FUNCTION

#-------------------------#
 FUNCTION pol0645_listar()
#-------------------------#

   IF NOT pol0645_carrega_dados() THEN
      RETURN
   END IF

   LET p_num_ordem = p_cabec.num_ordem2
   
   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   FOR p_index = 1 TO p_count

      OUTPUT TO REPORT pol0645_relat() 

   END FOR

END FUNCTION

#----------------------#
 REPORT pol0645_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         LET p_lin_imp = 7
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 040, "RESERVAS CONTIDAS NA TAB OP_LOTE",
               COLUMN 075, "PAG:", PAGENO USING "#&"
               
         PRINT COLUMN 001, "pol0645",
               COLUMN 040, "ORDEM: ", p_num_ordem,
               COLUMN 060, TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '   Componente     Ordem           Lote        Local      Endereço     Qtd Transf   Qtd Consu    Saldo    '
         PRINT COLUMN 001, '--------------- ------------ -------------- ---------- --------------- ----------- ----------- ----------'
         PRINT
         
      ON EVERY ROW

         PRINT COLUMN 001, pr_item[p_index].cod_item[1,6],
               COLUMN 014, pr_item[p_index].num_ordem USING '##########&&',
               COLUMN 021, pr_item[p_index].num_lote,
               COLUMN 046, pr_item[p_index].cod_local,
               COLUMN 056, pr_item[p_index].endereco, 
               COLUMN 072, pr_item[p_index].qtd_transf USING '#######&.&&',
               COLUMN 084, pr_item[p_index].qtd_cons   USING '#######&.&&',
               COLUMN 095, pr_item[p_index].saldo      USING '#######&.&&'
         
         LET p_lin_imp = p_lin_imp + 1
         
      ON LAST ROW

         LET p_salto = 62 - p_lin_imp
         
         SKIP p_salto LINES
         
         PRINT COLUMN 030, '* * * ULTIMA FOLHA * * *'
         
         
                        
END REPORT

#-------------------------------#   
 FUNCTION pol0645_carrega_item() 
#-------------------------------#
 
    DEFINE pr_lista       ARRAY[3000]
     OF RECORD
         cod_item_compon  LIKE op_lote.cod_item_compon
         
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06451") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06451 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_lista CURSOR FOR 
    SELECT UNIQUE cod_item_compon
        FROM op_lote
        ORDER BY cod_item_compon

   LET pr_index = 1

   FOREACH cq_lista INTO pr_lista[pr_index].cod_item_compon                    
                           
      LET pr_index = pr_index + 1
       IF pr_index > 3000 THEN
         ERROR "Limit e de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_lista TO sr_lista.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol06451
  
  LET p_op_lote.cod_item_compon = pr_lista[pr_index].cod_item_compon
  
   RETURN p_op_lote.cod_item_compon 
      
END FUNCTION 

#-----------------------#
 FUNCTION pol0645_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#
