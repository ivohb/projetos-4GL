#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1205                                                 #
# OBJETIVO: BAIXA DE ETAPAS DE CONTRATO                             #
# DATA....: 11/06/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080),
          p_last_row           SMALLINT
                   
END GLOBALS

DEFINE p_salto              SMALLINT,
       p_erro_critico       SMALLINT,
       p_existencia         SMALLINT,
       p_num_seq            SMALLINT,
       P_Comprime           CHAR(01),
       p_descomprime        CHAR(01),
       p_rowid              INTEGER,
       p_retorno            SMALLINT,
       p_index              SMALLINT,
       s_index              SMALLINT,
       p_ind                SMALLINT,
       s_ind                SMALLINT,
       p_count              SMALLINT,
       p_houve_erro         SMALLINT,
       p_nom_tela           CHAR(200),
       p_ies_cons           SMALLINT,
       p_6lpp               CHAR(100),
       p_8lpp               CHAR(100),
       p_msg                CHAR(500),
       p_opcao              CHAR(01),
       p_excluiu            SMALLINT,
       p_dat_proces         DATE,
       p_val_baixar         DECIMAL(12,2),
       sql_stmt             CHAR(500),
       where_clause         CHAR(500),
       p_num_oc             INTEGER,
       p_num_contr          INTEGER,
       p_num_etapa          INTEGER,
       p_num_versao         INTEGER,
       p_versao_oc          INTEGER,
       p_num_prog           INTEGER,
       p_dat_vencto         DATE,
       p_val_etapa          DECIMAL(12,2),
       p_den_linha          CHAR(20),
       p_cod_item           CHAR(15),
       p_den_item           CHAR(76),
       p_info               SMALLINT

DEFINE p_linha          RECORD
   cod_lin_prod         decimal(2,0)
END RECORD

DEFINE pr_item          ARRAY[100] OF RECORD
       cod_item         CHAR(15),
       den_item         CHAR(76)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1205-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
            
   IF p_status = 0 THEN
      CALL pol1205_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1205_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1205") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1205 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol1205_cria_temp() THEN
      CLOSE WINDOW w_pol1205
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Linha" "Informar linha de produção"
         IF pol1205_info_linha() THEN
            LET p_ies_cons = TRUE
            ERROR 'Operação efetuada com sucesso !!!'
            NEXT OPTION "Processar" 
         ELSE
            LET p_ies_cons = FALSE
            CALL pol1205_limpa_tela()
            ERROR 'Operação cancela !!!'
         END IF 
      COMMAND "Item" "Informar itens"
         IF pol1205_info_item() THEN
            LET p_ies_cons = TRUE
            ERROR 'Operação efetuada com sucesso !!!'
            NEXT OPTION "Processar" 
         ELSE
            LET p_ies_cons = FALSE
            CALL pol1205_limpa_tela()
            ERROR 'Operação cancela !!!'
         END IF 
      COMMAND "Processar" "Processa a baixa da(s) etapa(s)."
         IF p_ies_cons THEN
            LET p_ies_cons = FALSE
            IF pol1205_processar() THEN
               ERROR 'Operação efetuada com sucesso !!!'
               NEXT OPTION "Fim" 
            ELSE
               ERROR 'Operação cancela !!!'
            END IF
         ELSE
            ERROR "Informe previamente os parâmetros !!!"
            NEXT OPTION "Informar" 
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1205_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1205

END FUNCTION

#----------------------------#
FUNCTION pol1205_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-----------------------#
 FUNCTION pol1205_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1205_cria_temp()#
#---------------------------#

   DROP TABLE item_temp_454
   CREATE TEMP TABLE item_temp_454 (
	    cod_item        CHAR(15)
   );
   
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","ITEM_TEMP_454")
			RETURN FALSE
	 END IF
	 
	 RETURN TRUE

END FUNCTION	 

#----------------------------#
FUNCTION pol1205_info_linha()#
#----------------------------#

   LET INT_FLAG = FALSE
   INITIALIZE p_linha, pr_item TO NULL
   CALL pol1205_limpa_tela()
   LET p_opcao = 'L'
   
   INPUT BY NAME p_linha.*
     WITHOUT DEFAULTS

   AFTER FIELD cod_lin_prod
      
      IF p_linha.cod_lin_prod IS NOT NULL THEN
         CALL pol1205_le_linha()
         IF p_den_linha IS NULL THEN
            LET p_msg = 'Linha de produção\n inexistente.'
            CALL log0030_mensagem(p_msg,'excla')
            NEXT FIELD cod_lin_prod
         END IF
      END IF
      
      DISPLAY p_den_linha TO den_linha
      
      ON KEY (Control-z)
         CALL pol1205_popup()
      
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   LET p_info = FALSE
   
   IF NOT pol1205_carrega_itens() THEN
      RETURN FALSE
   END IF

   IF NOT p_info THEN
      LET p_msg = 'Linha de produção informada\n',
                  'não contem ordens com status R'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1205_le_linha()#
#--------------------------#

   SELECT den_estr_linprod
     INTO p_den_linha
     FROM linha_prod
    WHERE cod_lin_prod = p_linha.cod_lin_prod
      AND cod_lin_recei = 0
      AND cod_seg_merc = 0
      AND cod_cla_uso = 0
   
   IF STATUS <> 0 THEN
      LET p_den_linha = NULL
   END IF
      
END FUNCTION

#-------------------------------#
FUNCTION pol1205_carrega_itens()#
#-------------------------------#
   
   DELETE FROM item_temp_454
   
   DECLARE cq_itens CURSOR FOR
    SELECT DISTINCT
           i.cod_item
      FROM item i, ordem_sup o
     WHERE i.cod_empresa = p_cod_empresa
       AND i.ies_situacao = 'A'
       AND i.cod_lin_prod = p_linha.cod_lin_prod
       AND o.cod_empresa = i.cod_empresa
       AND o.cod_item = i.cod_item
       AND o.ies_situa_oc = 'R'
       AND o.ies_versao_atual = 'S'
   
   FOREACH cq_itens INTO p_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE
      END IF      
      
      INSERT INTO item_temp_454
       VALUES(p_cod_item)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','item_temp_454')
         RETURN FALSE
      END IF      
   
      LET p_info = TRUE
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1205_info_item()#
#---------------------------#

   LET INT_FLAG = FALSE
   INITIALIZE p_linha, pr_item TO NULL
   CALL pol1205_limpa_tela()
   LET p_opcao = 'I'
   
   INPUT ARRAY pr_item
      WITHOUT DEFAULTS FROM sr_item.*
   
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  
      
      AFTER FIELD cod_item

         IF pr_item[p_ind].cod_item IS NULL THEN
            IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
               OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
            ELSE
               NEXT FIELD cod_item
            END IF
         ELSE
            IF pol1205_repetiu() THEN
               CALL log0030_mensagem('Item já informado.','excla')
               NEXT FIELD cod_item
            END IF

            LET p_cod_item = pr_item[p_ind].cod_item
            CALL pol1205_le_item()

            IF p_den_item IS NULL THEN
               CALL log0030_mensagem('Item Inexistente.','excla')
               NEXT FIELD cod_item
            END IF
            
            LET pr_item[p_ind].den_item = p_den_item
            DISPLAY p_den_item TO sr_item[s_ind].den_item
         END IF

      ON KEY (Control-z)
         CALL pol1205_popup()

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            IF pr_item[1].cod_item IS NULL THEN
               LET p_msg = 'Informe ao menos 1 item'
               CALL log0030_mensagem(p_msg,'excla')
               NEXT FIELD cod_item
            END IF
         END IF
         
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   DELETE FROM item_temp_454
   LET p_info = FALSE
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_item[p_ind].cod_item IS NOT NULL THEN
          SELECT COUNT(num_oc)
            INTO p_count
            FROM ordem_sup
           WHERE cod_empresa = p_cod_empresa
             AND cod_item = pr_item[p_ind].cod_item
             AND ies_versao_atual = 'S'
             AND ies_situa_oc = 'R'
          IF p_count > 0 THEN
             LET p_info = TRUE
             INSERT INTO item_temp_454
              VALUES(pr_item[p_ind].cod_item)
             IF STATUS <> 0 THEN
                CALL log003_err_sql('INSERT','item_temp_454')
                RETURN FALSE
             END IF
          END IF
       END IF
   END FOR
   
   IF NOT p_info THEN
      LET p_msg = 'Itens informados não contém\n',
                  'ordens com status R'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------#
FUNCTION pol1205_le_item()#
#-------------------------#

   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item
   
   IF STATUS <> 0 THEN
      LET p_den_item = NULL
   END IF
   
END FUNCTION

#-------------------------#
FUNCTION pol1205_repetiu()#
#-------------------------#

   FOR p_index = 1 TO ARR_COUNT()                                                                        
       IF p_index <> p_ind THEN                                                                            
          IF pr_item[p_index].cod_item = pr_item[p_ind].cod_item THEN    
             RETURN TRUE
          END IF                                                                                           
       END IF                                                                                              
   END FOR                                                                                                
   
   RETURN FALSE

END FUNCTION
   
#-----------------------#
  FUNCTION pol1205_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_lin_prod)
         CALL log009_popup(8,5,"LINHA DE PRODUTO","linha_prod",
            "cod_lin_prod","den_estr_linprod","","N",
            " 1=1 and cod_lin_recei = 0 and cod_seg_merc = 0 and cod_cla_uso = 0") 
            RETURNING p_codigo
         CURRENT WINDOW IS w_pol1205
         IF p_codigo IS NOT NULL THEN
            LET p_linha.cod_lin_prod = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_lin_prod
         END IF

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CURRENT WINDOW IS w_pol1205
         IF p_codigo IS NOT NULL THEN
           LET pr_item[p_ind].cod_item = p_codigo
           DISPLAY p_codigo TO sr_item[s_ind].cod_item
         END IF

   END CASE 


END FUNCTION 

#---------------------------#
FUNCTION pol1205_processar()#
#---------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   RETURN TRUE

END FUNCTION
   


#-------------------------------- FIM DE PROGRAMA BL-----------------------------#