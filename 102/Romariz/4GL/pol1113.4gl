#-------------------------------------------------------------------#
# SISTEMA.: EMISSOR DE LAUDOS                                       #
# PROGRAMA: POL1113                                                 #
# OBJETIVO: RESULTADO DAS AN�LISES                                  #
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
          sql_stmt        CHAR(500),
          p_r             CHAR(001),
          p_count         SMALLINT,
          p_ind           INTEGER,
          s_ind           INTEGER,
          p_ies_cons      SMALLINT,
          p_last_row      SMALLINT,
          p_grava         SMALLINT, 
          pa_curr         SMALLINT,
          pa_curr1        SMALLINT,
          sc_curr         SMALLINT,
          sc_curr1        SMALLINT,
          w_a             SMALLINT,
		  p_msg           CHAR(500),
		  p_operacao      CHAR(10),
		  p_mensagem      CHAR(300),
		  p_id_registro   INTEGER,
		  p_cod_familia   char(05),
          p_dat_atual     date,
          p_dat_hor       DATETIME YEAR TO SECOND,
          p_txt_tip       char(10),
          p_txt_val       char(15),
          p_unidade       char(15),
          p_item          CHAR(15),
          p_num_pa        INTEGER,
          p_qtd_laudo     INTEGER,
          p_val_analise   char(15),
		  p_val_analise_ant  LIKE analise_915.val_analise,
		  p_cod_operacao  	 LIKE estoque_trans.cod_operacao,
		  p_tem_val_ana      SMALLINT,
		  p_existe           SMALLINT,
		  L_TIPO_VALOR       CHAR(1),
		  p_tex_obs          CHAR(80)
		 

END GLOBALS
   
	DEFINE l_achou_pend          CHAR(01),
	       l_achou_nao_conf      CHAR(01),
	       l_qtd_saldo_ender     DECIMAL(15,3),
		     l_msg                 CHAR(700),
		     l_num_transac	       LIKE estoque_lote.num_transac,
		     l_movito		   		     LIKE estoque_lote_ender.qtd_saldo,
		     l_movito_pen    		   LIKE estoque_lote_ender.qtd_saldo,
		     l_resultado           CHAR(01),
		     l_num_transac_up1 	   LIKE estoque_lote.num_transac,
		     l_num_transac_up 	   LIKE estoque_lote_ender.num_transac,
		     p_oper_entrada        LIKE estoque_trans.cod_operacao,
		     p_oper_saida          LIKE estoque_trans.cod_operacao,
		     p_conta_debito        LIKE estoque_operac_ct.num_conta_debito,
		     p_conta_credito       LIKE estoque_operac_ct.num_conta_credito,

         p_ies_situa_orig    LIKE estoque_trans.ies_sit_est_orig,
         p_ies_situa_dest    LIKE estoque_trans.ies_sit_est_dest,
         p_cod_local_orig    LIKE estoque_trans.cod_local_est_orig,
         p_cod_local_dest    LIKE estoque_trans.cod_local_est_dest,
         p_num_lote_orig     LIKE estoque_lote.num_lote,
         p_num_lote_dest     LIKE estoque_lote.num_lote,
         p_num_conta         LIKE estoque_trans.num_conta,
         p_transac_i         LIKE estoque_trans.num_transac,
         p_transac_l         LIKE estoque_trans.num_transac
		     
		     
          
   DEFINE w_i                  SMALLINT,
          p_tip_estoque_de     LIKE wms_identif_estoque.tip_estoque,
          p_resticao_de        LIKE wms_identif_estoque.restricao,
          p_tip_estoque_para   LIKE wms_identif_estoque.tip_estoque,
          p_resticao_para      LIKE wms_identif_estoque.restricao,
          p_identif_estoque    LIKE wms_identif_estoque.identif_estoque

   DEFINE p_tip_estoq_915      RECORD LIKE tip_estoque_915.*
     
   DEFINE mr_tela RECORD 
      identif_estoque LIKE analise_mest_915.identif_estoque,
      cod_item        LIKE analise_915.cod_item,
      lote_tanque     LIKE analise_915.lote_tanque,
      num_pa          LIKE analise_915.num_pa,
	    dat_analise     LIKE analise_915.dat_analise,
	    qtd_lote        LIKE analise_mest_915.qtd_lote,
	    qtd_pa          LIKE analise_mest_915.qtd_pa,
	    ies_liberado    LIKE analise_mest_915.ies_liberado,
	    nom_usuario     LIKE analise_mest_915.nom_usuario
   END RECORD 

   DEFINE mr_telat RECORD 
      cod_item       LIKE analise_915.cod_item,
      lote_tanque    LIKE analise_915.lote_tanque,
      num_pa         LIKE analise_915.num_pa,
	  dat_analise    LIKE analise_915.dat_analise,
	  qtd_lote       LIKE analise_mest_915.qtd_lote,
	  qtd_pa         LIKE analise_mest_915.qtd_pa,
	  ies_liberado   LIKE analise_mest_915.ies_liberado,
	  nom_usuario    LIKE analise_mest_915.nom_usuario
   END RECORD 
   
   DEFINE ma_tela ARRAY[1000] OF RECORD 
      tip_analise    LIKE analise_915.tip_analise,
      den_analise    LIKE it_analise_915.den_analise_port,
      metodo         LIKE analise_915.metodo,
      val_analise    LIKE analise_915.val_analise,
      em_analise     like analise_915.em_analise,
	  ies_obrigatoria    like analise_915.ies_obrigatoria,
	  ies_conforme       like analise_915.ies_conforme
   END RECORD 

   DEFINE pr_tela ARRAY[1000] OF RECORD 
      val_especif_de  LIKE especific_915.val_especif_de,
      val_especif_ate LIKE especific_915.val_especif_ate,
      ies_texto       char(01),
	  tipo_valor      LIKE especific_915.tipo_valor 
   END RECORD 

   DEFINE mr_esto RECORD 
      qtd_saldo     DECIMAL(15,3)
   END RECORD 

   DEFINE 		 p_estoque_trans 		RECORD LIKE estoque_trans.*,
			     p_estoque_trans_end  	RECORD LIKE estoque_trans_end.*,
				 p_estoque_lote_ender  	RECORD LIKE estoque_lote_ender.*,
				 p_estoque_lote 	  	RECORD LIKE estoque_lote.*
				 
DEFINE p_polit_estoq        CHAR(30),
       p_cod_item           CHAR(15),
       p_num_lote           CHAR(15),
       p_qtd_saldo          DECIMAL(10,3),
       p_cod_local_insp     CHAR(10),
       p_cod_local_estoq    CHAR(10),
       p_ies_situa          CHAR(01),
       p_controla_wms       CHAR(01)
       
DEFINE p_wms_identif_estoque RECORD
       identif_estoque       LIKE wms_identif_estoque.identif_estoque,
       qtd_origem            LIKE wms_identif_estoque.qtd_origem,
       qtd_regularizada      LIKE wms_identif_estoque.qtd_regularizada,
       tip_estoque           LIKE wms_identif_estoque.tip_estoque,
       restricao             LIKE wms_identif_estoque.restricao,
       sku                   LIKE wms_identif_estoque.sku,
       palete                LIKE wms_identif_estoque.palete,
       item                  LIKE wms_identif_estoque.item
END RECORD      


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "POL1113-10.02.56" 
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("POL1113.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '11'; LET p_user = 'admlog'; LET p_status = 0
      
   IF p_status = 0  THEN
      CALL POL1113_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION POL1113_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL1113") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_POL1113 AT 2,1 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","POL1113","IN") THEN
            IF POL1113_inclusao() THEN
               If POL1113_busca_itens_analise() then
                  IF POL1113_entrada_item("INCLUSAO") THEN
                     CALL POL1113_grava_dados()
                  End if
               END IF
            END IF
         END IF
      
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","POL1113","CO") THEN
            IF POL1113_consulta() THEN
               IF p_ies_cons = TRUE THEN
                 # NEXT OPTION "liBerar"
               END IF
            END IF
         END IF  
		 
	  COMMAND KEY("B") "liBerar" "Libera/Rejeita Lote"
         HELP 004
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","POL1113","CO") THEN
		           IF mr_tela.ies_liberado <> 'N' THEN
                  ERROR 'LOTE J� EST� LIBERADO OU REJEITADO !!!. - OPERA��O N�O PERMITIDA'
				          CONTINUE MENU
			         ELSE		
				          CALL log085_transacao('BEGIN')    
          				IF POL1113_libera() THEN
				             CALL log085_transacao('COMMIT')  
                     ERROR 'Opera��o efetuada com sucesso !!!'                            	
				             NEXT OPTION "Fim"   
				          ELSE                                         	
				 	           CALL log085_transacao('ROLLBACK') 
				 	           #ERROR 'Opera��o cancelada !!!'                                              	                                                 	
				 	           #NEXT OPTION "Liberar"  	 
				          END IF
               END IF
            END IF  
         ELSE
            ERROR 'Executa a consulta previamente.'
            NEXT OPTION "Consultar"
         END IF
        
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
      #  LET INT_FLAG = 0
         CALL POL1113_paginacao("SEGUINTE")
     
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
      #  LET INT_FLAG = 0
         CALL POL1113_paginacao("ANTERIOR") 
     
      COMMAND "Modificar" "Modifica dados da Tabela"
         HELP 002
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","POL1113","MO") THEN
			         CALL POL1113_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
     
      COMMAND "Excluir" "Exclui dados da Tabela"
         HELP 003
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","POL1113","EX") THEN
			         IF mr_tela.ies_liberado <> 'N' THEN
                   ERROR 'LOTE J� EST� LIBERADO OU REJEITADO !!!. - OPERA��O N�O PERMITIDA'
                   CONTINUE MENU
				       ELSE             
				           CALL POL1113_exclusao()
				       END IF	
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
		 
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa !!!"
         CALL POL1113_sobre()
		 
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
   CLOSE WINDOW w_POL1113

END FUNCTION

#-----------------------#
 FUNCTION POL1113_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
   
END FUNCTION   

#--------------------------#
 FUNCTION POL1113_inclusao()
#--------------------------#

   LET mr_esto.qtd_saldo = 0
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1113
   INITIALIZE mr_tela.* TO NULL
   INITIALIZE ma_tela TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
      
   LET mr_tela.nom_usuario =  p_user  
   DISPLAY mr_tela.nom_usuario        TO nom_usuario
   LET mr_tela.dat_analise = TODAY
   LET mr_tela.ies_liberado = 'N'
   DISPLAY mr_tela.ies_liberado       TO ies_liberado
  

   LET INT_FLAG =  FALSE
   INPUT BY NAME mr_tela.*  WITHOUT DEFAULTS  

      AFTER FIELD identif_estoque 

         IF mr_tela.identif_estoque IS NOT NULL THEN
            IF NOT pol1113_valida_identif(mr_tela.identif_estoque) THEN
               NEXT FIELD identif_estoque       
            END IF
            LET mr_tela.cod_item = p_wms_identif_estoque.item
            LET mr_tela.lote_tanque = p_num_lote
            LET mr_tela.qtd_lote = p_qtd_saldo
            LET mr_tela.qtd_pa = p_wms_identif_estoque.qtd_origem
            DISPLAY BY NAME mr_tela.*
            CALL POL1113_verifica_item() RETURNING p_status
            NEXT FIELD num_pa
         END IF

      AFTER FIELD cod_item 
         IF mr_tela.cod_item IS NULL THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD cod_item       
         END IF

         IF POL1113_verifica_item() = FALSE THEN
            ERROR 'Item n�o cadastrado.'
            NEXT FIELD cod_item
         END IF
         
         SELECT ind_item_ctr_wms 
           INTO p_controla_wms
           FROM wms_item_ctr_est
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = mr_tela.cod_item
         
         IF STATUS = 100 THEN
            LET p_controla_wms = 'N'
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','wms_item_ctr_est')
               NEXT FIELD cod_item
            END IF
         END IF
         
         IF p_controla_wms = 'S' THEN
            IF mr_tela.identif_estoque IS NULL THEN
               LET p_msg = 'Item controla WMS. Favor\n',
                           'informar o identificador.'
               CALL log0030_mensagem(p_msg, 'info')
               NEXT FIELD identif_estoque
            END IF
         END IF

      AFTER FIELD lote_tanque
         IF mr_tela.lote_tanque IS NULL THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD lote_tanque 
         END IF
         
				 LET mr_esto.qtd_saldo = 0 
				 SELECT sum(qtd_saldo) 
				 INTO mr_esto.qtd_saldo
				 FROM estoque_lote_ender
				 WHERE cod_empresa = p_cod_empresa
				 AND num_lote = mr_tela.lote_tanque
				 AND cod_item = mr_tela.cod_item 
				 AND ies_situa_qtd  = 'I'
				 AND qtd_saldo > 0

				 {AND cod_local = (SELECT cod_local_estoq  from item 
				                  WHERE cod_empresa = p_cod_empresa
								            AND cod_item = mr_tela.cod_item)}
								            		 
         IF (mr_esto.qtd_saldo = 0 ) OR (mr_esto.qtd_saldo IS NULL ) THEN
            ERROR "Lote informado n�o existe no estoque ou n�o est� em Inspe��o no Local padr�o"
            NEXT FIELD lote_tanque 
		     ELSE 
		        LET mr_tela.qtd_lote = mr_esto.qtd_saldo
			      DISPLAY mr_tela.qtd_lote TO qtd_lote
		     END IF
                  
      BEFORE FIELD num_pa
         IF POL1113_verifica_se_eh_tanque() = FALSE THEN
            CALL POL1113_busca_num_pa()
         END IF

      AFTER FIELD num_pa
         IF mr_tela.num_pa IS NOT NULL THEN
            IF POL1113_verifica_num_pa() THEN
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD num_pa
            END IF
         END IF 
      
      BEFORE FIELD qtd_pa
         
         IF mr_tela.identif_estoque IS NOT NULL THEN
            EXIT INPUT
         END IF

       AFTER FIELD qtd_pa
         
         IF (mr_tela.qtd_pa IS NULL)  OR (mr_tela.qtd_pa = 0 )  THEN
            ERROR "Campo de preenchimento obrigat�rio e maioir que zero."
            NEXT FIELD qtd_pa      
         ELSE
            IF mr_tela.qtd_pa > mr_tela.qtd_lote THEN
               ERROR 'Quantidade a inspecionar n�o pode ser maior que lote'
               NEXT FIELD qtd_pa 
            END IF   
         END IF
 
      ON KEY (control-z)
         CALL POL1113_popup()
 
    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1113
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------------#
FUNCTION pol1113_valida_identif(p_identif)#
#-----------------------------------------#
   
   DEFINE p_identif    LIKE wms_identif_estoque.identif_estoque
   
   SELECT identif_estoque,
          qtd_origem,
          qtd_regularizada,
          tip_estoque,
          restricao,
          sku,
          palete,
          item
     INTO p_wms_identif_estoque.*
     FROM wms_identif_estoque
    WHERE empresa = p_cod_empresa
      AND identif_estoque = p_identif

   IF STATUS = 100 THEN
      LET p_msg = 'Identificador inexistente.' 
      CALL log0030_mensagem(p_msg,'INFO')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','wms_identif_estoque')
         RETURN FALSE
      END IF
   END IF
   
   SELECT cod_empresa
     FROM tip_estoque_915      
    WHERE cod_empresa = p_cod_empresa
      AND tip_estoq_insp = p_wms_identif_estoque.tip_estoque
      AND restricao_insp = p_wms_identif_estoque.restricao
          
   IF STATUS = 100 THEN
      LET p_msg = 'Identificador n�o est�\n pendente de inspe��o.' 
      CALL log0030_mensagem(p_msg,'INFO')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','tip_estoque_915')
         RETURN FALSE
      END IF
   END IF

   SELECT num_lote,
          qtd_saldo,
          cod_local,
          ies_situa_qtd
     INTO p_num_lote,
          p_qtd_saldo,
          p_cod_local_insp,
          p_ies_situa
     FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_wms_identif_estoque.item
      AND identif_estoque = p_wms_identif_estoque.identif_estoque
      AND qtd_saldo > 0
      AND ies_situa_qtd = 'I'
          
   IF STATUS = 100 THEN
      LET p_msg = 'Identificador inexistente\n no estoque do logix.' 
      CALL log0030_mensagem(p_msg,'INFO')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_lote_ender')
         RETURN FALSE
      END IF
   END IF
   
   IF p_ies_situa <> 'I' THEN
      LET p_msg = 'Lote n�o est� em\n inspe��o no logix.' 
      CALL log0030_mensagem(p_msg,'INFO')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION POL1113_verifica_item()
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

#---------------------------------------# 
 FUNCTION POL1113_verifica_se_eh_tanque()
#---------------------------------------# 
   DEFINE l_ies_tanque          CHAR(1)

   DECLARE cq_tanque CURSOR FOR
    SELECT ies_tanque
      FROM especific_915
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
 FUNCTION POL1113_busca_num_pa()
#------------------------------#

   IF p_controla_wms = 'S' THEN   
      SELECT MAX(num_pa)
        INTO mr_tela.num_pa
        FROM analise_mest_915
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND lote_tanque = mr_tela.lote_tanque
         AND identif_estoque = mr_tela.identif_estoque
   ELSE
      SELECT MAX(num_pa)
        INTO mr_tela.num_pa
        FROM analise_mest_915
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND lote_tanque = mr_tela.lote_tanque
   END IF
      
   IF mr_tela.num_pa IS NULL THEN
      LET mr_tela.num_pa = 1
   ELSE
      LET mr_tela.num_pa = mr_tela.num_pa + 1
   END IF
  
   DISPLAY mr_tela.num_pa TO num_pa

END FUNCTION

#---------------------------------#
 FUNCTION POL1113_verifica_num_pa()
#---------------------------------#

   IF p_controla_wms = 'S' THEN
      LET p_msg = 'N�mero de PA j� existe para\n este Item/Lote/Identificador.'
      SELECT COUNT(a.num_pa)
        INTO p_count
        FROM analise_915 a, analise_mest_915 b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.cod_item    = mr_tela.cod_item
         AND a.lote_tanque = mr_tela.lote_tanque
         AND a.num_pa      = mr_tela.num_pa
         AND b.cod_empresa = a.cod_empresa
         AND b.cod_item    = a.cod_item   
         AND b.lote_tanque = a.lote_tanque
         AND b.num_pa      = a.num_pa   
         AND b.identif_estoque = mr_tela.identif_estoque         
   ELSE
      LET p_msg = 'N�mero de PA j� existe\n para este Item/Lote.'
      SELECT COUNT(num_pa)
        INTO p_count
        FROM analise_915
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND lote_tanque = mr_tela.lote_tanque
         AND num_pa      = mr_tela.num_pa
   END IF
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','analise_915')
      RETURN TRUE
   END IF
    
   IF p_count > 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 

END FUNCTION 

#-------------------------------------#
 FUNCTION POL1113_busca_itens_analise()
#-------------------------------------#
   DEFINE l_ind           SMALLINT

   INITIALIZE ma_tela, pr_tela to null
   
   LET l_ind = 1

   DECLARE cq_itens CURSOR FOR
    SELECT a.tip_analise, a.metodo, a.val_especif_de, a.val_especif_ate,
           a.tipo_valor, b.ies_texto, b.ies_obrigatoria, b.den_analise_port
      FROM especific_915 a, it_analise_915 b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.cod_item    = mr_tela.cod_item
       AND a.cod_cliente IS NULL 
       AND a.cod_empresa = b.cod_empresa
       AND a.tip_analise = b.tip_analise
       AND b.ies_validade = 'N'
	   ORDER BY a.tip_analise
	   
   FOREACH cq_itens INTO ma_tela[l_ind].tip_analise,
                         ma_tela[l_ind].metodo,
                         pr_tela[l_ind].val_especif_de,
                         pr_tela[l_ind].val_especif_ate,
						             pr_tela[l_ind].tipo_valor,
                         pr_tela[l_ind].ies_texto,
						             ma_tela[l_ind].ies_obrigatoria,
						             ma_tela[l_ind].den_analise

      LET ma_tela[l_ind].em_analise = 'S'
	    LET ma_tela[l_ind].ies_conforme = 'N'
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 1000 THEN
         CALL log0030_mensagem('Limite de itens ultrapassou','info')
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF l_ind > 1 THEN
      LET l_ind = l_ind - 1
   else
      let p_msg = "Item sem as especifica��es - cadastre-as no pol1112"
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
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

   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
 FUNCTION POL1113_entrada_item(p_funcao) 
#--------------------------------------#
   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT

   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1113

   LET INT_FLAG =  FALSE
 
   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*

      BEFORE FIELD val_analise 
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()
         
  		    LET p_val_analise_ant = ma_tela[pa_curr].val_analise 

      AFTER FIELD val_analise        
         
         LET p_val_analise = ma_tela[pa_curr].val_analise
         LET p_val_analise = p_val_analise CLIPPED
         
         
         IF p_val_analise IS NULL OR p_val_analise = ' ' OR length(p_val_analise) = 0 then
            IF ma_tela[pa_curr].tip_analise IS NULL OR ma_tela[pa_curr].tip_analise = ' ' THEN         
               let ma_tela[pa_curr].em_analise = ''
			         let ma_tela[pa_curr].ies_conforme = ''
            else
               let ma_tela[pa_curr].em_analise = 'S'
			         let ma_tela[pa_curr].ies_conforme = 'N'
            end if
         else   
		       IF  mr_tela.ies_liberado <> 'N'  AND 
		             ma_tela[pa_curr].val_analise <> p_val_analise_ant AND 
		             ma_tela[pa_curr].ies_obrigatoria  = 'S'  THEN 
				          ERROR 'PA j� liberada/rejeitada, resultado n�o pode ser alterado.'
				          LET ma_tela[pa_curr].val_analise  = p_val_analise_ant 
				          DISPLAY ma_tela[pa_curr].val_analise TO s_itens[sc_curr].val_analise
				         NEXT FIELD val_analise
			     ELSE
				      IF ma_tela[pa_curr].tip_analise IS NULL OR  ma_tela[pa_curr].tip_analise = ' ' THEN
				         ERROR 'N�o cont�m Tipo de An�lise para esta Linha.'
				         INITIALIZE ma_tela[pa_curr].val_analise TO NULL  
				         let ma_tela[pa_curr].ies_conforme = ''
				         NEXT FIELD val_analise
				      ELSE
					       IF POL1113_verifica_analise() = FALSE THEN
						        ERROR 'Resultado informado n�o existe.'
						        NEXT FIELD val_analise
					       ELSE
					       END IF
				      END IF
			      END IF
         END IF
         
         DISPLAY ma_tela[pa_curr].em_analise   TO s_itens[sc_curr].em_analise
		     DISPLAY ma_tela[pa_curr].ies_conforme TO s_itens[sc_curr].ies_conforme
             
      ON KEY (control-z)
         CALL POL1113_popup()

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1113
   
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

#-----------------------------------#
 FUNCTION POL1113_verifica_analise()
#-----------------------------------#
						
		IF pr_tela[pa_curr].ies_texto <> 'S' then
		   IF pr_tela[pa_curr].val_especif_de = pr_tela[pa_curr].val_especif_ate THEN
	        IF POL1113_confere_result() = FALSE THEN
		 	       LET ma_tela[pa_curr].ies_conforme  = 'F'
			       ERROR "Valor fora do especificado para o item"
			    ELSE
             LET ma_tela[pa_curr].ies_conforme  = 'S'
          END IF
			 ELSE   
			    IF ma_tela[pa_curr].val_analise >= pr_tela[pa_curr].val_especif_de and 
             ma_tela[pa_curr].val_analise <= pr_tela[pa_curr].val_especif_ate THEN
				     LET ma_tela[pa_curr].ies_conforme  = 'S'
			    ELSE
			       LET ma_tela[pa_curr].ies_conforme  = 'F'
			       ERROR "Valor fora do especificado para o item"
          END IF
			 END IF
    ELSE
			LET p_existe = 0
			SELECT COUNT(*)
			INTO p_existe
			FROM tipo_caract_915
			WHERE cod_empresa = p_cod_empresa
			AND tip_analise = ma_tela[pa_curr].tip_analise
			AND val_caracter = ma_tela[pa_curr].val_analise
			IF p_existe > 0  THEN	
			ELSE
				RETURN FALSE
			END IF 
			
			LET p_tem_val_ana = 0
			SELECT COUNT(*)
			INTO p_tem_val_ana
			FROM espec_carac_915
			WHERE cod_empresa = p_cod_empresa
			AND cod_item    = mr_tela.cod_item
			AND tip_analise = ma_tela[pa_curr].tip_analise
			AND val_caracter = ma_tela[pa_curr].val_analise			
						
						
			IF p_tem_val_ana = 0  THEN
			   LET ma_tela[pa_curr].ies_conforme  = 'F'
			   ERROR "Valor fora do especificado para o item"
			ELSE
               LET ma_tela[pa_curr].ies_conforme  = 'S'
			END IF 
		
		END IF
			
			
			
    LET ma_tela[pa_curr].em_analise = 'N'
	
    RETURN TRUE 

END FUNCTION

#-----------------------------------#
 FUNCTION POL1113_confere_result()
#-----------------------------------#
                  IF pr_tela[pa_curr].tipo_valor = '>' THEN
                     IF ma_tela[pa_curr].val_analise <= pr_tela[pa_curr].val_especif_de THEN
                        RETURN FALSE
                     END IF
                  ELSE
                     IF pr_tela[pa_curr].tipo_valor = '>=' THEN
                        IF ma_tela[pa_curr].val_analise < pr_tela[pa_curr].val_especif_de THEN
                           RETURN FALSE
                        END IF
                     ELSE
                        IF pr_tela[pa_curr].tipo_valor = '<=' THEN
                           IF ma_tela[pa_curr].val_analise > pr_tela[pa_curr].val_especif_de THEN
                              RETURN FALSE
                           END IF
                        ELSE
                            IF pr_tela[pa_curr].tipo_valor = '<' THEN
                              IF ma_tela[pa_curr].val_analise >= pr_tela[pa_curr].val_especif_de THEN
                                 RETURN FALSE
                              END IF
                            ELSE
                              IF pr_tela[pa_curr].tipo_valor = '<>' THEN
                                 IF ma_tela[pa_curr].val_analise = pr_tela[pa_curr].val_especif_de THEN
                                    RETURN FALSE
								 END IF	
							  ELSE
							     IF pr_tela[pa_curr].tipo_valor = '=' THEN
                                    IF ma_tela[pa_curr].val_analise <> pr_tela[pa_curr].val_especif_de THEN
                                       RETURN FALSE
									END IF	
								 END IF	
                              END IF
                            END IF     
                        END IF
                     END IF
                  END IF

    RETURN TRUE 

END FUNCTION
				  
#-----------------------------#
 FUNCTION POL1113_grava_dados()
#-----------------------------#

   let p_mensagem = ''
   LET p_houve_erro = FALSE
   IF mr_tela.identif_estoque IS NULL THEN
      LET mr_tela.identif_estoque = '0'
   END IF
   
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
    INSERT INTO analise_mest_915 
         VALUES (
         p_cod_empresa,
         mr_tela.cod_item,        
         mr_tela.dat_analise,
         mr_tela.lote_tanque,
         mr_tela.num_pa,
				 mr_tela.qtd_lote,
				 mr_tela.qtd_pa,
				 mr_tela.ies_liberado,
				 mr_tela.nom_usuario,            
         mr_tela.identif_estoque)
         
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE
            CALL log003_err_sql("INCLUSAO","analise_mest_915")
            CALL log085_transacao("ROLLBACK")
         END IF

   FOR w_i = 1 TO 1000
      IF ma_tela[w_i].tip_analise IS NOT NULL THEN
         
         let p_txt_tip = ma_tela[w_i].tip_analise
         let p_txt_val = ma_tela[w_i].val_analise
         LET p_item = mr_tela.cod_item
         LET p_num_pa = mr_tela.num_pa
         SELECT unidade
         INTO p_unidade 
         FROM especific_915
         WHERE cod_empresa = p_cod_empresa
         AND tip_analise = p_txt_tip
         AND cod_item    = p_item
         AND cod_cliente IS NULL
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_unidade = ''
         END IF
         
         
         let p_mensagem = p_mensagem CLIPPED, ' / Tp: ',p_txt_tip CLIPPED, ' valor: ', p_txt_val CLIPPED
         INSERT INTO analise_915 
         VALUES (p_cod_empresa,
                 mr_tela.cod_item,        
                 mr_tela.dat_analise,
                 mr_tela.lote_tanque,
                 ma_tela[w_i].tip_analise, 
                 p_num_pa,
                 ma_tela[w_i].metodo,
				         pr_tela[w_i].val_especif_de,
                 pr_tela[w_i].val_especif_ate,
                 ma_tela[w_i].em_analise,
                 ma_tela[w_i].val_analise,
                 p_user, 
                 '',
                 '',
                 p_unidade,
				         ma_tela[w_i].ies_conforme,
				         ma_tela[w_i].ies_obrigatoria,
				         mr_tela.identif_estoque)                
         
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE
            CALL log003_err_sql("INCLUSAO","analise_915")
            CALL log085_transacao("ROLLBACK")
            EXIT FOR
         END IF
      END IF
   END FOR
   
   
    IF not p_houve_erro THEN
      let p_operacao = 'INCLUIU'
      call pol1113_grava_audit()
    end if

    IF not p_houve_erro THEN
      let p_operacao = 'INCLUIU'
      call pol1113_grava_audit()
    end if
 
   IF p_houve_erro = FALSE THEN
      MESSAGE "Inclus�o Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      CALL log085_transacao("COMMIT")
      LET p_ies_cons = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")
      CLEAR FORM
   END IF    
   
        
