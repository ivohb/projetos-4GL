#-----------------------------------------------------------------#
# MODULO..: VDP                                                   #
# SISTEMA.: EPL PARA CANCELAR LC AUTOMATICAMENTE EM CASO DE DUPLICIDADE   #
# PROGRAMA: vdp0745y                                              #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 08/07/2016                                            #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_versao            CHAR(18)
   DEFINE p_cod_empresa       LIKE empresa.cod_empresa
   DEFINE p_user              LIKE usuarios.cod_usuario

END GLOBALS


#---------------------------------------#
 FUNCTION vdp0745y_before_processar_solicitacao()
#---------------------------------------#
	{DEFINE l_pedido DECIMAL(6,0)
	DEFINE l_count INTEGER
	DEFINE l_trans_nota_fiscal INTEGER
	DEFINE l_comando char(200)
	DEFINE l_ind INTEGER
	DEFINE l_mot_cancel           LIKE mot_cancel.cod_motivo
	
	WHENEVER ERROR CONTINUE
	DECLARE cq_canc_peds_dup CURSOR WITH HOLD FOR
	SELECT pedido, count(*)
	  FROM fat_nf_item
	 WHERE empresa = p_cod_empresa
	   AND trans_nota_fiscal IN (SELECT trans_nota_fiscal 
	                               FROM fat_nf_mestre 
	                              WHERE sit_nota_fiscal = 'N' 
	                                AND serie_nota_fiscal = 'LC' 
	                                AND empresa = p_cod_empresa)
	 GROUP BY pedido
	 HAVING COUNT(*) > 1
	
	FOREACH cq_canc_peds_dup INTO l_pedido, l_count
		DECLARE cq_get_trans CURSOR WITH HOLD FOR
		SELECT trans_nota_fiscal
		  FROM fat_nf_item
		 WHERE empresa = p_cod_empresa
		   AND pedido = l_pedido
		   AND trans_nota_fiscal IN (SELECT trans_nota_fiscal FROM fat_nf_mestre WHERE sit_nota_fiscal = 'N' AND serie_nota_fiscal = 'LC' AND empresa = p_cod_empresa)
		LET l_ind = 1
		FOREACH cq_get_trans INTO l_trans_nota_fiscal
		    IF l_ind > 1 THEN

       
		    	CALL log120_procura_caminho("VDP0753") RETURNING l_comando
		    	LET l_mot_cancel = '1'
			    LET l_comando = l_comando CLIPPED," ",p_cod_empresa CLIPPED,
			                         " ", l_trans_nota_fiscal USING "<<<<<<<<<<",
			                         " ", l_mot_cancel USING "<<<<<",
			                         " S"
			                         
			    RUN l_comando
		    END IF
			LET l_ind = l_ind + 1
		END FOREACH
	END FOREACH
	WHENEVER ERROR STOP}
   RETURN TRUE
END FUNCTION
