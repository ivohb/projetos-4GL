#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL1112                                                 #
# OBJETIVO: ESPECIFICAÇÕES DO ITEM                                  #
# DATA....: 03/11/2011                                              #
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
          p_msg          CHAR(100),
          pa_curr        SMALLINT,
          sc_curr        SMALLINT,
          p_ies_validade char(01),
          p_valCaracter  DECIMAL(3,0),
          p_ies_texto    CHAR(01),
          p_cod_item             LIKE item.cod_item,
          p_cod_cliente          LIKE clientes.cod_cliente,
          p_tip_analise          LIKE especific_915.tip_analise

END GLOBALS

    DEFINE mr_especific  RECORD 
           cod_empresa          LIKE empresa.cod_empresa,
           cod_item             LIKE item.cod_item,
           cod_cliente          LIKE clientes.cod_cliente,
           tip_analise          LIKE especific_915.tip_analise,
           metodo               LIKE especific_915.metodo,
           qtd_casas_dec        LIKE especific_915.qtd_casas_dec,
           unidade              LIKE especific_915.unidade,
           val_especif_de       LIKE especific_915.val_especif_de,
           val_especif_ate      LIKE especific_915.val_especif_ate,
           variacao             LIKE especific_915.variacao,
           tipo_valor           LIKE especific_915.tipo_valor,
           calcula_media        LIKE especific_915.calcula_media,
           ies_tanque           LIKE especific_915.ies_tanque,
           ies_texto            LIKE especific_915.ies_texto
#           texto_especific      LIKE especific_915.texto_especific 
           END RECORD 
   
    DEFINE mr_especificr  RECORD
           cod_empresa           LIKE empresa.cod_empresa,
           cod_item              LIKE item.cod_item,
           cod_cliente           LIKE clientes.cod_cliente,
           tip_analise           LIKE especific_915.tip_analise,
           metodo                LIKE especific_915.metodo,
           qtd_casas_dec         LIKE especific_915.qtd_casas_dec,
           unidade               LIKE especific_915.unidade,
           val_especif_de        LIKE especific_915.val_especif_de,
           val_especif_ate       LIKE especific_915.val_especif_ate,
           variacao              LIKE especific_915.variacao,
           tipo_valor            LIKE especific_915.tipo_valor,
           calcula_media         LIKE especific_915.calcula_media,
           ies_tanque            LIKE especific_915.ies_tanque,
           ies_texto             LIKE especific_915.ies_texto
#           texto_especif         LIKE especific_915.texto_especific 
   END RECORD
    
   DEFINE ma_tela ARRAY[50] OF RECORD
           val_caracter         	LIKE tipo_caract_915.val_caracter,
           den_caracter           LIKE tipo_caract_915.den_caracter
   END RECORD

   DEFINE m_ies_cons      SMALLINT,
          m_item          DECIMAL(3,0)


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL1112-10.02.07"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("POL1112.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '11'; LET p_user = 'admlog';  LET p_status = 0

   IF p_status = 0  THEN
      CALL POL1112_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION POL1112_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL1112") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_POL1112 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1112","IN") THEN
            CALL POL1112_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_especific.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","POL1112","MO") THEN
               CALL POL1112_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_especific.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","POL1112","EX") THEN
               CALL POL1112_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1112","CO") THEN
            CALL POL1112_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1112_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1112_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL POL1112_sobre()
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
   CLOSE WINDOW w_POL1112

END FUNCTION

#--------------------------#
 FUNCTION POL1112_inclusao()
#--------------------------#
   DEFINE l_ind SMALLINT

   INITIALIZE mr_especific.* TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM

   IF POL1112_entrada_dados("INCLUSAO") THEN
      IF mr_especific.ies_texto = 'S' THEN
       	IF POL1112_ent_val_carac("INCLUSAO") THEN 
      		CALL log085_transacao("BEGIN")
      		LET mr_especific.cod_empresa = p_cod_empresa
      		WHENEVER ERROR CONTINUE
      		INSERT INTO especific_915 VALUES (mr_especific.cod_empresa,
                                            mr_especific.cod_item,
                                            mr_especific.cod_cliente,
                                            mr_especific.tip_analise,
                                            mr_especific.metodo,
                                            mr_especific.unidade,
                                            mr_especific.val_especif_de,
                                            mr_especific.val_especif_ate,
                                            mr_especific.variacao,
                                            mr_especific.tipo_valor,
                                            mr_especific.calcula_media,
                                            mr_especific.ies_tanque,
                                            mr_especific.qtd_casas_dec,
                                            mr_especific.ies_texto, ' ')
