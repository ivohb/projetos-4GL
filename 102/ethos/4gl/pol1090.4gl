DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_release              CHAR(40),
         p_saldo                DECIMAL(10,3),
         p_erro                 CHAR(01),       
         p_qtd_variacao         DECIMAL(07,0),
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_ind                  SMALLINT,
         p_ies_cons             SMALLINT

  DEFINE p_pedidos              RECORD LIKE pedidos.*,
         p_pedido_volvo_512     RECORD LIKE pedido_volvo_512.*

  DEFINE p_tela   RECORD
         cod_empresa   CHAR(02), 
         num_pedido    LIKE pedidos.num_pedido
                 END RECORD
                 
  DEFINE p_nom_arquivo          CHAR(100),
         p_ies_impressao        CHAR(001),
         p_ok                   CHAR(001),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_prog_inex            CHAR(001),
         p_help                 CHAR(080),
         p_count_ped            INTEGER,
         p_cancel               INTEGER
  DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
  LET p_versao = "POL1090-10.02.01" 
  WHENEVER ANY ERROR CONTINUE
  CALL log0180_conecta_usuario()
  CALL log1400_isolation()
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho 
  OPTIONS
    HELP FILE p_help

  CALL log001_acessa_usuario("ESPEC999","")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN 
    CALL pol1090_controle()
  END IF
END MAIN

#----------------------------#
 FUNCTION pol1090_controle()
#----------------------------#
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol1090") RETURNING p_nom_tela 
  OPEN WINDOW w_pol1090 AT 7,11 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Processar" "Atualiza pedidos, inclui num_pedido_cli no pedido"
      HELP 0116
      MESSAGE ""
     IF pol1090_processa_atualizacao() THEN 
        CALL log085_transacao("COMMIT")
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("COMMIT","PEDIDOS")
           CALL log085_transacao("ROLLBACK")
        ELSE
           NEXT OPTION "Fim"    
        END IF
      ELSE 
        CALL log085_transacao("ROLLBACK")
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1090_sobre() 
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol1090
END FUNCTION

#-------------------------------------#
FUNCTION pol1090_processa_atualizacao()
#-------------------------------------#
   CALL log085_transacao("BEGIN")

   DISPLAY p_cod_empresa TO cod_empresa 
   
   DECLARE cp_ped CURSOR FOR
    SELECT *
      FROM pedido_volvo_512
     WHERE cod_empresa = p_cod_empresa 

   FOREACH cp_ped INTO p_pedido_volvo_512.*
     
        DISPLAY p_pedido_volvo_512.num_pedido TO num_pedido
        
        UPDATE pedidos  
           SET num_pedido_cli =   p_pedido_volvo_512.cod_item  
         WHERE cod_empresa =  p_pedido_volvo_512.cod_empresa
           AND num_pedido  =  p_pedido_volvo_512.num_pedido    
           
        IF SQLCA.sqlcode <> 0 THEN 
           CALL log003_err_sql("UPDATE","PEDIDOS")
           RETURN FALSE
        END IF    
           
   END FOREACH 
   
   RETURN TRUE 
   
END FUNCTION