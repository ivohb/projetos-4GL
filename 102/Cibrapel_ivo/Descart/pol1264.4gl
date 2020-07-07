#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1264                                                 #
# OBJETIVO: LISTAGEM CONSUMO ENVIADOS PELO TRIM                     #
# AUTOR...: IVO HB                                                  #
# DATA....: 28/08/2014                                              #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080),
          p_last_row           SMALLINT,
          sql_stmt             CHAR(500),
          where_clause         CHAR(500)

END GLOBALS

   DEFINE p_chave              CHAR(700),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT
                 
   DEFINE p_den_item_reduz     LIKE item.den_item_reduz,
          p_num_lote_orig      LIKE estoque_trans.num_lote_orig,
          p_qtd_movto          LIKE estoque_trans.qtd_movto,
          p_dat_movto          LIKE estoque_trans.dat_movto,
          p_ies_tip_movto      LIKE estoque_trans.ies_tip_movto,
          p_num_docum          LIKE estoque_trans.num_docum,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_den_familia        LIKE familia.den_familia,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa
          
          
   DEFINE p_tela               RECORD         
          cod_familia          LIKE item.cod_familia,
          cod_item             LIKE item.cod_item,
          dat_ini              DATE,
          dat_fim              DATE
      END RECORD 

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT

   LET p_versao = "pol1264-10.02.00  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL pol1264_controle()
   END IF
END MAIN

#---------------------------#
 FUNCTION pol1264_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1264") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1264 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa
      
   MENU "OPCAO"
      COMMAND "Informar" "Informa parâmetros para listagem"
         CALL pol1264_informar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE 
            ERROR 'Parâmetros informados com sucesso !!!'
         ELSE
            LET p_ies_cons = FALSE 
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Listar" "Listagem dos parâmetros informados"
         IF p_ies_cons = TRUE THEN 
            CALL pol1264_listagem() RETURNING p_status
            IF p_status THEN
               LET p_ies_cons = FALSE
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE 
            ERROR 'Informe previamente !!!'
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1264

END FUNCTION

#---------------------------#
FUNCTION pol1264_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1264_informar()
#--------------------------#
   
   LET INT_FLAG = FALSE 
   
   INITIALIZE p_tela.* TO NULL 
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS 
   
   AFTER FIELD cod_familia
      IF p_tela.cod_familia IS NOT NULL THEN  
         SELECT den_familia
           INTO p_den_familia
           FROM familia
          WHERE cod_empresa = p_cod_empresa
            AND cod_familia = p_tela.cod_familia
            
         IF STATUS = 100 THEN 
            ERROR "Família inexistente !!!"
            NEXT FIELD cod_familia
         ELSE 
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo', 'familia')
               RETURN FALSE 
            END IF 
         END IF  
      ELSE
         LET p_den_familia = NULL 
      END IF 
      
      DISPLAY p_den_familia TO den_familia 
      
   AFTER FIELD cod_item
      IF p_tela.cod_item IS NOT NULL THEN  
         SELECT den_item_reduz
           INTO p_den_item_reduz
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_tela.cod_item
            
         IF STATUS = 100 THEN 
            ERROR "Item inexistente !!!"
            NEXT FIELD cod_item
         ELSE 
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo', 'item')
               RETURN FALSE 
            END IF 
         END IF  
      ELSE 
         LET p_den_item_reduz = NULL 
      END IF  
      
      DISPLAY p_den_item_reduz TO den_item
      
   AFTER FIELD dat_ini
      IF p_tela.dat_ini > TODAY THEN 
         ERROR "A data inicial não pode ser maior que a data atual !!!"
         NEXT FIELD dat_ini
      END IF 
      
   AFTER INPUT 
      IF p_tela.dat_ini IS NOT NULL AND p_tela.dat_fim IS NOT NULL THEN 
         IF p_tela.dat_ini > p_tela.dat_fim THEN 
            ERROR "A data inicial não pode ser maior que a data final !!!"
            NEXT FIELD dat_ini
         END IF 
      END IF 
   
      ON KEY (control-z)
         CALL pol1264_popup()
      
   END INPUT 
      
   IF INT_FLAG  THEN
      CALL pol1264_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1264_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_familia)
         CALL log009_popup(8,10,"FAMÍLIAS","familia",
                     "cod_familia","den_familia","","S","")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_familia = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_familia
         END IF
      
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1264
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
      
   END CASE
   

END FUNCTION

{      
#--------------------------#
 FUNCTION pol1264_listagem()
#--------------------------#
   
   IF NOT pol1264_escolhe_saida() THEN
   		RETURN FALSE  
   END IF
      
   IF NOT pol1264_le_den_empresa() THEN
      RETURN FALSE 
   END IF   
   
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0
   
   INITIALIZE p_chave TO NULL
   
   LET p_chave = " a.cod_empresa = '", p_cod_empresa,"' "
   LET p_chave = p_chave CLIPPED, " AND b.cod_empresa = a.cod_empresa "
   LET p_chave = p_chave CLIPPED, " AND b.cod_item = a.cod_item "
   

   IF p_tela.cod_familia IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND a.cod_familia = '",p_tela.cod_familia,"' "
   END IF
   
   IF p_tela.cod_item IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND a.cod_item = '",p_tela.cod_item,"' "
   END IF
   
   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED,    
          " AND b.dat_movto >= '",p_tela.dat_ini,"' "
   END IF

   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED,    
          " AND b.dat_movto <= '",p_tela.dat_fim,"' "
   END IF

   SELECT cod_estoque_sp    
     INTO p_cod_operacao
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Lendo','par_pcp') 
     RETURN FALSE
   END IF

   LET p_chave = p_chave CLIPPED,    
       " AND b.cod_operacao = '",p_cod_operacao,"' "

   LET sql_stmt = "SELECT a.cod_item, a.den_item_reduz, ",
                  "       b.num_lote_orig, b.qtd_movto, ",
                  "       b.dat_movto, b.ies_tip_movto, b.num_docum",
                  "  FROM item a, estoque_trans b ",
                  " WHERE ", p_chave CLIPPED,
                  " order by b.dat_movto, a.den_item_reduz, b.num_docum"
   
   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF

   DECLARE cq_leitura CURSOR FOR var_query

   FOREACH cq_leitura INTO 
           p_tela.cod_item,
           p_den_item_reduz,
           p_num_lote_orig,
           p_qtd_movto,
           p_dat_movto,
           p_ies_tip_movto,
           p_num_docum

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo', 'item, estoque_trans')
         RETURN FALSE 
      END IF 
      
      IF p_ies_tip_movto = 'R' THEN 
         LET p_qtd_movto = -(p_qtd_movto)
      END IF  
      
      OUTPUT TO REPORT pol1264_relat(p_tela.cod_item) 
   
      LET p_count = 1
      
   END FOREACH 
         
   FINISH REPORT pol1264_relat   
   
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
 FUNCTION pol1264_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1264.tmp"
         START REPORT pol1264_relat TO p_caminho
      ELSE
         START REPORT pol1264_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1264_le_den_empresa()
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
 REPORT pol1264_relat(p_cod_item)
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
               COLUMN 086, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1264",
               COLUMN 031, "BAIXAS NO ESTOQUE",
               COLUMN 065, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "----------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '     Item           Descricao           lote          Quantidade       Data    Tipo Documento '
         PRINT COLUMN 001, '--------------- ------------------ --------------- ---------------- ---------- ---- ----------'
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_tela.cod_item,  
               COLUMN 017, p_den_item_reduz,       
               COLUMN 036, p_num_lote_orig, 
               COLUMN 052, p_qtd_movto       USING "###########&.&&&",     
               COLUMN 069, p_dat_movto,       
               COLUMN 080, p_ies_tip_movto,
               COLUMN 085, p_num_docum  
               
      AFTER GROUP OF p_cod_item
      
         SKIP 1 LINES
         PRINT COLUMN 038, "TOTAL DO ITEM: ",
               COLUMN 051, GROUP SUM(p_qtd_movto) USING "###########&.&&&"
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