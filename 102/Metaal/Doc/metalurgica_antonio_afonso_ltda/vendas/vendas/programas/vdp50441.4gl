###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUIÇÃO DE PRODUTOS                     #
# PROGRAMA: vdp50441                                               #
# OBJETIVO: CONSULTA DA TABELA DE INFORMACOES COMPLEMENTARES DOS  #
#           PEDIDOS                                               #
# AUTOR...: DANIEL C. FRANCA NETO                                 #
# DATA....: 21/09/2004                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT

  DEFINE g_ies_grafico          SMALLINT
  DEFINE g_tipo_sgbd               CHAR(003)
  DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

#MODULARES
  DEFINE m_comando              CHAR(080),
         m_caminho              CHAR(150),
         m_ies_cons             SMALLINT

  DEFINE mr_vdp_parametro_item  RECORD
                                   num_sequencia   LIKE ped_itens.num_sequencia,
                                   cod_item        LIKE ped_itens.cod_item,
                                   des_parametro   LIKE vdp_ped_item_compl.parametro_texto,
                                   parametro_val   LIKE vdp_ped_item_compl.parametro_val,
                                   num_pedido      LIKE pedidos.num_pedido
                                END RECORD

  DEFINE mr_vdp_parametro_itemr RECORD
                                  num_sequencia    LIKE ped_itens.num_sequencia,
                                  sequencia_pedido LIKE vdp_ped_item_compl.sequencia_pedido,
                                  des_parametro    LIKE vdp_ped_item_compl.parametro_texto,
                                  parametro_val    LIKE vdp_ped_item_compl.parametro_val,
                                  num_pedido       LIKE pedidos.num_pedido
                                END RECORD
#END MODULARES

MAIN

     CALL log0180_conecta_usuario()

  LET p_versao = 'VDP50441-05.10.00pp' #Favor nao alterar esta linha (SUPORTE)

  WHENEVER ERROR CONTINUE
     CALL log1400_isolation()
     SET LOCK MODE TO WAIT 120
  WHENEVER ERROR STOP

  DEFER INTERRUPT

  CALL log001_acessa_usuario('VDP','LOGERP')
    RETURNING p_status, p_cod_empresa, p_user

  IF p_status = 0 THEN
     CALL vdp50441_controle()
  END IF

END MAIN

#---------------------------#
 FUNCTION vdp50441_controle()
#---------------------------#
  DEFINE l_num_sequencia  LIKE ped_itens.num_sequencia,
         l_pedido         LIKE pedidos.num_pedido


  CALL log006_exibe_teclas('01',p_versao)

  LET m_caminho = log1300_procura_caminho('vdp50441','')
  OPEN WINDOW w_vdp50441 AT 2,2 WITH FORM m_caminho
    ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  DISPLAY p_cod_empresa TO empresa

  IF arg_val(01) = ' ' THEN
     CALL log0030_mensagem("Consulte previamente um pedido.", "exclamation")
  ELSE
     LET l_pedido = arg_val(01)

     LET l_num_sequencia   = arg_val(02)

     DISPLAY l_pedido        TO pedido
     DISPLAY l_num_sequencia  TO num_sequencia

     CALL vdp50441_prepara_consulta(l_pedido,l_num_sequencia)
  END IF

  MENU 'OPCAO'

     COMMAND "Anterior"	"Exibe o registro anterior encontrado na consulta."
        HELP 006
        MESSAGE ""
        IF log005_seguranca(p_user,"VDP","vdp50441","CO") THEN
           CALL vdp50441_paginacao("ANTERIOR")
        END IF

     COMMAND "Seguinte"	"Exibe o próximo registro encontrado na consulta."
        HELP 005
        MESSAGE ""
        IF log005_seguranca(p_user,"VDP","vdp50441","CO") THEN
           CALL vdp50441_paginacao("SEGUINTE")
        END IF

     COMMAND "Primeiro"	"Exibe o primeiro registro encontrado na consulta."
        HELP 009
        MESSAGE ""
        IF log005_seguranca(p_user,"VDP","vdp50441","CO") THEN
           CALL vdp50441_paginacao("PRIMEIRO")
        END IF

     COMMAND KEY("U") "Último"	"Exibe o último registro encontrado na consulta."
        HELP 010
        MESSAGE ""
        IF log005_seguranca(p_user,"VDP","vdp50441","CO") THEN
           CALL vdp50441_paginacao("ULTIMO")
        END IF

    COMMAND KEY ('!')
      PROMPT 'Digite o comando : ' FOR m_comando
      RUN m_comando
      PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando

    COMMAND 'Fim'       'Retorna ao menu anterior.'
      HELP 008
      EXIT MENU

  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

  CLOSE WINDOW w_vdp50441

 END FUNCTION

