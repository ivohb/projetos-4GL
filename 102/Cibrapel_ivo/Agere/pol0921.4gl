DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_val_tot              DECIMAL(15,2),
         p_pes_unit             DECIMAL(15,6),
         p_pre_unit             LIKE list_preco_item.pre_unit,
         p_cod_item_comp        LIKE item.cod_item, 
         p_qtd_saldo            DECIMAL(10,3),
         p_cod_emp1             LIKE empresa.cod_empresa,
         p_cod_emp2             LIKE empresa.cod_empresa,
         p_cod_emp3             LIKE empresa.cod_empresa,
         p_cod_emp4             LIKE empresa.cod_empresa,
         p_cod_emp5             LIKE empresa.cod_empresa,
         p_cod_empg1            LIKE empresa.cod_empresa,
         p_cod_empg2            LIKE empresa.cod_empresa,
         p_cod_empg3            LIKE empresa.cod_empresa,
         p_cod_empg4            LIKE empresa.cod_empresa,
         p_cod_empg5            LIKE empresa.cod_empresa,
         p_num_om               LIKE nf_item.num_om,
         p_ies_tip_controle     LIKE nat_operacao.ies_tip_controle,
         p_qtd_remessa          LIKE nf_item.qtd_item,  
         p_num_romaneio         INTEGER,
         p_des_alter            CHAR(40),       
         p_qtd_variacao         DECIMAL(07,0),
         p_dat_ini              DATE,
         p_dat_fim              DATE,
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_ies_cons             SMALLINT

   DEFINE p_tela         RECORD
          dat_ini      DATE,
          dat_fim      DATE
                     END RECORD 	
         
  DEFINE p_ped_itens           RECORD LIKE ped_itens.*
  DEFINE p_nf_item             RECORD LIKE nf_item.*
  DEFINE p_nf_item_1           RECORD LIKE nf_item.*
  DEFINE p_nf_mestre           RECORD LIKE nf_mestre.*
  DEFINE p_nf_mestre_1         RECORD LIKE nf_mestre.*
  DEFINE p_ped_itens_01        RECORD LIKE ped_itens.*
  DEFINE p_ped_at_885          RECORD LIKE ped_at_885.*
  DEFINE p_ped_itens_orig_885  RECORD LIKE ped_itens_orig_885.*
  DEFINE p_ped_itens_peso_885  RECORD LIKE ped_itens_peso_885.*
  DEFINE p_nota_itens_peso_885 RECORD LIKE nota_itens_peso_885.*
  DEFINE p_nota_mest_peso_885  RECORD LIKE nota_mest_peso_885.*
  DEFINE p_item_chapa_885      RECORD LIKE item_chapa_885.*
  DEFINE p_empresas_885        RECORD LIKE empresas_885.*             
  DEFINE p_pedidos             RECORD LIKE pedidos.*
  DEFINE p_desc_nat_oper_885   RECORD LIKE desc_nat_oper_885.*
  DEFINE p_canal_venda         RECORD LIKE canal_venda.*
  DEFINE p_item_bobina_885     RECORD LIKE item_bobina_885.*
  DEFINE p_item_chapa_885      RECORD LIKE item_chapa_885.*
  DEFINE p_item_caixa_885      RECORD LIKE item_caixa_885.*
  DEFINE p_tipo_pedido_885     RECORD LIKE tipo_pedido_885.*
  
  DEFINE p_nom_arquivo          CHAR(100),
         p_ies_impressao        CHAR(001),
         p_ok                   CHAR(001),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_prog_inex            CHAR(001),
         p_help                 CHAR(080),
         p_count_ped            INTEGER,
         p_ind                  INTEGER,
         p_cancel               INTEGER
  DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0921-05.10.08" #Favor nao alterar esta linha (SUPORTE)
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

  CALL log001_acessa_usuario("VDP","LIC_LIB")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN 
    CALL pol0921_controle()
  END IF
END MAIN

#---------------------------#
 FUNCTION pol0921_controle()
#---------------------------#
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol0921") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0921 AT 5,3  WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND  "Processar"    "Gera base para relatorios de pedidos "
      MESSAGE ""
      LET p_ind = 1
      DECLARE cq_emp CURSOR FOR 
        SELECT * 
          FROM empresas_885 
      FOREACH cq_emp INTO p_empresas_885.* 

		   # Refresh de tela
		   #lds CALL LOG_refresh_display()	

         IF p_ind = 1 THEN 
            LET p_cod_emp1 = p_empresas_885.cod_emp_oficial 
            LET p_cod_empg1 = p_empresas_885.cod_emp_gerencial
         ELSE   
            IF p_ind = 2 THEN 
               LET p_cod_emp2 = p_empresas_885.cod_emp_oficial 
               LET p_cod_empg2 = p_empresas_885.cod_emp_gerencial
            ELSE   
               IF p_ind = 3 THEN 
                  LET p_cod_emp3 = p_empresas_885.cod_emp_oficial
                  LET p_cod_empg3 = p_empresas_885.cod_emp_gerencial 
               ELSE   
                  IF p_ind = 4 THEN 
                     LET p_cod_emp4 = p_empresas_885.cod_emp_oficial
                     LET p_cod_empg4 = p_empresas_885.cod_emp_gerencial 
                  ELSE   
                     LET p_cod_emp5 = p_empresas_885.cod_emp_oficial
                     LET p_cod_empg5 = p_empresas_885.cod_emp_gerencial 
                  END IF 
               END IF 
            END IF 
         END IF 
         LET p_ind = p_ind + 1
      END FOREACH             

      LET p_tela.dat_fim = TODAY
      LET p_tela.dat_ini = p_tela.dat_fim - 10

      CALL pol0921_cria_tabela()
      CALL pol0921_limpa_pedidos()
      CALL pol0921_processa_pedidos()
      CALL pol0921_processa_notas()
      CALL pol0921_limpa_ped_at()
      ERROR 'Processamento Efetuado'
      NEXT OPTION "Fim"

    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
      
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0921
END FUNCTION

#------------------------------#
 FUNCTION pol0921_cria_tabela()
#------------------------------#

   WHENEVER ERROR CONTINUE
   DROP TABLE ped_del
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE ped_del
     (
      cod_empresa     CHAR(02),
      num_pedido      DECIMAL(6,0)
     )
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-ped_del")
   END IF

END FUNCTION

#--------------------------------#
 FUNCTION pol0921_limpa_pedidos()
#--------------------------------#
 DECLARE cq_del_ap CURSOR FOR
    SELECT * 
      FROM ped_at_885
   FOREACH  cq_del_ap INTO p_ped_at_885.*

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
   
     SELECT * 
       INTO p_empresas_885.*
       FROM empresas_885
      WHERE cod_emp_oficial = p_ped_at_885.cod_empresa
   
     DELETE FROM ped_itens_orig_885 
      WHERE cod_empresa  IN (p_empresas_885.cod_emp_oficial,p_empresas_885.cod_emp_gerencial)
        AND num_pedido  =  p_ped_at_885.num_pedido

     DELETE FROM ped_itens_peso_885 
      WHERE cod_empresa  IN (p_empresas_885.cod_emp_oficial,p_empresas_885.cod_emp_gerencial)
        AND num_pedido  =  p_ped_at_885.num_pedido
   END FOREACH  

END FUNCTION

#-----------------------------------#
 FUNCTION pol0921_processa_pedidos()
