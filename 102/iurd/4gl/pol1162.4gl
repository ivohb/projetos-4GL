#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1162                                                 #
# OBJETIVO: CONSULTA DE ERROS NA GERAÇÃO DA GRADE DE APROVAÇÃO DE AR#
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 18/09/12                                                #
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
          p_excluiu            SMALLINT
   
   DEFINE p_dat_ini            DATETIME YEAR TO DAY,
          p_dat_fim            DATETIME YEAR TO DAY,
          p_dat_proces         DATETIME YEAR TO DAY,
          p_hor_proces         DATETIME HOUR TO SECOND,
          p_dat_procesa        DATETIME YEAR TO DAY,
          p_hor_procesa        DATETIME HOUR TO SECOND,
          p_query              CHAR(3000)

   DEFINE pr_erro              ARRAY[50] OF RECORD
          empresa              CHAR(02),
          estado               CHAR(02),
          num_ar               INTEGER,
          den_erro             CHAR(76)
   END RECORD
         
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1162-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      CALL pol1162_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1162_menu()
#----------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11621") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11621 AT 09,13 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1162") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1162 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela."
         LET p_ies_cons = FALSE
         IF pol1162_consulta() THEN
            CALL pol1162_exibe_dados() RETURNING p_status
            IF p_status THEN
               ERROR 'Consulta efetuada com sucesso !!!'
               LET p_ies_cons = TRUE
               NEXT OPTION "Seguinte" 
            ELSE
               ERROR 'consulta cancela !!!'
            END IF
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1162_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1162_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      {COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1162_listagem()}
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1162_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1162

END FUNCTION

#-----------------------#
 FUNCTION pol1162_sobre()
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
FUNCTION pol1162_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
FUNCTION pol1162_consulta()#
#--------------------------#

   CURRENT WINDOW IS w_pol11621
   
   LET INT_FLAG = FALSE
      
   INITIALIZE p_dat_ini, p_dat_fim TO NULL
   
   INPUT p_dat_ini, p_dat_fim
      WITHOUT DEFAULTS FROM dat_ini, dat_fim
      
      AFTER FIELD dat_fim   
         IF p_dat_fim IS NOT NULL THEN
            IF p_dat_ini IS NOT NULL THEN
               IF p_dat_ini > p_dat_fim THEN
                  ERROR "Data Inicial nao pode ser maior que data Final"
                  NEXT FIELD dat_ini
               END IF 
               IF p_dat_fim - p_dat_ini > 720 THEN 
                  ERROR "Periodo nao pode ser maior que 720 Dias"
                  NEXT FIELD dat_ini
               END IF 
            END IF
         END IF

   END INPUT

   CURRENT WINDOW IS w_pol1162
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   LET p_query  = 
       "SELECT dat_ini_process, hor_ini_process ",
       "  FROM erro_pol1159_265 ",
       " WHERE 1 = 1 "

   IF p_dat_ini IS NOT NULL THEN
      LET p_query  = p_query CLIPPED,
          " AND dat_ini_process >= '",p_dat_ini,"' "
   END IF

   IF p_dat_fim IS NOT NULL THEN
      LET p_query  = p_query CLIPPED,
          " AND dat_ini_process <= '",p_dat_fim,"' "
   END IF
   
   LET p_query = p_query CLIPPED, " ORDER BY dat_ini_process, hor_ini_process "
   
   PREPARE var_query FROM p_query   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_dat_proces, p_hor_proces

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#------------------------------#
 FUNCTION pol1162_exibe_dados()
#------------------------------#
   
   DEFINE p_data DATE
   
   LET p_data = p_dat_proces
   
   DISPLAY p_data TO dat_proces
   DISPLAY p_hor_proces TO hor_proces
   
   IF NOT pol1162_carrega_erros() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol1162_carrega_erros()
#---------------------------------#
   
   INITIALIZE pr_erro TO NULL
   
   LET p_index = 1
   
   DECLARE cq_array CURSOR FOR
   
    SELECT cod_empresa,
           num_aviso_rec,
           den_erro
      FROM erro_pol1159_265
     WHERE dat_ini_process = p_dat_proces
       AND hor_ini_process = p_hor_proces
     ORDER BY cod_empresa, num_aviso_rec
     
   FOREACH cq_array
      INTO pr_erro[p_index].empresa,
           pr_erro[p_index].num_ar,
           pr_erro[p_index].den_erro
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "cursor: cq_array")
         RETURN FALSE
      END IF
      
      SELECT uni_feder
        INTO pr_erro[p_index].estado
        FROM empresa
       WHERE cod_empresa = pr_erro[p_index].empresa
   
      IF STATUS <> 0 THEN
         LET pr_erro[p_index].estado = ''
      END IF
            
      LET p_index = p_index + 1
      
      IF p_index > 50 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   IF p_index > 12 THEN
      DISPLAY ARRAY pr_erro TO sr_erro.*
   ELSE
      INPUT ARRAY pr_erro WITHOUT DEFAULTS FROM sr_erro.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF
   
   RETURN TRUE
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol1162_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_dat_procesa = p_dat_proces
   LET p_hor_procesa = p_hor_proces

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_dat_proces, p_hor_proces
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_dat_proces, p_hor_proces
         
      END CASE

      IF STATUS = 0 THEN
         
         IF p_dat_proces = p_dat_procesa AND p_hor_proces = p_hor_procesa THEN
            CONTINUE WHILE
         END IF
         
         LET p_count = 0
         
         SELECT COUNT(cod_empresa)
           INTO p_count
           FROM erro_pol1159_265
          WHERE dat_ini_process = p_dat_proces
            AND hor_ini_process = p_hor_proces
                        
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "erro_pol1159_265")
         END IF
         
         IF p_count > 0 THEN   
            CALL pol1162_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_dat_proces = p_dat_procesa
            LET p_hor_proces = p_hor_procesa
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION
