DATABASE logix 

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_den_empresa   LIKE empresa.den_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           comando         CHAR(80),
           p_ies_impressao CHAR(01),
           g_ies_ambiente  CHAR(01),
           p_caminho       CHAR(080),
           p_nom_arquivo   CHAR(100),
           g_tipo_sgbd     CHAR(003),
           g_msg           CHAR(150),
           p_qtd_lote      DECIMAL(10,3)
           
END GLOBALS

DEFINE m_msg               CHAR(100)

DEFINE mr_tela1            RECORD
       cod_empresa         LIKE empresa.cod_empresa,
       den_empresa         LIKE empresa.den_empresa,
       cod_cliente         LIKE clientes.cod_cliente,
       nom_cliente         LIKE clientes.nom_cliente,
       num_lote_om         LIKE ordem_montag_mest.num_lote_om,
       qtd_infor           LIKE estoque.qtd_reservada,
       qtd_dif             LIKE estoque.qtd_reservada,
       reimpressao         CHAR(01),
       num_om              INTEGER
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT

   INITIALIZE m_caminho TO NULL 
   CALL log130_procura_caminho("pol1326") RETURNING m_caminho
   LET m_caminho = m_caminho CLIPPED 
   OPEN WINDOW w_pol1326 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol1326_controle()

   CLOSE WINDOW w_pol1326
   
END MAIN

#--------------------------#
 FUNCTION pol1326_controle()
#--------------------------#

   DEFINE l_parametro CHAR(50)

   
   IF NUM_ARGS() > 0  THEN
      LET l_parametro = ARG_VAL(1)
   ELSE
      LET m_msg = 'Parâmetros obrigatórios não informados'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF
   
   DISPLAY p_cod_empresa TO cod_empresa
   #lds CALL LOG_refresh_display()
   

#---------------------------------#
 FUNCTION pol1326_le_oms(l_report)#
#---------------------------------#

   DEFINE l_report             CHAR(300),
          p_sql_stmt           VARCHAR(1000),                      
          l_qtd_embal          LIKE embal_itaesbra.qtd_padr_embal, 
          p_data               CHAR(10),                           
          p_hora               CHAR(08),                           
          p_tamanho            INTEGER,
          l_status             SMALLINT,
          l_cod                CHAR(15)
   
   LET l_cod = mr_tela1.cod_cliente CLIPPED,'%'

   LET m_page_length = ReportPageLength("pol1326om")

   START REPORT pol1326om_relat TO l_report

    LET p_data = TODAY USING "yyyy-mm-dd"
    LET p_hora = TIME
    
   LET p_count = 0

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = mr_tela1.cod_empresa
      
   IF mr_tela1.reimpressao = "S" THEN

      LET p_sql_stmt = " SELECT DISTINCT a.num_lote_om, ",                         
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND a.cod_empresa = '",mr_tela1.cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND d.cod_cliente LIKE '",l_cod,"' "
      
   END IF
   
   IF mr_tela1.reimpressao = "N" THEN
       
      LET p_sql_stmt = " SELECT DISTINCT a.num_lote_om, ",
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d, om_list e ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND d.cod_empresa = e.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND b.num_om = e.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND a.cod_empresa = '",mr_tela1.cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND e.nom_usuario = '",p_user,"' ",
                     " AND d.cod_cliente LIKE '",l_cod,"' "


   END IF

   IF mr_tela1.num_lote_om IS NOT NULL THEN
      LET p_sql_stmt = p_sql_stmt CLIPPED,
             " AND c.num_lote_om = '",mr_tela1.num_lote_om,"' "
   END IF
   
   LET p_sql_stmt = p_sql_stmt CLIPPED, " ORDER BY 9,1,4 "
      
   CALL LOG_progresspopup_set_total("PROCESS",10)
   
   PREPARE var_query1 FROM p_sql_stmt   
   DECLARE cq_relat CURSOR FOR var_query1

   LET l_qtd_vol   = 0
   LET l_qtd_embal = 0
   DELETE FROM  resumo_embal

   FOREACH cq_relat INTO p_relat.num_lote_om,
                         p_relat.num_om,
                         p_relat.num_sequencia,
                         p_relat.cod_item, 
                         p_qtd_faturada,
                         p_relat.cod_transpor,  
                         p_relat.num_placa,
                         p_relat.num_pedido,
                         p_relat.cod_cliente
                         

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_relat')
         EXIT FOREACH
      END IF
      
      SELECT cod_item_cliente
        INTO p_relat.cod_item_cliente
        FROM cliente_item
       WHERE cod_empresa = mr_tela1.cod_empresa
         AND cod_cliente_matriz = p_relat.cod_cliente
         AND cod_item = p_relat.cod_item

      IF STATUS <> 0 THEN
         LET p_relat.cod_item_cliente = ''
      END IF
      
      SELECT den_item,
             cod_unid_med
        INTO p_relat.den_item,
             p_relat.cod_unid_med
        FROM item
       WHERE cod_empresa = mr_tela1.cod_empresa 
         AND cod_item = p_relat.cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         EXIT FOREACH
      END IF

      SELECT usuario 
        INTO m_usuario
        FROM user_romaneio_304
       WHERE cod_empresa = mr_tela1.cod_empresa 
         AND num_om      = p_relat.num_om
         
      IF STATUS = 100 THEN 
         LET m_usuario = NULL 
      ELSE 
         IF STATUS <> 0 THEN 
            #CALL log003_err_sql('lendo', 'user_romaneio_304')
            #RETURN FALSE 
            LET m_usuario = p_user
         END IF 
      END IF 

      SELECT cod_tip_venda
        INTO m_cod_tip_venda
        FROM pedidos
       WHERE cod_empresa = mr_tela1.cod_empresa
         AND num_pedido = p_relat.num_pedido

      SELECT cod_embal_int, 
             qtd_embal_int, 
             cod_embal_ext, 
             qtd_embal_ext 
        INTO p_cod_embal_int,  
             p_qtd_vol_int,  
             p_cod_embal_ext,  
             p_qtd_vol_ext   
        FROM ordem_montag_embal
       WHERE cod_empresa   = mr_tela1.cod_empresa 
         AND num_om        = p_relat.num_om
         AND num_sequencia = p_relat.num_sequencia

      IF p_qtd_vol_int IS NOT NULL AND p_qtd_vol_int > 0 THEN
         SELECT qtd_padr_embal
           INTO p_qtd_embal_int
           FROM embal_itaesbra
          WHERE cod_empresa = mr_tela1.cod_empresa
            AND cod_item = p_relat.cod_item
            AND cod_cliente = p_relat.cod_cliente
            AND cod_tip_venda = m_cod_tip_venda
            AND cod_embal = p_cod_embal_int
            AND ies_tip_embal = 'N'
      
         IF STATUS = 100 THEN
         SELECT qtd_padr_embal
           INTO p_qtd_embal_int
           FROM embal_itaesbra
          WHERE cod_empresa = mr_tela1.cod_empresa
            AND cod_item = p_relat.cod_item
            AND cod_cliente = p_relat.cod_cliente
            AND cod_tip_venda = m_cod_tip_venda
            AND cod_embal = p_cod_embal_int
            AND ies_tip_embal = 'I'
         END IF
      ELSE
         LET p_qtd_vol_int = 0
         LET p_cod_embal_int = NULL
         LET p_qtd_embal_int = NULL
      END IF     

      IF p_qtd_vol_ext IS NOT NULL AND p_qtd_vol_ext > 0 THEN
         SELECT qtd_padr_embal
           INTO p_cod_embal_ext
           FROM embal_itaesbra
          WHERE cod_empresa = mr_tela1.cod_empresa
            AND cod_item = p_relat.cod_item
            AND cod_cliente = p_relat.cod_cliente
            AND cod_tip_venda = m_cod_tip_venda
            AND cod_embal = p_cod_embal_ext
            AND ies_tip_embal = 'C'
      
         IF STATUS = 100 THEN
         SELECT qtd_padr_embal
           INTO p_cod_embal_ext
           FROM embal_itaesbra
          WHERE cod_empresa = mr_tela1.cod_empresa
            AND cod_item = p_relat.cod_item
            AND cod_cliente = p_relat.cod_cliente
            AND cod_tip_venda = m_cod_tip_venda
            AND cod_embal = p_cod_embal_ext
            AND ies_tip_embal = 'C'
         END IF

      ELSE
         LET p_qtd_vol_ext = 0
         LET p_cod_embal_ext = NULL
         LET p_qtd_embal_ext = NULL
      END IF

      IF p_cod_embal_int IS NOT NULL THEN
         SELECT cod_embal_item
           INTO p_cod_embal_int_dp
           FROM de_para_embal
          WHERE cod_empresa   = mr_tela1.cod_empresa
            AND cod_embal_vdp = p_cod_embal_int
      
         IF STATUS <> 0 THEN
            LET p_cod_embal_int_dp = p_cod_embal_int
         END IF
      ELSE
         LET p_cod_embal_int_dp = NULL
      END IF
      
      IF p_cod_embal_ext IS NOT NULL THEN
         SELECT cod_embal_item
           INTO p_cod_embal_ext_dp
           FROM de_para_embal
          WHERE cod_empresa   = mr_tela1.cod_empresa
            AND cod_embal_vdp = p_cod_embal_ext
      
         IF STATUS <> 0 THEN
            LET p_cod_embal_ext_dp = p_cod_embal_ext
         END IF
      ELSE
         LET p_cod_embal_ext_dp = NULL
      END IF
      
      LET p_count = 1
      
      OUTPUT TO REPORT pol1326om_relat(
         p_relat.cod_cliente, p_relat.num_lote_om, p_relat.cod_item_cliente)
         
      IF p_cod_embal_int IS NOT NULL THEN
         INSERT INTO resumo_embal 
            VALUES (p_cod_embal_int, p_qtd_vol_int)
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql("INCLUSAO","RESUMO_EMBAL_INT")
            EXIT FOREACH 
         END IF
      END IF
      
      IF p_cod_embal_ext IS NOT NULL THEN
         INSERT INTO resumo_embal 
            VALUES (p_cod_embal_ext, p_qtd_vol_ext)
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql("INCLUSAO","RESUMO_EMBAL_EXT")
            EXIT FOREACH 
         END IF
      END IF
             
      IF mr_tela1.reimpressao = "N" THEN

         INSERT INTO w_om_list
            VALUES (mr_tela1.cod_empresa,
                    p_relat.num_om,
                    p_relat.num_pedido,
                    TODAY,
                    p_user)
         IF STATUS <> 0 THEN   
            CALL log003_err_sql("INCLUSAO","W_OM_LIST")
            EXIT FOREACH
         END IF

      END IF
      
      INITIALIZE p_relat.* TO NULL
      LET l_status = LOG_progresspopup_increment("PROCESS")
      
   END FOREACH

   FINISH REPORT pol1326om_relat 
   CALL FinishReport("pol1326om")

   IF mr_tela1.reimpressao = "N" THEN

      DECLARE cq_om_list CURSOR FOR
      SELECT * FROM w_om_list
   
      FOREACH cq_om_list INTO mr_om_list.*

         DELETE FROM om_list
         WHERE cod_empresa = p_cod_empresa
           AND num_om = mr_om_list.num_om
           AND nom_usuario = p_user
         
         IF STATUS <> 0 THEN   
            CALL log003_err_sql("EXCLUSAO","OM_LIST")
            EXIT FOREACH
         END IF

      END FOREACH

   END IF
   
END FUNCTION

#--------------------------------------------------#
REPORT pol1326om_relat(
    p_cod_cliente, p_num_lote_om,p_cod_item_cliente)
#--------------------------------------------------# 
      
   DEFINE p_cod_embal         CHAR(05),
          p_cod_embal_item    CHAR(07),
          p_den_embal         CHAR(26),
          p_qtd_vol           DECIMAL(6,0),
          p_primeira          CHAR(01),
          p_num_lote_om       LIKE ordem_montag_lote.num_lote_om,
          p_cod_cliente       CHAR(15),
          p_cod_item_cliente  CHAR(30),
          p_embalagens        CHAR(12),
          l_num_pedido_repres LIKE pedidos.num_pedido_repres,
          l_cod_cidade        LIKE cidades.cod_cidade,
          l_den_cidade        LIKE cidades.den_cidade
   
   DEFINE mr_estoque_loc_reser RECORD
          qtd_reservada        LIKE estoque_loc_reser.qtd_reservada,
          num_lote             LIKE estoque_loc_reser.num_lote
   END RECORD
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   ORDER EXTERNAL BY p_cod_cliente,
                     p_num_lote_om,
                     p_cod_item_cliente

   FORMAT

      FIRST PAGE HEADER
	  
	    #PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;


         PRINT COLUMN 001, p_den_empresa[1,20],
               COLUMN 054, "LISTAGEM O.M. NAO FATURADAS",
               COLUMN 125, "PAG.: ", PAGENO USING "######&"
         IF mr_tela1.reimpressao = "S" THEN
            PRINT COLUMN 001, "pol1326                                                       REIMPRESSAO";
         ELSE
            PRINT COLUMN 001, "pol1326                                                         IMPRESSAO";
         END IF 
         PRINT COLUMN 110, "EMISSAO: ", TODAY USING "DD/MM/YYYY", ' ', TIME 
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"
      PAGE HEADER

         PRINT
         PRINT COLUMN 001, p_den_empresa[1,20],
               COLUMN 028, "LISTAGEM O.M. NAO FATURADAS",
               COLUMN 125, "PAG. :    ", PAGENO USING "######&"
         PRINT COLUMN 001, "pol1326",
               COLUMN 110, "EMISSAO : ", TODAY USING "DD/MM/YYYY", ' ', TIME 
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"

      BEFORE GROUP OF p_cod_cliente

         SKIP TO TOP OF PAGE

         SELECT nom_cliente,
                cod_cidade
            INTO p_relat.nom_cliente,
                 l_cod_cidade
         FROM clientes
         WHERE cod_cliente = p_relat.cod_cliente    

         SELECT den_cidade
            INTO l_den_cidade
         FROM cidades
         WHERE cod_cidade = l_cod_cidade

         SELECT num_pedido_repres
            INTO l_num_pedido_repres
         FROM pedidos
         WHERE cod_empresa = mr_tela1.cod_empresa      
           AND num_pedido = p_relat.num_pedido

         IF l_num_pedido_repres IS NOT NULL THEN
            PRINT COLUMN 001, "Cliente        : ", p_relat.cod_cliente, " - ", 
                              p_relat.nom_cliente[1,23], 
                  COLUMN 063, "PLANTA : ", l_num_pedido_repres
         ELSE
            PRINT COLUMN 001, "Cliente        : ", p_relat.cod_cliente, " - ", 
                              p_relat.nom_cliente
         END IF

      BEFORE GROUP OF p_num_lote_om

         SELECT nom_cliente
            INTO p_relat.nom_transpor
         FROM clientes
         WHERE cod_cliente = p_relat.cod_transpor   

         #NEED 9 LINES

         PRINT COLUMN 001, "Lote           : ", 
                           p_relat.num_lote_om USING "#####&",
               COLUMN 036, l_den_cidade
         PRINT COLUMN 001, "Transportadora : ", 
                           p_relat.cod_transpor, " - ", p_relat.nom_transpor
         PRINT COLUMN 001, "Placa          : ", p_relat.num_placa,
               COLUMN 065, "N.F.: __________"

         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"

         PRINT COLUMN 001, "USUARIO   O.M.  PEDIDO SQ     PRODUTO      IT.CLIENTE          QDE FAT LoteOM UN CODIGO  PAD   EMB   CODIGO  PAD   EMB   QTD IT   LOTE ITEM"
         PRINT COLUMN 001, "-------- ------ ------ ---- -------------- -------------------- ------ ------ -- ------- ----- ----- ------- ----- ----- ------ ---------------"
         SKIP 1 LINE

      ON EVERY ROW

         DELETE FROM lote_tmp_304

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Deletando','lote_tmp_304')
         END IF
         
         LET p_num_seq = 0
         
         DECLARE cq_om_rel CURSOR FOR
         SELECT a.qtd_reservada,
                a.num_lote
         FROM estoque_loc_reser a, ordem_montag_grade b
         WHERE a.cod_empresa = b.cod_empresa
           AND a.cod_empresa = mr_tela1.cod_empresa
           AND a.num_reserva = b.num_reserva
           AND a.cod_item = b.cod_item
           AND a.cod_item = p_relat.cod_item
           AND b.num_om = p_relat.num_om
           AND b.num_pedido = p_relat.num_pedido
           AND b.num_sequencia = p_relat.num_sequencia

         FOREACH cq_om_rel INTO 
                 mr_estoque_loc_reser.qtd_reservada,
                 mr_estoque_loc_reser.num_lote
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','estoque_loc_reser:cq_om_rel')
            END IF
            
            LET p_num_seq = p_num_seq + 1
            
            INSERT INTO lote_tmp_304 
            VALUES (p_num_seq,
                    mr_estoque_loc_reser.qtd_reservada,
                    mr_estoque_loc_reser.num_lote)
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Inserindo','lote_tmp_304:cq_om_rel')
            END IF
                    
         END FOREACH
         
         SELECT * INTO 
                  p_num_seq,
                  mr_estoque_loc_reser.qtd_reservada,
                  mr_estoque_loc_reser.num_lote
             FROM lote_tmp_304 WHERE num_seq = 1

         DELETE FROM lote_tmp_304 WHERE num_seq = 1
         
         PRINT COLUMN 001, m_usuario,
               COLUMN 010, p_relat.num_om         USING "#####&",
               COLUMN 017, p_relat.num_pedido     USING "#####&",
               COLUMN 024, p_relat.num_sequencia  USING "###&",
               COLUMN 029, p_relat.cod_item,
               COLUMN 044, p_relat.cod_item_cliente[1,20],
               COLUMN 065, p_qtd_faturada  USING "#####&",
               COLUMN 072, p_relat.num_lote_om    USING "######",
               COLUMN 079, p_relat.cod_unid_med[1,2],
               COLUMN 084, p_cod_embal_int_dp,
               COLUMN 089, p_qtd_embal_int        USING "####&", 
               COLUMN 096, p_qtd_vol_int          USING "####&",
               COLUMN 103, p_cod_embal_ext_dp,
               COLUMN 110, p_qtd_embal_ext        USING "####&", 
               COLUMN 116, p_qtd_vol_ext          USING "####&",
               COLUMN 122, mr_estoque_loc_reser.qtd_reservada USING "#####&",
               COLUMN 129, mr_estoque_loc_reser.num_lote

         DECLARE cq_rel CURSOR FOR
         SELECT qtd_reservada,
                num_lote
         FROM lote_tmp_304

         FOREACH cq_rel INTO 
                 mr_estoque_loc_reser.qtd_reservada,
                 mr_estoque_loc_reser.num_lote
            PRINT COLUMN 122, mr_estoque_loc_reser.qtd_reservada USING "######&",
                  COLUMN 129, mr_estoque_loc_reser.num_lote
         END FOREACH
         

      AFTER GROUP OF p_num_lote_om

        PRINT 
         PRINT COLUMN 064, 'Total de volumes do lote:',
               COLUMN 095,GROUP SUM(p_qtd_vol_int) USING "#####&",
               COLUMN 115,GROUP SUM(p_qtd_vol_ext) USING "#####&"
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"

      ON LAST ROW

         PRINT 
         LET p_primeira = "S"
         
         DECLARE cq_resumo CURSOR FOR
         SELECT cod_embal,
                SUM(qtd_vol)
           FROM resumo_embal
          GROUP BY cod_embal
          ORDER BY cod_embal 

         FOREACH cq_resumo INTO p_cod_embal,
                                p_qtd_vol

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','cq_resumo')
               EXIT FOREACH
            END IF
            
            SELECT den_embal
              INTO p_den_embal
              FROM embalagem
             WHERE cod_embal = p_cod_embal
            
            SELECT cod_embal_item
              INTO p_cod_embal_item
              FROM de_para_embal
             WHERE cod_empresa   = mr_tela1.cod_empresa
               AND cod_embal_vdp = p_cod_embal
            
            IF STATUS <> 0 THEN
               LET p_cod_embal_item = NULL
            END IF

            IF p_primeira = "S" THEN
               LET p_embalagens = "Embalagens: "
               LET p_primeira = "N"
            ELSE
               LET p_embalagens = "            "
            END IF
            
            PRINT COLUMN 035, p_embalagens, 
                  COLUMN 047, p_cod_embal ,
                  COLUMN 053, p_cod_embal_item,
                  COLUMN 061, p_den_embal,
                  COLUMN 095, p_qtd_vol USING "#####&"
                                          
         END FOREACH

         SKIP 1 LINES  
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"
         SKIP 1 LINES
         PRINT COLUMN 035, "Total Geral : ",
               COLUMN 065, SUM(p_qtd_faturada)  USING "######&",
               COLUMN 095, SUM(p_qtd_vol_int)   USING "#####&",
               COLUMN 116, SUM(p_qtd_vol_ext)   USING "#####&"


END REPORT
