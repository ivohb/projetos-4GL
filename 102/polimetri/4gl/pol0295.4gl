#-------------------------------------------------------------------#
# SISTEMA.: CONTAS A RECEBER                                        #
# PROGRAMA: POL0295                                                 #
# MODULOS.: POL0295 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: DETERMINACAO COLETIVA DE PORTADORES                     #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 21/12/2004                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,  
          p_user          LIKE usuario.nom_usuario,
          p_ies_tip_docum LIKE docum.ies_tip_docum,
          p_status        SMALLINT,
          p_houve_erro    SMALLINT,
          comando         CHAR(80),
          p_ies_impressao CHAR(01),
          p_caminho       CHAR(80),
          g_ies_ambiente  CHAR(001),
          p_nom_arquivo   CHAR(100),
          p_versao        CHAR(18),
          p_arquivo       CHAR(025),
          p_nom_tela      CHAR(200),
          p_nom_help      CHAR(200),
          p_count         SMALLINT,
          p_ies_cons      SMALLINT,
          pa_curr         SMALLINT,
          sc_curr         SMALLINT,
          p_i             SMALLINT,
          p_a             SMALLINT,
          p_msg           CHAR(100)

   DEFINE p_docum         RECORD LIKE docum.*,
          p_docum_pgto    RECORD LIKE docum_pgto.*,
          p_docum_banco   RECORD LIKE docum_banco.*

   DEFINE p_tela RECORD 
      dat_ini             LIKE docum.dat_emis,
      dat_fim             LIKE docum.dat_emis,
      val_sel             LIKE docum.val_liquido,
      cod_portador        LIKE docum.cod_portador,
      nom_portador        LIKE portador.nom_portador,
      ies_tip_portador    LIKE portador.ies_tip_portador,
      ies_dupl            CHAR(003),
      val_saldo           LIKE docum.val_saldo,
      campo               LIKE docum.ies_tip_portador
   END RECORD 

   DEFINE p_relat RECORD 
      dat_ini             LIKE docum.dat_emis
   END RECORD 

   DEFINE t_tit_desc ARRAY[500] OF RECORD 
      ies_baixar          CHAR(01),
      num_docum           LIKE docum.num_docum,
      nom_cliente         LIKE clientes.nom_cliente,
      dat_vencto_s_desc   LIKE docum.dat_vencto_s_desc,
      val_saldo           LIKE docum.val_saldo
   END RECORD 
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0295-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0295.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0295_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0295_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0295") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0295 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informa Parametros para Processamento"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"CRECEBER","pol0295","IN") THEN
            IF pol0295_entrada_dados("INCLUSAO") THEN
               NEXT OPTION "Processar"
            ELSE
               ERROR "Funcao Cancelada"
               NEXT OPTION "Fim"
            END IF 
         END IF 
      COMMAND "Processar" "Processa Determinacao Automatica de Titulos"
         HELP 002
         MESSAGE ""
         IF log005_seguranca(p_user,"CRECEBER","pol0295","CO") THEN
            IF p_ies_cons THEN 
               IF pol0295_processa() THEN
                  NEXT OPTION "Listar"
               END IF
            ELSE
               ERROR "Informar Previamente Parametros de Entrada"
               NEXT OPTION "Informar"
            END IF
         END IF
      COMMAND "Listar" "Lista as Duplicatas Marcadas"
         HELP 003 
         IF log005_seguranca(p_user,"CRECEBER","pol0295","CO") THEN
            IF p_ies_cons THEN
               IF pol0295_imprime() THEN
                  NEXT OPTION "Fim"
               END IF 
            ELSE
               ERROR "Informe os Parametros para Listar"
               NEXT OPTION "Informar"
            END IF
         END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL esp0295_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0295

END FUNCTION

#-----------------------#
FUNCTION esp0295_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#---------------------------------------#
 FUNCTION pol0295_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(011)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0295

   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_tela.*,
                 p_docum.*,
                 p_docum_pgto.*,
                 p_docum_banco.*,
                 t_tit_desc TO NULL
      LET p_houve_erro = FALSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   LET INT_FLAG = FALSE
   INPUT BY NAME p_tela.dat_ini,
                 p_tela.dat_fim,
                 p_tela.ies_dupl,
                 p_tela.cod_portador
      WITHOUT DEFAULTS  

      BEFORE FIELD dat_ini        
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD val_liquido
      END IF

      AFTER FIELD dat_ini        
      IF p_tela.dat_ini IS NULL THEN
         ERROR "O Campo Data Inicial nao pode ser Nula"
         NEXT FIELD dat_ini
      END IF

      AFTER FIELD dat_fim
      IF p_tela.dat_fim IS NULL THEN
         ERROR "O Campo Data final nao pode ser Nula"
         NEXT FIELD dat_fim
      ELSE
         IF p_tela.dat_ini > p_tela.dat_fim THEN
            ERROR "Data Inicial nao pode ser Maior que Final"
            NEXT FIELD dat_ini
         END IF
      END IF

      AFTER FIELD ies_dupl       
      IF p_tela.ies_dupl IS NULL THEN
         ERROR "O Campo Desconto Duplicata nao pode ser Nulo"
         NEXT FIELD ies_dupl
      END IF

      AFTER FIELD cod_portador   
      IF p_tela.cod_portador IS NULL THEN
         ERROR "O Campo Cod Portador nao pode ser Nulo"
         NEXT FIELD cod_portador  
      ELSE
         SELECT ies_tip_portador,
                nom_portador
            INTO p_tela.ies_tip_portador,
                 p_tela.nom_portador
         FROM portador
         WHERE cod_portador = p_tela.cod_portador    
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Portador nao Cadastrado"
            NEXT FIELD cod_portador
         ELSE
            DISPLAY BY NAME p_tela.nom_portador,
                            p_tela.ies_tip_portador
         END IF
         SELECT *
         FROM port_des_polimetri
         WHERE cod_empresa = p_cod_empresa
           AND cod_portador = p_tela.cod_portador    
         IF SQLCA.SQLCODE = 0 AND
            p_tela.ies_dupl = "NAO" THEN
            ERROR "Portador é de Desconto"
            NEXT FIELD cod_portador
         ELSE
            IF SQLCA.SQLCODE <> 0 AND
               p_tela.ies_dupl = "SIM" THEN
               ERROR "Portador nao é de Desconto"
               NEXT FIELD cod_portador
            END IF
         END IF
      END IF

      ON KEY (control-z)
         IF INFIELD(cod_portador) THEN
            CALL log009_popup(6,25,"PORTADOR","portador","cod_portador",
                             "nom_portador","","N","")
               RETURNING p_tela.cod_portador 
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0295
            IF p_tela.cod_portador IS NOT NULL THEN
               DISPLAY BY NAME p_tela.cod_portador
            END IF
         END IF   

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0295
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET p_ies_cons = TRUE 
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol0295_processa() 
#--------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0295

   DECLARE cq_docum CURSOR WITH HOLD FOR
   SELECT num_docum,        
          dat_vencto_s_desc,
          cod_cliente,     
          val_saldo
   FROM docum         
   WHERE cod_empresa = p_cod_empresa
     AND ies_situa_docum <> "C"
     AND dat_vencto_s_desc BETWEEN p_tela.dat_ini AND p_tela.dat_fim
     AND (cod_portador = 0  OR cod_portador IS NULL)

   LET p_i = 1
   LET p_tela.val_saldo = 0
   FOREACH cq_docum INTO p_docum.num_docum,
                         p_docum.dat_vencto_s_desc,
                         p_docum.cod_cliente,  
                         p_docum.val_saldo
      IF p_i > 500 THEN
         EXIT FOREACH 
      END IF

      SELECT nom_cliente
         INTO
             t_tit_desc[p_i].nom_cliente
      FROM clientes  
      WHERE cod_cliente = p_docum.cod_cliente
      LET t_tit_desc[p_i].num_docum = p_docum.num_docum
      LET t_tit_desc[p_i].dat_vencto_s_desc = p_docum.dat_vencto_s_desc
      LET t_tit_desc[p_i].val_saldo = p_docum.val_saldo
      LET p_tela.val_saldo = p_tela.val_saldo + t_tit_desc[p_i].val_saldo
      LET p_i = p_i + 1

   END FOREACH 

   IF p_i = 1 THEN
      ERROR "Nao Existem Titulos p/ este Periodo"
      RETURN FALSE
   END IF

   DISPLAY BY NAME p_tela.val_saldo
   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   LET p_tela.val_sel = 0
   LET INT_FLAG = FALSE
   INPUT ARRAY t_tit_desc WITHOUT DEFAULTS FROM s_tit_desc.*

      BEFORE FIELD ies_baixar
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()
         LET p_tela.campo = t_tit_desc[pa_curr].ies_baixar 

      AFTER FIELD ies_baixar     
      IF p_tela.campo IS NULL AND
         t_tit_desc[pa_curr].ies_baixar = "X" THEN 
         LET p_tela.val_sel = p_tela.val_sel + t_tit_desc[pa_curr].val_saldo
         DISPLAY BY NAME p_tela.val_sel 
      END IF
      IF p_tela.campo = "X" AND
         t_tit_desc[pa_curr].ies_baixar IS NULL THEN 
         LET p_tela.val_sel = p_tela.val_sel - t_tit_desc[pa_curr].val_saldo
         DISPLAY BY NAME p_tela.val_sel 
      END IF
      IF t_tit_desc[pa_curr+1].num_docum IS NULL AND   
         (FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
         FGL_LASTKEY() = FGL_KEYVAL("RETURN")) THEN
         ERROR "Nao Existem mais Registros Nesta Direcao"
         NEXT FIELD ies_baixar 
      END IF  

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0295

   IF NOT INT_FLAG THEN
      IF p_ies_cons THEN 
         IF log004_confirm(21,42) THEN
            FOR p_i = 1 TO 500
               IF t_tit_desc[p_i].num_docum IS NOT NULL AND
                  t_tit_desc[p_i].ies_baixar = "X" THEN
                  UPDATE docum
                     SET cod_portador = p_tela.cod_portador,
                         ies_tip_portador = p_tela.ies_tip_portador,
                         ies_tip_cobr = "S"
                  WHERE cod_empresa = p_cod_empresa
                    AND num_docum = t_tit_desc[p_i].num_docum
                  IF SQLCA.SQLCODE <> 0 THEN 
           	     LET p_houve_erro = TRUE
                     CALL log003_err_sql("ALTERACAO","DOCUM")
                     EXIT FOR
                  END IF
                  IF p_tela.ies_dupl = "SIM" THEN
                     SELECT ies_tip_docum
                        INTO p_ies_tip_docum
                     FROM docum
                     WHERE cod_empresa = p_cod_empresa
                       AND num_docum = t_tit_desc[p_i].num_docum
                     IF SQLCA.SQLCODE <> 0 THEN
                        LET p_ies_tip_docum = " "
                     END IF
                     LET t_tit_desc[p_i].dat_vencto_s_desc = TODAY
                     INSERT INTO doc_desc_polimetri
                        VALUES (p_cod_empresa,
                                t_tit_desc[p_i].num_docum,
                                p_ies_tip_docum,
                                t_tit_desc[p_i].dat_vencto_s_desc)
                     IF SQLCA.SQLCODE <> 0 THEN 
           	        LET p_houve_erro = TRUE
                        CALL log003_err_sql("INCLUSAO","DOC_DESC_POLIMETRI")
                        EXIT FOR
                     END IF
                  END IF
               END IF
            END FOR
         ELSE
            CLEAR FORM
            LET p_ies_cons = FALSE
            RETURN FALSE
         END IF
      ELSE
         LET p_ies_cons = FALSE
         RETURN FALSE
      END IF
      IF p_houve_erro = FALSE THEN
         MESSAGE "Determinacao de Titulos Efetuada com Sucesso" 
            ATTRIBUTE(REVERSE)
         LET p_ies_cons = TRUE 
         RETURN TRUE
      ELSE
         LET p_ies_cons = FALSE
         RETURN FALSE
      END IF   
   ELSE
      CLEAR FORM
      ERROR "Determinacao de Titulos Cancelada"
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------#
 FUNCTION pol0295_imprime()
#-------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0295

   SELECT den_empresa
      INTO p_den_empresa
   FROM empresa
   WHERE cod_empresa = p_cod_empresa

   IF log028_saida_relat(21,39) IS NOT NULL THEN 
      MESSAGE "Processando a Extracao do Relatorio..." 
         ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0295_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0295.tmp' 
            START REPORT pol0295_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT pol0295_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN TRUE
   END IF

   OUTPUT TO REPORT pol0295_relat()
#  INITIALIZE p_relat.* TO NULL
   FINISH REPORT pol0295_relat

   IF p_count > 0 THEN
      IF p_ies_impressao = "S" THEN
         MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
            ATTRIBUTE(REVERSE)
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando 
         END IF
      ELSE 
         MESSAGE "Relatorio Gravado no Arquivo ", p_nom_arquivo, " " 
            ATTRIBUTE(REVERSE)
      END IF
   ELSE 
      MESSAGE "Nao Existem Dados para serem Listados"
         ATTRIBUTE(REVERSE)
   END IF

   RETURN TRUE

END FUNCTION   

#---------------------#
 REPORT pol0295_relat()
#---------------------# 

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   FORMAT

      PAGE HEADER

         PRINT COLUMN 001, p_den_empresa[1,21],
               COLUMN 024, "DETERMINACAO COLETIVA DE PORTADORES",
               COLUMN 072, "FL. ", PAGENO USING "####&"
         PRINT COLUMN 001, "POL0295",
               COLUMN 042, "EXTRAIDO EM ", TODAY USING "dd/mm/yyyy",
               COLUMN 064, " AS ", TIME,
               COLUMN 077, "HRS."
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
         PRINT COLUMN 001, "Portador : ", p_tela.cod_portador, " - ",
               p_tela.nom_portador,
               COLUMN 063, "Tipo : ", p_tela.ies_tip_portador
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
         PRINT COLUMN 001, "Duplicata", 
               COLUMN 020, "Cliente",
               COLUMN 050, "Data Vencto",
               COLUMN 076, "Valor"
         SKIP 1 LINE  

      ON EVERY ROW

         LET p_tela.val_saldo = 0
         FOR p_i = 1 TO 500
            IF t_tit_desc[p_i].num_docum IS NOT NULL AND
               t_tit_desc[p_i].ies_baixar = "X" THEN
               PRINT COLUMN 001, t_tit_desc[p_i].num_docum,
                     COLUMN 020, t_tit_desc[p_i].nom_cliente[1,25],
                     COLUMN 050, t_tit_desc[p_i].dat_vencto_s_desc,
                     COLUMN 069, t_tit_desc[p_i].val_saldo USING "#,###,##&.&&"
               LET p_tela.val_saldo = p_tela.val_saldo+t_tit_desc[p_i].val_saldo
               LET p_count = p_count + 1
            END IF
         END FOR

      ON LAST ROW

         SKIP 1 LINE  
         PRINT COLUMN 050, "Total Geral : ",
               COLUMN 067, p_tela.val_saldo USING "###,###,##&.&&"

END REPORT      
#------------------------------ FIM DE PROGRAMA -------------------------------#
