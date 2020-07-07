#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1240                                                 #
# OBJETIVO: USU�RIOS PARA EMAIL NA ABERTURA DE OS                   #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 11/11/2013                                              #
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

DEFINE p_den_grp_atividade    LIKE grupo_ativ.den_grp_atividade,
       p_nom_funcionario      like usuarios.nom_funcionario

DEFINE p_usuario   RECORD 
  cod_empresa        char(02),
  nom_usuario        char(08),
  ies_tip_os         char(01)
END RECORD

DEFINE p_usuarioa  RECORD 
  cod_empresa        char(02),
  nom_usuario        char(08),
  ies_tip_os         char(01)
END RECORD

DEFINE p_relat   RECORD
    cod_empresa  CHAR(02),
    nom_usuario  CHAR(08),
    ies_tip_os   char(01)
END RECORD

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
   LET p_versao = "pol1240-10.02.01"
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

   LET parametro.num_programa = 'POL1240'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user
      
   IF p_status = 0 THEN
      CALL pol1240_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1240_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1240") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1240 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1240_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1240_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1240_paginacao("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1240_paginacao("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1240_modificacao() RETURNING p_status  
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
            CALL pol1240_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclus�o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclus�o !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1240_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
				CALL pol1240_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1240

END FUNCTION

#-----------------------#
 FUNCTION pol1240_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1240_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1240_inclusao()
#--------------------------#

   CALL pol1240_limpa_tela()
   
   INITIALIZE p_usuario TO NULL
   LET p_usuario.cod_empresa = p_cod_empresa
   
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE
   
   IF pol1240_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1240_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1240_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1240_insere()
#------------------------#

   INSERT INTO usuario_manut_ind_1099 VALUES (p_usuario.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","usuario_manut_ind_1099")       
      RETURN FALSE
   END IF

   LET parametro.texto = 'INCLUSAO DO USUARIO ', p_usuario.nom_usuario 
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1240_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_usuario.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD nom_usuario

         IF p_funcao = "M" THEN
            NEXT FIELD ies_tip_os
         END IF
      
      AFTER FIELD nom_usuario

         IF p_usuario.nom_usuario IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD nom_usuario   
         END IF
         
         CALL pol1240_le_usuarios(p_usuario.nom_usuario)
          
         IF p_nom_funcionario IS NULL THEN 
            ERROR 'Usu�rio inexistente no Logix'
            NEXT FIELD nom_usuario
         END IF  
         
         DISPLAY p_nom_funcionario TO nom_funcionario


      AFTER FIELD ies_tip_os

         IF p_usuario.ies_tip_os IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD ies_tip_os   
         END IF
         
         IF p_usuario.ies_tip_os MATCHES '[ENP}' THEN
         ELSE
            ERROR 'Informe N/P/E'
            NEXT FIELD ies_tip_os
         END IF
         
         SELECT ies_tip_os
           FROM usuario_manut_ind_1099
          WHERE cod_empresa = p_cod_empresa
            AND nom_usuario = p_usuario.nom_usuario
            AND ies_tip_os = p_usuario.ies_tip_os
         
         IF STATUS = 0 THEN
            ERROR 'Registro j� cadastradO no pol1240.'
            NEXT FIELD nom_usuario   
         END IF

      ON KEY (control-z)
         CALL pol1240_popup()
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1240_le_usuarios(p_cod)#
#------------------------------------#
   
   DEFINE p_cod CHAR(10)
   
   SELECT nom_funcionario
     INTO p_nom_funcionario
     FROM usuarios
    WHERE cod_usuario = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_nom_funcionario = NULL
   END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol1240_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(nom_usuario)
         CALL log009_popup(8,10,"USU�RIOS LOGIX","usuarios",
              "cod_usuario","nom_funcionario","","N"," 1=1 order by cod_usuario") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_usuario.nom_usuario = p_codigo CLIPPED
            DISPLAY p_codigo TO nom_usuario
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1240_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1240_limpa_tela()
   LET p_usuarioa.* = p_usuario.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      usuario_manut_ind_1099.nom_usuario,     
      usuario_manut_ind_1099.ies_tip_os
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1240_limpa_tela()
         ELSE
            LET p_usuario.* = p_usuarioa.*
            CALL pol1240_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM usuario_manut_ind_1099 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY nom_usuario"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_usuario.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1240_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1240_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_usuario.*
   
   CALL pol1240_le_usuarios(p_usuario.nom_usuario)
   DISPLAY p_nom_funcionario TO nom_funcionario
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1240_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01),
          p_emp_lida CHAR(02)

   LET p_usuarioa.* = p_usuario.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_usuario.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_usuario.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT *
         INTO p_usuario.*
         FROM usuario_manut_ind_1099
        WHERE cod_empresa = p_cod_empresa
          AND nom_usuario = p_usuario.nom_usuario
          AND ies_tip_os = p_usuario.ies_tip_os
            
         IF STATUS = 0 THEN
            CALL pol1240_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "N�o existem mais itens nesta dire��o !!!"
            LET p_usuario.* = p_usuarioa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1240_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT ies_tip_os 
      FROM usuario_manut_ind_1099  
     WHERE cod_empresa = p_cod_empresa
       AND nom_usuario = p_usuario.nom_usuario
       AND ies_tip_os = p_usuario.ies_tip_os
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","usuario_manut_ind_1099")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1240_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("N�o h� dados � serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1240_prende_registro() THEN
      IF pol1240_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
      LET p_usuario.* = p_usuarioa.*
      CALL pol1240_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE usuario_manut_ind_1099
      SET ies_tip_os = p_usuario.ies_tip_os
    WHERE CURRENT OF cq_prende

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "usuario_manut_ind_1099")
      RETURN FALSE
   END IF

   LET parametro.texto = 'ALTERACAO DO USUARIO ', p_usuario.nom_usuario 
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1240_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("N�o h� dados � serem exclu�dos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1240_prende_registro() THEN
      IF pol1240_deleta() THEN
         INITIALIZE p_usuario TO NULL
         CALL pol1240_limpa_tela()
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
FUNCTION pol1240_deleta()
#------------------------#

   DELETE FROM usuario_manut_ind_1099
    WHERE cod_empresa = p_cod_empresa
      AND nom_usuario = p_usuario.nom_usuario
      AND ies_tip_os = p_usuario.ies_tip_os

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","usuario_manut_ind_1099")
      RETURN FALSE
   END IF

   LET parametro.texto = 'EXCLUSAO DO USUARIO ', p_usuario.nom_usuario 
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1240_listagem()
#--------------------------#     

   IF NOT pol1240_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1240_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT *
      FROM usuario_manut_ind_1099 
     ORDER BY nom_usuario
  
   FOREACH cq_impressao INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
       
      CALL pol1240_le_usuarios(p_relat.nom_usuario)
      
      OUTPUT TO REPORT pol1240_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1240_relat   
   
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
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relat�rio gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1240_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1240.tmp"
         START REPORT pol1240_relat TO p_caminho
      ELSE
         START REPORT pol1240_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1240_le_den_empresa()
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
 REPORT pol1240_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 078, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1240",
               COLUMN 010, "UAUAARIOS PARA AMAILS DE OS",
               COLUMN 058, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'USUARIO  NOME                                     TIPO OS'
         PRINT COLUMN 001, '-------- ---------------------------------------- ----------'

      ON EVERY ROW
         PRINT COLUMN 001, p_relat.nom_usuario,
               COLUMN 010, p_nom_funcionario,
               COLUMN 055, p_relat.ies_tip_os
                              
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