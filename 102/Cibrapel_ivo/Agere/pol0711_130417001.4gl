#-----------------------------------------------------------------------#
# SISTEMA.: VENDAS DISTRIBUICAO DE PRODUTOS                             #
# PROGRAMA: pol0711                                                     #
# MODULOS.: pol0711 - LOG0010 - LOG0030 - LOG0040 - LOG0050             #
#           LOG0060 - LOG0090 - LOG0190 - LOG0270 - LOG1200             #
#           LOG1300 - LOG1400 - VDP0050 - VDP0120 - VDP0140             #
# OBJETIVO: COMPATIBILIZA ORDENS DE COMPRAS                             #
# AUTOR...: LOGOCENTER GSP                                              #
# DATA....: 03/01/2008                                                  #
#-----------------------------------------------------------------------# 
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_num_oc_o             LIKE ordem_sup.num_oc,
          p_cod_empresa_o        LIKE ordem_sup.cod_empresa,
          p_erro                 CHAR(01),
          p_ies_situa_oc_o       LIKE ordem_sup.ies_situa_oc,
          p_num_pedido_of        LIKE ordem_sup.num_pedido,
          p_cod_empresa_copia    LIKE empresa.cod_empresa,
          p_houve_erro           SMALLINT,
          p_pula_oc              CHAR(01),
          p_count                SMALLINT,
          p_tem_oc               SMALLINT,          
          p_rowid                INTEGER,
          p_comando              CHAR(80),
          p_caminho              CHAR(80),
          p_nom_tela             CHAR(80),
          p_help                 CHAR(80),
          p_msg                  CHAR(30),
          p_insere               SMALLINT,
          p_last_row             SMALLINT,
          p_status               SMALLINT,
          pa_curr                SMALLINT,
          sc_curr                SMALLINT,
          p_i                    SMALLINT,
          p_cancel               INTEGER 

   DEFINE p_versao               CHAR(18) 

   DEFINE lr_wpol0711           RECORD LIKE wpol0711.*,
          l_ordem_sup_cot       RECORD LIKE ordem_sup_cot.*,
          l_cotacao_preco       RECORD LIKE cotacao_preco.*,
          l_ordem_sup           RECORD LIKE ordem_sup.*, 
          l_ordem_sup_compl     RECORD LIKE ordem_sup_compl.*, 
          l_ordem_sup_txt       RECORD LIKE ordem_sup_txt.*,
          l_prog_ordem_sup      RECORD LIKE prog_ordem_sup.*,
          l_dest_ordem_sup      RECORD LIKE dest_ordem_sup.*,
          l_prog_ordem_sup_com  RECORD LIKE prog_ordem_sup_com.*,
          l_estrut_ordem_sup    RECORD LIKE estrut_ordem_sup.*,
          l_pedido_sup          RECORD LIKE pedido_sup.*,
          l_pedido_sup_txt      RECORD LIKE pedido_sup_txt.*,
          l_estrut_ordem_sup    RECORD LIKE estrut_ordem_sup.*,
          l_ordem_sup_audit     RECORD LIKE ordem_sup_audit.*,  
          l_dest_prog_ord_sup   RECORD LIKE dest_prog_ord_sup.*,   
          l_empresas_885        RECORD LIKE empresas_885.*,          
          p_ordem_sup           RECORD LIKE ordem_sup.*,
          p_prog_ordem_sup      RECORD LIKE prog_ordem_sup.*,
          p_prog_ordem_sup_com  RECORD LIKE prog_ordem_sup_com.*,
          p_pedido_sup          RECORD LIKE pedido_sup.*,
          l_pedido_sup_compl    RECORD LIKE pedido_sup_compl.*,
          l_pedido_sup_885      RECORD LIKE pedido_sup_885.*,
          l_desc_ped_sup_885    RECORD LIKE desc_ped_sup_885.*,
          t_ordem_sup           RECORD LIKE ordem_sup.*, 
          t_ordem_sup_compl     RECORD LIKE ordem_sup_compl.*, 
          t_ordem_sup_txt       RECORD LIKE ordem_sup_txt.*,
          t_prog_ordem_sup      RECORD LIKE prog_ordem_sup.*,
          t_dest_ordem_sup      RECORD LIKE dest_ordem_sup.*,
          t_prog_ordem_sup_com  RECORD LIKE prog_ordem_sup_com.*,
          t_estrut_ordem_sup    RECORD LIKE estrut_ordem_sup.*,
          t_pedido_sup          RECORD LIKE pedido_sup.*,
          t_pedido_sup_txt      RECORD LIKE pedido_sup_txt.*,
          t_estrut_ordem_sup    RECORD LIKE estrut_ordem_sup.*,
          t_ordem_sup_cot       RECORD LIKE ordem_sup_cot.*,
          t_cotacao_preco       RECORD LIKE cotacao_preco.*,          
          t_dest_prog_ord_sup   RECORD LIKE dest_prog_ord_sup.*   

                   


END GLOBALS 

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0711-05.10.27"
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 7
   WHENEVER ERROR STOP
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
      CALL pol0711_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0711_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0711") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0711 AT 06,23 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE   
         
   IF pol0711_acerta_entradas() THEN
      CALL log085_transacao("COMMIT")
      CALL log085_transacao("BEGIN")
      WHENEVER ERROR CONTINUE   
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF
   
    
END FUNCTION   
   
#---------------------------------#
 FUNCTION pol0711_acerta_entradas()
#---------------------------------#
          
   SELECT *
     INTO l_empresas_885.*
     FROM empresas_885
    WHERE cod_emp_gerencial = p_cod_empresa
       OR cod_emp_oficial  = p_cod_empresa
            
   IF sqlca.sqlcode <> 0 THEN
      ERROR 'Problemas na leitura Empresas_885- Erro nº ', STATUS
      #LET p_houve_erro = TRUE
      #CALL log003_err_sql("LEITURA","EMPRESAS_885")
   END IF

  {Primeiro copia pedidos para a OF quando quando viram pedido na GR, depois atualiza os pedidos recebidos na OF} 
  	         
   DECLARE cq_entrada CURSOR FOR
    SELECT DISTINCT *
      FROM wpol0711
      WHERE  (cod_empresa = l_empresas_885.cod_emp_gerencial  OR 
              cod_empresa = l_empresas_885.cod_emp_oficial) 
     ORDER BY cod_empresa, num_oc, indicador
     
     
   INITIALIZE l_ordem_sup.*,l_prog_ordem_sup.*, l_dest_ordem_sup.*, l_estrut_ordem_sup.*, 
              l_ordem_sup_txt.*, l_prog_ordem_sup_com.*, l_ordem_sup_compl.*, 
              l_pedido_sup.*, l_pedido_sup_txt.*, l_ordem_sup_audit.*, lr_wpol0711.* TO NULL

   FOREACH cq_entrada INTO lr_wpol0711.*
   
          INITIALIZE p_cod_empresa_copia TO NULL
   
         IF lr_wpol0711.cod_empresa = l_empresas_885.cod_emp_gerencial THEN
            LET p_cod_empresa_copia  = l_empresas_885.cod_emp_oficial
            IF lr_wpol0711.indicador = 'I' THEN
               IF pol0711_ordem_aberta() = FALSE THEN
               ELSE
                  IF pol0711_copia_oc() = FALSE THEN
                     RETURN  FALSE
                  END IF
               END IF
            ELSE
               IF lr_wpol0711.indicador = 'E' THEN   
                  IF pol0711_verifica_exclusao() = FALSE THEN
                  ELSE
                     IF pol0711_deleta_oc() = FALSE THEN
                        RETURN  FALSE
                     END IF  
                  END IF  
               END IF                             
            END IF  
         ELSE  
             IF lr_wpol0711.cod_empresa = l_empresas_885.cod_emp_oficial THEN
                LET p_cod_empresa_copia  = l_empresas_885.cod_emp_gerencial
                IF lr_wpol0711.indicador <> 'E' THEN                 
                    IF pol0711_copia_oc() = FALSE THEN
                       RETURN  FALSE
                    END IF
                ELSE
                   IF lr_wpol0711.indicador = 'E' THEN   
                      IF pol0711_verifica_exclusao() = FALSE THEN
                      ELSE
                         IF pol0711_deleta_oc() = FALSE THEN
                            RETURN  FALSE
                         END IF  
                      END IF  
                   END IF                              
                END IF
             END IF        
         END IF
          
         IF NOT pol0711_deleta_wpol0711() THEN
            RETURN  FALSE
         END IF
         
    END FOREACH     
           
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
 FUNCTION pol0711_ordem_aberta()
#-------------------------------#

    SELECT cod_empresa,
            num_oc,
            ies_situa_oc
      INTO  p_cod_empresa_o,
            p_num_oc_o,
            p_ies_situa_oc_o           
      FROM ordem_sup
     WHERE cod_empresa      = l_empresas_885.cod_emp_oficial
       AND num_oc           = lr_wpol0711.num_oc
       AND ies_versao_atual = 'S' 

   IF sqlca.sqlcode = NOTFOUND  THEN
      RETURN TRUE
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
        ERROR 'Problemas no select del da ordem_sup of - Erro nº ', STATUS
        #CALL log003_err_sql("DELETE","Wpol0711")       
         RETURN FALSE
       END IF
   END IF
   
   IF p_ies_situa_oc_o  <> 'A'   AND 
      p_ies_situa_oc_o  <> 'D'   AND
      p_ies_situa_oc_o  <> 'T'   AND      
      p_ies_situa_oc_o  <> 'P'   THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE   
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol0711_verifica_exclusao()
#----------------------------------#

      LET p_tem_oc   =   0 
         
      SELECT COUNT(*) 
        INTO p_tem_oc
        FROM ordem_sup
       WHERE cod_empresa 		= lr_wpol0711.cod_empresa
         AND num_oc      		= lr_wpol0711.num_oc

      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN FALSE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura ordem_sup 3 - Erro nº ', STATUS
            RETURN FALSE
         END IF 
      END IF

      IF p_tem_oc  > 0   THEN
         RETURN FALSE  
      END IF
      
    RETURN TRUE 
END FUNCTION         
  
#-------------------------------#
 FUNCTION pol0711_deleta_oc()
#-------------------------------#

      IF pol0711_elimina_oc() = FALSE THEN 
         RETURN FALSE
      END IF 
 
      IF pol0711_elimina_prog() = FALSE THEN
         RETURN FALSE
      END IF 
  
      IF pol0711_elimina_prog_com() = FALSE THEN
         RETURN FALSE
      END IF 
  
      IF pol0711_elimina_dest() = FALSE THEN
         RETURN FALSE
      END IF 
  
      IF pol0711_elimina_estr() = FALSE THEN
         RETURN FALSE
      END IF 
   
      IF pol0711_elimina_txt() = FALSE THEN
         RETURN FALSE
      END IF 
      
      IF pol0711_elimina_compl() = FALSE THEN
         RETURN FALSE
      END IF 
      
      IF lr_wpol0711.cod_empresa = l_empresas_885.cod_emp_oficial  THEN
         IF pol0711_elimina_ped_ger() = FALSE THEN
             RETURN FALSE
         END IF 
         IF pol0711_elimina_txt_ped_ger() = FALSE THEN
             RETURN FALSE
         END IF 
      END IF 

   RETURN TRUE

END FUNCTION                                                                  
#----------------------------------#
 FUNCTION pol0711_elimina_oc()
#----------------------------------#
   DELETE FROM ordem_sup
    WHERE cod_empresa = p_cod_empresa_copia 
      AND num_oc      = lr_wpol0711.num_oc 
   
   IF sqlca.sqlcode = NOTFOUND  THEN
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na deleção ordem_sup of - Erro nº ', STATUS
         RETURN FALSE
       END IF
   END IF

   RETURN TRUE

END FUNCTION                 
#----------------------------------#
 FUNCTION pol0711_elimina_prog()
#----------------------------------#
   DELETE FROM prog_ordem_sup
    WHERE cod_empresa = p_cod_empresa_copia 
      AND num_oc      = lr_wpol0711.num_oc 
   
   IF sqlca.sqlcode = NOTFOUND  THEN
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na deleção prog_ordem_sup of - Erro nº ', STATUS
         RETURN FALSE
       END IF
   END IF
   
   RETURN TRUE

END FUNCTION      
#----------------------------------#
 FUNCTION pol0711_elimina_prog_com()
#----------------------------------#
 DELETE FROM prog_ordem_sup_com
    WHERE cod_empresa = p_cod_empresa_copia 
      AND num_oc      = lr_wpol0711.num_oc 
   
   IF sqlca.sqlcode = NOTFOUND  THEN
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na deleção prog_ordem_sup_com of - Erro nº ', STATUS
         RETURN FALSE
       END IF
   END IF

   RETURN TRUE

END FUNCTION                                                                  

#---------------------------------#
 FUNCTION pol0711_elimina_dest()
#---------------------------------#

   DELETE FROM dest_ordem_sup
    WHERE cod_empresa = p_cod_empresa_copia 
      AND num_oc      = lr_wpol0711.num_oc 
   
   IF sqlca.sqlcode = NOTFOUND THEN
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na deleção dest_ordem_sup of - Erro nº ', STATUS
         RETURN FALSE
      END IF
   END IF

   
   RETURN TRUE

END FUNCTION                                                                  

#--------------------------------#
 FUNCTION pol0711_elimina_estr()
#--------------------------------#
   DELETE FROM estrut_ordem_sup
    WHERE cod_empresa = p_cod_empresa_copia 
      AND num_oc      = lr_wpol0711.num_oc 
   
   IF sqlca.sqlcode = NOTFOUND  THEN
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
        ERROR 'Problemas na deleção estrut_ordem_sup of - Erro nº ', STATUS
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION       
#--------------------------------#
 FUNCTION pol0711_elimina_txt()
#--------------------------------#
   DELETE FROM ordem_sup_txt
    WHERE cod_empresa = p_cod_empresa_copia 
      AND num_oc      = lr_wpol0711.num_oc 
   
   IF sqlca.sqlcode = NOTFOUND  THEN
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
        ERROR 'Problemas na deleção ordem_sup_txt of - Erro nº ', STATUS
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION   
#----------------------------------#
 FUNCTION pol0711_elimina_compl()
#----------------------------------#
   DELETE FROM ordem_sup_compl
    WHERE cod_empresa = p_cod_empresa_copia 
      AND num_oc      = lr_wpol0711.num_oc 
   
   IF sqlca.sqlcode = NOTFOUND  THEN
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
        ERROR 'Problemas na deleção ordem_sup_compl of - Erro nº ', STATUS
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION   

#----------------------------------#
 FUNCTION pol0711_elimina_ped_ger()
#----------------------------------#
   INITIALIZE p_num_pedido_of TO NULL
  
   SELECT num_pedido
     INTO p_num_pedido_of
     FROM ordem_sup
     WHERE cod_empresa 		= l_empresas_885.cod_emp_oficial
      AND num_oc      		= lr_wpol0711.num_oc 
      AND ies_versao_atual='S'
 
   IF sqlca.sqlcode = NOTFOUND  THEN
      RETURN TRUE      
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
        ERROR 'Problemas na leitura ordem_sup_compl of - Erro nº ', STATUS
         RETURN FALSE
      END IF
   END IF

   IF p_num_pedido_of IS NULL THEN 
         RETURN TRUE
   ELSE   
      IF p_num_pedido_of = 0 THEN 
         RETURN TRUE
      END IF
   END IF   
 
    DELETE FROM pedido_sup
    WHERE cod_empresa = l_empresas_885.cod_emp_gerencial
      AND num_pedido      = p_num_pedido_of
   
   IF sqlca.sqlcode = NOTFOUND  THEN
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
        ERROR 'Problemas na deleção pedido_sup of - Erro nº ', STATUS
         RETURN FALSE
      END IF
   END IF
   RETURN TRUE

