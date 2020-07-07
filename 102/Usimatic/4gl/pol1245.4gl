DATABASE logix

GLOBALS
   DEFINE p_cod_empresa  LIKE empresa.cod_empresa,
          p_den_empresa  LIKE empresa.den_empresa,  
          p_status       SMALLINT,
          p_versao       CHAR(018),
          p_user         CHAR(008),
          p_caminho      CHAR(080),
          p_comando      CHAR(200)

END GLOBALS

MAIN

   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT 
   LET p_versao = "pol1245-10.02.00"
   
   OPTIONS
     NEXT KEY control-f,
     PREVIOUS KEY control-b,
     DELETE KEY control-e

   CALL log001_acessa_usuario("ESPEC999","")     
       RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1245_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1245_controle()
#--------------------------#
   
   DEFINE p_param   CHAR(30)
   
   LET p_param = p_cod_empresa, '&', p_user 
   
   SELECT nom_caminho
     INTO p_caminho
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = 'DPH'
  
   IF p_caminho IS NULL THEN
      LET p_caminho = 'Caminho do sistema DPH não en-\n',
                      'contrado. Consulte a log1100.'
      CALL log0030_mensagem(p_caminho,'Info')
      RETURN
   END IF
  
   LET p_comando = p_caminho CLIPPED, 'pgi1120.exe ', p_param

   CALL conout(p_comando)

   CALL runOnClient(p_comando)

END FUNCTION

