#------------------------------------------------------------------------------#
# OBJETIVO: PROGRAMA PARA CANCELAR ROMANEIO                                    #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE 
         p_cod_empresa    CHAR(02),
         p_cancel         INTEGER,
         p_num_om         LIKE ordem_montag_item.num_om,     
         p_num_om_ini     LIKE ordem_montag_item.num_om,             
         p_qtd_item       LIKE ordem_montag_item.qtd_reservada,      
         p_ies_processou  SMALLINT,
         comando          CHAR(80),
         p_ind            SMALLINT,
         p_count          SMALLINT,
         p_resposta       CHAR(1),
         p_data           DATE,
         p_hora           CHAR(05),
         p_versao         CHAR(18),
         p_ordem_mest     RECORD LIKE ordem_montag_mest.*,
         p_ordem_item     RECORD LIKE ordem_montag_item.*,
         p_estvdp         RECORD LIKE estrutura_vdp.*,     
         p_om_list        RECORD LIKE om_list.*,
         p_estoque        RECORD LIKE estoque.*, 
         p_pedidos        RECORD LIKE pedidos.*, 
         p_item           RECORD LIKE item.*, 
         p_nat_operacao   RECORD LIKE nat_operacao.*,
         p_estoque_operac RECORD LIKE estoque_operac.*, 
         p_estoque_trans  RECORD LIKE estoque_trans.*, 
         p_estoque_obs    RECORD LIKE estoque_obs.*, 
         p_par_desc_oper  RECORD LIKE par_desc_oper.*, 
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
  LET p_versao = "ESP0209-10.02.01"
  CALL log0180_conecta_usuario()
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("esp0209.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b
       
  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL esp0209_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION esp0209_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("esp0209") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_esp02090 AT 5,3 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar"   "Informar parametros "
       HELP 0009
       MESSAGE ""
       LET p_num_om_ini = 0
       DISPLAY "                                "  AT  9,5
       IF log005_seguranca(p_user,"VDP","esp0209","CO") THEN
          IF esp0209_entrada_parametros() THEN
             NEXT OPTION "Processar" 
          END IF
       END IF
    COMMAND "Processar" "Processa reserva de estoque"
      HELP 001
      MESSAGE ""
      LET p_ies_situa  = 0
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","esp0209","IN") THEN
        IF log004_confirm(16,30) THEN  
         
          SELECT * INTO p_par_desc_oper.* 
            FROM par_desc_oper 
           WHERE cod_emp_ofic = p_cod_empresa

          IF esp0209_processa() THEN
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
	    CALL ESP0209_sobre()
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
  CLOSE WINDOW w_esp02090
END FUNCTION

#-----------------------------------#
FUNCTION esp0209_entrada_parametros()
#-----------------------------------#
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_esp02090

   INPUT p_num_om_ini  WITHOUT DEFAULTS
    FROM num_om_ini 
      ON KEY (control-w)
         CASE
            WHEN infield(num_om_ini)   CALL showhelp(3187)
         END CASE
   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_esp02090

   IF int_flag THEN
      LET int_flag = 0
      CLEAR FORM
      RETURN FALSE

   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------#
 FUNCTION esp0209_processa()
#-----------------------------#
   LET p_ies_processou = TRUE
   LET p_hora = TIME   
   LET p_num_om = 0
  
   DELETE FROM ordem_montag_mest   
    WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
      AND num_om  =  p_num_om_ini   

   DELETE FROM  ordem_montag_item 
    WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
        AND num_om = p_num_om_ini 

   DELETE FROM  ordem_montag_embal 
    WHERE cod_empresa = p_par_desc_oper.cod_emp_oper
        AND num_om = p_num_om_ini 

   RETURN TRUE  
END FUNCTION  
   
#-----------------------#
 FUNCTION ESP0209_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
