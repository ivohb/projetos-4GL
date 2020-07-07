#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: pol0985                                              #
# MODULOS.: pol0985- LOG0010 - LOG0030 - LOG0040 - LOG0050       #
#           LOG0060 - LOG1200 - LOG1300 - LOG1400                 #
# OBJETIVO: CANCELAMENTO DE ROMANEIO                              #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_erro                 CHAR(01),       
         p_status               SMALLINT,
         p_ies_cons             SMALLINT

  DEFINE p_ordem_montag_item    RECORD LIKE ordem_montag_item.*,
         p_audit_vdp            RECORD LIKE audit_vdp.*

  DEFINE p_tela   RECORD
         cod_empresa   CHAR(02), 
         num_om_ini    LIKE ordem_montag_mest.num_om,
         num_om_fim    LIKE ordem_montag_mest.num_om
     END RECORD
                 
  DEFINE p_nom_arquivo          CHAR(100),
         p_ies_impressao        CHAR(001),
         p_ok                   CHAR(001),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_prog_inex            CHAR(001),
         p_help                 CHAR(080),
         p_count_ped            INTEGER,
         p_cancel               INTEGER,
         p_msg                  CHAR(500)
         
  DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0985-10.02.00" #Favor nao alterar esta linha (SUPORTE)
  WHENEVER ANY ERROR CONTINUE
  CALL log1400_isolation()             
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho CLIPPED
  OPTIONS
    HELP FILE p_help,
    PREVIOUS KEY control-b,
    NEXT     KEY control-f

  CALL log001_acessa_usuario("ESPEC999","")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN 
    CALL pol0985_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0985_controle()
#--------------------------#

  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol0985") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0985 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Informar"    "Informe num. das ordens"
         CALL pol0985_informar()

    COMMAND "Processar"    "Processa cancelamento "
        IF p_tela.num_om_ini IS NULL THEN 
           MESSAGE "Nao existem dados para processar"  ATTRIBUTE(REVERSE)
        ELSE
          IF log004_confirm(22,45) THEN
             ERROR " Em Processamento... "
             CALL log085_transacao("BEGIN")
             IF pol0985_cancela_romaneio() THEN 
               CALL log085_transacao("COMMIT")
                MESSAGE "Cancelamento efetuado com Sucesso "  ATTRIBUTE(REVERSE)
                NEXT OPTION "Fim"
             ELSE
                CALL log085_transacao("ROLLBACK")
                MESSAGE "PROBLEMA DURANTE PROCESSAMENTO"  ATTRIBUTE(REVERSE)
                NEXT OPTION "Fim"
             END IF 
          END IF
        END IF  
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0985_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix

    COMMAND "Fim" "Retorna ao Menu Anterior"
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0985
END FUNCTION

#--------------------------#
FUNCTION pol0985_informar()
#--------------------------#
 DEFINE l_count   INTEGER
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0985
   CLEAR FORM
   
   INITIALIZE p_tela TO NULL
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD num_om_ini
         IF p_tela.num_om_ini IS NULL THEN
            ERROR 'Informe Num.da OM !!!'
            NEXT FIELD num_om_ini
         ELSE
            LET l_count = 0 
            SELECT count(*)
              INTO l_count
              FROM ordem_montag_mest
             WHERE cod_empresa = p_cod_empresa
               AND num_om      = p_tela.num_om_ini
            IF l_count = 0 THEN 
               ERROR 'OM INEXISTENTE'  
               NEXT FIELD num_om_ini
            END IF
         END IF    

      AFTER FIELD num_om_fim
         IF p_tela.num_om_fim IS NULL THEN
            ERROR 'Informe Num.da OM !!!'
            NEXT FIELD num_om_fim
         ELSE
            IF p_tela.num_om_ini > p_tela.num_om_fim THEN 
               ERROR 'OM final deve ser maior ou igual a inicial !!!'
               NEXT FIELD num_om_ini 
            END IF    
            LET l_count = 0 
            SELECT count(*)
              INTO l_count
              FROM ordem_montag_mest
             WHERE cod_empresa = p_cod_empresa
               AND num_om      = p_tela.num_om_fim
            IF l_count = 0 THEN 
               ERROR 'OM INEXISTENTE'  
               NEXT FIELD num_om_fim
            END IF 
         END IF 

      
   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
   ELSE
      LET p_ies_cons = FALSE
      DISPLAY '' TO num_om_ini
      DISPLAY '' TO num_om_fim
   END IF
