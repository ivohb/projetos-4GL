#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1208                                                 #
# OBJETIVO: EFETIVAÇÃO DE FORNECEDORES                              #
# AUTOR...: ACEEX - BL                                              #
# DATA....: 04/07/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080)


END GLOBALS

   DEFINE p_id                INTEGER, 
          p_cod_fornecedor    CHAR(15),
          p_ies_fornec_ativo  CHAR(01)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT
   LET p_versao = "pol1209-10.02.02"

   CALL pol1209_controle()
   
END MAIN

#--------------------------#
FUNCTION pol1209_controle()#
#--------------------------#
    
      CALL log085_transacao("BEGIN")
      
      IF NOT pol1209_aut_tabs() THEN
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
      
END FUNCTION

#--------------------------#
FUNCTION pol1209_aut_tabs()#
#--------------------------# 
  
   SLEEP 1
  
   UPDATE fornecedor
      SET ies_fornec_ativo = 'I'
    WHERE cod_fornecedor not in (SELECT cod_fornecedor
        FROM fornec_1099)
      and ies_fornec_ativo = 'A'
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF
  
   UPDATE fornecedor
      SET ies_fornec_ativo = 'A'
    WHERE cod_fornecedor  in (SELECT cod_fornecedor
        FROM fornec_1099)
      and ies_fornec_ativo = 'I'
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF


  
   RETURN TRUE

END FUNCTION
   
#-------------------FIM DO PROGRAMA BL--------------------#

