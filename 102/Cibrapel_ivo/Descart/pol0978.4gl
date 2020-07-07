#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0978                                                 #
# OBJETIVO: LISTAGEM DO ESTOQUE ATUAL                               #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 09/10/09                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          sql_stmt             CHAR(500),
          where_clause         CHAR(500)
                 
   DEFINE p_cod_item           LIKE item.cod_item, 
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_cod_local          LIKE estoque_lote.cod_local,
          p_ies_situa_qtd      LIKE estoque_lote.ies_situa_qtd,
          p_qtd_saldo          LIKE estoque_lote.qtd_saldo,
          p_qtd_reservada      LIKE estoque_loc_reser.qtd_reservada,
          p_qtd_disponivel     LIKE estoque_lote.qtd_saldo

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0978-05.00.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0978_controle()
   END IF
END MAIN

#---------------------------#
 FUNCTION pol0978_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0978") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0978 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0978_le_empresa() THEN
      RETURN
   END IF

   DISPLAY p_cod_empresa TO cod_empresa
      
   MENU "OPCAO"
      COMMAND "Informar" "Informa parâmetros para listagem"
         CALL pol0978_informar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE 
            ERROR 'Parâmetros informados com sucesso !!!'
         ELSE
            LET p_ies_cons = FALSE 
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Listar" "Listagem dos parâmetros informados"
         IF p_ies_cons = TRUE THEN 
            CALL pol0978_listagem() RETURNING p_status
            IF p_status THEN
               LET p_ies_cons = FALSE
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE 
            ERROR 'Informe previamente !!!'
         END IF 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0978

END FUNCTION

#----------------------------#
FUNCTION pol0978_le_empresa()
#----------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
   LET p_cod_empresa = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
         LET p_cod_empresa = p_cod_emp_ger
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#---------------------------#
FUNCTION pol0978_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION


#--------------------------#
 FUNCTION pol0978_informar()
#--------------------------#

   CALL pol0978_limpa_tela()
   
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      item.cod_familia,
      item.cod_item
      
   IF INT_FLAG THEN
      CALL pol0978_limpa_tela()
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION

#--------------------------#
 FUNCTION pol0978_listagem()
#--------------------------#
   
   IF NOT pol0978_escolhe_saida() THEN
   		RETURN FALSE  
   END IF
      
   IF NOT pol0978_le_den_empresa() THEN
      RETURN FALSE 
   END IF   
   
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0
   
   LET sql_stmt = "SELECT cod_item, den_item_reduz",
                  "  FROM item ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " order by den_item_reduz"
   
   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF

   DECLARE cq_item CURSOR FOR var_query

   FOREACH cq_item INTO 
           p_cod_item,
           p_den_item_reduz

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo', 'item')
         RETURN FALSE 
      END IF 
      
      DECLARE cq_lote CURSOR FOR 
      
      SELECT num_lote,
             cod_local,
             ies_situa_qtd,
             qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
       ORDER BY num_lote
      
      FOREACH cq_lote INTO 
              p_num_lote,
              p_cod_local,
              p_ies_situa_qtd,
              p_qtd_saldo
              
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo', 'estoque_lote')
            RETURN FALSE 
         END IF  
      
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reservada
           FROM estoque_loc_reser
          WHERE cod_empresa  = p_cod_empresa
            AND cod_item     = p_cod_item
            AND num_lote     = p_num_lote
            AND cod_local    = p_cod_local
            
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo', 'estoque_loc_reser')
            RETURN FALSE 
         END IF
        
         IF p_qtd_reservada IS NULL THEN 
            LET p_qtd_reservada = 0
         END IF 
         
         LET p_qtd_disponivel = p_qtd_saldo - p_qtd_reservada
         
         OUTPUT TO REPORT pol0978_relat(p_cod_item) 
   
         LET p_count = 1

      END FOREACH
      
   END FOREACH 
         
   FINISH REPORT pol0978_relat   
   
   IF p_count = 0 THEN
      ERROR "Não há dados à serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso!!!'
   END IF
   
   RETURN TRUE 
   
END FUNCTION  

#-------------------------------#
 FUNCTION pol0978_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0978.tmp"
         START REPORT pol0978_relat TO p_caminho
      ELSE
         START REPORT pol0978_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol0978_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
 REPORT pol0978_relat(p_cod_item)
#-------------------------------#

   DEFINE p_cod_item LIKE item.cod_item
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
      
   ORDER EXTERNAL BY p_cod_item
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 109, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0978",
               COLUMN 038, "ESTOQUE ATUAL POR ITEM",
               COLUMN 088, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '     Item           Descricao           lote         Local    Sit.     Estoque         Reservado        Disponivel'
         PRINT COLUMN 001, '--------------- ------------------ --------------- ---------- ---- ---------------- ---------------- ----------------'
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_cod_item,  
               COLUMN 017, p_den_item_reduz,       
               COLUMN 036, p_num_lote, 
               COLUMN 052, p_cod_local,     
               COLUMN 063, p_ies_situa_qtd,       
               COLUMN 068, p_qtd_saldo      USING "###########&.&&&",
               COLUMN 085, p_qtd_reservada  USING "###########&.&&&",
               COLUMN 102, p_qtd_disponivel USING "###########&.&&&"
      
      AFTER GROUP OF p_cod_item
      
         SKIP 1 LINES
         PRINT COLUMN 061, "TOTAL:",
               COLUMN 068, GROUP SUM(p_qtd_saldo) USING "###########&.&&&",
               COLUMN 085, GROUP SUM(p_qtd_reservada) USING "###########&.&&&",
               COLUMN 102, GROUP SUM(p_qtd_disponivel) USING "###########&.&&&"
         SKIP 1 LINES
               
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#