#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1227                                                 #
# OBJETIVO: DESBLOQUEIO DE ORDENS DE COMPRA                         #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 23/05/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_last_row           SMALLINT,
          p_caminho            CHAR(080)

END GLOBALS

   DEFINE p_salto              SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho_jar        CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_texto              CHAR(10),
          p_linha              CHAR(30),
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT,
          p_erro               CHAR(10),
          p_qtd_linha          INTEGER,
          p_motivo             CHAR(240),
          p_causa              CHAR(30),
          p_aprovar            CHAR(01),
          p_preco_ant          DECIMAL(12,2)
          
   DEFINE p_den_item           LIKE item.den_item,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_raz_social         LIKE fornecedor.raz_social
                   
   DEFINE p_dat_atu            DATE,
          p_hor_atu            CHAR(08),
          p_cod_funcao         CHAR(01),
          p_ies_imprimiu       SMALLINT,
          p_dat_ini            DATE,
          p_dat_fim            DATE,
          p_query              CHAR(800),
          p_mot_01             CHAR(65),
          p_mot_02             CHAR(65),
          p_mot_03             CHAR(65)
          
   DEFINE pr_aprovar           ARRAY[1000] OF RECORD
          aprovar              CHAR(01),
          ordem                INTEGER,
          item                 CHAR(15),
          fornecedor           CHAR(15),
          preco                DECIMAL(12,2),
          preco_ant            DECIMAL(12,2)
   END RECORD

   DEFINE pr_compl             ARRAY[1000] OF RECORD
          num_versao           INTEGER,
          ies_situa_oc         CHAR(01),
          dat_emis             DATE,
          causa                CHAR(30),
          motivo               CHAR(210)
   END RECORD

   DEFINE p_parametro     RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
   END RECORD

   DEFINE p_tela           RECORD
          num_oc           integer,
          ies_situa_oc     char(01),
          dat_emis_ini     date,
          dat_emis_fim     date,
          cod_item         char(15),
          den_item         char(50),
          cod_fornecedor   char(15),
          raz_social       char(50)
   END RECORD

   DEFINE p_relat          RECORD
          cod_empresa  char(02),     
          num_oc       integer,      
          pre_unit_oc  decimal(17,6),
          pre_unit_ant decimal(17,6),
          causa        char(30),     
          tip_liberac  char(01),     
          motivo       char(210),    
          nom_usuario  char(08),     
          dat_liberac  date,         
          hor_liberac  char(08),
          oc_pre_ant   integer
   END RECORD
             
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1227-10.02.11"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   #LET p_cod_empresa = '21'
   #LET p_status = 0
   #LET p_user = 'admlog'

   IF NOT pol1227_le_usuario() THEN
      RETURN FALSE
   END IF
   
   LET p_parametro.num_programa = 'POL1227'
   LET p_parametro.cod_empresa = p_cod_empresa
   LET p_parametro.usuario = p_user
  
   IF p_status = 0 THEN
      CALL pol1227_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1227_menu()
#----------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1227") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1227 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consultar as ordens bloqueadas"
         CALL pol1227_informar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            NEXT OPTION "Processar"
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            LET p_ies_cons = FALSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Modificar" "Liberar as OC's selecionadas"
         IF p_ies_cons THEN
            IF pol1227_modificar() THEN
            ELSE
               CALL pol1227_limpa_tela()
               ERROR 'Operação cancela !!!'
            END IF
            LET p_ies_cons = FALSE
         ELSE
             ERROR 'Informe os parâmetros previamente !!!'
             NEXT OPTION 'Informar'
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1227_sobre() 
      COMMAND "Listar" "Listagem das ordens liberadas"
         CALL pol1227_relatorio() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1227

END FUNCTION

#------------------------#
 FUNCTION pol1227_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1227_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#----------------------------#
FUNCTION pol1227_le_usuario()#
#----------------------------#

   SELECT cod_funcao
     INTO p_cod_funcao
     FROM usuario_desblok_oc_1099
    WHERE nom_usuario = p_user

   IF STATUS = 100 THEN
      LET p_cod_funcao = NULL
      LET p_msg = 'Usuário  não  autorizado a usar\n',
                  'essa função. Consulte o POL1228'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'usuario_desblok_oc_1099')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION
          
