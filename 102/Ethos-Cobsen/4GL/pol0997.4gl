#-----------------------------------------------------------------------#
# SISTEMA.: MRP                                                         #
# PROGRAMA: pol0997                                                     #
# MODULOS.: pol0997-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060             #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500             #
# OBJETIVO: ACERTA TABELA MAN_PRIOR_CONSUMO                             #
# AUTOR...: POLO INFORMATICA - IVO                                      #
# DATA....: 06/10/2006                                                  #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_rowid              INTEGER,
          p_count              INTEGER,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
#          p_versao             CHAR(17),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          p_msg                CHAR(500)
          
   DEFINE p_man_prior_consumo RECORD LIKE man_prior_consumo.*

   DEFINE p_prior_mark        RECORD 
          empresa      char(2),
          tip_docum    char(2),
          docum        char(10),
          item         char(15),
          info_compl_2 INTEGER
   END RECORD
   

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0997-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0997.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#   CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0997_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0997_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0997") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0997 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Processa" "Processa o acerto da tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL log085_transacao("BEGIN")
         WHENEVER ERROR CONTINUE
         IF pol0997_acerta() THEN
            CALL log085_transacao("COMMIT")
            MESSAGE 'Processamento efetuado com sucesso!!!' ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            MESSAGE 'Houve Erro!!! - Processamento cancelado' ATTRIBUTE(REVERSE)
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0997_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0997

END FUNCTION

#------------------------#   
FUNCTION pol0997_acerta()
#------------------------#   

   SELECT COUNT(item)
     INTO p_count
     FROM man_prior_consumo
     
   DISPLAY p_count TO qtd_ant

   MESSAGE 'Aguarde!... Acertando tabela.' ATTRIBUTE(REVERSE)
   
   IF NOT pol0997_cria_tab_temp() THEN
      RETURN FALSE
   END IF

   IF NOT pol0997_acerta_sequencia() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0997_insere_tab_temp() THEN
      RETURN FALSE
   END IF
        
   IF NOT pol0997_deleta_itens_dupl() THEN
      RETURN FALSE
   END IF

   IF NOT pol0997_renumera_prioridade() THEN
      RETURN FALSE
   END IF

   SELECT COUNT(item)
     INTO p_count
     FROM man_prior_consumo
     
   DISPLAY p_count TO qtd_dep

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0997_cria_tab_temp() 
#------------------------------#

   DROP TABLE prior_mark;

   CREATE TEMP TABLE prior_mark
   (
    empresa char(2) not null ,
    tip_docum char(2) not null ,
    docum char(10) not null ,
    item char(15) not NULL,
    info_compl_2 INTEGER
   );

    REVOKE ALL ON prior_mark from "public";

    CREATE UNIQUE INDEX ix_prior_mark
       ON prior_mark(empresa, tip_docum, docum, item, info_compl_2);


   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","prior_mark")
      RETURN FALSE
   END IF

   DROP TABLE prior_mark_compl;

   CREATE TEMP TABLE prior_mark_compl
   (   
    empresa char(2) not null ,
    item char(15) not null ,
    prioridade integer not null ,
    tip_docum char(2) not null ,
    docum char(10) not null ,
    info_compl_1 char(10),
    info_compl_2 integer,
    info_compl_3 char(1),
    qtd_reservada decimal(15,3) not null ,
    qtd_original decimal(15,3),
    prior_atendida char(1) not null ,
    programa_inclusao char(8),
    usuario_inclusao char(8),
    dat_inclusao date,
    programa_alteracao char(8),
    usu_alter char(8),
    dat_alteracao DATE
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","prior_mark_compl")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION  

#----------------------------------#
FUNCTION pol0997_acerta_sequencia()
#----------------------------------#

   UPDATE man_prior_consumo
      SET info_compl_2 = 1
    WHERE info_compl_2 IS NULL OR 
          info_compl_2 = 0
          
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("ALTERAÇÃO","man_prior_consumo")
      RETURN FALSE
   END IF

   RETURN TRUE    

END FUNCTION

#---------------------------------#
FUNCTION pol0997_insere_tab_temp()
#---------------------------------#

   DECLARE cd_insere CURSOR FOR
    SELECT *, rowid
      FROM man_prior_consumo
     ORDER BY empresa, tip_docum, docum, item, info_compl_2
   
   FOREACH cd_insere INTO p_man_prior_consumo.*, p_rowid
      
      INSERT INTO prior_mark_compl
         VALUES(p_man_prior_consumo.*)

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("INSERÇÃO","prior_mark_compl")
         RETURN FALSE
      END IF

      SELECT empresa
        FROM prior_mark
       WHERE empresa      = p_man_prior_consumo.empresa
         AND tip_docum    = p_man_prior_consumo.tip_docum
         AND docum        = p_man_prior_consumo.docum
         AND item         = p_man_prior_consumo.item
         AND info_compl_2 = p_man_prior_consumo.info_compl_2
      
      IF SQLCA.SQLCODE = NOTFOUND THEN

         INSERT INTO prior_mark
            VALUES(p_man_prior_consumo.empresa,
                   p_man_prior_consumo.tip_docum,
                   p_man_prior_consumo.docum,
                   p_man_prior_consumo.item,
                   p_man_prior_consumo.info_compl_2)
                   
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("INSERÇÃO","prior_mark")
            RETURN FALSE
         END IF
      END IF
   
      DELETE FROM man_prior_consumo
       WHERE rowid = p_rowid
       
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("DELEÇÃO","man_prior_consumo")
         RETURN FALSE
      END IF
   
   END FOREACH
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0997_deleta_itens_dupl()
#-----------------------------------#

   DEFINE p_qtd_reservada  LIKE man_prior_consumo.qtd_reservada,
          p_prior_atendida LIKE man_prior_consumo.prior_atendida

   DECLARE cq_deleta CURSOR FOR
    SELECT *
      FROM prior_mark
     ORDER BY 1,2,3,4,5
      
   FOREACH cq_deleta INTO p_prior_mark.*

      LET p_qtd_reservada = 0
      
      SELECT MAX(qtd_reservada)
        INTO p_qtd_reservada
        FROM prior_mark_compl
       WHERE empresa      = p_prior_mark.empresa
         AND tip_docum    = p_prior_mark.tip_docum
         AND docum        = p_prior_mark.docum
         AND item         = p_prior_mark.item
         AND info_compl_2 = p_prior_mark.info_compl_2
         AND prior_atendida IN ('N','P')
         
      IF p_qtd_reservada IS NULL OR SQLCA.sqlcode = NOTFOUND THEN
         LET p_prior_atendida = 'S'
         LET p_qtd_reservada = 0
         SELECT MAX(qtd_reservada)
           INTO p_qtd_reservada
           FROM prior_mark_compl
          WHERE empresa      = p_prior_mark.empresa
            AND tip_docum    = p_prior_mark.tip_docum
            AND docum        = p_prior_mark.docum
            AND item         = p_prior_mark.item
            AND info_compl_2 = p_prior_mark.info_compl_2
            AND prior_atendida IN ('C','S')
            
         IF p_qtd_reservada IS NULL OR SQLCA.SQLCODE = NOTFOUND THEN
            LET p_qtd_reservada = 0
         END IF
      ELSE
         LET p_prior_atendida = 'N'
      END IF
      
      IF p_prior_atendida = 'N' THEN 
         DECLARE cq_aberta CURSOR FOR 
         SELECT *
           FROM prior_mark_compl
          WHERE empresa       = p_prior_mark.empresa
            AND tip_docum     = p_prior_mark.tip_docum
            AND docum         = p_prior_mark.docum
            AND item          = p_prior_mark.item
            AND info_compl_2  = p_prior_mark.info_compl_2
            AND qtd_reservada = p_qtd_reservada
            AND prior_atendida IN ('N','P')
         FOREACH cq_aberta INTO p_man_prior_consumo.*
            EXIT FOREACH
         END FOREACH   
      ELSE
         DECLARE cq_encerrada CURSOR FOR 
         SELECT *
           FROM prior_mark_compl
          WHERE empresa       = p_prior_mark.empresa
            AND tip_docum     = p_prior_mark.tip_docum
            AND docum         = p_prior_mark.docum
            AND item          = p_prior_mark.item
            AND info_compl_2  = p_prior_mark.info_compl_2
            AND qtd_reservada = p_qtd_reservada
            AND prior_atendida IN ('C','S')
         FOREACH cq_encerrada INTO p_man_prior_consumo.*
            EXIT FOREACH
         END FOREACH   
      END IF      

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("LEITURA","prior_mark_compl")
         RETURN FALSE
      END IF
   
      SELECT empresa
        FROM man_prior_consumo
       WHERE empresa       = p_man_prior_consumo.empresa
         AND item          = p_man_prior_consumo.item
         AND prioridade    = p_man_prior_consumo.prioridade
      
      IF SQLCA.SQLCODE = NOTFOUND THEN 
         INSERT INTO man_prior_consumo
           VALUES(p_man_prior_consumo.*)
        
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("INSERÇÃO","man_prior_consumo")
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION 

#------------------------------------#
FUNCTION pol0997_renumera_prioridade()
#------------------------------------#

   DECLARE cq_renumera CURSOR FOR
    SELECT item 
      FROM prior_mark
     GROUP BY item
     ORDER BY item

   FOREACH cq_renumera INTO p_prior_mark.item

      LET p_count = 0
   
      DECLARE cq_man CURSOR FOR
       SELECT item, prioridade, rowid
         FROM man_prior_consumo
        WHERE item = p_prior_mark.item
        ORDER BY prioridade           
        
      FOREACH cq_man INTO
              p_man_prior_consumo.item,
              p_man_prior_consumo.prioridade,
              p_rowid
      
         LET p_count = p_count + 1
         UPDATE man_prior_consumo
            SET prioridade = p_count
          WHERE rowid = p_rowid

         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("ALTERAÇÃO","man_prior_consumo")
            RETURN FALSE
         END IF
          
      END FOREACH
               
   END FOREACH
                    
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol0997_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION