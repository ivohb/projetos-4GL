
#-----------------------------------------------------------#
#-------Objetivo: excluir reserva de material---------------#
#--------------------------parâmetros-----------------------#
#        um parâmetro do tipo RECORD contendo:              #
# - código da empresa, tipo caractere, tamenho 2            #
# - numero da reserva, tipo numérico inteiro                #
#--------------------------retorno lógico-------------------#
#             TRUE, para sucesso na operação;               #
#            FALSE, para falha na operação                  #
#-----------------------------------------------------------#

DATABASE logix

#--variáveis privadas de usi geral--#

DEFINE p_num_reserva           INTEGER,
       p_cod_empresa           CHAR(02),
       p_msg                   CHAR(300),
       p_cod_item              CHAR(15),
       p_qtd_reservada         DECIMAL(10,3)

#-------------------------------------------#
FUNCTION func003_deleta_reserva(p_parametro)#
#-------------------------------------------#

   DEFINE p_parametro      RECORD
          cod_empresa      CHAR(02),
          num_reserva      INTEGER
   END RECORD
   
   LET p_cod_empresa = p_parametro.cod_empresa
   LET p_num_reserva = p_parametro.num_reserva
   
   SELECT cod_item,
          qtd_reservada
     INTO p_cod_item,
          p_qtd_reservada
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND num_reserva = p_num_reserva

   IF STATUS = 100 THEN
      LET p_msg = 'Programa: FUNC003\n',
                  'Mensagem de erro:\n',
                  'Reserva inexistente.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_loc_reser:func003')
         RETURN FALSE
      END IF
   END IF
   
   IF NOT func003_deleta_tabelas() THEN
      RETURN FALSE
   END IF
   
   UPDATE estoque
      SET qtd_reservada = qtd_reservada - p_qtd_reservada
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque:func003')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION func003_deleta_tabelas()#
#--------------------------------#

   DELETE FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND num_reserva = p_num_reserva

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','estoque_loc_reser:func003')
      RETURN FALSE
   END IF
   
   DELETE FROM est_loc_reser_end
    WHERE cod_empresa = p_cod_empresa
      AND num_reserva = p_num_reserva

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','est_loc_reser_end:func003')
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_grade
    WHERE cod_empresa = p_cod_empresa
      AND num_reserva = p_num_reserva

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','ordem_montag_grade:func003')
      RETURN FALSE
   END IF

   DELETE FROM ldi_om_grade_compl
    WHERE empresa = p_cod_empresa
      AND reserva = p_num_reserva

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','ldi_om_grade_compl:func003')
      RETURN FALSE
   END IF

   DELETE FROM sup_resv_lote_est
    WHERE empresa = p_cod_empresa
      AND num_trans_resv_est = p_num_reserva

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','sup_resv_lote_est:func003')
      RETURN FALSE
   END IF
   
   DELETE FROM est_reser_area_lin
    WHERE cod_empresa = p_cod_empresa
      AND num_reserva = p_num_reserva

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','est_reser_area_lin:func003')
      RETURN FALSE
   END IF
      
   DELETE FROM sup_par_resv_est
    WHERE empresa = p_cod_empresa
      AND reserva = p_num_reserva

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','sup_par_resv_est:func003')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION         

#-------fim do programa----------#
