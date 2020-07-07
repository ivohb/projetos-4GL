#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1287                                                 #
# OBJETIVO: PLACAS PARA TRANSPORTADORES                             #
# AUTOR...: DOUGLAS GREGORIO                                        #
# DATA....: 20/07/15                                                #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_cod_transp         CHAR(02),
          p_cod_transp_auto    CHAR(02),
          p_ies_ambiente       CHAR(01),
          p_cod_tip_cli        CHAR(02),
          p_ies_tara           SMALLINT


   DEFINE pr_transpor          ARRAY[1000] OF RECORD
          num_placa            LIKE transportador_placa_885.num_placa,
          tara_minima          LIKE transportador_placa_885.tara_minima,
          controle             CHAR(03)
   END RECORD

   DEFINE p_cod_transpor       LIKE transportador_placa_885.cod_transpor,
          pp_cod_transpor_dest LIKE transportador_placa_885.cod_transpor,
          p_cod_transpor_ant   LIKE transportador_placa_885.cod_transpor,
          p_nom_transpor       LIKE clientes.nom_cliente,
          p_num_placa          LIKE transportador_placa_885.num_placa,
          p_tara_minima        LIKE transportador_placa_885.tara_minima

END GLOBALS

DEFINE p_dat_atu CHAR(10)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1287-10.02.01  "
   CALL func002_versao_prg(p_versao)
   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1287_menu()
   END IF
END MAIN


#----------------------#
 FUNCTION pol1287_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1287") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1287 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol1287_parametros() THEN
      CLOSE WINDOW w_pol1287
      RETURN
   END IF

   LET p_dat_atu = EXTEND(CURRENT, YEAR TO DAY)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1287_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1287_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte"
         ELSE
            ERROR 'consulta cancela !!!'
         END IF
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1287_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1287_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1287_modificacao() RETURNING p_status
            IF p_status THEN
               DISPLAY p_cod_transpor TO cod_transpor
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1287_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1287_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1287

END FUNCTION

#----------------------------#
FUNCTION pol1287_parametros()#
#----------------------------#

   SELECT substring(par_vdp_txt,215,2)
     INTO p_cod_transp
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET p_msg = 'Não foi possivel ler parâmetro do\n',
                  'transportador na tabela par_vdp.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_cod_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF STATUS <> 0 THEN
      LET p_msg = 'Não foi possivel ler parâmetro do\n',
                  'transportador na tabela par_vdp_pad.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol1287_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa       TO cod_empresa
   INITIALIZE pr_transpor      TO NULL
   INITIALIZE p_cod_transpor   TO NULL
   LET p_opcao = 'I'

   IF pol1287_edita_dados() THEN
      IF pol1287_edita_transpor('I') THEN
         IF pol1287_grava_dados() THEN
            RETURN TRUE
         END IF
      END IF
   END IF

   RETURN FALSE

END FUNCTION



#-----------------------------#
 FUNCTION pol1287_edita_dados()
#-----------------------------#

   LET INT_FLAG = FALSE
   LET p_ies_tara = FALSE

   INPUT p_cod_transpor WITHOUT DEFAULTS
    FROM cod_transpor

      AFTER FIELD cod_transpor
         
         IF p_cod_transpor IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD cod_transpor
         END IF

         SELECT nom_cliente, cod_tip_cli
           INTO p_nom_transpor, p_cod_tip_cli
           FROM clientes
          WHERE cod_cliente = p_cod_transpor

         IF STATUS = 100 THEN
            ERROR "Transportador não cadastrado !!!"
            NEXT FIELD cod_transpor
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('lendo','clientes')
               RETURN FALSE
            END IF
         END IF

         IF p_cod_tip_cli = p_cod_transp OR p_cod_tip_cli = p_cod_transp_auto THEN
         ELSE
            ERROR ('O codigo informado não é de um transportar')
            NEXT FIELD cod_transpor
         END IF

         SELECT COUNT(cod_transpor)
           INTO p_count
           FROM fornec_tara_minima_885
          WHERE cod_transpor = p_cod_transpor

         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','fornec_tara_minima_885')
            RETURN FALSE
         END IF

         IF p_count > 0 THEN
            LET p_ies_tara = TRUE
         END IF

         DISPLAY p_nom_transpor TO nom_transpor

         SELECT COUNT(cod_transpor)
           INTO p_count
           FROM transportador_placa_885
          WHERE cod_transpor = p_cod_transpor

         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','transportador_placa_885')
            RETURN FALSE
         END IF

         IF p_count > 0 THEN
            ERROR "Transportador já cadastrado - Use a opção modificar"
            NEXT FIELD cod_transpor
         END IF

      ON KEY (control-z)
         CALL pol1287_popup()

   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#---------------------------------#
 FUNCTION pol1287_carrega_placa()
#---------------------------------#

   INITIALIZE pr_transpor TO NULL

   LET p_index = 1

   DECLARE cq_array CURSOR FOR

    SELECT num_placa, tara_minima
      FROM transportador_placa_885
     WHERE cod_transpor = p_cod_transpor
     ORDER BY cod_transpor, num_placa

   FOREACH cq_array
      INTO pr_transpor[p_index].num_placa,
           pr_transpor[p_index].tara_minima

      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "cursor: cq_array")
         RETURN FALSE
      END IF
     
     LET pr_transpor[p_index].controle = p_index
     
     LET p_index = p_index + 1

      IF p_index > 1000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF

   END FOREACH

   CALL SET_COUNT(p_index - 1)

   DISPLAY p_cod_transpor TO cod_transpor
   DISPLAY p_nom_transpor TO nom_transpor

   IF p_index > 9 THEN
      DISPLAY ARRAY pr_transpor TO sr_placa.*
   ELSE
      INPUT ARRAY pr_transpor WITHOUT DEFAULTS FROM sr_placa.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1287_grava_dados()
#-----------------------------#

   DEFINE p_incluiu SMALLINT

   CALL log085_transacao("BEGIN")

   LET p_incluiu = FALSE

   DELETE FROM transportador_placa_885
    WHERE cod_transpor = p_cod_transpor

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "transportador_placa_885")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_transpor[p_ind].num_placa IS NOT NULL THEN

		       INSERT INTO transportador_placa_885
		       VALUES (p_cod_transpor,
		               pr_transpor[p_ind].num_placa,
		               pr_transpor[p_ind].tara_minima)

		       IF STATUS <> 0 THEN
		          CALL log003_err_sql("Incluindo", "transportador_placa_885")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
		       LET p_incluiu = TRUE
       END IF
   END FOR

   CALL log085_transacao("COMMIT")

   IF p_opcao = "I" THEN
      IF NOT p_incluiu THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1287_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_transpor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0368
         IF p_codigo IS NOT NULL THEN
            LET p_cod_transpor = p_codigo
            DISPLAY p_codigo TO cod_transpor
         END IF

   END CASE

END FUNCTION

#--------------------------#
 FUNCTION pol1287_consulta()
#--------------------------#

   DEFINE sql_stmt,
          where_clause CHAR(500)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_transpor_ant = p_cod_transpor
   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause ON
      transportador_placa_885.cod_transpor

      ON KEY (control-z)
         CALL pol1287_popup()

   END CONSTRUCT

   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_cod_transpor = p_cod_transpor_ant
         CALL pol1287_exibe_dados() RETURNING p_status
      END IF
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT DISTINCT cod_transpor ",
                  "  FROM transportador_placa_885 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_transpor "

   PREPARE var_query FROM sql_stmt
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_transpor

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      RETURN FALSE
   ELSE
      IF STATUS = 0 THEN
         IF pol1287_exibe_dados() THEN
            LET p_ies_cons = TRUE
            RETURN TRUE
         END IF
      ELSE
         CALL log003_err_sql('FETCH','cq_padrao')
         RETURN FALSE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1287_exibe_dados()
#------------------------------#

   SELECT nom_cliente
     INTO p_nom_transpor
     FROM clientes
    WHERE cod_cliente = p_cod_transpor

   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','clientes')
      RETURN FALSE
   END IF

   IF NOT pol1287_carrega_placa() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1287_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_transpor_ant = p_cod_transpor

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_transpor

         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_transpor

      END CASE

      IF STATUS = 0 THEN

         LET p_count = 0

         SELECT COUNT(cod_transpor)
           INTO p_count
           FROM transportador_placa_885
          WHERE cod_transpor  = p_cod_transpor

         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "transportador_placa_885")
         END IF

         IF p_count > 0 THEN
            CALL pol1287_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_transpor = p_cod_transpor_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF

   END WHILE

END FUNCTION


#----------------------------------------#
 FUNCTION pol1287_edita_transpor(p_funcao)
#----------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT ARRAY pr_transpor
      WITHOUT DEFAULTS FROM sr_placa.*

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
         
         DISPLAY p_index TO sr_placa[s_index].controle

      AFTER ROW

         IF pr_transpor[p_index].num_placa IS NOT NULL THEN         
            DISPLAY p_index TO sr_placa[s_index].controle
         END IF
         

      AFTER FIELD num_placa

         IF pr_transpor[p_index].num_placa IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN
            ELSE
               ERROR 'Campo com preenchimento obrigatório !!!'
               NEXT FIELD num_placa
            END IF
         END IF
         
         FOR p_ind = 1 TO ARR_COUNT()
            IF p_ind <> p_index THEN
               IF pr_transpor[p_ind].num_placa = pr_transpor[p_index].num_placa THEN
                     ERROR "Placa já informada !!!"
                     NEXT FIELD num_placa
               END IF
            END IF
         END FOR

		  BEFORE FIELD tara_minima

         IF pr_transpor[p_index].num_placa IS NULL THEN
            NEXT FIELD num_placa
         END IF
         
         IF NOT p_ies_tara THEN
            NEXT FIELD controle
         END IF

		  AFTER FIELD tara_minima

		  IF NOT p_ies_tara OR pr_transpor[p_index].tara_minima = 0 THEN
		     LET pr_transpor[p_index].tara_minima = ''
		  END IF

      
   END INPUT

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      IF p_funcao = 'I' THEN
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
      ELSE
        CALL pol1287_carrega_placa() RETURNING p_status
      END IF
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol1287_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_transpor
      FROM transportador_placa_885
     WHERE cod_transpor = p_cod_transpor
       FOR UPDATE

    OPEN cq_prende
   FETCH cq_prende

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","transportador_placa_885")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1287_modificacao()
#-----------------------------#

   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'

   IF pol1287_prende_registro() THEN
      IF pol1287_edita_transpor('M') THEN
         IF pol1287_grava_dados() THEN
            LET p_retorno = TRUE
         END IF
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol1287_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN
      RETURN FALSE
   END IF

   LET p_retorno = FALSE

   IF pol1287_prende_registro() THEN
      DELETE FROM transportador_placa_885
			 WHERE cod_transpor = p_cod_transpor

      IF STATUS = 0 THEN
         INITIALIZE p_cod_transpor TO NULL
         INITIALIZE pr_transpor    TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
      ELSE
         CALL log003_err_sql("Excluindo","transportador_placa_885")
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol1287_listagem()
#--------------------------#

   IF NOT pol1287_escolhe_saida() THEN
   		RETURN
   END IF

   IF NOT pol1287_le_den_empresa() THEN
      RETURN
   END IF

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2"
   LET p_8lpp        = ascii 27, "0"

   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR

   SELECT cod_transpor,
          num_placa, 
          tara_minima
     FROM transportador_placa_885
 ORDER BY cod_transpor, num_placa

   FOREACH cq_impressao
      INTO p_cod_transpor,
           p_num_placa,
           p_tara_minima
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF

   SELECT nom_cliente
     INTO p_nom_transpor
     FROM clientes
    WHERE cod_cliente = p_cod_transpor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'clientes')
         RETURN
      END IF

      DECLARE cq_listar_transpor CURSOR FOR

       SELECT nom_cliente
         FROM clientes
        WHERE cod_cliente = p_cod_transpor

      FOREACH cq_listar_transpor
         INTO p_nom_transpor

         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','transportadoras')
            RETURN FALSE
         END IF

         EXIT FOREACH

      END FOREACH

   OUTPUT TO REPORT pol1287_relat(p_cod_transpor)

      LET p_count = 1

   END FOREACH

   FINISH REPORT pol1287_relat

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
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN

END FUNCTION

#-------------------------------#
 FUNCTION pol1287_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF

   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1287.tmp"
         START REPORT pol1287_relat TO p_caminho
      ELSE
         START REPORT pol1287_relat TO p_nom_arquivo
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1287_le_den_empresa()
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

#--------------------------------#
 REPORT pol1287_relat(p_cod_transpor)
#--------------------------------#

   DEFINE p_cod_transpor LIKE transportador_placa_885.cod_transpor

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63

   FORMAT

      PAGE HEADER

         PRINT COLUMN 002,  p_den_empresa,
               COLUMN 073, "PAG. ", PAGENO USING "####&"

         PRINT COLUMN 002, "pol1287",
               COLUMN 013, "TRANSPORTADORAS CADASTRO DE PLACAS",
               COLUMN 053, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 002, "---------------------------------------------------------------------------------"
         PRINT

      BEFORE GROUP OF p_cod_transpor

         PRINT
         PRINT COLUMN 003, "Transportador: ", p_cod_transpor, " - ", p_nom_transpor
         PRINT
         PRINT COLUMN 002, 'Placa     Tara Minima '
         PRINT COLUMN 002, '--------  -----------------------------------------------------'

      ON EVERY ROW

         PRINT COLUMN 002, p_num_placa,
               COLUMN 010, p_tara_minima USING '########,##&.&&' 
               
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE
           PRINT " "
        END IF

END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#