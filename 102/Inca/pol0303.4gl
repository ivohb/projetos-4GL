#-------------------------------------------------------------------#
# SISTEMA.: COMERCIAL                                               #
# PROGRAMA: pol0303                                                 #
# MODULOS.: pol0303 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: EMISSAO DE ETIQUETAS P/ FORNECEDOR - INCA               #
#-------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_user          LIKE usuario.nom_usuario,
          p_etiq_ini      LIKE nf_mestre.num_nff,
          p_etiq_fim      LIKE nf_mestre.num_nff,
          p_den_uni_feder LIKE uni_feder.den_uni_feder,
          p_status        SMALLINT,
          p_erro          SMALLINT,
          comando         CHAR(80),
          p_nom_arquivo   CHAR(100),
          p_caminho       CHAR(080),
          p_nom_tela      CHAR(200),
          p_nom_help      CHAR(200),
          p_ies_impressao CHAR(01),
          g_ies_ambiente  CHAR(01),
          p_filtro        CHAR(120),
          p_versao        CHAR(18),
          pa_curr         SMALLINT,
          sc_curr         SMALLINT,
          p_ies_cons      SMALLINT,
          p_last_row      SMALLINT,
          p_count         SMALLINT,
          p_i             SMALLINT,
          p_msg           char(300) 

   DEFINE p_fornecedor    RECORD LIKE fornecedor.*,
          p_clientes      RECORD LIKE clientes.*,
          p_cidades       RECORD LIKE cidades.*

   DEFINE p_comprime      CHAR(01),
          p_descomprime   CHAR(01),
          p_6lpp          CHAR(02),
          p_8lpp          CHAR(02)

   DEFINE p_tela RECORD
      cgc_cpf_de          LIKE fornecedor.num_cgc_cpf,
      cgc_cpf_ate         LIKE fornecedor.num_cgc_cpf,
      cod_fornec_de       LIKE fornecedor.cod_fornecedor,
      cod_fornec_ate      LIKE fornecedor.cod_fornecedor,
      cod_uni_feder       LIKE fornecedor.cod_uni_feder
   END RECORD

   DEFINE t_fornec ARRAY[1500] OF RECORD
      num_cgc_cpf         LIKE fornecedor.num_cgc_cpf,
      raz_social          LIKE fornecedor.raz_social
   END RECORD

   DEFINE p_relat RECORD
      raz_social          LIKE fornecedor.raz_social,
      end_fornec          LIKE fornecedor.end_fornec,
      den_bairro          LIKE fornecedor.den_bairro,
      den_cidade          LIKE cidades.den_cidade,
      cod_cep             LIKE fornecedor.cod_cep,
      cod_uni_feder       LIKE fornecedor.cod_uni_feder,
      nom_contato         LIKE fornecedor.nom_contato
   END RECORD
END GLOBALS
MAIN
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao="POL0303-10.02.00"
   INITIALIZE p_nom_help TO NULL
   CALL log140_procura_caminho("pol0303.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0303_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0303_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0303") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0303 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Listar" "Lista Etiquetas do Fornecedor"
         HELP 000
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0303","CO")  THEN
            CALL pol0303_listar()
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0303_sobre() 
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 001
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0303

END FUNCTION

#-----------------------#
FUNCTION pol0303_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------#
 FUNCTION pol0303_listar()
