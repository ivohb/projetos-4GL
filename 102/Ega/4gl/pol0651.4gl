#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO EGA                                          #
# PROGRAMA: pol0651                                                 #
# MODULOS.: pol0651-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CONSULTA APONTAMENTOS DAS TABELAS DE HISTÓRICO          #
# AUTOR...: POLO INFORMATICA - Ana Paula                            #
# DATA....: 18/08/2006                                              #
# ALTERADO: 04/04/2007 por ANA PAULA versao 08                      #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_op             LIKE apont_hist_man912.num_op,
          p_chav_seq           LIKE apont_hist_man912.chav_seq,
          p_processando        LIKE proc_apont_man912.processando,
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
          
   DEFINE p_dat_atualiz        LIKE man_apont_hist_454.dat_atualiz

   DEFINE p_apont_hist_man912   RECORD LIKE apont_hist_man912.*,
          p_apont_hist_man912a  RECORD LIKE apont_hist_man912.*
         
   DEFINE p_man_apont_hist_454   RECORD LIKE man_apont_hist_454.*,
          p_man_apont_hist_454a  RECORD LIKE man_apont_hist_454.*

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 3
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0651-10.02.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0651.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0651_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0651_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06511") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06511 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND 'Ega' 'Acesso aos apontamentos enviados pelo Ega'
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0651_pre_aponta()
      COMMAND 'Logix' 'Acesso aos apontamentos processados pelo Logix'
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0651_apont_final()
      COMMAND KEY ("S") "Sobre" "Exibe a versão do programa"
         CALL pol0651_sobre()
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

   CLOSE WINDOW w_pol06511

END FUNCTION

#-----------------------------#
 FUNCTION pol0651_pre_aponta()
#-----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0651") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0651 AT 4,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consulta" "Consulta Dados da Tabela"
         HELP 001
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0651_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0651_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0651_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 006
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0651","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0651_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0651.tmp'
                     START REPORT pol0651_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0651_relat TO p_nom_arquivo
               END IF
               CALL pol0651_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0651_relat   
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

   CLOSE WINDOW w_pol0651

END FUNCTION

#--------------------------#
 FUNCTION pol0651_consulta()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_apont_hist_man912a.* = p_apont_hist_man912.*
   
   CONSTRUCT BY NAME where_clause ON
       apont_hist_man912.arq_orig,
       apont_hist_man912.num_op,
       apont_hist_man912.cod_item,
       apont_hist_man912.cod_operac,
       apont_hist_man912.cod_maquina,
       apont_hist_man912.dat_producao,
       apont_hist_man912.hor_ini,
       apont_hist_man912.hor_fim,
       apont_hist_man912.cod_mov,
       apont_hist_man912.tip_mov
 
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0651

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_apont_hist_man912.* = p_apont_hist_man912a.*
      CALL pol0651_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT chav_seq FROM apont_hist_man912 ",
                  " WHERE ", where_clause CLIPPED,  
                  "   AND cod_empresa = '",p_cod_empresa,"' ",               
                  "ORDER BY num_op"                     

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_chav_seq
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0651_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0651_exibe_dados()
#------------------------------#
   
   SELECT * 
     INTO p_apont_hist_man912.* 
     FROM apont_hist_man912
    WHERE chav_seq = p_chav_seq
      AND cod_empresa = p_cod_empresa
   
   CLEAR FORM

   DISPLAY p_cod_empresa TO cod_empresa

   DISPLAY BY NAME p_apont_hist_man912.dat_producao,
                   p_apont_hist_man912.cod_item,
                   p_apont_hist_man912.num_op,
                   p_apont_hist_man912.cod_operac,
                   p_apont_hist_man912.cod_maquina,
                   p_apont_hist_man912.qtd_refugo,
                   p_apont_hist_man912.qtd_boas,
                   p_apont_hist_man912.tip_mov,
                   p_apont_hist_man912.mat_operador,
                   p_apont_hist_man912.cod_turno,
                   p_apont_hist_man912.hor_ini,
                   p_apont_hist_man912.hor_fim,
                   p_apont_hist_man912.cod_mov,
                   p_apont_hist_man912.usuario,
                   p_apont_hist_man912.programa,
                   p_apont_hist_man912.chav_seq,
                   p_apont_hist_man912.arq_orig,
                   p_apont_hist_man912.num_versao,
				   p_apont_hist_man912.situacao
                   
 
 END FUNCTION

#-----------------------------------#
 FUNCTION pol0651_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_apont_hist_man912a.* = p_apont_hist_man912.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_padrao INTO p_chav_seq
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_chav_seq
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_apont_hist_man912.* = p_apont_hist_man912a.* 
            EXIT WHILE
         END IF

         SELECT chav_seq
           FROM apont_hist_man912
          WHERE chav_seq = p_chav_seq
          AND cod_empresa = p_cod_empresa
          
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0651_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0651_emite_relatorio()
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
      FROM apont_hist_man912
      WHERE cod_empresa = p_cod_empresa

   FOREACH cq_apont INTO p_apont_hist_man912.*
   
      OUTPUT TO REPORT pol0651_relat() 
  
     LET p_count = p_count + 1
     
  END FOREACH
 
END FUNCTION 

#----------------------#
 REPORT pol0651_relat()
#----------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 120, "PAG.: ", PAGENO USING "####&"
         PRINT COLUMN 001, 'POL0651',
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

         PRINT COLUMN 001, p_apont_hist_man912.dat_producao,
               COLUMN 012, p_apont_hist_man912.cod_item,
               COLUMN 029, p_apont_hist_man912.num_op,
               COLUMN 041, p_apont_hist_man912.cod_operac,
               COLUMN 048, p_apont_hist_man912.cod_maquina,
               COLUMN 054, p_apont_hist_man912.qtd_refugo,
               COLUMN 065, p_apont_hist_man912.qtd_boas,
               COLUMN 078, p_apont_hist_man912.tip_mov,
               COLUMN 084, p_apont_hist_man912.mat_operador,
               COLUMN 097, p_apont_hist_man912.cod_turno,
               COLUMN 103, p_apont_hist_man912.hor_ini,
               COLUMN 113, p_apont_hist_man912.hor_fim,
               COLUMN 124, p_apont_hist_man912.cod_mov
               
      ON LAST ROW
         
         PRINT COLUMN 001, p_descomprime
   
END REPORT

#-----------------------# 
 FUNCTION pol0651_lista()
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
         LET p_caminho = p_caminho CLIPPED, "pol0651.tmp"
         START REPORT pol0651_imp TO p_caminho
      ELSE
         START REPORT pol0651_imp TO p_nom_arquivo
      END IF
   ELSE
      IF p_ies_impressao = "S" THEN
         START REPORT pol0651_imp TO PIPE p_nom_arquivo
      ELSE
         START REPORT pol0651_imp TO p_nom_arquivo
      END IF
   END IF

   CURRENT WINDOW IS w_pol06511

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_lista CURSOR FOR
    SELECT ordem_producao, operacao, sequencia_operacao, texto_erro       
      FROM man_apont_erro_454
     WHERE empresa = p_cod_empresa
     ORDER BY 1,2,3
     
   FOREACH cq_lista INTO lr_relat.*
      OUTPUT TO REPORT pol0651_imp(lr_relat.*)
      LET l_lista = TRUE
   END FOREACH

   FINISH REPORT pol0651_imp

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
REPORT pol0651_imp(lr_relat)
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

         PRINT COLUMN 001, "pol0651    RELACAO DAS ORDENS DE PRODUCAO IMPORTADAS P/ LOGIX   DATA: ",
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
 FUNCTION pol0651_apont_final()
#-----------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06512") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06512 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consulta" "Consulta Dados da Tabela"
         HELP 001
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0651_consulta_454()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0651_paginacao_454("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0651_paginacao_454("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 006
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0651","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0651_relat_454 TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0651.tmp'
                     START REPORT pol0651_relat_454  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0651_relat_454 TO p_nom_arquivo
               END IF
               CALL pol0651_emite_relatorio_454()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0651_relat_454   
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

   CLOSE WINDOW w_pol06512

END FUNCTION

#-------------------------------#
 FUNCTION pol0651_consulta_454()
#-------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa
   LET p_man_apont_hist_454a.* = p_man_apont_hist_454.*

   CONSTRUCT BY NAME where_clause ON
	   man_apont_hist_454.dat_ini_producao,
	   man_apont_hist_454.dat_fim_producao,
       man_apont_hist_454.item,
       man_apont_hist_454.ordem_producao,
       man_apont_hist_454.operacao,
       man_apont_hist_454.sequencia_operacao
          
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol06512

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_man_apont_hist_454.* = p_man_apont_hist_454a.*
      CALL pol0651_exibe_dados_454()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT rowid FROM man_apont_hist_454 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND empresa = '",p_cod_empresa,"' ",
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
        INTO p_man_apont_hist_454.*
        FROM man_apont_hist_454
       WHERE rowid = p_rowid
      CALL pol0651_exibe_dados_454()
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol0651_exibe_dados_454()
#----------------------------------#

   DISPLAY BY NAME p_man_apont_hist_454.*
   
END FUNCTION

#---------------------------------------#
 FUNCTION pol0651_paginacao_454(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_man_apont_hist_454a.* = p_man_apont_hist_454.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_padrao1 INTO p_rowid
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao1 INTO p_rowid
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_man_apont_hist_454.* = p_man_apont_hist_454a.* 
            EXIT WHILE
         END IF

        SELECT * 
           INTO p_man_apont_hist_454.* 
           FROM man_apont_hist_454
          WHERE rowid = p_rowid
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0651_exibe_dados_454()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0651_emite_relatorio_454()
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
      FROM man_apont_hist_454
      WHERE empresa = p_cod_empresa

   FOREACH cq_apont1 INTO p_man_apont_hist_454.*
   
      OUTPUT TO REPORT pol0651_relat_454() 
  
     LET p_count = p_count + 1
     
  END FOREACH
 
END FUNCTION 

#--------------------------#
 REPORT pol0651_relat_454()
#--------------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 120, "PAG.: ", PAGENO USING "####&"
         PRINT COLUMN 001, 'POL0651',
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

         PRINT COLUMN 001, p_man_apont_hist_454.dat_ini_producao,
               COLUMN 012, p_man_apont_hist_454.dat_fim_producao,
               COLUMN 023, p_man_apont_hist_454.item               USING '##############&',
               COLUMN 039, p_man_apont_hist_454.ordem_producao     USING '##########',
               COLUMN 050, p_man_apont_hist_454.sequencia_operacao USING '##&',
               COLUMN 054, p_man_apont_hist_454.operacao           USING '####&',               
               COLUMN 060, p_man_apont_hist_454.centro_trabalho    USING '####&',
               COLUMN 066, p_man_apont_hist_454.arranjo            USING '####&',
               COLUMN 072, p_man_apont_hist_454.qtd_refugo         USING '######&.&&&',               
               COLUMN 083, p_man_apont_hist_454.qtd_boas           USING '######&.&&&',
               COLUMN 094, p_man_apont_hist_454.tip_movto          USING '&',
               COLUMN 096, p_man_apont_hist_454.local              USING '#########&',
               COLUMN 107, p_man_apont_hist_454.qtd_hor,
               COLUMN 119, p_man_apont_hist_454.matricula          USING '#######&',
               COLUMN 128, p_man_apont_hist_454.sit_apont          USING '&',               
               COLUMN 130, p_man_apont_hist_454.turno              USING '&',                                            
               COLUMN 132, p_man_apont_hist_454.hor_inicial,        
               COLUMN 143, p_man_apont_hist_454.hor_fim,
               COLUMN 154, p_man_apont_hist_454.refugo             USING '#########&',
               COLUMN 165, p_man_apont_hist_454.parada             USING '##&',
               COLUMN 169, p_man_apont_hist_454.hor_ini_parada,
               COLUMN 180, p_man_apont_hist_454.hor_fim_parada,                                                            
               COLUMN 191, p_man_apont_hist_454.unid_funcional     USING '#########&',                                                                           
               COLUMN 202, p_man_apont_hist_454.dat_atualiz,                                                                           
               COLUMN 213, p_man_apont_hist_454.terminado          USING '&',                                                                           
               COLUMN 215, p_man_apont_hist_454.eqpto              USING '##############&',                                                                                          
               COLUMN 231, p_man_apont_hist_454.ferramenta         USING '##############&'
                                                                                                                                                                                                   
      ON LAST ROW
         
         PRINT COLUMN 001, p_descomprime
   
END REPORT

#-----------------------#
 FUNCTION pol0651_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
