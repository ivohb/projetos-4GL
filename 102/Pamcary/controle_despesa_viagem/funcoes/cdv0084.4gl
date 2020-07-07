#-------------------------------------------------------------------#
# SISTEMA.: GERENCIAMENTO DO MENU DE APLICATIVOS LOGIX.             #
# PROGRAMA: CDV0084                                                 #
# OBJETIVO: POPUP DA TABELA "EMPRESA"                               #
# AUTOR...: SAMUEL VIEIRA DA COSTA.                                 #
# DATA....: 24/11/1994.                                             #
#-------------------------------------------------------------------#
 DATABASE logix

 GLOBALS

  DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
         p_user                   LIKE usuario.nom_usuario

  DEFINE  p_versao   CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

 END GLOBALS

     DEFINE m_versao_funcao       CHAR(18) # -- Favor nao apagar esta linha (SUPORTE)

#------------------------------------------------------------------------#
 FUNCTION cdv0084_popup_cod_empresa(p_ies_atua, l_emp, l_empresa_atendida)
#------------------------------------------------------------------------#
     DEFINE p_ies_atua            SMALLINT,
            l_emp                 CHAR(03),
            l_empresa_atendida    LIKE empresa.cod_empresa

     DEFINE a_empresa             ARRAY[100] OF RECORD
                                       cod_empresa        LIKE empresa.cod_empresa,
                                       den_empresa_abrev  LIKE empresa.den_reduz
                                  END RECORD

     DEFINE p_ind                 SMALLINT,
            p_ies_fim             SMALLINT

     DEFINE p_cod_empresa         LIKE empresa.cod_empresa

     DEFINE p_caminho             CHAR(150)

     LET p_versao = "CDV0084-05.10.00p" #Favor nao alterar esta linha (SUPORTE)

     OPTIONS
         NEXT     KEY control-f,
         PREVIOUS KEY control-b

     IF  p_ies_atua THEN
         LET m_versao_funcao = "CDV0084-05.10.00p"
         CALL log006_exibe_teclas("02 08 10 17 18", m_versao_funcao)
     ELSE
         LET m_versao_funcao = "CDV0084-05.10.00p"
         CALL log006_exibe_teclas("02 08 17 18", m_versao_funcao)
     END IF

     LET p_caminho = log130_procura_caminho("cdv0084")

     OPEN WINDOW w_cdv0084 AT 8,56 WITH FORM p_caminho
          ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

   CALL log0010_close_window_screen()
     LET p_ies_fim   = FALSE

     DECLARE ca_empresa CURSOR FOR
      SELECT cod_empresa, den_reduz
        FROM empresa
    ORDER BY empresa.cod_empresa

     WHILE p_ies_fim = FALSE
         LET p_ind = 1
         OPEN  ca_empresa
         FETCH ca_empresa INTO a_empresa[p_ind].*

         WHILE sqlca.sqlcode <> NOTFOUND
           AND p_ind          < 100

             IF l_emp = 'MAT' THEN
                WHENEVER ERROR CONTINUE
                SELECT 1
                  FROM par_con
                 WHERE cod_empresa = a_empresa[p_ind].cod_empresa
                   AND (cod_empresa_mestre IS NULL
                      OR cod_empresa_mestre = ' ')
                WHENEVER ERROR STOP

                IF SQLCA.sqlcode <> 0 THEN
                   INITIALIZE a_empresa[p_ind].* TO NULL
                   FETCH ca_empresa INTO a_empresa[p_ind].*
                   CONTINUE WHILE
                END IF

             ELSE
                WHENEVER ERROR CONTINUE
                SELECT 1
                  FROM par_con
                 WHERE cod_empresa        = a_empresa[p_ind].cod_empresa
                   AND cod_empresa_mestre = l_empresa_atendida
                WHENEVER ERROR STOP

                IF SQLCA.sqlcode <> 0 THEN
                   INITIALIZE a_empresa[p_ind].* TO NULL
                   FETCH ca_empresa INTO a_empresa[p_ind].*
                   CONTINUE WHILE
                END IF

             END IF

             LET p_ind = p_ind + 1
             FETCH ca_empresa INTO a_empresa[p_ind].*
         END WHILE

         CALL set_count(p_ind)
         IF  sqlca.sqlcode <> 0 THEN
             IF  p_ind      = 1 THEN
                 ERROR " Tabela de Empresas está vazia. "
             ELSE
                 CALL set_count(p_ind - 1)
             END IF
         END IF

         CLOSE ca_empresa

         LET p_ies_fim = TRUE

         DISPLAY ARRAY a_empresa TO s_empresa.*
     END WHILE

     IF  int_flag THEN
         LET int_flag = FALSE
     ELSE
         LET p_ind = arr_curr()
         LET p_cod_empresa = a_empresa[p_ind].cod_empresa
     END IF

     CLOSE WINDOW w_cdv0084

     RETURN p_cod_empresa
 END FUNCTION

#-------------------------------#
 FUNCTION cdv0804_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/funcoes/cdv0084.4gl $|$Revision: 2 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION