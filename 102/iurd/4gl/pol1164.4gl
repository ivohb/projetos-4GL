#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1164                                                 #
# OBJETIVO: NIVEL POR USUARIO P/ AR E CONTRATO                      #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 14/09/12                                                #
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
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
         
  
   DEFINE p_nivel_usuario_265  RECORD
          cod_empresa          CHAR(2),
          nom_usuario          CHAR(8),
          cod_nivel_autorid    CHAR(2),
          num_versao           DECIMAL(3,0),
          ies_versao_atual     CHAR(10),
          nom_usuario_cad      CHAR(8),
          dat_cadast           DATE,
          hor_cadast           CHAR(8),
          ies_tip_autoridade   CHAR(1)
   END RECORD

   DEFINE p_nivel_usuario_265a RECORD
          cod_empresa          CHAR(2),
          nom_usuario          CHAR(8),
          cod_nivel_autorid    CHAR(2),
          num_versao           DECIMAL(3,0),
          ies_versao_atual     CHAR(10),
          nom_usuario_cad      CHAR(8),
          dat_cadast           DATE,
          hor_cadast           CHAR(8),
          ies_tip_autoridade   CHAR(1)
   END RECORD
          
   DEFINE p_den_nivel_autorid    CHAR(30),
          p_nom_funcionario      CHAR(40),
          p_den_tip_autoridade   CHAR(60),
          p_ies_versao_atual     CHAR(01),
          p_num_versao           INTEGER
          
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
   LET p_versao = "pol1164-10.02.06"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET parametro.num_programa = 'POL1164'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user
      
   IF p_status = 0 THEN
      CALL pol1164_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1164_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1164") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1164 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1164_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1164_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1164_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1164_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1164_modificacao() RETURNING p_status  
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
            CALL pol1164_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      {COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1164_listagem()}
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1164_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1164

END FUNCTION

#-----------------------#
 FUNCTION pol1164_sobre()
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
FUNCTION pol1164_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1164_inclusao()
#--------------------------#

   CALL pol1164_limpa_tela()
   
   INITIALIZE p_nivel_usuario_265 TO NULL

   LET p_nivel_usuario_265.cod_empresa = p_cod_empresa
   LET p_nivel_usuario_265.num_versao = 1
   LET p_nivel_usuario_265.ies_versao_atual = 'S'
   LET p_nivel_usuario_265.nom_usuario_cad = p_user
   LET p_nivel_usuario_265.dat_cadast = TODAY  
   LET p_nivel_usuario_265.hor_cadast = TIME
   
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1164_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1164_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1164_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1164_insere()
#------------------------#

   INSERT INTO nivel_usuario_265 VALUES (p_nivel_usuario_265.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","nivel_usuario_265")       
      RETURN FALSE
   END IF

   LET parametro.texto = 'INCLUSAO DO USUARIO/NIVEL ', 
       p_nivel_usuario_265.nom_usuario CLIPPED, "/", p_nivel_usuario_265.cod_nivel_autorid
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1164_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT p_nivel_usuario_265.nom_usuario,
         p_nivel_usuario_265.num_versao,
         p_nivel_usuario_265.ies_versao_atual,
         p_nivel_usuario_265.cod_nivel_autorid,
         p_nivel_usuario_265.ies_tip_autoridade,
         p_nivel_usuario_265.nom_usuario_cad,
         p_nivel_usuario_265.dat_cadast,     
         p_nivel_usuario_265.hor_cadast    
      WITHOUT DEFAULTS
         FROM nom_usuario,      
              num_versao,
              ies_versao_atual,
              cod_nivel_autorid,
              ies_tip_autoridade,
              nom_usuario_cad,
              dat_cadast,     
              hor_cadast    
              
      BEFORE FIELD nom_usuario

         IF p_funcao = "M" THEN
            NEXT FIELD cod_nivel_autorid
         END IF
      
      AFTER FIELD nom_usuario

         IF p_nivel_usuario_265.nom_usuario IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD nom_usuario   
         END IF
          
         SELECT nom_funcionario
           INTO p_nom_funcionario
           FROM usuarios
          WHERE cod_usuario = p_nivel_usuario_265.nom_usuario
         
         IF STATUS = 100 THEN 
            ERROR 'Usuário não cadastrado!!!'
            NEXT FIELD nom_usuario
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo','usuarios')
               RETURN FALSE
            END IF 
         END IF  
         
         DISPLAY p_nom_funcionario TO nom_funcionario

         {SELECT COUNT(cod_nivel_autorid)
           INTO p_count
           FROM nivel_usuario_265
          WHERE cod_empresa = p_cod_empresa
            AND nom_usuario = p_nivel_usuario_265.nom_usuario

         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','nivel_usuario_265')
            RETURN FALSE
         END IF 
         
         IF p_count > 0 THEN
            ERROR 'Usuário já cadastrado no POL1164'
            NEXT FIELD nom_usuario
         END IF}
         
         SELECT cod_nivel_autorid
           INTO p_nivel_usuario_265.cod_nivel_autorid
           FROM usuario_nivel_aut
          WHERE cod_empresa = p_cod_empresa
            AND nom_usuario = p_nivel_usuario_265.nom_usuario
            AND ies_versao_atual = 'S'
         
         IF STATUS <> 0 THEN
            LET p_nivel_usuario_265.cod_nivel_autorid = ''
         END IF
         
         DISPLAY p_nivel_usuario_265.cod_nivel_autorid TO cod_nivel_autorid
         
      AFTER FIELD cod_nivel_autorid

         IF p_nivel_usuario_265.cod_nivel_autorid IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_nivel_autorid   
         END IF
          
         SELECT den_nivel_autorid
           INTO p_den_nivel_autorid
           FROM nivel_autorid_265
          WHERE cod_empresa = p_cod_empresa
            AND cod_nivel_autorid = p_nivel_usuario_265.cod_nivel_autorid
         
         IF STATUS = 100 THEN 
            ERROR 'Nivel de autoridade não cadastrado!!!'
            NEXT FIELD cod_nivel_autorid
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo','nivel_autorid_265')
               RETURN FALSE
            END IF 
         END IF  
         
         DISPLAY p_den_nivel_autorid to den_nivel_autorid
                  
      AFTER FIELD ies_tip_autoridade

         IF p_nivel_usuario_265.ies_tip_autoridade IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD ies_tip_autoridade   
         END IF
         
         CALL pol1164_den_tipo()
         
         IF p_den_tip_autoridade IS NULL THEN
            ERROR "Valor inválido para o campo !!! - Informe 1,2,3,4 ou 5"
            NEXT FIELD ies_tip_autoridade   
         END IF
         
         DISPLAY p_den_tip_autoridade TO den_tip_autoridade
         
      ON KEY (control-z)
         CALL pol1164_popup()
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1164_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(nom_usuario)
         CALL log009_popup(8,10,"USUÁRIO","usuarios",
              "cod_usuario","nom_funcionario","","N"," 1=1 order by nom_funcionario") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_nivel_usuario_265.nom_usuario = p_codigo CLIPPED
            DISPLAY p_codigo TO nom_usuario
         END IF

      WHEN INFIELD(cod_nivel_autorid)
         CALL log009_popup(8,10,"NIVEL DE AUTORIDADE","nivel_autorid_265",
              "cod_nivel_autorid","den_nivel_autorid","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_nivel_usuario_265.cod_nivel_autorid = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_nivel_autorid
         END IF

      WHEN INFIELD(ies_tip_autoridade)
         LET p_codigo = pol1164_pop_tipo()
         IF p_codigo IS NOT NULL THEN
           LET p_nivel_usuario_265.ies_tip_autoridade = p_codigo
           DISPLAY p_codigo TO ies_tip_autoridade
         END IF
         
   END CASE 

END FUNCTION 

#--------------------------#
FUNCTION pol1164_den_tipo()
#--------------------------#

   CASE p_nivel_usuario_265.ies_tip_autoridade
        WHEN '1' LET p_den_tip_autoridade = 'Autorid dentro da hierarq unid funcional' 
        WHEN '2' LET p_den_tip_autoridade = 'Autoridade genérica'                      
        WHEN '3' LET p_den_tip_autoridade = 'Hierarquia e genérica'                    
        WHEN '4' LET p_den_tip_autoridade = 'Hierarquia absoluta'                      
        WHEN '5' LET p_den_tip_autoridade = 'Hierarquia absoluta e genérica'
   OTHERWISE
        LET p_den_tip_autoridade = NULL
   END CASE

END FUNCTION

#--------------------------#
FUNCTION pol1164_pop_tipo()
#--------------------------#

   DEFINE pr_tipo    ARRAY[5] OF RECORD
          cod_tipo   CHAR(01),
          den_tipo   CHAR(40)
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11641") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11641 AT 6,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_index = 5
   
   LET pr_tipo[1].cod_tipo = '1'
   LET pr_tipo[2].cod_tipo = '2'
   LET pr_tipo[3].cod_tipo = '3'
   LET pr_tipo[4].cod_tipo = '4'
   LET pr_tipo[5].cod_tipo = '5'

   LET pr_tipo[1].den_tipo = 'Autorid dentro da hierarq unid funcional' 
   LET pr_tipo[2].den_tipo = 'Autoridade genérica'                      
   LET pr_tipo[3].den_tipo = 'Hierarquia e genérica'                    
   LET pr_tipo[4].den_tipo = 'Hierarquia absoluta'                      
   LET pr_tipo[5].den_tipo = 'Hierarquia absoluta e genérica'           
   
   CALL SET_COUNT(p_index)

   DISPLAY ARRAY pr_tipo TO sr_tipo.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol11641
   
   IF NOT INT_FLAG THEN
      RETURN pr_tipo[p_index].cod_tipo
   ELSE
      RETURN ""
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1164_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1164_limpa_tela()
   LET p_nivel_usuario_265a.* = p_nivel_usuario_265.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      nivel_usuario_265.nom_usuario,      
      nivel_usuario_265.cod_nivel_autorid,
      nivel_usuario_265.ies_tip_autoridade,
      nivel_usuario_265.nom_usuario_cad  
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1164_limpa_tela()
         ELSE
            LET p_nivel_usuario_265.* = p_nivel_usuario_265a.*
            CALL pol1164_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM nivel_usuario_265 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND ies_versao_atual = 'S' ",
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY nom_usuario"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_nivel_usuario_265.*

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1164_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1164_exibe_dados()
#------------------------------#

   SELECT nu.cod_empresa,      
          nu.nom_usuario,       
          nu.cod_nivel_autorid, 
          nu.num_versao,        
          nu.ies_versao_atual,  
          nu.nom_usuario_cad,   
          nu.dat_cadast,        
          nu.hor_cadast,        
          nu.ies_tip_autoridade,    
          na.den_nivel_autorid,
          u.nom_funcionario
     INTO p_nivel_usuario_265.cod_empresa,      
          p_nivel_usuario_265.nom_usuario,       
          p_nivel_usuario_265.cod_nivel_autorid, 
          p_nivel_usuario_265.num_versao,        
          p_nivel_usuario_265.ies_versao_atual,  
          p_nivel_usuario_265.nom_usuario_cad,   
          p_nivel_usuario_265.dat_cadast,        
          p_nivel_usuario_265.hor_cadast,        
          p_nivel_usuario_265.ies_tip_autoridade,
          p_den_nivel_autorid,
          p_nom_funcionario
     FROM nivel_usuario_265 nu
          LEFT OUTER JOIN nivel_autorid_265 na 
            ON na.cod_empresa = nu.cod_empresa
           AND na.cod_nivel_autorid = nu.cod_nivel_autorid
          LEFT OUTER JOIN usuarios u
            ON u.cod_usuario = nu.nom_usuario
    WHERE nu.cod_empresa = p_cod_empresa
      AND nu.nom_usuario = p_nivel_usuario_265.nom_usuario
      AND nu.cod_nivel_autorid = p_nivel_usuario_265.cod_nivel_autorid
      AND nu.ies_versao_atual = 'S'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "nivel_usuario_265:join")
      RETURN FALSE
   END IF
   
   DISPLAY p_nivel_usuario_265.nom_usuario TO nom_usuario       
   DISPLAY p_nivel_usuario_265.cod_nivel_autorid TO cod_nivel_autorid
   DISPLAY p_nivel_usuario_265.num_versao TO num_versao
   DISPLAY p_nivel_usuario_265.ies_versao_atual TO ies_versao_atual
   DISPLAY p_nivel_usuario_265.nom_usuario_cad TO nom_usuario_cad
   DISPLAY p_nivel_usuario_265.dat_cadast TO dat_cadast
   DISPLAY p_nivel_usuario_265.hor_cadast TO hor_cadast
   DISPLAY p_nivel_usuario_265.ies_tip_autoridade TO ies_tip_autoridade
   DISPLAY p_nom_funcionario TO nom_funcionario
   DISPLAY p_den_nivel_autorid TO den_nivel_autorid
   
   CALL pol1164_den_tipo()
   DISPLAY p_den_tip_autoridade TO den_tip_autoridade
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1164_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_nivel_usuario_265a.* = p_nivel_usuario_265.*
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_nivel_usuario_265.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_nivel_usuario_265.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_nivel_autorid
           FROM nivel_usuario_265
          WHERE cod_empresa = p_cod_empresa
            AND nom_usuario = p_nivel_usuario_265.nom_usuario
            AND cod_nivel_autorid = p_nivel_usuario_265.cod_nivel_autorid
            AND ies_versao_atual = 'S'
            
         IF STATUS = 0 THEN
            CALL pol1164_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_nivel_usuario_265.* = p_nivel_usuario_265a.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1164_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_nivel_autorid 
      FROM nivel_usuario_265  
     WHERE cod_empresa = p_cod_empresa
       AND nom_usuario = p_nivel_usuario_265.nom_usuario
       AND cod_nivel_autorid = p_nivel_usuario_265.cod_nivel_autorid
       AND ies_versao_atual = 'S'
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","nivel_usuario_265")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1164_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   IF NOT pol1164_checa_versao() THEN
      RETURN FALSE
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_nivel_usuario_265a.* = p_nivel_usuario_265.*
   
   IF pol1164_prende_registro() THEN
      IF pol1164_edita_dados("M") THEN
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
      LET p_nivel_usuario_265.* = p_nivel_usuario_265a.*
      CALL pol1164_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#------------------------------#
FUNCTION pol1164_checa_versao()
#------------------------------#

   IF p_nivel_usuario_265.ies_versao_atual = 'N' THEN
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

   UPDATE nivel_usuario_265
      SET ies_versao_atual = 'N'
    WHERE cod_empresa = p_cod_empresa
      AND nom_usuario = p_nivel_usuario_265.nom_usuario
      AND cod_nivel_autorid = p_nivel_usuario_265a.cod_nivel_autorid
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "nivel_usuario_265")
      RETURN FALSE
   END IF

   LET p_nivel_usuario_265.num_versao = p_nivel_usuario_265.num_versao + 1
   LET p_nivel_usuario_265.nom_usuario_cad = p_user
   LET p_nivel_usuario_265.dat_cadast = TODAY  
   LET p_nivel_usuario_265.hor_cadast = TIME
   
   IF NOT pol1164_insere() THEN
      RETURN FALSE
   END IF

   LET parametro.texto = 'ALTERACAO DO USUARIO/NIVEL ', 
       p_nivel_usuario_265.nom_usuario CLIPPED, "/", p_nivel_usuario_265.cod_nivel_autorid
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1164_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF

   IF NOT pol1164_checa_versao() THEN
      RETURN FALSE
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1164_prende_registro() THEN
      IF pol1164_deleta() THEN
         INITIALIZE p_nivel_usuario_265 TO NULL
         CALL pol1164_limpa_tela()
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
FUNCTION pol1164_deleta()
#------------------------#

   DELETE FROM nivel_usuario_265
    WHERE cod_empresa = p_cod_empresa
      AND nom_usuario = p_nivel_usuario_265.nom_usuario
      AND cod_nivel_autorid = p_nivel_usuario_265.cod_nivel_autorid

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","nivel_usuario_265")
      RETURN FALSE
   END IF

   LET parametro.texto = 'DELECAO DO USUARIO/NIVEL ', 
       p_nivel_usuario_265.nom_usuario CLIPPED, "/", p_nivel_usuario_265.cod_nivel_autorid
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

{
#--------------------------#
 FUNCTION pol1164_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1164_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1164_le_den_empresa() THEN
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
     FROM nivel_usuario_265
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
   
   OUTPUT TO REPORT pol1164_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1164_relat   
   
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
 FUNCTION pol1164_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1164.tmp"
         START REPORT pol1164_relat TO p_caminho
      ELSE
         START REPORT pol1164_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1164_le_den_empresa()
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
 REPORT pol1164_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1164",
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