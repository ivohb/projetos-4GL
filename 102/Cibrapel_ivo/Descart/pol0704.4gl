#------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                            #
# PROGRAMA: pol0704                                                #
# MODULOS.: pol0704 - LOG0010 - LOG0030 - LOG9960 - LOG0060        #
#           LOG0280 - LOG1300 - LOG1400                            #
# OBJETIVO: IMPRESSAO DE NOTAS FISCAIS DE ENTRADA (CIBRAPEL)       #
# AUTOR...: POLO INFORMATICA                                       #
# DATA....: 21/12/2007                                             #
# ALTERADO: 26/12/2007 por ANA PAULA - versao 01                   #
#------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          p_nom_arquivo            CHAR(100),
          p_ies_impressao          CHAR(01),
          p_caminho                CHAR(080),
          comando                  CHAR(80),
          g_ies_ambiente           CHAR(001),
          p_par_val                SMALLINT,
          #p_texto1                 CHAR(75),
          #p_texto2                 CHAR(75),
          p_controle               SMALLINT,
          p_ind                    SMALLINT,
          p_den_texto              CHAR(120),
          p_cod_clas_fisc          CHAR(10),
          p_num_item               CHAR(01),
          p_cod_ref_clas           CHAR(01),
          p_num_seq                SMALLINT
           
   DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

   DEFINE p_dat_ult_fat            DATE,
          p_dat_fat_numero         DATE,
          p_ies_nfe_emit           CHAR(01),
          p_cod_operacao           CHAR(06),
          p_cod_fiscal             CHAR(06),
          p_cod_cla_h              CHAR(10),
          p_cod_cla_i              CHAR(10),
          p_cod_fiscal_compl       INTEGER, 
          p_cont_dados             SMALLINT,
          p_contador               SMALLINT,
          p_cont_fisc              SMALLINT,
          p_des_texto              CHAR(120),
          p_des_texto1             LIKE texto_nf.des_texto,
          p_des_texto2             LIKE texto_nf.des_texto,
          p_ies_informou           SMALLINT,
          p_atualiza               SMALLINT,
          p_qtd_linhas_dispon      INTEGER,
          p_cod_texto              LIKE texto_nf.cod_texto,
          p_num_aviso_rec          LIKE nf_sup.num_aviso_rec,
          p_ser_nf                 LIKE nf_sup.ser_nf,
          p_ssr_nf                 LIKE nf_sup.ssr_nf,
          p_num_ar_ini             LIKE aviso_rec.num_aviso_rec,     
          p_num_ar_fim             LIKE aviso_rec.num_aviso_rec,     
          p_nr_aviso_rec           LIKE nf_sup.num_aviso_rec,
          p_ies_num_nf_vdp         LIKE par_sup_pad.par_ies,
          p_num_nf                 LIKE nf_sup.num_nf,
          p_par_sup_pad            RECORD LIKE par_sup_pad.*,
          p_fiscal_par             RECORD LIKE fiscal_par.*,
          p_nf_sup                 RECORD LIKE nf_sup.*,
          p_nfe_sup_compl          RECORD LIKE nfe_sup_compl.*,
          p_aviso_rec              RECORD LIKE aviso_rec.*

   DEFINE p_clas_fisc              RECORD
          denominacao              CHAR(10),
          percentual               CHAR(02)
                                  END RECORD 	
 
   DEFINE p_clas_fisc_temp         RECORD
          cod_cla_fisc             CHAR(010),
          num_item                 DECIMAL(1,0)
                                  END RECORD 	

   DEFINE p_cidades                RECORD LIKE cidades.*,
          p_embalagem              RECORD LIKE embalagem.*,
          p_fornecedor             RECORD LIKE fornecedor.*,
          p_transport              RECORD LIKE transport.*,
          p_subst_trib_uf          RECORD LIKE subst_trib_uf.*
 
   DEFINE p_nff                    RECORD
             num_nff                  LIKE wfat_mestre_ent.num_nff,
             den_nat_oper             LIKE nat_operacao.den_nat_oper,
             cod_fiscal               CHAR(06),
             cod_fiscal_compl         LIKE aviso_rec_compl.cod_fiscal_compl,
             num_di                   LIKE aviso_rec_compl.num_di,
             ins_estadual_trib        LIKE subst_trib_uf.ins_estadual,
             nom_destinatario         LIKE clientes.nom_cliente,
             num_cgc_cpf              LIKE clientes.num_cgc_cpf,
             dat_emissao              LIKE wfat_mestre_ent.dat_emissao,
             end_destinatario         LIKE clientes.end_cliente,
             den_bairro               LIKE clientes.den_bairro,
             cod_cep                  LIKE clientes.cod_cep,
             dat_entrada_saida        LIKE wfat_mestre_ent.dat_emissao,
             den_cidade               LIKE cidades.den_cidade,
             num_telefone             LIKE clientes.num_telefone,
             cod_uni_feder            LIKE cidades.cod_uni_feder,
             ins_estadual             LIKE clientes.ins_estadual,
             hora_saida               DATETIME HOUR TO MINUTE,

   { Corpo da nota contendo os itens da mesma. Pode conter ate 999 itens }

             val_tot_base_icm         LIKE wfat_mestre_ent.val_tot_base_icm,
             val_tot_icm              LIKE wfat_mestre_ent.val_tot_icm,
             val_tot_base_ret         LIKE wfat_mestre_ent.val_tot_base_ret,
             val_tot_icm_ret          LIKE wfat_mestre_ent.val_tot_icm_ret,
             val_tot_mercadoria       LIKE wfat_mestre_ent.val_tot_mercadoria,
             val_tot_frete            LIKE wfat_mestre_ent.val_tot_frete,
             val_tot_seguro           LIKE wfat_mestre_ent.val_tot_seguro,
             val_tot_despesas         LIKE wfat_mestre_ent.val_tot_seguro,
             val_tot_ipi              LIKE wfat_mestre_ent.val_tot_ipi,
             val_tot_nff              LIKE wfat_mestre_ent.val_tot_nff,
             nom_transpor             LIKE clientes.nom_cliente,
             ies_frete                LIKE wfat_mestre_ent.ies_frete,
             num_placa                LIKE wfat_mestre_ent.num_placa,
             cod_uni_feder_trans      LIKE cidades.cod_uni_feder,
             num_cgc_trans            LIKE clientes.num_cgc_cpf,
             end_transpor             LIKE clientes.end_cliente,
             den_cidade_trans         LIKE cidades.den_cidade,
             ins_estadual_trans       LIKE clientes.ins_estadual,
             qtd_volume               LIKE wfat_mestre_ent.qtd_volumes1,
             des_especie              CHAR(035),
             den_marca                LIKE clientes.den_marca,
             pes_tot_bruto            LIKE wfat_mestre_ent.pes_tot_bruto,
             pes_tot_liquido          LIKE wfat_mestre_ent.pes_tot_liquido
                                   END RECORD

   DEFINE pa_corpo_nff             ARRAY[999] OF RECORD
             cod_item                 LIKE wfat_item_ent.cod_item,
             num_pedido               LIKE wfat_item_ent.num_pedido,
             den_item1                CHAR(050),
           # den_item2                CHAR(043),
             cod_cla_fisc             CHAR(010),
             cod_origem               LIKE wfat_mestre_ent.cod_origem,
             cod_tributacao           LIKE tributacao.cod_tributacao,
             cod_unid_med             LIKE wfat_item_ent.cod_unid_med,
             qtd_item                 LIKE wfat_item_ent.qtd_item,
             peso_liq                 DECIMAL(10,5),
             pre_unit                 LIKE wfat_item_ent.pre_unit_nf,
             val_liq_item             LIKE wfat_item_ent.val_liq_item,
             pct_icm                  LIKE wfat_mestre_ent.pct_icm,
             pct_ipi                  LIKE wfat_item_ent.pct_ipi,
             val_ipi                  LIKE wfat_item_ent.val_ipi
                                   END RECORD

   DEFINE p_dados_nota             RECORD
             num_seq                  SMALLINT,
             ies_tip_info             SMALLINT,
             cod_item                 LIKE wfat_item.cod_item,
             den_item                 CHAR(65),
             cod_cla_fisc             CHAR(010),
             cod_origem               LIKE wfat_mestre_ent.cod_origem,
             cod_tributacao           LIKE tributacao.cod_tributacao,
             cod_unid_med             LIKE wfat_item_ent.cod_unid_med,
             qtd_item                 LIKE wfat_item_ent.qtd_item,
             peso_liq                 DECIMAL(10,5),
             pre_unit                 LIKE wfat_item_ent.pre_unit_nf,
             val_liq_item             LIKE wfat_item_ent.val_liq_item,
             pct_icm                  LIKE wfat_mestre_ent.pct_icm,
             pct_ipi                  LIKE wfat_item_ent.pct_ipi,
             val_ipi                  LIKE wfat_item_ent.val_ipi,
             des_texto                CHAR(120),
             num_nff                  LIKE wfat_mestre_ent.num_nff
                                   END RECORD

   DEFINE p_consignat              RECORD
             den_consignat            LIKE clientes.nom_cliente,
             end_consignat            LIKE clientes.end_cliente,
             den_bairro               LIKE clientes.den_bairro,
             den_cidade               LIKE cidades.den_cidade,
             cod_uni_feder            LIKE cidades.cod_uni_feder
                                   END RECORD

   DEFINE p_comprime               CHAR(01),
          p_descomprime            CHAR(01),
          p_6lpp                   CHAR(02),
          p_8lpp                   CHAR(02)

   DEFINE pa_historico             ARRAY[08] OF RECORD
          texto                    CHAR(150)
                                   END RECORD

   DEFINE pa_texto                 ARRAY[12] OF RECORD
          texto                    CHAR(150)
                                   END RECORD

   DEFINE p_txt                    ARRAY[24] OF RECORD
          texto                    CHAR(53)
          END RECORD
          
   DEFINE p_textos                 RECORD
          texto1                   CHAR(120),
          texto2                   CHAR(120),
          texto3                   CHAR(120),
          texto4                   CHAR(120),
          texto5                   CHAR(120),
          texto6                   CHAR(120),
          texto7                   CHAR(120),
          texto8                   CHAR(120),
          texto9                   CHAR(120),
          texto10                  CHAR(120),
          texto11                  CHAR(120),
          texto12                  CHAR(120)
                                   END RECORD

   DEFINE p_texto1               CHAR(55), 
          p_texto2               CHAR(55),
          p_texto3               CHAR(55)


   DEFINE p_num_linhas             SMALLINT,
          p_num_pagina             SMALLINT,
          p_tot_paginas            SMALLINT,
          p_houve_consig           SMALLINT,
          p_ies_lista              SMALLINT,
          p_linhas_print           SMALLINT,
          p_ies_termina_relat      SMALLINT,
          p_vol_item               DECIMAL(9,3),
          p_vol_nf                 DECIMAL(9,3)

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0704-05.10.07" 
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP

   DEFER INTERRUPT

   CALL log140_procura_caminho("pol.iem") RETURNING comando
   OPTIONS
      FIELD ORDER UNCONSTRAINED,
      HELP FILE comando

   CALL log001_acessa_usuario("SUPRIMEN","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL pol0704_controle()
   END IF
END MAIN

#---------------------------#
 FUNCTION pol0704_controle()
#---------------------------#
   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0704") RETURNING comando    

   OPEN WINDOW w_pol0704 AT 2,2  WITH FORM comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parametros"
         HELP 2926
         MESSAGE ""
         CALL pol0704_inicializa_campos()
         IF log005_seguranca(p_user,"SUPRIMEN","pol0704","CO") THEN
            LET p_ies_informou = FALSE
            IF pol0704_entrada_parametros() THEN
               NEXT OPTION "Listar"
            END IF
         END IF
      COMMAND "Listar" "Lista as Notas Fiscais de Entrada"
         HELP 2927
         IF log005_seguranca(p_user,"SUPRIMEN","pol0704","CO") THEN
            IF p_ies_informou THEN
               IF pol0704_imprime_nff() THEN
                  NEXT OPTION "Fim"
               END IF 
            ELSE
               ERROR "Informe os Parametros para Listar"
               NEXT OPTION "Informar"
            END IF
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 509
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0704

END FUNCTION

#------------------------------------#
 FUNCTION pol0704_entrada_parametros()
#------------------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0704

   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_num_ar_ini, p_num_ar_fim, p_dat_fat_numero TO NULL
   INITIALIZE p_nff.*, p_nf_sup.* TO NULL

   CALL pol0704_busca_par_sup_pad("ies_num_nf_entrada")

   IF p_par_sup_pad.par_ies IS NOT NULL THEN
      LET p_ies_num_nf_vdp = p_par_sup_pad.par_ies
      LET p_num_nf         = p_par_sup_pad.par_val - 1
   ELSE
      LET p_ies_num_nf_vdp = "N"
      LET p_num_nf         = 0 
   END IF

   INPUT BY NAME p_num_ar_ini,
                 p_num_ar_fim,
                 p_dat_fat_numero WITHOUT DEFAULTS 

 
     AFTER FIELD p_num_ar_ini
         IF p_num_ar_ini IS NOT NULL THEN
            IF pol0704_verifica_aviso_rec(p_num_ar_ini) = FALSE THEN
               ERROR "Aviso de recebimento nao cadastrado na nota fiscal do suprimentos."
               NEXT FIELD p_num_ar_ini
            END IF
         ELSE
            ERROR "Informe o numero de aviso de recebimento "
            NEXT FIELD p_num_ar_ini
         END IF
      
      AFTER FIELD p_num_ar_fim
         IF p_num_ar_ini IS NOT NULL THEN
            IF p_num_ar_fim < p_num_ar_ini THEN
               ERROR " A.R. final menor que A.R. inicial "
               NEXT FIELD p_num_ar_fim
            END IF

            IF pol0704_verifica_aviso_rec(p_num_ar_fim) = FALSE THEN
               ERROR "Aviso de recebimento nao cadastrado na nota fiscal do suprimentos."
               NEXT FIELD p_num_ar_fim
            END IF
         ELSE
            ERROR "Informe o numero de aviso de recebimento "
            NEXT FIELD p_num_ar_fim   
         END IF
  
      BEFORE FIELD p_dat_fat_numero
         IF p_ies_num_nf_vdp = "N" THEN
            EXIT INPUT
         END IF  

      AFTER FIELD p_dat_fat_numero
         IF p_ies_num_nf_vdp = "S" THEN
            CALL pol0704_busca_num_nf_vdp()

            IF p_dat_fat_numero IS NULL THEN
               ERROR " Informe a data do ultimo faturamento "
               NEXT FIELD p_dat_fat_numero 
            ELSE
               IF p_dat_ult_fat > p_dat_fat_numero THEN
                  ERROR "Data informada nao pode ser menor que a data do ult. fat."
                  NEXT FIELD p_dat_fat_numero 
               END IF  

               IF p_dat_fat_numero > TODAY THEN
                  ERROR "Data informada nao pode ser maior que atual"
                  NEXT FIELD p_dat_fat_numero
               END IF             
            END IF
         END IF
  
      ON KEY(control-w,f1)
         CALL pol0704_help()
  
   
   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0704
        
   IF int_flag THEN
      LET int_flag = 0
      CLEAR FORM
      LET p_status = FALSE
      RETURN FALSE
   ELSE
      LET p_ies_informou = TRUE
      LET p_status = TRUE
      RETURN TRUE
   END IF
END FUNCTION

#---------------------------------------------------#
 FUNCTION pol0704_busca_par_sup_pad(p_cod_parametro)
#---------------------------------------------------#
 DEFINE p_cod_parametro LIKE par_sup_pad.cod_parametro 

   INITIALIZE p_par_sup_pad.* TO NULL

   SELECT *
     INTO p_par_sup_pad.*
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = p_cod_parametro

END FUNCTION

#---------------------------------------------#
 FUNCTION pol0704_verifica_aviso_rec(p_num_ar)
#---------------------------------------------#
 DEFINE p_num_ar LIKE aviso_rec.num_aviso_rec

   DECLARE cq_ver_aviso_rec  CURSOR FOR
    SELECT *
      FROM aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_ar

   OPEN cq_ver_aviso_rec
   FETCH cq_ver_aviso_rec
   IF sqlca.sqlcode <> 0 THEN
      CLOSE cq_ver_aviso_rec 
      RETURN FALSE
   ELSE
      CLOSE cq_ver_aviso_rec 
      RETURN TRUE
   END IF
END FUNCTION

#-----------------------------------#
 FUNCTION pol0704_busca_num_nf_vdp()
#-----------------------------------#

   CALL log085_transacao("BEGIN") 
#  BEGIN WORK 

   SELECT num_nff, dat_ult_fat
      INTO p_num_nf, p_dat_ult_fat
   FROM fat_numero
   WHERE cod_empresa = p_cod_empresa

   IF SQLCA.SQLCODE = 0 THEN
      CALL log085_transacao("COMMIT") 
   #  COMMIT WORK
   ELSE
      CALL log085_transacao("ROLLBACK") 
   #  ROLLBACK WORK
   END IF
END FUNCTION

#-----------------------#
 FUNCTION pol0704_help()
#-----------------------#
   CASE
      WHEN infield(p_num_ar_ini)            CALL showhelp(3099) 
      WHEN infield(p_num_ar_fim)            CALL showhelp(3100)
      WHEN infield(p_dat_fat_numero)        CALL showhelp(3101)
   END CASE
END FUNCTION

#------------------------------#
 FUNCTION pol0704_imprime_nff()
#------------------------------#

   DEFINE sql_stmt CHAR(1000)

   CALL pol0704_busca_par_sup_pad("ser_ssr_nf_entrada")

   LET p_ser_nf = p_par_sup_pad.par_txt
   LET p_ssr_nf = p_par_sup_pad.par_val 

   IF p_ser_nf IS NULL OR 
      p_ssr_nf IS NULL THEN
      ERROR " Parametros de Serie/SubSerie nao cadastrados. "
      SLEEP 5
      RETURN FALSE
   END IF

   LET p_qtd_linhas_dispon = 19
 
   IF log028_saida_relat(14,34) IS NOT NULL THEN
      MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
       
    IF p_ies_impressao = "S" THEN
         IF g_ies_ambiente = "W" THEN
            CALL log150_procura_caminho("LST") RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, "pol0704.tmp"
            START REPORT pol0704_relat TO p_caminho
         ELSE
            START REPORT pol0704_relat TO PIPE p_nom_arquivo
         END IF 
      ELSE
         START REPORT pol0704_relat TO p_nom_arquivo
      END IF
  
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN") 
   #  BEGIN WORK
#      LOCK TABLE t_pol0704 IN EXCLUSIVE MODE
      CALL log085_transacao("COMMIT") 
   #  COMMIT WORK
      CALL sup997_cria_t_pol0704()
      WHENEVER ERROR STOP

      INITIALIZE  p_nr_aviso_rec TO NULL

      DECLARE cq_nf_sup_temp CURSOR FOR
      SELECT num_aviso_rec 
      FROM nf_sup
      WHERE cod_empresa = p_cod_empresa
        AND num_aviso_rec BETWEEN p_num_ar_ini AND p_num_ar_fim
        AND nf_sup.ies_nf_aguard_nfe IN ("6", "X")

      FOREACH cq_nf_sup_temp INTO p_nr_aviso_rec
         INSERT INTO t_pol0704 VALUES (p_nr_aviso_rec)
      END FOREACH

      CALL log085_transacao("BEGIN") 
   #  BEGIN WORK
    
      LET p_atualiza = FALSE

{      IF p_ies_num_nf_vdp = "S" THEN
         WHENEVER ERROR CONTINUE
         SET LOCK MODE TO WAIT 180
         LOCK TABLE fat_numero IN EXCLUSIVE MODE    
         WHENEVER ERROR STOP
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR " Tabela FAT_NUMERO esta sendo atualizada por outro usuario"
            CALL log085_transacao("ROLLBACK") 
         #  ROLLBACK WORK 
            RETURN TRUE 
         END IF
      ELSE
         WHENEVER ERROR CONTINUE
         SET LOCK MODE TO WAIT 180
         LOCK TABLE par_sup_pad IN EXCLUSIVE MODE  
         WHENEVER ERROR STOP
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR " Tabela PAR_SUP_PAD  esta sendo atualizada por outro usuario"
            CALL log085_transacao("ROLLBACK") 
         #  ROLLBACK WORK
            RETURN TRUE 
         END IF
      END IF
 }     
      IF pol0704_imprime_relat() = FALSE THEN
         CALL log085_transacao("ROLLBACK") 
      #  ROLLBACK WORK
         RETURN TRUE
      ELSE
         IF p_atualiza THEN
            IF p_ies_num_nf_vdp = "S" THEN
               IF pol0704_atualiza_fat_numero() = FALSE THEN
                  CALL log085_transacao("ROLLBACK") 
               #  ROLLBACK WORK
                  RETURN FALSE
               END IF
            ELSE
               IF pol0704_atualiza_par_sup_pad() = FALSE THEN
                  CALL log085_transacao("ROLLBACK") 
               #  ROLLBACK WORK
                  RETURN FALSE
               END IF
            END IF
         END IF
      END IF

      CALL log085_transacao("COMMIT") 
   #  COMMIT WORK

      IF SQLCA.SQLCODE <> 0 THEN
         ERROR " Erro ",sqlca.sqlcode," na efetivacao dos dados."
         CALL log085_transacao("ROLLBACK") 
      #  ROLLBACK WORK
         RETURN FALSE
      END IF
      FINISH REPORT pol0704_relat
      IF g_ies_ambiente  = "W" AND
         p_ies_impressao = "S" THEN
         LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
         RUN comando
      END IF 
 
      IF p_ies_lista THEN
         IF p_ies_impressao = "S" THEN
            MESSAGE "Relatorio impresso na impressora ", p_nom_arquivo
                     ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Relatorio gravado no arquivo ", p_nom_arquivo
                     ATTRIBUTE(REVERSE)
         END IF
         ERROR " Fim de processamento ..."  
      ELSE
         MESSAGE ""
         ERROR " Nao existem dados para serem listados. "
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol0704_imprime_relat()
#--------------------------------#
   DECLARE cq_nf_sup CURSOR WITH HOLD FOR 
    SELECT num_aviso_rec FROM t_pol0704 ORDER BY num_aviso_rec

   OPEN cq_nf_sup
   FETCH cq_nf_sup INTO p_num_aviso_rec
   WHILE sqlca.sqlcode = 0
  
    # *** reimpressao *** 
      INITIALIZE  p_ies_nfe_emit TO NULL 
 
      SELECT ies_nfe_emit
        INTO p_ies_nfe_emit
        FROM nfe_sup_compl
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso_rec 

      IF p_ies_nfe_emit = "S" THEN
         CALL pol0704_imprime_dados() 
      ELSE
         LET p_atualiza = TRUE
         LET p_num_nf = p_num_nf + 1 

         CALL pol0704_imprime_dados() 

         IF pol0704_deleta_nf_sup_erro()= FALSE THEN
            RETURN FALSE
         END IF

         IF pol0704_modifica_nfe_sup_compl() = FALSE THEN
            RETURN FALSE
         END IF

         IF pol0704_atualiza_nf_sup() = FALSE THEN
            RETURN FALSE
         END IF    
      END IF
      FETCH cq_nf_sup INTO p_num_aviso_rec
   END WHILE

   RETURN TRUE
END FUNCTION

#--------------------------------------#
 FUNCTION pol0704_atualiza_fat_numero()
#--------------------------------------#
   UPDATE fat_numero SET num_nff     = (p_num_nf),
                         dat_ult_fat = p_dat_fat_numero
    WHERE fat_numero.cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("ATUALIZA","FAT_NUMERO")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0704_atualiza_par_sup_pad()
#---------------------------------------#
   UPDATE par_sup_pad SET par_val = p_num_nf + 1
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "ies_num_nf_entrada"

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("ATUALIZA","PAR_SUP_PAD")
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
END FUNCTION
 
#----------------------------------#
 FUNCTION pol0704_atualiza_nf_sup()
#----------------------------------#
   WHENEVER ERROR CONTINUE
   UPDATE nf_sup SET (num_nf  , ser_nf  , ssr_nf) = 
                     (p_num_nf, p_ser_nf, p_ssr_nf)
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec   
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("ATUALIZA","NF_SUP")
      RETURN FALSE
   END IF
  
   RETURN TRUE
END FUNCTION

#-------------------------------------#
 FUNCTION pol0704_deleta_nf_sup_erro()
#-------------------------------------#
   DELETE FROM nf_sup_erro 
    WHERE num_aviso_rec      = p_num_aviso_rec
      AND des_pendencia_item = "Falta imprimir NFE"

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETA","NF_SUP_ERRO")
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#------------------------------------#
 FUNCTION pol0704_inicializa_campos()
#------------------------------------#
   INITIALIZE p_transport.*    , p_nff.*   , pa_corpo_nff , p_consignat.* , 
              p_embalagem.*    , pa_texto  , p_cidades.*  , p_fornecedor.*, 
              p_subst_trib_uf.*, p_textos.*, p_clas_fisc.*  TO NULL
 
   LET p_houve_consig      = FALSE
   LET p_linhas_print      = 0
   LET p_vol_item          = 0
   LET p_vol_nf            = 0
   LET p_cont_fisc         = 0
   LET p_ies_termina_relat = TRUE
END FUNCTION

#--------------------------------#
 FUNCTION pol0704_imprime_dados()
#--------------------------------#
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_8lpp        = ascii 27, "0"
   LET p_6lpp        = ascii 27, "2"

   INITIALIZE p_cod_cla_h, p_cod_cla_i TO NULL
   
   DECLARE cq_nf_sup_mst CURSOR WITH HOLD FOR
    SELECT * FROM nf_sup
     WHERE cod_empresa           = p_cod_empresa
       AND num_aviso_rec         = p_num_aviso_rec
       AND nf_sup.ies_nf_aguard_nfe IN ("6", "X")

   FOREACH cq_nf_sup_mst INTO p_nf_sup.*

      IF p_ies_nfe_emit = "S" THEN
         LET p_nff.num_nff = p_nf_sup.num_nf
      ELSE 
         LET p_nff.num_nff = p_num_nf
      END IF

      CALL pol0704_cria_tabela_temporaria()
      CALL pol0704_busca_dados_compl()

      LET p_cod_operacao = p_nf_sup.cod_operacao[1,1],
                           p_nf_sup.cod_operacao[2,7]
 
      IF p_cod_operacao[1] = "5" THEN
         LET p_nff.cod_fiscal = "1",p_cod_operacao[2,6]
      END IF

      IF p_cod_operacao[1] = "6" THEN
         LET p_nff.cod_fiscal = "2",p_cod_operacao[2,6]
      END IF

      IF p_cod_operacao[1] = "7" THEN
         DECLARE cq_cfi CURSOR FOR
          SELECT cod_fiscal_item
            FROM aviso_rec
           WHERE cod_empresa   = p_cod_empresa
             AND num_aviso_rec = p_num_aviso_rec
         FOREACH cq_cfi INTO p_nff.cod_fiscal
            EXIT FOREACH
         END FOREACH
         
         #LET p_nff.cod_fiscal = "3",p_cod_operacao[2,6]
      END IF

      LET p_nff.den_nat_oper = pol0704_den_nat_oper()

      LET p_nff.cod_fiscal = p_nff.cod_fiscal[1,1], p_nff.cod_fiscal[3,6]

      SELECT cod_fiscal_compl,
             num_di
         INTO p_cod_fiscal_compl,
              p_nff.num_di
      FROM aviso_rec_compl
      WHERE cod_empresa = p_cod_empresa
        AND num_aviso_rec = p_num_aviso_rec

      IF SQLCA.SQLCODE = 0 THEN
         LET p_nff.cod_fiscal_compl = p_cod_fiscal_compl
      END IF

      CALL pol0704_busca_dados_subst_trib_uf()

      LET p_nff.ins_estadual_trib = p_subst_trib_uf.ins_estadual
      LET p_nff.dat_emissao       = p_nf_sup.dat_emis_nf
      LET p_nff.dat_entrada_saida = p_nf_sup.dat_entrada_nf

      CALL pol0704_busca_dados_fornec(p_nf_sup.cod_fornecedor)

      LET p_nff.nom_destinatario = p_fornecedor.raz_social
      LET p_nff.num_cgc_cpf      = p_fornecedor.num_cgc_cpf
      LET p_nff.end_destinatario = p_fornecedor.end_fornec
      LET p_nff.den_bairro       = p_fornecedor.den_bairro
      LET p_nff.cod_cep          = p_fornecedor.cod_cep
      LET p_nff.num_telefone     = p_fornecedor.num_telefone
      LET p_nff.ins_estadual     = p_fornecedor.ins_estadual
  
      CALL pol0704_busca_dados_cidades(p_fornecedor.cod_cidade)
      LET p_nff.den_cidade       = p_cidades.den_cidade[1,21]
      LET p_nff.cod_uni_feder    = p_cidades.cod_uni_feder
      LET p_nff.hora_saida       = EXTEND(CURRENT, HOUR TO MINUTE)

      # soma nos itens

      LET p_nff.val_tot_base_icm   = 0
      LET p_nff.val_tot_mercadoria = 0
      LET p_nff.pes_tot_bruto      = 0
      LET p_nff.pes_tot_liquido    = 0

      CALL pol0704_carrega_corpo_nff()  {le os itens pertencentes a nf}

      CALL pol0704_carrega_tabela_temporaria() {sera o corpo todo da nota}

      CALL pol0704_calcula_total_de_paginas()

# imprime base de calculo
      IF p_nf_sup.val_bc_subst_d > 0 THEN
         LET p_nff.val_tot_base_ret   = p_nf_sup.val_bc_subst_d
      ELSE
         LET p_nff.val_tot_base_ret   = p_nf_sup.val_bc_subst_c
      END IF

      IF p_nf_sup.val_icms_subst_d > 0 THEN
         LET p_nff.val_tot_icm_ret    = p_nf_sup.val_icms_subst_d
      ELSE
         LET p_nff.val_tot_icm_ret    = p_nf_sup.val_icms_subst_c
      END IF

      SELECT parametro_val
         INTO p_nff.val_tot_frete
      FROM sup_par_ar
      WHERE empresa = p_cod_empresa
        AND aviso_recebto = p_num_aviso_rec
        AND seq_aviso_recebto = 0
        AND parametro = "val_frete"

      SELECT parametro_val
         INTO p_nff.val_tot_seguro
      FROM sup_par_ar
      WHERE empresa = p_cod_empresa
        AND aviso_recebto = p_num_aviso_rec
        AND seq_aviso_recebto = 0
        AND parametro = "val_seguro"

      LET p_nff.val_tot_despesas = p_nf_sup.val_despesa_aces

      IF p_nf_sup.val_tot_icms_nf_d > 0 THEN
         LET p_nff.val_tot_icm = p_nf_sup.val_tot_icms_nf_d
      ELSE
         LET p_nff.val_tot_icm = p_nf_sup.val_tot_icms_nf_c
      END IF

      IF p_nf_sup.val_ipi_nf > 0 THEN
         LET p_nff.val_tot_ipi = p_nf_sup.val_ipi_nf
      ELSE
         LET p_nff.val_tot_ipi = p_nf_sup.val_ipi_calc
      END IF

      IF p_nf_sup.val_tot_nf_d > 0 THEN
         LET p_nff.val_tot_nff = p_nf_sup.val_tot_nf_d
      ELSE
         LET p_nff.val_tot_nff = p_nf_sup.val_tot_nf_c
      END IF

      IF p_nf_sup.cod_transpor IS NOT NULL AND
         p_nf_sup.cod_transpor <> " " THEN
         CALL pol0704_busca_dados_transport(p_nf_sup.cod_transpor)
         CALL pol0704_busca_dados_cidades(p_transport.cod_cidade)
         LET p_nff.nom_transpor = p_transport.den_transpor  
      END IF

      IF p_nff.nom_transpor IS NULL OR
         p_nff.nom_transpor = " " THEN
         SELECT den_transpor,
                num_placa_veic
            INTO p_nff.nom_transpor,
                 p_nff.num_placa
         FROM aviso_rec_compl
         WHERE cod_empresa = p_cod_empresa
           AND num_aviso_rec = p_num_aviso_rec
      END IF

      LET p_nff.ies_frete           = 1
      LET p_nff.num_cgc_trans[1,3]  = p_transport.num_cgc[1,3]
      LET p_nff.num_cgc_trans[4,6]  = p_transport.num_cgc[5,7]
      LET p_nff.num_cgc_trans[7,9]  = p_transport.num_cgc[9,11]
      LET p_nff.num_cgc_trans[10,13] = p_transport.num_cgc[13,16]
      LET p_nff.num_cgc_trans[14,15] = p_transport.num_cgc[18,19]
      LET p_nff.end_transpor        = p_transport.end_transpor
      LET p_nff.den_cidade_trans    = p_cidades.den_cidade
      LET p_nff.cod_uni_feder_trans = p_cidades.cod_uni_feder
      LET p_nff.ins_estadual_trans  = p_transport.ins_estadual
      LET p_nff.qtd_volume          = p_nfe_sup_compl.qtd_volumes
      LET p_nff.den_marca           = "         "
      LET p_nff.pes_tot_bruto       = p_nfe_sup_compl.peso_bruto
      LET p_nff.pes_tot_liquido     = p_nfe_sup_compl.peso_liquido

{     IF p_nff.val_tot_base_icm = 0 THEN
         LET p_nff.val_tot_base_icm = NULL
      END IF
      IF p_nff.val_tot_icm = 0 THEN
         LET p_nff.val_tot_icm = NULL
      END IF
      IF p_nff.val_tot_base_ret = 0 THEN
         LET p_nff.val_tot_base_ret = NULL
      END IF
      IF p_nff.val_tot_icm_ret = 0 THEN
         LET p_nff.val_tot_icm_ret = NULL
      END IF
      IF p_nff.val_tot_mercadoria = 0 THEN
         LET p_nff.val_tot_mercadoria = NULL   
      END IF
      IF p_nff.val_tot_frete = 0 THEN
         LET p_nff.val_tot_frete = NULL
      END IF
      IF p_nff.val_tot_seguro = 0 THEN
         LET p_nff.val_tot_seguro = NULL
      END IF
      IF p_nff.val_tot_despesas = 0 THEN
         LET p_nff.val_tot_despesas = NULL
      END IF
      IF p_nff.val_tot_ipi = 0 THEN
         LET p_nff.val_tot_ipi = NULL
      END IF
      IF p_nff.val_tot_nff = 0 THEN
         LET p_nff.val_tot_nff = NULL
      END IF
      IF p_nff.pes_tot_bruto = 0 THEN
         LET p_nff.pes_tot_bruto = NULL   
      END IF
      IF p_nff.pes_tot_liquido = 0 THEN
         LET p_nff.pes_tot_liquido = NULL   
      END IF}

      CALL pol0704_busca_dados_historicos()  {le wfat_historico}

      LET p_nff.des_especie = p_nfe_sup_compl.den_embal

      CALL pol0704_prepara_linhas_texto()

      LET p_ies_lista  = TRUE

      CALL pol0704_monta_relat()
      CALL pol0704_inicializa_campos()
   END FOREACH

END FUNCTION

#--------------------------------#
 FUNCTION sup997_cria_t_pol0704()
#--------------------------------#

   WHENEVER ERROR CONTINUE

    DROP TABLE t_pol0704 
    IF sqlca.sqlcode <> 0 THEN
       DELETE FROM t_pol0704
    END IF
 
    CREATE TEMP TABLE t_pol0704
    (num_aviso_rec    DECIMAL(6,0));

   WHENEVER ERROR STOP

 END FUNCTION

#----------------------------------------#
 FUNCTION pol0704_cria_tabela_temporaria()
#----------------------------------------#
   WHENEVER ERROR CONTINUE

   DROP TABLE dados_nota;

   IF sqlca.sqlcode <> 0 THEN
      DELETE FROM dados_nota;
   END IF

   CREATE TEMP TABLE dados_nota
   (num_seq            SMALLINT,
    ies_tip_info       SMALLINT,
    cod_item           CHAR(16),
    den_item           CHAR(50),
    cod_cla_fisc       CHAR(10),
    cod_origem         DECIMAL(1,0),
    cod_tributacao     DECIMAL(2,0),
    cod_unid_med       CHAR(3),
    qtd_item           DECIMAL(12,3),
    peso_liq           DECIMAL(10,5),
    pre_unit           DECIMAL(17,6),
    val_liq_item       DECIMAL(15,2),
    pct_icm            DECIMAL(5,2),
    pct_ipi            DECIMAL(6,3),
    val_ipi            DECIMAL(12,2),
    des_texto          CHAR(120),
    num_nff            DECIMAL(6,0)
   ) WITH NO LOG;

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-TEMPORARIA")
   END IF
   
   DROP TABLE clas_fisc_temp;
   CREATE TEMP TABLE clas_fisc_temp
     (
      cod_cla_fisc       CHAR(010),
      num_item           DECIMAL(1,0)
     ) ;

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-clas_fisc_temp")
   END IF
   
   WHENEVER ERROR STOP
END FUNCTION

#------------------------------------#
 FUNCTION pol0704_busca_dados_compl()
#------------------------------------#
   INITIALIZE p_des_texto, p_nfe_sup_compl.* TO NULL

   SELECT *
     INTO p_nfe_sup_compl.*
     FROM nfe_sup_compl
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec 

   IF sqlca.sqlcode = 0 THEN
      IF p_nfe_sup_compl.texto_obs1 IS NOT NULL THEN
         LET p_cod_texto = p_nfe_sup_compl.texto_obs1 
         CALL pol0704_busca_texto_nf()
         LET p_des_texto1 = p_des_texto
      END IF

      IF p_nfe_sup_compl.texto_obs2 IS NOT NULL THEN
         LET p_cod_texto = p_nfe_sup_compl.texto_obs2 
         CALL pol0704_busca_texto_nf()
         LET p_des_texto2 = p_des_texto
      END IF
   END IF
END FUNCTION

#---------------------------------#
 FUNCTION pol0704_busca_texto_nf()
#---------------------------------#
   INITIALIZE p_des_texto TO NULL

   SELECT des_texto
     INTO p_des_texto
     FROM texto_nf
    WHERE cod_texto = p_cod_texto

   IF sqlca.sqlcode <> 0 THEN
      LET p_des_texto = " "
   END IF
END FUNCTION

#--------------------------------------------#
 FUNCTION pol0704_busca_dados_subst_trib_uf()
#--------------------------------------------#
   INITIALIZE p_subst_trib_uf.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT subst_trib_uf.*
     INTO p_subst_trib_uf.*
     FROM fornecedor, cidades, subst_trib_uf
    WHERE fornecedor.cod_fornecedor   = p_nf_sup.cod_fornecedor
      AND cidades.cod_cidade          = fornecedor.cod_cidade
      AND subst_trib_uf.cod_uni_feder = cidades.cod_uni_feder
   WHENEVER ERROR STOP
END FUNCTION

#-----------------------------------------------------#
 FUNCTION pol0704_busca_dados_fornec(p_cod_fornecedor)
#-----------------------------------------------------#
 DEFINE p_cod_fornecedor    LIKE fornecedor.cod_fornecedor

   INITIALIZE p_fornecedor.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT fornecedor.*
     INTO p_fornecedor.*
     FROM fornecedor
    WHERE fornecedor.cod_fornecedor = p_cod_fornecedor
   WHENEVER ERROR STOP
END FUNCTION

#--------------------------------------------------#
 FUNCTION pol0704_busca_dados_cidades(p_cod_cidade)
#--------------------------------------------------#
 DEFINE p_cod_cidade     LIKE cidades.cod_cidade

   INITIALIZE p_cidades.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT cidades.*
     INTO p_cidades.*
     FROM cidades
    WHERE cidades.cod_cidade = p_cod_cidade
   WHENEVER ERROR STOP
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0704_modifica_nfe_sup_compl()
#-----------------------------------------#
   UPDATE nfe_sup_compl SET ies_nfe_emit = "S"
    WHERE nfe_sup_compl.cod_empresa   = p_cod_empresa
      AND nfe_sup_compl.num_aviso_rec = p_num_aviso_rec

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("ATUALIZA","NFE_SUP_COMPL")
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#------------------------------#
 FUNCTION pol0704_monta_relat()
#------------------------------#

# cria indice de classifica��o fiscal

   DEFINE p_indice       DECIMAL(2,0),
          p_cod_cla_fisc CHAR(10),
          l_des_texto    CHAR(120)
          
   LET p_indice = 0
   LET p_num_pagina = 0
   
   DECLARE cq_ind_cla CURSOR FOR
   SELECT cod_cla_fisc
     FROM dados_nota
    WHERE ies_tip_info = 1
    ORDER BY cod_cla_fisc 

   FOREACH cq_ind_cla INTO p_cod_cla_fisc

      SELECT cod_cla_fisc
        FROM clas_fisc_temp
       WHERE cod_cla_fisc = p_cod_cla_fisc
       
      IF SQLCA.sqlcode = NOTFOUND THEN
         LET p_indice = p_indice + 1
         INSERT INTO clas_fisc_temp 
            VALUES(p_cod_cla_fisc, p_indice)
      END IF
     
   END FOREACH

   # fim cria��o indice de classifica��o fiscal

   #--- cria arquivo de texto para impressao 

   LET p_num_seq = 0
   INITIALIZE p_txt TO NULL
   INITIALIZE p_des_texto TO NULL
   DECLARE cq_cl_t CURSOR FOR
   SELECT * 
     FROM clas_fisc_temp
    ORDER BY 2
   FOREACH cq_cl_t INTO p_clas_fisc_temp.* 
      IF p_clas_fisc_temp.num_item = 1 THEN 
         LET p_des_texto = 'Class.Fiscal: ', p_clas_fisc_temp.num_item, ' - ', p_clas_fisc_temp.cod_cla_fisc
      ELSE
         LET p_des_texto = '              ', p_clas_fisc_temp.num_item, ' - ', p_clas_fisc_temp.cod_cla_fisc
      END IF  
      CALL pol0704_insere_texto(p_des_texto)
      INITIALIZE p_des_texto TO NULL
      CALL pol0704_insere_texto(p_des_texto)
      INITIALIZE p_des_texto TO NULL
   END FOREACH 
   
   LET p_des_texto = 'Aviso Rec:  ', p_num_aviso_rec
   CALL pol0704_insere_texto(p_des_texto)
   INITIALIZE p_des_texto TO NULL
   CALL pol0704_insere_texto(p_des_texto)
   INITIALIZE p_des_texto TO NULL
   
   SELECT *
     INTO p_nfe_sup_compl.*
     FROM nfe_sup_compl
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec 
   IF p_nfe_sup_compl.texto_compl1 IS NOT NULL THEN    
      LET p_des_texto =  p_nfe_sup_compl.texto_compl1[1,50]
      IF p_des_texto IS NOT NULL THEN  
         CALL pol0704_insere_texto(p_des_texto)
         INITIALIZE p_des_texto TO NULL
      END IF 
      LET p_des_texto =  p_nfe_sup_compl.texto_compl1[51,100]
      IF p_des_texto IS NOT NULL THEN  
         CALL pol0704_insere_texto(p_des_texto)
         INITIALIZE p_des_texto TO NULL
      END IF 
      LET p_des_texto =  p_nfe_sup_compl.texto_compl1[101,120]
      IF p_des_texto IS NOT NULL THEN  
         CALL pol0704_insere_texto(p_des_texto)
         INITIALIZE p_des_texto TO NULL
      END IF 
      INITIALIZE p_des_texto TO NULL
      CALL pol0704_insere_texto(p_des_texto)
      INITIALIZE p_des_texto TO NULL
   END IF 
   IF p_nfe_sup_compl.texto_compl2 IS NOT NULL THEN    
      LET p_des_texto =  p_nfe_sup_compl.texto_compl2[1,50]
      IF p_des_texto IS NOT NULL THEN  
         CALL pol0704_insere_texto(p_des_texto)
         INITIALIZE p_des_texto TO NULL
      END IF 
      LET p_des_texto =  p_nfe_sup_compl.texto_compl2[51,100]
      IF p_des_texto IS NOT NULL THEN  
         CALL pol0704_insere_texto(p_des_texto)
         INITIALIZE p_des_texto TO NULL
      END IF 
      LET p_des_texto =  p_nfe_sup_compl.texto_compl2[101,120]
      IF p_des_texto IS NOT NULL THEN  
         CALL pol0704_insere_texto(p_des_texto)
         INITIALIZE p_des_texto TO NULL
      END IF 
      INITIALIZE p_des_texto TO NULL
      CALL pol0704_insere_texto(p_des_texto)
      INITIALIZE p_des_texto TO NULL
   END IF 

   IF p_nfe_sup_compl.texto_obs1 > 0 THEN
      SELECT des_texto
        INTO l_des_texto
        FROM texto_nf
       WHERE cod_texto = p_nfe_sup_compl.texto_obs1
      IF l_des_texto IS NOT NULL THEN 
         LET p_des_texto =  l_des_texto[1,50]
         IF p_des_texto IS NOT NULL THEN  
            CALL pol0704_insere_texto(p_des_texto)
            INITIALIZE p_des_texto TO NULL
         END IF 
         LET p_des_texto =  l_des_texto[51,100]
         IF p_des_texto IS NOT NULL THEN  
            CALL pol0704_insere_texto(p_des_texto)
            INITIALIZE p_des_texto TO NULL
         END IF 
         LET p_des_texto =  l_des_texto[101,120]
         IF p_des_texto IS NOT NULL THEN  
            CALL pol0704_insere_texto(p_des_texto)
            INITIALIZE p_des_texto TO NULL
         END IF 
         INITIALIZE p_des_texto TO NULL
         CALL pol0704_insere_texto(p_des_texto)
         INITIALIZE p_des_texto TO NULL
      END IF    
   END IF       
   INITIALIZE l_des_texto TO NULL
   IF p_nfe_sup_compl.texto_obs2 > 0 THEN
      SELECT des_texto
        INTO l_des_texto
        FROM texto_nf
       WHERE cod_texto = p_nfe_sup_compl.texto_obs2
      IF l_des_texto IS NOT NULL THEN 
         LET p_des_texto =  l_des_texto[1,50]
         IF p_des_texto IS NOT NULL THEN  
            CALL pol0704_insere_texto(p_des_texto)
            INITIALIZE p_des_texto TO NULL
         END IF 
         LET p_des_texto =  l_des_texto[51,100]
         IF p_des_texto IS NOT NULL THEN  
            CALL pol0704_insere_texto(p_des_texto)
            INITIALIZE p_des_texto TO NULL
         END IF 
         LET p_des_texto =  l_des_texto[101,120]
         IF p_des_texto IS NOT NULL THEN  
            CALL pol0704_insere_texto(p_des_texto)
            INITIALIZE p_des_texto TO NULL
         END IF 
         INITIALIZE p_des_texto TO NULL
         CALL pol0704_insere_texto(p_des_texto)
         INITIALIZE p_des_texto TO NULL
      END IF    
   END IF       
   
{   DELARE cq_texto1 CURSOR FOR
   SELECT des_texto
     FROM dados_nota
    WHERE ies_tip_info = 3
    ORDER BY des_texto

   FOREACH cq_texto1 INTO p_des_texto
     
     IF LENGTH(p_des_texto) > 0 THEN        
        IF LENGTH(p_des_texto) <= 55 THEN
           CALL pol0704_insere_texto(p_des_texto)
        ELSE
           IF LENGTH(p_des_texto) > 55 AND
              LENGTH(p_des_texto) <= 110 THEN
              CALL substr(p_des_texto,55,2,'N') RETURNING p_texto1, p_texto2
              CALL pol0704_insere_texto(p_texto1)
              CALL pol0704_insere_texto(p_texto2)
           ELSE
              CALL substr(p_des_texto,55,3,'N') RETURNING p_texto1, p_texto2, p_texto3
              CALL pol0704_insere_texto(p_texto1)
              CALL pol0704_insere_texto(p_texto2)
              CALL pol0704_insere_texto(p_texto3)
           END IF
        END IF 
     END IF

     IF p_num_seq > 17 THEN
        EXIT FOREACH
     END IF
     
   END FOREACH
}

   LET p_cont_dados = 0
   SELECT COUNT(*) 
     INTO p_cont_dados
     FROM dados_nota
    WHERE ies_tip_info < 3
     
   DECLARE cq_dados_nota CURSOR FOR
    SELECT *
      FROM dados_nota  
     WHERE ies_tip_info <= 2
     ORDER BY ies_tip_info

   FOREACH cq_dados_nota INTO p_dados_nota.*
      LET p_dados_nota.num_nff = p_nf_sup.num_nf

      SELECT num_item
        INTO p_cod_ref_clas
        FROM clas_fisc_temp
       WHERE cod_cla_fisc = p_dados_nota.cod_cla_fisc

      OUTPUT TO REPORT pol0704_relat(p_dados_nota.*, p_clas_fisc.*, p_textos.*,p_cod_cla_h, p_cod_cla_i,p_cod_ref_clas)

   END FOREACH

END FUNCTION

#------------------------------------#
FUNCTION pol0704_insere_texto(p_texto)
#------------------------------------#

   DEFINE p_texto CHAR(55)
   
   LET p_num_seq = p_num_seq + 1
   
   IF p_num_seq <= 24 THEN
      LET p_txt[p_num_seq].texto = p_texto
   END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol0704_carrega_corpo_nff()
#------------------------------------#
 DEFINE p_qtd_item_t     LIKE wfat_item_ent.qtd_item,
        p_ies_bonif      CHAR(01)

 DEFINE p_qtd_padr_embal LIKE item_embalagem.qtd_padr_embal,
        p_vol_padr_embal LIKE item_embalagem.vol_padr_embal

 DEFINE p_item           LIKE item.pes_unit
 
 DEFINE p_ind            SMALLINT

   LET p_ind = 1

   DECLARE cq_wfat_item_ent CURSOR FOR
    SELECT *
      FROM aviso_rec
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_nf_sup.num_aviso_rec
     ORDER BY num_seq

   FOREACH cq_wfat_item_ent INTO p_aviso_rec.*
   LET p_item = NULL
       
       SELECT pes_unit
         INTO p_item
       FROM item        
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_aviso_rec.cod_item

      LET p_nff.val_tot_mercadoria = p_nff.val_tot_mercadoria + 
          (p_aviso_rec.qtd_declarad_nf * p_aviso_rec.pre_unit_nf)

      LET pa_corpo_nff[p_ind].cod_item       = p_aviso_rec.cod_item
      LET pa_corpo_nff[p_ind].den_item1      = p_aviso_rec.den_item[01,50]
    # LET pa_corpo_nff[p_ind].den_item2      = p_aviso_rec.den_item[44,50]

      INITIALIZE p_cod_fiscal , p_fiscal_par.* TO NULL
      LET p_cod_fiscal = p_aviso_rec.cod_fiscal_item[1,1],
                         p_aviso_rec.cod_fiscal_item[3,7]

###-------------daqui------------------------------#

      SELECT parametro_val
        INTO p_par_val
        FROM obf_par_grp_desp
       WHERE empresa         = p_cod_empresa
         AND grp_ctr_despesa = p_aviso_rec.gru_ctr_desp_item
         AND unid_federal    = p_nff.cod_uni_feder
         AND parametro       = 'origem_mercadoria'

      IF STATUS = 0 THEN
         LET pa_corpo_nff[p_ind].cod_origem     = p_par_val
      ELSE
         LET pa_corpo_nff[p_ind].cod_origem     = NULL
      END IF 

      SELECT parametro_val
        INTO p_par_val
        FROM obf_par_grp_desp
       WHERE empresa         = p_cod_empresa
         AND grp_ctr_despesa = p_aviso_rec.gru_ctr_desp_item
         AND unid_federal    = p_nff.cod_uni_feder
         AND parametro       = 'tributacao_icms'

      IF STATUS = 0 THEN
         LET pa_corpo_nff[p_ind].cod_tributacao     = p_par_val
      ELSE
         LET pa_corpo_nff[p_ind].cod_tributacao     = NULL
      END IF 

###-------------at� aqui------------------------------#
      
      LET pa_corpo_nff[p_ind].cod_unid_med   = p_aviso_rec.cod_unid_med_nf
      LET pa_corpo_nff[p_ind].qtd_item       = p_aviso_rec.qtd_declarad_nf
    #  LET pa_corpo_nff[p_ind].peso_liq       = p_aviso_rec.qtd_declarad_nf * p_item

###   LET p_nff.pes_tot_bruto    =  p_nff.pes_tot_bruto + 
###       (p_aviso_rec.qtd_declarad_nf * p_item)
###   LET p_nff.pes_tot_liquido  =  p_nff.pes_tot_liquido + 
###       (p_aviso_rec.qtd_declarad_nf * p_item)
      LET pa_corpo_nff[p_ind].pre_unit       = p_aviso_rec.pre_unit_nf
      LET pa_corpo_nff[p_ind].val_liq_item   = p_aviso_rec.val_liquido_item

      IF p_aviso_rec.pct_icms_item_d > 0 THEN
         LET pa_corpo_nff[p_ind].pct_icm = p_aviso_rec.pct_icms_item_d
      ELSE
         LET pa_corpo_nff[p_ind].pct_icm = p_aviso_rec.pct_icms_item_c
      END IF

      LET pa_corpo_nff[p_ind].pct_ipi    = p_aviso_rec.pct_ipi_declarad

      IF p_aviso_rec.val_ipi_decl_item > 0 THEN
         LET pa_corpo_nff[p_ind].val_ipi = p_aviso_rec.val_ipi_decl_item
      ELSE
         LET pa_corpo_nff[p_ind].val_ipi = p_aviso_rec.val_ipi_calc_item
      END IF

      IF p_aviso_rec.val_base_c_item_d > 0 THEN
         IF p_nf_sup.val_tot_icms_nf_d >0  THEN
            LET p_nff.val_tot_base_icm = p_nff.val_tot_base_icm + p_aviso_rec.val_base_c_item_d
         END IF
      ELSE
         IF p_nf_sup.val_tot_icms_nf_c >0  THEN
            LET p_nff.val_tot_base_icm = p_nff.val_tot_base_icm + p_aviso_rec.val_base_c_item_c
         END IF
      END IF

    #--- calcula/acumula a cubagem ---#

{      SELECT qtd_padr_embal, vol_padr_embal
        INTO p_qtd_padr_embal, p_vol_padr_embal
        FROM item_embalagem
       WHERE item_embalagem.cod_empresa = p_cod_empresa
         AND item_embalagem.cod_item    = p_aviso_rec.cod_item
         AND item_embalagem.ies_tip_embal IN ("N","I")

      IF sqlca.sqlcode = 0 THEN
         LET p_vol_item = (p_aviso_rec.qtd_declarad_nf * p_vol_padr_embal ) /
                           p_qtd_padr_embal
         LET p_vol_nf   = p_vol_nf + p_vol_item
      END IF}
###
###  A Polimetri imprime o codigo da classificacao e nao letras, por isso desa-
###  tivei a rotina abaixo
###
###   CALL sup997_busca_clas_fisc(p_aviso_rec.cod_cla_fisc)
###        RETURNING pa_corpo_nff[p_ind].cod_cla_fisc       

      LET pa_corpo_nff[p_ind].cod_cla_fisc = p_aviso_rec.cod_cla_fisc_nf

      IF p_ind = 999 THEN
         EXIT FOREACH
      END IF

      LET p_ind = p_ind + 1
   END FOREACH
END FUNCTION
  
#--------------------------------------------#
 FUNCTION pol0704_carrega_tabela_temporaria()
#--------------------------------------------#
 DEFINE i, j         SMALLINT
#DEFINE p_num_seq    SMALLINT

   LET i = 1
   LET j = 0
   LET p_num_seq = 0

   FOR i = 1 TO 999   {insere as linhas de corpo da nota na TEMP}
      IF pa_corpo_nff[i].cod_item     IS NULL AND
         pa_corpo_nff[i].cod_cla_fisc IS NULL AND
         pa_corpo_nff[i].pct_ipi      IS NULL AND 
         pa_corpo_nff[i].qtd_item     IS NULL AND
         pa_corpo_nff[i].pre_unit     IS NULL THEN
         CONTINUE FOR
      END IF

      LET p_num_seq = p_num_seq + 1

      INSERT INTO dados_nota VALUES (p_num_seq,1,
                                     pa_corpo_nff[i].cod_item,
                                     pa_corpo_nff[i].den_item1,
                                     pa_corpo_nff[i].cod_cla_fisc,
                                     pa_corpo_nff[i].cod_origem,
                                     pa_corpo_nff[i].cod_tributacao,
                                     pa_corpo_nff[i].cod_unid_med,
                                     pa_corpo_nff[i].qtd_item,
                                     pa_corpo_nff[i].peso_liq,
                                     pa_corpo_nff[i].pre_unit,  
                                     pa_corpo_nff[i].val_liq_item,
                                     pa_corpo_nff[i].pct_icm,
                                     pa_corpo_nff[i].pct_ipi,
                                     pa_corpo_nff[i].val_ipi,NULL,NULL)

   END FOR
END FUNCTION

#-------------------------------------------#
 FUNCTION pol0704_calcula_total_de_paginas()
#-------------------------------------------#

   SELECT COUNT(*)
      INTO p_num_linhas
   FROM dados_nota
   WHERE ies_tip_info < 3

   { p_qtd_linhas_dispon = numero de linhas do corpo da nota fiscal }

   IF p_num_linhas IS NOT NULL AND
      p_num_linhas > 0 THEN
      LET p_tot_paginas = (p_num_linhas - (p_num_linhas MOD 
                           p_qtd_linhas_dispon)) / p_qtd_linhas_dispon

      IF (p_num_linhas MOD p_qtd_linhas_dispon) > 0 THEN
         LET p_tot_paginas = p_tot_paginas + 1
      ELSE
         LET p_ies_termina_relat = FALSE
      END IF
   ELSE 
      LET p_tot_paginas = 1
   END IF

END FUNCTION

#------------------------------# 
 FUNCTION pol0704_den_nat_oper() 
#------------------------------# 

   DEFINE p_den_cod_fiscal LIKE cod_fiscal_sup.den_cod_fiscal 
 
   WHENEVER ERROR CONTINUE 
   SELECT cod_fiscal_sup.den_cod_fiscal 
      INTO p_den_cod_fiscal 
   FROM cod_fiscal_sup
   WHERE cod_fiscal_sup.cod_fiscal = p_nff.cod_fiscal 
   WHENEVER ERROR STOP 
  
   IF SQLCA.SQLCODE = 0 THEN 
      RETURN p_den_cod_fiscal 
   ELSE  
      RETURN "NATUREZA NAO CADASTRADA" 
   END IF 

END FUNCTION 

#----------------------------------------#
 FUNCTION pol0704_busca_dados_historicos()
#----------------------------------------#

   DEFINE p_primeira_vez  SMALLINT,
          p_comando       CHAR(1) ,
          p_cont          SMALLINT,
          p_fiscal_hist1  RECORD LIKE fiscal_hist.*,
          p_fiscal_hist2  RECORD LIKE fiscal_hist.*

   INITIALIZE pa_historico TO NULL
   LET p_cont = 1
   LET p_primeira_vez = TRUE 

   WHENEVER ERROR CONTINUE
   SELECT * 
      INTO p_fiscal_hist1.*
   FROM fiscal_hist 
   WHERE cod_hist = p_fiscal_par.cod_hist_1
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
   SELECT * 
      INTO p_fiscal_hist2.*
   FROM fiscal_hist 
   WHERE cod_hist = p_fiscal_par.cod_hist_2
   WHENEVER ERROR STOP

   LET pa_historico[1].texto = p_fiscal_hist1.tex_hist_1 CLIPPED,
                               p_fiscal_hist1.tex_hist_2
   LET pa_historico[2].texto = p_fiscal_hist1.tex_hist_3 CLIPPED,
                               p_fiscal_hist1.tex_hist_4 
   LET pa_historico[3].texto = p_fiscal_hist2.tex_hist_1 CLIPPED,
                               p_fiscal_hist2.tex_hist_2
   LET pa_historico[4].texto = p_fiscal_hist2.tex_hist_3 CLIPPED,
                               p_fiscal_hist2.tex_hist_4

END FUNCTION

#------------------------------------------------------#
 FUNCTION pol0704_busca_dados_transport(p_cod_transpor)
#------------------------------------------------------#
 DEFINE p_cod_transpor LIKE clientes.cod_cliente

   INITIALIZE p_transport.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_transport.*
     FROM transport
    WHERE transport.cod_transpor = p_cod_transpor

    IF sqlca.sqlcode <> 0 THEN
       SELECT nom_cliente, end_cliente,  num_cgc_cpf, cod_cidade, ins_estadual
        INTO p_transport.den_transpor, p_transport.end_transpor,
             p_transport.num_cgc, p_transport.cod_cidade, 
             p_transport.ins_estadual
        FROM clientes                 
        WHERE cod_cliente = p_cod_transpor

       IF sqlca.sqlcode <> 0 THEN
          SELECT raz_social, end_fornec, ins_estadual, cod_cidade, num_cgc_cpf
           INTO p_transport.den_transpor, p_transport.end_transpor,
                p_transport.ins_estadual, p_transport.cod_cidade, 
                p_transport.num_cgc
            FROM fornecedor
            WHERE cod_fornecedor = p_cod_transpor
       END IF 
    END IF
   WHENEVER ERROR STOP
END FUNCTION

#-------------------------------------------------#
 FUNCTION pol0704_busca_dados_consig(p_cod_consig)
#-------------------------------------------------#
 DEFINE p_cod_consig  LIKE clientes.cod_cliente

   INITIALIZE p_consignat.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT clientes.nom_cliente,
          clientes.end_cliente,
          clientes.den_bairro,
          cidades.den_cidade,
          cidades.cod_uni_feder
     INTO p_consignat.*
     FROM clientes, cidades
    WHERE clientes.cod_cliente = p_cod_consig
      AND clientes.cod_cidade  = cidades.cod_cidade
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 0 THEN
      LET p_houve_consig = TRUE
   END IF
END FUNCTION

#---------------------------------------#
 FUNCTION pol0704_prepara_linhas_texto()
#---------------------------------------#
 DEFINE i            SMALLINT,
        p_count      SMALLINT,
        p_texto      CHAR(20)


   INITIALIZE pa_texto TO NULL
   LET p_count = 0

   IF p_houve_consig THEN
      LET p_count = p_count + 1
      LET pa_texto[p_count].texto = "CONS: ", p_consignat.den_consignat, " ",
                                              p_consignat.end_consignat
      LET p_count = p_count + 1
      LET pa_texto[p_count].texto = p_consignat.den_bairro, " ",
                                    p_consignat.den_cidade, " ",
                                    p_consignat.cod_uni_feder
   END IF

#  LET p_count = p_count + 1
#  LET pa_texto[p_count].texto = ""

   FOR i = 1 TO 8
      IF pa_historico[i].texto IS NOT NULL AND
         pa_historico[i].texto <> " " THEN
         LET p_count = p_count + 1
         LET pa_texto[p_count].texto = pa_historico[i].texto
         CONTINUE FOR
      END IF
   END FOR
{
   IF p_nff.num_di IS NOT NULL AND
      p_nff.num_di <> " " THEN
   
      INSERT INTO dados_nota 
         VALUES (p_num_seq,2,"","","","","","","","",
                 "","","","","",NULL,NULL)

      LET p_texto = "Num. DI ", p_nff.num_di
      LET p_num_seq = p_num_seq + 1

      INSERT INTO dados_nota 
         VALUES (p_num_seq,2,"","","","","","","","",
                 "","","","","",p_texto,NULL)
   END IF
}
	
  { imprime texto da nota, se este existir }

   IF p_des_texto1 IS NOT NULL AND p_des_texto1 <> " " THEN
      LET p_count = p_count + 1
      LET pa_texto[p_count].texto = p_des_texto1
   END IF

   IF p_des_texto2 IS NOT NULL AND p_des_texto2 <> " " THEN
      LET p_count = p_count + 1
      LET pa_texto[p_count].texto = p_des_texto2
   END IF

   IF p_nfe_sup_compl.texto_compl1 IS NOT NULL AND
      p_nfe_sup_compl.texto_compl1 <> " " THEN
      LET p_count = p_count + 1
      LET pa_texto[p_count].texto = p_nfe_sup_compl.texto_compl1
   END IF

   IF p_nfe_sup_compl.texto_compl2 IS NOT NULL AND
      p_nfe_sup_compl.texto_compl2 <> " " THEN
      LET p_count = p_count + 1
      LET pa_texto[p_count].texto = p_nfe_sup_compl.texto_compl2
   END IF

   LET p_textos.texto1  = pa_texto[1].texto
   LET p_textos.texto2  = pa_texto[2].texto
   LET p_textos.texto3  = pa_texto[3].texto
   LET p_textos.texto4  = pa_texto[4].texto
   LET p_textos.texto5  = pa_texto[5].texto  
   LET p_textos.texto6  = pa_texto[6].texto
   LET p_textos.texto7  = pa_texto[7].texto  
   LET p_textos.texto8  = pa_texto[8].texto
   LET p_textos.texto9  = pa_texto[9].texto
   LET p_textos.texto10 = pa_texto[10].texto
   LET p_textos.texto11 = pa_texto[11].texto
   LET p_textos.texto12 = pa_texto[12].texto

   IF p_count > 12 THEN
      ERROR "Linhas de texto ultrapassaram o limite de 12 linhas."
      SLEEP 1
      ERROR ""
   END IF

   FOR i = 1 TO 12
      IF pa_texto[i].texto IS NOT NULL THEN
         IF LENGTH(pa_texto[i].texto) > 74 THEN
            CALL substr(pa_texto[i].texto,74,2,'N') 
               RETURNING p_texto1, p_texto2
            LET p_num_seq = p_num_seq + 1
            INSERT INTO dados_nota 
                VALUES (p_num_seq,3,"","","",0,0,"",0,0,
                       0,0,0,0,0,p_texto1,NULL)

            LET p_num_seq = p_num_seq + 1
            INSERT INTO dados_nota 
               VALUES (p_num_seq,3,"","","",0,0,"",0,0,
                       0,0,0,0,0,p_texto2,NULL)
         ELSE
            LET p_num_seq = p_num_seq + 1
            INSERT INTO dados_nota 
               VALUES (p_num_seq,3,"","","",0,0,"",0,0,
                       0,0,0,0,0,pa_texto[i].texto,NULL)
         END IF
      END IF
   END FOR

END FUNCTION

#-----------------------------------------------#
 FUNCTION sup997_busca_clas_fisc(p_cod_cla_fisc2)
#-----------------------------------------------#

 DEFINE p_cod_cla_fisc2 LIKE clas_fisc_rec.cod_clas_fisc
 DEFINE p_ies_cla_fisc2 LIKE clas_fisc_rec.ies_tipo_class

 INITIALIZE p_ies_cla_fisc2 TO NULL

 IF p_cod_cla_fisc2 = p_cod_cla_h      THEN
    LET p_clas_fisc.percentual = "H"       
    RETURN p_cod_cla_fisc2
 END IF 

 SELECT clas_fisc_rec.ies_tipo_class INTO p_clas_fisc.percentual
   FROM clas_fisc_rec
  WHERE clas_fisc_rec.cod_empresa   = p_cod_empresa
    AND clas_fisc_rec.cod_clas_fisc = p_cod_cla_fisc2

 IF sqlca.sqlcode = NOTFOUND   THEN 
    LET p_cont_fisc = p_cont_fisc + 1
    IF p_cont_fisc = 1  THEN   
       LET p_clas_fisc.percentual = "H"       
       LET p_cod_cla_h = p_cod_cla_fisc2 
    ELSE
       IF p_cont_fisc = 2  THEN   
          LET p_clas_fisc.percentual = "I"       
          LET p_cod_cla_i = p_cod_cla_fisc2 
       ELSE
          LET p_clas_fisc.percentual = " "       
       END IF  
    END IF  
 END IF 

 LET p_cod_cla_fisc2 =  p_clas_fisc.percentual 

 RETURN p_cod_cla_fisc2

END FUNCTION

#---------------------------------------------------------------------------------------------#
 REPORT pol0704_relat(p_dados_nota,p_clas_fisc,p_textos,p_cod_cla_h,p_cod_cla_i,p_cod_ref_clas)
#---------------------------------------------------------------------------------------------#

 DEFINE p_dados_nota    RECORD
        num_seq         SMALLINT,
        ies_tip_info    SMALLINT,
        cod_item        LIKE wfat_item_ent.cod_item,
        den_item        CHAR(65),
        cod_cla_fisc    CHAR(10),
        cod_origem      LIKE wfat_mestre_ent.cod_origem,
        cod_tributacao  LIKE tributacao.cod_tributacao,
        cod_unid_med    LIKE wfat_item_ent.cod_unid_med,
        qtd_item        LIKE wfat_item_ent.qtd_item,
        peso_liq        DECIMAL(10,5),
        pre_unit        LIKE wfat_item_ent.pre_unit_nf,
        val_liq_item    LIKE wfat_item_ent.val_liq_item,
        pct_icm         LIKE wfat_mestre_ent.pct_icm,
        pct_ipi         LIKE wfat_item_ent.pct_ipi,
        val_ipi         LIKE wfat_item_ent.val_ipi,
        des_texto       CHAR(120),
        num_nff         LIKE wfat_mestre_ent.num_nff
        END RECORD

 DEFINE p_des_folha     CHAR(100)
 
 DEFINE p_clas_fisc     RECORD
        denominacao     CHAR(10),
        percentual      CHAR(02)
        END RECORD 	

 DEFINE p_textos       RECORD
        texto1         CHAR(120),
        texto2         CHAR(120),
        texto3         CHAR(120),
        texto4         CHAR(120),
        texto5         CHAR(120),
        texto6         CHAR(120),
        texto7         CHAR(120),
        texto8         CHAR(120),
        texto9         CHAR(120),
        texto10        CHAR(120),
        texto11        CHAR(120),
        texto12        CHAR(120)
        END RECORD
 
 DEFINE p_cod_cla_h    CHAR(10),
        p_cod_cla_i    CHAR(10),
        p_cod_ref_clas CHAR(01) 

 DEFINE i, j    SMALLINT

 OUTPUT LEFT   MARGIN   1 
        TOP    MARGIN   0
        BOTTOM MARGIN   0
        PAGE   LENGTH   65

 ORDER EXTERNAL BY p_dados_nota.num_nff, p_dados_nota.num_seq

 FORMAT

   PAGE HEADER
      LET p_num_pagina = p_num_pagina + 1
      PRINT p_8lpp, p_comprime
      PRINT COLUMN 001, p_txt[1].texto
      PRINT COLUMN 001, p_txt[2].texto,
            COLUMN 188, p_nff.num_nff USING "&&&&&&"                            

      PRINT COLUMN 001, p_txt[3].texto,
            COLUMN 168, "X"
       
      PRINT COLUMN 001, p_txt[4].texto

      PRINT COLUMN 001, p_txt[5].texto

      PRINT COLUMN 001, p_txt[6].texto

      PRINT COLUMN 001, p_txt[7].texto

      PRINT COLUMN 001, p_txt[8].texto

      IF p_cod_fiscal_compl IS NOT NULL  
         AND p_cod_fiscal_compl = 0 THEN
         PRINT COLUMN 001, p_txt[9].texto,
               COLUMN 060, p_nff.den_nat_oper[1,30],
               COLUMN 104, p_nff.cod_fiscal      USING "&&&&"
      ELSE
         PRINT COLUMN 001, p_txt[9].texto,
               COLUMN 060, p_nff.den_nat_oper[1,30],
               COLUMN 104, p_nff.cod_fiscal      USING "&&&",
               COLUMN 107, ".",
               COLUMN 108, p_cod_fiscal_compl    USING "&"
      END IF 
                            
      PRINT COLUMN 001, p_txt[10].texto

      PRINT COLUMN 001, p_txt[11].texto

      PRINT COLUMN 001, p_txt[12].texto

      PRINT COLUMN 001, p_txt[13].texto,
            COLUMN 060, p_nff.nom_destinatario,
            COLUMN 157, p_nff.num_cgc_cpf,
            COLUMN 187, p_nff.dat_emissao     USING "DD/MM/YYYY"  

      PRINT COLUMN 001, p_txt[14].texto
            
      PRINT COLUMN 001, p_txt[15].texto,
            COLUMN 060, p_nff.end_destinatario,
            COLUMN 135, p_nff.den_bairro[1,12],
            COLUMN 167, p_nff.cod_cep
            #COLUMN 071, TODAY USING "DD/MM/YYYY"
            
      PRINT COLUMN 001, p_txt[16].texto      

      PRINT COLUMN 001, p_txt[17].texto,      
            COLUMN 060, p_nff.den_cidade[1,22],
            COLUMN 116, p_nff.num_telefone[1,13],
            COLUMN 142, p_nff.cod_uni_feder,
            COLUMN 160, p_nff.ins_estadual
            #COLUMN 071, TIME 
      PRINT COLUMN 001, p_txt[18].texto
      PRINT COLUMN 001, p_txt[19].texto
      PRINT COLUMN 001, p_txt[20].texto
      PRINT COLUMN 001, p_txt[21].texto
      PRINT COLUMN 001, p_txt[22].texto
      PRINT COLUMN 001, p_txt[23].texto
      PRINT COLUMN 001, p_txt[24].texto
      
      PRINT
      PRINT
      PRINT
      
   BEFORE GROUP OF p_dados_nota.num_nff
      SKIP TO TOP OF PAGE 

   ON EVERY ROW

      CASE
         WHEN p_dados_nota.ies_tip_info = 1
            PRINT COLUMN 001, p_dados_nota.cod_item[1,15],
                  COLUMN 023, p_dados_nota.den_item[1,60],
                  COLUMN 111, p_cod_ref_clas,
                  COLUMN 117, p_dados_nota.cod_origem     USING "&",
                  COLUMN 118, p_dados_nota.cod_tributacao USING "&&",
                  COLUMN 123, p_dados_nota.cod_unid_med,
                  COLUMN 132, p_dados_nota.qtd_item      USING "####&.&&",
                  COLUMN 144, p_dados_nota.pre_unit      USING "####&.&&&&",
                  COLUMN 168, p_dados_nota.val_liq_item  USING "####,##&.&&",
                  COLUMN 184, p_dados_nota.pct_icm       USING "#&",
                  COLUMN 189, p_dados_nota.pct_ipi       USING "#&",
                  COLUMN 193, p_dados_nota.val_ipi       USING "####&.&&"
            LET p_linhas_print = p_linhas_print + 1

         WHEN p_dados_nota.ies_tip_info = 2
            PRINT COLUMN 022, p_dados_nota.des_texto
            LET p_linhas_print = p_linhas_print + 1
            
      END CASE

      IF p_num_pagina = p_tot_paginas THEN { numero de linhas corpo da nota }
         LET p_des_folha = "Folha ", p_num_pagina    USING "&&","/",
                            p_tot_paginas USING "&&" 

         IF (p_cont_dados MOD p_qtd_linhas_dispon) > 0 THEN
            IF p_num_pagina > 1 AND
               p_cont_dados = (((p_num_pagina - 1) * p_qtd_linhas_dispon) +
                              p_linhas_print) THEN
               FOR p_contador = 1 TO (p_qtd_linhas_dispon - p_linhas_print)
                  PRINT " "
               END FOR
            ELSE
               IF p_cont_dados = p_linhas_print THEN
                  FOR p_contador = 1 TO (p_qtd_linhas_dispon-p_linhas_print)
                     PRINT " "
                  END FOR
               END IF
            END IF
         END IF

         IF p_num_pagina > 1 AND
            p_cont_dados = (((p_num_pagina - 1) * p_qtd_linhas_dispon) +
                           p_linhas_print) OR
           (p_num_pagina = 1 AND
            p_cont_dados = p_linhas_print) THEN
            
            PRINT COLUMN 025, p_des_folha
            PRINT
            PRINT COLUMN 010, p_nff.val_tot_base_icm   USING "###,###,##&.&&",
                  COLUMN 036, p_nff.val_tot_icm        USING "###,###,##&.&&",
                  COLUMN 064, p_nff.val_tot_base_ret   USING "###,###,##&.&&",
                  COLUMN 090, p_nff.val_tot_icm_ret    USING "###,###,##&.&&",
                  COLUMN 118, p_nff.val_tot_mercadoria USING "###,###,##&.&&"
            SKIP 1 LINES
            PRINT COLUMN 010, p_nff.val_tot_frete      USING "###,###,##&.&&", 
                  COLUMN 036, p_nff.val_tot_seguro     USING "###,###,##&.&&",
                  COLUMN 064, p_nff.val_tot_despesas   USING "###,###,##&.&&",
                  COLUMN 090, p_nff.val_tot_ipi        USING "###,###,##&.&&",
                  COLUMN 118, p_nff.val_tot_nff        USING "###,###,##&.&&"
            SKIP 2 lines
            PRINT COLUMN 001, p_nff.nom_transpor;
            IF p_nff.ies_frete = "1" THEN
               PRINT COLUMN 075, "1";
            ELSE
               PRINT COLUMN 075, "2";
            END IF
            PRINT COLUMN 086, p_nff.num_placa,
                  COLUMN 097, p_nff.cod_uni_feder_trans,
                  COLUMN 116, p_nff.num_cgc_trans
            SKIP 1 LINES
            PRINT COLUMN 001, p_nff.end_transpor,
                  COLUMN 065, p_nff.den_cidade_trans[1,20],
                  COLUMN 097, p_nff.cod_uni_feder_trans,
                  COLUMN 116, p_nff.ins_estadual_trans
            SKIP 1 LINES 
            PRINT COLUMN 005, p_nff.qtd_volume      USING "###,##&",
                  COLUMN 020, p_nff.des_especie,
                  COLUMN 052, p_nff.den_marca,
                  COLUMN 082, p_nff.num_nff         USING "&&&&&&",
                  COLUMN 099, p_nff.pes_tot_bruto   USING "###,##&.&&&",
                  COLUMN 119, p_nff.pes_tot_liquido USING "###,##&.&&&"

            SKIP 3 LINES
            PRINT COLUMN 183, p_nff.num_nff USING "&&&&&&"
            SKIP 3 LINES
            LET p_num_pagina = 0
         END IF
      ELSE
         LET p_des_folha = "Folha ", p_num_pagina    USING "&&","/",
                            p_tot_paginas USING "&&"," - Continua" 
         PRINT
         IF p_qtd_linhas_dispon = p_linhas_print THEN
            PRINT COLUMN 025, p_des_folha
            PRINT COLUMN 010, "**************",
                  COLUMN 036, "**************",
                  COLUMN 064, "**************",
                  COLUMN 090, "**************",
                  COLUMN 118, "**************"
            SKIP 1 LINES
            PRINT COLUMN 010, "**************",
                  COLUMN 036, "**************",
                  COLUMN 064, "**************",
                  COLUMN 090, "**************",
                  COLUMN 118, "**************"
            SKIP 10 LINES 
            PRINT COLUMN 183, p_nff.num_nff USING "&&&&&&"
            SKIP 3 LINES 
            LET p_linhas_print = 0
         END IF
      END IF

END REPORT

#---------------------------- FIM DE PROGRAMA ---------------------------------#