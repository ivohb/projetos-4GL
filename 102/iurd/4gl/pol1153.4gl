#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1153                                                 #
# OBJETIVO: APROVAÇÃO DE ETAPAS DE CONTRATO DE SERVIÇO              #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 23/05/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_caminho_jar        CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_texto              CHAR(10),
          p_linha              CHAR(30),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
         
   DEFINE p_dat_atu            DATE,
          p_hor_atu            CHAR(08),
          p_usuario            CHAR(10),
          p_nom_func           CHAR(40),
          p_cod_aprovador      CHAR(02)
          
   DEFINE pr_aprovar            ARRAY[100] OF RECORD
          marcado              CHAR(01),
          contrato_servico     INTEGER,
          versao_contrato      INTEGER,
          num_etapa            INTEGER,
          cod_fornecedor       CHAR(15),
          dat_vencto_etapa     DATE,
          val_etapa            DECIMAL(12,2),
          solicitante          CHAR(10)
   END RECORD

   DEFINE pr_funcio            ARRAY[100] OF RECORD
          unid_funcional       CHAR(10)
   END RECORD

          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1153-10.02.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  
   IF p_status = 0 THEN
      CALL pol1153_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1153_menu()
#----------------------#

   IF NOT pol1153_le_parametros() THEN
      RETURN
   END IF

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1153") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1153 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Informar" "Seleciona contratos para aprovação"
         CALL pol1153_informar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            NEXT OPTION "Processar"
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            LET p_ies_cons = FALSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Processar" "Processa as estapas marcadas"
         IF p_ies_cons THEN
            IF pol1153_processar() THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               CALL limpa_tela()
               ERROR 'Operação cancela !!!'
            END IF
            LET p_ies_cons = FALSE
         ELSE
             ERROR 'Informe os parâmetros previamente !!!'
             NEXT OPTION 'Informar'
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1153_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1153

END FUNCTION

#------------------------#
 FUNCTION pol1153_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
FUNCTION pol1153_le_parametros()
#-------------------------------#

   SELECT nom_caminho
      INTO p_caminho_jar
      FROM path_logix_v2
     WHERE cod_sistema = 'JAR'
       AND cod_empresa  = p_cod_empresa
       #AND ies_ambiente = 'W'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('','CAMINHO DO PROGRAMA')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1153_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
FUNCTION pol1153_informar()#
#--------------------------#

   DEFINE p_marca          CHAR(01),
          p_ies_marca      SMALLINT
   
   IF NOT pol1153_cria_tab_temp() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE pr_aprovar TO NULL
   LET p_ies_marca  = FALSE
   LET p_ind = 1
      
   DECLARE cq_aprov CURSOR FOR
    SELECT a.num_contrato,
           a.versao_contrato,
           a.num_etapa,
           a.usuario_solic,
           b.dat_vencto_etapa,
           b.val_etapa
      FROM aprov_etapa_265 a, 
           cos_etapa_contrato b, 
           res_cpr_deb_direto c
     WHERE c.cod_empresa = p_cod_empresa
       AND c.nom_usuario = p_user
       AND a.cod_empresa = c.cod_empresa
       AND a.unid_funcional = c.cod_uni_funcio
       AND b.empresa = a.cod_empresa
       AND b.contrato_servico = a.num_contrato
       AND b.versao_contrato = a.versao_contrato
       AND b.num_etapa = a.num_etapa
       AND b.sit_etapa = 'A'
     ORDER BY a.num_contrato, a.num_etapa

   FOREACH cq_aprov INTO
           pr_aprovar[p_ind].contrato_servico, 
           pr_aprovar[p_ind].versao_contrato,
           pr_aprovar[p_ind].num_etapa,   
           pr_aprovar[p_ind].solicitante,
           pr_aprovar[p_ind].dat_vencto_etapa,         
           pr_aprovar[p_ind].val_etapa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'cursor cq_aprov')
         RETURN FALSE
      END IF

      LET pr_aprovar[p_ind].marcado = 'N'
      
      SELECT fornecedor
        INTO pr_aprovar[p_ind].cod_fornecedor
        FROM cos_contr_servico
       WHERE empresa = p_cod_empresa
         AND contrato_servico = pr_aprovar[p_ind].contrato_servico
         AND versao_contrato  = pr_aprovar[p_ind].versao_contrato

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cos_contr_servico')
         RETURN FALSE
      END IF
      
      #CALL pol1153_le_usuario() RETURNING p_status
      #LET pr_aprovar[p_ind].solicitante = p_nom_func
      
      LET p_ind = p_ind + 1

      IF p_ind > 100 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
      
       
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Não existem contratos p/ aprovação, \n',
                  'para o usuario ', p_user
      CALL log0030_mensagem(p_msg,'EXCLAMATION')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_ind - 1)

   INPUT ARRAY pr_aprovar
         WITHOUT DEFAULTS FROM sr_aprovar.*
         
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  
     
      AFTER FIELD marcado
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            IF pr_aprovar[p_ind+1].contrato_servico IS null THEN
               NEXT FIELD marcado
            END IF
         END IF
         
      ON KEY (control-t)
         LET p_ies_marca = NOT p_ies_marca
         IF p_ies_marca THEN
            LET p_marca = 'S'
         ELSE
            LET p_marca = 'N'
         END IF
         FOR p_index = 1 TO ARR_COUNT()
             LET pr_aprovar[p_index].marcado = p_marca
             DISPLAY p_marca TO sr_aprovar[p_index].marcado 
         END FOR

      AFTER INPUT
         IF NOT INT_FLAG THEN
            LET p_marca = 'N'
            FOR p_index = 1 TO ARR_COUNT()
                IF pr_aprovar[p_index].marcado = 'S' THEN
                   LET p_marca = 'S'
                   EXIT FOR
                END IF
            END FOR
            IF p_marca = 'N' THEN
               ERROR 'Você precisa selecionar pelo menos uma etapa!'
               NEXT FIELD marcado
            END IF
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      call pol1153_limpa_tela()
      RETURN false
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------#
FUNCTION pol1153_processar()
#---------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME

   SELECT cod_nivel_autorid 
     INTO p_cod_aprovador
     FROM usuario_nivel_aut 
    WHERE cod_empresa = p_cod_empresa
      AND nom_usuario = p_user
      AND ies_versao_atual = 'S'
      
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_aprovar[p_ind].marcado = 'S' THEN
          IF NOT pol1153_aprova_etapa() THEN   
             CALL log085_transacao("ROLLBACK")   
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   CALL log085_transacao("COMMIT")
   
   CALL pol1153_envia_email()
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1153_aprova_etapa()#
#------------------------------#

   UPDATE cos_etapa_contrato
      SET sit_etapa = 'I'
    WHERE empresa = p_cod_empresa
      AND contrato_servico = pr_aprovar[p_ind].contrato_servico
      AND versao_contrato  = pr_aprovar[p_ind].versao_contrato
      AND num_etapa = pr_aprovar[p_ind].num_etapa
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','cos_etapa_contrato')
      RETURN FALSE
   END IF

   UPDATE aprov_etapa_265
      SET cod_aprovador = p_cod_aprovador,
          usuario_aprov = p_user,
          dat_aprov = p_dat_atu,
          hor_aprova = p_hor_atu
    WHERE cod_empresa = p_cod_empresa
      AND num_contrato = pr_aprovar[p_ind].contrato_servico
      AND versao_contrato  = pr_aprovar[p_ind].versao_contrato
      AND num_etapa = pr_aprovar[p_ind].num_etapa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','aprov_etapa_265')
      RETURN FALSE
   END IF
          
   INSERT INTO aprov_tmp_265
      VALUES(pr_aprovar[p_ind].solicitante, 
             pr_aprovar[p_ind].contrato_servico,
             pr_aprovar[p_ind].num_etapa)
                
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERINFO','APROV_TMP_265')
         RETURN FALSE
      END IF
   
   RETURN TRUE
         
END FUNCTION

#-------------------------------#
FUNCTION pol1153_cria_tab_temp()#
#-------------------------------#

   DROP TABLE aprov_tmp_265
   
   CREATE  TABLE aprov_tmp_265(
	    usuario        CHAR(10),
	    num_contrato   CHAR(10),
	    num_etapa      CHAR(10)
	 )

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","APROV_TMP_265")
			RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1153_le_usuario()#
#----------------------------#

   SELECT nom_funcionario
     INTO p_nom_func
     FROM usuarios
    WHERE cod_usuario = p_usuario
      
   IF STATUS <> 0 THEN
      LET p_nom_func = NULL
      CALL log003_err_sql('LENDO','usuarios:de')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#-----------------------------#   
FUNCTION pol1153_envia_email()#
#-----------------------------#
   
   DEFINE p_de           CHAR(40),
          p_para         CHAR(40),
          p_servidor     CHAR(40),
          p_assunto      CHAR(30),
          p_mensagem     CHAR(3000),
          p_usuario      CHAR(10),
          p_contrato     CHAR(10),
          p_etapa        CHAR(10),
          p_nom_user     CHAR(40),
          p_argumentos   CHAR(300),
          p_comando      CHAR(3500),
          p_senha        CHAR(15),
          p_cod_user     CHAR(08)

   SELECT e_mail,
          nom_funcionario
     INTO p_de,
          p_nom_user
     FROM usuarios
    WHERE cod_usuario = p_user
   
   IF p_de IS NULL THEN
      LET p_de = p_user
   END IF

   IF p_nom_user IS NULL THEN
      LET p_nom_user = p_user
   END IF

   LET p_servidor = 'smtp.universalsp.com.br'
   #LET p_servidor = 'smtp.gmail.com'
   LET p_assunto = 'Aprovação de contratos'
   LET p_senha = ''
   LET p_cod_user = p_user
   
   LET p_caminho_jar = p_caminho_jar CLIPPED,'Email.jar '
   
   DECLARE cq_user CURSOR FOR
    SELECT DISTINCT usuario
      FROM aprov_tmp_265
   
   FOREACH cq_user INTO p_usuario

      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','cq_user')
         RETURN FALSE
      END IF
      
      LET p_mensagem = 'Contrato(s) aprovado(s):\n'

      DECLARE cq_cont_etap CURSOR FOR
       SELECT num_contrato,
              num_etapa
         FROM aprov_tmp_265
        WHERE usuario = p_usuario
        ORDER BY num_contrato, num_etapa
       
      FOREACH cq_cont_etap INTO p_contrato, p_etapa
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('LENDO','cq_cont_etap')
            RETURN FALSE
         END IF
         
         LET p_linha = 'Contrato: ', p_contrato CLIPPED, ' etapa: ', p_etapa CLIPPED
         LET p_mensagem = p_mensagem CLIPPED, p_linha, '\n'
      
      END FOREACH
           
      LET p_mensagem = p_mensagem CLIPPED, '\n', p_nom_user
      
      SELECT e_mail
        INTO p_para
        FROM usuarios
       WHERE cod_usuario = p_usuario
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','usuarios:para')
         RETURN FALSE
      END IF
      
      LET p_argumentos = p_servidor CLIPPED,'&', p_de CLIPPED, '&', p_para CLIPPED, '&',
                         p_assunto CLIPPED, '&', p_mensagem CLIPPED, '&', 
                         p_cod_user CLIPPED,'&', p_senha CLIPPED, '&'

      LET p_comando = 'java -jar ',p_caminho_jar CLIPPED, ' ',  p_argumentos CLIPPED

      CALL conout(p_comando)

      CALL runOnClient(p_comando)
                               
   
   END FOREACH

END FUNCTION  
