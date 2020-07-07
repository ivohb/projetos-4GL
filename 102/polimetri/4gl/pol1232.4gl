#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1232                                                 #
# OBJETIVO: REGRAS DO TRAVA90                                       #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 30/10/13                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_last_row           SMALLINT,
          p_caminho            CHAR(080),
          p_status             SMALLINT
                               
END GLOBALS

DEFINE    p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT

DEFINE p_tabela  RECORD LIKE tabela_trava90_454.*,
       p_tabelaa RECORD LIKE tabela_trava90_454.*

DEFINE p_parametro     RECORD
       cod_empresa     LIKE audit_logix.cod_empresa,
       texto           LIKE audit_logix.texto,
       num_programa    LIKE audit_logix.num_programa,
       usuario         LIKE audit_logix.usuario
END RECORD

DEFINE p_den_estr_linprod     CHAR(30),
       p_ies_versao_atual     CHAR(01),
       p_num_versao           INTEGER

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1232-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET p_parametro.num_programa = 'POL1232'
   LET p_parametro.cod_empresa = p_cod_empresa
   LET p_parametro.usuario = p_user
      
   IF p_status = 0 THEN
      CALL pol1232_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1232_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1232") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   
   OPEN WINDOW w_pol1232 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1232_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1232_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1232_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1232_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1232_modificacao() RETURNING p_status  
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
            CALL pol1232_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      {COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1232_listagem()}
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1232_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1232

END FUNCTION

#-----------------------#
 FUNCTION pol1232_sobre()
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
FUNCTION pol1232_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1232_inclusao()
#--------------------------#

   CALL pol1232_limpa_tela()
   
   INITIALIZE p_tabela TO NULL

   LET p_tabela.cod_empresa = p_cod_empresa
   LET p_tabela.num_versao = 1
   LET p_tabela.ies_versao_atual = 'S'
   LET p_tabela.nom_usuario_cad = p_user
   LET p_tabela.dat_cadast = TODAY  
   LET p_tabela.hor_cadast = TIME
   
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1232_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1232_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1232_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1232_insere()
#------------------------#

   INSERT INTO tabela_trava90_454 VALUES (p_tabela.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","tabela_trava90_454")       
      RETURN FALSE
   END IF

   LET p_parametro.texto = 'INCLUSAO DA LINHA DE PRODUTO ',  p_tabela.cod_lin_prod

   IF NOT pol1161_grava_auadit(p_parametro) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1232_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE   
   
   INPUT BY NAME p_tabela.* WITHOUT DEFAULTS
              
      BEFORE FIELD cod_lin_prod

         IF p_funcao = "M" THEN
            NEXT FIELD val_med_mensal
         END IF
      
      AFTER FIELD cod_lin_prod

         IF p_tabela.cod_lin_prod IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_lin_prod   
         END IF
         
         CALL pol1232_le_den_linha()          
         
         IF p_den_estr_linprod IS NULL THEN 
            ERROR 'Linha de produto inexistente.'
            NEXT FIELD cod_lin_prod
         END IF  
         
         DISPLAY p_den_estr_linprod TO den_estr_linprod

         SELECT COUNT(cod_lin_prod)
           INTO p_count
           FROM tabela_trava90_454
          WHERE cod_empresa = p_cod_empresa
            AND cod_lin_prod = p_tabela.cod_lin_prod

         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','tabela_trava90_454')
            RETURN FALSE
         END IF 
         
         IF p_count > 0 THEN
            ERROR 'Linha já cadastrada no pol1232'
            NEXT FIELD cod_lin_prod
         END IF
                  
         

      AFTER FIELD val_med_mensal
         
         IF p_tabela.val_med_mensal IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD val_med_mensal
         END IF

      AFTER FIELD estoq_quando_menor

         IF p_tabela.estoq_quando_menor IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD estoq_quando_menor
         END IF

      AFTER FIELD estoq_quando_maior
        
         IF p_tabela.estoq_quando_maior IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD estoq_quando_maior
         END IF

      AFTER FIELD lote_quando_menor
        
         IF p_tabela.lote_quando_menor IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD lote_quando_menor
         END IF

      AFTER FIELD lote_quando_maior
        
         IF p_tabela.lote_quando_maior IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD lote_quando_maior
         END IF

      AFTER FIELD limit_quando_menor
 
         IF p_tabela.limit_quando_menor IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD limit_quando_menor
         END IF

      AFTER FIELD limit_quando_maior

         IF p_tabela.limit_quando_maior IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD limit_quando_maior
         END IF

      ON KEY (control-z)
         CALL pol1232_popup()
               
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1232_le_den_linha()#
#------------------------------#

    SELECT den_estr_linprod
      INTO p_den_estr_linprod
      FROM linha_prod
     WHERE cod_lin_prod  = p_tabela.cod_lin_prod
       AND cod_lin_recei = 0
       AND cod_seg_merc = 0
       AND cod_cla_uso = 0
       
   IF STATUS <> 0 THEN
      LET p_den_estr_linprod = NULL
   END IF

END FUNCTION   
      

#-----------------------#
 FUNCTION pol1232_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_lin_prod)
         LET p_codigo = pol1232_le_linhas()
         IF p_codigo IS NOT NULL THEN
           LET p_tabela.cod_lin_prod = p_codigo
           DISPLAY p_codigo TO cod_lin_prod
         END IF
         
   END CASE 

END FUNCTION 

#---------------------------#
 FUNCTION pol1232_le_linhas()
#---------------------------#

   DEFINE pr_itens     ARRAY[200] OF RECORD
          cod_lin_prod      DECIMAL(2,0),
          den_estr_linprod  CHAR(30)
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1232a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1232a AT 5,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_itens CURSOR FOR
   
    SELECT cod_lin_prod,
           den_estr_linprod
      FROM linha_prod
     WHERE cod_lin_recei = 0
       AND cod_seg_merc = 0
       AND cod_cla_uso = 0
     ORDER BY den_estr_linprod

   FOREACH cq_itens
      INTO pr_itens[p_ind].*   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_itens')
         EXIT FOREACH
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 200 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_itens TO sr_itens.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol1232a
   
   IF NOT INT_FLAG THEN
      RETURN pr_itens[p_ind].cod_lin_prod
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#--------------------------#
 FUNCTION pol1232_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1232_limpa_tela()
   LET p_tabelaa.* = p_tabela.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      tabela_trava90_454.cod_lin_prod,
      tabela_trava90_454.val_med_mensal,
      tabela_trava90_454.nom_usuario_cad
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1232_limpa_tela()
         ELSE
            LET p_tabela.* = p_tabelaa.*
            CALL pol1232_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM tabela_trava90_454 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND ies_versao_atual = 'S' ",
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_lin_prod"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_tabela.*

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1232_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1232_exibe_dados()
#------------------------------#
   
   CALL pol1232_le_den_linha()
   DISPLAY BY NAME p_tabela.*
   DISPLAY p_den_estr_linprod TO den_estr_linprod
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1232_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_tabelaa.* = p_tabela.*
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_tabela.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_tabela.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_lin_prod
           FROM tabela_trava90_454
          WHERE cod_empresa = p_cod_empresa
            AND cod_lin_prod = p_tabela.cod_lin_prod
            AND ies_versao_atual = 'S'
            
         IF STATUS = 0 THEN
            CALL pol1232_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_tabela.* = p_tabelaa.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1232_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_lin_prod
      FROM tabela_trava90_454  
     WHERE cod_empresa = p_cod_empresa
       AND cod_lin_prod = p_tabela.cod_lin_prod
       AND ies_versao_atual = 'S'
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","tabela_trava90_454")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1232_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF

   #IF NOT pol1232_checa_versao() THEN
    #  RETURN FALSE
   #END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_tabelaa.* = p_tabela.*
   
   IF pol1232_prende_registro() THEN
      IF pol1232_edita_dados("M") THEN
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
      LET p_tabela.* = p_tabelaa.*
      CALL pol1232_exibe_dados() RETURNING p_status
   END IF

   RETURN p_retorno

END FUNCTION

#------------------------------#
FUNCTION pol1232_checa_versao()
#------------------------------#

   IF p_tabela.ies_versao_atual = 'N' THEN
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

   UPDATE tabela_trava90_454
      SET ies_versao_atual = 'N'
    WHERE cod_empresa = p_cod_empresa
      AND cod_lin_prod = p_tabelaa.cod_lin_prod
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "tabela_trava90_454")
      RETURN FALSE
   END IF

   LET p_tabela.num_versao = p_tabela.num_versao + 1
   LET p_tabela.nom_usuario_cad = p_user
   LET p_tabela.dat_cadast = TODAY  
   LET p_tabela.hor_cadast = TIME
   
   IF NOT pol1232_insere() THEN
      RETURN FALSE
   END IF

   LET p_parametro.texto = 'ALTERACAO DA LINHA DE PRODUCAO ', p_tabela.cod_lin_prod
   
   IF NOT pol1161_grava_auadit(p_parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1232_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF

   #IF NOT pol1232_checa_versao() THEN
   #   RETURN FALSE
   #END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1232_prende_registro() THEN
      IF pol1232_deleta() THEN
         INITIALIZE p_tabela TO NULL
         CALL pol1232_limpa_tela()
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
FUNCTION pol1232_deleta()
#------------------------#

   DELETE FROM tabela_trava90_454
    WHERE cod_empresa = p_cod_empresa
      AND cod_lin_prod = p_tabela.cod_lin_prod

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","tabela_trava90_454")
      RETURN FALSE
   END IF

   LET p_parametro.texto = 'EXCLUSAO DA LINHA DE PRODUCAO ', p_tabela.cod_lin_prod

   IF NOT pol1161_grava_auadit(p_parametro) THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

{
#--------------------------#
 FUNCTION pol1232_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1232_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1232_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_lin_prod,
          nom_contato,
          num_agencia,
          nom_agencia,
          num_conta,
          cod_tip_reg,
          dat_termino
     FROM tabela_trava90_454
 ORDER BY cod_lin_prod                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT den_nivel_autorid
        INTO p_den_nivel_autorid
        FROM bancos
       WHERE cod_lin_prod = p_relat.cod_lin_prod
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'bancos')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1232_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1232_relat   
   
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
 FUNCTION pol1232_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1232.tmp"
         START REPORT pol1232_relat TO p_caminho
      ELSE
         START REPORT pol1232_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1232_le_den_empresa()
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
 REPORT pol1232_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1232",
               COLUMN 042, "BANCOS PARA EMPRESTIMOS CONSIGNADOS",
               COLUMN 114, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, 'Banco          Descricao                       Contato              Agencia           Descricao                Conta       Identif   Termino'
         PRINT COLUMN 002, '----- ------------------------------ ------------------------------ ------- ------------------------------ --------------- -------- ----------'
                            
      ON EVERY ROW

         PRINT COLUMN 004, p_relat.cod_lin_prod   USING "###",
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