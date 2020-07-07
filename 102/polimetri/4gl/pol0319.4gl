#------------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                                  #
# PROGRAMA: POL0319                                                            #
# MODULOS.: POL0319                                                            #
# OBJETIVO: ATUALIZACAO DA NUMERACAO DAS DUPLICATAS DA G.M. (POLIMETRI)        #
# AUTOR...: POLO INFORMATICA                                                   #
# DATA....: 14/02/2005                                                         #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa       CHAR(02),
          p_user              LIKE usuario.nom_usuario,
          p_num_docum         LIKE docum.num_docum,
          p_empresa           LIKE empresa.cod_empresa,
          p_den_empresa       LIKE empresa.den_empresa,
          comando             CHAR(80),
          p_count             SMALLINT,
      #   p_versao            CHAR(17),               
          p_versao            CHAR(18),               
          p_nom_help          CHAR(200),
          p_nom_tela          CHAR(200),
          p_status            SMALLINT,
          p_houve_erro        SMALLINT,
          p_msg               CHAR(500),
          p_r                 CHAR(001),
          p_data              DATE

   DEFINE p_docum             RECORD LIKE docum.*,
          p_gm_polimetri      RECORD LIKE gm_polimetri.*
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT 
   LET p_versao = "POL0319-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0123.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0319_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0319_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0319") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0319 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informa Data de Processamento"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0319","IN") THEN
            IF pol0319_processa() THEN
               NEXT OPTION "Fim"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0319_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 002
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0319

END FUNCTION

#--------------------------#
 FUNCTION pol0319_processa()
#--------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0319
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_docum.*,
              p_num_docum,
              p_gm_polimetri.* TO NULL

   LET p_data = TODAY - 1
   LET INT_FLAG = FALSE

   INPUT p_empresa,
         p_data 
      WITHOUT DEFAULTS
   FROM cod_empresa1,
        data

      BEFORE FIELD cod_empresa1
      LET p_empresa = p_cod_empresa

      AFTER FIELD cod_empresa1
      IF p_empresa IS NOT NULL THEN
         SELECT den_empresa
            INTO p_den_empresa
         FROM empresa
         WHERE cod_empresa = p_empresa
         DISPLAY p_den_empresa TO den_empresa
      ELSE
         ERROR "O Campo Empresa nao pode ser Nulo"
         NEXT FIELD cod_empresa1
      END IF

      AFTER FIELD data
      IF p_data IS NULL THEN
         ERROR "O Campo Data nao pode ser Nulo"
         NEXT FIELD data
   #  ELSE
   #     IF p_data <= "28/02/2005" THEN
   #        ERROR "O Campo Data nao pode ser Menor que 01/03/2005"
   #        NEXT FIELD data
   #     END IF
      END IF

      ON KEY(control-z)
         IF INFIELD(cod_empresa1) THEN
            CALL log009_popup(6,25,"EMPRESAS","empresa",
                             "cod_empresa","den_empresa",
                             "","N","") 
               RETURNING p_empresa
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0319
            DISPLAY p_empresa TO cod_empresa1
         END IF

   END INPUT 
   
   IF INT_FLAG THEN
      CLEAR FORM
      ERROR "Funcao Cancelada"
      RETURN FALSE 
   END IF

   IF log004_confirm(14,30) THEN

      MESSAGE "Atualizando Numeracao Duplicatas G.M. !!!" ATTRIBUTE (REVERSE)
      LET p_houve_erro = FALSE

      DECLARE cq_docum CURSOR FOR 
      SELECT * FROM docum       
      WHERE cod_empresa = p_empresa 
        AND ies_tip_docum = "DP"
        AND ies_tip_docum_orig = "NF"
        AND dat_emis = p_data
        AND (cod_portador = 0 OR cod_portador IS NULL)

      CALL log085_transacao("BEGIN")
   #  BEGIN WORK
      LET p_count = 1
      FOREACH cq_docum INTO p_docum.*

         SELECT * FROM gm_polimetri
         WHERE cod_empresa = p_empresa
           AND cod_cliente = p_docum.cod_cliente
         IF SQLCA.SQLCODE <> 0 THEN
            CONTINUE FOREACH
         END IF
         DISPLAY "DUPLICATA Nro...: " AT 9,6
         DISPLAY p_docum.num_docum_origem AT 9,24
         IF LENGTH(p_docum.num_docum_origem) < 10 THEN
            LET p_num_docum = "0", p_docum.num_docum_origem CLIPPED
         ELSE
            CONTINUE FOREACH
         END IF
         DISPLAY p_num_docum AT 9,36

         UPDATE docum        
            SET num_docum = p_num_docum
         WHERE cod_empresa = p_empresa
           AND num_docum = p_docum.num_docum
           AND ies_tip_docum = p_docum.ies_tip_docum
         IF SQLCA.SQLCODE <> 0 THEN
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("ALTERACAO","DOCUM")
            EXIT FOREACH
         END IF

         UPDATE docum_obs
            SET num_docum = p_num_docum
         WHERE cod_empresa = p_empresa
           AND num_docum = p_docum.num_docum
           AND ies_tip_docum = p_docum.ies_tip_docum
         IF SQLCA.SQLCODE <> 0 THEN
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("ALTERACAO","DOCUM_OBS")
            EXIT FOREACH
         END IF

         UPDATE adocum        
            SET num_docum = p_num_docum
         WHERE cod_empresa = p_empresa
           AND num_docum = p_docum.num_docum
           AND ies_tip_docum = p_docum.ies_tip_docum
         IF SQLCA.SQLCODE <> 0 THEN
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("ALTERACAO","ADOCUM")
            EXIT FOREACH
         END IF       

         UPDATE cre_docum_compl
            SET docum = p_num_docum
         WHERE empresa = p_empresa
           AND docum = p_docum.num_docum
           AND tip_docum = p_docum.ies_tip_docum
         IF SQLCA.SQLCODE <> 0 THEN
            LET p_houve_erro = TRUE 
            CALL log003_err_sql("ALTERACAO","CRE_DOCUM_COMPL")
            EXIT FOREACH
         END IF       
         LET p_count = p_count + 1

      END FOREACH

      IF p_count = 1 THEN
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         MESSAGE "Nao Existem Duplicatas a serem Processadas !!!"
            ATTRIBUTE (REVERSE)
         RETURN FALSE
      END IF
      IF p_houve_erro = FALSE THEN
         CALL log085_transacao("COMMIT")
      #  COMMIT WORK
         MESSAGE "Atualizacao Efetuada com Sucesso !!!"
            ATTRIBUTE (REVERSE)
      ELSE
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF
   END IF

   CLEAR FORM
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol0319_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#
