#-------------------------------------------------------------------#
# SISTEMA.: EMISSOR DE LAUDOS                                       #
# PROGRAMA: POL1114                                                 #
# OBJETIVO: ANÁLISES POR ITEM (PARAMETEROS P/ IMPRESSAO DO LAUDO)   #
# DATA....: 03/11/2011                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,  
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_houve_erro    SMALLINT,
          comando         CHAR(80),
          p_versao        CHAR(18),
          p_ies_impressao CHAR(001),
          g_ies_ambiente  CHAR(001),
          p_nom_arquivo   CHAR(100),
          p_arquivo       CHAR(025),
          p_caminho       CHAR(080),
          p_nom_tela      CHAR(200),
          p_nom_help      CHAR(200),
          sql_stmt        CHAR(300),
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
          p_msg           CHAR(100)

END GLOBALS
   
   DEFINE w_i             SMALLINT

   DEFINE mr_tela RECORD 
      cod_item         LIKE par_laudo_915.cod_item,
      cod_cliente      LIKE par_laudo_915.cod_cliente, 
      pa_fora_especif  LIKE par_laudo_915.pa_fora_especif,
      tipo_venda       LIKE par_laudo_915.tipo_venda,
      bloqueia_laudo   LIKE par_laudo_915.bloqueia_laudo,
      texto            LIKE par_laudo_915.texto
   END RECORD 

   DEFINE mr_telat RECORD 
      cod_item         LIKE par_laudo_915.cod_item,
      cod_cliente      LIKE par_laudo_915.cod_cliente, 
      pa_fora_especif  LIKE par_laudo_915.pa_fora_especif,
      tipo_venda       LIKE par_laudo_915.tipo_venda,
      bloqueia_laudo   LIKE par_laudo_915.bloqueia_laudo,
      texto            LIKE par_laudo_915.texto
   END RECORD 
   
   DEFINE ma_tela ARRAY[50] OF RECORD 
      tip_analise      LIKE analise_915.tip_analise,
      den_analise_port      LIKE it_analise_915.den_analise_port
   END RECORD 

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL1114-10.02.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("POL1114.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL POL1114_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION POL1114_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL1114") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_POL1114 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","POL1114","IN") THEN
            IF POL1114_inclusao("INCLUSAO") THEN
               IF POL1114_entrada_item("INCLUSAO") THEN
                  CALL POL1114_grava_dados()
               END IF
            END IF
         END IF
      
      COMMAND KEY("C") "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","POL1114","CO") THEN
            IF POL1114_consulta() THEN
               IF p_ies_cons = TRUE THEN
                  NEXT OPTION "Seguinte"
               END IF
            END IF
         END IF  
     
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         CALL POL1114_paginacao("SEGUINTE")
     
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         CALL POL1114_paginacao("ANTERIOR") 
     
      COMMAND "Modificar" "Modifica dados da Tabela"
         HELP 002
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","POL1114","MO") THEN
               CALL POL1114_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
     
      COMMAND "Excluir" "Exclui dados da Tabela"
         HELP 003
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","POL1114","EX") THEN
               CALL POL1114_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL POL1114_sobre()
         
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
   CLOSE WINDOW w_POL1114

END FUNCTION
 
#----------------------------------#
 FUNCTION POL1114_inclusao(l_funcao)
#----------------------------------#
   DEFINE l_funcao          CHAR(15)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1114
   IF l_funcao = "INCLUSAO" THEN
      INITIALIZE mr_tela.* TO NULL
      INITIALIZE ma_tela TO NULL
      CLEAR FORM
      LET mr_tela.pa_fora_especif = 'N' 
      LET mr_tela.bloqueia_laudo  = 'N' 
   END IF
   
   LET p_houve_erro = FALSE
   LET INT_FLAG =  FALSE
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME 
      mr_tela.cod_item,
      mr_tela.cod_cliente,
      mr_tela.texto
   
     WITHOUT DEFAULTS  

     BEFORE FIELD cod_item
        IF l_funcao = "MODIFICACAO" THEN
           NEXT FIELD texto
        END IF
  
     AFTER FIELD cod_item 
        IF mr_tela.cod_item IS NULL THEN
           ERROR "Campo de preenchimento obrigatório."
           NEXT FIELD cod_item       
        ELSE
           IF POL1114_verifica_item() = FALSE THEN
              ERROR 'Item não cadastrado.'
              NEXT FIELD cod_item
           END IF   
        END IF

     BEFORE FIELD cod_cliente
        IF l_funcao = "MODIFICACAO" THEN
           NEXT FIELD texto
        END IF 
 
     AFTER FIELD cod_cliente 
        IF mr_tela.cod_cliente IS NOT NULL AND
           mr_tela.cod_cliente <> ' ' THEN
           IF POL1114_verifica_cliente() = FALSE THEN
              ERROR 'Cliente não cadastrado.'
              NEXT FIELD cod_cliente
           ELSE
              IF POL1114_verifica_duplicidade() THEN
                 ERROR 'Registro já cadastrado.'
                 NEXT FIELD cod_cliente
              ELSE
                 IF mr_tela.cod_cliente IS NOT NULL AND
                    mr_tela.cod_cliente <> ' ' THEN
                    IF POL1114_verifica_padrao_cliente() = FALSE THEN
                       ERROR 'Item não cadastrado nas especificações padrão.'
                       NEXT FIELD cod_item
                    END IF
                 END IF
              END IF     
           END IF   
        ELSE 
           DISPLAY '' TO nom_cliente
           IF POL1114_verifica_duplicidade() THEN
              ERROR 'Registro já cadastrado.'
              NEXT FIELD cod_cliente
           END IF
        END IF
     
       ON KEY (control-z)
          CALL POL1114_popup()
 
    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1114
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION POL1114_verifica_item()
#-------------------------------#
   DEFINE l_den_item         LIKE item.den_item

   SELECT den_item_portugues
     INTO l_den_item
     FROM item_915
    WHERE cod_empresa     = p_cod_empresa
      AND cod_item_analise = mr_tela.cod_item
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item to den_item
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION           

#----------------------------------#
 FUNCTION POL1114_verifica_cliente()
#----------------------------------#
   DEFINE l_nom_cliente          LIKE clientes.nom_cliente

   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_tela.cod_cliente

   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_nom_cliente TO nom_cliente
      RETURN TRUE
   ELSE
      DISPLAY l_nom_cliente TO nom_cliente
      RETURN FALSE
   END IF

END FUNCTION   

#--------------------------------------#
 FUNCTION POL1114_verifica_duplicidade()
#--------------------------------------#
   IF mr_tela.cod_cliente IS NULL OR
      mr_tela.cod_cliente = ' ' THEN
      WHENEVER ERROR CONTINUE
        SELECT cod_empresa
          FROM par_laudo_915
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item     = mr_tela.cod_item
           AND cod_cliente IS NULL 
      WHENEVER ERROR STOP
   ELSE
      WHENEVER ERROR CONTINUE
        SELECT cod_empresa
          FROM par_laudo_915
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item     = mr_tela.cod_item
           AND cod_cliente  = mr_tela.cod_cliente
      WHENEVER ERROR STOP
   END IF 
   IF sqlca.sqlcode = 0 OR
      sqlca.sqlcode = -284 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF      

END FUNCTION

#-----------------------------------------#
 FUNCTION POL1114_verifica_padrao_cliente()
#-----------------------------------------#

    WHENEVER ERROR CONTINUE
    SELECT *
      FROM par_laudo_915
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item     = mr_tela.cod_item
       AND cod_cliente IS NULL 
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 OR
       sqlca.sqlcode = -284 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF

END FUNCTION     
 
#--------------------------------------#
 FUNCTION POL1114_entrada_item(p_funcao) 
#--------------------------------------#
   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1114

   LET INT_FLAG =  FALSE
 
   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*
   
      BEFORE FIELD tip_analise 
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()
 
      AFTER FIELD tip_analise
         IF ma_tela[pa_curr].tip_analise IS NOT NULL THEN
            IF POL1114_verifica_tip_analise() = FALSE THEN
               ERROR 'Tipo de análise não cadastrado.'
               NEXT FIELD tip_analise
            END IF
			IF POL1114_valida_tip_analise() = FALSE THEN
               ERROR 'Tipo de análise não pertence a esse item.'
               NEXT FIELD tip_analise
            END IF
         END IF 
 
      ON KEY (control-z)
         CALL POL1114_popup()
 
   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1114
   
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

#--------------------------------------#
 FUNCTION POL1114_verifica_tip_analise()
#--------------------------------------#
   SELECT den_analise_port 
     INTO ma_tela[pa_curr].den_analise_port
     FROM it_analise_915
    WHERE cod_empresa = p_cod_empresa
      AND tip_analise = ma_tela[pa_curr].tip_analise
   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   ELSE
      DISPLAY ma_tela[pa_curr].den_analise_port TO s_itens[sc_curr].den_analise_port  
      RETURN TRUE
   END IF 

END FUNCTION
#--------------------------------------#
 FUNCTION POL1114_valida_tip_analise()
#--------------------------------------#
  DEFINE l_count   INTEGER
  
  LET l_count   = 0 

   SELECT count(*)
     INTO l_count
     FROM especific_915
    WHERE cod_empresa = p_cod_empresa
      AND tip_analise = ma_tela[pa_curr].tip_analise
	  AND cod_item=mr_tela.cod_item
      AND cod_cliente   IS NULL 
	  
   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   ELSE
      IF l_count > 0 THEN
	  ELSE
	  END IF 
   END IF 

END FUNCTION


#-----------------------------#
 FUNCTION POL1114_grava_dados()
#-----------------------------#
   LET p_houve_erro = FALSE
   CALL log085_transacao("BEGIN")
#  BEGIN WORK

   FOR w_i = 1 TO 50
      IF ma_tela[w_i].tip_analise IS NOT NULL THEN
         IF mr_tela.cod_cliente IS NOT NULL AND
            mr_tela.cod_cliente <> ' ' THEN 
            SELECT * 
              FROM par_laudo_915
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = mr_tela.cod_item
               AND cod_cliente = mr_tela.cod_cliente
               AND tip_analise = ma_tela[w_i].tip_analise
         ELSE 
            SELECT * 
              FROM par_laudo_915
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = mr_tela.cod_item
               AND cod_cliente IS NULL 
               AND tip_analise = ma_tela[w_i].tip_analise
         END IF
         IF sqlca.sqlcode = 100 THEN 
            WHENEVER ERROR CONTINUE
            INSERT INTO par_laudo_915 
            VALUES (p_cod_empresa,
                    mr_tela.cod_item,        
                    mr_tela.cod_cliente,
                    ma_tela[w_i].tip_analise,                
                    mr_tela.pa_fora_especif,
                    mr_tela.tipo_venda,
                    mr_tela.bloqueia_laudo,
                    mr_tela.texto)
            WHENEVER ERROR STOP
            IF SQLCA.SQLCODE <> 0 THEN 
               LET p_houve_erro = TRUE
               CALL log003_err_sql("INCLUSAO","PAR_LAUDO_915")
               EXIT FOR
            END IF
         END IF
      END IF
   END FOR

   IF p_houve_erro = FALSE THEN
      MESSAGE "Inclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      CALL log085_transacao("COMMIT")
   #  COMMIT WORK
      LET p_ies_cons = FALSE
   ELSE
      CALL log085_transacao("ROLLBACK")
   #  ROLLBACK WORK
      CLEAR FORM
   END IF    
               
END FUNCTION

#-----------------------#
 FUNCTION POL1114_popup()
#-----------------------#
   CASE
      WHEN INFIELD(cod_cliente)
         CALL vdp372_popup_cliente() RETURNING mr_tela.cod_cliente

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1114
         DISPLAY mr_tela.cod_cliente TO cod_cliente
         CALL POL1114_verifica_cliente() RETURNING p_status
                  
      WHEN infield(cod_item)
         CALL log009_popup(9,13,"ITEM PARA ANALISE","item_915","cod_item_analise",
                                "den_item_portugues","POL0337","S","")
            RETURNING mr_tela.cod_item

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1114
         DISPLAY mr_tela.cod_item TO cod_item
         CALL POL1114_verifica_item() RETURNING p_status
   
      WHEN INFIELD(tip_analise)
          CALL POL1114_popup_tip_analise() 
              RETURNING ma_tela[pa_curr].tip_analise
          CALL log006_exibe_teclas("01 02 03 07", p_versao)
          CURRENT WINDOW IS w_POL1114
          DISPLAY ma_tela[pa_curr].tip_analise TO 
                  s_itens[sc_curr].tip_analise
          CALL POL1114_verifica_tip_analise() RETURNING p_status           
   END CASE
 
END FUNCTION

#-----------------------------------#
 FUNCTION POL1114_popup_tip_analise()
#-----------------------------------#
   DEFINE l_ind             SMALLINT
 
   DEFINE la_tela ARRAY[50] OF RECORD
      tip_analise           LIKE it_analise_915.tip_analise,
      den_analise_port           LIKE it_analise_915.den_analise_port
                  END RECORD

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL11141") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_POL11141 AT 6,6 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)           

   LET l_ind = 1

   DECLARE cq_popup CURSOR FOR
    SELECT tip_analise, den_analise_port
      FROM it_analise_915
     WHERE cod_empresa = p_cod_empresa
	  AND  tip_analise in(select tip_analise from especific_915
                           where cod_empresa=p_cod_empresa
                           and    cod_item=mr_tela.cod_item)
     ORDER BY den_analise_port

   FOREACH cq_popup INTO la_tela[l_ind].tip_analise,
                         la_tela[l_ind].den_analise_port

      LET l_ind = l_ind + 1

   END FOREACH
 
   LET l_ind = l_ind - 1

   CALL SET_COUNT(l_ind) 
   DISPLAY ARRAY la_tela TO s_pa.*
  
   LET l_ind = ARR_CURR()
  
   IF INT_FLAG = 0 THEN
      CLOSE WINDOW w_POL11141
      CURRENT WINDOW IS w_POL1114
      RETURN la_tela[l_ind].tip_analise
   ELSE
      CLOSE WINDOW w_POL11141
      CURRENT WINDOW IS w_POL1114
      RETURN " "
   END IF

END FUNCTION                                           

#--------------------------------#
 FUNCTION POL1114_consulta_itens()
#--------------------------------#
   DEFINE l_ind          SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1114
   INITIALIZE ma_tela TO NULL
   CLEAR FORM
   LET INT_FLAG = 0

   LET l_ind = 1
   IF mr_tela.cod_cliente IS NOT NULL AND
      mr_tela.cod_cliente <> ' ' THEN 
      DECLARE c_item CURSOR FOR
       SELECT tip_analise
         FROM par_laudo_915 
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = mr_tela.cod_item
          AND cod_cliente = mr_tela.cod_cliente
        ORDER BY tip_analise 

      FOREACH c_item INTO ma_tela[l_ind].tip_analise

         SELECT den_analise_port
           INTO ma_tela[l_ind].den_analise_port
           FROM it_analise_915
          WHERE cod_empresa = p_cod_empresa
            AND tip_analise = ma_tela[l_ind].tip_analise

         LET l_ind = l_ind + 1

      END FOREACH 
   ELSE
      DECLARE c_item_2 CURSOR FOR
       SELECT tip_analise
         FROM par_laudo_915
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = mr_tela.cod_item
          AND cod_cliente IS NULL
        ORDER BY tip_analise

      FOREACH c_item_2 INTO ma_tela[l_ind].tip_analise

         SELECT den_analise_port
           INTO ma_tela[l_ind].den_analise_port
           FROM it_analise_915
          WHERE cod_empresa = p_cod_empresa
            AND tip_analise = ma_tela[l_ind].tip_analise

         LET l_ind = l_ind + 1

      END FOREACH          

   END IF
   IF l_ind = 1 THEN
      RETURN FALSE
   END IF
 
   DISPLAY BY NAME 
      mr_tela.cod_item,
      mr_tela.cod_cliente,
      mr_tela.texto

   
   DISPLAY p_cod_empresa TO cod_empresa
   CALL POL1114_verifica_item() RETURNING p_status
   CALL POL1114_verifica_cliente() RETURNING p_status
 
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
 FUNCTION POL1114_consulta()
#--------------------------#
   DEFINE where_clause CHAR(300)  
   
   CLEAR FORM
   LET INT_FLAG = FALSE
   DISPLAY p_cod_empresa TO cod_empresa
 
   CONSTRUCT BY NAME where_clause ON par_laudo_915.cod_item,
                                     par_laudo_915.cod_cliente
                                     
	
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1114
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Consulta Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET sql_stmt = " SELECT UNIQUE cod_item, cod_cliente, ",  
                  " pa_fora_especif, tipo_venda, ", 
                  " bloqueia_laudo, texto FROM par_laudo_915 ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  " AND ", where_clause CLIPPED,                 
                  " ORDER BY 1, 2 "

   PREPARE var_query1 FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query1
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_tela.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      CLEAR FORM 
      LET p_ies_cons = FALSE
      RETURN FALSE  
   ELSE 
      IF POL1114_consulta_itens() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE  
      ELSE
         RETURN FALSE  
      END IF
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION POL1114_paginacao(p_funcao)
#-----------------------------------#
   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_telat.* = mr_tela.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO mr_tela.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO mr_tela.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não existem mais itens nesta Direção"
            LET mr_tela.* = mr_telat.* 
            EXIT WHILE
         END IF
          
         IF POL1114_consulta_itens() THEN
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
 FUNCTION POL1114_modificacao()
#-----------------------------#
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_POL1114

   LET p_houve_erro = FALSE
   LET INT_FLAG = FALSE

   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   IF POL1114_inclusao("MODIFICACAO") THEN
      IF POL1114_entrada_item("MODIFICACAO") THEN
         IF mr_tela.cod_cliente IS NOT NULL AND
            mr_tela.cod_cliente <> ' ' THEN
            DELETE FROM par_laudo_915 
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = mr_tela.cod_item
               AND cod_cliente = mr_tela.cod_cliente
         ELSE
            DELETE FROM par_laudo_915 
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = mr_tela.cod_item
               AND cod_cliente IS NULL 
         END IF 
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK 
            CALL log003_err_sql("EXCLUSAO","PAR_LAUDO_915")
            RETURN
         END IF

         FOR w_i = 1 TO 50
            IF ma_tela[w_i].tip_analise IS NOT NULL THEN
               IF mr_tela.cod_cliente IS NOT NULL AND
                  mr_tela.cod_cliente <> ' ' THEN
                  SELECT * 
                    FROM par_laudo_915
                   WHERE cod_empresa = p_cod_empresa
                     AND cod_item    = mr_tela.cod_item
                     AND cod_cliente = mr_tela.cod_cliente
                     AND tip_analise = ma_tela[w_i].tip_analise
               ELSE                 
                  SELECT * 
                    FROM par_laudo_915
                   WHERE cod_empresa = p_cod_empresa
                     AND cod_item    = mr_tela.cod_item
                     AND cod_cliente IS NULL 
                     AND tip_analise = ma_tela[w_i].tip_analise
               END IF
               IF sqlca.sqlcode = 100 THEN  
                  WHENEVER ERROR CONTINUE
                  INSERT INTO par_laudo_915 
                  VALUES (p_cod_empresa,
                          mr_tela.cod_item,        
                          mr_tela.cod_cliente,
                          ma_tela[w_i].tip_analise,                
                          mr_tela.pa_fora_especif,
                          mr_tela.tipo_venda,
                          mr_tela.bloqueia_laudo,
                          mr_tela.texto)
                  WHENEVER ERROR STOP
                  IF SQLCA.SQLCODE <> 0 THEN 
                     LET p_houve_erro = TRUE
                     CALL log003_err_sql("INCLUSAO","PAR_LAUDO_915")
                     EXIT FOR
                  END IF
               END IF 
            END IF
         END FOR
      END IF
   END IF	
 
   IF p_houve_erro THEN
      CALL log085_transacao("ROLLBACK")
   #  ROLLBACK WORK 
      RETURN
   ELSE
      CALL log085_transacao("COMMIT")
   #  COMMIT WORK 
      MESSAGE "Modificação Efetuada com Sucesso" ATTRIBUTE(REVERSE)
   END IF

END FUNCTION   

#--------------------------#
 FUNCTION POL1114_exclusao()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1114
   LET p_houve_erro = FALSE
 
   IF log004_confirm(21,45) THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK                   
      IF mr_tela.cod_cliente = ' ' OR
         mr_tela.cod_cliente IS NULL THEN
         DELETE FROM par_laudo_915 
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = mr_tela.cod_item
            AND cod_cliente IS NULL 
      ELSE   
         DELETE FROM par_laudo_915 
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = mr_tela.cod_item
            AND cod_cliente = mr_tela.cod_cliente
      END IF    
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_houve_erro = TRUE 
         CALL log003_err_sql("EXCLUSAO","PAR_LAUDO_915")
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN
      END IF

      CALL log085_transacao("COMMIT")
   #  COMMIT WORK
      MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      INITIALIZE mr_tela.* TO NULL
      INITIALIZE ma_tela TO NULL
      CLEAR FORM
   END IF
 
END FUNCTION   

#-----------------------#
 FUNCTION POL1114_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION