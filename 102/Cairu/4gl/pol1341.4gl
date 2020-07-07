# PROGRAMA: pol1341                                                            #
# OBJETIVO: ENVIO DE EMAIL PARA CLIENTES C/ TITULOS EM ATRASO                  #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 16/04/2018                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#
# CRE3500

{
Peço que seja melhorado :
1-cobrança de  “juros e multas devidos” , segue print da tela (EXCLUIR)
(OK) 2-Ano cobrança a partir 2017 (excluir anos anteriores)
(ok) 3- seria possível dar um espaço entre as colunas e alinhamento (melhor visualização)
(OK) 4- Na frente no nome , colocar CNPJ  (do cliente)
(ok) 5- No final da carta colocar meu:  e-mail  sandraj@cairucp.com.br ,
(ok) e telefones   0800552210 ou 19-3666.6121, 19-3666.6111, 19-3666.6112.
(ok) 6- totalizar a coluna valor do titulo
(ok) 7- Se titulo possuir data prorrogada, considerar ela.
}
  
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_versao               CHAR(18),
          comando                CHAR(080),
          m_comando              CHAR(080),
          p_caminho              CHAR(150),
          m_caminho              CHAR(150),
          g_tipo_sgbd            CHAR(003),
          g_msg                  CHAR(150)         
END GLOBALS