END FUNCTION  
#----------------------------------#
 FUNCTION pol0711_elimina_txt_ped_ger()
#----------------------------------#   
   DELETE FROM pedido_sup_txt
    WHERE cod_empresa     = l_empresas_885.cod_emp_gerencial
      AND num_pedido      = p_num_pedido_of
   
   IF sqlca.sqlcode = NOTFOUND  THEN
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
        ERROR 'Problemas na deleção pedido_sup_txt of - Erro nº ', STATUS
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION   
#-------------------------------#
 FUNCTION pol0711_copia_oc()
#-------------------------------#


      IF pol0711_inclui_oc() = FALSE THEN
         RETURN FALSE
      END IF 
  
      IF pol0711_inclui_prog() = FALSE THEN
         RETURN FALSE
      END IF 
      
      IF pol0711_inclui_prog_com() = FALSE THEN
         RETURN FALSE
      END IF 
  
      IF pol0711_inclui_dest() = FALSE THEN
         RETURN FALSE
      END IF 
  
      IF pol0711_inclui_estr() = FALSE THEN
         RETURN FALSE
      END IF 
   
      IF pol0711_inclui_txt() = FALSE THEN
         RETURN FALSE
      END IF 
      
       IF pol0711_inclui_compl() = FALSE THEN
         RETURN FALSE
      END IF 
      
      IF pol0711_inclui_cotacao() = FALSE THEN
         RETURN FALSE
      END IF 
      IF lr_wpol0711.cod_empresa = l_empresas_885.cod_emp_oficial  THEN
         IF pol0711_inclui_pedido() = FALSE THEN
            RETURN FALSE
         END IF 
         IF pol0711_inclui_pedido_txt() = FALSE THEN
            RETURN FALSE
         END IF 
      END IF 

      RETURN TRUE

END FUNCTION                                                                  

#----------------------------------#
 FUNCTION pol0711_inclui_oc()
#----------------------------------#
    INITIALIZE l_ordem_sup.* TO NULL
  
    DECLARE cq_in_oc CURSOR FOR
      
    SELECT *
      FROM ordem_sup
     WHERE cod_empresa 		= lr_wpol0711.cod_empresa
      AND num_oc      		= lr_wpol0711.num_oc 


   FOREACH cq_in_oc INTO l_ordem_sup.*
      
      LET p_houve_erro = FALSE
      LET l_ordem_sup.cod_empresa = p_cod_empresa_copia 
      
      LET p_erro =  'N'
      IF pol0711_ver_oc() = FALSE THEN
         IF p_erro =  'S'  THEN	
            RETURN FALSE         
         ELSE   
            CONTINUE FOREACH 
         END IF       
      END IF    
      
      INSERT INTO ordem_sup VALUES (l_ordem_sup.*)

      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na gravacao ordem_sup - Erro nº ', STATUS
         RETURN FALSE
      ELSE
         CONTINUE FOREACH 
      END IF
                
   END FOREACH   
   RETURN TRUE

END FUNCTION           
#----------------------------------#
 FUNCTION pol0711_ver_oc()
#----------------------------------#
    INITIALIZE t_ordem_sup.* TO NULL 
         
      SELECT * 
        INTO t_ordem_sup.*
        FROM ordem_sup
       WHERE cod_empresa 		= p_cod_empresa_copia  
         AND num_oc      		= l_ordem_sup.num_oc
         AND num_versao  		= l_ordem_sup.num_versao

      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN TRUE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura ordem_sup 2 - Erro nº ', STATUS
            RETURN FALSE
         END IF 
      END IF
            
      IF pol0711_compara_oc() = FALSE THEN
           RETURN FALSE 
      END IF


      DELETE  
        FROM ordem_sup
       WHERE cod_empresa 		= p_cod_empresa_copia  
         AND num_oc      		= l_ordem_sup.num_oc
         AND num_versao  		= l_ordem_sup.num_versao    

      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas delete ordem_sup 2 - Erro nº ', STATUS
         LET p_erro   =  'S' 
         RETURN FALSE
      END IF 

    RETURN TRUE 
END FUNCTION  
#----------------------------------#
 FUNCTION pol0711_compara_oc()
#----------------------------------#  
# esta rotina compara todos os campos da OC an empresa geren com a oficial e se todos os campos estiverem iguais 
# significa que a ordem esta igual nas duas empresas e assim o programa não copia novamente a ordem.  Sem essa rotina 
# o programa fica copiando de uma para outra empresa indefinidamente. 

      IF   (l_ordem_sup.num_oc      				<> t_ordem_sup.num_oc)  THEN
               RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.num_versao 				 	<> t_ordem_sup.num_versao)  THEN
               RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.num_versao_pedido 	<> t_ordem_sup.num_versao_pedido)  THEN
               RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.ies_versao_atual 		<> t_ordem_sup.ies_versao_atual)  THEN 
               RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.cod_item 						<> t_ordem_sup.cod_item)   THEN
               RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.num_pedido 					<> t_ordem_sup.num_pedido)   THEN
               RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.ies_situa_oc 				<> t_ordem_sup.ies_situa_oc)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.ies_origem_oc 			<> t_ordem_sup.ies_origem_oc)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.ies_item_estoq 			<> t_ordem_sup.ies_item_estoq)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.ies_imobilizado 		<> t_ordem_sup.ies_imobilizado)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.cod_unid_med 				<> t_ordem_sup.cod_unid_med)   THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.dat_emis 						<> t_ordem_sup.dat_emis)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.qtd_solic 					<> t_ordem_sup.qtd_solic)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.dat_entrega_prev 		<> t_ordem_sup.dat_entrega_prev)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.fat_conver_unid 		<> t_ordem_sup.fat_conver_unid)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.qtd_recebida 				<> t_ordem_sup.qtd_recebida)   THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.pre_unit_oc 				<> t_ordem_sup.pre_unit_oc)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.dat_ref_cotacao 		<> t_ordem_sup.dat_ref_cotacao)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.ies_tip_cotacao 		<> t_ordem_sup.ies_tip_cotacao)   THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.pct_ipi 						<> t_ordem_sup.pct_ipi)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.cod_moeda 					<> t_ordem_sup.cod_moeda)   THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.cod_fornecedor 			<> t_ordem_sup.cod_fornecedor)   THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.num_cotacao 				<> t_ordem_sup.num_cotacao)   THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.cnd_pgto 						<> t_ordem_sup.cnd_pgto)   THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.cod_mod_embar 			<> t_ordem_sup.cod_mod_embar)   THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.num_docum 					<> t_ordem_sup.num_docum)   THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.gru_ctr_desp 				<> t_ordem_sup.gru_ctr_desp)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.cod_secao_receb 		<> t_ordem_sup.cod_secao_receb)  THEN
               RETURN TRUE
      END IF 
      IF   (l_ordem_sup.cod_progr 					<> t_ordem_sup.cod_progr)  THEN
               RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.cod_comprador 			<> t_ordem_sup.cod_comprador)  THEN
               RETURN TRUE
      END IF 
      
      IF  (l_ordem_sup.pct_aceite_dif 			<> t_ordem_sup.pct_aceite_dif)  THEN
               RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.ies_tip_entrega 		<> t_ordem_sup.ies_tip_entrega)   THEN
                     RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.ies_liquida_oc 			<> t_ordem_sup.ies_liquida_oc)  THEN
                     RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.dat_abertura_oc 		<> t_ordem_sup.dat_abertura_oc)  THEN
                     RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.num_oc_origem 			<> t_ordem_sup.num_oc_origem)  THEN
                     RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.qtd_origem 					<> t_ordem_sup.qtd_origem)  THEN
                     RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.dat_origem 					<> t_ordem_sup.dat_origem)  THEN
                    RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.ies_tip_incid_ipi 	<> t_ordem_sup.ies_tip_incid_ipi)  THEN
                     RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.ies_tip_incid_icms 	<> t_ordem_sup.ies_tip_incid_icms)  THEN
                     RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.cod_fiscal 					<> t_ordem_sup.cod_fiscal)  THEN
                     RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.cod_tip_despesa 		<> t_ordem_sup.cod_tip_despesa)  THEN
                     RETURN TRUE
      END IF 
      
      IF   (l_ordem_sup.ies_insp_recebto 		<> t_ordem_sup.ies_insp_recebto)  THEN
                     RETURN TRUE 
      END IF 

      IF   (l_ordem_sup.ies_tipo_inspecao		<> t_ordem_sup.ies_tipo_inspecao) THEN
           RETURN TRUE 
      END IF
      
    RETURN FALSE
END FUNCTION        
                                                    
#----------------------------------#
 FUNCTION pol0711_inclui_prog()
#----------------------------------#
    INITIALIZE l_prog_ordem_sup.*, l_prog_ordem_sup_com.* TO NULL
  
    DECLARE cq_in_prog CURSOR FOR
      
    SELECT *
      FROM prog_ordem_sup
     WHERE cod_empresa 		= lr_wpol0711.cod_empresa
      AND num_oc      		= lr_wpol0711.num_oc 
    
   FOREACH cq_in_prog INTO l_prog_ordem_sup.*
      
      LET p_houve_erro = FALSE
      LET l_prog_ordem_sup.cod_empresa = p_cod_empresa_copia 
      
      LET p_erro =  'N'
      IF pol0711_ver_prog() = FALSE THEN
         IF p_erro =  'S'  THEN	
            RETURN FALSE         
         ELSE   
            CONTINUE FOREACH 
         END IF       
      END IF    
      
      INSERT INTO prog_ordem_sup VALUES (l_prog_ordem_sup.*)
      
      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na gravacao prog_ordem_sup - Erro nº ', STATUS
         RETURN FALSE
      ELSE
         CONTINUE FOREACH 
      END IF
                
   END FOREACH 
   
  RETURN TRUE

END FUNCTION  

#----------------------------------#
 FUNCTION pol0711_ver_prog()
#----------------------------------#
    INITIALIZE t_prog_ordem_sup.* TO NULL 
         
      SELECT * 
        INTO t_prog_ordem_sup.*
        FROM prog_ordem_sup
       WHERE cod_empresa 				= p_cod_empresa_copia  
         AND num_oc      				= l_prog_ordem_sup.num_oc
         AND num_versao  				= l_prog_ordem_sup.num_versao
         AND num_prog_entrega  	= l_prog_ordem_sup.num_prog_entrega         

      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN TRUE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura prog_ordem_sup 3 - Erro nº ', STATUS
            RETURN FALSE
         END IF 
      END IF
            
      IF pol0711_compara_prog() = FALSE THEN
         RETURN FALSE 
      END IF
      
      DELETE FROM prog_ordem_sup
       WHERE cod_empresa 				= p_cod_empresa_copia 
         AND num_oc      				= l_prog_ordem_sup.num_oc
         AND num_versao  				= l_prog_ordem_sup.num_versao
         AND num_prog_entrega  	= l_prog_ordem_sup.num_prog_entrega 
   
      IF sqlca.sqlcode = NOTFOUND  THEN
      ELSE 
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas na deleção prog_ordem_sup 3 - Erro nº ', STATUS
            LET p_erro   =  'S' 
          END IF
      END IF
   
  RETURN TRUE 
END FUNCTION  
#----------------------------------#
 FUNCTION pol0711_compara_prog()
#----------------------------------#
      IF   l_prog_ordem_sup.num_oc		<> t_prog_ordem_sup.num_oc THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.num_versao		<> t_prog_ordem_sup.num_versao    THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.num_prog_entrega		<> t_prog_ordem_sup.num_prog_entrega THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.ies_situa_prog		<> t_prog_ordem_sup.ies_situa_prog THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.ies_situa_prog		<> t_prog_ordem_sup.ies_situa_prog THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.qtd_solic		<> t_prog_ordem_sup.qtd_solic THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.qtd_recebida		<> t_prog_ordem_sup.qtd_recebida THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.num_pedido_fornec		<> t_prog_ordem_sup.num_pedido_fornec THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.qtd_em_transito		<> t_prog_ordem_sup.qtd_em_transito THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.qtd_recebida		<> t_prog_ordem_sup.qtd_recebida THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.dat_palpite		<> t_prog_ordem_sup.dat_palpite THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.tex_observacao		<> t_prog_ordem_sup.tex_observacao THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup.dat_origem		<> t_prog_ordem_sup.dat_origem THEN
           RETURN TRUE 
      END IF
           
    RETURN FALSE
END FUNCTION     
#----------------------------------#
 FUNCTION pol0711_inclui_prog_com()
#----------------------------------#
  {Inclui prog_ordem_sup_com se houver}
  	
   DECLARE cq_in_prog_com CURSOR FOR
      
    SELECT *
      FROM prog_ordem_sup_com
     WHERE cod_empresa 		= lr_wpol0711.cod_empresa
      AND num_oc      		= lr_wpol0711.num_oc 
    
   FOREACH cq_in_prog_com INTO l_prog_ordem_sup_com.*
      
      LET p_houve_erro = FALSE
      LET l_prog_ordem_sup_com.cod_empresa = p_cod_empresa_copia 
      
      LET p_erro =  'N'
      IF pol0711_ver_prog_com() = FALSE THEN
         IF p_erro =  'S'  THEN	
            RETURN FALSE         
         ELSE   
            CONTINUE FOREACH 
         END IF       
      END IF 
      
      INSERT INTO prog_ordem_sup_com VALUES (l_prog_ordem_sup_com.*)

      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na gravacao prog_ordem_sup_com - Erro nº ', STATUS
         RETURN FALSE
      ELSE
         CONTINUE FOREACH 
      END IF
                
   END FOREACH    
     
   RETURN TRUE

END FUNCTION  
#------------------------------#
 FUNCTION pol0711_ver_prog_com()
#------------------------------#
    INITIALIZE t_prog_ordem_sup_com.* TO NULL 
         
      SELECT * 
        INTO t_prog_ordem_sup_com.*
        FROM prog_ordem_sup_com
       WHERE cod_empresa 				= p_cod_empresa_copia  
         AND num_oc      				= l_prog_ordem_sup_com.num_oc
         AND num_versao  				= l_prog_ordem_sup_com.num_versao
         AND num_prog_entrega  	= l_prog_ordem_sup_com.num_prog_entrega         

      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN TRUE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura prog_ordem_sup_com 3 - Erro nº ', STATUS
            RETURN FALSE
         END IF 
      END IF
            
      IF pol0711_compara_prog_com() = FALSE THEN
         RETURN FALSE 
      END IF
      
      DELETE FROM prog_ordem_sup_com
       WHERE cod_empresa 				= p_cod_empresa_copia 
         AND num_oc      				= l_prog_ordem_sup_com.num_oc
         AND num_versao  				= l_prog_ordem_sup_com.num_versao
         AND num_prog_entrega  	= l_prog_ordem_sup_com.num_prog_entrega 
   
      IF sqlca.sqlcode = NOTFOUND  THEN
      ELSE 
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas na deleção prog_ordem_sup_com 3 - Erro nº ', STATUS
            LET p_erro   =  'S' 
          END IF
      END IF
   
  RETURN TRUE 
  
END FUNCTION   
#----------------------------------#
 FUNCTION pol0711_compara_prog_com()
#----------------------------------#

      IF   l_prog_ordem_sup_com.num_oc							<> t_prog_ordem_sup_com.num_oc THEN
           RETURN TRUE 
      END IF  
      
      IF   l_prog_ordem_sup_com.num_versao					<> t_prog_ordem_sup_com.num_versao THEN
           RETURN TRUE 
      END IF  
      
      IF   l_prog_ordem_sup_com.num_prog_entrega		<> t_prog_ordem_sup_com.num_prog_entrega THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup_com.val_solic						<> t_prog_ordem_sup_com.val_solic THEN
           RETURN TRUE 
      END IF
      
      IF   l_prog_ordem_sup_com.val_receb						<> t_prog_ordem_sup_com.val_receb THEN
           RETURN TRUE 
      END IF
      
    RETURN FALSE
    
END FUNCTION       
 
#----------------------------------#
 FUNCTION pol0711_inclui_dest()
#----------------------------------#
    INITIALIZE l_dest_ordem_sup.* TO NULL
  
    DECLARE cq_in_dest CURSOR FOR
      
    SELECT *
      FROM dest_ordem_sup
     WHERE cod_empresa 		= lr_wpol0711.cod_empresa
      AND num_oc      		= lr_wpol0711.num_oc 

   FOREACH cq_in_dest INTO l_dest_ordem_sup.*
      
      LET p_houve_erro = FALSE
      LET l_dest_ordem_sup.cod_empresa = p_cod_empresa_copia 
      
      
      LET p_erro =  'N'
      IF pol0711_ver_dest() = FALSE THEN
         IF p_erro =  'S'  THEN	
            RETURN FALSE         
         ELSE   
            CONTINUE FOREACH 
         END IF 
      END IF           
      
      INSERT INTO dest_ordem_sup (cod_empresa,
      														num_oc,
      														cod_area_negocio,
																	cod_lin_negocio, 
																	pct_particip_comp, 
																	num_conta_deb_desp, 
																	cod_secao_receb,
																	qtd_particip_comp, 
																	num_docum)     
      										VALUES (l_dest_ordem_sup.cod_empresa,
      														l_dest_ordem_sup.num_oc,
      														l_dest_ordem_sup.cod_area_negocio,
      														l_dest_ordem_sup.cod_lin_negocio,
       														l_dest_ordem_sup.pct_particip_comp,    
       														l_dest_ordem_sup.num_conta_deb_desp,   												 
        												  l_dest_ordem_sup.cod_secao_receb,      														
         									        l_dest_ordem_sup.qtd_particip_comp,     
         									        l_dest_ordem_sup.num_docum)          														
    
      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na gravacao dest_ordem_sup of - Erro nº ', STATUS
         RETURN FALSE
      ELSE
         CONTINUE FOREACH 
      END IF
                
   END FOREACH   
   RETURN TRUE

END FUNCTION     
#----------------------------------#
 FUNCTION pol0711_ver_dest()
#----------------------------------#
    INITIALIZE t_dest_ordem_sup.* TO NULL 
         
      SELECT * 
        INTO t_dest_ordem_sup.*
        FROM dest_ordem_sup
       WHERE cod_empresa 				= p_cod_empresa_copia  
         AND num_oc      				= l_dest_ordem_sup.num_oc
         AND cod_area_negocio   = l_dest_ordem_sup.cod_area_negocio
         AND cod_lin_negocio    = l_dest_ordem_sup.cod_lin_negocio
         AND pct_particip_comp  = l_dest_ordem_sup.pct_particip_comp
         AND num_conta_deb_desp = l_dest_ordem_sup.num_conta_deb_desp
         AND cod_secao_receb    = l_dest_ordem_sup.cod_secao_receb
         AND qtd_particip_comp  = l_dest_ordem_sup.qtd_particip_comp
         AND num_docum          = l_dest_ordem_sup.num_docum
            
      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN TRUE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura dest_ordem_sup_com 3 - Erro nº ', STATUS
            RETURN FALSE
         END IF 
      END IF
            
      IF pol0711_compara_dest() = FALSE THEN
         RETURN FALSE 
      END IF
      
      DELETE FROM dest_ordem_sup
       WHERE cod_empresa 				= p_cod_empresa_copia  
         AND num_transac       	= t_dest_ordem_sup.num_transac
   
         
      IF sqlca.sqlcode = NOTFOUND  THEN
      ELSE 
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas na deleção dest_ordem_sup 3 - Erro nº ', STATUS
            LET p_erro   =  'S' 
          END IF
      END IF
   
  RETURN TRUE 
END FUNCTION   
#----------------------------------#
 FUNCTION pol0711_compara_dest()
#----------------------------------#

      IF   l_dest_ordem_sup.num_oc							<> t_dest_ordem_sup.num_oc THEN
           RETURN TRUE 
      END IF
      
      IF   l_dest_ordem_sup.cod_area_negocio							<> t_dest_ordem_sup.cod_area_negocio THEN
           RETURN TRUE 
      END IF
      
      IF   l_dest_ordem_sup.cod_lin_negocio							<> t_dest_ordem_sup.cod_lin_negocio THEN
           RETURN TRUE 
      END IF
      
      IF   l_dest_ordem_sup.pct_particip_comp							<> t_dest_ordem_sup.pct_particip_comp	 THEN
           RETURN TRUE 
      END IF
      
      IF   l_dest_ordem_sup.num_conta_deb_desp							<> t_dest_ordem_sup.num_conta_deb_desp THEN
           RETURN TRUE 
      END IF
      
      IF   l_dest_ordem_sup.cod_secao_receb							<> t_dest_ordem_sup.cod_secao_receb THEN
           RETURN TRUE 
      END IF
      
      IF   l_dest_ordem_sup.qtd_particip_comp							<> t_dest_ordem_sup.qtd_particip_comp THEN
           RETURN TRUE 
      END IF
      
      IF   l_dest_ordem_sup.num_docum							<> t_dest_ordem_sup.num_docum THEN
           RETURN TRUE 
      END IF
      
    
  RETURN FALSE 
END FUNCTION           
#----------------------------------#
 FUNCTION pol0711_inclui_estr() 
#----------------------------------#
    INITIALIZE l_estrut_ordem_sup.* TO NULL
  
    DECLARE cq_in_estr CURSOR FOR
      
    SELECT *
      FROM estrut_ordem_sup
     WHERE cod_empresa 		= lr_wpol0711.cod_empresa
      AND num_oc      		= lr_wpol0711.num_oc 


   FOREACH cq_in_estr INTO l_estrut_ordem_sup.*
      
      LET p_houve_erro = FALSE
      LET l_estrut_ordem_sup.cod_empresa = p_cod_empresa_copia 
      
      LET p_erro =  'N'
      IF pol0711_ver_estr() = FALSE THEN
         IF p_erro =  'S'  THEN	
            RETURN FALSE         
         ELSE   
            CONTINUE FOREACH 
         END IF 
      END IF           

      INSERT INTO estrut_ordem_sup VALUES (l_estrut_ordem_sup.*)

      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na gravacao estrut_ordem_sup - Erro nº ', STATUS
         RETURN FALSE
      ELSE
         CONTINUE FOREACH 
      END IF
                
   END FOREACH
      
   RETURN TRUE

END FUNCTION   
#----------------------------------#
 FUNCTION pol0711_ver_estr()
