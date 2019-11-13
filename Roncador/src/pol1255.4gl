#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1255                                                 #
# OBJETIVO: ITEM ALTERNATIVO P/ ORDEM DE PRODUÇÃO                   #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 20/01/14                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro               CHAR(06),
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT,
          p_ies_tip_item       CHAR(01),
          p_qtd_reser          DECIMAL(10,3)
         
END GLOBALS

DEFINE p_num_docum      CHAR(10),
       p_cod_item       CHAR(15),
       p_cod_ant        CHAR(15),
       p_cod_alternat   CHAR(15),
       p_ies_docum      CHAR(01),
       p_num_ordem      INTEGER,
       p_num_neces      INTEGER,
       p_tip_item       CHAR(01),
       p_tip_alternat   CHAR(01),
       p_local_item     CHAR(10),
       p_local_alternat CHAR(10),
       p_local_orig     CHAR(10),
       p_local_dest     CHAR(10),
       p_tip_orig       CHAR(01),
       p_cod_item_pai   CHAR(15),
       p_op_calcel      INTEGER,
       p_op_ant         INTEGER,
       p_qtd_prod       DECIMAL(10,3),
       p_dat_atu        DATE,
       p_hor_atu        CHAR(08),
       p_den_item       CHAR(76),
       p_ies_semelhante CHAR(01),
       p_query          CHAR(1000),
       p_qtd_itens      INTEGER,
       p_explodiu       CHAR(01),
       p_qtd_neces      DECIMAL(10,3),
       p_qtd_orig       DECIMAL(10,3),
       p_qtd_saldo      DECIMAL(10,3),
       p_qtd_alter      DECIMAL(10,3),
       p_cod_local      CHAR(10),
       p_ies_situa      CHAR(01),
       p_num_lote       CHAR(15),
       p_cod_local_est  CHAR(10),
       p_cod_local_prd  CHAR(10),
       p_qtd_movto      DECIMAL(10,3),
       p_qtd_transfer   DECIMAL(10,3),
       p_proces         CHAR(01),
       P_status_op      CHAR(01),
       p_id_registro    INTEGER,
       p_texto          CHAR(78),
       p_qtd_txt        CHAR(11),
       p_sdo_ordem      DECIMAL(10,3),
       P_qtd_planej     DECIMAL(10,3),
       p_ies_transfere  CHAR(01)

DEFINE pr_ordens        ARRAY[500] OF RECORD
       ordem            INTEGER,
       situacao         CHAR(01),
       saldo            DECIMAL(10,3),
       componente       CHAR(15),
       alternativo      CHAR(15),
       necessidade      DECIMAL(10,3)
END RECORD

DEFINE pr_compl         ARRAY[500] OF RECORD
       necessidade      DECIMAL(10,3)
END RECORD

DEFINE p_alternat  RECORD LIKE item_alternat_1054.*,
       p_alternata RECORD LIKE item_alternat_1054.*

DEFINE p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
       p_estoque_lote       RECORD LIKE estoque_lote.*,
       p_estoque_trans      RECORD LIKE estoque_trans.*,
       p_estoque_trans_end  RECORD LIKE estoque_trans_end.*

DEFINE p_cod_operacao      LIKE estoque_trans.cod_operacao,
       p_num_conta         LIKE estoque_trans.num_conta,
       p_num_transac_orig  LIKE estoque_trans.num_transac,
       p_largura           LIKE estoque_lote_ender.largura,
       p_altura            LIKE estoque_lote_ender.altura,
       p_diametro          LIKE estoque_lote_ender.diametro,
       p_comprimento       LIKE estoque_lote_ender.comprimento

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1255-10.02.04"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'
   #LET p_user = 'admlog'
   #LET p_status = 0

   IF p_status = 0 THEN
      CALL pol1255_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1255_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1255") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1255 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1255_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1255_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1255_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1255_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1255_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1255

END FUNCTION

#-----------------------#
 FUNCTION pol1255_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               "   Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br.com\n\n ",
               "      LOGIX 10.02\n",
               "   www.grupoaceex.com.br\n",
               "     (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1255_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1255_inclusao()
#--------------------------#

   CALL pol1255_limpa_tela()

   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   INITIALIZE p_alternat TO NULL
   LET p_alternat.cod_empresa = p_cod_empresa
   LET p_alternat.usuario = p_user
   LET p_alternat.dat_troca = p_dat_atu
   LET p_alternat.hor_troca = p_hor_atu
   
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1255_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1255_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1255_limpa_tela()
   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1255_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)

   IF NOT pol1255_le_parametro() THEN
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_alternat.*
      WITHOUT DEFAULTS
              
      BEFORE FIELD tip_docum

      AFTER FIELD tip_docum

         IF p_alternat.tip_docum IS NULL THEN
            ERROR "Informe o tipo de documento."
            NEXT FIELD tip_docum   
         END IF
      
      AFTER FIELD num_docum

         IF p_alternat.num_docum IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD num_docum   
         END IF

         IF NOT pol1255_le_docum() THEN
            NEXT FIELD num_docum   
         END IF
          
      AFTER FIELD cod_item

         IF p_alternat.cod_item IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_item   
         END IF
         
         IF NOT pol1255_le_den_item(p_alternat.cod_item) THEN
            NEXT FIELD cod_item   
         END IF

         IF NOT pol1255_le_qtd_neces(p_alternat.cod_item) THEN
            NEXT FIELD cod_item   
         END IF
         
         DISPLAY p_den_item TO den_item         
         DISPLAY p_tip_item TO tip_item
         DISPLAY p_qtd_neces TO neces_item
         LET p_tip_orig = p_tip_item
         LET p_local_item = p_cod_local_est
         LET p_alternat.neces_item = p_qtd_neces
         LET p_alternat.neces_alternat = p_qtd_neces

         IF p_tip_orig MATCHES '[FT]' THEN
            ERROR 'Item final/fantasma não podem ser substituídos.'
            NEXT FIELD cod_item   
         END IF

      AFTER FIELD item_alternat

         IF p_alternat.item_alternat IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD item_alternat   
         END IF
         
         IF NOT pol1255_le_den_item(p_alternat.item_alternat) THEN
            NEXT FIELD item_alternat   
         END IF
         
         DISPLAY p_den_item TO den_alternat   
         DISPLAY p_tip_item TO tip_alternat 
         LET p_tip_alternat = p_tip_item
         LET p_local_alternat = p_cod_local_est

         IF p_alternat.item_alternat = p_alternat.cod_item THEN 
            ERROR 'O item não pode ser trocado por ele mesmo'
            NEXT FIELD item_alternat   
         END IF
         
         IF p_tip_alternat = 'T' THEN
            ERROR 'O item alternativo não pode ser fantasma.'
            NEXT FIELD item_alternat   
         END IF
         
         IF p_ies_semelhante = 'S' THEN
            IF p_tip_alternat <> p_tip_orig THEN
               LET p_msg = 'O item alteranativo deve\n', 
                           'ser do mesmo tipo que o\n item a ser substituído.'
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD item_alternat
            END IF
         END IF

     BEFORE FIELD neces_alternat
        
        IF p_alternat.tip_docum = 'P' THEN
           EXIT INPUT
        END IF
        
     AFTER FIELD neces_alternat
        
        IF p_alternat.neces_alternat IS NULL OR
           p_alternat.neces_alternat <= 0 THEN
           ERROR 'Campo com preenchimento obrigatório.'
           NEXT FIELD neces_alternat
        END IF
        
      ON KEY (control-z)
         CALL pol1255_popup()

      AFTER INPUT

         IF NOT INT_FLAG THEN
            IF NOT pol1255_ops_existem() THEN
               NEXT FIELD cod_item
            END IF
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1255_exibe_ops() THEN
      RETURN FALSE
   END IF
   
	 LET p_msg = 'Confirma a substituição do item:', p_alternat.cod_item CLIPPED,
	             '\npelo alternativo: ', p_alternat.item_alternat CLIPPED
	             
	 IF NOT log0040_confirm(20,25,p_msg) THEN
	    RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1255_le_parametro()#
#------------------------------#

   DEFINE p_ies_com_detalhe CHAR(01)
   
   SELECT parametro_texto
     INTO p_ies_semelhante
     FROM min_par_modulo
    WHERE empresa = p_cod_empresa
      AND parametro = 'SO ITEM SEMELHANTE'
   
   IF STATUS = 100 THEN
      LET p_ies_semelhante = 'N'
   ELSE 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','MIN_PAR_MODULO')
         RETURN FALSE
      END IF
   END IF

   SELECT cod_estoque_ac
    INTO p_cod_operacao
    FROM par_pcp
   WHERE cod_empresa = p_cod_empresa       

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','MIN_PAR_MODULO')
      RETURN FALSE
   END IF

   SELECT ies_com_detalhe
     INTO p_ies_com_detalhe
     FROM estoque_operac
    WHERE cod_empresa  = p_cod_empresa
      AND cod_operacao = p_cod_operacao

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_operac')
      RETURN FALSE
   END IF

   IF p_ies_com_detalhe = 'S' THEN 
      SELECT num_conta_credito 
        INTO p_num_conta
        FROM estoque_operac_ct
       WHERE cod_empresa  = p_cod_empresa
         AND cod_operacao = p_cod_operacao
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_operac_ct')
         RETURN FALSE
      END IF
   ELSE
      LET p_num_conta = NULL
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1255_le_docum()#
#--------------------------#
   
   IF p_alternat.tip_docum = 'P' THEN
      LET p_num_docum = p_alternat.num_docum
      DECLARE cq_pri_op CURSOR FOR
       SELECT ies_situa
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND ies_situa IN ('3','4')
         AND num_docum = p_num_docum
      FOREACH cq_pri_op INTO p_ies_situa
         EXIT FOREACH
      END FOREACH
   ELSE
      LET p_num_ordem = p_alternat.num_docum
      SELECT ies_situa,
             num_docum,
             qtd_planej,
             (qtd_planej - qtd_boas - qtd_refug - qtd_sucata)
        INTO p_ies_situa,
             p_num_docum,
             P_qtd_planej,
             p_sdo_ordem
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND ies_situa IN ('3','4')
         AND num_ordem = p_num_ordem
   END IF
            
   IF STATUS <> 0 AND STATUS <> 100 THEN 
      CALL log003_err_sql('SELECT','ordens')
      LET p_ies_situa = NULL
   END IF  

   IF p_ies_situa IS NULL THEN 
      LET p_msg = 'Não há ordens com status 3 ou 4,\n',
                  'para os parâmetros informados.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF  
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1255_le_qtd_neces(p_compon)#
#--------------------------------------#
   
   DEFINE p_compon LIKE item.cod_item,
          p_neces  LIKE ord_compon.qtd_necessaria
   
   LET p_qtd_neces = NULL
   
   DECLARE cq_compon CURSOR FOR
    SELECT qtd_necessaria
      FROM ord_compon a, ordens b
      WHERE a.cod_empresa = p_cod_empresa
        AND a.cod_item_compon = p_compon
        AND a.num_ordem = b.num_ordem
        AND b.num_docum = p_num_docum
        AND b.ies_situa IN ('3','4')
        AND b.cod_empresa = a.cod_empresa

   FOREACH cq_compon INTO p_neces   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_compon')
         RETURN FALSE
      END IF
      
      LET p_qtd_neces = p_neces
      EXIT FOREACH
   END FOREACH
   
   IF p_qtd_neces IS NULL THEN
      LET p_msg = 'Componente não localizado no,\n',
                  'documento informado.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF  
   
   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol1255_le_den_item(p_cod)#
#----------------------------------#

   DEFINE p_cod CHAR(15)
   
   SELECT den_item,
          ies_tip_item,
          cod_local_estoq
     INTO p_den_item,
          p_tip_item,
          p_cod_local_est
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------#
 FUNCTION pol1255_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1255
         IF p_codigo IS NOT NULL THEN
           LET p_alternat.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

      WHEN INFIELD(item_alternat)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1255
         IF p_codigo IS NOT NULL THEN
           LET p_alternat.item_alternat = p_codigo
           DISPLAY p_codigo TO item_alternat
         END IF

   END CASE 

END FUNCTION 

#-----------------------------#
FUNCTION pol1255_ops_existem()#
#-----------------------------#

   LET p_ies_docum = p_alternat.tip_docum
   LET p_cod_item = p_alternat.cod_item
   LET p_cod_alternat = p_alternat.item_alternat
   
   IF p_ies_docum = 'O' THEN
      LET p_num_ordem = p_alternat.num_docum
      IF p_alternat.neces_alternat = p_alternat.neces_item THEN
         SELECT sum(b.qtd_necessaria - b.qtd_saida)
           INTO p_qtd_neces
           FROM ordens a, necessidades b
          WHERE a.cod_empresa = p_cod_empresa
            AND a.ies_situa IN ('3','4')
            AND a.num_ordem = p_num_ordem
            AND b.cod_empresa = a.cod_empresa
            AND b.num_ordem = a.num_ordem
            AND b.cod_item = p_cod_item
      ELSE
         LET p_qtd_neces = p_sdo_ordem * p_alternat.neces_alternat
      END IF
   ELSE
      LET p_num_docum = p_alternat.num_docum
      SELECT sum(b.qtd_necessaria - b.qtd_saida) as qtd_neces
        INTO p_qtd_neces
        FROM ordens a, necessidades b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.ies_situa IN ('3','4')
         AND a.num_docum = p_num_docum
         AND b.cod_empresa = a.cod_empresa
         AND b.num_ordem = a.num_ordem
         AND b.cod_item = p_cod_item
   END IF

   IF NOT pol1255_tem_op_est() THEN
      RETURN FALSE
   END IF

   IF NOT pol1255_le_ordens() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1255_tem_op_est()#
#----------------------------#

   IF p_tip_alternat MATCHES '[BC]' THEN
      IF NOT pol1255_tem_estoque() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1255_tem_op_lib() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1255_tem_estoque()#
#-----------------------------#

   SELECT cod_local_estoq
     INTO p_cod_local_est
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_alternat

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF      

   SELECT SUM(qtd_saldo)
     INTO p_qtd_saldo
     FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_alternat
      AND cod_local = p_cod_local_est
      AND ies_situa_qtd IN ('L','E')
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_lote')
      RETURN FALSE
   END IF      
   
   IF p_qtd_saldo IS NULL THEN
      LET p_qtd_saldo = 0
   END IF
   
   SELECT SUM(qtd_reservada)
     INTO p_qtd_reser 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_alternat
      AND cod_local   = p_cod_local_est
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_loc_reser')
      RETURN FALSE
   END IF      
   
   IF p_qtd_reser IS NULL THEN
      LET p_qtd_reser = 0
   END IF
   
   LET p_qtd_saldo = p_qtd_saldo - p_qtd_reser
   
   IF p_qtd_saldo < p_qtd_neces THEN
      LET p_msg = 'Item alternativo..: ', p_cod_alternat, '\n',
                  'Estoque disponível: ', p_qtd_saldo, '\n',
                  'Necessidade.......: ', p_qtd_neces, '\n\n',
                  'Conclusão: a troca nã pode ser efetuada.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF                  
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1255_tem_op_lib()#
#----------------------------#

    SELECT sum(qtd_planej - qtd_boas - qtd_refug - qtd_sucata)
      INTO p_qtd_saldo
      FROM ordens
     WHERE cod_empresa = p_cod_empresa
       AND num_docum   = p_num_docum
       AND cod_item    = p_cod_alternat
       AND ies_situa   = p_ies_situa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF      

   IF p_qtd_saldo IS NULL THEN
      LET p_qtd_saldo = 0
   END IF
   
   IF p_qtd_saldo < p_qtd_neces THEN
      LET p_msg = 'Item alternativo...: ', p_cod_alternat, '\n',
                  'Saldo das ordens...: ', p_qtd_saldo, '\n',
                  'Necessidade........: ', p_qtd_neces, '\n\n',
                  'Conclusão: a troca nã pode ser efetuada.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF                  
   
   RETURN TRUE

END FUNCTION
          
#---------------------------#
FUNCTION pol1255_le_ordens()#
#---------------------------#

   INITIALIZE pr_ordens, pr_compl TO NULL
   LET p_ind = 1

   IF p_ies_docum = 'O' THEN
      LET p_query =
        "SELECT a.num_ordem, a.ies_situa, ",
        " (a.qtd_planej - a.qtd_boas - a.qtd_refug - a.qtd_sucata), ",
        "  (b.qtd_necessaria - b.qtd_saida) ",
        "  FROM ordens a, necessidades b ",
        " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
        "   AND a.ies_situa IN ('3','4') ",
        "   AND a.num_ordem = ",p_num_ordem, 
        "   AND b.cod_empresa = a.cod_empresa ",
        "   AND b.num_ordem = a.num_ordem ",
        "   AND b.cod_item = '",p_cod_item,"' "
   ELSE      
      LET p_query =
        "SELECT a.num_ordem, a.ies_situa,  ",
        " (a.qtd_planej - a.qtd_boas - a.qtd_refug - a.qtd_sucata), ",
        "  (b.qtd_necessaria - b.qtd_saida) ",
        "  FROM ordens a, necessidades b ",
        " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
        "   AND a.ies_situa IN ('3','4') ",
        "   AND a.num_docum = '",p_num_docum,"' ", 
        "   AND b.cod_empresa = a.cod_empresa ",
        "   AND b.num_ordem = a.num_ordem ",
        "   AND b.cod_item = '",p_cod_item,"' "
   END IF
   
   PREPARE p_cursor FROM p_query   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','p_cursor')     
      RETURN FALSE
   END IF

   DECLARE cq_docum CURSOR FOR p_cursor
   
   FOREACH cq_docum INTO 
         pr_ordens[p_ind].ordem,
         pr_ordens[p_ind].situacao,
         pr_ordens[p_ind].saldo,
         pr_ordens[p_ind].necessidade
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_docum')     
         RETURN FALSE
      END IF
      
      LET pr_compl[p_ind].necessidade = pr_ordens[p_ind].necessidade
      
      IF p_ies_docum = 'O' THEN
         IF p_alternat.neces_alternat <> p_alternat.neces_item THEN
            LET pr_ordens[p_ind].necessidade = 
                  pr_ordens[p_ind].saldo * p_alternat.neces_alternat
         END IF
      END IF      
      
      LET pr_ordens[p_ind].componente = p_cod_item
      LET pr_ordens[p_ind].alternativo = p_cod_alternat
      LET p_ind = p_ind + 1
      
      IF p_ind > 500 THEN
         LET p_msg = 'Limite de linhas da\n grade ultrapassou.' 
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF

   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Não há ordens com status 3/4,\n',
                  'para os parâmetros informados.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   LET p_qtd_itens = p_ind - 1
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1255_exibe_ops()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1255a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1255a AT 07,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_cod_empresa to cod_empresa
   LET INT_FLAG = FALSE
   
   CALL SET_COUNT(p_ind-1)
   
   DISPLAY ARRAY pr_ordens TO sr_ordens.*

   CLOSE WINDOW w_pol1255a
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------#
FUNCTION pol1255_insere()
#------------------------#
   
   SELECT MAX(id_registro)
     INTO p_alternat.id_registro
     FROM item_alternat_1054

   IF STATUS <> 0 THEN     
	    CALL log003_err_sql("SELECT","item_alternat_1054:MAX(id_registro)")       
      RETURN FALSE
   END IF
   
   IF p_alternat.id_registro IS NULL THEN
      LET p_alternat.id_registro = 0
   END IF
   
   LET p_alternat.id_registro = p_alternat.id_registro + 1
   
   INSERT INTO item_alternat_1054 VALUES (p_alternat.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","item_alternat_1054")       
      RETURN FALSE
   END IF
   
   LET p_id_registro = p_alternat.id_registro
   
   IF NOT pol1255_proces_troca() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1255_ins_audit()#
#---------------------------#

   INSERT INTO audit_alternat_1054
    VALUES(p_id_registro, p_texto)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","audit_alternat_1054")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   
   
#------------------------------#
FUNCTION pol1255_proces_troca()#
#------------------------------#

   FOR p_ind = 1 TO p_qtd_itens
       IF pr_ordens[p_ind].ordem IS NOT NULL THEN
          IF NOT pol1255_troca_op() THEN
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1255_troca_op()#
#--------------------------#

   LET p_num_ordem = pr_ordens[p_ind].ordem
   LET p_qtd_alter = pr_ordens[p_ind].Necessidade
   LET p_qtd_orig  = pr_compl[p_ind].Necessidade

   SELECT cod_item,
          num_docum,
          cod_local_prod
     INTO p_cod_item_pai,
          p_num_docum,
          p_cod_local_prd
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens:pto')     
      RETURN FALSE
   END IF

   IF p_ies_docum = 'O' THEN
      IF p_alternat.neces_alternat <> p_alternat.neces_item THEN
         IF NOT pol1255_gra_necessidades() THEN
            RETURN FALSE
         END IF
      END IF
   END IF      
      
   IF NOT pol1255_atu_necessidades() THEN
      RETURN FALSE
   END IF
   
   IF p_tip_orig MATCHES '[BC]' THEN
      LET p_local_orig = p_cod_local_prd
      LET p_local_dest = p_local_item
      
      IF NOT checa_transferencia(p_num_ordem) THEN
         RETURN FALSE
      END IF
      
      IF p_ies_transfere = 'S' THEN
         LET p_opcao = 'B' 
         LET p_qtd_neces = p_qtd_orig
         IF NOT pol1255_trans_mat() THEN
            RETURN FALSE
         END IF
      
         IF p_qtd_neces > 0 THEN
            LET p_msg = 'Componente: ', p_cod_item CLIPPED, '\n',
                        'sem estoque suficiente\n ',
                        'para devolver ao local\n',
                        'do estoque.' 
            CALL log0030_mensagem(p_msg, 'info')
            RETURN FALSE
         END IF
      END IF
   ELSE
      IF p_tip_orig = 'P' THEN
         LET p_qtd_neces = p_qtd_orig
         LET p_ies_tip_item = p_tip_orig
         IF NOT pol1255_le_op_item_trocado() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_tip_alternat MATCHES '[BC]' THEN
      LET p_local_dest = p_cod_local_prd
      LET p_local_orig = p_local_alternat
      LET p_cod_ant = p_cod_item
      LET p_cod_item = p_cod_alternat
      
      IF p_ies_transfere THEN
         LET p_opcao = 'B' 
         LET p_qtd_neces = p_qtd_alter
         IF NOT pol1255_trans_mat() THEN
            RETURN FALSE
         END IF

         IF p_qtd_neces > 0 THEN
            LET p_msg = 'Alternativo: ', p_cod_item CLIPPED, '\n',
                        'sem estoque suficiente\n ',
                        'para transferir ao local\n',
                        'do produção.' 
            CALL log0030_mensagem(p_msg, 'info')
            RETURN FALSE
         END IF
      END IF
      LET p_cod_item = p_cod_ant
   ELSE
      IF p_tip_alternat = 'P' THEN
         LET p_qtd_neces = p_qtd_alter
         LET p_cod_item = p_cod_alternat
         LET p_ies_tip_item = p_tip_alternat
         IF NOT pol1255_le_op_item_alternat() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   RETURN TRUE 

END FUNCTION   

#------------------------------------#
FUNCTION checa_transferencia(p_docum)#
#------------------------------------#
   
   DEFINE p_cod_op_transf LIKE par_pcp.cod_estoque_ac,
          p_docum         LIKE estoque_trans.num_docum
   
   SELECT cod_estoque_ac
    INTO p_cod_op_transf
    FROM par_pcp
   WHERE cod_empresa = p_cod_empresa       

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','MIN_PAR_MODULO')
      RETURN FALSE
   END IF
   
   IF p_cod_op_transf IS NULL OR  p_cod_op_transf = ' ' THEN
      LET p_msg = 'Operação de transferência\n inválida na tabela par_pcp '
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   END IF
   
   SELECT COUNT(cod_item)
     INTO p_count
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item
      AND num_docum = p_docum
      AND cod_local_est_orig = p_local_item
      AND cod_local_est_dest = p_cod_local_prd

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ESTOQUE_TRANS:CK_TRAN')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      LET p_ies_transfere = 'N'
   ELSE
      LET p_ies_transfere = 'S'
   END IF
   
   RETURN TRUE 

END FUNCTION   

#----------------------------------#
FUNCTION pol1255_atu_necessidades()#
#----------------------------------#
 
   UPDATE necessidades
      SET cod_item = p_cod_alternat
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_num_ordem
      AND cod_item = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','necessidades:pan')     
      RETURN FALSE
   END IF

   
   UPDATE ord_compon
      SET cod_item_compon = p_cod_alternat,
          ies_tip_item = p_tip_alternat
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_num_ordem
      AND cod_item_compon = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ord_compon:pan')     
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1255_gra_necessidades()#
#----------------------------------#

   UPDATE ord_compon
      SET qtd_necessaria = p_alternat.neces_alternat
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_num_ordem
      AND cod_item_compon = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ord_compon:pgn')     
      RETURN FALSE
   END IF
   
   LET P_qtd_planej = P_qtd_planej * p_alternat.neces_alternat
 
   UPDATE necessidades
      SET qtd_necessaria = P_qtd_planej
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_num_ordem
      AND cod_item = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','necessidades:pgn')     
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1255_trans_mat()#
#---------------------------#
   
   DECLARE cq_dev CURSOR FOR
    SELECT * FROM estoque_lote_ender
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = p_cod_item
       AND cod_local = p_local_orig

   FOREACH cq_dev INTO p_estoque_lote_ender.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_dev')     
         RETURN FALSE
      END IF

      LET p_cod_local = p_estoque_lote_ender.cod_local
      LET p_ies_situa = p_estoque_lote_ender.ies_situa_qtd
      LET p_num_lote = p_estoque_lote_ender.num_lote
      LET p_largura = p_estoque_lote_ender.largura
      LET p_altura = p_estoque_lote_ender.altura
      LET p_diametro = p_estoque_lote_ender.diametro
      LET p_comprimento = p_estoque_lote_ender.comprimento

      IF p_estoque_lote_ender.num_lote IS NULL THEN
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reser 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND num_lote    IS NULL
      ELSE
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reser 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND num_lote    = p_estoque_lote_ender.num_lote
      END IF
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_loc_reser:cq_bel')
         RETURN FALSE
      END IF  

      IF p_qtd_reser IS NULL OR p_qtd_reser < 0 THEN
         LET p_qtd_reser = 0
      END IF
      
      IF p_estoque_lote_ender.qtd_saldo > p_qtd_reser THEN
         LET p_estoque_lote_ender.qtd_saldo = p_estoque_lote_ender.qtd_saldo - p_qtd_reser
      ELSE
         CONTINUE FOREACH
      END IF
      
      LET p_qtd_saldo = p_estoque_lote_ender.qtd_saldo
      
      IF p_qtd_saldo <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF p_qtd_saldo > p_qtd_neces THEN
         LET p_qtd_movto = p_qtd_neces
         LET p_qtd_neces = 0
      ELSE
         LET p_qtd_movto = p_qtd_saldo
         LET p_qtd_neces = p_qtd_neces - p_qtd_saldo
      END IF
      
      IF NOT pol1255_transfere() THEN
         RETURN FALSE
      END IF
      
      IF p_qtd_neces <= 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH
         
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1255_transfere()#
#---------------------------#

   IF NOT pol1255_le_lote() THEN
      RETURN FALSE
   END IF
      
   IF p_estoque_lote_ender.qtd_saldo > p_estoque_lote.qtd_saldo THEN
      LET p_msg = 'Item:  ', p_estoque_lote_ender.cod_item CLIPPED, '\n',
                  'Lote:  ', p_estoque_lote_ender.num_lote CLIPPED, '\n',
                  'Local: ', p_estoque_lote_ender.cod_local CLIPPED, '\n\n',
                  'Incompatibilidade entre tabelas de estoque.\n\n',
                  'Saldo estoque_lote......: ', p_estoque_lote.qtd_saldo, '\n',
                  'Saldo estoque_lote_ender: ', p_estoque_lote_ender.qtd_saldo, '\n'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   LET p_qtd_transfer = p_qtd_movto
   
   IF p_opcao = 'B' THEN
      LET p_qtd_movto = p_qtd_movto * (-1)
   END IF
   
   IF NOT pol1255_grava_estoq_orig() THEN
      RETURN FALSE
   END IF
   
   LET p_qtd_movto = p_qtd_transfer
   
   IF NOT pol1255_grava_trans() THEN
      RETURN FALSE
   END IF

   LET p_cod_local = p_local_dest

   IF NOT pol1255_grava_estoq_dest() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1255_le_lote()#
#-------------------------#

   IF p_num_lote IS NULL THEN
      SELECT * INTO p_estoque_lote.*
        FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
         AND cod_local = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote IS NULL
   ELSE
      SELECT * INTO p_estoque_lote.*
        FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
         AND cod_local = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote = p_num_lote
   END IF
   
   IF STATUS = 100 THEN
      LET p_estoque_lote.num_transac = 0
      LET p_estoque_lote.qtd_saldo = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_lote')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION 
         
#----------------------------------#
FUNCTION pol1255_grava_estoq_orig()#
#----------------------------------#

   IF NOT pol1255_atu_lote_ender() THEN
      RETURN FALSE
   END IF

   IF NOT pol1255_atu_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol1255_atu_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT pol1255_del_lote_zero() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1255_atu_lote_ender()#
#--------------------------------#   
      
   UPDATE estoque_lote_ender SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
      AND num_transac = p_estoque_lote_ender.num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque_lote_ender')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1255_atu_lote()#
#--------------------------#   
   
   UPDATE estoque_lote SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_estoque_lote.cod_empresa
      AND num_transac = p_estoque_lote.num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque_lote')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1255_atu_estoque()#
#-----------------------------#   

   IF p_ies_situa = 'L' THEN
      UPDATE estoque SET qtd_liberada = qtd_liberada + p_qtd_movto
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
   ELSE
      UPDATE estoque SET qtd_lib_excep = qtd_lib_excep + p_qtd_movto
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1255_del_lote_zero()#
#-------------------------------# 

   DELETE FROM estoque_lote_ender 
    WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
      AND num_transac = p_estoque_lote_ender.num_transac
      AND qtd_saldo <= 0
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','estoque_lote_ender')
      RETURN FALSE
   END IF

   DELETE FROM estoque_lote 
    WHERE cod_empresa = p_estoque_lote.cod_empresa
      AND num_transac = p_estoque_lote.num_transac
      AND qtd_saldo <= 0
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','estoque_lote')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1255_grava_trans()#
#-----------------------------#

   INITIALIZE p_estoque_trans.* TO NULL

   LET p_estoque_trans.cod_empresa        = p_estoque_lote_ender.cod_empresa
   LET p_estoque_trans.cod_item           = p_estoque_lote_ender.cod_item
   LET p_estoque_trans.dat_movto          = TODAY
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = "POL1255"
   LET p_estoque_trans.num_docum          = p_num_ordem
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.qtd_movto          = p_qtd_movto
   LET p_estoque_trans.ies_sit_est_orig   = p_estoque_lote_ender.ies_situa_qtd
   LET p_estoque_trans.ies_sit_est_dest   = p_estoque_lote_ender.ies_situa_qtd
   LET p_estoque_trans.cod_local_est_orig = p_local_orig
   LET p_estoque_trans.cod_local_est_dest = p_local_dest
   LET p_estoque_trans.num_lote_orig      = p_estoque_lote_ender.num_lote
   LET p_estoque_trans.num_lote_dest      = p_estoque_lote_ender.num_lote

   IF NOT pol1255_ins_estoq_trans() THEN
      RETURN FALSE
   END IF   

   IF NOT pol1255_gra_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol1255_insere_estoq_audit() THEN
      RETURN FALSE
   END IF
   
   LET p_qtd_txt = p_qtd_movto
   
   LET p_texto = 'Transf. de ', p_qtd_txt, ' do item ', p_estoque_trans.cod_item CLIPPED,
                 ' do local ', p_local_orig CLIPPED,
                 ' para o local ', p_local_dest
   
   IF NOT pol1255_ins_audit() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1255_ins_estoq_trans()#
#---------------------------------#

   LET p_estoque_trans.num_transac   = 0
   LET p_estoque_trans.ies_tip_movto = 'N'
   LET p_estoque_trans.nom_usuario   = p_user
   LET p_estoque_trans.dat_proces    = p_dat_atu
   LET p_estoque_trans.hor_operac    = p_hor_atu

    INSERT INTO estoque_trans(
          cod_empresa,
          #aquinum_transac,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  #aquip_estoque_trans.num_transac,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   


   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans')
     RETURN FALSE
   END IF

   LET p_num_transac_orig = SQLCA.SQLERRD[2]

   RETURN TRUE

END FUNCTION
   
#------------------------------------#
 FUNCTION pol1255_gra_est_trans_end()
#------------------------------------#

   INITIALIZE p_estoque_trans_end.*   TO NULL

   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f 
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = " "
   LET p_estoque_trans_end.tex_reservado    = " "
   LET p_estoque_trans_end.num_transac      = p_num_transac_orig
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1255_insere_estoq_audit()
#-----------------------------------#

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, 
            p_num_transac_orig, 
            p_user, 
            p_dat_atu,
            p_estoque_trans.num_prog)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria:fiea')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1255_grava_estoq_dest()#
#----------------------------------#

   IF NOT pol1255_le_lote_ender() THEN
      RETURN FALSE
   END IF   
   
   IF p_estoque_lote_ender.num_transac = 0 THEN #não tem o lote
      IF NOT pol1255_ins_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1255_atu_lote_ender() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol1255_le_lote() THEN
      RETURN FALSE
   END IF

   IF p_estoque_lote.num_transac = 0 THEN #não tem o lote
      IF NOT pol1255_ins_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1255_atu_lote() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1255_atu_estoque() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1255_le_lote_ender()#
#-------------------------------#

   IF p_num_lote IS NULL THEN
      SELECT * INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
         AND cod_local = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND largura =  p_largura    
         AND altura  =  p_altura     
         AND diametro = p_diametro   
         AND comprimento = p_comprimento
         AND num_lote IS NULL
   ELSE
      SELECT * INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
         AND cod_local = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND largura =  p_largura    
         AND altura  =  p_altura     
         AND diametro = p_diametro   
         AND comprimento = p_comprimento
         AND num_lote = p_num_lote
   END IF
   
   IF STATUS = 100 THEN
      LET p_estoque_lote_ender.num_transac = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','estoque_lote_ender')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION 

#--------------------------------#
FUNCTION pol1255_ins_lote_ender()#
#--------------------------------#
   
   CALL pol1255_ender_carrega()
   
   INSERT INTO estoque_lote_ender(
          cod_empresa,
          cod_item,
          cod_local,
          num_lote,
          endereco,
          num_volume,
          cod_grade_1,
          cod_grade_2,
          cod_grade_3,
          cod_grade_4,
          cod_grade_5,
          dat_hor_producao,
          num_ped_ven,
          num_seq_ped_ven,
          ies_situa_qtd,
          qtd_saldo,
          #aquinum_transac,
          ies_origem_entrada,
          dat_hor_validade,
          num_peca,
          num_serie,
          comprimento,
          largura,
          altura,
          diametro,
          dat_hor_reserv_1,
          dat_hor_reserv_2,
          dat_hor_reserv_3,
          qtd_reserv_1,
          qtd_reserv_2,
          qtd_reserv_3,
          num_reserv_1,
          num_reserv_2,
          num_reserv_3,
          tex_reservado) 
          VALUES(p_estoque_lote_ender.cod_empresa,
                 p_estoque_lote_ender.cod_item,
                 p_estoque_lote_ender.cod_local,
                 p_estoque_lote_ender.num_lote,
                 p_estoque_lote_ender.endereco,
                 p_estoque_lote_ender.num_volume,
                 p_estoque_lote_ender.cod_grade_1,
                 p_estoque_lote_ender.cod_grade_2,
                 p_estoque_lote_ender.cod_grade_3,
                 p_estoque_lote_ender.cod_grade_4,
                 p_estoque_lote_ender.cod_grade_5,
                 p_estoque_lote_ender.dat_hor_producao,
                 p_estoque_lote_ender.num_ped_ven,
                 p_estoque_lote_ender.num_seq_ped_ven,
                 p_estoque_lote_ender.ies_situa_qtd,
                 p_estoque_lote_ender.qtd_saldo,
                 #aquip_estoque_lote_ender.num_transac,
                 p_estoque_lote_ender.ies_origem_entrada,
                 p_estoque_lote_ender.dat_hor_validade,
                 p_estoque_lote_ender.num_peca,
                 p_estoque_lote_ender.num_serie,
                 p_estoque_lote_ender.comprimento,
                 p_estoque_lote_ender.largura,
                 p_estoque_lote_ender.altura,
                 p_estoque_lote_ender.diametro,
                 p_estoque_lote_ender.dat_hor_reserv_1,
                 p_estoque_lote_ender.dat_hor_reserv_2,
                 p_estoque_lote_ender.dat_hor_reserv_3,
                 p_estoque_lote_ender.qtd_reserv_1,
                 p_estoque_lote_ender.qtd_reserv_2,
                 p_estoque_lote_ender.qtd_reserv_3,
                 p_estoque_lote_ender.num_reserv_1,
                 p_estoque_lote_ender.num_reserv_2,
                 p_estoque_lote_ender.num_reserv_3,
                 p_estoque_lote_ender.tex_reservado)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_lote_ender')
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1255_ins_lote()#
#--------------------------#

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo)
          #aquinum_transac)  
          VALUES(p_cod_empresa,
                 p_cod_item,
                 p_cod_local,
                 p_num_lote,
                 p_ies_situa,
                 p_qtd_movto)
                 #aquip_estoque_lote.num_transac)
                 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estoque_lote')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1255_ender_carrega()#
#-------------------------------#

   LET p_estoque_lote_ender.cod_empresa   = p_cod_empresa
	 LET p_estoque_lote_ender.cod_item      = p_cod_item
	 LET p_estoque_lote_ender.cod_local     = p_cod_local
	 LET p_estoque_lote_ender.num_lote      = p_num_lote
	 LET p_estoque_lote_ender.ies_situa_qtd = p_ies_situa
	 LET p_estoque_lote_ender.qtd_saldo     = p_qtd_movto
   LET p_estoque_lote_ender.largura       = p_largura
   LET p_estoque_lote_ender.altura        = p_altura
   LET p_estoque_lote_ender.diametro      = p_diametro
   LET p_estoque_lote_ender.comprimento   = p_comprimento
   LET p_estoque_lote_ender.num_serie     = ' '
   LET p_estoque_lote_ender.dat_hor_producao   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.endereco           = ' '
   LET p_estoque_lote_ender.num_volume         = '0'
   LET p_estoque_lote_ender.cod_grade_1        = ' '
   LET p_estoque_lote_ender.cod_grade_2        = ' '
   LET p_estoque_lote_ender.cod_grade_3        = ' '
   LET p_estoque_lote_ender.cod_grade_4        = ' '
   LET p_estoque_lote_ender.cod_grade_5        = ' '
   LET p_estoque_lote_ender.num_ped_ven        = 0
   LET p_estoque_lote_ender.num_seq_ped_ven    = 0
   LET p_estoque_lote_ender.ies_situa_qtd      = p_ies_situa
   LET p_estoque_lote_ender.num_transac        = 0
   LET p_estoque_lote_ender.ies_origem_entrada = ' '
   LET p_estoque_lote_ender.dat_hor_validade   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.num_peca           = ' '
   LET p_estoque_lote_ender.dat_hor_reserv_1   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_2   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_3   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.qtd_reserv_1       = 0
   LET p_estoque_lote_ender.qtd_reserv_2       = 0
   LET p_estoque_lote_ender.qtd_reserv_3       = 0
   LET p_estoque_lote_ender.num_reserv_1       = 0
   LET p_estoque_lote_ender.num_reserv_2       = 0
   LET p_estoque_lote_ender.num_reserv_3       = 0
   LET p_estoque_lote_ender.tex_reservado      = ' '
   
END FUNCTION

#---------------------------#
FUNCTION pol1255_cria_tabs()#
#---------------------------#

   DROP TABLE item_troca_1054

   CREATE  TABLE item_troca_1054(
         num_ordem      INTEGER,
         ies_situa      CHAR(01),
         cod_local_prd  CHAR(10),
         cod_item       CHAR(15),
         ies_tipo       CHAR(01),
         qtd_item       DECIMAL(10,2),
         explodiu       CHAR(01)
    );
         
   IF STATUS <> 0 THEN 
      DELETE FROM item_troca_1054
      SELECT COUNT(*) INTO p_count FROM item_troca_1054
      IF p_count > 0 THEN
         LET p_msg = 'Não foi possivel limpar a tabela\n temporária item_troca_1054'
         CALL log0030_mensagem(p_msg,'info')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1255_pega_op()#
#-------------------------#

   LET p_houve_erro = TRUE

   SELECT num_ordem,
          cod_local_prod,
          (qtd_boas+qtd_refug+qtd_sucata) 
     INTO p_op_calcel, 
          p_cod_local_prd,
          p_qtd_prod
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = p_num_docum
      AND cod_item = p_cod_item
      AND cod_item_pai = p_cod_item_pai
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens:pop')     
      RETURN FALSE
   END IF

   IF p_qtd_prod = 0 THEN
      SELECT SUM(qtd_boas+qtd_refugo+qtd_sucata)
        INTO p_qtd_prod
        FROM ord_oper 
       WHERE cod_empresa = p_cod_empresa 
         AND num_ordem = p_op_calcel
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ord_oper:pio')     
         RETURN FALSE
      END IF
   END IF
   
   IF p_qtd_prod = 0 THEN
      LET p_ies_situa = '9'
   ELSE
      LET p_ies_situa = '5'
   END IF
         
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1255_le_op_alternat()#
#--------------------------------#

   LET p_houve_erro = TRUE

   SELECT num_ordem,
          cod_local_prod,
          (qtd_boas+qtd_refug+qtd_sucata),
          ies_situa 
     INTO p_op_calcel, 
          p_cod_local_prd,
          p_qtd_prod, 
          p_ies_situa
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = p_num_docum
      AND cod_item = p_cod_item
      AND cod_item_pai = p_cod_item_pai
      AND ies_situa IN ('3','4')
   
   IF STATUS = 100 THEN
      LET p_qtd_prod = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordens:loa')     
         RETURN FALSE
      END IF
   END IF

   IF p_qtd_prod < p_qtd_neces THEN
      LET p_msg = 'Tip troca:', p_tip_orig, ' p/ ', p_tip_alternat, '\n',
                  'Item.....: ', p_cod_item CLIPPED, '\n',
                  'Tipo.....: ', p_ies_tip_item, '\n',
                  'Filho de.: ', p_cod_item_pai CLIPPED, '\n',
                  'Necessita: ', p_qtd_neces, '\n',
                  'Sdo da OP: ', p_qtd_prod, '\n\n',
                  'Conclusão: troca não permitida'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
            
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1255_insere_ordem()
#-----------------------------#
   
   INSERT INTO item_troca_1054
      VALUES(p_op_calcel, 
             p_ies_situa,
             p_cod_local_prd,
             p_cod_item, 
             p_ies_tip_item,
             p_qtd_neces,
             p_explodiu)

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("Iserindo","item_troca_1054")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1255_le_op_item_trocado()#
#------------------------------------#
   
   IF NOT pol1255_cria_tabs() THEN
      RETURN FALSE
   END IF

   IF NOT pol1255_pega_op() THEN
      RETURN FALSE
   END IF
   
   LET p_explodiu   = 'N'
   
   IF NOT pol1255_insere_ordem() THEN
      RETURN FALSE
   END IF
   
   LET p_proces = 'O'
   
   IF NOT pol1255_explode_estrutura() THEN
      RETURN FALSE
   END IF

   IF NOT pol1255_cancel_fecha_ops() THEN 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1255_le_op_item_alternat()#
#-------------------------------------#
   
   IF NOT pol1255_cria_tabs() THEN
      RETURN FALSE
   END IF

   IF NOT pol1255_le_op_alternat() THEN
      RETURN FALSE
   END IF
   
   LET p_explodiu   = 'N'
   
   IF NOT pol1255_insere_ordem() THEN
      RETURN FALSE
   END IF

   LET p_proces = 'A'
   
   IF NOT pol1255_explode_estrutura() THEN
      RETURN FALSE
   END IF

   IF NOT pol1255_transf_alternat() THEN 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1255_explode_estrutura()
#-----------------------------------#
  
   WHILE TRUE
    
    SELECT COUNT(cod_item)
      INTO p_count
      FROM item_troca_1054
     WHERE explodiu = 'N'
       AND ies_tipo = 'P'
     
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','item_troca_1054')
       RETURN FALSE
    END IF
    
    IF p_count = 0 THEN
       EXIT WHILE
    END IF
    
    DECLARE cq_exp CURSOR FOR
     SELECT num_ordem,
            cod_item,
            cod_local_prd
       FROM item_troca_1054
      WHERE explodiu = 'N'
        AND ies_tipo = 'P'
    
    FOREACH cq_exp INTO 
            p_op_calcel,
            p_cod_item_pai,
            p_cod_local_prd
    
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','item_troca_1054')
          RETURN FALSE
       END IF

       SELECT ies_situa
         INTO P_status_op
         FROM ordens
        WHERE cod_empresa = p_cod_empresa
          AND num_ordem = p_op_calcel 

       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','ordens:es')
          RETURN FALSE
       END IF
       
       UPDATE item_troca_1054
          SET explodiu = 'S'
        WHERE num_ordem = p_op_calcel

       IF STATUS <> 0 THEN
          CALL log003_err_sql('Atualizando','item_troca_1054')
          RETURN FALSE
       END IF
       
       LET p_op_ant = p_op_calcel
       
       DECLARE cq_est CURSOR FOR
        SELECT cod_item,
               (qtd_necessaria - qtd_saida)
          FROM necessidades
         WHERE cod_empresa  = p_cod_empresa
           AND num_ordem    = p_op_calcel       
             
       FOREACH cq_est INTO p_cod_item, p_qtd_neces

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Lendo','estrutura')
             RETURN FALSE
          END IF
          
          IF NOT pol1255_le_tip_item() THEN
             RETURN FALSE
          END IF
          
          IF p_ies_tip_item MATCHES '[CB]' THEN
             
             LET p_op_calcel = p_op_ant
             LET p_explodiu = 'S'
             
             IF P_status_op = '4' THEN
                IF p_proces = 'O' THEN
                   LET p_ies_situa = 'D'
                ELSE
                   SELECT SUM(qtd_saldo)
                     INTO p_qtd_saldo
                     FROM estoque_lote
                    WHERE cod_empresa = p_cod_empresa
                      AND cod_item = p_cod_item
                      AND ies_situa_qtd IN ('L','E')
                   IF p_qtd_saldo < p_qtd_neces THEN
                      LET p_msg = 'Tip troca:', p_tip_orig, ' p/ ', p_tip_alternat, '\n',
                                  'Item.....:', p_cod_item, '\n',
                                  'Tipo.....:', p_ies_tip_item, '\n',
                                  'Sem saldo suficiente para \n',
                                  'transferir para o local ', p_cod_local_prd
                      CALL log0030_mensagem(p_msg,'info')
                      RETURN FALSE
                   END IF
                   LET p_ies_situa = 'T'
                END IF       
             ELSE
                LET p_ies_situa = 'N'
             END IF
          ELSE
             LET p_explodiu = 'N'
             IF p_proces = 'O' THEN
                IF NOT pol1255_pega_op() THEN
                   LET p_msg = 'Tip troca:', p_tip_orig, ' p/ ', p_tip_alternat, '\n',
                               'Não foi possivel localizar a ordem\n',
                               'do item ', p_cod_item CLIPPED, ', o qual está/n',
                               'abaixo do item ', p_cod_item_pai
                   CALL log0030_mensagem(p_msg,'info')
                   RETURN FALSE
                END IF
             ELSE
                IF NOT pol1255_le_op_alternat() THEN
                   RETURN FALSE
                END IF
             END IF
          END IF

          IF NOT pol1255_insere_ordem() THEN
             RETURN FALSE
          END IF
         
       END FOREACH
   
    END FOREACH
   
   END WHILE
   
   RETURN TRUE

END FUNCTION 

#-----------------------------#
FUNCTION pol1255_le_tip_item()
#-----------------------------#
          
   SELECT ies_tip_item 
     INTO p_ies_tip_item
     FROM item 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1255_cancel_fecha_ops()#
#----------------------------------#

   DECLARE cq_cacela CURSOR FOR
    SELECT num_ordem,
           ies_situa,
           cod_local_prd,
           cod_item,
           ies_tipo,
           qtd_item
      FROM item_troca_1054

   FOREACH cq_cacela INTO 
           p_op_calcel, p_ies_situa,
           p_cod_local_prd, p_cod_item, 
           p_ies_tip_item, p_qtd_neces   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_cacela')
         RETURN FALSE
      END IF
   
      IF p_ies_tip_item = 'P' THEN
         IF NOT pol1255_atu_op() THEN
            RETURN FALSE
         END IF
      ELSE
         IF p_ies_situa = 'D' THEN
            IF NOT pol1255_dev_mat() THEN
               RETURN FALSE
            END IF
         END IF
      END IF         
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol1255_transf_alternat()#
#---------------------------------#

   DECLARE cq_cacela CURSOR FOR
    SELECT num_ordem,
           ies_situa,
           cod_local_prd,
           cod_item,
           ies_tipo,
           qtd_item
      FROM item_troca_1054
     WHERE ies_situa = 'T'

   FOREACH cq_cacela INTO 
           p_op_calcel, p_ies_situa,
           p_cod_local_prd, p_cod_item, 
           p_ies_tip_item, p_qtd_neces   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_cacela')
         RETURN FALSE
      END IF
   
      IF NOT pol1255_trf_mat() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#------------------------#
FUNCTION pol1255_atu_op()#
#------------------------#

   UPDATE ordens 
      SET ies_situa = p_ies_situa, 
          dat_atualiz = p_dat_atu
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_op_calcel
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ordens:poc')     
      RETURN FALSE
   END IF
      
   UPDATE necessidades 
      SET ies_situa = p_ies_situa
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_op_calcel
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','necessidades:poc')     
      RETURN FALSE
   END IF

   DELETE FROM trans_pendentes 
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_op_calcel

   IF p_ies_situa = '5' THEN
      LET p_texto = 'Encerramento da OP ', p_op_calcel, ' do item ', p_cod_item CLIPPED
   ELSE
      LET p_texto = 'Cancelamento da OP ', p_op_calcel, ' do item ', p_cod_item CLIPPED
   END IF
   
   IF NOT pol1255_ins_audit() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1255_dev_mat()#
#-------------------------#

   LET p_local_orig = p_cod_local_prd
   LET p_opcao = 'B' 

   SELECT cod_local_estoq
     INTO p_local_dest
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item:dev_mat')     
      RETURN FALSE
   END IF
      
   IF NOT pol1255_trans_mat() THEN
      RETURN FALSE
   END IF
      
   IF p_qtd_neces > 0 THEN
      LET p_msg = 'Componente: ', p_cod_item CLIPPED, '\n',
                  'sem estoque suficiente\n ',
                  'para devolver ao local\n',
                  'do estoque ', p_local_orig 
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1255_trf_mat()#
#-------------------------#

   LET p_local_dest = p_cod_local_prd
   LET p_opcao = 'B' 

   SELECT cod_local_estoq
     INTO p_local_orig
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item:dev_mat')     
      RETURN FALSE
   END IF
      
   IF NOT pol1255_trans_mat() THEN
      RETURN FALSE
   END IF
      
   IF p_qtd_neces > 0 THEN
      LET p_msg = 'Componente: ', p_cod_item CLIPPED, '\n',
                  'sem estoque suficiente\n ',
                  'para devolver ao local\n',
                  'do produção ', p_local_dest
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
      
#--------------------------#
 FUNCTION pol1255_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1255_limpa_tela()
   LET p_alternata.* = p_alternat.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      item_alternat_1054.tip_docum,        
      item_alternat_1054.num_docum,    
      item_alternat_1054.cod_item,     
      item_alternat_1054.item_alternat
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1255_limpa_tela()
         ELSE
            LET p_alternat.* = p_alternata.*
            CALL pol1255_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT * ",
                  "  FROM item_alternat_1054 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_alternat.*

   IF STATUS <> 0 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1255_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1255_exibe_dados()
#------------------------------#

   LET p_cod_item = p_alternat.cod_item
   LET p_num_docum = p_alternat.num_docum
   
   SELECT *
     INTO p_alternat.*
     FROM item_alternat_1054
    WHERE id_registro =  p_alternat.id_registro
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'item_alternat_1054')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_alternat.*
      
   CALL pol1255_le_den_item(p_alternat.cod_item) RETURNING p_status
   DISPLAY p_den_item to den_item
   DISPLAY p_tip_item TO tip_item

   CALL pol1255_le_den_item(p_alternat.item_alternat) RETURNING p_status
   DISPLAY p_den_item to den_alternat
   DISPLAY p_tip_item TO tip_alternat
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1255_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao   CHAR(01)

   LET p_alternata.* = p_alternat.*
    
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_alternat.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_alternat.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_item
           FROM item_alternat_1054
          WHERE id_registro =  p_alternat.id_registro
            
         IF STATUS = 0 THEN
            IF pol1255_exibe_dados() THEN
               LET p_excluiu = FALSE
               EXIT WHILE
            END IF
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_alternat.* = p_alternata.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#-------FIM DO PROGRAMA BI---------#
   