#                                           mr_especific.texto_especific)
      		WHENEVER ERROR STOP 
      		IF SQLCA.SQLCODE <> 0 THEN 
	 			 		LET p_houve_erro = TRUE
	 			 		CALL log003_err_sql("INCLUSAO","ESPECIFIC_915")       
      		ELSE
          	FOR l_ind = 1 TO 50
            	IF ma_tela[l_ind].val_caracter > 0  THEN
                 INSERT INTO espec_carac_915 
                 VALUES (p_cod_empresa,
                         mr_especific.cod_item,
                         mr_especific.tip_analise,
                         mr_especific.cod_cliente,
                         ma_tela[l_ind].val_caracter)
               	IF SQLCA.SQLCODE <> 0 THEN 
	                LET p_houve_erro = TRUE
	                CALL log003_err_sql("INCLUSAO","espec_carac_915")       
                  EXIT FOR
               	END IF
            	END IF
          	END FOR
     	 		END IF
     	 	END IF
   		ELSE
#       	IF POL1118_ent_val_carac("INCLUSAO") THEN 
      		CALL log085_transacao("BEGIN")
      		LET mr_especific.cod_empresa = p_cod_empresa
      		WHENEVER ERROR CONTINUE
      		INSERT INTO especific_915 VALUES (mr_especific.cod_empresa,
                                            mr_especific.cod_item,
                                            mr_especific.cod_cliente,
                                            mr_especific.tip_analise,
                                            mr_especific.metodo,
                                            mr_especific.unidade,
                                            mr_especific.val_especif_de,
                                            mr_especific.val_especif_ate,
                                            mr_especific.variacao,
                                            mr_especific.tipo_valor,
                                            mr_especific.calcula_media,
                                            mr_especific.ies_tanque,
                                            mr_especific.qtd_casas_dec,
                                            mr_especific.ies_texto,' ')
#                                           mr_especific.texto_especific)
      		WHENEVER ERROR STOP 
      		IF SQLCA.SQLCODE <> 0 THEN 
	 			 		LET p_houve_erro = TRUE
	 			 		CALL log003_err_sql("INCLUSAO","ESPECIFIC_915") 
	 			 	END IF	      
   		END IF  	 		

      IF p_houve_erro THEN 
      	CALL log085_transacao("ROLLBACK")
        MESSAGE "Inclusão Cancelada." ATTRIBUTE(REVERSE)
        RETURN FALSE
      ELSE
        CALL log085_transacao("COMMIT")
        MESSAGE "Inclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
        RETURN TRUE 
      END IF
   ELSE
     CLEAR FORM
     MESSAGE "Inclusão Cancelada." ATTRIBUTE(REVERSE)
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION POL1112_entrada_dados(p_funcao)
#---------------------------------------#
   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1112
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE mr_especific.* TO NULL
      LET mr_especific.ies_tanque    = 'N'
      LET mr_especific.ies_texto     = 'N'
      LET mr_especific.calcula_media = 'S'
      LET mr_especific.unidade = ' '
      LET mr_especific.val_especif_de = 0
      LET mr_especific.val_especif_ate = 0
      LET mr_especific.variacao = 0
   		LET mr_especific.tipo_valor = ''
   END IF

   LET mr_especific.cod_empresa = p_cod_empresa
   LET mr_especific.variacao = 0
   LET mr_especific.calcula_media = 'N'
   LET mr_especific.ies_tanque = 'N'

   DISPLAY BY NAME mr_especific.cod_empresa
   
   INPUT BY NAME mr_especific.cod_empresa, 
                 mr_especific.cod_item,
                 mr_especific.cod_cliente,
                 mr_especific.tip_analise,
                 mr_especific.metodo,
                 mr_especific.qtd_casas_dec,
                 mr_especific.unidade,
                 mr_especific.val_especif_de,
                 mr_especific.val_especif_ate,
                 mr_especific.tipo_valor
                 #mr_especific.variacao,
                 #mr_especific.calcula_media,
                 #mr_especific.ies_tanque
              WITHOUT DEFAULTS  

      BEFORE FIELD cod_item
         IF p_funcao = "MODIFICACAO" THEN
            NEXT FIELD metodo
         END IF  
      
      AFTER FIELD cod_item
         IF mr_especific.cod_item IS NOT NULL AND
            mr_especific.cod_item <> ' ' THEN
            IF POL1112_verifica_item() = FALSE THEN
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
         IF mr_especific.cod_cliente IS NOT NULL AND
            mr_especific.cod_cliente <> ' ' THEN
            IF POL1112_verifica_cliente() = FALSE THEN
               ERROR 'Cliente não cadastrado.'
               NEXT FIELD cod_cliente
            END IF 
         END IF  
      
      BEFORE FIELD tip_analise
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD metodo
         END IF

      AFTER FIELD tip_analise  
         IF mr_especific.tip_analise IS NULL THEN
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD tip_analise  
            END IF
         ELSE
            IF POL1112_verifica_tip_analise() = FALSE THEN
               ERROR "Tipo de análise não Cadastrada."
               NEXT FIELD tip_analise
            ELSE
               IF POL1112_verifica_duplicidade() THEN
                  ERROR 'Registro já cadastrado.'
                  NEXT FIELD cod_item
               ELSE
                  LET mr_especific.ies_texto     = p_ies_texto
                  IF mr_especific.cod_cliente IS NOT NULL THEN
                     IF POL1112_verifica_padrao_cliente() = FALSE THEN
                        ERROR 'Item não cadastrado nas especificações padrão.'
                        NEXT FIELD cod_item
                     END IF
                  END IF 
               END IF  
            END IF
         END IF
            
      AFTER FIELD qtd_casas_dec 
         IF mr_especific.qtd_casas_dec IS NULL OR
            mr_especific.qtd_casas_dec = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD qtd_casas_dec 
            END IF
         END IF
 
      

      BEFORE FIELD val_especif_de
         IF mr_especific.ies_texto = 'S' THEN
            exit input
         END IF

      	AFTER FIELD val_especif_de 
         IF mr_especific.val_especif_de IS NULL OR      
            mr_especific.val_especif_de = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD val_especif_de
            END IF
         END IF

      	BEFORE FIELD val_especif_ate
         IF p_funcao = 'INCLUSAO' THEN
            LET mr_especific.val_especif_ate = 
                mr_especific.val_especif_de 
            DISPLAY BY NAME mr_especific.val_especif_ate
         END IF

      	AFTER FIELD val_especif_ate 
         IF mr_especific.val_especif_ate IS NULL OR      
            mr_especific.val_especif_ate = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD val_especif_ate
            END IF
         ELSE
            IF mr_especific.val_especif_de >
               mr_especific.val_especif_ate THEN
               ERROR 'Valor final não pode ser maior que o valor inicial.'
               NEXT FIELD val_especif_de
            END IF
         END IF 
		 
		 BEFORE FIELD tipo_valor
		 IF mr_especific.val_especif_de <> mr_especific.val_especif_ate THEN
		    EXIT INPUT
         END IF
		 
		 AFTER FIELD tipo_valor	  
         IF mr_especific.tipo_valor IS NOT NULL AND  mr_especific.tipo_valor <> ' ' THEN
            IF mr_especific.tipo_valor <> '<'  AND
               mr_especific.tipo_valor <> '>'  AND
               mr_especific.tipo_valor <> '<=' AND
               mr_especific.tipo_valor <> '>=' AND
			   mr_especific.tipo_valor <> '='  AND
               mr_especific.tipo_valor <> '<>' THEN
               ERROR 'Valor inválido.'
               NEXT FIELD tipo_valor
            END IF 
		 ELSE
			IF mr_especific.val_especif_de = mr_especific.val_especif_ate THEN
			   ERROR 'Campo obrigatório quando valores espec. iguais.'
               NEXT FIELD tipo_valor
			END IF		 
         END IF 

            
      ON KEY(control-z)
         CALL POL1112_popup()
 
      AFTER INPUT
         IF INT_FLAG = 0 THEN
            IF mr_especific.cod_item IS NULL THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD cod_item
            END IF 
            IF mr_especific.tip_analise IS NULL THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD tip_analise
            END IF 
            IF mr_especific.ies_texto = 'S' THEN
            	LET mr_especific.val_especif_de  = 0
            	LET mr_especific.val_especif_ate = 0
            END IF	

         END IF 
 
   END INPUT 


   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1112
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION POL1112_verifica_item()
#-------------------------------#
   DEFINE l_den_item         LIKE item_915.den_item_portugues

   SELECT den_item_portugues
     INTO l_den_item
     FROM item_915
    WHERE cod_empresa     = p_cod_empresa
      AND cod_item_analise = mr_especific.cod_item
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item to den_item
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF  

END FUNCTION

#----------------------------------#
 FUNCTION POL1112_verifica_cliente()
#----------------------------------#
   DEFINE l_nom_cliente          LIKE clientes.nom_cliente

   SELECT nom_cliente
     INTO l_nom_cliente 
     FROM clientes
    WHERE cod_cliente = mr_especific.cod_cliente
      
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_nom_cliente TO nom_cliente
      RETURN TRUE
   ELSE
      DISPLAY l_nom_cliente TO nom_cliente
      RETURN FALSE
   END IF  

END FUNCTION

#--------------------------------------#
 FUNCTION POL1112_verifica_tip_analise()
#--------------------------------------#

    DEFINE l_den_analise        LIKE it_analise_915.den_analise_port
           
           
    SELECT den_analise_port,
           ies_validade, 
           ies_texto
      INTO l_den_analise,
           p_ies_validade,
           p_ies_texto
      FROM it_analise_915
     WHERE cod_empresa = p_cod_empresa  
       AND tip_analise = mr_especific.tip_analise
    IF sqlca.sqlcode = 0 THEN
       DISPLAY l_den_analise to den_analise_port
       DISPLAY p_ies_texto TO mr_especific.ies_texto
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF

END FUNCTION

#--------------------------------------#
 FUNCTION POL1112_verifica_duplicidade()
#--------------------------------------#
   IF mr_especific.cod_cliente IS NULL THEN
      SELECT cod_empresa
        FROM especific_915
       WHERE cod_empresa  = p_cod_empresa
         AND cod_item     = mr_especific.cod_item
         AND cod_cliente  IS NULL 
         AND tip_analise  = mr_especific.tip_analise
   ELSE
      SELECT cod_empresa
        FROM especific_915
       WHERE cod_empresa  = p_cod_empresa
         AND cod_item     = mr_especific.cod_item
         AND cod_cliente  = mr_especific.cod_cliente
         AND tip_analise  = mr_especific.tip_analise
   END IF
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF  

END FUNCTION

#-----------------------------------------#
 FUNCTION POL1112_verifica_padrao_cliente() 
#-----------------------------------------#

    WHENEVER ERROR CONTINUE
    SELECT *
      FROM especific_915
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item     = mr_especific.cod_item
       AND cod_cliente IS NULL 
       AND tip_analise  = mr_especific.tip_analise

    IF sqlca.sqlcode = 0 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF  

END FUNCTION

#-----------------------#
 FUNCTION POL1112_popup()
#-----------------------#
   DEFINE z_ind  SMALLINT

   DEFINE pr_lote ARRAY[15] OF RECORD
      val_caracter INTEGER,
      resultado    char(45)
   END RECORD
   
   CASE
      WHEN INFIELD(cod_cliente)
         CALL vdp372_popup_cliente() RETURNING mr_especific.cod_cliente

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1112
         DISPLAY mr_especific.cod_cliente TO cod_cliente
         CALL POL1112_verifica_cliente() RETURNING p_status 

      WHEN infield(cod_item)
         CALL log009_popup(9,13,"ITEM PARA ANALISE","item_915","cod_item_analise",
                                "den_item_portugues","POL1118","S","")
            RETURNING mr_especific.cod_item
        
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1112
         DISPLAY mr_especific.cod_item TO cod_item
         CALL POL1112_verifica_item() RETURNING p_status   

      WHEN INFIELD(tip_analise)
         CALL log009_popup(9,13,"TIPO ANÁLISE","it_analise_915",
                                "tip_analise","den_analise_port","POL1111","S","")
            RETURNING mr_especific.tip_analise 
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1112
         DISPLAY mr_especific.tip_analise TO tip_analise
         CALL POL1112_verifica_tip_analise() RETURNING p_status 
   END CASE

   CASE 
   	WHEN infield(val_caracter)
	
				LET z_ind = 1
   			CALL log006_exibe_teclas("01",p_versao)
      	INITIALIZE p_nom_tela TO NULL
   			CALL log130_procura_caminho("POL11131") RETURNING p_nom_tela
      	LET p_nom_tela = p_nom_tela CLIPPED
      	OPEN WINDOW w_pol11121 AT 6,10 WITH FORM p_nom_tela
      	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)           
				DECLARE cq_lote2 CURSOR FOR
				SELECT  val_caracter, den_caracter 
				FROM tipo_caract_915
				WHERE cod_empresa = p_cod_empresa
				AND tip_analise = mr_especific.tip_analise
				AND cod_cliente IS NULL
       
		  	FOREACH cq_lote2 into 
					pr_lote[z_ind].val_caracter,
					pr_lote[z_ind].resultado
      
					let z_ind = z_ind + 1

      	END FOREACH

   			CALL SET_COUNT(z_ind - 1) 
   			DISPLAY ARRAY pr_lote TO sr_lote.*
   
   			LET z_ind = ARR_CURR()
   			CLOSE WINDOW w_pol11121

				if status <> 0 then
					call log003_err_sql('Lendo','tipo_caract_915')
					CLOSE WINDOW w_pol11121
					RETURN FALSE
				end if
   			IF INT_FLAG THEN
      		RETURN FALSE
   			End if

   		CALL log006_exibe_teclas("01 02 07",p_versao)
   		CURRENT WINDOW IS w_POL1112		
		   LET p_valCaracter = pr_lote[z_ind].val_caracter
		   LET ma_tela[pa_curr].val_caracter = p_valCaracter
   		DISPLAY pr_lote[z_ind].resultado TO ma_tela[pa_curr].den_caracter
   		DISPLAY p_valCaracter TO ma_tela[pa_curr].val_caracter
   		RETURN TRUE
   END CASE


END FUNCTION

#--------------------------#
 FUNCTION POL1112_consulta()
#--------------------------#

   DEFINE sql_stmt           CHAR(500), 
          where_clause       CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON especific_915.cod_item,
                                     especific_915.cod_cliente,
                                     especific_915.tip_analise,
                                     especific_915.metodo,   
                                     especific_915.qtd_casas_dec,   
                                     especific_915.unidade,  
                                     especific_915.val_especif_de,
                                     especific_915.val_especif_ate,
                                     especific_915.tipo_valor     


ON KEY (control-z)
      CALL pol1112_popup()
	END CONSTRUCT


   CALL log006_exibe_teclas("01",p_versao)
   

   CURRENT WINDOW IS w_POL1112

     


   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_especific.* = mr_especificr.*
      CALL POL1112_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT cod_empresa, cod_item, cod_cliente, ",
                  " tip_analise, metodo, qtd_casas_dec, unidade, ",
                  " val_especif_de, val_especif_ate, variacao, ",
                  " tipo_valor, calcula_media, ies_tanque, ies_texto ",
                  "  FROM especific_915 ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'", 
                  " AND ",where_clause CLIPPED,                 
                  " ORDER BY cod_item, cod_cliente, tip_analise "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_especific.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL POL1112_carrega_array()
      CALL POL1112_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION POL1112_exibe_dados()
#-----------------------------#
   IF mr_especific.cod_cliente = '0' THEN
      LET mr_especific.cod_cliente = ' '
   END IF

   DISPLAY BY NAME 
                 mr_especific.cod_empresa, 
                 mr_especific.cod_item,
                 mr_especific.cod_cliente,
                 mr_especific.tip_analise,
                 mr_especific.metodo,
                 mr_especific.qtd_casas_dec,
                 mr_especific.unidade,
                 mr_especific.val_especif_de,
                 mr_especific.val_especif_ate,
                 mr_especific.ies_texto
#                 mr_especific.texto_especific
   
   
   CALL POL1112_verifica_item() RETURNING p_status
   CALL POL1112_verifica_cliente() RETURNING p_status
   CALL POL1112_verifica_tip_analise() RETURNING p_status 

END FUNCTION

#-----------------------------------#
 FUNCTION POL1112_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_especificr.* = mr_especific.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_especific.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_especific.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Registros nesta Direcao"
            LET mr_especific.* = mr_especificr.* 
            EXIT WHILE
         END IF
       
         IF SQLCA.SQLCODE = 0 THEN 
            CALL POL1112_exibe_dados()
            CALL POL1112_carrega_array()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION POL1112_cursor_for_update()
#-----------------------------------#
   IF mr_especific.cod_cliente IS NULL OR 
      mr_especific.cod_cliente = ' ' THEN
   		WHENEVER ERROR CONTINUE
    	DECLARE cm_padrao CURSOR FOR 
     	SELECT *                            
       FROM especific_915  
      WHERE cod_empresa  = mr_especific.cod_empresa
        AND cod_item     = mr_especific.cod_item  
        AND cod_cliente IS NULL  
        AND tip_analise  = mr_especific.tip_analise
   		FOR UPDATE 
   		CALL log085_transacao("BEGIN")
   		OPEN cm_padrao
   		FETCH cm_padrao
   		CASE SQLCA.SQLCODE
      		WHEN    0 RETURN TRUE 
      		WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      		WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      		OTHERWISE CALL log003_err_sql("LEITURA","ESPECIFIC_915")
   		END CASE
   		WHENEVER ERROR STOP
   ELSE
   		WHENEVER ERROR CONTINUE
    	DECLARE cm_padrao CURSOR FOR 
     	SELECT *                            
       FROM especific_915  
      WHERE cod_empresa  = mr_especific.cod_empresa
        AND cod_item     = mr_especific.cod_item  
        AND cod_cliente  = mr_especific.cod_cliente 
        AND tip_analise  = mr_especific.tip_analise
   		FOR UPDATE 
   		CALL log085_transacao("BEGIN")
   		OPEN cm_padrao
   		FETCH cm_padrao
   		CASE SQLCA.SQLCODE
      	WHEN    0 RETURN TRUE 
      	WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      	WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      	OTHERWISE CALL log003_err_sql("LEITURA","ESPECIFIC_915")
   		END CASE
   		WHENEVER ERROR STOP
   END IF 
   

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION POL1112_modificacao()
#-----------------------------#

   DEFINE l_ind SMALLINT

   LET p_houve_erro = FALSE

   IF POL1112_cursor_for_update() THEN
      LET mr_especificr.* = mr_especific.*
      IF POL1112_entrada_dados("MODIFICACAO") THEN
      	IF mr_especific.ies_texto = 'S' THEN
         IF POL1112_ent_val_carac("MODIFICACAO") THEN 
         		WHENEVER ERROR CONTINUE
         		UPDATE especific_915
            	SET tip_analise     = mr_especific.tip_analise,
                metodo          = mr_especific.metodo,
                unidade         = mr_especific.unidade,
                val_especif_de  = mr_especific.val_especif_de,
                val_especif_ate = mr_especific.val_especif_ate,
                variacao        = mr_especific.variacao,
                tipo_valor      = mr_especific.tipo_valor,
                calcula_media   = mr_especific.calcula_media,
                ies_tanque      = mr_especific.ies_tanque,  
                qtd_casas_dec   = mr_especific.qtd_casas_dec,
                ies_texto       = mr_especific.ies_texto
         		WHERE CURRENT OF cm_padrao

            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("MODIFICACAO","ESPECIFIC_915")
               LET p_houve_erro = TRUE
            else
         			IF mr_especific.cod_cliente IS NULL OR 
            		mr_especific.cod_cliente = ' ' THEN
               	DELETE FROM espec_carac_915
     						WHERE cod_empresa = p_cod_empresa
       					AND cod_item      = mr_especific.cod_item
       					AND tip_analise   = mr_especific.tip_analise
       					AND cod_cliente IS NULL
         			ELSE
               	DELETE FROM espec_carac_915
     						WHERE cod_empresa = p_cod_empresa
       					AND cod_item      = mr_especific.cod_item
       					AND tip_analise   = mr_especific.tip_analise
       					AND cod_cliente   = mr_especific.cod_cliente
         			END IF
               IF SQLCA.SQLCODE <> 0 THEN
                  CALL log003_err_sql("EXCLUSAO","espec_carac_915")
                  LET p_houve_erro = TRUE
               else
                  FOR l_ind = 1 TO 50
                     IF ma_tela[l_ind].val_caracter> 0 THEN
                 		 		INSERT INTO espec_carac_915 
                 					VALUES (p_cod_empresa,
                         					mr_especific.cod_item,
                         					mr_especific.tip_analise,
                         					mr_especific.cod_cliente,
                         					ma_tela[l_ind].val_caracter)

                        IF SQLCA.SQLCODE <> 0 THEN
                           LET p_houve_erro = TRUE
                           CALL log003_err_sql("INCLUSAO","espec_carac_915")
                           EXIT FOR
                        END IF
                     END IF
                  END FOR
               end if
            end if

            IF p_houve_erro = FALSE THEN
               CALL log085_transacao("COMMIT")
               MESSAGE "Modificação Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            ELSE
               MESSAGE "Houve problemas na Modificação." ATTRIBUTE(REVERSE)
               CALL log085_transacao("ROLLBACK")
            END IF
         ELSE
            LET mr_especific.* = mr_especificr.*
            ERROR "Modificação Cancelada."
            CALL log085_transacao("ROLLBACK")
            CALL POL1112_exibe_dados()
         END IF
      	ELSE
         		WHENEVER ERROR CONTINUE
         		UPDATE especific_915
            	SET tip_analise     = mr_especific.tip_analise,
                metodo          = mr_especific.metodo,
                unidade         = mr_especific.unidade,
                val_especif_de  = mr_especific.val_especif_de,
                val_especif_ate = mr_especific.val_especif_ate,
                variacao        = mr_especific.variacao,
                tipo_valor      = mr_especific.tipo_valor,
                calcula_media   = mr_especific.calcula_media,
                ies_tanque      = mr_especific.ies_tanque,  
                qtd_casas_dec   = mr_especific.qtd_casas_dec,
                ies_texto       = mr_especific.ies_texto
         		WHERE CURRENT OF cm_padrao

            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("MODIFICACAO","ESPECIFIC_915")
               LET p_houve_erro = TRUE
            END IF   
      			IF p_houve_erro THEN 
      				CALL log085_transacao("ROLLBACK")
        			MESSAGE "Modificação Cancelada." ATTRIBUTE(REVERSE)
        			RETURN FALSE
      			ELSE
        			CALL log085_transacao("COMMIT")
        			MESSAGE "Modificação Efetuada com Sucesso" ATTRIBUTE(REVERSE)
        			RETURN TRUE 
      			END IF
      	END IF
      ELSE
         LET mr_especific.* = mr_especificr.*
         ERROR "Modificação Cancelada."
         CALL log085_transacao("ROLLBACK")
         CALL POL1112_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION POL1112_exclusao()
#--------------------------#
   IF POL1112_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         IF mr_especific.cod_cliente IS NULL OR 
            mr_especific.cod_cliente = ' ' THEN
            DELETE FROM especific_915 
             WHERE cod_empresa  = mr_especific.cod_empresa
               AND cod_item     = mr_especific.cod_item  
               AND cod_cliente  IS NULL 
               AND tip_analise  = mr_especific.tip_analise
         ELSE
            DELETE FROM especific_915 
             WHERE cod_empresa  = mr_especific.cod_empresa
               AND cod_item     = mr_especific.cod_item  
               AND cod_cliente  = mr_especific.cod_cliente
               AND tip_analise  = mr_especific.tip_analise
         END IF

         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","ESPECIFIC_915")
            ELSE
         			IF mr_especific.cod_cliente IS NULL OR 
            		mr_especific.cod_cliente = ' ' THEN
               	DELETE FROM espec_carac_915
     						WHERE cod_empresa = mr_especific.cod_empresa
       					AND cod_item      = mr_especific.cod_item
       					AND tip_analise   = mr_especific.tip_analise
       					AND cod_cliente IS NULL
         			ELSE
               	DELETE FROM espec_carac_915
     						WHERE cod_empresa = mr_especific.cod_empresa
       					AND cod_item      = mr_especific.cod_item
       					AND tip_analise   = mr_especific.tip_analise
       					AND cod_cliente   = mr_especific.cod_cliente
         			END IF
               MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE mr_especific.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","ESPECIFIC_915")
            CALL log085_transacao("ROLLBACK")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#--------------------------------------#
 FUNCTION POL1112_ent_val_carac(p_funcao)
#--------------------------------------#
   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1112

   IF p_funcao = 'INCLUSAO' THEN
      INITIALIZE ma_tela TO NULL
   END IF
 
   LET INT_FLAG =  FALSE

   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*

      BEFORE FIELD val_caracter
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD val_caracter
         IF ma_tela[pa_curr].val_caracter IS NOT NULL AND 
            ma_tela[pa_curr].val_caracter <> ' ' THEN
            IF POL1112_verifica_caracter() = FALSE THEN
               ERROR 'Código não cadastrado.'
               NEXT FIELD val_caracter 
            ELSE
               	IF POL1112_verifica_duplic_refer()  THEN
                  ERROR 'Código já cadastrado para esta Especificação Item ',m_item 
                  NEXT FIELD val_caracter 
               	END IF                         
            END IF                            
         END IF

      ON KEY (control-z)
         CALL POL1112_popup()

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1112

   IF INT_FLAG THEN
      IF p_funcao = "MODIFICACAO" THEN
         RETURN FALSE
      ELSE
         CLEAR FORM
         ERROR "Inclusão Cancelada"
         RETURN FALSE
      END IF
   ELSE
      RETURN TRUE
   END IF  

END FUNCTION

#-------------------------------#
 FUNCTION POL1112_verifica_caracter()
#-------------------------------#

   SELECT den_caracter 
     INTO ma_tela[pa_curr].den_caracter
     FROM tipo_caract_915
    WHERE cod_empresa  = p_cod_empresa  
      AND val_caracter = ma_tela[pa_curr].val_caracter
      AND tip_analise  = mr_especific.tip_analise
			AND cod_cliente IS NULL
			
   IF sqlca.sqlcode = 0 THEN
      DISPLAY ma_tela[pa_curr].den_caracter TO s_itens[sc_curr].den_caracter
      RETURN TRUE
   ELSE
      DISPLAY ma_tela[pa_curr].den_caracter TO s_itens[sc_curr].den_caracter
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION POL1112_verifica_duplic_refer()
#---------------------------------------#

   DEFINE l_ind1         		SMALLINT,
	      l_item_existe         SMALLINT

          	FOR l_ind1 = 1 TO 50
            	IF	(ma_tela[l_ind1].val_caracter = ma_tela[pa_curr].val_caracter)  
				AND (l_ind1 <>  pa_curr) THEN
					LET l_item_existe = FALSE
					EXIT FOR
               	END IF
          	END FOR

   IF l_item_existe THEN 
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION POL1112_carrega_array()
#-------------------------------#
   DEFINE l_ind          SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1112
   INITIALIZE ma_tela TO NULL
   CLEAR FORM

   LET l_ind = 1
   LET p_cod_cliente = mr_especific.cod_cliente
   LET p_cod_item    = mr_especific.cod_item
   LET p_tip_analise = mr_especific.tip_analise
   
   IF mr_especific.cod_cliente IS NULL OR
      mr_especific.cod_cliente = ' ' THEN 
   	DECLARE c_item CURSOR WITH HOLD FOR
   		SELECT val_caracter 
      	FROM espec_carac_915
     	WHERE cod_empresa     = p_cod_empresa
       	AND cod_item    = p_cod_item
       	AND tip_analise = p_tip_analise
       	AND cod_cliente IS NULL 
     	ORDER BY val_caracter 
   ELSE
   DECLARE c_item CURSOR WITH HOLD FOR
    	SELECT val_caracter 
      	FROM espec_carac_915
     	WHERE cod_empresa     = p_cod_empresa
       	AND cod_item    = p_cod_item
       	AND tip_analise = p_tip_analise
       	AND cod_cliente = p_cod_cliente
     	ORDER BY val_caracter 
	END IF
	 
   FOREACH c_item INTO ma_tela[l_ind].val_caracter           

   IF mr_especific.cod_cliente IS NULL OR
      mr_especific.cod_cliente = ' ' THEN 
   		SELECT den_caracter 
     		INTO ma_tela[l_ind].den_caracter
     		FROM tipo_caract_915
    	WHERE cod_empresa  = p_cod_empresa  
      	AND val_caracter = ma_tela[l_ind].val_caracter
      	AND tip_analise  = mr_especific.tip_analise
      	AND cod_cliente IS NULL
   ELSE  
   		SELECT den_caracter 
     		INTO ma_tela[l_ind].den_caracter
     		FROM tipo_caract_915
    	WHERE cod_empresa  = p_cod_empresa  
      	AND val_caracter = ma_tela[l_ind].val_caracter
      	AND tip_analise  = mr_especific.tip_analise
      	AND cod_cliente  = mr_especific.cod_cliente
   END IF  	

      LET l_ind = l_ind + 1

   END FOREACH 

   CALL POL1112_exibe_dados()
   CALL POL1112_verifica_duplicidade() RETURNING p_status

   IF l_ind > 1 THEN
      LET l_ind = l_ind - 1
   END IF

   CALL SET_COUNT(l_ind)

   IF l_ind > 10 THEN
      DISPLAY ARRAY ma_tela TO s_itens.*
      END DISPLAY
   ELSE
      INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF                    

END FUNCTION


#-----------------------#
 FUNCTION POL1112_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#