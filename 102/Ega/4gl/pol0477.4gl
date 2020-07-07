#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO EGA                                          #
# PROGRAMA: pol0477                                                 #
# MODULOS.: pol0477-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
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
          p_num_op             LIKE apont_ega_man912.num_op,
          p_chav_seq           LIKE apont_ega_man912.chav_seq,
          p_processando        LIKE proc_apont_man912.processando,
          p_hora_ini           LIKE proc_apont_man912.hor_ini,
          p_hor_atu            LIKE proc_apont_man912.hor_ini,
          p_time               DATETIME HOUR TO SECOND,
          p_prog_exp           like pct_ajust_man912.prog_export_op,
          p_prog_imp           like pct_ajust_man912.prog_import_op,
          p_hor_proces         CHAR(10),
          p_qtd_segundo        INTEGER,
          p_resp               CHAR(01),
          P_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          sql_stmt             CHAR(300),
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
          p_caminho            CHAR(080),
          p_msg                CHAR(500)
          
          
   DEFINE p_dat_atualiz        LIKE man_apont_454.dat_atualiz

   DEFINE p_apont_ega_man912   RECORD LIKE apont_ega_man912.*,
          p_apont_ega_man912a  RECORD LIKE apont_ega_man912.*
          
   DEFINE p_apont_hist_man912   RECORD LIKE apont_hist_man912.*,
          p_apont_hist_man912a  RECORD LIKE apont_hist_man912.*

   DEFINE p_man_apont_454   RECORD LIKE man_apont_454.*,
          p_man_apont_454a  RECORD LIKE man_apont_454.*

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 3
   DEFER INTERRUPT
   LET p_versao = "pol0477-10.02.09"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0477.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0477_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0477_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol04771") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol04771 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
   select prog_export_op,
          prog_import_op
     into p_prog_exp,
          p_prog_imp
     from pct_ajust_man912
    where cod_empresa = p_cod_empresa
   
   if status <> 0 then
      CALL log003_err_sql("LEITURA","pct_ajust_man912")
      return
   end if

   MENU "OPCAO"
      COMMAND 'Erros' 'Exibe os Erros que ocorreram na Importação.'
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL log085_transacao("BEGIN")
         IF pol0477_tab_livre() THEN
            CALL log085_transacao("COMMIT")
            CALL pol0477_consulta_erros()
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      COMMAND 'Listar' 'Lista os erros que ocorreram na Importação.'
         HELP 001
         MESSAGE ''
         IF log005_seguranca(p_user,'MANUFAT','pol0477','IN') THEN
            CALL pol0477_lista()
         END IF
      COMMAND 'Pré_apontamento' 'Permite modificação das críticas do pré_apontamento.'
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL log085_transacao("BEGIN")
         IF pol0477_tab_livre() THEN
            CALL log085_transacao("COMMIT")
            CALL pol0477_pre_aponta()
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      COMMAND 'Apontamento final' 'Permite modificação das críticas do pré_apontamento.'
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL log085_transacao("BEGIN")
         IF pol0477_tab_livre() THEN
            CALL log085_transacao("COMMIT")
            CALL pol0477_apont_final()
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      COMMAND KEY ("T") "aponTa" 'Efetua o apontamento das ordens.'
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF NOT pol0477_apontando() THEN
	         MESSAGE ""
			 CALL log120_procura_caminho(p_prog_imp) RETURNING comando
			 LET comando = comando 
			 RUN comando RETURNING p_status   	 	 
 #           CALL pol0477_integra_apont()
         ELSE
            ERROR 'Operação cancelada!'
         END IF
      COMMAND KEY ("B") "liBerar" 'Libera a integração de apontamentos'
         MESSAGE ""
         LET p_houve_erro = FALSE
         CALL pol0477_libera_apont()
         IF p_houve_erro THEN
            ERROR 'Operação cancelada!'
         ELSE
            ERROR 'Liberação efetuada com sucesso!'
         END IF
      COMMAND KEY ("D") "orDem" 'Exporta ordens para o EGA'
         MESSAGE ""
         CALL log120_procura_caminho(p_prog_exp) RETURNING comando
         LET comando = comando 
         RUN comando RETURNING p_status   
      COMMAND "Item" 'Exporta itens para o EGA'
         MESSAGE ""
         CALL log120_procura_caminho("pol0857") RETURNING comando
         LET comando = comando 
         RUN comando RETURNING p_status   
      COMMAND "Histórico" 'Consulta histórico dos apontamentos'
         MESSAGE ""
         CALL log120_procura_caminho("pol0651") RETURNING comando
         LET comando = comando 
         RUN comando RETURNING p_status   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0477_sobre()
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

   CLOSE WINDOW w_pol04771

