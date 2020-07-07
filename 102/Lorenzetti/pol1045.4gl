#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1045                                                 #
# OBJETIVO: CADASTRO DE CONTAS CONTÁBEIS                            #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 29/06/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_cod_emp_plano      LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_den_familia        LIKE familia.den_familia,
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
          p_msg                CHAR(300),
          p_last_row           SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_den_tipo           char(20)
         
  
   DEFINE p_contas_912         RECORD 
          cod_empresa          char(2),
          cod_tip_nf           decimal(2,0),
          cod_tip_item         decimal(2,0),
          tributo              char(30),    
          num_conta_cred       char(23),    
          num_conta_deb        char(23)      
   end record

   DEFINE p_contas_912_ant     RECORD 
          cod_empresa          char(2),
          cod_tip_nf           decimal(2,0),
          cod_tip_item         decimal(2,0),
          tributo              char(30),    
          num_conta_cred       char(23),    
          num_conta_deb        char(23)      
   end record
      
   DEFINE p_denominacao        LIKE tipo_ad.denominacao,
          p_tributo            CHAR(20)
          
   DEFINE p_tela               RECORD
          cod_empresa          char(2),
          cod_tip_nf           decimal(2,0),
          cod_tip_item         decimal(2,0)
   END RECORD
   
   DEFINE pr_contas            ARRAY[10] OF RECORD 
          num_conta_cred       char(15),  
          num_conta_deb        char(15)
   END RECORD 
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1045-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("SUPRIMEN","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1045_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1045_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1045") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1045 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1045_limpa_tela()

   IF NOT pol1045_le_parametros() THEN
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol1045_inclusao() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = FALSE
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
         IF pol1045_consulta() THEN
            LET p_ies_cons = TRUE
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1045_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1045_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1045_modificacao() RETURNING p_retorno  
            IF p_retorno THEN
               DISPLAY p_contas_912.cod_tip_nf   TO cod_tip_nf
               DISPLAY p_contas_912.cod_tip_item TO cod_tip_item
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol1045_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1045_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1045

END FUNCTION

#-----------------------#
FUNCTION pol1045_sobre()
#-----------------------#

   DEFINE p_dat DATETIME YEAR TO SECOND
   
   LET p_dat = CURRENT
   
   LET p_msg = p_versao CLIPPED,"\n\n",
               " Alteração: ",p_dat,"\n\n",
               " LOGIX 05.10 \n\n",
               " Home page: www.aceex.com.br \n\n",
               " (0xx11) 4991-6667 \n\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
FUNCTION pol1045_le_parametros()
#-------------------------------#

   SELECT cod_empresa_plano
     INTO p_cod_emp_plano
     FROM par_con
    WHERE cod_empresa = p_cod_empresa

   if p_cod_emp_plano is null or p_cod_emp_plano = ' ' THEN
      LET p_cod_emp_plano = p_cod_empresa
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','emp_orig_destino')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
 FUNCTION pol1045_limpa_tela()
#----------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 
   
#--------------------------#
 FUNCTION pol1045_inclusao()
#--------------------------#
   
   CALL pol1045_limpa_tela()
   
   CALL log085_transacao("BEGIN") 
   
   IF NOT pol1045_edita_dados() THEN 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   IF NOT pol1045_edita_dados_array("I") THEN 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   IF NOT pol1045_grava_dados() THEN 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE 

END FUNCTION

#-------------------------------#
 FUNCTION pol1045_edita_dados()
#-------------------------------#
   
   LET INT_FLAG = FALSE 
   CALL pol1045_limpa_tela()
   INITIALIZE p_tela.* TO NULL
   
   LET p_tela.cod_empresa = p_cod_empresa
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
      
#------------------- CONSISTINDO O ITEM -------------------# 
         
      AFTER FIELD cod_tip_nf
         IF p_tela.cod_tip_nf IS NULL THEN 
            ERROR "Campo com prenchimento obrigatório !!!"
            NEXT FIELD cod_tip_nf
         END IF
      
         IF NOT p_tela.cod_tip_nf MATCHES '[1256]' THEN 
            ERROR "Valor ilegal para o campo em questão !!!"
            NEXT FIELD cod_tip_nf
         END IF 
         
         let p_den_tipo = pol1045_den_tipo(p_tela.cod_tip_nf)
         DISPLAY p_den_tipo to den_tipo
         
      AFTER FIELD cod_tip_item
         IF p_tela.cod_tip_item IS NULL THEN 
            ERROR "Campo com prenchimento obrigatório !!!"
            NEXT FIELD cod_tip_item
         END IF
         
         SELECT DISTINCT (cod_tip_item)
           FROM contas_912
          WHERE cod_empresa  = p_cod_empresa
            AND cod_tip_nf   = p_tela.cod_tip_nf
            AND cod_tip_item = p_tela.cod_tip_item
            
         IF STATUS = 0 THEN 
            ERROR "Registro já cadastrado na tabela contas_912 !!!"
            NEXT FIELD cod_tip_item
         ELSE
            IF STATUS <> 100 THEN 
               CALL log003_err_sql("Lendo", "contas_912")
               RETURN FALSE 
            END IF 
         END IF
         
         SELECT cod_tip_item
           FROM tipo_item_912
          WHERE cod_empresa  = p_cod_empresa
            AND cod_tip_item = p_tela.cod_tip_item
            
         IF STATUS = 100 THEN 
            ERROR "Tipo de item não encontrado na tabela tipo_item_912 !!!"
            NEXT FIELD cod_tip_item
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql("Lendo", "tipo_item_912")
               RETURN FALSE 
            END IF 
         END IF
            
         SELECT denominacao
           INTO p_denominacao
           FROM tipo_ad
          WHERE cod_tip_ad = p_tela.cod_tip_item
          
         IF STATUS = 100 THEN 
            ERROR "Tipo de item não encontrado na tabela tipo_ad !!!"
            NEXT FIELD cod_tip_item
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql("Lendo", "tipo_ad")
               RETURN FALSE 
            END IF 
         END IF
         
         DISPLAY p_denominacao TO denominacao 
         
         ON KEY (control-z)
            CALL pol1045_popup()
            
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1045_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1045_den_tipo(p_tip_nf)
#---------------------------------#

   define p_tip_nf integer

   case p_tip_nf
      when 1 RETURN 'NF Primeira'
      when 2 RETURN 'NF Complementar'
      when 5 RETURN 'NF Mãe'
      when 6 RETURN 'NF Filha'
   end case

END FUNCTION

#-------------------------------------------#
 FUNCTION pol1045_edita_dados_array(p_funcao)
#-------------------------------------------#      
   
   DEFINE p_funcao CHAR(01)
   
   LET INT_FLAG = FALSE
   
   IF p_funcao = "I" THEN 
      INITIALIZE pr_contas TO NULL
      LET p_index = 1 
   END IF 
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_contas
      WITHOUT DEFAULTS FROM sr_contas.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
                         
         AFTER FIELD num_conta_cred
           
            IF pr_contas[p_index].num_conta_cred IS NOT NULL THEN 
               
               SELECT num_conta
                 FROM plano_contas
                WHERE cod_empresa = p_cod_emp_plano
                  AND num_conta_reduz = pr_contas[p_index].num_conta_cred 
                  
               IF STATUS = 100 THEN 
               
                  IF pr_contas[p_index].num_conta_cred <> 'ITEM_SUP' THEN
                     ERROR "Conta inexistente na tabela plano_contas !!!"
                     NEXT FIELD num_conta_cred
                  END IF
                                    
               ELSE
                  IF STATUS <> 0 THEN 
                     CALL log003_err_sql("Lendo", "plano_contas")
                     RETURN FALSE
                  END IF 
               END IF 
               
            END IF  
            
         AFTER FIELD num_conta_deb
            
            IF pr_contas[p_index].num_conta_deb IS NOT NULL THEN 
               
               SELECT num_conta
                 FROM plano_contas
                WHERE cod_empresa = p_cod_emp_plano
                  AND num_conta_reduz = pr_contas[p_index].num_conta_deb 
                  
               IF STATUS = 100 THEN 
               
                  IF pr_contas[p_index].num_conta_deb <> 'ITEM_SUP' THEN
                     ERROR "Conta inexistente na tabela plano_contas !!!"
                     NEXT FIELD num_conta_deb
                  END IF
               ELSE
                  IF STATUS <> 0 THEN 
                     CALL log003_err_sql("Lendo", "plano_contas")
                     RETURN FALSE
                  END IF 
               END IF 
               
            END IF 
            
         ON KEY (control-z)
            CALL pol1045_popup()       
   
   END INPUT 
      
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      LET INT_FLAG = TRUE
      RETURN TRUE
   END IF   
   
END FUNCTION

#-----------------------#
 FUNCTION pol1045_popup()
#-----------------------#

   DEFINE p_codigo CHAR(23)

   CASE

      WHEN INFIELD(cod_tip_item)
         LET p_codigo = pol1045_cod_tip_item()
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_tip_item = p_codigo
           DISPLAY p_codigo TO cod_tip_item
         END IF     

      WHEN INFIELD(num_conta_cred)
         CALL log009_popup(8,10,"CONTAS","plano_contas",
                     "num_conta_reduz","den_conta","","N"," 1=1 order by num_conta_reduz")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         current WINDOW is w_pol1045
         IF p_codigo IS NOT NULL THEN
            LET pr_contas[p_index].num_conta_cred = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_contas[s_index].num_conta_cred
         END IF
         
      WHEN INFIELD(num_conta_deb)
         CALL log009_popup(8,10,"CONTAS","plano_contas",
                     "num_conta_reduz","den_conta","","N"," 1=1 order by num_conta_reduz")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         current WINDOW is w_pol1045
         IF p_codigo IS NOT NULL THEN
            LET pr_contas[p_index].num_conta_deb = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_contas[s_index].num_conta_deb
         END IF
   
   END CASE 
   
END FUNCTION 
   

#------------------------------#
 FUNCTION pol1045_cod_tip_item()
#------------------------------#

   DEFINE pr_cod_tip_item  ARRAY[500] OF RECORD
          cod_tip_item     LIKE tipo_item_912.cod_tip_item,
          denominacao      LIKE tipo_ad.denominacao
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10451") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10451 AT 7,16 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
   
   DECLARE cq_tip_item CURSOR FOR
   
   SELECT a.cod_tip_item,
          b.denominacao
     FROM tipo_item_912 a,
          tipo_ad b
    WHERE a.cod_empresa  = p_cod_empresa
      AND a.cod_tip_item = b.cod_tip_ad

   FOREACH cq_tip_item 
      INTO pr_cod_tip_item[p_ind].cod_tip_item,
           pr_cod_tip_item[p_ind].denominacao
        
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_tip_item')
         EXIT FOREACH
      END IF
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 500 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassado!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
           
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Nenhum registro foi encontrado, para os parâmetros informados!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN ""
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_cod_tip_item TO sr_cod_tip_item.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol10451
   
   IF NOT INT_FLAG THEN
      RETURN pr_cod_tip_item[p_ind].cod_tip_item
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1045_grava_dados()
#-----------------------------#  

   IF NOT pol1045_deleta_dados() THEN 
      RETURN FALSE
   END IF 
      
   FOR p_ind = 1 TO ARR_COUNT()
      
      CASE p_ind
      
         WHEN 1
           LET p_tributo = 'val_ipi'
        
         WHEN 2
           LET p_tributo = 'val_icms'
        
         WHEN 3
           LET p_tributo = 'val_pis'
        
         WHEN 4
           LET p_tributo = 'val_cofins'
        
         WHEN 5
           LET p_tributo = 'val_liquido'
        
         WHEN 6
           LET p_tributo = 'val_contabil'        
      
         WHEN 7
           LET p_tributo = 'val_frete'        

         WHEN 8
           LET p_tributo = 'val_icms_frete'        
         
         WHEN 9
           LET p_tributo = 'val_pis_frete'        

         WHEN 10
           LET p_tributo = 'val_cofins_frete'        


      END CASE 
       
      INSERT INTO contas_912
		      VALUES (p_cod_empresa,
		              p_tela.cod_tip_nf,
		              p_tela.cod_tip_item,
		              p_tributo,
		              pr_contas[p_ind].num_conta_cred,
		              pr_contas[p_ind].num_conta_deb)
		
		  IF STATUS <> 0 THEN 
		     CALL log003_err_sql("Gravando","contas_912")
		     RETURN FALSE
		  END IF
            
   END FOR
                  
   RETURN TRUE
      
END FUNCTION 
   
#------------------------------#
 FUNCTION pol1045_deleta_dados()
#------------------------------#

   DELETE FROM contas_912
         WHERE cod_empresa  = p_cod_empresa
           AND cod_tip_nf   = p_tela.cod_tip_nf
           AND cod_tip_item = p_tela.cod_tip_item
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Deletando", "contas_912")
      RETURN FALSE
   END IF 
   
   RETURN TRUE 
   
END FUNCTION           
  
#--------------------------#
 FUNCTION pol1045_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1045_limpa_tela()
      
   LET p_contas_912_ant.* = p_contas_912.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      contas_912.cod_tip_nf,
      contas_912.cod_tip_item
    
      ON KEY (control-z)
         CALL pol1045_popup()
         
   END CONSTRUCT 
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_contas_912.* = p_contas_912_ant.*
         CALL pol1045_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF
   
   LET sql_stmt = "SELECT DISTINCT cod_tip_nf, cod_tip_item",
                  "  FROM contas_912 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_tip_nf, cod_tip_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_contas_912.cod_tip_nf, p_contas_912.cod_tip_item

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1045_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol1045_exibe_dados()
#-----------------------------#
   
   SELECT denominacao
     INTO p_denominacao
     FROM tipo_ad
    WHERE cod_tip_ad = p_contas_912.cod_tip_item
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo", "tipo_ad")
      RETURN FALSE
   END IF 
   
   let p_tela.cod_tip_nf   = p_contas_912.cod_tip_nf
   let p_tela.cod_tip_item = p_contas_912.cod_tip_item 
     
   DISPLAY p_cod_empresa             TO cod_empresa
   DISPLAY p_contas_912.cod_tip_nf   TO cod_tip_nf
   let p_den_tipo = pol1045_den_tipo(p_contas_912.cod_tip_nf)
   DISPLAY p_den_tipo to den_tipo
   DISPLAY p_contas_912.cod_tip_item TO cod_tip_item
   DISPLAY p_denominacao             TO denominacao

   IF NOT pol1045_carrega_array() THEN 
      RETURN FALSE
   END IF 

   CALL SET_COUNT(p_index - 1)
   current WINDOW is w_pol1045
   
   INPUT ARRAY pr_contas WITHOUT DEFAULTS FROM sr_contas.*
      
      BEFORE INPUT
         EXIT INPUT
         
   END INPUT
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
 FUNCTION pol1045_carrega_array()
#-------------------------------#
   
   LET p_index = 1
   
   DECLARE cq_array CURSOR FOR
   
   SELECT num_conta_cred,
          num_conta_deb
     FROM contas_912
    WHERE cod_empresa  = p_cod_empresa
      AND cod_tip_nf   = p_contas_912.cod_tip_nf
      AND cod_tip_item = p_contas_912.cod_tip_item
            
   FOREACH cq_array INTO
           pr_contas[p_index].num_conta_cred,
           pr_contas[p_index].num_conta_deb
           
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo", "Cursor: cq_array")
         RETURN FALSE
      END IF
      
      
      LET p_index = p_index + 1
      
      IF  p_index > 10 THEN
          EXIT FOREACH 
      END IF  
            
   END FOREACH 
   
   RETURN TRUE
   
END FUNCTION  

#-----------------------------------#
 FUNCTION pol1045_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_contas_912_ant.cod_tip_nf   = p_contas_912.cod_tip_nf
   LET p_contas_912_ant.cod_tip_item = p_contas_912.cod_tip_item

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO 
              p_contas_912.cod_tip_nf, p_contas_912.cod_tip_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO 
              p_contas_912.cod_tip_nf, p_contas_912.cod_tip_item
         
      END CASE

      IF STATUS = 0 THEN
         SELECT DISTINCT (cod_tip_nf)
           FROM contas_912
          WHERE cod_empresa  = p_cod_empresa
            AND cod_tip_nf   = p_contas_912.cod_tip_nf
            AND cod_tip_item = p_contas_912.cod_tip_item
             
         IF STATUS = 0 THEN
            CALL pol1045_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_contas_912.cod_tip_nf   = p_contas_912_ant.cod_tip_nf
            LET p_contas_912.cod_tip_item = p_contas_912_ant.cod_tip_item
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1045_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    
    SELECT cod_tip_nf 
      FROM contas_912  
     WHERE cod_empresa  = p_cod_empresa
       AND cod_tip_nf   = p_contas_912.cod_tip_nf
       AND cod_tip_item = p_contas_912.cod_tip_item
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","contas_912")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1045_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   IF pol1045_prende_registro() THEN
      IF pol1045_edita_dados_array("M") THEN
         LET p_tela.cod_tip_nf   = p_contas_912.cod_tip_nf
         LET p_tela.cod_tip_item = p_contas_912.cod_tip_item
         IF pol1045_grava_dados() THEN    
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
 FUNCTION pol1045_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1045_prende_registro() THEN
      DELETE FROM contas_912
			 WHERE cod_empresa  = p_cod_empresa
         AND cod_tip_nf   = p_contas_912.cod_tip_nf
         AND cod_tip_item = p_contas_912.cod_tip_item
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_contas_912.* TO NULL
         CALL pol1045_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","contas_912")
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

#-------------------------------- FIM DE PROGRAMA -----------------------------#
