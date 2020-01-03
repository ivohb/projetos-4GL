#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE DE DESPESAS DE VIAGEM                          #
# PROGRAMA: CDV0805                                                 #
# OBJETIVO: FUNCAO PARA VERIFICAR SE UMA VARIAVEL EH CHAR           #
# AUTOR...: ANA PAULA CASAS DE ALMEIDA                              #
# DATA....: 27/10/2005.                                             #
#-------------------------------------------------------------------#
DATABASE logix

#--------------------------------------------------#
 FUNCTION cdv0805_verifica_char_empresa(l_empresa)
#--------------------------------------------------#
 DEFINE l_empresa  LIKE empresa.cod_empresa

 CASE l_empresa[1,1]
    WHEN '0'
    WHEN '1'
    WHEN '2'
    WHEN '3'
    WHEN '4'
    WHEN '5'
    WHEN '6'
    WHEN '7'
    WHEN '8'
    WHEN '9'
    OTHERWISE
       RETURN TRUE
 END CASE

 CASE l_empresa[2,2]
    WHEN '0'
    WHEN '1'
    WHEN '2'
    WHEN '3'
    WHEN '4'
    WHEN '5'
    WHEN '6'
    WHEN '7'
    WHEN '8'
    WHEN '9'
    OTHERWISE
       RETURN TRUE
 END CASE

 RETURN FALSE

END FUNCTION

#-------------------------------#
 FUNCTION cdv0805_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/funcoes/cdv0805.4gl $|$Revision: 3 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION
