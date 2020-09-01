#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1023                                                 #
# OBJETIVO: PARÂMETROS DE COMISSÕES                                 #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 17/03/10                                                #
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
         
  
   DEFINE p_par_comis_444        RECORD LIKE par_comis_444.*

   DEFINE p_cod_tip_carteira     LIKE par_comis_444.cod_tip_carteira,
          p_cod_tip_carteira_ant LIKE par_comis_444.cod_tip_carteira,
          p_den_tip_carteira     LIKE tipo_carteira.den_tip_carteira
          
END GLOBALS

MAIN
   #CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1023-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1023_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1023_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1023") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1023 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1023_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol1023_inclusao() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = FALSE
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
          IF pol1023_consulta() THEN
            LET p_ies_cons = TRUE
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1023_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1023_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1023_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_tip_carteira TO cod_tip_carteira
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol1023_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem"
         CALL pol1023_listagem()  
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol1023_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1023

END FUNCTION

#----------------------------#
 FUNCTION pol1023_limpa_tela()
#----------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 
   
#--------------------------#
 FUNCTION pol1023_inclusao()
#--------------------------#
   
   IF pol1023_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO par_comis_444 VALUES (p_par_comis_444.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","par_comis_444")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#--------------------------------------#
 FUNCTION pol1023_edita_dados(p_funcao)
#--------------------------------------#

   DEFINE p_funcao CHAR(01)
   
   LET INT_FLAG = FALSE 
   
   INPUT BY NAME p_par_comis_444.* WITHOUT DEFAULTS
      
      BEFORE FIELD cod_tip_carteira
      IF p_funcao = "M" THEN 
         DISPLAY p_cod_tip_carteira TO cod_tip_carteira
         NEXT FIELD comis_prod_normal
      ELSE
         CALL pol1023_limpa_tela()
         INITIALIZE p_par_comis_444.* TO NULL
         LET p_par_comis_444.cod_empresa = p_cod_empresa
      END IF 
      
      AFTER FIELD cod_tip_carteira
      IF p_par_comis_444.cod_tip_carteira IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_tip_carteira   
      END IF
          
      SELECT den_tip_carteira
        INTO p_den_tip_carteira
        FROM tipo_carteira
       WHERE cod_tip_carteira = p_par_comis_444.cod_tip_carteira
      
      IF STATUS = 100 THEN 
         ERROR 'Carteira não cadastrada na tabela tipo_carteira !!!'
         NEXT FIELD cod_tip_carteira
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','tipo_carteira')
            NEXT FIELD cod_tip_carteira
         END IF 
      END IF
      
      SELECT cod_tip_carteira
        FROM par_comis_444
       WHERE cod_empresa      = p_cod_empresa
         AND cod_tip_carteira = p_par_comis_444.cod_tip_carteira
          
      IF STATUS = 0 THEN 
         ERROR 'Carteira já cadastrada na tabela par_comis_444 !!!'
         NEXT FIELD cod_tip_carteira
      ELSE
         IF STATUS <> 100 THEN 
            CALL log003_err_sql('lendo','par_comis_444')
            NEXT FIELD cod_tip_carteira
         END IF 
      END IF  
      
      DISPLAY p_den_tip_carteira TO den_tip_carteira
      
      AFTER FIELD comis_prod_normal
      IF p_par_comis_444.comis_prod_normal IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD comis_prod_normal   
      END IF
      
      IF p_par_comis_444.comis_prod_normal < 0 OR
         p_par_comis_444.comis_prod_normal > 100 THEN 
         ERROR "valor ilegal para o campo em questão !!!"
         NEXT FIELD comis_prod_normal   
      END IF
      
      AFTER FIELD comis_prod_novo
      IF p_par_comis_444.comis_prod_novo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD comis_prod_novo   
      END IF
      
      IF p_par_comis_444.comis_prod_novo < 0 OR
         p_par_comis_444.comis_prod_novo > 100 THEN 
         ERROR "valor ilegal para o campo em questão !!!"
         NEXT FIELD comis_prod_novo   
      END IF
      
      AFTER FIELD comis_acres_normal
      IF p_par_comis_444.comis_acres_normal IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD comis_acres_normal   
      END IF
      
      IF p_par_comis_444.comis_acres_normal < 0 OR
         p_par_comis_444.comis_acres_normal > 100 THEN 
         ERROR "valor ilegal para o campo em questão !!!"
         NEXT FIELD comis_acres_normal   
      END IF
      
      AFTER FIELD comis_acres_novo
      IF p_par_comis_444.comis_acres_novo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD comis_acres_novo   
      END IF
      
      IF p_par_comis_444.comis_acres_novo < 0 OR
         p_par_comis_444.comis_acres_novo > 100 THEN
         ERROR "valor ilegal para o campo em questão !!!"
         NEXT FIELD comis_acres_novo   
      END IF
      
      ON KEY (control-z)
         CALL pol1023_popup()
      
   END INPUT 

   IF INT_FLAG  THEN
      CALL pol1023_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1023_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     WHEN INFIELD(cod_tip_carteira)
         CALL log009_popup(8,10,"CARTEIRAS","tipo_carteira",
                     "cod_tip_carteira","den_tip_carteira","","S","")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_par_comis_444.cod_tip_carteira = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_tip_carteira
         END IF
     
   END CASE 

END FUNCTION 
  
#--------------------------#
 FUNCTION pol1023_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1023_limpa_tela()
      
   LET p_cod_tip_carteira_ant = p_cod_tip_carteira
   LET INT_FLAG               = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      par_comis_444.cod_tip_carteira
      
      ON KEY (control-z)
         CALL pol1023_popup()
         
   END CONSTRUCT
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_tip_carteira = p_cod_tip_carteira_ant
         CALL pol1023_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT cod_tip_carteira",
                  "  FROM par_comis_444 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_tip_carteira"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_tip_carteira

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1023_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1023_exibe_dados()
#------------------------------#
   
   LET p_par_comis_444.cod_empresa      = p_cod_empresa
   LET p_par_comis_444.cod_tip_carteira = p_cod_tip_carteira
   
   SELECT comis_prod_normal, 
          comis_prod_novo,   
          comis_acres_normal,
          comis_acres_novo  
     INTO p_par_comis_444.comis_prod_normal,
          p_par_comis_444.comis_prod_novo,
          p_par_comis_444.comis_acres_normal,
          p_par_comis_444.comis_acres_novo
     FROM par_comis_444
    WHERE cod_empresa      = p_cod_empresa
      AND cod_tip_carteira = p_cod_tip_carteira 
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'par_comis_444')
      RETURN FALSE 
   END IF
   
   SELECT den_tip_carteira
     INTO p_den_tip_carteira
     FROM tipo_carteira
    WHERE cod_tip_carteira = p_par_comis_444.cod_tip_carteira
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','tipo_carteira')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_par_comis_444.*
   DISPLAY p_den_tip_carteira TO den_tip_carteira
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1023_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_tip_carteira_ant = p_cod_tip_carteira

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_tip_carteira
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_tip_carteira
         
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_tip_carteira
           FROM par_comis_444
          WHERE cod_empresa      = p_cod_empresa
            AND cod_tip_carteira = p_cod_tip_carteira
             
         IF STATUS = 0 THEN
            CALL pol1023_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_tip_carteira = p_cod_tip_carteira_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1023_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_tip_carteira 
      FROM par_comis_444  
     WHERE cod_empresa      = p_cod_empresa
       AND cod_tip_carteira = p_cod_tip_carteira
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","par_comis_444")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1023_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   IF pol1023_prende_registro() THEN
      IF pol1023_edita_dados("M") THEN
         UPDATE par_comis_444
            SET comis_prod_normal  = p_par_comis_444.comis_prod_normal,
                comis_prod_novo    = p_par_comis_444.comis_prod_novo,
                comis_acres_normal = p_par_comis_444.comis_acres_normal,
                comis_acres_novo   = p_par_comis_444.comis_acres_novo
          WHERE cod_empresa        = p_cod_empresa
            AND cod_tip_carteira   = p_cod_tip_carteira
             
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","par_comis_444")
         END IF
      ELSE
         CALL pol1023_exibe_dados() RETURNING p_status
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
 FUNCTION pol1023_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1023_prende_registro() THEN
      DELETE FROM par_comis_444
			WHERE cod_empresa      = p_cod_empresa
        AND cod_tip_carteira = p_cod_tip_carteira
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_par_comis_444 TO NULL
         CALL pol1023_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","par_comis_444")
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
FUNCTION pol1023_listagem()
#-------------------------#     

   IF NOT pol1023_escolhe_saida() THEN
   		RETURN 
   END IF
   
   IF NOT pol1023_le_empresa() THEN
      RETURN
   END IF 
      
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_tip_carteira,
          comis_prod_normal, 
          comis_prod_novo,   
          comis_acres_normal,
          comis_acres_novo  
     INTO p_par_comis_444.comis_prod_normal,
          p_par_comis_444.comis_prod_novo,
          p_par_comis_444.comis_acres_normal,
          p_par_comis_444.comis_acres_novo
     FROM par_comis_444
    WHERE cod_empresa      = p_cod_empresa
    ORDER BY cod_tip_carteira
   
   FOREACH cq_impressao INTO 
           p_par_comis_444.cod_tip_carteira,
           p_par_comis_444.comis_prod_normal,
           p_par_comis_444.comis_prod_novo,
           p_par_comis_444.comis_acres_normal,
           p_par_comis_444.comis_acres_novo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','par_comis_444:cq_impressao')
         EXIT FOREACH
      END IF      
      
      SELECT den_tip_carteira
        INTO p_den_tip_carteira
        FROM tipo_carteira
       WHERE cod_tip_carteira = p_par_comis_444.cod_tip_carteira
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','tipo_carteira')
         EXIT FOREACH
      END IF
      
      OUTPUT TO REPORT pol1023_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1023_relat   
   
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
FUNCTION pol1023_escolhe_saida()
#------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1023.tmp"
         START REPORT pol1023_relat TO p_caminho
      ELSE
         START REPORT pol1023_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1023_le_empresa()
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
 REPORT pol1023_relat()
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
               
         PRINT COLUMN 001, "pol1023",
               COLUMN 022, "CADASTRO DE COMISSOES",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, ' Carteira    Descricao    C. prd. nor. C. prd. nov. C. acrs. nor. C. acrs. nov.'
         PRINT COLUMN 001, ' -------- --------------- ------------ ------------ ------------- -------------'
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1023",
               COLUMN 022, "CADASTRO DE COMISSOES",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, ' Carteira    Descricao    C. prd. nor. C. prd. nov. C. acrs. nor. C. acrs. nov.'
         PRINT COLUMN 001, ' -------- --------------- ------------ ------------ ------------- -------------'
                            
      ON EVERY ROW

         PRINT COLUMN 008, p_par_comis_444.cod_tip_carteira,
               COLUMN 011, p_den_tip_carteira,
               COLUMN 033, p_par_comis_444.comis_prod_normal   USING "###.&&", 
               COLUMN 046, p_par_comis_444.comis_prod_novo     USING "###.&&",
               COLUMN 060, p_par_comis_444.comis_acres_normal  USING "###.&&",
               COLUMN 074, p_par_comis_444.comis_acres_novo    USING "###.&&"

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
 FUNCTION pol1023_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#