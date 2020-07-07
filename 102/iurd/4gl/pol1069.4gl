#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1069                                                 #
# OBJETIVO: EVENTOS PARA EMPRÉSTIMOS CONSIGNADOS                    #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 23/11/10                                                #
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
          p_ies_ambiente       char(01)
         
  
   DEFINE pr_eventos           ARRAY[1000] OF RECORD
          estado               LIKE evento_265.estado,
          cod_evento           LIKE evento_265.cod_evento,
          den_evento           LIKE evento.den_evento,
          tip_evento           LIKE evento_265.tip_evento,
          den_tipo             CHAR(33)
   END RECORD

   DEFINE p_cod_banco          LIKE bancos.cod_banco,
          p_cod_banco_dest     LIKE bancos.cod_banco,
          p_cod_banco_ant      LIKE bancos.cod_banco,
          p_nom_banco          LIKE bancos.nom_banco,
          p_cod_evento         LIKE evento_265.cod_evento,
          p_den_evento         LIKE evento.den_evento,
          p_tip_evento         LIKE evento_265.tip_evento,
          p_den_tipo           CHAR(33),
          p_estado             CHAR(02)
          
END GLOBALS

DEFINE p_dat_atu CHAR(10)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1069-10.02.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1069_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1069_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1069") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1069 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   LET p_dat_atu = EXTEND(CURRENT, YEAR TO DAY)
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1069_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1069_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1069_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1069_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1069_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_banco TO cod_banco
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1069_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1069_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1069_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1069

END FUNCTION

#--------------------------#
 FUNCTION pol1069_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE pr_eventos TO NULL
   INITIALIZE p_cod_banco TO NULL
   LET p_opcao = 'I'
   
   IF pol1069_edita_dados() THEN      
      IF pol1069_edita_eventos('I') THEN      
         IF pol1069_grava_dados() THEN                                                     
            RETURN TRUE                                                                    
         END IF                                                                      
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1069_edita_dados()
#-----------------------------#
   
   LET INT_FLAG = FALSE
   
   INPUT p_cod_banco WITHOUT DEFAULTS
    FROM cod_banco
            
      AFTER FIELD cod_banco
      IF p_cod_banco IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_banco   
      END IF
                            
      SELECT den_reduz
        INTO p_nom_banco
        FROM banco_265
       WHERE cod_banco = p_cod_banco
       
      IF STATUS = 100 THEN
         ERROR "Banco não cadastrado para empréstimo consignado !!!"
         NEXT FIELD cod_banco
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','banco_265')
            RETURN FALSE
         END IF 
      END IF

      DISPLAY p_nom_banco TO nom_banco
      
      LET p_count = 0
      
      SELECT COUNT(cod_banco)
        INTO p_count
        FROM evento_265
       WHERE cod_banco = p_cod_banco
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','evento_265')
         RETURN FALSE
      END IF 
  
      IF p_count > 0 THEN
         ERROR "Já existem eventos p/ esse banco !!! - Use a opção modificar"
         NEXT FIELD cod_banco
      END IF
      
      ON KEY (control-z)
         CALL pol1069_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------------#
 FUNCTION pol1069_edita_eventos(p_funcao)
#----------------------------------------#     

   DEFINE p_funcao CHAR(01)
   
   INPUT ARRAY pr_eventos
      WITHOUT DEFAULTS FROM sr_eventos.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
      AFTER FIELD estado
         IF pr_eventos[p_index].estado IS NOT NULL THEN 
            IF pr_eventos[p_index].estado <> 'RJ' AND
               pr_eventos[p_index].estado <> 'BR' THEN
               ERROR 'Valor inválido para o campo !!!'
               NEXT FIELD estado
            END IF
         END IF
      
      BEFORE FIELD cod_evento
         IF pr_eventos[p_index].estado IS NULL THEN 
            LET pr_eventos[p_index].estado = 'BR'
            DISPLAY pr_eventos[p_index].estado TO sr_eventos[s_index].estado
         END IF
      
      AFTER FIELD cod_evento
      
         IF pr_eventos[p_index].cod_evento IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD cod_evento
         END IF
         
         FOR p_ind = 1 TO ARR_COUNT()                                                                        
            IF p_ind <> p_index THEN                                                                            
               IF pr_eventos[p_ind].cod_evento = pr_eventos[p_index].cod_evento THEN    
                  IF pr_eventos[p_ind].estado = pr_eventos[p_index].estado THEN    
                     ERROR "Evento já informado para esse banco/estado !!!"                                               
                     NEXT FIELD cod_evento   
                  END IF                                                                      
               END IF                                                                                           
            END IF                                                                                              
         END FOR                                                                                                
                                                                                                                
         LET p_count = 0                                                                                        
                                                                                                                
         DECLARE cq_evento CURSOR FOR                                                                           
                                                                                                                
          SELECT DISTINCT den_evento                                                                            
            FROM evento                                                                                         
           WHERE cod_evento = pr_eventos[p_index].cod_evento                                                    
                                                                                                                
         FOREACH cq_evento                                                                                      
            INTO pr_eventos[p_index].den_evento                                                                 
                                                                                                                
            IF STATUS <> 0 THEN                                                                                 
               CALL log003_err_sql('lendo','evento')                                                            
               RETURN FALSE                                                                                     
            END IF                                                                                              
                                                                                                                
            LET p_count = 1                                                                                     
                                                                                                                
            EXIT FOREACH                                                                                        
                                                                                                                
         END FOREACH                                                                                            
                                                                                                                
         IF p_count = 0 THEN                                                                                    
            ERROR "Evento não cadastrado no Logix !!!"                                                          
            NEXT FIELD cod_evento                                                                               
         END IF                                                                                                 
                                                                                                                                                                                                                                
         DISPLAY pr_eventos[p_index].den_evento TO sr_eventos[s_index].den_evento                               
            
      
      AFTER FIELD tip_evento
         IF pr_eventos[p_index].cod_evento IS NOT NULL THEN
            IF pr_eventos[p_index].tip_evento IS NULL THEN
               ERROR "Campo com prenchimento obrigatório !!!"
               NEXT FIELD tip_evento
            ELSE
               IF pr_eventos[p_index].tip_evento <> '1' AND
                  pr_eventos[p_index].tip_evento <> '2' AND
                  pr_eventos[p_index].tip_evento <> '3' AND
                  pr_eventos[p_index].tip_evento <> '4' THEN
                  ERROR "Evento invalido !!!"
                  NEXT FIELD tip_evento
               END IF
               
               IF pr_eventos[p_index].tip_evento = '1'THEN
                  LET pr_eventos[p_index].den_tipo = "Desconto da parcela de empréstimo"
               ELSE
                  IF pr_eventos[p_index].tip_evento = '2' THEN
                     LET pr_eventos[p_index].den_tipo = "Desconto de rescisão"
                  ELSE
                     IF pr_eventos[p_index].tip_evento = '3' THEN
                        LET pr_eventos[p_index].den_tipo = "Desconto de afastamento pelo INSS"
                     ELSE
                        LET pr_eventos[p_index].den_tipo = "Reembolso"
                     END IF
                  END IF
               END IF
               
               DISPLAY pr_eventos[p_index].den_tipo TO sr_eventos[s_index].den_tipo
            END IF
         ELSE
            LET pr_eventos[p_index].tip_evento = NULL
            DISPLAY '' TO sr_eventos[s_index].tip_evento
         END IF
                   
         AFTER ROW
            IF NOT INT_FLAG THEN                                    
               IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN                       
               ELSE                     
                  IF pr_eventos[p_index].estado IS NULL THEN   
                     NEXT FIELD estado                             
                  END IF                                           
                  IF pr_eventos[p_index].cod_evento IS NULL THEN   
                     NEXT FIELD cod_evento                         
                  END IF                                           
                  IF pr_eventos[p_index].tip_evento IS NULL THEN   
                     NEXT FIELD tip_evento                         
                  END IF                                           
               END IF                                              
            END IF                                                 
         
         ON KEY (control-z)
            CALL pol1069_popup()
                 
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      IF p_funcao = 'I' THEN
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
      ELSE
        CALL pol1069_carrega_eventos() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
         
END FUNCTION

#---------------------------------#
 FUNCTION pol1069_carrega_eventos()
#---------------------------------#
   
   INITIALIZE pr_eventos TO NULL
   
   LET p_index = 1
   
   DECLARE cq_array CURSOR FOR
   
    SELECT cod_evento,
           tip_evento,
           estado
      FROM evento_265
     WHERE cod_banco = p_cod_banco
     ORDER BY estado, cod_evento
     
   FOREACH cq_array
      INTO pr_eventos[p_index].cod_evento,
           pr_eventos[p_index].tip_evento,
           pr_eventos[p_index].estado
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "cursor: cq_array")
         RETURN FALSE
      END IF
      
      DECLARE cq_le_den_evento CURSOR FOR
      
       SELECT DISTINCT den_evento
         FROM evento
        WHERE cod_evento  = pr_eventos[p_index].cod_evento
      
      FOREACH cq_le_den_evento
         INTO pr_eventos[p_index].den_evento
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "cursor: cq_le_den_evento_1")
            RETURN FALSE
         END IF
         
         EXIT FOREACH
         
      END FOREACH
      
      IF pr_eventos[p_index].tip_evento = '1' THEN
         LET pr_eventos[p_index].den_tipo = "Desconto da parcela de empréstimo"
      ELSE
         IF pr_eventos[p_index].tip_evento = '2' THEN
            LET pr_eventos[p_index].den_tipo = "Desconto de rescisão"
         ELSE
            IF pr_eventos[p_index].tip_evento = '3' THEN
               LET pr_eventos[p_index].den_tipo = "Desconto de afastamento pelo INSS"
            ELSE
               LET pr_eventos[p_index].den_tipo = "Reembolso"
            END IF
         END IF
      END IF
         
      LET p_index = p_index + 1
      
      IF p_index > 1000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY p_cod_banco TO cod_banco
   DISPLAY p_nom_banco TO nom_banco
   
   IF p_index > 9 THEN
      DISPLAY ARRAY pr_eventos TO sr_eventos.*
   ELSE
      INPUT ARRAY pr_eventos WITHOUT DEFAULTS FROM sr_eventos.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF
   
   RETURN TRUE
   
END FUNCTION 

#-----------------------------#
 FUNCTION pol1069_grava_dados()
#-----------------------------#
   
   DEFINE p_incluiu SMALLINT
   
   CALL log085_transacao("BEGIN")
   
   LET p_incluiu = FALSE
   
   DELETE FROM evento_265
    WHERE cod_banco = p_cod_banco
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "evento_265")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_eventos[p_ind].cod_evento IS NOT NULL THEN
          
		       INSERT INTO evento_265
		       VALUES (p_cod_banco,
		               pr_eventos[p_ind].cod_evento,
		               pr_eventos[p_ind].tip_evento,
		               pr_eventos[p_ind].estado)
		
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Incluindo", "evento_265")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
		       LET p_incluiu = TRUE
       END IF
   END FOR
         
   CALL log085_transacao("COMMIT")	      
   
   IF p_opcao = "I" THEN
      IF NOT p_incluiu THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
      
END FUNCTION

#-----------------------#
 FUNCTION pol1069_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_banco)
         LET p_codigo = pol1069_le_bancos()
         IF p_codigo IS NOT NULL THEN
           LET p_cod_banco = p_codigo
           DISPLAY p_codigo TO cod_banco
         END IF
      
      WHEN INFIELD(cod_evento)
         LET p_codigo = pol1069_exibe_eventos()
                   
         IF p_codigo IS NOT NULL THEN
            LET pr_eventos[p_index].cod_evento = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_evento
         END IF
      
      WHEN INFIELD(tip_evento)
         LET p_codigo = pol1069_tipos_dos_eventos()
         IF p_codigo IS NOT NULL THEN
           LET pr_eventos[p_index].tip_evento = p_codigo
           DISPLAY p_codigo TO tip_evento
         END IF
   END CASE 

END FUNCTION 

#-------------------------------#
FUNCTION pol1069_exibe_eventos()
#-------------------------------#

   DEFINE pr_pop_eve           ARRAY[1000] OF RECORD
          cod_evento           LIKE evento.cod_evento,
          den_evento           LIKE evento.den_evento
   END RECORD

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10693") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10693 AT 5,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   
   LET p_ind = 1
   
   DECLARE cq_pop_eve CURSOR FOR
    SELECT DISTINCT
           cod_evento,
           den_evento
      FROM evento 
     WHERE cod_empresa = p_cod_empresa
       AND TO_CHAR(dat_validade_ini, 'YYYY-MM-DD') <= p_dat_atu 
       AND TO_CHAR(dat_validade_fim, 'YYYY-MM-DD') >= p_dat_atu
     ORDER BY cod_evento
   
   FOREACH cq_pop_eve INTO 
           pr_pop_eve[p_ind].cod_evento,
           pr_pop_eve[p_ind].den_evento
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_pop_eve')           
         RETURN FALSE
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 1000 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou!','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
      
   DISPLAY ARRAY pr_pop_eve TO sr_pop_eve.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol10693
   
   IF NOT INT_FLAG THEN
      RETURN pr_pop_eve[p_ind].cod_evento
   ELSE
      RETURN ""
   END IF
   
END FUNCTION
                       
#---------------------------#
 FUNCTION pol1069_le_bancos()
#---------------------------#

   DEFINE pr_bancos  ARRAY[2000] OF RECORD
          cod_banco  LIKE banco_265.cod_banco,
          nom_banco  LIKE bancos.nom_banco
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10691") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10691 AT 5,16 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_bancos CURSOR FOR
   
    SELECT cod_banco
      FROM banco_265
     ORDER BY cod_banco

   FOREACH cq_bancos
      INTO pr_bancos[p_ind].cod_banco   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor: cq_bancos')
         EXIT FOREACH
      END IF
      
      SELECT nom_banco
        INTO pr_bancos[p_ind].nom_banco
        FROM bancos
       WHERE cod_banco = pr_bancos[p_ind].cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','bancos')
         EXIT FOREACH
      END IF
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 2000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_bancos TO sr_bancos.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol10691
   
   IF NOT INT_FLAG THEN
      RETURN pr_bancos[p_ind].cod_banco
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1069_tipos_dos_eventos()
#-----------------------------------#

   DEFINE pr_tip_eventos  ARRAY[4] OF RECORD
          tip_evento      LIKE evento_265.tip_evento,
          den_tipo        CHAR(33)
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10692") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10692 AT 5,16 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
    
   LET pr_tip_eventos[1].tip_evento = '1'
   LET pr_tip_eventos[1].den_tipo   = 'Desconto da parcela de empréstimo'
   LET pr_tip_eventos[2].tip_evento = '2'
   LET pr_tip_eventos[2].den_tipo   = 'Desconto de rescisão'
   LET pr_tip_eventos[3].tip_evento = '3'
   LET pr_tip_eventos[3].den_tipo   = 'Desconto de afastamento pelo INSS'
   LET pr_tip_eventos[4].tip_evento = '4'
   LET pr_tip_eventos[4].den_tipo   = 'Reembolso'
   
   LET p_ind = 4
   
   CALL SET_COUNT(p_ind)
   
   DISPLAY ARRAY pr_tip_eventos TO sr_tip_eventos.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol10692
   
   IF NOT INT_FLAG THEN
      RETURN pr_tip_eventos[p_ind].tip_evento
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#--------------------------#
 FUNCTION pol1069_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_banco_ant = p_cod_banco
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      evento_265.cod_banco
      
      ON KEY (control-z)
         CALL pol1069_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_banco = p_cod_banco_ant
         CALL pol1069_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT DISTINCT cod_banco ",
                  "  FROM evento_265 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_banco"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_banco

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1069_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1069_exibe_dados()
#------------------------------#

   SELECT nom_banco
     INTO p_nom_banco
     FROM bancos
    WHERE cod_banco = p_cod_banco
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','bancos')
      RETURN FALSE 
   END IF
        
   IF NOT pol1069_carrega_eventos() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1069_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_banco_ant = p_cod_banco

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_banco
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_banco
         
      END CASE

      IF STATUS = 0 THEN
         
         LET p_count = 0
         
         SELECT COUNT(cod_banco)
           INTO p_count
           FROM evento_265
          WHERE cod_banco  = p_cod_banco
                        
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "evento_265")
         END IF
         
         IF p_count > 0 THEN   
            CALL pol1069_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_banco = p_cod_banco_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1069_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT cod_banco 
      FROM evento_265  
     WHERE cod_banco  = p_cod_banco
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","evento_265")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1069_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'
   
   IF pol1069_prende_registro() THEN
      IF pol1069_edita_eventos('M') THEN
         IF pol1069_grava_dados() THEN
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
 FUNCTION pol1069_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1069_prende_registro() THEN
      DELETE FROM evento_265
			 WHERE cod_banco = p_cod_banco
         
      IF STATUS = 0 THEN               
         INITIALIZE p_cod_banco TO NULL
         INITIALIZE pr_eventos TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","evento_265")
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
 FUNCTION pol1069_listagem()
#--------------------------#     

   IF NOT pol1069_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1069_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_banco,
          cod_evento,
          tip_evento,
          estado
     FROM evento_265
 ORDER BY cod_banco, cod_evento                          
  
   FOREACH cq_impressao 
      INTO p_cod_banco,
           p_cod_evento,
           p_tip_evento,
           p_estado
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT nom_banco
        INTO p_nom_banco
        FROM bancos
       WHERE cod_banco = p_cod_banco
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'bancos')
         RETURN
      END IF                                                             
                                                                                       
      DECLARE cq_listar_evento CURSOR FOR                                               
                                                                                       
       SELECT den_evento                                                         
         FROM evento                                                             
        WHERE cod_evento = p_cod_evento                        
                                                                                       
      FOREACH cq_listar_evento                                                          
         INTO p_den_evento                                     
                                                                                       
         IF STATUS <> 0 THEN                                                     
            CALL log003_err_sql('lendo','evento')                                
            RETURN FALSE                                                         
         END IF                                                                                                                           
                                                                                       
         EXIT FOREACH                                                            
                                                                                       
      END FOREACH
      
      IF p_tip_evento = '1'THEN
         LET p_den_tipo = "Desconto da parcela de empréstimo"
      ELSE
         IF p_tip_evento = '2' THEN
            LET p_den_tipo = "Desconto de rescisão"
         ELSE
            IF p_tip_evento = '3' THEN
               LET p_den_tipo = "Desconto de afastamento pelo INSS"
            ELSE
               LET p_den_tipo = "Reembolso"
            END IF
         END IF
      END IF
      
   OUTPUT TO REPORT pol1069_relat(p_cod_banco) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1069_relat   
   
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
 FUNCTION pol1069_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1069.tmp"
         START REPORT pol1069_relat TO p_caminho
      ELSE
         START REPORT pol1069_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1069_le_den_empresa()
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

#--------------------------------#
 REPORT pol1069_relat(p_cod_banco)
#--------------------------------#
    
   DEFINE p_cod_banco LIKE bancos.cod_banco
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1069",
               COLUMN 013, "EVENTOS PARA EMPRESTIMOS CONSIGNADOS",
               COLUMN 053, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "---------------------------------------------------------------------------------"
         PRINT
               
      BEFORE GROUP OF p_cod_banco
         
         PRINT
         PRINT COLUMN 003, "Banco: ", p_cod_banco, " - ", p_nom_banco
         PRINT
         PRINT COLUMN 002, 'Estado Evento      Descricao       Tipo           Descricao'
         PRINT COLUMN 002, '------ ------ -------------------- ---- ---------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 004, p_estado,
               COLUMN 010, p_cod_evento   USING "#####",
               COLUMN 016, p_den_evento,
               COLUMN 040, p_tip_evento   USING "#",
               COLUMN 042, p_den_tipo
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-----------------------#
 FUNCTION pol1069_sobre()
#-----------------------#

   {SELECT nom_caminho,
          ies_ambiente 
     INTO p_caminho,
          p_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "UNL"

   LET p_nom_arquivo = p_caminho clipped,'funcionario.unl'
   
   LOAD from p_nom_arquivo INSERT INTO funcionario

   if STATUS <> 0 then
   end if}
   
   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
