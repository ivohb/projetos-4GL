
#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1275                                                 #
# OBJETIVO: BAIXA DE ESTOQUE DE ITENS COMPRADOS                     #
# AUTOR...: IVO                                                     #
# DATA....: 11/02/15                                                #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          P_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_info           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(150),
          p_num_trans_atual    INTEGER
          

END GLOBALS

DEFINE sql_stmt            CHAR(600),
       p_last_row          SMALLINT,
       p_ies_cons          SMALLINT,
       p_qtd_linha         INTEGER,
       p_chave             CHAR(500)

DEFINE p_tela              RECORD
       dat_ini             DATE,
       dat_fim             DATE,
       cod_item            CHAR(15)
END RECORD

DEFINE pr_item             ARRAY[6000] OF RECORD 
       producao            DATE,
       ordem               INTEGER,
       item                CHAR(15),
       descricao           CHAR(18),
       unidade             CHAR(03),
       quantidade          DECIMAL(10,3),
       ies_deletar         CHAR(01)
END RECORD

DEFINE pr_chave            ARRAY[6000] OF RECORD 
       cod_empresa         CHAR(02),
       num_sequencia       INTEGER
END RECORD

DEFINE p_pendente          RECORD
       cod_empresa         CHAR(02),     
       num_sequencia       INTEGER,      
       num_ordem           INTEGER,      
       dat_producao        DATETIME YEAR TO DAY,     
       cod_compon          CHAR(15),     
       qtd_baixar          DECIMAL(10,3),
       mensagem            CHAR(20),
       num_neces           INTEGER
END RECORD

DEFINE p_relat             RECORD
       cod_item            CHAR(15),
       dat_producao        DATE,
       qtd_baixar          DECIMAL(10,3)
END RECORD

DEFINE p_dat_fecha_ult_man   LIKE par_estoque.dat_fecha_ult_man,    
       p_dat_fecha_ult_sup   LIKE par_estoque.dat_fecha_ult_sup,
       p_qtd_saldo           LIKE estoque_lote.qtd_saldo,
       p_qtd_baixar          LIKE estoque_lote.qtd_saldo,
       p_cod_item            LIKE estoque_lote.cod_item,
       p_cod_local           LIKE estoque_lote.cod_local,
       p_ies_situa           LIKE estoque_lote.ies_situa_qtd,
       p_qtd_reservada       LIKE estoque_lote.qtd_saldo,
       p_ies_ctr_lote        LIKE item.ies_ctr_lote,
       p_cod_oper_sp         LIKE par_pcp.cod_estoque_sp,
       p_den_item            LIKE item.den_item        

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1275-10.02.04  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") 
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1275_controle()
   END IF
   
END MAIN

#---------------------------#
 FUNCTION pol1275_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1275") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1275 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol1275_limpa_tela()
        
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta as baixas pendentes"
         CALL pol1275_consultar('C') RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            ERROR 'Operação efetuada com sucesso.'
         ELSE
            LET p_ies_cons = FALSE
            CALL pol1275_limpa_tela()
            ERROR 'Operação cancelada'
         END IF
      COMMAND "Excluir" "Exclui as baixas selecionadas"
         IF p_ies_cons THEN
            IF pol1275_excluir() THEN
               ERROR 'Operação efetuada com sucesso.'
            ELSE
               CALL pol1275_limpa_tela()
               ERROR 'Operação cancelada.'
            END IF
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Execute a consulta previamente.'
         END IF
      COMMAND "Processar" "Processa a baixa do material"
         CALL pol1275_processar()
         CALL log0030_mensagem(p_msg,'info')
      COMMAND "Listar" "Listagem das baixas pendentes"
         IF pol1275_listagem() THEN
            ERROR 'Operação efetuada com sucesso.'
         ELSE
            ERROR 'Operação cancelada.'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa."
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1275

END FUNCTION

#----------------------------#
 FUNCTION pol1275_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 

#-------------------------------#
FUNCTION pol1275_consultar(l_op)#
#-------------------------------#
   
   DEFINE l_op        CHAR(01)
   
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
   
   SELECT dat_corte
     INTO p_tela.dat_ini
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa
   
   IF p_tela.dat_ini IS NULL THEN
      LET p_tela.dat_ini = TODAY - 1800
   END IF
   
   LET p_tela.dat_fim = TODAY
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS 
      
      AFTER INPUT
         
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         IF p_tela.dat_ini IS NULL THEN
            LET p_tela.dat_ini = TODAY - 1800
         END IF

         IF p_tela.dat_fim IS NULL THEN
            LET p_tela.dat_fim = TODAY
         END IF
         
         IF p_tela.dat_ini > p_tela.dat_fim THEN
            ERROR 'Periodo inválido.'
            NEXT FIELD dat_ini
         END IF
  
   END INPUT
   
   IF l_op = 'C' THEN
      CALL pol1275_monta_query()
   
      IF NOT pol1275_exibe_dados() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1275_monta_query()#
#-----------------------------#

   DEFINE p_chave     CHAR(500)
   
   INITIALIZE p_chave TO NULL
   
   LET p_chave = " cod_empresa = '", p_cod_empresa,"' "
   LET p_chave = p_chave CLIPPED,    
          " AND dat_producao >= '",p_tela.dat_ini,"' "
   LET p_chave = p_chave CLIPPED,    
          " AND dat_producao <= '",p_tela.dat_fim,"' "
   
   IF p_tela.cod_item IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND cod_compon = '",p_tela.cod_item,"' "
   END IF

   LET sql_stmt = 
        "SELECT dat_producao, num_ordem, cod_compon, sum(qtd_baixar) ",
        "  FROM baixas_pendentes_885 WHERE ",p_chave CLIPPED, 
        " GROUP BY dat_producao, num_ordem, cod_compon ",
        " ORDER BY dat_producao, num_ordem, cod_compon "
           
END FUNCTION

#-----------------------------#
FUNCTION pol1275_exibe_dados()#
#-----------------------------#
   
   INITIALIZE pr_item TO NULL
   
   LET p_index = 1
   
   PREPARE var_query FROM sql_stmt   
   DECLARE cq_penden CURSOR FOR var_query
   
   FOREACH cq_penden INTO 
      pr_item[p_index].producao,
      pr_item[p_index].ordem,
      pr_item[p_index].item,
      pr_item[p_index].quantidade   
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_PENDEN')
         RETURN FALSE
      END IF
            
      SELECT den_item_reduz,
             cod_unid_med
        INTO pr_item[p_index].descricao,
             pr_item[p_index].unidade
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = pr_item[p_index].item
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ITEM.CQ_PENDEN')
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 6000 THEN
         LET p_msg = 'Limite de linhad da grade ultrapassou'
         CALL log0030_mensagem(p_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   IF p_index = 1 THEN
      LET p_msg = 'Não há dados para os \n parâmetros informados'
      CALL log0030_mensagem(p_msg,'info')
   ELSE
      LET p_qtd_linha = p_index - 1
      CALL SET_COUNT(p_index - 1)
      DISPLAY ARRAY pr_item TO sr_item.*
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1275_le_parametros()#
#-------------------------------#

   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO p_dat_fecha_ult_man,
          p_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA PAR_ESTOQUE'
      RETURN FALSE
   END IF

   SELECT cod_estoque_sp
     INTO p_cod_oper_sp
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_pcp')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
 
#---------------------------#
FUNCTION pol1275_processar()#
#---------------------------#

   CALL pol1275_consultar('P') RETURNING p_status
   
   IF NOT p_status THEN
      LET p_msg = 'Operação cancelada.'      
      CALL pol1275_limpa_tela()
      RETURN
   END IF

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1275a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1275a AT 10,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1275_baixa_compon() RETURNING p_status
   
   CLOSE WINDOW w_pol1275a
   
END FUNCTION

#------------------------------#
FUNCTION pol1275_baixa_compon()#
#------------------------------#

   IF NOT pol1275_le_parametros() THEN
      RETURN FALSE
   END IF
   
   LET p_count = 0
   
   LET sql_stmt = 
        "SELECT * FROM baixas_pendentes_885 ",
        " WHERE cod_empresa = '",p_cod_empresa,"' ",
        " AND dat_producao >= '",p_tela.dat_ini,"' ",
        " AND dat_producao <= '",p_tela.dat_fim,"' "

   IF p_tela.cod_item IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, 
          " AND cod_compon = '",p_tela.cod_item,"' "
   END IF
        
   LET sql_stmt = sql_stmt CLIPPED," ORDER BY cod_compon, dat_producao "

   PREPARE var_proces FROM sql_stmt   
   DECLARE cq_proces CURSOR WITH HOLD FOR var_proces
      
   FOREACH cq_proces INTO p_pendente.*
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_PROCES')
         RETURN FALSE
      END IF

      DISPLAY p_pendente.cod_compon TO componente
      #lds CALL LOG_refresh_display()	
      
      LET p_count = p_count + 1
      
      LET p_msg = NULL
      
      IF NOT pol1275_consiste_compon() THEN
         RETURN FALSE
      END IF
      
      IF p_msg IS NOT NULL THEN
         IF NOT pol1275_atu_baixa() THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      END IF
      
      CALL log085_transacao("BEGIN")  

      IF NOT pol1275_efetua_baixa() THEN
         CALL log085_transacao("ROLLBACK")  
         RETURN FALSE
      END IF

      IF p_msg IS NOT NULL THEN
         IF NOT pol1275_atu_baixa() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1275_del_baixa() THEN
            RETURN FALSE
         END IF
      END IF
      
      CALL log085_transacao("COMMIT")
   
   END FOREACH
   
   IF p_count = 0 THEN
      LET p_msg = 'Não há dados, para os parâmetros informados.'
   ELSE
      LET p_msg = 'Operação efetuada com sucesso.'
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1275_consiste_compon()#
#---------------------------------#
      
   IF p_dat_fecha_ult_man IS NOT NULL THEN
      IF p_pendente.dat_producao <= p_dat_fecha_ult_man THEN
         LET p_msg = 'MANUFATURA FECHADA'
         RETURN
      END IF
   END IF

   IF p_dat_fecha_ult_sup IS NOT NULL THEN
      IF p_pendente.dat_producao < p_dat_fecha_ult_sup THEN
         LET p_msg = 'ESTOQUE FECHADO'
         RETURN
      END IF
   END IF

   SELECT cod_local_estoq,
          ies_ctr_lote
     INTO p_cod_local,
          p_ies_ctr_lote
     FROM item
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = p_pendente.cod_compon
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ITEM')
      RETURN FALSE
   END IF
   
   SELECT SUM(qtd_saldo)
     INTO p_qtd_saldo
     FROM estoque_lote_ender
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = p_pendente.cod_compon
	    AND cod_local     = p_cod_local
      AND ies_situa_qtd = 'L'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ESTOQUE_LOTE_ENDER')
      RETURN FALSE
   END IF

   IF p_qtd_saldo IS NULL THEN
      LET p_qtd_saldo = 0
   END IF

   SELECT SUM(qtd_reservada)
     INTO p_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_pendente.cod_compon
      AND cod_local   = p_cod_local
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ESTOQUE_LOC_RESER')
      RETURN FALSE
   END IF  
               
   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF

   LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada

   IF p_qtd_saldo < p_pendente.qtd_baixar THEN
      LET p_msg = 'SEM SALDO P/ BAIXAR'
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1275_atu_baixa()#
#---------------------------#

   UPDATE baixas_pendentes_885
      SET mensagem = p_msg
    WHERE cod_empresa = p_pendente.cod_empresa
      AND num_sequencia = p_pendente.num_sequencia 
      AND num_ordem = p_pendente.num_ordem
      AND cod_compon = p_pendente.cod_compon

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','baixas_pendentes_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1275_del_baixa()#
#---------------------------#

   DELETE FROM baixas_pendentes_885
    WHERE cod_empresa = p_pendente.cod_empresa
      AND num_sequencia = p_pendente.num_sequencia 
      AND num_ordem = p_pendente.num_ordem
      AND cod_compon = p_pendente.cod_compon

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','baixas_pendentes_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1275_efetua_baixa()#
#------------------------------#

   DEFINE p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_baixa_do_lote      DECIMAL(10,3)

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01)
   END RECORD
   
   LET p_qtd_baixar = p_pendente.qtd_baixar
   
   IF p_ies_ctr_lote = 'S' THEN
      DECLARE cq_fifo CURSOR FOR
       SELECT *
         FROM estoque_lote_ender
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = p_pendente.cod_compon
          AND cod_local = p_cod_local
          AND ies_situa_qtd = 'L'
          AND qtd_saldo > 0
          AND num_lote IS NOT NULL
          AND num_lote <> ' '
        ORDER BY dat_hor_producao     
   ELSE
      DECLARE cq_fifo CURSOR FOR
       SELECT *
         FROM estoque_lote_ender
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = p_pendente.cod_compon
          AND cod_local = p_cod_local
          AND ies_situa_qtd = 'L'
          AND qtd_saldo > 0
          AND (num_lote IS NULL OR num_lote = ' ')
        ORDER BY dat_hor_producao     
   END IF
    
   FOREACH cq_fifo INTO p_estoque_lote_ender.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_FIFO')  
         RETURN FALSE
      END IF
      
      IF p_estoque_lote_ender.num_lote = ' ' THEN
         LET p_estoque_lote_ender.num_lote = NULL
      END IF
      
      IF p_estoque_lote_ender.num_lote IS NULL THEN
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reservada 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND num_lote IS NULL
      ELSE
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reservada 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND num_lote    = p_estoque_lote_ender.num_lote
      END IF      
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOC_RESER/CQ_FIFO'  
         RETURN FALSE
      END IF  

      IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
         LET p_qtd_reservada = 0
      END IF
      
      LET p_qtd_saldo = p_estoque_lote_ender.qtd_saldo - p_qtd_reservada
      
      IF p_qtd_saldo < p_qtd_baixar THEN
         LET p_baixa_do_lote = p_qtd_saldo
         LET p_qtd_baixar = p_qtd_baixar - p_baixa_do_lote
      ELSE
         LET p_baixa_do_lote = p_qtd_baixar
         LET p_qtd_baixar = 0
      END IF
      
      #Carrega record p_item, para chamada da func005, a qual
      #irá fazer a saída do material
      
      LET p_item.cod_empresa   = p_estoque_lote_ender.cod_empresa
      LET p_item.cod_item      = p_estoque_lote_ender.cod_item
      LET p_item.cod_local     = p_estoque_lote_ender.cod_local
      LET p_item.num_lote      = p_estoque_lote_ender.num_lote
      LET p_item.comprimento   = p_estoque_lote_ender.comprimento
      LET p_item.largura       = p_estoque_lote_ender.largura    
      LET p_item.altura        = p_estoque_lote_ender.altura     
      LET p_item.diametro      = p_estoque_lote_ender.diametro   
      LET p_item.cod_operacao  = p_cod_oper_sp
      LET p_item.ies_situa     = p_estoque_lote_ender.ies_situa_qtd
      LET p_item.qtd_movto     = p_baixa_do_lote
      LET p_item.dat_movto     = p_pendente.dat_producao
      LET p_item.ies_tip_movto = 'N'
      LET p_item.dat_proces    = TODAY
      LET p_item.hor_operac    = TIME
      LET p_item.num_prog      = 'POL1275'
      LET p_item.num_docum     = p_pendente.num_ordem
      LET p_item.num_seq       = 0
      LET p_item.tip_operacao  = 'S' #Saída
      LET p_item.usuario       = p_user
      LET p_item.cod_turno     = NULL
      LET p_item.trans_origem  = 0
      LET p_item.ies_ctr_lote  = p_ies_ctr_lote
   
      IF NOT func005_insere_movto(p_item) THEN
         CALL log0030_mensagem(p_msg,'info')
         RETURN FALSE
      END IF
      
      INSERT INTO apont_trans_885        
       VALUES(p_cod_empresa,
              p_pendente.num_sequencia,
              p_num_trans_atual,
              'B','N','N')
             
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','apont_trans_885') 
         RETURN FALSE
      END IF
      
      IF p_qtd_baixar <= 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_qtd_baixar > 0 THEN
      LET p_msg = 'SEM SALDO P/ BAIXAR'
   ELSE
      LET p_msg = NULL
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1275_excluir()#
#-------------------------#
   
   DEFINE l_tecla INTEGER,
          l_ind   INTEGER

   SELECT cod_usuario
     FROM usuario_exclui_baixa_885
    WHERE cod_usuario = p_user

   IF STATUS = 100 THEN
      LET p_msg = 'Você não está autorizado a\n',
                  'excluir baixas pendentes.'    
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','usuario_exclui_baixa_885')
         RETURN FALSE
      END IF
   END IF
   
   LET INT_FLAG = FALSE
   LET p_index = p_qtd_linha
   CALL SET_COUNT(p_index)
   
   INPUT ARRAY pr_item 
      WITHOUT DEFAULTS FROM sr_item.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD ies_deletar
         
         LET l_tecla = FGL_LASTKEY()
         
         IF l_tecla = 27 OR l_tecla = 2000 OR l_tecla= 4010
              OR l_tecla = 2016 OR l_tecla = 2 THEN
         ELSE
            IF p_index >= p_qtd_linha THEN
               NEXT FIELD ies_deletar
            END IF
         END IF
      
      AFTER INPUT
         
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         LET p_count = 0
         
         FOR l_ind = 1 TO p_qtd_linha
             IF pr_item[l_ind].ies_deletar = 'S' THEN
                LET p_count = 1
                EXIT FOR
             END IF
         END FOR
         
         IF p_count = 0 THEN
            ERROR 'Marque pelo menos um registro para excluir.'
            NEXT FIELD ies_deletar
         END IF
         
   END INPUT
   
   IF log004_confirm(18,35) THEN
   ELSE
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")  
   
   IF NOT pol1275_del_selecionados() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol1275_del_selecionados()#
#----------------------------------#

   FOR p_index = 1 TO p_qtd_linha
       IF pr_item[p_index].ies_deletar = 'S' THEN
          IF NOT pol1275_del_baixas() THEN
             RETURN FALSE
          END IF
       END IF
   END FOR
  
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1275_del_baixas()#
#----------------------------#

   DELETE FROM baixas_pendentes_885
    WHERE cod_empresa = p_cod_empresa
      AND dat_producao = pr_item[p_index].producao
      AND num_ordem = pr_item[p_index].ordem
      AND cod_compon = pr_item[p_index].item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','baixas_pendentes_885')
      RETURN FALSE
   END IF

   IF NOT pol1275_ins_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1275_ins_auditoria()#
#-----------------------------#

   DEFINE l_parametro   RECORD
          cod_empresa   LIKE audit_logix.cod_empresa,
          texto         LIKE audit_logix.texto,
          num_programa  LIKE audit_logix.num_programa,
          usuario       LIKE audit_logix.usuario
   END RECORD
   
   DEFINE l_qtd_baixar  CHAR(11),
          l_num_ordem   CHAR(11)

   LET l_qtd_baixar = pr_item[p_index].quantidade
   LET l_num_ordem = pr_item[p_index].ordem
   
   LET l_parametro.cod_empresa = p_cod_empresa
   
   LET l_parametro.texto = "EXCLUSAO DE BAIXA DE ", l_qtd_baixar CLIPPED,
        " DO ITEM ", pr_item[p_index].item CLIPPED, 
        " PREVISTO PARA A OP ", l_num_ordem CLIPPED
        
   LET l_parametro.num_programa = 'POL1275'
   LET l_parametro.usuario = p_user
   
   IF NOT func002_grava_auadit(l_parametro) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1275_listagem()#
