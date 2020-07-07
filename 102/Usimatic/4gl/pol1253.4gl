#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1253                                                 #
# OBJETIVO: DE PARA ITEM CHAPA                                      #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 09/01/2014                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro               CHAR(06),
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
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
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
         
END GLOBALS

DEFINE p_den_item_chapa        CHAR(76),
       p_den_chapa_reduz       CHAR(18),
       p_den_item_ar           CHAR(76),
       p_den_ar_reduz          CHAR(18)
       
DEFINE p_de_para       RECORD 
 cod_empresa   char(02),
 cod_chapa     char(15),
 cod_no_ar     char(15)
END RECORD

DEFINE p_de_paraa      RECORD 
 cod_empresa   char(02),
 cod_chapa     char(15),
 cod_no_ar     char(15)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1253-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'
   #LET p_user = 'admlog'
   #LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1253_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1253_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1253") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1253 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1253_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1253_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1253_paginacao("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1253_paginacao("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1253_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modifica��o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1253_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclus�o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclus�o !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1253_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
				CALL pol1253_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1253

END FUNCTION

#-----------------------#
 FUNCTION pol1253_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               "   Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br.com\n\n ",
               "      LOGIX 10.02\n",
               "   www.grupoaceex.com.br\n",
               "     (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1253_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1253_inclusao()
#--------------------------#

   CALL pol1253_limpa_tela()
   
   INITIALIZE p_de_para TO NULL
   LET p_de_para.cod_empresa = p_cod_empresa
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1253_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1253_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1253_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1253_insere()
#------------------------#

   INSERT INTO de_para_chapa_405 VALUES (p_de_para.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","de_para_chapa_405")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1253_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_de_para.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD cod_chapa

         IF p_funcao = "M" THEN
            NEXT FIELD cod_no_ar
         END IF
      
      AFTER FIELD cod_chapa

         IF p_de_para.cod_chapa IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_chapa   
         END IF

         LET p_den_item_chapa = pol1253_le_den_item(p_de_para.cod_chapa)
          
         IF p_den_item_chapa IS NULL THEN 
            ERROR 'Item inexistente.'
            NEXT FIELD cod_chapa
         END IF  
         
         DISPLAY p_den_item_chapa TO den_item_chapa

         SELECT cod_empresa
           FROM de_para_chapa_405
          WHERE cod_empresa = p_cod_empresa
            AND cod_chapa = p_de_para.cod_chapa
         
         IF STATUS = 0 THEN
            ERROR 'DEPARA J� CADASTRADO.'
            NEXT FIELD cod_chapa
         END IF

      AFTER FIELD cod_no_ar

         IF p_de_para.cod_no_ar IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_no_ar   
         END IF

         LET p_den_item_ar = pol1253_le_den_item(p_de_para.cod_no_ar)
          
         IF p_den_item_ar IS NULL THEN 
            ERROR 'Item inexistente.'
            NEXT FIELD cod_no_ar
         END IF  
         
         DISPLAY p_den_item_ar TO den_item_ar         
          
      ON KEY (control-z)
         CALL pol1253_popup()

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            IF p_de_para.cod_no_ar IS NULL THEN 
               NEXT FIELD cod_no_ar
            END IF

         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1253_le_den_item(p_cod)#
#----------------------------------#
   
   DEFINE p_cod CHAR(15),
          p_den CHAR(76)
   
   SELECT den_item
     INTO p_den
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_den = NULL
   END IF  
   
   RETURN p_den
   
END FUNCTION

#----------------------------------#
FUNCTION pol1253_le_den_reduz(p_cod)#
#----------------------------------#
   
   DEFINE p_cod CHAR(15),
          p_den CHAR(18)
   
   SELECT den_item_reduz
     INTO p_den
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_den = NULL
   END IF  
   
   RETURN p_den
   
END FUNCTION


#-----------------------#
 FUNCTION pol1253_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_chapa)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1253
         IF p_codigo IS NOT NULL THEN
           LET p_de_para.cod_chapa = p_codigo
           DISPLAY p_codigo TO cod_chapa
         END IF

      WHEN INFIELD(cod_no_ar)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1253
         IF p_codigo IS NOT NULL THEN
           LET p_de_para.cod_no_ar = p_codigo
           DISPLAY p_codigo TO cod_no_ar
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1253_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1253_limpa_tela()
   LET p_de_paraa.* = p_de_para.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      de_para_chapa_405.cod_chapa,     
      de_para_chapa_405.cod_no_ar
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1253_limpa_tela()
         ELSE
            LET p_de_para.* = p_de_paraa.*
            CALL pol1253_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM de_para_chapa_405 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_chapa"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_de_para.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1253_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1253_exibe_dados()
#------------------------------#

   DEFINE p_cod_item CHAR(15)
   
   LET p_cod_item = p_de_para.cod_chapa
   
   SELECT *
     INTO p_de_para.*
     FROM de_para_chapa_405
    WHERE cod_empresa = p_cod_empresa
      AND cod_chapa = p_cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'de_para_chapa_405')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_de_para.*
   
   LET p_den_item_chapa = pol1253_le_den_item(p_de_para.cod_chapa)
   LET p_den_item_ar = pol1253_le_den_item(p_de_para.cod_no_ar)
   
   DISPLAY p_den_item_chapa to den_item_chapa
   DISPLAY p_den_item_ar to den_item_ar
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1253_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_de_paraa.* = p_de_para.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_de_para.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_de_para.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_chapa
           FROM de_para_chapa_405
          WHERE cod_chapa = p_de_para.cod_chapa
            AND cod_empresa = p_cod_empresa
            
         IF STATUS = 0 THEN
            IF pol1253_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "N�o existem mais itens nesta dire��o !!!"
            LET p_de_para.* = p_de_paraa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1253_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_chapa 
      FROM de_para_chapa_405  
     WHERE cod_chapa = p_de_para.cod_chapa
       AND cod_empresa = p_cod_empresa
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","de_para_chapa_405")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1253_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET p_de_paraa.* = p_de_para.*
   
   IF p_excluiu THEN
      CALL log0030_mensagem("N�o h� dados � serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1253_prende_registro() THEN
      IF pol1253_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         LET p_de_para.* = p_de_paraa.*
         CALL pol1253_exibe_dados() RETURNING p_status
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE de_para_chapa_405
      SET cod_no_ar = p_de_para.cod_no_ar
    WHERE cod_chapa = p_de_para.cod_chapa
      AND cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "de_para_chapa_405")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1253_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("N�o h� dados � serem exclu�dos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1253_prende_registro() THEN
      IF pol1253_deleta() THEN
         INITIALIZE p_de_para TO NULL
         CALL pol1253_limpa_tela()
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#------------------------#
FUNCTION pol1253_deleta()
#------------------------#

   DELETE FROM de_para_chapa_405
    WHERE cod_chapa = p_de_para.cod_chapa
      AND cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","de_para_chapa_405")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1253_listagem()
#--------------------------#     

   IF NOT pol1253_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1253_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT *
      FROM de_para_chapa_405 
     ORDER BY cod_chapa
  
   FOREACH cq_impressao INTO p_de_para.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      LET p_den_chapa_reduz = pol1253_le_den_reduz(p_de_para.cod_chapa)
      LET p_den_ar_reduz = pol1253_le_den_reduz(p_de_para.cod_no_ar)
      
      OUTPUT TO REPORT pol1253_relat() 
      
      LET p_count = 1
      
   END FOREACH

   CALL pol1253_finaliza_relat()

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1253_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1253_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1253.tmp'
         START REPORT pol1253_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1253_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1253_le_den_empresa()
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

#--------------------------------#
FUNCTION pol1253_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1253_relat   

   IF p_count = 0 THEN
      ERROR "N�o existem dados h� serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relat�rio impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relat�rio gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relat�rio gerado com sucesso !!!'
   END IF

END FUNCTION

#----------------------#
 REPORT pol1253_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 071, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1253",
               COLUMN 010, "DE PARA ITEM CHAPA",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'ITEM CHAPA      DESCRICAO          ITEM CORRESP.   DESCRICAO'                                
         PRINT COLUMN 001, '--------------- ------------------ --------------- ------------------'

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 076, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'ITEM CHAPA      DESCRICAO          ITEM CORRESP.   DESCRICAO'                                
         PRINT COLUMN 001, '--------------- ------------------ --------------- ------------------'

      ON EVERY ROW

         PRINT COLUMN 001, p_de_para.cod_chapa,
               COLUMN 017, p_den_chapa_reduz,
               COLUMN 036, p_de_para.cod_no_ar,
               COLUMN 052, p_den_ar_reduz
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT
                  

#-------------------------------- FIM DE PROGRAMA BL-----------------------------#