#------------------------#

   DEFINE where_clause, sql_stmt CHAR(500),
          p_cod_item    LIKE mov_est_fis.cod_item

   INITIALIZE p_tela.* TO NULL
   CALL log006_exibe_teclas("02 07",p_versao)
   CURRENT WINDOW IS w_pol0303
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD cgc_cpf_de
      IF p_tela.cgc_cpf_de IS NOT NULL THEN
         SELECT num_cgc_cpf
         FROM fornecedor 
         WHERE num_cgc_cpf = p_tela.cgc_cpf_de 
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Fornecedor nao Cadastrado"
            NEXT FIELD cgc_cpf_de
         END IF
      ELSE
         NEXT FIELD cod_fornec_de 
      END IF

      AFTER FIELD cgc_cpf_ate
      IF p_tela.cgc_cpf_ate IS NOT NULL THEN
         SELECT num_cgc_cpf
         FROM fornecedor 
         WHERE num_cgc_cpf = p_tela.cgc_cpf_ate 
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Fornecedor nao Cadastrado"
            NEXT FIELD cgc_cpf_ate
         END IF
      END IF
      IF p_tela.cgc_cpf_de > p_tela.cgc_cpf_ate THEN
         ERROR "Fornecedor Inicial tem que ser Menor que Final"
         NEXT FIELD cgc_cpf_de
      ELSE
         NEXT FIELD cod_uni_feder 
      END IF

      AFTER FIELD cod_fornec_de 
      IF p_tela.cod_fornec_de IS NOT NULL THEN
         SELECT cod_fornecedor
         FROM fornecedor 
         WHERE cod_fornecedor = p_tela.cod_fornec_de 
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Fornecedor nao Cadastrado"
            NEXT FIELD cod_fornec_de 
         END IF
      ELSE
         NEXT FIELD cod_uni_feder
      END IF

      AFTER FIELD cod_fornec_ate
      IF p_tela.cod_fornec_ate IS NOT NULL THEN
         SELECT cod_fornecedor
         FROM fornecedor 
         WHERE cod_fornecedor = p_tela.cod_fornec_ate
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Fornecedor nao Cadastrado"
            NEXT FIELD cod_fornec_ate
         END IF
      END IF
      IF p_tela.cod_fornec_de > p_tela.cod_fornec_ate THEN
         ERROR "Fornecedor Inicial tem que ser Menor que Final"
         NEXT FIELD cod_fornec_de
      END IF

      AFTER FIELD cod_uni_feder  
      IF p_tela.cod_uni_feder IS NOT NULL THEN
         SELECT den_uni_feder
            INTO p_den_uni_feder 
         FROM uni_feder
         WHERE cod_uni_feder = p_tela.cod_uni_feder
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Unidade da Federacao nao Cadastrada"
            NEXT FIELD cod_uni_feder
         ELSE
            DISPLAY p_den_uni_feder TO den_uni_feder
         END IF
      END IF

      ON KEY (control-z)
         IF INFIELD(cgc_cpf_de) THEN
            CALL pol0303_popup()
               RETURNING p_tela.cgc_cpf_de
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0303
            DISPLAY p_tela.cgc_cpf_de TO cgc_cpf_de
         END IF
         IF INFIELD(cgc_cpf_ate) THEN
            CALL pol0303_popup()
               RETURNING p_tela.cgc_cpf_ate
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0303
            DISPLAY p_tela.cgc_cpf_ate TO cgc_cpf_ate
         END IF
         IF INFIELD(cod_fornec_de) THEN
            CALL log009_popup(6,20,"FORNECEDOR","fornecedor",
                              "cod_fornecedor","raz_social",
                              "","N","")
               RETURNING p_tela.cod_fornec_de
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0303
            DISPLAY p_tela.cod_fornec_de TO cod_fornec_de
         END IF
         IF INFIELD(cod_fornec_ate) THEN
            CALL log009_popup(6,20,"FORNECEDOR","fornecedor",
                              "cod_fornecedor","raz_social",
                              "","N","")
               RETURNING p_tela.cod_fornec_ate
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0303
            DISPLAY p_tela.cod_fornec_ate TO cod_fornec_ate
         END IF
         IF INFIELD(cod_uni_feder) THEN
            CALL log009_popup(6,20,"UNIDADE FEDERACAO","uni_feder",
                              "cod_uni_feder","den_uni_feder",
                              "","N","")
               RETURNING p_tela.cod_uni_feder
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0303
            DISPLAY p_tela.cod_uni_feder TO cod_uni_feder
         END IF
           
   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Funcao Cancelada"
      INITIALIZE p_tela.* TO NULL
      RETURN
   END IF

   CURRENT WINDOW IS w_pol0303
   IF log028_saida_relat(15,29) IS NOT NULL THEN
      MESSAGE "Processando a Extracao do Relatorio..." ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U"  THEN
            START REPORT pol0303_relat TO PIPE p_nom_arquivo
         ELSE
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0303.tmp'
            START REPORT pol0303_relat TO p_caminho 
         END IF
      ELSE
         START REPORT pol0303_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN
   END IF 
   CURRENT WINDOW IS w_pol0303

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2"
   LET p_8lpp        = ascii 27, "0"

   IF p_tela.cgc_cpf_de IS NOT NULL AND 
      p_tela.cod_fornec_de IS NULL AND 
      p_tela.cod_uni_feder IS NULL THEN
      LET sql_stmt = "SELECT * ",
                     "FROM fornecedor ",
                     "WHERE num_cgc_cpf BETWEEN '",p_tela.cgc_cpf_de,"' ",
                     " AND '",p_tela.cgc_cpf_ate,"' ",
                     " ORDER BY num_cgc_cpf " 
   END IF  

   IF p_tela.cod_fornec_de IS NOT NULL AND 
      p_tela.cgc_cpf_de IS NULL AND 
      p_tela.cod_uni_feder IS NULL THEN
      LET sql_stmt = "SELECT * ",
                     "FROM fornecedor ",
                     "WHERE cod_fornecedor BETWEEN '",p_tela.cod_fornec_de,"' ",
                     " AND '",p_tela.cod_fornec_ate,"' ",
                     " ORDER BY cod_fornecedor "
   END IF  

   IF p_tela.cgc_cpf_de IS NULL AND 
      p_tela.cod_fornec_de IS NULL AND 
      p_tela.cod_uni_feder IS NOT NULL THEN
      LET sql_stmt = "SELECT * ",
                     "FROM fornecedor ",
                     "WHERE cod_uni_feder = '",p_tela.cod_uni_feder,"' ",
                     " ORDER BY cod_fornecedor "
   END IF  

   IF p_tela.cgc_cpf_de IS NOT NULL AND 
      p_tela.cod_fornec_de IS NULL AND 
      p_tela.cod_uni_feder IS NOT NULL THEN
      LET sql_stmt = "SELECT * ",
                     "FROM fornecedor ",
                     "WHERE num_cgc_cpf BETWEEN '",p_tela.cgc_cpf_de,"' ",
                     " AND '",p_tela.cgc_cpf_ate,"' ",
                     " AND cod_uni_feder = '",p_tela.cod_uni_feder,"' ",
                     " ORDER BY num_cgc_cpf "
   END IF  

   IF p_tela.cod_fornec_de IS NOT NULL AND 
      p_tela.cgc_cpf_de IS NULL AND 
      p_tela.cod_uni_feder IS NOT NULL THEN
      LET sql_stmt = "SELECT * ",
                     "FROM fornecedor ",
                     "WHERE cod_fornecedor BETWEEN '",p_tela.cod_fornec_de,"' ",
                     " AND '",p_tela.cod_fornec_ate,"' ",
                     " AND cod_uni_feder = '",p_tela.cod_uni_feder,"' ",
                     " ORDER BY cod_fornecedor "
   END IF  

   IF p_tela.cgc_cpf_de IS NULL AND
      p_tela.cod_fornec_de IS NULL AND 
      p_tela.cod_uni_feder IS NULL THEN
      LET sql_stmt = "SELECT * FROM fornecedor ",
                     " ORDER BY raz_social " 
   END IF  

   PREPARE var_query FROM sql_stmt
   DECLARE cq_etiq CURSOR WITH HOLD FOR var_query

   FOREACH cq_etiq INTO p_fornecedor.*

      LET p_relat.raz_social    = p_fornecedor.raz_social
      LET p_relat.end_fornec    = p_fornecedor.end_fornec
      LET p_relat.den_bairro    = p_fornecedor.den_bairro
      LET p_relat.cod_cep       = p_fornecedor.cod_cep
      LET p_relat.cod_uni_feder = p_fornecedor.cod_uni_feder
      LET p_relat.nom_contato   = p_fornecedor.nom_contato

      SELECT den_cidade
         INTO p_relat.den_cidade
      FROM cidades
      WHERE cod_cidade = p_fornecedor.cod_cidade

      OUTPUT TO REPORT pol0303_relat(p_relat.*) 
      LET p_count = p_count + 1

   END FOREACH
   FINISH REPORT pol0303_relat  

   IF p_count > 0 THEN
      IF p_ies_impressao = "S" THEN
         MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
            ATTRIBUTE(REVERSE)
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo, " " 
            ATTRIBUTE(REVERSE)
      END IF
      ERROR "Fim de Processamento..."
   ELSE
      MESSAGE "Nao Existem Dados p/ serem Listados"
         ATTRIBUTE(REVERSE)
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0303_popup()
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol03031") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol03031 AT 6,25 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, FORM LINE FIRST, PROMPT LINE LAST)

   INITIALIZE t_fornec TO NULL
   CLEAR FORM

   LET INT_FLAG = FALSE

   DECLARE c_fornec CURSOR WITH HOLD FOR
   SELECT num_cgc_cpf,
          raz_social
   FROM fornecedor
   ORDER BY num_cgc_cpf

   LET p_i = 1
   FOREACH c_fornec INTO t_fornec[p_i].num_cgc_cpf,
                         t_fornec[p_i].raz_social

      IF p_i > 1500 THEN
         EXIT FOREACH
      END IF
      LET p_i = p_i + 1

   END FOREACH 

   LET p_i = p_i - 1
  
   CALL SET_COUNT(p_i)

   DISPLAY ARRAY t_fornec TO s_fornec.*
   END DISPLAY

   LET pa_curr = ARR_CURR()
   CLOSE WINDOW w_pol03031 
   RETURN t_fornec[pa_curr].num_cgc_cpf

END FUNCTION

#----------------------------#
 REPORT pol0303_relat(p_relat)
#----------------------------#

   DEFINE p_relat RECORD
      raz_social          LIKE fornecedor.raz_social,
      end_fornec          LIKE fornecedor.end_fornec,
      den_bairro          LIKE fornecedor.den_bairro,
      den_cidade          LIKE cidades.den_cidade,
      cod_cep             LIKE fornecedor.cod_cep,
      cod_uni_feder       LIKE fornecedor.cod_uni_feder,
      nom_contato         LIKE fornecedor.nom_contato
   END RECORD

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 12

   FORMAT

   #  BEFORE GROUP OF p_relat.num_nff 
   
   #  WHILE p_relat.impress <= p_relat.qtd_embal  
   #     SKIP TO TOP OF PAGE  

      ON EVERY ROW

         PRINT COLUMN 01,"N"   
         PRINT COLUMN 01,"S2"  
         PRINT COLUMN 01,"D5"  
         PRINT COLUMN 01,"ZT"         
         PRINT COLUMN 01,"R0,0" 
         PRINT COLUMN 01,"A35,005,0,4,1,2,N,",'"',p_relat.raz_social CLIPPED,'"'
         PRINT COLUMN 01,"A35,060,0,4,1,1,N,",'"',p_relat.end_fornec CLIPPED,'"'
         PRINT COLUMN 01,"A35,100,0,4,1,1,N,",'"',p_relat.den_bairro CLIPPED,'"'
         PRINT COLUMN 01,"A35,140,0,4,1,1,N,",'"',p_relat.cod_cep CLIPPED," ",
               p_relat.den_cidade CLIPPED," ",p_relat.cod_uni_feder,'"'
         PRINT COLUMN 001,"A35,185,0,4,1,2,N,",'"',"A/C: ", p_relat.nom_contato
               CLIPPED,'"'
   #     PRINT COLUMN 001,"A85,240,0,4,2,2,N,",'"',"CONTROLE ", 
   #           p_relat.num_pedido CLIPPED,'"'
   #     PRINT COLUMN 001,"A85,295,0,4,2,2,N,",'"',"VOLUME ", 
   #           p_relat.impress USING "###&"," / ",p_tela.num_etiq,'"'
         PRINT COLUMN 001,"P1"  
   #     SKIP 4 LINES

   #     LET  p_relat.impress = p_relat.impress + 1

   #  END WHILE

END REPORT
#------------------------------ FIM DE PROGRAMA -------------------------------#
