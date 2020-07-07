#-------------------------------------------------------------------#
# SISTEMA.: ESTOQUE                                                 #
# PROGRAMA: pol0448                                                 #
# OBJETIVO: ESTOQUE DA ESTRUTURA DOS ITENS                          #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 08/06/2006                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_item           LIKE item.den_item,
          p_cod_local_estoq    LIKE item.cod_local_estoq,
          p_den_item_redux     LIKE item.den_item_reduz,
          p_qtd_planej         LIKE ordens.qtd_planej,
          p_cod_local          LIKE ordens.cod_local_estoq,
          p_cod_local_pai      LIKE ordens.cod_local_estoq,
          p_prioridade         LIKE man_prior_consumo.prioridade,
          p_dat_med            LIKE estoque_trans.dat_movto,
          p_cod_item_pai       LIKE item.cod_item,
          p_qtd_necessaria     LIKE estrutura.qtd_necessaria,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_qtd_etoq_reser     LIKE estoque.qtd_liberada,
          p_qtd_reser          LIKE estoque_loc_reser.qtd_reservada,
          p_cria_temp          SMALLINT,
          p_msg                CHAR(300),
          p_grava_temp         SMALLINT,
          p_control            CHAR(01),
          p_cod_nivel_temp     DECIMAL(2,0),
          p_cod_nivel          DECIMAL(2,0),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          ped_index            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
#          p_versao             CHAR(17),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(80),
          p_den_item_compon    LIKE item.den_item


   DEFINE p_tela              RECORD
          cod_item            LIKE item.cod_item,
          den_item            LIKE item.den_item_reduz,
          qtd_penden          LIKE ordens.qtd_planej,
          qtd_planej          LIKE ordens.qtd_planej,
          qtd_abert           LIKE ordens.qtd_planej,
          qtd_liberac         LIKE ordens.qtd_planej,
          qtd_saldo           LIKE ordens.qtd_planej,
          qtd_fila            LIKE ordens.qtd_planej,
          qtd_dispon          LIKE ordens.qtd_planej,
          qtd_reservada        LIKE ordens.qtd_planej,
          med_mensal          LIKE ordens.qtd_planej,
          preco_item          DECIMAL(12,2)
   END RECORD

   DEFINE pr_compon           ARRAY[400] OF RECORD
          ies_alternat        CHAR(01),
          cod_item_compon     LIKE item.cod_item,
          tip_item            LIKE item.ies_tip_item,
          cod_local           LIKE item.cod_local_estoq,
          qtd_saldo_compon    LIKE estoque_lote.qtd_saldo,
          qtd_fila_compon     LIKE estoque_lote.qtd_saldo,
          qtd_necessaria      LIKE estoque_lote.qtd_saldo,
          qtd_dispon_compon   LIKE estoque_lote.qtd_saldo
   END RECORD

   DEFINE p_compon RECORD
      Cod_item_pai      CHAR (15),
      Cod_item_compon   CHAR (15),
      cod_nivel         DECIMAL(2,0),
      Qtd_necessaria    DECIMAL(7,3),
      ies_alternat      CHAR(01),
      tip_item          CHAR(01),
      cod_local         CHAR(10),
      qtd_saldo_compon  DECIMAL(9,3),
      qtd_fila_compon   DECIMAL(9,3),
      qtd_dispon_compon DECIMAL(9,3)
   END RECORD

   DEFINE pr_pedidos    ARRAY[400] OF RECORD
          num_pedido    LIKE pedidos.num_pedido,
          nom_cliente   LIKE clientes.nom_cliente,
          prz_entrega   LIKE ped_itens.prz_entrega,
          qtd_saldo     LIKE ped_itens.qtd_pecas_solic
   END RECORD

   DEFINE pr_ordens     ARRAY[400] OF RECORD
          num_ordem     LIKE ordens.num_ordem,
          qtd_planej    LIKE ordens.qtd_planej,
          qtd_saldo     LIKE ordens.qtd_planej,
          dat_abert     LIKE ordens.dat_abert,
          dat_entrega   LIKE ordens.dat_entrega,
          ies_situa     LIKE ordens.ies_situa
   END RECORD

   DEFINE pr_ord_sup       ARRAY[400] OF RECORD
          num_oc           LIKE ordem_sup.num_oc,
          qtd_solic        LIKE ordem_sup.qtd_solic,
          qtd_saldo        LIKE ordem_sup.qtd_solic,
          dat_emis         LIKE ordem_sup.dat_emis,
          dat_entrega_prev LIKE ordem_sup.dat_entrega_prev,
          ies_situa_oc     LIKE ordem_sup.ies_situa_oc
   END RECORD

   DEFINE p_prior        ARRAY[400] OF RECORD
          prioridade     LIKE man_prior_consumo.prioridade,
          docum          LIKE man_prior_consumo.docum,
          tip_docum      LIKE man_prior_consumo.tip_docum,
          info_compl_2   LIKE man_prior_consumo.info_compl_2,
          prior_atendida LIKE man_prior_consumo.prior_atendida,
          cod_repres     LIKE pedidos.cod_tip_carteira,
          qtd_reservada  LIKE man_prior_consumo.qtd_reservada
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0448-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0448.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
#      NEXT KEY control-f,
#      INSERT KEY control-i,
#      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0448_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0448_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0448") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0448 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informa parâmetros para consulta"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         LET p_cria_temp = TRUE
         LET p_grava_temp = TRUE
         CALL pol0448_informar()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0448_sobre() 
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0448

END FUNCTION


#-----------------------#
FUNCTION pol0448_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
FUNCTION pol0448_informar()
#--------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0448
   CLEAR FORM
   INITIALIZE p_tela.* TO NULL
   DISPLAY p_cod_empresa TO cod_empresa
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD cod_item
         IF p_tela.cod_item IS NULL THEN
            ERROR 'Informe o código do item !!!'
            NEXT FIELD cod_item
         END IF
         
         SELECT den_item_reduz, 
                cod_local_estoq
           INTO p_tela.den_item,
                p_cod_local_pai
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_tela.cod_item
            
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR 'Item não cadastrado !!!'
            NEXT FIELD cod_item
         END IF 

      ON KEY (control-z)
         CALL pol0368_popup()

   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_cod_nivel = 1
      LET p_cod_item_pai = p_tela.cod_item
      CALL pol0448_le_estrutura()
   ELSE
      MESSAGE 'Operação Cancelada !!!' ATTRIBUTE(REVERSE)
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0448_le_estrutura()
#-----------------------------#

   SELECT den_item_reduz, 
          cod_local_estoq
     INTO p_tela.den_item,
          p_cod_local_pai
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_tela.cod_item

   IF p_cria_temp THEN
      LET p_cria_temp = FALSE
      IF NOT pol0448_cria_temp() THEN
         RETURN
      END IF
   END IF

   IF p_grava_temp THEN
      IF NOT pol0448_grava_estrutura() THEN
         RETURN
      END IF
   END IF

   CALL pol0448_exibe_dados()
   CALL pol0448_exibe_estrutura()

END FUNCTION 

#--------------------------#
FUNCTION pol0448_cria_temp()
#--------------------------#

   WHENEVER ERROR CONTINUE
   
      DROP TABLE compon_temp;

   WHENEVER ERROR STOP
   
   CREATE TABLE compon_temp
  (
   Cod_item_pai      CHAR (15)    NOT NULL,
   Cod_item_compon   CHAR (15)    NOT NULL,
   cod_nivel         DECIMAL(2,0) NOT NULL,
   Qtd_necessaria    DECIMAL(7,3),
   ies_alternat      CHAR(01),
   tip_item          CHAR(01),
   cod_local         CHAR(10),
   qtd_saldo_compon  DECIMAL(9,3),
   qtd_fila_compon   DECIMAL(9,3),
   qtd_dispon_compon DECIMAL(9,3)

   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","compon_mark")
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#--------------------------------#
FUNCTION pol0448_grava_estrutura()
#--------------------------------#

   LET p_compon.cod_item_pai = p_cod_item_pai
   DECLARE cq_estru CURSOR FOR
    SELECT a.cod_item_compon,
           a.qtd_necessaria,
           b.ies_tip_item,
           b.cod_local_estoq
      FROM estrutura a,
           item b
     WHERE a.cod_empresa  = p_cod_empresa
       AND a.cod_item_pai = p_cod_item_pai
       AND b.cod_empresa  = a.cod_empresa
       AND b.cod_item     = a.cod_item_compon
     ORDER BY 1
       
   FOREACH cq_estru INTO
           p_compon.cod_item_compon,
           p_compon.qtd_necessaria,
           p_compon.tip_item,
           p_compon.cod_local
      
      IF p_compon.tip_item = 'T' THEN
         LET p_cod_item_pai = p_compon.cod_item_compon
         IF NOT pol0448_trata_fantasma() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0448_insere_compon() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
         
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0448_trata_fantasma()
#--------------------------------#

   DECLARE cq_fantasma CURSOR FOR
    SELECT a.cod_item_compon,
           a.qtd_necessaria,
           b.ies_tip_item,
           b.cod_local_estoq
      FROM estrutura a,
           item b
     WHERE a.cod_empresa  = p_cod_empresa
       AND a.cod_item_pai = p_cod_item_pai
       AND b.cod_empresa  = a.cod_empresa
       AND b.cod_item     = a.cod_item_compon
     ORDER BY 1
       
   FOREACH cq_fantasma INTO
           p_compon.cod_item_compon,
           p_compon.qtd_necessaria,
           p_compon.tip_item,
           p_compon.cod_local
      
      IF NOT pol0448_insere_compon() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
         
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0448_insere_compon()
#-------------------------------#

   LET p_cod_item_pai = p_compon.cod_item_compon
   LET p_cod_local    = p_compon.cod_local
   LET p_compon.cod_nivel = p_cod_nivel
   LET p_compon.ies_alternat = NULL
   CALL pol0448_calcula_saldo() RETURNING 
        p_compon.qtd_saldo_compon,
        p_compon.qtd_fila_compon,
        p_compon.qtd_dispon_compon

   LET p_compon.qtd_dispon_compon = 
       p_compon.qtd_dispon_compon / p_compon.qtd_necessaria
      
   INSERT INTO compon_temp
      VALUES(p_compon.*)
       
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("GRAVAÇÃO","compon_mark")
      RETURN FALSE
   END IF

   DECLARE cq_altern CURSOR FOR 
   SELECT a.cod_item_altern,
          b.ies_tip_item,
          b.cod_local_estoq
     FROM item_altern a, Item b
    WHERE a.cod_empresa     = p_cod_empresa
      AND a.cod_item_pai    = p_compon.cod_item_pai
      AND a.cod_item_compon = p_compon.cod_item_compon
      AND b.cod_empresa     = a.cod_empresa
      AND b.cod_item        = a.cod_item_altern
   
   FOREACH cq_altern INTO
           p_compon.cod_item_compon,
           p_compon.tip_item,
           p_compon.cod_local
     
      LET p_cod_item_pai = p_compon.cod_item_compon
      LET p_cod_local    = p_compon.cod_local
      LET p_compon.ies_alternat = '*'
      CALL pol0448_calcula_saldo() RETURNING 
           p_compon.qtd_saldo_compon,
           p_compon.qtd_fila_compon,
           p_compon.qtd_dispon_compon

      LET p_compon.qtd_dispon_compon = 
          p_compon.qtd_dispon_compon / p_compon.qtd_necessaria

      INSERT INTO compon_temp
         VALUES(p_compon.*)
       
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("GRAVAÇÃO","compon_mark")
         RETURN FALSE
      END IF
         
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0448_exibe_dados()
#----------------------------#

   LET p_cod_item_pai = p_tela.cod_item
   LET p_cod_local    = p_cod_local_pai

   SELECT SUM (qtd_planej) 
     INTO p_tela.qtd_planej
     FROM ordens  
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_pai
      AND ies_situa   = '1'
            
   IF p_tela.qtd_planej IS NULL THEN
      LET p_tela.qtd_planej = 0
   END IF
         
   SELECT SUM (qtd_planej) 
     INTO p_tela.qtd_abert
     FROM ordens  
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_pai
      AND ies_situa  IN ('2','3')
            
   IF p_tela.qtd_abert IS NULL THEN
      LET p_tela.qtd_abert = 0
   END IF
         
   SELECT SUM (qtd_planej-qtd_boas) 
     INTO p_tela.qtd_liberac
     FROM ordens  
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_pai
      AND ies_situa   = '4'
            
   IF p_tela.qtd_liberac IS NULL THEN
      LET p_tela.qtd_liberac = 0
   END IF

   SELECT SUM (ped_itens.qtd_pecas_solic - 
               ped_itens.qtd_pecas_atend - 
               ped_itens.qtd_pecas_cancel) 
     INTO p_tela.qtd_penden
     FROM pedidos, ped_itens
    WHERE pedidos.cod_empresa   = p_cod_empresa
      AND pedidos.ies_sit_pedido NOT IN ('S','B','P','9')  
      AND ped_itens.cod_empresa = pedidos.cod_empresa 
      AND ped_itens.num_pedido  = pedidos.num_pedido 
      AND ped_itens.cod_item    = p_cod_item_pai

   IF p_tela.qtd_penden IS NULL THEN
      LET p_tela.qtd_penden = 0
   END IF

   CALL pol0448_calcula_saldo() RETURNING
        p_tela.qtd_saldo,
        p_tela.qtd_fila,
        p_tela.qtd_dispon

   LET p_tela.qtd_reservada = p_qtd_reser        
    
   DECLARE cq_lista CURSOR FOR
   SELECT a.pre_unit
     FROM desc_preco_item a ,
          desc_preco_mest b
    WHERE a.cod_empresa    = p_cod_empresa
      AND a.cod_item       = p_cod_item_pai
      AND b.cod_empresa    = a.cod_empresa 
      AND b.num_list_preco = a.num_list_preco 
      AND b.dat_ini_vig    <= TODAY 
      AND b.dat_fim_vig    >= TODAY 
    ORDER BY a.num_list_preco DESC

   FOREACH cq_lista INTO p_tela.preco_item
      EXIT FOREACH 
   END FOREACH
   
   IF p_tela.preco_item IS NULL THEN
      LET p_tela.preco_item = 0
   END IF

   LET p_dat_med = TODAY - 91

   SELECT SUM (qtd_movto) 
     INTO p_tela.med_mensal
     FROM estoque_trans a,
          estoque_operac b
    WHERE a.cod_empresa        = p_cod_empresa
      AND a.cod_item           = p_cod_item_pai
      AND a.dat_movto         >= p_dat_med
      AND a.cod_local_est_orig = p_cod_local 
      AND b.cod_empresa        = a.cod_empresa
      AND b.cod_operacao       = a.cod_operacao 
      AND b.ies_origem         <> 'A' 
      AND b.ies_tipo           = 'S'

   IF p_tela.med_mensal IS NULL THEN
      LET p_tela.med_mensal = 0
   ELSE
      LET p_tela.med_mensal = p_tela.med_mensal / 3
   END IF
         
   DISPLAY BY NAME p_tela.*
   
END FUNCTION

#------------------------------#
FUNCTION pol0448_calcula_saldo()
#------------------------------#

   DEFINE p_qtd_saldo, p_qtd_fila, p_qtd_dispon DECIMAL(9,3)

   SELECT SUM (qtd_saldo) 
     INTO p_qtd_saldo
     FROM estoque_lote  
    WHERE cod_empresa = p_cod_empresa 
      AND cod_item    = p_cod_item_pai
      AND cod_local   = p_cod_local
      AND ies_situa_qtd = ('L') 

   IF p_qtd_saldo IS NULL THEN
      LET p_qtd_saldo = 0
   END IF

   SELECT SUM(qtd_reservada)
     INTO p_qtd_fila
     FROM man_prior_consumo
    WHERE empresa = p_cod_empresa
      AND item    = p_cod_item_pai
      AND prior_atendida IN ('N','P')

   IF p_qtd_fila IS NULL THEN
      LET p_qtd_fila = 0
   END IF

   SELECT SUM(qtd_reservada - qtd_atendida)
     INTO p_qtd_reser
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_pai
      AND cod_local   = p_cod_local
  
   IF p_qtd_reser IS NULL OR p_qtd_reser < 0 THEN
      LET p_qtd_reser = 0 
   END IF

   LET p_qtd_dispon = p_qtd_saldo - p_qtd_fila - p_qtd_reser

   RETURN p_qtd_saldo, p_qtd_fila, p_qtd_dispon
   
END FUNCTION

#--------------------------------#
FUNCTION pol0448_exibe_estrutura()
#--------------------------------#
   
   DEFINE p_item LIKE item.cod_item

   INITIALIZE p_control, pr_compon TO NULL
   LET p_index = 1
   
   DECLARE cq_compon CURSOR FOR
    SELECT *
      FROM compon_temp
     WHERE cod_nivel    = p_cod_nivel
       AND cod_item_pai = p_cod_item_pai
     
   FOREACH cq_compon INTO
           p_item,
           pr_compon[p_index].cod_item_compon,
           p_cod_nivel_temp,
           pr_compon[p_index].Qtd_necessaria,
           pr_compon[p_index].ies_alternat,
           pr_compon[p_index].tip_item,
           pr_compon[p_index].cod_local,
           pr_compon[p_index].qtd_saldo_compon,
           pr_compon[p_index].qtd_fila_compon,
           pr_compon[p_index].qtd_dispon_compon

      LET p_index = p_index + 1

      IF p_index > 400 THEN
         ERROR 'Limite de lihas ultrapassado !!!'
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_compon 
         WITHOUT DEFAULTS FROM sr_compon.*

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()

      BEFORE FIELD cod_item_compon
         LET p_item = pr_compon[p_index].cod_item_compon
         INITIALIZE p_den_item_compon TO NULL
         SELECT den_item
           INTO p_den_item_compon
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_item
         DISPLAY p_den_item_compon TO den_item_compon
      
      AFTER FIELD cod_item_compon
         IF pr_compon[p_index+1].cod_item_compon IS NULL THEN
            IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR
               FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN 
               NEXT FIELD cod_item_compon
            END IF
         END IF 
         
         IF p_item <> pr_compon[p_index].cod_item_compon OR 
            pr_compon[p_index].cod_item_compon IS NULL THEN
            LET pr_compon[p_index].cod_item_compon = p_item
            NEXT FIELD cod_item_compon
         END IF 

      ON KEY (control-f)
         IF pr_compon[p_index].qtd_fila_compon > 0 THEN
            CALL pol0448_exibe_fila()
         ELSE
            ERROR 'Não há reserva para esse item !!!'
         END IF
         
      ON KEY (control-s)
         LET p_count = 0
         SELECT COUNT(cod_item_compon)
           INTO p_count
           FROM estrutura
          WHERE cod_empresa  = p_cod_empresa
            AND cod_item_pai = pr_compon[p_index].cod_item_compon
         IF p_count > 0 THEN 
            LET p_control = 'S'
            EXIT INPUT
         ELSE
            ERROR 'Item Sem Estrutura !!!'
         END IF

      ON KEY (control-p)
         DECLARE cq_pedidos CURSOR FOR
         SELECT a.num_pedido, 
                c.nom_cliente, 
                a.prz_entrega, 
               (a.qtd_pecas_solic - a.qtd_pecas_atend - a.qtd_pecas_cancel) 
            FROM ped_itens a,
                 pedidos b, 
                 clientes c
           WHERE a.cod_empresa = p_cod_empresa
             AND a.cod_item    = p_tela.cod_item
             AND a.num_pedido  = b.num_pedido 
             AND b.cod_empresa = a.cod_empresa 
             AND b.cod_cliente = c.cod_cliente 
             AND b.ies_sit_pedido <> '9' 
             AND (a.qtd_pecas_solic - a.qtd_pecas_atend - a.qtd_pecas_cancel) > 0 
           ORDER BY a.num_pedido
         LET ped_index = 1
         FOREACH cq_pedidos INTO 
                 pr_pedidos[ped_index].*
            LET ped_index = ped_index + 1
         END FOREACH
         IF ped_index > 1 THEN
            CALL pol0448_exibe_pedidos()
         ELSE
            ERROR 'Não há pedidos para o item em questão !!!'
         END IF         

      ON KEY (control-o)
         SELECT ies_tip_item
           INTO p_ies_tip_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = pr_compon[p_index].cod_item_compon
         IF p_ies_tip_item = 'C' OR p_ies_tip_item = 'B' THEN
            DECLARE cq_ordem_sup CURSOR FOR
            SELECT num_oc, 
                   qtd_solic,
                  (qtd_solic - qtd_recebida),
                   dat_emis,
                   dat_entrega_prev,
                   ies_situa_oc
              FROM ordem_sup
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = pr_compon[p_index].cod_item_compon
               AND ies_situa_oc IN ('R','A')
               AND ies_versao_atual = 'S'
             ORDER BY num_oc
            LET ped_index = 1
            FOREACH cq_ordem_sup INTO 
                    pr_ordens[ped_index].*
               LET ped_index = ped_index + 1
            END FOREACH
            IF ped_index > 1 THEN
               CALL pol0448_exibe_ordens()
            ELSE
               ERROR 'Não há ordens para o item selecionado !!!'
            END IF                  
         ELSE
            DECLARE cq_ordens CURSOR FOR
            SELECT num_ordem, 
                   qtd_planej,
                  (qtd_planej - qtd_boas - qtd_refug),
                   dat_abert,
                   dat_entrega,
                   ies_situa
              FROM ordens
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = pr_compon[p_index].cod_item_compon
               AND ies_situa IN ('3','4')
             ORDER BY num_ordem
            LET ped_index = 1
            FOREACH cq_ordens INTO 
                    pr_ordens[ped_index].*
               LET ped_index = ped_index + 1
            END FOREACH
            IF ped_index > 1 THEN
               CALL pol0448_exibe_ordens()
            ELSE
               ERROR 'Não há ordens para o item selecionado !!!'
            END IF         
         END IF   
   END INPUT
   
   CASE p_control
      WHEN 'S'
         LET p_cod_nivel  = p_cod_nivel + 1
         SELECT UNIQUE cod_item_pai
           INTO p_cod_item_pai
           FROM compon_temp
          WHERE cod_item_pai = pr_compon[p_index].cod_item_compon
         IF STATUS = 0 THEN
            LET p_grava_temp = FALSE
         ELSE
            LET p_cod_item_pai  = pr_compon[p_index].cod_item_compon
            LET p_grava_temp = TRUE
         END IF
         LET p_tela.cod_item = p_cod_item_pai
         CALL pol0448_le_estrutura()
      OTHERWISE
         LET p_cod_nivel = p_cod_nivel - 1
         IF p_cod_nivel > 0 THEN
            SELECT UNIQUE cod_item_pai
              INTO p_cod_item_pai
              FROM compon_temp
             WHERE cod_nivel = p_cod_nivel
               AND cod_item_compon = p_tela.cod_item
            IF STATUS = 0 THEN
               LET p_tela.cod_item = p_cod_item_pai
               LET p_grava_temp = FALSE
               CALL pol0448_le_estrutura()
            END IF
         END IF
   END CASE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0448_exibe_pedidos()
#-------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04481") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04481 AT 7,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
 
   DISPLAY p_tela.cod_item TO cod_item
   DISPLAY p_tela.den_item TO den_item
   
   CALL SET_COUNT(ped_index-1)
   DISPLAY ARRAY pr_pedidos TO sr_pedidos.*

   CLEAR FORM
   CLOSE WINDOW w_pol04481

END FUNCTION

#-----------------------------#
FUNCTION pol0448_exibe_ordens()
#-----------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04482") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04482 AT 7,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
 
   IF p_ies_tip_item = 'C' OR p_ies_tip_item = 'B' THEN
      DISPLAY 'ORDENS DE COMPRA' AT 1,25
   ELSE
      DISPLAY 'ORDENS DE PRODUÇÃO' AT 1,25
   END IF
   DISPLAY pr_compon[p_index].cod_item_compon TO cod_item
   DISPLAY p_den_item_compon TO den_item
   
   CALL SET_COUNT(ped_index-1)
   DISPLAY ARRAY pr_ordens TO sr_ordens.*

   CLEAR FORM
   CLOSE WINDOW w_pol04482

END FUNCTION

#----------------------------#
FUNCTION pol0448_exibe_fila()
#----------------------------#

   DEFINE l_ind SMALLINT

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04483") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol044823 AT 7,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DECLARE cq_prior CURSOR FOR
    SELECT prioridade,
           docum, 
           tip_docum, 
           info_compl_2, 
           prior_atendida, 
           qtd_reservada
      FROM man_prior_consumo
     WHERE empresa = p_cod_empresa
       AND item    = pr_compon[p_index].cod_item_compon
       AND prior_atendida IN ('N','P')
     ORDER BY prioridade
   
   LET l_ind = 1
   
   FOREACH cq_prior INTO p_prior[l_ind].prioridade,
                         p_prior[l_ind].docum,
                         p_prior[l_ind].tip_docum,
                         p_prior[l_ind].info_compl_2,
                         p_prior[l_ind].prior_atendida,
                         p_prior[l_ind].qtd_reservada
                     
      IF p_prior[l_ind].tip_docum = 'PV' OR p_prior[l_ind].tip_docum = 'PP' THEN
         SELECT cod_tip_carteira
           INTO p_prior[l_ind].cod_repres
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_prior[l_ind].docum
      END IF

      LET l_ind = l_ind + 1

   END FOREACH     

   CALL SET_COUNT(l_ind - 1)

   DISPLAY ARRAY p_prior TO s_prior.*

   CLOSE WINDOW w_pol044823
   
END FUNCTION


#-----------------------#
FUNCTION pol0368_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0448
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

   END CASE
   
END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#

