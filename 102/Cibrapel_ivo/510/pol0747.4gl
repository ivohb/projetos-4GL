#-------------------------------------------------------------------#
# PROGRAMA: pol0747                                                 #
# MODULOS.: pol0747-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: ROTA DE FRETE - CIBRAPEL                                #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 27/02/2008                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_cod_percurso        CHAR(01),
          p_val_tonelada       DECIMAL(12,2),
          p_num_versao         INTEGER,
          p_ies_versao_atual   CHAR(01), 
          p_dat_atualiz        DATE,
          p_user               LIKE usuario.nom_usuario,
          numerador            SMALLINT,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_cod_percursos      CHAR(01),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_trim               CHAR(10),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_ies_cons           SMALLINT,
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          pr_index2            SMALLINT,  
          sr_index2            SMALLINT,
          p_numerador          SMALLINT,
          p_msg                CHAR(100) 
         
          
          
          
   DEFINE p_frete_peso_885       RECORD LIKE frete_peso_885.*,
          p_frete_peso_885a      RECORD LIKE frete_peso_885.*
          
           

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0747-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0747.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0747_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0747_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0747") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0747 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0747_inclusao() THEN
            MESSAGE 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Opera��o cancelada !!!'
         END IF
       COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0747_modificacao() THEN
               MESSAGE 'Modifica��o efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0747_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0747_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0747_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0747_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0747

END FUNCTION

#--------------------------#
 FUNCTION pol0747_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
  
   INITIALIZE p_frete_peso_885.* TO NULL
   LET p_frete_peso_885.cod_empresa = p_cod_empresa

   IF pol0747_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO frete_peso_885 VALUES (p_frete_peso_885.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
      ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      END IF 
   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0747_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
   LET numerador = 1 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0747




  INPUT BY NAME p_frete_peso_885.cod_empresa,
                p_frete_peso_885.cod_percurso,
                p_frete_peso_885.val_tonelada
                            
                 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_percurso
        IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD val_tonelada
      END IF 
      
      
      AFTER FIELD cod_percurso
        IF p_frete_peso_885.cod_percurso IS NULL THEN 
          ERROR "Campo com preenchimento obrigat�rio !!!"
          NEXT FIELD cod_percurso
        ELSE 
          SELECT cod_percurso
          INTO   p_cod_percursos
          FROM   frete_peso_885
          WHERE  cod_percurso = p_frete_peso_885.cod_percurso
          AND    ies_versao_atual = 'S'
          
          IF STATUS = 0 THEN 
          ERROR "Codigo Ja Cadastrado"
          NEXT FIELD cod_percurso
          END IF 
          
          NEXT FIELD val_tonelada
       END IF
                           
      AFTER FIELD val_tonelada
        IF p_frete_peso_885.val_tonelada IS NULL THEN 
          ERROR "Campo com preenchimento obrigat�rio !!!"
          NEXT FIELD val_tonelada
        END IF
        
    INITIALIZE p_cod_percursos TO NULL 

  
   LET p_frete_peso_885.num_versao = 1 
   LET p_frete_peso_885.dat_atualiz = TODAY 
   LET p_frete_peso_885.ies_versao_atual = 'S' 
 
   INSERT INTO frete_peso_885

  VALUES(p_frete_peso_885.num_versao,
         p_frete_peso_885.dat_atualiz,
         p_frete_peso_885.ies_versao_atual )
         
   
                          
   END INPUT 


  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0747

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE 
   END IF 

END FUNCTION


#--------------------------#
 FUNCTION pol0747_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause  CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_frete_peso_885.* TO NULL
   LET p_frete_peso_885a.* = p_frete_peso_885.*

   CONSTRUCT BY NAME where_clause ON frete_peso_885.val_frete

      ON KEY (control-z)
         

          
   END CONSTRUCT      
    
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0747

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_frete_peso_885.* = p_frete_peso_885a.*
      CALL pol0747_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM frete_peso_885 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                   "and ies_versao_atual = '",'S',"' ",
                   "ORDER BY cod_percurso "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_frete_peso_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0747_exibe_dados()

      
   END IF

END FUNCTION



#------------------------------#
 FUNCTION pol0747_exibe_dados()
#------------------------------#

 DISPLAY p_frete_peso_885.cod_percurso TO cod_percurso
 DISPLAY p_frete_peso_885.val_tonelada TO val_tonelada
   
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0747_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_frete_peso_885.*                                              
     FROM frete_peso_885
    WHERE cod_empresa = p_cod_empresa
    AND cod_percurso = p_frete_peso_885.cod_percurso
    AND ies_versao_atual = 'S'

        
    #FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
   

      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","frete_peso_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0747_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

 
  LET p_cod_percurso = p_frete_peso_885.cod_percurso
  LET p_val_tonelada = p_frete_peso_885.val_tonelada
  LET p_dat_atualiz = TODAY
  LET p_ies_versao_atual = 'N'
  
     SELECT COUNT (*) 
     INTO p_num_versao                                              
     FROM frete_peso_885
    WHERE cod_empresa = p_cod_empresa
    AND cod_percurso = p_frete_peso_885.cod_percurso
    
                      
   IF pol0747_cursor_for_update() THEN
      LET p_frete_peso_885a.* = p_frete_peso_885.*
      IF pol0747_entrada_dados("MODIFICACAO") THEN
         UPDATE frete_peso_885
            SET val_tonelada = p_frete_peso_885.val_tonelada,
                num_versao        = p_num_versao + 1,
                ies_versao_atual  = 'S'
             WHERE cod_empresa = p_cod_empresa
            AND cod_percurso = p_frete_peso_885.cod_percurso
            AND ies_versao_atual = 'S'
            
            
            
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","frete_peso_885")
         END IF
      ELSE
         LET p_frete_peso_885.* = p_frete_peso_885a.*
         CALL pol0747_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF
  
     SELECT COUNT (*) 
     INTO p_numerador                                             
     FROM frete_peso_885
    WHERE cod_empresa = p_cod_empresa
    AND cod_percurso = p_frete_peso_885.cod_percurso
    
  
  
      INSERT INTO frete_peso_885
  VALUES (p_cod_empresa,
          p_cod_percurso, 
          p_val_tonelada, 
          p_numerador,
          p_ies_versao_atual,
          p_dat_atualiz )

     
 
            
                
   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION 



#-----------------------------------#
 FUNCTION pol0747_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_frete_peso_885a.* = p_frete_peso_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_frete_peso_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_frete_peso_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Dire��o"
            LET p_frete_peso_885.* = p_frete_peso_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_frete_peso_885.*
           FROM frete_peso_885
          WHERE cod_empresa = p_cod_empresa
          AND cod_percurso = p_frete_peso_885.cod_percurso
          AND ies_versao_atual = 'S'

           
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0747_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0747_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#