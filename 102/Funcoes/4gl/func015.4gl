#-----------------------------------------------------------#
#-------Objetivo: gerar OM e solicit faturamento------------#
#--------------------------par�metros-----------------------#
# n�mro do pedido e ordem de montagem                       #
#--------------------------retorno texto--------------------#
#True = Opera��o bem sucedida / False = Erro na opera��o    #
#-----------------------------------------------------------#
# no caso de Erro, uma mensagem ficar� armazenada na vari�- #
# global g_msg e poder� ser exibida pelo programa chamador  #
#-----------------------------------------------------------#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa          CHAR(02),
          g_id_man_apont         INTEGER,
          g_tem_critica          SMALLINT,          
          g_msg                  CHAR(150),
          g_tipo_sgbd            CHAR(03)

   DEFINE p_user                 LIKE usuarios.cod_usuario

END GLOBALS

#-------------------------------------#
FUNCTION func016_gera_om(l_num_pedido)#
#-------------------------------------#
   
   DEFINE l_num_pedido        DECIMAL(6,0)
   
   
