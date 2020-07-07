#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0335                                                 #
# MODULOS.: POL0335 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: LÊ ARQUIVOS DE CONSISTENCIA/CONFIRMAÇÃO DA CATERPILLAR  #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 15/03/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,  
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          p_houve_erro           SMALLINT,
          comando                CHAR(80),
       #   p_versao               CHAR(17),
          p_versao               CHAR(18),
          p_nom_tela             CHAR(080),
          p_nom_help             CHAR(200),
          p_ies_cons             SMALLINT,
          p_arquivo              CHAR(80),
          p_last_row             SMALLINT,
          p_count                SMALLINT,
          p_descomprime          CHAR(01),
          p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_caminho              CHAR(080),
          p_msg                  CHAR(500)
         
END GLOBALS

   DEFINE mr_confir_cater_ethos  RECORD LIKE confir_cater_ethos.*,
          mr_confir_cater_ethosr RECORD LIKE confir_cater_ethos.*,
          m_nom_arquivo          CHAR(76)

   DEFINE mr_tela                RECORD
       dat_movto                 CHAR(10), 
       hor_movto                 CHAR(8), 
       dat_proces                DATE,
       hor_proces                DATETIME HOUR TO SECOND,
       texto_1                   CHAR(40),
       texto_2                   CHAR(40),
       texto_3                   CHAR(40)
                                  END RECORD    

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0335-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0335.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  #  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0335_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0335_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0335") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0335 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informa o caminho do arquivo."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0335","IN") THEN
            IF pol0335_entrada_dados() THEN
               NEXT OPTION "Processar"
            ELSE
               ERROR 'Operação Cancelada.'
            END IF
         END IF
      COMMAND "Processar" "Processa a leitura dos arquivos EDI."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0335","IN") THEN
            CALL pol0335_processa() 
         END IF
      
      COMMAND "Consultar" "Consulta o arquivo de consistência/confirmação"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0335","CO") THEN
            CALL pol0335_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      
      COMMAND "Seguinte" "Exibe o Próximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0335_paginacao("SEGUINTE")
      
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0335_paginacao("ANTERIOR") 
      
      COMMAND "Listar" "Imprime Relatório da Programação."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0335","MO") THEN
            CALL pol0335_imprime_relat()
            NEXT OPTION "Fim"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0335_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0335

END FUNCTION

#-------------------------------#
 FUNCTION pol0335_entrada_dados()
#-------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0335

   INITIALIZE m_nom_arquivo TO NULL
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT m_nom_arquivo WITHOUT DEFAULTS
    FROM nom_arquivo 

   AFTER FIELD nom_arquivo
      IF m_nom_arquivo IS NULL OR
         m_nom_arquivo = ' ' THEN 
         IF INT_FLAG = 0 THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD nom_arquivo
         END IF
      END IF

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0335
   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE 
      RETURN TRUE
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF      

END FUNCTION

#--------------------------#
 FUNCTION pol0335_processa()
#--------------------------#
   DEFINE l_texto             CHAR(128),
          l_dat_hora          CHAR(12)

   MESSAGE "Processando..." ATTRIBUTE(REVERSE)                                                             
   WHENEVER ERROR CONTINUE
     DELETE FROM confir_cater_ethos
   WHENEVER ERROR STOP 

   CALL pol0335_cria_temporaria()

   CALL log150_procura_caminho ('LST') RETURNING p_arquivo

   LET p_arquivo = p_arquivo CLIPPED, m_nom_arquivo 

   WHENEVER ERROR CONTINUE
       LOAD FROM p_arquivo INSERT INTO w_conf_temp        
   WHENEVER ERROR STOP 
  
   IF sqlca.sqlcode = -805 THEN
      ERROR 'Arquivo não encontrado no diretório ',p_arquivo
      RETURN
   ELSE
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("CRIACAO","W_CONF_TEMP")
         RETURN 
      END IF
   END IF
   
   WHENEVER ERROR CONTINUE
     SELECT texto[14,25]
       INTO l_dat_hora
       FROM w_conf_temp
      WHERE texto[1,3] = 'ITP'
   WHENEVER ERROR STOP 

   LET mr_tela.dat_movto  = l_dat_hora[5,6],'/',
                            l_dat_hora[3,4],'/20', 
                            l_dat_hora[1,2] 
   LET mr_tela.hor_movto  = l_dat_hora[7,8],':',
                            l_dat_hora[9,10],':',
                            l_dat_hora[11,12]
   LET mr_tela.dat_proces = TODAY
   LET mr_tela.hor_proces = CURRENT HOUR TO SECOND

   DECLARE cq_conf CURSOR FOR
    SELECT * 
      FROM w_conf_temp
     WHERE texto[1,3] = 'TE1'
   FOREACH cq_conf INTO l_texto 
    
      LET mr_tela.texto_1 = l_texto[4,43]
      LET mr_tela.texto_2 = l_texto[44,83]
      LET mr_tela.texto_3 = l_texto[84,123]

      WHENEVER ERROR CONTINUE
        INSERT INTO confir_cater_ethos VALUES (p_cod_empresa,
                                               mr_tela.dat_movto,
                                               mr_tela.hor_movto,
                                               mr_tela.dat_proces,
                                               mr_tela.hor_proces,
                                               mr_tela.texto_1,
                                               mr_tela.texto_2,
                                               mr_tela.texto_3,
                                               0) 

      WHENEVER ERROR STOP 
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO","CONFIR_CATER_ETHOS")
         RETURN 
      END IF

   END FOREACH
 
   MESSAGE "Fim de Processando..." ATTRIBUTE(REVERSE)                                                             
END FUNCTION

#---------------------------------#
 FUNCTION pol0335_cria_temporaria()
#---------------------------------#

   WHENEVER ERROR CONTINUE
      DROP TABLE w_conf_temp;

      CREATE TABLE w_conf_temp
         (
          texto              CHAR(128)
         )

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("CRIACAO","W_CONF_TEMP")
      END IF

   WHENEVER ERROR STOP

END FUNCTION     

#--------------------------#
 FUNCTION pol0335_consulta()
#--------------------------#
   DEFINE sql_stmt            CHAR(500)

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0335

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      CALL pol0335_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * ",
                  "  FROM confir_cater_ethos ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  " ORDER BY num_transac "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_confir_cater_ethos.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0335_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0335_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_confir_cater_ethos.cod_empresa,
                   mr_confir_cater_ethos.dat_movto,
                   mr_confir_cater_ethos.hor_movto,
                   mr_confir_cater_ethos.dat_proces,
                   mr_confir_cater_ethos.hor_proces,
                   mr_confir_cater_ethos.texto_1,
                   mr_confir_cater_ethos.texto_2,
                   mr_confir_cater_ethos.texto_3

END FUNCTION

#-----------------------------------#
 FUNCTION pol0335_paginacao(l_funcao)
#-----------------------------------#
   DEFINE l_funcao CHAR(20)

   IF p_ies_cons THEN
      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_confir_cater_ethos.* 
            WHEN l_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_confir_cater_ethos.* 
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção"
            EXIT WHILE
         END IF
        
         SELECT *
           INTO mr_confir_cater_ethos.* 
           FROM confir_cater_ethos   
          WHERE cod_empresa = mr_confir_cater_ethos.cod_empresa
            AND num_transac = mr_confir_cater_ethos.num_transac 
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0335_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 

#-------------------------------#
 FUNCTION pol0335_imprime_relat()
#-------------------------------#
   IF log028_saida_relat(13,29) IS NOT NULL THEN
      MESSAGE " Processando a Extração do Relatório..." ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0335_relat TO PIPE p_nom_arquivo
         ELSE
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0335.tmp'
            START REPORT pol0335_relat  TO p_caminho
         END IF
      ELSE
         START REPORT pol0335_relat TO p_nom_arquivo
      END IF

      CALL pol0335_emite_relatorio()

      IF p_count = 0 THEN
         ERROR "Não Existem Dados para serem Listados"
         RETURN
      ELSE
         ERROR "Relatório Processado com Sucesso"             
      END IF
      FINISH REPORT pol0335_relat
   ELSE
      ERROR "Listagem Cancelada."
      RETURN
   END IF
   IF p_ies_impressao = "S" THEN
      MESSAGE "Relatório Impresso na Impressora ", p_nom_arquivo
          ATTRIBUTE(REVERSE)
      IF g_ies_ambiente = "W" THEN
         LET comando = "lpdos.bat ", p_caminho CLIPPED, " ",p_nom_arquivo
         RUN comando
      END IF
   ELSE
      MESSAGE "Relatório Gravado no Arquivo ",p_nom_arquivo," "
          ATTRIBUTE(REVERSE)
   END IF

END FUNCTION           

#---------------------------------#
 FUNCTION pol0335_emite_relatorio()
#---------------------------------#
   DEFINE lr_relat          RECORD
       dat_movto                DATE,
       hor_movto                LIKE confir_cater_ethos.hor_movto,
       dat_proces               DATE,
       hor_proces               LIKE confir_cater_ethos.hor_proces,
       texto_1                  LIKE confir_cater_ethos.texto_1,
       texto_2                  LIKE confir_cater_ethos.texto_2,
       texto_3                  LIKE confir_cater_ethos.texto_3
                             END RECORD

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa                      

   DECLARE cq_relat CURSOR FOR
    SELECT dat_movto, hor_movto, dat_proces, hor_proces, 
           texto_1, texto_2, texto_3 
      FROM confir_cater_ethos

   FOREACH cq_relat INTO lr_relat.*

      OUTPUT TO REPORT pol0335_relat(lr_relat.*)

      INITIALIZE lr_relat.* TO NULL
      LET p_count = p_count + 1

   END FOREACH                  

END FUNCTION

#-----------------------------#
 REPORT pol0335_relat(lr_relat)
#-----------------------------#
   DEFINE lr_relat          RECORD
       dat_movto                DATE,
       hor_movto                LIKE confir_cater_ethos.hor_movto,
       dat_proces               DATE,
       hor_proces               LIKE confir_cater_ethos.hor_proces,
       texto_1                  LIKE confir_cater_ethos.texto_1,
       texto_2                  LIKE confir_cater_ethos.texto_2,
       texto_3                  LIKE confir_cater_ethos.texto_3
                             END RECORD

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1 

   ORDER EXTERNAL BY lr_relat.dat_movto,
                     lr_relat.hor_movto

  FORMAT
      PAGE HEADER

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 038, "RELATORIO DE CONFIRMAÇÃO/CONSISTENCIA",
               COLUMN 078, "PAG.: ", PAGENO USING "####"
         PRINT COLUMN 001, "POL0335",
               COLUMN 074, "DATA: ", TODAY USING "DD/MM/YY"
         PRINT COLUMN 001, "----------------------------------------",
                           "--------------------------------------------"
         PRINT COLUMN 001, "DATA/HORA MOVIMENTO",
               COLUMN 021, "DATA/HORA PROCESSAMENTO",
               COLUMN 045, "TEXTO"
         PRINT COLUMN 001, "------------------- ",
                           "----------------------- ",
                           "----------------------------------------"
      ON EVERY ROW

         PRINT COLUMN 001, lr_relat.dat_movto,' ',
                           lr_relat.hor_movto,
               COLUMN 025, lr_relat.dat_proces,' ',
                           lr_relat.hor_proces,
               COLUMN 045, lr_relat.texto_1
         PRINT COLUMN 045, lr_relat.texto_2
         PRINT COLUMN 045, lr_relat.texto_3
        
         SKIP 1 LINE

      ON LAST ROW
         PRINT COLUMN 001, p_descomprime
         
END REPORT                       

#-----------------------#
 FUNCTION pol0335_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION