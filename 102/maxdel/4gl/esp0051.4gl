#---------------------------------------------------------------------#
# PROGRAMA: ESP0051                                                   #
# OBJETIVO: REPLICA OM PARA OUTRA EMPRESA                             #
#---------------------------------------------------------------------#
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
         p_unit              LIKE ped_itens.pre_unit,
         p_msg               CHAR(500)


  DEFINE p_ordem_montag_mest  RECORD LIKE ordem_montag_mest.*,
         p_ordem_montag_item  RECORD LIKE ordem_montag_item.*,
         p_ordem_montag_grade RECORD LIKE ordem_montag_grade.*,
         p_ordem_montag_lote RECORD LIKE ordem_montag_lote.*,
         p_desc_nat_oper      RECORD LIKE desc_nat_oper.*, 
         p_item_corresp       RECORD LIKE item_corresp.*,
         p_par_desc_oper      RECORD LIKE par_desc_oper.*


  DEFINE p_tela              RECORD
                                cod_empresa    LIKE empresa.cod_empresa,
                                om_de          LIKE ordem_montag_mest.num_om,
                                om_ate         LIKE ordem_montag_mest.num_om
                             END RECORD,
         p_cont              SMALLINT

 END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
  SET LOCK MODE TO WAIT 60
  DEFER INTERRUPT
  LET p_versao = "ESP0051-10.02.01"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("esp0051.iem") RETURNING p_nom_help
  CALL log0180_conecta_usuario()
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0 THEN
      INITIALIZE p_tela.* TO NULL
      CALL esp0051_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION esp0051_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("esp0051") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_esp0051 AT 5,11 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar" "Informa data parametros para processamento."           
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","ESP0051","CO") THEN
        IF esp0051_informa_dados() THEN
             NEXT OPTION "Processar"
        ELSE
           ERROR "Funcao Cancelada"
        END IF
      END IF
    COMMAND "Processar" "Processa copia de pedidos."         
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","ESP0051","CO") THEN
        IF p_tela.om_de IS NOT NULL THEN
           CALL esp0051_processa() 
        ELSE
           ERROR "Informe dados para processamento"
           NEXT OPTION "Informar"
        END IF
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	    CALL ESP0051_sobre()
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
  CLOSE WINDOW w_esp0051
END FUNCTION

#----------------------------------------#
 FUNCTION esp0051_informa_dados()
#----------------------------------------#
  CLEAR FORM
  INITIALIZE p_tela.* TO NULL
  
  CALL log006_exibe_teclas("01 02",p_versao)
  CURRENT WINDOW IS w_esp0051
  LET p_tela.cod_empresa = p_cod_empresa
  DISPLAY BY NAME p_tela.cod_empresa

  INPUT BY NAME p_tela.* WITHOUT DEFAULTS

     AFTER FIELD om_de     
        IF p_tela.om_de      IS NULL THEN
           ERROR "Campo de Preenchimento Obrigatorio"
           NEXT FIELD om_de  
        ELSE 
           IF esp0051_checa_par() THEN
              ERROR "Empresa para copia sem paramentros cadastrados" 
              NEXT FIELD om_de  
           END IF
        END IF

     AFTER FIELD om_ate    
        IF p_tela.om_ate     IS NULL THEN
           ERROR "Campo de Preenchimento Obrigatorio"
           NEXT FIELD om_ate 
        ELSE 
           IF p_tela.om_de > p_tela.om_ate THEN
              ERROR "OM de deve ser menor ou igual om ate" 
              NEXT FIELD om_ate 
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
 FUNCTION esp0051_checa_par()
#----------------------------------------# 

 SELECT * 
   INTO p_par_desc_oper.*		
   FROM par_desc_oper 
  WHERE cod_emp_ofic = p_cod_empresa

 IF sqlca.sqlcode <> 0 THEN 
    RETURN TRUE 
 ELSE 
    RETURN FALSE 
 END IF

    
END FUNCTION 

#----------------------------#
 FUNCTION esp0051_processa()
#----------------------------#
  DEFINE p_cont, i, p_count     SMALLINT

   ERROR "Processando a copia de romaneios "ATTRIBUTE(REVERSE)
   LET p_cont = 0

  DECLARE cq_lista CURSOR FOR
    SELECT *
      FROM ordem_montag_mest        
     WHERE cod_empresa = p_cod_empresa
       AND num_om  >= p_tela.om_de  
       AND num_om  <= p_tela.om_ate 
     ORDER BY num_om     

  FOREACH cq_lista INTO p_ordem_montag_mest.*  

    display "OM :..."  at 7,15
    display p_ordem_montag_mest.num_om at 7,26 

    LET p_count = 0
    LET p_ies_gr = "N"

    SELECT count(*)
      INTO p_count
      FROM ordem_montag_item              
     WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
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
      LET p_ordem_montag_item.cod_empresa = p_par_desc_oper.cod_emp_oper

      SELECT cod_cliente,cod_nat_oper
        INTO p_cod_cliente,p_cod_nat_oper 
        FROM pedidos 
       WHERE num_pedido  = p_ordem_montag_item.num_pedido
         AND cod_empresa = p_cod_empresa                

      SELECT cod_nat_oper  INTO p_cod_nat_oper_it
        FROM ped_item_nat
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ordem_montag_item.num_pedido
         AND num_sequencia  = p_ordem_montag_item.num_sequencia 
      IF sqlca.sqlcode = 0 THEN
         LET p_cod_nat_oper = p_cod_nat_oper_it
      END IF

      SELECT * 
        INTO p_desc_nat_oper.* 
        FROM desc_nat_oper 
       WHERE cod_cliente = p_cod_cliente         
         AND cod_nat_oper = p_cod_nat_oper
          
      IF sqlca.sqlcode <> 0 THEN
         SELECT * 
           INTO p_desc_nat_oper.* 
           FROM desc_nat_oper 
          WHERE cod_cliente = "0"  
            AND cod_nat_oper = p_cod_nat_oper

         IF sqlca.sqlcode <> 0 THEN
            CONTINUE FOREACH
         END IF
      END IF

      IF p_desc_nat_oper.pct_desc_valor > 0 THEN 
         CALL esp0051_proc_valor() 
      ELSE 
         CALL esp0051_proc_quant() 
      END IF 
      LET p_count = p_count + 1 
    END FOREACH

    IF  p_ies_gr = "S" THEN
       LET p_ordem_montag_mest.cod_empresa = p_par_desc_oper.cod_emp_oper
       INSERT INTO ordem_montag_mest VALUES (p_ordem_montag_mest.*)
       IF p_ordem_montag_mest.num_lote_om > 0 THEN
          SELECT * 
            INTO p_ordem_montag_lote.*
            FROM ordem_montag_lote
           WHERE cod_empresa = p_cod_empresa
             AND num_lote_om = p_ordem_montag_mest.num_lote_om  
          IF SQLCA.sqlcode = 0 THEN
             LET p_ordem_montag_lote.cod_empresa = p_par_desc_oper.cod_emp_oper
             INSERT INTO ordem_montag_lote VALUES (p_ordem_montag_lote.*)
          END IF
       END IF      
       CALL esp0051_proc_bnf() 
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
 FUNCTION esp0051_proc_valor()  
#----------------------------# 
 
    INSERT INTO ordem_montag_item VALUES (p_ordem_montag_item.*)
    
    UPDATE ped_itens  SET
                     qtd_pecas_romaneio = p_ordem_montag_item.qtd_reservada
     WHERE cod_empresa = p_par_desc_oper.cod_emp_oper 
       AND num_pedido  = p_ordem_montag_item.num_pedido 
       AND cod_item    = p_ordem_montag_item.cod_item
       AND num_sequencia = p_ordem_montag_item.num_sequencia

    LET p_cont = p_cont + 1
    LET p_ies_gr = "S"

END FUNCTION

#----------------------------#
 FUNCTION esp0051_proc_quant()  
#----------------------------# 
  DEFINE p_qtd_int  DECIMAL (12,0)

  LET p_f2 = (1-(p_desc_nat_oper.pct_desc_oper/100))
  LET p_fq = (1-(p_desc_nat_oper.pct_desc_qtd/100))
  
    SELECT *
      FROM ped_itens_bnf         
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_ordem_montag_item.num_pedido
       AND num_sequencia =  p_ordem_montag_item.num_sequencia
       AND cod_item  = p_ordem_montag_item.cod_item      
    IF sqlca.sqlcode = 0 THEN
      LET p_ordem_montag_item.cod_empresa = p_par_desc_oper.cod_emp_oper 

      INSERT INTO ordem_montag_item VALUES (p_ordem_montag_item.*)
      LET p_qtd  = p_ordem_montag_item.qtd_reservada

       UPDATE ped_itens  SET
                        qtd_pecas_romaneio = p_ordem_montag_item.qtd_reservada
        WHERE cod_empresa = p_par_desc_oper.cod_emp_oper 
          AND num_pedido  = p_ordem_montag_item.num_pedido 
          AND cod_item    = p_ordem_montag_item.cod_item
          AND num_sequencia = p_ordem_montag_item.num_sequencia
      LET p_cont = p_cont + 1
    ELSE
      LET p_qtd  = p_ordem_montag_item.qtd_reservada
      LET p_qtd_v= p_ordem_montag_item.qtd_volume_item
      LET p_pes  = p_ordem_montag_item.pes_total_item 
  
      LET p_qtd_int = p_ordem_montag_item.qtd_reservada * p_fq

      LET p_ordem_montag_item.qtd_reservada = p_qtd_int
      LET p_ordem_montag_item.qtd_volume_item = p_ordem_montag_item.qtd_volume_item * p_fq
      LET p_ordem_montag_item.pes_total_item  = p_ordem_montag_item.pes_total_item * p_fq
 
      UPDATE ordem_montag_item SET
                           qtd_reservada  =   p_ordem_montag_item.qtd_reservada,
                           qtd_volume_item=   p_ordem_montag_item.qtd_volume_item,
                           pes_total_item =   p_ordem_montag_item.pes_total_item  
       WHERE cod_empresa = p_cod_empresa 
         AND num_om      = p_ordem_montag_mest.num_om 
         AND cod_item    = p_ordem_montag_item.cod_item
       AND num_sequencia = p_ordem_montag_item.num_sequencia

       UPDATE ped_itens  SET
                        qtd_pecas_reserv  =   p_ordem_montag_item.qtd_reservada,
                        qtd_pecas_romaneio=   p_qtd - p_qtd_int                 
        WHERE cod_empresa = p_par_desc_oper.cod_emp_oper 
          AND num_pedido  = p_ordem_montag_item.num_pedido 
          AND cod_item    = p_ordem_montag_item.cod_item
          AND num_sequencia = p_ordem_montag_item.num_sequencia

      LET p_ordem_montag_item.cod_empresa = p_par_desc_oper.cod_emp_oper 
      LET p_ordem_montag_item.qtd_reservada = p_qtd - p_qtd_int
      LET p_ordem_montag_item.qtd_volume_item = p_qtd_v - p_ordem_montag_item.qtd_volume_item
      LET p_ordem_montag_item.pes_total_item  = p_pes - p_ordem_montag_item.pes_total_item
    
      INSERT INTO ordem_montag_item VALUES (p_ordem_montag_item.*)

      LET p_cont = p_cont + 1
    END IF   
    LET p_ies_gr = "S"

END FUNCTION
 
#----------------------------#
 FUNCTION esp0051_proc_bnf()  
#----------------------------# 
  
  DECLARE cq_bonif CURSOR FOR
    SELECT a.*
      FROM ordem_montag_item a,
           ped_itens_bnf b        
     WHERE a.cod_empresa   = p_cod_empresa
       AND a.num_om        = p_ordem_montag_mest.num_om
       AND a.cod_empresa   = b.cod_empresa
       AND a.num_pedido    = b.num_pedido 	
       AND a.num_sequencia = b.num_sequencia

  FOREACH cq_bonif INTO p_ordem_montag_item.* 
    DELETE FROM ordem_montag_item 
     WHERE cod_empresa = p_ordem_montag_item.cod_empresa 
       AND num_om      = p_ordem_montag_item.num_om 
       AND num_sequencia = p_ordem_montag_item.num_sequencia 
       AND cod_item    = p_ordem_montag_item.cod_item
  END FOREACH
END FUNCTION

#-----------------------#
 FUNCTION ESP0051_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

