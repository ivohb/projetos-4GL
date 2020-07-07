#----------------------------------------------------#
# PROGRAMA: pol0713 - BASE PEDIDO OU CLIENTE         #
# OBJETIVO: BAIXAR ESTOQUES P. ACABADOS              #
#----------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE 
         p_cod_empresa         CHAR(02),
         p_cancel              INTEGER,
         p_num_nf              LIKE wfat_item.num_nff,
         p_qtd_item            LIKE wfat_item.qtd_item,
         p_qtd_res_at          LIKE estoque.qtd_reservada,
         p_cod_nat_oper        LIKE nat_operacao.cod_nat_oper,
         p_qtd_pecas_romaneio  LIKE ped_itens.qtd_pecas_romaneio,
         p_num_pedido          LIKE pedidos.num_pedido,
         p_num_nff_char        CHAR(06),                 
         p_ies_processou       SMALLINT,
         comando               CHAR(80),
         p_ind                 SMALLINT,
         p_count               SMALLINT,
         p_resposta            CHAR(1),
         p_baixa_est           CHAR(1),
         p_ies_romaneio        CHAR(1),
         p_data                DATE,
         p_hora                CHAR(05),
         p_versao              CHAR(18),               
         p_wfatn               RECORD LIKE wfat_item.*,
         p_fat_item_grd_consg  RECORD LIKE fat_item_grd_consg.*,
         p_sup_itterc_grade    RECORD LIKE sup_itterc_grade.*,
         p_item_em_terc        RECORD LIKE item_em_terc.*,
         p_wfati1              RECORD LIKE wfat_item.*,
         p_estoque             RECORD LIKE estoque.*, 
         p_om_grade            RECORD LIKE ordem_montag_grade.*,
         p_est_loc_res         RECORD LIKE estoque_loc_reser.*,                                 
         p_cod_local_estoq     LIKE item.cod_local_estoq,
         p_nat_operacao        RECORD LIKE nat_operacao.*,
         p_estvdp              RECORD LIKE estrutura_vdp.*,
         p_estoque_operac      RECORD LIKE estoque_operac.*, 
         p_estoque_trans       RECORD LIKE estoque_trans.*, 
         p_estoque_trans_end   RECORD LIKE estoque_trans_end.*,
         p_estoque_obs         RECORD LIKE estoque_obs.*, 
         p_desc_nat_oper_885   RECORD LIKE desc_nat_oper_885.*,
         p_empresas_885        RECORD LIKE empresas_885.*,
         p_msg                 CHAR(100) 

 DEFINE p_user            LIKE usuario.nom_usuario,
        p_status          SMALLINT,
        p_ies_situa       SMALLINT,
        p_nom_help        CHAR(200),
        p_nom_tela        CHAR(080),
        p_wfat            RECORD LIKE wfat_mestre.*    
END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT 
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0713-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0713.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

    CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL pol0713_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0713_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0713") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol07130 AT 7,13 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Processar" "Processa baixa de estoque"
      HELP 001
      MESSAGE ""
      LET p_ies_situa  = 0
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","pol0713","IN") THEN
         SELECT * INTO p_empresas_885.* 
           FROM empresas_885 
          WHERE cod_emp_oficial = p_cod_empresa   
         IF SQLCA.sqlcode <> 0 THEN 
            LET p_ies_processou = TRUE
            ERROR "Processamento Efetuado com Sucesso"
            NEXT OPTION "Fim"
         ELSE    
            IF pol0713_processa() THEN
               ERROR "Processamento Efetuado com Sucesso"
               NEXT OPTION "Fim"
            ELSE
               ERROR "Processamento Cancelado"
            END IF
         END IF    
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
      CALL pol0713_sobre()
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
  CLOSE WINDOW w_pol07130
END FUNCTION

#-----------------------------#
 FUNCTION pol0713_processa()
#-----------------------------#
LET p_ies_processou = TRUE
LET p_hora = TIME
DECLARE cq_nota CURSOR FOR 
   SELECT *  
     FROM wfat_mestre
    WHERE cod_empresa = p_cod_empresa
      AND ies_impr_nff = 'N'     
FOREACH cq_nota INTO p_wfat.* 
  
   LET p_ies_situa = 1 
   LET p_baixa_est = "S"

   DISPLAY " Nota : "  AT  7,5
   DISPLAY p_wfat.num_nff AT 7,12

   SELECT * INTO p_nat_operacao.*
     FROM nat_operacao 
    WHERE cod_nat_oper   = p_wfat.cod_nat_oper 
  
   IF p_nat_operacao.ies_tip_controle <> '1' THEN 
      SELECT * INTO p_estoque_operac.*
        FROM estoque_operac
       WHERE cod_operacao = p_nat_operacao.cod_movto_estoq
         AND cod_empresa  = p_empresas_885.cod_emp_oficial   
      
      IF sqlca.sqlcode = 100 OR                    
         p_estoque_operac.ies_tipo <> "S" THEN 
         CONTINUE FOREACH 
      END IF
   END IF 
   
   LET p_count = 0 
   LET p_num_nff_char = p_wfat.num_nff

   SELECT count(*) INTO p_count
     FROM estoque_trans
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
      AND cod_operacao = p_nat_operacao.cod_movto_estoq
      AND num_docum = p_num_nff_char
      AND ies_tip_movto = "N"
      AND num_prog = "POL0713"
   IF p_count > 0  THEN
      CONTINUE FOREACH
   END IF

   LET p_ies_romaneio = "S"

   DECLARE cq_bxe CURSOR FOR
    SELECT UNIQUE cod_empresa,cod_item  FROM wfat_item
     WHERE cod_empresa = p_cod_empresa
       AND num_nff     = p_wfat.num_nff
   FOREACH cq_bxe INTO p_wfatn.cod_empresa,p_wfatn.cod_item
 
    CALL pol0713_baixa_estoque()
    
    SELECT MAX(num_pedido)
      INTO p_wfatn.num_pedido 
      FROM nf_item 
     WHERE cod_empresa = p_cod_empresa
       AND num_nff     = p_wfat.num_nff
       AND cod_item    = p_wfatn.cod_item
           
    SELECT *
      INTO p_desc_nat_oper_885.*
      FROM desc_nat_oper_885
     WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
       AND num_pedido  =  p_wfatn.num_pedido
       
    IF  p_desc_nat_oper_885.pct_desc_valor = 0 AND 
        p_desc_nat_oper_885.pct_desc_qtd   = 0 THEN 
        LET p_ies_romaneio = "N"
    END IF     
    
   END FOREACH
   
   DECLARE cq_bxres CURSOR FOR
    SELECT UNIQUE *  FROM wfat_item
     WHERE cod_empresa = p_cod_empresa
       AND num_nff     = p_wfat.num_nff
   FOREACH cq_bxres INTO p_wfatn.*
 
    CALL pol0713_baixa_reserva()
    CALL pol0713_baixa_pedido()
   
   END FOREACH
   
END FOREACH
IF p_ies_situa = 1  THEN 
   RETURN TRUE  
ELSE
   ERROR "Dados nao encontrado na tabela WFAT_MESTRE"
   SLEEP 2
   RETURN FALSE
END IF
END FUNCTION  

#-------------------------------#
 FUNCTION pol0713_baixa_estoque()
#-------------------------------#
 DEFINE l_num_transac LIKE estoque_trans_end.num_transac,
        l_num_tran_at LIKE estoque_trans_end.num_transac,
        l_qtd_reser   LIKE estoque_trans.qtd_movto,
        l_qtd_saldo   LIKE estoque_trans.qtd_movto,  
        l_num_res     INTEGER,
        l_count       INTEGER

 IF p_nat_operacao.ies_tip_controle <> '1' THEN 
    DECLARE cq_grade  CURSOR FOR
     SELECT *
       FROM estoque_trans
      WHERE cod_empresa = p_cod_empresa
        AND num_docum   = p_num_nff_char
        AND cod_item    = p_wfatn.cod_item 
        AND num_prog LIKE 'VDP%'
##        AND cod_operacao = 'VEND'
    
    FOREACH cq_grade INTO p_estoque_trans.*
       LET l_num_transac = p_estoque_trans.num_transac
       LET p_estoque_trans.cod_empresa  = p_empresas_885.cod_emp_gerencial
       LET p_estoque_trans.num_prog = 'POL0713'
       
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
    
       LET l_num_tran_at =  SQLCA.SQLERRD[2]
        
       SELECT * 
         INTO p_estoque_trans_end.*
         FROM estoque_trans_end
        WHERE cod_empresa = p_cod_empresa
          AND num_transac = l_num_transac
        
       LET p_estoque_trans_end.cod_empresa = p_empresas_885.cod_emp_gerencial
       LET p_estoque_trans_end.num_transac = l_num_tran_at 
       
       INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)     

       SELECT qtd_reservada 
         INTO l_qtd_reser 
         FROM estoque 
        WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
          AND cod_item    =   p_estoque_trans.cod_item

       LET l_count = 0

       SELECT COUNT(*) 
         INTO l_count
         FROM estoque_lote
        WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
          AND cod_item    =   p_estoque_trans.cod_item
          AND cod_local   =   p_estoque_trans.cod_local_est_orig
          AND num_lote    =   p_estoque_trans.num_lote_orig
          AND ies_situa_qtd = "E"
          
       IF l_count > 0 THEN 
          IF l_qtd_reser < p_estoque_trans.qtd_movto THEN 
             UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep - p_estoque_trans.qtd_movto,
                                 qtd_reservada = 0
                 WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
                   AND cod_item    =   p_estoque_trans.cod_item
          ELSE
             UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep - p_estoque_trans.qtd_movto,
                                 qtd_reservada = qtd_reservada - p_estoque_trans.qtd_movto
                    WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
                      AND cod_item    =   p_estoque_trans.cod_item
          END IF 

          UPDATE estoque_lote SET qtd_saldo = qtd_saldo - p_estoque_trans.qtd_movto
           WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
             AND cod_item    =   p_estoque_trans.cod_item
             AND cod_local   =   p_estoque_trans.cod_local_est_orig
             AND num_lote    =   p_estoque_trans.num_lote_orig
             AND ies_situa_qtd = "E"
    
          UPDATE estoque_lote_ender SET qtd_saldo = qtd_saldo - p_estoque_trans.qtd_movto
           WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
             AND cod_item    =   p_estoque_trans.cod_item
             AND cod_local   =   p_estoque_trans.cod_local_est_orig
             AND num_lote    =   p_estoque_trans.num_lote_orig
             AND ies_situa_qtd = "E"
             AND largura     =   p_estoque_trans_end.largura
             AND altura      =   p_estoque_trans_end.altura   
             AND diametro    =   p_estoque_trans_end.diametro 
       ELSE  
          IF l_qtd_reser < p_estoque_trans.qtd_movto THEN 
             UPDATE estoque SET  qtd_liberada = qtd_liberada - p_estoque_trans.qtd_movto,
                                 qtd_reservada = 0
                 WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
                   AND cod_item    =   p_estoque_trans.cod_item
          ELSE
             UPDATE estoque SET  qtd_liberada = qtd_liberada - p_estoque_trans.qtd_movto,
                                 qtd_reservada = qtd_reservada - p_estoque_trans.qtd_movto
                    WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
                      AND cod_item    =   p_estoque_trans.cod_item
          END IF 

          UPDATE estoque_lote SET qtd_saldo = qtd_saldo - p_estoque_trans.qtd_movto
           WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
             AND cod_item    =   p_estoque_trans.cod_item
             AND cod_local   =   p_estoque_trans.cod_local_est_orig
             AND num_lote    =   p_estoque_trans.num_lote_orig
             AND ies_situa_qtd = "L"
    
          UPDATE estoque_lote_ender SET qtd_saldo = qtd_saldo - p_estoque_trans.qtd_movto
           WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
             AND cod_item    =   p_estoque_trans.cod_item
             AND cod_local   =   p_estoque_trans.cod_local_est_orig
             AND num_lote    =   p_estoque_trans.num_lote_orig
             AND ies_situa_qtd = "L"
             AND largura     =   p_estoque_trans_end.largura
             AND altura      =   p_estoque_trans_end.altura   
             AND diametro    =   p_estoque_trans_end.diametro 
       END IF 
       
       DELETE FROM estoque_lote 
        WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
          AND qtd_saldo   = 0
    
       DELETE FROM estoque_lote_ender 
        WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
          AND qtd_saldo   = 0  
       
    END FOREACH          
 END IF        
                                                       
END FUNCTION

#-------------------------------#
 FUNCTION pol0713_baixa_reserva()
#-------------------------------#
 DEFINE l_num_transac LIKE estoque_trans_end.num_transac,
        l_num_tran_at LIKE estoque_trans_end.num_transac,
        l_qtd_reser   LIKE estoque_trans.qtd_movto,
        l_qtd_saldo   LIKE estoque_trans.qtd_movto,  
        l_num_res     INTEGER

 IF p_nat_operacao.ies_tip_controle <> '1' THEN 
    IF p_desc_nat_oper_885.pct_desc_valor > 0 THEN 
       DECLARE cq_gd CURSOR FOR
        SELECT num_reserva 
          FROM ordem_montag_grade
         WHERE cod_empresa   =  p_empresas_885.cod_emp_gerencial
           AND num_om        =  p_wfatn.num_om   
           AND num_pedido    =  p_wfatn.num_pedido
           AND num_sequencia =  p_wfatn.num_sequencia
       FOREACH cq_gd INTO l_num_res 
         SELECT (qtd_reservada - qtd_atendida)
           INTO l_qtd_saldo
           FROM estoque_loc_reser 
          WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
            AND num_reserva = l_num_res
         IF l_qtd_saldo <= p_wfatn.qtd_item     THEN
            UPDATE estoque_loc_reser SET qtd_reservada = 0
             WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
               AND num_reserva = l_num_res
         ELSE
            UPDATE estoque_loc_reser SET qtd_reservada = qtd_reservada - p_wfatn.qtd_item    
             WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
               AND num_reserva = l_num_res
         END IF      
       END FOREACH     
    END IF    
 ELSE
    DECLARE cq_itt  CURSOR FOR
     SELECT *
       FROM item_em_terc 
      WHERE cod_empresa   = p_cod_empresa
        AND num_nf        = p_wfatn.num_nff
        AND cod_item      = p_wfatn.cod_item 
        AND num_sequencia = p_wfatn.num_sequencia
    
    FOREACH cq_itt INTO p_item_em_terc.*
      LET p_item_em_terc.cod_empresa  = p_empresas_885.cod_emp_gerencial
      INSERT INTO item_em_terc VALUES  (p_item_em_terc.*)
    END FOREACH   

    DECLARE cq_ittl  CURSOR FOR
     SELECT fat.*,sup.* 
       FROM fat_item_grd_consg fat,  sup_itterc_grade sup  
      WHERE fat.empresa         = p_cod_empresa
        AND fat.nota_fiscal     = p_wfatn.num_nff
        AND fat.sequencia_item  = p_wfatn.num_sequencia
        AND fat.item            = p_wfatn.cod_item 
        AND sup.empresa         = fat.empresa  
        AND sup.nota_fiscal     = fat.nota_fiscal  
        AND sup.seq_item_nf     = fat.sequencia_item  
        AND sup.fornecedor      = fat.fornecedor  
        AND sup.seq_tabulacao   = fat.seq_tabulacao

    FOREACH cq_ittl INTO p_fat_item_grd_consg.*,p_sup_itterc_grade.*
      LET p_fat_item_grd_consg.empresa  = p_empresas_885.cod_emp_gerencial
      INSERT INTO fat_item_grd_consg VALUES  (p_fat_item_grd_consg.*)
      
      LET p_sup_itterc_grade.empresa  = p_empresas_885.cod_emp_gerencial
      INSERT INTO sup_itterc_grade VALUES  (p_sup_itterc_grade.*)
    END FOREACH   
 END IF        
                                                       
END FUNCTION

#-----------------------------#
 FUNCTION pol0713_baixa_pedido()
#-----------------------------#

 IF p_nat_operacao.ies_baixa_pedido = "S" THEN
    IF p_ies_romaneio = "S" THEN 
       UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend + p_wfatn.qtd_item,
                            qtd_pecas_romaneio = qtd_pecas_romaneio - p_wfatn.qtd_item 
        WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
          AND num_pedido    = p_wfatn.num_pedido
          AND cod_item      = p_wfatn.cod_item
          AND num_sequencia = p_wfatn.num_sequencia
    ELSE
       UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend + p_wfatn.qtd_item
        WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
          AND num_pedido    = p_wfatn.num_pedido
          AND cod_item      = p_wfatn.cod_item
          AND num_sequencia = p_wfatn.num_sequencia
    END IF       
 END IF


END FUNCTION

#-----------------------#
 FUNCTION pol0713_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION