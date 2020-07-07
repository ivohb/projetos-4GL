#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1280                                                 #
# OBJETIVO: CHAMA CONSISTENCIA DE PEDIDO PARA PED WEB               #
# AUTOR...: IVO                                                     #
# DATA....: 25/02/15                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)

DEFINE g_tipo_sgbd         CHAR(003)

END GLOBALS

DEFINE m_pedido            INTEGER,
       m_status            SMALLINT

DEFINE m_sid_sessao        LIKE log_dados_sessao_logix.sid,
       m_date              LIKE log_dados_sessao_logix.dat_execucao

MAIN

   #CALL LOG_connectDatabase("DEFAULT")
   #CALL log0180_conecta_usuario()
   
   LET p_versao = 'pol1284-11.00.17'
   
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300
   DEFER INTERRUPT

  #A chamada da LOG abaixo faz com que uma janela seja
  #aberta para entrada de usuário e senha. Isso não é
  #necessário, pois esse programa é processado via chamada
  #de outros programa.

  # CALL LOG_initApp('VDPPED') RETURNING m_status

  # IF NOT m_status THEN

  CALL log0180_conecta_usuario()

  WHENEVER ERROR CONTINUE
  SET LOCK MODE TO WAIT
  WHENEVER ERROR STOP

  IF NOT LOG_connectDatabase("DEFAULT") THEN
     RETURN FALSE
  END IF

  CALL log1400_isolation()

  LET p_user       = 'admlog'
  LET p_status = 0
  LET m_sid_sessao = log0010_busca_sid()
  LET m_date       = TODAY

  INSERT INTO log_dados_sessao_logix VALUES(m_sid_sessao,m_date,'admlog','pol1284','pol1284')

  LET g_tipo_sgbd = LOG_getCurrentDBType()

  IF NUM_ARGS() > 0  THEN
     LET m_pedido = ARG_VAL(1)
     CALL pol1284_controle()
  END IF

  # ELSE
  #    CALL conout("pol1284","Não foi possível conectar o usuário.")
  # END IF

END MAIN

#--------------------------#
 FUNCTION pol1284_controle()
#--------------------------#

   DEFINE l_dat_atu DATETIME YEAR TO DAY,
          l_count    SMALLINT

   LET l_dat_atu = CURRENT


   SELECT cod_empresa
     INTO p_cod_empresa
     FROM consiste_ped5029
    WHERE num_pedido = m_pedido
   
   IF STATUS = 100 THEN
      INSERT INTO consiste_ped5029 VALUES (
       "00", m_pedido, l_dat_atu, 'N', 'S')
   ELSE
      UPDATE consiste_ped5029
         SET data_consist = l_dat_atu,
             ies_processado = 'N'
      WHERE cod_empresa = p_cod_empresa
         AND num_pedido = m_pedido
   END IF

   IF NOT pol1284_consiste() THEN
      RETURN
   END IF

   UPDATE consiste_ped5029
      SET ies_processado = 'S'
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_pedido

END FUNCTION

#--------------------------#
FUNCTION pol1284_consiste()
#--------------------------#

  IF NOT vdp20023_carga_inicial_exec_por_fora(p_cod_empresa,TRUE) THEN
     RETURN FALSE
  END IF

  CALL log085_transacao('BEGIN')

  IF NOT vdp20023_insere_pedido_exec_por_fora(m_pedido) THEN
     CALL log085_transacao('ROLLBACK')
     RETURN FALSE
  END IF

  IF NOT vdp20023_processa_consistencia_exec_por_fora('C',  #Ação: Consistência.
                                                      TRUE, #Realizar aprovação aut de pedidos em análise, se parâmetro "aprov_autom_ped_analise" estiver ativo.
                                                      FALSE, #Abrir tela com as consistências.
                                                      FALSE) THEN #Controlar transação de banco.
     CALL log085_transacao('ROLLBACK')
     RETURN FALSE
  END IF

  CALL log085_transacao('COMMIT')

# Pedidos que estão com situação "E - Em análise" não podem ser bloqueados.

#  UPDATE pedidos
#     SET ies_sit_pedido='B'
#	WHERE cod_empresa = p_cod_empresa
#     AND num_pedido  = m_pedido
#	  AND num_pedido IN (SELECT pedido
#	                       FROM vdp_ped_consis
#	                      WHERE empresa=p_cod_empresa
#		                     AND pedido = m_pedido
#			                  AND situacao in('C', 'W'))

  RETURN TRUE

 END FUNCTION

##--------------------------#
#FUNCTION pol1284_consiste()
##--------------------------#
#
#   DEFINE l_status    SMALLINT,
#          l_commit    CHAR(15)
#
#   CALL vdp90043_mr_param_set_empresa(p_cod_empresa)
#   CALL vdp90043_create_temp_tables(0)      # Antes de iniciar a transação
#
#   CALL log085_transacao('BEGIN')
#
#   CALL vdp90043_mr_param_set_usa_temp('N') # para buscar os dados já gravados na pedidos, ped_itens, etc.
#   CALL vdp90043_mr_param_set_tipo_acao('C')# Consulta
#   CALL vdp90043_mr_param_set_pedido_ini(m_pedido)
#   CALL vdp90043_mr_param_set_pedido_fim(m_pedido)
#
#   CALL vdp90043_consiste_gera_pedido(1) RETURNING l_status, l_commit
#
#   IF l_commit THEN
#      CALL log085_transacao('COMMIT')
#   ELSE
#      CALL log085_transacao('ROLLBACK')
#   END IF
#
#   insert into TT_PEDIDO_PARAM  VALUES (p_cod_empresa, m_pedido)
#
#   CALL vdp20023_atualiza_ies_sit_pedido() RETURNING l_status
#
#     UPDATE pedidos
#      SET ies_sit_pedido='B'
#	WHERE cod_empresa = p_cod_empresa
#      AND num_pedido = m_pedido
#	  and num_pedido in(SELECT  pedido FROM vdp_ped_consis
#	       where empresa=p_cod_empresa
#		     AND pedido = m_pedido
#			 and  situacao in('C', 'W'))
#
#
#END FUNCTION
