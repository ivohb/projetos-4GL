#----------------------------------------------------#
# PROGRAMA: pol0821 - BASE PEDIDO OU CLIENTE         #
# OBJETIVO: BAIXAR ESTOQUES P. ACABADOS              #
#----------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE 
         p_cod_empresa        CHAR(02),
         p_cancel             INTEGER,
         p_ies_processou      SMALLINT,
         comando              CHAR(80),
         p_ind                SMALLINT,
         p_count              SMALLINT,
         p_count_tot          DECIMAL(6,0),
         p_count_proc         DECIMAL(6,0),
         p_resposta           CHAR(1),
         p_baixa_est          CHAR(1),
         p_data               DATE,
         p_hora               CHAR(05),
         p_versao             CHAR(18),               
         p_num_tran_at        INTEGER,
         p_num_lote           LIKE estoque_trans.num_lote_orig,
         p_qtd_movto          LIKE estoque_trans.qtd_movto,
         p_cod_local          LIKE estoque_lote.cod_local,
         p_ies_situa          CHAR(01),
         p_estoque_operac     RECORD LIKE estoque_operac.*, 
         p_estoque_lote       RECORD LIKE estoque_lote.*, 
         p_estoque_trans      RECORD LIKE estoque_trans.*, 
         p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
         p_estt               RECORD LIKE estoque_trans.*, 
         p_estte              RECORD LIKE estoque_trans_end.*

 DEFINE p_user            LIKE usuario.nom_usuario,
        p_status          SMALLINT,
        p_ies_sit         SMALLINT,
        p_nom_help        CHAR(200),
        p_nom_tela        CHAR(080)
END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT 
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0821-05.10.05"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0821.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

    CALL log001_acessa_usuario("VDP","LIC_LIB")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0821_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0821_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0821") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol08210 AT 7,13 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Processar" "Processa baixa de estoque"
      HELP 001
      MESSAGE ""
      LET p_ies_sit  = 0
      LET int_flag = 0
      IF pol0821_processa() THEN
         IF  pol0821_zera_negativos() THEN
             IF pol0821_limpa_zerados() THEN
             ELSE
                #ROLLBACK WORK 
                CALL log085_transacao("ROLLBACK")
             END IF     
         ELSE
             #ROLLBACK WORK 
             CALL log085_transacao("ROLLBACK")
         END IF     
         
         ERROR "Processamento Efetuado com Sucesso"
         NEXT OPTION "Fim"
      ELSE
         MESSAGE "Processamento Cancelado"
         NEXT OPTION "Fim"
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
  CLOSE WINDOW w_pol08210
END FUNCTION

#-----------------------------#
 FUNCTION pol0821_processa()
#-----------------------------#
DEFINE l_count INTEGER,
       l_cod_empresa  CHAR(02),
       l_cod_item     CHAR(15),
       l_ies_tip_item CHAR(01),
       l_ies_dupl     CHAR(01),
       l_ind          INTEGER
   
WHENEVER ERROR CONTINUE


SELECT COUNT(*) 
  INTO p_count_tot
  FROM estoque_trans_aux

LET p_count_proc = 0  

DROP TABLE w821_item

CREATE TEMP TABLE w821_item (cod_empresa CHAR(02),
                             cod_item    CHAR(15),
                             ies_tip_item CHAR(01))

DELETE FROM w821_item

LET p_ies_processou = TRUE
LET p_hora = TIME

DECLARE cq_it CURSOR FOR
SELECT DISTINCT cod_empresa,
                cod_item
  FROM estoque_trans_aux 
  
FOREACH cq_it INTO l_cod_empresa,l_cod_item
  
  SELECT ies_tip_item 
    INTO l_ies_tip_item 
    FROM item  
   WHERE cod_empresa  = l_cod_empresa
     AND cod_item     = l_cod_item 

  IF l_ies_tip_item = 'C' THEN 
     CONTINUE FOREACH 
  END IF 
  
  INSERT INTO w821_item VALUES (l_cod_empresa,l_cod_item,l_ies_tip_item)
   
END FOREACH  


LET l_ind = 1

FOR l_ind = 1 TO 4
   
   #BEGIN WORK
   CALL log085_transacao("BEGIN")

   IF l_ind = 1 THEN 
      LET l_ies_tip_item = 'C'
   ELSE
      IF l_ind = 2 THEN 
         LET l_ies_tip_item = 'P'
      ELSE
         IF l_ind = 3 THEN 
            LET l_ies_tip_item = 'F'
         ELSE
            LET l_ies_tip_item = 'T'
         END IF
      END IF     
   END IF    

   IF l_ies_tip_item = 'P' THEN
      DISPLAY 'PRODUZIDOS' AT 5,25
   ELSE
      IF l_ies_tip_item = 'F' THEN
         DISPLAY 'FINAIS    ' AT 5,25
      ELSE   
         IF l_ies_tip_item = 'T' THEN
            DISPLAY 'FANTASMA  ' AT 5,25
         ELSE   
            DISPLAY 'COMPRADOS ' AT 5,25
         END IF 
      END IF 
   END IF 
            
   DECLARE cq_ite CURSOR FOR
     SELECT cod_empresa,
            cod_item  
       FROM w821_item
      WHERE ies_tip_item = l_ies_tip_item
      ORDER BY cod_empresa,
               cod_item
   FOREACH cq_ite INTO l_cod_empresa, l_cod_item

       LET l_count = 0 
       SELECT COUNT(*) 
         INTO l_count
         FROM estoque
        WHERE cod_empresa =  l_cod_empresa
          AND cod_item    =  l_cod_item
          
       IF l_count > 0 THEN 
          EXIT FOREACH
       END IF        
                
       DECLARE cq_estoq CURSOR FOR 
          SELECT *  
            FROM estoque_trans_aux
           WHERE cod_empresa =  l_cod_empresa
             AND cod_item    =  l_cod_item
           ORDER BY dat_movto
            
       FOREACH cq_estoq INTO p_estt.* 

          LET p_count_proc = p_count_proc + 1         
          
          LET p_ies_sit = 1 
          DISPLAY "Item " AT 7,7
          DISPLAY p_estt.cod_empresa AT 7,12
          DISPLAY p_estt.cod_operacao AT 7,17
          DISPLAY p_estt.cod_item AT 7,22
          DISPLAY "PROC " AT 8,7
          DISPLAY p_count_proc AT 8,12
          DISPLAY ' DE ' AT 8,19
          DISPLAY p_count_tot  AT 8,24
          DISPLAY '         ' AT 9,7
            
          IF p_estt.cod_operacao = 'IMPL' THEN
             IF p_estt.dat_movto <> '30/04/2008' THEN
                CONTINUE FOREACH
             END IF
          END IF       
       
          IF p_estt.cod_operacao = 'APOM' THEN
             CONTINUE FOREACH
          END IF       
       
          LET p_estoque_trans.*  =  p_estt.*
          
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
          
          LET p_num_tran_at =  SQLCA.SQLERRD[2]
          
          SELECT * 
            INTO p_estoque_operac.*
            FROM estoque_operac
           WHERE cod_operacao = p_estt.cod_operacao
             AND cod_empresa  = p_estoque_trans.cod_empresa
   
          LET p_count = 0 
          
          SELECT COUNT(*)
            INTO p_count 
            FROM est_trans_end_aux
           WHERE cod_empresa = p_estt.cod_empresa
             AND num_transac = p_estt.num_transac
             AND cod_item    = p_estt.cod_item 
   
          IF p_count = 0 THEN 
             LET p_estte.cod_empresa             = p_estt.cod_empresa       
             LET p_estte.num_transac             = p_num_tran_at
             LET p_estte.endereco                = ' '
             LET p_estte.num_volume              = 0
             LET p_estte.qtd_movto               = p_estt.qtd_movto
             LET p_estte.cod_grade_1             = ' '
             LET p_estte.cod_grade_2             = ' '
             LET p_estte.cod_grade_3             = ' '
             LET p_estte.cod_grade_4             = ' '
             LET p_estte.cod_grade_5             = ' '
             LET p_estte.dat_hor_prod_ini        = '1900-01-01 00:00:00'
             LET p_estte.dat_hor_prod_fim        = '1900-01-01 00:00:00'
             LET p_estte.vlr_temperatura         = 0
             LET p_estte.endereco_origem         = ' '
             LET p_estte.num_ped_ven             = 0
             LET p_estte.num_seq_ped_ven         = 0
             LET p_estte.dat_hor_producao        = '1900-01-01 00:00:00'
             LET p_estte.dat_hor_validade        = '1900-01-01 00:00:00'
             LET p_estte.num_peca                = ' '
             LET p_estte.num_serie               = ' '
             LET p_estte.comprimento             = 0
             LET p_estte.largura                 = 0
             LET p_estte.altura                  = 0
             LET p_estte.diametro                = 0
             LET p_estte.dat_hor_reserv_1        = '1900-01-01 00:00:00'
             LET p_estte.dat_hor_reserv_2        = '1900-01-01 00:00:00'
             LET p_estte.dat_hor_reserv_3        = '1900-01-01 00:00:00'
             LET p_estte.qtd_reserv_1            = 0
             LET p_estte.qtd_reserv_2            = 0
             LET p_estte.qtd_reserv_3            = 0
             LET p_estte.num_reserv_1            = 0
             LET p_estte.num_reserv_2            = 0
             LET p_estte.num_reserv_3            = 0
             LET p_estte.tex_reservado           = ' '
             LET p_estte.cus_unit_movto_p        = 0
             LET p_estte.cus_unit_movto_f        = 0
             LET p_estte.cus_tot_movto_p         = 0
             LET p_estte.cus_tot_movto_f         = 0
             LET p_estte.cod_item                = p_estt.cod_item 
             LET p_estte.dat_movto               = p_estoque_trans.dat_movto
             LET p_estte.cod_operacao            = p_estt.cod_operacao
             LET p_estte.ies_tip_movto           = p_estt.ies_tip_movto
             LET p_estte.num_prog                = p_estt.num_prog
   
             IF p_estoque_operac.ies_tipo = 'E' THEN 
                IF p_estt.ies_tip_movto = 'R' THEN
                   LET p_estt.num_lote_orig      = p_estt.num_lote_dest
                   LET p_estt.cod_local_est_orig = p_estt.cod_local_est_dest
                   LET p_estt.ies_sit_est_orig   = p_estt.ies_sit_est_dest 
                   IF pol0821_subtrai_estoque() THEN
                   ELSE
                     #ROLLBACK WORK
                     CALL log085_transacao("ROLLBACK")
                     RETURN FALSE
                   END IF
                ELSE  
                   IF pol0821_soma_estoque() THEN
                   ELSE
                     #ROLLBACK WORK
                     CALL log085_transacao("ROLLBACK")
                     RETURN FALSE
                   END IF
                END IF 
             ELSE
                IF p_estoque_operac.ies_tipo = 'S' THEN 
                   IF p_estt.ies_tip_movto = 'N' THEN
                      IF pol0821_subtrai_estoque() THEN
                      ELSE
                        #ROLLBACK WORK
                        CALL log085_transacao("ROLLBACK")
                        RETURN FALSE
                      END IF
                   ELSE  
                      LET p_estt.num_lote_dest      = p_estt.num_lote_orig
                      LET p_estt.cod_local_est_dest = p_estt.cod_local_est_orig 
                      LET p_estt.ies_sit_est_dest = p_estt.ies_sit_est_orig 
                      IF pol0821_soma_estoque() THEN
                      ELSE
                        #ROLLBACK WORK
                        CALL log085_transacao("ROLLBACK")
                        RETURN FALSE
                      END IF
                   END IF 
                ELSE
                   IF p_estoque_operac.ies_com_quantidade = 'S' THEN 
                      IF p_estt.ies_tip_movto = 'N' THEN
                         IF pol0821_transfer() THEN
                         ELSE
                            #ROLLBACK WORK
                            CALL log085_transacao("ROLLBACK")
                            RETURN FALSE
                         END IF
                      ELSE  
                         IF pol0821_rev_transfer() THEN
                         ELSE
                           #ROLLBACK WORK
                           CALL log085_transacao("ROLLBACK")
                           RETURN FALSE
                         END IF
                      END IF 
                   END IF 
                END IF 
             END IF    
             INSERT INTO estoque_trans_end VALUES (p_estte.*)
          ELSE   
             DECLARE cq_estte CURSOR FOR
               SELECT * 
                 FROM est_trans_end_aux
                WHERE cod_empresa  = p_estt.cod_empresa
                  AND num_transac  = p_estt.num_transac
                  AND cod_item     = p_estt.cod_item
                  AND cod_operacao = p_estt.cod_operacao
                  
             FOREACH  cq_estte  INTO p_estte.*
               
               LET p_estoque_trans_end.* = p_estte.*
               LET p_estoque_trans_end.num_transac = p_num_tran_at
               
               IF p_estoque_operac.ies_tipo = 'E' THEN 
                  IF p_estt.ies_tip_movto = 'R' THEN
                     LET p_estt.num_lote_orig      = p_estt.num_lote_dest
                     LET p_estt.cod_local_est_orig = p_estt.cod_local_est_dest
                     LET p_estt.ies_sit_est_orig   = p_estt.ies_sit_est_dest 
                     IF pol0821_subtrai_estoque() THEN
                     ELSE
                       #ROLLBACK WORK
                       CALL log085_transacao("ROLLBACK")
                       RETURN FALSE
                     END IF
                  ELSE  
                     IF pol0821_soma_estoque() THEN
                     ELSE
                       #ROLLBACK WORK
                       CALL log085_transacao("ROLLBACK")
                       RETURN FALSE
                     END IF
                  END IF 
               ELSE
                  IF p_estoque_operac.ies_tipo = 'S' THEN 
                     IF p_estt.ies_tip_movto = 'N' THEN
                        IF pol0821_subtrai_estoque() THEN
                        ELSE
                          #ROLLBACK WORK
                          CALL log085_transacao("ROLLBACK")
                          RETURN FALSE
                        END IF
                     ELSE  
                        LET p_estt.num_lote_dest      = p_estt.num_lote_orig
                        LET p_estt.cod_local_est_dest = p_estt.cod_local_est_orig 
                        LET p_estt.ies_sit_est_dest = p_estt.ies_sit_est_orig 
                        IF pol0821_soma_estoque() THEN
                        ELSE
                          #ROLLBACK WORK
                          CALL log085_transacao("ROLLBACK")
                          RETURN FALSE
                        END IF
                     END IF 
                  ELSE
                     IF p_estoque_operac.ies_com_quantidade = 'S' THEN 
                        IF p_estt.ies_tip_movto = 'N' THEN
                           IF pol0821_transfer() THEN
                           ELSE
                              #ROLLBACK WORK
                              CALL log085_transacao("ROLLBACK")
                              RETURN FALSE
                           END IF
                        ELSE  
                           IF pol0821_rev_transfer() THEN
                           ELSE
                             #ROLLBACK WORK
                             CALL log085_transacao("ROLLBACK")
                             RETURN FALSE
                           END IF
                        END IF 
                     END IF 
                  END IF 
               END IF    
               
               INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)
             
             END FOREACH     
          END IF    
       END FOREACH
       
   END FOREACH   

   #COMMIT WORK 
   CALL log085_transacao("COMMIT")

   DISPLAY 'COMMIT' AT 9,7
   DISPLAY "Item " AT 7,7
   DISPLAY '                         ' AT 7,12
   DISPLAY "doc " AT 8,7
   DISPLAY '                         ' AT 8,12

END FOR 

IF p_ies_sit = 1  THEN 
   RETURN TRUE  
ELSE
   ERROR "Dados nao encontrado na tabela estoque_trans_aux"
   SLEEP 2
   RETURN FALSE
END IF
END FUNCTION  

#-------------------------------#
 FUNCTION pol0821_soma_estoque()
#-------------------------------#
  DEFINE  l_count   INTEGER 
  
  LET l_count = 0 
  
  SELECT COUNT(*) 
    INTO l_count 
    FROM estoque 
   WHERE cod_empresa =   p_estt.cod_empresa
     AND cod_item    =   p_estt.cod_item
  IF l_count > 0 THEN 
     IF p_estt.ies_sit_est_dest = 'L' THEN 
        UPDATE estoque SET  qtd_liberada = qtd_liberada + p_estte.qtd_movto
         WHERE cod_empresa =   p_estt.cod_empresa
           AND cod_item    =   p_estt.cod_item
        IF STATUS <> 0 THEN
           CALL log003_err_sql("UPDATE 1","ESTOQUE lib")
           RETURN FALSE
        END IF
     ELSE
        IF p_estt.ies_sit_est_dest = 'I' THEN
           UPDATE estoque SET  qtd_impedida = qtd_impedida + p_estte.qtd_movto
            WHERE cod_empresa =   p_estt.cod_empresa
              AND cod_item    =   p_estt.cod_item
           IF STATUS <> 0 THEN
              CALL log003_err_sql("UPDATE 1","ESTOQUE imp")
              RETURN FALSE
           END IF
        ELSE 
           IF p_estt.ies_sit_est_dest = 'R' THEN
              UPDATE estoque SET  qtd_rejeitada = qtd_rejeitada + p_estte.qtd_movto
               WHERE cod_empresa =   p_estt.cod_empresa
                 AND cod_item    =   p_estt.cod_item
              IF STATUS <> 0 THEN
                 CALL log003_err_sql("UPDATE 1","ESTOQUE rej")
                 RETURN FALSE
              END IF
           ELSE      
              UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep + p_estte.qtd_movto
               WHERE cod_empresa =   p_estt.cod_empresa
                 AND cod_item    =   p_estt.cod_item
              IF STATUS <> 0 THEN
                 CALL log003_err_sql("UPDATE 1","ESTOQUE exc")
                 RETURN FALSE
              END IF
           END IF
        END IF
     END IF                           
  ELSE
     IF p_estt.ies_sit_est_dest = 'L' THEN 
        INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                    p_estt.cod_item,
                                    p_estte.qtd_movto,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    '',
                                    TODAY,
                                    TODAY)
        IF STATUS <> 0 THEN
          CALL log003_err_sql("INSERT 1","ESTOQUE lib")
          RETURN FALSE
        END IF
     ELSE
        IF p_estt.ies_sit_est_dest = 'I' THEN
           INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                       p_estt.cod_item,
                                       0,
                                       p_estte.qtd_movto,
                                       0,
                                       0,
                                       0,
                                       0,
                                       '',
                                       TODAY,
                                       TODAY)
           IF STATUS <> 0 THEN
              CALL log003_err_sql("INSERT 1","ESTOQUE imp")
              RETURN FALSE
           END IF                            
        ELSE
           IF p_estt.ies_sit_est_dest = 'R' THEN
              INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                          p_estt.cod_item,
                                          0,
                                          0,
                                          p_estte.qtd_movto,
                                          0,
                                          0,
                                          0,
                                          '',
                                          TODAY,
                                          TODAY)
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("INSERT 1","ESTOQUE rej")
                 RETURN FALSE                   
              END IF                            
           ELSE
              INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                          p_estt.cod_item,
                                          0,
                                          0,
                                          0,
                                          p_estte.qtd_movto,
                                          0,
                                          0,
                                          '',
                                          TODAY,
                                          TODAY)
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("INSERT 1","ESTOQUE exp")
                 RETURN FALSE                   
              END IF                            
           END IF 
        END IF                                
     END IF                                
  END IF 

  LET l_count = 0 

  IF p_estt.num_lote_dest IS NULL THEN 
     SELECT COUNT(*) 
       INTO l_count 
       FROM estoque_lote 
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL 
        AND cod_local     =   p_estt.cod_local_est_dest
        AND ies_situa_qtd =   p_estt.ies_sit_est_dest
  ELSE
     SELECT COUNT(*) 
       INTO l_count 
       FROM estoque_lote 
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_estt.num_lote_dest
        AND cod_local     =   p_estt.cod_local_est_dest
        AND ies_situa_qtd =   p_estt.ies_sit_est_dest
  END IF      
  IF l_count > 0 THEN 
     IF p_estt.num_lote_dest IS NULL THEN 
        UPDATE estoque_lote  SET  qtd_saldo = qtd_saldo + p_estte.qtd_movto
         WHERE cod_empresa   =   p_estt.cod_empresa
           AND cod_item      =   p_estt.cod_item
           AND num_lote      IS NULL 
           AND cod_local     =   p_estt.cod_local_est_dest
           AND ies_situa_qtd =   p_estt.ies_sit_est_dest
     ELSE 
        UPDATE estoque_lote  SET  qtd_saldo = qtd_saldo + p_estte.qtd_movto
         WHERE cod_empresa   =   p_estt.cod_empresa
           AND cod_item      =   p_estt.cod_item
           AND num_lote      =   p_estt.num_lote_dest
           AND cod_local     =   p_estt.cod_local_est_dest
           AND ies_situa_qtd =   p_estt.ies_sit_est_dest
     END IF    
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("UPDATE 1","ESTOQUE_LOTE")
        RETURN FALSE                   
     END IF                            
  ELSE
     INSERT INTO estoque_lote (cod_empresa,
                               cod_item,
                               cod_local,
                               num_lote,
                               ies_situa_qtd,
                               qtd_saldo) 
                       VALUES (p_estt.cod_empresa,
                               p_estt.cod_item,
                               p_estt.cod_local_est_dest,
                               p_estt.num_lote_dest,
                               p_estt.ies_sit_est_dest,
                               p_estte.qtd_movto)
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("INSERT 1","ESTOQUE_LOTE")
        RETURN FALSE                   
     END IF                            
  END IF 

  LET l_count = 0 
  IF p_estt.num_lote_dest IS NULL THEN
     SELECT COUNT(*) 
     INTO l_count 
     FROM estoque_lote_ender 
    WHERE cod_empresa   =   p_estt.cod_empresa
      AND cod_item      =   p_estt.cod_item
      AND num_lote      IS NULL 
      AND cod_local     =   p_estt.cod_local_est_dest
      AND ies_situa_qtd =   p_estt.ies_sit_est_dest
      AND comprimento   =   p_estte.comprimento
      AND largura       =   p_estte.largura
      AND altura        =   p_estte.altura
      AND diametro      =   p_estte.diametro
  ELSE
     SELECT COUNT(*) 
     INTO l_count 
     FROM estoque_lote_ender 
    WHERE cod_empresa   =   p_estt.cod_empresa
      AND cod_item      =   p_estt.cod_item
      AND num_lote      =   p_estt.num_lote_dest
      AND cod_local     =   p_estt.cod_local_est_dest
      AND ies_situa_qtd =   p_estt.ies_sit_est_dest
      AND comprimento   =   p_estte.comprimento
      AND largura       =   p_estte.largura
      AND altura        =   p_estte.altura
      AND diametro      =   p_estte.diametro
  END IF     
  IF l_count > 0 THEN 
     IF p_estt.num_lote_dest IS NULL THEN
        UPDATE estoque_lote_ender  SET  qtd_saldo = qtd_saldo + p_estte.qtd_movto
         WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL 
        AND cod_local     =   p_estt.cod_local_est_dest
        AND ies_situa_qtd =   p_estt.ies_sit_est_dest
        AND comprimento   =   p_estte.comprimento
        AND largura       =   p_estte.largura
        AND altura        =   p_estte.altura
        AND diametro      =   p_estte.diametro
     ELSE
        UPDATE estoque_lote_ender  SET  qtd_saldo = qtd_saldo + p_estte.qtd_movto
         WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_estt.num_lote_dest
        AND cod_local     =   p_estt.cod_local_est_dest
        AND ies_situa_qtd =   p_estt.ies_sit_est_dest
        AND comprimento   =   p_estte.comprimento
        AND largura       =   p_estte.largura
        AND altura        =   p_estte.altura
        AND diametro      =   p_estte.diametro
    END IF    
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("UPDATE 1","ESTOQUE_LOTE_ENDER")
        RETURN FALSE                   
     END IF                            
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
                              VALUES  (p_estt.cod_empresa,
                                       p_estt.cod_item,
                                       p_estt.cod_local_est_dest,
                                       p_estt.num_lote_dest,
                                       p_estte.endereco_origem,
                                       p_estte.num_volume,
                                       p_estte.cod_grade_1,
                                       p_estte.cod_grade_2,
                                       p_estte.cod_grade_3,
                                       p_estte.cod_grade_4,
                                       p_estte.cod_grade_5,
                                       p_estte.dat_hor_prod_ini,
                                       p_estte.num_ped_ven,
                                       p_estte.num_seq_ped_ven,
                                       p_estt.ies_sit_est_dest,
                                       p_estte.qtd_movto,
                                       ' ',
                                       p_estte.dat_hor_validade,
                                       p_estte.num_peca,
                                       p_estte.num_serie,
                                       p_estte.comprimento,
                                       p_estte.largura,
                                       p_estte.altura,
                                       p_estte.diametro,
                                       p_estte.dat_hor_reserv_1,
                                       p_estte.dat_hor_reserv_2,
                                       p_estte.dat_hor_reserv_3,
                                       p_estte.qtd_reserv_1,
                                       p_estte.qtd_reserv_2,
                                       p_estte.qtd_reserv_3,
                                       p_estte.num_reserv_1,
                                       p_estte.num_reserv_2,
                                       p_estte.num_reserv_3,
                                       p_estte.tex_reservado)
      IF STATUS <> 0 THEN               
        CALL log003_err_sql("INSERT 1","ESTOQUE_LOTE_ENDER")
        RETURN FALSE                   
      END IF                            
  END IF 

  RETURN TRUE
                             
