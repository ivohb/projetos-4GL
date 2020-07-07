#------------------------------------------------------------------------------#
# OBJETIVO: PROGRAMA PARA CANCELAR ROMANEIO                                    #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE 
         p_cod_empresa    CHAR(02),
         p_cancel         INTEGER,
         p_num_pedido     LIKE pedidos.num_pedido,             
         p_ies_processou  SMALLINT,
         comando          CHAR(80),
         p_ind            SMALLINT,
         p_count          SMALLINT,
         p_resposta       CHAR(1),
         p_data           DATE,
         p_hora           CHAR(05),
         p_versao         CHAR(18),
         p_ped_itens      RECORD LIKE ped_itens.*, 
         p_par_desc_oper  RECORD LIKE par_desc_oper.*,
         p_ped_item_orig  RECORD LIKE ped_item_orig.*, 
         p_msg            CHAR(500)
         
 DEFINE p_user            LIKE usuario.nom_usuario,
        p_status          SMALLINT,
        p_ies_situa       SMALLINT,
        p_nom_help        CHAR(200),
        p_nom_tela        CHAR(200)
END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT 
  LET p_versao = "ESP0210-10.02.01"
  CALL log0180_conecta_usuario()
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("esp0210.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b
       
  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL esp0210_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION esp0210_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("esp0210") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_esp02100 AT 5,3 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar"   "Informar parametros "
       HELP 0009
       MESSAGE ""
       LET p_num_pedido = 0
       DISPLAY "                                "  AT  9,5
       IF log005_seguranca(p_user,"VDP","esp0210","CO") THEN
          IF esp0210_entrada_parametros() THEN
             NEXT OPTION "Processar" 
          END IF
       END IF
    COMMAND "Processar" "Processa reserva de estoque"
      HELP 001
      MESSAGE ""
      LET p_ies_situa  = 0
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","esp0210","IN") THEN
        IF log004_confirm(15,20) THEN  
         
          SELECT * INTO p_par_desc_oper.* 
            FROM par_desc_oper 
           WHERE cod_emp_ofic = p_cod_empresa

          IF esp0210_processa() THEN
             ERROR "Processamento Efetuado com Sucesso"
             NEXT OPTION "Fim"
          ELSE
             ERROR "Processamento Cancelado"
          END IF
        ELSE
          ERROR "Processamento Cancelado"          
        END IF
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	    CALL ESP0210_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim" "Sai do programa"
      IF p_ies_processou = FALSE THEN
         ERROR "Funcao deve ser processada"
         NEXT OPTION "Processar"
      ELSE
         EXIT MENU
      END IF
  END MENU
  CLOSE WINDOW w_esp02100
END FUNCTION

#-----------------------------------#
FUNCTION esp0210_entrada_parametros()
#-----------------------------------#
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_esp02100

   INPUT p_num_pedido  WITHOUT DEFAULTS
    FROM num_pedido 
      ON KEY (control-w)
         CASE
            WHEN infield(num_pedido)   CALL showhelp(3187)
         END CASE
   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_esp02100

   IF int_flag THEN
      LET int_flag = 0
      CLEAR FORM
      RETURN FALSE

   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------#
 FUNCTION esp0210_processa()
#-----------------------------#
   LET p_ies_processou = TRUE
   LET p_hora = TIME   

 DECLARE cq_pedido CURSOR FOR
   SELECT * 
     FROM ped_itens
    WHERE cod_empresa =  p_par_desc_oper.cod_emp_oper
      AND num_pedido  =  p_num_pedido
 FOREACH cq_pedido INTO p_ped_itens.*
    SELECT * 
      INTO p_ped_item_orig.*
      FROM ped_item_orig
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido    = p_ped_itens.num_pedido      
       AND cod_item      = p_ped_itens.cod_item
       AND num_sequencia = p_ped_itens.num_sequencia
       
    IF SQLCA.sqlcode <> 0 THEN 
       UPDATE ped_itens SET pre_unit = pre_unit + p_ped_itens.pre_unit 
        WHERE cod_empresa   = p_cod_empresa
          AND num_pedido    = p_ped_itens.num_pedido      
          AND cod_item      = p_ped_itens.cod_item
          AND num_sequencia = p_ped_itens.num_sequencia
    ELSE    
       UPDATE ped_itens SET pre_unit = p_ped_item_orig.pre_unit
        WHERE cod_empresa   = p_cod_empresa
          AND num_pedido    = p_ped_itens.num_pedido      
          AND cod_item      = p_ped_itens.cod_item
          AND num_sequencia = p_ped_itens.num_sequencia
    END IF       
  
 END FOREACH
  
 DELETE FROM pedidos
  WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
    AND num_pedido  =  p_num_pedido   

 DELETE FROM  ped_itens
  WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
    AND num_pedido  = p_num_pedido 

 DELETE FROM  ped_itens_bnf
  WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
    AND num_pedido  = p_num_pedido 

 DELETE FROM  ped_itens_desc
  WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
    AND num_pedido  = p_num_pedido 

 RETURN TRUE  
 
END FUNCTION  
   
#-----------------------#
 FUNCTION ESP0210_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

