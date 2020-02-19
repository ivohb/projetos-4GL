#-------------------------------------------------------------------#
# SISTEMA.: EMISSOR DE LAUDOS                                       #
# PROGRAMA: POL0315                                                 #
# MODULOS.: POL0315 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: CADASTRAR OS RESULTADOS DAS ANALISES                    #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 09/02/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,  
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_houve_erro    SMALLINT,
          comando         CHAR(80),
      #   p_versao        CHAR(17),
          p_versao        CHAR(18),
          p_ies_impressao CHAR(001),
          g_ies_ambiente  CHAR(001),
          p_nom_arquivo   CHAR(100),
          p_arquivo       CHAR(025),
          p_caminho       CHAR(080),
          p_nom_tela      CHAR(200),
          p_nom_help      CHAR(200),
          sql_stmt        CHAR(500),
          p_r             CHAR(001),
          p_count         SMALLINT,
          p_ies_cons      SMALLINT,
          p_last_row      SMALLINT,
          p_grava         SMALLINT, 
          pa_curr         SMALLINT,
          pa_curr1        SMALLINT,
          sc_curr         SMALLINT,
          sc_curr1        SMALLINT,
          w_a             SMALLINT,
          p_qtd_dia_validade  INTEGER,
          p_ies_indeterminada CHAR(01),
          p_dat_fabricacao    DATE,
		  p_msg           CHAR(100)

END GLOBALS
   
   DEFINE w_i             SMALLINT

   DEFINE mr_tela RECORD 
      cod_item       LIKE analise_petrom.cod_item,
      lote_tanque    LIKE analise_petrom.lote_tanque,
      dat_fabricacao LIKE analise_petrom.dat_analise,
      dat_analise    LIKE analise_petrom.dat_analise,
      hor_analise    LIKE analise_petrom.hor_analise,
      num_pa         LIKE analise_petrom.num_pa
   END RECORD 

   DEFINE mr_telat RECORD 
      cod_item       LIKE analise_petrom.cod_item,
      lote_tanque    LIKE analise_petrom.lote_tanque,
      dat_fabricacao LIKE analise_petrom.dat_analise,
      dat_analise    LIKE analise_petrom.dat_analise,
      hor_analise    LIKE analise_petrom.hor_analise,
      num_pa         LIKE analise_petrom.num_pa
   END RECORD 
   
   DEFINE ma_tela ARRAY[50] OF RECORD 
      tip_analise    LIKE analise_petrom.tip_analise,
      den_analise    LIKE it_analise_petrom.den_analise,
      metodo         LIKE analise_petrom.metodo,
      val_analise    LIKE analise_petrom.val_analise
   END RECORD 

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0315-10.02.06"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0315.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0315_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0315_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0315") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0315 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0315","IN") THEN
            IF pol0315_inclusao() THEN
               CALL pol0315_busca_itens_analise()
               IF pol0315_entrada_item("INCLUSAO") THEN
                  CALL pol0315_grava_dados()
               END IF
            END IF
         END IF
      
      COMMAND KEY("C") "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0315","CO") THEN
            IF pol0315_consulta() THEN
               IF p_ies_cons = TRUE THEN
                  NEXT OPTION "Seguinte"
               END IF
            END IF
         END IF  
     
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
      #  LET INT_FLAG = 0
         CALL pol0315_paginacao("SEGUINTE")
     
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
      #  LET INT_FLAG = 0
         CALL pol0315_paginacao("ANTERIOR") 
     
      COMMAND "Modificar" "Modifica dados da Tabela"
         HELP 002
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0315","MO") THEN
               CALL pol0315_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
     
      COMMAND "Excluir" "Exclui dados da Tabela"
         HELP 003
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0315","EX") THEN
               CALL pol0315_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
		 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0315_sobre()
		 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0315

END FUNCTION
 
#--------------------------#
 FUNCTION pol0315_inclusao()
#--------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0315
   INITIALIZE mr_tela.* TO NULL
   INITIALIZE ma_tela TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET mr_tela.dat_analise = TODAY
   LET mr_tela.hor_analise = CURRENT HOUR TO SECOND

   LET INT_FLAG =  FALSE
   INPUT BY NAME mr_tela.*  WITHOUT DEFAULTS  

      AFTER FIELD cod_item 
         IF mr_tela.cod_item IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD cod_item       
         ELSE
            IF pol0315_verifica_item() = FALSE THEN
               ERROR 'Item não cadastrado.'
               NEXT FIELD cod_item
            END IF   
         END IF
         

      AFTER FIELD lote_tanque
         IF mr_tela.lote_tanque IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD lote_tanque 
         END IF

         SELECT dat_fabricacao
           INTO p_dat_fabricacao
           FROM validade_lote_455
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = mr_tela.cod_item 
            AND num_lote    = mr_tela.lote_tanque
      
         IF STATUS = 100 THEN
            LET p_dat_fabricacao = NULL
         ELSE
            IF  STATUS <> 100 
            AND STATUS <> 0  THEN
               CALL log003_err_sql('Lendo','validade_lote_455')
               NEXT FIELD lote_tanque
            END IF
         END IF
         
      BEFORE FIELD dat_fabricacao
         
         IF p_qtd_dia_validade > 0 OR
            p_ies_indeterminada = 'S' THEN
            IF mr_tela.dat_fabricacao IS NULL THEN
               LET mr_tela.dat_fabricacao = p_dat_fabricacao
            END IF
         ELSE
            LET mr_tela.dat_fabricacao = NULL
         END IF

      AFTER FIELD dat_fabricacao
         
         IF p_qtd_dia_validade > 0 OR
            p_ies_indeterminada = 'S' THEN
            IF mr_tela.dat_fabricacao IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório!'
               NEXT FIELD dat_fabricacao
            END IF
         ELSE
            LET mr_tela.dat_fabricacao = NULL
            DISPLAY mr_tela.dat_fabricacao TO dat_fabricacao
         END IF                     
         
      AFTER FIELD dat_analise
         IF mr_tela.dat_analise IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD dat_analise      
         END IF

      AFTER FIELD hor_analise
         IF mr_tela.hor_analise IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD hor_analise      
         END IF
 
      BEFORE FIELD num_pa
         IF pol0315_verifica_se_eh_tanque() = FALSE THEN
            CALL pol0315_busca_num_pa()
         ELSE
            EXIT INPUT
         END IF

      AFTER FIELD num_pa
         IF mr_tela.num_pa IS NOT NULL THEN
            IF pol0315_verifica_num_pa() THEN
               ERROR 'Número de PA já existe para este Item/Lote.'
               NEXT FIELD num_pa
            END IF
         END IF 
 
      ON KEY (control-z)
         CALL pol0315_popup()
 
    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0315
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0315_verifica_item()
#-------------------------------#
   DEFINE l_den_item         LIKE item.den_item

   SELECT den_item_petrom,
          qtd_dia_validade,
          ies_indeterminada
     INTO l_den_item,
          p_qtd_dia_validade,
          p_ies_indeterminada
     FROM item_petrom
    WHERE cod_empresa     = p_cod_empresa
      AND cod_item_petrom = mr_tela.cod_item
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item to den_item
      IF p_qtd_dia_validade IS NULL THEN
         LET p_qtd_dia_validade = 0
      END IF
      IF p_ies_indeterminada IS NULL THEN
         LET p_ies_indeterminada = 'N'
      END IF
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION           

#---------------------------------------# 
 FUNCTION pol0315_verifica_se_eh_tanque()
#---------------------------------------# 
   DEFINE l_ies_tanque          CHAR(1)

   DECLARE cq_tanque CURSOR FOR
    SELECT ies_tanque
      FROM especific_petrom
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = mr_tela.cod_item

     OPEN cq_tanque 
    FETCH cq_tanque INTO l_ies_tanque

    CLOSE cq_tanque

   IF l_ies_tanque = 'S' THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 

END FUNCTION

#------------------------------#
 FUNCTION pol0315_busca_num_pa()
#------------------------------#
   
   SELECT MAX(num_pa)
     INTO mr_tela.num_pa
     FROM analise_petrom
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND lote_tanque = mr_tela.lote_tanque
   
   IF mr_tela.num_pa IS NULL THEN
      LET mr_tela.num_pa = 1
   ELSE
      LET mr_tela.num_pa = mr_tela.num_pa + 1
   END IF
  
   DISPLAY mr_tela.num_pa TO num_pa

END FUNCTION

#---------------------------------#
 FUNCTION pol0315_verifica_num_pa()
#---------------------------------#

   WHENEVER ERROR CONTINUE
   SELECT num_pa
     FROM analise_petrom
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND lote_tanque = mr_tela.lote_tanque
      AND num_pa      = mr_tela.num_pa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 OR
      sqlca.sqlcode = -284 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 

END FUNCTION 

#-------------------------------------#
 FUNCTION pol0315_busca_itens_analise()
#-------------------------------------#
   DEFINE l_ind           SMALLINT

   LET l_ind = 1

   DECLARE cq_itens CURSOR FOR
    SELECT tip_analise, metodo
      FROM especific_petrom
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = mr_tela.cod_item
       AND cod_cliente IS NULL 
   FOREACH cq_itens INTO ma_tela[l_ind].tip_analise,
                         ma_tela[l_ind].metodo

      SELECT den_analise  
        INTO ma_tela[l_ind].den_analise
        FROM it_analise_petrom
       WHERE cod_empresa = p_cod_empresa
         AND tip_analise = ma_tela[l_ind].tip_analise
 
      LET l_ind = l_ind + 1
   END FOREACH

   IF l_ind > 1 THEN
      LET l_ind = l_ind - 1
   END IF 
   
   CALL SET_COUNT(l_ind)
   IF l_ind > 7 THEN
      DISPLAY ARRAY ma_tela TO s_itens.*
   ELSE
      INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF                

END FUNCTION

#--------------------------------------#
 FUNCTION pol0315_entrada_item(p_funcao) 
#--------------------------------------#
   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0315

   LET INT_FLAG =  FALSE
 
   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*

      BEFORE FIELD tip_analise 
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()
         NEXT FIELD val_analise

      BEFORE FIELD metodo
         NEXT FIELD val_analise

      AFTER FIELD val_analise
         IF ma_tela[pa_curr].val_analise IS NOT NULL THEN
            IF ma_tela[pa_curr].tip_analise IS NULL OR
               ma_tela[pa_curr].tip_analise = ' ' THEN
               ERROR 'Não contém Tipo de Análise para esta Linha.'
               INITIALIZE ma_tela[pa_curr].val_analise TO NULL  
               NEXT FIELD val_analise
            END IF
         END IF
            
    AFTER INPUT
       IF INT_FLAG = 0 THEN 
          FOR l_ind = 1 TO pa_curr
             IF ma_tela[l_ind].tip_analise IS NOT NULL THEN
                IF ma_tela[l_ind].val_analise IS NULL THEN
                   LET pa_curr = l_ind
                   ERROR 'Valores das análises não podem ser nulo.'
                   NEXT FIELD val_analise
                END IF  
             END IF 
          END FOR
       END IF
 
   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0315
   
   IF INT_FLAG THEN
      IF p_funcao = "MODIFICACAO" THEN
         RETURN FALSE
      ELSE
         CLEAR FORM
         ERROR "Inclusao Cancelada"
         LET p_ies_cons = FALSE
         RETURN FALSE
      END IF
   ELSE
      RETURN TRUE 
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0315_grava_dados()
#-----------------------------#

   LET p_houve_erro = FALSE
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   FOR w_i = 1 TO 50
      IF ma_tela[w_i].tip_analise IS NOT NULL AND
         ma_tela[w_i].val_analise IS NOT NULL THEN 
         WHENEVER ERROR CONTINUE
         INSERT INTO analise_petrom 
         VALUES (p_cod_empresa,
                 mr_tela.cod_item,        
                 mr_tela.dat_analise,
                 mr_tela.hor_analise, 
                 mr_tela.lote_tanque,
                 ma_tela[w_i].tip_analise, 
                 mr_tela.num_pa,
                 ma_tela[w_i].metodo,
                 ma_tela[w_i].val_analise)                
         WHENEVER ERROR STOP
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE
            CALL log003_err_sql("INCLUSAO","ANALISE_PETROM")
            CALL log085_transacao("ROLLBACK")
            EXIT FOR
         END IF
      END IF
   END FOR

   IF p_houve_erro = FALSE THEN
      CALL pol0315_gra_validade()
   END IF
   
   IF p_houve_erro = FALSE THEN
      MESSAGE "Inclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      CALL log085_transacao("COMMIT")
      LET p_ies_cons = FALSE
   ELSE
      CALL log085_transacao("ROLLBACK")
      CLEAR FORM
   END IF    
               
END FUNCTION

#------------------------------#
FUNCTION pol0315_gra_validade()
#------------------------------#

   IF p_qtd_dia_validade  = 0   AND
      p_ies_indeterminada = 'N' THEN
      RETURN
   END IF
   
   SELECT dat_fabricacao
     FROM validade_lote_455
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND num_lote    = mr_tela.lote_tanque
      
   IF STATUS = 100 THEN
      INSERT INTO validade_lote_455
        VALUES(p_cod_empresa, 
               mr_tela.cod_item,
               mr_tela.lote_tanque,
               mr_tela.dat_fabricacao)
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','validade_lote_455')
         LET p_houve_erro = TRUE
      END IF
   ELSE
      IF STATUS = 0 THEN
         UPDATE validade_lote_455
            SET dat_fabricacao = mr_tela.dat_fabricacao
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = mr_tela.cod_item
            AND num_lote    = mr_tela.lote_tanque
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizando','validade_lote_455')
            LET p_houve_erro = TRUE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','validade_lote_455:2')
         LET p_houve_erro = TRUE
      END IF
   END IF          
   
END FUNCTION

#-----------------------#
 FUNCTION pol0315_popup()
#-----------------------#
   CASE
      WHEN infield(cod_item)
         CALL log009_popup(9,13,"ITEM PETROM","item_petrom","cod_item_petrom",
                                "den_item_petrom","POL0337","S","")
            RETURNING mr_tela.cod_item

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0315
         IF mr_tela.cod_item IS NOT NULL THEN
            DISPLAY mr_tela.cod_item TO cod_item
            CALL pol0315_verifica_item() RETURNING p_status
         END IF
            
   END CASE
 
END FUNCTION

#--------------------------------#
 FUNCTION pol0315_consulta_itens()
#--------------------------------#
   DEFINE l_ind          SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0315
   INITIALIZE ma_tela TO NULL
   CLEAR FORM

   SELECT dat_fabricacao
     INTO mr_tela.dat_fabricacao
     FROM validade_lote_455
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND num_lote    = mr_tela.lote_tanque

   IF STATUS <> 0 THEN
      LET mr_tela.dat_fabricacao = NULL
   END IF
   
   LET l_ind = 1

   IF mr_tela.num_pa IS NOT NULL THEN
 
    DECLARE c_item CURSOR WITH HOLD FOR
    SELECT tip_analise,
          metodo, 
          val_analise
     FROM analise_petrom 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND dat_analise = mr_tela.dat_analise
      AND num_pa = mr_tela.num_pa
      AND lote_tanque = mr_tela.lote_tanque
    ORDER BY tip_analise 
   
   ELSE
   
    DECLARE c_item CURSOR WITH HOLD FOR
    SELECT tip_analise,
          metodo, 
          val_analise
     FROM analise_petrom 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND dat_analise = mr_tela.dat_analise
      AND num_pa IS NULL
      AND lote_tanque = mr_tela.lote_tanque
    ORDER BY tip_analise 
   
   END IF
   
   FOREACH c_item INTO ma_tela[l_ind].tip_analise,
                       ma_tela[l_ind].metodo,   
                       ma_tela[l_ind].val_analise     

      SELECT den_analise
        INTO ma_tela[l_ind].den_analise
        FROM it_analise_petrom
       WHERE cod_empresa = p_cod_empresa
         AND tip_analise = ma_tela[l_ind].tip_analise

      LET l_ind = l_ind + 1

   END FOREACH 

   IF l_ind = 1 THEN
      CALL log0030_mensagem('Não foi possivel ler os resultados das analises', 'info')
      RETURN FALSE
   END IF
 
   DISPLAY BY NAME mr_tela.*
   DISPLAY p_cod_empresa TO cod_empresa
   CALL pol0315_verifica_item() RETURNING p_status

   LET l_ind = l_ind - 1
  
   CALL SET_COUNT(l_ind)

   IF l_ind > 7 THEN
      DISPLAY ARRAY ma_tela TO s_itens.*
      END DISPLAY 
   ELSE
       INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*
          BEFORE INPUT
             EXIT INPUT
       END INPUT    
   END IF
   
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Consulta Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE
      LET p_ies_cons = TRUE  
      RETURN TRUE 
   END IF

END FUNCTION   

#--------------------------#
 FUNCTION pol0315_consulta()
#--------------------------#
   DEFINE where_clause CHAR(300)  
   
   CLEAR FORM
   LET INT_FLAG = FALSE
   DISPLAY p_cod_empresa TO cod_empresa
 
   CONSTRUCT BY NAME where_clause ON analise_petrom.cod_item,
                                     analise_petrom.lote_tanque,
                                     analise_petrom.dat_analise,
                                     analise_petrom.num_pa 
                                     
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0315
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Consulta Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET sql_stmt = " SELECT UNIQUE cod_item, lote_tanque, dat_analise, ", 
                  " hor_analise, num_pa FROM analise_petrom ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  " AND ", where_clause CLIPPED,                 
                  " ORDER BY 1, 2, 3, 4 "

   PREPARE var_query1 FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query1
   OPEN cq_padrao
   FETCH cq_padrao 
         INTO mr_tela.cod_item,
              mr_tela.lote_tanque,
              mr_tela.dat_analise,
              mr_tela.hor_analise,
              mr_tela.num_pa
              
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      CLEAR FORM 
      LET p_ies_cons = FALSE
      RETURN FALSE  
   ELSE 
      IF pol0315_consulta_itens() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE  
      END IF
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0315_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_telat.* = mr_tela.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
              mr_tela.cod_item,
              mr_tela.lote_tanque,
              mr_tela.dat_analise,
              mr_tela.hor_analise,
              mr_tela.num_pa
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
              mr_tela.cod_item,
              mr_tela.lote_tanque,
              mr_tela.dat_analise,
              mr_tela.hor_analise,
              mr_tela.num_pa
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não existem mais itens nesta Direção"
            LET mr_tela.* = mr_telat.* 
            EXIT WHILE
         END IF
          
         IF pol0315_consulta_itens() THEN
            LET p_ies_cons = TRUE
            EXIT WHILE
         ELSE
            CLEAR FORM
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 

#-----------------------------#
 FUNCTION pol0315_modificacao()
#-----------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0315

   LET p_houve_erro = FALSE
   LET INT_FLAG = FALSE

   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   IF pol0315_entrada_item("MODIFICACAO") THEN
      DELETE FROM analise_petrom 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND dat_analise = mr_tela.dat_analise
         AND lote_tanque = mr_tela.lote_tanque
         AND num_pa = mr_tela.num_pa
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK 
         CALL log003_err_sql("EXCLUSAO","ANALISE_PETROM")
         RETURN
      END IF
      FOR w_i = 1 TO 50
         IF ma_tela[w_i].tip_analise IS NOT NULL AND
            ma_tela[w_i].val_analise IS NOT NULL THEN 
            INSERT INTO analise_petrom 
            VALUES (p_cod_empresa,
                    mr_tela.cod_item,        
                    mr_tela.dat_analise,
                    mr_tela.hor_analise, 
                    mr_tela.lote_tanque,
                    ma_tela[w_i].tip_analise, 
                    mr_tela.num_pa,
                    ma_tela[w_i].metodo,
                    ma_tela[w_i].val_analise)                
            IF SQLCA.SQLCODE <> 0 THEN 
               LET p_houve_erro = TRUE
               CALL log003_err_sql("INCLUSAO","ANALISE_PETROM")
               EXIT FOR
            END IF
         END IF
      END FOR
   ELSE
      LET p_houve_erro = TRUE 
   END IF	
 
   IF p_houve_erro THEN
      CALL log085_transacao("ROLLBACK")
   #  ROLLBACK WORK 
      MESSAGE "Modificação Cancelada." ATTRIBUTE(REVERSE)
   ELSE
      CALL log085_transacao("COMMIT")
   #  COMMIT WORK 
      MESSAGE "Modificação Efetuada com Sucesso" ATTRIBUTE(REVERSE)
   END IF

END FUNCTION   

#--------------------------#
 FUNCTION pol0315_exclusao()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0315
   LET p_houve_erro = FALSE
 
   IF log004_confirm(21,45) THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK                   
      DELETE FROM analise_petrom 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND dat_analise = mr_tela.dat_analise
         AND hor_analise = mr_tela.hor_analise
         AND lote_tanque = mr_tela.lote_tanque
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_houve_erro = TRUE 
         CALL log003_err_sql("EXCLUSAO","ANALISE_PETROM")
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN
      END IF

      CALL log085_transacao("COMMIT")
   #  COMMIT WORK
      MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      INITIALIZE mr_tela.* TO NULL
      CLEAR FORM
   END IF
 
END FUNCTION   
#-----------------------#
 FUNCTION pol0315_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
   
END FUNCTION   
                  