#---------------------------------------------------------------------#
# SISTEMA.: PRODUCAO                                                  #
# PROGRAMA: POL0103                                                   #
# MODULOS.: POL0103 - LOG0010 - LOG0050 - LOG0060 - LOG1300 - LOG1400 #
# OBJETIVO: COPIA DE PEDIDOS                                          #
# AUTOR...: INTERNO - ALBRAS                                          #
# DATA....: 29/10/1996                                                #
#---------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_den_empresa       LIKE empresa.den_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_ies_impressao     CHAR(01),
         p_ies_processou     SMALLINT,                                          
         p_grava             CHAR(01),
         comando             CHAR(80),
         p_nom_arquivo       CHAR(100),
         p_versao            CHAR(17),
#        p_versao            CHAR(18),
         p_nom_tela          CHAR(200),
         p_nom_help          CHAR(200),
         p_last_row          SMALLINT,
         p_ies_cons          SMALLINT,
         p_fator_of          DECIMAL(5,3),
         p_fator_op          DECIMAL(5,3),
         p_f0                DECIMAL(5,3),
         p_f1                DECIMAL(5,3),
         p_fq                DECIMAL(5,3),
         p_f2                DECIMAL(5,3),
         p_codi              LIKE ped_itens.cod_item,
         p_qtd               LIKE ped_itens.qtd_pecas_solic,
         p_saldo             LIKE ped_itens.qtd_pecas_solic,
         p_unit              LIKE ped_itens.pre_unit


  DEFINE p_pedidos           RECORD LIKE pedidos.*,        
         p_ped_itens         RECORD LIKE ped_itens.*,    
         p_ped_itens_texto   RECORD LIKE ped_itens_texto.*,    
         p_ped_itens_desc    RECORD LIKE ped_itens_desc.*,    
         p_desc_nat_oper     RECORD LIKE desc_nat_oper.*, 
         p_item_corresp      RECORD LIKE item_corresp.*,
         p_par_desc_oper     RECORD LIKE par_desc_oper.*,
         p_ped_medio_albras  RECORD LIKE ped_medio_albras.*


  DEFINE p_tela              RECORD
                                cod_empresa    LIKE empresa.cod_empresa,
                                dat_de         DATE
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
  DEFER INTERRUPT
  LET p_versao = "POL0103-04.10.04"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0103.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("MANUFAT")
# CALL log001_acessa_usuario("MANUFAT","ESPECI")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0 THEN
      LET p_ies_processou = FALSE                                              
      INITIALIZE p_tela.* TO NULL
      CALL pol0103_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0103_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0103") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0103 AT 5,11 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar" "Informa data parametros para processamento."           
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","POL0103","CO") THEN
        IF pol0103_informa_dados() THEN
             NEXT OPTION "Processar"
        ELSE
           ERROR "Funcao Cancelada"
        END IF
      END IF
    COMMAND "Processar" "Processa copia de pedidos."         
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","POL0103","CO") THEN
        IF p_tela.dat_de IS NOT NULL THEN
           IF pol0103_checa_par() THEN
              ERROR "Empresa para copia sem paramentros cadastrados" 
              NEXT OPTION "Informar" 
           ELSE
              CALL pol0103_processa() 
           END IF
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
       IF p_ies_processou = FALSE THEN
         ERROR "Funcao deve ser processada"
         NEXT OPTION "Processar"
      ELSE
         EXIT MENU
      END IF
  END MENU
  CLOSE WINDOW w_pol0103
END FUNCTION

#----------------------------------------#
 FUNCTION pol0103_informa_dados()
#----------------------------------------#
  CLEAR FORM
  INITIALIZE p_tela.* TO NULL
  
  CALL log006_exibe_teclas("01 02",p_versao)
  CURRENT WINDOW IS w_pol0103
  LET p_tela.cod_empresa = p_cod_empresa
  DISPLAY BY NAME p_tela.cod_empresa
  LET p_tela.dat_de =  TODAY - 7
  DISPLAY BY NAME p_tela.dat_de


  INPUT BY NAME p_tela.* WITHOUT DEFAULTS


     AFTER FIELD dat_de    
        IF p_tela.dat_de     IS NULL THEN
           ERROR "Campo de Preenchimento Obrigatorio"
           NEXT FIELD dat_de 
        ELSE 
           IF pol0103_checa_par() THEN
              ERROR "Empresa para copia sem paramentros cadastrados" 
              NEXT FIELD dat_de 
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
 FUNCTION pol0103_checa_par()
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
 FUNCTION pol0103_processa()
#----------------------------------------#
  DEFINE p_cont, i, p_count     SMALLINT
 

IF log028_saida_relat(17,35) IS NOT NULL THEN
   ERROR "Processando a copia de pedidos e relatorio."ATTRIBUTE(REVERSE)
   LET p_cont = 0
   IF p_ies_impressao = "S" THEN
      START REPORT pol0103_relat TO PIPE p_nom_arquivo
   ELSE 
      START REPORT pol0103_relat TO p_nom_arquivo
   END IF

  LET p_cont = 0 

  LET p_ies_processou = TRUE                                                  

  DECLARE cq_lista CURSOR FOR
    SELECT *
      FROM pedidos                  
     WHERE cod_empresa = p_cod_empresa
       AND dat_emis_repres >= p_tela.dat_de 
       AND ies_sit_pedido <> "9" 
     ORDER BY num_pedido 
    

  FOREACH cq_lista INTO p_pedidos.*            

    display "Pedido:..."  at 7,15
    display p_pedidos.num_pedido at 7,28 

    SELECT * 
      INTO p_desc_nat_oper.* 
      FROM desc_nat_oper 
     WHERE cod_cliente = p_pedidos.cod_cliente 
       AND cod_nat_oper = p_pedidos.cod_nat_oper

    LET p_count = 0


    SELECT count(*) 
      INTO p_count 
      FROM ped_itens 
     WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
       AND num_pedido = p_pedidos.num_pedido 

    IF p_count > 0 THEN 
       CONTINUE FOREACH
    END IF

    SELECT * 
      INTO p_desc_nat_oper.* 
      FROM desc_nat_oper 
     WHERE cod_cliente = p_pedidos.cod_cliente 
       AND cod_nat_oper = p_pedidos.cod_nat_oper

    IF sqlca.sqlcode <> 0 THEN 
       LET  p_desc_nat_oper.pct_desc_valor = 0  
       LET  p_desc_nat_oper.pct_desc_qtd   = 0  
       CALL pol0103_proc_inex()
    ELSE 
       IF p_desc_nat_oper.pct_desc_valor > 0 THEN 
          CALL pol0103_proc_valor() 
       ELSE 
          CALL pol0103_proc_quant() 
       END IF 
    END IF 

   IF p_grava = "S"  THEN  

      LET p_cont = p_cont + 1

      LET p_pedidos.cod_empresa = p_par_desc_oper.cod_emp_oper
 
      IF p_desc_nat_oper.pct_desc_qtd > 0 
      AND p_desc_nat_oper.pct_desc_qtd < 100 THEN 
         LET p_pedidos.ies_embal_padrao = 3     
      END IF 

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

      IF p_desc_nat_oper.pct_desc_valor > 0 THEN 
         UPDATE pedidos   set cod_nat_oper = 199 
          WHERE cod_empresa = p_cod_empresa 
            AND num_pedido  = p_ped_itens.num_pedido 
      ELSE
         IF p_desc_nat_oper.pct_desc_qtd > 0 
         AND p_desc_nat_oper.pct_desc_qtd < 100 THEN 
            UPDATE pedidos   set ies_embal_padrao = 3 
             WHERE cod_empresa = p_cod_empresa 
               AND num_pedido  = p_ped_itens.num_pedido 
         END IF
      END IF

   END IF 

  END FOREACH    

  IF p_cont = 0 THEN
     ERROR "Nao existem dados para serem listados "
     RETURN 
  ELSE
     IF p_ies_impressao = "S" THEN
        ERROR "Emissao do relatorio efetuada com sucesso"
        RETURN
     ELSE
        ERROR "Relatorio gravado no arquivo ",p_nom_arquivo
        RETURN 
     END IF
  END IF    
  FINISH REPORT pol0103_relat
END IF
END FUNCTION

#----------------------------#
 FUNCTION pol0103_proc_inex()  
#----------------------------# 

  LET p_grava = "N" 
  LET p_relat.obs = "SEM DESCONTO"

  DECLARE cq_inex  CURSOR FOR
    SELECT *
      FROM ped_itens                
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_inex INTO p_ped_itens.*
 
    LET p_saldo = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel 
    
    IF p_saldo <= 0 THEN
       CONTINUE FOREACH
    END IF
 
    LET p_grava = "S"  
      
    LET p_ped_itens.cod_empresa = p_par_desc_oper.cod_emp_oper 
    LET p_ped_itens.qtd_pecas_reserv = p_ped_itens.qtd_pecas_solic
    LET p_relat.val_item_dest = p_ped_itens.pre_unit 
    LET p_relat.val_item_orig = p_ped_itens.pre_unit 
    LET p_relat.qtd_item_dest = p_ped_itens.qtd_pecas_solic
    LET p_relat.qtd_item_orig = p_ped_itens.qtd_pecas_solic
    LET p_relat.cod_item_dest = p_ped_itens.cod_item        
    LET p_relat.cod_item_orig = p_ped_itens.cod_item        
 
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
 
    LET p_ped_medio_albras.cod_empresa   = p_cod_empresa     
    LET p_ped_medio_albras.num_pedido    = p_ped_itens.num_pedido 
    LET p_ped_medio_albras.cod_item      = p_ped_itens.cod_item              
    LET p_ped_medio_albras.num_sequencia = p_ped_itens.num_sequencia
    LET p_ped_medio_albras.val_preco_medio = p_ped_itens.pre_unit
    LET p_ped_medio_albras.qtd_total = p_ped_itens.qtd_pecas_solic

    INSERT INTO ped_medio_albras VALUES (p_ped_medio_albras.*)

    LET p_relat.num_pedido    = p_pedidos.num_pedido        
    LET p_relat.cod_emp_orig  = p_cod_empresa               
    LET p_relat.cod_emp_dest  = p_par_desc_oper.cod_emp_oper

    OUTPUT TO REPORT pol0103_relat(p_relat.*)

  END FOREACH  

  DECLARE cq_intxt CURSOR FOR
    SELECT *
      FROM ped_itens_texto                
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_intxt INTO p_ped_itens_texto.*
    LET p_ped_itens_texto.cod_empresa = p_par_desc_oper.cod_emp_oper
 
    INSERT INTO ped_itens_texto VALUES (p_ped_itens_texto.*)
    
  END FOREACH
  
END FUNCTION


#----------------------------#
 FUNCTION pol0103_proc_valor()  
#----------------------------# 

 LET p_grava = "N" 
 LET p_relat.obs = "DESCONTO VALOR"

 LET p_f0 = 100 - p_desc_nat_oper.pct_desc_valor
 LET p_f0 = p_f0 / 100
 LET p_f1 = 1 - p_f0 
 LET p_f2 = (1 - (p_desc_nat_oper.pct_desc_oper / 100))
 LET p_fator_op = p_f1 * p_f2 
 LET p_fator_of = (1 - (p_desc_nat_oper.pct_desc_valor / 100))
  
  DECLARE cq_valor CURSOR FOR
    SELECT *
      FROM ped_itens                
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_valor INTO p_ped_itens.*
          
    LET p_saldo = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel 
    
    IF p_saldo <= 0 THEN
       CONTINUE FOREACH
    END IF
 
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

# osvaldo
    LET p_ped_medio_albras.val_preco_medio = p_ped_itens.pre_unit
    LET p_ped_medio_albras.qtd_total = p_ped_itens.qtd_pecas_solic
# osvaldo
 
    UPDATE ped_itens set pre_unit = p_ped_itens.pre_unit,
                         cod_item = p_ped_itens.cod_item,
                         qtd_pecas_solic= p_ped_itens.qtd_pecas_solic
     WHERE cod_empresa = p_cod_empresa 
       AND num_pedido  = p_ped_itens.num_pedido 
       AND cod_item    = p_codi  
       AND num_sequencia = p_ped_itens.num_sequencia 

    DISPLAY sqlca.sqlcode at 5,5


    UPDATE ped_agrupa_albras set pre_unit = p_ped_itens.pre_unit,
                                 cod_item = p_ped_itens.cod_item
     WHERE cod_empresa = p_cod_empresa 
       AND num_pedido  = p_ped_itens.num_pedido 
       AND cod_item    = p_codi  
       AND num_sequencia = p_ped_itens.num_sequencia 

    LET p_ped_itens.cod_empresa = p_par_desc_oper.cod_emp_oper 
    LET p_ped_itens.cod_item = p_codi 
    LET p_ped_itens.qtd_pecas_solic = p_qtd
    LET p_ped_itens.pre_unit = p_unit * p_fator_op

# osvaldo
    LET p_ped_medio_albras.val_preco_medio = p_ped_medio_albras.val_preco_medio
                                             + p_ped_itens.pre_unit
# osvaldo

    LET p_relat.val_item_dest = p_ped_itens.pre_unit 
    LET p_relat.qtd_item_dest = p_ped_itens.qtd_pecas_solic
    LET p_relat.cod_item_dest = p_ped_itens.cod_item        
    
    INSERT INTO ped_itens VALUES (p_ped_itens.*)

# osvaldo
    LET p_ped_medio_albras.cod_empresa   = p_cod_empresa     
    LET p_ped_medio_albras.num_pedido    = p_ped_itens.num_pedido 
    LET p_ped_medio_albras.cod_item      = p_ped_itens.cod_item              
    LET p_ped_medio_albras.num_sequencia = p_ped_itens.num_sequencia

    INSERT INTO ped_medio_albras VALUES (p_ped_medio_albras.*)
# osvaldo
    
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

    OUTPUT TO REPORT pol0103_relat(p_relat.*)


  END FOREACH  

  DECLARE cq_valtx CURSOR FOR
    SELECT *
      FROM ped_itens_texto                
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_valtx INTO p_ped_itens_texto.*
    LET p_ped_itens_texto.cod_empresa = p_par_desc_oper.cod_emp_oper
 
    INSERT INTO ped_itens_texto VALUES (p_ped_itens_texto.*)
    
  END FOREACH
  
END FUNCTION


#----------------------------#
 FUNCTION pol0103_proc_quant()  
#----------------------------# 
  DEFINE    p_qtd_01  LIKE ped_itens.qtd_pecas_solic,
            p_qtd_98  LIKE ped_itens.qtd_pecas_solic,
            p_pre_01  LIKE ped_itens.pre_unit,
            p_pre_98  LIKE ped_itens.pre_unit

  LET p_grava = "N" 
  LET p_relat.obs = "DESCONTO QTDE"

  LET p_f2 = (1-(p_desc_nat_oper.pct_desc_oper/100))
  LET p_fq = (1 - (p_desc_nat_oper.pct_desc_qtd/100))
  
  DECLARE cq_quant CURSOR FOR
    SELECT *
      FROM ped_itens                
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_quant INTO p_ped_itens.*
          
    LET p_saldo = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel 
    
    IF p_saldo <= 0 THEN
       CONTINUE FOREACH
    END IF
 
    LET p_grava = "S" 
# toni
    LET p_pre_01 = p_ped_itens.pre_unit 
# toni
    
    LET p_unit = p_ped_itens.pre_unit  
    LET p_codi = p_ped_itens.cod_item 
    LET p_qtd  = p_ped_itens.qtd_pecas_solic
# osvaldo
    LET p_ped_medio_albras.qtd_total = p_ped_itens.qtd_pecas_solic
# osvaldo
  
    LET p_relat.val_item_orig = p_ped_itens.pre_unit 

    LET p_ped_itens.qtd_pecas_solic = p_ped_itens.qtd_pecas_solic * p_fq  

# toni tirar esta linha 
#    LET p_ped_medio_albras.val_preco_medio = p_ped_itens.pre_unit
# toni

    LET p_relat.qtd_item_orig = p_ped_itens.qtd_pecas_solic
    LET p_relat.cod_item_orig = p_ped_itens.cod_item        
 
    UPDATE ped_itens set
       qtd_pecas_solic= p_ped_itens.qtd_pecas_solic
    WHERE cod_empresa = p_cod_empresa 
      AND num_pedido  = p_ped_itens.num_pedido 
      AND cod_item    = p_ped_itens.cod_item 
      AND num_sequencia = p_ped_itens.num_sequencia 
# toni
    LET p_qtd_01 = p_ped_itens.qtd_pecas_solic
# toni

    LET p_ped_itens.cod_empresa = p_par_desc_oper.cod_emp_oper 
    LET p_ped_itens.qtd_pecas_solic = p_qtd 
    LET p_ped_itens.qtd_pecas_reserv = p_qtd * p_fq
    LET p_ped_itens.pre_unit = p_ped_itens.pre_unit * p_f2        

    LET p_relat.val_item_dest = p_ped_itens.pre_unit 
    LET p_relat.qtd_item_dest = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_reserv
    LET p_relat.cod_item_dest = p_ped_itens.cod_item        
    
    INSERT INTO ped_itens VALUES (p_ped_itens.*)

# toni
    LET p_pre_98 = p_ped_itens.pre_unit 

    LET p_qtd_98 = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_reserv

    LET p_ped_medio_albras.val_preco_medio = ((p_qtd_01 * p_pre_01) + (p_qtd_98 * p_pre_98)) / (p_qtd_01 + p_qtd_98) 
# toni


# osvaldo
    LET p_ped_medio_albras.cod_empresa   = p_cod_empresa     
    LET p_ped_medio_albras.num_pedido    = p_ped_itens.num_pedido 
    LET p_ped_medio_albras.cod_item      = p_ped_itens.cod_item              
    LET p_ped_medio_albras.num_sequencia = p_ped_itens.num_sequencia

    INSERT INTO ped_medio_albras VALUES (p_ped_medio_albras.*)
# osvaldo
    
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

    OUTPUT TO REPORT pol0103_relat(p_relat.*)

  END FOREACH  

  DECLARE cq_qtdtx CURSOR FOR
    SELECT *
      FROM ped_itens_texto                
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_pedidos.num_pedido

  FOREACH cq_qtdtx INTO p_ped_itens_texto.*
    LET p_ped_itens_texto.cod_empresa = p_par_desc_oper.cod_emp_oper
 
    INSERT INTO ped_itens_texto VALUES (p_ped_itens_texto.*)
    
  END FOREACH
  
END FUNCTION


#----------------------------#
 REPORT pol0103_relat(p_relat)
#----------------------------# 
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

 OUTPUT LEFT   MARGIN 0
        TOP    MARGIN 0
        BOTTOM MARGIN 1
        PAGE LENGTH  60
{
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
0        1         2         3         4         5         6         7 
12345678901234567890123456789012345678901234567890123456789012345678901234567890
POL0103                       RELATORIO DE CONSUMO MEDIO                 FL. ##&
PERIODO DE 99/99/999  ATE  99/99/999      EXTRAIDO EM DD/MM/YY AS HH.MM.SS HRS.
 
EM EM NUM.   COD.ITEM        QUANT.        VALOR          COD.ITEM        QUANT.        VALOR 
OR DS PEDIDO ORIGEM          ORIGEM        ORIGEM         DESTINO         DESTINO       DESTINO  
-- -- ------ --------------- ------------- ------------- --------------- ------------- -------------
XX XX XXXXXX XXXXXXXXXXXXXXX ##,##&.&&&&&& ##,###,##&.&& XXXXXXXXXXXXXXX ##,##&.&&&&&& ##,###,##&.&&
0        1         2         3         4         5         6         7         8
12345678901234567890123456789012345678901234567890123456789012345678901234567890

}

FORMAT

PAGE HEADER  
    SELECT den_empresa INTO p_den_empresa
      FROM empresa
     WHERE cod_empresa = p_cod_empresa
    IF  sqlca.sqlcode  = NOTFOUND THEN
        LET p_den_empresa = "EMPRESA NAO CADASTRADA"
    END IF
  
    PRINT COLUMN 001, p_den_empresa 
    PRINT COLUMN 001, "POL0103",
          COLUMN 031, "RELATORIO DE COPIA DE PEDIDO",
          COLUMN 073, "FL. ", PAGENO USING "##&"
    PRINT COLUMN 001, "PERIODO ",p_tela.dat_de,
          COLUMN 044, "EXTRAIDO EM ",TODAY USING "DD/MM/YY"," AS ",TIME," HRS."
    SKIP  1 LINE
    PRINT COLUMN 001, "EM EM NUM.   COD.ITEM        QUANT.        VALOR          COD.ITEM        QUANT.        VALOR"
    PRINT COLUMN 001, "OR DS PEDIDO ORIGEM          ORIGEM        ORIGEM         DESTINO         DESTINO       DESTINO       OBSERVACAO"   
    PRINT COLUMN 001, "-- -- ------ --------------- ------------- ------------- --------------- ------------- -------------  ---------------"
    SKIP 1 LINE


ON  EVERY ROW
     PRINT COLUMN 001, p_relat.cod_emp_orig   USING "##",  
           COLUMN 004, p_relat.cod_emp_dest   USING "##", 
           COLUMN 007, p_relat.num_pedido     USING "######",           
           COLUMN 014, p_relat.cod_item_orig,  
           COLUMN 030, p_relat.qtd_item_orig  USING "##,##&.&&&",
           COLUMN 045, p_relat.val_item_orig  USING "###,##&.&&&&",
           COLUMN 058, p_relat.cod_item_dest,  
           COLUMN 074, p_relat.qtd_item_dest  USING "##,##&.&&&",
           COLUMN 089, p_relat.val_item_dest  USING "###,##&.&&&&", 
           COLUMN 103, p_relat.obs     

ON  LAST ROW
    LET p_last_row = TRUE

PAGE TRAILER
    IF  p_last_row THEN
        LET p_last_row = FALSE
    ELSE
    END IF

END REPORT
#---------------------------- FIM DE PROGRAMA ---------------------------------#
