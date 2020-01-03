#-----------------------------------------------------------------#
# SISTEMA.: CDV - CONTROLE DE VIAGENS                             #
# PROGRAMA: CDV2007                                               #
# OBJETIVO: CONSULTA DA AUDITORIA DO SISTEMA                      #
# AUTOR...: FABIANO PEDRO ESPINDOLA                               #
# DATA....: 13.07.2005                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
    DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
           p_user                 LIKE usuario.nom_usuario,
           p_status               SMALLINT

    DEFINE p_ies_impressao        CHAR(001),
           g_ies_ambiente         CHAR(001),
           p_nom_arquivo          CHAR(100)

    DEFINE g_ies_grafico          SMALLINT

    DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

#MODULARES
    DEFINE m_den_empresa          LIKE empresa.den_empresa
    DEFINE m_consulta_ativa       SMALLINT

    DEFINE sql_stmt               CHAR(800),
           m_last_row             SMALLINT,
           where_clause           CHAR(400)

    DEFINE m_comando              CHAR(080)

    DEFINE m_caminho              CHAR(150)

    DEFINE m_caminho_help         CHAR(150)

    DEFINE m_txt_processamento    LIKE cdv_auditoria_781.txt_processamento

    DEFINE mr_cdv_auditoria_781       RECORD
                                      usuario          LIKE cdv_auditoria_781.usuario,
                                      nom_usuario      LIKE usuarios.nom_funcionario,
                                      programa         LIKE cdv_auditoria_781.programa,
                                      tip_manut        LIKE cdv_auditoria_781.tip_manut,
                                      des_tip_manut    CHAR(13),
                                      dat_manut        LIKE cdv_auditoria_781.dat_manut,
                                      hor_manut        LIKE cdv_auditoria_781.hor_manut,
                                      nom_tabela       LIKE cdv_auditoria_781.nom_tabela,
                                      nom_campo        LIKE cdv_auditoria_781.nom_campo,
                                      val_ant          LIKE cdv_auditoria_781.val_ant,
                                      val_atual        LIKE cdv_auditoria_781.val_atual,
                                      chave_registro   LIKE cdv_auditoria_781.chave_registro
                                  END RECORD,
           mr_cdv_auditoria_781r      RECORD
                                      usuario          LIKE cdv_auditoria_781.usuario,
                                      nom_usuario      LIKE usuarios.nom_funcionario,
                                      programa         LIKE cdv_auditoria_781.programa,
                                      tip_manut        LIKE cdv_auditoria_781.tip_manut,
                                      des_tip_manut    CHAR(13),
                                      dat_manut        LIKE cdv_auditoria_781.dat_manut,
                                      hor_manut        LIKE cdv_auditoria_781.hor_manut,
                                      nom_tabela       LIKE cdv_auditoria_781.nom_tabela,
                                      nom_campo        LIKE cdv_auditoria_781.nom_campo,
                                      val_ant          LIKE cdv_auditoria_781.val_ant,
                                      val_atual        LIKE cdv_auditoria_781.val_atual,
                                      chave_registro   LIKE cdv_auditoria_781.chave_registro
                                  END RECORD

#END MODULARES

MAIN
    CALL log0180_conecta_usuario()

    LET p_versao = 'CDV2007-05.00.00p' #Favor nao alterar esta linha (SUPORTE)

    WHENEVER ANY ERROR CONTINUE
    CALL log1400_isolation()
    SET LOCK MODE TO WAIT 120
    WHENEVER ANY ERROR STOP

    DEFER INTERRUPT

    LET m_caminho_help = log140_procura_caminho('cdv2007.iem')

    OPTIONS
        PREVIOUS KEY control-b,
        NEXT     KEY control-f,
        HELP     FILE m_caminho_help

    CALL log001_acessa_usuario('CDV','LOGERP')
         RETURNING p_status, p_cod_empresa, p_user

    IF  p_status = 0 THEN
        CALL cdv2007_controle()
    END IF