#--------------------------#
FUNCTION pol1227_informar()#
#--------------------------#

   CALL pol1227_limpa_tela()

   IF NOT pol1227_le_usuario() THEN
      RETURN FALSE
   END IF

   INITIALIZE p_tela TO NULL
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
      
      AFTER INPUT
         IF INT_FLAG THEN
            CALL pol1227_limpa_tela()
            RETURN FALSE
         END IF

   END INPUT 

   IF NOT pol1227_le_ocs() THEN  
      CALL pol1227_limpa_tela()
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1227_le_ocs()#
#------------------------#

   CALL pol1227_monta_query()
   CALL pol1227_carrega_dados()

   INPUT ARRAY pr_aprovar WITHOUT DEFAULTS FROM sr_aprovar.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  

         IF pr_aprovar[p_ind].item IS NOT NULL THEN
            CALL pol1227_exibe_cabec()         
         END IF
         
      BEFORE FIELD aprovar
         LET p_aprovar = pr_aprovar[p_ind].aprovar
         
      AFTER FIELD aprovar

         IF pr_aprovar[p_ind].aprovar <> p_aprovar THEN
            LET pr_aprovar[p_ind].aprovar = p_aprovar
            DISPLAY p_aprovar TO sr_aprovar[s_ind].aprovar
            NEXT FIELD aprovar
         END IF

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_ind >= p_qtd_linha THEN
               LET p_aprovar = pr_aprovar[p_ind].aprovar
               NEXT FIELD aprovar
            END IF
         END IF                     

      ON KEY (control-p)
         IF pr_aprovar[p_ind].aprovar IS NOT NULL THEN
            #CALL pol1227_exibe_entrega()
         END IF
         
   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION  

#-----------------------------#
FUNCTION pol1227_monta_query()#
#-----------------------------#

   LET p_query = 
      "SELECT num_oc, num_versao, cod_item, ",
      " cod_fornecedor, pre_unit_oc, ies_situa_oc, dat_emis ",
      "  FROM ordem_sup WHERE cod_empresa = '",p_cod_empresa,"' ",
      "   AND ies_situa_oc = 'X' ",
      "   AND ies_versao_atual = 'S' "

   IF p_tela.num_oc IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND num_oc = ", p_tela.num_oc
   END IF
   
   IF p_tela.dat_emis_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND dat_emis >= '",p_tela.dat_emis_ini,"' "
   END IF
   
   IF p_tela.dat_emis_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND dat_emis <= '",p_tela.dat_emis_fim,"' "
   END IF

   IF p_tela.cod_item IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND cod_item <= '",p_tela.cod_item,"' "
   END IF

   IF p_tela.cod_fornecedor IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND cod_fornecedor <= '",p_tela.cod_fornecedor,"' "
   END IF
   
   LET p_query = p_query CLIPPED, " ORDER BY dat_emis, cod_fornecedor, cod_item "

END FUNCTION

#-------------------------------#
FUNCTION pol1227_carrega_dados()#
#-------------------------------#
   
   PREPARE var_query FROM p_query
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' preparando query' 
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET p_ind = 1
   INITIALIZE pr_aprovar, pr_compl TO NULL
   
   DECLARE cq_ocs CURSOR FOR var_query
   FOREACH cq_ocs INTO 
           pr_aprovar[p_ind].ordem,  
           pr_compl[p_ind].num_versao,   
           pr_aprovar[p_ind].item,      
           pr_aprovar[p_ind].fornecedor,
           pr_aprovar[p_ind].preco,     
           pr_compl[p_ind].ies_situa_oc,
           pr_compl[p_ind].dat_emis

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_ocs')
         RETURN FALSE
      END IF

      CALL pol1227_le_preco_ant(pr_aprovar[p_ind].ordem)

      IF p_preco_ant = 0 THEN
         LET p_preco_ant = NULL
      END IF
      
      LET pr_aprovar[p_ind].preco_ant = p_preco_ant
      LET pr_compl[p_ind].causa = p_causa
      LET pr_compl[p_ind].motivo = p_motivo
      LET pr_aprovar[p_ind].aprovar = 'N'
      
      LET p_ind = p_ind + 1
   
   END FOREACH

   IF p_ind = 1 THEN
      LET p_msg = 'Não a dados, para os\n',
                  'parâmetros informados.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET p_qtd_linha = p_ind - 1
   CALL SET_COUNT(p_ind - 1)
   LET INT_FLAG = FALSE
   
