#-------------------------------------------------------------------#
# SISTEMA.: EMISSOR DE LAUDOS                                       #
# PROGRAMA: POL1116                                                 #
# OBJETIVO: GERA��O DO LAUDO                                        #
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
          g_ies_ambiente  CHAR(001),
          p_nom_arquivo   CHAR(100),
          p_arquivo       CHAR(025),
          p_caminho       CHAR(080),
          p_nom_tela      CHAR(200),
          p_nom_help      CHAR(200),
          sq_stmt         CHAR(300),
          p_r             CHAR(001),
          p_count         SMALLINT,
          p_ies_cons      SMALLINT,
          p_ast_row       SMALLINT,
          p_grava         SMALLINT, 
          pa_curr         SMALLINT,
          pa_curr1        SMALLINT,
          sc_curr         SMALLINT,
          sc_curr1        SMALLINT,
          w_a             SMALLINT,
          p_msg           CHAR(500),
          p_hoje          DATE,
          p_index         integer,
          s_index         integer,
          p_ind           integer,
          s_ind           integer,
          p_ies_validade  char(01),
          p_ies_texto     char(01),
          p_em_analise    char(01),
          l_txt_resultado char(250),
          p_dat_hor_emis  datetime year to second,
          p_dat_producao  like ANALISE_VALI_915.DAT_VALI_INI,
          p_num_versao    decimal(3,0),
          p_versao_ant    decimal(3,0),
          p_nova_versao   char(01),
          m_ies_cons      SMALLINT,
          p_especie       char(01),
          p_operacao      char(20),
          p_num_om        integer,
		      p_seq_item_nf   like fat_nf_item.seq_item_nf,
		      p_ies_liberado    char (01) 
          
   DEFINE p_trans_nota_fiscal  Integer,
          l_informou_dados     SMALLINT,
          l_cod_cliente        LIKE clientes.cod_cliente,
          l_tip_analise        LIKE it_analise_915.tip_analise,
          l_unidade            CHAR(15), 
          l_dat_analise        date,
          l_em_analise         CHAR(1),
          p_val_resultado      like laudo_item_915.val_resultado,
          p_txt_resultado      like laudo_item_915.val_resultado,
          p_resultado          like laudo_item_915.val_resultado,
          p_observacao         like laudo_item_915.observacao,
          m_qtd_item           LIKE fat_nf_item.qtd_item,
          p_num_ser            Like vdp_num_docum.serie_docum,
          p_num_nf             integer,
          l_bloq_laudo         CHAR(1),
          l_tipo_laudo         char(02),
          p_lote_tanque        char(15),
          p_num_pa             Integer,
          p_num_laudo          Integer,
          p_cod_item           char(15),
          p_num_reserva        Integer,
          p_num_lote           char(15),
          p_identif_estoque    char(30),
          p_identif_virtual    char(30)
          
          
END GLOBALS
   
   DEFINE w_i             SMALLINT,
          m_laudo_exx     SMALLINT,
          p_den_item      CHAR(76)

   DEFINE mr_tela RECORD 
      num_laudo      LIKE laudo_mest_915.num_laudo,
      num_versao     dec(3,0),
      versao_atual   char(01),
      dat_emissao    date,
      num_nf         LIKE fat_nf_mestre.nota_fiscal,
      ser_nf         char(03),
      seq_item_nf    LIKE fat_nf_item.seq_item_nf,
      num_om         LIKE fat_nf_item.ord_montag, 
      cod_item       LIKE analise_915.cod_item,
      lote_tanque    LIKE analise_915.lote_tanque,
      dat_fabricacao date,
      dat_validade   date,
      dat_emis_nf    date,
      qtd_laudo      LIKE laudo_mest_915.qtd_laudo,
      num_pa         dec(6,0),
      ies_impresso   char(01),
      texto_1        LIKE laudo_mest_915.texto_1,
      texto_2        LIKE laudo_mest_915.texto_2
   END RECORD 


   DEFINE ma_num_pa ARRAY[50] OF RECORD 
      num_pa                LIKE analise_915.num_pa
   END RECORD 

   DEFINE pr_tip_analise    ARRAY[50] OF RECORD 
      tip_analise           LIKE analise_915.tip_analise
   END RECORD 

   DEFINE m_ind             SMALLINT,
          m_den_analise     LIKE it_analise_915.den_analise_port,
          m_ies_tanque      CHAR(1),
          m_item_analise    LIKE item_915.cod_item_analise

   DEFINE ma_tela   ARRAY[50]  OF RECORD
      den_analise              LIKE it_analise_915.den_analise_port,
      especificacao_de         LIKE laudo_item_915.especificacao_de,
      especificacao_ate        LIKE laudo_item_915.especificacao_ate,
      especie                  char(01)
   END RECORD 

   DEFINE ma_resu   ARRAY[50]  OF RECORD
      val_resultado            LIKE laudo_item_915.val_resultado,
      observacao               LIKE laudo_item_915.observacao
   END RECORD 

   DEFINE ma_id   ARRAY[50]  OF RECORD
          num_id  integer
   end RECORD

   DEFINE mr_laudo_mest  RECORD LIKE laudo_mest_915.*,
          mr_laudo_mestr RECORD LIKE laudo_mest_915.*

MAIN
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   
   DEFER INTERRUPT
   LET p_versao = "POL1116-10.02.40"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("POL1116.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '11'; LET p_user = 'admlog'; LET p_status = 0

   IF p_status = 0  THEN
      CALL POL1116_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION POL1116_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL1116") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_POL1116 AT 2,1 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 
   LET l_informou_dados = FAlSE

   MENU "OPCAO"
      COMMAND "Incluir" "Inclus�o do certificado."
         CALL pol1116_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            CLEAR FORM
            DISPLAY p_cod_empresa to cod_empresa
            ERROR 'Opera��o cancelada !!!'
         END IF 

      COMMAND "Consultar" "Consulta de certificado"
         IF pol1116_consulta() THEN
            IF m_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF

      COMMAND "Seguinte" "Exibe o Pr�ximo Item Encontrado na Consulta"
         CALL pol1116_paginacao("SEGUINTE")

      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         CALL pol1116_paginacao("ANTERIOR")       

      COMMAND "Modificar" "Modifica dados do Certificado."
         IF m_ies_cons THEN
            IF mr_laudo_mest.ies_impresso = 'S' THEN
               ERROR 'Certificado j� foi impresso, n�o pode ser modificado!'
            ELSE
               IF mr_laudo_mest.versao_atual = 'N' THEN
                  ERROR 'S� a vers�o atual pode ser modificada!'
               ELSE
                  IF POL1116_modificacao() then
                     ERROR 'Opera��o efetuada com sucesso!'
                  ELSE
                     ERROR 'Opera��o cancelada!'
                  END IF
               End if
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modifica��o"
         END IF

      COMMAND "Versao" "Criar nova vers�o do certificado"
         IF m_ies_cons THEN
            IF mr_laudo_mest.versao_atual = 'N' THEN
               ERROR 'S� � permitido criar nova vers�o da vers�o atual!'
            ELSE
               CALL log085_transacao("BEGIN")
               IF POL1116_nova_versao() then
                  CALL log085_transacao("COMMIT")
                  ERROR 'Opera��o efetuada com sucesso!'
               ELSE
                  CALL log085_transacao("ROLLBACK")
                  ERROR 'Opera��o cancelada!'
               END IF
            End if
         ELSE
            ERROR "Consulte Previamente para fazer a Modifica��o"
         END IF

      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa !!!"
         CALL POL1116_sobre()
         
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTece ENTER para continuar" FOR CHAR comando
         DATABASE ogix
         LET int_flag = 0
      
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_POL1116

END FUNCTION
 
 #-----------------------#
 FUNCTION POL1116_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol1116_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE mr_tela.* TO NULL
   LET INT_FLAG  = FALSE
   let p_nova_versao = 'N'

   IF POL1116_informa_dados('I') THEN
   		let p_lote_tanque = mr_tela.lote_tanque                                       
   		let p_cod_item    = mr_tela.cod_item
   		let p_num_pa      = mr_tela.num_pa
   		let p_num_laudo   = mr_tela.num_laudo
      IF pol1116_carrega_anali() THEN
         CALL log085_transacao("BEGIN")
         if POL1116_gera_laudo() then
            CALL log085_transacao("COMMIT")
            return TRUE
         END IF
         CALL log085_transacao("ROLLBACK")
      end if
   end if
   
   return false

end FUNCTION

#-----------------------------------#
 FUNCTION POL1116_informa_dados(p_op)
#-----------------------------------#

   DEFINE p_op char(01),
          l_count   integer
   
   LET l_informou_dados = false
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1116
   INITIALIZE mr_tela.* TO NULL
   LET p_houve_erro = FALSE
   LET m_laudo_exx = FALSE

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   SELECT serie_docum
     INTO p_num_ser
     FROM vdp_num_docum
    WHERE empresa = p_cod_empresa
      and tip_docum = 'FATPRDSV'
      
	IF STATUS <> 0 THEN 
		CALL log003_err_sql("LENDO",'VDP_NUM_DOCUM')
		RETURN FALSE
	END IF  

   LET INT_FLAG =  FALSE
   CALL POL1116_busca_num_laudo()

   LET mr_tela.ser_nf = p_num_ser
   
   INPUT BY NAME mr_tela.*  WITHOUT DEFAULTS  

      BEFORE FIELD num_nf
         IF mr_tela.ser_nf IS NULL THEN
            Let mr_tela.ser_nf = p_num_ser
            DISPLAY mr_tela.ser_nf TO ser_nf
         END IF

      AFTER FIELD num_nf
         
         LET p_num_nf = mr_tela.num_nf
         
         IF mr_tela.num_nf IS NULL THEN 
            ERROR 'Campo com preenchimento obrigat�rio.'
            NEXT FIELD num_nf
         END IF
         
      AFTER FIELD ser_nf
         IF mr_tela.ser_nf IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio!!!'
            NEXT FIELD ser_nf
         END IF

         IF POL1116_verifica_nf() = FALSE THEN
            NEXT FIELD num_nf
         END IF
          		 
	    AFTER FIELD seq_item_nf	 
	      
	       IF mr_tela.seq_item_nf IS NULL THEN    
            ERROR 'Campo com preenchimento obrigat�rio.'
            NEXT FIELD seq_item_nf				  
		     END IF
		     
         IF POL1116_valida_seq() = FALSE THEN
            NEXT FIELD num_nf
         END IF
		     
		     DISPLAY mr_tela.num_om TO num_om
		     DISPLAY mr_tela.cod_item TO cod_item
		     DISPLAY p_den_item TO den_item
         
         LET p_num_om = mr_tela.num_om
         
         IF not pol1116_sel_lote() then
            NEXT FIELD seq_item_nf
		     END IF 

		     LET l_count = 0 

         SELECT COUNT(*)  
				   INTO l_count
				   FROM laudo_mest_915
				  WHERE cod_empresa = p_cod_empresa
				  	AND num_nf = mr_tela.num_nf
					  AND ser_nf = mr_tela.ser_nf
					  AND cod_item = mr_tela.cod_item
					  AND seq_item_nf = mr_tela.seq_item_nf
					  AND lote_tanque =  mr_tela.lote_tanque
					  #AND num_versao  = mr_tela.num_versao
					  #AND identif_estoque = p_identif_estoque
					  
					IF l_count  > 0  THEN 
					   ERROR 'J� existe laudo para o Identificador ',p_identif_estoque
					   NEXT FIELD seq_item_nf	
					END IF	  	  

          SELECT SUM(qtd_item)
            INTO m_qtd_item
            FROM fat_nf_item
           WHERE empresa           = p_cod_empresa
             AND trans_nota_fiscal = p_trans_nota_fiscal
             AND item              = mr_tela.cod_item
		         AND seq_item_nf		   = mr_tela.seq_item_nf
		 
		      IF STATUS <> 0 THEN
		         CALL log003_err_sql('SELECT','fat_nf_item')
		         NEXT FIELD seq_item_nf
		      END IF
		      
      BEFORE FIELD qtd_laudo 
         IF mr_tela.qtd_laudo IS NULL OR mr_tela.qtd_laudo = ' ' THEN
            LET mr_tela.qtd_laudo = m_qtd_item
            DISPLAY mr_tela.qtd_laudo TO qtd_laudo
         END IF
         
      AFTER FIELD qtd_laudo 
         IF mr_tela.qtd_laudo IS NULL OR
            mr_tela.qtd_laudo = ' ' THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD qtd_laudo 
         ELSE
            IF POL1116_verifica_qtd_laudo() = FALSE THEN
               NEXT FIELD qtd_laudo 
            END IF
         END IF
      
      AFTER FIELD num_pa 
      
         if mr_tela.num_pa is null then
            error 'Campo com preenchimento obrigat�rio!!!'
            next FIELD num_pa
         end if
         
		      SELECT ies_liberado
		        INTO p_ies_liberado
		        FROM analise_mest_915
		       WHERE cod_empresa = p_cod_empresa
		         AND cod_item = mr_tela.cod_item
		         AND lote_tanque = mr_tela.lote_tanque
		         AND num_pa = mr_tela.num_pa
		         AND identif_estoque = p_identif_estoque
		      
		      IF STATUS <> 0 THEN
		         CALL log003_err_sql('SELECT','analise_mest_915')
		         NEXT FIELD num_pa
		      END IF
		      
		      IF p_ies_liberado = 'N' THEN
		         LET p_msg = 'Essa PA ainda n�o foi liberada.'
		         NEXT FIELD num_pa
		      END IF
		         

      ON KEY (control-z)
         CALL POL1116_popup()
 
    END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      RETURN FALSE
   END IF
   
   LET p_num_pa = mr_tela.num_pa
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION POL1116_busca_num_laudo()
#---------------------------------#
  
   DEFINE l_num_laudo          DECIMAL(6,0)

   SELECT MAX(num_laudo)
     INTO l_num_laudo
     FROM laudo_mest_915 
    WHERE cod_empresa = p_cod_empresa
   IF l_num_laudo IS NULL OR
      l_num_laudo = 0 THEN 
      LET l_num_laudo = 1 
   ELSE
      LET l_num_laudo = l_num_laudo + 1
   END IF

   LET mr_tela.num_laudo = l_num_laudo
   LET p_num_versao = 1 
   LET mr_tela.num_versao = 1
   LET mr_tela.versao_atual = 'S'
   LET mr_tela.dat_emissao = today
   LET mr_tela.ies_impresso = 'N'

END FUNCTION

#----------------------------------# 
 FUNCTION POL1116_verifica_cliente()
#----------------------------------# 
   DEFINE l_nom_cliente         LIKE clientes.nom_cliente

   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = l_cod_cliente

   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_nom_cliente TO nom_cliente
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 

END FUNCTION

#-------------------------------#
 FUNCTION POL1116_verifica_item()
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

#-------------------------------------#
 FUNCTION POL1116_verifica_item_nf_om()
#-------------------------------------#
   
   
   let p_num_om = null
   let p_seq_item_nf  = 0 
   
   IF mr_tela.num_nf IS NOT NULL AND
      mr_tela.num_nf <> ' ' THEN
      DECLARE cq_item_nf CURSOR FOR 
       SELECT qtd_item, ord_montag
         FROM fat_nf_item
        WHERE empresa           = p_cod_empresa
          AND trans_nota_fiscal = p_trans_nota_fiscal
          AND item              = mr_tela.cod_item
#		  AND seq_item_nf		= mr_tela.seq_item_nf
     
      OPEN cq_item_nf
      FETCH cq_item_nf INTO m_qtd_item, p_num_om
    
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE
      END IF 
   ELSE
      let p_num_om = mr_tela.num_om
      DECLARE cq_item_nf1 CURSOR FOR 
       SELECT qtd_reservada 
         FROM ordem_montag_item
        WHERE cod_empresa = p_cod_empresa
          AND num_om      = mr_tela.num_om
          AND cod_item    = mr_tela.cod_item
#		  AND num_sequencia = mr_tela.seq_item_nf
      
      OPEN cq_item_nf1
      FETCH cq_item_nf1 INTO m_qtd_item
      
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE
      END IF 
   END IF 
  
   RETURN TRUE 

END FUNCTION

#---------------------------------#
 FUNCTION POL1116_busca_item_915()
#---------------------------------#

   INITIALIZE m_item_analise TO NULL
   
     SELECT distinct cod_item_analise
       INTO m_item_analise
       FROM item_refer_915
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = mr_tela.cod_item  
   
	IF sqlca.sqlcode <> 0 THEN 
        SELECT distinct cod_item_analise
       INTO m_item_analise
       FROM item_915
      WHERE cod_empresa = p_cod_empresa
        AND cod_item_analise    = mr_tela.cod_item  
		IF sqlca.sqlcode <> 0 THEN
			RETURN FALSE
		ELSE
			RETURN TRUE
		END IF	
	ELSE
      RETURN TRUE
   END IF

END FUNCTION

#-------------------------#
FUNCTION pol1116_sel_lote()
#-------------------------#

   DEFINE l_ind              SMALLINT,
          p_dat_hor_producao datetime year to second,
          p_dat_hor_validade datetime year to second
          
   DEFINE pr_lote ARRAY[200] OF RECORD
      num_reserva     Integer,
      num_lote        char(15),
      identif_estoque char(30)      
   END RECORD

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL11162") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11162 AT 6,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)           
	  
	  LET l_ind = 1
	  
		DECLARE cq_lote CURSOR FOR
     SELECT a.num_reserva,
            a.num_lote,
            c.identif_estoque
       FROM estoque_loc_reser a,
            ordem_montag_grade b,
            est_loc_reser_end c
      WHERE a.cod_empresa = p_cod_empresa
        AND a.cod_empresa = b.cod_empresa
        AND a.num_reserva = b.num_reserva
        AND a.cod_empresa = c.cod_empresa
        AND a.num_reserva = c.num_reserva
        AND b.num_om = p_num_om
      ORDER BY a.num_lote, c.identif_estoque  
       
		FOREACH cq_lote into 
				pr_lote[l_ind].num_reserva,
				pr_lote[l_ind].num_lote,
				pr_lote[l_ind].identif_estoque
      
			if status <> 0 then
				call log003_err_sql('Lendo','cq_lote')
				CLOSE WINDOW w_pol11162
				RETURN FALSE
			end if

      SELECT COUNT(*)  
			  INTO p_count
			  FROM laudo_mest_915
			WHERE cod_empresa = p_cod_empresa
				AND num_nf = mr_tela.num_nf
			  AND ser_nf = mr_tela.ser_nf
			  AND cod_item = mr_tela.cod_item
			  AND seq_item_nf = mr_tela.seq_item_nf
			  AND lote_tanque =  pr_lote[l_ind].num_lote
					  
			IF p_count  > 0  THEN 
			   CONTINUE FOREACH
			END IF	  	  

      LET p_identif_virtual = pr_lote[l_ind].identif_estoque
      
      IF p_identif_virtual[1] = '6' THEN
         IF NOT pol1116_identf_original() THEN
            RETURN FALSE
         END IF
         LET pr_lote[l_ind].identif_estoque = p_identif_estoque
      END IF
      
			let l_ind = l_ind + 1
			
			IF l_ind > 200 THEN
			   call log0030_mensagem('Limite de linhas da grade ultrapassou.','info')
			   EXIT FOREACH
			END IF
   
		END FOREACH

   IF l_ind = 1 THEN
      LET p_msg = 'O NF/sequ�ncia informadas n�o\n possui mais lotes sem laudo.'
      CALL log0030_mensagem(p_msg,'info')
      CLOSE WINDOW w_pol11162
      CURRENT WINDOW IS w_POL1116
      RETURN FALSE
   END IF
      
   CALL SET_COUNT(l_ind - 1) 
   DISPLAY ARRAY pr_lote TO sr_lote.*
   
      LET l_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 

   CLOSE WINDOW w_pol11162
   CURRENT WINDOW IS w_POL1116
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   LET p_num_lote = pr_lote[l_ind].num_lote
   LET p_num_reserva = pr_lote[l_ind].num_reserva
   LET p_identif_estoque = pr_lote[l_ind].identif_estoque
   LET m_item_analise = mr_tela.cod_item
        
   SELECT max(num_pa)
     INTO mr_tela.num_pa
     FROM analise_mest_915
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_item_analise
      AND lote_tanque = p_num_lote
      AND identif_estoque = p_identif_estoque
      AND ies_liberado <> 'N'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo", "analise_mest_915")
      RETURN FALSE
   END IF
   
   IF mr_tela.num_pa IS NULL THEN
      let p_msg = 'Lote: ', p_num_lote CLIPPED, ' Item: ', m_item_analise CLIPPED, '\n',
                  'Identificador ',p_identif_estoque CLIPPED,'\n',
                  'sem resultado de an�lises!'
      call log0030_mensagem(p_msg,'excla') 
      RETURN FALSE
   END IF
   
   SELECT dat_hor_producao,
          dat_hor_validade
     INTO p_dat_hor_producao,
          p_dat_hor_validade
     FROM est_loc_reser_end
    WHERE cod_empresa = p_cod_empresa
      AND num_reserva = p_num_reserva
      
   IF STATUS <> 0 THEN
      call log003_err_sql('Lendo','est_loc_reser_end')
      RETURN false
   END IF
   
   LET mr_tela.lote_tanque    = p_num_lote
   LET mr_tela.dat_fabricacao = EXTEND(p_dat_hor_producao, year to day)
   LET mr_tela.dat_validade   = EXTEND(p_dat_hor_validade, year to day)
   
   DISPLAY  mr_tela.lote_tanque    to lote_tanque
   DISPLAY  mr_tela.dat_fabricacao to dat_fabricacao
   DISPLAY  mr_tela.dat_validade   to dat_validade
   DISPLAY  mr_tela.num_pa         to num_pa
   
   RETURN TRUE
   
END FUNCTION                                           

#---------------------------------#
FUNCTION pol1116_identf_original()#
#---------------------------------#

   DEFINE p_identif_orig     CHAR(30),
          p_trans_virtual    INTEGER,
          p_trans_original   INTEGER
      
   INITIALIZE p_trans_virtual TO NULL
   
   DECLARE cq_identif CURSOR FOR
    SELECT num_transac
      FROM estoque_trans_end
     WHERE cod_empresa = p_cod_empresa
       AND identif_estoque = p_identif_virtual
     ORDER BY num_transac
     
   FOREACH cq_identif INTO p_trans_virtual
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_identif')
         RETURN FALSE
      END IF
      EXIT FOREACH
   END FOREACH
   
   SELECT num_trans_origem
     INTO p_trans_original
     FROM sup_mov_orig_dest
    WHERE empresa = p_cod_empresa
      AND num_trans_destino = p_trans_virtual
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','sup_mov_orig_dest')
      RETURN FALSE
   END IF
   
   SELECT identif_estoque
     INTO p_identif_estoque
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_trans_original
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_trans_end')
      RETURN FALSE
   END IF
     
     
   IF p_identif_estoque IS NULL THEN
      LET p_msg = 'N�o foi possivel corregar\n',
                  'a identifica��o do estoque'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

   
#-----------------------------#
 FUNCTION POL1116_verifica_nf()
#-----------------------------#
   
   DEFINE l_nom_cliente        LIKE clientes.nom_cliente
   
   LET p_count = 0
   
   SELECT a.cliente, 
          a.trans_nota_fiscal, 
          b.nom_cliente,
          a.dat_hor_emissao
     INTO l_cod_cliente,
          p_trans_nota_fiscal,
          l_nom_cliente,
          p_dat_hor_emis
     FROM fat_nf_mestre a, clientes b
    WHERE a.empresa     = p_cod_empresa
      AND a.nota_fiscal = mr_tela.num_nf
      AND a.serie_nota_fiscal = mr_tela.ser_nf
      AND a.tip_nota_fiscal = 'FATPRDSV'
      AND a.cliente     = b.cod_cliente
   
   IF STATUS <> 0 THEN
      ERROR 'Nota Fisca n�o existe.'
      RETURN FALSE
   END IF

   LET mr_tela.dat_emis_nf = EXTEND(p_dat_hor_emis, year to day)
                  
   DISPLAY l_cod_cliente TO cod_cliente
   DISPLAY l_nom_cliente TO nom_cliente
   DISPLAY mr_tela.dat_emis_nf TO dat_emis_nf
   
   RETURN TRUE
   
END FUNCTION       

#----------------------------#
FUNCTION POL1116_valida_seq()#
#----------------------------#

   SELECT ord_montag,
          item,
          des_item
     INTO mr_tela.num_om,
          mr_tela.cod_item,
          p_den_item
     FROM fat_nf_item
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_trans_nota_fiscal
      AND seq_item_nf = mr_tela.seq_item_nf

   IF STATUS <> 0 THEN
      ERROR 'Sequ�ncia do item inexistete, para a NF informada.'
      RETURN FALSE
   END IF
   
   IF mr_tela.num_om IS NULL OR mr_tela.num_om = 0 THEN
      ERROR 'A NF informada n�o foi faturada com pedido.'
      RETURN FALSE
   END IF      
   
   RETURN TRUE

END FUNCTION

#------------------------------------# 
 FUNCTION POL1116_verifica_qtd_laudo()
#------------------------------------# 
   
   DEFINE l_qtd_item         DECIMAL(15,3),
          l_qtd_laudo        LIKE laudo_mest_915.qtd_laudo

      SELECT SUM(qtd_item)
        INTO l_qtd_item
        FROM fat_nf_item
       WHERE empresa           = p_cod_empresa
         AND trans_nota_fiscal = p_trans_nota_fiscal
         AND item              = mr_tela.cod_item
		     AND seq_item_nf		   = mr_tela.seq_item_nf
		     
      IF l_qtd_item IS NULL OR
         l_qtd_item = 0 THEN
         ERROR "Item sem quantidade na Nota Fiscal." 
         RETURN FALSE
      END IF 
      
   IF l_qtd_item < mr_tela.qtd_laudo THEN
      ERROR "Quantidade do Laudo maior que a Quantidade da NF."
      RETURN FALSE
   END IF 

END FUNCTION

#------------------------------#
 FUNCTION pol1116_sel_num_seq()#
#------------------------------#

   DEFINE pr_seq           ARRAY[200] OF RECORD
          seq_item_nf      INTEGER,
          cod_item         CHAR(15),
          des_item         CHAR(30),
          qtd_item         DECIMAL(10,3)
   END RECORD   
   
   INITIALIZE p_nom_tela, pr_tipo TO NULL
   CALL log130_procura_caminho("pol11164") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11164 AT 6,5 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_seq CURSOR FOR
    SELECT a.seq_item_nf,
           a.item,
           a.des_item,
           a.qtd_item
      FROM fat_nf_item a,
           fat_nf_mestre b
     WHERE b.empresa = p_cod_empresa
       AND b.trans_nota_fiscal = p_trans_nota_fiscal
       AND a.empresa = b.empresa
       AND a.trans_nota_fiscal = b.trans_nota_fiscal

   FOREACH cq_seq INTO 
      pr_seq[p_ind].seq_item_nf,
      pr_seq[p_ind].cod_item,   
      pr_seq[p_ind].des_item,   
      pr_seq[p_ind].qtd_item   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_iseq')
         EXIT FOREACH
      END IF
             
      LET p_ind = p_ind + 1
      
      IF p_ind > 200 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_seq TO sr_seq.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol11164
   
   IF NOT INT_FLAG THEN
      RETURN pr_seq[p_ind].seq_item_nf 
   ELSE
      RETURN ''
   END IF
   
END FUNCTION

#-----------------------#
 FUNCTION POL1116_popup()
#-----------------------#
 
   DEFINE p_codigo CHAR(15)
 
   DEFINE z_ind  SMALLINT

   DEFINE pr_PA ARRAY[15] OF RECORD
      num_pa INTEGER,
      dat_analise  DATE
   END RECORD
	 
   CASE 
    
    WHEN infield(seq_item_nf)
         
         LET p_codigo = pol1116_sel_num_seq()
         CALL log006_exibe_teclas("01 02 07", p_versao)
         
         CURRENT WINDOW IS w_POL1116
         
         IF p_codigo IS NOT NULL THEN
            DISPLAY p_codigo TO seq_item_nf
            LET mr_tela.seq_item_nf = p_codigo
         END IF
    
   
   	WHEN infield(num_pa)
	
			LET z_ind = 1
   		CALL log006_exibe_teclas("01",p_versao)
      INITIALIZE p_nom_tela TO NULL
   		CALL log130_procura_caminho("POL11163") RETURNING p_nom_tela
      LET p_nom_tela = p_nom_tela CLIPPED
      OPEN WINDOW w_pol11163 AT 6,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)           
				DECLARE cq_lote3 CURSOR FOR
        SELECT DISTINCT(num_pa), dat_analise FROM  analise_mest_915
        WHERE cod_empresa = p_cod_empresa
        AND cod_item = mr_tela.cod_item
        AND lote_tanque = mr_tela.lote_tanque
        AND identif_estoque = p_identif_estoque
        AND ies_liberado <> 'N'
        ORDER BY num_pa

		  FOREACH cq_lote3 into 
				pr_PA[z_ind].num_pa,
				pr_PA[z_ind].dat_analise
      
			let z_ind = z_ind + 1

      END FOREACH

   		CALL SET_COUNT(z_ind - 1) 
   		DISPLAY ARRAY pr_PA TO sr_pa.*
   
   		LET z_ind = ARR_CURR()
   		CLOSE WINDOW w_pol11163

			if status <> 0 then
				call log003_err_sql('Lendo','analise_mest_915')
				CLOSE WINDOW w_pol11163
				RETURN FALSE
			end if
   		IF INT_FLAG THEN
      	RETURN FALSE
   		End if

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1116		
		
	

   DISPLAY pr_pa[z_ind].num_pa TO mr_tela.num_pa
 

   RETURN TRUE
  
   
  END CASE
         