#----------------------------------#
    INITIALIZE t_estrut_ordem_sup.* TO NULL 
  
     SELECT *
      INTO  t_estrut_ordem_sup.*
      FROM estrut_ordem_sup
     WHERE cod_empresa 		= p_cod_empresa_copia 
      AND num_oc      		= l_estrut_ordem_sup.num_oc 
      AND cod_item_comp		= l_estrut_ordem_sup.cod_item_comp 

          
      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN TRUE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura estrut_ordem_sup 3 - Erro nº ', STATUS
            RETURN FALSE
         END IF 
      END IF
            
      IF pol0711_compara_estr() = FALSE THEN
         RETURN FALSE 
      END IF
      
     DELETE FROM estrut_ordem_sup
     WHERE cod_empresa 		= p_cod_empresa_copia 
      AND num_oc      		= l_estrut_ordem_sup.num_oc 
      AND cod_item_comp		= l_estrut_ordem_sup.cod_item_comp 
               
      IF sqlca.sqlcode = NOTFOUND  THEN
      ELSE 
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas na deleção estr_ordem_sup 3 - Erro nº ', STATUS
            LET p_erro   =  'S' 
          END IF
      END IF
   
  RETURN TRUE 
END FUNCTION   
#----------------------------------#
 FUNCTION pol0711_compara_estr()
#----------------------------------#

      IF   l_estrut_ordem_sup.num_oc							<> t_estrut_ordem_sup.num_oc THEN
           RETURN TRUE 
      END IF
      
      IF   l_estrut_ordem_sup.cod_item_comp							<> t_estrut_ordem_sup.cod_item_comp THEN
           RETURN TRUE 
      END IF
      
      IF   l_estrut_ordem_sup.qtd_necessaria							<> t_estrut_ordem_sup.qtd_necessaria THEN
           RETURN TRUE 
      END IF
      
      IF   l_estrut_ordem_sup.cus_unit_compon							<> t_estrut_ordem_sup.cus_unit_compon THEN
           RETURN TRUE 
      END IF
    
  RETURN FALSE 
END FUNCTION       

#----------------------------------#
 FUNCTION pol0711_inclui_txt()
#----------------------------------#
    INITIALIZE l_ordem_sup_txt.* TO NULL
  
    DECLARE cq_in_txt CURSOR FOR
      
    SELECT *
      FROM ordem_sup_txt
     WHERE cod_empresa 		= lr_wpol0711.cod_empresa
      AND num_oc      		= lr_wpol0711.num_oc 


   FOREACH cq_in_txt INTO l_ordem_sup_txt.*
      
      LET p_houve_erro = FALSE
      LET l_ordem_sup_txt.cod_empresa = p_cod_empresa_copia 
      
      LET p_erro =  'N'
      IF pol0711_ver_txt() = FALSE THEN
         IF p_erro =  'S'  THEN	
            RETURN FALSE         
         ELSE   
            CONTINUE FOREACH 
         END IF 
      END IF   
      
      INSERT INTO ordem_sup_txt VALUES (l_ordem_sup_txt.*)

      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na gravacao ordem_sup_txt of - Erro nº ', STATUS
         RETURN FALSE
      ELSE
         CONTINUE FOREACH 
      END IF
                
   END FOREACH
      
   RETURN TRUE

END FUNCTION      
#----------------------------------#
 FUNCTION pol0711_ver_txt()
#----------------------------------#
    INITIALIZE t_ordem_sup_txt.* TO NULL 
  
      SELECT *
      INTO  t_ordem_sup_txt.* 
      FROM ordem_sup_txt
     WHERE cod_empresa 		= p_cod_empresa_copia 
      AND num_oc      		= l_ordem_sup_txt.num_oc
      AND ies_tip_texto  	= l_ordem_sup_txt.ies_tip_texto
      AND num_seq  				= l_ordem_sup_txt.num_seq     
  
        
      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN TRUE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura ordem_sup_txt 3 - Erro nº ', STATUS
            RETURN FALSE
         END IF 
      END IF
            
      IF pol0711_compara_txt() = FALSE THEN
         RETURN FALSE 
      END IF
      
     DELETE FROM ordem_sup_txt
     WHERE cod_empresa 		= p_cod_empresa_copia
      AND num_oc      		= l_ordem_sup_txt.num_oc
      AND ies_tip_texto  	= l_ordem_sup_txt.ies_tip_texto
      AND num_seq  				= l_ordem_sup_txt.num_seq 
               
      IF sqlca.sqlcode = NOTFOUND  THEN
      ELSE 
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas na deleção ordem_sup_txt 3 - Erro nº ', STATUS
            LET p_erro   =  'S' 
          END IF
      END IF
   
  RETURN TRUE 
END FUNCTION  
#----------------------------------#   
 FUNCTION pol0711_compara_txt()
#----------------------------------#

      IF   l_ordem_sup_txt.num_oc							          <> t_ordem_sup_txt.num_oc THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_txt.ies_tip_texto							  <> t_ordem_sup_txt.ies_tip_texto THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_txt.num_seq							        <> t_ordem_sup_txt.num_seq THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_txt.tex_observ_oc						          <> t_ordem_sup_txt.tex_observ_oc THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_txt.num_oc							          <> t_ordem_sup_txt.num_oc THEN
           RETURN TRUE 
      END IF
    
    RETURN FALSE 
END FUNCTION       
#----------------------------------#
 FUNCTION pol0711_inclui_compl()
#----------------------------------#
    INITIALIZE l_ordem_sup_compl.* TO NULL
  
    DECLARE cq_in_compl CURSOR FOR
      
    SELECT *
      FROM ordem_sup_compl
     WHERE cod_empresa 		= lr_wpol0711.cod_empresa
      AND num_oc      		= lr_wpol0711.num_oc 


   FOREACH cq_in_compl INTO l_ordem_sup_compl.*
      
      LET p_houve_erro = FALSE
      LET l_ordem_sup_compl.cod_empresa = p_cod_empresa_copia 
      
      LET p_erro =  'N'
      IF pol0711_ver_compl() = FALSE THEN
         IF p_erro =  'S'  THEN	
            RETURN FALSE         
         ELSE   
            CONTINUE FOREACH 
         END IF 
      END IF   
      
      INSERT INTO ordem_sup_compl VALUES (l_ordem_sup_compl.*)
      
      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na gravacao ordem_sup_compl of - Erro nº ', STATUS
         RETURN FALSE
      ELSE
         CONTINUE FOREACH 
      END IF
                
   END FOREACH   
   RETURN TRUE

END FUNCTION   

#----------------------------------#
 FUNCTION pol0711_ver_compl()
#----------------------------------#
    INITIALIZE t_ordem_sup_compl.* TO NULL 
  
      SELECT *
      INTO t_ordem_sup_compl.* 
      FROM ordem_sup_compl
     WHERE cod_empresa 		= p_cod_empresa_copia 
      AND num_oc      		= l_ordem_sup_compl.num_oc 
  
        
      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN TRUE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura ordem_sup_compl 3 - Erro nº ', STATUS
            RETURN FALSE
         END IF 
      END IF
            
      IF pol0711_compara_compl() = FALSE THEN
         RETURN FALSE 
      END IF
      
     DELETE FROM ordem_sup_compl
     WHERE cod_empresa 		= p_cod_empresa_copia 
      AND num_oc      		= l_ordem_sup_compl.num_oc  
               
      IF sqlca.sqlcode = NOTFOUND  THEN
      ELSE 
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas na deleção ordem_sup_compl 3 - Erro nº ', STATUS
            LET p_erro   =  'S' 
          END IF
      END IF
   
  RETURN TRUE 
END FUNCTION       



#----------------------------------#   
 FUNCTION pol0711_compara_compl()
#----------------------------------#

      IF   l_ordem_sup_compl.num_oc							          <> t_ordem_sup_compl.num_oc THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.val_item_moeda						          <> t_ordem_sup_compl.val_item_moeda THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.num_lista						          <> t_ordem_sup_compl.num_lista THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.nom_fabricante						          <> t_ordem_sup_compl.nom_fabricante THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.cod_ref_item							          <> t_ordem_sup_compl.cod_ref_item THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.nom_apelido							          <> t_ordem_sup_compl.nom_apelido THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.cod_subregiao							          <> t_ordem_sup_compl.cod_subregiao THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.ins_estadual							          <> t_ordem_sup_compl.ins_estadual THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.ies_tip_contrat_mp							          <> t_ordem_sup_compl.ies_tip_contrat_mp THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.cod_praca				<> t_ordem_sup_compl.cod_praca THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.cod_fiscal_compl		<> t_ordem_sup_compl.cod_fiscal_compl THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.possui_remito			<> t_ordem_sup_compl.possui_remito THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.tip_compra					<> t_ordem_sup_compl.tip_compra THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl.oc_contrato				<> t_ordem_sup_compl.oc_contrato THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_compl. val_tot_contrato				<> t_ordem_sup_compl. val_tot_contrato THEN
           RETURN TRUE 
      END IF
    
    RETURN FALSE  
END FUNCTION 
#----------------------------------#
 FUNCTION pol0711_inclui_cotacao()
#----------------------------------#
    INITIALIZE l_ordem_sup_cot.* , l_cotacao_preco TO NULL
  
    DECLARE cq_in_cot CURSOR FOR
      
    SELECT *
      FROM ordem_sup_cot
     WHERE cod_empresa 		= lr_wpol0711.cod_empresa
      AND num_oc      		= lr_wpol0711.num_oc 


   FOREACH cq_in_cot INTO l_ordem_sup_cot.*
      
      LET p_houve_erro = FALSE
      LET l_ordem_sup_cot.cod_empresa = p_cod_empresa_copia 
      
      LET p_erro =  'N'
      IF pol0711_ver_cot() = FALSE THEN
         IF p_erro =  'S'  THEN	
            RETURN FALSE         
         ELSE   
            CONTINUE FOREACH  
         END IF 
      END IF   
           
      INSERT INTO ordem_sup_cot VALUES (l_ordem_sup_cot.*)
      
      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na gravacao ordem_sup_cot   - Erro nº ', STATUS
         RETURN FALSE
      END IF
       
      SELECT *
      INTO l_cotacao_preco.*
      FROM cotacao_preco
     WHERE cod_empresa 		 = lr_wpol0711.cod_empresa
      AND  cod_fornecedor  = l_ordem_sup_cot.cod_fornecedor 
      AND  num_cotacao		 = l_ordem_sup_cot.num_cotacao 
      AND  num_versao      = l_ordem_sup_cot.num_versao_cot
      AND  cod_item        = l_ordem_sup_cot.cod_ref_item    
      
       IF sqlca.sqlcode = 0 THEN    
          LET l_cotacao_preco.cod_empresa = p_cod_empresa_copia 
          INSERT INTO cotacao_preco VALUES (l_cotacao_preco.*)
          IF sqlca.sqlcode <> 0 THEN
             ERROR 'Problemas na gravacao cotacao_preco   - Erro nº ', STATUS
             RETURN FALSE
          END IF
      END IF
                
   END FOREACH   
   RETURN TRUE

END FUNCTION   

#-------------------------#
 FUNCTION pol0711_ver_cot()
#-------------------------#
    INITIALIZE t_ordem_sup_cot.* TO NULL 
  
      SELECT *
      INTO t_ordem_sup_cot.* 
      FROM ordem_sup_cot
     WHERE cod_empresa 		= p_cod_empresa_copia 
      AND num_oc      		= l_ordem_sup_cot.num_oc
      AND num_versao_oc		= l_ordem_sup_cot.num_versao_oc  
      AND num_cotacao			= l_ordem_sup_cot.num_cotacao 
      AND num_versao_cot  = l_ordem_sup_cot.num_versao_cot
      AND cod_fornecedor  = l_ordem_sup_cot.cod_fornecedor 
  
        
      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN TRUE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura ordem_sup_cot 3 - Erro nº ', STATUS
            RETURN FALSE 
         END IF 
      END IF
            
      IF pol0711_compara_cot() = FALSE THEN
         RETURN FALSE 
      END IF
      
     DELETE FROM ordem_sup_cot
     WHERE cod_empresa 		= p_cod_empresa_copia 
      AND num_oc      		= l_ordem_sup_cot.num_oc 
      AND num_versao_oc		= l_ordem_sup_cot.num_versao_oc  
      AND num_cotacao			= l_ordem_sup_cot.num_cotacao 
      AND num_versao_cot  = l_ordem_sup_cot.num_versao_cot
      AND cod_fornecedor  = l_ordem_sup_cot.cod_fornecedor  
               
      IF sqlca.sqlcode = NOTFOUND  THEN
      ELSE 
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas na deleção ordem_sup_cot 3 - Erro nº ', STATUS
            LET p_erro   =  'S' 
          END IF
      END IF
   
   DELETE FROM cotacao_preco
     WHERE cod_empresa 		= p_cod_empresa_copia 
      AND cod_fornecedor  = l_ordem_sup_cot.cod_fornecedor 
      AND num_cotacao			= l_ordem_sup_cot.num_cotacao 
      AND num_versao      = l_ordem_sup_cot.num_versao_cot
      AND cod_item        = l_ordem_sup.cod_item  
               
      IF sqlca.sqlcode = NOTFOUND  THEN
      ELSE 
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas na deleção cotacao_preco 1 - Erro nº ', STATUS
            LET p_erro   =  'S' 
          END IF
      END IF
   
  RETURN TRUE 
END FUNCTION       

#------------------------------#   
 FUNCTION pol0711_compara_cot()
#------------------------------#

    
      IF   l_ordem_sup_cot.num_cotacao				 		          <> t_ordem_sup_cot.num_cotacao THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.cod_fornecedor						          <> t_ordem_sup_cot.cod_fornecedor THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.nom_fornecedor						          <> t_ordem_sup_cot.nom_fornecedor THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.nom_contato						          <> t_ordem_sup_cot.nom_contato THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.num_telefone						          <> t_ordem_sup_cot.num_telefone THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.dat_entrega						          <> t_ordem_sup_cot.dat_entrega THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.dat_inclusao						          <> t_ordem_sup_cot.dat_inclusao THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.num_dias_entrega						          <> t_ordem_sup_cot.num_dias_entrega THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.ies_melhor_preco						 <> t_ordem_sup_cot.ies_melhor_preco         THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.valor_presente 							<> t_ordem_sup_cot.valor_presente         THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.num_versao_oc 						   <> t_ordem_sup_cot.num_versao_oc        THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.num_versao_cot 						<> t_ordem_sup_cot.num_versao_cot         THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.nom_fabricante 							<> t_ordem_sup_cot.nom_fabricante         THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.cod_ref_item 							<> t_ordem_sup_cot.cod_ref_item         THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.ies_cot_designada 						<> t_ordem_sup_cot.ies_cot_designada         THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.nom_fabricante 						<> t_ordem_sup_cot.nom_fabricante         THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.cod_ref_item 					<> t_ordem_sup_cot.cod_ref_item         THEN
           RETURN TRUE 
      END IF

		  IF   l_ordem_sup_cot.ies_cot_designada		 <> t_ordem_sup_cot.ies_cot_designada         THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.login 					       <> t_ordem_sup_cot.login         THEN
           RETURN TRUE 
      END IF
      
      IF   l_ordem_sup_cot.hora_cadastro 					<> t_ordem_sup_cot.hora_cadastro         THEN
           RETURN TRUE 
      END IF
      
    
   RETURN FALSE 
END FUNCTION 

#----------------------------------# 
 FUNCTION pol0711_inclui_pedido() 
#----------------------------------#
INITIALIZE l_pedido_sup.* TO NULL

 INITIALIZE p_num_pedido_of TO NULL
  
   SELECT num_pedido
     INTO p_num_pedido_of
     FROM ordem_sup
     WHERE cod_empresa 		= l_empresas_885.cod_emp_oficial
      AND num_oc      		= lr_wpol0711.num_oc 
      AND ies_versao_atual='S'
 
   IF sqlca.sqlcode = NOTFOUND  THEN
      RETURN TRUE      
   ELSE 
      IF sqlca.sqlcode <> 0 THEN
        ERROR 'Problemas na leitura pedido_sup gr - Erro nº ', STATUS
         RETURN FALSE
      END IF
   END IF
   
    DECLARE cq_in_ped CURSOR FOR
      
    SELECT *
      FROM pedido_sup
     WHERE cod_empresa 		=  l_empresas_885.cod_emp_oficial
      AND num_pedido     		= p_num_pedido_of
   
   FOREACH cq_in_ped INTO l_pedido_sup.*
      
      LET p_houve_erro = FALSE
      LET l_pedido_sup.cod_empresa = l_empresas_885.cod_emp_gerencial
      
      LET p_erro =  'N'
      IF pol0711_ver_pedido() = FALSE THEN
         IF p_erro =  'S'  THEN	
            RETURN FALSE         
         ELSE   
            CONTINUE FOREACH 
         END IF 
      END IF  
      
      INSERT INTO pedido_sup VALUES (l_pedido_sup.*)      

      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na gravacao pedido_sup - Erro nº ', STATUS
         RETURN FALSE
      ELSE
         CONTINUE FOREACH 
      END IF 
                
   END FOREACH   
   
   RETURN TRUE
END FUNCTION  

#----------------------------------#
 FUNCTION pol0711_ver_pedido()
#----------------------------------#
      INITIALIZE t_pedido_sup.* TO NULL
  
     SELECT *
     INTO t_pedido_sup.* 
     FROM pedido_sup
     WHERE cod_empresa 		= l_empresas_885.cod_emp_oficial
      AND num_pedido   		= l_pedido_sup.num_pedido 
      AND num_versao   		= l_pedido_sup.num_versao       
 
        
      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN TRUE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura pedido_sup 3 - Erro nº ', STATUS
            RETURN FALSE
         END IF 
      END IF
            
      IF pol0711_compara_ped() = FALSE THEN
         RETURN FALSE 
      END IF
      
     DELETE FROM pedido_sup 
     WHERE cod_empresa 		= l_empresas_885.cod_emp_gerencial
      AND num_pedido      = l_pedido_sup.num_pedido
      AND num_versao   		= l_pedido_sup.num_versao      
               
      IF sqlca.sqlcode = NOTFOUND  THEN
      ELSE 
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas na deleção pedido_sup 3 - Erro nº ', STATUS
            LET p_erro   =  'S' 
          END IF
      END IF
   
  RETURN TRUE 
END FUNCTION    
#----------------------------------#   
 FUNCTION pol0711_compara_ped()
#----------------------------------#

      IF   l_pedido_sup.num_pedido			<>      t_pedido_sup.num_pedido THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.num_versao			<>      t_pedido_sup.num_versao THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.ies_versao_atual			<>      t_pedido_sup.ies_versao_atual THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.ies_situa_ped			<>      t_pedido_sup.ies_situa_ped THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.dat_emis			<>      t_pedido_sup.dat_emis THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.dat_liquidac			<>      t_pedido_sup.dat_liquidac THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.cod_fornecedor			<>      t_pedido_sup.cod_fornecedor THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.cod_moeda			<>      t_pedido_sup.cod_moeda THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.cnd_pgto			<>      t_pedido_sup.cnd_pgto THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.cod_mod_embar			<>      t_pedido_sup.cod_mod_embar THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.num_texto_loc_entr			<>      t_pedido_sup.num_texto_loc_entr THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.num_texto_loc_cobr			<>      t_pedido_sup.num_texto_loc_cobr THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.cod_transpor			<>      t_pedido_sup.cod_transpor THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.val_tot_ped			<>      t_pedido_sup.val_tot_ped THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.cod_comprador			<>      t_pedido_sup.cod_comprador THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.ies_impresso			<>      t_pedido_sup.ies_impresso THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup.ies_ped_automatic			<>      t_pedido_sup.ies_ped_automatic THEN
           RETURN TRUE 
      END IF
      

  RETURN TRUE 
END FUNCTION        
#------------------------------------# 
 FUNCTION pol0711_inclui_pedido_txt() 
#------------------------------------#
INITIALIZE  l_pedido_sup_txt.* TO NULL
   {Grava pedido_sup_txt} 
     
   DECLARE cq_in_ped_txt CURSOR FOR
         
    SELECT *
      FROM pedido_sup_txt
     WHERE cod_empresa 		= l_empresas_885.cod_emp_gerencial
      AND num_pedido     		= p_num_pedido_of
      
    FOREACH cq_in_ped_txt INTO l_pedido_sup_txt.*
      
      LET p_houve_erro = FALSE
      LET l_pedido_sup_txt.cod_empresa = l_empresas_885.cod_emp_oficial

      LET p_erro =  'N'
      IF pol0711_ver_pedido_txt() = FALSE THEN
         IF p_erro =  'S'  THEN	
            RETURN FALSE         
         ELSE   
            CONTINUE FOREACH 
         END IF 
      END IF  
      
      INSERT INTO pedido_sup_txt VALUES (l_pedido_sup_txt.*)

      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na gravacao pedido_sup_txt of - Erro nº ', STATUS
         RETURN FALSE
      ELSE
         CONTINUE FOREACH 
      END IF
                
   END FOREACH   
   
   
   RETURN TRUE
END FUNCTION   

#----------------------------------#
 FUNCTION pol0711_ver_pedido_txt()
#----------------------------------#
   INITIALIZE t_pedido_sup_txt.* TO NULL
  
   SELECT *
     INTO t_pedido_sup_txt.* 
     FROM pedido_sup_txt
     WHERE cod_empresa 		= l_empresas_885.cod_emp_oficial
      AND num_oc      		= l_pedido_sup_txt.num_oc 
      AND num_seq  		    = l_pedido_sup_txt.num_seq       
         
      IF sqlca.sqlcode = NOTFOUND  THEN    
         RETURN TRUE
      ELSE   
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas leitura pedido_sup_txt 3 - Erro nº ', STATUS
            RETURN FALSE
         END IF 
      END IF
            
      IF pol0711_compara_ped_txt() = FALSE THEN
         RETURN FALSE 
      END IF
      
     DELETE FROM pedido_sup_txt   
     WHERE cod_empresa 		= l_empresas_885.cod_emp_gerencial
      AND num_pedido      = l_pedido_sup_txt.num_pedido 
      AND num_seq  		    = l_pedido_sup_txt.num_seq             
               
      IF sqlca.sqlcode = NOTFOUND  THEN
      ELSE 
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Problemas na deleção pedido_sup_txt 3 - Erro nº ', STATUS
            LET p_erro   =  'S' 
          END IF
      END IF
   
  RETURN TRUE
END FUNCTION  
#----------------------------------#   
 FUNCTION pol0711_compara_ped_txt()
#----------------------------------#

      IF   l_pedido_sup_txt.num_pedido						<> t_pedido_sup_txt.num_pedido THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup_txt.num_seq							  <> t_pedido_sup_txt.num_seq THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup_txt.ies_tip_texto					<> t_pedido_sup_txt.ies_tip_texto THEN
           RETURN TRUE 
      END IF
      
      IF   l_pedido_sup_txt.tex_observ_pedido			<> t_pedido_sup_txt.tex_observ_pedido THEN
           RETURN TRUE 
      END IF
      
  RETURN TRUE 
END FUNCTION       
#---------------------------------------------------------#
 FUNCTION pol0711_deleta_wpol0711()
#---------------------------------------------------------#
  
 
  DELETE FROM wpol0711
   WHERE  num_oc        = lr_wpol0711.num_oc
     AND indicador     = lr_wpol0711.indicador

   IF SQLCA.SQLCODE <> 0 THEN 
      ERROR 'Problemas na deleção wpol0711 - Erro nº ', STATUS
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION 

