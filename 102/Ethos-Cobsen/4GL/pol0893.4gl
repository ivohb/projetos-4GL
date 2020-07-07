#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: pol0893                                               #
# MODULOS.: pol0893 - LOG0010 - LOG0030 - LOG0040 - LOG0050       #
#           LOG0060 - LOG1200 - LOG1300 - LOG1400                 #
# OBJETIVO: VARIACAO DA PROGRAMACAO DO CLIENTE                    #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_cod_cliente          LIKE pedidos.cod_cliente,
         p_cod_cnd_pgto         LIKE pedidos.cod_cnd_pgto,
         p_cnd_pgto_list        LIKE ped_cond_pgto_list.cod_cnd_pgto,
         p_ies_preco            LIKE pedidos.ies_preco,
         p_num_list_preco       LIKE pedidos.num_list_preco,
         p_num_versao_lista     LIKE pedidos.num_versao_lista,
         p_num_nff_ult          LIKE pedidos_qfp.num_nff_ult,
         p_qtd_estoque          LIKE estoque.qtd_liberada,
         p_qtd_prod             LIKE estoque.qtd_liberada,
         p_qtd_tot_ent          LIKE estoque.qtd_liberada,
         p_qtd_saldo_ped        LIKE ped_itens.qtd_pecas_solic,
         p_pre_unit             LIKE list_preco_item.pre_unit,
         p_qtd_pecas_cancel     LIKE ped_itens.qtd_pecas_cancel,
         p_cod_item_cliente     LIKE cliente_item.cod_item_cliente,
         p_identif              LIKE pedidos_edi_pe1.identif_prog_atual,  
         p_num_om_ini           LIKE ordem_montag_mest.num_om,
         p_num_om_fim           LIKE ordem_montag_mest.num_om,
         p_release              CHAR(40),
         p_saldo                DECIMAL(10,3),
         p_msg                  CHAR(100),
         pa_curr                SMALLINT,
         sc_curr                SMALLINT,
         p_erro                 CHAR(01),       
         p_qtd_variacao         DECIMAL(07,0),
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_ind                  SMALLINT,
         p_ies_cons             SMALLINT

  DEFINE p_tela   RECORD
                   dat_ini    DATE,
                   dat_fim    DATE    
                 END RECORD

  DEFINE p_wped_rom   RECORD
             num_pedido        LIKE ped_itens.num_pedido,
             num_sequencia     LIKE ped_itens.num_sequencia, 
             qtd_saldo         LIKE ped_itens.qtd_pecas_solic,
             prz_entrega       LIKE ped_itens.prz_entrega
                      END RECORD    

  DEFINE t_ped_itens_fct_547  ARRAY[500] OF RECORD
             ies_func          CHAR(01),
             dat_entrega       LIKE ped_itens_fct_547.prz_entrega,
             qtd_gatilho       LIKE ped_itens_fct_547.qtd_solic,      
             qtd_solic         LIKE ped_itens_fct_547.qtd_solic,      
             qtd_estoque       LIKE ped_itens.qtd_pecas_atend,
             qtd_produc        LIKE ped_itens.qtd_pecas_atend,
             ies_semana        CHAR(03) 
                         END RECORD
                                
  DEFINE p_ped_itens_fct_547   RECORD LIKE ped_itens_fct_547.*,
         p_ped_itens_fct_547r  RECORD LIKE ped_itens_fct_547.*,
         p_ped_itens           RECORD LIKE ped_itens.*,
         p_audit_vdp           RECORD LIKE audit_vdp.*,
         p_ordem_montag_mest   RECORD LIKE ordem_montag_mest.*,
         p_ordem_montag_item   RECORD LIKE ordem_montag_item.*,
         p_ordem_montag_grade RECORD LIKE ordem_montag_grade.*,
         p_estoque_loc_reser  RECORD LIKE estoque_loc_reser.*,
         p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
         p_ldi_om_grade_compl RECORD LIKE ldi_om_grade_compl.*
     
  
  DEFINE p_nom_arquivo          CHAR(100),
         p_ies_impressao        CHAR(001),
         p_ok                   CHAR(001),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_prog_inex            CHAR(001),
         p_help                 CHAR(080),
         p_count_ped            INTEGER,
         p_cancel               INTEGER
  DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

{  >>  OS 115462 - INICIO  <<  }
   DEFINE
      mr_par_vdp      RECORD  LIKE  par_vdp.*,
      m_cod_tip_carteira_ant  LIKE  pedidos.cod_tip_carteira,
      m_cod_tip_carteira      LIKE  pedidos.cod_tip_carteira,
      m_qtd_decimais_cart     DECIMAL(1,0),
      m_qtd_decimais_par      DECIMAL(1,0)
{  >>  OS 115462 - FINAL  <<  }

   DEFINE m_nom_cliente       LIKE clientes.nom_cliente
MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0893-10.02.05" 
  WHENEVER ANY ERROR CONTINUE
  CALL log1400_isolation()             
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho CLIPPED
  OPTIONS
    HELP FILE p_help,
    PREVIOUS KEY control-b,
    NEXT     KEY control-f

  CALL log001_acessa_usuario("ESPEC999","")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN 
    CALL pol0893_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0893_controle()
#--------------------------#

  INITIALIZE p_ped_itens_fct_547.*, p_ped_itens_fct_547r.*, p_ped_itens.* TO NULL
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol0893") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0893 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

{  >>  OS 115462 - INICIO  <<  }
   SELECT * INTO mr_par_vdp.* FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      ERROR " Parametros do Sistema nao cadastrados (VDP1400) "
   END IF

   LET m_qtd_decimais_par = mr_par_vdp.par_vdp_txt[43,43]
{  >>  OS 115462 - FINAL  <<  }

  MENU "OPCAO"
    COMMAND "Consultar"    "Consulta Programacao do cliente"
      HELP 0004
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","pol0893","CO")
      THEN CALL pol0893_consulta_ped_itens_fct_547()
           MESSAGE "                 "
      END IF
    COMMAND KEY ("G") "Gera Om"    "Confirma Programacao do cliente "
      HELP 2043
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","pol0893","MO") THEN
        IF t_ped_itens_fct_547[1].dat_entrega IS NULL THEN 
           MESSAGE "Nao existem dados para confirmacao"  ATTRIBUTE(REVERSE)
        ELSE
          IF log004_confirm(22,45) THEN
             ERROR " Em Processamento... "
             CALL pol0893_atualiza_ped_itens()
             CLEAR FORM
             MESSAGE "Confirmacao Executada com Sucesso Om ini ",p_num_om_ini," Om Final ",p_num_om_ini   ATTRIBUTE(REVERSE)
             NEXT OPTION "Consultar"
          END IF
        END IF  
      END IF
    COMMAND "Seguinte"   "Exibe Programacao seguinte"
      HELP 0005
      MESSAGE ""
      CALL pol0893_paginacao("SEGUINTE")
    COMMAND "Anterior"   "Exibe Programacao anterior "
      HELP 0006
      MESSAGE ""
      CALL pol0893_paginacao("ANTERIOR")
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0893_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0893
END FUNCTION

#--------------------------------------------#
 FUNCTION pol0893_consulta_ped_itens_fct_547()
#--------------------------------------------#
  DEFINE where_clause, sql_stmt CHAR(550),
         l_count     INTEGER

  CLEAR FORM
  CALL log006_exibe_teclas("02 07", p_versao)
  CURRENT WINDOW IS w_pol0893
  DISPLAY p_cod_empresa TO cod_empresa

  CALL pol0893_cria_tmp()

  LET p_ped_itens_fct_547r.* = p_ped_itens_fct_547.*
  INITIALIZE p_ped_itens_fct_547.*,
             t_ped_itens_fct_547  TO NULL

  CONSTRUCT BY NAME where_clause ON ped_itens_fct_547.num_pedido,
                                    ped_itens_fct_547.cod_item,
                                    pedidos.cod_cliente
  LET p_tela.dat_ini = '01/01/2000'
  LET p_tela.dat_fim = '31/12/3000'
  
 INPUT BY NAME p_tela.* WITHOUT DEFAULTS

#  BEFORE FIELD dat_ini
#     LET p_tela.dat_ini = '01/01/2000'
#     LET p_tela.dat_fim = '31/12/3000'


  AFTER FIELD dat_ini
     IF p_tela.dat_ini IS NULL THEN
        ERROR "Campo de preenchimento obrigatorio"
        NEXT FIELD dat_ini 
     END IF   
     
  AFTER FIELD dat_fim  
     IF p_tela.dat_fim IS NULL THEN
        ERROR "Campo de preenchimento obrigatorio"
        NEXT FIELD dat_fim
     ELSE   
        IF p_tela.dat_ini > p_tela.dat_fim THEN 
           ERROR "Data final deve ser maior ou igual inicial"
           NEXT FIELD dat_ini
        END IF     
     END IF

  IF INT_FLAG THEN
     LET int_flag = 0
     LET p_ped_itens_fct_547.* = p_ped_itens_fct_547r.*
     CALL log006_exibe_teclas("01", p_versao)
     CURRENT WINDOW IS w_pol0893
     CALL pol0893_exibe_dados()
     ERROR " Consulta Cancelada "
     RETURN
  END IF

  LET sql_stmt = "SELECT UNIQUE ped_itens_fct_547.num_pedido, ",
                 "ped_itens_fct_547.cod_item, ",
                 "pedidos.cod_cliente ",
                 "FROM ped_itens_fct_547, pedidos ",
                 "WHERE ped_itens_fct_547.cod_empresa = '",p_cod_empresa,"' ",
                 "AND ped_itens_fct_547.qtd_romaneio < ped_itens_fct_547.qtd_solic ",
                 "AND ", where_clause CLIPPED, " ",
                 "AND pedidos.cod_empresa     = ped_itens_fct_547.cod_empresa ",
                 "AND pedidos.num_pedido      = ped_itens_fct_547.num_pedido  "

  PREPARE var_query FROM sql_stmt

  DECLARE cq_ped_itens_fct_547 SCROLL CURSOR WITH HOLD FOR var_query
  OPEN  cq_ped_itens_fct_547
  FETCH cq_ped_itens_fct_547 INTO p_ped_itens_fct_547.num_pedido,
                                  p_ped_itens_fct_547.cod_item,
                                  p_cod_cliente
  
  IF SQLCA.sqlcode = NOTFOUND THEN
     MESSAGE "Argumentos de Pesquisa nao Encontrados !!!" ATTRIBUTE(REVERSE)
     LET p_ies_cons = FALSE
  ELSE 
     MESSAGE " Consultando ... "
     LET p_ies_cons = TRUE
     IF pol0893_verifica_pedido() THEN
     END IF 
     
     CALL pol0893_prepara_dados_consulta()
     
     CALL pol0893_monta_dados_consulta()
     CALL log006_exibe_teclas("01 02", p_versao)
     CURRENT WINDOW IS w_pol0893
     CALL pol0893_exibe_dados()
     LET int_flag = 0
  END IF
 
 END INPUT 
END FUNCTION

#----------------------------------------#
 FUNCTION pol0893_prepara_dados_consulta()
#----------------------------------------#

     DELETE FROM wped_rom
  
     SELECT cod_item_cliente 
       INTO p_cod_item_cliente 
       FROM cliente_item
      WHERE cod_empresa = p_cod_empresa
        AND cod_cliente_matriz = p_cod_cliente 
        AND cod_item = p_ped_itens_fct_547.cod_item

     SELECT (qtd_liberada - qtd_reservada)
       INTO p_qtd_estoque
       FROM estoque 
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = p_ped_itens_fct_547.cod_item 

     IF p_qtd_estoque IS NULL THEN
        LET p_qtd_estoque = 0 
     END IF    
  
     SELECT SUM(qtd_planej - qtd_boas - qtd_refug - qtd_sucata)
       INTO p_qtd_prod
       FROM ordens 
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = p_ped_itens_fct_547.cod_item 
        AND ies_situa IN (3,4)
  
     IF p_qtd_prod IS NULL THEN
        LET p_qtd_prod = 0 
     END IF    

END FUNCTION

#---------------------------------#
 FUNCTION pol0893_verifica_pedido()
#---------------------------------#
  INITIALIZE p_cod_cliente, p_ies_preco TO NULL
  LET p_cnd_pgto_list    = 0
  LET p_cod_cnd_pgto     = 0
  LET p_num_list_preco   = 0
  LET p_num_versao_lista = 0

  SELECT cod_cliente, cod_cnd_pgto, ies_preco, num_list_preco,
         num_versao_lista, cod_tip_carteira
    INTO p_cod_cliente, p_cod_cnd_pgto, p_ies_preco, p_num_list_preco,
         p_num_versao_lista, m_cod_tip_carteira
    FROM pedidos
   WHERE pedidos.cod_empresa = p_cod_empresa
     AND pedidos.num_pedido  = p_ped_itens_fct_547.num_pedido

  IF sqlca.sqlcode = 0 THEN 
     IF p_cnd_pgto_list = 0 THEN
     ELSE 
       LET p_cod_cnd_pgto = p_cnd_pgto_list
     END IF
     RETURN TRUE
  ELSE 
     RETURN FALSE
  END IF
END FUNCTION

#---------------------------------------#
 FUNCTION pol0893_monta_dados_consulta()
#---------------------------------------#
  DEFINE l_prz_entrega     LIKE ped_itens.prz_entrega,
         l_ind             INTEGER,
         l_dat_ini         LIKE ped_itens.prz_entrega,
         l_dat_rom         LIKE ped_itens.prz_entrega,
         l_qtd_res         LIKE ped_itens.qtd_pecas_solic,
         l_qtd_saldo_ant   LIKE ped_itens.qtd_pecas_solic,
         l_qtd_gatilho     LIKE ped_itens.qtd_pecas_solic,
         l_dat_entrega_ant LIKE ped_itens.prz_entrega,
         l_num_seq         LIKE ped_itens.num_sequencia,
         l_ent_ant         LIKE ped_itens.prz_entrega,
         l_dat_emissao     LIKE fat_nf_mestre.dat_hor_emissao,
         l_ent_sant        LIKE ped_itens.prz_entrega,
         l_qtd_dias        INTEGER,
         l_dia_sem_ant     INTEGER,
         l_dia_sem_atu     INTEGER,
         l_dia_sem_rom     INTEGER,
         l_dia_sem_sant    INTEGER   
         
  
  LET l_qtd_res = 0
  CALL set_count(0)                                                  
  LET p_ind = 1                                                     
  LET l_dat_ini = '01/01/1900'
  LET l_dat_entrega_ant = '01/01/1900'
  
  DECLARE cq_pdr CURSOR FOR 
    SELECT prz_entrega,
           WEEKDAY(prz_entrega),
           (qtd_solic - qtd_romaneio)
      FROM ped_itens_fct_547 
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_ped_itens_fct_547.num_pedido
       AND cod_item    = p_ped_itens_fct_547.cod_item 
       AND (qtd_solic - qtd_romaneio) > 0
       AND prz_entrega >= p_tela.dat_ini
       AND prz_entrega <= p_tela.dat_fim
     ORDER BY prz_entrega 
  FOREACH cq_pdr INTO p_ped_itens.prz_entrega,l_dia_sem_atu, p_qtd_saldo_ped

     IF p_qtd_estoque >= p_qtd_saldo_ped THEN   
        LET t_ped_itens_fct_547[p_ind].qtd_solic       = p_qtd_saldo_ped 
        LET t_ped_itens_fct_547[p_ind].dat_entrega     = p_ped_itens.prz_entrega
        LET t_ped_itens_fct_547[p_ind].qtd_gatilho     = p_qtd_saldo_ped  
        LET p_qtd_estoque = p_qtd_estoque - p_qtd_saldo_ped
        LET t_ped_itens_fct_547[p_ind].qtd_estoque     = p_qtd_estoque
        LET t_ped_itens_fct_547[p_ind].qtd_produc      = p_qtd_prod 
     ELSE
        LET t_ped_itens_fct_547[p_ind].qtd_solic       = p_qtd_estoque
        LET t_ped_itens_fct_547[p_ind].dat_entrega     = p_ped_itens.prz_entrega
        LET t_ped_itens_fct_547[p_ind].qtd_gatilho     = p_qtd_saldo_ped 
        LET p_qtd_estoque = 0
        LET t_ped_itens_fct_547[p_ind].qtd_estoque     = p_qtd_estoque
        LET t_ped_itens_fct_547[p_ind].qtd_produc      = p_qtd_prod 
     END IF 

     SELECT MAX(dat_hor_emissao), 
            WEEKDAY(MAX(dat_hor_emissao)) 
       INTO l_dat_emissao,
            l_dia_sem_ant 
       FROM fat_nf_mestre a,
            fat_nf_item b
      WHERE a.empresa           = p_cod_empresa
        AND a.empresa           = b.empresa
        AND a.trans_nota_fiscal = b.trans_nota_fiscal
        AND b.pedido            = p_ped_itens_fct_547.num_pedido

     LET l_ent_ant = l_dat_emissao
     
     SELECT MAX(prz_entrega),
            WEEKDAY(MAX(prz_entrega))  
       INTO l_ent_sant,
            l_dia_sem_sant
       FROM ped_itens_fct_547
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_ped_itens_fct_547.num_pedido
##        AND dat_alteracao IS NULL 
        AND prz_entrega < p_ped_itens.prz_entrega


    IF  l_ent_sant > l_ent_ant  THEN 
        LET l_ent_ant =    l_ent_sant
        LET l_dia_sem_ant = l_dia_sem_sant 
    END IF 