END FUNCTION

#----------------------------------#
 FUNCTION pol0821_subtrai_estoque()
#----------------------------------#
  DEFINE  l_count   INTEGER 
  
  LET l_count = 0 
  
  SELECT COUNT(*) 
    INTO l_count 
    FROM estoque 
   WHERE cod_empresa =   p_estt.cod_empresa
     AND cod_item    =   p_estt.cod_item
  IF l_count > 0 THEN 
     IF p_estt.ies_sit_est_orig = 'L' THEN 
        UPDATE estoque SET  qtd_liberada = qtd_liberada - p_estte.qtd_movto
         WHERE cod_empresa =   p_estt.cod_empresa
           AND cod_item    =   p_estt.cod_item
        IF STATUS <> 0 THEN               
           CALL log003_err_sql("UPDATE 2","ESTOQUE lib")
           RETURN FALSE                   
        END IF  
     ELSE
        IF p_estt.ies_sit_est_orig = 'I' THEN
           UPDATE estoque SET  qtd_impedida = qtd_impedida - p_estte.qtd_movto
            WHERE cod_empresa =   p_estt.cod_empresa
              AND cod_item    =   p_estt.cod_item
           IF STATUS <> 0 THEN               
              CALL log003_err_sql("UPDATE 2","ESTOQUE imp")
              RETURN FALSE                   
           END IF  
        ELSE 
           IF p_estt.ies_sit_est_orig = 'R' THEN
              UPDATE estoque SET  qtd_rejeitada = qtd_rejeitada - p_estte.qtd_movto
               WHERE cod_empresa =   p_estt.cod_empresa
                 AND cod_item    =   p_estt.cod_item
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("UPDATE 2","ESTOQUE rej")
                 RETURN FALSE                   
              END IF  
           ELSE      
              UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep - p_estte.qtd_movto
               WHERE cod_empresa =   p_estt.cod_empresa
                 AND cod_item    =   p_estt.cod_item
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("UPDATE 2","ESTOQUE exp")
                 RETURN FALSE                   
              END IF  
           END IF
        END IF
     END IF                           
  ELSE
     LET p_qtd_movto = p_estte.qtd_movto*-1
     IF p_estt.ies_sit_est_orig = 'L' THEN 
        INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                    p_estt.cod_item,
                                    p_qtd_movto,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    '',
                                    TODAY,
                                    TODAY)
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("INSERT 2","ESTOQUE lib")
                 RETURN FALSE                   
              END IF  
     ELSE
        IF p_estt.ies_sit_est_orig = 'I' THEN
           INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                       p_estt.cod_item,
                                       0,
                                       p_qtd_movto,
                                       0,
                                       0,
                                       0,
                                       0,
                                       '',
                                       TODAY,
                                       TODAY)
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("INSERT 2","ESTOQUE imp")
                 RETURN FALSE                   
              END IF  
        ELSE
           IF p_estt.ies_sit_est_orig = 'R' THEN
              INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                          p_estt.cod_item,
                                          0,
                                          0,
                                          p_qtd_movto,
                                          0,
                                          0,
                                          0,
                                          '',
                                          TODAY,
                                          TODAY)
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("INSERT 2","ESTOQUE rej")
                 RETURN FALSE                   
              END IF  
           ELSE
              INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                          p_estt.cod_item,
                                          0,
                                          0,
                                          0,
                                          p_qtd_movto,
                                          0,
                                          0,
                                          '',
                                          TODAY,
                                          TODAY)
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("INSERT 2","ESTOQUE exp")
                 RETURN FALSE                   
              END IF  
           END IF 
        END IF                                
     END IF                                
  END IF 

  LET l_count = 0 
  IF p_estt.num_lote_orig IS NULL THEN 
     SELECT COUNT(*) 
       INTO l_count 
       FROM estoque_lote 
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL
        AND cod_local     =   p_estt.cod_local_est_orig
        AND ies_situa_qtd =   p_estt.ies_sit_est_orig
  ELSE
     SELECT COUNT(*) 
       INTO l_count 
       FROM estoque_lote 
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_estt.num_lote_orig
        AND cod_local     =   p_estt.cod_local_est_orig
        AND ies_situa_qtd =   p_estt.ies_sit_est_orig
  END IF   
  
  IF l_count > 0 THEN 
   IF p_estt.num_lote_orig IS NULL THEN 
     UPDATE estoque_lote  SET  qtd_saldo = qtd_saldo - p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL
        AND cod_local     =   p_estt.cod_local_est_orig
        AND ies_situa_qtd =   p_estt.ies_sit_est_orig
   ELSE
     UPDATE estoque_lote  SET  qtd_saldo = qtd_saldo - p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_estt.num_lote_orig
        AND cod_local     =   p_estt.cod_local_est_orig
        AND ies_situa_qtd =   p_estt.ies_sit_est_orig
   END IF      
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("UPDATE 2","ESTOQUE_LOTE")
        RETURN FALSE                   
     END IF  
  ELSE
     LET p_qtd_movto = p_estte.qtd_movto*-1  
     INSERT INTO estoque_lote (cod_empresa,
                               cod_item,
                               cod_local,
                               num_lote,
                               ies_situa_qtd,
                               qtd_saldo) 
                       VALUES (p_estt.cod_empresa,
                               p_estt.cod_item,
                               p_estt.cod_local_est_orig,
                               p_estt.num_lote_orig,
                               p_estt.ies_sit_est_orig,
                               p_qtd_movto)
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("INSERT 2","ESTOQUE_LOTE")
        RETURN FALSE                   
     END IF  
  END IF 

  LET l_count = 0 
  IF p_estt.num_lote_orig IS NULL THEN 
     SELECT COUNT(*) 
       INTO l_count 
       FROM estoque_lote_ender 
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL
        AND cod_local     =   p_estt.cod_local_est_orig
        AND ies_situa_qtd =   p_estt.ies_sit_est_orig
        AND comprimento   =   p_estte.comprimento
        AND largura       =   p_estte.largura
        AND altura        =   p_estte.altura
        AND diametro      =   p_estte.diametro
  ELSE
     SELECT COUNT(*) 
       INTO l_count 
       FROM estoque_lote_ender 
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_estt.num_lote_orig
        AND cod_local     =   p_estt.cod_local_est_orig
        AND ies_situa_qtd =   p_estt.ies_sit_est_orig
        AND comprimento   =   p_estte.comprimento
        AND largura       =   p_estte.largura
        AND altura        =   p_estte.altura
        AND diametro      =   p_estte.diametro
  END IF 
  IF l_count > 0 THEN 
   IF p_estt.num_lote_orig IS NULL THEN 
     UPDATE estoque_lote_ender  SET  qtd_saldo = qtd_saldo - p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL
        AND cod_local     =   p_estt.cod_local_est_orig
        AND ies_situa_qtd =   p_estt.ies_sit_est_orig
        AND comprimento   =   p_estte.comprimento
        AND largura       =   p_estte.largura
        AND altura        =   p_estte.altura
        AND diametro      =   p_estte.diametro
   ELSE
     UPDATE estoque_lote_ender  SET  qtd_saldo = qtd_saldo - p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_estt.num_lote_orig
        AND cod_local     =   p_estt.cod_local_est_orig
        AND ies_situa_qtd =   p_estt.ies_sit_est_orig
        AND comprimento   =   p_estte.comprimento
        AND largura       =   p_estte.largura
        AND altura        =   p_estte.altura
        AND diametro      =   p_estte.diametro
   END IF      
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("UPDATE 2","ESTOQUE_LOTE")
        RETURN FALSE                   
     END IF  
  ELSE
      LET p_qtd_movto = p_estte.qtd_movto*-1  
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
         VALUES  (p_estt.cod_empresa,
                  p_estt.cod_item,
                  p_estt.cod_local_est_orig,
                  p_estt.num_lote_orig,
                  p_estte.endereco_origem,
                  p_estte.num_volume,
                  p_estte.cod_grade_1,
                  p_estte.cod_grade_2,
                  p_estte.cod_grade_3,
                  p_estte.cod_grade_4,
                  p_estte.cod_grade_5,
                  p_estte.dat_hor_prod_ini,
                  p_estte.num_ped_ven,
                  p_estte.num_seq_ped_ven,
                  p_estt.ies_sit_est_orig,
                  p_qtd_movto,
                  ' ',
                  p_estte.dat_hor_validade,
                  p_estte.num_peca,
                  p_estte.num_serie,
                  p_estte.comprimento,
                  p_estte.largura,
                  p_estte.altura,
                  p_estte.diametro,
                  p_estte.dat_hor_reserv_1,
                  p_estte.dat_hor_reserv_2,
                  p_estte.dat_hor_reserv_3,
                  p_estte.qtd_reserv_1,
                  p_estte.qtd_reserv_2,
                  p_estte.qtd_reserv_3,
                  p_estte.num_reserv_1,
                  p_estte.num_reserv_2,
                  p_estte.num_reserv_3,
                  p_estte.tex_reservado)
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("INSERT 2","ESTOQUE_LOTE_ENDER")
        RETURN FALSE                   
     END IF  
  END IF 
  
  RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol0821_transfer()
