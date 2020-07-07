#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1173                                                 #
# OBJETIVO: CONSULTA DE ERROS DO POL1159                            #
# AUTOR...: IVO                                                     #
# DATA....: 18/10/12                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_ar             INTEGER,
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
          p_opcao              CHAR(01)
         
END GLOBALS
  
DEFINE pr_erro              ARRAY[1000] OF RECORD
       cod_empresa          CHAR(02),  
       num_aviso_rec        INTEGER,
       num_nf               INTEGER,
       den_erro             CHAR(76)    
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1173-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1173_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1173_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1173") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1173 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO empresa_log
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1173_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      #COMMAND "Listar" "Listagem dos registros cadastrados."
      #   CALL pol1173_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1173_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1173

END FUNCTION

#--------------------------#
FUNCTION pol1173_consulta()
#--------------------------#

   DEFINE sql_stmt CHAR(800)
   
   INITIALIZE p_num_ar TO NULL
   
   INPUT p_num_ar WITHOUT DEFAULTS FROM num_ar
      
      AFTER FIELD num_ar
         
         IF p_num_ar IS NOT NULL THEN
            SELECT COUNT(num_aviso_rec)
              INTO p_count
              FROM erro_pol1159_265
             WHERE num_aviso_rec = p_num_ar
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','erro_pol1159_265')
               NEXT FIELD num_ar
            END IF
            
            IF p_count = 0 THEN
               LET p_msg = 'AR sem mensagens de erro!'
               CALL log0030_mensagem(p_msg,'excla')
               NEXT FIELD num_ar
            END IF
         END IF
      
   END INPUT
   
   LET p_ind = 1
   
   LET sql_stmt = 
    "SELECT a.cod_empresa, a.num_aviso_rec, b.num_nf, a.den_erro ",
    "  FROM erro_pol1159_265 a, nf_sup b ",
    " WHERE a.cod_empresa = b.cod_empresa ",
    "   AND a.num_aviso_rec = b.num_aviso_rec "
    
   IF p_num_ar IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND a.num_aviso_rec = '",p_num_ar,"' "
   END IF
     
   LET sql_stmt = sql_stmt CLIPPED, " ORDER BY a.cod_empresa, a.num_aviso_rec "
   
   PREPARE var_query FROM sql_stmt   
      
   DECLARE cq_erro CURSOR FOR var_query
   
   FOREACH cq_erro INTO pr_erro[p_ind].*
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_erro')           
         RETURN FALSE
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 1000 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou!','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
      
   DISPLAY ARRAY pr_erro TO sr_erro.*
   
END FUNCTION
                       
#-------------------------------- FIM DE PROGRAMA -----------------------------#
