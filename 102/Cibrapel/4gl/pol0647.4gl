#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO TRIM X LOGIX                                 #
# PROGRAMA: pol0647                                                 #
# OBJETIVO: APONTAMENTOS CRITICADOS - TRIMBOX                       #
# AUTOR...: IVO HB                                                  #
# DATA....: 03/10/2007                                              #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_empresa        LIKE empresa.cod_empresa,
          p_num_op             LIKE ordens.num_ordem
          
   DEFINE p_retorno            SMALLINT,
          p_salto              SMALLINT,
          p_imprimiu           SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                INTEGER,
          s_ind                SMALLINT,
          p_dat_consumo        DATE,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(02),
          p_8lpp               CHAR(02),
          p_caminho            CHAR(080),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),
          p_opcao              CHAR(01),
          p_num_seq_apont      INTEGER,
          p_msg                CHAR(150),
          p_dat_proces         DATE,
          p_numsequencia       INTEGER,
          p_num_pedido         CHAR(15),
          p_den_item           CHAR(18),
          p_ies_bobina         SMALLINT,
          p_cod_familia        CHAR(15)

END GLOBALS

DEFINE p_tela                  RECORD
       dat_ini                 DATE,
       dat_fim                 DATE,
       num_pedido              INTEGER,
       num_ordem               INTEGER,
       cod_item                CHAR(15)
END RECORD
        
DEFINE pr_inconsist            ARRAY[2000] OF RECORD
       numpedido               CHAR(10),         
       numordem                INTEGER,
       coditem                 CHAR(15),
       codmaquina              CHAR(04),
       fim                     DATE,
       tipmovto                CHAR(01),
       qtdprod                 DECIMAL(9,3),
       consumorefugo           DECIMAL(8,3),
       pesoteorico             DECIMAL(6,3)
END RECORD

DEFINE pr_mensagem             ARRAY[2000] OF RECORD
       mensagem                CHAR(150),
       numsequencia            INTEGER
END RECORD

DEFINE pr_papel                ARRAY[30] OF RECORD
       papelprevisto           CHAR(15),
       denpapelprevisto        CHAR(18),
       papelutilizado          CHAR(15),
       denpapelutilizado       CHAR(18)
END RECORD

DEFINE pr_consumo              ARRAY[30] OF RECORD
       qtdconsumida            DECIMAL(10,3)
END RECORD

DEFINE p_papel                 RECORD
       numordem                INTEGER,
       numpedido               INTEGER,
       codcliente              CHAR(15),
       nomecliente             CHAR(36)
END RECORD

DEFINE p_trim                  RECORD
	codempresa                   CHAR(2) ,          
	numsequencia                 INTEGER ,          
	numpedido                    CHAR(10),          
	coditem                      CHAR(15) ,         
	numordem                     INTEGER ,          
	codmaquina                   CHAR(10) ,         
	inicio                       CHAR(20) ,         
	fim                          CHAR(20) ,         
	qtdprod                      DECIMAL(10, 3) ,   
	tipmovto                     CHAR(1) ,          
	pesoteorico                  DECIMAL(10, 3) ,   
	consumorefugo                DECIMAL(10, 3) ,   
	iesdevolucao                 CHAR(1) ,          
	datageracao                  CHAR(20)           
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol0647-10.02.05  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0647.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
   
   #LET p_status = 0; LET p_cod_empresa = '01'; LET p_user = 'admlog'
   
   IF p_status = 0  THEN
      CALL pol0647_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0647_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0647") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06471 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Inconsistência" "Apontamentos inconsistentes"
         CALL pol0647_inconsistencia() RETURNING p_status
         IF NOT p_status THEN
            CALL pol0647_limpa_tela()
            ERROR 'Operação cancelada.'
         ELSE
            ERROR 'Operação efetuada com sucesso.'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0647

END FUNCTION

#---------------------------#
FUNCTION pol0647_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-------------------------------#
FUNCTION pol0647_inconsistencia()
#-------------------------------#

   INITIALIZE p_tela TO NULL
   CALL pol0647_limpa_tela()
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS 
      
      AFTER INPUT

         IF INT_FLAG THEN
            CALL pol0647_limpa_tela()
            RETURN FALSE
         END IF
         
         IF p_tela.dat_ini IS NOT NULL AND                
            p_tela.dat_fim   IS NOT NULL THEN
            IF p_tela.dat_fim < p_tela.dat_ini THEN
               LET p_msg = "A data inicial não pode\n ser maior que a data final."
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD dat_ini
            END IF
         END IF
         
   END INPUT

   CALL pol647_le_inconsist() RETURNING p_status
  
   RETURN  p_status
   
END FUNCTION

#----------------------------#
FUNCTION pol647_le_inconsist()
#----------------------------#
   
   DEFINE p_query           CHAR(3000),
          p_dat_hor_proces  CHAR(19),
          p_men_erro        CHAR(150)
          
   SELECT dat_hor_proces,
          mensagem
     INTO p_dat_hor_proces,
          p_men_erro
     FROM apont_msg_885
    WHERE cod_empresa = p_cod_empresa
   
   DISPLAY p_dat_hor_proces TO dat_hor_proces
   DISPLAY p_men_erro TO men_erro   
   
   LET p_index = 1
   LET p_count = 0

   INITIALIZE pr_inconsist TO NULL

   LET p_query = 
       "SELECT a.num_lote, b.numordem, a.coditem, a.codmaquina, DATE(a.fim), ",
       " a.tipmovto, a.qtdprod, a.consumorefugo, a.pesoteorico, ",
       " b.mensagem, a.numsequencia ",
       " FROM apont_trim_885 a, apont_erro_885 b ",
       " WHERE a.codempresa  = '",p_cod_empresa,"' ",
       "   AND a.codempresa = b.codempresa ",
       "   AND a.numsequencia = b.numsequencia ",
       "   AND a.statusregistro = '2' "

   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND DATE(a.inicio) >= '",p_tela.dat_ini,"' "
   END IF
   
   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND DATE(a.fim) <= '",p_tela.dat_fim,"' "
   END IF

   IF p_tela.num_pedido IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.numpedido = ", p_tela.num_pedido
   END IF

   IF p_tela.num_ordem IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND (b.numordem = ", p_tela.num_ordem, 
         " OR a.numordem = ", p_tela.num_ordem, ")"
   END IF

   IF p_tela.cod_item IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.coditem = '",p_tela.cod_item,"' "
   END IF

   LET p_query = p_query CLIPPED, " ORDER BY a.numpedido, a.coditem, a.fim "  

   PREPARE var_query FROM p_query   
   DECLARE cq_inconsist CURSOR FOR var_query
   
   FOREACH cq_inconsist INTO 
           pr_inconsist[p_index].numpedido,    
           pr_inconsist[p_index].numordem,     
           pr_inconsist[p_index].coditem,      
           pr_inconsist[p_index].codmaquina,   
           pr_inconsist[p_index].fim,       
           pr_inconsist[p_index].tipmovto,     
           pr_inconsist[p_index].qtdprod,      
           pr_inconsist[p_index].consumorefugo,
           pr_inconsist[p_index].pesoteorico,  
           pr_mensagem[p_index].mensagem,
           pr_mensagem[p_index].numsequencia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_inconsist')
         EXIT FOREACH
      END IF      
              
      LET p_index = p_index + 1

      IF p_index > 2000 THEN
         LET p_count = p_index - 1
         ERROR 'Limite de Linhas da pesquisa Ultrapassou ', p_count
         EXIT FOREACH
      END IF

   END FOREACH
   
   IF p_index = 1 THEN
      LET p_msg = 'Não há dados para os\n parâmetros informados.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN RETURN TRUE
   END IF
  
   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY pr_inconsist TO sr_inconsist.*
      
      BEFORE ROW
      
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE() 
         LET p_msg = pr_mensagem[p_index].mensagem
         DISPLAY p_msg TO mensagem
      
       ON KEY (control-z)
          IF pr_mensagem[p_index].numsequencia IS NOT NULL THEN
             CALL pol0647_exibe_item()
          END IF

       ON KEY (control-a)
          IF p_msg[1,13] = 'ITEM PREVISTO' THEN
             IF pr_mensagem[p_index].numsequencia IS NOT NULL THEN
                LET p_numsequencia = pr_mensagem[p_index].numsequencia
                LET p_num_pedido = pr_inconsist[p_index].numpedido   
                LET p_num_op = pr_inconsist[p_index].numordem 
                CALL pol0647_edita_consumo()
             END IF
          END IF
      
   END DISPLAY
   
   RETURN TRUE   

END FUNCTION

#----------------------------#
FUNCTION pol0647_exibe_item()
#----------------------------#
   
   DEFINE p_tecla     CHAR(1)
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0647a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0647a AT 6,8 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_cod_empresa TO codempresa
   
   SELECT codempresa,   
          numsequencia, 
          num_lote,    
          coditem,      
          numordem,     
          codmaquina,   
          inicio,       
          fim,          
          qtdprod,      
          tipmovto,     
          pesoteorico,  
          consumorefugo,
          iesdevolucao, 
          datageracao  
     INTO p_trim.*
     FROM apont_trim_885
    WHERE codempresa = p_cod_empresa
      AND numsequencia = pr_mensagem[p_index].numsequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','apont_trim_885')
   ELSE
      DISPLAY BY NAME p_trim.*      
      PROMPT "Digite <ENTER> para voltar " FOR p_tecla
   END IF
   
   CLOSE WINDOW w_pol0647a
      
END FUNCTION

#-------------------------------#
FUNCTION pol0647_edita_consumo()
#-------------------------------#
      
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0647b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0647b AT 4,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_cod_empresa TO codempresa
   #lds CALL LOG_refresh_display()	
      
   CALL pol0647_le_consumo()
   
   CLOSE WINDOW w_pol0647b

END FUNCTION

#----------------------------#
FUNCTION pol0647_le_consumo()
#----------------------------#
   
   DEFINE p_qtd_linha   INTEGER,
          p_cod_cliente CHAR(15),
          p_nom_cliente CHAR(36),
          p_pedido      INTEGER

   DISPLAY p_num_op TO numordem
   DISPLAY p_num_pedido TO numpedido
   
   SELECT numpedido
     INTO p_pedido
     FROM apont_trim_885
    WHERE codempresa = p_cod_empresa
      AND numsequencia = p_numsequencia
   
   IF STATUS = 0 THEN
      SELECT cod_cliente
        INTO p_cod_cliente
        FROM pedidos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = p_pedido
   
      IF STATUS = 0 THEN
         SELECT nom_cliente
           INTO p_nom_cliente
           FROM clientes
          WHERE cod_cliente = p_cod_cliente
      END IF
   END IF
   
   DISPLAY p_cod_cliente TO codcliente
   DISPLAY p_nom_cliente TO nomecliente
      
   LET p_ind = 1
   
   DECLARE cq_consumo CURSOR FOR
    SELECT coditemorig, 
           coditem,
           qtdconsumida
      FROM consumo_trimbox_885
    WHERE codempresa = p_cod_empresa
      AND numsequencia = p_numsequencia

   FOREACH cq_consumo INTO
           pr_papel[p_ind].papelprevisto,
           pr_papel[p_ind].papelutilizado,
           pr_consumo[p_ind].qtdconsumida

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','consumo_trimbox_885')
         RETURN
      END IF
            
      LET pr_papel[p_ind].denpapelprevisto = pol0647_le_item(pr_papel[p_ind].papelprevisto)
      LET pr_papel[p_ind].denpapelutilizado = pol0647_le_item(pr_papel[p_ind].papelutilizado)
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 30 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassou'
         CALL log0030_mensagem(p_msg, 'info')
         EXIT FOREACH
      END IF
   
   END FOREACH

   LET INT_FLAG = FALSE
   
   LET p_qtd_linha = p_ind - 1
   
   IF p_qtd_linha = 0 THEN
      LET p_msg = 'Não há consumo a ser alerado'
      CALL log0030_mensagem(p_msg,'info')
      RETURN
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_papel
      WITHOUT DEFAULTS FROM sr_papel.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()
      
      AFTER FIELD papelprevisto
      
         IF pr_papel[p_ind].papelprevisto IS NULL THEN
            ERROR 'Campo com preenchimento obrigatórorio'
            NEXT FIELD papelprevisto
         END IF

         SELECT cod_item_compon
           FROM ord_compon
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem = p_num_op
            AND cod_item_compon = pr_papel[p_ind].papelprevisto
         
         IF STATUS = 100 THEN
            ERROR 'Componente não previsto da estrutura da OP'
            NEXT FIELD papelprevisto
         END IF
         
         IF NOT pol0647_le_familia(pr_papel[p_ind].papelprevisto) THEN
            EXIT FOREACH
         END IF

         IF p_den_item IS NULL THEN
            ERROR 'Item não cadastrado'
            NEXT FIELD papelprevisto
         END IF
                        
         IF p_cod_familia = '001' THEN
         ELSE
            ERROR 'Item informado não é da familia papel'
            NEXT FIELD papelprevisto
         END IF
                              
         DISPLAY p_den_item TO Sr_papel[s_ind].denpapelprevisto
                 
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_ind >= p_qtd_linha THEN
               NEXT FIELD papelprevisto
            END IF
         END IF
            
      ON KEY (control-z)
         CALL pol0647_popup()
         
   END INPUT
   
   IF INT_FLAG THEN
      RETURN
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0647_grava() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0647_grava()
#-----------------------#
   
   DELETE FROM consumo_trimbox_885
    WHERE codempresa = p_cod_empresa
      AND numsequencia = p_numsequencia
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','consumo_trimbox_885')
      RETURN FALSE
   END IF
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_papel[p_ind].papelprevisto IS NOT NULL THEN
          INSERT INTO consumo_trimbox_885(
             codempresa, 
             numsequencia,
             coditem, 
             qtdconsumida, 
             datageracao, 
             coditemorig)
           VALUES(p_cod_empresa, 
                  p_numsequencia,  
                  pr_papel[p_ind].papelutilizado,
                  pr_consumo[p_ind].qtdconsumida, 
                  getdate(), 
                  pr_papel[p_ind].papelprevisto)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','consumo_trimbox_885')
            RETURN FALSE
         END IF
      
      END IF
   
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0647_le_item(p_cod_item)
#-----------------------------------#
   
   DEFINE p_cod_item    CHAR(15)
   
   SELECT den_item_reduz
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item

   IF STATUS <> 0 THEN
      LET p_den_item = NULL
   END IF
   
   RETURN p_den_item

END FUNCTION

#----------------------#
FUNCTION pol0647_popup()
#----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
 
      WHEN INFIELD(papelprevisto)
         LET p_codigo = pol0647_le_estrutura()
         
         IF p_codigo IS NOT NULL THEN
           LET pr_papel[p_ind].papelprevisto = p_codigo
           DISPLAY p_codigo TO sr_papel[s_ind].papelprevisto
         END IF
  
   END CASE 

END FUNCTION 

#-------------------------------#
 FUNCTION pol0647_le_estrutura()
#-------------------------------#

   DEFINE pr_item    ARRAY[20] OF RECORD
          item       CHAR(15),
          descricao  CHAR(18)
   END RECORD
   
   DEFINE l_ind, m_ind  INTEGER
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0647c") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0647c AT 8,16 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET l_ind = 1
    
   DECLARE cq_item CURSOR FOR
   
    SELECT cod_item_compon
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem = p_num_op
       
   FOREACH cq_item
      INTO pr_item[l_ind].item   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ord_compon')
         EXIT FOREACH
      END IF

      IF NOT pol0647_le_familia(pr_item[l_ind].item) THEN
         EXIT FOREACH
      END IF
                        
      IF p_cod_familia = '001' THEN
      ELSE
         CONTINUE FOREACH
      END IF
      
      LET pr_item[l_ind].descricao = pol0647_le_item(pr_item[l_ind].item )
             
      LET l_ind = l_ind + 1
      
      IF l_ind > 2000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(l_ind - 1)
   
   DISPLAY ARRAY pr_item TO sr_item.*

      LET l_ind = ARR_CURR()
      LET m_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol0647c
   
   IF NOT INT_FLAG THEN
      RETURN pr_item[l_ind].item
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#----------------------------------#
FUNCTION pol0647_le_familia(p_item)#
#----------------------------------#
   
   DEFINE p_item    CHAR(15)
   
   SELECT cod_familia,
          den_item_reduz
     INTO p_cod_familia,
          p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_item 
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------FIM DO PROGRAMA---------------#



  