#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1218                                                 #
# OBJETIVO: CONSULTA GRADE DE APROVAÇÃO DE AR                       #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 19/09/13                                                #
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
          p_ies_aprov          SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01)
         
  
END GLOBALS

DEFINE p_tela     RECORD
       num_aviso_rec   INTEGER,
       num_nf          INTEGER,
       ser_nf          CHAR(03),
       ssr_nf          INTEGER,
       ies_incl_cap    CHAR(01),
       cod_fornecedor  CHAR(15),
       raz_social      CHAR(40)
END RECORD

DEFINE pr_grade             ARRAY[50] OF RECORD
       hierarquia           INTEGER,
       cod_nivel_autorid    CHAR(02),
       den_nivel_autorid    CHAR(30),
       nom_usuario_aprov    CHAR(08),
       dat_aprovacao        DATE,
       hor_aprovacao        CHAR(08)
END RECORD
          
DEFINE parametro     RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD

DEFINE p_ies_adm     SMALLINT

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1218-10.02.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET parametro.num_programa = 'POL1218'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user
      
   IF p_status = 0 THEN
      CALL pol1218_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1218_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1218") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1218 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   SELECT nom_usuario
     FROM usuario_adim_265
    WHERE nom_usuario = p_user
   
   IF STATUS = 0 THEN
      LET p_ies_adm = TRUE
   ELSE
      LET p_ies_adm = FALSE
   END IF
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1218_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1218_exclusao() RETURNING p_status
            IF p_status THEN
               CALL pol1218_limpa_tela()
               LET p_ies_cons = FALSE
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1218_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1218

END FUNCTION

#-----------------------#
 FUNCTION pol1218_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')

END FUNCTION

#----------------------------#
FUNCTION pol1218_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
END FUNCTION
      
#--------------------------#
 FUNCTION pol1218_consulta()
#--------------------------#

   CALL pol1218_limpa_tela()
   LET INT_FLAG = FALSE
   LET p_ies_cons = FALSE
   INITIALIZE p_tela TO NULL
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

   AFTER FIELD num_aviso_rec
      
      IF p_tela.num_aviso_rec IS NULL THEN
         ERROR 'Campo com preenchimento obrigatório.'
         NEXT FIELD num_aviso_rec
      END IF
      
      SELECT num_nf, 
             ser_nf, 
             ssr_nf,
             cod_fornecedor,
             ies_incl_cap 
        INTO p_tela.num_nf,          
             p_tela.ser_nf,        
             p_tela.ssr_nf,        
             p_tela.cod_fornecedor,
             p_tela.ies_incl_cap
        FROM nf_sup
       WHERE cod_empresa = p_cod_empresa
         AND num_aviso_rec = p_tela.num_aviso_rec
      
      IF STATUS = 100 THEN
         ERROR 'AR inexistente.'
         NEXT FIELD num_aviso_rec
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','nf_sup')
            RETURN FALSE
         END IF
      END IF

      IF NOT pol1218_exibe_dados() THEN
         RETURN FALSE
      END IF
      
      IF p_count = 0 THEN
         ERROR 'Esse AR não está na grade de aprovação.'
         NEXT FIELD num_aviso_rec
      END IF
            
   END INPUT
   
   IF INT_FLAG THEN
      CALL pol1218_limpa_tela()
      RETURN FALSE
   END IF
      
   LET p_ies_cons = TRUE
               
   RETURN TRUE   
      
END FUNCTION

#------------------------------#
 FUNCTION pol1218_exibe_dados()
#------------------------------#

   SELECT raz_social
     INTO p_tela.raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_tela.cod_fornecedor

   IF STATUS <> 0 THEN
      LET p_tela.raz_social = ''
      CALL log003_err_sql('SELECT','fornecedor')
   END IF
   
   DISPLAY BY NAME p_tela.*

   LET p_ind = 1
   LET p_ies_aprov = FALSE
   INITIALIZE pr_grade TO NULL
   
   DECLARE cq_grade CURSOR FOR
    SELECT hierarquia,        
           cod_nivel_autorid, 
           nom_usuario_aprov, 
           dat_aprovacao,     
           hor_aprovacao     
      FROM aprov_ar_265 
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec

   FOREACH cq_grade INTO
      pr_grade[p_ind].hierarquia,       
      pr_grade[p_ind].cod_nivel_autorid,
      pr_grade[p_ind].nom_usuario_aprov,
      pr_grade[p_ind].dat_aprovacao,    
      pr_grade[p_ind].hor_aprovacao     

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_grade')
         RETURN FALSE
      END IF
      
      SELECT den_nivel_autorid
        INTO pr_grade[p_ind].den_nivel_autorid 
        FROM nivel_autorid_265
       WHERE cod_empresa = p_cod_empresa
         AND cod_nivel_autorid = pr_grade[p_ind].cod_nivel_autorid
         
      IF STATUS = 100 THEN
         LET pr_grade[p_ind].den_nivel_autorid = ''
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','nivel_autorid_265')
            RETURN FALSE
         END IF
      END IF
      
      IF pr_grade[p_ind].nom_usuario_aprov IS NULL OR
         pr_grade[p_ind].nom_usuario_aprov = ' ' THEN
      ELSE
         LET p_ies_aprov = TRUE
      END IF
      
      LET p_ind = p_ind + 1
   
   END FOREACH
   
   LET p_count = p_ind - 1
   
   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_grade WITHOUT DEFAULTS FROM sr_grade.*
      BEFORE INPUT
      EXIT INPUT
   END INPUT
      
   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol1218_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT * 
      FROM aprov_ar_265  
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","aprov_ar_265")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1218_exclusao()
#--------------------------#

   IF p_tela.ies_incl_cap = 'X' THEN
   ELSE
      LET p_msg = 'O status atual da NF não\n permite sua exclusão da grade'
      CALL log0030_mensagem(p_msg, 'exclamation')
      RETURN FALSE
   END IF

   IF NOT p_ies_adm THEN
      IF p_ies_aprov THEN
         LET p_msg = 'AR com aprovações não pode ser excluído da grade.'
         CALL log003_err_sql(p_msg,'exclamation')
         RETURN FALSE
      END IF
   END IF
                  
   IF p_ies_aprov THEN
      LET p_msg = 'AR já possui aprovação.\n Excluir mesmo assim?'
   ELSE
      LET p_msg = 'Deseja mesmo excluir\n esse AR da grade?'
   END IF

   IF NOT log0040_confirm(20,25,p_msg) THEN
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1218_prende_registro() THEN

      LET parametro.texto = 'EXCLUSAO DO AR ', p_tela.num_aviso_rec, ' DA GRADE DE APROVACAO '
      CALL pol1161_grava_auadit(parametro) RETURNING p_status
      
      IF pol1218_delete_grade() THEN
         LET p_retorno = TRUE
      END IF
   
   END IF

   CLOSE cq_prende

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#------------------------------#
FUNCTION pol1218_delete_grade()#
#------------------------------#

   DELETE FROM aprov_ar_265  
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
         
   IF STATUS <> 0 THEN               
      CALL log003_err_sql("DELETE","aprov_ar_265")
      RETURN FALSE
   END IF
   
   DELETE FROM nfe_aprov_265  
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
         
   IF STATUS <> 0 THEN               
      CALL log003_err_sql("DELETE","nfe_aprov_265")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   

#-------------------------------- FIM DE PROGRAMA BL-----------------------------#
