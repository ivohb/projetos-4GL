#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1166 - RELAÇÃO DE DOCUMENTOS POR USUÁRIO             #
# OBJETIVO: LISTAR OS DOCUMENTOS APORVADOS E PENDENTES DE APROVAÇÃO #
#           DE CADA USUARIO. PARA CADA DOCUMENTO, LISTAR QUEM JÁ    #
#           APROVOU E QUEM FALTA APROVAR. LISTAR TAMBÉM AS PRINCI-  #
#           PAIS INFORMAÇÕES DE CADA DOCUEMNTO                      #
# AUTOR...: IVO BL                                                  #
# DATA....: 03/12/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       p_den_empresa        LIKE empresa.den_empresa,
       p_user               LIKE usuario.nom_usuario,
       p_num_seq            INTEGER,
       P_Comprime           CHAR(01),
       p_descomprime        CHAR(01),
       p_6lpp               CHAR(100),
       p_8lpp               CHAR(100),
       p_retorno            SMALLINT,
       p_status             SMALLINT,
       p_index              SMALLINT,
       s_index              SMALLINT,
       p_ind                SMALLINT,
       s_ind                SMALLINT,
       p_count              SMALLINT,
       p_houve_erro         SMALLINT,
       p_ies_impressao      CHAR(01),
       g_ies_ambiente       CHAR(01),
       p_caminho            CHAR(080),
       p_versao             CHAR(18),
       p_nom_arquivo        CHAR(100),
       p_nom_tela           CHAR(200),
       p_ies_cons           SMALLINT,
       p_msg                CHAR(500),
       p_last_row           SMALLINT,
       p_query              CHAR (3000),
       comando              CHAR(80),
       p_opcao              CHAR(01)	

END GLOBALS

DEFINE p_ies_admin          SMALLINT,
       p_nom_usuario        CHAR(08),        	  
       p_dat_ini            DATE,
       p_dat_fim            DATE,
       p_ies_aprovacao      CHAR(01),
       p_ies_aprovante      CHAR(01),
       p_ies_detalhe        CHAR(01),
       p_ies_sumarizar      CHAR(01),
       p_ies_emresa         CHAR(01),
       p_nom_funcionario    CHAR(50),
       p_nivel_autoridade   CHAR(02),
       p_le_ad              SMALLINT,
       p_dat_atu            DATE,
       p_num_versao         INTEGER,
       p_cod_user           CHAR(08),
       p_niv_autorid        CHAR(02),
       p_empresa            CHAR(02),
       p_nivel              CHAR(02),
       p_tipo               CHAR(01),
       p_den_nivel          CHAR(30),
       p_tp_docum           CHAR(02),
       p_hieraq_user        INTEGER,
       p_hierarquia         INTEGER,
       p_cod_fornecedor     CHAR(15),
       p_raz_social         CHAR(45),
       s_linha              INTEGER,
       P_ies_ar_cs          CHAR(10),
       p_ar                 INTEGER,
       p_num_nf             CHAR(10),
       p_ser_nf             CHAR(02),
       p_ssr_nf             CHAR(02),
       p_contrato           INTEGER,
       p_ver_cont           INTEGER,
       p_nao_achou          SMALLINT,
       p_parcela            INTEGER, 
       p_vencto             DATE, 
       p_val_pagar          DECIMAL(12,2),
       p_txt_cont           CHAR(2000),
       p_servico            CHAR(15),
       p_sit_contrato       CHAR(01),
       p_especie            CHAR(03),
       p_qtd_lin            INTEGER,
       p_qtd_aprov          INTEGER

   DEFINE p_cod_uni_funcio     LIKE usu_nivel_aut_cap.cod_uni_funcio,  
          p_ies_tip_autor      LIKE usu_nivel_aut_cap.ies_tip_autor,   
          p_cod_nivel_autor    LIKE usu_nivel_aut_cap.cod_nivel_autor, 
          p_cod_emp_usuario    LIKE usu_nivel_aut_cap.cod_emp_usuario, 
          p_emp_pend           LIKE usu_nivel_aut_cap.cod_empresa,
          p_cod_usuario        LIKE usuario_subs_cap.cod_usuario,
          p_num_linha_grade    LIKE aprov_necessaria.num_linha_grade,
          p_val_tot_nf         LIKE ad_mestre.val_tot_nf,
          p_dat_emis_nf        LIKE ad_mestre.dat_emis_nf,    
          p_dat_venc           LIKE ad_mestre.dat_venc,       
          p_cod_tip_despesa    LIKE tipo_despesa.cod_tip_despesa,
          p_ies_previsao       LIKE tipo_despesa.ies_previsao,   
          p_nom_tip_despesa    LIKE tipo_despesa.nom_tip_despesa,
          p_cod_grp_despesa    LIKE tipo_despesa.cod_grp_despesa,
          p_nom_grp_despesa    LIKE grupo_despesa.nom_grp_despesa,
          p_ad_empresa         LIKE empresa.cod_empresa,
          p_num_ad             CHAR(08),
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
          p_ies_incl_cap       CHAR(01),
          p_ies_suspensa       CHAR(01),
          p_ies_soma           CHAR(01)

   DEFINE pr_docum             RECORD
          nom_usuario          CHAR(08),
    	    nom_funcionario      CHAR(30),
          cod_nivel_autorid    CHAR(02),
          empresa              CHAR(02),
          estado               CHAR(02),
          cod_uni_funcio       CHAR(15),
          num_docum            CHAR(10),
          num_versao           INTEGER,
          tip_docum            CHAR(10),
          cod_fornecedor       CHAR(15),
          nom_fornecedor       CHAR(40),
          dat_docum            DATE,
          val_docum            DECIMAL(12,2),
          ies_suspensa         CHAR(01),
          dat_aprovacao        DATE,
          hor_aprovacao        CHAR(08),
          cod_tip_despesa      DECIMAL(4,0)
   END RECORD

   DEFINE pr_men               ARRAY[1] OF RECORD    
          mensagem             CHAR(60)
   END RECORD

   DEFINE p_docum              RECORD
      nom_usuario          CHAR(08),
      nom_funcionario      CHAR(30),
      cod_nivel_autorid    CHAR(02),
      empresa              CHAR(02),
      estado               CHAR(02),
      cod_uni_funcio       CHAR(15),
      num_docum            CHAR(10),
      num_versao           INTEGER,
      tip_docum            CHAR(10),
      cod_fornecedor       CHAR(15),
      nom_fornecedor       CHAR(40),
      dat_docum            DATE,
      val_docum            DECIMAL(12,2),
      ies_suspensa         CHAR(01),
      dat_aprovacao        DATE,
      hor_aprovacao        CHAR(08),
      cod_tip_despesa      DECIMAL(4,0)
   END RECORD   

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

   DEFINE pr_aprovant ARRAY[10] OF RECORD
      usuario             CHAR(08),    
      funcionario         CHAR(29),       
      nivel               CHAR(02),
      descricao           CHAR(25),
      hierarquia          DECIMAL(2,0),
      dat_aprov           DATE,
      hor_aprov           CHAR(08)
   END RECORD

   DEFINE pr_oc ARRAY[50] OF RECORD
      num_oc              INTEGER,       
      ies_situa_oc        CHAR(01),
      cod_item            CHAR(15),
      ies_estoque         CHAR(01),
      den_item        	  CHAR(18),
      cod_unid_med        CHAR(02),
      saldo_oc            DECIMAL(10,3),
      pre_unit_oc         DECIMAL(12,2)
   END RECORD

   DEFINE p_num_pedido      CHAR(10),
          p_ies_situa       CHAR(01),
          p_dat_emis        DATE,
          p_nom_comprador   CHAR(30),
          p_val_tot_ped     DECIMAL(10,2)

   DEFINE pr_ap ARRAY[50] OF RECORD
      num_ap              INTEGER,       
      num_parcela         INTEGER,
      val_nom_ap          DECIMAL(10,2),
      dat_vencto_s_desc	  DATE,
      cod_portador        CHAR(03),
      nom_portador        CHAR(30)
   END RECORD

   DEFINE p_num_ap            INTEGER,
          p_num_parcela       INTEGER,
          p_observ            CHAR(40),
          p_ies_usuario       SMALLINT

   DEFINE p_soma_empresa DEC(12,2),
          p_soma_docum   DEC(12,2),
          p_soma_user    DEC(12,2),
          p_soma_geral   DEC(12,2)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1166-10.02.10"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1166_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1166_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1166") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1166 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   CALL pol1166_limpa_tela()

   IF NOT pol1166_identif_user() THEN
      RETURN
   END IF

   IF NOT pol1166_cria_temp() THEN
      RETURN
   END IF

   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para listegem"
         IF pol1166_informar() THEN
            LET p_ies_cons = TRUE
            NEXT OPTION 'Listar'
         ELSE
            ERROR 'Operação cancelada!'
            LET p_ies_cons = FALSE
            NEXT OPTION 'Fim'
         END IF
      COMMAND "Listar" "Listagem dos documentos"
         IF p_ies_cons THEN
            CALL pol1166_listagem()
         ELSE
            ERROR 'Informe os parâmetros previamente!'
            NEXT OPTION 'Informar'
         END IF
         LET p_ies_cons = FALSE
         NEXT OPTION 'Fim'
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1166_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1166

END FUNCTION

#-----------------------#
 FUNCTION pol1166_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1166_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
END FUNCTION

#------------------------------#
FUNCTION pol1166_identif_user()#
#------------------------------#

   SELECT COUNT(nom_usuario)
     INTO p_count
     FROM usuario_adim_265
    WHERE nom_usuario = p_user
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','usuario_adim_265')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_ies_admin = TRUE
   ELSE
      LET p_ies_admin = FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
      
#---------------------------#
FUNCTION pol1166_cria_temp()
#---------------------------#

   DROP TABLE empresas_sel_265
   
   CREATE TEMP TABLE empresas_sel_265(
      cod_empresa   CHAR(02),
      ad_empresa    CHAR(02)
   )
   
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","EMPRESAS_SEL_265")
			RETURN FALSE
	 END IF

   DROP TABLE docum_tmp_265
   
   CREATE TEMP TABLE docum_tmp_265(
      nom_usuario          CHAR(08),
      nom_funcionario      CHAR(30),
      cod_nivel_autorid    CHAR(02),
      empresa              CHAR(02),
      estado               CHAR(02),
      cod_uni_funcio       CHAR(15),
      num_docum            CHAR(10),
      num_versao           INTEGER,
      tip_docum            CHAR(10),
      cod_fornecedor       CHAR(15),
      nom_fornecedor       CHAR(40),
      dat_docum            DATE,
      val_docum            DECIMAL(12,2),
      ies_suspensa         CHAR(01),
      dat_aprovacao        DATE,
      hor_aprovacao        CHAR(08),
      cod_tip_despesa      DECIMAL(4,0)
   )
   
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","DOCUM_TMP_265")
			RETURN FALSE
	 END IF

   DROP TABLE empresa_temp_265
   CREATE TEMP TABLE empresa_temp_265(
	    empresa        CHAR(02),
	    nivel_autorid  CHAR(02),
	    tip_docum       CHAR(02))

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","EMPRESA_TEMP_265")
			RETURN FALSE
	 END IF

   DROP TABLE nivel_temp_265
   CREATE TEMP TABLE nivel_temp_265(
     usuario         CHAR(08),
     empresa         CHAR(02), 
     nivel_autorid   CHAR(02), 
     tipo_autorid    CHAR(01), 
     den_nivel       CHAR(30),
     tip_docum       CHAR(02))   

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","NIVEL_TEMP_265")
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
			CALL log003_err_sql("CRIANDO","AD_APROV_TEMP_265")
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

#----------------------------------#
FUNCTION pol1166_carrega_usuarios()#
#----------------------------------#

   DROP TABLE usuarios_tmp_265
   
   CREATE TEMP TABLE usuarios_tmp_265(
      cod_usuario   CHAR(08)
   )
   
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","USUARIOS_TMP_265")
			RETURN FALSE
	 END IF
	 
	 INSERT INTO usuarios_tmp_265
	  SELECT DISTINCT cod_usuario FROM usu_nivel_aut_cap

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("INSERT","USUARIOS_TMP_265:1")
			RETURN FALSE
	 END IF
	 
	 INSERT INTO usuarios_tmp_265
	  SELECT DISTINCT NOM_usuario FROM usuario_nivel_aut

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("INSERT","USUARIOS_TMP_265:2")
			RETURN FALSE
	 END IF

	 INSERT INTO usuarios_tmp_265
	  SELECT DISTINCT NOM_usuario FROM nivel_usuario_265

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("INSERT","USUARIOS_TMP_265:3")
			RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1166_informar()#
#--------------------------#
   
   IF NOT p_ies_usuario THEN
      IF NOT pol1166_carrega_usuarios() THEN
         RETURN FALSE
      END IF
      LET p_ies_usuario = TRUE
   END IF
   
   INITIALIZE p_dat_ini, p_dat_fim TO NULL
   CALL pol1166_limpa_tela()
   
   LET p_ies_aprovacao = 'P'
   LET p_ies_aprovante = 'N'
   LET p_ies_detalhe = 'N'
   LET p_ies_sumarizar = 'N'
   LET p_ies_emresa = 'N'
   
   IF p_ies_admin THEN
      LET p_cod_usuario = NULL
   ELSE
      LET p_cod_usuario = p_user
      SELECT nom_funcionario
        INTO p_nom_funcionario
        FROM usuarios
       WHERE cod_usuario = p_cod_usuario
      IF STATUS <> 0 THEN
	       CALL log003_err_sql('Lendo','Usuarios')
	       LET p_nom_funcionario = NULL
      END IF
      DISPLAY p_nom_funcionario to nom_funcionario
   END IF
   
   LET INT_FLAG = FALSE
   
   INPUT p_ies_aprovacao,
         p_cod_usuario,
         p_ies_aprovante,
         p_ies_detalhe,
         p_ies_sumarizar,
         p_ies_emresa,
         p_dat_ini,
         p_dat_fim
      WITHOUT DEFAULTS 
        FROM ies_aprovacao,
             cod_usuario,
             ies_aprovante,
             ies_detalhe,
             ies_sumarizar,
             ies_empresa,
             dat_ini,
             dat_fim

	    BEFORE FIELD cod_usuario
	       IF NOT p_ies_admin THEN
	          NEXT FIELD ies_aprovante
	       END IF
	       LET p_nom_funcionario = NULL
	  
	    AFTER FIELD cod_usuario
	    
	       IF p_cod_usuario IS NOT NULL THEN
	          SELECT nom_funcionario
	            INTO p_nom_funcionario
	            FROM usuarios
	           WHERE cod_usuario = p_cod_usuario
	          IF STATUS <> 0 THEN
	             CALL log003_err_sql('Lendo','Usuarios')
	             NEXT FIELD cod_usuario
	          END IF
	       END IF   
	       
	       DISPLAY p_nom_funcionario TO nom_funcionario

      BEFORE FIELD ies_aprovante
         IF p_ies_aprovacao = 'A' THEN
            NEXT FIELD ies_sumarizar
         END IF

      BEFORE FIELD ies_detalhe
         IF p_ies_aprovacao = 'A' THEN
            NEXT FIELD ies_sumarizar
         END IF

      BEFORE FIELD dat_ini
         IF p_ies_aprovacao = 'P' THEN
            EXIT INPUT
         END IF

      ON KEY (control-z)
         CALL pol1166_popup()

      AFTER INPUT
         
        IF NOT INT_FLAG THEN
          IF p_ies_aprovacao = 'A' THEN
            IF p_dat_ini IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório.'
               NEXT FIELD dat_ini
            END IF
            IF p_dat_fim IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório.'
               NEXT FIELD dat_fim
            END IF
            IF p_dat_fim < p_dat_ini THEN
               ERROR 'A data final não pode ser menor que a data inicial.'
               NEXT FIELD dat_ini
            END IF
          END IF
        END IF
         	 
	 END INPUT
	 
	 IF INT_FLAG THEN
	    RETURN FALSE
	 END IF

   DELETE from empresas_sel_265
   
	 IF p_ies_emresa = 'S' THEN
	    IF NOT pol1166_sel_empresa() THEN
	       RETURN FALSE
	    END IF
	 ELSE
	    IF NOT pol1166_todas_empresa() THEN
	       RETURN FALSE
	    END IF
	 END IF
	 
	 RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1166_todas_empresa()#
#-------------------------------#
   
   DEFINE p_codemp CHAR(02)
   
   DECLARE cq_todas CURSOR FOR
    SELECT cod_empresa 
      FROM empresa
     ORDER BY cod_empresa
   
   FOREACH cq_todas INTO p_codemp
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','empresas_sel_265')
         RETURN FALSE
      END IF

      LET p_ad_empresa = pol166_ad_empresa(p_codemp)

      INSERT INTO empresas_sel_265
           VALUES(p_codemp, p_ad_empresa)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','empresas_sel_265')
         RETURN FALSE
      END IF

   END FOREACH
      
   RETURN TRUE

END FUNCTION   
      
#-----------------------------#
FUNCTION pol1166_sel_empresa()#
#-----------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1166a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1166ae AT 04,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_exibe_empresas() RETURNING p_status

   CLOSE WINDOW w_pol1166a
  
   RETURN p_status
   
END FUNCTION

#--------------------------------#
FUNCTION pol1158_exibe_empresas()#
#--------------------------------#

   DEFINE pr_empresa   ARRAY[100] OF RECORD
          ies_select   CHAR(01),
          cod_empresa  CHAR(02),
          den_empresa  CHAR(40)
   END RECORD
   
   LET p_index = 1
   
   DECLARE cq_sel_emp CURSOR FOR
    SELECT 'N', cod_empresa
           den_empresa
      FROM empresa
     ORDER BY cod_empresa

   FOREACH cq_sel_emp INTO pr_empresa[p_index].*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_sel_emp')
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 100 THEN
         LET p_msg = 'Quantidade de empresas maior que\n',
                     'quantidade de linhas da grade.\n',
                     'Algumas empresas não serão exibidas.'
         CALL log0030_mensagem(p_msg, 'INFO')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_empresa WITHOUT DEFAULTS FROM sr_empresa.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
      AFTER FIELD ies_select

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            IF pr_empresa[p_index+1].cod_empresa IS NULL THEN
               ERROR 'Não existe mais linhas nessa direção.'
               NEXT FIELD ies_select
            END IF
         END IF
      
   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_empresa[p_ind].ies_select = 'S' THEN
          LET p_ad_empresa = pol166_ad_empresa(pr_empresa[p_ind].cod_empresa)
          INSERT INTO empresas_sel_265
           VALUES(pr_empresa[p_ind].cod_empresa, p_ad_empresa)
          IF STATUS <> 0 THEN
             CALL log003_err_sql('INSERT','empresas_sel_265')
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol166_ad_empresa(p_empresa)#
#------------------------------------#
   
   DEFINE p_emp_ad  CHAR(02),
          p_empresa CHAR(02)

   SELECT cod_empresa_destin
     INTO p_emp_ad
     FROM emp_orig_destino
    WHERE cod_empresa_orig = p_empresa
   
   IF STATUS <> 0 THEN
      LET p_emp_ad = p_empresa
   END IF

   RETURN p_emp_ad

END FUNCTION
   
#-----------------------#
FUNCTION pol1166_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_usuario)
         CALL log009_popup(8,25,"USUARIOS","usuarios",
                     "cod_usuario","nom_funcionario","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1166
         IF p_codigo IS NOT NULL THEN
            LET p_cod_usuario = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_usuario
         END IF
	 
   END CASE
   
END FUNCTION
	  
#------------------------------#
FUNCTION pol1166_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE INPUT
         EXIT INPUT
         
   END INPUT

END FUNCTION

#--------------------------#
FUNCTION pol1166_listagem()#
#--------------------------#

   
   LET p_dat_atu = TODAY
   LET p_count = 0

   IF NOT pol1166_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   IF p_ies_aprovacao = 'P' THEN   
      CALL pol1166_escolhe_saida() RETURNING p_status
      CURRENT WINDOW IS w_pol1166
      IF NOT p_status THEN
      	 RETURN 
      END IF
      CALL pol1166_gera_pendentes()
      CALL pol1166_finaliza_relat()
   ELSE
      CALL pol1166_escolhe_impressao() RETURNING p_status
      CURRENT WINDOW IS w_pol1166
      IF NOT p_status THEN
      	 RETURN 
      END IF
      CALL pol1166_gera_aprovados() 
      CALL pol1166_finaliza_impressao()
   END IF

   LET pr_men[1].mensagem = 'Processamento concluido.'
   CALL pol1166_exib_mensagem()

END FUNCTION

#--------------------------------#
 FUNCTION pol1166_le_den_empresa()
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

#-------------------------------#
 FUNCTION pol1166_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1166_relat TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1166.tmp' 
         START REPORT pol1166_relat TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1166_relat TO p_nom_arquivo
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#---------------------------------#
 FUNCTION pol1166_finaliza_relat()#
#---------------------------------#

   FINISH REPORT pol1166_relat   
   
   IF p_count = 0 THEN
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

END FUNCTION

#--------------------------------#
FUNCTION pol1166_gera_pendentes()#
#--------------------------------#

   DELETE FROM docum_tmp_265
   DELETE FROM empresa_temp_265
   DELETE FROM nivel_temp_265
   DELETE FROM ad_aprov_temp_265
   DELETE FROM usu_niv_temp_265

   IF p_cod_usuario IS NULL THEN
      LET p_query = "SELECT DISTINCT cod_usuario FROM usuarios_tmp_265 ORDER BY cod_usuario"
   ELSE
      LET p_query = "SELECT DISTINCT cod_usuario FROM usuarios_tmp_265",
                    " WHERE cod_usuario = '",p_cod_usuario,"' ",
                    " ORDER BY cod_usuario "
   END IF
   
   PREPARE query_user FROM p_query   
   DECLARE cq_query_user CURSOR FOR query_user

   FOREACH cq_query_user INTO p_nom_usuario

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_query_user')
         RETURN 
      END IF
      
      CALL pol1166_le_usuario()

      IF NOT pol1166_le_doctos() THEN
         RETURN 
      END IF
      
   END FOREACH

   CALL pol1166_imp_pendentes()
   
END FUNCTION

#---------------------------#   
FUNCTION pol1166_le_doctos()#
#---------------------------#

   LET pr_men[1].mensagem = 'Lendo financeiro - usuário ',p_nom_usuario
   CALL pol1166_exib_mensagem()

   IF NOT pol1166_le_ad() THEN
      RETURN FALSE
   END IF

   LET p_cod_user = p_nom_usuario

   IF NOT pol1166_le_niv_autorid() THEN
      RETURN FALSE
   END IF

   SELECT COUNT(empresa)
     INTO p_count
     FROM nivel_temp_265

   IF p_count > 0 THEN
      IF NOT pol1166_le_empresas() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1166_le_ar('NOTA') THEN
      RETURN FALSE
   END IF

   IF NOT pol1166_le_ar('CONTRATO') THEN
      RETURN FALSE
   END IF

   IF NOT pol1166_le_pc() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1166_le_ad()#
#-----------------------#
   
   DELETE FROM ad_aprov_temp_265
   
   SELECT COUNT (*) 
     INTO p_count
     FROM usu_nivel_aut_cap 
    WHERE cod_usuario = p_nom_usuario

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
     WHERE cod_empresa IN (SELECT DISTINCT cod_empresa FROM par_cap_pad)
       AND cod_empresa IN (SELECT DISTINCT ad_empresa FROM empresas_sel_265)     #01/02/2013
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
          AND cod_usuario = p_nom_usuario
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
         
         IF NOT pol1166_ins_usu_niv('P') THEN
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
          AND cod_usuario_subs = p_nom_usuario 
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
       
            IF NOT pol1166_ins_usu_niv('S') THEN
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

      LET pr_men[1].mensagem = ' Aguarde... lendo financeiro - usuário: ',p_nom_usuario
      CALL pol1166_exib_mensagem()

      DECLARE cq_aprov_necess CURSOR FOR
       SELECT aprov_necessaria.num_ad,
              aprov_necessaria.num_versao,
              aprov_necessaria.num_linha_grade,
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
         p_num_linha_grade,
         p_cod_nivel_autor, 
         p_cod_uni_funcio

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_aprov_necess')
            RETURN FALSE
         END IF

         IF NOT pol1166_le_tip_desp() THEN
            RETURN FALSE
         END IF

         #IF p_dat_emis_nf < p_dat_ini OR p_dat_emis_nf > p_dat_fim THEN
         #   CONTINUE FOREACH
         #END IF
            
         IF p_ies_previsao = 'P' THEN
            CONTINUE FOREACH
         END IF

         IF NOT pol1166_ins_ad_docum() THEN
            RETURN FALSE
         END IF
         
      END FOREACH #cq_aprov_necess

      DECLARE cq_aprov_hierarq CURSOR FOR
       SELECT aprov.num_ad,
              aprov.num_versao,
              aprov.num_linha_grade,
              aprov.cod_nivel_autor,
              aprov.cod_uni_funcio
         FROM aprov_necessaria aprov 
        WHERE aprov.cod_empresa = p_emp_pend
          AND aprov.ies_aprovado = 'N' 
          AND aprov.num_ad IS NOT NULL 
          AND aprov.cod_nivel_autor IS NOT NULL 
          AND EXISTS 
              (SELECT DISTINCT tmp.cod_emp_usuario
                 FROM usu_niv_temp_265 tmp
                WHERE tmp.cod_emp_usuario = aprov.cod_empresa
                  AND tmp.cod_uni_funcional = aprov.cod_uni_funcio
                  AND tmp.cod_nivel_autor = aprov.cod_nivel_autor
                  AND tmp.ies_tip_autor = 'H')
        ORDER BY aprov.cod_empresa, aprov.num_ad, aprov.cod_nivel_autor
          
      FOREACH cq_aprov_hierarq INTO
         p_num_ad, 
         p_num_versao, 
         p_num_linha_grade,
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
         
         IF NOT pol1166_le_tip_desp() THEN
            RETURN FALSE
         END IF

         #IF p_dat_emis_nf < p_dat_ini OR p_dat_emis_nf > p_dat_fim THEN
         #   CONTINUE FOREACH
         #END IF
            
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
            IF NOT pol1166_ins_ad_docum() THEN
               RETURN FALSE
            END IF
         END IF
      
      END FOREACH #cq_aprov_hierarq
      
      
   END FOREACH #cq_emp_pend

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1166_ins_usu_niv(p_subst)#
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
FUNCTION pol1166_le_tip_desp()#
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
      CALL log003_err_sql('Lendo','ad_mestre')           
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
      LET p_ies_previsao = 'N'                          
   END IF                                                

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1166_ins_ad_docum()#
#------------------------------#

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
         
   LET pr_docum.empresa =    p_emp_pend
   LET pr_docum.num_docum =  p_num_ad
   LET pr_docum.val_docum =  p_val_tot_nf
   LET pr_docum.dat_docum =  p_dat_emis_nf
   LET pr_docum.ies_suspensa = p_ies_suspensa
   LET pr_docum.cod_nivel_autorid = p_cod_nivel_autor
   LET pr_docum.cod_uni_funcio = p_cod_uni_funcio
   LET pr_docum.nom_usuario = p_nom_usuario
   LET pr_docum.nom_funcionario = p_nom_funcionario
   LET pr_docum.num_versao = ''
   LET pr_docum.tip_docum = 'FINANCEIRO'

   CALL pol1166_le_estado()
      
   SELECT cod_fornecedor
     INTO pr_docum.cod_fornecedor
     FROM ad_mestre
    WHERE cod_empresa = pr_docum.empresa
      AND num_ad      = pr_docum.num_docum
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','AD_MESTRE:CQ_AD')
      RETURN FALSE
   END IF

   CALL pol1166_le_nome_for()

   IF NOT pol1166_ins_docum() THEN
      RETURN FALSE
   END IF
                                                            
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1166_le_usuario()#
#----------------------------#

   SELECT nom_funcionario
     INTO p_nom_funcionario
     FROM usuarios
    WHERE cod_usuario = p_nom_usuario
   
   IF STATUS <> 0 THEN
	    #CALL log003_err_sql('Lendo','Usuarios')
	    LET p_nom_funcionario = NULL
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1166_le_estado()
#--------------------------#

   SELECT uni_feder
     INTO pr_docum.estado
     FROM empresa
    WHERE cod_empresa = pr_docum.empresa
   
   IF STATUS <> 0 THEN
      LET pr_docum.estado = ''
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1166_le_nome_for()#
#-----------------------------#

   SELECT raz_social
     INTO pr_docum.nom_fornecedor
     FROM fornecedor
    WHERE cod_fornecedor = pr_docum.cod_fornecedor

   IF STATUS <> 0 THEN
      LET pr_docum.nom_fornecedor = ''
   END IF

END FUNCTION   

#--------------------------------#
FUNCTION pol1166_le_niv_autorid()#
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
     WHERE a.cod_empresa = p_cod_empresa
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
     WHERE a.cod_empresa = p_cod_empresa
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
         AND usuario = p_cod_user
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'nivel_temp_265:cq_niv_aut')
         RETURN FALSE
      END IF
      
      IF p_count = 0 THEN

         INSERT INTO nivel_temp_265
          VALUES(p_cod_user, p_empresa, p_nivel, p_tipo, p_den_nivel, p_tp_docum)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo', 'nivel_temp_265:cq_niv_aut')
            RETURN FALSE
         END IF

      END IF
   
   END FOREACH       

   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1166_le_empresas()
#-----------------------------#

   DELETE FROM empresa_temp_265

   DECLARE cq_filiais CURSOR FOR
    SELECT DISTINCT 
           cod_empresa_filial, 
           cod_nivel_autorid 
      FROM usuar_aprov_filial 
     WHERE cod_empresa = p_cod_empresa 
       AND nom_usuario = p_cod_user 
       AND cod_nivel_autorid IN 
           (SELECT nivel_autorid 
              FROM nivel_temp_265 WHERE tip_docum = 'PC')
   
   FOREACH cq_filiais INTO p_empresa, p_nivel

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'usuar_aprov_filial:cq_filiais')
         RETURN FALSE
      END IF
      
      INSERT INTO empresa_temp_265
       VALUES(p_empresa, p_nivel, 'PC')

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo', 'empresa_temp_265:cq_filiais')
         RETURN FALSE
      END IF
   
   END FOREACH       

   DECLARE cq_le_niv CURSOR FOR
    SELECT empresa, 
           nivel_autorid
      FROM nivel_temp_265
     WHERE tip_docum = 'PC' 

   FOREACH cq_le_niv INTO p_empresa, p_nivel

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'nivel_temp_265:cq_le_niv')
         RETURN FALSE
      END IF
      
      SELECT empresa
        FROM empresa_temp_265
       WHERE empresa = p_empresa
         AND nivel_autorid = p_nivel
      
      IF STATUS = 100 THEN
         INSERT INTO empresa_temp_265
          VALUES(p_empresa, p_nivel, 'PC')

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo', 'empresa_temp_265:cq_le_niv')
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'empresa_temp_265:cq_le_niv')
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH       

   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1166_le_ar(p_docum)#
#------------------------------#

   DEFINE p_docum CHAR(10)

   LET pr_men[1].mensagem = 'Lendo notas - usuário ',p_nom_usuario
   CALL pol1166_exib_mensagem()
   
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
       AND d.empresa IN (SELECT cod_empresa FROM empresas_sel_265) #01/02/2013
       AND (a.nom_usuario_aprov IS NULL   OR a.nom_usuario_aprov = " ")       
       AND b.cod_empresa   = a.cod_empresa
       AND b.ies_incl_cap  = 'X'
       AND b.num_aviso_rec = a.num_aviso_rec
       AND c.cod_empresa   = b.cod_empresa
       AND c.num_aviso_rec = b.num_aviso_rec
       AND c.ies_ar_cs     = p_docum
       #AND b.dat_entrada_nf >= p_dat_ini
       #AND b.dat_entrada_nf <= p_dat_fim
     ORDER BY b.cod_empresa, b.num_aviso_rec

   FOREACH cq_le_nf INTO      
           pr_docum.empresa, 
           pr_docum.num_docum, 
           pr_docum.dat_docum,     
           pr_docum.cod_fornecedor,
           pr_docum.val_docum,
           pr_docum.cod_nivel_autorid
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'cursor cq_le_nf')
         RETURN FALSE
      END IF
      
      CALL pol1166_le_estado()
      
      SELECT hierarquia
        INTO p_hieraq_user
        FROM nivel_hierarq_265
       WHERE empresa = pr_docum.empresa
         AND nivel_autoridade = pr_docum.cod_nivel_autorid

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'nivel_hierarq_265:cq_le_nf')
         RETURN FALSE
      END IF
      
      SELECT MAX(a.hierarquia)
        INTO p_hierarquia
        FROM nivel_hierarq_265 a,
             aprov_ar_265 b
       WHERE a.empresa = pr_docum.empresa
         AND b.cod_empresa = a.empresa
         AND b.num_aviso_rec = pr_docum.num_docum
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

      LET pr_docum.nom_usuario = p_nom_usuario
      LET pr_docum.nom_funcionario = p_nom_funcionario
      LET pr_docum.num_versao = ''
      LET pr_docum.tip_docum = p_docum

      CALL pol1166_le_nome_for()

      IF NOT pol1166_ins_docum() THEN
         RETURN FALSE
      END IF
       
   END FOREACH

   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1166_le_pc()#
#-----------------------#

   LET pr_men[1].mensagem = 'Lendo pedidos - usuário ',p_nom_usuario
   CALL pol1166_exib_mensagem()

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
      FROM aprov_ped_sup a, pedido_sup b
     WHERE a.cod_empresa IN (SELECT DISTINCT empresa FROM empresa_temp_265)
       AND a.cod_nivel_autorid IN (SELECT DISTINCT nivel_autorid FROM empresa_temp_265 ) 
       AND (a.nom_usuario_aprov IS NULL   OR a.nom_usuario_aprov = " ")  
       AND b.cod_empresa      = a.cod_empresa
       AND b.ies_versao_atual = "S"
       AND b.ies_situa_ped    = "A"
       AND b.num_pedido       = a.num_pedido
       AND b.num_versao       = a.num_versao_pedido
       AND b.cod_empresa IN (SELECT cod_empresa FROM empresas_sel_265) #01/02/2013
     ORDER BY b.cod_empresa, b.num_pedido
   
   FOREACH cq_le_pc INTO      
           pr_docum.empresa, 
           pr_docum.num_docum, 
           pr_docum.num_versao, 
           pr_docum.dat_docum,     
           pr_docum.cod_fornecedor,
           pr_docum.val_docum,
           pr_docum.cod_nivel_autorid
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'cursor cq_le_pc')
         RETURN FALSE
      END IF
      
      CALL pol1166_le_estado()
      
      SELECT hierarquia
        INTO p_hieraq_user
        FROM sup_niv_autorid_complementar
       WHERE empresa = pr_docum.empresa
         AND nivel_autoridade = pr_docum.cod_nivel_autorid

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'sup_niv_autorid_complementar:cq_le_pc')
         RETURN FALSE
      END IF
      
      SELECT max(a.hierarquia)
        INTO p_hierarquia
        FROM sup_niv_autorid_complementar a,
             aprov_ped_sup b
       WHERE a.empresa = pr_docum.empresa
         AND b.cod_empresa = a.empresa
         AND b.cod_nivel_autorid = a.nivel_autoridade 
         AND b.num_pedido = pr_docum.num_docum
         AND b.num_versao_pedido = pr_docum.num_versao
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

      LET pr_docum.nom_usuario = p_nom_usuario
      LET pr_docum.nom_funcionario = p_nom_funcionario
      LET pr_docum.tip_docum = 'COMPRAS'

      CALL pol1166_le_nome_for()

      IF NOT pol1166_ins_docum() THEN
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1166_ins_docum()#
#---------------------------#

   INSERT INTO docum_tmp_265
    VALUES(pr_docum.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','DOCUM_TMP_265:CQ_AD')
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol1166_imp_pendentes()#
#-------------------------------#

   DEFINE p_qtd_docum INTEGER

   LET p_soma_empresa = 0
   LET p_soma_docum = 0
   LET p_soma_user = 0
   LET p_soma_geral = 0
   
   SELECT COUNT(num_docum)
      INTO p_qtd_docum
      FROM docum_tmp_265

   IF STATUS <> 0 THEN
      LET p_qtd_docum = 0
   END IF

   LET pr_men[1].mensagem = 'Documentos a imprimir: ', p_qtd_docum
   CALL pol1166_exib_mensagem()

   DECLARE cq_pend CURSOR FOR
    SELECT *
      FROM docum_tmp_265
     ORDER BY nom_usuario, tip_docum, empresa
   
   FOREACH cq_pend INTO p_docum.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'CQ_PEND')
         RETURN
      END IF 

      LET p_qtd_docum = p_qtd_docum - 1
      LET p_count = p_count + 1

      IF p_count = 100 THEN
         LET pr_men[1].mensagem = 'Documentos a imprimir: ', p_qtd_docum
         CALL pol1166_exib_mensagem()
         LET p_count = 1
      END IF

      IF p_ies_detalhe = 'S' THEN
         CASE p_docum.tip_docum
            WHEN 'NOTA'       CALL pol1166_dados_ar()
            WHEN 'CONTRATO'   CALL pol1166_dados_ar()
            WHEN 'COMPRAS'    CALL pol1166_dados_pc()
            WHEN 'FINANCEIRO' CALL pol1166_dados_ad()
         END CASE
      END IF

      IF p_ies_aprovante = 'S' THEN
         CASE p_docum.tip_docum
            WHEN 'NOTA'       CALL pol1166_aprov_ar()
            WHEN 'CONTRATO'   CALL pol1166_aprov_ar()
            WHEN 'COMPRAS'    CALL pol1166_aprov_pc()
            WHEN 'FINANCEIRO' CALL pol1166_aprov_ad()
         END CASE
      END IF
      
      OUTPUT TO REPORT pol1166_relat(p_docum.nom_usuario, p_docum.tip_docum, p_docum.empresa) 

   END FOREACH

   LET pr_men[1].mensagem = 'Impressão concluída.'
   CALL pol1166_exib_mensagem()

   RETURN TRUE

END FUNCTION

#-----------------------------------------------------------#
 REPORT pol1166_relat(p_nom_usuario, p_tip_docum, p_empresa)#
#-----------------------------------------------------------#

   DEFINE p_empresa      CHAR(02), 
          p_tip_docum    CHAR(10),
          p_nom_usuario  CHAR(08),
          p_linha        CHAR(100),
          p_den_tot_emp  CHAR(30),
          p_den_tot_doc  CHAR(16),
          p_den_tot_user CHAR(14)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   #ORDER EXTERNAL BY p_empresa, p_tip_docum, p_nom_usuario
   
   FORMAT

      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 043, "PENDENCIAS DE APROVACAO",
               COLUMN 071, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " ", TIME
               
         PRINT COLUMN 001, "POL1166.4GL",
               COLUMN 025, p_nom_usuario CLIPPED, ' - ', p_docum.nom_funcionario,
               COLUMN 090, "PAG. ", PAGENO USING "&&&&"
         PRINT COLUMN 001, "--------------------------------------------------------------------------------------------------"

         PRINT
         PRINT COLUMN 001, 'EMP UF DOCUMENTO  VER TIPO          DATA       VALOR                  FORNECEDOR'
         PRINT COLUMN 001, '--- -- ---------- --- ---------- ---------- ------------- ----------------------------------------'

      PAGE HEADER  
         PRINT COLUMN 001, "POL1166.4GL",
               COLUMN 025, p_nom_usuario CLIPPED, ' - ', p_docum.nom_funcionario,
               COLUMN 090, "PAG. ", PAGENO USING "&&&&"
         PRINT COLUMN 001, "--------------------------------------------------------------------------------------------------"

         PRINT
         PRINT COLUMN 001, 'EMP UF DOCUMENTO  VER TIPO          DATA       VALOR                  FORNECEDOR'
         PRINT COLUMN 001, '--- -- ---------- --- ---------- ---------- ------------- ----------------------------------------'

      BEFORE GROUP OF p_nom_usuario
      
         SKIP TO TOP OF PAGE

      BEFORE GROUP OF p_tip_docum
      
         SKIP TO TOP OF PAGE

      ON EVERY ROW
      
         PRINT COLUMN 002, p_docum.empresa,
               COLUMN 005, p_docum.estado,
               COLUMN 008, p_docum.num_docum,
               COLUMN 019, p_docum.num_versao USING '###',
               COLUMN 023, p_docum.tip_docum,
               COLUMN 034, p_docum.dat_docum,
               COLUMN 045, p_docum.val_docum USING '##,###,##&.&&',
               COLUMN 059, p_docum.nom_fornecedor
         
         IF p_ies_detalhe = 'S' THEN
            IF p_docum.tip_docum = 'NOTA' OR p_docum.tip_docum = 'CONTRATO' THEN
               PRINT
               LET p_linha = 
                     'Num NF:', p_num_nf CLIPPED, '   Tipo:', p_especie CLIPPED, 
                     '   Ser:', p_ser_nf CLIPPED, '   Sub ser:', p_ssr_nf CLIPPED,
                     ' Emissao:', p_dat_emis_nf, '   Valor:', p_val_tot_nf USING '<,<<<,<<<,<<&.&&'
               PRINT COLUMN 005, p_linha
               IF p_ies_ar_cs = 'CONTRATO' THEN
                  LET p_linha = 'Contrato: ', p_contrato USING '<<<<<<<<', '   Sit: ', p_sit_contrato,
                        '   Ver: ', p_ver_cont USING '<<', '   Servico: ', p_servico CLIPPED
                  PRINT COLUMN 005, p_linha
                  PRINT
               ELSE  
                  PRINT
               END IF
               
               PRINT COLUMN 005, 'SEQ      ITEM            DESCRICAO     UND QUANTIDADE     PRECO     VAL IQUIDO  USUARIO'
               PRINT COLUMN 005, '--- --------------- ------------------ --- ---------- ------------ ------------ --------'
               FOR p_ind = 1 TO p_qtd_lin 
                   PRINT COLUMN 005, pr_ar[p_ind].num_seq USING '###',         
                         COLUMN 009, pr_ar[p_ind].cod_item,        
                         COLUMN 025, pr_ar[p_ind].den_item,        
                         COLUMN 044, pr_ar[p_ind].cod_unid_med,    
                         COLUMN 048, pr_ar[p_ind].qtd_recebida USING '######&.&&',
                         COLUMN 059, pr_ar[p_ind].pre_unit_nf USING '#,###,##&.&&',
                         COLUMN 072, pr_ar[p_ind].val_liquido_item USING '#,###,##&.&&',
                         COLUMN 085, pr_ar[p_ind].nom_usuario     
               END FOR
               PRINT                   
            ELSE      
               IF p_docum.tip_docum = 'COMPRAS' THEN   
                  PRINT
                  LET p_linha = 'Pedido: ', p_num_pedido CLIPPED, '   Sit: ', p_ies_situa,
                      '   Comprador: ', p_cod_comprador CLIPPED, ' - ', p_nom_comprador
                  PRINT COLUMN 005, p_linha
                  PRINT
                  PRINT COLUMN 005, 'NUM OC   SIT      ITEM           DESCRICAO      UND   SDO OC    PRECO UNIT'
                  PRINT COLUMN 005, '-------- --- --------------- ------------------ --- ---------- ------------'

                  FOR p_ind = 1 TO p_qtd_lin 
                   PRINT COLUMN 005, pr_oc[p_ind].num_oc USING '########',
                         COLUMN 015, pr_oc[p_ind].ies_situa_oc, 
                         COLUMN 018, pr_oc[p_ind].cod_item,     
                         COLUMN 034, pr_oc[p_ind].den_item,     
                         COLUMN 053, pr_oc[p_ind].cod_unid_med, 
                         COLUMN 057, pr_oc[p_ind].saldo_oc USING '######&.&&',     
                         COLUMN 068, pr_oc[p_ind].pre_unit_oc USING '#,###,##&.&&'
                  END FOR
                  PRINT                   
               ELSE   
                  PRINT
                  LET p_linha = 'AD: ', p_num_ad CLIPPED, '   Num NF:', p_num_nf CLIPPED,
                     '   Ser:', p_ser_nf CLIPPED, '   Sub ser:', p_ssr_nf CLIPPED,
                     '   Tip despesa: ', p_cod_tip_despesa, ' - ', p_nom_tip_despesa
                  PRINT COLUMN 005, p_linha
                  PRINT
                  PRINT COLUMN 005, 'NUM AP   PARCELA   VALOR AP     VENCTO   PORTADOR DESCRICAO'
                  PRINT COLUMN 005, '-------- ------- ------------ ---------- -------- ------------------------------'
                  FOR p_ind = 1 TO p_qtd_lin 
                   PRINT COLUMN 005, pr_ap[p_ind].num_ap USING '########',         
                         COLUMN 017, pr_ap[p_ind].num_parcela USING '###',      
                         COLUMN 022, pr_ap[p_ind].val_nom_ap  USING '#,###,##&.&&',   
                         COLUMN 035, pr_ap[p_ind].dat_vencto_s_desc,
                         COLUMN 046, pr_ap[p_ind].cod_portador,     
                         COLUMN 055, pr_ap[p_ind].nom_portador   
                  END FOR
                  PRINT                   
               END IF
            END IF
         ELSE
            LET p_status = TRUE
         END IF

         IF p_ies_aprovante = 'S' THEN
            IF p_docum.tip_docum = 'NOTA' OR p_docum.tip_docum = 'CONTRATO' THEN
               PRINT COLUMN 005, '  NUM AR   NIV DESCRICAO                 USUARIO  DATA APROV HORA APROV'
               PRINT COLUMN 005, '---------- --- ------------------------- -------- ---------- ----------'
               FOR p_ind = 1 TO p_qtd_aprov
                   PRINT COLUMN 005, p_docum.num_docum,
                         COLUMN 017, pr_aprovant[p_ind].nivel,      
                         COLUMN 020, pr_aprovant[p_ind].descricao,  
                         COLUMN 046, pr_aprovant[p_ind].usuario,
                         COLUMN 055, pr_aprovant[p_ind].dat_aprov,  
                         COLUMN 066, pr_aprovant[p_ind].hor_aprov  
               END FOR
               PRINT                   
            ELSE
               IF p_docum.tip_docum = 'COMPRAS' THEN
                  PRINT COLUMN 005, 'NUM PEDIDO NIV DESCRICAO                 USUARIO  DATA APROV HORA APROV'
                  PRINT COLUMN 005, '---------- --- ------------------------- -------- ---------- ----------'
                  FOR p_ind = 1 TO p_qtd_aprov
                   PRINT COLUMN 005, p_docum.num_docum,
                         COLUMN 017, pr_aprovant[p_ind].nivel,      
                         COLUMN 020, pr_aprovant[p_ind].descricao,  
                         COLUMN 046, pr_aprovant[p_ind].usuario, 
                         COLUMN 055, pr_aprovant[p_ind].dat_aprov,  
                         COLUMN 066, pr_aprovant[p_ind].hor_aprov  
                  END FOR
                  PRINT                   
               ELSE
                  PRINT COLUMN 005, 'NUM AD     NIV DESCRICAO                 USUARIO  DATA APROV HORA APROV'
                  PRINT COLUMN 005, '---------- --- ------------------------- -------- ---------- ----------'
                  FOR p_ind = 1 TO p_qtd_aprov
                   PRINT COLUMN 005, p_docum.num_docum,
                         COLUMN 017, pr_aprovant[p_ind].nivel,      
                         COLUMN 020, pr_aprovant[p_ind].descricao,  
                         COLUMN 046, pr_aprovant[p_ind].usuario,
                         COLUMN 055, pr_aprovant[p_ind].dat_aprov,  
                         COLUMN 066, pr_aprovant[p_ind].hor_aprov  
                  END FOR
                  PRINT                   
               END IF
            END IF
         ELSE      
            LET p_status = TRUE
         END IF

      AFTER GROUP OF p_empresa
          
         IF p_ies_sumarizar = 'S' THEN
            LET p_soma_empresa = GROUP SUM(p_docum.val_docum)
            LET p_den_tot_emp = 'TOTAL EMPRESA ', p_empresa, ' - ', p_tip_docum
            PRINT COLUMN 042, '----------------'
            PRINT COLUMN 012, p_den_tot_emp,
                  COLUMN 042, p_soma_empresa USING '#,###,###,##&.&&'
            PRINT
            LET p_soma_docum = p_soma_docum + p_soma_empresa
         END IF
         
      AFTER GROUP OF p_tip_docum

         IF p_ies_sumarizar = 'S' THEN
            LET p_den_tot_doc = 'TOTAL ', p_tip_docum
            PRINT #COLUMN 042, '----------------'
            PRINT COLUMN 025, p_den_tot_doc,
                  COLUMN 042, p_soma_docum USING '#,###,###,##&.&&'
            PRINT
            LET p_soma_user = p_soma_user + p_soma_docum
            LET p_soma_docum = 0
         END IF

      AFTER GROUP OF p_nom_usuario

         IF p_ies_sumarizar = 'S' THEN
            LET p_den_tot_user = 'TOTAL ', p_nom_usuario
            PRINT #COLUMN 042, '----------------'
            PRINT COLUMN 027, p_den_tot_user,
                  COLUMN 042, p_soma_user USING '#,###,###,##&.&&'
            PRINT
            LET p_soma_geral = p_soma_geral + p_soma_user
            LET p_soma_user = 0
         END IF
         
      ON LAST ROW

         IF p_ies_sumarizar = 'S' THEN
            PRINT #COLUMN 066, '----------------'
            PRINT COLUMN 030, 'TOTAL GERAL',
                  COLUMN 042, p_soma_geral USING '#,###,###,##&.&&'
         END IF

         LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF

END REPORT

#--------------------------#
FUNCTION pol1166_dados_ar()#
#--------------------------# 

   INITIALIZE pr_ar TO NULL
   
   IF NOT pol1166_le_nf_sup() THEN
      RETURN 
   END IF
   
   IF p_ies_ar_cs = 'CONTRATO' THEN
      LET p_ar = p_docum.num_docum
      CALL pol1166_obtem_contrato()
   END IF
  
   LET p_index = 1
   
   DECLARE cq_le_ars CURSOR FOR
    SELECT a.num_seq,        
           a.cod_item,       
           b.den_item_reduz,       
           b.cod_unid_med,   
           a.qtd_recebida,   
           a.pre_unit_nf,    
           a.val_liquido_item
      FROM aviso_rec a, item b
     WHERE a.cod_empresa   = p_docum.empresa
       AND a.num_aviso_rec = p_docum.num_docum
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
       WHERE cod_empresa = p_docum.empresa
         AND num_aviso_rec = p_docum.num_docum
         AND num_seq = pr_ar[p_index].num_seq
         AND ies_tipo_auditoria = 1
      
      IF STATUS <> 0 THEN
         LET pr_ar[p_index].num_seq = ''
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 50 THEN
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET p_qtd_lin = p_index - 1
               
END FUNCTION

#---------------------------#
FUNCTION pol1166_le_nf_sup()#
#---------------------------#

   SELECT a.num_nf,
          a.ser_nf,
          a.ssr_nf,
          a.dat_emis_nf,   
          a.val_tot_nf_d,    
          a.ies_especie_nf,
          a.cod_fornecedor,
          b.raz_social
     INTO p_num_nf,     
          p_ser_nf,  
          p_ssr_nf, 
          p_dat_emis_nf,   
          p_val_tot_nf,    
          p_especie,
          p_cod_fornecedor,
          p_raz_social    
     FROM nf_sup a,
          fornecedor b
    WHERE a.cod_empresa   = p_docum.empresa
      AND a.num_aviso_rec = p_docum.num_docum
      AND a.cod_fornecedor = b.cod_fornecedor

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','nf_sup e fornecedor')
      RETURN FALSE
   END IF
   
   SELECT ies_ar_cs
     INTO p_ies_ar_cs
     FROM nfe_aprov_265
    WHERE cod_empresa   = p_docum.empresa  
      AND num_aviso_rec = p_docum.num_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','nfe_aprov_265')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   
   
#--------------------------------#
FUNCTION pol1166_obtem_contrato()#
#--------------------------------#
   
   LET p_nao_achou = TRUE   
   
   DECLARE cq_cs CURSOR FOR
    SELECT contrato_servico, 
           versao_contrato,
           parcela,
           dat_vencto,
           val_pagar
      FROM cos_pagto_etapa 
     WHERE empresa = p_docum.empresa
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
      INITIALIZE p_contrato, p_ver_cont, 
         p_txt_cont, p_servico, p_sit_contrato TO NULL
      RETURN 
   END IF
   
   SELECT objeto_contrato,
          servico,
          sit_contrato
     INTO p_txt_cont,
          p_servico,
          p_sit_contrato
     FROM cos_contr_servico
    WHERE empresa = p_docum.empresa
      AND filial = 0
      AND contrato_servico = p_contrato
      AND versao_contrato = p_ver_cont

   IF STATUS <> 0 THEN
      INITIALIZE p_txt_cont, p_servico, p_sit_contrato TO NULL
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1166_aprov_ar()#
#--------------------------#

   LET p_index = 1
   
   DECLARE cq_aprov_ar CURSOR FOR
    SELECT nom_usuario_aprov,
           cod_nivel_autorid,
           hierarquia,
           dat_aprovacao,
           hor_aprovacao
      FROM aprov_ar_265
     WHERE cod_empresa = p_docum.empresa
       AND num_aviso_rec = p_docum.num_docum
     ORDER BY hierarquia DESC
   
   FOREACH cq_aprov_ar INTO
      pr_aprovant[p_index].usuario,
      pr_aprovant[p_index].nivel,
      pr_aprovant[p_index].hierarquia,
      pr_aprovant[p_index].dat_aprov,
      pr_aprovant[p_index].hor_aprov
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_APROV_AR')
         RETURN
      END IF
      
      SELECT den_nivel_autorid
        INTO pr_aprovant[p_index].descricao
        FROM nivel_autorid_265
       WHERE cod_empresa = p_docum.empresa
         AND cod_nivel_autorid = pr_aprovant[p_index].nivel
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','NIVEL_AUTORID_265')
         LET pr_aprovant[p_index].descricao = ''
      END IF

      LET p_index = p_index + 1

   END FOREACH
   
   LET p_qtd_aprov = p_index - 1

END FUNCTION

#--------------------------#
FUNCTION pol1166_dados_pc()#
#--------------------------# 

   IF NOT pol1166_le_pedido_sup() THEN
      RETURN
   END IF

   LET p_index = 1
   
   DECLARE cq_le_ocs CURSOR FOR
    SELECT a.num_oc,
           a.ies_situa_oc,        
           a.cod_item,  
           a.ies_item_estoq,     
           b.den_item,       
           b.cod_unid_med,   
           (a.qtd_solic - a.qtd_recebida),   
           a.pre_unit_oc   
      FROM ordem_sup a, item b
     WHERE a.cod_empresa   = p_docum.empresa
       AND a.num_pedido    = p_docum.num_docum
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
      
      IF p_index > 50 THEN
         CALL log0030_mensagem('Limite de linhas esgotado','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET p_qtd_lin = p_index - 1

END FUNCTION

#-------------------------------#
FUNCTION pol1166_le_pedido_sup()#
#-------------------------------#

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
    WHERE a.cod_empresa   = p_docum.empresa
      AND a.num_pedido    = p_docum.num_docum
      AND a.num_versao    = p_docum.num_versao
      AND a.cod_fornecedor = b.cod_fornecedor
      AND a.cod_empresa    = c.cod_empresa
      AND a.cod_comprador  = c.cod_comprador

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','pedido_sup/fornecedor/comprador')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1166_aprov_pc()#
#--------------------------# 
   
   LET p_index = 1
   
   DECLARE cq_aprov_pc CURSOR FOR
    SELECT a.nom_usuario_aprov,
           a.cod_nivel_autorid,
           a.dat_aprovacao,
           a.hor_aprovacao,
           b.hierarquia
     FROM aprov_ped_sup a,
          sup_niv_autorid_complementar b
    WHERE a.cod_empresa = p_docum.empresa
      AND a.num_pedido  = p_docum.num_docum
      AND a.num_versao_pedido = p_docum.num_versao
      AND b.empresa = a.cod_empresa
      AND b.nivel_autoridade = a.cod_nivel_autorid
    ORDER BY b.hierarquia DESC

   FOREACH cq_aprov_pc INTO
           pr_aprovant[p_index].usuario,
           pr_aprovant[p_index].nivel,
           pr_aprovant[p_index].dat_aprov,
           pr_aprovant[p_index].hor_aprov,
           pr_aprovant[p_index].hierarquia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_APROV_PC')
         RETURN
      END IF
      
      SELECT den_nivel_autorid
        INTO pr_aprovant[p_index].descricao
        FROM nivel_autoridade
       WHERE cod_empresa = p_docum.empresa
         AND cod_nivel_autorid = pr_aprovant[p_index].nivel
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','NIVEL_AUTORIDADE')
         LET pr_aprovant[p_index].descricao = ''
      END IF

      LET p_index = p_index + 1

   END FOREACH
   
   LET p_qtd_aprov = p_index - 1

END FUNCTION

#--------------------------#
FUNCTION pol1166_dados_ad()#
#--------------------------# 

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
    WHERE a.cod_empresa   = p_docum.empresa
      AND a.num_ad        = p_docum.num_docum
      AND a.cod_fornecedor = b.cod_fornecedor
      AND c.cod_empresa = a.cod_empresa
      AND c.cod_tip_despesa = a.cod_tip_despesa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ad_mestre/fornecedor')
      RETURN
   END IF
   
   LET p_index = 1
   
   DECLARE cq_le_aps CURSOR FOR
    SELECT num_ap
      FROM ad_ap
     WHERE cod_empresa = p_docum.empresa
       AND num_ad      = p_docum.num_docum
   
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
       WHERE cod_empresa = p_docum.empresa
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
   
   LET p_qtd_lin = p_index - 1   

END FUNCTION

#--------------------------#
FUNCTION pol1166_aprov_ad()#
#--------------------------# 

   LET p_index = 1
   
   DECLARE cq_aprov_ad CURSOR FOR
    SELECT cod_usuario_aprov,
           cod_nivel_autor,
           dat_aprovacao,
           hor_aprovacao
     FROM aprov_necessaria 
    WHERE cod_empresa = p_docum.empresa
      AND num_ad = p_docum.num_docum
    ORDER BY cod_nivel_autor

   FOREACH cq_aprov_ad INTO
           pr_aprovant[p_index].usuario,
           pr_aprovant[p_index].nivel,
           pr_aprovant[p_index].dat_aprov,
           pr_aprovant[p_index].hor_aprov
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_APROV_AD')
         RETURN
      END IF

      LET pr_aprovant[p_index].hierarquia = ''
      
      SELECT den_nivel_autor
        INTO pr_aprovant[p_index].descricao
        FROM nivel_autor_cap
       WHERE cod_empresa = p_docum.empresa
         AND cod_nivel_autor = pr_aprovant[p_index].nivel
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','NIVEL_AUTOR_CAP')
         LET pr_aprovant[p_index].descricao = ''
      END IF

      LET p_index = p_index + 1

   END FOREACH
   
   LET p_qtd_aprov = p_index - 1


END FUNCTION

#-----------------------------------#
 FUNCTION pol1166_escolhe_impressao()
#-----------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1166_imprime TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1166.tmp' 
         START REPORT pol1166_imprime TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1166_imprime TO p_nom_arquivo
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#-------------------------------------#
 FUNCTION pol1166_finaliza_impressao()#
#-------------------------------------#

   FINISH REPORT pol1166_imprime   
   
   IF p_count = 0 THEN
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

END FUNCTION

#--------------------------------#
FUNCTION pol1166_gera_aprovados()#
#--------------------------------#

   DELETE FROM docum_tmp_265

   IF p_cod_usuario IS NULL THEN
      LET p_query = "SELECT DISTINCT cod_usuario FROM usuarios_tmp_265 ORDER BY cod_usuario"
   ELSE
      LET p_query = "SELECT DISTINCT cod_usuario FROM usuarios_tmp_265",
                    " WHERE cod_usuario = '",p_cod_usuario,"' ",
                    " ORDER BY cod_usuario "
   END IF

   PREPARE query_user FROM p_query   
   DECLARE cq_query_user CURSOR FOR query_user

   FOREACH cq_query_user INTO p_nom_usuario

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_query_user')
         RETURN 
      END IF

      CALL pol1166_le_usuario()

      LET pr_men[1].mensagem = 'Lendo documentos aprovados'
      CALL pol1166_exib_mensagem()

      IF NOT pol1166_le_aprovados() THEN
         RETURN 
      END IF
      
   END FOREACH

   CALL pol1166_imp_arovados()

END FUNCTION

#------------------------------#
FUNCTION pol1166_le_aprovados()#
#------------------------------#

   IF NOT pol1166_le_aprov_ad() THEN
      RETURN FALSE
   END IF

   IF NOT pol1166_le_aprov_ar() THEN
      RETURN FALSE
   END IF

   IF NOT pol1166_le_aprov_pc() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1166_le_aprov_ad()#
#-----------------------------#
   
   INITIALIZE p_docum TO NULL

   LET pr_men[1].mensagem = 'Lendo financeiro - usuário ',p_nom_usuario
   CALL pol1166_exib_mensagem()

   DECLARE cq_ad_aprov CURSOR FOR
    SELECT cod_empresa,
           num_ad,
           num_versao,
           cod_nivel_autor,
           dat_aprovacao,
           hor_aprovacao,
           cod_uni_funcio
      FROM aprov_necessaria
     WHERE ies_aprovado = 'S'
       AND cod_usuario_aprov = p_nom_usuario
       AND dat_aprovacao >= p_dat_ini
       AND dat_aprovacao <= p_dat_fim
       AND cod_empresa IN (SELECT DISTINCT ad_empresa FROM empresas_sel_265)     #01/02/2013
       
   FOREACH cq_ad_aprov INTO
           p_docum.empresa,
           p_docum.num_docum,
           p_docum.num_versao,
           p_docum.cod_nivel_autorid,
           p_docum.dat_aprovacao,
           p_docum.hor_aprovacao,
           p_docum.cod_uni_funcio

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_AD_APROV')
         RETURN FALSE
      END IF

      SELECT a.cod_fornecedor,
             b.raz_social,
             a.dat_emis_nf,                                   
             a.val_tot_nf,                                       
             #a.dat_venc,                                      
             a.cod_tip_despesa                                
        INTO p_docum.cod_fornecedor,
             p_docum.nom_fornecedor,
             p_docum.dat_docum,
             p_docum.val_docum,
             p_docum.cod_tip_despesa
        FROM ad_mestre a,
             fornecedor b
       WHERE a.cod_empresa = p_docum.empresa
         AND a.num_ad = p_docum.num_docum
         AND a.cod_fornecedor = b.cod_fornecedor

      LET p_docum.nom_usuario = p_nom_usuario  
      LET p_docum.nom_funcionario = p_nom_funcionario        

      LET p_docum.tip_docum = 'FINANCEIRO'
      
      LET pr_docum.* = p_docum.*

      CALL pol1166_le_estado()         
      
      IF NOT pol1166_ins_docum() THEN
         RETURN FALSE
      END IF
      
      INITIALIZE p_docum TO NULL
      
   END FOREACH

END FUNCTION

#-----------------------------#
FUNCTION pol1166_le_aprov_ar()#
#-----------------------------#
   
   INITIALIZE p_docum TO NULL

   LET pr_men[1].mensagem = 'Lendo notas - usuário ',p_nom_usuario
   CALL pol1166_exib_mensagem()
   
   DECLARE cq_ar_aprov CURSOR FOR
    SELECT cod_empresa,
           num_aviso_rec,
           cod_nivel_autorid,
           dat_aprovacao,
           hor_aprovacao
      FROM aprov_ar_265
     WHERE nom_usuario_aprov = p_nom_usuario
       AND dat_aprovacao >= p_dat_ini
       AND dat_aprovacao <= p_dat_fim
       AND cod_empresa IN (SELECT DISTINCT cod_empresa FROM empresas_sel_265)     #01/02/2013
       
   FOREACH cq_ar_aprov INTO
           p_docum.empresa,
           p_docum.num_docum,
           p_docum.cod_nivel_autorid,
           p_docum.dat_aprovacao,
           p_docum.hor_aprovacao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_AR_APROV')
         RETURN FALSE
      END IF

      CALL pol1166_le_nf_sup() RETURNING p_status
      
      LET p_docum.cod_fornecedor = p_cod_fornecedor
      LET p_docum.nom_fornecedor = p_raz_social
      LET p_docum.dat_docum = p_dat_emis_nf
      LET p_docum.val_docum = p_val_tot_nf
      LET p_docum.tip_docum = p_ies_ar_cs
      LET p_docum.nom_usuario = p_nom_usuario  
      LET p_docum.nom_funcionario = p_nom_funcionario        

      LET p_docum.cod_uni_funcio = pol1166_le_uni_funcio()
      
      LET pr_docum.* = p_docum.*

      CALL pol1166_le_estado()         
      
      IF NOT pol1166_ins_docum() THEN
         RETURN FALSE
      END IF
      
      INITIALIZE p_docum TO NULL

   END FOREACH

END FUNCTION

#-------------------------------#
FUNCTION pol1166_le_uni_funcio()#
#-------------------------------#

   DEFINE p_unid_funcional CHAR(30)

   DECLARE cq_dest CURSOR FOR
       SELECT parametro_texto 
         FROM sup_par_ar 
        WHERE empresa = p_docum.empresa
          AND aviso_recebto = p_docum.num_docum
          AND seq_aviso_recebto = 0 
          AND parametro = 'secao_resp_aprov'
     
      FOREACH cq_dest INTO p_unid_funcional

         IF STATUS <> 0 THEN
            LET p_unid_funcional = NULL
         END IF
         
         EXIT FOREACH
      
   END FOREACH                     
   
   RETURN p_unid_funcional
   
END FUNCTION

#-----------------------------#
FUNCTION pol1166_le_aprov_pc()#
#-----------------------------#

   INITIALIZE p_docum TO NULL

   LET pr_men[1].mensagem = 'Lendo pedidos - usuário ',p_nom_usuario
   CALL pol1166_exib_mensagem()
   
   DECLARE cq_aprov_pc CURSOR FOR
    SELECT cod_empresa,
           num_pedido,
           num_versao_pedido,
           cod_nivel_autorid,
           dat_aprovacao,
           hor_aprovacao
      FROM aprov_ped_sup
     WHERE nom_usuario_aprov = p_nom_usuario
       AND dat_aprovacao >= p_dat_ini
       AND dat_aprovacao <= p_dat_fim
       AND cod_empresa IN (SELECT DISTINCT cod_empresa FROM empresas_sel_265)     #01/02/2013
       
   FOREACH cq_aprov_pc INTO
           p_docum.empresa,
           p_docum.num_docum,
           p_docum.num_versao,
           p_docum.cod_nivel_autorid,
           p_docum.dat_aprovacao,
           p_docum.hor_aprovacao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_APROV_PC')
         RETURN FALSE
      END IF

      CALL pol1166_le_pedido_sup() RETURNING p_status
      
      LET p_docum.cod_fornecedor = p_cod_fornecedor
      LET p_docum.nom_fornecedor = p_raz_social
      LET p_docum.dat_docum = p_dat_emis
      LET p_docum.val_docum = p_val_tot_ped
      LET p_docum.tip_docum = 'COMPRAS'
      LET p_docum.nom_usuario = p_nom_usuario  
      LET p_docum.nom_funcionario = p_nom_funcionario        

      LET pr_docum.* = p_docum.*

      CALL pol1166_le_estado()         
      
      IF NOT pol1166_ins_docum() THEN
         RETURN FALSE
      END IF
      
      INITIALIZE p_docum TO NULL
      
   END FOREACH

END FUNCTION

#------------------------------#
FUNCTION pol1166_imp_arovados()#
#------------------------------#

   DEFINE p_qtd_docum INTEGER

   LET p_soma_empresa = 0
   LET p_soma_docum = 0
   LET p_soma_user = 0
   LET p_soma_geral = 0
   
   SELECT COUNT(num_docum)
      INTO p_qtd_docum
      FROM docum_tmp_265

   IF STATUS <> 0 THEN
      LET p_qtd_docum = 0
   END IF

   LET pr_men[1].mensagem = 'Documentos a imprimir: ', p_qtd_docum
   CALL pol1166_exib_mensagem()

   DECLARE cq_imp_aprov CURSOR FOR
    SELECT *
      FROM docum_tmp_265
     ORDER BY nom_usuario, tip_docum, empresa
   
   FOREACH cq_imp_aprov INTO p_docum.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'CQ_IMP_APROV')
         RETURN
      END IF 

      LET p_qtd_docum = p_qtd_docum - 1
      LET p_count = p_count + 1

      IF p_count = 100 THEN
         LET pr_men[1].mensagem = 'Documentos a imprimir: ', p_qtd_docum
         CALL pol1166_exib_mensagem()
         LET p_count = 1
      END IF

      OUTPUT TO REPORT pol1166_imprime(p_docum.nom_usuario, p_docum.tip_docum, p_docum.empresa) 

   END FOREACH

   LET pr_men[1].mensagem = 'Impressão concluída.'
   CALL pol1166_exib_mensagem()
   
   RETURN TRUE

END FUNCTION

#-------------------------------------------------------------#
 REPORT pol1166_imprime(p_nom_usuario, p_tip_docum, p_empresa)#
#-------------------------------------------------------------#

   DEFINE p_empresa      CHAR(02), 
          p_tip_docum    CHAR(10),
          p_nom_usuario  CHAR(08),
          p_linha        CHAR(100),
          p_den_tot_emp  CHAR(30),
          p_den_tot_doc  CHAR(16),
          p_den_tot_user CHAR(14)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT

      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 053, "DOCUMENTOS APROVADOS",
               COLUMN 095, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " ", TIME
               
         PRINT COLUMN 001, "POL1166.4GL",
               COLUMN 035, p_nom_usuario CLIPPED, ' - ', p_docum.nom_funcionario,
               COLUMN 114, "PAG. ", PAGENO USING "&&&&"
         PRINT COLUMN 001, "--------------------------------------------------------------------------------------------------------------------------"

         PRINT
         PRINT COLUMN 001, 'EMP UF DOCUMENTO  VER TIPO       NIV DT APROV   HR APROV DATA DOCUM    VALOR                  FORNECEDOR'
         PRINT COLUMN 001, '--- -- ---------- --- ---------- --- ---------- -------- ---------- ------------- ----------------------------------------'

      PAGE HEADER  
         PRINT COLUMN 001, "POL1166.4GL",
               COLUMN 035, p_nom_usuario CLIPPED, ' - ', p_docum.nom_funcionario,
               COLUMN 114, "PAG. ", PAGENO USING "&&&&"
         PRINT COLUMN 001, "--------------------------------------------------------------------------------------------------------------------------"

         PRINT
         PRINT COLUMN 001, 'EMP UF DOCUMENTO  VER TIPO       NIV DT APROV   HR APROV DATA DOCUM    VALOR                  FORNECEDOR'
         PRINT COLUMN 001, '--- -- ---------- --- ---------- --- ---------- -------- ---------- ------------- ----------------------------------------'
         
      BEFORE GROUP OF p_nom_usuario
         SKIP TO TOP OF PAGE

      BEFORE GROUP OF p_tip_docum
         SKIP TO TOP OF PAGE

      ON EVERY ROW
      
         PRINT COLUMN 002, p_docum.empresa,
               COLUMN 005, p_docum.estado,
               COLUMN 008, p_docum.num_docum,
               COLUMN 019, p_docum.num_versao USING '###',
               COLUMN 023, p_docum.tip_docum,
               COLUMN 035, p_docum.cod_nivel_autorid,
               COLUMN 038, p_docum.dat_aprovacao,
               COLUMN 049, p_docum.hor_aprovacao,
               COLUMN 058, p_docum.dat_docum,
               COLUMN 069, p_docum.val_docum USING '##,###,##&.&&',
               COLUMN 083, p_docum.nom_fornecedor

      AFTER GROUP OF p_empresa
          
         IF p_ies_sumarizar = 'S' THEN
            LET p_soma_empresa = GROUP SUM(p_docum.val_docum)
            LET p_den_tot_emp = 'TOTAL EMPRESA ', p_empresa, ' - ', p_tip_docum
            PRINT COLUMN 066, '----------------'
            PRINT COLUMN 036, p_den_tot_emp,
                  COLUMN 066, p_soma_empresa USING '#,###,###,##&.&&'
            PRINT
            LET p_soma_docum = p_soma_docum + p_soma_empresa
         END IF
         
      AFTER GROUP OF p_tip_docum

         IF p_ies_sumarizar = 'S' THEN
            LET p_den_tot_doc = 'TOTAL ', p_tip_docum
            PRINT #COLUMN 066, '----------------'
            PRINT COLUMN 049, p_den_tot_doc,
                  COLUMN 066, p_soma_docum USING '#,###,###,##&.&&'
            PRINT
            LET p_soma_user = p_soma_user + p_soma_docum
            LET p_soma_docum = 0
         END IF

      AFTER GROUP OF p_nom_usuario

         IF p_ies_sumarizar = 'S' THEN
            LET p_den_tot_user = 'TOTAL ', p_nom_usuario
            PRINT #COLUMN 066, '----------------'
            PRINT COLUMN 051, p_den_tot_user,
                  COLUMN 066, p_soma_user USING '#,###,###,##&.&&'
            PRINT
            LET p_soma_geral = p_soma_geral + p_soma_user
            LET p_soma_user = 0
         END IF
         
      ON LAST ROW

         IF p_ies_sumarizar = 'S' THEN
            PRINT #COLUMN 066, '----------------'
            PRINT COLUMN 054, 'TOTAL GERAL',
                  COLUMN 066, p_soma_geral USING '#,###,###,##&.&&'
         END IF

         LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF

END REPORT

