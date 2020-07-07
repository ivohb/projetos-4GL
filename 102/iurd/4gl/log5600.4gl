#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE E ADMINISTRACAO GERAL DO LOGIX                 #
# PROGRAMA: LOG5600                                                 #
# OBJETIVO: ENVIAR EMAIL FORMATADO EM FORMATO HTML PELO LOGIX.      #
# AUTOR...: FERNANDO CESAR JUNKES.                                  #
# DATA....: 26/06/2001.                                             #
#-------------------------------------------------------------------#
# INCLUIDA FUNCAO DE ENVIO DE E-MAIL EM FORMATO HTML E CRIPTOGRAFADO#
# SILVIANE - O.S. 271988                                            #
# DATA....: 21/07/2003                                              #
#-------------------------------------------------------------------#
 DATABASE logix

 GLOBALS

 END GLOBALS

    DEFINE mr_tela      RECORD
                              remetente           LIKE usuarios.e_mail,
                              destinatario        CHAR(150),
                              assunto             CHAR(070)
                        END RECORD

    DEFINE m_versao_funcao       CHAR(18) # -- Favor nao apagar esta linha (SUPORTE)

    DEFINE m_caminho             CHAR(100)


#------------------------------------------------------------------------#
 FUNCTION log5600_envia_email(l_remetente,
                              l_destinatario,
                              l_assunto,
                              l_arquivo_html,
                              l_formato)
#------------------------------------------------------------------------#

    DEFINE l_remetente           LIKE usuarios.e_mail,
           l_destinatario        CHAR(250),
           l_assunto             CHAR(070),
           l_arquivo_html        CHAR(200),
           l_formato             SMALLINT   #1-Formato HTML   2-Formato Texto

    LET m_versao_funcao = "LOG5600-05.00.12"

    LET mr_tela.remetente    = l_remetente
    LET mr_tela.destinatario = l_destinatario
    LET mr_tela.assunto      = l_assunto

    IF  mr_tela.remetente IS NULL THEN

        LET mr_tela.remetente = log5600_busca_email_usuario()
    END IF

    IF  mr_tela.remetente    = " " OR
        mr_tela.remetente    IS NULL OR
        mr_tela.destinatario IS NULL OR
        mr_tela.assunto      IS NULL THEN

        CALL log006_exibe_teclas("01 09", m_versao_funcao)

        LET m_caminho = log130_procura_caminho("log56001")

        OPEN WINDOW w_log56001 AT 6,5 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL log0010_close_window_screen()
        IF  log5600_entrada_dados() THEN

            CALL log5600_processa_envio_email(l_arquivo_html,l_formato, " ")

        ELSE
            ERROR "Envio de Email Cancelado. "
            SLEEP 2

        END IF

        CLOSE WINDOW w_log56001

   ELSE

       CALL log5600_processa_envio_email(l_arquivo_html, l_formato, " ")
   END IF

 END FUNCTION



#--------------------------------------#
 FUNCTION log5600_busca_email_usuario()
#--------------------------------------#

    DEFINE l_usuario          LIKE usuario.nom_usuario

    DEFINE l_remetente        LIKE usuarios.e_mail

    LET l_usuario = fgl_getenv("LOGNAME")

    SELECT e_mail INTO l_remetente
     FROM usuarios
    WHERE cod_usuario = l_usuario

    RETURN l_remetente

 END FUNCTION



#--------------------------------#
 FUNCTION log5600_entrada_dados()
#--------------------------------#

   INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

   AFTER INPUT

       IF  NOT INT_FLAG  THEN

           IF  mr_tela.remetente <> " " THEN
               IF  NOT log5600_verifica_email_valido(mr_tela.remetente) THEN
                   ERROR "Endereco Invalido. "
                   SLEEP 1
                   NEXT FIELD remetente
               END IF
           ELSE
               NEXT FIELD remetente
           END IF

           IF  mr_tela.destinatario <> " " THEN
               IF  NOT log5600_verifica_email_valido(mr_tela.destinatario) THEN
                   ERROR "Endereco Invalido. "
                   SLEEP 1
                   NEXT FIELD destinatario
               END IF
           ELSE
               NEXT FIELD destinatario
           END IF

       END IF

   END INPUT

   IF  INT_FLAG THEN
       LET INT_FLAG = FALSE
       RETURN FALSE
   ELSE
       RETURN TRUE
   END IF

 END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION log5600_envia_email_anexo(l_remetente,
                                    l_destinatario,
                                    l_assunto,
                                    l_arquivo_html,
                                    l_formato,
                                    l_arquivos_anexos)
#---------------------------------------------------------------------#

    DEFINE l_remetente           LIKE usuarios.e_mail,
           l_destinatario        CHAR(250),
           l_assunto             CHAR(070),
           l_arquivo_html        CHAR(200),
           l_arquivos_anexos     CHAR(500), #Se houver mais de um arquivo a anexar, o delimitador entre os dois arquivos neste parametro será o ";"
           l_formato             SMALLINT   #1-Formato HTML   2-Formato Texto

    LET m_versao_funcao = "LOG5600-04.10.07"

    LET mr_tela.remetente    = l_remetente
    LET mr_tela.destinatario = l_destinatario
    LET mr_tela.assunto      = l_assunto

    IF  mr_tela.remetente IS NULL THEN

        LET mr_tela.remetente = log5600_busca_email_usuario()
    END IF

    IF  mr_tela.remetente    = " " OR
        mr_tela.destinatario IS NULL OR
        mr_tela.assunto      IS NULL THEN

        CALL log006_exibe_teclas("01 09", m_versao_funcao)

        LET m_caminho = log130_procura_caminho("log56001")

        OPEN WINDOW w_log56001 AT 6,5 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL log0010_close_window_screen()
        IF  log5600_entrada_dados() THEN

            CALL log5600_processa_envio_email(l_arquivo_html,l_formato,l_arquivos_anexos)

        ELSE
            ERROR "Envio de Email Cancelado. "
            SLEEP 2

        END IF

        CLOSE WINDOW w_log56001

   ELSE

       CALL log5600_processa_envio_email(l_arquivo_html, l_formato, l_arquivos_anexos)
   END IF

 END FUNCTION

#-----------------------------------------------------#
 FUNCTION log5600_verifica_email_valido(l_endereco)
#-----------------------------------------------------#
    DEFINE l_endereco    LIKE usuarios.e_mail

    DEFINE l_ind_arroba  SMALLINT,
           l_ind_ponto   SMALLINT,
           l_ind         SMALLINT

    FOR l_ind = 1 TO LENGTH(l_endereco)

        IF  l_ind_arroba = FALSE THEN

            IF  l_endereco[l_ind] = "@" THEN
                LET l_ind_arroba = TRUE
            END IF

        ELSE

            IF  l_endereco[l_ind] = "." THEN
                LET l_ind_ponto = TRUE
                EXIT FOR
            END IF

        END IF

    END FOR

    RETURN l_ind_ponto

 END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION log5600_processa_envio_email(l_arquivo_html,
                                       l_formato,
                                       l_arquivos_anexos)
#--------------------------------------------------------------------#
    DEFINE l_comando             CHAR(800),
           l_arquivo_html        CHAR(200),
           l_servidor_smtp       CHAR(100),
           l_arquivos_anexos     CHAR(500)

    DEFINE l_formato             SMALLINT

    LET l_servidor_smtp = fgl_getenv("SMTP_SERVER")

    IF  l_arquivos_anexos = " " THEN
        LET l_arquivos_anexos = NULL
    END IF

    LET l_comando = "java Envia ",
                    l_servidor_smtp CLIPPED,
                    " ",
                    mr_tela.remetente CLIPPED,
                    " ",
                    '"',
                    mr_tela.destinatario CLIPPED,
                    '"',
                    ' "',
                    mr_tela.assunto CLIPPED,
                    '" ',
                    l_arquivo_html CLIPPED,
                    " ",
                    l_formato CLIPPED

    {IF  l_arquivos_anexos IS NOT NULL THEN
        LET l_comando = l_comando CLIPPED,
                        ' "',
                        l_arquivos_anexos CLIPPED,
                        '"'
    END IF}
    
   let l_arquivos_anexos = l_comando
   
    RUN l_comando

 END FUNCTION


