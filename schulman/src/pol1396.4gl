#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc                                #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1396                                                            #
# OBJETIVO: CONSISTÊNCIA DE PEDIDOS DE VENDA                                   #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 13/07/2020                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_versao               CHAR(18),
          comando                CHAR(080),
          m_comando              CHAR(080),
          p_caminho              CHAR(150),
          m_caminho              CHAR(150),
          g_tipo_sgbd            CHAR(003)
END GLOBALS

DEFINE    m_msg                  CHAR(150),
          m_erro                 CHAR(10),
          m_num_pedido           INTEGER,
          m_cod_cliente          CHAR(15),
          m_dat_proces           VARCHAR(19),
          m_tem_erro             SMALLINT


MAIN   

   IF NUM_ARGS() > 0  THEN
      LET p_cod_empresa = ARG_VAL(1)
      LET m_num_pedido = ARG_VAL(2)

      IF LOG_connectDatabase("DEFAULT") THEN
         CALL pol1396_proc_consistencia()
      END IF
      RETURN
   END IF
   
   CALL log0180_conecta_usuario()
   
   CALL pol1396_exibe_tela()
         
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN    
      CALL pol1396_controle()
   END IF

   CLOSE WINDOW w_pol1396
         
END MAIN

#----------------------------#
FUNCTION pol1396_exibe_tela()#
#----------------------------#
   
   DEFINE l_nom_tela  CHAR(200)
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 60

   LET p_versao = "pol1396-12.00.00  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE l_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1396") RETURNING l_nom_tela
   LET l_nom_tela = l_nom_tela CLIPPED 
   OPEN WINDOW w_pol1396 AT 3,05 WITH FORM l_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET m_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)
   LET m_tem_erro = FALSE
   
END FUNCTION

#------------------------------#
FUNCTION pol1396_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user

   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   LET m_msg = ''
   
   IF p_cod_empresa IS NULL THEN
      LET m_msg = '- Empresa não enviada;'
   END IF

   IF p_user IS NULL THEN
      LET m_msg = m_msg CLIPPED, ' - Usuário não enviado;'
   END IF      
   
   CALL pol1396_exibe_tela()
   CALL pol1396_consiste() RETURNING p_status   
   CLOSE WINDOW w_pol1396
   
   RETURN p_status
   
END FUNCTION   

#--------------------------#
FUNCTION pol1396_controle()#
#--------------------------#

   MENU "OPCAO"
      COMMAND "Processar" "Processa a consistência de pedidos"
         CALL pol1396_consiste() RETURNING p_status
         
         IF NOT p_status THEN
            ERROR 'Operação cancelada.'
         ELSE
            ERROR 'Operação efetuada com sucesso.'
         END IF         
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0440_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
   
END FUNCTION

#--------------------------#
FUNCTION pol1396_consiste()#
#--------------------------#

   IF NOT log0150_verifica_se_tabela_existe("erro_consite_pedidos") THEN 
      IF NOT pol1396_cria_tab_erro() THEN
         RETURN FALSE
      END IF
   END IF

   DECLARE cq_pedidos CURSOR WITH HOLD FOR
    SELECT num_pedido
      FROM pedidos 
     WHERE cod_empresa = p_cod_empresa
       AND (ies_sit_pedido = 'E')
   FOREACH cq_pedidos INTO m_num_pedido       
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo pedidos - cq_pedidos '
         LET m_num_pedido = 0
         CALL pol1396_ins_erro()
         RETURN FALSE
      END IF
      
      LET m_msg = ''
      CALL pol1396_proc_consistencia()
      
      IF m_msg IS NOT NULL THEN
         CALL pol1396_ins_erro()
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1396_cria_tab_erro()#
#-------------------------------#

   CREATE TABLE erro_consite_pedidos (
      cod_empresa            INTEGER,
      num_pedido             INTEGER,
      dat_proces             VARCHAR(19),
      erro                   VARCHAR(120)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','erro_consite_pedidos')
      RETURN FALSE
   END IF

   CREATE INDEX ix_erro_pedidos
    ON erro_consite_pedidos(cod_empresa, num_pedido);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix_erro_pedidos')
      RETURN FALSE
   END IF
   
   RETURN TRUE      
   
END FUNCTION

#---------------------------------------------#
FUNCTION pol1396_consiste_pedido(lr_consioste)#
#---------------------------------------------#

   DEFINE lr_consioste    RECORD
          cod_empresa     CHAR(02),
          num_pedido      INTEGER
   END RECORD
   
   LET p_cod_empresa =  lr_consioste.cod_empresa
   LET m_num_pedido =  lr_consioste.num_pedido
   LET m_msg = ''
   
   IF p_cod_empresa IS NULL THEN
      LET m_msg = '- Empresa não enviada;'
   END IF

   IF m_num_pedido IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Pedido não enviado;'
   END IF

   IF m_msg IS NULL THEN
      CALL pol1396_proc_consistencia()
   END IF
   
   RETURN m_msg

END FUNCTION      
   
#--------------------------#
FUNCTION pol1396_ins_erro()#
#--------------------------#

   INSERT INTO erro_consite_pedidos
    VALUES(p_cod_empresa, m_num_pedido, m_dat_proces, m_msg)
   
   LET m_tem_erro = TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1396_proc_consistencia()#
#-----------------------------------#
   
   DISPLAY m_num_pedido TO num_pedido
   #lds CALL LOG_refresh_display()
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1396_processa() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1396_processa()#
#--------------------------#

   IF NOT vdp20023_carga_inicial_exec_por_fora(p_cod_empresa,TRUE) THEN
      RETURN FALSE
   END IF

  IF NOT vdp20023_insere_pedido_exec_por_fora(m_num_pedido) THEN
     RETURN FALSE
  END IF

  IF NOT vdp20023_processa_consistencia_exec_por_fora('C',TRUE,FALSE,FALSE) THEN 
     RETURN FALSE
  END IF

  {
     'C',  #Ação: Consistência.
     TRUE, #Realizar aprovação aut de pedidos em análise, se parâmetro "aprov_autom_ped_analise" estiver ativo.
     FALSE, #Abrir tela com as consistências.
     FALSE) THEN #Controlar transação de banco.
     RETURN FALSE
  }
  RETURN TRUE

END FUNCTION
    

{

select * from pedidos where cod_empresa = '01' and num_pedido >= 134615
select * from ped_itens where cod_empresa = '01' and qtd_pecas_atend = 0 and qtd_pecas_cancel = 0
 and num_pedido in (select num_pedido from pedidos where cod_empresa = '01' and ies_sit_pedido <> '9')

 select * from pedidos where cod_empresa = '01' and num_pedido = 134640
 select * from clientes where cod_cliente = '008613972000163'
 select * from ped_itens where cod_empresa = '01' and num_pedido = 134640
   