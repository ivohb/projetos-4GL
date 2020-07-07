#-------------------------------------------------------------------------#
# SISTEMA.: Relaçao de Conciliação entre Folha e Banco             		  #
#	PROGRAMA:	pol1080													  #
#	CLIENTE.:	IURD													  #
#	OBJETIVO:	Rel. Conciliação entre Folha e Banco                      #
#	AUTOR...:	Paulo													  #
#	DATA....:	03/12/2010			 									  #
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
          p_last_row            SMALLINT,
          p_Comprime            CHAR(01),
          p_descomprime         CHAR(01),
          p_negrito             CHAR(02),
          p_normal              CHAR(02),
          p_ordem               CHAR(10),
          p_repetiu             SMALLINT,
          p_Data_char           CHAR(10),
          p_data                DATE,
          p_Dat_referencia      CHAR(07),
          p_num_seq             SMALLINT,
          p_sql                 CHAR(950),
          p_sql_2               CHAR(900),
          p_sql_3               CHAR(900),
          p_sql_4               CHAR(500),
          p_val_Diferenca       DECIMAL(12,2),
          p_val_parc_Nao        DECIMAL(12,2),
          p_fval_parc_Prev      DECIMAL(12,2),
          p_fval_parc_Efe       DECIMAL(12,2),
          p_fval_parc_Acer      DECIMAL(12,2),
          p_fval_parc_Nao       DECIMAL(12,2),
          p_num_matricula       DECIMAL(8,0),
          p_imprime             SMALLINT,
          p_nom_banco1          CHAR(20),
          p_nom_banco2          CHAR(20),
          p_nom_banco3          CHAR(20),
          p_cod_banco1          SMALLINT,
          p_cod_banco2          SMALLINT,
          p_cod_banco3          SMALLINT,
          p_cod_banco4          SMALLINT,
          p_evento_folha        SMALLINT,
          p_qtde_banco          SMALLINT,
          p_qtde_banco1         SMALLINT,
          p_qtde_banco2         SMALLINT,
          p_qtde_banco3         SMALLINT,
          p_qtde_folha          SMALLINT,
          p_tqtde_banco1        SMALLINT,
          p_tqtde_banco2        SMALLINT,
          p_tqtde_banco3        SMALLINT,
          p_tqtde_folha         SMALLINT,
          p_qtd_folha           SMALLINT,
          p_qtd_Demitido        SMALLINT,
          p_tqtd_folha          SMALLINT,
          p_qtde_Diferenca      SMALLINT,
          p_evento_banco1       SMALLINT,
          p_evento_banco2       SMALLINT,
          p_evento_banco3       SMALLINT,
          p_val_banco           DECIMAL(12,2),
          p_val_banco1          DECIMAL(12,2),
          p_val_banco2          DECIMAL(12,2),
          p_val_banco3          DECIMAL(12,2),
          p_val_folha           DECIMAL(12,2),
          p_val_demitido        DECIMAL(12,2),
          p_val_folha_parc      DECIMAL(12,2),
          p_tval_banco1         DECIMAL(12,2),
          p_tval_banco2         DECIMAL(12,2),
          p_tval_banco3         DECIMAL(12,2),
          p_tval_folha          DECIMAL(12,2),
          p_count_banco         SMALLINT,
          p_estado              CHAR(2),
          p_obs                 CHAR(25),
          p_obs_2               CHAR(25),
          p_tqtde_Diferenca     SMALLINT,
          p_tval_Diferenca      DECIMAL(12,2),
          P_val_parc_folha      DECIMAL(12,2),
          p_quantidade          SMALLINT,
          p_num_parcela         SMALLINT,
         p_filtro              CHAR(120)
               
   DEFINE p_tela                RECORD 
          cod_banco             LIKE bancos.cod_banco,
          nom_banco             LIKE bancos.nom_banco,
          mesano                CHAR(7),
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
      nom_banco                 CHAR(20),
      cod_evento                SMALLINT,
      cod_banco                 SMALLINT,
      val_parc_folha            DECIMAL(12,2),
      val_parc_banco            DECIMAL(12,2),
      num_matricula             DECIMAL(8,0),
      empresa                   CHAR(2),
      uni_feder                 CHAR(2),
      dat_rescisao              DATE,
      dat_afasta                DATE,
      dat_referencia            DATETIME YEAR TO MONTH,
      observacao                CHAR(225),
      mensagem                  CHAR(60),
      val_evento                DECIMAL(12,2),
      val_acerto                DECIMAL(12,2),
      val_folha                 DECIMAL(12,2),
      val_banco                 DECIMAL(12,2),
      quantidade                SMALLINT,
      num_parcela               SMALLINT,
      val_parc_Acer             DECIMAL(12,2),
      val_parc_Nao              DECIMAL(12,2),
      tip_evento                INTEGER,
      dat_acerto                DATE
      
   END RECORD 

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
	 LET p_versao = "pol1080-10.02.07"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1080.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol1080_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1080_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1080") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1080 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
         
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Listagem"
         HELP 001 
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol1080","IN")  THEN
         		LET p_count = 0
            IF pol1080_informar() THEN
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
         IF log005_seguranca(p_user,"VDP","pol1080","MO") THEN
           IF p_ies_cons THEN 
               IF log0280_saida_relat(13,29) IS NOT NULL THEN
                  MESSAGE " Processando a Extracao do Relatorio..." 
                     ATTRIBUTE(REVERSE)
                     
                  IF p_ies_impressao = "S" THEN
                     IF g_ies_ambiente = "U" THEN
                        START REPORT pol1080_relat TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1080.tmp'
                        START REPORT pol1080_relat  TO p_caminho
                     END IF
                  ELSE
                     START REPORT pol1080_relat TO p_nom_arquivo
                  END IF
                  CALL pol1080_emite_relatorio()   
                  IF p_count = 0 THEN
                     ERROR "Nao Existem Dados para serem Listados" 
                  ELSE
                     ERROR "Relatorio Processado com Sucesso" 
                  END IF
                  FINISH REPORT pol1080_relat   

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
                        START REPORT pol1080_Banco TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1080.tmp'
                        START REPORT pol1080_Banco  TO p_caminho
                     END IF
                  ELSE
                  	 LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_1"
                     START REPORT pol1080_Banco TO p_nom_arquivo
                  END IF
                  CALL pol1080_emite_Banco()   
                  FINISH REPORT pol1080_Banco   

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
                        START REPORT pol1080_total TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1080.tmp'
                        START REPORT pol1080_total  TO p_caminho
                     END IF
                  ELSE
                  	 LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_2"
                     START REPORT pol1080_total TO p_nom_arquivo
                  END IF
                  CALL pol1080_emite_total()   
                  FINISH REPORT pol1080_total   

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
#---------- Relatório de Eventos sem Banco definido -------------------------#
                  IF p_ies_impressao = "S" THEN
                     IF g_ies_ambiente = "U" THEN
                        START REPORT pol1080_semBanco TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1080.tmp'
                        START REPORT pol1080_semBanco  TO p_caminho
                     END IF
                  ELSE
                  	 LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_3"
                     START REPORT pol1080_semBanco TO p_nom_arquivo
                  END IF
                  CALL pol1080_emite_semBanco()   
                  FINISH REPORT pol1080_semBanco   

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
	    CALL pol1080_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1080

