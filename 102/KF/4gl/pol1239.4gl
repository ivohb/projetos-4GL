#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1239                                                 #
# OBJETIVO: GRUPO DE ATIVIDADE P/ MANUTENÇÃO INDUSTRIAL             #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 04/11/2013                                              #
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
          p_excluiu            SMALLINT,
          p_nom_funcionario    CHAR(40)
         
END GLOBALS

DEFINE p_den_grp_atividade    LIKE grupo_ativ.den_grp_atividade

DEFINE p_grupo   RECORD 
  cod_grp_atividade  integer,
  cod_tip_manut      char(01)
END RECORD

DEFINE p_grupoa  RECORD 
  cod_grp_atividade  integer,
  cod_tip_manut      char(01)
END RECORD

DEFINE p_relat   RECORD
      cod_grp_atividade   CHAR(02),
      den_grp_atividade   CHAR(40),
      cod_tip_manut       CHAR(01),
      den_tip_manut       CHAR(15)
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
   LET p_versao = "pol1239-10.02.00"
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
   
   LET parametro.num_programa = 'POL1239'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user
      
   IF p_status = 0 THEN
      CALL pol1239_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1239_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1239") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1239 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1239_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1239_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1239_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1239_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1239_modificacao() RETURNING p_status  
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
            CALL pol1239_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1239_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1239_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1239

END FUNCTION

#-----------------------#
 FUNCTION pol1239_sobre()
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
FUNCTION pol1239_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1239_inclusao()
#--------------------------#

   CALL pol1239_limpa_tela()
   
   INITIALIZE p_grupo TO NULL

   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE
   LET p_grupo.cod_tip_manut = 'P'
   
   IF pol1239_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1239_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1239_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1239_insere()
#------------------------#

   INSERT INTO grupo_ativ_manut_ind_1099 VALUES (p_grupo.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","grupo_ativ_manut_ind_1099")       
      RETURN FALSE
   END IF

   LET parametro.texto = 'INCLUSAO DO GRUPO DE ATIVIDADE ', p_grupo.cod_grp_atividade 
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1239_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_grupo.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD cod_grp_atividade

         IF p_funcao = "M" THEN
            NEXT FIELD cod_tip_manut
         END IF
      
      AFTER FIELD cod_grp_atividade

         IF p_grupo.cod_grp_atividade IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_grp_atividade   
         END IF
         
         SELECT cod_tip_manut
           FROM grupo_ativ_manut_ind_1099
          WHERE cod_grp_atividade = p_grupo.cod_grp_atividade
         
         IF STATUS = 0 THEN
            ERROR 'Grupo já cadastradO no pol1239.'
            NEXT FIELD cod_grp_atividade   
         END IF
          
         CALL pol1239_le_nom_grupo(p_grupo.cod_grp_atividade)
          
         IF p_den_grp_atividade IS NULL THEN 
            ERROR 'Grupo de atividade inexistente no Logix'
            NEXT FIELD cod_grp_atividade
         END IF  
         
         DISPLAY p_den_grp_atividade TO den_grp_atividade

      ON KEY (control-z)
         CALL pol1239_popup()
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1239_le_nom_grupo(p_cod)#
#-----------------------------------#
   
   DEFINE p_cod CHAR(10)
   
   SELECT den_grp_atividade
     INTO p_den_grp_atividade
     FROM grupo_ativ
    WHERE cod_grp_atividade = p_cod
         
   IF STATUS <> 0 THEN 
      LET p_den_grp_atividade = NULL
   END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol1239_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_grp_atividade)
         CALL log009_popup(8,10,"GRUPO DE ATIVIDADE","grupo_ativ",
              "cod_grp_atividade","den_grp_atividade","","N"," 1=1 order by den_grp_atividade") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_grupo.cod_grp_atividade = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_grp_atividade
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1239_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1239_limpa_tela()
   LET p_grupoa.* = p_grupo.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      grupo_ativ_manut_ind_1099.cod_grp_atividade,     
      grupo_ativ_manut_ind_1099.cod_tip_manut
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1239_limpa_tela()
         ELSE
            LET p_grupo.* = p_grupoa.*
            CALL pol1239_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM grupo_ativ_manut_ind_1099 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_grp_atividade"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_grupo.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1239_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1239_exibe_dados()
#------------------------------#

   SELECT  *
     INTO p_grupo.*
     FROM grupo_ativ_manut_ind_1099
    WHERE cod_grp_atividade = p_grupo.cod_grp_atividade
       
   DISPLAY BY NAME p_grupo.*
   
   CALL pol1239_le_nom_grupo(p_grupo.cod_grp_atividade)
   DISPLAY p_den_grp_atividade to den_grp_atividade
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1239_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01),
          p_emp_lida CHAR(02)

   LET p_grupoa.* = p_grupo.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_grupo.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_grupo.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_tip_manut
           FROM grupo_ativ_manut_ind_1099
          WHERE cod_grp_atividade = p_grupo.cod_grp_atividade
            
         IF STATUS = 0 THEN
            CALL pol1239_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_grupo.* = p_grupoa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1239_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_tip_manut 
      FROM grupo_ativ_manut_ind_1099  
     WHERE cod_grp_atividade = p_grupo.cod_grp_atividade
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","grupo_ativ_manut_ind_1099")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1239_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   LET p_opcao   = "M"
   
   IF pol1239_prende_registro() THEN
      IF pol1239_edita_dados("M") THEN
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
      LET p_grupo.* = p_grupoa.*
      CALL pol1239_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE grupo_ativ_manut_ind_1099
      SET cod_tip_manut = p_grupo.cod_tip_manut
     WHERE cod_grp_atividade = p_grupo.cod_grp_atividade

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "grupo_ativ_manut_ind_1099")
      RETURN FALSE
   END IF

   LET parametro.texto = 'ALTERACAO DO TIPO DE MANUTENCAO DO GRUPO ', p_grupo.cod_grp_atividade 
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1239_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1239_prende_registro() THEN
      IF pol1239_deleta() THEN
         INITIALIZE p_grupo TO NULL
         CALL pol1239_limpa_tela()
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
FUNCTION pol1239_deleta()
#------------------------#

   DELETE FROM grupo_ativ_manut_ind_1099
    WHERE cod_grp_atividade = p_grupo.cod_grp_atividade

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","grupo_ativ_manut_ind_1099")
      RETURN FALSE
   END IF

   LET parametro.texto = 'EXCLUSAO DO GRUPO ', p_grupo.cod_grp_atividade 
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1239_listagem()
#--------------------------#     

   IF NOT pol1239_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1239_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT a.cod_grp_atividade, 
           b.den_grp_atividade,
           a.cod_tip_manut
      FROM grupo_ativ_manut_ind_1099 a, grupo_ativ b
     WHERE a.cod_grp_atividade = b.cod_grp_atividade
     ORDER BY a.cod_grp_atividade
  
   FOREACH cq_impressao 
      INTO p_relat.cod_grp_atividade,
           p_relat.den_grp_atividade,
           p_relat.cod_tip_manut
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      IF p_relat.cod_tip_manut = 'C' THEN 
         LET p_relat.den_tip_manut = 'CORRETIVA'
      ELSE
         LET p_relat.den_tip_manut = 'PREVENTIVA'
      END IF
      
      OUTPUT TO REPORT pol1239_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1239_relat   
   
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
 FUNCTION pol1239_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1239.tmp"
         START REPORT pol1239_relat TO p_caminho
      ELSE
         START REPORT pol1239_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1239_le_den_empresa()
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
 REPORT pol1239_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 078, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1239",
               COLUMN 010, "GRUPOS MANUTENCAO INDUSTRIAL",
               COLUMN 058, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'GRUPO       DESCRICAO                                TIPO'
         PRINT COLUMN 001, '----------- ---------------------------------------- ---------------'
----------- ---------------------------------------- ---------------
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.cod_grp_atividade,
               COLUMN 013, p_relat.den_grp_atividade,
               COLUMN 054, p_relat.cod_tip_manut,
               COLUMN 056, p_relat.den_tip_manut
                              
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