END FUNCTION
     

#----------------------------------#
FUNCTION pol1227_le_preco_ant(p_oc)#
#----------------------------------#

   DEFINE p_oc integer
   
   SELECT pre_unit_ant, 
          causa,
          motivo
     INTO p_preco_ant,
          p_causa,
          p_motivo
     FROM oc_bloqueada_1099
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT',  'oc_bloqueada_1099')
   END IF

END FUNCTION             

#-------------------------------#
FUNCTION pol1227_le_item(p_item)#
#-------------------------------#

   DEFINE p_item CHAR(15)
   
   SELECT den_item,
          den_item_reduz
     INTO p_den_item,
          p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
   END IF
   
END FUNCTION

#---------------------------------------#
FUNCTION pol1227_le_fornecedor(p_fornec)#
#---------------------------------------#

   DEFINE p_fornec CHAR(15)
   
   SELECT raz_social
     INTO p_raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_fornec

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fornecedor')
   END IF
   
END FUNCTION

#---------------------------#
FUNCTION pol1227_modificar()#
#---------------------------#

   IF NOT pol1227_le_usuario() THEN
      RETURN FALSE
   END IF

   IF p_cod_funcao <> 'L' THEN
      LET p_msg = 'Usuário  não  autorizado a fazer\n',
                  'modificações. Consulte o POL1228'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN TRUE
   END IF
   
   DISPLAY 'A-Aumento C-Condicional  /  Ctrl+T = Motivo' AT 23,20 
   
   CALL pol1227_carrega_dados()
   
   INPUT ARRAY pr_aprovar
      WITHOUT DEFAULTS FROM sr_aprovar.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  

         IF pr_aprovar[p_ind].item IS NOT NULL THEN
            CALL pol1227_exibe_cabec()         
         END IF
         
      BEFORE FIELD aprovar
         LET p_aprovar = pr_aprovar[p_ind].aprovar
         
      AFTER FIELD aprovar

         IF pr_aprovar[p_ind].aprovar MATCHES '[ACN]' THEN
         ELSE
            LET p_msg = 'Informe:\n',
                        'A=Aumento de preçõ\n',
                        'C=Condicional\n',
                        'N=Não desbloquear'
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD aprovar
         END IF

         IF pr_aprovar[p_ind].aprovar MATCHES '[AC]' THEN
            IF pr_aprovar[p_ind].aprovar <> p_aprovar THEN
               CALL pol1227_info_motivo()
               LET p_aprovar = pr_aprovar[p_ind].aprovar
               NEXT FIELD aprovar
            END IF
         ELSE
            LET pr_compl[p_ind].motivo = NULL
         END IF
         
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_ind >= p_qtd_linha THEN
               LET p_aprovar = pr_aprovar[p_ind].aprovar
               NEXT FIELD aprovar
            END IF
         END IF                     

      ON KEY (control-t)
         IF pr_aprovar[p_ind].aprovar = 'N' THEN
         ELSE
            CALL pol1227_info_motivo()
         END IF

      ON KEY (control-p)
         IF pr_aprovar[p_ind].aprovar IS NOT NULL THEN
            #CALL pol1227_exibe_entrega()
         END IF
         
      AFTER INPUT
       
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         LET p_count = 0
         
         FOR p_index = 1 TO p_qtd_linha
            IF pr_aprovar[p_index].aprovar MATCHES '[AC]' THEN
               LET p_count = p_count + 1
               EXIT FOR
            END IF
         END FOR
         
         IF p_count = 0 THEN
            LET p_msg = 'Nenhuma OC foi selecionada\n para desbloquear'
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD aprovar
         END IF
               
   END INPUT

   LET p_msg = 'Confirma a liberação das\n Ordens selecionadas?'

   IF NOT log0040_confirm(20,25,p_msg) THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1227_grava_modificaoes() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")

   ERROR 'Operação efetuada com sucesso !!!'

   RETURN TRUE
   
END FUNCTION   

