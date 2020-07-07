#-----------------------------------------------------------------#
# SISTEMA.: Levorin                                               #
# PROGRAMA: POL0615                                               #
# OBJETIVO: Libera ordens de producao   													#
# ALTERADO: THIAGO - EXIBIR CODIGO E DESCRIÇAO DE PAGAMENTO NA		#
#						TELA, TIRAR A LIBERAÇÃO AUTOMATICA QUE LIBERAVA TODOS	#
#						CORRIGIR PROBLEMA DE BLOQUEIO DO ULTIMO ITEM Q TRAVAVA#
#						INSERIR UM POPUP DE CLIENTES AO LIBERAR								#
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
    DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
           p_user                 LIKE usuario.nom_usuario,
           p_status               SMALLINT,
           p_count                SMALLINT,
           p_ies_cons             SMALLINT,
           l_ind                  INTEGER,
           p_msg                  CHAR(500)

           
    DEFINE p_ies_impressao        CHAR(001),
           g_ies_ambiente         CHAR(001),
           p_nom_arquivo          CHAR(100),
           p_nom_arquivo_back     CHAR(100),
           comando                CHAR(80),
           p_efetiva              CHAR(001),
           p_houve_erro           SMALLINT

    DEFINE g_ies_grafico          SMALLINT,
           g_usa_visualizador     SMALLINT 

    DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
    
    DEFINE p_ordem_montag_mest   RECORD LIKE ordem_montag_mest.*,
           p_ordem_montag_item   RECORD LIKE ordem_montag_item.*,
           p_ped_itens_desc      RECORD LIKE ped_itens_desc.*,
           p_lib_om_levorin      RECORD LIKE lib_om_levorin.*,
           p_msn                  CHAR(30),
           p_ind_t1               INTEGER,
           p_ind_t2               INTEGER, 
           p_grava                CHAR(1)
    #alteraçoes      	
    DEFINE p_ies_limite						CHAR(1),
    			 p_ies_duplic						CHAR(1),
    			 p_ies_data							CHAR(1)
    
    DEFINE p_dado 							ARRAY[5000] OF RECORD
    			 ies_limite						CHAR(1),
    			 ies_duplic						CHAR(1),
    			 ies_data							CHAR(1) 
    END RECORD
    #final alteraçao			 

END GLOBALS

#MODULARES
    DEFINE m_den_empresa          LIKE empresa.den_empresa
    DEFINE m_consulta_ativa       SMALLINT,
           m_informa_zoom         SMALLINT,
           m_count                SMALLINT,
           pa_curr                SMALLINT,
           sc_curr                SMALLINT,
           pa_curr2               SMALLINT,
           sc_curr2               SMALLINT,
           p_cod_item_pe          LIKE item.cod_item

    DEFINE sql_stmt               CHAR(500),
           m_last_row             SMALLINT,
           where_clause           CHAR(400)

    DEFINE m_comando              CHAR(080)

    DEFINE m_caminho              CHAR(150)

    DEFINE m_camh_help            CHAR(150),
           m_informou             SMALLINT 
		
  DEFINE p_om_lev             RECORD
         ies_acao                 CHAR(01),
         num_om                   LIKE ordem_montag_mest.num_om,
         dat_emissao              LIKE ordem_montag_mest.dat_emis,
         cod_cliente              LIKE pedidos.cod_cliente,
         nom_cliente              CHAR(19),
         val_om                   DECIMAL(13,2),
         #ies_limite               CHAR(01),
         #ies_duplic               CHAR(01),
         #ies_data                 CHAR(01)
         cod_cnd_pgto   					INTEGER   
  END RECORD

  DEFINE t_ped_ant            ARRAY[5000] OF RECORD
         num_pedido               DECIMAL(06,0)
  END RECORD

  DEFINE mr_tela             RECORD
         cod_empresa              CHAR(02),
         cod_tip_carteira         LIKE pedidos.cod_tip_carteira 
  END RECORD

  DEFINE ma_tela1            ARRAY[5000] OF RECORD
         ies_acao                 CHAR(01),
         num_om                   LIKE ordem_montag_mest.num_om,
         dat_emissao              LIKE ordem_montag_mest.dat_emis,
         cod_cliente              LIKE pedidos.cod_cliente,
         nom_cliente              CHAR(19),
         val_om                   DECIMAL(13,2),
         #ies_limite               CHAR(01),
         #ies_duplic               CHAR(01),
         #ies_data                 CHAR(01)
         cod_cnd_pgto   					INTEGER
  END RECORD

MAIN
	  LET p_versao = "pol0615-10.02.00"

    WHENEVER ANY ERROR CONTINUE

    CALL log1400_isolation()
    SET LOCK MODE TO WAIT 120

    WHENEVER ANY ERROR STOP

    DEFER INTERRUPT

    LET m_camh_help = log140_procura_caminho('pol0615.iem')

    OPTIONS

        PREVIOUS KEY control-b,
        NEXT     KEY control-n,
        HELP     FILE m_camh_help

   CALL log001_acessa_usuario("ESPEC999","")
         RETURNING p_status, p_cod_empresa, p_user

    IF  p_status = 0 THEN
        CALL pol0615_controle()
    END IF
END MAIN

#---------------------------#
FUNCTION pol0615_controle()
#---------------------------#
    CALL log006_exibe_teclas('01', p_versao)
    
    LET g_usa_visualizador = TRUE 
    
    SELECT den_empresa
      INTO m_den_empresa
      FROM empresa
     WHERE cod_empresa = p_cod_empresa
     
    LET m_caminho = log1300_procura_caminho('pol0615','pol0615')
    OPEN WINDOW w_pol0615 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Informa" "Informa carteira"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","pol0615","IN") THEN
         CALL pol0615_informar()
         CALL pol0615_cria_temp()
         CALL pol0615_monta_dados()
         NEXT OPTION "Seleciona" 
      END IF

    COMMAND "Todos" "Marca Todas Oms em tela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      CALL pol0615_marca_todos()
      IF log0040_confirm(10,15,"Libera todas? ") = FALSE THEN 
         NEXT OPTION "Seleciona"
      ELSE         
         NEXT OPTION "Efetiva"      
      END IF    
      
    COMMAND "Seleciona" "Seleciona Oms "
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      CALL pol0615_escolhe_oms()
      NEXT OPTION "Efetiva"
      
    COMMAND "Efetiva" "Efetiva"
      CALL pol0615_efetiva()
      ERROR 'Ordens liberadas com sucesso'
      NEXT OPTION "Fim"
 
    COMMAND "Credito" "Situacao de Clientes"
      CALL log120_procura_caminho("cre3880") RETURNING comando
      LET comando = comando CLIPPED
      RUN comando RETURNING p_status   
			       
    COMMAND "Romaneio" "Consulta/Modifica OM"
      CALL log120_procura_caminho("vdp1040") RETURNING comando
      LET comando = comando CLIPPED
      RUN comando RETURNING p_status   
      NEXT OPTION "Fim" 
      
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
      CALL pol0615_sobre()
         
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET INT_FLAG = 0
         
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  
  CLOSE WINDOW w_pol0615
END FUNCTION

#----------------------------#
 FUNCTION pol0615_cria_temp()
#----------------------------#

   WHENEVER ERROR CONTINUE

   DROP TABLE w_om_lev;

   CREATE TEMP TABLE w_om_lev
   (
     ies_acao                 CHAR(01),
     num_om                   DECIMAL(6,0),
     dat_emissao              DATE,
     cod_cliente              CHAR(15),
     nom_cliente              CHAR(19),
     val_om                   DECIMAL(13,2),
    #ies_limite               CHAR(01),
    # ies_duplic               CHAR(01),
    # ies_data                 CHAR(01)  
    cod_cnd_pgto   						INTEGER 
   );

   DELETE FROM w_om_lev   

END FUNCTION

#----------------------------#
 FUNCTION pol0615_informar()
#----------------------------#
DEFINE l_count    INTEGER

  INITIALIZE mr_tela.*,
             ma_tela1 TO NULL

  CALL log006_exibe_teclas("01 03 02 07",p_versao)
  CURRENT WINDOW IS w_pol0615
  CLEAR FORM

   INPUT mr_tela.cod_tip_carteira 
         WITHOUT DEFAULTS
    FROM cod_tip_carteira 

    BEFORE FIELD cod_tip_carteira 
       LET mr_tela.cod_empresa = p_cod_empresa
       DISPLAY mr_tela.cod_empresa TO  cod_empresa

    AFTER FIELD cod_tip_carteira 
      IF mr_tela.cod_tip_carteira  IS NOT NULL THEN
         SELECT * 
           FROM tipo_carteira
          WHERE cod_tip_carteira  = mr_tela.cod_tip_carteira 
         IF sqlca.sqlcode <> 0 THEN 
            ERROR "Carteira Nao Cadastrada   "
         END IF 
      END IF

  END INPUT

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_pol0615

  IF INT_FLAG THEN
     ERROR "Inclusao Cancelada. "
     LET INT_FLAG = FALSE
  END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0615_monta_dados()
#-----------------------------#

  DEFINE l_cod_item           LIKE ped_itens.cod_item,
         l_qtd_pecas_solic    LIKE ped_itens.qtd_pecas_solic,
         l_count              INTEGER,
         l_num_pedido         LIKE ped_itens.num_pedido,
         l_cod_tip_carteira   LIKE pedidos.cod_tip_carteira,
         l_cli_credito        RECORD LIKE cli_credito.*,
         l_par_vdp            RECORD LIKE par_vdp.*,
         l_credcad_cli        RECORD LIKE credcad_cli.*,
         l_cod_cliente        LIKE clientes.cod_cliente,
         l_cod_pais           LIKE cli_dist_geog.cod_pais,
         l_cod_cnd_pgto       LIKE pedidos.cod_cnd_pgto,
         l_val                DECIMAL(9,6),
         l_pre_tot_om         DECIMAL(15,2),
         l_pre_unit           DECIMAL(15,6),
         l_pct_desc_adic      DECIMAL(9,6),
         l_pct_desc_adici     DECIMAL(9,6) 
         

 DECLARE cq_om CURSOR FOR 
  SELECT * 
    FROM ordem_montag_mest  
   WHERE ies_sit_om = "B"
   ORDER BY  num_om 
 
  LET l_ind = 1 

 FOREACH cq_om INTO p_ordem_montag_mest.*

   SELECT MAX(num_pedido) 
     INTO l_num_pedido 
     FROM ordem_montag_item
    WHERE cod_empresa  =  p_ordem_montag_mest.cod_empresa
      AND num_om       =  p_ordem_montag_mest.num_om
   SELECT cod_tip_carteira,
          cod_cliente  
     INTO l_cod_tip_carteira,
          l_cod_cliente  
     FROM pedidos 
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = l_num_pedido
    IF mr_tela.cod_tip_carteira  IS NOT NULL THEN
       IF l_cod_tip_carteira <>  mr_tela.cod_tip_carteira THEN 
          CONTINUE FOREACH
       END IF 
    END IF                 

    LET p_om_lev.num_om        =  p_ordem_montag_mest.num_om
    LET p_om_lev.dat_emissao   =  p_ordem_montag_mest.dat_emis
    LET p_om_lev.cod_cliente   =  l_cod_cliente

    SELECT nom_cliente[1,18]
      INTO p_om_lev.nom_cliente
      FROM clientes
     WHERE cod_cliente =  l_cod_cliente

    LET l_pre_tot_om = 0 
    
    DECLARE cq_pre CURSOR FOR 
    SELECT *
      FROM ordem_montag_item  
     WHERE cod_empresa   = p_cod_empresa 
       AND num_om        = p_ordem_montag_mest.num_om
    FOREACH cq_pre INTO p_ordem_montag_item.* 
       LET l_val = 100
       LET l_pct_desc_adic = 0
       LET l_pre_unit      = 0     
    
      SELECT pre_unit
        INTO l_pre_unit
        FROM ped_itens 
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_ordem_montag_item.num_pedido
#         AND cod_item      = p_ordem_montag_item.cod_item
         AND num_sequencia = p_ordem_montag_item.num_sequencia

      SELECT pct_desc_adic
        INTO l_pct_desc_adic
        FROM pedidos 
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_ordem_montag_item.num_pedido
      IF l_pct_desc_adic > 0 THEN 
         LET l_val = l_val * ((100 - l_pct_desc_adic)/100)
      END IF                       

      SELECT pct_desc_adic
        INTO l_pct_desc_adici
        FROM ped_itens 
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_ordem_montag_item.num_pedido
         AND num_sequencia = p_ordem_montag_item.num_sequencia         
      IF l_pct_desc_adici > 0 THEN 
         LET l_val = l_val * ((100 - l_pct_desc_adici)/100)
      END IF                       

      SELECT *                
         INTO p_ped_itens_desc.* 
      FROM ped_itens_desc  
      WHERE cod_empresa   = p_cod_empresa 
        AND num_pedido    = p_ordem_montag_item.num_pedido        
        AND num_sequencia = 0 
      IF sqlca.sqlcode = 0 THEN  
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_1)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_2)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_3)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_4)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_5)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_6)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_7)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_8)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_9)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_10)/100)
      END IF

      SELECT *                
         INTO p_ped_itens_desc.* 
      FROM ped_itens_desc  
      WHERE cod_empresa   = p_cod_empresa 
        AND num_pedido    = p_ordem_montag_item.num_pedido        
        AND num_sequencia = p_ordem_montag_item.num_sequencia
      IF sqlca.sqlcode = 0 THEN  
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_1)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_2)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_3)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_4)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_5)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_6)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_7)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_8)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_9)/100)
         LET l_val = l_val * ((100 - p_ped_itens_desc.pct_desc_10)/100)
      END IF

      LET l_pre_unit = (l_pre_unit * l_val) / 100 
      LET l_pre_tot_om = l_pre_tot_om + (l_pre_unit * p_ordem_montag_item.qtd_reservada)
      
    END FOREACH

    LET p_om_lev.val_om = l_pre_tot_om
    
    LET p_om_lev.ies_acao = " "
         
    SELECT *
      INTO l_cli_credito.*
      FROM cli_credito
     WHERE cod_cliente =  l_cod_cliente

    SELECT *
      INTO l_credcad_cli.*
      FROM credcad_cli
     WHERE cod_cliente =  l_cod_cliente
     
    SELECT * 
      INTO l_par_vdp.*
      FROM par_vdp 
     WHERE cod_empresa = p_cod_empresa
     
    IF (l_cli_credito.val_ped_carteira + l_cli_credito.val_dup_aberto)  > l_cli_credito.val_limite_cred THEN      
       #LET p_om_lev.ies_limite = "S" 
       LET p_ies_limite = "S"
    ELSE
    		LET p_ies_limite = "N"
    END IF 
	
    IF l_cli_credito.qtd_dias_atr_dupl  > l_par_vdp.qtd_dias_atr_dupl OR 
       l_cli_credito.qtd_dias_atr_med  > l_par_vdp.qtd_dias_atr_med THEN      
       #LET p_om_lev.ies_duplic = "S" 
       LET p_ies_duplic = "S"
    ELSE
    	 LET p_ies_duplic = "N"
    END IF 
    
    IF l_credcad_cli.dat_credito_conced  <  TODAY THEN  
       #LET p_om_lev.ies_data = "S"
       LET p_ies_data ='S'
    ELSE
    	 LET p_ies_data = 'N'
    END IF 
    
    SELECT cod_pais
      INTO l_cod_pais
      FROM cli_dist_geog 
     WHERE cod_cliente = l_cod_cliente
    IF l_cod_pais <> "001" THEN 
       LET p_om_lev.ies_acao = "L"  
    END IF 

    SELECT MAX(num_pedido)
      INTO l_num_pedido
      FROM ordem_montag_item 
     WHERE cod_empresa   = p_cod_empresa 
       AND num_om        = p_ordem_montag_mest.num_om
      
    SELECT cod_cnd_pgto
      INTO l_cod_cnd_pgto
      FROM pedidos
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = l_num_pedido
   # IF l_cod_cnd_pgto = 1 OR      
   #    l_cod_cnd_pgto = 999 THEN
   #    LET p_om_lev.ies_acao = "L"  
   # END IF 
   
		SELECT p.cod_cnd_pgto
		INTO p_om_lev.cod_cnd_pgto
		FROM pedidos p
		WHERE p.cod_empresa=p_cod_empresa
		AND p.num_pedido =l_num_pedido
   		
		LET p_om_lev.ies_acao = NULL 
    INSERT INTO w_om_lev VALUES (p_om_lev.*)
 
 END FOREACH 
    
 DECLARE cq_tel CURSOR FOR 
 
   SELECT * 
     FROM w_om_lev
    ORDER BY nom_cliente,num_om 
 FOREACH cq_tel INTO p_om_lev.*

    LET ma_tela1[l_ind].num_om        =  p_om_lev.num_om
    LET ma_tela1[l_ind].dat_emissao   =  p_om_lev.dat_emissao
    LET ma_tela1[l_ind].cod_cliente   =  p_om_lev.cod_cliente
    LET ma_tela1[l_ind].nom_cliente   =  p_om_lev.nom_cliente
    LET ma_tela1[l_ind].val_om        =  p_om_lev.val_om
   # LET ma_tela1[l_ind].ies_limite    =  p_om_lev.ies_limite 
    LET ma_tela1[l_ind].ies_acao      =  p_om_lev.ies_acao 
   #LET ma_tela1[l_ind].ies_data      =  p_om_lev.ies_data
   # LET ma_tela1[l_ind].ies_duplic    =  p_om_lev.ies_duplic
    LET ma_tela1[l_ind].cod_cnd_pgto	=		p_om_lev.cod_cnd_pgto
		#alteraçoa
		LET p_dado[l_ind].ies_limite 			=		p_ies_limite
		LET p_dado[l_ind].ies_duplic			=		p_ies_duplic
		LET p_dado[l_ind].ies_data			=		p_ies_data
    #final alteraçoa
    LET p_lib_om_levorin.cod_empresa       = p_cod_empresa
    LET p_lib_om_levorin.num_om            = ma_tela1[l_ind].num_om
    LET p_lib_om_levorin.dat_ocor          = CURRENT
    LET p_lib_om_levorin.cod_usuario       = p_user
    LET p_lib_om_levorin.cod_cliente       = ma_tela1[l_ind].cod_cliente
    LET p_lib_om_levorin.val_om            = ma_tela1[l_ind].val_om      
    LET p_lib_om_levorin.cod_tip_carteira  = l_cod_tip_carteira
    
    {IF ma_tela1[l_ind].ies_limite = "S" THEN  ######
       LET p_lib_om_levorin.ies_bl_limit  = "S"
    ELSE
       LET p_lib_om_levorin.ies_bl_limit  = "N"
    END IF }
    LET p_lib_om_levorin.ies_bl_limit  = p_dado[l_ind].ies_limite   
    {IF ma_tela1[l_ind].ies_duplic = "S"  THEN 
       LET p_lib_om_levorin.ies_bl_dupl  = "S"
    ELSE
       LET p_lib_om_levorin.ies_bl_dupl  = "N"
    END IF  }
    LET p_lib_om_levorin.ies_bl_dupl = p_dado[l_ind].ies_duplic 
     
    {IF ma_tela1[l_ind].ies_data = "S"  THEN 
       LET p_lib_om_levorin.ies_bl_dat  = "S"
    ELSE
       LET p_lib_om_levorin.ies_bl_dat  = "N"
    END IF }   
		LET p_lib_om_levorin.ies_bl_dat =p_dado[l_ind].ies_data
		
    LET p_lib_om_levorin.ies_liber     = "C"

    INSERT INTO lib_om_levorin VALUES (p_lib_om_levorin.*) 
    
    LET l_ind = l_ind + 1 
        
 END FOREACH     
 CALL SET_COUNT(l_ind - 1)   
 DISPLAY ARRAY ma_tela1 TO s_itens.* 
		BEFORE ROW 
		CALL pol0615_exibe_denominacao(ma_tela1[ARR_CURR()].cod_cnd_pgto)
	END DISPLAY
		
		
END FUNCTION

#-----------------------------#
 FUNCTION pol0615_marca_todos()
#-----------------------------#

  FOR l_ind = 1 TO 5000   
    
    IF ma_tela1[l_ind].num_om IS NULL THEN
       EXIT FOR
    END IF    
 
    LET ma_tela1[l_ind].ies_acao    =  'L'
        
  END FOR 
        
 CALL SET_COUNT(l_ind - 1)   
 DISPLAY ARRAY ma_tela1 TO s_itens.*              
 
 END FUNCTION

#---------------------------------#
 FUNCTION pol0615_escolhe_oms()
#---------------------------------#

  CALL log006_exibe_teclas("02 03 07", p_versao)
  CURRENT WINDOW IS w_pol0615

  INPUT ARRAY ma_tela1 WITHOUT DEFAULTS
         FROM s_itens.*
#         ATTRIBUTE(MAXCOUNT=ARR_COUNT())
  				
      BEFORE ROW
         LET pa_curr = arr_curr()
         LET sc_curr = scr_line()
         CALL pol0615_exibe_denominacao(ma_tela1[pa_curr].cod_cnd_pgto)
        
         
         
      AFTER FIELD ies_acao  
         IF  ma_tela1[pa_curr].ies_acao IS NOT  NULL AND 
            ma_tela1[pa_curr].ies_acao <> "L" THEN 
		            ERROR "Campo com Preenchimento invalido"
		            NEXT FIELD ies_acao
         END IF   
         ON KEY(control-f)  
         	CALL pol0615_chama_cre3880(){<----------}
  END INPUT

  CALL SET_COUNT(l_ind - 1)

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_pol0615
        
 END FUNCTION

#-----------------------------#
 FUNCTION pol0615_efetiva()
#-----------------------------#
 DEFINE  l_num_pedido         LIKE ped_itens.num_pedido,
         l_cod_tip_carteira   LIKE pedidos.cod_tip_carteira
 
 FOR l_ind = 1 TO 5000   
    
    IF ma_tela1[l_ind].num_om IS NULL THEN
       EXIT FOR
    END IF  
      
   SELECT MAX(num_pedido) 
     INTO l_num_pedido 
     FROM ordem_montag_item
    WHERE cod_empresa  =  p_cod_empresa
      AND num_om       =  ma_tela1[l_ind].num_om
      
   SELECT cod_tip_carteira
     INTO l_cod_tip_carteira
     FROM pedidos 
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = l_num_pedido
     
    LET p_lib_om_levorin.cod_empresa       = p_cod_empresa
    LET p_lib_om_levorin.num_om            = ma_tela1[l_ind].num_om
    LET p_lib_om_levorin.dat_ocor          = CURRENT 
    LET p_lib_om_levorin.cod_usuario       = p_user
    LET p_lib_om_levorin.cod_cliente       = ma_tela1[l_ind].cod_cliente
    LET p_lib_om_levorin.val_om            = ma_tela1[l_ind].val_om      
    LET p_lib_om_levorin.cod_tip_carteira  = l_cod_tip_carteira
    
   { IF ma_tela1[l_ind].ies_limite = "S" THEN  
       LET p_lib_om_levorin.ies_bl_limit  = "S"
    ELSE
       LET p_lib_om_levorin.ies_bl_limit  = "N"
    END IF  }
    LET p_lib_om_levorin.ies_bl_limit = p_dado[l_ind].ies_limite
    
    {IF ma_tela1[l_ind].ies_duplic = "S"  THEN 
       LET p_lib_om_levorin.ies_bl_dupl  = "S"
    ELSE
       LET p_lib_om_levorin.ies_bl_dupl  = "N"
    END IF}
    LET p_lib_om_levorin.ies_bl_dupl = p_dado[l_ind].ies_duplic     
    {IF ma_tela1[l_ind].ies_data = "S"  THEN 
       LET p_lib_om_levorin.ies_bl_dat  = "S"
    ELSE
       LET p_lib_om_levorin.ies_bl_dat  = "N"
    END IF  }  

    IF ma_tela1[l_ind].ies_acao = "L" THEN

       UPDATE ordem_montag_mest SET ies_sit_om = "N" 
        WHERE num_om      = ma_tela1[l_ind].num_om
          AND cod_empresa = p_cod_empresa

       LET p_lib_om_levorin.ies_liber     = "S"

       INSERT INTO lib_om_levorin VALUES (p_lib_om_levorin.*) 
    END IF    
 END FOR 

 END FUNCTION
 
#-------------------------------#
 FUNCTION pol0615_chama_cre3880()
#-------------------------------#
	CALL log120_procura_caminho("cre3880") RETURNING comando
  LET comando = comando CLIPPED
  RUN comando RETURNING p_status
END FUNCTION 

#------------------------------------#
 FUNCTION pol0615_exibe_denominacao(l_cod_cnd_pgto)#
#------------------------------------#
DEFINE 	l_cod_cnd_pgto			LIKE cond_pgto.cod_cnd_pgto,
				l_den_pgto					LIKE cond_pgto.den_cnd_pgto
	SELECT c.den_cnd_pgto
	INTO l_den_pgto
	FROM cond_pgto c
	WHERE c.cod_cnd_pgto=l_cod_cnd_pgto
	
	IF SQLCA.sqlcode = 0 THEN 
		DISPLAY l_den_pgto TO den_cnd_pgto
	END IF
END FUNCTION
#-----------------------#
 FUNCTION pol0615_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION 

