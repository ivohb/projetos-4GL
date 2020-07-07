#-------------------------------------------------------------------#
# SISTEMA.: PLANEJAMENTO                                            #
# PROGRAMA: POL0215                                                 #
# MODULOS.: POL0215 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DE CONSIGNATARIO                             #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_num_pedido        LIKE pedidos.num_pedido,  
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(17),
         p_nom_arquivo       CHAR(100),
         p_nom_tel           CHAR(200),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT,
         p_msg               CHAR(100)

  DEFINE p_tela    RECORD
                     num_om           LIKE ordem_montag_mest.num_om,
                     cod_cliente      LIKE clientes.cod_cliente,
                     nom_cliente      LIKE clientes.nom_cliente,
                     cod_consig       LIKE clientes.cod_cliente,
                     nom_consig       LIKE clientes.nom_cliente,
                     cod_transp       LIKE clientes.cod_cliente,
                     nom_transp       LIKE clientes.nom_cliente
                   END RECORD

  DEFINE p_clientes          RECORD LIKE clientes.*,        
         p_om                RECORD LIKE ordem_montag_mest.*,
         p_pedidos           RECORD LIKE pedidos.*             
END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "pol0215-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0215.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0215_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0215_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tel TO NULL
  CALL log130_procura_caminho("POL0215") RETURNING p_nom_tel
  LET  p_nom_tel = p_nom_tel CLIPPED 
  OPEN WINDOW w_pol0215 AT 2,5 WITH FORM p_nom_tel 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE "" 
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0215","CO") THEN
           CALL pol0215_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Modificar"
           END IF
       END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_tela.nom_cliente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0215","MO") THEN
               CALL pol0215_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL esp0215_sobre() 
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
  CLOSE WINDOW w_pol0215
END FUNCTION

#-----------------------#
FUNCTION esp0215_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------------------#
 FUNCTION pol0215_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0215
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_tela.* TO NULL
    DISPLAY BY NAME p_tela.*
  END IF
  INPUT BY NAME p_tela.* WITHOUT DEFAULTS  

    BEFORE FIELD num_om      
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD cod_consig  
      END IF

    AFTER FIELD num_om       
      IF p_tela.num_om  IS NOT NULL THEN 
         IF pol0215_verifica_om() THEN
            ERROR "PRE-NOTA NAO CADASTRADA" 
            NEXT FIELD num_om
         END IF        
      ELSE 
         ERROR "PRE-NOTA INVALIDA" 
         NEXT FIELD num_om       
      END IF

    AFTER FIELD cod_consig  
      IF p_funcao = "MODIFICACAO" THEN 
         IF p_tela.cod_consig IS NOT NULL THEN
            IF pol0215_verifica_consig() THEN
               ERROR "TRANSPORTADORA NAO CADASTRADA"
               NEXT FIELD cod_consig   
            ELSE 
               LET p_tela.nom_consig  = p_clientes.nom_cliente 
               DISPLAY p_tela.nom_consig TO nom_consig  
            END IF
         END IF 
      END IF 

    AFTER FIELD cod_transp  
      IF p_funcao = "MODIFICACAO" THEN 
         IF p_tela.cod_transp IS NOT NULL THEN
            IF pol0215_verifica_transp() THEN
               ERROR "TRANSPORTADORA NAO CADASTRADA"
               NEXT FIELD cod_transp   
            ELSE 
               LET p_tela.nom_transp  = p_clientes.nom_cliente 
               DISPLAY p_tela.nom_transp TO nom_transp  
            END IF
         END IF 
      END IF 

   ON KEY (control-z)
        CALL pol0215_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0215
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol0215_consulta()
#--------------------------#
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0215
 IF int_flag THEN
   LET int_flag = 0 
   CALL pol0215_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 INITIALIZE p_tela.* TO NULL
 IF pol0215_entrada_dados("CONSULTA") THEN
    SELECT * 
      INTO p_om.*         
      FROM ordem_montag_mest
     WHERE num_om = p_tela.num_om              
       AND cod_empresa = p_cod_empresa 

  IF sqlca.sqlcode = NOTFOUND THEN
     ERROR "Argumentos de Pesquisa nao encontrados"
     LET p_ies_cons = FALSE
  ELSE 
     IF p_om.cod_transpor IS NOT NULL THEN
        LET p_tela.cod_transp = p_om.cod_transpor
        SELECT nom_cliente 
          INTO p_tela.nom_transp
          FROM clientes
         WHERE cod_cliente = p_om.cod_transpor
     END IF

     DECLARE cm_pedido CURSOR WITH HOLD FOR
     SELECT unique num_pedido 
     FROM ordem_montag_item
     WHERE cod_empresa = p_cod_empresa 
       AND num_om = p_tela.num_om 

     FOREACH cm_pedido INTO p_num_pedido
        IF p_num_pedido IS NOT NULL THEN
           EXIT FOREACH
        END IF         
     END FOREACH

     SELECT *      
       INTO p_pedidos.*
       FROM pedidos 
      WHERE cod_empresa = p_cod_empresa 
        AND num_pedido = p_num_pedido
 
     SELECT nom_cliente 
       INTO p_tela.nom_cliente
       FROM clientes
      WHERE cod_cliente = p_pedidos.cod_cliente

     SELECT nom_cliente 
       INTO p_tela.nom_consig 
       FROM clientes
      WHERE cod_cliente = p_pedidos.cod_consig   

     LET p_tela.cod_cliente = p_pedidos.cod_cliente 
     LET p_tela.cod_consig  = p_pedidos.cod_consig  
    
     LET p_ies_cons = TRUE
  END IF
 END IF
 CALL pol0215_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0215_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_tela.*         

END FUNCTION

#------------------------------------#
 FUNCTION pol0215_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     INTO p_om.*                                                        
     FROM ordem_montag_mest 
    WHERE num_om  = p_tela.num_om               
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
 FUNCTION pol0215_modificacao()
#----------------------------------#
  DEFINE  p_num_ped         LIKE pedidos.num_pedido 
 
   IF pol0215_cursor_for_update() THEN
      IF pol0215_entrada_dados("MODIFICACAO") THEN
         CALL pol0215_exibe_dados()
        IF log004_confirm(09,05) THEN  
         WHENEVER ERROR CONTINUE
         UPDATE ordem_montag_mest SET cod_transpor = p_tela.cod_transp       
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
        END IF
        IF p_tela.cod_consig IS NOT NULL THEN 

           DECLARE cm_ped CURSOR WITH HOLD FOR
            SELECT unique num_pedido 
              FROM ordem_montag_item
             WHERE cod_empresa = p_cod_empresa 
               AND num_om = p_tela.num_om 

           FOREACH cm_ped INTO p_num_ped
              UPDATE pedidos SET cod_consig = p_tela.cod_consig WHERE 
                     cod_empresa = p_cod_empresa and num_pedido = p_num_ped
           END FOREACH 
        END IF
      ELSE
         ERROR "Modificacao Cancelada"
         ROLLBACK WORK
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0215_verifica_om()
#-----------------------------#

SELECT ordem_montag_mest.* 
  INTO p_om.*                             
  FROM ordem_montag_mest               
 WHERE num_om = p_tela.num_om       

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#-----------------------#
 FUNCTION pol0215_popup()
#-----------------------#
  DEFINE p_cod_transp         LIKE clientes.cod_cliente,     
         p_cod_consig         LIKE clientes.cod_consig       
  
  CASE 

    WHEN infield(cod_transp)
         LET p_cod_transp  = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0215
         IF p_cod_transp  IS NOT NULL
         THEN  LET p_tela.cod_transp  = p_cod_transp 
               DISPLAY p_tela.cod_transp TO cod_transp 
         END IF
    WHEN infield(cod_consig)
         LET  p_cod_consig = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0215
         IF p_cod_consig  IS NOT NULL
         THEN  LET p_tela.cod_consig  = p_cod_consig  
               DISPLAY p_tela.cod_consig TO cod_consig  
         END IF
  END CASE
END FUNCTION

#----------------------------------#
 FUNCTION pol0215_verifica_consig()
#----------------------------------# 
 
SELECT *                   
  INTO p_clientes.*                       
  FROM clientes                        
 WHERE cod_cliente = p_tela.cod_consig

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol0215_verifica_transp()
#----------------------------------# 
 
SELECT *                   
  INTO p_clientes.*                       
  FROM clientes                        
 WHERE cod_cliente = p_tela.cod_transp

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION
