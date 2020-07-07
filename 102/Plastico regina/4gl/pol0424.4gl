#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: pol0424                                                 #
# MODULOS.: pol0424 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA ORDEM_MONTAG_TRAN                  #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 08/07/2004                                              #
#-------------------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_pedido         LIKE ordem_montag_item.num_pedido,
          p_cod_cliente        LIKE pedidos.cod_cliente,                
          p_qtd_terc           LIKE ordem_montag_tran.qtd_devolvida,
          p_sdo_lote           LIKE ordem_montag_tran.qtd_devolvida,
          p_qtd_neces          LIKE ordem_montag_tran.qtd_devolvida,
          p_qtd_om             LIKE ordem_montag_tran.qtd_devolvida,
          p_num_sequencia      LIKE ordem_montag_item.num_sequencia,
          p_cod_item           LIKE ordem_montag_item.cod_item,
          p_ies_sit_om         LIKE ordem_montag_mest.ies_sit_om,
          p_devolver           DECIMAL(10,3),
          p_status             SMALLINT,
          p_houve_erro         SMALLINT,
          p_grava              SMALLINT,
          p_num_trans          INTEGER, 
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          p_caminho            CHAR(80),
          g_ies_ambiente       CHAR(001),
          p_count              SMALLINT,
          p_qtd_reg            SMALLINT,
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(080),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_last_row           SMALLINT,
          pa_curr              SMALLINT,
          sc_curr              SMALLINT,
          p_i                  SMALLINT,
          p_msg                CHAR(500)

   DEFINE p_ordem_montag_tran  RECORD LIKE ordem_montag_tran.*,
          p_ordem_montag_trann RECORD LIKE ordem_montag_tran.*,
          p_estrut_item_indus  RECORD LIKE estrut_item_indus.*,
          p_ordem_montag_item  RECORD LIKE ordem_montag_item.*,
          p_nat_operacao       RECORD LIKE nat_operacao.*,
          p_item_de_terc       RECORD LIKE item_de_terc.*,
		      p_sup_item_terc_end  RECORD LIKE sup_item_terc_end.*
		  
		  
   DEFINE p_item RECORD
      cod_item_prd  LIKE estrut_item_indus.cod_item_prd,
      den_item_prd  LIKE item.den_item_reduz,
      qtd_reservada LIKE ordem_montag_item.qtd_reservada
   END RECORD

   DEFINE p_tela RECORD
      num_om        LIKE ordem_montag_tran.num_om,
      dat_inclusao  LIKE estrut_item_indus.dat_inclusao,
      cod_nat_oper  LIKE wfat_mestre.cod_nat_oper
   END RECORD

   DEFINE t_montag_item ARRAY[100] OF RECORD
      num_pedido    LIKE ordem_montag_item.num_pedido,
      num_sequencia LIKE ordem_montag_item.num_sequencia,
      cod_item      LIKE ordem_montag_item.cod_item,
      den_item      LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med,
      qtd_reservada LIKE ordem_montag_item.qtd_reservada
   END RECORD

   DEFINE t_estrut_item ARRAY[100] OF RECORD
      dat_inclusao  LIKE estrut_item_indus.dat_inclusao,
      seq_estrut    LIKE estrut_item_indus.seq_estrut,
      cod_item_ret  LIKE estrut_item_indus.cod_item_ret,  
      den_item_ret  LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med,
      qtd_item_ret  LIKE estrut_item_indus.qtd_item_ret
   END RECORD

   DEFINE t_ordem_montag ARRAY[100] OF RECORD
      cod_item      LIKE ordem_montag_tran.cod_item,    
      den_item_ret  LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med,
      qtd_devolvida LIKE ordem_montag_tran.qtd_devolvida,
      pre_unit      LIKE ordem_montag_tran.pre_unit,
      num_nf        LIKE ordem_montag_tran.num_nf       
   END RECORD

   DEFINE p_relat RECORD
      num_om        LIKE ordem_montag_tran.num_om,
      cod_item_prd  LIKE estrut_item_indus.cod_item_prd,
      den_item_prd  LIKE item.den_item_reduz,
      cod_item_ret  LIKE estrut_item_indus.cod_item_ret,
      den_item_ret  LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med, 
      qtd_devolvida LIKE ordem_montag_tran.qtd_devolvida,
      pre_unit      LIKE ordem_montag_tran.pre_unit,
      num_nf        LIKE ordem_montag_tran.num_nf
   END RECORD
END GLOBALS
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 15
   DEFER INTERRUPT
   LET p_versao = "POL0424-10.02.20"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0424.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0424_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0424_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0424") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0424 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0424","IN") THEN
            CALL pol0424_inclusao() RETURNING p_status
            IF NOT p_status THEN
               ERROR 'Opera��o cancelada'
            ELSE
               ERROR 'Opera��o efetuada com sucesso'
            END IF
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0424","CO") THEN
            CALL pol0424_consulta()
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
				CALL pol0424_sobre()
	  COMMAND KEY ("T") "faTurar"  "Fatura as solicita��es de  faturas"
			HELP 0001
			CALL log120_procura_caminho("VDP0742") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol0424
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0424

