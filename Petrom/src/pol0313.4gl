#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0313                                                 #
# MODULOS.: POL0313 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA ESPECIFIC_PETROM                   #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 05/02/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa  LIKE empresa.cod_empresa,
          p_den_empresa  LIKE empresa.den_empresa,  
          p_user         LIKE usuario.nom_usuario,
          p_status       SMALLINT,
          p_houve_erro   SMALLINT,
          comando        CHAR(80),
          p_versao       CHAR(18),
          p_nom_tela     CHAR(080),
          p_nom_help     CHAR(200),
          p_ies_cons     SMALLINT,
          p_last_row     SMALLINT,
          p_msg          CHAR(100)

END GLOBALS

    DEFINE mr_especific_petrom  RECORD 
           cod_empresa          LIKE empresa.cod_empresa,
           cod_item             LIKE item.cod_item,
           cod_cliente          LIKE clientes.cod_cliente,
           tip_analise          LIKE especific_petrom.tip_analise,
           metodo               LIKE especific_petrom.metodo,
           qtd_casas_dec        LIKE especific_petrom.qtd_casas_dec,
           unidade              LIKE especific_petrom.unidade,
           val_especif_de       LIKE especific_petrom.val_especif_de,
           val_especif_ate      LIKE especific_petrom.val_especif_ate,
           variacao             LIKE especific_petrom.variacao,
           tipo_valor           LIKE especific_petrom.tipo_valor,
           calcula_media        LIKE especific_petrom.calcula_media,
           ies_tanque           LIKE especific_petrom.ies_tanque,
           ies_texto            LIKE especific_petrom.ies_texto,
           texto_especific      LIKE especific_petrom.texto_especific 
           END RECORD 
   
    DEFINE mr_especific_petromr  RECORD
           cod_empresa           LIKE empresa.cod_empresa,
           cod_item              LIKE item.cod_item,
           cod_cliente           LIKE clientes.cod_cliente,
           tip_analise           LIKE especific_petrom.tip_analise,
           metodo                LIKE especific_petrom.metodo,
           qtd_casas_dec         LIKE especific_petrom.qtd_casas_dec,
           unidade               LIKE especific_petrom.unidade,
           val_especif_de        LIKE especific_petrom.val_especif_de,
           val_especif_ate       LIKE especific_petrom.val_especif_ate,
           variacao              LIKE especific_petrom.variacao,
           tipo_valor            LIKE especific_petrom.tipo_valor,
           calcula_media         LIKE especific_petrom.calcula_media,
           ies_tanque            LIKE especific_petrom.ies_tanque,
           ies_texto             LIKE especific_petrom.ies_texto,
           texto_especif         LIKE especific_petrom.texto_especific 
           END RECORD 

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0313-10.02.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0313.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0313_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0313_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0313") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0313 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0313","IN") THEN
            CALL pol0313_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_especific_petrom.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol0313","MO") THEN
               CALL pol0313_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_especific_petrom.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol0313","EX") THEN
               CALL pol0313_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0313","CO") THEN
            CALL pol0313_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0313_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0313_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0313_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0313

END FUNCTION

#--------------------------#
 FUNCTION pol0313_inclusao()
#--------------------------#

   INITIALIZE mr_especific_petrom.* TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM
   IF pol0313_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      LET mr_especific_petrom.cod_empresa = p_cod_empresa
      WHENEVER ERROR CONTINUE
      INSERT INTO especific_petrom VALUES (mr_especific_petrom.cod_empresa,
                                           mr_especific_petrom.cod_item,
                                           mr_especific_petrom.cod_cliente,
                                           mr_especific_petrom.tip_analise,
                                           mr_especific_petrom.metodo,
                                           mr_especific_petrom.unidade,
                                           mr_especific_petrom.val_especif_de,
                                           mr_especific_petrom.val_especif_ate,
                                           mr_especific_petrom.variacao,
                                           mr_especific_petrom.tipo_valor,
                                           mr_especific_petrom.calcula_media,
                                           mr_especific_petrom.ies_tanque,
                                           mr_especific_petrom.qtd_casas_dec,
                                           mr_especific_petrom.ies_texto,
                                           mr_especific_petrom.texto_especific)
      WHENEVER ERROR STOP 
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","ESPECIFIC_PETROM")       
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
   ELSE
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0313_entrada_dados(p_funcao)
#---------------------------------------#
   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0313
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE mr_especific_petrom.* TO NULL
      LET mr_especific_petrom.ies_tanque    = 'N'
      LET mr_especific_petrom.ies_texto     = 'N'
      LET mr_especific_petrom.calcula_media = 'S'
   END IF

   LET mr_especific_petrom.cod_empresa = p_cod_empresa
   DISPLAY BY NAME mr_especific_petrom.cod_empresa
   
   INPUT BY NAME mr_especific_petrom.cod_empresa, 
                 mr_especific_petrom.cod_item,
                 mr_especific_petrom.cod_cliente,
                 mr_especific_petrom.tip_analise,
                 mr_especific_petrom.metodo,
                 mr_especific_petrom.qtd_casas_dec,
                 mr_especific_petrom.unidade,
                 mr_especific_petrom.val_especif_de,
                 mr_especific_petrom.val_especif_ate,
                 mr_especific_petrom.variacao,
                 mr_especific_petrom.tipo_valor,
                 mr_especific_petrom.calcula_media,
                 mr_especific_petrom.ies_tanque,
                 mr_especific_petrom.ies_texto,
                 mr_especific_petrom.texto_especific WITHOUT DEFAULTS  

      BEFORE FIELD cod_item
         IF p_funcao = "MODIFICACAO" THEN
            NEXT FIELD metodo
         END IF  
      
      AFTER FIELD cod_item
         IF mr_especific_petrom.cod_item IS NOT NULL AND
            mr_especific_petrom.cod_item <> ' ' THEN
            IF pol0313_verifica_item() = FALSE THEN
               ERROR 'Item não cadastrado.'
               NEXT FIELD cod_item
            END IF 
         ELSE
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD cod_item
            END IF
         END IF  

      AFTER FIELD cod_cliente
         IF mr_especific_petrom.cod_cliente IS NOT NULL AND
            mr_especific_petrom.cod_cliente <> ' ' THEN
            IF pol0313_verifica_cliente() = FALSE THEN
               ERROR 'Cliente não cadastrado.'
               NEXT FIELD cod_cliente
            END IF 
         END IF  
      
      BEFORE FIELD tip_analise
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD metodo
         END IF

      AFTER FIELD tip_analise  
         IF mr_especific_petrom.tip_analise IS NULL THEN
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD tip_analise  
            END IF
         ELSE
            IF pol0313_verifica_tip_analise() = FALSE THEN
               ERROR "Tipo de análise não Cadastrada."
               NEXT FIELD tip_analise
            ELSE
               IF pol0313_verifica_duplicidade() THEN
                  ERROR 'Registro já cadastrado.'
                  NEXT FIELD cod_item
               ELSE
                  IF mr_especific_petrom.cod_cliente IS NOT NULL THEN
                     IF pol0313_verifica_padrao_cliente() = FALSE THEN
                        ERROR 'Item não cadastrado nas especificações padrão.'
                        NEXT FIELD cod_item
                     END IF
                  END IF 
               END IF  
            END IF
         END IF
      
      AFTER FIELD metodo
         IF mr_especific_petrom.metodo IS NULL OR      
            mr_especific_petrom.metodo = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD metodo
            END IF 
         END IF 

      AFTER FIELD qtd_casas_dec 
         IF mr_especific_petrom.qtd_casas_dec IS NULL OR
            mr_especific_petrom.qtd_casas_dec = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD qtd_casas_dec 
            END IF
         END IF
 
      AFTER FIELD unidade 
         IF mr_especific_petrom.unidade IS NULL OR      
            mr_especific_petrom.unidade = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD unidade
            END IF
         END IF

      AFTER FIELD val_especif_de 
         IF mr_especific_petrom.val_especif_de IS NULL OR      
            mr_especific_petrom.val_especif_de = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD val_especif_de
            END IF
         END IF

      BEFORE FIELD val_especif_ate
         IF p_funcao = 'INCLUSAO' THEN
            LET mr_especific_petrom.val_especif_ate = 
                mr_especific_petrom.val_especif_de 
            DISPLAY BY NAME mr_especific_petrom.val_especif_ate
         END IF

      AFTER FIELD val_especif_ate 
         IF mr_especific_petrom.val_especif_ate IS NULL OR      
            mr_especific_petrom.val_especif_ate = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD val_especif_ate
            END IF
         ELSE
            IF mr_especific_petrom.val_especif_de >
               mr_especific_petrom.val_especif_ate THEN
               ERROR 'Valor final não pode ser maior que o valor inicial.'
               NEXT FIELD val_especif_de
            END IF
         END IF

      BEFORE FIELD variacao
         IF mr_especific_petrom.val_especif_de <> 
            mr_especific_petrom.val_especif_ate THEN
            LET mr_especific_petrom.variacao = 0 
            DISPLAY BY NAME mr_especific_petrom.variacao
            NEXT FIELD tipo_valor
         END IF

      AFTER FIELD variacao
         IF mr_especific_petrom.variacao IS NULL THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD variacao
            END IF 
         END IF 
     
      BEFORE FIELD tipo_valor
         IF mr_especific_petrom.val_especif_de <>
            mr_especific_petrom.val_especif_ate THEN
            NEXT FIELD calcula_media
         END IF
         IF mr_especific_petrom.variacao IS NOT NULL AND
            mr_especific_petrom.variacao <> '0' THEN
            LET mr_especific_petrom.tipo_valor = ' ' 
            DISPLAY BY NAME mr_especific_petrom.tipo_valor
            NEXT FIELD calcula_media
         END IF   
      
      AFTER FIELD tipo_valor
         IF mr_especific_petrom.tipo_valor IS NOT NULL AND
            mr_especific_petrom.tipo_valor <> ' ' THEN
            IF mr_especific_petrom.tipo_valor <> '<' AND
               mr_especific_petrom.tipo_valor <> '>' AND
               mr_especific_petrom.tipo_valor <> '<=' AND
               mr_especific_petrom.tipo_valor <> '>=' AND
               mr_especific_petrom.tipo_valor <> '<>' THEN
               ERROR 'Valor inválido.'
               NEXT FIELD tipo_valor
            END IF 
         END IF 
 
      AFTER FIELD calcula_media 
         IF FGL_LASTKEY() = FGL_KEYVAL("UP") OR 
            FGL_LASTKEY() = FGL_KEYVAL("LEFT") THEN
            IF mr_especific_petrom.tipo_valor IS NOT NULL AND
               mr_especific_petrom.tipo_valor <> ' ' THEN 
               NEXT FIELD tipo_valor
            ELSE 
               IF mr_especific_petrom.val_especif_de <>
                  mr_especific_petrom.val_especif_ate THEN
                  NEXT FIELD val_especif_ate
               ELSE 
                  NEXT FIELD variacao
               END IF
            END IF
         ELSE   
            IF mr_especific_petrom.calcula_media IS NOT NULL AND 
               mr_especific_petrom.calcula_media <> ' ' THEN
               IF mr_especific_petrom.calcula_media <> 'S' AND
                  mr_especific_petrom.calcula_media <> 'N' THEN
                  ERROR 'Valor inválido. Informe S - Sim ou N - Não'
                  NEXT FIELD calcula_media 
               END IF
            END IF    
         END IF    
 
      AFTER FIELD ies_tanque 
         IF mr_especific_petrom.ies_tanque IS NULL OR      
            mr_especific_petrom.ies_tanque = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD ies_tanque
            END IF
         ELSE
            IF mr_especific_petrom.ies_tanque <> 'S' AND 
               mr_especific_petrom.ies_tanque <> 'N' THEN
               ERROR 'Valor inválido. Informe S - Sim ou N - Não'
               NEXT FIELD ies_tanque
            END IF
         END IF

      AFTER FIELD ies_texto
         IF mr_especific_petrom.ies_texto IS NULL OR      
            mr_especific_petrom.ies_texto = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD ies_texto
            END IF
         ELSE
            IF mr_especific_petrom.ies_texto <> 'S' AND 
               mr_especific_petrom.ies_texto <> 'N' THEN
               ERROR 'Valor inválido. Informe S - Sim ou N - Não'
               NEXT FIELD ies_texto
            END IF
         END IF

      AFTER FIELD texto_especific
         {IF mr_especific_petrom.texto_especific IS NULL OR      
            mr_especific_petrom.texto_especific = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD texto_especific
            END IF
         END IF}
            
      ON KEY(control-z)
         CALL pol0313_popup()
 
      AFTER INPUT
         IF INT_FLAG = 0 THEN
            IF mr_especific_petrom.cod_item IS NULL THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD cod_item
            END IF 
            IF mr_especific_petrom.tip_analise IS NULL THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD tip_analise
            END IF 
         END IF 
 
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0313
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION pol0313_verifica_item()
#-------------------------------#
   DEFINE l_den_item         LIKE item_petrom.den_item_petrom

   SELECT den_item_petrom
     INTO l_den_item
     FROM item_petrom
    WHERE cod_empresa     = p_cod_empresa
      AND cod_item_petrom = mr_especific_petrom.cod_item
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item to den_item
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF  