#---------------------------------------------------------------------------#
 FUNCTION log5600_envia_email_criptografado(l_remetente,
                                            l_destinatario,
                                            l_assunto,
                                            l_arquivo_html,
                                            l_formato,
                                            l_arquivos_anexos,
                                            l_imagem_arq_html,
                                            l_arquivo_criptograf,
                                            l_senha)
#---------------------------------------------------------------------------#

    DEFINE l_remetente           LIKE usuarios.e_mail,
           l_destinatario        CHAR(250),
           l_assunto             CHAR(070),
           l_arquivo_html        CHAR(200),
           l_arquivos_anexos     CHAR(500), #Se houver mais de um arquivo a anexar, o delimitador entre os dois arquivos neste parametro será o ";"
           l_formato             SMALLINT,  #1-Formato HTML   2-Formato Texto
           l_imagem_arq_html     CHAR(150), #Será informado somente se formato for 1
           l_arquivo_criptograf  CHAR(150),
           l_senha               LIKE usuario_senha.senha

    LET m_versao_funcao = "LOG5600-04.10.07"

    LET mr_tela.remetente          = l_remetente
    LET mr_tela.destinatario       = l_destinatario
    LET mr_tela.assunto            = l_assunto

    IF  mr_tela.remetente IS NULL THEN
        LET mr_tela.remetente = log5600_busca_email_usuario()
    END IF

    IF  mr_tela.remetente    = " " OR
        mr_tela.destinatario IS NULL OR
        mr_tela.assunto      IS NULL THEN

        CALL log006_exibe_teclas("01 09", m_versao_funcao)

        LET m_caminho = log130_procura_caminho("log56001")

        OPEN WINDOW w_log56001 AT 6,5 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL log0010_close_window_screen()
        IF  log5600_entrada_dados() THEN

            CALL log5600_processa_envio_email_criptograf(l_arquivo_html,l_formato,
                                                         l_arquivos_anexos,l_imagem_arq_html,
                                                         l_arquivo_criptograf,l_senha)

        ELSE
            ERROR "Envio de Email Cancelado. "
            SLEEP 2

        END IF

        CLOSE WINDOW w_log56001

   ELSE
       CALL log5600_processa_envio_email_criptograf(l_arquivo_html,l_formato,
                                                    l_arquivos_anexos,l_imagem_arq_html,
                                                    l_arquivo_criptograf,l_senha)
   END IF

 END FUNCTION



#-------------------------------------------------------------------------#
 FUNCTION log5600_processa_envio_email_criptograf(l_arquivo_html,
                                                  l_formato,
                                                  l_arquivos_anexos,
                                                  l_imagem_arq_html,
                                                  l_arquivo_criptograf,
                                                  l_senha)
#-------------------------------------------------------------------------#
    DEFINE l_comando             CHAR(800),
           l_arquivo_html        CHAR(200),
           l_servidor_smtp       CHAR(100),
           l_arquivos_anexos     CHAR(500),
           l_imagem_arq_html     CHAR(150), #Será informado somente se formato for 1
           l_arquivo_criptograf  CHAR(150),
           l_senha               LIKE usuario_senha.senha

    DEFINE l_formato             SMALLINT

    LET l_servidor_smtp = fgl_getenv("SMTP_SERVER")

    LET l_comando = "java Envia2 ",
                     l_servidor_smtp CLIPPED,
                     " ",
                     mr_tela.remetente CLIPPED,
                     " ",
                     '"',
                     mr_tela.destinatario CLIPPED,
                     '"',
                     ' "',
                     mr_tela.assunto CLIPPED,
                     '" ',
                     l_arquivo_html CLIPPED,
                     " ",
                     l_formato CLIPPED,
                     ' "',
                     l_arquivos_anexos CLIPPED,
                     '" ',
                     ' "',
                     l_imagem_arq_html CLIPPED,
                     '" ',
                     ' "',
                     l_arquivo_criptograf CLIPPED,
                     '" ',
                     ' "',
                     l_senha CLIPPED,
                     '"'

     RUN l_comando

 END FUNCTION
