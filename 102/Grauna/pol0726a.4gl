#-------------------------------------------------------------------#
# PROGRAMA: pol0726a                                                #
# OBJETIVO: MRP POR PEDIOS                                          #
# CLIENTE.: GRAUNA                                                  #
# DATA....: 02/03/2012                                              #
# POR.....: IVO H BARBOSA                                           #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       	 p_den_empresa        LIKE empresa.den_empresa,
       	 p_user               LIKE usuario.nom_usuario,
         p_index              SMALLINT,
         s_index              SMALLINT,
         p_ind                SMALLINT,
         s_ind                SMALLINT,
         p_msg                CHAR(70),
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_rowid              SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
         p_nom_tela           CHAR(200),
       	 p_status             SMALLINT,
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
         p_versao             CHAR(18),
         sql_stmt             CHAR(500),
         where_clause         CHAR(500),
         p_ies_cons           SMALLINT,
         
         p_ies_cons1           SMALLINT,	
         p_data_in						LIKE 	ped_itens.prz_entrega,
         p_data_fi						LIKE  ped_itens.prz_entrega,
         p_cod_lin_prod       char(10),
         m_ind                SMALLINT

   DEFINE p_num_seq           INTEGER,
          p_sequencia         INTEGER,
          p_gerar             CHAR(02),
          p_fantasma          CHAR(01),
          p_explodiu          CHAR(01)
   
   DEFINE p_cod_item          LIKE item.cod_item,
          p_cod_item_pai      LIKE item.cod_item,
          p_item_ordem        LIKE item.cod_item,
          p_cod_fantasma      LIKE item.cod_item,
          p_qtd_fantasma      LIKE estrutura.qtd_necessaria,
          p_ies_tip_item      LIKE item.ies_tip_item,
          p_cod_item_compon   LIKE estrutura.cod_item_compon,
          p_qtd_necessaria    LIKE estrutura.qtd_necessaria,
          p_qtd_prodcomp      LIKE estrutura.qtd_necessaria,
          p_qtd_compon        LIKE estrutura.qtd_necessaria,
          p_qtd_ordem         LIKE estrutura.qtd_necessaria,
          p_oc_linha          LIKE pedidos.num_pedido_cli,
          p_num_pedido        LIKE pedidos.num_pedido,
          p_prz_entrega       LIKE ped_itens.prz_entrega,
          p_qtd_sdo_ped       LIKE ped_itens.qtd_pecas_solic,
          p_qtd_sdo_est       LIKE estoque_lote.qtd_saldo,
          p_cod_horizon       LIKE item_man.cod_horizon,
          p_qtd_dias          LIKE horizonte.qtd_dias_horizon,
          p_qtd_sdo_ord       LIKE ordens.qtd_planej,
          p_cod_local         LIKE estoque_lote.cod_local,
          p_qtd_reservada     LIKE estoque_loc_reser.qtd_reservada,
          p_prx_num_oc        LIKE par_sup.prx_num_oc,
          p_prx_num_op        LIKE par_mrp.prx_num_ordem,
          p_prx_num_neces     LIKE par_mrp.prx_num_neces,
          p_num_oc            LIKE ordem_sup.num_oc,
          m_gru_ctr_desp       LIKE item_sup.gru_ctr_desp,
          m_num_conta          LIKE item_sup.num_conta,
          m_cod_tip_despesa    LIKE item_sup.cod_tip_despesa,
          m_ies_tip_item       LIKE item.ies_tip_item,
          m_cod_progr          LIKE item_sup.cod_progr,
          m_cod_comprador      LIKE item_sup.cod_comprador,
          m_ies_tip_incid_ipi  LIKE item_sup.ies_tip_incid_ipi,
          m_cod_fiscal         LIKE item_sup.cod_fiscal,
          m_prx_num_oc         LIKE par_sup.prx_num_oc,
          m_pct_ipi            LIKE item.pct_ipi,
          m_ies_tip_incid_icms LIKE item_sup.ies_tip_incid_icms,
          m_cod_unid_med       LIKE item.cod_unid_med,
          p_pct_refug          LIKE estrutura.pct_refug,
          p_texto              LIKE ordem_sup_txt.tex_observ_oc,
          p_num_docum          LIKE ordem_sup.num_docum
          
   DEFINE p_ordens            RECORD LIKE ordens.*,
          p_op_compl          RECORD LIKE ordens_complement.*,
          p_necessidades      RECORD LIKE necessidades.*,
          p_item_man          RECORD LIKE item_man.*,
          p_ordem_sup         RECORD LIKE ordem_sup.*,
          p_prog_ordem_sup    RECORD LIKE prog_ordem_sup.*,
          p_dest_ordem_sup    RECORD LIKE dest_ordem_sup.*,
          p_estr_ordem_sup    RECORD LIKE estrut_ordem_sup.*

   DEFINE pr_item             ARRAY[500] OF RECORD
          cod_item            LIKE item.cod_item,
          tip_item            LIKE item.ies_tip_item,
          den_item            LIKE item.den_item
   END RECORD
   
   DEFINE pr_pedido           ARRAY[500] OF RECORD
          num_pedido          LIKE ped_itens.num_pedido,
          cod_item            LIKE item.cod_item,
          tip_item            LIKE item.ies_tip_item,
          den_item_reduz      LIKE item.den_item_reduz,
          num_pedido_cli      CHAR(15)          
   END RECORD
   
   DEFINE pr_linha            ARRAY[500] OF RECORD
          cod_lin_prod        LIKE linha_prod.cod_lin_prod,
          den_estr_linprod    LIKE linha_prod.den_estr_linprod 
   END RECORD

   DEFINE pr_tela             ARRAY[100] OF RECORD
          empresa             CHAR(02),
          data_in             DATE,
          data_fi             DATE,
          msg                 CHAR(15)
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT 
   LET p_versao = "pol0726a-05.10.00"
   INITIALIZE p_data_fi TO NULL 
   INITIALIZE p_data_in TO NULL
   
   
   OPTIONS
     NEXT KEY control-f,
     PREVIOUS KEY control-b,
     DELETE KEY control-e

   CALL log001_acessa_usuario("VDP","LIC_LIB")     
       RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0726a_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0726a_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0726a") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0726a AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa to cod_empresa
   
   IF NOT pol0726a_cria_tmp() THEN
      RETURN FALSE
   END IF
   
   LET m_ind = 0
   
   DECLARE cq_emp CURSOR WITH HOLD FOR
    SELECT DISTINCT 
           cod_empresa,
           dat_ini,
           dat_fim
      FROM par_mrp_454
     ORDER BY cod_empresa
   
   FOREACH cq_emp INTO 
           p_cod_empresa,
           p_data_in,
           p_data_fi

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'par_mrp_454:cq_par')
         RETURN
      END IF

      DELETE from item_tmp_1040
      
      LET m_ind = m_ind + 1
      
      CALL pol0726a_exib_mensagem()
      
      DECLARE cq_lin CURSOR FOR
       SELECT cod_lin_prod
         FROM par_mrp_454
        WHERE cod_empresa = p_cod_empresa
        ORDER BY cod_lin_prod
   
      FOREACH cq_lin INTO 
              p_cod_lin_prod

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'par_mrp_454:cq_par')
            RETURN
         END IF

	       DECLARE cq_vdp CURSOR FOR
	        SELECT a.cod_item 
	          FROM item a,
	               item_vdp b
	         WHERE a.cod_empresa  = p_cod_empresa
	           AND a.cod_lin_prod = p_cod_lin_prod
	           AND a.ies_tip_item <> 'C'
	           AND a.ies_tip_item <> 'T'
	           AND a.ies_situacao = 'A'
	           AND b.cod_empresa  = a.cod_empresa
	           AND b.cod_item     = a.cod_item
	          
	       FOREACH cq_vdp INTO p_cod_item
	          
	          IF STATUS <> 0 THEN
	             CALL log003_err_sql('Lendo','item/item_vdp')
	             RETURN FALSE
	          END IF
	          
	          INSERT INTO item_tmp_1040
	           VALUES(p_cod_item)
	          
	          IF STATUS <> 0 THEN
	             CALL log003_err_sql('Inserindo','item_tmp_1040')
	             RETURN FALSE
	          END IF

	       END FOREACH

      END FOREACH

      DELETE from estrut_item_1040
      
      CALL log085_transacao("BEGIN")
      IF pol0726a_processa('L') THEN
         CALL log085_transacao("COMMIT")
      ELSE 
         CALL log085_transacao("ROLLBACK")
      END IF

   END FOREACH
  
   CLOSE WINDOW w_pol0726a

END FUNCTION

#-------------------------------#
FUNCTION pol0726a_exib_mensagem()
#-------------------------------#

   LET pr_tela[m_ind].empresa = p_cod_empresa
   LET pr_tela[m_ind].data_in = p_data_in
   LET pr_tela[m_ind].data_fi = p_data_fi
   LET pr_tela[m_ind].msg = "Processando..."
   
   CALL SET_COUNT(m_ind)
   
   INPUT ARRAY pr_tela 
      WITHOUT DEFAULTS FROM sr_tela.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION

#----------------------#
FUNCTION pol0726a_pedido()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0726a4") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0726a4 AT 5,7 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
    COMMAND "Informar" "Informa parâmetros p/ o processamento"
       IF pol0726a_informar('P') THEN
          ERROR 'Parâmetros infomados com sucesso !!!'
          LET p_ies_cons = TRUE
          NEXT OPTION 'Processar'
       ELSE
          ERROR 'Operação cancelada !!!'
          LET p_ies_cons = FALSE
          NEXT OPTION 'Fim'
       END IF
    COMMAND "Processar" "Processa a Geração das ordens"
       IF p_ies_cons THEN
          IF log004_confirm(18,35) THEN
             MESSAGE 'AGUARDE!... PROCESSANDO.'
             CALL log085_transacao("BEGIN")
             IF pol0726a_processa('P') THEN
                CALL log085_transacao("COMMIT")
                ERROR 'Processamento efetuado com sucesso !!!'
             ELSE 
                CALL log085_transacao("ROLLBACK")
                ERROR 'Operação cancelada !!!'
             END IF
             LET p_ies_cons = FALSE
             CLEAR FORM
             NEXT OPTION 'Fim'
          END IF
       ELSE
          ERROR 'Informe previamente os parâmetros!!!'
          NEXT OPTION 'Informar'
       END IF
    COMMAND KEY ("!")
       PROMPT "Digite o comando : " FOR comando
       RUN comando
       PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
       DATABASE logix
       LET INT_FLAG = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
       EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol06271

END FUNCTION

#----------------------#
FUNCTION pol0726a_item()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0726a1") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0726a1 AT 5,7 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
    COMMAND "Informar" "Informa parâmetros p/ o processamento"
       IF pol0726a_informar('I') THEN
          ERROR 'Parâmetros infomados com sucesso !!!'
          LET p_ies_cons = TRUE
          NEXT OPTION 'Processar'
       ELSE
          ERROR 'Operação cancelada !!!'
          LET p_ies_cons = FALSE
          NEXT OPTION 'Fim'
       END IF
    COMMAND "Processar" "Processa a Geração das ordens"
       IF p_ies_cons THEN
          IF log004_confirm(18,35) THEN
             MESSAGE 'AGUARDE!... PROCESSANDO.'
             CALL log085_transacao("BEGIN")
             IF pol0726a_processa('I') THEN
                CALL log085_transacao("COMMIT")
                ERROR 'Processamento efetuado com sucesso !!!'
             ELSE 
                CALL log085_transacao("ROLLBACK")
                ERROR 'Operação cancelada !!!'
             END IF
             LET p_ies_cons = FALSE
             CLEAR FORM
             NEXT OPTION 'Fim'
          END IF
       ELSE
          ERROR 'Informe previamente os parâmetros!!!'
          NEXT OPTION 'Informar'
       END IF
    COMMAND KEY ("!")
       PROMPT "Digite o comando : " FOR comando
       RUN comando
       PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
       DATABASE logix
       LET INT_FLAG = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
       EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol06271

END FUNCTION
#-----------------------#
FUNCTION pol0726a_linha()
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0726a2") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0726a2 AT 5,7 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
    COMMAND "Informar" "Informa parâmetros p/ o processamento"
       IF pol0726a_informar('L') THEN
          ERROR 'Parâmetros infomados com sucesso !!!'
          LET p_ies_cons = TRUE
          NEXT OPTION 'Processar'
       ELSE
          ERROR 'Operação cancelada !!!'
          LET p_ies_cons = FALSE
          NEXT OPTION 'Fim'
       END IF
    COMMAND "Processar" "Processa a Geração das ordens"
       IF p_ies_cons THEN
          IF log004_confirm(18,35) THEN
             MESSAGE 'AGUARDE!... PROCESSANDO.'
             CALL log085_transacao("BEGIN")
             IF pol0726a_processa('L') THEN
                CALL log085_transacao("COMMIT")
                ERROR 'Processamento efetuado com sucesso !!!'
             ELSE 
                CALL log085_transacao("ROLLBACK")
                ERROR 'Operação cancelada !!!'
             END IF
             LET p_ies_cons = FALSE
             CLEAR FORM
             NEXT OPTION 'Fim'
          END IF
       ELSE	
       		IF log0040_confirm(18,35,'Deseja processar todos as linhas?') THEN
       			MESSAGE 'AGUARDE!... PROCESSANDO.'
       			IF select_linha(FALSE) THEN 
	             CALL log085_transacao("BEGIN")
	             IF pol0726a_processa('L') THEN
	                CALL log085_transacao("COMMIT")
	                ERROR 'Processamento efetuado com sucesso !!!'
	             ELSE 
	                CALL log085_transacao("ROLLBACK")
	                ERROR 'Operação cancelada !!!'
	             END IF
	             CLEAR FORM
	             NEXT OPTION 'Fim'
	           END IF 
       		ELSE
	          ERROR 'Informe previamente os parâmetros!!!'
	          NEXT OPTION 'Informar'
	        END IF 
       END IF
    COMMAND KEY ("!")
       PROMPT "Digite o comando : " FOR comando
       RUN comando
       PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
       DATABASE logix
       LET INT_FLAG = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
       EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol06272

END FUNCTION

#-------------------------------#
FUNCTION pol0726a_informar(p_info)
#-------------------------------#
   
   DEFINE p_info CHAR(01)
   
   IF NOT pol0726a_cria_item_tmp() THEN
      RETURN FALSE
   END IF

   IF p_info = 'P' THEN
      CALL select_itens_pedidos() RETURNING p_status
   ELSE
      IF p_info = 'I' THEN
         CALL select_itens() RETURNING p_status
      ELSE
         CALL select_linha(TRUE) RETURNING p_status
      END IF
   END IF      

   IF NOT p_status THEN
      RETURN FALSE
   END IF

   SELECT COUNT(cod_item)
     INTO p_count
     FROM item_tmp_1040

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_tmp_1040')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
     LET p_msg = 'Nenhum parâmetro foi informado.'
     CALL log0030_mensagem(p_msg,'exclamation')
     RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#-----------------------------#
FUNCTION select_itens_pedidos()
#-----------------------------#

   INITIALIZE pr_pedido TO NULL

   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_pedido
      WITHOUT DEFAULTS FROM sr_pedido.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD num_pedido
         IF pr_pedido[p_index].num_pedido IS NOT NULL THEN
            IF pol0726a_repetiu_pedido() THEN
               ERROR "Pedido já Indormado !!!"
               NEXT FIELD num_pedido
            END IF
            IF NOT pol0726a_le_pedido(pr_pedido[p_index].num_pedido) THEN
               RETURN FALSE
            END IF
            IF p_msg IS NOT NULL THEN
               ERROR p_msg
               NEXT FIELD num_pedido
            END IF
            DISPLAY pr_pedido[p_index].cod_item TO
                    sr_pedido[p_index].cod_item            
            DISPLAY pr_pedido[p_index].tip_item TO
                    sr_pedido[p_index].tip_item
            DISPLAY pr_pedido[p_index].den_item_reduz TO
                    sr_pedido[s_index].den_item_reduz
            DISPLAY pr_pedido[p_index].num_pedido_cli TO
                    sr_pedido[s_index].num_pedido_cli                   
         ELSE
            IF FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2000 THEN
            ELSE
               ERROR 'Campo com preenchimento obrigatório!'
               NEXT FIELD num_pedido
            END IF
         END IF
         
{      ON KEY (control-z)
         CALL pol0726a_popup()}
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_pedido[p_ind].cod_item IS NOT NULL THEN
          
          INSERT INTO item_tmp_1040
           VALUES(pr_pedido[p_ind].cod_item)
          
          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo 3','item_tmp_1040')
             RETURN FALSE
          END IF
          
          INSERT INTO pedido_tmp_1040
           VALUES(pr_pedido[p_ind].num_pedido)
          
          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','pedido_tmp_1040')
             RETURN FALSE
          END IF
          
          
       END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#----------------------#
FUNCTION select_itens()
#----------------------#

   INITIALIZE pr_item TO NULL

   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_item
      WITHOUT DEFAULTS FROM sr_item.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD cod_item
         IF pr_item[p_index].cod_item IS NOT NULL THEN
            IF pol0726a_repetiu_cod() THEN
               ERROR "Item já Indormado !!!"
               NEXT FIELD cod_item
            END IF
            IF NOT pol0726a_le_item(pr_item[p_index].cod_item) THEN
               RETURN FALSE
            END IF
            IF p_msg IS NOT NULL THEN
               ERROR p_msg
               NEXT FIELD cod_item
            END IF
            DISPLAY pr_item[p_index].tip_item TO
                    sr_item[p_index].tip_item
            DISPLAY pr_item[p_index].den_item TO
                    sr_item[s_index].den_item
         ELSE
            IF FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2000 THEN
            ELSE
               ERROR 'Campo com preenchimento obrigatório!'
               NEXT FIELD cod_item
            END IF
         END IF
         
      ON KEY (control-z)
         CALL pol0726a_popup()
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_item[p_ind].cod_item IS NOT NULL THEN
          
          INSERT INTO item_tmp_1040
           VALUES(pr_item[p_ind].cod_item)
          
          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','item_tmp_1040')
             RETURN FALSE
          END IF
          
       END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION
#-------------------------------#
FUNCTION pol0726a_repetiu_pedido()
#-------------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_pedido[p_ind].num_pedido= pr_pedido[p_index].num_pedido THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION
#-------------------------------#
FUNCTION pol0726a_repetiu_cod()
#-------------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_item[p_ind].cod_item = pr_item[p_index].cod_item THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0726a_le_item(p_cod_item)
#----------------------------------#

    DEFINE p_cod_item LIKE item.cod_item
    
    INITIALIZE p_msg TO NULL
    
    SELECT cod_item
      FROM item_vdp
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_cod_item

    IF STATUS = 100 THEN
       LET p_msg = 'Esse item não é vendido!'
    ELSE
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','Item_vdp')
          RETURN FALSE
       END IF
    END IF

    SELECT den_item, 
           ies_tip_item
      INTO pr_item[p_index].den_item,
           pr_item[p_index].tip_item
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = pr_item[p_index].cod_item
    
    IF STATUS = 100 THEN
       LET p_msg = 'item Inexistente!!!'
    ELSE
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','Item')
          RETURN FALSE
       END IF
    END IF
    
    IF pr_item[p_index].tip_item MATCHES '[CT]' THEN
       LET p_msg = 'Tipo do item inválido: ',pr_item[p_index].tip_item
    END IF

    RETURN TRUE
    
END FUNCTION
#--------------------------------------#
FUNCTION pol0726a_le_pedido(p_num_pedido)
#--------------------------------------#

    DEFINE p_num_pedido      LIKE ped_itens.num_pedido,
           t_cod_item        LIKE ped_itens.cod_item,
           t_ies_sit_pedido  LIKE pedidos.ies_sit_pedido,   
           t_num_pedido_cli  CHAR(15)
    
    INITIALIZE p_msg, t_cod_item, t_num_pedido_cli, t_ies_sit_pedido  TO NULL
    
    SELECT b.cod_item,
           a.ies_sit_pedido,
           a.num_pedido_cli[1,15]   
      INTO t_cod_item,
           t_ies_sit_pedido,
           t_num_pedido_cli
      FROM pedidos a, ped_itens b, item c
     WHERE a.cod_empresa   = p_cod_empresa
       AND a.num_pedido    = p_num_pedido
       AND a.cod_empresa   = b.cod_empresa
       AND a.num_pedido    = b.num_pedido
       AND b.cod_empresa   = c.cod_empresa 
       AND b.cod_item      = c.cod_item
       AND (b.qtd_pecas_solic - b.qtd_pecas_atend - b.qtd_pecas_cancel)>0
       AND b.num_sequencia = 1  
       AND( b.prz_entrega >= p_data_in  
       AND	b.prz_entrega <= p_data_fi)					{<------10/03/2009----}
       

    IF STATUS = 100 THEN
       LET p_msg = 'Esse pedido não foi encontrado ou está s/ saldo ou esta fora dos parametros!'
       RETURN TRUE
    ELSE
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','Pedido')
          RETURN FALSE
       END IF
    END IF
      
    IF t_ies_sit_pedido = '9' THEN
       LET p_msg = 'Esse pedido está cancelado!'
       RETURN TRUE
    END IF  
      
    LET pr_pedido[p_index].cod_item         =   t_cod_item      
    LET pr_pedido[p_index].num_pedido_cli   =   t_num_pedido_cli
    
    SELECT den_item_reduz, 
           ies_tip_item
      INTO pr_pedido[p_index].den_item_reduz,
           pr_pedido[p_index].tip_item
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = t_cod_item 
    
    IF STATUS = 100 THEN
       LET p_msg = 'item Inexistente!!!'
    ELSE
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','Item')
          RETURN FALSE
       END IF
    END IF
    
    IF pr_pedido[p_index].tip_item MATCHES '[T]' THEN
       LET p_msg = 'Tipo do item inválido: ',pr_pedido[p_index].tip_item
    END IF

    RETURN TRUE
    