END FUNCTION

#-----------------------#
 FUNCTION pol0477_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------#
 FUNCTION pol0477_consulta_erros()
#--------------------------------#
   DEFINE l_ind           SMALLINT,
          s_ind           SMALLINT,
          p_tem_dados     SMALLINT

   DEFINE p_op            RECORD
          ordem_producao  LIKE man_apont_erro_454.ordem_producao
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
              FROM man_apont_erro_454
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
                      "  FROM man_apont_erro_454 ",
                      " WHERE empresa = '",p_cod_empresa,"' ",
                      " ORDER BY ordem_producao"
   ELSE
      LET sql_stmt =  "SELECT DISTINCT ordem_producao, operacao, texto_erro ",
                      "  FROM man_apont_erro_454 ",
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
 FUNCTION pol0477_pre_aponta()
#-----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0477") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0477 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 001
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0477_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0477_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0477_exportacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exportação"
         END IF 
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0477_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0477_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 006
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0477","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0477_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0477.tmp'
                     START REPORT pol0477_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0477_relat TO p_nom_arquivo
               END IF
               CALL pol0477_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0477_relat   
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

   CLOSE WINDOW w_pol0477

END FUNCTION

#--------------------------#
 FUNCTION pol0477_consulta()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_apont_ega_man912a.* = p_apont_ega_man912.*

   
   CONSTRUCT BY NAME where_clause ON
       apont_ega_man912.num_op
 
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0477

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_apont_ega_man912.* = p_apont_ega_man912a.*
      CALL pol0477_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT chav_seq, num_op FROM apont_ega_man912 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",                
                  "ORDER BY num_op, chav_seq "

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
        INTO p_apont_ega_man912.*
        FROM apont_ega_man912
       WHERE chav_seq = p_chav_seq
         AND cod_empresa = p_cod_empresa
         
      CALL pol0477_exibe_dados()
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0477_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0477
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_apont_ega_man912.* TO NULL
      CALL pol0477_exibe_dados()
   END IF

   INPUT BY NAME p_apont_ega_man912.* 
      WITHOUT DEFAULTS  

      AFTER FIELD num_op

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0477

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0477_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_apont_ega_man912.*
   
END FUNCTION


#-----------------------------------#
 FUNCTION pol0477_cursor_for_update()
#-----------------------------------#

   IF pol0477_apontando() THEN
      RETURN FALSE
   END IF

   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *
     INTO p_apont_ega_man912.*                                              
     FROM apont_ega_man912  
    WHERE chav_seq = p_chav_seq  
      AND cod_empresa = p_cod_empresa
      FOR UPDATE
      
   CALL log085_transacao("BEGIN")   
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","apont_ega_man912")
   END CASE
   CALL log085_transacao("ROLLBACK")

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0477_modificacao()
#-----------------------------#

   IF pol0477_cursor_for_update() THEN
      LET p_apont_ega_man912a.* = p_apont_ega_man912.*
      IF pol0477_entrada_dados("MODIFICACAO") THEN
         LET p_apont_ega_man912.num_versao = p_apont_ega_man912.num_versao + 1
         UPDATE apont_ega_man912 
            SET apont_ega_man912.* = p_apont_ega_man912.*
          WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            IF pol0477_insere_hist() THEN
               CALL log085_transacao("COMMIT")
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            ELSE
               CALL log085_transacao("ROLLBACK")
               ERROR "Modificação cancelada !!!"
            END IF
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","apont_ega_man912")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_apont_ega_man912.* = p_apont_ega_man912a.*
         ERROR "Modificacao Cancelada"
         CALL pol0477_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0477_insere_hist()
#-----------------------------#
   
   LET p_apont_hist_man912.chav_seq = p_apont_ega_man912.chav_seq
   LET p_apont_hist_man912.num_versao = p_apont_ega_man912.num_versao
   LET p_apont_hist_man912.dat_producao = p_apont_ega_man912.dat_producao
   LET p_apont_hist_man912.cod_item = p_apont_ega_man912.cod_item
   LET p_apont_hist_man912.num_op = p_apont_ega_man912.num_op
   LET p_apont_hist_man912.cod_operac = p_apont_ega_man912.cod_operac
   LET p_apont_hist_man912.cod_maquina = p_apont_ega_man912.cod_maquina
   LET p_apont_hist_man912.qtd_refugo = p_apont_ega_man912.qtd_refugo
   LET p_apont_hist_man912.qtd_boas = p_apont_ega_man912.qtd_boas
   LET p_apont_hist_man912.tip_mov = p_apont_ega_man912.tip_mov
   LET p_apont_hist_man912.mat_operador = p_apont_ega_man912.mat_operador
   LET p_apont_hist_man912.cod_turno = p_apont_ega_man912.cod_turno
   LET p_apont_hist_man912.hor_ini = p_apont_ega_man912.hor_ini
   LET p_apont_hist_man912.hor_fim = p_apont_ega_man912.hor_fim
   LET p_apont_hist_man912.cod_mov = p_apont_ega_man912.cod_mov
   LET p_apont_hist_man912.arq_orig = p_apont_ega_man912.arq_orig
   LET p_apont_hist_man912.situacao = NULL
   LET p_apont_hist_man912.usuario  = p_user
   LET p_apont_hist_man912.programa = 'pol0477'

   INSERT INTO apont_hist_man912
    VALUES(p_apont_hist_man912.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSAO","APONT_HIST_MAN912")
      RETURN FALSE
   END IF
           
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0477_exportacao()
#-----------------------------#

   IF pol0477_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         IF pol0477_atualiza_hist() THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_apont_ega_man912.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            CALL log085_transacao("ROLLBACK")
            ERROR "Exclusão cancelada !!!"
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF
        
END FUNCTION     

#-------------------------------#
FUNCTION pol0477_atualiza_hist()
#-------------------------------#

   PROMPT 'Excluir (A)pontamento da Tela ou (T)odos da Ordem ?' FOR p_resp
   
   IF p_resp MATCHES "[TtAa]" THEN
   ELSE
      ERROR 'Resposta Inválida !!!'
      RETURN FALSE
   END IF
   
   IF p_resp MATCHES "[Aa]" THEN
 
      DELETE FROM apont_ega_man912
       WHERE CURRENT OF cm_padrao

      IF STATUS = 0 THEN
         UPDATE apont_hist_man912
            SET situacao = 'D',
                usuario  = p_user,
                programa = 'pol0477'
          WHERE chav_seq   = p_chav_seq
            AND num_versao = p_apont_ega_man912.num_versao
            AND cod_empresa = p_cod_empresa
    
         IF STATUS <> 0 THEN
            CALL log003_err_sql("UPDATE","APONT_HIST_MAN912")
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
      FROM apont_ega_man912
     WHERE num_op = p_num_op
       AND cod_empresa = p_cod_empresa
    
   FOREACH cq_deleta INTO 
           p_apont_ega_man912.chav_seq,
           p_apont_ega_man912.num_versao
    
      UPDATE apont_hist_man912
         SET situacao = 'D',
             usuario  = p_user,
             programa = 'pol0477'
       WHERE chav_seq   = p_apont_ega_man912.chav_seq
         AND num_versao = p_apont_ega_man912.num_versao
         AND cod_empresa = p_cod_empresa
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDATE","APONT_HIST_MAN912")
         RETURN FALSE
      END IF

   END FOREACH
           
   DELETE FROM apont_ega_man912
    WHERE num_op = p_num_op
      AND cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELEÇÃO","APONT_EGA_MAN912")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------------------------------#
 FUNCTION pol0477_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_apont_ega_man912a.* = p_apont_ega_man912.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_padrao INTO p_chav_seq, p_num_op
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_chav_seq, p_num_op
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_apont_ega_man912.* = p_apont_ega_man912a.* 
            EXIT WHILE
         END IF

        SELECT * 
           INTO p_apont_ega_man912.* 
           FROM apont_ega_man912
          WHERE chav_seq = p_chav_seq
            AND cod_empresa = p_cod_empresa
            
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0477_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0477_emite_relatorio()
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
      FROM apont_ega_man912
     WHERE cod_empresa = p_cod_empresa

   FOREACH cq_apont INTO p_apont_ega_man912.*
   
      OUTPUT TO REPORT pol0477_relat() 
  
     LET p_count = p_count + 1
     
  END FOREACH
 
END FUNCTION 

#----------------------#
 REPORT pol0477_relat()
#----------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 120, "PAG.: ", PAGENO USING "####&"
         PRINT COLUMN 001, 'POL0477',
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

         PRINT COLUMN 001, p_apont_ega_man912.dat_producao,
               COLUMN 012, p_apont_ega_man912.cod_item,
               COLUMN 029, p_apont_ega_man912.num_op,
               COLUMN 041, p_apont_ega_man912.cod_operac,
               COLUMN 048, p_apont_ega_man912.cod_maquina,
               COLUMN 054, p_apont_ega_man912.qtd_refugo,
               COLUMN 065, p_apont_ega_man912.qtd_boas,
               COLUMN 078, p_apont_ega_man912.tip_mov,
               COLUMN 084, p_apont_ega_man912.mat_operador,
               COLUMN 097, p_apont_ega_man912.cod_turno,
               COLUMN 103, p_apont_ega_man912.hor_ini,
               COLUMN 113, p_apont_ega_man912.hor_fim,
               COLUMN 124, p_apont_ega_man912.cod_mov
               
      ON LAST ROW
         
         PRINT COLUMN 001, p_descomprime
   
END REPORT

#-----------------------# 
 FUNCTION pol0477_lista()
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
         LET p_caminho = p_caminho CLIPPED, "pol0477.tmp"
         START REPORT pol0477_imp TO p_caminho
      ELSE
         START REPORT pol0477_imp TO p_nom_arquivo
      END IF
   ELSE
      IF p_ies_impressao = "S" THEN
         START REPORT pol0477_imp TO PIPE p_nom_arquivo
      ELSE
         START REPORT pol0477_imp TO p_nom_arquivo
      END IF
   END IF

   CURRENT WINDOW IS w_pol04771

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_lista CURSOR FOR
    SELECT DISTINCT ordem_producao, operacao, sequencia_operacao, texto_erro       
      FROM man_apont_erro_454
     WHERE empresa = p_cod_empresa
     ORDER BY 1,2,3
     
   FOREACH cq_lista INTO lr_relat.*
      OUTPUT TO REPORT pol0477_imp(lr_relat.*)
      LET l_lista = TRUE
   END FOREACH

   FINISH REPORT pol0477_imp

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
REPORT pol0477_imp(lr_relat)
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

         PRINT COLUMN 001, "pol0477    RELACAO DAS ORDENS DE PRODUCAO IMPORTADAS P/ LOGIX   DATA: ",
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
 FUNCTION pol0477_apont_final()
#-----------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol04772") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol04772 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consulta" "Consulta Dados da Tabela"
         HELP 001
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0477_consulta_454()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0477_modifica_454()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0477_exclui_454()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0477_paginacao_454("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0477_paginacao_454("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 006
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0477","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0477_relat_454 TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0477.tmp'
                     START REPORT pol0477_relat_454  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0477_relat_454 TO p_nom_arquivo
               END IF
               CALL pol0477_emite_relatorio_454()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0477_relat_454   
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

   CLOSE WINDOW w_pol04772

END FUNCTION

#-------------------------------#
 FUNCTION pol0477_consulta_454()
#-------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa
   LET p_man_apont_454a.* = p_man_apont_454.*

   CONSTRUCT BY NAME where_clause ON
       man_apont_454.ordem_producao
          
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol04772

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_man_apont_454.* = p_man_apont_454a.*
      CALL pol0477_exibe_dados_454()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT rowid FROM man_apont_454 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND empresa = '",p_cod_empresa,"' ",
                  "   AND (dat_atualiz = ' ' OR dat_atualiz is null) ",
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
        INTO p_man_apont_454.*
        FROM man_apont_454
       WHERE rowid = p_rowid
         
      CALL pol0477_exibe_dados_454()
      
   END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION pol0477_entrada_454(p_funcao)
#--------------------------------------------#

   DEFINE p_funcao CHAR(30),
          p_ies_situa char(01),
          p_cod_item  char(15)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol04772
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_man_apont_454.* TO NULL
      CALL pol0477_exibe_dados_454()
   END IF

   INPUT BY NAME p_man_apont_454.* 
      WITHOUT DEFAULTS  
      
      AFTER FIELD ordem_producao
         if p_man_apont_454.ordem_producao is null then
            error 'Campo com preenchimento obrigatório!'
            next FIELD ordem_producao
         end if
         
         select ies_situa,
                cod_item
           into p_ies_situa,
                p_cod_item
           from ordens
          where cod_empresa = p_cod_empresa
            and num_ordem   = p_man_apont_454.ordem_producao
         If status = 100 then
            ERROR 'Ordem de produção inexistente!'
            next FIELD ordem_producao
         else
            if status <> 0 then
               call log003_err_sql('Lendo','ordens')
               next FIELD ordem_producao
            end if
         end if
         
         if p_ies_situa <> '4' then
            error 'Ordem não está liberada!'
            next FIELD ordem_producao
         end if

         if p_cod_item <> p_man_apont_454.item then
            error 'Ordem não é do mesmo item!'
            next FIELD ordem_producao
         end if
         
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol04772

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol0477_exibe_dados_454()
#----------------------------------#

   DISPLAY BY NAME p_man_apont_454.*
   
END FUNCTION

#---------------------------------------#
 FUNCTION pol0477_cursor_for_update_454()
#---------------------------------------#

   IF pol0477_apontando() THEN
      RETURN FALSE
   END IF

   DECLARE cm_padrao1 CURSOR WITH HOLD FOR
   SELECT * INTO p_man_apont_454.*                                              
     FROM man_apont_454  
    WHERE rowid = p_rowid 
      FOR UPDATE 
    
   CALL log085_transacao("BEGIN")   
   OPEN cm_padrao1
   FETCH cm_padrao1
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","man_apont_454")
   END CASE
   CALL log085_transacao("ROLLBACK")

   RETURN FALSE

END FUNCTION

#----------------------------------#
 FUNCTION pol0477_modifica_454()
#----------------------------------#

   IF pol0477_cursor_for_update_454() THEN
      LET p_man_apont_454a.* = p_man_apont_454.*
      IF pol0477_entrada_454("MODIFICACAO") THEN
         UPDATE man_apont_454 
            SET man_apont_454.* = p_man_apont_454.*
          WHERE CURRENT OF cm_padrao1
         IF SQLCA.SQLCODE = 0 THEN
            UPDATE man_apont_hist_454
               SET situacao = 'U',
                   usuario  = p_user,
                   programa = 'pol0477'
             WHERE empresa = p_cod_empresa
               AND refugo  = p_rowid
            IF STATUS = 0 THEN
               CALL log085_transacao("COMMIT")
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            ELSE
               CALL log085_transacao("ROLLBACK")
               CALL log003_err_sql("MODIFICACAO","man_apont_hist_454")
            END IF
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","man_apont_454")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_man_apont_454.* = p_man_apont_454a.*
         ERROR "Modificacao Cancelada"
         CALL pol0477_exibe_dados_454()
      END IF
      CLOSE cm_padrao1
   END IF

END FUNCTION

#---------------------------#
FUNCTION pol0477_apontando()
#---------------------------#

   SELECT processando
     INTO p_processando
     FROM proc_apont_man912
    WHERE cod_empresa = '01'

   IF STATUS = 0 THEN
      IF p_processando = 'S' THEN
         CALL log0030_mensagem(
             "No momento, está sendo efetuado o apontamento. Tente mais tarde",
             "exclamation")
         RETURN TRUE
      END IF
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','proc_apont_man912')
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE
   
END FUNCTION

#-------------------------------#
 FUNCTION pol0477_exclui_454()
#-------------------------------#

   IF pol0477_cursor_for_update_454() THEN
      IF log004_confirm(18,35) THEN
         PROMPT 'Excluir (A)pontamento da Tela ou (T)odos da Ordem ?' FOR p_resp
         IF p_resp MATCHES "[Tt]" THEN
            UPDATE man_apont_454
               SET dat_atualiz = TODAY
            WHERE empresa        = p_cod_empresa
              AND ordem_producao = p_man_apont_454.ordem_producao
            IF STATUS <> 0 THEN
               LET p_houve_erro = TRUE
               CALL log003_err_sql("EXCLUSAO","man_apont_454")
            ELSE
               DECLARE cq_man CURSOR FOR
                SELECT rowid
                  FROM man_apont_454
                 WHERE empresa        = p_cod_empresa
                   AND ordem_producao = p_man_apont_454.ordem_producao
               FOREACH cq_man INTO p_rowid   
                  UPDATE man_apont_hist_454
                     SET situacao = 'D',
                         usuario  = p_user,
                         programa = 'pol0477'
                   WHERE empresa = p_cod_empresa
                     AND refugo  = p_rowid
                  IF STATUS <> 0 THEN
                     LET p_houve_erro = TRUE
                     CALL log003_err_sql("EXCLUSAO","man_apont_hist_454")
                     EXIT FOREACH
                  END IF
               END FOREACH
            END IF
         ELSE
            UPDATE man_apont_454
               SET dat_atualiz = TODAY
            WHERE CURRENT OF cm_padrao1
            IF STATUS <> 0 THEN
               LET p_houve_erro = TRUE
               CALL log003_err_sql("EXCLUSAO","man_apont_454")
            ELSE
               UPDATE man_apont_hist_454
                  SET situacao = 'D',
                      usuario  = p_user,
                      programa = 'pol0477'
                WHERE empresa = p_cod_empresa
                  AND refugo  = p_rowid
               IF STATUS <> 0 THEN
                  LET p_houve_erro = TRUE
                  CALL log003_err_sql("EXCLUSAO","man_apont_hist_454")
               END IF
            END IF
         END IF
         IF NOT p_houve_erro THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_man_apont_454.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO empresa
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao1
   END IF

END FUNCTION  

#---------------------------------------#
 FUNCTION pol0477_paginacao_454(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_man_apont_454a.* = p_man_apont_454.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_padrao1 INTO p_rowid
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao1 INTO p_rowid
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_man_apont_454.* = p_man_apont_454a.* 
            EXIT WHILE
         END IF

        SELECT * 
           INTO p_man_apont_454.* 
           FROM man_apont_454
          WHERE rowid = p_rowid
            AND (dat_atualiz IS NULL OR dat_atualiz = ' ')
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0477_exibe_dados_454()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0477_emite_relatorio_454()
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
      FROM man_apont_454
     WHERE empresa = p_cod_empresa

   FOREACH cq_apont1 INTO p_man_apont_454.*
   
      OUTPUT TO REPORT pol0477_relat_454() 
  
     LET p_count = p_count + 1
     
  END FOREACH
 
END FUNCTION 

#--------------------------#
 REPORT pol0477_relat_454()
#--------------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 120, "PAG.: ", PAGENO USING "####&"
         PRINT COLUMN 001, 'POL0477',
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

         PRINT COLUMN 001, p_man_apont_454.dat_ini_producao,
               COLUMN 012, p_man_apont_454.dat_fim_producao,
               COLUMN 023, p_man_apont_454.item               USING '##############&',
               COLUMN 039, p_man_apont_454.ordem_producao     USING '##########',
               COLUMN 050, p_man_apont_454.sequencia_operacao USING '##&',
               COLUMN 054, p_man_apont_454.operacao           USING '####&',               
               COLUMN 060, p_man_apont_454.centro_trabalho    USING '####&',
               COLUMN 066, p_man_apont_454.arranjo            USING '####&',
               COLUMN 072, p_man_apont_454.qtd_refugo         USING '######&.&&&',               
               COLUMN 083, p_man_apont_454.qtd_boas           USING '######&.&&&',
               COLUMN 094, p_man_apont_454.tip_movto          USING '&',
               COLUMN 096, p_man_apont_454.local              USING '#########&',
               COLUMN 107, p_man_apont_454.qtd_hor,
               COLUMN 119, p_man_apont_454.matricula          USING '#######&',
               COLUMN 128, p_man_apont_454.sit_apont          USING '&',               
               COLUMN 130, p_man_apont_454.turno              USING '&',                                            
               COLUMN 132, p_man_apont_454.hor_inicial,        
               COLUMN 143, p_man_apont_454.hor_fim,
               COLUMN 154, p_man_apont_454.refugo             USING '#########&',
               COLUMN 165, p_man_apont_454.parada             USING '##&',
               COLUMN 169, p_man_apont_454.hor_ini_parada,
               COLUMN 180, p_man_apont_454.hor_fim_parada,                                                            
               COLUMN 191, p_man_apont_454.unid_funcional     USING '#########&',                                                                           
               COLUMN 202, p_man_apont_454.dat_atualiz,                                                                           
               COLUMN 213, p_man_apont_454.terminado          USING '&',                                                                           
               COLUMN 215, p_man_apont_454.eqpto              USING '##############&',                                                                                          
               COLUMN 231, p_man_apont_454.ferramenta         USING '##############&'
                                                                                                                                                                                                   
      ON LAST ROW
         
         PRINT COLUMN 001, p_descomprime
   
END REPORT

#----------------------------# 
 FUNCTION pol0477_lista_454()
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
         LET p_caminho = p_caminho CLIPPED, "pol0477.tmp"
         START REPORT pol0477_imp_454 TO p_caminho
      ELSE
         START REPORT pol0477_imp_454 TO p_nom_arquivo
      END IF
   ELSE
      IF p_ies_impressao = "S" THEN
         START REPORT pol0477_imp_454 TO PIPE p_nom_arquivo
      ELSE
         START REPORT pol0477_imp_454 TO p_nom_arquivo
      END IF
   END IF

   CURRENT WINDOW IS w_pol0477

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_lista1 CURSOR FOR
    SELECT ordem_producao, operacao, sequencia_operacao, texto_erro       
      FROM man_apont_erro_454
     WHERE empresa = p_cod_empresa
     ORDER BY 1,2,3
     
   FOREACH cq_lista1 INTO lr_relat_454.*
      OUTPUT TO REPORT pol0477_imp_454(lr_relat_454.*)
      LET l_lista = TRUE
   END FOREACH

   FINISH REPORT pol0477_imp_454

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
REPORT pol0477_imp_454(lr_relat_454)
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

         PRINT COLUMN 001, "pol0477    RELACAO DAS ORDENS DE PRODUCAO IMPORTADAS P/ LOGIX   DATA: ",
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
FUNCTION pol0477_tab_livre()
#---------------------------#

   SELECT processando,
          hor_ini
     INTO p_processando,
          p_hora_ini
     FROM proc_apont_man912
    WHERE cod_empresa = '01'
    
   IF STATUS = 100 THEN
      INSERT INTO proc_apont_man912 VALUES('N', CURRENT HOUR TO SECOND, '01')
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERT","proc_apont_man912")
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF p_processando = 'S' THEN
            CALL pol0477_calc_tempo()
            IF p_qtd_segundo < 3600 THEN
               CALL log0030_mensagem(
                "Apontamento sendo processado por outro usuário. Tente mais tarde!","exclamation")
               RETURN FALSE
            END IF
         END IF
      ELSE
         CALL log003_err_sql("LEITURA","proc_apont_man912")
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0477_calc_tempo()
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
FUNCTION pol0477_integra_apont()
#-------------------------------#

   CALL log120_procura_caminho(p_prog_imp) RETURNING comando
   LET comando = comando CLIPPED, " ","pol0477"
   RUN comando RETURNING p_status   
   
   CALL log085_transacao("BEGIN")       
   DELETE FROM man_apont_erro_454
    WHERE empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELEÇÃO","MAN_APONT_ERRO_454")
      CALL log085_transacao("ROLLBACK")       
   ELSE
      CALL log085_transacao("COMMIT")       
      CALL log120_procura_caminho(p_prog_imp) RETURNING comando
      LET comando = comando CLIPPED
      RUN comando RETURNING p_status   

      CALL log085_transacao("BEGIN")       
      INSERT INTO apont_erro_man912
           SELECT * FROM man_apont_erro_454 WHERE empresa = p_cod_empresa

      IF STATUS <> 0 THEN
         CALL log003_err_sql("INCLUSÃO","apont_erro_man912")
         CALL log085_transacao("ROLLBACK")       
      ELSE
         DELETE FROM man_apont_erro_454 WHERE empresa = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("DELEÇÃO","MAN_APONT_ERRO_454")
            CALL log085_transacao("ROLLBACK")       
         ELSE
            INSERT INTO man_apont_erro_454
                 SELECT * FROM apont_erro_man912 WHERE empresa = p_cod_empresa
            IF STATUS <> 0 THEN
               CALL log003_err_sql("INCLUSÃO","MAN_APONT_ERRO_454")
               CALL log085_transacao("ROLLBACK")       
            ELSE
               CALL log085_transacao("COMMIT")       
            END IF
         END IF
      END IF
   END IF

   #--- Este trecho foi acrescentado a pedido do Sr.Manuel Sobrido
   CALL log120_procura_caminho(p_prog_imp) RETURNING comando
   LET comando = comando CLIPPED, " ","pol0477"
   RUN comando RETURNING p_status   
   
   CALL log085_transacao("BEGIN")       
   DELETE FROM man_apont_erro_454
    WHERE empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELEÇÃO","MAN_APONT_ERRO_454")
      CALL log085_transacao("ROLLBACK")       
   ELSE
      CALL log085_transacao("COMMIT")       
      CALL log120_procura_caminho(p_prog_imp) RETURNING comando
      LET comando = comando CLIPPED
      RUN comando RETURNING p_status   

      CALL log085_transacao("BEGIN")       
      INSERT INTO apont_erro_man912
              SELECT * FROM man_apont_erro_454 WHERE empresa = p_cod_empresa

      IF STATUS <> 0 THEN
         CALL log003_err_sql("INCLUSÃO","apont_erro_man912")
         CALL log085_transacao("ROLLBACK")       
      ELSE
         DELETE FROM man_apont_erro_454 WHERE empresa = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("DELEÇÃO","MAN_APONT_ERRO_454")
            CALL log085_transacao("ROLLBACK")       
         ELSE
            INSERT INTO man_apont_erro_454
                 SELECT * FROM apont_erro_man912 WHERE empresa = p_cod_empresa
            IF STATUS <> 0 THEN
               CALL log003_err_sql("INCLUSÃO","MAN_APONT_ERRO_454")
               CALL log085_transacao("ROLLBACK")       
            ELSE
               CALL log085_transacao("COMMIT")       
            END IF
         END IF
      END IF
   END IF
   #--- Fim
   
   CALL pol0477_libera_apont()
   
END FUNCTION

#------------------------------#
FUNCTION pol0477_libera_apont()
#------------------------------#

   CALL log085_transacao("BEGIN")       
   
   UPDATE proc_apont_man912 
      SET processando = 'N'
    WHERE cod_empresa = '01'

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","proc_apont_man912")
      CALL log085_transacao("ROLLBACK")    
      LET p_houve_erro = TRUE   
   END IF
   
   CALL log085_transacao("COMMIT")       
   
   SELECT processando
     INTO p_processando
     FROM proc_apont_man912
    WHERE cod_empresa = '01'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo","proc_apont_man912")
      LET p_houve_erro = TRUE   
   ELSE
      IF p_processando <> 'N' THEN
         LET p_msg = 'Não foi possivel efetuar a liberação!'
         CALL log0030_mensagem(p_msg,'excla')
         LET p_houve_erro = TRUE
      END IF
   END IF
     
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
