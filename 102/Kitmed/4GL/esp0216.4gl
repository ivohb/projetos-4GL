#------------------------------------#
# OBJETIVO: IMPRESSAO ETIQUETA 2D)   #
#------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_nom_cliente       LIKE clientes.nom_cliente,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_tela_nom          CHAR(200),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT,
         p_den_item_reduz    LIKE item.den_item_reduz,
         p_det_cab           CHAR(1000)

   DEFINE p_tela RECORD
         cod_empresa       LIKE fat_nf_mestre.empresa,
         ser_nff           CHAR(03),
         num_nff_ini       LIKE fat_nf_mestre.nota_fiscal,
         num_nff_fim       LIKE fat_nf_mestre.nota_fiscal
   END RECORD
          
   DEFINE p_nf_mest_etq_ktm RECORD 
            cnpj_or         CHAR(15),
            cnpj_des        CHAR(15),
            base_icms       DECIMAL(15,2),
            val_icms        DECIMAL(15,2),
            val_tot_nf      DECIMAL(15,2),
            val_tot_merc    DECIMAL(15,2),
            base_pis        DECIMAL(15,2),
            val_pis         DECIMAL(15,2),
            base_cofins     DECIMAL(15,2),
            val_cofins      DECIMAL(15,2)
   END RECORD       

   DEFINE p_nf_item_etq_ktm  RECORD
            sequencia       INTEGER,
            cod_item        INTEGER,
            cod_unid_med    CHAR(03),
            qtd_item        DECIMAL(12,3),
            pre_unit        DECIMAL(15,6),  
            cod_cla_fis     CHAR(10),
            base_icms       DECIMAL(15,2),
            val_icms        DECIMAL(15,2),
            cod_fiscal      DECIMAL(4,0),
            aliquota        DECIMAL(4,2)
   END RECORD       

   DEFINE p_nf_ctr_etq_ktm  RECORD
            cod_empresa     CHAR(02), 
            num_nff         DECIMAL(6,0),
            ser_nff         CHAR(03),
            num_etq         DECIMAL(2,0),
            det_etq         CHAR(1000) 
   END RECORD       
         
DEFINE p_ind                 INTEGER,
       pa_curr               SMALLINT,
       sc_curr               SMALLINT,
       p_count               SMALLINT,
       p_num_nff             LIKE fat_nf_mestre.nota_fiscal,
       sql_prep1             CHAR(600),
       p_msg_fim             CHAR(70),
       p_cod_unid_med        CHAR(03),
       p_fat_conver          DECIMAL(13,9),
       p_dat_emis            DATE
         
  DEFINE p_fat_nf_mestre         RECORD LIKE fat_nf_mestre.*,    
         p_fat_nf_item           RECORD LIKE fat_nf_item.*
END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "ESP0216-05.10.05"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("esp0216.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
###aquioooooooo
#       LET p_user = 'admlog'
#       LET p_cod_empresa = '20'
###aquioooooooo
      CALL esp0216_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION esp0216_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_tela_nom TO NULL
  CALL log130_procura_caminho("esp0216") RETURNING p_tela_nom
#  LET  p_tela_nom = p_tela_nom CLIPPED 
#  LET  p_tela_nom = 'esp0216'
  OPEN WINDOW w_esp0216 AT 2,5 WITH FORM p_tela_nom 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
       
  MENU "OPCAO"
     COMMAND "Informar"    "Informar num. das notas"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","esp0216","CO") THEN
           IF esp0216_entrada_dados() THEN
              ERROR "NOTAS MARCADAS COM SUCESSO"
              NEXT OPTION "Fim"
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
  CLOSE WINDOW w_esp0216
END FUNCTION

#--------------------------------#
 FUNCTION esp0216_entrada_dados()
#--------------------------------#

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_esp0216

  INITIALIZE p_tela.* TO NULL 

  LET p_tela.cod_empresa = p_cod_empresa

  DISPLAY p_tela.cod_empresa TO cod_empresa

  INPUT p_tela.ser_nff,
        p_tela.num_nff_ini,
        p_tela.num_nff_fim
   FROM ser_nff,
        num_nff_ini,
        num_nff_fim

    AFTER FIELD ser_nff  
      IF p_tela.ser_nff  IS NULL THEN
         ERROR 'INFORME A SERIE DAS NOTAS'
         NEXT FIELD ser_nff  
      END IF

    AFTER FIELD num_nff_ini 
      IF p_tela.num_nff_ini  IS NOT NULL THEN
         LET p_num_nff = p_tela.num_nff_ini
         IF esp0216_verifica_nota() THEN
         ELSE 
            ERROR 'NOTA FISCAL INEXISTENTE'
            NEXT FIELD num_nff_ini  
         END IF
      END IF

    AFTER FIELD num_nff_fim 
      IF p_tela.num_nff_fim  IS NOT NULL THEN
         LET p_num_nff = p_tela.num_nff_ini
         IF esp0216_verifica_nota() THEN
            CALL esp0216_processa()
         ELSE 
            ERROR 'NOTA FISCAL INEXISTENTE'
            NEXT FIELD num_nff_fim 
         END IF
      END IF

 END INPUT 
 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_esp0216
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION

#----------------------------------#
 FUNCTION esp0216_verifica_nota()
#----------------------------------#

 SELECT *
   INTO p_fat_nf_mestre.*
   FROM fat_nf_mestre
  WHERE empresa  = p_cod_empresa
    AND nota_fiscal = p_num_nff
    AND serie_nota_fiscal = p_tela.ser_nff

IF sqlca.sqlcode = 0 THEN
ELSE
   RETURN FALSE
END IF

RETURN TRUE

END FUNCTION 

#---------------------------#
 FUNCTION esp0216_processa()
#---------------------------#
  DEFINE l_inteiro        DECIMAL(2,0),
         l_resto          DECIMAL(2,0),
         l_num_pedido     DECIMAL(6,0),
         l_num_pedido_rep CHAR(10),
         l_num_ped_rep    DECIMAL(7,0),
         l_cod_item_ant   CHAR(15),
         l_num_ped_ant    DECIMAL(6,0),
         l_qtd_etq        DECIMAL(2,0),
         l_qtd_itens      INTEGER,
         l_it             INTEGER,
         l_count          INTEGER,
         l_erro           CHAR(01),
         l_num_etq        DECIMAL(2,0),
         l_num_cgc_des    CHAR(19)  

  LET  p_nf_mest_etq_ktm.cnpj_or = '068446103000113'

  LET l_erro = 'N'
  
  BEGIN WORK 
  
  DECLARE cq_nf  CURSOR FOR 
    SELECT * 
      FROM fat_nf_mestre
     WHERE empresa = p_cod_empresa 
       AND nota_fiscal BETWEEN p_tela.num_nff_ini AND p_tela.num_nff_fim    
       AND sit_nota_fiscal = 'N'
       AND serie_nota_fiscal = p_tela.ser_nff
  FOREACH cq_nf INTO p_fat_nf_mestre.*
   
    INITIALIZE p_nf_ctr_etq_ktm.det_etq TO NULL

    LET l_num_etq = 0

    SELECT num_cgc_cpf
      INTO l_num_cgc_des
      FROM clientes
     WHERE cod_cliente =  p_fat_nf_mestre.cliente

    LET p_nf_mest_etq_ktm.cnpj_des = l_num_cgc_des[1,3],l_num_cgc_des[5,7],
                                     l_num_cgc_des[9,11],l_num_cgc_des[13,16],
                                     l_num_cgc_des[18,19]

    SELECT bc_tributo_tot,
           val_tributo_tot
      INTO p_nf_mest_etq_ktm.base_icms,
           p_nf_mest_etq_ktm.val_icms 
      FROM fat_mestre_fiscal
     WHERE empresa =  p_fat_nf_mestre.empresa
       AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
       AND tributo_benef = 'ICMS'
       
    IF SQLCA.sqlcode <> 0 THEN 
       LET p_nf_mest_etq_ktm.base_icms = 0
       LET p_nf_mest_etq_ktm.val_icms = 0
    END IF 

    SELECT bc_tributo_tot,
           val_tributo_tot
      INTO p_nf_mest_etq_ktm.base_pis,
           p_nf_mest_etq_ktm.val_pis 
      FROM fat_mestre_fiscal
     WHERE empresa =  p_fat_nf_mestre.empresa
       AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
       AND tributo_benef = 'PIS_REC'

    IF SQLCA.sqlcode <> 0 THEN 
       LET p_nf_mest_etq_ktm.base_pis = 0
       LET p_nf_mest_etq_ktm.val_pis = 0
    END IF 

    SELECT bc_tributo_tot,
           val_tributo_tot
      INTO p_nf_mest_etq_ktm.base_cofins,
           p_nf_mest_etq_ktm.val_cofins 
      FROM fat_mestre_fiscal
     WHERE empresa =  p_fat_nf_mestre.empresa
       AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
       AND tributo_benef = 'COFINS_REC'

    IF SQLCA.sqlcode <> 0 THEN 
       LET p_nf_mest_etq_ktm.base_cofins = 0
       LET p_nf_mest_etq_ktm.val_cofins = 0
    END IF 
    
    LET p_dat_emis = DATE(p_fat_nf_mestre.dat_hor_emissao)
     
    SELECT MAX(pedido)
      INTO l_num_pedido
      FROM fat_nf_item
     WHERE empresa = p_cod_empresa 
       AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal

    SELECT num_pedido_repres
      INTO l_num_pedido_rep
      FROM pedidos
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = l_num_pedido

    SELECT par_val
      INTO l_qtd_itens
      FROM par_vdp_pad
     WHERE cod_parametro = 'qtd_itens_etiqueta'
       AND cod_empresa = p_cod_empresa

    LET l_num_ped_rep =  l_num_pedido_rep[1,6]
    
    IF l_num_ped_rep IS NULL THEN
       LET l_num_ped_rep = 0 
    END IF    

    LET l_count = 0
    
    SELECT COUNT(*)
      INTO l_count
      FROM fat_nf_item
     WHERE empresa = p_cod_empresa 
       AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal

{    LET l_inteiro =  l_count / l_qtd_itens

    DISPLAY 'l_inteiro  ', l_inteiro AT 5,6
        
    IF l_inteiro = 0 THEN
       LET l_inteiro = 1
    ELSE
       LET l_resto =  l_inteiro * l_qtd_itens

      DISPLAY 'l_resto  ', l_resto AT 6,6

       IF l_resto < l_count THEN 
          LET l_inteiro = l_inteiro + 1
          DISPLAY 'l_inteiro ', l_inteiro AT 7,6
       END IF 
    END IF       
      
    LET l_qtd_etq = l_inteiro
    DISPLAY 'l_qtd_etq  ',l_qtd_etq AT 8,6}
    
    
    IF l_count <= 6 THEN 
       LET l_qtd_etq = 1
    ELSE
       IF l_count <= 12 THEN    
          LET l_qtd_etq = 2
       ELSE
          IF l_count <= 18 THEN
             LET l_qtd_etq = 3
          ELSE
             IF l_count <= 24 THEN   
                LET l_qtd_etq = 4
             ELSE        
                IF l_count <= 30 THEN   
                   LET l_qtd_etq = 5
                ELSE        
                   IF l_count <= 36 THEN   
                      LET l_qtd_etq = 6
                   ELSE        
                      IF l_count <= 42 THEN   
                         LET l_qtd_etq = 7
                      END IF 
                   END IF 
                END IF 
             END IF 
          END IF
       END IF
    END IF                           

    LET l_num_etq = 1
    
    LET p_nf_ctr_etq_ktm.det_etq = l_num_ped_rep USING "&&&&&&&",l_num_etq USING "&&",l_qtd_etq USING "&&",p_fat_nf_mestre.nota_fiscal USING "&&&&&&",p_tela.ser_nff,p_fat_nf_mestre.subserie_nf USING "&&",p_nf_mest_etq_ktm.cnpj_or,
        p_nf_mest_etq_ktm.cnpj_des,p_dat_emis,p_fat_nf_mestre.val_nota_fiscal USING "&&&&&&&&&&&&&&&.&&",
        p_nf_mest_etq_ktm.base_icms USING "&&&&&&&&&&&&&&&.&&",p_nf_mest_etq_ktm.val_icms  USING "&&&&&&&&&&&.&&",
        p_nf_mest_etq_ktm.base_pis USING "&&&&&&&&&&&&&&&.&&",p_nf_mest_etq_ktm.val_pis  USING "&&&&&&&&&&&.&&",
        p_nf_mest_etq_ktm.base_cofins USING "&&&&&&&&&&&&&&&.&&",p_nf_mest_etq_ktm.val_cofins  USING "&&&&&&&&&&&.&&"

    LET p_det_cab = p_nf_ctr_etq_ktm.det_etq

    LET l_it = 0 

    DECLARE cq_nfi  CURSOR FOR 
      SELECT * 
        FROM fat_nf_item
       WHERE empresa = p_cod_empresa 
         AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
        ORDER BY seq_item_nf 
        
    FOREACH cq_nfi INTO p_fat_nf_item.*

       LET p_nf_item_etq_ktm.sequencia    = p_fat_nf_item.seq_item_nf
       
       LET l_it = l_it + 1 

       INITIALIZE l_cod_item_ant,
                  l_num_ped_ant   TO NULL
       LET p_fat_conver = 0            
       SELECT cod_item_ant
         INTO l_cod_item_ant,
              l_num_ped_ant    
         FROM audit_ped_ktm
        WHERE cod_empresa  =  p_cod_empresa
          AND num_ped_atu  =  p_fat_nf_item.pedido
          AND cod_item_atu =  p_fat_nf_item.item

       IF l_cod_item_ant  IS NOT NULL THEN 
          SELECT ped_item,
                 fat_conver 
            INTO p_nf_item_etq_ktm.cod_item,
                 p_fat_conver 
            FROM kmif_pedidos_recebidos
           WHERE pedido_logix = l_num_ped_ant 
             AND cod_item = l_cod_item_ant
          IF SQLCA.sqlcode <> 0 THEN  
             SELECT ped_item,
                    fat_conver 
               INTO p_nf_item_etq_ktm.cod_item,
                    p_fat_conver 
               FROM kmif_pedidos_recebidos
              WHERE pedido_logix = p_fat_nf_item.pedido 
                AND cod_item = p_fat_nf_item.item
                
             IF SQLCA.sqlcode <> 0 THEN 
                LET p_fat_conver = 0
                SELECT cod_item_cliente 
                  INTO p_nf_item_etq_ktm.cod_item
                  FROM cliente_item 
                 WHERE cod_empresa        = p_cod_empresa 
                   AND cod_cliente_matriz = p_fat_nf_mestre.cliente
                   AND cod_item           = p_fat_nf_item.item 
             END IF 
          END IF    
       ELSE
          SELECT ped_item,
                 fat_conver 
            INTO p_nf_item_etq_ktm.cod_item,
                 p_fat_conver 
            FROM kmif_pedidos_recebidos
           WHERE pedido_logix = p_fat_nf_item.pedido 
             AND cod_item = p_fat_nf_item.item
             
          IF SQLCA.sqlcode <> 0 THEN
             LET p_fat_conver = 0 
             SELECT cod_item_cliente 
               INTO p_nf_item_etq_ktm.cod_item
               FROM cliente_item 
              WHERE cod_empresa        = p_cod_empresa 
                AND cod_cliente_matriz = p_fat_nf_mestre.cliente
                AND cod_item           = p_fat_nf_item.item 
          END IF 
       END IF 
       
#       SELECT fat_conver 
#         INTO p_fat_conver       
#         FROM kmif_pedidos_recebidos 
#        WHERE pedido_logix = p_fat_nf_item.pedido 
#          AND cod_item     = p_fat_nf_item.item 
          
       IF p_fat_conver > 0 THEN    
          LET p_nf_item_etq_ktm.qtd_item     = p_fat_nf_item.qtd_item * p_fat_conver
          LET p_nf_item_etq_ktm.pre_unit     = p_fat_nf_item.preco_unit_liquido / p_fat_conver
          LET p_nf_item_etq_ktm.cod_unid_med = p_fat_nf_item.unid_medida
       ELSE
          SELECT cod_unid_med_cli,
                 fat_conver  
            INTO p_cod_unid_med,
                 p_fat_conver
            FROM bkp_ctr_unid_med
           WHERE cod_empresa = p_cod_empresa 
             AND cod_cliente = p_fat_nf_mestre.cliente
             AND cod_item    = p_fat_nf_item.item
          IF SQLCA.sqlcode = 0 THEN 
             LET p_nf_item_etq_ktm.qtd_item     = p_fat_nf_item.qtd_item * p_fat_conver
             LET p_nf_item_etq_ktm.pre_unit     = p_fat_nf_item.preco_unit_liquido / p_fat_conver
             LET p_nf_item_etq_ktm.cod_unid_med = p_cod_unid_med
          ELSE
             LET p_nf_item_etq_ktm.qtd_item     = p_fat_nf_item.qtd_item 
             LET p_nf_item_etq_ktm.pre_unit     = p_fat_nf_item.preco_unit_liquido
             LET p_nf_item_etq_ktm.cod_unid_med = p_fat_nf_item.unid_medida
          END IF    
       END IF 
          
       LET p_nf_item_etq_ktm.cod_cla_fis  = p_fat_nf_item.classif_fisc 
       
       SELECT bc_tributo_tot,
              val_tributo_tot,
              cod_fiscal,
              aliquota
         INTO p_nf_item_etq_ktm.base_icms,
              p_nf_item_etq_ktm.val_icms,
              p_nf_item_etq_ktm.cod_fiscal,
              p_nf_item_etq_ktm.aliquota
         FROM fat_nf_item_fisc
        WHERE empresa =  p_fat_nf_mestre.empresa
          AND trans_nota_fiscal = p_fat_nf_item.trans_nota_fiscal
          AND seq_item_nf  =   p_fat_nf_item.seq_item_nf 
          AND tributo_benef = 'ICMS'

          LET p_nf_ctr_etq_ktm.det_etq = p_nf_ctr_etq_ktm.det_etq CLIPPED,p_nf_item_etq_ktm.cod_item USING "&&&&&&",p_nf_item_etq_ktm.cod_unid_med,
              p_nf_item_etq_ktm.qtd_item USING "&&&&&&&&&.&&&",p_nf_item_etq_ktm.pre_unit USING "&&&&&&&.&&&&&&",p_nf_item_etq_ktm.cod_cla_fis,
              p_nf_item_etq_ktm.cod_fiscal USING "&&&&",p_nf_item_etq_ktm.aliquota USING "&&.&&",p_nf_item_etq_ktm.base_icms USING "&&&&&&&&&&&&&&&.&&",
              p_nf_item_etq_ktm.val_icms USING "&&&&&&&&&&&&&&&.&&"
    
       IF l_it = l_qtd_itens THEN 
          LET p_nf_ctr_etq_ktm.num_etq     = l_num_etq
          LET p_nf_ctr_etq_ktm.cod_empresa = p_cod_empresa
          LET p_nf_ctr_etq_ktm.num_nff     = p_fat_nf_mestre.nota_fiscal
          LET p_nf_ctr_etq_ktm.ser_nff     = p_tela.ser_nff
       
          INSERT INTO  nf_ctr_etq_ktm VALUES (p_nf_ctr_etq_ktm.*)
          IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("INCLUSAO","nf_item_etq_ktm")
            LET l_erro = 'S'
            ROLLBACK WORK
            EXIT FOREACH   
          END IF

          INITIALIZE p_nf_ctr_etq_ktm.det_etq TO NULL 

          LET l_num_etq = l_num_etq + 1
           
          LET p_nf_ctr_etq_ktm.det_etq = l_num_ped_rep USING "&&&&&&&",l_num_etq USING "&&",l_qtd_etq USING "&&",p_fat_nf_mestre.nota_fiscal USING "&&&&&&",p_tela.ser_nff,p_fat_nf_mestre.subserie_nf USING "&&",p_nf_mest_etq_ktm.cnpj_or,
              p_nf_mest_etq_ktm.cnpj_des,p_dat_emis,p_fat_nf_mestre.val_nota_fiscal USING "&&&&&&&&&&&&&&&.&&",
              p_nf_mest_etq_ktm.base_icms USING "&&&&&&&&&&&&&&&.&&",p_nf_mest_etq_ktm.val_icms  USING "&&&&&&&&&&&.&&",
              p_nf_mest_etq_ktm.base_pis USING "&&&&&&&&&&&&&&&.&&",p_nf_mest_etq_ktm.val_pis  USING "&&&&&&&&&&&.&&",
              p_nf_mest_etq_ktm.base_cofins USING "&&&&&&&&&&&&&&&.&&",p_nf_mest_etq_ktm.val_cofins  USING "&&&&&&&&&&&.&&"
          
          LET l_it = 0
          
       END IF 

    END FOREACH

    IF l_erro = 'S' THEN
       EXIT FOREACH
    END IF 

    IF l_it > 0 THEN    
       LET p_nf_ctr_etq_ktm.num_etq     = l_num_etq
       LET p_nf_ctr_etq_ktm.cod_empresa = p_cod_empresa
       LET p_nf_ctr_etq_ktm.num_nff     = p_fat_nf_mestre.nota_fiscal
       LET p_nf_ctr_etq_ktm.ser_nff     = p_tela.ser_nff
       
       INSERT INTO  nf_ctr_etq_ktm VALUES (p_nf_ctr_etq_ktm.*)
       IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","nf_item_etq_ktm")
         ROLLBACK WORK
         LET l_erro = 'S'
         EXIT FOREACH   
       END IF 
    END IF 
  END FOREACH
       
  IF l_erro <> 'S' THEN
     COMMIT WORK 
  END IF 
  
END FUNCTION     