#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: ESP0159                                                 #
# MODULOS.: ESP0159 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: ACERTO FECHAMENTO DO ESTOQUE                            #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 13/07/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa    LIKE empresa.cod_empresa,
          p_den_empresa    LIKE empresa.den_empresa,  
          p_user           LIKE usuario.nom_usuario,
          p_cus_unit_medio LIKE estoque_hist.cus_unit_medio,
          p_qtd_mes_ant    LIKE estoque_hist.qtd_mes_ant,
          p_max_ano_mes    LIKE estoque_hist.ano_mes_ref,
          p_ies_tipo       LIKE estoque_operac.ies_tipo,
          p_cod_local      LIKE estoque_lote_ender.cod_local,
          p_num_lote       LIKE estoque_lote_ender.num_lote,
          p_ies_situa      LIKE estoque_lote_ender.ies_situa_qtd,
          p_qtd_saldo      LIKE estoque_lote.qtd_saldo,
          p_cod_local_estoq LIKE item.cod_local_estoq,
          p_qtd_saida      LIKE estoque_hist.qtd_saida,
          t_rowid          INTEGER,
          p_status         SMALLINT,
          p_houve_erro     SMALLINT,
          comando          CHAR(080),
          p_versao         CHAR(018),
          p_nom_tela       CHAR(200),
          p_nom_help       CHAR(200),
          p_ano_mes        CHAR(006),
          p_dat_aux        CHAR(010),
          p_hora           CHAR(008),
          p_ies_cons       SMALLINT,
          pa_curr          SMALLINT,
          sc_curr          SMALLINT,
          p_i              SMALLINT,
          p_dat_inicio     DATE,
          p_dat_fim        DATE,
          p_msg            CHAR(100)
          

   DEFINE p_item               RECORD LIKE item.*,
          p_estoque_hist       RECORD LIKE estoque_hist.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_est_lote_ender     RECORD LIKE estoque_lote_ender.*,
          p_est_oper_polimetri RECORD LIKE est_oper_polimetri.*

   DEFINE p_tela RECORD 
      mes_ano             CHAR(007), 
      gru_ctr_estoq       LIKE item.gru_ctr_estoq,
      den_gru_ctr_estoq   LIKE grupo_ctr_estoq.den_gru_ctr_estoq,
      cod_item            LIKE item.cod_item,
      den_item_reduz      LIKE item.den_item_reduz,
      ano_mes             DEC(6,0),
      qtd_est             DEC(15,3),
      val_est             DEC(15,2),
      qtd_tot             DEC(15,3),
      val_tot             DEC(15,2),
      qtd_saida           DEC(15,3),
      campo               CHAR(001)
   END RECORD 

   DEFINE p_rowid ARRAY[2000] OF RECORD 
          rowid   INTEGER
   END RECORD

   DEFINE t_fech_est ARRAY[2000] OF RECORD 
      ies_acerto          CHAR(001),
      cod_item            LIKE item.cod_item,
      cod_unid_med        LIKE item.cod_unid_med,
      cod_local_estoq     LIKE item.cod_local_estoq,
      cus_unit_medio      LIKE estoque_hist.cus_unit_medio,
      qtd_mes_ant         LIKE estoque_hist.qtd_mes_ant,
      val_fech            DEC(15,2),
      qtd_saida           LIKE estoque_hist.qtd_saida
   END RECORD 

   DEFINE t_qtd_mes ARRAY[2000] OF RECORD 
      qtd_mes_ant         LIKE estoque_hist.qtd_mes_ant
   END RECORD 
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "esp0159-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("esp0159.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL esp0159_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION esp0159_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("esp0159") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_esp0159 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informa Parametros para Processamento"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","esp0159","IN") THEN
            IF esp0159_entrada_dados() THEN
               NEXT OPTION "Processar"
            ELSE
               ERROR "Funcao Cancelada"
               NEXT OPTION "Fim"
            END IF 
         END IF 
      COMMAND "Processar" "Processa Acerto Fechamento Estoque"
         HELP 002
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","esp0159","MO") THEN
            IF p_ies_cons THEN 
               IF esp0159_processa() THEN
                  NEXT OPTION "Fim"
               END IF
            ELSE
               ERROR "Informar Previamente Parametros de Entrada"
               NEXT OPTION "Informar"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL esp0159_sobre() 
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
   CLOSE WINDOW w_esp0159

END FUNCTION

#-----------------------#
FUNCTION esp0159_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
 
#-------------------------------#
 FUNCTION esp0159_entrada_dados()
#-------------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp0159
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE t_fech_est,
              p_rowid,
              t_qtd_mes,
              p_tela.*,
              p_item.*,
              p_estoque_hist.*,
              p_estoque_trans.*,
              p_estoque_trans_end.* TO NULL

   LET p_houve_erro = FALSE
   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela.mes_ano,
                 p_tela.gru_ctr_estoq,
                 p_tela.cod_item
      WITHOUT DEFAULTS

      AFTER FIELD mes_ano        
      IF p_tela.mes_ano IS NULL THEN
         ERROR "O Campo Mes/Ano nao pode ser Nulo"
         NEXT FIELD mes_ano
      ELSE
         LET p_ano_mes = p_tela.mes_ano[4,7],p_tela.mes_ano[1,2]
         LET p_tela.ano_mes = p_ano_mes USING "&&&&&&"

         SELECT UNIQUE ano_mes_ref
         FROM estoque_hist
         WHERE cod_empresa = p_cod_empresa
           AND ano_mes_ref = p_tela.ano_mes
         IF SQLCA.SQLCODE = 0 THEN
            ERROR "Periodo Selecionado Já Fechado"
            NEXT FIELD mes_ano
         END IF

         SELECT UNIQUE ano_mes_ref
         FROM est_hist_polimetri
         WHERE cod_empresa = p_cod_empresa
           AND ano_mes_ref = p_tela.ano_mes
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Simulacao de Fechamento nao Processado"
            NEXT FIELD mes_ano
         END IF  

      END IF

      AFTER FIELD gru_ctr_estoq
      IF p_tela.gru_ctr_estoq IS NOT NULL THEN
         SELECT den_gru_ctr_estoq
            INTO p_tela.den_gru_ctr_estoq
         FROM grupo_ctr_estoq 
         WHERE cod_empresa = p_cod_empresa
           AND gru_ctr_estoq = p_tela.gru_ctr_estoq
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Grupo Estoque Item nao Cadastrado"
            NEXT FIELD gru_ctr_estoq
         END IF
         DISPLAY BY NAME p_tela.den_gru_ctr_estoq
         EXIT INPUT 
      END IF

      AFTER FIELD cod_item
      IF p_tela.cod_item IS NOT NULL THEN
         SELECT den_item_reduz, 
                cod_local_estoq
           INTO p_tela.den_item_reduz,
                p_cod_local_estoq
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = p_tela.cod_item
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Item nao Cadastrado"
            NEXT FIELD cod_item     
         END IF
         IF p_cod_local_estoq <> '01' AND p_cod_local_estoq <> '11' THEN
            ERROR "Local de estoque difere de 01 ou 11"
            NEXT FIELD cod_item     
         END IF
         DISPLAY BY NAME p_tela.den_item_reduz
      ELSE
         IF p_tela.gru_ctr_estoq IS NULL THEN
            MESSAGE "Não é possível processar só pelo mês/ano!!!..."
               ATTRIBUTE(REVERSE)
            ERROR 'Informe o grupo e/ou o item!!!'
            NEXT FIELD gru_ctr_estoq
         END IF
      END IF

      ON KEY (control-z)
         IF INFIELD(gru_ctr_estoq) THEN
            CALL log009_popup(6,25,"GRUPO ESTOQUE","grupo_ctr_estoq",
                             "gru_ctr_estoq","den_gru_ctr_estoq",
                             "sup0270","N","")
               RETURNING p_tela.gru_ctr_estoq
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_esp0159
            IF p_tela.gru_ctr_estoq IS NOT NULL THEN
               DISPLAY BY NAME p_tela.gru_ctr_estoq
            END IF
         END IF   
         IF INFIELD(cod_item) THEN
            LET p_tela.cod_item = min071_popup_item(p_cod_empresa)
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_esp0159
            IF p_tela.cod_item IS NOT NULL THEN
               DISPLAY BY NAME p_tela.cod_item
            END IF
         END IF   

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0159
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Operação cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE
      LET p_ies_cons = TRUE 
      RETURN TRUE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION esp0159_processa() 
#--------------------------#

   DEFINE sql_stmt CHAR(200),
          p_index  SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp0159

   LET p_tela.qtd_tot = 0
   LET p_tela.val_tot = 0

   IF p_tela.gru_ctr_estoq IS NOT NULL AND
         p_tela.cod_item IS NULL THEN
      LET sql_stmt = "SELECT * FROM item ",   
                     "WHERE cod_empresa = '", p_cod_empresa, "' ",
                     "AND ies_ctr_estoque = 'S' ",
                     "AND (cod_local_estoq = '01' OR cod_local_estoq = '11') ",
                     "AND gru_ctr_estoq = '", p_tela.gru_ctr_estoq, "' ",
                     "ORDER BY cod_item "
   END IF
   IF p_tela.gru_ctr_estoq IS NULL AND
      p_tela.cod_item IS NOT NULL THEN
      LET sql_stmt = "SELECT * FROM item ",   
                     "WHERE cod_empresa = '", p_cod_empresa, "' ",
                     "AND ies_ctr_estoque = 'S' ",
                     "AND cod_item = '", p_tela.cod_item, "' "
   END IF

   MESSAGE "Aguarde!!!...   Processando Item:"

   LET p_i = 1

   PREPARE var_query FROM sql_stmt

   DECLARE cq_item CURSOR WITH HOLD FOR var_query

   FOREACH cq_item INTO p_item.*       
   
      DISPLAY p_item.cod_item AT 21,38

      SELECT MAX(ano_mes_ref)
         INTO p_max_ano_mes
      FROM est_hist_polimetri
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = p_item.cod_item   
        AND ano_mes_ref <= p_tela.ano_mes
      
      IF p_max_ano_mes IS NULL THEN
         LET p_max_ano_mes = 190001
      END IF

      SELECT cus_unit_medio,
             qtd_mes_ant,
             rowid
        INTO p_cus_unit_medio,
             p_qtd_mes_ant,
             t_rowid
        FROM est_hist_polimetri
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_item.cod_item   
         AND ano_mes_ref = p_max_ano_mes
      
      IF SQLCA.sqlcode = NOTFOUND THEN
         LET p_cus_unit_medio = 0
         LET p_qtd_mes_ant    = 0
      END IF

      LET p_dat_aux = p_tela.ano_mes
      LET p_dat_aux = "01/", p_dat_aux[5,6], "/", p_dat_aux[1,4]
      LET p_dat_fim = p_dat_aux
      LET p_dat_fim = p_dat_fim + 1 UNITS MONTH - 1 UNITS DAY

      LET p_dat_aux = p_tela.ano_mes
      LET p_dat_aux = "01/", p_dat_aux[5,6], "/", p_dat_aux[1,4]
      LET p_dat_inicio = p_dat_aux
      LET p_dat_inicio = p_dat_inicio + 1 UNITS MONTH

      LET p_hora = TIME

   FOR p_index = 1 TO 2

      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_item.cod_item   
         AND cod_local   = p_item.cod_local_estoq

      IF p_qtd_saldo IS NULL THEN
         LET p_qtd_saldo = 0
      END IF

      DECLARE cq_est_trans CURSOR WITH HOLD FOR 
      SELECT dat_movto,
             cod_operacao,
             ies_tip_movto,
             qtd_movto,
             cod_local_est_orig,
             cod_local_est_dest,
             hor_operac
      FROM estoque_trans
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = p_item.cod_item
        AND (cod_local_est_orig = p_item.cod_local_estoq OR
             cod_local_est_dest = p_item.cod_local_estoq)
        AND dat_movto BETWEEN p_dat_inicio AND TODAY
      ORDER BY dat_movto DESC,
               hor_operac DESC

      FOREACH cq_est_trans INTO p_estoque_trans.dat_movto,
                                p_estoque_trans.cod_operacao,
                                p_estoque_trans.ies_tip_movto,
                                p_estoque_trans.qtd_movto,
                                p_estoque_trans.cod_local_est_orig,
                                p_estoque_trans.cod_local_est_dest,
                                p_estoque_trans.hor_operac

         IF p_estoque_trans.dat_movto = TODAY AND
            p_estoque_trans.hor_operac > p_hora THEN
            CONTINUE FOREACH
         END IF    

         SELECT ies_tipo
           INTO p_ies_tipo
           FROM estoque_operac 
          WHERE cod_empresa = p_cod_empresa
            AND cod_operacao = p_estoque_trans.cod_operacao
    
         IF SQLCA.SQLCODE = 100 THEN
            CONTINUE FOREACH
         END IF    

         IF p_ies_tipo = "D" AND
            p_estoque_trans.cod_local_est_orig = 
            p_estoque_trans.cod_local_est_dest THEN
            CONTINUE FOREACH
         END IF    

         IF p_estoque_trans.ies_tip_movto = "N" THEN
            IF p_ies_tipo = "E" THEN 
               LET p_qtd_saldo = p_qtd_saldo - p_estoque_trans.qtd_movto
            END IF
            IF p_ies_tipo = "S" THEN 
               LET p_qtd_saldo = p_qtd_saldo + p_estoque_trans.qtd_movto
            END IF
            IF p_ies_tipo = "D" THEN 
               IF p_estoque_trans.cod_local_est_orig=p_item.cod_local_estoq THEN
                  LET p_qtd_saldo = p_qtd_saldo + p_estoque_trans.qtd_movto
               ELSE
                  LET p_qtd_saldo = p_qtd_saldo - p_estoque_trans.qtd_movto
               END IF
            END IF
         END IF
         IF p_estoque_trans.ies_tip_movto = "R" THEN
            IF p_ies_tipo = "E" THEN 
	       LET p_qtd_saldo = p_qtd_saldo + p_estoque_trans.qtd_movto
            END IF
            IF p_ies_tipo = "S" THEN 
               LET p_qtd_saldo = p_qtd_saldo - p_estoque_trans.qtd_movto
            END IF
            IF p_ies_tipo = "D" THEN 
               IF p_estoque_trans.cod_local_est_orig=p_item.cod_local_estoq THEN
                  LET p_qtd_saldo = p_qtd_saldo - p_estoque_trans.qtd_movto
               ELSE
                  LET p_qtd_saldo = p_qtd_saldo + p_estoque_trans.qtd_movto
               END IF
            END IF
         END IF

      END FOREACH 
      
      IF p_qtd_saldo > 0 THEN

         LET t_fech_est[p_i].cod_item        = p_item.cod_item
         LET t_fech_est[p_i].cod_unid_med    = p_item.cod_unid_med
         LET t_fech_est[p_i].cod_local_estoq = p_item.cod_local_estoq
         LET t_fech_est[p_i].cus_unit_medio  = p_cus_unit_medio
         LET t_fech_est[p_i].qtd_mes_ant     = p_qtd_saldo
         LET t_fech_est[p_i].val_fech        = p_cus_unit_medio * p_qtd_saldo
     
         LET t_qtd_mes[p_i].qtd_mes_ant = p_qtd_mes_ant
      
         IF p_qtd_mes_ant >= p_qtd_saldo THEN
            LET t_fech_est[p_i].qtd_saida = p_qtd_saldo
         ELSE
            LET t_fech_est[p_i].qtd_saida = p_qtd_mes_ant
         END IF

         IF p_item.cod_local_estoq = '12' THEN  #ivo
            LET t_fech_est[p_i].qtd_saida = 0
         END IF
      
         LET p_tela.qtd_tot = p_tela.qtd_tot + t_fech_est[p_i].qtd_mes_ant
         LET p_tela.val_tot = p_tela.val_tot + t_fech_est[p_i].val_fech
         LET p_rowid[p_i].rowid = t_rowid
         LET p_i = p_i + 1
      
      END IF
      
      IF p_item.cod_local_estoq <> '11' THEN 
         EXIT FOR
      ELSE
         LET p_item.cod_local_estoq = '12'
      END IF
      
   END FOR
      
   END FOREACH

   IF p_i = 1 THEN
      ERROR "Nao Existem Itens p/ este Periodo"
      RETURN FALSE
   END IF

   DISPLAY p_tela.qtd_tot TO qtd_tot
   DISPLAY p_tela.val_tot TO val_tot

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   LET p_tela.qtd_est = 0
   LET p_tela.val_est = 0

   LET p_houve_erro = FALSE

   LET INT_FLAG = FALSE

   INPUT ARRAY t_fech_est WITHOUT DEFAULTS FROM s_fech_est.*

      BEFORE ROW
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()
         DISPLAY t_qtd_mes[pa_curr].qtd_mes_ant TO qtd_fec

      BEFORE FIELD ies_acerto
         LET p_tela.campo = t_fech_est[pa_curr].ies_acerto 

      AFTER FIELD ies_acerto     
      IF p_tela.campo = "X" AND
         t_fech_est[pa_curr].ies_acerto IS NULL THEN 
         LET p_tela.qtd_est = p_tela.qtd_est - t_fech_est[pa_curr].qtd_saida
         LET p_tela.val_est = p_tela.val_est - (t_fech_est[pa_curr].qtd_saida *
                              t_fech_est[pa_curr].cus_unit_medio)
         DISPLAY BY NAME p_tela.qtd_est, p_tela.val_est
      END IF    
      
      IF t_fech_est[pa_curr+1].ies_acerto IS NULL AND   
         t_fech_est[pa_curr+1].qtd_saida IS NULL AND   
         (FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
         FGL_LASTKEY() = FGL_KEYVAL("RETURN")) THEN
         ERROR "Nao Existem mais Registros Nesta Direcao"
         NEXT FIELD ies_acerto
      END IF   

      BEFORE FIELD qtd_saida 
      LET p_tela.qtd_saida = t_fech_est[pa_curr].qtd_saida

      AFTER FIELD qtd_saida
      IF t_fech_est[pa_curr].qtd_saida IS NULL THEN
         LET t_fech_est[pa_curr].qtd_saida = p_tela.qtd_saida
         DISPLAY t_fech_est[pa_curr].qtd_saida TO s_fech_est[sc_curr].qtd_saida
         NEXT FIELD qtd_saida
      END IF

      IF t_fech_est[pa_curr].qtd_saida > t_fech_est[pa_curr].qtd_mes_ant THEN
         ERROR "Qtde a Transferir nao pode ser Maior que Estoque"
         NEXT FIELD qtd_saida
      END IF

      LET p_qtd_saida = t_fech_est[pa_curr].qtd_saida
      
      #{ivo
      IF t_fech_est[pa_curr].cod_local_estoq = '11' THEN
         IF t_fech_est[pa_curr+1].cod_item = t_fech_est[pa_curr].cod_item AND
            t_fech_est[pa_curr+1].cod_local_estoq = '12' THEN
            LET p_qtd_saida = p_qtd_saida + t_fech_est[pa_curr+1].qtd_saida
         END IF
      END IF
      
      IF t_fech_est[pa_curr].cod_local_estoq = '12' THEN
         IF t_fech_est[pa_curr-1].cod_item = t_fech_est[pa_curr].cod_item AND
            t_fech_est[pa_curr-1].cod_local_estoq = '11' THEN
            LET p_qtd_saida = p_qtd_saida + t_fech_est[pa_curr-1].qtd_saida
         END IF
      END IF
      #---}
      
      IF p_qtd_saida > t_qtd_mes[pa_curr].qtd_mes_ant
         AND t_fech_est[pa_curr].ies_acerto = 'X' THEN
         ERROR "Qtde a Transferir nao pode ser Maior que Fechamento = ",
               t_qtd_mes[pa_curr].qtd_mes_ant
         NEXT FIELD qtd_saida
      END IF

      LET p_tela.qtd_est = 0
      LET p_tela.val_est = 0

      FOR p_i = 1 TO 2000
         IF t_fech_est[p_i].ies_acerto = "X" THEN
            LET p_tela.qtd_est = p_tela.qtd_est + t_fech_est[p_i].qtd_saida
            LET p_tela.val_est = p_tela.val_est + (t_fech_est[p_i].qtd_saida *
                                 t_fech_est[p_i].cus_unit_medio)
         END IF    
      END FOR
      DISPLAY BY NAME p_tela.qtd_est, p_tela.val_est

      IF t_fech_est[pa_curr+1].ies_acerto IS NULL AND   
         t_fech_est[pa_curr+1].qtd_saida IS NULL AND   
         (FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
         FGL_LASTKEY() = FGL_KEYVAL("RIGHT") OR 
         FGL_LASTKEY() = FGL_KEYVAL("RETURN")) THEN
         ERROR "Nao Existem mais Registros Nesta Direcao"
         NEXT FIELD ies_acerto
      END IF    


   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0159

   IF NOT INT_FLAG THEN
      IF p_ies_cons THEN 
         IF log004_confirm(21,45) THEN
            FOR p_i = 1 TO 2000
               IF t_fech_est[p_i].ies_acerto = "X" AND
                  t_fech_est[p_i].qtd_saida > 0 THEN
                  IF esp0159_inclusao_item() THEN
           	     LET p_houve_erro = FALSE
                  ELSE
           	     LET p_houve_erro = TRUE
                     EXIT FOR
                  END IF
               END IF
            END FOR
         ELSE
            CLEAR FORM
            LET p_ies_cons = FALSE
            RETURN FALSE
         END IF
      ELSE
         LET p_ies_cons = FALSE
         RETURN FALSE
      END IF
      IF p_houve_erro = FALSE THEN
         MESSAGE "Acerto Fechamento de Estoque Efetuado com Sucesso"
            ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      ELSE
         LET p_ies_cons = FALSE
         RETURN FALSE
      END IF   
   ELSE
      CLEAR FORM
      ERROR "Funcao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION esp0159_inclusao_item() 
#-------------------------------#

   DEFINE p_num_transac LIKE estoque_trans.num_transac

   SELECT * 
      INTO p_est_oper_polimetri.*
   FROM est_oper_polimetri
   WHERE cod_empresa = p_cod_empresa
   IF SQLCA.SQLCODE <> 0 THEN
      LET p_est_oper_polimetri.cod_oper_ent = " "
      LET p_est_oper_polimetri.cod_oper_sai = " "
   END IF

   LET p_estoque_trans.cod_empresa = p_cod_empresa
   LET p_estoque_trans.num_transac = 0
   LET p_estoque_trans.cod_item = t_fech_est[p_i].cod_item
   LET p_estoque_trans.dat_movto = p_dat_fim
   LET p_estoque_trans.dat_ref_moeda_fort = p_dat_fim
   LET p_estoque_trans.cod_operacao = p_est_oper_polimetri.cod_oper_sai
   LET p_estoque_trans.num_docum = NULL
   LET p_estoque_trans.num_seq = NULL
   LET p_estoque_trans.ies_tip_movto = "N"
   LET p_estoque_trans.qtd_movto = t_fech_est[p_i].qtd_saida
   LET p_estoque_trans.cus_unit_movto_p = t_fech_est[p_i].cus_unit_medio
   LET p_estoque_trans.cus_tot_movto_p = t_fech_est[p_i].cus_unit_medio *
                                         t_fech_est[p_i].qtd_saida
   LET p_estoque_trans.cus_unit_movto_f = 0
   LET p_estoque_trans.cus_tot_movto_f = 0
   LET p_estoque_trans.num_conta = NULL
   LET p_estoque_trans.num_secao_requis = NULL
   LET p_estoque_trans.cod_local_est_orig = t_fech_est[p_i].cod_local_estoq
   LET p_estoque_trans.cod_local_est_dest = NULL
   LET p_estoque_trans.num_lote_orig = NULL
   LET p_estoque_trans.num_lote_dest = NULL
   LET p_estoque_trans.ies_sit_est_orig = "L"
   LET p_estoque_trans.ies_sit_est_dest = NULL
   LET p_estoque_trans.cod_turno = NULL 
   LET p_estoque_trans.nom_usuario = p_user
   LET p_estoque_trans.dat_proces = p_dat_fim
   LET p_estoque_trans.hor_operac = TIME
   LET p_estoque_trans.num_prog = "ESP0159"

   INSERT INTO estoque_trans
      VALUES (p_estoque_trans.*)
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","ESTOQUE_TRANS")
      RETURN FALSE
   END IF

   LET p_num_transac = SQLCA.SQLERRD[2]

   LET p_estoque_trans_end.cod_empresa = p_cod_empresa
   LET p_estoque_trans_end.num_transac = p_num_transac
   LET p_estoque_trans_end.endereco = " "
   LET p_estoque_trans_end.num_volume = 0
   LET p_estoque_trans_end.qtd_movto = t_fech_est[p_i].qtd_saida
   LET p_estoque_trans_end.cod_grade_1 = " "
   LET p_estoque_trans_end.cod_grade_2 = " "
   LET p_estoque_trans_end.cod_grade_3 = " "
   LET p_estoque_trans_end.cod_grade_4 = " "
   LET p_estoque_trans_end.cod_grade_5 = " "
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura = 0
   LET p_estoque_trans_end.endereco_origem = " "
   LET p_estoque_trans_end.num_ped_ven = 0
   LET p_estoque_trans_end.num_seq_ped_ven = 0
   LET p_estoque_trans_end.dat_hor_producao = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_validade = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.num_peca = " "
   LET p_estoque_trans_end.num_serie = " "
   LET p_estoque_trans_end.comprimento = 0
   LET p_estoque_trans_end.largura = 0
   LET p_estoque_trans_end.altura = 0
   LET p_estoque_trans_end.diametro = 0
   LET p_estoque_trans_end.dat_hor_reserv_1 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_reserv_2 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_reserv_3 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.qtd_reserv_1 = 0
   LET p_estoque_trans_end.qtd_reserv_2 = 0
   LET p_estoque_trans_end.qtd_reserv_3 = 0
   LET p_estoque_trans_end.num_reserv_1 = 0
   LET p_estoque_trans_end.num_reserv_2 = 0
   LET p_estoque_trans_end.num_reserv_3 = 0
   LET p_estoque_trans_end.tex_reservado = " "
   LET p_estoque_trans_end.cus_unit_movto_p = t_fech_est[p_i].cus_unit_medio
   LET p_estoque_trans_end.cus_unit_movto_f = 0
   LET p_estoque_trans_end.cus_tot_movto_p = t_fech_est[p_i].cus_unit_medio *
                                             t_fech_est[p_i].qtd_saida
   LET p_estoque_trans_end.cus_tot_movto_f = 0
   LET p_estoque_trans_end.cod_item = t_fech_est[p_i].cod_item
   LET p_estoque_trans_end.dat_movto = p_dat_fim
   LET p_estoque_trans_end.cod_operacao = p_est_oper_polimetri.cod_oper_sai
   LET p_estoque_trans_end.ies_tip_movto = "N"
   LET p_estoque_trans_end.num_prog = "ESP0159"

   INSERT INTO estoque_trans_end
      VALUES (p_estoque_trans_end.*)
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","ESTOQUE_TRANS_END")
      RETURN FALSE
   END IF

   LET p_estoque_trans.cod_empresa = p_cod_empresa
   LET p_estoque_trans.num_transac = 0
   LET p_estoque_trans.cod_item = t_fech_est[p_i].cod_item
   LET p_estoque_trans.dat_movto = p_dat_inicio
   LET p_estoque_trans.dat_ref_moeda_fort = p_dat_inicio
   LET p_estoque_trans.cod_operacao = p_est_oper_polimetri.cod_oper_ent
   LET p_estoque_trans.num_docum = NULL
   LET p_estoque_trans.num_seq = NULL
   LET p_estoque_trans.ies_tip_movto = "N"
   LET p_estoque_trans.qtd_movto = t_fech_est[p_i].qtd_saida
   LET p_estoque_trans.cus_unit_movto_p = t_fech_est[p_i].cus_unit_medio
   LET p_estoque_trans.cus_tot_movto_p = t_fech_est[p_i].cus_unit_medio * 
                                         t_fech_est[p_i].qtd_saida
   LET p_estoque_trans.cus_unit_movto_f = 0
   LET p_estoque_trans.cus_tot_movto_f = 0
   LET p_estoque_trans.num_conta = NULL
   LET p_estoque_trans.num_secao_requis = NULL
   LET p_estoque_trans.cod_local_est_orig = NULL
   LET p_estoque_trans.cod_local_est_dest = t_fech_est[p_i].cod_local_estoq
   LET p_estoque_trans.num_lote_orig = NULL
   LET p_estoque_trans.num_lote_dest = NULL
   LET p_estoque_trans.ies_sit_est_orig = NULL
   LET p_estoque_trans.ies_sit_est_dest = "L"
   LET p_estoque_trans.cod_turno = NULL 
   LET p_estoque_trans.nom_usuario = p_user
   LET p_estoque_trans.dat_proces = p_dat_inicio
   LET p_estoque_trans.hor_operac = TIME
   LET p_estoque_trans.num_prog = "ESP0159"

   INSERT INTO estoque_trans
      VALUES (p_estoque_trans.*)
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","ESTOQUE_TRANS")
      RETURN FALSE
   END IF

   LET p_num_transac = SQLCA.SQLERRD[2]

   LET p_estoque_trans_end.cod_empresa = p_cod_empresa
   LET p_estoque_trans_end.num_transac = p_num_transac
   LET p_estoque_trans_end.endereco = " "
   LET p_estoque_trans_end.num_volume = 0 
   LET p_estoque_trans_end.qtd_movto = t_fech_est[p_i].qtd_saida
   LET p_estoque_trans_end.cod_grade_1 = " "
   LET p_estoque_trans_end.cod_grade_2 = " "
   LET p_estoque_trans_end.cod_grade_3 = " "
   LET p_estoque_trans_end.cod_grade_4 = " "
   LET p_estoque_trans_end.cod_grade_5 = " "
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura = 0
   LET p_estoque_trans_end.endereco_origem = " "
   LET p_estoque_trans_end.num_ped_ven = 0
   LET p_estoque_trans_end.num_seq_ped_ven = 0
   LET p_estoque_trans_end.dat_hor_producao = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_validade = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.num_peca = " "
   LET p_estoque_trans_end.num_serie = " "
   LET p_estoque_trans_end.comprimento = 0
   LET p_estoque_trans_end.largura = 0
   LET p_estoque_trans_end.altura = 0
   LET p_estoque_trans_end.diametro = 0
   LET p_estoque_trans_end.dat_hor_reserv_1 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_reserv_2 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_reserv_3 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.qtd_reserv_1 = 0
   LET p_estoque_trans_end.qtd_reserv_2 = 0
   LET p_estoque_trans_end.qtd_reserv_3 = 0
   LET p_estoque_trans_end.num_reserv_1 = 0
   LET p_estoque_trans_end.num_reserv_2 = 0
   LET p_estoque_trans_end.num_reserv_3 = 0
   LET p_estoque_trans_end.tex_reservado = " "
   LET p_estoque_trans_end.cus_unit_movto_p = t_fech_est[p_i].cus_unit_medio
   LET p_estoque_trans_end.cus_unit_movto_f = 0
   LET p_estoque_trans_end.cus_tot_movto_p = t_fech_est[p_i].cus_unit_medio * 
                                             t_fech_est[p_i].qtd_saida
   LET p_estoque_trans_end.cus_tot_movto_f = 0
   LET p_estoque_trans_end.cod_item = t_fech_est[p_i].cod_item
   LET p_estoque_trans_end.dat_movto = p_dat_inicio
   LET p_estoque_trans_end.cod_operacao = p_est_oper_polimetri.cod_oper_ent
   LET p_estoque_trans_end.ies_tip_movto = "N"
   LET p_estoque_trans_end.num_prog = "ESP0159"

   INSERT INTO estoque_trans_end
      VALUES (p_estoque_trans_end.*)
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","ESTOQUE_TRANS_END")
      RETURN FALSE
   END IF

   IF t_fech_est[p_i].qtd_saida > 0 THEN
      UPDATE est_hist_polimetri
         SET qtd_mes_ant = qtd_mes_ant - t_fech_est[p_i].qtd_saida
       WHERE rowid = p_rowid[p_i].rowid

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("UPDATE","EST_HIST_POLIMETRI")
         RETURN FALSE
      END IF

   END IF
   
   RETURN TRUE

END FUNCTION
#------------------------------ FIM DE PROGRAMA -------------------------------#
