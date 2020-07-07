#-------------------------------------------------------------------#
# SISTEMA.: CONTAS A RECEBER                                        #
# PROGRAMA: POL0327                                                 #
# MODULOS.: POL0327 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA DESC_DUP_POLIMETRI                 #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 16/02/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,  
          p_user               LIKE usuario.nom_usuario,
          p_nom_portador       LIKE portador.nom_portador,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_status             SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
      #   p_versao             CHAR(17),
          p_versao             CHAR(18),
          p_arquivo            CHAR(25),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_r                  CHAR(01),
          p_count              SMALLINT,
          p_ies_cons           SMALLINT,
          pa_curr              SMALLINT,
          sc_curr              SMALLINT,
          pa_curr1             SMALLINT,
          sc_curr1             SMALLINT,
          p_i                  SMALLINT,
          p_msg                CHAR(500)

   DEFINE p_docum              RECORD LIKE docum.*,
          p_desc_dup_polimetri RECORD LIKE desc_dup_polimetri.*

   DEFINE t_tit_desc ARRAY[500] OF RECORD 
      num_docum           LIKE docum.num_docum,
      ies_evento          CHAR(1), 
      ies_tip_docum       LIKE docum.ies_tip_docum,
      nom_cliente         LIKE clientes.nom_cliente,
      dat_vencto_s_desc   LIKE docum.dat_vencto_s_desc,
      val_saldo           LIKE docum.val_saldo,
      num_lote            LIKE desc_dup_polimetri.num_lote
   END RECORD 
   
   DEFINE t_tit_desc1 ARRAY[500] OF RECORD 
      ies_excluir         CHAR(01)
   END RECORD 

END GLOBALS

   DEFINE ma_evento ARRAY[50] OF RECORD 
      cod_evento             LIKE evento_polimetri.cod_evento,
      den_evento             LIKE evento_polimetri.den_evento,
      cta_debito             LIKE evento_polimetri.cta_debito,
      cod_hist_deb           LIKE evento_polimetri.cod_hist_deb,
      valor_evento           LIKE lan_cont_polimetri.valor_evento
   END RECORD 

   DEFINE mr_evento      RECORD
      num_docum              LIKE docum.num_docum,
      ies_tip_docum          LIKE docum.ies_tip_docum
                         END RECORD

   DEFINE m_num_docum        LIKE docum.num_docum,
          m_ies_tip_docum    LIKE docum.ies_tip_docum,
          m_consulta         SMALLINT

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0327-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0327.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("CRECEBER")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0327_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0327_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0327") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0327 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"CRECEBER","pol0327","IN") THEN
            CALL pol0327_inclusao() RETURNING p_status
            NEXT OPTION "Consultar"
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"CRECEBER","pol0327","CO") THEN
            CALL pol0327_consulta_desc()
            NEXT OPTION "Excluir"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"CRECEBER","pol0327","EX") THEN
               CALL pol0327_exclusao()
               NEXT OPTION "Fim"
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0327_sobre()
      COMMAND KEY ("V") "eVentos" "Manutenção dos eventos."
         HELP 005
         MESSAGE ""
         IF log005_seguranca(p_user,"CRECEBER","pol0327","EX") THEN
            CALL pol0327_controle_eventos()
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0327

END FUNCTION

#--------------------------#
 FUNCTION pol0327_inclusao()
#--------------------------#
   LET p_houve_erro = FALSE
   CLEAR FORM
   IF pol0327_entrada_dados() THEN
      IF log004_confirm(21,45) THEN
         CALL log085_transacao("BEGIN")
      #  BEGIN WORK
         LET p_desc_dup_polimetri.cod_empresa = p_cod_empresa
         FOR p_i = 1 TO 500
            IF t_tit_desc[p_i].num_docum IS NOT NULL THEN
               INSERT INTO desc_dup_polimetri
                  VALUES (p_desc_dup_polimetri.cod_empresa,
                          t_tit_desc[p_i].num_docum,
                          t_tit_desc[p_i].ies_evento,
                          t_tit_desc[p_i].ies_tip_docum,
                          p_desc_dup_polimetri.cod_portador,
                          p_desc_dup_polimetri.data_movto, 
                          t_tit_desc[p_i].val_saldo,
                          0) 
               IF SQLCA.SQLCODE <> 0 THEN 
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("INCLUSAO","DESC_DUP_POLIMETRI")
                  EXIT FOR
               END IF
            END IF
         END FOR
         IF p_houve_erro = FALSE THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK 
            MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            LET p_ies_cons = FALSE
         ELSE
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK 
            LET p_ies_cons = FALSE
            RETURN FALSE
         END IF   
      ELSE
         CLEAR FORM
         RETURN FALSE
      END IF
   ELSE
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
 
#-------------------------------#
 FUNCTION pol0327_entrada_dados()
#-------------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0327

   INITIALIZE p_desc_dup_polimetri.*,
              p_docum.*,
              p_nom_portador,
              t_tit_desc TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG = FALSE
   INPUT BY NAME p_desc_dup_polimetri.cod_portador,
                 p_desc_dup_polimetri.data_movto
      WITHOUT DEFAULTS  

      AFTER FIELD cod_portador   
      IF p_desc_dup_polimetri.cod_portador IS NULL THEN
         ERROR "O Campo Cod Banco nao pode ser Nulo"
         NEXT FIELD cod_portador  
      ELSE
         SELECT nom_portador     
            INTO p_nom_portador     
         FROM portador
         WHERE cod_portador = p_desc_dup_polimetri.cod_portador
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Banco nao Cadastrado"
            NEXT FIELD cod_portador
         ELSE
            DISPLAY p_nom_portador TO nom_portador
         END IF
      END IF

      BEFORE FIELD data_movto      
      LET p_desc_dup_polimetri.data_movto = TODAY

      AFTER FIELD data_movto      
      IF p_desc_dup_polimetri.data_movto IS NULL THEN
         ERROR "O Campo Data Movimento nao pode ser Nula"
         NEXT FIELD data_movto
      END IF

      ON KEY (control-z)
         IF INFIELD(cod_portador) THEN
            CALL log009_popup(6,25,"PORTADOR","portador","cod_portador",
                             "nom_portador","","N","")
               RETURNING p_desc_dup_polimetri.cod_portador        
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0327
            IF p_desc_dup_polimetri.cod_portador IS NOT NULL THEN
               DISPLAY BY NAME p_desc_dup_polimetri.cod_portador
            END IF
         END IF   

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0327
   IF INT_FLAG THEN
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET INT_FLAG = FALSE
   INPUT ARRAY t_tit_desc WITHOUT DEFAULTS FROM s_tit_desc.*

      BEFORE FIELD num_docum  
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD num_docum
      IF t_tit_desc[pa_curr].num_docum IS NULL THEN  
         EXIT INPUT
      ELSE
         SELECT * 
           INTO p_docum.*
           FROM docum
          WHERE cod_empresa   = p_cod_empresa
            AND num_docum     = t_tit_desc[pa_curr].num_docum 
            AND ies_tip_docum = 'DP'
            AND cod_portador  = p_desc_dup_polimetri.cod_portador 
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Duplicata não Cadastrada ou não pertence p/ esse Portador."
            NEXT FIELD num_docum
         END IF
         SELECT * 
           FROM desc_dup_polimetri
          WHERE cod_empresa   = p_cod_empresa
            AND num_docum     = t_tit_desc[pa_curr].num_docum 
            AND ies_tip_docum = p_docum.ies_tip_docum 
         IF SQLCA.SQLCODE = 0 THEN
            ERROR "Duplicata Já Cadastrada"
            NEXT FIELD num_docum
         END IF
         WHENEVER ERROR CONTINUE 
           SELECT * 
             FROM docum_pgto
            WHERE cod_empresa   = p_cod_empresa
              AND num_docum     = p_docum.num_docum 
              AND ies_tip_docum = p_docum.ies_tip_docum
         WHENEVER ERROR STOP 
         IF SQLCA.SQLCODE = 0 OR
            sqlca.sqlcode = -284 THEN
            ERROR "Duplicata Já Baixada"
            NEXT FIELD num_docum
         ELSE
            SELECT nom_cliente
              INTO t_tit_desc[pa_curr].nom_cliente
              FROM clientes  
             WHERE cod_cliente = p_docum.cod_cliente
            
            LET t_tit_desc[pa_curr].ies_tip_docum = p_docum.ies_tip_docum
            LET t_tit_desc[pa_curr].dat_vencto_s_desc = 
                p_docum.dat_vencto_s_desc
            LET t_tit_desc[pa_curr].val_saldo = p_docum.val_saldo    
            LET t_tit_desc[pa_curr].num_lote = 0
            DISPLAY t_tit_desc[pa_curr].* TO s_tit_desc[sc_curr].*
         END IF
      END IF

      AFTER FIELD ies_evento
         IF t_tit_desc[pa_curr].ies_evento = 'X' THEN
            IF pol0327_insere_evento('INSERE') = FALSE THEN
               LET t_tit_desc[pa_curr].ies_evento = ''
               DISPLAY t_tit_desc[pa_curr].ies_evento TO 
                       s_tit_desc[sc_curr].ies_evento 
               NEXT FIELD ies_evento
            END IF
         END IF
       
   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0327
   IF INT_FLAG THEN
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET p_ies_cons = FALSE
   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0327_consulta_desc() 
