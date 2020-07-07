#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1182                                                 #
# OBJETIVO: CADASTRO USUÁRIO ADMINISTRADOR DO CONTROLE DE ALÇADA.   #
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
          p_nom_usuario        CHAR(08),
          p_nom_funcionario    CHAR(40)
  
   DEFINE pr_usuario           ARRAY[100] OF RECORD
          nom_usuario          CHAR(08),
          nom_funcionario      CHAR(40)
   END RECORD

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
   LET p_versao = "pol1182-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET parametro.num_programa = 'POL1182'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user

   IF p_status = 0 THEN
      CALL pol1182_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1182_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1182") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1182 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1182_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1182_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1182_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Listar" "Listagem dos dados"
				CALL pol1182_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1182_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1182

END FUNCTION

#-----------------------#
 FUNCTION pol1182_sobre()
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
 FUNCTION pol1182_inclusao()
#--------------------------#

   LET p_opcao = 'I'

   IF NOT p_ies_cons THEN
      CALL pol1182_carrega_dados()
      CALL SET_COUNT(p_index - 1)
   END IF
   
   IF pol1182_edita_dados() THEN      
      IF pol1182_grava_dados() THEN                                                     
         RETURN TRUE                                                                    
      END IF
   END IF
   
   LET p_ies_cons = TRUE
   
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1182_modificacao()
#-----------------------------#
   
   LET p_opcao   = 'M'
   
   IF pol1182_edita_dados() THEN      
      IF pol1182_grava_dados() THEN                                                     
         RETURN TRUE                                                                    
      END IF
   END IF

   RETURN FALSE

END FUNCTION


#-----------------------#
 FUNCTION pol1182_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(nom_usuario)
         CALL log009_popup(8,10,"USUARIOS","usuarios",
              "cod_usuario","nom_funcionario","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET pr_usuario[p_index].nom_usuario = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_usuario[s_index].nom_usuario
         END IF

   END CASE 

END FUNCTION 

#------------------------------#
 FUNCTION pol1182_edita_dados()#
#------------------------------#     
   
   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_usuario
      WITHOUT DEFAULTS FROM sr_usuario.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
      AFTER FIELD nom_usuario
      
      IF pr_usuario[p_index].nom_usuario IS NOT NULL THEN
                    
         LET p_count = 0                                                                                        

         FOR p_ind = 1 TO ARR_COUNT()                                                                        
            IF p_ind <> p_index THEN                                                                            
               IF pr_usuario[p_ind].nom_usuario = pr_usuario[p_index].nom_usuario THEN    
                  LET p_msg = "Usuário já informado."     
                  CALL log0030_mensagem(p_msg,'information')                                          
                  NEXT FIELD nom_usuario   
               END IF                                                                                           
            END IF                                                                                              
         END FOR                                                                                                
                                                                                                                
         SELECT nom_funcionario
           INTO pr_usuario[p_index].nom_funcionario
           FROM usuarios
          WHERE cod_usuario = pr_usuario[p_index].nom_usuario
                                                                                                                
         IF STATUS = 100 THEN                                                                                 
            ERROR 'Usuário inexistente no Logix.'
            NEXT FIELD nom_usuario
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('lendo','usuarios')                                                            
               NEXT FIELD nom_usuario
            END IF                                                                                    
         END IF                                                                                              
                                                                                                                                                                                                                                
         DISPLAY pr_usuario[p_index].nom_funcionario TO sr_usuario[s_index].nom_funcionario                               

      END IF
         
      AFTER ROW
         IF NOT INT_FLAG THEN                                    
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN    
            ELSE
               IF pr_usuario[p_index].nom_usuario IS NULL THEN
                  ERROR 'Campo com preenchimento obrigatório !!!'
                  NEXT FIELD nom_usuario
               END IF
            END IF
         END IF
                   
      ON KEY (control-z)
         CALL pol1182_popup()
                 
   END INPUT 

   IF NOT INT_FLAG THEN
      RETURN TRUE
   ELSE
      CALL pol1182_carrega_dados() RETURNING p_status
      CALL pol1182_exibe_dados() RETURNING p_status
      RETURN FALSE
   END IF
         
END FUNCTION

#-----------------------------#
 FUNCTION pol1182_grava_dados()
#-----------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DELETE FROM usuario_adim_265
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "usuario_adim_265")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_usuario[p_ind].nom_usuario IS NOT NULL THEN
	        INSERT INTO usuario_adim_265
		       VALUES (pr_usuario[p_ind].nom_usuario)
		
		      IF STATUS <> 0 THEN 
		         CALL log003_err_sql("Incluindo", "usuario_adim_265")
		         CALL log085_transacao("ROLLBACK")
		         RETURN FALSE
		      END IF
       END IF
   END FOR

   IF p_opcao = 'I' THEN
      LET parametro.texto = 'INCLUSAO D USUARIO ADMINISTRADOR '
   ELSE
      LET parametro.texto = 'ALTERACAO D USUARIO ADMINISTRADOR '
   END IF
   
   CALL pol1161_grava_auadit(parametro) RETURNING p_status

   CALL log085_transacao("COMMIT")	      
   
   RETURN TRUE
      
END FUNCTION

#--------------------------#
 FUNCTION pol1182_consulta()
#--------------------------#
   
   IF NOT pol1182_carrega_dados() THEN
      RETURN FALSE
   END IF

   LET p_ies_cons = TRUE
   
   IF p_index > 1 THEN 
      CALL pol1182_exibe_dados() RETURNING p_status
   ELSE
      LET p_msg = 'Não usuários cadastrados.\n',
                  'Utilize a opção Incluir.'
      CALL log0030_mensagem(p_msg,'information')
   END IF    
   
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol1182_exibe_dados()
#------------------------------#

   CALL SET_COUNT(p_index - 1)
   
   IF p_index > 13 THEN
      DISPLAY ARRAY pr_usuario TO sr_usuario.*
   ELSE
      INPUT ARRAY pr_usuario WITHOUT DEFAULTS FROM sr_usuario.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1182_carrega_dados()
#-------------------------------#
   
   INITIALIZE pr_usuario TO NULL
   LET p_ies_cons = TRUE
   LET p_index = 1
   
   DECLARE cq_user CURSOR FOR
    SELECT a.nom_usuario, b.nom_funcionario 
      FROM usuario_adim_265 a, usuarios b
     WHERE a.nom_usuario = b.cod_usuario
     ORDER BY a.nom_usuario

   FOREACH cq_user INTO 
      pr_usuario[p_index].nom_usuario,
      pr_usuario[p_index].nom_funcionario

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_padrao')
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

#--------------------------#
 FUNCTION pol1182_listagem()
#--------------------------#     

   IF NOT pol1182_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1182_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT a.nom_usuario, b.nom_funcionario 
      FROM usuario_adim_265 a, usuarios b
     WHERE a.nom_usuario = b.cod_usuario
     ORDER BY a.nom_usuario
  
   FOREACH cq_impressao 
      INTO p_nom_usuario,
           p_nom_funcionario
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      OUTPUT TO REPORT pol1182_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1182_relat   
   
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
 FUNCTION pol1182_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1182.tmp"
         START REPORT pol1182_relat TO p_caminho
      ELSE
         START REPORT pol1182_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1182_le_den_empresa()
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

#----------------------#
 REPORT pol1182_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 078, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1182",
               COLUMN 010, "USUARIOS ADMINISTRADORES DA GRADE DE APROVACAO",
               COLUMN 058, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'USUARIO  FUNCIONARIO'
         PRINT COLUMN 001, '-------- ----------------------------------------'
               
      ON EVERY ROW

         PRINT COLUMN 001, p_nom_usuario,
               COLUMN 010, p_nom_funcionario
                              
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
