DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_cod_emp_oper       LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_oper_ent_vrqtd LIKE estoque_trans.cod_operacao,                     
          p_dat_movto          LIKE estoque_trans.dat_movto,  
          p_prox_fec           LIKE par_estoque.dat_prx_fecha_est,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_ies_situacao       LIKE item.ies_situacao,
          p_cod_grupo_item     LIKE item_vdp.cod_grupo_item,
          p_pre_unit           DECIMAL(15,4),
          p_num_transac        INTEGER,
          p_cod_item           CHAR(15),
          p_cod_emp            CHAR(02),
          p_dat_txt            CHAR(10),
          p_dia_txt            CHAR(02),
          p_ano_mes_ref        CHAR(06),
          p_ano_mes_fec        CHAR(06),
          p_dat_sup            DATE,
          p_dat_est            DATE,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_des_erro           CHAR(060),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(80)
          
   DEFINE p_tela               RECORD
          cod_empresa          CHAR(02),
          cod_item             LIKE item.cod_item,
          den_item             LIKE item.den_item,
          num_docum            CHAR(06) 
   END RECORD

   DEFINE p_tmp_item   RECORD
      cod_empresa  CHAR(02),
      cod_item     CHAR(15),
      pre_unit     DECIMAL(15,4)
   END RECORD

   DEFINE    p_empresas_885        RECORD LIKE empresas_885.*,
             p_estoque_trans       RECORD LIKE estoque_trans.*

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0973-05.10.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0973.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0973_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0973_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0973") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0973 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa dados"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0973_informar() THEN
            NEXT OPTION 'Processar'
         END IF
      COMMAND "Processar" "Processa a valorizacao do estoque - IMPL"
         HELP 001
         MESSAGE ""
         LET int_flag = 0
         IF p_ies_cons THEN 
            IF log005_seguranca(p_user,"VDP","pol0973","IN") THEN
               IF log004_confirm(19,41) THEN
                  CALL log085_transacao("BEGIN")
                  IF pol0973_processa() THEN
                     MESSAGE "Movimento atualizados"
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
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Sai do programa"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0973

END FUNCTION

#--------------------------#
FUNCTION pol0973_informar()
#--------------------------#
 DEFINE l_count   INTEGER
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0973
   CLEAR FORM
   
   INITIALIZE p_tela TO NULL
   LET p_tela.cod_empresa = p_cod_empresa
   DISPLAY p_tela.cod_empresa TO cod_empresa
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD cod_item
         IF p_tela.cod_item IS NULL THEN
            ERROR 'Informe o Item !!!'
            NEXT FIELD cod_item
         ELSE
            SELECT den_item 
              INTO p_tela.den_item
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item = p_tela.cod_item
            IF SQLCA.sqlcode <> 0 THEN 
               ERROR 'ITEM INEXIXTENTE '
               NEXT FIELD cod_item
            ELSE
               DISPLAY p_tela.den_item TO den_item   
            END IF          
         END IF

      AFTER FIELD num_docum
         IF p_tela.num_docum IS NULL THEN
            ERROR 'Informe o documento !!!'
            NEXT FIELD num_docum
         ELSE
            SELECT cod_emp_gerencial
              INTO p_cod_emp_oper  
              FROM empresas_885  
	           WHERE cod_emp_oficial = p_cod_empresa
	          IF SQLCA.sqlcode <> 0 THEN 
               SELECT cod_emp_oficial
                 INTO p_cod_emp_oper  
                 FROM empresas_885  
	              WHERE cod_emp_gerencial = p_cod_empresa
	             IF SQLCA.sqlcode <> 0 THEN 
	                LET p_cod_emp_oper = p_cod_empresa 
	             END IF 
	          END IF       
         END IF 
   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
   END IF

   RETURN(p_ies_cons)

END FUNCTION

#--------------------------#
FUNCTION pol0973_processa()
#--------------------------#
DEFINE l_count  INTEGER 
   MESSAGE "Aguarde. Processando ..." ATTRIBUTE(REVERSE)
    
      LET p_count = 0  

       SELECT MIN(dat_movto)
        INTO  p_dat_movto 
         FROM estoque_trans
        WHERE cod_empresa  = p_cod_empresa
          AND cod_item  = p_tela.cod_item
          AND num_docum = p_tela.num_docum 
          AND (cod_operacao = 'AR' OR 
               cod_operacao = 'TREN' OR   
               cod_operacao = 'TRGD')
               
       UPDATE estoque_trans SET dat_movto =  p_dat_movto
        WHERE cod_empresa  IN (p_cod_empresa, p_cod_emp_oper)
          AND cod_item = p_tela.cod_item
          AND cod_operacao IN ('INSP','CQV')
          AND num_docum    = p_tela.num_docum
          
       IF SQLCA.sqlcode <> 0 THEN 
          CALL log003_err_sql("UPDATE","estoque_trans")
          RETURN FALSE
       END IF 
 
   RETURN TRUE
   
END FUNCTION