END FUNCTION

#-----------------------#
 FUNCTION pol0424_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Convers�o para 10.02.00\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol0424_inclusao()
#--------------------------#
   
   IF NOT pol0424_entrada_dados() THEN
      RETURN FALSE
   END IF
      
   BEGIN WORK

   IF NOT pol0424_ret_mat() THEN
      ROLLBACK WORK
      RETURN FALSE
   END IF
   
   COMMIT WORK
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol0424_ret_mat()#
#-------------------------#

   DECLARE cq_omit CURSOR FOR
    SELECT * 
      FROM ordem_montag_item a,
           item b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.num_om = p_tela.num_om
       AND a.cod_empresa = b.cod_empresa 
       AND a.cod_item = b.cod_item 
       AND b.ies_tip_item IN ('F','B') 
      
   FOREACH cq_omit INTO p_ordem_montag_item.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_omit')
         RETURN FALSE
      END IF
              
      SELECT MAX(dat_inclusao)
        INTO p_tela.dat_inclusao
        FROM estrut_item_indus
       WHERE cod_empresa  = p_cod_empresa
         AND cod_item_prd = p_ordem_montag_item.cod_item 
         AND cod_cliente  = p_cod_cliente          

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'estrut_item_indus')
         RETURN FALSE
      END IF
        
      DECLARE cq_estrut_item CURSOR WITH HOLD FOR

       SELECT *
         FROM estrut_item_indus
        WHERE cod_empresa  = p_cod_empresa
          AND cod_item_prd = p_ordem_montag_item.cod_item 
          AND dat_inclusao = p_tela.dat_inclusao
          AND cod_cliente  = p_cod_cliente          
         
      FOREACH cq_estrut_item INTO p_estrut_item_indus.*

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH', 'cq_estrut_item')
            RETURN FALSE
         END IF
         
         LET p_grava = FALSE
         LET p_qtd_neces = p_ordem_montag_item.qtd_reservada * p_estrut_item_indus.qtd_item_ret
   
         IF NOT pol0424_devolve_mat() THEN
            RETURN FALSE
         END IF     
         
      END FOREACH
         
   END FOREACH
     
END FUNCTION

