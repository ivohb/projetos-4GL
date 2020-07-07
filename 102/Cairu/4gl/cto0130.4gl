#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: cto0130                                                 #
# MODULOS.: cto0130 LOG0010 LOG0030 LOG0050 LOG0060 LOG0130 LOG0280 #
# OBJETIVO: EFETUA A ENTRADA DE NOTAS FISCAIS DE BENEFICIAMENTO PARA#
#           A CAIRU QUE SAO EFETUADAS NA PENITENCIARIA E CADEIA     #
# CLIENTE.: CAIRU                                                   #
# DATA....: 18/02/2001                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
       	 p_user              LIKE usuario.nom_usuario,
       	 p_status            SMALLINT,
       	 comando             CHAR(80),
       	 p_nom_arquivo       CHAR(100),
       	 p_den_empresa       LIKE empresa.den_empresa,
       	 p_msg               CHAR(500),
       	 p_trans_nf		       LIKE fat_nf_mestre.trans_nota_fiscal


  DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

 END GLOBALS

 DEFINE p_itens_remessa
      RECORD
        cod_empresa      CHAR(02),
        cod_item         CHAR(15),
        cod_cla_fisc     CHAR(10),
        pct_ipi          DECIMAL(6,3),
        pre_unit_nf      DECIMAL(17,6)
      END RECORD 

 DEFINE p_tela            
      RECORD
        cod_empresa         CHAR(02),
        num_aviso_rec       DECIMAL(6,0),
        num_nff1            LIKE fat_nf_mestre.nota_fiscal,
        num_nff2            LIKE fat_nf_mestre.nota_fiscal,
        num_nff3            LIKE fat_nf_mestre.nota_fiscal,
        num_nff4            LIKE fat_nf_mestre.nota_fiscal,
        num_nff5            LIKE fat_nf_mestre.nota_fiscal
      END RECORD 

 DEFINE p_aviso_rec_cairu  RECORD 
        cod_empresa        CHAR(02),
        num_aviso_rec      INTEGER,
        cod_item_benef     CHAR(15)
 END RECORD

 DEFINE p_nf_retorno_cairu RECORD
    cod_empresa char(2),
    num_aviso_rec decimal(6,0),
    num_nff1 decimal(6),
    num_nff2 decimal(6),
    num_nff3 decimal(6),
    num_nff4 decimal(6),
    num_nff5 decimal(6)
 END RECORD
 
 DEFINE p_nf_sup           RECORD LIKE   nf_sup.*,
        p_estrutura        RECORD LIKE   estrutura.*,
        p_aviso_rec        RECORD LIKE   aviso_rec.*,
        p_aviso_rec_cp     RECORD LIKE   aviso_rec.*,
        p_cod_item         LIKE          aviso_rec.cod_item,
        p_den_item         LIKE          item.den_item,
        p_cod_unid_med     LIKE          item.cod_unid_med,
        p_pre_unit_nf      LIKE          fat_nf_item.preco_unit_liquido,  
        p_ies_tip_item     LIKE          item.ies_tip_item,   
        p1_ies_tip_item    LIKE          item.ies_tip_item,   
        p_total_nota       LIKE          nf_sup.val_tot_nf_d,
        p_num_seq          LIKE          aviso_rec.num_seq,   
        p_tem_benef        CHAR(001),
        p_ja_processado    CHAR(001),
        p_ies_penitenc     CHAR(001),
        p_num_programa     CHAR(007),
        p_num_ar           LIKE aviso_rec.num_aviso_rec,
        p_qtd_item         LIKE aviso_rec.qtd_declarad_nf

MAIN
CALL log0180_conecta_usuario()
LET p_versao = "cto0130-10.02.07"
WHENEVER ANY ERROR CONTINUE
LET p_num_programa = "cto0130"                       

SET ISOLATION TO DIRTY READ
                       
DEFER INTERRUPT
                       
  CALL log130_procura_caminho("sup.iem") RETURNING comando
  OPTIONS
    FIELD ORDER UNCONSTRAINED,
     HELP FILE comando

  LET p_num_ar = arg_val(1)

    

    DROP table t_itens_remessa 

    CREATE TABLE t_itens_remessa
    (cod_empresa      CHAR(02),
     cod_item         CHAR(15),
     cod_cla_fisc     CHAR(10),
     pct_ipi          DECIMAL(6,3),
     pre_unit_nf      DECIMAL(17,6))

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-TEMPORARIA")
   END IF

 CREATE UNIQUE INDEX ix_it_rem_1 ON t_itens_remessa(cod_item, pre_unit_nf)

    

   CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL cto0130_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION cto0130_controle()
#--------------------------#

  CALL log006_exibe_teclas("01", p_versao)
  INITIALIZE p_nf_sup.*,    p_aviso_rec.*, p_estrutura.*,                      
             p_aviso_rec_cp.*  
                               TO NULL
  CALL log130_procura_caminho("cto0130") RETURNING comando
  OPEN WINDOW w_cto0130 AT 2,02 WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 
  MENU "OPCAO"

    COMMAND "Informar" "Informar notas fiscais de componentes, enviadas "
      HELP 002
      MESSAGE ""
        IF cto0130_inicializa() = TRUE    THEN
       	   IF log005_seguranca(p_user,"SUPRIMEN",p_num_programa,"MO")  
           THEN
              CALL cto0130_processar()
           END IF
        END IF   


      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
	 			CALL cto0130_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix

    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_cto0130
END FUNCTION

#----------------------------#
 FUNCTION cto0130_inicializa()
#----------------------------#


 SELECT *  INTO p_nf_sup.* FROM nf_sup
  WHERE cod_empresa = p_cod_empresa           
    AND num_aviso_rec = p_num_ar

 IF sqlca.sqlcode = 0 
 THEN
   SELECT * INTO p_nf_retorno_cairu.*                         
     FROM nf_retorno_cairu 
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar 
    IF   sqlca.sqlcode = 0    THEN 
         LET p_tela.num_nff1 = p_nf_retorno_cairu.num_nff1
         LET p_tela.num_nff2 = p_nf_retorno_cairu.num_nff2 
         LET p_tela.num_nff3 = p_nf_retorno_cairu.num_nff3
         LET p_tela.num_nff4 = p_nf_retorno_cairu.num_nff4
         LET p_tela.num_nff5 = p_nf_retorno_cairu.num_nff5
    END IF
 ELSE
   ERROR " Aviso de recebimento nao encontrado. "
   RETURN FALSE
 END IF

 LET p_tem_benef      = 'N' 

 DECLARE ct_ar    CURSOR FOR
   SELECT aviso_rec.cod_item, item.ies_tip_item   FROM aviso_rec, item        
    WHERE aviso_rec.cod_empresa   = p_cod_empresa     AND
          aviso_rec.num_aviso_rec = p_num_ar          AND
          aviso_rec.cod_empresa   = item.cod_empresa  AND
          aviso_rec.cod_item      = item.cod_item         

 FOREACH ct_ar INTO p_cod_item, p_ies_tip_item 

   IF    sqlca.sqlcode = 0  
   AND   p_ies_tip_item = 'B'  
   THEN
      LET p_tem_benef   = 'S' 
   END IF 
     
 END FOREACH

 IF p_tem_benef  = 'N'   THEN 
    ERROR " Nota fiscal de entrada, nao tem itens beneficiados"
    RETURN FALSE
 END IF 


 RETURN TRUE  
END FUNCTION
#-------------------------------#
 FUNCTION cto0130_entrada_dados()
#-------------------------------#

  DEFINE p_funcao            CHAR(30)
  CALL log006_exibe_teclas("01 02 07",p_versao)

  CURRENT WINDOW IS w_cto0130

  LET p_tela.cod_empresa   = p_cod_empresa
  LET p_tela.num_aviso_rec = p_num_ar     

  DISPLAY BY NAME p_tela.* 
  INPUT BY NAME p_tela.* WITHOUT DEFAULTS
    
  AFTER FIELD  num_nff1     
     IF    p_tela.num_nff1              IS NOT NULL
     AND   p_nf_retorno_cairu.num_nff1  IS NOT NULL        
     AND   p_tela.num_nff1     <> p_nf_retorno_cairu.num_nff1 THEN
           ERROR "NOTA FISCAL JA PROCESSADA, NAO PODE O PODE SER ALTERADA" 
           NEXT FIELD num_nff1
     END IF
     IF    cto0130_pesq_nff(p_tela.num_nff1)   THEN 
     ELSE
           NEXT FIELD num_nff1
     END IF

  AFTER FIELD  num_nff2     
     IF    p_tela.num_nff1     IS NULL  THEN 
           ERROR "NOTA FISCAL ANTERIOR ESTA EM BRANCO, PREENCHER NA ORDEM" 
           NEXT FIELD num_nff1
     ELSE
        IF    p_tela.num_nff2     IS NOT NULL
        AND   p_nf_retorno_cairu.num_nff2  IS NOT NULL        
        AND   p_tela.num_nff2     <> p_nf_retorno_cairu.num_nff2 THEN
           ERROR "NOTA FISCAL JA PROCESSADA, NAO PODE O PODE SER ALTERADA" 
           NEXT FIELD num_nff2
        END IF
     END IF
     IF p_tela.num_nff2     IS NOT NULL THEN
        IF    cto0130_pesq_nff(p_tela.num_nff2)   THEN 
        ELSE
              NEXT FIELD num_nff2
        END IF
     END IF

  AFTER FIELD  num_nff3     
     IF    p_tela.num_nff2     IS NULL  THEN 
           ERROR "NOTA FISCAL ANTERIOR ESTA EM BRANCO, PREENCHER NA ORDEM" 
           NEXT FIELD num_nff2
     ELSE
        IF    p_tela.num_nff3     IS NOT NULL
        AND   p_nf_retorno_cairu.num_nff3  IS NOT NULL        
        AND   p_tela.num_nff3     <> p_nf_retorno_cairu.num_nff3 THEN
           ERROR "NOTA FISCAL JA PROCESSADA, NAO PODE O PODE SER ALTERADA" 
           NEXT FIELD num_nff3
        END IF
     END IF
     IF p_tela.num_nff3 IS NOT NULL THEN
        IF    cto0130_pesq_nff(p_tela.num_nff3)   THEN 
        ELSE
              NEXT FIELD num_nff3
        END IF
     END IF 
     
  AFTER FIELD  num_nff4     
     IF    p_tela.num_nff3     IS NULL  THEN 
           ERROR "NOTA FISCAL ANTERIOR ESTA EM BRANCO, PREENCHER NA ORDEM" 
           NEXT FIELD num_nff3
     ELSE
        IF    p_tela.num_nff4     IS NOT NULL
        AND   p_nf_retorno_cairu.num_nff4  IS NOT NULL        
        AND   p_tela.num_nff4     <> p_nf_retorno_cairu.num_nff4 THEN
           ERROR "NOTA FISCAL JA PROCESSADA, NAO PODE O PODE SER ALTERADA" 
           NEXT FIELD num_nff4
        END IF
     END IF
     IF p_tela.num_nff4 IS NOT NULL THEN     
        IF    cto0130_pesq_nff(p_tela.num_nff4)    THEN 
        ELSE
              NEXT FIELD num_nff4
        END IF
     END IF
      
  AFTER FIELD  num_nff5     
     IF    p_tela.num_nff5 IS NULL  THEN 
           ERROR "NOTA FISCAL ANTERIOR ESTA EM BRANCO, PREENCHER NA ORDEM" 
           NEXT FIELD num_nff5
     ELSE
        IF    p_tela.num_nff5     IS NOT NULL
        AND   p_nf_retorno_cairu.num_nff5  IS NOT NULL        
        AND   p_tela.num_nff5     <> p_nf_retorno_cairu.num_nff5 THEN
           ERROR "NOTA FISCAL JA PROCESSADA, NAO PODE O PODE SER ALTERADA" 
           NEXT FIELD num_nff5
        END IF
     END IF
     IF p_tela.num_nff5 IS NOT NULL THEN
        IF    cto0130_pesq_nff(p_tela.num_nff5)    THEN 
        ELSE
              NEXT FIELD num_nff5
        END IF
     END IF   

  END  INPUT 
 
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_cto0130
  IF int_flag = 0 
  THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION  cto0130_pesq_nff(p_num_nff)
