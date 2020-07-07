
#-----------------------------------------------------------#
#-------Objetivo: alterar reserva de material---------------#
#--------------------------parâmetros-----------------------#
#        um parâmetro do tipo RECORD contendo:              #
# - código da empresa, tipo caractere, tamanho 2            #
# - numero da reserva, tipo numérico inteiro                #
# - quantida da reserva atual, tipo decimal(10,3)           #
#--------------------------retorno lógico-------------------#
#             TRUE, para sucesso na operação;               #
#            FALSE, para falha na operação                  #
#-----------------------------------------------------------#

DATABASE logix

#--variáveis privadas de usi geral--#

DEFINE p_cod_empresa           CHAR(02),
       p_num_reserva           INTEGER,
       p_qtd_reservada         DECIMAL(10,3),
       p_qtd_reser_ants        DECIMAL(10,3),
       p_msg                   CHAR(300),
       p_cod_item              CHAR(15)


#-------------------------------------------#
FUNCTION func004_altera_reserva(p_parametro)#
#-------------------------------------------#

   DEFINE p_parametro      RECORD
          cod_empresa      CHAR(02),
          num_reserva      INTEGER,
          qtd_reservada    DECIMAL(10,3)
   END RECORD
   
   LET p_cod_empresa = p_parametro.cod_empresa
   LET p_num_reserva = p_parametro.num_reserva
   LET p_qtd_reservada = p_parametro.qtd_reservada

   IF p_qtd_reservada IS NULL OR p_qtd_reservada <= 0 THEN
      LET p_msg = 'Programa: FUNC004 - Mensagem de erro:\n',
                  'Valor ilegal p/ QUANTIDADE RESEVADA.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   SELECT cod_item,
          qtd_reservada
     INTO p_cod_item,
          p_qtd_reser_ants
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND num_reserva = p_num_reserva

   IF STATUS = 100 THEN
      LET p_msg = 'Programa: FUNC004\n',
                  'Mensagem de erro:\n',
                  'Reserva inexistente.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_loc_reser:func004')
         RETURN FALSE
      END IF
   END IF
      
   IF NOT func004_altera_tabelas() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION func004_altera_tabelas()#
#--------------------------------#
   
   DEFINE p_qtd_estoque  DECIMAL(10,3)

   UPDATE estoque_loc_reser
      SET qtd_reservada = p_qtd_reservada
    WHERE cod_empresa = p_cod_empresa
      AND num_reserva = p_num_reserva

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque_loc_reser:func004')
      RETURN FALSE
   END IF
   
   UPDATE ordem_montag_grade
      SET qtd_reservada = p_qtd_reservada
    WHERE cod_empresa = p_cod_empresa
      AND num_reserva = p_num_reserva

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ordem_montag_grade:func004')
      RETURN FALSE
   END IF

   UPDATE sup_resv_lote_est
      SET qtd_reservada = p_qtd_reservada
    WHERE empresa = p_cod_empresa
      AND num_trans_resv_est = p_num_reserva

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','sup_resv_lote_est:func004')
      RETURN FALSE
   END IF

   LET p_qtd_estoque = p_qtd_reservada - p_qtd_reser_ants

   UPDATE estoque
      SET qtd_reservada = qtd_reservada + p_qtd_estoque
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque:func004')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION         

#-------fim do programa----------#
