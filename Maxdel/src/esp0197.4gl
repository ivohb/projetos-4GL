#-----------------------------------------------------------------#
# PROGRAMA: esp0197                                               #
# OBJETIVO: COPIA DE NOTAS FISCAIS ENTRE EMPRESAS                 #
# Conversão para 10.02 - 10/10/2011                               #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_nf_mestre        RECORD LIKE fat_nf_mestre.*,
          p_fat_nf_repr      RECORD LIKE fat_nf_repr.*,
          p_nf_mestree       RECORD LIKE fat_nf_mestre.*,
          p_sac_item         RECORD LIKE sac_item.*,
          p_nf_fiscal        RECORD LIKE fat_mestre_fiscal.*,
          p_nf_item_fiscal   RECORD LIKE fat_nf_item_fisc.*,
          p_nf_movto_dupl    RECORD LIKE nf_movto_dupl.*,
          p_ordem_montag_item RECORD LIKE ordem_montag_item.*,
          p_desc_nat_oper    RECORD LIKE desc_nat_oper.*, 
          p_par_desc_oper    RECORD LIKE par_desc_oper.*,
          p_cond_pgto_item   RECORD LIKE cond_pgto_item.*,
          p_ped_itens        RECORD LIKE ped_itens.*,
          p_ped_itens_desc   RECORD LIKE ped_itens_desc.*,
          p_ped_itens_bnf    RECORD LIKE ped_itens_bnf.*,
          p_pct_desp_finan   LIKE cond_pgto.pct_desp_finan,
          p_cod_empresa      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_cod_uni_feder    char(02),
          p_qtd_res          LIKE ped_itens.qtd_pecas_reserv,  
          p_qtd_rom          LIKE ped_itens.qtd_pecas_romaneio,  
          p_cod_cla_fisc     LIKE item.cod_cla_fisc, 
          p_fat_conver       LIKE item.fat_conver,          
          p_val_tot_merc     decimal(17,2),
          p_val_tot_nf_or    decimal(17,2),
          p_val_tot_dupl     decimal(17,2),
          p_cod_nat_oper     LIKE nat_operacao.cod_nat_oper,     
          p_ies_subst_tribut LIKE nat_operacao.ies_subst_tribut,     
          p_ies_baixa_pedido LIKE nat_operacao.ies_baixa_pedido, 
          p_tip_docum        LIKE vdp_num_docum.tip_docum,
          p_trans_nf         Integer,
          p_ser_nf           char(03), 
          p_ssr_nf           Integer,
          p_val_tot_ipi      decimal(17,2),
          p_val_tot_icm      decimal(17,2),
          p_val_icm_tot_ret  decimal(17,2),
          p_val_base_tot_ret decimal(17,2),
          p_val_icm_ret      decimal(17,2),
          p_val_base_ret     decimal(17,2),
          p_val_tot_nf       decimal(17,2),
          p_val_tot_nff      decimal(17,2),
          p_val_tot_aux      CHAR(15),                     
          p_val_tot_ant      decimal(17,2),
          p_val_base_icm     decimal(17,2),
          p_val_b_icm        decimal(17,2),
          p_val_icm          decimal(17,2),          
          p_num_nff_oper     integer,
          p_num_nff          integer,
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
          p_copia            CHAR(1), 
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
          p_msg              CHAR(500),
          p_nota_fiscal      INTEGER,
          p_val_abat         decimal(15,2),
          p_count            INTEGER,
          p_cod_item         char(15),
          p_tem_tributo      SMALLINT,
          p_tributo_benef    char(11)

   DEFINE p_pct_desc_adic_mest dec(8,5),  #substituirá p_nf_item.pct_desc_adic_mest
          p_pct_desc_adic      dec(8,5),  #substituirá p_nf_item.pct_desc_adic
          p_val_tot_mercadoria dec(17,2),
          p_val_desc_adicional dec(17,2),
          p_val_ipi            dec(17,2),
          p_val_liquido        dec(17,2),
          p_trans_nf_dest      INTEGER,
          p_num_pedido         integer,
          p_val_desp_finan     dec(17,2)

   DEFINE t_nf_item ARRAY[500] OF RECORD
      cod_item       LIKE item.cod_item,
      den_item_reduz LIKE item.den_item_reduz,        
      qtd_fatur      LIKE fat_nf_item.qtd_item,        
      qtd_total      LIKE fat_nf_item.qtd_item,
      pre_unit       LIKE fat_nf_item.preco_unit_liquido
   END RECORD

   DEFINE t_ped_itens ARRAY[500] OF RECORD
      cod_item       LIKE ped_itens.cod_item,
      pre_unit       LIKE ped_itens.pre_unit
   END RECORD 

   DEFINE p_nf RECORD
      nom_cliente  LIKE clientes.nom_cliente,
      den_nat_oper LIKE nat_operacao.den_nat_oper    
   END RECORD

   DEFINE p_versao  CHAR(18) 
   
   DEFINE p_nf_duplicata RECORD
      empresa            LIKE fat_nf_duplicata.empresa,          
      trans_nota_fiscal  LIKE fat_nf_duplicata.trans_nota_fiscal,
      seq_duplicata      LIKE fat_nf_duplicata.seq_duplicata,    
      val_duplicata      LIKE fat_nf_duplicata.val_duplicata,    
      dat_vencto_cdesc   LIKE fat_nf_duplicata.dat_vencto_cdesc, 
      dat_vencto_sdesc   LIKE fat_nf_duplicata.dat_vencto_sdesc, 
      pct_desc_financ    LIKE fat_nf_duplicata.pct_desc_financ,  
      val_bc_comissao    LIKE fat_nf_duplicata.val_bc_comissao,  
      portador           LIKE fat_nf_duplicata.portador,         
      agencia            LIKE fat_nf_duplicata.agencia,          
      dig_agencia        LIKE fat_nf_duplicata.dig_agencia,      
      titulo_bancario    LIKE fat_nf_duplicata.titulo_bancario,  
      tip_duplicata      LIKE fat_nf_duplicata.tip_duplicata,    
      docum_cre          LIKE fat_nf_duplicata.docum_cre,        
      empresa_cre        LIKE fat_nf_duplicata.empresa_cre, 
      val_prov_comissao    decimal(17,2),
      val_prov_comis_extra decimal(17,2)
   END RECORD
        
END GLOBALS

DEFINE p_nf_item RECORD LIKE fat_nf_item.*

DEFINE p_fat_nf_item_fisc RECORD LIKE fat_nf_item_fisc.*

MAIN
   LET p_versao = "ESP0197-10.02.17"
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   DEFER INTERRUPT
   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL esp0197_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION esp0197_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("esp0197") RETURNING p_nom_tela 
   OPEN WINDOW w_esp0197 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   if not esp0197_cria_tabs() then
      return
   end if
      
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Notas Fiscais"
         HELP 2010
         MESSAGE ""
         CALL esp0197_consulta()                     
         IF p_ies_cons THEN 
            NEXT OPTION "Replicar"
         END IF
      COMMAND "Replicar" "Executa Copia da Nota Fiscal "
         HELP 2011
         MESSAGE ""
         IF p_ies_cons THEN
            IF p_copia = 'S' THEN  
               CALL log085_transacao("BEGIN")
               if not esp0197_total() then
                  CALL log085_transacao("ROLLBACK")
                  ERROR "Copia cancelada " 
               else
                  CALL log085_transacao("COMMIT")
                  ERROR "Copia Total efetuada com sucesso NF - ", p_num_nff_oper 
               end if
               NEXT OPTION "Consultar"
            ELSE
               ERROR 'Nota nao parametrizada para copia'
            END IF       
         ELSE
            ERROR "Consulte Previamente Antes de Processar"
            NEXT OPTION "Consultar"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL esp0197_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_esp0197

END FUNCTION

#-----------------------#
 FUNCTION esp0197_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION esp0197_cria_tabs()
#---------------------------#

   create temp table tab_tmp_maxdel ( 
      campo integer
   );
   
   if status <> 0 then
      CALL log003_err_sql("Criando",'tab_tmp_maxdel')
      return false
   end if

   create temp table pedido_tmp_maxdel ( 
      campo integer
   );
   
   if status <> 0 then
      CALL log003_err_sql("Criando",'pedido_tmp_maxdel')
      return false
   end if
  
   CREATE temp TABLE tributo_tmp (
      tributo_benef CHAR(11)
   );

   IF STATUS <> 0 THEN
		  CALL log003_err_sql("Criando","tributo_tmp")
		  RETURN FALSE
	  END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION esp0197_consulta()
#--------------------------#
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0197

   LET p_nota_fiscal = NULL 
   IF esp0197_entrada_dados() THEN
      if not esp0197_exibe_dados() then
         let INT_FLAG = false
      end if
   END IF

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_nota_fiscal = NULL 
      
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
   END IF
   
END FUNCTION

#-------------------------------#
 FUNCTION esp0197_entrada_dados()
#-------------------------------#
   
   DEFINE p_ies_situacao   LIKE nf_mestre.ies_situacao
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_esp0197

   LET INT_FLAG = FALSE  
   INPUT p_nota_fiscal, p_ser_nf, p_val_abat
      WITHOUT DEFAULTS from num_nff, ser_nf, val_desc_cred_icm

      AFTER FIELD num_nff     

      if p_nota_fiscal is null then
         ERROR "Campo com preenchimento obrigatório!"
         NEXT FIELD num_nff       
      END IF

      AFTER FIELD ser_nf     

      if p_ser_nf is null then
         ERROR "Campo com preenchimento obrigatório!"
         NEXT FIELD ser_nf       
      END IF

      SELECT tip_docum,
             subserie_docum
        INTO p_tip_docum,
             p_ssr_nf
        FROM vdp_num_docum
       WHERE empresa = p_cod_empresa
         and serie_docum = p_ser_nf
      
	    IF STATUS <> 0 THEN 
		     CALL log003_err_sql("LENDO",'VDP_NUM_DOCUM')
		     NEXT FIELD ser_nf       
	    END IF  

      SELECT *
        INTO p_nf_mestre.*
        FROM fat_nf_mestre                  
       WHERE empresa = p_cod_empresa            
         AND nota_fiscal = p_nota_fiscal
         AND serie_nota_fiscal = p_ser_nf
         and tip_nota_fiscal = p_tip_docum
         and subserie_nf = p_ssr_nf 
           
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("Lendo","fat_nf_mestre")
         NEXT FIELD num_nff       
      END IF

      IF esp0197_checa_par() THEN
         ERROR "Empresa para Copia sem Parametros Cadastrados" 
         NEXT FIELD num_nff
      END IF

      SELECT nota_fiscal
        FROM fat_nf_mestre                  
       WHERE empresa = p_par_desc_oper.cod_emp_oper            
         AND nota_fiscal = p_nota_fiscal
         AND serie_nota_fiscal = p_ser_nf
         and tip_nota_fiscal = p_tip_docum
         and subserie_nf = p_ssr_nf 

      IF status = 0 THEN 
         ERROR "Nota Fiscal ja Copiada nesta Empresa"
         NEXT FIELD num_nff
      END IF 

      LET p_val_abat = 0
      LET p_trans_nf = p_nf_mestre.trans_nota_fiscal
      
      AFTER FIELD val_desc_cred_icm
      
      if p_val_abat is null or p_val_abat < 0 then
         error 'Valor invalido para o campo!'
         next FIELD val_desc_cred_icm
      end if
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp0197
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF
 
END FUNCTION

#---------------------------#
 FUNCTION esp0197_checa_par()
#---------------------------# 

   INITIALIZE p_par_desc_oper.* TO NULL

   SELECT * 
      INTO p_par_desc_oper.*		
   FROM par_desc_oper 
   WHERE cod_emp_ofic = p_cod_empresa

   IF SQLCA.SQLCODE <> 0 THEN 
      RETURN TRUE 
   ELSE 
      RETURN FALSE 
   END IF
    
END FUNCTION 

#------------------------------#
 FUNCTION esp0197_exibe_dados()
#------------------------------#
   
   LET p_copia = 'S'

   SELECT pct_desp_finan,
          ies_emite_dupl
     INTO p_pct_desp_finan,
          p_ies_emit_dupl
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_nf_mestre.cond_pagto  

   if status <> 0 then
      call log003_err_sql('Lendo', 'cond_pgto')
      RETURN false
   end if

   SELECT nom_cliente
     INTO p_nf.nom_cliente
     FROM clientes
    WHERE cod_cliente = p_nf_mestre.cliente

   SELECT den_nat_oper,
          ies_baixa_pedido
     INTO p_nf.den_nat_oper,
          p_ies_baixa_pedido
     FROM nat_operacao
     WHERE cod_nat_oper = p_nf_mestre.natureza_operacao

   if status <> 0 then
      call log003_err_sql('Lendo', 'nat_operacao')
      RETURN false
   end if

   DISPLAY p_nf_mestre.nota_fiscal to num_nff
   DISPLAY p_nf_mestre.cliente     to cod_cliente
   DISPLAY p_nf.nom_cliente        to nom_cliente
   DISPLAY p_nf_mestre.natureza_operacao to cod_nat_oper
   DISPLAY p_nf.den_nat_oper to den_nat_oper

   INITIALIZE t_nf_item TO NULL
   INITIALIZE t_ped_itens TO NULL
   LET p_i = 1

   DECLARE c_nf_item CURSOR FOR
   SELECT a.pedido,
          a.seq_item_pedido,
          a.item,
          a.qtd_item,
          a.ord_montag
     FROM fat_nf_item a, item b
    WHERE a.empresa = p_cod_empresa
      AND a.trans_nota_fiscal = p_trans_nf
      AND b.cod_empresa = a.empresa
      AND b.cod_item = a.item
      AND b.ies_tip_item IN ('C','F')

   FOREACH c_nf_item INTO p_nf_item.pedido,
                          p_nf_item.seq_item_pedido,
                          p_nf_item.item,      
                          p_nf_item.qtd_item,
                          p_nf_item.ord_montag
                          
      if status <> 0 then
         call log003_err_sql('Lendo', 'fat_nf_item:c_nf_item')
         RETURN false
      end if

      let p_pct_desc_adic_mest = 0 #verificar em qual campo da fat_nf_item está esse desconto
      let p_pct_desc_adic = 0      #verificar em qual campo da fat_nf_item está esse desconto

      LET t_nf_item[p_i].cod_item  = p_nf_item.item
      LET t_nf_item[p_i].qtd_fatur = p_nf_item.qtd_item

      SELECT den_item_reduz
        INTO t_nf_item[p_i].den_item_reduz   
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_nf_item.item

      SELECT a.cod_item,
             a.pre_unit,
             b.qtd_reservada
        INTO t_ped_itens[p_i].cod_item, 
             t_ped_itens[p_i].pre_unit, 
             t_nf_item[p_i].qtd_total
        FROM ped_itens a, ordem_montag_item b
       WHERE a.cod_empresa   = p_par_desc_oper.cod_emp_oper
         AND a.num_pedido    = p_nf_item.pedido
         AND a.num_sequencia = p_nf_item.seq_item_pedido
         AND a.cod_empresa   = b.cod_empresa               
         AND a.num_pedido    = b.num_pedido         
         AND a.num_sequencia = b.num_sequencia          
         AND b.num_om        = p_nf_item.ord_montag

      IF SQLCA.SQLCODE <> 0 THEN
         LET t_nf_item[p_i].qtd_total = 0 
         LET p_copia = 'N'
         EXIT FOREACH 
      ELSE 
         LET t_ped_itens[p_i].pre_unit = t_ped_itens[p_i].pre_unit-(t_ped_itens[p_i].pre_unit*p_pct_desc_adic_mest/100)
         LET t_ped_itens[p_i].pre_unit = t_ped_itens[p_i].pre_unit-(t_ped_itens[p_i].pre_unit*p_pct_desc_adic/100)
         LET t_nf_item[p_i].pre_unit   = t_ped_itens[p_i].pre_unit
         LET t_nf_item[p_i].qtd_total  = p_nf_item.qtd_item
      END IF

      LET p_i = p_i + 1

   END FOREACH

   if p_i = 1 then
      LET p_copia = 'N'
   End if
   
   CALL SET_COUNT(p_i - 1)
   DISPLAY ARRAY t_nf_item TO s_nf_item.*
   END DISPLAY

   IF INT_FLAG THEN 
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE  
   END IF

END FUNCTION

#-------------------------------#
FUNCTION esp0197_ins_nf_mestre()
#-------------------------------#
 
   Let p_nf_mestre.empresa = p_par_desc_oper.cod_emp_oper
                                                                                             
   INSERT INTO fat_nf_mestre VALUES (p_nf_mestre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','FAT_NF_MESTRE')
      RETURN FALSE
   END IF
   
   LET p_trans_nf_dest = SQLCA.SQLERRD[2]

   SELECT representante,
          seq_representante,
          pct_comissao,
          tem_comissao
     INTO p_fat_nf_repr.representante,
          p_fat_nf_repr.seq_representante,
          p_fat_nf_repr.pct_comissao,
          p_fat_nf_repr.tem_comissao
     FROM fat_nf_repr
    WHERE empresa = p_cod_empresa
      and trans_nota_fiscal = p_trans_nf
   
   if status = 0 then
      let p_fat_nf_repr.empresa = p_nf_mestre.empresa
      let p_fat_nf_repr.trans_nota_fiscal = p_trans_nf_dest
      if p_fat_nf_repr.pct_comissao is null then
         let p_fat_nf_repr.pct_comissao = 0
      end if
      INSERT INTO fat_nf_repr
       VALUES(p_fat_nf_repr.*)
    
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERINDO','FAT_NF_REPR')
         RETURN FALSE
      END IF
   end if
   
   if not esp0197_insere_integr() then
      RETURN FALSE
   end if
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION esp0197_insere_integr() 
#-------------------------------#

  DEFINE p_nf_integr RECORD 
		empresa 		       char(2),
		trans_nota_fiscal  integer,
		sit_nota_fiscal 	 char(1),
		status_intg_est 	 char(1),
		dat_hr_intg_est 	 datetime year to second,
		status_intg_contab char(1),
		dat_hr_intg_contab datetime year to second,
		status_intg_creceb char(1),
		dat_hr_intg_creceb datetime year to second,
		status_integr_obf  char(1),
		dat_hor_integr_obf datetime year to second,
		status_intg_migr 	 char(1),
		dat_hr_intg_migr 	 datetime year to second
  END RECORD
	 
  INITIALIZE 	 p_nf_integr  TO NULL
  
  LET  p_nf_integr.empresa           	= p_par_desc_oper.cod_emp_oper
  LET  p_nf_integr.trans_nota_fiscal 	= p_trans_nf_dest
  LET  p_nf_integr.sit_nota_fiscal   	= 'N'
  LET  p_nf_integr.status_intg_est   	= 'P' 	 
#  LET  p_nf_integr.dat_hr_intg_est		= p_fat_mestre.dat_hor_emissao   	 
  LET  p_nf_integr.status_intg_contab	= 'P'	 
#  LET  p_nf_integr.dat_hr_intg_contab	= 	 
  LET  p_nf_integr.status_intg_creceb	= 'P'	 
#  LET  p_nf_integr.dat_hr_intg_creceb	= 
  LET  p_nf_integr.status_integr_obf	= 'P'	 
#  LET  p_nf_integr.dat_hor_integr_obf	= 	 
  LET  p_nf_integr.status_intg_migr		= 'P'	 
#  LET  p_nf_integr.dat_hr_intg_migr	= 	 
	
	INSERT INTO fat_nf_integr
	 VALUES(p_nf_integr.*)	        
	 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','fat_nf_integr')
      RETURN FALSE
   END IF
	
	RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION esp0197_total()
#-----------------------#

   if not esp0197_ins_nf_mestre() then
      RETURN false
   end if

   LET p_houve_erro = FALSE
   LET p_val_tot_mercadoria = 0    
   LET p_val_tot_ipi = 0              
   LET p_pct_dupl = 0

   LET p_num_nff_oper = p_nf_mestre.nota_fiscal 
   LET w_i = 1
   
   delete from tab_tmp_maxdel
   
   DECLARE c_nf_item1 CURSOR FOR 
    SELECT * FROM fat_nf_item
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = p_trans_nf
      
   FOREACH c_nf_item1 INTO p_nf_item.*  
      
      if status <> 0 then
         call log003_err_sql('Lendo','fat_nf_item:c_nf_item1')
      End if
      
      let p_num_pedido = p_nf_item.pedido

      IF t_nf_item[w_i].qtd_total = 0 or
         t_ped_itens[w_i].pre_unit  IS NULL THEN
         CONTINUE FOREACH
      END IF

      LET p_val_desc_adicional = 0

      LET p_nf_item.preco_unit_liquido = t_ped_itens[w_i].pre_unit
      LET p_nf_item.qtd_item           = t_nf_item[w_i].qtd_total
      LET p_val_liquido                = p_nf_item.qtd_item * p_nf_item.preco_unit_liquido
      LET p_val_tot_mercadoria         = p_val_tot_mercadoria +  p_val_liquido
      
      LET p_nf_item.val_liquido_item   = p_val_liquido                                                                         
      LET p_nf_item.val_duplicata_item = p_val_liquido                                                                         
      LET p_nf_item.preco_unit_bruto   = p_nf_item.preco_unit_liquido                                                          
      LET p_nf_item.pre_uni_desc_incnd = p_nf_item.preco_unit_liquido                                                          
      LET p_nf_item.val_merc_item      = p_nf_item.val_liquido_item                                                            
      LET p_nf_item.val_bruto_item     = p_nf_item.val_liquido_item                                                            
      LET p_nf_item.val_brt_desc_incnd = p_nf_item.val_liquido_item   
      LET p_nf_item.val_contab_item    = p_nf_item.val_liquido_item                                                                  
      LET p_nf_item.empresa            = p_par_desc_oper.cod_emp_oper

      INSERT INTO fat_nf_item values(p_nf_item.*)
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERINDO','fat_nf_item')
         RETURN FALSE
      END IF
      
      IF p_ies_baixa_pedido = "S" THEN
         if not esp0197_atualiza_pedido() then
            RETURN false
         end if
      end if
       
      select campo from tab_tmp_maxdel
       where campo = p_nf_item.ord_montag
      
      if status = 100 then
         insert into tab_tmp_maxdel values(p_nf_item.ord_montag)
         if status <> 0 then
            call log003_err_sql('Inserindo','tab_tmp_maxdel')
            RETURN FALSE
         end if
      end if
      
      LET w_i = w_i + 1

   END FOREACH 

   DECLARE c_nf_item_fiscal CURSOR FOR                                
    SELECT * FROM fat_nf_item_fisc                                          
     WHERE empresa = p_cod_empresa                                     
       AND trans_nota_fiscal = p_trans_nf
                                                                      
   FOREACH c_nf_item_fiscal INTO p_nf_item_fiscal.*                      

      LET p_nf_item_fiscal.empresa = p_par_desc_oper.cod_emp_oper
      LET p_nf_item_fiscal.trans_nota_fiscal  = p_trans_nf_dest
      LET p_nf_item_fiscal.bc_trib_mercadoria = 0
      LET p_nf_item_fiscal.bc_tributo_frete   = 0
      LET p_nf_item_fiscal.bc_trib_calculado  = 0
      LET p_nf_item_fiscal.bc_tributo_tot     = 0
      LET p_nf_item_fiscal.val_trib_merc      = 0
      LET p_nf_item_fiscal.val_tributo_frete  = 0
      LET p_nf_item_fiscal.val_trib_calculado = 0
      LET p_nf_item_fiscal.val_tributo_tot    = 0
      LET p_nf_item_fiscal.incide             = 'N'
      LET p_nf_item_fiscal.aliquota           = 0
                                                         
      INSERT INTO fat_nf_item_fisc                                         
         VALUES (p_nf_item_fiscal.*)

      if status <> 0 then
         call log003_err_sql('Inserindo','fat_nf_item_fisc')
         RETURN FALSE
      end if
      
      let p_fat_nf_item_fisc.* = p_nf_item_fiscal.*
                                                                            
   END FOREACH                                                           
   
   if not esp0197_proces_om() then
      RETURN FALSE
   end if

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION esp0197_ins_tributos()
#------------------------------#

 LET p_fat_nf_item_fisc.empresa = p_par_desc_oper.cod_emp_oper
 LET p_fat_nf_item_fisc.trans_nota_fiscal = p_trans_nf_dest
 LET p_fat_nf_item_fisc.seq_item_nf = p_nf_item.seq_item_nf

 DECLARE cq_trib_tmp cursor for
  select distinct tributo_benef
    from tributo_tmp

 FOREACH cq_trib_tmp into p_tributo_benef
 
    if status <> 0 then
       call log003_err_sql('Lendo','tributo_tmp')
       RETURN FALSE
    end if
  
    LET p_fat_nf_item_fisc.tributo_benef = p_tributo_benef
        
    INSERT INTO fat_nf_item_fisc                                         
       VALUES (p_nf_item_fiscal.*)

    if status <> 0 then
       call log003_err_sql('Inserindo','fat_nf_item_fisc')
       RETURN FALSE
    end if
 
 End FOREACH
 
 RETURN true
 
end FUNCTION

#----------------------------------#
FUNCTION esp0197_ins_mestre_fiscal()
#----------------------------------#

   INITIALIZE p_mest_fisc TO NULL

   LET p_nf_fiscal.empresa            = p_par_desc_oper.cod_emp_oper  
   LET p_nf_fiscal.trans_nota_fiscal  = p_trans_nf_dest

   DECLARE cq_sum CURSOR FOR
    SELECT tributo_benef,
           SUM(bc_trib_mercadoria),
           SUM(bc_tributo_tot),
           SUM(val_trib_merc),
           SUM(val_tributo_tot),
           SUM(val_trib_calculado),
           SUM(val_tributo_frete),
           SUM(bc_trib_calculado),
           SUM(bc_tributo_frete)
      FROM fat_nf_item_fisc
     WHERE empresa = p_nf_fiscal.empresa 
       AND trans_nota_fiscal = p_trans_nf_dest
     GROUP BY tributo_benef

   FOREACH cq_sum INTO 
           p_nf_fiscal.tributo_benef,
           p_nf_fiscal.bc_trib_mercadoria,
           p_nf_fiscal.bc_tributo_tot,
           p_nf_fiscal.val_trib_merc,
           p_nf_fiscal.val_tributo_tot,
           p_nf_fiscal.val_trib_calculado,
           p_nf_fiscal.val_tributo_frete,
           p_nf_fiscal.bc_trib_calculado,
           p_nf_fiscal.bc_tributo_frete
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_item_fisc')
         RETURN FALSE
      END IF

      INSERT INTO fat_mestre_fiscal
       VALUES(p_nf_fiscal.*)
    
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','fat_mestre_fiscal')
         RETURN FALSE
      END IF
   
   END FOREACH
    
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION esp0197_atu_mestre()
#----------------------------#
   
   UPDATE fat_nf_mestre
      SET val_mercadoria  = p_nf_mestre.val_mercadoria,
          val_duplicata   = p_nf_mestre.val_duplicata,
          val_nota_fiscal = p_nf_mestre.val_nota_fiscal
    WHERE empresa = p_par_desc_oper.cod_emp_oper
      AND trans_nota_fiscal = p_trans_nf_dest
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update', 'fat_nf_mestre')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


### ITENS QUE NA DIVISAO FICARAM ZERADOS NA EMPRESA 01 E NAO SAO BONIFICACAO.

#----------------------------#
FUNCTION esp0197_proces_om()
#----------------------------#

delete from pedido_tmp_maxdel

DECLARE cq_temp cursor for
 select campo from tab_tmp_maxdel

FOREACH cq_temp into p_nf_item.ord_montag

 if status <> 0 then
    call log003_err_sql('Lendo','tab_tmp_maxdel:cq_temp')
    RETURN false
 end if

 DECLARE c_itsf CURSOR FOR 
  SELECT * 
    FROM ordem_montag_item
   WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
     AND num_om     = p_nf_item.ord_montag    

 FOREACH c_itsf INTO p_ordem_montag_item.*
    
    if status <> 0 then
       call log003_err_sql('Lendo','ordem_montag_item:c_itsf')
       RETURN FALSE
    end if
    
    SELECT * 
      FROM fat_nf_item
     WHERE empresa = p_par_desc_oper.cod_emp_oper
       AND trans_nota_fiscal = p_trans_nf_dest
       AND ord_montag  = p_ordem_montag_item.num_om
       AND pedido  = p_ordem_montag_item.num_pedido
       AND seq_item_pedido = p_ordem_montag_item.num_sequencia
       AND item = p_ordem_montag_item.cod_item

    if status = 0 then
       CONTINUE FOREACH
    end if

    IF status <> 100 THEN
       call log003_err_sql('Lendo','fat_nf_item:c_itsf')
       RETURN false
    end if
    
    SELECT *                                                  
      INTO p_ped_itens_bnf.*                                     
      FROM ped_itens_bnf                                         
     WHERE cod_empresa = p_cod_empresa                           
       AND num_pedido  = p_ordem_montag_item.num_pedido          
       AND num_sequencia = p_ordem_montag_item.num_sequencia     
       AND cod_item      = p_ordem_montag_item.cod_item          

    if status = 0 then
       CONTINUE FOREACH
    end if

    IF status <> 100 THEN
       call log003_err_sql('Lendo','ped_itens_bnf:c_itsf')
       RETURN false
    end if
             
    SELECT *                                                                                                            
      INTO p_ped_itens.*                                                                                                     
      FROM ped_itens                                                                                                         
     WHERE cod_empresa   = p_par_desc_oper.cod_emp_oper                                                                      
       AND num_pedido    = p_ordem_montag_item.num_pedido                                                                    
       AND num_sequencia = p_ordem_montag_item.num_sequencia                                                                 
       AND cod_item      = p_ordem_montag_item.cod_item                                                                      
                                                                                                                        
     SELECT den_item,                                                                                                        
            pes_unit,                                                                                                        
            cod_unid_med,                                                                                                    
            cod_cla_fisc,                                                                                                    
            fat_conver                                                                                                       
       INTO p_den_item,                                                                                                      
            p_pes_unit,                                                                                                      
            p_cod_unid_med,                                                                                                  
            p_cod_cla_fisc,                                                                                                  
            p_fat_conver                                                                                                     
       FROM item                                                                                                             
      WHERE cod_empresa = p_cod_empresa                                                                                      
        AND cod_item = p_ordem_montag_item.cod_item                                                                          
                                                                                                                        
    SELECT *                                                                                                                 
      INTO p_ped_itens_desc.*                                                                                                
      FROM ped_itens_desc                                                                                                    
     WHERE cod_empresa   = p_par_desc_oper.cod_emp_oper                                                                      
       AND num_pedido    = p_ordem_montag_item.num_pedido                                                                    
       AND num_sequencia = 0                                                                                                 
                                                                                                                        
    IF status  = 0 THEN                                                                                                      
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_1 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_2 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_3 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_4 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_5 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_6 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_7 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_8 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_9 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_10 / 100)          
    END IF                                                                                                                   
                                                                                                                        
    SELECT *                                                                                                                 
      INTO p_ped_itens_desc.*                                                                                                
      FROM ped_itens_desc                                                                                                    
     WHERE cod_empresa   = p_par_desc_oper.cod_emp_oper                                                                      
       AND num_pedido    = p_ordem_montag_item.num_pedido                                                                    
       AND num_sequencia = p_ordem_montag_item.num_sequencia                                                                 
                                                                                                                        
    IF status  = 0 THEN                                                                                                      
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_1 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_2 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_3 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_4 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_5 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_6 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_7 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_8 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_9 / 100)           
      LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_ped_itens_desc.pct_desc_10 / 100)          
    END IF                                                                                                                   
                                                                                                                             
    LET p_val_desc_adicional = 0                                                                                             
    LET p_val_liquido = p_ordem_montag_item.qtd_reservada * p_ped_itens.pre_unit                                             
    LET p_val_tot_mercadoria = p_val_tot_mercadoria + p_val_liquido                                                          
                                                                                                                             
    select max(seq_item_nf)                                                                                                  
       into p_nf_item.seq_item_nf                                                                                            
       from fat_nf_item                                                                                                      
      where empresa = p_par_desc_oper.cod_emp_oper                                                                           
        and trans_nota_fiscal = p_trans_nf_dest                                                                              
                                                                                                                             
    if p_nf_item.seq_item_nf is null then                                                                                    
       let p_nf_item.seq_item_nf = 1                                                                                         
    else                                                                                                                     
       let p_nf_item.seq_item_nf = p_nf_item.seq_item_nf + 1                                                                 
    end if                                                                                                                   
                                                                                                                             
    select campo from pedido_tmp_maxdel
       where campo = p_ordem_montag_item.num_pedido
      
    if status = 100 then
       insert into pedido_tmp_maxdel values(p_ordem_montag_item.num_pedido)
       if status <> 0 then
          call log003_err_sql('Inserindo','pedido_tmp_maxdel')
          RETURN FALSE
       end if
    end if
                                                         
    LET p_nf_item.Empresa           = p_par_desc_oper.cod_emp_oper                                                           
    LET p_nf_item.trans_nota_fiscal = p_trans_nf_dest                                                                        
    LET p_nf_item.pedido  			     = p_ordem_montag_item.num_pedido                                                        
	  LET p_nf_item.seq_item_pedido   = p_ordem_montag_item.num_sequencia                                                      
    LET p_nf_item.ord_montag        = p_ordem_montag_item.num_om                                                             
	  LET p_nf_item.item     				  = p_ordem_montag_item.cod_item                                                            
    LET p_nf_item.tip_item          = 'N'                                                                                    
    LET p_nf_item.tip_preco         = 'F'                                                                                    
    
    SELECT cod_nat_oper_ref INTO p_cod_nat_oper
      FROM nat_oper_refer
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = p_nf_item.item 
       AND cod_nat_oper = p_nf_mestre.natureza_operacao
    
    if status <> 0 and status <> 100 then
       call log003_err_sql('Inserindo','nat_oper_refer')
       RETURN FALSE
    end if
    
    if status = 0 then
       LET p_nf_item.natureza_operacao = p_cod_nat_oper
    else
       LET p_nf_item.natureza_operacao = p_nf_mestre.natureza_operacao  
       let p_cod_nat_oper = p_nf_mestre.natureza_operacao
    end if
                                                            
    LET p_nf_item.qtd_item          = p_ordem_montag_item.qtd_reservada                                                      
    LET p_nf_item.unid_medida       = p_cod_unid_med                                                                         
    LET p_nf_item.des_item          = p_den_item                                                                             
    LET p_nf_item.peso_unit         = p_pes_unit                                                                             
    LET p_nf_item.classif_fisc      = p_cod_cla_fisc                                                                         
    LET p_nf_item.fator_conv        = p_fat_conver                                                                           
    LET p_nf_item.val_desc_merc      = 0                                                                                     
    LET p_nf_item.val_desc_contab    = 0                                                                                     
    LET p_nf_item.val_desc_duplicata = 0                                                                                     
    LET p_nf_item.val_acresc_item    = 0                                                                                     
    LET p_nf_item.val_acre_merc      = 0                                                                                     
    LET p_nf_item.val_acresc_contab  = 0                                                                                     
    LET p_nf_item.val_acre_duplicata = 0                                                                                     
    LET p_nf_item.val_fret_consig    = 0                                                                                     
    LET p_nf_item.val_segr_consig    = 0                                                                                     
    LET p_nf_item.val_frete_cliente  = 0                                                                                     
    LET p_nf_item.val_seguro_cliente = 0                                                                                     
    LET p_nf_item.val_liquido_item   = p_val_liquido                                                                         
    LET p_nf_item.val_duplicata_item = p_val_liquido                                                                         
    LET p_nf_item.preco_unit_liquido = p_ped_itens.pre_unit                                                                  
    LET p_nf_item.preco_unit_bruto   = p_nf_item.preco_unit_liquido                                                          
    LET p_nf_item.pre_uni_desc_incnd = p_nf_item.preco_unit_liquido                                                          
    LET p_nf_item.val_merc_item      = p_nf_item.val_liquido_item                                                            
    LET p_nf_item.val_bruto_item     = p_nf_item.val_liquido_item                                                            
    LET p_nf_item.val_brt_desc_incnd = p_nf_item.val_liquido_item 
    LET p_nf_item.val_contab_item    = p_nf_item.val_liquido_item                                                           
                                                                                                                             
    INSERT INTO fat_nf_item values(p_nf_item.*)                                                                              
                                                                                                                        
    IF STATUS <> 0 THEN                                                                                                      
       CALL log003_err_sql('INSERINDO','fat_nf_item')                                                                        
       RETURN FALSE                                                                                                          
    END IF                                                                                                                   

    DELETE FROM tributo_tmp
    
    let p_cod_item = p_ordem_montag_item.cod_item   
    
    IF NOT esp0197_le_param_fisc() THEN 
       RETURN FALSE
    END IF
    
    if p_tem_tributo then
       if not esp0197_ins_tributos() then
          RETURN false
       end if
    end if       

 END FOREACH

END FOREACH


   if not esp0197_ins_mestre_fiscal() then
      RETURN FALSE
   end if

   IF p_val_abat > p_val_tot_mercadoria THEN 
      let p_msg = 'Valor do abatimento maior que valor total da mercadoria!'
      call log0030_mensagem(p_msg,'excla')      
      RETURN FALSE
   ELSE
      LET p_val_tot_mercadoria = p_val_tot_mercadoria - p_val_abat
      LET p_nf_mestre.val_mercadoria  = p_val_tot_mercadoria
      LET p_nf_mestre.val_duplicata   = p_val_tot_mercadoria
      LET p_nf_mestre.val_nota_fiscal = p_val_tot_mercadoria
   END IF
   
   if not esp0197_atu_mestre() then
      RETURN FALSE
   end if

   let p_data = extend(p_nf_mestre.dat_hor_emissao, year to day)

   INSERT INTO sac_mestre 
      VALUES (p_par_desc_oper.cod_emp_oper,
              p_nota_fiscal,
              p_ser_nf,
              p_nf_mestre.cliente,
              p_data,
              p_nf_mestre.natureza_operacao,
              p_nf_mestre.val_nota_fiscal,
              p_nf_mestre.peso_bruto,
              p_nf_mestre.transportadora,
              ' ')

   IF status <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","SAC_MESTRE")
      RETURN FALSE
   END IF

   DECLARE cq_sac_pedido cursor for
    select distinct campo from pedido_tmp_maxdel 
   
   FOREACH cq_sac_pedido into p_num_pedido

      IF status <> 0 THEN 
         CALL log003_err_sql("Lendo","cq_sac_pedido")
         RETURN FALSE
      END IF
   
      INSERT INTO sac_pedido 
         VALUES (p_par_desc_oper.cod_emp_oper,
                 p_nota_fiscal,
                 p_ser_nf,
                 p_num_pedido,
                 '', 
                 '')

      IF status <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","sac_pedido")
         RETURN FALSE
      END IF
   
   END FOREACH
   
   IF p_ies_emit_dupl = "S"  THEN

      DECLARE cq_fat_nf_dupl cursor for
        SELECT empresa,          
               trans_nota_fiscal,
               seq_duplicata,    
               val_duplicata,    
               dat_vencto_cdesc, 
               dat_vencto_sdesc, 
               pct_desc_financ,  
               val_bc_comissao,  
               portador,         
               agencia,          
               dig_agencia,      
               titulo_bancario,  
               tip_duplicata,    
               docum_cre,        
               empresa_cre      
          FROM fat_nf_duplicata 
         WHERE empresa = p_cod_empresa
           AND trans_nota_fiscal = p_trans_nf
         ORDER BY seq_duplicata
      
      FOREACH cq_fat_nf_dupl INTO p_nf_duplicata.*  

        if status <> 0 then
           call log003_err_sql('Lendo', 'fat_nf_duplicata:cq_fat_nf_dupl')
           RETURN FALSE
        end if
     
        LET p_nf_duplicata.val_prov_comissao    = 0
        LET p_nf_duplicata.val_prov_comis_extra = 0

        SELECT * 
          INTO p_cond_pgto_item.*
          FROM cond_pgto_item
         WHERE cod_cnd_pgto = p_nf_mestre.cond_pagto
           and sequencia    = p_nf_duplicata.seq_duplicata
       
        if status <> 0 then
           call log003_err_sql('Lendo', 'cond_pgto_item:cq_fat_nf_dupl')
           RETURN FALSE
        end if
              
        LET p_nf_duplicata.val_duplicata = p_nf_mestre.val_nota_fiscal * p_cond_pgto_item.pct_valor_liquido / 100

        IF p_nf_duplicata.pct_desc_financ > 0 THEN
           let p_val_desp_finan = p_nf_duplicata.val_duplicata * p_nf_duplicata.pct_desc_financ / 100
           LET p_nf_duplicata.val_duplicata = p_nf_duplicata.val_duplicata + p_val_desp_finan
        END IF
        
        LET p_nf_duplicata.empresa           = p_par_desc_oper.cod_emp_oper
        LET p_nf_duplicata.trans_nota_fiscal = p_trans_nf_dest
        LET p_nf_duplicata.empresa_cre       = 'O1'
        LET p_nf_duplicata.val_bc_comissao   = p_nf_duplicata.val_duplicata
        
        INSERT INTO fat_nf_duplicata 
           VALUES (p_nf_duplicata.*)
        
        IF status <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","NF_DUPLICATA")
           RETURN FALSE
        END IF   

      END FOREACH 

   END IF 

   UPDATE ordem_montag_mest 
     SET ies_sit_om = "F" 
   WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
     AND num_om  = p_nf_item.ord_montag    

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("MODIFICA","ORDEM_MONTAG_MESTRE")
      RETURN FALSE
   END IF    

   IF NOT esp0197_bonif() THEN
      RETURN FALSE
   End if
   