{ 

     INITIALIZE l_dat_rom TO NULL

      SELECT MAX(dat_romaneio),
             WEEKDAY(MAX(dat_romaneio)) 
        INTO l_dat_rom,
             l_dia_sem_rom
        FROM ped_itens_fct_547
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ped_itens_fct_547.num_pedido
         AND prz_entrega = l_ent_ant

      IF l_dat_rom IS NOT NULL THEN 
         LET l_ent_ant = l_dat_rom
         LET l_dia_sem_ant = l_dia_sem_rom         
      END IF    
}

      IF l_dia_sem_atu <= l_dia_sem_ant THEN
         LET t_ped_itens_fct_547[p_ind].ies_semana = '   '
      ELSE
         LET l_qtd_dias = p_ped_itens.prz_entrega - l_ent_ant
      
         IF l_qtd_dias < 7 THEN 
            LET t_ped_itens_fct_547[p_ind].ies_semana = '***' 
         ELSE
            LET t_ped_itens_fct_547[p_ind].ies_semana = '   '
         END IF     
      END IF 
       
     LET p_ind = p_ind + 1
       
  END FOREACH
       
END FUNCTION
        
#-------------------------------------#
 FUNCTION pol0893_atualiza_ped_itens()
#-------------------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0893

   LET INT_FLAG = FALSE
   INPUT ARRAY t_ped_itens_fct_547  WITHOUT DEFAULTS FROM s_ped_itens_fct_547.*

      BEFORE FIELD ies_func    
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD ies_func
        IF t_ped_itens_fct_547[pa_curr].ies_func IS NOT NULL THEN
           IF t_ped_itens_fct_547[pa_curr].ies_func <> 'S' AND
              t_ped_itens_fct_547[pa_curr].ies_func <> 'C' AND 
              t_ped_itens_fct_547[pa_curr].ies_func <> 'N' THEN 
              ERROR 'INFORME (S)-PARA GERAR ROMANEIO, (C)-PARA CANCELAR PROGRAMACAO OU (N)'
              NEXT FIELD ies_func
           END IF   
           IF t_ped_itens_fct_547[pa_curr].ies_func = 'S' THEN 
              IF t_ped_itens_fct_547[pa_curr].qtd_solic = 0 THEN 
                 ERROR 'SEM ESTOQUE PARA GERAR ROMANEIO'
                 NEXT FIELD ies_func
              END IF 
           END IF 
        END IF    

      AFTER FIELD qtd_solic
         IF t_ped_itens_fct_547[pa_curr].qtd_solic > t_ped_itens_fct_547[pa_curr].qtd_estoque THEN 
            ERROR 'QTDE NAO PODE SER MAIOR QUE ESTOQUE'
            NEXT FIELD qtd_solic
         END IF    

         IF t_ped_itens_fct_547[pa_curr].qtd_solic > t_ped_itens_fct_547[pa_curr].qtd_gatilho THEN 
            ERROR 'QTDE NAO PODE SER MAIOR QUE SOLICITADA'
            NEXT FIELD qtd_solic
         END IF    

      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN")  OR  
         FGL_LASTKEY() = FGL_KEYVAL("RIGHT") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
         IF t_ped_itens_fct_547[pa_curr+1].dat_entrega IS NULL THEN 
            ERROR "Nao Existem mais Registros Nesta Direcao"
            NEXT FIELD ies_func
         END IF  
      END IF  

   END INPUT

   CALL log085_transacao("BEGIN")
   
   LET p_erro = 'N'
   LET p_num_om_ini = 0
   LET p_num_om_fim = 0
   
   FOR p_ind = 1 TO 500  
     IF t_ped_itens_fct_547[p_ind].dat_entrega IS NULL THEN
        EXIT FOR
     ELSE   
        IF t_ped_itens_fct_547[p_ind].ies_func = 'S' THEN 
           IF pol0893_gera_romaneio() THEN
           ELSE
              EXIT FOR
           END IF
        END IF    
        IF t_ped_itens_fct_547[p_ind].ies_func = 'C' THEN 
              CALL pol0893_cancela_gatilho()
        END IF    
     END IF   
   END FOR 

   IF p_erro = 'N' THEN 
      CALL log085_transacao("COMMIT")
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("GRAVACAO_1","PED_ITENS")
         CALL log085_transacao("ROLLBACK")
      END IF
   ELSE 
      CALL log085_transacao("ROLLBACK")
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0893_cria_tmp()
#--------------------------#
   DROP TABLE wped_rom;
   CREATE TABLE wped_rom
   (
    num_pedido         DECIMAL(6,0),
    num_sequencia      SMALLINT,
    qtd_saldo          DECIMAL(10,3),
    prz_entrega        DATE
   );
   IF sqlca.sqlcode <> 0 THEN
      DELETE FROM wped_rom;
   END IF

END FUNCTION

#--------------------------------#
 FUNCTION pol0893_gera_romaneio()
#--------------------------------#
   DEFINE l_ind               SMALLINT,
          l_num_om            LIKE ordem_montag_mest.num_om,
          l_num_lote          LIKE ordem_montag_mest.num_lote_om,
          l_peso_unit         LIKE item.pes_unit,
          l_cod_local_estoq   LIKE item.cod_local_estoq,
          l_qtd_padr_embal    LIKE item_embalagem.qtd_padr_embal,
          l_qtd_saldo_ped     LIKE ped_itens.qtd_pecas_solic,
          l_qtd_dif_sal       LIKE ped_itens.qtd_pecas_solic,
          l_num_reserva       INTEGER,
          l_num_sequencia     LIKE ped_itens.num_sequencia,
          l_num_transac       LIKE fat_nf_mestre.trans_nota_fiscal,
          l_pre_unit          LIKE ped_itens.pre_unit,
          l_cod_tip_carteira  LIKE pedidos.cod_tip_carteira,
          l_cont              SMALLINT,
          l_qtd_volume        LIKE ordem_montag_mest.qtd_volume_om,
          l_cod_embal_matriz  LIKE embalagem.cod_embal_matriz,
          l_cod_embal_int     LIKE item_embalagem.cod_embal,
          l_qtd_vol           CHAR(10)

   
   LET l_num_lote = 0
   LET l_cont     = 0
 
   SELECT MAX(num_lote_om)
     INTO l_num_lote
     FROM ordem_montag_lote
    WHERE cod_empresa = p_cod_empresa
         
   IF l_num_lote IS NULL THEN 
      LET l_num_lote = 1
   ELSE    
      LET l_num_lote = l_num_lote + 1
   END IF    
   
   SELECT num_ult_om
     INTO l_num_om
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF l_num_om IS NULL THEN
      LET l_num_om = 1
   ELSE
      LET l_num_om = l_num_om + 1
   END IF

   IF p_num_om_ini = 0 THEN 
      LET p_num_om_ini = l_num_om  
   END IF
   
   LET p_num_om_fim = l_num_om  
   
   SELECT pes_unit,
          cod_local_estoq
     INTO l_peso_unit,
          l_cod_local_estoq  
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_ped_itens_fct_547.cod_item         

   LET p_ordem_montag_item.qtd_volume_item = 0
   LET p_ordem_montag_item.cod_empresa     = p_cod_empresa
   LET p_ordem_montag_item.num_om          = l_num_om
   LET p_ordem_montag_item.num_pedido      = p_ped_itens_fct_547.num_pedido
   LET p_ordem_montag_item.cod_item        = p_ped_itens_fct_547.cod_item
   LET p_ordem_montag_item.qtd_reservada   = t_ped_itens_fct_547[p_ind].qtd_solic
   LET p_ordem_montag_item.ies_bonificacao = 'N'
   LET p_ordem_montag_item.pes_total_item  = t_ped_itens_fct_547[p_ind].qtd_solic * l_peso_unit

   LET l_pre_unit = 0 
   SELECT pre_unit 
     INTO l_pre_unit
     FROM desc_preco_item 
    WHERE cod_empresa = p_cod_empresa 
      AND cod_item    = p_ped_itens_fct_547.cod_item
      AND num_list_preco = 1

   IF l_pre_unit = 0 OR 
      l_pre_unit IS NULL THEN 

      SELECT MAX(a.trans_nota_fiscal)
        INTO l_num_transac
        FROM fat_nf_mestre a,
             fat_nf_item b
       WHERE a.empresa           = p_cod_empresa
         AND a.empresa           = b.empresa
         AND a.trans_nota_fiscal = b.trans_nota_fiscal
         AND b.pedido            = p_ped_itens_fct_547.num_pedido
         AND b.item              = p_ped_itens_fct_547.cod_item
         AND a.dat_hor_emissao   > '01/01/2010'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_mestre')
         RETURN FALSE
      END IF

      LET p_pre_unit = 0
              
      SELECT MAX(seq_item_pedido)
        INTO l_num_sequencia    
        FROM fat_nf_item
       WHERE empresa           = p_cod_empresa                 
         AND trans_nota_fiscal = l_num_transac  
         AND b.pedido          = p_ped_itens_fct_547.num_pedido  
         AND item              = p_ped_itens_fct_547.cod_item      
      
      IF l_num_sequencia IS NOT NULL THEN
         
         SELECT pre_unit_ped
           INTO l_pre_unit
           FROM ped_itens
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_ped_itens_fct_547.num_pedido
            AND num_sequencia = l_num_sequencia
         
         IF p_pre_unit IS NULL THEN
            LET p_pre_unit = 0
         END IF
      
      END IF
      
   END IF     

   SELECT num_sequencia,
          (qtd_pecas_solic-qtd_pecas_atend-qtd_pecas_cancel-qtd_pecas_romaneio)
     INTO l_num_sequencia,
          l_qtd_saldo_ped
     FROM ped_itens 
    WHERE cod_empresa = p_cod_empresa 
      AND num_pedido  = p_ped_itens_fct_547.num_pedido
      AND prz_entrega = t_ped_itens_fct_547[p_ind].dat_entrega

   IF SQLCA.sqlcode <> 0 THEN
      LET l_num_sequencia = 0 
      SELECT MAX(num_sequencia) 
        INTO l_num_sequencia
        FROM ped_itens 
       WHERE cod_empresa = p_cod_empresa 
         AND num_pedido  = p_ped_itens_fct_547.num_pedido
      IF l_num_sequencia = 0 THEN 
         LET l_num_sequencia = 1
      ELSE
         LET l_num_sequencia = l_num_sequencia + 1
      END IF       
        
      INSERT INTO ped_itens VALUES (p_cod_empresa,
                                    p_ped_itens_fct_547.num_pedido,
                                    l_num_sequencia,
                                    p_ped_itens_fct_547.cod_item,
                                    0,
                                    l_pre_unit,
                                    t_ped_itens_fct_547[p_ind].qtd_solic,
                                    0,
                                    0,
                                    0,
                                    t_ped_itens_fct_547[p_ind].dat_entrega,
                                    0,
                                    0,
                                    0,
                                    t_ped_itens_fct_547[p_ind].qtd_solic,
                                    0)
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","PED_ITENS")
         LET p_erro = 'S'
         RETURN FALSE
      END IF 
   ELSE
      IF l_qtd_saldo_ped < t_ped_itens_fct_547[p_ind].qtd_solic THEN 
         LET l_qtd_dif_sal = t_ped_itens_fct_547[p_ind].qtd_solic - l_qtd_saldo_ped 
      ELSE
         LET l_qtd_dif_sal = 0   
      END IF 

      IF l_pre_unit > 0 THEN
         UPDATE ped_itens
            SET qtd_pecas_romaneio  = qtd_pecas_romaneio + t_ped_itens_fct_547[p_ind].qtd_solic,
                qtd_pecas_solic     = qtd_pecas_solic + l_qtd_dif_sal,
                pre_unit            = l_pre_unit
          WHERE ped_itens.cod_empresa   = p_cod_empresa
            AND ped_itens.num_pedido    = p_ped_itens_fct_547.num_pedido
            AND ped_itens.num_sequencia = l_num_sequencia
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("ATUALIZA","PED_ITENS")
            LET p_erro = 'S'
            RETURN FALSE
         END IF 
      ELSE
         UPDATE ped_itens
            SET qtd_pecas_romaneio  = qtd_pecas_romaneio + t_ped_itens_fct_547[p_ind].qtd_solic,
                qtd_pecas_solic     = qtd_pecas_solic + l_qtd_dif_sal
          WHERE ped_itens.cod_empresa   = p_cod_empresa
            AND ped_itens.num_pedido    = p_ped_itens_fct_547.num_pedido
            AND ped_itens.num_sequencia = l_num_sequencia
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("ATUALIZA","PED_ITENS")
            LET p_erro = 'S'
            RETURN FALSE
         END IF 
      END IF    
   END IF 
            
   LET p_ordem_montag_item.num_sequencia   = l_num_sequencia

   INSERT INTO ordem_montag_item VALUES (p_ordem_montag_item.*)

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_ITEM")
      LET p_erro = 'S' 
      RETURN FALSE
   END IF

   INSERT INTO ordem_montag_embal 
      VALUES(p_cod_empresa,
             p_ordem_montag_item.num_om,
	           1,	
             p_ordem_montag_item.cod_item,
             0,
             0,
             0,
             0,
             'T',
             1,
             1,
             p_ordem_montag_item.qtd_reservada)

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_EMBAL")
      LET p_erro = 'S' 
      RETURN FALSE
   END IF
           
   SELECT cod_tip_carteira
     INTO l_cod_tip_carteira
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_fct_547.num_pedido
   
   LET p_ordem_montag_mest.cod_empresa   = p_cod_empresa
   LET p_ordem_montag_mest.num_om        = l_num_om
   LET p_ordem_montag_mest.num_lote_om   = l_num_lote
   LET p_ordem_montag_mest.ies_sit_om    = 'N'
   LET p_ordem_montag_mest.qtd_volume_om = t_ped_itens_fct_547[p_ind].qtd_solic
   LET p_ordem_montag_mest.dat_emis      = TODAY 

   INSERT INTO ordem_montag_mest VALUES (p_ordem_montag_mest.*)

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_MEST")
      LET p_erro = 'S' 
      RETURN FALSE
   END IF
   
   INSERT INTO om_list 
      VALUES (p_cod_empresa,
              p_ordem_montag_mest.num_om,
              p_ordem_montag_item.num_pedido,
              TODAY,
              p_user)

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("INCLUSAO","OM_LIST")
      LET p_erro = 'S' 
      RETURN FALSE
   END IF

   INSERT INTO ordem_montag_lote 
      VALUES(p_cod_empresa,
             l_num_lote,
             'N',
              '0',
              TODAY,
              0,
              l_cod_tip_carteira,
              NULL,
              0,
              0,
              0)

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_LOTE") 
      LET p_erro = 'S'
      RETURN FALSE
   END IF
# inicio insere reserva


          LET p_estoque_loc_reser.cod_empresa     = p_cod_empresa
          LET p_estoque_loc_reser.num_reserva     = 0
          LET p_estoque_loc_reser.cod_item        = p_ordem_montag_item.cod_item
          LET p_estoque_loc_reser.cod_local       = l_cod_local_estoq
          LET p_estoque_loc_reser.qtd_reservada   = p_ordem_montag_item.qtd_reservada
          LET p_estoque_loc_reser.ies_origem      = 'V'
          LET p_estoque_loc_reser.ies_situacao    = 'N'
          LET p_estoque_loc_reser.dat_solicitacao = TODAY
          LET p_estoque_loc_reser.qtd_atendida    = 0   

            WHENEVER ERROR CONTINUE
            INSERT INTO estoque_loc_reser 
               VALUES(p_estoque_loc_reser.*)
               
             WHENEVER ERROR STOP 
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","ESTOQUE_LOC_RESER")
               RETURN FALSE
            END IF


            LET p_ordem_montag_grade.cod_empresa   = p_cod_empresa
            LET p_ordem_montag_grade.num_om        = p_ordem_montag_mest.num_om
            LET p_ordem_montag_grade.num_pedido    = p_ordem_montag_item.num_pedido
            LET p_ordem_montag_grade.num_sequencia = p_ordem_montag_item.num_sequencia
            LET p_ordem_montag_grade.cod_item      = p_ordem_montag_item.cod_item
            LET p_ordem_montag_grade.qtd_reservada = p_ordem_montag_item.qtd_reservada
            LET p_ordem_montag_grade.num_reserva   = SQLCA.SQLERRD[2]

            WHENEVER ERROR CONTINUE
            INSERT INTO ordem_montag_grade
               VALUES(p_ordem_montag_grade.*)
            WHENEVER ERROR STOP 
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_GRADE")
               CALL log085_transacao("ROLLBACK")
               RETURN FALSE
            END IF


            LET p_ldi_om_grade_compl.empresa            = p_cod_empresa
            LET p_ldi_om_grade_compl.ord_montag         = p_ordem_montag_mest.num_om
            LET p_ldi_om_grade_compl.pedido             = p_ordem_montag_item.num_pedido
            LET p_ldi_om_grade_compl.sequencia_pedido   = p_ordem_montag_item.num_sequencia
            LET p_ldi_om_grade_compl.reserva            = p_ordem_montag_grade.num_reserva
            LET p_ldi_om_grade_compl.eh_bonific         = 'N'


            INSERT INTO ldi_om_grade_compl
               VALUES(p_ldi_om_grade_compl.*)
           
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("INCLUSAO","LDI_OM_GRADE_COMPL")
               RETURN FALSE
            END IF
            
            IF NOT pol893_ins_est_loc_reser_end() THEN
               RETURN FALSE
            END IF


# fim insere reserva
   UPDATE par_vdp
      SET num_ult_om = l_num_om
    WHERE cod_empresa = p_cod_empresa 
 
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("ALTERACAO","PAR_VDP") 
      LET p_erro = 'S'
      RETURN FALSE
   END IF
   
      LET p_audit_vdp.cod_empresa = p_cod_empresa
      LET p_audit_vdp.num_pedido = p_ped_itens_fct_547.num_pedido
      LET p_audit_vdp.tipo_informacao = 'M' 
      LET p_audit_vdp.tipo_movto = 'I'
      LET p_audit_vdp.texto = 'ALTERACAO SEQ ',l_num_sequencia,' QTD. RESERVADA ALTERADA PARA ',
                              t_ped_itens_fct_547[p_ind].qtd_solic
      LET p_audit_vdp.num_programa = 'POL0893'
      LET p_audit_vdp.data =  TODAY
      LET p_audit_vdp.hora =  TIME 
      LET p_audit_vdp.usuario = p_user
      LET p_audit_vdp.num_transacao = 0  
      INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","audit_vdp")
         LET p_erro = 'S'
         RETURN FALSE
      END IF
 
   UPDATE estoque
     SET qtd_reservada = qtd_reservada + t_ped_itens_fct_547[p_ind].qtd_solic
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = p_ped_itens_fct_547.cod_item
 
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("ALTERACAO","ESTOQUE") 
      LET p_erro = 'S'
      RETURN FALSE
   END IF

   UPDATE ped_itens_fct_547 SET qtd_romaneio = qtd_romaneio + t_ped_itens_fct_547[p_ind].qtd_solic,
                                dat_romaneio  = TODAY           
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_fct_547.num_pedido
      AND prz_entrega = t_ped_itens_fct_547[p_ind].dat_entrega

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("ALTERACAO","PED_ITENS_FCT") 
      LET p_erro = 'S'
      RETURN FALSE
   END IF

   RETURN TRUE
 
 END FUNCTION

#--------------------------------------#
FUNCTION pol893_ins_est_loc_reser_end()
#--------------------------------------#

   WHENEVER ERROR CONTINUE   
   
                                     
   INSERT INTO est_loc_reser_end                                         
      VALUES(p_cod_empresa,                                              
             p_ordem_montag_grade.num_reserva,                          
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
                                                                  
   WHENEVER ERROR STOP                                                   
   IF SQLCA.SQLCODE <> 0 THEN                                            
      CALL log003_err_sql("INCLUSAO","EST_LOC_RESER_END")                                                                                                      
      RETURN FALSE                                                       
   END IF                                                                
   
   RETURN TRUE
   
END FUNCTION
#------------------------------------#
 FUNCTION pol0893_cancela_gatilho()
#------------------------------------#

   UPDATE ped_itens_fct_547 SET qtd_romaneio = qtd_romaneio + t_ped_itens_fct_547[p_ind].qtd_gatilho,
                                dat_alteracao  = TODAY           
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ped_itens_fct_547.num_pedido
      AND prz_entrega = t_ped_itens_fct_547[p_ind].dat_entrega

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("ALTERACAO","PED_ITENS_FCT") 
      LET p_erro = 'S'
      RETURN FALSE
   END IF

   LET p_audit_vdp.cod_empresa = p_cod_empresa
   LET p_audit_vdp.num_pedido = p_ped_itens_fct_547.num_pedido
   LET p_audit_vdp.tipo_informacao = 'C' 
   LET p_audit_vdp.tipo_movto = 'I'
   LET p_audit_vdp.texto = 'QTD. CANCELADA NO GATILHO ped_itens_fct_547 ',
                           t_ped_itens_fct_547[p_ind].qtd_gatilho
   LET p_audit_vdp.num_programa = 'POL0893'
   LET p_audit_vdp.data =  TODAY
   LET p_audit_vdp.hora =  TIME 
   LET p_audit_vdp.usuario = p_user
   LET p_audit_vdp.num_transacao = 0  
   INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","audit_vdp")
      LET p_erro = 'S'
      RETURN FALSE
   END IF

 END FUNCTION

#------------------------------------#
 FUNCTION pol0893_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao            CHAR(20)
  IF p_ies_cons THEN
     LET p_ped_itens_fct_547r.* = p_ped_itens_fct_547.*
     WHILE TRUE
       CASE
         WHEN p_funcao = "SEGUINTE"
                         FETCH NEXT cq_ped_itens_fct_547 INTO 
                            p_ped_itens_fct_547.num_pedido,p_ped_itens_fct_547.cod_item,
                            p_cod_cliente 
         WHEN p_funcao = "ANTERIOR"
                         FETCH PREVIOUS cq_ped_itens_fct_547 INTO 
                            p_ped_itens_fct_547.num_pedido,p_ped_itens_fct_547.cod_item,
                            p_cod_cliente 
       END CASE
       IF SQLCA.sqlcode = NOTFOUND THEN
          ERROR " Nao existem mais itens nesta direcao "
          EXIT WHILE
       END IF
       WHENEVER ERROR CONTINUE  
       IF pol0893_verifica_pedido() THEN
       END IF
       CALL pol0893_prepara_dados_consulta()
       CALL pol0893_monta_dados_consulta()
       WHENEVER ERROR STOP
       IF SQLCA.sqlcode = 0    OR 
          SQLCA.sqlcode = -284 THEN
          IF p_ped_itens_fct_547.num_pedido = p_ped_itens_fct_547r.num_pedido AND
             p_ped_itens_fct_547.cod_item   = p_ped_itens_fct_547r.cod_item   THEN
          ELSE 
             CALL pol0893_exibe_dados()
             EXIT WHILE
          END IF
       END IF
     END WHILE
  ELSE 
     ERROR " Nao existe nenhuma consulta ativa "
  END IF
END FUNCTION

#-----------------------------#
 FUNCTION pol0893_exibe_dados()
#-----------------------------#
  DEFINE p_count SMALLINT
  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY p_cod_cliente TO cod_cliente
  DISPLAY p_cod_item_cliente TO p_cod_item_cliente
  CALL pol0893_verifica_cliente()
  DISPLAY BY NAME p_ped_itens_fct_547.num_pedido,
                  p_ped_itens_fct_547.cod_item

  CALL set_count(p_ind - 1)
  IF p_ind < 10 THEN 
     LET p_count = p_ind - 1
     FOR p_ind = 1 TO p_count
         DISPLAY t_ped_itens_fct_547[p_ind].* TO s_ped_itens_fct_547[p_ind].*
     END FOR
  ELSE 
     DISPLAY ARRAY t_ped_itens_fct_547 TO s_ped_itens_fct_547.*
     LET int_flag = 0
  END IF
  LET p_ind = p_ind - 1
END FUNCTION

#---------------------------------#
FUNCTION pol0893_verifica_cliente()
#---------------------------------#
   INITIALIZE m_nom_cliente TO NULL

   SELECT nom_cliente
     INTO m_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_cod_cliente

   DISPLAY m_nom_cliente TO nom_cliente

   IF SQLCA.SQLCODE <> 0        AND 
      p_cod_cliente IS NOT NULL AND
      p_cod_cliente <> " "      THEN
      ERROR "Cliente nao encontrado."
   END IF
END FUNCTION

#-----------------------#
 FUNCTION pol0893_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION