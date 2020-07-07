#------------------------------------------------------------------------------#
# MODULOS.: POL0714 -                                                          #
# OBJETIVO: DEVOLVER ESTOQUES P.ACABADOS NA EMPRESA O1                         #
#         ESTE PGM DEVERA RODAR NA EMP. 01 APOS DO CANCELAMENTO DA NF          #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_user               LIKE usuario.nom_usuario,	       
	       p_num_nf             LIKE wfat_item.num_nff,
	       p_qtd_item           LIKE wfat_item.qtd_item,
         p_qtd_oper           LIKE wfat_item.qtd_item,
         p_num_om             LIKE nf_item.num_om,
	       p_num_nff_ini        LIKE nf_mestre.num_nff,
	       p_num_nff_fim        LIKE nf_mestre.num_nff,
	       p_qtd_res_at         LIKE estoque.qtd_reservada,
	       p_cod_local_estoq    LIKE item.cod_local_estoq,
	       p_num_pedido         LIKE nf_item.num_pedido,
	       p_nfit               RECORD LIKE nf_item.*,
	       p_estoque            RECORD LIKE estoque.*, 
	       p_nat_operacao       RECORD LIKE nat_operacao.*,
	       p_desc_nat_oper_885  RECORD LIKE desc_nat_oper_885.*,
	       p_estvdp             RECORD LIKE estrutura_vdp.*,
	       p_estoque_operac     RECORD LIKE estoque_operac.*, 
	       p_estoque_trans      RECORD LIKE estoque_trans.*, 
	       p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
	       p_estoque_obs        RECORD LIKE estoque_obs.*, 
	       p_empresas_885       RECORD LIKE empresas_885.*, 
	       p_wfat               RECORD LIKE nf_mestre.*,    
         p_cod_empresa        CHAR(02),
	       p_cancel             INTEGER,
	       p_num_nff_char       CHAR(06),
	       p_ies_ftg            CHAR(01),
	       p_ies_vl             CHAR(01),
	       p_ies_qt             CHAR(01),
	       p_ies_nf100          CHAR(01),                 
	       p_ies_processou      SMALLINT,
	       comando              CHAR(80),
	       p_ind                SMALLINT,
	       p_count              SMALLINT,
	       p_resposta           CHAR(1),
	       p_data               DATE,
	       p_hora               CHAR(05),
	       p_versao             CHAR(18),               
	       p_status             SMALLINT,
	       p_ies_situa          SMALLINT,
	       p_nom_help           CHAR(200),
	       p_nom_tela           CHAR(080),
	       p_msg                CHAR(100)

END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
##  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT 
  LET p_versao = "POL0714-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0714.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL pol0714_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0714_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0714") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0714 AT 5,3  WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar"   "Informar parametros "
       HELP 0009
       MESSAGE ""
       LET p_num_nff_ini = 0
       LET p_num_nff_fim = 0 
       DISPLAY "                                "  AT  9,5
       IF log005_seguranca(p_user,"VDP","pol0714","CO") THEN
	        IF pol0714_entrada_parametros() THEN
	           NEXT OPTION "Processar" 
	        END IF
       END IF
       
    COMMAND "Processar" "Processa baixa de estoque"
      HELP 001
      MESSAGE ""
      LET p_ies_situa  = 0
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","pol0714","IN") THEN
	        IF log004_confirm(16,30) THEN  
	           SELECT * INTO p_empresas_885.* 
	             FROM empresas_885 
	            WHERE cod_emp_oficial = p_cod_empresa
             IF SQLCA.sqlcode = 0 THEN    
	              IF pol0714_processa() THEN
	                 ERROR "Processamento Efetuado com Sucesso"
	                 NEXT OPTION "Fim"
	              ELSE
	                 ERROR "Processamento Cancelado"
	              END IF
	           ELSE
	              LET p_ies_processou = TRUE   
	           END IF    
	        ELSE
	          ERROR "Processamento Cancelado"          
	        END IF
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
      CALL pol0714_sobre()  
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
      
    COMMAND "Fim" "Sai do programa"
      IF p_ies_processou = FALSE THEN
	       ERROR "Funcao deve ser processada"
	       NEXT OPTION "Processar"
      ELSE
	       EXIT MENU
      END IF
  END MENU
  CLOSE WINDOW w_pol0714
END FUNCTION
#-----------------------------------#
FUNCTION pol0714_entrada_parametros()
#-----------------------------------#
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0714

   INPUT p_num_nff_ini,
    	   p_num_nff_fim  WITHOUT DEFAULTS
    FROM num_nff_ini,
	       num_nff_fim
      ON KEY (control-w)
	 CASE
	    WHEN infield(num_nff_ini)   CALL showhelp(3187)
	    WHEN infield(num_nff_fim)   CALL showhelp(3188)
	 END CASE
   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0714

   IF int_flag THEN
      LET int_flag = 0
      CLEAR FORM
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------#
 FUNCTION pol0714_processa()
#-----------------------------#
   LET p_ies_processou = TRUE
   LET p_hora = TIME
   BEGIN WORK 
DECLARE cq_nota CURSOR FOR 
   SELECT *  
     FROM nf_mestre
    WHERE cod_empresa = p_cod_empresa
      AND num_nff >= p_num_nff_ini 
      AND num_nff <= p_num_nff_fim 
      AND ies_situacao = "C"    

FOREACH cq_nota INTO p_wfat.* 
  
   LET p_ies_situa = 1 
   DISPLAY " Nota : "  AT  7,5
   display p_wfat.num_nff AT 7,12

   SELECT * INTO p_nat_operacao.*
     FROM nat_operacao 
    WHERE cod_nat_oper   = p_wfat.cod_nat_oper 

   SELECT * INTO p_estoque_operac.*
     FROM estoque_operac
    WHERE cod_operacao = p_nat_operacao.cod_movto_estoq
      AND cod_empresa  = p_cod_empresa

   IF sqlca.sqlcode = 100 OR                    
      p_estoque_operac.ies_tipo <> "S" THEN 
      CONTINUE FOREACH 
   END IF

   LET p_count = 0 
   LET p_num_nff_char = p_wfat.num_nff

   SELECT count(*) INTO p_count
     FROM estoque_trans
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      AND cod_operacao = p_nat_operacao.cod_movto_estoq
      AND num_docum = p_num_nff_char
      AND num_prog  = "POL0714"        
      AND ies_tip_movto = "R"

   IF p_count > 0  THEN
      CONTINUE FOREACH
   END IF

   LET p_ies_ftg = 'N'
   LET p_ies_vl = 'N'
   LET p_ies_qt = 'N' 
   LET p_ies_nf100 = 'N'
   LET p_count = 0
 
   SELECT COUNT(*)
     INTO p_count  
     FROM nf_item
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      AND num_nff     = p_wfat.num_nff
  
   IF p_count > 0 THEN 
      LET p_ies_ftg = 'S'
   END IF

   SELECT MAX(num_pedido)
     INTO p_num_pedido
     FROM nf_item
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_wfat.num_nff
      
   SELECT * 
     INTO p_desc_nat_oper_885.*
     FROM desc_nat_oper_885
    WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial 
      AND num_pedido  =  p_num_pedido
   IF p_desc_nat_oper_885.pct_desc_valor = 0 AND 
      p_desc_nat_oper_885.pct_desc_qtd = 0 THEN 
      LET p_ies_nf100 = 'S'
   ELSE
      IF p_desc_nat_oper_885.pct_desc_valor > 0 THEN
         LET p_ies_vl = 'S'        
      ELSE
         LET p_ies_qt = 'S'        
      END IF                
   END IF    

   CALL pol0714_devol_estoque() 

   CALL pol0714_atualiza_ped() 

END FOREACH
IF p_ies_situa = 1  THEN 
   COMMIT WORK 
   RETURN TRUE  
ELSE
   ERROR "Dados nao encontrado na tabela WFAT_MESTRE"
   SLEEP 2
   RETURN FALSE
END IF
END FUNCTION  
   
#--------------------------------#
 FUNCTION pol0714_devol_estoque()
#--------------------------------#
 DEFINE l_num_om        LIKE ordem_montag_mest.num_om,
        l_num_reserva   INTEGER,
        l_qtd_res       LIKE ordem_montag_grade.qtd_reservada,
        l_count         INTEGER
        
 DECLARE cq_devol CURSOR FOR
  SELECT *
    FROM estoque_trans
   WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
     AND num_docum = p_num_nff_char
     AND num_prog = 'POL0713'
     AND ies_tip_movto = "N"

 FOREACH cq_devol  INTO p_estoque_trans.*

   IF p_ies_nf100 = 'S' THEN 
      UPDATE estoque SET qtd_liberada = qtd_liberada + p_estoque_trans.qtd_movto
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
         AND cod_item    = p_estoque_trans.cod_item
   ELSE
      UPDATE estoque SET qtd_liberada = qtd_liberada + p_estoque_trans.qtd_movto,
                         qtd_reservada = qtd_reservada + p_estoque_trans.qtd_movto
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
         AND cod_item    = p_estoque_trans.cod_item
   END IF

   SELECT * 
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
      AND num_transac = p_estoque_trans.num_transac  

   LET p_count = 0
   IF p_estoque_trans.num_lote_orig = NULL OR 
      p_estoque_trans.num_lote_orig IS NULL THEN
      SELECT count(*) 
        INTO p_count 
        FROM estoque_lote    
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
         AND cod_item    = p_estoque_trans.cod_item
         AND cod_local   = p_estoque_trans.cod_local_est_orig
         AND num_lote    IS NULL
         AND ies_situa_qtd = 'L'

      IF p_count > 0 THEN 
         UPDATE estoque_lote SET qtd_saldo = qtd_saldo + p_estoque_trans.qtd_movto
          WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
            AND cod_item    = p_estoque_trans.cod_item
            AND num_lote    IS NULL
            AND cod_local   = p_estoque_trans.cod_local_est_orig
            AND ies_situa_qtd = 'L'
      ELSE
         INSERT INTO estoque_lote VALUES (p_empresas_885.cod_emp_gerencial,
                                          p_estoque_trans.cod_item,
                                          p_estoque_trans.cod_local_est_orig,
                                          p_estoque_trans.num_lote_orig,
                                          'L',
                                          p_estoque_trans.qtd_movto)
      END IF
   ELSE    
      SELECT count(*) 
        INTO p_count 
        FROM estoque_lote    
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
         AND cod_item    = p_estoque_trans.cod_item
         AND cod_local   = p_estoque_trans.cod_local_est_orig
         AND num_lote    = p_estoque_trans.num_lote_orig
         AND ies_situa_qtd = 'L'

      IF p_count > 0 THEN 
         UPDATE estoque_lote SET qtd_saldo = qtd_saldo + p_estoque_trans.qtd_movto
          WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
            AND cod_item    = p_estoque_trans.cod_item
            AND num_lote    = p_estoque_trans.num_lote_orig
            AND cod_local   = p_estoque_trans.cod_local_est_orig
            AND ies_situa_qtd = 'L'
      ELSE
         INSERT INTO estoque_lote VALUES (p_empresas_885.cod_emp_gerencial,
                                          p_estoque_trans.cod_item,
                                          p_estoque_trans.cod_local_est_orig,
                                          p_estoque_trans.num_lote_orig,
                                          'L',
                                          p_estoque_trans.qtd_movto)
      END IF
   END IF 

   LET p_count = 0
   IF p_estoque_trans.num_lote_orig = NULL OR 
      p_estoque_trans.num_lote_orig IS NULL THEN
      SELECT count(*) 
        INTO p_count 
        FROM estoque_lote_ender    
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
         AND cod_item    = p_estoque_trans.cod_item
         AND cod_local   = p_estoque_trans.cod_local_est_orig
         AND num_lote    IS NULL
         AND ies_situa_qtd = 'L'
         AND comprimento =   p_estoque_trans_end.comprimento
         AND altura      =   p_estoque_trans_end.altura   
         AND diametro    =   p_estoque_trans_end.diametro 

      IF p_count > 0 THEN 
         UPDATE estoque_lote_ender SET qtd_saldo=qtd_saldo + p_estoque_trans.qtd_movto
          WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
            AND cod_item    = p_estoque_trans.cod_item
            AND cod_local   = p_estoque_trans.cod_local_est_orig
            AND ies_situa_qtd = 'L'
            AND num_lote    IS NULL
            AND largura     =   p_estoque_trans_end.largura
            AND altura      =   p_estoque_trans_end.altura   
            AND diametro    =   p_estoque_trans_end.diametro 
      
      ELSE
        INSERT INTO estoque_lote_ender (cod_empresa, 
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
                            VALUES 
                                  (p_empresas_885.cod_emp_gerencial,
                                   p_estoque_trans.cod_item,
                                   p_estoque_trans.cod_local_est_orig,
                                   p_estoque_trans.num_lote_orig,
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
                                   'L',
                                   p_estoque_trans.qtd_movto,
                                   ' ',
                                   p_estoque_trans_end.dat_hor_producao, 
                                   p_estoque_trans_end.num_peca , 
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
                                   p_estoque_trans_end.tex_reservado)                                  
      
      END IF
   ELSE
      SELECT count(*) 
        INTO p_count 
        FROM estoque_lote_ender    
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
         AND cod_item    = p_estoque_trans.cod_item
         AND cod_local   = p_estoque_trans.cod_local_est_orig
         AND num_lote    = p_estoque_trans.num_lote_orig
         AND ies_situa_qtd = 'L'
         AND comprimento =   p_estoque_trans_end.comprimento
         AND altura      =   p_estoque_trans_end.altura   
         AND diametro    =   p_estoque_trans_end.diametro 

      IF p_count > 0 THEN 
         UPDATE estoque_lote_ender SET qtd_saldo=qtd_saldo + p_estoque_trans.qtd_movto
          WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
            AND cod_item    = p_estoque_trans.cod_item
            AND cod_local   = p_estoque_trans.cod_local_est_orig
            AND ies_situa_qtd = 'L'
            AND largura     =   p_estoque_trans_end.largura
            AND altura      =   p_estoque_trans_end.altura   
            AND diametro    =   p_estoque_trans_end.diametro 
      
      ELSE
        INSERT INTO estoque_lote_ender (cod_empresa, 
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
                            VALUES 
                                  (p_empresas_885.cod_emp_gerencial,
                                   p_estoque_trans.cod_item,
                                   p_estoque_trans.cod_local_est_orig,
                                   p_estoque_trans.num_lote_orig,
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
                                   'L',
                                   p_estoque_trans.qtd_movto,
                                   ' ',
                                   p_estoque_trans_end.dat_hor_producao, 
                                   p_estoque_trans_end.num_peca , 
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
                                   p_estoque_trans_end.tex_reservado)                                  
      
      END IF  
   END IF
    
   LET p_estoque_trans.cod_empresa   = p_empresas_885.cod_emp_gerencial 
   LET p_estoque_trans.dat_movto     = TODAY
   LET p_estoque_trans.dat_proces    = TODAY
   LET p_estoque_trans.hor_operac    = TIME 
   LET p_estoque_trans.num_transac   =  0
   LET p_estoque_trans.ies_tip_movto = 'R'
   LET p_estoque_trans.num_prog      = 'POL0714' 

 ##  INSERT INTO estoque_trans VALUES (p_estoque_trans.*)
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

 
   LET p_estoque_trans_end.num_transac =  SQLCA.SQLERRD[2]
   LET p_estoque_trans_end.cod_empresa = p_empresas_885.cod_emp_gerencial
   LET p_estoque_trans_end.ies_tip_movto = 'R'   

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)
 
 END FOREACH

 DECLARE cq_om CURSOR FOR
 SELECT UNIQUE num_om
   FROM nf_item
  WHERE cod_empresa = p_cod_empresa 
    AND num_nff     = p_wfat.num_nff
 FOREACH cq_om INTO l_num_om

   UPDATE ordem_montag_mest
      SET ies_sit_om = 'N'
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
      AND num_om      = l_num_om        


   IF p_ies_ftg = 'S' THEN 
      DECLARE cq_loc CURSOR FOR 
        SELECT num_reserva,qtd_reservada
          FROM ordem_montag_grade
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
           AND num_om      = l_num_om        
      FOREACH cq_loc INTO l_num_reserva,l_qtd_res
         UPDATE estoque_loc_reser SET qtd_reservada = qtd_reservada + l_qtd_res
             WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
               AND num_reserva = l_num_reserva
      END FOREACH
   ELSE
     IF p_ies_vl = 'S' THEN 
        DECLARE cq_locv CURSOR FOR 
          SELECT num_reserva,qtd_reservada
            FROM ordem_montag_grade
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_om      = l_num_om        
        FOREACH cq_locv INTO l_num_reserva,l_qtd_res
           UPDATE estoque_loc_reser SET qtd_reservada = qtd_reservada + l_qtd_res
               WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
                 AND num_reserva = l_num_reserva
        END FOREACH
     END IF    
   END IF    
 END FOREACH               

END FUNCTION  

#--------------------------------#
 FUNCTION pol0714_atualiza_ped()
#--------------------------------#
  DEFINE l_count  INTEGER
  
 IF p_ies_ftg = 'S' THEN  

   DECLARE cq_rom CURSOR FOR
     SELECT *
       FROM nf_item 
      WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
        AND num_nff     = p_wfat.num_nff 
        
   FOREACH cq_rom INTO p_nfit.*
      UPDATE ordem_montag_mest 
         SET ies_sit_om='N'
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
         AND num_om      = p_nfit.num_om
      IF p_ies_nf100 = 'S'  THEN 
         UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend - p_nfit.qtd_item
          WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial 
            AND num_pedido    = p_nfit.num_pedido
            AND cod_item      = p_nfit.cod_item
            AND num_sequencia = p_nfit.num_sequencia
      ELSE
         UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend - p_nfit.qtd_item,
                              qtd_pecas_romaneio = qtd_pecas_romaneio + p_nfit.qtd_item
          WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial 
            AND num_pedido    = p_nfit.num_pedido
            AND cod_item      = p_nfit.cod_item
            AND num_sequencia = p_nfit.num_sequencia
      END IF       
   END FOREACH  
ELSE
   DECLARE cq_pd0 CURSOR FOR
     SELECT *
       FROM nf_item 
      WHERE cod_empresa = p_cod_empresa
        AND num_nff     = p_wfat.num_nff 
        
   FOREACH cq_pd0 INTO p_nfit.*
      IF p_ies_nf100 = 'S'  THEN         
         UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend - p_nfit.qtd_item
          WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial 
            AND num_pedido    = p_nfit.num_pedido
            AND cod_item      = p_nfit.cod_item
            AND num_sequencia = p_nfit.num_sequencia
      ELSE
         UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend - p_nfit.qtd_item,
                              qtd_pecas_romaneio = qtd_pecas_romaneio + p_nfit.qtd_item
          WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial 
            AND num_pedido    = p_nfit.num_pedido
            AND cod_item      = p_nfit.cod_item
            AND num_sequencia = p_nfit.num_sequencia
      END IF    
   END FOREACH  
END IF    

END FUNCTION  

#-----------------------#
 FUNCTION pol0714_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION