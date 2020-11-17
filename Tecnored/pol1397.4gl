#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc                                #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1397                                                            #
# OBJETIVO: PONTOS DE ENTRADA MAN10021                                         #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 21/07/2020                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
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
          g_tipo_sgbd            CHAR(003)
END GLOBALS

MAIN   

   
   CALL log0180_conecta_usuario()
         
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN    
      CALL pol1397_controle()
   END IF
         
END MAIN

#--------------------------#
FUNCTION pol1397_controle()#
#--------------------------#

END FUNCTION

FUNCTION vdp30100y_before_processar()

   DEFINE l_empresa VARCHAR(02),
          l_roma    INTEGER
          
   CALL log0030_mensagem(p_cod_empresa,'info')
   SELECT max(num_om) into l_roma from ordem_montag_item where cod_empresa = '01'                       
   CALL log0030_mensagem(l_roma,'info')

END FUNCTION

FUNCTION vdp30100y_after_processar()

   DEFINE l_empresa VARCHAR(02),
          l_roma    INTEGER
          
   CALL log0030_mensagem(p_cod_empresa,'info')
   SELECT max(num_om) into l_roma from ordem_montag_item where cod_empresa = '01'                       
   CALL log0030_mensagem(l_roma,'info')

END FUNCTION


#---------------------------------------------------#
FUNCTION man100211y_after_incluir(l_empresa, l_item)#
#---------------------------------------------------#
   
   DEFINE l_empresa VARCHAR(02),
          l_item    VARCHAR(15)
          
   

END FUNCTION

#-----------------------------------------------------#
FUNCTION man100211y_after_modificar()#
#-----------------------------------------------------#
   
   DEFINE l_empresa VARCHAR(02),
          l_item    VARCHAR(15)
   
   call LOG_setVar("empresa",l_empresa)
   CALL log0030_mensagem(l_empresa,'info')
   call LOG_setVar("cod_empresa",l_empresa)
   CALL log0030_mensagem(l_empresa,'info')

   let l_empresa = LOG_getVar("empresa")
   CALL log0030_mensagem(l_empresa,'info')
   let l_empresa = LOG_getVar("cod_empresa")
   CALL log0030_mensagem(l_empresa,'info')
   let l_item = LOG_getVar("cod_item")
   CALL log0030_mensagem(l_item,'info')


END FUNCTION

#---------------------------------------------------#
FUNCTION man100211y_after_excluir(l_empresa, l_item)#
#---------------------------------------------------#
   
   DEFINE l_empresa VARCHAR(02),
          l_item    VARCHAR(15)
          
   CALL log0030_mensagem(l_empresa,'info')
   CALL log0030_mensagem(l_item,'info')

END FUNCTION

   