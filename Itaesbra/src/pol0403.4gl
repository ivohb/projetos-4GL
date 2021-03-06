#---------------------------------------------------------------------#
# SISTEMA.: VENDAS DISTRIBUICAO DE PRODUTOS                           #
# PROGRAMA: POL0403                                                   #
# OBJETIVO: PROGRAMA PARA GERAR ORDEM DE MONTAGEM - ITAESBRA          #
# AUTOR...: LOGOCENTER ABC                                            # 
# DATA....: 25/11/2005                                                #
#---------------------------------------------------------------------#

DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_den_empresa       LIKE empresa.den_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_num_seq           INTEGER,
	       l_resto             INTEGER,
         p_cod_tip_venda     LIKE pedidos.cod_tip_venda,
         p_cod_cliente       LIKE clientes.cod_cliente,
         p_cod_nat_oper      LIKE nat_operacao.cod_nat_oper,
         p_cod_nat_oper_it   LIKE nat_operacao.cod_nat_oper,
         p_num_pedido        LIKE pedidos.num_pedido,
         p_num_ped           LIKE pedidos.num_pedido,
         p_num_om            LIKE ordem_montag_mest.num_om,
         p_num_om_pri        LIKE ordem_montag_mest.num_om,
         p_cod_local_estoq   LIKE item.cod_local_estoq,
         p_local_estoq       LIKE item.cod_local_estoq,
         p_cod_tip_ant       LIKE pedidos.cod_tip_venda,
         p_cod_item          LIKE item.cod_item,
         p_ies_sit_om        LIKE ordem_montag_mest.ies_sit_om,
         p_ies_ctr_estoque   LIKE item.ies_ctr_estoque,
         p_qtd_reservada     LIKE ordem_montag_item.qtd_reservada,
         p_qtd_faturada      LIKE ordem_montag_item.qtd_reservada,
         p_num_lote_om       LIKE ordem_montag_lote.num_lote_om,
         p_qtd_terc          LIKE estoque_lote.qtd_saldo,
         p_qtd_estoque       LIKE estoque_lote.qtd_saldo,
         p_qtd_saldo         LIKE estoque_lote.qtd_saldo,
         p_saldo             LIKE estoque_lote.qtd_saldo,
         p_den_item          LIKE item.den_item,
         p_qtd_lote          LIKE estoque_lote.qtd_saldo,
         p_status            SMALLINT,
         p_qtd_linhas_nf     DECIMAL(3,0),
         p_qtd_item          INTEGER,
         p_item_asel         DECIMAL(3,0),
         p_itens_fat         CHAR(07),
         p_itens_aux         CHAR(03),
         p_msg               CHAR(300),
         p_ind               SMALLINT,
         p_index             SMALLINT,
         p_num_item_fat      DECIMAL(3,0),
         p_itens_sel         SMALLINT,
         p_ies_impressao     CHAR(001),
         p_grava             CHAR(001),
         p_comprime          CHAR(001),
         p_descomprime       CHAR(001),
         comando             CHAR(080),
         p_comando           CHAR(080),
         p_nom_arquivo       CHAR(100),
         p_versao            CHAR(018),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         g_ies_ambiente      CHAR(001),
         p_caminho           CHAR(080),
         p_num_lote          CHAR(005),
         p_r                 CHAR(001),
         p_ies_lista         SMALLINT,
         p_ies_igual         SMALLINT,
         p_count             SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         la_curr             SMALLINT,
         lc_curr             SMALLINT,
         p_i                 SMALLINT,
         p_seq               INTEGER,
         p_cod_embal_int     CHAR(05),  
         p_cod_embal_int_dp  CHAR(07),  
         p_qtd_embal_int     INTEGER,     
         p_cod_embal_ext     CHAR(05),          
         p_cod_embal_ext_dp  CHAR(07),          
         p_qtd_embal_ext     INTEGER,
         p_qtd_vol_int       INTEGER,
         p_qtd_vol_ext       INTEGER,
         l_qtd_vol           CHAR(10),
         p_resto             INTEGER,
         p_ies_lote          CHAR(01)
         
          
END GLOBALS

   DEFINE mr_tela            RECORD
         cod_empresa         LIKE empresa.cod_empresa,
         num_pedido          LIKE pedidos.num_pedido,
         usuario             CHAR(08),
         entrega_ate         LIKE ped_itens.prz_entrega,
         cod_doca            CHAR(05),
         cod_transpor        LIKE ordem_montag_lote.cod_transpor,
         nom_transpor        LIKE clientes.nom_cliente,
         num_placa           LIKE ordem_montag_lote.num_placa,
         ies_lote            LIKE ordem_montag_mest.ies_sit_om,
         num_lote            LIKE ordem_montag_lote.num_lote_om
   END RECORD

   DEFINE mr_tela1           RECORD
         cod_cliente         LIKE clientes.cod_cliente,
         nom_cliente         LIKE clientes.nom_cliente,
         num_lote_om         LIKE ordem_montag_mest.num_lote_om,
         qtd_infor           LIKE estoque.qtd_reservada,
         qtd_dif             LIKE estoque.qtd_reservada,
         reimpressao         CHAR(01)
   END RECORD

   DEFINE ma_tela        ARRAY[1000] OF RECORD
         num_sequencia          LIKE ped_itens.num_sequencia,
         prz_entrega            LIKE ped_itens.prz_entrega,
         cod_item               LIKE item.cod_item,
         qtd_saldo              LIKE ped_itens.qtd_pecas_solic,
         qtd_reservada          LIKE ped_itens.qtd_pecas_solic,
         qtd_estoque            LIKE ped_itens.qtd_pecas_solic
   END RECORD
   
   DEFINE pr_reser    ARRAY[1000] OF RECORD
          qtd_reservada LIKE estoque.qtd_reservada
   END RECORD
   DEFINE ma_tela1   ARRAY[1000] OF RECORD
      cod_item                  LIKE item.cod_item,
      ies_ctr_lote              LIKE item.ies_ctr_lote,
      ies_igual                 SMALLINT
   END RECORD

   DEFINE t_ordem    ARRAY[1000] OF RECORD
      num_lote                  LIKE ordem_montag_lote.num_lote_om,
      cod_transpor              LIKE ordem_montag_lote.cod_transpor,
      num_placa                 LIKE ordem_montag_lote.num_placa
   END RECORD

   DEFINE ma_tela2   ARRAY[1000] OF RECORD
      num_lote                  LIKE estoque_lote_ender.num_lote,
      qtd_reservada             LIKE estoque.qtd_reservada,
      qtd_saldo                 LIKE estoque_lote_ender.qtd_saldo
   END RECORD

   DEFINE p_relat RECORD
      cod_cliente               LIKE clientes.cod_cliente,  
      nom_cliente               LIKE clientes.nom_cliente,  
      num_lote_om               INTEGER,
      num_om                    LIKE ordem_montag_mest.num_om,
      num_pedido                LIKE pedidos.num_pedido,  
      num_sequencia             LIKE ordem_montag_item.num_sequencia,
      cod_item                  LIKE ordem_montag_item.cod_item,
      den_item                  LIKE item.den_item,
      qtd_reservada             LIKE ordem_montag_item.qtd_reservada,
      cod_transpor              LIKE ordem_montag_lote.cod_transpor,
      nom_transpor              LIKE transport.den_transpor,
      num_placa                 LIKE ordem_montag_lote.num_placa,
      cod_unid_med              LIKE item.cod_unid_med,
      cod_embal                 LIKE embal_itaesbra.cod_embal,
      qtd_padr_embal            LIKE embal_itaesbra.qtd_padr_embal,
      qtd_vol                   LIKE ordem_montag_item.num_om,
      cod_item_cliente          LIKE cliente_item.cod_item_cliente
   END RECORD
      
   DEFINE mr_ordem_montag_mest  RECORD LIKE ordem_montag_mest.*,
          mr_ordem_montag_item  RECORD LIKE ordem_montag_item.*,
          mr_ordem_montag_grade RECORD LIKE ordem_montag_grade.*,
          mr_estoque_loc_reser  RECORD LIKE estoque_loc_reser.*,
          mr_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          mr_estoque_lote       RECORD LIKE estoque_lote.*,
          mr_cliente_item       RECORD LIKE cliente_item.*,
          mr_pedidos            RECORD LIKE pedidos.*,
          mr_om_list            RECORD LIKE om_list.*,
          mr_cidades            RECORD LIKE cidades.*

   DEFINE m_informou            SMALLINT,
          m_ind                 SMALLINT,
          m_houve_erro          SMALLINT,
          m_cond_carteira       CHAR(70),
          m_cond_repres         CHAR(100),
          m_ies_gm              SMALLINT,
          m_cod_item            CHAR(15),
          m_num_sequencia       INTEGER,
          m_dat_atu             DATE
           
   DEFINE l_cod_doca      CHAR(05),
          l_num_sequencia INTEGER,
          l_pedido        CHAR(10),
          l_num_pedido    DECIMAL(6,0),
          sql_stmt        CHAR(1000)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT
   LET p_versao = "POL0403-10.02.53"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0403.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
        NEXT KEY control-f,
        PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      INITIALIZE mr_tela.* TO NULL
      INITIALIZE ma_tela TO NULL
      CALL pol0403_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0403_controle()
#--------------------------#
   DEFINE p_cont SMALLINT
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0403") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0403 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST-1, PROMPT LINE LAST)

   IF NOT pol0403_cria_tabela_temporaria() THEN
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa Parametros para Processamento"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
             DELETE FROM w_lote
            IF pol0403_informa_dados() THEN
               IF pol0403_informa_quantidades() THEN
                  NEXT OPTION "Processar"
               ELSE
                  ERROR "Fun��o Cancelada"
               END IF
            ELSE
               ERROR "Fun��o Cancelada"
            END IF
      COMMAND "Processar" "Processa a Cria��o da O.M."         
         HELP 002
         MESSAGE ""
            IF m_informou THEN
               IF log004_confirm(21,45) THEN
                  IF pol0403_processa() THEN
                     LET p_msg = 'PROCESSAMENTO EFETUADO COM SUCESSO\n',
                                 'N�MERO DA OM..: ', p_num_om,
                                 ' N�MERO DO LOTE: ', mr_tela.num_lote
                     CALL log0030_mensagem(p_msg,'info')
                     NEXT OPTION "Informar"
                  ELSE
                     CALL log0030_mensagem("Ocorreu erros no processamento, N�o foi Gerada OM.","stop")   
                  END IF
               END IF
            ELSE
               ERROR "Informar Dados para Processamento"
               NEXT OPTION "Informar"
            END IF
      COMMAND "Cliente X Pedido" "Abre Tela de Gera��o por Cliente/Pedido"
         HELP 0000
         MESSAGE ""
         LET INT_FLAG = 0
         CALL log120_procura_caminho("VDP1906") RETURNING p_comando
         LET p_comando = p_comando CLIPPED, " ",mr_pedidos.cod_cliente
         RUN p_comando
      COMMAND "Listar" "Lista Parametros de Entrada"
         HELP 002
         MESSAGE ""
            CALL pol0403_listar() 
            NEXT OPTION "Fim"
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0403_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0403
   
END FUNCTION

#-----------------------#
FUNCTION pol0403_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " LOGIX 10.02 \n\n",
               " Home page: www.aceex.com.br \n\n",
               " (0xx11) 4991-6667 \n\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#-------------------------------#
 FUNCTION pol0403_informa_dados()
#-------------------------------#
   
   DEFINE l_par_vdp_txt     LIKE par_vdp.par_vdp_txt
   
   CLEAR FORM
   INITIALIZE mr_tela.*,
              ma_tela,
              ma_tela1 TO NULL
   
   CALL log006_exibe_teclas("01 02",p_versao)
   CURRENT WINDOW IS w_pol0403
   LET mr_tela.cod_empresa = p_cod_empresa
#  LET mr_tela.entrega_ate = TODAY
   LET p_ies_igual = FALSE
   LET mr_tela.usuario = p_user
   
   INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

      BEFORE FIELD num_pedido
         DELETE FROM w_lote 
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("EXCLUSAO","W_LOTE")
         END IF 
      
      AFTER FIELD num_pedido  
            
         IF mr_tela.num_pedido IS NULL THEN
            ERROR "Campo de Preenchimento Obrigat�rio"
            NEXT FIELD num_pedido  
         ELSE 
            IF pol0403_verifica_pedido() = FALSE THEN
               NEXT FIELD num_pedido
            ELSE
               IF pol0403_verifica_saldo_pedido() = FALSE THEN
                  ERROR "Pedido sem saldo para Processar OM."
                  NEXT FIELD num_pedido  
               END IF
            END IF
         END IF

         SELECT qtd_linhas_nf
           INTO p_qtd_linhas_nf
           FROM par_romaneio_970
          WHERE cod_cliente = mr_pedidos.cod_cliente
          
         IF SQLCA.sqlcode = NOTFOUND THEN
            LET p_qtd_linhas_nf = 999
         END IF
         
         INITIALIZE p_itens_fat TO NULL
         
      
      AFTER FIELD usuario
         IF mr_tela.usuario IS NULL THEN 
            ERROR "Campo com prenchimento obrigat�rio !!!"
            NEXT FIELD usuario
         END IF
         
         SELECT DISTINCT cod_usuario
           FROM usuarios 
          WHERE cod_usuario = mr_tela.usuario
            
         IF STATUS = 100 THEN 
            ERROR "Usu�rio inexistente !!!"
            NEXT FIELD usuario
         ELSE 
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('Lendo', 'usuarios')
               RETURN FALSE 
            END IF 
         END IF  
      
      AFTER FIELD entrega_ate    
         IF mr_tela.entrega_ate IS NOT NULL THEN
            IF mr_tela.entrega_ate < mr_pedidos.dat_pedido THEN
               ERROR "Data de Entrega Menor que a Data do Pedido."
               NEXT FIELD entrega_ate 
            END IF
         END IF

      AFTER FIELD cod_transpor 
         IF mr_tela.cod_transpor IS NOT NULL THEN
            SELECT nom_cliente
               INTO mr_tela.nom_transpor
            FROM clientes
         	   WHERE cod_cliente = mr_tela.cod_transpor
         	     AND ies_situacao = "A"
         	     
            IF SQLCA.SQLCODE <> 0 THEN
               ERROR "Transportadora nao Cadastrada ou inativa!"
               NEXT FIELD cod_transpor
            END IF
            DISPLAY BY NAME mr_tela.nom_transpor
         END IF
         
      AFTER FIELD ies_lote       
         IF mr_tela.ies_lote IS NULL THEN
            ERROR "Campo de Preenchimento Obrigat�rio"
            NEXT FIELD ies_lote
         END IF
         
         IF mr_tela.ies_lote = 'N' THEN
            LET p_num_item_fat = 0
            LET p_itens_fat = p_num_item_fat
            LET p_itens_aux = p_qtd_linhas_nf
            LET p_itens_fat = p_itens_fat CLIPPED,'/',p_itens_aux CLIPPED
      
            DISPLAY p_itens_fat  TO itens_fat

            CALL log085_transacao("BEGIN") 

            LOCK TABLE par_vdp IN EXCLUSIVE MODE

            SELECT par_vdp_txt
              INTO l_par_vdp_txt
              FROM par_vdp
             WHERE cod_empresa = p_cod_empresa
           
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','par_vdp')
               RETURN FALSE
            END IF
            
            LET mr_tela.num_lote = l_par_vdp_txt[92,96]
            LET mr_tela.num_lote = mr_tela.num_lote + 1
            LET p_num_lote = mr_tela.num_lote USING "&&&&&"
            LET l_par_vdp_txt[92,96] = p_num_lote
            
            UPDATE par_vdp
               SET par_vdp_txt = l_par_vdp_txt
             WHERE cod_empresa = p_cod_empresa 
            
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("ALTERACAO","PAR_VDP") 
               CALL log085_transacao("ROLLBACK")
            END IF

            CALL log085_transacao("COMMIT") 
            DISPLAY mr_tela.num_lote TO num_lote
            LET p_num_item_fat = 0
            EXIT INPUT
         END IF

      AFTER FIELD num_lote
         IF mr_tela.num_lote IS NULL THEN
            ERROR "O Campo Numero do Lote nao pode ser Nulo"
            NEXT FIELD num_lote
         END IF

         SELECT cod_empresa
           FROM ordem_montag_lote
          WHERE cod_empresa = p_cod_empresa
            AND num_lote_om = mr_tela.num_lote

         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Lote Inexistente"
            NEXT FIELD num_lote
         END IF

         INITIALIZE p_num_om, p_num_om_pri TO NULL
         LET p_num_item_fat = 0
         
         DECLARE cq_om CURSOR FOR
          SELECT num_om
            FROM ordem_montag_mest
           WHERE cod_empresa = p_cod_empresa
             AND num_lote_om = mr_tela.num_lote
             
         FOREACH cq_om INTO p_num_om     

            IF p_num_om_pri IS NULL THEN
               LET p_num_om_pri = p_num_om
            END IF

            SELECT COUNT(cod_item)
              INTO p_count
              FROM ordem_montag_item
             WHERE cod_empresa = p_cod_empresa
               AND num_om      = p_num_om
               
            LET p_num_item_fat = p_num_item_fat + p_count
            
         END FOREACH

         LET p_itens_fat = p_num_item_fat
         LET p_itens_aux = p_qtd_linhas_nf
         LET p_itens_fat = p_itens_fat CLIPPED,'/',p_itens_aux CLIPPED

         DISPLAY p_itens_fat  TO itens_fat

         IF p_num_item_fat >= p_qtd_linhas_nf THEN
            ERROR "Limite de linhas por NF j� atinjido !!!"
            NEXT FIELD num_lote
         END IF                    
        
         SELECT UNIQUE num_pedido
           INTO p_num_ped
           FROM ordem_montag_item
          WHERE cod_empresa = p_cod_empresa
            AND num_om  = p_num_om_pri
             
         SELECT cod_tip_venda
           INTO p_cod_tip_ant
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_num_ped
  
##-- Alteracao Manuel 26/03/2010  
             
         IF mr_pedidos.cod_tip_venda <> p_cod_tip_ant THEN
            CALL log0030_mensagem('Pedido n�o pertence � mesma PLANTA !!!', 'excla')
            RETURN FALSE
         END IF 
             

         {IF m_ies_gm THEN
            
            DECLARE cq_omit CURSOR FOR
            SELECT num_sequencia,
                   cod_item
              FROM ordem_montag_item
             WHERE cod_empresa = p_cod_empresa
               AND num_om  = p_num_om_pri
            
            OPEN cq_omit
            
            FETCH cq_omit INTO m_num_sequencia, m_cod_item
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','ordem_montag_item:entrada do lote')
               NEXT FIELD num_lote
            END IF
            
            IF m_cod_item[1,2] = '10' THEN
               SELECT cod_doca INTO mr_tela.cod_doca
                 FROM ped_item_edi
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido  = p_num_ped
                  AND num_sequencia = m_num_sequencia
               IF STATUS <> 0 THEN
                  CALL log003_err_sql('SELECT','ped_item_edi:busca da Doca')
                  NEXT FIELD num_lote
               END IF
               DISPLAY mr_tela.cod_doca TO cod_doca                
            ELSE
               CALL log0030_mensagem('Lote n�o � da GM','info')
               NEXT FIELD num_lote
            END IF
         
         END IF}
             
      ON KEY (control-z)
         IF INFIELD(cod_transpor) THEN
            LET mr_tela.cod_transpor = vdp372_popup_cliente()
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0403
            IF mr_tela.cod_transpor IS NOT NULL THEN 
               DISPLAY BY NAME mr_tela.cod_transpor
            END IF
         END IF
         IF INFIELD(num_lote) THEN
            CALL pol0403_popup()
               RETURNING mr_tela.num_lote,
                         mr_tela.cod_transpor,
                         mr_tela.num_placa
            CURRENT WINDOW IS w_pol0403
            DISPLAY BY NAME mr_tela.num_lote,
                            mr_tela.cod_transpor,
                            mr_tela.num_placa
         END IF
         
         AFTER INPUT
            IF NOT INT_FLAG THEN
               IF mr_tela.num_pedido IS NULL THEN
                  ERROR "Campo de Preenchimento Obrigat�rio"
                  NEXT FIELD num_pedido  
               END IF
               IF mr_tela.num_lote IS NULL AND
                  mr_tela.ies_lote = "S" THEN
                  ERROR "O Campo Numero do Lote nao pode ser Nulo"
                  NEXT FIELD num_lote
               END IF
            END IF

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0403
   
   LET p_item_asel = p_qtd_linhas_nf - p_num_item_fat
   
   IF INT_FLAG <> 0 THEN
      RETURN FALSE 
   ELSE
      {IF m_ies_gm THEN
         IF NOT pol0403_le_doca() THEN
            LET m_informou = FALSE 
            RETURN FALSE
         END IF
      END IF   }
      
      DISPLAY mr_tela.cod_doca TO cod_doca 
      
      IF pol0403_busca_itens_pedido() = FALSE THEN
         LET m_informou = FALSE 
         RETURN FALSE
      ELSE
         DISPLAY mr_tela.cod_doca TO cod_doca 
         LET m_informou = TRUE
         RETURN TRUE
      END IF
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0403_popup() 
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04032") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol04032 AT 9,45 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER,FORM LINE FIRST,COMMENT LINE LAST-1,MESSAGE LINE LAST)
   INITIALIZE t_ordem TO NULL
   CLEAR FORM

   DECLARE cq_ordem CURSOR FOR
   SELECT UNIQUE a.num_lote_om, 
                 c.cod_transpor, 
                 c.num_placa
   FROM ordem_montag_mest a, ordem_montag_item b,
        ordem_montag_lote c, pedidos d
   WHERE a.cod_empresa = b.cod_empresa
     and a.num_om = b.num_om
     and a.cod_empresa = c.cod_empresa
     and a.num_lote_om = c.num_lote_om
     and b.cod_empresa = d.cod_empresa
     and b.num_pedido  = d.num_pedido
     and a.cod_empresa = p_cod_empresa
     and a.num_nff IS NULL
     and a.ies_sit_om <> "F"
     and d.cod_cliente = mr_pedidos.cod_cliente

   LET p_i = 1
   FOREACH cq_ordem INTO t_ordem[p_i].num_lote,
                         t_ordem[p_i].cod_transpor,
                         t_ordem[p_i].num_placa
      LET p_i = p_i + 1

   END FOREACH 

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   MESSAGE "Esc - Seleciona Lote Desejado"
      ATTRIBUTE(REVERSE)

   INPUT ARRAY t_ordem WITHOUT DEFAULTS FROM s_ordem.*

      BEFORE FIELD num_lote   
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD num_lote
   #  IF t_ordem[pa_curr].num_lote IS NULL THEN
   #     NEXT FIELD num_lote
   #  END IF
      IF (FGL_LASTKEY() = FGL_KEYVAL("RETURN") OR
         FGL_LASTKEY() = FGL_KEYVAL("DOWN")) AND
         t_ordem[pa_curr+1].num_lote IS NULL AND
         t_ordem[pa_curr+1].cod_transpor IS NULL AND
         t_ordem[pa_curr+1].num_placa IS NULL THEN
         ERROR "Nao Existem mais Registros nesta Direcao"
         NEXT FIELD num_lote
      END IF

   END INPUT 

   IF INT_FLAG THEN
      INITIALIZE t_ordem TO NULL
      CLOSE WINDOW w_pol04032
      CURRENT WINDOW IS w_pol0403
   ELSE
      RETURN t_ordem[pa_curr].num_lote,
             t_ordem[pa_curr].cod_transpor,
             t_ordem[pa_curr].num_placa
      CLOSE WINDOW w_pol04032
      CURRENT WINDOW IS w_pol0403
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0403_verifica_pedido() 
#---------------------------------#

   DEFINE l_nom_cliente LIKE clientes.nom_cliente

   SELECT *
     INTO mr_pedidos.*
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = mr_tela.num_pedido

   LET p_cod_tip_venda = mr_pedidos.cod_tip_venda
   
   IF sqlca.sqlcode <> 0 THEN
      ERROR 'Pedido n�o Cadastrado.'
      RETURN FALSE
   END IF

   IF mr_pedidos.cod_tip_venda <> p_cod_tip_ant THEN
      ERROR 'Pedido n�p pertence � mesma PLANTA !!!'
      RETURN FALSE
   END IF 
  
   IF mr_pedidos.ies_sit_pedido = '9' THEN
      ERROR 'Pedido Cancelado.'
      RETURN FALSE
   END IF
      
   IF mr_pedidos.ies_sit_pedido = 'B' THEN
      ERROR 'Pedido Bloqueado.'
      RETURN FALSE
   END IF

   IF mr_pedidos.ies_sit_pedido = 'S' THEN
      ERROR 'Pedido Suspenso.'
      RETURN FALSE
   END IF
 
   IF mr_pedidos.ies_sit_pedido <> 'F' AND 
      mr_pedidos.ies_sit_pedido <> 'A' THEN
      IF pol0403_verifica_credito() = FALSE THEN
         RETURN FALSE
      END IF
   END IF
      
   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_pedidos.cod_cliente

   LET mr_tela.cod_transpor = mr_pedidos.cod_transpor

   IF mr_tela.cod_transpor IS NOT NULL AND mr_tela.cod_transpor <> ' ' THEN
      SELECT nom_cliente
        INTO mr_tela.nom_transpor
        FROM clientes
       WHERE cod_cliente = mr_tela.cod_transpor
   END IF
   
   DISPLAY BY NAME mr_tela.nom_transpor
   DISPLAY mr_tela.cod_transpor TO cod_transpor
   
   DISPLAY mr_pedidos.cod_cliente TO cod_cliente
   DISPLAY l_nom_cliente TO nom_cliente
 
   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol0403_verifica_credito()
#----------------------------------#
   DEFINE lr_par_vdp           RECORD LIKE par_vdp.*,
          lr_cli_credito       RECORD LIKE cli_credito.*,
          l_valor_cli          DECIMAL(15,2),
          l_parametro          CHAR(1)
          
   SELECT *
     INTO lr_cli_credito.*
     FROM cli_credito
    WHERE cod_cliente = mr_pedidos.cod_cliente
      
   IF sqlca.sqlcode <> 0 THEN
      ERROR 'Cliente sem dados de cr�dito.'
      RETURN FALSE
   END IF

   SELECT *
     INTO lr_par_vdp.*
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF lr_par_vdp.par_vdp_txt[367] = 'S' THEN
      IF lr_cli_credito.qtd_dias_atr_dupl > lr_par_vdp.qtd_dias_atr_dupl THEN
         ERROR 'Cliente com duplicatas em atraso excedido.'
         RETURN FALSE
      END IF
      IF lr_cli_credito.qtd_dias_atr_med > lr_par_vdp.qtd_dias_atr_med THEN
         ERROR 'Cliente com atraso m�dio excedido.'
         RETURN FALSE
      END IF
   END IF

   SELECT par_ies
     INTO l_parametro
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'ies_limite_credito'
    
   IF l_parametro = 'S' THEN         
      LET l_valor_cli = lr_cli_credito.val_ped_carteira + 
                        lr_cli_credito.val_dup_aberto
      IF l_valor_cli > lr_cli_credito.val_limite_cred THEN
         ERROR 'Limite de cr�dito excedido.'
         RETURN TRUE #FALSE
      END IF
   END IF

   IF lr_cli_credito.dat_val_lmt_cr IS NOT NULL THEN
      IF lr_cli_credito.dat_val_lmt_cr < TODAY THEN
         ERROR 'Data cr�dito expirada.'
         RETURN FALSE
      END IF
   END IF    
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0403_verifica_saldo_pedido() 
#---------------------------------------#
   DEFINE l_cod_item             LIKE item.cod_item,
          p_qtd_terc             LIKE estoque.qtd_liberada

   DECLARE cq_saldo CURSOR FOR 
    SELECT a.cod_item
      FROM ped_itens a
     WHERE a.cod_empresa = p_cod_empresa 
       AND a.num_pedido  = mr_tela.num_pedido
       AND (a.qtd_pecas_solic - (a.qtd_pecas_atend  +
                                 a.qtd_pecas_cancel +
                                 a.qtd_pecas_reserv +
                                 a.qtd_pecas_romaneio)) > 0 
      OPEN cq_saldo
     FETCH cq_saldo INTO l_cod_item
  
   IF sqlca.sqlcode = 0 THEN
      IF l_cod_item[1,2] = '10' THEN
         LET m_ies_gm = TRUE
      ELSE
         LET m_ies_gm = FALSE
      END IF
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF  

END FUNCTION

#-------------------------#
FUNCTION pol0403_le_doca()#
#-------------------------#
   
   DEFINE l_cod_doca      CHAR(05),
          l_num_sequencia INTEGER,
          l_pedido        CHAR(10),
          l_num_pedido    DECIMAL(6,0),
          sql_stmt        CHAR(1000)
   
   LET l_pedido = mr_tela.num_pedido
   LET l_num_pedido = mr_tela.num_pedido
   
   CREATE TEMP TABLE doca_tmp (
    cod_doca    CHAR(05)
   );
   
   CREATE INDEX ix_doca_tmp on doca_tmp(cod_doca);

   LET sql_stmt = 
      " SELECT num_sequencia ",
      "   FROM ped_itens ",
      "  WHERE cod_empresa = '",p_cod_empresa,"'",
      "    AND num_pedido  = ",l_num_pedido,
      "    AND (qtd_pecas_solic - (qtd_pecas_atend  + ",
      "                            qtd_pecas_cancel + ",
      "                            qtd_pecas_reserv + ",
      "                            qtd_pecas_romaneio)) > 0 "
      
   IF mr_tela.entrega_ate IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, "  AND prz_entrega <= '",mr_tela.entrega_ate,"'"
   END IF
   
   LET p_itens_sel = 0
   
   PREPARE var_doca FROM sql_stmt
   DECLARE cq_doca CURSOR FOR var_doca
 
   FOREACH cq_doca INTO l_num_sequencia
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ped_itens:cq_doca')
         RETURN FALSE
      END IF
         
      SELECT cod_doca 
        INTO l_cod_doca
        FROM ped_item_edi
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = l_num_pedido
         AND num_sequencia = l_num_sequencia         

      IF STATUS <> 0 THEN
         #CALL log003_err_sql('SELECT','ped_item_edi:cq_doca')
         #RETURN FALSE
         CONTINUE FOREACH
      END IF
      
      IF l_cod_doca IS NULL THEN
         LET p_msg = 'Pedido:    ', mr_tela.num_pedido,'\n',
                     'Sequencia: ', l_num_sequencia,'\n',
                     'Doca est� nula.'
         CALL log0030_mensagem(p_msg,'info')
         RETURN FALSE
      END IF
      
      IF mr_tela.cod_doca IS NOT NULL THEN
         IF l_cod_doca <> mr_tela.cod_doca THEN
            CONTINUE FOREACH
         END IF
      END IF
      
      SELECT 1 FROM doca_tmp WHERE cod_doca = l_cod_doca
      
      IF STATUS = 100 THEN
         INSERT INTO doca_tmp VALUES(l_cod_doca)
         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','doca:cq_doca')
            RETURN FALSE
         END IF
      END IF
   
   END FOREACH
   
   SELECT COUNT(cod_doca)    
     INTO p_count
     FROM doca_tmp

   IF p_count = 0 THEN
      IF mr_tela.cod_doca IS NOT NULL THEN
         LET p_msg = 'N�o a sequencia/item com saldo para\n o pedido/doca ',
             l_pedido CLIPPED, '/',mr_tela.cod_doca
      ELSE
         LET p_msg = 'N�o a sequencia/item com saldo para o pedido indormado.'
      END IF  
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   IF mr_tela.cod_doca IS NULL THEN
      IF p_count > 1 THEN      
         IF NOT pol0403_sel_doca() THEN
           RETURN FALSE
         END IF
      ELSE
         SELECT cod_doca INTO mr_tela.cod_doca FROM doca_tmp
      END IF      
   END IF
      
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0403_sel_doca()#
#--------------------------#
   
   DEFINE s_ind, l_ind    INTEGER
   DEFINE lr_doca  ARRAY[1000] OF RECORD
          cod_doca  CHAR(05)
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04035") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10691 AT 05,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET l_ind = 1
    
   DECLARE cq_sel CURSOR FOR
   
    SELECT cod_doca
      FROM doca_tmp
     ORDER BY cod_doca

   FOREACH cq_sel
      INTO lr_doca[l_ind].cod_doca   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor: cq_sel')
         RETURN FALSE
      END IF
             
      LET l_ind = l_ind + 1
      
      IF l_ind > 1000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(l_ind - 1)
   
   DISPLAY ARRAY lr_doca TO sr_doca.*

      LET l_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol10691
   
   IF NOT INT_FLAG THEN
      LET mr_tela.cod_doca = lr_doca[l_ind].cod_doca
   ELSE
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
      

#------------------------------------#
 FUNCTION pol0403_busca_itens_pedido()
#------------------------------------#
   
   DEFINE l_ind               SMALLINT,
          l_prioridade        LIKE man_prior_consumo.prioridade, 
          l_qtd_reservada     LIKE man_prior_consumo.qtd_reservada,
          sql_stmt            CHAR(1000),
          l_cod_doca          CHAR(05),
          l_pedido            CHAR(07)

   LET l_ind = 1
   LET p_cod_item = NULL
   LET p_qtd_estoque = 0
   INITIALIZE pr_reser TO NULL
   LET l_pedido = mr_tela.num_pedido

   LET sql_stmt = 
      " SELECT a.num_sequencia, a.prz_entrega, b.cod_item, ",
      " (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_reserv - qtd_pecas_romaneio), ",
      " a.cod_item, b.ies_ctr_lote FROM ped_itens a, item b ",
      " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
      " AND a.num_pedido  = '",l_pedido,"' ",
      " AND a.cod_empresa = b.cod_empresa ",
      " AND a.cod_item = b.cod_item ",
      " AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_reserv - qtd_pecas_romaneio) > 0 "
      
   IF mr_tela.entrega_ate IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, "  AND a.prz_entrega <= '",mr_tela.entrega_ate,"'"
   END IF

   LET sql_stmt = sql_stmt CLIPPED, " ORDER BY a.prz_entrega, a.cod_item "
   
   LET p_itens_sel = 0
   
   PREPARE var_query FROM sql_stmt
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','var_query')
      RETURN FALSE
   END IF    
   
   DECLARE cq_itens CURSOR FOR var_query
 
   FOREACH cq_itens INTO ma_tela[l_ind].num_sequencia,
                         ma_tela[l_ind].prz_entrega,
                         ma_tela[l_ind].cod_item,
                         ma_tela[l_ind].qtd_saldo,
                         ma_tela1[l_ind].cod_item,
                         ma_tela1[l_ind].ies_ctr_lote
 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ped_itens:cq_itens')
         RETURN FALSE
      END IF

      {IF m_ies_gm THEN 
         SELECT cod_doca 
           INTO l_cod_doca
           FROM ped_item_edi
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = mr_tela.num_pedido
            AND num_sequencia = ma_tela[l_ind].num_sequencia         

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ped_item_edi:cq_itens')
            RETURN FALSE
         END IF
         
         IF l_cod_doca <> mr_tela.cod_doca THEN
            CONTINUE FOREACH
         END IF
      
      END IF}
      
 
      SELECT ies_ctr_estoque,
             cod_local_estoq
        INTO p_ies_ctr_estoque,
             p_local_estoq
        FROM item 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_tela1[l_ind].cod_item
 
      IF p_ies_ctr_estoque = 'N' THEN
         LET ma_tela[l_ind].qtd_estoque = 9999999
      ELSE     
         IF p_cod_item IS NULL OR p_cod_item <> ma_tela1[l_ind].cod_item THEN
            SELECT SUM(qtd_reservada)
              INTO p_qtd_reservada
              FROM estoque_loc_reser
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = ma_tela1[l_ind].cod_item
               AND cod_local   = p_local_estoq

            IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
               LET p_qtd_reservada = 0
            END IF
         ELSE
            LET p_qtd_reservada = 0
         END IF
         
         LET pr_reser[l_ind].qtd_reservada = p_qtd_reservada
         
         SELECT SUM(qtd_saldo)
           INTO p_saldo
           FROM estoque_lote
          WHERE cod_empresa   = p_cod_empresa
            AND cod_item      = ma_tela1[l_ind].cod_item
            AND cod_local     = p_local_estoq
            AND ies_situa_qtd IN ('L','E')
         
         IF p_saldo IS NULL THEN 
            LET p_saldo = 0 
         ELSE
            IF p_qtd_reservada < p_saldo THEN
               LET p_saldo = p_saldo - p_qtd_reservada
            ELSE
               LET p_saldo = 0
            END IF
         END IF
         
         LET ma_tela[l_ind].qtd_estoque = p_saldo
           
      END IF      
 
      IF ma_tela[l_ind].qtd_estoque IS NULL THEN
         LET ma_tela[l_ind].qtd_estoque = 0 
      END IF

      IF p_cod_item = ma_tela1[l_ind].cod_item AND p_cod_item IS NOT NULL THEN
         LET ma_tela1[l_ind].ies_igual = TRUE
         IF l_ind > 1 THEN
            LET p_qtd_estoque = ma_tela[l_ind-1].qtd_estoque
         END IF
         LET p_qtd_estoque = p_qtd_estoque - ma_tela[l_ind-1].qtd_reservada
         IF p_qtd_estoque < 0 THEN
            LET p_qtd_estoque = 0 
         END IF
         LET ma_tela[l_ind].qtd_estoque = p_qtd_estoque
      END IF

      LET p_cod_item = ma_tela1[l_ind].cod_item

      IF ma_tela[l_ind].qtd_estoque < 0 THEN
         LET ma_tela[l_ind].qtd_estoque = 0 
      END IF

      IF p_item_asel > 0 THEN
         IF ma_tela[l_ind].qtd_estoque < ma_tela[l_ind].qtd_saldo THEN
            LET ma_tela[l_ind].qtd_reservada = ma_tela[l_ind].qtd_estoque
         ELSE
            LET ma_tela[l_ind].qtd_reservada = ma_tela[l_ind].qtd_saldo
         END IF   
      ELSE
         LET ma_tela[l_ind].qtd_reservada = 0
      END IF
 
      IF ma_tela[l_ind].qtd_reservada > 0 THEN
         LET p_itens_sel = p_itens_sel + 1
      END IF

      LET p_item_asel = p_item_asel - 1
            
      LET l_ind = l_ind + 1

   END FOREACH    
   
   DISPLAY p_itens_sel TO itens_sel
   
   IF l_ind = 1 THEN
      MESSAGE 'N�o h� itens com saldo para faturar !!!' ATTRIBUTE(REVERSE)
      RETURN FALSE
   ELSE 
      LET m_ind = l_ind - 1 
      LET p_qtd_item = m_ind
      RETURN TRUE
   END IF

END FUNCTION

#-------------------------------------#
 FUNCTION pol0403_informa_quantidades() 
#-------------------------------------#
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0403

   LET p_item_asel = p_qtd_linhas_nf - p_num_item_fat
   
   CALL SET_COUNT(m_ind)

   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_om.*

      BEFORE FIELD qtd_reservada 
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()
         
         SELECT den_item
           INTO p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = ma_tela[pa_curr].cod_item
         
         IF SQLCA.SQLCODE = 0 THEN
            MESSAGE p_den_item ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE ""
         END IF
        
        IF pr_reser[pa_curr].qtd_reservada < 0 THEN
           ERROR 'Quantidade reservada do estoque est� negativa!!!'
           LET ma_tela[pa_curr].qtd_reservada = 0
        ELSE
           ERROR ''
        END IF
        
      AFTER FIELD qtd_reservada 

         LET mr_ordem_montag_item.cod_item = ma_tela[pa_curr].cod_item

         IF ma_tela[pa_curr].qtd_reservada > 0 THEN
            IF pr_reser[pa_curr].qtd_reservada < 0 THEN
               CALL log0030_mensagem(
                 "Quantidade reservada na tabela estoque est� negativa","exclamation")    
               NEXT FIELD qtd_reservada       
            END IF
         END IF

         IF pol0403_item_estoque() THEN
            IF ma_tela[pa_curr].qtd_reservada > ma_tela[pa_curr].qtd_estoque THEN
               ERROR "Quantidade reservada maior que saldo do item"
                  ATTRIBUTE (REVERSE)
               NEXT FIELD qtd_reservada
            END IF
         END IF
         
         IF ma_tela[pa_curr].num_sequencia IS NOT NULL THEN
            IF NOT pol0403_verifica_qtd_embal() THEN
               NEXT FIELD qtd_reservada
            END IF
         END IF
                  
         IF ma_tela[pa_curr].qtd_reservada = 0 AND 
            ma_tela[pa_curr].cod_item = ma_tela[pa_curr+1].cod_item THEN
           
            LET ma_tela[pa_curr+1].qtd_estoque = ma_tela[pa_curr].qtd_estoque
            
            IF SC_CURR < 8 then
               DISPLAY ma_tela[pa_curr+1].qtd_estoque TO 
                       s_om[sc_curr+1].qtd_estoque
            ELSE
               DISPLAY ma_tela[pa_curr+1].qtd_estoque TO 
                       s_om[sc_curr].qtd_estoque
            END IF
            
         END IF
         
         IF ma_tela1[pa_curr].ies_ctr_lote = "S" THEN

            LET p_cod_item = ma_tela[pa_curr].cod_item
            LET p_seq = ma_tela[pa_curr].num_sequencia
            
            IF ma_tela[pa_curr].qtd_reservada = 0 THEN
               DELETE FROM w_lote
                WHERE cod_empresa = p_cod_empresa
                  AND cod_item = p_cod_item
                  AND num_seq  = p_seq
            ELSE
               SELECT SUM(qtd_reservada)
                 INTO p_qtd_lote
                 FROM w_lote
                WHERE cod_empresa = p_cod_empresa
                  AND cod_item = p_cod_item
                  AND num_seq  = p_seq
               
               IF STATUS <> 0 THEN
                  CALL log003_err_sql('Somando','w_lote')
               END IF
               
               IF p_qtd_lote IS NULL THEN
                  LET p_qtd_lote = 0
               END IF
               
               IF p_qtd_lote <> ma_tela[pa_curr].qtd_reservada THEN
                  CALL pol0403_lotes_fifo()
               END IF
            END IF
            
            FOR p_i = pa_curr TO p_qtd_item 
               IF p_i < p_qtd_item THEN
                  IF ma_tela[p_i].num_sequencia IS NOT NULL AND
                     ma_tela[p_i].cod_item IS NOT NULL AND
                     ma_tela[p_i].qtd_saldo IS NOT NULL AND
                     ma_tela[p_i].qtd_reservada IS NOT NULL AND
                     ma_tela[p_i].qtd_estoque IS NOT NULL AND
                     ma_tela[p_i].cod_item = ma_tela[p_i+1].cod_item THEN
                     LET ma_tela[p_i+1].qtd_estoque= ma_tela[p_i].qtd_estoque - 
                                                     ma_tela[p_i].qtd_reservada
                     DISPLAY ma_tela[p_i+1].qtd_estoque TO s_om[p_i+1].qtd_estoque
                  END IF
               END IF
            END FOR
         END IF 

         LET p_itens_sel = 0
         
         FOR p_ind = 1 TO ARR_COUNT()
             IF ma_tela[p_ind].qtd_reservada > 0 THEN
                LET p_itens_sel = p_itens_sel + 1
             END IF
        END FOR
        
        DISPLAY p_itens_sel TO itens_sel
        
        IF p_itens_sel > p_item_asel THEN
           ERROR 'Limite de linhas da NF ultrapassado !!!'
           NEXT FIELD qtd_reservada
        END IF
        
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_qtd_linhas_nf > 0 THEN
               LET p_count = 0
               
               FOR p_index = 1 TO ARR_COUNT()
                   IF ma_tela[p_index].qtd_reservada > 0 THEN
                      LET p_count = p_count + 1
                   END IF
               END FOR
               
               LET p_num_item_fat = p_num_item_fat + p_count
               IF p_num_item_fat > p_qtd_linhas_nf THEN
                  ERROR "Limite de linhas por NF > o permitido !!!"
                  LET p_num_item_fat = p_num_item_fat - p_count
                  NEXT FIELD qtd_reservada
               END IF
            END IF
         END IF
      
      ON KEY (control-p)
         CALL pol0403_mostra_item()

   END INPUT        

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0403

   IF INT_FLAG THEN
   #  LET INT_FLAG = FALSE
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol0403_verifica_qtd_embal()
#------------------------------------#

   DEFINE l_qtd_padr_embal LIKE item_embalagem.qtd_padr_embal,
          l_qtd_embal      LIKE item_embalagem.qtd_padr_embal

   LET l_qtd_padr_embal = NULL
   
   SELECT qtd_padr_embal
     INTO l_qtd_padr_embal
     FROM embal_itaesbra 
    WHERE cod_empresa   = p_cod_empresa
      AND cod_cliente   = mr_pedidos.cod_cliente
      AND cod_item      = ma_tela1[pa_curr].cod_item
      AND cod_tip_venda = p_cod_tip_venda
      AND ies_tip_embal = 'N'

   IF STATUS = 100 THEN
      SELECT qtd_padr_embal
        INTO l_qtd_padr_embal
        FROM embal_itaesbra 
       WHERE cod_empresa   = p_cod_empresa
         AND cod_cliente   = mr_pedidos.cod_cliente
         AND cod_item      = ma_tela1[pa_curr].cod_item
         AND cod_tip_venda = p_cod_tip_venda
         AND ies_tip_embal = 'I'
   END IF

   IF STATUS = 100 THEN
      LET p_msg = 'Embalagem padr�o n�o cadastrada no pol0364'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','embal_itaesbra:cq_verif')
         RETURN FALSE
      END IF
   END IF
   
   LET l_qtd_embal = ma_tela[pa_curr].qtd_reservada MOD l_qtd_padr_embal
   
   IF (l_qtd_embal > 0 ) AND (mr_pedidos.ies_embal_padrao <> '3' )  THEN
      LET p_msg = "Pedido padrao embal. qtd. pecas nao padrao embal."
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION

#---------------------------------------#
FUNCTION pol0403_cria_tabela_temporaria()
#---------------------------------------#

   CALL log085_transacao("BEGIN") 

   DROP TABLE w_lote;

   CREATE TEMP TABLE w_lote
     (
      cod_empresa    CHAR(2),  
      cod_item       CHAR(015),
      num_seq        SMALLINT,
      cod_local      CHAR(010),
      num_lote       CHAR(015),
      qtd_reservada  DECIMAL(15,3),
      qtd_saldo      DECIMAL(15,3)
     );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-W_LOTE")
      RETURN FALSE
   END IF

   
    DROP TABLE lote_tmp_304;
   CREATE TEMP TABLE lote_tmp_304
     (
      num_seq        SMALLINT,  
      qtd_reservada  DEC(7,0), 
      num_lote       CHAR(15)
     ) WITH NO LOG;
     
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-lote_tmp_304")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
 
#--------------------------#
 FUNCTION pol0403_processa()
#--------------------------#

   DEFINE l_ind               SMALLINT,
          l_num_om            LIKE ordem_montag_mest.num_om,
          l_num_lote          LIKE ordem_montag_mest.num_lote_om,
          l_peso_unit         LIKE item.pes_unit,
          l_qtd_padr_embal    LIKE item_embalagem.qtd_padr_embal,
          l_qtd_embal_ext     LIKE item_embalagem.qtd_padr_embal,
          l_qtd_reservada     LIKE man_prior_consumo.qtd_reservada, 
          l_qtd_reserv        LIKE man_prior_consumo.qtd_reservada,
          l_situacao_prior    LIKE man_prior_consumo.prior_atendida,
          l_cod_local_estoq   LIKE item.cod_local_estoq,
          l_num_reserva       INTEGER,
          l_cod_tip_carteira  LIKE pedidos.cod_tip_carteira,
          l_cod_transpor      LIKE pedidos.cod_transpor,
          l_cont              SMALLINT,
          l_qtd_volume        LIKE ordem_montag_mest.qtd_volume_om,
          l_cod_embal_matriz  LIKE embalagem.cod_embal_matriz,
          l_cod_embal_int     LIKE item_embalagem.cod_embal,
          l_cod_embal_ext     LIKE item_embalagem.cod_embal,
          l_qtd_vol           CHAR(10),
          p_qtd_volume        LIKE ordem_montag_item.qtd_volume_item,
		      l_qtd_emb_int       LIKE ordem_montag_embal.qtd_embal_int,
		      l_qtd_emb_ext       LIKE ordem_montag_embal.qtd_embal_ext,
          p_qtd_volume_int    INTEGER,
          p_qtd_volume_ext    INTEGER,
          p_item              CHAR(15),
          p_ies_ctr_estoque   CHAR(01)

   MESSAGE "Processando a Cria��o da OM..." ATTRIBUTE(REVERSE)
   LET l_num_lote = 0
   LET l_cont     = 0
   LET m_dat_atu = TODAY
   
   SELECT num_ult_om
     INTO l_num_om
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF l_num_om IS NULL THEN
      LET l_num_om = 1
   ELSE
      LET l_num_om = l_num_om + 1
   END IF

   UPDATE par_vdp
      SET num_ult_om = l_num_om
    WHERE cod_empresa = p_cod_empresa 

   IF STATUS <> 0 THEN
      CALL log003_err_sql("ALTERACAO","PAR_VDP") 
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")

   LET l_qtd_volume = 0
   
   FOR l_ind = 1 TO p_qtd_item
      IF ma_tela[l_ind].qtd_reservada IS NULL OR
         ma_tela[l_ind].qtd_reservada <= 0 THEN
         CONTINUE FOR
      END IF
      
      SELECT qtd_padr_embal,
             cod_embal
        INTO l_qtd_padr_embal,
             l_cod_embal_int
        FROM embal_itaesbra
       WHERE cod_empresa   = p_cod_empresa
         AND cod_cliente   = mr_pedidos.cod_cliente
         AND cod_item      = ma_tela1[l_ind].cod_item
         AND cod_tip_venda = p_cod_tip_venda
         AND ies_tip_embal = 'N'

      IF STATUS = 100 THEN
         SELECT qtd_padr_embal,
                cod_embal
           INTO l_qtd_padr_embal,
                l_cod_embal_int
           FROM embal_itaesbra
          WHERE cod_empresa   = p_cod_empresa
            AND cod_cliente   = mr_pedidos.cod_cliente
            AND cod_item      = ma_tela1[l_ind].cod_item
            AND cod_tip_venda = p_cod_tip_venda
            AND ies_tip_embal = 'I'
      END IF

      IF STATUS = 100 THEN
         LET l_qtd_padr_embal = 0
         LET l_cod_embal_int  = 0
      ELSE
         IF STATUS = 0 THEN
            LET l_cod_embal_matriz = NULL
            SELECT cod_embal_matriz
              INTO l_cod_embal_matriz
              FROM embalagem
             WHERE cod_embal = l_cod_embal_int
            IF l_cod_embal_matriz IS NOT NULL THEN 
               LET l_cod_embal_int = l_cod_embal_matriz
            END IF
         ELSE
            CALL log003_err_sql('Lendo','embal_itaesbra:2')
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
      END IF
      
      SELECT qtd_padr_embal,
             cod_embal
        INTO l_qtd_embal_ext,
             l_cod_embal_ext
        FROM embal_itaesbra
       WHERE cod_empresa   = p_cod_empresa
         AND cod_cliente   = mr_pedidos.cod_cliente
         AND cod_item      = ma_tela1[l_ind].cod_item
         AND cod_tip_venda = p_cod_tip_venda
         AND ies_tip_embal = 'E'

      IF STATUS = 100 THEN
         SELECT qtd_padr_embal,
                cod_embal
           INTO l_qtd_embal_ext,
                l_cod_embal_ext
           FROM embal_itaesbra
          WHERE cod_empresa   = p_cod_empresa
            AND cod_cliente   = mr_pedidos.cod_cliente
            AND cod_item      = ma_tela1[l_ind].cod_item
            AND cod_tip_venda = p_cod_tip_venda
            AND ies_tip_embal = 'C'
      END IF

      IF STATUS = 100 THEN
         LET l_qtd_embal_ext = 0
         LET l_cod_embal_ext  = 0
      ELSE
         IF STATUS = 0 THEN
            LET l_cod_embal_matriz = NULL
            SELECT cod_embal_matriz
              INTO l_cod_embal_matriz
              FROM embalagem
             WHERE cod_embal = l_cod_embal_ext
            IF l_cod_embal_matriz IS NOT NULL THEN 
               LET l_cod_embal_ext = l_cod_embal_matriz
            END IF
         ELSE
            CALL log003_err_sql('Lendo','embal_itaesbra:2')
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
      END IF

      IF l_qtd_padr_embal > 0 THEN
         LET p_qtd_volume_int = ma_tela[l_ind].qtd_reservada / l_qtd_padr_embal
         LET l_resto = ma_tela[l_ind].qtd_reservada MOD l_qtd_padr_embal
         IF l_resto > 0 THEN
            LET p_qtd_volume_int = p_qtd_volume_int + 1
         END IF
         LET l_qtd_emb_int =  l_qtd_padr_embal
      ELSE
         LET p_qtd_volume_int = 0
		     LET l_qtd_emb_int = 0 
      END IF

      IF l_qtd_embal_ext > 0 THEN
         LET p_qtd_volume_ext = ma_tela[l_ind].qtd_reservada / l_qtd_embal_ext
         LET l_resto = ma_tela[l_ind].qtd_reservada MOD l_qtd_embal_ext
         IF l_resto > 0 THEN
            LET p_qtd_volume_ext = p_qtd_volume_ext + 1
         END IF
         LET l_qtd_emb_ext  = l_qtd_embal_ext
	    ELSE	 
	       LET p_qtd_volume_ext = 0
		     LET l_qtd_emb_ext = 0 
      END IF

      LET p_qtd_volume = p_qtd_volume_int + p_qtd_volume_ext
      
      LET mr_ordem_montag_item.qtd_volume_item = p_qtd_volume

      SELECT pes_unit
         INTO l_peso_unit 
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = ma_tela1[l_ind].cod_item
      
      LET mr_ordem_montag_item.cod_empresa     = p_cod_empresa
      LET mr_ordem_montag_item.num_om          = l_num_om
      LET mr_ordem_montag_item.num_pedido      = mr_tela.num_pedido
      LET mr_ordem_montag_item.num_sequencia   = ma_tela[l_ind].num_sequencia 
      LET mr_ordem_montag_item.cod_item        = ma_tela1[l_ind].cod_item
      LET mr_ordem_montag_item.qtd_reservada   = ma_tela[l_ind].qtd_reservada
      LET mr_ordem_montag_item.ies_bonificacao = 'N'
      LET mr_ordem_montag_item.pes_total_item  = ma_tela[l_ind].qtd_reservada *
                                                 l_peso_unit

      INSERT INTO ordem_montag_item VALUES (mr_ordem_montag_item.*)
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_ITEM") 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF
      
      LET l_qtd_volume = l_qtd_volume + mr_ordem_montag_item.qtd_volume_item
      
      INSERT INTO ordem_montag_embal VALUES(p_cod_empresa,
                                               mr_ordem_montag_item.num_om,
			 		                                     mr_ordem_montag_item.num_sequencia,	           
                                               mr_ordem_montag_item.cod_item,
                                               l_cod_embal_int,
                                               p_qtd_volume_int,
                                               l_cod_embal_ext,
                                               p_qtd_volume_ext,
                                               'T',
                                               1,
                                               1,
                                               mr_ordem_montag_item.qtd_reservada)
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_EMBAL") 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF

      { RASTREABILIDADE - LOTES POR FIFO }
      	
      LET p_ies_lote = ma_tela1[l_ind].ies_ctr_lote
      
      IF ma_tela1[l_ind].ies_ctr_lote = "S" THEN
         
         DECLARE cq_lote CURSOR FOR
         SELECT cod_item,
                cod_local,
                num_lote,
                SUM(qtd_reservada)
         FROM w_lote
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = ma_tela1[l_ind].cod_item 
           AND num_seq = ma_tela[l_ind].num_sequencia
         GROUP BY cod_item, cod_local, num_lote

         FOREACH cq_lote INTO mr_estoque_lote.cod_item,
                              mr_estoque_lote.cod_local,
                              mr_estoque_lote.num_lote,
                              mr_estoque_loc_reser.qtd_reservada
            IF STATUS <> 0 THEN
               CALL log003_err_sql('FOREACH','cq_lote')
               RETURN FALSE
            END IF

            LET mr_estoque_loc_reser.num_reserva = 0

            IF mr_estoque_lote.num_lote IS NULL OR mr_estoque_lote.num_lote = ' ' THEN
               CALL log0030_mensagem("Numero de lote nulo na tab temp w_lote", "exclamation")
               RETURN FALSE
            END IF
            
            INSERT INTO estoque_loc_reser 
               VALUES(p_cod_empresa,
                      mr_estoque_loc_reser.num_reserva,
                      mr_estoque_lote.cod_item,
                      mr_estoque_lote.cod_local,
                      mr_estoque_loc_reser.qtd_reservada,
                      mr_estoque_lote.num_lote,
                      "V",
                      NULL,
                      NULL,
                      "N",
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      m_dat_atu,
                      NULL,
                      NULL,
                      0,
                      NULL)

            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","ESTOQUE_LOC_RESER")
               CALL log085_transacao("ROLLBACK")
            #  ROLLBACK WORK
               RETURN FALSE
            END IF

            LET mr_ordem_montag_grade.num_reserva = SQLCA.SQLERRD[2]

            INSERT INTO ordem_montag_grade
               VALUES(p_cod_empresa,
                      l_num_om,
                      mr_tela.num_pedido,
                      ma_tela[l_ind].num_sequencia,
                      mr_estoque_lote.cod_item,
                      mr_estoque_loc_reser.qtd_reservada,
                      mr_ordem_montag_grade.num_reserva,
                      ' ',                                                        
                      ' ',                                                        
                      ' ',                                                        
                      ' ',                                                        
                      ' ', 
                      NULL)

            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_GRADE")
               CALL log085_transacao("ROLLBACK")
            #  ROLLBACK WORK
               RETURN FALSE
            END IF

            INSERT INTO ldi_om_grade_compl
               VALUES(p_cod_empresa,
                      l_num_om,
                      mr_tela.num_pedido,
                      ma_tela[l_ind].num_sequencia,
                      mr_ordem_montag_grade.num_reserva,
                      "N")
           
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","LDI_OM_GRADE_COMPL")
               CALL log085_transacao("ROLLBACK")
               RETURN FALSE
            END IF
            
            IF NOT pol403_ins_est_loc_reser_end() THEN
               RETURN FALSE
            END IF
            
         END FOREACH
      ELSE
         LET p_qtd_reservada = ma_tela[l_ind].qtd_reservada
         LET p_qtd_saldo = 0
         LET p_item = ma_tela1[l_ind].cod_item

         SELECT cod_local_estoq,
                ies_ctr_estoque
            INTO p_cod_local_estoq,
                 p_ies_ctr_estoque
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = ma_tela1[l_ind].cod_item

         DECLARE cq_est_lote CURSOR FOR
          SELECT * 
            FROM estoque_lote
           WHERE cod_empresa = p_cod_empresa
             AND cod_item = ma_tela1[l_ind].cod_item
             AND cod_local = p_cod_local_estoq
             AND ies_situa_qtd IN ("L","E")
           ORDER BY num_lote

         FOREACH cq_est_lote INTO mr_estoque_lote.* 

            IF mr_estoque_lote.num_lote IS NULL OR mr_estoque_lote.num_lote = ' ' THEN
               SELECT SUM(qtd_reservada)
                 INTO mr_estoque_loc_reser.qtd_reservada
                 FROM estoque_loc_reser
                WHERE cod_empresa = p_cod_empresa
                  AND cod_item = mr_estoque_lote.cod_item
                  AND cod_local = mr_estoque_lote.cod_local
                  AND (num_lote IS NULL OR num_lote = ' ')
            ELSE
               SELECT SUM(qtd_reservada)
                 INTO mr_estoque_loc_reser.qtd_reservada
                 FROM estoque_loc_reser
                WHERE cod_empresa = p_cod_empresa
                  AND cod_item = mr_estoque_lote.cod_item
                  AND cod_local = mr_estoque_lote.cod_local
                  AND num_lote = mr_estoque_lote.num_lote
            END IF
            
            IF mr_estoque_loc_reser.qtd_reservada IS NULL THEN
               LET mr_estoque_loc_reser.qtd_reservada = 0
            END IF
             
            LET p_qtd_saldo = mr_estoque_lote.qtd_saldo - 
                              mr_estoque_loc_reser.qtd_reservada
            IF p_qtd_saldo <= 0 THEN
               CONTINUE FOREACH
            END IF
               
            IF p_qtd_saldo < p_qtd_reservada THEN
               LET p_qtd_reservada = p_qtd_reservada - p_qtd_saldo
            ELSE
               LET p_qtd_saldo = p_qtd_reservada
               LET p_qtd_reservada = 0
            END IF
   
            LET mr_estoque_loc_reser.num_reserva = 0
   
            INSERT INTO estoque_loc_reser 
                  VALUES(p_cod_empresa,
                         mr_estoque_loc_reser.num_reserva,
                         mr_estoque_lote.cod_item,
                         mr_estoque_lote.cod_local,
                         p_qtd_saldo,
                         mr_estoque_lote.num_lote,
                         "V",
                         NULL,
                         NULL,
                         "N",
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         m_dat_atu,
                         NULL,
                         NULL,
                         0,
                         NULL)

            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","ESTOQUE_LOC_RESER")
               CALL log085_transacao("ROLLBACK")
               #  ROLLBACK WORK
               RETURN FALSE
            END IF

            LET mr_ordem_montag_grade.num_reserva = SQLCA.SQLERRD[2]
   
            INSERT INTO ordem_montag_grade
                  VALUES(p_cod_empresa,
                         l_num_om,
                         mr_tela.num_pedido,
                         ma_tela[l_ind].num_sequencia,
                         mr_estoque_lote.cod_item,
                         p_qtd_saldo,
                         mr_ordem_montag_grade.num_reserva,
                         ' ',
                         ' ',
                         ' ',
                         ' ',
                         ' ',
                         NULL)

            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_GRADE")
               CALL log085_transacao("ROLLBACK")
               #  ROLLBACK WORK
              RETURN FALSE
            END IF

            INSERT INTO ldi_om_grade_compl
               VALUES(p_cod_empresa,
                      l_num_om,
                      mr_tela.num_pedido,
                      ma_tela[l_ind].num_sequencia,
                      mr_ordem_montag_grade.num_reserva,
                      "N")
           
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","LDI_OM_GRADE_COMPL")
               CALL log085_transacao("ROLLBACK")
               RETURN FALSE
            END IF

            IF NOT pol403_ins_est_loc_reser_end() THEN
               RETURN FALSE
            END IF

            IF p_qtd_reservada <= 0 THEN
               EXIT FOREACH
            END IF

         END FOREACH
         
         IF p_ies_ctr_estoque = 'S' THEN
            IF p_qtd_reservada > 0 THEN
               CALL log085_transacao("ROLLBACK")
               LET p_msg = 'Item ',p_item CLIPPED, '. N�o h� saldo suficiente\n',
                           'para faturar a quantidade desejada.'
               CALL log0030_mensagem(p_msg,'excla')
               RETURN FALSE
            END IF
         END IF

      END IF

      UPDATE ped_itens 
         SET qtd_pecas_romaneio = qtd_pecas_romaneio + 
                                  mr_ordem_montag_item.qtd_reservada
      WHERE cod_empresa   = p_cod_empresa
        AND num_pedido    = mr_ordem_montag_item.num_pedido
        AND num_sequencia = mr_ordem_montag_item.num_sequencia
        AND cod_item      = mr_ordem_montag_item.cod_item

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("ALTERACAO","PED_ITENS") 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF

      IF pol0403_item_estoque() THEN

         UPDATE estoque
            SET qtd_reservada = qtd_reservada + 
                                mr_ordem_montag_item.qtd_reservada
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = mr_ordem_montag_item.cod_item

         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("ALTERACAO","ESTOQUE") 
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
            RETURN FALSE
         END IF
      END IF
            
#  era aqui

      LET l_cont = l_cont + 1       

   END FOR

   IF l_cont > 0 THEN
      SELECT cod_transpor, cod_tip_carteira
         INTO l_cod_transpor, l_cod_tip_carteira
      FROM pedidos
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = mr_ordem_montag_item.num_pedido
      
      IF l_cod_transpor IS NULL THEN
         LET l_cod_transpor = '0'
      END IF
      
      LET mr_ordem_montag_mest.cod_empresa   = p_cod_empresa
      LET mr_ordem_montag_mest.num_om        = l_num_om
      LET mr_ordem_montag_mest.num_lote_om   = mr_tela.num_lote
      LET mr_ordem_montag_mest.ies_sit_om    = 'N'
      LET mr_ordem_montag_mest.cod_transpor  = NULL 
      LET mr_ordem_montag_mest.qtd_volume_om = l_qtd_volume
      LET mr_ordem_montag_mest.dat_emis      = m_dat_atu 

      INSERT INTO ordem_montag_mest VALUES (mr_ordem_montag_mest.*)

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_MEST") 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF
      
      LET p_num_om = l_num_om

      DELETE FROM user_romaneio_304
       WHERE cod_empresa = p_cod_empresa 
         AND num_om      = mr_ordem_montag_mest.num_om
      
      INSERT INTO user_romaneio_304 
           VALUES (p_cod_empresa, mr_tela.usuario, mr_ordem_montag_mest.num_om)

         IF STATUS <> 0 THEN
            CALL log003_err_sql("INCLUSAO","user_romaneio_304") 
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
            RETURN FALSE
         END IF
      
      INSERT INTO om_list VALUES (p_cod_empresa,
                                    mr_ordem_montag_mest.num_om,
                                    mr_ordem_montag_item.num_pedido,
                                    m_dat_atu,
                                    p_user)
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","OM_LIST") 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF

      SELECT * 
      FROM ordem_montag_lote
      WHERE cod_empresa = p_cod_empresa
        AND num_lote_om = mr_tela.num_lote
      IF SQLCA.SQLCODE = 100 THEN
         IF mr_tela.cod_transpor IS NULL THEN
            LET mr_tela.cod_transpor = '0' 
         END IF   
         INSERT INTO ordem_montag_lote VALUES(p_cod_empresa,
                                              mr_tela.num_lote,
                                              'N',
                                              mr_tela.cod_transpor,
                                              m_dat_atu,
                                              0,
                                              l_cod_tip_carteira,
                                              mr_tela.num_placa,
                                              0,
                                              0,
                                              0)
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_LOTE") 
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
            RETURN FALSE
         END IF
      END IF
      
   END IF

   CALL log085_transacao("COMMIT")
#  COMMIT WORK
   
   CLEAR FORM 

   IF l_cont = 0 THEN
      CALL log0030_mensagem("N�o foi Gerada OM.","stop") 
   #  MESSAGE "N�o foi Gerada O.M. !!!" ATTRIBUTE(REVERSE)
      RETURN TRUE 
   ELSE
      RETURN TRUE
   END IF    

END FUNCTION

#--------------------------------------#
FUNCTION pol403_ins_est_loc_reser_end()
#--------------------------------------#

   IF mr_estoque_lote.num_lote IS NULL OR mr_estoque_lote.num_lote = ' ' THEN
      SELECT * 
        INTO mr_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_estoque_lote.cod_item
         AND cod_local   = mr_estoque_lote.cod_local
         AND ies_situa_qtd = mr_estoque_lote.ies_situa_qtd
         AND (num_lote IS NULL OR num_lote = ' ')
   ELSE
      SELECT * 
        INTO mr_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_estoque_lote.cod_item
         AND cod_local   = mr_estoque_lote.cod_local
         AND num_lote    = mr_estoque_lote.num_lote
   END IF
   
   IF STATUS = 0 THEN
      IF pol0403_est_loc_reser_end() THEN
         RETURN TRUE
      END IF
   END IF      

   INSERT INTO est_loc_reser_end                                         
      VALUES(p_cod_empresa,                                              
             mr_ordem_montag_grade.num_reserva,                          
             ' ',                                                        
             0,                                                          
             ' ',                                                        
             ' ',                                                        
             ' ',                                                        
             ' ',                                                        
             ' ',                                                        
             '1900-01-01 00:00:00',                                      
             0,                                                          
             0,                                                          
             '1900-01-01 00:00:00',                                      
             ' ',                                                        
             ' ',                                                        
             0,                                                          
             0,                                                          
             0,                                                          
             0,                                                          
             '1900-01-01 00:00:00',                                      
             '1900-01-01 00:00:00',                                      
             '1900-01-01 00:00:00',                                      
             0,                                                          
             0,                                                          
             0,                                                          
             0,                                                          
             0,                                                          
             0,                                                          
             ' ', ' ',' ')   
                                                                  
   IF SQLCA.SQLCODE <> 0 THEN                                            
      CALL log003_err_sql("INCLUSAO","EST_LOC_RESER_END")                
      CALL log085_transacao("ROLLBACK")                                  
      RETURN FALSE                                                       
   END IF                                                                
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0403_est_loc_reser_end()#
#-----------------------------------#

      INSERT INTO est_loc_reser_end
            VALUES(p_cod_empresa,
                   mr_ordem_montag_grade.num_reserva,
                   mr_estoque_lote_ender.endereco,
                   mr_estoque_lote_ender.num_volume,
                   mr_estoque_lote_ender.cod_grade_1,
                   mr_estoque_lote_ender.cod_grade_2,
                   mr_estoque_lote_ender.cod_grade_3,
                   mr_estoque_lote_ender.cod_grade_4,
                   mr_estoque_lote_ender.cod_grade_5,
                   mr_estoque_lote_ender.dat_hor_producao,
                   mr_estoque_lote_ender.num_ped_ven,
                   mr_estoque_lote_ender.num_seq_ped_ven,
                   mr_estoque_lote_ender.dat_hor_validade,
                   mr_estoque_lote_ender.num_peca,
                   mr_estoque_lote_ender.num_serie,
                   mr_estoque_lote_ender.comprimento,
                   mr_estoque_lote_ender.largura,
                   mr_estoque_lote_ender.altura,
                   mr_estoque_lote_ender.diametro,
                   mr_estoque_lote_ender.dat_hor_reserv_1,
                   mr_estoque_lote_ender.dat_hor_reserv_2,
                   mr_estoque_lote_ender.dat_hor_reserv_3,
                   mr_estoque_lote_ender.qtd_reserv_1,
                   mr_estoque_lote_ender.qtd_reserv_2,
                   mr_estoque_lote_ender.qtd_reserv_3,
                   mr_estoque_lote_ender.num_reserv_1,
                   mr_estoque_lote_ender.num_reserv_2,
                   mr_estoque_lote_ender.num_reserv_3,
                   mr_estoque_lote_ender.tex_reservado,
                   mr_estoque_lote_ender.identif_estoque,
                   mr_estoque_lote_ender.deposit)

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
      
#------------------------------#
 FUNCTION pol0403_item_estoque()  
#------------------------------#

   DEFINE l_ies_ctr_est CHAR(01)

   LET l_ies_ctr_est = 'N'

   SELECT ies_ctr_estoque
      INTO l_ies_ctr_est 
   FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = mr_ordem_montag_item.cod_item

   IF SQLCA.SQLCODE <> 0 THEN
      RETURN FALSE
   END IF
        
   IF l_ies_ctr_est <> 'S' THEN 
      RETURN FALSE
   END IF

   RETURN TRUE 

END FUNCTION

#-----------------------------#
 FUNCTION pol0403_mostra_item()
#-----------------------------#

   DEFINE l_r CHAR(01)

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04031") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04031 AT 8,30 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
#  DISPLAY ma_tela1[pa_curr].* TO s_item[sc_curr].*

   DISPLAY ma_tela1[pa_curr].cod_item TO s_item[1].cod_item

   PROMPT "Digite Enter p/ Retornar." FOR l_r

   CLOSE WINDOW w_pol04031
   CURRENT WINDOW IS w_pol0403

END FUNCTION 

#----------------------------#
 FUNCTION pol0403_lotes_fifo()
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04034") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol04034 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE ma_tela2 TO NULL

   LET mr_tela1.qtd_infor = 0
   LET mr_tela1.qtd_dif = ma_tela[pa_curr].qtd_reservada 

   DISPLAY ma_tela[pa_curr].qtd_reservada TO qtd_reser
   DISPLAY BY NAME mr_tela.num_pedido,
                   ma_tela[pa_curr].cod_item,
                   mr_tela1.qtd_infor,
                   mr_tela1.qtd_dif

   SELECT cod_local_estoq
      INTO p_cod_local_estoq
   FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item = ma_tela1[pa_curr].cod_item

   DECLARE cq_estoque_lote CURSOR FOR
   SELECT cod_item,
          cod_local,
          num_lote,
          qtd_saldo,  
          dat_hor_producao
   FROM estoque_lote_ender
   WHERE cod_empresa = p_cod_empresa
     AND cod_item = ma_tela1[pa_curr].cod_item
     AND cod_local = p_cod_local_estoq
     AND ies_situa_qtd IN ("L","E")
     AND num_lote IS NOT NULL
   ORDER BY dat_hor_producao, 
            num_lote

   LET p_i = 1
   FOREACH cq_estoque_lote INTO mr_estoque_lote_ender.cod_item,
                                mr_estoque_lote_ender.cod_local,
                                mr_estoque_lote_ender.num_lote,
                                mr_estoque_lote_ender.qtd_saldo,
                                mr_estoque_lote_ender.dat_hor_producao

      SELECT SUM(qtd_reservada)
         INTO ma_tela2[p_i].qtd_reservada
      FROM estoque_loc_reser
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = mr_estoque_lote_ender.cod_item
        AND num_lote = mr_estoque_lote_ender.num_lote
        AND cod_local = mr_estoque_lote_ender.cod_local
      IF ma_tela2[p_i].qtd_reservada IS NULL THEN
         LET ma_tela2[p_i].qtd_reservada = 0 
      END IF

      LET ma_tela2[p_i].num_lote  = mr_estoque_lote_ender.num_lote
      LET ma_tela2[p_i].qtd_saldo = mr_estoque_lote_ender.qtd_saldo - 
                                    ma_tela2[p_i].qtd_reservada

      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada
        FROM w_lote 
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = ma_tela1[pa_curr].cod_item
         AND num_lote = ma_tela2[p_i].num_lote
         AND num_seq <> ma_tela[pa_curr].num_sequencia
     
      IF p_qtd_reservada IS NOT NULL AND 
         p_qtd_reservada > 0 THEN
         LET ma_tela2[p_i].qtd_saldo = ma_tela2[p_i].qtd_saldo - p_qtd_reservada
         LET p_qtd_reservada = 0
      END IF 
   
      IF ma_tela2[p_i].qtd_saldo = 0 THEN
         CONTINUE FOREACH
      END IF
      
      LET ma_tela2[p_i].qtd_reservada = 0 

      LET p_i = p_i + 1

   END FOREACH

   LET p_count = p_i - 1
   
   CALL SET_COUNT(p_i - 1)

   INPUT ARRAY ma_tela2 WITHOUT DEFAULTS FROM s_ordem.*

      BEFORE FIELD qtd_reservada 
         LET la_curr = ARR_CURR()
         LET lc_curr = SCR_LINE()
         
         LET p_qtd_saldo = ma_tela2[la_curr].qtd_reservada

      AFTER FIELD qtd_reservada 
        
         IF ma_tela2[la_curr].qtd_reservada IS NULL THEN
            LET ma_tela2[la_curr].qtd_reservada = 0
         END IF
                           
         IF ma_tela2[la_curr].qtd_reservada > ma_tela2[la_curr].qtd_saldo THEN
            ERROR "Quantidade Reservada Maior que Saldo do Item"
            NEXT FIELD qtd_reservada
         END IF 
        
         LET mr_tela1.qtd_infor = 0

         FOR p_i = 1 TO p_count 
            IF ma_tela2[p_i].num_lote IS NOT NULL AND
               ma_tela2[p_i].qtd_reservada IS NOT NULL AND
               ma_tela2[p_i].qtd_saldo IS NOT NULL THEN
               LET mr_tela1.qtd_infor = mr_tela1.qtd_infor + ma_tela2[p_i].qtd_reservada
            END IF
         END FOR
         
         LET mr_tela1.qtd_dif = ma_tela[pa_curr].qtd_reservada - mr_tela1.qtd_infor
         
         IF mr_tela1.qtd_dif < 0 THEN
            ERROR "Soma das qtdes selecionadas dos lotes maior que qtde a faturar"
            NEXT FIELD qtd_reservada
         END IF 

         DISPLAY BY NAME mr_tela1.qtd_infor,
                         mr_tela1.qtd_dif

   END INPUT        

   DELETE FROM w_lote
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = ma_tela1[pa_curr].cod_item
      AND num_seq  = ma_tela[pa_curr].num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('deletando','w_lote')
   END IF

   IF INT_FLAG THEN
      INITIALIZE ma_tela2 TO NULL
      LET ma_tela[pa_curr].qtd_reservada = 0
   ELSE
      CALL pol0403_grava_lotes()
      LET ma_tela[pa_curr].qtd_reservada = mr_tela1.qtd_infor
   END IF

   CLOSE WINDOW w_pol04034
   CURRENT WINDOW IS w_pol0403
   
END FUNCTION

#-----------------------------#
FUNCTION pol0403_grava_lotes()
#-----------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
       
       IF ma_tela2[p_ind].num_lote IS NOT NULL AND
          ma_tela2[p_ind].qtd_reservada IS NOT NULL AND
          ma_tela2[p_ind].qtd_saldo IS NOT NULL THEN

          IF ma_tela2[p_ind].qtd_reservada > 0 THEN
             INSERT INTO w_lote
               VALUES(p_cod_empresa,
                      ma_tela1[pa_curr].cod_item,
                      ma_tela[pa_curr].num_sequencia,
                      p_cod_local_estoq,
                      ma_tela2[p_ind].num_lote,
                      ma_tela2[p_ind].qtd_reservada,
                      ma_tela2[p_ind].qtd_saldo)

             IF SQLCA.SQLCODE <> 0 THEN
                CALL log003_err_sql("INCLUSAO","W_LOTE")
             END IF
          END IF
            
       END IF

   END FOR

END FUNCTION

#------------------------#
 FUNCTION pol0403_listar()
#------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04033") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol04033 AT 9,12 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF pol0403_entrada_dados() THEN
      CALL pol0403_cria_tab_resumo()
      CALL pol0403_imprime() 
   END IF
      
END FUNCTION

#-------------------------------#
 FUNCTION pol0403_entrada_dados()
#-------------------------------#

   CLEAR FORM
   LET INT_FLAG = FALSE   
   INITIALIZE mr_tela1.* TO NULL
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME mr_tela1.reimpressao,
                 mr_tela1.cod_cliente,
                 mr_tela1.num_lote_om
      WITHOUT DEFAULTS

      BEFORE FIELD reimpressao 
         LET mr_tela1.reimpressao = "N"

      AFTER FIELD reimpressao 
      IF mr_tela1.reimpressao IS NULL OR
         mr_tela1.reimpressao = " " THEN
         LET mr_tela1.reimpressao = "N"
         DISPLAY BY NAME mr_tela1.reimpressao
      END IF

      AFTER FIELD cod_cliente
      IF mr_tela1.cod_cliente IS NOT NULL THEN
         SELECT nom_cliente
            INTO mr_tela1.nom_cliente
         FROM clientes
         WHERE cod_cliente = mr_tela1.cod_cliente
         IF SQLCA.SQLCODE <> 0 THEN 
            ERROR "Cliente nao Cadastrado" 
            NEXT FIELD cod_cliente
         END IF   
         DISPLAY BY NAME mr_tela1.nom_cliente
      END IF

      AFTER FIELD num_lote_om
      IF mr_tela1.num_lote_om IS NOT NULL THEN
         SELECT *               
         FROM ordem_montag_lote
         WHERE cod_empresa = p_cod_empresa
           AND num_lote_om = mr_tela1.num_lote_om
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Lote nao Cadastrado"
            NEXT FIELD num_lote_om
         END IF   
      END IF

   END INPUT

   CLOSE WINDOW w_pol04033

   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Opera��o Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
 FUNCTION pol0403_imprime()
#-------------------------#

   DEFINE p_sql_stmt           VARCHAR(1000),                      
          l_qtd_embal          LIKE embal_itaesbra.qtd_padr_embal, 
          p_data               CHAR(10),                           
          p_hora               CHAR(08),                           
          p_tamanho            INTEGER                            

    LET p_data = TODAY USING "yyyy-mm-dd"
    LET p_hora = TIME
    
    IF log0280_saida_relat(13,29) IS NOT NULL THEN

      {LET p_tamanho = LENGTH(p_nom_arquivo) - 4
      LET p_nom_arquivo = p_nom_arquivo[1, p_tamanho]
      LET p_nom_arquivo = p_nom_arquivo CLIPPED,
             '.',p_data,'.',p_hora[1,2],'.',p_hora[4,5],'.lst'}

      MESSAGE " Processando a Extracao do Relatorio..." 
         ATTRIBUTE(REVERSE)
         
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0403_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0403.tmp' 
            START REPORT pol0403_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT pol0403_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN 
   END IF

   CALL pol0403_cria_temporaria()

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_count = 0

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF mr_tela1.reimpressao = "S" THEN

   IF mr_tela1.cod_cliente IS NOT NULL AND
      mr_tela1.num_lote_om IS NULL THEN
      LET p_sql_stmt = " SELECT UNIQUE a.num_lote_om, ",
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente,",
                     " e.cod_item_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d, OUTER cliente_item e ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND d.cod_empresa = e.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND e.cod_empresa = '",p_cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND d.cod_cliente = '",mr_tela1.cod_cliente,"' ",
                     " AND d.cod_cliente = e.cod_cliente_matriz ",
                     " AND b.cod_item = e.cod_item ",
                     " ORDER BY 9,1,10,4 "
   END IF

   IF mr_tela1.cod_cliente IS NULL AND
      mr_tela1.num_lote_om IS NOT NULL THEN
      LET p_sql_stmt = " SELECT UNIQUE a.num_lote_om, ",
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente, ",
                     " e.cod_item_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d, OUTER cliente_item e ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND d.cod_empresa = e.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND c.num_lote_om = '",mr_tela1.num_lote_om,"' ",
                     " AND e.cod_empresa = '",p_cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND d.cod_cliente = e.cod_cliente_matriz ",
                     " AND b.cod_item = e.cod_item ",
                     " ORDER BY 9,1,10,4 "
   END IF

   IF mr_tela1.cod_cliente IS NOT NULL AND
      mr_tela1.num_lote_om IS NOT NULL THEN
      LET p_sql_stmt = " SELECT UNIQUE a.num_lote_om, ",
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente, ",
                     " e.cod_item_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d, OUTER cliente_item e ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND d.cod_empresa = e.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND c.num_lote_om = '",mr_tela1.num_lote_om,"' ",
                     " AND e.cod_empresa = '",p_cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND d.cod_cliente = '",mr_tela1.cod_cliente,"' ",
                     " AND d.cod_cliente = e.cod_cliente_matriz ",
                     " AND b.cod_item = e.cod_item ",
                     " ORDER BY 9,1,10,4 "
   END IF

   IF mr_tela1.cod_cliente IS NULL AND
      mr_tela1.num_lote_om IS NULL THEN
      LET p_sql_stmt = " SELECT UNIQUE a.num_lote_om, ",
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente, ",
                     " e.cod_item_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d, OUTER cliente_item e ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND d.cod_empresa = e.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND e.cod_empresa = '",p_cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND d.cod_cliente = e.cod_cliente_matriz ",
                     " AND b.cod_item = e.cod_item ",
                     " ORDER BY 9,1,10,4 "
   END IF

   ELSE

   IF mr_tela1.cod_cliente IS NOT NULL AND
      mr_tela1.num_lote_om IS NULL THEN
      LET p_sql_stmt = " SELECT UNIQUE a.num_lote_om, ",
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente, ",
                     " f.cod_item_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d, om_list e, ",
                     " OUTER cliente_item f ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND d.cod_empresa = e.cod_empresa ",
                     " AND e.cod_empresa = f.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND b.num_om = e.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND f.cod_empresa = '",p_cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND e.nom_usuario = '",p_user,"' ",
                     " AND d.cod_cliente = '",mr_tela1.cod_cliente,"' ",
                     " AND d.cod_cliente = f.cod_cliente_matriz ",
                     " AND b.cod_item = f.cod_item ",
                     " ORDER BY 9,1,10,4 "
   END IF

   IF mr_tela1.cod_cliente IS NULL AND
      mr_tela1.num_lote_om IS NOT NULL THEN
      LET p_sql_stmt = " SELECT UNIQUE a.num_lote_om, ",
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente, ",
                     " f.cod_item_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d, om_list e, ",
                     " OUTER cliente_item f ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND d.cod_empresa = e.cod_empresa ",
                     " AND e.cod_empresa = f.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND b.num_om = e.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND c.num_lote_om = '",mr_tela1.num_lote_om,"' ",
                     " AND f.cod_empresa = '",p_cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND e.nom_usuario = '",p_user,"' ",
                     " AND d.cod_cliente = f.cod_cliente_matriz ",
                     " AND b.cod_item = f.cod_item ",
                     " ORDER BY 9,1,10,4 "
   END IF

   IF mr_tela1.cod_cliente IS NOT NULL AND
      mr_tela1.num_lote_om IS NOT NULL THEN
      LET p_sql_stmt = " SELECT UNIQUE a.num_lote_om, ",
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente, ",
                     " f.cod_item_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d, om_list e, ",
                     " OUTER cliente_item f ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND d.cod_empresa = e.cod_empresa ",
                     " AND e.cod_empresa = f.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND b.num_om = e.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND c.num_lote_om = '",mr_tela1.num_lote_om,"' ",
                     " AND f.cod_empresa = '",p_cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND e.nom_usuario = '",p_user,"' ",
                     " AND d.cod_cliente = '",mr_tela1.cod_cliente,"' ",
                     " AND d.cod_cliente = f.cod_cliente_matriz ",
                     " AND b.cod_item = f.cod_item ",
                     " ORDER BY 9,1,10,4 "
   END IF

   IF mr_tela1.cod_cliente IS NULL AND
      mr_tela1.num_lote_om IS NULL THEN
      LET p_sql_stmt = " SELECT UNIQUE a.num_lote_om, ",
                     " a.num_om, ",
                     " b.num_sequencia, ",
                     " b.cod_item, ",
                     " b.qtd_reservada, ",
                     " c.cod_transpor, ",
                     " c.num_placa, ",
                     " d.num_pedido, ",
                     " d.cod_cliente, ",
                     " f.cod_item_cliente ",
                     " FROM ordem_montag_mest a, ordem_montag_item b, ",
                     " ordem_montag_lote c, pedidos d, om_list e, ",
                     " OUTER cliente_item f ",
                     " WHERE a.cod_empresa = b.cod_empresa ",
                     " AND b.cod_empresa = c.cod_empresa ",
                     " AND c.cod_empresa = d.cod_empresa ",
                     " AND d.cod_empresa = e.cod_empresa ",
                     " AND e.cod_empresa = f.cod_empresa ",
                     " AND a.num_om = b.num_om ",
                     " AND b.num_om = e.num_om ",
                     " AND a.num_lote_om = c.num_lote_om ",
                     " AND f.cod_empresa = '",p_cod_empresa,"' ",
                     " AND b.num_pedido = d.num_pedido ",
                     " AND a.num_nff IS NULL ",
                     " AND a.ies_sit_om = 'N' ",
                     " AND e.nom_usuario = '",p_user,"' ",
                     " AND d.cod_cliente = f.cod_cliente_matriz ",
                     " AND b.cod_item = f.cod_item ",
                     " ORDER BY 9,1,10,4 "
   END IF

   END IF

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
                         p_relat.cod_cliente,
                         p_relat.cod_item_cliente

      SELECT den_item,
             cod_unid_med
        INTO p_relat.den_item,
             p_relat.cod_unid_med
        FROM item
       WHERE cod_empresa = p_cod_empresa 
         AND cod_item = p_relat.cod_item

      SELECT usuario 
        INTO mr_tela.usuario
        FROM user_romaneio_304
       WHERE cod_empresa = p_cod_empresa 
         AND num_om      = p_relat.num_om
         
      IF STATUS = 100 THEN 
         LET mr_tela.usuario = NULL 
      ELSE 
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo', 'user_romaneio_304')
            RETURN FALSE 
         END IF 
      END IF 

      SELECT cod_embal_int, 
             qtd_embal_int, 
             cod_embal_ext, 
             qtd_embal_ext 
        INTO p_cod_embal_int,  
             p_qtd_vol_int,  
             p_cod_embal_ext,  
             p_qtd_vol_ext   
        FROM ordem_montag_embal
       WHERE cod_empresa   = p_cod_empresa 
         AND num_om        = p_relat.num_om
         AND num_sequencia = p_relat.num_sequencia

      IF p_qtd_vol_int IS NOT NULL AND p_qtd_vol_int > 0 THEN
         LET p_qtd_embal_int = p_qtd_faturada / p_qtd_vol_int
      ELSE
         LET p_qtd_vol_int = 0
         LET p_cod_embal_int = NULL
         LET p_qtd_embal_int = NULL
      END IF

      IF p_qtd_vol_ext IS NOT NULL AND p_qtd_vol_ext > 0 THEN
         LET p_qtd_embal_ext = p_qtd_faturada / p_qtd_vol_ext
      ELSE
         LET p_qtd_vol_ext = 0
         LET p_cod_embal_ext = NULL
         LET p_qtd_embal_ext = NULL
      END IF

      IF p_cod_embal_int IS NOT NULL THEN
         SELECT cod_embal_item
           INTO p_cod_embal_int_dp
           FROM de_para_embal
          WHERE cod_empresa   = p_cod_empresa
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
          WHERE cod_empresa   = p_cod_empresa
            AND cod_embal_vdp = p_cod_embal_ext
      
         IF STATUS <> 0 THEN
            LET p_cod_embal_ext_dp = p_cod_embal_ext
         END IF
      ELSE
         LET p_cod_embal_ext_dp = NULL
      END IF
      
      LET p_count = 1
      
      OUTPUT TO REPORT pol0403_relat(
         p_relat.cod_cliente, p_relat.num_lote_om, p_relat.cod_item_cliente)
         
      IF p_cod_embal_int IS NOT NULL THEN
         INSERT INTO resumo_embal 
            VALUES (p_cod_embal_int, p_qtd_vol_int)
         
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","RESUMO_EMBAL_INT")
            EXIT FOREACH 
         END IF
      END IF
      
      IF p_cod_embal_ext IS NOT NULL THEN
         INSERT INTO resumo_embal 
            VALUES (p_cod_embal_ext, p_qtd_vol_ext)
         
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO","RESUMO_EMBAL_EXT")
            EXIT FOREACH 
         END IF
      END IF
             
      IF mr_tela1.reimpressao = "N" THEN

         INSERT INTO w_om_list
            VALUES (p_cod_empresa,
                    p_relat.num_om,
                    p_relat.num_pedido,
                    m_dat_atu,
                    p_user)
         IF SQLCA.SQLCODE <> 0 THEN   
            CALL log003_err_sql("INCLUSAO","W_OM_LIST")
            EXIT FOREACH
         END IF

      END IF
      INITIALIZE p_relat.* TO NULL

   END FOREACH
   
   FINISH REPORT pol0403_relat

   IF mr_tela1.reimpressao = "N" THEN

      DECLARE cq_om_list CURSOR FOR
      SELECT * FROM w_om_list
   
      FOREACH cq_om_list INTO mr_om_list.*

         DELETE FROM om_list
         WHERE cod_empresa = p_cod_empresa
           AND num_om = mr_om_list.num_om
           AND nom_usuario = p_user
         IF SQLCA.SQLCODE <> 0 THEN   
            CALL log003_err_sql("EXCLUSAO","OM_LIST")
            EXIT FOREACH
         END IF

      END FOREACH

   END IF

   IF p_count > 0 THEN
      IF p_ies_impressao = "S" THEN
         ERROR "Relatorio Impresso na Impressora ", p_nom_arquivo
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando 
         END IF
      ELSE 
         ERROR "Relatorio Gravado no Arquivo ", p_nom_arquivo, " " 
      END IF
   ELSE 
      ERROR "Nao Existem Dados p/ serem Listados" 
   END IF

END FUNCTION

#--------------------------------#
FUNCTION pol0403_cria_temporaria()
#--------------------------------#

   CALL log085_transacao("BEGIN") 
#  BEGIN WORK

   LOCK TABLE w_om_list IN EXCLUSIVE MODE

   CALL log085_transacao("COMMIT") 
#  COMMIT WORK

   DROP TABLE w_om_list;

   IF SQLCA.SQLCODE <> 0 THEN 
      DELETE FROM w_om_list;
   END IF

   
   CREATE TEMP TABLE w_om_list
     (
      cod_empresa    CHAR(2),  
      num_om         DEC(6,0), 
      num_pedido     DEC(6,0), 
      dat_emis       DATE,
      nom_usuario    CHAR(8)      
     ) WITH NO LOG;
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-W_OM_LIST")
   END IF
 
END FUNCTION

#---------------------------------#
 FUNCTION pol0403_cria_tab_resumo()
#---------------------------------# 

   CALL log085_transacao("BEGIN") 

   DROP TABLE resumo_embal;
   CREATE  TEMP TABLE resumo_embal
     (
      cod_embal        CHAR(15),
      qtd_vol          DECIMAL(6,0)
     );
     
     IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-resumo_embal")
   END IF
   
END FUNCTION

#--------------------------------------------------#
 REPORT pol0403_relat(
    p_cod_cliente, p_num_lote_om,p_cod_item_cliente)
#--------------------------------------------------# 
      
   DEFINE p_cod_embal        CHAR(05),
          p_cod_embal_item   CHAR(07),
          p_den_embal        CHAR(26),
          p_qtd_vol          DECIMAL(6,0),
          p_primeira         CHAR(01),
          p_num_lote_om      LIKE ordem_montag_lote.num_lote_om,
          p_cod_cliente      CHAR(15),
          p_cod_item_cliente CHAR(30),
          p_embalagens       CHAR(12)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   ORDER EXTERNAL BY p_cod_cliente,
                     p_num_lote_om,
                     p_cod_item_cliente

   FORMAT

      FIRST PAGE HEADER
	  
	    PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;


         PRINT COLUMN 001, p_comprime,
               COLUMN 001, p_den_empresa[1,20],
               COLUMN 054, "LISTAGEM O.M. NAO FATURADAS",
               COLUMN 125, "PAG.: ", PAGENO USING "######&"
         IF mr_tela1.reimpressao = "S" THEN
            PRINT COLUMN 001, "POL0403                                                       REIMPRESSAO";
         ELSE
            PRINT COLUMN 001, "POL0403                                                         IMPRESSAO";
         END IF 
         PRINT COLUMN 110, "EMISSAO: ", TODAY USING "DD/MM/YYYY", ' ', TIME 
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"
      PAGE HEADER

      #  PRINT log500_determina_cpp(132)
      #  PRINT log500_condensado(true)
         PRINT
         PRINT COLUMN 001, p_den_empresa[1,20],
               COLUMN 028, "LISTAGEM O.M. NAO FATURADAS",
               COLUMN 125, "PAG. :    ", PAGENO USING "######&"
         PRINT COLUMN 001, "POL0403",
               COLUMN 110, "EMISSAO : ", TODAY USING "DD/MM/YYYY", ' ', TIME 
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------"

      BEFORE GROUP OF p_cod_cliente

         SKIP TO TOP OF PAGE

         SELECT nom_cliente,
                cod_cidade
            INTO p_relat.nom_cliente,
                 mr_cidades.cod_cidade
         FROM clientes
         WHERE cod_cliente = p_relat.cod_cliente    

         SELECT den_cidade
            INTO mr_cidades.den_cidade
         FROM cidades
         WHERE cod_cidade = mr_cidades.cod_cidade

         SELECT num_pedido_repres
            INTO mr_pedidos.num_pedido_repres
         FROM pedidos
         WHERE cod_empresa = p_cod_empresa      
           AND num_pedido = p_relat.num_pedido

         IF mr_pedidos.num_pedido_repres IS NOT NULL THEN
            PRINT COLUMN 001, "Cliente        : ", p_relat.cod_cliente, " - ", 
                              p_relat.nom_cliente[1,23], 
                  COLUMN 063, "PLANTA : ", mr_pedidos.num_pedido_repres
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
               COLUMN 036, mr_cidades.den_cidade
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
           AND a.cod_empresa = p_cod_empresa
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
         
         PRINT COLUMN 001, mr_tela.usuario,
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
             WHERE cod_empresa   = p_cod_empresa
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

         PRINT p_descomprime

END REPORT
#------------------------------ FIM DE PROGRAMA BL-------------------------------#
{ALTERA��ES:
24/08/12: grava��o da est_loc_reser_end a partir da estoque_lote_ender
04/09/12: ajsutes na rotina de reserva para item que n�o controla lote
          