END FUNCTION

#--------------------------#
FUNCTION pol1080_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_tela.cod_uf    = '99'
   LET p_tela.cod_setor = '99'
   LET p_tela.cod_func  = ''
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

      IF p_tela.mesano[1,2] > '12' THEN
         ERROR "Mês incorreto"
         NEXT FIELD mesano       
      END IF 
      
      ON KEY (control-z)
         CALL pol1080_popup()

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
FUNCTION pol1080_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_setor)
         CALL log009_popup(8,15,"EMPRESAS","empresa",
                     "cod_empresa","den_empresa","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1080
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_setor = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_setor
            
         END IF

      WHEN INFIELD(cod_banco)
         CALL log009_popup(8,25,"Banco","bancos",
                     "cod_banco","nom_banco","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1080
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_banco = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_banco
         END IF



   END CASE

END FUNCTION


#--------------------------------#
 FUNCTION pol1080_emite_relatorio()
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
   LET p_Dat_referencia = EXTEND(p_data, YEAR TO MONTH)
   LET p_val_Diferenca = 0 
   LET p_val_folha_parc = 0 
   
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
   SELECT nom_banco   
      INTO p_nom_banco
   FROM bancos 
   WHERE cod_banco = p_tela.cod_banco

{   SELECT cod_evento   
      INTO p_cod_evento
   FROM evento_265 
   WHERE cod_banco = p_tela.cod_banco
   AND tip_evento = 1}

#----------------------------- IMPRIMINDO LISTA --------------------------#
   LET p_sql = 
      "SELECT b.dat_referencia, b.tip_acerto,b.num_cpf,b.nom_funcionario, ",
      " b.num_matricula, b.cod_empresa, e.uni_feder, b.valor_30, b.val_acerto, ",
      " b.val_folha, b.dat_rescisao, b.dat_afastamento, b.observacao, b.mensagem  ",
      "  FROM diverg_consig_265 b ",
      "   LEFT JOIN empresa e ",
      "   ON e.cod_empresa = b.cod_empresa "

   LET p_sql = p_sql CLIPPED, ' '," WHERE b.cod_banco =  ",p_tela.cod_banco," "
   LET p_sql = p_sql CLIPPED, ' ', "   AND to_char(b.dat_referencia, 'YYYY-MM') = '",p_Dat_referencia,"' "
   LET p_sql = p_sql CLIPPED, ' ', "   AND b.tip_diverg = 'F'"
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   
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

   LET p_sql = p_sql CLIPPED, ' ', " order by e.uni_feder,b.cod_empresa,b.nom_funcionario "

   PREPARE var_query FROM p_sql   
   DECLARE cq_padrao CURSOR FOR var_query


   FOREACH cq_padrao INTO 
      p_lista.dat_referencia, p_lista.tipo_acerto,
      p_lista.cpf_func, p_lista.nom_funcionario, 
      p_lista.num_matricula,
      p_lista.empresa, p_lista.uni_feder, 
      p_lista.val_evento, p_lista.val_acerto,
      p_lista.val_folha,p_lista.dat_rescisao,
      p_lista.dat_afasta, p_lista.observacao,
      p_lista.mensagem


      SELECT Sum(val_parcela)
      INTO p_val_banco
      FROM arq_banco_265
      WHERE to_char(dat_referencia, 'YYYY-MM') = p_Dat_referencia
            AND num_cpf   = p_lista.cpf_func
            AND cod_banco = p_tela.cod_banco

      CASE p_lista.tipo_acerto[1,1]    
         WHEN '1'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Descontar' 
         WHEN '2'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Reembolsar' 
         WHEN '3'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Repassar' 
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

      
      # Verifico se os valores entre folha e banco não são nulos
      IF p_lista.mensagem CLIPPED <> 'Valores diferentes'  THEN
      	IF p_lista.val_folha > 0  AND p_val_banco > 0 THEN 
      		IF p_lista.val_folha < p_val_banco THEN
      			LET p_obs_2 = 'Ver se vai descontar R$ '
      		ELSE
      			LET p_obs_2 = 'Ver se vai reembolsar R$ '
      		END IF

     		ELSE 		
      		# Verifico se os valor folha não é nulo
      		IF p_val_banco IS NULL THEN 
      		 	LET p_obs_2 = 'Ver se vai reembolsar: R$ '
      		ELSE
     			  LET p_obs_2 = 'Ver se vai descontar R$ '
      		END IF

     		END IF  		
    END IF 	
	

      IF p_lista.observacao IS NOT NULL THEN
        CALL substrivo(p_lista.observacao[1,225],34,10,'N') 
        	RETURNING p_txt[1].txt,p_txt[2].txt,p_txt[3].txt,p_txt[4].txt,p_txt[5].txt,
        	          p_txt[6].txt,p_txt[7].txt,p_txt[8].txt,p_txt[9].txt,p_txt[10].txt

      END IF
   OUTPUT TO REPORT pol1080_relat(p_lista.dat_referencia) 
      
   LET p_count = p_count + 1
   INITIALIZE p_lista TO NULL
   LET p_val_Diferenca = 0 
                 
   END FOREACH


END FUNCTION


#--------------------------------#
FUNCTION pol1080_emite_Banco()
#--------------------------------#

   FOR p_num_seq = 1 TO 10
    LET p_txt[p_num_seq].txt = NULL
   END FOR
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_negrito     = ascii 27, "E"
   LET p_normal      = ascii 27, "F"
   LET p_count = 0 
   LET p_Data_char      = "01/",p_tela.mesano
   LET p_data           = p_Data_char
   LET p_Dat_referencia = EXTEND(p_data, YEAR TO MONTH)
   LET p_val_Diferenca = 0 
   LET p_obs = NULL
   
#----------------------------- IMPRIMINDO LISTA --------------------------#
   LET p_sql = 
      "SELECT b.dat_referencia, b.tip_acerto,b.num_cpf,b.nom_funcionario, ",
      " b.num_matricula, b.cod_empresa, e.uni_feder, b.valor_30, b.val_acerto, ",
      " b.val_folha, b.dat_rescisao, b.dat_afastamento, b.observacao, b.mensagem,  ",
      " a.val_parcela,a.qtd_parcela,a.num_parcela  ",
      "  FROM arq_banco_265 a, diverg_consig_265 b ",
      "   LEFT JOIN empresa e ",
      "   ON e.cod_empresa = b.cod_empresa "

  


   LET p_sql = p_sql CLIPPED, ' '," WHERE b.cod_banco =  ",p_tela.cod_banco," "
   LET p_sql = p_sql CLIPPED, ' ', "   AND to_char(b.dat_referencia, 'YYYY-MM') = '",p_Dat_referencia,"' "
   LET p_sql = p_sql CLIPPED, ' ', "   AND b.tip_diverg = 'B'"
   LET p_sql = p_sql CLIPPED, ' ', "   AND a.num_cpf = b.num_cpf"
   LET p_sql = p_sql CLIPPED, ' ', "   AND a.cod_banco = b.cod_banco"
   LET p_sql = p_sql CLIPPED, ' ', "   AND a.dat_referencia = b.dat_referencia"
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   
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

   LET p_sql = p_sql CLIPPED, ' ', " order by e.uni_feder,b.cod_empresa,b.nom_funcionario "

   PREPARE var_query2 FROM p_sql   
   DECLARE cq_padrao2 CURSOR FOR var_query2


   FOREACH cq_padrao2 INTO 
      p_lista.dat_referencia, p_lista.tipo_acerto,
      p_lista.cpf_func, p_lista.nom_funcionario, 
      p_lista.num_matricula,
      p_lista.empresa, p_lista.uni_feder, 
      p_lista.val_evento, p_lista.val_acerto,
      p_lista.val_folha,p_lista.dat_rescisao,
      p_lista.dat_afasta, p_lista.observacao,
      p_lista.mensagem, p_val_banco, 
      p_quantidade, p_num_parcela
       
      
            
{      SELECT Sum(val_parcela), qtd_parcela, num_parcela
      INTO p_val_banco, p_quantidade, p_num_parcela
      FROM arq_banco_265
      WHERE dat_referencia = p_Dat_referencia
            AND num_cpf   = p_lista.cpf_func
            AND cod_banco = p_tela.cod_banco
            AND num
      GROUP BY qtd_parcela, num_parcela    }  

      CASE p_lista.tipo_acerto[1,1]    
         WHEN '1'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Descontar' 
         WHEN '2'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Reembolsar' 
         WHEN '3'
            LET p_lista.tipo_acerto = p_lista.tipo_acerto CLIPPED,'-Repassar' 
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

      # Verifico se os valores entre folha e banco não são nulos
      	IF p_lista.val_folha > 0  AND p_lista.val_banco > 0 THEN 
      		IF p_lista.val_folha < p_lista.val_banco THEN
      			LET p_obs_2 = 'Ver se vai descontar R$ '
      		ELSE
      			LET p_obs_2 = 'Ver se vai reembolsar R$ '
      		END IF

     		ELSE 		
      		# Verifico se os valor folha não é nulo
      		IF p_lista.val_banco IS NULL THEN 
      		 	LET p_obs_2 = 'Ver se vai reembolsar: R$ '
      		ELSE
     			  LET p_obs_2 = 'Ver se vai descontar R$ '
      		END IF

     		END IF  		

      	LET p_obs = p_lista.mensagem


      IF p_lista.observacao IS NOT NULL THEN
        CALL substrivo(p_lista.observacao[1,225],23,10,'N') 
        	RETURNING p_txt[1].txt,p_txt[2].txt,p_txt[3].txt,p_txt[4].txt,p_txt[5].txt,
        	          p_txt[6].txt,p_txt[7].txt,p_txt[8].txt,p_txt[9].txt,p_txt[10].txt

      END IF
   OUTPUT TO REPORT pol1080_Banco(p_lista.dat_referencia) 
      
   LET p_count = p_count + 1
   INITIALIZE p_lista TO NULL
   LET p_val_Diferenca = 0 
                 
   END FOREACH


END FUNCTION


#--------------------------------#
FUNCTION pol1080_emite_total()
#--------------------------------#

   FOR p_num_seq = 1 TO 10
    LET p_txt[p_num_seq].txt = NULL
   END FOR
   LET p_estado         = NULL
   LET p_comprime       = ascii 15
   LET p_descomprime    = ascii 18
   LET p_negrito        = ascii 27, "E"
   LET p_normal         = ascii 27, "F"
   LET p_count          = 0 
   LET p_Data_char      = "01/",p_tela.mesano
   LET p_data           = p_Data_char
   LET p_Dat_referencia = EXTEND(p_data, YEAR TO MONTH)
   LET p_val_Diferenca  = 0 
   LET p_val_folha      = 0 
   LET p_qtde_folha     = 0
   LET p_val_folha_parc = 0 
   LET p_qtd_folha      = 0
   LET p_qtde_Diferenca = 0
   LET p_qtde_banco     = 0
   LET p_val_banco      = 0
   LET p_tval_Diferenca  = 0 
   LET p_tval_folha      = 0 
   LET p_tqtde_folha     = 0
   LET p_tqtd_folha      = 0
   LET p_tqtde_Diferenca = 0
 	 LET p_tqtde_banco1    = 0
   LET p_tval_banco1     = 0
 	 LET p_tqtde_banco2    = 0
   LET p_tval_banco2     = 0
 	 LET p_tqtde_banco3    = 0
   LET p_tval_banco3     = 0
   
#----------------------------- GERANDO CABEÇALHO --------------------------#
   LET sql_stmt = 
      "SELECT DISTINCT(cod_banco), den_reduz ",
      "FROM banco_265  "

      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano

   LET sql_stmt = sql_stmt CLIPPED, ' ', " order by cod_banco "

   PREPARE var_query3 FROM sql_stmt   
   DECLARE cq_padrao3 CURSOR FOR var_query3


   FOREACH cq_padrao3 INTO 
      p_lista.cod_banco, p_lista.nom_banco
      

 			LET p_cod_banco4    = p_lista.cod_banco

      CASE p_count    
         WHEN '0'
      			LET p_nom_banco1    = p_lista.nom_banco
      			LET p_cod_banco1    = p_lista.cod_banco
         WHEN '1'
            IF  p_cod_banco1 <> p_cod_banco4 THEN
      				LET p_nom_banco2    = p_lista.nom_banco
      				LET p_cod_banco2    = p_lista.cod_banco
      			END IF	
         WHEN '2'
            IF  p_cod_banco1 <> p_cod_banco4 AND p_cod_banco2 <> p_cod_banco4 THEN
      				LET p_nom_banco3    = p_lista.nom_banco
      				LET p_cod_banco3    = p_lista.cod_banco
      			END IF	
      END CASE


      
   LET p_count = p_count + 1
   END FOREACH

   INITIALIZE p_lista TO NULL
   LET p_val_Diferenca = 0 

#----------------------------- GERANDO DADOS --------------------------#

#------------- PEGANDO UFS DO ARQ_BANCO_265 --------------------------#
   LET sql_stmt = 
         "SELECT DISTINCT(e.uni_feder) ",
         " FROM hist_movto h, empresa e ",
         " WHERE to_char(h.dat_referencia, 'YYYY-MM') = '",p_Dat_referencia,"' ",
         " AND h.cod_evento IN (SELECT cod_evento FROM evento_265) ",
         " AND h.cod_empresa = e.cod_empresa "


   LET p_filtro = "MÊS/ANO: ",p_tela.mesano

   LET sql_stmt = sql_stmt CLIPPED, ' ', " order by e.uni_feder "

   PREPARE var_query4 FROM sql_stmt   
   DECLARE cq_padrao4 CURSOR FOR var_query4

   FOREACH cq_padrao4 INTO 
      p_lista.uni_feder

#------------- PEGANDO VALORES POR BANCO POR ESTADO --------------------------#
    
    
    LET p_qtde_Diferenca = 0
    LET p_qtde_banco     = 0
    LET p_val_banco      = 0
    LET p_qtde_banco1    = 0
    LET p_val_banco1     = 0
    LET p_qtde_banco2    = 0
    LET p_val_banco2     = 0
    LET p_qtde_banco3    = 0
    LET p_val_banco3     = 0

		LET p_sql_2 = 
      		"SELECT a.cod_banco, count(a.cod_banco), sum(a.val_parcela) val_banco ",
      		" FROM arq_banco_265 a, contr_consig_265 c  ",
      		" where c.uf = '",p_lista.uni_feder,"'",
      		" AND a.cod_empresa = c.cod_empresa",
      		" AND a.num_contrato = c.num_contrato",
      		" AND a.num_cpf NOT IN (SELECT d.num_cpf FROM diverg_consig_265 d",
      		" WHERE d.dat_referencia = a.dat_referencia",
      		" AND d.dat_afastamento IS NOT NULL)"


   	LET p_sql_2 = p_sql_2 CLIPPED, ' ', "   AND to_char(a.dat_referencia, 'YYYY-MM') = '",p_Dat_referencia,"' "
      
   	LET p_filtro = "MÊS/ANO: ",p_tela.mesano

   	LET p_sql_2 = p_sql_2 CLIPPED, ' ', " group by a.cod_banco "

   	PREPARE var_query5 FROM p_sql_2   
   DECLARE cq_padrao5 CURSOR FOR var_query5


   FOREACH cq_padrao5 INTO 
      p_lista.cod_banco,
      p_lista.quantidade, p_lista.val_parc_banco

      IF p_lista.cod_banco = p_cod_banco1 THEN
      	LET p_qtde_banco1  = p_lista.quantidade
      	LET p_val_banco1   = p_lista.val_parc_banco
      	IF p_lista.quantidade > 0 THEN 
      		LET p_tqtde_banco1  = p_tqtde_banco1 + p_lista.quantidade
      		LET p_tval_banco1   = p_tval_banco1 + p_lista.val_parc_banco
      	END IF	
      END IF	
      IF p_lista.cod_banco = p_cod_banco2 THEN
      	LET p_qtde_banco2  = p_lista.quantidade
      	LET p_val_banco2   = p_lista.val_parc_banco
      	IF p_lista.quantidade > 0 THEN 
      		LET p_tqtde_banco2  = p_tqtde_banco2 + p_lista.quantidade
      		LET p_tval_banco2   = p_tval_banco2 + p_lista.val_parc_banco
      	END IF	
      END IF	
      IF p_lista.cod_banco = p_cod_banco3 THEN
      	LET p_qtde_banco3  = p_lista.quantidade
      	LET p_val_banco3   = p_lista.val_parc_banco
      	IF p_lista.quantidade > 0 THEN 
      		LET p_tqtde_banco3  = p_tqtde_banco3 + p_lista.quantidade
      		LET p_tval_banco3   = p_tval_banco3 + p_lista.val_parc_banco
      	END IF	
      END IF	
      

                       
      LET p_val_banco   = p_val_banco + p_lista.val_parc_banco
      LET p_qtde_banco  = p_qtde_banco + p_lista.quantidade
      

      LET p_count = p_count + 1
  	END FOREACH

#------------- Calcula valor da Folha por estado ------------#
    	LET p_qtd_Demitido   = 0
    	LET p_val_demitido   = 0
    	LET p_qtd_folha      = 0
    	LET p_val_folha_parc = 0

      IF p_lista.uni_feder = 'RJ' THEN
       LET p_estado = 'RJ'
      ELSE
       LET p_estado = 'BR'
      END IF   
       
      SELECT COUNT(h.cod_evento),SUM(h.val_evento)
      INTO p_qtd_folha,p_val_folha_parc
      FROM hist_movto h, empresa e
      WHERE to_char(h.dat_referencia, 'YYYY-MM') = p_Dat_referencia
            AND h.cod_evento IN (SELECT cod_evento FROM evento_265
                                 WHERE estado  = p_estado)
            AND h.cod_empresa = e.cod_empresa
            AND e.uni_feder   = p_lista.uni_feder


			SELECT COUNT(h.cod_evento),SUM(h.val_evento)
      INTO p_qtd_Demitido,p_val_demitido
      FROM movto_demitidos h, empresa e
      WHERE to_char(dat_referencia, 'YYYY-MM') = p_Dat_referencia
            AND h.cod_evento IN (SELECT cod_evento FROM evento_265
                                 WHERE estado  = p_estado)
            AND h.cod_empresa = e.cod_empresa
            AND e.uni_feder   = p_lista.uni_feder 
            
      LET p_qtde_folha  = p_qtd_folha
      LET p_val_folha   = p_val_folha_parc
      IF p_qtd_Demitido > 0 AND p_val_folha_parc > 0 THEN
      	LET p_qtde_folha  = p_qtd_folha + p_qtd_Demitido
      	LET p_val_folha   = p_val_folha_parc +p_val_demitido
      END IF	
      IF p_qtd_Demitido > 0 AND p_val_folha_parc <= 0 THEN
      	LET p_qtde_folha  = p_qtd_Demitido
      	LET p_val_folha   = p_val_demitido
      END IF	
      LET p_tqtde_folha = p_tqtde_folha + p_qtde_folha
      LET p_tval_folha  = p_tval_folha  + p_val_folha

#------------- CALCULA A DIFERENÇA --------------------------#
   LET p_qtde_Diferenca = p_qtde_folha - p_qtde_banco
   LET p_val_Diferenca  = p_val_folha - p_val_banco
   
   LET p_tqtde_Diferenca = p_tqtde_Diferenca + p_qtde_Diferenca
   LET p_tval_Diferenca  = p_tval_Diferenca + p_val_Diferenca
   
   OUTPUT TO REPORT pol1080_total(p_lista.dat_referencia) 
     
   INITIALIZE p_lista TO NULL
   LET p_val_Diferenca = 0 
                 
   END FOREACH



END FUNCTION


#--------------------------------#
 REPORT pol1080_relat(p_ordem_imp)                              
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
               
         PRINT COLUMN 001, "pol1080",
               COLUMN 050, "CONCILIAÇÃO ENTRE FOLHA E BANCO",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
         PRINT #COLUMN 050, "(((((((((( INCONSISTÊNCIAS ))))))))))"  
               
         PRINT COLUMN 001, '--------------------------------------------------------------------------------------------'
         PRINT COLUMN 001, 'UF|SETOR|                NOME                    |       OBSERVACAO      |     |   VALOR    '
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '--|-----|----------------------------------------|-----------------------|-----|------------'
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 006, p_lista.empresa, 
               COLUMN 009,'|',
               COLUMN 010, p_lista.nom_funcionario[1,40], 
               COLUMN 050,'|',
               COLUMN 051, p_lista.mensagem[1,23],
               COLUMN 074,'|',
               COLUMN 075, "FOLHA", 
               COLUMN 080,'|',
               COLUMN 081, p_lista.val_folha USING '###,##&.&&' 
         PRINT COLUMN 003,'|',
               COLUMN 009,'|',
               COLUMN 010, "CPF: ",p_lista.cpf_func," - MATR.:",p_lista.num_matricula USING '#####', 
               COLUMN 050,'|',
               COLUMN 074,'|',
               COLUMN 075, "BANCO", 
               COLUMN 080,'|',
               COLUMN 081, p_val_banco USING '###,##&.&&' 
							IF p_lista.val_folha < p_val_banco THEN
         				PRINT COLUMN 003,'|',
               	COLUMN 009,'|',
               	COLUMN 010, p_obs_2,p_lista.val_acerto USING '###,##&.&&',
               	COLUMN 050,'|',
               	COLUMN 074,'|',
               	COLUMN 080,'|'
               ELSE
                IF p_val_banco IS NULL OR p_lista.val_folha = p_lista.val_acerto THEN
         					PRINT COLUMN 003,'|',
               		COLUMN 009,'|',
	               	COLUMN 010, p_obs_2,p_lista.val_folha USING '###,##&.&&', 
               		COLUMN 050,'|',
               		COLUMN 074,'|',
               		COLUMN 080,'|'
               	ELSE
               	END IF	
               END IF	
         IF p_val_banco < p_lista.val_folha THEN
         	 PRINT COLUMN 003,'|',
                 COLUMN 009,'|',
                 COLUMN 010, "Ver se é desconto de meses anteriores",
                 COLUMN 050,'|',
                 COLUMN 074,'|',
                 COLUMN 080,'|'
         ELSE
         END IF        
   			 FOR p_num_seq = 1 TO 10
         	 IF p_txt[p_num_seq].txt IS NULL THEN
           ELSE
           	 PRINT COLUMN 003,'|',
                   COLUMN 009,'|',
                   COLUMN 010, p_txt[p_num_seq].txt[1,34],
                   COLUMN 050,'|',
                   COLUMN 074,'|',
                   COLUMN 080,'|'
           END IF      
         END FOR
         PRINT COLUMN 003,'|',
               COLUMN 004,'||||||',
               COLUMN 010, p_lista.tipo_acerto,
               COLUMN 050,'|',
               COLUMN 074,'|',
               COLUMN 080,'|'
               
         PRINT COLUMN 001, '--|-----|----------------------------------------|-----------------------|-----|------------'
      ON LAST ROW 
         PRINT COLUMN 001, '--------------------------------------------------------------------------------------------'
					

END REPORT


#--------------------------------#
 REPORT pol1080_Banco(p_ordem_imp)                              
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
               
         PRINT COLUMN 001, "pol1080",
               COLUMN 050, "CONCILIAÇÃO ENTRE BANCO e FOLHA",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
         PRINT #COLUMN 050, "(((((((((( INCONSISTÊNCIAS ))))))))))"  
               
         PRINT COLUMN 001, '----------------------------------------------------------------------------------------------------------------------------------'
         PRINT COLUMN 001, 'UF|SETOR|                NOME                    |      OBSERVACAO       |    VALOR   | DEMISSAO |  30% RESC. |   INSS   |PARCELA '
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '--|-----|----------------------------------------|-----------------------|------------|----------|------------|----------|--------'
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         IF p_lista.val_evento <= 0 THEN
         	PRINT COLUMN 001, p_lista.uni_feder, 
               	COLUMN 003,'|',
               	COLUMN 006, p_lista.empresa, 
               	COLUMN 009,'|',
               	COLUMN 010, p_lista.nom_funcionario[1,40], 
               	COLUMN 050,'|',
               	COLUMN 051, p_txt[1].txt[1,23],
               	COLUMN 074,'|',
               	COLUMN 075, p_val_banco USING '###,##&.&&',
               	COLUMN 087,'|',
               	COLUMN 098,'|',
               	COLUMN 111,'|',
                  COLUMN 112, p_lista.dat_afasta,
               	COLUMN 122,'|',
               	COLUMN 124, p_num_parcela USING '&&','/',p_quantidade USING '&&' 
         	PRINT COLUMN 003,'|',
               	COLUMN 009,'|',
               	COLUMN 010, "CPF: ",p_lista.cpf_func," - MATR.:",p_lista.num_matricula USING '#####', 
               	COLUMN 050,'|',
               	COLUMN 051, p_txt[2].txt[1,23],
               	COLUMN 074,'|',
               	COLUMN 087,'|',
               	COLUMN 098,'|',
               	COLUMN 111,'|',
               	COLUMN 122,'|'
	    		IF p_lista.dat_afasta IS NOT NULL  THEN
         		PRINT COLUMN 003,'|',
               		COLUMN 009,'|',
               		COLUMN 010, p_obs_2,p_val_banco USING '###,##&.&&',
               		COLUMN 050,'|',
               		COLUMN 051, p_txt[3].txt[1,23],
               		COLUMN 074,'|',
               		COLUMN 087,'|',
               		COLUMN 098,'|',
               		COLUMN 111,'|',
               		COLUMN 122,'|'
           ELSE
         		PRINT COLUMN 003,'|',
               		COLUMN 009,'|',
               		COLUMN 050,'|',
               		COLUMN 051, p_txt[3].txt[1,23],
               		COLUMN 074,'|',
               		COLUMN 087,'|',
               		COLUMN 098,'|',
               		COLUMN 111,'|',
               		COLUMN 122,'|'
           END IF    		
         ELSE
         	PRINT COLUMN 001, p_lista.uni_feder, 
               	COLUMN 003,'|',
               	COLUMN 006, p_lista.empresa, 
               	COLUMN 009,'|',
               	COLUMN 010, p_lista.nom_funcionario[1,40], 
               	COLUMN 050,'|',
               	COLUMN 051, p_txt[1].txt[1,23],
               	COLUMN 074,'|',
               	COLUMN 087,'|',
                  COLUMN 088, p_lista.dat_rescisao,
               	COLUMN 098,'|',
               	COLUMN 099, p_lista.val_evento USING '###,##&.&&',
               	COLUMN 111,'|',
               	COLUMN 122,'|',
               	COLUMN 124, p_num_parcela USING '&&','/',p_quantidade USING '&&' 
         	PRINT COLUMN 003,'|',
               	COLUMN 009,'|',
               	COLUMN 010, "CPF: ",p_lista.cpf_func," - MATR.:",p_lista.num_matricula USING '#####', 
               	COLUMN 050,'|',
               	COLUMN 051, p_txt[2].txt[1,23],
               	COLUMN 074,'|',
               	COLUMN 087,'|',
               	COLUMN 098,'|',
               	COLUMN 111,'|',
               	COLUMN 122,'|'
         	PRINT COLUMN 003,'|',
               	COLUMN 009,'|',
               	COLUMN 010, p_obs_2,p_lista.val_acerto USING '###,##&.&&',
               	COLUMN 050,'|',
               	COLUMN 051, p_txt[3].txt[1,23],
               	COLUMN 074,'|',
               	COLUMN 087,'|',
               	COLUMN 098,'|',
               	COLUMN 111,'|',
               	COLUMN 122,'|'
         END IF      	
         IF p_val_banco < p_lista.val_folha THEN
         	 PRINT COLUMN 003,'|',
                 COLUMN 009,'|',
                 COLUMN 010, "Ver se é desconto de meses anteriores",
                 COLUMN 050,'|',
               	 COLUMN 074,'|',
               	 COLUMN 087,'|',
               	 COLUMN 098,'|',
               	 COLUMN 111,'|',
               	 COLUMN 122,'|'
         ELSE
         END IF        
   			 FOR p_num_seq = 4 TO 10
         	 IF p_txt[p_num_seq].txt IS NULL THEN
           ELSE
           	 PRINT COLUMN 003,'|',
                   COLUMN 009,'|',
                   COLUMN 050,'|',
                   COLUMN 051, p_txt[p_num_seq].txt[1,23],
               	   COLUMN 074,'|',
               	   COLUMN 087,'|',
               	   COLUMN 098,'|',
               	   COLUMN 111,'|',
               	   COLUMN 122,'|'
           END IF      
         END FOR
         PRINT COLUMN 003,'|',
               COLUMN 004,'||||||',
               COLUMN 010, p_lista.tipo_acerto,
               COLUMN 050,'|',
               COLUMN 074,'|',
               COLUMN 087,'|',
               COLUMN 098,'|',
               COLUMN 111,'|',
               COLUMN 122,'|'
               
         PRINT COLUMN 001, '--|-----|----------------------------------------|-----------------------|------------|----------|------------|----------|--------'
      ON LAST ROW 
         PRINT COLUMN 001, '----------------------------------------------------------------------------------------------------------------------------------'
					

END REPORT

#--------------------------------#
 REPORT pol1080_total(p_ordem_imp)                              
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
               
         PRINT COLUMN 001, "pol1080",
               COLUMN 050, "TOTAL DE VALORES CONSIGNADOS FOLHA E BANCO",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
               
         PRINT COLUMN 001, '--------------------------------------------------------------------------------------------------------------------'
#        PRINT COLUMN 001, 'UF| QTD |               | QTD |               | QTD |               | QTD |               | QTD |   DIFERENCA   '
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, 'UF| QTD |  FOLHA        | QTD |',
               COLUMN 032, p_nom_banco1[1,15],
               COLUMN 047, '| QTD |',
               COLUMN 054, p_nom_banco2[1,15],
               COLUMN 069, '| QTD |',
               COLUMN 076, p_nom_banco3[1,15],
               COLUMN 091, '| QTD |   DIFERENCA   '
         PRINT COLUMN 001, '--|-----|---------------|-----|---------------|-----|---------------|-----|---------------|-----|-------------------'
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 004, p_qtde_folha USING '####', 
               COLUMN 009,'|',
               COLUMN 014, p_val_folha USING '###,##&.&&', 
               COLUMN 025,'|',
               COLUMN 026, p_qtde_banco1 USING '####', 
               COLUMN 031,'|',
               COLUMN 032, p_val_banco1 USING '###,##&.&&', 
               COLUMN 047,'|',
               COLUMN 048, p_qtde_banco2 USING '####', 
               COLUMN 053,'|',
               COLUMN 054, p_val_banco2 USING '###,##&.&&', 
               COLUMN 069,'|',
               COLUMN 070, p_qtde_banco3 USING '####', 
               COLUMN 075,'|',
               COLUMN 076, p_val_banco3 USING '###,##&.&&', 
               COLUMN 091,'|',
               COLUMN 070, p_qtde_diferenca USING '####', 
               COLUMN 097,'|',
               COLUMN 076, p_val_Diferenca USING '###,##&.&&' 
               
         PRINT COLUMN 001, '--|-----|---------------|-----|---------------|-----|---------------|-----|---------------|-----|-------------------'
      ON LAST ROW 
         PRINT COLUMN 003,'|',
               COLUMN 004, p_tqtde_folha USING '####', 
               COLUMN 009,'|',
               COLUMN 014, p_tval_folha USING '###,##&.&&', 
               COLUMN 025,'|',
               COLUMN 026, p_tqtde_banco1 USING '####', 
               COLUMN 031,'|',
               COLUMN 032, p_tval_banco1 USING '###,##&.&&', 
               COLUMN 047,'|',
               COLUMN 048, p_tqtde_banco2 USING '####', 
               COLUMN 053,'|',
               COLUMN 054, p_tval_banco2 USING '###,##&.&&', 
               COLUMN 069,'|',
               COLUMN 070, p_tqtde_banco3 USING '####', 
               COLUMN 075,'|',
               COLUMN 076, p_tval_banco3 USING '###,##&.&&', 
               COLUMN 091,'|',
               COLUMN 070, p_tqtde_diferenca USING '####', 
               COLUMN 097,'|',
               COLUMN 076, p_tval_Diferenca USING '###,##&.&&' 
         PRINT COLUMN 001, '--------------------------------------------------------------------------------------------------------------------'
					

END REPORT

#--------------------------------#
FUNCTION pol1080_emite_semBanco()
#--------------------------------#

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_negrito     = ascii 27, "E"
   LET p_normal      = ascii 27, "F"
   LET p_count = 0 
   LET p_Data_char      = "01/",p_tela.mesano
   LET p_data           = p_Data_char
   LET p_Dat_referencia = EXTEND(p_data, YEAR TO MONTH)
   LET p_val_Diferenca = 0 
   
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
   SELECT nom_banco   
      INTO p_nom_banco
   FROM bancos 
   WHERE cod_banco = p_tela.cod_banco

#----------------------------- IMPRIMINDO LISTA --------------------------#
   LET p_sql_4 = 
      "SELECT h.num_matricula, h.num_cpf, h.val_evento, ",
      " (SELECT f.nom_funcionario FROM funcionario f ",
      " where f.num_matricula = h.num_matricula ",
      "  AND f.cod_empresa = h.cod_empresa) AS nome ",
      "  FROM hist_movto_265 h ",
      "  where h.cod_banco is null or cod_banco = 0"

   LET p_sql_4 = p_sql_4 CLIPPED, ' ', "   AND to_char(h.dat_referencia, 'YYYY-MM') = '",p_Dat_referencia,"' "
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   


   PREPARE var_query6 FROM p_sql_4   
   DECLARE cq_padrao6 CURSOR FOR var_query6


   FOREACH cq_padrao6 INTO 
      p_lista.num_matricula,
      p_lista.cpf_func, p_lista.val_evento, 
      p_lista.nom_funcionario
      
    LET p_obs = 'Evento sem banco definido'



   OUTPUT TO REPORT pol1080_semBanco(p_lista.dat_referencia) 
      
   LET p_count = p_count + 1
   INITIALIZE p_lista TO NULL
                 
   END FOREACH


END FUNCTION

#--------------------------------#
 REPORT pol1080_semBanco(p_ordem_imp)                              
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
               
         PRINT COLUMN 001, "pol1080",
               COLUMN 050, "Relação de Eventos sem Banco Definido",
               COLUMN 106, "DATA: ", TODAY USING "DD/MM/YYYY", " - ", TIME
         PRINT COLUMN 057, "BANCO: ",p_tela.nom_banco 
         PRINT COLUMN 001, p_filtro  
               
         PRINT COLUMN 001, '--------------------------------------------------------------------------------------------------------------------'
         PRINT COLUMN 001, '   MATRICULA |     CPF      |               NOME                     |        OBSERVAÇÃO            | PRESTAÇÃO   '
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '-------------|--------------|----------------------------------------|------------------------------|---------------'
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 002, p_lista.num_matricula, 
               COLUMN 014,'|',
               COLUMN 015, p_lista.cpf_func[1,14], 
               COLUMN 029,'|',
               COLUMN 030, p_lista.nom_funcionario[1,40], 
               COLUMN 070,'|',
               COLUMN 071, p_obs, 
               COLUMN 101,'|',
               COLUMN 102, p_lista.val_evento USING '###,##&.&&' 
               
      ON LAST ROW 
         PRINT COLUMN 001, '--------------------------------------------------------------------------------------------------------------------'
					

END REPORT

#-----------------------#
 FUNCTION pol1080_sobre()
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
