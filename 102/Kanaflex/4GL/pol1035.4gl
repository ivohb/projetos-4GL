#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1035                                                 #
# OBJETIVO: CADASTRO DOS REPRESENTANTES QUE ATINGIRAM A META        #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 03/05/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
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
          p_msg                CHAR(100),
          p_last_row           SMALLINT
         
  
   DEFINE p_repres_meta_444    RECORD
          cod_repres           DECIMAL(4,0),
          ano                  DECIMAL(4,0),
          mes                  DECIMAL(2,0) 
   END RECORD
   
   DEFINE p_repres_meta_444_ant RECORD
          cod_repres            DECIMAL(4,0),
          ano                   DECIMAL(4,0),
          mes                   DECIMAL(2,0) 
   END RECORD
      
   DEFINE p_today              CHAR(10),
          p_den_mes            CHAR(09),
          p_raz_social         CHAR(36)
             
END GLOBALS

MAIN
   #CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1035-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1035_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1035_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1035") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1035 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1035_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol1035_inclusao() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = FALSE
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
          IF pol1035_consulta() THEN
            LET p_ies_cons = TRUE
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1035_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1035_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol1035_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem"
         CALL pol1035_listagem()   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol1035_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1035

END FUNCTION

#----------------------------#
 FUNCTION pol1035_limpa_tela()
#----------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 
   
#--------------------------#
 FUNCTION pol1035_inclusao()
#--------------------------#
   
   IF pol1035_edita_dados() THEN
      CALL log085_transacao("BEGIN")
      
      INSERT INTO repres_meta_444 
         VALUES (p_repres_meta_444.cod_repres, 
                 p_repres_meta_444.ano, 
                 p_repres_meta_444.mes)
      
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","repres_meta_444")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol1035_edita_dados()
#-----------------------------#
   
   LET INT_FLAG = FALSE 
   
   CALL pol1035_limpa_tela()
   INITIALIZE p_repres_meta_444.* TO NULL
   
   LET p_today                = TODAY 
   LET p_repres_meta_444.ano  = p_today[7,10]
   LET p_repres_meta_444.mes  = p_today[4,5]
   
   CALL pol1035_checa_mes()
   
   INPUT BY NAME p_repres_meta_444.* WITHOUT DEFAULTS
            
      AFTER FIELD cod_repres
      IF p_repres_meta_444.cod_repres IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_repres   
      END IF
          
      SELECT raz_social
        INTO p_raz_social
        FROM representante
       WHERE cod_repres = p_repres_meta_444.cod_repres
          
      IF STATUS = 100 THEN 
         ERROR 'Representante não cadastrado !!!'
         NEXT FIELD cod_repres
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','representante')
            RETURN FALSE
         END IF 
      END IF  
      
      DISPLAY p_raz_social TO raz_social
                  
      AFTER FIELD ano
      IF p_repres_meta_444.ano IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD ano   
      END IF
                  
      IF p_repres_meta_444.ano < 1899 THEN 
         ERROR "Valor ilegal para o campo em questão !!!"
         NEXT FIELD ano
      END IF 
      
      AFTER FIELD mes
      IF p_repres_meta_444.mes IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD mes   
      END IF
                       
      IF p_repres_meta_444.mes > 12 OR p_repres_meta_444.mes < 1 THEN 
         ERROR "Valor ilegal para o campo em questão !!!"
         NEXT FIELD mes
      END IF
      
      CALL pol1035_checa_mes()
      
      IF p_repres_meta_444.ano > p_today[7,10] THEN 
         ERROR "A data indicada não pode ser superior á data atual !!!"
         NEXT FIELD ano
      ELSE 
         IF p_repres_meta_444.ano = p_today[7,10] AND 
            p_repres_meta_444.mes > p_today[4,5]  THEN
            ERROR "A data indicada não pode ser superior á data atual !!!"
            NEXT FIELD mes
         END IF 
      END IF 
      
      LET p_repres_meta_444.mes = p_repres_meta_444.mes USING "&&"
      
      SELECT cod_repres
        FROM repres_meta_444
       WHERE cod_repres = p_repres_meta_444.cod_repres
         AND ano        = p_repres_meta_444.ano
         AND mes        = p_repres_meta_444.mes
         
      IF STATUS = 0 THEN 
         ERROR "Representante já cadastrado para a data informada !!!"
         NEXT FIELD cod_repres
      ELSE
         IF STATUS <> 100 THEN 
            CALL log003_err_sql("Lendo", "repres_meta_444")
            RETURN FALSE
         END IF 
      END IF 
      
      ON KEY (control-z)
         CALL pol1035_popup()
      
   END INPUT 

   IF INT_FLAG  THEN
      CALL pol1035_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol1035_checa_mes()
#---------------------------#

   CASE 
      
      WHEN p_repres_meta_444.mes = 1
         LET p_den_mes = "JANEIRO"
      
      WHEN p_repres_meta_444.mes = 2
         LET p_den_mes = "FEVEREIRO"
         
      WHEN p_repres_meta_444.mes = 3
         LET p_den_mes = "MARÇO"
         
      WHEN p_repres_meta_444.mes = 4
         LET p_den_mes = "ABRIL"
         
      WHEN p_repres_meta_444.mes = 5
         LET p_den_mes = "MAIO"
         
      WHEN p_repres_meta_444.mes = 6
         LET p_den_mes = "JUNHO"
         
      WHEN p_repres_meta_444.mes = 7
         LET p_den_mes = "JULHO"
         
      WHEN p_repres_meta_444.mes = 8
         LET p_den_mes = "AGOSTO"
         
      WHEN p_repres_meta_444.mes = 9
         LET p_den_mes = "SETEMBRO"
         
      WHEN p_repres_meta_444.mes = 10
         LET p_den_mes = "OUTUBRO"
         
      WHEN p_repres_meta_444.mes = 11
         LET p_den_mes = "NOVEMBRO"
         
      WHEN p_repres_meta_444.mes = 12
         LET p_den_mes = "DEZEMBRO"
         
   END CASE 
   
   DISPLAY p_den_mes TO den_mes
   
END FUNCTION 

#-----------------------#
 FUNCTION pol1035_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     WHEN INFIELD(cod_repres)
         CALL log009_popup(8,10,"REPRESENTANTES","representante",
                     "cod_repres","raz_social","","N","")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_repres_meta_444.cod_repres = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_repres
         END IF
   END CASE 
   
END FUNCTION
         
#--------------------------#
 FUNCTION pol1035_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1035_limpa_tela()
      
   LET p_repres_meta_444_ant.* = p_repres_meta_444.*
   LET INT_FLAG                = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      repres_meta_444.cod_repres,
      repres_meta_444.ano,
      repres_meta_444.mes
      
      ON KEY (control-z)
         CALL pol1035_popup()
         
   END CONSTRUCT 
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_repres_meta_444.* = p_repres_meta_444_ant.*
         CALL pol1035_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT cod_repres, ano, mes",
                  "  FROM repres_meta_444 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY ano, mes, cod_repres"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_repres_meta_444.*

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1035_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1035_exibe_dados()
#------------------------------#
   
   SELECT raz_social
     INTO p_raz_social
     FROM representante
    WHERE cod_repres = p_repres_meta_444.cod_repres
    
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'representante')
      RETURN FALSE 
   END IF
   
   CALL pol1035_checa_mes()
   
   DISPLAY p_repres_meta_444.cod_repres TO cod_repres
   DISPLAY p_raz_social                 TO raz_social
   DISPLAY p_repres_meta_444.ano        TO ano
   DISPLAY p_repres_meta_444.mes        TO mes
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1035_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_repres_meta_444_ant.* = p_repres_meta_444.*

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_repres_meta_444.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_repres_meta_444.*
         
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_repres
           FROM repres_meta_444
          WHERE cod_repres = p_repres_meta_444.cod_repres
            AND ano        = p_repres_meta_444.ano
            AND mes        = p_repres_meta_444.mes
             
         IF STATUS = 0 THEN
            CALL pol1035_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_repres_meta_444.* = p_repres_meta_444_ant.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1035_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_repres 
      FROM repres_meta_444  
     WHERE cod_repres = p_repres_meta_444.cod_repres
       AND ano        = p_repres_meta_444.ano
       AND mes        = p_repres_meta_444.mes
           FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","repres_meta_444")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1035_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1035_prende_registro() THEN
      DELETE FROM repres_meta_444
			WHERE cod_repres = p_repres_meta_444.cod_repres
        AND ano        = p_repres_meta_444.ano
        AND mes        = p_repres_meta_444.mes
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_repres_meta_444.* TO NULL
         CALL pol1035_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","repres_meta_444")
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
FUNCTION pol1035_listagem()
#-------------------------#     

   IF NOT pol1035_escolhe_saida() THEN
   		RETURN 
   END IF
   
   IF NOT pol1035_le_empresa() THEN
      RETURN
   END IF 
      
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT cod_repres,
           ano,
           mes
      FROM repres_meta_444
     ORDER BY ano, mes, cod_repres
   
   FOREACH cq_impressao INTO 
           p_repres_meta_444.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','repres_meta_444:cq_impressao')
         EXIT FOREACH
      END IF      
      
      SELECT raz_social
        INTO p_raz_social
        FROM representante
       WHERE cod_repres = p_repres_meta_444.cod_repres
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Representante')
         EXIT FOREACH
      END IF 
      
      OUTPUT TO REPORT pol1035_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1035_relat   
   
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

#------------------------------#
FUNCTION pol1035_escolhe_saida()
#------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1035.tmp"
         START REPORT pol1035_relat TO p_caminho
      ELSE
         START REPORT pol1035_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1035_le_empresa()
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
 REPORT pol1035_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
      
      FIRST PAGE HEADER  
      
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1035",
               COLUMN 013, "REPRESENTANTES QUE ATINGIRAM A META",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '          Codigo              Descrição               Ano  Mes'
         PRINT COLUMN 001, '          ------ ------------------------------------ ---- ---'
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1035",
               COLUMN 013, "REPRESENTANTES QUE ATINGIRAM A META",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '          Codigo              Descrição               Ano  Mes'
         PRINT COLUMN 001, '          ------ ------------------------------------ ---- ---'
                            
      ON EVERY ROW

         PRINT COLUMN 013, p_repres_meta_444.cod_repres USING "####",
               COLUMN 018, p_raz_social,
               COLUMN 055, p_repres_meta_444.ano        USING "####",
               COLUMN 061, p_repres_meta_444.mes        USING "##"
         

      ON LAST ROW

        LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-----------------------#
 FUNCTION pol1035_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#