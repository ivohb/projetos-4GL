##PARSER-Não remover esta linha(Framework Logix)###
#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: VDPY152                                                 #
# OBJETIVO: ESPECIFICO CLIENTE KANAFLEX                             #
# AUTOR...: SEAN PABLO ESCHENBACH                                   #
# DATA....: 14/08/2012                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_versao                 CHAR(18)#Favor não alterar esta linha (SUPORTE)

END GLOBALS

#MODULARES
  DEFINE m_envia_inf_nfe    CHAR(01)
#END MODULARES

#-------------------------------------#
 FUNCTION vdpy152_verifica_cliente()
#-------------------------------------#
  RETURN TRUE

 END FUNCTION
#-------------------------------------#
 FUNCTION vdpy152_carrega_dados(l_cod_cliente, l_nom_cliente)
#-------------------------------------#
  DEFINE l_tela             CHAR(100),
         l_nom_tela         CHAR(100),
         l_cod_cliente      LIKE par_clientes.cod_cliente,
         l_nom_cliente      LIKE clientes.nom_cliente

  WHENEVER ERROR CONTINUE
    SELECT texto_parametro
      INTO m_envia_inf_nfe
      FROM vdp_cli_parametro
     WHERE cliente = l_cod_cliente
       AND parametro = "xPednItemPe_KANAFLEX"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("select","vdp_cli_parametro")
        RETURN FALSE
     END IF
  END IF

  CALL log006_exibe_teclas("01",p_versao)

  LET l_nom_tela = 'vdpy152'
  CALL log130_procura_caminho(l_nom_tela) RETURNING l_tela
  OPEN WINDOW w_vdpy152 AT 2,2 WITH FORM l_tela
     ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  CURRENT WINDOW IS w_vdpy152

  DISPLAY m_envia_inf_nfe TO envia_inf_nfe

  MENU "Opção"
     COMMAND "Fim" "Retorna ao menu anterior."
        HELP 010
        EXIT MENU

  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdpy152

 END FUNCTION

#-----------------------------------------------------#
 FUNCTION vdpy152_inclusao(l_cod_cliente,l_nom_cliente)
#-----------------------------------------------------#
  DEFINE l_cod_cliente  LIKE par_clientes.cod_cliente,
         l_nom_cliente  LIKE clientes.nom_cliente

  IF vdpy152_entrada_dados('INCLUSAO',l_cod_cliente,l_nom_cliente) THEN
     IF m_envia_inf_nfe = "S" THEN
        WHENEVER ERROR CONTINUE
          INSERT INTO vdp_cli_parametro(cliente,
                                       parametro,
                                       des_parametro,
                                       tip_parametro,
                                       texto_parametro,
                                       val_parametro,
                                       num_parametro,
                                       dat_parametro)
                                VALUES(l_cod_cliente,
                                       'xPednItemPe_KANAFLEX',
                                       'Envia xPed e nItemPed no XML?',
                                       "S",
                                       m_envia_inf_nfe,
                                       NULL,
                                       NULL,
                                       NULL)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           IF log0030_err_sql_registro_duplicado() THEN
              CALL log0030_mensagem("Registro já cadastrado.","excl")
              RETURN FALSE
           ELSE
              CALL log003_err_sql("INSERT","vdp_cli_parametro vdpy152")
              CLOSE WINDOW w_vdpy152
              RETURN FALSE
           END IF
        END IF
     END IF

     CLOSE WINDOW w_vdpy152
     RETURN TRUE
  ELSE
     CLEAR FORM
     CLOSE WINDOW w_vdpy152
     RETURN FALSE
  END IF

 END FUNCTION

#----------------------------------------#
 FUNCTION vdpy152_entrada_dados(l_funcao,l_cod_cliente,l_nom_cliente)
#----------------------------------------#
{OBJETIVO: Utilizada para entrada de dados tanto para inclusão quanto para
           modificação de um registro da tabela principal.

 PARÂMETROS:
 1 - Função em execução.
     INCLUSAO    - A função atual trata-se de uma inclusão de registro.
     MODIFICACAO - A função atual trata-se de uma modificação de registro.

 RETORNO:
 1 - Status
     TRUE  - Entrada de dados informada com sucesso.
     FALSE - Entrada de dados cancelada.
}
  DEFINE l_funcao       CHAR(015),
         l_cod_cliente  LIKE par_clientes.cod_cliente,
         l_nom_cliente  LIKE clientes.nom_cliente,
         l_tela         CHAR(100),
         l_nom_tela     CHAR(100)

  LET l_nom_tela = 'vdpy152'
  CALL log130_procura_caminho(l_nom_tela) RETURNING l_tela
  OPEN WINDOW w_vdpy152 AT 2,2 WITH FORM l_tela
     ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_vdpy152

  LET int_flag = 0

  INPUT m_envia_inf_nfe WITHOUT DEFAULTS
   FROM envia_inf_nfe

  BEFORE FIELD envia_inf_nfe

  END INPUT

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_vdpy152

  IF int_flag THEN
     LET int_flag = FALSE
     RETURN FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#---------------------------------------------------------#
 FUNCTION vdpy152_modificacao(l_cod_cliente,l_nom_cliente)
#---------------------------------------------------------#
  DEFINE l_cod_cliente  LIKE par_clientes.cod_cliente,
         l_nom_cliente  LIKE clientes.nom_cliente

  INITIALIZE m_envia_inf_nfe TO NULL

  CALL vdpy152_carrega_imp_parametro(l_cod_cliente)

  IF vdpy152_entrada_dados('MODIFICACAO',l_cod_cliente,l_nom_cliente) THEN
     WHENEVER ERROR CONTINUE
       DELETE
         FROM vdp_cli_parametro
        WHERE cliente   = l_cod_cliente
          AND parametro = 'xPednItemPe_KANAFLEX'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("delete","vdp_cli_parametro")
        CLOSE WINDOW w_vdpy152
        RETURN FALSE
     END IF

     IF m_envia_inf_nfe = "S" THEN
        WHENEVER ERROR CONTINUE
          INSERT INTO vdp_cli_parametro(cliente,
                                       parametro,
                                       des_parametro,
                                       tip_parametro,
                                       texto_parametro,
                                       val_parametro,
                                       num_parametro,
                                       dat_parametro)
                                VALUES(l_cod_cliente,
                                       'xPednItemPe_KANAFLEX',
                                       'Envia xPed e nItemPed no XML?',
                                       "S",
                                       m_envia_inf_nfe,
                                       NULL,
                                       NULL,
                                       NULL)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           IF log0030_err_sql_registro_duplicado() THEN
              CALL log0030_mensagem("Registro já cadastrado.","excl")
              RETURN FALSE
           ELSE
              CALL log003_err_sql("INSERT","vdp_cli_parametro vdpy152")
              CLOSE WINDOW w_vdpy152
              RETURN FALSE
           END IF
        END IF
     END IF

     CLOSE WINDOW w_vdpy152
     RETURN TRUE
  ELSE
     CLOSE WINDOW w_vdpy152
     RETURN FALSE
  END IF

 END FUNCTION

#-------------------------------#
 FUNCTION vdpy152_excluir(l_cod_cliente)
#--------------------------------------#
  DEFINE l_cod_cliente LIKE par_clientes.cod_cliente

  INITIALIZE m_envia_inf_nfe TO NULL

  CALL vdpy152_carrega_imp_parametro(l_cod_cliente)

  WHENEVER ERROR CONTINUE
    DELETE FROM vdp_cli_parametro
     WHERE cliente   = l_cod_cliente
       AND parametro = 'xPednItemPe_KANAFLEX'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("SELECT","VDP_CLI_PARAMETRO(xpednitemped_FAGOR)")
  END IF

  CLEAR FORM
  INITIALIZE m_envia_inf_nfe TO NULL

 END FUNCTION

#----------------------------------------------------#
 FUNCTION vdpy152_carrega_imp_parametro(l_cod_cliente)
#----------------------------------------------------#
  DEFINE l_cod_cliente LIKE par_clientes.cod_cliente

  WHENEVER ERROR CONTINUE
    SELECT texto_parametro
      INTO m_envia_inf_nfe
      FROM vdp_cli_parametro
     WHERE cliente   = l_cod_cliente
       AND parametro = 'xPednItemPe_KANAFLEX'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("SELECT","VDP_CLI_PARAMETRO")
  END IF

 END FUNCTION

#-------------------------------#
 FUNCTION vdpy152_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdpy152.4gl $|$Revision: 1 $|$Date: 24/08/12 16:23 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION
