#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1208                                                 #
# OBJETIVO: GRADE DE APROVAÇÃO DE NOTAS E CONTRATOS                 #
# AUTOR...: ACEEX - BL                                              #
# DATA....: 29/07/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
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
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_erro               CHAR(10)

END GLOBALS

DEFINE p_tem_aprov          SMALLINT

DEFINE p_tela          RECORD
       cod_empresa     CHAR(02),
       num_aviso_rec   INTEGER,
       num_nf          INTEGER,
       ser_nf          CHAR(03),
       ssr_nf          INTEGER,
       cod_uni_funcio  CHAR(10),
       fornecedor      CHAR(40)
END RECORD

DEFINE pr_nivel ARRAY[30] OF RECORD
       cod_nivel_autorid  CHAR(03),
       den_nivel_autorid  CHAR(30),
       hierarquia         INTEGER,
       nom_usuario_aprov  CHAR(08),
       dat_aprovacao      DATE,
       hor_aprovacao      CHAR(08)
END RECORD       

DEFINE p_parametro   RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1208-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET p_parametro.num_programa = 'POL1208'
   LET p_parametro.cod_empresa = p_cod_empresa
   LET p_parametro.usuario = p_user
      
   IF p_status = 0 THEN
      CALL pol1208_menu()
   END IF
   
END MAIN

#-----------------------#
 FUNCTION pol1208_menu()#
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1208") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1208 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela"
         LET p_opcao = 'C'
         CALL pol1208_consultar() RETURNING p_ies_cons
         IF p_ies_cons THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            CALL pol1208_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Excluir" "Exclui o AR da grade de aprovação"
         IF p_ies_cons THEN
            LET p_opcao = 'E'
            CALL pol1208_excluir() RETURNING p_status
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso !!!'
               LET p_ies_cons = FALSE
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR 'Informe previamente os parâmetros'
            NEXT OPTION 'Consultar'
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1208_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1208

END FUNCTION

#------------------------#
 FUNCTION pol1208_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1208_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#---------------------------#
FUNCTION pol1208_consultar()#
#---------------------------#

   CALL pol1208_limpa_tela()
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
            
      AFTER FIELD num_aviso_rec

         IF p_tela.num_aviso_rec IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD num_aviso_rec   
         END IF
         
         IF NOT pol1208_le_nf() THEN
            NEXT FIELD num_aviso_rec
         END IF
         
         DISPLAY BY NAME p_tela.*

      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF NOT pol1208_monta_grade() THEN
               NEXT FIELD num_aviso_rec
            END IF
         END IF
                            
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#------------------------#
 FUNCTION pol1208_le_nf()#
#------------------------#

   DEFINE p_num_ar  INTEGER,
          p_cod_uni CHAR(10)
   
   LET p_num_ar = p_tela.num_aviso_rec
   
   SELECT n.num_nf, 
          n.ser_nf,
          n.ssr_nf,  
          f.raz_social    
     INTO p_tela.num_nf, 
          p_tela.ser_nf, 
          p_tela.ssr_nf, 
          p_tela.fornecedor
     FROM nf_sup n, fornecedor f
    WHERE n.cod_empresa = p_cod_empresa
      AND n.num_aviso_rec = p_num_ar
      AND f.cod_fornecedor = n.cod_fornecedor

   IF STATUS = 100 THEN
      ERROR 'Aviso de recebimento inexitente!'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','nf_sup')
         RETURN FALSE
      END IF
   END IF

   SELECT parametro_texto
     INTO p_cod_uni
     FROM sup_par_ar
    WHERE empresa = p_cod_empresa
      AND aviso_recebto = p_num_ar
      AND seq_aviso_recebto = 0
      AND parametro = "secao_resp_aprov"

   IF STATUS <> 0 THEN
      LET p_tela.cod_uni_funcio = ''
   ELSE 
      LET p_tela.cod_uni_funcio = p_cod_uni
   END IF
     
   RETURN TRUE
          
END FUNCTION 

#-----------------------------#
FUNCTION pol1208_monta_grade()#
#-----------------------------#

   LET p_index = 1
   LET p_tem_aprov = FALSE
   
   DECLARE cq_aprov_ar CURSOR FOR
    SELECT nom_usuario_aprov,
           cod_nivel_autorid,
           hierarquia,
           dat_aprovacao,
           hor_aprovacao
      FROM aprov_ar_265
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec
     ORDER BY hierarquia DESC
   
   FOREACH cq_aprov_ar INTO
      pr_nivel[p_index].nom_usuario_aprov,
      pr_nivel[p_index].cod_nivel_autorid,
      pr_nivel[p_index].hierarquia,
      pr_nivel[p_index].dat_aprovacao,
      pr_nivel[p_index].hor_aprovacao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_APROV_AR')
         RETURN FALSE
      END IF
      
      SELECT den_nivel_autorid
        INTO pr_nivel[p_index].den_nivel_autorid
        FROM nivel_autorid_265
       WHERE cod_empresa = p_cod_empresa
         AND cod_nivel_autorid = pr_nivel[p_index].cod_nivel_autorid
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','NIVEL_AUTORID_265')
         LET pr_nivel[p_index].den_nivel_autorid = ''
      END IF

      IF pr_nivel[p_index].nom_usuario_aprov IS NULL OR
         pr_nivel[p_index].nom_usuario_aprov = ' ' THEN
      ELSE
         LET p_tem_aprov = TRUE
      END IF
      
      LET p_index = p_index + 1

   END FOREACH

   IF p_index = 1 THEN
      LET p_msg = 'AR informado não está\n',
            'na grade de aprovação.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   CALL SET_COUNT(p_index - 1)
   
   IF p_index > 8 THEN
      DISPLAY ARRAY pr_nivel TO sr_nivel.*
   ELSE
      INPUT ARRAY pr_nivel 
         WITHOUT DEFAULTS FROM sr_nivel.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1208_excluir()#
#-------------------------#

   IF p_tem_aprov THEN
      LET p_msg = 'AR com aprovações não pode\n',
          'ser excluido da grade.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET p_msg = 'Confirma a exclusão do AR\n',
        'da grade de arovação?'

   IF NOT log0040_confirm(20,25,p_msg) THEN
      RETURN FALSE
	 END IF
	 
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1208_grava_tabs() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1208_grava_tabs()#
#----------------------------#

   UPDATE nf_sup
      SET ies_incl_cap = 'X'
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','nf_sup')
      RETURN FALSE
   END IF
   
   DELETE FROM nfe_aprov_265
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','nfe_aprov_265')
      RETURN FALSE
   END IF

   DELETE FROM aprov_ar_265
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','aprov_ar_265')
      RETURN FALSE
   END IF

   LET p_parametro.texto = 'EXCLUSAO DO AR ', p_tela.num_aviso_rec, 
         ' DA GRADE DE APROVACAO'
   CALL pol1161_grava_auadit(p_parametro) RETURNING p_status
   
   RETURN TRUE

END FUNCTION
   