END MAIN

#---------------------------#
FUNCTION cdv2007_controle()
#---------------------------#
    CALL log006_exibe_teclas('01', p_versao)

    CALL cdv2007_inicia_variaveis()

    LET m_caminho = log130_procura_caminho('cdv2007')
    OPEN WINDOW w_cdv2007 AT 2,2 WITH FORM m_caminho
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
    DISPLAY p_cod_empresa TO empresa

    MENU 'OPÇÃO'
        COMMAND 'Consultar' 'Pesquisa os registros de auditoria gravados.'
            HELP 004
            MESSAGE ''
            IF  log005_seguranca(p_user, 'CDV' , 'CDV2007', 'CO') THEN
                CALL cdv2007_consulta()
            END IF

        COMMAND 'Seguinte'  'Exibe o próximo item encontrado na pesquisa.'
            HELP 005
            MESSAGE ''
            IF  m_consulta_ativa THEN
                CALL cdv2007_paginacao('SEGUINTE')
            ELSE
                CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ',"info")
            END IF

        COMMAND 'Anterior'  'Exibe o item anterior encontrado na pesquisa.'
            HELP 006
            MESSAGE ''
            IF  m_consulta_ativa THEN
                CALL cdv2007_paginacao('ANTERIOR')
            ELSE
                CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ',"info")
            END IF

        COMMAND KEY ('!')
            PROMPT 'Digite o comando : ' FOR m_comando
            RUN m_comando
            PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando

        COMMAND 'Fim'       'Retorna ao menu anterior.'
            HELP 008
            EXIT MENU
    END MENU

    WHENEVER ERROR CONTINUE
    CLOSE WINDOW w_cdv2007
    WHENEVER ERROR STOP
END FUNCTION

#-----------------------------------#
FUNCTION cdv2007_inicia_variaveis()
#-----------------------------------#
    LET m_consulta_ativa = FALSE

    INITIALIZE mr_cdv_auditoria_781.*  TO NULL
    INITIALIZE mr_cdv_auditoria_781r.* TO NULL
END FUNCTION

#-----------------------#
 FUNCTION cdv2007_help()
#-----------------------#
    OPTIONS HELP FILE m_caminho_help

    CASE
        WHEN infield(usuario)       	CALL showhelp(101)
        WHEN infield(programa)  	    CALL showhelp(102)
        WHEN infield(tip_manut)     	CALL showhelp(103)
        WHEN infield(dat_manut)     	CALL showhelp(104)
        WHEN infield(hor_manut)     	CALL showhelp(105)
        WHEN infield(nom_tabela)    	CALL showhelp(106)
        WHEN infield(nom_campo)     	CALL showhelp(107)
        WHEN infield(val_ant)				    CALL showhelp(108)
        WHEN infield(val_atual)			   CALL showhelp(109)
        WHEN infield(chave_registro)	CALL showhelp(110)
    END CASE

    CURRENT WINDOW IS w_cdv2007

END FUNCTION

#--------------------------#
 FUNCTION cdv2007_popup()
#--------------------------#
 CASE
   WHEN INFIELD(usuario)
      LET mr_cdv_auditoria_781.usuario = men010_popup_cod_usuario(TRUE)
      CALL log006_exibe_teclas("01 02 07",p_versao)
      CURRENT WINDOW IS w_cdv2007
      IF mr_cdv_auditoria_781.usuario IS NOT NULL THEN
         DISPLAY BY NAME mr_cdv_auditoria_781.usuario
      END IF

   WHEN infield(tip_manut)
      LET mr_cdv_auditoria_781.tip_manut = log0830_list_box(10,20,
                        "I {Inclusão}, M {Modificação}, E {Exclusão}" )
      CALL log006_exibe_teclas("01 02 07",p_versao)
      CURRENT WINDOW IS w_cdv2007
      IF mr_cdv_auditoria_781.tip_manut IS NOT NULL THEN
         DISPLAY BY NAME mr_cdv_auditoria_781.tip_manut
      END IF

 END CASE

 END FUNCTION

#--------------------------#
FUNCTION cdv2007_consulta()
#--------------------------#
    CALL log006_exibe_teclas('01 02 07 08', p_versao)
    CURRENT WINDOW IS w_cdv2007

    INITIALIZE where_clause TO NULL

    CLEAR FORM

    DISPLAY p_cod_empresa TO empresa

    LET INT_FLAG = FALSE

    CONSTRUCT BY NAME where_clause ON usuario, programa, tip_manut, dat_manut, hor_manut

        ON KEY (f1, control-w)
            CALL cdv2007_help()

        ON KEY (control-z, f4)
            CALL cdv2007_popup()

    END CONSTRUCT

    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_cdv2007

    IF  INT_FLAG THEN
        LET INT_FLAG = FALSE
        ERROR ' Consulta cancelada. '
    ELSE
        CALL cdv2007_prepara_consulta()
    END IF

    CALL cdv2007_exibe_dados()

    CALL log006_exibe_teclas('01 09', p_versao)
    CURRENT WINDOW IS w_cdv2007
END FUNCTION

#-----------------------------------#
 FUNCTION cdv2007_prepara_consulta()
#-----------------------------------#
 DEFINE l_seq      LIKE cdv_auditoria_781.seq_auditoria

    INITIALIZE mr_cdv_auditoria_781.* TO NULL

    LET sql_stmt = ' SELECT usuario, programa, tip_manut, dat_manut, ',
                          ' hor_manut, nom_tabela, nom_campo, val_ant, ',
                          ' val_atual, chave_registro, txt_processamento, seq_auditoria ',
                     ' FROM cdv_auditoria_781 ',
                    " WHERE empresa = '", p_cod_empresa, "' ",
                      " AND ", where_clause CLIPPED,
                    ' ORDER BY seq_auditoria '

    WHENEVER ERROR CONTINUE

    WHENEVER ERROR CONTINUE
    PREPARE var_cdv_auditoria_781 FROM sql_stmt
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("PREPARE","VAR_CDV_AUDITORIA")
       RETURN
    END IF

    WHENEVER ERROR CONTINUE
    DECLARE cq_cdv_auditoria_781 SCROLL CURSOR WITH HOLD FOR var_cdv_auditoria_781
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("PREPARE","cq_cdv_auditoria_781")
       RETURN
    END IF

    WHENEVER ANY ERROR CONTINUE
    OPEN  cq_cdv_auditoria_781
    WHENEVER ANY ERROR CONTINUE

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("OPEN","cq_cdv_auditoria_781")
       RETURN
    END IF

    WHENEVER ERROR CONTINUE
    FETCH cq_cdv_auditoria_781 INTO mr_cdv_auditoria_781.usuario, mr_cdv_auditoria_781.programa,
                                mr_cdv_auditoria_781.tip_manut, mr_cdv_auditoria_781.dat_manut,
                                mr_cdv_auditoria_781.hor_manut, mr_cdv_auditoria_781.nom_tabela,
                                mr_cdv_auditoria_781.nom_campo, mr_cdv_auditoria_781.val_ant,
                                mr_cdv_auditoria_781.val_atual, mr_cdv_auditoria_781.chave_registro,
                                m_txt_processamento, l_seq
    WHENEVER ERROR STOP

    IF  sqlca.sqlcode = 0 THEN
        MESSAGE ' Consulta efetuada com sucesso. ' ATTRIBUTE (REVERSE)
        LET m_consulta_ativa = TRUE
    ELSE
        LET m_consulta_ativa = FALSE
        CALL log0030_mensagem(' Argumentos de pesquisa não encontrados. ','info')
    END IF

END FUNCTION

