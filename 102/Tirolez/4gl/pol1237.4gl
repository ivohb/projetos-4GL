#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1237                                                 #
# OBJETIVO: CANAL DE VENDA                                          #
# AUTOR...: IVO BI                                                  #
# DATA....: 30/10/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix       

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
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
  
   DEFINE p_tirolez_canal    RECORD LIKE tirolez_canal.*
      
   DEFINE p_cod_canal        LIKE tirolez_canal.cod_canal,
          p_cod_canala       LIKE tirolez_canal.cod_canal
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1237-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  
   IF p_status = 0 THEN
      CALL pol1237_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1237_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1237") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1237 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   LET p_ies_cons  = FALSE
   CALL pol1237_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         LET p_ies_cons = FALSE
         CALL pol1237_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclus�o efetuada com sucesso !!!'
         ELSE
            CALL pol1237_limpa_tela()
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
         CALL pol1237_consulta() RETURNING p_status
         IF p_status THEN
            IF p_ies_cons THEN
               ERROR 'Consulta efetuada com sucesso !!!'
               NEXT OPTION "Seguinte" 
            ELSE
               CALL pol1237_limpa_tela()
               ERROR 'Argumentos de pesquisa n�o encontrados !!!'
            END IF 
         ELSE
            CALL pol1237_limpa_tela()
            ERROR 'Opera��o cancelada!!!'
            NEXT OPTION 'Incluir'
         END IF 
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1237_paginacao("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1237_paginacao("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1237_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modifica��o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
        IF p_ies_cons THEN
           CALL pol1237_exclusao() RETURNING p_retorno
           IF p_retorno THEN
              ERROR 'Exclus�o efetuada com sucesso !!!'
           ELSE
              ERROR 'Opera��o cancelada !!!'
           END IF
        ELSE
           ERROR "Consulte previamente para fazer a exclus�o !!!"
        END IF  
      COMMAND "Listar" "Listagem"
         CALL pol1237_listagem()     
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol1237_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1237

END FUNCTION

#-----------------------#
 FUNCTION pol1237_sobre()
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
 FUNCTION pol1237_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1237_inclusao()
#--------------------------#

   CALL pol1237_limpa_tela()
   
   INITIALIZE p_tirolez_canal.* TO NULL
   
   IF pol1237_edita_dados("I") THEN
      INSERT INTO tirolez_canal
       VALUES(p_tirolez_canal.*)
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERT", "tirolez_canal")   
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1237_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01) 
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tirolez_canal.* WITHOUT DEFAULTS
      
      BEFORE FIELD cod_canal
         
         IF p_funcao = 'M' THEN
            NEXT FIELD den_canal
         END IF
      
      AFTER FIELD cod_canal
         
         IF p_tirolez_canal.cod_canal IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD cod_canal   
         END IF
      
         SELECT den_canal
           FROM tirolez_canal
          WHERE cod_canal = p_tirolez_canal.cod_canal
       
         IF STATUS = 0 THEN
            ERROR "Canal de venda j� cadastrado !!!"
            NEXT FIELD cod_canal
         END IF
                 
      AFTER FIELD den_canal

         IF p_tirolez_canal.den_canal IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD den_canal   
         END IF

                   
   END INPUT 

   IF INT_FLAG  THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol1237_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1237_limpa_tela()
   
   LET p_cod_canala = p_cod_canal
   LET INT_FLAG          = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      tirolez_canal.cod_canal,
      tirolez_canal.den_canal
            
   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_cod_canal = p_cod_canala   
         CALL pol1237_exibe_dados() RETURNING p_status
      ELSE
         CALL pol1237_limpa_tela()
      END IF
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT cod_canal ",
                  "  FROM tirolez_canal ",
                  " WHERE ", where_clause CLIPPED,
                  " order by cod_canal "
                  

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','VAR_QUERY')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_canal

   IF STATUS = 0 THEN
      IF pol1237_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   ELSE   
      IF STATUS = 100 THEN
         CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados!","excla")
      ELSE
         CALL log003_err_sql('FETCH','CQ_PADRAO')
      END IF
   END IF

   CALL pol1237_limpa_tela()
   
   LET p_ies_cons = FALSE
         
   RETURN FALSE
   
END FUNCTION

#------------------------------#
 FUNCTION pol1237_exibe_dados()
#------------------------------#
  
  SELECT * 
    INTO p_tirolez_canal.*
    FROM tirolez_canal
   WHERE cod_canal = p_cod_canal
   
  IF STATUS <> 0 THEN 
     CALL log003_err_sql('SELECT','tirolez_canal')
     RETURN FALSE 
  END IF  
  
  DISPLAY BY NAME p_tirolez_canal.*
 
  LET p_excluiu = FALSE
  
  RETURN TRUE
  
END FUNCTION

#-----------------------------------#
 FUNCTION pol1237_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_canala = p_cod_canal

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_canal
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_canal
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "N�o existem mais itens nesta dire��o !!!"
            LET p_cod_canal = p_cod_canala
         ELSE
            CALL log003_err_sql('FETCH','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      SELECT COUNT(*)
        INTO p_count
        FROM tirolez_canal
       WHERE cod_canal = p_cod_canal
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','tirolez_canal')
         RETURN
      END IF
      
      IF p_count > 0 THEN
         IF pol1237_exibe_dados() THEN
            EXIT WHILE
         ELSE
            RETURN
         END IF
      END IF
       
    END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1237_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR WITH HOLD FOR
    SELECT cod_canal 
      FROM tirolez_canal  
     WHERE cod_canal = p_cod_canal
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","tirolez_canal")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1237_modificacao()
#-----------------------------#
   
   IF p_excluiu THEN
      LET p_msg = 'N�o dados na tela\n a serem modificados'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE
   
   IF pol1237_prende_registro() THEN
      IF pol1237_edita_dados("M") THEN
         UPDATE tirolez_canal
            SET tirolez_canal.* = p_tirolez_canal.*
          WHERE cod_canal = p_cod_canal
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","tirolez_canal")
            CALL pol1237_exibe_dados() RETURNING p_status
         END IF
      ELSE
         CALL pol1237_exibe_dados() RETURNING p_status
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
 FUNCTION pol1237_exclusao()
#--------------------------#

   IF p_excluiu THEN
      LET p_msg = 'N�o dados na tela\n a serem exclu�dos'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   IF NOT pol1237_eh_possivel() THEN
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1237_prende_registro() THEN
      DELETE FROM tirolez_canal
       WHERE cod_canal = p_cod_canal
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_tirolez_canal TO NULL
         CALL pol1237_limpa_tela()
         LET p_retorno = TRUE  
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("DELETE","tirolez_canal")
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

#-----------------------------#
FUNCTION pol1237_eh_possivel()#
#-----------------------------#

   SELECT COUNT(*)
     INTO p_count
     FROM tirolez_clientes
    WHERE par_txt[4,5] = p_cod_canal

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','tirolez_clientes')
      RETURN FALSE
   END IF   
   
   IF p_count > 0 THEN
      LET p_msg = 'Canal j� utilizado no CRE0126\n',
                  'n�o pode mais ser exclu�do.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------#
FUNCTION pol1237_listagem()
#-------------------------#     

   IF NOT pol1237_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1237_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT *
      FROM tirolez_canal
     ORDER BY cod_canal
   
   FOREACH cq_impressao INTO 
           p_tirolez_canal.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_IMPRESSAO')
         EXIT FOREACH
      END IF      
               
      OUTPUT TO REPORT pol1237_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1237_relat   
   
   IF p_count = 0 THEN
      ERROR "N�o existem dados h� serem listados. "
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
      ERROR 'Relat�rio gerado com sucesso!!!'
   END IF
  
END FUNCTION 

#------------------------------#
FUNCTION pol1237_escolhe_saida()
#------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1237.tmp"
         START REPORT pol1237_relat TO p_caminho
      ELSE
         START REPORT pol1237_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1237_le_empresa()
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
 REPORT pol1237_relat()
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
               
         PRINT COLUMN 001, "pol1237",
               COLUMN 025, "CANAL DE VENDA",
               COLUMN 060, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '       CODIGO      den_canal                     '
         PRINT COLUMN 001, '       ------      -----------------------------------------'
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1237",
               COLUMN 025, "CANAL DE VENDA",
               COLUMN 060, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '       CODIGO      den_canal                     '
         PRINT COLUMN 001, '       ------      -----------------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 008, p_tirolez_canal.cod_canal,
               COLUMN 020, p_tirolez_canal.den_canal
         
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