END FUNCTION


#----------------------------#
FUNCTION pol1113_grava_audit()
#----------------------------#
   
   select max(id_registro)
     into p_id_registro
     from analise_audit_915
    where cod_empresa = p_cod_empresa

   if p_id_registro is null then
      let p_id_registro = 1
   else
      let p_id_registro = p_id_registro + 1
   end if    
   
   let p_dat_atual = TODAY

   
   INSERT INTO analise_audit_915
         VALUES (p_id_registro,
                 p_cod_empresa,
                 mr_tela.cod_item,  
                 mr_tela.lote_tanque,
                 p_cod_familia,      
                 p_dat_atual,
                 mr_tela.num_pa,
                 p_user,
                 p_operacao,
                 p_mensagem)
   
   if status <> 0 then
      call log003_err_sql('Inserindo', 'analise_audit_915')
      let p_houve_erro = true
   end if
   
end FUNCTION

#------------------------#
 FUNCTION pol1113_popcon()
#------------------------#

   DEFINE p_codigo CHAR(30)

   CASE
   
      WHEN INFIELD(identif_estoque)
         LET p_codigo = pol1113_sel_ident()
         CALL log006_exibe_teclas("01 02 07", p_versao)
         
         CURRENT WINDOW IS w_POL1113
         
         IF p_codigo IS not NULL THEN
            DISPLAY p_codigo TO identif_estoque
         END IF
                   
   END CASE 

END FUNCTION 

#----------------------------#
 FUNCTION pol1113_sel_ident()#
#----------------------------#

   DEFINE pr_identif  ARRAY[2000] OF RECORD
          identif_estoque  LIKE wms_identif_estoque.identif_estoque,
          cod_item         LIKE item.cod_item,
          den_item_reduz   LIKE item.den_item_reduz,
          num_lote         LIKE estoque_lote.num_lote
   END RECORD   
   
   INITIALIZE p_nom_tela, pr_tipo TO NULL
   CALL log130_procura_caminho("pol1113b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1113b AT 8,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_ident CURSOR FOR
    SELECT DISTINCT
           a.identif_estoque,
           a.cod_item,
           b.den_item_reduz,
           a.lote_tanque
      FROM analise_mest_915 a,
           item b
     WHERE a.cod_empresa = p_cod_empresa
       AND b.cod_empresa = a.cod_empresa
       AND a.cod_item = b.cod_item

   FOREACH cq_ident INTO 
      pr_identif[p_ind].identif_estoque,   
      pr_identif[p_ind].cod_item,      
      pr_identif[p_ind].den_item_reduz,
      pr_identif[p_ind].num_lote      

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ident')
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
   
   DISPLAY ARRAY pr_identif TO sr_identif.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol1113b
   
   IF NOT INT_FLAG THEN
      RETURN pr_identif[p_ind].identif_estoque 
   ELSE
      RETURN ''
   END IF
   
END FUNCTION

#-----------------------#
 FUNCTION POL1113_popup()
#-----------------------#
   DEFINE z_ind  SMALLINT

   DEFINE pr_lote ARRAY[150] OF RECORD
      val_caracter decimal(10,4),
      resultado    char(45)
   END RECORD
   

   CASE
      WHEN infield(cod_item)
         CALL log009_popup(9,13,"ITEM ANALISE","item_915","cod_item_analise",
                                "den_item_portugues","POL1118","S","")
            RETURNING mr_tela.cod_item

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1113
         IF mr_tela.cod_item IS NOT NULL THEN
            DISPLAY mr_tela.cod_item TO cod_item
            CALL POL1113_verifica_item() RETURNING p_status
         END IF
       
       WHEN infield(identif_estoque)
          CALL pol1113_exibe_identif() 
          CALL log006_exibe_teclas("01 02 07", p_versao)

           
   END CASE
   
   CASE 
   	WHEN infield(val_analise)
   		IF pr_tela[pa_curr].ies_texto = 'S' THEN 
				SELECT COUNT(val_caracter)
				INTO z_ind 
				FROM espec_carac_915 e
						WHERE e.cod_empresa = p_cod_empresa
						AND e.tip_analise = ma_tela[pa_curr].tip_analise
						AND e.cod_cliente IS NULL
						
      	IF z_ind = 0 THEN 
					LET z_ind = 1
   				CALL log006_exibe_teclas("01",p_versao)
      		INITIALIZE p_nom_tela TO NULL
   				CALL log130_procura_caminho("POL11131") RETURNING p_nom_tela
      		LET p_nom_tela = p_nom_tela CLIPPED
      		OPEN WINDOW w_pol11131 AT 6,5 WITH FORM p_nom_tela
      		ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)           
					DECLARE cq_lote2 CURSOR FOR
					SELECT  val_caracter, den_caracter 
					FROM tipo_caract_915
					WHERE cod_empresa = p_cod_empresa
					AND tip_analise = ma_tela[pa_curr].tip_analise
					AND cod_cliente IS NULL
       
		  		FOREACH cq_lote2 into 
						pr_lote[z_ind].val_caracter,
						pr_lote[z_ind].resultado
      
						let z_ind = z_ind + 1

      		END FOREACH

   				CALL SET_COUNT(z_ind - 1) 
   				DISPLAY ARRAY pr_lote TO sr_lote.*
   
   				LET z_ind = ARR_CURR()
   				CLOSE WINDOW w_pol11131

					if status <> 0 then
						call log003_err_sql('Lendo','tipo_caract_915')
						CLOSE WINDOW w_pol11131
						RETURN FALSE
					end if
   				IF INT_FLAG THEN
      			RETURN FALSE
   				End if

   			CALL log006_exibe_teclas("01 02 07",p_versao)
   			CURRENT WINDOW IS w_POL1113		
		
   			DISPLAY pr_lote[z_ind].val_caracter TO s_itens[sc_curr].val_analise
   			LET ma_tela[pa_curr].val_analise = pr_lote[z_ind].val_caracter
   			RETURN TRUE
   		ELSE
					LET z_ind = 1
   				CALL log006_exibe_teclas("01",p_versao)
      		INITIALIZE p_nom_tela TO NULL
   				CALL log130_procura_caminho("POL11131") RETURNING p_nom_tela
      		LET p_nom_tela = p_nom_tela CLIPPED
      		OPEN WINDOW w_pol11131 AT 6,5 WITH FORM p_nom_tela
      		ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)           
					DECLARE cq_lote2 CURSOR FOR
				SELECT  t.val_caracter, t.den_caracter 
					FROM tipo_caract_915 t
					WHERE t.cod_empresa = p_cod_empresa
					AND t.tip_analise = ma_tela[pa_curr].tip_analise
					AND t.cod_cliente IS NULL
					AND t.val_caracter IN (SELECT val_caracter FROM espec_carac_915 e
						WHERE e.cod_empresa = t.cod_empresa
						AND e.tip_analise = t.tip_analise
						AND e.cod_cliente IS NULL)
       
		  		FOREACH cq_lote2 into 
						pr_lote[z_ind].val_caracter,
						pr_lote[z_ind].resultado
      
						let z_ind = z_ind + 1

      		END FOREACH

   				CALL SET_COUNT(z_ind - 1) 
   				DISPLAY ARRAY pr_lote TO sr_lote.*
   
   				LET z_ind = ARR_CURR()
   				CLOSE WINDOW w_pol11131

					if status <> 0 then
						call log003_err_sql('Lendo','tipo_caract_915')
						CLOSE WINDOW w_pol11131
						RETURN FALSE
					end if
   				IF INT_FLAG THEN
      			RETURN FALSE
   				End if

   			CALL log006_exibe_teclas("01 02 07",p_versao)
   			CURRENT WINDOW IS w_POL1113		
		
   			DISPLAY pr_lote[z_ind].val_caracter TO s_itens[sc_curr].val_analise
   			LET ma_tela[pa_curr].val_analise = pr_lote[z_ind].val_caracter
   			RETURN TRUE
   			
   		END IF
   		
    END IF 	
    
   END CASE
         


END FUNCTION

#--------------------------------#
 FUNCTION pol1113_exibe_identif()#
#--------------------------------#

   DEFINE pr_identif       ARRAY[2000] OF RECORD
          identif_estoque  LIKE wms_identif_estoque.identif_estoque,
          tip_estoque      LIKE wms_tip_estoque_restricao.tip_estoque,
          restricao        LIKE wms_tip_estoque_restricao.restricao,
          qtd_origem       LIKE wms_identif_estoque.qtd_origem,
          item             LIKE wms_identif_estoque.item
   END RECORD
   
   DEFINE p_ind, s_ind     INTEGER,
          p_query          CHAR(1000)
   
   
   INITIALIZE p_nom_tela, pr_identif TO NULL
   CALL log130_procura_caminho("pol1113a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1113a AT 8,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
   
   LET p_query = 
    "SELECT a.identif_estoque, a.tip_estoque, a.restricao, a.qtd_origem, a.item ",
    "  FROM wms_identif_estoque a, tip_estoque_915 b ",
    " WHERE a.empresa = '",p_cod_empresa,"' ", 
    "   AND b.cod_empresa = a.empresa ",
    "   AND b.tip_estoq_insp = a.tip_estoque ",
    "   AND b.restricao_insp = a.restricao "
   
   IF mr_tela.cod_item IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.item = '",mr_tela.cod_item,"' "
   END IF
   
   LET p_query = p_query CLIPPED, " ORDER BY a.item, a.identif_estoque "
   
   PREPARE v_query FROM p_query 
   
   DECLARE cq_identif CURSOR FOR v_query

   FOREACH cq_identif INTO 
      pr_identif[p_ind].identif_estoque, 
      pr_identif[p_ind].tip_estoque,    
      pr_identif[p_ind].restricao,      
      pr_identif[p_ind].qtd_origem,      
      pr_identif[p_ind].item           

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_identif')
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
   
   DISPLAY ARRAY pr_identif TO sr_identif.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol1113a
   
   IF NOT INT_FLAG THEN
      LET mr_tela.identif_estoque = pr_identif[p_ind].identif_estoque
      DISPLAY mr_tela.identif_estoque TO identif_estoque
   END IF
   
END FUNCTION

#----------------------------#
 FUNCTION POL1113_pega_itens()
#----------------------------#
   DEFINE l_ind          SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1113
   INITIALIZE ma_tela, pr_tela TO NULL
   CLEAR FORM
   
     SELECT 
      qtd_lote,
			qtd_pa, 
			ies_liberado,
			nom_usuario 

	 INTO 	  
		  	mr_tela.qtd_lote,
			  mr_tela.qtd_pa,
			  mr_tela.ies_liberado,
			  mr_tela.nom_usuario 
     FROM analise_mest_915 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND lote_tanque = mr_tela.lote_tanque
      AND dat_analise = mr_tela.dat_analise
      AND num_pa 	  = mr_tela.num_pa
	    AND identif_estoque = mr_tela.identif_estoque
	  
   LET l_ind = 1
   
   DECLARE c_item CURSOR WITH HOLD FOR
   SELECT tip_analise,
          metodo, 
          em_analise,
          val_analise,
		  ies_obrigatoria,
		  ies_conforme
     FROM analise_915 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND lote_tanque = mr_tela.lote_tanque
      AND dat_analise = mr_tela.dat_analise
      AND num_pa 	  = mr_tela.num_pa
	    AND identif_estoque = mr_tela.identif_estoque

    ORDER BY tip_analise 

   FOREACH c_item INTO ma_tela[l_ind].tip_analise,
                       ma_tela[l_ind].metodo,   
                       ma_tela[l_ind].em_analise,     
                       ma_tela[l_ind].val_analise,
					             ma_tela[l_ind].ies_obrigatoria,
					             ma_tela[l_ind].ies_conforme



    SELECT a.val_especif_de, 
           a.val_especif_ate, 
		   a.tipo_valor,
           b.den_analise_port, 
           b.ies_texto
      INTO pr_tela[l_ind].val_especif_de,
           pr_tela[l_ind].val_especif_ate,
		   pr_tela[l_ind].tipo_valor,
           ma_tela[l_ind].den_analise,
           pr_tela[l_ind].ies_texto
      FROM especific_915 a, it_analise_915 b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.cod_item    = mr_tela.cod_item
       AND a.cod_cliente IS NULL 
       AND a.tip_analise = b.tip_analise
       AND b.tip_analise = ma_tela[l_ind].tip_analise
       AND b.cod_empresa = a.cod_empresa

      LET l_ind = l_ind + 1

      IF l_ind > 1000 THEN
         CALL log0030_mensagem('Limite de itens ultrapassou','info')
         EXIT FOREACH
      END IF

   END FOREACH 

   IF l_ind = 1 THEN
      RETURN FALSE
   END IF
 
   DISPLAY BY NAME mr_tela.*
   DISPLAY p_cod_empresa TO cod_empresa
   CALL POL1113_verifica_item() RETURNING p_status

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
 FUNCTION POL1113_consulta()
#--------------------------#
   DEFINE where_clause CHAR(300)  
   
   CLEAR FORM
   LET INT_FLAG = FALSE
   DISPLAY p_cod_empresa TO cod_empresa
 
   CONSTRUCT BY NAME where_clause ON analise_mest_915.identif_estoque,
                                     analise_mest_915.cod_item,
                                     analise_mest_915.lote_tanque,
                                     analise_mest_915.num_pa,
									 analise_915.dat_analise
	ON KEY (control-z)
      CALL pol1113_popcon()
      
	END CONSTRUCT
                                     
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1113
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Consulta Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET sql_stmt = " SELECT DISTINCT identif_estoque, cod_item, lote_tanque, num_pa, dat_analise", 
                  " FROM analise_mest_915 ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  " AND ", where_clause CLIPPED,                 
                  " ORDER BY cod_item, lote_tanque, dat_analise"

   PREPARE var_query1 FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query1
   OPEN cq_padrao
   FETCH cq_padrao 
         INTO mr_tela.identif_estoque,
              mr_tela.cod_item,
              mr_tela.lote_tanque,
              mr_tela.num_pa,
              mr_tela.dat_analise
              
			  
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa n�o Encontrados"
      CLEAR FORM 
      LET p_ies_cons = FALSE
      RETURN FALSE  
   ELSE 
      IF POL1113_pega_itens() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE  
      END IF
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION POL1113_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_telat.* = mr_tela.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
              mr_tela.identif_estoque,
              mr_tela.cod_item,
              mr_tela.lote_tanque,
              mr_tela.num_pa,
              mr_tela.dat_analise
              
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
              mr_tela.identif_estoque,
              mr_tela.cod_item,
              mr_tela.lote_tanque,
              mr_tela.num_pa,
              mr_tela.dat_analise
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "N�o existem mais itens nesta Dire��o"
            LET mr_tela.* = mr_telat.* 
            EXIT WHILE
         END IF
          
         IF POL1113_pega_itens() THEN
            LET p_ies_cons = TRUE
            EXIT WHILE
         ELSE
            CLEAR FORM
         END IF
      END WHILE
   ELSE
      ERROR "N�o Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 

#-----------------------------#
 FUNCTION POL1113_modificacao()
#-----------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_POL1113

   LET p_houve_erro = FALSE
   LET INT_FLAG = FALSE

   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   IF POL1113_entrada_item("MODIFICACAO") THEN
      DELETE FROM analise_915 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND dat_analise = mr_tela.dat_analise
         AND lote_tanque = mr_tela.lote_tanque
         AND num_pa = mr_tela.num_pa
         AND identif_estoque = mr_tela.identif_estoque
   
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK 
         CALL log003_err_sql("EXCLUSAO","analise_915")
         RETURN
      END IF
      FOR w_i = 1 TO 1000
         IF ma_tela[w_i].tip_analise IS NOT NULL THEN
            let p_txt_tip = ma_tela[w_i].tip_analise
            let p_txt_val = ma_tela[w_i].val_analise
            
            SELECT unidade
            INTO p_unidade 
            FROM especific_915
            WHERE cod_empresa = p_cod_empresa
            AND tip_analise = p_txt_tip
            AND cod_item    = mr_tela.cod_item
            AND cod_cliente IS NULL
            IF SQLCA.SQLCODE <> 0 THEN 
               LET p_unidade = ''
            END IF
            
            let p_mensagem = p_mensagem CLIPPED, ' / Tp: ',p_txt_tip CLIPPED, ' valor: ', p_txt_val CLIPPED
            INSERT INTO analise_915 
            VALUES (p_cod_empresa,
                    mr_tela.cod_item,        
                    mr_tela.dat_analise,
                    mr_tela.lote_tanque,
                    ma_tela[w_i].tip_analise, 
                    mr_tela.num_pa,
                    ma_tela[w_i].metodo,
					          pr_tela[w_i].val_especif_de,
                    pr_tela[w_i].val_especif_ate,
                    ma_tela[w_i].em_analise,
                    ma_tela[w_i].val_analise,
                    p_user,'','',p_unidade,
					          ma_tela[w_i].ies_conforme,
					         ma_tela[w_i].ies_obrigatoria,
					         mr_tela.identif_estoque)                
            IF SQLCA.SQLCODE <> 0 THEN 
               LET p_houve_erro = TRUE
               CALL log003_err_sql("INCLUSAO","analise_915")
               EXIT FOR
            END IF
         END IF
      END FOR
   ELSE
      LET p_houve_erro = TRUE 
   END IF	

   IF not p_houve_erro THEN
      let p_operacao = 'ALTEROU'
      call pol1113_grava_audit()
   end if
      
   IF p_houve_erro THEN
      CALL log085_transacao("ROLLBACK")
      ERROR "Modifica��o Cancelada." 
   ELSE
      CALL log085_transacao("COMMIT")
      ERROR "Modifica��o Efetuada com Sucesso" 
   END IF

END FUNCTION   

#--------------------------#
 FUNCTION POL1113_exclusao()
#--------------------------#

   IF NOT log004_confirm(21,45) THEN
      ERROR 'Opera��o cancelada.'
      RETURN
   END IF
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1113
   LET p_houve_erro = FALSE

   SELECT count(m.num_laudo)
   INTO p_qtd_laudo 
   FROM laudo_mest_915 m
   WHERE m.cod_empresa = p_cod_empresa
   AND m.num_pa        = mr_tela.num_pa
   AND m.cod_item      = mr_tela.cod_item
   AND m.lote_tanque   = mr_tela.lote_tanque


  
   IF p_qtd_laudo > 0 THEN
      LET p_houve_erro = TRUE
   ELSE
      LET p_houve_erro = FALSE
   END IF

   
   IF p_houve_erro THEN
      ERROR 'analise n�o pode ser exclu�da pois � utilizada em certificado!'
   ELSE
   		CALL log085_transacao("BEGIN")
 
			DELETE FROM analise_915 
			WHERE cod_empresa = p_cod_empresa
			 AND cod_item    = mr_tela.cod_item
			 AND dat_analise = mr_tela.dat_analise
			 AND lote_tanque = mr_tela.lote_tanque
			 AND num_pa      = mr_tela.num_pa
       AND identif_estoque = mr_tela.identif_estoque

			IF SQLCA.SQLCODE <> 0 THEN
				CALL log003_err_sql("EXCLUSAO","analise_915")
				LET p_houve_erro = TRUE 
			END IF
			DELETE FROM analise_mest_915 
			WHERE cod_empresa = p_cod_empresa
			 AND cod_item    = mr_tela.cod_item
			 AND dat_analise = mr_tela.dat_analise
			 AND lote_tanque = mr_tela.lote_tanque
			 AND num_pa      = mr_tela.num_pa
       AND identif_estoque = mr_tela.identif_estoque

			IF SQLCA.SQLCODE <> 0 THEN
				CALL log003_err_sql("EXCLUSAO","analise_mest_915")
				LET p_houve_erro = TRUE 
			END IF

   		IF not p_houve_erro THEN
      	let p_operacao = 'EXCLUIU'
      	LET p_mensagem = ''
      	call pol1113_grava_audit()
   		end if
   		IF p_houve_erro THEN
      	CALL log085_transacao("ROLLBACK")
      	ERROR 'Opera��o cancelada!'
      ELSE
        CALL log085_transacao("COMMIT")
        INITIALIZE mr_tela.* TO NULL
        CLEAR FORM
        ERROR 'Opera��o efetudada com sucesso!'
     END IF
   END IF
   
    
END FUNCTION  

#--------------------------#
 FUNCTION POL1113_libera()
#--------------------------# 
		   
	INITIALIZE 	 p_estoque_trans, 
	             p_estoque_trans_end, 
				 p_estoque_lote_ender  TO NULL
			     

	LET l_movito_pen   =  mr_tela.qtd_pa
	LET l_achou_pend   = 0 
	INITIALIZE  p_cod_operacao TO NULL  

  IF NOT pol1113_verif_possib() THEN
     RETURN FALSE
  END IF

  IF NOT pol1113_efetua_transfer() THEN
     RETURN FALSE
  END IF
  
  RETURN TRUE

END FUNCTION


#------------------------------#
FUNCTION pol1113_verif_possib()
#------------------------------#
   
   DEFINE p_max_pa       INTEGER,
          p_endereco     LIKE estoque_lote_ender.endereco,
          p_inventario   LIKE wms_endereco.inventario
                 
   IF mr_tela.identif_estoque IS NULL OR
       mr_tela.identif_estoque = 0 THEN
      SELECT MAX(num_pa)
        INTO p_max_pa
        FROM analise_mest_915
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND lote_tanque = mr_tela.lote_tanque
   ELSE
      SELECT MAX(num_pa)
        INTO p_max_pa
        FROM analise_mest_915
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_tela.cod_item
         AND lote_tanque = mr_tela.lote_tanque
         AND identif_estoque = mr_tela.identif_estoque
   END IF
   
   IF STATUS <> 0 OR p_max_pa is NULL THEN
      LET p_max_pa = 0
   END IF
   
   IF p_max_pa > mr_tela.num_pa THEN
      LET p_msg = 'Somente a �ltima PA\n pode ser liberada.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
	  	
	LET l_achou_pend   = 0 
	SELECT count(*) 
    INTO l_achou_pend	   
     FROM analise_915 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND lote_tanque = mr_tela.lote_tanque
      AND dat_analise = mr_tela.dat_analise
      AND num_pa 	  = mr_tela.num_pa
	  AND ies_obrigatoria = 'S'
	  AND ies_conforme    = 'N'
	  
	IF l_achou_pend > 0 THEN
      ERROR 'Libera��o n�o permitida, existem analises obrigat�rias n�o realizadas !'
  	  RETURN FALSE
   END IF
	      
   SELECT cod_local_insp  
     INTO p_cod_local_insp
     FROM item 
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = mr_tela.cod_item	  	  

		IF STATUS <> 0 THEN
       CALL log003_err_sql("SELECT","item")
       RETURN FALSE
		END IF	
 
	SELECT * 
	  INTO p_estoque_lote.*
	  FROM estoque_lote 
	 WHERE cod_empresa = p_cod_empresa
  	 AND num_lote = mr_tela.lote_tanque
	   AND cod_item = mr_tela.cod_item 
	   AND ies_situa_qtd  = 'I'
	   AND qtd_saldo > 0
	   #AND cod_local = p_cod_local_insp
									
	IF STATUS = 100 THEN
	   LET p_estoque_lote.qtd_saldo = 0  
	ELSE
		IF STATUS <> 0 THEN
         	CALL log003_err_sql("LEITURA 2","estoque_lote")
         	RETURN FALSE
		END IF	
    END IF								
									
	IF p_estoque_lote.qtd_saldo > 0 THEN
	ELSE
     ERROR "Lote informado n�o existe na tab estoque_lote "
	   RETURN FALSE
  END IF 
	
	IF mr_tela.qtd_pa > p_estoque_lote.qtd_saldo THEN
       ERROR 'Quantidade a inspecionar n�o pode ser maior que lote no estoque'
	     RETURN FALSE
  END IF		
	
	LET l_qtd_saldo_ender   = 0 
	
	IF mr_tela.identif_estoque IS NULL THEN
	   SELECT SUM(qtd_saldo) 
			 INTO l_qtd_saldo_ender
			 FROM estoque_lote_ender
			WHERE cod_empresa = p_cod_empresa
			  AND num_lote = mr_tela.lote_tanque
				AND cod_item = mr_tela.cod_item 
				AND ies_situa_qtd  = 'I'
				AND qtd_saldo > 0
				#AND cod_local = p_cod_local_insp
   ELSE
	   SELECT qtd_saldo, endereco
			 INTO l_qtd_saldo_ender, p_endereco
			 FROM estoque_lote_ender
			WHERE cod_empresa = p_cod_empresa
			  AND num_lote = mr_tela.lote_tanque
				AND cod_item = mr_tela.cod_item 
				AND ies_situa_qtd  = 'I'
				AND qtd_saldo > 0
				#AND cod_local = p_cod_local_insp
   			AND identif_estoque = mr_tela.identif_estoque
	END IF								    
  									
	IF l_qtd_saldo_ender > 0 THEN
	ELSE
       ERROR "Lote informado n�o existe na tab estoque_ender_ender "
	   RETURN FALSE
  END IF 
	
	IF mr_tela.qtd_pa > l_qtd_saldo_ender THEN
     ERROR 'Quantidade a inspecionar n�o pode ser maior que lote_ender no estoque'
	   RETURN FALSE
  END IF

  SELECT inventario 
    INTO p_inventario
    FROM wms_endereco
   WHERE empresa =  p_cod_empresa
     AND endereco = p_endereco
  
  if STATUS = 100 THEN
     LET p_inventario = 'N'
  else
     if STATUS <> 0 THEN
        CALL log003_err_sql('select','wms_endereco')
        RETURN FALSE
     end if
  end if
  
  IF p_inventario = 'S' THEN
     ERROR 'item/local/identifica��o/endere�o est� em invent�rio e n�o pode ser liberado'
     RETURN FALSE
  END IF
  
   LET l_achou_nao_conf   = 0 
	
   SELECT count(*) 
     INTO l_achou_nao_conf   
     FROM analise_915 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND lote_tanque = mr_tela.lote_tanque
      AND num_pa 	    = mr_tela.num_pa
      AND identif_estoque = mr_tela.identif_estoque
	    AND ies_obrigatoria = 'S'
	    AND ies_conforme    = 'F'

   IF l_achou_nao_conf > 0 THEN
	    LET l_msg = 'Existem analises liberativas fora\n da especifica��o lote ser� rejeitado.\n',
	                'Deseja continuar e refugar o lote?'
      LET l_resultado = 'R'
	 ELSE
		  LET l_msg = 'Lote conforme e ser� liberado, confirma opera��o?'
	    LET l_resultado = 'L'
   END IF
   
   IF NOT log0040_confirm(18,35,l_msg) THEN
	    RETURN FALSE
   END IF 
	
	RETURN TRUE

END FUNCTION
	                                                  	
#--------------------------------#
FUNCTION pol1113_efetua_transfer()
#--------------------------------#

  	IF mr_tela.identif_estoque IS NOT NULL THEN
	     LET p_identif_estoque = mr_tela.identif_estoque
       IF NOT pol1113_le_tip_estoq() THEN
          RETURN FALSE
       END IF
	  END IF

   IF NOT pol1113_atu_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT pol1113_atu_estoq_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol1113_atu_estoq_lote_ender() THEN
      RETURN FALSE
   END IF

	IF mr_tela.identif_estoque IS NOT NULL THEN
	   IF NOT pol1113_atuali_wms() THEN
	      RETURN FALSE
	   END IF
	END IF
	
	UPDATE analise_mest_915  
	   SET ies_liberado = l_resultado
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_tela.cod_item
      AND lote_tanque = mr_tela.lote_tanque
      AND num_pa      = mr_tela.num_pa
      AND identif_estoque = mr_tela.identif_estoque

	
  IF STATUS <> 0 THEN 
		LET p_houve_erro = TRUE
		CALL log003_err_sql("UPDATE","ANALISE_MEST_915")
		RETURN FALSE
  END IF
    
	LET mr_tela.ies_liberado = l_resultado
	DISPLAY mr_tela.ies_liberado TO ies_liberado
	
	CALL log0030_mensagem('Libera��o efetuada c/ sucesso','info')

   RETURN TRUE

END FUNCTION      

#----------------------------#
FUNCTION pol1113_atu_estoque()
#----------------------------#
	
   IF l_resultado   = 'L'   THEN
 			UPDATE estoque
 			   SET qtd_liberada = qtd_liberada + mr_tela.qtd_pa,
             qtd_impedida = qtd_impedida - mr_tela.qtd_pa
			 WHERE cod_empresa = p_cod_empresa
			   AND cod_item = mr_tela.cod_item
	
      IF STATUS <> 0 THEN 
				LET p_houve_erro = TRUE
				CALL log003_err_sql("UPDATE","ESTOQUE")
				RETURN FALSE
		  END IF
		ELSE
		 	UPDATE estoque
			   SET qtd_rejeitada = qtd_rejeitada + mr_tela.qtd_pa,
             qtd_impedida = qtd_impedida - mr_tela.qtd_pa
			WHERE cod_empresa = p_cod_empresa
			AND cod_item = mr_tela.cod_item
	
     IF SQLCA.SQLCODE <> 0 THEN 
				LET p_houve_erro = TRUE
				CALL log003_err_sql("UPDATE","ESTOQUE")
				RETURN FALSE
		 END IF
	END IF 
   
   RETURN TRUE

END FUNCTION
	
#-------------------------------#
FUNCTION pol1113_atu_estoq_lote()
#-------------------------------#
	
   IF p_estoque_lote.qtd_saldo > mr_tela.qtd_pa THEN
      UPDATE estoque_lote
		    	SET qtd_saldo = qtd_saldo - mr_tela.qtd_pa
		   WHERE cod_empresa = p_cod_empresa
		     AND num_transac 	= p_estoque_lote.num_transac
   ELSE
      DELETE FROM estoque_lote
		   WHERE cod_empresa = p_cod_empresa
		     AND num_transac 	= p_estoque_lote.num_transac
   END IF
	
   IF STATUS <> 0 THEN 
  	  LET p_houve_erro = TRUE
		  CALL log003_err_sql("ATUALIZANDO","ESTOQUE_LOTE")
			RETURN FALSE
	 END IF
   
	 LET l_num_transac_up1 = 0 
	 
	 SELECT cod_local_estoq
	   INTO p_cod_local_estoq
	   FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = mr_tela.cod_item

   IF STATUS <> 0 THEN 
  	  LET p_houve_erro = TRUE
		  CALL log003_err_sql("select","item:2")
			RETURN FALSE
	 END IF
	 
	 SELECT num_transac 
		 INTO l_num_transac_up1
		 FROM estoque_lote
		WHERE cod_empresa = p_cod_empresa
		  AND num_lote = mr_tela.lote_tanque
			AND cod_item = mr_tela.cod_item 
			AND ies_situa_qtd  = p_ies_situa
			AND qtd_saldo > 0
			AND cod_local = p_cod_local_estoq

				
		IF STATUS = 0 THEN 
			 UPDATE estoque_lote
		  	  SET qtd_saldo = qtd_saldo + mr_tela.qtd_pa
				WHERE cod_empresa = p_cod_empresa
				  AND num_transac 	= l_num_transac_up1
		
			 IF SQLCA.SQLCODE <> 0 THEN 
					LET p_houve_erro = TRUE
					CALL log003_err_sql("UPDATE 2","ESTOQUE_LOTE")
					RETURN FALSE
			 END IF
		ELSE
			 LET p_estoque_lote.ies_situa_qtd = p_ies_situa
			 LET p_estoque_lote.qtd_saldo     = mr_tela.qtd_pa 
			 LET p_estoque_lote.cod_local = p_cod_local_estoq
			 LET p_estoque_lote.num_transac   = 0
				   
			 INSERT INTO estoque_lote
						values(p_estoque_lote.*)
						
			 IF SQLCA.SQLCODE <> 0 THEN 
					LET p_houve_erro = TRUE
					CALL log003_err_sql("INSERT 2","ESTOQUE_LOTE")
					RETURN FALSE
		   END IF
		END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1113_le_operacao()
#----------------------------#

   SELECT val_parametro
     INTO p_oper_entrada
     FROM LOG_VAL_PARAMETRO 
    WHERE empresa = p_cod_empresa
      AND parametro = 'oper_ent_alter_tip_est_rest'

   IF STATUS <> 0 THEN 
		  CALL log003_err_sql("ATUALIZANDO","LOG_VAL_PARAMETRO")
			RETURN FALSE
	 END IF

   SELECT val_parametro
     INTO p_oper_saida
     FROM LOG_VAL_PARAMETRO 
    WHERE empresa = p_cod_empresa
      AND parametro = 'oper_sai_alter_tip_est_rest'

   IF STATUS <> 0 THEN 
		  CALL log003_err_sql("ATUALIZANDO","LOG_VAL_PARAMETRO")
			RETURN FALSE
	 END IF
	 
	 SELECT num_conta_credito
	   INTO p_conta_credito
	   FROM estoque_operac_ct
    WHERE cod_empresa = p_cod_empresa
      AND cod_operacao =  p_oper_entrada
   
   IF STATUS <> 0 THEN 
		  LET p_conta_credito = NULL
	 END IF

	 SELECT num_conta_debito
	   INTO p_conta_debito
	   FROM estoque_operac_ct
    WHERE cod_empresa = p_cod_empresa
      AND cod_operacao =  p_oper_saida
      
   IF STATUS <> 0 THEN 
		  LET p_conta_debito = NULL
	 END IF
 
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1113_atuali_inpecao()
#-------------------------------#

   IF p_estoque_lote_ender.qtd_saldo > l_movito THEN
      UPDATE estoque_lote_ender
		     SET qtd_saldo = qtd_saldo - l_movito 
		   WHERE cod_empresa = p_cod_empresa
		     AND num_transac 	= p_estoque_lote_ender.num_transac
   ELSE
      DELETE FROM estoque_lote_ender
		   WHERE cod_empresa = p_cod_empresa
		     AND num_transac 	= p_estoque_lote_ender.num_transac
   END IF
         
   IF STATUS <> 0 THEN 
			LET p_houve_erro = TRUE
			CALL log003_err_sql("UPDATE 2","ESTOQUE_LOTE_ENDER")
			RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1113_atuali_liberacao()#
#----------------------------------#

   LET l_num_transac_up = 0 
		
   SELECT num_transac 
		 INTO l_num_transac_up
		 FROM estoque_lote_ender
		WHERE cod_empresa = p_cod_empresa
		  AND num_lote = mr_tela.lote_tanque
			AND cod_item = mr_tela.cod_item 
			AND ies_situa_qtd  = p_ies_situa
			AND qtd_saldo > 0
			AND cod_local = p_cod_local_estoq
			AND comprimento = p_estoque_lote_ender.comprimento
			AND largura  = p_estoque_lote_ender.largura
			AND altura  = p_estoque_lote_ender.altura
			AND diametro  = p_estoque_lote_ender.diametro
      AND identif_estoque = mr_tela.identif_estoque

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('SELECT','estoque_lote_ender')
      RETURN FALSE
   END IF
   
   IF STATUS = 0 THEN 
			UPDATE estoque_lote_ender
		     SET qtd_saldo = qtd_saldo + l_movito 
			 WHERE cod_empresa = p_cod_empresa
				 AND num_transac 	= l_num_transac_up
   ELSE
			LET p_estoque_lote_ender.ies_situa_qtd = p_ies_situa
			LET p_estoque_lote_ender.qtd_saldo     = l_movito
			LET p_estoque_lote_ender.num_transac   = 0
			LET p_estoque_lote_ender.cod_local = p_cod_local_estoq
			   
			INSERT INTO estoque_lote_ender
			VALUES(p_estoque_lote_ender.*)

   END IF
   
   IF STATUS <> 0 THEN 
		  LET p_houve_erro = TRUE
			CALL log003_err_sql("ATUALIZANDO","ESTOQUE_LOTE_ENDER")
			RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   						
      
#-------------------------------------#
FUNCTION pol1113_atu_estoq_lote_ender()
#-------------------------------------#
    
    IF NOT pol1113_le_operacao() THEN
       RETURN FALSE
    END IF

    LET p_dat_hor = CURRENT

		LET l_msg = "SELECT * FROM estoque_lote_ender ",
				 " WHERE cod_empresa = '",p_cod_empresa,"' ",
				 " AND num_lote = '",mr_tela.lote_tanque,"' ",
				 " AND cod_item = '",mr_tela.cod_item,"' ",
				 " AND ies_situa_qtd  = 'I' ",
				 " AND qtd_saldo > 0 "

				 #" AND cod_local = '",p_cod_local_insp,"' "
	 
	 IF mr_tela.identif_estoque IS NOT NULL THEN
	    LET l_msg = l_msg CLIPPED, " AND identif_estoque = '",mr_tela.identif_estoque,"' "
	 END IF
	 
	 LET l_msg = l_msg CLIPPED, " ORDER BY  dat_hor_producao, dat_hor_validade "
	 
   PREPARE ender_query FROM l_msg 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','ender_query')
      RETURN FALSE
   END IF
   
	 DECLARE cq_transf_item CURSOR FOR ender_query
			
	 FOREACH cq_transf_item INTO p_estoque_lote_ender.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_transf_item')
         RETURN FALSE
      END IF
      
      LET p_cod_local_insp = p_estoque_lote_ender.cod_local
      
		  IF l_movito_pen = 0 THEN 
				EXIT FOREACH
			END IF 
	    
			IF l_movito_pen > p_estoque_lote_ender.qtd_saldo THEN 
				LET l_movito = p_estoque_lote_ender.qtd_saldo
				LET l_movito_pen = l_movito_pen - p_estoque_lote_ender.qtd_saldo
			ELSE
				LET l_movito     = l_movito_pen
				LET l_movito_pen = 0
			END IF 
			
			#IF NOT pol1113_atuali_inpecao() THEN
			#   RETURN FALSE
			#END IF

      DELETE FROM estoque_lote_ender
		   WHERE cod_empresa = p_cod_empresa
		     AND num_transac 	= p_estoque_lote_ender.num_transac

      LET p_cod_local_orig = p_cod_local_insp
      LET p_cod_local_dest = NULL
      LET p_num_lote_orig  = p_estoque_lote_ender.num_lote
      LET p_num_lote_dest  = NULL
      LET p_ies_situa_orig = p_estoque_lote_ender.ies_situa_qtd
      LET p_ies_situa_dest = NULL
      LET p_cod_operacao = p_oper_saida
      LET p_num_conta = p_conta_debito

			IF NOT pol1113_grava_movimento() THEN
			   RETURN FALSE
			END IF
			
			LET p_transac_i = l_num_transac

			IF NOT pol1113_atuali_liberacao() THEN
			   RETURN FALSE
			END IF

      LET p_cod_local_dest = p_cod_local_estoq
      LET p_cod_local_orig = NULL
      LET p_num_lote_dest  = p_estoque_lote_ender.num_lote
      LET p_num_lote_orig  = NULL
      LET p_ies_situa_dest = p_ies_situa
      LET p_ies_situa_orig = NULL
      LET p_cod_operacao = p_oper_entrada
      LET p_num_conta = p_conta_credito
					
			IF NOT pol1113_grava_movimento() THEN
			   RETURN FALSE
			END IF

			LET p_transac_l = l_num_transac

      INSERT INTO sup_mov_orig_dest (
        empresa, num_trans_origem, num_trans_destino, tip_relacionto) 
      VALUES(p_cod_empresa, p_transac_i, p_transac_l, '3')

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','sup_mov_orig_dest')
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION
   
#--------------------------------#
FUNCTION pol1113_grava_movimento()
#--------------------------------#

   INITIALIZE p_estoque_trans,
      p_estoque_trans_end   TO NULL

   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_empresa        = p_estoque_lote_ender.cod_empresa
   LET p_estoque_trans.cod_item           = p_estoque_lote_ender.cod_item
   LET p_estoque_trans.dat_movto          = TODAY
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = 'POL1113'
   LET p_estoque_trans.num_docum          = mr_tela.num_pa
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL   
   LET p_estoque_trans.qtd_movto          = l_movito
   LET p_estoque_trans.ies_sit_est_orig   = p_ies_situa_orig
   LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa_dest
   LET p_estoque_trans.cod_local_est_orig = p_cod_local_orig
   LET p_estoque_trans.cod_local_est_dest = p_cod_local_dest
   LET p_estoque_trans.num_lote_orig      = p_num_lote_orig
   LET p_estoque_trans.num_lote_dest      = p_num_lote_dest
   LET p_estoque_trans.ies_tip_movto      = 'N'
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME

   INSERT INTO estoque_trans VALUES (p_estoque_trans.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans')
     RETURN FALSE
   END IF

   LET l_num_transac = SQLCA.SQLERRD[2]

   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3
   LET p_estoque_trans_end.identif_estoque  = p_estoque_lote_ender.identif_estoque
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f 
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = " "
   LET p_estoque_trans_end.tex_reservado    = " "  
   LET p_estoque_trans_end.num_transac      = l_num_transac
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end')
     RETURN FALSE
   END IF

	 INSERT INTO estoque_auditoria (
	   cod_empresa, num_transac, nom_usuario, dat_hor_proces, num_programa) 
	 VALUES(p_cod_empresa, l_num_transac, p_user, p_dat_hor, p_estoque_trans.num_prog)
	      
   IF STATUS <> 0 THEN 
			CALL log003_err_sql("INSERT","estoque_auditoria")	
			RETURN FALSE 		
	 END IF
	      
	 IF mr_tela.identif_estoque IS NOT NULL THEN
	    INSERT INTO estoque_obs (
	      cod_empresa, num_transac, tex_observ) 
	    VALUES(p_cod_empresa, l_num_transac, p_tex_obs)

 		  IF STATUS <> 0 THEN 
		     CALL log003_err_sql("INSERT","estoque_obs")	
		     RETURN FALSE 		
		  END IF
	 END IF
   
   RETURN TRUE 
   
END FUNCTION

#----------------------------#                  
FUNCTION pol1113_atuali_wms()#
#----------------------------#

   #IF NOT POL1113_atu_par_user() THEN
   #   RETURN FALSE
   #END IF
      
   IF NOT pol1113_grav_wms_identif_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION POL1113_atu_par_user()#
#------------------------------#
   
   DEFINE p_parametro     LIKE wms_parametro_usuario.parametro,
          p_val_parametro LIKE wms_parametro_usuario.val_parametro,
          p_rotina        LIKE wms_parametro_usuario.rotina,
          p_sequencia_parametro LIKE wms_parametro_usuario.sequencia_parametro
   
   LET p_sequencia_parametro = 1
   LET p_rotina = 5
   
   DECLARE cq_user CURSOR FOR
    SELECT parametro, 
           val_parametro 
      FROM wms_parametro_usuario  
     WHERE empresa = p_cod_empresa
       AND usuario = p_user
       AND rotina = p_rotina
   
   FOREACH cq_user INTO p_parametro, p_val_parametro
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_user')
         RETURN FALSE
      END IF
      
      DELETE FROM wms_parametro_usuario  
       WHERE empresa = p_cod_empresa 
         AND usuario = p_user
         AND parametro = p_parametro 
         AND sequencia_parametro = p_sequencia_parametro
         AND rotina = p_rotina

      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','wms_parametro_usuario')
         RETURN FALSE
      END IF

      SELECT 1 FROM wms_parametro_usuario  
       WHERE empresa = p_cod_empresa 
         AND usuario = p_user
         AND parametro = p_parametro 
         AND sequencia_parametro = p_sequencia_parametro
         AND rotina = p_rotina

      IF STATUS = 100 THEN
         INSERT INTO wms_parametro_usuario
          VALUES(p_cod_empresa,
                 p_user,
                 p_parametro,
                 p_sequencia_parametro,
                 p_rotina,
                 p_val_parametro)
         IF STATUS <> 0 THEN
            CALL log003_err_sql('DELETE','wms_parametro_usuario')
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','wms_parametro_usuario')
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION 
   
#------------------------------#
FUNCTION pol1113_le_tip_estoq()#
#------------------------------#

   SELECT tip_estoque,
          restricao
     INTO p_tip_estoque_de,
          p_resticao_de
     FROM wms_identif_estoque
    WHERE empresa = p_cod_empresa
      AND identif_estoque = p_identif_estoque
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','wms_identif_estoque')
      RETURN FALSE
   END IF
                     
   SELECT *
     INTO p_tip_estoq_915.*
     FROM tip_estoque_915      
    WHERE cod_empresa = p_cod_empresa
      AND tip_estoq_insp = p_tip_estoque_de
      AND restricao_insp = p_resticao_de
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','tip_estoque_915')
      RETURN FALSE
   END IF
   
   IF l_resultado = 'L' THEN
      LET p_tip_estoque_para = p_tip_estoq_915.tip_estoq_liber
      LET p_resticao_para = p_tip_estoq_915.restricao_liber
      LET p_ies_situa = p_tip_estoq_915.status_liberado
   ELSE
      LET p_tip_estoque_para = p_tip_estoq_915.tip_estoque_rejei
      LET p_resticao_para = p_tip_estoq_915.restricao_rejei
      LET p_ies_situa = p_tip_estoq_915.status_rejeitado
   END IF

   LET p_tex_obs =  'Altera��o Tipo Estoque/Restri��o de ',
       p_tip_estoque_de CLIPPED, '/', p_resticao_de CLIPPED,
       ' para ', p_tip_estoque_para CLIPPED, '/', p_resticao_para

   RETURN TRUE

END FUNCTION

#------------------------------------------#
FUNCTION pol1113_grav_wms_identif_estoque()#
#------------------------------------------#
  
   UPDATE wms_identif_estoque
      SET tip_estoque = p_tip_estoque_para,
          restricao = p_resticao_para,
          dat_hor_bloqueio = NULL,
          usuario_bloqueio = NULL 
          #qtd_realizada = mr_tela.qtd_pa    
    WHERE empresa = p_cod_empresa
      AND identif_estoque = p_identif_estoque

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','wms_identif_estoque')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
                        