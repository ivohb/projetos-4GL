#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1152                                                 #
# OBJETIVO: SOLICITAÇÃO DE APROVAÇÃO DE ETAPAS                      #
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
          p_hor_atu            CHAR(08)
          
   DEFINE p_param              RECORD
          contrato_de          INTEGER, 
          contrato_ate         INTEGER, 
          etapa_de             INTEGER,     
          etapa_ate            INTEGER, 
          data_de              DATE, 
          data_ate             DATE
   END RECORD          

   DEFINE pr_solic             ARRAY[100] OF RECORD
          marcado              CHAR(01),
          contrato_servico     INTEGER,
          versao_contrato      INTEGER,
          num_etapa            INTEGER,
          cod_fornecedor       CHAR(15),
          dat_vencto_etapa     DATE,
          val_etapa            DECIMAL(12,2)
   END RECORD

   DEFINE pr_funcio            ARRAY[100] OF RECORD
          unid_funcional       CHAR(10)
   END RECORD

   DEFINE pr_aprovada          ARRAY[100] OF RECORD
          marcado              CHAR(01),
          contrato_servico     INTEGER,
          num_etapa            INTEGER,
          cod_fornecedor       CHAR(15),
          dat_vencto_etapa     DATE,
          val_etapa            DECIMAL(12,2),
          aprovante            CHAR(02),
          usuario              CHAR(08)
   END RECORD
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1152-10.02.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  
   IF p_status = 0 THEN
      CALL pol1152_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1152_menu()
#----------------------#

   IF NOT pol1152_le_parametros() THEN
      RETURN
   END IF

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol11521") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol11521 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1152") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1152 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Solicitar" "Solicitar aprovação de etapas do contrato"
         CURRENT WINDOW IS w_pol1152
         CALL pol1152_informar() RETURNING p_status
         IF p_status THEN
            IF pol1152_marca_etapas() THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Aprovadas" "Consulta as etapas já aprovadas"
         CURRENT WINDOW IS w_pol11521
         CALL pol1152_informar() RETURNING p_status
         IF p_status THEN
            IF pol1152_exibe_etapas() THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Processar" "Processa as estapas marcadas"
         IF p_ies_cons THEN
            IF pol1152_processar() THEN
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
         CALL pol1152_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1152
   CLOSE WINDOW w_pol11521

END FUNCTION

#------------------------#
 FUNCTION pol1152_sobre()#
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
FUNCTION pol1152_le_parametros()
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
FUNCTION pol1152_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
FUNCTION pol1152_informar()#
#--------------------------#

   CALL pol1152_limpa_tela()
   INITIALIZE p_param TO NULL
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_param.* WITHOUT DEFAULTS

      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_param.contrato_de IS NULL THEN
               LET p_param.contrato_de = 0
            END IF
            IF p_param.contrato_ate IS NULL THEN
               LET p_param.contrato_ate = 999999999
            END IF
            IF p_param.etapa_de IS NULL THEN
               LET p_param.etapa_de = 0
            END IF
            IF p_param.etapa_ate IS NULL THEN
               LET p_param.etapa_ate = 9999
            END IF
            IF p_param.data_de IS NULL THEN
               LET p_param.data_de = '01/01/2000'
            END IF
            IF p_param.data_ate IS NULL THEN
               LET p_param.data_ate = '31/12/2999'
            END IF
         END IF

   END INPUT 

   IF INT_FLAG THEN
      CALL pol1152_limpa_tela()
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_param.*

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1152_cria_tab_temp()#
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

#------------------------------#
FUNCTION pol1152_marca_etapas()#
#------------------------------#

   DEFINE p_marca          CHAR(01),
          p_ies_marca      SMALLINT
   
   IF NOT pol1152_cria_tab_temp() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE pr_solic, pr_funcio to null
   LET p_ies_marca  = FALSE
   LET p_ind = 1
   
   DECLARE cq_solicita CURSOR FOR
    SELECT a.contrato_servico,
           a.versao_contrato,
           a.num_etapa,
           b.fornecedor,
           a.dat_vencto_etapa,
           a.val_etapa,
           b.unid_funcional
      FROM cos_etapa_contrato a, cos_contr_servico b
     WHERE a.empresa = p_cod_empresa
       AND a.contrato_servico BETWEEN p_param.contrato_de AND p_param.contrato_ate
       AND a.num_etapa BETWEEN p_param.etapa_de AND p_param.etapa_ate
       AND a.dat_vencto_etapa BETWEEN p_param.data_de AND p_param.data_ate
       AND a.sit_etapa = 'A'
       AND b.empresa = a.empresa
       AND b.contrato_servico = a.contrato_servico
       AND b.versao_contrato = a.versao_contrato
       AND b.filial=0
     ORDER BY a.contrato_servico, a.num_etapa

   FOREACH cq_solicita INTO
           pr_solic[p_ind].contrato_servico, 
           pr_solic[p_ind].versao_contrato,
           pr_solic[p_ind].num_etapa,         
           pr_solic[p_ind].cod_fornecedor,          
           pr_solic[p_ind].dat_vencto_etapa,         
           pr_solic[p_ind].val_etapa,
           pr_funcio[p_ind].unid_funcional   

      SELECT COUNT(cod_uni_funcio)
        INTO p_count
        FROM res_cpr_deb_direto
       WHERE cod_empresa = p_cod_empresa
         and cod_uni_funcio = pr_funcio[p_ind].unid_funcional
      
      if status <> 0 then
         call log003_err_sql('Lendo', 'res_cpr_deb_direto')
         RETURN false
      end if
      
      if p_count = 0 then
         CONTINUE FOREACH
      end if
      
      SELECT num_contrato
        FROM aprov_etapa_265
       WHERE cod_empresa = p_cod_empresa
         AND num_contrato = pr_solic[p_ind].contrato_servico
         AND versao_contrato = pr_solic[p_ind].versao_contrato
         AND num_etapa = pr_solic[p_ind].num_etapa
      
      IF STATUS = 0 then
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            call log003_err_sql('Lendo','aprov_etapa_265:1')
            RETURN FALSE
         END IF
      END IF
      
      let pr_solic[p_ind].marcado = 'N'
      
      let p_ind = p_ind + 1

      IF p_ind > 100 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
      
       
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Não existem contratos s/ aprovação, \n',
                  'para os parâmtros informados!'
      CALL log0030_mensagem(p_msg,'EXCLAMATION')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_ind - 1)

   INPUT ARRAY pr_solic
         WITHOUT DEFAULTS FROM sr_solic.*
         
            
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  
     
      AFTER FIELD marcado
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            IF pr_solic[p_ind+1].contrato_servico IS null THEN
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
             LET pr_solic[p_index].marcado = p_marca
             DISPLAY p_marca TO sr_solic[p_index].marcado 
         END FOR

      AFTER INPUT
         IF NOT INT_FLAG THEN
            LET p_marca = 'N'
            FOR p_index = 1 TO ARR_COUNT()
                IF pr_solic[p_index].marcado = 'S' THEN
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
      call pol1152_limpa_tela()
      RETURN false
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_solic[p_ind].marcado = 'S' THEN
          IF NOT pol1152_ins_solic() THEN   
             CALL log085_transacao("ROLLBACK")   
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   CALL log085_transacao("COMMIT")
   
   CALL pol1152_envia_email()
   
   RETURN TRUE
         
END FUNCTION

#---------------------------#
FUNCTION pol1152_ins_solic()#
#---------------------------#
   
   DEFINE p_aprov_etapa_265 RECORD LIKE aprov_etapa_265.*
   
   SELECT num_contrato
     FROM aprov_etapa_265
    WHERE cod_empresa = p_cod_empresa
      AND num_contrato = pr_solic[p_ind].contrato_servico
      AND versao_contrato = pr_solic[p_ind].versao_contrato
      AND num_etapa = pr_solic[p_ind].num_etapa
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','aprov_etapa_265:2')
         RETURN FALSE
      END IF
   END IF
   
   LET p_aprov_etapa_265.cod_empresa     = p_cod_empresa
   LET p_aprov_etapa_265.unid_funcional  = pr_funcio[p_ind].unid_funcional
   LET p_aprov_etapa_265.num_contrato    = pr_solic[p_ind].contrato_servico
   LET p_aprov_etapa_265.versao_contrato = pr_solic[p_ind].versao_contrato
   LET p_aprov_etapa_265.num_etapa       = pr_solic[p_ind].num_etapa
   LET p_aprov_etapa_265.cod_aprovador   = '' 
   LET p_aprov_etapa_265.usuario_aprov   = ''
   LET p_aprov_etapa_265.dat_aprov       = ''
   LET p_aprov_etapa_265.hor_aprova      = ''
   LET p_aprov_etapa_265.usuario_solic   = p_user
   LET p_aprov_etapa_265.dat_solic       = p_dat_atu
   LET p_aprov_etapa_265.hor_solic       = p_hor_atu

   INSERT INTO aprov_etapa_265 VALUES(p_aprov_etapa_265.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','APROV_ETAPA_265')
      RETURN FALSE
   END IF

   IF NOT pol1152_ins_aprov_temp() THEN   
      RETURN FALSE
   END IF
   
   RETURN TRUE 

END FUNCTION

#--------------------------------#
FUNCTION pol1152_ins_aprov_temp()
#--------------------------------#

   DEFINE p_nom_usuario CHAR(10)

   DECLARE cq_res_cpr CURSOR FOR
    SELECT nom_usuario
      FROM res_cpr_deb_direto
     WHERE cod_empresa = p_cod_empresa
       AND cod_uni_funcio = pr_funcio[p_ind].unid_funcional
   
   FOREACH cq_res_cpr INTO p_nom_usuario   
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','cq_res_cpr')
         RETURN FALSE
      END IF
      
      INSERT INTO aprov_tmp_265
         VALUES(p_nom_usuario, 
                pr_solic[p_ind].contrato_servico,
                pr_solic[p_ind].num_etapa)
                
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERINFO','aprov_tmp_265')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION
    
#-----------------------------#   
FUNCTION pol1152_envia_email()#
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
      
      LET p_mensagem = 'Solicito aprovação do(s) contrato(s) abaixo:\n'

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

#------------------------------#
FUNCTION pol1152_exibe_etapas()#
#------------------------------#

   DEFINE p_unid_funcional CHAR(15)
   
   INITIALIZE pr_aprovada to null

   LET p_ind = 1
   
   DECLARE cq_aprovada CURSOR FOR
    SELECT a.contrato_servico,
           a.num_etapa,
           b.fornecedor,
           a.dat_vencto_etapa,
           a.val_etapa,
           b.unid_funcional
      FROM cos_etapa_contrato a, cos_contr_servico b
     WHERE a.empresa = p_cod_empresa
       AND a.contrato_servico BETWEEN p_param.contrato_de AND p_param.contrato_ate
       AND a.num_etapa BETWEEN p_param.etapa_de AND p_param.etapa_ate
       AND a.dat_vencto_etapa BETWEEN p_param.data_de AND p_param.data_ate
       AND a.sit_etapa = 'I'
       AND b.empresa = a.empresa
       AND b.contrato_servico = a.contrato_servico
       AND b.versao_contrato = a.versao_contrato
       AND b.filial=0

   FOREACH cq_aprovada INTO
           pr_aprovada[p_ind].contrato_servico,        
           pr_aprovada[p_ind].num_etapa,         
           pr_aprovada[p_ind].cod_fornecedor,          
           pr_aprovada[p_ind].dat_vencto_etapa,         
           pr_aprovada[p_ind].val_etapa,
           p_unid_funcional   

      SELECT COUNT(cod_uni_funcio)
        INTO p_count
        FROM res_cpr_deb_direto
       WHERE cod_empresa = p_cod_empresa
         and cod_uni_funcio = p_unid_funcional
      
      if status <> 0 then
         call log003_err_sql('Lendo', 'res_cpr_deb_direto')
         RETURN false
      end if
      
      if p_count = 0 then
         CONTINUE FOREACH
      end if
      
      let pr_aprovada[p_ind].marcado = 'S'
      
      let p_ind = p_ind + 1

      IF p_ind > 100 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
      
       
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Não há contratos, para os parãmetros informados !'
      CALL log0030_mensagem(p_msg,'exclamation')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_aprovada TO sr_aprovada.*
   
   RETURN TRUE
         
END FUNCTION
       
      
      
      
      
      
      
      
      
          