#-----------------------------#
FUNCTION pol1227_exibe_cabec()#
#-----------------------------#

   CALL pol1227_le_item(pr_aprovar[p_ind].item)
   CALL pol1227_le_fornecedor(pr_aprovar[p_ind].fornecedor)
   
   LET p_tela.num_oc = pr_aprovar[p_ind].ordem
   LET p_tela.cod_item = pr_aprovar[p_ind].item
   LET p_tela.cod_fornecedor = pr_aprovar[p_ind].fornecedor
   LET p_tela.ies_situa_oc = pr_compl[p_ind].ies_situa_oc
   LET p_tela.dat_emis_ini = pr_compl[p_ind].dat_emis
   LET p_tela.dat_emis_fim = NULL
   LET p_causa = pr_compl[p_ind].causa
   LET p_motivo = pr_compl[p_ind].motivo
   
   DISPLAY by NAME p_tela.*
   DISPLAY p_den_item TO den_item
   DISPLAY p_raz_social to raz_social
   DISPLAY p_causa TO causa
   DISPLAY p_motivo TO motivo
   
END FUNCTION

#-----------------------------#
FUNCTION pol1227_info_motivo()#
#-----------------------------#
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1227b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1227b AT 10,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1227_dig_motivo()

   CLOSE WINDOW w_pol1227b
   
   CURRENT WINDOW IS w_pol1227
   
   DISPLAY p_motivo TO motivo
   
END FUNCTION

#----------------------------#
FUNCTION pol1227_dig_motivo()#
#----------------------------#

   LET p_motivo = pr_compl[p_ind].motivo
   
   INPUT p_motivo WITHOUT DEFAULTS
     FROM motivo

      BEFORE FIELD motivo
         DISPLAY p_motivo to motivo

      AFTER FIELD motivo
         
         IF p_motivo IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD p_motivo
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
       LET INT_FLAG = FALSE
        RETURN
   END IF
         
   LET pr_compl[p_ind].motivo = p_motivo

END FUNCTION

#-----------------------------------#
FUNCTION pol1227_grava_modificaoes()#
#-----------------------------------#

   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   
   FOR p_ind = 1 to p_qtd_linha
       
       IF pr_aprovar[p_ind].aprovar MATCHES '[AC]' THEN
          IF NOT pol1227_libera_oc() THEN
             RETURN FALSE
          END IF
       END IF
              
   END FOR
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#   
FUNCTION pol1227_libera_oc()#
#---------------------------#

   UPDATE ordem_sup
      SET ies_situa_oc = 'A'
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = pr_aprovar[p_ind].ordem
      AND ies_versao_atual = 'S'
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'ordem_sup')
      RETURN FALSE
   END IF

   UPDATE prog_ordem_sup
      SET ies_situa_prog = 'F'
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = pr_aprovar[p_ind].ordem
      AND num_versao = pr_compl[p_ind].num_versao
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'prog_ordem_sup')
      RETURN FALSE
   END IF

   IF NOT pol1227_atu_oc_bloq() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1227_atu_oc_bloq()#
#-----------------------------#

   UPDATE oc_bloqueada_1099 
      SET motivo = pr_compl[p_ind].motivo,
          tip_liberac = pr_aprovar[p_ind].aprovar,
          nom_usuario = p_user,
          dat_liberac = p_dat_atu,
          hor_liberac = p_hor_atu
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = pr_aprovar[p_ind].ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'OC_BLOQUEADA_1099')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1227_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1227_relatorio()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1227a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1227a AT 07,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1227_gera_relat()

   CLOSE WINDOW w_pol1227a

END FUNCTION

