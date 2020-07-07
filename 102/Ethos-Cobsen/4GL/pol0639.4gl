#-----------------------------------------------------------------------#
# PROGRAMA: pol0639                                                     #
# OBJETIVO: LE DEMANDA DE PEDIOS E INSERE NA TAB PL_IT_ME               #
# AUTOR...: POLO INFORMATICA - IVO                                      #
# DATA....: 21/09/2007                                                  #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_ies_cons           SMALLINT,
          p_rowid              INTEGER,
          p_count              INTEGER,
          p_status             SMALLINT,
          p_sobe               DECIMAL(1,0),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          p_msg                CHAR(500)

   DEFINE p_tela               RECORD
          dat_ini              DATE,
          dat_fim              DATE
   END RECORD 
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0639-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0639.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0639_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0639_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0639") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0639 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar Período"
         HELP 001 
         MESSAGE ""
         IF pol0639_informar() THEN
            LET p_ies_cons = TRUE
            NEXT OPTION "Processar"
         ELSE
            ERROR "Operação Cancelada !!!"
            NEXT OPTION "Fim"
         END IF
      COMMAND "Processar" "Processa o pol0639"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0639_processa()
            MESSAGE ''
            ERROR 'Processamento Efetuado Com Sucesso'
         ELSE
            ERROR 'Infome previamento o periodo'
         END IF
         LET p_ies_cons = FALSE
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0639_sobre()
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
   CLOSE WINDOW w_pol0639

END FUNCTION

#--------------------------#
FUNCTION pol0639_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
 
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_ini    
      IF p_tela.dat_ini IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_ini       
      END IF 

      AFTER FIELD dat_fim   
      IF p_tela.dat_fim IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_fim
      ELSE
         IF p_tela.dat_ini > p_tela.dat_fim THEN
            ERROR "Data Inicial nao pode ser maior que data Final"
            NEXT FIELD dat_ini
         END IF 
      END IF 
      
   END INPUT

   IF NOT INT_FLAG THEN
      RETURN TRUE
   END IF

   LET INT_FLAG = 0

   RETURN FALSE
   
END FUNCTION


#------------------------#
FUNCTION pol0639_processa()
#------------------------#

   MESSAGE 'Aguarde!... Excluindo registros da tab pl_it_me'

DELETE FROM pl_it_me

MESSAGE 'Aguarde!... Inserindo registros na tab pl_it_me'

INSERT INTO pl_it_me
SELECT a.cod_empresa, 
       a.cod_item, 
       MONTH(prz_entrega), 
       YEAR(prz_entrega),
       SUM(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel)
  FROM ped_itens a, pedidos b
 WHERE a.cod_empresa=b.cod_empresa
   AND a.num_pedido=b.num_pedido
   AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel) > 0
   AND prz_entrega between p_tela.dat_ini and p_tela.dat_fim
   AND ies_sit_pedido <> '9'
 GROUP by 1, 2, 3, 4
   
END FUNCTION

#-----------------------#
 FUNCTION pol0639_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION