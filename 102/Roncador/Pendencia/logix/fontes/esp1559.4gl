#---------------------------------------------------------------------------#
# SISTEMA.: ESPECIFICO                                                      #
# PROGRAMA: ESP1559                                                         #
# OBJETIVO: CADASTRO DE MOTORISTA GRUPO RONCADOR                            #
# AUTOR...: LUCAS HENRIQUE                                                  #
# DATA....: 16/01/2012                                                      #
#---------------------------------------------------------------------------#

DATABASE logix
  
GLOBALS

   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          p_nom_arquivo            CHAR(100),
          p_ies_impressao          CHAR(01),
          p_caminho                CHAR(100),
          comando                  CHAR(80),
          g_ies_ambiente           CHAR(001),
          p_caminho_relat          CHAR(100),
          p_den_empresa            LIKE empresa.den_empresa,
          p_last_row               SMALLINT,
          m_den_empresa            LIKE empresa.den_empresa,
          g_arg_empresa            LIKE empresa.cod_empresa,
          g_arg_serial             INTEGER

   DEFINE p_versao                 CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

#MODULARES

 DEFINE sql_stmt                 CHAR(1000),
        where_clause             CHAR(500)
                                
 DEFINE m_consulta_ativa         SMALLINT                                  
 DEFINE m_count                  SMALLINT   
 DEFINE m_operacao               CHAR(10)                               
 DEFINE m_cont                   SMALLINT

 DEFINE mr_tela      RECORD
                        motorista            LIKE esp_balanca_motorista.motorista
                       ,nom_motorista        LIKE esp_balanca_motorista.nom_motorista    
                       ,num_registro_geral   LIKE esp_balanca_motorista.num_registro_geral    
                       ,cpf                  LIKE esp_balanca_motorista.cpf    
                       ,cnh                  LIKE esp_balanca_motorista.cnh    
                       ,obs_motorista        LIKE esp_balanca_motorista.obs_motorista    
                     END RECORD
                     
 DEFINE mr_telar     RECORD
                        motorista            LIKE esp_balanca_motorista.motorista
                       ,nom_motorista        LIKE esp_balanca_motorista.nom_motorista    
                       ,num_registro_geral   LIKE esp_balanca_motorista.num_registro_geral    
                       ,cpf                  LIKE esp_balanca_motorista.cpf    
                       ,cnh                  LIKE esp_balanca_motorista.cnh    
                       ,obs_motorista        LIKE esp_balanca_motorista.obs_motorista    
                     END RECORD                    
 
 DEFINE m_motorista      LIKE esp_balanca_motorista.motorista
 DEFINE m_nom_motorista  LIKE esp_balanca_motorista.nom_motorista

  DEFINE  m_rg           LIKE esp_balanca_motorista.num_registro_geral,
          m_cpf          LIKE esp_balanca_motorista.cpf,
          m_cnh          LIKE esp_balanca_motorista.cnh


#END MODULARES
 
MAIN
 
   LET p_versao = "ESP1559-10.00.01" #Favor nao alterar esta linha (SUPORTE)

   CALL log1400_isolation()

   DEFER INTERRUPT
   CALL log140_procura_caminho("esp1559.iem") RETURNING comando
   OPTIONS
      FIELD    ORDER UNCONSTRAINED,
      HELP     FILE  comando,
      HELP     KEY   control-w,
      NEXT     KEY   control-f,
      PREVIOUS KEY   control-b

#LET p_cod_empresa = '10'
#LET p_user = 'admlog'
#LET p_status = 0
   
   CALL log001_acessa_usuario("VDP", "LOGERP")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL esp1559_controle()
   END IF

END MAIN 

#----------------------------#
FUNCTION esp1559_controle()
#----------------------------#
 
   CALL log006_exibe_teclas("01 03",p_versao)
   INITIALIZE comando TO NULL
   LET m_consulta_ativa = FALSE
   CALL log130_procura_caminho("esp1559") RETURNING comando
 
   OPEN WINDOW w_esp1559 AT 2,2 WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
 
   MENU "OPCAO"
      COMMAND "Incluir" " Incluir. "
         HELP 001
         MESSAGE ""
         IF  log005_seguranca(p_user,"SUP","esp1559","IN") THEN
            CALL esp1559_incluir()
         END IF
      COMMAND "Modificar" " Modificar. "
         HELP 002
         MESSAGE ""
         IF  log005_seguranca(p_user,"SUP","esp1559","MO") THEN
           IF m_consulta_ativa THEN
              CALL esp1559_modificar()
           ELSE
              CALL log0030_mensagem( " Execute uma consulta previamente. ","info")
           END IF
         END IF
      COMMAND "Excluir"  "Excluir. "
         HELP 003
         MESSAGE ""
         IF  log005_seguranca(p_user,"SUP","esp1559","EX") THEN
           IF m_consulta_ativa THEN
              CALL esp1559_excluir()
           ELSE
              CALL log0030_mensagem( " Execute uma consulta previamente. ","info")
           END IF
         END IF
      COMMAND "Consultar"    "Consultar. "
         HELP 004
         MESSAGE ""
         IF  log005_seguranca(p_user,"SUP","esp1559","CO") THEN
            CALL esp1559_consulta()
         END IF
      COMMAND "Seguinte" "Exibe Proximo Registro"
         MESSAGE ""
         LET INT_FLAG = 0 
         IF m_consulta_ativa THEN 
            CALL esp1559_paginacao('SEGUINTE')
         ELSE 
             CALL log0030_mensagem("Efetue a Consulta Previamente", "info") 
            NEXT OPTION "Consultar"
         END IF 
      COMMAND "Anterior" "Exibe Registro Anterior"
         LET INT_FLAG = 0 
         MESSAGE ""
         IF m_consulta_ativa THEN 
            CALL esp1559_paginacao('ANTERIOR')
         ELSE 
             CALL log0030_mensagem("Efetue a Consulta Previamente", "info")
            NEXT OPTION "Consultar"
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim"        "Retorna ao Menu Anterior"
         HELP 007
      EXIT MENU
      COMMAND "Fim"   "Retorna ao menu anterior"
         EXIT MENU
        COMMAND KEY ("control-F1") "Sobre" "Informações sobre a aplicação (CTRL-F1)."
        CALL ESP_info_sobre(sourceName(),p_versao)

   END MENU
   CLOSE WINDOW w_esp1559
   
END FUNCTION

#--------------------------------#
FUNCTION esp1559_incluir()
#--------------------------------#

   DEFINE lr_tela         RECORD LIKE esp_balanca_motorista.*
   DEFINE l_erro                        SMALLINT
   DEFINE l_cod_motorista  INTEGER


   INITIALIZE mr_tela.* TO NULL
   INITIALIZE lr_tela.* TO NULL
   CLEAR FORM    
   DISPLAY p_cod_empresa TO cod_empresa   
    
   IF esp1559_entrada_dados("INCLUSAO") THEN
         SELECT DISTINCT max(motorista)
           INTO l_cod_motorista
           FROM esp_balanca_motorista
          WHERE cod_empresa = p_cod_empresa
          
          IF l_cod_motorista IS NULL
          OR l_cod_motorista = 0 THEN 
             LET mr_tela.motorista = 1
             DISPLAY mr_tela.motorista TO motorista
          ELSE 
             LET mr_tela.motorista = l_cod_motorista + 1
             DISPLAY mr_tela.motorista TO motorista
          END IF 

      CALL log085_transacao("BEGIN")

      LET lr_tela.cod_empresa          = p_cod_empresa
      LET lr_tela.motorista            = mr_tela.motorista
      LET lr_tela.nom_motorista        = mr_tela.nom_motorista
      LET lr_tela.num_registro_geral   = mr_tela.num_registro_geral
      LET lr_tela.cpf                  = mr_tela.cpf
      LET lr_tela.cnh                  = mr_tela.cnh
      LET lr_tela.obs_motorista        = mr_tela.obs_motorista
      
         INSERT INTO esp_balanca_motorista  VALUES (lr_tela.*)
      
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INCLUSAO","esp_balanca_motorista")
            LET l_erro = TRUE
         END IF
         
      IF l_erro = TRUE THEN
         CALL log085_transacao("ROLLBACK")
         CALL log0030_mensagem("Inclusao Cancelada.","info")
         RETURN FALSE
      ELSE
         CALL log085_transacao("COMMIT")
         CALL log0030_mensagem("Inclusao efetuada com sucesso.","info")
         MESSAGE " Inclusao efetuada com sucesso. " ATTRIBUTE(REVERSE)
         LET m_consulta_ativa = FALSE
         RETURN TRUE 
      END IF
   ELSE
      CALL esp1559_exibe_dados()
      CALL log0030_mensagem("Inclusao Cancelada.","info")
      LET m_consulta_ativa = FALSE
      CLEAR FORM
      CURRENT WINDOW IS w_esp1559
   END IF
END FUNCTION
#----------------------------------------#
 FUNCTION esp1559_entrada_dados(l_funcao)
#----------------------------------------#

   DEFINE l_funcao 		CHAR(20)
   DEFINE l_cod_motorista       INTEGER
   
#   LET mr_telar.* = mr_tela.*
   
   IF l_funcao = "INCLUSAO" THEN 
      INITIALIZE mr_tela.* TO NULL
   END IF 
      
   DISPLAY p_cod_empresa TO cod_empresa
   LET l_cod_motorista = 0
   
   INPUT BY NAME mr_tela.* WITHOUT DEFAULTS        

   BEFORE INPUT
    IF l_funcao = "MODIFICAR" THEN 
       NEXT FIELD nom_motorista 
    END IF 

   DISPLAY l_cod_motorista TO motorista
    
{   BEFORE FIELD motorista
      IF l_funcao = 'INCLUSAO' THEN 
         SELECT DISTINCT max(motorista)
           INTO l_cod_motorista
           FROM esp_balanca_motorista
          WHERE cod_empresa = p_cod_empresa
          
          IF l_cod_motorista IS NULL
          OR l_cod_motorista = 0 THEN 
             LET mr_tela.motorista = 1
             DISPLAY mr_tela.motorista TO motorista
             NEXT FIELD nom_motorista
          ELSE 
             LET mr_tela.motorista = l_cod_motorista + 1
             DISPLAY mr_tela.motorista TO motorista
             NEXT FIELD nom_motorista
          END IF 
      END IF   
}   
      AFTER FIELD nom_motorista
       IF mr_tela.nom_motorista IS NULL 
       OR mr_tela.nom_motorista = " " THEN 
          CALL log0030_mensagem("Informe o campo NOME DO MOTORISTA.","info")
          NEXT FIELD nom_motorista
       END IF

      AFTER FIELD num_registro_geral
         IF l_funcao = 'INCLUSAO' THEN    
            IF mr_tela.num_registro_geral IS NOT NULL 
            OR mr_tela.num_registro_geral <> " " THEN 
               SELECT DISTINCT num_registro_geral
                 FROM esp_balanca_motorista
                WHERE cod_empresa        = p_cod_empresa
                  AND num_registro_geral = mr_tela.num_registro_geral
               IF sqlca.sqlcode = 0 THEN 
                  CALL log0030_mensagem("RG ja incluso","info")
                  NEXT FIELD num_registro_geral
               END IF
            END IF
         END IF 
         
         IF l_funcao = 'MODIFICAR' THEN
            IF mr_tela.num_registro_geral <> m_rg THEN 
               SELECT DISTINCT num_registro_geral
                 FROM esp_balanca_motorista
                WHERE cod_empresa        = p_cod_empresa
                  AND num_registro_geral = m_rg
               IF sqlca.sqlcode = 0 THEN 
                  CALL log0030_mensagem("RG ja incluso","info")
                  NEXT FIELD num_registro_geral
               END IF
            END IF 
         END IF 
            
         
      AFTER FIELD cpf
         IF l_funcao = 'INCLUSAO' THEN 
            IF mr_tela.cpf IS NOT NULL 
            OR mr_tela.cpf <> " " THEN 
               SELECT DISTINCT cpf
                 FROM esp_balanca_motorista
                WHERE cod_empresa  = p_cod_empresa
                  AND cpf          = mr_tela.cpf
               IF sqlca.sqlcode = 0 THEN 
                  CALL log0030_mensagem("CPF ja incluso","info")
                  NEXT FIELD cpf
               END IF
            END IF
         END IF 
         
         IF l_funcao = 'MODIFICAR' THEN 
           IF mr_tela.cpf <> m_cpf THEN
               SELECT DISTINCT cpf
                 FROM esp_balanca_motorista
                WHERE cod_empresa  = p_cod_empresa
                  AND cpf          = m_cpf
               IF sqlca.sqlcode = 0 THEN 
                  CALL log0030_mensagem("CPF ja incluso","info")
                  NEXT FIELD cpf
               END IF
           END IF 
         END IF   
         
     AFTER FIELD cnh
        IF l_funcao = 'INCLUSAO' THEN 
           IF mr_tela.cnh IS NOT NULL 
           OR mr_tela.cnh <> " " THEN 
              SELECT DISTINCT cnh
                FROM esp_balanca_motorista
               WHERE cod_empresa   = p_cod_empresa
                 AND cnh           = mr_tela.cnh
              IF sqlca.sqlcode = 0 THEN 
                 CALL log0030_mensagem("CNH ja incluso","info")
                 NEXT FIELD cnh
              END IF
           END IF
        END IF
        
        IF l_funcao = 'MODIFICAR' THEN 
           IF mr_tela.cnh <> m_cnh THEN 
              SELECT DISTINCT cnh
                FROM esp_balanca_motorista
               WHERE cod_empresa   = p_cod_empresa
                 AND cnh           = m_cnh
              IF sqlca.sqlcode = 0 THEN 
                 CALL log0030_mensagem("CNH ja incluso","info")
                 NEXT FIELD cnh  
              END IF          
           END IF 
        END IF  

   AFTER INPUT
      IF NOT INT_FLAG THEN
      END IF
   END INPUT

   IF INT_FLAG = TRUE THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION
#-----------------------------#
FUNCTION esp1559_exibe_dados()
#-----------------------------#   

DISPLAY BY NAME mr_tela.*


   LET m_motorista     = mr_tela.motorista
   LET m_nom_motorista = mr_tela.nom_motorista 
   
   LET m_rg   = mr_tela.num_registro_geral
   LET m_cpf  = mr_tela.cpf
   LET m_cnh  = mr_tela.cnh

END FUNCTION

#------------------------------#
FUNCTION esp1559_consulta()
#------------------------------#
 DEFINE where_clause, sql_stmt   CHAR(500)
   
   INITIALIZE where_clause, sql_stmt TO NULL
   
   CALL log006_exibe_teclas("01 02",p_versao)
   CURRENT WINDOW IS w_esp1559
   LET INT_FLAG = FALSE 
   LET mr_telar.* = mr_tela.*
   INITIALIZE mr_tela.* TO NULL
   CLEAR FORM

   DISPLAY p_cod_empresa TO cod_empresa
   
   CONSTRUCT BY NAME where_clause ON esp_balanca_motorista.motorista
                                    ,esp_balanca_motorista.nom_motorista
                                    ,esp_balanca_motorista.num_registro_geral
                                    ,esp_balanca_motorista.cpf
                                    ,esp_balanca_motorista.cnh
   END CONSTRUCT 
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_esp1559
   
   IF INT_FLAG = TRUE THEN
      LET INT_FLAG = 0
      LET mr_tela.* = mr_telar.*
      ERROR "Consulta Cancelada"
      INITIALIZE mr_tela.* TO NULL
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET m_consulta_ativa = FALSE
      RETURN
   END IF

    LET sql_stmt = "SELECT motorista, nom_motorista, num_registro_geral, cpf, cnh, obs_motorista",
                   "  FROM esp_balanca_motorista ",
                   " WHERE cod_empresa = ", log0800_string(p_cod_empresa),
                   "   AND ", where_clause CLIPPED,
                   "ORDER BY motorista" 
                  
   PREPARE var_query FROM sql_stmt
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_consulta
   FETCH cq_consulta INTO mr_tela.motorista
                         ,mr_tela.nom_motorista
                         ,mr_tela.num_registro_geral
                         ,mr_tela.cpf
                         ,mr_tela.cnh                      
                         ,mr_tela.obs_motorista
   
   IF sqlca.sqlcode = NOTFOUND  THEN
      CALL log0030_mensagem( " Argumentos de pesquisa nao encontrados. ","info")
      LET m_consulta_ativa = FALSE
      RETURN
   ELSE
      LET m_consulta_ativa = TRUE 
      CALL esp1559_exibe_dados()
      CALL log0030_mensagem("Consulta Efetuada Com Sucesso. ","info")
   END IF
   
END FUNCTION

#----------------------------------#
FUNCTION esp1559_cursor_for_update()
#----------------------------------#

   DECLARE cq_update CURSOR FOR SELECT *
                                  FROM esp_balanca_motorista
                                  FOR UPDATE

   CALL log085_transacao("BEGIN")
   OPEN cq_update
   FETCH cq_update
   CASE
      WHEN sqlca.sqlcode = 0
         RETURN TRUE
      WHEN sqlca.sqlcode = -250
         CALL log0030_mensagem("Registro Sendo Atualizado Por Outro Usuario. Aguarde e Tente Novamente.", "exclamation")
      WHEN sqlca.sqlcode = 100
         CALL log0030_mensagem("Registro Nao Encontrado, Efetue a Consulta Novamente", "exclamation")
      OTHERWISE
         CALL log003_err_sql("FETCH","esp_balanca_motorista")
   END CASE

   CLOSE cq_update
   CALL log085_transacao("ROLLBACK")
   RETURN FALSE

END FUNCTION

#----------------------------#
FUNCTION esp1559_modificar()
#----------------------------#

 DEFINE l_erro    SMALLINT

   IF esp1559_cursor_for_update() = TRUE THEN
     LET mr_telar.* = mr_tela.*
     
     IF esp1559_entrada_dados("MODIFICAR") THEN
        CALL log085_transacao("BEGIN")
          DELETE FROM esp_balanca_motorista
           WHERE cod_empresa = p_cod_empresa
             AND motorista = m_motorista 
            
         INSERT INTO esp_balanca_motorista VALUES (p_cod_empresa
                                                  ,mr_tela.motorista      
                                                  ,mr_tela.nom_motorista        
                                                  ,mr_tela.num_registro_geral       
                                                  ,mr_tela.cpf            
                                                  ,mr_tela.cnh
                                                  ,mr_tela.obs_motorista)
                                            
         IF sqlca.sqlcode = 0 THEN          
            CALL log085_transacao("COMMIT") 
            MESSAGE " MODIFICAR efetuada com sucesso. "
            ATTRIBUTE(REVERSE)              
            DISPLAY BY NAME mr_tela.*
         ELSE                               
            CALL log003_err_sql("MODIFICAR","esp_balanca_motorista")
            CALL log085_transacao("ROLLBACK")
         END IF                             
      ELSE                                  
         CALL esp1559_exibe_dados()         
         ERROR " MODIFICAR Cancelada. "
      END IF
   END IF

END FUNCTION


#----------------------------#
 FUNCTION esp1559_excluir()
#----------------------------#

   IF log0040_confirm(10,10,'Deseja Realmente Excluir ' ) = FALSE THEN
      ERROR "Exclusao Cancelada"
      RETURN
   END IF

   DELETE FROM esp_balanca_motorista
    WHERE motorista = mr_tela.motorista

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('DELETE','esp_balanca_motorista')
      CALL log085_transacao('ROLLBACK')
      MESSAGE ' '
      ERROR 'Falha ao excluir'
   ELSE
      CALL log085_transacao('COMMIT')
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET m_consulta_ativa = FALSE
      MESSAGE 'Exclusao efetuada com sucesso'
   END IF

END FUNCTION                

#----------------------------#
FUNCTION esp1559_paginacao(l_funcao)
#----------------------------#
   DEFINE l_funcao             CHAR(15)

   WHILE TRUE
      IF l_funcao = 'SEGUINTE' THEN
         FETCH NEXT cq_consulta  INTO mr_tela.*
      ELSE
         FETCH PREVIOUS cq_consulta  INTO mr_tela.*
      END IF

      IF sqlca.sqlcode = 0 THEN
         SELECT DISTINCT
                motorista, nom_motorista, num_registro_geral, 
                cpf, cnh, obs_motorista
           INTO mr_tela.motorista,       
                mr_tela.nom_motorista,       
                mr_tela.num_registro_geral,          
                mr_tela.cpf,
                mr_tela.cnh,       
                mr_tela.obs_motorista
           FROM esp_balanca_motorista
          WHERE cod_empresa = p_cod_empresa
            AND motorista   = mr_tela.motorista

         IF sqlca.sqlcode <> 0 THEN
            CONTINUE WHILE
         END IF
         CALL esp1559_exibe_dados()
         EXIT WHILE
      ELSE
         CALL log0030_mensagem("Nao existem mais dados nesta direcao","info")
         LET mr_telar.* = mr_tela.*
         EXIT WHILE
      END IF
   END WHILE
END FUNCTION                                                                                        
