#-------------------------------------------------------------------#
# SISTEMA.: PLANEJAMENTO                                            #
# PROGRAMA: pol0824                                                 #
# MODULOS.: pol0824 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA composicao_chapa_885               #
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
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT,
         pr_index             SMALLINT,
         sr_index             SMALLINT,
         pr_index2            SMALLINT,  
         sr_index2            SMALLINT,
         p_cod_item           CHAR(15),
         p_den_item_reduz    LIKE item.den_item_reduz

  DEFINE p_composicao_chapa_885     RECORD LIKE composicao_chapa_885.*,    
         p_composicao_chapa_885r    RECORD LIKE composicao_chapa_885.*,
         p_item                     RECORD LIKE item.*
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0824-05.10.01"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0824.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0824_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0824_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0824") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0824 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0824","IN") THEN
        CALL pol0824_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_composicao_chapa_885.cod_item IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0824","MO") THEN
               CALL pol0824_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_composicao_chapa_885.cod_item IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0824","EX") THEN
               CALL pol0824_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0824","CO") THEN
           CALL pol0824_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0824_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0824_paginacao("ANTERIOR") 
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
  CLOSE WINDOW w_pol0824
END FUNCTION

#---------------------------------------#
 FUNCTION pol0824_inclusao()
#---------------------------------------#
  LET p_houve_erro = FALSE

  IF  pol0824_entrada_dados("INCLUSAO") THEN
      #BEGIN WORK
      CALL log085_transacao("BEGIN")
      INSERT INTO composicao_chapa_885 VALUES (p_composicao_chapa_885.*)
      IF sqlca.sqlcode <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","TABELA")       
      ELSE
          #COMMIT WORK 
          CALL log085_transacao("COMMIT")
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
 FUNCTION pol0824_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0824
  IF p_funcao = "INCLUSAO" THEN
    CLEAR FORM
    INITIALIZE p_composicao_chapa_885.* TO NULL
  END IF

  INPUT   BY NAME p_composicao_chapa_885.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_item
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD den_comp
      END IF

    AFTER FIELD cod_item 
      IF p_composicao_chapa_885.cod_item  IS NOT NULL THEN
         IF pol0824_verifica_item() THEN
            MESSAGE "Item nao cadastrado" 
            NEXT FIELD cod_item  
         ELSE 
            DISPLAY BY NAME p_item.den_item
         END IF
      ELSE ERROR "O campo cod_item nao pode ser nulo."
           NEXT FIELD cod_item  
      END IF

    AFTER FIELD den_comp
      IF p_composicao_chapa_885.den_comp IS NULL THEN
         MESSAGE "O campo den_comp nao pode ser nulo."
         NEXT FIELD den_comp    
      END IF 

   ON KEY (control-z)
        CALL pol0824_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0824
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION

#--------------------------#
 FUNCTION pol0824_consulta()
#--------------------------#
 
 DEFINE sql_stmt, where_clause    CHAR(300)  
 
 CLEAR FORM
 
 LET p_composicao_chapa_885r.* = p_composicao_chapa_885.*

 CONSTRUCT BY NAME where_clause ON 	 composicao_chapa_885.cod_item,
                                     composicao_chapa_885.den_comp

   ON KEY (control-z)
        CALL pol0824_popup()
       
END CONSTRUCT
                                     
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0824
 IF int_flag THEN
   LET int_flag = 0 
   LET p_composicao_chapa_885.* = p_composicao_chapa_885r.*
   CALL pol0824_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM composicao_chapa_885 ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY cod_item, den_comp "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_composicao_chapa_885.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
      RETURN
   ELSE 
      IF pol0824_verifica_item() THEN
         LET p_item.den_item=" NAO CADASTRADO" 
      END IF
      LET p_ies_cons = TRUE
   END IF
    CALL pol0824_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0824_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_composicao_chapa_885.* 
  DISPLAY BY NAME p_item.den_item 

END FUNCTION

