###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDP0657                                               #
# MODULOS.: VDP0657 - LOG0010 - LOG0030 - LOG0050 - LOG0060       #
#           LOG1300 - LOG1400                                     #
# OBJETIVO: IMPORTACAO DA TABELA QFPTRAN                          #
# AUTOR...: EMANUELE BERGUI                                       #
# DATA....: 21/06/2006                                            #
#-----------------------------------------------------------------#
# OBJETIVO: MIGRAÇÃO VERSAO 05.10 PARA 10.02                      #
# AUTOR...: IVANELE DO ROCIO LOPES                                #
# DATA....: 06/01/2011                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT,
         p_houve_erro           SMALLINT,
         p_erro_informar        CHAR(01),
         p_ind_decimais         DECIMAL(01,0),
         p_divisor              DECIMAL(10,0),
         g_ies_ambiente         CHAR(001),
         g_ies_grafico          SMALLINT

  DEFINE p_qfptran              RECORD LIKE qfptran.*
  DEFINE p_par_vdp              RECORD LIKE par_vdp.*

  DEFINE p_qfptran_3            RECORD
                                chave              CHAR(76),
                                data1              CHAR(06),
                                hora1              DECIMAL(02,0),
                                qtd_chamada1       DECIMAL(09,0),
                                data2              CHAR(06),
                                hora2              DECIMAL(02,0),
                                qtd_chamada2       DECIMAL(09,0),
                                data3              CHAR(06),
                                hora3              DECIMAL(02,0),
                                qtd_chamada3       DECIMAL(09,0),
                                data4              CHAR(06),
                                hora4              DECIMAL(02,0),
                                qtd_chamada4       DECIMAL(09,0),
                                data5              CHAR(06),
                                hora5              DECIMAL(02,0),
                                qtd_chamada5       DECIMAL(09,0),
                                data6              CHAR(06),
                                hora6              DECIMAL(02,0),
                                qtd_chamada6       DECIMAL(09,0),
                                data7              CHAR(06),
                                hora7              DECIMAL(02,0),
                                qtd_chamada7       DECIMAL(09,0),
                                fim                CHAR(05)
                                END RECORD

   DEFINE p_nom_arquivo          CHAR(100),
          p_msg                  CHAR(100),
          p_comando              CHAR(080),
          p_caminho              CHAR(080),
          p_nom_tela             CHAR(080),
          p_help                 CHAR(080),
          m_nom_arquivo_aux      CHAR(100),
          p_cancel               INTEGER

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
   DEFINE p_mensagem          CHAR(300)
END GLOBALS

DEFINE m_status               INTEGER,
       m_diretorio            CHAR(100),
       m_executa_auto              SMALLINT,
       m_usa_var_qfp_agco     CHAR(01),
       m_comando              CHAR(150),
       m_comand_cap           CHAR(150)

DEFINE ma_tela  ARRAY[99] OF RECORD
                   seleciona  CHAR(01),
                   arquivo    CHAR(57)
                END RECORD

MAIN

   CALL log0180_conecta_usuario()

   LET p_versao = "VDP0657-10.02.00p" #Favor nao alterar esta linha (SUPORTE)

   WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("vdp0657.iem") RETURNING m_comando
   OPTIONS
       HELP FILE m_comando

   CALL log001_acessa_usuario("VDP","LOGERP")
        RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL vdp0657_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION vdp0657_controle()
#--------------------------#
   DEFINE
      l_diretorio  LIKE  exp_interface.dir_entrada,
      l_arquivo    LIKE  exp_interface.nom_arquivo,
      l_parametro  CHAR(01),
      l_caminho    CHAR(200),
      l_comando    CHAR(130),
      l_nom_remove CHAR(200),
      l_ind        SMALLINT,
      l_selecao    SMALLINT

   #
   CALL vdp0654_cria_tabelas_temp()
   #

   CALL log2250_busca_parametro(p_cod_empresa,'usa_var_qfp_agco')
      RETURNING m_usa_var_qfp_agco, p_status

   IF m_usa_var_qfp_agco = 'S' THEN
      {Sistema QFP não suporta arquivo EDI AGCO}
      CALL LOG0030_mensagem('Sistema QFP não suporta arquivo EDI AGCO.','exclamation')
      RETURN
   END IF

   LET m_executa_auto = TRUE

   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("vdp0657") RETURNING m_comand_cap
   OPEN WINDOW w_vdp0657 AT 2,2  WITH FORM m_comand_cap
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

    MENU "OPCAO"

      COMMAND "Processar" "Processar atualização de tabelas de Pedidos."
        HELP 010
        MESSAGE ""
        IF log005_seguranca(p_user,"VDP","VDP0657","CO") THEN
           CALL vdp0654_carrega_ies_job(m_executa_auto)
           WHENEVER ERROR CONTINUE
            CALL log085_transacao("BEGIN")
            WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
           END IF
           IF vdp0654_controle() THEN
              WHENEVER ERROR CONTINUE
               CALL log085_transacao("COMMIT")
               WHENEVER ERROR STOP
              CALL LOG0030_mensagem('Processamento finalizado.','exclamation')
           ELSE
              WHENEVER ERROR CONTINUE
               CALL log085_transacao("ROLLBACK")
              WHENEVER ERROR STOP
               IF sqlca.sqlcode <> 0 THEN
               END IF
              CALL LOG0030_mensagem('Processamento cancelado.','exclamation')
              CALL log0030_mensagem(p_mensagem,"excl.")
              SLEEP 2
           END IF
        END IF
        NEXT OPTION "Fim"

      COMMAND "Fim" "Retorna ao Menu Anterior"
        HELP 008
        MESSAGE ""
        EXIT MENU
         #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
         #lds CALL LOG_info_sobre(sourceName(),p_versao)

  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

     END MENU
     CLOSE WINDOW w_vdp0657

END FUNCTION

#-------------------------------#
 FUNCTION vdp0657_version_info()
#-------------------------------#

 RETURN "$Archive: /especificos/logix10R2/painco_industria_e_comercio_sa/vendas/vendas/programas/vdp0657.4gl $|$Revision: 6 $|$Date: 27/05/11 16:42 $|$Modtime: 26/05/11 17:03 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION
