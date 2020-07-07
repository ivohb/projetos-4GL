#-------------------------------------------------------------------------#
# SISTEMA.: Relaçao de Funcionários		                				            #
#	PROGRAMA:	pol1075																												#
#	CLIENTE.:	IURD																													#
#	OBJETIVO:	Rel. de contratos de emprestimos consignados p/ funcionarios	#
#	AUTOR...:	Paulo																												  #
#	DATA....:	03/12/2010							 																			#
#-------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa         LIKE empresa.cod_empresa,
          p_den_empresa         LIKE empresa.den_empresa,
          p_user                LIKE usuario.nom_usuario,
          p_cod_banco           LIKE bancos.cod_banco,
          p_nom_banco           LIKE bancos.nom_banco,
          p_status              SMALLINT,
          p_count               SMALLINT,
          p_houve_erro          SMALLINT,
          comando               CHAR(80),
          p_ies_impressao       CHAR(01),
          g_ies_ambiente        CHAR(01),
          p_versao              CHAR(18),
          p_nom_arquivo         CHAR(100),
          p_nom_tela            CHAR(200),
          p_nom_help            CHAR(200),
          p_ies_cons            SMALLINT,
          p_caminho             CHAR(080),
          p_retorno             SMALLINT,
          p_index               SMALLINT,
          s_index               SMALLINT,
          p_ind                 SMALLINT,
          s_ind                 SMALLINT,
          p_cab_gru             CHAR(10),
          p_cod_gru             CHAR(10),
          sql_stmt              CHAR(500),          
          where_clause          CHAR(500),          
          p_6lpp                CHAR(100),
          p_8lpp                CHAR(100),
          p_msg                 CHAR(600),
          p_last_row            SMALLINT,
          p_Comprime            CHAR(01),
          p_descomprime         CHAR(01),
          p_negrito             CHAR(02),
          p_normal              CHAR(02),
          p_ordem               CHAR(10),
          p_repetiu             SMALLINT,
          p_Data_char           CHAR(10),
          p_Ano                 CHAR(10),
          p_data                DATE,
          p_Dat_referencia      DATE,
          p_Dat_ref_final       DATE,
          p_Dat_ref_acerto      DATE,
          p_Dat_ref_acerfim     DATE,
          p_num_seq             SMALLINT,
          p_sql                 CHAR(800),
          p_val_parc_Prev       DECIMAL(12,2),
          p_val_parc_Efe        DECIMAL(12,2),
          p_val_parc_Acer       DECIMAL(12,2),
          p_val_parc_Nao        DECIMAL(12,2),
          p_fval_parc_Prev      DECIMAL(12,2),
          p_fval_parc_Efe       DECIMAL(12,2),
          p_fval_parc_Acer      DECIMAL(12,2),
          p_fval_parc_Nao       DECIMAL(12,2),
          p_num_matricula       DECIMAL(8,0),
          p_imprime             SMALLINT,
          p_filtro              CHAR(120)
               
   DEFINE p_tela                RECORD 
          cod_banco             LIKE bancos.cod_banco,
          nom_banco             LIKE bancos.nom_banco,
          mesano                CHAR(7),
          mesano_acerto         CHAR(7),
          cod_uf                LIKE uni_feder.cod_uni_feder,
          cod_setor             LIKE empresa.cod_empresa,
          cod_func              CHAR(19),
          cod_tipo              CHAR(1)
   END RECORD
          
   DEFINE p_txt  ARRAY[10] OF RECORD
          txt    CHAR(40)
   END RECORD
           
   DEFINE pr_campos             ARRAY[11] OF RECORD
          posicao               INTEGER,
          tamanho               INTEGER
   END RECORD
   
   DEFINE p_lista RECORD
      ano_mes_proces            CHAR(7),
      tipo_acerto               CHAR(15),
      cpf_func                  CHAR(19),
      nom_funcionario           CHAR(60),
      val_parc_folha            DECIMAL(12,2),
      val_parc_banco            DECIMAL(12,2),
      num_matricula             DECIMAL(8,0),
      empresa                   CHAR(2),
      uni_feder                 CHAR(2),
      dat_acerto_prev           DATE,
      dat_acerto_real           DATE,
      dat_referencia            DATE,
      observacao                CHAR(225),
      val_parc_Prev             DECIMAL(12,2),
      val_parc_Efe              DECIMAL(12,2),
      val_parc_Acer             DECIMAL(12,2),
      val_parc_Nao              DECIMAL(12,2),
      quantidade                SMALLINT,
      cod_banco                 SMALLINT,
      dat_acerto                DATE
   END RECORD 

   DEFINE p_total  RECORD
          p_val_desc_prev       DECIMAL(12,2),
          p_val_desc_efe        DECIMAL(12,2),
          p_val_desc_nao        DECIMAL(12,2),
          p_val_desc_acer       DECIMAL(12,2),
          p_val_reem_prev       DECIMAL(12,2),
          p_val_reem_efe        DECIMAL(12,2),
          p_val_reem_nao        DECIMAL(12,2),
          p_val_reem_acer       DECIMAL(12,2),
          p_val_repa_prev       DECIMAL(12,2),
          p_val_repa_efe        DECIMAL(12,2),
          p_val_repa_nao        DECIMAL(12,2),
          p_val_repa_acer       DECIMAL(12,2),
          p_val_prej_prev       DECIMAL(12,2),
          p_val_prej_efe        DECIMAL(12,2),
          p_val_prej_nao        DECIMAL(12,2),
          p_val_prej_acer       DECIMAL(12,2),
          p_val_duvi_prev       DECIMAL(12,2),
          p_val_duvi_efe        DECIMAL(12,2),
          p_val_duvi_nao        DECIMAL(12,2),
          p_val_duvi_acer       DECIMAL(12,2),
          p_count_desc_prev     SMALLINT,
          p_count_desc_efe      SMALLINT,
          p_count_desc_nao      SMALLINT,
          p_count_desc_acer     SMALLINT,
          p_count_reem_prev     SMALLINT,
          p_count_reem_efe      SMALLINT,
          p_count_reem_nao      SMALLINT,
          p_count_reem_acer     SMALLINT,
          p_count_repa_prev     SMALLINT,
          p_count_repa_efe      SMALLINT,
          p_count_repa_nao      SMALLINT,
          p_count_repa_acer     SMALLINT,
          p_count_prej_prev     SMALLINT,
          p_count_prej_efe      SMALLINT,
          p_count_prej_nao      SMALLINT,
          p_count_prej_acer     SMALLINT,
          p_count_duvi_prev     SMALLINT,
          p_count_duvi_efe      SMALLINT,
          p_count_duvi_nao      SMALLINT,
          p_count_duvi_acer     SMALLINT,
          p_val_desc_dif        DECIMAL(12,2),
          p_val_reem_dif        DECIMAL(12,2),
          p_val_repa_dif        DECIMAL(12,2),
          p_val_prej_dif        DECIMAL(12,2),
          p_val_duvi_dif        DECIMAL(12,2),
          p_count_desc_dif      SMALLINT,
          p_count_reem_dif      SMALLINT,
          p_count_repa_dif      SMALLINT,
          p_count_prej_dif      SMALLINT,
          p_count_duvi_dif      SMALLINT
   END RECORD 

    # retornos da função - o objetivo é dividir o texto em até
    # 15 linhas com no minimo 20 e no máximo 200 caracteres
    
   DEFINE r_01 VARCHAR(200),
          r_02 VARCHAR(200),
          r_03 VARCHAR(200),
          r_04 VARCHAR(200),
          r_05 VARCHAR(200),
          r_06 VARCHAR(200),
          r_07 VARCHAR(200),
          r_08 VARCHAR(200),
          r_09 VARCHAR(200),
          r_10 VARCHAR(200),
          r_11 VARCHAR(200),
          r_12 VARCHAR(200),
          r_13 VARCHAR(200),
          r_14 VARCHAR(200),
          r_15 VARCHAR(200)
          
    
    # parâmetros recebidos #
          
   DEFINE texto      VARCHAR(3000),
          tam_linha  SMALLINT,
          qtd_linha  SMALLINT,
          justificar CHAR(01)

   DEFINE num_carac  SMALLINT,
          ret        VARCHAR(200)
 
         
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
	 LET p_versao = "pol1075-10.02.11"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1075.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol1075_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1075_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1075") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1075 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
         
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Listagem"
         HELP 001 
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol1075","IN")  THEN
         		LET p_count = 0
            IF pol1075_informar() THEN
            	MESSAGE "Parâmetros informados com sucesso !!!" ATTRIBUTE(REVERSE)
              LET p_ies_cons = TRUE
              NEXT OPTION "Listar"
            ELSE
              ERROR "Operação Cancelada !!!"
              NEXT OPTION "Fim"
            END IF
         END IF 
      COMMAND "Listar" "Listagem de observações - Conciliação"
         HELP 002
         LET p_count = 0
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol1075","MO") THEN
           IF p_ies_cons THEN 
               IF log0280_saida_relat(13,29) IS NOT NULL THEN
                  MESSAGE " Processando a Extracao do Relatorio..." 
                     ATTRIBUTE(REVERSE)
                     
                  IF p_ies_impressao = "S" THEN
                     IF g_ies_ambiente = "U" THEN
                        START REPORT pol1075_relat TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1075.tmp'
                        START REPORT pol1075_relat  TO p_caminho
                     END IF
                  ELSE
                     START REPORT pol1075_relat TO p_nom_arquivo
                  END IF
                  CALL pol1075_emite_relatorio()   
                  IF p_count = 0 THEN
                     ERROR "Nao Existem Dados para serem Listados" 
                  ELSE
                     ERROR "Relatorio Processado com Sucesso" 
                  END IF
                  FINISH REPORT pol1075_relat   

               ELSE
                  CONTINUE MENU
               END IF                                                    
               IF p_ies_impressao = "S" THEN
                  MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                     ATTRIBUTE(REVERSE)
                  IF g_ies_ambiente = "W" THEN
                     LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                   p_nom_arquivo
                     RUN comando
                  END IF
               ELSE
                  IF p_count > 0 THEN 
                     MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                     " " ATTRIBUTE(REVERSE)
                  ELSE
                     MESSAGE ""
                  END IF
               END IF                              
                  IF p_ies_impressao = "S" THEN
                     IF g_ies_ambiente = "U" THEN
                        START REPORT pol1075_resumo TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1075.tmp'
                        START REPORT pol1075_resumo  TO p_caminho
                     END IF
                  ELSE
                  	 LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_1"
                     START REPORT pol1075_resumo TO p_nom_arquivo
                  END IF
                  CALL pol1075_emite_resumo()   
                  FINISH REPORT pol1075_resumo   

               IF p_ies_impressao = "S" THEN
                  MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                     ATTRIBUTE(REVERSE)
                  IF g_ies_ambiente = "W" THEN
                     LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                   p_nom_arquivo
                     RUN comando
                  END IF
               ELSE
                  IF p_count > 0 THEN 
                     MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                     " " ATTRIBUTE(REVERSE)
                  ELSE
                     MESSAGE ""
                  END IF
               END IF                              

                  IF p_ies_impressao = "S" THEN
                     IF g_ies_ambiente = "U" THEN
                        START REPORT pol1075_total TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1075.tmp'
                        START REPORT pol1075_total  TO p_caminho
                     END IF
                  ELSE
                  	 LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_2"
                     START REPORT pol1075_total TO p_nom_arquivo
                  END IF
                  CALL pol1075_emite_total()   
                  FINISH REPORT pol1075_total   

               IF p_ies_impressao = "S" THEN
                  MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                     ATTRIBUTE(REVERSE)
                  IF g_ies_ambiente = "W" THEN
                     LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                   p_nom_arquivo
                     RUN comando
                  END IF
               ELSE
                  IF p_count > 0 THEN 
                     MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                     " " ATTRIBUTE(REVERSE)
                  ELSE
                     MESSAGE ""
                  END IF
               END IF                              

               NEXT OPTION "Fim"
           ELSE
               ERROR "Informar Previamente Parametros para Impressao"
               NEXT OPTION "Informar"
           END IF 
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				 CALL pol1075_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1075

END FUNCTION

#--------------------------#
FUNCTION pol1075_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_tela.cod_uf    = '99'
   LET p_tela.cod_setor = '99'
   LET p_tela.cod_tipo  = 0
 
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      BEFORE FIELD cod_banco
         IF p_tela.cod_banco IS NULL THEN
            LET p_tela.cod_banco = p_cod_banco
         END IF

      AFTER FIELD cod_banco
         IF p_tela.cod_banco IS NULL THEN
            ERROR "Campo com preenchimento obrigatorio !!!"
            NEXT FIELD cod_banco
         END IF
         
         SELECT nom_banco
           INTO p_tela.nom_banco
           FROM bancos
          WHERE cod_banco = p_tela.cod_banco
         
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR "Banco inexistente !!!"
            NEXT FIELD cod_banco
         END IF
         
         DISPLAY p_tela.nom_banco TO nom_banco

      AFTER FIELD mesano    
      IF p_tela.mesano IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD mesano       
      END IF 

      IF p_tela.mesano[4,7] = '9999' THEN
         ERROR "Ano incorreto"
         NEXT FIELD mesano
      END IF 

      IF p_tela.mesano[1,2] > '12' THEN
         IF p_tela.mesano_acerto[1,2] <> '99' THEN
         	ERROR "Mês incorreto"
         	NEXT FIELD mesano
         END IF 	       
      END IF 

      
      AFTER FIELD mesano_acerto  
      IF p_tela.mesano_acerto[1,2] > '12' THEN
         IF p_tela.mesano_acerto[1,2] <> '99' THEN
         	ERROR "Mês incorreto"
         	NEXT FIELD mesano_acerto
         END IF 	       
      END IF 
        

      ON KEY (control-z)
         CALL pol1075_popup()

   END INPUT

   IF INT_FLAG = 0 THEN
   #   IF pol1029_aceita_repres() THEN
         RETURN TRUE
   #   END IF
   ELSE
      LET INT_FLAG = 0
      CLEAR FORM
      DISPLAY p_cod_banco TO cod_banco
   END IF

   RETURN FALSE
   
END FUNCTION

#-----------------------#
FUNCTION pol1075_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_setor)
         CALL log009_popup(8,15,"EMPRESAS","empresa",
                     "cod_empresa","den_empresa","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1075
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_setor = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_setor
            
         END IF

      WHEN INFIELD(cod_banco)
         CALL log009_popup(8,25,"Banco","bancos",
                     "cod_banco","nom_banco","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1075
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_banco = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_banco
         END IF



   END CASE

END FUNCTION

#--------------------------------#
FUNCTION pol1075_emite_total()
#--------------------------------#

   LET p_total.p_val_desc_prev = 0
   LET p_total.p_val_desc_efe  = 0
   LET p_total.p_val_desc_nao  = 0
   LET p_total.p_val_desc_acer = 0
   LET p_total.p_val_reem_prev = 0
   LET p_total.p_val_reem_efe  = 0
   LET p_total.p_val_reem_nao  = 0
   LET p_total.p_val_reem_acer = 0
   LET p_total.p_val_repa_prev = 0
   LET p_total.p_val_repa_efe  = 0
   LET p_total.p_val_repa_nao  = 0
   LET p_total.p_val_repa_acer = 0
   LET p_total.p_val_prej_prev = 0
   LET p_total.p_val_prej_efe  = 0
   LET p_total.p_val_prej_nao  = 0
   LET p_total.p_val_prej_acer = 0
   LET p_total.p_val_duvi_prev = 0
   LET p_total.p_val_duvi_efe  = 0
   LET p_total.p_val_duvi_nao  = 0
   LET p_total.p_val_duvi_acer = 0
   LET p_total.p_count_desc_prev = 0
   LET p_total.p_count_desc_efe  = 0
   LET p_total.p_count_desc_nao  = 0
   LET p_total.p_count_desc_acer = 0
   LET p_total.p_count_reem_prev = 0
   LET p_total.p_count_reem_efe  = 0
   LET p_total.p_count_reem_nao  = 0
   LET p_total.p_count_reem_acer = 0
   LET p_total.p_count_repa_prev = 0
   LET p_total.p_count_repa_efe  = 0
   LET p_total.p_count_repa_nao  = 0
   LET p_total.p_count_repa_acer = 0
   LET p_total.p_count_prej_prev = 0
   LET p_total.p_count_prej_efe  = 0
   LET p_total.p_count_prej_nao  = 0
   LET p_total.p_count_prej_acer = 0
   LET p_total.p_count_duvi_prev = 0
   LET p_total.p_count_duvi_efe  = 0
   LET p_total.p_count_duvi_nao  = 0
   LET p_total.p_count_duvi_acer = 0
   LET p_total.p_val_desc_dif    = 0
   LET p_total.p_val_reem_dif    = 0
   LET p_total.p_val_repa_dif    = 0
   LET p_total.p_val_prej_dif    = 0
   LET p_total.p_val_duvi_dif    = 0
   LET p_total.p_count_desc_dif  = 0
   LET p_total.p_count_reem_dif  = 0
   LET p_total.p_count_repa_dif  = 0
   LET p_total.p_count_prej_dif  = 0
   LET p_total.p_count_duvi_dif  = 0
   
#----------------------------- IMPRIMINDO TOTALIZAÇÃO --------------------------#
   LET p_sql = 
      "SELECT b.tip_acerto,b.dat_referencia,b.dat_acerto_real, b.cod_banco, ",
      " b.dat_acerto_prev, sum(b.val_acerto) AS val_acerto,sum(b.val_banco) AS val_parcela, count(b.tip_acerto) AS qtd ",
      " FROM diverg_consig_265 b ",
      "   LEFT JOIN empresa e ",
      "   ON e.cod_empresa = b.cod_empresa "


   LET p_sql = p_sql CLIPPED, ' '," WHERE b.cod_banco =  ",p_tela.cod_banco," "

   IF p_tela.mesano <> '99/9999' AND p_tela.mesano_acerto <> '99/9999' THEN
   		IF p_tela.mesano[1,2] <> '99' AND p_tela.mesano_acerto[1,2] <> '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND (b.dat_referencia = '",p_Dat_referencia,"' or b.dat_acerto_prev = '",p_Dat_ref_acerto,"')" 
      	LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   			LET p_filtro = p_filtro CLIPPED, " MÊS/ANO ACERTO: ",p_tela.mesano_acerto
   		END IF
   		IF p_tela.mesano[1,2] = '99' AND p_tela.mesano_acerto[1,2] = '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND ((b.dat_referencia >= '",p_Dat_referencia,"' and b.dat_referencia <= '",p_Dat_ref_final,"') or (b.dat_acerto_prev >= '",p_Dat_ref_acerto,"' and b.dat_acerto_prev <= '",p_Dat_ref_acerfim,"'))" 
      	LET p_filtro = "ANO: ",p_Ano
   			LET p_filtro = p_filtro CLIPPED, " ANO ACERTO: ",p_Ano
   		END IF   
   		IF p_tela.mesano[1,2] <> '99' AND p_tela.mesano_acerto[1,2] = '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND (b.dat_referencia = '",p_Dat_referencia,"'  AND (b.dat_acerto_prev >= '",p_Dat_ref_acerto,"' and b.dat_acerto_prev <= '",p_Dat_ref_acerfim,"'))" 
      	LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   			LET p_filtro = p_filtro CLIPPED, " ANO ACERTO: ",p_Ano
   		END IF   
   		IF p_tela.mesano[1,2] = '99' AND p_tela.mesano_acerto[1,2] <> '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND ((b.dat_referencia >= '",p_Dat_referencia,"' and b.dat_referencia <= '",p_Dat_ref_final,"') and  b.dat_acerto_prev = '",p_Dat_ref_acerto,"')"
      	LET p_filtro = "ANO: ",p_Ano
   			LET p_filtro = p_filtro CLIPPED, " MÊS/ANO ACERTO: ",p_tela.mesano_acerto
   		END IF   
   	END IF	   

   	IF p_tela.mesano[1,2] <> '99' AND p_tela.mesano_acerto IS NULL THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND (b.dat_referencia = '",p_Dat_referencia,"' and  b.dat_acerto_prev IS NULL)"
      LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   		LET p_filtro = p_filtro CLIPPED, " SEM ACERTO "
   	END IF   
   	IF p_tela.mesano[1,2] = '99' AND p_tela.mesano_acerto IS NULL THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND ((b.dat_referencia >= '",p_Dat_referencia,"' and b.dat_referencia <= '",p_Dat_ref_final,"') AND b.dat_acerto_prev IS NULL)"
      LET p_filtro = "ANO: ",p_Ano
   		LET p_filtro = p_filtro CLIPPED, " SEM ACERTO "
   	END IF

    IF p_tela.mesano = '99/9999' AND p_tela.mesano_acerto = '99/9999' THEN
      LET p_filtro = "MÊS/ANO: TODOS"
   		LET p_filtro = p_filtro CLIPPED, " MÊS/ANO ACERTO: TODOS "
	  END IF


		IF   p_tela.cod_uf <> '99' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND e.uni_feder = '",p_tela.cod_uf,"' "
    END IF

		IF   p_tela.cod_setor <> '99' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.cod_empresa = '",p_tela.cod_setor,"' "
    END IF

		IF   p_tela.cod_tipo <> '0' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.tip_acerto = ",p_tela.cod_tipo
    END IF

		IF   p_tela.cod_tipo = '0' THEN
      LET p_filtro = p_filtro CLIPPED, " TIPO: TODOS"
    END IF

   LET p_sql = p_sql CLIPPED, ' ', " GROUP BY b.tip_acerto, b.cod_banco, b.dat_referencia,b.dat_acerto_real,b.dat_acerto_prev  "
   LET p_sql = p_sql CLIPPED, ' ', " ORDER BY b.dat_referencia "

   PREPARE var_query3 FROM p_sql   
   DECLARE cq_padrao3 CURSOR FOR var_query3

   FOREACH cq_padrao3 INTO 
      p_lista.tipo_acerto, p_lista.dat_referencia, 
      p_lista.dat_acerto_real, p_lista.cod_banco,
      p_lista.dat_acerto_prev, p_lista.val_parc_banco, 
      p_lista.val_parc_folha,  p_lista.quantidade
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_padrao2')
      END IF
         
      CASE p_lista.tipo_acerto[1,1]    
         WHEN '1'
            IF p_lista.dat_referencia < p_Dat_referencia THEN
            	LET p_total.p_count_desc_prev  = p_total.p_count_desc_prev + p_lista.quantidade
            	LET p_total.p_val_desc_prev    = p_lista.val_parc_banco
            END IF	
            IF p_lista.dat_acerto_prev = p_lista.dat_referencia THEN
            	LET p_total.p_count_desc_efe   = p_total.p_count_desc_efe + p_lista.quantidade
            	LET p_total.p_val_desc_efe     = p_lista.val_parc_banco
            END IF	
    	      IF p_lista.dat_acerto_prev > p_Dat_referencia THEN
            	LET p_total.p_count_desc_acer  = p_total.p_count_desc_acer + p_lista.quantidade
            	LET p_total.p_val_desc_acer    = p_lista.val_parc_banco
            END IF	
            IF p_lista.dat_acerto_prev IS NULL THEN
            	LET p_total.p_count_desc_nao   = p_total.p_count_desc_nao + p_lista.quantidade
            	LET p_total.p_val_desc_nao     = p_lista.val_parc_banco
            END IF	
         WHEN '2'
            IF p_lista.dat_referencia < p_Dat_referencia THEN
            	LET p_total.p_count_reem_prev  = p_total.p_count_reem_prev + p_lista.quantidade
            	LET p_total.p_val_reem_prev    = p_lista.val_parc_banco
            END IF	
            IF p_lista.dat_acerto_prev = p_lista.dat_referencia THEN
            	LET p_total.p_count_reem_efe   = p_total.p_count_reem_efe + p_lista.quantidade
            	LET p_total.p_val_reem_efe     = p_lista.val_parc_banco
            END IF	
    	      IF p_lista.dat_acerto_prev > p_Dat_referencia THEN
            	LET p_total.p_count_reem_acer  = p_total.p_count_reem_acer + p_lista.quantidade
            	LET p_total.p_val_reem_acer    = p_lista.val_parc_banco
            END IF	
            IF p_lista.dat_acerto_prev IS NULL THEN
            	LET p_total.p_count_reem_nao   = p_total.p_count_reem_nao + p_lista.quantidade
            	LET p_total.p_val_reem_nao     = p_lista.val_parc_banco
            END IF	
         WHEN '3'
            IF p_lista.dat_referencia < p_Dat_referencia THEN
            	LET p_total.p_count_repa_prev  = p_total.p_count_repa_prev + p_lista.quantidade
            	LET p_total.p_val_repa_prev    = p_lista.val_parc_banco
            END IF	
            IF p_lista.dat_acerto_prev = p_lista.dat_referencia THEN
            	LET p_total.p_count_repa_efe   = p_total.p_count_repa_efe + p_lista.quantidade
            	LET p_total.p_val_repa_efe     = p_lista.val_parc_banco
            END IF	
    	      IF p_lista.dat_acerto_prev > p_Dat_referencia THEN
            	LET p_total.p_count_repa_acer  = p_total.p_count_repa_acer + p_lista.quantidade
            	LET p_total.p_val_repa_acer    = p_lista.val_parc_banco
            END IF	
            IF p_lista.dat_acerto_prev IS NULL THEN
            	LET p_total.p_count_repa_nao   = p_total.p_count_repa_nao + p_lista.quantidade
            	LET p_total.p_val_repa_nao     = p_lista.val_parc_banco
            END IF	
         WHEN '4'
            IF p_lista.dat_referencia < p_Dat_referencia THEN
            	LET p_total.p_count_prej_prev  = p_total.p_count_prej_prev + p_lista.quantidade
            	LET p_total.p_val_prej_prev    = p_lista.val_parc_banco
            END IF	
    	      IF p_lista.dat_acerto_prev > p_Dat_referencia THEN
            	LET p_total.p_count_prej_acer  = p_total.p_count_prej_acer + p_lista.quantidade
            	LET p_total.p_val_prej_acer    = p_lista.val_parc_banco
            END IF	
            IF p_lista.dat_acerto_prev IS NULL THEN
            	LET p_total.p_count_prej_nao   = p_total.p_count_prej_nao + p_lista.quantidade
            	LET p_total.p_val_prej_nao     = p_lista.val_parc_banco
            END IF	
         WHEN '5'
            IF p_lista.dat_referencia < p_Dat_referencia THEN
            	LET p_total.p_count_duvi_prev  = p_total.p_count_duvi_prev + p_lista.quantidade
            	LET p_total.p_val_duvi_prev    = p_lista.val_parc_banco
            END IF	
    	      IF p_lista.dat_acerto_prev > p_Dat_referencia THEN
            	LET p_total.p_count_duvi_acer  = p_total.p_count_duvi_acer + p_lista.quantidade
            	LET p_total.p_val_duvi_acer    = p_lista.val_parc_banco
            END IF	
            IF p_lista.dat_acerto_prev IS NULL THEN
            	LET p_total.p_count_duvi_nao   = p_total.p_count_duvi_nao + p_lista.quantidade
            	LET p_total.p_val_duvi_nao     = p_lista.val_parc_banco
            END IF	
      END CASE
      
			IF   p_tela.cod_tipo <> '0' THEN
      	LET p_filtro = p_filtro CLIPPED, " TIPO: ",p_lista.tipo_acerto
    	END IF




      
      LET p_count = p_count + 1
      INITIALIZE p_lista TO NULL
                 
   END FOREACH
 	 
	 LET p_total.p_count_desc_dif = p_total.p_count_desc_prev - p_total.p_count_desc_efe	
	 LET p_total.p_count_reem_dif = p_total.p_count_reem_prev - p_total.p_count_reem_efe	
	 LET p_total.p_count_repa_dif = p_total.p_count_repa_prev - p_total.p_count_repa_efe	
	 LET p_total.p_val_desc_dif = p_total.p_val_desc_prev - p_total.p_val_desc_efe	
	 LET p_total.p_val_reem_dif = p_total.p_val_reem_prev - p_total.p_val_reem_efe	
	 LET p_total.p_val_repa_dif = p_total.p_val_repa_prev - p_total.p_val_repa_efe	



 	 OUTPUT TO REPORT pol1075_total(p_lista.dat_referencia) 




END FUNCTION

#--------------------------------#
FUNCTION pol1075_emite_resumo()
#--------------------------------#

   LET p_count          = 0 
   LET p_val_parc_Prev  = 0
   LET p_val_parc_Efe   = 0
   LET p_val_parc_Acer  = 0
   LET p_val_parc_Nao   = 0
   LET p_num_matricula  = NULL
   LET p_imprime        = 0
   
#----------------------------- IMPRIMINDO RESUMO --------------------------#
   LET p_sql = 
      "SELECT DISTINCT(b.dat_referencia), b.tip_acerto,b.num_cpf,b.nom_funcionario, ",
      " b.num_matricula, b.cod_empresa, e.uni_feder, b.dat_acerto_prev, b.val_acerto, ",
      " b.dat_acerto_real ",
      " FROM diverg_consig_265 b ",
      "   LEFT JOIN empresa e ",
      "   ON e.cod_empresa = b.cod_empresa "



   LET p_sql = p_sql CLIPPED, ' '," WHERE b.cod_banco =  ",p_tela.cod_banco," "

   IF p_tela.mesano <> '99/9999' AND p_tela.mesano_acerto <> '99/9999' THEN
   		IF p_tela.mesano[1,2] <> '99' AND p_tela.mesano_acerto[1,2] <> '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND (b.dat_referencia = '",p_Dat_referencia,"' or b.dat_acerto_prev = '",p_Dat_ref_acerto,"')" 
      	LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   			LET p_filtro = p_filtro CLIPPED, " MÊS/ANO ACERTO: ",p_tela.mesano_acerto
   		END IF
   		IF p_tela.mesano[1,2] = '99' AND p_tela.mesano_acerto[1,2] = '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND ((b.dat_referencia >= '",p_Dat_referencia,"' and b.dat_referencia <= '",p_Dat_ref_final,"') or (b.dat_acerto_prev >= '",p_Dat_ref_acerto,"' and b.dat_acerto_prev <= '",p_Dat_ref_acerfim,"'))" 
      	LET p_filtro = "ANO: ",p_Ano
   			LET p_filtro = p_filtro CLIPPED, " ANO ACERTO: ",p_Ano
   		END IF   
   		IF p_tela.mesano[1,2] <> '99' AND p_tela.mesano_acerto[1,2] = '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND (b.dat_referencia = '",p_Dat_referencia,"'  AND (b.dat_acerto_prev >= '",p_Dat_ref_acerto,"' and b.dat_acerto_prev <= '",p_Dat_ref_acerfim,"'))" 
      	LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   			LET p_filtro = p_filtro CLIPPED, " ANO ACERTO: ",p_Ano
   		END IF   
   		IF p_tela.mesano[1,2] = '99' AND p_tela.mesano_acerto[1,2] <> '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND ((b.dat_referencia >= '",p_Dat_referencia,"' and b.dat_referencia <= '",p_Dat_ref_final,"') and  b.dat_acerto_prev = '",p_Dat_ref_acerto,"')"
      	LET p_filtro = "ANO: ",p_Ano
   			LET p_filtro = p_filtro CLIPPED, " MÊS/ANO ACERTO: ",p_tela.mesano_acerto
   		END IF   
   	END IF	   

   	IF p_tela.mesano[1,2] <> '99' AND p_tela.mesano_acerto IS NULL THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND (b.dat_referencia = '",p_Dat_referencia,"' and  b.dat_acerto_prev IS NULL)"
      LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   		LET p_filtro = p_filtro CLIPPED, " SEM ACERTO "
   	END IF   
   	IF p_tela.mesano[1,2] = '99' AND p_tela.mesano_acerto IS NULL THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND ((b.dat_referencia >= '",p_Dat_referencia,"' and b.dat_referencia <= '",p_Dat_ref_final,"') AND b.dat_acerto_prev IS NULL)"
      LET p_filtro = "ANO: ",p_Ano
   		LET p_filtro = p_filtro CLIPPED, " SEM ACERTO "
   	END IF

   	IF p_tela.mesano = '99/9999' AND p_tela.mesano_acerto = '99/9999' THEN
      LET p_filtro = "MÊS/ANO: TODOS"
   		LET p_filtro = p_filtro CLIPPED, " MÊS/ANO ACERTO: TODOS "
	 	END IF


		IF   p_tela.cod_uf <> '99' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND e.uni_feder = '",p_tela.cod_uf,"' "
    END IF

		IF   p_tela.cod_setor <> '99' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.cod_empresa = '",p_tela.cod_setor,"' "
    END IF

		IF   p_tela.cod_tipo <> '0' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.tip_acerto = ",p_tela.cod_tipo
    END IF

		IF   p_tela.cod_func <> '                  ' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.num_cpf = '",p_tela.cod_func,"'"
    END IF

		IF   p_tela.cod_tipo = '0' THEN
      LET p_filtro = p_filtro CLIPPED, " TIPO: TODOS"
    END IF

   LET p_sql = p_sql CLIPPED, ' ', " order by b.nom_funcionario "

   PREPARE var_query1 FROM p_sql   
   DECLARE cq_padrao1 CURSOR FOR var_query1

   FOREACH cq_padrao1 INTO 
      p_lista.dat_referencia, p_lista.tipo_acerto,
      p_lista.cpf_func, p_lista.nom_funcionario, 
      p_lista.num_matricula,
      p_lista.empresa, p_lista.uni_feder, 
      p_lista.dat_acerto_prev, p_lista.val_parc_folha,
      p_lista.dat_acerto_real
      
      CASE p_lista.tipo_acerto[1,1]    
         WHEN '1'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Desconto' 
         WHEN '2'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Reembolso' 
         WHEN '3'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Repasse' 
         WHEN '4'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Em prejuízo' 
         WHEN '5'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Em dúvida' 
      END CASE
      
			IF   p_tela.cod_tipo <> '0' THEN
      	LET p_filtro = p_filtro CLIPPED, " TIPO: ",p_lista.tipo_acerto
    	END IF


      IF p_lista.dat_referencia < p_Dat_referencia THEN
        LET p_lista.val_parc_Prev = p_lista.val_parc_folha 
        LET p_val_parc_Prev       = p_val_parc_Prev + p_lista.val_parc_folha 
        LET p_fval_parc_Prev      = p_fval_parc_Prev + p_lista.val_parc_folha 
      ELSE
        LET p_lista.val_parc_Prev = NULL 
      END IF	

      IF p_lista.dat_acerto_prev >= p_lista.dat_referencia THEN
        LET p_lista.val_parc_Efe = p_lista.val_parc_folha 
        LET p_val_parc_Efe       = p_val_parc_Efe + p_lista.val_parc_folha 
        LET p_fval_parc_Efe      = p_fval_parc_Efe + p_lista.val_parc_folha 
      ELSE
        LET p_lista.val_parc_Efe = NULL 
      END IF	 

    	IF p_lista.dat_acerto_prev > p_Dat_referencia THEN
        LET p_lista.val_parc_Acer = p_lista.val_parc_folha 
        LET p_val_parc_Acer       = p_val_parc_Acer + p_lista.val_parc_folha 
        LET p_fval_parc_Acer      = p_fval_parc_Acer + p_lista.val_parc_folha 
      ELSE
        LET p_lista.val_parc_Acer = NULL 
      END IF	 

      IF p_lista.dat_acerto_prev IS NULL THEN
        LET p_lista.val_parc_Nao = p_lista.val_parc_folha 
        LET p_val_parc_Nao       = p_val_parc_Nao + p_lista.val_parc_folha 
        LET p_fval_parc_Nao      = p_fval_parc_Nao + p_lista.val_parc_folha 
      ELSE
        LET p_lista.val_parc_Nao = NULL 
      END IF	


    	OUTPUT TO REPORT pol1075_resumo(p_lista.dat_referencia) 
      
      LET p_count = p_count + 1
      INITIALIZE p_lista TO NULL
                 
   END FOREACH




END FUNCTION

#--------------------------------#
FUNCTION pol1075_emite_relatorio()
#--------------------------------#

   FOR p_num_seq = 1 TO 5
    LET p_txt[p_num_seq].txt = NULL
   END FOR
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_negrito     = ascii 27, "E"
   LET p_normal      = ascii 27, "F"
   LET p_count = 0 
   LET p_Data_char      = "01/",p_tela.mesano
   LET p_data           = p_Data_char
   LET p_Dat_referencia = p_Data
   IF p_tela.mesano[1,2] = '99' THEN
   	LET p_Ano            = p_Data_char[7,10]
   	LET p_Data_char      = "01/01/",p_Ano
   	LET p_data           = p_Data_char
   	LET p_Dat_referencia = p_Data
   	LET p_Data_char      = "01/12/",p_Ano
   	LET p_data           = p_Data_char
   	LET p_Dat_ref_final  = p_Data
   END IF	
   LET p_Data_char      = "01/",p_tela.mesano_acerto
   LET p_data           = p_Data_char
   LET p_Dat_ref_acerto = p_Data
   IF p_tela.mesano_acerto[1,2] = '99' THEN
   	LET p_Ano            = p_Data_char[7,10]
   	LET p_Data_char      = "01/01/",p_Ano
   	LET p_data           = p_Data_char
   	LET p_Dat_ref_acerto = p_Data
   	LET p_Data_char      = "01/12/",p_Ano
   	LET p_data           = p_Data_char
   	LET p_Dat_ref_acerfim = p_Data
   END IF	
   
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
   SELECT nom_banco   
      INTO p_nom_banco
   FROM bancos 
   WHERE cod_banco = p_cod_banco

#----------------------------- IMPRIMINDO LISTA --------------------------#
   LET p_sql = 
      "SELECT b.dat_referencia, b.tip_acerto,b.num_cpf,b.nom_funcionario,b.val_acerto, ",
      " b.num_matricula, b.cod_empresa, e.uni_feder, b.dat_acerto_prev, b.val_acerto, b.dat_acerto_real, b.observacao ",
      " FROM diverg_consig_265 b ",
      "   LEFT JOIN empresa e ",
      "   ON e.cod_empresa = b.cod_empresa "

   LET p_sql = p_sql CLIPPED, ' '," WHERE b.cod_banco =  ",p_tela.cod_banco," "
   
   IF p_tela.mesano <> '99/9999' AND p_tela.mesano_acerto <> '99/9999' THEN
   		IF p_tela.mesano[1,2] <> '99' AND p_tela.mesano_acerto[1,2] <> '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND (b.dat_referencia = '",p_Dat_referencia,"' or b.dat_acerto_prev = '",p_Dat_ref_acerto,"')" 
      	LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   			LET p_filtro = p_filtro CLIPPED, " MÊS/ANO ACERTO: ",p_tela.mesano_acerto
   		END IF
   		IF p_tela.mesano[1,2] = '99' AND p_tela.mesano_acerto[1,2] = '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND ((b.dat_referencia >= '",p_Dat_referencia,"' and b.dat_referencia <= '",p_Dat_ref_final,"') or (b.dat_acerto_prev >= '",p_Dat_ref_acerto,"' and b.dat_acerto_prev <= '",p_Dat_ref_acerfim,"'))" 
      	LET p_filtro = "ANO: ",p_Ano
   			LET p_filtro = p_filtro CLIPPED, " ANO ACERTO: ",p_Ano
   		END IF   
   		IF p_tela.mesano[1,2] <> '99' AND p_tela.mesano_acerto[1,2] = '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND (b.dat_referencia = '",p_Dat_referencia,"'  AND (b.dat_acerto_prev >= '",p_Dat_ref_acerto,"' and b.dat_acerto_prev <= '",p_Dat_ref_acerfim,"'))" 
      	LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   			LET p_filtro = p_filtro CLIPPED, " ANO ACERTO: ",p_Ano
   		END IF   
   		IF p_tela.mesano[1,2] = '99' AND p_tela.mesano_acerto[1,2] <> '99' THEN
   			LET p_sql = p_sql CLIPPED, ' ', "   AND ((b.dat_referencia >= '",p_Dat_referencia,"' and b.dat_referencia <= '",p_Dat_ref_final,"') and  b.dat_acerto_prev = '",p_Dat_ref_acerto,"')"
      	LET p_filtro = "ANO: ",p_Ano
   			LET p_filtro = p_filtro CLIPPED, " MÊS/ANO ACERTO: ",p_tela.mesano_acerto
   		END IF   
   	END IF	   

   	IF p_tela.mesano[1,2] <> '99' AND p_tela.mesano_acerto IS NULL THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND (b.dat_referencia = '",p_Dat_referencia,"' and  b.dat_acerto_prev IS NULL)"
      LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   		LET p_filtro = p_filtro CLIPPED, " SEM ACERTO "
   	END IF   
   	IF p_tela.mesano[1,2] = '99' AND p_tela.mesano_acerto IS NULL THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND ((b.dat_referencia >= '",p_Dat_referencia,"' and b.dat_referencia <= '",p_Dat_ref_final,"') AND b.dat_acerto_prev IS NULL)"
      LET p_filtro = "ANO: ",p_Ano
   		LET p_filtro = p_filtro CLIPPED, " SEM ACERTO "
   	END IF

    IF p_tela.mesano = '99/9999' AND p_tela.mesano_acerto = '99/9999' THEN
      LET p_filtro = "MÊS/ANO: TODOS"
   		LET p_filtro = p_filtro CLIPPED, " MÊS/ANO ACERTO: TODOS "
	  END IF


		IF   p_tela.cod_uf <> '99' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND e.uni_feder = '",p_tela.cod_uf,"' "
    END IF

		IF   p_tela.cod_setor <> '99' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.cod_empresa = '",p_tela.cod_setor,"' "
    END IF

		IF   p_tela.cod_tipo <> '0' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.tip_acerto = ",p_tela.cod_tipo
    END IF

		IF   p_tela.cod_tipo = '0' THEN
      LET p_filtro = p_filtro CLIPPED, " TIPO: TODOS"
    END IF

		IF   p_tela.cod_func <> '                  ' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.num_cpf = '",p_tela.cod_func,"'"
    END IF

   LET p_sql = p_sql CLIPPED, ' ', " ORDER by b.dat_referencia,b.dat_acerto_prev, b.cod_empresa, e.uni_feder, b.nom_funcionario"

   PREPARE var_query FROM p_sql   
   DECLARE cq_padrao CURSOR FOR var_query


   FOREACH cq_padrao INTO 
      p_lista.dat_referencia, p_lista.tipo_acerto,
      p_lista.cpf_func, p_lista.nom_funcionario, 
      p_lista.val_parc_banco, p_lista.num_matricula,
      p_lista.empresa, p_lista.uni_feder, 
      p_lista.dat_acerto_prev, p_lista.val_parc_folha,
      p_lista.dat_acerto_real, p_lista.observacao
      
      CASE p_lista.tipo_acerto[1,1]    
         WHEN '1'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Descontado' 
         WHEN '2'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Reembolsado' 
         WHEN '3'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Repassado' 
         WHEN '4'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Em prejuízo' 
         WHEN '5'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Em dúvida' 
         WHEN '7'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Liquidado' 
      END CASE
       
      
			IF   p_tela.cod_tipo <> '0' THEN
      	LET p_filtro = p_filtro CLIPPED, " TIPO: ",p_lista.tipo_acerto
    	END IF

      IF p_lista.observacao IS NOT NULL THEN
        CALL substrivo(p_lista.observacao[1,225],34,5,'N') 
        	RETURNING p_txt[1].txt,p_txt[2].txt,p_txt[3].txt,p_txt[4].txt,
                    p_txt[5].txt

      END IF
   OUTPUT TO REPORT pol1075_relat(p_lista.dat_referencia) 
      
   LET p_count = p_count + 1
   INITIALIZE p_lista TO NULL
                 
   END FOREACH


END FUNCTION



#--------------------------------#
 REPORT pol1075_relat(p_ordem_imp)                              
#--------------------------------# 

	DEFINE 	p_ordem_imp				CHAR(7)
   
	OUTPUT LEFT   MARGIN 0
	TOP    				MARGIN 0
	BOTTOM 				MARGIN 3

	FORMAT
	
	PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------
	
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
                           
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 124, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 001, "pol1075",
               COLUMN 057, "RELATORIO DE OBSERVAÇÕES DA CONCILIAÇÃO",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
         PRINT COLUMN 050, "(((((((((( LISTA ))))))))))"  
               
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, 'MÊS/ANO|      TIPO       |UF|SETOR| MATRICULA |         CPF       |             NOME/OBSERVACAO            |    VALOR   |ACERTO EM'
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '-------|-----------------|--|-----|-----------|-------------------|----------------------------------------|------------|---------'
				
	 BEFORE GROUP OF p_ordem_imp 	#------------GRUPO----------
         LET p_cab_gru = 'MÊS/ANO: '
         LET p_cod_gru = p_lista.dat_acerto_prev 

         PRINT COLUMN 001, '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||'
         PRINT COLUMN 001, p_cab_gru, MONTH(p_lista.dat_referencia) USING '&#','/',YEAR(p_lista.dat_referencia) USING '####'
         
         PRINT COLUMN 001, '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||'
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, MONTH(p_lista.dat_referencia) USING '&#','/',YEAR(p_lista.dat_referencia) USING '####', 
               COLUMN 008,'|',
               COLUMN 009, p_lista.tipo_acerto, 
               COLUMN 026,'|',
               COLUMN 027, p_lista.uni_feder, 
               COLUMN 029,'|',
               COLUMN 032, p_lista.empresa, 
               COLUMN 035,'|',
               COLUMN 037, p_lista.num_matricula USING '######', 
               COLUMN 047,'|',
               COLUMN 048, p_lista.cpf_func[1,19], 
               COLUMN 067,'|',
               COLUMN 068, p_lista.nom_funcionario[1,40],
               COLUMN 108,'|',
               COLUMN 109, p_lista.val_parc_banco USING '###,##&.&&', 
               COLUMN 121,'|',
               COLUMN 122, MONTH(p_lista.dat_acerto_prev) USING '&#','/',YEAR(p_lista.dat_acerto_prev) USING '####' 
   			 FOR p_num_seq = 1 TO 5
         	 IF p_txt[p_num_seq].txt IS NULL THEN
           ELSE
         	 	 PRINT COLUMN 008,'|',
                   COLUMN 026,'|',
                   COLUMN 029,'|',
                   COLUMN 035,'|',
                   COLUMN 047,'|',
                   COLUMN 067,'|',
                   COLUMN 068, p_txt[p_num_seq].txt,
                   COLUMN 108,'|',
                   COLUMN 121,'|'
           END IF      
         END FOR
         PRINT COLUMN 008,'|',
               COLUMN 026,'|',
               COLUMN 029,'|',
               COLUMN 035,'|',
               COLUMN 047,'|',
               COLUMN 067,'|',
               COLUMN 068, p_lista.tipo_acerto,
               COLUMN 083, " de R$ ",p_lista.val_parc_folha USING '###,##&.&&',
               COLUMN 108,'|',
               COLUMN 121,'|'
               
         PRINT COLUMN 001, '-------|-----------------|--|-----|-----------|-------------------|----------------------------------------|------------|---------'
					

END REPORT

#--------------------------------#
 REPORT pol1075_resumo(p_ordem_imp)                              
#--------------------------------# 

	DEFINE 	p_ordem_imp				CHAR(7)
   
	OUTPUT LEFT   MARGIN 0
	TOP    				MARGIN 0
	BOTTOM 				MARGIN 3

	FORMAT

	
	PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------
	
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
                           
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 124, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 001, "pol1075",
               COLUMN 057, "RELATORIO DE OBSERVAÇÕES DA CONCILIAÇÃO",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
         PRINT COLUMN 050, "(((((((((( RESUMO ))))))))))"  
               
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, 'UF|SETOR|               NOME                     |   TIPOS   |MÊS/ANO| PREVISTOS  | EFETUADOS  | ACERTADOS  |     NÃO    '
   			 IF p_tela.mesano[1,2] = '99' THEN
         		PRINT COLUMN 001, '  |     |                                        |           |       | EM ',p_Ano[1,7],' | EM ',p_Ano[1,7],' |APÓS ',p_Ano[1,7],'|  ACERTADOS '
         ELSE
         		PRINT COLUMN 001, '  |     |                                        |           |       | EM ',p_tela.mesano,' | EM ',p_tela.mesano,' |APÓS ',p_tela.mesano,'|  ACERTADOS '
         END IF
         PRINT COLUMN 001, '--|-----|----------------------------------------|-----------|-------|------------|------------|------------|------------'
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         IF p_count > 1 THEN
      	  IF p_lista.num_matricula <> p_num_matricula THEN
            PRINT COLUMN 001, '  |     |||||||||||||||||||||||||||||||||||||||||||||||||||||| TOTAL |',
             	    COLUMN 071, p_fval_parc_Prev USING '###,##&.&&', 
                  COLUMN 083,'|',
           	 	    COLUMN 084, p_fval_parc_Efe USING '###,##&.&&',
                  COLUMN 096,'|',
                  COLUMN 097, p_fval_parc_Acer USING '###,##&.&&',
                  COLUMN 109,'|',
             	    COLUMN 110, p_fval_parc_Nao USING '###,##&.&&' 
         		PRINT COLUMN 001, '--|-----|----------------------------------------|-----------|-------|------------|------------|------------|------------'
   				   LET p_fval_parc_Prev  = 0
   				   LET p_fval_parc_Efe   = 0
   				   LET p_fval_parc_Acer  = 0
   				   LET p_fval_parc_Nao   = 0
   				   LET p_num_matricula   = p_lista.num_matricula
   				   LET p_count           = 0
      	   END IF
      	   ELSE
         END IF
         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 005, p_lista.empresa, 
               COLUMN 009,'|',
               COLUMN 010, p_lista.nom_funcionario[1,40], 
               COLUMN 050,'|',
               COLUMN 051, p_lista.tipo_acerto[1,11], 
               COLUMN 062,'|',
               COLUMN 063, MONTH(p_lista.dat_referencia) USING '&#','/',YEAR(p_lista.dat_referencia) USING '####', 
               COLUMN 070,'|',
             	 COLUMN 071, p_lista.val_parc_Prev USING '###,##&.&&', 
               COLUMN 083,'|',
           	 	 COLUMN 084, p_lista.val_parc_Efe USING '###,##&.&&',
               COLUMN 096,'|',
               COLUMN 097, p_lista.val_parc_Acer USING '###,##&.&&',
               COLUMN 109,'|',
             	 COLUMN 110, p_lista.val_parc_Nao USING '###,##&.&&' 
         PRINT COLUMN 001, '--|-----|----------------------------------------|-----------|-------|------------|------------|------------|------------'
      ON LAST ROW 
         PRINT COLUMN 001, '  |     |||||||||||||||||||||||||||||||||||||||||||||||||||||| TOTAL |',
             	 COLUMN 071, p_val_parc_Prev USING '###,##&.&&', 
               COLUMN 083,'|',
           	 	 COLUMN 084, p_val_parc_Efe USING '###,##&.&&',
               COLUMN 096,'|',
               COLUMN 097, p_val_parc_Acer USING '###,##&.&&',
               COLUMN 109,'|',
             	 COLUMN 110, p_val_parc_Nao USING '###,##&.&&' 
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
					

END REPORT


#--------------------------------#
 REPORT pol1075_total(p_ordem_imp)                              
#--------------------------------# 

	DEFINE 	p_ordem_imp				CHAR(7)
   
	OUTPUT LEFT   MARGIN 0
	TOP    				MARGIN 0
	BOTTOM 				MARGIN 3

	FORMAT
	
	
	PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------
	
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 124, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 001, "pol1075",
               COLUMN 057, "RELATORIO DE OBSERVAÇÕES DA CONCILIAÇÃO",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
         PRINT COLUMN 040, "(((((((((( T O T A L I Z A D O R ))))))))))"  
         PRINT
               
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 007, "+--------------------------------------+"
         PRINT COLUMN 007, "|  ACERTOS PREVISTOS PARA",              
               COLUMN 033, p_tela.mesano,             
               COLUMN 046, "|"
         PRINT COLUMN 007,       "+--------------------------------------+   +------------+   +------------+        +----------------------------+"
         PRINT COLUMN 007,       "|DESCONTADOS |REEMBOLSADOS| REPASSADOS |---|EM PREJUIZOS|---| EM DUVIDAS |        | Totaliza todos os valores  |"
         PRINT COLUMN 001, "+-----|------------|------------|------------|   |------------|   |------------|        | PREVISTO para ",p_tela.mesano,
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
               COLUMN 118, "|"
				
#	ON EVERY ROW			#---ITENS ---
	       #--------- Previsto ----------
         PRINT COLUMN 001, "| QTD |",
        	   	 COLUMN 011, p_total.p_count_desc_prev USING '#####',
          	   COLUMN 020, "|", 
          	   COLUMN 024, p_total.p_count_reem_prev USING '#####',
          	   COLUMN 033, "|", 
          	   COLUMN 037, p_total.p_count_repa_prev USING '#####',
          	   COLUMN 046, "|", 
          	   COLUMN 050, "|", 
        	   	 COLUMN 054, p_total.p_count_prej_prev USING '#####',
          	   COLUMN 063, "|", 
          	   COLUMN 067, "|", 
          	   COLUMN 071, p_total.p_count_duvi_prev USING '#####',
          	   COLUMN 080, "|", 
               COLUMN 089, "+----------------------------+"
         PRINT COLUMN 001, "|-----|------------|------------|------------|   |------------|   |------------|"        

         PRINT COLUMN 001, "|VALOR|",
          	   COLUMN 009, p_total.p_val_desc_prev USING '###,##&.&&',
          	   COLUMN 020, "|", 
          	   COLUMN 021, p_total.p_val_reem_prev USING '###,##&.&&',
          	   COLUMN 033, "|", 
          	   COLUMN 034, p_total.p_val_repa_prev USING '###,##&.&&',
          	   COLUMN 046, "|", 
          	   COLUMN 050, "|", 
          	   COLUMN 051, p_total.p_val_prej_prev USING '###,##&.&&',
          	   COLUMN 063, "|", 
          	   COLUMN 067, "|", 
          	   COLUMN 068, p_total.p_val_duvi_prev USING '###,##&.&&',
          	   COLUMN 080, "|" 
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, "+-----+------+-----+------+-----+-----+------+   +------+-----+   +-----+------+ "
         PRINT COLUMN 007, "|",
        	   	 COLUMN 014, "|", 
        	   	 COLUMN 027, "|", 
        	   	 COLUMN 039, "|", 
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|" 
{         PRINT COLUMN 001, "+-----+------+-----+------+-----+-----+------+",
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|" }
         PRINT COLUMN 007, "+------+------------+-----------+------+"
         PRINT COLUMN 007, "| ACERTOS EFETUADOS EM",              
               COLUMN 033, p_tela.mesano,             
               COLUMN 046, "|",
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|" 
         PRINT COLUMN 007,       "+--------------------------------------+",
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|", 
        	   	 COLUMN 089, "+----------------------------+"
         PRINT COLUMN 007,       "|DESCONTADOS |REEMBOLSADOS| REPASSADOS |",
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|", 
        	   	 COLUMN 089, "| Totaliza todos os valores  |"
         PRINT COLUMN 001, "+-----|------------+------------+------------|",
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|", 
        	   	 COLUMN 089, "| Acertados para ",p_tela.mesano,
               COLUMN 118, "|"
	       #--------- Efetuados ----------
         PRINT COLUMN 001, "| QTD |",
          	   COLUMN 011, p_total.p_count_desc_efe USING '#####',
          	   COLUMN 020, "|", 
          	   COLUMN 024, p_total.p_count_reem_efe USING '#####',
          	   COLUMN 033, "|", 
          	   COLUMN 037, p_total.p_count_repa_efe USING '#####',
          	   COLUMN 046, "|", 
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|", 
               COLUMN 089, "+----------------------------+"
         PRINT COLUMN 001, "|-----|------------|------------|------------|",        
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|" 
         PRINT COLUMN 001, "|VALOR|",
          	   COLUMN 010, p_total.p_val_desc_efe USING '###,##&.&&',
          	   COLUMN 020, "|", 
          	   COLUMN 023, p_total.p_val_reem_efe USING '###,##&.&&',
          	   COLUMN 033, "|", 
          	   COLUMN 036, p_total.p_val_repa_efe USING '###,##&.&&',
          	   COLUMN 046, "|", 
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|" 
         PRINT COLUMN 001, "+-----+------+-----+------+-----+-----+------+",
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|" 
         PRINT COLUMN 007, "|",
        	   	 COLUMN 014, "|", 
        	   	 COLUMN 027, "|", 
        	   	 COLUMN 039, "|", 
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|" 
         PRINT COLUMN 007, "|",
        	   	 COLUMN 014, "|", 
        	   	 COLUMN 027, "|", 
        	   	 COLUMN 039, "|", 
        	   	 COLUMN 057, "|", 
        	   	 COLUMN 073, "|" 

	       #--------- Diferença ----------
         PRINT COLUMN 007,       "+--------------------------------------+   +------------+   +------------+        +----------------------------+"
         PRINT COLUMN 007,       "| TOTAL A    |  TOTAL A   |  TOTAL A   |   |    TOTAL   |   |   TOTAL    |        | Total de DIFERENCAS entre  |"
         PRINT COLUMN 007,       "| DESCONTAR  | REEMBOLSAR |  REPASSAR  |---|EM PREJUIZOS|---| EM DUVIDAS |        | o PREVISTO com o EFETUADO  |"
         PRINT COLUMN 001, "+-----|------------+------------+------------|   |------------|   |------------|        |          em ",p_tela.mesano,
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
               COLUMN 118, "|"
				
         PRINT COLUMN 001, "| QTD |",
        	   	 COLUMN 011, p_total.p_count_desc_dif USING '#####',
          	   COLUMN 020, "|", 
          	   COLUMN 024, p_total.p_count_reem_dif USING '#####',
          	   COLUMN 033, "|", 
          	   COLUMN 037, p_total.p_count_repa_dif USING '#####',
          	   COLUMN 046, "|", 
          	   COLUMN 050, "|", 
        	   	 COLUMN 054, p_total.p_count_prej_prev USING '#####',
          	   COLUMN 063, "|", 
          	   COLUMN 067, "|", 
          	   COLUMN 071, p_total.p_count_duvi_prev USING '#####',
          	   COLUMN 080, "|", 
               COLUMN 089, "+----------------------------+"
         PRINT COLUMN 001, "|-----|------------|------------|------------|   |------------|   |------------|"        

         PRINT COLUMN 001, "|VALOR|",
          	   COLUMN 009, p_total.p_val_desc_dif USING '###,##&.&&',
          	   COLUMN 020, "|", 
          	   COLUMN 021, p_total.p_val_reem_dif USING '###,##&.&&',
          	   COLUMN 033, "|", 
          	   COLUMN 034, p_total.p_val_repa_dif USING '###,##&.&&',
          	   COLUMN 046, "|", 
          	   COLUMN 050, "|", 
          	   COLUMN 051, p_total.p_val_prej_prev USING '###,##&.&&',
          	   COLUMN 063, "|", 
          	   COLUMN 067, "|", 
          	   COLUMN 068, p_total.p_val_duvi_prev USING '###,##&.&&',
          	   COLUMN 080, "|" 
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, "+-----+------------+------------+------------+   +------------+   +------------+"        

	       #--------- Posteriores ----------
	       PRINT
	       PRINT
         PRINT COLUMN 007,       "+--------------------------------------+   +------------+   +------------+        +----------------------------+"
         PRINT COLUMN 007,       "| TOTAL A    |  TOTAL A   |  TOTAL A   |   |    TOTAL   |   |   TOTAL    |        | Totaliza TODOS os Valores  |"
         PRINT COLUMN 007,       "| DESCONTAR  | REEMBOLSAR |  REPASSAR  |---|EM PREJUIZOS|---| EM DUVIDAS |        | Acertados depois           |"
         PRINT COLUMN 001, "+-----|------------+------------+------------|   |------------|   |------------|        |          de ",p_tela.mesano,
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
               COLUMN 118, "|"
				
         PRINT COLUMN 001, "| QTD |",
        	   	 COLUMN 011, p_total.p_count_desc_acer USING '#####',
          	   COLUMN 020, "|", 
          	   COLUMN 024, p_total.p_count_reem_acer USING '#####',
          	   COLUMN 033, "|", 
          	   COLUMN 037, p_total.p_count_repa_acer USING '#####',
          	   COLUMN 046, "|", 
          	   COLUMN 050, "|", 
        	   	 COLUMN 054, p_total.p_count_prej_acer USING '#####',
          	   COLUMN 063, "|", 
          	   COLUMN 067, "|", 
          	   COLUMN 071, p_total.p_count_duvi_acer USING '#####',
          	   COLUMN 080, "|", 
               COLUMN 089, "+----------------------------+"

         PRINT COLUMN 001, "|-----|------------|------------|------------|   |------------|   |------------|"        
         PRINT COLUMN 001, "|VALOR|",
          	   COLUMN 009, p_total.p_val_desc_acer USING '###,##&.&&',
          	   COLUMN 020, "|", 
          	   COLUMN 021, p_total.p_val_reem_acer USING '###,##&.&&',
          	   COLUMN 033, "|", 
          	   COLUMN 034, p_total.p_val_repa_acer USING '###,##&.&&',
          	   COLUMN 046, "|", 
          	   COLUMN 050, "|", 
          	   COLUMN 051, p_total.p_val_prej_acer USING '###,##&.&&',
          	   COLUMN 063, "|", 
          	   COLUMN 067, "|", 
          	   COLUMN 068, p_total.p_val_duvi_acer USING '###,##&.&&',
          	   COLUMN 080, "|" 
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, "+-----+------+-----+------+-----+-----+------+   +------+-----+   +-----+------+ "
         PRINT	   	  
         PRINT COLUMN 001, "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| "
         PRINT
         PRINT	   	  
        
	       #--------- Pendentes ----------
         PRINT COLUMN 007, "+======================================+"
         PRINT COLUMN 007, "|  EM ABERTO - SEM PREVISAO DE ACERTO",   
               COLUMN 046, "|"
         PRINT COLUMN 007,       "+======================================+   +============+   +============+        +============================+"
         PRINT COLUMN 007,       "| TOTAL A    |  TOTAL A   |  TOTAL A   |   |    TOTAL   |   |   TOTAL    |        |         ATENCAO!!!         |"
         PRINT COLUMN 007,       "| DESCONTAR  | REEMBOLSAR |  REPASSAR  |---|EM PREJUIZOS|---| EM DUVIDAS |        | Se existir valores, existe |"
         PRINT COLUMN 001, "+=====|============+============+============|   |============|   |============|        | inconsistencias para serem |"
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
				
         PRINT COLUMN 001, "| QTD |",
        	   	 COLUMN 011, p_total.p_count_desc_nao USING '#####',
          	   COLUMN 020, "|", 
          	   COLUMN 024, p_total.p_count_reem_nao USING '#####',
          	   COLUMN 033, "|", 
          	   COLUMN 037, p_total.p_count_repa_nao USING '#####',
          	   COLUMN 046, "|", 
          	   COLUMN 050, "|", 
        	   	 COLUMN 054, p_total.p_count_prej_nao USING '#####',
          	   COLUMN 063, "|", 
          	   COLUMN 067, "|", 
          	   COLUMN 071, p_total.p_count_duvi_nao USING '#####',
          	   COLUMN 080, "|", 
               COLUMN 089, "| resolvidas. Acertar TUDO,  |"

         PRINT COLUMN 001, "|-----|------------|------------|------------|   |------------|   |------------|",        
               COLUMN 089, "| para FECHAR ",p_tela.mesano,
               COLUMN 118, "|"
         PRINT COLUMN 001, "|VALOR|",
          	   COLUMN 009, p_total.p_val_desc_nao USING '###,##&.&&',
          	   COLUMN 020, "|", 
          	   COLUMN 021, p_total.p_val_reem_nao USING '###,##&.&&',
          	   COLUMN 033, "|", 
          	   COLUMN 034, p_total.p_val_repa_nao USING '###,##&.&&',
          	   COLUMN 046, "|", 
          	   COLUMN 050, "|", 
          	   COLUMN 051, p_total.p_val_prej_nao USING '###,##&.&&',
          	   COLUMN 063, "|", 
          	   COLUMN 067, "|", 
          	   COLUMN 068, p_total.p_val_duvi_nao USING '###,##&.&&',
          	   COLUMN 080, "|", 
               COLUMN 089, "+============================+"
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, "+============+============+===========+======+   +============+   +============+ "
         PRINT	   	  
         PRINT COLUMN 001, "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| "
		

END REPORT

#-----------------------#
 FUNCTION pol1075_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
#---------------------------#
 FUNCTION substrivo(parametro)
#---------------------------#

   DEFINE parametro  RECORD 
          texto      VARCHAR(3000),
          tam_linha  SMALLINT,
          qtd_linha  SMALLINT,
          justificar CHAR(01)
   END RECORD
         
   LET texto      = parametro.texto CLIPPED
   LET tam_linha  = parametro.tam_linha
   LET qtd_linha  = parametro.qtd_linha
   LET justificar = parametro.justificar
   
   CALL limpa_retorno()
   
   IF NOT checa_parametros() THEN
      LET r_01 = 'ERRO ENVIO PARAMETRO'
   ELSE
      CALL separa_texto()
   END IF
   
   CASE qtd_linha

      WHEN  1 RETURN r_01
      WHEN  2 RETURN r_01,r_02
      WHEN  3 RETURN r_01,r_02,r_03
      WHEN  4 RETURN r_01,r_02,r_03,r_04
      WHEN  5 RETURN r_01,r_02,r_03,r_04,r_05
      WHEN  6 RETURN r_01,r_02,r_03,r_04,r_05,r_06
      WHEN  7 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07
      WHEN  8 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08
      WHEN  9 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09
      WHEN 10 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10
      WHEN 11 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11
      WHEN 12 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12
      WHEN 13 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12,r_13
      WHEN 14 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12,r_13,r_14
      WHEN 15 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12,r_13,r_14,r_15

   END CASE
   
   
END FUNCTION 


#--------------------------------#
 FUNCTION limpa_retorno()
#--------------------------------#

   INITIALIZE r_01, r_02, r_03, r_04, r_05, r_06, r_07, r_08, r_09, r_10,
              r_11, r_12, r_13, r_14, r_15 TO NULL 
              
END FUNCTION

#---------------------------#
 FUNCTION checa_parametros()
#---------------------------#

   IF texto IS NULL THEN
      RETURN FALSE
   END IF
   
   IF tam_linha IS NULL THEN
      RETURN FALSE
   ELSE
      IF tam_linha < 20 OR tam_linha > 200 THEN
         RETURN FALSE
      END IF 
   END IF

   IF qtd_linha IS NULL THEN
      RETURN FALSE
   ELSE
      IF qtd_linha < 1 OR qtd_linha > 15 THEN
         RETURN FALSE
      END IF 
   END IF

   IF justificar IS NULL THEN
      RETURN FALSE
   ELSE
      IF justificar <> 'S' AND justificar <> 'N' THEN
         RETURN FALSE
      END IF 
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------------------#
 FUNCTION separa_texto()
#-----------------------#
          
   LET r_01 = quebra_texto()
   LET r_02 = quebra_texto()
   LET r_03 = quebra_texto()
   LET r_04 = quebra_texto()
   LET r_05 = quebra_texto()
   LET r_06 = quebra_texto()
   LET r_07 = quebra_texto()
   LET r_08 = quebra_texto()
   LET r_09 = quebra_texto()
   LET r_10 = quebra_texto()
   LET r_11 = quebra_texto()
   LET r_12 = quebra_texto()
   LET r_13 = quebra_texto()
   LET r_14 = quebra_texto()
   LET r_15 = quebra_texto()
      
              
END FUNCTION

#----------------------#
FUNCTION quebra_texto()
#----------------------#

   DEFINE ind SMALLINT,
          p_des_texto CHAR(200)

   LET num_carac = LENGTH(texto)
   IF num_carac = 0 THEN
      RETURN ''
   END IF
   
   IF num_carac <= tam_linha THEN
      LET p_des_texto = texto
      INITIALIZE texto TO NULL
      RETURN(p_des_texto)
   END IF

   FOR ind = tam_linha+1 TO 1 step -1
      IF texto[ind] = ' ' then
         LET ret = texto[1,ind-1]
         LET texto = texto[ind+1,num_carac]
         EXIT FOR
      END IF
   END FOR 

   LET ret = ret CLIPPED
   IF justificar = 'S' THEN
      IF LENGTH(ret) < tam_linha THEN
         CALL justifica()
      END IF
   END IF 
              
   RETURN(ret)
   
END FUNCTION

#-------------------#
FUNCTION justifica()
#-------------------#

   DEFINE ind, y, p_branco, p_tam, p_tem_branco SMALLINT
   DEFINE p_tex VARCHAR(200)
   
   LET y = 1
   LET p_branco = tam_linha - LENGTH(ret)

   WHILE p_branco > 0   
      LET p_tam = LENGTH(ret)
      LET p_tem_branco = FALSE
      FOR ind = y TO p_tam
         IF ret[ind] = ' ' THEN
            LET p_tem_branco = TRUE
            LET p_tex = ret[1,ind],' ',ret[ind+1,p_tam]
            LET p_branco = p_branco - 1
            LET ret = p_tex
            LET y = ind + 2
            WHILE ret[y] = ' '
               LET y = y + 1
            END WHILE
            IF y >= LENGTH(ret) THEN
               LET y = 1
            END IF
            EXIT FOR
         END IF
      END FOR
      IF NOT p_tem_branco THEN
         LET y = 1
      END IF
   END WHILE 
      
END FUNCTION




 
#-------------------------------- FIM DE PROGRAMA -----------------------------#
