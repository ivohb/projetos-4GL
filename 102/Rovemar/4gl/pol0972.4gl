#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO EGA                                          #
# PROGRAMA: pol0972                                                 #
# MODULOS.: pol0972-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: MANUTENCAO ITENS CRITICADOS - IMPORTAÇÃO EGA x LOGIX    #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 18/08/2006                                              #
# ALTERADO: 05/08/2008 por ANA PAULA versao 24                      #
# 11/09/09: Coloquei distinct nos select das mensagens - Ivo        #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_op             LIKE rovapont_ega_man912.num_op,
          p_chav_seq           LIKE rovapont_ega_man912.chav_seq,
          p_processando        LIKE rovproc_apont_man912.processando,
          p_hora_ini           LIKE rovproc_apont_man912.hor_ini,
          p_hor_atu            LIKE rovproc_apont_man912.hor_ini,
          p_time               DATETIME HOUR TO SECOND,
          p_msg                CHAR(500),
          p_hor_proces         CHAR(10),
          p_qtd_segundo        INTEGER,
          p_resp               CHAR(01),
          P_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          sql_stmt             CHAR(600),
          where_clause         CHAR(300),
          p_rowid              INTEGER,
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
          p_caminho            CHAR(080)
          
   DEFINE p_dat_atualiz        LIKE rovman_apont_454.dat_atualiz

   DEFINE p_rovapont_ega_man912   RECORD LIKE rovapont_ega_man912.*,
          p_rovapont_ega_man912a  RECORD LIKE rovapont_ega_man912.*
          
   DEFINE p_rovapont_hist_man912   RECORD LIKE rovapont_hist_man912.*,
          p_rovapont_hist_man912a  RECORD LIKE rovapont_hist_man912.*

   DEFINE p_rovman_apont_454   RECORD LIKE rovman_apont_454.*,
          p_rovman_apont_454a  RECORD LIKE rovman_apont_454.*

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 3
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0972-12.00.05  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0972.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0972_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0972_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09721") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09721 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND 'Erros' 'Exibe os Erros que ocorreram na Importação.'
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL log085_transacao("BEGIN")
         IF pol0972_tab_livre() THEN
            CALL log085_transacao("COMMIT")
            CALL pol0972_consulta_erros()
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      COMMAND 'Listar' 'Lista os erros que ocorreram na Importação.'
         HELP 001
         MESSAGE ''
         IF log005_seguranca(p_user,'MANUFAT','pol0972','IN') THEN
            CALL pol0972_lista()
         END IF
      COMMAND 'Pré_apontamento' 'Permite modificação das críticas do pré_apontamento.'
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL log085_transacao("BEGIN")
         IF pol0972_tab_livre() THEN
            CALL log085_transacao("COMMIT")
            CALL pol0972_pre_aponta()
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      COMMAND 'Apontamento final' 'Permite modificação das críticas do pré_apontamento.'
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL log085_transacao("BEGIN")
         IF pol0972_tab_livre() THEN
            CALL log085_transacao("COMMIT")
            CALL pol0972_apont_final()
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      COMMAND KEY ("T") "aponTa" 'Efetua o apontamento das ordens.'
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0972_tab_livre() THEN
        
         	CALL pol0972_integra_apont()
         
         END IF
      COMMAND KEY ("S") "Sobre" "Exibe a versão do programa"
         CALL pol0972_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol09721

END FUNCTION

#-----------------------#
 FUNCTION pol0972_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------#
 FUNCTION pol0972_consulta_erros()
#--------------------------------#
   DEFINE l_ind           SMALLINT,
          s_ind           SMALLINT,
          p_tem_dados     SMALLINT

   DEFINE p_op            RECORD
          ordem_producao  LIKE rovapont_erro_man912.ordem_producao
   END RECORD
   
   DEFINE la_erro_man912  ARRAY[5000] OF RECORD
          num_ordem       INTEGER,
          cod_operac      CHAR(5),
          msg             CHAR(100)
   END RECORD                           
   
   INPUT BY NAME p_op.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD ordem_producao
         INITIALIZE p_op.ordem_producao TO NULL
      
      AFTER FIELD ordem_producao
         IF p_op.ordem_producao is not null THEN
            SELECT COUNT(ordem_producao)
              INTO p_count
              FROM rovapont_erro_man912
             WHERE empresa = p_cod_empresa
               AND ordem_producao = p_op.ordem_producao
            IF p_count = 0 THEN
               ERROR 'Ordem inexistente !!!'
               NEXT FIELD ordem_producao
            END IF
         END IF
   
   END INPUT

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET l_ind = 1
   LET p_tem_dados = FALSE
   
   IF p_op.ordem_producao is null THEN
      LET sql_stmt =  "SELECT DISTINCT ordem_producao, operacao, texto_erro ",
                      "  FROM rovapont_erro_man912 ",
                      " WHERE empresa = '",p_cod_empresa,"' ",
                      " ORDER BY ordem_producao"
   ELSE
      LET sql_stmt =  "SELECT DISTINCT ordem_producao, operacao, texto_erro ",
                      "  FROM rovapont_erro_man912 ",
                      " WHERE empresa = '",p_cod_empresa,"' ",
                      "   AND ordem_producao = '",p_op.ordem_producao,"' "
   END IF      
   
   PREPARE v_query FROM sql_stmt   
   DECLARE cq_erro CURSOR FOR v_query
 
   FOREACH cq_erro INTO la_erro_man912[l_ind].*
      LET l_ind = l_ind + 1
      LET p_tem_dados = TRUE
   END FOREACH
   
   IF NOT p_tem_dados THEN
      ERROR "Nenhum Erro foi encontrado !!!"
      RETURN
   END IF

   CALL SET_COUNT(l_ind - 1)

   DISPLAY ARRAY la_erro_man912 TO s_erro.*

   LET l_ind = ARR_CURR()
   LET s_ind = SCR_LINE()
 
   LET p_ies_cons = FALSE
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

  END FUNCTION

#-----------------------------#
 FUNCTION pol0972_pre_aponta()
#-----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0972") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0972 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consulta" "Consulta Dados da Tabela"
         HELP 001
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0972_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0972_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0972_exportacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exportação"
         END IF 
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0972_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0972_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 006
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0972","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0972_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0972.tmp'
                     START REPORT pol0972_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0972_relat TO p_nom_arquivo
               END IF
               CALL pol0972_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0972_relat   
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 007
         MESSAGE ""
         LET INT_FLAG = 0
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0972

END FUNCTION

#--------------------------#
 FUNCTION pol0972_consulta()
#--------------------------#
   
   DEFINE l_op     INTEGER
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_rovapont_ega_man912a.* = p_rovapont_ega_man912.*
   
   LET p_rovapont_ega_man912.num_op = NULL
   
   INPUT p_rovapont_ega_man912.num_op 
      WITHOUT DEFAULTS  FROM num_op

      AFTER FIELD num_op
         IF p_rovapont_ega_man912.num_op IS NOT NULL THEN
            LET l_op = p_rovapont_ega_man912.num_op
            LET p_rovapont_ega_man912.num_op =  func002_strzero(l_op, 9)
         END IF
         
   END INPUT 
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0972

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_rovapont_ega_man912.* = p_rovapont_ega_man912a.*
      CALL pol0972_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   IF p_rovapont_ega_man912.num_op IS NULL THEN
      LET sql_stmt = "SELECT chav_seq, num_op FROM rovapont_ega_man912 ",
                     " ORDER BY num_op, chav_seq "
   ELSE
      
      LET sql_stmt = "SELECT chav_seq, num_op FROM rovapont_ega_man912 ",
                     " WHERE num_op = '",p_rovapont_ega_man912.num_op,"' ",
                     " ORDER BY num_op, chav_seq "
   END IF

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_chav_seq, p_num_op
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      SELECT *
        INTO p_rovapont_ega_man912.*
        FROM rovapont_ega_man912
       WHERE chav_seq = p_chav_seq
      CALL pol0972_exibe_dados()
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0972_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0972
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_rovapont_ega_man912.* TO NULL
      CALL pol0972_exibe_dados()
   END IF

   INPUT BY NAME p_rovapont_ega_man912.* 
      WITHOUT DEFAULTS  

      AFTER FIELD num_op

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0972

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0972_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_rovapont_ega_man912.*
   
END FUNCTION


#-----------------------------------#
 FUNCTION pol0972_cursor_for_update()
#-----------------------------------#

  # IF pol0972_apontando() THEN
  #   RETURN FALSE
   #END IF

   WHENEVER ERROR CONTINUE
   
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *
     INTO p_rovapont_ega_man912.*                                              
     FROM rovapont_ega_man912  
    WHERE chav_seq = p_chav_seq FOR UPDATE 

   CALL log085_transacao("BEGIN")   
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","rovapont_ega_man912")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0972_modificacao()
#-----------------------------#

   IF pol0972_cursor_for_update() THEN
      LET p_rovapont_ega_man912a.* = p_rovapont_ega_man912.*
      IF pol0972_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         LET p_rovapont_ega_man912.num_versao = p_rovapont_ega_man912.num_versao + 1
         UPDATE rovapont_ega_man912 
            SET rovapont_ega_man912.* = p_rovapont_ega_man912.*
          WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            IF pol0972_insere_hist() THEN
               CALL log085_transacao("COMMIT")
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            ELSE
               CALL log085_transacao("ROLLBACK")
               ERROR "Modificação cancelada !!!"
            END IF
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","rovapont_ega_man912")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_rovapont_ega_man912.* = p_rovapont_ega_man912a.*
         ERROR "Modificacao Cancelada"
         CALL pol0972_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0972_insere_hist()
#-----------------------------#
   
   LET p_rovapont_hist_man912.chav_seq = p_rovapont_ega_man912.chav_seq
   LET p_rovapont_hist_man912.num_versao = p_rovapont_ega_man912.num_versao
   LET p_rovapont_hist_man912.dat_producao = p_rovapont_ega_man912.dat_producao
   LET p_rovapont_hist_man912.cod_item = p_rovapont_ega_man912.cod_item
   LET p_rovapont_hist_man912.num_op = p_rovapont_ega_man912.num_op
   LET p_rovapont_hist_man912.cod_operac = p_rovapont_ega_man912.cod_operac
   LET p_rovapont_hist_man912.cod_maquina = p_rovapont_ega_man912.cod_maquina
   LET p_rovapont_hist_man912.qtd_refugo = p_rovapont_ega_man912.qtd_refugo
   LET p_rovapont_hist_man912.qtd_boas = p_rovapont_ega_man912.qtd_boas
   LET p_rovapont_hist_man912.tip_mov = p_rovapont_ega_man912.tip_mov
   LET p_rovapont_hist_man912.mat_operador = p_rovapont_ega_man912.mat_operador
   LET p_rovapont_hist_man912.cod_turno = p_rovapont_ega_man912.cod_turno
   LET p_rovapont_hist_man912.hor_ini = p_rovapont_ega_man912.hor_ini
   LET p_rovapont_hist_man912.hor_fim = p_rovapont_ega_man912.hor_fim
   LET p_rovapont_hist_man912.cod_mov = p_rovapont_ega_man912.cod_mov
   LET p_rovapont_hist_man912.arq_orig = p_rovapont_ega_man912.arq_orig
   LET p_rovapont_hist_man912.situacao = NULL
   LET p_rovapont_hist_man912.usuario  = p_user
   LET p_rovapont_hist_man912.programa = 'pol0972'

   INSERT INTO rovapont_hist_man912
    VALUES(p_rovapont_hist_man912.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSAO","rovapont_hist_man912")
      RETURN FALSE
   END IF
           
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0972_exportacao()
#-----------------------------#

   IF pol0972_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         IF pol0972_atualiza_hist() THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_rovapont_ega_man912.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            CALL log085_transacao("ROLLBACK")
            ERROR "Exclusão cancelada !!!"
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF
        
END FUNCTION     

#-------------------------------#
FUNCTION pol0972_atualiza_hist()
#-------------------------------#

   PROMPT 'Excluir (A)pontamento da Tela ou (T)odos da Ordem ?' FOR p_resp
   
   IF p_resp MATCHES "[TtAa]" THEN
   ELSE
      ERROR 'Resposta Inválida !!!'
      RETURN FALSE
   END IF
   
   IF p_resp MATCHES "[Aa]" THEN
 
      DELETE FROM rovapont_ega_man912
       WHERE CURRENT OF cm_padrao

      IF STATUS = 0 THEN
         UPDATE rovapont_hist_man912
            SET situacao = 'D',
                usuario  = p_user,
                programa = 'pol0972'
          WHERE chav_seq   = p_chav_seq
            AND num_versao = p_rovapont_ega_man912.num_versao
    
         IF STATUS <> 0 THEN
            CALL log003_err_sql("UPDATE","rovapont_hist_man912")
            RETURN FALSE
         END IF
               
         DELETE FROM rovapont_erro_man912
          WHERE empresa = p_cod_empresa
            AND chav_seq = p_chav_seq
            AND ies_apont = 'P'
         IF STATUS <> 0 THEN
            CALL log003_err_sql("EXCLUSAO","rovapont_erro_man912")
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql("DELEÇÃO","APONT_AGA_MAN912")
         RETURN FALSE
      END IF
       
      RETURN TRUE
    
   END IF
   
   DECLARE cq_deleta CURSOR WITH HOLD FOR
    SELECT chav_seq,
           num_versao
      FROM rovapont_ega_man912
     WHERE num_op = p_num_op
    
   FOREACH cq_deleta INTO 
           p_rovapont_ega_man912.chav_seq,
           p_rovapont_ega_man912.num_versao
    
      UPDATE rovapont_hist_man912
         SET situacao = 'D',
             usuario  = p_user,
             programa = 'pol0972'
       WHERE chav_seq   = p_rovapont_ega_man912.chav_seq
         AND num_versao = p_rovapont_ega_man912.num_versao

      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDATE","rovapont_hist_man912")
         RETURN FALSE
      END IF

         DELETE FROM rovapont_erro_man912
          WHERE empresa = p_cod_empresa
            AND chav_seq = p_rovapont_ega_man912.chav_seq
            AND ies_apont = 'P'
         IF STATUS <> 0 THEN
            CALL log003_err_sql("EXCLUSAO","rovapont_erro_man912")
            RETURN FALSE
         END IF

   END FOREACH
           
   DELETE FROM rovapont_ega_man912
    WHERE num_op = p_num_op

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELEÇÃO","rovapont_ega_man912")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------------------------------#
 FUNCTION pol0972_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_rovapont_ega_man912a.* = p_rovapont_ega_man912.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_padrao INTO p_chav_seq, p_num_op
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_chav_seq, p_num_op
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_rovapont_ega_man912.* = p_rovapont_ega_man912a.* 
            EXIT WHILE
         END IF

        SELECT * 
           INTO p_rovapont_ega_man912.* 
           FROM rovapont_ega_man912
          WHERE chav_seq = p_chav_seq
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0972_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0972_emite_relatorio()
#-----------------------------------#
   LET p_count = 0
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   
   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
    
   DECLARE cq_apont CURSOR FOR
    SELECT * 
      FROM rovapont_ega_man912

   FOREACH cq_apont INTO p_rovapont_ega_man912.*
   
      OUTPUT TO REPORT pol0972_relat() 
  
     LET p_count = p_count + 1
     
  END FOREACH
 
END FUNCTION 

#----------------------#
 REPORT pol0972_relat()
#----------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 120, "PAG.: ", PAGENO USING "####&"
         PRINT COLUMN 001, 'pol0972',
               COLUMN 030, 'INTEGRACAO EGA X LOGIX - REGISTROS CRITICADOS',
               COLUMN 107, 'DATA: ', TODAY USING 'dd/mm/yyyy', ' ', TIME
               
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "-----------"
         PRINT
         PRINT COLUMN 001, 'DAT PROD        ITEM          ORDEM     OPER   MAQ    REFUGO      BOAS     T.MOV  OPERADOR    TURNO   HOR INI  HOR FIM     COD MOV'
         PRINT COLUMN 001, '--------   --------------   ---------   ----   ---   --------   --------   -----  --------    -----   -------  -------     -------'

      ON EVERY ROW

         PRINT COLUMN 001, p_rovapont_ega_man912.dat_producao,
               COLUMN 012, p_rovapont_ega_man912.cod_item,
               COLUMN 029, p_rovapont_ega_man912.num_op,
               COLUMN 041, p_rovapont_ega_man912.cod_operac,
               COLUMN 048, p_rovapont_ega_man912.cod_maquina,
               COLUMN 054, p_rovapont_ega_man912.qtd_refugo,
               COLUMN 065, p_rovapont_ega_man912.qtd_boas,
               COLUMN 078, p_rovapont_ega_man912.tip_mov,
               COLUMN 084, p_rovapont_ega_man912.mat_operador,
               COLUMN 097, p_rovapont_ega_man912.cod_turno,
               COLUMN 103, p_rovapont_ega_man912.hor_ini,
               COLUMN 113, p_rovapont_ega_man912.hor_fim,
               COLUMN 124, p_rovapont_ega_man912.cod_mov
               
      ON LAST ROW
         
         PRINT COLUMN 001, p_descomprime
   
END REPORT

#-----------------------# 
 FUNCTION pol0972_lista()
#-----------------------#
   DEFINE l_lista             SMALLINT 
   
   DEFINE lr_relat            RECORD
             num_ordem           LIKE ordens.num_ordem, 
             cod_operac          LIKE ord_oper.cod_operac, 
             seq_operac          DECIMAL(3,0), 
             msg                 CHAR(60)
                              END RECORD
                              
   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN
   END IF
   
   LET l_lista = FALSE
   
   MESSAGE "Processando a extração do relatório..." ATTRIBUTE(REVERSE)

   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0972.tmp"
         START REPORT pol0972_imp TO p_caminho
      ELSE
         START REPORT pol0972_imp TO p_nom_arquivo
      END IF
   ELSE
      IF p_ies_impressao = "S" THEN
         START REPORT pol0972_imp TO PIPE p_nom_arquivo
      ELSE
         START REPORT pol0972_imp TO p_nom_arquivo
      END IF
   END IF

   CURRENT WINDOW IS w_pol09721

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_lista CURSOR FOR
    SELECT DISTINCT ordem_producao, operacao, sequencia_operacao, texto_erro       
      FROM rovapont_erro_man912
     WHERE empresa = p_cod_empresa
     ORDER BY 1,2,3
     
   FOREACH cq_lista INTO lr_relat.*
      OUTPUT TO REPORT pol0972_imp(lr_relat.*)
      LET l_lista = TRUE
   END FOREACH

   FINISH REPORT pol0972_imp

   IF p_ies_impressao = "S" THEN
      MESSAGE "Relatório impresso na impressora ", p_nom_arquivo ATTRIBUTE(REVERSE)
   ELSE
      MESSAGE "Relatório gravado no arquivo ", p_nom_arquivo ATTRIBUTE(REVERSE)
   END IF
   ERROR " Fim de processamento... "

   IF l_lista = FALSE THEN
      ERROR "Não existem dados para serem listados. "
   END IF

END FUNCTION

#----------------------------#
REPORT pol0972_imp(lr_relat)
#----------------------------#
   DEFINE lr_relat            RECORD
          num_ordem           LIKE ordens.num_ordem, 
          cod_operac          LIKE ord_oper.cod_operac, 
          seq_operac          DECIMAL(3,0), 
          msg                 CHAR(54)
          END RECORD

   OUTPUT LEFT   MARGIN   0
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH  66

   FORMAT
      PAGE HEADER
#         PRINT log500_determina_cpp(132)
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&"

         PRINT COLUMN 001, "pol0972    RELACAO DAS ORDENS DE PRODUCAO IMPORTADAS P/ LOGIX   DATA: ",
               COLUMN 071, TODAY USING "dd/mm/yyyy"
         
         PRINT COLUMN 001, "*------------------------------------------------------------------------------*"
       
         PRINT
         
         PRINT COLUMN 003, "ORDEM   OPER. SEQ                       MENSAGEM"
         PRINT COLUMN 001, "--------- ----- --- -----------------------------------------------------------"

      ON EVERY ROW
         PRINT COLUMN 001, lr_relat.num_ordem USING "########&",
               COLUMN 011, lr_relat.cod_operac USING "####&",
               COLUMN 017, lr_relat.seq_operac USING "##&",
               COLUMN 021, lr_relat.msg

END REPORT

#-----------------------------------#
 FUNCTION pol0972_apont_final()
#-----------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09722") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09722 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consulta" "Consulta Dados da Tabela"
         HELP 001
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0972_consulta_454()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0972_modifica_454()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0972_exclui_454()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0972_paginacao_454("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0972_paginacao_454("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 006
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0972","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0972_relat_454 TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0972.tmp'
                     START REPORT pol0972_relat_454  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0972_relat_454 TO p_nom_arquivo
               END IF
               CALL pol0972_emite_relatorio_454()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0972_relat_454   
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 007
         MESSAGE ""
         LET INT_FLAG = 0
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol09722

END FUNCTION

#-------------------------------#
 FUNCTION pol0972_consulta_454()
#-------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa
   LET p_rovman_apont_454a.* = p_rovman_apont_454.*

   CONSTRUCT BY NAME where_clause ON
       rovman_apont_454.ordem_producao
          
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol09722

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_rovman_apont_454.* = p_rovman_apont_454a.*
      CALL pol0972_exibe_dados_454()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT rowid FROM rovman_apont_454 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND empresa = '",p_cod_empresa,"' ",
                  "   AND (dat_atualiz = '' or dat_atualiz is null) ",
                  " ORDER BY ordem_producao, dat_ini_producao, sequencia_operacao "

   PREPARE var_query1 FROM sql_stmt   
   DECLARE cq_padrao1 SCROLL CURSOR WITH HOLD FOR var_query1
   OPEN cq_padrao1
   FETCH cq_padrao1 INTO p_rowid
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      SELECT *
        INTO p_rovman_apont_454.*
        FROM rovman_apont_454
       WHERE rowid = p_rowid
      CALL pol0972_exibe_dados_454()
   END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION pol0972_entrada_454(p_funcao)
#--------------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol09722
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_rovman_apont_454.* TO NULL
      CALL pol0972_exibe_dados_454()
   END IF

   INPUT BY NAME p_rovman_apont_454.* 
      WITHOUT DEFAULTS  
      AFTER FIELD dat_ini_producao
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol09722

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol0972_exibe_dados_454()
#----------------------------------#

   DISPLAY BY NAME p_rovman_apont_454.*
   
END FUNCTION

#---------------------------------------#
 FUNCTION pol0972_cursor_for_update_454()
#---------------------------------------#

  # IF pol0972_apontando() THEN
  #    RETURN FALSE
  # END IF

   WHENEVER ERROR CONTINUE

   DECLARE cm_padrao1 CURSOR WITH HOLD FOR
   SELECT * INTO p_rovman_apont_454.*                                              
     FROM rovman_apont_454  
    WHERE rowid = p_rowid FOR UPDATE 
   CALL log085_transacao("BEGIN")   
   OPEN cm_padrao1
   FETCH cm_padrao1
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","rovman_apont_454")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#----------------------------------#
 FUNCTION pol0972_modifica_454()
#----------------------------------#

   IF pol0972_cursor_for_update_454() THEN
      LET p_rovman_apont_454a.* = p_rovman_apont_454.*
      IF pol0972_entrada_454("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE rovman_apont_454 
            SET rovman_apont_454.* = p_rovman_apont_454.*
          WHERE CURRENT OF cm_padrao1
         IF SQLCA.SQLCODE = 0 THEN
            UPDATE rovman_apont_hist_454
               SET situacao = 'U',
                   usuario  = p_user,
                   programa = 'pol0972'
             WHERE empresa = p_cod_empresa
               AND refugo  = p_rowid
            IF STATUS = 0 THEN
               CALL log085_transacao("COMMIT")
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            ELSE
               CALL log003_err_sql("MODIFICACAO","rovman_apont_hist_454")
               CALL log085_transacao("ROLLBACK")
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","rovman_apont_454")
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_rovman_apont_454.* = p_rovman_apont_454a.*
         ERROR "Modificacao Cancelada"
         CALL pol0972_exibe_dados_454()
      END IF
      
      CLOSE cm_padrao1
   END IF

END FUNCTION
{
#---------------------------#
FUNCTION pol0972_apontando()
#---------------------------#

   SELECT processando
     INTO p_processando
     FROM rovproc_apont_man912

   IF STATUS = 0 THEN
      IF p_processando = 'S' THEN
         CALL log0030_mensagem(
             "No momento, está sendo efetuado o apontamento. Tente mais tarde",
             "exclamation")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE
   
END FUNCTION
}
#-------------------------------#
 FUNCTION pol0972_exclui_454()
#-------------------------------#

   IF pol0972_cursor_for_update_454() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         PROMPT 'Excluir (A)pontamento da Tela ou (T)odos da Ordem ?' FOR p_resp
         IF p_resp MATCHES "[Tt]" THEN
            UPDATE rovman_apont_454
               SET dat_atualiz = TODAY
            WHERE empresa        = p_cod_empresa
              AND ordem_producao = p_rovman_apont_454.ordem_producao
            IF STATUS <> 0 THEN
               LET p_houve_erro = TRUE
               CALL log003_err_sql("EXCLUSAO","rovman_apont_454")
            ELSE
               DECLARE cq_man CURSOR FOR
                SELECT rowid
                  FROM rovman_apont_454
                 WHERE empresa        = p_cod_empresa
                   AND ordem_producao = p_rovman_apont_454.ordem_producao
               FOREACH cq_man INTO p_rowid   
                  UPDATE rovman_apont_hist_454
                     SET situacao = 'D',
                         usuario  = p_user,
                         programa = 'pol0972'
                   WHERE empresa = p_cod_empresa
                     AND refugo  = p_rowid
                  IF STATUS <> 0 THEN
                     LET p_houve_erro = TRUE
                     CALL log003_err_sql("EXCLUSAO","rovman_apont_hist_454")
                     EXIT FOREACH
                  END IF
                  DELETE FROM rovapont_erro_man912
                   WHERE empresa = p_cod_empresa
                     AND chav_seq = p_rowid
                     AND ies_apont = 'F'
                  IF STATUS <> 0 THEN
                     CALL log003_err_sql("EXCLUSAO","rovapont_erro_man912")
                     LET p_houve_erro = TRUE
                     EXIT FOREACH
                  END IF
               END FOREACH
            END IF
         ELSE
            UPDATE rovman_apont_454
               SET dat_atualiz = TODAY
            WHERE CURRENT OF cm_padrao1
            IF STATUS <> 0 THEN
               LET p_houve_erro = TRUE
               CALL log003_err_sql("EXCLUSAO","rovman_apont_454")
            ELSE
               UPDATE rovman_apont_hist_454
                  SET situacao = 'D',
                      usuario  = p_user,
                      programa = 'pol0972'
                WHERE empresa = p_cod_empresa
                  AND refugo  = p_rowid
               IF STATUS <> 0 THEN
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("EXCLUSAO","rovman_apont_hist_454")
               END IF
               DELETE FROM rovapont_erro_man912
                WHERE empresa = p_cod_empresa
                  AND chav_seq = p_rowid
                  AND ies_apont = 'F'
               IF STATUS <> 0 THEN
                  CALL log003_err_sql("EXCLUSAO","rovapont_erro_man912")
                  LET p_houve_erro = TRUE
               END IF
            END IF
         END IF
         IF NOT p_houve_erro THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_rovman_apont_454.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO empresa
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao1
   END IF

END FUNCTION  

#---------------------------------------#
 FUNCTION pol0972_paginacao_454(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_rovman_apont_454a.* = p_rovman_apont_454.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_padrao1 INTO p_rowid
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao1 INTO p_rowid
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_rovman_apont_454.* = p_rovman_apont_454a.* 
            EXIT WHILE
         END IF

        SELECT * 
           INTO p_rovman_apont_454.* 
           FROM rovman_apont_454
          WHERE rowid = p_rowid
            AND (dat_atualiz IS NULL OR dat_atualiz = ' ')
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0972_exibe_dados_454()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0972_emite_relatorio_454()
#---------------------------------------#
   LET p_count = 0
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   
   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
    
   DECLARE cq_apont1 CURSOR FOR
    SELECT * 
      FROM rovman_apont_454

   FOREACH cq_apont1 INTO p_rovman_apont_454.*
   
      OUTPUT TO REPORT pol0972_relat_454() 
  
     LET p_count = p_count + 1
     
  END FOREACH
 
END FUNCTION 

#--------------------------#
 REPORT pol0972_relat_454()
#--------------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 120, "PAG.: ", PAGENO USING "####&"
         PRINT COLUMN 001, 'pol0972',
               COLUMN 030, 'INTEGRACAO EGA X LOGIX - REGISTROS CRITICADOS',
               COLUMN 107, 'DATA: ', TODAY USING 'dd/mm/yyyy', ' ', TIME
               
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "-------------------------------"
         PRINT
         PRINT COLUMN 001, '  INI PROD   FIM PROD      ITEM          ORDEM   SEQ  OPER  CT    AR   QT REFUGO   QTDE BOAS MOV LOCAL      QTDE HOR MATRICULA S T H. INICIAL H. FINAL       REFUGO     PARADA H.I.PARADA H.F.PARADA  FUNCIONAL DT ATUALIZ T         EQUIPTO      FERRAMENTA' 
         PRINT COLUMN 001, '---------- ---------- --------------- ---------- --- ----- ----- ----- ---------- ---------- --- ---------- -------- --------- - - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- - --------------- ---------------' 

      ON EVERY ROW

         PRINT COLUMN 001, p_rovman_apont_454.dat_ini_producao,
               COLUMN 012, p_rovman_apont_454.dat_fim_producao,
               COLUMN 023, p_rovman_apont_454.item               USING '##############&',
               COLUMN 039, p_rovman_apont_454.ordem_producao     USING '##########',
               COLUMN 050, p_rovman_apont_454.sequencia_operacao USING '##&',
               COLUMN 054, p_rovman_apont_454.operacao           USING '####&',               
               COLUMN 060, p_rovman_apont_454.centro_trabalho    USING '####&',
               COLUMN 066, p_rovman_apont_454.arranjo            USING '####&',
               COLUMN 072, p_rovman_apont_454.qtd_refugo         USING '######&.&&&',               
               COLUMN 083, p_rovman_apont_454.qtd_boas           USING '######&.&&&',
               COLUMN 094, p_rovman_apont_454.tip_movto          USING '&',
               COLUMN 096, p_rovman_apont_454.local              USING '#########&',
               COLUMN 107, p_rovman_apont_454.qtd_hor,
               COLUMN 119, p_rovman_apont_454.matricula          USING '#######&',
               COLUMN 128, p_rovman_apont_454.sit_apont          USING '&',               
               COLUMN 130, p_rovman_apont_454.turno              USING '&',                                            
               COLUMN 132, p_rovman_apont_454.hor_inicial,        
               COLUMN 143, p_rovman_apont_454.hor_fim,
               COLUMN 154, p_rovman_apont_454.refugo             USING '#########&',
               COLUMN 165, p_rovman_apont_454.parada             USING '##&',
               COLUMN 169, p_rovman_apont_454.hor_ini_parada,
               COLUMN 180, p_rovman_apont_454.hor_fim_parada,                                                            
               COLUMN 191, p_rovman_apont_454.unid_funcional     USING '#########&',                                                                           
               COLUMN 202, p_rovman_apont_454.dat_atualiz,                                                                           
               COLUMN 213, p_rovman_apont_454.terminado          USING '&',                                                                           
               COLUMN 215, p_rovman_apont_454.eqpto              USING '##############&',                                                                                          
               COLUMN 231, p_rovman_apont_454.ferramenta         USING '##############&'
                                                                                                                                                                                                   
      ON LAST ROW
         
         PRINT COLUMN 001, p_descomprime
   
END REPORT

#----------------------------# 
 FUNCTION pol0972_lista_454()
#----------------------------#
   DEFINE l_lista             SMALLINT 
   
   DEFINE lr_relat_454     RECORD
          num_ordem        LIKE ordens.num_ordem, 
          cod_operac       LIKE ord_oper.cod_operac, 
          seq_operac       DECIMAL(3,0), 
          msg              CHAR(60)
                           END RECORD
                              
   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN
   END IF
   
   LET l_lista = FALSE
   
   MESSAGE "Processando a extração do relatório..." ATTRIBUTE(REVERSE)

   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0972.tmp"
         START REPORT pol0972_imp_454 TO p_caminho
      ELSE
         START REPORT pol0972_imp_454 TO p_nom_arquivo
      END IF
   ELSE
      IF p_ies_impressao = "S" THEN
         START REPORT pol0972_imp_454 TO PIPE p_nom_arquivo
      ELSE
         START REPORT pol0972_imp_454 TO p_nom_arquivo
      END IF
   END IF

   CURRENT WINDOW IS w_pol0972

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_lista1 CURSOR FOR
    SELECT ordem_producao, operacao, sequencia_operacao, texto_erro       
      FROM rovapont_erro_man912
     WHERE empresa = p_cod_empresa
     ORDER BY 1,2,3
     
   FOREACH cq_lista1 INTO lr_relat_454.*
      OUTPUT TO REPORT pol0972_imp_454(lr_relat_454.*)
      LET l_lista = TRUE
   END FOREACH

   FINISH REPORT pol0972_imp_454

   IF p_ies_impressao = "S" THEN
      MESSAGE "Relatório impresso na impressora ", p_nom_arquivo ATTRIBUTE(REVERSE)
   ELSE
      MESSAGE "Relatório gravado no arquivo ", p_nom_arquivo ATTRIBUTE(REVERSE)
   END IF
   ERROR " Fim de processamento... "

   IF l_lista = FALSE THEN
      ERROR "Não existem dados para serem listados. "
   END IF

END FUNCTION

#-----------------------------------#
REPORT pol0972_imp_454(lr_relat_454)
#-----------------------------------#
   DEFINE lr_relat_454        RECORD
          num_ordem           LIKE ordens.num_ordem, 
          cod_operac          LIKE ord_oper.cod_operac, 
          seq_operac          DECIMAL(3,0), 
          msg                 CHAR(54)
                              END RECORD

   OUTPUT LEFT   MARGIN   0
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH  66

   FORMAT
      PAGE HEADER
#         PRINT log500_determina_cpp(132)
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&"

         PRINT COLUMN 001, "pol0972    RELACAO DAS ORDENS DE PRODUCAO IMPORTADAS P/ LOGIX   DATA: ",
               COLUMN 071, TODAY USING "dd/mm/yyyy"
         
         PRINT COLUMN 001, "*------------------------------------------------------------------------------*"
       
         PRINT
         
         PRINT COLUMN 003, "ORDEM   OPER. SEQ                       MENSAGEM"
         PRINT COLUMN 001, "--------- ----- --- -----------------------------------------------------------"

      ON EVERY ROW
         PRINT COLUMN 001, lr_relat_454.num_ordem USING "########&",
               COLUMN 011, lr_relat_454.cod_operac USING "####&",
               COLUMN 017, lr_relat_454.seq_operac USING "##&",
               COLUMN 021, lr_relat_454.msg

END REPORT

#---------------------------#
FUNCTION pol0972_tab_livre()
#---------------------------#

   WHENEVER ERROR CONTINUE

   SELECT processando,
          hor_ini
     INTO p_processando,
          p_hora_ini
     FROM rovproc_apont_man912

   IF STATUS = 100 THEN
      INSERT INTO rovproc_apont_man912 VALUES('N', CURRENT HOUR TO SECOND)
      IF STATUS <> 0 THEN
         ERROR 'Erro inserindo a tabela rovproc_apont_man912'
         CALL log003_err_sql("INSERT","rovproc_apont_man912")
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF p_processando = 'S' THEN
            CALL pol0972_calc_tempo()
            IF p_qtd_segundo < 3600 THEN
               CALL log0030_mensagem(
                "Apontamento sendo processado por outro usuário. Tente mais tarde!","exclamation")
               RETURN FALSE
            END IF
         END IF
      ELSE
         ERROR 'Erro lendo a tabela rovproc_apont_man912'
         CALL log003_err_sql("LEITURA","rovproc_apont_man912")
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0972_calc_tempo()
#----------------------------#

    LET p_hor_atu = CURRENT HOUR TO SECOND

    IF p_hora_ini > p_hor_atu THEN
       LET p_hor_proces = '24:00:00' - (p_hora_ini - p_hor_atu)
    ELSE
       LET p_hor_proces = (p_hor_atu - p_hora_ini)
    END IF

    LET p_time       = p_hor_proces
    LET p_hor_proces = p_time
    LET p_qtd_segundo = (p_hor_proces[1,2] * 3600) + 
                        (p_hor_proces[4,5] * 60)   + (p_hor_proces[7,8])

END FUNCTION

#-------------------------------#
FUNCTION pol0972_integra_apont()
#-------------------------------#

   CALL log120_procura_caminho("pol0971") RETURNING comando
   LET comando = comando CLIPPED , " ","pol0971"
   RUN comando RETURNING p_status         
   
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
