#-------------------------------------------------------------------#
# SISTEMA.: COMERCIAL                                               #
# PROGRAMA: pol0304                                                 #
# MODULOS.: pol0304 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: EMISSAO DE ETIQUETAS P/ CLIENTES / REPRESENTANTE - INCA #
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
      cgc_cpf_de          LIKE clientes.num_cgc_cpf,
      cgc_cpf_ate         LIKE clientes.num_cgc_cpf,
      cod_cliente_de      LIKE clientes.cod_cliente,
      cod_cliente_ate     LIKE clientes.cod_cliente,
      cod_repres_de       LIKE pedidos.cod_repres, 
      cod_repres_ate      LIKE pedidos.cod_repres,
      cod_transpor_de     LIKE pedidos.cod_transpor,
      cod_transpor_ate    LIKE pedidos.cod_transpor,
      cod_uni_feder       LIKE cidades.cod_uni_feder
   END RECORD

   DEFINE t_cliente ARRAY[3000] OF RECORD
      num_cgc_cpf         LIKE clientes.num_cgc_cpf,
      nom_cliente         LIKE clientes.nom_cliente
   END RECORD

   DEFINE p_relat RECORD
      nom_cliente         LIKE clientes.nom_cliente,
      end_cliente         LIKE clientes.end_cliente,
      complemento         CHAR(30),
      den_bairro          LIKE clientes.den_bairro,
      den_cidade          LIKE cidades.den_cidade,
      cod_cep             LIKE clientes.cod_cep,
      cod_uni_feder       LIKE cidades.cod_uni_feder,
      nom_contato         LIKE clientes.nom_contato
   END RECORD
END GLOBALS
MAIN
#  CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao="POL0304-10.02.04"
   INITIALIZE p_nom_help TO NULL
   CALL log140_procura_caminho("pol0304.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0304_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0304_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0304") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0304 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Listar" "Lista Etiquetas de Clientes"
         HELP 000
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0304","CO")  THEN
            CALL pol0304_listar()
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0304_sobre() 
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 001
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0304

END FUNCTION

#-----------------------#
FUNCTION pol0304_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#------------------------#
 FUNCTION pol0304_listar()
#------------------------#

   DEFINE where_clause, sql_stmt CHAR(500),
          p_cod_item    LIKE mov_est_fis.cod_item

   INITIALIZE p_tela.* TO NULL
   CALL log006_exibe_teclas("02 07",p_versao)
   CURRENT WINDOW IS w_pol0304
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD cgc_cpf_de
      IF p_tela.cgc_cpf_de IS NOT NULL THEN
         SELECT num_cgc_cpf
         FROM clientes
         WHERE num_cgc_cpf = p_tela.cgc_cpf_de 
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cgc_cpf_de
         END IF
      ELSE
         NEXT FIELD cod_cliente_de
      END IF

      AFTER FIELD cgc_cpf_ate
      IF p_tela.cgc_cpf_ate IS NOT NULL THEN
         SELECT num_cgc_cpf
         FROM clientes
         WHERE num_cgc_cpf = p_tela.cgc_cpf_ate 
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cgc_cpf_ate
         END IF
      END IF
      IF p_tela.cgc_cpf_de > p_tela.cgc_cpf_ate THEN
         ERROR "Cliente Inicial tem que ser Menor que Final"
         NEXT FIELD cgc_cpf_de
      ELSE
         NEXT FIELD cod_uni_feder 
      END IF

      AFTER FIELD cod_cliente_de 
      IF p_tela.cod_cliente_de IS NOT NULL THEN
         SELECT cod_cliente   
         FROM clientes
         WHERE cod_cliente = p_tela.cod_cliente_de 
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cod_cliente_de 
         END IF
      ELSE
         NEXT FIELD cod_repres_de
      END IF

      AFTER FIELD cod_cliente_ate
      IF p_tela.cod_cliente_ate IS NOT NULL THEN
         SELECT cod_cliente
         FROM clientes
         WHERE cod_cliente = p_tela.cod_cliente_ate
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cod_cliente_ate
         END IF
      END IF
      IF p_tela.cod_cliente_de > p_tela.cod_cliente_ate THEN
         ERROR "Cliente Inicial tem que ser Menor que Final"
         NEXT FIELD cod_cliente_de
      ELSE
         NEXT FIELD cod_uni_feder 
      END IF

      AFTER FIELD cod_repres_de 
      IF p_tela.cod_repres_de IS NOT NULL THEN
         SELECT cod_repres
         FROM representante
         WHERE cod_repres = p_tela.cod_repres_de
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Representante nao Cadastrado"
            NEXT FIELD cod_repres_de
         END IF
      ELSE
         NEXT FIELD cod_transpor_de
      END IF

      AFTER FIELD cod_repres_ate
      IF p_tela.cod_repres_ate IS NOT NULL THEN
         SELECT cod_repres
         FROM representante
         WHERE cod_repres = p_tela.cod_repres_ate
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Representante nao Cadastrado"
            NEXT FIELD cod_repres_ate
         END IF
      END IF
      IF p_tela.cod_repres_de > p_tela.cod_repres_ate THEN
         ERROR "Representante Inicial tem que ser Menor que Final"
         NEXT FIELD cod_repres_de
      ELSE
         EXIT INPUT
      END IF

      AFTER FIELD cod_transpor_de
      IF p_tela.cod_transpor_de IS NOT NULL THEN
         SELECT UNIQUE cod_transpor
         FROM pedidos
         WHERE cod_transpor = p_tela.cod_transpor_de
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Transportadora nao Cadastrada"
            NEXT FIELD cod_transpor_de
         END IF
      ELSE
         NEXT FIELD cod_uni_feder
      END IF

      AFTER FIELD cod_transpor_ate
      IF p_tela.cod_transpor_ate IS NOT NULL THEN
         SELECT UNIQUE cod_transpor
         FROM pedidos
         WHERE cod_transpor = p_tela.cod_transpor_ate
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Transportadora nao Cadastrada"
            NEXT FIELD cod_transpor_ate
         END IF
      END IF
      IF p_tela.cod_transpor_de > p_tela.cod_transpor_ate THEN
         ERROR "Transportadora Inicial tem que ser Menor que Final"
         NEXT FIELD cod_transpor_de
      ELSE
         EXIT INPUT
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
            CALL pol0304_popup()
               RETURNING p_tela.cgc_cpf_de
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0304
            DISPLAY p_tela.cgc_cpf_de TO cgc_cpf_de
         END IF
         IF INFIELD(cgc_cpf_ate) THEN
            CALL pol0304_popup()
               RETURNING p_tela.cgc_cpf_ate
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0304
            DISPLAY p_tela.cgc_cpf_ate TO cgc_cpf_ate
         END IF
         IF INFIELD(cod_cliente_de) THEN
            LET p_tela.cod_cliente_de = vdp372_popup_cliente()
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0304 
            DISPLAY p_tela.cod_cliente_de TO cod_cliente_de
         END IF
         IF INFIELD(cod_cliente_ate) THEN
            LET p_tela.cod_cliente_ate = vdp372_popup_cliente()
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0304 
            DISPLAY p_tela.cod_cliente_ate TO cod_cliente_ate
         END IF
         IF INFIELD(cod_uni_feder) THEN
            CALL log009_popup(6,20,"UNIDADE FEDERACAO","uni_feder",
                              "cod_uni_feder","den_uni_feder",
                              "","N","")
               RETURNING p_tela.cod_uni_feder
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0304
            DISPLAY p_tela.cod_uni_feder TO cod_uni_feder
         END IF
           
   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Funcao Cancelada"
      INITIALIZE p_tela.* TO NULL
      RETURN
   END IF

   CURRENT WINDOW IS w_pol0304
   IF log028_saida_relat(18,29) IS NOT NULL THEN
      MESSAGE "Processando a Extracao do Relatorio..." ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U"  THEN
            START REPORT pol0304_relat TO PIPE p_nom_arquivo
         ELSE
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0304.tmp'
            START REPORT pol0304_relat TO p_caminho 
         END IF
      ELSE
         START REPORT pol0304_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN
   END IF 
   CURRENT WINDOW IS w_pol0304

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2"
   LET p_8lpp        = ascii 27, "0"

   IF p_tela.cgc_cpf_de IS NOT NULL AND 
      p_tela.cod_cliente_de IS NULL AND  
      p_tela.cod_repres_de IS NULL AND
      p_tela.cod_transpor_de IS NULL AND
      p_tela.cod_uni_feder IS NULL THEN
      LET sql_stmt = "SELECT * ",
                     "FROM clientes ",
                     "WHERE num_cgc_cpf BETWEEN '",p_tela.cgc_cpf_de,"' ",
                     " AND '",p_tela.cgc_cpf_ate,"' ",
                     " ORDER BY num_cgc_cpf " 
   END IF  

   IF p_tela.cod_cliente_de IS NOT NULL AND 
      p_tela.cgc_cpf_de IS NULL AND   
      p_tela.cod_repres_de IS NULL AND
      p_tela.cod_transpor_de IS NULL AND
      p_tela.cod_uni_feder IS NULL THEN
      LET sql_stmt = "SELECT * ",
                     "FROM clientes ",
                     "WHERE cod_cliente BETWEEN '",p_tela.cod_cliente_de,"' ",
                     " AND '",p_tela.cod_cliente_ate,"' ",
                     " ORDER BY cod_cliente "
   END IF  

   IF p_tela.cod_repres_de IS NOT NULL AND
      p_tela.cgc_cpf_de IS NULL AND
      p_tela.cod_cliente_de IS NULL AND
      p_tela.cod_transpor_de IS NULL AND
      p_tela.cod_uni_feder IS NULL THEN
      LET sql_stmt = "SELECT UNIQUE a.* ",
                     "FROM clientes a, pedidos b ",
                     "WHERE a.cod_cliente = b.cod_cliente ",
                     "  AND b.cod_empresa = '",p_cod_empresa,"' ", 
                     "  AND b.cod_repres BETWEEN '",p_tela.cod_repres_de,"' ",
                     "  AND '",p_tela.cod_repres_ate,"' ",
                     " ORDER BY a.cod_cliente "
   END IF  

   IF p_tela.cod_transpor_de IS NOT NULL AND
      p_tela.cgc_cpf_de IS NULL AND 
      p_tela.cod_cliente_de IS NULL AND 
      p_tela.cod_repres_de IS NULL AND
      p_tela.cod_uni_feder IS NULL THEN
      LET sql_stmt = "SELECT UNIQUE a.* ",
                     "FROM clientes a, pedidos b ",
                     "WHERE a.cod_cliente = b.cod_cliente ",
                     "  AND b.cod_empresa = '",p_cod_empresa,"' ", 
                     "AND b.cod_transpor BETWEEN '",p_tela.cod_transpor_de,"' ",
                     "  AND '",p_tela.cod_transpor_ate,"' ",
                     " ORDER BY a.cod_cliente "
   END IF  

   IF p_tela.cod_uni_feder IS NOT NULL AND
      p_tela.cgc_cpf_de IS NULL AND 
      p_tela.cod_cliente_de IS NULL AND 
      p_tela.cod_repres_de IS NULL AND
      p_tela.cod_transpor_de IS NULL THEN
      LET sql_stmt = "SELECT a.* ",
                     "FROM clientes a, cidades b ",
                     "WHERE a.cod_cidade = b.cod_cidade ",
                     "  AND b.cod_uni_feder = '",p_tela.cod_uni_feder,"' ",
                     " ORDER BY a.cod_cliente "
   END IF  

   IF p_tela.cgc_cpf_de IS NOT NULL AND 
      p_tela.cod_cliente_de IS NULL AND 
      p_tela.cod_repres_de IS NULL AND
      p_tela.cod_transpor_de IS NULL AND 
      p_tela.cod_uni_feder IS NOT NULL THEN
      LET sql_stmt = "SELECT a.* ",
                     "FROM clientes a, cidades b ",
                     "WHERE a.cod_cidade = b.cod_cidade ",
                     " AND a.num_cgc_cpf BETWEEN '",p_tela.cgc_cpf_de,"' ",
                     " AND '",p_tela.cgc_cpf_ate,"' ",
                     " AND b.cod_uni_feder = '",p_tela.cod_uni_feder,"' ",
                     " ORDER BY a.num_cgc_cpf " 
   END IF    

   IF p_tela.cod_cliente_de IS NOT NULL AND 
      p_tela.cgc_cpf_de IS NULL AND 
      p_tela.cod_repres_de IS NULL AND
      p_tela.cod_transpor_de IS NULL AND  
      p_tela.cod_uni_feder IS NOT NULL THEN
      LET sql_stmt = "SELECT a.* ",
                     "FROM clientes a, cidades b ",
                     "WHERE a.cod_cidade = b.cod_cidade ",
                     "  AND a.cod_cliente BETWEEN '",p_tela.cod_cliente_de,"' ",
                     "  AND '",p_tela.cod_cliente_ate,"' ",
                     "  AND b.cod_uni_feder = '",p_tela.cod_uni_feder,"' ",
                     " ORDER BY a.cod_cliente "
   END IF  

   IF p_tela.cgc_cpf_de IS NULL AND
      p_tela.cod_cliente_de IS NULL AND  
      p_tela.cod_repres_de IS NULL AND
      p_tela.cod_transpor_de IS NULL AND  
      p_tela.cod_uni_feder IS NULL THEN
      LET sql_stmt = "SELECT * FROM clientes ",
                     " ORDER BY nom_cliente " 
   END IF

   PREPARE var_query FROM sql_stmt
   DECLARE cq_etiq CURSOR WITH HOLD FOR var_query

   FOREACH cq_etiq INTO p_clientes.*

      LET p_relat.nom_cliente   = p_clientes.nom_cliente
      LET p_relat.end_cliente   = p_clientes.end_cliente
      LET p_relat.den_bairro    = p_clientes.den_bairro
      LET p_relat.cod_cep       = p_clientes.cod_cep
      LET p_relat.nom_contato   = p_clientes.nom_contato

      SELECT den_cidade,
             cod_uni_feder
         INTO p_relat.den_cidade,
              p_relat.cod_uni_feder
      FROM cidades
      WHERE cod_cidade = p_clientes.cod_cidade
      

      #Ivo 08/02/2013...

      SELECT compl_endereco
        INTO p_relat.complemento
        FROM vdp_cli_fornec_cpl
       WHERE cliente_fornecedor =  p_clientes.cod_cliente
         AND tip_cadastro = p_clientes.ies_cli_forn

      IF STATUS <> 0 THEN
         LET p_relat.complemento = ''
      END IF
      #......até aqui
      
      OUTPUT TO REPORT pol0304_relat(p_relat.*) 
      LET p_count = p_count + 1

   END FOREACH
   FINISH REPORT pol0304_relat  

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
 FUNCTION pol0304_popup()
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol03041") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol03041 AT 6,25 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, FORM LINE FIRST, PROMPT LINE LAST)

   INITIALIZE t_cliente TO NULL
   CLEAR FORM

   LET INT_FLAG = FALSE

   DECLARE c_cliente CURSOR WITH HOLD FOR
   SELECT num_cgc_cpf,
          nom_cliente 
   FROM clientes
   ORDER BY num_cgc_cpf

   LET p_i = 1
   FOREACH c_cliente INTO t_cliente[p_i].num_cgc_cpf,
                          t_cliente[p_i].nom_cliente

      LET p_i = p_i + 1
      IF p_i > 3000 THEN
         EXIT FOREACH
      END IF

   END FOREACH 

   LET p_i = p_i - 1
  
   CALL SET_COUNT(p_i)

   DISPLAY ARRAY t_cliente TO s_cliente.*
   END DISPLAY

   LET pa_curr = ARR_CURR()
   CLOSE WINDOW w_pol03041 
   RETURN t_cliente[pa_curr].num_cgc_cpf

END FUNCTION

#----------------------------#
 REPORT pol0304_relat(p_relat)
#----------------------------#

   DEFINE p_relat RECORD
      nom_cliente    LIKE clientes.nom_cliente,
      end_cliente    LIKE clientes.end_cliente,
      complemento         CHAR(30),
      den_bairro     LIKE clientes.den_bairro,
      den_cidade     LIKE cidades.den_cidade,
      cod_cep        LIKE clientes.cod_cep,
      cod_uni_feder  LIKE cidades.cod_uni_feder,
      nom_contato    LIKE clientes.nom_contato
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
         PRINT COLUMN 01,"A35,005,0,4,1,2,N,",'"',p_relat.nom_cliente CLIPPED,'"'
         PRINT COLUMN 01,"A35,060,0,4,1,1,N,",'"',p_relat.end_cliente CLIPPED,'"'
         PRINT COLUMN 01,"A35,100,0,4,1,1,N,",'"',p_relat.complemento CLIPPED,'"'
         PRINT COLUMN 01,"A35,140,0,4,1,1,N,",'"',p_relat.den_bairro CLIPPED,'"'
         PRINT COLUMN 01,"A35,180,0,4,1,1,N,",'"',p_relat.cod_cep CLIPPED," ",
               p_relat.den_cidade CLIPPED," ",p_relat.cod_uni_feder,'"'
         PRINT COLUMN 001,"A35,255,0,4,1,2,N,",'"',"A/C: ", p_relat.nom_contato
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