END FUNCTION

#-----------------------------------#
 FUNCTION pol0985_cancela_romaneio()
#-----------------------------------#
   DEFINE l_prz_entrega       LIKE ped_itens.prz_entrega

### --- ATUALIZA ESTOQUE QTD_ROMANEADA , PED_ITENS E PED_ITENS_FCT_547
   DECLARE cq_omi CURSOR for 
     SELECT * 
       FROM ordem_montag_item 
      WHERE cod_empresa = p_cod_empresa
        AND num_om >= p_tela.num_om_ini
        AND num_om <= p_tela.num_om_fim
      ORDER BY num_om, num_sequencia
   FOREACH  cq_omi INTO p_ordem_montag_item.*
      UPDATE estoque 
         SET qtd_liberada = qtd_reservada - p_ordem_montag_item.qtd_reservada
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_ordem_montag_item.cod_item 
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("update","estoque")
         RETURN FALSE
      END IF

      UPDATE ped_itens
         SET qtd_pecas_romaneio  = qtd_pecas_romaneio - p_ordem_montag_item.qtd_reservada
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_ordem_montag_item.num_pedido
         AND num_sequencia = p_ordem_montag_item.num_sequencia
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("update","ped_itens")
         RETURN FALSE
      END IF

      SELECT prz_entrega
        INTO l_prz_entrega
        FROM ped_itens
       WHERE cod_empresa   = p_cod_empresa 
         AND num_pedido    = p_ordem_montag_item.num_pedido
         AND num_sequencia = p_ordem_montag_item.num_sequencia

      UPDATE ped_itens_fct_547 
         SET qtd_romaneio = qtd_romaneio - p_ordem_montag_item.qtd_reservada,
                            dat_romaneio = NULL            
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ordem_montag_item.num_pedido
         AND prz_entrega = l_prz_entrega
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("update","ped_itens_fct_547")
         RETURN FALSE
      END IF
         
      LET p_audit_vdp.cod_empresa = p_cod_empresa
      LET p_audit_vdp.num_pedido = p_ordem_montag_item.num_pedido
      LET p_audit_vdp.tipo_informacao = 'M' 
      LET p_audit_vdp.tipo_movto = 'C'
      LET p_audit_vdp.texto = 'ALTERACAO SEQ ',p_ordem_montag_item.num_sequencia,' QTD. RESERVADA ALTERADA PARA ',
                              0
      LET p_audit_vdp.num_programa = 'POL0985'
      LET p_audit_vdp.data =  TODAY
      LET p_audit_vdp.hora =  TIME 
      LET p_audit_vdp.usuario = p_user
      LET p_audit_vdp.num_transacao = 0  
      INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","audit_vdp")
         LET p_erro = 'S'
         RETURN FALSE
      END IF
   END FOREACH 

### --- DELETA ORDENS 
   DELETE FROM ordem_montag_mest 
    WHERE cod_empresa = p_cod_empresa 
      AND num_om >= p_tela.num_om_ini
      AND num_om <= p_tela.num_om_fim
        
   DELETE FROM ordem_montag_item 
    WHERE cod_empresa = p_cod_empresa 
      AND num_om >= p_tela.num_om_ini
      AND num_om <= p_tela.num_om_fim

   DELETE FROM ordem_montag_embal 
    WHERE cod_empresa = p_cod_empresa 
      AND num_om >= p_tela.num_om_ini
      AND num_om <= p_tela.num_om_fim

   RETURN TRUE
 
 END FUNCTION
 
 #-----------------------#
 FUNCTION pol0985_sobre()
 #-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
 END FUNCTION