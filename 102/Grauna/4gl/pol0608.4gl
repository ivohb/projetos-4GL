#-------------------------------------------------------------------#
# PROGRAMA: pol0608                                                 #
# OBJETIVO: CANCELAMENTO DO FATURAMENTO DE PEÇAS REJEITADAS         #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 11/07/2007                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_titulo             CHAR(20),
          p_status             SMALLINT,
          p_men                CHAR(65),
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_normal             CHAR(02),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          sql_stmt             CHAR(500)
          
   DEFINE p_tela               RECORD
          num_pedido           LIKE pedidos.num_pedido,
          cod_cliente          LIKE clientes.cod_cliente,
          nom_reduzido         LIKE clientes.nom_reduzido,
          num_sequencia        LIKE ped_itens.num_sequencia,
          cod_item             LIKE item.cod_item,
          den_item_reduz       LIKE item.den_item_reduz,
          qtd_faturada         LIKE fat_pc_rejei_1040.qtd_faturada,
          qtd_cancelar         LIKE fat_pc_rejei_1040.qtd_faturada
   END RECORD 
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0608-05.10.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0608.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0608_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0608_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0608") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0608 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Cancelamento"
         HELP 001 
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0608","IN")  THEN
            LET p_count = 0
            IF pol0608_informar() THEN
               ERROR "Parâmetros informados com sucesso !!!" 
               NEXT OPTION "Processar"
            ELSE
               ERROR "Operação Cancelada !!!"
               NEXT OPTION "Fim"
            END IF
         END IF 
      COMMAND "Processar" "Processa o Cancelamento do faturamento"
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0386","IN") THEN
               IF log004_confirm(19,41) THEN
                  CALL log085_transacao("BEGIN")
                  IF pol0386_processa() THEN
                     ERROR "Processamento Efetuado c/ Sucesso" 
                     CALL log085_transacao("COMMIT")
                  ELSE
                     ERROR "Operação cancelada !!!" ATTRIBUTE(REVERSE)
                     CALL log085_transacao("ROLLBACK")
                  END IF
                  LET p_ies_cons = FALSE
                  NEXT OPTION "Fim"
               END IF
            END IF
         ELSE
            ERROR "Informe os parâmetros previamente !!!"
            NEXT OPTION "Informar"
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
  
   CLOSE WINDOW w_pol0608

END FUNCTION


#--------------------------#
FUNCTION pol0608_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
 
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD num_pedido
         IF p_tela.num_pedido IS NULL THEN
            ERROR 'Compo com preenchimento obrigatório !!!'
            NEXT FIELD num_pedido
         END IF
         
         SELECT cod_cliente
           INTO p_tela.cod_cliente
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_tela.num_pedido
         
         IF STATUS = 100 THEN
            ERROR 'Pedido Inexistente !!! '
            NEXT FIELD num_pedido
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql("LEITURA","PEDIDOS")    
               LET INT_FLAG = FALSE
               EXIT INPUT
            END IF
         END IF

         SELECT nom_reduzido
           INTO p_tela.nom_reduzido
           FROM clientes
          WHERE cod_cliente = p_tela.cod_cliente
          
         IF STATUS = 100 THEN
            LET p_tela.nom_reduzido = NULL
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql("LEITURA","CLIENTES")    
               LET INT_FLAG = FALSE
               EXIT INPUT
            END IF
         END IF
         
         DISPLAY p_tela.cod_cliente  TO cod_cliente
         DISPLAY p_tela.nom_reduzido TO nom_reduzido
      
      BEFORE FIELD num_sequencia
         IF p_tela.num_sequencia IS NULL THEN
            LET p_tela.num_sequencia = 1
         END IF
         
      AFTER FIELD num_sequencia

         IF NOT pol0608_consiste_seq() THEN
            NEXT FIELD num_sequencia
         END IF


      BEFORE FIELD qtd_cancelar
         IF p_tela.qtd_cancelar IS NULL THEN
            LET p_tela.qtd_cancelar = 0
         END IF

      AFTER FIELD qtd_cancelar
         IF NOT pol0608_consiste_qtd() THEN
            NEXT FIELD qtd_cancelar
         END IF
         
      AFTER INPUT
         IF NOT INT_FLAG THEN
         
            IF NOT pol0608_consiste_seq() THEN
               NEXT FIELD num_sequencia
            END IF
         
            IF NOT pol0608_consiste_qtd() THEN
               NEXT FIELD qtd_cancelar
            END IF
         
         END IF
                     
   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
      RETURN TRUE
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE
   
END FUNCTION

#------------------------------#
FUNCTION pol0608_consiste_seq()
#------------------------------#

   IF p_tela.num_sequencia IS NULL THEN
      ERROR 'Compo com preenchimento obrigatório !!!'
      RETURN FALSE
   END IF

   SELECT cod_item
	   INTO p_tela.cod_item
	   FROM ped_itens
	  WHERE cod_empresa   = p_cod_empresa
	    AND num_pedido    = p_tela.num_pedido
	    AND num_sequencia = p_tela.num_sequencia
	
   IF STATUS = 100 THEN
	    ERROR 'Sequencia do pedido inexistente !!!'
	    RETURN FALSE
	 ELSE
	    IF STATUS <> 0 THEN
	       CALL log003_err_sql("LEITURA","PED_ITENS")    
	       RETURN FALSE
	    END IF
	 END IF
	
	 SELECT den_item_reduz
	   INTO p_tela.den_item_reduz
	   FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item    = p_tela.cod_item
	
	 IF STATUS = 100 THEN
	    LET p_tela.den_item_reduz = NULL
	 ELSE
	    IF STATUS <> 0 THEN
	       CALL log003_err_sql("LEITURA","ITEM")    
	       RETURN FALSE
	    END IF
   END IF
	
	 DISPLAY p_tela.cod_item       TO cod_item
	 DISPLAY p_tela.den_item_reduz TO den_item_reduz
	
	 SELECT qtd_faturada
	   INTO p_tela.qtd_faturada
	   FROM fat_pc_rejei_1040
	  WHERE cod_empresa   = p_cod_empresa
	    AND num_pedido    = p_tela.num_pedido
	    AND num_sequencia = p_tela.num_sequencia
	   
	 IF STATUS = 100 THEN
	    ERROR 'Não há faturamento peças rejeitadas p/ pedido/seq. informados'
	    RETURN FALSE
	 ELSE
	    IF STATUS <> 0 THEN
	       CALL log003_err_sql("LEITURA","FAT_PC_REJEI_1040")    
	       RETURN FALSE
	    END IF
	 END IF
	  
	 DISPLAY p_tela.qtd_faturada TO qtd_faturada

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0608_consiste_qtd()
#------------------------------#

   IF p_tela.qtd_cancelar IS NULL OR
      p_tela.qtd_cancelar = 0 THEN
      ERROR 'Informe a quqntidade a cancelar !!!'
      RETURN FALSE
   END IF

   IF p_tela.qtd_cancelar > p_tela.qtd_faturada THEN
      ERROR 'Qtd Cancelar > Qtd Faturadas !!!'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION


#--------------------------#
FUNCTION pol0386_processa()
#--------------------------#

   WHENEVER ERROR CONTINUE

   UPDATE ped_itens
      SET qtd_pecas_atend = qtd_pecas_atend - p_tela.qtd_cancelar
	  WHERE cod_empresa   = p_cod_empresa
	    AND num_pedido    = p_tela.num_pedido
	    AND num_sequencia = p_tela.num_sequencia
      
   IF STATUS <> 0 THEN
	    CALL log003_err_sql("UPDATE","PED_ITENS")    
	    RETURN FALSE
	 END IF

   UPDATE fat_pc_rejei_1040
      SET qtd_faturada = qtd_faturada - p_tela.qtd_cancelar
	  WHERE cod_empresa   = p_cod_empresa
	    AND num_pedido    = p_tela.num_pedido
	    AND num_sequencia = p_tela.num_sequencia
      
   IF STATUS <> 0 THEN
	    CALL log003_err_sql("UPDATE","FAT_PC_REJEI_1040")    
	    RETURN FALSE
	 END IF

   RETURN TRUE
   
END FUNCTION
