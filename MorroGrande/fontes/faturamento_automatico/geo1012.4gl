#-----------------------------------------------------------------#
# MODULO..: GEO                                                   #
# SISTEMA.: IMPORTAÇÃO AUTOMATICA DE PEDIDOS DO SOFTSITE GEOSALES #
# PROGRAMA: geo1012                                               #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 17/02/2016                                            #
#-----------------------------------------------------------------#


DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario
 
END GLOBALS

   DEFINE mr_mestre RECORD  
	          codven integer, 
	          numope integer, 
	          chqdev VARCHAR(1),
	          codcli integer,
	          codemp varchar(2),
	          codlote_exp integer,
	          codpgto varchar(50),
	          limexc varchar(1),
	          numpag integer,
	          numrot varchar(30),
	          totope decimal(15,2),
	          cgfcli char(16),
	          numnot integer,
	          basicm decimal(12,2),
	          bassbt integer,
	          codmcn integer,
	          datemi datetime year to second,
	          horsai varchar(5),
	          iescan varchar(1),
	          natope integer,
	          numsel varchar(11),
	          numser varchar(2),
	          obsnot varchar(255),
	          sersel varchar(5),
	          tipnot varchar(1),
	          totmer decimal(12,2),
	          totnot decimal(12,2),
	          totnot_pauta decimal(12,2),
	          num_pedido_cli char(25)
        END RECORD
   DEFINE m_contribuinte            CHAR(01)
   DEFINE mr_itens RECORD  
	          codpro integer,
	          codgrd integer,
	          codmtr integer,
	          codprm varchar(5),
	          codref varchar(20),
	          datval datetime year to second,
	          desctb decimal(12,2),
	          dessbh decimal(12,2),
	          pcticm decimal(12,2),
	          pctipi decimal(12,2),
	          pctred decimal(12,2),
	          predes decimal(12,2),
	          qtdven decimal(15,2),
	          tipope varchar(4),
	          unipro varchar(3),
	          valdes decimal(12,2),
	          valitn decimal(12,2),
	          valliq decimal(12,2),
	          valtot decimal(12,2),
	          xped           char(15),
	          nitemped       integer
        END RECORD

#-------------------------------#
 FUNCTION geo1012_job(l_rotina)
#-------------------------------#
 DEFINE l_rotina           CHAR(50),
        l_den_empresa      CHAR(50),
        l_param1_empresa   CHAR(02),
        l_param2_user      CHAR(08),
        l_status 		   SMALLINT
	
	CALL JOB_get_parametro_gatilho_tarefa(1,0)
    RETURNING l_status, p_cod_empresa

 	CALL JOB_get_parametro_gatilho_tarefa(2,0)
    RETURNING l_status, p_user
	
    CALL geo1012()
    
    RETURN 0
END FUNCTION

#-------------------#
 FUNCTION geo1012()
#-------------------#

   DEFINE l_label                      VARCHAR(50)
        , l_status                     SMALLINT
   
   CALL fgl_setenv("ADVPL","1")
   CALL LOG_connectDatabase("DEFAULT")

   CALL log1400_isolation()
   CALL log0180_conecta_usuario()
   #CALL LOG_initApp('VDPLOG') RETURNING l_status
   #IF NOT l_status THEN
      CALL geo1012_processa()
   #END IF

END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION geo1012_processa()
#--------------------------------------------------------------------#
   define l_sql_stmt char(5000)
   DEFINE l_sql_stmt2 char(5000)
   define l_sequencia smallint
   DEFINE l_num_pedido LIKE pedidos.num_pedido
   DEFINE l_trans_solic_fatura LIKE fat_solic_mestre.trans_solic_fatura
   DEFINE l_nat_oper VARCHAR(3)
   DEFINE l_msg CHAR(76)
   DEFINE l_erro char(999)
   DEFINE l_serie_fatura varchar(3)
   DEFINE l_finalidade varchar(1)
   DEFINE l_status SMALLINT
   DEFINE l_sqlcode char(10)
   DEFINE l_solicitacao_fatura INTEGER
   DEFINE l_cod_cliente char(15)
   DEFINE l_cod_vendedor char(15)
   DEFINE l_cod_manifesto  INTEGER
   DEFINE l_num_remessa    INTEGER
   DEFINE l_ser_remessa    CHAR(3)
   DEFINE l_trans_remessa  INTEGER
   DEFINE l_qtd_item    LIKE fat_nf_item.qtd_item
   DEFINE l_cod_item    LIKE fat_nf_item.item
   DEFINE l_parametro   CHAR(99)
   DEFINE l_desconto    LIKE ped_itens.pct_desc_adic
   DEFINE l_pct_desc    LIKE ped_itens.pct_desc_adic
   DEFINE l_pct_desc_adic LIKE ped_itens.pct_desc_adic
   DEFINE l_trans_nota_fiscal   INTEGER
   
   DEFINE lr_enviados RECORD 
            cod_empresa          char(2),
			cod_repres           decimal(4,0),
			cod_ope              integer,
			num_pedido           integer,
			nota_fiscal          integer,
			serie_nota_fiscal    char(3),
			trans_nota_fiscal    integer
          END RECORD
   DEFINE l_continue SMALLINT
   
   
   
   
   
   ## VERIFICA SE JA FATUROU OS PEDIDOS IMPORTADOS QUE 
   ## AINDA NAO ESTAO COM A NOTA FISCAL INFORMADOS NO CAMPO
   ## E ATUALIZA AS INFORMACOES DA NOTA CASO JA ESTEJA FATURADO
   DECLARE cq_enviados CURSOR WITH HOLD FOR 
   SELECT *
     FROM geo_ope_env
    WHERE cod_empresa = p_cod_empresa
      AND (nota_fiscal IS NULL OR nota_fiscal = "")
   FOREACH cq_enviados INTO lr_enviados.*
      
      SELECT a.trans_nota_fiscal, 
             a.nota_fiscal, 
             a.serie_nota_fiscal
        INTO lr_enviados.trans_nota_fiscal, 
             lr_enviados.nota_fiscal, 
             lr_enviados.serie_nota_fiscal 
        FROM fat_nf_mestre a, fat_nf_item b
       WHERE a.empresa = b.empresa
         AND a.trans_nota_fiscal = b.trans_nota_fiscal
         AND b.seq_item_nf = 1
         AND a.sit_nota_fiscal = 'N'
         AND a.tip_nota_fiscal = 'FATPRDSV'
         AND b.pedido = lr_enviados.num_pedido
         AND b.empresa = lr_enviados.cod_empresa
         
       IF sqlca.sqlcode = 0 THEN
          UPDATE geo_ope_env
             SET trans_nota_fiscal = lr_enviados.trans_nota_fiscal,
                 nota_fiscal = lr_enviados.nota_fiscal,
                 serie_nota_fiscal = lr_enviados.serie_nota_fiscal
           WHERE cod_empresa = p_cod_empresa
             AND cod_ope = lr_enviados.cod_ope
             AND num_pedido = lr_enviados.num_pedido
             AND cod_repres = lr_enviados.cod_repres
           IF sqlca.sqlcode <> 0 THEN
              let l_sqlcode = sqlca.sqlcode
       		  LET l_erro = "ERRO AO ATUALIZAR geo_ope_env. sqlcode: ",l_sqlcode
       		  CALL geo1012_grava_audit(l_erro)
           END IF 
          
          
          DECLARE cq_notas CURSOR WITH HOLD FOR
          SELECT b.qtd_item, 
                 b.item
            FROM fat_nf_mestre a, fat_nf_item b
           WHERE a.empresa = b.empresa
             AND a.trans_nota_fiscal = b.trans_nota_fiscal
             AND b.pedido = lr_enviados.num_pedido
             AND b.empresa = lr_enviados.cod_empresa
          FOREACH cq_notas INTO l_qtd_item, l_cod_item
             
             
             SELECT DISTINCT a.cod_manifesto, a.num_remessa, a.ser_remessa, a.trans_remessa
               INTO l_cod_manifesto, l_num_remessa, l_ser_remessa, l_trans_remessa
               FROM geo_remessa_movto a, geo_manifesto b, fat_nf_repr c, geo_repres_paramet d, fat_nf_mestre e
              WHERE a.cod_empresa = b.cod_empresa
                AND a.cod_manifesto = b.cod_manifesto
                AND a.cod_empresa = c.empresa
                AND c.trans_nota_fiscal = lr_enviados.trans_nota_fiscal
                AND b.cod_resp = d.cod_cliente
                AND d.cod_repres = c.representante
                AND b.sit_manifesto = 'T'
                AND a.tipo_movto = 'E'
                AND a.cod_empresa = p_cod_empresa
				AND e.empresa = c.empresa
				AND e.trans_nota_fiscal = c.trans_nota_fiscal
				AND e.sit_nota_fiscal = 'N'
				AND e.dat_hor_emissao >= b.dat_manifesto
             
             IF l_num_remessa IS NULL OR l_num_remessa = " " OR l_num_remessa = 0 THEN
                CONTINUE FOREACH
             END IF 
             
             WHENEVER ERROR CONTINUE
             INSERT INTO geo_remessa_movto VALUES (p_cod_empresa,
                                                   l_cod_manifesto,
                                                   l_num_remessa,
                                                   l_ser_remessa,
                                                   l_trans_remessa,
                                                   "S",
                                                   l_cod_item,
                                                   l_qtd_item,
                                                   lr_enviados.nota_fiscal,
                                                   lr_enviados.serie_nota_fiscal,
                                                   lr_enviados.trans_nota_fiscal,
                                                   TODAY
                                                   )
             WHENEVER ERROR STOP
             IF sqlca.sqlcode <> 0 THEN
                let l_sqlcode = sqlca.sqlcode
       		    LET l_erro = "ERRO AO INSERIR geo_remessa_movto. sqlcode: ",l_sqlcode
       		    CALL geo1012_grava_audit(l_erro)
             END IF 
          END FOREACH
       END IF 
   END FOREACH
   
   CALL log2250_busca_parametro(p_cod_empresa,'geo_instancia_bd')
   RETURNING l_parametro, l_status
   
   
   ## VARRE AS TABELAS GEOSALES PARA IMPORTAR 
   ## OS PEDIDOS E GERAR A SOLICITACAO DE FATURAMENTO
   let l_sql_stmt = " SELECT DISTINCT a.codven, ",
					               " a.numope, ",
					               " a.chqdev, ",
					               " a.codcli, ",
					               " a.codemp, ",
					               " a.codlote_exp, ",
					               " a.codpgto, ",
					               " a.limexc, ",
					               " a.numpag, ",
					               " a.numrot, ",
					               " a.totope, ",
					               " a.cgfcli, ",
					               " b.numnot, ",
					               " b.basicm, ",
					               " b.bassbt, ",
					               " b.codmcn, ",
					               " b.datemi, ",
					               " b.horsai, ",
					               " b.iescan, ",
					               " b.natope, ",
					               " b.numsel, ",
					               " b.numser, ",
					               " b.obsnot, ",
					               " b.sersel, ",
					               " b.tipnot, ",
					               " b.totmer, ",
					               " b.totnot, ",
					               " b.totnot_pauta, b.num_pedido_cli ",
				     " FROM ",l_parametro CLIPPED,"svnope a, ",
				     "      ",l_parametro CLIPPED,"svnitn c, ",
					 "      ",l_parametro CLIPPED,"svnnot b ",
				    " WHERE a.codven = b.codven ",
				     "  AND a.numope = b.numope ",
				     "  AND a.codemp = '",p_cod_empresa CLIPPED,"'",
				         "   AND c.codven = a.codven",
					     "     AND c.numope = a.numope",
					     "     AND c.numnot = b.numnot",
				     
#" AND a.numope > '16'",	     
				     "  AND NOT EXISTS (SELECT c.* ",
				                       "  FROM geo_ope_env c ",
				                       " WHERE c.cod_empresa = a.codemp ",
				                       "   AND c.cod_repres = a.codven ",
				                       "   AND c.cod_ope = a.numope ) "
   
   
   PREPARE var_query FROM l_sql_stmt
   DECLARE cq_dados_svn CURSOR WITH HOLD FOR var_query
   FOREACH cq_dados_svn INTO mr_mestre.*
      
   
      CALL log085_transacao("BEGIN")
      
      
      CALL vdpr100_criar_temps_pedido_fatura(TRUE)
      CALL supr11_cria_temporarias_reserva()
      CALL supr9_cria_temporarias_estoque()
      
        SELECT *
       	  FROM cond_pgto
       	 WHERE cod_cnd_pgto = mr_mestre.codpgto
       	if sqlca.sqlcode <> 0 then
       	   let l_sqlcode = sqlca.sqlcode
       	   CALL log085_transacao("ROLLBACK")
       	   LET l_erro = "CONDICAO DE PAGAMENTO ",mr_mestre.codpgto," NAO FOI ENCONTRADA NA TABELA cond_pgto. sqlcode: ",l_sqlcode
       	   CALL geo1012_grava_audit(l_erro)
           CONTINUE FOREACH
       	end if 
       	
       	
       	LET l_cod_cliente = mr_mestre.codcli
       	SELECT *
       	  FROM clientes
       	 WHERE cod_cliente = l_cod_cliente
       	IF sqlca.sqlcode <> 0 THEN
       	   LET l_cod_cliente = "0",l_cod_cliente CLIPPED
       	   SELECT *
       	     FROM clientes
       	    WHERE cod_cliente = l_cod_cliente
       	   IF sqlca.sqlcode <> 0 THEN
	       	   let l_sqlcode = sqlca.sqlcode
	       	   CALL log085_transacao("ROLLBACK")
	       	   LET l_erro = "CLIENTE ",l_cod_cliente," NAO FOI ENCONTRADO NA TABELA clientes. sqlcode: ",l_sqlcode
	       	   CALL geo1012_grava_audit(l_erro)
	       	   CONTINUE FOREACH
	       END IF 
        END IF 
      
        SELECT val_parametro
       	  INTO l_num_pedido
       	  FROM log_val_parametro
       	 WHERE empresa = p_cod_empresa
       	   AND parametro = 'num_prx_pedido'
       	if sqlca.sqlcode = 0 then 
       		UPDATE log_val_parametro
       		   SET val_parametro = l_num_pedido + 1
       		 WHERE empresa = p_cod_empresa
       		   AND parametro = 'num_prx_pedido'
       		if sqlca.sqlcode = 0 then
       		   UPDATE par_vdp
       		      SET num_prx_pedido = l_num_pedido + 1
       		    WHERE cod_empresa = p_cod_empresa
       		   if sqlca.sqlcode = 0 then
       		      CALL log085_transacao("COMMIT")
       		   ELSE 
       		      let l_sqlcode = sqlca.sqlcode
       		   	  CALL log085_transacao("ROLLBACK")
       		   	  LET l_erro = "ERRO AO ATUALIZAR par_vdp. sqlcode: ",l_sqlcode
       		   	  CALL geo1012_grava_audit(l_erro)
       		   	  CONTINUE FOREACH
       		   end if 
       		ELSE
       		   let l_sqlcode = sqlca.sqlcode
       		   CALL log085_transacao("ROLLBACK")
       		   LET l_erro = "ERRO AO ATUALIZAR log_val_parametro PARAMETRO num_prx_pedido. sqlcode: ",l_sqlcode
       		   CALL geo1012_grava_audit(l_erro)
       		   CONTINUE FOREACH
       		end if 
        ELSE
        	let l_sqlcode = sqlca.sqlcode
           CALL log085_transacao("ROLLBACK")
           LET l_erro = "PARAMETRO num_prx_pedido NAO FOI ENCONTRADO NA TABELA log_val_parametro. sqlcode: ",l_sqlcode
       	   CALL geo1012_grava_audit(l_erro)
           CONTINUE FOREACH
       	end if 
       	
       	CALL log085_transacao("BEGIN")
       	
        IF mr_mestre.tipnot = "V" THEN
           CALL log2250_busca_parametro(p_cod_empresa,'geo_nat_oper_venda')
           RETURNING l_parametro, l_status
           
           IF l_parametro IS NULL OR l_parametro = " " THEN
              LET l_parametro = "11"
           END IF 
           
       	   LET l_nat_oper = l_parametro CLIPPED
       	ELSE 
       	   LET l_nat_oper = "100"
       	END IF 
       	
       	if UPSHIFT(mr_mestre.cgfcli) = "ISENTO" OR mr_mestre.cgfcli IS NULL OR mr_mestre.cgfcli = " " THEN
       	   LET l_finalidade = "2"
       	ELSE
       	   LET l_finalidade = "1"
       	END IF
       	
       	
       	CALL vdpm46_pedidos_set_null()
       	CALL vdpm46_pedidos_set_cod_empresa(p_cod_empresa)
		CALL vdpm46_pedidos_set_num_pedido(l_num_pedido)
		CALL vdpm46_pedidos_set_cod_cliente(l_cod_cliente)
		CALL vdpm46_pedidos_set_pct_comissao(0)
		CALL vdpm46_pedidos_set_num_pedido_repres(NULL)
		CALL vdpm46_pedidos_set_dat_emis_repres(mr_mestre.datemi)
		CALL vdpm46_pedidos_set_cod_nat_oper(l_nat_oper)
		CALL vdpm46_pedidos_set_cod_transpor(NULL)
		CALL vdpm46_pedidos_set_cod_consig(NULL)
		CALL vdpm46_pedidos_set_ies_finalidade(l_finalidade)
		CALL vdpm46_pedidos_set_ies_frete(1)
		CALL vdpm46_pedidos_set_ies_preco("F")
		CALL vdpm46_pedidos_set_cod_cnd_pgto(mr_mestre.codpgto)
		CALL vdpm46_pedidos_set_pct_desc_financ(0)
		CALL vdpm46_pedidos_set_ies_embal_padrao(3)
		CALL vdpm46_pedidos_set_ies_tip_entrega(1)
		CALL vdpm46_pedidos_set_ies_aceite("N")
		CALL vdpm46_pedidos_set_ies_sit_pedido("N")
		CALL vdpm46_pedidos_set_dat_pedido(mr_mestre.datemi)
		CALL vdpm46_pedidos_set_num_pedido_cli(mr_mestre.num_pedido_cli) #GEOSALES TEM QUE ENVIAR
		CALL vdpm46_pedidos_set_pct_desc_adic(0) #GEOSALES TEM QUE ENVIAR
		CALL vdpm46_pedidos_set_num_list_preco(NULL) # VAMOS VERIFICAR
		CALL vdpm46_pedidos_set_cod_repres(mr_mestre.codven)
		CALL vdpm46_pedidos_set_cod_repres_adic(NULL)
		CALL vdpm46_pedidos_set_dat_alt_sit(mr_mestre.datemi)
		CALL vdpm46_pedidos_set_dat_cancel(NULL)
		CALL vdpm46_pedidos_set_cod_tip_venda(2)
		CALL vdpm46_pedidos_set_cod_motivo_can(NULL)
		CALL vdpm46_pedidos_set_dat_ult_fatur(NULL)
		CALL vdpm46_pedidos_set_cod_moeda(1)
		CALL vdpm46_pedidos_set_ies_comissao("S")
		CALL vdpm46_pedidos_set_pct_frete(0)
		CALL vdpm46_pedidos_set_cod_tip_carteira("01")
		CALL vdpm46_pedidos_set_num_versao_lista(0)
		CALL vdpm46_pedidos_set_cod_local_estoq(NULL)
		
		IF NOT vdpt46_pedidos_inclui(TRUE,TRUE) THEN
		   let l_sqlcode = sqlca.sqlcode
           CALL log085_transacao("ROLLBACK")
           LET l_erro = "FALHA AO INSERIR DADOS NA TABELA pedidos. sqlcode: ",l_sqlcode
       	   CALL geo1012_grava_audit(l_erro)
           CONTINUE FOREACH
        END IF
        
        CALL log2250_busca_parametro(p_cod_empresa,'geo_instancia_bd')
        RETURNING l_parametro, l_status
   
        
        LET l_sql_stmt2 = " SELECT DISTINCT  c.codpro, ",
							               " c.codgrd, ",
							               " c.codmtr, ",
							               " c.codprm, ",
							               " c.codref, ",
							               " c.datval, ",
							               " c.desctb, ",
							               " c.dessbh, ",
							               " c.pcticm, ",
							               " c.pctipi, ",
							               " c.pctred, ",
							               " c.predes, ",
							               " c.qtdven, ",
							               " c.tipope, ",
							               " c.unipro, ",
							               " c.valdes, ",
							               " c.valitn, ",
							               " c.valliq, ",
							               " c.valtot, c.xped, c.nitemped ",
			                " FROM ",l_parametro CLIPPED,"svnitn c ",
					     "   WHERE c.codven = '",mr_mestre.codven,"'",
					     "     AND c.numope = '",mr_mestre.numope,"'",
					     "     AND c.numnot = '",mr_mestre.numnot,"'"
        PREPARE var_query2 FROM l_sql_stmt2
		DECLARE cq_dados_svn2 CURSOR WITH HOLD FOR var_query2
		let l_sequencia = 1
		
		LET l_continue = FALSE
       	
		FOREACH cq_dados_svn2 INTO mr_itens.*
	       	
	       	CALL vdpm29_ped_itens_set_null()
            CALL vdpm29_ped_itens_set_cod_empresa(p_cod_empresa)
            CALL vdpm29_ped_itens_set_num_pedido(l_num_pedido)
            CALL vdpm29_ped_itens_set_num_sequencia(l_sequencia)
            CALL vdpm29_ped_itens_set_cod_item(mr_itens.codpro)
            
            CALL log2250_busca_parametro(p_cod_empresa,'geo_aplica_desc_ped')
            RETURNING l_parametro, l_status
            IF l_parametro IS NULL OR l_parametro = " " THEN
               LET l_parametro= "N"
            END IF 
            
            LET l_desconto = 0
            LET l_pct_desc = 0
            LET l_pct_desc_adic = 0
            
            IF l_parametro = "S" THEN
               SELECT pct_desc, pct_desc_adic
                 INTO l_pct_desc, l_pct_desc_adic
                 FROM geo_desc_lista
                WHERE cod_empresa = p_cod_empresa
                  AND cod_cliente = l_cod_cliente
                  AND cod_item = mr_itens.codpro
                  AND dat_final_desc >= TODAY
               IF sqlca.sqlcode = NOTFOUND THEN
                  LET l_pct_desc_adic = 0
                  SELECT pct_desc
                    INTO l_pct_desc
                    FROM geo_desc_lista
                   WHERE cod_empresa = p_cod_empresa
                     AND cod_cliente = l_cod_cliente
                     AND cod_item = mr_itens.codpro
                     AND dat_final_desc < TODAY
               END IF
               IF l_pct_desc IS NULL OR l_pct_desc = " " THEN
                  LET l_pct_desc = 0
               END IF 
               IF l_pct_desc_adic IS NULL OR l_pct_desc_adic = " " THEN
                  LET l_pct_desc_adic = 0
               END IF 
               
               LET l_desconto = l_pct_desc + l_pct_desc_adic
               IF l_desconto < 0 then
                  LET mr_itens.valitn = mr_itens.valitn + (mr_itens.valitn*l_desconto/100*-1)
                  LET l_desconto = 0  
               end IF 
            
               CALL vdpm29_ped_itens_set_pct_desc_adic(l_desconto)
            ELSE
               CALL vdpm29_ped_itens_set_pct_desc_adic(0) #GEOSALES TEM QUE ENVIAR
            END IF
            
            
            CALL vdpm29_ped_itens_set_pre_unit(mr_itens.valitn)
            CALL vdpm29_ped_itens_set_qtd_pecas_solic(mr_itens.qtdven)
            CALL vdpm29_ped_itens_set_qtd_pecas_atend(0)
            CALL vdpm29_ped_itens_set_qtd_pecas_cancel(0)
            CALL vdpm29_ped_itens_set_qtd_pecas_reserv(0)
            CALL vdpm29_ped_itens_set_prz_entrega(TODAY)
            CALL vdpm29_ped_itens_set_val_desc_com_unit(0)
            CALL vdpm29_ped_itens_set_val_frete_unit(0)
            CALL vdpm29_ped_itens_set_val_seguro_unit(0)
            CALL vdpm29_ped_itens_set_qtd_pecas_romaneio(0)
            CALL vdpm29_ped_itens_set_pct_desc_bruto(0)

            IF NOT vdpt29_ped_itens_inclui(TRUE,TRUE) THEN
               let l_sqlcode = sqlca.sqlcode
               CALL log085_transacao("ROLLBACK")
               LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_itens. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
       	   		LET l_continue = TRUE
	           EXIT FOREACH
            END IF
            
            
            CALL vdpm675_ped_seq_ped_cliente_set_null()
            CALL vdpm675_ped_seq_ped_cliente_set_empresa(p_cod_empresa)
            CALL vdpm675_ped_seq_ped_cliente_set_pedido(l_num_pedido)
            CALL vdpm675_ped_seq_ped_cliente_set_seq_item_ped(l_sequencia)
   			CALL vdpm675_ped_seq_ped_cliente_set_xped(mr_itens.xped)
   			CALL vdpm675_ped_seq_ped_cliente_set_nitemped(mr_itens.nitemped)
   			 
   			IF NOT vdpm675_ped_seq_ped_cliente_inclui(TRUE,TRUE) THEN
   				let l_sqlcode = sqlca.sqlcode
                CALL log085_transacao("ROLLBACK")
                LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_seq_ped_cliente. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
       	   		LET l_continue = TRUE
	            EXIT FOREACH
            END IF
   		
			
			{ A PRINCIPIO NAO É OBRIGATORIO ESTA TABELA
			CALL vdpm65_ped_aen_item_ped_set_null()
	        CALL vdpm65_ped_aen_item_ped_set_empresa(p_cod_empresa)
	        CALL vdpm65_ped_aen_item_ped_set_pedido(l_num_pedido)
	        CALL vdpm65_ped_aen_item_ped_set_sequencia(l_sequencia)
	        CALL vdpm65_ped_aen_item_ped_set_linha_produto(mr_aen_item_ped.linha_produto)
	        CALL vdpm65_ped_aen_item_ped_set_linha_receita(mr_aen_item_ped.linha_receita)
	        CALL vdpm65_ped_aen_item_ped_set_segmto_mercado(mr_aen_item_ped.segmto_mercado)
	        CALL vdpm65_ped_aen_item_ped_set_classe_uso(mr_aen_item_ped.classe_uso)
	        
	        IF NOT vdpt65_ped_aen_item_ped_inclui(TRUE,TRUE) THEN
	           let l_sqlcode = sqlca.sqlcode
	        	CALL log085_transacao("ROLLBACK")
	        	LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_aen_item_ped. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           LET l_continue = TRUE
	           EXIT FOREACH
	        END IF }
			
			let l_sequencia = l_sequencia + 1
		END FOREACH
        
        IF l_continue THEN
           LET l_continue = FALSE
           CONTINUE FOREACH
        END IF 
        
        CALL vdpm64_ped_info_compl_set_null()
        CALL vdpm64_ped_info_compl_set_empresa(p_cod_empresa)
        CALL vdpm64_ped_info_compl_set_pedido(l_num_pedido)
        CALL vdpm64_ped_info_compl_set_campo("pedido_paletizado")
        CALL vdpm64_ped_info_compl_set_par_existencia("N")
        CALL vdpm64_ped_info_compl_set_parametro_texto(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_val(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_qtd(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_dat(NULL)
         
        IF NOT vdpt64_ped_info_compl_inclui(TRUE,TRUE) THEN
           let l_sqlcode = sqlca.sqlcode
			CALL log085_transacao("ROLLBACK")
			LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_info_compl CAMPO pedido_paletizado. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
   		END IF
        
	    CALL vdpm64_ped_info_compl_set_null()
        CALL vdpm64_ped_info_compl_set_empresa(p_cod_empresa)
        CALL vdpm64_ped_info_compl_set_pedido(l_num_pedido)
        CALL vdpm64_ped_info_compl_set_campo("pct_tolerancia_maximo")
        CALL vdpm64_ped_info_compl_set_par_existencia(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_texto(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_val(0)
        CALL vdpm64_ped_info_compl_set_parametro_qtd(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_dat(NULL)
         
        IF NOT vdpt64_ped_info_compl_inclui(TRUE,TRUE) THEN
           let l_sqlcode = sqlca.sqlcode
			CALL log085_transacao("ROLLBACK")
			LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_info_compl CAMPO pct_tolerancia_maximo. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
   		END IF
        
	    CALL vdpm64_ped_info_compl_set_null()
        CALL vdpm64_ped_info_compl_set_empresa(p_cod_empresa)
        CALL vdpm64_ped_info_compl_set_pedido(l_num_pedido)
        CALL vdpm64_ped_info_compl_set_campo("pct_tolerancia_minimo")
        CALL vdpm64_ped_info_compl_set_par_existencia(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_texto(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_val(0)
        CALL vdpm64_ped_info_compl_set_parametro_qtd(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_dat(NULL)
         
        IF NOT vdpt64_ped_info_compl_inclui(TRUE,TRUE) THEN
           let l_sqlcode = sqlca.sqlcode
			CALL log085_transacao("ROLLBACK")
			LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_info_compl CAMPO pct_tolerancia_minimo. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
   		END IF
        
	    CALL vdpm64_ped_info_compl_set_null()
        CALL vdpm64_ped_info_compl_set_empresa(p_cod_empresa)
        CALL vdpm64_ped_info_compl_set_pedido(l_num_pedido)
        CALL vdpm64_ped_info_compl_set_campo("nota_empenho")
        CALL vdpm64_ped_info_compl_set_par_existencia(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_texto(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_val(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_qtd(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_dat(NULL)
         
        IF NOT vdpt64_ped_info_compl_inclui(TRUE,TRUE) THEN
           let l_sqlcode = sqlca.sqlcode
			CALL log085_transacao("ROLLBACK")
			LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_info_compl CAMPO nota_empenho. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
   		END IF
        
	    CALL vdpm64_ped_info_compl_set_null()
        CALL vdpm64_ped_info_compl_set_empresa(p_cod_empresa)
        CALL vdpm64_ped_info_compl_set_pedido(l_num_pedido)
        CALL vdpm64_ped_info_compl_set_campo("contrato_compra")
        CALL vdpm64_ped_info_compl_set_par_existencia(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_texto(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_val(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_qtd(NULL)
        CALL vdpm64_ped_info_compl_set_parametro_dat(NULL)
         
        IF NOT vdpt64_ped_info_compl_inclui(TRUE,TRUE) THEN
           let l_sqlcode = sqlca.sqlcode
			CALL log085_transacao("ROLLBACK")
			LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_info_compl CAMPO contrato_compra. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
   		END IF
   		
   		
   		
        
   		CALL vdpm34_ped_itens_texto_set_null()
        CALL vdpm34_ped_itens_texto_set_cod_empresa(p_cod_empresa)
        CALL vdpm34_ped_itens_texto_set_num_pedido(l_num_pedido)
        CALL vdpm34_ped_itens_texto_set_num_sequencia(0)
        
        LET l_cod_vendedor = mr_mestre.codven
        LET l_msg = "CLIENTE: ",l_cod_cliente CLIPPED," VENDEDOR: ",l_cod_vendedor CLIPPED
        CALL vdpm34_ped_itens_texto_set_den_texto_1(l_msg CLIPPED)
        
        LET l_msg = mr_mestre.obsnot
        
        IF l_msg IS NULL then
           LET l_msg = ''
        END if
        
        CALL vdpm34_ped_itens_texto_set_den_texto_2(l_msg CLIPPED)  
        CALL vdpm34_ped_itens_texto_set_den_texto_3("")
        CALL vdpm34_ped_itens_texto_set_den_texto_4("")
        CALL vdpm34_ped_itens_texto_set_den_texto_5("")

        IF NOT vdpt34_ped_itens_texto_inclui(TRUE,TRUE) THEN
           let l_sqlcode = sqlca.sqlcode
           CALL log085_transacao("ROLLBACK")
           LET l_erro = "FALHA AO INSERIR DADOS NA TABELA ped_itens_texto. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
        END IF
        
        LET l_serie_fatura = ""
        
        SELECT serie_docum
          INTO l_serie_fatura
          FROM geo_repres_paramet
         WHERE cod_repres = mr_mestre.codven
        if l_serie_fatura is null or l_serie_fatura = "" then
           let l_sqlcode = sqlca.sqlcode
           CALL log085_transacao("ROLLBACK")
           LET l_erro = "SERIE DO REPRESENTANTE NAO ENCONTRADO NA TABELA geo_repres_paramet. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
        end if 
        
        LET l_solicitacao_fatura = mr_mestre.numope
        WHILE TRUE
           SELECT *
             FROM fat_solic_mestre
            WHERE empresa = p_cod_empresa
              AND tip_docum = "SOLPRDSV"
              AND serie_fatura = l_serie_fatura
              AND subserie_fatura = 0
              AND especie_fatura = "NFF"
              AND solicitacao_fatura = l_solicitacao_fatura
           if sqlca.sqlcode <> 0 THEN
              EXIT WHILE
           END IF 
           LET l_solicitacao_fatura = l_solicitacao_fatura + 1
        END WHILE
        
        LET l_trans_solic_fatura = 0
        CALL vdpm98_fat_solic_mestre_set_null()
	    CALL vdpm98_fat_solic_mestre_set_trans_solic_fatura(l_trans_solic_fatura)
	    CALL vdpm98_fat_solic_mestre_set_empresa(p_cod_empresa)
	    CALL vdpm98_fat_solic_mestre_set_tip_docum("SOLPRDSV")
	    CALL vdpm98_fat_solic_mestre_set_serie_fatura(l_serie_fatura)
	    CALL vdpm98_fat_solic_mestre_set_subserie_fatura(0)
	    CALL vdpm98_fat_solic_mestre_set_especie_fatura("NFF")
	    CALL vdpm98_fat_solic_mestre_set_solicitacao_fatura(l_solicitacao_fatura)
	    CALL vdpm98_fat_solic_mestre_set_usuario(p_user)
	    CALL vdpm98_fat_solic_mestre_set_inscricao_estadual(NULL)
	    CALL vdpm98_fat_solic_mestre_set_dat_refer(TODAY)
	    CALL vdpm98_fat_solic_mestre_set_tip_solicitacao("P")
	    CALL vdpm98_fat_solic_mestre_set_lote_geral("N")
	    CALL vdpm98_fat_solic_mestre_set_tip_carteira(NULL)
	    CALL vdpm98_fat_solic_mestre_set_sit_solic_fatura("N")
        
        IF NOT vdpt98_fat_solic_mestre_inclui(TRUE,TRUE) THEN
           let l_sqlcode = sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       LET l_erro = "FALHA AO INSERIR DADOS NA TABELA fat_solic_mestre. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
	    END IF
	    
	    LET l_trans_solic_fatura = sqlca.sqlerrd[2]   {Transação da solicitação - serial}
        
        CALL vdpm101_fat_solic_fatura_set_null()
        CALL vdpm101_fat_solic_fatura_set_trans_solic_fatura(l_trans_solic_fatura)
        CALL vdpm101_fat_solic_fatura_set_ord_montag(l_num_pedido)
        CALL vdpm101_fat_solic_fatura_set_lote_ord_montag(0)
        CALL vdpm101_fat_solic_fatura_set_seq_solic_fatura(1)
        CALL vdpm101_fat_solic_fatura_set_controle(NULL)
        CALL vdpm101_fat_solic_fatura_set_cond_pagto(NULL)
        CALL vdpm101_fat_solic_fatura_set_qtd_dia_acre_dupl(NULL)
        CALL vdpm101_fat_solic_fatura_set_texto_1(NULL)
        CALL vdpm101_fat_solic_fatura_set_texto_2(NULL)
        CALL vdpm101_fat_solic_fatura_set_texto_3(NULL)
        CALL vdpm101_fat_solic_fatura_set_via_transporte(1)
        CALL vdpm101_fat_solic_fatura_set_tabela_frete(NULL)
        CALL vdpm101_fat_solic_fatura_set_seq_tabela_frete(NULL)
        CALL vdpm101_fat_solic_fatura_set_sequencia_faixa(NULL)
        CALL vdpm101_fat_solic_fatura_set_cidade_dest_frete(NULL)
        CALL vdpm101_fat_solic_fatura_set_transportadora(NULL)
        CALL vdpm101_fat_solic_fatura_set_placa_veiculo(NULL)
        CALL vdpm101_fat_solic_fatura_set_placa_carreta_1(NULL)
        CALL vdpm101_fat_solic_fatura_set_placa_carreta_2(NULL)
        CALL vdpm101_fat_solic_fatura_set_estado_placa_veic(NULL)
        CALL vdpm101_fat_solic_fatura_set_estado_plac_carr_1(NULL)
        CALL vdpm101_fat_solic_fatura_set_estado_plac_carr_2(NULL)
        CALL vdpm101_fat_solic_fatura_set_val_frete(0)
        CALL vdpm101_fat_solic_fatura_set_val_seguro(0)
        CALL vdpm101_fat_solic_fatura_set_peso_liquido(0)
        CALL vdpm101_fat_solic_fatura_set_peso_bruto(0)
        CALL vdpm101_fat_solic_fatura_set_primeiro_volume(1)
        CALL vdpm101_fat_solic_fatura_set_volume_cubico(0)
        CALL vdpm101_fat_solic_fatura_set_mercado(NULL)
        CALL vdpm101_fat_solic_fatura_set_local_embarque(NULL)
        CALL vdpm101_fat_solic_fatura_set_modo_embarque(NULL)
        CALL vdpm101_fat_solic_fatura_set_dat_hor_embarque(NULL)
        CALL vdpm101_fat_solic_fatura_set_cidade_embarque(NULL)
        CALL vdpm101_fat_solic_fatura_set_sit_solic_fatura("C")
        
        IF find4GLFunction("vdpm101_fat_solic_fatura_get_val_fret_exp") THEN
           CALL vdpm101_fat_solic_fatura_set_val_fret_exp(NULL)
           CALL vdpm101_fat_solic_fatura_set_val_segr_exp(NULL)
           CALL vdpm101_fat_solic_fatura_set_aplic_fret_exp(NULL)
           CALL vdpm101_fat_solic_fatura_set_tip_rat_fret_exp(NULL)
        END IF
        
        IF NOT vdpt101_fat_solic_fatura_inclui(TRUE,TRUE) THEN
           let l_sqlcode = sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       LET l_erro = "FALHA AO INSERIR DADOS NA TABELA fat_solic_fatura. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
	    END IF
        
        CALL vdpm102_fat_solic_embal_set_null()
        CALL vdpm102_fat_solic_embal_set_trans_solic_fatura(l_trans_solic_fatura)
        CALL vdpm102_fat_solic_embal_set_ord_montag(l_num_pedido)
        CALL vdpm102_fat_solic_embal_set_lote_ord_montag(0)
        CALL vdpm102_fat_solic_embal_set_embalagem(1)
        CALL vdpm102_fat_solic_embal_set_qtd_embalagem(1)
        
        IF NOT vdpt102_fat_solic_embal_inclui(TRUE,TRUE) THEN
           let l_sqlcode = sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       LET l_erro = "FALHA AO INSERIR DADOS NA TABELA fat_solic_embal. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	       
	           CONTINUE FOREACH
	    END IF
        
        IF find4GLFunction("vdpm554_fat_s_nf_eletr_set_null") THEN
           CALL vdpm554_fat_s_nf_eletr_set_null()
           CALL vdpm554_fat_s_nf_eletr_set_trans_solic_fatura(l_trans_solic_fatura)
           CALL vdpm554_fat_s_nf_eletr_set_ord_montag(l_num_pedido)
           CALL vdpm554_fat_s_nf_eletr_set_lote_ord_montag(0)
           --tipo de frete ies_frete           
           CALL vdpm554_fat_s_nf_eletr_set_modalidade_frete_nfe(3)
           CALL vdpm554_fat_s_nf_eletr_set_inf_adic_fisco(NULL)
           CALL vdpm554_fat_s_nf_eletr_set_dat_hor_saida(NULL)
           
           IF NOT vdpt554_fat_s_nf_eletr_inclui(TRUE,TRUE) THEN
              let l_sqlcode = sqlca.sqlcode
              CALL log085_transacao("ROLLBACK")
	          LET l_erro = "FALHA AO INSERIR DADOS NA TABELA fat_s_nf_eletr. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	        CONTINUE FOREACH
           END IF
        END IF
        
        
   		CALL vdpr100_valida_pedido_tipo_entrega(p_cod_empresa ,
                                              l_num_pedido,
                                              "M",
                                              FALSE) RETURNING l_status
   		IF NOT vdpr100_gerar_reservas_pedido(p_cod_empresa, l_num_pedido, FALSE) THEN
           LET l_erro = "FALHA AO VALIDAR PEDIDO TIPO ENTREGA DO PEDIDO ",l_num_pedido,". sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
        END IF
        
        DELETE FROM tran_arg
        WHERE cod_empresa   = p_cod_empresa
          AND num_programa  = 'vdp0745'
          AND login_usuario = p_user
          AND num_arg       = 1
          AND indice_arg    = 0
        
        if sqlca.sqlcode <> 0 then
           let l_sqlcode = sqlca.sqlcode
           CALL log085_transacao("ROLLBACK")
           LET l_erro = "FALHA AO DELETAR DADOS DA TABELA tran_arg. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
        end if 
        
        INSERT INTO tran_arg VALUES (p_cod_empresa,'vdp0745',p_user, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),1,0,'',l_trans_solic_fatura,NULL,NULL,NULL)
        IF sqlca.sqlcode = 0 THEN
           CALL log085_transacao("COMMIT")
           #CALL log0030_mensagem("INICIA O VDP0745","excl")
           CALL log1200_executa_programa_background('vdp0745')
           
           INSERT INTO geo_ope_env VALUES (p_cod_empresa, mr_mestre.codven, mr_mestre.numope, l_num_pedido,NULL, NULL, NULL)
           IF sqlca.sqlcode <> 0 THEN
	           let l_sqlcode = sqlca.sqlcode
	       	   LET l_erro = "FALHA AO INSERIR DADOS NA TABELA geo_ope_env. sqlcode: ",l_sqlcode
       	   	   CALL geo1012_grava_audit(l_erro)
           END IF 
           ### SLEEP PARA NAO APAGAR A TRAN_ARG ANTES DO VDP0745 PEGAR A SOLICITACAO PARA FATURAMENTO
           SLEEP 5
           
           
       	ELSE
       	   let l_sqlcode = sqlca.sqlcode
       	   CALL log085_transacao("ROLLBACK")
	       LET l_erro = "FALHA AO INSERIR DADOS NA TABELA tran_arg. sqlcode: ",l_sqlcode
       	   		CALL geo1012_grava_audit(l_erro)
	           CONTINUE FOREACH
       	END IF 
        
   END FOREACH
   
   DECLARE cq_reproc_bol CURSOR WITH HOLD FOR
   SELECT *
     FROM geo_reprocessa_boleto
   FOREACH cq_reproc_bol INTO l_trans_nota_fiscal
      CALL vdp0749y_reprocessa_boleto(l_trans_nota_fiscal)
      SLEEP 5
   END FOREACH
   
   
   DECLARE cq_reproc_bol2 CURSOR WITH HOLD FOR
   ##### SQL PARA GERAR BOLETOS DE NFS EM QUE NAO FORAM GERADAS
	SELECT DISTINCT a.trans_nota_fiscal
	   FROM fat_nf_mestre a, 
	        cond_pgto b, 
	        fat_nf_item c, 
	        geo_ope_env d, 
	        pedidos e,
	        clientes f
	  WHERE b.cod_cnd_pgto = a.cond_pagto 
	    AND a.empresa = c.empresa 
	    AND f.cod_cliente = a.cliente
	    AND (f.cod_portador IS NULL OR f.cod_portador < 900)
	    AND a.trans_nota_fiscal = c.trans_nota_fiscal 
	    AND c.seq_item_nf = 1 
	    AND d.cod_empresa = a.empresa 
	    AND a.sit_nota_fiscal = 'N'
	    AND a.tip_nota_fiscal = 'FATPRDSV'
	    AND d.num_pedido = c.pedido 
	    AND e.cod_empresa = a.empresa 
	    AND c.pedido = e.num_pedido 
	    AND b.ies_tipo = 'N' 
	    AND b.cod_cnd_pgto <> '999' 
	    AND a.empresa = '01'
	    AND e.cod_tip_venda = '2'
	    AND NOT EXISTS (SELECT num_docum
	                      FROM docum_banco
	                     WHERE cod_empresa = a.empresa
	                       AND num_docum IN (SELECT docum_cre
	                                           FROM fat_nf_duplicata
	                                          WHERE empresa = a.empresa
	                                            AND trans_nota_fiscal = a.trans_nota_fiscal))
	    AND NOT EXISTS (SELECT nota_fiscal
	                      FROM geo_inf_boleto
	                     WHERE cod_empresa = a.empresa
	                       AND nota_fiscal = a.nota_fiscal
	                       AND serie_nota_fiscal = a.serie_nota_fiscal)
	 
     FOREACH cq_reproc_bol2 INTO l_trans_nota_fiscal
        CALL vdp0749y_reprocessa_boleto(l_trans_nota_fiscal)
        SLEEP 5
     END FOREACH
   
   
END FUNCTION


#-----------------------------#
FUNCTION geo1012_grava_audit(l_erro)
#-----------------------------#
   DEFINE l_erro  CHAR(999)
   
   INSERT INTO geo_audit VALUES (p_cod_empresa, "geo1012",CURRENT,l_erro)
   
END FUNCTION
