###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDP03134                                              #
# OBJETIVO: EPL DE PEDIDOS ON LINE                                #
# AUTOR...: LUCIANA NAOMI KANEKO                                  #
# DATA....: 12/09/2011                                            #
#-----------------------------------------------------------------#
DATABASE logix
GLOBALS
  DEFINE g_ies_grafico       SMALLINT

END GLOBALS

   DEFINE m_empresa         LIKE empresa.cod_empresa

  DEFINE m_user                    LIKE usuarios.cod_usuario,
         m_comando                 CHAR(080),
         m_nom_tela                CHAR(80),
         m_versao_funcao           CHAR(18),
         m_status                  SMALLINT

#-----------------------------------------------------------------#
FUNCTION vdp03134y_before_open_window_mestre()
#-----------------------------------------------------------------#
  LET m_empresa            = LOG_getVar("empresa")
  LET m_nom_tela           = LOG_getVar("nom_tela")


  CALL log130_procura_caminho("vdp4134ay") RETURNING m_nom_tela  #os TDQPX4

      CALL LOG_setVar("nom_tela",m_nom_tela)
      #EPL Nome da tela
      #EPL TIPO: char(80)

RETURN TRUE
END FUNCTION

#-------------------------------#
 FUNCTION vdp03134y_version_info()
#-------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdp03134y.4gl $|$Revision: 3 $|$Date: 05/10/11 15:05 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION
