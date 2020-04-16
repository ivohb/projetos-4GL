#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO TRIM X LOGIX                                 #
# PROGRAMA: pol0830                                                 #
# OBJETIVO: APONTAMENTOS CRITICADOS - TRIMPAPEL                     #
# AUTOR...: IVO HB                                                  #
# DATA....: 03/10/2007                                              #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_item           LIKE item.den_item,
          p_den_empresa        LIKE empresa.cod_empresa,
          p_num_op             LIKE ordens.num_ordem
          
   DEFINE p_retorno            SMALLINT,
          p_salto              SMALLINT,
          p_imprimiu           SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                INTEGER,
          p_dat_consumo        DATE,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(02),
          p_8lpp               CHAR(02),
          p_caminho            CHAR(080),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),
          p_opcao              CHAR(01),
          p_num_seq_apont      INTEGER,
          p_msg                CHAR(150),
          p_dat_proces         DATE

END GLOBALS

DEFINE p_tela                  RECORD
       dat_ini                 DATE,
       dat_fim                 DATE,
       num_ordem               INTEGER,
       cod_item                CHAR(15)
END RECORD
        
DEFINE pr_inconsist            ARRAY[2000] OF RECORD
       numordem                INTEGER,
       coditem                 CHAR(15),
       codmaquina              CHAR(04),
       datproducao             CHAR(19),
       tipmovto                CHAR(01),
       pesobalanca             DECIMAL(9,3),
       numlote                 CHAR(15)
END RECORD

DEFINE pr_mensagem             ARRAY[2000] OF RECORD
       mensagem                CHAR(150)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol0830-10.02.00  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0830.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
   
   LET p_status = 0; LET p_cod_empresa = '02'; LET p_user = 'admlog'
   
   IF p_status = 0  THEN
      CALL pol0830_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0830_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0830") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08301 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Inconsistência" "Apontamentos inconsistentes"
         CALL pol0830_inconsistencia() RETURNING p_status
         IF NOT p_status THEN
            CALL pol0830_limpa_tela()
            ERROR 'Operação cancelada.'
         ELSE
            ERROR 'Operação efetuada com sucesso.'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0830

END FUNCTION

#---------------------------#
FUNCTION pol0830_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-------------------------------#
FUNCTION pol0830_inconsistencia()
#-------------------------------#

   INITIALIZE p_tela TO NULL
   CALL pol0830_limpa_tela()
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS 
      
      AFTER INPUT

         IF INT_FLAG THEN
            CALL pol0830_limpa_tela()
            RETURN FALSE
         END IF
         
         IF p_tela.dat_ini IS NOT NULL AND                
            p_tela.dat_fim   IS NOT NULL THEN
            IF p_tela.dat_fim < p_tela.dat_ini THEN
               LET p_msg = "A data inicial não pode\n ser maior que a data final."
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD dat_ini
            END IF
         END IF
         
   END INPUT

   CALL pol647_le_inconsist() RETURNING p_status
  
   RETURN  p_status
   
END FUNCTION

#----------------------------#
FUNCTION pol647_le_inconsist()
#----------------------------#
   
   DEFINE p_query           CHAR(3000),
          p_dat_hor_proces  CHAR(19),
          p_men_erro        CHAR(150)
          
   SELECT dat_hor_proces,
          mensagem
     INTO p_dat_hor_proces,
          p_men_erro
     FROM apont_msg_885
    WHERE cod_empresa = p_cod_empresa
   
   DISPLAY p_dat_hor_proces TO dat_hor_proces
   DISPLAY p_men_erro TO men_erro   
   
   LET p_index = 1
   LET p_count = 0

   INITIALIZE pr_inconsist TO NULL

   LET p_query = 
       "SELECT DISTINCT a.numordem, a.coditem, a.codmaquina, datproducao, ",
       " a.tipmovto, a.pesobalanca, a.numlote, b.mensagem ",
       " FROM apont_papel_885 a, apont_erro_885 b ",
       " WHERE a.codempresa  = '",p_cod_empresa,"' ",
       "   AND a.codempresa = b.codempresa ",
       "   AND a.numsequencia = b.numsequencia ",
       "   AND a.statusregistro = '2' "

   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND DATE(a.datiniproducao) >= '",p_tela.dat_ini,"' "
   END IF
   
   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND DATE(a.datproducao) <= '",p_tela.dat_fim,"' "
   END IF

   IF p_tela.num_ordem IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.numordem = ", p_tela.num_ordem
   END IF

   IF p_tela.cod_item IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.coditem = '",p_tela.cod_item,"' "
   END IF

   LET p_query = p_query CLIPPED, " ORDER BY a.numordem"  

   PREPARE var_query FROM p_query   
   DECLARE cq_inconsist CURSOR FOR var_query
   
   FOREACH cq_inconsist INTO 
           pr_inconsist[p_index].numordem,     
           pr_inconsist[p_index].coditem,      
           pr_inconsist[p_index].codmaquina,   
           pr_inconsist[p_index].datproducao,       
           pr_inconsist[p_index].tipmovto,     
           pr_inconsist[p_index].pesobalanca,      
           pr_inconsist[p_index].numlote,
           pr_mensagem[p_index].mensagem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_inconsist')
         EXIT FOREACH
      END IF      
              
      LET p_index = p_index + 1

      IF p_index > 2000 THEN
         LET p_count = p_index - 1
         ERROR 'Limite de Linhas da pesquisa Ultrapassou ', p_count
         EXIT FOREACH
      END IF

   END FOREACH
   
   IF p_index = 1 THEN
      LET p_msg = 'Não há dados para os\n parâmetros informados.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN RETURN TRUE
   END IF
  
   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY pr_inconsist TO sr_inconsist.*
      
      BEFORE ROW
      
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE() 
         LET p_msg = pr_mensagem[p_index].mensagem
         DISPLAY p_msg TO mensagem
         
   END DISPLAY
   
   RETURN TRUE   

END FUNCTION

