#--------------------------------------------------------------------#
# SISTEMA.: SOL - SISTEMA DE ORGANMIZACAO DE LOJA                    #
# PROGRAMA: SOL0220                                                  #
# OBJETIVO: INTEGRACAO DOS CUPONS FISCAIS COM O LIVRO FISCAL.        #
# AUTOR...: Ivo                                                      #
# DATA....: 17/12/2002  - Conversão para a versão 10.02              #
#--------------------------------------------------------------------#

 DATABASE logix

 GLOBALS
     DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
            p_user                 LIKE usuario.nom_usuario,
            p_dat_emissao          DATE,
            p_dat_cupom            DATE,
            p_tributa_ipi          CHAR(01),
            p_trans_config         INTEGER,
            p_trans_ipi            INTEGER,
            p_cod_fiscal           INTEGER,
            p_status               SMALLINT,
            p_val_base_trib        DECIMAL(17,2),
            p_val_item             DECIMAL(17,2),
            p_msg						       CHAR(300),
            p_ies_cons             SMALLINT,
            p_grava_tabs_velhas    char(01),
            p_tip_item             CHAR(01),
            l_nat_oper_emis_nf     LIKE sol_parametros.nat_oper_emis_nf,
            l_uni_feder            LIKE empresa.uni_feder,
            p_val_unit_ipi         LIKE ctr_ipi_unit.val_unit_ipi,
            p_val_ipi_item         DECIMAL(15,2),
            p_val_tot_ipi          DECIMAL(15,2),
            p_count                INTEGER,
            p_ies_tributo          SMALLINT,
            p_tributo_benef        CHAR(12),
            p_query                CHAR(600),
            p_regiao_fiscal        CHAR(10),
            p_cod_uni_feder        CHAR(02),
            p_grp_classif_fisc     CHAR(10),
            p_grp_fiscal_item      CHAR(10),
            p_grp_fisc_cliente     CHAR(10),
            p_micro_empresa        CHAR(01),
            p_dat_ini              DATE,
            p_dat_fim              DATE,
            p_dat_hor_emis         DATETIME YEAR TO SECOND
            
            

   DEFINE p_preco_s_trib       LIKE fat_nf_item.preco_unit_liquido,
		  	  p_preco_uni   	     LIKE fat_nf_item.preco_unit_liquido,
          p_val_tribruto       LIKE fat_nf_item_fisc.val_unit,
          p_val_ipi            LIKE fat_nf_item_fisc.val_trib_merc,
          p_val_icms           LIKE fat_nf_item_fisc.val_trib_merc,
          p_pct_red_bas_calc   LIKE fat_nf_item_fisc.pct_red_bas_calc,
          p_val_icm_it         LIKE fat_nf_item_fisc.val_trib_merc,
          p_tot_peso           LIKE fat_nf_mestre.peso_bruto,
          p_val_bruto          LIKE fat_nf_mestre.val_nota_fiscal,
          p_val_liqui          LIKE fat_nf_mestre.val_nota_fiscal,
		      p_val_acres          LIKE fat_nf_mestre.val_acre_nf,
          p_cod_nat_oper       LIKE fat_nf_mestre.natureza_operacao,
          p_cod_cnd_pgto       LIKE fat_nf_mestre.cond_pagto,
          p_cod_cidade         LIKE clientes.cod_cidade,
          p_ies_finalidade     LIKE pedidos.ies_finalidade,
          p_cod_tip_carteira   LIKE pedidos.cod_tip_carteira,
          p_cod_lin_prod       LIKE item.cod_lin_prod,
          p_cod_lin_recei      LIKE item.cod_lin_recei,
          p_cod_seg_merc       LIKE item.cod_seg_merc,
          p_cod_cla_uso        LIKE item.cod_cla_uso,
          p_cod_cla_fisc       LIKE item.cod_cla_fisc,
          p_cod_familia        LIKE item.cod_familia, 
          p_gru_ctr_estoq      LIKE item.gru_ctr_estoq,           
          p_cod_unid_med       LIKE item.cod_unid_med,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_ies_tipo           LIKE estoque_operac.ies_tipo,
          p_cod_item           LIKE item.cod_item,
          p_cod_incide         LIKE obf_config_fiscal.incide, 
          p_incide_icm         LIKE obf_config_fiscal.incide, 
          p_aliquota           LIKE obf_config_fiscal.aliquota,
		      p_aliquota_ipi       LIKE obf_config_fiscal.aliquota,
          p_tip_docum          LIKE vdp_num_docum.tip_docum,
          p_tip_solic          LIKE vdp_num_docum.tip_solicitacao,
          p_ser                LIKE vdp_num_docum.serie_docum,
          p_ssr                LIKE vdp_num_docum.subserie_docum,
          p_esp                LIKE vdp_num_docum.especie_docum,
          p_pes_unit           LIKE item.pes_unit,
          p_fat_conver         LIKE item.fat_conver,
          p_des_item           LIKE item.den_item,
          p_seq_acesso         LIKE obf_ctr_acesso.sequencia_acesso,
          p_trans_nf           INTEGER,
          p_chave              CHAR(11)


            
            

     DEFINE p_ies_impressao        CHAR(001),
            g_ies_ambiente         CHAR(001),
            p_nom_arquivo          CHAR(100),
            p_nom_arquivo_back     CHAR(100),
            p_scr_lin              SMALLINT,
            p_arr_cur              SMALLINT,
            p_arr_count            SMALLINT

     DEFINE g_ies_grafico          SMALLINT

     DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

 END GLOBALS

#MODULARES
     DEFINE m_den_empresa          LIKE empresa.den_empresa

     DEFINE m_consulta_ativa       SMALLINT

     DEFINE sql_stmt               CHAR(800),
            where_clause           CHAR(400)

     DEFINE m_comando              CHAR(080)

     DEFINE m_caminho              CHAR(150),
            m_last_row             SMALLINT

     DEFINE m_num_nff             LIKE nf_mestre.num_nff

     DEFINE mr_tela               RECORD
            dat_ini              DATE,
            dat_fim              DATE,
            ies_calcula          CHAR(01)
                                 END RECORD

     DEFINE m_serie_cupom        CHAR(02),
            m_serie_nota         CHAR(02)

     DEFINE l_sol_cupom_mestre   RECORD LIKE sol_cupom_mestre.*,
            l_nf_mestre_ser      RECORD LIKE nf_mestre_ser.*,
            l_sol_infor_fecham   RECORD LIKE sol_infor_fecham.*,
            l_dat_emis_cupom     DATE,
            l_texto              CHAR(80),
            l_num_gt             LIKE sol_infor_fecham.num_gt,
            l_data               DATE

   DEFINE 
          p_fat_mestre         RECORD LIKE fat_nf_mestre.*,
          p_fat_item           RECORD LIKE fat_nf_item.*,
          p_txt_hist           RECORD LIKE fat_nf_texto_hist.*,
          p_mest_fisc          RECORD LIKE fat_mestre_fiscal.*,
          p_nf_duplicata       RECORD LIKE fat_nf_duplicata.*,
          l_sol_cupom_itens    RECORD LIKE sol_cupom_itens.*

   DEFINE p_fat_item_fisc      RECORD

    empresa            char(2),
    trans_nota_fiscal  INTEGER,
    seq_item_nf        INTEGER,
    tributo_benef      char(20),
    trans_config       INTEGER,
    bc_trib_mercadoria decimal(17,2),
    bc_tributo_frete   decimal(17,2),
    bc_trib_calculado  decimal(17,2),
    bc_tributo_tot     decimal(17,2),
    val_trib_merc      decimal(17,2),
    val_tributo_frete  decimal(17,2),
    val_trib_calculado decimal(17,2),
    val_tributo_tot    decimal(17,2),
    acresc_desc        char(1),
    aplicacao_val      char(1), 
    incide             char(1),
    origem_produto     smallint, 
    tributacao         smallint, 
    hist_fiscal        integer, 
    sit_tributo        char(1), 
    motivo_retencao    char(1), 
    retencao_cre_vdp   char(3), 
    cod_fiscal         integer, 
    inscricao_estadual char(16), 
    dipam_b            char(3), 
    aliquota           decimal(7,4), 
    val_unit           decimal(17,6), 
    pre_uni_mercadoria decimal(17,6), 
    pct_aplicacao_base decimal(7,4), 
    pct_acre_bas_calc  decimal(7,4), 
    pct_red_bas_calc   decimal(7,4), 
    pct_diferido_base  decimal(7,4), 
    pct_diferido_val   decimal(7,4), 
    pct_acresc_val     decimal(7,4), 
    pct_reducao_val    decimal(7,4), 
    pct_margem_lucro   decimal(7,4), 
    pct_acre_marg_lucr decimal(7,4), 
    pct_red_marg_lucro decimal(7,4), 
    taxa_reducao_pct   decimal(7,4), 
    taxa_acresc_pct    decimal(7,4), 
    cotacao_moeda_upf  decimal(7,2), 
    simples_nacional   decimal(5,0),
    iden_processo      integer
 END RECORD
   

#END MODULARES

 MAIN
     LET p_versao = 'SOL0220-10.02.24' 

     WHENEVER ANY ERROR CONTINUE

     CALL log1400_isolation()
     SET LOCK MODE TO WAIT 120

     DEFER INTERRUPT

     LET m_caminho = log140_procura_caminho('sol0220.iem')

     OPTIONS
         PREVIOUS KEY control-b,
         NEXT     KEY control-f,
         HELP    FILE m_caminho

     CALL log001_acessa_usuario('SOL','LOGERP')
          RETURNING p_status, p_cod_empresa, p_user

     IF  p_status = 0 THEN
         CALL sol0220_controle()
     END IF
     
 END MAIN

#---------------------------#
 FUNCTION sol0220_controle()
#---------------------------#
     CALL log006_exibe_teclas('01', p_versao)

     CALL sol0220_inicia_variaveis()

     LET m_caminho = log1300_procura_caminho('sol0220','')

     OPEN WINDOW w_sol0220 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

     MENU 'OPCAO'
         COMMAND 'Informar'   'Informa dados para integracao da NFF'
             HELP 001
             MESSAGE ''
             IF  log005_seguranca(p_user, 'SOL', 'SOL0220', 'IN') THEN
                 CALL sol0220_inicia_variaveis()
                 IF sol0220_entrada_dados() = TRUE THEN
                    LET p_ies_cons = TRUE
                    NEXT OPTION 'Processar'
                 ELSE
                    LET p_ies_cons = FALSE
                 END IF
             END IF

         COMMAND 'Processar'   'Processa emissao da NFF'
             HELP 001
             MESSAGE ''
             IF p_ies_cons THEN
                IF log004_confirm(6,10) THEN
                   CALL sol0220_processa_dados()
                ELSE
                   ERROR 'Operação cancelada!'
                END IF
             ELSE
                ERROR 'Informe os parâmtros previamente!'
                NEXT OPTION 'Informar'
             END IF
         
         COMMAND "Sobre" "Exibe a versão do programa"
             CALL sol0220_sobre() 		


         COMMAND KEY ("!")
             PROMPT "Digite o comando : " FOR m_comando
             RUN m_comando
             PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

         COMMAND 'Fim'       'Retorna ao menu anterior.'
             HELP 008
             EXIT MENU
     END MENU

     CLOSE WINDOW w_sol0220
 END FUNCTION

#-----------------------#
FUNCTION sol0220_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-----------------------------------#
 FUNCTION sol0220_inicia_variaveis()
#-----------------------------------#
     LET m_consulta_ativa           = FALSE
     INITIALIZE mr_tela.*                 TO NULL

 END FUNCTION


#-----------------------------------#
 FUNCTION sol0220_entrada_dados()
#-----------------------------------#
   CLEAR FORM
   CALL log006_exibe_teclas('01', p_versao)
   CURRENT WINDOW IS w_sol0220

   DISPLAY p_cod_empresa TO cod_empresa
   LET mr_tela.dat_ini = MDY(MONTH(TODAY),"01",YEAR(TODAY))
   DISPLAY BY NAME mr_tela.dat_ini
   LET mr_tela.ies_calcula = "S"
   DISPLAY BY NAME mr_tela.ies_calcula

   INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

          AFTER FIELD dat_ini
             IF  mr_tela.dat_ini IS NULL THEN
                 ERROR "Data de inicio de processamento invalida."
                 NEXT FIELD dat_inicio
             END IF
             LET mr_tela.dat_fim = MDY(MONTH(mr_tela.dat_ini),"01",YEAR(mr_tela.dat_ini))
             LET mr_tela.dat_fim = mr_tela.dat_fim + 1 UNITS MONTH
             LET mr_tela.dat_fim = mr_tela.dat_fim - 1 UNITS DAY
             DISPLAY BY NAME mr_tela.dat_fim

          AFTER FIELD dat_fim
             IF  mr_tela.dat_fim IS NULL THEN
                 ERROR "Data fim de processamento invalida."
                 NEXT FIELD dat_fim
             END IF
             IF  mr_tela.dat_ini > mr_tela.dat_fim THEN
                 ERROR "Data inicio nao pode ser maior que a fim."
                 NEXT FIELD dat_ini
             END IF
             IF  MONTH(mr_tela.dat_ini) <> MONTH(mr_tela.dat_fim) OR
                 YEAR(mr_tela.dat_ini) <> YEAR(mr_tela.dat_fim) THEN
                 ERROR "Periodo invalido deve ficar dentro do mesmo mes."
                 NEXT FIELD dat_ini
             END IF

   AFTER INPUT
        IF INT_FLAG = 0 THEN
             IF  mr_tela.dat_ini IS NULL THEN
                 ERROR "Data de inicio de processamento invalida."
                 NEXT FIELD dat_inicio
             END IF
             IF  mr_tela.dat_fim IS NULL THEN
                 ERROR "Data fim de processamento invalida."
                 NEXT FIELD dat_fim
             END IF
             IF  mr_tela.dat_ini > mr_tela.dat_fim THEN
                 ERROR "Data inicio nao pode ser maior que a fim."
                 NEXT FIELD dat_inicio
             END IF
             IF  MONTH(mr_tela.dat_ini) <> MONTH(mr_tela.dat_fim) OR
                 YEAR(mr_tela.dat_ini) <> YEAR(mr_tela.dat_fim) THEN
                 ERROR "Periodo invalido deve ficar dentro do mesmo mes."
                 NEXT FIELD dat_inicio
             END IF

        END IF

   END INPUT

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0
      ERROR " Entrada Dados Cancelada."
      RETURN FALSE
   END IF

   RETURN TRUE

 END FUNCTION

#-----------------------------------#
FUNCTION sol0220_delete_tabs_velhas()
#-----------------------------------#

 DECLARE cq_item CURSOR FOR
 SELECT * FROM nf_mestre_ser
  WHERE cod_empresa  = p_cod_empresa
    AND dat_emissao >= mr_tela.dat_ini
    AND dat_emissao <= mr_tela.dat_fim
#   AND ies_situacao = 'N'
    AND ser_nff     <> 'D'
    AND ies_especie  = 'CF'

 FOREACH cq_item INTO l_nf_mestre_ser.*
   
   DELETE FROM nf_item_ser
    WHERE cod_empresa = p_cod_empresa
     AND num_nff     = l_nf_mestre_ser.num_nff
     AND ser_nff     = l_nf_mestre_ser.ser_nff

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","NF_ITEM_SER")
     ROLLBACK WORK
     RETURN FALSE
  END IF

  DELETE FROM nf_item_fiscal_ser
   WHERE cod_empresa = p_cod_empresa
     AND num_nff     = l_nf_mestre_ser.num_nff
     AND ser_nff     = l_nf_mestre_ser.ser_nff

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","NF_ITEM_FISCAL_SER")
     ROLLBACK WORK
     RETURN
  END IF

  DELETE FROM nf_obs_livro
   WHERE cod_empresa = p_cod_empresa
     AND num_nff     = l_nf_mestre_ser.num_nff
     AND ser_nff     = l_nf_mestre_ser.ser_nff

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","NF_ITEM_SER")
     ROLLBACK WORK
     RETURN
  END IF

  DELETE FROM fat_nf_compl
   WHERE empresa           = p_cod_empresa
     AND nota_fiscal       = l_nf_mestre_ser.num_nff
     AND serie_nota_fiscal = l_nf_mestre_ser.ser_nff

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","FAT_NF_COMPL")
     ROLLBACK WORK
     RETURN
  END IF

  # Testa nf cancelada se integrada ao CRE

  SELECT * FROM nf_movto_dupl_ser
   WHERE cod_empresa  = l_nf_mestre_ser.cod_empresa
     AND num_nff      = l_nf_mestre_ser.num_nff
     AND ser_nff      = l_nf_mestre_ser.ser_nff
     AND ies_operacao = 'I'
     AND num_lote IS NOT NULL
     AND l_nf_mestre_ser.ies_situacao <> "N" #<> N significa integrada
 
  IF STATUS = 0 THEN
  	ERROR "Cupom cancelado integrado ao CRE: ",l_nf_mestre_ser.num_nff
    ROLLBACK WORK
    RETURN
  END IF

  SELECT * FROM nf_movto_dupl_ser
   WHERE cod_empresa  = l_nf_mestre_ser.cod_empresa
     AND num_nff      = l_nf_mestre_ser.num_nff
     AND ser_nff      = l_nf_mestre_ser.ser_nff
     AND ies_operacao = 'I'
     AND num_lote IS NULL

  IF STATUS = 0 THEN
     DELETE FROM nf_duplicata_ser
      WHERE cod_empresa = p_cod_empresa
        AND num_nff     = l_nf_mestre_ser.num_nff
        AND ser_nff     = l_nf_mestre_ser.ser_nff

     IF STATUS <> 0 THEN
        CALL log003_err_sql("DELETE","NF_DUPLICATA_SER")
        ROLLBACK WORK
        RETURN
     END IF

     DELETE FROM nf_movto_dupl_ser
      WHERE cod_empresa = p_cod_empresa
        AND num_nff     = l_nf_mestre_ser.num_nff
        AND ser_nff     = l_nf_mestre_ser.ser_nff

     IF STATUS <> 0 THEN
        CALL log003_err_sql("DELETE","NF_MOVTO_DUPL_SER")
        ROLLBACK WORK
        RETURN
     END IF
  END IF

END FOREACH

DELETE FROM nf_mestre_ser
 WHERE cod_empresa  = p_cod_empresa
   AND dat_emissao >= mr_tela.dat_ini
   AND dat_emissao <= mr_tela.dat_fim
#   AND ies_situacao = 'N'
   AND ser_nff     <> 'D'
   AND ies_especie  = 'CF'

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","NF_MESTRE_SER")
     ROLLBACK WORK
     RETURN
  END IF

END FUNCTION


#-----------------------------------#
FUNCTION sol0220_delete_tabs_novas()
#-----------------------------------#
 
 DEFINE p_cod_status CHAR(01),
        p_dat_emis   DATE
        
 LET p_dat_ini = mr_tela.dat_ini
 LET p_dat_fim = mr_tela.dat_fim
 
 DECLARE cq_del CURSOR FOR
 SELECT trans_nota_fiscal
   FROM fat_nf_mestre
  WHERE empresa = p_cod_empresa
    AND serie_nota_fiscal <> 'D'
    AND espc_nota_fiscal = 'CF'
    AND DATE(dat_hor_emissao) >= p_dat_ini
    AND DATE(dat_hor_emissao) <= p_dat_fim

 FOREACH cq_del INTO p_trans_nf
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'fat_nf_mestre:cq_del')
      RETURN FALSE
   END IF
     
   SELECT status_intg_creceb
     INTO p_cod_status
     FROM fat_nf_integr
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_trans_nf

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'fat_nf_integr:cq_del')
      RETURN FALSE
   END IF
   
   IF p_cod_status <> 'P' THEN
      LET p_msg = 'Notas do período informado já integradas com o CRE!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
    
   DELETE FROM fat_nf_mestre
    WHERE empresa = p_cod_empresa
     AND trans_nota_fiscal = p_trans_nf

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","fat_nf_mestre")
     RETURN FALSE
  END IF

   DELETE FROM fat_nf_item
    WHERE empresa = p_cod_empresa
     AND trans_nota_fiscal = p_trans_nf

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","fat_nf_item")
     RETURN FALSE
  END IF

   DELETE FROM fat_nf_item_fisc
    WHERE empresa = p_cod_empresa
     AND trans_nota_fiscal = p_trans_nf

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","fat_nf_item_fisc")
     RETURN FALSE
  END IF

   DELETE FROM fat_mestre_fiscal
    WHERE empresa = p_cod_empresa
     AND trans_nota_fiscal = p_trans_nf

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","fat_mestre_fiscal")
     RETURN FALSE
  END IF

  DELETE FROM fat_nf_duplicata
   WHERE empresa = p_cod_empresa
    AND trans_nota_fiscal = p_trans_nf

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","fat_mestre_fiscal")
     RETURN FALSE
  END IF

  DELETE FROM fat_nf_integr
   WHERE empresa = p_cod_empresa
    AND trans_nota_fiscal = p_trans_nf

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","fat_nf_integr")
     RETURN FALSE
  END IF

  DELETE FROM fat_nf_obs_livro
   WHERE empresa = p_cod_empresa
     AND trans_nota_fiscal = p_trans_nf

  IF STATUS <> 0 THEN
     CALL log003_err_sql("DELETE","fat_nf_obs_livro")
     ROLLBACK WORK
     RETURN
  END IF

 END FOREACH

END FUNCTION

#-----------------------------------#
FUNCTION sol0220_processa_dados()
#-----------------------------------#

   DEFINE l_ind              SMALLINT ,
       l_cod_ponto_venda     LIKE sol_ponto_venda.cod_ponto_venda

   SELECT uni_feder INTO p_cod_uni_feder
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   MESSAGE " Aguarde, limpando dados do livro para carga."

   #Modificar esquema de deleção e gravação das tabelas velhas,
   #encadeando esse processo com a deleção e gravação das
   #tabelas novas
   
   SELECT val_parametro 
     INTO p_grava_tabs_velhas
     FROM log_val_parametro 
    WHERE empresa   = p_cod_empresa
      AND parametro = 'replicar_nf_fat_antigo'
   
   if status <> 0 then
      let p_grava_tabs_velhas = 'N'
   end if

   BEGIN WORK

 IF NOT sol0220_cria_temporaria() THEN
    ROLLBACK WORK
    RETURN
 END IF

 IF p_grava_tabs_velhas = 'S' THEN
    IF NOT sol0220_delete_tabs_velhas() THEN
       ROLLBACK WORK
       RETURN
    END IF
 END IF

 IF NOT sol0220_delete_tabs_novas() THEN
    ROLLBACK WORK
    RETURN
 END IF
       
 MESSAGE " Aguarde, processando a exportacao do cupom para o livro. "

 IF NOT sol0220_carrega_cupons_livro() THEN # carrega a tabela tmp w_obs_livro com os
    ROLLBACK WORK                           #campos num. cupom, ponto de venda, emissão,
    RETURN                                  #num. cupom fim e um texto com num. gt
 END IF                                     #com dados extraídos de sol_cupom_mestre e
                                            #sol_infor_fecham

 DECLARE cq_cupom CURSOR FOR
 SELECT * FROM sol_cupom_mestre
  WHERE cod_empresa = p_cod_empresa
    AND dat_emis_cupom >= mr_tela.dat_ini
    AND dat_emis_cupom <= mr_tela.dat_fim
    AND ies_situacao = "N"

 FOREACH cq_cupom INTO l_sol_cupom_mestre.*

   MESSAGE ' Processando cupom ',
           l_sol_cupom_mestre.num_cupom USING '<<<<<<',' ',
           l_sol_cupom_mestre.cod_ponto_venda,' ...'

   LET m_num_nff = l_sol_cupom_mestre.num_cupom

   IF l_sol_cupom_mestre.cod_cliente IS NOT NULL THEN
      LET p_cod_cliente = l_sol_cupom_mestre.cod_cliente
   ELSE
      SELECT cod_cliente 
        INTO p_cod_cliente 
        FROM sol_parametros
       WHERE cod_empresa = p_cod_empresa
   END IF

   IF l_sol_cupom_mestre.cod_cnd_pgto IS NOT NULL AND
      l_sol_cupom_mestre.cod_cnd_pgto  <> ' ' THEN
      LET p_cod_cnd_pgto = l_sol_cupom_mestre.cod_cnd_pgto
   ELSE
      SELECT cod_cnd_pgto_cupom 
        INTO p_cod_cnd_pgto
        FROM sol_parametros
       WHERE cod_empresa = p_cod_empresa
   END IF
   
   DELETE from icms_temp_7662
   
   LET p_cod_fiscal  = 0
   LET p_val_tot_ipi = 0
   LET p_dat_cupom = l_sol_cupom_mestre.dat_emis_cupom
   
   IF NOT sol0220_grava_tabs_novas() THEN
      ROLLBACK WORK
      RETURN
   END IF

   IF p_grava_tabs_velhas = 'S' THEN
      IF sol0220_grava_nf_mestre_ser() = FALSE THEN
         ROLLBACK WORK
         RETURN
      END IF
      IF sol0220_grava_nf_item_ser() = FALSE THEN
         ROLLBACK WORK
         RETURN
      END IF
   END IF

 END FOREACH

 ERROR "Atualizando informações de fechamento diário."

 IF sol0220_grava_informacoes_livro() = FALSE THEN
     RETURN
 END IF

 MESSAGE ' Gravando nf_obs_livro ...'

 IF NOT sol0220_grava_nf_obs_livro() THEN
    ROLLBACK WORK
    RETURN
 END IF

 COMMIT WORK
 MESSAGE ""
 
 ERROR " Fim do processamento. "

END FUNCTION

#-------------------------------------#
FUNCTION sol0220_grava_nf_mestre_ser()
#-------------------------------------#


   DEFINE l_fiscal_par             RECORD LIKE fiscal_par.*,
       l_num_cgc_cpf               LIKE clientes.num_cgc_cpf

   INITIALIZE l_nf_mestre_ser TO NULL
   

SELECT nat_oper_emis_nf 
  INTO l_nat_oper_emis_nf
  FROM sol_parametros
 WHERE cod_empresa  = p_cod_empresa


SELECT uni_feder INTO l_uni_feder
  FROM empresa
 WHERE cod_empresa = p_cod_empresa

LET l_nf_mestre_ser.cod_empresa          = l_sol_cupom_mestre.cod_empresa
LET l_nf_mestre_ser.num_nff              = m_num_nff
LET l_nf_mestre_ser.dat_emissao          = l_sol_cupom_mestre.dat_emis_cupom
LET l_nf_mestre_ser.ies_situacao         = l_sol_cupom_mestre.ies_situacao
LET l_nf_mestre_ser.ser_nff              = l_sol_cupom_mestre.cod_ponto_venda

CALL sol0220_controla_serie(l_nf_mestre_ser.num_nff, l_nf_mestre_ser.ser_nff)
    RETURNING l_nf_mestre_ser.ser_nff

LET l_nf_mestre_ser.ies_origem           = "I"
IF l_sol_cupom_mestre.cod_cliente IS NOT NULL THEN
   LET l_nf_mestre_ser.cod_cliente       = l_sol_cupom_mestre.cod_cliente
ELSE
   SELECT cod_cliente INTO l_nf_mestre_ser.cod_cliente
     FROM sol_parametros
    WHERE cod_empresa = p_cod_empresa
END IF

LET l_nf_mestre_ser.ies_zona_franca      = "N"
LET l_nf_mestre_ser.cod_transpor         = NULL
LET l_nf_mestre_ser.cod_consig           = NULL
LET l_nf_mestre_ser.pct_frete            = 0
LET l_nf_mestre_ser.ies_frete            = "1"

IF l_sol_cupom_mestre.cod_cnd_pgto IS NOT NULL AND
   l_sol_cupom_mestre.cod_cnd_pgto  <> '' THEN
   LET l_nf_mestre_ser.cod_cnd_pgto         = l_sol_cupom_mestre.cod_cnd_pgto
ELSE
   SELECT cod_cnd_pgto_cupom INTO l_nf_mestre_ser.cod_cnd_pgto
     FROM sol_parametros
    WHERE cod_empresa = p_cod_empresa
END IF

LET l_nf_mestre_ser.pct_icm              = 0
LET l_nf_mestre_ser.pct_desc_base_icm    = 0
LET l_nf_mestre_ser.pct_comis            = 0

SELECT num_cgc_cpf INTO l_num_cgc_cpf
  FROM clientes
 WHERE cod_cliente = l_sol_cupom_mestre.cod_cliente

LET l_nf_mestre_ser.ies_finalidade = "2"

SELECT * INTO l_fiscal_par.*
  FROM fiscal_par
 WHERE cod_empresa  = p_cod_empresa
   AND cod_nat_oper = l_sol_cupom_mestre.cod_nat_oper
   AND cod_uni_feder = l_uni_feder

IF STATUS <> 0 THEN
   ERROR " Nao existe parametros fiscais para a venda "
   RETURN FALSE
END IF

LET l_nf_mestre_ser.ies_incid_ipi        = l_fiscal_par.ies_incid_ipi
LET l_nf_mestre_ser.ies_incid_icm        = l_fiscal_par.ies_incid_icm
LET l_nf_mestre_ser.pct_icm              = 0
LET l_nf_mestre_ser.pct_desc_base_icm    = 0

LET l_nf_mestre_ser.pct_desp_dist        = 0
LET l_nf_mestre_ser.pct_desp_finan       = 0
LET l_nf_mestre_ser.pes_tot_liquido      = 1
LET l_nf_mestre_ser.pes_tot_bruto        = 1
LET l_nf_mestre_ser.cod_nat_oper         = l_sol_cupom_mestre.cod_nat_oper
LET l_nf_mestre_ser.cod_fiscal           = l_fiscal_par.cod_fiscal
LET l_nf_mestre_ser.cod_origem           = l_fiscal_par.cod_origem
LET l_nf_mestre_ser.cod_tributacao       = l_fiscal_par.cod_tributacao
LET l_nf_mestre_ser.pct_desc_base_ipi    = l_fiscal_par.pct_desc_base_ipi
LET l_nf_mestre_ser.pct_cred_icm         = l_fiscal_par.pct_cred_icm
LET l_nf_mestre_ser.tax_red_pct_icm      = l_fiscal_par.tax_red_pct_icm
LET l_nf_mestre_ser.pct_desc_ipi         = l_fiscal_par.pct_desc_ipi
LET l_nf_mestre_ser.val_desc_merc        = 0
LET l_nf_mestre_ser.cod_repres           = NULL

SELECT cod_repres INTO l_nf_mestre_ser.cod_repres
  FROM sol_de_para_repres
 WHERE cod_usuario = l_sol_cupom_mestre.vendedor
 
LET l_nf_mestre_ser.cod_repres_adic      = NULL
LET l_nf_mestre_ser.num_lote_lc          = 0 
LET l_nf_mestre_ser.cod_sit_trib         = 0
LET l_nf_mestre_ser.cod_trib_estadual    = 0
LET l_nf_mestre_ser.cod_trib_federal     = 0
LET l_nf_mestre_ser.val_desc_cred_icm    = 0
LET l_nf_mestre_ser.val_frete_rod        = 0
LET l_nf_mestre_ser.val_seguro_rod       = 0

IF mr_tela.ies_calcula = 'S' THEN
   LET l_nf_mestre_ser.val_tot_base_ipi     = l_sol_cupom_mestre.val_tot_venda
ELSE
   LET l_nf_mestre_ser.val_tot_base_ipi     = 0
END IF

LET l_nf_mestre_ser.val_tot_ipi          = 0
LET l_nf_mestre_ser.val_tot_base_icm     = l_sol_cupom_mestre.val_tot_venda
LET l_nf_mestre_ser.val_tot_icm          = 0
LET l_nf_mestre_ser.val_tot_mercadoria   = l_sol_cupom_mestre.val_tot_venda ### devera ser pega do cupom
LET l_nf_mestre_ser.val_tot_nff          = l_sol_cupom_mestre.val_tot_venda ### devera ser pega do cupom
LET l_nf_mestre_ser.val_tot_base_ret     = 0
LET l_nf_mestre_ser.val_tot_icm_ret      = 0
LET l_nf_mestre_ser.ies_mod_embarque     = 1
LET l_nf_mestre_ser.cod_moeda            = 01
LET l_nf_mestre_ser.pct_bonificacao      = 0
LET l_nf_mestre_ser.cod_local_embarque   = NULL
LET l_nf_mestre_ser.cod_entrega          = 3
LET l_nf_mestre_ser.val_tot_bonif        = 0
LET l_nf_mestre_ser.val_frete_cli        = 0
LET l_nf_mestre_ser.val_seguro_cli       = 0
LET l_nf_mestre_ser.val_frete_ex         = 0
LET l_nf_mestre_ser.val_seguro_ex        = 0
LET l_nf_mestre_ser.cod_tip_carteira     = '01'
LET l_nf_mestre_ser.ies_plano_vendas     = 'N'
LET l_nf_mestre_ser.ies_especie          = 'CF '

INSERT INTO nf_mestre_ser VALUES (l_nf_mestre_ser.*)
IF STATUS <> 0 AND STATUS <> -239 THEN
    CALL log003_err_sql("INSERCAO","NF_MESTRE_SER")
    RETURN FALSE
END IF

IF sol0220_gera_duplicata(l_nf_mestre_ser.*) = FALSE THEN
   ROLLBACK WORK
   RETURN FALSE
END IF

IF NOT sol0220_grava_fat_nf_compl() THEN
   RETURN FALSE
END IF

RETURN TRUE

END FUNCTION

#--------------------------------------------------#
 FUNCTION sol0220_gera_duplicata(l_nf_mestre_ser)
#--------------------------------------------------#

 DEFINE l_nf_mestre_ser       RECORD LIKE nf_mestre_ser.*,
        l_nf_movto_dupl_ser   RECORD LIKE nf_movto_dupl_ser.*,
        l_cond_pgto_item      RECORD LIKE cond_pgto_item.*,
        l_nf_duplicata_ser    RECORD LIKE nf_duplicata_ser.*,
        l_pct_desp_finan      LIKE cond_pgto.pct_desp_finan,
        l_val_duplic          DECIMAL(17,2)

 DEFINE l_dupl_nat_oper       CHAR(01),
        l_dupl_cond_pgto      CHAR(01)

 LET l_dupl_nat_oper  = 'N'
 LET l_dupl_cond_pgto = 'N'

 
 SELECT nat_operacao.ies_emite_dupl
   INTO l_dupl_nat_oper
   FROM nat_operacao
  WHERE nat_operacao.cod_nat_oper = l_nf_mestre_ser.cod_nat_oper
 

 IF STATUS = NOTFOUND THEN
    LET l_dupl_nat_oper = 'N'
 END IF

 IF l_dupl_nat_oper = 'S' THEN
    {gera duplicata}
 ELSE
    RETURN TRUE
 END IF

 
 SELECT cond_pgto.ies_emite_dupl
   INTO l_dupl_cond_pgto
   FROM cond_pgto
  WHERE cond_pgto.cod_cnd_pgto = l_nf_mestre_ser.cod_cnd_pgto
 

 IF STATUS = NOTFOUND THEN
    LET l_dupl_cond_pgto = 'N'
 END IF

 IF l_dupl_cond_pgto = 'S' THEN
    {gera duplicata}
 ELSE
    RETURN TRUE
 END IF

 SELECT cod_empresa
   FROM nf_movto_dupl_ser
  WHERE cod_empresa  = l_nf_mestre_ser.cod_empresa
    AND num_nff      = l_nf_mestre_ser.num_nff
    AND ser_nff      = l_nf_mestre_ser.ser_nff
    AND ies_operacao = 'I'

 IF STATUS <> 0 THEN

    LET l_nf_movto_dupl_ser.cod_empresa    = l_nf_mestre_ser.cod_empresa
    LET l_nf_movto_dupl_ser.num_nff        = l_nf_mestre_ser.num_nff
    LET l_nf_movto_dupl_ser.ser_nff        = l_nf_mestre_ser.ser_nff
    LET l_nf_movto_dupl_ser.dat_operacao   = l_nf_mestre_ser.dat_emissao
    LET l_nf_movto_dupl_ser.ies_operacao   = 'I'
    LET l_nf_movto_dupl_ser.num_lote       = NULL

    INSERT INTO nf_movto_dupl_ser VALUES (l_nf_movto_dupl_ser.*)

    IF STATUS <> 0 THEN
       CALL log003_err_sql("INSERCAO","NF_MOVTO_DUPL_SER")
       RETURN FALSE
    END IF

    SELECT pct_desp_finan INTO l_pct_desp_finan
      FROM cond_pgto
     WHERE cod_cnd_pgto = l_nf_mestre_ser.cod_cnd_pgto

    DECLARE cq_cnd CURSOR FOR
     SELECT * FROM cond_pgto_item
      WHERE cod_cnd_pgto = l_nf_mestre_ser.cod_cnd_pgto

    FOREACH cq_cnd INTO l_cond_pgto_item.*

       LET l_nf_duplicata_ser.cod_empresa    = l_nf_mestre_ser.cod_empresa
       LET l_nf_duplicata_ser.num_nff        = l_nf_mestre_ser.num_nff
       LET l_nf_duplicata_ser.ser_nff        = l_nf_mestre_ser.ser_nff
       LET l_nf_duplicata_ser.num_duplicata  = l_nf_mestre_ser.num_nff
       LET l_nf_duplicata_ser.dig_duplicata  = l_cond_pgto_item.sequencia
       LET l_nf_duplicata_ser.pct_desc_financ = 0 #l_pct_desp_finan
       LET l_val_duplic = (l_nf_mestre_ser.val_tot_nff * l_cond_pgto_item.pct_valor_liquido) / 100
       LET l_nf_duplicata_ser.val_duplic     = l_val_duplic
       LET l_nf_duplicata_ser.dat_vencto_sd  = NULL
       LET l_nf_duplicata_ser.dat_vencto_cd  = NULL

       LET l_nf_duplicata_ser.dat_vencto_sd   = (l_nf_mestre_ser.dat_emissao + l_cond_pgto_item.qtd_dias_sd UNITS DAY)
       LET l_nf_duplicata_ser.cod_moeda      = l_nf_mestre_ser.cod_moeda

       INSERT INTO nf_duplicata_ser  VALUES (l_nf_duplicata_ser.*)

       IF STATUS <> 0 THEN
          CALL log003_err_sql("INSERCAO","NF_DUPLICATA_SER")
          RETURN FALSE
       END IF
    END FOREACH
 END IF

 RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION sol0220_grava_nf_item_ser()
#-----------------------------------#

DEFINE l_nf_item_ser           RECORD LIKE nf_item_ser.*,
       l_nf_item_fiscal_ser    RECORD LIKE nf_item_fiscal_ser.*,
       l_fiscal_par            RECORD LIKE fiscal_par.*,
       l_nat_operacao          RECORD LIKE nat_operacao.*,
       l_pct_icm               DECIMAL(5,2),
       l_ies_incid_icm         LIKE fiscal_par.ies_incid_icm,
       l_pct_icm_consumo       LIKE fiscal_par.pct_icm_consumo,
       l_tax_red_pct_icm       LIKE fiscal_par.tax_red_pct_icm,
       l_cod_nat_oper_ref      LIKE nat_oper_refer.cod_nat_oper_ref,
       l_val_unit_ipi          LIKE ctr_ipi_unit.val_unit_ipi,
       l_val_base_icm          DECIMAL(17,2),
       l_val_icm               DECIMAL(17,2),
       l_val_ipi               DECIMAL(17,2),
       l_ind                   SMALLINT,
       l_val_item              DECIMAL(17,2),
       l_val_tot_mercadoria    DECIMAL(17,2)


 LET l_nf_item_ser.cod_empresa = p_cod_empresa
 LET l_nf_item_ser.num_nff     = m_num_nff

 LET l_val_ipi            = 0
 LET l_val_tot_mercadoria = 0
 LET l_val_base_icm       = 0
 LET l_val_icm            = 0

 LET l_ind = 0

DECLARE cq_cup_item CURSOR FOR
SELECT * FROM sol_cupom_itens
  WHERE cod_empresa      = l_sol_cupom_mestre.cod_empresa
    AND cod_ponto_venda  = l_sol_cupom_mestre.cod_ponto_venda
    AND num_cupom        = l_sol_cupom_mestre.num_cupom
    AND dat_emis_cupom   = l_sol_cupom_mestre.dat_emis_cupom
    AND ies_situacao = 'N'
ORDER BY  num_sequencia

