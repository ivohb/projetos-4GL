#-------------------------------------------------------------------#
# OBJETIVO: MOVIMENTOS DE PRODUTOS                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
          p_val_icms_c         DECIMAL(10,2),
          p_imprimiu           SMALLINT,
          p_msg                CHAR(100),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_normal             CHAR(02),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_ies_conf           SMALLINT,
          p_caminho            CHAR(080),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_query              CHAR(600),
          where_clause         CHAR(500)

   DEFINE p_den_item           LIKE item.den_item_reduz,
          p_den_familia        LIKE familia.den_familia
          
   DEFINE p_tela               RECORD
      empresa                  LIKE item.cod_empresa,
      cod_item                 LIKE item.cod_item,
      cod_familia              LIKE item.cod_familia,
      dat_ini                  DATE,
      dat_fim                  DATE      
   END RECORD 

   DEFINE p_relat             RECORD
          num_transac        INTEGER,         
          cod_item           CHAR(15),        
          num_lote           CHAR(15),        
          ies_situacao       CHAR(01),        
          num_lote_orig      CHAR(15),        
          ies_sit_est_orig   CHAR(01),        
          num_lote_dest      CHAR(15),        
          ies_sit_est_dest   CHAR(01),        
          qtd_movto          DECIMAL(10,3),   
          cod_operacao       CHAR(04),        
          tip_operacao       CHAR(01)         
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1082-05.10.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1082.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1082_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1082_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1082") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1082 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol1082_cria_tab_tmp() THEN
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para o processamento"
         CALL pol1082_informar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            NEXT OPTION 'Listar'
         ELSE
            LET p_ies_cons = FALSE
         END IF
      COMMAND "Movimentos" "Listagem dos movimentos de Entrada/Saida"
         IF log005_seguranca(p_user,"VDP","pol1082","IN")  THEN
            IF p_ies_cons THEN
               CALL pol1082_listagem("M") RETURNING p_status
               IF NOT p_status THEN
                  ERROR 'Operação cancelada !!!'
               ELSE
                  ERROR 'Fim do processamento !!!'
               END IF
            ELSE
               ERROR 'Informe os parâmetros previamente !!!'
            END IF
         END IF 
      COMMAND "Divergências" "Listagem das bobinas que entraram más não sairam"
         IF log005_seguranca(p_user,"VDP","pol1082","IN")  THEN
            IF p_ies_cons THEN
               CALL pol1082_listagem("D") RETURNING p_status
               IF NOT p_status THEN
                  ERROR 'Operação cancelada !!!'
               ELSE
                  ERROR 'Fim do processamento !!!'
               END IF
            ELSE
               ERROR 'Informe os parâmetros previamente !!!'
            END IF
         END IF 
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
   
   CLOSE WINDOW w_pol1082

END FUNCTION

#----------------------------#
FUNCTION pol1082_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL

END FUNCTION

#--------------------------#
FUNCTION pol1082_informar()
#--------------------------#

   CALL pol1082_limpa_tela()
   LET p_tela.empresa = p_cod_empresa
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
      
      AFTER FIELD empresa
      
         IF p_tela.empresa IS NULL THEN
            ERROR 'Campo com preenchimento obrigat´rio !!!'
            NEXT FIELD empresa
         END IF
         
         SELECT den_empresa
           INTO p_den_empresa
           FROM empresa
          WHERE cod_empresa = p_tela.empresa
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','empresa')
            NEXT FIELD empresa
         END IF
         
         DISPLAY p_den_empresa TO den_empresa

      AFTER FIELD cod_item
      
         IF p_tela.cod_item IS NOT NULL THEN
            SELECT den_item_reduz
              INTO p_den_item
              FROM item
             WHERE cod_empresa = p_tela.empresa
               AND cod_item    = p_tela.cod_item
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','item')
               NEXT FIELD cod_item
            END IF
            DISPLAY p_den_item TO den_item
         END IF
         
      AFTER FIELD cod_familia
      
         IF p_tela.cod_familia IS NOT NULL THEN
            SELECT den_familia
              INTO p_den_familia
              FROM familia
             WHERE cod_empresa = p_tela.empresa
               AND cod_familia = p_tela.cod_familia
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','item')
               NEXT FIELD cod_familia
            END IF
            DISPLAY p_den_familia TO den_familia
         END IF
            
      AFTER INPUT
         IF NOT INT_FLAG THEN   
            IF p_tela.dat_ini IS NULL THEN
               ERROR 'Informe a data inicial !!!'
               NEXT FIELD dat_ini
            END IF
            IF p_tela.dat_fim IS NULL THEN
               ERROR 'Informe a data final !!!'
               NEXT FIELD dat_fim
            END IF
            IF p_tela.dat_fim > TODAY THEN
               ERROR 'Data final deve ser menor ou igual a data de hoje !!!'
               NEXT FIELD dat_fim
            END IF
            IF p_tela.dat_ini > p_tela.dat_fim THEN
               ERROR "Data Inicial nao pode ser maior que data Final"
               NEXT FIELD dat_ini
            END IF 
            IF p_tela.dat_fim - p_tela.dat_ini > 365 THEN 
               ERROR "Periodo nao pode ser maior que 720 Dias"
               NEXT FIELD dat_ini
            END IF 
         END IF
         
   END INPUT
   
   IF INT_FLAG THEN
      CALL pol1082_limpa_tela()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1082_monta_select()
#------------------------------#

   LET p_query  = 
       "SELECT num_transac, cod_item, num_lote_orig, ies_sit_est_orig,  ",
       "   num_lote_dest, ies_sit_est_dest, qtd_movto, cod_operacao ",
       "  FROM estoque_trans ",
       " WHERE cod_empresa = '",p_tela.empresa,"' ",
       "   AND dat_movto BETWEEN '",p_tela.dat_ini,"'  AND '",p_tela.dat_fim,"' ",
       "   AND ies_tip_movto = 'N' "

   IF p_tela.cod_item IS NOT NULL THEN
      LET p_query  = p_query CLIPPED,
          " AND cod_item = '",p_tela.cod_item,"' "
   END IF

   IF p_tela.cod_familia IS NOT NULL THEN
      LET p_query  = p_query CLIPPED,
          " AND cod_item in (SELECT cod_item FROM item ",
          " WHERE cod_empresa = '",p_tela.empresa,"' ",
          "   AND cod_familia = '",p_tela.cod_familia,"' )"
   END IF
      
END FUNCTION

#-----------------------------#
FUNCTION pol1082_cria_tab_tmp()
#-----------------------------#

   DROP TABLE mov_tmp_885

   CREATE TABLE mov_tmp_885(
       num_transac        INTEGER, 
       cod_item           CHAR(15), 
       num_lote           CHAR(15), 
       ies_situacao       CHAR(01),
       qtd_movto          DECIMAL(10,3), 
       cod_operacao       CHAR(04),
       tip_operacao       CHAR(01)
    );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","mov_tmp_885")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1082_le_movtos()
#---------------------------#

   DEFINE p_ies_acumulado LIKE estoque_operac.ies_acumulado,
          p_ies_tipo      LIKE estoque_operac.ies_tipo

   CALL pol1082_monta_select()

   DELETE FROM mov_tmp_885

   MESSAGE "Aguarde!... Lendo movimentos..." ATTRIBUTE(REVERSE)

   PREPARE var_query FROM p_query   
   DECLARE cq_lst CURSOR FOR var_query

   FOREACH cq_lst INTO 
           p_relat.num_transac,     
           p_relat.cod_item,        
           p_relat.num_lote_orig,   
           p_relat.ies_sit_est_orig,
           p_relat.num_lote_dest,   
           p_relat.ies_sit_est_dest,
           p_relat.qtd_movto,       
           p_relat.cod_operacao   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','cq_lst')
         RETURN FALSE
      END IF

      SELECT COUNT(num_transac_rev)
        INTO p_count
        FROM estoque_trans_rev
       WHERE cod_empresa = p_tela.empresa
         AND num_transac_normal = p_relat.num_transac

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','estoque_trans_rev')
         RETURN FALSE
      END IF

      IF p_count > 0 THEN
         CONTINUE FOREACH
      END IF
           
      SELECT ies_tipo
             ies_acumulado
        INTO p_ies_tipo,
             p_ies_acumulado
        FROM estoque_operac
       WHERE cod_empresa  = p_tela.empresa
         AND cod_operacao = p_relat.cod_operacao
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','estoque_operac')
         RETURN FALSE
      END IF

      IF p_ies_tipo = 'S' THEN
         IF p_ies_acumulado = '2' THEN
            LET p_ies_tipo = 'E'
         END IF
      ELSE
         IF p_ies_acumulado = '1' THEN
            LET p_ies_tipo = 'S'
         END IF
      END IF      
      
      IF p_ies_tipo = 'E' THEN
         LET p_relat.num_lote     = p_relat.num_lote_dest
         LET p_relat.ies_situacao = p_relat.ies_sit_est_dest
      ELSE
         LET p_relat.num_lote     = p_relat.num_lote_orig
         LET p_relat.ies_situacao = p_relat.ies_sit_est_orig
      END IF
      
      LET p_relat.tip_operacao = p_ies_tipo

      INSERT INTO mov_tmp_885
       VALUES(p_relat.num_transac, 
              p_relat.cod_item,    
              p_relat.num_lote,    
              p_relat.ies_situacao,
              p_relat.qtd_movto,   
              p_relat.cod_operacao,
              p_relat.tip_operacao)
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','mov_tmp_885')
         RETURN FALSE
      END IF
      
   END FOREACH

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1082_checa_diverg()
#------------------------------#

   DEFINE p_num_trans_s INTEGER,
          p_num_trans_e INTEGER,
          p_num_lote    CHAR(15)

   DECLARE cq_div CURSOR FOR
    SELECT num_transac,
           num_lote
      FROM mov_tmp_885
     WHERE tip_operacao = 'S'

   FOREACH cq_div INTO p_num_trans_s, p_num_lote

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_div')
         RETURN
      END IF
      
      DECLARE cq_del CURSOR FOR
       SELECT num_transac
         FROM mov_tmp_885
        WHERE tip_operacao = 'E'
          AND num_lote     = p_num_lote
        ORDER BY num_transac
      
      FOREACH cq_del INTO p_num_trans_e
           
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_del')
            RETURN
         END IF
         
         DELETE FROM mov_tmp_885
          WHERE num_transac = p_num_trans_e

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Deletando','mov_tmp_885:E')
            RETURN
         END IF
         
         EXIT FOREACH
      
      END FOREACH
      
      DELETE FROM mov_tmp_885
       WHERE num_transac = p_num_trans_S

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Deletando','mov_tmp_885:S')
         RETURN
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION
           
#------------------------------#
FUNCTION pol1082_listagem(p_op)
#------------------------------#
   
   DEFINE p_op CHAR(01)
   
   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF

   IF NOT pol1082_le_movtos() THEN
      RETURN FALSE
   END IF
   
   IF p_op = 'D' THEN
      IF NOT pol1082_checa_diverg() THEN
         RETURN FALSE
      END IF
   END IF

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_tela.empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0732.tmp"
         START REPORT pol1082_relat TO p_caminho
      ELSE
         START REPORT pol1082_relat TO p_nom_arquivo
      END IF
   END IF

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18

   LET p_imprimiu = FALSE

   DECLARE cq_tmp CURSOR FOR
    SELECT num_transac, 
           cod_item,    
           num_lote,    
           ies_situacao,
           qtd_movto,   
           cod_operacao,
           tip_operacao
      FROM mov_tmp_885
     ORDER BY cod_item, num_lote, tip_operacao, cod_operacao, num_transac      
   
   FOREACH cq_tmp INTO 
           p_relat.num_transac, 
           p_relat.cod_item,    
           p_relat.num_lote,    
           p_relat.ies_situacao,
           p_relat.qtd_movto,   
           p_relat.cod_operacao,
           p_relat.tip_operacao 

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','empresa')
         EXIT FOREACH
      END IF
      
      IF p_relat.tip_operacao = 'S' THEN
         LET p_relat.qtd_movto = -p_relat.qtd_movto
      END IF
      
      SELECT den_item_reduz
        INTO p_den_item
        FROM item
       WHERE cod_empresa = p_tela.empresa
         AND cod_item    = p_relat.cod_item
        
      LET p_imprimiu = TRUE
        
      DISPLAY p_relat.num_transac AT 21,50
         
      OUTPUT TO REPORT pol1082_relat(p_relat.cod_item)

   END FOREACH
      
           
   FINISH REPORT pol1082_relat

   MESSAGE ""
   
   IF NOT p_imprimiu THEN
      ERROR "Não existem dados para serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         MESSAGE p_msg
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         MESSAGE p_msg
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 REPORT pol1082_relat(p_cod_item)
#--------------------------------#

   DEFINE p_cod_item CHAR(15)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 1
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
      
      ORDER EXTERNAL BY p_cod_item
      
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 042, "MOVIMENTACAO DE PRODUTOS",
               COLUMN 071, "PAG: ", PAGENO USING "&&&"
               
         PRINT COLUMN 001, "POL1082",                   
               COLUMN 020, "PERIODO: ",p_tela.dat_ini USING 'dd/mm/yyyy', ' - ',p_tela.dat_fim USING 'dd/mm/yyyy',
               COLUMN 064, "DATA: ", TODAY USING 'dd/mm/yyyy'

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "LOTE            QUANTIDADE  SITUACAO OPERACAO TIPO"
         PRINT COLUMN 001, "--------------- ----------- -------- -------- ----"
         PRINT

      BEFORE GROUP OF p_cod_item

         PRINT      
         PRINT COLUMN 001, "ITEM: ",p_cod_item CLIPPED, ' - ', p_den_item
         PRINT
         #SKIP TO TOP OF PAGE  
      
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.num_lote,
               COLUMN 017, p_relat.qtd_movto,
               COLUMN 032, p_relat.ies_situacao,
               COLUMN 040, p_relat.cod_operacao,
               COLUMN 048, p_relat.tip_operacao
               
      AFTER GROUP OF p_cod_item
      
         SKIP 1 LINES
         PRINT COLUMN 004, "SALDO MOVTO: ",
               COLUMN 017, GROUP SUM(p_relat.qtd_movto) USING '######&.&&&'
         PRINT COLUMN 001, "--------------------------------------------------"
         
      ON LAST ROW

         
         PRINT
         
         WHILE LINENO < 64
            PRINT
         END WHILE

         PRINT COLUMN 030, p_descomprime, '* * * ULTIMA FOLHA * * *'

END REPORT
