##----------------------------------------------------------##
##  POL0800 - ENTRADA ESTOQUE DE SUCATAS                    ##
##----------------------------------------------------------##
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_num_tran_at       INTEGER,
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT,
         p_cod_emp2          CHAR(02),
         l_count             SMALLINT
          
  DEFINE p_estoque           RECORD LIKE estoque.*, 
         p_estoque_trans     RECORD LIKE estoque_trans.*, 
         p_item              RECORD LIKE item.*
         
  DEFINE l_cod_lin_prod  LIKE item.cod_lin_prod, 
         l_cod_lin_recei LIKE item.cod_lin_recei,
         l_cod_seg_merc  LIKE item.cod_seg_merc, 
         l_cod_cla_uso   LIKE item.cod_cla_uso,
         l_num_tran_at   INTEGER

  DEFINE p_tela RECORD 
         qtd_movto           DECIMAL(15,6)
  END RECORD 

END GLOBALS


MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0800-05.10.05"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0800.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0800_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0800_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0800") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0800 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar" "Informa dados para processamento"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0800","IN") THEN
        CALL pol0800_informar() RETURNING p_status
      END IF
     COMMAND "Processar" "Processa dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0800","MO") THEN
           IF pol0800_processar() THEN 
              LET p_tela.qtd_movto = 0
              CLEAR FORM
              MESSAGE "PROCESSAMENTO EFETUADO COM SUCESSO"
           ELSE
              MESSAGE " "
           END IF    
       END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0800
END FUNCTION

#--------------------------------------#
 FUNCTION pol0800_informar()
#--------------------------------------#
  LET p_houve_erro = FALSE
  IF  pol0800_entrada_dados("INCLUSAO") THEN
      SELECT cod_emp_gerencial
        INTO p_cod_emp2
        FROM empresas_885
       WHERE cod_emp_oficial = p_cod_empresa
      IF SQLCA.sqlcode <> 0 THEN 
         SELECT cod_emp_oficial
           INTO p_cod_emp2
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
      END IF   
  ELSE
      CLEAR FORM
      MESSAGE " Inclusao Cancelada. "
      RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION

#---------------------------------------#
 FUNCTION pol0800_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0800
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_item.cod_empresa,
               p_item.cod_item,
               p_item.den_item  TO NULL
    LET p_item.cod_empresa = p_cod_empresa
    
    SELECT cod_item_sucata 
      INTO p_item.cod_item 
      FROM parametros_885
     WHERE cod_empresa = p_cod_empresa
     
    IF SQLCA.sqlcode <> 0 THEN 
       SELECT cod_item_sucata 
         INTO p_item.cod_item 
         FROM parametros_885
        WHERE cod_empresa = p_cod_emp2
        ERROR "PARAMETROS NAO CADASTRADOS PARA A EMPRESA"
        RETURN FALSE
    END IF 
    
    SELECT den_item,
           cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso, 
           cod_local_estoq
      INTO p_item.den_item,
           l_cod_lin_prod, 
           l_cod_lin_recei,
           l_cod_seg_merc, 
           l_cod_cla_uso,  
           p_item.cod_local_estoq
      FROM item
     WHERE cod_empresa = p_cod_empresa   
       AND cod_item    = p_item.cod_item 

    DISPLAY BY NAME p_item.cod_empresa
    DISPLAY BY NAME p_item.cod_item
    DISPLAY BY NAME p_item.den_item
  END IF
  INPUT   BY NAME p_tela.* WITHOUT DEFAULTS  

    AFTER FIELD qtd_movto 
      IF p_tela.qtd_movto  IS NULL OR 
         p_tela.qtd_movto = 0 THEN
         ERROR "O campo quantidade nao pode ser nulo ou menor que 0."
         NEXT FIELD qtd_movto
      END IF

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0800
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION

#---------------------------#
 FUNCTION pol0800_processar()
#---------------------------#

  IF p_tela.qtd_movto > 0 THEN 
     LET  p_estoque_trans.cod_empresa   = p_cod_empresa
     LET  p_estoque_trans.dat_movto     = TODAY
     LET  p_estoque_trans.dat_proces    = TODAY
     LET  p_estoque_trans.hor_operac    = TIME
     
     LET p_estoque_trans.ies_tip_movto = "N"
            
     SELECT num_conta_debito 
       INTO p_estoque_trans.num_conta
       FROM estoque_operac_ct      
      WHERE cod_empresa = p_cod_empresa
        AND cod_operacao =  'APOS'
         
     IF SQLCA.sqlcode <> 0 THEN 
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
        
     LET  p_estoque_trans.cod_operacao       =  'APOS'
     LET  p_estoque_trans.cod_item           =  p_item.cod_item
     LET  p_estoque_trans.num_transac        =  "0"
     LET  p_estoque_trans.num_prog           =  "POL0800"
     LET  p_estoque_trans.num_docum          =  "1"
     LET  p_estoque_trans.num_seq            =  "1"
     LET  p_estoque_trans.cus_unit_movto_p   =  0
     LET  p_estoque_trans.cus_tot_movto_p    =  0
     LET  p_estoque_trans.cus_unit_movto_f   =  0
     LET  p_estoque_trans.cus_tot_movto_f    =  0
     LET  p_estoque_trans.num_secao_requis   =  NULL
     LET  p_estoque_trans.cod_local_est_dest =  NULL
     LET  p_estoque_trans.num_lote_dest      =  NULL
     LET  p_estoque_trans.ies_sit_est_dest   =  "L"
     LET  p_estoque_trans.cod_turno          =  NULL
     LET  p_estoque_trans.nom_usuario        =  p_user
     LET  p_estoque_trans.ies_sit_est_orig   =  " "
     LET  p_estoque_trans.cod_local_est_orig =  NULL
     LET  p_estoque_trans.dat_ref_moeda_fort =  "31/12/1899"
     LET  p_estoque_trans.qtd_movto          =  p_tela.qtd_movto
     LET  p_estoque_trans.cod_local_est_dest =  p_item.cod_local_estoq
     LET  p_estoque_trans.num_lote_orig      =  NULL
        
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
          VALUES (p_cod_empresa,
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

     LET p_num_tran_at =  SQLCA.SQLERRD[2]
                  
     INSERT INTO estoque_trans_end VALUES (p_cod_empresa,
                                           p_num_tran_at,
                                           ' ',
                                           0,
                                           p_estoque_trans.qtd_movto,
                                           ' ',
                                           ' ',
                                           ' ',
                                           ' ',
                                           ' ',
                                           '1900-01-01 00:00:00',
                                           '1900-01-01 00:00:00',
                                           0,
                                           ' ',
                                           0,
                                           0,
                                           '1900-01-01 00:00:00',
                                           '1900-01-01 00:00:00',
                                           ' ',
                                           ' ',
                                           0,
                                           0,
                                           0,
                                           0,
                                           '1900-01-01 00:00:00',
                                           '1900-01-01 00:00:00',
                                           '1900-01-01 00:00:00',
                                           0,
                                           0,
                                           0,
                                           0,
                                           0,
                                           0,
                                           ' ',
                                           0,
                                           0,
                                           0,
                                           0,
                                           p_estoque_trans.cod_item,
                                           p_estoque_trans.dat_movto,
                                           p_estoque_trans.cod_operacao,
                                           p_estoque_trans.ies_tip_movto,
                                           p_estoque_trans.num_prog)
     
     LET l_count = 0 
     SELECT COUNT(*)
       INTO l_count
       FROM estoque 
      WHERE cod_empresa =   p_cod_empresa
        AND cod_item    =   p_item.cod_item
     IF l_count > 0 THEN 
        UPDATE estoque SET qtd_liberada  = qtd_liberada + p_tela.qtd_movto
            WHERE cod_empresa =   p_cod_empresa
              AND cod_item    =   p_item.cod_item
     ELSE
        INSERT INTO estoque VALUES (p_cod_empresa,
                                    p_item.cod_item,
                                    p_tela.qtd_movto,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    TODAY,
                                    TODAY,
                                    TODAY)
     END IF 
     
     LET l_count = 0 
     SELECT COUNT(*)
       INTO l_count
       FROM estoque_lote
      WHERE cod_empresa   =   p_cod_empresa
        AND cod_item      =   p_item.cod_item
        AND cod_local     =   p_item.cod_local_estoq
        AND num_lote      IS  NULL 
        AND ies_situa_qtd = "L"
     IF l_count > 0 THEN 
        UPDATE estoque_lote SET qtd_saldo = qtd_saldo + p_tela.qtd_movto
         WHERE cod_empresa   =   p_cod_empresa
           AND cod_item      =   p_item.cod_item
           AND cod_local     =   p_item.cod_local_estoq
           AND num_lote      IS  NULL 
           AND ies_situa_qtd = "L"
     ELSE
        INSERT INTO estoque_lote (cod_empresa,
                                  cod_item,
                                  cod_local,
                                  num_lote,
                                  ies_situa_qtd,
                                  qtd_saldo) 
                          VALUES (p_cod_empresa,
                                  p_item.cod_item,
                                  p_item.cod_local_estoq,
                                  p_estoque_trans.num_lote_orig,
                                  'L',
                                  p_tela.qtd_movto)
     
     END IF 
     
     LET l_count = 0 
     SELECT COUNT(*)
       INTO l_count
       FROM estoque_lote_ender
      WHERE cod_empresa   =   p_cod_empresa
        AND cod_item      =   p_item.cod_item
        AND cod_local     =   p_item.cod_local_estoq
        AND num_lote      IS  NULL 
        AND ies_situa_qtd = "L"
     IF l_count > 0 THEN 
        UPDATE estoque_lote_ender SET qtd_saldo = qtd_saldo + p_tela.qtd_movto
         WHERE cod_empresa   =   p_cod_empresa
           AND cod_item      =   p_item.cod_item
           AND cod_local     =   p_item.cod_local_estoq
           AND num_lote      IS  NULL 
           AND ies_situa_qtd = "L"
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
                                VALUES (p_cod_empresa, 
                                        p_item.cod_item, 
                                        p_item.cod_local_estoq,
                                        p_estoque_trans.num_lote_orig,
                                        ' ',
                                        0,
                                        ' ',
                                        ' ',
                                        ' ',
                                        ' ',
                                        ' ',
                                        '1900-01-01 00:00:00',
                                        0,
                                        0,
                                        'L',
                                        p_tela.qtd_movto,
                                        ' ',
                                        '1900-01-01 00:00:00',
                                        ' ',
                                        ' ',
                                        0,
                                        0,
                                        0,
                                        0,
                                        '1900-01-01 00:00:00',
                                        '1900-01-01 00:00:00',
                                        '1900-01-01 00:00:00',
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        ' ')
     END IF 
     IF p_cod_emp2 IS NOT NULL THEN 
        LET  p_estoque_trans.cod_empresa   = p_cod_emp2
        LET  p_estoque_trans.dat_movto     = TODAY
        LET  p_estoque_trans.dat_proces    = TODAY
        LET  p_estoque_trans.hor_operac    = TIME
        
        LET p_estoque_trans.ies_tip_movto = "N"
               
        SELECT num_conta_debito 
          INTO p_estoque_trans.num_conta
          FROM estoque_operac_ct      
         WHERE cod_empresa = p_cod_emp2
           AND cod_operacao =  'APOS'
            
        IF SQLCA.sqlcode <> 0 THEN 
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
           
        LET  p_estoque_trans.cod_operacao       =  'APOS'
        LET  p_estoque_trans.cod_item           =  p_item.cod_item
        LET  p_estoque_trans.num_transac        =  "0"
        LET  p_estoque_trans.num_prog           =  "POL0800"
        LET  p_estoque_trans.num_docum          =  "1"
        LET  p_estoque_trans.num_seq            =  "1"
        LET  p_estoque_trans.cus_unit_movto_p   =  0
        LET  p_estoque_trans.cus_tot_movto_p    =  0
        LET  p_estoque_trans.cus_unit_movto_f   =  0
        LET  p_estoque_trans.cus_tot_movto_f    =  0
        LET  p_estoque_trans.num_secao_requis   =  NULL
        LET  p_estoque_trans.cod_local_est_dest =  NULL
        LET  p_estoque_trans.num_lote_dest      =  NULL
        LET  p_estoque_trans.ies_sit_est_dest   =  "L"
        LET  p_estoque_trans.cod_turno          =  NULL
        LET  p_estoque_trans.nom_usuario        =  p_user
        LET  p_estoque_trans.ies_sit_est_orig   =  " "
        LET  p_estoque_trans.cod_local_est_orig =  NULL
        LET  p_estoque_trans.dat_ref_moeda_fort =  "31/12/1899"
        LET  p_estoque_trans.qtd_movto          =  p_tela.qtd_movto
        LET  p_estoque_trans.cod_local_est_dest =  p_item.cod_local_estoq
        LET  p_estoque_trans.num_lote_orig      =  NULL
           
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
             VALUES (p_cod_emp2,
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

     LET p_num_tran_at =  SQLCA.SQLERRD[2]
                  
     INSERT INTO estoque_trans_end VALUES (p_cod_emp2,
                                           p_num_tran_at,
                                           ' ',
                                           0,
                                           p_estoque_trans.qtd_movto,
                                           ' ',
                                           ' ',
                                           ' ',
                                           ' ',
                                           ' ',
                                           '1900-01-01 00:00:00',
                                           '1900-01-01 00:00:00',
                                           0,
                                           ' ',
                                           0,
                                           0,
                                           '1900-01-01 00:00:00',
                                           '1900-01-01 00:00:00',
                                           ' ',
                                           ' ',
                                           0,
                                           0,
                                           0,
                                           0,
                                           '1900-01-01 00:00:00',
                                           '1900-01-01 00:00:00',
                                           '1900-01-01 00:00:00',
                                           0,
                                           0,
                                           0,
                                           0,
                                           0,
                                           0,
                                           ' ',
                                           0,
                                           0,
                                           0,
                                           0,
                                           p_estoque_trans.cod_item,
                                           p_estoque_trans.dat_movto,
                                           p_estoque_trans.cod_operacao,
                                           p_estoque_trans.ies_tip_movto,
                                           p_estoque_trans.num_prog)
        
        LET l_count = 0 
        SELECT COUNT(*)
          INTO l_count
          FROM estoque 
         WHERE cod_empresa =   p_cod_emp2
           AND cod_item    =   p_item.cod_item
        IF l_count > 0 THEN 
           UPDATE estoque SET qtd_liberada  = qtd_liberada + p_tela.qtd_movto
               WHERE cod_empresa =   p_cod_emp2
                 AND cod_item    =   p_item.cod_item
        ELSE
           INSERT INTO estoque VALUES (p_cod_emp2,
                                       p_item.cod_item,
                                       p_tela.qtd_movto,
                                       0,
                                       0,
                                       0,
                                       0,
                                       0,
                                       TODAY,
                                       TODAY,
                                       TODAY)
        END IF 
        
        LET l_count = 0 
        SELECT COUNT(*)
          INTO l_count
          FROM estoque_lote
         WHERE cod_empresa   =   p_cod_emp2
           AND cod_item      =   p_item.cod_item
           AND cod_local     =   p_item.cod_local_estoq
           AND num_lote      IS  NULL 
           AND ies_situa_qtd = "L"
        IF l_count > 0 THEN 
           UPDATE estoque_lote SET qtd_saldo = qtd_saldo + p_tela.qtd_movto
            WHERE cod_empresa   =   p_cod_emp2
              AND cod_item      =   p_item.cod_item
              AND cod_local     =   p_item.cod_local_estoq
              AND num_lote      IS  NULL 
              AND ies_situa_qtd = "L"
        ELSE
           INSERT INTO estoque_lote (cod_empresa,
                                     cod_item,
                                     cod_local,
                                     num_lote,
                                     ies_situa_qtd,
                                     qtd_saldo) 
                             VALUES (p_cod_emp2,
                                     p_item.cod_item,
                                     p_item.cod_local_estoq,
                                     p_estoque_trans.num_lote_orig,
                                     'L',
                                     p_tela.qtd_movto)
        
        END IF 
        
        LET l_count = 0 
        SELECT COUNT(*)
          INTO l_count
          FROM estoque_lote_ender
         WHERE cod_empresa   =   p_cod_emp2
           AND cod_item      =   p_item.cod_item
           AND cod_local     =   p_item.cod_local_estoq
           AND num_lote      IS  NULL 
           AND ies_situa_qtd = "L"
        IF l_count > 0 THEN 
           UPDATE estoque_lote_ender SET qtd_saldo = qtd_saldo + p_tela.qtd_movto
            WHERE cod_empresa   =   p_cod_emp2
              AND cod_item      =   p_item.cod_item
              AND cod_local     =   p_item.cod_local_estoq
              AND num_lote      IS  NULL 
              AND ies_situa_qtd = "L"
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
                                   VALUES (p_cod_emp2, 
                                           p_item.cod_item, 
                                           p_item.cod_local_estoq,
                                           p_estoque_trans.num_lote_orig,
                                           ' ',
                                           0,
                                           ' ',
                                           ' ',
                                           ' ',
                                           ' ',
                                           ' ',
                                           '1900-01-01 00:00:00',
                                           0,
                                           0,
                                           'L',
                                           p_tela.qtd_movto,
                                           ' ',
                                           '1900-01-01 00:00:00',
                                           ' ',
                                           ' ',
                                           0,
                                           0,
                                           0,
                                           0,
                                           '1900-01-01 00:00:00',
                                           '1900-01-01 00:00:00',
                                           '1900-01-01 00:00:00',
                                           0,
                                           0,
                                           0,
                                           0,
                                           0,
                                           0,
                                           ' ')
        END IF 
     END IF
     RETURN TRUE 
  ELSE
     RETURN FALSE
  END IF    
END FUNCTION