#-----------------------------------------------------------------#
# MODULO..: VDP                                                   #
# SISTEMA.: EPL PARA GERAR BOLETO AUTOMATICO LOGO APOS EMISSAO DA NF   #
# PROGRAMA: vdp0749y                                              #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 26/02/2016                                            #
#-----------------------------------------------------------------#


DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario

END GLOBALS


#---------------------------------------#
 FUNCTION y_vdp0745_after_commit()
#---------------------------------------#
   DEFINE l_empresa LIKE fat_nf_mestre.empresa
   DEFINE l_usuario LIKE usuarios.cod_usuario
   DEFINE l_trans_nota_fiscal LIKE fat_nf_mestre.trans_nota_fiscal
   DEFINE l_modo_exibicao SMALLINT
   DEFINE l_sql_stmt CHAR(5000)
   DEFINE l_repres DECIMAL(4,0)
   DEFINE l_transportadora VARCHAR(15)
   DEFINE l_erro CHAR(999)
   DEFINE l_status SMALLINT
   DEFINE l_parametro CHAR(10)
   DEFINE l_num_docum CHAR(20)
   DEFINE l_portador VARCHAR(20)
   DEFINE l_nom_arquivo CHAR(200)
   DEFINE l_entrou SMALLINT
   DEFINE lr_boletos RECORD
                        empresa CHAR(2),
   					    nota_fiscal INTEGER,
					    serie_nota_fiscal CHAR(3),
					    tip_nota_fiscal CHAR(8), 
   					    cod_repres decimal(4,0)
                     END RECORD
   
   LET l_empresa = LOG_getVar("empresa")
   LET l_usuario = "admlog"
   LET l_trans_nota_fiscal = LOG_getVar("trans_nota_fiscal")
   LET l_modo_exibicao = LOG_getVar("modo_exibicao")
   
   #LET l_empresa = "01"
   #LET l_usuario = "admlog"
   #LET l_trans_nota_fiscal = 638
   #LET l_modo_exibicao = 0
   
   LET l_status = false
   LET l_entrou = FALSE
   DELETE FROM tran_arg
    WHERE cod_empresa   = l_empresa
      AND num_programa  = 'geo1015'
      AND login_usuario = l_usuario
   IF sqlca.sqlcode <> 0 THEN
      LET l_erro = "Falha ao deletar tran_arg. sqlcode: ",sqlca.sqlcode
      CALL vdp0749y_grava_audit(l_erro)
	  RETURN FALSE
   END IF 
   LET l_sql_stmt = " SELECT DISTINCT a.empresa, ",
					    "    a.nota_fiscal, ", 
						"    a.serie_nota_fiscal, ", 
						"    a.tip_nota_fiscal, ",
						"    e.cod_repres ",
					 "  FROM fat_nf_mestre a, ",
					     "   cond_pgto b, ",
					     "   fat_nf_item c, ",
					     "   geo_ope_env d, ",
					     "   pedidos e ",
					"  WHERE b.cod_cnd_pgto = a.cond_pagto ",
					  "  AND a.empresa = c.empresa ",
					  "  AND a.trans_nota_fiscal = c.trans_nota_fiscal ",
					  "  AND c.seq_item_nf = 1 ",
					  "  AND d.cod_empresa = a.empresa ",
					  "  AND d.num_pedido = c.pedido ",
					  "  AND e.cod_empresa = a.empresa ",
					  "  AND c.pedido = e.num_pedido ",
					  "  AND b.ies_tipo = 'N' ",
					  "  AND b.cod_cnd_pgto <> '999' ",
					  "  AND a.empresa = '",l_empresa,"' ",
				      "  AND a.trans_nota_fiscal = '",l_trans_nota_fiscal,"' "
   
	PREPARE var_query FROM l_sql_stmt
	DECLARE cq_boletos CURSOR WITH HOLD FOR var_query
	FOREACH cq_boletos INTO lr_boletos.*
	    CALL log085_transacao("BEGIN")
	   	#origem 
	   	LET l_num_docum = lr_boletos.serie_nota_fiscal,"00",lr_boletos.nota_fiscal,"%"
	   	INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),1,0,'',"NF",NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg ORIGEM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
		#empresa          
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),2,0,'',lr_boletos.empresa,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg EMPRESA. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        #portador  
        
        SELECT cod_portador
          INTO l_portador
          FROM geo_repres_paramet
         WHERE cod_repres = lr_boletos.cod_repres     
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Configurações do Representante não encontrado. Representante ",lr_boletos.cod_repres," - sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
	       EXIT FOREACH
        END IF 
        
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),3,0,'',l_portador,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg PORTADOR. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        #tip_nota_fiscal  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),4,0,'',lr_boletos.tip_nota_fiscal,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg TIP_NOTA_FISCAL. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        #serie_nota_fiscal
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),5,0,'',lr_boletos.serie_nota_fiscal,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg SERIE_NOTA_FISCAL. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        #nota_fiscal_ini  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),6,0,'',lr_boletos.nota_fiscal,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_INI. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        #nota_fiscal_fim  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),7,0,'',lr_boletos.nota_fiscal,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        
        #p_ies_impressao  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),14,0,'',"N",NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        
        #p_nom_arquivo  
        LET l_nom_arquivo = "BOLETO_",l_usuario CLIPPED,".",lr_boletos.nota_fiscal,".pdf"
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),15,0,'',l_nom_arquivo,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        
        #m_formato  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),16,0,'',"P",NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        
        #m_antecipacao_pedido  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),17,0,'',"N",NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        
        CALL log085_transacao("COMMIT")
        LET l_entrou = TRUE
        
        EXIT FOREACH
	END FOREACH
    
    #IF l_status THEN
    #   RETURN FALSE
    #END IF 
    
    IF l_entrou THEN
       #CALL geo1015_executa()
       CALL log1200_executa_programa_background('geo1015')
    ELSE
    
       {LET l_status = false
	   LET l_entrou = FALSE
	   DELETE FROM tran_arg
	    WHERE cod_empresa   = l_empresa
	      AND num_programa  = 'geo1015'
	      AND login_usuario = l_usuario
	   IF sqlca.sqlcode <> 0 THEN
	      LET l_erro = "Falha ao deletar tran_arg. sqlcode: ",sqlca.sqlcode
	      CALL vdp0749y_grava_audit(l_erro)
		  RETURN FALSE
	   END IF 
	   LET l_sql_stmt = " SELECT DISTINCT a.empresa, ",
						    "    a.nota_fiscal, ", 
							"    a.serie_nota_fiscal, ", 
							"    a.tip_nota_fiscal, ",
							"    e.cod_repres ",
						 "  FROM fat_nf_mestre a, ",
						     "   cond_pgto b, ",
						     "   fat_nf_item c, ",
						     "   geo_loc_faturado d, ",
						     "   pedidos e ",
						"  WHERE b.cod_cnd_pgto = a.cond_pagto ",
						  "  AND a.empresa = c.empresa ",
						  "  AND a.trans_nota_fiscal = c.trans_nota_fiscal ",
						  "  AND c.seq_item_nf = 1 ",
						  "  AND d.cod_empresa = a.empresa ",
						  "  AND d.num_pedido = c.pedido ",
						  "  AND e.cod_empresa = a.empresa ",
						  "  AND c.pedido = e.num_pedido ",
						  "  AND b.ies_tipo = 'N' ",
						  "  AND b.cod_cnd_pgto <> '999' ",
						  "  AND a.empresa = '",l_empresa,"' ",
					      "  AND a.trans_nota_fiscal = '",l_trans_nota_fiscal,"' "
	   
		PREPARE var_query FROM l_sql_stmt
		DECLARE cq_boletos CURSOR WITH HOLD FOR var_query
		FOREACH cq_boletos INTO lr_boletos.*
		    CALL log085_transacao("BEGIN")
		   	#origem 
		   	LET l_num_docum = lr_boletos.serie_nota_fiscal,"00",lr_boletos.nota_fiscal,"%"
		   	INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),1,0,'',"NF",NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg ORIGEM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
			#empresa          
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),2,0,'',lr_boletos.empresa,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg EMPRESA. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        #portador  
	        
	        CALL log2250_busca_parametro(p_cod_empresa,'geo_portador_locacao')
		    RETURNING l_parametro, l_status
		    
		    IF l_parametro IS NULL OR l_parametro = " " THEN
		       LET l_parametro = "350"
		    END IF  
	        
	        LET l_portador = l_parametro CLIPPED
	        INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),3,0,'',l_portador,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg PORTADOR. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        #tip_nota_fiscal  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),4,0,'',lr_boletos.tip_nota_fiscal,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg TIP_NOTA_FISCAL. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        #serie_nota_fiscal
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),5,0,'',lr_boletos.serie_nota_fiscal,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg SERIE_NOTA_FISCAL. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        #nota_fiscal_ini  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),6,0,'',lr_boletos.nota_fiscal,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_INI. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        #nota_fiscal_fim  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),7,0,'',lr_boletos.nota_fiscal,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        
	        #p_ies_impressao  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),14,0,'',"N",NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        
	        #p_nom_arquivo  
	        LET l_nom_arquivo = "BOLETO_",l_usuario CLIPPED,".",lr_boletos.nota_fiscal,".pdf"
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),15,0,'',l_nom_arquivo,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        
	        #m_formato  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),16,0,'',"P",NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        
	        #m_antecipacao_pedido  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),17,0,'',"N",NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        
	        CALL log085_transacao("COMMIT")
	        LET l_entrou = TRUE
	        
	        EXIT FOREACH
		END FOREACH
	    
	    #IF l_status THEN
	    #   RETURN FALSE
	    #END IF 
	    
	    IF l_entrou THEN
	       #CALL geo1015_executa()
	       CALL log1200_executa_programa_background('geo1015')
	    END IF }
	    
	    
    
    END IF 
    
    
    RETURN TRUE
END FUNCTION

#-----------------------------#
FUNCTION vdp0749y_grava_audit(l_erro)
#-----------------------------#
   DEFINE l_erro  CHAR(999)
   
   INSERT INTO geo_audit VALUES (p_cod_empresa, "vdp0749y",CURRENT,l_erro)
   
END FUNCTION




#---------------------------------------#
 FUNCTION vdp0749y_reprocessa_boleto(l_trans_nota_fiscal)
#---------------------------------------#
   DEFINE l_empresa LIKE fat_nf_mestre.empresa
   DEFINE l_usuario LIKE usuarios.cod_usuario
   DEFINE l_trans_nota_fiscal LIKE fat_nf_mestre.trans_nota_fiscal
   DEFINE l_modo_exibicao SMALLINT
   DEFINE l_sql_stmt CHAR(5000)
   DEFINE l_repres DECIMAL(4,0)
   DEFINE l_transportadora VARCHAR(15)
   DEFINE l_erro CHAR(999)
   DEFINE l_parametro CHAR(10)
   DEFINE l_status SMALLINT
   DEFINE l_num_docum CHAR(20)
   DEFINE l_portador VARCHAR(20)
   DEFINE l_nom_arquivo CHAR(200)
   DEFINE l_entrou SMALLINT
   DEFINE lr_boletos RECORD
                        empresa CHAR(2),
   					    nota_fiscal INTEGER,
					    serie_nota_fiscal CHAR(3),
					    tip_nota_fiscal CHAR(8), 
   					    cod_repres decimal(4,0)
                     END RECORD
   
   LET l_empresa = "01"
   LET l_usuario = "admlog"
   #LET l_trans_nota_fiscal = LOG_getVar("trans_nota_fiscal")
   LET l_modo_exibicao = 0
   
   #LET l_empresa = "01"
   #LET l_usuario = "admlog"
   #LET l_trans_nota_fiscal = 638
   #LET l_modo_exibicao = 0
   
   LET l_status = false
   LET l_entrou = FALSE
   DELETE FROM tran_arg
    WHERE cod_empresa   = l_empresa
      AND num_programa  = 'geo1015'
      AND login_usuario = l_usuario
   IF sqlca.sqlcode <> 0 THEN
      LET l_erro = "Falha ao deletar tran_arg. sqlcode: ",sqlca.sqlcode
      CALL vdp0749y_grava_audit(l_erro)
	  RETURN FALSE
   END IF 
   LET l_sql_stmt = " SELECT DISTINCT a.empresa, ",
					    "    a.nota_fiscal, ", 
						"    a.serie_nota_fiscal, ", 
						"    a.tip_nota_fiscal, ",
						"    e.cod_repres ",
					 "  FROM fat_nf_mestre a, ",
					     "   cond_pgto b, ",
					     "   fat_nf_item c, ",
					     "   geo_ope_env d, ",
					     "   pedidos e ",
					"  WHERE b.cod_cnd_pgto = a.cond_pagto ",
					  "  AND a.empresa = c.empresa ",
					  "  AND a.trans_nota_fiscal = c.trans_nota_fiscal ",
					  "  AND c.seq_item_nf = 1 ",
					  "  AND d.cod_empresa = a.empresa ",
					  "  AND d.num_pedido = c.pedido ",
					  "  AND e.cod_empresa = a.empresa ",
					  "  AND c.pedido = e.num_pedido ",
					  "  AND b.ies_tipo = 'N' ",
					  "  AND b.cod_cnd_pgto <> '999' ",
					  "  AND a.empresa = '",l_empresa,"' ",
				      "  AND a.trans_nota_fiscal = '",l_trans_nota_fiscal,"' "
   
	PREPARE var_query FROM l_sql_stmt
	DECLARE cq_boletos CURSOR WITH HOLD FOR var_query
	FOREACH cq_boletos INTO lr_boletos.*
	    CALL log085_transacao("BEGIN")
	   	#origem 
	   	LET l_num_docum = lr_boletos.serie_nota_fiscal,"00",lr_boletos.nota_fiscal,"%"
	   	INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),1,0,'',"NF",NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg ORIGEM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
		#empresa          
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),2,0,'',lr_boletos.empresa,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg EMPRESA. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        #portador  
        
        SELECT cod_portador
          INTO l_portador
          FROM geo_repres_paramet
         WHERE cod_repres = lr_boletos.cod_repres     
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Configurações do Representante não encontrado. Representante ",lr_boletos.cod_repres," - sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
	       EXIT FOREACH
        END IF 
        
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),3,0,'',l_portador,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg PORTADOR. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        #tip_nota_fiscal  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),4,0,'',lr_boletos.tip_nota_fiscal,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg TIP_NOTA_FISCAL. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        #serie_nota_fiscal
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),5,0,'',lr_boletos.serie_nota_fiscal,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg SERIE_NOTA_FISCAL. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        #nota_fiscal_ini  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),6,0,'',lr_boletos.nota_fiscal,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_INI. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        #nota_fiscal_fim  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),7,0,'',lr_boletos.nota_fiscal,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        
        #p_ies_impressao  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),14,0,'',"N",NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        
        #p_nom_arquivo  
        LET l_nom_arquivo = "BOLETO_",l_usuario CLIPPED,".",lr_boletos.nota_fiscal,".pdf"
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),15,0,'',l_nom_arquivo,NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        
        #m_formato  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),16,0,'',"P",NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        
        #m_antecipacao_pedido  
		INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),17,0,'',"N",NULL,NULL,NULL)
        IF sqlca.sqlcode <> 0 THEN
           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
	       CALL log085_transacao("ROLLBACK")
	       CALL vdp0749y_grava_audit(l_erro)
	       LET l_status = TRUE
           EXIT FOREACH
        END IF 
        
        CALL log085_transacao("COMMIT")
        LET l_entrou = TRUE
        
        EXIT FOREACH
	END FOREACH
    
    #IF l_status THEN
    #   RETURN FALSE
    #END IF 
    
    IF l_entrou THEN
       #CALL geo1015_executa()
       CALL log1200_executa_programa_background('geo1015')
    
    ELSE
    
       {LET l_status = false
	   LET l_entrou = FALSE
	   DELETE FROM tran_arg
	    WHERE cod_empresa   = l_empresa
	      AND num_programa  = 'geo1015'
	      AND login_usuario = l_usuario
	   IF sqlca.sqlcode <> 0 THEN
	      LET l_erro = "Falha ao deletar tran_arg. sqlcode: ",sqlca.sqlcode
	      CALL vdp0749y_grava_audit(l_erro)
		  RETURN FALSE
	   END IF 
	   LET l_sql_stmt = " SELECT DISTINCT a.empresa, ",
						    "    a.nota_fiscal, ", 
							"    a.serie_nota_fiscal, ", 
							"    a.tip_nota_fiscal, ",
							"    e.cod_repres ",
						 "  FROM fat_nf_mestre a, ",
						     "   cond_pgto b, ",
						     "   fat_nf_item c, ",
						     "   geo_loc_faturado d, ",
						     "   pedidos e ",
						"  WHERE b.cod_cnd_pgto = a.cond_pagto ",
						  "  AND a.empresa = c.empresa ",
						  "  AND a.trans_nota_fiscal = c.trans_nota_fiscal ",
						  "  AND c.seq_item_nf = 1 ",
						  "  AND d.cod_empresa = a.empresa ",
						  "  AND d.num_pedido = c.pedido ",
						  "  AND e.cod_empresa = a.empresa ",
						  "  AND c.pedido = e.num_pedido ",
						  "  AND b.ies_tipo = 'N' ",
						  "  AND b.cod_cnd_pgto <> '999' ",
						  "  AND a.empresa = '",l_empresa,"' ",
					      "  AND a.trans_nota_fiscal = '",l_trans_nota_fiscal,"' "
	   
		PREPARE var_query FROM l_sql_stmt
		DECLARE cq_boletos CURSOR WITH HOLD FOR var_query
		FOREACH cq_boletos INTO lr_boletos.*
		    CALL log085_transacao("BEGIN")
		   	#origem 
		   	LET l_num_docum = lr_boletos.serie_nota_fiscal,"00",lr_boletos.nota_fiscal,"%"
		   	INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),1,0,'',"NF",NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg ORIGEM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
			#empresa          
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),2,0,'',lr_boletos.empresa,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg EMPRESA. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        #portador  
	        
	        CALL log2250_busca_parametro(p_cod_empresa,'geo_portador_locacao')
		    RETURNING l_parametro, l_status
		    
		    IF l_parametro IS NULL OR l_parametro = " " THEN
		       LET l_parametro = "350"
		    END IF  
	        
	        LET l_portador = l_parametro CLIPPED
	        INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),3,0,'',l_portador,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg PORTADOR. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        #tip_nota_fiscal  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),4,0,'',lr_boletos.tip_nota_fiscal,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg TIP_NOTA_FISCAL. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        #serie_nota_fiscal
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),5,0,'',lr_boletos.serie_nota_fiscal,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg SERIE_NOTA_FISCAL. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        #nota_fiscal_ini  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),6,0,'',lr_boletos.nota_fiscal,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_INI. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        #nota_fiscal_fim  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),7,0,'',lr_boletos.nota_fiscal,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        
	        #p_ies_impressao  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),14,0,'',"N",NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        
	        #p_nom_arquivo  
	        LET l_nom_arquivo = "BOLETO_",l_usuario CLIPPED,".",lr_boletos.nota_fiscal,".pdf"
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),15,0,'',l_nom_arquivo,NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        
	        #m_formato  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),16,0,'',"P",NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        
	        #m_antecipacao_pedido  
			INSERT INTO tran_arg VALUES (l_empresa,'geo1015',l_usuario, TODAY ,EXTEND(CURRENT, HOUR TO MINUTE),17,0,'',"N",NULL,NULL,NULL)
	        IF sqlca.sqlcode <> 0 THEN
	           LET l_erro = "Falha ao inserir tran_arg NOTA_FISCAL_FIM. sqlcode: ",sqlca.sqlcode
		       CALL log085_transacao("ROLLBACK")
		       CALL vdp0749y_grava_audit(l_erro)
		       LET l_status = TRUE
	           EXIT FOREACH
	        END IF 
	        
	        CALL log085_transacao("COMMIT")
	        LET l_entrou = TRUE
	        
	        EXIT FOREACH
		END FOREACH
	    
	    #IF l_status THEN
	    #   RETURN FALSE
	    #END IF 
	    
	    IF l_entrou THEN
	       #CALL geo1015_executa()
	       CALL log1200_executa_programa_background('geo1015')
	    END IF }
	    
	    
    
    
    END IF 
    
    
    RETURN TRUE
END FUNCTION

#--------------------------------------#
FUNCTION vdp0745y_after_commit_insert()
#--------------------------------------#
   
    RETURN TRUE
END FUNCTION