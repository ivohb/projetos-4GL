#--------------------------------------------------#
# OBJETIVO: RELATORIO COMPRA MATERIAIS x PROJETO   #
#--------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_ped_ant        LIKE ordem_sup.num_pedido,
          p_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          p_cod_item           LIKE item.cod_item,
          p_val_tot_it         LIKE ordem_sup.pre_unit_oc,
          p_val_tot_ped        LIKE ordem_sup.pre_unit_oc,
          p_val_tot_proj       LIKE ordem_sup.pre_unit_oc,
          p_num_oc             LIKE ordem_sup.num_oc,
          p_num_os             DECIMAL(6,0),
          p_status             SMALLINT,
          p_count              SMALLINT,
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_normal             CHAR(02),
          p_comprime           CHAR(01),
          p_diferenca          DECIMAL(12,3),
          p_descomprime        CHAR(01),
          p_expande            CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),
          p_tot_cli            DECIMAL(15,2),
          p_8lpp               CHAR(02),
          p_tot_ger            DECIMAL(15,2)
          
   DEFINE p_tela        RECORD
      num_docum         CHAR(10),
      nom_os            CHAR(50),
      dat_ini           DATE,
      dat_fim           DATE,
      ies_rec           CHAR(01)
   END RECORD 

   DEFINE p_fornecedor     RECORD
      cod_fornecedor    LIKE fornecedor.cod_fornecedor,
      nom_fornecedor    LIKE fornecedor.raz_social
   END RECORD

   DEFINE p_relat         RECORD 
          num_pedido         LIKE ordem_sup.num_pedido, 
          nom_fornecedor     LIKE fornecedor.raz_social,
          num_oc             CHAR(09),
          den_item           LIKE item.den_item,
          qtd_solic          LIKE ordem_sup.qtd_solic,
          pre_unit           LIKE ordem_sup.pre_unit_oc,
          val_tot_it         LIKE ordem_sup.pre_unit_oc,
          val_tot_ped        LIKE ordem_sup.pre_unit_oc,
          dat_entrada        LIKE nf_sup.dat_entrada_nf,
          qtd_recebida       LIKE aviso_rec.qtd_recebida,  
          pre_unit_nf        LIKE aviso_rec.pre_unit_nf,
          num_nf             LIKE nf_sup.num_nf,
          val_liquido_item   LIKE aviso_rec.val_liquido_item

   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "POL1041-05.10.04"
   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("SUPRIMEN","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol1041_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1041_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1041") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1041 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar numero do projeto"
         HELP 001 
         MESSAGE ""
         LET p_ies_cons = FALSE
         IF pol1041_informar() THEN
            LET p_ies_cons = TRUE
            NEXT OPTION "Listar"
         ELSE
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            ERROR "Operação Cancelada !!!"
         END IF
         
      COMMAND "Listar" "Lista Ordens de compras"
         MESSAGE ""
         IF log0280_saida_relat(18,35) IS NOT NULL THEN
            IF p_ies_impressao = "S" THEN
               CALL log150_procura_caminho ('LST') RETURNING p_caminho
               LET p_caminho = p_caminho CLIPPED, 'pol1041.tmp'
               START REPORT pol1041_relat  TO p_caminho
            ELSE
               START REPORT pol1041_relat TO p_nom_arquivo
            END IF
            MESSAGE " Processando a Extracao do Relatorio..." 
            CALL pol1041_emite_relatorio()   
         END IF 
         
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
         
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
  
   CLOSE WINDOW w_pol1041

END FUNCTION