END FUNCTION

#----------------------------------#
 FUNCTION pol0313_verifica_cliente()
#----------------------------------#
   DEFINE l_nom_cliente          LIKE clientes.nom_cliente

   SELECT nom_cliente
     INTO l_nom_cliente 
     FROM clientes
    WHERE cod_cliente = mr_especific_petrom.cod_cliente
      
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_nom_cliente TO nom_cliente
      RETURN TRUE
   ELSE
      DISPLAY l_nom_cliente TO nom_cliente
      RETURN FALSE
   END IF  

END FUNCTION

#--------------------------------------#
 FUNCTION pol0313_verifica_tip_analise()
#--------------------------------------#
    DEFINE l_den_analise        LIKE it_analise_petrom.den_analise
    SELECT den_analise
      INTO l_den_analise 
      FROM it_analise_petrom
     WHERE cod_empresa = p_cod_empresa  
       AND tip_analise = mr_especific_petrom.tip_analise
    IF sqlca.sqlcode = 0 THEN
       DISPLAY l_den_analise to den_analise
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF

END FUNCTION

#--------------------------------------#
 FUNCTION pol0313_verifica_duplicidade()
#--------------------------------------#
   IF mr_especific_petrom.cod_cliente IS NULL THEN
      SELECT cod_empresa
        FROM especific_petrom
       WHERE cod_empresa  = p_cod_empresa
         AND cod_item     = mr_especific_petrom.cod_item
         AND cod_cliente  IS NULL 
         AND tip_analise  = mr_especific_petrom.tip_analise
   ELSE
      SELECT cod_empresa
        FROM especific_petrom
       WHERE cod_empresa  = p_cod_empresa
         AND cod_item     = mr_especific_petrom.cod_item
         AND cod_cliente  = mr_especific_petrom.cod_cliente
         AND tip_analise  = mr_especific_petrom.tip_analise
   END IF
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF  

END FUNCTION

#-----------------------------------------#
 FUNCTION pol0313_verifica_padrao_cliente() 
#-----------------------------------------#

    WHENEVER ERROR CONTINUE
    SELECT *
      FROM especific_petrom
     WHERE cod_empresa  = mr_especific_petrom.cod_empresa
       AND cod_item     = mr_especific_petrom.cod_item
       AND cod_cliente IS NULL 
       AND tip_analise  = mr_especific_petrom.tip_analise

    IF sqlca.sqlcode = 0 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF  

END FUNCTION

#-----------------------#
 FUNCTION pol0313_popup()
#-----------------------#
   CASE
      WHEN INFIELD(cod_cliente)
         CALL vdp372_popup_cliente() RETURNING mr_especific_petrom.cod_cliente

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0313
         DISPLAY mr_especific_petrom.cod_cliente TO cod_cliente
         CALL pol0313_verifica_cliente() RETURNING p_status 

      WHEN infield(cod_item)
         CALL log009_popup(9,13,"ITEM PETROM","item_petrom","cod_item_petrom",
                                "den_item_petrom","POL0337","S","")
            RETURNING mr_especific_petrom.cod_item
        
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0313
         DISPLAY mr_especific_petrom.cod_item TO cod_item
         CALL pol0313_verifica_item() RETURNING p_status   

      WHEN INFIELD(tip_analise)
         CALL log009_popup(9,13,"TIPO ANÁLISE","it_analise_petrom",
                                "tip_analise","den_analise","POL0312","S","")
            RETURNING mr_especific_petrom.tip_analise 
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0313
         DISPLAY mr_especific_petrom.tip_analise TO tip_analise
         CALL pol0313_verifica_tip_analise() RETURNING p_status 
   END CASE

END FUNCTION

#--------------------------#
 FUNCTION pol0313_consulta()
#--------------------------#
   DEFINE sql_stmt           CHAR(500), 
          where_clause       CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON especific_petrom.cod_item,
                                     especific_petrom.cod_cliente,
                                     especific_petrom.tip_analise,
                                     especific_petrom.metodo,   
                                     especific_petrom.qtd_casas_dec,   
                                     especific_petrom.unidade,  
                                     especific_petrom.val_especif_de,
                                     especific_petrom.val_especif_ate,
                                     especific_petrom.variacao,       
                                     especific_petrom.tipo_valor,     
                                     especific_petrom.calcula_media,
                                     especific_petrom.ies_texto,
                                     especific_petrom.texto_especific

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0313

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_especific_petrom.* = mr_especific_petromr.*
      CALL pol0313_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT cod_empresa, cod_item, cod_cliente, ",
                  " tip_analise, metodo, qtd_casas_dec, unidade, ",
                  " val_especif_de, val_especif_ate, variacao, ",
                  " tipo_valor, calcula_media, ies_tanque, ies_texto, texto_especific ",
                  "  FROM especific_petrom ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'", 
                  " AND ",where_clause CLIPPED,                 
                  " ORDER BY cod_item, cod_cliente, tip_analise "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_especific_petrom.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0313_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0313_exibe_dados()
#-----------------------------#
   IF mr_especific_petrom.cod_cliente = '0' THEN
      LET mr_especific_petrom.cod_cliente = ' '
   END IF

   DISPLAY BY NAME mr_especific_petrom.*
   CALL pol0313_verifica_item() RETURNING p_status
   CALL pol0313_verifica_cliente() RETURNING p_status
   CALL pol0313_verifica_tip_analise() RETURNING p_status 

END FUNCTION

#-----------------------------------#
 FUNCTION pol0313_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_especific_petromr.* = mr_especific_petrom.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_especific_petrom.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_especific_petrom.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Registros nesta Direcao"
            LET mr_especific_petrom.* = mr_especific_petromr.* 
            EXIT WHILE
         END IF
       
         IF mr_especific_petrom.cod_cliente IS NULL OR
            mr_especific_petrom.cod_cliente = ' ' THEN 
            SELECT cod_empresa, cod_item, cod_cliente, 
                   tip_analise, metodo, qtd_casas_dec, unidade, 
                   val_especif_de, val_especif_ate, variacao, 
                   tipo_valor, calcula_media, ies_tanque, ies_texto, texto_especific
              INTO mr_especific_petrom.* 
              FROM especific_petrom   
             WHERE cod_empresa = mr_especific_petrom.cod_empresa
               AND cod_cliente IS NULL 
               AND cod_item    = mr_especific_petrom.cod_item
               AND tip_analise = mr_especific_petrom.tip_analise
         ELSE
            SELECT cod_empresa, cod_item, cod_cliente, 
                   tip_analise, metodo, qtd_casas_dec, unidade, 
                   val_especif_de, val_especif_ate, variacao, 
                   tipo_valor, calcula_media, ies_tanque ies_texto, texto_especific  
              INTO mr_especific_petrom.* 
              FROM especific_petrom   
             WHERE cod_empresa = mr_especific_petrom.cod_empresa
               AND cod_item    = mr_especific_petrom.cod_item
               AND cod_cliente = mr_especific_petrom.cod_cliente
               AND tip_analise = mr_especific_petrom.tip_analise
         END IF
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0313_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0313_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")

   WHENEVER ERROR CONTINUE

   IF mr_especific_petrom.cod_cliente IS NULL OR 
            mr_especific_petrom.cod_cliente = ' ' THEN
     DECLARE cm_padrao CURSOR FOR 
     SELECT *                            
       FROM especific_petrom  
      WHERE cod_empresa  = mr_especific_petrom.cod_empresa
        AND cod_item     = mr_especific_petrom.cod_item  
        AND cod_cliente IS NULL  
        AND tip_analise  = mr_especific_petrom.tip_analise   
     FOR UPDATE 
   ELSE
     DECLARE cm_padrao CURSOR FOR 
     SELECT *                            
       FROM especific_petrom  
      WHERE cod_empresa  = mr_especific_petrom.cod_empresa
        AND cod_item     = mr_especific_petrom.cod_item  
        AND cod_cliente  = mr_especific_petrom.cod_cliente
        AND tip_analise  = mr_especific_petrom.tip_analise   
     FOR UPDATE 
   END IF
      
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","ESPECIFIC_PETROM")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0313_modificacao()
#-----------------------------#

   IF pol0313_cursor_for_update() THEN
      LET mr_especific_petromr.* = mr_especific_petrom.*
      IF pol0313_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE especific_petrom
            SET tip_analise     = mr_especific_petrom.tip_analise,
                metodo          = mr_especific_petrom.metodo,
                unidade         = mr_especific_petrom.unidade,
                val_especif_de  = mr_especific_petrom.val_especif_de,
                val_especif_ate = mr_especific_petrom.val_especif_ate,
                variacao        = mr_especific_petrom.variacao,
                tipo_valor      = mr_especific_petrom.tipo_valor,
                calcula_media   = mr_especific_petrom.calcula_media,
                ies_tanque      = mr_especific_petrom.ies_tanque,  
                qtd_casas_dec   = mr_especific_petrom.qtd_casas_dec,
                ies_texto       = mr_especific_petrom.ies_texto,
                texto_especific = mr_especific_petrom.texto_especific                
         WHERE CURRENT OF cm_padrao

         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","ESPECIFIC_PETROM")
            ELSE
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","ESPECIFIC_PETROM")
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         LET mr_especific_petrom.* = mr_especific_petromr.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
         DISPLAY BY NAME mr_especific_petrom.tip_analise
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0313_exclusao()
#--------------------------#
   IF pol0313_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         IF mr_especific_petrom.cod_cliente IS NULL OR 
            mr_especific_petrom.cod_cliente = ' ' THEN
            DELETE FROM especific_petrom 
             WHERE cod_empresa  = mr_especific_petrom.cod_empresa
               AND cod_item     = mr_especific_petrom.cod_item  
               AND cod_cliente  IS NULL 
               AND tip_analise  = mr_especific_petrom.tip_analise
         ELSE
            DELETE FROM especific_petrom 
             WHERE cod_empresa  = mr_especific_petrom.cod_empresa
               AND cod_item     = mr_especific_petrom.cod_item  
               AND cod_cliente  = mr_especific_petrom.cod_cliente
               AND tip_analise  = mr_especific_petrom.tip_analise
         END IF
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","ESPECIFIC_PETROM")
            ELSE
               MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE mr_especific_petrom.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","ESPECIFIC_PETROM")
            CALL log085_transacao("ROLLBACK")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------#
 FUNCTION pol0313_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#