#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1163                                                 #
# OBJETIVO: NIVEL DE AUTORIDADE P/ AR E CONTRATO                    #
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
         
  
   DEFINE p_nivel_autorid_265  RECORD LIKE nivel_autorid_265.*,
          p_relat              RECORD LIKE nivel_autorid_265.*      
          
   DEFINE p_cod_nivel_autorid  LIKE nivel_autorid_265.cod_nivel_autorid,
          p_cod_nivel_autorida LIKE nivel_autorid_265.cod_nivel_autorid,
          p_den_nivel_autorid  LIKE nivel_autorid_265.den_nivel_autorid,
          p_hierarquia         LIKE nivel_hierarq_265.hierarquia,
          p_cod_nivel          LIKE nivel_autorid_265.cod_nivel_autorid
          
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
   LET p_versao = "pol1163-10.02.07"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET parametro.num_programa = 'POL1163'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user
   
   IF p_status = 0 THEN
      CALL pol1163_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1163_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1163") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1163 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1163_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1163_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1163_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1163_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1163_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_nivel_autorid TO cod_nivel_autorid
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1163_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      {COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1163_listagem()}
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1163_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1163

END FUNCTION

#-----------------------#
 FUNCTION pol1163_sobre()
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
FUNCTION pol1163_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1163_inclusao()
#--------------------------#

   CALL pol1163_limpa_tela()
   INITIALIZE p_nivel_autorid_265, p_hierarquia TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1163_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1163_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1163_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1163_insere()
#------------------------#

   LET p_nivel_autorid_265.cod_empresa = p_cod_empresa

   INSERT INTO nivel_autorid_265 VALUES (p_nivel_autorid_265.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","nivel_autorid_265")       
      RETURN FALSE
   END IF
   
   INSERT INTO nivel_hierarq_265(
      empresa,         
      nivel_autoridade,
      hierarquia)
   VALUES(p_cod_empresa,
          p_nivel_autorid_265.cod_nivel_autorid,
          p_hierarquia)
          
   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","nivel_hierarq_265")       
      RETURN FALSE
   END IF
   
   LET parametro.texto = 'INCLUSAO DO NIVEL DE AUTORIDADE ', p_nivel_autorid_265.cod_nivel_autorid
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1163_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01),
          l_nivel  CHAR(02)
          
   LET INT_FLAG = FALSE
   
   INPUT p_nivel_autorid_265.cod_nivel_autorid,   
         p_nivel_autorid_265.den_nivel_autorid,   
         p_nivel_autorid_265.cod_nivel_subst,    
         p_hierarquia    
      WITHOUT DEFAULTS
         FROM cod_nivel_autorid,   
              den_nivel_autorid,   
              cod_nivel_subst, 
              hierarquia 
                       
      BEFORE FIELD cod_nivel_autorid

         IF p_funcao = "M" THEN
            NEXT FIELD den_nivel_autorid
         END IF
      
      AFTER FIELD cod_nivel_autorid

         IF p_nivel_autorid_265.cod_nivel_autorid IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_nivel_autorid   
         END IF
          
         SELECT den_nivel_autorid
           INTO p_den_nivel_autorid
           FROM nivel_autorid_265
          WHERE cod_empresa = p_cod_empresa
            AND cod_nivel_autorid = p_nivel_autorid_265.cod_nivel_autorid
         
         IF STATUS = 0 THEN 
            ERROR 'Nivel de autoridade já cadastrado!!!'
            NEXT FIELD cod_nivel_autorid
         ELSE
            IF STATUS <> 100 THEN 
               CALL log003_err_sql('lendo','nivel_autorid_265:1')
               RETURN FALSE
            END IF 
         END IF  
     
      AFTER FIELD den_nivel_autorid

         IF p_nivel_autorid_265.den_nivel_autorid IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD den_nivel_autorid   
         END IF

      AFTER FIELD cod_nivel_subst
      
         IF p_nivel_autorid_265.cod_nivel_subst IS NOT NULL THEN 
          
            SELECT den_nivel_autorid
              INTO p_den_nivel_autorid
              FROM nivel_autorid_265
             WHERE cod_empresa = p_cod_empresa
               AND cod_nivel_autorid = p_nivel_autorid_265.cod_nivel_subst
         
            IF STATUS = 100 THEN 
               ERROR 'Nivel de autoridade NÃO cadastrado!!!'
               NEXT FIELD cod_nivel_subst
            ELSE
               IF STATUS <> 0 THEN 
                  CALL log003_err_sql('lendo','nivel_autorid_265:2')
                  RETURN FALSE
               END IF 
            END IF  
   
         ELSE
            LET p_den_nivel_autorid = ''
         END IF

         DISPLAY p_den_nivel_autorid TO den_nivel_subst
      
      AFTER FIELD hierarquia
         
         IF p_hierarquia IS NULL OR
            p_hierarquia < 0 THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD hierarquia   
         END IF            
      
         SELECT nivel_autoridade
           INTO l_nivel
           FROM nivel_hierarq_265
          WHERE empresa = p_cod_empresa
            AND hierarquia = p_hierarquia
         
         IF STATUS <> 0 AND STATUS <> 100 THEN
            CALL log003_err_sql('SELECT', 'nivel_hierarq_265')
            RETURN FALSE
         END IF
         
         IF STATUS = 0 THEN
            IF p_funcao = 'I' THEN
               ERROR 'Hierarquia já cadastrada'
               NEXT FIELD hierarquia 
            ELSE         
               IF l_nivel <> p_nivel_autorid_265.cod_nivel_autorid  THEN
                  ERROR 'Hierarquia já cadastrada'
                  NEXT FIELD hierarquia 
               END IF
            END IF
         END IF
         
      ON KEY (control-z)
         CALL pol1163_popup()
      
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1163_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_nivel_subst)
         CALL log009_popup(8,10,"NIVEL DE AUTORIDADE","nivel_autorid_265",
              "cod_nivel_autorid","den_nivel_autorid","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_nivel_autorid_265.cod_nivel_subst = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_nivel_subst
         END IF
   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1163_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1163_limpa_tela()
   LET p_cod_nivel_autorida = p_cod_nivel_autorid
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      nivel_autorid_265.cod_nivel_autorid,
      nivel_autorid_265.den_nivel_autorid,
      nivel_autorid_265.cod_nivel_subst
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1163_limpa_tela()
         ELSE
            LET p_cod_nivel_autorid = p_cod_nivel_autorida
            CALL pol1163_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_nivel_autorid ",
                  "  FROM nivel_autorid_265 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_nivel_autorid"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_nivel_autorid

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1163_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1163_exibe_dados()
#------------------------------#


   SELECT n.cod_empresa,      
          n.cod_nivel_autorid,
          n.den_nivel_autorid,
          n.cod_nivel_subst,  
          h.hierarquia
     INTO p_nivel_autorid_265.cod_empresa,      
          p_nivel_autorid_265.cod_nivel_autorid,
          p_nivel_autorid_265.den_nivel_autorid,
          p_nivel_autorid_265.cod_nivel_subst,  
          p_hierarquia
     FROM nivel_autorid_265 n
    INNER JOIN nivel_hierarq_265 h 
       ON n.cod_empresa = h.empresa
      AND n.cod_nivel_autorid = h.nivel_autoridade
    WHERE n.cod_empresa = p_cod_empresa
      AND n.cod_nivel_autorid = p_cod_nivel_autorid
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "nivel_autorid_265")
      RETURN FALSE
   END IF
   
   IF p_nivel_autorid_265.cod_nivel_subst IS NULL
      OR p_nivel_autorid_265.cod_nivel_subst = ' ' THEN
      LET p_den_nivel_autorid = ''
   ELSE
      SELECT den_nivel_autorid
        INTO p_den_nivel_autorid
        FROM nivel_autorid_265
       WHERE cod_empresa = p_cod_empresa
         AND cod_nivel_autorid = p_nivel_autorid_265.cod_nivel_subst 
   
      IF STATUS <> 0 THEN 
         LET p_den_nivel_autorid = ''
      END IF
   END IF
   
   DISPLAY BY NAME p_nivel_autorid_265.*

   DISPLAY p_den_nivel_autorid   TO den_nivel_subst
   DISPLAY p_hierarquia TO hierarquia
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1163_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_nivel_autorida = p_cod_nivel_autorid
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_nivel_autorid
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_nivel_autorid
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_nivel_autorid
           FROM nivel_autorid_265
          WHERE cod_empresa = p_cod_empresa
            AND cod_nivel_autorid = p_cod_nivel_autorid
            
         IF STATUS = 0 THEN
            CALL pol1163_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_nivel_autorid = p_cod_nivel_autoridA
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1163_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_nivel_autorid 
      FROM nivel_autorid_265  
     WHERE cod_empresa = p_cod_empresa
       AND cod_nivel_autorid = p_cod_nivel_autorid
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","nivel_autorid_265")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1163_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   
   IF pol1163_prende_registro() THEN
      IF pol1163_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         CALL pol1163_exibe_dados() RETURNING p_status
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

   UPDATE nivel_autorid_265
      SET den_nivel_autorid = p_nivel_autorid_265.den_nivel_autorid,
          cod_nivel_subst = p_nivel_autorid_265.cod_nivel_subst
    WHERE cod_empresa = p_cod_empresa
      AND cod_nivel_autorid   = p_cod_nivel_autorid
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "nivel_autorid_265")
      RETURN FALSE
   END IF

   UPDATE nivel_hierarq_265
      SET hierarquia = p_hierarquia
    WHERE empresa = p_cod_empresa
      AND nivel_autoridade = p_cod_nivel_autorid
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "nivel_hierarq_265")
      RETURN FALSE
   END IF

   LET parametro.num_programa = 'POL1163'
   LET parametro.texto = 'ALTERACAO DA HIERARQUIA DO NIVEL DE AUTORIDADE ', p_cod_nivel_autorid
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1163_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF

   SELECT COUNT(nom_usuario)
     INTO p_count
     FROM nivel_usuario_265
    WHERE cod_empresa = p_cod_empresa
      AND cod_nivel_autorid = p_cod_nivel_autorid

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','nivel_usuario_265')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_msg = 'Nivel de autoridade já está sendo utiliazado\n',
                  'pelo POL1164. Exclusão não permitida.'
      CALL log0030_mensagem(p_msg, "exclamation")
      RETURN FALSE
   END IF   
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1163_prende_registro() THEN
      IF pol1163_deleta() THEN
         INITIALIZE p_nivel_autorid_265 TO NULL
         CALL pol1163_limpa_tela()
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
FUNCTION pol1163_deleta()
#------------------------#

   DELETE FROM nivel_autorid_265
    WHERE cod_empresa = p_cod_empresa
      AND cod_nivel_autorid = p_cod_nivel_autorid

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","nivel_autorid_265")
      RETURN FALSE
   END IF

   DELETE FROM nivel_hierarq_265
    WHERE empresa = p_cod_empresa
      AND nivel_autoridade = p_cod_nivel_autorid

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","nivel_hierarq_265")
      RETURN FALSE
   END IF

   LET parametro.num_programa = 'POL1163'
   LET parametro.texto = 'DELECAO DO NIVEL DE AUTORIDADE ', p_cod_nivel_autorid
   IF NOT pol1161_grava_auadit(parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

{
#--------------------------#
 FUNCTION pol1163_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1163_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1163_le_den_empresa() THEN
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
     FROM nivel_autorid_265
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
   
   OUTPUT TO REPORT pol1163_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1163_relat   
   
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
 FUNCTION pol1163_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1163.tmp"
         START REPORT pol1163_relat TO p_caminho
      ELSE
         START REPORT pol1163_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1163_le_den_empresa()
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
 REPORT pol1163_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1163",
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