FOREACH cq_cup_item INTO l_sol_cupom_itens.*
   LET l_ind                          = l_ind + 1

   IF l_sol_cupom_itens.pct_desc_item IS NULL THEN
      LET l_sol_cupom_itens.pct_desc_item = 0
   END IF

   LET l_nf_item_ser.ser_nff          = m_serie_nota
   LET l_nf_item_ser.num_pedido       = l_sol_cupom_itens.num_cupom
   LET l_nf_item_ser.num_sequencia    = l_ind
   LET l_nf_item_ser.cod_item         = l_sol_cupom_itens.cod_item
   LET l_nf_item_ser.ies_desp_dist    = "N"
   LET l_nf_item_ser.pes_unit         = NULL
   LET l_nf_item_ser.qtd_item         = l_sol_cupom_itens.qtd_pecas_atend
   LET l_nf_item_ser.pct_desc_adic_mest = 0
   LET l_nf_item_ser.pct_desc_adic      = l_sol_cupom_itens.pct_desc_item
   LET l_nf_item_ser.val_desc_adicional = 0 #### devera verif. se colocara igual ao cupom
   LET l_nf_item_ser.cod_cla_fisc       = NULL
   LET l_nf_item_ser.pct_ipi            = 0

   LET l_nf_item_ser.cod_unid_med     = NULL
   LET l_nf_item_ser.fat_conver       = 1
   LET l_nf_item_ser.num_om           = 0

   LET l_nf_item_ser.pre_unit_nf      = l_sol_cupom_itens.pre_unit_venda -
                                       (l_sol_cupom_itens.pre_unit_venda *
                                       (l_nf_item_ser.pct_desc_adic / 100))

   LET l_nf_item_ser.pre_unit_ped     = l_sol_cupom_itens.pre_unit_venda

   LET l_nf_item_ser.val_liq_item     = l_nf_item_ser.qtd_item *
                                        l_nf_item_ser.pre_unit_nf

   LET l_val_tot_mercadoria = l_val_tot_mercadoria +
                              l_nf_item_ser.val_liq_item

   SELECT cod_unid_med,pes_unit,cod_cla_fisc,pct_ipi,fat_conver
     INTO l_nf_item_ser.cod_unid_med,l_nf_item_ser.pes_unit,
          l_nf_item_ser.cod_cla_fisc,l_nf_item_ser.pct_ipi,
          l_nf_item_ser.fat_conver
     FROM item
    WHERE cod_empresa  = l_sol_cupom_mestre.cod_empresa
      AND cod_item     = l_sol_cupom_itens.cod_item

   IF mr_tela.ies_calcula = 'S' THEN
      SELECT val_unit_ipi  INTO l_val_unit_ipi
        FROM ctr_ipi_unit
       WHERE cod_empresa =p_cod_empresa
         AND cod_item = l_sol_cupom_itens.cod_item

      IF STATUS = 0 THEN
         LET l_nf_item_ser.val_ipi     = l_val_unit_ipi * l_sol_cupom_itens.qtd_pecas_atend
         LET l_nf_item_ser.ies_tributa_ipi    = "S"
         LET l_val_item = l_sol_cupom_itens.pre_unit_venda * 
                          l_sol_cupom_itens.qtd_pecas_atend
         LET l_nf_item_ser.val_liq_item = l_val_item - l_nf_item_ser.val_ipi
      ELSE
         IF l_nf_item_ser.pct_ipi >  0 THEN
            LET l_val_item = l_sol_cupom_itens.pre_unit_venda * l_sol_cupom_itens.qtd_pecas_atend
            LET l_nf_item_ser.val_ipi = l_val_item - (l_val_item / (1 + l_nf_item_ser.pct_ipi/100))
            LET l_nf_item_ser.val_liq_item = l_val_item - l_nf_item_ser.val_ipi
            LET l_nf_item_ser.ies_tributa_ipi    = "S"
         ELSE
            LET l_nf_item_ser.val_ipi     = 0
            LET l_nf_item_ser.ies_tributa_ipi    = "N"
            LET l_val_item = l_sol_cupom_itens.pre_unit_venda * 
                             l_sol_cupom_itens.qtd_pecas_atend
            LET l_nf_item_ser.val_liq_item = l_val_item
         END IF
      END IF
      LET l_nf_item_ser.pre_unit_ped     = l_nf_item_ser.val_liq_item / l_sol_cupom_itens.qtd_pecas_atend
      LET l_nf_item_ser.pre_unit_nf      = l_nf_item_ser.val_liq_item / l_sol_cupom_itens.qtd_pecas_atend
      
   ELSE
      LET l_nf_item_ser.val_ipi     = 0
      LET l_nf_item_ser.ies_tributa_ipi    = "N"
   END IF

   INSERT INTO nf_item_ser VALUES (l_nf_item_ser.*)

   IF STATUS <> 0 AND
      STATUS <> -239 THEN
     CALL log003_err_sql("INSERCAO","NF_ITEM_SER")
      ROLLBACK WORK
      RETURN FALSE
   END IF

   SELECT cod_nat_oper_ref INTO l_cod_nat_oper_ref
     FROM nat_oper_refer
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_sol_cupom_itens.cod_item
      AND cod_nat_oper = l_sol_cupom_mestre.cod_nat_oper

   IF STATUS = 0 THEN
      SELECT * INTO l_fiscal_par.*
        FROM fiscal_par
       WHERE cod_empresa  = p_cod_empresa
         AND cod_nat_oper = l_cod_nat_oper_ref
         AND cod_uni_feder = l_uni_feder

      IF STATUS <> 0 THEN
         ERROR " Nao existe parametros fiscais para a venda "
         RETURN FALSE
      END IF

      SELECT * INTO l_nat_operacao.*
        FROM nat_operacao
       WHERE cod_nat_oper = l_cod_nat_oper_ref

      IF STATUS <> 0 THEN
         ERROR " Nao existe natureza operacao fiscais para a venda "
         RETURN FALSE
      END IF
   ELSE
      SELECT * INTO l_nat_operacao.*
        FROM nat_operacao
       WHERE cod_nat_oper = l_sol_cupom_mestre.cod_nat_oper

      IF STATUS <> 0 THEN
         ERROR " Nao existe natureza operacao fiscais para a venda "
         RETURN FALSE
      END IF

      SELECT * INTO l_fiscal_par.*
        FROM fiscal_par
       WHERE cod_empresa  = p_cod_empresa
         AND cod_nat_oper = l_sol_cupom_mestre.cod_nat_oper
         AND cod_uni_feder = l_uni_feder

      IF STATUS <> 0 THEN
         ERROR " Nao existe parametros fiscais para a venda "
         RETURN FALSE
      END IF
   END IF

   select pct_icms
     into l_pct_icm
     from icms_temp_7662
    where cod_item = l_nf_item_ser.cod_item
     
   if status <> 0 then
      let l_pct_icm = 0
   end if
   
   LET l_nf_item_fiscal_ser.cod_empresa       = p_cod_empresa
   LET l_nf_item_fiscal_ser.num_nff           = m_num_nff
   LET l_nf_item_fiscal_ser.ser_nff           = m_serie_nota
   LET l_nf_item_fiscal_ser.num_pedido        = l_sol_cupom_itens.num_cupom
   LET l_nf_item_fiscal_ser.num_sequencia     = l_ind
   LET l_nf_item_fiscal_ser.cod_nat_oper      = l_nat_operacao.cod_nat_oper
   LET l_nf_item_fiscal_ser.ies_incid_ipi     = l_fiscal_par.ies_incid_ipi
   LET l_nf_item_fiscal_ser.ies_incid_icm     = l_fiscal_par.ies_incid_icm
   LET l_nf_item_fiscal_ser.pct_icm           = l_pct_icm
   LET l_nf_item_fiscal_ser.pct_desc_base_icm = l_fiscal_par.pct_desc_b_icm_c
   LET l_nf_item_fiscal_ser.cod_fiscal        = l_fiscal_par.cod_fiscal
   LET l_nf_item_fiscal_ser.cod_origem        = l_fiscal_par.cod_origem
   LET l_nf_item_fiscal_ser.cod_tributacao    = l_fiscal_par.cod_tributacao
   LET l_nf_item_fiscal_ser.pct_desc_base_ipi = l_fiscal_par.pct_desc_base_ipi
   LET l_nf_item_fiscal_ser.pct_cred_icm      = l_fiscal_par.pct_cred_icm
   LET l_nf_item_fiscal_ser.tax_red_pct_icm   = l_fiscal_par.tax_red_pct_icm
   LET l_nf_item_fiscal_ser.pct_desc_ipi      = l_fiscal_par.pct_desc_ipi
   LET l_nf_item_fiscal_ser.cod_sit_trib      = l_nat_operacao.cod_sit_trib
   LET l_nf_item_fiscal_ser.cod_trib_estadual = l_nat_operacao.cod_trib_estadual
   LET l_nf_item_fiscal_ser.cod_trib_federal  = l_nat_operacao.cod_trib_federal
   LET l_nf_item_fiscal_ser.val_desc_cred_icm = 0

    IF mr_tela.ies_calcula = 'S' THEN
      LET l_nf_item_fiscal_ser.val_base_ipi   = l_nf_item_ser.val_liq_item
   ELSE
      LET l_nf_item_fiscal_ser.val_ipi        = 0
      LET l_nf_item_fiscal_ser.val_base_ipi   = 0
   END IF

   LET l_nf_item_fiscal_ser.val_ipi           = l_nf_item_ser.val_ipi
   LET l_nf_item_fiscal_ser.val_base_icm      = l_nf_item_ser.val_liq_item + l_nf_item_ser.val_ipi
   LET l_nf_item_fiscal_ser.val_icm           = (l_nf_item_fiscal_ser.val_base_icm * l_pct_icm) /100
   LET l_nf_item_fiscal_ser.val_base_ret      = 0
   LET l_nf_item_fiscal_ser.val_icm_ret       = 0
   LET l_nf_item_fiscal_ser.val_frete         = 0
   LET l_nf_item_fiscal_ser.val_seguro        = 0
   LET l_nf_item_fiscal_ser.val_base_ipi_da   = 0
   LET l_nf_item_fiscal_ser.val_ipi_desp_aces = 0
   LET l_nf_item_fiscal_ser.ord_montag        = 0

   LET l_val_icm      = l_val_icm      + l_nf_item_fiscal_ser.val_icm
   LET l_val_base_icm = l_val_base_icm + l_nf_item_fiscal_ser.val_base_icm
   LET l_val_ipi      = l_val_ipi      + l_nf_item_fiscal_ser.val_ipi

   INSERT INTO nf_item_fiscal_ser VALUES (l_nf_item_fiscal_ser.*)
   IF STATUS <> 0 AND
      STATUS <> -239 THEN
      CALL log003_err_sql("INSERCAO","NF_ITEM_FISCAL_SER")
      ROLLBACK WORK
      RETURN FALSE
   END IF

END FOREACH

 IF l_val_ipi IS NULL THEN
    LET l_val_ipi = 0
 END IF

 UPDATE nf_mestre_ser
    SET val_tot_icm        = l_val_icm,
        val_tot_base_icm   = l_val_base_icm,
        val_tot_ipi        = l_val_ipi,
        val_tot_base_ipi   = val_tot_base_ipi - l_val_ipi,
        val_tot_mercadoria = l_val_tot_mercadoria - l_val_ipi,
        val_tot_nff        = l_val_tot_mercadoria
  WHERE cod_empresa = p_cod_empresa
    AND num_nff     = m_num_nff
    AND ser_nff     = m_serie_nota

   IF STATUS <> 0 THEN
      CALL log003_err_sql("MODIFICACAO","NF_MESTRE_SER")
      ROLLBACK WORK
      RETURN FALSE
   END IF
RETURN TRUE

END FUNCTION


#-------------------------------------#
 FUNCTION sol0220_grava_fat_nf_compl()
#-------------------------------------#
 DEFINE lr_nf_compl   RECORD LIKE fat_nf_compl.*

 INITIALIZE lr_nf_compl.* TO NULL

 LET lr_nf_compl.empresa           = p_cod_empresa
 LET lr_nf_compl.nota_fiscal       = m_num_nff
 LET lr_nf_compl.serie_nota_fiscal = m_serie_nota
 LET lr_nf_compl.campo             = 'serie_cupom_fiscal'
 LET lr_nf_compl.parametro_texto   = m_serie_cupom

 

 INSERT INTO fat_nf_compl VALUES (lr_nf_compl.*)

 

 IF STATUS <> 0 THEN
    CALL log003_err_sql('INSERT','FAT_NF_COMPL')
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#-----------------------------------------------------#
 FUNCTION sol0220_controla_serie(l_num_nff, l_ser_nff)
#-----------------------------------------------------#
 
 DEFINE l_num_nff   LIKE nf_mestre_ser.num_nff,
        l_ser_nff   LIKE nf_mestre_ser.ser_nff

 LET m_serie_cupom = l_ser_nff

 SELECT num_nff
   FROM nf_mestre_ser
  WHERE cod_empresa = p_cod_empresa
    AND num_nff     = l_num_nff
    AND ser_nff     = l_ser_nff

{* IF STATUS = 0 THEN
    {busca serie substituta

    CALL vdp0458_busca_serie_disponivel(l_num_nff,l_ser_nff)
       RETURNING l_ser_nff

 END IF
}

 LET m_serie_nota = l_ser_nff

 RETURN l_ser_nff

END FUNCTION

#---------------------------------------#
 FUNCTION sol0220_carrega_cupons_livro()
#---------------------------------------#
 
 DEFINE l_sol_infor_fecham   RECORD LIKE sol_infor_fecham.*

 DEFINE l_cod_ponto_venda    LIKE sol_ponto_venda.cod_ponto_venda,
        l_dat_emis_cupom     DATE,
        l_num_cupom          LIKE sol_cupom_mestre.num_cupom

 DEFINE l_texto              CHAR(80),
        l_num_gt             LIKE sol_infor_fecham.num_gt,
        l_data               DATE,
        l_ind                SMALLINT

 DECLARE cq_pto CURSOR FOR
  SELECT cod_ponto_venda,
         dat_emis_cupom,
         MAX(num_cupom)
    FROM sol_cupom_mestre  #deve ser a tabela que contém os cupons
   WHERE cod_empresa     = p_cod_empresa
     AND dat_emis_cupom >= mr_tela.dat_ini
     AND dat_emis_cupom <= mr_tela.dat_fim
     AND ies_situacao    = 'N'
   GROUP BY cod_ponto_venda, dat_emis_cupom

 FOREACH cq_pto INTO l_cod_ponto_venda,
                     l_dat_emis_cupom,
                     l_num_cupom

    IF STATUS <> 0 THEN
       CALL log003_err_sql('FOREACH','CQ_PTO')
       RETURN FALSE
    END IF

    SELECT * INTO l_sol_infor_fecham.*
      FROM sol_infor_fecham
     WHERE cod_empresa = p_cod_empresa
       AND cod_ponto_venda = l_cod_ponto_venda
       AND dat_movto = l_dat_emis_cupom

    LET l_ind = 1

    LET l_data = l_dat_emis_cupom

    WHILE TRUE
       LET l_data = l_data - 1 UNITS DAY

       SELECT num_gt
         INTO l_num_gt
         FROM sol_infor_fecham
        WHERE cod_empresa     = p_cod_empresa
          AND cod_ponto_venda = l_cod_ponto_venda
          AND dat_movto       = l_data

       IF STATUS = 0 THEN
          EXIT WHILE
       END IF
       
       LET l_ind = l_ind + 1

       IF l_ind > 30 THEN
          LET l_num_gt = 0
          EXIT WHILE
       END IF
    END WHILE

    IF STATUS = 0 THEN
       LET l_texto = 'GT:', l_num_gt USING '<<,<<<,<<<,<<&.&&',
                     '/', l_sol_infor_fecham.num_gt USING '<<,<<<,<<<,<<&.&&'

       INSERT INTO w_obs_livro VALUES (p_cod_empresa,
                                       l_num_cupom,
                                       l_cod_ponto_venda,
                                       l_dat_emis_cupom,
                                       l_sol_infor_fecham.num_cupom_fim,
                                       l_texto)

       IF STATUS <> 0 THEN
          CALL log003_err_sql('INSERT','W_OBS_LIVRO')
          RETURN FALSE
       END IF
    END IF

 END FOREACH

 RETURN TRUE

END FUNCTION

#-------------------------------------#
 FUNCTION sol0220_grava_nf_obs_livro()
#-------------------------------------#
 
 DEFINE l_num_nff       LIKE nf_mestre_ser.num_nff,
        l_ser_nff       LIKE nf_mestre_ser.ser_nff,
        l_dat_emis      LIKE nf_mestre_ser.dat_emissao,
        l_texto_livro   CHAR(120),
        p_transac       INTEGER

 INITIALIZE l_num_nff, l_ser_nff, l_dat_emis, l_texto_livro TO NULL

 
 DECLARE cq_grava_obs CURSOR FOR
  SELECT UNIQUE 
         nf_mestre_ser.num_nff,
         nf_mestre_ser.ser_nff,
         w_obs_livro.dat_emis_cupom,
         w_obs_livro.texto_livro
    FROM nf_mestre_ser,
         w_obs_livro
   WHERE nf_mestre_ser.cod_empresa   = p_cod_empresa
     AND nf_mestre_ser.dat_emissao  >= mr_tela.dat_ini
     AND nf_mestre_ser.dat_emissao  <= mr_tela.dat_fim
     AND nf_mestre_ser.ser_nff      <> 'D'
     AND nf_mestre_ser.ies_situacao  = 'N'
     AND nf_mestre_ser.ies_especie   = 'CF'
     AND w_obs_livro.empresa         = nf_mestre_ser.cod_empresa
     AND w_obs_livro.dat_emis_cupom  = nf_mestre_ser.dat_emissao
     AND ((w_obs_livro.serie_cupom   = nf_mestre_ser.ser_nff)
       OR (w_obs_livro.serie_cupom   =
              (SELECT parametro_texto
                 FROM fat_nf_compl
                WHERE campo                = 'serie_cupom_fiscal'
                  AND fat_nf_compl.empresa = nf_mestre_ser.cod_empresa
                  AND nota_fiscal          = nf_mestre_ser.num_nff
                  AND serie_nota_fiscal    = nf_mestre_ser.ser_nff)))

 FOREACH cq_grava_obs INTO l_num_nff,
                           l_ser_nff,
                           l_dat_emis,
                           l_texto_livro

    IF STATUS <> 0 THEN
       CALL log003_err_sql('FOREACH','CQ_GRAVA_OBS')
       RETURN FALSE
    END IF

    SELECT cod_empresa
      FROM nf_obs_livro
     WHERE cod_empresa = p_cod_empresa
       AND num_nff     = l_num_nff
       AND ser_nff     = l_ser_nff

    IF STATUS <> 0 THEN

       INSERT INTO nf_obs_livro VALUES (p_cod_empresa,
                                        l_num_nff,
                                        l_ser_nff,
                                        l_texto_livro,
                                        l_dat_emis)

       IF STATUS <> 0 THEN
          CALL log003_err_sql('INSERT','NF_OBS_LIVRO')
          RETURN FALSE
       END IF
    ELSE
       UPDATE nf_obs_livro
          SET texto = l_texto_livro
        WHERE cod_empresa = p_cod_empresa
          AND num_nff     = l_num_nff
          AND ser_nff     = l_ser_nff

       IF STATUS <> 0 THEN
          CALL log003_err_sql('UPDATE','NF_OBS_LIVRO')
          RETURN FALSE
       END IF
    END IF

 END FOREACH
 
 FREE cq_grava_obs

 RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION sol0220_cria_temporaria()
#----------------------------------#
 
 DROP TABLE w_obs_livro

 CREATE TEMP TABLE w_obs_livro
 (
    empresa           CHAR(02),
    num_cupom         DECIMAL(6,0),
    serie_cupom       CHAR(02),
    dat_emis_cupom    DATE,
    num_cupom_final   DECIMAL(6,0),
    texto_livro       CHAR(120)
 ) WITH NO LOG;

 IF STATUS <> 0 THEN
    CALL log003_err_sql('CREATE','W_OBS_LIVRO')
    RETURN FALSE
 END IF

 CREATE INDEX ix1_obs_livro ON w_obs_livro
 (
    empresa,
    num_cupom,
    serie_cupom,
    dat_emis_cupom
 );

 IF STATUS <> 0 THEN
    CALL log003_err_sql('CREATE','W_OBS_LIVRO')
    RETURN FALSE
 END IF

 DROP TABLE tributo_tmp

 CREATE TABLE tributo_tmp (
      tributo_benef CHAR(11),
      trans_config  INTEGER
 );

 IF STATUS <> 0 THEN
		CALL log003_err_sql("Criando","tributo_tmp")
		RETURN FALSE
	END IF

 DROP TABLE chave_tmp_7662

  CREATE TABLE chave_tmp_7662 (
      chave CHAR(11)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','chave_tmp_7662')
      RETURN FALSE
   END IF  

 DROP TABLE icms_temp_7662

  CREATE TABLE icms_temp_7662 (
      cod_item CHAR(15),
      pct_icms DECIMAL(5,2)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','icms_temp_7662')
      RETURN FALSE
   END IF  

 RETURN TRUE

END FUNCTION

#------------------------------------------#
 FUNCTION sol0220_grava_informacoes_livro()
#------------------------------------------#
 
  DEFINE l_sol_infor_fecham    RECORD LIKE sol_infor_fecham.*,
         l_texto               CHAR(120),
         l_serie               CHAR(02),
         l_num_serie           LIKE sol_ponto_venda.num_serie,
         p_transac             INTEGER

  INITIALIZE l_sol_infor_fecham.* TO NULL

  DELETE FROM fat_info_fecha_cf
   WHERE fat_info_fecha_cf.empresa = p_cod_empresa
     AND fat_info_fecha_cf.dat_movto >= mr_tela.dat_ini
     AND fat_info_fecha_cf.dat_movto <= mr_tela.dat_fim
  
  IF STATUS <> 0 THEN
     CALL log0030_mensagem('Problema da limpeza dos dados de fechamento fiscal.','info')
     CALL log085_transacao("ROLLBACK")
     ERROR "Processamento Cancelado."
     RETURN FALSE
  END IF

  DECLARE cq_fecha_cf CURSOR FOR
   SELECT * FROM sol_infor_fecham
    WHERE sol_infor_fecham.cod_empresa = p_cod_empresa
      AND sol_infor_fecham.dat_movto >= mr_tela.dat_ini
      AND sol_infor_fecham.dat_movto <= mr_tela.dat_fim

  FOREACH cq_fecha_cf INTO l_sol_infor_fecham.*

      INSERT INTO fat_info_fecha_cf 
       VALUES (l_sol_infor_fecham.cod_empresa,
               l_sol_infor_fecham.cod_ponto_venda,
               l_sol_infor_fecham.dat_movto,
               l_sol_infor_fecham.num_cupom_ini,
               l_sol_infor_fecham.num_cupom_fim,
               l_sol_infor_fecham.num_gt,
               l_sol_infor_fecham.vlr_acrescimo,
               l_sol_infor_fecham.vlr_desconto,
               l_sol_infor_fecham.vlr_tot_cupons,
               l_sol_infor_fecham.cnt_reducao_z,
               l_sol_infor_fecham.cnt_reinicio_oper,
               0,'') 
               
      IF STATUS <> 0 THEN
         CALL log0030_mensagem('Problema na inclusao dados de fechamento fiscal.','info')
         CALL log085_transacao("ROLLBACK")
         ERROR "Processamento Cancelado."
         RETURN FALSE
      END IF

      LET l_serie = l_sol_infor_fecham.cod_ponto_venda

      DELETE FROM nf_obs_livro
       WHERE cod_empresa = p_cod_empresa
         AND num_nff = l_sol_infor_fecham.num_cupom_fim
         AND ser_nff = l_serie
  
      IF STATUS <> 0 THEN
         CALL log0030_mensagem('Problema da limpeza dos dados de observações de NF.','info')
         CALL log085_transacao("ROLLBACK")
         ERROR "Processamento Cancelado."
         RETURN FALSE
      END IF
      
      LET p_trans_nf = 0
      
      DECLARE cq_trans CURSOR FOR
       SELECT trans_nota_fiscal
         FROM fat_nf_mestre
        WHERE empresa = p_cod_empresa
          AND nota_fiscal = l_sol_infor_fecham.num_cupom_fim
          AND serie_nota_fiscal = l_serie
          AND espc_nota_fiscal = 'CF'
      FOREACH cq_trans INTO p_transac
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','fat_nf_mestre:cq_trans')
            CALL log085_transacao("ROLLBACK")
            ERROR "Processamento Cancelado."
            RETURN FALSE
         END IF
         
         LET p_trans_nf = p_transac
         
         DELETE FROM fat_nf_obs_livro
          WHERE empresa = p_cod_empresa
            AND trans_nota_fiscal = p_trans_nf

         EXIT FOREACH
      
      END FOREACH
      
      SELECT sol_ponto_venda.num_serie
        INTO l_num_serie
        FROM sol_ponto_venda
       WHERE sol_ponto_venda.cod_empresa     = p_cod_empresa
         AND sol_ponto_venda.cod_ponto_venda = l_sol_infor_fecham.cod_ponto_venda

      LET l_texto = 'ECF/Nro Série: ', l_sol_infor_fecham.cod_ponto_venda USING "&&&", "/", l_num_serie

      INSERT INTO nf_obs_livro VALUES (p_cod_empresa,
                                       l_sol_infor_fecham.num_cupom_fim,
                                       l_serie,
                                       l_texto,
                                       l_sol_infor_fecham.dat_movto)
      
      IF p_trans_nf > 0 THEN
         INSERT INTO fat_nf_obs_livro
          VALUES (p_cod_empresa,
                  p_trans_nf,
                  p_cod_fiscal,
                  l_texto,
                  'A')
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo', 'fat_nf_obs_livro')
            RETURN FALSE
         END IF
      END IF
                                          
  END FOREACH

  RETURN TRUE

END FUNCTION

#Ivo: 04/04/2011 - gravação das 
#tabelas da versão 10.02

#----------------------------------#
FUNCTION sol0220_grava_tabs_novas()
#----------------------------------#
 
   IF NOT sol0220_ins_mestre() THEN
      RETURN FALSE
   END IF

   IF NOT sol0220_ins_itens() THEN
      RETURN FALSE
   END IF

   IF NOT sol0220_mestre_fisc() THEN 
      RETURN FALSE
   END IF

   IF NOT sol0220_ins_duplicatas() THEN 
      RETURN FALSE
   END IF
   
   UPDATE fat_nf_mestre
      SET val_mercadoria = val_mercadoria - p_val_tot_ipi,
          val_acre_nf    = p_val_tot_ipi
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_trans_nf
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update', 'fat_nf_mestre')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION sol0220_ins_mestre()
#---------------------------#

   DEFINE p_hor        CHAR(08),
          p_dat        CHAR(19),
          p_cod_repres INTEGER

   MESSAGE 'Gravando fat_nf_mestre!'

   SELECT tip_docum,
          subserie_docum
     INTO p_tip_docum,
          p_ssr
     FROM vdp_num_docum
    WHERE empresa = p_cod_empresa
      and serie_docum = l_sol_cupom_mestre.cod_ponto_venda
      
	IF STATUS <> 0 THEN 
		CALL log003_err_sql("LENDO",'VDP_NUM_DOCUM')
		RETURN 
	END IF  
	
	LET p_esp = 'CF'

   SELECT nat_oper_emis_nf INTO l_nat_oper_emis_nf
     FROM sol_parametros
    WHERE cod_empresa  = p_cod_empresa

   SELECT uni_feder INTO l_uni_feder
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   #LET p_dat = l_sol_cupom_mestre.dat_emis_cupom
   #LET p_hor = CURRENT HOUR TO SECOND
   #LET p_dat = p_dat CLIPPED, " ", p_hor
   
   INITIALIZE p_fat_mestre TO NULL

   LET p_fat_mestre.empresa            =  p_cod_empresa            
   LET p_fat_mestre.trans_nota_fiscal  =  0                        
   LET p_fat_mestre.tip_nota_fiscal    =  p_tip_docum             
   LET p_fat_mestre.serie_nota_fiscal  =  l_sol_cupom_mestre.cod_ponto_venda #p_ser                    
   LET p_fat_mestre.subserie_nf        =  0                                  #p_ssr                    
   LET p_fat_mestre.espc_nota_fiscal   =  p_esp                   
   LET p_fat_mestre.nota_fiscal        =  m_num_nff              
   LET p_fat_mestre.status_nota_fiscal =  'F'                      
   LET p_fat_mestre.modelo_nota_fiscal =  '01'                      
   LET p_fat_mestre.origem_nota_fiscal =  'I'                      
   LET p_fat_mestre.tip_processamento  =  'A'                      
   LET p_fat_mestre.sit_nota_fiscal    =  l_sol_cupom_mestre.ies_situacao   
   LET p_fat_mestre.cliente            = p_cod_cliente
   LET p_fat_mestre.remetent           =  ' '                      
   LET p_fat_mestre.zona_franca        =  'N'                      
   LET p_fat_mestre.natureza_operacao  =  l_sol_cupom_mestre.cod_nat_oper          
   LET p_fat_mestre.finalidade         =  '2'   
   LET p_fat_mestre.cond_pagto         = p_cod_cnd_pgto
   LET p_fat_mestre.tip_carteira       =  '01'       
   LET p_fat_mestre.ind_despesa_financ =  0                        
   LET p_fat_mestre.moeda              =  1                        
   LET p_fat_mestre.plano_venda        =  'N'     
   LET p_fat_mestre.transportadora     =  ''    
   LET p_fat_mestre.tip_frete          =  1 
   LET p_fat_mestre.via_transporte     =  1                      
   LET p_fat_mestre.peso_liquido       =  1                        
   LET p_fat_mestre.peso_bruto         =  1                        
   LET p_fat_mestre.peso_tara          =  0                        
   LET p_fat_mestre.num_prim_volume    =  0                        
   LET p_fat_mestre.volume_cubico      =  0                        
   LET p_fat_mestre.usu_incl_nf        =  p_user   
   LET p_dat_hor_emis                  =  l_sol_cupom_mestre.dat_emis_cupom                  
   LET p_fat_mestre.dat_hor_emissao    =  p_dat_hor_emis                 
   LET p_fat_mestre.sit_impressao      =  'N'                      
   LET p_fat_mestre.val_frete_rodov    =  0                        
   LET p_fat_mestre.val_seguro_rodov   =  0                        
   LET p_fat_mestre.val_fret_consig    =  0                        
   LET p_fat_mestre.val_segr_consig    =  0                        
   LET p_fat_mestre.val_frete_cliente  =  0                        
   LET p_fat_mestre.val_seguro_cliente =  0                        
   LET p_fat_mestre.val_desc_merc      =  0                        
   LET p_fat_mestre.val_desc_nf        =  0                        
   LET p_fat_mestre.val_desc_duplicata =  0                        
   LET p_fat_mestre.val_acre_merc      =  0                        
   LET p_fat_mestre.val_acre_nf        =  0                        
   LET p_fat_mestre.val_acre_duplicata =  0                        
   LET p_fat_mestre.val_mercadoria     =  l_sol_cupom_mestre.val_tot_venda                        
   LET p_fat_mestre.val_duplicata      =  l_sol_cupom_mestre.val_tot_venda                        
   LET p_fat_mestre.val_nota_fiscal    =  l_sol_cupom_mestre.val_tot_venda                      
                                                                                          
   INSERT INTO fat_nf_mestre VALUES (p_fat_mestre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','FAT_NF_MESTRE')
      RETURN FALSE
   END IF
   
   LET p_trans_nf = SQLCA.SQLERRD[2]

   SELECT cod_repres 
     INTO p_cod_repres
     FROM sol_de_para_repres
    WHERE cod_usuario = l_sol_cupom_mestre.vendedor
    
   INSERT INTO fat_nf_repr
    VALUES(p_fat_mestre.empresa,
           p_trans_nf,
           p_cod_repres,
           1,             #seq_representante
           0,             #pct_comissao
           'N')           #tem_comissao
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','FAT_NF_REPR')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION sol0220_ins_itens()
#--------------------------#
 
 DEFINE l_ind INTEGER
 
 INITIALIZE p_fat_item TO NULL
  
 LET p_fat_item.empresa            = p_cod_empresa                  
 LET p_fat_item.trans_nota_fiscal  = p_trans_nf  

 LET l_ind = 0

 DECLARE cq_cup_item CURSOR FOR
  SELECT * 
    FROM sol_cupom_itens
   WHERE cod_empresa      = l_sol_cupom_mestre.cod_empresa
     AND cod_ponto_venda  = l_sol_cupom_mestre.cod_ponto_venda
     AND num_cupom        = l_sol_cupom_mestre.num_cupom
     AND dat_emis_cupom   = l_sol_cupom_mestre.dat_emis_cupom
     AND ies_situacao = 'N'
   ORDER BY  num_sequencia

 FOREACH cq_cup_item INTO l_sol_cupom_itens.*

    LET p_cod_item = l_sol_cupom_itens.cod_item
    
    SELECT cod_nat_oper_ref                                  
      INTO p_cod_nat_oper                                            
      FROM nat_oper_refer                                            
     WHERE cod_empresa  = p_cod_empresa                              
       AND cod_nat_oper = p_fat_mestre.natureza_operacao                
       AND cod_item     = p_cod_item                
                                                                     
    IF STATUS = 100 THEN                                             
       LET p_cod_nat_oper = p_fat_mestre.natureza_operacao                                     
    ELSE                                                             
       IF STATUS <> 0 THEN                                           
          CALL log003_err_sql('Lendo','nat_oper_refer:2')            
          RETURN FALSE
       END IF                                                        
    END IF                                                           
                                                                      
   LET l_ind = l_ind + 1

   IF l_sol_cupom_itens.pct_desc_item IS NULL THEN
      LET l_sol_cupom_itens.pct_desc_item = 0
   END IF

	 LET p_fat_item.pedido  			    = l_sol_cupom_itens.num_cupom                               
	 LET p_fat_item.seq_item_pedido   = 0                             
   LET p_fat_item.ord_montag        = 0                              
	 LET p_fat_item.seq_item_nf  	 	  = l_ind          
	 LET p_fat_item.item     				  = l_sol_cupom_itens.cod_item            
   LET p_fat_item.tip_item          = 'N'                             
   LET p_fat_item.tip_preco         = 'F'                            
   LET p_fat_item.natureza_operacao = p_fat_mestre.natureza_operacao                
   LET p_fat_item.qtd_item          = l_sol_cupom_itens.qtd_pecas_atend

   SELECT cod_unid_med,
          den_item,
          pes_unit,
          cod_cla_fisc,
          fat_conver
     INTO p_fat_item.unid_medida,
          p_fat_item.des_item,
          p_fat_item.peso_unit,
          p_fat_item.classif_fisc,
          p_fat_item.fator_conv
     FROM item
    WHERE cod_empresa  = l_sol_cupom_mestre.cod_empresa
      AND cod_item     = l_sol_cupom_itens.cod_item

    LET p_fat_item.preco_unit_bruto   = l_sol_cupom_itens.pre_unit_venda  
                 
    LET p_fat_item.pre_uni_desc_incnd = l_sol_cupom_itens.pre_unit_venda -           
        (l_sol_cupom_itens.pre_unit_venda * (l_sol_cupom_itens.pct_desc_item / 100))    
              
    LET p_fat_item.preco_unit_liquido = p_fat_item.pre_uni_desc_incnd
                 
    LET p_fat_item.pct_frete          = 0                              
    LET p_fat_item.val_desc_item      = 
        p_fat_item.qtd_item * l_sol_cupom_itens.pct_desc_item / 100

    LET p_fat_item.val_desc_merc      = p_fat_item.val_desc_item                             
    LET p_fat_item.val_desc_contab    = 0                              
    LET p_fat_item.val_desc_duplicata = 0                              
    LET p_fat_item.val_acresc_item    = 0                             
    LET p_fat_item.val_acre_merc      = 0  
    LET p_fat_item.val_acresc_contab  = 0
    LET p_fat_item.val_acre_duplicata = 0
    LET p_fat_item.val_fret_consig    = 0
    LET p_fat_item.val_segr_consig    = 0
    LET p_fat_item.val_frete_cliente  = 0
    LET p_fat_item.val_seguro_cliente = 0
    LET p_fat_item.val_duplicata_item = 
           p_fat_item.preco_unit_bruto * p_fat_item.qtd_item - p_fat_item.val_desc_item
    LET p_fat_item.val_contab_item    = p_fat_item.val_duplicata_item
    LET p_val_base_trib               = p_fat_item.val_duplicata_item
    
    DELETE FROM tributo_tmp
    
    IF NOT sol0220_le_param_fisc() THEN 
       RETURN FALSE
    END IF

    LET p_cod_fiscal  = 0

    SELECT trans_config
      INTO p_trans_config
      FROM tributo_tmp
     WHERE tributo_benef = 'ICMS'
    
    IF STATUS = 0 THEN
      SELECT cod_fiscal
        INTO p_cod_fiscal
        FROM obf_config_fiscal
       WHERE empresa  	  = p_cod_empresa
         AND trans_config = p_trans_config
    END IF    

    SELECT trans_config
      INTO p_trans_config
      FROM tributo_tmp
     WHERE tributo_benef = 'IPI'

    IF STATUS <> 0 THEN
       LET p_aliquota_ipi  = 0
    ELSE
      SELECT aliquota
        INTO p_aliquota_ipi
        FROM obf_config_fiscal
       WHERE empresa  	  = p_cod_empresa
         AND trans_config = p_trans_config
         
      IF STATUS <> 0 THEN
         LET p_aliquota_ipi = 0
      END IF
    END IF

    LET p_trans_ipi = 0
    LET p_tributa_ipi  = "N"

    IF p_aliquota_ipi IS NULL THEN
       LET p_aliquota_ipi = 0
    END IF
           
   IF mr_tela.ies_calcula = 'S' THEN
      SELECT val_unit_ipi  
        INTO p_val_unit_ipi
        FROM ctr_ipi_unit
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = l_sol_cupom_itens.cod_item

      IF STATUS = 0 THEN
         LET p_val_ipi_item = p_val_unit_ipi * p_fat_item.qtd_item
         LET p_val_item     = p_val_base_trib
         LET p_fat_item.val_liquido_item = p_val_item - p_val_ipi_item
         LET p_aliquota_ipi = p_val_ipi_item / p_val_item * 100
      ELSE
         IF p_aliquota_ipi >  0 THEN
            LET p_val_item = p_val_base_trib
            LET p_val_ipi_item = p_val_item - (p_val_item / (1 + p_aliquota_ipi/100))
            LET p_fat_item.val_liquido_item = p_val_item - p_val_ipi_item
            LET p_tributa_ipi = "S"
         ELSE
            IF NOT sol0220_le_formula() THEN
               RETURN FALSE
            END IF
            IF p_trans_ipi > 0 THEN
               LET p_val_ipi_item = p_val_unit_ipi * p_fat_item.qtd_item
               LET p_tributa_ipi  = "S"
               LET p_val_item     = p_val_base_trib
               LET p_fat_item.val_liquido_item = p_val_item - p_val_ipi_item
               LET p_aliquota_ipi = p_val_ipi_item / p_val_item * 100
            ELSE
               LET p_val_ipi_item = 0
               LET p_tributa_ipi = "N"
               LET p_val_item = p_val_base_trib
               LET p_fat_item.val_liquido_item = p_val_item
            END IF
         END IF
      END IF
      LET p_fat_item.preco_unit_liquido = p_fat_item.val_liquido_item / p_fat_item.qtd_item
   ELSE
      LET p_val_ipi_item = 0
      LET p_aliquota_ipi = 0
      LET p_tributa_ipi = "N"
   END IF

   LET p_fat_item.preco_unit_bruto   = p_fat_item.preco_unit_liquido                 
   LET p_fat_item.pre_uni_desc_incnd = p_fat_item.preco_unit_liquido
   LET p_fat_item.val_merc_item      = p_fat_item.val_liquido_item
   LET p_fat_item.val_bruto_item     = p_fat_item.val_liquido_item
   LET p_fat_item.val_brt_desc_incnd = p_fat_item.val_liquido_item

    IF NOT sol0220_ins_tributo() THEN 
       RETURN FALSE
    END IF    
   
    LET p_fat_item.item_prod_servico = p_tip_item                     
   
   INSERT INTO fat_nf_item VALUES(p_fat_item.*) 

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERCAO","fat_nf_item")
      RETURN FALSE
   END IF
   
   LET p_val_tot_ipi = p_val_tot_ipi + p_val_ipi_item
 
 END FOREACH
 
 RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION sol0220_ins_tributo()
#----------------------------#
   
   LET p_fat_item_fisc.empresa            = p_fat_item.empresa
   LET p_fat_item_fisc.trans_nota_fiscal  = p_fat_item.trans_nota_fiscal
   LET p_fat_item_fisc.seq_item_nf        = p_fat_item.seq_item_nf

   DECLARE cq_trib_tmp CURSOR FOR
    SELECT tributo_benef,
           trans_config
      FROM tributo_tmp

   FOREACH cq_trib_tmp INTO p_tributo_benef, p_trans_config

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','tributo_tmp')
         RETURN FALSE
      END IF
      
      IF p_tributo_benef = 'IPI' THEN
         IF p_trans_ipi > 0 THEN
            LET p_trans_config = p_trans_ipi
         END IF
      END IF
      
      IF NOT sol0220_le_obf_config() THEN
         RETURN FALSE
      END IF

      IF p_tributo_benef = 'IPI' THEN
         IF p_tributa_ipi = 'S' THEN
            LET p_aliquota = p_aliquota_ipi
         ELSE
            LET p_aliquota = NULL
         END IF
      END IF
      
      IF p_aliquota = 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF p_cod_fiscal <> 0 THEN
         LET p_fat_item_fisc.cod_fiscal = p_cod_fiscal
      END IF

      IF p_tributo_benef = 'ICMS' THEN
         LET p_fat_item_fisc.bc_trib_mercadoria = p_val_base_trib  
         select cod_item
           from icms_temp_7662
          where cod_item = p_fat_item.item
         if status <> 0 then
            insert into icms_temp_7662
             values(p_fat_item.item, p_aliquota)
         end if
      ELSE
         LET p_fat_item_fisc.bc_trib_mercadoria = p_val_base_trib - p_val_ipi_item
      END IF        
      
      IF p_tributo_benef = 'IPI' THEN
         LET p_val_tribruto = p_val_ipi_item
      ELSE
         LET p_val_tribruto = p_fat_item_fisc.bc_trib_mercadoria * (p_aliquota / 100)
      END IF
   
      LET p_fat_item_fisc.incide               = p_cod_incide        
      LET p_fat_item_fisc.aliquota             = p_aliquota      
      LET p_fat_item_fisc.tributo_benef        = p_tributo_benef 
      LET p_fat_item_fisc.trans_config         = p_trans_config  
      LET p_fat_item_fisc.bc_tributo_frete     = 0                            
      LET p_fat_item_fisc.bc_trib_calculado    = 0                         
      LET p_fat_item_fisc.bc_tributo_tot       = p_fat_item_fisc.bc_trib_mercadoria               
      LET p_fat_item_fisc.val_trib_merc        = p_val_tribruto  
      LET p_fat_item_fisc.val_tributo_frete    = 0                            
      LET p_fat_item_fisc.val_trib_calculado   = 0                         
      LET p_fat_item_fisc.cotacao_moeda_upf    = NULL            
      LET p_fat_item_fisc.simples_nacional     = NULL            
      LET p_fat_item_fisc.val_tributo_tot      = p_val_tribruto 
                                                                
      INSERT INTO fat_nf_item_fisc(
         empresa,           
         trans_nota_fiscal, 
         seq_item_nf,       
         tributo_benef,     
         trans_config,      
         bc_trib_mercadoria,
         bc_tributo_frete,  
         bc_trib_calculado, 
         bc_tributo_tot,    
         val_trib_merc,     
         val_tributo_frete, 
         val_trib_calculado,
         val_tributo_tot,   
         acresc_desc,       
         aplicacao_val,     
         incide,            
         origem_produto,    
         tributacao,        
         hist_fiscal,       
         sit_tributo,       
         motivo_retencao,   
         retencao_cre_vdp,  
         cod_fiscal,        
         inscricao_estadual,
         dipam_b,           
         aliquota,          
         val_unit,         
         pre_uni_mercadoria,
         pct_aplicacao_base,
         pct_acre_bas_calc, 
         pct_red_bas_calc,  
         pct_diferido_base, 
         pct_diferido_val,  
         pct_acresc_val,    
         pct_reducao_val,   
         pct_margem_lucro,  
         pct_acre_marg_lucr,
         pct_red_marg_lucro,
         taxa_reducao_pct,  
         taxa_acresc_pct,   
         cotacao_moeda_upf, 
         simples_nacional,  
         iden_processo) 
      VALUES(p_fat_item_fisc.*)                                  
                                                                
      IF STATUS <> 0 THEN                                       
         CALL log003_err_sql('Inserindo','fat_nf_item_fisc')
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION sol0220_le_obf_config()
#-------------------------------#

   SELECT incide,                      
          aliquota, 
          acresc_desc,              
          aplicacao_val,               
          origem_produto,              
          hist_fiscal,                 
          sit_tributo,                 
          inscricao_estadual,          
          dipam_b,                     
          retencao_cre_vdp,            
          motivo_retencao,             
          val_unit,                    
          pre_uni_mercadoria,          
          pct_aplicacao_base,          
          pct_acre_bas_calc,  
          pct_red_bas_calc,         
          pct_diferido_base,           
          pct_diferido_val,            
          pct_acresc_val,              
          pct_reducao_val,             
          pct_margem_lucro,            
          pct_acre_marg_lucr,          
          pct_red_marg_lucro,          
          taxa_reducao_pct,            
          taxa_acresc_pct,
		      cod_fiscal,
		      tributacao
     INTO p_cod_incide,                    
          p_aliquota,
          p_fat_item_fisc.acresc_desc,               
          p_fat_item_fisc.aplicacao_val,             
          p_fat_item_fisc.origem_produto,            
          p_fat_item_fisc.hist_fiscal,               
          p_fat_item_fisc.sit_tributo,               
          p_fat_item_fisc.inscricao_estadual,        
          p_fat_item_fisc.dipam_b,                   
          p_fat_item_fisc.retencao_cre_vdp,          
          p_fat_item_fisc.motivo_retencao,           
          p_fat_item_fisc.val_unit,                  
          p_fat_item_fisc.pre_uni_mercadoria,        
          p_fat_item_fisc.pct_aplicacao_base,        
          p_fat_item_fisc.pct_acre_bas_calc, 
          p_fat_item_fisc.pct_red_bas_calc,        
          p_fat_item_fisc.pct_diferido_base,         
          p_fat_item_fisc.pct_diferido_val,          
          p_fat_item_fisc.pct_acresc_val,            
          p_fat_item_fisc.pct_reducao_val,           
          p_fat_item_fisc.pct_margem_lucro,          
          p_fat_item_fisc.pct_acre_marg_lucr,        
          p_fat_item_fisc.pct_red_marg_lucro,        
          p_fat_item_fisc.taxa_reducao_pct,          
          p_fat_item_fisc.taxa_acresc_pct,
		      p_fat_item_fisc.cod_fiscal,
		      p_fat_item_fisc.tributacao
     FROM obf_config_fiscal
    WHERE empresa      = p_cod_empresa
      AND trans_config = p_trans_config                             

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','obf_config_fiscal')
      RETURN FALSE
   END IF

   IF p_aliquota IS NULL THEN
      LET p_aliquota = 0
   END IF       		     
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION sol0220_mestre_fisc()
#-----------------------------#

   DEFINE p_val_ipi DECIMAL(12,2)
   
   MESSAGE 'Gravando fat_mestre_fiscal!'
   
   INITIALIZE p_mest_fisc TO NULL

   LET p_mest_fisc.empresa            = p_cod_empresa  
   LET p_mest_fisc.trans_nota_fiscal  = p_trans_nf

   DECLARE cq_sum CURSOR FOR
    SELECT tributo_benef,
           SUM(bc_trib_mercadoria),
           SUM(bc_tributo_tot),
           SUM(val_trib_merc),
           SUM(val_tributo_tot)
      FROM fat_nf_item_fisc
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = p_trans_nf
     GROUP BY tributo_benef

   FOREACH cq_sum INTO 
           p_mest_fisc.tributo_benef,
           p_mest_fisc.bc_trib_mercadoria,
           p_mest_fisc.bc_tributo_tot,
           p_mest_fisc.val_trib_merc,
           p_mest_fisc.val_tributo_tot
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_item_fisc')
         RETURN FALSE
      END IF

      LET p_mest_fisc.bc_tributo_frete   = 0
      LET p_mest_fisc.bc_trib_calculado  = 0
      LET p_mest_fisc.val_tributo_frete  = 0
      LET p_mest_fisc.val_trib_calculado = 0

      INSERT INTO fat_mestre_fiscal
       VALUES(p_mest_fisc.*)
    
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','fat_mestre_fiscal')
         RETURN FALSE
      END IF
      
      #IF tributo_benef = 'IPI' THEN
      #   LET p_val_ipi = p_mest_fisc.val_trib_merc
      #END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION sol0220_ins_duplicatas()
#-------------------------------#

   DEFINE p_nf_integr         RECORD LIKE fat_nf_integr.*,
          p_ies_emite_dupl    CHAR(01),
          p_sequencia         LIKE cond_pgto_item.sequencia,
          p_pct_valor_liquido LIKE cond_pgto_item.pct_valor_liquido,
          p_qtd_dias_sd       LIKE cond_pgto_item.qtd_dias_sd,
          p_val_tot_dupl      DECIMAL(17,2),
          p_ind               INTEGER,
          p_val_gravado       DECIMAL(17,2),
          p_val_duplic        DECIMAL(17,2),
          p_dat_vencto        DATE

 SELECT ies_emite_dupl
   INTO p_ies_emite_dupl
   FROM nat_operacao
  WHERE cod_nat_oper = p_fat_mestre.natureza_operacao

 IF STATUS <> 0 THEN
    CALL log003_err_sql('Lendo','nat_operacao')
    RETURN FALSE
 END IF

 IF p_ies_emite_dupl = 'N' THEN
    RETURN TRUE
 END IF
 
 SELECT ies_emite_dupl
   INTO p_ies_emite_dupl
   FROM cond_pgto
  WHERE cod_cnd_pgto = p_cod_cnd_pgto
 
 IF p_ies_emite_dupl = 'N' THEN
    RETURN TRUE
 END IF

   SELECT COUNT(cod_cnd_pgto)
     INTO p_count
    FROM cond_pgto_item
   WHERE cod_cnd_pgto = p_cod_cnd_pgto

   IF p_count IS NULL THEN
      RETURN TRUE
   END IF
   
  LET  p_nf_integr.empresa           	= p_cod_empresa
  LET  p_nf_integr.trans_nota_fiscal 	= p_trans_nf
  LET  p_nf_integr.sit_nota_fiscal   	= 'N'
  LET  p_nf_integr.status_intg_est   	= 'P' 	 
  LET  p_nf_integr.status_intg_contab	= 'P'	 
  LET  p_nf_integr.status_intg_creceb	= 'P'	 
  LET  p_nf_integr.status_integr_obf	= 'P'	 
  LET  p_nf_integr.status_intg_migr		= 'P'	 
	
	INSERT INTO fat_nf_integr
	 VALUES(p_nf_integr.*)	        
	 
	IF STATUS <> 0 THEN 
	   CALL log003_err_sql('Inserindo','fat_nf_integr')
      RETURN FALSE
	END IF 

  LET p_val_tot_dupl = p_fat_mestre.val_duplicata
  LET p_ind = 1
  LET p_val_gravado = 0
	
  DECLARE cq_cond CURSOR FOR
   SELECT sequencia,
          pct_valor_liquido,
          qtd_dias_sd
     FROM cond_pgto_item
    WHERE cod_cnd_pgto = p_cod_cnd_pgto

    FOREACH cq_cond INTO 
          p_sequencia,
          p_pct_valor_liquido,
          p_qtd_dias_sd    

	    IF STATUS <> 0 THEN 
	       CALL log003_err_sql('lendo','cond_pgto_item:cq_cond')
         RETURN FALSE
	    END IF 

      IF p_ind = p_count THEN
         LET p_val_duplic = p_val_tot_dupl - p_val_gravado
      ELSE
         LET p_val_duplic  = 
             p_val_tot_dupl * p_pct_valor_liquido / 100
      END IF
      
      LET p_val_gravado = p_val_gravado + p_val_duplic    
      LET p_dat_vencto  = p_dat_cupom + p_qtd_dias_sd

      LET  p_nf_duplicata.empresa           = p_cod_empresa 
      LET  p_nf_duplicata.trans_nota_fiscal = p_trans_nf    
      LET  p_nf_duplicata.seq_duplicata     = p_sequencia            
      LET  p_nf_duplicata.val_duplicata     = p_val_duplic   
      LET  p_nf_duplicata.dat_vencto_sdesc  = p_dat_vencto  
      LET  p_nf_duplicata.dat_vencto_cdesc  = ''
      LET  p_nf_duplicata.pct_desc_financ   = 0             
      LET  p_nf_duplicata.val_bc_comissao   = 0             
      LET  p_nf_duplicata.agencia           = 0             
      LET  p_nf_duplicata.dig_agencia       = ' '           
      LET  p_nf_duplicata.titulo_bancario   = ' '           
      LET  p_nf_duplicata.docum_cre         = ' '           
      LET  p_nf_duplicata.empresa_cre       = ' '           
      
      INSERT INTO fat_nf_duplicata
       VALUES(p_nf_duplicata.*)

	    IF STATUS <> 0 THEN 
	       CALL log003_err_sql('Inserindo','fat_nf_duplicata')
         RETURN FALSE
	    END IF 

      LET p_ind = p_ind + 1
      
   END FOREACH

	RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION sol0220_le_param_fisc()
#------------------------------#

   DEFINE m_msg             CHAR(600),
          p_sem_tributo     SMALLINT
   
   LET p_msg = NULL
   LET m_msg = "Configuração fiscal não encontrada para o tributo(s) abaixo:","\n"   
   LET p_sem_tributo = FALSE
   
   LET p_ies_tipo = 'S' 
   LET p_ies_finalidade = 2
   
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
      LET p_msg = 'Não há tributos parametrizados!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   SELECT cod_cidade
     INTO p_cod_cidade
     FROM clientes
    WHERE cod_cliente = p_cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','clientes:cod_cidade')
      RETURN FALSE
   END IF
    
   SELECT cod_lin_prod,                             
          cod_lin_recei,                                     
          cod_seg_merc,                                      
          cod_cla_uso,                                       
          cod_familia,                                       
          gru_ctr_estoq,                                     
          cod_cla_fisc,                                      
          cod_unid_med                                       
     INTO p_cod_lin_prod,                                    
          p_cod_lin_recei,                                   
          p_cod_seg_merc,                                    
          p_cod_cla_uso,                                     
          p_cod_familia,                                     
          p_gru_ctr_estoq,                                   
          p_cod_cla_fisc,                                    
          p_cod_unid_med                                     
     FROM item                                               
    WHERE cod_empresa  = p_cod_empresa                       
      AND cod_item     = p_cod_item          
      AND ies_situacao = 'A'                                 
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
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

      LET p_ies_tributo = FALSE
      
      DECLARE cq_acesso CURSOR FOR
       SELECT sequencia_acesso
         FROM obf_ctr_acesso
        WHERE empresa         = p_cod_empresa
          AND controle_acesso = p_tributo_benef
          AND origem          = p_ies_tipo
        ORDER BY num_ctr_acesso DESC
      
      FOREACH cq_acesso INTO p_seq_acesso
      
         LET p_seq_acesso = p_seq_acesso CLIPPED
         
         IF LENGTH(p_seq_acesso) = 0 THEN
            CONTINUE FOREACH
         END IF
         
         CALL sol0220_pega_chave()

         IF NOT sol0220_checa_tributo() THEN
            RETURN FALSE
         END IF
         
         IF p_ies_tributo THEN
            EXIT FOREACH
         END IF
         
      END FOREACH
      
      IF NOT p_ies_tributo THEN
         LET m_msg = m_msg CLIPPED, p_tributo_benef,"\n"
         LET p_sem_tributo = TRUE
      END IF

   END FOREACH
   
   IF p_sem_tributo THEN
      
      LET m_msg = m_msg CLIPPED,
                 "   Empresa: ", p_cod_empresa CLIPPED,"\n",
                 "   Nat oper: ", p_cod_nat_oper USING '<<<<<<<<&',"\n",
                 "   Carteira: ", p_cod_tip_carteira CLIPPED,"\n",
                 "   Finalidade: ", p_ies_finalidade CLIPPED,"\n",
                 "   Clas fisc: ", p_cod_cla_fisc CLIPPED,"\n",
                 "   Linha prod: ", p_cod_lin_prod USING '<<<<&',"\n",
                 "   Lin recei: ", p_cod_lin_recei USING '<<<<&',"\n",
                 "   Segto merc: ", p_cod_seg_merc USING '<<<<&',"\n",
                 "   Classe uso: ", p_cod_cla_uso USING '<<<<&',"\n",
                 "   Unid med: ", p_cod_unid_med CLIPPED,"\n",
                #"   Bonificação: ", p_pct_bonif CLIPPED,"\n",
                 "   Item: ", p_cod_item CLIPPED,"\n",
                 "   Cliente: ", p_cod_cliente CLIPPED,"\n"

      CALL log0030_mensagem(m_msg,'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION sol0220_pega_chave()
#----------------------------#

   DEFINE m_ind       SMALLINT,
          p_letra     CHAR(01),
          p_barra     INTEGER
   
   DELETE FROM chave_tmp_7662
   INITIALIZE p_chave TO NULL
   
   FOR m_ind = 2 TO LENGTH(p_seq_acesso)
       
       LET p_letra = p_seq_acesso[m_ind]
       
       IF p_letra = '|' THEN
          IF p_chave IS NOT NULL THEN
             INSERT INTO chave_tmp_7662 VALUES(p_chave)
             INITIALIZE p_chave TO NULL
          END IF
       ELSE
          LET p_chave = p_chave CLIPPED, p_letra
       END IF
         
   END FOR
      
END FUNCTION

#-------------------------------#
FUNCTION sol0220_checa_tributo()
#-------------------------------#

   DEFINE p_cheve_ok SMALLINT
   
   LET p_cheve_ok = FALSE

   LET p_query = 
       "SELECT trans_config FROM obf_config_fiscal ",
       " WHERE empresa = '",p_cod_empresa,"' ",
       " AND origem  = '",p_ies_tipo,"' ",
       " AND tributo_benef = '",p_tributo_benef,"' "
       

   DECLARE cq_chave CURSOR FOR
    SELECT chave
      FROM chave_tmp_7662
   
   FOREACH cq_chave INTO p_chave
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_chave')
         RETURN FALSE
      END IF
      
      LET p_cheve_ok = TRUE
      
      CASE p_chave
      
      WHEN 'NAT_OPER' 
         LET p_query  = p_query CLIPPED, 
          " AND (nat_oper_grp_desp  = '",p_cod_nat_oper,"' AND matriz[1] = 'N') "

      WHEN 'REGIAO' 
         IF sol0220_le_obf_regiao() THEN
            LET p_query  = p_query CLIPPED, 
             " AND (grp_fiscal_regiao = '",p_regiao_fiscal,"' AND matriz[2] = 'N') "
         END IF

      WHEN 'ESTADO'
         LET p_query  = p_query CLIPPED, 
          " AND (estado = '",p_cod_uni_feder,"' AND matriz[3] = 'N') "

      WHEN 'MUNICIPIO' 
         LET p_query  = p_query CLIPPED, 
          " AND (municipio = '",p_cod_cidade,"' AND matriz[4] = 'N') "

      WHEN 'CARTEIRA' 
         LET p_query  = p_query CLIPPED, 
          " AND (carteira = '",p_cod_tip_carteira,"' AND matriz[5] = 'N') "

      WHEN 'FINALIDADE' 
         LET p_query  = p_query CLIPPED, 
          " AND (finalidade = '",p_ies_finalidade,"' AND matriz[6] = 'N') "

      WHEN 'FAMILIA_IT' 
         LET p_query  = p_query CLIPPED, 
          " AND (familia_item = '",p_cod_familia,"' AND matriz[7] = 'N') "

      WHEN 'GRP_ESTOQUE' 
         LET p_query  = p_query CLIPPED, 
          " AND (grupo_estoque = '",p_gru_ctr_estoq,"' AND matriz[8] = 'N') "

      WHEN 'GRP_CLASSIF' 
         IF sol0220_le_obf_cl_fisc() THEN
            LET p_query  = p_query CLIPPED, 
             " AND (grp_fiscal_classif  = '",p_grp_classif_fisc,"' AND matriz[9] = 'N') "
         END IF

      WHEN 'CLAS_FISC' 
         LET p_query  = p_query CLIPPED, 
          " AND (classif_fisc = '",p_cod_cla_fisc,"' AND matriz[10] = 'N') "

      WHEN 'LIN_PROD' 
         LET p_query  = p_query CLIPPED, 
          " AND (linha_produto = '",p_cod_lin_prod,"' AND matriz[11] = 'N') "

      WHEN 'LIN_REC' 
         LET p_query  = p_query CLIPPED, 
          " AND (linha_receita = '",p_cod_lin_recei,"' AND matriz[12] = 'N') "

      WHEN 'SEGTO_MERC' 
         LET p_query  = p_query CLIPPED, 
          " AND (segmto_mercado = '",p_cod_seg_merc,"' AND matriz[13] = 'N') "

      WHEN 'CLASSE_USO' 
         LET p_query  = p_query CLIPPED, 
          " AND (classe_uso = '",p_cod_cla_uso,"' AND matriz[14] = 'N') "

      WHEN 'UNID_MED' 
         LET p_query  = p_query CLIPPED, 
          " AND (unid_medida = '",p_cod_unid_med,"' AND matriz[15] = 'N') "

      WHEN 'GRP_ITEM' 
         IF sol0220_le_obf_fisc_item() THEN
            LET p_query  = p_query CLIPPED, 
             " AND (grupo_fiscal_item = '",p_grp_fiscal_item,"' AND matriz[17] = 'N') "
         END IF

      WHEN 'ITEM' 
         LET p_query  = p_query CLIPPED, 
          " AND (item = '",p_cod_item,"' AND matriz[18] = 'N') "

      WHEN 'MICRO_EMPR' 
         LET p_query  = p_query CLIPPED, 
          " AND (micro_empresa = '",p_micro_empresa,"' AND matriz[19] = 'N') "

      WHEN 'GRP_CLIENTE' 
         IF p_tributo_benef = 'PIS_REC' OR p_tributo_benef = 'COFINS_REC' THEN
            LET p_query  = p_query CLIPPED, " AND incide = 'S' "
         ELSE
            IF sol0220_le_obf_fisc_cli() THEN
               LET p_query  = p_query CLIPPED, 
                " AND (grp_fiscal_cliente = '",p_grp_fisc_cliente,"' AND matriz[20] = 'N') "
            END IF
         END IF

      WHEN 'CLIENTE' 
         LET p_query  = p_query CLIPPED, 
          " (AND cliente = '",p_cod_cliente,"' AND matriz[21] = 'N') "

      WHEN 'X'
      WHEN 'BONIF'
      WHEN 'VIA_TRANSP'
      
      OTHERWISE 
         LET p_cheve_ok = FALSE
  
   END CASE
   
   END FOREACH

   IF p_cheve_ok THEN

      LET p_query  = p_query CLIPPED, " ORDER BY trans_config "
   
      PREPARE var_query FROM p_query   
      DECLARE cq_obf_cfg CURSOR FOR var_query

      FOREACH cq_obf_cfg INTO p_trans_config

         IF STATUS <> 0 THEN 
            CALL log003_err_sql('Lendo','cq_obf_cfg')
            RETURN FALSE
         END IF
      
         INSERT INTO tributo_tmp
          VALUES(p_tributo_benef, p_trans_config)
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','tributo_tmp')
            RETURN FALSE
         END IF
            
         LET p_ies_tributo = TRUE
         EXIT FOREACH
      
   
      END FOREACH
   
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION sol0220_le_obf_regiao()
#-------------------------------#

   LET p_regiao_fiscal = NULL

   SELECT regiao_fiscal
     INTO p_regiao_fiscal
     FROM obf_regiao_fiscal
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND municipio     = p_cod_cidade
   
   IF STATUS = 100 THEN
      SELECT regiao_fiscal
        INTO p_regiao_fiscal
        FROM obf_regiao_fiscal
       WHERE empresa       = p_cod_empresa
         AND tributo_benef = p_tributo_benef
         AND estado        = p_cod_uni_feder
      
      IF STATUS = 100 THEN
         LET p_regiao_fiscal = NULL
      END IF
   END IF
   
   IF p_regiao_fiscal IS NULL THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#-------------------------------#
FUNCTION sol0220_le_obf_cl_fisc()
#-------------------------------#

   LET p_grp_classif_fisc = NULL
   
   SELECT grupo_classif_fisc
     INTO p_grp_classif_fisc
     FROM obf_grp_cl_fisc
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND classif_fisc  = p_cod_cla_fisc
   
   IF STATUS <> 0 OR p_grp_classif_fisc IS NULL THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------------#
FUNCTION sol0220_le_obf_fisc_item()
#---------------------------------#

   LET p_grp_fiscal_item = NULL
   
   SELECT grupo_fiscal_item
     INTO p_grp_fiscal_item
     FROM obf_grp_fisc_item
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND item          = p_cod_item
   
   IF STATUS <> 0 OR p_grp_fiscal_item IS NULL THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------------#
FUNCTION sol0220_le_obf_fisc_cli()
#---------------------------------#

   LET p_grp_fisc_cliente = NULL
   
   SELECT grp_fiscal_cliente
     INTO p_grp_fisc_cliente
     FROM obf_grp_fisc_cli
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND cliente       = p_cod_cliente
   
   IF STATUS <> 0 OR p_grp_fisc_cliente IS NULL THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#----------------------------#
FUNCTION sol0220_le_formula()
#----------------------------#

   DEFINE p_tip_config CHAR(01),
          p_achou      SMALLINT,
          p_origem     CHAR(01)
   
   LET p_achou = FALSE   
   
   DECLARE cq_obf_trib CURSOR FOR
    SELECT tip_config
      FROM obf_tributo_benef 
     WHERE empresa = p_cod_empresa
       AND tributo_benef = 'IPI'
   
   FOREACH cq_obf_trib INTO p_tip_config
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'obf_tributo_benef')
         RETURN FALSE
      END IF
      
      LET p_achou = TRUE
      EXIT FOREACH
   
   END FOREACH
   
   IF NOT p_achou THEN
      LET p_trans_ipi = 0
      RETURN TRUE
   END IF
   
   SELECT origem 
     INTO p_origem
     FROM obf_fml_trib_benef
    WHERE empresa = p_cod_empresa 
      AND tributo_benef = 'IPI' 
      AND formula = 3
   
   IF STATUS <> 0 THEN
      LET p_origem = 'S'
   END IF
   
   LET p_achou = FALSE
   
   DECLARE cq_conf_fisc CURSOR FOR      
    SELECT trans_config,
           val_unit
      FROM obf_config_fiscal
     WHERE empresa       = p_cod_empresa
       AND tributo_benef = 'IPI'
       AND origem        = p_origem
       AND formula       = 3

   FOREACH cq_conf_fisc INTO p_trans_ipi, p_val_unit_ipi
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','obf_config_fiscal')
         RETURN FALSE
      END IF
      
      LET p_achou = TRUE
      EXIT FOREACH
   
   END FOREACH
   
   IF NOT p_achou THEN
      LET p_trans_ipi = 0
   END IF
      
   RETURN TRUE
   
END FUNCTION   
