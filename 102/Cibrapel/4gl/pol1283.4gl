#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1283                                                 #
# OBJETIVO: ESTORNO DE BAIXAS FEITAS PELO pol1283                   #
# AUTOR...: IVO                                                     #
# DATA....: 29/05/15                                                #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_user               LIKE usuario.nom_usuario,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,         
          p_status             SMALLINT,
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          sql_stmt             CHAR(900),
          p_caminho            CHAR(080),
          p_msg                CHAR(150)
END GLOBALS

DEFINE p_estoque_trans         RECORD LIKE estoque_trans.*

DEFINE p_nom_tela              CHAR(200),
       p_ies_cons              SMALLINT,
       p_tot_estornar          DECIMAL(11,3),
       p_ind                   INTEGER,
       s_ind                   INTEGER,
       p_qtd_linha             INTEGER,
       p_count                 INTEGER,
       p_num_transac           INTEGER

DEFINE p_tela                  RECORD
       dat_ini                 DATE,
       dat_fim                 DATE,
       cod_item                CHAR(15),
       den_item                CHAR(50)
END RECORD

DEFINE pr_item             ARRAY[6000] OF RECORD 
       producao            DATE,
       ordem               INTEGER,
       item                CHAR(15),
       descricao           CHAR(18),
       unidade             CHAR(03),
       quantidade          DECIMAL(10,3),
       ies_estornar        CHAR(01)
END RECORD

DEFINE pr_transac          ARRAY[6000] OF RECORD 
       num_transac         INTEGER
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   
   LET p_versao = 'pol1283-10.02.04  ' 
   CALL func002_versao_prg(p_versao)

   WHENEVER ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 90
      DEFER INTERRUPT

   LET p_caminho = log140_procura_caminho('pol1283.iem')

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

  IF p_status = 0  THEN
     CALL pol1283_controle() RETURNING p_status
  END IF

END MAIN       

#--------------------------#
FUNCTION pol1283_controle()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1283") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1283 AT 2,2 WITH FORM p_caminho
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   DISPLAY p_cod_empresa TO cod_empresa

   CALL pol1283_limpa_tela()
        
   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros par o processamento"
         CALL pol1283_informar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            ERROR 'Operação efetuada com sucesso.'
            NEXT OPTION 'Processar'
         ELSE
            LET p_ies_cons = FALSE
            CALL pol1283_limpa_tela()
            ERROR 'Operação cancelada'
         END IF
      COMMAND "Processar" "Processa estorno das baixas feitas pelo POL1275"
         IF p_ies_cons THEN
            IF pol1283_processar() THEN
               ERROR 'Operação efetuada com sucesso.'
            ELSE
               CALL pol1283_limpa_tela()
               ERROR 'Operação cancelada.'
            END IF
            MESSAGE ''
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Informe os parâmetros previamente.'
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

   CLOSE WINDOW w_pol1283

END FUNCTION

#----------------------------#
 FUNCTION pol1283_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 

#---------------------------#
 FUNCTION pol1283_informar()
#---------------------------#

   CALL pol1283_limpa_tela()
   
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
      
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS 
      
      AFTER FIELD cod_item
         
         IF p_tela.cod_item IS NOT NULL THEN
            SELECT den_item
              INTO p_tela.den_item
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item = p_tela.cod_item
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','item')
               NEXT FIELD cod_item
            END IF
         ELSE
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD cod_item
         END IF
         
         DISPLAY p_tela.den_item TO den_item

      ON KEY (control-z)
           CALL pol1283_popup()
         
      AFTER INPUT
         
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         IF p_tela.dat_ini IS NOT NULL THEN
            IF p_tela.dat_fim IS NOT NULL THEN
               IF p_tela.dat_ini > p_tela.dat_fim THEN
                  ERROR 'Periodo inválido.'
                  NEXT FIELD dat_ini
               END IF
            END IF
         END IF
  
   END INPUT
   
   IF NOT pol1283_sel_item() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
  
END FUNCTION 

#-----------------------#
FUNCTION pol1283_popup()
#-----------------------#
   
   DEFINE p_codigo  CHAR(15)
        
   CASE
 
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CURRENT WINDOW IS w_pol1283
         
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_item = p_codigo
            DISPLAY p_codigo TO cod_item
         END IF
         
   END CASE
            
END FUNCTION 

#--------------------------#
FUNCTION pol1283_sel_item()#
#--------------------------#
   
   DEFINE l_tecla      INTEGER,
          l_ind        INTEGER
   
   IF NOT pol1283_le_baixas() THEN
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_item 
      WITHOUT DEFAULTS FROM sr_item.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  
         
         CALL pol1283_soma_baixas()
         
      AFTER FIELD ies_estornar
         
         LET l_tecla = FGL_LASTKEY()
         
         IF l_tecla = 27 OR l_tecla = 2000 OR l_tecla= 4010
              OR l_tecla = 2016 OR l_tecla = 2 THEN
         ELSE
            IF p_ind >= p_qtd_linha THEN
               NEXT FIELD ies_estornar
            END IF
         END IF
      
      AFTER INPUT
         
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         LET p_count = 0
         
         FOR l_ind = 1 TO p_qtd_linha
             IF pr_item[l_ind].ies_estornar = 'S' THEN
                LET p_count = 1
                EXIT FOR
             END IF
         END FOR
         
         IF p_count = 0 THEN
            ERROR 'Marque pelo menos um registro para estornar.'
            NEXT FIELD ies_estornar
         END IF
         
   END INPUT
   
   RETURN TRUE
   
END FUNCTION 

#---------------------------#
FUNCTION pol1283_le_baixas()#
#---------------------------#

   DEFINE p_query      VARCHAR(2000)
  	 
	 LET p_ind = 1
	 
	 INITIALIZE pr_item, pr_transac TO NULL
 
   LET p_query =
    "SELECT estoque_trans.* FROM estoque_trans ",
    " WHERE estoque_trans.cod_empresa = '",p_cod_empresa,"' ",
    "   AND estoque_trans.num_prog = 'POL1275' ",
    "   AND estoque_trans.cod_operacao = 'BPRD' ",
    "   AND estoque_trans.ies_tip_movto = 'N' ",
    "   AND estoque_trans.cod_item IN ",
         " (SELECT item.cod_item FROM item ",
         "   WHERE item.cod_empresa = estoque_trans.cod_empresa ",
         "     AND item.ies_tip_item = 'C') ",
    "   AND estoque_trans.num_transac NOT IN ",
         " (SELECT estoque_trans_rev.num_transac_normal ",
         "    FROM estoque_trans_rev ",
         "   WHERE estoque_trans_rev.cod_empresa = estoque_trans.cod_empresa) "
   
   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED,    
          " AND estoque_trans.dat_movto >= '",p_tela.dat_ini,"' "
   END IF
   
   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED,    
          " AND estoque_trans.dat_movto <= '",p_tela.dat_fim,"' "
   END IF

   IF p_tela.cod_item IS NOT NULL THEN
      LET p_query = p_query CLIPPED,    
          " AND estoque_trans.cod_item = '",p_tela.cod_item,"' "
   END IF

   PREPARE var_query FROM p_query   
   DECLARE cq_estorna CURSOR WITH HOLD FOR var_query
   
   FOREACH cq_estorna INTO p_estoque_trans.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_estorna')
         RETURN FALSE
      END IF
      
      LET pr_transac[p_ind].num_transac = p_estoque_trans.num_transac
      LET pr_item[p_ind].producao = p_estoque_trans.dat_movto
      LET pr_item[p_ind].ordem    = p_estoque_trans.num_docum
      LET pr_item[p_ind].item     = p_estoque_trans.cod_item
      
      SELECT den_item_reduz, cod_unid_med
        INTO pr_item[p_ind].descricao,
             pr_item[p_ind].unidade
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_estoque_trans.cod_item
            
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         RETURN FALSE
      END IF

      LET pr_item[p_ind].quantidade  = p_estoque_trans.qtd_movto
      LET pr_item[p_ind].ies_estornar = 'N'
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 6000 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassou'
         CALL log003_err_sql(p_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Não há dados, para os\n parâmetros informados.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   LET p_qtd_linha = p_ind - 1

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1283_soma_baixas()#
#-----------------------------#

   DEFINE l_ind      INTEGER
   
   LET p_tot_estornar = 0
   
   FOR l_ind = 1 TO ARR_COUNT()
      IF pr_item[l_ind].ies_estornar = 'S' THEN
         LET p_tot_estornar = p_tot_estornar + pr_item[l_ind].quantidade
      END IF
   END FOR
   
   DISPLAY p_tot_estornar TO tot_estornar

END FUNCTION   
   
#--------------------------#
FUNCTION pol1283_processar()
#--------------------------#

   DEFINE p_count      INTEGER,
          p_soma       DECIMAL(12,3),
          c_soma       CHAR(12),
          l_ind        INTEGER
  

	 LET p_msg = 'Você tem certeja que deseja\n',
	             'estornar as baixas para os\n',
	             'parâmetros informados ???' 
	
	 IF NOT log0040_confirm(20,25,p_msg) THEN
	    RETURN FALSE
	 END IF

   MESSAGE 'Aguarde... processando.'
   #lds CALL LOG_refresh_display()	
	 
	 LET p_count = 0
	 LET p_soma = 0
	 
	 FOR l_ind = 1 TO p_qtd_linha
	     
	     IF pr_item[l_ind].ies_estornar = 'S' THEN
	        
	        LET p_num_transac = pr_transac[l_ind].num_transac
	        
	        IF NOT pol1283_le_movimento() THEN
	           RETURN FALSE
	        END IF

          CALL log085_transacao("BEGIN")  
      
          IF NOT pol1283_reverte_apon() THEN
             CALL log085_transacao("ROLLBACK")  
             RETURN FALSE
          END IF
      
          CALL log085_transacao("COMMIT")  

          LET p_count = p_count + 1
          LET p_soma = p_soma + p_estoque_trans.qtd_movto

	     END IF
	     
	  END FOR
     
    LET c_soma = p_soma
    LET p_msg = p_count
    LET p_msg = p_msg CLIPPED, ' baixas foram estornadas\n',
         'totalizando ', c_soma CLIPPED, ' kilos'
   
   CALL log0030_mensagem(p_msg, 'info')
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1283_le_movimento()#
#------------------------------#

   SELECT * INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_trans')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1283_reverte_apon()#
#------------------------------#

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

   LET p_item.cod_empresa   = p_estoque_trans.cod_empresa
   LET p_item.cod_item      = p_estoque_trans.cod_item
   LET p_item.cod_operacao  = p_estoque_trans.cod_operacao
   LET p_item.qtd_movto     = p_estoque_trans.qtd_movto   
   LET p_item.dat_movto     = p_estoque_trans.dat_movto   
   LET p_item.num_prog      = 'POL1283' 
   LET p_item.num_docum     = p_estoque_trans.num_docum
   LET p_item.num_seq       = p_estoque_trans.num_seq  
   LET p_item.trans_origem  = p_estoque_trans.num_transac
      
   LET p_item.cod_local     = p_estoque_trans.cod_local_est_orig
   LET p_item.num_lote      = p_estoque_trans.num_lote_orig
   LET p_item.ies_situa     = p_estoque_trans.ies_sit_est_orig


   SELECT comprimento,
          largura,    
          altura,     
          diametro   
     INTO p_item.comprimento,  
          p_item.largura,      
          p_item.altura,       
          p_item.diametro     
     FROM estoque_trans_end
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND num_transac = p_estoque_trans.num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_trans_end')
      RETURN FALSE
   END IF
      
   LET p_item.tip_operacao  = 'S' 
   LET p_item.ies_tip_movto = 'R'
   LET p_item.dat_proces    = TODAY
   LET p_item.hor_operac    = TIME 
   LET p_item.usuario       = p_user
   LET p_item.cod_turno     = '1'
   
   SELECT ies_ctr_lote
     INTO p_item.ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_item.cod_empresa
      AND cod_item = p_item.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   IF p_item.ies_ctr_lote = 'N' THEN
      LET p_item.num_lote = NULL
   END IF
      
   IF NOT func005_insere_movto(p_item) THEN
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   DELETE FROM apont_trans_885 
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND num_transac = p_estoque_trans.num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','apont_trans_885')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION
       




