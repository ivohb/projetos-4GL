#-------------------------------------------------------------------#
# PROGRAMA: pol1282                                                 #
# OBJETIVO: ERROS DA EXPORTA��O DE DADOS PARA FIAT                  #
# AUTOR...: IVO                                                     #
# DATA....: 30/04/2015                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_msg                CHAR(150)

END GLOBALS

DEFINE pr_erro                 ARRAY[500] OF RECORD
   datproces                   CHAR(10),
   erro                        CHAR(120)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT

   LET p_versao = "pol1282-10.02.00  "
   CALL func002_versao_prg(p_versao)

   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol1282_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol1282_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1282") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1282 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   DISPLAY p_cod_empresa TO cod_empresa
         
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Dados da Tabela"
         CALL pol1282_consulta()
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1282

END FUNCTION

#--------------------------#
FUNCTION pol1282_consulta()#
#--------------------------#

   SELECT COUNT(erro)
     INTO p_count
     FROM nota_diverg_5054 
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'nota_diverg_5054')
      RETURN FALSE 
   END IF 
      
   IF p_count = 0 THEN 
      LET p_msg = 'N�o h� erros de exporta��o\n',
                  'de notas/saldos para a fiat'
      CALL log0030_mensagem(p_msg,'info')
      RETURN      
   END IF 
   
   INITIALIZE pr_erro TO NULL
   LET p_ind = 1
   
   DECLARE cq_erro CURSOR FOR
    SELECT datproces,
           erro
     FROM nota_diverg_5054
   
   FOREACH cq_erro INTO pr_erro[p_ind].*

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('FOREACH', 'cq_erro')
         RETURN
      END IF 
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 500 THEN
         LET p_msg = 'Limite de linhas\n da grade ultrapassou'
         CALL log0030_mensagem(p_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_erro TO sr_erro.*   
   
END FUNCTION     
   