#------------------------------------#
FUNCTION cdv2007_paginacao(l_funcao)
#------------------------------------#
 DEFINE l_funcao   CHAR(010)
 DEFINE l_seq      LIKE cdv_auditoria_781.seq_auditoria

    LET mr_cdv_auditoria_781r.* = mr_cdv_auditoria_781.*
    INITIALIZE mr_cdv_auditoria_781.*  TO NULL

    WHILE TRUE
        IF  l_funcao = 'SEGUINTE' THEN
            WHENEVER ERROR CONTINUE
            FETCH NEXT     cq_cdv_auditoria_781 INTO mr_cdv_auditoria_781.usuario, mr_cdv_auditoria_781.programa,
                                mr_cdv_auditoria_781.tip_manut, mr_cdv_auditoria_781.dat_manut,
                                mr_cdv_auditoria_781.hor_manut, mr_cdv_auditoria_781.nom_tabela,
                                mr_cdv_auditoria_781.nom_campo, mr_cdv_auditoria_781.val_ant,
                                mr_cdv_auditoria_781.val_atual, mr_cdv_auditoria_781.chave_registro,
                                m_txt_processamento, l_seq
           WHENEVER ERROR STOP
           IF SQLCA.sqlcode <> 0 THEN
           END IF
        ELSE
            WHENEVER ERROR CONTINUE
            FETCH PREVIOUS cq_cdv_auditoria_781 INTO mr_cdv_auditoria_781.usuario, mr_cdv_auditoria_781.programa,
                                mr_cdv_auditoria_781.tip_manut, mr_cdv_auditoria_781.dat_manut,
                                mr_cdv_auditoria_781.hor_manut, mr_cdv_auditoria_781.nom_tabela,
                                mr_cdv_auditoria_781.nom_campo, mr_cdv_auditoria_781.val_ant,
                                mr_cdv_auditoria_781.val_atual, mr_cdv_auditoria_781.chave_registro,
                                m_txt_processamento, l_seq
            WHENEVER ERROR STOP
            IF SQLCA.sqlcode <> 0 THEN
            END IF
        END IF

        IF  sqlca.sqlcode = 0 THEN
            EXIT WHILE
        ELSE
            ERROR ' Não existem mais itens nesta direção. '
            LET mr_cdv_auditoria_781.* = mr_cdv_auditoria_781r.*
            EXIT WHILE
        END IF
    END WHILE

    CALL cdv2007_exibe_dados()

END FUNCTION

#------------------------------#
 FUNCTION cdv2007_exibe_dados()
#------------------------------#
    DEFINE l_tam     SMALLINT

    IF mr_cdv_auditoria_781.usuario IS NOT NULL THEN

        WHENEVER ERROR CONTINUE
        SELECT nom_funcionario
          INTO mr_cdv_auditoria_781.nom_usuario
          FROM usuarios
         WHERE cod_usuario = mr_cdv_auditoria_781.usuario
         WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
            INITIALIZE mr_cdv_auditoria_781.nom_usuario TO NULL
        END IF
    END IF

    CASE mr_cdv_auditoria_781.tip_manut
        WHEN 'I' LET mr_cdv_auditoria_781.des_tip_manut = 'INCLUSÃO'
        WHEN 'E' LET mr_cdv_auditoria_781.des_tip_manut = 'EXCLUSÃO'
        WHEN 'M' LET mr_cdv_auditoria_781.des_tip_manut = 'MODIFICAÇÃO'
        WHEN 'P' LET mr_cdv_auditoria_781.des_tip_manut = 'PROCESSAMENTO'
            LET mr_cdv_auditoria_781.val_ant = m_txt_processamento
            INITIALIZE mr_cdv_auditoria_781.val_atual      TO NULL
            INITIALIZE mr_cdv_auditoria_781.chave_registro TO NULL
    END CASE
    DISPLAY BY NAME mr_cdv_auditoria_781.*

END FUNCTION

#-------------------------------#
 FUNCTION cdv2007_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2007.4gl $|$Revision: 3 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION