#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1246                                                 #
# OBJETIVO: PARÂMETROS PARA CONTROLE DE FRETE                       #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 20/10/13                                                #
# FUNÇÕES: FUNC002                                                  #
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


DEFINE p_par_frete   RECORD LIKE par_frete_455.*,
       p_par_fretea  RECORD LIKE par_frete_455.*
       
DEFINE p_relat   RECORD
      cod_empresa    CHAR(02),
      den_empresa    CHAR(40),
      dat_corte      DATE,
      pct_tolerancia DECIMAL(5,2),
      pct_seguro     DECIMAL(5,2)
END RECORD
          
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1246-10.02.03  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1246_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1246_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1246") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1246 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1246_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1246_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1246_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1246_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1246_modificacao() RETURNING p_status  
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
            CALL pol1246_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1246_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1246

END FUNCTION

#---------------------------#
FUNCTION pol1246_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1246_inclusao()
#--------------------------#

   CALL pol1246_limpa_tela()
   
   INITIALIZE p_par_frete TO NULL

   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1246_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1246_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1246_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1246_insere()
#------------------------#

   INSERT INTO par_frete_455 VALUES (p_par_frete.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","par_frete_455")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1246_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_par_frete.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD cod_empresa

         IF p_funcao = "M" THEN
            NEXT FIELD dat_corte
         END IF
      
      AFTER FIELD cod_empresa

         IF p_par_frete.cod_empresa IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_empresa   
         END IF
         
         SELECT cod_empresa
           FROM par_frete_455
          WHERE cod_empresa = p_par_frete.cod_empresa
         
         IF STATUS = 0 THEN
            ERROR 'Empresa já cadastrada no pol1246.'
            NEXT FIELD cod_empresa   
         END IF
          
         CALL pol1246_le_nom_empresa(p_par_frete.cod_empresa)
          
         IF p_den_empresa IS NULL THEN 
            ERROR 'Empresa inválida.'
            NEXT FIELD cod_empresa
         END IF  
         
         DISPLAY p_den_empresa TO den_empresa

      ON KEY (control-z)
         CALL pol1246_popup()

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            IF p_par_frete.dat_corte IS NULL THEN 
               ERROR "Preencha a data de corte"
               NEXT FIELD dat_corte   
            END IF

            IF p_par_frete.pct_tolerancia IS NULL THEN 
               ERROR "Preencha a % de tolerância"
               NEXT FIELD pct_tolerancia   
            END IF

            IF p_par_frete.pct_seguro IS NULL THEN 
               ERROR "Preencha o campo % de seguro"
               NEXT FIELD pct_seguro   
            END IF

         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1246_le_nom_empresa(p_cod)#
#-------------------------------------#
   
   DEFINE p_cod CHAR(10)
   
   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_den_empresa = NULL
   END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol1246_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_empresa)
         CALL log009_popup(8,10,"Empresas","empresa",
              "cod_empresa","den_empresa","","N"," 1=1 order by cod_empresa") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_par_frete.cod_empresa = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_empresa
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1246_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1246_limpa_tela()
   LET p_par_fretea.* = p_par_frete.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      par_frete_455.cod_empresa,     
      par_frete_455.dat_corte
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1246_limpa_tela()
         ELSE
            LET p_par_frete.* = p_par_fretea.*
            CALL pol1246_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM par_frete_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_empresa"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_par_frete.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1246_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1246_exibe_dados()
#------------------------------#

   DEFINE p_empresa CHAR(02)
   
   LET p_empresa = p_par_frete.cod_empresa
   
   SELECT *
     INTO p_par_frete.*
     FROM par_frete_455
    WHERE cod_empresa = p_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'p_par_frete')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_par_frete.*
   
   CALL pol1246_le_nom_empresa(p_par_frete.cod_empresa)
   DISPLAY p_den_empresa to den_empresa
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1246_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_par_fretea.* = p_par_frete.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_par_frete.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_par_frete.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_empresa
           FROM par_frete_455
          WHERE cod_empresa = p_par_frete.cod_empresa
            
         IF STATUS = 0 THEN
            IF pol1246_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_par_frete.* = p_par_fretea.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1246_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM par_frete_455  
     WHERE cod_empresa = p_par_frete.cod_empresa
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","par_frete_455")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1246_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET p_par_fretea.* = p_par_frete.*
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1246_prende_registro() THEN
      IF pol1246_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         LET p_par_frete.* = p_par_fretea.*
         CALL pol1246_exibe_dados() RETURNING p_status
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

   UPDATE par_frete_455
      SET dat_corte = p_par_frete.dat_corte,
          pct_tolerancia = p_par_frete.pct_tolerancia,
          pct_seguro = p_par_frete.pct_seguro
     WHERE cod_empresa = p_par_frete.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "par_frete_455")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1246_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1246_prende_registro() THEN
      IF pol1246_deleta() THEN
         INITIALIZE p_par_frete TO NULL
         CALL pol1246_limpa_tela()
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
FUNCTION pol1246_deleta()
#------------------------#

   DELETE FROM par_frete_455
    WHERE cod_empresa = p_par_frete.cod_empresa

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","par_frete_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1246_listagem()
#--------------------------#     

   IF NOT pol1246_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1246_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT a.cod_empresa, 
           b.den_empresa,
           a.dat_corte,
           a.pct_tolerancia,
           A.pct_seguro
      FROM par_frete_455 a, Empresa b
     WHERE a.cod_empresa = b.cod_empresa
     ORDER BY a.cod_empresa
  
   FOREACH cq_impressao 
      INTO p_relat.cod_empresa,
           p_relat.den_empresa,
           p_relat.dat_corte,
           p_relat.pct_tolerancia,
           p_relat.pct_seguro
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      OUTPUT TO REPORT pol1246_relat() 

      LET p_count = 1
      
   END FOREACH

   CALL pol1246_finaliza_relat()

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1246_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1246_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1246.tmp'
         START REPORT pol1246_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1246_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1246_le_den_empresa()
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
FUNCTION pol1246_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1246_relat   

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
 REPORT pol1246_relat()
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
               
         PRINT COLUMN 001, "pol1246",
               COLUMN 010, "PARAMETROS P/ CONTROLE DE FRETE",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'EMPRESA                                     DAT CORTE  % TOLERANCIA % SEGURO'                                
         PRINT COLUMN 001, '-- ---------------------------------------- ---------- ------------ --------'

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 076, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'EMPRESA                                     DAT CORTE  % TOLERANCIA % SEGURO'                                
         PRINT COLUMN 001, '-- ---------------------------------------- ---------- ------------ --------'

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.cod_empresa,
               COLUMN 004, p_relat.den_empresa,
               COLUMN 045, p_relat.dat_corte,
               COLUMN 056, p_relat.pct_tolerancia USING '##&,&&',
               COLUMN 063, p_relat.pct_seguro USING '##&,&&'
                              
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
