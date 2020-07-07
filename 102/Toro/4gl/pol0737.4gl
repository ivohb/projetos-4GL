#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0737                                                 #
# MODULOS.: pol0737-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: PARAMETROS PARA ETIQUETA - TORO                         #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 18/02/2008                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
          p_msg                CHAR(300),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_num_ordem          INTEGER,
          p_serie              INTEGER,
          p_qtd_pecas          INTEGER,
          p_cod_item_cliente   CHAR(30),
          p_dt_coleta          DATE,
          p_ies_situacao       CHAR(01),
          p_tipo               CHAR(02),
          p_cod_usuario        CHAR(08),
          p_cod_formulario     CHAR(03),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_cod_item           CHAR(15),
          p_den_item           CHAR(50),
          p_cod_item_cliente2  CHAR(15)
          
   DEFINE p_etiq_coletada_912   RECORD LIKE etiq_coletada_912.*,
          p_etiq_coletada_912a  RECORD LIKE etiq_coletada_912.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0737-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0737.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0737_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0737_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0737") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0737 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0737_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
          COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0737_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0737_paginacao("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0737_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0737_sobre() 
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0737

END FUNCTION

#-----------------------#
FUNCTION pol0737_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#--------------------------#
 FUNCTION pol0737_inclusao()
#--------------------------#
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_etiq_coletada_912.* TO NULL
   LET p_etiq_coletada_912.cod_empresa = p_cod_empresa

   IF pol0737_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO etiq_coletada_912 VALUES (p_etiq_coletada_912.*)
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
 FUNCTION pol0737_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0737

   INPUT BY NAME p_etiq_coletada_912.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD num_ordem
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD ies_situacao
      END IF 
      
      AFTER FIELD ies_situacao
      IF p_etiq_coletada_912.ies_situacao MATCHES '[LT]' THEN 
      ELSE
         ERROR "Digite (L ou T) Para a situação !!!"
         NEXT FIELD ies_situacao
    END IF   
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0737

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION
#--------------------------#
 FUNCTION pol0737_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_etiq_coletada_912a.* = p_etiq_coletada_912.*

   CONSTRUCT BY NAME where_clause ON p_etiq_coletada_912.cod_item_cliente
  
      ON KEY (control-z)
      LET p_cod_item_cliente = pol0737_carrega_form()
      IF p_cod_item_cliente IS NOT NULL THEN
         LET p_etiq_coletada_912.cod_item_cliente = p_cod_item_cliente
         CURRENT WINDOW IS w_pol0737
       END IF 
     
      LET p_serie = pol0737_carrega_formu()
      IF p_serie IS NOT NULL THEN
         LET p_etiq_coletada_912.serie = p_serie
         CURRENT WINDOW IS w_pol0737
      END IF 
         
         SELECT qtd_pecas,num_ordem, dt_coleta, ies_situacao, tipo, cod_usuario
         INTO p_qtd_pecas,p_num_ordem, p_dt_coleta, p_ies_situacao, p_tipo, p_cod_usuario
         FROM etiq_coletada_912
         WHERE cod_empresa    = p_cod_empresa
         AND cod_item_cliente = p_cod_item_cliente
         AND serie = p_etiq_coletada_912.serie
         AND ies_situacao = 'E'
         AND tipo = 'C'
      
         SELECT a.cod_item,a.cod_item_cliente,b.den_item
          INTO  p_cod_item,p_cod_item_cliente2,p_den_item
          FROM  cliente_item a,item b
          WHERE a.cod_empresa = p_cod_empresa
          AND   a.cod_item = b.cod_item
          AND   a.cod_item_cliente = p_etiq_coletada_912.cod_item_cliente
        
          LET p_etiq_coletada_912.qtd_pecas = p_qtd_pecas
          LET p_etiq_coletada_912.num_ordem = p_num_ordem
          LET p_etiq_coletada_912.dt_coleta = p_dt_coleta
          LET p_etiq_coletada_912.ies_situacao = p_ies_situacao
          LET p_etiq_coletada_912.tipo = p_tipo
          LET p_etiq_coletada_912.cod_usuario = p_cod_usuario
        
         DISPLAY p_etiq_coletada_912.serie TO serie 
         DISPLAY p_etiq_coletada_912.qtd_pecas TO qtd_pecas
         DISPLAY p_etiq_coletada_912.cod_item_cliente TO cod_item_cliente
         DISPLAY p_etiq_coletada_912.dt_coleta TO dt_coleta  
         DISPLAY p_etiq_coletada_912.ies_situacao TO ies_situacao 
         DISPLAY p_etiq_coletada_912.tipo TO tipo 
         DISPLAY p_etiq_coletada_912.cod_usuario TO cod_usuario 
         DISPLAY p_etiq_coletada_912.num_ordem TO num_ordem
         DISPLAY p_cod_empresa TO cod_empresa
         DISPLAY p_cod_item TO cod_item
         DISPLAY p_cod_item_cliente2 TO cod_item_cliente2
         DISPLAY p_den_item TO den_item

   END CONSTRUCT      
 
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0737

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_etiq_coletada_912.* = p_etiq_coletada_912a.*
      CALL pol0737_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM etiq_coletada_912 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  "and ies_situacao = 'E'",
                  "and tipo = 'C'",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_item_cliente "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_etiq_coletada_912.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0737_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0737_exibe_dados()
#------------------------------#
    SELECT a.cod_item,a.cod_item_cliente,b.den_item
    INTO  p_cod_item,p_cod_item_cliente2,p_den_item
    FROM  cliente_item a,item b
    WHERE a.cod_empresa = p_cod_empresa
    AND   a.cod_item = b.cod_item
    AND   a.cod_item_cliente = p_etiq_coletada_912.cod_item_cliente
                
   DISPLAY BY NAME p_etiq_coletada_912.*
   DISPLAY p_cod_item TO cod_item
   DISPLAY p_cod_item_cliente2 TO cod_item_cliente2
   DISPLAY p_den_item TO den_item
 
END FUNCTION

#-----------------------------------#
 FUNCTION pol0737_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_etiq_coletada_912.*                                              
     FROM etiq_coletada_912
    WHERE cod_empresa    = p_cod_empresa
      AND cod_item_cliente = p_etiq_coletada_912.cod_item_cliente
      AND serie = p_etiq_coletada_912.serie
      AND ies_situacao = 'E'
      AND tipo = 'C'
      
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","etiq_coletada_912")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0737_modificacao()
#-----------------------------#

   DEFINE p_msg CHAR(100),
          p_dat CHAR(10),
          p_hor CHAR(08)
   
   LET p_retorno = FALSE
   LET p_dat = TODAY
   LET p_hor = TIME

   IF pol0737_cursor_for_update() THEN
      LET p_etiq_coletada_912a.* = p_etiq_coletada_912.*
      IF pol0737_entrada_dados("MODIFICACAO") THEN
         UPDATE etiq_coletada_912
            SET ies_situacao = p_etiq_coletada_912.ies_situacao
          WHERE cod_empresa    = p_cod_empresa
            AND cod_item_cliente = p_etiq_coletada_912.cod_item_cliente 
            AND ies_situacao = 'E'
            AND serie = p_etiq_coletada_912.serie
            AND tipo = 'C'
            
      
         IF STATUS = 0 THEN
            IF p_etiq_coletada_912.ies_situacao = 'L' THEN
               LET p_msg = "Transferencia de situacao de E para L"
            ELSE
               LET p_msg = "Transferencia de situacao de E para T"
            END IF
            INSERT INTO audit_toro
             VALUES(p_cod_empresa,
                    p_etiq_coletada_912.cod_item_cliente,
                    p_msg,
                    "POL0737",
                    p_dat,
                    p_hor,
                    p_user)
            IF STATUS = 0 THEN
               LET p_retorno = TRUE
            ELSE
               CALL log003_err_sql("Inclusao","audit_toro")
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","etiq_coletada_912")
         END IF
      ELSE
         LET p_etiq_coletada_912.* = p_etiq_coletada_912a.*
         CALL pol0737_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#-----------------------------------#
 FUNCTION pol0737_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_etiq_coletada_912a.* = p_etiq_coletada_912.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_etiq_coletada_912.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_etiq_coletada_912.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_etiq_coletada_912.* = p_etiq_coletada_912a.* 
            EXIT WHILE
         END IF

     SELECT * 
     INTO p_etiq_coletada_912.*                                              
     FROM etiq_coletada_912
    WHERE cod_empresa    = p_cod_empresa
      AND cod_item_cliente = p_etiq_coletada_912.cod_item_cliente
      AND serie = p_etiq_coletada_912.serie
      AND ies_situacao = 'E'
      AND tipo = 'C' 
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0737_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION
#-----------------------------------#   
 FUNCTION pol0737_carrega_form() 
#-----------------------------------#
 
  DEFINE pr_lista       ARRAY[3000]
     OF RECORD
         cod_item_cliente   LIKE etiq_coletada_912.cod_item_cliente
         
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07371") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07371 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_lista CURSOR FOR 
    SELECT UNIQUE cod_item_cliente           
      FROM etiq_coletada_912
     WHERE cod_empresa = p_cod_empresa
      AND ies_situacao = 'E'
      AND tipo = 'C'
     ORDER BY cod_item_cliente

   LET pr_index = 1

   FOREACH cq_lista INTO pr_lista[pr_index].cod_item_cliente 
                        

      LET pr_index = pr_index + 1
      IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_lista TO sr_lista.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0737

   LET p_etiq_coletada_912.cod_item_cliente = pr_lista[pr_index].cod_item_cliente
   
   RETURN pr_lista[pr_index].cod_item_cliente
      
END FUNCTION 



#-----------------------------------#   
 FUNCTION pol0737_carrega_formu() 
#-----------------------------------#
 
  DEFINE pr_listas       ARRAY[3000]
     OF RECORD
         serie   LIKE etiq_coletada_912.serie
         
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07372") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07372 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_listas CURSOR FOR 
    SELECT serie
      FROM etiq_coletada_912
     WHERE cod_empresa = p_cod_empresa
     AND cod_item_cliente = p_etiq_coletada_912.cod_item_cliente
      AND ies_situacao = 'E'
      AND tipo = 'C'
     

   LET pr_index = 1

   FOREACH cq_listas INTO pr_listas[pr_index].serie 
                        

      LET pr_index = pr_index + 1
      IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_listas TO sr_listas.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0737

   LET p_etiq_coletada_912.serie = pr_listas[pr_index].serie
   
   RETURN pr_listas[pr_index].serie
      
END FUNCTION 

#-------------------------------- FIM DE PROGRAMA -----------------------------#