#-----------------------------------#

  DISPLAY 'PROCESSANDO PEDIDOS '  AT 7,10

  DECLARE cq_ped1 CURSOR FOR
   SELECT DISTINCT cod_empresa,num_pedido  
     FROM ped_at_885 
  FOREACH cq_ped1 INTO p_ped_at_885.cod_empresa,p_ped_at_885.num_pedido 

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

     SELECT * 
       INTO p_empresas_885.*
       FROM empresas_885
      WHERE cod_emp_oficial = p_ped_at_885.cod_empresa

     SELECT * 
       INTO p_pedidos.*
       FROM pedidos  
      WHERE cod_empresa  = p_empresas_885.cod_emp_gerencial  
        AND num_pedido   = p_ped_at_885.num_pedido

     INSERT INTO ped_del VALUES (p_empresas_885.cod_emp_oficial, p_pedidos.num_pedido)

      IF p_pedidos.ies_sit_pedido = '9' THEN 
         CONTINUE FOREACH
      END IF      

      IF p_pedidos.cod_tip_carteira = 90 OR 
         p_pedidos.cod_tip_carteira = 91 THEN 
         CONTINUE FOREACH
      END IF     
  
     DISPLAY "PEDIDO "  AT  8,6
     DISPLAY p_pedidos.num_pedido   AT  8,14
     
     LET p_ped_itens_orig_885.cod_empresa     = p_empresas_885.cod_emp_oficial
     LET p_ped_itens_orig_885.cod_cliente     = p_pedidos.cod_cliente
     LET p_ped_itens_orig_885.dat_emis_repres = p_pedidos.dat_emis_repres
     LET p_ped_itens_peso_885.cod_empresa     = p_empresas_885.cod_emp_oficial
     LET p_ped_itens_peso_885.cod_cliente     = p_pedidos.cod_cliente
     LET p_ped_itens_peso_885.dat_emis_repres = p_pedidos.dat_emis_repres

     
     SELECT den_cnd_pgto[1,15]
       INTO p_ped_itens_orig_885.den_cnd_pgto
       FROM cond_pgto
      WHERE cod_cnd_pgto =  p_pedidos.cod_cnd_pgto

      LET p_ped_itens_peso_885.den_cnd_pgto = p_ped_itens_orig_885.den_cnd_pgto  

     SELECT nom_reduzido
       INTO p_ped_itens_orig_885.nom_cliente
       FROM clientes
      WHERE cod_cliente =  p_pedidos.cod_cliente

      LET p_ped_itens_peso_885.nom_cliente = p_ped_itens_orig_885.nom_cliente  

      SELECT *
        INTO p_canal_venda.*
        FROM canal_venda
       WHERE cod_nivel_1 = p_pedidos.cod_repres 
         AND cod_nivel_2 = 0
         AND cod_nivel_3 = 0
         AND cod_nivel_4 = 0
         AND cod_nivel_5 = 0
         AND cod_nivel_6 = 0
         AND cod_nivel_7 = 0
      IF SQLCA.sqlcode <> 0 THEN
         SELECT *
           INTO p_canal_venda.*
           FROM canal_venda
          WHERE cod_nivel_2 = p_pedidos.cod_repres 
            AND cod_nivel_3 = 0
            AND cod_nivel_4 = 0
            AND cod_nivel_5 = 0
            AND cod_nivel_6 = 0
            AND cod_nivel_7 = 0
         IF SQLCA.sqlcode <> 0 THEN
            SELECT *
              INTO p_canal_venda.*
              FROM canal_venda
             WHERE cod_nivel_3 = p_pedidos.cod_repres 
               AND cod_nivel_4 = 0
               AND cod_nivel_5 = 0
               AND cod_nivel_6 = 0
               AND cod_nivel_7 = 0
            IF SQLCA.sqlcode <> 0 THEN
               SELECT *
                 INTO p_canal_venda.*
                 FROM canal_venda
                WHERE cod_nivel_4 = p_pedidos.cod_repres 
                  AND cod_nivel_5 = 0
                  AND cod_nivel_6 = 0
                  AND cod_nivel_7 = 0
               IF SQLCA.sqlcode <> 0 THEN
                  SELECT *
                    INTO p_canal_venda.*
                    FROM canal_venda
                   WHERE cod_nivel_5 = p_pedidos.cod_repres 
                     AND cod_nivel_6 = 0
                     AND cod_nivel_7 = 0
                  IF SQLCA.sqlcode <> 0 THEN
                     SELECT *
                       INTO p_canal_venda.*
                       FROM canal_venda
                      WHERE cod_nivel_6 = p_pedidos.cod_repres 
                        AND cod_nivel_7 = 0
                     IF SQLCA.sqlcode <> 0 THEN
                        SELECT *
                          INTO p_canal_venda.*
                          FROM canal_venda
                         WHERE cod_nivel_7 = p_pedidos.cod_repres 
                         IF SQLCA.sqlcode <> 0 THEN
                            LET p_ped_itens_orig_885.cod_gerente = 1000
                         ELSE    
                            IF p_canal_venda.cod_nivel_2 = 0 THEN 
                               LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_1
                            ELSE
                               LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_2
                            END IF
                         END IF      
                     ELSE
                        IF p_canal_venda.cod_nivel_2 = 0 THEN 
                           LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_1
                        ELSE
                           LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_2
                        END IF   
                     END IF
                  ELSE
                     IF p_canal_venda.cod_nivel_2 = 0 THEN 
                        LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_1
                     ELSE
                        LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_2
                     END IF   
                  END IF 
               ELSE
                  IF p_canal_venda.cod_nivel_2 = 0 THEN 
                     LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_1
                  ELSE
                     LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_2
                  END IF   
               END IF 
            ELSE
               IF p_canal_venda.cod_nivel_2 = 0 THEN 
                  LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_1
               ELSE
                  LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_2
               END IF   
            END IF 
         ELSE
            IF p_canal_venda.cod_nivel_2 = 0 THEN 
               LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_1
            ELSE
               LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_2
            END IF   
         END IF    
      ELSE
         LET p_ped_itens_orig_885.cod_gerente = p_canal_venda.cod_nivel_1
      END IF 

      LET p_ped_itens_peso_885.cod_gerente = p_ped_itens_orig_885.cod_gerente

     SELECT nom_guerra
       INTO p_ped_itens_orig_885.nom_repres 
       FROM representante
      WHERE cod_repres = p_pedidos.cod_repres 

     SELECT nom_guerra
       INTO p_ped_itens_orig_885.nom_gerente 
       FROM representante
      WHERE cod_repres = p_ped_itens_orig_885.cod_gerente

     LET p_ped_itens_peso_885.nom_gerente = p_ped_itens_orig_885.nom_gerente
     LET p_ped_itens_peso_885.nom_repres  = p_ped_itens_orig_885.nom_repres 
     
     SELECT *
       INTO p_tipo_pedido_885.*
       FROM tipo_pedido_885
      WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
        AND num_pedido  =  p_pedidos.num_pedido

     SELECT *
       INTO p_desc_nat_oper_885.*
       FROM desc_nat_oper_885
      WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
        AND num_pedido  =  p_pedidos.num_pedido
        
     IF SQLCA.sqlcode <> 0 THEN 
        CALL pol0921_processa_100_or()
        CALL pol0921_processa_100_sd()       
     ELSE
        IF p_desc_nat_oper_885.pct_desc_qtd   = 0 AND 
           p_desc_nat_oper_885.pct_desc_valor = 0 THEN 
           CALL pol0921_processa_100_or()
           CALL pol0921_processa_100_sd()
        ELSE
           IF p_desc_nat_oper_885.pct_desc_qtd > 0 THEN
              CALL pol0921_processa_qtd_or()
              CALL pol0921_processa_qtd_sd()
           ELSE   
              CALL pol0921_processa_val_or()
              CALL pol0921_processa_val_sd()
           END IF 
        END IF
     END IF
  END FOREACH              

END FUNCTION

#---------------------------------#
 FUNCTION pol0921_processa_100_or()
#---------------------------------#
  DECLARE cq_peio100 CURSOR FOR
    SELECT * 
      FROM ped_itens
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND num_pedido  = p_pedidos.num_pedido
  FOREACH cq_peio100 INTO p_ped_itens.*

   # Refresh de tela
   #lds CALL LOG_refresh_display()	

    SELECT * 
      INTO p_ped_itens_01.*
      FROM ped_itens 
     WHERE cod_empresa =  p_empresas_885.cod_emp_oficial
       AND num_pedido  =  p_ped_itens.num_pedido
       AND num_sequencia = p_ped_itens.num_sequencia
    IF SQLCA.sqlcode = 0 THEN
       LET p_ped_itens.pre_unit = p_ped_itens_01.pre_unit
    END IF

    INITIALIZE p_ped_itens_orig_885.den_comp TO NULL 

    DECLARE cq_es100or CURSOR FOR
      SELECT cod_item_compon
        FROM estrutura
       WHERE cod_empresa  = p_empresas_885.cod_emp_oficial
         AND cod_item_pai = p_ped_itens.cod_item  
      FOREACH cq_es100or INTO p_cod_item_comp

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

       SELECT den_comp
         INTO p_ped_itens_orig_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_cod_item_comp
       IF SQLCA.sqlcode = 0 THEN
          EXIT FOREACH
       END IF     
      END FOREACH  

    IF p_ped_itens_orig_885.den_comp IS NULL THEN 
       SELECT den_comp
         INTO p_ped_itens_orig_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_ped_itens.cod_item  
    END IF 

    IF p_ped_itens_orig_885.den_comp IS NULL THEN 
       SELECT composicao
         INTO p_ped_itens_orig_885.den_comp
         FROM ft_item_885
        WHERE cod_item    =  p_ped_itens.cod_item  
          AND cod_empresa =  p_empresas_885.cod_emp_gerencial 
    END IF                
             
    LET p_ped_itens_orig_885.cod_repres    = p_pedidos.cod_repres 
    LET p_ped_itens_orig_885.num_pedido    = p_pedidos.num_pedido
    LET p_ped_itens_orig_885.num_sequencia = p_ped_itens.num_sequencia
    LET p_ped_itens_orig_885.cod_item      = p_ped_itens.cod_item
    LET p_ped_itens_orig_885.pre_unit_qtd  = p_ped_itens.pre_unit
    LET p_ped_itens_orig_885.qtd_peca_solic  = p_ped_itens.qtd_pecas_solic 
    LET p_ped_itens_orig_885.qtd_peca_cancel = p_ped_itens.qtd_pecas_cancel
    LET p_ped_itens_orig_885.qtd_peca_atend  = p_ped_itens.qtd_pecas_atend
    LET p_ped_itens_orig_885.qtd_saldo     = (p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_cancel)
    LET p_ped_itens_orig_885.prz_entrega   = p_ped_itens.prz_entrega

    SELECT ies_tip_controle
      INTO p_ies_tip_controle
      FROM nat_operacao
     WHERE cod_nat_oper = p_pedidos.cod_nat_oper 

    IF p_ies_tip_controle = '1' THEN 
       LET p_qtd_remessa = 0
       SELECT sum(qtd_item)
         INTO p_qtd_remessa
         FROM nf_item a,
              nf_mestre b
        WHERE a.cod_empresa =   p_empresas_885.cod_emp_oficial
          AND a.cod_item    =   p_ped_itens.cod_item
          AND a.num_pedido  =   p_pedidos.num_pedido
          AND a.num_sequencia = p_ped_itens.num_sequencia
          AND a.cod_empresa   = b.cod_empresa
          AND a.num_nff       = b.num_nff
          AND b.ies_situacao  = 'N'
       IF p_qtd_remessa IS NULL THEN 
          LET p_qtd_remessa = 0
       END IF
       LET p_ped_itens_orig_885.qtd_saldo =  p_ped_itens_orig_885.qtd_saldo  -  p_qtd_remessa 
       LET p_ped_itens_orig_885.qtd_peca_atend = p_qtd_remessa
    END IF   

    SELECT cod_lin_prod,                     
           cod_lin_recei,                    
           cod_seg_merc,
           cod_cla_uso,
           pes_unit 
      INTO p_ped_itens_orig_885.cod_lin_prod,
           p_ped_itens_orig_885.cod_lin_recei,
           p_ped_itens_orig_885.cod_seg_merc,
           p_ped_itens_orig_885.cod_cla_uso,
           p_pes_unit
      FROM item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND cod_item    = p_ped_itens.cod_item 

    INITIALIZE p_ped_itens_orig_885.cod_item_cli TO NULL 

    SELECT cod_item_cliente 
      INTO p_ped_itens_orig_885.cod_item_cli
      FROM cliente_item
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND cod_item    = p_ped_itens.cod_item
       AND cod_cliente_matriz =  p_ped_itens_orig_885.cod_cliente

    IF p_tipo_pedido_885.tipo_pedido <> 2 THEN 
       IF p_tipo_pedido_885.tipo_pedido = 1 THEN 
          SELECT * 
            INTO p_item_bobina_885.*
            FROM item_bobina_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          LET p_ped_itens_orig_885.pct_lst_vnd =  p_ped_itens_orig_885.pre_unit_qtd / p_item_bobina_885.pre_unit_logix   
          LET p_ped_itens_orig_885.pre_unit_lista  =  p_item_bobina_885.pre_unit_logix
       ELSE
          SELECT * 
            INTO p_item_caixa_885.*
            FROM item_caixa_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          IF p_item_caixa_885.pes_unit > 0 THEN    
             LET p_pes_unit =    p_item_caixa_885.pes_unit   
          END IF 
          LET p_ped_itens_orig_885.pct_lst_vnd =  p_ped_itens_orig_885.pre_unit_qtd / p_item_caixa_885.pre_unit_logix      
          LET p_ped_itens_orig_885.pre_unit_lista  =  p_item_caixa_885.pre_unit_logix
       END IF       
       LET p_ped_itens_orig_885.peso_item = p_pes_unit *  p_ped_itens_orig_885.qtd_saldo
       LET p_val_tot = p_ped_itens_orig_885.qtd_saldo * p_ped_itens.pre_unit
       LET p_ped_itens_orig_885.pre_unit_peso =  p_val_tot / p_ped_itens_orig_885.peso_item
    ELSE   
       SELECT * 
         INTO p_item_chapa_885.*
         FROM item_chapa_885
        WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
          AND num_pedido  = p_ped_itens.num_pedido
          AND num_sequencia = p_ped_itens.num_sequencia
       LET p_pes_unit =    p_item_chapa_885.pes_unit / 1000 
       LET p_ped_itens_orig_885.peso_item = p_pes_unit *  p_ped_itens_orig_885.qtd_saldo
       LET p_val_tot = p_ped_itens_orig_885.qtd_saldo * p_ped_itens.pre_unit
       LET p_ped_itens_orig_885.pre_unit_peso =  p_val_tot / p_ped_itens_orig_885.peso_item
       LET p_ped_itens_orig_885.pct_lst_vnd =  p_item_chapa_885.pre_unit_lista / p_item_chapa_885.pre_unit_logix
       LET p_ped_itens_orig_885.pre_unit_lista  =  p_item_chapa_885.pre_unit_logix
    END IF 

    LET p_count_ped = 0 
    SELECT count(*) 
      INTO p_count_ped
      FROM ped_itens_orig_885 
     WHERE cod_empresa = p_ped_itens_orig_885.cod_empresa
       AND num_pedido  = p_ped_itens_orig_885.num_pedido
       AND num_sequencia = p_ped_itens_orig_885.num_sequencia 
    IF p_count_ped = 0 THEN     
       INSERT INTO ped_itens_orig_885 VALUES (p_ped_itens_orig_885.*)
    END IF 
   
  END FOREACH   
END FUNCTION
     
#---------------------------------#
 FUNCTION pol0921_processa_val_or()
#---------------------------------#
  DECLARE cq_peioval CURSOR FOR
    SELECT * 
      FROM ped_itens
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_peioval INTO p_ped_itens.*

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

    LET p_qtd_saldo = 0   
    SELECT *
      INTO p_ped_itens_01.*
      FROM ped_itens 
     WHERE cod_empresa =  p_empresas_885.cod_emp_oficial
       AND num_pedido  =  p_ped_itens.num_pedido
       AND num_sequencia = p_ped_itens.num_sequencia
    IF SQLCA.sqlcode = 0 THEN
    ELSE
       LET  p_ped_itens_01.pre_unit = 0       
    END IF
       
    LET p_ped_itens_orig_885.cod_repres    = p_pedidos.cod_repres 
    LET p_ped_itens_orig_885.num_pedido    = p_pedidos.num_pedido
    LET p_ped_itens_orig_885.num_sequencia = p_ped_itens.num_sequencia
    LET p_ped_itens_orig_885.cod_item      = p_ped_itens.cod_item
    LET p_ped_itens_orig_885.pre_unit_qtd  = p_ped_itens.pre_unit + p_ped_itens_01.pre_unit
    LET p_ped_itens_orig_885.qtd_saldo     = (p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_cancel)
    LET p_ped_itens_orig_885.qtd_peca_solic  = p_ped_itens.qtd_pecas_solic
    LET p_ped_itens_orig_885.qtd_peca_atend  = p_ped_itens.qtd_pecas_atend
    LET p_ped_itens_orig_885.qtd_peca_cancel = p_ped_itens.qtd_pecas_cancel
    LET p_ped_itens_orig_885.prz_entrega   = p_ped_itens.prz_entrega

    SELECT ies_tip_controle
      INTO p_ies_tip_controle
      FROM nat_operacao
     WHERE cod_nat_oper = p_pedidos.cod_nat_oper 

    IF p_ies_tip_controle = '1' THEN 
       LET p_qtd_remessa = 0
       SELECT sum(qtd_item)
         INTO p_qtd_remessa
         FROM nf_item a,
              nf_mestre b
        WHERE a.cod_empresa =   p_empresas_885.cod_emp_oficial
          AND a.cod_item    =   p_ped_itens.cod_item
          AND a.num_pedido  =   p_pedidos.num_pedido
          AND a.num_sequencia = p_ped_itens.num_sequencia
          AND a.cod_empresa   = b.cod_empresa
          AND a.num_nff       = b.num_nff
          AND b.ies_situacao  = 'N'
       IF p_qtd_remessa IS NULL THEN 
          LET p_qtd_remessa = 0
       END IF
       LET p_ped_itens_orig_885.qtd_saldo =  p_ped_itens_orig_885.qtd_saldo  -  p_qtd_remessa 
       LET p_ped_itens_orig_885.qtd_peca_atend = p_qtd_remessa
    END IF   
   
    SELECT cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso,
           pes_unit 
      INTO p_ped_itens_orig_885.cod_lin_prod,
           p_ped_itens_orig_885.cod_lin_recei,
           p_ped_itens_orig_885.cod_seg_merc,
           p_ped_itens_orig_885.cod_cla_uso,
           p_pes_unit
      FROM item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND cod_item    = p_ped_itens.cod_item 

    INITIALIZE p_ped_itens_orig_885.cod_item_cli TO NULL 

    SELECT cod_item_cliente 
      INTO p_ped_itens_orig_885.cod_item_cli
      FROM cliente_item
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND cod_item    = p_ped_itens.cod_item
       AND cod_cliente_matriz =  p_ped_itens_orig_885.cod_cliente

    INITIALIZE p_ped_itens_orig_885.den_comp TO NULL 

    DECLARE cq_esvalor CURSOR FOR
      SELECT cod_item_compon
        FROM estrutura
       WHERE cod_empresa  = p_empresas_885.cod_emp_oficial
         AND cod_item_pai = p_ped_itens.cod_item  
      FOREACH cq_esvalor INTO p_cod_item_comp

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

       SELECT den_comp
         INTO p_ped_itens_orig_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_cod_item_comp
       IF SQLCA.sqlcode = 0 THEN
          EXIT FOREACH
       END IF     
      END FOREACH  

    IF p_ped_itens_orig_885.den_comp IS NULL THEN 
       SELECT den_comp
         INTO p_ped_itens_orig_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_ped_itens.cod_item  
    END IF 

    IF p_ped_itens_orig_885.den_comp IS NULL THEN 
       SELECT composicao
         INTO p_ped_itens_orig_885.den_comp
         FROM ft_item_885
        WHERE cod_item    =  p_ped_itens.cod_item  
          AND cod_empresa =  p_empresas_885.cod_emp_gerencial 
    END IF                

    IF p_tipo_pedido_885.tipo_pedido <> 2 THEN 
       IF p_tipo_pedido_885.tipo_pedido = 1 THEN 
          SELECT * 
            INTO p_item_bobina_885.*
            FROM item_bobina_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          LET p_ped_itens_orig_885.pct_lst_vnd =  p_ped_itens_orig_885.pre_unit_qtd / p_item_bobina_885.pre_unit_logix   
          LET p_ped_itens_orig_885.pre_unit_lista  =  p_item_bobina_885.pre_unit_logix
       ELSE
          SELECT * 
            INTO p_item_caixa_885.*
            FROM item_caixa_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          IF p_item_caixa_885.pes_unit > 0 THEN    
             LET p_pes_unit =    p_item_caixa_885.pes_unit   
          END IF 
          LET p_ped_itens_orig_885.pct_lst_vnd =  p_ped_itens_orig_885.pre_unit_qtd / p_item_caixa_885.pre_unit_logix      
          LET p_ped_itens_orig_885.pre_unit_lista  =  p_item_caixa_885.pre_unit_logix
       END IF       
       LET p_ped_itens_orig_885.peso_item = p_pes_unit *  p_ped_itens_orig_885.qtd_saldo
       LET p_val_tot = p_ped_itens_orig_885.qtd_saldo * p_ped_itens_orig_885.pre_unit_qtd
       LET p_ped_itens_orig_885.pre_unit_peso =  p_val_tot / p_ped_itens_orig_885.peso_item
    ELSE   
       SELECT * 
         INTO p_item_chapa_885.*
         FROM item_chapa_885
        WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
          AND num_pedido  = p_ped_itens.num_pedido
          AND num_sequencia = p_ped_itens.num_sequencia
       LET p_pes_unit =    p_item_chapa_885.pes_unit / 1000 
       LET p_ped_itens_orig_885.peso_item = p_pes_unit *  p_ped_itens_orig_885.qtd_saldo
       LET p_val_tot = p_ped_itens_orig_885.qtd_saldo * p_ped_itens_orig_885.pre_unit_qtd
       LET p_ped_itens_orig_885.pre_unit_peso =  p_val_tot / p_ped_itens_orig_885.peso_item
       LET p_ped_itens_orig_885.pct_lst_vnd =  p_item_chapa_885.pre_unit_lista / p_item_chapa_885.pre_unit_logix
       LET p_ped_itens_orig_885.pre_unit_lista  =  p_item_chapa_885.pre_unit_logix
    END IF 

    LET p_count_ped = 0 
    SELECT count(*) 
      INTO p_count_ped
      FROM ped_itens_orig_885 
     WHERE cod_empresa = p_ped_itens_orig_885.cod_empresa
       AND num_pedido  = p_ped_itens_orig_885.num_pedido
       AND num_sequencia = p_ped_itens_orig_885.num_sequencia 
    IF p_count_ped = 0 THEN     
       INSERT INTO ped_itens_orig_885 VALUES (p_ped_itens_orig_885.*)
    END IF 

  END FOREACH   
END FUNCTION

#---------------------------------#
 FUNCTION pol0921_processa_qtd_or()
#---------------------------------#
  DECLARE cq_peioqtd CURSOR FOR
    SELECT * 
      FROM ped_itens
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_peioqtd INTO p_ped_itens.*

   # Refresh de tela
   #lds CALL LOG_refresh_display()	

    SELECT *
      INTO p_ped_itens_01.*
      FROM ped_itens 
     WHERE cod_empresa =  p_empresas_885.cod_emp_oficial
       AND num_pedido  =  p_ped_itens.num_pedido
       AND num_sequencia = p_ped_itens.num_sequencia
    IF SQLCA.sqlcode <> 0 THEN
       LET  p_ped_itens_01.qtd_pecas_solic = 0 
    END IF
       
    LET p_ped_itens_orig_885.cod_repres    = p_pedidos.cod_repres 
    LET p_ped_itens_orig_885.num_pedido    = p_pedidos.num_pedido
    LET p_ped_itens_orig_885.num_sequencia = p_ped_itens.num_sequencia
    LET p_ped_itens_orig_885.cod_item      = p_ped_itens.cod_item
    LET p_ped_itens_orig_885.pre_unit_qtd  = p_ped_itens.pre_unit 
    LET p_ped_itens_orig_885.qtd_saldo     = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_cancel     
    LET p_ped_itens_orig_885.qtd_peca_solic  = p_ped_itens.qtd_pecas_solic + p_ped_itens_01.qtd_pecas_solic
    LET p_ped_itens_orig_885.qtd_peca_atend  = p_ped_itens.qtd_pecas_atend
    LET p_ped_itens_orig_885.qtd_peca_cancel = p_ped_itens.qtd_pecas_cancel
    LET p_ped_itens_orig_885.prz_entrega   = p_ped_itens.prz_entrega

    SELECT ies_tip_controle
      INTO p_ies_tip_controle
      FROM nat_operacao
     WHERE cod_nat_oper = p_pedidos.cod_nat_oper 

    IF p_ies_tip_controle = '1' THEN 
       LET p_qtd_remessa = 0
       SELECT sum(qtd_item)
         INTO p_qtd_remessa
         FROM nf_item a,
              nf_mestre b
        WHERE a.cod_empresa =   p_empresas_885.cod_emp_oficial
          AND a.cod_item    =   p_ped_itens.cod_item
          AND a.num_pedido  =   p_pedidos.num_pedido
          AND a.num_sequencia = p_ped_itens.num_sequencia
          AND a.cod_empresa   = b.cod_empresa
          AND a.num_nff       = b.num_nff
          AND b.ies_situacao  = 'N'
       IF p_qtd_remessa IS NULL THEN 
          LET p_qtd_remessa = 0
       END IF
       LET p_ped_itens_orig_885.qtd_saldo =  p_ped_itens_orig_885.qtd_saldo  -  p_qtd_remessa 
       LET p_ped_itens_orig_885.qtd_peca_atend = p_qtd_remessa
    END IF   
    
    SELECT cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso,
           pes_unit 
      INTO p_ped_itens_orig_885.cod_lin_prod,
           p_ped_itens_orig_885.cod_lin_recei,
           p_ped_itens_orig_885.cod_seg_merc,
           p_ped_itens_orig_885.cod_cla_uso,
           p_pes_unit
      FROM item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND cod_item    = p_ped_itens.cod_item 

    INITIALIZE p_ped_itens_orig_885.cod_item_cli TO NULL 

    SELECT cod_item_cliente 
      INTO p_ped_itens_orig_885.cod_item_cli
      FROM cliente_item
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND cod_item    = p_ped_itens.cod_item
       AND cod_cliente_matriz =  p_ped_itens_orig_885.cod_cliente

    INITIALIZE p_ped_itens_orig_885.den_comp TO NULL 

    DECLARE cq_esqtdor CURSOR FOR
      SELECT cod_item_compon
        FROM estrutura
       WHERE cod_empresa  = p_empresas_885.cod_emp_oficial
         AND cod_item_pai = p_ped_itens.cod_item  
      FOREACH cq_esqtdor INTO p_cod_item_comp

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

       SELECT den_comp
         INTO p_ped_itens_orig_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_cod_item_comp
       IF SQLCA.sqlcode = 0 THEN
          EXIT FOREACH
       END IF     
      END FOREACH  

    IF p_ped_itens_orig_885.den_comp IS NULL THEN 
       SELECT den_comp
         INTO p_ped_itens_orig_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_ped_itens.cod_item  
    END IF 

    IF p_ped_itens_orig_885.den_comp IS NULL THEN 
       SELECT composicao
         INTO p_ped_itens_orig_885.den_comp
         FROM ft_item_885
        WHERE cod_item    =  p_ped_itens.cod_item  
          AND cod_empresa =  p_empresas_885.cod_emp_gerencial 
    END IF                

    IF p_tipo_pedido_885.tipo_pedido <> 2 THEN 
       IF p_tipo_pedido_885.tipo_pedido = 1 THEN 
          SELECT * 
            INTO p_item_bobina_885.*
            FROM item_bobina_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          LET p_ped_itens_orig_885.pct_lst_vnd =  p_ped_itens_orig_885.pre_unit_qtd / p_item_bobina_885.pre_unit_logix   
          LET p_ped_itens_orig_885.pre_unit_lista  =  p_item_bobina_885.pre_unit_logix
       ELSE
          SELECT * 
            INTO p_item_caixa_885.*
            FROM item_caixa_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          IF p_item_caixa_885.pes_unit > 0 THEN    
             LET p_pes_unit =    p_item_caixa_885.pes_unit   
          END IF 
          LET p_ped_itens_orig_885.pct_lst_vnd =  p_ped_itens_orig_885.pre_unit_qtd / p_item_caixa_885.pre_unit_logix      
          LET p_ped_itens_orig_885.pre_unit_lista  =  p_item_caixa_885.pre_unit_logix
       END IF       
       LET p_ped_itens_orig_885.peso_item = p_pes_unit *  p_ped_itens_orig_885.qtd_saldo
       LET p_val_tot = p_ped_itens_orig_885.qtd_saldo * p_ped_itens_orig_885.pre_unit_qtd
       LET p_ped_itens_orig_885.pre_unit_peso =  p_val_tot / p_ped_itens_orig_885.peso_item
    ELSE   
       SELECT * 
         INTO p_item_chapa_885.*
         FROM item_chapa_885
        WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
          AND num_pedido  = p_ped_itens.num_pedido
          AND num_sequencia = p_ped_itens.num_sequencia
       LET p_pes_unit =    p_item_chapa_885.pes_unit / 1000 
       LET p_ped_itens_orig_885.peso_item = p_pes_unit *  p_ped_itens_orig_885.qtd_saldo
       LET p_val_tot = p_ped_itens_orig_885.qtd_saldo * p_ped_itens_orig_885.pre_unit_qtd
       LET p_ped_itens_orig_885.pre_unit_peso =  p_val_tot / p_ped_itens_orig_885.peso_item
       LET p_ped_itens_orig_885.pct_lst_vnd =  p_item_chapa_885.pre_unit_lista / p_item_chapa_885.pre_unit_logix
       LET p_ped_itens_orig_885.pre_unit_lista  =  p_item_chapa_885.pre_unit_logix
    END IF 

    LET p_count_ped = 0 
    SELECT count(*) 
      INTO p_count_ped
      FROM ped_itens_orig_885 
     WHERE cod_empresa = p_ped_itens_orig_885.cod_empresa
       AND num_pedido  = p_ped_itens_orig_885.num_pedido
       AND num_sequencia = p_ped_itens_orig_885.num_sequencia 
    IF p_count_ped = 0 THEN     
       INSERT INTO ped_itens_orig_885 VALUES (p_ped_itens_orig_885.*)
    END IF 

  END FOREACH   
END FUNCTION

#---------------------------------#
 FUNCTION pol0921_processa_100_sd()
#---------------------------------#
  DECLARE cq_peis100 CURSOR FOR
    SELECT * 
      FROM ped_itens
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND num_pedido  = p_pedidos.num_pedido
  FOREACH cq_peis100 INTO p_ped_itens.*

   # Refresh de tela
   #lds CALL LOG_refresh_display()	

    SELECT * 
      INTO p_ped_itens_01.*
      FROM ped_itens 
     WHERE cod_empresa =  p_empresas_885.cod_emp_oficial
       AND num_pedido  =  p_ped_itens.num_pedido
       AND num_sequencia = p_ped_itens.num_sequencia
    IF SQLCA.sqlcode = 0 THEN
       IF (p_ped_itens_01.qtd_pecas_solic - p_ped_itens_01.qtd_pecas_atend - p_ped_itens_01.qtd_pecas_cancel) <= 0 THEN
          CONTINUE FOREACH
       ELSE
          LET p_ped_itens.pre_unit = p_ped_itens_01.pre_unit
       END IF   
    END IF
          
    LET p_ped_itens_peso_885.cod_repres    = p_pedidos.cod_repres 
    LET p_ped_itens_peso_885.num_pedido    = p_pedidos.num_pedido
    LET p_ped_itens_peso_885.num_sequencia = p_ped_itens.num_sequencia
    LET p_ped_itens_peso_885.cod_item      = p_ped_itens.cod_item
    LET p_ped_itens_peso_885.pre_unit_qtd  = p_ped_itens.pre_unit
    LET p_ped_itens_peso_885.qtd_saldo     = (p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel)
    LET p_ped_itens_peso_885.qtd_peca_solic  = p_ped_itens.qtd_pecas_solic 
    LET p_ped_itens_peso_885.qtd_peca_cancel = p_ped_itens.qtd_pecas_cancel
    LET p_ped_itens_peso_885.qtd_peca_atend  = p_ped_itens.qtd_pecas_atend
    LET p_ped_itens_peso_885.prz_entrega   = p_ped_itens.prz_entrega

    SELECT ies_tip_controle
      INTO p_ies_tip_controle
      FROM nat_operacao
     WHERE cod_nat_oper = p_pedidos.cod_nat_oper 

    IF p_ies_tip_controle = '1' THEN 
       LET p_qtd_remessa = 0
       SELECT sum(qtd_item)
         INTO p_qtd_remessa
         FROM nf_item a,
              nf_mestre b
        WHERE a.cod_empresa =   p_empresas_885.cod_emp_oficial
          AND a.cod_item    =   p_ped_itens.cod_item
          AND a.num_pedido  =   p_pedidos.num_pedido
          AND a.num_sequencia = p_ped_itens.num_sequencia
          AND a.cod_empresa   = b.cod_empresa
          AND a.num_nff       = b.num_nff
          AND b.ies_situacao  = 'N'
       IF p_qtd_remessa IS NULL THEN 
          LET p_qtd_remessa = 0
       END IF
       LET p_ped_itens_peso_885.qtd_saldo =  p_ped_itens_peso_885.qtd_saldo  -  p_qtd_remessa 
       LET p_ped_itens_peso_885.qtd_peca_atend = p_qtd_remessa
    END IF   
   
    SELECT cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso,
           pes_unit 
      INTO p_ped_itens_peso_885.cod_lin_prod,
           p_ped_itens_peso_885.cod_lin_recei,
           p_ped_itens_peso_885.cod_seg_merc,
           p_ped_itens_peso_885.cod_cla_uso,
           p_pes_unit
      FROM item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND cod_item    = p_ped_itens.cod_item 

    INITIALIZE p_ped_itens_peso_885.cod_item_cli TO NULL 

    SELECT cod_item_cliente 
      INTO p_ped_itens_peso_885.cod_item_cli
      FROM cliente_item
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND cod_item    = p_ped_itens.cod_item
       AND cod_cliente_matriz =  p_ped_itens_peso_885.cod_cliente

    INITIALIZE p_ped_itens_peso_885.den_comp TO NULL 

    DECLARE cq_es100sd CURSOR FOR
      SELECT cod_item_compon
        FROM estrutura
       WHERE cod_empresa  = p_empresas_885.cod_emp_oficial
         AND cod_item_pai = p_ped_itens.cod_item  
      FOREACH cq_es100sd INTO p_cod_item_comp

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

       SELECT den_comp
         INTO p_ped_itens_peso_885.den_comp
         FROM composicao_chapa_885         
        WHERE cod_item =  p_cod_item_comp
       IF SQLCA.sqlcode = 0 THEN
          EXIT FOREACH
       END IF     
      END FOREACH  

    IF p_ped_itens_peso_885.den_comp IS NULL THEN 
       SELECT den_comp
         INTO p_ped_itens_peso_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_ped_itens.cod_item  
    END IF 

    IF p_ped_itens_peso_885.den_comp IS NULL THEN 
       SELECT composicao
         INTO p_ped_itens_peso_885.den_comp
         FROM ft_item_885
        WHERE cod_item    =  p_ped_itens.cod_item  
          AND cod_empresa =  p_empresas_885.cod_emp_gerencial 
    END IF                

    IF p_tipo_pedido_885.tipo_pedido <> 2 THEN 
       IF p_tipo_pedido_885.tipo_pedido = 1 THEN 
          SELECT * 
            INTO p_item_bobina_885.*
            FROM item_bobina_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          LET p_ped_itens_peso_885.pct_lst_vnd =  p_ped_itens_peso_885.pre_unit_qtd / p_item_bobina_885.pre_unit_logix   
          LET p_ped_itens_peso_885.pre_unit_lista  =  p_item_bobina_885.pre_unit_logix
       ELSE
          SELECT * 
            INTO p_item_caixa_885.*
            FROM item_caixa_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          IF p_item_caixa_885.pes_unit > 0 THEN    
             LET p_pes_unit =    p_item_caixa_885.pes_unit   
          END IF 
          LET p_ped_itens_peso_885.pct_lst_vnd =  p_ped_itens_peso_885.pre_unit_qtd / p_item_caixa_885.pre_unit_logix      
          LET p_ped_itens_peso_885.pre_unit_lista  =  p_item_caixa_885.pre_unit_logix
       END IF       
       LET p_ped_itens_peso_885.peso_item = p_pes_unit *  p_ped_itens_peso_885.qtd_saldo
       LET p_val_tot = p_ped_itens_peso_885.qtd_saldo * p_ped_itens.pre_unit
       LET p_ped_itens_peso_885.pre_unit_peso =  p_val_tot / p_ped_itens_peso_885.peso_item
    ELSE   
       SELECT * 
         INTO p_item_chapa_885.*
         FROM item_chapa_885
        WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
          AND num_pedido  = p_ped_itens.num_pedido
          AND num_sequencia = p_ped_itens.num_sequencia
       LET p_pes_unit =    p_item_chapa_885.pes_unit / 1000 
       LET p_ped_itens_peso_885.peso_item = p_pes_unit *  p_ped_itens_peso_885.qtd_saldo
       LET p_val_tot = p_ped_itens_peso_885.qtd_saldo * p_ped_itens.pre_unit
       LET p_ped_itens_peso_885.pre_unit_peso =  p_val_tot / p_ped_itens_peso_885.peso_item
       LET p_ped_itens_peso_885.pct_lst_vnd =  p_item_chapa_885.pre_unit_lista / p_item_chapa_885.pre_unit_logix
       LET p_ped_itens_peso_885.pre_unit_lista  =  p_item_chapa_885.pre_unit_logix
    END IF 
    
    INSERT INTO ped_itens_peso_885 VALUES (p_ped_itens_peso_885.*)
    
  END FOREACH   
END FUNCTION
     
#---------------------------------#
 FUNCTION pol0921_processa_val_sd()
#---------------------------------#
  DECLARE cq_peisval CURSOR FOR
    SELECT * 
      FROM ped_itens
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_peisval INTO p_ped_itens.*

   # Refresh de tela
   #lds CALL LOG_refresh_display()	

    LET p_qtd_saldo = 0   
    SELECT *
      INTO p_ped_itens_01.*
      FROM ped_itens 
     WHERE cod_empresa =  p_empresas_885.cod_emp_oficial
       AND num_pedido  =  p_ped_itens.num_pedido
       AND num_sequencia = p_ped_itens.num_sequencia
    IF SQLCA.sqlcode = 0 THEN
       IF (p_ped_itens_01.qtd_pecas_solic - p_ped_itens_01.qtd_pecas_atend - p_ped_itens_01.qtd_pecas_cancel) <= 0 THEN
          CONTINUE FOREACH
       END IF
    ELSE
       LET  p_ped_itens_01.pre_unit = 0       
    END IF
       
    LET p_ped_itens_peso_885.cod_repres    = p_pedidos.cod_repres 
    LET p_ped_itens_peso_885.num_pedido    = p_pedidos.num_pedido
    LET p_ped_itens_peso_885.num_sequencia = p_ped_itens.num_sequencia
    LET p_ped_itens_peso_885.cod_item      = p_ped_itens.cod_item
    LET p_ped_itens_peso_885.pre_unit_qtd  = p_ped_itens.pre_unit + p_ped_itens_01.pre_unit
    LET p_ped_itens_peso_885.qtd_saldo     = (p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel)
    LET p_ped_itens_peso_885.qtd_peca_solic  = p_ped_itens.qtd_pecas_solic
    LET p_ped_itens_peso_885.qtd_peca_atend  = p_ped_itens.qtd_pecas_atend
    LET p_ped_itens_peso_885.qtd_peca_cancel = p_ped_itens.qtd_pecas_cancel
    LET p_ped_itens_peso_885.prz_entrega   = p_ped_itens.prz_entrega

    SELECT ies_tip_controle
      INTO p_ies_tip_controle
      FROM nat_operacao
     WHERE cod_nat_oper = p_pedidos.cod_nat_oper 

    IF p_ies_tip_controle = '1' THEN 
       LET p_qtd_remessa = 0
       SELECT sum(qtd_item)
         INTO p_qtd_remessa
         FROM nf_item a,
              nf_mestre b
        WHERE a.cod_empresa =   p_empresas_885.cod_emp_oficial
          AND a.cod_item    =   p_ped_itens.cod_item
          AND a.num_pedido  =   p_pedidos.num_pedido
          AND a.num_sequencia = p_ped_itens.num_sequencia
          AND a.cod_empresa   = b.cod_empresa
          AND a.num_nff       = b.num_nff
          AND b.ies_situacao  = 'N'
       IF p_qtd_remessa IS NULL THEN 
          LET p_qtd_remessa = 0
       END IF
       LET p_ped_itens_peso_885.qtd_saldo =  p_ped_itens_peso_885.qtd_saldo  -  p_qtd_remessa 
       LET p_ped_itens_peso_885.qtd_peca_atend = p_qtd_remessa
    END IF   

    SELECT cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso,
           pes_unit 
      INTO p_ped_itens_peso_885.cod_lin_prod,
           p_ped_itens_peso_885.cod_lin_recei,
           p_ped_itens_peso_885.cod_seg_merc,
           p_ped_itens_peso_885.cod_cla_uso,
           p_pes_unit
      FROM item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND cod_item    = p_ped_itens.cod_item 

    INITIALIZE p_ped_itens_peso_885.cod_item_cli TO NULL 

    SELECT cod_item_cliente 
      INTO p_ped_itens_peso_885.cod_item_cli
      FROM cliente_item
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND cod_item    = p_ped_itens.cod_item
       AND cod_cliente_matriz =  p_ped_itens_peso_885.cod_cliente

    INITIALIZE p_ped_itens_peso_885.den_comp TO NULL 

    DECLARE cq_esvalsd CURSOR FOR
      SELECT cod_item_compon
        FROM estrutura
       WHERE cod_empresa  = p_empresas_885.cod_emp_oficial
         AND cod_item_pai = p_ped_itens.cod_item  

      FOREACH cq_esvalsd INTO p_cod_item_comp

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

       SELECT den_comp
         INTO p_ped_itens_peso_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_ped_itens.cod_item  
       IF SQLCA.sqlcode = 0 THEN
          EXIT FOREACH
       END IF     
      END FOREACH  

    IF p_ped_itens_peso_885.den_comp IS NULL THEN 
       SELECT den_comp
         INTO p_ped_itens_peso_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_ped_itens.cod_item  
    END IF 

    IF p_ped_itens_peso_885.den_comp IS NULL THEN 
       SELECT composicao
         INTO p_ped_itens_peso_885.den_comp
         FROM ft_item_885
        WHERE cod_item    =  p_ped_itens.cod_item
          AND cod_empresa =  p_empresas_885.cod_emp_gerencial 
    END IF                

    IF p_tipo_pedido_885.tipo_pedido <> 2 THEN 
       IF p_tipo_pedido_885.tipo_pedido = 1 THEN 
          SELECT * 
            INTO p_item_bobina_885.*
            FROM item_bobina_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          LET p_ped_itens_peso_885.pct_lst_vnd =  p_ped_itens_peso_885.pre_unit_qtd / p_item_bobina_885.pre_unit_logix   
          LET p_ped_itens_peso_885.pre_unit_lista  =  p_item_bobina_885.pre_unit_logix
       ELSE
          SELECT * 
            INTO p_item_caixa_885.*
            FROM item_caixa_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          IF p_item_caixa_885.pes_unit > 0 THEN    
             LET p_pes_unit =    p_item_caixa_885.pes_unit   
          END IF 
          LET p_ped_itens_peso_885.pct_lst_vnd =  p_ped_itens_peso_885.pre_unit_qtd / p_item_caixa_885.pre_unit_logix      
          LET p_ped_itens_peso_885.pre_unit_lista  =  p_item_caixa_885.pre_unit_logix
       END IF       
       LET p_ped_itens_peso_885.peso_item = p_pes_unit *  p_ped_itens_peso_885.qtd_saldo
       LET p_val_tot = p_ped_itens_peso_885.qtd_saldo * p_ped_itens_peso_885.pre_unit_qtd
       LET p_ped_itens_peso_885.pre_unit_peso =  p_val_tot / p_ped_itens_peso_885.peso_item
    ELSE   
       SELECT * 
         INTO p_item_chapa_885.*
         FROM item_chapa_885
        WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
          AND num_pedido  = p_ped_itens.num_pedido
          AND num_sequencia = p_ped_itens.num_sequencia
       LET p_pes_unit =    p_item_chapa_885.pes_unit / 1000 
       LET p_ped_itens_peso_885.peso_item = p_pes_unit *  p_ped_itens_peso_885.qtd_saldo
       LET p_val_tot = p_ped_itens_peso_885.qtd_saldo * p_ped_itens_peso_885.pre_unit_qtd
       LET p_ped_itens_peso_885.pre_unit_peso = p_val_tot / p_ped_itens_peso_885.peso_item
       LET p_ped_itens_peso_885.pct_lst_vnd   = p_item_chapa_885.pre_unit_lista / p_item_chapa_885.pre_unit_logix
       LET p_ped_itens_peso_885.pre_unit_lista  =  p_item_chapa_885.pre_unit_logix
    END IF 

    INSERT INTO ped_itens_peso_885 VALUES (p_ped_itens_peso_885.*)

  END FOREACH   
END FUNCTION

#---------------------------------#
 FUNCTION pol0921_processa_qtd_sd()
#---------------------------------#
  DECLARE cq_peisqtd CURSOR FOR
    SELECT * 
      FROM ped_itens
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_peisqtd INTO p_ped_itens.*

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

    SELECT *
      INTO p_ped_itens_01.*
      FROM ped_itens 
     WHERE cod_empresa =  p_empresas_885.cod_emp_oficial
       AND num_pedido  =  p_ped_itens.num_pedido
       AND num_sequencia = p_ped_itens.num_sequencia
    IF SQLCA.sqlcode = 0 THEN
       LET  p_ped_itens_01.qtd_pecas_solic =0
    END IF
       
    LET p_ped_itens_peso_885.cod_repres    = p_pedidos.cod_repres 
    LET p_ped_itens_peso_885.num_pedido    = p_pedidos.num_pedido
    LET p_ped_itens_peso_885.num_sequencia = p_ped_itens.num_sequencia
    LET p_ped_itens_peso_885.cod_item      = p_ped_itens.cod_item
    LET p_ped_itens_peso_885.pre_unit_qtd  = p_ped_itens.pre_unit 
    LET p_ped_itens_peso_885.qtd_saldo     = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel
    LET p_ped_itens_peso_885.qtd_peca_solic  = p_ped_itens.qtd_pecas_solic + p_ped_itens_01.qtd_pecas_solic
    LET p_ped_itens_peso_885.qtd_peca_atend  = p_ped_itens.qtd_pecas_atend
    LET p_ped_itens_peso_885.qtd_peca_cancel = p_ped_itens.qtd_pecas_cancel
    LET p_ped_itens_peso_885.prz_entrega   = p_ped_itens.prz_entrega

    SELECT ies_tip_controle
      INTO p_ies_tip_controle
      FROM nat_operacao
     WHERE cod_nat_oper = p_pedidos.cod_nat_oper 

    IF p_ies_tip_controle = '1' THEN 
       LET p_qtd_remessa = 0
       SELECT sum(qtd_item)
         INTO p_qtd_remessa
         FROM nf_item a,
              nf_mestre b
        WHERE a.cod_empresa =   p_empresas_885.cod_emp_oficial
          AND a.cod_item    =   p_ped_itens.cod_item
          AND a.num_pedido  =   p_pedidos.num_pedido
          AND a.num_sequencia = p_ped_itens.num_sequencia
          AND a.cod_empresa   = b.cod_empresa
          AND a.num_nff       = b.num_nff
          AND b.ies_situacao  = 'N'
       IF p_qtd_remessa IS NULL THEN 
          LET p_qtd_remessa = 0
       END IF
       LET p_ped_itens_peso_885.qtd_saldo =  p_ped_itens_peso_885.qtd_saldo  -  p_qtd_remessa 
       LET p_ped_itens_peso_885.qtd_peca_atend = p_qtd_remessa
    END IF   

    SELECT cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso,
           pes_unit 
      INTO p_ped_itens_peso_885.cod_lin_prod,
           p_ped_itens_peso_885.cod_lin_recei,
           p_ped_itens_peso_885.cod_seg_merc,
           p_ped_itens_peso_885.cod_cla_uso,
           p_pes_unit
      FROM item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND cod_item    = p_ped_itens.cod_item 

    INITIALIZE p_ped_itens_peso_885.cod_item_cli TO NULL 

    SELECT cod_item_cliente 
      INTO p_ped_itens_peso_885.cod_item_cli
      FROM cliente_item
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND cod_item    = p_ped_itens.cod_item
       AND cod_cliente_matriz =  p_ped_itens_peso_885.cod_cliente

    INITIALIZE p_ped_itens_peso_885.den_comp TO NULL 

    DECLARE cq_esqtdsd CURSOR FOR
      SELECT cod_item_compon
        FROM estrutura
       WHERE cod_empresa  = p_empresas_885.cod_emp_oficial
         AND cod_item_pai = p_ped_itens.cod_item  
      FOREACH cq_esqtdsd INTO p_cod_item_comp

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

       SELECT den_comp
         INTO p_ped_itens_peso_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_cod_item_comp
       IF SQLCA.sqlcode = 0 THEN
          EXIT FOREACH
       END IF     
      END FOREACH  

    IF p_ped_itens_peso_885.den_comp IS NULL THEN 
       SELECT den_comp
         INTO p_ped_itens_peso_885.den_comp
         FROM composicao_chapa_885
        WHERE cod_item =  p_ped_itens.cod_item  
    END IF 

    IF p_ped_itens_peso_885.den_comp IS NULL THEN 
       SELECT composicao
         INTO p_ped_itens_peso_885.den_comp
         FROM ft_item_885
        WHERE cod_item    =  p_ped_itens.cod_item  
          AND cod_empresa =  p_empresas_885.cod_emp_gerencial 
    END IF                

    IF p_tipo_pedido_885.tipo_pedido <> 2 THEN 
       IF p_tipo_pedido_885.tipo_pedido = 1 THEN 
          SELECT * 
            INTO p_item_bobina_885.*
            FROM item_bobina_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          LET p_ped_itens_peso_885.pct_lst_vnd =  p_ped_itens_peso_885.pre_unit_qtd / p_item_bobina_885.pre_unit_logix   
          LET p_ped_itens_peso_885.pre_unit_lista  =  p_item_bobina_885.pre_unit_logix
       ELSE
          SELECT * 
            INTO p_item_caixa_885.*
            FROM item_caixa_885
           WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
             AND num_pedido  = p_ped_itens.num_pedido
             AND num_sequencia = p_ped_itens.num_sequencia
          IF p_item_caixa_885.pes_unit > 0 THEN    
             LET p_pes_unit =    p_item_caixa_885.pes_unit   
          END IF 
          LET p_ped_itens_peso_885.pct_lst_vnd =  p_ped_itens_peso_885.pre_unit_qtd / p_item_caixa_885.pre_unit_logix      
          LET p_ped_itens_peso_885.pre_unit_lista  =  p_item_caixa_885.pre_unit_logix
       END IF       
       LET p_ped_itens_peso_885.peso_item = p_pes_unit *  p_ped_itens_peso_885.qtd_saldo
       LET p_val_tot = p_ped_itens_peso_885.qtd_saldo * p_ped_itens_peso_885.pre_unit_qtd
       LET p_ped_itens_peso_885.pre_unit_peso =  p_val_tot / p_ped_itens_peso_885.peso_item
    ELSE   
       SELECT * 
         INTO p_item_chapa_885.*
         FROM item_chapa_885
        WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
          AND num_pedido  = p_ped_itens.num_pedido
          AND num_sequencia = p_ped_itens.num_sequencia
       LET p_pes_unit =    p_item_chapa_885.pes_unit / 1000 
       LET p_ped_itens_peso_885.peso_item = p_pes_unit *  p_ped_itens_peso_885.qtd_saldo
       LET p_val_tot = p_ped_itens_peso_885.qtd_saldo * p_ped_itens_peso_885.pre_unit_qtd
       LET p_ped_itens_peso_885.pre_unit_peso =  p_val_tot / p_ped_itens_peso_885.peso_item
       LET p_ped_itens_peso_885.pct_lst_vnd   = p_item_chapa_885.pre_unit_lista / p_item_chapa_885.pre_unit_logix
       LET p_ped_itens_peso_885.pre_unit_lista  =  p_item_chapa_885.pre_unit_logix
    END IF 

    INSERT INTO ped_itens_peso_885 VALUES (p_ped_itens_peso_885.*)

  END FOREACH   
END FUNCTION

#---------------------------------#
 FUNCTION pol0921_processa_notas()
#---------------------------------#

  DISPLAY 'PROCESSANDO NOTAS FISCAIS'  AT 7,10

  DELETE FROM nota_itens_peso_885 
   WHERE cod_empresa  IN (p_cod_emp1, p_cod_emp2, p_cod_emp3, p_cod_emp4, p_cod_emp5, p_cod_empg1, p_cod_empg2, p_cod_empg3, p_cod_empg4, p_cod_empg5)
     AND dat_emissao >= p_tela.dat_ini
     AND dat_emissao <= p_tela.dat_fim  

  DELETE FROM nota_mest_peso_885 
   WHERE cod_empresa  IN (p_cod_emp1, p_cod_emp2, p_cod_emp3, p_cod_emp4, p_cod_emp5, p_cod_empg1, p_cod_empg2, p_cod_empg3, p_cod_empg4, p_cod_empg5)
     AND dat_emissao >= p_tela.dat_ini
     AND dat_emissao <= p_tela.dat_fim  

  DECLARE cq_not CURSOR FOR
    SELECT * 
      FROM nf_mestre 
      WHERE cod_empresa  IN (p_cod_emp1, p_cod_emp2, p_cod_emp3, p_cod_emp4, p_cod_emp5) 
       AND dat_emissao >= p_tela.dat_ini
       AND dat_emissao <= p_tela.dat_fim  
       AND ies_situacao <> 'C'
  FOREACH cq_not INTO p_nf_mestre.*

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

     INITIALIZE p_nota_itens_peso_885,
                p_nota_mest_peso_885 TO NULL

     SELECT * 
       INTO p_empresas_885.*
       FROM empresas_885 
      WHERE cod_emp_oficial = p_nf_mestre.cod_empresa

     DISPLAY "NOTA    "  AT  8,6
     DISPLAY p_nf_mestre.num_nff   AT  8,14
     
     LET p_nota_itens_peso_885.cod_empresa    = p_empresas_885.cod_emp_oficial
     LET p_nota_itens_peso_885.cod_cliente    = p_nf_mestre.cod_cliente
     LET p_nota_itens_peso_885.num_nff        = p_nf_mestre.num_nff
     LET p_nota_itens_peso_885.dat_emissao    = p_nf_mestre.dat_emissao
     LET p_nota_itens_peso_885.cod_repres     = p_nf_mestre.cod_repres
     LET p_nota_itens_peso_885.ies_situacao   = p_nf_mestre.ies_situacao
     LET p_nota_itens_peso_885.cod_transpor   = p_nf_mestre.cod_transpor
     LET p_nota_itens_peso_885.dat_emissao    = p_nf_mestre.dat_emissao
      
     LET p_nota_mest_peso_885.cod_empresa     = p_empresas_885.cod_emp_oficial
     LET p_nota_mest_peso_885.cod_cliente     = p_nf_mestre.cod_cliente
     LET p_nota_mest_peso_885.num_nff         = p_nf_mestre.num_nff
     LET p_nota_mest_peso_885.dat_emissao     = p_nf_mestre.dat_emissao
     LET p_nota_mest_peso_885.cod_repres      = p_nf_mestre.cod_repres
     LET p_nota_mest_peso_885.ies_situacao    = p_nf_mestre.ies_situacao
     LET p_nota_mest_peso_885.cod_transpor    = p_nf_mestre.cod_transpor

     SELECT nom_reduzido
       INTO p_nota_itens_peso_885.nom_cliente
       FROM clientes
      WHERE cod_cliente =  p_nf_mestre.cod_cliente

     LET p_nota_mest_peso_885.nom_cliente    = p_nota_itens_peso_885.nom_cliente

     IF p_nf_mestre.cod_transpor IS NOT NULL THEN 
        SELECT nom_reduzido
          INTO p_nota_itens_peso_885.nom_transpor
          FROM clientes
         WHERE cod_cliente =  p_nf_mestre.cod_transpor
     ELSE
        LET p_nota_itens_peso_885.nom_transpor = 'SEM FRETE'
     END IF 
        
     LET p_nota_mest_peso_885.nom_transpor    = p_nota_itens_peso_885.nom_transpor

     SELECT num_placa
       INTO p_nota_itens_peso_885.num_placa
       FROM wfat_mestre
      WHERE cod_empresa = p_empresas_885.cod_emp_oficial 
        AND num_nff     = p_nf_mestre.num_nff

     LET p_nota_mest_peso_885.num_placa  = p_nota_itens_peso_885.num_placa

      SELECT *
        INTO p_canal_venda.*
        FROM canal_venda
       WHERE cod_nivel_1 = p_nf_mestre.cod_repres 
         AND p_nf_mestre.cod_repres <> 0
         AND cod_nivel_2 = 0
         AND cod_nivel_3 = 0
         AND cod_nivel_4 = 0
         AND cod_nivel_5 = 0
         AND cod_nivel_6 = 0
         AND cod_nivel_7 = 0
      IF SQLCA.sqlcode <> 0 THEN
         SELECT *
           INTO p_canal_venda.*
           FROM canal_venda
          WHERE cod_nivel_2 = p_nf_mestre.cod_repres 
            AND p_nf_mestre.cod_repres <> 0
            AND cod_nivel_3 = 0
            AND cod_nivel_4 = 0
            AND cod_nivel_5 = 0
            AND cod_nivel_6 = 0
            AND cod_nivel_7 = 0
         IF SQLCA.sqlcode <> 0 THEN
            SELECT *
              INTO p_canal_venda.*
              FROM canal_venda
             WHERE cod_nivel_3 = p_nf_mestre.cod_repres 
               AND p_nf_mestre.cod_repres <> 0
               AND cod_nivel_4 = 0
               AND cod_nivel_5 = 0
               AND cod_nivel_6 = 0
               AND cod_nivel_7 = 0
            IF SQLCA.sqlcode <> 0 THEN
               SELECT *
                 INTO p_canal_venda.*
                 FROM canal_venda
                WHERE cod_nivel_4 = p_nf_mestre.cod_repres 
                  AND p_nf_mestre.cod_repres <> 0
                  AND cod_nivel_5 = 0
                  AND cod_nivel_6 = 0
                  AND cod_nivel_7 = 0
               IF SQLCA.sqlcode <> 0 THEN
                  SELECT *
                    INTO p_canal_venda.*
                    FROM canal_venda
                   WHERE cod_nivel_5 = p_nf_mestre.cod_repres 
                     AND p_nf_mestre.cod_repres <> 0
                     AND cod_nivel_6 = 0
                     AND cod_nivel_7 = 0
                  IF SQLCA.sqlcode <> 0 THEN
                     SELECT *
                       INTO p_canal_venda.*
                       FROM canal_venda
                      WHERE cod_nivel_6 = p_nf_mestre.cod_repres 
			            AND p_nf_mestre.cod_repres <> 0
                     IF SQLCA.sqlcode <> 0 THEN
                        SELECT *
                          INTO p_canal_venda.*
                          FROM canal_venda
                         WHERE cod_nivel_7 = p_nf_mestre.cod_repres 
				           AND p_nf_mestre.cod_repres <> 0
                         IF SQLCA.sqlcode <> 0 THEN
                            LET p_ped_itens_orig_885.cod_gerente = 1000	
                         ELSE    
                            IF p_canal_venda.cod_nivel_2 = 0 THEN 
                               LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
                               LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_1
                            ELSE
                               LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
                               LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_2
                            END IF
                         END IF      
                     ELSE
                        IF p_canal_venda.cod_nivel_2 = 0 THEN 
                           LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
                           LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_1
                        ELSE
                           LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
                           LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_2
                        END IF   
                     END IF
                  ELSE
                     IF p_canal_venda.cod_nivel_2 = 0 THEN 
                        LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
                        LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_1
                     ELSE
                        LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
                        LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_2
                     END IF   
                  END IF 
               ELSE
                  IF p_canal_venda.cod_nivel_2 = 0 THEN 
                     LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
                     LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_1
                  ELSE
                     LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
                     LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_2
                  END IF   
               END IF 
            ELSE
               IF p_canal_venda.cod_nivel_2 = 0 THEN 
                  LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
                  LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_1
               ELSE
                  LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
                  LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_2
               END IF   
            END IF 
         ELSE
            IF p_canal_venda.cod_nivel_2 = 0 THEN 
               LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
               LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_1
            ELSE
               LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
               LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_2
            END IF   
         END IF    
      ELSE
         LET p_nota_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
         LET p_nota_mest_peso_885.cod_gerente  = p_canal_venda.cod_nivel_1
      END IF 

     IF p_nf_mestre.cod_repres = 0 OR 
        p_nf_mestre.cod_repres IS NULL THEN 
        LET p_nota_itens_peso_885.cod_repres  = 9999
        LET p_nota_mest_peso_885.cod_repres   = 9999
        LET p_nota_itens_peso_885.nom_repres  = 'NOTAS FISCAIS SEM REP' 
        LET p_nota_itens_peso_885.nom_gerente = 'NOTAS FISCAIS SEM REP'
        LET p_nota_mest_peso_885.nom_repres  = 'NOTAS FISCAIS SEM REP' 
        LET p_nota_mest_peso_885.nom_gerente = 'NOTAS FISCAIS SEM REP'
     ELSE           
        SELECT nom_guerra
          INTO p_nota_itens_peso_885.nom_repres 
          FROM representante
         WHERE cod_repres = p_nf_mestre.cod_repres 
        
        LET p_nota_mest_peso_885.nom_repres  = p_nota_itens_peso_885.nom_repres 
        
        SELECT nom_guerra
          INTO p_nota_itens_peso_885.nom_gerente 
          FROM representante
         WHERE cod_repres = p_nota_itens_peso_885.cod_gerente
        
        LET p_nota_mest_peso_885.nom_gerente  = p_nota_itens_peso_885.nom_gerente 
        
        SELECT ies_estatistica
          INTO p_nota_itens_peso_885.ies_estatistica
          FROM nat_operacao
         WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper 
     END IF 

     LET p_nota_mest_peso_885.ies_estatistica  =  p_nota_itens_peso_885.ies_estatistica

     SELECT MAX(num_pedido)
       INTO p_pedidos.num_pedido
       FROM nf_item 
      WHERE cod_empresa = p_empresas_885.cod_emp_oficial 
        AND num_nff     = p_nf_mestre.num_nff 

     LET p_num_om = 0 
     LET p_num_romaneio = 0  

     SELECT MAX(num_om)
       INTO p_num_om
       FROM nf_item 
      WHERE cod_empresa = p_empresas_885.cod_emp_oficial 
        AND num_nff     = p_nf_mestre.num_nff 

     SELECT num_solicit
       INTO p_num_romaneio
       FROM solicit_fat_885
      WHERE cod_empresa = p_cod_empresa
        AND num_om      = p_num_om 

     LET p_nota_itens_peso_885.num_romaneio    = p_num_romaneio
     LET p_nota_mest_peso_885.num_romaneio     = p_num_romaneio

     SELECT *
       INTO p_desc_nat_oper_885.*
       FROM desc_nat_oper_885
      WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
        AND num_pedido  =  p_pedidos.num_pedido
        
     IF SQLCA.sqlcode <> 0 THEN 
        CALL pol0921_proc_nf_100()
     ELSE
        IF p_desc_nat_oper_885.pct_desc_qtd   = 0 AND 
           p_desc_nat_oper_885.pct_desc_valor = 0 THEN 
           CALL pol0921_proc_nf_100()
        ELSE
           IF p_desc_nat_oper_885.pct_desc_qtd > 0 THEN
              CALL pol0921_proc_nf_qtd()
           ELSE   
              CALL pol0921_proc_nf_val()
           END IF 
        END IF
     END IF
  END FOREACH              

END FUNCTION

#------------------------------#
 FUNCTION pol0921_proc_nf_100()
#------------------------------#
DEFINE l_pes_unit    LIKE ordem_montag_item.pes_total_item
DEFINE l_char	CHAR(01)

  LET p_nota_mest_peso_885.peso_total    = p_nf_mestre.pes_tot_liquido
  LET p_nota_mest_peso_885.val_tot_merc  = p_nf_mestre.val_tot_mercadoria
  LET p_nota_mest_peso_885.val_tot_nff   = p_nf_mestre.val_tot_nff

  DECLARE cq_nfi100 CURSOR FOR
    SELECT * 
      FROM nf_item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND num_nff     = p_nf_mestre.num_nff
  FOREACH cq_nfi100 INTO p_nf_item.*

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
             
    LET p_nota_itens_peso_885.num_pedido    = p_nf_item.num_pedido
    LET p_nota_itens_peso_885.num_sequencia = p_nf_item.num_sequencia
    LET p_nota_itens_peso_885.cod_item      = p_nf_item.cod_item
    LET p_nota_itens_peso_885.pre_unit_qtd  = p_nf_item.pre_unit_nf
    LET p_nota_itens_peso_885.qtd_item      = p_nf_item.qtd_item

    SELECT cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso
      INTO p_nota_itens_peso_885.cod_lin_prod,
           p_nota_itens_peso_885.cod_lin_recei,
           p_nota_itens_peso_885.cod_seg_merc,
           p_nota_itens_peso_885.cod_cla_uso
      FROM item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND cod_item    = p_nf_item.cod_item 

    SELECT pes_total_item
      INTO p_nota_itens_peso_885.peso_item
      FROM ordem_montag_item
     WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
       AND num_om        = p_nf_item.num_om
       AND num_pedido    = p_nf_item.num_pedido
       AND cod_item      = p_nf_item.cod_item  
       AND num_sequencia = p_nf_item.num_sequencia
    IF SQLCA.sqlcode <> 0 THEN 
       SELECT pes_unit
         INTO l_pes_unit 
         FROM item
        WHERE cod_empresa = p_empresas_885.cod_emp_oficial
          AND cod_item    = p_nf_item.cod_item  
       IF SQLCA.sqlcode <> 0 THEN 
          LET l_pes_unit = p_nf_item.qtd_item           
       END IF 
       
       LET p_nota_itens_peso_885.peso_item =  l_pes_unit *  p_nf_item.qtd_item           
    END IF
    
    LET p_nota_itens_peso_885.pre_unit_peso =  p_nf_item.val_liq_item  / p_nota_itens_peso_885.peso_item
    
     SELECT ies_estatistica
       INTO p_nota_itens_peso_885.ies_estatistica
       FROM nat_operacao
      WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper 
     IF p_nota_itens_peso_885.ies_estatistica IS NULL THEN
     	ERROR 'Natureza não cadastrada! ',p_nf_mestre.cod_nat_oper 
     	PROMPT 'Natureza não cadastrada!' FOR CHAR l_char
     END IF
    
    INSERT INTO nota_itens_peso_885 VALUES (p_nota_itens_peso_885.*)
    
  END FOREACH   
  
  LET p_nota_mest_peso_885.cod_lin_prod  = p_nota_itens_peso_885.cod_lin_prod 
  LET p_nota_mest_peso_885.cod_lin_recei = p_nota_itens_peso_885.cod_lin_recei 
  LET p_nota_mest_peso_885.cod_seg_merc  = p_nota_itens_peso_885.cod_seg_merc 
  LET p_nota_mest_peso_885.cod_cla_uso   = p_nota_itens_peso_885.cod_cla_uso

  SELECT ies_estatistica
  INTO p_nota_mest_peso_885.ies_estatistica
  FROM nat_operacao
  WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper 
  IF p_nota_mest_peso_885.ies_estatistica IS NULL THEN
  	ERROR 'Natureza não cadastrada! ',p_nf_mestre.cod_nat_oper 
   	PROMPT 'Natureza não cadastrada!' FOR CHAR l_char
  END IF
  
  INSERT INTO nota_mest_peso_885 VALUES (p_nota_mest_peso_885.*)
    
END FUNCTION
     
#------------------------------#
 FUNCTION pol0921_proc_nf_val()
#------------------------------#

  LET p_nota_mest_peso_885.peso_total    = p_nf_mestre.pes_tot_liquido

  SELECT *
    INTO p_nf_mestre_1.*
    FROM nf_mestre
   WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
     AND num_nff = p_nf_mestre.num_nff
  IF SQLCA.sqlcode <> 0 THEN 
     LET p_nota_mest_peso_885.val_tot_merc  = p_nf_mestre.val_tot_mercadoria
     LET p_nota_mest_peso_885.val_tot_nff   = p_nf_mestre.val_tot_nff
  ELSE
     LET p_nota_mest_peso_885.val_tot_merc  = p_nf_mestre.val_tot_mercadoria + p_nf_mestre_1.val_tot_mercadoria
     LET p_nota_mest_peso_885.val_tot_nff   = p_nf_mestre.val_tot_nff + p_nf_mestre_1.val_tot_nff
  END IF 

  DECLARE cq_nfiv CURSOR FOR
    SELECT * 
      FROM nf_item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND num_nff     = p_nf_mestre.num_nff
  FOREACH cq_nfiv INTO p_nf_item.*

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
             
    LET p_nota_itens_peso_885.num_pedido    = p_nf_item.num_pedido
    LET p_nota_itens_peso_885.num_sequencia = p_nf_item.num_sequencia
    LET p_nota_itens_peso_885.cod_item      = p_nf_item.cod_item
    LET p_nota_itens_peso_885.qtd_item      = p_nf_item.qtd_item
    
    SELECT cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso
      INTO p_nota_itens_peso_885.cod_lin_prod,
           p_nota_itens_peso_885.cod_lin_recei,
           p_nota_itens_peso_885.cod_seg_merc,
           p_nota_itens_peso_885.cod_cla_uso
      FROM item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND cod_item    = p_nf_item.cod_item 

    SELECT pes_total_item
      INTO p_nota_itens_peso_885.peso_item
      FROM ordem_montag_item
     WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
       AND num_om        = p_nf_item.num_om
       AND num_pedido    = p_nf_item.num_pedido
       AND cod_item      = p_nf_item.cod_item  
       AND num_sequencia = p_nf_item.num_sequencia
       
    IF p_nota_itens_peso_885.peso_item IS NULL THEN
    	LET p_nota_itens_peso_885.peso_item = p_nf_item.qtd_item
    END IF

    SELECT pre_unit_nf, 
           val_liq_item 
      INTO p_nf_item_1.pre_unit_nf,
           p_nf_item_1.val_liq_item
      FROM nf_item
     WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
       AND num_nff       = p_nf_item.num_nff
       AND num_sequencia = p_nf_item.num_sequencia
       AND num_pedido    = p_nf_item.num_pedido
       AND cod_item      = p_nf_item.cod_item
    IF SQLCA.sqlcode <> 0 THEN    
       LET p_nota_itens_peso_885.pre_unit_qtd  = p_nf_item.pre_unit_nf
       LET p_nota_itens_peso_885.pre_unit_peso = p_nf_item.val_liq_item / p_nota_itens_peso_885.peso_item
    ELSE
       LET p_nota_itens_peso_885.pre_unit_qtd  = p_nf_item.pre_unit_nf + p_nf_item_1.pre_unit_nf
       LET p_nota_itens_peso_885.pre_unit_peso = (p_nf_item.val_liq_item + p_nf_item_1.val_liq_item) / p_nota_itens_peso_885.peso_item
    END IF  

    INSERT INTO nota_itens_peso_885 VALUES (p_nota_itens_peso_885.*)
    
  END FOREACH   
  
  LET p_nota_mest_peso_885.cod_lin_prod  = p_nota_itens_peso_885.cod_lin_prod 
  LET p_nota_mest_peso_885.cod_lin_recei = p_nota_itens_peso_885.cod_lin_recei 
  LET p_nota_mest_peso_885.cod_seg_merc  = p_nota_itens_peso_885.cod_seg_merc 
  LET p_nota_mest_peso_885.cod_cla_uso   = p_nota_itens_peso_885.cod_cla_uso
  
  INSERT INTO nota_mest_peso_885 VALUES (p_nota_mest_peso_885.*)

END FUNCTION

#-----------------------------#
 FUNCTION pol0921_proc_nf_qtd()
#-----------------------------#
  DEFINE l_pes_item     LIKE  ordem_montag_item.pes_total_item

  SELECT *
    INTO p_nf_mestre_1.*
    FROM nf_mestre
   WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
     AND num_nff = p_nf_mestre.num_nff
  IF SQLCA.sqlcode <> 0 THEN 
     LET p_nota_mest_peso_885.val_tot_merc  = p_nf_mestre.val_tot_mercadoria
     LET p_nota_mest_peso_885.val_tot_nff   = p_nf_mestre.val_tot_nff
     LET p_nota_mest_peso_885.peso_total    = p_nf_mestre.pes_tot_liquido
  ELSE
     LET p_nota_mest_peso_885.val_tot_merc  = p_nf_mestre.val_tot_mercadoria + p_nf_mestre_1.val_tot_mercadoria
     LET p_nota_mest_peso_885.val_tot_nff   = p_nf_mestre.val_tot_nff + p_nf_mestre_1.val_tot_nff
     LET p_nota_mest_peso_885.peso_total    = p_nf_mestre.pes_tot_liquido + p_nf_mestre_1.pes_tot_liquido
  END IF 

  DECLARE cq_nfiq CURSOR FOR
    SELECT * 
      FROM nf_item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND num_nff     = p_nf_mestre.num_nff
  FOREACH cq_nfiq INTO p_nf_item.*

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
             
    LET p_nota_itens_peso_885.num_pedido    = p_nf_item.num_pedido
    LET p_nota_itens_peso_885.num_sequencia = p_nf_item.num_sequencia
    LET p_nota_itens_peso_885.cod_item      = p_nf_item.cod_item
    LET p_nota_itens_peso_885.pre_unit_qtd  = p_nf_item.pre_unit_nf
    
    SELECT cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso
      INTO p_nota_itens_peso_885.cod_lin_prod,
           p_nota_itens_peso_885.cod_lin_recei,
           p_nota_itens_peso_885.cod_seg_merc,
           p_nota_itens_peso_885.cod_cla_uso
      FROM item
     WHERE cod_empresa = p_empresas_885.cod_emp_oficial
       AND cod_item    = p_nf_item.cod_item 

    SELECT pes_total_item
      INTO p_nota_itens_peso_885.peso_item
      FROM ordem_montag_item
     WHERE cod_empresa   = p_empresas_885.cod_emp_oficial
       AND num_om        = p_nf_item.num_om
       AND num_pedido    = p_nf_item.num_pedido
       AND cod_item      = p_nf_item.cod_item  
       AND num_sequencia = p_nf_item.num_sequencia

    SELECT pes_total_item
      INTO l_pes_item
      FROM ordem_montag_item
     WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
       AND num_om        = p_nf_item.num_om
       AND num_pedido    = p_nf_item.num_pedido
       AND cod_item      = p_nf_item.cod_item  
       AND num_sequencia = p_nf_item.num_sequencia
    IF SQLCA.sqlcode <> 0 THEN
       LET l_pes_item = 0
    END IF 
    
    LET p_nota_itens_peso_885.peso_item =  p_nota_itens_peso_885.peso_item + l_pes_item

    SELECT qtd_item, 
           val_liq_item 
      INTO p_nf_item_1.qtd_item,
           p_nf_item_1.val_liq_item
      FROM nf_item
     WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
       AND num_nff       = p_nf_item.num_nff
       AND num_sequencia = p_nf_item.num_sequencia
       AND num_pedido    = p_nf_item.num_pedido
       AND cod_item      = p_nf_item.cod_item
    IF SQLCA.sqlcode <> 0 THEN    
       LET p_nota_itens_peso_885.qtd_item      = p_nf_item.qtd_item
    ELSE
       LET p_nota_itens_peso_885.qtd_item      = p_nf_item.qtd_item + p_nf_item_1.qtd_item
    END IF  

    LET p_nota_itens_peso_885.pre_unit_peso = (p_nf_item.val_liq_item + p_nf_item_1.val_liq_item) / p_nota_itens_peso_885.peso_item

    INSERT INTO nota_itens_peso_885 VALUES (p_nota_itens_peso_885.*)
    
  END FOREACH   
  
  LET p_nota_mest_peso_885.cod_lin_prod  = p_nota_itens_peso_885.cod_lin_prod 
  LET p_nota_mest_peso_885.cod_lin_recei = p_nota_itens_peso_885.cod_lin_recei 
  LET p_nota_mest_peso_885.cod_seg_merc  = p_nota_itens_peso_885.cod_seg_merc 
  LET p_nota_mest_peso_885.cod_cla_uso   = p_nota_itens_peso_885.cod_cla_uso
 
  INSERT INTO nota_mest_peso_885 VALUES (p_nota_mest_peso_885.*)

END FUNCTION


#-------------------------------#
 FUNCTION pol0921_limpa_ped_at()
#-------------------------------#

DECLARE cq_del_ped_at CURSOR FOR
  SELECT cod_empresa, num_pedido 
    FROM ped_del 
FOREACH cq_del_ped_at INTO p_pedidos.cod_empresa, p_pedidos.num_pedido

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

   DELETE 
     FROM ped_at_885 
    WHERE cod_empresa =  p_pedidos.cod_empresa
      AND num_pedido  =  p_pedidos.num_pedido
END FOREACH     


END FUNCTION
