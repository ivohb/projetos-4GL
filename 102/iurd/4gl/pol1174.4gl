#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1174                                                 #
# OBJETIVO: CADASTRO DE UNIDADE FUNCIONAL ISENTA DE APROVAÇÃO.      #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 18/09/12                                                #
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
          p_dat_atu            DATETIME YEAR TO SECOND
         
  
   DEFINE pr_unid              ARRAY[100] OF RECORD
          cod_uni_funcio       CHAR(10),
          den_uni_funcio       CHAR(30)
   END RECORD

   DEFINE p_empresa            CHAR(02),
          p_empresaa           CHAR(02)
          
END GLOBALS

DEFINE parametro     RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1174-10.02.03"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET parametro.num_programa = 'POL1174'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user
      
   IF p_status = 0 THEN
      CALL pol1174_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1174_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1174") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1174 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_dat_atu = CURRENT

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1174_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1174_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1174_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1174_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1174_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_empresa TO cod_empresa
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1174_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1174_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1174

END FUNCTION

#-----------------------#
 FUNCTION pol1174_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')

END FUNCTION

#--------------------------#
 FUNCTION pol1174_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE pr_unid TO NULL
   INITIALIZE p_empresa TO NULL
   LET p_opcao = 'I'
   
   IF pol1174_edita_dados() THEN      
      IF pol1174_edita_unid('I') THEN      
         IF pol1174_grava_dados() THEN                                                     
            RETURN TRUE                                                                    
         END IF                                                                      
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1174_edita_dados()
#-----------------------------#
   
   LET INT_FLAG = FALSE
   
   INPUT p_empresa WITHOUT DEFAULTS
    FROM empresa
            
      AFTER FIELD empresa
      IF p_empresa IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD empresa   
      END IF
                            
      SELECT den_empresa
        INTO p_den_empresa
        FROM empresa
       WHERE cod_empresa = p_empresa
       
      IF STATUS = 100 THEN
         LET p_msg = "Empresa não cadastrada !!!"
         CALL log0030_mensagem(p_msg,'exclamation')
         NEXT FIELD empresa
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','empresa')
            RETURN FALSE
         END IF 
      END IF

      DISPLAY p_den_empresa TO den_empresa
      
      LET p_count = 0
      
      SELECT COUNT(empresa)
        INTO p_count
        FROM unid_isenta_265
       WHERE empresa = p_empresa
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','unid_isenta_265')
         RETURN FALSE
      END IF 
  
      IF p_count > 0 THEN
         LET p_msg = "Já existe unid funcional p/ a empresa - Use modificar"
         CALL log0030_mensagem(p_msg,'exclamation')
         NEXT FIELD empresa
      END IF
      
      ON KEY (control-z)
         CALL pol1174_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1174_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(empresa)
         CALL log009_popup(8,10,"EMPRESAS","empresa",
              "cod_empresa","den_empresa","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_empresa = p_codigo CLIPPED
            DISPLAY p_codigo TO empresa
         END IF

      WHEN INFIELD(cod_uni_funcio)
         LET p_codigo = pol1174_le_unid()
         
         IF p_codigo IS NOT NULL THEN
            LET pr_unid[p_index].cod_uni_funcio = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_unid[s_index].cod_uni_funcio
         END IF

   END CASE 

END FUNCTION 

#-------------------------#
FUNCTION pol1174_le_unid()#
#-------------------------#

   DEFINE pr_pop_eve           ARRAY[1000] OF RECORD
          cod_uni_funcio       LIKE uni_funcional.cod_uni_funcio,
          den_uni_funcio       LIKE uni_funcional.den_uni_funcio
   END RECORD

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1174a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1174a AT 5,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   
   LET p_ind = 1
   
   DECLARE cq_pop_eve CURSOR FOR
    SELECT DISTINCT
           cod_uni_funcio,
           den_uni_funcio
      FROM uni_funcional
     WHERE cod_empresa = p_empresa
       AND dat_validade_fim > p_dat_atu
     ORDER BY den_uni_funcio
   
   FOREACH cq_pop_eve INTO 
           pr_pop_eve[p_ind].cod_uni_funcio,
           pr_pop_eve[p_ind].den_uni_funcio
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_pop_eve')           
         RETURN FALSE
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 1000 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou!','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
      
   DISPLAY ARRAY pr_pop_eve TO sr_pop_eve.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol1174a
   
   IF NOT INT_FLAG THEN
      RETURN pr_pop_eve[p_ind].cod_uni_funcio
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#-------------------------------------#
 FUNCTION pol1174_edita_unid(p_funcao)
#-------------------------------------#     

   DEFINE p_funcao CHAR(01)
   
   INPUT ARRAY pr_unid
      WITHOUT DEFAULTS FROM sr_unid.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
      AFTER FIELD cod_uni_funcio
      
      IF pr_unid[p_index].cod_uni_funcio IS NOT NULL THEN
                    
         LET p_count = 0                                                                                        
                                                                                                                
         DECLARE cq_unid_f CURSOR FOR                                                                           
          SELECT den_uni_funcio
            FROM uni_funcional
           WHERE cod_empresa    = p_empresa
             AND cod_uni_funcio = pr_unid[p_index].cod_uni_funcio
             AND dat_validade_fim > p_dat_atu
                                                                                                                
         FOREACH cq_unid_f                                                                                      
            INTO pr_unid[p_index].den_uni_funcio                                                                 
                                                                                                                
            IF STATUS <> 0 THEN                                                                                 
               CALL log003_err_sql('lendo','uni_funcional')                                                            
               RETURN FALSE                                                                                     
            END IF                                                                                              
                                                                                                                
            LET p_count = 1                                                                                     
                                                                                                                
            EXIT FOREACH                                                                                        
                                                                                                                
         END FOREACH                                                                                            
                                                                                                                
         IF p_count = 0 THEN                                                                                    
            LET p_msg = "Unidade funcional não cadastrado !!!"
            CALL log0030_mensagem(p_msg,'exclamation')
            NEXT FIELD cod_uni_funcio                                                                               
         END IF                                                                                                 
                                                                                                                                                                                                                                
         DISPLAY pr_unid[p_index].den_uni_funcio TO sr_unid[s_index].den_uni_funcio                               

         FOR p_ind = 1 TO ARR_COUNT()                                                                        
            IF p_ind <> p_index THEN                                                                            
               IF pr_unid[p_ind].cod_uni_funcio = pr_unid[p_index].cod_uni_funcio THEN    
                  LET p_msg = "Unidade já informada para esse usuário !!!"     
                  CALL log0030_mensagem(p_msg,'exclamation')                                          
                  NEXT FIELD cod_uni_funcio   
               END IF                                                                                           
            END IF                                                                                              
         END FOR                                                                                                
         
      END IF
         
      AFTER ROW
         IF NOT INT_FLAG THEN                                    
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN    
            ELSE
               IF pr_unid[p_index].cod_uni_funcio IS NULL THEN
                  ERROR 'Campo com preenchimento obrigatório !!!'
                  NEXT FIELD cod_uni_funcio
               END IF
            END IF
         END IF
                   
      ON KEY (control-z)
         CALL pol1174_popup()
                 
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      IF p_funcao = 'I' THEN
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
      ELSE
        CALL pol1174_carrega_itens() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
         
END FUNCTION

#-----------------------------#
 FUNCTION pol1174_grava_dados()
#-----------------------------#
   
   DEFINE p_incluiu SMALLINT

   DROP TABLE uni_temp_265
   
   CREATE TEMP TABLE uni_temp_265(
	    cod_uni_funcio       CHAR(10)
   )
   
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","UNI_TEMP_265")
			RETURN FALSE
	 END IF

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_unid[p_ind].cod_uni_funcio IS NOT NULL THEN
          INSERT INTO uni_temp_265 VALUES(pr_unid[p_ind].cod_uni_funcio)

          IF STATUS <> 0 THEN
             CALL log003_err_sql("INSERT", "uni_temp_265")
             RETURN FALSE
          END IF 
       END IF 
   END FOR
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1174_ins_audit() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 

   LET p_incluiu = FALSE
   
   DELETE FROM unid_isenta_265
    WHERE empresa = p_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "unid_isenta_265")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
      
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_unid[p_ind].cod_uni_funcio IS NOT NULL THEN
          
		       INSERT INTO unid_isenta_265
		       VALUES (p_empresa,
		               pr_unid[p_ind].cod_uni_funcio)
		
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Incluindo", "unid_isenta_265")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
		       LET p_incluiu = TRUE
       END IF
   END FOR

   CALL log085_transacao("COMMIT")	      
   
   IF p_opcao = "I" THEN
      IF NOT p_incluiu THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
      
END FUNCTION

#---------------------------#
FUNCTION pol1174_ins_audit()#
#---------------------------#

   DEFINE p_cod_unidade CHAR(10)
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_unid[p_ind].cod_uni_funcio IS NOT NULL THEN
          SELECT cod_uni_funcio
            FROM unid_isenta_265
           WHERE empresa = p_empresa
             AND cod_uni_funcio = pr_unid[p_ind].cod_uni_funcio
          IF STATUS = 100 THEN
             LET parametro.texto = 'INCLUSAO DE UNIDADE FUNCIONAL ', 
                 pr_unid[p_ind].cod_uni_funcio CLIPPED, ' P/ A EMPRESA ', p_empresa 
             IF NOT pol1161_grava_auadit(parametro) THEN
                RETURN FALSE
             END IF
          END IF
       END IF
   END FOR

   DECLARE cq_del CURSOR FOR
    SELECT cod_uni_funcio
      FROM unid_isenta_265
     WHERE empresa = p_empresa
       AND cod_uni_funcio NOT IN (SELECT cod_uni_funcio FROM uni_temp_265)
   
   FOREACH cq_del INTO p_cod_unidade
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_DEL')
         RETURN FALSE
      END IF
      
      LET parametro.texto = 'EXCLUSAO DE UNIDADE FUNCIONAL ', 
            p_cod_unidade CLIPPED, ' DA EMPRESA ', p_empresa 
      IF NOT pol1161_grava_auadit(parametro) THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION   
      
#--------------------------#
 FUNCTION pol1174_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_empresaa = p_empresa
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      unid_isenta_265.empresa
      
      ON KEY (control-z)
         CALL pol1174_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_empresa = p_empresaa
         CALL pol1174_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT DISTINCT empresa ",
                  "  FROM unid_isenta_265 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY empresa"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_empresa

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1174_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1174_exibe_dados()
#------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_empresa
       
   IF STATUS <> 0 THEN 
      LET p_den_empresa = ''
   END IF

   DISPLAY p_empresa TO empresa
   DISPLAY p_den_empresa TO den_empresa
        
   LET p_index = 1

   IF NOT pol1174_carrega_itens() THEN
      RETURN FALSE
   END IF

   CALL SET_COUNT(p_index - 1)
   
   IF p_index > 11 THEN
      DISPLAY ARRAY pr_unid TO sr_unid.*
   ELSE
      INPUT ARRAY pr_unid WITHOUT DEFAULTS FROM sr_unid.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol1174_carrega_itens()
#---------------------------------#
   
   INITIALIZE pr_unid TO NULL
   
   DECLARE cq_array CURSOR FOR
    SELECT DISTINCT
           a.cod_uni_funcio,
           b.den_uni_funcio
      FROM unid_isenta_265 a
           LEFT OUTER JOIN uni_funcional b
              ON b.cod_empresa = a.empresa
             AND b.cod_uni_funcio = a.cod_uni_funcio
             AND b.dat_validade_fim > p_dat_atu
     WHERE a.empresa = p_empresa 
     ORDER BY a.cod_uni_funcio
     
   FOREACH cq_array
      INTO pr_unid[p_index].cod_uni_funcio,
           pr_unid[p_index].den_uni_funcio
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "cursor: cq_array")
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 100 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol1174_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_empresaa = p_empresa

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_empresa
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_empresa
         
      END CASE

      IF STATUS = 0 THEN
         
         IF p_empresa = p_empresaa THEN
            CONTINUE WHILE
         END IF
         
         LET p_count = 0
         
         SELECT COUNT(empresa)
           INTO p_count
           FROM unid_isenta_265
          WHERE empresa  = p_empresa
                        
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "unid_isenta_265")
            RETURN
         END IF
         
         IF p_count > 0 THEN   
            CALL pol1174_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_empresa = p_empresaa
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1174_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT empresa 
      FROM unid_isenta_265  
     WHERE empresa = p_empresa 
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","unid_isenta_265")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1174_modificacao()
#-----------------------------#
   
   IF p_empresa IS NULL THEN
      LET p_msg = 'Não a dados na tela, p/ serem modificados!'
      CALL log0030_mensagem(p_msg, 'exclamation')
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'
   
   IF pol1174_prende_registro() THEN
      IF pol1174_edita_unid('M') THEN
         IF pol1174_grava_dados() THEN
            LET p_retorno = TRUE
         END IF
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
 FUNCTION pol1174_exclusao()
#--------------------------#

   IF p_empresa IS NULL THEN
      LET p_msg = 'Não a dados na tela, p/ serem modificados!'
      CALL log0030_mensagem(p_msg, 'exclamation')
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1174_prende_registro() THEN

     FOR p_ind = 1 TO ARR_COUNT()
       IF pr_unid[p_ind].cod_uni_funcio IS NOT NULL THEN
          LET parametro.texto = 'EXCLUSAO DA UNIDADE FUNCIONAL ', 
              pr_unid[p_ind].cod_uni_funcio CLIPPED, ' DA EMPRESA ', p_empresa 
          IF NOT pol1161_grava_auadit(parametro) THEN
             RETURN FALSE
          END IF
       END IF
     END FOR

      DELETE FROM unid_isenta_265
			 WHERE empresa = p_empresa
         
      IF STATUS = 0 THEN               
         INITIALIZE p_empresa TO NULL
         INITIALIZE pr_unid TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE 
      ELSE
         CALL log003_err_sql("Excluindo","unid_isenta_265")
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

{
#--------------------------#
 FUNCTION pol1174_listagem()
#--------------------------#     

   IF NOT pol1174_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1174_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_empresa,
          cod_uni_funcio,
          tip_evento,
          estado
     FROM unid_isenta_265
 ORDER BY cod_empresa, cod_uni_funcio                          
  
   FOREACH cq_impressao 
      INTO p_empresa,
           p_cod_uni_funcio,
           p_tip_evento,
           p_estado
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT nom_banco
        INTO p_den_empresa
        FROM bancos
       WHERE cod_empresa = p_empresa
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'bancos')
         RETURN
      END IF                                                             
                                                                                       
      DECLARE cq_listar_evento CURSOR FOR                                               
                                                                                       
       SELECT den_uni_funcio                                                         
         FROM evento                                                             
        WHERE cod_uni_funcio = p_cod_uni_funcio                        
                                                                                       
      FOREACH cq_listar_evento                                                          
         INTO p_den_uni_funcio                                     
                                                                                       
         IF STATUS <> 0 THEN                                                     
            CALL log003_err_sql('lendo','evento')                                
            RETURN FALSE                                                         
         END IF                                                                                                                           
                                                                                       
         EXIT FOREACH                                                            
                                                                                       
      END FOREACH
      
      IF p_tip_evento = '1'THEN
         LET p_den_tipo = "Desconto da parcela de empréstimo"
      ELSE
         IF p_tip_evento = '2' THEN
            LET p_den_tipo = "Desconto de rescisão"
         ELSE
            IF p_tip_evento = '3' THEN
               LET p_den_tipo = "Desconto de afastamento pelo INSS"
            ELSE
               LET p_den_tipo = "Reembolso"
            END IF
         END IF
      END IF
      
   OUTPUT TO REPORT pol1174_relat(p_empresa) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1174_relat   
   
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
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1174_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1174.tmp"
         START REPORT pol1174_relat TO p_caminho
      ELSE
         START REPORT pol1174_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1174_le_den_empresa()
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
 REPORT pol1174_relat(p_empresa)
#--------------------------------#
    
   DEFINE p_empresa LIKE bancos.cod_empresa
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1174",
               COLUMN 013, "EVENTOS PARA EMPRESTIMOS CONSIGNADOS",
               COLUMN 053, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "---------------------------------------------------------------------------------"
         PRINT
               
      BEFORE GROUP OF p_empresa
         
         PRINT
         PRINT COLUMN 003, "Banco: ", p_empresa, " - ", p_den_empresa
         PRINT
         PRINT COLUMN 002, 'Estado Evento      Descricao       Tipo           Descricao'
         PRINT COLUMN 002, '------ ------ -------------------- ---- ---------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 004, p_estado,
               COLUMN 010, p_cod_uni_funcio   USING "#####",
               COLUMN 016, p_den_uni_funcio,
               COLUMN 040, p_tip_evento   USING "#",
               COLUMN 042, p_den_tipo
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA BL-----------------------------#
