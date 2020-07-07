#-------------------------------------------------------------------------#
# SISTEMA.: Relaçao Pagamentos Consignados                        				#
#	PROGRAMA:	pol1081																												#
#	CLIENTE.:	IURD																													#
#	OBJETIVO:	Rel. Conciliação entre Folha e Banco                        	#
#	AUTOR...:	Paulo																												  #
#	DATA....:	10/01/2011																										#
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
          p_data_fim            DATE,
          p_dat_referencia      DATE,
          p_data_divegencia     DATE,
          p_num_seq             SMALLINT,
          p_sql                 CHAR(850),
          p_sql_2               CHAR(500),
          p_sql_3               CHAR(800),
          p_val_Diferenca       DECIMAL(12,2),
          p_val_parc_Nao        DECIMAL(12,2),
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
          p_tqtd_folha          SMALLINT,
          p_qtde_Diferenca      SMALLINT,
          p_evento_banco1       SMALLINT,
          p_evento_banco2       SMALLINT,
          p_evento_banco3       SMALLINT,
          p_cod_tipo            SMALLINT,
          p_val_banco           DECIMAL(12,2),
          p_val_banco1          DECIMAL(12,2),
          p_val_banco2          DECIMAL(12,2),
          p_val_banco3          DECIMAL(12,2),
          p_val_recisao         DECIMAL(12,2),
          p_val_folha           DECIMAL(12,2),
          p_val_folha_parc      DECIMAL(12,2),
          p_tval_banco1         DECIMAL(12,2),
          p_tval_banco2         DECIMAL(12,2),
          p_tval_banco3         DECIMAL(12,2),
          p_tval_folha          DECIMAL(12,2),
          p_count_banco         SMALLINT,
          p_obs                 CHAR(23),
          p_obs_2               CHAR(25),
          p_tqtde_Diferenca     SMALLINT,
          p_tval_Diferenca      DECIMAL(12,2),
          p_filtro              CHAR(120)
               
   DEFINE p_tela                RECORD 
          cod_banco             LIKE bancos.cod_banco,
          nom_banco             LIKE bancos.nom_banco,
          mesano                CHAR(7),
          data_rep              DATE
   END RECORD
          
   DEFINE p_txt  ARRAY[4000] OF RECORD
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
      id_registro               SMALLINT,
      cod_banco                 SMALLINT,
      val_parc_folha            DECIMAL(12,2),
      val_parc_banco            DECIMAL(12,2),
      num_matricula             DECIMAL(8,0),
      empresa                   CHAR(2),
      uni_feder                 CHAR(2),
      dat_rescisao              DATE,
      dat_afasta                DATE,
      dat_liquida               DATE,
      dat_contrato              DATE,
      dat_referencia            DATE,
      observacao                CHAR(225),
      val_evento                DECIMAL(12,2),
      val_parc_Acer             DECIMAL(12,2),
      val_parc_Nao              DECIMAL(12,2),
      quantidade                SMALLINT,
      num_parcela               SMALLINT,
      cod_status                CHAR(1),
      dat_acerto                DATE
   END RECORD 


         
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
	 LET p_versao = "pol1081-10.02.11"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1081.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol1081_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1081_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1081") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1081 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
         
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Listagem"
         HELP 001 
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol1081","IN")  THEN
         		LET p_count = 0
         		LET p_imprime = 0
            IF pol1081_informar() THEN
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
         LET p_imprime = 0
         LET p_count = 0
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol1081","MO") THEN
           IF p_ies_cons THEN 
               IF log0280_saida_relat(13,29) IS NOT NULL THEN
                  MESSAGE " Processando a Extracao do Relatorio..." 
                     ATTRIBUTE(REVERSE)
                     
                  IF p_ies_impressao = "S" THEN
                     IF g_ies_ambiente = "U" THEN
                        START REPORT pol1081_relat TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1081.tmp'
                        START REPORT pol1081_relat  TO p_caminho
                     END IF
                  ELSE
                     START REPORT pol1081_relat TO p_nom_arquivo
                  END IF
                  CALL pol1081_emite_relatorio()   
                  IF p_count = 0 THEN
                     ERROR "Nao Existem Dados para serem Listados" 
                  ELSE
                     ERROR "Relatorio Processado com Sucesso" 
                  END IF
                  FINISH REPORT pol1081_relat   

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
                        START REPORT pol1081_Banco TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1081.tmp'
                        START REPORT pol1081_Banco  TO p_caminho
                     END IF
                  ELSE
                  	 LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_1"
                     START REPORT pol1081_Banco TO p_nom_arquivo
                  END IF
                  CALL pol1081_emite_Banco()   
                  FINISH REPORT pol1081_Banco   

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
                        START REPORT pol1081_autoriza TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1081.tmp'
                        START REPORT pol1081_autoriza  TO p_caminho
                     END IF
                  ELSE
                  	 LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_2"
                     START REPORT pol1081_autoriza TO p_nom_arquivo
                  END IF
                  CALL pol1081_emite_autorizacao()   
                  FINISH REPORT pol1081_autoriza   

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
                        START REPORT pol1081_recisao TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol1081.tmp'
                        START REPORT pol1081_recisao  TO p_caminho
                     END IF
                  ELSE
                  	 LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_3"
                     START REPORT pol1081_recisao TO p_nom_arquivo
                  END IF
                  CALL pol1081_emite_recisao()   
                  FINISH REPORT pol1081_recisao   

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
	       CALL pol1081_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1081

END FUNCTION

#--------------------------#
FUNCTION pol1081_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_cod_tipo  = 5
   
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

   		LET p_Data_char      = "01/",p_tela.mesano
   		LET p_data           = p_Data_char
   		LET p_Dat_referencia = p_Data

      AFTER FIELD data_rep    
      IF p_tela.data_rep IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD data_rep       
      END IF 

#     verifico se existem divergencias não resolvidas no período selecionado, para emitir rel.
      SELECT COUNT(*) duvida
      INTO p_qtd_folha
      FROM diverg_consig_265 d
      WHERE d.tip_acerto = p_cod_tipo
            AND d.dat_referencia = p_Dat_referencia
            AND d.cod_banco = p_tela.cod_banco

      IF p_qtd_folha > 0 THEN
         ERROR "Existem divergências para serem conciliadas"
         NEXT FIELD mesano       
      END IF 


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
FUNCTION pol1081_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_banco)
         CALL log009_popup(8,25,"Banco","bancos",
                     "cod_banco","nom_banco","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1081
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_banco = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_banco
         END IF



   END CASE

END FUNCTION


#--------------------------------#
FUNCTION pol1081_emite_relatorio()
#--------------------------------#

   FOR p_num_seq = 1 TO 30
    LET p_txt[p_num_seq].txt = NULL
   END FOR
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_negrito     = ascii 27, "E"
   LET p_normal      = ascii 27, "F"
   LET p_count = 0 
   LET p_imprime = 0
   LET p_Data_char      = "01/",p_tela.mesano
   LET p_data           = p_Data_char
   LET p_Dat_referencia = p_Data
   LET p_val_folha_parc = 0 
   LET p_tval_banco1    = 0
   LET p_tval_banco2    = 0
   LET p_val_recisao    = 0
   
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
   SELECT nom_banco   
      INTO p_nom_banco
   FROM bancos 
   WHERE cod_banco = p_tela.cod_banco

#----------------------------- GERANDO CABEÇALHO --------------------------#
#  Seleciono todos que estão OK fazendo a somatória
   LET p_sql = 
      "SELECT e.uni_feder, count(a.cod_banco) AS qtde, sum(a.val_parcela) AS valor  ",
      "FROM arq_banco_265 a, contr_consig_265 b  ",
      "LEFT OUTER JOIN empresa e  ",
      "ON e.cod_empresa = b.cod_empresa   ",
      "WHERE b.cod_banco = a.cod_banco  ",
      "AND b.num_contrato = a.num_contrato  ",
      "AND a.num_cpf NOT in (SELECT f.num_cpf  ",
      "FROM arq_banco_265 f, contr_consig_265 g  ",
      "WHERE g.num_contrato = f.num_contrato ",
      "AND f.cod_status = 'D' ",
      "AND ((g.dat_liquidacao is not NULL AND g.dat_liquidacao >  g.dat_contrato) ",
      "OR g.dat_rescisao >  g.dat_contrato ",
      "OR g.dat_afastamento >  g.dat_contrato) ",
      "AND f.cod_banco =  a.cod_banco ",
      "AND f.dat_referencia = a.dat_referencia) " 


   LET p_sql = p_sql CLIPPED, ' ', " AND a.cod_banco =  ",p_tela.cod_banco," "
   LET p_sql = p_sql CLIPPED, ' ', " AND a.dat_referencia = '",p_Dat_referencia,"' "
   LET p_sql = p_sql CLIPPED, ' ', " GROUP BY e.uni_feder "
   LET p_sql = p_sql CLIPPED, ' ', " order by e.uni_feder "
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   

   PREPARE var_query FROM p_sql   
   DECLARE cq_padrao CURSOR FOR var_query


   FOREACH cq_padrao INTO 
      p_lista.uni_feder, p_lista.quantidade,
      p_lista.val_parc_banco
      
      LET p_count = p_count + 1
      LET p_val_folha_parc = p_val_folha_parc + p_lista.val_parc_banco 
      LET p_txt[p_count].txt = "R$ ",p_lista.val_parc_banco USING '###,##&.&&'," - ",
      p_lista.quantidade USING '####'," Funcionarios ",p_lista.uni_feder

   	INITIALIZE p_lista TO NULL
                 
   END FOREACH

#-- somatória geral do arquivo com divergência
	SELECT sum(a.val_parcela) AS valor 
  INTO p_tval_banco2
	FROM arq_banco_265 a, contr_consig_265 b
	LEFT OUTER JOIN empresa e 
	ON e.cod_empresa = b.cod_empresa 
	WHERE b.cod_banco = a.cod_banco
	AND b.num_contrato = a.num_contrato
	AND a.cod_status = 'D'
  AND a.cod_banco = p_tela.cod_banco
  AND a.dat_referencia = p_Dat_referencia
	AND (b.dat_rescisao IS NOT NULL
	or b.dat_afastamento IS NOT NULL
	or b.dat_liquidacao IS NOT NULL)

#-- somatória geral do arquivo enviado pelo Banco
      SELECT sum(val_parcela) AS valor 
      INTO p_tval_banco1
      FROM arq_banco_265
      WHERE cod_banco = p_tela.cod_banco      
      AND dat_referencia = p_Dat_referencia

#-- pega ultimo dia do mes corrente
      SELECT DISTINCT LAST_DAY(TODAY) AS data 
      INTO p_data_fim
      FROM arq_banco_265
      WHERE cod_banco = p_tela.cod_banco      
      AND dat_referencia = p_Dat_referencia


#----------------------------- IMPRIMINDO LISTA --------------------------#
   LET p_sql = 
      "SELECT e.uni_feder, a.cod_empresa,a.num_matricula,a.nom_funcionario,a.num_cpf,Sum(a.val_parcela),",
      " b.dat_rescisao, b.dat_afastamento, b.dat_liquidacao, b.valor_30, b.dat_contrato ",
      " FROM arq_banco_265 a, contr_consig_265 b ",
      " LEFT OUTER JOIN empresa e ",
      " ON e.cod_empresa = b.cod_empresa ",
      " WHERE b.num_contrato = a.num_contrato ",
      " AND a.cod_status = 'D' ",
      " AND ((b.dat_liquidacao is not NULL AND b.dat_liquidacao >  b.dat_contrato)",
      " OR b.dat_rescisao >  b.dat_contrato ",
      " OR b.dat_afastamento >  b.dat_contrato) " 


   LET p_sql = p_sql CLIPPED, ' '," AND a.cod_banco =  ",p_tela.cod_banco," "
   LET p_sql = p_sql CLIPPED, ' '," AND a.dat_referencia = '",p_Dat_referencia,"' "
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   
   LET p_sql = p_sql CLIPPED, ' ', " GROUP BY e.uni_feder,a.cod_empresa,a.num_matricula,a.nom_funcionario,a.num_cpf, "
   LET p_sql = p_sql CLIPPED, ' ', " b.dat_rescisao,b.dat_afastamento, b.dat_liquidacao,b.valor_30, b.dat_contrato "
   LET p_sql = p_sql CLIPPED, ' ', " ORDER BY e.uni_feder,a.nom_funcionario "

   PREPARE var_query2 FROM p_sql   
   DECLARE cq_padrao2 CURSOR FOR var_query2


   FOREACH cq_padrao2 INTO 
      p_lista.uni_feder, p_lista.empresa,
      p_lista.num_matricula, p_lista.nom_funcionario, 
      p_lista.cpf_func, p_lista.val_parc_banco,
      p_lista.dat_rescisao, p_lista.dat_afasta, 
      p_lista.dat_liquida, p_lista.val_evento,
      p_lista.dat_contrato
      
	    IF p_lista.dat_afasta IS NOT NULL AND p_lista.dat_afasta > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "NO INSS"
   			LET p_data_divegencia = p_lista.dat_afasta
   		END IF	

	    IF p_lista.dat_liquida IS NOT NULL AND p_lista.dat_liquida > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "LIQUIDADO"
   			LET p_data_divegencia = p_lista.dat_liquida
   		END IF	

	 		IF p_lista.dat_rescisao IS NOT NULL AND p_lista.dat_rescisao > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "RESCISAO"
   			LET p_data_divegencia = p_lista.dat_rescisao
   		END IF	

   
      IF p_lista.val_evento IS NOT NULL THEN
   			LET p_val_recisao =  p_val_recisao + p_lista.val_evento
   		END IF
   		
   		OUTPUT TO REPORT pol1081_relat(p_lista.dat_referencia) 
      
   		LET p_count = p_count + 1
      LET p_imprime = 1
   		
   		INITIALIZE p_lista TO NULL
   		LET p_val_Diferenca = 0 
                 
   END FOREACH
   if p_imprime = 0 then
   		OUTPUT TO REPORT pol1081_relat(p_lista.dat_referencia) 
   end if 
END FUNCTION


#--------------------------------#
FUNCTION pol1081_emite_Banco()
#--------------------------------#

LET p_tval_banco2 = 0

#----------------------------- IMPRIMINDO LISTA --------------------------#
   LET p_sql = 
      "SELECT e.uni_feder, a.cod_empresa,a.num_matricula,a.nom_funcionario,a.num_cpf,Sum(a.val_parcela),",
      " b.dat_rescisao, b.dat_afastamento, b.dat_liquidacao, b.valor_30, b.dat_contrato ",
      " FROM arq_banco_265 a, contr_consig_265 b ",
      " LEFT OUTER JOIN empresa e ",
      " ON e.cod_empresa = b.cod_empresa ",
      " WHERE b.num_contrato = a.num_contrato ",
      " AND  b.dat_rescisao >  b.dat_contrato  ", 
      " AND a.cod_status = 'D' "


   LET p_sql = p_sql CLIPPED, ' '," AND a.cod_banco =  ",p_tela.cod_banco," "
   LET p_sql = p_sql CLIPPED, ' '," AND a.dat_referencia = '",p_Dat_referencia,"' "
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   
   LET p_sql = p_sql CLIPPED, ' ', " GROUP BY e.uni_feder,a.cod_empresa,a.num_matricula,a.nom_funcionario,a.num_cpf, "
   LET p_sql = p_sql CLIPPED, ' ', " b.dat_rescisao,b.dat_afastamento, b.dat_liquidacao,b.valor_30, b.dat_contrato "
   LET p_sql = p_sql CLIPPED, ' ', " ORDER BY e.uni_feder,a.nom_funcionario "

   PREPARE var_query3 FROM p_sql   
   DECLARE cq_padrao3 CURSOR FOR var_query3


   FOREACH cq_padrao3 INTO 
      p_lista.uni_feder, p_lista.empresa,
      p_lista.num_matricula, p_lista.nom_funcionario, 
      p_lista.cpf_func, p_lista.val_parc_banco,
      p_lista.dat_rescisao, p_lista.dat_afasta, 
      p_lista.dat_liquida, p_lista.val_evento,
      p_lista.dat_contrato
      
	    IF p_lista.dat_afasta IS NOT NULL AND p_lista.dat_afasta > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "NO INSS"
   			LET p_data_divegencia = p_lista.dat_afasta
   		END IF	

	    IF p_lista.dat_liquida IS NOT NULL AND p_lista.dat_liquida > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "LIQUIDADO"
   			LET p_data_divegencia = p_lista.dat_liquida
   		END IF	

	 		IF p_lista.dat_rescisao IS NOT NULL AND p_lista.dat_rescisao > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "RESCISAO"
   			LET p_data_divegencia = p_lista.dat_rescisao
   		END IF	

   
      LET p_tval_banco2 = p_tval_banco2 + p_lista.val_parc_banco
      
   		OUTPUT TO REPORT pol1081_Banco(p_lista.dat_referencia) 
      
   		LET p_count = p_count + 1
      LET p_imprime = 1
   		INITIALIZE p_lista TO NULL
   		LET p_val_Diferenca = 0 
                 
   END FOREACH
   if p_imprime = 0 then
   		OUTPUT TO REPORT pol1081_Banco(p_lista.dat_referencia) 
   end if 


END FUNCTION

#--------------------------------#
FUNCTION pol1081_emite_autorizacao()
#--------------------------------#

   FOR p_num_seq = 1 TO 30
    LET p_txt[p_num_seq].txt = NULL
   END FOR
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_negrito     = ascii 27, "E"
   LET p_normal      = ascii 27, "F"
   LET p_count = 0 
   LET p_imprime = 0
   LET p_Data_char      = "01/",p_tela.mesano
   LET p_data           = p_Data_char
   LET p_Dat_referencia = p_Data
   LET p_val_folha_parc = 0 
   LET p_tval_banco1    = 0
   LET p_tval_banco2    = 0
   LET p_val_recisao    = 0
   
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
   SELECT nom_banco   
      INTO p_nom_banco
   FROM bancos 
   WHERE cod_banco = p_tela.cod_banco

#----------------------------- GERANDO CABEÇALHO --------------------------#
#  Seleciono todos que estão OK fazendo a somatória
   LET p_sql = 
      "SELECT distinct(e.uni_feder), count(a.cod_banco) AS qtde, sum(a.val_parcela) AS valor  ",
      "FROM arq_banco_265 a, contr_consig_265 b  ",
      "LEFT OUTER JOIN empresa e  ",
      "ON e.cod_empresa = b.cod_empresa   ",
      "WHERE b.cod_banco = a.cod_banco  ",
      "AND b.num_contrato = a.num_contrato  ",
      "AND a.num_cpf NOT in (SELECT f.num_cpf  ",
      "FROM arq_banco_265 f, contr_consig_265 g  ",
      "WHERE g.num_contrato = f.num_contrato ",
      "AND f.cod_status = 'D' ",
      "AND ((g.dat_liquidacao is not NULL AND g.dat_liquidacao >  g.dat_contrato) ",
      "OR g.dat_rescisao >  g.dat_contrato ",
      "OR g.dat_afastamento >  g.dat_contrato) ",
      "AND f.cod_banco =  a.cod_banco ",
      "AND f.dat_referencia = a.dat_referencia) " 


   LET p_sql = p_sql CLIPPED, ' ', " AND a.cod_banco =  ",p_tela.cod_banco," "
   LET p_sql = p_sql CLIPPED, ' ', " AND a.dat_referencia = '",p_Dat_referencia,"' "
   LET p_sql = p_sql CLIPPED, ' ', " GROUP BY e.uni_feder "
   LET p_sql = p_sql CLIPPED, ' ', " order by e.uni_feder "
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   

   PREPARE var_query_2 FROM p_sql   
   DECLARE cq_padrao_2 CURSOR FOR var_query_2


   FOREACH cq_padrao_2 INTO 
      p_lista.uni_feder, p_lista.quantidade,
      p_lista.val_parc_banco
      
      LET p_count = p_count + 1
      LET p_val_folha_parc = p_val_folha_parc + p_lista.val_parc_banco 
      LET p_txt[p_count].txt = "R$ ",p_lista.val_parc_banco USING '###,##&.&&'," - ",
      p_lista.quantidade USING '####'," Funcionarios ",p_lista.uni_feder

   	INITIALIZE p_lista TO NULL
                 
   END FOREACH

#-- somatória geral do arquivo com divergência
	SELECT sum(a.val_parcela) AS valor 
  INTO p_tval_banco2
	FROM arq_banco_265 a, contr_consig_265 b
	LEFT OUTER JOIN empresa e 
	ON e.cod_empresa = b.cod_empresa 
	WHERE b.cod_banco = a.cod_banco
	AND b.num_contrato = a.num_contrato
	AND a.cod_status = 'D'
	AND (b.dat_rescisao IS NOT NULL
	or b.dat_afastamento IS NOT NULL
	or b.dat_liquidacao IS NOT NULL)
  AND a.cod_banco = p_tela.cod_banco
  AND a.dat_referencia = p_Dat_referencia


#-- somatória geral do arquivo enviado pelo Banco
      SELECT sum(val_parcela) AS valor 
      INTO p_tval_banco1
      FROM arq_banco_265
      WHERE cod_banco = p_tela.cod_banco      
      AND dat_referencia = p_Dat_referencia

#-- pega ultimo dia do mes corrente
      SELECT DISTINCT LAST_DAY(TODAY) AS data 
      INTO p_data_fim
      FROM arq_banco_265
      WHERE cod_banco = p_tela.cod_banco      
      AND dat_referencia = p_Dat_referencia


#----------------------------- IMPRIMINDO LISTA --------------------------#
   LET p_sql = 
      "SELECT e.uni_feder, a.cod_empresa,a.num_matricula,a.nom_funcionario,a.num_cpf,Sum(a.val_parcela),",
      " b.dat_rescisao, b.dat_afastamento, b.dat_liquidacao, b.valor_30, b.dat_contrato ",
      " FROM arq_banco_265 a, contr_consig_265 b ",
      " LEFT OUTER JOIN empresa e ",
      " ON e.cod_empresa = b.cod_empresa ",
      " WHERE b.num_contrato = a.num_contrato ",
      " AND a.cod_status = 'D' ",
      " AND ((b.dat_liquidacao is not NULL AND b.dat_liquidacao >  b.dat_contrato)",
      " OR b.dat_rescisao >  b.dat_contrato ",
      " OR b.dat_afastamento >  b.dat_contrato) " 


   LET p_sql = p_sql CLIPPED, ' '," AND a.cod_banco =  ",p_tela.cod_banco," "
   LET p_sql = p_sql CLIPPED, ' '," AND a.dat_referencia = '",p_Dat_referencia,"' "
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   
   LET p_sql = p_sql CLIPPED, ' ', " GROUP BY e.uni_feder,a.cod_empresa,a.num_matricula,a.nom_funcionario,a.num_cpf, "
   LET p_sql = p_sql CLIPPED, ' ', " b.dat_rescisao,b.dat_afastamento, b.dat_liquidacao,b.valor_30, b.dat_contrato "
   LET p_sql = p_sql CLIPPED, ' ', " ORDER BY e.uni_feder,a.nom_funcionario "

   PREPARE var_query_3 FROM p_sql   
   DECLARE cq_padrao_3 CURSOR FOR var_query_3

   LET p_count = 0 

   FOREACH cq_padrao_3 INTO 
      p_lista.uni_feder, p_lista.empresa,
      p_lista.num_matricula, p_lista.nom_funcionario, 
      p_lista.cpf_func, p_lista.val_parc_banco,
      p_lista.dat_rescisao, p_lista.dat_afasta, 
      p_lista.dat_liquida, p_lista.val_evento,
      p_lista.dat_contrato
      
	    IF p_lista.dat_afasta IS NOT NULL AND p_lista.dat_afasta > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "NO INSS"
   			LET p_data_divegencia = p_lista.dat_afasta
   		END IF	

	    IF p_lista.dat_liquida IS NOT NULL AND p_lista.dat_liquida > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "LIQUIDADO"
   			LET p_data_divegencia = p_lista.dat_liquida
   		END IF	

	 		IF p_lista.dat_rescisao IS NOT NULL AND p_lista.dat_rescisao > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "RESCISAO"
   			LET p_data_divegencia = p_lista.dat_rescisao
   		END IF	

   
      IF p_lista.val_evento IS NOT NULL THEN
   			LET p_val_recisao =  p_val_recisao + p_lista.val_evento
   		END IF
   		
   		OUTPUT TO REPORT pol1081_autoriza(p_lista.dat_referencia) 
      
   		LET p_count = p_count + 1
      LET p_imprime = 1
   		INITIALIZE p_lista TO NULL
   		LET p_val_Diferenca = 0 
                 
   END FOREACH
    if p_imprime = 0 then
   		OUTPUT TO REPORT pol1081_autoriza(p_lista.dat_referencia) 
   end if 


END FUNCTION


#--------------------------------#
 REPORT pol1081_relat(p_ordem_imp)                              
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
                           
         PRINT COLUMN 001, p_descomprime,
               COLUMN 010, "IGREJA UNIVERSAL DO REINO DE DEUS", 
               COLUMN 075, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 012, "ADMINISTRACAO DE PESSOAL - SP"
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, p_descomprime,
                           "pol1081",
               COLUMN 70, "CI.INTERNA"
         PRINT COLUMN 001, "De  : Recursos Humanos - Depto. CONSIGNADO" 
         PRINT COLUMN 001, "Para: Departamento Financeiro/SP" 
         PRINT COLUMN 001, "Data: ",TODAY USING "DD/MM/YYYY", " - ", TIME  
         PRINT COLUMN 001, "Ref.: ", p_tela.mesano," - EMPRESTIMO CONSIGNADO ",p_tela.nom_banco 
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, p_descomprime,
                           "Informamos que o valor do Repasse dos Descontos dos Emprestimos Consignados" 
         PRINT COLUMN 001, "dos funcionários no ",p_tela.nom_banco CLIPPED," é de R$ ",p_val_folha_parc USING '###,##&.&&' 
         PRINT
         IF p_count > 28 THEN
         	LET p_count = 28
         END IF
   			 FOR p_num_seq = 1 TO p_count-1
         	 IF p_txt[p_num_seq].txt IS NULL THEN
         	 	PRINT
           ELSE
           	 PRINT COLUMN 001, p_txt[p_num_seq].txt
           END IF      
         END FOR
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, p_descomprime,
                          "(+) TOTAL do Arquivo do ",p_tela.nom_banco CLIPPED,"   R$ ",p_tval_banco1 USING '###,##&.&&' 
         PRINT COLUMN 001,"(-) TOTAL Rescisao/Inss/Liquidados R$ ",p_tval_banco2 USING '###,##&.&&' 
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"

         PRINT COLUMN 001, 'UF|SETOR|MATRICULA |                NOME                    |     CPF      |   MOTIVO   |   DATA   | PRESTACAO  |    RESCISAO 30%'
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '--|-----|----------|----------------------------------------|--------------|------------|----------|------------|--------------------'
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 006, p_lista.empresa, 
               COLUMN 009,'|',
               COLUMN 0010, p_lista.num_matricula USING '#####', 
               COLUMN 020,'|',
               COLUMN 021, p_lista.nom_funcionario[1,40], 
               COLUMN 061,'|',
               COLUMN 062, p_lista.cpf_func[1,14],
               COLUMN 076,'|',
               COLUMN 077, p_lista.tipo_acerto[1,12], 
               COLUMN 089,'|',
               COLUMN 090, p_data_divegencia,
               COLUMN 100,'|',
               COLUMN 101, p_lista.val_parc_banco USING '###,##&.&&', 
               COLUMN 113,'|',
               COLUMN 117, p_lista.val_evento USING '###,##&.&&'
               
         PRINT COLUMN 001, '--|-----|----------|----------------------------------------|--------------|------------|----------|------------|--------------------'
      ON LAST ROW 
         PRINT COLUMN 001, 'TOTAL .............................................................................................|',
               COLUMN 101, p_tval_banco2 USING '###,##&.&&', 
               COLUMN 113,'|',
               COLUMN 117, p_val_recisao USING '###,##&.&&'
         PRINT COLUMN 001, '-------------------------------------------------------------------------------------------------------------------------------------'
				 PRINT COLUMN 001, p_descomprime,p_negrito	
         PRINT COLUMN 001, "(=) TOTAL do Repasse para o  ",p_tela.nom_banco CLIPPED,"   R$ ",p_val_folha_parc USING '###,##&.&&' 
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '--------------------------------------------------------------------------------'
         PRINT COLUMN 001, "Devendo ser autorizado o Debito de R$ ",p_val_folha_parc USING '###,##&.&&'," em ",p_tela.data_rep USING "DD/MM/YYYY"
         PRINT
         PRINT
         PRINT COLUMN 001, '______________________________________'
         PRINT COLUMN 001, '  IGREJA UNIVERSAL DO REINO DE DEUS'
         
END REPORT

#--------------------------------#
 REPORT pol1081_autoriza(p_ordem_imp)                              
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
                           
         PRINT COLUMN 001, p_descomprime,
               COLUMN 010, "IGREJA UNIVERSAL DO REINO DE DEUS", 
               COLUMN 075, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 012, "ADMINISTRACAO DE PESSOAL - SP"
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, p_descomprime,
                           "pol1081",
               COLUMN 70, "CI.INTERNA"
         PRINT COLUMN 001, "De  : Recursos Humanos - Depto. CONSIGNADO" 
         PRINT COLUMN 001, "Para: Departamento Financeiro/SP" 
         PRINT COLUMN 001, "Data: ",TODAY USING "DD/MM/YYYY", " - ", TIME  
         PRINT COLUMN 001, "Ref.: ", p_tela.mesano," - EMPRESTIMO CONSIGNADO ",p_tela.nom_banco 
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, p_descomprime,
                           "Autorizamos o Debito na conta corrente 1255-6 no valor de R$",p_val_folha_parc USING '###,##&.&&' CLIPPED,","
         PRINT COLUMN 001, "referente ao repasse do desconto de Emprestimo Consignado dos seguintes estados:"
         PRINT
   			 FOR p_num_seq = 1 TO p_count-1
         	 IF p_txt[p_num_seq].txt IS NULL THEN
         	 	PRINT
           ELSE
           	 PRINT COLUMN 001, p_txt[p_num_seq].txt
           END IF      
         END FOR
         PRINT
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"

         PRINT COLUMN 001, 'UF|SETOR|MATRICULA |                NOME                    |     CPF      |   MOTIVO   |   DATA   | PRESTACAO  |    RESCISAO 30%'
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '--|-----|----------|----------------------------------------|--------------|------------|----------|------------|--------------------'
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 006, p_lista.empresa, 
               COLUMN 009,'|',
               COLUMN 0010, p_lista.num_matricula USING '#####', 
               COLUMN 020,'|',
               COLUMN 021, p_lista.nom_funcionario[1,40], 
               COLUMN 061,'|',
               COLUMN 062, p_lista.cpf_func[1,14],
               COLUMN 076,'|',
               COLUMN 077, p_lista.tipo_acerto[1,12], 
               COLUMN 089,'|',
               COLUMN 090, p_data_divegencia,
               COLUMN 100,'|',
               COLUMN 101, p_lista.val_parc_banco USING '###,##&.&&', 
               COLUMN 113,'|',
               COLUMN 117, p_lista.val_evento USING '###,##&.&&'
               
         PRINT COLUMN 001, '--|-----|----------|----------------------------------------|--------------|------------|----------|------------|--------------------'
      ON LAST ROW 
         PRINT COLUMN 001, 'TOTAL .............................................................................................|',
               COLUMN 101, p_tval_banco2 USING '###,##&.&&', 
               COLUMN 113,'|',
               COLUMN 117, p_val_recisao USING '###,##&.&&'
         PRINT COLUMN 001, '-------------------------------------------------------------------------------------------------------------------------------------'
				 PRINT COLUMN 001, p_descomprime,p_negrito	
         PRINT
         PRINT
         PRINT COLUMN 001, "Atenciosamente,"
         PRINT
         PRINT
         PRINT COLUMN 001, '______________________________________'
         PRINT COLUMN 001, '  IGREJA UNIVERSAL DO REINO DE DEUS'
         
END REPORT


#--------------------------------#
 REPORT pol1081_Banco(p_ordem_imp)                              
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
                           
         PRINT COLUMN 001, p_descomprime,
               COLUMN 010, "IGREJA UNIVERSAL DO REINO DE DEUS", 
               COLUMN 075, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 012, "ADMINISTRACAO DE PESSOAL - SP"
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, p_descomprime,
                           "pol1081",
               COLUMN 70, "CI.INTERNA"
         PRINT COLUMN 001, "De  : Recursos Humanos - Depto. CONSIGNADO" 
         PRINT COLUMN 001, "Para: Departamento Financeiro/SP" 
         PRINT COLUMN 001, "Data: ",TODAY USING "DD/MM/YYYY", " - ", TIME  
         PRINT COLUMN 001, "Ref.: ", p_tela.mesano," - EMPRESTIMO CONSIGNADO ",p_tela.nom_banco 
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, p_descomprime,
                           "Informamos que o valor do Repasse dos 30% do Valor Liquido das Rescisoes" 
         PRINT COLUMN 001, "dos funcionários no ",p_tela.nom_banco CLIPPED," é de R$ ",p_val_recisao USING '###,##&.&&' 
         PRINT
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"

         PRINT COLUMN 001, 'UF|SETOR|MATRICULA |                NOME                    |     CPF      |   MOTIVO   |   DATA   | PRESTACAO  |    RESCISAO 30%'
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '--|-----|----------|----------------------------------------|--------------|------------|----------|------------|--------------------'
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 006, p_lista.empresa, 
               COLUMN 009,'|',
               COLUMN 0010, p_lista.num_matricula USING '#####', 
               COLUMN 020,'|',
               COLUMN 021, p_lista.nom_funcionario[1,40], 
               COLUMN 061,'|',
               COLUMN 062, p_lista.cpf_func[1,14],
               COLUMN 076,'|',
               COLUMN 077, p_lista.tipo_acerto[1,12], 
               COLUMN 089,'|',
               COLUMN 090, p_lista.dat_rescisao,
               COLUMN 100,'|',
               COLUMN 101, p_lista.val_parc_banco USING '###,##&.&&', 
               COLUMN 113,'|',
               COLUMN 117, p_lista.val_evento USING '###,##&.&&'
               
         PRINT COLUMN 001, '--|-----|----------|----------------------------------------|--------------|------------|----------|------------|--------------------'
      ON LAST ROW 
         PRINT COLUMN 001, 'TOTAL .............................................................................................|',
               COLUMN 101, p_tval_banco2 USING '###,##&.&&', 
               COLUMN 113,'|',
               COLUMN 117, p_val_recisao USING '###,##&.&&'
         PRINT COLUMN 001, '-------------------------------------------------------------------------------------------------------------------------------------'
				 PRINT COLUMN 001, p_descomprime,p_negrito	
         PRINT COLUMN 001, "(=) TOTAL do Repasse para o  ",p_tela.nom_banco CLIPPED,"   R$ ",p_val_recisao USING '###,##&.&&' 
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '--------------------------------------------------------------------------------'
         PRINT COLUMN 001, "Devendo ser autorizado o Debito de R$ ",p_val_recisao USING '###,##&.&&'," em ",p_tela.data_rep USING "DD/MM/YYYY"
         PRINT
         PRINT
         PRINT COLUMN 001, '______________________________________'
         PRINT COLUMN 001, '  IGREJA UNIVERSAL DO REINO DE DEUS'

END REPORT

#--------------------------------#
FUNCTION pol1081_emite_recisao()
#--------------------------------#

LET p_tval_banco2 = 0

#----------------------------- IMPRIMINDO LISTA --------------------------#
   LET p_sql = 
      "SELECT e.uni_feder, a.cod_empresa,a.num_matricula,a.nom_funcionario,a.num_cpf,Sum(a.val_parcela),",
      " b.dat_rescisao, b.dat_afastamento, b.dat_liquidacao, b.valor_30, b.dat_contrato ",
      " FROM arq_banco_265 a, contr_consig_265 b ",
      " LEFT OUTER JOIN empresa e ",
      " ON e.cod_empresa = b.cod_empresa ",
      " WHERE b.num_contrato = a.num_contrato ",
      " AND  b.dat_rescisao >  b.dat_contrato  ", 
      " AND a.cod_status = 'D' "


   LET p_sql = p_sql CLIPPED, ' '," AND a.cod_banco =  ",p_tela.cod_banco," "
   LET p_sql = p_sql CLIPPED, ' '," AND a.dat_referencia = '",p_Dat_referencia,"' "
      
   LET p_filtro = "MÊS/ANO: ",p_tela.mesano
   
   LET p_sql = p_sql CLIPPED, ' ', " GROUP BY e.uni_feder,a.cod_empresa,a.num_matricula,a.nom_funcionario,a.num_cpf, "
   LET p_sql = p_sql CLIPPED, ' ', " b.dat_rescisao,b.dat_afastamento, b.dat_liquidacao,b.valor_30, b.dat_contrato "
   LET p_sql = p_sql CLIPPED, ' ', " ORDER BY e.uni_feder,a.nom_funcionario "

   PREPARE var_query_4 FROM p_sql   
   DECLARE cq_padrao_4 CURSOR FOR var_query_4


   FOREACH cq_padrao_4 INTO 
      p_lista.uni_feder, p_lista.empresa,
      p_lista.num_matricula, p_lista.nom_funcionario, 
      p_lista.cpf_func, p_lista.val_parc_banco,
      p_lista.dat_rescisao, p_lista.dat_afasta, 
      p_lista.dat_liquida, p_lista.val_evento,
      p_lista.dat_contrato
      
	    IF p_lista.dat_afasta IS NOT NULL AND p_lista.dat_afasta > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "NO INSS"
   			LET p_data_divegencia = p_lista.dat_afasta
   		END IF	

	    IF p_lista.dat_liquida IS NOT NULL AND p_lista.dat_liquida > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "LIQUIDADO"
   			LET p_data_divegencia = p_lista.dat_liquida
   		END IF	

	 		IF p_lista.dat_rescisao IS NOT NULL AND p_lista.dat_rescisao > p_lista.dat_contrato THEN
      	LET p_lista.tipo_acerto = "RESCISAO"
   			LET p_data_divegencia = p_lista.dat_rescisao
   		END IF	

   
      LET p_tval_banco2 = p_tval_banco2 + p_lista.val_parc_banco
      
   		OUTPUT TO REPORT pol1081_recisao(p_lista.dat_referencia) 
      
   		LET p_count = p_count + 1
      LET p_imprime = 1
   		INITIALIZE p_lista TO NULL
   		LET p_val_Diferenca = 0 
                 
   END FOREACH
    if p_imprime = 0 then
   			OUTPUT TO REPORT pol1081_recisao(p_lista.dat_referencia) 
   end if 


END FUNCTION

#--------------------------------#
 REPORT pol1081_recisao(p_ordem_imp)                              
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
                           
         PRINT COLUMN 001, p_descomprime,
               COLUMN 010, "IGREJA UNIVERSAL DO REINO DE DEUS", 
               COLUMN 075, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 012, "ADMINISTRACAO DE PESSOAL - SP"
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, p_descomprime,
                           "pol1081",
               COLUMN 70, "CI.INTERNA"
         PRINT COLUMN 001, "De  : Recursos Humanos - Depto. CONSIGNADO" 
         PRINT COLUMN 001, "Para: Departamento Financeiro/SP" 
         PRINT COLUMN 001, "Data: ",TODAY USING "DD/MM/YYYY", " - ", TIME  
         PRINT COLUMN 001, "Ref.: ", p_tela.mesano," - EMPRESTIMO CONSIGNADO ",p_tela.nom_banco 
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"
         PRINT COLUMN 001, p_descomprime,
                           "Autorizamos o Debito na conta corrente 1255-6 no valor de R$",p_val_recisao USING '###,##&.&&' CLIPPED,","
         PRINT COLUMN 001, "referente a Rescisao de Contrato dos Emprestimos Consignados dos funcionários"
         PRINT COLUMN 001, "conforme abaixo relacionado:"
         PRINT
         PRINT COLUMN 001, p_comprime,
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"

         PRINT COLUMN 001, 'UF|SETOR|MATRICULA |                NOME                    |     CPF      |   MOTIVO   |   DATA   | PRESTACAO  |    RESCISAO 30%'
                           #         1         2         3         4         5         6         7         8         9        10        11        12        13            
                           #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         PRINT COLUMN 001, '--|-----|----------|----------------------------------------|--------------|------------|----------|------------|--------------------'
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
         PRINT COLUMN 001, p_lista.uni_feder, 
               COLUMN 003,'|',
               COLUMN 006, p_lista.empresa, 
               COLUMN 009,'|',
               COLUMN 0010, p_lista.num_matricula USING '#####', 
               COLUMN 020,'|',
               COLUMN 021, p_lista.nom_funcionario[1,40], 
               COLUMN 061,'|',
               COLUMN 062, p_lista.cpf_func[1,14],
               COLUMN 076,'|',
               COLUMN 077, p_lista.tipo_acerto[1,12], 
               COLUMN 089,'|',
               COLUMN 090, p_lista.dat_rescisao,
               COLUMN 100,'|',
               COLUMN 101, p_lista.val_parc_banco USING '###,##&.&&', 
               COLUMN 113,'|',
               COLUMN 117, p_lista.val_evento USING '###,##&.&&'
               
         PRINT COLUMN 001, '--|-----|----------|----------------------------------------|--------------|------------|----------|------------|--------------------'
      ON LAST ROW 
         PRINT COLUMN 001, 'TOTAL .............................................................................................|',
               COLUMN 101, p_tval_banco2 USING '###,##&.&&', 
               COLUMN 113,'|',
               COLUMN 117, p_val_recisao USING '###,##&.&&'
         PRINT COLUMN 001, '-------------------------------------------------------------------------------------------------------------------------------------'
				 PRINT COLUMN 001, p_descomprime,p_negrito
				 PRINT
				 PRINT	
         PRINT COLUMN 001, "Atenciosamente,"
         PRINT
         PRINT
         PRINT COLUMN 001, '______________________________________'
         PRINT COLUMN 001, '  IGREJA UNIVERSAL DO REINO DE DEUS'

END REPORT

#-----------------------#
 FUNCTION pol1081_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


 
#-------------------------------- FIM DE PROGRAMA -----------------------------#