END FUNCTION
                               
#-----------------------------#
 FUNCTION POL1116_gera_laudo()
#-----------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   let p_lote_tanque = mr_tela.lote_tanque                                       
   let p_cod_item    = mr_tela.cod_item
   let p_num_pa      = mr_tela.num_pa
   let p_num_laudo   = mr_tela.num_laudo
   let p_dat_producao = mr_tela.dat_fabricacao

   if not pol1116_inclui_itens() then
      RETURN FALSE
   end if
   
   if mr_tela.num_om is null or mr_tela.num_om = ' ' then
      let mr_tela.num_om = p_num_om
   end if
   
   if mr_tela.num_nf is null or mr_tela.num_nf = ' ' then
      let mr_tela.num_nf = p_num_nf
      let mr_tela.ser_nf = p_num_ser
   end if
   
   INSERT INTO laudo_mest_915
         VALUES (p_cod_empresa,                                    
                 mr_tela.num_laudo,                       
                 p_num_versao,                
                 mr_tela.versao_atual,                                  
                 mr_tela.num_om,                          
                 mr_tela.num_nf,                          
                 mr_tela.ser_nf,                          
                 mr_tela.cod_item,            
				         mr_tela.seq_item_nf,         
                 m_item_analise,                          
                 mr_tela.dat_emissao,                                  
                 l_cod_cliente,                           
                 mr_tela.lote_tanque,                     
                 mr_tela.qtd_laudo,                       
                 l_tipo_laudo,                            
                 mr_tela.ies_impresso,                                     
                 l_bloq_laudo,                            
                 mr_tela.texto_1,                         
                 mr_tela.texto_2,                         
                 p_user,                                    
                 NULL,                                    
                 NULL,                        
                 mr_tela.num_pa,              
                 mr_tela.dat_emis_nf,         
                 mr_tela.dat_fabricacao,      
                 mr_tela.dat_validade,        
                 p_identif_estoque)           
                            
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO","LAUDO_MEST_915")
         RETURN false
      END IF
      
   INSERT INTO pa_laudo_915 
          VALUES(p_cod_empresa,                                    
                 mr_tela.num_laudo,                             
                 p_num_versao,                                                   
                 mr_tela.num_pa)
                          
   IF status <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","PA_LAUDO_915")                                               
       RETURN FALSE
   end if

                                                    
   Let mr_laudo_mest.num_laudo  = mr_tela.num_laudo     
   Let mr_laudo_mest.num_versao = p_num_versao 
   Let p_operacao = 'INCLUIU'
   
    IF NOT pol1116_grava_audit() THEN 
       RETURN FALSE
    END IF
   
   RETURN true
   
END FUNCTION

#------------------------------#
FUNCTION pol1116_inclui_itens()
#------------------------------#

   DEFINE l_tipo_valor          CHAR(2),
          l_val_resultado       DECIMAL(10,4),
          l_val_especif_de      LIKE especific_915.val_especif_de,
          l_val_especif_ate     LIKE especific_915.val_especif_ate,
          l_variacao            LIKE especific_915.variacao,
          l_metodo              LIKE especific_915.metodo,
          l_val_especif_de_2    LIKE especific_915.val_especif_de,
          l_val_especif_ate_2   LIKE especific_915.val_especif_ate,
          l_metodo_2            LIKE especific_915.metodo,
          l_variacao_2          LIKE especific_915.variacao,
          l_tipo_valor_2        CHAR(2),
          l_tem_cli             SMALLINT,
          sql_stmt              CHAR(500),
          l_bloq_item           CHAR(1),
          l_observacao          CHAR(20),
          z_ind                 SMALLINT

   LET l_bloq_laudo = 'N'
   let l_tipo_laudo = null
   let l_bloq_item = 'N'

   INITIALIZE sql_stmt TO NULL 

    SELECT count(cod_empresa)
      into p_count                                                                 
      FROM par_laudo_915                                                               
     WHERE cod_empresa = p_cod_empresa                                                 
       AND cod_item    = m_item_analise                                                
       AND cod_cliente = l_cod_cliente                                                 
                                                                                    
   IF p_count > 0 THEN                                                           
      LET l_tem_cli = TRUE                                                             
   ELSE                                                                                
      LET l_tem_cli = FALSE                                                            
   END IF                                                                              
                                                                                       
   LET sql_stmt =                                                                      
      " SELECT DISTINCT tip_analise ",                                                 
      "   FROM par_laudo_915 ",                                                   
      "  WHERE cod_empresa = '",p_cod_empresa,"'",                                   
      "    AND cod_item    = '",m_item_analise,"'"                                    
                                                                                       
   IF l_tem_cli THEN                                                                   
      LET sql_stmt = sql_stmt CLIPPED, "    AND cod_cliente = '",l_cod_cliente,"'"   
   ELSE                                                                                
      LET sql_stmt = sql_stmt CLIPPED, "    AND cod_cliente IS NULL "                
   END IF                                                                              
                                                                                    
   LET sql_stmt = sql_stmt CLIPPED, "   ORDER BY tip_analise "                       
                                                                                       
   PREPARE var_query2 FROM sql_stmt                                                    
   DECLARE cq_tip_analise2 SCROLL CURSOR WITH HOLD FOR var_query2                      
                                                                                     
   FOREACH cq_tip_analise2 INTO l_tip_analise                                          

      IF STATUS <> 0 THEN                                              
         CALL log003_err_sql("Lendo", "Cursor: cq_tip_analise2")    
         RETURN FALSE                                                  
      END IF                                                           
   
      SELECT val_especif_de, val_especif_ate,                                        
             tipo_valor, variacao, metodo                                            
        INTO l_val_especif_de_2, l_val_especif_ate_2,                                
             l_tipo_valor_2, l_variacao_2, l_metodo_2                                
        FROM especific_915                                                           
       WHERE cod_empresa = p_cod_empresa                                             
         AND cod_item    = m_item_analise                                            
         AND cod_cliente = l_cod_cliente                                             
         AND tip_analise = l_tip_analise                                             
                                                                                       
      IF sqlca.sqlcode = 0 THEN                                                        
         LET l_val_especif_de  = l_val_especif_de_2                                    
         LET l_val_especif_ate = l_val_especif_ate_2                                   
         LET l_tipo_valor      = l_tipo_valor_2                                        
         LET l_variacao        = l_variacao_2                                          
         LET l_metodo          = l_metodo_2                                            
      ELSE                                                                             
         SELECT val_especif_de, val_especif_ate,                        
                tipo_valor, variacao, metodo                                         
           INTO l_val_especif_de, l_val_especif_ate,                  
                l_tipo_valor, l_variacao, l_metodo                                   
           FROM especific_915                                                        
          WHERE cod_empresa = p_cod_empresa                                          
            AND cod_item    = m_item_analise                                         
            AND cod_cliente IS NULL                                                  
            AND tip_analise = l_tip_analise   
          
          if status <> 0 then
             call log003_err_sql('Lendo','especific_915')
             RETURN false
          end if                        
      END IF                                                                           
                  
      select ies_validade,
             ies_texto
        into p_ies_validade,
             p_ies_texto
        from it_analise_915
       where cod_empresa = p_cod_empresa
         and tip_analise = l_tip_analise
     
      if status <> 0 then
         call log003_err_sql('Lendo','it_analise_915')
         RETURN false
      end if                        
     
      If p_ies_validade = 'N' then                                                            
         SELECT val_analise,
                dat_analise,
                em_analise,
                unidade                                                            
           INTO l_val_resultado,
                l_dat_analise,
                l_em_analise,
                l_unidade                                                           
           FROM analise_915                                                             
          WHERE cod_empresa = p_cod_empresa                                             
            AND cod_item    = m_item_analise                                            
            AND tip_analise = l_tip_analise                                             
            AND lote_tanque = p_lote_tanque                                       
            AND num_pa      = p_num_pa
            AND identif_estoque = p_identif_estoque
         
         if status <> 0 then
            call log003_err_sql('Lendo','ANALISE_915')
            RETURN false
         end if  
         
		     IF l_em_analise = 'N'   THEN 
			      
			      IF p_ies_texto = 'N' THEN
				       let l_txt_resultado = l_val_resultado
			      ELSE
						   SELECT COUNT(val_caracter)
						     INTO z_ind 
						     FROM espec_carac_915 e
						    WHERE e.cod_empresa = p_cod_empresa
							    AND e.cod_item      = m_item_analise
							    AND e.tip_analise   = l_tip_analise
							    AND e.cod_cliente   = l_cod_cliente

					     IF z_ind = 0 THEN  
				          select den_caracter
				            into l_txt_resultado
				            from tipo_caract_915
				           where cod_empresa  = p_cod_empresa
				             and tip_analise  = l_tip_analise
				             and val_caracter = l_val_resultado
				             AND cod_cliente  = l_cod_cliente
					     ELSE
							    SELECT val_caracter
								    INTO l_val_resultado
								    FROM espec_carac_915 e
							     WHERE e.cod_empresa  = p_cod_empresa
								     AND e.cod_item     = m_item_analise
								     AND e.tip_analise  = l_tip_analise
								     AND e.cod_cliente  = l_cod_cliente

				          select den_caracter
				            into l_txt_resultado
				            from tipo_caract_915
				           where cod_empresa  = p_cod_empresa
				             and tip_analise  = l_tip_analise
				             and val_caracter = l_val_resultado
				             AND cod_cliente  IS NULL
					     END IF
			
               IF status <> 0 THEN
					        select den_caracter
					          into l_txt_resultado
					          FROM tipo_caract_915
				           WHERE cod_empresa  = p_cod_empresa
					           and tip_analise  = l_tip_analise
					           and val_caracter = l_val_resultado
					           AND cod_cliente IS NULL
					        if status <> 0 then
					           call log003_err_sql('Lendo','tipo_caract_915')
					           RETURN FALSE
					        END IF 
				       END IF 	 
			      END IF
		     END IF
      
      else       
         let p_count = 0
         
         if not pol1116_le_analise() then
            RETURN FALSE
         end if  
         
         IF p_count = 0 then
            let l_em_analise = 'S'
            INITIALIZE l_dat_analise, l_txt_resultado to null
         ELSE 		
		 	      let p_em_analise = 'N'
         END IF 
                                                                              
      end if
      
      if l_em_analise = 'S' then
         let l_observacao = 'EM ANALISE'
         LET l_txt_resultado = l_observacao
      else
         let l_observacao = null
      end if

      if p_nova_versao = 'S' then
         if mr_laudo_mest.ies_impresso = 'S' then
            select val_resultado, observacao
              into p_txt_resultado, p_observacao
              from laudo_item_915
             where cod_empresa = p_cod_empresa
               and num_laudo   = p_num_laudo
               and num_versao  = p_versao_ant
               and tip_analise = l_tip_analise
            if status = 0 then
               if p_observacao is null then
                  LET l_txt_resultado = p_txt_resultado
                  LET l_observacao    = p_observacao
               end if
            else
               if status <> 100 then
                  call log003_err_sql('Lendo','laudo_item_915')
                  RETURN FALSE
               end if
            end if
         end if
      end if
         
      INSERT INTO laudo_item_915                      
        VALUES (p_cod_empresa,                                                         
                p_num_laudo,  
                p_num_versao,                                                   
                l_tip_analise,                                                         
                l_metodo,                                                              
                l_val_especif_de,                                                      
                l_val_especif_ate,                                                     
                l_txt_resultado,                                                         
                l_tipo_valor,                                                          
                l_bloq_item,
                l_observacao,
                l_dat_analise,
                l_unidade)    

      IF STATUS <> 0 THEN                                                       
         CALL log003_err_sql("INSERT","LAUDO_ITEM_915")                           
         RETURN FALSE
      END IF                                                                           
   
   END FOREACH                                                                         
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1116_le_dat_prod()
#-----------------------------#

   select max(dat_hor_producao)
     into p_dat_hor
     from estoque_lote_ender
    where cod_empresa = p_cod_empresa
      and cod_item    = p_cod_item
      and num_lote    = p_lote_tanque
     
   IF status <> 0 THEN 
       CALL log003_err_sql("Lendo","estoque_lote_ender")                                               
       RETURN FALSE
   end if
   
   if p_dat_hor is null then
      let p_msg = 'Item ', mr_tela.cod_item CLIPPED,
                  ' Lote ', mr_tela.lote_tanque CLIPPED, ' n�o encontrado na estoque_lote_ender!'
      call log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   end if
   
   RETURN TRUE

end FUNCTION

#---------------------------#
FUNCTION pol1116_le_analise()
#---------------------------#

   define p_cod_familia like item.cod_familia
   
   let p_count = 0
   
   INITIALIZE             l_dat_analise, l_em_analise,  l_txt_resultado  TO NULL
   
   DECLARE cq_por_item cursor for
    select dat_analise,
           em_analise,
           resultado
      from analise_vali_915
     where cod_empresa   = p_cod_empresa
       and cod_item      = m_item_analise
       and tip_analise   = l_tip_analise
       and dat_vali_ini <= p_dat_producao
       and dat_vali_fim >= p_dat_producao
     order by dat_analise desc

   FOREACH cq_por_item INTO
           l_dat_analise,
            l_em_analise,
           l_txt_resultado                                                           
      
      IF status <> 0 THEN 
         CALL log003_err_sql("Lendo","analise_vali_915:por_item")                                               
         RETURN FALSE
      end if
      
      let p_count = 1
      RETURN TRUE
         
   end FOREACH
   
   select cod_familia
     into p_cod_familia
     from item
    where cod_empresa = p_cod_empresa
      and cod_item    = p_cod_item

   IF status <> 0 THEN 
      CALL log003_err_sql("Lendo","item.familia")                                               
      RETURN FALSE
   end if
        
   DECLARE cq_por_familia cursor for
    select dat_analise,
           em_analise,
           resultado
      from analise_vali_915
     where cod_empresa   = p_cod_empresa
       and cod_familia   = p_cod_familia
       and tip_analise   = l_tip_analise
       and dat_vali_ini <= p_dat_producao
       and dat_vali_fim >= p_dat_producao
     order by dat_analise desc

   FOREACH cq_por_familia INTO
           l_dat_analise,
           l_em_analise,
           l_txt_resultado                                                           
      
      IF status <> 0 THEN 
         CALL log003_err_sql("Lendo","analise_vali_915:por_familia")                                               
         RETURN FALSE
      end if
      
      let p_count = 1
      RETURN TRUE
         
   end FOREACH
   
   RETURN TRUE

end FUNCTION

#--------------------------#
 FUNCTION pol1116_consulta()
#--------------------------#

   DEFINE sql_stmt,
          where_clause CHAR(800)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET mr_laudo_mestr.* = mr_laudo_mest.*
   LET INT_FLAG = false

   CONSTRUCT BY NAME where_clause ON laudo_mest_915.num_laudo,
                                     laudo_mest_915.num_versao,
                                     laudo_mest_915.versao_atual,
                                     laudo_mest_915.num_nf,
                                     laudo_mest_915.num_om,
                                     laudo_mest_915.cod_cliente,
                                     laudo_mest_915.cod_item,
                                     laudo_mest_915.lote_tanque
	ON KEY (control-z)
      CALL pol1116_popup()
	END CONSTRUCT
	
   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      if p_ies_cons then
         LET mr_laudo_mest.* = mr_laudo_mestr.*
         call pol1116_exibe_dados()
      end if
      ERROR "Consulta Cancelada."
      RETURN FALSE
   END IF

      LET sql_stmt = "SELECT * FROM laudo_mest_915 ",
                     " WHERE cod_empresa = '",p_cod_empresa,"'",
                     " AND ",where_clause CLIPPED,
                     " ORDER BY num_laudo, num_versao desc "

   PREPARE var_query FROM sql_stmt
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_laudo_mest.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa n�o Encontrados"
      LET m_ies_cons = FALSE
      RETURN FALSE
   ELSE
      LET m_ies_cons = TRUE
      LET mr_laudo_mestr.* = mr_laudo_mest.*
      CALL pol1116_carrega_array()
      MESSAGE "Consulta Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      RETURN TRUE 
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION pol1116_carrega_array()
#-------------------------------#

   DEFINE l_tip_analise  LIKE it_analise_915.tip_analise

   LET p_ind = 1
   INITIALIZE ma_tela, ma_id TO NULL
   
   DECLARE cq_array CURSOR FOR
    SELECT tip_analise, 
           especificacao_de, 
           especificacao_ate,
           val_resultado,
           observacao
      FROM laudo_item_915
     WHERE cod_empresa = p_cod_empresa
       AND num_laudo   = mr_laudo_mest.num_laudo
       AND num_versao  = mr_laudo_mest.num_versao

   FOREACH cq_array INTO pr_tip_analise[p_ind].tip_analise,
                         ma_tela[p_ind].especificacao_de,  
                         ma_tela[p_ind].especificacao_ate,  
                         ma_resu[p_ind].val_resultado,  
                         ma_resu[p_ind].observacao  

      LET l_tip_analise = pr_tip_analise[p_ind].tip_analise

      SELECT den_analise_port
        INTO ma_tela[p_ind].den_analise
        FROM it_analise_915
       WHERE cod_empresa = p_cod_empresa
         AND tip_analise = l_tip_analise

      select ies_validade
        from it_analise_915
       where cod_empresa = p_cod_empresa
         and tip_analise = l_tip_analise
         and ies_validade =  'S'

      if status = 0 then
         let ma_tela[p_ind].especie = 'V'
      else
         let ma_tela[p_ind].especie = 'N'
      end if
      
      LET p_ind = p_ind + 1

   END FOREACH

   CALL pol1116_exibe_dados() 
   CALL pol1116_mostra_analise()
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1116_exibe_dados()
#-----------------------------#

   DEFINE l_tipo         CHAR(10),
          l_ies_situacao CHAR(1)

   if mr_tela.num_nf is null or mr_tela.num_nf = ' ' then
      select num_nff
        into mr_laudo_mest.num_nf
        from ordem_montag_mest
       where cod_empresa = p_cod_empresa
         and num_om      = mr_laudo_mest.num_om
      
      if mr_laudo_mest.num_nf is not null then
         SELECT serie_nota_fiscal,
                dat_hor_emissao
           INTO mr_laudo_mest.ser_nf,
                p_dat_hor_emis
           FROM fat_nf_mestre
          WHERE empresa = p_cod_empresa
            AND nota_fiscal = mr_laudo_mest.num_nf
            AND cliente = mr_laudo_mest.cod_cliente
            AND tip_docum = 'FATPRDSV'

         if status = 0 then
            let mr_laudo_mest.dat_emis_nf = EXTEND(p_dat_hor_emis, year to day)
         end if

         update laudo_mest_915
            set num_nf  = mr_laudo_mest.num_nf,
            ser_nf      = mr_laudo_mest.ser_nf,
            dat_emis_nf = mr_laudo_mest.dat_emis_nf
          where cod_empresa = p_cod_empresa
            and num_laudo   = mr_laudo_mest.num_laudo
            and num_versao  = mr_laudo_mest.num_versao
      end if
   end if

   DISPLAY BY NAME mr_laudo_mest.cod_empresa
   DISPLAY BY NAME mr_laudo_mest.num_laudo
   DISPLAY BY NAME mr_laudo_mest.num_versao
   DISPLAY BY NAME mr_laudo_mest.versao_atual
   DISPLAY BY NAME mr_laudo_mest.dat_emissao
   DISPLAY BY NAME mr_laudo_mest.num_nf
   DISPLAY BY NAME mr_laudo_mest.ser_nf
   DISPLAY BY NAME mr_laudo_mest.num_om
   DISPLAY BY NAME mr_laudo_mest.cod_cliente
   DISPLAY BY NAME mr_laudo_mest.cod_item
   DISPLAY BY NAME mr_laudo_mest.seq_item_nf
   DISPLAY BY NAME mr_laudo_mest.lote_tanque
   DISPLAY BY NAME mr_laudo_mest.qtd_laudo
   DISPLAY BY NAME mr_laudo_mest.num_pa
   DISPLAY BY NAME mr_laudo_mest.dat_fabricacao
   DISPLAY BY NAME mr_laudo_mest.dat_validade
   DISPLAY BY NAME mr_laudo_mest.dat_emis_nf   
   DISPLAY BY NAME mr_laudo_mest.ies_impresso
   DISPLAY BY NAME mr_laudo_mest.texto_1
   DISPLAY BY NAME mr_laudo_mest.texto_2

   CALL pol1116_busca_den_item()
   CALL pol1116_busca_nom_cliente()

END FUNCTION       

#--------------------------------#
 FUNCTION pol1116_busca_den_item() 
#--------------------------------#

   DEFINE l_den_item LIKE item.den_item

   SELECT den_item
      INTO l_den_item
   FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item = mr_laudo_mest.cod_item

   DISPLAY l_den_item TO den_item        
   

   SELECT den_item_portugues
      INTO l_den_item
   FROM item_915
   WHERE cod_empresa = p_cod_empresa
     AND cod_item_analise = mr_laudo_mest.cod_item_analise

   #DISPLAY l_den_item TO den_item_analise        

END FUNCTION

#-----------------------------------#
 FUNCTION pol1116_busca_nom_cliente()
#-----------------------------------#
   DEFINE l_nom_cliente          LIKE clientes.nom_cliente 

   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes 
    WHERE cod_cliente = mr_laudo_mest.cod_cliente

   DISPLAY l_nom_cliente TO nom_cliente

END FUNCTION      

#-------------------------------#
FUNCTION pol1116_mostra_analise()
#-------------------------------#

   CALL SET_COUNT(p_ind - 1)

   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_laudo.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      BEFORE FIELD especie
         let p_especie = ma_tela[p_index].especie
#         call pol1116_exibe_resultado()


   			 if ma_resu[p_index].observacao is not null then
         	let p_resultado = ma_resu[p_index].observacao
         else
          let p_resultado = ma_resu[p_index].val_resultado
   			 end IF
   			 
         DISPLAY p_resultado to resultado
         
      AFTER FIELD especie
         if ma_tela[p_index].especie <> p_especie then
            let ma_tela[p_index].especie = p_especie
            DISPLAY p_especie to s_laudo[s_index].especie
            NEXT FIELD especie
         end if
         
         IF ma_tela[p_index].especie IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN
            ELSE
               NEXT FIELD especie
            END IF
         END IF

   END INPUT

END FUNCTION

#----------------------------------#
 FUNCTION pol1116_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM laudo_mest_915  
     WHERE cod_empresa = p_cod_empresa
       AND num_laudo   = mr_laudo_mest.num_laudo
       AND num_versao  = mr_laudo_mest.num_versao
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","laudo_mest_915")
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
FUNCTION POL1116_modificacao()
#----------------------------#
   
   IF NOT pol1116_prende_registro() THEN
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_prende
      RETURN FALSE
   END IF
   
   If pol1116_edita_laudo() then
      update laudo_mest_915
         set #num_nf = mr_laudo_mest.num_nf,
             #ser_nf = mr_laudo_mest.ser_nf,
             #qtd_laudo = mr_laudo_mest.qtd_laudo,
             texto_1   = mr_laudo_mest.texto_1,
             texto_2   = mr_laudo_mest.texto_2
       where cod_empresa = p_cod_empresa
         and num_laudo   = mr_laudo_mest.num_laudo
         and num_versao  = mr_laudo_mest.num_versao
   
      If status = 0 then
         Let p_operacao = 'ALTEROU'
         call pol1116_grava_audit() RETURNING p_status
         call pol1116_edita_analise()
         CALL log085_transacao("COMMIT")
         CLOSE cq_prende
         RETURN TRUE
      Else
         call log003_err_sql('Atualizando','laudo_mest_915')
      End if
   End if
   
   CALL log085_transacao("ROLLBACK")
   CLOSE cq_prende
   let mr_laudo_mest.* = mr_laudo_mestr.*
   CALL pol1116_exibe_dados()

   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1116_grava_audit()
#-----------------------------#

   DEFINE p_id_registro Integer,
          p_dat_atual   Date,
          p_hora        CHAR(08)
   
   select max(id_registro)
     into p_id_registro
     from laudo_audit_915
    where cod_empresa = p_cod_empresa

   if status <> 0 then
      call log003_err_sql('Lendo','laudo_audit_915') 
      RETURN FALSE
   end if
   
   if p_id_registro is null then
      let p_id_registro = 1
   else
      let p_id_registro = p_id_registro + 1
   end if
   
   let p_dat_atual = today
   let p_hora = EXTEND(CURRENT, HOUR TO SECOND)
      
   INSERT INTO laudo_audit_915
      VALUES(p_id_registro,
             p_cod_empresa,
             mr_laudo_mest.num_laudo,
             mr_laudo_mest.num_versao,
             p_dat_atual,
             p_hora,
             p_user,
             p_operacao)

   if status <> 0 then
      call log003_err_sql('Inserindo','laudo_audit_915')
      RETURN FALSE 
   end if
   
   RETURN TRUE
   
end FUNCTION

#-----------------------------#
FUNCTION pol1116_edita_laudo()
#-----------------------------#

   let INT_FLAG = false
   
   INPUT BY NAME 
      #mr_laudo_mest.num_nf,  
      #mr_laudo_mest.ser_nf,  
      #mr_laudo_mest.qtd_laudo,
      mr_laudo_mest.texto_1,  
      mr_laudo_mest.texto_2  
         WITHOUT DEFAULTS  

      {AFTER FIELD num_nf
         IF mr_laudo_mest.num_nf IS NULL THEN 
            let mr_laudo_mest.ser_nf = null
            DISPLAY '' to ser_nf
            next field qtd_laudo
         end if
         
         select count(num_nff)
           into p_count
           from ordem_montag_mest
          where cod_empresa = p_cod_empresa
            and num_om      = mr_laudo_mest.num_om
            and num_nff     = mr_laudo_mest.num_nf
            
         if status <> 0 then
            CALL log003_err_sql("Lendo","ordem_montag_mest")
            RETURN false
         end if
         
         if p_count = 0 then
            error 'NF n�o enexistente, para a OM ', mr_laudo_mest.num_om
            next field num_nf
         end if

      BEFORE FIELD ser_nf
         IF mr_laudo_mest.num_nf IS NULL THEN 
            next field num_nf
         end if
         
      AFTER FIELD ser_nf
         IF mr_laudo_mest.ser_nf IS NULL THEN
            error 'Campo com preenchimento obrigat�rio!!!'
            NEXT FIELD ser_nf
         END IF
            
         SELECT trans_nota_fiscal
           INTO p_trans_nota_fiscal
           FROM fat_nf_mestre
          WHERE empresa = p_cod_empresa
            AND nota_fiscal = mr_laudo_mest.num_nf
            AND serie_nota_fiscal = mr_laudo_mest.ser_nf
            AND cliente = mr_laudo_mest.cod_cliente
   
         if status = 100 then
            error 'NF n�o enexistente, para o cliente ', mr_laudo_mest.cod_cliente
            next field num_nf
         else
            if status <> 0 then
               CALL log003_err_sql("Lendo","fat_nf_mestre")
               RETURN false
            end if
         end if
    }
      AFTER FIELD qtd_laudo 
         IF mr_laudo_mest.qtd_laudo IS NULL OR
            mr_laudo_mest.qtd_laudo = ' ' THEN
            ERROR "Campo de preenchimento obrigat�rio."
            NEXT FIELD qtd_laudo 
         END IF
 
         If not POL1116_checa_qtd_laudo() then
            next FIELD qtd_laudo
         end if
         
    END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------# 
 FUNCTION POL1116_checa_qtd_laudo()
#----------------------------------# 
   
   DEFINE l_qtd_item         DECIMAL(15,3),
          l_qtd_laudo        LIKE laudo_mest_915.qtd_laudo

   IF mr_laudo_mest.num_nf IS NOT NULL AND
      mr_laudo_mest.num_nf <> ' ' THEN
      SELECT SUM(qtd_item)
        INTO l_qtd_item
        FROM fat_nf_item
       WHERE empresa           = p_cod_empresa
         AND trans_nota_fiscal = p_trans_nota_fiscal
         AND item              = mr_laudo_mest.cod_item
		 AND seq_item_nf		= mr_tela.seq_item_nf
      IF l_qtd_item IS NULL OR
         l_qtd_item = 0 THEN
         ERROR "Item sem quantidade na Nota Fiscal." 
         RETURN FALSE
      END IF 
   ELSE
      SELECT SUM(qtd_reservada)
        INTO l_qtd_item
        FROM ordem_montag_item
       WHERE cod_empresa = p_cod_empresa
         AND num_om      = mr_laudo_mest.num_om 
         AND cod_item    = mr_laudo_mest.cod_item

      IF l_qtd_item IS NULL OR
         l_qtd_item = 0 THEN
         ERROR "Item sem quantidade na Ordem de Montagem." 
         RETURN FALSE
      END IF 
   END IF       

      
   SELECT SUM(qtd_laudo)
     INTO l_qtd_laudo
     FROM laudo_mest_915
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = mr_laudo_mest.num_nf
      AND ser_nff     = mr_laudo_mest.ser_nf
      AND cod_item    = mr_laudo_mest.cod_item
      AND num_laudo  <> mr_laudo_mest.num_laudo
         
   IF l_qtd_laudo IS NULL THEN
      LET l_qtd_laudo = 0
   END IF 

   IF l_qtd_item < mr_laudo_mest.qtd_laudo THEN
      ERROR "Quantidade informada maior que a Quantidade da OM/NF."
      RETURN FALSE
   END IF 

   IF l_qtd_item >= (mr_laudo_mest.qtd_laudo + l_qtd_laudo) THEN
      RETURN TRUE
   ELSE
      ERROR "Quantidade informada maior que o Saldo Restante da OM/NF."
      RETURN FALSE
   END IF 

END FUNCTION


#-------------------------------#
FUNCTION pol1116_edita_analise()
#-------------------------------#
   
   DISPLAY 'Enter = Editar resultado' AT 21,54
   
   CALL SET_COUNT(p_ind - 1)

   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_laudo.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      BEFORE FIELD especie
         let p_especie = ma_tela[p_index].especie
   			 if p_observacao is not null then
         	let p_resultado = ma_resu[p_index].observacao
         else
          let p_resultado = ma_resu[p_index].val_resultado
   			 end if
#         call pol1116_exibe_resultado()         
         
      AFTER FIELD especie
         if ma_tela[p_index].especie <> p_especie then
            let ma_tela[p_index].especie = p_especie
            DISPLAY p_especie to s_laudo[s_index].especie
            NEXT FIELD especie
         end if
         
         IF ma_tela[p_index].especie IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN
            ELSE
               NEXT FIELD especie
            END IF
         END IF

         IF FGL_LASTKEY() = 13 THEN
            IF ma_tela[p_index].especie IS NOT NULL THEN
               LET l_tip_analise = pr_tip_analise[p_index].tip_analise
               CALL pol1116_edita_resultado()
               NEXT FIELD especie
            END IF
         END IF         
         
   END INPUT

   DISPLAY '                        ' AT 21,54

end FUNCTION

#--------------------------------#
FUNCTION pol1116_exibe_resultado()
#--------------------------------#

   IF ma_tela[p_index].especie IS NULL THEN
      display '' to resultado
      RETURN
   end if
   
   select tip_analise,
          val_resultado,
          observacao
     into l_tip_analise,
          p_val_resultado,
          p_observacao
     from laudo_item_915
    where cod_empresa = p_cod_empresa
      AND num_laudo   = mr_laudo_mest.num_laudo
      AND num_versao  = mr_laudo_mest.num_versao

   if p_observacao is not null then
      let p_resultado = p_observacao
   else
      let p_resultado = p_val_resultado
   end if

   DISPLAY p_resultado to resultado

END FUNCTION

#--------------------------------#
FUNCTION pol1116_edita_resultado()
#--------------------------------#
   
   DEFINE resultado_ant like laudo_item_915.val_resultado
   
   LET resultado_ant = p_resultado
   LET INT_FLAG = false
   
   INPUT p_resultado WITHOUT DEFAULTS
    FROM resultado
     
                       
      AFTER FIELD resultado

   END INPUT 

   IF INT_FLAG THEN
      let p_resultado = resultado_ant
      DISPLAY p_resultado TO resultado
      RETURN 
   END IF
   
   let p_val_resultado = p_resultado
   
   BEGIN WORK
   
   update laudo_item_915
      set val_resultado = p_val_resultado,
          observacao = null
    where cod_empresa = p_cod_empresa
      and tip_analise = l_tip_analise
      AND num_laudo   = mr_laudo_mest.num_laudo
      AND num_versao  = mr_laudo_mest.num_versao
   
   COMMIT WORK
   
end FUNCTION

#-----------------------------------#
 FUNCTION POL1116_paginacao(l_funcao)
#-----------------------------------#
   DEFINE l_funcao          CHAR(20)

   IF m_ies_cons THEN
      LET mr_laudo_mestr.* = mr_laudo_mest.*
      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO
                            mr_laudo_mest.*
            WHEN l_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO
                            mr_laudo_mest.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "N�o Existem mais Registros nesta Dire��o"
            LET mr_laudo_mest.* = mr_laudo_mestr.*
            EXIT WHILE
         END IF                                            

         SELECT *
           INTO mr_laudo_mest.*
           FROM laudo_mest_915
          WHERE cod_empresa = mr_laudo_mest.cod_empresa
            AND num_laudo   = mr_laudo_mest.num_laudo
         
         IF SQLCA.SQLCODE = 0 THEN
            CALL pol1116_carrega_array()
            EXIT WHILE
         END IF
      END WHILE        
   ELSE
      ERROR "N�o Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION    

#-----------------------------#
FUNCTION POL1116_nova_versao()
#-----------------------------#

   IF not log004_confirm(13,42) THEN
      RETURN FALSE
   end if
   
   let p_nova_versao = 'S'
   
   update laudo_mest_915
      set versao_atual = 'N'
    where cod_empresa = p_cod_empresa
      and num_laudo   = mr_laudo_mest.num_laudo
      and num_versao  = mr_laudo_mest.num_versao

   if status <> 0 then
      call log003_err_sql('Atualizando','laudo_mest_915')
      RETURN FALSE
   End if
   
   let p_versao_ant = mr_laudo_mest.num_versao
   let mr_laudo_mest.num_versao = mr_laudo_mest.num_versao + 1
   
   INSERT INTO laudo_mest_915
      values(mr_laudo_mest.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","LAUDO_MEST_915")
      RETURN FALSE
   END IF
      
   INSERT INTO pa_laudo_915 
          VALUES(p_cod_empresa,                                    
                 mr_laudo_mest.num_laudo,                             
                 mr_laudo_mest.num_versao,                                                   
                 mr_laudo_mest.num_pa)
                          
   IF status <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","PA_LAUDO_915")                                               
       RETURN FALSE
   end if

   let p_num_versao = mr_laudo_mest.num_versao
   let m_item_analise = mr_laudo_mest.cod_item_analise
   let l_cod_cliente = mr_laudo_mest.cod_cliente
   let p_num_laudo   = mr_laudo_mest.num_laudo
   let p_cod_item    = mr_laudo_mest.cod_item
   let p_lote_tanque = mr_laudo_mest.lote_tanque
   let p_num_pa      = mr_laudo_mest.num_pa
   let p_dat_producao = mr_laudo_mest.dat_fabricacao
   LET p_identif_estoque = mr_laudo_mest.identif_estoque

   if not pol1116_inclui_itens() then
      RETURN FALSE
   end if

   Let p_operacao = 'INCLUIU VERSAO'

   IF NOT pol1116_grava_audit() THEN
      RETURN FALSE
   END IF
   
   LET p_msg = 'Nova vers�o gerada com sucesso!'
   #call log0030_mensagem(p_msg, 'excla')
   ERROR p_msg
   
   
   CALL pol1116_carrega_array()
   
   let m_ies_cons = FALSE
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1116_carrega_anali()
#-------------------------------#

   DEFINE l_tip_analise  LIKE it_analise_915.tip_analise,
          l_tem_cli             SMALLINT

   LET p_ind = 1
   INITIALIZE ma_tela, ma_id TO NULL

    SELECT count(p.cod_empresa)
      INTO p_count                                                                 
      FROM especific_915 a, par_laudo_915 p
    	WHERE a.cod_empresa = p_cod_empresa                                 
      	AND a.cod_item    = p_cod_item   
      	AND p.cod_empresa = a.cod_empresa
      	AND p.cod_item    = a.cod_item
      	AND p.tip_analise = a.tip_analise

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_laudo_915')
      RETURN FALSE
   END IF
                                                                                    
   IF p_count = 0 THEN                                                           
      LET p_msg = 'Fata especifica��es do item\n ou par�metros p/ o laudo.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
    SELECT count(cod_empresa)
      into p_count                                                                 
      FROM par_laudo_915                                                               
     WHERE cod_empresa = p_cod_empresa                                                 
       AND cod_item    = p_cod_item                                                
       AND cod_cliente = l_cod_cliente                                                 
                                                                                    
   IF p_count > 0 THEN                                                           
      LET l_tem_cli = TRUE                                                             
   ELSE                                                                                
      LET l_tem_cli = FALSE                                                            
   END IF 
   
   IF l_tem_cli THEN                                                                   
   	DECLARE cq_array CURSOR FOR
			SELECT DISTINCT a.tip_analise,
		       	a.val_especif_de,
		       	a.val_especif_ate, 
		       	a.tip_analise  
      FROM especific_915 a, par_laudo_915 p
    	WHERE a.cod_empresa = p_cod_empresa                                 
      	AND a.cod_item    = p_cod_item   
      	AND a.cod_cliente = l_cod_cliente
      	AND p.cod_empresa = a.cod_empresa
      	AND p.cod_item = a.cod_item
      	AND p.tip_analise = a.tip_analise
   ELSE                                                                                
   	DECLARE cq_array CURSOR FOR
			SELECT DISTINCT a.tip_analise,
		       	a.val_especif_de,
		       	a.val_especif_ate, 
		       	a.tip_analise  
      FROM especific_915 a, par_laudo_915 p
    	WHERE a.cod_empresa = p_cod_empresa                                 
      	AND a.cod_item    = p_cod_item   
      	AND a.cod_cliente IS NULL
      	AND p.cod_empresa = a.cod_empresa
      	AND p.cod_item = a.cod_item
      	AND p.tip_analise = a.tip_analise
   END IF                                                                              
                                                                                
   
   FOREACH cq_array INTO l_tip_analise,
                         ma_tela[p_ind].especificacao_de,  
                         ma_tela[p_ind].especificacao_ate,  
                         ma_id[p_ind].num_id
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_array')
         RETURN FALSE
      END IF
      
      SELECT den_analise_port
        INTO ma_tela[p_ind].den_analise
        FROM it_analise_915
       WHERE cod_empresa = p_cod_empresa
         AND tip_analise = l_tip_analise

      select ies_validade
        from it_analise_915
       where cod_empresa = p_cod_empresa
         and tip_analise = l_tip_analise
         and ies_validade =  'S'

      if status = 0 then
         let ma_tela[p_ind].especie = 'V'
      else
         let ma_tela[p_ind].especie = 'N'
      end if
      
      LET p_ind = p_ind + 1

   END FOREACH

   IF p_ind = 1 THEN
      LET p_msg = 'Os itens da an�lise n�o\n foram localizados.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   IF NOT pol1116_exibe_analise() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1116_exibe_analise()
#-------------------------------#

   LET INT_FLAG = FALSE
   
   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_laudo.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      BEFORE FIELD especie
         let p_especie = ma_tela[p_index].especie
         LET l_tip_analise = ma_id[p_index].num_id
         call pol1116_exibe_res_anali()
         
      AFTER FIELD especie
         if ma_tela[p_index].especie <> p_especie then
            let ma_tela[p_index].especie = p_especie
            DISPLAY p_especie to s_laudo[s_index].especie
            NEXT FIELD especie
         end if
         
         IF ma_tela[p_index].especie IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN
            ELSE
               NEXT FIELD especie
            END IF
         END IF

   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION


#--------------------------------#
FUNCTION pol1116_exibe_res_anali()
#--------------------------------#

   DEFINE z_ind  SMALLINT

   IF ma_tela[p_index].especie IS NULL THEN
      DISPLAY '' to resultado
      RETURN
   END IF
  
   LET p_observacao = NULL 
  
   SELECT DISTINCT ies_validade,
                  ies_texto
     INTO p_ies_validade,
          p_ies_texto
     FROM it_analise_915                                                   
    WHERE cod_empresa = p_cod_empresa 
      AND tip_analise = l_tip_analise  

   IF STATUS <> 0 THEN
       call log003_err_sql('lEITURA 2 ','it_analise_915') 
       RETURN
    END IF 
  

   IF p_ies_validade  = 'N'   THEN 
  
  	  SELECT DISTINCT 
	          p.val_analise,
	          p.em_analise
       INTO p_val_resultado,
            p_em_analise
       FROM analise_915 p
      WHERE p.cod_empresa = p_cod_empresa                                 
        AND p.cod_item    = m_item_analise 
        AND p.tip_analise = l_tip_analise
        AND p.lote_tanque = p_lote_tanque
        AND p.num_pa      = p_num_pa
        AND p.identif_estoque = p_identif_estoque
   
      IF STATUS <> 0 THEN
         call log003_err_sql('lEITURA 2 ','analise_915') 
         RETURN
      END IF 
  
      IF p_em_analise  = 'N'   THEN 
  
	      IF p_ies_texto = 'S' THEN
	 		     SELECT COUNT(val_caracter)
			       INTO z_ind 
			       FROM espec_carac_915 
			 	    WHERE cod_empresa = p_cod_empresa
					    AND cod_item      = m_item_analise
					    AND tip_analise   = l_tip_analise
					    AND val_caracter  = p_val_resultado
					    AND cod_cliente   = l_cod_cliente

		       IF z_ind = 0 THEN  
			        SELECT den_caracter
		            INTO p_observacao
		            FROM tipo_caract_915
			         WHERE cod_empresa  = p_cod_empresa
				         AND tip_analise  = l_tip_analise
				         AND val_caracter = p_val_resultado
			           AND cod_cliente  = l_cod_cliente
		       ELSE
				      SELECT val_caracter
						   INTO p_val_resultado
						   FROM espec_carac_915 e
					    WHERE e.cod_empresa  = p_cod_empresa
						    AND e.cod_item     = m_item_analise
						    AND e.tip_analise  = l_tip_analise
						    AND e.cod_cliente  = l_cod_cliente
			
			        SELECT den_caracter
		            INTO p_observacao
		            FROM tipo_caract_915
			         WHERE cod_empresa  = p_cod_empresa
				         AND tip_analise  = l_tip_analise
				         AND val_caracter = p_val_resultado
			           AND cod_cliente  IS NULL
		       END IF
			  
				   
		      IF status <> 0 THEN
			       SELECT den_caracter
			         INTO l_txt_resultado
			         FROM tipo_caract_915
			 	      WHERE cod_empresa  = p_cod_empresa
				        AND tip_analise  = l_tip_analise
				        AND val_caracter = p_val_resultado
				        AND cod_cliente IS NULL
			  
				     IF status <> 0 then
					      call log003_err_sql('Lendo','tipo_caract_915')
				        RETURN FALSE
				     ELSE
					      LET p_observacao = l_txt_resultado  
				     END if 
		      END IF 
      
      END IF          
   
   END IF  
	
   ELSE       
   
      let p_count = 0
         
      if not pol1116_le_analise() then
         RETURN FALSE
      end if  
         
      IF p_count = 0 then
			   let p_em_analise = 'S'
         INITIALIZE l_dat_analise, l_txt_resultado to null
	    ELSE 		
		 	   let p_em_analise = 'N'
      END IF 
		  
      LET p_observacao = l_txt_resultado  
                                                                              
   END IF
  
  IF p_em_analise = 'S'  OR p_em_analise IS NULL THEN
  	LET p_observacao = 'EM ANALISE'
  END IF	


   if p_observacao is not null then
      let p_resultado = p_observacao
   else
      let p_resultado = p_val_resultado
   end if


   DISPLAY p_resultado to resultado

END FUNCTION
   