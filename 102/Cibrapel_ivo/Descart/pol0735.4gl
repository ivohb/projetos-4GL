#------------------------------------------------------------------------------#
# PROGRAMA: pol0735 - REPLICA romaneio
#------------------------------------------------------------------------------#

DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_den_empresa       LIKE empresa.den_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_cod_cliente       LIKE clientes.cod_cliente,
         p_cod_nat_oper      LIKE nat_operacao.cod_nat_oper,
         p_cod_nat_oper_it   LIKE nat_operacao.cod_nat_oper,
         p_num_pedido        LIKE pedidos.num_pedido,
         p_status            SMALLINT,
         p_ies_impressao     CHAR(01),
         p_grava             CHAR(01),
         comando             CHAR(80),
         p_nom_arquivo       CHAR(100),
         p_versao            CHAR(18),
         p_ies_gr            CHAR(1),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_last_row          SMALLINT,
         p_ies_cons          SMALLINT,
         p_fator_of          DECIMAL(5,3),
         p_fator_op          DECIMAL(5,3),
         p_f0                DECIMAL(5,3),
         p_f1                DECIMAL(5,3),
         p_fq                DECIMAL(5,3),
         p_f2                DECIMAL(5,3),
         p_num_sequencia     LIKE ped_itens.num_sequencia,
         p_codi              LIKE ped_itens.cod_item,
         p_qtd               LIKE ped_itens.qtd_pecas_solic,
         p_qtd_v             LIKE ped_itens.qtd_pecas_solic,
         p_pes               LIKE ordem_montag_item.pes_total_item,
         p_saldo             LIKE ped_itens.qtd_pecas_solic,
         p_unit              LIKE ped_itens.pre_unit

  DEFINE p_ordem_montag_mest  RECORD LIKE ordem_montag_mest.*,
         p_nat_operacao       RECORD LIKE nat_operacao.*,
         p_ordem_montag_item  RECORD LIKE ordem_montag_item.*,
         p_pedidos            RECORD LIKE pedidos.*, 
         p_ordem_montag_grade RECORD LIKE ordem_montag_grade.*,
         p_ordem_montag_lote  RECORD LIKE ordem_montag_lote.*,
         p_desc_nat_oper_885  RECORD LIKE desc_nat_oper_885.*, 
         #p_item_corresp       RECORD LIKE item_corresp.*,
         p_empresas_885       RECORD LIKE empresas_885.*

  DEFINE p_tela      RECORD
                        cod_empresa    LIKE empresa.cod_empresa,
                        om_de          LIKE ordem_montag_mest.num_om
                     END RECORD,
         p_cont              SMALLINT

 END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
  SET LOCK MODE TO WAIT 60
  DEFER INTERRUPT
  LET p_versao = "POL0735-05.10.01"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0735.iem") RETURNING p_nom_help
  CALL log0180_conecta_usuario()
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0 THEN
      INITIALIZE p_tela.* TO NULL
      CALL pol0735_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0735_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0735") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0735 AT 5,11 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar" "Informa data parametros para processamento."           
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0735","CO") THEN
        IF pol0735_informa_dados() THEN
             NEXT OPTION "Processar"
        ELSE
           ERROR "Funcao Cancelada"
        END IF
      END IF
    COMMAND "Processar" "Processa copia de pedidos."         
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0735","CO") THEN
        IF p_tela.om_de IS NOT NULL THEN
           CALL pol0735_processa() 
        ELSE
           ERROR "Informe dados para processamento"
           NEXT OPTION "Informar"
        END IF
      END IF
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
  CLOSE WINDOW w_pol0735
END FUNCTION

#----------------------------------------#
 FUNCTION pol0735_informa_dados()
#----------------------------------------#
  CLEAR FORM
  INITIALIZE p_tela.* TO NULL
  
  CALL log006_exibe_teclas("01 02",p_versao)
  CURRENT WINDOW IS w_pol0735
  LET p_tela.cod_empresa = p_cod_empresa
  DISPLAY BY NAME p_tela.cod_empresa

  INPUT BY NAME p_tela.* WITHOUT DEFAULTS

     AFTER FIELD om_de     
        IF p_tela.om_de      IS NULL THEN
           ERROR "Campo de Preenchimento Obrigatorio"
           NEXT FIELD om_de  
        ELSE 
           IF pol0735_checa_par() THEN
              ERROR "Empresa para copia sem paramentros cadastrados" 
              NEXT FIELD om_de
           ELSE
              SELECT MAX(num_pedido) 
                INTO p_num_pedido
                FROM ordem_montag_item
               WHERE cod_empresa = p_cod_empresa 
                 AND num_om      = p_tela.om_de
                 
              SELECT *    
                INTO p_pedidos.*
                FROM pedidos 
               WHERE cod_empresa =  p_cod_empresa
                 AND num_pedido  = p_num_pedido
              
              SELECT *
                INTO p_nat_operacao.*
                FROM nat_operacao 
               WHERE cod_nat_oper = p_pedidos.cod_nat_oper
              
              IF p_nat_operacao.ies_tip_controle <> '8' THEN
                 ERROR "Pedido nao e de faturamento antecipado" 
                 NEXT FIELD p_tela.om_de
              END IF 
                
           END IF
        END IF

   END INPUT

  IF int_flag <> 0 THEN
     RETURN FALSE 
  ELSE
     RETURN TRUE
  END IF

END FUNCTION


#----------------------------------------#
 FUNCTION pol0735_checa_par()
#----------------------------------------# 

 SELECT * 
   INTO p_empresas_885.*		
   FROM empresas_885 
  WHERE cod_emp_oficial = p_cod_empresa

 IF sqlca.sqlcode <> 0 THEN 
    RETURN TRUE 
 ELSE 
    RETURN FALSE 
 END IF
    
END FUNCTION 

#----------------------------#
 FUNCTION pol0735_processa()
#----------------------------#
  DEFINE p_cont, i, p_count     SMALLINT

   ERROR "Processando a copia de romaneios "ATTRIBUTE(REVERSE)
   LET p_cont = 0

  DECLARE cq_lista CURSOR FOR
    SELECT *
      FROM ordem_montag_mest        
     WHERE cod_empresa = p_cod_empresa
       AND num_om  >= p_tela.om_de 
     ORDER BY num_om     

  FOREACH cq_lista INTO p_ordem_montag_mest.*  

    LET p_count = 0
    LET p_ies_gr = "N"

    SELECT count(*)
      INTO p_count
      FROM ordem_montag_item              
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND num_om      = p_ordem_montag_mest.num_om

    IF p_count > 0 THEN
       CONTINUE FOREACH
    END IF

    LET p_count = 0

    DECLARE cq_omit  CURSOR FOR
     SELECT *
       FROM ordem_montag_item              
      WHERE cod_empresa = p_cod_empresa
        AND num_om      = p_ordem_montag_mest.num_om

    FOREACH cq_omit  INTO p_ordem_montag_item.*
      
      LET p_ordem_montag_item.cod_empresa = p_empresas_885.cod_emp_gerencial
      CALL pol0735_proc_quant() 

    END FOREACH

    IF  p_ies_gr = "S" THEN
       LET p_ordem_montag_mest.cod_empresa = p_empresas_885.cod_emp_gerencial
       INSERT INTO ordem_montag_mest VALUES (p_ordem_montag_mest.*)
       IF p_ordem_montag_mest.num_lote_om > 0 THEN
          SELECT * 
            INTO p_ordem_montag_lote.*
            FROM ordem_montag_lote
           WHERE cod_empresa = p_cod_empresa
             AND num_lote_om = p_ordem_montag_mest.num_lote_om  
          IF SQLCA.sqlcode = 0 THEN
             LET p_ordem_montag_lote.cod_empresa = p_empresas_885.cod_emp_gerencial
             INSERT INTO ordem_montag_lote VALUES (p_ordem_montag_lote.*)
          END IF
       END IF      
    END IF

  END FOREACH

  IF p_cont = 0 THEN
     ERROR "Nao existem dados para serem listados "
     RETURN 
  ELSE
     ERROR "Copia efetuada com sucesso"
     RETURN
  END IF    
END FUNCTION

#----------------------------#
 FUNCTION pol0735_proc_quant()  
#----------------------------# 
  DEFINE p_qtd_saldo  DECIMAL (12,0)

  SELECT *
    INTO p_desc_nat_oper_885.*
    FROM desc_nat_oper_885
   WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
     AND num_pedido  = p_ordem_montag_item.num_pedido 
  
  IF p_desc_nat_oper_885.pct_desc_qtd > 0 THEN 
     SELECT (qtd_pecas_solic - qtd_pecas_cancel - qtd_pecas_atend - qtd_pecas_romaneio)
       INTO p_qtd_saldo
       FROM ped_itens 
      WHERE cod_empresa =  p_empresas_885.cod_emp_gerencial
        AND num_pedido  =  p_ordem_montag_item.num_pedido 
        AND cod_item    =  p_ordem_montag_item.cod_item
        AND num_sequencia = p_ordem_montag_item.num_sequencia

     LET p_ordem_montag_item.qtd_reservada = p_qtd_saldo * (p_desc_nat_oper_885.pct_desc_qtd / 100)
     LET p_ordem_montag_item.cod_empresa   = p_empresas_885.cod_emp_gerencial

     INSERT INTO ordem_montag_item VALUES (p_ordem_montag_item.*)
        
     LET p_cont = p_cont + 1
     LET p_ies_gr = "S"
  ELSE
     IF p_desc_nat_oper_885.pct_desc_valor > 0 THEN  

        LET p_ordem_montag_item.cod_empresa = p_empresas_885.cod_emp_gerencial 
         
        INSERT INTO ordem_montag_item VALUES (p_ordem_montag_item.*)
        
        LET p_cont = p_cont + 1
        LET p_ies_gr = "S"
     ELSE
        RETURN
     END IF 
  END IF    
END FUNCTION