#------------------------------------------------------------------------------#
# PROGRAMA: pol0715 - BASE PEDIDO OU CLIENTE                                   #
# OBJETIVO: BAIXAR ESTOQUES P. ACABADOS                                        #
#------------------------------------------------------------------------------#
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
         p_data                DATE,
         p_hora                CHAR(05),
         p_versao              CHAR(18),               
         p_wfatn               RECORD LIKE wfat_item.*,
         p_wfati1              RECORD LIKE wfat_item.*,
         p_estoque             RECORD LIKE estoque.*, 
         p_om_grade            RECORD LIKE ordem_montag_grade.*,
         p_est_loc_res         RECORD LIKE estoque_loc_reser.*,
         p_est_loc_res_end     RECORD LIKE est_loc_reser_end.*,
         p_cod_local_estoq     LIKE item.cod_local_estoq,
         p_nat_operacao        RECORD LIKE nat_operacao.*,
         p_estvdp              RECORD LIKE estrutura_vdp.*,
         p_estoque_operac      RECORD LIKE estoque_operac.*, 
         p_estoque_trans       RECORD LIKE estoque_trans.*, 
         p_estoque_trans_end   RECORD LIKE estoque_trans_end.*,
         p_estoque_obs         RECORD LIKE estoque_obs.*, 
         p_desc_nat_oper_885   RECORD LIKE desc_nat_oper_885.*,
         p_empresas_885        RECORD LIKE empresas_885.* 

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
  LET p_versao = "POL0715-05.10.05"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0715.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

    CALL log001_acessa_usuario("VDP","LIC_LIB")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL pol0715_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0715_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0715") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol07150 AT 7,13 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Processar" "Processa baixa de estoque"
      HELP 001
      MESSAGE ""
      LET p_ies_situa  = 0
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","pol0715","IN") THEN
         SELECT * INTO p_empresas_885.* 
           FROM empresas_885 
          WHERE cod_emp_oficial = p_cod_empresa   
         IF SQLCA.sqlcode <> 0 THEN 
            LET p_ies_processou = TRUE
            ERROR "Processamento Efetuado com Sucesso"
            NEXT OPTION "Fim"
         ELSE    
            IF pol0715_processa() THEN
               ERROR "Processamento Efetuado com Sucesso"
               NEXT OPTION "Fim"
            ELSE
               ERROR "Processamento Cancelado"
            END IF
         END IF    
      END IF
      
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
  CLOSE WINDOW w_pol07150
END FUNCTION

#-----------------------------#
 FUNCTION pol0715_processa()
#-----------------------------#
LET p_ies_processou = TRUE
LET p_hora = TIME
DECLARE cq_nota CURSOR FOR 
   SELECT *  
     FROM wfat_mestre
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      AND ies_impr_nff = 'N'     
FOREACH cq_nota INTO p_wfat.* 
  
   LET p_ies_situa = 1 
   LET p_baixa_est = "S"

   DISPLAY " Nota : "  AT  7,5
   DISPLAY p_wfat.num_nff AT 7,12

   SELECT * INTO p_nat_operacao.*
     FROM nat_operacao 
    WHERE cod_nat_oper   = p_wfat.cod_nat_oper 

   SELECT * INTO p_estoque_operac.*
     FROM estoque_operac
    WHERE cod_operacao = p_nat_operacao.cod_movto_estoq
      AND cod_empresa  = p_empresas_885.cod_emp_oficial   

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
      AND ies_tip_movto = "N"
      AND num_prog = "POL0715"
   IF p_count > 0  THEN
      CONTINUE FOREACH
   END IF

   SELECT MAX(num_pedido)
     INTO p_num_pedido
     FROM wfat_item
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      AND num_nff     = p_wfat.num_nff
      
   SELECT * 
     INTO p_desc_nat_oper_885.*
     FROM desc_nat_oper_885
    WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial 
      AND num_pedido  =  p_num_pedido
   IF p_desc_nat_oper_885.pct_desc_valor > 0 THEN 
      CONTINUE FOREACH
   END IF    

   DECLARE cq_consulta CURSOR FOR
    SELECT * FROM wfat_item
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND num_nff     = p_wfat.num_nff
   FOREACH cq_consulta INTO p_wfatn.*  
 
    CALL pol0715_baixa_estoque()
   
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
 FUNCTION pol0715_baixa_estoque()
#-------------------------------#
DEFINE l_cod_lin_prod  LIKE item.cod_lin_prod, 
       l_cod_lin_recei LIKE item.cod_lin_recei,
       l_cod_seg_merc  LIKE item.cod_seg_merc, 
       l_cod_cla_uso   LIKE item.cod_cla_uso,
       l_num_tran_at   INTEGER,
       l_qtd_reserv    LIKE estoque_trans.qtd_movto,
       l_count         INTEGER,
       l_qtd_saldo     LIKE estoque_trans.qtd_movto

  LET  p_estoque_trans.cod_empresa   = p_empresas_885.cod_emp_gerencial 
  LET  p_estoque_trans.dat_movto     = TODAY
  LET  p_estoque_trans.dat_proces    = TODAY
  LET  p_estoque_trans.hor_operac    = TIME

  LET p_estoque_trans.ies_tip_movto = "N"
         
  SELECT num_conta_debito 
    INTO p_estoque_trans.num_conta
    FROM estoque_operac_ct      
   WHERE cod_empresa = p_empresas_885.cod_emp_oficial
     AND cod_operacao =  p_nat_operacao.cod_movto_estoq   
      
  IF SQLCA.sqlcode <> 0 THEN 
     SELECT cod_lin_prod, 
            cod_lin_recei,
            cod_seg_merc, 
            cod_cla_uso
       INTO l_cod_lin_prod, 
            l_cod_lin_recei,
            l_cod_seg_merc, 
            l_cod_cla_uso   
       FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = p_wfatn.cod_item       
  
     SELECT num_conta_est_nac
       INTO p_estoque_trans.num_conta
       FROM linha_prod
      WHERE cod_lin_prod  = l_cod_lin_prod 
        AND cod_lin_recei = l_cod_lin_recei
        AND cod_seg_merc  = l_cod_seg_merc 
        AND cod_cla_uso   = l_cod_cla_uso  
     IF SQLCA.sqlcode <> 0 THEN 
        SELECT num_conta_est_nac
          INTO p_estoque_trans.num_conta
          FROM linha_prod
         WHERE cod_lin_prod  = l_cod_lin_prod 
           AND cod_lin_recei = l_cod_lin_recei
           AND cod_seg_merc  = l_cod_seg_merc 
        IF SQLCA.sqlcode <> 0 THEN  
           SELECT num_conta_est_nac
             INTO p_estoque_trans.num_conta
             FROM linha_prod
            WHERE cod_lin_prod  = l_cod_lin_prod 
              AND cod_lin_recei = l_cod_lin_recei
           IF SQLCA.sqlcode <> 0 THEN  
              SELECT num_conta_est_nac
                INTO p_estoque_trans.num_conta
                FROM linha_prod
               WHERE cod_lin_prod  = l_cod_lin_prod 
           ELSE
              INITIALIZE  p_estoque_trans.num_conta  TO  NULL
           END IF    
        END IF    
     END IF 
  END IF 
     
  LET  p_estoque_trans.cod_operacao       =  p_nat_operacao.cod_movto_estoq
  LET  p_estoque_trans.cod_item           =  p_wfatn.cod_item
  LET  p_estoque_trans.num_transac        =  "0"
  LET  p_estoque_trans.num_prog           =  "POL0715"
  LET  p_estoque_trans.num_docum          =  p_wfatn.num_nff
  LET  p_estoque_trans.num_seq            =  p_wfatn.num_sequencia
  LET  p_estoque_trans.cus_unit_movto_p   =  0
  LET  p_estoque_trans.cus_tot_movto_p    =  0
  LET  p_estoque_trans.cus_unit_movto_f   =  0
  LET  p_estoque_trans.cus_tot_movto_f    =  0
  LET  p_estoque_trans.num_secao_requis   =  NULL
  LET  p_estoque_trans.cod_local_est_dest =  NULL
  LET  p_estoque_trans.num_lote_dest      =  NULL
  LET  p_estoque_trans.ies_sit_est_dest   =  " "
  LET  p_estoque_trans.cod_turno          =  NULL
  LET  p_estoque_trans.nom_usuario        =  p_user
  LET  p_estoque_trans.ies_sit_est_orig   =  "L"
  LET  p_estoque_trans.cod_local_est_dest =  NULL
  LET  p_estoque_trans.dat_ref_moeda_fort =  "31/12/1899"
 
  DECLARE cq_grade  CURSOR FOR
   SELECT *
     FROM ordem_montag_grade
    WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial 
      AND num_om        = p_wfatn.num_om
      AND num_pedido    = p_wfatn.num_pedido
      AND num_sequencia = p_wfatn.num_sequencia
      AND cod_item      = p_wfatn.cod_item
   FOREACH cq_grade INTO p_om_grade.*
     SELECT *
       INTO p_est_loc_res.*
       FROM estoque_loc_reser
      WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
        AND num_reserva = p_om_grade.num_reserva

     LET p_estoque_trans.num_lote_orig       =  p_est_loc_res.num_lote
     LET p_estoque_trans.qtd_movto           =  p_est_loc_res.qtd_reservada
     LET p_estoque_trans.cod_local_est_orig  =  p_est_loc_res.cod_local

     SELECT qtd_reservada 
       INTO l_qtd_reserv
       FROM estoque 
      WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
        AND cod_item    =   p_wfatn.cod_item
     
     LET l_count = 0 
     
     SELECT COUNT(*)
       INTO l_count
       FROM estoque_lote
      WHERE cod_empresa   =   p_empresas_885.cod_emp_gerencial
        AND cod_item      =   p_wfatn.cod_item
        AND cod_local     =   p_est_loc_res.cod_local
        AND num_lote      =   p_est_loc_res.num_lote
        AND ies_situa_qtd = "E"

     IF l_count > 0 THEN
        IF l_qtd_reserv >  p_est_loc_res.qtd_reservada THEN   
           UPDATE estoque SET qtd_lib_excep = qtd_lib_excep - p_est_loc_res.qtd_reservada
            WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
              AND cod_item    =   p_wfatn.cod_item
        ELSE
           UPDATE estoque SET qtd_lib_excep = qtd_lib_excep - p_est_loc_res.qtd_reservada
            WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
              AND cod_item    =   p_wfatn.cod_item
        END IF 

        UPDATE estoque_lote SET qtd_saldo = qtd_saldo - p_est_loc_res.qtd_reservada
         WHERE cod_empresa   =   p_empresas_885.cod_emp_gerencial
           AND cod_item      =   p_wfatn.cod_item
           AND cod_local     =   p_est_loc_res.cod_local
           AND num_lote      =   p_est_loc_res.num_lote
           AND ies_situa_qtd = "E"
     ELSE
        IF l_qtd_reserv >  p_est_loc_res.qtd_reservada THEN   
           UPDATE estoque SET qtd_liberada  = qtd_liberada  - p_est_loc_res.qtd_reservada
            WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
              AND cod_item    =   p_wfatn.cod_item
        ELSE
           UPDATE estoque SET qtd_liberada  = qtd_liberada  - p_est_loc_res.qtd_reservada
            WHERE cod_empresa =   p_empresas_885.cod_emp_gerencial
              AND cod_item    =   p_wfatn.cod_item
        END IF 

        UPDATE estoque_lote SET qtd_saldo = qtd_saldo - p_est_loc_res.qtd_reservada
         WHERE cod_empresa   =   p_empresas_885.cod_emp_gerencial
           AND cod_item      =   p_wfatn.cod_item
           AND cod_local     =   p_est_loc_res.cod_local
           AND num_lote      =   p_est_loc_res.num_lote
           AND ies_situa_qtd = "L"
     END IF 

     SELECT (qtd_reservada - qtd_atendida)
       INTO l_qtd_saldo
       FROM estoque_loc_reser 
      WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
        AND num_reserva = p_om_grade.num_reserva
     IF l_qtd_saldo <= p_wfatn.qtd_item     THEN
        UPDATE estoque_loc_reser SET qtd_reservada = 0
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
           AND num_reserva = p_om_grade.num_reserva
     ELSE
        UPDATE estoque_loc_reser SET qtd_reservada = qtd_reservada - p_wfatn.qtd_item    
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
           AND num_reserva = p_om_grade.num_reserva
     END IF      

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
       INTO p_est_loc_res_end.*
       FROM est_loc_reser_end
      WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial    
        AND num_reserva =  p_est_loc_res.num_reserva
 
     IF l_count > 0 THEN 
        UPDATE estoque_lote_ender SET qtd_saldo = qtd_saldo - p_est_loc_res.qtd_reservada
         WHERE cod_empresa   =   p_empresas_885.cod_emp_gerencial 
           AND cod_item      =   p_wfatn.cod_item
           AND cod_local     =   p_est_loc_res.cod_local
           AND num_lote      =   p_est_loc_res.num_lote
           AND largura       =   p_est_loc_res_end.largura
           AND altura        =   p_est_loc_res_end.altura   
           AND diametro      =   p_est_loc_res_end.diametro 
           AND ies_situa_qtd = "E"
     ELSE
        UPDATE estoque_lote_ender SET qtd_saldo = qtd_saldo - p_est_loc_res.qtd_reservada
         WHERE cod_empresa   =   p_empresas_885.cod_emp_gerencial 
           AND cod_item      =   p_wfatn.cod_item
           AND cod_local     =   p_est_loc_res.cod_local
           AND num_lote      =   p_est_loc_res.num_lote
           AND largura       =   p_est_loc_res_end.largura
           AND altura        =   p_est_loc_res_end.altura   
           AND diametro      =   p_est_loc_res_end.diametro 
           AND ies_situa_qtd = "L"
     END IF 
    
     LET p_estoque_trans_end.cod_empresa          =  p_empresas_885.cod_emp_gerencial
     LET p_estoque_trans_end.num_transac          =  l_num_tran_at 
     LET p_estoque_trans_end.endereco             =  p_est_loc_res_end.endereco
     LET p_estoque_trans_end.num_volume           =  p_est_loc_res_end.num_volume     
     LET p_estoque_trans_end.qtd_movto            =  p_est_loc_res.qtd_reservada     
     LET p_estoque_trans_end.cod_grade_1          =  p_est_loc_res_end.cod_grade_1     
     LET p_estoque_trans_end.cod_grade_2          =  p_est_loc_res_end.cod_grade_2          
     LET p_estoque_trans_end.cod_grade_3          =  p_est_loc_res_end.cod_grade_3          
     LET p_estoque_trans_end.cod_grade_4          =  p_est_loc_res_end.cod_grade_4          
     LET p_estoque_trans_end.cod_grade_5          =  p_est_loc_res_end.cod_grade_5          
     LET p_estoque_trans_end.dat_hor_prod_ini     =  p_est_loc_res_end.dat_hor_producao     
     LET p_estoque_trans_end.dat_hor_prod_fim     =  p_est_loc_res_end.dat_hor_producao     
     LET p_estoque_trans_end.vlr_temperatura      =  0      
     LET p_estoque_trans_end.endereco_origem      =  0      
     LET p_estoque_trans_end.num_ped_ven          =  p_est_loc_res_end.num_ped_ven         
     LET p_estoque_trans_end.num_seq_ped_ven      =  p_est_loc_res_end.num_seq_ped_ven 
     LET p_estoque_trans_end.dat_hor_producao     =  p_est_loc_res_end.dat_hor_producao     
     LET p_estoque_trans_end.dat_hor_validade     =  p_est_loc_res_end.dat_hor_validade     
     LET p_estoque_trans_end.num_peca             =  p_est_loc_res_end.num_peca             
     LET p_estoque_trans_end.num_serie            =  p_est_loc_res_end.num_serie            
     LET p_estoque_trans_end.comprimento          =  p_est_loc_res_end.comprimento          
     LET p_estoque_trans_end.largura              =  p_est_loc_res_end.largura              
     LET p_estoque_trans_end.altura               =  p_est_loc_res_end.altura               
     LET p_estoque_trans_end.diametro             =  p_est_loc_res_end.diametro             
     LET p_estoque_trans_end.dat_hor_reserv_1     =  p_est_loc_res_end.dat_hor_reserv_1     
     LET p_estoque_trans_end.dat_hor_reserv_2     =  p_est_loc_res_end.dat_hor_reserv_2     
     LET p_estoque_trans_end.dat_hor_reserv_3     =  p_est_loc_res_end.dat_hor_reserv_3     
     LET p_estoque_trans_end.qtd_reserv_1         =  p_est_loc_res_end.qtd_reserv_1         
     LET p_estoque_trans_end.qtd_reserv_2         =  p_est_loc_res_end.qtd_reserv_2         
     LET p_estoque_trans_end.qtd_reserv_3         =  p_est_loc_res_end.qtd_reserv_3         
     LET p_estoque_trans_end.num_reserv_1         =  p_est_loc_res_end.num_reserv_1         
     LET p_estoque_trans_end.num_reserv_2         =  p_est_loc_res_end.num_reserv_2         
     LET p_estoque_trans_end.num_reserv_3         =  p_est_loc_res_end.num_reserv_3         
     LET p_estoque_trans_end.tex_reservado        =  p_est_loc_res_end.tex_reservado        
     LET p_estoque_trans_end.cus_unit_movto_p     =  0
     LET p_estoque_trans_end.cus_unit_movto_f     =  0
     LET p_estoque_trans_end.cus_tot_movto_p      =  0
     LET p_estoque_trans_end.cus_tot_movto_f      =  0
     LET p_estoque_trans_end.cod_item             =  p_wfatn.cod_item
     LET p_estoque_trans_end.dat_movto            =  TODAY
     LET p_estoque_trans_end.cod_operacao         =  p_nat_operacao.cod_movto_estoq
     LET p_estoque_trans_end.ies_tip_movto        =  'N'
     LET p_estoque_trans_end.num_prog             =  'POL0715'
     
     INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)     

     DELETE FROM estoque_lote 
      WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      AND   qtd_saldo   = 0 

     DELETE FROM estoque_lote_ender 
      WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      AND   qtd_saldo   = 0 
        
   END FOREACH                                                       
END FUNCTION 