END FUNCTION

#---------------------------------#
FUNCTION esp0197_atualiza_pedido()
#---------------------------------#

   SELECT qtd_pecas_reserv,                                                       
          qtd_pecas_romaneio                                                            
     INTO p_qtd_res,                                                                    
          p_qtd_rom                                                                     
     FROM ped_itens                                                                     
    WHERE cod_empresa = p_par_desc_oper.cod_emp_oper                                    
      AND num_pedido  = p_nf_item.pedido                                                
      AND cod_item    = p_nf_item.item                                                  
      AND num_sequencia = p_nf_item.seq_item_pedido                                     
                                                                 
   if status <> 0 then                                              
      return true                                                   
   end if                                                           
                                                                                           
   SELECT cod_nat_oper  INTO p_cod_nat_oper                                             
     FROM ped_item_nat                                                                  
    WHERE cod_empresa = p_cod_empresa                                                   
      AND num_pedido  = p_nf_item.pedido                                                
      AND num_sequencia = p_nf_item.seq_item_pedido                                     
                                                                                        
   IF status = 0 THEN                                                                   
      SELECT *                                                                          
        INTO p_desc_nat_oper.*                                                          
        FROM desc_nat_oper                                                              
       WHERE cod_cliente = p_nf_mestre.cliente                                          
         AND cod_nat_oper = p_cod_nat_oper                                              
                                                                                        
      IF status <> 0 THEN                                                               
         SELECT *                                                                       
           INTO p_desc_nat_oper.*                                                       
           FROM desc_nat_oper                                                           
          WHERE cod_cliente = "0"                                                       
            AND cod_nat_oper = p_cod_nat_oper                                           
                                                                                     
         IF status <> 0 THEN                                                            
            LET p_desc_nat_oper.pct_desc_valor =0                                       
         END IF                                                                         
      END IF                                                                            
   ELSE                                                                                 
      SELECT *                                                                          
        INTO p_desc_nat_oper.*                                                          
        FROM desc_nat_oper                                                              
       WHERE cod_cliente = p_nf_mestre.cliente                                          
         AND cod_nat_oper = p_nf_mestre.natureza_operacao                               
                                                                                        
      IF status <> 0 THEN                                                               
         SELECT *                                                                       
           INTO p_desc_nat_oper.*                                                       
           FROM desc_nat_oper                                                           
          WHERE cod_cliente = "0"                                                       
            AND cod_nat_oper = p_nf_mestre.natureza_operacao                            
                                                                                     
         IF status <> 0 THEN                                                            
            LET p_desc_nat_oper.pct_desc_valor = 0                                      
         END IF                                                                         
      END IF                                                                            
   END IF                                                                               

   IF p_desc_nat_oper.pct_desc_valor > 0 THEN                                                        
      If p_qtd_rom < p_nf_item.qtd_item THEN                                                            
        UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend + p_nf_item.qtd_item,                    
                             qtd_pecas_romaneio = 0                                                     
         WHERE cod_empresa = p_par_desc_oper.cod_emp_oper                                               
           AND num_pedido  = p_nf_item.pedido                                                           
           AND cod_item    = p_nf_item.item                                                             
           AND num_sequencia = p_nf_item.seq_item_pedido                                                
      Else                                                                                              
        UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend + p_nf_item.qtd_item,                    
                             qtd_pecas_romaneio = qtd_pecas_romaneio - p_nf_item.qtd_item               
         WHERE cod_empresa = p_par_desc_oper.cod_emp_oper                                               
           AND num_pedido  = p_nf_item.pedido                                                           
           AND cod_item    = p_nf_item.item                                                             
            AND num_sequencia = p_nf_item.seq_item_pedido                                               
      END IF                                                                                            
   ELSE                                                                                                 
      IF p_qtd_res < t_nf_item[w_i].qtd_fatur THEN                                                      
         IF p_qtd_rom < t_nf_item[w_i].qtd_fatur THEN                                                   
            UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend +                                    
                                 p_nf_item.qtd_item + t_nf_item[w_i].qtd_fatur,                         
                   qtd_pecas_reserv = 0,                                                                
                   qtd_pecas_romaneio = 0                                                               
             WHERE cod_empresa = p_par_desc_oper.cod_emp_oper                                           
               AND num_pedido  = p_nf_item.pedido                                                       
               AND cod_item    = p_nf_item.item                                                         
               AND num_sequencia = p_nf_item.seq_item_pedido                                            
         ELSE                                                                                           
            UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend +                                    
                                 p_nf_item.qtd_item + t_nf_item[w_i].qtd_fatur,                         
                   qtd_pecas_reserv = 0,                                                                
                   qtd_pecas_romaneio = qtd_pecas_romaneio - p_nf_item.qtd_item                         
             WHERE cod_empresa = p_par_desc_oper.cod_emp_oper                                           
               AND num_pedido  = p_nf_item.pedido                                                       
               AND cod_item    = p_nf_item.item                                                         
               AND num_sequencia = p_nf_item.seq_item_pedido                                            
         END IF                                                                                         
      ELSE                                                                                              
         IF p_qtd_rom < t_nf_item[w_i].qtd_fatur THEN                                                   
            UPDATE ped_itens SET                                                                        
                   qtd_pecas_atend = qtd_pecas_atend + p_nf_item.qtd_item + t_nf_item[w_i].qtd_fatur,   
                   qtd_pecas_reserv = qtd_pecas_reserv - t_nf_item[w_i].qtd_fatur,                      
                   qtd_pecas_romaneio = 0                                                               
             WHERE cod_empresa = p_par_desc_oper.cod_emp_oper                                           
               AND num_pedido  = p_nf_item.pedido                                                       
               AND cod_item    = p_nf_item.item                                                         
               AND num_sequencia = p_nf_item.seq_item_pedido                                            
         ELSE                                                                                           
            UPDATE ped_itens SET                                                                        
                   qtd_pecas_atend = qtd_pecas_atend + p_nf_item.qtd_item + t_nf_item[w_i].qtd_fatur,   
                   qtd_pecas_reserv = qtd_pecas_reserv - t_nf_item[w_i].qtd_fatur,                      
                   qtd_pecas_romaneio = qtd_pecas_romaneio - p_nf_item.qtd_item                         
             WHERE cod_empresa = p_par_desc_oper.cod_emp_oper                                           
               AND num_pedido  = p_nf_item.pedido                                                       
               AND cod_item    = p_nf_item.item                                                         
               AND num_sequencia = p_nf_item.seq_item_pedido                                            
         END IF                                                                                         
      END IF                                                                                            
                                                                                                        
      SELECT qtd_pecas_reserv,                                                                          
             qtd_pecas_romaneio                                                                         
        INTO p_qtd_res,                                                                                 
             p_qtd_rom                                                                                  
        FROM ped_itens                                                                                  
       WHERE cod_empresa = p_cod_empresa                                                                
         AND num_pedido  = p_nf_item.pedido                                                             
         AND cod_item    = p_nf_item.item                                                               
         AND num_sequencia = p_nf_item.seq_item_pedido                                                  
      IF p_qtd_rom < t_nf_item[w_i].qtd_fatur THEN                                                      
         UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend + p_nf_item.qtd_item,                   
                              qtd_pecas_romaneio = 0                                                    
          WHERE cod_empresa = p_cod_empresa                                                             
            AND num_pedido  = p_nf_item.pedido                                                          
            AND cod_item    = p_nf_item.item                                                            
            AND num_sequencia = p_nf_item.seq_item_pedido                                               
      ELSE                                                                                              
         UPDATE ped_itens SET qtd_pecas_atend = qtd_pecas_atend + p_nf_item.qtd_item,                   
                              qtd_pecas_romaneio = qtd_pecas_romaneio - p_nf_item.qtd_item              
          WHERE cod_empresa = p_cod_empresa                                                             
            AND num_pedido  = p_nf_item.pedido                                                          
            AND cod_item    = p_nf_item.item                                                            
            AND num_sequencia = p_nf_item.seq_item_pedido                                               
      END IF                                                                                            
   END IF                                                                                               

