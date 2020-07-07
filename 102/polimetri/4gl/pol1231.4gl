#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1231                                                 #
# OBJETIVO: CONSULTA AUDITORIA DE DESBLOQUEAMENTO DE OC             #
# AUTOR...: IVO BL                                                  #
# DATA....: 25/10/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix       

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_nom_funcionario    LIKE usuarios.nom_funcionario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080),
          p_last_row           SMALLINT
END GLOBALS       

DEFINE    p_acesso             CHAR(15),
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
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
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_ies_inclu          SMALLINT,
          P_consulta_ent       CHAR(100),
          P_consulta_sai       CHAR(100),
          p_msg                CHAR(300),
          p_excluiu            SMALLINT,
          p_erro               CHAR(10),
          p_qtd_linha          INTEGER
  
DEFINE p_nom_usuario        LIKE audit_oc_bloq_454.nom_usuario,
       p_audit_oc_bloq_454  RECORD LIKE audit_oc_bloq_454.*

DEFINE pr_item              ARRAY[2000] OF RECORD
       ordem                LIKE audit_oc_bloq_454.num_oc,
       versao               LIKE audit_oc_bloq_454.num_versao,
       operacao             CHAR(15),
       data                 DATE,
       hora                 CHAR(08),
       usuario              CHAR(08),
       funcionario          CHAR(40)
END RECORD
 
DEFINE p_tela               RECORD
       num_oc               LIKE audit_oc_bloq_454.num_oc,
       nom_usuario          LIKE audit_oc_bloq_454.nom_usuario,
       dat_ini              LIKE audit_oc_bloq_454.dat_operacao,
       dat_fim              LIKE audit_oc_bloq_454.dat_operacao
END RECORD   


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1231-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

     IF p_status = 0 THEN
      CALL pol1231_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1231_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1231") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1231 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   LET p_ies_cons  = FALSE
   CALL pol1231_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela"
         CALL pol1231_consulta() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso.'
         ELSE
            CALL pol1231_limpa_tela()
            ERROR 'Operação cancelada.'
         END IF 
      COMMAND "Listar" "Listagem"
         CALL pol1231_listagem()     
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1231_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1231

END FUNCTION

#-----------------------#
 FUNCTION pol1231_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
 FUNCTION pol1231_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#----------------------------#
FUNCTION pol1231_le_usuario()#
#----------------------------#

   SELECT nom_funcionario
     INTO p_nom_funcionario
     FROM usuarios
    WHERE cod_usuario = p_nom_usuario

END FUNCTION

#-----------------------#
 FUNCTION pol1231_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(nom_usuario)
         CALL log009_popup(8,10,"USUARIOS","usuarios",
              "cod_usuario","nom_funcionario","","N","1=1 order by cod_usuario") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN

            DISPLAY p_codigo TO nom_usuario
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1231_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1231_limpa_tela()
   INITIALIZE p_tela TO NULL
   
   LET INT_FLAG          = FALSE

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
      
      AFTER INPUT
         IF INT_FLAG THEN
            CALL pol1231_limpa_tela()
            RETURN FALSE
         END IF

         IF NOT pol1231_le_audit() THEN  
            NEXT FIELD nom_usuario
         END IF
         
   END INPUT 
  
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1231_le_audit()#
#--------------------------#

   DEFINE p_query CHAR(800)
   
   LET p_query = 
      "SELECT num_oc, num_versao, tip_operacao, dat_operacao, hor_operacao, ",
      "       nom_usuario, nom_funcionario ",
      "  FROM audit_oc_bloq_454 a, usuarios u ",
      " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
      "   AND a.nom_usuario LIKE '","%",p_tela.nom_usuario CLIPPED,"%","' ",
      "   AND u.cod_usuario = a.nom_usuario "


   IF p_tela.num_oc IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.num_oc = ", p_tela.num_oc
   END IF
      
   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.dat_operacao >= '",p_tela.dat_ini,"' "
   END IF
   
   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.dat_operacao <= '",p_tela.dat_fim,"' "
   END IF

   LET p_query = p_query CLIPPED, " ORDER BY a.num_oc "
   
   PREPARE var_query FROM p_query
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' preparando query' 
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET p_ind = 1
   INITIALIZE pr_item TO NULL

   DECLARE cq_ocs CURSOR FOR var_query
   FOREACH cq_ocs INTO pr_item[p_ind].*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_ocs')
         RETURN FALSE
      END IF

      CASE pr_item[p_ind].operacao
         WHEN 'L' LET pr_item[p_ind].operacao = 'LIBEROU'
         WHEN 'E' LET pr_item[p_ind].operacao = 'EXCLUIU'
      END CASE

      LET p_ind = p_ind + 1
      
      IF p_ind > 2000 THEN
         LET p_msg = 'Limite de linhas da\n grade ultrapasou.'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
   
   END FOREACH

   IF p_ind = 1 THEN
      LET p_msg = 'Não a dados, para os\n',
                  'parâmetros informados.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET p_qtd_linha = p_ind - 1
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_item TO sr_item.*
   
   RETURN TRUE

END FUNCTION  

#-------------------------#
FUNCTION pol1231_listagem()
#-------------------------#     

   IF NOT pol1231_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1231_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT *
      FROM audit_oc_bloq_454
     ORDER BY num_oc
   
   FOREACH cq_impressao INTO 
           p_audit_oc_bloq_454.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_IMPRESSAO')
         EXIT FOREACH
      END IF      
      
      LET p_nom_usuario = p_audit_oc_bloq_454.nom_usuario
      CALL pol1231_le_usuario()
      
      CASE p_audit_oc_bloq_454.tip_operacao
         WHEN 'L' LET p_acesso = 'LIBEROU'
         WHEN 'E' LET p_acesso = 'EXCLUIU'
      END CASE
      
      OUTPUT TO REPORT pol1231_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1231_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados. "
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
      ERROR 'Relatório gerado com sucesso!!!'
   END IF
  
END FUNCTION 

#------------------------------#
FUNCTION pol1231_escolhe_saida()
#------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1231.tmp"
         START REPORT pol1231_relat TO p_caminho
      ELSE
         START REPORT pol1231_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1231_le_empresa()
#---------------------------#

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

#---------------------#
 REPORT pol1231_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT

      FIRST PAGE HEADER
              
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1231",
               COLUMN 025, "AUDITORIA DE DESBLOQUEAMENTO DE OC",
               COLUMN 060, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'NUM OC    VER    DATA      HORA   USUARIO              NOME           OPERACAO  '
         PRINT COLUMN 001, '--------- --- ---------- -------- -------- -------------------------- ----------'

      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1231",
               COLUMN 025, "AUDITORIA DE DESBLOQUEAMENTO DE OC",
               COLUMN 060, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'NUM OC    VER    DATA      HORA   USUARIO              NOME           OPERACAO  '
         PRINT COLUMN 001, '--------- --- ---------- -------- -------- -------------------------- ----------'
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_audit_oc_bloq_454.num_oc USING '########&',
               COLUMN 011, p_audit_oc_bloq_454.num_versao USING '##&',
               COLUMN 015, p_audit_oc_bloq_454.dat_operacao USING 'dd/mm/yyyy',
               COLUMN 026, p_audit_oc_bloq_454.hor_operacao,
               COLUMN 035, p_audit_oc_bloq_454.nom_usuario,
               COLUMN 044, p_nom_funcionario[1,26],
               COLUMN 071, p_acesso
         
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#