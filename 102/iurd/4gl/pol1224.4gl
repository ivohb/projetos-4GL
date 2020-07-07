
DATABASE logix

#------------------------------#
 FUNCTION pol1224_job(l_rotina)
#------------------------------#
  DEFINE l_rotina  CHAR(10)
  
  IF LOG_initApp("ESPEC99") <> 0 THEN
     RETURN 1
  END IF
  
  RETURN pol1224_processar()

 END FUNCTION
 
#----------------------------#
 FUNCTION pol1224_processar()
#----------------------------#
  
  DEFINE l_sql_stmt     CHAR(500)
  DEFINE l_dat_execucao LIKE log_dados_sessao_logix.dat_execucao
  DEFINE l_sid          LIKE log_dados_sessao_logix.sid
  
  LET l_sql_stmt = " SELECT a.dat_execucao, a.sid ",
                     " FROM logix:log_dados_sessao_logix a", 
                    " WHERE a.sid NOT IN (SELECT b.sid ",
                    " FROM sysmaster:syssessions b) "
  
  WHENEVER ERROR CONTINUE
   PREPARE var_query FROM l_sql_stmt
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL LOG_consoleError("PREPARE - var_query - pol1224")
     RETURN 1
  END IF
  
  WHENEVER ERROR CONTINUE
   DECLARE cq_sid CURSOR FOR var_query
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL LOG_consoleError("DECLARE - cq_sid - pol1224")
     RETURN 1
  END IF
  
  WHENEVER ERROR CONTINUE
   FOREACH cq_sid INTO l_dat_execucao, l_sid
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL LOG_consoleError("FOREACH - cq_sid - pol1224")
     RETURN 1
  END IF
  
     WHENEVER ERROR CONTINUE
       DELETE 
         FROM log_dados_sessao_logix
        WHERE dat_execucao = l_dat_execucao
          AND sid = l_sid
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL LOG_consoleError("DELETE - log_dados_sessao_logix - pol1224")
        RETURN 1
     END IF
  
  END FOREACH
  
  FREE cq_sid
  
  RETURN 0

 END FUNCTION
 