##-----------------------------------#
# FUNCTION vdp50441_prepara_consulta(l_item)
##-----------------------------------#
# DEFINE l_item     LIKE item.cod_item,
#        l_op       LIKE vdp_parametro_item.parametro_num,
#        l_campo    LIKE vdp_parametro_item.des_parametro
#
#
#  WHENEVER ERROR CONTINUE
#    SELECT des_parametro,
#           parametro_val
#      INTO l_campo,
#           l_op
#      FROM vdp_parametro_item
#     WHERE empresa = p_cod_empresa
#       AND item = l_item
#       AND parametro = 'pct_acrescim'
#  WHENEVER ERROR STOP
#  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
#     CALL log003_err_sql("SELECT","vdp_parametro_item")
#  END IF
#
#  DISPLAY l_campo   TO campo
#  DISPLAY l_op      TO parametro
#
# END FUNCTION


#-----------------------------#
 FUNCTION vdp50441_prepara_consulta(l_pedido,l_num_sequencia)
#-----------------------------#

  DEFINE #l_item              LIKE item.cod_item,
         l_op                LIKE vdp_parametro_item.parametro_num,
         l_campo             LIKE vdp_parametro_item.des_parametro,
         l_cod_item          LIKE ped_itens.cod_item,
         l_pedido            LIKE ped_itens.num_pedido,
         l_num_sequencia     LIKE ped_itens.num_sequencia

  DEFINE sql_stmt            CHAR(1000)

  CLEAR FORM

  LET sql_stmt =  'SELECT ped_itens.num_sequencia, ',
                        '  ped_itens.cod_item,  ',
                        ' vdp_ped_item_compl.parametro_texto, ',
                        ' vdp_ped_item_compl.parametro_val, ' ,
                        ' ped_itens.num_pedido ',
                   ' FROM vdp_ped_item_compl, ped_itens',
                  ' WHERE ped_itens.cod_empresa               = "',p_cod_empresa,'"',
                    ' AND vdp_ped_item_compl.empresa          = ped_itens.cod_empresa ',
                    ' AND vdp_ped_item_compl.sequencia_pedido = ped_itens.num_sequencia ',
                    ' AND vdp_ped_item_compl.campo            = "pct_acrescim" ',
                    ' AND ped_itens.num_pedido =  vdp_ped_item_compl.pedido '


  IF l_pedido IS NOT NULL THEN
     LET sql_stmt = sql_stmt CLIPPED, ' AND ped_itens.num_pedido = ',l_pedido
  END IF

  IF l_num_sequencia IS NOT NULL THEN
     LET sql_stmt = sql_stmt CLIPPED, ' AND ped_itens.num_sequencia = ',l_num_sequencia
  END IF

  LET sql_stmt = sql_stmt CLIPPED , ' ORDER BY ped_itens.num_sequencia '

  MESSAGE "Processando a consulta..." ATTRIBUTE(REVERSE)

  LET sql_stmt = log0810_prepare_sql(sql_stmt)

  WHENEVER ERROR CONTINUE
  PREPARE var_vdp_par_item FROM sql_stmt
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     MESSAGE ""
     CALL log003_err_sql("PREPARE SQL","var_vdp_par_item")
     ERROR "Consulta cancelada."
     LET m_ies_cons = FALSE
     RETURN
  END IF

  WHENEVER ERROR CONTINUE
  DECLARE cq_vdp_par_item  SCROLL CURSOR FOR var_vdp_par_item
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     MESSAGE ""
     CALL log003_err_sql("DECLARE CURSOR","cq_vdp_par_item")
     ERROR "Consulta cancelada."
     LET m_ies_cons = FALSE
     RETURN
  END IF

  WHENEVER ERROR CONTINUE
      OPEN cq_vdp_par_item
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     MESSAGE ""
     CALL log003_err_sql("OPEN CURSOR","cq_vdp_par_item")
     ERROR "Consulta cancelada."
     LET m_ies_cons = FALSE
     RETURN
  END IF

  WHENEVER ERROR CONTINUE
  FETCH cq_vdp_par_item INTO mr_vdp_parametro_item.*
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     MESSAGE ""
     IF sqlca.sqlcode = NOTFOUND THEN
        CALL log0030_mensagem("Argumentos de pesquisa não encontrados.","exclamation")
        CLEAR FORM
        LET m_ies_cons = FALSE
     END IF
     CLOSE cq_vdp_par_item
     FREE cq_vdp_par_item
     RETURN
  ELSE
  DISPLAY mr_vdp_parametro_item.num_sequencia  TO num_sequencia
  DISPLAY mr_vdp_parametro_item.cod_item       TO cod_item
  DISPLAY mr_vdp_parametro_item.des_parametro  TO campo
  DISPLAY mr_vdp_parametro_item.parametro_val  TO parametro
  DISPLAY mr_vdp_parametro_item.num_pedido     TO pedido
  DISPLAY p_cod_empresa TO empresa

  LET m_ies_cons = TRUE
    MESSAGE "Consulta efetuada com sucesso." ATTRIBUTE(REVERSE)

  END IF

END FUNCTION

#-----------------------------------#
 FUNCTION vdp50441_paginacao(l_acao)
#-----------------------------------#

  DEFINE l_acao                   CHAR(15),
         l_msg_erro               CHAR(100)

  LET l_acao = UPSHIFT(l_acao)

   IF m_ies_cons THEN
       LET mr_vdp_parametro_itemr = mr_vdp_parametro_item
       WHILE TRUE
       CASE
         WHEN l_acao = "SEGUINTE" FETCH NEXT     cq_vdp_par_item INTO mr_vdp_parametro_item.*

         WHEN l_acao = "ANTERIOR" FETCH PREVIOUS cq_vdp_par_item INTO mr_vdp_parametro_item.*

         WHEN l_acao = "PRIMEIRO" FETCH FIRST    cq_vdp_par_item INTO mr_vdp_parametro_item.*

         WHEN l_acao = "ULTIMO"   FETCH LAST     cq_vdp_par_item INTO mr_vdp_parametro_item.*

         WHEN l_acao = "ATUAL"    FETCH CURRENT  cq_vdp_par_item INTO mr_vdp_parametro_item.*
       END CASE
       IF sqlca.sqlcode = 100 THEN
          ERROR "Não existem mais ítens nesta direção."
             LET mr_vdp_parametro_item = mr_vdp_parametro_itemr
          EXIT WHILE
       ELSE
          CLEAR FORM
       END IF

       WHENEVER ERROR CONTINUE
       SELECT UNIQUE(empresa)
         FROM vdp_parametro_item
        WHERE vdp_parametro_item.empresa = p_cod_empresa
          AND parametro = 'pct_acrescim'
       WHENEVER ERROR STOP
       IF sqlca.sqlcode = 0 THEN
         DISPLAY mr_vdp_parametro_item.num_sequencia  TO num_sequencia
         DISPLAY mr_vdp_parametro_item.cod_item       TO cod_item
         DISPLAY mr_vdp_parametro_item.des_parametro  TO campo
         DISPLAY mr_vdp_parametro_item.parametro_val  TO parametro
         DISPLAY mr_vdp_parametro_item.num_pedido     TO pedido
         DISPLAY p_cod_empresa TO empresa

         EXIT WHILE
       END IF

     END WHILE
   ELSE
       ERROR "Não existe nenhuma consulta ativa."
   END IF

   IF int_flag <> 0 THEN
      MESSAGE "Paginação cancelada " ATTRIBUTE(REVERSE)
      LET int_flag = 0
   END IF

END FUNCTION

#---------------------------------------------#
 FUNCTION vdp50441_version_info()
#---------------------------------------------#
  RETURN "$Archive: /especificos/logix10R2/metalurgica_antonio_afonso_ltda/vendas/vendas/programas/vdp50441.4gl $|$Revision: 2 $|$Date: 9/10/09 16:09 $|$Modtime: 6/10/09 15:42 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION