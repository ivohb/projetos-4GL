#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: pol0890                                               #
# MODULOS.: pol0890 - LOG0010 - LOG0030 - LOG0040 - LOG0050       #
#           LOG0060 - LOG1200 - LOG1300 - LOG1400                 #
# OBJETIVO: VARIACAO DA PROGRAMACAO DO CLIENTE                    #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_val_tot              DECIMAL(15,2),
         p_pes_unit             DECIMAL(15,6),
         p_pre_unit             LIKE list_preco_item.pre_unit,
         p_qtd_saldo            DECIMAL(10,3),
         p_des_alter            CHAR(40),       
         p_qtd_variacao         DECIMAL(07,0),
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_ies_cons             SMALLINT
         
  DEFINE p_ped_itens          RECORD LIKE ped_itens.*
  DEFINE p_ped_itens_01       RECORD LIKE ped_itens.*
  DEFINE p_ped_itens_peso_885 RECORD LIKE ped_itens_peso_885.*
  DEFINE p_item_chapa_885     RECORD LIKE item_chapa_885.*
  DEFINE p_empresas_885       RECORD LIKE empresas_885.*             
  DEFINE p_pedidos            RECORD LIKE pedidos.*
  DEFINE p_desc_nat_oper_885  RECORD LIKE desc_nat_oper_885.*
  DEFINE p_canal_venda        RECORD LIKE canal_venda.*
  
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
  DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0890-05.10.09" #Favor nao alterar esta linha (SUPORTE)
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
    CALL pol0890_controle()
  END IF
END MAIN

#---------------------------------------------------------------------#
 FUNCTION pol0890_controle()
#---------------------------------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol0890") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0890 AT 5,3  WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND  "Processar"    "Gera base para relatorios de pedidos "
      HELP 2043
      MESSAGE ""
      SELECT * 
        INTO p_empresas_885.* 
        FROM empresas_885 
	     WHERE cod_emp_oficial = p_cod_empresa
	    IF SQLCA.sqlcode <> 0 THEN 
	       ERROR 'Empresa nao autorizada a executar rotina'
      ELSE    
         CALL pol0890_processa()
      END IF 
      
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0890
END FUNCTION

#----------------------------#
 FUNCTION pol0890_processa()
#----------------------------#

  DELETE FROM ped_itens_peso_885 
   WHERE cod_empresa =  p_empresas_885.cod_emp_oficial 

  DECLARE cq_ped1 CURSOR FOR
    SELECT UNIQUE a.* 
      FROM pedidos a, ped_itens b 
     WHERE a.cod_empresa   = p_empresas_885.cod_emp_gerencial
       AND a.ies_sit_pedido  <> '9'
       AND a.cod_empresa = b.cod_empresa
       AND a.num_pedido = b.num_pedido
       AND (b.qtd_pecas_solic - b.qtd_pecas_atend - b.qtd_pecas_cancel)>0
  FOREACH cq_ped1 INTO p_pedidos.*

     DISPLAY "PEDIDO "  AT  8,6
     DISPLAY p_pedidos.num_pedido   AT  8,14
  
     LET p_ped_itens_peso_885.cod_empresa    = p_empresas_885.cod_emp_oficial
     LET p_ped_itens_peso_885.cod_cliente    = p_pedidos.cod_cliente

     SELECT nom_reduzido
       INTO p_ped_itens_peso_885.nom_cliente
       FROM clientes
      WHERE cod_cliente =  p_pedidos.cod_cliente

      SELECT *
        INTO p_canal_venda.*
        FROM canal_venda
       WHERE cod_nivel_1 = p_pedidos.cod_repres 
      IF SQLCA.sqlcode <> 0 THEN
         SELECT *
           INTO p_canal_venda.*
           FROM canal_venda
          WHERE cod_nivel_2 = p_pedidos.cod_repres 
         IF SQLCA.sqlcode <> 0 THEN
            SELECT *
              INTO p_canal_venda.*
              FROM canal_venda
             WHERE cod_nivel_3 = p_pedidos.cod_repres 
            IF SQLCA.sqlcode <> 0 THEN
               SELECT *
                 INTO p_canal_venda.*
                 FROM canal_venda
                WHERE cod_nivel_4 = p_pedidos.cod_repres 
               IF SQLCA.sqlcode <> 0 THEN
                  SELECT *
                    INTO p_canal_venda.*
                    FROM canal_venda
                   WHERE cod_nivel_5 = p_pedidos.cod_repres 
                  IF SQLCA.sqlcode <> 0 THEN
                     SELECT *
                       INTO p_canal_venda.*
                       FROM canal_venda
                      WHERE cod_nivel_6 = p_pedidos.cod_repres 
                     IF SQLCA.sqlcode <> 0 THEN
                        SELECT *
                          INTO p_canal_venda.*
                          FROM canal_venda
                         WHERE cod_nivel_7 = p_pedidos.cod_repres 
                        IF SQLCA.sqlcode <> 0 THEN  
                           LET p_ped_itens_peso_885.cod_gerente = 1000
                        ELSE
                           IF p_canal_venda.cod_nivel_2 = 0 THEN 
                              LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
                           ELSE
                              LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
                           END IF   
                        END IF    
                     ELSE
                        IF p_canal_venda.cod_nivel_2 = 0 THEN 
                           LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
                        ELSE
                           LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
                        END IF   
                     END IF
                  ELSE
                     IF p_canal_venda.cod_nivel_2 = 0 THEN 
                        LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
                     ELSE
                        LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
                     END IF   
                  END IF 
               ELSE
                  IF p_canal_venda.cod_nivel_2 = 0 THEN 
                     LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
                  ELSE
                     LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
                  END IF   
               END IF 
            ELSE
               IF p_canal_venda.cod_nivel_2 = 0 THEN 
                  LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
               ELSE
                  LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
               END IF   
            END IF 
         ELSE
            IF p_canal_venda.cod_nivel_2 = 0 THEN 
               LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
            ELSE
               LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_2
            END IF   
         END IF    
      ELSE
         LET p_ped_itens_peso_885.cod_gerente = p_canal_venda.cod_nivel_1
      END IF 

     SELECT nom_guerra
       INTO p_ped_itens_peso_885.nom_repres 
       FROM representante
      WHERE cod_repres = p_pedidos.cod_repres 

     SELECT nom_guerra
       INTO p_ped_itens_peso_885.nom_gerente 
       FROM representante       
      WHERE cod_repres = p_ped_itens_peso_885.cod_gerente
  
     SELECT *
       INTO p_desc_nat_oper_885.*
       FROM desc_nat_oper_885
      WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
        AND num_pedido  =  p_pedidos.num_pedido
     IF SQLCA.sqlcode <> 0 THEN 
        CALL pol0890_processa_100()
     ELSE
        IF p_desc_nat_oper_885.pct_desc_qtd   = 0 AND 
           p_desc_nat_oper_885.pct_desc_valor = 0 THEN 
           CALL pol0890_processa_100()
        ELSE
           IF p_desc_nat_oper_885.pct_desc_qtd > 0 THEN
              CALL pol0890_processa_qtd()
           ELSE   
              CALL pol0890_processa_val()
           END IF 
        END IF
     END IF
  END FOREACH              

END FUNCTION

#-------------------------------#
 FUNCTION pol0890_processa_100()
#-------------------------------#
  DECLARE cq_pei100 CURSOR FOR
    SELECT * 
      FROM ped_itens
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND num_pedido  = p_pedidos.num_pedido
  FOREACH cq_pei100 INTO p_ped_itens.*
    SELECT * 
      INTO p_ped_itens_01.*
      FROM ped_itens 
     WHERE cod_empresa =  p_cod_empresa 
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
    LET p_ped_itens_peso_885.prz_entrega   = p_ped_itens.prz_entrega
    
    SELECT cod_lin_prod,pes_unit 
      INTO p_ped_itens_peso_885.cod_lin_prod, p_pes_unit
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_ped_itens.cod_item 

    IF p_ped_itens_peso_885.cod_lin_prod <> 3 THEN 
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
    END IF 
    
    INSERT INTO ped_itens_peso_885 VALUES (p_ped_itens_peso_885.*)
    
  END FOREACH   
END FUNCTION
     
#-------------------------------#
 FUNCTION pol0890_processa_val()
#-------------------------------#
  DECLARE cq_peival CURSOR FOR
    SELECT * 
      FROM ped_itens
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_peival INTO p_ped_itens.*
    LET p_qtd_saldo = 0   
    SELECT *
      INTO p_ped_itens_01.*
      FROM ped_itens 
     WHERE cod_empresa =  p_cod_empresa 
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
    LET p_ped_itens_peso_885.prz_entrega   = p_ped_itens.prz_entrega

    SELECT cod_lin_prod,pes_unit 
      INTO p_ped_itens_peso_885.cod_lin_prod, p_pes_unit
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_ped_itens.cod_item 

    IF p_ped_itens_peso_885.cod_lin_prod <> 3 THEN 
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
    END IF 

    INSERT INTO ped_itens_peso_885 VALUES (p_ped_itens_peso_885.*)

  END FOREACH   
END FUNCTION

#-------------------------------#
 FUNCTION pol0890_processa_qtd()
#-------------------------------#
  DECLARE cq_peiqtd CURSOR FOR
    SELECT * 
      FROM ped_itens
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_peiqtd INTO p_ped_itens.*

    SELECT *
      INTO p_ped_itens_01.*
      FROM ped_itens 
     WHERE cod_empresa =  p_cod_empresa 
       AND num_pedido  =  p_ped_itens.num_pedido
       AND num_sequencia = p_ped_itens.num_sequencia
    IF SQLCA.sqlcode = 0 THEN
       LET  p_qtd_saldo = p_ped_itens_01.qtd_pecas_solic - p_ped_itens_01.qtd_pecas_atend - p_ped_itens_01.qtd_pecas_cancel
    ELSE
       LET  p_qtd_saldo = 0      
    END IF
       
    LET p_ped_itens_peso_885.cod_repres    = p_pedidos.cod_repres 
    LET p_ped_itens_peso_885.num_pedido    = p_pedidos.num_pedido
    LET p_ped_itens_peso_885.num_sequencia = p_ped_itens.num_sequencia
    LET p_ped_itens_peso_885.cod_item      = p_ped_itens.cod_item
    LET p_ped_itens_peso_885.pre_unit_qtd  = p_ped_itens.pre_unit 
    LET p_ped_itens_peso_885.qtd_saldo     = (p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel) + p_qtd_saldo
    LET p_ped_itens_peso_885.prz_entrega   = p_ped_itens.prz_entrega

    SELECT cod_lin_prod,pes_unit 
      INTO p_ped_itens_peso_885.cod_lin_prod, p_pes_unit
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_ped_itens.cod_item 

    IF p_ped_itens_peso_885.cod_lin_prod <> 3 THEN 
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
    END IF 

    INSERT INTO ped_itens_peso_885 VALUES (p_ped_itens_peso_885.*)

  END FOREACH   
END FUNCTION
