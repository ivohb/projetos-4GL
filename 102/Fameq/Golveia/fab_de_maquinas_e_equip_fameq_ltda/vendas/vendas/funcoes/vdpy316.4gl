###PARSER-Não remover esta linha(Framework Logix)###
#--------------------------------------------------------------------#
# SISTEMA.: VDP - VENDAS E DISTRIBUICAO DE PRODUTOS                  #
# PROGRAMA: VDPY316 - FUNCAO EPL DO CLIENTE 1080                     #
# AUTOR...: DIEGO FERNANDO VENTURI                                   #
# DATA....: 27/10/2009                                               #
#--------------------------------------------------------------------#
DATABASE logix

#-------------------------------------------#
 FUNCTION vdpy316_consiste_cliente()
#-------------------------------------------#
{Função que retorna a utilização dessa EPL - Cliente :1080 FAMEQ }

 RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION vdpy316_version_info()
#-------------------------------#
  RETURN "$Archive: /especificos/logix10R2/fameq_fab_de_maquinas_e_equip_ltda/vendas/vendas/funcoes/vdpy316.4gl $|$Revision: 2 $|$Date: 24/11/09 17:48 $|$Modtime: 24/11/09 13:46 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION


