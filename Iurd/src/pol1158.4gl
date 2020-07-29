#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1158                                                 #
# OBJETIVO: APROVAÇÃO DE DOCUMENTOS                                 #
# AUTOR...: IVO HB BL                                               #
# DATA....: 09/08/2012                                              #
#-------------------------------------------------------------------#
{
Empresa 16 - AR 93026
Empresa 25 - AR 344177
}

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_user_solict        LIKE usuario.nom_usuario,
          p_cod_user           LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_caminho_jar        CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_texto              CHAR(10),
          p_last_row           SMALLINT,
          p_opcao              CHAR(02),
          p_excluiu            SMALLINT

END GLOBALS

   DEFINE pr_cc ARRAY[20] OF RECORD
          cod_area_lin      CHAR(08),    
          den_estr_linprod  CHAR(30),   
          cod_cent_cust     CHAR(04),
          nom_cent_cust     CHAR(30),
          pct_particip_comp CHAR(03)
   END RECORD

         
   DEFINE p_dat_atu            DATE,
          p_hor_atu            CHAR(08),
          p_usuario            CHAR(10),
          p_dat_proces         CHAR(10),
          p_nom_func           CHAR(40),
          p_den_user           CHAR(40),
          p_den_email          CHAR(40),
          p_cod_aprovador      CHAR(02),
          p_aprovador          CHAR(02),
          p_cod_fornecedor     CHAR(15),
          p_num_docum          CHAR(10),
          p_niv_autorid        CHAR(02),
          p_empresa            CHAR(02),
          p_nivel              CHAR(02), 
          p_tipo               CHAR(01), 
          p_den_nivel          CHAR(30),
          p_ies_situacao       CHAR(01),
          p_campo_txt          CHAR(15),
          p_lib_pedido         SMALLINT,
          p_hieraq_user        INTEGER,
          p_hierarquia         INTEGER,
          p_numero             INTEGER,
          p_item               CHAR(15),
          p_desc               CHAR(76),
          p_ver_docum          INTEGER,
          P_ies_ar_cs          CHAR(10),
          p_num_nf             INTEGER,
          p_ser_nf             CHAR(03),
          p_ssr_nf             INTEGER,
          p_cod_emp_orig       CHAR(02),
          p_contrato           INTEGER,
          p_ver_cont           INTEGER,
          p_ar                 INTEGER,
          p_nao_achou          SMALLINT,
          p_txt_cont           CHAR(2000),
          p_servico            CHAR(15),
          p_sit_contrato       CHAR(01),
          p_cod_status         CHAR(01),
          p_qtd_ad             INTEGER,
          p_val_ad             DECIMAL(10,2),
          p_ies_soma           CHAR(01),
          p_ies_aprovar        CHAR(01),
          p_parcela            INTEGER, 
          p_vencto             DATE, 
          p_val_pagar          DECIMAL(12,2),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_le_ad              SMALLINT,
          p_ies_suspensa       CHAR(01),
          p_sit_ad             CHAR(10),
          p_sit_ped            CHAR(01),
          p_versao_ped         INTEGER,
          p_ies_imprimiu       SMALLINT,
          p_imp_doc            CHAR(01),
          p_ind_cc             INTEGER,
          p_val_ipi            DECIMAL(5,2)


   DEFINE p_cod_uni_funcio     LIKE usu_nivel_aut_cap.cod_uni_funcio,  
          p_ies_tip_autor      LIKE usu_nivel_aut_cap.ies_tip_autor,   
          p_cod_nivel_autor    LIKE usu_nivel_aut_cap.cod_nivel_autor, 
          p_cod_emp_usuario    LIKE usu_nivel_aut_cap.cod_emp_usuario, 
          p_emp_pend           LIKE usu_nivel_aut_cap.cod_empresa,
          p_cod_usuario        LIKE usuario_subs_cap.cod_usuario,
          p_num_ad             LIKE aprov_necessaria.num_ad,
          p_val_tot_nf         LIKE ad_mestre.val_tot_nf,
          p_dat_emis_nf        LIKE ad_mestre.dat_emis_nf,    
          p_dat_venc           LIKE ad_mestre.dat_venc,       
          p_cod_tip_despesa    LIKE tipo_despesa.cod_tip_despesa,
          p_ies_previsao       LIKE tipo_despesa.ies_previsao,   
          p_nom_tip_despesa    LIKE tipo_despesa.nom_tip_despesa,
          p_cod_grp_despesa    LIKE tipo_despesa.cod_grp_despesa,
          p_nom_grp_despesa    LIKE grupo_despesa.nom_grp_despesa,
          p_cod_comprador      CHAR(15),
          p_ies_forma_aprov    CHAR(01),
          p_cod_autorid        CHAR(02),
          p_ies_aceita         CHAR(01),
          p_situacao           CHAR(10),
          p_substituto         CHAR(01),
          p_aprova             CHAR(01),
          p_qtd_docum          INTEGER,
          p_val_total          DECIMAL(12,2),
          p_qtd_tot_ads        INTEGER,
          p_val_tot_ads        DECIMAL(12,2),
          p_ies_incl_cap       CHAR(01)

   
   DEFINE p_num_oc           LIKE  ordem_sup.num_oc,         
          p_num_versao       LIKE  ordem_sup.num_versao,     
          p_cod_item         LIKE  ordem_sup.cod_item,       
          p_cod_unid_med     LIKE  ordem_sup.cod_unid_med,     
          p_fat_conver_unid  LIKE  ordem_sup.fat_conver_unid,
          p_pre_unit_oc      LIKE  ordem_sup.pre_unit_oc,    
          p_qtd_solic        LIKE  ordem_sup.qtd_solic      

   DEFINE p_num_ver_oc       INTEGER,
          p_num_ver_pc       INTEGER,
          p_cnd_pgto         CHAR(04),
          p_cod_mod_embar    CHAR(01),
          p_cod_moeda        CHAR(01),
          p_dat_emis         DATE,
          p_val_tot_ped      DECIMAL(12,2),
          p_ies_situa_ped    CHAR(01),
          p_cod_transpor     CHAR(15),
          p_num_cotacao      INTEGER,
          p_num_ver_grade    INTEGER,
          p_ind_ad           INTEGER,
          p_qtd_msg          INTEGER,
          p_ies_controle     CHAR(01),
          p_txt_aprovante    CHAR(250),
          p_txt_emitente     CHAR(250),
          p_num_mensag       DECIMAL(3,0)

   DEFINE p_tp_docum         CHAR(02)
          

   DEFINE pr_docum             ARRAY[20000] OF RECORD
          ies_aprovar          CHAR(01),
          empresa              CHAR(02),
          estado               CHAR(02),
          num_docum            CHAR(10),
          num_versao           INTEGER,
          tip_docum            CHAR(10),
          nom_fornecedor       CHAR(30),
          dat_docum            DATE,
          val_docum            DECIMAL(12,2)
   END RECORD

   DEFINE pr_compl             ARRAY[20000] OF RECORD
          cod_fornecedor       CHAR(15),
          user_solicit         CHAR(08),
          unid_funcional       CHAR(10),
          cod_nivel_autorid    CHAR(02),
          ies_suspensa         CHAR(01),
          ies_situa_ped        CHAR(01),
          cod_uni_funcio       CHAR(15)
   END RECORD

   DEFINE pr_tipo             ARRAY[5000] OF RECORD
          ies_aprovar         CHAR(01),
          empresa             CHAR(02),
          estado              CHAR(02),
          cod_tip_despesa     DECIMAL(4,0),
          nom_tip_despesa     CHAR(30),
          qtd_ads             INTEGER,
          val_ads             DECIMAL(12,2)
  END RECORD

   DEFINE pr_usuario           ARRAY[10] OF RECORD
          cod_usuario          CHAR(10),
          nom_funcionario      CHAR(30)
   END RECORD

   DEFINE pr_txt_ad            ARRAY[30] OF RECORD
          num_mensag           DECIMAL(3,0),
          txt_aprovante        CHAR(250),
          txt_emitente         CHAR(250)
   END RECORD          

   DEFINE p_param              RECORD
          aprova_ar            CHAR(01),
          aprova_cs            CHAR(01),
          aprova_ad            CHAR(01),
          aprova_pc            CHAR(01)
   END RECORD          
   
   DEFINE p_tip_docum      CHAR(03),
          p_cod_empre      CHAR(02),
          p_email_usuario  CHAR(50),
          p_nom_usuario    CHAR(50),
          p_email_emitente CHAR(50),
          p_nom_emitente   CHAR(50),
          p_den_comando    CHAR(80),
          p_imp_linha      CHAR(80),
          p_den_docum      CHAR(30),
          p_titulo         CHAR(50),
          p_assunto        CHAR(30),
          p_user_para      CHAR(08),
          m_tip_docum      CHAR(10),
    	    m_num_docum      CHAR(10),
	        m_num_versao     CHAR(02),
	        m_cod_empresa    CHAR(02),
	        m_query          CHAR(800)

   DEFINE p_qtd_docs INTEGER,
          p_val_tot  DECIMAL(12,2)

DEFINE p_parametro   RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 15
   DEFER INTERRUPT
   LET p_versao = "pol1158-10.02.69"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET p_parametro.num_programa = 'POL1158'
   LET p_parametro.cod_empresa = p_cod_empresa
   LET p_parametro.usuario = p_user
  
   IF p_status = 0 THEN
      CALL pol1158_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1158_menu()
#----------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1158") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1158 AT 1,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol1158_cria_temp() THEN
      CLOSE WINDOW w_pol1158
      RETURN
   END IF

   MENU "OPCAO"
      COMMAND "Selecionar" "Seleciona documentos p/ aprovação"
         IF pol1158_selecionar() THEN
            IF pol1158_processar() THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               CALL pol1158_limpa_tela()
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            CALL pol1158_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "AD/Tip despesa" "Aprovação de AD (FINANCEIRO) pot tipo de despesa"
         IF pol1158_tip_despesa() THEN
            LET p_msg = 'Operação efetuada com sucesso !!!'
         ELSE
            CALL pol1158_limpa_tela()
            IF p_msg IS NULL THEN
               LET p_msg = 'Operação cancelada !!!'
            END IF
         END IF 
         CALL log0030_mensagem(p_msg, 'excla')
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1158_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1158

END FUNCTION

#------------------------#
 FUNCTION pol1158_sobre()#
#------------------------#

{
   LET pr_docum[1].ies_aprovar = 'N'
   LET pr_docum[1].empresa     = '01' 
   LET pr_docum[1].estado      = 'SP'  
   LET pr_docum[1].num_docum   = '577'
   LET pr_docum[1].num_versao  = ' '
   LET pr_docum[1].tip_docum   =  'NOTA'
   LET pr_docum[1].nom_fornecedor = '043837780000131'
   LET pr_docum[1].dat_docum   = '26/11/2010'  
   LET pr_docum[1].val_docum   = 100
   
   LET P_IND = 2

   IF NOT pol1158_sel_documto() THEN
      RETURN FALSE
   END IF

   
}

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
   
#---------------------------#
FUNCTION pol1158_cria_temp()#
#---------------------------#

   DROP TABLE nivel_temp_265
   CREATE TEMP TABLE nivel_temp_265(
     empresa         CHAR(02), 
     nivel_autorid   CHAR(02), 
     tipo_autorid    CHAR(01), 
     den_nivel       CHAR(30),
     tip_docum       CHAR(02))   

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","NIVEL_TEMP_265")
			RETURN FALSE
	 END IF

   DROP TABLE email_temp_265
   CREATE TEMP TABLE email_temp_265(
      id_registro    SERIAL,
	    num_docum      CHAR(10),
	    num_versao     CHAR(02),
	    tip_docum      CHAR(10),
	    cod_empresa    CHAR(02),
	    cod_usuario    CHAR(10),
	    email_usuario  CHAR(50),
	    nom_usuario    CHAR(50),
	    cod_emitente   CHAR(10),
	    email_emitente CHAR(50),
	    nom_emitente   CHAR(50)
	 )

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","email_temp_265")
			RETURN FALSE
	 END IF

   DROP TABLE cc_ad_temp_265
   CREATE TEMP TABLE cc_ad_temp_265
    (
      cod_empresa      CHAR(2), 
      cod_centro_custo DECIMAL(4,0), 
      num_ad           DECIMAL(6,0)
   )

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","cc_ad_temp_265")
			RETURN FALSE
	 END IF

   DROP TABLE ad_aprov_temp_265
   CREATE TEMP TABLE ad_aprov_temp_265 (
      aprova           CHAR(1), 
      empresa          CHAR(2), 
      num_ad           DECIMAL(6,0), 
      valor_ad         DECIMAL(15,2), 
      dat_emis         DATE, 
      dat_venc         DATE, 
      situacao         CHAR(10), 
      substituto       CHAR(1), 
      cod_nivel_autor  CHAR(2), 
      cod_tip_despesa  DECIMAL(4,0), 
      den_tipo_despesa CHAR(30), 
      cod_grupo_desp   DECIMAL(4,0), 
      den_grupo_desp   CHAR(30), 
      cod_uni_funcio   CHAR(10),
      ies_soma         CHAR(01),
      ies_suspensa     CHAR(01)
   )

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","ad_aprov_temp_265:CREATE")
			RETURN FALSE
	 END IF

   DROP TABLE usu_niv_temp_265
   CREATE TEMP TABLE usu_niv_temp_265 (
      cod_emp_usuario   CHAR(2), 
      cod_uni_funcional CHAR(10),  
      cod_nivel_autor   CHAR(2),   
      situacao          CHAR(10),   
      ies_tip_autor     CHAR(1),   
      substituto        CHAR(01),   
      empresa           CHAR(2)
   )         

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","usu_niv_temp_265")
			RETURN FALSE
	 END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1158_del_temp()#
#--------------------------#

   DELETE FROM nivel_temp_265
   DELETE FROM email_temp_265
   DELETE FROM cc_ad_temp_265
   DELETE FROM ad_aprov_temp_265
   DELETE FROM usu_niv_temp_265

END FUNCTION

#----------------------------#
FUNCTION pol1158_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#----------------------------#
FUNCTION pol1158_selecionar()#
#----------------------------#

   CALL pol1158_limpa_tela()
   CALL pol1158_del_temp()
   
   LET p_dat_atu = TODAY

   INITIALIZE p_param TO NULL
   LET p_param.aprova_ar = 'S'
   LET p_param.aprova_cs = 'S'
   LET p_param.aprova_ad = 'S'
   LET p_param.aprova_pc = 'S'
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_param.* WITHOUT DEFAULTS

      AFTER INPUT
         IF NOT INT_FLAG THEN

            IF p_param.aprova_ar = 'S' OR
               p_param.aprova_cs = 'S' OR
               p_param.aprova_ad = 'S' OR
               p_param.aprova_pc = 'S' THEN
            ELSE
               ERROR 'Selecione pelomenos um tipo de documento!'
               NEXT FIELD aprova_ar
            END IF

         END IF

   END INPUT 

   IF INT_FLAG THEN
      LET p_msg = NULL
      RETURN FALSE
   END IF
   
   IF NOT pol1158_carrega_documto() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1158_carrega_documto()#
#---------------------------------#

   INITIALIZE pr_docum, pr_compl TO NULL

   LET p_ind = 1
   LET p_val_total = 0

   IF p_param.aprova_ad = 'S' THEN
      IF NOT pol1158_le_ad() THEN
         RETURN FALSE
      END IF
      IF p_le_ad THEN
         IF NOT pol1158_carga_ads() THEN
            RETURN FALSE
         END IF  
      END IF
   END IF

   IF p_param.aprova_ar = 'S' OR 
      p_param.aprova_cs = 'S' OR 
      p_param.aprova_pc = 'S' THEN
      
      INITIALIZE p_cod_user, p_niv_autorid TO NULL

      IF NOT pol1158_sel_usuario() THEN
         RETURN FALSE
      END IF
   
      IF NOT pol1158_le_niv_autorid() THEN
         RETURN FALSE
      END IF
      
   END IF

   IF p_param.aprova_ar = 'S' AND p_ind < 20000 THEN
      IF NOT pol1158_le_ar('NOTA') THEN
         RETURN FALSE
      END IF
   END IF

   IF p_param.aprova_cs = 'S' AND p_ind < 20000 THEN
      IF NOT pol1158_le_ar('CONTRATO') THEN
         RETURN FALSE
      END IF
   END IF

   IF p_param.aprova_pc = 'S' AND p_ind < 20000 THEN
      IF NOT pol1158_le_pc() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_ind = 1 THEN
      LET p_msg = 'Não a documento a serem aprovados\n',
                  'para os parâmetros informados.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET p_qtd_docum = p_ind - 1
   
   DISPLAY p_qtd_docum TO qtd_docum
   DISPLAY p_val_total TO val_total
   
   IF NOT pol1158_sel_documto() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1158_sel_documto()#
#-----------------------------#
   
   DEFINE p_tip_docum      CHAR(10),
          p_marca          CHAR(01),
          p_ies_marca      SMALLINT,
          p_qtd_linha      INTEGER,
          p_docum          CHAR(06)
   
   LET p_ies_marca  = FALSE
   LET INT_FLAG = FALSE
   LET p_qtd_linha = p_ind - 1
   
   CALL SET_COUNT(p_ind - 1)

   INPUT ARRAY pr_docum
      WITHOUT DEFAULTS FROM sr_docum.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  
         
         LET p_docum = '  AR  '
         
         IF pr_docum[p_ind].tip_docum = 'FINANCEIRO' THEN
            LET p_docum = '  AD  '
         ELSE
            IF pr_docum[p_ind].tip_docum = 'COMPRAS' THEN
               LET p_docum = 'Pedido'
            END IF
         END IF
         
         DISPLAY p_docum AT 10,10
         
      AFTER FIELD ies_aprovar
      
         IF pr_docum[p_ind].ies_aprovar = 'S' AND pr_compl[p_ind].ies_suspensa = 'S' THEN
            LET p_msg = 'AD suspensa!. Utilize Ctrl+Z,\n para acesar os detalhes.'
            CALL log0030_mensagem(p_msg,'excla')
            LET pr_docum[p_ind].ies_aprovar = 'N'
            DISPLAY pr_docum[p_ind].ies_aprovar TO sr_docum[s_ind].ies_aprovar
            NEXT FIELD ies_aprovar
         END IF

         IF pr_docum[p_ind].ies_aprovar = 'S' AND pr_docum[p_ind].tip_docum = 'COMPRAS' THEN
            IF pr_compl[p_ind].ies_situa_ped = 'A' THEN
            ELSE
               LET p_msg = 'Pedido Liberado ou Cancelado!\n',
                           'Aprovação não permitida.'
               CALL log0030_mensagem(p_msg,'excla')
               LET pr_docum[p_ind].ies_aprovar = 'N'
               DISPLAY pr_docum[p_ind].ies_aprovar TO sr_docum[s_ind].ies_aprovar
               NEXT FIELD ies_aprovar
            END IF
         END IF

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_ind >= p_qtd_linha THEN
               NEXT FIELD ies_aprovar
            END IF
         END IF
         
      ON KEY (control-t)
         LET p_ies_marca = NOT p_ies_marca
         IF p_ies_marca THEN
            LET p_marca = 'S'
         ELSE
            LET p_marca = 'N'
         END IF
         FOR p_count = 1 TO ARR_COUNT()
             LET pr_docum[p_count].ies_aprovar = p_marca
             DISPLAY p_marca TO sr_docum[p_count].ies_aprovar 
         END FOR
         LET INT_FLAG = FALSE

      ON KEY (control-p)
         LET p_tip_docum =  pr_docum[p_ind].tip_docum
         IF p_tip_docum IS NOT NULL THEN
            LET p_empresa = pr_docum[p_ind].empresa
            LET p_num_docum = pr_docum[p_ind].num_docum
            CASE pr_docum[p_ind].tip_docum
               WHEN 'NOTA'       CALL pol1158_textos_ar()
               WHEN 'CONTRATO'   CALL pol1158_textos_cs()
               WHEN 'COMPRAS'    CALL pol1158_textos_pc()
               WHEN 'FINANCEIRO' CALL pol1158_textos_ad()
            END CASE
         END IF
         LET INT_FLAG = FALSE

      ON KEY (control-z)
         LET p_tip_docum =  pr_docum[p_ind].tip_docum
         IF p_tip_docum IS NOT NULL THEN
            LET p_empresa = pr_docum[p_ind].empresa
            LET p_num_docum = pr_docum[p_ind].num_docum
            CASE pr_docum[p_ind].tip_docum
               WHEN 'NOTA'       CALL pol1158_dados_ar()
               WHEN 'CONTRATO'   CALL pol1158_dados_cs()
               WHEN 'COMPRAS'    CALL pol1158_dados_pc()
               WHEN 'FINANCEIRO' CALL pol1158_dados_ad()
            END CASE
         END IF
         LET INT_FLAG = FALSE

      ON KEY (control-l)
         LET p_index = p_qtd_linha
         LET p_imp_doc = 'S'
         CALL pol1158_lista_docs()         

      ON KEY (control-d)
         LET m_tip_docum =  pr_docum[p_ind].tip_docum
         IF m_tip_docum IS NOT NULL THEN
            LET m_cod_empresa = pr_docum[p_ind].empresa
            LET m_num_docum = pr_docum[p_ind].num_docum
            LET m_num_versao = pr_docum[p_ind].num_versao
            CALL pol1158_le_despesas()
         END IF
         LET INT_FLAG = FALSE
         
      AFTER INPUT
         IF NOT INT_FLAG THEN
            LET p_count = 0
            FOR p_index = 1 TO ARR_COUNT()
                IF pr_docum[p_index].num_docum IS NOT NULL THEN
                   IF pr_docum[p_index].ies_aprovar = 'S' THEN
                      LET p_count = p_count + 1
                   END IF
                END IF
            END FOR       
            IF p_count = 0 THEN
               LET p_msg = 'Por favor, selecione pelomenos um documento!'
               CALL log0030_mensagem(p_msg,'excla')
               NEXT FIELD ies_aprovar
            END IF
         END IF

   END INPUT
   
   IF INT_FLAG THEN
      LET p_msg = NULL
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1158_dados_ar()#
#--------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11582") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11582 AT 02,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_ar()

   CLOSE WINDOW w_pol11582

END FUNCTION

#--------------------------#
FUNCTION pol1158_dados_cs()#
#--------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1158b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1158b AT 02,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_ar()

   CLOSE WINDOW w_pol1158b

END FUNCTION

#--------------------------#
FUNCTION pol1158_exibe_ar()#
#--------------------------# 

   DEFINE pr_ar ARRAY[50] OF RECORD
      num_seq             INTEGER,       
      cod_item            CHAR(15),
      den_item        	  CHAR(18),
      cod_unid_med        CHAR(02),
      qtd_recebida        DECIMAL(10,3),
      pre_unit_nf         DECIMAL(12,2),    
      val_liquido_item    DECIMAL(12,2),
      nom_usuario         CHAR(08)
   END RECORD
   
   DEFINE pr_vencto ARRAY[50] OF RECORD
          num_parcela     CHAR(10),
          dat_vencto      CHAR(10),
          val_parcela     DECIMAL(10,2)
   END RECORD
   
   DEFINE p_dat_emis_nf     DATE,
          p_val_tot_nf      DECIMAL(10,2),
          p_cod_fornecedor  CHAR(15),
          p_raz_social      CHAR(45),
          p_linha           INTEGER,
          s_linha           INTEGER
   
   SELECT a.num_nf,
          a.ser_nf,
          a.ssr_nf,
          a.dat_emis_nf,   
          a.val_tot_nf_d,    
          a.cod_fornecedor,
          b.raz_social
     INTO p_num_nf,     
          p_ser_nf,  
          p_ssr_nf, 
          p_dat_emis_nf,   
          p_val_tot_nf,    
          p_cod_fornecedor,
          p_raz_social    
     FROM nf_sup a,
          fornecedor b
    WHERE a.cod_empresa   = pr_docum[p_ind].empresa
      AND a.num_aviso_rec = pr_docum[p_ind].num_docum
      AND a.cod_fornecedor = b.cod_fornecedor

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','nf_sup e fornecedor')
      RETURN
   END IF
   
   SELECT ies_ar_cs
     INTO p_ies_ar_cs
     FROM nfe_aprov_265
    WHERE cod_empresa   = pr_docum[p_ind].empresa  
      AND num_aviso_rec = pr_docum[p_ind].num_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','nfe_aprov_265')
      RETURN
   END IF
   
   LET p_linha = 1
   
   IF p_ies_ar_cs = 'NOTA' THEN
      DECLARE cq_nf CURSOR FOR
       SELECT num_docum,
              dat_vencto,
              val_docum
         FROM vencimento_nff
        WHERE cod_empresa = pr_docum[p_ind].empresa
          AND num_nf = p_num_nf
          AND ser_nf = p_ser_nf
          AND ssr_nf = p_ssr_nf
          AND cod_fornecedor = p_cod_fornecedor
      FOREACH cq_nf INTO 
              pr_vencto[p_linha].num_parcela,
              pr_vencto[p_linha].dat_vencto,
              pr_vencto[p_linha].val_parcela
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','vencimento_nff')
            RETURN
         END IF
         LET p_linha = p_linha + 1        
      END FOREACH
   ELSE
      LET p_cod_emp_orig = pr_docum[p_ind].empresa
      LET p_ar = pr_docum[p_ind].num_docum
      LET p_opcao = 'CS'
      IF NOT pol1158_obtem_contrato() THEN
         RETURN
      END IF
      LET pr_vencto[p_linha].num_parcela = p_parcela
      LET pr_vencto[p_linha].dat_vencto = p_vencto
      LET pr_vencto[p_linha].val_parcela = p_val_pagar
      LET p_linha = p_linha + 1 
   END IF

   DISPLAY pr_docum[p_ind].empresa TO cod_empresa   
   DISPLAY p_num_nf TO num_nf
   DISPLAY p_ser_nf TO ser_nf
   DISPLAY pr_docum[p_ind].num_docum TO num_aviso_rec   
   DISPLAY pr_docum[p_ind].tip_docum TO tip_docum   
   DISPLAY p_dat_emis_nf TO dat_emis_nf  
   DISPLAY p_val_tot_nf TO val_tot_nf  
   DISPLAY p_cod_fornecedor TO cod_fornecedor  
   DISPLAY p_raz_social TO nom_fornecedor  
   
   IF p_ies_ar_cs = 'CONTRATO' THEN
      DISPLAY p_contrato TO contrato_servico
      DISPLAY p_ver_cont TO versao_contrato
      DISPLAY p_sit_contrato TO sit_contrato
      DISPLAY p_servico TO servico
   END IF

   IF p_linha > 1 THEN
      CALL SET_COUNT(p_linha - 1)
      INPUT ARRAY pr_vencto 
         WITHOUT DEFAULTS FROM sr_vencto.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF
  
   LET p_index = 1
   
   DECLARE cq_le_ars CURSOR FOR
    SELECT a.num_seq,        
           a.cod_item,       
           b.den_item,       
           b.cod_unid_med,   
           a.qtd_recebida,   
           a.pre_unit_nf,    
           a.val_liquido_item
      FROM aviso_rec a, item b
     WHERE a.cod_empresa   = pr_docum[p_ind].empresa
       AND a.num_aviso_rec = pr_docum[p_ind].num_docum
       AND a.cod_empresa   = b.cod_empresa
       AND a.cod_item      = b.cod_item
   
   FOREACH cq_le_ars INTO 
      pr_ar[p_index].num_seq,         
      pr_ar[p_index].cod_item,        
      pr_ar[p_index].den_item,        
      pr_ar[p_index].cod_unid_med,    
      pr_ar[p_index].qtd_recebida,    
      pr_ar[p_index].pre_unit_nf,     
      pr_ar[p_index].val_liquido_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_le_etapa')
         EXIT FOREACH
      END IF
      
      SELECT nom_usuario
        INTO pr_ar[p_index].nom_usuario
        FROM audit_ar
       WHERE cod_empresa = pr_docum[p_ind].empresa
         AND num_aviso_rec = pr_docum[p_ind].num_docum
         AND num_seq = pr_ar[p_index].num_seq
         AND ies_tipo_auditoria = 1
      
      IF STATUS <> 0 THEN
         LET pr_ar[p_index].num_seq = ''
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 50 THEN
         CALL log0030_mensagem('Limite de linhas esgotado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_index = 1 THEN
      CALL log0030_mensagem('Erro lendo dados da NFE','excla')
      RETURN
   END IF
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_ar WITHOUT DEFAULTS FROM sr_ar.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      BEFORE FIELD num_seq
         LET p_num_seq = pr_ar[p_index].num_seq 
         
      AFTER FIELD num_seq
         
         LET pr_ar[p_index].num_seq = p_num_seq
         DISPLAY p_num_seq to sr_ar[s_index].num_seq

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            LET p_count = p_index + 1
            IF p_count > 50 OR pr_ar[p_count].cod_item IS NULL OR
               pr_ar[p_count].cod_item = ' ' THEN
               NEXT FIELD num_seq
            END IF
         END IF

      ON KEY (control-t)
         IF p_num_seq IS NOT NULL THEN
            LET p_numero = pr_docum[p_ind].num_docum 
            LET p_item = pr_ar[p_index].cod_item
            LET p_desc = pr_ar[p_index].den_item
            IF p_ies_ar_cs = 'NOTA' THEN
               CALL pol1158_textos_it()
            ELSE
               #CALL pol1158_textos_cs()
            END IF
         END IF
         LET INT_FLAG = FALSE
         
   END INPUT
         
END FUNCTION

#---------------------------#
FUNCTION pol1158_textos_it()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1158a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11584 AT 02,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_txt_it()

   CLOSE WINDOW w_pol1158a

END FUNCTION

#------------------------------#
FUNCTION pol1158_exibe_txt_it()#
#------------------------------#

   DEFINE pr_texto ARRAY[20] OF RECORD
      num_seq_ar   INTEGER,
      texto        CHAR(60)
   END RECORD

   DEFINE p_linha, s_linha INTEGER

   IF NOT pol1158_le_nota() THEN
      RETURN
   END IF
   
   DISPLAY p_item TO cod_item
   DISPLAY p_desc TO den_item
   
   LET p_linha = 1
   
   DECLARE cq_txt_it CURSOR FOR
    SELECT seq_aviso_recebto, 
           observacao,
           sequencia_texto
      FROM sup_obs_ar
     WHERE empresa = pr_docum[p_ind].empresa
       AND aviso_recebto = pr_docum[p_ind].num_docum
       AND seq_aviso_recebto = p_num_seq
     ORDER BY sequencia_texto

   FOREACH cq_txt_it INTO 
           pr_texto[p_linha].num_seq_ar,
           pr_texto[p_linha].texto
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','sup_obs_ar')
         RETURN
      END IF
      
      LET p_linha = p_linha + 1

      IF p_linha > 20 THEN
         CALL log0030_mensagem('Limite de linhas esgotado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_linha = 1 THEN
      LET p_msg = 'Não há textos para o AR ', pr_docum[p_ind].num_docum, '\n',
                  'e sequência ', p_num_seq
      CALL log0030_mensagem(p_msg,'excla')
      RETURN
   END IF                    
   
   CALL SET_COUNT(p_linha - 1)
   
   DISPLAY ARRAY pr_texto TO sr_texto.*

END FUNCTION   

#---------------------------#
FUNCTION pol1158_textos_ar()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11584") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11584 AT 02,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_txt_ar()

   CLOSE WINDOW w_pol11584

END FUNCTION

#------------------------------#
FUNCTION pol1158_exibe_txt_ar()#
#------------------------------#

   DEFINE pr_texto ARRAY[20] OF RECORD
      num_seq_ar   INTEGER,
      texto        CHAR(60)
   END RECORD

   DEFINE p_linha, s_linha INTEGER

   IF NOT pol1158_le_nota() THEN
      RETURN
   END IF
      
   LET p_linha = 1
   
   DECLARE cq_txt CURSOR FOR
    SELECT seq_aviso_recebto, 
           observacao,
           sequencia_texto
      FROM sup_obs_ar
     WHERE empresa = pr_docum[p_ind].empresa
       AND aviso_recebto = pr_docum[p_ind].num_docum
     ORDER BY seq_aviso_recebto, sequencia_texto

   FOREACH cq_txt INTO 
           pr_texto[p_linha].num_seq_ar,
           pr_texto[p_linha].texto
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','sup_obs_ar')
         RETURN
      END IF
      
      LET p_linha = p_linha + 1

      IF p_linha > 20 THEN
         CALL log0030_mensagem('Limite de linhas esgotado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_linha = 1 THEN
      LET p_msg = 'Não há textos para o AR ', pr_docum[p_ind].num_docum, '\n',
                  'e sequência ', p_num_seq
      CALL log0030_mensagem(p_msg,'excla')
      RETURN
   END IF                    
   
   CALL SET_COUNT(p_linha - 1)
   
   DISPLAY ARRAY pr_texto TO sr_texto.*

END FUNCTION   

#-------------------------#
FUNCTION pol1158_le_nota()#
#-------------------------#

   SELECT num_nf,
          ser_nf,
          ssr_nf,
          dat_emis_nf
     INTO p_num_nf,     
          p_ser_nf,
          p_ssr_nf,
          p_dat_emis_nf
     FROM nf_sup
    WHERE cod_empresa   = pr_docum[p_ind].empresa
      AND num_aviso_rec = pr_docum[p_ind].num_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','nf_sup e fornecedor')
      RETURN
   END IF

   DISPLAY pr_docum[p_ind].empresa TO cod_empresa
   DISPLAY p_num_nf TO num_nf
   DISPLAY p_dat_emis_nf TO dat_emis
   DISPLAY pr_docum[p_ind].num_docum TO num_ar
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1158_textos_cs()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11583") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11583 AT 02,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_txt_cs()

   CLOSE WINDOW w_pol11583

END FUNCTION

#------------------------------#
FUNCTION pol1158_exibe_txt_cs()#
#------------------------------#

   DEFINE pr_texto ARRAY[15] OF RECORD
      texto        CHAR(70)
   END RECORD

   DEFINE p_linha, s_linha   INTEGER

   IF NOT pol1158_le_nota() THEN
      RETURN
   END IF

   LET p_cod_emp_orig = pr_docum[p_ind].empresa
   LET p_ar = pr_docum[p_ind].num_docum
   LET p_opcao = 'CS'
   
   IF NOT pol1158_obtem_contrato() THEN
      RETURN
   END IF
      
   DISPLAY p_contrato TO contrato_servico
   DISPLAY p_ver_cont TO versao_contrato
   DISPLAY p_sit_contrato TO sit_contrato
   DISPLAY p_servico TO servico
   
   IF p_txt_cont IS NULL OR p_txt_cont = ' ' THEN
      CALL log0030_mensagem('Contrato não contém texto!','excla')
      RETURN
   END IF
   
   CALL pol1161_quebrar_texto(p_txt_cont, 70, 15, 'N') RETURNING
      pr_texto[01].texto, pr_texto[02].texto, pr_texto[03].texto,
      pr_texto[04].texto, pr_texto[05].texto, pr_texto[06].texto,
      pr_texto[07].texto, pr_texto[08].texto, pr_texto[09].texto,
      pr_texto[10].texto, pr_texto[11].texto, pr_texto[12].texto,
      pr_texto[13].texto, pr_texto[14].texto, pr_texto[15].texto
   
   LET p_linha = 12
   
   CALL SET_COUNT(p_linha)
   
   DISPLAY ARRAY pr_texto TO sr_texto.*

END FUNCTION   

#---------------------------#
FUNCTION pol1158_textos_pc()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11589") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11589 AT 02,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_txt_pc()

   CLOSE WINDOW w_pol11589

END FUNCTION

#------------------------------#
FUNCTION pol1158_exibe_txt_pc()#
#------------------------------#

   DEFINE pr_texto ARRAY[20] OF RECORD
      num_seq      INTEGER,
      texto        CHAR(60)
   END RECORD

   DEFINE p_linha, s_linha INTEGER

   DISPLAY pr_docum[p_ind].empresa     TO cod_empresa
   DISPLAY pr_docum[p_ind].num_docum   TO num_docum
   DISPLAY pr_docum[p_ind].num_versao  TO num_versao
   DISPLAY pr_docum[p_ind].dat_docum   TO dat_emis
   
   LET p_linha = 1
   
   DECLARE cq_txt_pc CURSOR FOR
    SELECT num_seq, 
           tex_observ_pedido
      FROM pedido_sup_txt
     WHERE cod_empresa = pr_docum[p_ind].empresa
       AND num_pedido  = pr_docum[p_ind].num_docum
       AND ies_tip_texto <> "M"                     #ies_tip_texto NOT IN ('J','K')
     ORDER BY num_seq

   FOREACH cq_txt_pc INTO 
           pr_texto[p_linha].num_seq,
           pr_texto[p_linha].texto
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','sup_obs_ar')
         RETURN
      END IF
      
      LET p_linha = p_linha + 1

      IF p_linha > 20 THEN
         CALL log0030_mensagem('Limite de linhas esgotado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_linha = 1 THEN
      LET p_msg = 'Não há textos para o pedido ', pr_docum[p_ind].num_docum
      CALL log0030_mensagem(p_msg,'excla')
      RETURN
   END IF                    
   
   CALL SET_COUNT(p_linha - 1)
   
   DISPLAY ARRAY pr_texto TO sr_texto.*

END FUNCTION   

#--------------------------------#
FUNCTION pol1158_obtem_contrato()#
#--------------------------------#

   LET p_nao_achou = TRUE   
   
   DECLARE cq_cs CURSOR FOR
    SELECT contrato_servico, 
           versao_contrato,
           parcela,
           dat_vencto,
           val_pagar
      FROM cos_pagto_etapa 
     WHERE empresa = p_cod_emp_orig
      AND filial = 0 
      AND nota_fiscal = p_num_nf
      AND serie_nota_fiscal = p_ser_nf
      AND subserie_nf = p_ssr_nf
      AND hist_pagto[750, 755] = p_ar
   
   FOREACH cq_cs INTO p_contrato, p_ver_cont,
           p_parcela, p_vencto, p_val_pagar

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_cs')
         RETURN FALSE
      END IF
      
      IF p_contrato > 0 AND p_ver_cont > 0 THEN
         LET p_nao_achou = FALSE
      END IF
      
      EXIT FOREACH
      
   END FOREACH
   
   IF p_nao_achou THEN
      IF p_opcao = 'CS' THEN
         CALL log0030_mensagem('Contrato não localizado!','excla')
      END IF
      RETURN FALSE
   END IF
   
   SELECT objeto_contrato,
          servico,
          sit_contrato
     INTO p_txt_cont,
          p_servico,
          p_sit_contrato
     FROM cos_contr_servico
    WHERE empresa = p_cod_emp_orig
      AND filial = 0
      AND contrato_servico = p_contrato
      AND versao_contrato = p_ver_cont

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cos_contr_servico')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1158_dados_pc()#
#--------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11585") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11585 AT 02,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_pc()

   CLOSE WINDOW w_pol11585

END FUNCTION

#--------------------------#
FUNCTION pol1158_exibe_pc()#
#--------------------------# 

   DEFINE pr_oc ARRAY[150] OF RECORD
      num_oc              INTEGER,       
      ies_situa_oc        CHAR(01),
      cod_item            CHAR(15),
      ies_estoque         CHAR(01),
      den_item        	  CHAR(18),
      cod_unid_med        CHAR(02),
      saldo_oc            DECIMAL(10,3),
      pre_unit_oc         DECIMAL(12,2)
   END RECORD

   DEFINE p_num_pedido      INTEGER,
          p_num_versao      INTEGER,
          p_ies_situa       CHAR(01),
          p_dat_emis        DATE,
          p_nom_comprador   CHAR(30),
          p_val_tot_ped     DECIMAL(10,2),
          p_cod_fornecedor  CHAR(15),
          p_raz_social      CHAR(50),
          l_cod_tip_desp    CHAR(04),
          l_num_pedido      INTEGER
   
   LET l_cod_tip_desp = NULL
   LET p_val_ipi = 0
   LET l_num_pedido = pr_docum[p_ind].num_docum 
   
   DECLARE cq_pri_desp CURSOR FOR
    SELECT DISTINCT cod_tip_despesa 
      FROM ordem_sup 
     WHERE cod_empresa = pr_docum[p_ind].empresa 
       AND num_pedido = l_num_pedido
       AND num_versao_pedido = pr_docum[p_ind].num_versao
       AND ies_versao_atual = 'S' 
       AND ies_situa_oc <> 'C' 
   
   FOREACH cq_pri_desp INTO l_cod_tip_desp 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Tipo de despesa')
         RETURN
      END IF
      
      IF l_cod_tip_desp IS NOT NULL THEN
         
         SELECT cod_tip_despesa FROM despesa_import_265
          WHERE cod_empresa = p_cod_empresa
            AND cod_tip_despesa = l_cod_tip_desp
         
         IF STATUS = 0 THEN

            SELECT SUM(qtd_solic * pre_unit_oc * (pct_ipi / 100))
              INTO p_val_ipi
              FROM ordem_sup 
             WHERE cod_empresa = pr_docum[p_ind].empresa 
               AND num_pedido = l_num_pedido
               AND num_versao_pedido = pr_docum[p_ind].num_versao
               AND ies_versao_atual = 'S' 
               AND ies_situa_oc <> 'C' 

            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','ordem_sup:val_ipi')
               RETURN
            END IF
            
            IF p_val_ipi IS NULL THEN
               LET p_val_ipi = 0
            END IF

         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('SELECT','despesa_import_265')
               RETURN
            END IF
         END IF
      END IF            
      
      EXIT FOREACH
      
   END FOREACH
         
   SELECT a.num_pedido,
          a.num_versao,
          a.ies_situa_ped,
          a.dat_emis,   
          a.cod_comprador,
          c.nom_comprador,
          a.val_tot_ped,    
          a.cod_fornecedor,
          b.raz_social
     INTO p_num_pedido,    
          p_num_versao,    
          p_ies_situa,
          p_dat_emis,        
          p_cod_comprador, 
          p_nom_comprador,            
          p_val_tot_ped,                
          p_cod_fornecedor,           
          p_raz_social               
     FROM pedido_sup a,
          fornecedor b,
          comprador c
    WHERE a.cod_empresa   = pr_docum[p_ind].empresa
      AND a.num_pedido    = pr_docum[p_ind].num_docum
      AND a.num_versao    = pr_docum[p_ind].num_versao
      AND a.cod_fornecedor = b.cod_fornecedor
      AND a.cod_empresa    = c.cod_empresa
      AND a.cod_comprador  = c.cod_comprador

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','pedido_sup/fornecedor/comprador')
      RETURN
   END IF
   
   LET p_val_tot_ped = p_val_tot_ped - p_val_ipi
   
   DISPLAY pr_docum[p_ind].empresa TO cod_empresa   
   DISPLAY p_num_pedido TO num_pedido
   DISPLAY p_num_versao TO num_versao
   DISPLAY p_ies_situa TO ies_situa_ped
   DISPLAY p_dat_emis TO dat_emis
   DISPLAY p_cod_comprador TO cod_comprador  
   DISPLAY p_nom_comprador TO nom_comprador  
   DISPLAY p_val_tot_ped TO val_tot_ped  
   DISPLAY p_cod_fornecedor TO cod_fornecedor  
   DISPLAY p_raz_social TO raz_social  
  
   LET p_index = 1
   
   DECLARE cq_le_ocs CURSOR FOR
    SELECT a.num_oc,
           a.ies_situa_oc,        
           a.cod_item,  
           a.ies_item_estoq,     
           b.den_item,       
           a.cod_unid_med,   
           (a.qtd_solic - a.qtd_recebida),   
           a.pre_unit_oc   
      FROM ordem_sup a, item b
     WHERE a.cod_empresa   = pr_docum[p_ind].empresa
       AND a.num_pedido    = pr_docum[p_ind].num_docum
       #AND a.num_versao_pedido = pr_docum[p_ind].num_versao
       AND a.ies_versao_atual = 'S'
       AND a.cod_empresa   = b.cod_empresa
       AND a.cod_item      = b.cod_item
       AND a.ies_situa_oc <> "C"
   
   FOREACH cq_le_ocs INTO 
      pr_oc[p_index].num_oc,       
      pr_oc[p_index].ies_situa_oc, 
      pr_oc[p_index].cod_item,  
      pr_oc[p_index].ies_estoque,
      pr_oc[p_index].den_item,     
      pr_oc[p_index].cod_unid_med, 
      pr_oc[p_index].saldo_oc,     
      pr_oc[p_index].pre_unit_oc  

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_le_ocs')
         EXIT FOREACH
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 150 THEN
         CALL log0030_mensagem('Limite de linhas esgotado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_index = 1 THEN
      CALL log0030_mensagem('Erro lendo dados da OC','excla')
      RETURN
   END IF
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_oc WITHOUT DEFAULTS FROM sr_oc.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
         LET p_num_oc = pr_oc[p_index].num_oc
         
         CALL pol1158_exibe_sa('1')
         DISPLAY p_usuario    TO cod_solicit
         DISPLAY p_den_user   TO nom_solicit
         DISPLAY p_dat_proces TO dat_solicit

         CALL pol1158_exibe_sa('2')
         DISPLAY p_usuario    TO cod_aprovan
         DISPLAY p_den_user   TO nom_aprovan
         DISPLAY p_dat_proces TO dat_aprovan
         
         CALL pol1158_exibe_cc(pr_docum[p_ind].empresa, pr_oc[p_index].cod_item, 
                 pr_oc[p_index].num_oc, pr_oc[p_index].ies_estoque)
         
      BEFORE FIELD ies_situa_oc
         LET p_ies_situa = pr_oc[p_index].ies_situa_oc 
         
      AFTER FIELD ies_situa_oc
         
         LET pr_oc[p_index].ies_situa_oc = p_ies_situa
         DISPLAY p_ies_situa to sr_ar[s_index].ies_situa_oc
         
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            LET p_count = p_index + 1
            IF p_count > 150 OR pr_oc[p_count].ies_situa_oc IS NULL OR
               pr_oc[p_count].ies_situa_oc = ' ' THEN
               NEXT FIELD ies_situa_oc
            END IF
         END IF

      ON KEY (control-q)
         LET p_count = p_ind
         CALL sup6722_exibe_mapa_comparativo(
            pr_docum[p_ind].empresa, pr_docum[p_ind].num_docum, 'S')
         LET p_ind = p_count
         
      ON KEY (control-p)
         IF p_ies_situa IS NOT NULL THEN
            LET p_numero = pr_oc[p_index].num_oc
            LET p_item = pr_oc[p_index].cod_item
            LET p_desc = pr_oc[p_index].den_item
            CALL pol1158_textos_oc()
         END IF
         LET INT_FLAG = FALSE
      
      ON KEY (control-t)
         LET p_sit_ped = pr_compl[p_ind].ies_situa_ped
         
         IF p_sit_ped = 'C' THEN
            ERROR 'Pedido já está cancelado!'
         ELSE
            IF p_sit_ped = 'L' THEN
               ERROR 'Pedido já está liquidado!'
            ELSE
               LET p_count = p_ind
               CALL pol1158_cancela_pc(pr_docum[p_ind].empresa, 
                 pr_docum[p_ind].num_docum, p_num_versao)
               LET p_ind = p_count
               LET pr_compl[p_ind].ies_situa_ped = p_sit_ped
            END IF
         END IF

      ON KEY (control-y)
         CALL pol1158_assinatura()

      ON KEY (control-a)
         IF p_ind_cc > 3 THEN
            CALL SET_COUNT(p_ind_cc)
            DISPLAY ARRAY pr_cc TO Sr_cc.*
         END IF
         
   END INPUT
         
END FUNCTION

#--------------------------------------#
FUNCTION pol1158_cancela_pc(           #
         m_empresa, m_pedido, m_versao)#
#--------------------------------------#

   DEFINE m_empresa CHAR(02),
          m_pedido  INTEGER,
          m_cont    INTEGER,
          m_versao  INTEGER
          
   SELECT COUNT(cod_empresa)
     INTO m_cont
     FROM ar_ped 
    WHERE cod_empresa = m_empresa 
      AND num_pedido  = m_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ar_ped')
      RETURN
   END IF
   
   IF m_cont = 0 THEN
      CALL log120_procura_caminho("SUP1600") RETURNING comando
      LET comando = comando CLIPPED," ",m_empresa, " ", m_pedido, " ", m_versao, " POL1158"
	    RUN comando RETURNING p_status
	    LET p_msg = NULL
	 ELSE
	    LET p_msg = 'Pedido já contém recebimento!.\n',
	                'Deseja liquidar o pedido?' 
	    IF log0040_confirm(20,25,p_msg) THEN
	       CALL sup6440_liquida_pc(m_empresa, m_pedido, m_versao)
	    ELSE
	       ERROR 'Operação cancelada!'
	       RETURN
	    END IF
	    LET p_msg = 'Liquidação de pedido\n',
	                'efetuada com sucesso!'
   END IF
    
   SELECT ies_situa_ped,
          num_versao
     INTO p_sit_ped,
          p_versao_ped
     FROM pedido_sup
    WHERE cod_empresa = m_empresa 
      AND num_pedido  = m_pedido
      AND ies_versao_atual = 'S'
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','pedido_sup')
      RETURN
   END IF
   
   IF p_sit_ped MATCHES '[CL]' THEN
      DISPLAY p_versao_ped TO num_versao
      DISPLAY p_sit_ped TO ies_situa_ped
      IF p_msg IS NOT NULL THEN
         CALL log0030_mensagem(p_msg,'information')
      END IF
   END IF
   
END FUNCTION
   
#--------------------------------#
FUNCTION pol1158_exibe_sa(p_tipo)#
#--------------------------------#
   
   DEFINE p_tipo CHAR(01)
   
   SELECT nom_usuario,
          dat_proces 
     INTO p_usuario,
          p_dat_proces
     FROM ordem_sup_audit
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_oc = p_num_oc
      AND ies_tipo_audit = p_tipo
   
   IF STATUS <> 0 THEN
      INITIALIZE p_usuario, p_dat_proces, p_den_user TO NULL
      RETURN
   END IF
   
   SELECT nom_funcionario 
     INTO p_den_user
     FROM usuarios 
    WHERE cod_usuario = p_usuario
    
   IF STATUS <> 0 THEN
      INITIALIZE p_den_user TO NULL
      RETURN
   END IF

END FUNCTION

#------------------------------------------------#
FUNCTION pol1158_exibe_cc(p_ce, p_ci, p_no, p_ie)#
#------------------------------------------------#
   
   DEFINE 
          p_cod_lin_prod   DECIMAL(2,0),
          p_cod_lin_recei  DECIMAL(2,0),
          p_cod_seg_merc   DECIMAL(2,0),
          p_cod_cla_uso    DECIMAL(2,0),
          p_conta          CHAR(25),
          p_cod_secao      CHAR(25),
          p_ce             CHAR(02),
          p_ci             CHAR(15),
          p_no             INTEGER,
          p_ie             CHAR(01),
          p_ies_tip_conta  INTEGER,
          p_cod_ccn        INTEGER,
          p_cod_ccc        CHAR(04)

   LET p_ind_cc = 1

   {IF p_ie IS NULL OR p_ie = 'S' THEN
      CALL SET_COUNT(p_ind_cc)
      INPUT ARRAY pr_cc WITHOUT DEFAULTS FROM sr_cc.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
      RETURN
   END IF}
 
   DECLARE cq_cc CURSOR FOR 
    SELECT pct_particip_comp,   
           num_conta_deb_desp,
           cod_secao_receb,
           cod_area_negocio,    
           cod_lin_negocio,
           cod_seg_merc,
           cod_cla_uso
      FROM dest_ordem_sup4
     WHERE cod_empresa = p_ce
       AND num_oc      = p_no
   
   FOREACH cq_cc INTO 
           pr_cc[p_ind_cc].pct_particip_comp,
           p_conta,
           p_cod_secao,
           p_cod_lin_prod,
           p_cod_lin_recei,
           p_cod_seg_merc, 
           p_cod_cla_uso  
                     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_cc')
         RETURN 
      END IF
      
      LET pr_cc[p_ind_cc].cod_area_lin = p_cod_lin_prod USING '&&', 
         p_cod_lin_recei USING '&&', p_cod_seg_merc USING '&&', p_cod_cla_uso USING '&&'

      SELECT den_estr_linprod 
        INTO pr_cc[p_ind_cc].den_estr_linprod
        FROM linha_prod
      WHERE cod_lin_prod  = p_cod_lin_prod
        AND cod_lin_recei = p_cod_lin_recei
        AND cod_seg_merc  = p_cod_seg_merc
        AND cod_cla_uso   = p_cod_cla_uso

      IF STATUS <> 0 THEN
         LET pr_cc[p_ind_cc].den_estr_linprod = ''
      END IF
      
      SELECT ies_tip_conta
        INTO p_ies_tip_conta
        FROM plano_contas
       WHERE cod_empresa = '99'
         AND num_conta_reduz = p_conta

      IF STATUS <> 0 THEN
         LET p_ies_tip_conta = 0
      END IF
      
      IF p_ies_tip_conta = 8 THEN
         LET p_cod_ccn = p_conta[1,4]
         LET p_cod_ccc = p_cod_ccn
      ELSE
         SELECT cod_centro_custo
           INTO p_cod_ccc
           FROM unidade_funcional
          WHERE cod_empresa = p_ce
            AND cod_uni_funcio = p_cod_secao
            AND DATE(dat_validade_ini) <= TODAY
            AND DATE(dat_validade_fim) >= TODAY
         IF STATUS <> 0 THEN
            LET p_cod_ccc = ' '
         END IF
      END IF
      
      LET pr_cc[p_ind_cc].cod_cent_cust = p_cod_ccc
      
      IF p_cod_ccc IS NULL OR p_cod_ccc = ' ' THEN
         LET pr_cc[p_ind_cc].nom_cent_cust = ''
      ELSE
         SELECT nom_cent_cust
           INTO pr_cc[p_ind_cc].nom_cent_cust
           FROM cad_cc
          WHERE cod_empresa   = '99'
            AND cod_cent_cust = pr_cc[p_ind_cc].cod_cent_cust
            AND ies_cod_versao IN 
                (SELECT MAX(ies_cod_versao) 
                   FROM cad_cc 
                  WHERE cod_empresa   = '99' 
                    AND cod_cent_cust = pr_cc[p_ind_cc].cod_cent_cust)

         IF STATUS <> 0 THEN
            LET pr_cc[p_ind_cc].nom_cent_cust = ''
         END IF
      END IF
      
      LET p_ind_cc = p_ind_cc + 1

      IF p_ind_cc > 20 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassado','excla')
         EXIT FOREACH
      END IF

   END FOREACH

   LET p_ind_cc = p_ind_cc - 1
   
   CALL SET_COUNT(p_ind_cc)
   
   #IF p_ind_cc <= 3 THEN
      INPUT ARRAY pr_cc WITHOUT DEFAULTS FROM sr_cc.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   #ELSE
   #   DISPLAY ARRAY pr_cc TO Sr_cc.*
   #END IF
   
END FUNCTION

#---------------------------#
FUNCTION pol1158_textos_oc()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11586") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11586 AT 02,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_txt_oc()

   CLOSE WINDOW w_pol11586
  
END FUNCTION

#------------------------------#
FUNCTION pol1158_exibe_txt_oc()#
#------------------------------#

   DEFINE pr_texto ARRAY[50] OF RECORD
      num_seq            INTEGER,
      ies_tip_texto      CHAR(01),
      tex_observ_oc      CHAR(60)
   END RECORD
   
   DEFINE p_linha, s_linha INTEGER

   DISPLAY pr_docum[p_ind].empresa to cod_empresa
   DISPLAY p_numero TO num_oc
   DISPLAY p_item TO cod_item
   DISPLAY p_desc TO den_item

   LET p_linha = 1

   DECLARE cq_ordem_sup_txt_arg CURSOR FOR
    SELECT num_seq,
           ies_tip_texto, 
           tex_observ_oc
      FROM ordem_sup_txt 
     WHERE cod_empresa = pr_docum[p_ind].empresa
       AND num_oc = p_numero
       AND ies_tip_texto IN ('P','C','O','J','S') 
     ORDER BY ies_tip_texto, num_seq

   FOREACH cq_ordem_sup_txt_arg INTO
      pr_texto[p_linha].num_seq,      
      pr_texto[p_linha].ies_tip_texto,
      pr_texto[p_linha].tex_observ_oc
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ordem_sup_txt_arg')
         RETURN
      END IF
      
      LET p_linha = p_linha + 1

      IF p_linha > 50 THEN
         CALL log0030_mensagem('Limite de linhas esgotado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_linha = 1 THEN
      LET p_msg = 'Não há textos para a OC ', p_numero
      CALL log0030_mensagem(p_msg,'excla')
      RETURN
   END IF                    
   
   CALL SET_COUNT(p_linha - 1)
   
   DISPLAY ARRAY pr_texto TO sr_texto.*

END FUNCTION   

#---------------------------#
FUNCTION pol1158_textos_ad()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11588") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11588 AT 02,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_txt_ad()

   CLOSE WINDOW w_pol11588


END FUNCTION

#------------------------------#
FUNCTION pol1158_exibe_txt_ad()
#------------------------------#

   DEFINE p_num_ad            INTEGER,
          p_dat_emis_nf       DATE,
          p_val_tot_nf        DECIMAL(10,2),
          p_dat_venc          DATE
   
   SELECT num_ad,
          dat_emis_nf,
          val_tot_nf,
          dat_venc,
          num_nf,     
          ser_nf,     
          ssr_nf,     
          cod_empresa_orig,
          cod_fornecedor
     INTO p_num_ad,         
          p_dat_emis_nf,    
          p_val_tot_nf,     
          p_dat_venc,
          p_num_nf,     
          p_ser_nf,     
          p_ssr_nf,     
          p_cod_emp_orig,
          p_cod_fornecedor
     FROM ad_mestre 
    WHERE cod_empresa = p_empresa
      AND num_ad      = p_num_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ad_mestre:eta')
      RETURN
   END IF
   
   DISPLAY p_empresa TO cod_empresa   
   DISPLAY p_num_ad TO num_ad
   DISPLAY p_dat_emis_nf TO dat_emis_nf
   DISPLAY p_val_tot_nf TO val_tot_nf
   DISPLAY p_dat_venc TO dat_venc
   DISPLAY p_num_nf TO num_nf
   DISPLAY p_ser_nf TO ser_nf
   DISPLAY p_ssr_nf TO ssr_nf
   DISPLAY p_cod_emp_orig TO cod_emp_orig
   
   SELECT num_ad
     FROM ad_contrato_265
    WHERE cod_empresa = p_empresa
      AND num_ad      = p_num_docum

   IF STATUS = 100 THEN
      IF NOT pol1158_ve_se_contrato() THEN
         RETURN
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ad_contrato_265')
         RETURN
      END IF
   END IF
       
   IF NOT pol1158_le_txt_ad() THEN
      RETURN
   END IF
   
   IF p_qtd_msg > 0 THEN
      LET p_ind_ad = 1
      CALL pol1158_pega_txt_ad()
   ELSE
      LET p_num_mensag = ''
      LET p_txt_aprovante = ''
   END IF
   
   LET INT_FLAG = FALSE
   
   INPUT p_ies_controle   
      WITHOUT DEFAULTS
         FROM ies_controle   

      AFTER FIELD ies_controle
         
         IF p_ies_controle = 'S' THEN
            IF p_ind_ad < p_qtd_msg THEN
               LET p_ind_ad = p_ind_ad + 1
               CALL pol1158_pega_txt_ad()
            ELSE
               LET p_msg = 'Não existem mais\n textos nessa direção!'
               CALL log0030_mensagem(p_msg,'exclamation')
            END IF
         END IF

         IF p_ies_controle = 'A' THEN
            IF p_ind_ad > 1 THEN
               LET p_ind_ad = p_ind_ad - 1
               CALL pol1158_pega_txt_ad()
            ELSE
               LET p_msg = 'Não existem mais\n textos nessa direção!'
               CALL log0030_mensagem(p_msg,'exclamation')
            END IF
         END IF

         IF p_ies_controle = 'E' THEN
            IF p_num_mensag IS NULL OR p_num_mensag = 0 THEN
            ELSE
               IF log004_confirm(6,10) THEN
                  CALL pol1158_del_texto()
               END IF
            END IF
         END IF

         IF p_ies_controle = 'M' THEN
            IF p_num_mensag IS NULL OR p_num_mensag = 0 THEN
            ELSE
               CALL pol1158_mod_texto()
            END IF
         END IF

         IF p_ies_controle = 'I' THEN
            CALL pol1158_inc_texto()
         END IF
         
         NEXT FIELD ies_controle
         
      ON KEY (control-t)
         CALL pol1158_popup()
         LET INT_FLAG = FALSE
           
   END INPUT 

END FUNCTION

#---------------------------#
FUNCTION pol1158_le_txt_ad()
#---------------------------#

   INITIALIZE pr_txt_ad TO NULL
   LET p_ind_ad = 1

   DECLARE cq_txt_ad CURSOR FOR
    SELECT num_mensag,
           txt_msg_aprovante,
           txt_msg_digitador
      FROM cap_msg_susp_aprov          
     WHERE empresa = p_empresa
       AND apropr_desp = p_num_docum
   
   FOREACH cq_txt_ad INTO pr_txt_ad[p_ind_ad].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','CQ_TXT_AD')
         RETURN FALSE
      END IF
      
      LET p_ind_ad = p_ind_ad + 1
   
   END FOREACH
   
   LET p_ind_ad = p_ind_ad - 1
   LET p_qtd_msg = p_ind_ad
   
   RETURN TRUE

END FUNCTION

#-----------------------------#   
FUNCTION pol1158_pega_txt_ad()#
#-----------------------------#

   IF p_ind_ad > 0 AND p_ind_ad <= 30 THEN
      LET p_txt_aprovante = pr_txt_ad[p_ind_ad].txt_aprovante
      LET p_txt_emitente = pr_txt_ad[p_ind_ad].txt_emitente         
      LET p_num_mensag = pr_txt_ad[p_ind_ad].num_mensag
   ELSE
      INITIALIZE p_txt_aprovante, p_txt_emitente, p_num_mensag  TO NULL
   END IF
   
   DISPLAY p_num_mensag TO num_mensag         
   DISPLAY p_txt_aprovante TO txt_aprovante
   DISPLAY p_txt_emitente TO txt_emitente

END FUNCTION   

#--------------------------------#
FUNCTION pol1158_ve_se_contrato()#
#--------------------------------#

   SELECT num_aviso_rec
     INTO p_ar
     FROM nf_sup
    WHERE cod_empresa = p_cod_emp_orig
      AND num_nf = p_num_nf
      AND ser_nf = p_ser_nf
      AND ssr_nf = p_ssr_nf
      AND cod_fornecedor = p_cod_fornecedor

   IF STATUS = 100 THEN
      LET p_txt_cont = NULL
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','NF_SUP')
         RETURN FALSE
      END IF
   END IF
   
   LET p_opcao = 'AD'
   
   IF NOT pol1158_obtem_contrato() THEN
      RETURN
   END IF
   
   LET p_txt_cont = p_txt_cont CLIPPED

   IF p_txt_cont IS NULL OR p_txt_cont = ' ' THEN
      RETURN TRUE
   END IF

   IF NOT pol1158_junta_txt() THEN
      RETURN FALSE
   END IF
   
   INSERT INTO ad_contrato_265
     VALUES(p_empresa,  
            p_num_docum)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','ad_contrato_265')
      RETURN FALSE
   END IF
            
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1158_junta_txt()#
#---------------------------#

   DEFINE p_lin_txt INTEGER

   DEFINE pr_texto  ARRAY[10] OF RECORD
      texto         CHAR(200)
   END RECORD

   SELECT MAX(num_mensag)
     INTO p_num_mensag
     FROM cap_msg_susp_aprov
    WHERE empresa = pr_docum[p_ind].empresa  
      AND apropr_desp = pr_docum[p_ind].num_docum   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','cap_msg_susp_aprov')
      RETURN FALSE
   END IF
   
   IF p_num_mensag IS NULL THEN
      LET p_num_mensag = 0
   END IF
   
   CALL pol1161_quebrar_texto(p_txt_cont, 200, 10, 'N') RETURNING
      pr_texto[01].texto, pr_texto[02].texto, pr_texto[03].texto,
      pr_texto[04].texto, pr_texto[05].texto, pr_texto[06].texto,
      pr_texto[07].texto, pr_texto[08].texto, pr_texto[09].texto,
      pr_texto[10].texto

   LET p_hor_atu = TIME
   
   FOR p_lin_txt = 1 TO 10
       IF pr_texto[p_lin_txt].texto IS NOT NULL THEN
          LET p_num_mensag = p_num_mensag + 1
          INSERT INTO cap_msg_susp_aprov(
             empresa,
             apropr_desp,
             num_mensag,
             txt_msg_aprovante,
             dat_msg_aprovante,
             hr_msg_aprovante )
           VALUES(pr_docum[p_ind].empresa,
                  pr_docum[p_ind].num_docum,
                  p_num_mensag,
                  pr_texto[p_lin_txt].texto,
                  p_dat_atu,
                  p_hor_atu)
          IF STATUS <> 0 THEN
             CALL log003_err_sql('INSERINDO','cap_msg_susp_aprov')
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE

END FUNCTION                     

#---------------------------#   
FUNCTION pol1158_del_texto()#
#---------------------------#   

   CALL log085_transacao("BEGIN")

   DELETE FROM cap_msg_susp_aprov
    WHERE empresa = p_empresa
      AND apropr_desp = p_num_docum
      AND num_mensag = p_num_mensag

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETANDO','cap_msg_susp_aprov')
      CALL log085_transacao("ROLLBACK")
      RETURN
   END IF
   
   LET p_count = p_ind_ad   

   IF NOT pol1158_le_txt_ad() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN
   END IF

   CALL log085_transacao("COMMIT")

   IF p_count <= p_qtd_msg THEN
      LET p_ind_ad = p_count
   ELSE
      LET p_ind_ad = p_qtd_msg
   END IF
   
   CALL pol1158_pega_txt_ad()
   
   RETURN TRUE

END FUNCTION            

#---------------------------#
FUNCTION pol1158_mod_texto()#
#---------------------------#

   DEFINE p_txt_ant CHAR(250)
   
   LET INT_FLAG = FALSE
   
   LET p_txt_ant = p_txt_aprovante
   
   INPUT p_txt_aprovante
      WITHOUT DEFAULTS
         FROM txt_aprovante   

      AFTER FIELD txt_aprovante
         
         IF p_txt_aprovante IS NULL THEN 
            LET p_msg = 'Por favor, digite o texto!'
            CALL log0030_mensagem(p_msg,'exclamation')
            NEXT FIELD txt_aprovante
         END IF
         
   END INPUT 

   IF NOT INT_FLAG THEN
      LET p_msg = "Confirma a modificação do texto?"
      IF log0040_confirm(20,15,p_msg) THEN
         IF pol1158_atu_texto() THEN
            RETURN 
         END IF
      END IF
   END IF
   
   LET p_txt_aprovante = p_txt_ant
   DISPLAY p_txt_aprovante TO txt_aprovante

END FUNCTION      

#---------------------------#
FUNCTION pol1158_atu_texto()#
#---------------------------#
   
   CALL log085_transacao("BEGIN")

   UPDATE cap_msg_susp_aprov
      SET txt_msg_aprovante = p_txt_aprovante
    WHERE empresa = pr_docum[p_ind].empresa
      AND apropr_desp = pr_docum[p_ind].num_docum
      AND num_mensag = p_num_mensag

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','cap_msg_susp_aprov')
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   LET pr_txt_ad[p_ind_ad].txt_aprovante = p_txt_aprovante
   
   RETURN TRUE

END FUNCTION
    
#---------------------------#
FUNCTION pol1158_inc_texto()#
#---------------------------#
   
   DEFINE p_sequencia  INTEGER,
          p_txt_ant    CHAR(250),
          p_mensag_ant INTEGER,
          p_ind_ad_ant INTEGER
   
   LET p_txt_ant = p_txt_aprovante
   LET p_txt_aprovante = NULL
   LET p_mensag_ant = p_num_mensag
   LET p_ind_ad_ant = p_ind_ad
   
   SELECT MAX(num_mensag)
     INTO p_sequencia
     FROM cap_msg_susp_aprov
    WHERE empresa = pr_docum[p_ind].empresa  
      AND apropr_desp = pr_docum[p_ind].num_docum   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','cap_msg_susp_aprov')
      RETURN
   END IF
   
   IF p_sequencia IS NULL THEN
      LET p_sequencia = 0
   END IF
   
   LET p_sequencia = p_sequencia + 1
   DISPLAY p_sequencia TO num_mensag
   DISPLAY p_txt_aprovante TO txt_aprovante
   DISPLAY '' TO txt_emitente
   
   LET INT_FLAG = FALSE
   
   INPUT p_txt_aprovante
      WITHOUT DEFAULTS
         FROM txt_aprovante   

      AFTER FIELD txt_aprovante
         
         IF p_txt_aprovante IS NULL THEN 
            LET p_msg = 'Por favor, digite o texto!'
            CALL log0030_mensagem(p_msg,'exclamation')
            NEXT FIELD txt_aprovante
         END IF
         
   END INPUT 

   IF NOT INT_FLAG THEN
      LET p_msg = "Confirma a inclusão do texto?"
      IF log0040_confirm(20,15,p_msg) THEN
         LET p_num_mensag = p_sequencia
         IF pol1158_ins_texto() THEN
            RETURN 
         END IF
      END IF
   END IF
   
   LET p_txt_aprovante = p_txt_ant
   LET p_ind_ad = p_ind_ad_ant
   
   DISPLAY p_num_mensag TO num_mensag
   DISPLAY p_txt_aprovante TO txt_aprovante
   IF p_ind_ad > 0 THEN
      DISPLAY pr_txt_ad[p_ind_ad].txt_emitente TO txt_emitente
   END IF

END FUNCTION      

#---------------------------#
FUNCTION pol1158_ins_texto()#
#---------------------------#
   
   LET p_hor_atu = TIME

   CALL log085_transacao("BEGIN")
   
   INSERT INTO cap_msg_susp_aprov(
             empresa,
             apropr_desp,
             num_mensag,
             txt_msg_aprovante,
             dat_msg_aprovante,
             hr_msg_aprovante )
      VALUES(pr_docum[p_ind].empresa,
             pr_docum[p_ind].num_docum,
             p_num_mensag,
             p_txt_aprovante,
             p_dat_atu,
             p_hor_atu)
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','cap_msg_susp_aprov')
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   LET p_qtd_msg = p_qtd_msg + 1
   LET p_ind_ad = p_qtd_msg
   LET pr_txt_ad[p_ind_ad].num_mensag = p_num_mensag
   LET pr_txt_ad[p_ind_ad].txt_aprovante = p_txt_aprovante
   LET pr_txt_ad[p_ind_ad].txt_emitente = ''

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1158_dados_ad()#
#--------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11587") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11587 AT 02,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_ad()

   CLOSE WINDOW w_pol11587


END FUNCTION

#--------------------------#
FUNCTION pol1158_exibe_ad()#
#--------------------------# 

   DEFINE pr_ap ARRAY[50] OF RECORD
      num_ap              INTEGER,       
      num_parcela         INTEGER,
      val_nom_ap          DECIMAL(10,2),
      dat_vencto_s_desc	  DATE,
      cod_portador        CHAR(03),
      nom_portador        CHAR(30)
   END RECORD

   DEFINE p_num_ad            INTEGER,
          p_num_nf            INTEGER,
          p_dat_emis_nf       DATE,
          p_ser_nf            CHAR(03),
          p_ssr_nf            DECIMAL(2,0),
          p_val_tot_nf        DECIMAL(10,2),
          p_dat_venc          DATE,
          p_cod_fornecedor    CHAR(15),
          p_raz_social        CHAR(50),
          p_cod_tip_despesa   CHAR(04),
          p_nom_tip_despesa   CHAR(30),
          p_num_ap            INTEGER,
          p_num_parcela       INTEGER,
          p_observ            CHAR(40)
   
   SELECT a.num_ad,
          a.val_tot_nf,
          a.dat_venc,   
          a.observ,
          a.cod_fornecedor,
          b.raz_social,
          a.cod_tip_despesa,
          c.nom_tip_despesa,
          a.num_nf,     
          a.dat_emis_nf,
          a.ser_nf,     
          a.ssr_nf     
     INTO p_num_ad,         
          p_val_tot_nf,     
          p_dat_venc,  
          p_observ,     
          p_cod_fornecedor, 
          p_raz_social,     
          p_cod_tip_despesa,
          p_nom_tip_despesa,
          p_num_nf,     
          p_dat_emis_nf,
          p_ser_nf,     
          p_ssr_nf     
     FROM ad_mestre a,
          fornecedor b,
          tipo_despesa c
    WHERE a.cod_empresa   = p_empresa
      AND a.num_ad        = p_num_docum
      AND a.cod_fornecedor = b.cod_fornecedor
      AND c.cod_empresa = a.cod_empresa
      AND c.cod_tip_despesa = a.cod_tip_despesa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ad_mestre/fornecedor')
      RETURN
   END IF
   
   LET p_ies_suspensa = pr_compl[p_ind].ies_suspensa
   IF p_ies_suspensa IS NULL THEN
      LET p_ies_suspensa = 'N'
   END IF
   
   DISPLAY p_empresa TO cod_empresa   
   DISPLAY p_num_ad TO num_ad
   IF p_ies_suspensa = 'S' THEN
      DISPLAY 'Suspensa' TO sit_ad
   ELSE
      DISPLAY 'Normal' TO sit_ad
   END IF

   DISPLAY p_val_tot_nf TO val_tot_nf
   DISPLAY p_num_nf TO num_nf
   DISPLAY p_dat_emis_nf TO dat_emis_nf
   DISPLAY p_ser_nf TO ser_nf
   DISPLAY p_ssr_nf TO ssr_nf
   DISPLAY p_observ TO observ
   DISPLAY p_cod_fornecedor TO cod_fornecedor  
   DISPLAY p_raz_social TO raz_social  
   DISPLAY p_cod_tip_despesa TO cod_tip_despesa  
   DISPLAY p_nom_tip_despesa TO nom_tip_despesa  

   LET p_index = 1
   
   DECLARE cq_le_aps CURSOR FOR
    SELECT num_ap
      FROM ad_ap
     WHERE cod_empresa = p_empresa
       AND num_ad      = p_num_docum
   
   FOREACH cq_le_aps INTO p_num_ap     
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ad_ap')
         EXIT FOREACH
      END IF
   
      SELECT num_ap,
             num_parcela,      
             val_nom_ap,       
             dat_vencto_s_desc,
             cod_portador   
        INTO pr_ap[p_index].num_ap,           
             pr_ap[p_index].num_parcela,      
             pr_ap[p_index].val_nom_ap,       
             pr_ap[p_index].dat_vencto_s_desc,
             pr_ap[p_index].cod_portador     
        FROM ap
       WHERE cod_empresa = p_empresa
         AND num_ap      = p_num_ap
         AND ies_versao_atual = 'S'
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ap')
         EXIT FOREACH
      END IF
      
      DECLARE cq_port CURSOR FOR
       SELECT nom_portador
         FROM portador
        WHERE cod_portador = pr_ap[p_index].cod_portador
      
      FOREACH cq_port INTO pr_ap[p_index].nom_portador

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_port')
         END IF
         
         EXIT FOREACH
      
      END FOREACH
            
      LET p_index = p_index + 1
      
      IF p_index > 50 THEN
         CALL log0030_mensagem('Limite de linhas esgotado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_index = 1 THEN
      CALL log0030_mensagem('Erro lendo dados da AP','excla')
      RETURN
   END IF
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_ap WITHOUT DEFAULTS FROM sr_ap.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      BEFORE FIELD num_parcela
         LET p_num_parcela = pr_ap[p_index].num_parcela 
         
      AFTER FIELD num_parcela
         
         LET pr_ap[p_index].num_parcela = p_num_parcela
         DISPLAY p_num_parcela to sr_ap[s_index].num_parcela
         
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            LET p_count = p_index + 1
            IF p_count > 50 OR pr_ap[p_count].num_parcela IS NULL OR
               pr_ap[p_count].num_parcela <= 0 THEN
               NEXT FIELD num_parcela
            END IF
         END IF
      
      ON KEY (control-s)
         IF pol1158_susp_ativ_ad() THEN
            DISPLAY p_sit_ad to sit_ad
            CALL log0030_mensagem('Operação efetuada c/ sucesso!','Info')
         END IF
                           
   END INPUT
         
END FUNCTION

#------------------------------#
FUNCTION pol1158_susp_ativ_ad()#
#------------------------------#

   CALL log085_transacao("BEGIN")
   
   IF p_ies_suspensa = 'N' THEN
      CALL pol1158_supende_ad() RETURNING p_status
      LET p_sit_ad = 'Suspensa'
   ELSE   
      CALL pol1158_ativa_ad() RETURNING p_status
      LET p_sit_ad = 'Normal'
   END IF
   
   IF p_status THEN
      CALL log085_transacao("COMMIT")
      RETURN TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
END FUNCTION

#----------------------------#
FUNCTION pol1158_supende_ad()#
#----------------------------#

   LET p_hor_atu = TIME
   
   LET p_txt_aprovante = 'APROV.ELETR. AD SUSPENSA PELO USUARIO ', p_cod_user,
                         ' DATA ', p_dat_atu, 'HORA ', p_hor_atu

   IF NOT pol1158_ins_cap_msg() THEN 
      RETURN FALSE
   END IF
   
   LET p_niv_autorid = pr_compl[p_ind].cod_nivel_autorid
   
   SELECT cod_uni_funcio
     INTO p_cod_uni_funcio
     FROM ad_aprov_temp_265
    WHERE empresa = p_empresa
      AND num_ad = p_num_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','ad_aprov_temp_265:suspende')
      RETURN FALSE
   END IF

   INSERT INTO cap_ad_susp_aprov(
      empresa,           
      apropr_desp,       
      niv_autd_aprovante,
      unid_funcional,    
      usuario,           
      dat_suspens,       
      hor_suspens,       
      observacao_suspens)
   VALUES(p_empresa,
          p_num_docum,
          p_niv_autorid,
          p_cod_uni_funcio,
          p_cod_user,
          p_dat_atu,
          p_hor_atu,
          ' ')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','cap_ad_susp_aprov:suspende')
      RETURN FALSE
   END IF
   
   LET pr_compl[p_ind].ies_suspensa = 'S'
   
   RETURN TRUE

END FUNCTION
   
   
#-----------------------------#
FUNCTION pol1158_ins_cap_msg()#
#-----------------------------# 

   SELECT MAX(num_mensag)
     INTO p_num_mensag
     FROM cap_msg_susp_aprov
    WHERE empresa = p_empresa  
      AND apropr_desp = p_num_docum   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','cap_msg_susp_aprov:suspende')
      RETURN FALSE
   END IF
   
   IF p_num_mensag IS NULL THEN
      LET p_num_mensag = 0
   END IF

   LET p_num_mensag = p_num_mensag + 1
   
   INSERT INTO cap_msg_susp_aprov(
             empresa,
             apropr_desp,
             num_mensag,
             txt_msg_aprovante,
             dat_msg_aprovante,
             hr_msg_aprovante )
      VALUES(p_empresa,
             p_num_docum,
             p_num_mensag,
             p_txt_aprovante,
             p_dat_atu,
             p_hor_atu)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','cap_msg_susp_aprov:suspende')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1158_ativa_ad()#
#--------------------------#

   LET p_hor_atu = TIME
   
   LET p_txt_aprovante = 'APROV.ELETR. AD REATIVADA PELO USUARIO ', p_cod_user,
                         ' DATA ', p_dat_atu, 'HORA ', p_hor_atu

   IF NOT pol1158_ins_cap_msg() THEN 
      RETURN FALSE
   END IF

   DELETE FROM cap_ad_susp_aprov
    WHERE empresa = p_empresa
      AND apropr_desp = p_num_docum
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','cap_ad_susp_aprov:reativa')
      RETURN FALSE
   END IF
   
   LET pr_compl[p_ind].ies_suspensa = 'N'

   RETURN TRUE

END FUNCTION
   
         
#-----------------------------#
FUNCTION pol1158_le_nome_for()#
#-----------------------------#

   SELECT raz_social
     INTO pr_docum[p_ind].nom_fornecedor
     FROM fornecedor
    WHERE cod_fornecedor = pr_compl[p_ind].cod_fornecedor

   IF STATUS <> 0 THEN
      LET pr_docum[p_ind].nom_fornecedor = 'INEXISTENTE'
   END IF

END FUNCTION   

#-----------------------------#
FUNCTION pol1158_le_ar(p_docum)#
#-----------------------------#

   DEFINE p_docum CHAR(10)
   
   DECLARE cq_le_nf CURSOR FOR
    SELECT UNIQUE
           b.cod_empresa,
           b.num_aviso_rec,
           b.dat_emis_nf,
           b.cod_fornecedor,
           b.val_tot_nf_d,
           a.cod_nivel_autorid
      FROM aprov_ar_265 a, nf_sup b, nfe_aprov_265 c, nivel_temp_265 d  
     WHERE a.cod_nivel_autorid = d.nivel_autorid
       AND a.cod_empresa = d.empresa
       AND d.tip_docum = 'AR'     
       AND (a.nom_usuario_aprov IS NULL   OR a.nom_usuario_aprov = " ")
       AND b.cod_empresa   = a.cod_empresa
       AND b.ies_incl_cap  = 'X'
       AND b.num_aviso_rec = a.num_aviso_rec
       AND c.cod_empresa   = b.cod_empresa
       AND c.num_aviso_rec = b.num_aviso_rec
       AND c.ies_ar_cs     = p_docum
     ORDER BY b.cod_empresa, b.num_aviso_rec

   FOREACH cq_le_nf INTO      
           pr_docum[p_ind].empresa, 
           pr_docum[p_ind].num_docum, 
           pr_docum[p_ind].dat_docum,     
           pr_compl[p_ind].cod_fornecedor,
           pr_docum[p_ind].val_docum,
           pr_compl[p_ind].cod_nivel_autorid
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'cursor cq_le_nf')
         RETURN FALSE
      END IF
      
      CALL pol1158_le_estado()
      
      SELECT hierarquia
        INTO p_hieraq_user
        FROM nivel_hierarq_265
       WHERE empresa = pr_docum[p_ind].empresa
         AND nivel_autoridade = pr_compl[p_ind].cod_nivel_autorid

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'nivel_hierarq_265:cq_le_nf')
         RETURN FALSE
      END IF
      
      SELECT MAX(a.hierarquia)
        INTO p_hierarquia
        FROM nivel_hierarq_265 a, aprov_ar_265 b
       WHERE a.empresa = pr_docum[p_ind].empresa
         AND b.cod_empresa = a.empresa
         AND b.num_aviso_rec = pr_docum[p_ind].num_docum
         AND b.cod_nivel_autorid = a.nivel_autoridade 
         AND (b.nom_usuario_aprov IS NULL OR b.nom_usuario_aprov = " ")

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'hierarquia:cq_le_nf')
         RETURN FALSE
      END IF
      
      IF p_hierarquia IS NULL THEN
         LET p_hierarquia = 0
      END IF
      
      IF p_hierarquia <> p_hieraq_user THEN
         CONTINUE FOREACH
      END IF

      LET pr_docum[p_ind].num_versao = ''
      LET pr_docum[p_ind].ies_aprovar = 'N'
      LET pr_docum[p_ind].tip_docum = p_docum
      
      CALL pol1158_le_nome_for()
      
      LET p_val_total = p_val_total + pr_docum[p_ind].val_docum
      
      LET p_ind = p_ind + 1

      IF p_ind > 20000 THEN
         LET p_msg = 'Limite de documentos ultrapassado!\n',
                     'durante a carga de Notas.'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
       
   END FOREACH

   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1158_le_pc()#
#-----------------------#

   DECLARE cq_le_pc CURSOR FOR
    SELECT UNIQUE
           b.cod_empresa,
           b.num_pedido,
           b.num_versao,
           b.dat_emis,
           b.cod_fornecedor,
           b.val_tot_ped,
           a.cod_nivel_autorid,
           b.ies_situa_ped
      FROM aprov_ped_sup a, pedido_sup b, nivel_temp_265 c
     WHERE a.cod_empresa = c.empresa                  
       AND a.cod_nivel_autorid = c.nivel_autorid      
       AND (a.nom_usuario_aprov IS NULL   OR a.nom_usuario_aprov = " ")  
       AND b.cod_empresa      = a.cod_empresa
       AND b.ies_versao_atual = "S"
       AND b.ies_situa_ped    = "A"
       AND b.num_pedido       = a.num_pedido
       AND b.num_versao       = a.num_versao_pedido
       AND c.tip_docum  = 'PC'  
     ORDER BY b.cod_empresa, b.num_pedido
   
   FOREACH cq_le_pc INTO      
           pr_docum[p_ind].empresa, 
           pr_docum[p_ind].num_docum, 
           pr_docum[p_ind].num_versao, 
           pr_docum[p_ind].dat_docum,     
           pr_compl[p_ind].cod_fornecedor,
           pr_docum[p_ind].val_docum,
           pr_compl[p_ind].cod_nivel_autorid,
           pr_compl[p_ind].ies_situa_ped
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'cursor cq_le_pc')
         RETURN FALSE
      END IF
      
      CALL pol1158_le_estado()
      
      SELECT hierarquia
        INTO p_hieraq_user
        FROM sup_niv_autorid_complementar
       WHERE empresa = pr_docum[p_ind].empresa
         AND nivel_autoridade = pr_compl[p_ind].cod_nivel_autorid

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'sup_niv_autorid_complementar:cq_le_pc')
         RETURN FALSE
      END IF
      
      SELECT max(a.hierarquia)
        INTO p_hierarquia
        FROM sup_niv_autorid_complementar a,
             aprov_ped_sup b
       WHERE a.empresa = pr_docum[p_ind].empresa
         AND b.cod_empresa = a.empresa
         AND b.cod_nivel_autorid = a.nivel_autoridade 
         AND b.num_pedido = pr_docum[p_ind].num_docum
         AND b.num_versao_pedido = pr_docum[p_ind].num_versao
         AND (b.nom_usuario_aprov IS NULL OR b.nom_usuario_aprov = " ")

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'hierarquia')
         RETURN FALSE
      END IF
      
      IF p_hierarquia IS NULL THEN
         LET p_hierarquia = 0
      END IF
      
      IF p_hierarquia <> p_hieraq_user THEN
         CONTINUE FOREACH
      END IF
      
      LET pr_docum[p_ind].ies_aprovar = 'N'
      LET pr_docum[p_ind].tip_docum   = 'COMPRAS'
      
      CALL pol1158_le_nome_for()
      
      LET p_val_total = p_val_total + pr_docum[p_ind].val_docum
      
      LET p_ind = p_ind + 1

      IF p_ind > 20000 THEN
         LET p_msg = 'Limite de documentos ultrapassado!\n',
                     'durante a carga de Pedidos de Compra.'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
       
   END FOREACH

   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1158_le_ad()#
#-----------------------#
   
   DELETE FROM ad_aprov_temp_265
   
   SELECT COUNT (*) 
     INTO p_count
     FROM usu_nivel_aut_cap 
    WHERE cod_usuario = p_user

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','usu_nivel_aut_cap:count')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      LET p_le_ad = FALSE
      RETURN TRUE
   END IF
   
   LET p_le_ad = TRUE

   DECLARE cq_emp_pend CURSOR FOR
    SELECT UNIQUE cod_empresa 
      FROM aprov_necessaria 
     WHERE cod_empresa IN (SELECT UNIQUE cod_empresa FROM par_cap_pad)
       AND ies_aprovado = 'N' 
     ORDER BY cod_empresa

   FOREACH cq_emp_pend INTO p_emp_pend   
 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','aprov_necessaria:cq_emp_pend')
         RETURN FALSE
      END IF

      DELETE FROM usu_niv_temp_265
 
      DECLARE cq_usu_nivel CURSOR FOR
       SELECT cod_uni_funcio, 
              ies_tip_autor, 
              cod_nivel_autor, 
              cod_emp_usuario 
         FROM usu_nivel_aut_cap 
        WHERE cod_empresa = p_emp_pend 
          AND cod_emp_usuario IS NOT NULL 
          AND cod_usuario = p_user
          AND cod_uni_funcio IS NOT NULL 
          AND ies_versao_atual = 'S' 
          AND num_versao IS NOT NULL 
          AND ies_tip_autor IS NOT NULL 
          AND ies_ativo = 'S'
      
      FOREACH cq_usu_nivel INTO
         p_cod_uni_funcio, 
         p_ies_tip_autor,  
         p_cod_nivel_autor,
         p_cod_emp_usuario

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','usu_nivel_aut_cap:cq_usu_nivel')
            RETURN FALSE
         END IF
         
         IF NOT pol1158_ins_usu_niv('P') THEN
            RETURN FALSE
         END IF
         
      END FOREACH
      
      DECLARE cq_subs_nivel CURSOR FOR
       SELECT cod_usuario, 
              cod_uni_funcio 
         FROM usuario_subs_cap 
        WHERE cod_empresa = p_emp_pend
          AND cod_usuario IS NOT NULL 
          AND cod_uni_funcio IS NOT NULL 
          AND cod_usuario_subs = p_user 
          AND dat_ini_validade IS NOT NULL 
          AND ies_versao_atual = 'S' 
          AND num_versao IS NOT NULL 
          AND cod_emp_usuario IS NOT NULL 
          AND p_dat_atu BETWEEN dat_ini_validade AND dat_fim_validade
      
      FOREACH cq_subs_nivel INTO p_cod_usuario, p_cod_uni_funcio

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','usuario_subs_cap:cq_subs_nivel')
            RETURN FALSE
         END IF

         DECLARE cq_acha_princ CURSOR FOR
          SELECT ies_tip_autor, 
                 cod_nivel_autor, 
                 cod_emp_usuario 
            FROM usu_nivel_aut_cap 
           WHERE cod_empresa = p_emp_pend 
             AND cod_emp_usuario IS NOT NULL 
             AND cod_usuario = p_cod_usuario
             AND cod_uni_funcio = p_cod_uni_funcio
             AND ies_versao_atual = 'S' 
             AND num_versao IS NOT NULL 
             AND ies_tip_autor IS NOT NULL

         FOREACH cq_acha_princ INTO
            p_ies_tip_autor,  
            p_cod_nivel_autor,
            p_cod_emp_usuario
         
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','usu_nivel_aut_cap:cq_acha_princ')
               RETURN FALSE
            END IF
       
            IF NOT pol1158_ins_usu_niv('S') THEN
               RETURN FALSE
            END IF

         END FOREACH #cq_acha_princ
         
      END FOREACH #cq_subs_nivel


      SELECT par_ies 
        INTO p_ies_forma_aprov
        FROM par_cap_pad 
       WHERE cod_empresa   = p_emp_pend 
         AND cod_parametro ='ies_forma_aprov'

      IF STATUS = 100 THEN
         LET p_ies_forma_aprov = NULL
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','par_cap_pad')
            RETURN FALSE
         END IF
      END IF

      DECLARE cq_aprov_necess CURSOR FOR
       SELECT aprov_necessaria.num_ad,
              aprov_necessaria.num_versao,
              aprov_necessaria.cod_nivel_autor,
              aprov_necessaria.cod_uni_funcio
         FROM aprov_necessaria, ad_mestre 
        WHERE aprov_necessaria.cod_empresa = p_emp_pend
          AND aprov_necessaria.num_ad IS NOT NULL 
          AND aprov_necessaria.cod_nivel_autor IS NOT NULL 
          AND aprov_necessaria.ies_aprovado = 'N'
          AND ad_mestre.cod_empresa = aprov_necessaria.cod_empresa 
          AND ad_mestre.num_ad = aprov_necessaria.num_ad 
          AND EXISTS 
              (SELECT DISTINCT tmp.cod_emp_usuario
                 FROM usu_niv_temp_265 tmp
                WHERE tmp.cod_emp_usuario = aprov_necessaria.cod_empresa #empresa da AD
                  AND tmp.cod_nivel_autor = aprov_necessaria.cod_nivel_autor
                  AND tmp.ies_tip_autor = 'G')
        ORDER BY aprov_necessaria.num_ad
        
      FOREACH cq_aprov_necess INTO 
         p_num_ad, 
         p_num_versao, 
         p_cod_nivel_autor, 
         p_cod_uni_funcio

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_aprov_necess')
            RETURN FALSE
         END IF

         IF NOT pol1158_le_tip_desp() THEN
            RETURN FALSE
         END IF

         IF p_ies_previsao = 'P' THEN
            CONTINUE FOREACH
         END IF

         IF NOT pol1158_ins_ad_aprov() THEN
            RETURN FALSE
         END IF
         
      END FOREACH #cq_aprov_necess

      DECLARE cq_aprov_hierarq CURSOR FOR
       SELECT aprov.cod_empresa,
              aprov.num_ad,
              aprov.num_versao,
              aprov.cod_nivel_autor,
              aprov.cod_uni_funcio
         FROM aprov_necessaria aprov, ad_mestre adm      #ivo 17/03/2014
        WHERE aprov.cod_empresa = p_emp_pend
          AND aprov.ies_aprovado = 'N' 
          AND aprov.num_ad IS NOT NULL 
          AND aprov.cod_nivel_autor IS NOT NULL 
          AND adm.cod_empresa = aprov.cod_empresa        #ivo 17/03/2014
          AND adm.num_ad = aprov.num_ad                  #ivo 17/03/2014
          AND EXISTS 
              (SELECT DISTINCT tmp.cod_emp_usuario
                 FROM usu_niv_temp_265 tmp
                WHERE tmp.cod_emp_usuario = aprov.cod_empresa
                  AND tmp.cod_uni_funcional = aprov.cod_uni_funcio
                  AND tmp.cod_nivel_autor = aprov.cod_nivel_autor
                  AND tmp.ies_tip_autor = 'H')
        ORDER BY aprov.cod_empresa, aprov.num_ad, aprov.cod_nivel_autor
          
      FOREACH cq_aprov_hierarq INTO
         p_empresa,
         p_num_ad, 
         p_num_versao, 
         p_cod_nivel_autor, 
         p_cod_uni_funcio

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_aprov_hierarq')
            RETURN FALSE
         END IF

         SELECT COUNT(num_ad)
           INTO p_count
           FROM ad_aprov_temp_265
          WHERE empresa = p_emp_pend
            AND num_ad = p_num_ad

         IF STATUS <> 0 THEN                                           
            CALL log003_err_sql('Lendo','AD_APROV_TEMP_265:count')   
            RETURN FALSE    
         END IF                                                        

         IF p_count > 0 THEN
            CONTINUE FOREACH
         END IF           
         
         IF NOT pol1158_le_tip_desp() THEN
            RETURN FALSE
         END IF
            
         IF p_ies_previsao = 'P' THEN
            CONTINUE FOREACH
         END IF
         
         LET p_ies_aceita = "S"
         
         IF p_ies_forma_aprov = '3' THEN
            DECLARE c_w_cap3560 CURSOR FOR
             SELECT cod_nivel_autor 
               FROM aprov_necessaria 
              WHERE cod_empresa = p_emp_pend 
                AND num_ad = p_num_ad 
                AND cod_uni_funcio = p_cod_uni_funcio
                AND ies_aprovado = 'N' 
               AND cod_nivel_autor < p_cod_nivel_autor
             ORDER BY cod_nivel_autor DESC
          
            FOREACH c_w_cap3560 INTO p_cod_autorid
            
               IF STATUS <> 0 THEN
                  CALL log003_err_sql('FOREACH','c_w_cap3560')
                  RETURN FALSE
               END IF

               SELECT cod_nivel_autor 
                 FROM usu_niv_temp_265 
                WHERE cod_emp_usuario = p_emp_pend
                  AND cod_uni_funcional = p_cod_uni_funcio
                  AND cod_nivel_autor = p_cod_autorid
                  AND substituto = "S" 

               IF STATUS = 100 THEN
                  LET p_ies_aceita = "N"
                  EXIT FOREACH
               ELSE
                  IF STATUS <> 0 THEN
                     CALL log003_err_sql('Lendo','usu_niv_temp_265:c_w_cap3560')
                     RETURN FALSE
                  END IF
               END IF
         
            END FOREACH  #c_w_cap3560 
         END IF
         
         IF p_ies_aceita = 'S' THEN
            IF NOT pol1158_ins_ad_aprov() THEN
               RETURN FALSE
            END IF
         END IF
      
      END FOREACH #cq_aprov_hierarq
      
      
   END FOREACH #cq_emp_pend

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1158_ins_usu_niv(p_subst)#
#------------------------------------#
   
   DEFINE p_subst CHAR(01)
   
   IF p_subst = 'P' THEN
      LET p_situacao = 'Principal'
   ELSE
      LET p_situacao = 'Substituto'
   END IF
   
   INSERT INTO usu_niv_temp_265(
      cod_emp_usuario,  
      cod_uni_funcional,
      cod_nivel_autor,  
      situacao,         
      ies_tip_autor, 
      substituto,   
      empresa)
    VALUES(p_emp_pend,                                                       
           p_cod_uni_funcio,                                                 
           p_cod_nivel_autor,                                                
           p_situacao,                                                      
           p_ies_tip_autor, 
           p_subst,                                           
           p_cod_emp_usuario)                                                
                                                                       
   IF STATUS <> 0 THEN                                                       
      CALL log003_err_sql('Inserindo','usu_niv_temp_265')       
      RETURN FALSE                                                           
   END IF                                                                    

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1158_le_tip_desp()#
#-----------------------------#

   SELECT val_tot_nf,                                       
          dat_emis_nf,                                   
          dat_venc,                                      
          cod_tip_despesa                                
     INTO p_val_tot_nf,                                  
          p_dat_emis_nf,                                 
          p_dat_venc,                                    
          p_cod_tip_despesa                              
     FROM ad_mestre                                      
    WHERE cod_empresa = p_emp_pend                       
      AND num_ad = p_num_ad                              
                                                         
   IF STATUS <> 0 THEN                                   
      CALL log003_err_sql('Lendo','ad_mestre:ltd')           
      RETURN FALSE                                       
   END IF                                                
                                                         
   SELECT ies_previsao,                                  
          nom_tip_despesa,                               
          cod_grp_despesa                                
     INTO p_ies_previsao,                                
          p_nom_tip_despesa,                             
          p_cod_grp_despesa                              
     FROM tipo_despesa                                   
    WHERE cod_empresa = p_emp_pend                       
      AND cod_tip_despesa = p_cod_tip_despesa            
                                                   
   IF STATUS <> 0 THEN                                   
      CALL log003_err_sql('Lendo','tipo_despesa')        
      RETURN FALSE                                       
   END IF                                                

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1158_ins_ad_aprov()#
#------------------------------#
   
   SELECT den_nivel_autor                                           
     FROM nivel_autor_cap                                        
    WHERE cod_empresa = p_emp_pend                               
      AND cod_nivel_autor = p_cod_nivel_autor                    
                                                              
   IF STATUS <> 0 THEN                                           
      CALL log003_err_sql('Lendo','nivel_autor_cap')             
      RETURN FALSE                                               
   END IF                                                        
                                                                 
   SELECT nom_grp_despesa                                        
     INTO p_nom_grp_despesa                                      
     FROM grupo_despesa                                          
    WHERE cod_empresa = p_emp_pend                               
      AND cod_grp_despesa = p_cod_grp_despesa                    
                                                                 
   IF STATUS = 100 THEN                                          
      LET p_nom_grp_despesa = ''                                 
   ELSE                                                          
      IF STATUS <> 0 THEN                                        
         CALL log003_err_sql('Lendo','nivel_autor_cap')          
         RETURN FALSE                                            
      END IF                                                     
   END IF                                                        

   SELECT substituto,
          situacao
     INTO p_substituto,
          p_situacao
     FROM usu_niv_temp_265
    WHERE cod_emp_usuario = p_emp_pend
      AND cod_uni_funcional = p_cod_uni_funcio
      AND cod_nivel_autor =  p_cod_nivel_autor 
   
   IF STATUS <> 0 THEN 
      INITIALIZE p_substituto, p_situacao TO NULL
   END IF 
   
   LET p_aprova = 'N'
   LET p_ies_suspensa = 'N'

   SELECT empresa
     FROM cap_ad_susp_aprov
    WHERE empresa = p_emp_pend
      AND apropr_desp = p_num_ad
   
   IF STATUS = 0 THEN
      LET p_ies_suspensa = 'S'
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','cap_ad_susp_aprov')          
         RETURN FALSE                                            
      END IF                                                     
   END IF
         
   SELECT COUNT(num_ad)
     INTO p_count
     FROM ad_aprov_temp_265
    WHERE empresa = p_emp_pend
      AND num_ad = p_num_ad

   IF STATUS <> 0 THEN                                           
      CALL log003_err_sql('Lendo','AD_APROV_TEMP_265:count')   
      LET p_count = 0    
   END IF                                                        
   
   IF p_count > 0 THEN
      LET p_ies_soma = 'N'
   ELSE
      LET p_ies_soma = 'S'
   END IF
                                                            
   INSERT INTO ad_aprov_temp_265                                 
    VALUES(p_aprova,                                                  
           p_emp_pend,                                           
           p_num_ad,                                             
           p_val_tot_nf,                                         
           p_dat_emis_nf,                                        
           p_dat_venc,                                            
           p_situacao,
           p_substituto,
           p_cod_nivel_autor,                                    
           p_cod_tip_despesa,                                    
           p_nom_tip_despesa,                                    
           p_cod_grp_despesa,                                    
           p_nom_grp_despesa,                                    
           p_cod_uni_funcio,
           p_ies_soma,
           p_ies_suspensa)                                     
                                                           
   IF STATUS <> 0 THEN                                           
      CALL log003_err_sql('Inserindo','ad_aprov_temp_265:INS1')       
   END IF                                                        

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1158_le_estado()
#--------------------------#

   SELECT uni_feder
     INTO pr_docum[p_ind].estado
     FROM empresa
    WHERE cod_empresa = pr_docum[p_ind].empresa
   
   IF STATUS <> 0 THEN
      LET pr_docum[p_ind].estado = ''
   END IF

END FUNCTION

#---------------------------#
FUNCTION pol1158_carga_ads()#
#---------------------------#
  
   DECLARE cq_ad CURSOR FOR
    SELECT DISTINCT
           aprova,
           empresa, 
           num_ad, 
           valor_ad, 
           dat_emis,
           ies_suspensa,
           cod_nivel_autor,
           cod_uni_funcio
      FROM ad_aprov_temp_265 
     ORDER BY empresa, num_ad
   
   FOREACH cq_ad INTO
      pr_docum[p_ind].ies_aprovar,
      pr_docum[p_ind].empresa,
      pr_docum[p_ind].num_docum,
      pr_docum[p_ind].val_docum,
      pr_docum[p_ind].dat_docum,
      pr_compl[p_ind].ies_suspensa,
      pr_compl[p_ind].cod_nivel_autorid,
      pr_compl[p_ind].cod_uni_funcio

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_AD')
         RETURN FALSE
      END IF
      
      CALL pol1158_le_estado()
      
      SELECT cod_fornecedor
        INTO pr_compl[p_ind].cod_fornecedor
        FROM ad_mestre
       WHERE cod_empresa = pr_docum[p_ind].empresa
         AND num_ad      = pr_docum[p_ind].num_docum
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','ad_mestre:CQ_AD')
         RETURN FALSE
      END IF

      LET  pr_docum[p_ind].num_versao = ''
      LET pr_docum[p_ind].tip_docum = 'FINANCEIRO'
      
      CALL pol1158_le_nome_for()
      
      LET p_val_total = p_val_total + pr_docum[p_ind].val_docum
      
      LET p_ind = p_ind + 1

      IF p_ind > 20000 THEN
         LET p_msg = 'Limite de documentos ultrapassado!\n',
                     'durante a carga de AD.'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
       
   END FOREACH
         
   RETURN TRUE
         
END FUNCTION
      
#-----------------------------#
FUNCTION pol1158_sel_usuario()
#-----------------------------#

   INITIALIZE pr_usuario TO NULL

   CALL pol1158_le_usuario(p_user)
   LET pr_usuario[1].cod_usuario     = p_user
   LET pr_usuario[1].nom_funcionario = p_nom_func
   
   LET p_index = 2
   
   DECLARE cq_user CURSOR FOR                   
    SELECT cod_usuario                          
      FROM usuario_nivel_subs                   
     WHERE cod_empresa      = p_cod_empresa
       AND cod_usuario_subs = p_user
       AND ies_versao_atual = 'S'
       AND dat_ini_validade <= p_dat_atu 
       AND dat_fim_validade >= p_dat_atu
     UNION
    SELECT cod_usuario                          
      FROM usuario_subs_265                   
     WHERE cod_empresa      = p_cod_empresa
       AND cod_usuario_subs = p_user
       AND ies_versao_atual = 'S'
       AND dat_ini_validade <= p_dat_atu 
       AND dat_fim_validade >= p_dat_atu
     
   FOREACH cq_user INTO pr_usuario[p_index].cod_usuario

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'usuario_nivel_subs:cq_user')
         RETURN FALSE
      END IF
      
      CALL pol1158_le_usuario(pr_usuario[p_index].cod_usuario)
      LET pr_usuario[p_index].nom_funcionario = p_nom_func

      LET p_index = p_index + 1
      
      IF p_index > 10 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF

   END FOREACH   

   IF p_index > 2 THEN
      IF NOT pol1158_escolhe_user() THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_cod_user = p_user
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1158_escolhe_user()#
#------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11581") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11581 AT 7,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_usuario TO sr_usuario.*

   LET p_index = ARR_CURR()
   LET s_index = SCR_LINE() 

   CLOSE WINDOW w_pol11581
   
   IF INT_FLAG THEN
      LET p_msg = NULL
      RETURN FALSE
   END IF

   LET p_cod_user = pr_usuario[p_index].cod_usuario
   
   RETURN TRUE

