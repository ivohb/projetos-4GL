#------------------------------------------------------------------------------#
# MODULOS.: POL0716 -                                                          #
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
	       p_nfit               RECORD LIKE nf_item.*,
	       p_estoque            RECORD LIKE estoque.*, 
	       p_nat_operacao       RECORD LIKE nat_operacao.*,
	       p_estvdp             RECORD LIKE estrutura_vdp.*,
	       p_estoque_operac     RECORD LIKE estoque_operac.*, 
	       p_estoque_trans      RECORD LIKE estoque_trans.*, 
	       p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
	       p_desc_nat_oper_885  RECORD LIKE desc_nat_oper_885.*,
	       p_estoque_obs        RECORD LIKE estoque_obs.*, 
	       p_empresas_885       RECORD LIKE empresas_885.*, 
	       p_wfat               RECORD LIKE nf_mestre.*,    
         p_cod_empresa        CHAR(02),
	       p_cancel             INTEGER,
	       p_num_nff_char       CHAR(06),                  
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
	       p_ies_est            CHAR(01),
	       p_nom_help           CHAR(200),
	       p_nom_tela           CHAR(080),
	       p_msg                CHAR(100)

END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT 
  LET p_versao = "POL0716-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0716.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL pol0716_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0716_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0716") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0716 AT 5,3  WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar"   "Informar parametros "
       HELP 0009
       MESSAGE ""
       LET p_num_nff_ini = 0
       DISPLAY "                                "  AT  9,5
       IF log005_seguranca(p_user,"VDP","pol0716","CO") THEN
	        IF pol0716_entrada_parametros() THEN
	           NEXT OPTION "Processar" 
	        END IF
       END IF
       
    COMMAND "Processar" "Processa cancelamento da Nota"
      HELP 001
      MESSAGE ""
      LET p_ies_situa  = 0
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","pol0716","IN") THEN
	       IF log004_confirm(16,30) THEN  
	         SELECT * INTO p_empresas_885.* 
	           FROM empresas_885 
	          WHERE cod_emp_oficial = p_cod_empresa
           IF SQLCA.sqlcode = 0 THEN 
	            IF pol0716_processa() THEN
	               ERROR "Cancelamento Efetuado com Sucesso"
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
	COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
      CALL pol0716_sobre()        
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
  CLOSE WINDOW w_pol0716
END FUNCTION

#-----------------------------------#
FUNCTION pol0716_entrada_parametros()
#-----------------------------------#
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0716

   INPUT p_num_nff_ini  WITHOUT DEFAULTS
    FROM num_nff_ini
      ON KEY (control-w)
	 CASE
	    WHEN infield(num_nff_ini)   CALL showhelp(3187)
	 END CASE
   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0716

   IF int_flag THEN
      LET int_flag = 0
      CLEAR FORM
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------#
 FUNCTION pol0716_processa()
#-----------------------------#
   LET p_ies_processou = TRUE
   LET p_hora = TIME
   LET p_ies_est = 'S'
   LET p_ies_situa = 1 

   SELECT *
     INTO p_wfat.*   
     FROM nf_mestre
    WHERE cod_empresa = p_cod_empresa
      AND num_nff = p_num_nff_ini 

   IF p_wfat.ies_situacao = 'C' THEN
      SELECT *
        INTO p_wfat.*   
        FROM nf_mestre
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
         AND num_nff = p_num_nff_ini 
      IF SQLCA.sqlcode = 0 THEN 
         IF p_wfat.ies_situacao <> 'C' THEN      
            LET p_count = 0 
            LET p_num_nff_char = p_wfat.num_nff
            
            CALL pol0716_devol_estoque() 
            
            CALL pol0716_cancela_nota() 
         END IF    
      END IF 
   END IF 
IF p_ies_situa = 1  THEN 
   RETURN TRUE  
ELSE
   ERROR "Dados nao encontrado na tabela WFAT_MESTRE"
   SLEEP 2
   RETURN FALSE
END IF
END FUNCTION  
   
#--------------------------------#
 FUNCTION pol0716_devol_estoque()
#--------------------------------#
 
 DECLARE cq_devol CURSOR FOR
    SELECT *
      FROM estoque_trans
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND num_docum = p_num_nff_char
       AND num_prog = 'POL0715'
       AND ies_tip_movto = "N"

 FOREACH cq_devol  INTO p_estoque_trans.*

   SELECT * 
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
      AND num_transac = p_estoque_trans.num_transac  
  
   UPDATE estoque SET qtd_liberada = qtd_liberada + p_estoque_trans.qtd_movto
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
      AND cod_item    = p_estoque_trans.cod_item

   LET p_count = 0
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
                                       p_estoque_trans.qtd_movto,
                                       0)
   END IF

   LET p_count = 0
   SELECT count(*) 
     INTO p_count 
     FROM estoque_lote_ender    
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
      AND cod_item    = p_estoque_trans.cod_item
      AND cod_local   = p_estoque_trans.cod_local_est_orig
      AND num_lote    = p_estoque_trans.num_lote_orig
      AND ies_situa_qtd = 'L'
      AND largura     =   p_estoque_trans_end.largura
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
     INSERT INTO estoque_lote_ender VALUES (p_empresas_885.cod_emp_gerencial,
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
                                            0,
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
   
   LET p_estoque_trans.cod_empresa   = p_empresas_885.cod_emp_gerencial 
   LET p_estoque_trans.dat_movto     = TODAY
   LET p_estoque_trans.dat_proces    = TODAY
   LET p_estoque_trans.hor_operac    = TIME 
   LET p_estoque_trans.num_transac   =  0
   LET p_estoque_trans.ies_tip_movto = 'R'
   LET p_estoque_trans.num_prog      = 'POL0716' 

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

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)
  
 END FOREACH

END FUNCTION  

#--------------------------------#
 FUNCTION pol0716_cancela_nota()
#--------------------------------#
 DEFINE l_ies_ped  CHAR(01)

   UPDATE nf_mestre SET ies_situacao = 'C'
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
      AND num_nff     = p_wfat.num_nff 
      
   INSERT INTO nf_movto_dupl VALUES (p_empresas_885.cod_emp_gerencial ,
                                     p_wfat.num_nff,
                                     TODAY,
                                     'C',
                                     0)    

   INITIALIZE l_ies_ped TO NULL 

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

      IF l_ies_ped IS NULL THEN 
         SELECT * 
           INTO p_desc_nat_oper_885.*
           FROM desc_nat_oper_885
          WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial 
            AND num_pedido  =  p_nfit.num_pedido
         IF p_desc_nat_oper_885.pct_desc_qtd > 0 THEN 
            LET l_ies_ped = 'S'
         ELSE   
            LET l_ies_ped = 'N'
         END IF    
      END IF  
            
      IF l_ies_ped = 'S' THEN    
         UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend - p_nfit.qtd_item
          WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial 
            AND num_pedido    = p_nfit.num_pedido
            AND cod_item      = p_nfit.cod_item
            AND num_sequencia = p_nfit.num_sequencia
      END IF    
   END FOREACH  

END FUNCTION  

#-----------------------#
 FUNCTION pol0716_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION