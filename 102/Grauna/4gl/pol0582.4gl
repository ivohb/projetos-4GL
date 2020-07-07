#-------------------------------------------------------------------#
# SISTEMA.: ANÁLISE DOS PRODUTOS                                    #
# PROGRAMA: pol0582                                                 #
# OBJETIVO: PRAMÊTROS DO SISTEMA - GRAUNA                           #
# AUTOR...: POLO INFORMATICA - ANA PAULA                            #
# DATA....: 13/04/2007    																					#
# ALTERADO: 13/03/2009 -THIAGO- INCLUIR CAMPO oc_linha              #
#           17/03/2009 - THIAGO- VERSÃO 4-ADD COD_EMPRESA DE EMPRESA#
#05/01/10(Ivo) em função da colocação do cod_empresa na tab         #
#              nat_oper_bene_1040                                   #
#15/01/10(Ivo) madunça do nome da tabela nat_oper_bene_1040         #
#              p/ operacao_bene_1040                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_local          LIKE local.den_local,
          p_den_nat_oper       LIKE nat_operacao.den_nat_oper,
          p_cod_nat_oper       LIKE nat_operacao.cod_nat_oper,
          p_den_cnd_pgto       LIKE cond_pgto.den_cnd_pgto,
          p_den_via_transporte LIKE via_transporte.den_via_transporte,
          p_den_local_embarque LIKE local_embarque.den_local_embarque,
          p_den_entrega        LIKE entregas.den_entrega,
          p_den_empresa        CHAR(25), 
          p_retorno            SMALLINT,
          p_ind                SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
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
          p_caminho            CHAR(080),
          sql_stmt             CHAR(300),
          where_clause         CHAR(300),
          p_cod_item           LIKE item.cod_item,
          p_den_item           LIKE item.den_item,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_den_estr_linprod   LIKE linha_prod.den_estr_linprod
          
   DEFINE p_cli_c_oclinha_1040  RECORD LIKE cli_c_oclinha_1040.* 

   DEFINE p_ite_s_oclinha_1040  RECORD LIKE ite_s_oclinha_1040.*, 
          p_ite_s_oclinha_1040a RECORD LIKE ite_s_oclinha_1040.* 
   
   DEFINE pr_itens
         ARRAY[2000] OF RECORD
          cod_item      LIKE item.cod_item,
          den_item      LIKE item.den_item
   END RECORD

   DEFINE pr_clientes      ARRAY[2000] OF RECORD
          cod_cliente      LIKE clientes.cod_cliente,
          nom_cliente      LIKE clientes.nom_cliente,
          pct_eletrica     DECIMAL(5,2)
   END RECORD

   DEFINE pr_oper          ARRAY[2000] OF RECORD
          cod_nat_oper      LIKE nat_operacao.cod_nat_oper,
          den_nat_oper      LIKE nat_operacao.den_nat_oper
   END RECORD

   DEFINE p_parametros_1040  RECORD LIKE parametros_1040.*,
          p_parametros_1040a RECORD LIKE parametros_1040.*
          
   DEFINE p_cod_lin_prod     LIKE lib_linprod_1040.cod_lin_prod,
          p_cod_lin_prod_ant LIKE lib_linprod_1040.cod_lin_prod
   
   DEFINE pr_lin_prod        ARRAY[1000] OF RECORD
          cod_lin_prod       DECIMAL(2,0),
          den_estr_linprod   CHAR(20)
   END RECORD     
   
   DEFINE p_lib_linprod_1040 RECORD 
   				cod_lin_prod			LIKE lib_linprod_1040.cod_lin_prod, 
   				envia_almox				LIKE lib_linprod_1040.envia_almox,
   				oc_linha    			LIKE lib_linprod_1040.oc_linha
   END RECORD 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0582-05.10.06"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0582.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0582_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0582_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0582") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0582 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Parametros Gerais" "Cadastro de parametros gerais do sistema"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0582_parametros_gerais()
      COMMAND "Itens kanban" "Itens KANBAN"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0582_itens_oclinha()
      COMMAND "Clientes c/ Oclinha" "Cadastro de clientes que usam Oc_linha."
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0582_clientes_oclinha()
      COMMAND "Natureza Operação" "Cadastro de Natureza de OPeração p/ Beneficiamento."
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0582_nat_oper_bene()
      COMMAND "Linha de Produto" "Cadastro de linha de produto para transferência de materias"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0582_linha_prod()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 004
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0582

END FUNCTION

#-----------------------------------#
 FUNCTION pol0582_itens_oclinha()
#-----------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol05822") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol05822 AT 6,5 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   LET p_ies_cons = TRUE

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0582_inclui_it_oc() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Dados já cadastrado para essa Empresa !!!'
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0582_exclui_it_oc() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0582_consulta_it_oc()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0582_paginacao_it_oc("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0582_paginacao_it_oc("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0582","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0582_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0530.tmp'
                     START REPORT pol0582_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0582_relat TO p_nom_arquivo
               END IF
               CALL pol0582_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0582_relat   
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
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
   
   CLOSE WINDOW w_pol05822

END FUNCTION

##########################
######### INICIO #########
##########################
#---------------------------------#
 FUNCTION pol0582_inclui_it_oc()
#---------------------------------#

CLEAR FORM
DISPLAY p_cod_empresa TO cod_empresa
INITIALIZE p_ite_s_oclinha_1040.* TO NULL
LET p_ite_s_oclinha_1040.cod_empresa = p_cod_empresa

   IF pol0582_entrada_dados_it_oc("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO ite_s_oclinha_1040 VALUES (p_ite_s_oclinha_1040.*)
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","ite_s_oclinha_1040")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF
   RETURN FALSE   

END FUNCTION

#------------------------------------------------#
 FUNCTION pol0582_entrada_dados_it_oc(p_funcao)
#------------------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol05822

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME p_ite_s_oclinha_1040.* WITHOUT DEFAULTS  

      AFTER FIELD cod_item
      IF p_ite_s_oclinha_1040.cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_item
      END IF
      
      SELECT cod_item
        FROM ite_s_oclinha_1040
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_ite_s_oclinha_1040.cod_item
         
      IF STATUS = 0 THEN  
         ERROR 'Código do Item sem OCLINHA já cadastrada !!!'
         NEXT FIELD cod_item
      END IF
       
      SELECT den_item
        INTO p_den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_ite_s_oclinha_1040.cod_item

      IF STATUS <> 0 THEN
         ERROR 'Cliente nao cadastrado na Tabela ITEM !!!'
         NEXT FIELD cod_item
      END IF        
      
      DISPLAY p_den_item TO den_item

      ON KEY (control-z)
         CALL pol0582_popup_linha_prod()
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol05822

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0582_consulta_it_oc()
#-----------------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_ite_s_oclinha_1040a.* = p_ite_s_oclinha_1040.*

   CONSTRUCT BY NAME where_clause ON 
      ite_s_oclinha_1040.cod_item

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol05822
   
     IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_ite_s_oclinha_1040.* = p_ite_s_oclinha_1040a.*
      CALL pol0582_exibe_dados_it_oc()
      CLEAR FORM
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM ite_s_oclinha_1040 ",
                  "WHERE cod_empresa = '",p_cod_empresa,"' ",
                  "  AND ", where_clause CLIPPED,                 
                  "ORDER BY cod_item "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_ite_s_oclinha_1040.*

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0582_exibe_dados_it_oc()
   END IF
   
END FUNCTION

#--------------------------------------#
 FUNCTION pol0582_exibe_dados_it_oc()
#--------------------------------------#

   CLEAR FORM
   DISPLAY BY NAME p_ite_s_oclinha_1040.*
   DISPLAY p_cod_empresa TO cod_empresa
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_ite_s_oclinha_1040.cod_item

   DISPLAY p_den_item TO den_item
   
END FUNCTION

#---------------------------------------------#
 FUNCTION pol0582_cursor_for_update_it_oc()
#---------------------------------------------#

   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_ite_s_oclinha_1040.*                                              
     FROM ite_s_oclinha_1040
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_ite_s_oclinha_1040.cod_item
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","ite_s_oclinha_1040")
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0582_exclui_it_oc()
#---------------------------------#

   LET p_retorno = FALSE
   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")

   IF pol0582_cursor_for_update_it_oc() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM ite_s_oclinha_1040
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_ite_s_oclinha_1040.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","ite_s_oclinha_1040")
         END IF
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   WHENEVER ERROR STOP

   RETURN p_retorno

END FUNCTION  

#-----------------------------------------#
 FUNCTION pol0582_paginacao_it_oc(p_funcao)
#-----------------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_ite_s_oclinha_1040a.* = p_ite_s_oclinha_1040.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_ite_s_oclinha_1040.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_ite_s_oclinha_1040.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_ite_s_oclinha_1040.* = p_ite_s_oclinha_1040a.* 
            EXIT WHILE
         END IF

         SELECT cod_item
           INTO p_ite_s_oclinha_1040.* 
           FROM ite_s_oclinha_1040
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_ite_s_oclinha_1040.cod_item
         
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0582_exibe_dados_it_oc()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

###############################
########     F I M     ########
###############################


#-----------------------#
FUNCTION pol0582_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
   
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05823
         IF p_codigo IS NOT NULL THEN
            LET pr_clientes[p_index].cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF

      WHEN INFIELD(local_est_pc_rej)
         CALL log009_popup(8,15,"LOCAL DE ESTOQUE","local",
                     "cod_local","den_local","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05821
         IF p_codigo IS NOT NULL THEN
            LET p_parametros_1040.local_est_pc_rej = p_codigo CLIPPED
            DISPLAY p_codigo TO local_est_pc_rej
         END IF

      WHEN INFIELD(cod_local_transf)
         CALL log009_popup(8,15,"LOCAL DE ESTOQUE","local",
                     "cod_local","den_local","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05821
         IF p_codigo IS NOT NULL THEN
            LET p_parametros_1040.cod_local_transf = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_local_transf
         END IF
      
      WHEN INFIELD(nat_oper_mat_rej)
         CALL log009_popup(8,15,"NATUREZA DE OPERAÇÃO","nat_operacao",
                     "cod_nat_oper","den_nat_oper","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05821
         IF p_codigo IS NOT NULL THEN
            LET p_parametros_1040.nat_oper_mat_rej = p_codigo CLIPPED
            DISPLAY p_codigo TO nat_oper_mat_rej
         END IF

      WHEN INFIELD(nat_oper_mat_boa)
         CALL log009_popup(8,15,"NATUREZA DE OPERAÇÃO","nat_operacao",
                     "cod_nat_oper","den_nat_oper","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05821
         IF p_codigo IS NOT NULL THEN
            LET p_parametros_1040.nat_oper_mat_boa = p_codigo CLIPPED
            DISPLAY p_codigo TO nat_oper_mat_boa
         END IF

      WHEN INFIELD(nat_oper_fat_rej)
         CALL log009_popup(8,15,"NATUREZA DE OPERAÇÃO","nat_operacao",
                     "cod_nat_oper","den_nat_oper","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05821
         IF p_codigo IS NOT NULL THEN
            LET p_parametros_1040.nat_oper_fat_rej = p_codigo CLIPPED
            DISPLAY p_codigo TO nat_oper_fat_rej
         END IF

      WHEN INFIELD(cod_via_transporte)
         CALL log009_popup(8,15,"VIAS DE TRANSPORTE","via_transporte",
                     "cod_via_transporte","den_via_transporte","","","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05821
         IF p_codigo IS NOT NULL THEN
            LET p_parametros_1040.cod_via_transporte = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_via_transporte
         END IF

      WHEN INFIELD(cod_local_embarque)
         CALL log009_popup(8,15,"LOCAAIS DE EMBARQUE","local_embarque",
                     "cod_local_embarque","den_local_embarque","","","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05821
         IF p_codigo IS NOT NULL THEN
            LET p_parametros_1040.cod_local_embarque = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_local_embarque
         END IF

      WHEN INFIELD(cod_entrega)
         CALL log009_popup(8,15,"ENTREGA","entregas",
                     "cod_entrega","DEN_entrega","","","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05821
         IF p_codigo IS NOT NULL THEN
            LET p_parametros_1040.cod_entrega = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_entrega
         END IF

      WHEN INFIELD(cnd_pgto_fat_rej)
         CALL log009_popup(8,15,"NATUREZA DE OPERAÇÃO","cond_pgto",
                     "cod_cnd_pgto","den_cnd_pgto","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05821
         IF p_codigo IS NOT NULL THEN
            LET p_parametros_1040.cnd_pgto_fat_rej = p_codigo CLIPPED
            DISPLAY p_codigo TO cnd_pgto_fat_rej
         END IF
      
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05822
         IF p_codigo IS NOT NULL THEN
           LET p_ite_s_oclinha_1040.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
   END CASE

END FUNCTION 

#-----------------------------------#
 FUNCTION pol0582_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   LET p_count    = 0
   
    DECLARE cq_lista CURSOR FOR
    SELECT a.cod_item,
           b.den_item
      FROM ite_s_oclinha_1040 a,
           item b
     WHERE b.cod_empresa = a.cod_empresa
       AND b.cod_item    = a.cod_item
     ORDER BY 1
   
   FOREACH cq_lista INTO 
           p_cod_item,
           p_den_item

      OUTPUT TO REPORT pol0582_relat() 
 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0582_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT COLUMN 001, "POL0582    ITENS SEM OC LINHA",
               COLUMN 056, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "   CODIGO                           DESCRIÇÃO                  "
         PRINT COLUMN 001, "--------------- ----------------------------------------------------------------"
         PRINT
                           
      ON EVERY ROW
         
         PRINT COLUMN 001, p_cod_item,
               COLUMN 001, p_den_item
               
END REPORT

#-----------------------------------#
 FUNCTION pol0582_clientes_oclinha()
#-----------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol05823") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol05823 AT 6,8 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Modificar" "Inclui/Modifica/Exclui Clientes c/ Oc_linha"
         HELP 001
         MESSAGE ""
         WHENEVER ERROR CONTINUE
         LET INT_FLAG = 0
         CALL log085_transacao("BEGIN")
         IF pol0582_modifica_clientes() THEN
            CALL log085_transacao("COMMIT")	      
            ERROR "Modificação de Dados Efetuada c/ Sucesso !!!"
         ELSE
            CALL log085_transacao("ROLLBACK")
            ERROR "Operação Cancelada !!!"
         END IF      
         WHENEVER ERROR STOP
      COMMAND "Consultar" "Consulta Clientes c/ Oc_linha"
         HELP 002
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0582_consulta_clientes()
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 003
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0582","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0582_relat_clientes TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0582.tmp'
                     START REPORT pol0582_relat_clientes  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0582_relat_clientes TO p_nom_arquivo
               END IF
               CALL pol0582_emite_relat_clientes()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0582_relat_clientes  
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
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
   
   CLOSE WINDOW w_pol05823

END FUNCTION

#----------------------------------#
FUNCTION pol0582_consulta_clientes()
#----------------------------------#

   CALL pol0582_carrega_clientes()
   
   DISPLAY ARRAY pr_clientes TO  sr_clientes.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()

END FUNCTION

#---------------------------------#
FUNCTION pol0582_carrega_clientes()
#---------------------------------#

   INITIALIZE pr_clientes TO NULL
   CLEAR FORM

   LET p_index = 1
   
   DECLARE cq_clientes CURSOR FOR
    SELECT a.cod_cliente,
           b.nom_cliente,
           a.pct_energ_eletrica
      FROM cli_c_oclinha_1040 a,
           clientes b
     WHERE b.cod_cliente = a.cod_cliente
   
   FOREACH cq_clientes INTO 
           pr_clientes[p_index].cod_cliente,
           pr_clientes[p_index].nom_cliente,
           pr_clientes[p_index].pct_eletrica
              
      LET p_index = p_index + 1
      
      IF p_index > 2000 THEN
         ERROR 'Limite de itens ultrapassado !!!'
         EXIT FOREACH
      END IF

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
END FUNCTION


#-----------------------------------#
FUNCTION pol0582_modifica_clientes()
#-----------------------------------#
   
   CALL pol0582_carrega_clientes()
   
   INPUT ARRAY pr_clientes
      WITHOUT DEFAULTS FROM sr_clientes.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
      AFTER FIELD cod_cliente
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_clientes[p_index].cod_cliente IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               NEXT FIELD cod_cliente
            END IF
         END IF
         
         IF pr_clientes[p_index].cod_cliente IS NOT NULL THEN
            IF pol0582_repetiu_cod_cliente() THEN
               ERROR "Codigo do Cliente ",pr_clientes[p_index].cod_cliente CLIPPED ," já Informado !!!"
               NEXT FIELD cod_cliente
            ELSE
               SELECT nom_cliente
                 INTO pr_clientes[p_index].nom_cliente
                 FROM clientes
                WHERE cod_cliente = pr_clientes[p_index].cod_cliente

               IF STATUS = 0 THEN 
                  DISPLAY pr_clientes[p_index].nom_cliente TO 
                          sr_clientes[s_index].nom_cliente
               ELSE
                  ERROR "Codigo do Cliente não existente !!!"
                  NEXT FIELD cod_cliente
               END IF
            END IF   
         END IF

      AFTER FIELD pct_eletrica
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_clientes[p_index].pct_eletrica IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               NEXT FIELD pct_eletrica
            END IF
         END IF
                  
      ON KEY (control-z)
         CALL pol0582_popup()
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      IF pol0582_grava_clientes() THEN
         RETURN TRUE
      ELSE
         RETURN FALSE
      END IF
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF   
   
END FUNCTION

#-------------------------------------#
FUNCTION pol0582_repetiu_cod_cliente()
#-------------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_clientes[p_ind].cod_cliente = pr_clientes[p_index].cod_cliente THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0582_grava_clientes()
#--------------------------------#
   
   DEFINE p_ind SMALLINT 

   DELETE FROM cli_c_oclinha_1040

   IF SQLCA.sqlcode <> 0 THEN 
      CALL log003_err_sql("DELEÇÃO","CLI_C_OCLINHA_1040")
      RETURN FALSE
   END IF
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_clientes[p_ind].cod_cliente IS NOT NULL THEN
          INSERT INTO cli_c_oclinha_1040
          VALUES(pr_clientes[p_ind].cod_cliente,
                 pr_clientes[p_ind].pct_eletrica)
          IF SQLCA.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSÃO","CLI_C_OCLINHA_1040")
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION


#--------------------------------------#
 FUNCTION pol0582_emite_relat_clientes()
#--------------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   LET p_cod_cliente = NULL
   LET p_nom_cliente = NULL
   LET p_count    = 0
   
    DECLARE cq_listar_clientes CURSOR FOR
    SELECT a.cod_cliente,
           b.nom_cliente
      FROM cli_c_oclinha_1040 a,
           clientes b
     WHERE b.cod_cliente = a.cod_cliente
     ORDER BY 1
   
   FOREACH cq_listar_clientes INTO 
           p_cod_cliente,
           p_nom_cliente

      OUTPUT TO REPORT pol0582_relat_clientes() 
 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#------------------------------#
 REPORT pol0582_relat_clientes()
#------------------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT COLUMN 001, "pol0582    CLIENTES COM OC_LINHA  ",
               COLUMN 056, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 017, "    CODIGO             NOME DO CLIENTE                "
         PRINT COLUMN 017, "---------------   ------------------------------------"
         PRINT
                           
      ON EVERY ROW
         
         PRINT COLUMN 017, p_cod_cliente,
               COLUMN 035, p_nom_cliente
               
END REPORT

#-----------------------------------#
 FUNCTION pol0582_parametros_gerais()
#------------
#-----------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol05821") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol05821 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0582_inclusao_par_ger() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0582_modificacao_par_ger() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0582_exclusao_par_ger() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
               LET p_ies_cons = FALSE
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0582_consulta_par_ger()
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
   
   CLOSE WINDOW w_pol05821

END FUNCTION

#----------------------------------#
 FUNCTION pol0582_inclusao_par_ger()
#----------------------------------#

   SELECT cod_empresa
     FROM parametros_1040
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS = 0 THEN
      CALL log0030_mensagem('Parâmetros já cadastrado para empresa corrente','exclamation')
      RETURN FALSE
   END IF

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_parametros_1040.* TO NULL
   LET p_parametros_1040.cod_empresa = p_cod_empresa

   IF pol0582_entrada_dados_par_ger() THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO parametros_1040 VALUES (p_parametros_1040.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0582_entrada_dados_par_ger()
#---------------------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol05821

   INPUT BY NAME p_parametros_1040.*
      WITHOUT DEFAULTS  

      AFTER FIELD local_est_pc_rej
      IF p_parametros_1040.local_est_pc_rej IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD local_est_pc_rej
      END IF
      
      IF NOT pol0582_le_local(p_parametros_1040.local_est_pc_rej) THEN
         ERROR 'Local Inexistente !!!'
         NEXT FIELD local_est_pc_rej
      END IF
      
      DISPLAY p_den_local TO den_local_rej

      AFTER FIELD nat_oper_mat_rej
      IF p_parametros_1040.nat_oper_mat_rej IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD nat_oper_mat_rej
      END IF

      IF NOT pol0582_le_operacao(p_parametros_1040.nat_oper_mat_rej) THEN
         ERROR 'Operação Inexistente !!!'
         NEXT FIELD nat_oper_mat_rej
      END IF

      DISPLAY p_den_nat_oper TO den_oper_mat_rej

      AFTER FIELD nat_oper_mat_boa
      IF p_parametros_1040.nat_oper_mat_boa IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD nat_oper_mat_boa
      END IF

      IF NOT pol0582_le_operacao(p_parametros_1040.nat_oper_mat_boa) THEN
         ERROR 'Operação Inexistente !!!'
         NEXT FIELD nat_oper_mat_boa
      END IF
      
      DISPLAY p_den_nat_oper TO den_oper_mat_boa

      AFTER FIELD nat_oper_fat_rej
      IF p_parametros_1040.nat_oper_fat_rej IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD nat_oper_fat_rej
      END IF

      IF NOT pol0582_le_operacao(p_parametros_1040.nat_oper_fat_rej) THEN
         ERROR 'Operação Inexistente !!!'
         NEXT FIELD nat_oper_fat_rej
      END IF
      
      DISPLAY p_den_nat_oper TO den_oper_fat_rej

      AFTER FIELD cnd_pgto_fat_rej
      IF p_parametros_1040.cnd_pgto_fat_rej IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cnd_pgto_fat_rej
      END IF

      IF NOT pol0582_le_cond_pgto() THEN
         ERROR 'Operação Inexistente !!!'
         NEXT FIELD cnd_pgto_fat_rej
      END IF
      
      DISPLAY p_den_cnd_pgto TO den_pgto_fat_rej

      AFTER FIELD cod_via_transporte
      IF p_parametros_1040.cod_via_transporte IS NOT NULL THEN 
         IF NOT pol0582_le_via_transporte() THEN
            ERROR 'Via de Transporte Inexistente !!!'
            NEXT FIELD cod_via_transporte
         END IF
         DISPLAY p_den_via_transporte TO den_via_transporte
      ELSE
         DISPLAY '' TO den_via_transporte
      END IF      
      
      AFTER FIELD cod_local_embarque
      IF p_parametros_1040.cod_local_embarque IS NOT NULL THEN 
         IF NOT pol0582_le_local_embarque() THEN
            ERROR 'Local de Embarque Inexistente !!!'
            NEXT FIELD cod_local_embarque
         END IF
         DISPLAY p_den_local_embarque TO den_local_embarque
      ELSE
         DISPLAY '' TO den_local_embarque
      END IF      

      AFTER FIELD cod_entrega
      IF p_parametros_1040.cod_entrega IS NOT NULL THEN 
         IF NOT pol0582_le_entregas() THEN
            ERROR 'Entrega Inexistente !!!'
            NEXT FIELD cod_entrega
         END IF
         DISPLAY p_den_entrega TO den_entrega
      ELSE
         DISPLAY '' TO den_entrega
      END IF      

      AFTER FIELD cod_local_transf
      IF p_parametros_1040.cod_local_transf IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_local_transf
      END IF
      
      IF NOT pol0582_le_local(p_parametros_1040.cod_local_transf) THEN
         ERROR 'Local Inexistente !!!'
         NEXT FIELD cod_local_transf
      END IF
      
      DISPLAY p_den_local TO den_local_transf

      ON KEY (control-z)
         CALL pol0582_popup()

    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol05821

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------------#
FUNCTION pol0582_le_local(p_cod_local)
#------------------------------------#

   DEFINE p_cod_local LIKE local.cod_local
   
   INITIALIZE p_den_local TO NULL
   
   SELECT den_local
     INTO p_den_local
     FROM local
    WHERE cod_empresa = p_cod_empresa
      AND cod_local   = p_cod_local
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#------------------------------------------#
FUNCTION pol0582_le_operacao(p_cod_nat_oper)
#------------------------------------------#

   DEFINE p_cod_nat_oper LIKE nat_operacao.cod_nat_oper
   INITIALIZE p_den_nat_oper TO NULL
   
   SELECT den_nat_oper
     INTO p_den_nat_oper
     FROM nat_operacao
    WHERE cod_nat_oper = p_cod_nat_oper
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#------------------------------#
FUNCTION pol0582_le_cond_pgto()
#------------------------------#

   INITIALIZE p_den_cnd_pgto TO NULL

   SELECT den_cnd_pgto
     INTO p_den_cnd_pgto
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_parametros_1040.cnd_pgto_fat_rej
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol0582_le_via_transporte()
#----------------------------------#

   INITIALIZE p_den_via_transporte TO NULL
   
   SELECT den_via_transporte
     INTO p_den_via_transporte
     FROM via_transporte
    WHERE cod_via_transporte = p_parametros_1040.cod_via_transporte
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol0582_le_local_embarque()
#----------------------------------#

   INITIALIZE p_den_local_embarque TO NULL
   
   SELECT den_local_embarque
     INTO p_den_local_embarque
     FROM local_embarque
    WHERE cod_local_embarque = p_parametros_1040.cod_local_embarque
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0582_le_entregas()
#----------------------------#

   INITIALIZE p_den_entrega TO NULL
   
   SELECT den_entrega
     INTO p_den_entrega
     FROM entregas
    WHERE cod_entrega = p_parametros_1040.cod_entrega
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol0582_consulta_par_ger()
#----------------------------------#

   SELECT * 
     INTO p_parametros_1040.*
     FROM parametros_1040
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      ERROR 'Não há parâmetros gerais cadastrados p/ empresa corrente !!!'
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      ERROR 'Consulta efetuada com sucesso !!!'
      CALL pol0582_exibe_dados_1040()
   END IF
        
END FUNCTION

#-----------------------------------#
 FUNCTION pol0582_exibe_dados_1040()
#-----------------------------------#

   DISPLAY BY NAME p_parametros_1040.*

   CALL pol0582_le_local(p_parametros_1040.local_est_pc_rej) RETURNING p_status
   DISPLAY p_den_local TO den_local_rej

   CALL pol0582_le_operacao(p_parametros_1040.nat_oper_mat_rej) RETURNING p_status
   DISPLAY p_den_nat_oper TO den_oper_mat_rej

   CALL pol0582_le_operacao(p_parametros_1040.nat_oper_mat_boa) RETURNING p_status
   DISPLAY p_den_nat_oper TO den_oper_mat_boa

   CALL pol0582_le_operacao(p_parametros_1040.nat_oper_fat_rej) RETURNING p_status
   DISPLAY p_den_nat_oper TO den_oper_fat_rej

   CALL pol0582_le_cond_pgto() RETURNING p_status
   DISPLAY p_den_cnd_pgto TO den_pgto_fat_rej

   CALL pol0582_le_via_transporte() RETURNING p_status
   DISPLAY p_den_via_transporte TO den_via_transporte

   CALL pol0582_le_local_embarque() RETURNING p_status
   DISPLAY p_den_local_embarque TO den_local_embaruqe
   
   CALL pol0582_le_entregas() RETURNING p_status
   DISPLAY p_den_entrega TO den_entrega

   CALL pol0582_le_local(p_parametros_1040.cod_local_transf) RETURNING p_status
   DISPLAY p_den_local TO den_local_transf

END FUNCTION

#--------------------------------------------#
 FUNCTION pol0582_cursor_for_update_par_ger()
#--------------------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao2 CURSOR WITH HOLD FOR

   SELECT *
     INTO p_parametros_1040.*
     FROM parametros_1040
    WHERE cod_empresa = p_cod_empresa
   FOR UPDATE 
   
   OPEN cm_padrao2
   FETCH cm_padrao2
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","parametros_1040")   
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------------#
 FUNCTION pol0582_modificacao_par_ger()
#-------------------------------------#

   LET p_retorno = FALSE
   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")
   
   IF pol0582_cursor_for_update_par_ger() THEN
      LET p_parametros_1040a.* = p_parametros_1040.*
      IF pol0582_entrada_dados_par_ger() THEN
         UPDATE parametros_1040
            SET parametros_1040.* = p_parametros_1040.*
         WHERE CURRENT OF cm_padrao2
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","parametros_1040")
         END IF
      ELSE
         LET p_parametros_1040.* = p_parametros_1040a.*
         CALL pol0582_exibe_dados_1040()
      END IF
      CLOSE cm_padrao2
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF
   
   #WHENEVER ERROR STOP
   RETURN p_retorno

END FUNCTION

#-----------------------------------#
 FUNCTION pol0582_exclusao_par_ger()
#-----------------------------------#

   LET p_retorno = FALSE
   IF pol0582_cursor_for_update_par_ger() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM parametros_1040
         WHERE CURRENT OF cm_padrao2
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
            CLEAR FORM 
         ELSE
            CALL log003_err_sql("EXCLUSAO","parametros_1040")
         END IF
      END IF
      CLOSE cm_padrao2
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  


#-------------------------------#
 FUNCTION pol0582_nat_oper_bene()
#-------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol05824") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol05824 AT 6,11 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_ies_cons = TRUE
   
   MENU "OPCAO"
      COMMAND "Modificar" "Inclui/Modifica/Exclui Nat Oper p/ Beneficiamento"
         HELP 001
         MESSAGE ""
         WHENEVER ERROR CONTINUE
         LET INT_FLAG = 0
         CALL log085_transacao("BEGIN")
         IF pol0582_modifica_oper() THEN
            CALL log085_transacao("COMMIT")	      
            ERROR "Modificação de Dados Efetuada c/ Sucesso !!!"
         ELSE
            CALL log085_transacao("ROLLBACK")
            ERROR "Operação Cancelada !!!"
         END IF      
         WHENEVER ERROR STOP
      COMMAND "Consultar" "Consulta Nat Oper p/ Beneficiamento"
         HELP 002
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0582_consulta_oper()
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 003
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0582","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0582_relat_oper TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0582.tmp'
                     START REPORT pol0582_relat_oper  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0582_relat_oper TO p_nom_arquivo
               END IF
               CALL pol0582_emite_relat_oper()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0582_relat_oper 
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
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
   
   CLOSE WINDOW w_pol05824

END FUNCTION

#-------------------------------#
FUNCTION pol0582_consulta_oper()
#-------------------------------#

   CALL pol0582_carrega_oper()
   
   DISPLAY ARRAY pr_oper TO  sr_oper.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()

END FUNCTION

#-------------------------------#
FUNCTION pol0582_carrega_oper()
#-------------------------------#

   INITIALIZE pr_oper TO NULL
   CLEAR FORM

   LET p_index = 1
   
   DECLARE cq_oper CURSOR FOR
    SELECT a.cod_nat_oper,
           b.den_nat_oper
      FROM operacao_bene_1040 a,
           nat_operacao b
     WHERE b.cod_nat_oper = a.cod_nat_oper
   
   FOREACH cq_oper INTO 
           pr_oper[p_index].cod_nat_oper,
           pr_oper[p_index].den_nat_oper
   
      LET p_index = p_index + 1
      
      IF p_index > 2000 THEN
         ERROR 'Limite de itens ultrapassado !!!'
         EXIT FOREACH
      END IF

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
END FUNCTION

#-------------------------------#
FUNCTION pol0582_modifica_oper()
#-------------------------------#

   CALL pol0582_carrega_oper()
   
   INPUT ARRAY pr_oper
      WITHOUT DEFAULTS FROM sr_oper.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
      AFTER FIELD cod_nat_oper
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_oper[p_index].cod_nat_oper IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               NEXT FIELD cod_nat_oper
            END IF
         END IF
         
         IF pr_oper[p_index].cod_nat_oper IS NOT NULL THEN
            IF pol0582_repetiu_oper() THEN
               ERROR "Operação ",pr_oper[p_index].cod_nat_oper CLIPPED ," já Informada !!!"
               NEXT FIELD cod_nat_oper
            ELSE
               SELECT den_nat_oper
                 INTO pr_oper[p_index].den_nat_oper
                 FROM nat_operacao
                WHERE cod_nat_oper = pr_oper[p_index].cod_nat_oper

               IF STATUS = 0 THEN 
                  DISPLAY pr_oper[p_index].den_nat_oper TO 
                          sr_oper[s_index].den_nat_oper
               ELSE
                  ERROR "Codigo do Item não existente !!!"
                  NEXT FIELD cod_nat_oper
               END IF
   
            END IF

         END IF
         
      ON KEY (control-z)
         CALL pol0582_popup()
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      IF pol0582_grava_oper() THEN
         RETURN TRUE
      ELSE
         RETURN FALSE
      END IF
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF   
   
END FUNCTION

#-------------------------------#
FUNCTION pol0582_repetiu_oper()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_oper[p_ind].cod_nat_oper = pr_oper[p_index].cod_nat_oper THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#---------------------------#
FUNCTION pol0582_grava_oper()
#---------------------------#
   
   DEFINE p_ind SMALLINT 

   DELETE FROM operacao_bene_1040

   IF SQLCA.sqlcode <> 0 THEN 
      CALL log003_err_sql("DELEÇÃO","operacao_bene_1040")
      RETURN FALSE
   END IF
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_oper[p_ind].cod_nat_oper IS NOT NULL THEN
          INSERT INTO operacao_bene_1040
            VALUES(pr_oper[p_ind].cod_nat_oper)
          IF SQLCA.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSÃO","operacao_bene_1040")
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol0582_emite_relat_oper()
#----------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   LET p_count    = 0
   
    DECLARE cq_listar_oper CURSOR FOR
    SELECT a.cod_nat_oper,
           b.den_nat_oper
      FROM operacao_bene_1040 a,
           nat_operacao b
     WHERE b.cod_nat_oper = a.cod_nat_oper
     ORDER BY 1
   
   FOREACH cq_listar_oper INTO 
           p_cod_nat_oper,
           p_den_nat_oper

      OUTPUT TO REPORT pol0582_relat_oper() 
 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#---------------------------#
 REPORT pol0582_relat_oper()
#---------------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT COLUMN 001, "pol0582    NATUREZA DE OPERACAO P/ BENEFICIAMENTO  ",
               COLUMN 056, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 017, "    CODIGO             DESCRICAO                "
         PRINT COLUMN 017, "---------------   ------------------------------------"
         PRINT
                           
      ON EVERY ROW
         
         PRINT COLUMN 017, p_cod_nat_oper,
               COLUMN 035, p_den_nat_oper
               
END REPORT

#----------------------------#
FUNCTION pol0582_linha_prod()
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol05825") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol05825 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   LET p_ies_cons = FALSE

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0582_inclui_linha_prod() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada!!!'
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0582_exclui_linha_prod() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol0582_modificacao_linha_prod() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao"
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0582_consulta_linha_prod()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0582_paginacao_linha_prod("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0582_paginacao_linha_prod("ANTERIOR")
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
   
   CLOSE WINDOW w_pol05825

END FUNCTION

#-----------------------------------#
 FUNCTION pol0582_inclui_linha_prod()
#-----------------------------------#

CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE P_lib_linprod_1040.* TO NULL

   IF pol0582_edita_linha_prod("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO lib_linprod_1040 VALUES (p_cod_empresa,
      	p_lib_linprod_1040.cod_lin_prod,p_lib_linprod_1040.envia_almox, p_lib_linprod_1040.oc_linha )
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","lib_linprod_1040")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION


#------------------------------------------#
 FUNCTION pol0582_edita_linha_prod(p_funcao)
#------------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_lib_linprod_1040.* WITHOUT DEFAULTS
   
      BEFORE FIELD cod_lin_prod
      IF p_funcao = 'M' THEN
         NEXT FIELD envia_almox
      END IF
      
      AFTER FIELD cod_lin_prod
      IF p_lib_linprod_1040.cod_lin_prod IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_lin_prod   
      END IF
         
      SELECT cod_lin_prod
        FROM lib_linprod_1040
       WHERE cod_lin_prod  = p_lib_linprod_1040.cod_lin_prod
       AND cod_empresa=p_cod_empresa
     
      IF STATUS = 0 THEN
         ERROR "Código já cadastrado"
         NEXT FIELD cod_lin_prod
      END IF     
      
      SELECT cod_lin_prod
        FROM linha_prod
       WHERE cod_lin_prod  = p_lib_linprod_1040.cod_lin_prod 
         AND cod_lin_recei = 0
         AND cod_seg_merc  = 0
         AND cod_cla_uso   = 0
                
      IF STATUS = 100 THEN
         ERROR "Código não cadastrado"
         NEXT FIELD cod_lin_prod
      END IF    
           
      SELECT den_estr_linprod 
        INTO p_den_estr_linprod
        FROM linha_prod
       WHERE cod_lin_prod  = p_lib_linprod_1040.cod_lin_prod 
         AND cod_lin_recei = 0
         AND cod_seg_merc  = 0
         AND cod_cla_uso   = 0
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'linha_prod')
         RETURN FALSE 
      END IF    
      
      DISPLAY p_den_estr_linprod TO den_estr_linprod
      
      AFTER FIELD envia_almox
      IF p_lib_linprod_1040.envia_almox IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD envia_almox   
      END IF
      
      IF p_lib_linprod_1040.envia_almox = 'S' OR  
         p_lib_linprod_1040.envia_almox = 'N' THEN 
      ELSE   
         ERROR "Valor ilegal para o campo em questão!!!"
         NEXT FIELD envia_almox   
      END IF
 {------------alterado-------thiago--------------------------13/03/2009}     
      AFTER FIELD oc_linha									
      	IF p_lib_linprod_1040.oc_linha IS NULL THEN 
      		 ERROR "Campo com preenchimento obrigatório !!!"
      		 NEXT FIELD oc_linha
      	ELSE 
	      	IF p_lib_linprod_1040.oc_linha = 'S' OR  
	         p_lib_linprod_1040.oc_linha = 'N' THEN 
		      ELSE   
		         ERROR "Valor ilegal para o campo em questão!!!"
		         NEXT FIELD oc_linha
		      END IF
      	END IF 
{---------------------------------------------------------------}   
      ON KEY (control-z)
        CALL pol0582_popup_linha_prod()
        
   END INPUT 


   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-------------------------------------#
 FUNCTION pol0582_consulta_linha_prod()
#-------------------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500) 
            

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_lin_prod_ant = p_cod_lin_prod
   LET p_ies_cons = FALSE
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      lib_linprod_1040.cod_lin_prod,
      lib_linprod_1040.envia_almox,
      lib_linprod_1040.oc_linha
      
   IF INT_FLAG THEN
      LET p_cod_lin_prod = p_cod_lin_prod_ant
      CALL pol0582_exibe_dados_linha_prod() RETURNING p_status
      RETURN 
   END IF

   LET sql_stmt = "SELECT cod_lin_prod ",
                  "  FROM lib_linprod_1040 ",
                  " WHERE ", where_clause CLIPPED,
                  "AND cod_empresa=",p_cod_empresa,
                  " ORDER BY cod_lin_prod"

   PREPARE var_query_linha FROM sql_stmt   
   DECLARE cq_linha SCROLL CURSOR WITH HOLD FOR var_query_linha

   OPEN cq_linha

   FETCH cq_linha INTO p_cod_lin_prod

   IF STATUS = NOTFOUND THEN
      ERROR "Argumentos de pesquisa não encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0582_exibe_dados_linha_prod() THEN
         LET p_ies_cons = TRUE
      END IF
   END IF
   
   RETURN

END FUNCTION

#----------------------------------------#
 FUNCTION pol0582_exibe_dados_linha_prod()
#----------------------------------------#

  LET p_den_estr_linprod = NULL 
  
  SELECT cod_lin_prod, envia_almox, oc_linha
    INTO 	p_lib_linprod_1040.cod_lin_prod,
    			p_lib_linprod_1040.envia_almox,
    			p_lib_linprod_1040.oc_linha
    FROM lib_linprod_1040
   WHERE cod_lin_prod = p_cod_lin_prod 
   AND cod_empresa = p_cod_empresa
     

   IF STATUS = 0 THEN
      
      SELECT den_estr_linprod 
        INTO p_den_estr_linprod
        FROM linha_prod
       WHERE cod_lin_prod  = p_lib_linprod_1040.cod_lin_prod 
         AND cod_lin_recei = 0
         AND cod_seg_merc  = 0
         AND cod_cla_uso   = 0
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo', 'linha_prod')
         RETURN FALSE
      END IF       
      
      DISPLAY p_den_estr_linprod TO den_estr_linprod
      
      DISPLAY BY NAME p_lib_linprod_1040.*
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION


#----------------------------------------------#
 FUNCTION pol0582_paginacao_linha_prod(p_funcao)
#----------------------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_lin_prod_ant = p_cod_lin_prod

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_linha INTO p_cod_lin_prod
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_linha INTO p_cod_lin_prod
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção"
            LET p_cod_lin_prod = p_cod_lin_prod_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_linha')
         END IF
         EXIT WHILE
      END IF    
      
      IF pol0582_exibe_dados_linha_prod() THEN
         EXIT WHILE
      END IF

   END WHILE

END FUNCTION


#--------------------------------------------#
 FUNCTION pol0582_prende_registro_linha_prod()
#--------------------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende_linha_prod CURSOR WITH HOLD FOR
    SELECT cod_lin_prod 
      FROM lib_linprod_1040  
     WHERE cod_lin_prod  = p_cod_lin_prod
     			AND cod_empresa= p_cod_empresa
       FOR UPDATE 
    
    OPEN cq_prende_linha_prod
   FETCH cq_prende_linha_prod
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","lib_linprod_1040")
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0582_modificacao_linha_prod()
#----------------------------------------#
   
   LET p_retorno = FALSE

   IF pol0582_prende_registro_linha_prod() THEN
      IF pol0582_edita_linha_prod("M") THEN
         UPDATE lib_linprod_1040
            SET envia_almox   = p_lib_linprod_1040.envia_almox,
            		oc_linha	=	p_lib_linprod_1040.oc_linha
          WHERE cod_lin_prod  = p_cod_lin_prod
          	AND cod_empresa = p_cod_empresa
             

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","lib_linprod_1040")
         END IF
      ELSE
         CALL pol0582_exibe_dados_linha_prod() RETURNING p_status
      END IF
      CLOSE cq_prende_linha_prod
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#-----------------------------------#
 FUNCTION pol0582_exclui_linha_prod()
#-----------------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol0582_prende_registro_linha_prod() THEN
      DELETE FROM lib_linprod_1040
			      WHERE cod_lin_prod  = p_cod_lin_prod
			      		AND 	cod_empresa = p_cod_empresa
    		 

      IF STATUS = 0 THEN               
         INITIALIZE p_lib_linprod_1040 TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","lib_linprod_1040")
      END IF
      CLOSE cq_prende_linha_prod
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  


#---------------------------------#
FUNCTION pol0582_popup_linha_prod()
#---------------------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_lin_prod)
         CALL pol0582_popup_lin_prod() RETURNING p_codigo
         CURRENT WINDOW IS w_pol05825
         IF p_codigo IS NOT NULL THEN
            LET p_lib_linprod_1040.cod_lin_prod = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_lin_prod
         END IF
   END CASE

END FUNCTION 

#-------------------------------#
FUNCTION pol0582_popup_lin_prod()
#-------------------------------#
      
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol05826") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol05826 AT 8,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_index = 1
   
   DECLARE cq_popup_lin_prod CURSOR FOR
    SELECT cod_lin_prod,
           den_estr_linprod
      FROM linha_prod
     WHERE cod_lin_recei = 0
       AND cod_seg_merc  = 0
       AND cod_cla_uso   = 0
     ORDER BY cod_lin_prod
      
   FOREACH cq_popup_lin_prod INTO 
           pr_lin_prod[p_index].cod_lin_prod, 
           pr_lin_prod[p_index].den_estr_linprod
           
       LET p_index = p_index + 1
  
   IF p_index > 1000 THEN
      ERROR 'Limite de Grades ultrapassado'
      EXIT FOREACH
   END IF
   END FOREACH
   
   CALL SET_COUNT(P_index - 1)
    
   DISPLAY ARRAY pr_lin_prod TO sr_lin_prod.*
      LET p_index = ARR_CURR()
    
   CLOSE WINDOW w_pol05826
   
   RETURN pr_lin_prod[p_index].cod_lin_prod
           
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
