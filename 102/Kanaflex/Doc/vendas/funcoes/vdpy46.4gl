#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDPY46                                                #
# OBJETIVO: MANUTENCAO DO CAMPO LINHA DE PRODUTO (PED_INFO_COMPL) #
# AUTOR...: EDUARDO LUIS PRIM                                     #
# DATA....: 05/10/2006                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
    DEFINE p_status           SMALLINT,
           where_clause       CHAR(500),
           sql_stmt           CHAR(500),
           p_user             LIKE usuario.nom_usuario

    DEFINE p_comando          CHAR(80),
           p_cod_empresa           LIKE empresa.cod_empresa,
           p_caminho          CHAR(80),
           p_nom_tela         CHAR(80),
           p_help             CHAR(80),
           p_cancel           INTEGER
END GLOBALS

    DEFINE m_versao_funcao    CHAR(18), # -- Favor nao apagar esta linha (SUPORTE)
           m_consulta_ativa   SMALLINT

    DEFINE mr_tela            RECORD
                                  pedido           LIKE pedidos.num_pedido,
                                  linha_produto    LIKE ped_info_compl.parametro_texto
                              END RECORD

    DEFINE mr_telar           RECORD
                                  pedido           LIKE pedidos.num_pedido,
                                  linha_produto    LIKE ped_info_compl.parametro_texto
                              END RECORD


#-------------------------------------------#
 FUNCTION vdpy46_exibe_opcao_linha_produto()
#-------------------------------------------#
     RETURN TRUE

 END FUNCTION

#---------------------------------------#
 FUNCTION vdpy46_controle(l_num_pedido)
#---------------------------------------#
     DEFINE l_num_pedido         LIKE pedidos.num_pedido

     INITIALIZE mr_tela.*,
                mr_telar.*,
                m_consulta_ativa TO NULL

     LET mr_tela.pedido   = l_num_pedido
     LET m_versao_funcao  = "VDPY46-10.02.00e"

     CALL log140_procura_caminho("VDPY46.iem") RETURNING p_caminho
     LET p_help = p_caminho CLIPPED

     OPTIONS
       HELP    FILE p_help,
       NEXT     KEY control-f,
       PREVIOUS KEY control-b

     CALL log006_exibe_teclas("02 08 09", m_versao_funcao)

     CALL log130_procura_caminho("vdpy46") RETURNING p_nom_tela

     OPEN WINDOW w_vdpy46 AT 2,2 WITH FORM p_nom_tela
          ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

     CALL log0010_close_window_screen()

     WHENEVER ERROR CONTINUE
       SELECT parametro_texto
         INTO mr_tela.linha_produto
         FROM ped_info_compl
        WHERE empresa = p_cod_empresa
          AND pedido  = mr_tela.pedido
          AND campo   = 'linha_produto'
     WHENEVER ERROR STOP

     IF  SQLCA.sqlcode <> 0 THEN
     END IF


     DISPLAY p_cod_empresa   TO empresa
     DISPLAY BY NAME mr_tela.*

     MENU "OPCAO"

       COMMAND "Incluir" "Inclui registro de linha de produto"
         HELP  001
         MESSAGE ""
         IF  log005_seguranca(p_user,"VDP","vdpy46","IN") THEN
             CALL vdpy46_inclusao_ped_info_compl()
         ELSE
             CALL log0030_mensagem("Usuário não autorizado para fazer inclusão. ","exclamation")
         END IF

       COMMAND "Modificar" "Modifica registro de linha de produto"
         HELP 002
         MESSAGE ""
         IF  log005_seguranca(p_user,"VDP","vdpy46","MO") THEN
             IF  mr_tela.pedido IS NOT NULL AND
                 mr_tela.pedido <> ' '      THEN
                 CALL vdpy46_modificacao_ped_info_compl()
             ELSE
                 CALL log0030_mensagem("Não existe consulta ativa. ","exclamation")
             END IF
         ELSE
             CALL log0030_mensagem("Usuário não autorizado para fazer modificação. ","exclamation")
         END IF

       COMMAND "Consultar"    "Consulta registro de linha de produto"
         HELP 004
         MESSAGE ""
         IF  log005_seguranca(p_user,"VDP","vdpy46","CO") THEN
             CALL vdpy46_consulta_ped_info_compl()
         END IF

       COMMAND "Seguinte"   "Exibe registro de linha de produto seguinte "
         HELP 005
         MESSAGE ""
         CALL vdpy46_paginacao("SEGUINTE")

       COMMAND "Anterior"   "Exibe registro de linha de produto Anterior "
         HELP 006
         MESSAGE ""
         CALL vdpy46_paginacao("ANTERIOR")

       COMMAND "Fim"        "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
     END MENU

     WHENEVER ANY ERROR CONTINUE
        CLOSE WINDOW w_vdpy46
     WHENEVER ANY ERROR STOP

 END FUNCTION

#------------------------------------------#
 FUNCTION vdpy46_inclusao_ped_info_compl()
#------------------------------------------#
     LET mr_telar.* = mr_tela.*

     DISPLAY p_cod_empresa   TO empresa
     DISPLAY BY NAME mr_tela.*

     IF  vdpy46_entrada_dados('INCLUSAO') THEN

         WHENEVER ERROR CONTINUE
           INSERT INTO ped_info_compl (empresa,
                                       pedido,
                                       campo,
                                       parametro_texto)
                               VALUES (p_cod_empresa,
                                       mr_tela.pedido,
                                       'linha_produto',
                                       mr_tela.linha_produto)
         WHENEVER ERROR STOP
         IF  SQLCA.sqlcode = 0 THEN
             CALL log0030_mensagem("Inclusão efetuada com sucesso. ","exclamation")
         ELSE
             CALL log003_err_sql("INCLUSÃO","PED_INFO_COMPL")
         END IF
     ELSE
         LET mr_tela.* = mr_telar.*
         CALL vdpy46_exibe_dados()
         CALL log0030_mensagem("Inclusão cancelada. ","exclamation")
     END IF

 END FUNCTION

#---------------------------------------------#
 FUNCTION vdpy46_modificacao_ped_info_compl()
#---------------------------------------------#
     LET mr_telar.* = mr_tela.*

     IF  vdpy46_entrada_dados('MODIFICACAO') THEN

         WHENEVER ERROR CONTINUE
           SELECT 1
             FROM ped_info_compl
            WHERE empresa = p_cod_empresa
              AND pedido  = mr_tela.pedido
              AND campo   = 'linha_produto'
         WHENEVER ERROR STOP

         IF  SQLCA.sqlcode = 0 THEN
             WHENEVER ERROR CONTINUE
               UPDATE ped_info_compl
                  SET parametro_texto = mr_tela.linha_produto
                WHERE empresa = p_cod_empresa
                  AND pedido  = mr_tela.pedido
                  AND campo   = 'linha_produto'
             WHENEVER ERROR STOP

             IF  SQLCA.sqlcode = 0 THEN
                 CALL log0030_mensagem("Modificação efetuada com sucesso. ","exclamation")
             ELSE
                 CALL log003_err_sql("MODIFICAÇÃO","PED_INFO_COMPL")
             END IF
         ELSE
             WHENEVER ERROR CONTINUE
               INSERT INTO ped_info_compl (empresa,
                                           pedido,
                                           campo,
                                           parametro_texto)
                                   VALUES (p_cod_empresa,
                                           mr_tela.pedido,
                                           'linha_produto',
                                           mr_tela.linha_produto)
             WHENEVER ERROR STOP
             IF  SQLCA.sqlcode = 0 THEN
                 CALL log0030_mensagem("Modificação efetuada com sucesso. ","exclamation")
             ELSE
                 CALL log003_err_sql("MODIFICAÇÃO","PED_INFO_COMPL")
             END IF
         END IF
     ELSE
         LET mr_tela.* = mr_telar.*
         CALL vdpy46_exibe_dados()
         CALL log0030_mensagem("Modificação cancelada. ","exclamation")
     END IF

 END FUNCTION

#----------------------------------------#
 FUNCTION vdpy46_entrada_dados(l_funcao)
#----------------------------------------#
     DEFINE l_funcao         CHAR(011)

     CALL log006_exibe_teclas("01 02 03 07",m_versao_funcao)
     CURRENT WINDOW IS w_vdpy46

     INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

         BEFORE INPUT
            IF  l_funcao = 'MODIFICACAO' THEN
                NEXT FIELD linha_produto
            END IF

         AFTER FIELD pedido
            IF  mr_tela.pedido IS NULL OR
                mr_tela.pedido = ' '   THEN
                ERROR 'Informe o numero do pedido.'
                NEXT FIELD pedido
            END IF

         AFTER FIELD linha_produto
            IF  mr_tela.linha_produto IS NULL OR
                mr_tela.linha_produto = ' '   THEN
                ERROR 'Informe a linha do produto.'
                NEXT FIELD linha_produto
            END IF

         ON KEY ('control-w', f1)
                CALL vdpy46_help()

         AFTER INPUT
            IF  NOT INT_FLAG THEN
                IF  mr_tela.pedido IS NULL OR
                    mr_tela.pedido = ' '   THEN
                    ERROR 'Informe o numero do pedido.'
                    NEXT FIELD pedido
                END IF

                IF  mr_tela.linha_produto IS NULL OR
                    mr_tela.linha_produto = ' '   THEN
                    ERROR 'Informe a linha do produto.'
                    NEXT FIELD linha_produto
                END IF
            END IF

     END INPUT

     CALL log006_exibe_teclas("01",m_versao_funcao)
     CURRENT WINDOW IS w_vdpy46

     IF  NOT INT_FLAG THEN
         RETURN TRUE
     ELSE
         LET INT_FLAG = FALSE
         RETURN FALSE
     END IF

 END FUNCTION

#------------------------------------------#
 FUNCTION vdpy46_consulta_ped_info_compl()
#------------------------------------------#
     DISPLAY p_cod_empresa  TO empresa

     LET mr_telar.*         = mr_tela.*
     INITIALIZE mr_tela.*   TO NULL
     CLEAR FORM

     CONSTRUCT where_clause ON pedido, parametro_texto
                          FROM pedido, linha_produto
     IF  INT_FLAG THEN
         LET INT_FLAG = FALSE
         LET mr_tela.* = mr_telar.*
         CALL vdpy46_exibe_dados()
         CALL log0030_mensagem(" Consulta cancelada. ","excl")
         RETURN
     END IF

     LET sql_stmt = ' SELECT pedido, parametro_texto ',
                      ' FROM  ped_info_compl ',
                     ' WHERE ', where_clause CLIPPED,
                       " AND empresa = '", p_cod_empresa,"'",
                       " AND campo   = 'linha_produto'"

     WHENEVER ERROR CONTINUE
      PREPARE var_query FROM sql_stmt
     WHENEVER ERROR STOP
     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql('PREPARE','VAR_QUERY')
     END IF

     WHENEVER ERROR CONTINUE
      DECLARE cq_linha_produto SCROLL CURSOR WITH HOLD FOR var_query
     WHENEVER ERROR STOP
     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql('DECLARE','CQ_LINHA_PRODUTO')
     END IF

     WHENEVER ERROR CONTINUE
         OPEN cq_linha_produto
     WHENEVER ERROR STOP
     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql('OPEN','CQ_LINHA_PRODUTO')
     END IF

     WHENEVER ERROR CONTINUE
        FETCH cq_linha_produto INTO mr_tela.pedido, mr_tela.linha_produto
     WHENEVER ERROR STOP

     CASE sqlca.sqlcode
          WHEN 0
               LET m_consulta_ativa = TRUE

          WHEN 100
               CALL log0030_mensagem(" Argumentos de pesquisa não encontrados. ","excl")
               LET m_consulta_ativa = FALSE

          OTHERWISE
               CALL log003_err_sql('FETCH','CQ_LINHA_PRODUTO')
               RETURN
     END CASE

     CALL vdpy46_exibe_dados()

 END FUNCTION

#------------------------------------#
 FUNCTION vdpy46_paginacao(l_funcao)
#------------------------------------#
     DEFINE l_funcao            CHAR(20)

     IF  m_consulta_ativa  THEN
         LET mr_telar.* = mr_tela.*

         WHILE TRUE
             CASE
                 WHEN l_funcao = "SEGUINTE"
                      WHENEVER ERROR CONTINUE
                         FETCH NEXT     cq_linha_produto INTO mr_tela.*
                      WHENEVER ERROR STOP

                 WHEN l_funcao = "ANTERIOR"
                      WHENEVER ERROR CONTINUE
                         FETCH PREVIOUS cq_linha_produto INTO mr_tela.*
                      WHENEVER ERROR STOP
             END CASE

             IF sqlca.sqlcode = NOTFOUND  THEN
                ERROR " Não existem mais registros nesta direção."

                LET mr_tela.* = mr_telar.*
                EXIT WHILE
             END IF

             WHENEVER ERROR CONTINUE
               SELECT pedido, parametro_texto
                 INTO mr_tela.pedido,
                      mr_tela.linha_produto
                 FROM ped_info_compl
                WHERE empresa         = p_cod_empresa
                  AND pedido          = mr_tela.pedido
                  AND parametro_texto = mr_tela.linha_produto
                  AND campo           = 'linha_produto'
             WHENEVER ERROR STOP

             IF  SQLCA.sqlcode = 0 THEN
                 EXIT WHILE
             END IF
         END WHILE

         CALL vdpy46_exibe_dados()
     ELSE
         ERROR " Não existe nenhuma consulta ativa."
     END IF

 END FUNCTION

#------------------------------#
 FUNCTION vdpy46_exibe_dados()
#------------------------------#
     DISPLAY p_cod_empresa TO empresa
     DISPLAY BY NAME mr_tela.*

 END FUNCTION

#----------------------#
 FUNCTION vdpy46_help()
#----------------------#
    CASE
       WHEN INFIELD(pedido)           CALL SHOWHELP(101)
       WHEN INFIELD(linha_produto)  CALL SHOWHELP(102)
    END CASE

END FUNCTION
#-------------------------------#
 FUNCTION vdpy46_version_info()
#-------------------------------#

 RETURN "$Archive: /especificos/logix10R2/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdpy46.4gl $|$Revision: 2 $|$Date: 2/06/11 15:08 $|$Modtime: 31/05/11 11:08 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION