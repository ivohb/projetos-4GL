#-----------------------------------------------------------------#
# PROGRAMA: pol0766                                               #
# OBJETIVO: COPIA DE NOTAS FISCAIS ENTRE EMPRESAS - consignacao   #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_nf_mestre         RECORD LIKE nf_mestre.*,
          p_nf_mestree        RECORD LIKE nf_mestre.*,
          p_copia_nf_vetor    RECORD LIKE copia_nf_vetor.*,
          p_nf_item           RECORD LIKE nf_item.*,
          p_nf_fiscal         RECORD LIKE nf_fiscal.*,
          p_nf_item_fiscal    RECORD LIKE nf_item_fiscal.*,
          p_nf_duplicata      RECORD LIKE nf_duplicata.*,
          p_nf_movto_dupl     RECORD LIKE nf_movto_dupl.*,
          p_wfat_mestre       RECORD LIKE wfat_mestre.*,
          p_wfat_item         RECORD LIKE wfat_item.*,
          p_wfat_item_fiscal  RECORD LIKE wfat_item_fiscal.*,
          p_ordem_montag_item RECORD LIKE ordem_montag_item.*,
          p_wfat_fiscal       RECORD LIKE wfat_fiscal.*,
          p_wfat_duplic       RECORD LIKE wfat_duplic.*,
          p_empresas_885      RECORD LIKE empresas_885.*,
          p_cond_pgto_item    RECORD LIKE cond_pgto_item.*,
          p_ped_itens         RECORD LIKE ped_itens.*,
          p_ped_itens_desc    RECORD LIKE ped_itens_desc.*,
          p_ped_itens_bnf     RECORD LIKE ped_itens_bnf.*,
          p_desc_nat_oper_885 RECORD LIKE desc_nat_oper_885.*,
          p_nat_operacao      RECORD LIKE nat_operacao.*

   DEFINE p_pct_desp_finan   LIKE cond_pgto.pct_desp_finan,
          p_cod_empresa      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_cod_uni_feder    LIKE fiscal_par.cod_uni_feder,
          p_qtd_res          LIKE ped_itens.qtd_pecas_reserv,  
          p_qtd_rom          LIKE ped_itens.qtd_pecas_romaneio,  
          p_cod_cla_fisc     LIKE item.cod_cla_fisc,          
          p_val_tot_merc     LIKE nf_mestre.val_tot_mercadoria,
          p_val_tot_nf_or    LIKE nf_mestre.val_tot_nff,
          p_val_tot_dupl     LIKE nf_mestre.val_tot_mercadoria,
          p_cod_nat_oper     LIKE nat_operacao.cod_nat_oper,     
          p_ies_subst_tribut LIKE nat_operacao.ies_subst_tribut,     
          p_ies_baixa_pedido LIKE nat_operacao.ies_baixa_pedido,     
          p_val_tot_ipi      LIKE nf_mestre.val_tot_ipi,
          p_val_tot_icm      LIKE nf_mestre.val_tot_icm,
          p_val_icm_tot_ret  LIKE nf_item_fiscal.val_icm_ret,
          p_val_base_tot_ret LIKE nf_item_fiscal.val_base_ret,
          p_val_icm_ret      LIKE nf_item_fiscal.val_icm_ret,
          p_val_base_ret     LIKE nf_item_fiscal.val_base_ret,
          p_val_tot_nf       LIKE nf_mestre.val_tot_nff,
          p_val_tot_nff      LIKE nf_mestre.val_tot_nff,
          p_val_tot_aux      CHAR(15),                     
          p_val_tot_ant      LIKE nf_mestre.val_tot_nff,
          p_val_base_icm     LIKE nf_mestre.val_tot_base_icm,
          p_val_b_icm        LIKE nf_item_fiscal.val_base_icm,
          p_val_icm          LIKE nf_item_fiscal.val_icm,
          p_num_nff_oper     LIKE nf_mestre.num_nff,
          p_num_nff          LIKE nf_mestre.num_nff,
          p_num_docum        LIKE docum.num_docum,
          p_num_docum_d      LIKE docum.num_docum,
          p_pct_dupl         DEC(10,9),                             
          p_ies_cons         SMALLINT,
          p_qtd_parcelas     SMALLINT,
          p_dias             SMALLINT,
          p_last_row         SMALLINT,
          p_conta            SMALLINT,
          p_cont             SMALLINT,
          pa_curr            SMALLINT,
          sc_curr            SMALLINT,
          p_status           SMALLINT,
          p_funcao           CHAR(15),
          p_houve_erro       SMALLINT, 
          p_comando          CHAR(80),
          p_caminho          CHAR(80),
          p_help             CHAR(80),
          p_cancel           INTEGER,
          p_nom_tela         CHAR(80),
          p_ies_emit_dupl    CHAR(01),
          p_mensag           CHAR(200),
          w_i                SMALLINT,
          p_i                SMALLINT, 
          p_data1            DATE,
          p_data2            DATE,
          p_data3            DATE,
          p_data4            DATE,
          p_data5            DATE,
          p_data             DATE,      
          p_data_ini         DATE,      
          p_den_item         LIKE item.den_item,
          p_pes_unit         LIKE item.pes_unit,
          p_data_ent         DATE,
          p_cod_unid_med     LIKE item.cod_unid_med,
          p_cod_nat_oper_rem LIKE nf_mestre.cod_nat_oper,
          p_num_pedido       DECIMAL(6,0),
          p_msg              CHAR(100) 

   DEFINE t_nf_item ARRAY[500] OF RECORD
      cod_item       LIKE nf_item.cod_item,
      den_item_reduz LIKE item.den_item_reduz,        
      qtd_fatur      LIKE nf_item.qtd_item,        
      qtd_total      LIKE nf_item.qtd_item,
      pre_unit       LIKE nf_item.pre_unit_nf
   END RECORD

   DEFINE t_ped_itens ARRAY[500] OF RECORD
      cod_item       LIKE ped_itens.cod_item,
      pre_unit       LIKE ped_itens.pre_unit
   END RECORD

   DEFINE p_nf RECORD
      nom_cliente  LIKE clientes.nom_cliente,
      den_nat_oper LIKE nat_operacao.den_nat_oper    
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
   LET p_versao = "POL0766-10.02.00" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0766_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0766_controle()
#--------------------------#

   INITIALIZE p_nf_mestre.*, 
              p_nf_mestree.*, 
              p_nf_item.*,
              p_nf_fiscal.*,
              p_nf_item_fiscal.*,
              p_nf_duplicata.*,
              p_nf_movto_dupl.*,
              p_wfat_mestre.*,
              p_wfat_item.*,
              p_wfat_item_fiscal.*,
              p_wfat_fiscal.*,
              p_wfat_duplic.*,
              p_empresas_885.*,
              p_ped_itens.*,
              p_nf.* TO NULL

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0766") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0766 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Notas Fiscais"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0766","CO") THEN 
            CALL pol0766_consulta()                     
            IF p_ies_cons THEN 
               NEXT OPTION "Total"
            END IF
         END IF
      COMMAND "Processa" "Executa Baixa de estaque"
         HELP 2011
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0766","MO") THEN 
            IF p_ies_cons THEN 
               SELECT MAX(num_pedido) 
                 INTO p_num_pedido
                 FROM nf_item
                WHERE cod_empresa = p_cod_empresa
                  AND num_nff     = p_nf_mestre.num_nff 
                  
               SELECT * 
                 INTO p_desc_nat_oper_885.*
                 FROM desc_nat_oper_885 
                WHERE cod_empresa = p_empresas_885.cod_emp_gerencial    
                  AND num_pedido  = p_num_pedido
               IF SQLCA.sqlcode <> 0 THEN 
               END IF
               IF p_desc_nat_oper_885.pct_desc_qtd   > 0 OR 
                  p_desc_nat_oper_885.pct_desc_valor > 0 THEN 
                  CALL pol0766_total()
                  IF p_houve_erro THEN
                     ERROR "Processamento Cancelado " 
                     NEXT OPTION "Consultar"
                  END IF  
                  COMMIT WORK
               END IF    
               ERROR "Baixa concluida com sucesso " 
               NEXT OPTION "Consultar"
            ELSE
               ERROR "Consulte Previamente Antes de Processar"
               NEXT OPTION "Consultar"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0766_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0766

END FUNCTION

#--------------------------#
 FUNCTION pol0766_consulta()
#--------------------------#
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0766

   LET p_nf_mestre.num_nff = NULL 
   IF pol0766_entrada_dados() THEN
      CALL pol0766_exibe_dados()
   END IF

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_nf_mestre.num_nff = NULL 
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
   END IF
 
END FUNCTION

#-------------------------------#
 FUNCTION pol0766_entrada_dados()
#-------------------------------#
   DEFINE p_ies_situacao   LIKE nf_mestre.ies_situacao
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0766

   LET INT_FLAG = FALSE  
   INPUT p_nf_mestre.num_nff,
         p_cod_nat_oper_rem WITHOUT DEFAULTS  
    FROM
         num_nff,
         cod_nat_oper_rem 

      AFTER FIELD num_nff     
      IF p_nf_mestre.num_nff IS NOT NULL THEN
         SELECT * INTO p_nf_mestre.*
         FROM nf_mestre                  
         WHERE cod_empresa = p_cod_empresa            
           AND num_nff = p_nf_mestre.num_nff
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Nota Fiscal nao cadastrada" 
            NEXT FIELD num_nff       
         END IF
      ELSE 
         ERROR "O Campo Nota Fiscal nao pode ser Nulo"
         NEXT FIELD num_nff       
      END IF
      IF pol0766_checa_par() THEN
         ERROR "Empresa para Copia sem Parametros Cadastrados" 
         NEXT FIELD num_nff
      END IF

      SELECT num_nff_ds
        INTO p_copia_nf_vetor.num_nff_ds
        FROM copia_nf_vetor           
       WHERE cod_emp_or = p_cod_empresa                 
         AND num_nff_or = p_nf_mestre.num_nff 
      IF sqlca.sqlcode = 0 THEN 
         SELECT ies_situacao
           INTO p_ies_situacao
           FROM nf_mestre 
          WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
            AND num_nff     = p_copia_nf_vetor.num_nff_ds 
         IF sqlca.sqlcode = 0 THEN 
            IF p_ies_situacao = "N" THEN
               ERROR "Nota Fiscal ja processada anteriormente"
               NEXT FIELD num_nff
            ELSE
               DELETE from copia_nf_vetor 
                WHERE cod_emp_or = p_cod_empresa 
                  AND num_nff_or = p_nf_mestre.num_nff
            END IF  
         ELSE     
            ERROR "Nota Fiscal ja processada anteriormente"
            NEXT FIELD num_nff
         END IF       
      END IF 
      
      LET p_copia_nf_vetor.cod_emp_or = p_cod_empresa
      LET p_copia_nf_vetor.cod_emp_ds = p_empresas_885.cod_emp_gerencial
      LET p_copia_nf_vetor.num_nff_or = p_nf_mestre.num_nff 

      SELECT *
        INTO p_nat_operacao.*
        FROM nat_operacao 
       WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper

      IF p_nat_operacao.ies_tip_controle <> '8' THEN
         EXIT INPUT  
      END IF 

      AFTER FIELD cod_nat_oper_rem
         SELECT *
           INTO p_nat_operacao.*
           FROM nat_operacao 
          WHERE cod_nat_oper = p_cod_nat_oper_rem
            
         IF p_nat_operacao.ies_tip_controle <> '9' THEN
            ERROR 'Operacao deve ser de remessa, tipo de controle (9)'
            NEXT FIELD cod_nat_oper_rem 
         END IF 
         
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0766
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF
 
END FUNCTION

#---------------------------#
 FUNCTION pol0766_checa_par()
#---------------------------# 

   INITIALIZE p_empresas_885.* TO NULL

   SELECT * 
      INTO p_empresas_885.*		
      FROM empresas_885 
     WHERE cod_emp_oficial = p_cod_empresa

   IF SQLCA.SQLCODE <> 0 THEN 
      RETURN TRUE 
   ELSE 
      RETURN FALSE 
   END IF
    
END FUNCTION 

#------------------------------#
 FUNCTION pol0766_exibe_dados()
#------------------------------#

   SELECT * INTO p_nf_fiscal.*
   FROM nf_fiscal
   WHERE cod_empresa = p_cod_empresa
     AND num_nff = p_nf_mestre.num_nff

   SELECT pct_desp_finan,ies_emite_dupl
     INTO p_pct_desp_finan,p_ies_emit_dupl
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_nf_mestre.cod_cnd_pgto  

   SELECT * INTO p_wfat_mestre.*
   FROM wfat_mestre 
   WHERE cod_empresa = p_cod_empresa
     AND num_nff = p_nf_mestre.num_nff

   SELECT * INTO p_wfat_fiscal.*
   FROM wfat_fiscal 
   WHERE cod_empresa = p_cod_empresa
     AND num_nff = p_nf_mestre.num_nff

   SELECT * INTO p_nf_movto_dupl.*
   FROM nf_movto_dupl
   WHERE cod_empresa = p_cod_empresa
     AND num_nff = p_nf_mestre.num_nff

   SELECT nom_cliente
      INTO p_nf.nom_cliente
   FROM clientes
   WHERE cod_cliente = p_nf_mestre.cod_cliente

   SELECT den_nat_oper,
          ies_baixa_pedido
      INTO p_nf.den_nat_oper,
           p_ies_baixa_pedido
   FROM nat_operacao
   WHERE cod_nat_oper = p_nf_mestre.cod_nat_oper

   DISPLAY BY NAME p_nf_mestre.num_nff,
                   p_nf_mestre.cod_cliente,
                   p_nf_mestre.cod_nat_oper,
                   p_nf.*       

   INITIALIZE t_nf_item TO NULL
   INITIALIZE t_ped_itens TO NULL
   DECLARE c_nf_item CURSOR FOR
   SELECT num_pedido,
          num_sequencia,
          cod_item,
          qtd_item,
          num_om,
          pct_desc_adic_mest,
          pct_desc_adic
   FROM nf_item
   WHERE cod_empresa = p_cod_empresa
     AND num_nff = p_nf_mestre.num_nff

   LET p_i = 1
   FOREACH c_nf_item INTO p_nf_item.num_pedido,
                          p_nf_item.num_sequencia,
                          p_nf_item.cod_item,      
                          p_nf_item.qtd_item,
                          p_nf_item.num_om,     
                          p_nf_item.pct_desc_adic_mest,
                          p_nf_item.pct_desc_adic

      LET t_nf_item[p_i].cod_item  = p_nf_item.cod_item
      LET t_nf_item[p_i].qtd_fatur = p_nf_item.qtd_item
      LET t_nf_item[p_i].qtd_total = p_nf_item.qtd_item

      SELECT den_item_reduz
         INTO t_nf_item[p_i].den_item_reduz   
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = p_nf_item.cod_item

      SELECT a.cod_item,
             a.pre_unit
         INTO t_ped_itens[p_i].cod_item, 
              t_ped_itens[p_i].pre_unit
      FROM ped_itens a
      WHERE a.cod_empresa = p_empresas_885.cod_emp_gerencial
        AND a.num_pedido = p_nf_item.num_pedido
        AND a.num_sequencia = p_nf_item.num_sequencia
      IF SQLCA.SQLCODE <> 0 THEN
         LET t_nf_item[p_i].qtd_total = 0 
      ELSE 
         LET t_ped_itens[p_i].pre_unit = t_ped_itens[p_i].pre_unit-(t_ped_itens[p_i].pre_unit*p_nf_item.pct_desc_adic_mest/100)
         LET t_ped_itens[p_i].pre_unit = t_ped_itens[p_i].pre_unit-(t_ped_itens[p_i].pre_unit*p_nf_item.pct_desc_adic/100)
         LET t_nf_item[p_i].pre_unit = t_ped_itens[p_i].pre_unit
      END IF

      LET p_i = p_i + 1

   END FOREACH

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_nf_item TO s_nf_item.*
   END DISPLAY

   IF INT_FLAG THEN 
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE  
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0766_total()
#-----------------------#
 DEFINE p_val_liquido  DEC(17,2)

   MESSAGE "Aguarde Processando Copia Total...!!!"
      ATTRIBUTE (REVERSE) 

   LET p_houve_erro = FALSE
   LET p_nf_mestree.val_tot_mercadoria = 0    
   LET p_nf_mestree.val_tot_ipi = 0              
   LET p_pct_dupl = 0
   BEGIN WORK

#   SELECT num_nff
#     INTO p_num_nff_oper
#     FROM fat_numero
#    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

#    LET p_num_nff_oper = p_num_nff_oper + 1

      LET p_num_nff_oper = p_nf_mestre.num_nff
    
      DECLARE c_nf_item1 CURSOR FOR 
      SELECT * FROM nf_item
      WHERE cod_empresa = p_cod_empresa
        AND num_nff     = p_nf_mestre.num_nff 

      LET w_i = 1
      FOREACH c_nf_item1 INTO p_nf_item.*  

         IF t_nf_item[w_i].qtd_total = 0 AND
            t_ped_itens[w_i].pre_unit  IS NULL THEN
            CONTINUE FOREACH
         END IF

         LET p_val_liquido = 0
         LET p_nf_item.val_desc_adicional = 0

         LET p_nf_item.val_liq_item = t_nf_item[w_i].qtd_total *
                                      t_ped_itens[w_i].pre_unit
   
         LET p_val_liquido = p_nf_item.val_liq_item 

         LET p_nf_item.val_ipi = 0

         LET p_nf_mestree.val_tot_mercadoria = p_nf_mestree.val_tot_mercadoria +
                                               p_nf_item.val_liq_item

         IF t_nf_item[w_i].qtd_total = 0 THEN
            CONTINUE FOREACH
         END IF

         INSERT INTO nf_item 
            VALUES (p_empresas_885.cod_emp_gerencial,
                    p_num_nff_oper,
                    p_nf_item.num_pedido,
                    p_nf_item.num_sequencia,
                    t_ped_itens[w_i].cod_item,
                    p_nf_item.ies_desp_dist,
                    p_nf_item.pes_unit,      
                    t_nf_item[w_i].qtd_total,
                    p_nf_item.pre_unit_ped,
                    t_ped_itens[w_i].pre_unit,
                    p_nf_item.pct_desc_adic_mest,
                    p_nf_item.pct_desc_adic,
                    p_nf_item.val_desc_adicional,
                    p_nf_item.val_liq_item,
                    p_nf_item.cod_cla_fisc,
                    0,                 
                    0,                  
                    p_nf_item.cod_unid_med,
                    p_nf_item.fat_conver,
                    p_nf_item.ies_tributa_ipi,
                    p_nf_item.num_om)
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("INCLUSAO","NF_ITEM")
            ROLLBACK WORK 
            EXIT FOREACH
         END IF

         IF p_cod_nat_oper_rem <> 0 AND 
            p_cod_nat_oper_rem IS NOT NULL THEN 
            UPDATE pedidos 
               SET cod_nat_oper = p_cod_nat_oper_rem
             WHERE cod_empresa  IN (p_empresas_885.cod_emp_gerencial,p_empresas_885.cod_emp_oficial)
               AND num_pedido   = p_nf_item.num_pedido
            
            IF SQLCA.SQLCODE <> 0 THEN 
               LET p_houve_erro = TRUE 
               CALL log003_err_sql("ATUALIZACAO","PEDIDOS")
               ROLLBACK WORK 
               EXIT FOREACH
            END IF
         END IF
         INSERT INTO sac_item 
            VALUES (p_empresas_885.cod_emp_gerencial,
                    p_num_nff_oper,
                    p_nf_mestre.ser_nff,
                    p_nf_item.num_pedido,
                    p_nf_item.num_sequencia,
                    t_ped_itens[w_i].cod_item,
                    t_nf_item[w_i].qtd_total,
                    t_ped_itens[w_i].pre_unit)
                   
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("INCLUSAO","SAC_ITEM")
            ROLLBACK WORK 
            EXIT FOREACH
         END IF

         SELECT * INTO p_wfat_item.*
         FROM wfat_item
         WHERE cod_empresa = p_cod_empresa
           AND num_nff = p_nf_mestre.num_nff 
           AND num_sequencia = p_nf_item.num_sequencia
           AND num_pedido    = p_nf_item.num_pedido
         IF SQLCA.SQLCODE = 0 THEN
            LET p_wfat_item.cod_item = t_ped_itens[w_i].cod_item
            LET p_wfat_item.val_liq_item = p_nf_item.val_liq_item
            LET p_wfat_item.qtd_item = t_nf_item[w_i].qtd_total
            LET p_wfat_item.pre_unit_nf = t_ped_itens[w_i].pre_unit
            SELECT den_item
               INTO p_wfat_item.den_item
            FROM item
            WHERE cod_empresa = p_cod_empresa
              AND cod_item = p_wfat_item.cod_item

            INSERT INTO wfat_item 
               VALUES (p_empresas_885.cod_emp_gerencial,
                       p_num_nff_oper,
                       p_wfat_item.num_pedido,
                       p_wfat_item.num_sequencia,
                       p_wfat_item.dat_emis_pedido,
                       p_wfat_item.cod_item,
                       p_wfat_item.ies_desp_dist,
                       p_wfat_item.den_item,
                       p_wfat_item.pes_unit,
                       p_wfat_item.qtd_item,
                       p_wfat_item.pre_unit_ped,
                       p_wfat_item.pre_unit_nf,
                       p_wfat_item.pct_desc_adic_mest,
                       p_wfat_item.pct_desc_adic,
                       p_wfat_item.val_desc_adicional,
                       p_wfat_item.val_liq_item,
                       p_wfat_item.cod_cla_fisc,
                       0,                  
                       0,                  
                       p_wfat_item.cod_unid_med,
                       p_wfat_item.num_om,
                       p_wfat_item.fat_conver,
                       p_wfat_item.ies_tributa_ipi,
                       p_user,
                       p_wfat_item.val_icm_ret) 
            IF SQLCA.SQLCODE <> 0 THEN 
               LET p_houve_erro = TRUE 
               CALL log003_err_sql("INCLUSAO","WFAT_ITEM")
               ROLLBACK WORK 
               EXIT FOREACH
            END IF
         END IF

         SELECT *
           INTO p_desc_nat_oper_885.*
           FROM desc_nat_oper_885
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_wfat_item.num_pedido 
         
{         IF p_ies_baixa_pedido = "S" THEN
            IF p_desc_nat_oper_885.pct_desc_valor > 0 THEN 
               UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend + p_wfat_item.qtd_item
                WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
                  AND num_pedido    = p_wfat_item.num_pedido
                  AND cod_item      = p_wfat_item.cod_item
                  AND num_sequencia = p_wfat_item.num_sequencia
            ELSE
               UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend + p_wfat_item.qtd_item + t_nf_item[w_i].qtd_fatur
                WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
                  AND num_pedido  = p_wfat_item.num_pedido
                  AND cod_item    = p_wfat_item.cod_item
                  AND num_sequencia = p_wfat_item.num_sequencia
            END IF 
          END IF}
         LET w_i = w_i + 1

      END FOREACH 

      IF p_houve_erro THEN
         RETURN  
      END IF

      DECLARE c_nf_item_fiscal CURSOR FOR 
      SELECT * FROM nf_item_fiscal
      WHERE cod_empresa = p_cod_empresa
        AND num_nff = p_nf_mestre.num_nff 

      FOREACH c_nf_item_fiscal INTO p_nf_item_fiscal.*

         INSERT INTO nf_item_fiscal
            VALUES (p_empresas_885.cod_emp_gerencial,
                    p_num_nff_oper,
                    p_nf_item_fiscal.num_pedido,
                    p_nf_item_fiscal.num_sequencia,
                    p_nf_item_fiscal.cod_nat_oper,
                    p_nf_item_fiscal.ies_incid_ipi,
                    p_nf_item_fiscal.ies_incid_icm,
                    0,
                    0,
                    p_nf_item_fiscal.cod_fiscal,
                    p_nf_item_fiscal.cod_origem,
                    p_nf_item_fiscal.cod_tributacao,
                    0,
                    0,
                    0,
                    0,
                    p_nf_item_fiscal.cod_sit_trib,
                    p_nf_item_fiscal.cod_trib_estadual,
                    p_nf_item_fiscal.cod_trib_federal,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,                              
                    0,
                    0,
                    0,
                    p_nf_item_fiscal.ordem_montag)
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("INCLUSAO","NF_ITEM_FISCAL")
            ROLLBACK WORK 
            EXIT FOREACH 
         END IF

      END FOREACH 

      IF p_houve_erro THEN
         RETURN  
      END IF

      DECLARE c_wfat_item_fiscal CURSOR FOR 
      SELECT * FROM wfat_item_fiscal
      WHERE cod_empresa = p_cod_empresa
        AND num_nff = p_nf_mestre.num_nff 

      FOREACH c_wfat_item_fiscal INTO p_wfat_item_fiscal.*

         INSERT INTO wfat_item_fiscal 
            VALUES (p_empresas_885.cod_emp_gerencial,
                    p_num_nff_oper,
                    p_wfat_item_fiscal.num_pedido,
                    p_wfat_item_fiscal.num_sequencia,
                    p_wfat_item_fiscal.cod_nat_oper,
                    p_wfat_item_fiscal.ies_incid_ipi,
                    p_wfat_item_fiscal.ies_incid_icm,
                    0,
                    0,
                    p_wfat_item_fiscal.cod_fiscal,
                    p_wfat_item_fiscal.cod_origem,
                    p_wfat_item_fiscal.cod_tributacao,
                    0,
                    0,
                    0,
                    0,
                    p_wfat_item_fiscal.cod_sit_trib,
                    p_wfat_item_fiscal.cod_trib_estadual,
                    p_wfat_item_fiscal.cod_trib_federal,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,                               
                    0,
                    0,
                    0,
                    p_user,
                    p_wfat_item_fiscal.ordem_montag)
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("INCLUSAO","WFAT_ITEM_FISCAL")
            ROLLBACK WORK 
            EXIT FOREACH
         END IF

      END FOREACH

      IF p_houve_erro THEN
         RETURN  
      END IF

      LET p_nf_mestre.val_tot_mercadoria = p_nf_mestree.val_tot_mercadoria
      LET p_nf_mestre.val_tot_nff = p_nf_mestree.val_tot_mercadoria
      
      INSERT INTO nf_mestre
         VALUES (p_empresas_885.cod_emp_gerencial,
                 p_num_nff_oper,
                 p_nf_mestre.dat_emissao,
                 p_nf_mestre.ies_situacao,
                 p_nf_mestre.ser_nff,
                 p_nf_mestre.ies_origem,
                 p_nf_mestre.cod_cliente,
                 p_nf_mestre.ies_zona_franca,
                 p_nf_mestre.cod_transpor,
                 p_nf_mestre.cod_consig,
                 p_nf_mestre.pct_frete,
                 p_nf_mestre.ies_frete,
                 p_nf_mestre.cod_cnd_pgto,
                 p_nf_mestre.ies_incid_ipi,
                 p_nf_mestre.ies_incid_icm,
                 p_nf_mestre.pct_icm,
                 p_nf_mestre.pct_desc_base_icm,
                 p_nf_mestre.pct_comis,
                 p_nf_mestre.ies_finalidade,
                 p_nf_mestre.pct_desp_dist,
                 p_nf_mestre.pct_desp_finan,
                 p_nf_mestre.pes_tot_liquido,
                 p_nf_mestre.pes_tot_bruto,
                 p_nf_mestre.cod_nat_oper,
                 p_nf_mestre.cod_fiscal,
                 p_nf_mestre.cod_origem,
                 p_nf_mestre.cod_tributacao,
                 p_nf_mestre.pct_desc_base_ipi,
                 p_nf_mestre.pct_cred_icm,
                 p_nf_mestre.tax_red_pct_icm,
                 p_nf_mestre.pct_desc_ipi,
                 p_nf_mestre.val_desc_merc,
                 p_nf_mestre.cod_repres,
                 p_nf_mestre.cod_repres_adic,
                 p_nf_mestre.num_lote_lc,
                 p_nf_mestre.cod_sit_trib,
                 p_nf_mestre.cod_trib_estadual,
                 p_nf_mestre.cod_trib_federal,
                 p_nf_mestre.val_desc_cred_icm,
                 0,                              
                 p_nf_mestre.val_seguro_rod,
                 p_nf_mestre.val_tot_base_ipi,
                 p_nf_mestre.val_tot_ipi,
                 p_nf_mestre.val_tot_base_icm,
                 p_nf_mestre.val_tot_icm,
                 p_nf_mestre.val_tot_mercadoria,
                 p_nf_mestre.val_tot_nff,
                 p_nf_mestre.val_tot_base_ret,
                 p_nf_mestre.val_tot_icm_ret,
                 p_nf_mestre.ies_mod_embarque,
                 p_nf_mestre.cod_moeda,
                 p_nf_mestre.pct_bonificacao,
                 p_nf_mestre.cod_local_embarque,
                 p_nf_mestre.cod_entrega,
                 p_nf_mestre.val_tot_bonif,
                 0,                           
                 p_nf_mestre.val_seguro_cli,
                 0,                            
                 p_nf_mestre.val_seguro_ex,
                 p_nf_mestre.cod_tip_carteira,
                 p_nf_mestre.ies_plano_vendas)
      IF SQLCA.SQLCODE <> 0 THEN 
         LET p_houve_erro = TRUE 
         CALL log003_err_sql("INCLUSAO","NF_MESTRE")
         ROLLBACK WORK 
      END IF

      IF p_houve_erro THEN
         RETURN  
      END IF

      INSERT INTO sac_mestre 
         VALUES (p_empresas_885.cod_emp_gerencial,
                 p_num_nff_oper,
                 p_nf_mestre.ser_nff,
                 p_nf_mestre.cod_cliente,
                 p_nf_mestre.dat_emissao,
                 p_nf_mestre.cod_nat_oper,
                 p_nf_mestre.val_tot_nff,
                 p_nf_mestre.pes_tot_bruto,
                 p_nf_mestre.cod_transpor,
                 p_nf_mestre.cod_consig)
      IF SQLCA.SQLCODE <> 0 THEN 
         LET p_houve_erro = TRUE 
         CALL log003_err_sql("INCLUSAO","SAC_MESTRE")
         ROLLBACK WORK 
      END IF

      IF p_houve_erro THEN
         RETURN  
      END IF 

      INSERT INTO sac_pedido 
         VALUES (p_empresas_885.cod_emp_gerencial,
                 p_num_nff_oper,
                 p_nf_mestre.ser_nff,
                 p_nf_item.num_pedido,
                 '', 
                 '')
      IF SQLCA.SQLCODE <> 0 THEN
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("INCLUSAO","SAC_PEDIDO")
            ROLLBACK WORK 
      END IF 

      IF p_houve_erro THEN
         RETURN  
      END IF

      IF p_nf_fiscal.num_nff IS NOT NULL THEN
      INSERT INTO nf_fiscal 
         VALUES (p_empresas_885.cod_emp_gerencial,
                 p_num_nff_oper,
                 p_nf_fiscal.cod_fiscal,
                 p_nf_fiscal.val_tot_base_icm,
                 p_nf_fiscal.val_tot_icm,
                 p_nf_fiscal.val_tot_base_ipi,
                 p_nf_fiscal.val_tot_ipi,
                 p_nf_fiscal.pes_tot_liquido,
                 0,                            
                 p_nf_mestre.val_tot_nff,
                 p_nf_fiscal.val_tot_base_ret,
                 p_nf_fiscal.val_tot_icm_ret,
                 p_user)
        IF SQLCA.SQLCODE <> 0 THEN 
           ROLLBACK WORK 
           LET p_houve_erro = TRUE 
           CALL log003_err_sql("INCLUSAO","NF_FISCAL")
        END IF
      END IF

      IF p_houve_erro THEN
         RETURN  
      END IF

      LET p_wfat_mestre.ies_impr_nff = "N" 

      IF p_wfat_mestre.num_nff IS NOT NULL THEN
        INSERT INTO wfat_mestre 
           VALUES (p_empresas_885.cod_emp_gerencial,
                 p_num_nff_oper,
                 p_wfat_mestre.dat_emissao,
                 p_wfat_mestre.ies_origem,
                 p_wfat_mestre.cod_cliente,
                 p_wfat_mestre.num_placa,
                 p_wfat_mestre.cod_transpor,
                 p_wfat_mestre.cod_consig,
                 p_wfat_mestre.ies_zona_franca,
                 p_wfat_mestre.pct_frete,
                 p_wfat_mestre.ies_frete,
                 p_wfat_mestre.cod_cnd_pgto,
                 p_wfat_mestre.ies_incid_ipi,
                 p_wfat_mestre.ies_incid_icm,
                 p_wfat_mestre.pct_icm,
                 p_wfat_mestre.pct_desc_base_icm,
                 p_wfat_mestre.pct_comis,
                 p_wfat_mestre.ies_finalidade,
                 p_wfat_mestre.pct_desp_dist,
                 p_wfat_mestre.pct_desp_finan,
                 p_wfat_mestre.pes_tot_liquido,
                 p_wfat_mestre.pes_tot_bruto,
                 p_wfat_mestre.cod_embal_1,
                 p_wfat_mestre.qtd_volumes1,
                 p_wfat_mestre.cod_embal_2,
                 p_wfat_mestre.qtd_volumes2,
                 p_wfat_mestre.cod_embal_3,
                 p_wfat_mestre.qtd_volumes3,
                 p_wfat_mestre.cod_embal_4,
                 p_wfat_mestre.qtd_volumes4,
                 p_wfat_mestre.cod_embal_5,
                 p_wfat_mestre.qtd_volumes5,
                 p_wfat_mestre.num_pri_volume,
                 p_nf_mestre.cod_nat_oper,
                 p_wfat_mestre.cod_fiscal,
                 p_wfat_mestre.cod_origem,
                 p_wfat_mestre.cod_tributacao,
                 p_wfat_mestre.cod_texto1,
                 p_wfat_mestre.cod_texto2,
                 p_wfat_mestre.cod_texto3,
                 p_wfat_mestre.pct_desc_base_ipi,
                 p_wfat_mestre.pct_cred_icm,
                 p_wfat_mestre.tax_red_pct_icm,
                 p_wfat_mestre.pct_desc_ipi,
                 p_wfat_mestre.val_desc_merc,
                 p_wfat_mestre.cod_repres,
                 p_wfat_mestre.cod_repres_adic,
                 p_nf_mestre.val_desc_cred_icm,
                 0,                              
                 p_wfat_mestre.val_seguro_rod,
                 p_wfat_mestre.val_tot_base_ipi,
                 p_wfat_mestre.val_tot_ipi,
                 p_wfat_mestre.val_tot_base_icm,
                 p_wfat_mestre.val_tot_icm,
                 p_nf_mestre.val_tot_mercadoria,
                 p_nf_mestre.val_tot_nff,
                 p_user,
                 p_wfat_mestre.cod_sit_trib,
                 p_wfat_mestre.cod_trib_estadual,
                 p_wfat_mestre.cod_trib_federal,
                 p_wfat_mestre.val_acr_fin_excl,
                 p_wfat_mestre.val_acr_fin,
                 p_wfat_mestre.cod_via_transporte,
                 p_wfat_mestre.val_tot_base_ret,
                 p_wfat_mestre.val_tot_icm_ret,
                 p_wfat_mestre.ies_proc_nff,
                 p_wfat_mestre.ies_impr_nff,
                 p_wfat_mestre.ies_mod_embarque,
                 p_wfat_mestre.cod_moeda,
                 p_wfat_mestre.pct_bonificacao,
                 p_wfat_mestre.cod_local_embarque,
                 p_wfat_mestre.cod_entrega,
                 p_wfat_mestre.val_tot_bonif,
                 0,                              
                 p_wfat_mestre.val_seguro_cli,
                 0,                             
                 p_wfat_mestre.val_seguro_ex,
                 p_wfat_mestre.cod_tip_carteira,
                 p_wfat_mestre.ies_plano_vendas)
        IF SQLCA.SQLCODE <> 0 THEN 
           LET p_houve_erro = TRUE 
           CALL log003_err_sql("INCLUSAO","WFAT_MESTRE")
           ROLLBACK WORK 
        END IF
      END IF

      IF p_houve_erro THEN
         RETURN  
      END IF

      IF p_wfat_fiscal.num_nff IS NOT NULL THEN
         INSERT INTO wfat_fiscal 
              VALUES (p_empresas_885.cod_emp_gerencial,
                      p_num_nff_oper,
                      p_wfat_fiscal.cod_fiscal,
                      p_wfat_fiscal.val_tot_base_icm,
                      p_wfat_fiscal.val_tot_icm,
                      p_wfat_fiscal.val_tot_base_ipi,
                      p_wfat_fiscal.val_tot_ipi,
                      p_wfat_fiscal.pes_tot_liquido,
                      0,                               
                      p_nf_mestre.val_tot_nff,
                      p_wfat_fiscal.val_tot_base_ret,
                      p_wfat_fiscal.val_tot_icm_ret,
                      p_user) 
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("INCLUSAO","WFAT_FISCAL")
            ROLLBACK WORK 
         END IF
      END IF

      IF p_houve_erro THEN
         RETURN  
      END IF

    IF p_ies_emit_dupl = "S"  THEN
      LET p_nf_movto_dupl.num_lote = NULL 

      IF p_nf_movto_dupl.num_nff IS NOT NULL THEN
        INSERT INTO nf_movto_dupl 
           VALUES (p_empresas_885.cod_emp_gerencial,
                   p_num_nff_oper,
                   p_nf_movto_dupl.dat_operacao, 
                   p_nf_movto_dupl.ies_operacao, 
                   p_nf_movto_dupl.num_lote)
        IF SQLCA.SQLCODE <> 0 THEN 
           LET p_houve_erro = TRUE 
           CALL log003_err_sql("INCLUSAO","NF_MOVTO_DUPL")
           ROLLBACK WORK 
        END IF   
      END IF   

      IF p_houve_erro THEN
         RETURN  
      END IF

      LET p_data_ent = p_wfat_mestre.dat_emissao 

      DECLARE c_nf_duplicata CURSOR FOR
      SELECT * FROM cond_pgto_item
      WHERE cod_cnd_pgto = p_nf_mestre.cod_cnd_pgto
      ORDER BY sequencia

      FOREACH c_nf_duplicata INTO p_cond_pgto_item.*

        LET p_nf_duplicata.val_duplic = p_nf_mestre.val_tot_nff * p_cond_pgto_item.pct_valor_liquido / 100

        IF p_pct_desp_finan > 0 THEN
           LET p_nf_duplicata.val_duplic = p_nf_duplicata.val_duplic * p_pct_desp_finan
        END IF

        IF p_wfat_mestre.dat_emissao > p_data_ent THEN
           LET p_nf_duplicata.dat_vencto_sd = p_nf_mestre.dat_emissao + p_cond_pgto_item.qtd_dias_sd
        ELSE
           LET p_nf_duplicata.dat_vencto_sd = p_data_ent + p_cond_pgto_item.qtd_dias_sd
        END IF   

         INSERT INTO nf_duplicata 
            VALUES (p_empresas_885.cod_emp_gerencial,
                    p_num_nff_oper,
                    p_num_nff_oper,
                    p_cond_pgto_item.sequencia,
                    p_cond_pgto_item.pct_desc_financ,
                    p_nf_duplicata.val_duplic,
                    p_nf_duplicata.dat_vencto_sd,
                    NULL,                        
                    "01")
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("INCLUSAO","NF_DUPLICATA")
            ROLLBACK WORK 
            EXIT FOREACH
         END IF   

         INSERT INTO wfat_duplic 
            VALUES (p_empresas_885.cod_emp_gerencial,
                    p_num_nff_oper,
                    p_num_nff_oper,
                    p_cond_pgto_item.sequencia,
                    p_cond_pgto_item.pct_desc_financ,
                    p_nf_duplicata.val_duplic,
                    p_nf_duplicata.dat_vencto_sd,
                    NULL,
                    p_user)
         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_houve_erro = TRUE        
            CALL log003_err_sql("INCLUSAO","WFAT_DUPLIC")
            ROLLBACK WORK 
            EXIT FOREACH
         END IF   

      END FOREACH 
    END IF 

    LET p_copia_nf_vetor.num_nff_ds = p_num_nff_oper

     UPDATE ordem_montag_mest 
        SET ies_sit_om = "F" 
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
         AND num_om  = p_nf_item.num_om    

      IF SQLCA.SQLCODE <> 0 THEN 
         LET p_houve_erro = TRUE        
         CALL log003_err_sql("MODIFICA","ORDEM_MONTAG_MESTRE")
         ROLLBACK WORK 
      END IF    

      INSERT INTO copia_nf_vetor
         VALUES (p_copia_nf_vetor.cod_emp_or, 
                 p_copia_nf_vetor.num_nff_or, 
                 p_copia_nf_vetor.cod_emp_ds, 
                 p_copia_nf_vetor.num_nff_ds) 
      IF SQLCA.SQLCODE <> 0 THEN 
         LET p_houve_erro = TRUE        
         CALL log003_err_sql("INCLUSAO","COPIA_NF_VETOR")
         ROLLBACK WORK 
      END IF    

      LET p_ies_cons = FALSE
      MESSAGE ""
   
END FUNCTION

#-----------------------#
 FUNCTION pol0766_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#