#---------------------------#
FUNCTION pol1227_gera_relat()#
#---------------------------#
   
   INITIALIZE p_dat_ini, p_dat_fim TO NULL
   LET INT_FLAG = FALSE
      
   INPUT p_dat_ini,
         p_dat_fim WITHOUT DEFAULTS
         FROM dat_ini, dat_fim
      
      AFTER INPUT
         
         IF INT_FLAG THEN  
            RETURN
         END IF 
         
         IF p_dat_ini IS NOT NULL AND 
            p_dat_fim IS NOT NULL THEN
            IF p_dat_ini > p_dat_fim THEN
               ERROR 'Período inválido.'
               NEXT FIELD dat_ini
            END IF
         END IF
                 
   END INPUT

   IF log0280_saida_relat(18,35) IS NULL THEN
      RETURN
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1227_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1227.tmp'
         START REPORT pol1227_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1227_relat TO p_nom_arquivo
   END IF
      
   IF NOT pol1227_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   LET p_ies_imprimiu = FALSE

   LET p_query = 
      "SELECT * FROM oc_bloqueada_1099 ",
      " WHERE cod_empresa = '",p_cod_empresa,"' ",
      "   AND tip_liberac <> 'N' "
      
 
   IF p_dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND dat_liberac >= '",p_dat_ini,"' "
   END IF
   
   IF p_dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND dat_liberac <= '",p_dat_fim,"' "
   END IF
      
   LET p_query = p_query CLIPPED, " ORDER BY nom_usuario, dat_liberac "
   
   PREPARE rel_query FROM p_query
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','REL_QUERY')
      RETURN 
   END IF
   
   DECLARE cq_relat CURSOR FOR rel_query
   FOREACH cq_relat INTO p_relat.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_RELAT')
         EXIT FOREACH 
      END IF
      
      IF LENGTH(p_relat.motivo) <= 65 THEN
         LET p_mot_01 = p_relat.motivo
         INITIALIZE p_mot_02, p_mot_03 TO NULL
      ELSE
         CALL pol1161_quebrar_texto(p_relat.motivo,65,3,'N')
            RETURNING p_mot_01, p_mot_02, p_mot_03
      END IF
         
      OUTPUT TO REPORT pol1227_relat() 
      LET p_ies_imprimiu = TRUE

   END FOREACH

   FINISH REPORT pol1227_relat   
   
   IF NOT p_ies_imprimiu THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#----------------------#
 REPORT pol1227_relat()#
#----------------------#
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 66
          
   FORMAT

   FIRST PAGE HEADER
	  
      PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

      PRINT COLUMN 001,  p_den_empresa, 
            COLUMN 134, "PAG. ", PAGENO USING "##&"
      PRINT COLUMN 001, "POL1227",
            COLUMN 036, "LIBERACAO DE ORDENS",
            COLUMN 068, "PRERIODO:",
            COLUMN 078, p_dat_ini USING 'dd/mm/yyyy', " - ", p_dat_fim USING 'dd/mm/yyyy',
            COLUMN 123, "EMISSAO: ", TODAY USING 'dd/mm/yyyy'
            
      PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------------------"
      PRINT
         
      PRINT COLUMN 001, 'ORDEM     PRECO UNIT   PRECO ANT  / OC       USUARIO  DAT LIBER  HORA    TIP MOTIVO DA LIBERACAO'                  
      PRINT COLUMN 001, '--------- ------------ --------------------- -------- ---------- -------- - -----------------------------------------------------------------'

   PAGE HEADER
	  
      PRINT COLUMN 001,  p_den_empresa, 
            COLUMN 134, "PAG. ", PAGENO USING "##&"
      PRINT COLUMN 001, "POL1227",
            COLUMN 036, "LIBERACAO DE ORDENS",
            COLUMN 068, "PRERIODO:",
            COLUMN 078, p_dat_ini USING 'dd/mm/yyyy', " - ", p_dat_fim USING 'dd/mm/yyyy',
            COLUMN 123, "EMISSAO: ", TODAY USING 'dd/mm/yyyy'
            
      PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------------------------------------------"
      PRINT
         
      PRINT COLUMN 001, 'ORDEM     PRECO UNIT   PRECO ANT  / OC       USUARIO  DAT LIBER  HORA    TIP MOTIVO DA LIBERACAO'                  
      PRINT COLUMN 001, '--------- ------------ --------------------- -------- ---------- -------- - -----------------------------------------------------------------'

   ON EVERY ROW

      PRINT COLUMN 001, p_relat.num_oc USING '########&',
            COLUMN 011, p_relat.pre_unit_oc USING '#,###,##&.&&',
            COLUMN 024, p_relat.pre_unit_ant USING '#,###,##&.&&',
            COLUMN 037, p_relat.oc_pre_ant USING '#######&',
            COLUMN 046, p_relat.nom_usuario,
            COLUMN 055, p_relat.dat_liberac USING 'dd/mm/yyyy',
            COLUMN 066, p_relat.hor_liberac,
            COLUMN 075, p_relat.tip_liberac,
            COLUMN 077, p_mot_01
      
      IF p_mot_02 IS NULL THEN
      ELSE
         PRINT COLUMN 068, p_mot_02
      END IF

      IF p_mot_03 IS NULL THEN
      ELSE
         PRINT COLUMN 068, p_mot_03
      END IF

   ON LAST ROW
   
      LET p_last_row = TRUE

   PAGE TRAILER

     IF p_last_row = TRUE THEN 
        PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
     ELSE 
        PRINT " "
     END IF
        
END REPORT
             