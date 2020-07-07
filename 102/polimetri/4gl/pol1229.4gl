#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1229                                                 #
# OBJETIVO: USUÁRIO PARA MANIPULAÇÃO DE OC BLOQUEADA                #
# AUTOR...: IVO BL                                                  #
# DATA....: 25/09/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix       

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_nom_funcionario    LIKE usuarios.nom_funcionario,
          p_acesso             CHAR(15),
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
  
   DEFINE p_usuario_oc_bloq_454    RECORD LIKE usuario_oc_bloq_454.*
      
   DEFINE p_nom_usuario        LIKE usuario_oc_bloq_454.nom_usuario,
          p_nom_usuarioa       LIKE usuario_oc_bloq_454.nom_usuario
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1229-10.02.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

     IF p_status = 0 THEN
      CALL pol1229_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1229_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1229") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1229 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   LET p_ies_cons  = FALSE
   CALL pol1229_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         LET p_ies_cons = FALSE
         CALL pol1229_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            CALL pol1229_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
         CALL pol1229_consulta() RETURNING p_status
         IF p_status THEN
            IF p_ies_cons THEN
               ERROR 'Consulta efetuada com sucesso !!!'
               NEXT OPTION "Seguinte" 
            ELSE
               CALL pol1229_limpa_tela()
               ERROR 'Argumentos de pesquisa não encontrados !!!'
            END IF 
         ELSE
            CALL pol1229_limpa_tela()
            ERROR 'Operação cancelada!!!'
            NEXT OPTION 'Incluir'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1229_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1229_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1229_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
        IF p_ies_cons THEN
           CALL pol1229_exclusao() RETURNING p_retorno
           IF p_retorno THEN
              ERROR 'Exclusão efetuada com sucesso !!!'
           ELSE
              ERROR 'Operação cancelada !!!'
           END IF
        ELSE
           ERROR "Consulte previamente para fazer a exclusão !!!"
        END IF  
      COMMAND "Listar" "Listagem"
         CALL pol1229_listagem()     
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1229_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1229

END FUNCTION

#-----------------------#
 FUNCTION pol1229_sobre()
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
 FUNCTION pol1229_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1229_inclusao()
#--------------------------#

   CALL pol1229_limpa_tela()
   
   INITIALIZE p_usuario_oc_bloq_454 TO NULL
   LET p_usuario_oc_bloq_454.tip_acesso = 'A'
   
   IF pol1229_edita_dados("I") THEN
      INSERT INTO usuario_oc_bloq_454
       VALUES(p_usuario_oc_bloq_454.*)
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERT", "usuario_oc_bloq_454")   
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1229_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01) 
   LET INT_FLAG = FALSE
   
   
   INPUT BY NAME p_usuario_oc_bloq_454.* WITHOUT DEFAULTS
      
      BEFORE FIELD nom_usuario

         IF p_funcao = 'M' THEN
            NEXT FIELD tip_acesso
         END IF
         
      AFTER FIELD nom_usuario
         
         IF p_usuario_oc_bloq_454.nom_usuario IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD nom_usuario   
         END IF
      
         SELECT nom_usuario
           FROM usuario_oc_bloq_454
          WHERE nom_usuario = p_usuario_oc_bloq_454.nom_usuario
       
         IF STATUS = 0 THEN
            ERROR "Usuário já cadastrada no pol1229."
            NEXT FIELD nom_usuario
         END IF
         
         CALL pol1229_le_usuario()
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','excla')
            NEXT FIELD nom_usuario
         END IF
         
         DISPLAY p_nom_funcionario TO nom_funcionario

      ON KEY (control-z)
         CALL pol1229_popup()
                                   
   END INPUT 

   IF INT_FLAG  THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1229_le_usuario()#
#----------------------------#

   SELECT nom_funcionario
     INTO p_nom_funcionario
     FROM usuarios
    WHERE cod_usuario = p_usuario_oc_bloq_454.nom_usuario

END FUNCTION

#-----------------------#
 FUNCTION pol1229_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(nom_usuario)
         CALL log009_popup(8,10,"USUARIOS","usuarios",
              "cod_usuario","nom_funcionario","","N","1=1 order by cod_usuario") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_usuario_oc_bloq_454.nom_usuario = p_codigo CLIPPED
            DISPLAY p_codigo TO nom_usuario
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1229_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1229_limpa_tela()
   
   LET p_nom_usuarioa = p_nom_usuario
   LET INT_FLAG          = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      usuario_oc_bloq_454.nom_usuario,
      usuario_oc_bloq_454.tip_acesso
            
   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_nom_usuario = p_nom_usuarioa   
         CALL pol1229_exibe_dados() RETURNING p_status
      ELSE
         CALL pol1229_limpa_tela()
      END IF
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT nom_usuario ",
                  "  FROM usuario_oc_bloq_454 ",
                  " WHERE ", where_clause CLIPPED,
                  " order by nom_usuario "
                  

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','VAR_QUERY')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_nom_usuario

   IF STATUS = 0 THEN
      IF pol1229_exibe_dados() THEN
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

   CALL pol1229_limpa_tela()
   
   LET p_ies_cons = FALSE
         
   RETURN FALSE
   
END FUNCTION

#------------------------------#
 FUNCTION pol1229_exibe_dados()
#------------------------------#
  
  SELECT * 
    INTO p_usuario_oc_bloq_454.*
    FROM usuario_oc_bloq_454
   WHERE nom_usuario = p_nom_usuario
   
  IF STATUS <> 0 THEN 
     CALL log003_err_sql('SELECT','usuario_oc_bloq_454')
     RETURN FALSE 
  END IF  

  CALL pol1229_le_usuario()  
  
  DISPLAY by NAME p_usuario_oc_bloq_454.*
  DISPLAY p_nom_funcionario TO nom_funcionario
 
  LET p_excluiu = FALSE
  
  RETURN TRUE
  
END FUNCTION

#-----------------------------------#
 FUNCTION pol1229_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_nom_usuarioa = p_nom_usuario

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_nom_usuario
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_nom_usuario
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_nom_usuario = p_nom_usuarioa
         ELSE
            CALL log003_err_sql('FETCH','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      SELECT COUNT(nom_usuario)
        INTO p_count
        FROM usuario_oc_bloq_454
       WHERE nom_usuario = p_nom_usuario
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','usuario_oc_bloq_454')
         RETURN
      END IF
      
      IF p_count > 0 THEN
         IF pol1229_exibe_dados() THEN
            EXIT WHILE
         ELSE
            RETURN
         END IF
      END IF
       
    END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1229_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR WITH HOLD FOR
    SELECT nom_usuario 
      FROM usuario_oc_bloq_454  
     WHERE nom_usuario = p_nom_usuario
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","usuario_oc_bloq_454")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1229_modificacao()
#-----------------------------#
   
   IF p_excluiu THEN
      LET p_msg = 'Não dados na tela\n a serem modificados'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE
   
   IF pol1229_prende_registro() THEN
      IF pol1229_edita_dados("M") THEN
         UPDATE usuario_oc_bloq_454
            SET usuario_oc_bloq_454.* = p_usuario_oc_bloq_454.*
          WHERE nom_usuario = p_nom_usuario
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","usuario_oc_bloq_454")
            CALL pol1229_exibe_dados() RETURNING p_status
         END IF
      ELSE
         CALL pol1229_exibe_dados() RETURNING p_status
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
 FUNCTION pol1229_exclusao()
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

   IF pol1229_prende_registro() THEN
      DELETE FROM usuario_oc_bloq_454
       WHERE nom_usuario = p_nom_usuario
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_usuario_oc_bloq_454 TO NULL
         CALL pol1229_limpa_tela()
         LET p_retorno = TRUE  
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("DELETE","usuario_oc_bloq_454")
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
FUNCTION pol1229_listagem()
#-------------------------#     

   IF NOT pol1229_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1229_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT *
      FROM usuario_oc_bloq_454
     ORDER BY nom_usuario
   
   FOREACH cq_impressao INTO 
           p_usuario_oc_bloq_454.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_IMPRESSAO')
         EXIT FOREACH
      END IF      
      
      CALL pol1229_le_usuario()
      
      CASE p_usuario_oc_bloq_454.tip_acesso
         WHEN 'L' LET p_acesso = 'LIBERAR'
         WHEN 'E' LET p_acesso = 'EXCLUIR'
         WHEN 'A' LET p_acesso = 'AMBOS'
      END CASE
      
      OUTPUT TO REPORT pol1229_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1229_relat   
   
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
FUNCTION pol1229_escolhe_saida()
#------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1229.tmp"
         START REPORT pol1229_relat TO p_caminho
      ELSE
         START REPORT pol1229_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1229_le_empresa()
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
 REPORT pol1229_relat()
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
               
         PRINT COLUMN 001, "pol1229",
               COLUMN 025, "USUARIOS PARA DESBLOQUEIO DE OC",
               COLUMN 060, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '       USUARIO      NOME                                      ACESSO'
         PRINT COLUMN 001, '       -------      ----------------------------------------- ------------------'

      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1229",
               COLUMN 025, "USUARIOS PARA DESBLOQUEIO DE OC",
               COLUMN 060, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '       USUARIO      NOME                                      ACESSO'
         PRINT COLUMN 001, '       -------      ----------------------------------------- ------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 008, p_usuario_oc_bloq_454.nom_usuario,
               COLUMN 021, p_nom_funcionario,
               COLUMN 063, p_acesso
         
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