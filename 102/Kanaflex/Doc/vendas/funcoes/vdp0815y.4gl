###PARSER-Não remover esta linha(Framework Logix)###
#-------------------------------------------------------------------#
# PROGRAMA: vdp0815y                                                #
# OBJETIVO: EPL - CADASTRO DE CLIENTE                               #
# CLIENTE.: 970 - Itaebra  e 547-Ethos                              #
# AUTOR...: LUCIANA N. KANEKO                                       #
# DATA....: 04/08/2010                                              #
#-------------------------------------------------------------------#
DATABASE logix

#----------------------------------------------------------#
 FUNCTION vdp0815y_before_input_cliente()
#----------------------------------------------------------#
  DEFINE l_consistir_ie        SMALLINT   #os 788431

  LET l_consistir_ie            = LOG_getVar("consistir_ie")
  LET l_consistir_ie            = FALSE        #os 788431

  CALL LOG_setVar("consistir_ie",l_consistir_ie)   #os 788431

  CALL LOG_setVar("consistir",FALSE) #812735

END FUNCTION
#-------------------------------#
FUNCTION vdp0815y_version_info()
#-------------------------------#
RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdp0815y.4gl $|$Revision: 1 $|$Date: 01/07/11 11:21 $|$Modtime: 8/12/10 17:32 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
END FUNCTION
