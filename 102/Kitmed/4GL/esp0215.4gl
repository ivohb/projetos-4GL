
#-------------------------------------------------------------------#
# PROGRAMA: esp0215                                                 #
# OBJETIVO: MANUTENCAO DA TABELA bkp_ctr_unid_med                   #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_nom_cliente       LIKE clientes.nom_cliente,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_tela_nom          CHAR(200),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT,
         p_den_item_reduz    LIKE item.den_item_reduz
         
   DEFINE p_tab_cli      ARRAY[200] OF RECORD
          cod_cli_novo    LIKE clientes.cod_cliente,
          nom_cli_novo    LIKE clientes.nom_cliente
   END RECORD

DEFINE p_ind                 INTEGER,
       pa_curr               SMALLINT,
       sc_curr               SMALLINT,
       p_count               SMALLINT,
       p_cod_copia           LIKE item.cod_item,   
       p_cod_novo            LIKE item.cod_item, 
       p_den_copia           LIKE item.den_item,
       p_den_novo            LIKE item.den_item,
       p_fat_novo            DECIMAL(13,9),
       p_cod_unid_novo       CHAR(03) 
         
   DEFINE p_bkp_ctr_unid_med    RECORD
       cod_empresa          CHAR(2),
       cod_cliente          CHAR(15),
       cod_item             CHAR(15),
       cod_unid_med_cli     CHAR(3),
       fat_conver           DECIMAL(14,9),
       num_nff              DECIMAL(6,0),
       pre_unit_um          DECIMAL(17,6)
   END RECORD

   DEFINE p_bkp_ctr_unid_medr    RECORD
       cod_empresa          CHAR(2),
       cod_cliente          CHAR(15),
       cod_item             CHAR(15),
       cod_unid_med_cli     CHAR(3),
       fat_conver           DECIMAL(14,9),
       num_nff              DECIMAL(6,0),
       pre_unit_um          DECIMAL(17,6)
   END RECORD

   DEFINE pn_bkp_ctr_unid_med    RECORD
       cod_empresa          CHAR(2),
       cod_cliente          CHAR(15),
       cod_item             CHAR(15),
       cod_unid_med_cli     CHAR(3),
       fat_conver           DECIMAL(14,9),
       num_nff              DECIMAL(6,0),
       pre_unit_um          DECIMAL(17,6)
   END RECORD
   
  DEFINE p_clientes          RECORD LIKE clientes.*,          
         p_item              RECORD LIKE item.*,
         p_nat_operacao      RECORD LIKE nat_operacao.*   
END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "ESP0215-05.10.05"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("esp0215.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

###aquioooooooo
##       LET p_user = 'admlog'
##       LET p_cod_empresa = '20'
###aquioooooooo

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL esp0215_controle()
  END IF
  
END MAIN

#--------------------------#
 FUNCTION esp0215_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_tela_nom TO NULL
  CALL log130_procura_caminho("esp0215") RETURNING p_tela_nom
  LET  p_tela_nom = p_tela_nom CLIPPED 
#  LET  p_tela_nom = 'esp0215'
  OPEN WINDOW w_esp0215 AT 2,5 WITH FORM p_tela_nom 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","esp0215","IN") THEN
        CALL esp0215_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_bkp_ctr_unid_med.cod_cliente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","esp0215","MO") THEN
               CALL esp0215_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_bkp_ctr_unid_med.cod_cliente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","esp0215","EX") THEN
               CALL esp0215_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","esp0215","CO") THEN
           CALL esp0215_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL esp0215_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL esp0215_paginacao("ANTERIOR") 
     COMMAND KEY("P") "coPia"  "Copia dados de um item"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","esp0215","EX") THEN
           IF esp0215_Copia() THEN
              ERROR 'Copia efetuada com sucesso'
           ELSE
              ERROR 'Problema ocorrido durante copia'   
           END IF 
       END IF
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
  CLOSE WINDOW w_esp0215
END FUNCTION

#--------------------------------------#
 FUNCTION esp0215_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
#  CLEAR FORM
  IF  esp0215_entrada_dados("INCLUSAO") THEN
      BEGIN WORK
      LET p_bkp_ctr_unid_med.num_nff = 1
      LET p_bkp_ctr_unid_med.pre_unit_um = 0    
      INSERT INTO bkp_ctr_unid_med VALUES (p_bkp_ctr_unid_med.*)
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
 FUNCTION esp0215_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_esp0215
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_bkp_ctr_unid_med.* TO NULL
    LET p_bkp_ctr_unid_med.cod_empresa = p_cod_empresa
    DISPLAY BY NAME p_bkp_ctr_unid_med.*
  END IF
  INPUT   BY NAME p_bkp_ctr_unid_med.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_cliente 
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD cod_unid_med_cli
      END IF

    AFTER FIELD cod_cliente 
      IF p_bkp_ctr_unid_med.cod_cliente  IS NOT NULL THEN
         IF esp0215_verifica_cliente() THEN
            ERROR "Cliente nao cadastrado" 
            NEXT FIELD cod_cliente  
         ELSE 
            DISPLAY BY NAME p_clientes.nom_cliente 
         END IF
      ELSE 
         ERROR "O campo COD_CLIENTE nao pode ser nulo."
         NEXT FIELD cod_cliente  
      END IF

    AFTER FIELD cod_item
      IF p_bkp_ctr_unid_med.cod_item IS NOT NULL THEN
         IF esp0215_verifica_item() THEN
            ERROR "Item nao cadastrado" 
            NEXT FIELD cod_item 
         ELSE 
            DISPLAY BY NAME p_item.den_item
            DISPLAY BY NAME p_item.cod_unid_med
            IF esp0215_verifica_duplicidade() THEN
               ERROR "Item ja cadastrado p/ cliente" 
               NEXT FIELD cod_cliente  
            END IF
         END IF
      ELSE ERROR "O campo cod_item nao pode ser nulo."
           NEXT FIELD cod_item    
      END IF 

    AFTER FIELD cod_unid_med_cli
      IF p_bkp_ctr_unid_med.cod_unid_med_cli IS NOT NULL THEN
         IF esp0215_verifica_unidade_medida() THEN
            ERROR "Unidade de medida nao cadastrada" 
            NEXT FIELD cod_unid_med_cli
         END IF
      ELSE
         ERROR "O campo unidade de medida do cliente nao pode ser nulo."
         NEXT FIELD cod_unid_med_cli
      END IF

    AFTER FIELD fat_conver  
      IF p_bkp_ctr_unid_med.fat_conver IS NULL THEN
            ERROR "O campo fator de conversao nao pode ser nulo"         
            NEXT FIELD fat_conver
      END IF   

   ON KEY (control-z)
        CALL esp0215_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_esp0215
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION

#--------------------------#
 FUNCTION esp0215_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM

 CONSTRUCT BY NAME where_clause ON bkp_ctr_unid_med.cod_cliente,
                                   bkp_ctr_unid_med.cod_item
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_esp0215
 IF int_flag THEN
   LET int_flag = 0 
   LET p_bkp_ctr_unid_med.* = p_bkp_ctr_unid_medr.*
   CALL esp0215_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM bkp_ctr_unid_med ",
                " WHERE cod_empresa = '",p_cod_empresa,"'",
                " AND ", where_clause CLIPPED,                 
                " ORDER BY cod_cliente, cod_item "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_bkp_ctr_unid_med.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF esp0215_verifica_cliente() THEN
         LET p_clientes.nom_cliente=" NAO CADASTRADO" 
      END IF
      IF esp0215_verifica_item() THEN
         LET p_item.den_item=" NAO CADASTRADO" 
      END IF
      LET p_ies_cons = TRUE
   END IF
    CALL esp0215_exibe_dados()
    
END FUNCTION

#------------------------------#
 FUNCTION esp0215_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_bkp_ctr_unid_med.* 
  DISPLAY BY NAME p_clientes.nom_cliente 
  DISPLAY BY NAME p_item.den_item
  DISPLAY BY NAME p_item.cod_unid_med

END FUNCTION

#------------------------------------#
 FUNCTION esp0215_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_bkp_ctr_unid_medr.* = p_bkp_ctr_unid_med.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_bkp_ctr_unid_med.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_bkp_ctr_unid_med.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_bkp_ctr_unid_med.* = p_bkp_ctr_unid_medr.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_bkp_ctr_unid_med.* FROM bkp_ctr_unid_med    
        WHERE cod_cliente = p_bkp_ctr_unid_med.cod_cliente
          AND cod_item = p_bkp_ctr_unid_med.cod_item
          AND cod_empresa = p_bkp_ctr_unid_med.cod_empresa
        IF sqlca.sqlcode = 0 THEN 
           IF esp0215_verifica_cliente() THEN
              LET p_clientes.nom_cliente=" NAO CADASTRADO" 
           END IF
           IF esp0215_verifica_item() THEN
              LET p_item.den_item=" NAO CADASTRADO" 
           END IF
           CALL esp0215_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 

 
#------------------------------------#
 FUNCTION esp0215_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR FOR
   SELECT *                            
     INTO p_bkp_ctr_unid_med.*                                              
     FROM bkp_ctr_unid_med      
    WHERE cod_cliente = p_bkp_ctr_unid_med.cod_cliente
      AND cod_item = p_bkp_ctr_unid_med.cod_item
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
      OTHERWISE CALL log003_err_sql("LEITURA","bkp_ctr_unid_med")
   END CASE
   WHENEVER ERROR STOP
   RETURN FALSE

 END FUNCTION

#----------------------------------#
 FUNCTION esp0215_modificacao()
#----------------------------------#
   IF esp0215_cursor_for_update() THEN
      LET p_bkp_ctr_unid_medr.* = p_bkp_ctr_unid_med.*
      IF esp0215_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE bkp_ctr_unid_med SET cod_unid_med_cli = p_bkp_ctr_unid_med.cod_unid_med_cli,
                                     fat_conver  = p_bkp_ctr_unid_med.fat_conver
         WHERE CURRENT OF cm_padrao
         IF sqlca.sqlcode = 0 THEN
            COMMIT WORK
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TABELA")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso, Modifica todos da mesma raiz???" ATTRIBUTE(REVERSE)
               IF log004_confirm(2,3) THEN 
                  CALL esp0215_modificacao_ger()
               END IF   
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TABELA")
            ROLLBACK WORK
         END IF
      ELSE
         LET p_bkp_ctr_unid_med.* = p_bkp_ctr_unid_medr.*
         ERROR "Modificacao Cancelada"
         ROLLBACK WORK
         DISPLAY BY NAME p_bkp_ctr_unid_med.cod_cliente 
         DISPLAY BY NAME p_clientes.nom_cliente                
         DISPLAY BY NAME p_bkp_ctr_unid_med.cod_item
         DISPLAY BY NAME p_item.den_item               
         DISPLAY BY NAME p_item.cod_unid_med
         DISPLAY BY NAME p_bkp_ctr_unid_med.cod_unid_med_cli
         DISPLAY BY NAME p_bkp_ctr_unid_med.fat_conver
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION


#----------------------------------#
 FUNCTION esp0215_modificacao_ger()
#----------------------------------#
 DEFINE l_raiz   CHAR(12)
 
 BEGIN WORK
 
 LET l_raiz = p_bkp_ctr_unid_med.cod_cliente[1,9]
 LET l_raiz = l_raiz CLIPPED,'%'
 
 UPDATE bkp_ctr_unid_med SET cod_unid_med_cli = p_bkp_ctr_unid_med.cod_unid_med_cli,
                             fat_conver  = p_bkp_ctr_unid_med.fat_conver
  WHERE cod_cliente LIKE l_raiz
    AND cod_item = p_bkp_ctr_unid_med.cod_item
 IF SQLCA.sqlcode = 0 THEN
    MESSAGE "Todos registros, ",l_raiz," foram alterados"
    COMMIT WORK
 ELSE
    MESSAGE "Problema na alteracao dos registros, ",l_raiz," ",SQLCA.sqlcode
    ROLLBACK WORK 
 END IF  

END FUNCTION

#----------------------------------------#
 FUNCTION esp0215_exclusao()
#----------------------------------------#
   IF esp0215_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM bkp_ctr_unid_med    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             COMMIT WORK
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_bkp_ctr_unid_med.* TO NULL
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
 END FUNCTION  

#------------------------------------#
 FUNCTION esp0215_verifica_cliente()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT nom_cliente
  INTO p_clientes.nom_cliente
  FROM clientes               
 WHERE cod_cliente  = p_bkp_ctr_unid_med.cod_cliente

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#--------------------------------#
 FUNCTION esp0215_verifica_item()
#--------------------------------#
DEFINE p_cont      SMALLINT

SELECT den_item,
       cod_unid_med
  INTO p_item.den_item,
       p_item.cod_unid_med
  FROM item
 WHERE cod_item = p_bkp_ctr_unid_med.cod_item
   AND cod_empresa = p_cod_empresa

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#-----------------------------------------#
 FUNCTION esp0215_verifica_unidade_medida()
#-----------------------------------------#
DEFINE p_cont      SMALLINT

LET p_cont = 0

SELECT COUNT(*) 
  INTO p_cont
  FROM unid_med
 WHERE cod_unid_med = p_bkp_ctr_unid_med.cod_unid_med_cli

IF p_cont > 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 


#------------------------------------#
 FUNCTION esp0215_verifica_duplicidade()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT COUNT(*) 
  INTO p_cont
  FROM bkp_ctr_unid_med
 WHERE cod_cliente  = p_bkp_ctr_unid_med.cod_cliente
   AND cod_item = p_bkp_ctr_unid_med.cod_item 

IF p_cont > 0 THEN
   RETURN TRUE
ELSE
   RETURN FALSE
END IF

END FUNCTION   

#-------------------------#
 FUNCTION esp0215_popup()
#-------------------------#
  DEFINE p_cod_item       LIKE item.cod_item,
         p_cod_cliente    LIKE clientes.cod_cliente,
         p_cod_unid_med   LIKE unid_med.cod_unid_med,
         l_i              INTEGER
  
  CASE
    WHEN infield(cod_unid_med_cli)
         CALL log009_popup(6,25,"UNID. MEDIDA","unid_med",
                          "cod_uni_med","den_unid_med_30",
                          "man1170","N","") RETURNING p_cod_unid_med
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_esp0215 
         IF   p_cod_unid_med IS NOT NULL OR
              p_cod_unid_med <> " " THEN  
              LET p_bkp_ctr_unid_med.cod_unid_med_cli  = p_cod_unid_med  
              DISPLAY BY NAME p_bkp_ctr_unid_med.cod_item
         END IF
    WHEN infield(cod_cliente)
         LET  p_cod_cliente = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_esp0215   
         IF p_cod_cliente IS NOT NULL THEN 
            LET p_bkp_ctr_unid_med.cod_cliente = p_cod_cliente
            DISPLAY BY NAME p_bkp_ctr_unid_med.cod_cliente
         END IF
    WHEN infield(cod_item)
         LET p_cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_esp0215
         IF p_cod_item IS NOT NULL THEN 
            LET p_bkp_ctr_unid_med.cod_item = p_cod_item
            DISPLAY BY NAME p_bkp_ctr_unid_med.cod_item
         END IF
    WHEN infield(cod_copia)
         LET p_cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_esp02151
         IF p_cod_item IS NOT NULL THEN 
            LET p_cod_copia = p_cod_item
            DISPLAY  p_cod_copia TO cod_copia
         END IF
    WHEN infield(cod_novo)
         LET p_cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_esp02151
         IF p_cod_item IS NOT NULL THEN 
            LET p_cod_novo = p_cod_item
            DISPLAY  p_cod_novo TO cod_novo
         END IF
    WHEN infield(cod_unid_novo)
         CALL log009_popup(6,25,"UNID. MEDIDA","unid_med",
                          "cod_uni_med","den_unid_med_30",
                          "man1170","N","") RETURNING p_cod_unid_med
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_esp02151 
         IF   p_cod_unid_med IS NOT NULL OR
              p_cod_unid_med <> " " THEN  
              LET p_cod_unid_novo  = p_cod_unid_med  
              DISPLAY p_cod_unid_novo TO cod_unid_novo
         END IF
    WHEN infield(cod_cli_novo)
         LET  p_cod_cliente = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_esp02151   
         IF p_cod_cliente IS NOT NULL THEN 
            LET p_tab_cli[pa_curr].cod_cli_novo = p_cod_cliente
            DISPLAY p_tab_cli[pa_curr].cod_cli_novo TO cod_cli_novo
         END IF
  END CASE
END FUNCTION


#------------------------#
 FUNCTION esp0215_copia()
#------------------------#

  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_tela_nom TO NULL
  CALL log130_procura_caminho("esp02151") RETURNING p_tela_nom
  LET  p_tela_nom = p_tela_nom CLIPPED 
#  LET  p_tela_nom = 'esp02151'
  OPEN WINDOW w_esp02151 AT 2,5 WITH FORM p_tela_nom 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  INPUT p_cod_copia,   
        p_cod_novo,           
        p_fat_novo,
        p_cod_unid_novo 
   FROM cod_copia,   
        cod_novo,           
        fat_novo,
        cod_unid_novo

    BEFORE FIELD cod_copia 
      IF p_bkp_ctr_unid_med.cod_item IS NOT NULL THEN 
         LET p_cod_copia = p_bkp_ctr_unid_med.cod_item
         LET p_den_copia = p_item.den_item
         LET p_fat_novo  = p_bkp_ctr_unid_med.fat_conver
         LET p_cod_unid_novo = p_bkp_ctr_unid_med.cod_unid_med_cli
         DISPLAY p_cod_copia TO cod_copia
         DISPLAY p_den_copia TO den_copia
         DISPLAY p_fat_novo TO fat_novo
         DISPLAY p_cod_unid_novo TO cod_unid_novo
      END IF

    AFTER FIELD cod_copia
      IF p_cod_copia IS NOT NULL THEN
         SELECT den_item
           INTO p_den_copia
           FROM item
          WHERE cod_item = p_cod_copia
            AND cod_empresa = p_cod_empresa
         IF SQLCA.sqlcode <> 0 THEN    
            ERROR "Item nao cadastrado tabela ITEM"
            NEXT FIELD cod_copia
         ELSE 
            DISPLAY p_den_copia TO den_copia
            LET p_count = 0 
            SELECT COUNT(*)
              INTO p_count
              FROM bkp_ctr_unid_med
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = p_cod_copia 
            IF p_count = 0 THEN
               ERROR 'ITEM NAO CADASTRADO PARA COPIA'
               NEXT FIELD cod_copia
            END IF    
         END IF
      ELSE 
         ERROR "O campo COD. ITEM nao pode ser nulo."
         NEXT FIELD cod_copia 
      END IF

    AFTER FIELD cod_novo
      IF p_cod_novo IS NOT NULL THEN
         SELECT den_item
           INTO p_den_novo
           FROM item
          WHERE cod_item = p_cod_novo
            AND cod_empresa = p_cod_empresa
         IF SQLCA.sqlcode <> 0 THEN    
            ERROR "Item nao cadastrado na tabela ITEM" 
            NEXT FIELD cod_novo
         ELSE 
            DISPLAY p_den_novo TO den_novo
            LET p_count = 0 
            SELECT COUNT(*)
              INTO p_count
              FROM bkp_ctr_unid_med
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = p_cod_novo 
            IF p_count > 0 THEN
               ERROR 'ITEM JA CADASTRADO'
               NEXT FIELD cod_copia
            END IF    
         END IF
      ELSE 
         ERROR "O campo COD. ITEM NOVO nao pode ser nulo."
         NEXT FIELD cod_copia 
      END IF

    AFTER FIELD fat_novo
      IF p_fat_novo IS NULL THEN
            ERROR "O campo fator de conversao nao pode ser nulo"         
            NEXT FIELD fat_novo
      END IF   

    AFTER FIELD cod_unid_novo
      IF p_cod_unid_novo IS NOT NULL THEN
         LET p_count = 0
         SELECT COUNT(*) 
           INTO p_count
           FROM unid_med
          WHERE cod_unid_med = p_cod_unid_novo
         IF p_count = 0 THEN 
            ERROR "unidade de medida nao cadastrada."
            NEXT FIELD cod_unid_novo
         END IF   
      ELSE
         ERROR "O campo unidade de medida do cliente nao pode ser nulo."
         NEXT FIELD cod_unid_novo
      END IF
      CALL esp0215_informa_clientes()
      IF esp0215_efetiva_copia() THEN 
         ERROR 'Copia efetuada com sucesso' 
      ELSE
         ERROR 'Problema durante copia processo cancelado' 
         SLEEP 2 
      END IF 

   ON KEY (control-z)
        CALL esp0215_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
 
 CLOSE WINDOW w_esp02151
 CURRENT WINDOW IS w_esp0215
 IF  int_flag = 0 THEN
   RETURN TRUE
 ELSE
   LET int_flag = 0
   RETURN FALSE
 END IF
END FUNCTION


#-----------------------------------#
 FUNCTION esp0215_informa_clientes()
#-----------------------------------#

   INPUT ARRAY p_tab_cli
      WITHOUT DEFAULTS FROM s_tab_cli.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
        LET pa_curr  = ARR_CURR()
        LET sc_curr  = SCR_LINE()   

     AFTER FIELD cod_cli_novo
       IF p_tab_cli[pa_curr].cod_cli_novo IS NOT NULL THEN      
          SELECT nom_cliente
            INTO p_tab_cli[pa_curr].nom_cli_novo
            FROM clientes               
           WHERE cod_cliente  = p_tab_cli[pa_curr].cod_cli_novo
          IF sqlca.sqlcode <> 0 THEN       
             ERROR 'Cliente nao cadastrado' 
             NEXT FIELD cod_cli_novo
          ELSE
             DISPLAY p_tab_cli[pa_curr].nom_cli_novo TO s_tab_cli[pa_curr].nom_cli_novo
          END IF
          LET p_count = 0 
          SELECT COUNT(*) 
            INTO p_count
            FROM bkp_ctr_unid_med
           WHERE cod_item = p_cod_copia
             AND cod_cliente = p_tab_cli[p_ind].cod_cli_novo
          IF p_count = 0 THEN 
             ERROR 'Item nao cadastrado para o Cliente' 
             NEXT FIELD cod_cli_novo
          END IF     
       END IF 

      ON KEY (control-z)
         CALL esp0215_popup()
        
   END INPUT 

END FUNCTION 

#--------------------------------#
 FUNCTION esp0215_efetiva_copia()
#--------------------------------#

 WHENEVER ANY ERROR CONTINUE
 
 IF p_tab_cli[1].cod_cli_novo IS NULL THEN 
    DECLARE cq_atg CURSOR FOR 
      SELECT * 
        FROM bkp_ctr_unid_med
       WHERE cod_item = p_cod_copia
    FOREACH cq_atg INTO pn_bkp_ctr_unid_med.*
       LET pn_bkp_ctr_unid_med.cod_item = p_cod_novo
       LET pn_bkp_ctr_unid_med.fat_conver = p_fat_novo
       LET pn_bkp_ctr_unid_med.cod_unid_med_cli = p_cod_unid_novo
       INSERT INTO bkp_ctr_unid_med VALUES (pn_bkp_ctr_unid_med.*)
       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("ERR INS1 ","bkp_ctr_unid") 
          RETURN FALSE
       END IF 
    END FOREACH
 ELSE
    FOR p_ind = 1 TO 200
      IF p_tab_cli[p_ind].cod_cli_novo IS NULL THEN
         EXIT FOR
      END IF 
      
      SELECT * 
        INTO pn_bkp_ctr_unid_med.*
        FROM bkp_ctr_unid_med
       WHERE cod_item = p_cod_copia
         AND cod_cliente = p_tab_cli[p_ind].cod_cli_novo
      IF SQLCA.sqlcode = 0 THEN 
          LET pn_bkp_ctr_unid_med.cod_item = p_cod_novo
          LET pn_bkp_ctr_unid_med.fat_conver = p_fat_novo
          LET pn_bkp_ctr_unid_med.cod_unid_med_cli = p_cod_unid_novo
          INSERT INTO bkp_ctr_unid_med VALUES (pn_bkp_ctr_unid_med.*)
          IF SQLCA.sqlcode <> 0 THEN 
             CALL log003_err_sql("ERR INS2 ","bkp_ctr_unid") 
             RETURN FALSE
          END IF 
      END IF 
    END FOR
 END IF 
 RETURN TRUE 
END FUNCTION 