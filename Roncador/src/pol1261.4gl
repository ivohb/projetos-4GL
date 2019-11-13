#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1261                                                 #
# OBJETIVO: DE PARA COMPONENTE DA OP X ITEM SUCATA                  #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 23/07/201                                               #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080),
          p_status             SMALLINT
          
END GLOBALS


DEFINE p_last_row           SMALLINT,
       p_opcao              CHAR(01),  
       p_excluiu            SMALLINT,      
       p_6lpp               CHAR(100),    
       p_8lpp               CHAR(100),    
       p_msg                CHAR(500),    
       p_nom_tela           CHAR(200),    
       p_ies_cons           SMALLINT,     
       p_salto              SMALLINT,     
       p_erro_critico       SMALLINT,     
       p_existencia         SMALLINT,     
       p_num_seq            SMALLINT,     
       P_Comprime           CHAR(01),     
       p_descomprime        CHAR(01),     
       p_rowid              INTEGER,      
       p_retorno            SMALLINT,     
       p_index              SMALLINT,     
       s_index              SMALLINT,     
       p_count              SMALLINT,     
       p_houve_erro         SMALLINT    

DEFINE p_den_item           LIKE item.den_item,
       p_cod_item           LIKE item.cod_item
             
DEFINE p_de_para            RECORD
       cod_empresa          char(02),
       cod_item_compon      char(15),
       cod_item_sucata      char(15)
END RECORD

DEFINE p_de_paraa           RECORD
       cod_empresa          char(02),
       cod_item_compon      char(15),
       cod_item_sucata      char(15)
END RECORD
             
DEFINE p_relat RECORD
       cod_empresa          char(02),
       cod_item_compon      char(15),
       den_compon           char(40),
       cod_item_sucata      char(15),       
       den_sucata           char(40)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1261-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   #CALL log001_acessa_usuario("ESPEC999","")
   #   RETURNING p_status, p_cod_empresa, p_user
   
   LET p_cod_empresa = '21'
   LET p_status = 0
   LET p_user = 'admlog'
   
   IF p_status = 0 THEN
      CALL pol1261_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1261_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1261") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1261 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   CALL pol1261_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1261_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1261_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1261_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1261_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1261_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1261_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1261_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1261_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1261

END FUNCTION

#-----------------------#
 FUNCTION pol1261_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               "   Autor: Ivo H Barbosa\n    ",
               " ibarbosa@totvs.com.br.com\n ",
               "   ivohb.me@gmail.com\n\n    ",
               "      LOGIX 10.02\n          ",
               "   www.grupoaceex.com.br\n   ",
               "   (0xx11) 4991-6667 Com.    ",
               "   (0xx11)94179-6633 Vivo    "

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1261_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1261_inclusao()
#--------------------------#

   CALL pol1261_limpa_tela()
   
   INITIALIZE p_de_para TO NULL
   LET p_de_para.cod_empresa = p_cod_empresa

   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1261_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1261_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1261_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1261_insere()
#------------------------#

   INSERT INTO de_para_item_1054 VALUES (p_de_para.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","de_para_item_1054")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1261_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_de_para.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD cod_item_compon

         IF p_funcao = "M" THEN
            NEXT FIELD cod_item_sucata
         END IF
      
      AFTER FIELD cod_item_compon

         IF p_de_para.cod_item_compon IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório."
            NEXT FIELD cod_item_compon   
         END IF
         
         SELECT cod_item_compon
           FROM de_para_item_1054
          WHERE cod_empresa = p_cod_empresa
            AND cod_item_compon = p_de_para.cod_item_compon
         
         IF STATUS = 0 THEN
            ERROR 'Componente já cadastrada no pol1261.'
            NEXT FIELD cod_item_compon   
         END IF

         CALL pol1261_le_item(p_de_para.cod_item_compon)
            RETURNING p_status
         
         IF NOT p_status THEN
            NEXT FIELD cod_item_compon   
         END IF
                  
         DISPLAY p_den_item TO den_compon

      AFTER FIELD cod_item_sucata

         IF p_de_para.cod_item_sucata IS NOT NULL THEN
            CALL pol1261_le_item(p_de_para.cod_item_sucata)
               RETURNING p_status
         
            IF NOT p_status THEN
               NEXT FIELD cod_item_sucata   
            END IF
         ELSE
            LET p_den_item = NULL
         END IF                  
         
         DISPLAY p_den_item TO den_sucata
            

      ON KEY (control-z)
         CALL pol1261_popup()

      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_de_para.cod_item_sucata IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório."
               NEXT FIELD cod_item_sucata   
            END IF
         END IF

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            IF p_de_para.cod_item_sucata IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório."
               NEXT FIELD cod_item_sucata   
            END IF

         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1261_le_item(p_cod_item)#
#-----------------------------------#

   DEFINE p_cod_item LIKE item.cod_item
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item

   IF STATUS <> 0 THEN
      LET p_den_item = NULL
      CALL log003_err_sql('SELECT', 'item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
     
#-----------------------#
 FUNCTION pol1261_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item_compon)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1261
         IF p_codigo IS NOT NULL THEN
           LET p_de_para.cod_item_compon = p_codigo
           DISPLAY p_codigo TO cod_item_compon
         END IF

      WHEN INFIELD(cod_item_sucata)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1261
         IF p_codigo IS NOT NULL THEN
           LET p_de_para.cod_item_sucata = p_codigo
           DISPLAY p_codigo TO cod_item_sucata
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1261_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1261_limpa_tela()
   LET p_de_paraa.* = p_de_para.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      de_para_item_1054.cod_item_compon,     
      de_para_item_1054.cod_item_sucata

      ON KEY (control-z)
         CALL pol1261_popup()
   END CONSTRUCT
            
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1261_limpa_tela()
         ELSE
            LET p_de_para.* = p_de_paraa.*
            CALL pol1261_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_item_compon ",
                  "  FROM de_para_item_1054 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_empresa"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_item

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1261_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1261_exibe_dados()
#------------------------------#

   DEFINE p_empresa CHAR(02)
   
   SELECT *
     INTO p_de_para.*
     FROM de_para_item_1054
    WHERE cod_empresa = p_cod_empresa 
      AND cod_item_compon = p_cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'de_para_item_1054')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_de_para.*
   
   CALL pol1261_le_item(p_de_para.cod_item_compon)
   DISPLAY p_den_item to den_compon

   CALL pol1261_le_item(p_de_para.cod_item_sucata)
   DISPLAY p_den_item to den_sucata
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1261_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_de_paraa.* = p_de_para.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_item
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_empresa
           FROM de_para_item_1054
          WHERE cod_empresa = p_cod_empresa
            AND cod_item_compon = p_cod_item
            
         IF STATUS = 0 THEN
            IF pol1261_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_de_para.* = p_de_paraa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1261_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM de_para_item_1054  
     WHERE cod_empresa = p_cod_empresa
       AND cod_item_compon = p_cod_item
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","de_para_item_1054")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1261_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET p_de_paraa.* = p_de_para.*
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1261_prende_registro() THEN
      IF pol1261_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         LET p_de_para.* = p_de_paraa.*
         CALL pol1261_exibe_dados() RETURNING p_status
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

   UPDATE de_para_item_1054
      SET de_para_item_1054.* = p_de_para.*
    WHERE cod_empresa = p_cod_empresa
      AND cod_item_compon = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "de_para_item_1054")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1261_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1261_prende_registro() THEN
      IF pol1261_deleta() THEN
         INITIALIZE p_de_para TO NULL
         CALL pol1261_limpa_tela()
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
FUNCTION pol1261_deleta()
#------------------------#

   DELETE FROM de_para_item_1054
    WHERE cod_empresa = p_cod_empresa
     AND cod_item_compon = p_cod_item

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","de_para_item_1054")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1261_listagem()
#--------------------------#     

   IF NOT pol1261_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1261_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT *
      FROM de_para_item_1054
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_item_compon
  
   FOREACH cq_impressao 
      INTO p_relat.cod_empresa,
           p_relat.cod_item_compon,
           p_relat.cod_item_sucata
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      CALL pol1261_le_item(p_relat.cod_item_compon)
      LET p_relat.den_compon = p_den_item

      CALL pol1261_le_item(p_relat.cod_item_sucata)
      LET p_relat.den_sucata = p_den_item
      
      OUTPUT TO REPORT pol1261_relat() 

      LET p_count = 1
      
   END FOREACH

   CALL pol1261_finaliza_relat()

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1261_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1261_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1261.tmp'
         START REPORT pol1261_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1261_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1261_le_den_empresa()
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
FUNCTION pol1261_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1261_relat   

   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
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
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

END FUNCTION

#----------------------#
 REPORT pol1261_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 104, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "POL1261",
               COLUMN 031, "COMPONENTE DA ORDEM X ITEM SUACATA",
               COLUMN 084, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '  COMPONENTE    DESCRICAO                                    SUCATA      DESCRICAO'
         PRINT COLUMN 001, '--------------- ---------------------------------------- --------------- ----------------------------------------'

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 076, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '  COMPONENTE    DESCRICAO                                    SUCATA      DESCRICAO'
         PRINT COLUMN 001, '--------------- ---------------------------------------- --------------- ----------------------------------------'

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.cod_item_compon,
               COLUMN 017, p_relat.den_compon,
               COLUMN 058, p_relat.cod_item_sucata,
               COLUMN 074, p_relat.den_sucata
                              
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
