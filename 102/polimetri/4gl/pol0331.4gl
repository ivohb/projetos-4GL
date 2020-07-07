#---------------------------------------------------------------------------#  
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                               #
# PROGRAMA: POL0331                                                         #
# MODULOS.: POL0331 - LOG0010 - LOG0030 - LOG0040 - LOG0050                 #
#           LOG0280 - LOG1200 - LOG1300 - LOG1400 - LOG1500                 #
# OBJETIVO: GERACAO DE LANCAMENTOS CONTABEIS P/ LOTE DE DUPLICATAS          #
# DATA....: 25/02/2005                                                      #
#---------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(80),
          comando              CHAR(80),
          p_houve_erro         SMALLINT,
          p_status             SMALLINT,
          p_ies_cons           SMALLINT,
          p_count              SMALLINT,
          p_i                  SMALLINT,
          p_dat_aux            CHAR(010),
          p_dat_ini            DATE,
          p_dat_fim            DATE,
          p_msg                CHAR(500)

   DEFINE p_cta_cont_polimetri RECORD LIKE cta_cont_polimetri.*,
          p_port_polimetri     RECORD LIKE port_polimetri.*,
          p_desc_dup_polimetri RECORD LIKE desc_dup_polimetri.*,
          p_dg_lote            RECORD LIKE dg_lote.*,
          p_dg_lancamento      RECORD LIKE dg_lancamento.*,
          p_evento_polimetri   RECORD LIKE evento_polimetri.*,
          p_lan_cont_polimetri RECORD LIKE lan_cont_polimetri.*

   DEFINE p_tela RECORD
      dat_ini  LIKE desc_dup_polimetri.data_movto,
      dat_fim  LIKE desc_dup_polimetri.data_movto,
      num_lote LIKE desc_dup_polimetri.num_lote
   END RECORD

#  DEFINE p_versao    CHAR(17)
   DEFINE p_versao    CHAR(18)
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0331-10.02.00"
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT
   CALL log140_procura_caminho("pol0331.iem") RETURNING comando
   OPTIONS
      HELP FILE comando

#  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0331_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0331_controle()
#-------------------------#

   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0331") RETURNING comando    
   OPEN WINDOW w_pol0331 AT 2,2 WITH FORM comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parametros de Entrada"
         HELP 0009
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","POL0331","IN") THEN
            IF pol0331_entrada_parametros("INFORMA") THEN
               NEXT OPTION "Processar"
            END IF
         END IF
      COMMAND "Processar" "Processar a Geracao de Lotes Contabeis"
         HELP 0010
         IF log005_seguranca(p_user,"VDP","POL0331","MO") THEN
            IF p_ies_cons THEN
               IF pol0331_processar() THEN
                  NEXT OPTION "Fim"
               END IF
            ELSE
               ERROR "Informar Previamente Parametros de Entrada"
               NEXT OPTION "Informar"
            END IF
         END IF
      COMMAND "Cancela Lote" "Cancelar Lotes Contabeis"
         HELP 0010
         IF log005_seguranca(p_user,"VDP","POL0331","MO") THEN
            IF p_ies_cons THEN
               IF pol0331_entrada_parametros("CANCELA") THEN
                  IF pol0331_cancela_lote() THEN
                     NEXT OPTION "Fim"
                  END IF
               END IF
            ELSE
               ERROR "Informar Previamente Parametros de Entrada"
               NEXT OPTION "Informar"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0331_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0331

END FUNCTION

#-------------------------------------------#
FUNCTION pol0331_entrada_parametros(p_funcao)
#-------------------------------------------#
   DEFINE p_funcao                CHAR(07)

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0331
   DISPLAY p_cod_empresa TO cod_empresa
   IF p_funcao = "INFORMA" THEN
      INITIALIZE p_tela.* TO NULL
   END IF

   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      BEFORE FIELD dat_ini
      IF p_funcao = "CANCELA" THEN
         NEXT FIELD num_lote
      END IF

      AFTER FIELD dat_ini
      IF p_tela.dat_ini IS NULL THEN
         ERROR "O Campo Data Inicial nao pode ser Nulo"
         NEXT FIELD dat_ini 
      END IF

      AFTER FIELD dat_fim
      IF p_tela.dat_fim IS NULL THEN
         ERROR "O Campo Data Final nao pode ser Nulo"
         NEXT FIELD dat_fim 
      ELSE
         IF p_tela.dat_fim < p_tela.dat_ini THEN
            ERROR "O Campo Data Final nao pode ser Menor que Inicial"
            NEXT FIELD dat_ini     
         END IF
         IF MONTH(p_tela.dat_ini) <> MONTH(p_tela.dat_fim) THEN
            ERROR "Periodo nao pode ser Maior que Um Mes"
            NEXT FIELD dat_ini     
         END IF
      END IF
      EXIT INPUT

      AFTER FIELD num_lote
      IF p_tela.num_lote IS NULL THEN
         ERROR "O Campo Numero do Lote nao pode ser Nulo"
         NEXT FIELD num_lote
      ELSE
         SELECT UNIQUE(num_lote)
           FROM desc_dup_polimetri
          WHERE cod_empresa = p_cod_empresa
            AND num_lote = p_tela.num_lote
            AND data_movto BETWEEN p_tela.dat_ini AND p_tela.dat_fim 
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Lote Inexistente"
            NEXT FIELD num_lote
         END IF
      END IF

   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0331

   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Funcao Cancelada"
      RETURN FALSE
   END IF

   LET p_ies_cons = TRUE 
   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol0331_processar()
#---------------------------#    
   DEFINE l_texto               CHAR(50),
          l_nom_cliente         LIKE clientes.nom_cliente,
          l_cta_debito          LIKE plano_contas.num_conta_reduz

   IF log004_confirm(13,34) THEN
      INITIALIZE p_cta_cont_polimetri.*,
                 p_port_polimetri.*,
                 p_desc_dup_polimetri.*,
                 p_dg_lote.*,
                 p_dg_lancamento.*,
                 p_evento_polimetri.*,
                 p_lan_cont_polimetri.* TO NULL

      MESSAGE "Aguarde Gerando Arquivo de Lotes Contabeis..." 
         ATTRIBUTE(REVERSE)

      CALL log085_transacao("BEGIN")
   #  BEGIN WORK

      SELECT MAX(num_lote)
        INTO p_dg_lote.num_lote
        FROM dg_lote
       WHERE cod_empresa     = p_cod_empresa
         AND den_sistema_ger = "CRE"
         AND per_contabil    = YEAR(p_tela.dat_ini)
         AND cod_seg_periodo = MONTH(p_tela.dat_ini)
      IF p_dg_lote.num_lote IS NULL THEN
         LET p_dg_lote.num_lote = 1
      ELSE
         LET p_dg_lote.num_lote = p_dg_lote.num_lote + 1
      END IF

      SELECT * 
        INTO p_cta_cont_polimetri.*
        FROM cta_cont_polimetri 
       WHERE cod_empresa = p_cod_empresa
      IF SQLCA.SQLCODE <> 0 THEN
         ERROR "Nao Existe Conta Contábil de Débito"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF

      SELECT num_conta_reduz
        INTO p_dg_lancamento.num_conta_deb
        FROM plano_contas
       WHERE cod_empresa = p_cod_empresa
         AND num_conta   = p_cta_cont_polimetri.num_conta

      LET p_houve_erro = FALSE
      LET p_dg_lote.per_contabil    = YEAR(p_tela.dat_ini)
      LET p_dg_lote.cod_seg_periodo = MONTH(p_tela.dat_ini)

      INSERT INTO dg_lote
      VALUES (p_cod_empresa, "CRE", p_dg_lote.per_contabil,
              p_dg_lote.cod_seg_periodo, p_dg_lote.num_lote,
              p_user, 1, 0, 0, 0, "D", 1, "N", "A")
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","DG_LOTE")
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF

      SELECT MAX(num_lanc) 
        INTO p_dg_lancamento.num_lanc
        FROM dg_lancamento
       WHERE cod_empresa     = p_cod_empresa
         AND den_sistema_ger = "CRE"
         AND per_contabil    = YEAR(p_tela.dat_ini)
         AND cod_seg_periodo = MONTH(p_tela.dat_ini)
      IF p_dg_lancamento.num_lanc IS NULL THEN
         LET p_dg_lancamento.num_lanc = 0
      END IF

      DECLARE cq_desc_dup CURSOR FOR 
       SELECT *
         FROM desc_dup_polimetri
        WHERE cod_empresa = p_cod_empresa
          AND num_lote    = 0
          AND data_movto  BETWEEN p_tela.dat_ini AND p_tela.dat_fim 

      FOREACH cq_desc_dup INTO p_desc_dup_polimetri.* 

         LET p_dg_lancamento.num_lanc = p_dg_lancamento.num_lanc + 1

         INSERT INTO dg_lancamento
            VALUES (p_cod_empresa, 
                    "CRE", 
                    p_dg_lote.per_contabil,
                    p_dg_lote.cod_seg_periodo, 
                    p_dg_lote.num_lote,
                    p_dg_lancamento.num_lanc, 
                    p_dg_lancamento.num_conta_deb, 
                    '0', 
                    p_desc_dup_polimetri.data_movto,
                    p_desc_dup_polimetri.val_saldo, 
                    0, 
                    p_cta_cont_polimetri.cod_hist,
                    "N", 
                    "N", 
                    NULL,
                    NULL, 
                    0, 
                    NULL, 
                    NULL, 
                    NULL, 
                    NULL, 
                    NULL, 
                    NULL)
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","DG_LANCAMENTO")
            LET p_houve_erro = TRUE
            EXIT FOREACH
         END IF

         SELECT clientes.nom_cliente
           INTO l_nom_cliente
           FROM clientes, docum
          WHERE docum.cod_empresa   = p_cod_empresa
            AND docum.num_docum     = p_desc_dup_polimetri.num_docum
            AND docum.ies_tip_docum = 'DP' 
            AND docum.cod_cliente   = clientes.cod_cliente 
               
         LET l_texto = p_desc_dup_polimetri.num_docum CLIPPED, ' DE ',
                       l_nom_cliente 

         WHENEVER ERROR CONTINUE
           INSERT INTO dg_historico VALUES (p_cod_empresa, 
                                            "CRE", 
                                            p_dg_lote.per_contabil,
                                            p_dg_lote.cod_seg_periodo, 
                                            p_dg_lote.num_lote,
                                            p_dg_lancamento.num_lanc, 
                                            1,
                                            l_texto)
         WHENEVER ERROR STOP 
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","DG_HISTORICO")
            LET p_houve_erro = TRUE
            EXIT FOREACH
         END IF
          
         SELECT *
           INTO p_port_polimetri.*
           FROM port_polimetri
          WHERE cod_empresa  = p_cod_empresa
            AND cod_portador = p_desc_dup_polimetri.cod_portador
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Nao Existe Portador da Conta de Credito"
            LET p_houve_erro = TRUE
            EXIT FOREACH
         END IF   

         SELECT num_conta_reduz
           INTO p_dg_lancamento.num_conta_cre
           FROM plano_contas
         WHERE cod_empresa = p_cod_empresa
           AND num_conta   = p_port_polimetri.num_conta

         LET p_dg_lancamento.num_lanc = p_dg_lancamento.num_lanc + 1

         INSERT INTO dg_lancamento
            VALUES (p_cod_empresa, 
                    "CRE", 
                    p_dg_lote.per_contabil,
                    p_dg_lote.cod_seg_periodo, 
                    p_dg_lote.num_lote,
                    p_dg_lancamento.num_lanc, 
                    '0', 
                    p_dg_lancamento.num_conta_cre,
                    p_desc_dup_polimetri.data_movto,
                    p_desc_dup_polimetri.val_saldo, 
                    0, 
                    p_port_polimetri.cod_hist,
                    "N", 
                    "N", 
                    NULL,
                    NULL, 
                    0, 
                    NULL, 
                    NULL, 
                    NULL, 
                    NULL, 
                    NULL, 
                    NULL)
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","DG_LANCAMENTO")
            LET p_houve_erro = TRUE
            EXIT FOREACH
         END IF

         WHENEVER ERROR CONTINUE
         INSERT INTO dg_historico VALUES (p_cod_empresa, 
                                          "CRE", 
                                          p_dg_lote.per_contabil,
                                          p_dg_lote.cod_seg_periodo, 
                                          p_dg_lote.num_lote,
                                          p_dg_lancamento.num_lanc, 
                                          1,
                                          l_texto)
         WHENEVER ERROR STOP 
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","DG_HISTORICO")
            LET p_houve_erro = TRUE
            EXIT FOREACH
         END IF

         DECLARE cq_eve_lan CURSOR FOR 
          SELECT a.cta_debito, 
                 a.cod_hist_deb,
                 b.valor_evento
            FROM evento_polimetri a, lan_cont_polimetri b
           WHERE a.cod_empresa   = p_cod_empresa
             AND a.cod_empresa   = b.cod_empresa
             AND a.cod_evento    = b.cod_evento
             AND b.num_docum     = p_desc_dup_polimetri.num_docum
             AND b.ies_tip_docum = p_desc_dup_polimetri.ies_tip_docum

         FOREACH cq_eve_lan INTO p_evento_polimetri.cta_debito,
                                 p_evento_polimetri.cod_hist_deb,
                                 p_lan_cont_polimetri.valor_evento

            LET p_dg_lancamento.num_lanc = p_dg_lancamento.num_lanc + 1

            SELECT num_conta_reduz
              INTO l_cta_debito
              FROM plano_contas
             WHERE cod_empresa = p_cod_empresa
               AND num_conta   = p_evento_polimetri.cta_debito
      
            INSERT INTO dg_lancamento
               VALUES (p_cod_empresa,
                       "CRE",
                       p_dg_lote.per_contabil,
                       p_dg_lote.cod_seg_periodo,
                       p_dg_lote.num_lote,
                       p_dg_lancamento.num_lanc,
                       l_cta_debito,
                       '0',
                       p_desc_dup_polimetri.data_movto,
                       p_lan_cont_polimetri.valor_evento,
                       0,
                       p_evento_polimetri.cod_hist_deb,
                       "N",
                       "N",
                       NULL,
                       NULL, 
                       0, 
                       NULL, 
                       NULL, 
                       NULL, 
                       NULL, 
                       NULL, 
                       NULL)
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","DG_LANCAMENTO")
               LET p_houve_erro = TRUE
               EXIT FOREACH
            END IF

            WHENEVER ERROR CONTINUE
              INSERT INTO dg_historico VALUES (p_cod_empresa, 
                                               "CRE", 
                                               p_dg_lote.per_contabil,
                                               p_dg_lote.cod_seg_periodo, 
                                               p_dg_lote.num_lote,
                                               p_dg_lancamento.num_lanc, 
                                               1,
                                               l_texto)
            WHENEVER ERROR STOP 
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","DG_HISTORICO")
               LET p_houve_erro = TRUE
               EXIT FOREACH
            END IF
          
            LET p_dg_lancamento.num_lanc = p_dg_lancamento.num_lanc + 1

            INSERT INTO dg_lancamento
               VALUES (p_cod_empresa, 
                       "CRE", 
                       p_dg_lote.per_contabil,
                       p_dg_lote.cod_seg_periodo, 
                       p_dg_lote.num_lote,
                       p_dg_lancamento.num_lanc, 
                       '0', 
                       p_dg_lancamento.num_conta_cre,
                       p_desc_dup_polimetri.data_movto,
                       p_lan_cont_polimetri.valor_evento,
                       0, 
                       p_port_polimetri.cod_hist,
                       "N", 
                       "N", 
                       NULL,
                       NULL, 
                       0, 
                       NULL, 
                       NULL, 
                       NULL, 
                       NULL, 
                       NULL, 
                       NULL)
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","DG_LANCAMENTO")
               LET p_houve_erro = TRUE
               EXIT FOREACH
            END IF
            
            WHENEVER ERROR CONTINUE
              INSERT INTO dg_historico VALUES (p_cod_empresa, 
                                               "CRE", 
                                               p_dg_lote.per_contabil,
                                               p_dg_lote.cod_seg_periodo, 
                                               p_dg_lote.num_lote,
                                               p_dg_lancamento.num_lanc, 
                                               1,
                                               l_texto)
            WHENEVER ERROR STOP 
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","DG_HISTORICO")
               LET p_houve_erro = TRUE
               EXIT FOREACH
            END IF

         END FOREACH

         IF p_houve_erro THEN
            EXIT FOREACH
         END IF

         LET p_count = p_count + 1

      END FOREACH

      IF p_houve_erro THEN
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF

      IF p_count > 0 THEN
         UPDATE desc_dup_polimetri
            SET num_lote    = p_dg_lote.num_lote
          WHERE cod_empresa = p_cod_empresa
            AND num_lote    = 0
            AND data_movto BETWEEN p_tela.dat_ini AND p_tela.dat_fim 
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("ALTERACAO","DESC_DUP_POLIMETRI")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
            RETURN FALSE
         END IF
      END IF
   
      CALL log085_transacao("COMMIT")
   #  COMMIT WORK

      IF p_count > 0 THEN
         ERROR "Lote Gerado com sucesso...!!!"
      ELSE
         ERROR "Nao existem Dados para Geracao de Lote"
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol0331_cancela_lote()
#------------------------------#    
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0331
   DISPLAY p_cod_empresa TO cod_empresa

   IF log004_confirm(13,34) THEN
      INITIALIZE p_desc_dup_polimetri.* TO NULL

      SELECT *
        FROM dg_lote
       WHERE cod_empresa = p_cod_empresa
         AND den_sistema_ger = "CRE"
         AND per_contabil = YEAR(p_tela.dat_ini)
         AND cod_seg_periodo = MONTH(p_tela.dat_ini)
        AND num_lote = p_tela.num_lote
      IF SQLCA.SQLCODE = 0 THEN
         MESSAGE "Cancelamento nao Permitido Lote na Contabilidade"
            ATTRIBUTE(REVERSE)
         RETURN FALSE
      END IF

      UPDATE desc_dup_polimetri
         SET num_lote    = 0
       WHERE cod_empresa = p_cod_empresa
         AND num_lote    = p_tela.num_lote
         AND data_movto  BETWEEN p_tela.dat_ini AND p_tela.dat_fim 
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("ALTERACAO","DESC_DUP_POLIMETRI")
         RETURN FALSE
      END IF

      MESSAGE "Lote Cancelado com Sucesso...!!!" ATTRIBUTE(REVERSE)
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol0331_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#
