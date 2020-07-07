#-------------------------------------------------------------------#
# SISTEMA.: ESTOQUE                                                 #
# PROGRAMA: pol1006                                                 #
# OBJETIVO: MOVIMENTO DE VALOR PARA AJUSTE DE CUSTO                 #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 11/01/2010                                             #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_oper_sai       LIKE par_ajust_454.cod_oper_sai,
          p_cod_oper_ent       LIKE par_ajust_454.cod_oper_ent,
          p_num_conta          LIKE item_sup.num_conta,
          p_cod_operac         LIKE par_ajust_454.cod_oper_ent,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_den_familia        LIKE familia.den_familia,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_ies_situacao       LIKE item.ies_situacao,
          p_dat_txt            CHAR(10),
          p_dia_txt            CHAR(02),
          p_ano_mes_ref        CHAR(06),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(80),
          p_msg                CHAR(300)

   DEFINE p_qtd_mes_ant_ini    LIKE estoque_hist.qtd_mes_ant,
          p_qtd_mes_normal     LIKE estoque_hist.qtd_mes_ant,
          p_qtd_mes_rev        LIKE estoque_hist.qtd_mes_ant, 
          p_qtd_mes_ant        LIKE estoque_hist.qtd_mes_ant,
          p_cod_item           LIKE estoque_hist.cod_item,
          p_qtd_mes_ent        LIKE estoque_hist.qtd_mes_ant,
          p_cus_unit_medio     LIKE estoque_hist.cus_unit_medio,
          p_cus_unit_medio_ini LIKE estoque_hist.cus_unit_medio,
          p_cus_tot_normal    LIKE estoque_hist.cus_unit_medio,
          p_cus_tot_rev       LIKE estoque_hist.cus_unit_medio,                    
          p_val_movto          LIKE estoque_hist.cus_unit_medio,
          p_val_medio          LIKE estoque_hist.cus_unit_medio,
          p_cus_unit_normal    LIKE estoque_hist.cus_unit_medio,
          p_cus_unit_rev       LIKE estoque_hist.cus_unit_medio,
          p_val_cus_medio      LIKE estoque_hist.cus_unit_medio,
          p_val_cus_medio_ini  LIKE estoque_hist.cus_unit_medio,
          p_val_cus_medio_ent  LIKE estoque_hist.cus_unit_medio,
          p_val_contab         LIKE estoque_hist.cus_unit_medio,
          p_pre_contab         LIKE estoque_trans.cus_unit_movto_p,
          p_cod_local_estoq    LIKE item.cod_local_estoq

   DEFINE p_estoque_trans      RECORD LIKE  estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*
          
   DEFINE p_tela               RECORD
          prox_fec             DATE,
          ult_fec              DATE,
          mes_ref              CHAR(02),
          ano_ref              CHAR(04),
          dat_movto            DATE,
          cod_item             CHAR(15),
          cod_familia          CHAR(05),
          ies_tip_item         CHAR(01)
   END RECORD

   DEFINE p_aen              RECORD 
          cod_lin_prod       LIKE item.cod_lin_prod,
          cod_lin_recei      LIKE item.cod_lin_recei,
          cod_seg_merc       LIKE item.cod_seg_merc,
          cod_cla_uso        LIKE item.cod_cla_uso
  END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol1006-05.10.06"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1006.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1006_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1006_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1006") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1006 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
      
   MENU "OPCAO"
      COMMAND "Informar" "Informa mês e ano de referência"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = FALSE
         IF pol1006_informar() THEN
            ERROR "Parâmetros informados com sucesso!"
            NEXT OPTION 'Processar'
         ELSE
            ERROR 'Operação cancelada!'
         END IF
      COMMAND "Processar" "Processa a atualização do histórico do estoque"
         HELP 001
         MESSAGE ""
         LET int_flag = 0
         IF p_ies_cons THEN 
            CALL pol1006_processa()
            NEXT OPTION "Fim"
         ELSE
            ERROR "Informe os parâmetros previamente !!!"
            NEXT OPTION "Informar"
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Sai do programa"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1006

END FUNCTION

#--------------------------#
FUNCTION pol1006_le_fecha()
#--------------------------#

   INITIALIZE p_tela TO NULL
   
   SELECT dat_prx_fecha_est,
          dat_fecha_ult_sup
     INTO p_tela.prox_fec,
          p_tela.ult_fec
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","par_estoque")
      RETURN FALSE
   END IF
   
   LET p_dat_txt = p_tela.ult_fec
   LET p_tela.mes_ref = p_dat_txt[4,5]
   LET p_tela.ano_ref = p_dat_txt[7,10]
   #CALL pol01006_calc_dat_mov()
   LET p_tela.dat_movto = p_tela.prox_fec #Marcio pediu pra alterar dessa forma
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol01006_calc_dat_mov()
#-------------------------------#

   DEFINE p_mes_fec, p_ano_fec, p_resto SMALLINT
    
      LET p_mes_fec = p_tela.mes_ref
      LET p_ano_fec = p_tela.ano_ref
      LET p_resto = p_ano_fec MOD 4

      IF p_mes_fec = 2 THEN 
         IF p_resto = 0 THEN
            LET p_dia_txt = '29'
         ELSE
            LET p_dia_txt = '28'
         END IF
      ELSE
         IF p_mes_fec = 4 OR p_mes_fec = 6 OR p_mes_fec = 9 OR p_mes_fec = 11 THEN
            LET p_dia_txt = '30'
         ELSE
            LET p_dia_txt = '31'
         END IF
      END IF
      
      #LET p_tela.dat_movto = p_dia_txt,'/',p_tela.mes_ref,'/', p_tela.ano_ref

END FUNCTION

#--------------------------#
FUNCTION pol1006_informar()
#--------------------------#

   DEFINE p_ano_fec, p_mes_fec, p_resto SMALLINT

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol1006_le_fecha() THEN
      RETURN FALSE
   END IF

   SELECT cod_oper_ent,
          cod_oper_sai
     INTO p_cod_oper_ent,
          p_cod_oper_sai
     FROM par_ajust_454
    WHERE cod_empresa = p_cod_empresa

   IF SQLCA.sqlcode = NOTFOUND THEN
      LET p_msg = 'Parâmetros para ajuste de custo não encontrados!'
      CALL log0030_mensagem(p_msg,'Excla')
      RETURN FALSE
   END IF
     
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD mes_ref
         IF p_tela.mes_ref IS NULL THEN
            ERROR 'Informe o mês de referência !!!'
            NEXT FIELD mes_ref
         END IF
         
         IF p_tela.mes_ref < 1 OR p_tela.mes_ref > 12 THEN
            ERROR 'Mês Inválido !!!'
            NEXT FIELD mes_ref
         END IF
         
         LET p_tela.mes_ref = p_tela.mes_ref CLIPPED
         
         IF LENGTH(p_tela.mes_ref) = 1 THEN
            LET p_tela.mes_ref = '0', p_tela.mes_ref
         END IF
         
      AFTER FIELD ano_ref

         IF p_tela.ano_ref IS NULL THEN
            ERROR 'Informe o ano de referência !!!'
            NEXT FIELD ano_ref
         END IF
         
         LET p_count = p_tela.ano_ref
         
         IF p_count < 1900 THEN
            ERROR 'O ano informado não é válido !!!'
            NEXT FIELD ano_ref
         END IF
      
      AFTER FIELD cod_item
         
         IF p_tela.cod_item IS NOT NULL THEN
         
	         SELECT den_item_reduz,
	                ies_tip_item,
	                ies_situacao
	           INTO p_den_item_reduz,
	                p_ies_tip_item,
	                p_ies_situacao
	           FROM item
	          WHERE cod_empresa = p_cod_empresa
	            AND cod_item    = p_tela.cod_item
	         
	         IF SQLCA.sqlcode = NOTFOUND THEN
	            ERROR 'Item Inexistente !!!'
	            NEXT FIELD cod_item   
	         END IF
	         
	         {IF p_ies_situacao <> 'A' THEN
	            ERROR 'Item não está ativo !!!'
	            NEXT FIELD cod_item   
	         END IF}
	         
	         IF p_ies_tip_item MATCHES '[FPB]' THEN
	         ELSE
	            ERROR 'Item informado não é um item final ou produzido !!!'
	            NEXT FIELD cod_item   
	         END IF
	         
	         DISPLAY p_den_item_reduz TO den_item_reduz  
	         EXIT INPUT
	         
	       END IF
	         
      AFTER FIELD cod_familia
         
         IF p_tela.cod_familia IS NOT NULL THEN
            
            SELECT den_familia
              INTO p_den_familia
              FROM familia
             WHERE cod_empresa = p_cod_empresa
               AND cod_familia = p_tela.cod_familia
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo', 'Familia')
               NEXT FIELD cod_familia
            END IF
            
            DISPLAY p_den_familia TO den_familia
            
         END IF

      AFTER FIELD ies_tip_item
      
         IF p_tela.ies_tip_item IS NOT NULL THEN
            IF p_tela.ies_tip_item MATCHES '[PFB]' THEN
            ELSE
               ERROR 'O tipo do item deve ser (P)roduzido ou (F)inal!'
               NEXT FIELD ies_tip_item
            END IF
         END IF
      
      ON KEY (control-z)
         CALL pol1006_popup()

   END INPUT

   IF INT_FLAG THEN
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE
   END IF

   RETURN(p_ies_cons)

END FUNCTION

#-----------------------#
FUNCTION pol1006_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1006
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
   
      WHEN INFIELD(cod_familia)
         CALL log009_popup(8,25,"FAMILIAS","familia",
                     "cod_familia","den_familia","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1006
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_familia = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_familia
         END IF

   END CASE

END FUNCTION


#--------------------------#
FUNCTION pol1006_processa()
#--------------------------#

   DEFINE p_qtd CHAR(10)

   IF NOT log004_confirm(19,41) THEN
      RETURN 
   END IF
   
   CALL log085_transacao("BEGIN")

   IF pol1006_gera_movtos() THEN
      CALL log085_transacao("COMMIT")
      LET p_qtd = p_count
      LET p_msg = 'Processamneto efetuado com sucesso!','\n'
      IF p_count > 0 THEN
         LET p_msg = p_msg CLIPPED, p_qtd CLIPPED,' itens foram ajustados.'
      ELSE
         LET p_msg = p_msg CLIPPED,' Nenhum item foi ajustado.'
      END IF
   ELSE
      CALL log085_transacao("ROLLBACK")
      LET p_msg = 'Operação cancelada!'
   END IF

   CALL log0030_mensagem(p_msg,'excla')
   
END FUNCTION


#----------------------------#
FUNCTION pol1006_gera_movtos()
#----------------------------#

   DEFINE sql_stmt  CHAR(600),
          p_ano_mes DECIMAL(6,0)
          
   MESSAGE "Aguarde. Processando ..." ATTRIBUTE(REVERSE)

   LET p_count = 0
   
   LET p_ano_mes_ref = p_tela.ano_ref CLIPPED, p_tela.mes_ref CLIPPED
   LET p_ano_mes = p_ano_mes_ref

   LET sql_stmt = 
       "SELECT cod_item, cod_local_estoq FROM item ",
       " WHERE cod_empresa  = '",p_cod_empresa,"' ",
       "   AND ies_tip_item IN ('F','P', 'B') "
   
   IF p_tela.cod_item IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
          "   AND cod_item = '",p_tela.cod_item,"' "
   END IF   

   IF p_tela.cod_familia IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
          "   AND cod_item = '",p_tela.cod_familia,"' "
   END IF   

   IF p_tela.ies_tip_item IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED,
          "   AND ies_tip_item = '",p_tela.ies_tip_item,"' "
   END IF   


   LET p_cus_unit_medio     = 0 
   LET p_cus_unit_medio_ini = 0 
   LET p_cus_unit_normal    = 0 
   LET p_cus_unit_rev       = 0 
   LET p_qtd_mes_ant        = 0 
   LET p_qtd_mes_ant_ini    = 0 
   LET p_qtd_mes_normal     = 0 
   LET p_qtd_mes_rev        = 0 


   PREPARE var_query FROM sql_stmt   
   DECLARE cq_item CURSOR FOR var_query
         
   FOREACH cq_item INTO 
           p_cod_item, p_cod_local_estoq
         
      SELECT qtd_mes_ant,
             cus_unit_medio
        INTO p_qtd_mes_ant_ini,
             p_cus_unit_medio_ini
        FROM estoque_hist
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
         AND ano_mes_ref = ( SELECT MAX (ano_mes_ref)
                               FROM estoque_hist
                              WHERE cod_empresa = p_cod_empresa
                                AND cod_item = p_cod_item
                                AND ano_mes_ref < p_ano_mes)

      IF SQLCA.sqlcode = NOTFOUND THEN
         LET p_qtd_mes_ant = 0
         LET p_cus_unit_medio = 0
      END IF

      LET p_pre_contab = NULL
      
      DISPLAY p_cod_item AT 21,50
     
#----- Leitura do movimento de entrada do mes  Normal     
     
    SELECT sum(qtd_movto),
           sum(cus_tot_movto_p)
      INTO   
           p_qtd_mes_normal,
           p_cus_tot_normal  
      FROM estoque_trans 
     WHERE cod_empresa          = p_cod_empresa
       AND ies_tip_movto        = 'N'
       AND MONTH(dat_movto)   = p_tela.mes_ref
       AND  YEAR(dat_movto)   = p_tela.ano_ref
       AND cod_operacao         in (select cod_operacao from estoque_operac
                                    where cod_empresa='01'  and ies_tipo = 'E')
            
     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("LEITURA NORMAL","estoque_trans")
     END IF
     
     IF p_qtd_mes_normal IS NULL THEN
        LET p_qtd_mes_normal = 0
     END IF

     IF p_cus_tot_normal IS NULL THEN
        LET p_cus_tot_normal = 0
     END IF
     
  #----- Leitura do movimento de entrada do mes  reversao    
     
    SELECT sum(qtd_movto),
           sum(cus_tot_movto_p)
      INTO   
           p_qtd_mes_rev,
           p_cus_tot_rev  
      FROM estoque_trans 
     WHERE cod_empresa          = p_cod_empresa
       AND ies_tip_movto        = 'R'
       AND MONTH(dat_movto)   = p_tela.mes_ref
       AND  YEAR(dat_movto)   = p_tela.ano_ref
       AND cod_operacao         in (select cod_operacao from estoque_operac
                                    where cod_empresa='01'  and ies_tipo = 'E')
            
     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("LEITURA REVERSAO","estoque_trans")
     END IF  

     IF p_qtd_mes_rev IS NULL THEN
        LET p_qtd_mes_rev = 0
     END IF
     
     IF p_cus_tot_rev IS NULL THEN
        LET p_cus_tot_rev = 0
     END IF
         
      DECLARE cq_spe CURSOR FOR
       SELECT total
         FROM spe_contab_prod
        WHERE cod_item = p_cod_item
    
      FOREACH cq_spe INTO p_pre_contab
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_spe')
            RETURN FALSE
         END IF
         
         EXIT FOREACH
         
      END FOREACH

      IF p_pre_contab IS NULL THEN
         CONTINUE FOREACH
      END IF
      
      LET p_val_cus_medio_ini = p_qtd_mes_ant_ini * p_cus_unit_medio_ini
      
      LET p_qtd_mes_ent  = p_qtd_mes_normal - p_qtd_mes_rev
      
      LET p_val_cus_medio_ent  = (p_cus_tot_normal - p_cus_tot_rev)
      
      LET p_val_contab = (p_qtd_mes_ant_ini + p_qtd_mes_ent)  * p_pre_contab
      
      LET p_val_medio  = p_val_cus_medio_ini + p_val_cus_medio_ent
      
      
      IF p_val_contab > p_val_medio THEN
         LET p_val_movto = p_val_contab - p_val_cus_medio
         LET p_cod_operac = p_cod_oper_ent
         LET p_estoque_trans.cod_local_est_dest = p_cod_local_estoq
         LET p_estoque_trans.ies_sit_est_dest   = 'L' 
      ELSE
         LET p_val_movto = p_val_cus_medio - p_val_contab
         LET p_cod_operac = p_cod_oper_sai
         LET p_estoque_trans.cod_local_est_orig = p_cod_local_estoq
         LET p_estoque_trans.ies_sit_est_orig   = 'L' 
      END IF
      
      IF p_val_movto = 0 THEN
         CONTINUE FOREACH
      END IF

      DISPLAY p_cod_item TO cod_item
      
      IF NOT pol1006_ins_est_trans() THEN
         RETURN FALSE
      END IF

      IF NOT pol1006_ins_est_trans_end() THEN
         RETURN FALSE
      END IF

      IF NOT pol1006_ins_est_auditoria() THEN
         RETURN FALSE
      END IF

     LET p_count = p_count + 1
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1006_ins_est_trans()
#-------------------------------#

      SELECT num_conta
        INTO p_num_conta
        FROM item_sup
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item_sup')
         RETURN FALSE
      END IF
      
      LET p_estoque_trans.cod_empresa        = p_cod_empresa
      LET p_estoque_trans.num_transac        = 0
      LET p_estoque_trans.cod_item           = p_cod_item
      LET p_estoque_trans.dat_movto          = p_tela.dat_movto
      LET p_estoque_trans.dat_ref_moeda_fort = TODAY
      LET p_estoque_trans.dat_proces         = TODAY
      LET p_estoque_trans.hor_operac         = TIME
      LET p_estoque_trans.ies_tip_movto      = "N"                    
      LET p_estoque_trans.cod_operacao       = p_cod_operac
      LET p_estoque_trans.num_prog           = "POL1006"
      LET p_estoque_trans.num_docum          = NULL 
      LET p_estoque_trans.num_seq            = NULL
      LET p_estoque_trans.cus_unit_movto_p   = p_val_movto
      LET p_estoque_trans.cus_tot_movto_p    = p_val_movto
      LET p_estoque_trans.cus_unit_movto_f   = 0
      LET p_estoque_trans.cus_tot_movto_f    = 0
      LET p_estoque_trans.num_conta          = p_num_conta
      LET p_estoque_trans.num_secao_requis   = NULL
      LET p_estoque_trans.nom_usuario        = p_user
      LET p_estoque_trans.qtd_movto          = 0
      LET p_estoque_trans.num_lote_orig      = NULL 
      LET p_estoque_trans.num_lote_dest      = NULL 

      INSERT INTO estoque_trans VALUES (p_estoque_trans.*)

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INSERÇÃO","ESTOQUE_TRANS")
         RETURN FALSE
      END IF

     LET p_estoque_trans.num_transac = SQLCA.SQLERRD[2]

     RETURN TRUE
     
END FUNCTION

#-----------------------------------#
FUNCTION pol1006_ins_est_trans_end()
#-----------------------------------#

     LET p_estoque_trans_end.cod_empresa = p_cod_empresa
     LET p_estoque_trans_end.num_transac = p_estoque_trans.num_transac
     LET p_estoque_trans_end.endereco =  " "
     LET p_estoque_trans_end.num_volume = 0
     LET p_estoque_trans_end.qtd_movto = p_estoque_trans.qtd_movto
     LET p_estoque_trans_end.cod_grade_1 = " "
     LET p_estoque_trans_end.cod_grade_2 = " "
     LET p_estoque_trans_end.cod_grade_3 = " "
     LET p_estoque_trans_end.cod_grade_4 = " "
     LET p_estoque_trans_end.cod_grade_5 = " "
     LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.vlr_temperatura = 0
     LET p_estoque_trans_end.endereco_origem = " "
     LET p_estoque_trans_end.num_ped_ven = 0
     LET p_estoque_trans_end.num_seq_ped_ven = 0
     LET p_estoque_trans_end.dat_hor_producao = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_validade = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.num_peca = " "
     LET p_estoque_trans_end.num_serie = " "
     LET p_estoque_trans_end.comprimento = 0
     LET p_estoque_trans_end.largura = 0
     LET p_estoque_trans_end.altura = 0
     LET p_estoque_trans_end.diametro = 0
     LET p_estoque_trans_end.dat_hor_reserv_1 = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_reserv_2 = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_reserv_3 = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.qtd_reserv_1 = 0
     LET p_estoque_trans_end.qtd_reserv_2 = 0
     LET p_estoque_trans_end.qtd_reserv_3 = 0
     LET p_estoque_trans_end.num_reserv_1 = 0
     LET p_estoque_trans_end.num_reserv_2 = 0
     LET p_estoque_trans_end.num_reserv_3 = 0
     LET p_estoque_trans_end.tex_reservado = " "
     LET p_estoque_trans_end.cus_unit_movto_p = 0
     LET p_estoque_trans_end.cus_unit_movto_f = 0
     LET p_estoque_trans_end.cus_tot_movto_p = 0
     LET p_estoque_trans_end.cus_tot_movto_f = 0
     LET p_estoque_trans_end.cod_item = p_estoque_trans.cod_item
     LET p_estoque_trans_end.dat_movto = p_estoque_trans.dat_movto
     LET p_estoque_trans_end.cod_operacao = p_estoque_trans.cod_operacao
     LET p_estoque_trans_end.dat_movto = p_estoque_trans.dat_movto
     LET p_estoque_trans_end.ies_tip_movto = p_estoque_trans.ies_tip_movto
     LET p_estoque_trans_end.num_prog = "pol1006"

     INSERT INTO estoque_trans_end
        VALUES (p_estoque_trans_end.*)

     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INSERÇÃO","ESTOQUE_TRANS_END")
        RETURN FALSE
     END IF
     
     RETURN TRUE
     
END FUNCTION

#-----------------------------------#
FUNCTION pol1006_ins_est_auditoria()
#-----------------------------------#

     INSERT INTO estoque_auditoria 
        VALUES(p_cod_empresa, 
               p_estoque_trans.num_transac, 
               p_user, p_estoque_trans.dat_movto,'pol1006')

     IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INSERÇÃO","estoque_auditoria")
        RETURN FALSE
     END IF
        
   RETURN TRUE
   
END FUNCTION