END FUNCTION
#----------------------#
FUNCTION select_linha(l_status)					#Alterado 29/05/2009 a pedido do cliente
#----------------------#
DEFINE l_status 	SMALLINT 							#Essa alteraçao foi feita para selecionar todas as 
   INITIALIZE pr_linha TO NULL					#linhas caso não informe nenhum parametro por isso
																				#foi inserido o parametro l_status para identificar 
   LET INT_FLAG = FALSE									#se foi informado o parametro ou não
   IF l_status THEN 
	   INPUT ARRAY pr_linha
	      WITHOUT DEFAULTS FROM sr_linha.*
	      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
	      
	      BEFORE ROW
	         LET p_index = ARR_CURR()
	         LET s_index = SCR_LINE()  
	
	      AFTER FIELD cod_lin_prod
	         IF pr_linha[p_index].cod_lin_prod IS NOT NULL THEN
	            IF pol0726a_repetiu_linha() THEN
	               ERROR "Area/Linha já Indormado !!!"
	               NEXT FIELD cod_lin_prod
	            END IF
	            IF NOT pol0726a_le_linha_prod() THEN
	               RETURN FALSE
	            END IF
	            IF p_msg IS NOT NULL THEN
	               ERROR p_msg
	               NEXT FIELD cod_lin_prod
	            END IF
	            DISPLAY pr_linha[p_index].den_estr_linprod TO 
	                    sr_linha[p_index].den_estr_linprod
	         ELSE
	            IF FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2000 THEN
	            ELSE
	               ERROR 'Campo com preenchimento obrigatório!'
	               NEXT FIELD cod_lin_prod
	            END IF
	         END IF
	         
	      ON KEY (control-z)
	         CALL pol0726a_popup()
	         
	   END INPUT 
	
	   IF INT_FLAG THEN
	      RETURN FALSE
	   END IF
	
	   FOR p_ind = 1 TO ARR_COUNT()
	       
	       IF pr_linha[p_ind].cod_lin_prod IS NOT NULL THEN
	          
	          DECLARE cd_vdp CURSOR FOR
	           SELECT a.cod_item 
	             FROM item a,
	                  item_vdp b
	            WHERE a.cod_empresa  = p_cod_empresa
	              AND a.cod_lin_prod = pr_linha[p_ind].cod_lin_prod
	              AND a.ies_tip_item <> 'C'
	              AND a.ies_tip_item <> 'T'
	              AND a.ies_situacao = 'A'
	              AND b.cod_empresa  = a.cod_empresa
	              AND b.cod_item     = a.cod_item
	          
	          FOREACH cd_vdp INTO p_cod_item
	          
	             IF STATUS <> 0 THEN
	                CALL log003_err_sql('Lendo','item/item_vdp')
	                RETURN FALSE
	             END IF
	          
	             INSERT INTO item_tmp_1040
	              VALUES(p_cod_item)
	          
	             IF STATUS <> 0 THEN
	                CALL log003_err_sql('Inserindo','item_tmp_1040')
	                RETURN FALSE
	             END IF
	          END FOREACH
	       END IF
	   END FOR
   ELSE 
			DECLARE cp_vdp_todo CURSOR FOR  SELECT UNIQUE a.cod_item 						#vai ler todos os itens de todas as
													             FROM item a,												#linhas e inserir numa tabela tempo
													                  item_vdp b										#-raria
													            WHERE a.cod_empresa  = p_cod_empresa
													              AND a.ies_tip_item <> 'C'
													              AND a.ies_tip_item <> 'T'
													              AND a.ies_situacao = 'A'
													              AND b.cod_empresa  = a.cod_empresa
													              AND b.cod_item     = a.cod_item
													              AND a.cod_lin_prod IN (select unique cod_lin_prod from linha_prod)
			FOREACH cp_vdp_todo INTO p_cod_item
				IF STATUS <> 0 THEN
					CALL log003_err_sql('Lendo','item/item_vdp')
					RETURN FALSE
				END IF
				
				INSERT INTO item_tmp_1040
					VALUES(p_cod_item)
				
				IF STATUS <> 0 THEN
					CALL log003_err_sql('Inserindo','item_tmp_1040')
					RETURN FALSE
				END IF
			END FOREACH
   END IF 
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0726a_repetiu_linha()
#-------------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_linha[p_ind].cod_lin_prod = pr_linha[p_index].cod_lin_prod THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0726a_le_linha_prod()
#-------------------------------#

   INITIALIZE p_msg TO NULL
   
   SELECT den_estr_linprod
     INTO pr_linha[p_index].den_estr_linprod
     FROM linha_prod
    WHERE cod_lin_prod  = pr_linha[p_index].cod_lin_prod
      AND cod_lin_recei = 0
      AND cod_seg_merc  = 0
      AND cod_cla_uso   = 0

   IF STATUS = 100 THEN
      LET p_msg = 'Area/Linha Inexistente!'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','linha_prod')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol0726a_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0726a1
         IF p_codigo IS NOT NULL THEN
           LET pr_item[p_index].cod_item = p_codigo
           DISPLAY p_codigo TO sr_item[s_index].cod_item
         END IF

      WHEN INFIELD(cod_lin_prod)
         LET p_codigo = pol0726a_exibe_linha()
         CURRENT WINDOW IS w_pol0726a2
         IF p_codigo IS NOT NULL THEN
           LET pr_linha[p_index].cod_lin_prod = p_codigo
           DISPLAY p_codigo TO sr_linha[s_index].cod_lin_prod
         END IF

   END CASE

END FUNCTION

#-----------------------------#
FUNCTION pol0726a_exibe_linha()
#-----------------------------#

   DEFINE pr_area             ARRAY[1000] OF RECORD
          cod_lin_prod        LIKE linha_prod.cod_lin_prod,
          den_estr_linprod    LIKE linha_prod.den_estr_linprod 
   END RECORD

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0726a3") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0726a3 AT 8,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INITIALIZE pr_area TO NULL
   LET p_ind = 1
   
   DECLARE cq_area CURSOR FOR   
    SELECT cod_lin_prod,
           den_estr_linprod
      FROM linha_prod
     WHERE cod_lin_recei = 0
       AND cod_seg_merc  = 0
       AND cod_cla_uso   = 0

   FOREACH cq_area INTO 
           pr_area[p_ind].cod_lin_prod,
           pr_area[p_ind].den_estr_linprod

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','linha_prod')
         RETURN
      END IF

      LET p_ind = p_ind + 1
      
      IF p_ind > 1000 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassado.'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_ind)
   
   DISPLAY ARRAY pr_area TO sr_area.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol0726a3
   
   IF INT_FLAG = 0 THEN
      RETURN pr_area[p_ind].cod_lin_prod
   ELSE
      LET INT_FLAG = 0
      RETURN ''
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0726a_cria_tmp()
#----------------------------#

   DROP TABLE item_tmp_1040

   CREATE TABLE item_tmp_1040(
         cod_item      CHAR(15)
    );
         
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","item_tmp_1040")
      RETURN FALSE
   END IF

   DROP TABLE estrut_item_1040

   CREATE TABLE estrut_item_1040(
         num_seq       INTEGER,
         cod_item_pai  CHAR(15),
         cod_item      CHAR(15),
         tip_item      CHAR(01),
         cod_local     CHAR(10),
         qtd_prodcomp  DECIMAL(10,3),
         gerar         CHAR(02),
         explodiu      CHAR(01)
       );
         
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","estrut_item_1040")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol0726a_processa(p_processa)
#------------------------------------#

   DEFINE p_processa CHAR(01)
   
   IF NOT pol0726a_bloqueia_tab() THEN
      RETURN FALSE
   END IF
 
   DECLARE cq_tmp CURSOR FOR
    SELECT cod_item
      FROM item_tmp_1040
     ORDER BY cod_item
   
   FOREACH cq_tmp INTO p_cod_item

       IF NOT pol0726a_le_tip_local(p_cod_item) THEN
          RETURN FALSE
       END IF   

       IF NOT pol0726a_insere_item() THEN
          RETURN FALSE
       END IF

       IF NOT pol0726a_explode_estrutura() THEN
          RETURN FALSE
       END IF
       
       IF p_processa  = 'P'   THEN 
          IF NOT pol0726a_gera_ordens_ped() THEN
             RETURN FALSE
          END IF
       ELSE
          IF NOT pol0726a_gera_ordens() THEN
             RETURN FALSE
          END IF
       END IF
       
       IF NOT pol0726a_deleta_estrut() THEN
          RETURN FALSE
       END IF
   
  END FOREACH

  RETURN TRUE
  
END FUNCTION

#---------------------------------------#
FUNCTION pol0726a_le_tip_local(p_cod_item)
#---------------------------------------#

   DEFINE p_cod_item LIKE item.cod_item

   SELECT ies_tip_item,
          cod_local_estoq
     INTO p_ies_tip_item,
          p_cod_local
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:local')
      RETURN FALSE
   END IF

  RETURN TRUE
  
END FUNCTION

#------------------------------#
FUNCTION pol0726a_bloqueia_tab()
#------------------------------#

   LOCK TABLE item_tmp_1040 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') BLOQUEANDO ITEM_TMP_1040'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0726a_deleta_oc()
#---------------------------#

   DECLARE cq_sup CURSOR FOR
    SELECT num_oc
      FROM ordem_sup
     WHERE cod_empresa   = p_cod_empresa
       AND ies_situa_oc  = 'P'
       AND ies_origem_oc = 'H'
       AND num_docum     = p_num_pedido
         

   FOREACH cq_sup INTO p_num_oc

      DELETE FROM ordem_sup
            WHERE cod_empresa   = p_cod_empresa
              AND num_oc        = p_num_oc
              AND ies_situa_oc  = 'P'
              AND ies_origem_oc = 'H'
   
        IF STATUS <> 0 THEN
           CALL log003_err_sql('Deletando','ordem_sup')
           RETURN FALSE
        END IF 

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_sup:cq_sup')
         RETURN FALSE
      END IF 

      DELETE FROM prog_ordem_sup
       WHERE cod_empresa = p_cod_empresa
         AND num_oc      = p_num_oc

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Deletando','prog_ordem_sup')
         RETURN FALSE
      END IF 

      DELETE FROM dest_ordem_sup
       WHERE cod_empresa = p_cod_empresa
         AND num_oc      = p_num_oc

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Deletando','dest_ordem_sup')
         RETURN FALSE
      END IF 

      DELETE FROM estrut_ordem_sup
       WHERE cod_empresa = p_cod_empresa
         AND num_oc      = p_num_oc

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Deletando','estrut_ordem_sup')
         RETURN FALSE
      END IF 

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0726a_deleta_estrut()
#------------------------------#

   DELETE FROM estrut_item_1040
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estrut_item_1040')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0726a_deleta_ops()
#----------------------------#

   DEFINE p_num_ordem LIKE ordens.num_ordem
          
   DECLARE cq_del_neces CURSOR FOR
    SELECT num_ordem
      FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_lote    = p_oc_linha
      AND ies_situa   = '1'
      AND ies_origem  = 'H'
      AND num_docum   = p_num_pedido  

   FOREACH cq_del_neces INTO p_num_ordem
      DELETE FROM necessidades
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_num_ordem

      IF STATUS <> 0 then
         CALL log003_err_sql("Deletando","necessidades:cq_del_neces")
         RETURN FALSE
      END IF

      DELETE FROM ordens_complement
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_num_ordem

      IF STATUS <> 0 then
         CALL log003_err_sql("Deletando","ordens_complement:cq_del_neces")
         RETURN FALSE
      END IF
   
   END FOREACH

   DELETE FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_lote    = p_oc_linha
      AND ies_situa   = '1'
      AND ies_origem  = 'H'
      
   IF STATUS <> 0 then
      CALL log003_err_sql("Deletando","ordens:cq_del_neces")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION pol0726a_insere_item()
#-----------------------------#

   LET p_num_seq = 1
 
   IF p_ies_tip_item = 'T' THEN
      LET p_gerar = NULL
   ELSE
      IF p_ies_tip_item MATCHES '[FP]' THEN
         LET p_gerar = 'OP'
      ELSE
         LET p_gerar = 'OC'
      END IF
   END IF

   INSERT INTO estrut_item_1040
      VALUES(p_num_seq,
             0,
             p_cod_item, 
             p_ies_tip_item,
             p_cod_local,
             1,
             p_gerar,
             'N')

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("Iserindo","estrut_item_1040")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0726a_explode_estrutura()
#-----------------------------------#

   WHILE TRUE
    
    SELECT COUNT(cod_item)
      INTO p_count
      FROM estrut_item_1040
     WHERE explodiu = 'N'
     
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','estrut_item_1040:while')
       RETURN FALSE
    END IF
    
    IF p_count = 0 THEN
       EXIT WHILE
    END IF
    
    DECLARE cq_exp CURSOR FOR
     SELECT num_seq,
            cod_item,
            qtd_prodcomp
       FROM estrut_item_1040
      WHERE explodiu = 'N'
    
    FOREACH cq_exp INTO p_sequencia, p_cod_item_pai, p_qtd_prodcomp
    
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','estrut_item_1040:cq_exp')
          RETURN FALSE
       END IF
       
       UPDATE estrut_item_1040
          SET explodiu = 'S'
        WHERE num_seq = p_sequencia

       IF STATUS <> 0 THEN
          CALL log003_err_sql('Atualizando','estrut_item_1040:cq_exp')
          RETURN FALSE
       END IF

       DECLARE cq_est CURSOR FOR
        SELECT cod_item_compon,
               qtd_necessaria,
               pct_refug
          FROM estrutura
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item_pai = p_cod_item_pai
           AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
               (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
               (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
               (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
       
       FOREACH cq_est INTO p_cod_item_compon, p_qtd_necessaria, p_pct_refug

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Lendo','estrutura:cq_est')
             RETURN FALSE
          END IF
       
          IF NOT pol0726a_le_tip_item() THEN
             RETURN FALSE
          END IF
          
          LET p_qtd_necessaria = p_qtd_necessaria + (p_qtd_necessaria * p_pct_refug / 100)
          LET p_num_seq = p_num_seq + 1
          LET p_qtd_compon = p_qtd_prodcomp * p_qtd_necessaria

          IF p_ies_tip_item = 'T' THEN
             LET p_gerar = NULL
          ELSE
             IF p_ies_tip_item MATCHES '[FP]' THEN
                LET p_gerar = 'OP'
             ELSE
                LET p_gerar = 'OC'
             END IF
          END IF
          
          IF p_ies_tip_item = 'C' THEN
             LET p_explodiu = 'S'
          ELSE
             LET p_explodiu = 'N'
          END IF

          IF NOT pol0726a_le_tip_local(p_cod_item_compon) THEN
             RETURN FALSE
          END IF   
          
          INSERT INTO estrut_item_1040
            VALUES(p_num_seq,
                   p_cod_item_pai,
                   p_cod_item_compon,
                   p_ies_tip_item,
                   p_cod_local,
                   p_qtd_compon,
                   p_gerar,
                   p_explodiu)
                   
          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','estrut_item_1040:cq_est')
             RETURN FALSE
          END IF

       END FOREACH
   
    END FOREACH
   
   END WHILE
   
   RETURN TRUE

END FUNCTION 

#-----------------------------#
FUNCTION pol0726a_gera_ordens()
#-----------------------------#

   DECLARE cq_gera CURSOR FOR
    SELECT a.num_pedido,
           a.num_pedido_cli,
           b.prz_entrega,
          (b.qtd_pecas_solic  -
           b.qtd_pecas_atend  -
           b.qtd_pecas_cancel -
           b.qtd_pecas_reserv -
           b.qtd_pecas_romaneio)
      FROM pedidos a,
           ped_itens b
     WHERE a.cod_empresa     = p_cod_empresa
       AND a.ies_sit_pedido <> '9'
       AND b.cod_empresa     = a.cod_empresa
       AND b.num_pedido      = a.num_pedido
       AND b.cod_item        = p_cod_item
       AND (b.qtd_pecas_solic  -
            b.qtd_pecas_atend  -
            b.qtd_pecas_cancel -
            b.qtd_pecas_reserv -
            b.qtd_pecas_romaneio)>0
       AND( b.prz_entrega >= p_data_in  {<-----alterado---10/03/2009---}
       AND	b.prz_entrega <= p_data_fi)
       
     
   FOREACH cq_gera INTO 
           p_num_pedido,
           p_oc_linha,
           p_prz_entrega,
           p_qtd_sdo_ped

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Pedidos:cq_gera')
         RETURN FALSE
      END IF

      IF p_qtd_sdo_ped <= 0 THEN
         CONTINUE FOREACH
      END IF

       IF NOT pol0726a_deleta_ops() THEN
          RETURN FALSE
       END IF
       
       IF pol0726a_deleta_oc() = FALSE THEN
          RETURN FALSE
       END IF
   
      IF NOT pol0726a_grava_ordens() THEN
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0726a_gera_ordens_ped()
#---------------------------------#

   INITIALIZE  p_num_pedido,p_oc_linha,p_prz_entrega, p_qtd_sdo_ped  TO NULL

   DECLARE cq_gera_pd CURSOR FOR
    SELECT a.num_pedido,
           a.num_pedido_cli,
           b.prz_entrega,
          (b.qtd_pecas_solic  -
           b.qtd_pecas_atend  -
           b.qtd_pecas_cancel -
           b.qtd_pecas_reserv -
           b.qtd_pecas_romaneio)
      FROM pedidos a,
           ped_itens b
     WHERE a.cod_empresa     = p_cod_empresa
       AND a.ies_sit_pedido <> '9'
       AND a.num_pedido_cli IS NOT NULL
       AND a.num_pedido_cli <> ''
       AND b.cod_empresa     = a.cod_empresa
       AND b.num_pedido      = a.num_pedido
       AND b.cod_item        = p_cod_item
       AND( b.prz_entrega >= p_data_in  {<---------alterado-----10/03/2009}
       AND	b.prz_entrega <= p_data_fi)
       AND (b.qtd_pecas_solic  -
            b.qtd_pecas_atend  -
            b.qtd_pecas_cancel -
            b.qtd_pecas_reserv -
            b.qtd_pecas_romaneio)>0
       AND a.num_pedido IN (SELECT DISTINCT num_pedido   FROM pedido_tmp_1040)
       
            
#      AND b.num_sequencia   = 1
     
   FOREACH cq_gera_pd INTO 
           p_num_pedido,
           p_oc_linha,
           p_prz_entrega,
           p_qtd_sdo_ped

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Pedidos:cq_gera')
         RETURN FALSE
      END IF

      IF p_qtd_sdo_ped <= 0 THEN
         CONTINUE FOREACH
      END IF

       IF NOT pol0726a_deleta_ops() THEN
          RETURN FALSE
       END IF
       
       
       IF pol0726a_deleta_oc() = FALSE THEN
          RETURN FALSE
       END IF
       
      IF NOT pol0726a_grava_ordens() THEN
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE
   
END FUNCTION


#----------------------------#
FUNCTION pol0726a_le_estoque()
#----------------------------#

   SELECT cod_item
     FROM ite_s_oclinha_1040
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','ite_s_oclinha_1040')
      RETURN FALSE
   END IF
   
   IF STATUS = 0 THEN
      SELECT SUM(qtd_saldo)
        INTO p_qtd_sdo_est
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_item_ordem
         #AND cod_local     = p_cod_local
         #AND num_lote      = p_oc_linha
         AND ies_situa_qtd = 'L'
   ELSE
      SELECT SUM(qtd_saldo)
        INTO p_qtd_sdo_est
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_item_ordem
         #AND cod_local     = p_cod_local
         AND num_lote      = p_oc_linha
         AND ies_situa_qtd = 'L'
   END IF   
   
   IF STATUS = 100  THEN
      LET p_qtd_sdo_est = 0
   ELSE
      IF STATUS <> 0  THEN
         CALL log003_err_sql('Lendo','estoque_lote')
         RETURN FALSE
      END IF
   END IF
   
   IF p_qtd_sdo_est  IS  NULL THEN
      LET p_qtd_sdo_est = 0 
   END IF      
      
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0726a_le_reserva()
#----------------------------#

   SELECT SUM(qtd_reservada - qtd_atendida)
     INTO p_qtd_reservada
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem
      AND cod_local   = p_cod_local
      AND num_lote    = p_oc_linha

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_loc')
      RETURN FALSE
   END IF  
      
   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF

   RETURN TRUE
         
END FUNCTION

#---------------------------#
FUNCTION pol0726a_le_ordens()
#---------------------------#

		IF p_gerar = 'OP' THEN
		   SELECT SUM(qtd_planej - qtd_boas - qtd_refug - qtd_sucata)
		     INTO p_qtd_sdo_ord
		     FROM ordens
		    WHERE cod_empresa = p_cod_empresa
		      AND cod_item    = p_item_ordem
		      AND num_lote    = p_oc_linha
		      AND ies_situa   IN ('2','3','4')
		ELSE
		   LET p_num_docum = p_num_pedido
		   SELECT SUM(qtd_solic) 
		     INTO p_qtd_sdo_ord
		     FROM ordem_sup
		    WHERE cod_empresa      = p_cod_empresa
		      AND cod_item         = p_item_ordem
		      AND ies_versao_atual = 'S'
		      AND ies_situa_oc    <> 'C'
		      AND ies_situa_oc    <> 'P' 
		      AND num_docum        = p_num_docum 
	  END IF
         
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','ordens/ordem_sup')
       RETURN FALSE
    END IF  
      
    IF p_qtd_sdo_ord IS NULL OR p_qtd_sdo_ord < 0 THEN
       LET p_qtd_sdo_ord = 0
    END IF

    RETURN TRUE

END FUNCTION 

#-------------------------------#
FUNCTION pol0726a_grava_ordens()
#-------------------------------#

   DECLARE cq_op CURSOR FOR
    SELECT cod_item_pai,
           cod_item,
           tip_item,
           qtd_prodcomp,
           gerar,
           cod_local
      FROM estrut_item_1040
     WHERE tip_item    <> 'T'
       AND qtd_prodcomp > 0
   
   FOREACH cq_op INTO 
           p_cod_item_pai,
           p_item_ordem, 
           p_ies_tip_item,
           p_qtd_prodcomp, 
           p_gerar,
           p_cod_local

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estrut_item_1040:cq_op')
         RETURN FALSE
      END IF

      LET p_qtd_ordem = p_qtd_prodcomp * p_qtd_sdo_ped
      
      IF NOT pol0726a_le_estoque() THEN
         RETURN FALSE
      END IF

      LET p_qtd_ordem = p_qtd_ordem - p_qtd_sdo_est
      
      IF p_qtd_ordem <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol0726a_le_ordens() THEN
         RETURN FALSE
      END IF
      
      LET p_qtd_ordem = p_qtd_ordem - p_qtd_sdo_ord
      
      IF p_qtd_ordem <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol0726a_le_item_man() THEN
         RETURN FALSE
      END IF 
      
      IF p_item_man.ies_planejamento  = '9'  THEN
         CONTINUE FOREACH             
      END IF
      
      IF p_gerar = 'OP' THEN
         CALL pol0726a_gera_op() RETURNING p_status
      ELSE
         CALL pol0726a_gera_oc() RETURNING p_status
      END IF
      
      IF NOT p_status THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0726a_gera_op()
#-------------------------#

   IF NOT pol0726a_insere_ordens() THEN
      RETURN FALSE
   END IF      

   IF NOT pol0726a_insere_op_compl() THEN
      RETURN FALSE
   END IF

   IF NOT pol0726a_le_compon() THEN
      RETURN FALSE
   END IF      
   
   RETURN TRUE

END FUNCTION


#-------------------------------#
FUNCTION pol0726a_insere_ordens()
#-------------------------------#

   IF NOT pol0726a_prx_num_op() THEN
      RETURN FALSE
   END IF

   INITIALIZE p_ordens TO NULL

   LET p_ordens.cod_empresa        = p_cod_empresa
   LET p_ordens.num_ordem          = p_prx_num_op
   LET p_ordens.num_neces          = 0
   LET p_ordens.num_versao         = 0
   LET p_ordens.cod_item           = p_item_ordem
   LET p_ordens.cod_item_pai       = p_cod_item_pai
   LET p_ordens.dat_entrega        = p_prz_entrega
   LET p_ordens.dat_abert          = TODAY
   LET p_ordens.dat_liberac        = TODAY
   LET p_ordens.qtd_planej         = p_qtd_ordem
   LET p_ordens.pct_refug          = 0
   LET p_ordens.qtd_boas           = 0
   LET p_ordens.qtd_refug          = 0
   LET p_ordens.qtd_sucata         = 0
   LET p_ordens.cod_local_prod     = p_item_man.cod_local_prod
   LET p_ordens.cod_local_estoq    = p_cod_local
   LET p_ordens.num_docum          = p_num_pedido
   LET p_ordens.ies_lista_ordem    = p_item_man.ies_lista_ordem
   LET p_ordens.ies_lista_roteiro  = p_item_man.ies_lista_roteiro
   LET p_ordens.ies_origem         = 'H'
   LET p_ordens.ies_situa          = '1'
   LET p_ordens.ies_abert_liber    = p_item_man.ies_abert_liber
   LET p_ordens.ies_baixa_comp     = p_item_man.ies_baixa_comp
   LET p_ordens.ies_apontamento    = p_item_man.ies_apontamento
   LET p_ordens.dat_atualiz        = TODAY
   LET p_ordens.num_lote           = p_oc_linha
   LET p_ordens.cod_roteiro        = p_item_man.cod_roteiro
   LET p_ordens.num_altern_roteiro = p_item_man.num_altern_roteiro

   INSERT INTO ordens VALUES (p_ordens.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','Ordens')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0726a_le_item_man()
#-----------------------------#

   SELECT *
     INTO p_item_man.*
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_man')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
 FUNCTION pol0726a_prx_num_op()
#----------------------------#

   SELECT prx_num_ordem
     INTO p_prx_num_op
     FROM par_mrp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','par_mrp:num_op')
      RETURN FALSE
   END IF

   IF p_prx_num_op IS NULL THEN
      LET p_prx_num_op = 1
   ELSE
      LET p_prx_num_op = p_prx_num_op + 1
   END IF

   UPDATE par_mrp
      SET prx_num_ordem = p_prx_num_op
    WHERE cod_empresa   = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Update','par_mrp:num_op')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0726a_prx_num_neces()
#-------------------------------#

   SELECT prx_num_neces
     INTO p_prx_num_neces
     FROM par_mrp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','par_mrp:num_neces')
      RETURN FALSE
   END IF

   IF p_prx_num_neces IS NULL THEN
      LET p_prx_num_neces = 0
   ELSE
      LET p_prx_num_neces = p_prx_num_neces + 1
   END IF
   
   UPDATE par_mrp
      SET prx_num_neces = p_prx_num_neces
    WHERE cod_empresa   = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Update','par_mrp:num_neces')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol0726a_insere_op_compl()
#---------------------------------#

   INITIALIZE p_op_compl  TO NULL

   LET p_op_compl.cod_empresa    = p_ordens.cod_empresa
   LET p_op_compl.num_ordem      = p_ordens.num_ordem
   LET p_op_compl.cod_grade_1    = " "
   LET p_op_compl.cod_grade_2    = " "
   LET p_op_compl.cod_grade_3    = " "
   LET p_op_compl.cod_grade_4    = " "
   LET p_op_compl.cod_grade_5    = " "
   LET p_op_compl.num_lote       = p_ordens.num_lote
   LET p_op_compl.ies_tipo       = "N"
   LET p_op_compl.num_prioridade = 9999

   INSERT INTO ordens_complement VALUES (p_op_compl.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','ordens_complement')
      RETURN  FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol0726a_le_compon()
#-----------------------------#
   
   DECLARE cq_compon CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_ordens.cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
            (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
       
   FOREACH cq_compon INTO p_cod_item_compon, p_qtd_necessaria

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estrutura:cq_compon')
         RETURN FALSE
      END IF
      
      IF NOT pol0726a_le_tip_item() THEN
         RETURN FALSE
      END IF

      IF p_ies_tip_item  = "T"  THEN
         LET p_cod_fantasma = p_cod_item_compon
         IF NOT pol0726a_trata_fantasma() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0726a_insere_necessidades() THEN
            RETURN FALSE
         END IF
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#--------------------------------#          
FUNCTION pol0726a_trata_fantasma()
#--------------------------------#

   DECLARE cq_fantasma   CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_cod_fantasma
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
            (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))

   FOREACH cq_fantasma INTO p_cod_item_compon, p_qtd_necessaria

      IF NOT pol0726a_insere_necessidades() THEN
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol0726a_insere_necessidades()
#-------------------------------------#

   IF NOT pol0726a_prx_num_neces() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE p_necessidades TO NULL

   LET p_necessidades.cod_empresa      = p_ordens.cod_empresa
   LET p_necessidades.num_neces        = p_prx_num_neces
   LET p_necessidades.num_versao       = p_ordens.num_versao
   LET p_necessidades.cod_item_pai     = p_ordens.cod_item
   LET p_necessidades.cod_item         = p_cod_item_compon
   LET p_necessidades.qtd_necessaria   = p_ordens.qtd_planej * p_qtd_necessaria
   LET p_necessidades.num_ordem        = p_ordens.num_ordem
   LET p_necessidades.qtd_saida        = 0
   LET p_necessidades.num_docum        = p_ordens.num_docum
   LET p_necessidades.dat_neces        = p_ordens.dat_entrega
   LET p_necessidades.ies_origem       = p_ordens.ies_origem
   LET p_necessidades.ies_situa        = p_ordens.ies_situa
   LET p_necessidades.num_neces_consol = 0

   INSERT INTO necessidades  VALUES (p_necessidades.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','Necessidades')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0726a_le_tip_item()
#-----------------------------#
          
   SELECT ies_tip_item 
     INTO p_ies_tip_item
     FROM item 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_compon
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:tipo')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0726a_gera_oc()
#-------------------------#

   INITIALIZE p_ordem_sup, 
              p_prog_ordem_sup, 
              p_dest_ordem_sup,
              p_estr_ordem_sup TO NULL

   IF NOT pol0726a_le_item_sup() THEN
      RETURN FALSE
   END IF

   IF pol0726a_prx_num_oc() = FALSE THEN
      RETURN FALSE
   END IF
   
   IF pol0726a_insere_oc() = FALSE THEN
      RETURN FALSE
   END IF

   IF pol0726a_insere_prog_oc() = FALSE THEN
      RETURN FALSE
   END IF

   IF pol0726a_insere_dest_oc() = FALSE THEN
      RETURN FALSE
   END IF

   IF p_ies_tip_item = 'B' THEN
      IF pol0726a_insere_estrut() = FALSE THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
 FUNCTION pol0726a_prx_num_oc()
#----------------------------#
   LET m_prx_num_oc = 0

   SELECT prx_num_oc
     INTO m_prx_num_oc
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','par_sup')
      RETURN FALSE
   END IF

   IF m_prx_num_oc IS NULL THEN
      LET m_prx_num_oc = 0
   END IF

   UPDATE par_sup
      SET prx_num_oc = m_prx_num_oc + 1
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Atualizando','par_sup')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol0726a_insere_oc()
#---------------------------#

   SELECT cod_progr INTO m_cod_progr
     FROM programador
    WHERE cod_empresa = p_cod_empresa
      AND login       = p_user
   
   IF STATUS <> 0 THEN
      LET m_cod_progr = 0
   END IF

   LET p_ordem_sup.cod_empresa        = p_cod_empresa
   LET p_ordem_sup.num_oc             = m_prx_num_oc
   LET p_ordem_sup.num_versao         = 0
   LET p_ordem_sup.num_versao_pedido  = 0
   LET p_ordem_sup.ies_versao_atual   = 'S'
   LET p_ordem_sup.cod_item           = p_item_ordem
   LET p_ordem_sup.num_pedido         = 0
   LET p_ordem_sup.ies_situa_oc       = 'P'
   LET p_ordem_sup.ies_origem_oc      = 'H'
   LET p_ordem_sup.ies_item_estoq     = 'S' 
   LET p_ordem_sup.ies_imobilizado    = 'N'
   LET p_ordem_sup.cod_unid_med       = m_cod_unid_med
   LET p_ordem_sup.dat_emis           = TODAY
   LET p_ordem_sup.qtd_solic          = p_qtd_ordem
   LET p_ordem_sup.dat_entrega_prev   = p_prz_entrega - p_qtd_dias
   LET p_ordem_sup.fat_conver_unid    = 1
   LET p_ordem_sup.qtd_recebida       = 0
   LET p_ordem_sup.pre_unit_oc        = 0
   LET p_ordem_sup.pct_ipi            = m_pct_ipi
   LET p_ordem_sup.cod_moeda          = 1
   LET p_ordem_sup.cod_fornecedor     = ' '
   LET p_ordem_sup.cnd_pgto           = 0
   LET p_ordem_sup.cod_mod_embar      = 0
   LET p_ordem_sup.num_docum          = p_num_pedido
   LET p_ordem_sup.gru_ctr_desp       = m_gru_ctr_desp
   LET p_ordem_sup.cod_secao_receb    = " "
   LET p_ordem_sup.cod_progr          = m_cod_progr
   LET p_ordem_sup.cod_comprador      = m_cod_comprador
   LET p_ordem_sup.pct_aceite_dif     = 0
   LET p_ordem_sup.ies_tip_entrega    = 'D'
   LET p_ordem_sup.ies_liquida_oc     = '2'
   LET p_ordem_sup.dat_abertura_oc    = TODAY
   LET p_ordem_sup.num_oc_origem      = m_prx_num_oc
   LET p_ordem_sup.qtd_origem         = p_qtd_ordem
   LET p_ordem_sup.ies_tip_incid_ipi  = m_ies_tip_incid_ipi
   LET p_ordem_sup.ies_tip_incid_icms = m_ies_tip_incid_icms
   LET p_ordem_sup.cod_fiscal         = m_cod_fiscal
   LET p_ordem_sup.cod_tip_despesa    = m_cod_tip_despesa
   LET p_ordem_sup.ies_insp_recebto   = '4'

   INSERT INTO ordem_sup VALUES (p_ordem_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inderindo','ordem_sup')
      RETURN  FALSE
   END IF

   LET p_texto = p_oc_linha CLIPPED, ' - FAVOR INFORMAR ESSE NUMERO EM SUA NF'

   INSERT INTO ordem_sup_txt
     VALUES(p_ordem_sup.cod_empresa,
            p_ordem_sup.num_oc,
            "O",
            1,
            p_texto)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Inclusão","ordem_sup_txt")       
      RETURN FALSE
   END IF

   RETURN  TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol0726a_insere_prog_oc()
#--------------------------------#
   LET p_prog_ordem_sup.cod_empresa      = p_ordem_sup.cod_empresa
   LET p_prog_ordem_sup.num_oc           = p_ordem_sup.num_oc
   LET p_prog_ordem_sup.num_versao       = p_ordem_sup.num_versao
   LET p_prog_ordem_sup.num_prog_entrega = 1
   LET p_prog_ordem_sup.ies_situa_prog   = p_ordem_sup.ies_situa_oc
   LET p_prog_ordem_sup.dat_entrega_prev = p_ordem_sup.dat_entrega_prev
   LET p_prog_ordem_sup.qtd_solic        = p_ordem_sup.qtd_solic
   LET p_prog_ordem_sup.qtd_recebida     = p_ordem_sup.qtd_recebida
   LET p_prog_ordem_sup.dat_origem       = p_ordem_sup.dat_abertura_oc

   INSERT INTO prog_ordem_sup VALUES (p_prog_ordem_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','prog_ordem_sup')
      RETURN FALSE
   END IF

   RETURN  TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol0726a_insere_dest_oc()
#--------------------------------#
   LET p_dest_ordem_sup.cod_empresa        = p_ordem_sup.cod_empresa
   LET p_dest_ordem_sup.num_oc             = p_ordem_sup.num_oc
   LET p_dest_ordem_sup.cod_area_negocio   = 0
   LET p_dest_ordem_sup.cod_lin_negocio    = 0
   LET p_dest_ordem_sup.pct_particip_comp  = 100
   LET p_dest_ordem_sup.cod_secao_receb    = p_ordem_sup.cod_secao_receb
   LET p_dest_ordem_sup.num_conta_deb_desp = m_num_conta
   LET p_dest_ordem_sup.qtd_particip_comp  = p_ordem_sup.qtd_solic
   LET p_dest_ordem_sup.num_transac        = 0

   INSERT INTO dest_ordem_sup VALUES (p_dest_ordem_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','dest_ordem_sup')
      RETURN  FALSE
   END IF

   RETURN  TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0726a_insere_estrut()
#-------------------------------#

   DECLARE cq_estr CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           pct_refug
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_ordem_sup.cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
            (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))

   FOREACH cq_estr INTO 
           p_estr_ordem_sup.cod_item_comp,
           p_estr_ordem_sup.qtd_necessaria,
           p_pct_refug

      LET p_estr_ordem_sup.cod_empresa    = p_ordem_sup.cod_empresa
      LET p_estr_ordem_sup.num_oc         = p_ordem_sup.num_oc
      LET p_estr_ordem_sup.qtd_necessaria = p_estr_ordem_sup.qtd_necessaria +
          (p_estr_ordem_sup.qtd_necessaria * p_pct_refug / 100)
      
      INSERT INTO estrut_ordem_sup VALUES (p_estr_ordem_sup.*)

      IF sqlca.sqlcode <> 0 THEN																								#caso haja alguma ordem repetida
         UPDATE estrut_ordem_sup																								#ele vai somar os valores
         	SET qtd_necessaria = qtd_necessaria + p_estr_ordem_sup.qtd_necessaria
         WHERE cod_empresa = p_estr_ordem_sup.cod_empresa 
         AND num_oc = p_estr_ordem_sup.num_oc 
         AND cod_item_comp = p_estr_ordem_sup.cod_item_comp
         IF sqlca.sqlcode <> 0 THEN
         		CALL log003_err_sql('Inserindo','estrut_ordem_sup')
         		RETURN  FALSE
         END IF 
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol0726a_le_item_sup()
#-----------------------------#
   
   SELECT cod_comprador,
          cod_progr,
          gru_ctr_desp,
          num_conta,
          cod_tip_despesa,
          ies_tip_incid_icms,
          ies_tip_incid_ipi,
          cod_fiscal
     INTO m_cod_comprador,
          m_cod_progr,
          m_gru_ctr_desp,
          m_num_conta,
          m_cod_tip_despesa,
          m_ies_tip_incid_icms,
          m_ies_tip_incid_ipi,
          m_cod_fiscal
     FROM item_sup
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem

   IF sqlca.sqlcode = NOTFOUND THEN
      CALL log0030_mensagem("Item Não Localizado na Tab. item_sup","exclamation")
      RETURN FALSE
   END IF

   IF m_num_conta IS NULL THEN
      LET m_num_conta = 0
   END IF

   IF m_gru_ctr_desp IS NULL THEN 
      LET m_gru_ctr_desp = 0
   END IF

{   IF m_cod_progr = 0 THEN 
      LET p_msg = "item_sup.cod_progr = 0 - item:",p_item_ordem
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF
  
   IF m_cod_tip_despesa = 0 THEN
      LET p_msg = "item_sup.cod_tip_despesa = 0 - item:",p_item_ordem
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF

   IF m_ies_tip_incid_icms IS NULL THEN
      LET p_msg = "item_sup.ies_tip_incid_icms = nulo - item:",p_item_ordem
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF

   IF m_ies_tip_incid_ipi IS NULL THEN
      LET p_msg = "item_sup.ies_tip_incid_ipi = nulo - item:",p_item_ordem
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF

   IF m_cod_fiscal IS NULL THEN
      LET p_msg = "item_sup.cod_fiscal = nulo - item:",p_item_ordem
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF
}

   SELECT pct_ipi, 
          cod_unid_med
     INTO m_pct_ipi, 
          m_cod_unid_med
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:und')
      RETURN FALSE
   END IF

   SELECT cod_horizon
     INTO p_cod_horizon
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_man:oc')
      RETURN FALSE
   END IF
   
   SELECT qtd_dias_horizon
     INTO p_qtd_dias
     FROM horizonte
    WHERE cod_empresa = p_cod_empresa
      AND cod_horizon = p_cod_horizon

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','horizonte')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#-------------------------------#
 FUNCTION pol0726a_informa_data()		{<--------Alterado----------THIAGO-----10/03/2009----}
#-------------------------------#
	 CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0726a") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0726a AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   CLEAR FORM
      
	IF p_data_in IS NULL THEN 
		LET p_data_in = '01/01/2000'
	END IF 
	IF p_data_fi IS NULL THEN 
		LET p_data_fi = '01/01/2100'
	END IF 

   INPUT p_data_in,p_data_fi   WITHOUT DEFAULTS
   FROM data_in,data_fi
        

      			
			AFTER FIELD data_in
					
				IF p_data_in IS NULL THEN
							ERROR "Campo com Preenchimento Obrigatório !!!"
            	NEXT FIELD data_in
  			ELSE 
  						NEXT FIELD data_fi
    	 	END IF	
    	 	
    	 	
    	 	
    	 	AFTER FIELD data_fi
					
				IF p_data_fi IS NULL THEN
							ERROR "Campo com Preenchimento Obrigatório !!!"
            	NEXT FIELD data_fi
         ELSE 
         		IF p_data_in > p_data_fi THEN
         			ERROR "Data final tem que ser maior que a data inicial !!!"
         			NEXT FIELD data_fi
         		END IF 
  
    	 	END IF	

   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE 
   ELSE
   		
      CLEAR FORM
     
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF

   RETURN(p_retorno)

END FUNCTION 