#-------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0327

   INITIALIZE p_desc_dup_polimetri.*,
              p_docum.*,
              p_nom_portador,
              t_tit_desc TO NULL
   LET p_houve_erro = FALSE
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG = FALSE
   INPUT BY NAME p_desc_dup_polimetri.cod_portador,
                 p_desc_dup_polimetri.data_movto
      WITHOUT DEFAULTS  

      AFTER FIELD cod_portador   
      IF p_desc_dup_polimetri.cod_portador IS NULL THEN
         ERROR "O Campo Cod Banco nao pode ser Nulo"
         NEXT FIELD cod_portador  
      ELSE
         SELECT nom_portador     
            INTO p_nom_portador     
         FROM portador
         WHERE cod_portador = p_desc_dup_polimetri.cod_portador
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Banco nao Cadastrado"
            NEXT FIELD cod_portador
         ELSE
            DISPLAY p_nom_portador TO nom_portador        
         END IF
      END IF

      BEFORE FIELD data_movto      
      LET p_desc_dup_polimetri.data_movto = TODAY

      AFTER FIELD data_movto      
      IF p_desc_dup_polimetri.data_movto IS NULL THEN
         ERROR "O Campo Data Movimento nao pode ser Nula"
         NEXT FIELD data_movto
      END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0327

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   DECLARE cq_desc_cons CURSOR FOR
    SELECT *
      FROM desc_dup_polimetri
     WHERE cod_empresa = p_cod_empresa
       AND cod_portador = p_desc_dup_polimetri.cod_portador
       AND data_movto = p_desc_dup_polimetri.data_movto

   LET p_i = 1
   FOREACH cq_desc_cons INTO p_desc_dup_polimetri.*

      SELECT dat_vencto_s_desc,
             cod_cliente
        INTO p_docum.dat_vencto_s_desc,
             p_docum.cod_cliente
        FROM docum     
       WHERE cod_empresa   = p_desc_dup_polimetri.cod_empresa
         AND num_docum     = p_desc_dup_polimetri.num_docum
         AND ies_tip_docum = p_desc_dup_polimetri.ies_tip_docum

      SELECT nom_cliente
        INTO t_tit_desc[p_i].nom_cliente
        FROM clientes  
       WHERE cod_cliente = p_docum.cod_cliente
     
      LET t_tit_desc[p_i].num_docum         = p_desc_dup_polimetri.num_docum
      LET t_tit_desc[p_i].ies_evento        = p_desc_dup_polimetri.ies_evento
      LET t_tit_desc[p_i].ies_tip_docum     = p_desc_dup_polimetri.ies_tip_docum
      LET t_tit_desc[p_i].dat_vencto_s_desc = p_docum.dat_vencto_s_desc
      LET t_tit_desc[p_i].val_saldo         = p_desc_dup_polimetri.val_saldo
      LET t_tit_desc[p_i].num_lote          = p_desc_dup_polimetri.num_lote
      LET p_i = p_i + 1

   END FOREACH 

   IF p_i = 1 THEN
      LET p_ies_cons = FALSE
      PROMPT "Nao Existem Titulos p/ este Portador Tecle <Enter>" 
         ATTRIBUTE (REVERSE) FOR p_r
      RETURN 
   END IF

   LET p_ies_cons = TRUE
   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   IF p_i > 10 THEN
      DISPLAY ARRAY t_tit_desc TO s_tit_desc.*
      END DISPLAY 
   ELSE
      INPUT ARRAY t_tit_desc WITHOUT DEFAULTS FROM s_tit_desc.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0327_exclusao()
#--------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0327

   LET p_houve_erro = FALSE
   LET INT_FLAG = FALSE
   INITIALIZE t_tit_desc1 TO NULL

   INPUT ARRAY t_tit_desc1 WITHOUT DEFAULTS FROM s_titdesc.*

      BEFORE FIELD ies_excluir
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD ies_excluir
         IF t_tit_desc1[pa_curr].ies_excluir IS NOT NULL AND
            t_tit_desc1[pa_curr].ies_excluir <> ' ' THEN 
            IF t_tit_desc[pa_curr].num_lote > 0 THEN 
               ERROR 'Duplicata já possui Lote, não pode excluir'
               NEXT FIELD ies_excluir
            END IF
         END IF   
         IF t_tit_desc[pa_curr+1].num_docum IS NULL THEN  
            EXIT INPUT
         END IF

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0327

   IF NOT INT_FLAG THEN
      IF log004_confirm(21,45) THEN
         FOR p_i = 1 TO 500
            IF t_tit_desc[p_i].num_docum IS NOT NULL AND
               t_tit_desc1[p_i].ies_excluir = "X" THEN
               DELETE FROM desc_dup_polimetri
                WHERE cod_empresa   = p_cod_empresa
                  AND num_docum     = t_tit_desc[p_i].num_docum 
                  AND ies_tip_docum = t_tit_desc[p_i].ies_tip_docum 
               IF SQLCA.SQLCODE <> 0 THEN 
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("EXCLUSAO","DESC_DUP_POLIMETRI")
                  EXIT FOR
               END IF
               DELETE FROM lan_cont_polimetri
                WHERE cod_empresa   = p_cod_empresa
                  AND num_docum     = t_tit_desc[p_i].num_docum 
                  AND ies_tip_docum = t_tit_desc[p_i].ies_tip_docum 
               IF SQLCA.SQLCODE <> 0 THEN 
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("EXCLUSAO","LAN_CONT_POLIMETRI")
                  EXIT FOR
               END IF
            END IF
         END FOR
      ELSE
         LET p_ies_cons = FALSE
         CLEAR FORM
         RETURN 
      END IF
      IF p_houve_erro = FALSE THEN
         CLEAR FORM
         MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
         RETURN 
      ELSE
         LET p_ies_cons = FALSE
         RETURN 
      END IF   
   ELSE
      CLEAR FORM
      ERROR "Exclusão de Títulos Cancelada."
      LET p_ies_cons = FALSE
   END IF   

END FUNCTION
 
#---------------------------------------#
 FUNCTION pol0327_insere_evento(l_funcao)
#---------------------------------------#
   DEFINE l_funcao           CHAR(15),
          l_ind              SMALLINT

   IF l_funcao = 'INSERE' THEN
      CALL log006_exibe_teclas("01",p_versao)
      INITIALIZE p_nom_tela TO NULL
      CALL log130_procura_caminho("pol03271") RETURNING p_nom_tela
      LET  p_nom_tela = p_nom_tela CLIPPED 
      OPEN WINDOW w_pol03271 AT 2,2 WITH FORM p_nom_tela 
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
      LET mr_evento.num_docum     = t_tit_desc[pa_curr].num_docum
      LET mr_evento.ies_tip_docum = t_tit_desc[pa_curr].ies_tip_docum
   END IF 

   IF l_funcao <> 'MODIFICACAO' THEN
      DISPLAY p_cod_empresa   TO cod_empresa 
      DISPLAY BY NAME mr_evento.*
      INITIALIZE ma_evento TO NULL
   END IF 

   INPUT ARRAY ma_evento WITHOUT DEFAULTS FROM s_evento.*

      BEFORE FIELD cod_evento
         LET pa_curr1 = ARR_CURR() 
         LET sc_curr1 = SCR_LINE()

      AFTER FIELD cod_evento
         IF ma_evento[pa_curr1].cod_evento IS NOT NULL THEN
            IF pol0327_verifica_evento() = FALSE THEN
               ERROR 'Evento não cadastrado.'
               NEXT FIELD cod_evento
            ELSE
               IF pol0327_verifica_duplicidade() THEN
                  ERROR 'Evento já informado.'
                  NEXT FIELD cod_evento
               END IF
            END IF
         END IF  

      AFTER FIELD valor_evento
         IF ma_evento[pa_curr1].cod_evento IS NOT NULL THEN
            IF ma_evento[pa_curr1].valor_evento IS NULL THEN
               ERROR 'Obrigatório informar Valor.'
               NEXT FIELD valor_evento
            END IF
         END IF  

      ON KEY (Control-z)
         CALL pol0327_popup()

      AFTER INPUT 
         IF INT_FLAG = 0 THEN
            FOR l_ind = 1 TO 50
               IF ma_evento[l_ind].cod_evento IS NOT NULL THEN
                  EXIT FOR
               END IF
               IF l_ind = 50 THEN
                  ERROR 'Obrigatório informar pelo menos um evento.'
                  NEXT FIELD cod_evento
               END IF
            END FOR
         END IF

   END INPUT   

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol03271
   IF INT_FLAG THEN
      CLEAR FORM
      LET INT_FLAG = 0
      IF l_funcao = 'INSERE' THEN
         CLOSE WINDOW w_pol03271
         CURRENT WINDOW IS w_pol0327
      END IF   
      RETURN FALSE 
   ELSE
      IF l_funcao = 'INSERE' THEN
         IF pol0327_inclui_evento() THEN
            CLOSE WINDOW w_pol03271
            CURRENT WINDOW IS w_pol0327
            RETURN TRUE 
         ELSE
            CLOSE WINDOW w_pol03271
            CURRENT WINDOW IS w_pol0327
            ERROR 'Ocorreu problemas na inclusão de eventos.'
            RETURN FALSE
         END IF
      ELSE
         RETURN TRUE
      END IF
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0327_verifica_evento()
#---------------------------------#
   SELECT den_evento, cta_debito, cod_hist_deb
     INTO ma_evento[pa_curr1].den_evento,
          ma_evento[pa_curr1].cta_debito,
          ma_evento[pa_curr1].cod_hist_deb
     FROM evento_polimetri
    WHERE cod_empresa = p_cod_empresa
      AND cod_evento  = ma_evento[pa_curr1].cod_evento
   IF sqlca.sqlcode = 0 THEN
      DISPLAY ma_evento[pa_curr1].den_evento   TO 
              s_evento[sc_curr1].den_evento
      DISPLAY ma_evento[pa_curr1].cta_debito   TO 
              s_evento[sc_curr1].cta_debito
      DISPLAY ma_evento[pa_curr1].cod_hist_deb TO 
              s_evento[sc_curr1].cod_hist_deb
      RETURN TRUE
   ELSE
      DISPLAY ma_evento[pa_curr1].den_evento   TO 
              s_evento[sc_curr1].den_evento
      DISPLAY ma_evento[pa_curr1].cta_debito   TO 
              s_evento[sc_curr1].cta_debito
      DISPLAY ma_evento[pa_curr1].cod_hist_deb TO 
              s_evento[sc_curr1].cod_hist_deb
      RETURN FALSE
   END IF

END FUNCTION     

#--------------------------------------#
 FUNCTION pol0327_verifica_duplicidade()
#--------------------------------------#
   DEFINE l_ind                   SMALLINT

   FOR l_ind = 1 TO 50
      IF ma_evento[l_ind].cod_evento = ma_evento[pa_curr1].cod_evento THEN
         IF pa_curr1 <> l_ind THEN
            RETURN TRUE
         END IF 
      END IF
   END FOR

   RETURN FALSE 

END FUNCTION

#-------------------------------#
 FUNCTION pol0327_inclui_evento()
#-------------------------------#
   DEFINE l_ind                SMALLINT 

   FOR l_ind = 1 TO 50
      IF ma_evento[l_ind].cod_evento IS NOT NULL THEN
         WHENEVER ERROR CONTINUE
           INSERT INTO lan_cont_polimetri VALUES (p_cod_empresa,
                                                  mr_evento.num_docum,
                                                  mr_evento.ies_tip_docum,
                                                  ma_evento[l_ind].cod_evento, 
                                                  ma_evento[l_ind].valor_evento)
         WHENEVER ERROR STOP 
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("INCLUSAO","LAN_CONT_POLIMETRI")
            RETURN FALSE
         END IF
      END IF
   END FOR

   RETURN TRUE 

END FUNCTION

#-----------------------#
 FUNCTION pol0327_popup()
#-----------------------#
   CASE
      WHEN INFIELD(cod_evento)
         CALL pol0327_popup_evento() 
            RETURNING ma_evento[pa_curr1].cod_evento,
                      ma_evento[pa_curr1].den_evento,
                      ma_evento[pa_curr1].cta_debito,
                      ma_evento[pa_curr1].cod_hist_deb
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol03271
         IF ma_evento[pa_curr1].cod_evento IS NOT NULL THEN
            DISPLAY ma_evento[pa_curr1].cod_evento   TO 
                    s_evento[sc_curr1].cod_evento
            DISPLAY ma_evento[pa_curr1].den_evento   TO 
                    s_evento[sc_curr1].den_evento
            DISPLAY ma_evento[pa_curr1].cta_debito   TO 
                    s_evento[sc_curr1].cta_debito
            DISPLAY ma_evento[pa_curr1].cod_hist_deb TO 
                    s_evento[sc_curr1].cod_hist_deb
         
         END IF
   END CASE
 
END FUNCTION 

#------------------------------#
 FUNCTION pol0327_popup_evento()
#------------------------------#
   DEFINE l_ind             SMALLINT

   DEFINE la_tela ARRAY[50] OF RECORD
      cod_evento            LIKE evento_polimetri.cod_evento,
      den_evento            LIKE evento_polimetri.den_evento,
      cta_debito            LIKE evento_polimetri.cta_debito,
      cod_hist_deb          LIKE evento_polimetri.cod_hist_deb
                  END RECORD

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol03272") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol03272 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa
   LET l_ind = 1                         

   DECLARE cq_popup_1 CURSOR FOR
    SELECT UNIQUE cod_evento, den_evento, cta_debito, cod_hist_deb
      FROM evento_polimetri
     WHERE cod_empresa = p_cod_empresa

   FOREACH cq_popup_1 INTO la_tela[l_ind].*

      LET l_ind = l_ind + 1

   END FOREACH
 
   LET l_ind = l_ind - 1

   CALL SET_COUNT(l_ind)
   DISPLAY ARRAY la_tela TO s_item.*

   LET l_ind = ARR_CURR()              

   IF INT_FLAG = 0 THEN
      CLOSE WINDOW w_pol03272
      CURRENT WINDOW IS w_pol03271
      RETURN la_tela[l_ind].cod_evento, 
             la_tela[l_ind].den_evento, 
             la_tela[l_ind].cta_debito,
             la_tela[l_ind].cod_hist_deb
   ELSE
      CLOSE WINDOW w_pol03272
      CURRENT WINDOW IS w_pol03271
      RETURN " ", " ", " ", " "
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol0327_controle_eventos()                  
#----------------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol03271") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol03271 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui eventos na duplicata."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"CRECEBER","pol0327","IN") THEN
            IF pol0327_inclusao_evento() THEN
               ERROR 'Inclusão efetuada com Sucesso.' 
               NEXT OPTION "Fim"
            END IF
         END IF
      COMMAND "Consultar" "Consulta os eventos da duplicata."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"CRECEBER","pol0327","CO") THEN
            CALL pol0327_consulta_evento()
            NEXT OPTION "Modificar"
         END IF
      COMMAND "Modificar" "Modifica os eventos da duplicata."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"CRECEBER","pol0327","IN") THEN
            IF m_consulta THEN
               IF pol0327_modifica_evento() THEN
                  ERROR 'Modificação efetuada com Sucesso.' 
                  NEXT OPTION "Fim"
               END IF
            ELSE
               ERROR 'Consulte Previamente para fazer modificação.' 
               NEXT OPTION "Consultar"
            END IF
         END IF
      COMMAND "Excluir" "Exclui os Eventos da Duplicata."
         HELP 005
         MESSAGE ""
         IF m_consulta THEN
            IF log005_seguranca(p_user,"CRECEBER","pol0327","EX") THEN
               IF pol0327_exclusao_eventos() THEN
                  ERROR 'Exclusão efetuada com Sucesso.'
                  NEXT OPTION "Fim"
               END IF
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusão"
            NEXT OPTION "Consultar"
         END IF 
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol03271
   CURRENT WINDOW IS w_pol0327

END FUNCTION

#---------------------------------#
 FUNCTION pol0327_consulta_evento()
#---------------------------------#
   DEFINE l_ind             SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol03271

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE mr_evento.*, ma_evento TO NULL
   LET mr_evento.ies_tip_docum = 'DP'
   LET INT_FLAG = FALSE

   INPUT BY NAME mr_evento.* WITHOUT DEFAULTS                  

      AFTER FIELD num_docum
         IF mr_evento.num_docum IS NULL OR
            mr_evento.num_docum = ' ' THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD num_docum
         ELSE
            IF pol0327_verifica_docum() = FALSE THEN
               ERROR 'Duplicata não cadastrada na DESC_DUP_POLIMETRI'
               NEXT FIELD num_docum   
            END IF 
         END IF

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol03271

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      LET m_consulta = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
      RETURN
   END IF         

   LET l_ind = 1
   INITIALIZE ma_evento TO NULL

   DECLARE cq_evento CURSOR FOR
    SELECT a.cod_evento, b.den_evento, b.cta_debito, 
           b.cod_hist_deb, a.valor_evento
      FROM lan_cont_polimetri a, evento_polimetri b
     WHERE a.cod_empresa   = p_cod_empresa
       AND a.num_docum     = mr_evento.num_docum
       AND a.ies_tip_docum = mr_evento.ies_tip_docum
       AND a.cod_empresa   = b.cod_empresa
       AND a.cod_evento    = b.cod_evento

   FOREACH cq_evento INTO ma_evento[l_ind].*

      LET l_ind = l_ind + 1

   END FOREACH

   IF l_ind = 1 THEN
      LET m_consulta = FALSE
      ERROR "Não Existem Eventos para essa duplicata."
      RETURN
   END IF        

   LET m_consulta = TRUE
   LET l_ind = l_ind - 1
   CALL SET_COUNT(l_ind)

   IF l_ind > 10 THEN
      DISPLAY ARRAY ma_evento TO s_evento.*
      END DISPLAY
   ELSE
      INPUT ARRAY ma_evento WITHOUT DEFAULTS FROM s_evento.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

END FUNCTION     
       
#--------------------------------#
 FUNCTION pol0327_verifica_docum()
#--------------------------------#
   SELECT num_docum
     FROM desc_dup_polimetri
    WHERE cod_empresa   = p_cod_empresa
      AND num_docum     = mr_evento.num_docum
      AND ies_tip_docum = 'DP' 
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 

END FUNCTION

#---------------------------------#
 FUNCTION pol0327_inclusao_evento()
#---------------------------------#
   IF pol0327_entrada_eventos() THEN
      IF pol0327_insere_evento('INCLUSAO') THEN
         CALL log085_transacao("BEGIN")
      #  BEGIN WORK 
         IF pol0327_inclui_evento() THEN 
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
         ELSE
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         CLEAR FORM
         ERROR "Inclusão Cancelada." 
         LET m_consulta = FALSE
         RETURN FALSE
      END IF
   ELSE
      CLEAR FORM
      ERROR "Inclusão Cancelada." 
      LET m_consulta = FALSE
      RETURN FALSE
   END IF

   LET m_consulta = FALSE
   RETURN TRUE

END FUNCTION    

#---------------------------------#
 FUNCTION pol0327_entrada_eventos() 
#---------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol03271

   CLEAR FORM
   INITIALIZE mr_evento.*, ma_evento TO NULL
   DISPLAY p_cod_empresa TO cod_empresa
   LET mr_evento.ies_tip_docum = 'DP'
   LET INT_FLAG = FALSE

   INPUT BY NAME mr_evento.* WITHOUT DEFAULTS

      AFTER FIELD num_docum
         IF mr_evento.num_docum IS NULL OR
            mr_evento.num_docum = ' ' THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD num_docum
         ELSE
            IF pol0327_verifica_se_ja_existe() THEN
               ERROR 'Duplicata já possui eventos.'
               NEXT FIELD num_docum
            ELSE
               IF pol0327_verifica_contab() THEN
                  ERROR 'Duplicata já foi contabilizada.'
                  NEXT FIELD num_docum
               END IF               
            END IF               
         END IF

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol03271

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      RETURN FALSE
   END IF      

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0327_verifica_se_ja_existe() 
#---------------------------------------#

   WHENEVER ERROR CONTINUE
     SELECT num_docum
       FROM lan_cont_polimetri
      WHERE cod_empresa   = p_cod_empresa
        AND num_docum     = mr_evento.num_docum
        AND ies_tip_docum = 'DP'
   WHENEVER ERROR CONTINUE
   IF sqlca.sqlcode = 0 OR
      sqlca.sqlcode = -284 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0327_modifica_evento()
#---------------------------------#
   IF pol0327_verifica_contab() = FALSE THEN
      IF pol0327_insere_evento('MODIFICACAO') THEN
         CALL log085_transacao("BEGIN")
      #  BEGIN WORK
         WHENEVER ERROR CONTINUE
           DELETE FROM lan_cont_polimetri
            WHERE cod_empresa   = p_cod_empresa
              AND num_docum     = mr_evento.num_docum
              AND ies_tip_docum = mr_evento.ies_tip_docum
         WHENEVER ERROR STOP 
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("DELETE","LAN_CONT_POLIMETRI")
            LET m_consulta = FALSE
            RETURN FALSE
         END IF
         IF pol0327_inclui_evento() THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
         ELSE
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         CLEAR FORM
         ERROR "Modificação Cancelada."
         LET m_consulta = FALSE
         RETURN FALSE
      END IF       
   ELSE
      ERROR "Duplicata já foi contabilizada, não pode modificar."
      RETURN FALSE
   END IF

   LET m_consulta = FALSE
   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol0327_verifica_contab()
#---------------------------------#
   SELECT num_lote
     FROM desc_dup_polimetri
    WHERE cod_empresa   = p_cod_empresa
      AND num_docum     = mr_evento.num_docum
      AND ies_tip_docum = 'DP'
      AND num_lote      > 0
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------# 
 FUNCTION pol0327_exclusao_eventos() 
#----------------------------------# 
   IF pol0327_verifica_contab() = FALSE THEN
      IF log004_confirm(21,45) THEN
         CALL log085_transacao("BEGIN")
      #  BEGIN WORK 
         WHENEVER ERROR CONTINUE
           DELETE FROM lan_cont_polimetri
            WHERE cod_empresa   = p_cod_empresa
              AND num_docum     = mr_evento.num_docum
              AND ies_tip_docum = mr_evento.ies_tip_docum         
         WHENEVER ERROR STOP 
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("DELETE","LAN_CONT_POLIMETRI")
            LET m_consulta = FALSE
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK 
            RETURN FALSE
         END IF
         
         WHENEVER ERROR CONTINUE
           UPDATE desc_dup_polimetri
              SET ies_evento = NULL 
            WHERE cod_empresa   = p_cod_empresa
              AND num_docum     = mr_evento.num_docum
              AND ies_tip_docum = mr_evento.ies_tip_docum
         WHENEVER ERROR STOP 
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("MODIFICACAO","DESC_DUP_POLIMETRI")
            LET m_consulta = FALSE
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK 
            RETURN FALSE
         END IF
      ELSE
         ERROR 'Exclusão cancelada.'
         RETURN FALSE
      END IF
   ELSE
      ERROR 'Duplicata já foi contabilizada, não pode ser Excluída.'
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
#  COMMIT WORK 
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol0327_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#