#------------------------------------#
 FUNCTION pol0824_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_composicao_chapa_885r.* = p_composicao_chapa_885.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_composicao_chapa_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_composicao_chapa_885.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_composicao_chapa_885.* = p_composicao_chapa_885r.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_composicao_chapa_885.* FROM composicao_chapa_885    
        WHERE cod_item  = p_composicao_chapa_885.cod_item
  
        IF sqlca.sqlcode = 0 THEN 
           IF pol0824_verifica_item() THEN
              LET p_item.den_item=" NAO CADASTRADO" 
           END IF
           CALL pol0824_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 

 
#------------------------------------#
 FUNCTION pol0824_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     FROM composicao_chapa_885      
    WHERE cod_item  = p_composicao_chapa_885.cod_item
      AND den_comp = p_composicao_chapa_885.den_comp
 
   #BEGIN WORK
   CALL log085_transacao("BEGIN")
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
 FUNCTION pol0824_modificacao()
#----------------------------------#
   IF pol0824_cursor_for_update() THEN
      LET p_composicao_chapa_885r.* = p_composicao_chapa_885.*
      IF pol0824_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE composicao_chapa_885 SET den_comp = p_composicao_chapa_885.den_comp
         WHERE cod_item = p_composicao_chapa_885.cod_item
 
         IF sqlca.sqlcode = 0 THEN
            #COMMIT WORK
            CALL log085_transacao("COMMIT")
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TABELA")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TABELA")
            #ROLLBACK WORK
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         LET p_composicao_chapa_885.* = p_composicao_chapa_885r.*
         ERROR "Modificacao Cancelada"
         #ROLLBACK WORK
         CALL log085_transacao("ROLLBACK")
         DISPLAY BY NAME p_composicao_chapa_885.cod_item 
         DISPLAY BY NAME p_item.den_item                
         DISPLAY BY NAME p_composicao_chapa_885.den_comp
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0824_exclusao()
#----------------------------------------#
    IF pol0824_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM composicao_chapa_885    
         WHERE cod_item = p_composicao_chapa_885.cod_item
         AND den_comp = p_composicao_chapa_885.den_comp
         
          IF sqlca.sqlcode = 0 THEN
             #COMMIT WORK
             CALL log085_transacao("COMMIT")
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_composicao_chapa_885.* TO NULL
                CLEAR FORM
             END IF
          ELSE
             CALL log003_err_sql("EXCLUSAO","TABELA")
             #ROLLBACK WORK
             CALL log085_transacao("ROLLBACK")
          END IF
          WHENEVER ERROR STOP
       ELSE
          #ROLLBACK WORK
          CALL log085_transacao("ROLLBACK")
       END IF
       CLOSE cm_padrao
      END IF
 END FUNCTION  

#------------------------------------#
 FUNCTION pol0824_verifica_item()
#------------------------------------#
DEFINE p_cont            SMALLINT,
       l_cod_grupo_item  LIKE item_vdp.cod_grupo_item

SELECT den_item
  INTO p_item.den_item
  FROM item               
 WHERE cod_item  = p_composicao_chapa_885.cod_item
   AND cod_empresa = p_cod_empresa

IF sqlca.sqlcode = 0 THEN
   SELECT cod_grupo_item
     INTO l_cod_grupo_item
     FROM item_vdp
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_composicao_chapa_885.cod_item
   IF l_cod_grupo_item = '02' THEN     
      RETURN FALSE
   ELSE
      ERROR 'Item nao e chapa'
      RETURN TRUE
   END IF    
ELSE
   ERROR 'Item nao cadastrado'
   RETURN TRUE
END IF

END FUNCTION 

#-----------------------#
 FUNCTION pol0824_popup()
#-----------------------#
  DEFINE p_cod_item        LIKE item.cod_item
  
  CASE
    WHEN infield(cod_item)
         LET p_cod_item = vdp373_popup_item(p_cod_empresa) 
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_cod_item IS NOT NULL THEN
            LET p_composicao_chapa_885.cod_item  = p_cod_item
            DISPLAY BY NAME p_composicao_chapa_885.cod_item
         END IF    
  END CASE
END FUNCTION
