#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0701                                                 #
# OBJETIVO: COTA��O DE PRE�O - CIBRAPEL (RIO DE JANEIRO)            #
# AUTOR...: ACEEX DESENVOLVIMENTO DE SISTEMAS                       #
# DATA....: 18/12/2007                                              #
# CONVERS�O 10.02: 30/07/2014 - IVO                                 #
# FUN��ES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_cod_fornecedor     LIKE cotacao_preco_885.cod_fornecedor,
          p_cod_item           LIKE cotacao_preco_885.cod_item,
          p_preco              LIKE cotacao_preco_885.pre_unit_fob,
          p_den_item           LIKE item.den_item,
          p_raz_social         LIKE fornecedor.raz_social,
          p_user               LIKE usuario.nom_usuario,
          p_preco_fob          CHAR(12),
          p_preco_cif          CHAR(12),
          p_den_texto          CHAR(78),
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080)

END GLOBALS


   DEFINE p_cod_formulario     CHAR(03),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          pr_index2            SMALLINT,  
          sr_index2            SMALLINT,
          pre_unit_fob         DECIMAL(17,6),  
          p_codigo             CHAR(15),
          p_des_cnd_pgto       CHAR(30),
          p_ies_auditoria      SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_msg                CHAR(300),
          p_max_dat_fim        DATE,
          p_id_registro        INTEGER
          
   DEFINE p_cotacao_preco_885  RECORD 
    cod_empresa                CHAR(2),      
    cod_item                   CHAR(15),     
    cod_fornecedor             CHAR(15),     
    pre_unit_fob               DECIMAL(17,6),
    pre_unit_cif               DECIMAL(17,6),
    cnd_pgto                   DECIMAL(3,0), 
    dat_val_ini                DATE,     
    dat_val_fim                DATE,     
    id_registro                INTEGER,      
    regiao_lagos               CHAR(01)      
  END RECORD

   DEFINE p_cotacao_preco_885a RECORD 
    cod_empresa                CHAR(2),      
    cod_item                   CHAR(15),     
    cod_fornecedor             CHAR(15),     
    pre_unit_fob               DECIMAL(17,6),
    pre_unit_cif               DECIMAL(17,6),
    cnd_pgto                   DECIMAL(3,0), 
    dat_val_ini                DATE,     
    dat_val_fim                DATE,     
    id_registro                INTEGER,      
    regiao_lagos               CHAR(01)      
  END RECORD
   
   DEFINE p_auditoria          RECORD
          cod_item             CHAR(15),
          cod_fornecedor       CHAR(15),
          nom_usuario          CHAR(08)
   END RECORD
                                                         
   DEFINE pr_auditoria         ARRAY[5000] OF RECORD
          cod_item_array       CHAR(15),
          cod_fornecedor_array CHAR(15),
          nom_usuario_array    CHAR(08),
          dat_proces           DATETIME YEAR TO SECOND,
          den_texto            CHAR(78)
   END RECORD       

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0701-10.02.00 "
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0701.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0701_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0701_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0701") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0701 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    DISPLAY p_cod_empresa TO cod_empresa
    
    IF NOT pol0701_atualiza_id_registro() THEN
       RETURN 
    END IF
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0701_inclusao() THEN
            MESSAGE 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Opera��o cancelada !!!'
         END IF
       COMMAND "Modificar" "Modifica Dados da Tabela."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0701_modificacao() THEN
               MESSAGE 'Modifica��o efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao !!!"
         END IF 
      COMMAND "Excluir" "Exclui Dados da Tabela."
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0701_exclusao() THEN
               MESSAGE 'Exclus�o efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao !!!"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela."
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0701_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta."
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0701_paginacao("S")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta."
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0701_paginacao("A")
      COMMAND KEY ("D") "auDitoria" "Consulta dos processos efetuados por usu�rios neste programa."
         IF NOT pol0701_auditoria() THEN
            LET p_ies_auditoria = FALSE
            ERROR "Consulta cancelada !!!"
         ELSE
            LET p_ies_auditoria = FALSE
            ERROR "Consulta efetuada com sucesso !!!"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0701

END FUNCTION

#---------------------------------------#
 FUNCTION pol0701_atualiza_id_registro()
#---------------------------------------#
   
   INITIALIZE p_cotacao_preco_885.* TO NULL
   
   LET p_id_registro = pol0701_le_id()

   IF p_id_registro = 0 THEN
      RETURN FALSE
   END IF

  DECLARE cq_atualiza CURSOR FOR
   SELECT *
     FROM cotacao_preco_885
    WHERE id_registro IS NULL
  
  FOREACH cq_atualiza INTO p_cotacao_preco_885.*
  
     IF p_cotacao_preco_885.regiao_lagos IS NULL OR
        p_cotacao_preco_885.regiao_lagos = ' ' THEN
        LET p_cotacao_preco_885.regiao_lagos = 'N'
	   END IF
	    
     UPDATE cotacao_preco_885
        SET id_registro = p_id_registro,
            regiao_lagos = p_cotacao_preco_885.regiao_lagos
      WHERE cod_empresa = p_cotacao_preco_885.cod_empresa
        AND cod_fornecedor = p_cotacao_preco_885.cod_fornecedor
        AND cod_item = p_cotacao_preco_885.cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','cotacao_preco_885')
         RETURN FALSE
      END IF

      LET p_id_registro = p_id_registro + 1

  END FOREACH
  
  RETURN TRUE

END FUNCTION


#--------------------------#
 FUNCTION pol0701_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
  
   INITIALIZE p_cotacao_preco_885.* TO NULL
   LET p_cotacao_preco_885.cod_empresa = p_cod_empresa

   IF pol0701_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF NOT pol00701_ins_tabs() THEN
         CALL log085_transacao("ROLLBACK")
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF 
   
   RETURN FALSE

END FUNCTION

#-----------------------#
FUNCTION pol0701_le_id()#
#-----------------------#
 
   DEFINE p_id_reg INTEGER
   
   SELECT MAX(id_registro)
     INTO p_id_reg
     FROM cotacao_preco_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cotacao_preco_885')
      RETURN 0
   END IF
   
   IF p_id_reg IS NULL THEN
      LET p_id_reg = 0
   END IF
   
   LET p_id_reg = p_id_reg + 1
   
   RETURN p_id_reg

END FUNCTION

#---------------------------#
FUNCTION pol00701_ins_tabs()
#---------------------------#

   
   LET p_cotacao_preco_885.id_registro = pol0701_le_id()

   IF p_cotacao_preco_885.id_registro = 0 THEN
      RETURN FALSE
   END IF
   
   INSERT INTO cotacao_preco_885 
    VALUES (p_cotacao_preco_885.*)
    
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo','cotacao_preco_885')
      RETURN FALSE
   END IF
   
   LET p_preco_fob = p_cotacao_preco_885.pre_unit_fob
   LET p_preco_cif = p_cotacao_preco_885.pre_unit_cif
   
   LET p_den_texto = 'INSERIU PRECO FOB = ', p_preco_fob CLIPPED, 
       ' E PRECO CIF = ', p_preco_cif CLIPPED
   
   IF NOT pol0701_ins_audit() THEN
      RETURN FALSE
   END IF
   
   DISPLAY p_cotacao_preco_885.id_registro TO id_registro
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0701_ins_audit()
#---------------------------#

   DEFINE p_audit_cotacao RECORD #LIKE audit_cotacao_885.*
						   	cod_empresa    CHAR (2),
							cod_item       CHAR (15),
							cod_fornecedor CHAR (15),
							nom_usuario    CHAR (15),
							dat_proces     DATETIME YEAR TO SECOND,
							den_texto      CHAR (78)
						END RECORD						   
   LET p_audit_cotacao.cod_empresa    = p_cod_empresa
   LET p_audit_cotacao.cod_item       = p_cotacao_preco_885.cod_item
   LET p_audit_cotacao.cod_fornecedor = p_cotacao_preco_885.cod_fornecedor
   LET p_audit_cotacao.nom_usuario    = p_user
   LET p_audit_cotacao.dat_proces     = CURRENT
   LET p_audit_cotacao.den_texto      = p_den_texto

   INSERT INTO audit_cotacao_885 
    VALUES (p_audit_cotacao.*)
    
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo','audit_cotacao_885')
      RETURN FALSE
   END IF
 
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0701_atualiza_tabs()
#-------------------------------#

   DEFINE p_preco_fob_d,
          p_preco_fob_p,
          p_preco_cif_d,
          p_preco_cif_p CHAR(10)
          
          
   UPDATE cotacao_preco_885
      SET cnd_pgto = p_cotacao_preco_885.cnd_pgto,
          pre_unit_fob = p_cotacao_preco_885.pre_unit_fob,
          pre_unit_cif = p_cotacao_preco_885.pre_unit_cif,
          regiao_lagos = p_cotacao_preco_885.regiao_lagos
    WHERE cod_empresa    = p_cod_empresa
      AND id_registro    = p_cotacao_preco_885.id_registro

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Atualizando','cotacao_preco_885')
      RETURN FALSE
   END IF

   LET p_preco_fob_d = p_cotacao_preco_885a.pre_unit_fob
   LET p_preco_fob_p = p_cotacao_preco_885.pre_unit_fob
   LET p_preco_cif_d = p_cotacao_preco_885a.pre_unit_cif
   LET p_preco_cif_p = p_cotacao_preco_885.pre_unit_cif
   
   LET p_den_texto = 'ALTEROU PRECO FOB DE ', p_preco_fob_d CLIPPED, 
       ' P/ ', p_preco_fob_P CLIPPED, 
       ' E PRECO CIF DE ', p_preco_cif_d CLIPPED, ' P/', p_preco_cif_p CLIPPED
      
   IF NOT pol0701_ins_audit() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0701_deleta_tab()
#----------------------------#

   DELETE FROM cotacao_preco_885
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = p_cotacao_preco_885.id_registro
        
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Deletando','cotacao_preco_885')
      RETURN FALSE
   END IF

   LET p_preco_fob = p_cotacao_preco_885.pre_unit_fob
   LET p_preco_cif = p_cotacao_preco_885.pre_unit_cif
   
   LET p_den_texto = 'EXCLUIU PRECO FOB ', p_preco_fob CLIPPED, 
       ' E PRECO CIF ', p_preco_cif CLIPPED
      
   IF NOT pol0701_ins_audit() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION


#---------------------------------------#
 FUNCTION pol0701_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)
  
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0701

   INPUT p_cotacao_preco_885.cod_empresa,
         p_cotacao_preco_885.regiao_lagos,
         p_cotacao_preco_885.id_registro,   
         p_cotacao_preco_885.cod_item,   
         p_cotacao_preco_885.cod_fornecedor,
         p_cotacao_preco_885.pre_unit_fob,  
         p_cotacao_preco_885.pre_unit_cif,  
         p_cotacao_preco_885.cnd_pgto,      
         p_cotacao_preco_885.dat_val_ini,   
         p_cotacao_preco_885.dat_val_fim  
      WITHOUT DEFAULTS 
         FROM cod_empresa,      
              regiao_lagos,     
              id_registro,       
              cod_item,         
              cod_fornecedor,   
              pre_unit_fob,     
              pre_unit_cif,     
              cnd_pgto,         
              dat_val_ini,      
              dat_val_fim      

      AFTER FIELD regiao_lagos
      
        IF p_cotacao_preco_885.regiao_lagos IS NULL THEN 
           ERROR "Campo com preenchimento obrigat�rio !!!"
           NEXT FIELD regiao_lagos
        END IF  

        IF p_cotacao_preco_885.regiao_lagos MATCHES '[SN]' THEN 
        ELSE
           ERROR "Valor inv�lido para o campo !!!"
           NEXT FIELD regiao_lagos
        END IF  

      BEFORE FIELD cod_item
     
      IF p_funcao = "M" THEN
         NEXT FIELD pre_unit_fob
      END IF   

      AFTER FIELD cod_item
     
      IF p_cotacao_preco_885.cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD cod_item
      ELSE
         SELECT den_item
         INTO p_den_item
         FROM item
         WHERE cod_empresa = p_cod_empresa 
         AND cod_item = p_cotacao_preco_885.cod_item
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Item nao Cadastrado no Logix !!!" 
            NEXT FIELD cod_item
         END IF
         
         DISPLAY p_cotacao_preco_885.cod_item TO cod_item 
         DISPLAY p_den_item TO den_item 
         
      END IF
         
      BEFORE FIELD cod_fornecedor
     
      IF p_funcao = "M" THEN
         NEXT FIELD pre_unit_fob
      END IF   
               
      AFTER FIELD cod_fornecedor
     
      IF p_cotacao_preco_885.cod_fornecedor IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD cod_fornecedor
      ELSE
         SELECT raz_social
         INTO p_raz_social
         FROM fornecedor
         WHERE cod_fornecedor = p_cotacao_preco_885.cod_fornecedor
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do fornecedor nao Cadastrado na Tabela fornecedor !!!" 
            NEXT FIELD cod_fornecedor
         END IF   
         
         DISPLAY p_raz_social TO raz_social 

         SELECT MAX(dat_val_fim)
           INTO p_max_dat_fim
         FROM cotacao_preco_885
         WHERE cod_item = p_cotacao_preco_885.cod_item
           AND cod_fornecedor = p_cotacao_preco_885.cod_fornecedor
           AND regiao_lagos   = p_cotacao_preco_885.regiao_lagos
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cotacao_preco_885')
            NEXT FIELD cod_fornecedor
         END IF 
         
      END IF

      AFTER FIELD pre_unit_fob
      
        IF p_cotacao_preco_885.pre_unit_fob IS NULL THEN 
           ERROR "Campo com preenchimento obrigat�rio !!!"
           NEXT FIELD pre_unit_fob
        END IF  

      AFTER FIELD pre_unit_cif
      
        IF p_cotacao_preco_885.pre_unit_cif IS NULL THEN 
           ERROR "Campo com preenchimento obrigat�rio !!!"
           NEXT FIELD pre_unit_cif
        END IF  
        
      AFTER FIELD cnd_pgto
      
        IF p_cotacao_preco_885.cnd_pgto IS NULL THEN 
           ERROR "Campo com preenchimento obrigat�rio !!!"
           NEXT FIELD cnd_pgto
        END IF  
        
        IF NOT pol0701_le_cond() THEN
           ERROR 'Condi��o de pagamento n�o cadastrada no CAP'
           NEXT FIELD cnd_pgto
        END IF
        
        DISPLAY p_des_cnd_pgto TO des_cnd_pgto
        
        BEFORE FIELD dat_val_ini

          IF p_funcao = "M" THEN
             EXIT INPUT
          END IF   
        
          IF p_cotacao_preco_885.dat_val_ini IS NULL THEN
             LET p_cotacao_preco_885.dat_val_ini =  p_max_dat_fim + 1
          END IF

        BEFORE FIELD dat_val_fim

          IF p_funcao = "M" THEN
             EXIT INPUT
          END IF   
      
        ON KEY (control-z)
                CALL pol0701_popup()
      
        AFTER INPUT
           IF NOT INT_FLAG AND p_funcao = 'I' THEN
              IF p_cotacao_preco_885.dat_val_ini IS NULL THEN
                 ERROR "Campo com preenchimento obrigat�rio !!!"
                 NEXT FIELD dat_val_ini
              END IF  
              IF p_cotacao_preco_885.dat_val_fim IS NULL THEN
                 ERROR "Campo com preenchimento obrigat�rio !!!"
                 NEXT FIELD dat_val_fim
              END IF  
              IF p_cotacao_preco_885.dat_val_ini > p_cotacao_preco_885.dat_val_fim THEN
                 ERROR "Per�odo inv�lido !!!"
                 NEXT FIELD dat_val_ini
              END IF  
              {IF p_cotacao_preco_885.dat_val_fim < TODAY THEN
                 ERROR "Data deve ser maior ou igual a hoje !!!"
                 NEXT FIELD dat_val_fim
              END IF}
              IF p_max_dat_fim IS NOT NULL THEN
                 IF p_cotacao_preco_885.dat_val_ini < p_max_dat_fim THEN
                    LET p_msg = 'A data inicial deve ser maior que ',p_max_dat_fim,',\n',
                                'pois j� existe um per�odo cadastrado com \n',
                                'data final = ',p_max_dat_fim,'\n'
                    CALL log0030_mensagem(p_msg,'excla')
                    NEXT FIELD dat_val_ini
                 END IF
              END IF
           END IF
              
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0701

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------#
FUNCTION pol0701_le_cond()
#-------------------------#

   SELECT des_cnd_pgto
     INTO p_des_cnd_pgto
     FROM cond_pgto_cap
    WHERE cnd_pgto = p_cotacao_preco_885.cnd_pgto
    
   IF STATUS <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#--------------------------#
 FUNCTION pol0701_consulta()
#--------------------------#
   
   DEFINE sql_stmt, 
          where_clause CHAR(600)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cotacao_preco_885a.* = p_cotacao_preco_885.*

   CONSTRUCT BY NAME where_clause ON 
      cotacao_preco_885.regiao_lagos,
      cotacao_preco_885.cod_item,
      cotacao_preco_885.cod_fornecedor  
  
  ON KEY (control-z)
      CALL pol0701_popup()
   
 END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0701

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_cotacao_preco_885.* = p_cotacao_preco_885a.*
      CALL pol0701_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM cotacao_preco_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_fornecedor, cod_item, regiao_lagos, dat_val_ini "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   
   OPEN cq_padrao
   
   FETCH cq_padrao INTO p_cotacao_preco_885.*
   
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0701_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0701_exibe_dados()
#------------------------------#
    
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa 
      AND cod_item = p_cotacao_preco_885.cod_item
 
   SELECT raz_social
     INTO p_raz_social
     FROM fornecedor
    WHERE  cod_fornecedor = p_cotacao_preco_885.cod_fornecedor
   
   CALL pol0701_le_cond() RETURNING p_status
   
   DISPLAY BY NAME p_cotacao_preco_885.*
   
   DISPLAY p_den_item TO den_item
   DISPLAY p_raz_social TO raz_social
   DISPLAY p_des_cnd_pgto TO des_cnd_pgto
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0701_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   DECLARE cm_padrao CURSOR FOR

   SELECT * 
     INTO p_cotacao_preco_885.*                                              
     FROM cotacao_preco_885
    WHERE cod_empresa = p_cod_empresa  
      AND id_registro = p_cotacao_preco_885.id_registro
   FOR UPDATE
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","cotacao_preco_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0701_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0701_cursor_for_update() THEN
      LET p_cotacao_preco_885a.* = p_cotacao_preco_885.*
      IF pol0701_entrada_dados("M") THEN
         IF pol0701_atualiza_tabs() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         LET p_cotacao_preco_885.* = p_cotacao_preco_885a.*
         CALL pol0701_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION 

#--------------------------#
 FUNCTION pol0701_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0701_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         IF pol0701_deleta_tab() THEN
            INITIALIZE p_cotacao_preco_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         END IF
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0701_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   IF p_ies_cons THEN
      LET p_cotacao_preco_885a.* = p_cotacao_preco_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO 
                            p_cotacao_preco_885.*
            WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO 
                            p_cotacao_preco_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Dire��o"
            LET p_cotacao_preco_885.* = p_cotacao_preco_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_cotacao_preco_885.*
           FROM cotacao_preco_885
          WHERE cod_empresa = p_cod_empresa 
            AND id_registro = p_cotacao_preco_885.id_registro
                         
         IF STATUS = 0 THEN  
            CALL pol0701_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0701_popup()
#-----------------------#
   DEFINE p_codigo  CHAR(15),
          p_codigo2 CHAR(15)
     
   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_ies_auditoria THEN
            CURRENT WINDOW IS w_pol07013
            IF p_codigo IS NOT NULL THEN
               LET p_auditoria.cod_item = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_item
            END IF
         ELSE
            CURRENT WINDOW IS w_pol0701
            IF p_codigo IS NOT NULL THEN
               LET p_cotacao_preco_885.cod_item = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_item
            END IF
         END IF
                  
       WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         IF p_ies_auditoria THEN
            CURRENT WINDOW IS w_pol07013
            IF p_codigo IS NOT NULL THEN
               LET p_auditoria.cod_fornecedor = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_fornecedor
            END IF
         ELSE
            CURRENT WINDOW IS w_pol0701
            IF p_codigo IS NOT NULL THEN
               LET p_cotacao_preco_885.cod_fornecedor = p_codigo CLIPPED
               DISPLAY p_codigo TO cod_fornecedor
            END IF
         END IF
      
      WHEN INFIELD(nom_usuario)
         CALL log009_popup(8,10,"USU�RIOS","usuarios",
              "cod_usuario","nom_funcionario","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol07013
          
         IF p_codigo IS NOT NULL THEN
           LET p_auditoria.nom_usuario = p_codigo CLIPPED
           DISPLAY p_codigo TO nom_usuario
         END IF 
                 
      WHEN INFIELD(cnd_pgto)
         CALL log009_popup(8,10,"CONDICAO PAGAMENTO","cond_pgto_cap",
              "cnd_pgto","des_cnd_pgto","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0701
          
         IF p_codigo IS NOT NULL THEN
           LET p_cotacao_preco_885.cnd_pgto = p_codigo CLIPPED
           DISPLAY p_codigo TO cnd_pgto
         END IF 
      
         
   END CASE
            
END FUNCTION 

#---------------------------#
 FUNCTION pol0701_auditoria()
#---------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(600)
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07013") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07013 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   CLEAR FORM
   DISPLAY p_cod_empresa   TO cod_empresa
   INITIALIZE p_auditoria  TO NULL
   INITIALIZE pr_auditoria TO NULL
   LET INT_FLAG        = FALSE
   LET p_ies_auditoria = TRUE
   
   CONSTRUCT BY NAME where_clause ON 
      audit_cotacao_885.cod_item,
      audit_cotacao_885.cod_fornecedor,
      audit_cotacao_885.nom_usuario  
  
      ON KEY (control-z)
         CALL pol0701_popup()
          
   END CONSTRUCT
   
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF
      
   LET sql_stmt = "SELECT cod_item, cod_fornecedor, nom_usuario, dat_proces, den_texto",
                  "  FROM audit_cotacao_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",                
                  " ORDER BY cod_fornecedor, cod_item, dat_proces"

   PREPARE var_query_2 FROM sql_stmt   
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Criando", "var_query_2")
         RETURN FALSE
      END IF
   
   LET p_index = 1
   
   DECLARE cq_auditoria CURSOR FOR var_query_2
   
   FOREACH cq_auditoria
      INTO pr_auditoria[p_index].cod_item_array,
           pr_auditoria[p_index].cod_fornecedor_array,
           pr_auditoria[p_index].nom_usuario_array,
           pr_auditoria[p_index].dat_proces,
           pr_auditoria[p_index].den_texto
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "cursor: cq_auditoria")
         RETURN FALSE
      END IF
      
      IF p_index > 5000 THEN
         ERROR "Limite de grade ultrapassado !!!"
         EXIT FOREACH
      END IF
      
      LET p_index = p_index + 1
      
   END FOREACH 

   CALL SET_COUNT(p_index - 1)
   
   IF p_index = 1 THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!", "exclamation")
      RETURN FALSE
   END IF
   
   DISPLAY ARRAY pr_auditoria TO sr_auditoria.*
      
   CLOSE WINDOW w_pol07013
  
   RETURN TRUE
      
END FUNCTION 

#-------------------------------- FIM DE PROGRAMA -----------------------------#