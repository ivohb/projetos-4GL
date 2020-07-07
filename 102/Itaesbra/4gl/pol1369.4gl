#-------------------------------------------------------------------#
# SISTEMA.: LOGIX      ITAESBRA                                     #
# PROGRAMA: pol1369                                                 #
# OBJETIVO: INSPEÇÃO DE ITEM PRODUZIDO                              #
# AUTOR...: IVO                                                     #
# DATA....: 07/05/2019                                              #
#-------------------------------------------------------------------#
# Alterações                                                        #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003),
           g_msg           CHAR(150),
           p_nom_arquivo   CHAR(100),
           p_caminho       CHAR(080),
           p_comando       CHAR(200)
END GLOBALS

DEFINE p_nom_tela          CHAR(200)

DEFINE p_tela              RECORD 
   num_ordem               DECIMAL(9,0),
   num_lote                CHAR(15),
   qtd_lote                DECIMAL(10,3),
   qtd_liberada            DECIMAL(10,3),
   qtd_rejeitada           DECIMAL(10,3),
   cod_motivo              DECIMAL(10,3)
END RECORD        

MAIN

   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 60
   DEFER INTERRUPT
   LET p_versao = "pol1369-12.00.00  "
   CALL func002_versao_prg(p_versao)
   
   #CALL log001_acessa_usuario("ESPEC999","")
   #   RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1369_tela()
   END IF

END MAIN

#----------------------#
FUNCTION pol1369_tela()#
#----------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1369") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1369 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   #DISPLAY p_cod_empresa TO cod_empresa

   MENU "Opção"
      COMMAND "Processar" ""
         CALL pol1369_processar() RETURNING p_status
         IF p_status THEN
            ERROR 'Sucesso na operação'
         ELSE
            ERROR 'Operação cancelada'
         END IF 
      COMMAND "Fim"  ""
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1369
   
END FUNCTION

#---------------------------#
FUNCTION pol1369_processar()#
#---------------------------#
   
   INITIALIZE p_tela.* TO NULL
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD num_ordem


   END INPUT 

   RETURN TRUE

END FUNCTION
   