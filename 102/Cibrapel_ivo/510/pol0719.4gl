#-------------------------------------------------------------------#
# SISTEMA.: VALORIZACAO DE ESTOQUE - MOVIMENTO CQV                  #
# PROGRAMA: pol0719                                                 #
# MODULOS.: pol0719-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: VALORIZAÇÃO DO ESTOQUE C/ BASE NA ENTRADA DO AR         #
# DATA....: 21/01/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_dat_inicio         CHAR(10),
          p_dat_fim            CHAR(10),
          p_cod_oper_ent_vrqtd LIKE estoque_trans.cod_operacao,                     
          p_cod_operac_estoq_c LIKE estoque_trans.cod_operacao,  
          p_prox_fec           LIKE par_estoque.dat_prx_fecha_est,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_ies_situacao       LIKE item.ies_situacao,
          p_dat_txt            CHAR(10),
          p_dia_txt            CHAR(02),
          p_ano_mes_ref        CHAR(06),
          p_ano_mes_fec        CHAR(06),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
#         p_versao             CHAR(17),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(80),
          p_msg                CHAR(100)
          
   DEFINE p_tela               RECORD
          mes_ref              CHAR(02),
          ano_ref              CHAR(04)
   END RECORD

   DEFINE    p_empresas_885        RECORD LIKE empresas_885.*,
             p_estoque_trans_cqv   RECORD LIKE estoque_trans.*,
             p_estoque_trans_ar    RECORD LIKE estoque_trans.*


END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0719-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0719.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#   CALL log001_acessa_usuario("VDP")
  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0719_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0719_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0719") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0719 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa mês e ano de referência"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0719_informar() THEN
            NEXT OPTION 'Processar'
         END IF
      COMMAND "Processar" "Processa a valorizacao do estoque - CQV"
         HELP 001
         MESSAGE ""
         LET int_flag = 0
         IF p_ies_cons THEN 
            IF log005_seguranca(p_user,"VDP","pol0719","IN") THEN
               IF log004_confirm(19,41) THEN
                  CALL log085_transacao("BEGIN")
                  IF pol0719_processa() THEN
                     MESSAGE "Foram Processado(s) ",p_count,' Item(ns).'
                        ATTRIBUTE(REVERSE)
                     CALL log085_transacao("COMMIT")
                  ELSE
                     MESSAGE "Erro no Processamento !!!" ATTRIBUTE(REVERSE)
                     CALL log085_transacao("ROLLBACK")
                  END IF
                  NEXT OPTION "Fim"
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF
            END IF
         ELSE
            ERROR "Informe os parâmetros previamente !!!"
            NEXT OPTION "Informar"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0719_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Sai do programa"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0719

END FUNCTION

#--------------------------#
FUNCTION pol0719_informar()
#--------------------------#

   DEFINE p_ano_fec, p_mes_fec, p_resto  SMALLINT

 SELECT *
     INTO p_empresas_885.*
     FROM empresas_885
    WHERE cod_emp_gerencial = p_cod_empresa
       OR cod_emp_oficial  = p_cod_empresa
            
   IF SQLCA.sqlcode = NOTFOUND THEN
      ERROR 'Registro nao encontrada na tabela empresas_885'
      RETURN FALSE
   ELSE
      IF sqlca.sqlcode <> 0 THEN
         ERROR 'Problemas na leitura Empresas_885- Erro nº ', STATUS
         CALL log003_err_sql("LEITURA","EMPRESAS_885")
         RETURN FALSE
      END IF
   END IF
   
   SELECT cod_oper_ent_vrqtd
     INTO p_cod_oper_ent_vrqtd
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF SQLCA.sqlcode = NOTFOUND THEN
      ERROR 'Parametro nao encontrado na tabela PARAMETRO_885'
      RETURN FALSE
   END IF

   SELECT cod_operac_estoq_c
     INTO p_cod_operac_estoq_c
     FROM par_sup
    WHERE cod_empresa = p_empresas_885.cod_emp_oficial

   IF SQLCA.sqlcode = NOTFOUND THEN
      ERROR 'Parametro nao encontrado na tabela PARAMETRO_SUP'
      RETURN FALSE
   END IF

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0719
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela, p_ano_mes_ref TO NULL
   
   SELECT dat_prx_fecha_est
     INTO p_prox_fec
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","par_estoque")
      RETURN FALSE
   END IF
   
   DISPLAY p_prox_fec TO prox_fec
   
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
         
         IF p_empresas_885.cod_emp_oficial = p_cod_empresa THEN
            ERROR 'Esta empresa nao permite processar este programa !!!'
            NEXT FIELD mes_ref
         END IF
         
      AFTER FIELD ano_ref
         IF p_tela.ano_ref IS NULL THEN
            ERROR 'Informe o ano de referência !!!'
            NEXT FIELD ano_ref
         END IF
         IF p_tela.ano_ref < 1 THEN
            ERROR 'Ano Inválido !!!'
            NEXT FIELD ano_ref
         END IF

      LET p_ano_mes_ref = p_tela.ano_ref, p_tela.mes_ref
      INITIALIZE p_ano_mes_fec TO NULL
      LET p_ano_fec = YEAR(p_prox_fec)
      LET p_mes_fec = MONTH(p_prox_fec)
  
      LET p_ano_mes_fec = p_ano_fec  
      LET p_ano_mes_fec = p_ano_mes_fec CLIPPED, p_mes_fec  USING '&&'
            
      IF p_ano_mes_ref < p_ano_mes_fec THEN
         ERROR 'Já foi efetuado o fechamento p/ esse período !!!'
         NEXT FIELD mes_ref
      END IF
      
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
      
      LET p_dat_txt = '01','/',p_tela.mes_ref,'/', p_tela.ano_ref
      LET p_dat_inicio  = p_dat_txt
      
      LET p_dat_txt = p_dia_txt,'/',p_tela.mes_ref,'/', p_tela.ano_ref
      LET p_dat_fim  = p_dat_txt
      
   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
   ELSE
      LET p_ies_cons = FALSE
      DISPLAY '' TO mes_ref
      DISPLAY '' TO ano_ref
   END IF

   RETURN(p_ies_cons)

END FUNCTION
#--------------------------#
FUNCTION pol0719_processa()
#--------------------------#
   MESSAGE "Aguarde. Processando ..." ATTRIBUTE(REVERSE)
    
      LET p_count = 0  
      DECLARE cq_est_cqv CURSOR FOR 
       SELECT *
         FROM estoque_trans  
        WHERE cod_empresa      = p_empresas_885.cod_emp_gerencial
          AND cod_operacao     = p_cod_oper_ent_vrqtd
          AND ies_tip_movto    = 'N'
          AND dat_movto       >= p_dat_inicio
          AND dat_movto       <= p_dat_fim
          AND cus_unit_movto_p = 0 
        ORDER BY dat_movto 

      FOREACH cq_est_cqv INTO p_estoque_trans_cqv.*
      
          IF pol0719_le_movto_ar()  =  FALSE  THEN
             CONTINUE FOREACH
          END IF  

      END FOREACH
  
   RETURN TRUE
   
END FUNCTION
#----------------------------#
FUNCTION pol0719_le_movto_ar()
#----------------------------#
     DECLARE cq_est_ar CURSOR FOR
       SELECT *
         FROM estoque_trans  
        WHERE cod_empresa      = p_empresas_885.cod_emp_oficial
          AND cod_operacao     = p_cod_operac_estoq_c
          AND ies_tip_movto    = 'N'
          AND dat_movto       >= p_dat_inicio
          AND dat_movto       <= p_dat_fim
          AND num_docum        = p_estoque_trans_cqv.num_docum
          AND cod_item         = p_estoque_trans_cqv.cod_item
          AND num_seq          = p_estoque_trans_cqv.num_seq
          AND cus_unit_movto_p > 0 
        ORDER BY b.dat_movto 

      FOREACH cq_est_ar INTO p_estoque_trans_ar.*
      
          IF p_estoque_trans_ar.cus_unit_movto_p  >  0  THEN
             UPDATE estoque_trans 
             SET cus_unit_movto_p   = p_estoque_trans_ar.cus_unit_movto_p,
                 cus_tot_movto_p    = p_estoque_trans_ar.cus_tot_movto_p
             WHERE cod_empresa      = p_estoque_trans_cqv.cod_empresa
               AND cod_operacao     = p_estoque_trans_cqv.cod_operacao
               AND ies_tip_movto    = 'N'
               AND dat_movto        = p_estoque_trans_cqv.dat_movto
               AND num_docum        = p_estoque_trans_cqv.num_docum
               AND cod_item         = p_estoque_trans_cqv.cod_item
               AND num_seq          = p_estoque_trans_cqv.num_seq
               IF STATUS <> 0 THEN
                  CALL log003_err_sql("UPDATE","Estoque_trans")
                  RETURN FALSE
               ELSE
                  LET p_count = p_count + 1    
              END IF
           END IF
      END FOREACH
  
   RETURN TRUE
   
END FUNCTION 

#-----------------------#
 FUNCTION pol0719_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION