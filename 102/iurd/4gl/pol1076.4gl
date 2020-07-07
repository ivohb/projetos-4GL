#-------------------------------------------------------------------------#
# SISTEMA.: Relaçao Mensal Descontos	                		          #
#	PROGRAMA:	pol1076											 	      #
#	CLIENTE.:	IURD										              #
#	OBJETIVO:	Rel. Mensal de Descontos                                  #
#	AUTOR...:	Paulo		  											  #
#	DATA....:	10/12/2010		 									      #
#-------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa         LIKE empresa.cod_empresa,
          p_den_empresa         LIKE empresa.den_empresa,
          p_user                LIKE usuario.nom_usuario,
          p_cod_banco           LIKE bancos.cod_banco,
          p_nom_banco           LIKE bancos.nom_banco,
          p_cod_evento          LIKE evento_265.cod_evento,
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
          p_sql                 CHAR(900),
          p_last_row            SMALLINT,
          p_Comprime            CHAR(01),
          p_descomprime         CHAR(01),
          p_negrito             CHAR(02),
          p_normal              CHAR(02),
          p_ordem               CHAR(10),
          p_repetiu             SMALLINT,
          p_filtro              CHAR(120),
          p_Val_total_rep       DECIMAL(12,2),
          p_Val_total           DECIMAL(12,2),
          p_Val_total_Demi      DECIMAL(12,2),
          p_count_demi          SMALLINT,
          p_Val_total_inss      DECIMAL(12,2),
          p_count_inss          SMALLINT,
          p_Val_total_liq       DECIMAL(12,2),
          p_Val_total_30        DECIMAL(12,2),
          p_Val_rep             DECIMAL(12,2),
          p_Data_char           CHAR(10),
          p_data                DATE,
          p_Dat_referencia      DATE,
          p_count_liq           SMALLINT,
          p_count_rep           SMALLINT,
          p_estado              CHAR(2),
          p_gVal_total_rep       DECIMAL(12,2),
          p_gVal_total           DECIMAL(12,2),
          p_gVal_total_Demi      DECIMAL(12,2),
          p_gcount               SMALLINT,
          p_gcount_demi          SMALLINT,
          p_gVal_total_inss      DECIMAL(12,2),
          p_gcount_inss          SMALLINT,
          p_gVal_total_liq       DECIMAL(12,2),
          p_gVal_total_30        DECIMAL(12,2),
          p_gData_char           CHAR(10),
          p_gdata                DATE,
          p_gDat_referencia      DATETIME YEAR TO MONTH,
          p_gcount_liq           SMALLINT,
          p_gcount_rep           SMALLINT,
          p_cod_uf_r             CHAR(2),
          p_rVal_total_rep       DECIMAL(12,2),
          p_rVal_total           DECIMAL(12,2),
          p_rVal_total_Demi      DECIMAL(12,2),
          p_rcount               SMALLINT,
          p_rcount_demi          SMALLINT,
          p_rVal_total_inss      DECIMAL(12,2),
          p_rcount_inss          SMALLINT,
          p_rVal_total_liq       DECIMAL(12,2),
          p_rVal_total_30        DECIMAL(12,2),
          p_gVal_afasta          DECIMAL(12,2),
          p_rData_char           CHAR(10),
          p_rdata                DATE,
          p_rDat_referencia      DATETIME YEAR TO MONTH,
          p_rcount_liq           SMALLINT,
          p_rcount_rep           SMALLINT,
          p_demissao             CHAR(40),
          p_motivo               CHAR(1),
          p_motivo_c             CHAR(1),
          pa_curr                SMALLINT,
          sc_curr                SMALLINT,
          p_where                CHAR(200),
      	  p_seleciona            CHAR(200),
          p_ano_mes_ref          CHAR(07)
          
               
   DEFINE p_tela                RECORD 
          cod_banco             LIKE bancos.cod_banco,
          nom_banco             LIKE bancos.nom_banco,
          mesano                CHAR(7),
          cod_uf                LIKE uni_feder.cod_uni_feder,
          cod_setor             LIKE empresa.cod_empresa,
          classifica            CHAR(1)
   END RECORD
          
           
   DEFINE pr_campos             ARRAY[11] OF RECORD
          posicao               INTEGER,
          tamanho               INTEGER
   END RECORD
   
   DEFINE p_lista RECORD
      ano_mes_proces            CHAR(7),
      cpf_func                  CHAR(19),
      nom_funcionario           CHAR(60),
      val_parc_folha            DECIMAL(12,2),
      val_parc_banco            DECIMAL(12,2),
      num_contrato              CHAR(12),
      cod_empresa               CHAR(2),
      uni_feder                 CHAR(2),
      dat_renovacao             DATE,
      dat_liquidacao            DATE,
      num_matricula             DECIMAL(8,0),
      num_parcela               DECIMAL(3,0),
      prazo                     DECIMAL(3,0),
      Tipo                      CHAR(9),
      dat_demissao              DATE,
      dat_contrato              DATE,
      dat_afastamento           DATE,
      valor_30                  DECIMAL(12,2),
      cod_tip_contr             CHAR(1),
      cod_status                CHAR(1),
      motivo                    CHAR(20)
      
   END RECORD 

   DEFINE ma_tela ARRAY[50] OF RECORD
           empresa         	LIKE empresa.cod_empresa,
           den_empresa        LIKE empresa.den_empresa
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
	 LET p_versao = "pol1076-10.02.07"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1076.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = 0
   
   IF p_status = 0  THEN
      CALL pol1076_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1076_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1076") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1076 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
         
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Listagem"
         HELP 001 
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol1076","IN")  THEN
         		LET p_count = 0
            IF pol1076_informar() THEN
            	MESSAGE "Parâmetros informados com sucesso !!!" ATTRIBUTE(REVERSE)
              LET p_ies_cons = TRUE
              NEXT OPTION "Listar"
            ELSE
              ERROR "Operação Cancelada !!!"
              NEXT OPTION "Fim"
            END IF
         END IF 
      COMMAND "Listar" "Relação Mensal de Descontos"
         HELP 002
         LET p_count = 0
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol1076","MO") THEN
           IF p_ies_cons THEN 
               IF log0280_saida_relat(13,29) IS NOT NULL THEN
                  MESSAGE " Processando a Extracao do Relatorio..." 
                     ATTRIBUTE(REVERSE)
                     
                  IF p_ies_impressao = "S" THEN
                     IF g_ies_ambiente = "U" THEN
                        START REPORT pol1076_relat TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1076.tmp'
                        START REPORT pol1076_relat  TO p_caminho
                     END IF
                  ELSE
                     START REPORT pol1076_relat TO p_nom_arquivo
                  END IF
               
                  CALL pol1076_emite_relatorio()   
               
                  IF p_count = 0 THEN
                     ERROR "Nao Existem Dados para serem Listados" 
                  ELSE
                     ERROR "Relatorio Processado com Sucesso" 
                  END IF
               
                  FINISH REPORT pol1076_relat   

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
                        START REPORT pol1076_afasta TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1076.tmp'
                        START REPORT pol1076_afasta  TO p_caminho
                     END IF
                  ELSE
                  	 LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_2"
                     START REPORT pol1076_afasta TO p_nom_arquivo
                  END IF
                  
                  CALL pol1076_emite_afasta()   
                  
                  FINISH REPORT pol1076_afasta   

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
                        START REPORT pol1076_status TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1076.tmp'
                        START REPORT pol1076_status  TO p_caminho
                     END IF
                  ELSE
                  	 LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_3"
                     START REPORT pol1076_status TO p_nom_arquivo
                  END IF
                  
                  CALL pol1076_emite_status()   
                  
                  FINISH REPORT pol1076_status   

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
	       CALL pol1076_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1076

END FUNCTION

#--------------------------#
FUNCTION pol1076_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_tela.cod_uf     = '99'
   LET p_tela.cod_setor  = '99'
   LET p_tela.classifica = 1
 
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
         
      AFTER FIELD mesano    
      IF p_tela.mesano IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD mesano       
      END IF 
     
      IF p_tela.mesano[1,2] > '12' THEN
         ERROR "Mês incorreto"
         NEXT FIELD mesano       
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

      AFTER FIELD cod_setor
      IF p_tela.cod_setor <> '99' THEN
   		INITIALIZE p_seleciona TO NULL  
			CALL pol1076_ent_empresa('INCLUSAO') 
      END IF 

      ON KEY (control-z)
         CALL pol1076_popup()

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
FUNCTION pol1076_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)
   LET p_where = ''
   
   CASE
      WHEN INFIELD(cod_banco)
         CALL log009_popup(8,25,"Banco","bancos",
                     "cod_banco","nom_banco","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1076
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_banco = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_banco
         END IF

      WHEN INFIELD(empresa)
         IF p_tela.cod_uf    <> '99' THEN 
         	LET p_where = "uni_feder = '",p_tela.cod_uf,"'" 
         END IF
         
         CALL log009_popup(8,15,"EMPRESAS","empresa",
                     "cod_empresa","den_empresa","","N",p_where) 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1076
         IF p_codigo IS NOT NULL THEN
         	DISPLAY p_codigo to s_itens[sc_curr].empresa
#   			DISPLAY p_codigo TO ma_tela[pa_curr].empresa
          	IF p_seleciona IS NULL THEN
            LET p_seleciona = "'",p_codigo CLIPPED,"'"
          else  
            LET p_seleciona = p_seleciona clipped, ",'",p_codigo CLIPPED,"'"
          END IF
            
         END IF




   END CASE

END FUNCTION

#--------------------------------#
 FUNCTION pol1076_emite_relatorio()
#--------------------------------#


   LET p_comprime       = ascii 15
   LET p_descomprime    = ascii 18
   LET p_negrito        = ascii 27, "E"
   LET p_normal         = ascii 27, "F"
   LET p_count          = 0
   LET p_Val_total      = 0 
   LET p_count_demi     = 0
   LET p_Val_total_Demi = 0
   LET p_count_liq      = 0
   LET p_Val_total_liq  = 0
   LET p_count_inss     = 0
   LET p_Val_total_inss = 0
   LET p_Val_total_rep  = 0
   LET p_Val_total_30   = 0
   LET p_Data_char      = "01/",p_tela.mesano
   LET p_data           = p_Data_char
   LET p_Dat_referencia = p_Data

   LET p_ano_mes_ref = EXTEND(p_data, YEAR TO MONTH)
   
   LET p_gcount          = 0
   LET p_gVal_total      = 0 
   LET p_gcount_demi     = 0
   LET p_gVal_total_Demi = 0
   LET p_gcount_liq      = 0
   LET p_gVal_total_liq  = 0
   LET p_gcount_inss     = 0
   LET p_gVal_total_inss = 0
   LET p_gVal_total_rep  = 0
   LET p_gVal_total_30   = 0

   LET p_rVal_total_rep  = 0
   LET p_rVal_total      = 0
   LET p_rVal_total_Demi = 0
   LET p_rcount          = 0
   LET p_rcount_demi     = 0
   LET p_rVal_total_inss = 0
   LET p_rcount_inss     = 0
   LET p_rVal_total_liq  = 0
   LET p_rVal_total_30   = 0
   LET p_rcount_liq      = 0
   LET p_rcount_rep      = 0
   LET p_demissao        = ' '
   
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
   SELECT nom_banco   
      INTO p_nom_banco
   FROM bancos 
   WHERE cod_banco = p_cod_banco

{   SELECT cod_evento   
      INTO p_cod_evento
   FROM evento_265 
   WHERE cod_banco = p_tela.cod_banco
   AND tip_evento = 1}

#----------------------------- IMPRIMINDO RELAÇÃO --------------------------#
   LET p_sql = 
      "SELECT e.uni_feder, a.cod_empresa, a.nom_funcionario, a.num_cpf, a.num_contrato,",
      " b.qtd_parcela, a.num_parcela, a.val_parcela, b.cod_tip_contr,",
      " b.dat_liquidacao, b.dat_rescisao, b.dat_afastamento, b.valor_30, b.dat_contrato, ",
      " (SELECT sum(h.val_evento) FROM hist_movto_265 h  ",
      " WHERE h.cod_empresa = b.cod_empresa ",
      " AND h.num_cpf = b.num_cpf ",
      " AND h.dat_referencia = a.dat_referencia ",
      " AND h.cod_evento in (select ce.cod_evento from evento_265 ce where ce.cod_banco = a.cod_banco", 
      " and ce.tip_evento = 1 and ce.estado= a.uf)) AS val_evento, a.cod_status ",
      " FROM arq_banco_265 a, contr_consig_265 b ",
      " LEFT OUTER JOIN empresa e ", 
      " ON e.cod_empresa = b.cod_empresa ",
      " WHERE b.num_contrato = a.num_contrato "


   LET p_sql = p_sql CLIPPED, ' ', "   AND a.cod_banco = '",p_tela.cod_banco,"' "
   LET p_sql = p_sql CLIPPED, ' ', "   AND  to_char(a.dat_referencia, 'YYYY-MM') = '",p_ano_mes_ref,"'"

      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   
		IF   p_tela.cod_uf <> '99' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND e.uni_feder = '",p_tela.cod_uf,"' "
    END IF

		IF p_seleciona IS NOT NULL THEN
		   LET p_seleciona = "(",p_seleciona CLIPPED,")"
#   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.cod_empresa = '",p_tela.cod_setor,"' "
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.cod_empresa in ",p_seleciona
    END IF

		IF   p_tela.classifica = 1 THEN
   		LET p_sql = p_sql CLIPPED, ' ', " order by a.nom_funcionario "
   	ELSE
   		LET p_sql = p_sql CLIPPED, ' ', " order by a.num_cpf "
    END IF


   PREPARE var_query FROM p_sql   
   DECLARE cq_padrao CURSOR FOR var_query


   FOREACH cq_padrao INTO 
      p_lista.uni_feder, p_lista.cod_empresa,
      p_lista.nom_funcionario, p_lista.cpf_func,  
      p_lista.num_contrato, p_lista.prazo, 
      p_lista.num_parcela, p_lista.val_parc_banco,
      p_lista.cod_tip_contr, p_lista.dat_liquidacao,
      p_lista.dat_demissao,p_lista.dat_afastamento,
      p_lista.valor_30,p_lista.dat_contrato,
      p_lista.val_parc_folha, p_lista.cod_status
      
      LET p_lista.Tipo = "1-Normal"
      
      IF p_lista.cod_tip_contr <> '1' THEN
      	LET p_lista.tipo = "2-Renova"
      END IF	
      	
   LET p_lista.cpf_func = p_lista.cpf_func CLIPPED
   
   OUTPUT TO REPORT pol1076_relat(1) 
      
   LET p_rcount         = p_rcount + 1
   LET p_rVal_total     = p_rVal_total + p_lista.val_parc_banco
   LET p_rVal_total_rep = p_rVal_total_rep + p_lista.val_parc_banco

	 IF p_lista.dat_demissao IS NOT NULL AND p_lista.dat_demissao > p_lista.dat_contrato AND p_lista.cod_status = 'D' THEN
   	  LET p_rcount_demi     = p_rcount_demi + 1
   		LET p_rVal_total_Demi = p_rVal_total_Demi + p_lista.val_parc_banco
      LET p_rVal_total_rep  = p_rVal_total_rep - p_lista.val_parc_banco 
   		LET p_rVal_total_30   = p_rVal_total_30 + p_lista.valor_30
   ELSE   
   	IF p_lista.dat_liquidacao IS NOT NULL AND p_lista.dat_liquidacao > p_lista.dat_contrato  AND p_lista.valor_30 <= 0 AND p_lista.cod_status = 'D' THEN
   	  	LET p_rcount_liq     = p_rcount_liq + 1
   			LET p_rVal_total_liq = p_rVal_total_liq + p_lista.val_parc_banco
      	LET p_rVal_total_rep = p_rVal_total_rep - p_lista.val_parc_banco
    ELSE  	 
	 		IF p_lista.dat_afastamento IS NOT NULL AND p_lista.dat_afastamento > p_lista.dat_contrato AND p_lista.cod_status = 'D' THEN
   	  	LET p_rcount_inss     = p_rcount_inss + 1
   			LET p_rVal_total_inss = p_rVal_total_inss + p_lista.val_parc_banco
      	LET p_rVal_total_rep =  p_rVal_total_rep - p_lista.val_parc_banco 
   		END IF	
   	END IF	
   END IF	


   

   LET p_gcount          = p_rcount 
   LET p_gVal_total      = p_rVal_total
   LET p_gVal_total_rep  = p_rVal_total_rep
   LET p_gVal_total_30   = p_rVal_total_30
   LET p_gcount_demi     = p_rcount_demi
   LET p_gVal_total_Demi = p_rVal_total_Demi
   LET p_gcount_liq      = p_rcount_liq
   LET p_gVal_total_liq  = p_rVal_total_liq
   LET p_gcount_inss     = p_rcount_inss
   LET p_gVal_total_inss = p_rVal_total_inss
   LET p_gcount_rep      = p_gcount - (p_gcount_demi+p_gcount_inss+p_gcount_liq) 
   
   
   
   INITIALIZE p_lista TO NULL
                 
   END FOREACH 

   CALL pol1076_emite_estado()   



END FUNCTION

#--------------------------------#
FUNCTION pol1076_emite_estado()
#--------------------------------#


   LET p_comprime       = ascii 15
   LET p_descomprime    = ascii 18
   LET p_negrito        = ascii 27, "E"
   LET p_normal         = ascii 27, "F"
   LET p_count          = 0
   LET p_Val_total      = 0 
   LET p_count_demi     = 0
   LET p_Val_total_Demi = 0
   LET p_count_liq      = 0
   LET p_Val_total_liq  = 0
   LET p_count_inss     = 0
   LET p_Val_total_inss = 0
   LET p_Val_total_rep  = 0
   LET p_Val_total_30   = 0
   LET p_Data_char      = "01/",p_tela.mesano
   LET p_data           = p_Data_char
   LET p_Dat_referencia = p_Data
   
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	

#----------------------------- GERANDO DADOS --------------------------#

#------------- PEGANDO UFS DO ARQ_BANCO_265 --------------------------#
   LET sql_stmt = 
         "SELECT DISTINCT(e.uni_feder) ",
         " FROM arq_banco_265 h, empresa e  ",
         " WHERE h.dat_referencia= '",p_Dat_referencia,"' ",
         " AND h.cod_banco = '",p_tela.cod_banco,"' ",
         " AND h.cod_empresa = e.cod_empresa "


   LET p_filtro = "MÊS/ANO: ",p_tela.mesano

   LET sql_stmt = sql_stmt CLIPPED, ' ', " order by e.uni_feder "

   PREPARE var_query5 FROM sql_stmt   
   DECLARE cq_padrao5 CURSOR FOR var_query5

   FOREACH cq_padrao5 INTO 
      p_lista.uni_feder

#------------- PEGANDO VALORES POR ESTADO --------------------------#

   	LET p_count          = 0
   	LET p_Val_total      = 0 
   	LET p_count_demi     = 0
   	LET p_Val_total_Demi = 0
   	LET p_count_liq      = 0
   	LET p_Val_total_liq  = 0
   	LET p_count_inss     = 0
   	LET p_count_rep      = 0
   	LET p_Val_total_inss = 0
   	LET p_Val_total_rep  = 0
   	LET p_Val_total_30   = 0
   	LET p_count_rep      = 0
   	LET p_Val_rep        = 0
   	LET p_estado         = p_lista.uni_feder

   	LET p_sql = 
      	"SELECT a.val_parcela, b.cod_tip_contr,",
      	" b.dat_liquidacao, b.dat_rescisao, b.dat_afastamento, b.valor_30, b.dat_contrato, ",
      	" (SELECT SUM(h.val_evento) FROM hist_movto_265 h  ",
      	" WHERE h.cod_empresa = b.cod_empresa ",
      	" AND h.num_cpf = b.num_cpf ",
      	" AND h.dat_referencia = a.dat_referencia ",
      	" AND h.cod_evento in (select ce.cod_evento from evento_265 ce where ce.cod_banco = a.cod_banco ",
      	" and ce.tip_evento = 1 and ce.estado= a.uf)) AS val_evento, a.cod_status ",
      " FROM arq_banco_265 a, contr_consig_265 b ",
      " LEFT OUTER JOIN empresa e ", 
      " ON e.cod_empresa = b.cod_empresa ",
      " WHERE b.num_contrato = a.num_contrato "


   LET p_sql = p_sql CLIPPED, ' ', "   AND a.cod_banco = '",p_tela.cod_banco,"' "
   LET p_sql = p_sql CLIPPED, ' ', "   AND a.dat_referencia = '",p_Dat_referencia,"'"
 	 LET p_sql = p_sql CLIPPED, ' ', "   AND e.uni_feder = '",p_lista.uni_feder,"' "
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   

		IF p_seleciona IS NOT NULL THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.cod_empresa in ",p_seleciona
      END IF

 		LET p_sql = p_sql CLIPPED, ' ', " ORDER BY e.uni_feder "

   PREPARE var_query2 FROM p_sql   
   DECLARE cq_padrao2 CURSOR FOR var_query2



   	FOREACH cq_padrao2 INTO 
      p_lista.val_parc_banco,
      p_lista.cod_tip_contr, p_lista.dat_liquidacao,
      p_lista.dat_demissao,p_lista.dat_afastamento,
      p_lista.valor_30,p_lista.dat_contrato,
      p_lista.val_parc_folha, p_lista.cod_status
      
  
   		LET p_count         = p_count + 1
   		LET p_Val_total     = p_Val_total + p_lista.val_parc_banco
   		LET p_Val_total_rep = p_Val_total_rep + p_lista.val_parc_folha
   
	    IF p_lista.dat_demissao IS NOT NULL AND p_lista.dat_demissao > p_lista.dat_contrato AND p_lista.cod_status = 'D' THEN
   	  	LET p_count_demi     = p_count_demi + 1
   			LET p_Val_total_Demi = p_Val_total_Demi + p_lista.val_parc_banco
     		LET p_Val_total_30  = p_Val_total_30 + p_lista.valor_30
   		ELSE	
      	IF p_lista.dat_liquidacao IS NOT NULL  AND p_lista.cod_status = 'D' THEN
   	  		LET p_count_liq     = p_count_liq + 1
   				LET p_Val_total_liq = p_Val_total_liq + p_lista.val_parc_banco
   			ELSE
	    		IF p_lista.dat_afastamento IS NOT NULL AND p_lista.dat_afastamento > p_lista.dat_contrato AND p_lista.cod_status = 'D'  THEN
   	  			LET p_count_inss     = p_count_inss + 1
   					LET p_Val_total_inss = p_Val_total_inss + p_lista.val_parc_banco
   				END IF	
   			END IF	
   		END IF	


      LET p_count_rep        = p_count - (p_count_demi+p_count_inss+p_count_liq)
      LET p_Val_rep          = p_Val_total - (p_Val_total_inss+p_Val_total_liq+p_Val_total_Demi)
      
      
      
                 
   	END FOREACH

    LET p_gcount_rep       = p_gcount - (p_gcount_demi+p_gcount_inss+p_gcount_liq)
   
   	OUTPUT TO REPORT pol1076_relat(2) 
   END FOREACH
#	 OUTPUT TO REPORT pol1076_estado(p_lista.uni_feder)



END FUNCTION

#--------------------------------#
FUNCTION pol1076_emite_afasta()
#--------------------------------#


  LET p_Data_char      = "01/",p_tela.mesano
  LET p_data           = p_Data_char
  LET p_Dat_referencia = p_Data
  LET p_gVal_afasta    = 0
   
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
#----------------------------- IMPRIMINDO RELAÇÃO --------------------------#
   LET p_sql = 
      "SELECT e.uni_feder, a.cod_empresa,b.num_matricula,a.nom_funcionario,",
      " a.val_parcela, ",
      " b.dat_liquidacao, b.dat_rescisao, b.dat_afastamento, b.valor_30, b.dat_contrato ",
      " FROM arq_banco_265 a, contr_consig_265 b ",
      " LEFT OUTER JOIN empresa e ",
      " ON e.cod_empresa = b.cod_empresa ",
      " WHERE b.num_contrato = a.num_contrato ",
      " AND ((b.dat_liquidacao is not NULL AND b.dat_liquidacao >  b.dat_contrato)",
      " OR b.dat_rescisao >  b.dat_contrato ",
      " OR b.dat_afastamento >  b.dat_contrato) " 


   LET p_sql = p_sql CLIPPED, ' ', " AND a.cod_banco = '",p_tela.cod_banco,"' "
   LET p_sql = p_sql CLIPPED, ' ', " AND a.dat_referencia = '",p_Dat_referencia,"'"
   LET p_sql = p_sql CLIPPED, ' ', " AND a.cod_status = 'D' "
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   
		IF   p_tela.cod_uf <> '99' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND e.uni_feder = '",p_tela.cod_uf,"' "
    END IF

		IF p_seleciona IS NOT NULL THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.cod_empresa in ",p_seleciona
      END IF


 		LET p_sql = p_sql CLIPPED, ' ', " order by e.uni_feder, a.nom_funcionario "

   PREPARE var_query3 FROM p_sql   
   DECLARE cq_padrao3 CURSOR FOR var_query3


   FOREACH cq_padrao3 INTO 
      p_lista.uni_feder, p_lista.cod_empresa,p_lista.num_matricula,
      p_lista.nom_funcionario, p_lista.val_parc_banco, 
      p_lista.dat_liquidacao, p_lista.dat_demissao,
      p_lista.dat_afastamento, p_lista.valor_30, 
      p_lista.dat_contrato, p_lista.cod_status
      
	    IF p_lista.dat_afastamento IS NOT NULL AND p_lista.dat_afastamento > p_lista.dat_contrato THEN
      	LET p_lista.tipo = "NO INSS"
   		END IF	

      IF p_lista.dat_liquidacao IS NOT NULL AND p_lista.dat_liquidacao > p_lista.dat_contrato THEN
      	LET p_lista.tipo = "LIQUIDADO"
      	LET p_lista.dat_afastamento = p_lista.dat_liquidacao
   		END IF	

	 		IF p_lista.dat_demissao IS NOT NULL AND p_lista.dat_demissao > p_lista.dat_contrato THEN
      	LET p_lista.tipo = "RESCISAO"
      	LET p_lista.dat_afastamento = p_lista.dat_demissao
   		END IF	

      LET p_gVal_afasta  = p_gVal_afasta + p_lista.val_parc_banco


   OUTPUT TO REPORT pol1076_afasta(p_lista.ano_mes_proces) 
      
   
   INITIALIZE p_lista TO NULL
                 
   END FOREACH 



END FUNCTION

#--------------------------------#
FUNCTION pol1076_emite_status()
#--------------------------------#


  LET p_Data_char      = "01/",p_tela.mesano
  LET p_data           = p_Data_char
  LET p_Dat_referencia = p_Data
   
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
#----------------------------- IMPRIMINDO RELAÇÃO --------------------------#
   LET p_cod_uf_r = ''
   LET p_motivo   = ''

   LET p_sql = 
      "SELECT e.uni_feder, a.cod_empresa,a.nom_funcionario,a.num_cpf,",
      " b.num_contrato,b.qtd_parcela,a.num_parcela, a.val_parcela, b.cod_tip_contr, ",
      " b.dat_liquidacao, b.dat_rescisao, b.dat_afastamento, b.valor_30, b.dat_contrato ",
      " FROM arq_banco_265 a, contr_consig_265 b ",
      " LEFT OUTER JOIN empresa e ",
      " ON e.cod_empresa = b.cod_empresa ",
      " WHERE b.num_contrato = a.num_contrato ",
      " AND ((b.dat_liquidacao is not NULL AND b.dat_liquidacao >  b.dat_contrato)",
      " OR b.dat_rescisao >  b.dat_contrato ",
      " OR b.dat_afastamento >  b.dat_contrato) " 


   LET p_sql = p_sql CLIPPED, ' ', " AND a.cod_banco = '",p_tela.cod_banco,"' "
   LET p_sql = p_sql CLIPPED, ' ', " AND a.dat_referencia = '",p_Dat_referencia,"'"
   LET p_sql = p_sql CLIPPED, ' ', " AND a.cod_status = 'D' "
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   
		IF   p_tela.cod_uf <> '99' THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND e.uni_feder = '",p_tela.cod_uf,"' "
    END IF

		IF p_seleciona IS NOT NULL THEN
   		LET p_sql = p_sql CLIPPED, ' ', "   AND b.cod_empresa in ",p_seleciona
      END IF


 		LET p_sql = p_sql CLIPPED, ' ', " order by e.uni_feder,a.cod_empresa,b.nom_funcionario,b.dat_afastamento,b.dat_rescisao "

   PREPARE var_query4 FROM p_sql   
   DECLARE cq_padrao4 CURSOR FOR var_query4


   FOREACH cq_padrao4 INTO 
      p_lista.uni_feder, p_lista.cod_empresa,
      p_lista.nom_funcionario, p_lista.cpf_func,  
      p_lista.num_contrato, p_lista.prazo, 
      p_lista.num_parcela, p_lista.val_parc_banco,
      p_lista.cod_tip_contr, p_lista.dat_liquidacao,
      p_lista.dat_demissao,p_lista.dat_afastamento,
      p_lista.valor_30, p_lista.dat_contrato
      
      LET p_lista.Tipo = "1-Normal"
     	LET p_motivo_c = "L"

      IF p_lista.cod_tip_contr <> '1' THEN
      	LET p_lista.tipo = "2-Renova"
      END IF	

	    IF p_lista.dat_afastamento IS NOT NULL AND p_lista.dat_afastamento > p_lista.dat_contrato THEN
      	LET p_motivo_c = "I"
   		END IF	

	    IF p_lista.dat_liquidacao IS NOT NULL AND p_lista.dat_liquidacao > p_lista.dat_contrato THEN
      	LET p_motivo_c = "L"
   		END IF	

	 		IF p_lista.dat_demissao IS NOT NULL AND p_lista.dat_demissao > p_lista.dat_contrato THEN
      	LET p_motivo_c = "D"
   		END IF	


   OUTPUT TO REPORT pol1076_status(p_lista.ano_mes_proces) 
      
   
   INITIALIZE p_lista TO NULL
                 
   END FOREACH 



END FUNCTION


#--------------------------------#
 REPORT pol1076_relat(p_ordem_imp)                              
#--------------------------------# 


	DEFINE 	p_ordem_imp				SMALLINT
	DEFINE 	p_cabeca_imp			SMALLINT
   
	OUTPUT LEFT   MARGIN 0
	TOP    				MARGIN 0
	BOTTOM 				MARGIN 3
  
	FORMAT
	
	PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------
  			LET   p_cabeca_imp = 0
	
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
                           
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 124, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 001, "pol1076",
               COLUMN 057, "RELATORIO MENSAL DE DESCONTOS",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
               
	IF p_ordem_imp = 1 THEN        
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, "UF|SETOR|               NOME                     |      CPF     | CONTRATO |SOLICITACAO|PRAZO|PARCELA|  PRESTACAO  |   TIPO   "
         PRINT COLUMN 001, "--|-----|----------------------------------------|",
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                           "--------------|----------|-----------|-----|-------|-------------|",
                           "----------------"
	ELSE
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 001, "UF| QTD - VL.PRESTACAO | QTD - VL. RESCISAO | QTD - VALOR INSS   | QTD - LIQUIDADOS   | QTD - VL. REPASSE  | QTD - VALOR 30% " 
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, "--|--------------------|--------------------|--------------------|--------------------|--------------------|---------------------"
  			 LET   p_cabeca_imp = 1
	
	
	END IF
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
  CASE p_ordem_imp
  	WHEN 1
         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 005, p_lista.cod_empresa, 
               COLUMN 009,'|',
               COLUMN 010, p_lista.nom_funcionario[1,40], 
               COLUMN 050,'|',
               COLUMN 051, p_lista.cpf_func[1,14], 
               COLUMN 065,'|',
               COLUMN 061, p_lista.num_contrato[1,10], 
               COLUMN 069,'|',
             	 COLUMN 070, p_lista.dat_contrato, 
               COLUMN 081,' |',
             	 COLUMN 082, p_lista.prazo USING '#&', 
               COLUMN 094,'|',
               COLUMN 097, p_lista.num_parcela USING '#&', 
               COLUMN 102,'|',
             	 COLUMN 103, p_lista.val_parc_banco USING '#,###,##&.&&', 
               COLUMN 116,'|',
             	 COLUMN 117, p_lista.tipo 
             	 
				 	IF p_lista.dat_demissao IS NOT NULL AND p_lista.dat_demissao > p_lista.dat_contrato AND p_lista.cod_status = 'D' THEN
				 	
         		PRINT COLUMN 003,'|',
               		COLUMN 005, '***', 
               		COLUMN 009,'|',
               		COLUMN 010, 'Demitido em ',p_lista.dat_demissao,' - 30% ',p_lista.valor_30 USING '###,##&.&&',
               		COLUMN 050,'|              |          |           |     |       |             |'
				 ELSE
				 IF p_lista.dat_afastamento IS NOT NULL AND p_lista.dat_afastamento > p_lista.dat_contrato AND p_lista.cod_status = 'D' THEN
         	PRINT COLUMN 003,'|',
               	COLUMN 005, '***', 
               	COLUMN 009,'|',
               	COLUMN 010, 'No INSS em ',p_lista.dat_afastamento, 
               	COLUMN 050,'|              |          |           |     |       |             |'
          ELSE   		
				 		IF p_lista.dat_liquidacao IS NOT NULL AND p_lista.dat_liquidacao > p_lista.dat_contrato AND p_lista.cod_status = 'D' THEN
				 	
         			PRINT COLUMN 003,'|',
               			COLUMN 005, '***', 
               			COLUMN 009,'|',
               			COLUMN 010, 'Liquidado em ',p_lista.dat_liquidacao,
               			COLUMN 050,'|              |          |           |     |       |             |'
          	ELSE   		
          END IF     		
          END IF     		
				 END IF 
             	 
         PRINT COLUMN 001, "--|-----|----------------------------------------|",
                           "--------------|----------|-----------|-----|-------|-------------|",
                           "----------------"
  	WHEN 2
         IF p_cabeca_imp = 0 THEN

         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, 'TOTAL DE PRESTACOES:................(', 
               COLUMN 038, p_rcount USING '######&',
               COLUMN 045, ' - CONTRATOS)............................................|',
             	 COLUMN 103, p_rVal_total USING '#,###,##&.&&', 
               COLUMN 116,'|'
               
         PRINT COLUMN 001, 'TOTAL DE PRESTACOES DOS DEMITIDOS:..(', 
               COLUMN 038, p_rcount_demi USING '######&',
               COLUMN 045, ' - CONTRATOS)............................................|',
             	 COLUMN 103, p_rVal_total_Demi USING '#,###,##&.&&', 
               COLUMN 116,'|'

         PRINT COLUMN 001, 'TOTAL DE PRESTACOES DOS LIQUIDADOS:.(', 
               COLUMN 038, p_rcount_liq USING '######&',
               COLUMN 045, ' - CONTRATOS)............................................|',
             	 COLUMN 103, p_rVal_total_liq USING '#,###,##&.&&', 
               COLUMN 116,'|'

         PRINT COLUMN 001, 'TOTAL DE PRESTACOES DOS NO INSS:....(', 
               COLUMN 038, p_rcount_inss USING '######&',
               COLUMN 045, ' - CONTRATOS)............................................|',
             	 COLUMN 103, p_rVal_total_inss USING '#,###,##&.&&', 
               COLUMN 116,'|'

         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------|-------------|"
         PRINT COLUMN 001, 'TOTAL DE REPASSE:....................................................................................|', 
             	 COLUMN 103, p_rVal_total_rep USING '#,###,##&.&&', 
               COLUMN 116,'|'
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------|-------------|"
         PRINT COLUMN 001, 'TOTAL DOS 30% NA RESCISAO:..........(', 
               COLUMN 038, p_rcount_demi USING '######&',
               COLUMN 045, ' - CONTRATOS)............................................|',
             	 COLUMN 103, p_rVal_total_30 USING '#,###,##&.&&', 
               COLUMN 116,'|'
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"

         PRINT COLUMN 001, p_descomprime
#    {33} SKIP 6 LINES

      SKIP TO TOP OF PAGE

{         	PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"
         	PRINT COLUMN 001, "UF| QTD - VL.PRESTACAO | QTD - VL. RESCISAO | QTD - VALOR INSS   | QTD - LIQUIDADOS   | QTD - VL. REPASSE  | QTD - VALOR 30% " 
                           	#         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           	#1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         	PRINT COLUMN 001, "--|--------------------|--------------------|--------------------|--------------------|--------------------|---------------------"}
  			 	LET   p_cabeca_imp = 1
         ELSE
         END IF

         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 004, p_count USING '###&', 
               COLUMN 009,'-',
               COLUMN 011, p_Val_total USING '#,###,##&.&&', 
               COLUMN 024,'|',
               COLUMN 025, p_count_demi USING '###&', 
               COLUMN 030,'-',
               COLUMN 032, p_Val_total_Demi USING '#,###,##&.&&',  
               COLUMN 045,'|',
             	 COLUMN 046, p_count_inss USING '###&', 
               COLUMN 051,'-',
             	 COLUMN 053, p_Val_total_inss USING '#,###,##&.&&', 
               COLUMN 066,'|',
               COLUMN 067, p_count_liq USING '###&', 
               COLUMN 072,'-',
             	 COLUMN 074, p_Val_total_liq USING '#,###,##&.&&',  
               COLUMN 087,'|',
               COLUMN 088, p_count_rep USING '###&', 
               COLUMN 093,'-',
             	 COLUMN 095, p_Val_rep USING '#,###,##&.&&',  
               COLUMN 108,'|',
               COLUMN 109, p_count_demi USING '###&', 
               COLUMN 114,'-',
             	 COLUMN 116, p_Val_total_30 USING '#,###,##&.&&'  

	END CASE					
  
  ON LAST ROW 
  CASE p_ordem_imp
  	WHEN 1
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, 'TOTAL DE PRESTACOES:................(', 
               COLUMN 038, p_rcount USING '######&',
               COLUMN 045, ' - CONTRATOS)............................................|',
             	 COLUMN 103, p_rVal_total USING '#,###,##&.&&', 
               COLUMN 116,'|'
               
         PRINT COLUMN 001, 'TOTAL DE PRESTACOES DOS DEMITIDOS:..(', 
               COLUMN 038, p_rcount_demi USING '######&',
               COLUMN 045, ' - CONTRATOS)............................................|',
             	 COLUMN 103, p_rVal_total_Demi USING '#,###,##&.&&', 
               COLUMN 116,'|'

         PRINT COLUMN 001, 'TOTAL DE PRESTACOES DOS LIQUIDADOS:.(', 
               COLUMN 038, p_rcount_liq USING '######&',
               COLUMN 045, ' - CONTRATOS)............................................|',
             	 COLUMN 103, p_rVal_total_liq USING '#,###,##&.&&', 
               COLUMN 116,'|'

         PRINT COLUMN 001, 'TOTAL DE PRESTACOES DOS NO INSS:....(', 
               COLUMN 038, p_rcount_inss USING '######&',
               COLUMN 045, ' - CONTRATOS)............................................|',
             	 COLUMN 103, p_rVal_total_inss USING '#,###,##&.&&', 
               COLUMN 116,'|'

         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------|-------------|"
         PRINT COLUMN 001, 'TOTAL DE REPASSE:....................................................................................|', 
             	 COLUMN 103, p_rVal_total_rep USING '#,###,##&.&&', 
               COLUMN 116,'|'
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------|-------------|"
         PRINT COLUMN 001, 'TOTAL DOS 30% NA RESCISAO:...........................................................................|', 
             	 COLUMN 103, p_rVal_total_30 USING '#,###,##&.&&', 
               COLUMN 116,'|'
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, p_descomprime
         PRINT
  	WHEN 2
         PRINT COLUMN 001, "--|--------------------|--------------------|--------------------|--------------------|--------------------|---------------------"
         PRINT COLUMN 001, 'TT', 
               COLUMN 003,'|',
               COLUMN 004, p_gcount USING '###&', 
               COLUMN 009,'-',
               COLUMN 011, p_gVal_total USING '#,###,##&.&&', 
               COLUMN 024,'|',
               COLUMN 025, p_gcount_demi USING '###&', 
               COLUMN 030,'-',
               COLUMN 032, p_gVal_total_Demi USING '#,###,##&.&&',  
               COLUMN 045,'|',
             	 COLUMN 046, p_gcount_inss USING '###&', 
               COLUMN 051,'-',
             	 COLUMN 053, p_gVal_total_inss USING '#,###,##&.&&', 
               COLUMN 066,'|',
               COLUMN 067, p_gcount_liq USING '###&', 
               COLUMN 072,'-',
             	 COLUMN 074, p_gVal_total_liq USING '#,###,##&.&&',  
               COLUMN 087,'|',
               COLUMN 088, p_gcount_rep USING '###&', 
               COLUMN 093,'-',
             	 COLUMN 095, p_gVal_total_rep USING '#,###,##&.&&',  
               COLUMN 108,'|',
               COLUMN 109, p_gcount_demi USING '###&', 
               COLUMN 114,'-',
             	 COLUMN 116, p_gVal_total_30 USING '#,###,##&.&&'  
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 001, 'As quantidades acima referem-se aos numeros de contratos, podendo um funcionario ter mais de um contrato.' 
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"

								

         PRINT COLUMN 001, p_descomprime
					
         
	END CASE  				

END REPORT




#--------------------------------#
 REPORT pol1076_estado(p_ordem_imp)                              
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
               
         PRINT COLUMN 001, "pol1076",
               COLUMN 057, "RELATORIO MENSAL DE DESCONTOS",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
               
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 001, "UF| QTD - VL.PRESTACAO | QTD - VL. RESCISAO | QTD - VALOR INSS   | QTD - LIQUIDADOS   | QTD - VL. REPASSE  | QTD - VALOR 30% " 
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, "--|--------------------|--------------------|--------------------|--------------------|--------------------|---------------------"
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, p_cod_uf_r, 
               COLUMN 003,'|',
               COLUMN 004, p_count USING '###&', 
               COLUMN 009,'-',
               COLUMN 011, p_Val_total USING '#,###,##&.&&', 
               COLUMN 024,'|',
               COLUMN 025, p_count_demi USING '###&', 
               COLUMN 030,'-',
               COLUMN 032, p_Val_total_Demi USING '#,###,##&.&&',  
               COLUMN 045,'|',
             	 COLUMN 046, p_count_inss USING '###&', 
               COLUMN 051,'-',
             	 COLUMN 053, p_Val_total_inss USING '#,###,##&.&&', 
               COLUMN 066,'|',
               COLUMN 067, p_count_liq USING '###&', 
               COLUMN 072,'-',
             	 COLUMN 074, p_Val_total_liq USING '#,###,##&.&&',  
               COLUMN 087,'|',
               COLUMN 088, p_count_rep USING '###&', 
               COLUMN 093,'-',
             	 COLUMN 095, p_Val_total_rep USING '#,###,##&.&&',  
               COLUMN 108,'|',
               COLUMN 109, p_count_demi USING '###&', 
               COLUMN 114,'-',
             	 COLUMN 116, p_Val_total_30 USING '#,###,##&.&&'  
								
      ON LAST ROW 
         PRINT COLUMN 001, "--|--------------------|--------------------|--------------------|--------------------|--------------------|---------------------"
         PRINT COLUMN 001, 'TT', 
               COLUMN 003,'|',
               COLUMN 004, p_gcount USING '###&', 
               COLUMN 009,'-',
               COLUMN 011, p_gVal_total USING '#,###,##&.&&', 
               COLUMN 024,'|',
               COLUMN 025, p_gcount_demi USING '###&', 
               COLUMN 030,'-',
               COLUMN 032, p_gVal_total_Demi USING '#,###,##&.&&',  
               COLUMN 045,'|',
             	 COLUMN 046, p_gcount_inss USING '###&', 
               COLUMN 051,'-',
             	 COLUMN 053, p_gVal_total_inss USING '#,###,##&.&&', 
               COLUMN 066,'|',
               COLUMN 067, p_gcount_liq USING '###&', 
               COLUMN 072,'-',
             	 COLUMN 074, p_gVal_total_liq USING '#,###,##&.&&',  
               COLUMN 087,'|',
               COLUMN 088, p_gcount_rep USING '###&', 
               COLUMN 093,'-',
             	 COLUMN 095, p_gVal_total_rep USING '#,###,##&.&&',  
               COLUMN 108,'|',
               COLUMN 109, p_gcount_demi USING '###&', 
               COLUMN 114,'-',
             	 COLUMN 116, p_gVal_total_30 USING '#,###,##&.&&'  
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 001, 'As quantidades acima referem-se aos numeros de contratos, podendo um funcionario ter mais de um contrato.' 
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"

								

         PRINT COLUMN 001, p_descomprime
					

END REPORT

#--------------------------------#
 REPORT pol1076_afasta(p_ordem_imp)                              
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
               
         PRINT COLUMN 001, "pol1076",
               COLUMN 057, "RELATORIO MENSAL DE DESCONTOS",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
               
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 001, "UF|SETOR| MATRICULA |                   NOME                  |     CPF      | MOTIVO  |   DATA   | PRESTACAO  |   VALOR 30% " 
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, "--|-----|-----------|-----------------------------------------|--------------|---------|----------|------------|-----------------"
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 005, p_lista.cod_empresa, 
               COLUMN 009,'|',
               COLUMN 012, p_lista.num_matricula USING '######',
               COLUMN 021,'|',
               COLUMN 022, p_lista.nom_funcionario[1,40], 
               COLUMN 063,'|',
               COLUMN 064, p_lista.cpf_func[1,14], 
               COLUMN 078,'|',
               COLUMN 079, p_lista.tipo, 
               COLUMN 088,'|',
             	 COLUMN 089, p_lista.dat_afastamento, 
               COLUMN 099,'|',
             	 COLUMN 100, p_lista.val_parc_banco USING '#,###,##&.&&', 
               COLUMN 112,'|',
             	 COLUMN 115, p_lista.valor_30 USING '#,###,##&.&&' 
         PRINT COLUMN 001, "--|-----|-----------|-----------------------------------------|--------------|---------|----------|------------|-----------------"
								
      ON LAST ROW 
         PRINT COLUMN 001, 'TOTAL ............................................................................................|', 
             	 COLUMN 100, p_gVal_afasta USING '#,###,##&.&&', 
               COLUMN 112,'|',
             	 COLUMN 115, p_gVal_total_30 USING '#,###,##&.&&' 
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"

         PRINT COLUMN 001, p_descomprime
					

END REPORT

#--------------------------------#
 REPORT pol1076_status(p_ordem_imp)                              
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
               
         PRINT COLUMN 001, "pol1076",
               COLUMN 057, "RELATORIO MENSAL DE DESCONTOS",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
               
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 001, "UF|SETOR|                   NOME                  |     CPF      | CONTRATO |SOLICITACAO|PRAZO|PARCELA| PRESTACAO |   TIPO   " 
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, "--|-----|-----------------------------------------|--------------|----------|-----------|-----|-------|-----------|--------------"
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
	       IF p_motivo_c = p_motivo THEN
	       ELSE
	          LET p_motivo = p_motivo_c
         		PRINT COLUMN 001, "--|-----|-----------------------------------------|--------------|----------|-----------|-----|-------|-----------|--------------"
            IF p_motivo_c = 'D' THEN   		
         			PRINT COLUMN 001, p_lista.uni_feder,"|||||||             DEMITIDOS                   |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
         		ELSE
         		END IF	
            IF p_motivo_c = 'L' THEN   		
         			PRINT COLUMN 001, p_lista.uni_feder,"||||||| EMPRESTIMOS LIQUIDADOS E RENOVADOS      |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
         		ELSE
         		END IF	
            IF p_motivo_c = 'I' THEN   		
         			PRINT COLUMN 001, p_lista.uni_feder,"|||||||                INSS                     |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
         		ELSE
         		END IF	
         		PRINT COLUMN 001, "  |     |-----------------------------------------|              |          |           |     |       |           |"
         END IF
         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 005, p_lista.cod_empresa, 
               COLUMN 009,'|',
               COLUMN 010, p_lista.nom_funcionario[1,40], 
               COLUMN 051,'|',
               COLUMN 052, p_lista.cpf_func[1,14], 
               COLUMN 066,'|',
               COLUMN 067, p_lista.num_contrato[1,10], 
               COLUMN 077,'|',
             	 COLUMN 078, p_lista.dat_contrato, 
               COLUMN 089,'|',
               COLUMN 092, p_lista.prazo USING '##', 
               COLUMN 095,'|',
               COLUMN 098, p_lista.num_parcela USING '##', 
               COLUMN 103,'|',
             	 COLUMN 104, p_lista.val_parc_banco USING '###,##&.&&', 
               COLUMN 115,'|',
             	 COLUMN 117, p_lista.tipo 
          
          IF p_motivo_c = 'D' THEN 
						PRINT COLUMN 003,'|',
                  COLUMN 005, "***", 
                  COLUMN 009,'|',
                  COLUMN 010, "Demitido em ",p_lista.dat_demissao," - 30%:",p_lista.valor_30 USING '#,###,##&.&&', 
                  COLUMN 051,'|',
                  COLUMN 066,'|',
                  COLUMN 077,'|',
                  COLUMN 089,'|',
                  COLUMN 095,'|',
                  COLUMN 103,'|',
                  COLUMN 115,'|'
         		PRINT COLUMN 001, "--|-----|-----------------------------------------|--------------|----------|-----------|-----|-------|-----------|--------------"
          ELSE
          END IF
             	 
          IF p_motivo_c = 'I' THEN 
						PRINT COLUMN 003,'|',
                  COLUMN 005, "***", 
                  COLUMN 009,'|',
                  COLUMN 010, "No INSS em ",p_lista.dat_afastamento, 
                  COLUMN 051,'|',
                  COLUMN 066,'|',
                  COLUMN 077,'|',
                  COLUMN 089,'|',
                  COLUMN 095,'|',
                  COLUMN 103,'|',
                  COLUMN 115,'|'
         		PRINT COLUMN 001, "--|-----|-----------------------------------------|--------------|----------|-----------|-----|-------|-----------|--------------"
          ELSE
          END IF
             	 
          IF p_cod_uf_r = p_lista.uni_feder THEN
          ELSE
             IF p_cod_uf_r = '' THEN
             ELSE        
         		 	PRINT COLUMN 001, "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
         		 END IF	
             LET p_cod_uf_r = p_lista.uni_feder 
					END IF			
      ON LAST ROW 
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------"

         PRINT COLUMN 001, p_descomprime
					

END REPORT

#-----------------------#
 FUNCTION pol1076_sobre()
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

#--------------------------------------#
 FUNCTION POL1076_ent_empresa(p_funcao)
#--------------------------------------#
   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1076

   IF p_funcao = 'INCLUSAO' THEN
      INITIALIZE ma_tela TO NULL
   END IF
 
   LET INT_FLAG =  FALSE

   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*

      BEFORE FIELD empresa
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD empresa
         IF ma_tela[pa_curr].empresa IS NOT NULL AND 
            ma_tela[pa_curr].empresa <> ' ' THEN
            IF POL1076_verifica_empresa() = FALSE THEN
               ERROR 'Código não cadastrado.'
               NEXT FIELD empresa 
            END IF   
         END IF

      ON KEY (control-z)
         CALL POL1076_popup()

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1076

   IF INT_FLAG THEN
      IF p_funcao = "MODIFICACAO" THEN
         RETURN FALSE
      ELSE
         CLEAR FORM
         ERROR "Inclusão Cancelada"
         RETURN FALSE
      END IF
   ELSE
      RETURN TRUE
   END IF  

END FUNCTION

#-------------------------------#
 FUNCTION POL1076_verifica_empresa()
#-------------------------------#

   SELECT DISTINCT(den_empresa) 
     INTO ma_tela[pa_curr].den_empresa
     FROM empresa
    WHERE cod_empresa  = ma_tela[pa_curr].empresa  

   IF sqlca.sqlcode = 0 THEN
      DISPLAY ma_tela[pa_curr].den_empresa TO s_itens[sc_curr].den_empresa
      RETURN TRUE
   ELSE
      DISPLAY ma_tela[pa_curr].den_empresa TO s_itens[sc_curr].den_empresa
      RETURN FALSE
   END IF

END FUNCTION



#-------------------------------- FIM DE PROGRAMA -----------------------------#