END FUNCTION
   
#--------------------------------#
FUNCTION pol1158_le_niv_autorid()#
#--------------------------------#
   
   DELETE FROM nivel_temp_265
   
   LET p_count = 0
   
   DECLARE cq_niv_aut CURSOR FOR                  
    SELECT a.cod_empresa,                         
           a.cod_nivel_autorid, 
           a.ies_tip_autoridade, 
           b.den_nivel_autorid,
           'PC' 
      FROM usuario_nivel_aut a,           
           nivel_autoridade b             
     WHERE 1 = 1 #a.cod_empresa = p_cod_empresa
       AND a.nom_usuario = p_cod_user 
       AND a.ies_versao_atual = 'S' 
       AND b.cod_empresa = a.cod_empresa 
       AND b.cod_nivel_autorid = a.cod_nivel_autorid   
     UNION     
    SELECT a.cod_empresa,                         
           a.cod_nivel_autorid, 
           a.ies_tip_autoridade, 
           b.den_nivel_autorid,
           'AR'
      FROM nivel_usuario_265 a,            
           nivel_autorid_265 b             
     WHERE 1 = 1 #a.cod_empresa = p_cod_empresa
       AND a.nom_usuario = p_cod_user 
       AND a.ies_versao_atual = 'S' 
       AND b.cod_empresa = a.cod_empresa 
       AND b.cod_nivel_autorid = a.cod_nivel_autorid   
     
   FOREACH cq_niv_aut INTO
      p_empresa, p_nivel, p_tipo, p_den_nivel, p_tp_docum

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'usuario_nivel_aut:cq_niv_aut')
         RETURN FALSE
      END IF
      
      SELECT COUNT(empresa)
        INTO p_count
        FROM nivel_temp_265
       WHERE empresa = p_empresa
         AND nivel_autorid = p_nivel
         AND tip_docum = p_tp_docum
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'nivel_temp_265:cq_niv_aut')
         RETURN FALSE
      END IF
      
      IF p_count = 0 THEN

         INSERT INTO nivel_temp_265
          VALUES(p_empresa, p_nivel, p_tipo, p_den_nivel, p_tp_docum)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo', 'nivel_temp_265:cq_niv_aut')
            RETURN FALSE
         END IF
        
      END IF
   
   END FOREACH       

   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1158_processar()
#---------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   LET p_index = p_index - 1

   CALL log085_transacao("BEGIN")

   FOR p_ind = 1 TO p_index
       IF pr_docum[p_ind].ies_aprovar = 'S' THEN
          IF NOT pol1158_aprova_docum() THEN   
             CALL log085_transacao("ROLLBACK")   
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   CALL log085_transacao("COMMIT")

   SELECT COUNT(nom_usuario)
     INTO p_count
     FROM email_temp_265

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','email_temp_265:1')
   ELSE
      IF p_count > 0 THEN
         CALL log085_transacao("BEGIN")
         IF NOT pol1158_envia_email() THEN
            CALL log085_transacao("ROLLBACK")
         ELSE
            CALL log085_transacao("COMMIT")
         END IF
      END IF
   END IF

   LET p_msg = 'Os documentos selecionados\n',
               'foram aprovados c/ sucesso.\n',
               'Deseja imprimir o resumo\n',
               'desse processo?'

   IF log0040_confirm(20,25,p_msg) THEN
      LET p_imp_doc = 'A'
      CALL pol1158_lista_docs()
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1158_aprova_docum()#
#------------------------------#

   IF pr_docum[p_ind].tip_docum = 'FINANCEIRO' THEN
      IF NOT pol1158_aprova_ad() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF pr_docum[p_ind].tip_docum = 'NOTA' THEN
      IF NOT pol1158_aprova_ar() THEN
         RETURN FALSE
      END IF
   END IF

   IF pr_docum[p_ind].tip_docum = 'CONTRATO' THEN
      IF NOT pol1158_aprova_ar() THEN
         RETURN FALSE
      END IF
   END IF

   IF pr_docum[p_ind].tip_docum = 'COMPRAS' THEN
      IF NOT pol1158_aprova_pedido() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1158_aprova_ar()#
#---------------------------#
   
   DEFINE p_hierarc_aprov INTEGER,
          p_user_email    CHAR(08),
          m_tip_docum     CHAR(02)
   
   LET p_cod_aprovador = pr_compl[p_ind].cod_nivel_autorid
   
   UPDATE aprov_ar_265
      SET nom_usuario_aprov = p_cod_user, 
          dat_aprovacao = p_dat_atu, 
          hor_aprovacao = p_hor_atu
     WHERE cod_empresa = pr_docum[p_ind].empresa
       AND cod_nivel_autorid = p_cod_aprovador
       AND num_aviso_rec = pr_docum[p_ind].num_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','aprov_ar_265')
      RETURN FALSE
   END IF

   IF NOT pol1158_ins_audit() THEN
      RETURN FALSE
   END IF

   LET p_campo_txt = pr_docum[p_ind].num_docum
   LET p_msg = 'ARPOVACAO DO AR ', p_campo_txt CLIPPED
   CALL pol1158_ins_resumo() RETURNING p_status

   SELECT hierarquia
     INTO p_hierarc_aprov
     FROM aprov_ar_265
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND cod_nivel_autorid = p_cod_aprovador
      AND num_aviso_rec = pr_docum[p_ind].num_docum
      AND nom_usuario_aprov = p_cod_user
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','aprov_ar_265')
      RETURN FALSE
   END IF
   
   LET p_user_para = NULL
   
   DECLARE cq_ar_265 CURSOR FOR
    SELECT b.nom_usuario
      FROM aprov_ar_265 a,
           nivel_usuario_265 b
     WHERE a.cod_empresa = pr_docum[p_ind].empresa
       AND a.num_aviso_rec = pr_docum[p_ind].num_docum
       AND (a.nom_usuario_aprov IS NULL OR a.nom_usuario_aprov = ' ')
       AND a.hierarquia < p_hierarc_aprov
       AND b.cod_empresa = a.cod_empresa
       AND b.cod_nivel_autorid = a.cod_nivel_autorid
       AND b.ies_versao_atual = 'S'
     ORDER BY a.hierarquia DESC
  
   FOREACH cq_ar_265 INTO p_user_email      
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','aprov_ar_265:count')
         RETURN FALSE
      END IF
      
      LET p_user_para = p_user_email
      EXIT FOREACH
   END FOREACH
   
   #IVO 13/05/13 - ALTERADO PARA ENVIAR EMAIL
   #PARA O FINANCEIRO, NA LIBERAÇÃO DO AR
   
   LET m_tip_docum = 'NF'
   
   IF p_user_para IS NULL THEN
      IF NOT pol1158_atu_nf_sup() THEN
         RETURN FALSE
      END IF
      LET m_tip_docum = 'UF' #identifica que será enviado email ao usuário financeiro
   END IF
   
   IF p_user_para IS NULL OR p_user_para = ' ' THEN
   ELSE
      IF NOT pol1158_ins_email(
             p_user_para,
             pr_docum[p_ind].num_docum, 
             pr_docum[p_ind].num_versao, 
             m_tip_docum,
             pr_docum[p_ind].empresa,
             p_cod_user) THEN
         RETURN FALSE
      END IF
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1158_ins_audit()#
#---------------------------#

   DEFINE p_max_seq  INTEGER,
          p_dt_proces DATETIME YEAR TO SECOND

   LET p_dt_proces = CURRENT
   
   SELECT MAX(num_seq)
     INTO p_max_seq
     FROM audit_ar
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_aviso_rec = pr_docum[p_ind].num_docum
      AND num_prog = 'POL1158'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','audit_ar')
      RETURN FALSE
   END IF
   
   IF p_max_seq IS NULL THEN
      LET p_max_seq = 0
   ELSE
      LET p_max_seq = p_max_seq + 1
   END IF     
          
   INSERT INTO audit_ar(
      cod_empresa,
      num_aviso_rec,
      num_seq,
      nom_usuario,
      dat_hor_proces,
      num_prog,
      ies_tipo_auditoria)
   VALUES(pr_docum[p_ind].empresa,
          pr_docum[p_ind].num_docum,
          p_max_seq,
          p_cod_user,
          p_dt_proces,
          'POL1158',
          '3')
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_ar')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION             

#----------------------------#
FUNCTION pol1158_atu_nf_sup()#
#----------------------------#

   DEFINE p_cod_unidade LIKE uni_funcional.cod_uni_funcio   
   
   SELECT ies_incl_cap
     INTO p_ies_incl_cap
     FROM nfe_aprov_265
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_aviso_rec = pr_docum[p_ind].num_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','nfe_aprov_265')
      RETURN FALSE
   END IF
      
   UPDATE nf_sup
      SET ies_incl_cap = 'N'
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_aviso_rec = pr_docum[p_ind].num_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','nf_sup')
      RETURN FALSE
   END IF

   IF NOT pol1158_atu_integ(pr_docum[p_ind].empresa, pr_docum[p_ind].num_docum) THEN
      RETURN FALSE
   END IF 
   
   LET p_msg = 'LIBERACAO DO AR ', p_campo_txt CLIPPED,
               ' P/ INTEGRACAO COM O CAP '
   CALL pol1158_ins_resumo() RETURNING p_status

   SELECT user_financ
     INTO p_user_para
     FROM empresa_proces_265
    WHERE cod_empresa = pr_docum[p_ind].empresa
   
   IF STATUS <> 0 THEN
      LET p_user_para = NULL
   END IF
      
   RETURN TRUE
         
END FUNCTION

#----------------------------------------------#
FUNCTION pol1158_atu_integ(l_cod_emp, l_num_ar)#
#----------------------------------------------#
   
   DEFINE l_cod_emp        LIKE nf_sup.cod_empresa,
          l_num_ar         LIKE nf_sup.num_aviso_rec,
          l_num_nf         LIKE nf_sup.num_nf,        
          l_ser_nf         LIKE nf_sup.ser_nf,        
          l_ssr_nf         LIKE nf_sup.ssr_nf,        
          l_cod_fornecedor LIKE nf_sup.cod_fornecedor 
   
   SELECT num_nf, 
          ser_nf, 
          ssr_nf, 
          cod_fornecedor
    INTO  l_num_nf,        
          l_ser_nf,        
          l_ssr_nf,        
          l_cod_fornecedor
    FROM nf_sup
    WHERE cod_empresa = l_cod_emp
      AND num_aviso_rec = l_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','nf_sup - atu_integ')
      RETURN FALSE
   END IF
   
   SELECT num_ad
     FROM integ_cos_logix 
    WHERE cod_empresa = 'ZZ' 
      AND num_nf = l_num_nf
      AND ser_nf = l_ser_nf
      AND ssr_nf = l_ssr_nf
      AND cod_fornecedor = l_cod_fornecedor
   
   IF STATUS = 0 THEN   
      UPDATE integ_cos_logix 
         SET cod_empresa = l_cod_emp
       WHERE cod_empresa = 'ZZ' 
         AND num_nf = l_num_nf
         AND ser_nf = l_ser_nf
         AND ssr_nf = l_ssr_nf
         AND cod_fornecedor = l_cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','integ_cos_logix - atu_integ')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1158_ins_email(p_email)#
#----------------------------------#

   DEFINE p_email    RECORD
          user_para  CHAR(08),
          num_docum  CHAR(10),
          num_versao CHAR(02),
          tip_docum  CHAR(10),
          empresa    CHAR(02),
          user_de    CHAR(08)
   END RECORD          
   
   DEFINE p_email_usuario CHAR(40),
          p_nom_usuario   CHAR(40)
   
   CALL pol1158_le_usuario(p_email.user_para) 
   LET p_email_usuario = p_den_email
   LET p_nom_usuario   = p_nom_func
   CALL pol1158_le_usuario(p_email.user_de) 

   INSERT INTO email_temp_265 (
      id_registro,   
	    num_docum,   
	    num_versao,  
	    tip_docum,     
	    cod_empresa,   
	    cod_usuario,   
	    email_usuario, 
	    nom_usuario,   
	    cod_emitente,  
	    email_emitente,
	    nom_emitente)  
   VALUES(0, p_email.num_docum,
          p_email.num_versao,
          p_email.tip_docum,
          p_email.empresa,
          p_email.user_para,
          p_email_usuario,
          p_nom_usuario,
          p_email.user_de,
          p_den_email,
          p_nom_func)
                
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINFO','email_temp_265')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1158_ins_resumo()#
#----------------------------#

   INSERT INTO resumo_aprov_265
    VALUES(pr_docum[p_ind].empresa,
           pr_docum[p_ind].num_docum,
           pr_docum[p_ind].tip_docum,
           p_msg, 
           p_cod_aprovador,
           p_cod_user,
           p_dat_atu,
           p_hor_atu)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','resumo_aprov_265')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION             
   
#-------------------------------#
FUNCTION pol1158_aprova_pedido()#
#-------------------------------#
   
   DEFINE p_qtd_reg INTEGER
   
   LET p_cod_aprovador = pr_compl[p_ind].cod_nivel_autorid
   
   LET p_houve_erro = FALSE
   
   SELECT num_versao,
          cnd_pgto,
          cod_mod_embar,
          cod_moeda,
          cod_fornecedor,
          dat_emis,
          val_tot_ped,
          ies_situa_ped,
          cod_transpor,
          cod_comprador
     INTO p_num_ver_pc,    
          p_cnd_pgto,      
          p_cod_mod_embar, 
          p_cod_moeda,     
          p_cod_fornecedor,
          p_dat_emis,      
          p_val_tot_ped,   
          p_ies_situa_ped, 
          p_cod_transpor,
          p_cod_comprador
     FROM pedido_sup 
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_pedido  = pr_docum[p_ind].num_docum
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','pedido_sup')
      RETURN FALSE
   END IF
   
   DECLARE cq_cot_nao_aprov CURSOR FOR
    SELECT num_cotacao, 
           cod_item, 
           num_oc, 
           num_versao,
           cod_fornecedor 
      FROM ordem_sup 
     WHERE cod_empresa = pr_docum[p_ind].empresa 
       AND num_pedido  = pr_docum[p_ind].num_docum
       AND ies_versao_atual = 'S' 
       AND ies_situa_oc NOT IN ('C','L') 

   FOREACH cq_cot_nao_aprov INTO
           p_num_cotacao,
           p_cod_item,
           p_num_oc,
           p_num_ver_oc,
           p_cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_sup:cq_cot_nao_aprov')
         RETURN FALSE
      END IF

      SELECT COUNT(cod_empresa) 
        INTO p_count
        FROM aprov_ordem_sup 
       WHERE cod_empresa = pr_docum[p_ind].empresa 
         AND num_oc = p_num_oc
         AND num_versao_oc = p_num_ver_oc
         AND (nom_usuario_aprov IS NULL OR nom_usuario_aprov = ' ')

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','aprov_ordem_sup')
         RETURN FALSE
      END IF
      
      IF p_count > 0 THEN
         LET p_houve_erro = TRUE
         LET p_msg = 'FALTA APROVACAO PARA A OC ', p_num_oc
         CALL pol1158_ins_resumo() RETURNING p_status
      END IF
              
      SELECT ies_situacao  
        INTO p_ies_situacao                            
        FROM cotacao_preco                             
       WHERE cod_empresa    = pr_docum[p_ind].empresa                         
         AND cod_fornecedor = p_cod_fornecedor                      
         AND num_cotacao    = p_num_cotacao                        
         AND cod_item       = p_cod_item                        
         AND num_versao =                              
            (SELECT MAX(num_versao)                    
               FROM cotacao_preco                      
              WHERE cotacao_preco.cod_empresa    = pr_docum[p_ind].empresa   
                AND cotacao_preco.cod_fornecedor = p_cod_fornecedor   
                AND cotacao_preco.num_cotacao    = p_num_cotacao
                AND cotacao_preco.cod_item       = p_cod_item)  

      IF STATUS = 0 THEN
         IF p_ies_situacao <> 'A' THEN
            LET p_houve_erro = TRUE
            LET p_campo_txt = p_num_cotacao
            LET p_msg = 'FALTA APROVACAO P/ COTACAO ', p_campo_txt CLIPPED,
                        ' DA OC ', p_num_oc
            CALL pol1158_ins_resumo() RETURNING p_status
         END IF
      END IF
   
   END FOREACH
                   
   IF p_houve_erro THEN
      RETURN TRUE
   END IF                  

   SELECT COUNT (cod_nivel_autorid)
     INTO p_count
     FROM aprov_ped_sup 
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_pedido  = pr_docum[p_ind].num_docum 
      AND num_versao_pedido = pr_docum[p_ind].num_versao 
      AND (nom_usuario_aprov IS NULL OR nom_usuario_aprov = ' ')
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','aprov_ped_sup:count1')
      RETURN FALSE
   END IF
   
   IF p_count = 1 THEN
      LET p_lib_pedido = TRUE
   ELSE
      LET p_lib_pedido = FALSE
   END IF
   
   LET p_qtd_reg = p_count

   SELECT MAX(num_versao_grade)
     INTO p_num_ver_grade 
     FROM aprov_ped_sup 
    WHERE cod_empresa = pr_docum[p_ind].empresa 
      AND num_pedido  = pr_docum[p_ind].num_docum
      AND num_versao_pedido = pr_docum[p_ind].num_versao

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','aprov_ped_sup:MAX(num_versao_grade)')
      RETURN FALSE
   END IF
   
   IF p_num_ver_grade IS NULL THEN
      LET p_num_ver_grade = 0
   END IF

  UPDATE aprov_ped_sup 
     SET nom_usuario_aprov = p_cod_user, 
         dat_aprovacao = p_dat_atu, 
         hor_aprovacao = p_hor_atu, 
         num_versao_grade = p_num_ver_grade 
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND cod_nivel_autorid = p_cod_aprovador
      AND num_pedido = pr_docum[p_ind].num_docum
      AND num_versao_pedido = pr_docum[p_ind].num_versao
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','aprov_ped_sup')
      RETURN FALSE
   END IF

   SELECT COUNT (cod_nivel_autorid)
     INTO p_count
     FROM aprov_ped_sup 
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_pedido  = pr_docum[p_ind].num_docum 
      AND num_versao_pedido = pr_docum[p_ind].num_versao 
      AND (nom_usuario_aprov IS NULL OR nom_usuario_aprov = ' ')
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','aprov_ped_sup:count2')
      RETURN FALSE
   END IF
   
   IF p_count = p_qtd_reg THEN
      LET p_msg = 'Não foi possivel atualizar\n tabela aprov_ped_sup'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   UPDATE sup_pc_aprov_uni_func 
      SET nom_usuario_aprov = p_cod_user, 
          dat_aprovacao = p_dat_atu, 
          hor_aprovacao = p_hor_atu 
    WHERE empresa = pr_docum[p_ind].empresa
      AND cod_nivel_autorid = p_cod_aprovador
      AND num_pedido = pr_docum[p_ind].num_docum 
      AND num_versao_pedido = pr_docum[p_ind].num_versao
      AND (nom_usuario_aprov IS NULL OR nom_usuario_aprov = ' ')
 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','sup_pc_aprov_uni_func')
      RETURN FALSE
   END IF

   IF p_lib_pedido THEN
      IF NOT pol1158_libera_pc() THEN
         RETURN FALSE
      END IF
      LET p_msg = 'DOCUMENTO APROVADO E LIBERADO'
      CALL pol1158_ins_resumo() RETURNING p_status
      IF NOT pol1158_notif_comprador() THEN
         LET p_msg = 'NAO FOI POSSIVEL NOTIFICAR O COMPRADOR'
         CALL pol1158_ins_resumo() RETURNING p_status
      END IF      
   ELSE
      LET p_msg = 'DOCUMENTO APROVADO'
      CALL pol1158_ins_resumo() RETURNING p_status
      IF NOT pol1158_notif_prox_aprov() THEN
         LET p_msg = 'NAO FOI POSSIVEL NOTIFICAR O PROXIMO APROVADOR'
         CALL pol1158_ins_resumo() RETURNING p_status
      END IF      
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1158_libera_pc()#
#---------------------------#   
   
   DEFINE p_dat_compra_1 DATE,  
          p_dat_compra_2 DATE,   
          p_dat_compra_3  DATE
   
   UPDATE pedido_sup 
      SET ies_situa_ped = 'R'
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_pedido  = pr_docum[p_ind].num_docum 
      AND num_versao  = pr_docum[p_ind].num_versao
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','pedido_sup')
      RETURN FALSE
   END IF

   DECLARE cq_lib_oc CURSOR WITH HOLD FOR
    SELECT num_oc, 
           num_versao, 
           cod_fornecedor, 
           cod_item, 
           cod_unid_med, 
           fat_conver_unid, 
           pre_unit_oc, 
           qtd_solic,
           ies_situa_oc
      FROM ordem_sup 
     WHERE cod_empresa  = pr_docum[p_ind].empresa   
       AND num_pedido   = pr_docum[p_ind].num_docum 
       AND ies_situa_oc = 'A' 
       AND ies_versao_atual = 'S' 
       AND ies_situa_oc != 'C'   

   FOREACH cq_lib_oc INTO
           p_num_oc,         
           p_num_versao,     
           p_cod_fornecedor, 
           p_cod_item,       
           p_cod_unid_med,   
           p_fat_conver_unid,
           p_pre_unit_oc,    
           p_qtd_solic,
           p_ies_situacao     

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_lib_oc')
         RETURN FALSE
      END IF

      IF p_ies_situacao <> 'R' THEN
      
         UPDATE ordem_sup
            SET ies_situa_oc = 'R',
                cnd_pgto = p_cnd_pgto, 
                cod_mod_embar = p_cod_mod_embar, 
                cod_moeda = p_cod_moeda     
          WHERE cod_empresa = pr_docum[p_ind].empresa
            AND num_oc      = p_num_oc
            AND num_versao  = p_num_versao
            AND ies_versao_atual = 'S' 

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizando','ordem_sup')
            RETURN FALSE
         END IF

         LET p_msg = 'LIBERACAO DA ORDEM DE COMPRA ', p_num_oc
         CALL pol1158_ins_resumo() RETURNING p_status
         
      END IF

      UPDATE item_fornec 
         SET cnd_pgto = p_cnd_pgto, 
             cod_mod_embar = p_cod_mod_embar, 
             cod_moeda = p_cod_moeda 
       WHERE cod_empresa = pr_docum[p_ind].empresa
         AND cod_fornecedor = p_cod_fornecedor
         AND cod_item = p_cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Update','item_fornec')
         RETURN FALSE
      END IF

      SELECT dat_compra_1,
             dat_compra_2,
             dat_compra_3
        INTO p_dat_compra_1,
             p_dat_compra_2,
             p_dat_compra_3
        FROM item_fornec_comp
       WHERE cod_empresa = pr_docum[p_ind].empresa
         AND cod_fornecedor = p_cod_fornecedor
         AND cod_item = p_cod_item

      IF STATUS <> 0 AND STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','item_fornec_comp')
         RETURN FALSE
      END IF

      IF STATUS = 0 THEN
         UPDATE item_fornec_comp 
            SET dat_compra_1      = p_dat_compra_2, 
                pre_unit_compra_1 = p_pre_unit_oc,
                cnd_pgto_1        = p_cnd_pgto, 
                cod_mod_embar_1   = p_cod_mod_embar, 
                cod_moeda_compra_1= p_cod_moeda, 
                dat_compra_2      = p_dat_compra_3, 
                pre_unit_compra_2 = p_pre_unit_oc,
                cnd_pgto_2        = p_cnd_pgto, 
                cod_mod_embar_2   = p_cod_mod_embar, 
                cod_moeda_compra_2= p_cod_moeda, 
                dat_compra_3      = p_dat_emis, 
                pre_unit_compra_3 = p_pre_unit_oc,
                cnd_pgto_3        = p_cnd_pgto, 
                cod_mod_embar_3   = p_cod_mod_embar, 
                cod_moeda_compra_3= p_cod_moeda
          WHERE cod_empresa = pr_docum[p_ind].empresa
            AND cod_fornecedor = p_cod_fornecedor
            AND cod_item = p_cod_item

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Update','item_fornec_comp')
            RETURN FALSE
         END IF

      END IF
      
   END FOREACH
   
   #IF NOT pol1158_ins_sup_par() THEN
   #   RETURN FALSE
   #END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1158_ins_sup_par()
#-----------------------------#

   SELECT parametro 
     FROM sup_par_ped_compra 
    WHERE empresa = pr_docum[p_ind].empresa 
      AND pedido_compra = pr_docum[p_ind].num_docum 
      AND parametro = 'val_ver_aprov_ped001' 

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','sup_par_ped_compra')
      RETURN FALSE
   END IF
   
   IF STATUS = 100 THEN
      INSERT INTO sup_par_ped_compra(
         empresa, 
         pedido_compra, 
         parametro, 
         des_parametro, 
         parametro_ind, 
         parametro_texto, 
         parametro_val, 
         parametro_num, 
         parametro_dat) 
         VALUES(pr_docum[p_ind].empresa,
                pr_docum[p_ind].num_docum,
                'val_ver_aprov_ped001', 
                'Dif. valor total do pedido de compra na aprovação da versão', 
                NULL, 
                p_cod_unid_med, 
                pr_docum[p_ind].num_versao, 
                p_val_tot_ped, 
                p_dat_atu)
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','sup_par_ped_compra')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#   
FUNCTION pol1158_notif_comprador()
#----------------------------------#   
   
   DEFINE p_cod_usuario CHAR(08)
   
   SELECT login
     INTO p_cod_usuario
     FROM comprador
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND cod_comprador = p_cod_comprador
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'comprador')
      RETURN FALSE
   END IF

   IF p_cod_usuario IS NOT NULL THEN
      IF NOT pol1158_ins_email(
             p_cod_usuario,
             pr_docum[p_ind].num_docum, 
             pr_docum[p_ind].num_versao, 
             "PA",
             pr_docum[p_ind].empresa,
             p_cod_user) THEN
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

   
#----------------------------------#   
FUNCTION pol1158_notif_prox_aprov()#
#----------------------------------#
   
   DEFINE p_prox_aprov  CHAR(02),
          p_prox_user   CHAR(10),
          p_envia_email CHAR(01)

   DECLARE cq_prox_aprov CURSOR FOR
    SELECT b.cod_nivel_autorid, a.hierarquia
      FROM sup_niv_autorid_complementar a,
           aprov_ped_sup b
     WHERE b.cod_empresa = pr_docum[p_ind].empresa
       AND b.cod_empresa = a.empresa
       AND b.cod_nivel_autorid = a.nivel_autoridade
       AND b.num_pedido = pr_docum[p_ind].num_docum
       AND b.num_versao_pedido = pr_docum[p_ind].num_versao
       AND b.cod_nivel_autorid <> p_cod_aprovador
       AND (b.nom_usuario_aprov IS NULL OR b.nom_usuario_aprov = " ")
     ORDER BY a.hierarquia DESC
   
   FOREACH cq_prox_aprov INTO p_prox_aprov
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_prox_aprov')
         RETURN FALSE
      END IF
      
      DECLARE cq_prox_usuer CURSOR FOR
       SELECT nom_usuario 
         FROM usuario_nivel_aut 
        WHERE cod_empresa = pr_docum[p_ind].empresa
          AND ies_versao_atual = 'S'
          AND cod_nivel_autorid = p_prox_aprov
      
      FOREACH cq_prox_usuer INTO p_prox_user
   
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_prox_aprov')
            RETURN FALSE
         END IF
         
         EXIT FOREACH
      
      END FOREACH
      
      EXIT FOREACH
      
   END FOREACH
   
   IF p_prox_user IS NULL THEN
      RETURN FALSE
   END IF
   
   LET p_msg = 'FALTA APROVACAO DO(A) ', p_prox_aprov, '/', p_prox_user
   CALL pol1158_ins_resumo() RETURNING p_status

  SELECT val_parametro 
    INTO p_envia_email
    FROM log_val_parametro 
   WHERE empresa   = pr_docum[p_ind].empresa
     AND parametro = 'envia_email_proximo_nivel_pd'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','log_val_parametro')
      RETURN FALSE
   END IF

   IF p_envia_email = 'S' THEN   
      IF NOT pol1158_ins_email(
             p_prox_user,
             pr_docum[p_ind].num_docum, 
             pr_docum[p_ind].num_versao, 
             'PC',
             pr_docum[p_ind].empresa,
             p_cod_user) THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1158_aprova_ad()#
#---------------------------#

   DEFINE p_prox_nivel  CHAR(02),
          p_prox_user   CHAR(10)
   
   DECLARE cq_ad_aprov CURSOR FOR
    SELECT cod_nivel_autor
      FROM ad_aprov_temp_265
     WHERE empresa = pr_docum[p_ind].empresa  
       AND num_ad  = pr_docum[p_ind].num_docum
     ORDER BY cod_nivel_autor
   
   FOREACH cq_ad_aprov INTO p_cod_nivel_autor    
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_ad_aprov')
         RETURN FALSE
      END IF
      
      UPDATE aprov_necessaria 
         SET ies_aprovado = 'S',     
             cod_usuario_aprov = p_user,
             dat_aprovacao = p_dat_atu,    
             hor_aprovacao = p_hor_atu    
       WHERE cod_empresa = pr_docum[p_ind].empresa
         AND num_ad = pr_docum[p_ind].num_docum
         AND cod_nivel_autor = p_cod_nivel_autor
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','aprov_necessaria')
         RETURN FALSE
      END IF

   END FOREACH
   
   LET p_cod_aprovador = p_cod_nivel_autor
   LET p_campo_txt = pr_docum[p_ind].num_docum
   LET p_msg = 'ARPOVACAO DA AD ', p_campo_txt CLIPPED
   CALL pol1158_ins_resumo() RETURNING p_status

   SELECT COUNT(cod_nivel_autor) 
     INTO p_count
     FROM aprov_necessaria 
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_ad = pr_docum[p_ind].num_docum
      AND ies_aprovado = 'N'

   IF p_count = 0 THEN  
      IF NOT pol1158_atu_ad() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   DECLARE ad_prox_nivel CURSOR FOR
    SELECT cod_nivel_autor 
      FROM aprov_necessaria 
     WHERE cod_empresa = pr_docum[p_ind].empresa 
       AND num_ad = pr_docum[p_ind].num_docum 
       AND ies_aprovado = 'N' 
       AND cod_nivel_autor > p_cod_nivel_autor
     ORDER BY cod_nivel_autor 
          
   FOREACH ad_prox_nivel INTO p_prox_nivel
            
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ad_prox_nivel')
         RETURN FALSE
      END IF
      
      DECLARE ad_prox_user CURSOR FOR
       SELECT cod_usuario
         FROM usu_nivel_aut_cap
        WHERE cod_empresa = pr_docum[p_ind].empresa 
          AND cod_nivel_autor = p_prox_nivel
          AND cod_emp_usuario IS NOT NULL
          AND cod_uni_funcio = pr_compl[p_ind].cod_uni_funcio
          AND ies_versao_atual = 'S'
          AND num_versao IS NOT NULL
          AND ies_tip_autor IS NOT NULL
          AND ies_ativo = 'S'

      FOREACH ad_prox_user INTO p_prox_user
            
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','ad_prox_user')
            RETURN FALSE
         END IF
         
         EXIT FOREACH
      
      END FOREACH
   
   END FOREACH

   IF p_prox_user IS NULL THEN
      LET p_msg = 'NAO FOI POSSIVEL LER PROX APROVADOR, P/ EMAIL ',
                   pr_docum[p_ind].empresa, '/', pr_docum[p_ind].num_docum CLIPPED
      CALL pol1158_ins_resumo() RETURNING p_status
      RETURN FALSE
   END IF

   LET p_msg = 'FALTA APROVACAO DO(A) ', p_prox_user, '/', p_prox_nivel
   CALL pol1158_ins_resumo() RETURNING p_status

   IF NOT pol1158_ins_email(
          p_prox_user,
          pr_docum[p_ind].num_docum, 
          pr_docum[p_ind].num_versao, 
          'AD',
          pr_docum[p_ind].empresa,
          p_user) THEN
      RETURN FALSE
   END IF
               
   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1158_atu_ad()
#-----------------------#

   DEFINE p_ano CHAR(04),
          p_mes CHAR(02),
          p_num_ap INTEGER,
          p_cod_tip_desp CHAR(15),
          p_ies_sup_cap CHAR(01),
          p_ad INTEGER,
          p_set_aplicacao CHAR(01)

   LET p_cod_user = p_user
   LET p_campo_txt = p_dat_atu
   LET p_ano = p_campo_txt[7,10]
   LET p_mes = p_campo_txt[4,5]

  SELECT set_aplicacao
    INTO p_set_aplicacao
    FROM ad_mestre
   WHERE cod_empresa = pr_docum[p_ind].empresa
     AND num_ad = pr_docum[p_ind].num_docum 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','AD_MESTRE')
      RETURN FALSE
   END IF

   IF p_set_aplicacao IS NULL THEN
      LET p_set_aplicacao = '0'
   END IF
   
   IF p_set_aplicacao = '1' THEN
      LET p_ies_sup_cap = 'H'
   ELSE
      IF p_set_aplicacao = '6' THEN
         LET p_ies_sup_cap = 'O'
      ELSE
         LET p_ies_sup_cap = pol1158_le_audit()
      END IF
   END IF
  
  UPDATE ad_mestre 
     SET ies_sup_cap = p_ies_sup_cap
   WHERE cod_empresa = pr_docum[p_ind].empresa
     AND num_ad = pr_docum[p_ind].num_docum 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','ad_mestre')
      RETURN FALSE
   END IF

   UPDATE deposito_cap 
      SET dat_deposito = p_dat_atu 
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_ad = pr_docum[p_ind].num_docum 
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','deposito_cap')
      RETURN FALSE
   END IF

  {SELECT COUNT (*) 
    INTO p_count
    FROM lanc_cont_cap 
   WHERE cod_empresa = pr_docum[p_ind].empresa
     AND num_ad_ap = pr_docum[p_ind].num_docum 
     AND ies_ad_ap = '1' 
     AND ies_liberad_contab = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','lanc_cont_cap')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      UPDATE lanc_cont_cap 
         SET dat_lanc = p_dat_atu,
             ies_liberad_contab = "S" 
       WHERE cod_empresa = pr_docum[p_ind].empresa   
         AND num_ad_ap   = pr_docum[p_ind].num_docum
         AND ies_ad_ap   = "1"

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','lanc_cont_cap')
         RETURN FALSE
      END IF

      UPDATE ctb_lanc_ctbl_cap 
         SET dat_movto  = p_dat_atu,
             periodo_contab = p_ano,
             segmto_periodo = p_mes 
       WHERE empresa    = pr_docum[p_ind].empresa  
         AND num_ad_ap  = pr_docum[p_ind].num_docum
         AND eh_ad_ap   = "1"
    
      IF STATUS = -239 THEN
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizando','ctb_lanc_ctbl_cap')
            RETURN FALSE
         END IF
      END IF
      
   END IF}

   DECLARE cq_ad_ap CURSOR FOR
    SELECT num_ap
      FROM ad_ap
     WHERE cod_empresa = pr_docum[p_ind].empresa 
       AND num_ad = pr_docum[p_ind].num_docum
   
   FOREACH cq_ad_ap INTO p_num_ap
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_ad_ap')
         RETURN FALSE
      END IF
      
      SELECT COUNT(num_ad)
        INTO p_count
       FROM ad_ap 
      WHERE cod_empresa = pr_docum[p_ind].empresa 
        AND num_ap = p_num_ap
        AND num_ad <> pr_docum[p_ind].num_docum
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ad_ap')
         RETURN FALSE
      END IF
      
      IF p_count = 0 THEN
         UPDATE ap 
            SET ies_lib_pgto_cap = 'N' 
          WHERE num_ap = p_num_ap
            AND cod_empresa = pr_docum[p_ind].empresa
            AND ies_versao_atual = 'S'
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizando','ap')
            RETURN FALSE
         END IF
      END IF
   
   END FOREACH

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1158_le_audit()#
#--------------------------#
   
   DEFINE p_retorno  CHAR(01),
          p_nom_prog CHAR(07)
          
   SELECT desc_manut[1,7]
     INTO p_nom_prog
     FROM audit_cap
    WHERE cod_empresa = pr_docum[p_ind].empresa
      AND num_ad_ap = pr_docum[p_ind].num_docum
      AND ies_ad_ap = '1'
      AND ies_manut = 'I'
      AND data_manut > '01/01/2012'
   
   IF STATUS <> 0 THEN
      LET p_nom_prog = NULL
   END IF
   
   IF p_nom_prog IS NULL THEN
      LET p_retorno = 'C'
   ELSE
      IF p_nom_prog = 'CAP9600' OR 
         p_nom_prog = 'CAP4170' OR 
         p_nom_prog = 'CAP4110' OR 
         p_nom_prog = 'CAP2770' THEN
         LET p_retorno = 'J'
      ELSE
         IF p_nom_prog = 'CAP0020' THEN
            LET p_retorno = 'S'
         ELSE
            LET p_retorno = 'C'
         END IF
      END IF
   END IF
         
   RETURN p_retorno

END FUNCTION   
   
#------------------------------------#
FUNCTION pol1158_le_usuario(p_codido)#
#------------------------------------#

   DEFINE p_codido CHAR(08)

   SELECT e_mail,
          nom_funcionario
     INTO p_den_email,
          p_nom_func
     FROM usuarios
    WHERE cod_usuario = p_codido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','usuarios')
      LET p_den_email = ''
      LET p_nom_func = ''
   END IF

END FUNCTION        
   
#----------------------------#
FUNCTION pol1158_tip_despesa()
#----------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1158c") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1158c AT 02,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DISPLAY p_cod_empresa to cod_empresa
   
   LET p_dat_atu = TODAY

   CALL pol1158_agrupa_ads() RETURNING p_status
   
   CLOSE WINDOW w_pol1158c
   
   RETURN(p_status)

END FUNCTION

#----------------------------#
FUNCTION pol1158_agrupa_ads()#
#----------------------------#
   
   DEFINE p_doc_aprov  SMALLINT,
          p_qtd_linhas INTEGER
   
   CALL pol1158_del_temp()

   IF NOT pol1158_le_ad() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE pr_tipo TO NULL 

   LET p_ind = 1
   LET p_qtd_tot_ads = 0
   LET p_val_tot_ads = 0
   
   DECLARE cq_ce CURSOR FOR
    SELECT DISTINCT cod_tip_despesa
      FROM ad_aprov_temp_265 
     ORDER BY cod_tip_despesa
  
   FOREACH cq_ce INTO p_cod_tip_despesa
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_CE')
         RETURN FALSE
      END IF
      
      IF NOT pol1158_aprov_temp() THEN
         RETURN FALSE
      END IF
      
   END FOREACH

   IF p_ind = 1 THEN 
      LET p_msg = 'Não há ADs pendentes de aprovação\n',
                  'para o usuário logado.\n',
                  'Operação cancelada!'
      RETURN FALSE
   END IF

   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   LET p_qtd_linhas = p_ind - 1

   IF NOT pol1158_sel_tip_desp() THEN
      RETURN FALSE
   END IF

   CALL pol1158_imprime_telas()

   LET p_msg = 'Confirma a aprovação dos\n',
               'itens selecionados ???'
   IF log0040_confirm(20,25,p_msg) = FALSE THEN
      LET p_msg = 'Operação cancelada.'
      RETURN FALSE
   END IF

   LET p_doc_aprov = FALSE
   
   DECLARE cq_empresa CURSOR WITH HOLD FOR
    SELECT DISTINCT empresa
      FROM ad_aprov_temp_265
     WHERE aprova  = 'S'
     ORDER BY empresa
     
   FOREACH cq_empresa INTO p_empresa
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_empresa')
         RETURN FALSE
      END IF
   
      INITIALIZE pr_docum TO NULL
      LET p_index = 1

      IF NOT pol1158_prepara_docum() THEN
         RETURN FALSE
      END IF

      LET p_index = p_index - 1
   
      IF p_index = 0 THEN
         CONTINUE FOREACH
      END IF
   
      LET p_doc_aprov = TRUE
      CALL log085_transacao("BEGIN")

      IF NOT pol1158_apr_tip_desp() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      CALL log085_transacao("COMMIT")

   END FOREACH
   
   IF NOT p_doc_aprov THEN 
      LET p_msg = 'Nenhum documento foi\n',
                  'selecionado p/ aprovação.\n',
                  'Operação cancelada!'
      RETURN FALSE
   END IF
   
   FOR p_ind = 1 to p_qtd_linhas
       INSERT INTO aprov_por_tipo_265
        VALUES(p_user,
               pr_tipo[p_ind].ies_aprovar,
               pr_tipo[p_ind].empresa,
               pr_tipo[p_ind].estado,
               pr_tipo[p_ind].cod_tip_despesa,
               pr_tipo[p_ind].qtd_ads,
               pr_tipo[p_ind].val_ads,
               p_dat_atu,
               p_hor_atu)
       IF STATUS <> 0 THEN
          CALL log003_err_sql('INSERT','aprov_por_tipo_265')
          EXIT FOR
       END IF
   END FOR
   
   SELECT COUNT(nom_usuario)
     INTO p_count
     FROM email_temp_265

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','email_temp_265:1')
   ELSE
      IF p_count > 0 THEN
         CALL log085_transacao("BEGIN")
         IF NOT pol1158_envia_email() THEN
            CALL log085_transacao("ROLLBACK")
         ELSE
            CALL log085_transacao("COMMIT")
         END IF
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1158_prepara_docum()
#-------------------------------#   

   DECLARE cq_prepara CURSOR FOR
    SELECT aprova,
           empresa,
           num_ad,
           cod_uni_funcio
      FROM ad_aprov_temp_265
     WHERE aprova  = 'S'
       AND empresa = p_empresa
   FOREACH cq_prepara INTO 
           pr_docum[p_index].ies_aprovar,
           pr_docum[p_index].empresa,
           pr_docum[p_index].num_docum,
           pr_compl[p_index].cod_uni_funcio
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','exclamation')
         RETURN FALSE
      END IF
      
      LET pr_docum[p_index].tip_docum = 'FINANCEIRO'
      LET p_index = p_index + 1
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1158_apr_tip_desp()
#-----------------------------#

   FOR p_ind = 1 TO p_index
       IF pr_docum[p_ind].ies_aprovar = 'S' THEN
          IF NOT pol1158_aprova_ad() THEN   
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1158_aprov_temp()
#----------------------------#
    
   DECLARE cq_at CURSOR FOR
    SELECT empresa,
           SUM(valor_ad) 
      FROM ad_aprov_temp_265 
     WHERE cod_tip_despesa = p_cod_tip_despesa
       AND ies_soma = 'S'
     GROUP BY empresa
     ORDER BY empresa
   
   FOREACH cq_at INTO
      pr_tipo[p_ind].empresa,
      pr_tipo[p_ind].val_ads

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_AT')
         RETURN FALSE
      END IF

      SELECT COUNT(num_ad)      
        INTO pr_tipo[p_ind].qtd_ads
        FROM ad_aprov_temp_265 
       WHERE empresa = pr_tipo[p_ind].empresa
         AND cod_tip_despesa = p_cod_tip_despesa
      
      IF STATUS <> 0 THEN
         LET pr_tipo[p_ind].cod_tip_despesa = 0
      END IF

      LET pr_tipo[p_ind].ies_aprovar = 'N'
      LET pr_tipo[p_ind].cod_tip_despesa = p_cod_tip_despesa
      
      CALL pol1158_le_descricao()
      
      LET p_qtd_tot_ads = p_qtd_tot_ads + pr_tipo[p_ind].qtd_ads
      LET p_val_tot_ads = p_val_tot_ads + pr_tipo[p_ind].val_ads
      
      LET p_ind = p_ind + 1

      IF p_ind > 5000 THEN
         EXIT FOREACH
      END IF
       
   END FOREACH
         
   RETURN TRUE
         
END FUNCTION

#-----------------------------#
FUNCTION pol1158_le_descricao()
#-----------------------------#

   SELECT nom_tip_despesa                              
     INTO pr_tipo[p_ind].nom_tip_despesa                              
     FROM tipo_despesa                                   
    WHERE cod_empresa = pr_tipo[p_ind].empresa                      
      AND cod_tip_despesa = pr_tipo[p_ind].cod_tip_despesa            
                                                   
   IF STATUS <> 0 THEN  
      LET pr_tipo[p_ind].nom_tip_despesa = ''                               
   END IF                                                

   SELECT uni_feder
     INTO pr_tipo[p_ind].estado
     FROM empresa
    WHERE cod_empresa = pr_tipo[p_ind].empresa
   
   IF STATUS <> 0 THEN
      LET pr_docum[p_ind].estado = ''
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1158_sel_tip_desp()
#-----------------------------#
   
   DEFINE p_tip_docum      CHAR(10),
          p_marca          CHAR(01),
          p_ies_marca      SMALLINT

   LET p_qtd_docum = p_ind - 1
   
   DISPLAY p_qtd_tot_ads TO qtd_tot_ads
   DISPLAY p_val_tot_ads TO val_tot_ads
   
   LET p_ies_marca  = FALSE
   LET INT_FLAG = FALSE
   CALL SET_COUNT(p_ind - 1)

   INPUT ARRAY pr_tipo
      WITHOUT DEFAULTS FROM sr_tipo.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  

      BEFORE FIELD ies_aprovar
         LET p_ies_aprovar = pr_tipo[p_ind].ies_aprovar
      
      AFTER FIELD ies_aprovar
         
         IF p_ind <= p_qtd_docum THEN
            IF pr_tipo[p_ind].ies_aprovar = 'P' AND p_ies_aprovar <> 'P' THEN
               LET p_msg = 'Para aprovação parcial,\n pressione Ctrl+Z'
               CALL log0030_mensagem(p_msg, 'excla')
               LET pr_tipo[p_ind].ies_aprovar = p_ies_aprovar
               DISPLAY p_ies_aprovar TO sr_tipo[s_ind].ies_aprovar
               NEXT FIELD ies_aprovar
            ELSE
               IF pr_tipo[p_ind].ies_aprovar = 'T' THEN
                  LET p_cod_status = 'S'
               ELSE
                  LET p_cod_status = 'N'
               END IF
               IF pr_tipo[p_ind].ies_aprovar = 'P' THEN
               ELSE
                  UPDATE ad_aprov_temp_265
                     SET aprova = p_cod_status
                   WHERE empresa = pr_tipo[p_ind].empresa
                     AND cod_tip_despesa = pr_tipo[p_ind].cod_tip_despesa
                  IF STATUS <> 0 THEN
                     CALL log003_err_sql('update','ad_aprov_temp_265:UPD1')
                     RETURN FALSE
                  END IF
               END IF
            END IF
         END IF

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_ind = p_qtd_docum THEN
               NEXT FIELD ies_aprovar
            END IF
         END IF

      ON KEY (control-l)
         CALL pol1158_imprime_telas()

      ON KEY (control-t)

         LET p_ies_marca = NOT p_ies_marca
         
         IF p_ies_marca THEN
            LET p_marca = 'T'
            LET p_cod_status = 'S'
         ELSE
            LET p_marca = 'N'
            LET p_cod_status = 'N'
         END IF

         FOR p_count = 1 TO ARR_COUNT()
             LET pr_tipo[p_count].ies_aprovar = p_marca
             DISPLAY p_marca TO sr_tipo[p_count].ies_aprovar 
         END FOR

         UPDATE ad_aprov_temp_265
            SET aprova = p_cod_status

         IF STATUS <> 0 THEN
            CALL log003_err_sql('update','ad_aprov_temp_265:ALL')
            RETURN FALSE
         END IF

         LET INT_FLAG = FALSE

      ON KEY (control-z)
         IF pr_tipo[p_ind].cod_tip_despesa IS NOT NULL THEN
            LET p_empresa = pr_tipo[p_ind].empresa
            LET p_cod_tip_despesa = pr_tipo[p_ind].cod_tip_despesa
            IF pol1158_por_ad() THEN
               DISPLAY p_cod_status TO sr_tipo[p_ind].ies_aprovar 
               LET p_ies_aprovar = p_cod_status
            END IF
         END IF
         LET INT_FLAG = FALSE

      AFTER INPUT
         IF NOT INT_FLAG THEN
            LET p_count = 0
            FOR p_index = 1 TO ARR_COUNT()
                IF pr_tipo[p_index].ies_aprovar <> 'N' THEN
                   LET p_count = p_count + 1
                END IF
            END FOR       
            IF p_count = 0 THEN
               LET p_msg = 'Por favor, selecione pelomenos um documento!'
               CALL log0030_mensagem(p_msg,'excla')
               NEXT FIELD ies_aprovar
            END IF
         END IF

   END INPUT
   
   IF INT_FLAG THEN
      LET p_msg = NULL
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1158_por_ad()
#------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1158d") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1158d AT 02,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DISPLAY p_cod_empresa to cod_empresa
   
   CALL pol1158_sel_ad() RETURNING p_status
   
   CLOSE WINDOW w_pol1158d
   
   RETURN(p_status)

END FUNCTION


#------------------------#
FUNCTION pol1158_sel_ad()
#------------------------#

   DEFINE pr_ad                ARRAY[1000] OF RECORD
          ies_aprovar          CHAR(01),
          empresa              CHAR(02),
          estado               CHAR(02),
          num_ad               CHAR(10),
          nom_fornecedor       CHAR(30),
          dat_emis             DATE,
          valor_ad             DECIMAL(12,2)
   END RECORD

   DEFINE p_linha          INTEGER,
          s_linha          INTEGER,
          p_marca          CHAR(01),
          p_ies_marca      SMALLINT
   
   INITIALIZE pr_ad TO NULL
   LET p_linha = 1
   LET p_qtd_ad = 0
   LET p_val_ad = 0
   
   DECLARE cq_sel_ad CURSOR FOR
    SELECT tmp.aprova,
           tmp.num_ad,
           tmp.valor_ad,
           tmp.dat_emis,
           ad.cod_fornecedor
      FROM ad_aprov_temp_265 tmp  
           INNER JOIN ad_mestre ad
              ON ad.cod_empresa = tmp.empresa
             AND ad.num_ad = tmp.num_ad
     WHERE tmp.empresa = p_empresa
       AND tmp.cod_tip_despesa = p_cod_tip_despesa
       AND tmp.ies_soma = 'S'      

   FOREACH cq_sel_ad INTO
           pr_ad[p_linha].ies_aprovar,
           pr_ad[p_linha].num_ad,
           pr_ad[p_linha].valor_ad,
           pr_ad[p_linha].dat_emis,
           p_cod_fornecedor
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_sel_ad')
         RETURN FALSE
      END IF
      
      LET pr_ad[p_linha].empresa = p_empresa
      
      SELECT raz_social
        INTO pr_ad[p_linha].nom_fornecedor
        FROM fornecedor
       WHERE cod_fornecedor = p_cod_fornecedor
       
      IF STATUS <> 0 THEN
         LET pr_ad[p_linha].nom_fornecedor = ''
      END IF

      SELECT uni_feder
        INTO pr_ad[p_linha].estado
        FROM empresa
       WHERE cod_empresa = p_empresa
   
      IF STATUS <> 0 THEN
         LET pr_ad[p_linha].estado = ''
      END IF
      
      LET p_qtd_ad = p_qtd_ad + 1
      LET p_val_ad = p_val_ad + pr_ad[p_linha].valor_ad
      LET p_linha = p_linha + 1
      
   END FOREACH
      
   DISPLAY p_qtd_ad TO qtd_ad
   DISPLAY p_val_ad TO val_total
   
   CALL SET_COUNT(p_linha - 1)
   
   INPUT ARRAY pr_ad
      WITHOUT DEFAULTS FROM sr_ad.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW
         LET p_linha = ARR_CURR()
         LET s_linha = SCR_LINE()  

      AFTER FIELD ies_aprovar
         
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_linha >= p_qtd_ad THEN
               NEXT FIELD ies_aprovar
            END IF
         END IF
         
      ON KEY (control-p)
         LET p_num_docum = pr_ad[p_linha].num_ad
         CALL pol1158_textos_ad()
         LET INT_FLAG = FALSE
         
      ON KEY (control-t)
         LET p_ies_marca = NOT p_ies_marca
         IF p_ies_marca THEN
            LET p_marca = 'S'
         ELSE
            LET p_marca = 'N'
         END IF
         FOR p_count = 1 TO ARR_COUNT()
             LET pr_ad[p_count].ies_aprovar = p_marca
             DISPLAY p_marca TO sr_ad[p_count].ies_aprovar 
         END FOR
         LET INT_FLAG = FALSE

      ON KEY (control-z)
         IF pr_ad[p_linha].num_ad IS NOT NULL THEN
            LET p_num_docum = pr_ad[p_linha].num_ad
            CALL pol1158_dados_ad()
         END IF
         LET INT_FLAG = FALSE

   END INPUT
   
   IF INT_FLAG THEN
      LET p_msg = NULL
      RETURN FALSE
   END IF
   
   LET p_qtd_ad = 0
   LET p_val_ad = 0
   
   FOR p_count = 1 TO ARR_COUNT()
       IF pr_ad[p_count].ies_aprovar = 'S' THEN
          LET p_qtd_ad = p_qtd_ad + 1
       END IF
       UPDATE ad_aprov_temp_265
          SET aprova = pr_ad[p_count].ies_aprovar
        WHERE empresa = p_empresa
          AND num_ad = pr_ad[p_count].num_ad
       IF STATUS <> 0 THEN
          CALL log003_err_sql('UPDADTE','ad_aprov_temp_265:UPD2')
          RETURN FALSE
       END IF
   END FOR
   
   LET p_count = p_count - 1
   
   IF p_qtd_ad = p_count THEN
      LET p_cod_status = 'T'
   ELSE
      IF p_qtd_ad > 0 THEN
         LET p_cod_status = 'P'
      ELSE
         LET p_cod_status = 'N'
      END IF
   END IF

   {SELECT SUM(valor_ad)
     INTO p_val_ad
     FROM ad_aprov_temp_265
    WHERE empresa = p_empresa
      AND cod_tip_despesa = p_cod_tip_despesa
      AND aprova = 'S'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','ad_aprov_temp_265:SUM')
      RETURN FALSE
   END IF
   
   IF p_val_ad IS NULL THEN
      LET p_val_ad = 0
   END IF}
       
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1158_envia_email()#
#-----------------------------#
   
   DEFINE  p_arquivo   CHAR(30)
                       
   LET p_assunto = 'Aprovacao de documentos'
   
   DECLARE cq_le_de CURSOR FOR
    SELECT DISTINCT
           cod_emitente,
           email_emitente,
           nom_emitente
      FROM email_temp_265
     ORDER BY cod_emitente

   FOREACH cq_le_de INTO p_cod_user, p_email_emitente, p_nom_emitente

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','email_env_265:cq_le_de')
         RETURN FALSE
      END IF
      
      IF p_email_emitente IS NULL OR
         p_email_emitente = ' ' THEN
         LET p_parametro.texto = 'USUARIO ', p_cod_user CLIPPED,
                ' SEM EMAIL CADASTRADO'
         CALL pol1161_grava_auadit(p_parametro) RETURNING p_status
         CONTINUE FOREACH
      END IF

      DECLARE cq_le_para CURSOR FOR
       SELECT DISTINCT 
              cod_usuario, 
              email_usuario,
              nom_usuario,
              tip_docum  
         FROM email_temp_265
        WHERE cod_emitente = p_cod_user
   
      FOREACH cq_le_para INTO p_cod_usuario, p_email_usuario, p_nom_usuario, p_tip_docum

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','email_env_265:cq_le_para')
            RETURN FALSE
         END IF

         IF p_email_usuario IS NULL OR
            p_email_usuario = ' ' THEN
            LET p_parametro.texto = 'USUARIO ', p_cod_usuario CLIPPED,
                   ' SEM EMAIL CADASTRADO'
            CALL pol1161_grava_auadit(p_parametro) RETURNING p_status
            CONTINUE FOREACH
         END IF

         SELECT nom_caminho
           INTO p_den_comando
           FROM log_usu_dir_relat 
          WHERE usuario = p_cod_usuario
            AND empresa = p_cod_empresa 
            AND sistema_fonte = 'LST' 
            AND ambiente = g_ies_ambiente
  
         IF STATUS <> 0 THEN
            LET p_parametro.texto = 'USUARIO ', p_cod_usuario CLIPPED,
                   ' SEM PASTA DE RELATORIO CADASTRADA'
            CALL pol1161_grava_auadit(p_parametro) RETURNING p_status
            CONTINUE FOREACH
         END IF

         CASE p_tip_docum

            WHEN 'PC' 
               LET p_titulo = 'Falta sua aprovação para:'
               LET p_den_docum = 'Pedido de Compra'
         
            WHEN 'PA'
               LET p_titulo = 'Pedidos aprovado(s) e liberado(s):'
               LET p_den_docum = 'Pedido de compra'

            WHEN 'AD'
               LET p_titulo = 'Falta sua aprovação para:'
               LET p_den_docum = 'Financeiro (AD)'

            WHEN 'NF'
               LET p_titulo = 'Falta sua aprovação para:'
               LET p_den_docum = 'Nota Fiscal'

            WHEN 'UF'
               LET p_titulo = 'Nota(s) aprovada(s) e liberada(s):'
               LET p_den_docum = 'Nota Fiscal'

         END CASE
            
         LET p_arquivo = p_cod_user CLIPPED, '-', p_cod_usuario CLIPPED, '.lst'
         LET p_den_comando = p_den_comando CLIPPED, p_arquivo
         
         START REPORT pol1158_relat TO p_den_comando
      
         DECLARE cq_le_docs CURSOR FOR
          SELECT num_docum,
                 cod_empresa
            FROM email_temp_265
           WHERE cod_usuario  = p_cod_usuario
             AND cod_emitente = p_cod_user
             AND tip_docum = p_tip_docum   
           ORDER by cod_empresa, num_docum     

         FOREACH cq_le_docs INTO  
                 p_num_docum,     
                 p_cod_empre

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','email_env_265:cq_le_docs')
               EXIT FOREACH
            END IF
                  
            LET p_imp_linha = 'Empresa: ',p_cod_empre CLIPPED, ' - ',
                   p_den_docum CLIPPED, ': ', p_num_docum CLIPPED
         
            OUTPUT TO REPORT pol1158_relat() 
      
         END FOREACH

         FINISH REPORT pol1158_relat  
      
         CALL log5600_envia_email(p_email_emitente, p_email_usuario, p_assunto, p_den_comando, 2)
            
      END FOREACH
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION


#---------------------#
 REPORT pol1158_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 60
          
   FORMAT
          
      FIRST PAGE HEADER  
         
         PRINT COLUMN 001, 'A/C. ', p_nom_usuario
         PRINT
         PRINT COLUMN 001, p_titulo
         PRINT
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_imp_linha

      ON LAST ROW
        PRINT
        PRINT COLUMN 005, 'Atenciosamente,'
        PRINT
        PRINT COLUMN 001, p_nom_emitente
        
END REPORT

#----------------------------#
FUNCTION pol1158_assinatura()#
#----------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1158e") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1158e AT 04,03 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_assinatura()

   CLOSE WINDOW w_pol1158e
  
END FUNCTION

#----------------------------------#
FUNCTION pol1158_exibe_assinatura()#
#----------------------------------#

   DEFINE pr_assinatura ARRAY[50] OF RECORD
          empresa    CHAR(02),
          cod_nivel  CHAR(03),
          den_nivel  CHAR(30),
          login      CHAR(08),
          data       CHAR(10),
          hora       CHAR(08)
   END RECORD
   
   DEFINE p_linha, s_linha INTEGER

   DISPLAY pr_docum[p_ind].empresa to cod_empresa

   LET p_linha = 1

   DECLARE cq_assinatura CURSOR FOR
  SELECT aprov_ped_sup.cod_empresa, 
         aprov_ped_sup.cod_nivel_autorid, ' ', 
         aprov_ped_sup.nom_usuario_aprov, 
         aprov_ped_sup.dat_aprovacao, 
         aprov_ped_sup.hor_aprovacao 
    FROM aprov_ped_sup, sup_niv_autorid_complementar 
   WHERE aprov_ped_sup.cod_empresa = pr_docum[p_ind].empresa
     AND aprov_ped_sup.cod_empresa = sup_niv_autorid_complementar.empresa 
     AND aprov_ped_sup.cod_nivel_autorid = sup_niv_autorid_complementar.nivel_autoridade 
     AND aprov_ped_sup.num_pedido = pr_docum[p_ind].num_docum
     AND aprov_ped_sup.num_versao_pedido = pr_docum[p_ind].num_versao
   ORDER by sup_niv_autorid_complementar.hierarquia desc


   FOREACH cq_assinatura INTO pr_assinatura[p_linha].*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_assinatura')
         RETURN
      END IF

      SELECT den_nivel_autorid 
        INTO pr_assinatura[p_linha].den_nivel
        FROM nivel_autoridade 
       WHERE nivel_autoridade.cod_empresa = pr_docum[p_ind].empresa
         AND nivel_autoridade.cod_nivel_autorid = pr_assinatura[p_linha].cod_nivel
      
      LET p_linha = p_linha + 1

      IF p_linha > 50 THEN
         CALL log0030_mensagem('Limite de linhas esgotado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_linha = 1 THEN
      LET p_msg = 'Não há assinuturas para esse pedido ', pr_docum[p_ind].num_docum
      CALL log0030_mensagem(p_msg,'excla')
      RETURN
   END IF                    
   
   CALL SET_COUNT(p_linha - 1)
   
   DISPLAY ARRAY pr_assinatura TO sr_assinatura.*

END FUNCTION   

#-------------------------------#
FUNCTION pol1158_imprime_telas()
#-------------------------------#

   IF NOT pol1158_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1158_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   LET p_qtd_docs    = 0
   LET p_val_tot     = 0
   LET p_ies_imprimiu = FALSE
   
   FOR p_count = 1 TO ARR_COUNT()
      OUTPUT TO REPORT pol1158_imp_docs() 
      LET p_ies_imprimiu = TRUE
   END FOR

   FINISH REPORT pol1158_imp_docs   
   
   IF NOT p_ies_imprimiu THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1158_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1158_imp_docs TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1158.tmp'
         START REPORT pol1158_imp_docs  TO p_caminho
      END IF
   ELSE
      START REPORT pol1158_imp_docs TO p_nom_arquivo
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1158_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------#
 REPORT pol1158_imp_docs()#
#-------------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT

      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 062, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 00, "POL1158       APROVAÇÃO POR TIPO DE DESPESAS",
               COLUMN 051, p_dat_atu USING "dd/mm/yyyy", " ", p_hor_atu

         PRINT COLUMN 001, "---------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'APROV EMP UF TIPO DE DESPESAS                    QTD DOC    VALOR'
         PRINT COLUMN 001, '----- --- -- ----------------------------------- ------- ------------'
          
      PAGE HEADER  
         
         PRINT COLUMN 062, "PAG. ", PAGENO USING "##&"
         PRINT COLUMN 001, 'APROV EMP UF TIPO DE DESPESAS                    QTD DOC    VALOR'
         PRINT COLUMN 001, '----- --- -- ----------------------------------- ------- ------------'

      ON EVERY ROW

         PRINT COLUMN 003, pr_tipo[p_count].ies_aprovar,
               COLUMN 008, pr_tipo[p_count].empresa,
               COLUMN 011, pr_tipo[p_count].estado,
               COLUMN 014, pr_tipo[p_count].cod_tip_despesa USING '####', 
               COLUMN 019, pr_tipo[p_count].nom_tip_despesa,
               COLUMN 050, pr_tipo[p_count].qtd_ads USING '####&',
               COLUMN 058, pr_tipo[p_count].val_ads USING '#,###,##&.&&'

         LET p_qtd_docs = p_qtd_docs + pr_tipo[p_count].qtd_ads
         LET p_val_tot  = p_val_tot +  pr_tipo[p_count].val_ads 
                              
      ON LAST ROW
        
        PRINT COLUMN 050, '------- ------------'
        PRINT COLUMN 050, p_qtd_docs USING '####&',
              COLUMN 058, p_val_tot  USING '#,###,##&.&&'
              
        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#----------------------------#
FUNCTION pol1158_lista_docs()#
#----------------------------#
   
   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1158_listagem TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1158.tmp'
         START REPORT pol1158_listagem  TO p_caminho
      END IF
   ELSE
      START REPORT pol1158_listagem TO p_nom_arquivo
   END IF
      
   IF NOT pol1158_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   LET p_qtd_docs    = 0
   LET p_val_tot     = 0
   LET p_ies_imprimiu = FALSE
   
   FOR p_count = 1 TO p_index
      
      
      OUTPUT TO REPORT pol1158_listagem() 
      LET p_ies_imprimiu = TRUE
   END FOR

   FINISH REPORT pol1158_listagem   
   
   IF NOT p_ies_imprimiu THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------#
 REPORT pol1158_listagem()#
#-------------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT

      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 090, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 00, "POL1158                  APROVAÇÃO CENTRALIZADA DE DOCUMENTOS",
               COLUMN 079, p_dat_atu USING "dd/mm/yyyy", " ", p_hor_atu

         PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------"
         PRINT
         
         IF p_imp_doc = 'S' THEN
            PRINT COLUMN 001, 'SELECIONADO EMP UF DOCUM     VER TIPO       FORNEC                        DATA DOCUM VALOR'
         ELSE
            PRINT COLUMN 001, 'APROVADO    EMP UF DOCUM     VER TIPO       FORNEC                        DATA DOCUM VALOR'
         END IF
                  
         PRINT COLUMN 001, '----------- --- -- ------------- ---------- ----------------------------- ---------- ------------'
          
      PAGE HEADER  
         
         PRINT COLUMN 090, "PAG. ", PAGENO USING "##&"

         IF p_imp_doc = 'S' THEN
            PRINT COLUMN 001, 'SELECIONADO EMP UF DOCUM     VER TIPO       FORNEC                        DATA DOCUM VALOR'
         ELSE
            PRINT COLUMN 001, 'APROVADO    EMP UF DOCUM     VER TIPO       FORNEC                        DATA DOCUM VALOR'
         END IF
                  
         PRINT COLUMN 001, '----------- --- -- ------------- ---------- ----------------------------- ---------- ------------'

      ON EVERY ROW

         PRINT COLUMN 005, pr_docum[p_count].ies_aprovar,
               COLUMN 014, pr_docum[p_count].empresa,
               COLUMN 017, pr_docum[p_count].estado,
               COLUMN 020, pr_docum[p_count].num_docum, 
               COLUMN 031, pr_docum[p_count].num_versao USING '##',
               COLUMN 034, pr_docum[p_count].tip_docum,
               COLUMN 045, pr_docum[p_count].nom_fornecedor,
               COLUMN 075, pr_docum[p_count].dat_docum USING 'dd/mm/yyyy',
               COLUMN 086, pr_docum[p_count].val_docum USING '#,###,##&.&&'

         LET p_val_tot  = p_val_tot +  pr_docum[p_count].val_docum 
                              
      ON LAST ROW
        PRINT COLUMN 058, '----------------------------------------'
        PRINT COLUMN 058, 'DOCUMENTOS:', p_index USING '####&',
              COLUMN 078, 'VALOR:', p_val_tot  USING '###,###,##&.&&'
              
        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-----------------------------#
FUNCTION pol1158_le_despesas()#
#-----------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1158f") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1158f AT 06,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_despesas()

   CLOSE WINDOW w_pol1158f

END FUNCTION

#--------------------------------#
FUNCTION pol1158_exibe_despesas()#
#--------------------------------#
   
   DEFINE lr_despesa ARRAY[100] OF RECORD
          cod_tip_despesa    LIKE tipo_despesa.cod_tip_despesa,
          nom_tip_despesa    LIKE tipo_despesa.nom_tip_despesa
   END RECORD
   
   DEFINE l_ind      INTEGER
   
   LET l_ind = 1
   
   CASE m_tip_docum
        WHEN 'NOTA'       
          LET m_query = pol1158_aviso_rec()
        WHEN 'CONTRATO'   
          LET m_query = pol1158_aviso_rec()
        WHEN 'COMPRAS'    
          LET m_query = pol1158_compras()
        WHEN 'FINANCEIRO' 
          LET m_query = pol1158_financeiro()
   END CASE

   PREPARE var_query FROM m_query  
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','var_query')
      RETURN 
   END IF 
    
   DECLARE cq_despesa CURSOR FOR var_query
   
   FOREACH cq_despesa INTO lr_despesa[l_ind].cod_tip_despesa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('PREPARE','var_query')
         RETURN 
      END IF 
      
      SELECT nom_tip_despesa
        INTO lr_despesa[l_ind].nom_tip_despesa
        FROM tipo_despesa
       WHERE cod_empresa = m_cod_empresa
         AND cod_tip_despesa = lr_despesa[l_ind].cod_tip_despesa

      IF STATUS <> 0 THEN
         LET lr_despesa[l_ind].nom_tip_despesa = ''
      END IF 
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 100 THEN
         CALL log0030_mensagem('Limite de despesas previstas ultrapasou', 'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(l_ind - 1)
   
   DISPLAY ARRAY lr_despesa TO sr_despesa.*

END FUNCTION

#-------------------------#
FUNCTION pol1158_compras()#
#-------------------------#

   DEFINE l_query        CHAR(800)
   
   LET l_query = 
       "SELECT DISTINCT o.cod_tip_despesa ",
       "  FROM ordem_sup o, pedido_sup p ",
       " WHERE o.cod_empresa = p.cod_empresa ",
       "   AND o.num_pedido = p.num_pedido ",
       "   AND o.num_versao_pedido = p.num_versao ",
       "   AND o.ies_versao_atual = 'S' ",
       "   AND o.ies_situa_oc <> 'C' ",
       "   AND p.num_pedido  = '",m_num_docum,"' ",
       "   AND p.num_versao  = '",m_num_versao,"' ",
       "   AND p.cod_empresa = '",m_cod_empresa,"' "
       
   RETURN l_query

END FUNCTION

#----------------------------#
FUNCTION pol1158_financeiro()#
#----------------------------#

   DEFINE l_query        CHAR(800)
   
   LET l_query = 
       "SELECT cod_tip_despesa ",
       "  FROM ad_mestre ",
       " WHERE 1 = 1 ",
       "   AND num_ad  = '",m_num_docum,"' ",
       "   AND cod_empresa = '",m_cod_empresa,"' "
       
   RETURN l_query

END FUNCTION

#---------------------------#
FUNCTION pol1158_aviso_rec()#
#---------------------------#

   DEFINE l_query        CHAR(800)
   
   LET l_query = 
       "SELECT DISTINCT cod_tip_despesa ",
       "  FROM aviso_rec ",
       " WHERE 1 = 1 ",
       "   AND num_aviso_rec  = '",m_num_docum,"' ",
       "   AND cod_empresa = '",m_cod_empresa,"' "
       
   RETURN l_query

END FUNCTION

#----------FIM DO PROGRAMA BL---------------#
{Alterações:
23/10/2012: permitir que um usuário com vários niveis de autoridade possa aprovar documentos
06/11/2012: acerto na gravação da tabela audit_ar, pois estava estourando o campo num_seq
01/02/2013: utilizar uma transação por empresa, na aprovação de AD por tipo de despesa
            função Ctrl+y, para exibir assinaturas do PC
05/02/2013: Ler unidade de medida da tabela ordem_sup, no detalhe do PC
21/02/2013: Botão para imprimir as telas, na opção de aprovar títulos por tipo de despesas.