#---------------------------#
LET p_num_lote  = p_estt.num_lote_orig 

IF p_estt.cod_local_est_orig IS NULL THEN 
   LET p_cod_local = p_estt.cod_local_est_dest
ELSE
   LET p_cod_local = p_estt.cod_local_est_orig
END IF 

IF p_estt.ies_sit_est_orig IS NULL THEN
   LET p_ies_situa  = p_estt.ies_sit_est_dest
ELSE
   LET p_ies_situa  = p_estt.ies_sit_est_orig
END IF
 
IF pol0821_subtrai_transf() THEN
ELSE
   RETURN FALSE
END IF 

LET p_num_lote  = p_estt.num_lote_dest
IF p_estt.cod_local_est_dest IS NULL THEN
   LET p_cod_local = p_estt.cod_local_est_orig
ELSE
   LET p_cod_local = p_estt.cod_local_est_dest
END IF    
IF p_estt.ies_sit_est_dest IS NULL THEN
   LET p_ies_situa  = p_estt.ies_sit_est_orig
ELSE
   LET p_ies_situa  = p_estt.ies_sit_est_dest
END IF    

IF pol0821_soma_transf() THEN
ELSE
   RETURN FALSE
END IF 

IF p_estt.ies_sit_est_orig <> p_estt.ies_sit_est_dest THEN
   IF pol0821_mov_est() THEN
   ELSE
      RETURN FALSE
   END IF    
END IF 

RETURN TRUE 
 
END FUNCTION

#-------------------------------#
 FUNCTION pol0821_rev_transfer()
#-------------------------------#
LET p_num_lote  = p_estt.num_lote_orig

IF p_estt.cod_local_est_orig  IS NULL THEN
   LET p_cod_local = p_estt.cod_local_est_dest
ELSE
   LET p_cod_local = p_estt.cod_local_est_orig
END IF 

IF p_estt.ies_sit_est_orig IS NULL THEN 
   LET p_ies_situa  = p_estt.ies_sit_est_dest
ELSE
   LET p_ies_situa  = p_estt.ies_sit_est_orig
END IF 

IF pol0821_soma_transf() THEN
ELSE
   RETURN FALSE
END IF 

LET p_num_lote  = p_estt.num_lote_dest     
IF p_estt.cod_local_est_dest IS NULL THEN 
   LET p_cod_local = p_estt.cod_local_est_orig
ELSE
   LET p_cod_local = p_estt.cod_local_est_dest
END IF
                                    
IF p_estt.ies_sit_est_dest IS NULL THEN 
   LET p_ies_situa  = p_estt.ies_sit_est_orig
ELSE
   LET p_ies_situa  = p_estt.ies_sit_est_dest
END IF 
   
IF pol0821_subtrai_transf() THEN
ELSE
   RETURN FALSE
END IF 

IF p_estt.ies_sit_est_orig <> p_estt.ies_sit_est_dest THEN
   IF pol0821_mov_est_rev() THEN
   ELSE
      RETURN FALSE
   END IF    
END IF 

RETURN TRUE 

END FUNCTION

#-----------------------------#
 FUNCTION pol0821_soma_transf()
#-----------------------------#
  DEFINE  l_count   INTEGER 
  
  LET l_count = 0 
  IF p_num_lote IS NULL THEN 
     SELECT COUNT(*) 
       INTO l_count 
       FROM estoque_lote 
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL
        AND cod_local     =   p_cod_local
        AND ies_situa_qtd =   p_ies_situa
  ELSE
     SELECT COUNT(*) 
       INTO l_count 
       FROM estoque_lote 
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_num_lote
        AND cod_local     =   p_cod_local
        AND ies_situa_qtd =   p_ies_situa
  END IF 

  IF l_count > 0 THEN 
   IF p_num_lote IS NULL THEN 
     UPDATE estoque_lote  SET  qtd_saldo = qtd_saldo + p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL 
        AND cod_local     =   p_cod_local
        AND ies_situa_qtd =   p_ies_situa
   ELSE
     UPDATE estoque_lote  SET  qtd_saldo = qtd_saldo + p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_num_lote 
        AND cod_local     =   p_cod_local
        AND ies_situa_qtd =   p_ies_situa
   END IF      
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("UPDATE 3","ESTOQUE_LOTE")
        RETURN FALSE                   
     END IF                            
  ELSE
     INSERT INTO estoque_lote (cod_empresa,
                               cod_item,
                               cod_local,
                               num_lote,
                               ies_situa_qtd,
                               qtd_saldo) 
                       VALUES (p_estt.cod_empresa,
                               p_estt.cod_item,
                               p_cod_local,
                               p_num_lote,
                               p_ies_situa,
                               p_estte.qtd_movto)
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("INSERT 3","ESTOQUE_LOTE")
        RETURN FALSE                   
     END IF                            
  END IF 

  LET l_count = 0 
  IF p_num_lote IS NULL THEN 
    SELECT COUNT(*) 
      INTO l_count 
      FROM estoque_lote_ender 
     WHERE cod_empresa   =   p_estt.cod_empresa
       AND cod_item      =   p_estt.cod_item
       AND num_lote      IS NULL
       AND cod_local     =   p_cod_local 
       AND ies_situa_qtd =   p_ies_situa
       AND comprimento   =   p_estte.comprimento
       AND largura       =   p_estte.largura
       AND altura        =   p_estte.altura
       AND diametro      =   p_estte.diametro
  ELSE
    SELECT COUNT(*) 
      INTO l_count 
      FROM estoque_lote_ender 
     WHERE cod_empresa   =   p_estt.cod_empresa
       AND cod_item      =   p_estt.cod_item
       AND num_lote      =   p_num_lote  
       AND cod_local     =   p_cod_local 
       AND ies_situa_qtd =   p_ies_situa
       AND comprimento   =   p_estte.comprimento
       AND largura       =   p_estte.largura
       AND altura        =   p_estte.altura
       AND diametro      =   p_estte.diametro
  END IF
  
  IF l_count > 0 THEN 
   IF p_num_lote IS NULL THEN 
     UPDATE estoque_lote_ender  SET  qtd_saldo = qtd_saldo + p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL
        AND cod_local     =   p_cod_local 
        AND ies_situa_qtd =   p_ies_situa
        AND comprimento   =   p_estte.comprimento
        AND largura       =   p_estte.largura
        AND altura        =   p_estte.altura
        AND diametro      =   p_estte.diametro
   ELSE
     UPDATE estoque_lote_ender  SET  qtd_saldo = qtd_saldo + p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_num_lote 
        AND cod_local     =   p_cod_local 
        AND ies_situa_qtd =   p_ies_situa
        AND comprimento   =   p_estte.comprimento
        AND largura       =   p_estte.largura
        AND altura        =   p_estte.altura
        AND diametro      =   p_estte.diametro
   END IF
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("UPDATE 3","ESTOQUE_LOTE_ENDER")
        RETURN FALSE                   
     END IF                            
  ELSE
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
         VALUES  (p_estt.cod_empresa,
                  p_estt.cod_item,
                  p_cod_local,
                  p_num_lote,
                  p_estte.endereco_origem,
                  p_estte.num_volume,
                  p_estte.cod_grade_1,
                  p_estte.cod_grade_2,
                  p_estte.cod_grade_3,
                  p_estte.cod_grade_4,
                  p_estte.cod_grade_5,
                  p_estte.dat_hor_prod_ini,
                  p_estte.num_ped_ven,
                  p_estte.num_seq_ped_ven,
                  p_ies_situa,
                  p_estte.qtd_movto,
                  ' ',
                  p_estte.dat_hor_validade,
                  p_estte.num_peca,
                  p_estte.num_serie,
                  p_estte.comprimento,
                  p_estte.largura,
                  p_estte.altura,
                  p_estte.diametro,
                  p_estte.dat_hor_reserv_1,
                  p_estte.dat_hor_reserv_2,
                  p_estte.dat_hor_reserv_3,
                  p_estte.qtd_reserv_1,
                  p_estte.qtd_reserv_2,
                  p_estte.qtd_reserv_3,
                  p_estte.num_reserv_1,
                  p_estte.num_reserv_2,
                  p_estte.num_reserv_3,
                  p_estte.tex_reservado)
      IF STATUS <> 0 THEN               
        CALL log003_err_sql("INSERT 3","ESTOQUE_LOTE_ENDER")
        RETURN FALSE                   
      END IF                            
  END IF 

  RETURN TRUE
                             
END FUNCTION

#--------------------------------#
 FUNCTION pol0821_subtrai_transf()
#--------------------------------#
  DEFINE  l_count   INTEGER 
  
LET l_count = 0 
LET p_qtd_movto = (p_estte.qtd_movto*-1)
IF p_num_lote IS NULL THEN 
  SELECT COUNT(*) 
    INTO l_count 
    FROM estoque_lote 
   WHERE cod_empresa   =   p_estt.cod_empresa
     AND cod_item      =   p_estt.cod_item
     AND num_lote      IS NULL
     AND cod_local     =   p_cod_local          
     AND ies_situa_qtd =   p_ies_situa          
ELSE
  SELECT COUNT(*) 
    INTO l_count 
    FROM estoque_lote 
   WHERE cod_empresa   =   p_estt.cod_empresa
     AND cod_item      =   p_estt.cod_item
     AND num_lote      =   p_num_lote           
     AND cod_local     =   p_cod_local          
     AND ies_situa_qtd =   p_ies_situa          
END IF 
  IF l_count > 0 THEN 
   IF p_num_lote IS NULL THEN 
     UPDATE estoque_lote  SET  qtd_saldo = qtd_saldo - p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL 
        AND cod_local     =   p_cod_local          
        AND ies_situa_qtd =   p_ies_situa          
   ELSE
     UPDATE estoque_lote  SET  qtd_saldo = qtd_saldo - p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_num_lote           
        AND cod_local     =   p_cod_local          
        AND ies_situa_qtd =   p_ies_situa          
   END IF 
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("UPDATE 4","ESTOQUE_LOTE")
        RETURN FALSE                   
     END IF  
  ELSE
     INSERT INTO estoque_lote (cod_empresa,
                               cod_item,
                               cod_local,
                               num_lote,
                               ies_situa_qtd,
                               qtd_saldo) 
                       VALUES (p_estt.cod_empresa,
                               p_estt.cod_item,
                               p_cod_local,
                               p_num_lote,
                               p_ies_situa,
                               p_qtd_movto)
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("INSERT 4","ESTOQUE_LOTE")
        RETURN FALSE                   
     END IF  
  END IF 

  LET l_count = 0 
IF p_num_lote IS NULL THEN 
  SELECT COUNT(*) 
    INTO l_count 
    FROM estoque_lote_ender 
   WHERE cod_empresa   =   p_estt.cod_empresa
     AND cod_item      =   p_estt.cod_item
     AND num_lote      IS NULL
     AND cod_local     =   p_cod_local          
     AND ies_situa_qtd =   p_ies_situa          
     AND comprimento   =   p_estte.comprimento
     AND largura       =   p_estte.largura
     AND altura        =   p_estte.altura
     AND diametro      =   p_estte.diametro
ELSE
  SELECT COUNT(*) 
    INTO l_count 
    FROM estoque_lote_ender 
   WHERE cod_empresa   =   p_estt.cod_empresa
     AND cod_item      =   p_estt.cod_item
     AND num_lote      =   p_num_lote           
     AND cod_local     =   p_cod_local          
     AND ies_situa_qtd =   p_ies_situa          
     AND comprimento   =   p_estte.comprimento
     AND largura       =   p_estte.largura
     AND altura        =   p_estte.altura
     AND diametro      =   p_estte.diametro
END IF 
  IF l_count > 0 THEN 
   IF p_num_lote IS NULL THEN
     UPDATE estoque_lote_ender  SET  qtd_saldo = qtd_saldo - p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      IS NULL
        AND cod_local     =   p_cod_local          
        AND ies_situa_qtd =   p_ies_situa          
        AND comprimento   =   p_estte.comprimento
        AND largura       =   p_estte.largura
        AND altura        =   p_estte.altura
        AND diametro      =   p_estte.diametro
   ELSE 
     UPDATE estoque_lote_ender  SET  qtd_saldo = qtd_saldo - p_estte.qtd_movto
      WHERE cod_empresa   =   p_estt.cod_empresa
        AND cod_item      =   p_estt.cod_item
        AND num_lote      =   p_num_lote           
        AND cod_local     =   p_cod_local          
        AND ies_situa_qtd =   p_ies_situa          
        AND comprimento   =   p_estte.comprimento
        AND largura       =   p_estte.largura
        AND altura        =   p_estte.altura
        AND diametro      =   p_estte.diametro
   END IF
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("UPDATE 4","ESTOQUE_LOTE")
        RETURN FALSE                   
     END IF  
  ELSE
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
         VALUES  (p_estt.cod_empresa,
                  p_estt.cod_item,
                  p_cod_local,
                  p_num_lote,
                  p_estte.endereco_origem,
                  p_estte.num_volume,
                  p_estte.cod_grade_1,
                  p_estte.cod_grade_2,
                  p_estte.cod_grade_3,
                  p_estte.cod_grade_4,
                  p_estte.cod_grade_5,
                  p_estte.dat_hor_prod_ini,
                  p_estte.num_ped_ven,
                  p_estte.num_seq_ped_ven,
                  p_ies_situa,
                  p_qtd_movto,
                  ' ',
                  p_estte.dat_hor_validade,
                  p_estte.num_peca,
                  p_estte.num_serie,
                  p_estte.comprimento,
                  p_estte.largura,
                  p_estte.altura,
                  p_estte.diametro,
                  p_estte.dat_hor_reserv_1,
                  p_estte.dat_hor_reserv_2,
                  p_estte.dat_hor_reserv_3,
                  p_estte.qtd_reserv_1,
                  p_estte.qtd_reserv_2,
                  p_estte.qtd_reserv_3,
                  p_estte.num_reserv_1,
                  p_estte.num_reserv_2,
                  p_estte.num_reserv_3,
                  p_estte.tex_reservado)
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("INSERT 4","ESTOQUE_LOTE_ENDER")
        RETURN FALSE                   
     END IF  
  END IF 
  
  RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol0821_mov_est()
#--------------------------#
  DEFINE  l_count   INTEGER 
  
  LET l_count = 0 
  
  SELECT COUNT(*) 
    INTO l_count 
    FROM estoque 
   WHERE cod_empresa =   p_estt.cod_empresa
     AND cod_item    =   p_estt.cod_item
  IF l_count > 0 THEN 
     IF pol0821_atualiza_est() THEN
     ELSE
        RETURN FALSE
     END IF 
  ELSE
     IF pol0821_insere_est() THEN
     ELSE
        RETURN FALSE
     END IF 
  END IF             

  RETURN TRUE 

END FUNCTION

#-----------------------------#
 FUNCTION pol0821_mov_est_rev()
#-----------------------------#
  DEFINE  l_count   INTEGER 
  
  LET l_count = 0 
  
  SELECT COUNT(*) 
    INTO l_count 
    FROM estoque 
   WHERE cod_empresa =   p_estt.cod_empresa
     AND cod_item    =   p_estt.cod_item
  IF l_count > 0 THEN 
     IF pol0821_atualiza_est_rev() THEN
     ELSE
        RETURN FALSE
     END IF 
  ELSE
     IF pol0821_insere_est_rev() THEN
     ELSE
        RETURN FALSE
     END IF 
  END IF             

  RETURN TRUE 

END FUNCTION

#-----------------------------#
 FUNCTION pol0821_atualiza_est()
#-----------------------------#
## --  saida   
 IF p_estt.ies_sit_est_orig = 'L' THEN 
    UPDATE estoque SET  qtd_liberada = qtd_liberada - p_estte.qtd_movto
     WHERE cod_empresa =   p_estt.cod_empresa
       AND cod_item    =   p_estt.cod_item
    IF STATUS <> 0 THEN               
       CALL log003_err_sql("UPDATE 5","ESTOQUE lib")
       RETURN FALSE                   
    END IF  
 ELSE
    IF p_estt.ies_sit_est_orig = 'I' THEN
       UPDATE estoque SET  qtd_impedida = qtd_impedida - p_estte.qtd_movto
        WHERE cod_empresa =   p_estt.cod_empresa
          AND cod_item    =   p_estt.cod_item
       IF STATUS <> 0 THEN               
          CALL log003_err_sql("UPDATE 5","ESTOQUE imp")
          RETURN FALSE                   
       END IF  
    ELSE 
       IF p_estt.ies_sit_est_orig = 'R' THEN
          UPDATE estoque SET  qtd_rejeitada = qtd_rejeitada - p_estte.qtd_movto
           WHERE cod_empresa =   p_estt.cod_empresa
             AND cod_item    =   p_estt.cod_item
          IF STATUS <> 0 THEN               
             CALL log003_err_sql("UPDATE 5","ESTOQUE rej")
             RETURN FALSE                   
          END IF  
       ELSE      
          UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep - p_estte.qtd_movto
           WHERE cod_empresa =   p_estt.cod_empresa
             AND cod_item    =   p_estt.cod_item
          IF STATUS <> 0 THEN               
             CALL log003_err_sql("UPDATE 5","ESTOQUE exp")
             RETURN FALSE                   
          END IF  
       END IF
    END IF
 END IF  
                          
#--  entrada
 IF p_estt.ies_sit_est_dest = 'L' THEN 
    UPDATE estoque SET  qtd_liberada = qtd_liberada + p_estte.qtd_movto
     WHERE cod_empresa =   p_estt.cod_empresa
       AND cod_item    =   p_estt.cod_item
    IF STATUS <> 0 THEN               
       CALL log003_err_sql("UPDATE 6","ESTOQUE lib")
       RETURN FALSE                   
    END IF  
 ELSE
    IF p_estt.ies_sit_est_dest = 'I' THEN
       UPDATE estoque SET  qtd_impedida = qtd_impedida + p_estte.qtd_movto
        WHERE cod_empresa =   p_estt.cod_empresa
          AND cod_item    =   p_estt.cod_item
       IF STATUS <> 0 THEN               
          CALL log003_err_sql("UPDATE 6","ESTOQUE imp")
          RETURN FALSE                   
       END IF  
    ELSE 
       IF p_estt.ies_sit_est_dest = 'R' THEN
          UPDATE estoque SET  qtd_rejeitada = qtd_rejeitada + p_estte.qtd_movto
           WHERE cod_empresa =   p_estt.cod_empresa
             AND cod_item    =   p_estt.cod_item
          IF STATUS <> 0 THEN               
             CALL log003_err_sql("UPDATE 6","ESTOQUE rej")
             RETURN FALSE                   
          END IF  
       ELSE      
          UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep + p_estte.qtd_movto
           WHERE cod_empresa =   p_estt.cod_empresa
             AND cod_item    =   p_estt.cod_item
          IF STATUS <> 0 THEN               
             CALL log003_err_sql("UPDATE 6","ESTOQUE exp")
             RETURN FALSE                   
          END IF  
       END IF
    END IF
 END IF    
                            
 RETURN TRUE   
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0821_insere_est()
#-----------------------------#
DEFINE l_count  INTEGER
## -- saida
  LET p_qtd_movto = (p_estte.qtd_movto*-1)
  IF p_estt.ies_sit_est_orig = 'L' THEN 
     INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                 p_estt.cod_item,
                                 p_qtd_movto,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 '',
                                 TODAY,
                                 TODAY)
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("INSERT 5","ESTOQUE lib")
        RETURN FALSE                   
     END IF  
  ELSE
     IF p_estt.ies_sit_est_orig = 'I' THEN
        INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                    p_estt.cod_item,
                                    0,
                                    p_qtd_movto,
                                    0,
                                    0,
                                    0,
                                    0,
                                    '',
                                    TODAY,
                                    TODAY)
       IF STATUS <> 0 THEN               
          CALL log003_err_sql("INSERT 5","ESTOQUE imp")
          RETURN FALSE                   
       END IF  
     ELSE
        IF p_estt.ies_sit_est_orig = 'R' THEN
           INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                       p_estt.cod_item,
                                       0,
                                       0,
                                       p_qtd_movto,
                                       0,
                                       0,
                                       0,
                                       '',
                                       TODAY,
                                       TODAY)
           IF STATUS <> 0 THEN               
              CALL log003_err_sql("INSERT 5","ESTOQUE rej")
              RETURN FALSE                   
           END IF  
        ELSE
           INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                       p_estt.cod_item,
                                       0,
                                       0,
                                       0,
                                       p_qtd_movto,
                                       0,
                                       0,
                                       '',
                                       TODAY,
                                       TODAY)
           IF STATUS <> 0 THEN               
              CALL log003_err_sql("INSERT 5","ESTOQUE exp")
              RETURN FALSE                   
           END IF  
        END IF 
     END IF                                
  END IF              
  
###--- entradas  
  LET l_count = 0 
  
  SELECT COUNT(*) 
    INTO l_count 
    FROM estoque 
   WHERE cod_empresa =   p_estt.cod_empresa
     AND cod_item    =   p_estt.cod_item
  IF l_count > 0 THEN 
     IF p_estt.ies_sit_est_dest = 'L' THEN 
        UPDATE estoque SET  qtd_liberada = qtd_liberada + p_estte.qtd_movto
         WHERE cod_empresa =   p_estt.cod_empresa
           AND cod_item    =   p_estt.cod_item
        IF STATUS <> 0 THEN               
           CALL log003_err_sql("UPDATE 6","ESTOQUE lib")
           RETURN FALSE                   
        END IF  
     ELSE
        IF p_estt.ies_sit_est_dest = 'I' THEN
           UPDATE estoque SET  qtd_impedida = qtd_impedida + p_estte.qtd_movto
            WHERE cod_empresa =   p_estt.cod_empresa
              AND cod_item    =   p_estt.cod_item
           IF STATUS <> 0 THEN               
              CALL log003_err_sql("UPDATE 6","ESTOQUE imp")
              RETURN FALSE                   
           END IF  
        ELSE 
           IF p_estt.ies_sit_est_dest = 'R' THEN
              UPDATE estoque SET  qtd_rejeitada = qtd_rejeitada + p_estte.qtd_movto
               WHERE cod_empresa =   p_estt.cod_empresa
                 AND cod_item    =   p_estt.cod_item
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("UPDATE 6","ESTOQUE rej")
                 RETURN FALSE                   
              END IF  
           ELSE      
              UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep + p_estte.qtd_movto
               WHERE cod_empresa =   p_estt.cod_empresa
                 AND cod_item    =   p_estt.cod_item
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("UPDATE 6","ESTOQUE exp")
                 RETURN FALSE                   
              END IF  
           END IF
        END IF
     END IF    
  ELSE                     
     IF p_estt.ies_sit_est_dest = 'L' THEN 
        INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                    p_estt.cod_item,
                                    p_estte.qtd_movto,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    '',
                                    TODAY,
                                    TODAY)
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("INSERT 6","ESTOQUE lib")
                 RETURN FALSE                   
              END IF  
     ELSE
        IF p_estt.ies_sit_est_dest = 'I' THEN
           INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                       p_estt.cod_item,
                                       0,
                                       p_estte.qtd_movto,
                                       0,
                                       0,
                                       0,
                                       0,
                                       '',
                                       TODAY,
                                       TODAY)
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("INSERT 6","ESTOQUE imp")
                 RETURN FALSE                   
              END IF  
        ELSE
           IF p_estt.ies_sit_est_dest = 'R' THEN
              INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                          p_estt.cod_item,
                                          0,
                                          0,
                                          p_estte.qtd_movto,
                                          0,
                                          0,
                                          0,
                                          '',
                                          TODAY,
                                          TODAY)
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("INSERT 6","ESTOQUE rej")
                 RETURN FALSE                   
              END IF  
           ELSE
              INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                          p_estt.cod_item,
                                          0,
                                          0,
                                          0,
                                          p_estte.qtd_movto,
                                          0,
                                          0,
                                          '',
                                          TODAY,
                                          TODAY)
              IF STATUS <> 0 THEN               
                 CALL log003_err_sql("INSERT 6","ESTOQUE exp")
                 RETURN FALSE                   
              END IF  
           END IF 
        END IF                                
     END IF                                
  END IF    
     
  RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol0821_atualiza_est_rev()