#-----------------------------------------#

   DEFINE p_num_nff LIKE fat_nf_mestre.nota_fiscal,
          p_cod_cliente   LIKE clientes.cod_cliente,
          p_cgc_cli       LIKE clientes.num_cgc_cpf,
          p_cgc_for       LIKE fornecedor.num_cgc_cpf,
          p_achou         SMALLINT

   LET p_achou = FALSE
   
   DECLARE cq_fat cursor for
    SELECT  b.num_cgc_cpf, a.trans_nota_fiscal  
      INTO  p_cgc_cli, p_trans_nf
      FROM  fat_nf_mestre a, clientes b
     WHERE a.empresa = p_cod_empresa           
       AND a.nota_fiscal     = p_num_nff
       AND a.cliente = b.cod_cliente
   
   FOREACH cq_fat into p_cgc_cli, p_trans_nf
   
     IF STATUS <> 0           THEN
        call log003_err_sql('Lendo', 'fat_nf_mestre/clientes')
        RETURN FALSE
     END IF 
     
     LET p_achou = TRUE
     EXIT FOREACH
  
  END FOREACH

  if not p_achou then
     ERROR 'Nota fiscal n�o encontrada!'
     RETURN FALSE
  end if
  
    SELECT num_cgc_cpf     
      INTO p_cgc_for
      FROM fornecedor a, nf_sup b
     WHERE a.cod_fornecedor=b.cod_fornecedor
       AND b.cod_empresa=p_cod_empresa
       AND b.num_aviso_rec=p_num_ar     
     GROUP BY 1
     
   IF sqlca.sqlcode <>  0   
      THEN
      CALL log003_err_sql("SELECT","FORNECEDOR-NOTA")
      RETURN 
   END IF

   IF p_cgc_cli <> p_cgc_for   THEN 
      ERROR "CNPJ DA NOTA DE RETORNO NAO CONFERE COM A DE REMESSA" 
      RETURN FALSE
   END IF 
     
   RETURN TRUE  

END FUNCTION

#---------------------------#
 FUNCTION cto0130_processar()
#---------------------------#

   IF cto0130_entrada_dados()
   THEN
     CALL cto0130_atualiza_tabelas()
     IF p_ja_processado  = 'S'   THEN 
        ERROR " Todos os itens ja foram processados"
     ELSE
        IF p_ja_processado  = 'N'   THEN
           MESSAGE " Processamento efetuada com Sucesso " ATTRIBUTE(REVERSE)
        ELSE
           MESSAGE "ITEM ", p_estrutura.cod_item_compon," NAO CONSTA NAS NFS DE RETORNO INFORMADAS" ATTRIBUTE(REVERSE)
        END IF
     END IF 
   ELSE
     MESSAGE " Processamento Cancelada. " ATTRIBUTE(REVERSE)
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION cto0130_atualiza_tabelas()
#---------------------------------#

 CALL cto0130_carrega_nff()

 CALL log085_transacao("BEGIN")
#BEGIN WORK

 LET p_ja_processado  = 'S'   

 DECLARE ct_ar1   CURSOR FOR
   SELECT *                                                       
     FROM aviso_rec              
    WHERE aviso_rec.cod_empresa   = p_cod_empresa     AND
          aviso_rec.num_aviso_rec = p_num_ar               

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CURSOR","AVISO_REC")
   END IF

 FOREACH ct_ar1 INTO p_aviso_rec.*                                

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("LEITURA","AVISO_REC")
   END IF

  SELECT ies_tip_item INTO p1_ies_tip_item  
    FROM item   
   WHERE cod_empresa=p_cod_empresa       AND
         cod_item   = p_aviso_rec.cod_item 


   IF sqlca.sqlcode <>  0   
      THEN
      CALL log003_err_sql("SELECT","ITEM")
      RETURN 
  END IF


  IF p1_ies_tip_item  = "B"   THEN 
     IF p_aviso_rec.pre_unit_nf   = 0   THEN 
        LET p_ies_penitenc   =  'S' 
     ELSE 
        LET p_ies_penitenc   =  'N' 
     END IF
      
     SELECT * FROM aviso_rec_cairu
      WHERE cod_empresa=p_cod_empresa        
       AND num_aviso_rec = p_num_ar 
       AND cod_item_benef = p_aviso_rec.cod_item 
       IF sqlca.sqlcode   = NOTFOUND   THEN 
          LET p_ja_processado  = 'N'   
          IF  cto0130_trata_item()    THEN 
              CALL  cto0130_grava_ar_cairu()
          ELSE
              CALL log085_transacao("ROLLBACK")
         #    ROLLBACK WORK
              RETURN
          END IF
       END IF 
  END IF         

 END FOREACH 


 SELECT * FROM nf_retorno_cairu  
  WHERE cod_empresa=p_cod_empresa        
    AND num_aviso_rec = p_num_ar 

    IF    sqlca.sqlcode  = NOTFOUND   
    AND   p_tela.num_nff1 IS NOT  NULL THEN 
          INSERT INTO nf_retorno_cairu VALUES(p_cod_empresa, 
                                              p_num_ar, 
                                              p_tela.num_nff1,
                                              p_tela.num_nff2, 
                                              p_tela.num_nff3, 
                                              p_tela.num_nff4, 
                                              p_tela.num_nff5) 
          IF sqlca.sqlcode <>  0
          THEN
              CALL log003_err_sql("INSERT","NF_RETORNO_CAIRU")
              CALL log085_transacao("ROLLBACK")
          #   ROLLBACK WORK
              RETURN 
          END IF
     ELSE
       IF    p_tela.num_nff1 IS NOT  NULL THEN 
          UPDATE nf_retorno_cairu  SET num_nff1 = p_tela.num_nff1,
                                       num_nff2 = p_tela.num_nff2,
                                       num_nff3 = p_tela.num_nff3,
                                       num_nff4 = p_tela.num_nff4,
                                       num_nff5 = p_tela.num_nff5 
           WHERE cod_empresa=p_cod_empresa        
             AND num_aviso_rec = p_num_ar 

          IF sqlca.sqlcode <>  0
          THEN
              CALL log003_err_sql("UPDATE","NF_RETORNO_CAIRU")
              CALL log085_transacao("ROLLBACK")
          #   ROLLBACK WORK
              RETURN 
          END IF
        END IF
     END IF

     IF  p_ies_penitenc   =  'S'   THEN 
         SELECT SUM(val_liquido_item)
           INTO p_total_nota
           FROM aviso_rec   
           WHERE aviso_rec.cod_empresa   = p_cod_empresa     AND
                 aviso_rec.num_aviso_rec = p_num_ar               
           IF sqlca.sqlcode =  0
           THEN
             UPDATE nf_sup   set val_tot_nf_d = p_total_nota
                WHERE nf_sup.cod_empresa   = p_cod_empresa     AND
                      nf_sup.num_aviso_rec = p_num_ar               
             IF sqlca.sqlcode <>  0
             THEN
                CALL log003_err_sql("UPDATE","NF_SUP")
                CALL log085_transacao("ROLLBACK")
             #  ROLLBACK WORK
                RETURN 
             END IF
             UPDATE nfe_sup_compl SET texto_obs1=9
                WHERE cod_empresa   = p_cod_empresa     AND
                      num_aviso_rec = p_num_ar               
             IF sqlca.sqlcode <>  0
             THEN
                CALL log003_err_sql("UPDATE","NFE_SUP_COMPL")
                CALL log085_transacao("ROLLBACK")
             #  ROLLBACK WORK
                RETURN 
             END IF

           END IF
      END IF

 CALL log085_transacao("COMMIT")
#COMMIT WORK

END FUNCTION
#------------------------------#
 FUNCTION  cto0130_carrega_nff()
#------------------------------#


   IF p_tela.num_nff1   IS NOT NULL   THEN 
      CALL  cto0130_processa_carga(p_tela.num_nff1)
   END IF 
   
   IF p_tela.num_nff2   IS NOT NULL   THEN 
      CALL  cto0130_processa_carga(p_tela.num_nff2)
   END IF 

   IF p_tela.num_nff3   IS NOT NULL   THEN 
      CALL  cto0130_processa_carga(p_tela.num_nff3)
   END IF 

   IF p_tela.num_nff4   IS NOT NULL   THEN 
      CALL  cto0130_processa_carga(p_tela.num_nff4)
   END IF 

   IF p_tela.num_nff5   IS NOT NULL   THEN 
      CALL  cto0130_processa_carga(p_tela.num_nff5)
   END IF 

   

END FUNCTION
#-------------------------------------------#
 FUNCTION  cto0130_processa_carga(p2_num_nff)
#-------------------------------------------#

 DEFINE p2_num_nff LIKE fat_nf_mestre.nota_fiscal
 
    SELECT  a.trans_nota_fiscal  
     INTO  p_trans_nf
     FROM  fat_nf_mestre a
    WHERE a.empresa = p_cod_empresa           
      AND a.nota_fiscal     = p2_num_nff



 DECLARE ct_nff   CURSOR FOR
	SELECT  i.empresa, i.item, i.classif_fisc, f.aliquota,i.preco_unit_liquido 
	FROM fat_nf_item i
	LEFT OUTER JOIN fat_nf_item_fisc f
	ON f.empresa = i.empresa
	AND f.trans_nota_fiscal = i.trans_nota_fiscal
	AND f.seq_item_nf = i.seq_item_nf
	AND tributo_benef = 'IPI'
	WHERE i.empresa = p_cod_empresa
	AND i.trans_nota_fiscal = p_trans_nf


 FOREACH ct_nff INTO p_itens_remessa.*          

   IF STATUS <> 0 THEN
      CALL log003_err_sql('FOREACH','Cursor ct_nff')
   END IF
      
   SELECT *   FROM t_itens_remessa
    WHERE cod_empresa=p_itens_remessa.cod_empresa
      AND    cod_item=p_itens_remessa.cod_item

   IF STATUS = 0   THEN
      CONTINUE FOREACH
   END IF

   INSERT INTO  t_itens_remessa  VALUES (p_itens_remessa.*)    

 END FOREACH 



END FUNCTION

#----------------------------#
 FUNCTION cto0130_trata_item()
#----------------------------#



 MESSAGE " Processando  ... " ATTRIBUTE(REVERSE)

 DECLARE ct_est  CURSOR FOR
   SELECT *  FROM estrutura              
    WHERE cod_empresa   = p_cod_empresa     AND
          cod_item_pai  = p_aviso_rec.cod_item AND 
          dat_validade_fim IS NULL             

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CURSOR","ESTRUTURA")
      RETURN FALSE
   END IF

   FOREACH ct_est INTO p_estrutura.*               

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("LEITURA","ESTRUTURA")
      RETURN FALSE
   END IF
                  
   LET p_aviso_rec_cp.* = p_aviso_rec.*

   SELECT  pre_unit_nf , cod_cla_fisc, pct_ipi
     INTO  p_aviso_rec_cp.pre_unit_nf, p_aviso_rec_cp.cod_cla_fisc, 
           p_aviso_rec_cp.pct_ipi_declarad 
     FROM t_itens_remessa
    WHERE  cod_item   =  p_estrutura.cod_item_compon 
      AND cod_empresa  = p_cod_empresa

   IF STATUS <> 0  THEN 
      LET p_ja_processado  = 'R' 
      RETURN FALSE
   END IF 
   IF    cto0130_insere_item()    THEN 
   ELSE
        RETURN FALSE
   END IF

 END FOREACH 

   RETURN  TRUE 

END FUNCTION

#-----------------------------------#
 FUNCTION cto0130_insere_item()   
#-----------------------------------#

   SELECT den_item, cod_unid_med
     INTO p_den_item ,p_cod_unid_med
     FROM item 
    WHERE cod_empresa= p_cod_empresa   AND 
          cod_item =   p_estrutura.cod_item_compon

   IF sqlca.sqlcode <>  0   
      THEN
      CALL log003_err_sql("SELECT","ITEM")
      RETURN  FALSE
   END IF

     LET p_qtd_item = p_estrutura.qtd_necessaria * p_aviso_rec.qtd_declarad_nf 
  
     SELECT max(num_seq)   INTO p_num_seq  
       FROM   aviso_rec
      WHERE cod_empresa  = p_cod_empresa
        AND num_aviso_rec    = p_num_ar    
   

   LET p_aviso_rec_cp.num_seq             =   (p_num_seq + 1)
   LET p_aviso_rec_cp.ies_situa_ar        =   "E" 
   LET p_aviso_rec_cp.ies_liberacao_ar    =   "2"
   LET p_aviso_rec_cp.ies_liberacao_cont  =   "S"
   LET p_aviso_rec_cp.ies_liberacao_insp  =   "S"
   LET p_aviso_rec_cp.ies_diverg_listada  =   "S"
   LET p_aviso_rec_cp.ies_item_estoq      =   "N"
   LET p_aviso_rec_cp.ies_controle_lote   =   "N" 
   LET p_aviso_rec_cp.num_pedido          =   0
   LET p_aviso_rec_cp.num_oc              =   0
   LET p_aviso_rec_cp.cod_item            =   p_estrutura.cod_item_compon
   LET p_aviso_rec_cp.den_item            =   p_den_item
   LET p_aviso_rec_cp.cod_unid_med_nf     =   p_cod_unid_med
   LET p_aviso_rec_cp.val_despesa_aces_i  =   0    
   LET p_aviso_rec_cp.ies_da_bc_ipi       =   "S"
   LET p_aviso_rec_cp.cod_incid_ipi       =   4
   LET p_aviso_rec_cp.ies_tip_incid_ipi   =   "O" 
   LET p_aviso_rec_cp.pct_direito_cred    =   100
   LET p_aviso_rec_cp.pct_ipi_declarad    =   0
   LET p_aviso_rec_cp.pct_ipi_tabela      =   0
   LET p_aviso_rec_cp.ies_bitributacao    =   "N"
   LET p_aviso_rec_cp.val_base_c_ipi_it   =   (p_qtd_item * p_aviso_rec_cp.pre_unit_nf)

   LET p_aviso_rec_cp.val_base_c_ipi_da   =   0
   LET p_aviso_rec_cp.val_ipi_decl_item   =   0
   LET p_aviso_rec_cp.val_ipi_calc_item   =   0
   LET p_aviso_rec_cp.val_ipi_desp_aces   =   0
   LET p_aviso_rec_cp.val_desc_item       =   0
   LET p_aviso_rec_cp.val_liquido_item    =   (p_qtd_item * p_aviso_rec_cp.pre_unit_nf) 

   LET p_aviso_rec_cp.val_contabil_item   =   p_aviso_rec_cp.val_liquido_item 
   LET p_aviso_rec_cp.qtd_declarad_nf     =   p_qtd_item  
   LET p_aviso_rec_cp.qtd_recebida        =   0
   LET p_aviso_rec_cp.cod_local_estoq     =   " " 
   LET p_aviso_rec_cp.cod_operac_estoq    =   " "  
   LET p_aviso_rec_cp.val_base_c_item_d   =   0                               
   LET p_aviso_rec_cp.val_base_c_item_c   =   0                               
   LET p_aviso_rec_cp.pct_icms_item_d     =   0
   LET p_aviso_rec_cp.pct_icms_item_c     =   0
   LET p_aviso_rec_cp.pct_red_bc_item_d   =   0
   LET p_aviso_rec_cp.pct_red_bc_item_c   =   0
   LET p_aviso_rec_cp.pct_diferen_item_d  =   0
   LET p_aviso_rec_cp.pct_diferen_item_c  =   0
   LET p_aviso_rec_cp.val_icms_item_d     =   0
   LET p_aviso_rec_cp.val_icms_item_c     =   0
   LET p_aviso_rec_cp.val_base_c_icms_da  =   0 
   LET p_aviso_rec_cp.val_icms_diferen_i  =   0
   LET p_aviso_rec_cp.val_icms_desp_aces  =   0
   LET p_aviso_rec_cp.ies_incid_icms_ite  =  "O"
   LET p_aviso_rec_cp.val_frete           =   0
   LET p_aviso_rec_cp.val_icms_frete_d    =   0
   LET p_aviso_rec_cp.val_icms_frete_c    =   0
   LET p_aviso_rec_cp.val_base_c_frete_d  =   0
   LET p_aviso_rec_cp.val_base_c_frete_c  =   0
   LET p_aviso_rec_cp.val_icms_diferen_f  =   0
   LET p_aviso_rec_cp.pct_icms_frete_d    =   0
   LET p_aviso_rec_cp.pct_icms_frete_c    =   0
   LET p_aviso_rec_cp.pct_red_bc_frete_d  =   0
   LET p_aviso_rec_cp.pct_red_bc_frete_c  =   0
   LET p_aviso_rec_cp.pct_diferen_fret_d  =   0
   LET p_aviso_rec_cp.pct_diferen_fret_c  =   0
   LET p_aviso_rec_cp.val_acrescimos      =   0
   LET p_aviso_rec_cp.val_enc_financ      =   0

   LET p_aviso_rec_cp.ies_contabil        =   "M"

   IF p_ies_penitenc   =  'S'  THEN 
      LET p_aviso_rec_cp.ies_total_nf     =   "S" 
   ELSE
      LET p_aviso_rec_cp.ies_total_nf     =   "N" 
   END IF 
   LET p_aviso_rec_cp.val_compl_estoque   =   0
   LET p_aviso_rec_cp.cod_cla_fisc_nf     =   p_aviso_rec_cp.cod_cla_fisc

   INSERT INTO aviso_rec    VALUES (p_aviso_rec_cp.*)
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","AVISO_REC")
         RETURN FALSE
      END IF

   INSERT INTO dest_aviso_rec   VALUES (p_cod_empresa,
	                                p_aviso_rec_cp.num_aviso_rec,
	                                p_aviso_rec_cp.num_seq, 1,
	                                "0","0",100,"0",
                                        "2500" , 0, "S", " ")
 

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","DEST_AVISO_REC")
      RETURN FALSE
   END IF

   IF p_ies_penitenc   =  'S'  THEN 
      INSERT INTO aviso_rec_compl_sq VALUES(p_cod_empresa,
	                                p_aviso_rec_cp.cod_empresa_estab,
	                                p_aviso_rec_cp.num_aviso_rec,
	                                p_aviso_rec_cp.num_seq, 
                                        0,
                                        0,
                                        NULL,
                                        NULL)
       IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","DEST_AVISO_REC")
         RETURN FALSE
       END IF
   ELSE
      INSERT INTO aviso_rec_compl_sq VALUES(p_cod_empresa,
	                                p_aviso_rec_cp.cod_empresa_estab,
	                                p_aviso_rec_cp.num_aviso_rec,
	                                p_aviso_rec_cp.num_seq, 
                                        0,
                                        0,
                                        NULL,
                                        NULL)
       IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","DEST_AVISO_REC")
         RETURN FALSE
       END IF
   END IF

      RETURN TRUE  

END FUNCTION
#--------------------------------#
 FUNCTION cto0130_grava_ar_cairu()   
#--------------------------------#

   INSERT INTO  aviso_rec_cairu VALUES(p_cod_empresa, 
                                       p_num_ar, 
                                       p_aviso_rec.cod_item)
   IF sqlca.sqlcode <>  0
   THEN
      CALL log003_err_sql("INSERT","AVISO_REC_CAIRU")
      RETURN 
   END IF
END FUNCTION

#-----------------------#
 FUNCTION cto0130_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION