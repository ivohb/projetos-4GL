#-------------------------------------------------------------------#
# SISTEMA.: EMISSOR DE LAUDOS                                       #
# PROGRAMA: pol0492                                                 #
# MODULOS.: pol0492 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: CADASTRAR PARÂMETROS PARA IMPRESSÃO DO LAUDO            #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 10/02/2005                                              #
# ALTERADO: 04/01/2007 POR ANA PAULA - VERSAO 01                    #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,  
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_houve_erro    SMALLINT,
          p_ind           SMALLINT,
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
          p_msg           CHAR(500)

   DEFINE mr_par_laudo_comil RECORD LIKE par_laudo_comil.*

END GLOBALS
   
   DEFINE w_i             SMALLINT

   DEFINE mr_tela RECORD 
      cod_item         LIKE par_laudo_comil.cod_item,
      cod_cliente      LIKE par_laudo_comil.cod_cliente, 
      granulometria    LIKE par_laudo_comil.granulometria,
      texto            LIKE par_laudo_comil.texto
   END RECORD 

   DEFINE mr_telat RECORD 
      cod_item         LIKE par_laudo_comil.cod_item,
      cod_cliente      LIKE par_laudo_comil.cod_cliente, 
      granulometria    LIKE par_laudo_comil.granulometria,
      texto            LIKE par_laudo_comil.texto
   END RECORD 
   
   DEFINE ma_tela ARRAY[50] OF RECORD 
      tip_analise      LIKE analise_comil.tip_analise,
      den_analise      LIKE it_analise_comil.den_analise
   END RECORD 

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
	 LET p_versao = "pol0492-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0492.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0492_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0492_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0492") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0492 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0492","IN") THEN
            IF pol0492_inclusao("INCLUSAO") THEN
               IF pol0492_entrada_item("INCLUSAO") THEN
                  CALL pol0492_grava_dados()
               END IF
            END IF
         END IF
      
      COMMAND KEY("C") "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0492","CO") THEN
            IF pol0492_consulta() THEN
               IF p_ies_cons = TRUE THEN
                  NEXT OPTION "Seguinte"
               END IF
            END IF
         END IF  
     
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         CALL pol0492_paginacao("SEGUINTE")
     
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         CALL pol0492_paginacao("ANTERIOR") 
     
      COMMAND "Modificar" "Modifica dados da Tabela"
         HELP 002
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0492","MO") THEN
               CALL pol0492_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
     
      COMMAND "Excluir" "Exclui dados da Tabela"
         HELP 003
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0492","EX") THEN
               CALL pol0492_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0492","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0492_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0492.tmp'
                     START REPORT pol0492_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0492_relat TO p_nom_arquivo
               END IF
               CALL pol0492_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0492_relat   
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
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol0492_sobre()
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
   CLOSE WINDOW w_pol0492

END FUNCTION
 
#----------------------------------#
 FUNCTION pol0492_inclusao(l_funcao)
#----------------------------------#
   DEFINE l_funcao          CHAR(15)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0492
   IF l_funcao = "INCLUSAO" THEN
      INITIALIZE mr_tela.* TO NULL
      INITIALIZE ma_tela   TO NULL
      CLEAR FORM
      LET mr_tela.granulometria   = 'N' 
   END IF
   
   LET p_houve_erro = FALSE
   LET INT_FLAG =  FALSE
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME mr_tela.*  WITHOUT DEFAULTS  

     BEFORE FIELD cod_item
        IF l_funcao = "MODIFICACAO" THEN
           NEXT FIELD granulometria
        END IF
  
     AFTER FIELD cod_item 
        IF mr_tela.cod_item IS NULL THEN
           ERROR "Campo de preenchimento obrigatório."
           NEXT FIELD cod_item       
        ELSE
           IF pol0492_verifica_item() = FALSE THEN
              ERROR 'Item não cadastrado.'
              NEXT FIELD cod_item
           END IF   
        END IF

     BEFORE FIELD cod_cliente
        IF l_funcao = "MODIFICACAO" THEN
           NEXT FIELD granulometria
        END IF 
 
     AFTER FIELD cod_cliente 
        IF mr_tela.cod_cliente IS NOT NULL AND
           mr_tela.cod_cliente <> ' ' THEN
           IF pol0492_verifica_cliente() = FALSE THEN
              ERROR 'Cliente não cadastrado.'
              NEXT FIELD cod_cliente
           ELSE
              IF pol0492_verifica_duplicidade() THEN
                 ERROR 'Registro já cadastrado.'
                 NEXT FIELD cod_cliente
              ELSE
                 IF mr_tela.cod_cliente IS NOT NULL AND
                    mr_tela.cod_cliente <> ' ' THEN
                    IF pol0492_verifica_padrao_cliente() = FALSE THEN
                       ERROR 'Item não cadastrado nas especificações padrão.'
                       NEXT FIELD cod_item
                    END IF
                 END IF
              END IF     
           END IF   
        ELSE 
           IF pol0492_verifica_duplicidade() THEN
              ERROR 'Registro já cadastrado.'
              NEXT FIELD cod_cliente
           END IF
        END IF
     
     AFTER FIELD granulometria
        IF mr_tela.granulometria IS NULL OR
           mr_tela.granulometria = ' ' THEN
           ERROR "Campo com preenchimento obrigatório."
           NEXT FIELD granulometria
        ELSE
           IF mr_tela.granulometria <> 'S' AND
              mr_tela.granulometria <> 'N' THEN
              ERROR 'Valor inválido.'
              NEXT FIELD granulometria
           END IF
        END IF
        
       ON KEY (control-z)
          CALL pol0492_popup()
 
    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0492
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0492_verifica_item()
#-------------------------------#
   DEFINE l_den_item         LIKE item.den_item

   SELECT den_item
     INTO l_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item to den_item
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION           

#----------------------------------#
 FUNCTION pol0492_verifica_cliente()
#----------------------------------#
   DEFINE l_nom_cliente LIKE clientes.nom_cliente

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
 FUNCTION pol0492_verifica_duplicidade()
#--------------------------------------#
   IF mr_tela.cod_cliente IS NULL OR
      mr_tela.cod_cliente = ' ' THEN
      WHENEVER ERROR CONTINUE
        SELECT cod_empresa
          FROM par_laudo_comil
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item     = mr_tela.cod_item
           AND cod_cliente IS NULL 
      WHENEVER ERROR STOP
   ELSE
      WHENEVER ERROR CONTINUE
        SELECT cod_empresa
          FROM par_laudo_comil
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
 FUNCTION pol0492_verifica_padrao_cliente()
#-----------------------------------------#

    WHENEVER ERROR CONTINUE
    SELECT *
      FROM par_laudo_comil
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
 FUNCTION pol0492_entrada_item(p_funcao) 
#--------------------------------------#
   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0492

   LET INT_FLAG =  FALSE
 
   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*
   
      BEFORE FIELD tip_analise 
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()
 
      AFTER FIELD tip_analise
         IF ma_tela[pa_curr].tip_analise IS NOT NULL THEN
            IF pol0492_verifica_tip_analise() = FALSE THEN
               ERROR 'Tipo de análise não cadastrado.'
               NEXT FIELD tip_analise
            END IF
            IF pol0492_repetiu_codigo() THEN
               ERROR "Análise já associada !!!"
               NEXT FIELD tip_analise
            END IF
         END IF 
 
      ON KEY (control-z)
         CALL pol0492_popup()
 
   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0492
   
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

#-------------------------------#
FUNCTION pol0492_repetiu_codigo()
#-------------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = pa_curr THEN
          CONTINUE FOR
       END IF
       IF ma_tela[p_ind].tip_analise = ma_tela[pa_curr].tip_analise THEN
          RETURN TRUE
       END IF
   END FOR
   RETURN FALSE

END FUNCTION

#--------------------------------------#
 FUNCTION pol0492_verifica_tip_analise()
#--------------------------------------#

   SELECT a.den_analise
     INTO ma_tela[pa_curr].den_analise
     FROM it_analise_comil a, 
          especific_comil b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.tip_analise = ma_tela[pa_curr].tip_analise
      AND b.cod_empresa = a.cod_empresa
      AND b.tip_analise = a.tip_analise
      AND b.cod_item    = mr_tela.cod_item

   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   ELSE
      DISPLAY ma_tela[pa_curr].den_analise TO s_itens[sc_curr].den_analise  
      RETURN TRUE
   END IF 

END FUNCTION

#-----------------------------#
 FUNCTION pol0492_grava_dados()
#-----------------------------#
   LET p_houve_erro = FALSE
   CALL log085_transacao("BEGIN")
#  BEGIN WORK

   FOR w_i = 1 TO 50
      IF ma_tela[w_i].tip_analise IS NOT NULL THEN
         IF mr_tela.cod_cliente IS NOT NULL AND
            mr_tela.cod_cliente <> ' ' THEN 
            SELECT * 
              FROM par_laudo_comil
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = mr_tela.cod_item
               AND cod_cliente = mr_tela.cod_cliente
               AND tip_analise = ma_tela[w_i].tip_analise
         ELSE 
            SELECT * 
              FROM par_laudo_comil
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = mr_tela.cod_item
               AND cod_cliente IS NULL 
               AND tip_analise = ma_tela[w_i].tip_analise
         END IF
         IF sqlca.sqlcode = 100 THEN {nao encontrado}
            WHENEVER ERROR CONTINUE
            INSERT INTO par_laudo_comil 
            VALUES (p_cod_empresa,
                    mr_tela.cod_item,        
                    mr_tela.cod_cliente,
                    ma_tela[w_i].tip_analise,                
                    mr_tela.granulometria,
                    mr_tela.texto)
            WHENEVER ERROR STOP
            IF SQLCA.SQLCODE <> 0 THEN 
               LET p_houve_erro = TRUE
               CALL log003_err_sql("INCLUSAO","par_laudo_comil")
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
 FUNCTION pol0492_popup()
#-----------------------#
   CASE
      WHEN INFIELD(cod_cliente)
         CALL vdp372_popup_cliente() RETURNING mr_tela.cod_cliente

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0492
         DISPLAY mr_tela.cod_cliente TO cod_cliente
         CALL pol0492_verifica_cliente() RETURNING p_status
                  
      WHEN infield(cod_item)
         LET mr_tela.cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0492
         DISPLAY mr_tela.cod_item  TO cod_item

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0492
         DISPLAY mr_tela.cod_item TO cod_item
         CALL pol0492_verifica_item() RETURNING p_status
   
      WHEN INFIELD(tip_analise)
          CALL pol0492_popup_tip_analise() 
              RETURNING ma_tela[pa_curr].tip_analise
          CALL log006_exibe_teclas("01 02 03 07", p_versao)
          CURRENT WINDOW IS w_pol0492
          DISPLAY ma_tela[pa_curr].tip_analise TO 
                  s_itens[sc_curr].tip_analise
          CALL pol0492_verifica_tip_analise() RETURNING p_status           
   END CASE
 
END FUNCTION

#-----------------------------------#
 FUNCTION pol0492_popup_tip_analise()
#-----------------------------------#

   DEFINE l_ind             SMALLINT
 
   DEFINE la_tela ARRAY[50] OF RECORD
      tip_analise           LIKE it_analise_comil.tip_analise,
      den_analise           LIKE it_analise_comil.den_analise
   END RECORD

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04921") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04921 AT 4,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)           

   LET l_ind = 1

   DECLARE cq_popup CURSOR FOR
    SELECT a.tip_analise, 
           b.den_analise
      FROM it_analise_comil b, 
           especific_comil a 
     WHERE a.cod_empresa = b.cod_empresa
       AND a.tip_analise = b.tip_analise
       AND a.cod_empresa = p_cod_empresa
       AND a.cod_item    = mr_tela.cod_item

   FOREACH cq_popup INTO 
           la_tela[l_ind].tip_analise,
           la_tela[l_ind].den_analise

      LET l_ind = l_ind + 1

   END FOREACH
 
   LET l_ind = l_ind - 1

   CALL SET_COUNT(l_ind) 
   DISPLAY ARRAY la_tela TO s_pa.*
  
   LET l_ind = ARR_CURR()
  
   IF INT_FLAG = 0 THEN
      CLOSE WINDOW w_pol04921
      CURRENT WINDOW IS w_pol0492
      RETURN la_tela[l_ind].tip_analise
   ELSE
      CLOSE WINDOW w_pol04921
      CURRENT WINDOW IS w_pol0492
      RETURN " "
   END IF

END FUNCTION                                           

#--------------------------------#
 FUNCTION pol0492_consulta_itens()
#--------------------------------#
   DEFINE l_ind          SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0492
   INITIALIZE ma_tela TO NULL
   CLEAR FORM
   LET INT_FLAG = 0

   LET l_ind = 1
   IF mr_tela.cod_cliente IS NOT NULL AND
      mr_tela.cod_cliente <> ' ' THEN 
      DECLARE c_item CURSOR FOR
       SELECT tip_analise
         FROM par_laudo_comil 
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = mr_tela.cod_item
          AND cod_cliente = mr_tela.cod_cliente
        ORDER BY tip_analise 

      FOREACH c_item INTO ma_tela[l_ind].tip_analise

         SELECT den_analise
           INTO ma_tela[l_ind].den_analise
           FROM it_analise_comil
          WHERE cod_empresa = p_cod_empresa
            AND tip_analise = ma_tela[l_ind].tip_analise

         LET l_ind = l_ind + 1

      END FOREACH 
   ELSE
      DECLARE c_item_2 CURSOR FOR
       SELECT tip_analise
         FROM par_laudo_comil
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = mr_tela.cod_item
          AND cod_cliente IS NULL
        ORDER BY tip_analise

      FOREACH c_item_2 INTO ma_tela[l_ind].tip_analise

         SELECT den_analise
           INTO ma_tela[l_ind].den_analise
           FROM it_analise_comil
          WHERE cod_empresa = p_cod_empresa
            AND tip_analise = ma_tela[l_ind].tip_analise

         LET l_ind = l_ind + 1

      END FOREACH          

   END IF
   IF l_ind = 1 THEN
      RETURN FALSE
   END IF
 
   DISPLAY BY NAME mr_tela.*
   DISPLAY p_cod_empresa TO cod_empresa
   CALL pol0492_verifica_item() RETURNING p_status
   CALL pol0492_verifica_cliente() RETURNING p_status
 
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
 FUNCTION pol0492_consulta()
#--------------------------#
   DEFINE where_clause CHAR(300)  
   
   CLEAR FORM
   LET INT_FLAG = FALSE
   DISPLAY p_cod_empresa TO cod_empresa
 
   CONSTRUCT BY NAME where_clause ON par_laudo_comil.cod_item,
                                     par_laudo_comil.cod_cliente,
                                     par_laudo_comil.granulometria,
                                     par_laudo_comil.texto
                                     
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0492
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Consulta Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET sql_stmt = " SELECT UNIQUE cod_item, cod_cliente, ",  
                  " granulometria, ",
                  " texto FROM par_laudo_comil ",
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
      IF pol0492_consulta_itens() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE  
      ELSE
         RETURN FALSE  
      END IF
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0492_paginacao(p_funcao)
#-----------------------------------#
   DEFINE p_funcao CHAR(20)

   #IF p_ies_cons THEN
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
          
         IF pol0492_consulta_itens() THEN
            LET p_ies_cons = TRUE
            EXIT WHILE
         ELSE
            CLEAR FORM
         END IF
      END WHILE
   #ELSE
   #   ERROR "Não Existe Nenhuma Consulta Ativa"
   #END IF

END FUNCTION 

#-----------------------------#
 FUNCTION pol0492_modificacao()
#-----------------------------#
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0492

   LET p_houve_erro = FALSE
   LET INT_FLAG = FALSE

   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   IF pol0492_inclusao("MODIFICACAO") THEN
      IF pol0492_entrada_item("MODIFICACAO") THEN
         IF mr_tela.cod_cliente IS NOT NULL AND
            mr_tela.cod_cliente <> ' ' THEN
            DELETE FROM par_laudo_comil 
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = mr_tela.cod_item
               AND cod_cliente = mr_tela.cod_cliente
         ELSE
            DELETE FROM par_laudo_comil 
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = mr_tela.cod_item
               AND cod_cliente IS NULL 
         END IF 
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK 
            CALL log003_err_sql("EXCLUSAO","par_laudo_comil")
            RETURN
         END IF

         FOR w_i = 1 TO 50
            IF ma_tela[w_i].tip_analise IS NOT NULL THEN
               IF mr_tela.cod_cliente IS NOT NULL AND
                  mr_tela.cod_cliente <> ' ' THEN
                  SELECT * 
                    FROM par_laudo_comil
                   WHERE cod_empresa = p_cod_empresa
                     AND cod_item    = mr_tela.cod_item
                     AND cod_cliente = mr_tela.cod_cliente
                     AND tip_analise = ma_tela[w_i].tip_analise
               ELSE                 
                  SELECT * 
                    FROM par_laudo_comil
                   WHERE cod_empresa = p_cod_empresa
                     AND cod_item    = mr_tela.cod_item
                     AND cod_cliente IS NULL 
                     AND tip_analise = ma_tela[w_i].tip_analise
               END IF
               IF sqlca.sqlcode = 100 THEN  
                  WHENEVER ERROR CONTINUE
                  INSERT INTO par_laudo_comil 
                  VALUES (p_cod_empresa,
                          mr_tela.cod_item,        
                          mr_tela.cod_cliente,
                          ma_tela[w_i].tip_analise,                
                          mr_tela.granulometria,
                          mr_tela.texto)
                  WHENEVER ERROR STOP
                  IF SQLCA.SQLCODE <> 0 THEN 
                     LET p_houve_erro = TRUE
                     CALL log003_err_sql("INCLUSAO","par_laudo_comil")
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
 FUNCTION pol0492_exclusao()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0492
   LET p_houve_erro = FALSE
 
   IF log004_confirm(21,45) THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK                   
      IF mr_tela.cod_cliente = ' ' OR
         mr_tela.cod_cliente IS NULL THEN
         DELETE FROM par_laudo_comil 
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = mr_tela.cod_item
            AND cod_cliente IS NULL 
      ELSE   
         DELETE FROM par_laudo_comil 
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = mr_tela.cod_item
            AND cod_cliente = mr_tela.cod_cliente
      END IF    
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_houve_erro = TRUE 
         CALL log003_err_sql("EXCLUSAO","par_laudo_comil")
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

#-----------------------------------#
 FUNCTION pol0492_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_listar CURSOR FOR
    SELECT * 
      FROM par_laudo_comil
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_item, tip_analise

   FOREACH cq_listar INTO mr_par_laudo_comil.*
   

      OUTPUT TO REPORT pol0492_relat() 
 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#---------------------#
 REPORT pol0492_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 124, "PAG: ", PAGENO USING "#&"
         PRINT COLUMN 001, "pol0492",
               COLUMN 049, "RELAÇÃO PRODUTO X ANÁLISES",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
         PRINT COLUMN 001, "----------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "     ITEM           CLIENTE     ANALISE GR        TEXTO"
         PRINT COLUMN 001, "--------------- --------------- ------- -- ---------------------------------------------------------------------------------------"
                           
      ON EVERY ROW

         PRINT COLUMN 001, mr_par_laudo_comil.cod_item,
               COLUMN 017, mr_par_laudo_comil.cod_cliente,
               COLUMN 034, mr_par_laudo_comil.tip_analise USING '######',
               COLUMN 041, mr_par_laudo_comil.granulometria,
               COLUMN 044, mr_par_laudo_comil.texto
        
END REPORT


#-----------------------#
 FUNCTION pol0492_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
