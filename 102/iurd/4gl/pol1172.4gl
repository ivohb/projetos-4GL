#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1172                                                 #
# OBJETIVO: USUÁRIO NIVEL SUBSTITUTO, P/ APROVAÇÃO DE NOTAS         #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 18/10/12                                                #
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


   DEFINE p_usuario_subs_265  RECORD
    cod_empresa      char(2),     
    cod_usuario      char(8),     
    num_versao       decimal(3,0),
    ies_versao_atual char(1),     
    cod_usuario_subs char(8),     
    dat_ini_validade date,        
    dat_fim_validade date,        
    cod_usuario_incl char(8),     
    dat_inclusao     date,        
    hor_inclusao     char(8),     
    motivo_subs      char(50)    
   END RECORD

   DEFINE p_usuario_subs_265a  RECORD
    cod_empresa      char(2),     
    cod_usuario      char(8),     
    num_versao       decimal(3,0),
    ies_versao_atual char(1),     
    cod_usuario_subs char(8),     
    dat_ini_validade date,        
    dat_fim_validade date,        
    cod_usuario_incl char(8),     
    dat_inclusao     date,        
    hor_inclusao     char(8),     
    motivo_subs      char(50)    
   END RECORD

          
   DEFINE p_nom_usuario         CHAR(40),
          p_nom_usuario_subs    CHAR(40),
          p_ies_versao_atual    CHAR(01),
          p_num_versao          INTEGER
          
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
   LET p_versao = "pol1172-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET parametro.num_programa = 'POL1172'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user
      
   IF p_status = 0 THEN
      CALL pol1172_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1172_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1172") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1172 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1172_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1172_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1172_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1172_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1172_modificacao() RETURNING p_status  
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
            CALL pol1172_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      {COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1172_listagem()}
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1172_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1172

END FUNCTION

#-----------------------#
 FUNCTION pol1172_sobre()
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
FUNCTION pol1172_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1172_inclusao()
#--------------------------#

   CALL pol1172_limpa_tela()
   
   INITIALIZE p_usuario_subs_265 TO NULL

   LET p_usuario_subs_265.cod_empresa = p_cod_empresa
   LET p_usuario_subs_265.num_versao = 1
   LET p_usuario_subs_265.ies_versao_atual = 'S'
   LET p_usuario_subs_265.cod_usuario_incl = p_user
   LET p_usuario_subs_265.dat_inclusao = TODAY  
   LET p_usuario_subs_265.HOR_inclusao = TIME
   
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1172_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1172_insere('I') THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1172_limpa_tela()
   RETURN FALSE

END FUNCTION

