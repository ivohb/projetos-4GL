#---------------------------------------------------------------------#
# PROGRAMA: ESP0202                                                  #
# OBJETIVO: COPIA DE PEDIDOS BASE NAT. OPERACAO x CLIENTE             #
#---------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_den_empresa       LIKE empresa.den_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_ies_impressao     CHAR(01),
         p_grava             CHAR(01),
         comando             CHAR(80),
         p_nom_arquivo       CHAR(100),
         p_versao            CHAR(18),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_last_row          SMALLINT,
         p_ies_cons          SMALLINT,
         p_fator_of          DECIMAL(8,5),
         p_fator_op          DECIMAL(8,5),
         p_f0                DECIMAL(8,5),
         p_f1                DECIMAL(8,5),
         p_fq                DECIMAL(8,5),
         p_f2                DECIMAL(8,5),
         p_codi              LIKE ped_itens.cod_item,
         p_qtd               LIKE ped_itens.qtd_pecas_solic,
         p_cod_nat_oper      LIKE pedidos.cod_nat_oper,
         p_saldo             LIKE ped_itens.qtd_pecas_solic,
         p_unit              LIKE ped_itens.pre_unit,
         p_msg               CHAR(500)


  DEFINE p_pedidos           RECORD LIKE pedidos.*,        
         p_ped_itens         RECORD LIKE ped_itens.*,    
         p_ped_itens_texto   RECORD LIKE ped_itens_texto.*,    
         p_ped_itens_desc    RECORD LIKE ped_itens_desc.*, 
         p_ped_itens_bnf     RECORD LIKE ped_itens_bnf.*,    
         p_desc_nat_oper     RECORD LIKE desc_nat_oper.*, 
         p_item_corresp      RECORD LIKE item_corresp.*,
         p_par_desc_oper     RECORD LIKE par_desc_oper.*,
         p_ped_item_orig     RECORD LIKE ped_item_orig.*

  DEFINE p_tela              RECORD
                                cod_empresa    LIKE empresa.cod_empresa,
                                ped_ini        LIKE pedidos.num_pedido,
                                ped_fim        LIKE pedidos.num_pedido 
                             END RECORD,
         p_cont              SMALLINT
         
  DEFINE p_relat             RECORD
                               cod_emp_orig     LIKE empresa.cod_empresa,
                               cod_emp_dest     LIKE ordem_prod.cod_item,    
                               num_pedido       LIKE pedidos.num_pedido,  
                               cod_item_orig    LIKE item.cod_item,        
                               qtd_item_orig    LIKE ped_itens.qtd_pecas_solic,
                               val_item_orig    LIKE ped_itens.pre_unit,
                               cod_item_dest    LIKE item.cod_item,        
                               qtd_item_dest    LIKE ped_itens.qtd_pecas_solic,
                               val_item_dest    LIKE ped_itens.pre_unit,
                               obs              CHAR(15)                
                             END RECORD

 END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
  SET LOCK MODE TO WAIT 60
  CALL log0180_conecta_usuario()
  DEFER INTERRUPT
  LET p_versao = "ESP0202-10.02.02"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("esp0202.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0 THEN
      INITIALIZE p_tela.* TO NULL
      CALL esp0202_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION esp0202_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("esp0202") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_esp0202 AT 5,11 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar" "Informa data parametros para processamento."           
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","esp0202","CO") THEN
        IF esp0202_informa_dados() THEN
             NEXT OPTION "Processar"
        ELSE
           ERROR "Funcao Cancelada"
        END IF
      END IF
    COMMAND "Processar" "Processa copia de pedidos."         
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","esp0202","CO") THEN
        IF p_tela.ped_ini IS NOT NULL THEN
           CALL esp0202_processa() 
           ERROR "Processamento Efetuado"
        ELSE
           ERROR "Informe dados para processamento"
           NEXT OPTION "Informar"
        END IF
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	    CALL ESP0202_sobre()
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
  CLOSE WINDOW w_esp0202
END FUNCTION

#----------------------------------------#
 FUNCTION esp0202_informa_dados()
#----------------------------------------#
  CLEAR FORM
  INITIALIZE p_tela.* TO NULL
  
  CALL log006_exibe_teclas("01 02",p_versao)
  CURRENT WINDOW IS w_esp0202
  LET p_tela.cod_empresa = p_cod_empresa
  DISPLAY BY NAME p_tela.cod_empresa

  INPUT BY NAME p_tela.* WITHOUT DEFAULTS

     AFTER FIELD ped_ini   
        IF p_tela.ped_ini    IS NULL THEN
           ERROR "Campo de Preenchimento Obrigatorio"
           NEXT FIELD ped_ini
        ELSE 
           IF esp0202_checa_par() THEN
              ERROR "Empresa para copia sem paramentros cadastrados" 
              NEXT FIELD ped_ini 
           END IF
        END IF

     AFTER FIELD ped_fim    
        IF p_tela.ped_fim    IS NULL THEN
           ERROR "Campo de Preenchimento Obrigatorio"
           NEXT FIELD ped_fim
        END IF
   END INPUT

  IF int_flag <> 0 THEN
     RETURN FALSE 
  ELSE
     RETURN TRUE
  END IF

END FUNCTION

#----------------------------------------#
 FUNCTION esp0202_checa_par()
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

#----------------------------------------#
 FUNCTION esp0202_processa()
#----------------------------------------#
  DEFINE p_cont, i, p_count     SMALLINT

  LET p_cont = 0 

  DECLARE cq_lista CURSOR FOR
    SELECT *
      FROM pedidos                  
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido >= p_tela.ped_ini
       AND num_pedido <= p_tela.ped_fim
       AND ies_sit_pedido <> "9" 
     ORDER BY num_pedido 

  FOREACH cq_lista INTO p_pedidos.*            

    display "Pedido:..."  at 7,15
    display p_pedidos.num_pedido at 7,28 

    LET p_count = 0

    SELECT count(*) 
      INTO p_count 
      FROM ped_itens 
     WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
       AND num_pedido = p_pedidos.num_pedido 

    IF p_count > 0 THEN 
       CONTINUE FOREACH
    END IF

   LET p_grava = "N"

###------------------------10/02/2004
   DECLARE cq_valor CURSOR FOR
     SELECT *
       FROM ped_itens                
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_pedidos.num_pedido

    FOREACH cq_valor INTO p_ped_itens.*

      SELECT cod_nat_oper 
        INTO p_cod_nat_oper
        FROM ped_item_nat 
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_pedidos.num_pedido 
         AND num_sequencia  = p_ped_itens.num_sequencia 
      IF sqlca.sqlcode = 0 THEN
        SELECT * 
           INTO p_desc_nat_oper.* 
           FROM desc_nat_oper 
          WHERE cod_cliente = p_pedidos.cod_cliente 
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
      ELSE
         SELECT * 
           INTO p_desc_nat_oper.* 
           FROM desc_nat_oper 
          WHERE cod_cliente = p_pedidos.cod_cliente 
            AND cod_nat_oper = p_pedidos.cod_nat_oper
         IF sqlca.sqlcode <> 0 THEN
            SELECT * 
              INTO p_desc_nat_oper.* 
              FROM desc_nat_oper 
             WHERE cod_cliente = "0"  
               AND cod_nat_oper = p_pedidos.cod_nat_oper
            IF sqlca.sqlcode <> 0 THEN
               CONTINUE FOREACH
            END IF
         END IF
      END IF
###------------------------10/02/2004

      IF p_desc_nat_oper.pct_desc_valor > 0 THEN 
         CALL esp0202_proc_valor() 
      ELSE 
         CALL esp0202_proc_quant() 
      END IF 
    END FOREACH

   IF p_grava = "S"  THEN  

      LET p_cont = p_cont + 1

      LET p_pedidos.cod_empresa = p_par_desc_oper.cod_emp_oper
 
      LET p_pedidos.ies_embal_padrao = 3     

      INSERT INTO pedidos VALUES (p_pedidos.*)

      SELECT *
        INTO p_ped_itens_desc.*
        FROM ped_itens_desc 
       WHERE cod_empresa = p_cod_empresa 
         AND num_pedido  = p_pedidos.num_pedido 
         AND num_sequencia = 0                         
  
      IF sqlca.sqlcode = 0 THEN 
         LET p_ped_itens_desc.cod_empresa = p_par_desc_oper.cod_emp_oper 
       
         INSERT INTO ped_itens_desc VALUES (p_ped_itens_desc.*)
      END IF  

      UPDATE pedidos   set ies_embal_padrao = 3
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_ped_itens.num_pedido
 
      DECLARE cq_valtx CURSOR FOR
        SELECT *
          FROM ped_itens_texto                
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_pedidos.num_pedido

      FOREACH cq_valtx INTO p_ped_itens_texto.*
        LET p_ped_itens_texto.cod_empresa = p_par_desc_oper.cod_emp_oper
  
        INSERT INTO ped_itens_texto VALUES (p_ped_itens_texto.*)
    
      END FOREACH

   END IF 

  END FOREACH    

END FUNCTION

#----------------------------#
 FUNCTION esp0202_proc_valor()  
#----------------------------# 
  DEFINE  l_count     SMALLINT

 LET l_count = 0 
 SELECT COUNT(*)
   INTO l_count
   FROM ped_item_orig
  WHERE cod_empresa = p_cod_empresa
    AND num_pedido  = p_pedidos.num_pedido  
    AND num_sequencia  =  p_ped_itens.num_sequencia
    AND cod_item       =  p_ped_itens.cod_item 
 IF l_count > 0 THEN    
 ELSE 
    LET p_ped_item_orig.cod_empresa    =  p_cod_empresa
    LET p_ped_item_orig.num_pedido     =  p_pedidos.num_pedido 
    LET p_ped_item_orig.num_sequencia  =  p_ped_itens.num_sequencia
    LET p_ped_item_orig.cod_item       =  p_ped_itens.cod_item 
    LET p_ped_item_orig.pre_unit       =  p_ped_itens.pre_unit 
    INSERT INTO ped_item_orig VALUES (p_ped_item_orig.*)
 END IF    

 LET p_grava = "N" 
 LET p_relat.obs = "DESCONTO VALOR"

 LET p_f0 = 100 - p_desc_nat_oper.pct_desc_valor
 LET p_f0 = p_f0 / 100
 LET p_f1 = 1 - p_f0 
 LET p_f2 = (1 - (p_desc_nat_oper.pct_desc_oper / 100))
 LET p_fator_op = p_f1 * p_f2 
 LET p_fator_of = (1 - (p_desc_nat_oper.pct_desc_valor / 100))
  
         
 LET p_saldo = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel 
    
  IF p_saldo > 0 THEN
 
    LET p_grava = "S"

    LET p_unit = p_ped_itens.pre_unit 
    LET p_codi = p_ped_itens.cod_item 
    LET p_qtd  = p_ped_itens.qtd_pecas_solic
  
    LET p_ped_itens.pre_unit = p_ped_itens.pre_unit * p_fator_of 
   
    LET p_relat.val_item_orig = p_ped_itens.pre_unit 

    SELECT * 
      INTO p_item_corresp.* 
      FROM item_corresp
    WHERE cod_item_ped = p_ped_itens.cod_item

    IF sqlca.sqlcode = 0 THEN
        LET p_ped_itens.cod_item = p_item_corresp.cod_item_nf  
        LET p_ped_itens.qtd_pecas_solic = p_ped_itens.qtd_pecas_solic / p_item_corresp.qtd_item_nf 
    END IF

    LET p_relat.qtd_item_orig = p_ped_itens.qtd_pecas_solic
    LET p_relat.cod_item_orig = p_ped_itens.cod_item        
 
    UPDATE ped_itens set pre_unit = p_ped_itens.pre_unit,
                         cod_item = p_ped_itens.cod_item,
                         qtd_pecas_solic= p_ped_itens.qtd_pecas_solic
     WHERE cod_empresa = p_cod_empresa 
       AND num_pedido  = p_ped_itens.num_pedido 
       AND cod_item    = p_codi  
       AND num_sequencia = p_ped_itens.num_sequencia 

    LET p_ped_itens.cod_empresa = p_par_desc_oper.cod_emp_oper 
    LET p_ped_itens.cod_item = p_codi 
    LET p_ped_itens.qtd_pecas_solic = p_qtd
    LET p_ped_itens.pre_unit = p_unit * p_fator_op

    LET p_relat.val_item_dest = p_ped_itens.pre_unit 
    LET p_relat.qtd_item_dest = p_ped_itens.qtd_pecas_solic
    LET p_relat.cod_item_dest = p_ped_itens.cod_item        

     SELECT *
      INTO p_ped_itens_bnf.*
      FROM ped_itens_bnf 
     WHERE cod_empresa = p_cod_empresa 
       AND num_pedido  = p_pedidos.num_pedido 
       AND num_sequencia = p_ped_itens.num_sequencia
  
    IF sqlca.sqlcode = 0 THEN 
       LET p_ped_itens_bnf.cod_empresa = p_par_desc_oper.cod_emp_oper 
       
       INSERT INTO ped_itens_bnf VALUES (p_ped_itens_bnf.*)
       LET p_ped_itens.pre_unit = 0  

    END IF
   
    INSERT INTO ped_itens VALUES (p_ped_itens.*)
    
    SELECT *
      INTO p_ped_itens_desc.*
      FROM ped_itens_desc 
     WHERE cod_empresa = p_cod_empresa 
       AND num_pedido  = p_pedidos.num_pedido 
       AND num_sequencia = p_ped_itens.num_sequencia
  
    IF sqlca.sqlcode = 0 THEN 
       LET p_ped_itens_desc.cod_empresa = p_par_desc_oper.cod_emp_oper 
       
       INSERT INTO ped_itens_desc VALUES (p_ped_itens_desc.*)
    END IF

    LET p_relat.num_pedido    = p_pedidos.num_pedido        
    LET p_relat.cod_emp_orig  = p_cod_empresa               
    LET p_relat.cod_emp_dest  = p_par_desc_oper.cod_emp_oper

 END IF
  
END FUNCTION

#----------------------------#
 FUNCTION esp0202_proc_quant()  
#----------------------------# 

  LET p_grava = "N" 
  LET p_relat.obs = "DESCONTO QTDE"
  LET p_f2 = (1 - (p_desc_nat_oper.pct_desc_oper / 100))

          
    LET p_saldo = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel 

    LET p_relat.val_item_orig = p_ped_itens.pre_unit 
    LET p_ped_itens.pre_unit = p_ped_itens.pre_unit * p_f2
    
  IF p_saldo >  0 THEN
 
    LET p_grava = "S" 

    LET p_relat.cod_item_orig = p_ped_itens.cod_item        
    LET p_relat.val_item_dest = p_ped_itens.pre_unit 
    LET p_relat.qtd_item_dest = p_ped_itens.qtd_pecas_reserv
    LET p_relat.cod_item_dest = p_ped_itens.cod_item        
 
    SELECT *
     INTO p_ped_itens_bnf.*
     FROM ped_itens_bnf 
    WHERE cod_empresa = p_cod_empresa 
      AND num_pedido  = p_pedidos.num_pedido 
      AND num_sequencia = p_ped_itens.num_sequencia
 
    IF sqlca.sqlcode = 0 THEN 
       LET p_ped_itens_bnf.cod_empresa = p_par_desc_oper.cod_emp_oper 
       
       INSERT INTO ped_itens_bnf VALUES (p_ped_itens_bnf.*)
       LET p_ped_itens.pre_unit = 0  
    END IF 

    LET p_ped_itens.cod_empresa = p_par_desc_oper.cod_emp_oper 
    
    INSERT INTO ped_itens VALUES (p_ped_itens.*)
    
    SELECT *
      INTO p_ped_itens_desc.*
      FROM ped_itens_desc
     WHERE cod_empresa = p_cod_empresa 
       AND num_pedido  = p_pedidos.num_pedido 
       AND num_sequencia = p_ped_itens.num_sequencia
  
    IF sqlca.sqlcode = 0 THEN 
       LET p_ped_itens_desc.cod_empresa = p_par_desc_oper.cod_emp_oper 
       
       INSERT INTO ped_itens_desc VALUES (p_ped_itens_desc.*)
    END IF 

    LET p_relat.num_pedido    = p_pedidos.num_pedido        
    LET p_relat.cod_emp_orig  = p_cod_empresa               
    LET p_relat.cod_emp_dest  = p_par_desc_oper.cod_emp_oper

  END IF  

END FUNCTION

#-----------------------#
 FUNCTION ESP0202_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
