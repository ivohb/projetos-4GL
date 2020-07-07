#-----------------------------------------------------------------------#
# SISTEMA.: VENDAS DISTRIBUICAO DE PRODUTOS                             #
# OBJETIVO: COMPATIBILIZA reservas de estoque                           #
# DATA....: 03/01/2008                                                  #
#-----------------------------------------------------------------------# 
DATABASE logix 

 
GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_num_oc_o             LIKE ordem_sup.num_oc,
          p_cod_empresa_o        LIKE ordem_sup.cod_empresa,
          p_qtd_da_reser         LIKE estoque_loc_reser.qtd_reservada,
          p_largura              LIKE est_loc_reser_end.largura,
          p_altura               LIKE est_loc_reser_end.altura,
          p_diametro             LIKE est_loc_reser_end.diametro,
          p_comprimento          LIKE est_loc_reser_end.comprimento,
          p_qtd_saldo            LIKE estoque_lote_ender.qtd_saldo,
          p_qtd_reservar         LIKE estoque_lote_ender.qtd_saldo,
          p_num_transac          LIKE estoque_lote.num_transac,
          p_num_reserva          LIKE estoque_loc_reser.num_reserva,
          p_reser_relac          LIKE estoque_loc_reser.num_reserva,
          p_qtd_atendida         LIKE estoque_loc_reser.qtd_atendida,
          p_qtd_atender          LIKE estoque_loc_reser.qtd_atendida,
          p_qtd_movto            LIKE estoque_trans.qtd_movto,
          p_qtd_abat_reser       LIKE estoque.qtd_reservada,
          p_cod_operacao         LIKE estoque_trans.cod_operacao,
          p_num_docum            LIKE estoque_trans.num_docum,
          p_cod_empresa_copia    LIKE empresa.cod_empresa,
          p_req                  LIKE estoque_trans.cod_operacao,
          p_dcc                  LIKE estoque_trans.cod_operacao,
          p_ajco                 LIKE estoque_trans.cod_operacao,
          p_emco                 LIKE estoque_trans.cod_operacao,
          p_bxco                 LIKE estoque_trans.cod_operacao,
          p_ies_tipo             LIKE estoque_operac.ies_tipo,
          p_ies_acumulado        LIKE estoque_operac.ies_acumulado,
          p_dat_ult_entrada      DATE,
          p_dat_ult_saida        DATE,
          p_ies_situa            CHAR(01),
          p_gravar_relac         CHAR(01),
          p_erro                 CHAR(01),
          p_houve_erro           SMALLINT,        
          p_count                SMALLINT,
          p_grava_est_loc        SMALLINT,
          p_tem_rsv              SMALLINT,
          p_ja_copiou            SMALLINT,          
          p_ja_copiou_est        SMALLINT,                    
          p_rowid                INTEGER,
          p_comando              CHAR(80),
          p_caminho              CHAR(80),
          p_nom_tela             CHAR(80),
          p_help                 CHAR(80),
          p_versao               CHAR(18),
          p_msg                  CHAR(30),
          p_insere               SMALLINT,
          p_last_row             SMALLINT,
          p_del_wpol0801         SMALLINT,
          p_proces_ok            SMALLINT,
          p_status               SMALLINT,
          pa_curr                SMALLINT,
          sc_curr                SMALLINT,
          p_i                    SMALLINT,
          p_difer_reserva        DECIMAL (15,3), 
          p_cod_oper_saida       LIKE estoque_operac.cod_operacao, 
          p_cod_oper_devol_almox LIKE estoque_operac.cod_operacao,  
          p_cancel               INTEGER 

   DEFINE p_ies_situa_orig       LIKE estoque_trans.ies_sit_est_orig,
          p_ies_situa_dest       LIKE estoque_trans.ies_sit_est_dest,
          p_cod_local_orig       LIKE estoque_trans.cod_local_est_orig,
          p_cod_local_dest       LIKE estoque_trans.cod_local_est_dest,
          p_num_lote_orig        LIKE estoque_trans.num_lote_orig,
          p_num_lote_dest        LIKE estoque_trans.num_lote_dest,
          p_num_lote_reser       LIKE estoque_trans.num_lote_dest,
          p_qtd_reservada        LIKE estoque_loc_reser.qtd_reservada,
          p_cod_local_estoq      LIKE estoque_loc_reser.cod_local
   

   DEFINE lr_wpol0801           RECORD LIKE wpol0801.*,
          l_empresas_885        RECORD LIKE empresas_885.*,
          l_estoque_loc_reser   RECORD LIKE estoque_loc_reser.*,     
          l_est_loc_reser_end   RECORD LIKE est_loc_reser_end.*,                   
          t_estoque_loc_reser   RECORD LIKE estoque_loc_reser.*,
          l_sup_par_resv_est    RECORD LIKE sup_par_resv_est.*,  
          l_sup_est_loc_resdev  RECORD LIKE sup_est_loc_resdev.*,                    
          l_estoq_loc_res_obs   RECORD LIKE estoq_loc_res_obs.*,
	        p_estoque_trans       RECORD LIKE estoque_trans.*, 
	        p_estoque_trans_end   RECORD LIKE estoque_trans_end.*,
	        l_reserva_erro_885    RECORD LIKE reserva_erro_885.*, 
	        p_estoque_obs         RECORD LIKE estoque_obs.*,
	        p_estoque_lote_ender  RECORD LIKE estoque_lote_ender.*,
	        p_estoque_lote        RECORD LIKE estoque_lote.*,
	        p_movto_relac_885     RECORD LIKE movto_relac_885.*
             
END GLOBALS 

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0801-05.10.03"  
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT
  
   CALL log140_procura_caminho("POL.IEM") RETURNING p_caminho
   LET p_help = p_caminho
   OPTIONS
      HELP     FILE p_help,
      INSERT   KEY control-i,
      DELETE   KEY control-e,
      PREVIOUS KEY control-b,
      NEXT     KEY control-f
  CALL log001_acessa_usuario("SUPRIMEN","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
  

   IF p_status = 0 THEN 
      CALL pol0801_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0801_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0801") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0801 AT 06,23 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol0801_le_parametros() THEN
      RETURN 
   END IF

   DECLARE cq_del CURSOR FOR
    SELECT a.num_reserva
      FROM wpol0801 a,
           estoque_loc_reser b
    WHERE b.cod_empresa = a.cod_empresa
      AND b.num_reserva = a.num_reserva
      AND b.ies_origem  <> 'C'
      AND b.qtd_reservada <> 0

   FOREACH cq_del INTO p_num_reserva

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
   
      IF STATUS <> 0 THEN
         EXIT FOREACH
      END IF
   
      DELETE FROM wpol0801
       WHERE num_reserva = p_num_reserva
       
   END FOREACH      

   CALL log085_transacao("BEGIN")      
   
   DELETE FROM reserva_erro_885 
    WHERE cod_empresa = l_empresas_885.cod_emp_oficial
       OR cod_empresa = l_empresas_885.cod_emp_gerencial

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log085_transacao("ROLLBACK")      
      RETURN
   END IF      
   
   CALL log085_transacao("COMMIT")      
   
   CALL pol0801_processa_reservas()
   CALL pol0801_processa_delecoes()
   
END FUNCTION    

#-------------------------------#
FUNCTION pol0801_le_parametros()
#-------------------------------#

   SELECT *
     INTO l_empresas_885.*
     FROM empresas_885 
    WHERE cod_emp_gerencial = p_cod_empresa
       OR cod_emp_oficial  = p_cod_empresa
            
   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro lendo empresas_885 - Erro nº', STATUS
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_ajco
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_oper_ajust_ent'
        
   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro lendo cod_oper_ajust_ent - Erro nº', STATUS
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_emco
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_entrada_consig'
        
   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro lendo cod_entrada_consig - Erro nº', STATUS
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_req
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_operac_rm_aut'
        
   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro lendo cod_operac_rm_aut - Erro nº', STATUS
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_dcc
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_oper_dev_almox'
        
   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro lendo cod_oper_dev_almox - Erro nº', STATUS
      RETURN FALSE
   END IF

   SELECT cod_operac_it_terc 
     INTO p_bxco
     FROM par_sup_compl_1 
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro lendo cod_operac_it_terc - Erro nº', STATUS
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol0801_copia_rsv() 
#----------------------------#

   SELECT *
     INTO l_estoque_loc_reser.*    
     FROM estoque_loc_reser
    WHERE cod_empresa = lr_wpol0801.cod_empresa
      AND num_reserva = lr_wpol0801.num_reserva 
      AND ies_origem  = 'C' 

   IF STATUS = 100 THEN
      RETURN TRUE
   ELSE
      IF sqlca.sqlcode <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
          'Erro lendo estoque_loc_reser - Erro nº', STATUS
         RETURN TRUE 
      END IF
   END IF

   SELECT COUNT(item)
     INTO p_count
     FROM sup_item_terc_end
    WHERE empresa = p_cod_empresa_copia
      AND item    = l_estoque_loc_reser.cod_item

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
          'Erro lendo sup_item_terc_end - Erro nº', STATUS
      RETURN FALSE 
   END IF
   
   IF p_count > 0 THEN
      LET l_reserva_erro_885.des_erro = 
          'item consta da tebela de material de terceiros ', STATUS
      RETURN TRUE 
   END IF
      
   IF NOT pol0801_checa_estoque() THEN
      RETURN FALSE
   END IF

   IF p_gravar_relac = 'I' THEN
      IF NOT pol0801_insere_reser() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0801_alreta_reser() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol0801_grava_res_obs() THEN
      RETURN FALSE
   END IF

   IF NOT pol0801_copia_sup_par() THEN  
      RETURN TRUE
   END IF          

   IF NOT pol0801_grava_resdev() THEN  
      RETURN TRUE
   END IF          

   IF NOT pol0801_atualiza_relac() THEN
      RETURN FALSE
   END IF
     
   IF p_qtd_reservar > 0 AND p_gravar_relac = "I" THEN
      IF pol0801_grava_estoque('R') = FALSE THEN  
         RETURN FALSE
      END IF
   END IF 
                  
   RETURN TRUE
    
END FUNCTION         

#-------------------------#
FUNCTION pol0801_le_item()
#-------------------------#

   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = l_estoque_loc_reser.cod_item
   
   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
          'Erro lendo tabela item Erro nº', STATUS 
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION         


#------------------------------#
FUNCTION pol0801_insere_reser()
#------------------------------#
      
   LET l_estoque_loc_reser.cod_empresa    = p_cod_empresa_copia 
   LET l_estoque_loc_reser.num_referencia = lr_wpol0801.num_reserva    
         
   INSERT INTO estoque_loc_reser
       (cod_empresa,
				cod_item,
				cod_local, 
				qtd_reservada,
				num_lote, 
				ies_origem, 
				num_docum, 
				num_referencia,
				ies_situacao, 
				dat_prev_baixa,
				num_conta_deb,
				cod_uni_funcio,
				nom_solicitante,
				dat_solicitacao,
				nom_aprovante,
				dat_aprovacao,
				qtd_atendida,
				dat_ult_atualiz)
   VALUES
       (l_estoque_loc_reser.cod_empresa,
				l_estoque_loc_reser.cod_item,
				l_estoque_loc_reser.cod_local,
				l_estoque_loc_reser.qtd_reservada,       														      														
				l_estoque_loc_reser.num_lote,
				l_estoque_loc_reser.ies_origem,
				l_estoque_loc_reser.num_docum,    
				l_estoque_loc_reser.num_referencia,   												 
			  l_estoque_loc_reser.ies_situacao,      														
        l_estoque_loc_reser.dat_prev_baixa,     
        l_estoque_loc_reser.num_conta_deb,
        l_estoque_loc_reser.cod_uni_funcio,
        l_estoque_loc_reser.nom_solicitante,
        l_estoque_loc_reser.dat_solicitacao,
        l_estoque_loc_reser.nom_aprovante,
        l_estoque_loc_reser.dat_aprovacao,
        l_estoque_loc_reser.qtd_atendida,
        l_estoque_loc_reser.dat_ult_atualiz)      														
        
   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 'Erro inserindo estoque_loc_reser Erro nº', STATUS 
      RETURN FALSE
   END IF
      
   LET p_num_reserva = SQLCA.SQLERRD[2]
   
  DELETE FROM wpol0801
   WHERE cod_empresa = l_estoque_loc_reser.cod_empresa    
     AND num_reserva = p_num_reserva
     AND indicador   = 'I'

   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
        'Erro ao deletar reserva da wpol0801 Erro nº', STATUS 
      RETURN FALSE
   END IF
   
   IF p_grava_est_loc THEN
      LET l_est_loc_reser_end.cod_empresa = p_cod_empresa_copia 
      LET l_est_loc_reser_end.num_reserva = p_num_reserva 
      
      INSERT INTO est_loc_reser_end VALUES (l_est_loc_reser_end.*)

      IF sqlca.sqlcode <> 0 THEN
         LET l_reserva_erro_885.des_erro = 'Erro insert est_loc_reser_end - Erro' , STATUS 
         RETURN FALSE
      END IF         
   END IF
   
   UPDATE estoque_loc_reser  
 	    SET num_referencia = p_num_reserva
 	  WHERE cod_empresa  	 = lr_wpol0801.cod_empresa  
      AND num_reserva    = lr_wpol0801.num_reserva 
       
   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 'Erro gravando estoque_loc_reser Erro nº', STATUS 
      RETURN FALSE
   END IF     

   RETURN TRUE
               
END FUNCTION

#------------------------------#  
FUNCTION pol0801_alreta_reser()
#------------------------------#  

   UPDATE estoque_loc_reser
      SET cod_local       = l_estoque_loc_reser.cod_local,
					qtd_reservada   = l_estoque_loc_reser.qtd_reservada,
					num_lote        = l_estoque_loc_reser.num_lote,
					ies_origem      = l_estoque_loc_reser.ies_origem,
					num_docum       = l_estoque_loc_reser.num_docum,
					ies_situacao    = l_estoque_loc_reser.ies_situacao,
					dat_prev_baixa  = l_estoque_loc_reser.dat_prev_baixa,
					num_conta_deb   = l_estoque_loc_reser.num_conta_deb,
					cod_uni_funcio  = l_estoque_loc_reser.cod_uni_funcio,
					nom_solicitante = l_estoque_loc_reser.nom_solicitante,
					dat_solicitacao = l_estoque_loc_reser.dat_solicitacao,
					nom_aprovante   = l_estoque_loc_reser.nom_aprovante,
					dat_aprovacao   = l_estoque_loc_reser.dat_aprovacao,
					qtd_atendida    = l_estoque_loc_reser.qtd_atendida,
					dat_ult_atualiz = l_estoque_loc_reser.dat_ult_atualiz
    WHERE cod_empresa = p_cod_empresa_copia
      AND num_reserva = p_reser_relac
      
   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
          'Erro atualizando estoque_loc_reser - Erro' , STATUS 
      RETURN FALSE
   END IF         

   DELETE FROM wpol0801
    WHERE cod_empresa = p_cod_empresa_copia    
      AND num_reserva = p_reser_relac
      AND indicador   = 'U'

   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
        'Erro ao deletar reserva wpol0801 Erro nº', STATUS 
      RETURN FALSE
   END IF

   IF p_grava_est_loc THEN
      UPDATE est_loc_reser_end
         SET comprimento = l_est_loc_reser_end.comprimento,
             largura     = l_est_loc_reser_end.largura,
             altura      = l_est_loc_reser_end.altura,
             diametro    = l_est_loc_reser_end.diametro
       WHERE cod_empresa = p_cod_empresa_copia
         AND num_reserva = p_reser_relac
      
      IF sqlca.sqlcode <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
             'Erro atualizando est_loc_reser_end - Erro' , STATUS 
         RETURN FALSE
      END IF         
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0801_grava_res_obs()
#-------------------------------#

   SELECT * 
     INTO l_estoq_loc_res_obs.* 
     FROM estoq_loc_res_obs  
    WHERE cod_empresa 		= lr_wpol0801.cod_empresa  
      AND num_reserva     = lr_wpol0801.num_reserva 
      
   IF sqlca.sqlcode = 0 THEN
      IF p_gravar_relac = 'I' THEN
         LET l_estoq_loc_res_obs.cod_empresa = p_cod_empresa_copia 
         LET l_estoq_loc_res_obs.num_reserva = p_num_reserva                

         INSERT INTO estoq_loc_res_obs 
            VALUES (l_estoq_loc_res_obs.*)

      ELSE
         UPDATE estoq_loc_res_obs
            SET tex_observ = l_estoq_loc_res_obs.tex_observ
          WHERE cod_empresa = p_cod_empresa_copia
            AND num_reserva = p_reser_relac
      END IF
      IF sqlca.sqlcode <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
             'Erro gravando estoq_loc_res_obs Erro nº', STATUS 
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 100 THEN
         LET l_reserva_erro_885.des_erro = 
             'Erro lendo estoq_loc_res_obs Erro nº', STATUS 
         RETURN FALSE
      END IF      
   END IF

   RETURN TRUE
   
END FUNCTION   

#------------------------------#  
FUNCTION pol0801_checa_estoque()
#------------------------------#

   IF NOT pol0801_le_relac() THEN
      RETURN FALSE
   END IF

   LET p_qtd_reservar = l_estoque_loc_reser.qtd_reservada +
                        l_estoque_loc_reser.qtd_atendida
                        
   IF p_gravar_relac = 'U' THEN
      IF p_num_lote_reser = l_estoque_loc_reser.num_lote THEN
         IF p_qtd_reservar > p_qtd_reservada THEN
            LET p_qtd_reservar = p_qtd_reservar - p_qtd_reservada
         ELSE
            LET p_qtd_reservar = 0
         END IF
      ELSE
         LET p_qtd_reservar = p_qtd_reservar - p_qtd_atendida
      END IF       
   END IF
   
   IF NOT pol0801_le_est_loc_reser_end() THEN
      RETURN FALSE
   END IF

   IF p_qtd_reservar = 0 THEN
      RETURN TRUE
   END IF
   
   IF NOT pol0801_tem_estoque() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0801_le_relac()
#--------------------------#

   SELECT reser_relac,
          qtd_atendida
     INTO p_reser_relac,
          p_qtd_atendida
     FROM reser_relac_885
    WHERE cod_empresa = l_estoque_loc_reser.cod_empresa
      AND num_reserva = l_estoque_loc_reser.num_reserva

   IF STATUS = 100 THEN
      LET p_qtd_atendida = 0
      LET p_gravar_relac = 'I'
      LET p_reser_relac = NULL
   ELSE
      IF STATUS = 0 THEN
         LET p_gravar_relac = 'U'
         IF NOT pol0801_le_reser() THEN
            RETURN FALSE
         END IF
      ELSE
         LET l_reserva_erro_885.des_erro = 
             'Erro lendo est_loc_reser_end - Erro nº', STATUS
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0801_le_reser()
#--------------------------#

   SELECT num_lote,
          qtd_reservada
     INTO p_num_lote_reser,
          p_qtd_reservada
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa_copia
      AND num_reserva = p_reser_relac

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
          'Erro ao ler estoque_loc_reser - Erro nº', STATUS
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol0801_le_est_loc_reser_end()
#--------------------------------------#

   LET p_grava_est_loc = TRUE
   
   SELECT *
     INTO l_est_loc_reser_end.*
     FROM est_loc_reser_end
    WHERE cod_empresa = l_estoque_loc_reser.cod_empresa
      AND num_reserva = l_estoque_loc_reser.num_reserva

   IF STATUS = 100 THEN
      LET p_grava_est_loc = FALSE
      LET l_est_loc_reser_end.largura = 0
      LET l_est_loc_reser_end.altura = 0
      LET l_est_loc_reser_end.comprimento = 0
      LET l_est_loc_reser_end.diametro = 0
   ELSE
      IF STATUS <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
             'Erro lendo est_loc_reser_end - Erro nº', STATUS
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol0801_le_estoque_lote_ender()
#--------------------------------------#

   IF l_estoque_loc_reser.num_lote IS NOT NULL THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa_copia
         AND cod_item    = l_estoque_loc_reser.cod_item
         AND cod_local   = l_estoque_loc_reser.cod_local
         AND num_lote    = l_estoque_loc_reser.num_lote
         AND largura     = l_est_loc_reser_end.largura
         AND altura      = l_est_loc_reser_end.altura
         AND diametro    = l_est_loc_reser_end.diametro
         AND comprimento = l_est_loc_reser_end.comprimento
         AND ies_situa_qtd = 'L'
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa_copia
         AND cod_item    = l_estoque_loc_reser.cod_item
         AND cod_local   = l_estoque_loc_reser.cod_local
         AND num_lote    IS NULL
         AND largura     = l_est_loc_reser_end.largura
         AND altura      = l_est_loc_reser_end.altura
         AND diametro    = l_est_loc_reser_end.diametro
         AND comprimento = l_est_loc_reser_end.comprimento
         AND ies_situa_qtd = 'L'
   END IF            

END FUNCTION

#-----------------------------#
FUNCTION pol0801_tem_estoque()
#-----------------------------#

   CALL pol0801_le_estoque_lote_ender()

   IF STATUS = 0 THEN
      LET p_qtd_saldo = p_estoque_lote_ender.qtd_saldo
   ELSE
      IF STATUS = 100 THEN
         LET p_qtd_saldo = 0
      ELSE      
         LET l_reserva_erro_885.des_erro = 
             'Erro lendo estoque_lote_ender - Erro nº', STATUS
         LET p_houve_erro = TRUE
         RETURN FALSE
      END IF
   END IF

   IF l_estoque_loc_reser.num_lote IS NOT NULL THEN
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada
        FROM estoque_loc_reser a,
             est_loc_reser_end b
       WHERE a.cod_empresa = p_cod_empresa_copia
         AND a.cod_item    = l_estoque_loc_reser.cod_item
         AND a.cod_local   = l_estoque_loc_reser.cod_local
         AND a.num_lote    = l_estoque_loc_reser.num_lote
         AND b.cod_empresa = a.cod_empresa
         AND b.num_reserva = a.num_reserva
         AND b.largura     = l_est_loc_reser_end.largura
         AND b.altura      = l_est_loc_reser_end.altura
         AND b.diametro    = l_est_loc_reser_end.diametro
         AND b.comprimento = l_est_loc_reser_end.comprimento
   ELSE
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada
        FROM estoque_loc_reser a,
             est_loc_reser_end b
       WHERE a.cod_empresa = p_cod_empresa_copia
         AND a.cod_item    = l_estoque_loc_reser.cod_item
         AND a.cod_local   = l_estoque_loc_reser.cod_local
         AND a.num_lote    IS NULL
         AND a.num_reserva = b.num_reserva
         AND b.largura     = l_est_loc_reser_end.largura
         AND b.altura      = l_est_loc_reser_end.altura
         AND b.diametro    = l_est_loc_reser_end.diametro
         AND b.comprimento = l_est_loc_reser_end.comprimento
   END IF            

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
          'Erro somando reservas da estoque_loc_reser - Erro nº', STATUS
      LET p_houve_erro = TRUE
      RETURN FALSE
   END IF

   IF p_qtd_reservada IS NULL THEN
      LET p_qtd_reservada = 0
   ELSE
      IF p_reser_relac IS NOT NULL THEN
         SELECT qtd_reservada
           INTO p_qtd_da_reser
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa_copia
            AND num_reserva = p_reser_relac
         IF p_qtd_da_reser IS NOT NULL THEN
            LET p_qtd_reservada = p_qtd_reservada - p_qtd_da_reser
         END IF
      END IF
   END IF
   
   IF p_qtd_saldo < p_qtd_reservada THEN
      LET p_qtd_saldo = 0
   ELSE
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   END IF
   
   IF p_qtd_saldo < p_qtd_reservar THEN
      LET l_reserva_erro_885.des_erro = 
          'Falta estoque p/ fazer a reserva'
      RETURN FALSE
   ELSE
      IF p_qtd_saldo = 0 THEN
         RETURN FALSE
      END IF
   END IF

   CALL pol0801_le_lote()

   IF STATUS = 100 THEN
      LET p_estoque_trans.cod_item = l_estoque_loc_reser.cod_item
      LET p_ies_situa = p_estoque_lote_ender.ies_situa_qtd
      LET p_estoque_trans_end.qtd_movto = p_estoque_lote_ender.qtd_saldo
      IF NOT pol0801_insere_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
             'Erro lendo estoque_lote - Erro nº', STATUS
         LET p_houve_erro = TRUE
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#  
FUNCTION pol0801_le_lote()
#-------------------------#  

   IF l_estoque_loc_reser.num_lote IS NOT NULL THEN
      SELECT *
        INTO p_estoque_lote.*
        FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa_copia
         AND cod_item    = l_estoque_loc_reser.cod_item
         AND cod_local   = l_estoque_loc_reser.cod_local
         AND num_lote    = l_estoque_loc_reser.num_lote
         #AND qtd_saldo  >= p_qtd_reservar
         AND ies_situa_qtd = 'L'
   ELSE         
      SELECT *
        INTO p_estoque_lote.*
        FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa_copia
         AND cod_item    = l_estoque_loc_reser.cod_item
         AND cod_local   = l_estoque_loc_reser.cod_local
         #AND qtd_saldo  >= p_qtd_reservar
         AND ies_situa_qtd = 'L'
         AND num_lote      IS NULL
   END IF            

END FUNCTION

#--------------------------------#  
 FUNCTION pol0801_copia_sup_par()
#--------------------------------#    

   DECLARE cq_rsv_1 CURSOR FOR
      SELECT *
        FROM sup_par_resv_est
       WHERE empresa = lr_wpol0801.cod_empresa
         AND reserva = lr_wpol0801.num_reserva 

   FOREACH cq_rsv_1 INTO l_sup_par_resv_est.*

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

      IF p_gravar_relac = 'I' THEN
         LET l_sup_par_resv_est.empresa = p_cod_empresa_copia 
         LET l_sup_par_resv_est.reserva = p_num_reserva
      
         INSERT INTO sup_par_resv_est 
           VALUES (l_sup_par_resv_est.*)
      
      ELSE
      
         UPDATE sup_par_resv_est
            SET parametro_val = l_sup_par_resv_est.parametro_val
          WHERE empresa   = p_cod_empresa_copia
            AND reserva   = p_reser_relac 
            AND parametro = l_sup_par_resv_est.parametro
            
      END IF
      
      IF sqlca.sqlcode <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
           'Erro na gravacao sup_par_resv_est - Erro', STATUS  
         RETURN FALSE
      END IF 
   
   END FOREACH  

   RETURN TRUE        
   
END FUNCTION   

#------------------------------#     
FUNCTION pol0801_grava_resdev()
#------------------------------#     

   SELECT *
     INTO l_sup_est_loc_resdev.*
     FROM sup_est_loc_resdev 
    WHERE empresa 		= lr_wpol0801.cod_empresa
      AND num_reserva	= lr_wpol0801.num_reserva 

   IF sqlca.sqlcode <> 0 THEN
      RETURN TRUE
   END IF 
   
   IF p_gravar_relac = 'I' THEN
      LET l_sup_est_loc_resdev.empresa     = p_cod_empresa_copia 
      LET l_sup_est_loc_resdev.num_reserva = p_num_reserva 
     
      INSERT INTO sup_est_loc_resdev 
         VALUES (l_sup_est_loc_resdev.*)          
   ELSE
      UPDATE sup_est_loc_resdev
         SET qtd_devolvida = l_sup_est_loc_resdev.qtd_devolvida,
             qtd_atendida  = l_sup_est_loc_resdev.qtd_atendida
       WHERE empresa 		 = p_cod_empresa_copia
         AND num_reserva = p_reser_relac 
   END IF
             
   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro na gravacao sup_est_loc_resdev - Erro', STATUS
      RETURN FALSE
   END IF 
     
   RETURN TRUE        
   
END FUNCTION   

#--------------------------------#
FUNCTION pol0801_atualiza_relac()
#--------------------------------#

   LET p_qtd_atender = 0
   
   IF p_gravar_relac = 'I' THEN
      LET p_num_docum = p_num_reserva
      INSERT INTO reser_relac_885
       VALUES (lr_wpol0801.cod_empresa,
               lr_wpol0801.num_reserva,
               p_num_reserva,
               p_qtd_atender)
   ELSE
      LET p_num_docum = p_reser_relac
      UPDATE reser_relac_885
         SET qtd_atendida = qtd_atendida + p_qtd_atender
       WHERE cod_empresa = lr_wpol0801.cod_empresa
         AND num_reserva = lr_wpol0801.num_reserva
   END IF
   
   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro na gravacao reser_relac_885 - Erro', STATUS
      RETURN FALSE
   END IF 
     
   RETURN TRUE        
   
END FUNCTION   

#-----------------------------------#
 FUNCTION pol0801_grava_estoque(p_op)
#-----------------------------------#  
 
   DEFINE p_op CHAR(01)

   IF p_op = 'R' THEN
      UPDATE estoque 
 	       SET qtd_reservada = qtd_reservada  + p_qtd_reservar 
       WHERE cod_empresa = p_cod_empresa_copia  
         AND cod_item    = l_estoque_loc_reser.cod_item
   ELSE
      SELECT dat_ult_entrada,
             dat_ult_saida
        INTO p_dat_ult_entrada,
             p_dat_ult_saida
        FROM estoque
       WHERE cod_empresa = p_estoque_lote.cod_empresa  
         AND cod_item    = p_estoque_lote.cod_item

      IF p_qtd_movto < 0 THEN
         LET p_dat_ult_entrada = TODAY
      ELSE
         LET p_dat_ult_saida = TODAY
      END IF
         
      IF p_op = 'L' THEN
         UPDATE estoque 
 	          SET qtd_liberada    = qtd_liberada - p_qtd_movto,
 	              qtd_reservada   = qtd_reservada - p_qtd_abat_reser,
 	              dat_ult_entrada = p_dat_ult_entrada,
 	              dat_ult_saida   = p_dat_ult_saida
          WHERE cod_empresa = p_estoque_lote.cod_empresa  
            AND cod_item    = p_estoque_lote.cod_item
      ELSE
         UPDATE estoque 
 	          SET qtd_lib_excep   = qtd_lib_excep - p_qtd_movto,
 	              qtd_reservada   = qtd_reservada - p_qtd_abat_reser,
 	              dat_ult_entrada = p_dat_ult_entrada,
 	              dat_ult_saida   = p_dat_ult_saida
          WHERE cod_empresa = p_estoque_lote.cod_empresa 
            AND cod_item    = p_estoque_lote.cod_item
      END IF
   END IF
      
   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro na gravacao estoque - Erro', STATUS
      RETURN FALSE
   END IF

   RETURN TRUE        
   
END FUNCTION   

#-------------------------------------#
FUNCTION pol0801_atualiza_lote_ender()
#-------------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo - p_qtd_movto
    WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
      AND num_transac = p_estoque_lote_ender.num_transac

   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro na gravacao estoque_lote_ender - Erro', STATUS
      RETURN FALSE
   END IF

   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
      AND num_transac = p_estoque_lote_ender.num_transac
      AND qtd_saldo <= 0
          
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0801_atualiza_lote()
#-------------------------------#

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo - p_qtd_movto
    WHERE cod_empresa = p_estoque_lote.cod_empresa
      AND num_transac = p_estoque_lote.num_transac

   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro na gravacao estoque_lote - Erro', STATUS
      RETURN FALSE
   END IF

   DELETE FROM estoque_lote
    WHERE cod_empresa = p_estoque_lote.cod_empresa
      AND num_transac = p_estoque_lote.num_transac
      AND qtd_saldo  <= 0
      
   RETURN TRUE
   
END FUNCTION



#------------------------------#
FUNCTION pol0801_insere_trans()
#------------------------------#

   INITIALIZE p_estoque_trans.* TO NULL
   
   LET p_estoque_trans.cod_empresa        = p_estoque_lote.cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_estoque_lote.cod_item
   LET p_estoque_trans.dat_movto          = TODAY
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.ies_tip_movto      = 'N'
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = "POL0801"
   LET p_estoque_trans.num_docum          = p_num_docum
   LET p_estoque_trans.num_seq            = 0
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = l_estoque_loc_reser.num_conta_deb
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.qtd_movto          = p_qtd_movto
   LET p_estoque_trans.ies_sit_est_orig   = p_ies_situa_orig
   LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa_dest
   LET p_estoque_trans.cod_local_est_orig = p_cod_local_orig
   LET p_estoque_trans.cod_local_est_dest = p_cod_local_dest
   LET p_estoque_trans.num_lote_orig      = p_num_lote_orig
   LET p_estoque_trans.num_lote_dest      = p_num_lote_dest

   IF NOT pol0801_inclui_estoq_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol0801_inclui_estoq_trans()
#------------------------------------#

    INSERT INTO estoque_trans(
          cod_empresa,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   


   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro inserindo na estoque_trans - Erro', STATUS
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol0801_insere_trans_end()
#-----------------------------------#

   INITIALIZE p_estoque_trans_end.*   TO NULL

   LET p_estoque_trans_end.num_transac      = p_num_transac
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
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = 0
   LET p_estoque_trans_end.cus_unit_movto_f = 0
   LET p_estoque_trans_end.cus_tot_movto_p  = 0
   LET p_estoque_trans_end.cus_tot_movto_f  = 0
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = ' '
   LET p_estoque_trans_end.tex_reservado    = " "

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro inserindo na estoque_trans_end - Erro', STATUS
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0801_insere_auditoria()
#-----------------------------------#

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa_copia, 
            p_num_transac,
            p_user, 
            getdate(),
            'pol0801')

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro inserindo na estoque_auditoria - Erro', STATUS
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#         
 FUNCTION pol0801_inclui_erro()   
#------------------------------#               

   LET l_reserva_erro_885.cod_empresa = lr_wpol0801.cod_empresa   
   LET l_reserva_erro_885.num_reserva = lr_wpol0801.num_reserva
   
   INSERT INTO reserva_erro_885 VALUES (l_reserva_erro_885.*)
  
 END FUNCTION       
 
#----------------------------------#
 FUNCTION pol0801_deleta_wpol0801()
#----------------------------------#

   IF NOT p_del_wpol0801 THEN
      RETURN TRUE
   END IF

  DELETE FROM wpol0801
   WHERE cod_empresa = lr_wpol0801.cod_empresa    
     AND num_reserva = lr_wpol0801.num_reserva
     AND indicador  != 'E'

   IF SQLCA.SQLCODE <> 0 THEN 
      LET l_reserva_erro_885.des_erro = 
       'Erro deletando wpol0801 - Erro', STATUS
      RETURN FALSE
   END IF
   
    RETURN TRUE

END FUNCTION 

#-----------------------------------#
 FUNCTION pol0801_processa_reservas()
#-----------------------------------#
   
   DECLARE cq_altera CURSOR WITH HOLD FOR
    SELECT DISTINCT
           cod_empresa,
           num_reserva
      FROM wpol0801
      WHERE (cod_empresa = l_empresas_885.cod_emp_oficial OR 
             cod_empresa = l_empresas_885.cod_emp_gerencial)
        AND indicador   IN ('I','U')
      ORDER BY num_reserva
     
   FOREACH cq_altera INTO lr_wpol0801.cod_empresa, lr_wpol0801.num_reserva

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

      IF STATUS <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
          'Erro lendo wpol0801 - Erro', STATUS
         RETURN FALSE
      END IF

      MESSAGE lr_wpol0801.num_reserva
            
      IF lr_wpol0801.cod_empresa = l_empresas_885.cod_emp_gerencial THEN
         LET p_cod_empresa_copia  = l_empresas_885.cod_emp_oficial
      ELSE  
         LET p_cod_empresa_copia  = l_empresas_885.cod_emp_gerencial
      END IF   

      LET p_del_wpol0801 = TRUE
      LET p_proces_ok = FALSE
      
      CALL log085_transacao("BEGIN")      
   
      IF pol0801_copia_rsv() THEN      
         IF pol0801_checa_movto() THEN
            IF pol0801_deleta_wpol0801() THEN 
               LET p_proces_ok = TRUE
            END IF
         END IF
      END IF

      IF p_proces_ok THEN
         CALL log085_transacao("COMMIT")          
      ELSE
         CALL log085_transacao("ROLLBACK")      
         CALL pol0801_inclui_erro()
      END IF
               
   END FOREACH     
   
END FUNCTION  

#------------------------------------#
 FUNCTION pol0801_processa_delecoes()
#------------------------------------#
   
   DECLARE cq_deleta CURSOR WITH HOLD FOR
    SELECT DISTINCT *
      FROM wpol0801
      WHERE (cod_empresa = l_empresas_885.cod_emp_oficial OR 
             cod_empresa = l_empresas_885.cod_emp_gerencial)
        AND indicador    = 'E'
      ORDER BY num_reserva
     
   FOREACH cq_deleta INTO lr_wpol0801.*
   
	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

      IF STATUS <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
          'Erro lendo wpol0801 - Erro', STATUS
         RETURN FALSE
      END IF

      CALL log085_transacao("BEGIN")      

      DELETE FROM wpol0801
       WHERE cod_empresa = lr_wpol0801.cod_empresa    
         AND num_reserva = lr_wpol0801.num_reserva
         AND indicador   = 'E'

      IF SQLCA.SQLCODE <> 0 THEN 
         LET l_reserva_erro_885.des_erro = 
          'Erro deletando wpol0801 - Erro', STATUS
         RETURN FALSE
      END IF
   
      SELECT reser_relac
        INTO p_reser_relac
        FROM reser_relac_885
       WHERE cod_empresa = lr_wpol0801.cod_empresa
         AND num_reserva = lr_wpol0801.num_reserva

      IF STATUS = 100 THEN
         CALL log085_transacao("COMMIT")      
         CONTINUE FOREACH
      END IF
   
      IF lr_wpol0801.cod_empresa = l_empresas_885.cod_emp_gerencial THEN
         LET p_cod_empresa_copia  = l_empresas_885.cod_emp_oficial
      ELSE  
         LET p_cod_empresa_copia  = l_empresas_885.cod_emp_gerencial
      END IF   

      IF pol0801_deleta_reserva() THEN
         CALL log085_transacao("COMMIT")          
      ELSE
         CALL log085_transacao("ROLLBACK")      
         CALL pol0801_inclui_erro()
      END IF
               
   END FOREACH     
   
END FUNCTION  

#--------------------------------#
FUNCTION pol0801_deleta_reserva()
#--------------------------------#

   SELECT qtd_reservada,
          cod_item
     INTO p_qtd_reservar,
          l_estoque_loc_reser.cod_item
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa_copia
      AND num_reserva = p_reser_relac
          
   IF p_qtd_reservar IS NOT NULL THEN
      LET p_qtd_reservar = -p_qtd_reservar
      IF NOT pol0801_grava_estoque("R") THEN
         RETURN FALSE
      END IF
   END IF
         
   DELETE FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa_copia
      AND num_reserva = p_reser_relac

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro deletando estoque_loc_reser - Erro', STATUS
      RETURN FALSE
   END IF

  DELETE FROM wpol0801
   WHERE cod_empresa = p_cod_empresa_copia    
     AND num_reserva = p_reser_relac
     AND indicador   = 'E'

   IF sqlca.sqlcode <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
        'Erro ao deletar reserva da wpol0801 Erro nº', STATUS 
      RETURN FALSE
   END IF
   
   DELETE FROM est_loc_reser_end
    WHERE cod_empresa = p_cod_empresa_copia
      AND num_reserva = p_reser_relac

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro deletando est_loc_reser_end - Erro', STATUS
      RETURN FALSE
   END IF
   
   DELETE FROM sup_par_resv_est
    WHERE empresa = p_cod_empresa_copia
      AND reserva = p_reser_relac

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro deletando sup_par_resv_est - Erro', STATUS
      RETURN FALSE
   END IF

   DELETE FROM estoq_loc_res_obs
    WHERE cod_empresa = p_cod_empresa_copia
      AND num_reserva = p_reser_relac

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro deletando estoq_loc_res_obs - Erro', STATUS
      RETURN FALSE
   END IF         

   DELETE FROM sup_est_loc_resdev
    WHERE empresa     = p_cod_empresa_copia
      AND num_reserva = p_reser_relac

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
       'Erro deletando sup_est_loc_resdev - Erro', STATUS
      RETURN FALSE
   END IF       

   RETURN TRUE     

END FUNCTION

#-----------------------------#
FUNCTION pol0801_checa_movto()
#-----------------------------#
   
   LET p_num_docum = lr_wpol0801.num_reserva 
   LET p_qtd_abat_reser = 0
   
   DECLARE cq_mov CURSOR FOR
    SELECT *
      FROM estoque_trans
     WHERE cod_empresa  = lr_wpol0801.cod_empresa
       AND num_docum    = p_num_docum
       AND cod_operacao IN 
          (p_req, p_dcc, p_ajco, p_emco, p_bxco)
       AND num_transac NOT IN
           (SELECT num_transac_orig
              FROM movto_relac_885
             WHERE cod_empresa = lr_wpol0801.cod_empresa)
             
   FOREACH cq_mov INTO p_estoque_trans.*

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
   
      IF STATUS <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
          'Erro lendo estoque_trans - Erro nº', STATUS
         RETURN FALSE
      END IF

      IF NOT pol0801_proces_movto() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0801_proces_movto()
#-----------------------------#

      LET p_movto_relac_885.cod_empresa     = lr_wpol0801.cod_empresa
      LET p_movto_relac_885.num_transac_orig = p_estoque_trans.num_transac

      SELECT *
        INTO p_estoque_trans_end.*
        FROM estoque_trans_end
       WHERE cod_empresa = p_estoque_trans.cod_empresa
         AND num_transac = p_estoque_trans.num_transac

      IF STATUS <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
          'Erro lendo estoque_trans_end - Erro nº', STATUS
         RETURN FALSE
      END IF

      SELECT ies_tipo,
             ies_acumulado
        INTO p_ies_tipo,
             p_ies_acumulado
        FROM estoque_operac
       WHERE cod_empresa  = p_cod_empresa
         AND cod_operacao = p_estoque_trans.cod_operacao
      
      IF STATUS <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
          'Erro lendo estoque_operac - Erro nº', STATUS
         RETURN FALSE
      END IF
   
      IF p_ies_tipo = 'S' THEN
         IF p_ies_acumulado = '2' THEN
            LET p_ies_tipo = 'E'
         END IF
      ELSE
         IF p_ies_acumulado = '1' THEN
            LET p_ies_tipo = 'S'
         END IF
      END IF      
            
      LET l_estoque_loc_reser.cod_item    = p_estoque_trans.cod_item
      LET l_estoque_loc_reser.cod_local   = p_estoque_trans.cod_local_est_orig

      IF l_estoque_loc_reser.cod_local IS NULL THEN
         LET l_estoque_loc_reser.cod_local = p_estoque_trans.cod_local_est_dest
      END IF
         
      LET l_estoque_loc_reser.num_lote    = p_estoque_trans.num_lote_orig
      
      IF l_estoque_loc_reser.num_lote IS NULL THEN
         LET l_estoque_loc_reser.num_lote = p_estoque_trans.num_lote_dest
      END IF
      
      LET l_est_loc_reser_end.largura     = p_estoque_trans_end.largura
      LET l_est_loc_reser_end.altura      = p_estoque_trans_end.altura
      LET l_est_loc_reser_end.diametro    = p_estoque_trans_end.diametro
      LET l_est_loc_reser_end.comprimento = p_estoque_trans_end.comprimento
      LET p_qtd_reservar                  = p_estoque_trans.qtd_movto
      LET p_qtd_movto                     = p_estoque_trans.qtd_movto
      LET l_reserva_erro_885.des_erro     = NULL
      LET p_houve_erro = FALSE

      IF p_ies_tipo = 'S' THEN
         IF NOT pol0801_le_relac() THEN
            RETURN FALSE
         END IF
         IF NOT pol0801_tem_estoque() THEN
            IF p_houve_erro THEN
               RETURN FALSE
            END IF
            LET p_del_wpol0801 = FALSE
            CALL pol0801_inclui_erro()
            RETURN TRUE
         END IF
      ELSE
         CALL pol0801_le_estoque_lote_ender()
         IF STATUS = 100 THEN
            LET p_estoque_lote_ender.num_transac = NULL
         ELSE
            IF STATUS <> 0 THEN
               LET l_reserva_erro_885.des_erro = 
                   'Erro lendo estoque_lote_ender - Erro nº', STATUS
               RETURN FALSE
            END IF
         END IF
         CALL pol0801_le_lote()
         IF STATUS = 100 THEN
            LET p_estoque_lote.num_transac = NULL
         ELSE
            IF STATUS <> 0 THEN
               LET l_reserva_erro_885.des_erro = 
                   'Erro lendo estoque_lote - Erro nº', STATUS
               RETURN FALSE
            END IF
         END IF
      END IF

      LET p_estoque_trans.cod_empresa        = p_cod_empresa_copia
      LET p_estoque_trans.dat_movto          = TODAY
      LET p_estoque_trans.dat_ref_moeda_fort = TODAY
      LET p_estoque_trans.dat_proces         = TODAY
      LET p_estoque_trans.hor_operac         = TIME

      IF NOT pol0801_inclui_estoq_trans() THEN
         RETURN FALSE
      END IF

      LET p_num_transac = SQLCA.SQLERRD[2]
      LET p_movto_relac_885.num_transac_dest = p_num_transac
      LET p_estoque_trans_end.cod_empresa   = p_cod_empresa_copia
      LET p_estoque_trans_end.num_transac   = p_num_transac
      
      INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

      IF STATUS <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
          'Erro inserindo na estoque_trans_end - Erro', STATUS
        RETURN FALSE
      END IF

      IF NOT pol0801_insere_auditoria() THEN    
         RETURN FALSE 
      END IF
      
      INSERT INTO movto_relac_885
       VALUES(p_movto_relac_885.*)
       
      IF STATUS <> 0 THEN
         LET l_reserva_erro_885.des_erro = 
          'Erro inserindo na movto_relac_885 - Erro', STATUS
        RETURN FALSE
      END IF

      IF p_ies_tipo = 'E' THEN
         IF NOT pol0801_proces_entrada() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_qtd_abat_reser = p_qtd_reservar
         IF NOT pol0801_grava_estoque(p_estoque_lote.ies_situa_qtd) THEN  
            RETURN FALSE
         END IF 
         IF NOT pol0801_atualiza_lote_ender() THEN
            RETURN FALSE
         END IF
         IF NOT pol0801_atualiza_lote() THEN
            RETURN FALSE
         END IF
      END IF
   
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0801_proces_entrada()
#--------------------------------#

   LET p_qtd_movto = -p_qtd_movto
   
   IF p_estoque_trans.ies_sit_est_dest IS NOT NULL THEN
      LET p_ies_situa = p_estoque_trans.ies_sit_est_dest
   ELSE
      LET p_ies_situa = p_estoque_trans.ies_sit_est_orig
   END IF

   IF NOT pol0801_grava_estoque(p_ies_situa) THEN  
      RETURN FALSE
   END IF 

   IF p_estoque_lote_ender.num_transac IS NOT NULL THEN
      IF NOT pol0801_atualiza_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0801_insere_lote_ender() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_estoque_lote.num_transac IS NOT NULL THEN
      IF NOT pol0801_atualiza_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0801_insere_lote() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0801_insere_lote_ender()
#-----------------------------------#

   IF p_qtd_movto < 0 THEN
      LET p_qtd_movto = -p_qtd_movto
   END IF

   INSERT INTO estoque_lote_ender(
          cod_empresa,
          cod_item,
          cod_local,
          num_lote,
          endereco,
          num_volume,
          cod_grade_1,
          cod_grade_2,
          cod_grade_3,
          cod_grade_4,
          cod_grade_5,
          dat_hor_producao,
          num_ped_ven,
          num_seq_ped_ven,
          ies_situa_qtd,
          qtd_saldo,
          ies_origem_entrada,
          dat_hor_validade,
          num_peca,
          num_serie,
          comprimento,
          largura,
          altura,
          diametro,
          dat_hor_reserv_1,
          dat_hor_reserv_2,
          dat_hor_reserv_3,
          qtd_reserv_1,
          qtd_reserv_2,
          qtd_reserv_3,
          num_reserv_1,
          num_reserv_2,
          num_reserv_3,
          tex_reservado) 
          VALUES(p_cod_empresa_copia,
                 p_estoque_trans.cod_item,
                 l_estoque_loc_reser.cod_local,
                 l_estoque_loc_reser.num_lote,
                 p_estoque_trans_end.endereco,
                 p_estoque_trans_end.num_volume,
                 p_estoque_trans_end.cod_grade_1,
                 p_estoque_trans_end.cod_grade_2,
                 p_estoque_trans_end.cod_grade_3,
                 p_estoque_trans_end.cod_grade_4,
                 p_estoque_trans_end.cod_grade_5,
                 p_estoque_trans_end.dat_hor_producao,
                 p_estoque_trans_end.num_ped_ven,
                 p_estoque_trans_end.num_seq_ped_ven,
                 p_ies_situa,
                 p_estoque_trans_end.qtd_movto,
                 " ",
                 p_estoque_trans_end.dat_hor_validade,
                 p_estoque_trans_end.num_peca,
                 p_estoque_trans_end.num_serie,
                 p_estoque_trans_end.comprimento,
                 p_estoque_trans_end.largura,
                 p_estoque_trans_end.altura,
                 p_estoque_trans_end.diametro,
                 p_estoque_trans_end.dat_hor_reserv_1,
                 p_estoque_trans_end.dat_hor_reserv_2,
                 p_estoque_trans_end.dat_hor_reserv_3,
                 p_estoque_trans_end.qtd_reserv_1,
                 p_estoque_trans_end.qtd_reserv_2,
                 p_estoque_trans_end.qtd_reserv_3,
                 p_estoque_trans_end.num_reserv_1,
                 p_estoque_trans_end.num_reserv_2,
                 p_estoque_trans_end.num_reserv_3,
                 " ")
   
   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
          'Erro inserindo na estoque_lote_ender - Erro', STATUS
      RETURN FALSE
   END IF
   
   RETURN TRUE
      
END FUNCTION

#-----------------------------#
FUNCTION pol0801_insere_lote()
#-----------------------------#

   IF p_qtd_movto < 0 THEN
      LET p_qtd_movto = -p_qtd_movto
   END IF

   INSERT INTO 
    estoque_lote(cod_empresa,
                 cod_item,
                 cod_local,
                 num_lote,
                 ies_situa_qtd,
                 qtd_saldo) 
    VALUES(p_cod_empresa_copia,
           p_estoque_trans.cod_item,
           l_estoque_loc_reser.cod_local,
           l_estoque_loc_reser.num_lote,
           p_ies_situa,
           p_estoque_trans_end.qtd_movto)      

   IF STATUS <> 0 THEN
      LET l_reserva_erro_885.des_erro = 
          'Erro inserindo na estoque_lote - Erro', STATUS
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------FIM DO PROGRAMA---------------------#
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     