#----------------------------#
FUNCTION pol1172_insere(p_op)#
#----------------------------#
   
   DEFINE p_op CHAR(01)

   INSERT INTO usuario_subs_265 VALUES (p_usuario_subs_265.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","usuario_subs_265")       
      RETURN FALSE
   END IF

   IF p_op = 'I' THEN
      LET parametro.texto = 'INCLUSAO DE SUBSTITUTO P/ O USUARIO ', p_usuario_subs_265.cod_usuario 
   ELSE
      LET parametro.texto = 'ALTERACAO DO SUBSTITUTO P/ O USUARIO ', p_usuario_subs_265.cod_usuario 
   END IF
   
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1172_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_usuario_subs_265.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD cod_usuario

         IF p_funcao = "M" THEN
            NEXT FIELD dat_ini_validade
         END IF
      
      AFTER FIELD cod_usuario

         IF p_usuario_subs_265.cod_usuario IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_usuario   
         END IF
         
         CALL pol1172_le_nom_usuario(p_usuario_subs_265.cod_usuario)
          
         IF p_nom_usuario IS NULL THEN 
            NEXT FIELD cod_usuario
         END IF  
         
         DISPLAY p_nom_usuario TO nom_usuario

      BEFORE FIELD cod_usuario_subs

         IF p_funcao = "M" THEN
            NEXT FIELD dat_ini_validade
         END IF
         
      AFTER FIELD cod_usuario_subs

         IF p_usuario_subs_265.cod_usuario_subs IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_usuario_subs   
         END IF

         IF p_usuario_subs_265.cod_usuario_subs = p_usuario_subs_265.cod_usuario THEN 
            ERROR "Informe um usuário diferente do titular !!!"
            NEXT FIELD cod_usuario_subs   
         END IF
         
         SELECT cod_empresa
           FROM usuario_subs_265
          WHERE cod_empresa = p_cod_empresa
            AND cod_usuario = p_usuario_subs_265.cod_usuario
            AND cod_usuario_subs = p_usuario_subs_265.cod_usuario_subs
         
         IF STATUS = 0 THEN
            ERROR "Usuário substituído já existe - Use Modificar !!!"
            NEXT FIELD cod_usuario_subs   
         END IF
         
         CALL pol1172_le_nom_usuario(p_usuario_subs_265.cod_usuario_subs)
          
         IF p_nom_usuario IS NULL THEN 
            NEXT FIELD cod_usuario_subs
         END IF  
         
         DISPLAY p_nom_usuario TO nom_usuario_subs
         
      AFTER FIELD dat_ini_validade

         IF p_usuario_subs_265.dat_ini_validade IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD dat_ini_validade   
         END IF

      AFTER FIELD dat_fim_validade

         IF p_usuario_subs_265.dat_fim_validade IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD dat_fim_validade   
         ELSE
            IF p_usuario_subs_265.dat_fim_validade < p_usuario_subs_265.dat_ini_validade THEN
               ERROR 'A data final deve ser maior que a data inicial!'
               NEXT FIELD dat_ini_validade
            END IF
         END IF
         
      ON KEY (control-z)
         CALL pol1172_popup()
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1172_le_nom_usuario(p_cod)#
#-------------------------------------#
   
   DEFINE p_cod CHAR(10)
   
   SELECT nom_funcionario
     INTO p_nom_usuario
     FROM usuarios
    WHERE cod_usuario = p_cod
         
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Lendo','usuarios')
      LET p_nom_usuario = NULL
   END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol1172_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_usuario)
         CALL log009_popup(8,10,"USUÁRIO","usuarios",
              "cod_usuario","nom_funcionario","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_usuario_subs_265.cod_usuario = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_usuario
         END IF

      WHEN INFIELD(cod_usuario_subs)
         CALL log009_popup(8,10,"USUÁRIO","usuarios",
              "cod_usuario","nom_funcionario","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_usuario_subs_265.cod_usuario_subs = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_usuario_subs
         END IF
         
   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1172_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1172_limpa_tela()
   LET p_usuario_subs_265a.* = p_usuario_subs_265.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      usuario_subs_265.cod_usuario,      
      usuario_subs_265.cod_usuario_subs,
      usuario_subs_265.dat_ini_validade,
      usuario_subs_265.dat_fim_validade  
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1172_limpa_tela()
         ELSE
            LET p_usuario_subs_265.* = p_usuario_subs_265a.*
            CALL pol1172_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM usuario_subs_265 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND ies_versao_atual = 'S' ",
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_usuario, cod_usuario_subs"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_usuario_subs_265.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1172_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1172_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_usuario_subs_265.*
   
   CALL pol1172_le_nom_usuario(p_usuario_subs_265.cod_usuario)
   DISPLAY p_nom_usuario to nom_usuario

   CALL pol1172_le_nom_usuario(p_usuario_subs_265.cod_usuario_subs)
   DISPLAY p_nom_usuario to nom_usuario_subs
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1172_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_usuario_subs_265a.* = p_usuario_subs_265.*
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_usuario_subs_265.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_usuario_subs_265.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_empresa
           FROM usuario_subs_265
          WHERE cod_empresa = p_cod_empresa
            AND cod_usuario = p_usuario_subs_265.cod_usuario
            AND cod_usuario_subs = p_usuario_subs_265.cod_usuario_subs
            AND num_versao = p_usuario_subs_265.num_versao
            AND ies_versao_atual = 'S'
            
         IF STATUS = 0 THEN
            CALL pol1172_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_usuario_subs_265.* = p_usuario_subs_265a.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1172_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM usuario_subs_265  
     WHERE cod_empresa = p_cod_empresa
       AND cod_usuario = p_usuario_subs_265.cod_usuario
       AND cod_usuario_subs = p_usuario_subs_265.cod_usuario_subs
       AND ies_versao_atual = 'S'
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","usuario_subs_265")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1172_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   #IF NOT pol1172_checa_versao() THEN
   #   RETURN FALSE
   #END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_usuario_subs_265a.* = p_usuario_subs_265.*
   
   IF pol1172_prende_registro() THEN
      IF pol1172_edita_dados("M") THEN
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
      LET p_usuario_subs_265.* = p_usuario_subs_265a.*
      CALL pol1172_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#------------------------------#
FUNCTION pol1172_checa_versao()
#------------------------------#

   IF p_usuario_subs_265.ies_versao_atual = 'N' THEN
      LET p_msg = 'Somente a versão atual pode\n',
                  'ser modificada ou excluida!'
      CALL log0030_mensagem(p_msg,'exclamation')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION    

#--------------------------#
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE usuario_subs_265
      SET ies_versao_atual = 'N'
     WHERE cod_empresa = p_cod_empresa
       AND cod_usuario = p_usuario_subs_265.cod_usuario
       AND cod_usuario_subs = p_usuario_subs_265.cod_usuario_subs
       AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "usuario_subs_265")
      RETURN FALSE
   END IF

   LET p_usuario_subs_265.num_versao = p_usuario_subs_265.num_versao + 1
   LET p_usuario_subs_265.cod_usuario_incl = p_user
   LET p_usuario_subs_265.dat_inclusao = TODAY  
   LET p_usuario_subs_265.hor_inclusao = TIME
   
   IF NOT pol1172_insere('M') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1172_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF

   #IF NOT pol1172_checa_versao() THEN
   #   RETURN FALSE
   #END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1172_prende_registro() THEN
      IF pol1172_deleta() THEN
         INITIALIZE p_usuario_subs_265 TO NULL
         CALL pol1172_limpa_tela()
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
FUNCTION pol1172_deleta()
#------------------------#

   DELETE FROM usuario_subs_265
    WHERE cod_empresa = p_cod_empresa
      AND cod_usuario = p_usuario_subs_265.cod_usuario
      AND cod_usuario_subs = p_usuario_subs_265.cod_usuario_subs

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","usuario_subs_265")
      RETURN FALSE
   END IF

   LET parametro.texto = 'DELECAO DE SUBSTITUTO P/ O USUARIO ', p_usuario_subs_265.cod_usuario 
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

{
#--------------------------#
 FUNCTION pol1172_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1172_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1172_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_nivel_autorid,
          nom_contato,
          num_agencia,
          nom_agencia,
          num_conta,
          cod_tip_reg,
          dat_termino
     FROM usuario_subs_265
 ORDER BY cod_nivel_autorid                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT den_nivel_autorid
        INTO p_den_nivel_autorid
        FROM bancos
       WHERE cod_nivel_autorid = p_relat.cod_nivel_autorid
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'bancos')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1172_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1172_relat   
   
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

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1172_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1172.tmp"
         START REPORT pol1172_relat TO p_caminho
      ELSE
         START REPORT pol1172_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1172_le_den_empresa()
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

#---------------------#
 REPORT pol1172_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1172",
               COLUMN 042, "BANCOS PARA EMPRESTIMOS CONSIGNADOS",
               COLUMN 114, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, 'Banco          Descricao                       Contato              Agencia           Descricao                Conta       Identif   Termino'
         PRINT COLUMN 002, '----- ------------------------------ ------------------------------ ------- ------------------------------ --------------- -------- ----------'
                            
      ON EVERY ROW

         PRINT COLUMN 004, p_relat.cod_nivel_autorid   USING "###",
               COLUMN 008, p_den_nivel_autorid,
               COLUMN 039, p_relat.nom_contato,
               COLUMN 070, p_relat.num_agencia,
               COLUMN 078, p_relat.nom_agencia,
               COLUMN 109, p_relat.num_conta,
               COLUMN 131, p_relat.cod_tip_reg USING "##",
               COLUMN 134, p_relat.dat_termino
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#