#-----------------------------#
FUNCTION pol0424_devolve_mat()#
#-----------------------------#

   DEFINE p_qtd_dev_terc     DECIMAL(10,3),
          p_qtd_dev_fat      DECIMAL(10,3),
          p_qtd_dev_ldi      DECIMAL(10,3)
   
   DECLARE cq_item_terc CURSOR WITH HOLD FOR
    SELECT *
      FROM item_de_terc
     WHERE cod_empresa = p_cod_empresa
       AND cod_fornecedor = p_estrut_item_indus.cod_cliente
       AND cod_item = p_estrut_item_indus.cod_item_ret
       AND qtd_tot_recebida - qtd_tot_devolvida > 0
	     AND dat_emis_nf >= '01/09/2009'
     ORDER BY dat_emis_nf
         
   FOREACH cq_item_terc INTO p_item_de_terc.*
            
      SELECT SUM(qtd_devolvida)
        INTO p_qtd_dev_terc
        FROM item_dev_terc
       WHERE cod_empresa    = p_item_de_terc.cod_empresa
         AND num_nf         = p_item_de_terc.num_nf
         AND ser_nf         = p_item_de_terc.ser_nf
         AND ssr_nf         = p_item_de_terc.ssr_nf
         AND ies_especie_nf = p_item_de_terc.ies_especie_nf
         AND cod_fornecedor = p_item_de_terc.cod_fornecedor
			   AND num_sequencia  = p_item_de_terc.num_sequencia
			   AND dat_emis_nf      >= '01/09/2009'
                
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item_dev_terc')
         LET p_qtd_dev_terc = 0
      END IF

      IF p_item_de_terc.qtd_tot_devolvida < p_qtd_dev_terc THEN
         LET p_item_de_terc.qtd_tot_devolvida = p_qtd_dev_terc
      END IF
               
      LET p_qtd_terc = p_item_de_terc.qtd_tot_recebida - p_item_de_terc.qtd_tot_devolvida
                              
      IF p_qtd_terc <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      LET p_qtd_terc = 0
      
      DECLARE cq_tec_end CURSOR FOR
       SELECT *
         FROM sup_item_terc_end
        WHERE empresa           = p_item_de_terc.cod_empresa
          AND nota_fiscal       = p_item_de_terc.num_nf
          AND serie_nota_fiscal = p_item_de_terc.ser_nf
          AND subserie_nf       = p_item_de_terc.ssr_nf
          AND espc_nota_fiscal  = p_item_de_terc.ies_especie_nf
          AND fornecedor        = p_item_de_terc.cod_fornecedor
			    AND seq_aviso_recebto = p_item_de_terc.num_sequencia
			    AND item              = p_item_de_terc.cod_item
          AND (qtd_receb - qtd_consumida) > 0

      FOREACH cq_tec_end INTO p_sup_item_terc_end.*

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_tec_end')
            RETURN FALSE
         END IF
         
         SELECT SUM(qtd_devolvida)
           INTO p_qtd_dev_ldi
           FROM ldi_retn_terc_grd  #cont�m retornos pendentes e faturados
          WHERE empresa            = p_sup_item_terc_end.empresa
            AND nf_entrada         = p_sup_item_terc_end.nota_fiscal
            AND serie_nf_entrada   = p_sup_item_terc_end.serie_nota_fiscal
            AND subserie_nfe       = p_sup_item_terc_end.subserie_nf
            AND especie_nf_entrada = p_sup_item_terc_end.espc_nota_fiscal
            AND seq_aviso_recebto  = p_sup_item_terc_end.seq_aviso_recebto
            AND fornecedor         = p_sup_item_terc_end.fornecedor
            AND seq_tabulacao      = p_sup_item_terc_end.seq_tabulacao            
            AND ord_montag IN 
                (SELECT num_om FROM ordem_montag_mest
                  WHERE cod_empresa = p_cod_empresa
                    AND ies_sit_om = 'N')

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ldi_retn_terc_grd')
            RETURN FALSE
         END IF

         IF p_qtd_dev_ldi IS NULL THEN
            LET p_qtd_dev_ldi = 0
         END IF
         
         LET p_sdo_lote = p_sup_item_terc_end.qtd_receb - p_sup_item_terc_end.qtd_consumida
         
         LET p_sdo_lote = p_sdo_lote - p_qtd_dev_ldi

         IF p_sdo_lote <= 0 THEN
            CONTINUE FOREACH
         END IF

         IF p_sdo_lote < p_qtd_neces THEN
            LET p_devolver = p_sdo_lote
            LET p_qtd_neces = p_qtd_neces - p_devolver
         ELSE
            LET p_devolver = p_qtd_neces
            LET p_qtd_neces = 0
         END IF
         
         IF NOT pol0424_ins_ldi_retn_terc_grd() THEN
            RETURN FALSE
         END IF   
         
         LET p_qtd_terc = p_qtd_terc + p_devolver
         
         IF p_qtd_neces <= 0 THEN
             EXIT FOREACH
         END IF  
      
      END FOREACH

      IF NOT pol0424_ins_ordem_montag_tran() THEN
         RETURN FALSE
      END IF
      
      IF p_qtd_neces <= 0 THEN
         EXIT FOREACH
      END IF  
   
   END FOREACH

   IF p_qtd_neces <= 0 THEN
      RETURN TRUE
   END IF  

   UPDATE ordem_montag_mest SET ies_sit_om ='B'
    WHERE cod_empresa = p_cod_empresa 
      AND num_om = p_tela.num_om  
   
   LET p_msg = "Nao Existe Saldo de\n Terceiro para o Item: ", 
        p_estrut_item_indus.cod_item_ret CLIPPED
   
   CALL log0030_mensagem(p_msg,'excla')
   
   RETURN FALSE

END FUNCTION   

#---------------------------------------#
FUNCTION pol0424_ins_ldi_retn_terc_grd()#
#---------------------------------------#

   DEFINE p_ldi_retn_terc_grd RECORD LIKE ldi_retn_terc_grd.*
   
   LET p_ldi_retn_terc_grd.empresa 	       = p_cod_empresa
   LET p_ldi_retn_terc_grd.ord_montag      = p_tela.num_om
   LET p_ldi_retn_terc_grd.pedido 	       = p_ordem_montag_item.num_pedido
   LET p_ldi_retn_terc_grd.seq_item_pedido = p_ordem_montag_item.num_sequencia
   LET p_ldi_retn_terc_grd.grade_1 = p_sup_item_terc_end.grade_1
	 LET p_ldi_retn_terc_grd.grade_2 = p_sup_item_terc_end.grade_2
   LET p_ldi_retn_terc_grd.grade_3 = p_sup_item_terc_end.grade_3
	 LET p_ldi_retn_terc_grd.grade_4 = p_sup_item_terc_end.grade_4
	 LET p_ldi_retn_terc_grd.grade_5 = p_sup_item_terc_end.grade_5
	 LET p_ldi_retn_terc_grd.nf_entrada         = p_sup_item_terc_end.nota_fiscal        
	 LET p_ldi_retn_terc_grd.serie_nf_entrada   = p_sup_item_terc_end.serie_nota_fiscal  
	 LET p_ldi_retn_terc_grd.subserie_nfe       = p_sup_item_terc_end.subserie_nf        
	 LET p_ldi_retn_terc_grd.especie_nf_entrada = p_sup_item_terc_end.espc_nota_fiscal   
	 LET p_ldi_retn_terc_grd.fornecedor         = p_sup_item_terc_end.fornecedor         
	 LET p_ldi_retn_terc_grd.seq_aviso_recebto  = p_sup_item_terc_end.seq_aviso_recebto  
	 LET p_ldi_retn_terc_grd.seq_tabulacao      = p_sup_item_terc_end.seq_tabulacao      
   LET p_ldi_retn_terc_grd.qtd_devolvida     = p_devolver
   LET p_ldi_retn_terc_grd.preco_unit        = p_item_de_terc.val_remessa / p_item_de_terc.qtd_tot_recebida
   LET p_ldi_retn_terc_grd.natureza_operacao = p_tela.cod_nat_oper
   LET p_ldi_retn_terc_grd.num_trans  = 0
   LET p_ldi_retn_terc_grd.cond_pagto = 9

   INSERT INTO ldi_retn_terc_grd VALUES (p_ldi_retn_terc_grd.*)

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("INCLUSAO 1","ldi_retn_terc_grd")
      RETURN FALSE
   END IF		  			  

   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol0424_ins_ordem_montag_tran()#
#---------------------------------------#

   LET p_ordem_montag_tran.cod_empresa = p_cod_empresa                                              
   LET p_ordem_montag_tran.num_om = p_tela.num_om                                                   
   LET p_ordem_montag_tran.num_pedido = p_ordem_montag_item.num_pedido                              
   LET p_ordem_montag_tran.num_seq_item = p_ordem_montag_item.num_sequencia                         
   LET p_ordem_montag_tran.cod_item = p_estrut_item_indus.cod_item_ret                                     
   LET p_ordem_montag_tran.num_nf = p_item_de_terc.num_nf                                                          
   LET p_ordem_montag_tran.ser_nf = p_item_de_terc.ser_nf                                                          
   LET p_ordem_montag_tran.ssr_nf = p_item_de_terc.ssr_nf                                                          
   LET p_ordem_montag_tran.ies_especie_nf =  p_item_de_terc.ies_especie_nf                                         
   LET p_ordem_montag_tran.num_seq_nf = p_item_de_terc.num_sequencia                                               
   LET p_ordem_montag_tran.qtd_devolvida = p_qtd_terc
   LET p_ordem_montag_tran.pre_unit = p_item_de_terc.val_remessa / p_item_de_terc.qtd_tot_recebida                 
   LET p_ordem_montag_tran.cod_nat_oper = p_tela.cod_nat_oper                                                      
   LET p_ordem_montag_tran.num_transacao = 0                                                                       
                                                                                                                   
   INSERT INTO ordem_montag_tran VALUES (p_ordem_montag_tran.*)                                                    
                                                                                                                   
   IF STATUS <> 0 THEN                                                                                      
      CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_TRAN")                                                          
      RETURN FALSE
   END IF                                                                                                          
                                                                                                          	        
	 LET p_num_trans = SQLCA.SQLERRD[2]                                                                              
                                                                                                                   
   INSERT INTO ldi_om_trfor_inf_c                                                                                  
		  VALUES (p_ordem_montag_tran.cod_empresa,p_num_trans,p_cod_cliente)                             		  

   IF STATUS <> 0 THEN                                                                                      
      CALL log003_err_sql("INCLUSAO","ldi_om_trfor_inf_c")                                                          
      RETURN FALSE
   END IF                                                                                                                                                                                                      		          

   RETURN TRUE
   
END FUNCTION   
#-------------------------------#
 FUNCTION pol0424_entrada_dados()
#-------------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0424
   CLEAR FORM
   INITIALIZE p_tela.*, p_ordem_montag_tran.* TO NULL
   DISPLAY BY NAME p_tela.*
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela.* 
      WITHOUT DEFAULTS  

      AFTER FIELD num_om        
      IF p_tela.num_om IS NOT NULL THEN
         SELECT UNIQUE ord_montag
         FROM LDI_RETN_TERC_GRD
         WHERE empresa = p_cod_empresa
           AND ord_montag = p_tela.num_om        
         IF SQLCA.SQLCODE = 0 THEN
            ERROR "Ordem de Montagem J� Cadastrada"
            NEXT FIELD num_om
         END IF
         SELECT ies_sit_om
            INTO p_ies_sit_om
         FROM ordem_montag_mest
         WHERE cod_empresa = p_cod_empresa
           AND num_om = p_tela.num_om        
         IF p_ies_sit_om = "F" THEN
            ERROR "Ordem de Montagem J� Faturada !!!"
            NEXT FIELD num_om
         END IF
         SELECT UNIQUE num_pedido
            INTO p_num_pedido
         FROM ordem_montag_item
         WHERE cod_empresa = p_cod_empresa
           AND num_om = p_tela.num_om        
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Ordem de Montagem nao Cadastrada"
            NEXT FIELD num_om
         END IF
         SELECT cod_cliente
            INTO p_cod_cliente
         FROM pedidos 
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_num_pedido
      ELSE
         ERROR "O Campo Numero da O.M. nao pode ser Nulo"
         NEXT FIELD num_om
      END IF

      BEFORE FIELD dat_inclusao
         SELECT MAX(dat_inclusao)
            INTO p_tela.dat_inclusao
         FROM estrut_item_indus a,
              ordem_montag_item b
         WHERE a.cod_empresa = p_cod_empresa
           AND a.cod_empresa = b.cod_empresa
           AND a.cod_item_prd = b.cod_item
           AND a.cod_cliente = p_cod_cliente
           AND a.dat_inclusao < TODAY
         
      AFTER FIELD dat_inclusao
      IF p_tela.dat_inclusao IS NOT NULL THEN
         SELECT UNIQUE dat_inclusao
         FROM estrut_item_indus a,
              ordem_montag_item b
         WHERE a.cod_empresa = p_cod_empresa
           AND a.cod_empresa = b.cod_empresa
           AND a.cod_item_prd = b.cod_item
           AND dat_inclusao = p_tela.dat_inclusao
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Data da Formula nao Cadastrada p/ este Produto"
            NEXT FIELD dat_inclusao
         END IF
      ELSE
         ERROR "O Campo Data da Formula nao pode ser Nulo"
         NEXT FIELD dat_inclusao
      END IF

      BEFORE FIELD cod_nat_oper
         LET p_tela.cod_nat_oper = 40

      AFTER FIELD cod_nat_oper
      IF p_tela.cod_nat_oper IS NOT NULL THEN
         SELECT den_nat_oper,   
                ies_tip_controle
            INTO p_nat_operacao.den_nat_oper,
                 p_nat_operacao.ies_tip_controle
         FROM nat_operacao 
         WHERE cod_nat_oper = p_tela.cod_nat_oper
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Operacao de Retorno nao Cadastrada"
            NEXT FIELD cod_nat_oper
         ELSE
            DISPLAY BY NAME p_nat_operacao.den_nat_oper
            IF p_nat_operacao.ies_tip_controle <> "3" THEN
               ERROR "Operacao nao � de Retorno"
               NEXT FIELD cod_nat_oper
            END IF
         END IF
      ELSE
         ERROR "O Campo Operacao Retorno nao pode ser Nulo"
         NEXT FIELD cod_nat_oper
      END IF
      
      ON KEY (control-z)
         CALL pol0424_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0424
   IF INT_FLAG = 0 THEN
      LET p_ies_cons = FALSE
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0424_consulta()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04242") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol04242 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0424","CO") THEN
            CALL pol0424_consulta_ordem()
            IF p_ies_cons = TRUE THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0424_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0424_paginacao("ANTERIOR") 
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 007
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0424","EX") THEN
            IF p_ies_cons THEN
               CALL pol0424_exclusao() RETURNING p_status
               IF p_status THEN
                  ERROR 'Opera��o efetuada com sucesso'
               ELSE
                  ERROR 'Opera��o cancelada'
               END IF
            ELSE
               ERROR "Consulte Previamente para fazer a Exclusao"
            END IF
         END IF 
      COMMAND "Listar" "Lista Parametros de Entrada"
         HELP 008
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0424","CO") THEN
            IF p_ies_cons THEN
               CALL pol0424_listar() 
            ELSE
               ERROR "Informar Previamente Parametros de Entrada"
            END IF
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 009
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol04242

END FUNCTION

#--------------------------------#
 FUNCTION pol0424_consulta_ordem()
#--------------------------------#

   DEFINE sql_stmt, where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON ordem_montag_tran.num_om

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol04242
   IF INT_FLAG THEN
      LET p_ordem_montag_tran.* = p_ordem_montag_trann.*
      CLEAR FORM
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT UNIQUE cod_empresa, ",
                  "              num_om, ",
                  "              num_seq_item ",
                  "FROM ordem_montag_tran ",
                  "WHERE ", where_clause CLIPPED,
                  "ORDER BY num_om "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_ordem_montag_tran.cod_empresa,
                        p_ordem_montag_tran.num_om,
                        p_ordem_montag_tran.num_seq_item

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Argumentos de Pesquisa nao Encontrados"
         LET p_ies_cons = FALSE
      ELSE 
         LET p_ies_cons = TRUE
         CALL pol0424_exibe_dados()
      END IF

END FUNCTION  

#-----------------------------#
 FUNCTION pol0424_exibe_dados()
#-----------------------------#
 
   SELECT cod_item
      INTO p_item.cod_item_prd
   FROM ordem_montag_item
   WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
     AND num_om = p_ordem_montag_tran.num_om
     AND num_sequencia = p_ordem_montag_tran.num_seq_item

   SELECT den_item_reduz
      INTO p_item.den_item_prd
   FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item = p_item.cod_item_prd

   DISPLAY BY NAME p_ordem_montag_tran.num_om,
                   p_item.cod_item_prd,
                   p_item.den_item_prd

   INITIALIZE t_ordem_montag TO NULL
   DECLARE cq_ordem CURSOR WITH HOLD FOR
   SELECT cod_item,
          num_nf,     
          qtd_devolvida,
          pre_unit
   FROM ordem_montag_tran 
   WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
     AND num_om = p_ordem_montag_tran.num_om        
     AND num_seq_item = p_ordem_montag_tran.num_seq_item
   ORDER BY 1

   LET p_i = 1
   FOREACH cq_ordem INTO t_ordem_montag[p_i].cod_item,
                         t_ordem_montag[p_i].num_nf,       
                         t_ordem_montag[p_i].qtd_devolvida,
                         t_ordem_montag[p_i].pre_unit

      SELECT den_item_reduz,
             cod_unid_med
         INTO t_ordem_montag[p_i].den_item_ret,
              t_ordem_montag[p_i].cod_unid_med
      FROM item
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND cod_item = t_ordem_montag[p_i].cod_item
      LET p_i = p_i + 1

   END FOREACH

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_ordem_montag TO s_ordem_montag.*
   END DISPLAY

END FUNCTION   

#-----------------------------------#
 FUNCTION pol0424_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_ordem_montag_trann.* = p_ordem_montag_tran.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_ordem_montag_tran.cod_empresa,
                            p_ordem_montag_tran.num_om,       
                            p_ordem_montag_tran.num_seq_item 
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_ordem_montag_tran.cod_empresa,
                            p_ordem_montag_tran.num_om,       
                            p_ordem_montag_tran.num_seq_item  
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Itens nesta Direcao"
            LET p_ordem_montag_tran.* = p_ordem_montag_trann.*
            EXIT WHILE
         END IF
        
         SELECT UNIQUE cod_empresa,
                       num_om,
                       num_seq_item
            INTO p_ordem_montag_tran.cod_empresa,
                 p_ordem_montag_tran.num_om,     
                 p_ordem_montag_tran.num_seq_item 
         FROM ordem_montag_tran
         WHERE cod_empresa  = p_ordem_montag_tran.cod_empresa
           AND num_om = p_ordem_montag_tran.num_om
           AND num_seq_item = p_ordem_montag_tran.num_seq_item
  
         IF SQLCA.SQLCODE = 0 THEN 
            LET p_ies_cons = TRUE
            CALL pol0424_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION   
 
#--------------------------#
 FUNCTION pol0424_exclusao()
#--------------------------#

      IF NOT log004_confirm(20,45) THEN
         RETURN FALSE
      END IF
   
      SELECT ies_sit_om
         INTO p_ies_sit_om
      FROM ordem_montag_mest
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND num_om = p_ordem_montag_tran.num_om

      IF p_ies_sit_om = "F" THEN
         LET p_msg = "Exclusao nao Permitida\n Ordem de Montagem Faturada !!!"
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
      
      BEGIN WORK

      DELETE FROM ldi_om_trfor_inf_c
      WHERE empresa = p_ordem_montag_tran.cod_empresa
        AND num_trans IN
            (SELECT num_transacao FROM ordem_montag_tran
              WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
                AND num_om = p_ordem_montag_tran.num_om
                AND num_seq_item = p_ordem_montag_tran.num_seq_item)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','ldi_om_trfor_inf_c')
         ROLLBACK WORK
         RETURN FALSE
      END IF
      
      DELETE FROM ordem_montag_tran
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND num_om = p_ordem_montag_tran.num_om
        AND num_seq_item = p_ordem_montag_tran.num_seq_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','ordem_montag_tran')
         ROLLBACK WORK
         RETURN FALSE
      END IF

      DELETE FROM ldi_retn_terc_grd
      WHERE empresa = p_ordem_montag_tran.cod_empresa
        AND ord_montag = p_ordem_montag_tran.num_om
        AND seq_item_pedido = p_ordem_montag_tran.num_seq_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','ldi_retn_terc_grd')
         ROLLBACK WORK
         RETURN FALSE
      END IF

      COMMIT WORK

      RETURN TRUE
      
END FUNCTION   

#-----------------------#
 FUNCTION pol0424_popup()
#-----------------------#

   DEFINE p_cod_nat_oper LIKE nat_operacao.cod_nat_oper
  
   CASE
      WHEN INFIELD(cod_nat_oper)
         CALL log009_popup(6,25,"NAT. OPERACAO","nat_operacao","cod_nat_oper",
                           "den_nat_oper","","N","") 
            RETURNING p_cod_nat_oper
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0424 
         IF p_cod_nat_oper IS NOT NULL THEN 
            LET p_tela.cod_nat_oper = p_cod_nat_oper
            DISPLAY BY NAME p_tela.cod_nat_oper
         END IF
      WHEN INFIELD(dat_inclusao)
         CALL pol0424_busca_data()
            RETURNING t_estrut_item[pa_curr].*
            CURRENT WINDOW IS w_pol0424
            LET p_tela.dat_inclusao = t_estrut_item[pa_curr].dat_inclusao
            DISPLAY BY NAME p_tela.dat_inclusao
   END CASE

END FUNCTION  

#----------------------------#
 FUNCTION pol0424_busca_item()
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04243") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol04243 AT 3,5 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   INITIALIZE t_montag_item TO NULL
   CLEAR FORM

   DECLARE cq_item_prd CURSOR WITH HOLD FOR
   SELECT num_pedido,
          num_sequencia,
          cod_item,
          qtd_reservada
   FROM ordem_montag_item
   WHERE cod_empresa  = p_cod_empresa
     AND num_om = p_tela.num_om      

   LET p_i = 1
   FOREACH cq_item_prd INTO t_montag_item[p_i].num_pedido,  
                            t_montag_item[p_i].num_sequencia,
                            t_montag_item[p_i].cod_item,     
                            t_montag_item[p_i].qtd_reservada

      SELECT den_item_reduz,
             cod_unid_med
         INTO t_montag_item[p_i].den_item,
              t_montag_item[p_i].cod_unid_med
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = t_montag_item[p_i].cod_item
      LET p_i = p_i + 1

   END FOREACH 

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   LET INT_FLAG = FALSE
   INPUT ARRAY t_montag_item WITHOUT DEFAULTS FROM s_montag_item.*

      BEFORE FIELD num_pedido  
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD num_pedido  
         IF t_montag_item[pa_curr].num_pedido IS NULL THEN
            EXIT INPUT
         END IF

   END INPUT 

   IF INT_FLAG THEN
      INITIALIZE t_montag_item TO NULL
      CLOSE WINDOW w_pol04243
      RETURN t_montag_item[1].*
   ELSE
      CLOSE WINDOW w_pol04243
      RETURN t_montag_item[pa_curr].*
   END IF
 
END FUNCTION  

#----------------------------#
 FUNCTION pol0424_busca_data()
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04241") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol04241 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   INITIALIZE t_estrut_item TO NULL
   CLEAR FORM

   DECLARE cq_item_ret CURSOR WITH HOLD FOR
   SELECT a.dat_inclusao,
          a.seq_estrut,
          a.cod_item_ret,
          a.qtd_item_ret
   FROM estrut_item_indus a,
        ordem_montag_item b
   WHERE a.cod_empresa  = p_cod_empresa
     AND a.cod_item_prd = b.cod_item  
     AND a.cod_cliente  = p_cod_cliente
     AND a.cod_empresa = b.cod_empresa
 
   LET p_i = 1
   FOREACH cq_item_ret INTO t_estrut_item[p_i].dat_inclusao,
                            t_estrut_item[p_i].seq_estrut,  
                            t_estrut_item[p_i].cod_item_ret,     
                            t_estrut_item[p_i].qtd_item_ret

      SELECT den_item_reduz,
             cod_unid_med
         INTO t_estrut_item[p_i].den_item_ret,
              t_estrut_item[p_i].cod_unid_med
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = t_estrut_item[p_i].cod_item_ret
      LET p_i = p_i + 1

   END FOREACH 

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   LET INT_FLAG = FALSE
   INPUT ARRAY t_estrut_item WITHOUT DEFAULTS FROM s_estrut_item.*

      BEFORE FIELD dat_inclusao
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD dat_inclusao
         IF t_estrut_item[pa_curr].dat_inclusao IS NULL THEN
            EXIT INPUT
         END IF

   END INPUT 

   IF INT_FLAG THEN
      INITIALIZE t_estrut_item TO NULL
      CLOSE WINDOW w_pol04241
      RETURN t_estrut_item[1].*
   ELSE
      CLOSE WINDOW w_pol04241
      RETURN t_estrut_item[pa_curr].*
   END IF
 
END FUNCTION  

#------------------------#
 FUNCTION pol0424_listar()
#------------------------#

   DEFINE sql_stmt1, where_clause1 CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause1 ON ordem_montag_tran.num_om        

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol04242
   IF INT_FLAG THEN
      LET p_ordem_montag_tran.* = p_ordem_montag_trann.*
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt1 = "SELECT UNIQUE cod_empresa, ",
                   "              num_om, ",
                   "              num_seq_item ",
                   " FROM ordem_montag_tran ",
                   " WHERE ", where_clause1 CLIPPED
               #   " ORDER BY num_om "

   PREPARE var_query1 FROM sql_stmt1  
   DECLARE cq_relat CURSOR WITH HOLD FOR var_query1

   OPEN cq_relat
   FETCH cq_relat INTO p_ordem_montag_tran.cod_empresa,
                       p_ordem_montag_tran.num_om,
                       p_ordem_montag_tran.num_seq_item

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Argumentos de Pesquisa nao Encontrados"
         LET p_ies_cons = FALSE
         RETURN
      ELSE 
         SELECT cod_item
            INTO p_item.cod_item_prd
         FROM ordem_montag_item
         WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
           AND num_om = p_ordem_montag_tran.num_om
           AND num_sequencia = p_ordem_montag_tran.num_seq_item
         SELECT den_item_reduz
            INTO p_item.den_item_prd
         FROM item
         WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
           AND cod_item = p_item.cod_item_prd
         DISPLAY BY NAME p_ordem_montag_tran.cod_empresa,
                         p_ordem_montag_tran.num_om,
                         p_item.cod_item_prd,
                         p_item.den_item_prd
      END IF

   IF log028_saida_relat(20,42) IS NOT NULL THEN 
      MESSAGE " Processando a Extracao do Relatorio..." 
         ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0424_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0424.tmp' 
            START REPORT pol0424_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT pol0424_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN 
   END IF

   SELECT den_empresa
      INTO p_den_empresa
   FROM empresa
   WHERE cod_empresa = p_cod_empresa

   FOREACH cq_relat INTO p_ordem_montag_tran.cod_empresa,
                         p_ordem_montag_tran.num_om,
                         p_ordem_montag_tran.num_seq_item

      LET p_relat.num_om = p_ordem_montag_tran.num_om       
      SELECT cod_item
         INTO p_relat.cod_item_prd
      FROM ordem_montag_item
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND num_om = p_ordem_montag_tran.num_om
        AND num_sequencia = p_ordem_montag_tran.num_seq_item
      SELECT den_item_reduz
         INTO p_relat.den_item_prd
      FROM item
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND cod_item = p_relat.cod_item_prd

      DECLARE cq_relat_item CURSOR WITH HOLD FOR
      SELECT cod_item,
             num_nf,      
             qtd_devolvida, 
             pre_unit     
      FROM ordem_montag_tran
      WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
        AND num_om = p_ordem_montag_tran.num_om       
        AND num_seq_item = p_ordem_montag_tran.num_seq_item
      ORDER BY 1

      LET p_count = 0
      FOREACH cq_relat_item INTO p_relat.cod_item_ret,
                                 p_relat.num_nf,      
                                 p_relat.qtd_devolvida,
                                 p_relat.pre_unit

         SELECT den_item_reduz,
                cod_unid_med
            INTO p_relat.den_item_ret,
                 p_relat.cod_unid_med
         FROM item
         WHERE cod_empresa = p_ordem_montag_tran.cod_empresa
           AND cod_item = p_relat.cod_item_ret

         OUTPUT TO REPORT pol0424_relat(p_relat.*)
      #  INITIALIZE p_relat.* TO NULL
         LET p_count = p_count + 1

      END FOREACH

   END FOREACH

   FINISH REPORT pol0424_relat

   IF p_count > 0 THEN
      IF p_ies_impressao = "S" THEN
         MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
            ATTRIBUTE(REVERSE)
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando 
         END IF
      ELSE 
         MESSAGE "Relatorio Gravado no Arquivo ", p_nom_arquivo, " " 
            ATTRIBUTE(REVERSE)
      END IF
   ELSE 
      MESSAGE "Nao Existem Dados para serem Listados"
         ATTRIBUTE(REVERSE)
   END IF

END FUNCTION   

#----------------------------#
 REPORT pol0424_relat(p_relat)
#----------------------------# 

   DEFINE p_relat RECORD
      num_om        LIKE ordem_montag_tran.num_om,
      cod_item_prd  LIKE estrut_item_indus.cod_item_prd,
      den_item_prd  LIKE item.den_item_reduz,
      cod_item_ret  LIKE estrut_item_indus.cod_item_ret,
      den_item_ret  LIKE item.den_item_reduz,
      cod_unid_med  LIKE item.cod_unid_med, 
      qtd_devolvida LIKE ordem_montag_tran.qtd_devolvida,
      pre_unit      LIKE ordem_montag_tran.pre_unit,
      num_nf        LIKE ordem_montag_tran.num_nf      
   END RECORD

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   ORDER EXTERNAL BY p_relat.num_om,
                     p_relat.cod_item_prd

   FORMAT

      PAGE HEADER

         PRINT COLUMN 001, p_den_empresa[1,21],
               COLUMN 024, "LISTAGEM DE RETORNO DE MERCADORIAS",
               COLUMN 072, "FL. ", PAGENO USING "####&"
         PRINT COLUMN 001, "pol0424",
               COLUMN 042, "EXTRAIDO EM ", TODAY USING "dd/mm/yyyy",
               COLUMN 064, " AS ", TIME,
               COLUMN 077, "HRS."
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"

      BEFORE GROUP OF p_relat.num_om

         SKIP 1 LINE
         PRINT COLUMN 001, "O.M. : ", p_relat.num_om USING "#####&"

      BEFORE GROUP OF p_relat.cod_item_prd

         SKIP 1 LINE
         PRINT COLUMN 001, "Item Produzido : ", p_relat.cod_item_prd CLIPPED,
                           1 SPACE, p_relat.den_item_prd
         SKIP 1 LINE

         PRINT COLUMN 001, "Item Retorno", 
               COLUMN 018, "Descricao",
               COLUMN 038, "U.M.",
               COLUMN 047, "Qtde Devolvida",
               COLUMN 064, "Preco Unit",
               COLUMN 077, "N.F." 
         SKIP 1 LINE

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.cod_item_ret,
               COLUMN 018, p_relat.den_item_ret,
               COLUMN 040, p_relat.cod_unid_med,
               COLUMN 047, p_relat.qtd_devolvida USING "##,###,##&.&&&",
               COLUMN 062, p_relat.pre_unit USING "#,###,##&.&&",
               COLUMN 075, p_relat.num_nf USING "#####&"

END REPORT    
#------------------------------ FIM DE PROGRAMA BL-------------------------------#