#----------------------------------#
## --  saida reversao   
 IF p_estt.ies_sit_est_orig = 'L' THEN 
    UPDATE estoque SET  qtd_liberada = qtd_liberada + p_estte.qtd_movto
     WHERE cod_empresa =   p_estt.cod_empresa
       AND cod_item    =   p_estt.cod_item
    IF STATUS <> 0 THEN               
       CALL log003_err_sql("UPDATE 7","ESTOQUE lib")
       RETURN FALSE                   
    END IF  
 ELSE
    IF p_estt.ies_sit_est_orig = 'I' THEN
       UPDATE estoque SET  qtd_impedida = qtd_impedida + p_estte.qtd_movto
        WHERE cod_empresa =   p_estt.cod_empresa
          AND cod_item    =   p_estt.cod_item
       IF STATUS <> 0 THEN               
          CALL log003_err_sql("UPDATE 7","ESTOQUE imp")
          RETURN FALSE                   
       END IF  
    ELSE 
       IF p_estt.ies_sit_est_orig = 'R' THEN
          UPDATE estoque SET  qtd_rejeitada = qtd_rejeitada + p_estte.qtd_movto
           WHERE cod_empresa =   p_estt.cod_empresa
             AND cod_item    =   p_estt.cod_item
          IF STATUS <> 0 THEN               
             CALL log003_err_sql("UPDATE 7","ESTOQUE rej")
             RETURN FALSE                   
          END IF  
       ELSE      
          UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep + p_estte.qtd_movto
           WHERE cod_empresa =   p_estt.cod_empresa
             AND cod_item    =   p_estt.cod_item
          IF STATUS <> 0 THEN               
             CALL log003_err_sql("UPDATE 7","ESTOQUE exp")
             RETURN FALSE                   
          END IF  
       END IF
    END IF
 END IF                           

## --  entrada reversao
 IF p_estt.ies_sit_est_dest = 'L' THEN 
    UPDATE estoque SET  qtd_liberada = qtd_liberada - p_estte.qtd_movto
     WHERE cod_empresa =   p_estt.cod_empresa
       AND cod_item    =   p_estt.cod_item
    IF STATUS <> 0 THEN               
       CALL log003_err_sql("UPDATE 8","ESTOQUE lib")
       RETURN FALSE                   
    END IF  
 ELSE
    IF p_estt.ies_sit_est_dest = 'I' THEN
       UPDATE estoque SET  qtd_impedida = qtd_impedida - p_estte.qtd_movto
        WHERE cod_empresa =   p_estt.cod_empresa
          AND cod_item    =   p_estt.cod_item
       IF STATUS <> 0 THEN               
          CALL log003_err_sql("UPDATE 8","ESTOQUE imp")
          RETURN FALSE                   
       END IF  
    ELSE 
       IF p_estt.ies_sit_est_dest = 'R' THEN
          UPDATE estoque SET  qtd_rejeitada = qtd_rejeitada - p_estte.qtd_movto
           WHERE cod_empresa =   p_estt.cod_empresa
             AND cod_item    =   p_estt.cod_item
          IF STATUS <> 0 THEN               
             CALL log003_err_sql("UPDATE 8","ESTOQUE rej")
             RETURN FALSE                   
          END IF  
       ELSE      
          UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep - p_estte.qtd_movto
           WHERE cod_empresa =   p_estt.cod_empresa
             AND cod_item    =   p_estt.cod_item
          IF STATUS <> 0 THEN               
             CALL log003_err_sql("UPDATE 8","ESTOQUE exp")
             RETURN FALSE                   
          END IF  
       END IF
    END IF
 END IF                           

 RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol0821_insere_est_rev()
#--------------------------------#
DEFINE   l_count   INTEGER
## -- saida reversao
IF p_estt.ies_sit_est_orig = 'L' THEN 
   INSERT INTO estoque VALUES (p_estt.cod_empresa,
                               p_estt.cod_item,
                               p_estte.qtd_movto,
                               0,
                               0,
                               0,
                               0,
                               0,
                               '',
                               TODAY,
                               TODAY)
   IF STATUS <> 0 THEN               
      CALL log003_err_sql("INSERT 7","ESTOQUE lib")
      RETURN FALSE                   
   END IF  
ELSE
   IF p_estt.ies_sit_est_orig = 'I' THEN
      INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                  p_estt.cod_item,
                                  0,
                                  p_estte.qtd_movto,
                                  0,
                                  0,
                                  0,
                                  0,
                                  '',
                                  TODAY,
                                  TODAY)
     IF STATUS <> 0 THEN               
        CALL log003_err_sql("INSERT 7","ESTOQUE imp")
        RETURN FALSE                   
     END IF  
   ELSE
      IF p_estt.ies_sit_est_orig = 'R' THEN
         INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                     p_estt.cod_item,
                                     0,
                                     0,
                                     p_estte.qtd_movto,
                                     0,
                                     0,
                                     0,
                                     '',
                                     TODAY,
                                     TODAY)
         IF STATUS <> 0 THEN               
            CALL log003_err_sql("INSERT 7","ESTOQUE rej")
            RETURN FALSE                   
         END IF  
      ELSE
         INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                     p_estt.cod_item,
                                     0,
                                     0,
                                     0,
                                     p_estte.qtd_movto,
                                     0,
                                     0,
                                     '',
                                     TODAY,
                                     TODAY)
         IF STATUS <> 0 THEN               
            CALL log003_err_sql("INSERT 7","ESTOQUE exp")
            RETURN FALSE                   
         END IF  
      END IF 
   END IF                                
END IF                                

### --- entradas reversao 
 
LET l_count = 0 
LET p_qtd_movto = (p_estte.qtd_movto*-1)
SELECT COUNT(*) 
  INTO l_count 
  FROM estoque 
 WHERE cod_empresa =   p_estt.cod_empresa
   AND cod_item    =   p_estt.cod_item
IF l_count > 0 THEN 
   IF p_estt.ies_sit_est_dest = 'L' THEN 
      UPDATE estoque SET  qtd_liberada = qtd_liberada - p_estte.qtd_movto
       WHERE cod_empresa =   p_estt.cod_empresa
         AND cod_item    =   p_estt.cod_item
      IF STATUS <> 0 THEN               
         CALL log003_err_sql("UPDATE 8","ESTOQUE lib")
         RETURN FALSE                   
      END IF  
   ELSE
      IF p_estt.ies_sit_est_dest = 'I' THEN
         UPDATE estoque SET  qtd_impedida = qtd_impedida - p_estte.qtd_movto
          WHERE cod_empresa =   p_estt.cod_empresa
            AND cod_item    =   p_estt.cod_item
         IF STATUS <> 0 THEN               
            CALL log003_err_sql("UPDATE 8","ESTOQUE imp")
            RETURN FALSE                   
         END IF  
      ELSE 
         IF p_estt.ies_sit_est_dest = 'R' THEN
            UPDATE estoque SET  qtd_rejeitada = qtd_rejeitada - p_estte.qtd_movto
             WHERE cod_empresa =   p_estt.cod_empresa
               AND cod_item    =   p_estt.cod_item
            IF STATUS <> 0 THEN               
               CALL log003_err_sql("UPDATE 8","ESTOQUE rej")
               RETURN FALSE                   
            END IF  
         ELSE      
            UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep - p_estte.qtd_movto
             WHERE cod_empresa =   p_estt.cod_empresa
               AND cod_item    =   p_estt.cod_item
            IF STATUS <> 0 THEN               
               CALL log003_err_sql("UPDATE 8","ESTOQUE exp")
               RETURN FALSE                   
            END IF  
         END IF
      END IF
   END IF                           
ELSE
   IF p_estt.ies_sit_est_dest = 'L' THEN 
      INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                  p_estt.cod_item,
                                  p_qtd_movto,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  '',
                                  TODAY,
                                  TODAY)
      IF STATUS <> 0 THEN               
         CALL log003_err_sql("INSERT 8","ESTOQUE lib")
         RETURN FALSE                   
      END IF  
   ELSE         
      IF p_estt.ies_sit_est_dest = 'I' THEN
         INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                     p_estt.cod_item,
                                     0,
                                     p_qtd_movto,
                                     0,
                                     0,
                                     0,
                                     0,
                                     '',
                                     TODAY,
                                     TODAY)
        IF STATUS <> 0 THEN               
           CALL log003_err_sql("INSERT 8","ESTOQUE imp")
           RETURN FALSE                   
        END IF  
      ELSE
         IF p_estt.ies_sit_est_dest = 'R' THEN
            INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                        p_estt.cod_item,
                                        0,
                                        0,
                                        p_qtd_movto,
                                        0,
                                        0,
                                        0,
                                        '',
                                        TODAY,
                                        TODAY)
            IF STATUS <> 0 THEN               
               CALL log003_err_sql("INSERT 8","ESTOQUE rej")
               RETURN FALSE                   
            END IF  
         ELSE
            INSERT INTO estoque VALUES (p_estt.cod_empresa,
                                        p_estt.cod_item,
                                        0,
                                        0,
                                        0,
                                        p_qtd_movto,
                                        0,
                                        0,
                                        '',
                                        TODAY,
                                        TODAY)
            IF STATUS <> 0 THEN               
               CALL log003_err_sql("INSERT 8","ESTOQUE exp")
               RETURN FALSE                   
            END IF  
         END IF 
      END IF                                
   END IF                                
