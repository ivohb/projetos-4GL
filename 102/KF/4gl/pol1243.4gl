#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1243                                                 #
# OBJETIVO: FAMÍLIA PARA BLOQUEIO DE OC                             #
# AUTOR...: IVO BL                                                  #
# DATA....: 18/11/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix       

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_familia        LIKE familia.den_familia,
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
          p_last_row           SMALLINT,
          p_ies_inclu          SMALLINT,
          P_consulta_ent       CHAR(100),
          P_consulta_sai       CHAR(100),
          p_msg                CHAR(300),
          p_excluiu            SMALLINT
  
   DEFINE p_familia_oc_1099    RECORD LIKE familia_oc_1099.*
      
   DEFINE p_cod_familia        LIKE familia_oc_1099.cod_familia,
          p_cod_familiaa       LIKE familia_oc_1099.cod_familia
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1243-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

     IF p_status = 0 THEN
      CALL pol1243_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1243_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1243") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1243 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   LET p_ies_cons  = FALSE
   CALL pol1243_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         LET p_ies_cons = FALSE
         CALL pol1243_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            CALL pol1243_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
         CALL pol1243_consulta() RETURNING p_status
         IF p_status THEN
            IF p_ies_cons THEN
               ERROR 'Consulta efetuada com sucesso !!!'
               NEXT OPTION "Seguinte" 
            ELSE
               CALL pol1243_limpa_tela()
               ERROR 'Argumentos de pesquisa não encontrados !!!'
            END IF 
         ELSE
            CALL pol1243_limpa_tela()
            ERROR 'Operação cancelada!!!'
            NEXT OPTION 'Incluir'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1243_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1243_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      {COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1243_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF}
      COMMAND "Excluir" "Exclui dados da tabela"
        IF p_ies_cons THEN
           CALL pol1243_exclusao() RETURNING p_retorno
           IF p_retorno THEN
              ERROR 'Exclusão efetuada com sucesso !!!'
           ELSE
              ERROR 'Operação cancelada !!!'
           END IF
        ELSE
           ERROR "Consulte previamente para fazer a exclusão !!!"
        END IF  
      COMMAND "Listar" "Listagem"
         CALL pol1243_listagem()     
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1243_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1243

END FUNCTION

#-----------------------#
 FUNCTION pol1243_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
 FUNCTION pol1243_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1243_inclusao()
#--------------------------#

   CALL pol1243_limpa_tela()
   
   INITIALIZE p_familia_oc_1099.* TO NULL
   LET p_familia_oc_1099.cod_empresa = p_cod_empresa
   
   IF pol1243_edita_dados("I") THEN
      INSERT INTO familia_oc_1099
       VALUES(p_familia_oc_1099.*)
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERT", "familia_oc_1099")   
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1243_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01) 
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_familia_oc_1099.* WITHOUT DEFAULTS
      
      BEFORE FIELD cod_familia
         
      AFTER FIELD cod_familia
         
         IF p_familia_oc_1099.cod_familia IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_familia   
         END IF
      
         SELECT cod_familia
           FROM familia_oc_1099
          WHERE cod_empresa = p_cod_empresa
            AND cod_familia = p_familia_oc_1099.cod_familia
       
         IF STATUS = 0 THEN
            ERROR "Família já cadastrada no POL1243."
            NEXT FIELD cod_familia
         END IF
         
         CALL pol1243_le_familia()
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','FAMILIA')
            NEXT FIELD cod_familia
         END IF
         
         DISPLAY p_den_familia TO den_familia

      ON KEY (control-z)
         CALL pol1243_popup()
                                   
   END INPUT 

   IF INT_FLAG  THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1243_le_familia()#
#----------------------------#

   SELECT den_familia
     INTO p_den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_familia_oc_1099.cod_familia

END FUNCTION

#-----------------------#
 FUNCTION pol1243_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_familia)
         CALL log009_popup(8,10,"FAMILIAS","familia",
              "cod_familia","den_familia","","S","1=1 ORDER BY den_familia") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_familia_oc_1099.cod_familia = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_familia
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1243_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1243_limpa_tela()
   
   LET p_cod_familiaa = p_cod_familia
   LET INT_FLAG          = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      familia_oc_1099.cod_familia
            
   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_cod_familia = p_cod_familiaa   
         CALL pol1243_exibe_dados() RETURNING p_status
      ELSE
         CALL pol1243_limpa_tela()
      END IF
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT cod_familia ",
                  "  FROM familia_oc_1099 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " order by cod_familia "
                  

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','VAR_QUERY')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_familia

   IF STATUS = 0 THEN
      IF pol1243_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   ELSE   
      IF STATUS = 100 THEN
         CALL log0030_mensagem("Argumentos de pesquisa não encontrados!","excla")
      ELSE
         CALL log003_err_sql('FETCH','CQ_PADRAO')
      END IF
   END IF

   CALL pol1243_limpa_tela()
   
   LET p_ies_cons = FALSE
         
   RETURN FALSE
   
END FUNCTION

#------------------------------#
 FUNCTION pol1243_exibe_dados()
#------------------------------#
  
  SELECT * 
    INTO p_familia_oc_1099.*
    FROM familia_oc_1099
   WHERE cod_familia = p_cod_familia
   
  IF STATUS <> 0 THEN 
     CALL log003_err_sql('SELECT','familia_oc_1099')
     RETURN FALSE 
  END IF  

  CALL pol1243_le_familia()  
  
  DISPLAY p_cod_familia TO cod_familia
  DISPLAY p_den_familia TO den_familia
 
  LET p_excluiu = FALSE
  
  RETURN TRUE
  
END FUNCTION

#-----------------------------------#
 FUNCTION pol1243_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_familiaa = p_cod_familia

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_familia
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_familia
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_familia = p_cod_familiaa
         ELSE
            CALL log003_err_sql('FETCH','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      SELECT COUNT(cod_familia)
        INTO p_count
        FROM familia_oc_1099
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_cod_familia
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','familia_oc_1099')
         RETURN
      END IF
      
      IF p_count > 0 THEN
         IF pol1243_exibe_dados() THEN
            EXIT WHILE
         ELSE
            RETURN
         END IF
      END IF
       
    END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1243_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR WITH HOLD FOR
    SELECT cod_familia 
      FROM familia_oc_1099  
     WHERE cod_empresa = p_cod_empresa
       AND cod_familia = p_cod_familia
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","familia_oc_1099")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1243_modificacao()
#-----------------------------#
   
   IF p_excluiu THEN
      LET p_msg = 'Não dados na tela\n a serem modificados'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE
   
   IF pol1243_prende_registro() THEN
      IF pol1243_edita_dados("M") THEN
         UPDATE familia_oc_1099
            SET familia_oc_1099.* = p_familia_oc_1099.*
          WHERE cod_empresa = p_cod_empresa
            AND cod_familia = p_cod_familia
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","familia_oc_1099")
            CALL pol1243_exibe_dados() RETURNING p_status
         END IF
      ELSE
         CALL pol1243_exibe_dados() RETURNING p_status
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
 FUNCTION pol1243_exclusao()
#--------------------------#

   IF p_excluiu THEN
      LET p_msg = 'Não dados na tela\n a serem excluídos'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1243_prende_registro() THEN
      DELETE FROM familia_oc_1099
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_cod_familia
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_familia_oc_1099 TO NULL
         CALL pol1243_limpa_tela()
         LET p_retorno = TRUE  
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("DELETE","familia_oc_1099")
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

#-------------------------#
FUNCTION pol1243_listagem()
#-------------------------#     

   IF NOT pol1243_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1243_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT *
      FROM familia_oc_1099
     ORDER BY cod_familia
   
   FOREACH cq_impressao INTO 
           p_familia_oc_1099.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_IMPRESSAO')
         EXIT FOREACH
      END IF      
      
      CALL pol1243_le_familia()
      
      OUTPUT TO REPORT pol1243_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1243_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados. "
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
  
END FUNCTION 

#------------------------------#
FUNCTION pol1243_escolhe_saida()
#------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1243.tmp"
         START REPORT pol1243_relat TO p_caminho
      ELSE
         START REPORT pol1243_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1243_le_empresa()
#---------------------------#

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

#---------------------#
 REPORT pol1243_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT

      FIRST PAGE HEADER
              
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1243",
               COLUMN 025, "FAMÍLIA PARA BLOQUEIO DE OC",
               COLUMN 060, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '       FAMILIA      NOME'
         PRINT COLUMN 001, '       -------      -----------------------------------------'
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1243",
               COLUMN 025, "FAMÍLIA PARA BLOQUEIO DE OC",
               COLUMN 060, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '       FAMILIA      NOME'
         PRINT COLUMN 001, '       -------      -----------------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 010, p_familia_oc_1099.cod_familia,
               COLUMN 021, p_den_familia
         
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