END FUNCTION

#-------------------------#
 FUNCTION esp0197_bonif()
#-------------------------#

 DECLARE c_bonif CURSOR FOR 
  SELECT * 
    FROM ordem_montag_item
   WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
     AND num_om     = p_nf_item.ord_montag    

 FOREACH c_bonif INTO p_ordem_montag_item.*

   if status <> 0 then
      call log003_err_sql('Lendo','ordem_montag_item')
      RETURN FALSE
   end if
      
    SELECT * 
      INTO p_nf_item.*
      FROM fat_nf_item
     WHERE empresa     = p_par_desc_oper.cod_emp_oper
       AND ord_montag  = p_ordem_montag_item.num_om
       AND pedido      = p_ordem_montag_item.num_pedido
       AND seq_item_pedido = p_ordem_montag_item.num_sequencia

    IF status = 0 THEN 
       CONTINUE FOREACH
    end if
    
    SELECT den_item,                                                          
           pes_unit,                                                             
           cod_unid_med,                                                         
           cod_cla_fisc,                                                         
           fat_conver                                                            
      INTO p_den_item,                                                           
           p_pes_unit,                                                           
           p_cod_unid_med,                                                       
           p_cod_cla_fisc,                                                       
           p_fat_conver                                                          
      FROM item                                                                  
     WHERE cod_empresa = p_cod_empresa                                           
       AND cod_item = p_ordem_montag_item.cod_item                               
                                                                              
      select max(seq_item_nf)                                                    
         into p_nf_item.seq_item_nf                                              
         from fat_nf_item                                                        
        where empresa = p_par_desc_oper.cod_emp_oper                             
          and trans_nota_fiscal = p_trans_nf_dest                                
                                                                                 
      if p_nf_item.seq_item_nf is null then                                      
         let p_nf_item.seq_item_nf = 1                                           
      else                                                                       
         let p_nf_item.seq_item_nf = p_nf_item.seq_item_nf + 1                       
      end if                                                                     
                                                                                 
      LET p_nf_item.empresa           = p_par_desc_oper.cod_emp_oper             
      LET p_nf_item.trans_nota_fiscal = p_trans_nf_dest                          
      LET p_nf_item.pedido  			     = p_ordem_montag_item.num_pedido                                 
	    LET p_nf_item.seq_item_pedido   = p_ordem_montag_item.num_sequencia                                      
      LET p_nf_item.ord_montag        = p_ordem_montag_item.num_om                                      
	    LET p_nf_item.item     				 = p_ordem_montag_item.cod_item               
      LET p_nf_item.tip_item          = 'N'                                      
      LET p_nf_item.tip_preco         = 'F'   
                                         
      SELECT cod_nat_oper_ref INTO p_cod_nat_oper
        FROM nat_oper_refer
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_nf_item.item 
         AND cod_nat_oper = p_nf_mestre.natureza_operacao
    
      if status <> 0 and status <> 100 then
         call log003_err_sql('Inserindo','nat_oper_refer')
         RETURN FALSE
      end if
    
      if status = 0 then
         LET p_nf_item.natureza_operacao = p_cod_nat_oper
      else
         LET p_nf_item.natureza_operacao = p_nf_mestre.natureza_operacao  
         let p_cod_nat_oper = p_nf_mestre.natureza_operacao
      end if
      
      LET p_nf_item.qtd_item          = p_ordem_montag_item.qtd_reservada        
      LET p_nf_item.unid_medida       = p_cod_unid_med                           
      LET p_nf_item.des_item          = p_den_item                               
      LET p_nf_item.peso_unit         = p_pes_unit                               
      LET p_nf_item.classif_fisc      = p_cod_cla_fisc                           
      LET p_nf_item.fator_conv        = p_fat_conver                             
      LET p_nf_item.val_desc_merc      = 0                                       
      LET p_nf_item.val_desc_contab    = 0                                       
      LET p_nf_item.val_desc_duplicata = 0                                       
      LET p_nf_item.val_acresc_item    = 0                                       
      LET p_nf_item.val_acre_merc      = 0                                       
      LET p_nf_item.val_acresc_contab  = 0                                       
      LET p_nf_item.val_acre_duplicata = 0                                       
      LET p_nf_item.val_fret_consig    = 0                                       
      LET p_nf_item.val_segr_consig    = 0                                       
      LET p_nf_item.val_frete_cliente  = 0                                       
      LET p_nf_item.val_seguro_cliente = 0                                       
      LET p_nf_item.val_liquido_item   = 0                                       
      LET p_nf_item.val_duplicata_item = 0                                       
      LET p_nf_item.preco_unit_liquido = 0                                       
      LET p_nf_item.preco_unit_bruto   = p_nf_item.preco_unit_liquido                               
      LET p_nf_item.pre_uni_desc_incnd = p_nf_item.preco_unit_liquido               
      LET p_nf_item.val_merc_item      = p_nf_item.val_liquido_item              
      LET p_nf_item.val_bruto_item     = p_nf_item.val_liquido_item              
      LET p_nf_item.val_brt_desc_incnd = p_nf_item.val_liquido_item              
                                                                                 
      INSERT INTO fat_nf_item values(p_nf_item.*)                                
                                                                              
      IF STATUS <> 0 THEN                                                        
         CALL log003_err_sql('INSERINDO','fat_nf_item')                          
         RETURN FALSE                                                            
      END IF             

    DELETE FROM tributo_tmp
    
    let p_cod_item = p_ordem_montag_item.cod_item   
    
    IF NOT esp0197_le_param_fisc() THEN 
       RETURN FALSE
    END IF
    
    if p_tem_tributo then
       if not esp0197_ins_tributos() then
          RETURN false
       end if
    end if       
                                                              
 END FOREACH

END FUNCTION


#------------------------------#
FUNCTION esp0197_le_param_fisc()
#------------------------------#

   DEFINE p_tip_item char(01)
   
   LET p_tem_tributo = FALSE
      
   SELECT parametro_ind
    INTO p_tip_item                  # P = Produto ; S = Serviço
    FROM vdp_parametro_item 
   WHERE empresa   = p_cod_empresa
     AND item      = p_cod_item
     AND parametro = 'tipo_item'
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','vdp_parametro_item')
      RETURN FALSE
   END IF

   SELECT COUNT(a.tributo_benef)
     INTO p_count
     FROM obf_oper_fiscal a, obf_tributo_benef b
    WHERE a.empresa           = p_cod_empresa
      AND a.origem            = 'S'
      AND a.nat_oper_grp_desp = p_cod_nat_oper
      AND a.tip_item          IN ('A',p_tip_item) 
      AND b.empresa           = a.empresa 
      AND b.tributo_benef     = a.tributo_benef 
      AND b.ativo             IN ('S','A') 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','tributos')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      RETURN true
   END IF

   DECLARE cq_tributos CURSOR FOR
    SELECT a.tributo_benef
      FROM obf_oper_fiscal a, obf_tributo_benef b
     WHERE a.empresa           = p_cod_empresa
       AND a.origem            = 'S'
       AND a.nat_oper_grp_desp = p_cod_nat_oper
       AND a.tip_item          IN ('A',p_tip_item) 
       AND b.empresa           = a.empresa 
       AND b.tributo_benef     = a.tributo_benef 
       AND b.ativo             IN ('S','A') 
     ORDER BY b.tip_config, b.prioridade   

   FOREACH  cq_tributos INTO
            p_tributo_benef

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_tributos')
         RETURN FALSE
      END IF
      
      insert into tributo_tmp values(p_tributo_benef)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','tributo_tmp')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#

