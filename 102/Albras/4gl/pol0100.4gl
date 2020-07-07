#-------------------------------------------------------------------#
# SISTEMA.: PLANEJAMENTO                                            #
# PROGRAMA: POL0100                                                 #
# MODULOS.: POL0100 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA DESC_NAT_OPER                      #
# AUTOR...: ALBRAS - INTERNO                                        #
# DATA....: 20/06/2000                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_nom_cliente       LIKE clientes.nom_cliente,
         p_den_nat_oper      LIKE nat_operacao.den_nat_oper,
         p_max_desc_oper     LIKE par_desc_oper.max_desc_oper,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
      #  p_nom_tela          CHAR(200),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT,
         w_cod_nat_oper      SMALLINT,
         p_den_item_reduz    LIKE item.den_item_reduz
  DEFINE p_desc_nat_oper     RECORD LIKE desc_nat_oper.*,    
         p_desc_nat_operr    RECORD LIKE desc_nat_oper.*,     
         p_clientes          RECORD LIKE clientes.*,          
         p_nat_operacao      RECORD LIKE nat_operacao.*       
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0100-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0100.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol010_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol010_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("POL0100") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0100 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0100","IN") THEN
        CALL pol010_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_desc_nat_oper.cod_cliente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0100","MO") THEN
               CALL pol010_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_desc_nat_oper.cod_cliente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0100","EX") THEN
               CALL pol010_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0100","CO") THEN
           CALL pol010_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol010_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol010_paginacao("ANTERIOR") 
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0100
END FUNCTION

#--------------------------------------#
 FUNCTION pol010_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
#  CLEAR FORM
  IF  pol010_entrada_dados("INCLUSAO") THEN
      BEGIN WORK
      INSERT INTO desc_nat_oper VALUES (p_desc_nat_oper.*)
      IF sqlca.sqlcode <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","TABELA")       
      ELSE
          COMMIT WORK 
          MESSAGE " Inclusao efetuada com sucesso. " ATTRIBUTE(REVERSE)
          LET p_ies_cons = FALSE
      END IF
  ELSE
      CLEAR FORM
      ERROR " Inclusao Cancelada. "
      RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION

#---------------------------------------#
 FUNCTION pol010_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  SELECT max_desc_oper
    INTO p_max_desc_oper
    FROM par_desc_oper 
   WHERE cod_emp_ofic = p_cod_empresa

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0100
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_desc_nat_oper.* TO NULL
    DISPLAY BY NAME p_desc_nat_oper.*
  END IF
  INPUT   BY NAME p_desc_nat_oper.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_cliente 
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD cod_nat_oper
      END IF

    AFTER FIELD cod_cliente 
      IF p_desc_nat_oper.cod_cliente  IS NOT NULL THEN
         IF pol010_verifica_cliente() THEN
            ERROR "Cliente nao cadastrado" 
            NEXT FIELD cod_cliente  
         ELSE 
            DISPLAY BY NAME p_clientes.nom_cliente 
         END IF
      ELSE ERROR "O campo COD_CLIENTE nao pode ser nulo."
           NEXT FIELD cod_cliente  
      END IF

    AFTER FIELD cod_nat_oper
      IF p_desc_nat_oper.cod_nat_oper IS NOT NULL THEN
         IF pol010_verifica_nat_oper() THEN
            ERROR "Natureza de Operacao nao cadastrada" 
            NEXT FIELD cod_nat_oper 
         ELSE 
            DISPLAY BY NAME p_nat_operacao.den_nat_oper
            IF pol010_verifica_duplicidade() THEN
               ERROR "Natureza de Operacao ja cadastrada p/ cliente" 
               NEXT FIELD cod_cliente  
            END IF
         END IF
      ELSE ERROR "O campo COD_NAT_OPER nao pode ser nulo."
           NEXT FIELD cod_nat_oper    
      END IF 

    AFTER FIELD pct_desc_valor
      IF p_desc_nat_oper.pct_desc_valor IS NOT NULL THEN
      ELSE
         LET p_desc_nat_oper.pct_desc_valor = 0               
      END IF

    AFTER FIELD pct_desc_qtd   
      IF p_desc_nat_oper.pct_desc_qtd   IS NOT NULL THEN
         IF p_desc_nat_oper.pct_desc_valor>0 AND
            p_desc_nat_oper.pct_desc_qtd>0  THEN
            ERROR "Apenas um dos descontos deve ser consedido"    
            NEXT FIELD pct_desc_valor  
         ELSE 
            IF p_desc_nat_oper.pct_desc_valor=0 AND
               p_desc_nat_oper.pct_desc_qtd=0  THEN
               ERROR "Um dos descontos deve ser maior que 0"         
               NEXT FIELD pct_desc_valor  
            END IF 
         END IF 
      ELSE
         LET p_desc_nat_oper.pct_desc_qtd  = 0               
         IF p_desc_nat_oper.pct_desc_valor=0 AND
            p_desc_nat_oper.pct_desc_qtd=0  THEN
            ERROR "Um dos descontos deve ser maior que 0"         
            NEXT FIELD pct_desc_valor  
         END IF 
      END IF   

    AFTER FIELD pct_desc_oper  
      IF p_desc_nat_oper.pct_desc_qtd   IS NOT NULL THEN
#        IF p_desc_nat_oper.pct_desc_oper=0 THEN          
#           ERROR "Valor do desconto operacao deve ser maior que 0" 
#           NEXT FIELD pct_desc_oper  
#        ELSE 
            IF p_desc_nat_oper.pct_desc_oper > p_max_desc_oper THEN
               ERROR "Valor do desconto operacao maior que o permitido" 
               NEXT FIELD pct_desc_oper  
            END IF
#        END IF
      ELSE 
         ERROR "Valor do desconto operacao deve ser maior que 0" 
         NEXT FIELD pct_desc_oper   
      END IF 

   ON KEY (control-z)
        CALL pol0100_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0100
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol010_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM

 CONSTRUCT BY NAME where_clause ON desc_nat_oper.cod_cliente,
                                   desc_nat_oper.cod_nat_oper
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0100
 IF int_flag THEN
   LET int_flag = 0 
   LET p_desc_nat_oper.* = p_desc_nat_operr.*
   CALL pol010_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM desc_nat_oper ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY cod_cliente, cod_nat_oper "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_desc_nat_oper.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol010_verifica_cliente() THEN
         LET p_clientes.nom_cliente=" NAO CADASTRADO" 
      END IF
      IF pol010_verifica_nat_oper() THEN
         LET p_clientes.nom_cliente=" NAO CADASTRADO" 
      END IF
      LET p_ies_cons = TRUE
   END IF
    CALL pol010_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol010_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_desc_nat_oper.* 
  DISPLAY BY NAME p_clientes.nom_cliente 
  DISPLAY BY NAME p_nat_operacao.den_nat_oper 

END FUNCTION

#------------------------------------#
 FUNCTION pol010_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_desc_nat_operr.* = p_desc_nat_oper.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_desc_nat_oper.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_desc_nat_oper.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_desc_nat_oper.* = p_desc_nat_operr.* 
           EXIT WHILE
        END IF
        
        LET w_cod_nat_oper = p_desc_nat_oper.cod_nat_oper
        SELECT * INTO p_desc_nat_oper.* FROM desc_nat_oper    
        WHERE cod_cliente = p_desc_nat_oper.cod_cliente
          AND cod_nat_oper = w_cod_nat_oper 
  
        IF sqlca.sqlcode = 0 THEN 
           IF pol010_verifica_cliente() THEN
              LET p_clientes.nom_cliente=" NAO CADASTRADO" 
           END IF
           IF pol010_verifica_nat_oper() THEN
              LET p_clientes.nom_cliente=" NAO CADASTRADO" 
           END IF
           CALL pol010_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 

 
#------------------------------------#
 FUNCTION pol010_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     INTO p_desc_nat_oper.*                                              
     FROM desc_nat_oper      
    WHERE cod_cliente = p_desc_nat_oper.cod_cliente
      AND cod_nat_oper = p_desc_nat_oper.cod_nat_oper
 FOR UPDATE 
   BEGIN WORK
   OPEN cm_padrao
   FETCH cm_padrao
   CASE sqlca.sqlcode
     
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","TABELA")
   END CASE
   WHENEVER ERROR STOP
   RETURN FALSE

 END FUNCTION


#----------------------------------#
 FUNCTION pol010_modificacao()
#----------------------------------#
   IF pol010_cursor_for_update() THEN
      LET p_desc_nat_operr.* = p_desc_nat_oper.*
      IF pol010_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE desc_nat_oper SET cod_nat_oper = p_desc_nat_oper.cod_nat_oper,
                                 pct_desc_valor= p_desc_nat_oper.pct_desc_valor,
                                 pct_desc_qtd  = p_desc_nat_oper.pct_desc_qtd
         WHERE CURRENT OF cm_padrao
         IF sqlca.sqlcode = 0 THEN
            COMMIT WORK
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TABELA")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TABELA")
            ROLLBACK WORK
         END IF
      ELSE
         LET p_desc_nat_oper.* = p_desc_nat_operr.*
         ERROR "Modificacao Cancelada"
         ROLLBACK WORK
         DISPLAY BY NAME p_desc_nat_oper.cod_cliente 
         DISPLAY BY NAME p_clientes.nom_cliente                
         DISPLAY BY NAME p_desc_nat_oper.cod_nat_oper
         DISPLAY BY NAME p_nat_operacao.den_nat_oper             
         DISPLAY BY NAME p_desc_nat_oper.pct_desc_valor
         DISPLAY BY NAME p_desc_nat_oper.pct_desc_qtd 
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol010_exclusao()
#----------------------------------------#
   IF pol010_verifica_pedido() THEN
    IF pol010_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM desc_nat_oper    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             COMMIT WORK
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_desc_nat_oper.* TO NULL
                CLEAR FORM
             END IF
          ELSE
             CALL log003_err_sql("EXCLUSAO","TABELA")
             ROLLBACK WORK
          END IF
          WHENEVER ERROR STOP
       ELSE
          ROLLBACK WORK
       END IF
       CLOSE cm_padrao
      END IF
     ELSE
       MESSAGE "Cliente possui pedido,exclusao cancelada" ATTRIBUTE(REVERSE)
     END IF
 END FUNCTION  

#------------------------------------#
 FUNCTION pol010_verifica_cliente()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT nom_cliente
  INTO p_clientes.nom_cliente
  FROM clientes               
 WHERE cod_cliente  = p_desc_nat_oper.cod_cliente

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#------------------------------------#
 FUNCTION pol010_verifica_nat_oper()
#------------------------------------#
DEFINE p_cont           SMALLINT


LET w_cod_nat_oper = p_desc_nat_oper.cod_nat_oper

SELECT den_nat_oper
  INTO p_nat_operacao.den_nat_oper
  FROM nat_operacao           
 WHERE cod_nat_oper = w_cod_nat_oper 

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#------------------------------------#
 FUNCTION pol010_verifica_pedido()
#------------------------------------#
DEFINE p_contador      SMALLINT

SELECT count(*)    
  INTO p_contador                  
  FROM pedidos                
 WHERE cod_nat_oper = p_desc_nat_oper.cod_nat_oper 
 AND   cod_cliente  = p_desc_nat_oper.cod_cliente

IF sqlca.sqlcode = 0 THEN
   IF p_contador > 0   THEN
      RETURN FALSE 
   ELSE
      RETURN TRUE 
   END IF
ELSE
   RETURN TRUE 
END IF

END FUNCTION 



#------------------------------------#
 FUNCTION pol010_verifica_duplicidade()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT COUNT(*) 
  INTO p_cont
  FROM desc_nat_oper
 WHERE cod_cliente  = p_desc_nat_oper.cod_cliente
   AND cod_nat_oper = p_desc_nat_oper.cod_nat_oper 

IF p_cont > 0 THEN
   RETURN TRUE
ELSE
   RETURN FALSE
END IF

END FUNCTION   

#-----------------------#
 FUNCTION pol0100_popup()
#-----------------------#
  DEFINE p_cod_nat_oper       LIKE nat_operacao.cod_nat_oper,
         p_cod_cliente        LIKE clientes.cod_cliente
  
  CASE
    WHEN infield(cod_nat_oper)
         CALL log009_popup(6,25,"NAT. OPERACAO","nat_operacao",
                          "cod_nat_oper","den_nat_oper",
                          "vdp0050","N","") RETURNING p_cod_nat_oper
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0100 
         IF   p_cod_nat_oper IS NOT NULL OR
              p_cod_nat_oper <> " " 
         THEN
              LET p_desc_nat_oper.cod_nat_oper  = p_cod_nat_oper  
              DISPLAY BY NAME p_desc_nat_oper.cod_nat_oper
         END IF
    WHEN infield(cod_cliente)
         LET  p_cod_cliente = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0100   
         IF   p_cod_cliente IS NOT NULL
         THEN LET  p_desc_nat_oper.cod_cliente = p_cod_cliente
              DISPLAY BY NAME p_desc_nat_oper.cod_cliente
         END IF
  END CASE
END FUNCTION