END IF 

RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol0821_limpa_zerados()
#--------------------------------#

ERROR 'EXCLUINDO ESTOQUES ZERADOS ESTOQUE_LOTE E ENDER'

#BEGIN WORK 
CALL log085_transacao("BEGIN")

 DELETE FROM estoque_lote 
  WHERE qtd_saldo=0
    AND cod_empresa IN ('01','O1')

 DELETE FROM estoque_lote_ender
  WHERE qtd_saldo=0
    AND cod_empresa IN ('01','O1')

ERROR 'INCLUINDO ESTOQUE ZERADO PARA ITENS SEM CONTROLE DE ESTOQUE'

 DECLARE cq_itse CURSOR FOR
  SELECT cod_empresa,
         cod_item 
    FROM item
#   WHERE ies_ctr_estoque = 'N'
 FOREACH cq_itse INTO p_estt.cod_empresa,p_estt.cod_item            
 
   LET p_count = 0 
   SELECT COUNT(*)
     INTO p_count
     FROM estoque 
    WHERE cod_empresa =  p_estt.cod_empresa
      AND cod_item    =      p_estt.cod_item           
   IF p_count > 0 THEN 
      CONTINUE FOREACH
   END IF    

   DISPLAY "      " AT 9,7
   DISPLAY "Item " AT 7,7
   DISPLAY p_estoque_lote.cod_item AT 7,12
   DISPLAY "      " AT 8,7
      
   INSERT INTO estoque VALUES (p_estt.cod_empresa,
                               p_estt.cod_item,
                               0,
                               0,
                               0,
                               0,
                               0,
                               0,
                               '',
                               TODAY,
                               TODAY)
   IF STATUS <> 0 THEN               
      CALL log003_err_sql("INSERT 8","ESTOQUE exp")
      RETURN FALSE                   
   END IF       
 END FOREACH 

#COMMIT WORK     
CALL log085_transacao("COMMIT")

RETURN TRUE 

END FUNCTION

#--------------------------------#
 FUNCTION pol0821_zera_negativos()
#--------------------------------#
DEFINE l_num_ordem     LIKE ordens.num_ordem,
       l_dat_movto     LIKE estoque_trans.dat_movto

ERROR 'ZERANDO ESTOQUES NEGATIVOS APOM'

#BEGIN WORK 
CALL log085_transacao("BEGIN")
       
DECLARE cq_eneg CURSOR FOR
 SELECT * 
   FROM estoque_lote
  WHERE qtd_saldo < 0 
FOREACH cq_eneg INTO p_estoque_lote.*
   DISPLAY "      " AT 9,7
   DISPLAY "Item " AT 7,7
   DISPLAY p_estoque_lote.cod_item AT 7,12
   DISPLAY "      " AT 8,7

   SELECT num_ordem,
          dat_liberac
     INTO l_num_ordem,
          l_dat_movto
     FROM ordens 
    WHERE cod_empresa = p_estoque_lote.cod_empresa
      AND num_docum   = p_estoque_lote.num_lote
      AND cod_item    = p_estoque_lote.cod_item
      
   LET p_qtd_movto =  p_estoque_lote.qtd_saldo * -1
   IF p_estoque_lote.ies_situa_qtd = 'L' THEN
      UPDATE estoque SET qtd_liberada = qtd_liberada + p_qtd_movto
       WHERE cod_empresa = p_estoque_lote.cod_empresa
         AND cod_item    = p_estoque_lote.cod_item
      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDATE N","ESTOQUE LIB")
         RETURN FALSE
      END IF
   ELSE
      IF p_estoque_lote.ies_situa_qtd = 'I' THEN
         UPDATE estoque SET  qtd_impedida = qtd_impedida + p_qtd_movto
          WHERE cod_empresa = p_estoque_lote.cod_empresa
            AND cod_item    = p_estoque_lote.cod_item
         IF STATUS <> 0 THEN
            CALL log003_err_sql("UPDATE N","ESTOQUE IMP")
            RETURN FALSE
         END IF
      ELSE 
         IF p_estoque_lote.ies_situa_qtd = 'R' THEN
            UPDATE estoque SET  qtd_rejeitada = qtd_rejeitada + p_qtd_movto
             WHERE cod_empresa = p_estoque_lote.cod_empresa
               AND cod_item    = p_estoque_lote.cod_item
            IF STATUS <> 0 THEN
               CALL log003_err_sql("UPDATE N","ESTOQUE REJ")
               RETURN FALSE
            END IF
         ELSE      
            UPDATE estoque SET  qtd_lib_excep = qtd_lib_excep + p_qtd_movto
             WHERE cod_empresa = p_estoque_lote.cod_empresa
               AND cod_item    = p_estoque_lote.cod_item
            IF STATUS <> 0 THEN
               CALL log003_err_sql("UPDATE N","ESTOQUE EXC")
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF            
   
   UPDATE estoque_lote_ender 
      SET qtd_saldo = 0
    WHERE cod_empresa   = p_estoque_lote.cod_empresa
      AND cod_item      = p_estoque_lote.cod_item
      AND num_lote      = p_estoque_lote.num_lote
      AND ies_situa_qtd = p_estoque_lote.ies_situa_qtd

   INITIALIZE p_estoque_trans.* TO NULL

   LET p_estoque_trans.cod_empresa          =  p_estoque_lote.cod_empresa                        
   LET p_estoque_trans.cod_item             =  p_estoque_lote.cod_item                        
   LET p_estoque_trans.dat_movto            =  l_dat_movto                       
   LET p_estoque_trans.dat_ref_moeda_fort   =  l_dat_movto                       
   LET p_estoque_trans.cod_operacao         =  'APOM'                       
   LET p_estoque_trans.num_docum            =  l_num_ordem
   LET p_estoque_trans.ies_tip_movto        =  'N'
   LET p_estoque_trans.qtd_movto            =  p_qtd_movto
   LET p_estoque_trans.cus_unit_movto_p     =  0
   LET p_estoque_trans.cus_tot_movto_p      =  0
   LET p_estoque_trans.cus_unit_movto_f     =  0
   LET p_estoque_trans.cus_tot_movto_f      =  0
   LET p_estoque_trans.num_conta            =  '3.01.10.25.02'
   LET p_estoque_trans.cod_local_est_dest   =  'PRODUCAO'
   LET p_estoque_trans.num_lote_dest        =  p_estoque_lote.num_lote
   LET p_estoque_trans.ies_sit_est_dest     =  p_estoque_lote.ies_situa_qtd
   LET p_estoque_trans.nom_usuario          =  p_user
   LET p_estoque_trans.dat_proces           =  TODAY
   LET p_estoque_trans.hor_operac           =  '00:00:00'
   LET p_estoque_trans.num_prog             =  'POL0821'
          
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
      CALL log003_err_sql("INSERT N","ESTOQUE_TRANS ")
      RETURN FALSE
   END IF
   
   LET p_num_tran_at =  SQLCA.SQLERRD[2]
   
   LET p_estte.cod_empresa             = p_estoque_lote.cod_empresa       
   LET p_estte.num_transac             = p_num_tran_at
   LET p_estte.endereco                = ' '
   LET p_estte.num_volume              = 0
   LET p_estte.qtd_movto               = p_qtd_movto
   LET p_estte.cod_grade_1             = ' '
   LET p_estte.cod_grade_2             = ' '
   LET p_estte.cod_grade_3             = ' '
   LET p_estte.cod_grade_4             = ' '
   LET p_estte.cod_grade_5             = ' '
   LET p_estte.dat_hor_prod_ini        = '1900-01-01 00:00:00'
   LET p_estte.dat_hor_prod_fim        = '1900-01-01 00:00:00'
   LET p_estte.vlr_temperatura         = 0
   LET p_estte.endereco_origem         = ' '
   LET p_estte.num_ped_ven             = 0
   LET p_estte.num_seq_ped_ven         = 0
   LET p_estte.dat_hor_producao        = '1900-01-01 00:00:00'
   LET p_estte.dat_hor_validade        = '1900-01-01 00:00:00'
   LET p_estte.num_peca                = ' '
   LET p_estte.num_serie               = ' '
   LET p_estte.comprimento             = 0
   LET p_estte.largura                 = 0
   LET p_estte.altura                  = 0
   LET p_estte.diametro                = 0
   LET p_estte.dat_hor_reserv_1        = '1900-01-01 00:00:00'
   LET p_estte.dat_hor_reserv_2        = '1900-01-01 00:00:00'
   LET p_estte.dat_hor_reserv_3        = '1900-01-01 00:00:00'
   LET p_estte.qtd_reserv_1            = 0
   LET p_estte.qtd_reserv_2            = 0
   LET p_estte.qtd_reserv_3            = 0
   LET p_estte.num_reserv_1            = 0
   LET p_estte.num_reserv_2            = 0
   LET p_estte.num_reserv_3            = 0
   LET p_estte.tex_reservado           = ' '
   LET p_estte.cus_unit_movto_p        = 0
   LET p_estte.cus_unit_movto_f        = 0
   LET p_estte.cus_tot_movto_p         = 0
   LET p_estte.cus_tot_movto_f         = 0
   LET p_estte.cod_item                = p_estoque_lote.cod_item 
   LET p_estte.dat_movto               = l_dat_movto
   LET p_estte.cod_operacao            = 'APOM'
   LET p_estte.ies_tip_movto           = 'N'
   LET p_estte.num_prog                = 'POL0821'

   INSERT INTO estoque_trans_end VALUES (p_estte.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERT N","ESTOQUE_TRANS_END ")
      RETURN FALSE
   END IF

END FOREACH

UPDATE estoque_lote 
   SET qtd_saldo = 0
 WHERE qtd_saldo < 0 

#COMMIT WORK     
CALL log085_transacao("COMMIT")

RETURN TRUE 

END FUNCTION