#--------------------------#
FUNCTION pol1041_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD num_docum    
      IF p_tela.num_docum IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD num_docum
      ELSE
         LET p_num_os = p_tela.num_docum
         SELECT nom_os 
           INTO p_tela.nom_os
           FROM cad_os
          WHERE cod_empresa = '01'
            AND num_os      = p_num_os     
         IF sqlca.sqlcode <> 0 THEN 
            LET p_tela.nom_os = 'PROJETO NAO CADASTRADO' 
         END IF 
         DISPLAY  p_tela.nom_os TO nom_os   
      END IF 
     
      BEFORE FIELD dat_ini
        LET p_tela.dat_ini = '01/01/1900'
        LET p_tela.dat_fim = '31/12/3000'

      AFTER FIELD dat_ini
         IF p_tela.dat_ini IS NULL THEN 
            ERROR 'INFORME A DATA INICIAL'
            NEXT FIELD dat_ini
         END IF 
            
      AFTER FIELD dat_fim
         IF p_tela.dat_fim IS NULL THEN 
            ERROR 'INFORME A DATA FINAL'
            NEXT FIELD dat_fim
         END IF 
         
         IF p_tela.dat_fim < p_tela.dat_ini THEN
            ERROR 'INFORME A DATA FINAL MENOR QUE INICIAL'
            NEXT FIELD dat_ini
         END IF

      AFTER FIELD ies_rec
         IF p_tela.ies_rec <> 'S' AND
            p_tela.ies_rec <> 'N' THEN 
            ERROR 'INFORME (S) PARA LISTAR APENAS PED. RECEDIDOS OU (N) PARA TODOS' 
            NEXT FIELD ies_rec
         END IF    
     
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
 FUNCTION pol1041_emite_relatorio()
#---------------------------------#
  DEFINE l_qtd_rel         INTEGER,
         l_num_seq         INTEGER,
         l_num_aviso_rec   LIKE aviso_rec.num_aviso_rec,
         l_count_reg       INTEGER  

   SELECT den_empresa 
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_negrito     = ascii 27, "E"
   LET p_normal      = ascii 27, "F"
   LET p_expande     = ascii 14
   LET p_8lpp        = ascii 27, "0"

   LET p_num_ped_ant = 0
   LET p_val_tot_proj = 0
   DECLARE cq_ord_sup CURSOR FOR
     SELECT a.cod_fornecedor, a.num_oc, a.num_pedido, a.cod_item,
            a.qtd_solic, a.pre_unit_oc, b.val_tot_ped
       FROM ordem_sup a, pedido_sup b
      WHERE a.cod_empresa       = p_cod_empresa 
        AND a.ies_versao_atual  = 'S'
        AND a.cod_empresa       = b.cod_empresa
        AND a.num_pedido        = b.num_pedido
        AND a.num_versao_pedido = b.num_versao
        AND b.ies_versao_atual  = 'S'
        AND a.num_docum         = p_tela.num_docum
     ORDER BY a.num_pedido,a.num_oc
     
   FOREACH cq_ord_sup INTO
           p_cod_fornecedor,
           p_num_oc,
           p_relat.num_pedido,    
           p_cod_item,      
           p_relat.qtd_solic,     
           p_relat.pre_unit,
           p_relat.val_tot_ped      

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ord_sup')
         EXIT FOREACH
      END IF

      CALL pol1041_checa_recebimento()

      IF p_tela.ies_rec = 'S' THEN 
         IF p_relat.num_nf = 0 THEN     
            CONTINUE FOREACH
         END IF    
      END IF 

      IF p_num_ped_ant <> p_relat.num_pedido THEN
         LET p_num_ped_ant = p_relat.num_pedido
         LET p_val_tot_proj  =  p_val_tot_proj  +  p_relat.val_tot_ped  
      END IF 
   
      SELECT raz_social
        INTO p_relat.nom_fornecedor
        FROM fornecedor
       WHERE cod_fornecedor  = p_cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fornecedor')
         EXIT FOREACH
      END IF

      LET p_relat.val_tot_it   =  p_relat.qtd_solic  *  p_relat.pre_unit
 
      LET p_relat.num_oc = p_num_oc

      IF p_relat.den_item  IS NULL THEN 
         SELECT den_item 
           INTO p_relat.den_item 
           FROM ordem_sup_txt 
          WHERE ies_tip_texto = 'P' 
            AND num_seq       = 1
            AND num_oc = p_num_oc

         IF sqlca.sqlcode <> 0 THEN                                                            
            SELECT den_item
              INTO p_relat.den_item
              FROM item
             WHERE cod_empresa  = p_cod_empresa
               AND cod_item     = p_cod_item 
         
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','item')
               EXIT FOREACH
            END IF
         END IF    
      END IF 
       
      OUTPUT TO REPORT pol1041_relat(p_relat.*)
         
      LET p_count = p_count + 1
          
   END FOREACH

   IF p_count > 0 THEN
      MESSAGE "Relatorio Processado com Sucesso" ATTRIBUTE(REVERSE)
   ELSE
      MESSAGE "Não existem dados para os parâmetros informados" ATTRIBUTE(REVERSE)
   END IF
   
   FINISH REPORT pol1041_relat   

   IF p_ies_impressao = "S" THEN
      ERROR "Relatorio Impresso na Impressora ", p_nom_arquivo
      LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
      RUN comando
   ELSE
      ERROR "Relatorio Gravado no Arquivo ",p_nom_arquivo
   END IF
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol1041_checa_recebimento()
#-----------------------------------#

  SELECT a.qtd_recebida, a.pre_unit_nf,  a.val_liquido_item, 
         a.den_item, b.num_nf, b.dat_entrada_nf
    INTO p_relat.qtd_recebida, p_relat.pre_unit_nf, p_relat.val_liquido_item, 
         p_relat.den_item, p_relat.num_nf, p_relat.dat_entrada     
    FROM aviso_rec a, nf_sup b 
   WHERE a.cod_empresa   = b.cod_empresa 
     AND a.num_aviso_rec = b.num_aviso_rec 
     AND a.cod_empresa   = p_cod_empresa 
     AND a.num_oc        = p_num_oc 

  IF sqlca.sqlcode <> 0 THEN 
     LET p_relat.qtd_recebida = 0
     LET p_relat.pre_unit_nf  = 0
     LET p_relat.num_nf       = 0
     LET p_relat.val_liquido_item = 0 
     INITIALIZE p_relat.dat_entrada, p_relat.den_item TO NULL
  ELSE
     IF p_relat.dat_entrada >= p_tela.dat_ini AND 
        p_relat.dat_entrada <= p_tela.dat_fim THEN 
     ELSE   
        LET p_relat.num_nf       = 0
     END IF    
       
  END IF  

END FUNCTION 

#-----------------------------#
REPORT pol1041_relat(p_relat)
#-----------------------------#

   DEFINE p_relat         RECORD 
          num_pedido         LIKE ordem_sup.num_pedido, 
          nom_fornecedor     LIKE fornecedor.raz_social,
          num_oc             CHAR(09),
          den_item           LIKE item.den_item,
          qtd_solic          LIKE ordem_sup.qtd_solic,
          pre_unit           LIKE ordem_sup.pre_unit_oc,
          val_tot_it         LIKE ordem_sup.pre_unit_oc,
          val_tot_ped        LIKE ordem_sup.pre_unit_oc,
          dat_entrada        LIKE nf_sup.dat_entrada_nf,
          qtd_recebida       LIKE aviso_rec.qtd_recebida,  
          pre_unit_nf        LIKE aviso_rec.pre_unit_nf,
          num_nf             LIKE nf_sup.num_nf,
          val_liquido_item   LIKE aviso_rec.val_liquido_item
   END RECORD

 OUTPUT LEFT   MARGIN   1 
        TOP    MARGIN   0
        BOTTOM MARGIN   0
        PAGE   LENGTH   66
   
      ORDER EXTERNAL BY p_relat.num_pedido,p_relat.num_oc
          
   FORMAT

      FIRST PAGE HEADER  
      
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED
         PRINT COLUMN 001, p_8lpp
         PRINT COLUMN 001,  p_den_empresa,
               COLUMN 165, " EMISSAO : ", TODAY USING "DD/MM/YYYY"
         PRINT COLUMN 001, "POL1041                                                       RELACAO DE ORDENS DE COMPRA POR PROJETO                                                     PAG: ", PAGENO USING "&&&"
         PRINT
         PRINT COLUMN 001, "  PROJETO: ", p_tela.num_docum , " - ", p_tela.nom_os, "                                                                       PERIODO: ", p_tela.dat_ini, " - ", p_tela.dat_fim
         PRINT COLUMN 001, '____________________________________________________________________________________________________________________________________________________________________________________________'
         PRINT
         PRINT COLUMN 001, 'NUM PED FORNECEDOR                 NUM OC    NF    DAT.RECEB.  PRODUTO/SERVICO                           QTD.PEDIDA     PRE.UNIT      VAL.TOTAL      QTD.RECEBIDA   PRE.UNITARIO  VAL.TOTAL '
         PRINT COLUMN 001, '____________________________________________________________________________________________________________________________________________________________________________________________'

      PAGE HEADER
   
         PRINT COLUMN 001, p_8lpp
         PRINT COLUMN 001,  p_den_empresa,
               COLUMN 165, " EMISSAO : ", TODAY USING "DD/MM/YYYY"
         PRINT COLUMN 001, "POL1041                                                       RELACAO DE ORDENS DE COMPRA POR PROJETO                                                     PAG: ", PAGENO USING "&&&"
         PRINT
         PRINT COLUMN 001, "  PROJETO: ", p_tela.num_docum , " - ", p_tela.nom_os, "                                                                       PERIODO: ", p_tela.dat_ini, " - ", p_tela.dat_fim
         PRINT COLUMN 001, '____________________________________________________________________________________________________________________________________________________________________________________________'
         PRINT
         PRINT COLUMN 001, 'NUM PED FORNECEDOR                 NUM OC    NF    DAT.RECEB.  PRODUTO/SERVICO                           QTD.PEDIDA     PRE.UNIT      VAL.TOTAL      QTD.RECEBIDA   PRE.UNITARIO  VAL.TOTAL '
         PRINT COLUMN 001, '____________________________________________________________________________________________________________________________________________________________________________________________'

      BEFORE GROUP OF p_relat.num_pedido 
         
      ON EVERY ROW
      PRINT  COLUMN 001, p_relat.num_pedido USING '######',
             COLUMN 009, p_relat.nom_fornecedor[1,25],
             COLUMN 036, p_relat.num_oc USING '######', 
             COLUMN 044, p_relat.num_nf     USING '######',       
             COLUMN 052, p_relat.dat_entrada,
             COLUMN 064, p_relat.den_item[1,40],
             COLUMN 106, p_relat.qtd_solic  USING '#,###,##&.&&&',
             COLUMN 121, p_relat.pre_unit   USING '#,###,##&.&&',
             COLUMN 135, p_relat.val_tot_it USING '--,---,--&.&&',
             COLUMN 150, p_relat.qtd_recebida USING '#,###,##&.&&&',
             COLUMN 165, p_relat.pre_unit_nf  USING '#,###,##&.&&',
             COLUMN 179, p_relat.val_liquido_item USING  '--,---,--&.&&'
             
      AFTER GROUP OF p_relat.num_pedido
         PRINT
         PRINT COLUMN 065, 'TOTAL PEDIDO: ',  
               COLUMN 135, GROUP SUM(p_relat.val_tot_it) USING '-,---,--&.&&&',
               COLUMN 179, GROUP SUM(p_relat.val_liquido_item) USING '-,---,--&.&&&'
         PRINT
         
      ON LAST ROW

         SKIP 1 LINE          
         PRINT COLUMN 065, "TOTAL PROJETO: ",        
               COLUMN 135, SUM(p_relat.val_tot_it) USING '-,---,--&.&&&',
               COLUMN 179, SUM(p_relat.val_liquido_item) USING '-,---,--&.&&&'      
               
END REPORT