##----------------------------------------------------------##
##  POL0800 - ENTRADA ESTOQUE DE SUCATAS                    ##
# FUNÇÕES: FUNC002                                           #
##----------------------------------------------------------##

DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_last_row          SMALLINT,
         p_msg               CHAR(150)


END GLOBALS
                   
  DEFINE l_cod_lin_prod  LIKE item.cod_lin_prod, 
         l_cod_lin_recei LIKE item.cod_lin_recei,
         l_cod_seg_merc  LIKE item.cod_seg_merc, 
         l_cod_cla_uso   LIKE item.cod_cla_uso,
         p_den_item      LIKE item.den_item,
         p_ctr_estoque   CHAR(01),
         p_ctr_lote      CHAR(01),
         p_nom_tela      CHAR(080),
         p_nom_help      CHAR(200),
         p_ies_cons      SMALLINT,
         p_count         INTEGER
        
  DEFINE p_tela RECORD 
         qtd_movto           DECIMAL(10,3),
         ies_tip_movto       CHAR(01)
  END RECORD 

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
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0800-10.02.01  "
  CALL func002_versao_prg(p_versao)
 
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0800.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user

  IF  p_status = 0  THEN
      CALL pol0800_controle()
  END IF

END MAIN

#----------------------------#
FUNCTION pol0800_limpa_tela()#
#----------------------------#

  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
  
END FUNCTION

#--------------------------#
 FUNCTION pol0800_controle()
#--------------------------#

  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0800") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0800 AT 2,1 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
  CALL pol0800_limpa_tela()
  
  MENU "OPCAO"
    COMMAND "Informar" "Informa dados para processamento"

      IF  log005_seguranca(p_user,"VDP","pol0800","IN") THEN
        CALL pol0800_informar() RETURNING p_status
        IF NOT p_status THEN
           CALL pol0800_limpa_tela()
           LET p_ies_cons = FALSE
           ERROR 'Operação cancelada.'
        ELSE
           ERROR 'Parâmetros informados com sucesso.'
           LET p_ies_cons = TRUE
           NEXT OPTION "Processar"
        END IF
      END IF
      
     COMMAND "Processar" "Processa dados da tabela"

       IF p_ies_cons THEN
        IF  log005_seguranca(p_user,"VDP","pol0800","MO") THEN
           IF pol0800_processar() THEN 
              LET p_msg = "Operação efetuada com sucesso"
           ELSE
              CALL pol0800_limpa_tela()
              LET p_msg = "Operação cancelada."
           END IF  
           ERROR p_msg
        END IF
        LET p_ies_cons = FALSE
       ELSE
          ERROR 'Informe os parâmetros previamente.'
          NEXT OPTION 'Informar'
       END IF

    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
       CALL func002_exibe_versao(p_versao)
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0800
END FUNCTION

#----------------------------#
 FUNCTION pol0800_informar()
#----------------------------#

    CALL pol0800_limpa_tela()
    LET p_tela.qtd_movto = 0
    LET p_tela.ies_tip_movto = 'N'
    
    INITIALIZE p_item TO NULL
    LET p_item.cod_empresa = p_cod_empresa
    LET p_item.cus_unit      = 0
    LET p_item.cus_tot       = 0

    
    LET INT_FLAG = FALSE
        
    SELECT cod_item_sucata,
           oper_entr_sucata,
           num_lote_sucata 
      INTO p_item.cod_item,
           p_item.cod_operacao,
           p_item.num_lote
      FROM parametros_885
     WHERE cod_empresa = p_cod_empresa
     
    IF SQLCA.sqlcode <> 0 THEN 
        CALL log0030_mensagem(
           "PARAMETROS NAO CADASTRADOS PARA A EMPRESA CORRENTE.",'INFO')
        RETURN FALSE
    END IF 
    
    SELECT den_item,
           cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso, 
           cod_local_estoq,
           ies_ctr_estoque,
           ies_ctr_lote
      INTO p_den_item,
           l_cod_lin_prod, 
           l_cod_lin_recei,
           l_cod_seg_merc, 
           l_cod_cla_uso,  
           p_item.cod_local,
           p_ctr_estoque,
           p_ctr_lote
      FROM item
     WHERE cod_empresa = p_cod_empresa   
       AND cod_item    = p_item.cod_item 

    IF STATUS <> 0 THEN
       CALL log003_err_sql('SELECT','item')
       RETURN FALSE
    END IF
    
    IF p_ctr_estoque = 'N' THEN
       LET p_msg = 'Item sucata ',p_item.cod_item CLIPPED, ' não\n',
          'controla estoque.'
       CALL log0030_mensagem(p_msg, 'info')
       RETURN FALSE
    END IF
    
    IF p_ctr_lote = 'N' THEN
       LET p_item.num_lote = NULL
    END IF
    
    DISPLAY p_item.cod_item TO cod_item
    DISPLAY p_den_item TO den_item
    
  INPUT BY NAME p_tela.* WITHOUT DEFAULTS  

    AFTER FIELD qtd_movto 
      IF p_tela.qtd_movto  IS NULL OR p_tela.qtd_movto <= 0 THEN
         ERROR 'Campo com preenchimento obrigatório'
         NEXT FIELD qtd_movto
      END IF
   
   AFTER INPUT 
      
      IF INT_FLAG THEN
         RETURN FALSE
      END IF

 END INPUT 
  
  LET p_item.qtd_movto = p_tela.qtd_movto
  LET p_item.ies_tip_movto = p_tela.ies_tip_movto
  LET p_item.dat_movto = TODAY
  LET p_item.dat_proces = TODAY
  LET p_item.hor_operac = TIME
  LET p_item.num_prog = 'POL0800'
  LET p_item.tip_operacao = 'E'      #entrada
  LET p_item.num_docum = '1'
  LET p_item.num_seq = NULL
  LET p_item.usuario = p_user
  LET p_item.cod_turno = NULL
  LET p_item.ies_ctr_lote = p_ctr_lote

  IF p_item.ies_tip_movto = 'N' THEN
     LET p_item.ies_situa = 'L'
     LET p_item.trans_origem = 0
  ELSE
     IF NOT pol0800_ve_possibilidade() THEN
        RETURN FALSE
     END IF
  END IF
  
  RETURN TRUE
  
END FUNCTION

#----------------------------------#
FUNCTION pol0800_ve_possibilidade()#
#----------------------------------#

   DEFINE p_num_trans_ant INTEGER,
          p_qtd_saldo     DECIMAL(10,3)
   
   LET p_num_trans_ant = NULL

   DECLARE cq_mov_nor CURSOR FOR
       SELECT num_transac
         FROM estoque_trans
        WHERE cod_empresa = p_item.cod_empresa
          AND cod_item = p_item.cod_item
          AND cod_operacao = p_item.cod_operacao
          AND qtd_movto = p_item.qtd_movto
          AND num_prog = p_item.num_prog 
          AND ies_tip_movto = 'N'
          AND num_docum = p_item.num_docum
          AND (num_lote_dest = p_item.num_lote OR 
                 (num_lote_dest IS NULL AND p_ctr_lote = 'N'))
        ORDER BY num_transac DESC

   FOREACH cq_mov_nor INTO p_num_trans_ant
		      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_mov_nor')
         RETURN FALSE
      END IF
      
      SELECT COUNT(cod_empresa)
        INTO p_count
        FROM estoque_trans_rev
       WHERE cod_empresa = p_item.cod_empresa
         AND num_transac_normal = p_num_trans_ant

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_trans_rev')
         RETURN FALSE
      END IF
         
      IF p_count > 0 THEN
         LET p_num_trans_ant = NULL
         CONTINUE FOREACH
      END IF
         
      EXIT FOREACH
      
   END FOREACH
      
   IF p_num_trans_ant IS NULL THEN
      LET p_msg = 'MOVTO NORMAL CORRESPONDENTE NAO ENCONTRADO'  
      CALL log0030_mensagem(p_msg,'INFO')
      RETURN FALSE
   END IF
    
   SELECT ies_sit_est_dest
     INTO p_item.ies_situa
     FROM estoque_trans
    WHERE cod_empresa = p_item.cod_empresa
      AND num_transac = p_num_trans_ant

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_trans')
      RETURN FALSE
   END IF
   
   LET p_item.trans_origem = p_num_trans_ant
   
   SELECT SUM(qtd_saldo)
     INTO p_qtd_saldo
     FROM estoque_lote_ender
    WHERE cod_empresa = p_item.cod_empresa
      AND cod_item = p_item.cod_item
      AND cod_local = p_item.cod_local
      AND ies_situa_qtd = p_item.ies_situa
      AND comprimento = p_item.comprimento
      AND largura = p_item.largura
      AND altura = p_item.altura
      AND diametro = p_item.diametro
      AND (num_lote = p_item.num_lote OR (num_lote IS NULL AND p_ctr_lote = 'N'))

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote_ender')
      RETURN FALSE
   END IF
   
   IF p_qtd_saldo < p_item.qtd_movto THEN
      LET p_msg = 'Lote ', p_item.num_lote CLIPPED, ' sem saldo para reverter'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   SELECT SUM(qtd_saldo)
     INTO p_qtd_saldo
     FROM estoque_lote
    WHERE cod_empresa = p_item.cod_empresa
      AND cod_item = p_item.cod_item
      AND cod_local = p_item.cod_local
      AND ies_situa_qtd = p_item.ies_situa
      AND (num_lote = p_item.num_lote OR (num_lote IS NULL AND p_ctr_lote = 'N'))

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote')
      RETURN FALSE
   END IF
   
   IF p_qtd_saldo < p_item.qtd_movto THEN
      LET p_msg = 'Lote ', p_item.num_lote CLIPPED, ' sem saldo para reverter'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   IF p_item.ies_situa = 'L' THEN
      SELECT qtd_liberada
        INTO p_qtd_saldo
        FROM estoque
       WHERE cod_empresa = p_item.cod_empresa
         AND cod_item = p_item.cod_item
   ELSE
      IF p_item.ies_situa = 'R' THEN
         SELECT qtd_rejeitada
           INTO p_qtd_saldo
           FROM estoque
          WHERE cod_empresa = p_item.cod_empresa
            AND cod_item = p_item.cod_item
      ELSE
         SELECT qtd_lib_excep
           INTO p_qtd_saldo
           FROM estoque
          WHERE cod_empresa = p_item.cod_empresa
            AND cod_item = p_item.cod_item
      END IF
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque')
      RETURN FALSE
   END IF
   
   IF p_qtd_saldo < p_item.qtd_movto THEN
      LET p_msg = 'Item ', p_item.cod_item CLIPPED, ' sem saldo para reverter'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#---------------------------#
 FUNCTION pol0800_processar()
#---------------------------#

   IF NOT log004_confirm(18,38) THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")  
   
   CALL func005_insere_movto(p_item.*) RETURNING p_status
   
   IF NOT p_status THEN
      CALL log085_transacao("ROLLBACK")
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