#--------------------------#

   CALL pol1275_consultar('L') RETURNING p_status
   
   IF NOT p_status THEN
      CALL pol1275_limpa_tela()
      RETURN FALSE
   END IF

   IF NOT pol1275_le_den_empresa() THEN
      RETURN FALSE
   END IF

   IF NOT pol1275_inicializa_relat() THEN
      RETURN FALSE
   END IF
   
   LET p_count = 0
   
   LET p_chave = " cod_empresa = '", p_cod_empresa,"' "
   LET p_chave = p_chave CLIPPED,    
          " AND dat_producao >= '",p_tela.dat_ini,"' "
   LET p_chave = p_chave CLIPPED,    
          " AND dat_producao <= '",p_tela.dat_fim,"' "
   
   IF p_tela.cod_item IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND cod_compon = '",p_tela.cod_item,"' "
   END IF

   LET sql_stmt = 
        "SELECT cod_compon, dat_producao, sum(qtd_baixar) ",
        "  FROM baixas_pendentes_885 WHERE ",p_chave CLIPPED, 
        " GROUP BY cod_compon, dat_producao ",
        " ORDER BY cod_compon, dat_producao "

   PREPARE var_query2 FROM sql_stmt   
   DECLARE cq_relat CURSOR FOR var_query2
   
   FOREACH cq_relat INTO 
      p_relat.cod_item,
      p_relat.dat_producao,
      p_relat.qtd_baixar
            
      OUTPUT TO REPORT pol1275_relat(p_relat.cod_item)
      
      LET p_count = p_count + 1
   
   END FOREACH

   CALL pol1275_finaliza_relat()
   CALL log0030_mensagem(p_msg, 'excla')
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1275_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1275_inicializa_relat()#
#----------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1275_relat TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1275.tmp' 
         START REPORT pol1275_relat TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1275_relat TO p_nom_arquivo
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1275_finaliza_relat()
#--------------------------------#

   FINISH REPORT pol1275_relat
   
   IF p_count = 0 THEN
      LET p_msg = "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
      END IF
   END IF
     
END FUNCTION 

#--------------------------------#
 REPORT pol1275_relat(l_cod_item)#
#--------------------------------#
    
   DEFINE l_cod_item        CHAR(15)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
     
      ORDER EXTERNAL BY l_cod_item          
   
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 046, 'BAIXAS PENDENTES',
               COLUMN 073, 'PAG. ', PAGENO USING '##&'
         PRINT COLUMN 001, 'PERIODO DE:',
               COLUMN 013, p_tela.dat_ini USING 'dd/mm/yyyy',
               COLUMN 024, 'ATE:',
               COLUMN 029, p_tela.dat_fim USING 'dd/mm/yyyy',
               COLUMN 053, 'EMISSAO:',
               COLUMN 062, TODAY, ' ', TIME
         PRINT '--------------------------------------------------------------------------------'
        
      PAGE HEADER
	  
         PRINT COLUMN 001,  'Item: ', l_cod_item, ' - ', p_den_item, 
               COLUMN 073, 'PAG. ', PAGENO USING '##&'               
         PRINT
         PRINT COLUMN 025, '   DATA       BAIXAR'
         PRINT COLUMN 025, '---------- -------------'

      BEFORE GROUP OF l_cod_item

         SELECT den_item
           INTO p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_relat.cod_item
      
         IF STATUS <> 0 THEN
            LET p_den_item = ''
         END IF
         
         PRINT
         PRINT COLUMN 001,  'Item: ', l_cod_item, ' - ', p_den_item
         PRINT
         PRINT COLUMN 025, '   DATA       BAIXAR'
         PRINT COLUMN 025, '---------- -------------'
      
      ON EVERY ROW
         
         PRINT COLUMN 025, p_relat.dat_producao,
               COLUMN 036, p_relat.qtd_baixar USING '#,###,##&.&&&'

      AFTER GROUP OF l_cod_item
         
         PRINT
         PRINT COLUMN 001, 'Total do item:',
               COLUMN 036, GROUP SUM(p_relat.qtd_baixar) USING '#,###,##&.&&&'
         PRINT
                                             
      ON LAST ROW

         PRINT
         PRINT COLUMN 001, 'Total geral:',
               COLUMN 036, SUM(p_relat.qtd_baixar) USING '#,###,##&.&&&'

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT



#--------------FIM DO PROGRAMA-------------#
   