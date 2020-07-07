#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1230                                                 #
# OBJETIVO: LIBERAÇÃO / EXCLUSÃO DE ORDENS BLOQUADAS                #
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

DEFINE p_num_oc             INTEGER,
       p_num_versao         INTEGER,
       p_cod_item           CHAR(15),
       p_den_item           CHAR(76),
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
       p_msg                CHAR(300),
       p_erro               CHAR(10),
       p_qtd_linha          INTEGER,
       p_dat_atu            DATE,
       p_hor_atu            CHAR(08),
       p_operacao           CHAR(01),
       p_tip_acesso         CHAR(01)
 
DEFINE p_tela               RECORD
       cod_lin_prod         DECIMAL(2,0),
       cod_item             CHAR(15),
       dat_ini              DATE,
       dat_fim              DATE
END RECORD   

DEFINE pr_item              ARRAY[2000] OF RECORD
       operacao             CHAR(01),
       linha                CHAR(30),
       item                 CHAR(15),       
       ordem                INTEGER,
       entrega              DATE,
       seq_periodo         INTEGER
END RECORD

DEFINE pr_compl             ARRAY[2000] OF RECORD
       num_versao           INTEGER
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1230-10.02.06"
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

     IF p_status = 0 THEN
      CALL pol1230_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1230_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1230") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1230 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   LET p_ies_cons  = FALSE
   CALL pol1230_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta ordens bloqueadas"
         CALL pol1230_informar() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            ERROR 'Operação efetuada com sucesso.'
            NEXT OPTION 'Processar'
         ELSE
            LET p_ies_cons = FALSE
            CALL pol1230_limpa_tela()
            ERROR 'Operação cancelada.'
            NEXT OPTION 'Fim'
         END IF 
      COMMAND "Modificar" "Selecionar, liberar ou excluir ordens"
         IF p_ies_cons THEN
            LET p_ies_cons = FALSE
            IF pol1230_selecionar() THEN
               ERROR 'Operação efetuada com sucesso.'
            ELSE
               ERROR 'Operação cancelada.'
            END IF 
         ELSE
            ERROR 'Informe previamente os parâmetros'
            NEXT OPTION 'Informar'
         END IF
         NEXT OPTION 'Fim'
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1230_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1230

END FUNCTION

#-----------------------#
 FUNCTION pol1230_sobre()
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
 FUNCTION pol1230_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION


#--------------------------#
 FUNCTION pol1230_informar()
#--------------------------#

   CALL pol1230_limpa_tela()
   INITIALIZE p_tela TO NULL
   
   LET INT_FLAG = FALSE

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      ON KEY (control-z)
         CALL pol1230_popup()
      
      AFTER INPUT
         IF INT_FLAG THEN
            CALL pol1230_limpa_tela()
            RETURN FALSE
         END IF

         IF NOT pol1230_le_ocs() THEN  
            NEXT FIELD cod_lin_prod
         END IF
         
   END INPUT 
  
   RETURN TRUE

END FUNCTION

#------------------------#
 FUNCTION pol1230_popup()#
#------------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_lin_prod)
         LET p_codigo = pol1230_le_linhas()
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_lin_prod = p_codigo
           DISPLAY p_codigo TO cod_lin_prod
         END IF
   END CASE 

END FUNCTION 

#---------------------------#
 FUNCTION pol1230_le_linhas()
#---------------------------#

   DEFINE pr_itens     ARRAY[200] OF RECORD
          cod_lin_prod      DECIMAL(2,0),
          den_estr_linprod  CHAR(30)
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1230a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1230a AT 5,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_itens CURSOR FOR
   
    SELECT cod_lin_prod,
           den_estr_linprod
      FROM linha_prod
     WHERE cod_lin_recei = 0
       AND cod_seg_merc = 0
       AND cod_cla_uso = 0
     ORDER BY den_estr_linprod

   FOREACH cq_itens
      INTO pr_itens[p_ind].*   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_itens')
         EXIT FOREACH
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 200 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_itens TO sr_itens.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol1230a
   
   IF NOT INT_FLAG THEN
      RETURN pr_itens[p_ind].cod_lin_prod
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#------------------------#
FUNCTION pol1230_le_ocs()#
#------------------------#

   DEFINE p_query CHAR(1000)
   
   LET p_query = 
      "SELECT o.num_oc, o.num_versao, o.cod_item, o.dat_entrega_prev, l.den_estr_linprod ",
      "  FROM ordem_sup o, item i, linha_prod l ",
      " WHERE o.cod_empresa = '",p_cod_empresa,"' ",
      "   AND o.ies_situa_oc = 'X' ",
      "   AND o.ies_versao_atual = 'S' ",
      "   AND i.cod_empresa = o.cod_empresa ",
      "   AND i.cod_item = o.cod_item ",
      "   AND l.cod_lin_prod = i.cod_lin_prod ",
      "   AND l.cod_lin_recei = i.cod_lin_recei ",
      "   AND l.cod_seg_merc = i.cod_seg_merc ",
      "   AND l.cod_cla_uso = i.cod_cla_uso "

   IF p_tela.cod_item IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND o.cod_item <= '",p_tela.cod_item,"' "
   END IF

   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND o.dat_entraga_prev >= '",p_tela.dat_ini,"' "
   END IF
   
   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND o.dat_entraga_prev <= '",p_tela.dat_fim,"' "
   END IF

   IF p_tela.cod_lin_prod IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND i.cod_lin_prod = ", p_tela.cod_lin_prod
   END IF
   
   LET p_query = p_query CLIPPED, " ORDER BY l.den_estr_linprod, o.cod_item, o.dat_entrega_prev"
   
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
   FOREACH cq_ocs INTO 
           pr_item[p_ind].ordem,  
           pr_compl[p_ind].num_versao,  
           pr_item[p_ind].item,      
           pr_item[p_ind].entrega,
           pr_item[p_ind].linha     

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_ocs')
         RETURN FALSE
      END IF
      
      LET pr_item[p_ind].operacao = 'N'

      DECLARE cq_seq_periodo CURSOR FOR
      SELECT seq_periodo
        FROM item_criticado_bi_454
       WHERE cod_empresa = p_cod_empresa
         AND num_oc = pr_item[p_ind].ordem
       ORDER BY seq_periodo

      FOREACH cq_seq_periodo  INTO pr_item[p_ind].seq_periodo
  
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_seq_periodo')
            RETURN FALSE
         END IF
      
         EXIT FOREACH
      
      END FOREACH
       
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

   LET p_num_oc = pr_item[1].ordem
   LET p_cod_item = pr_item[1].item

   CALL pol1230_exibe_mensagem() 
   
   INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
   RETURN TRUE

END FUNCTION  

#----------------------------#
FUNCTION pol1230_selecionar()#
#----------------------------#

   SELECT tip_acesso 
     INTO p_tip_acesso
     FROM usuario_oc_bloq_454
    WHERE nom_usuario = p_user
   
   IF STATUS = 100 THEN
      LET p_msg = 'Usuário ', p_user CLIPPED, ' não\n',
                  'cadastrado no POL1229.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','usuario_oc_bloq_454')
         RETURN FALSE
      END IF
   END IF         
   
   INPUT ARRAY pr_item
      WITHOUT DEFAULTS FROM sr_item.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  

         LET p_num_oc = pr_item[p_ind].ordem
         LET p_num_versao = pr_compl[p_ind].num_versao
         LET p_cod_item = pr_item[p_ind].item
         
         IF pr_item[p_ind].ordem IS NOT NULL THEN
            CALL pol1230_exibe_mensagem()         
         END IF
      
      AFTER FIELD operacao

         IF pr_item[p_ind].operacao MATCHES '[LEN]' THEN
            IF pr_item[p_ind].operacao = 'L' AND p_tip_acesso = 'E' THEN
               ERROR 'Usuário não autorizado a Liberar OC. Consulte o POL1229.'
               NEXT FIELD operacao
            END IF
            IF pr_item[p_ind].operacao = 'E' AND p_tip_acesso = 'L' THEN
               ERROR 'Usuário não autorizado a Liberar OC. Consulte o POL1229.'
               NEXT FIELD operacao
            END IF
         ELSE
            LET p_msg = 'Informe:\n',
                        'L=Liberar\n',
                        'E=Excluir\n',
                        'N=Nenhuma ação'
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD operacao
         END IF

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_ind >= p_qtd_linha THEN
               NEXT FIELD operacao
            END IF
         END IF                     

      ON KEY (control-o)
         CALL pol1230_detalhe_oc()

      AFTER INPUT
       
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         LET p_count = 0
         
         FOR p_index = 1 TO p_qtd_linha
            IF pr_item[p_index].operacao MATCHES '[LE]' THEN
               LET p_count = p_count + 1
               EXIT FOR
            END IF
         END FOR
         
         IF p_count = 0 THEN
            LET p_msg = 'Nenhuma OC foi selecionada\n para processar'
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD operacao
         END IF
               
   END INPUT

   LET p_msg = 'Confirma o procesamento\n da(s) OC(s) selecionadas(s)'

   IF NOT log0040_confirm(20,25,p_msg) THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1230_processar() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
FUNCTION pol1230_exibe_mensagem()#
#--------------------------------#
   DEFINE  p_mensagem   CHAR(240)

   DECLARE cq_msg CURSOR FOR
   SELECT mensagem
     FROM oc_bloqueada_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc

   FOREACH cq_msg  INTO p_mensagem

      IF STATUS <> 0 THEN
         LET p_mensagem = ''
      END IF   
      
      EXIT FOREACH
      
   END FOREACH
   
   DISPLAY p_mensagem TO mensagem
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item

   IF STATUS <> 0 THEN
      LET p_den_item = ''
   END IF   
   
   DISPLAY p_den_item TO den_item

END FUNCTION

#---------------------------#
FUNCTION pol1230_processar()#
#---------------------------#
   
   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   
   FOR p_ind = 1 to p_qtd_linha
       LET p_num_oc = pr_item[p_ind].ordem
       LET p_num_versao = pr_compl[p_ind].num_versao
       LET p_operacao = pr_item[p_ind].operacao
   
       IF p_operacao = 'L' THEN
          IF NOT pol1230_libera_oc() THEN
             RETURN FALSE
          END IF
       END IF

       IF p_operacao = 'E' THEN
          IF NOT pol1230_deleta_oc() THEN
             RETURN FALSE
          END IF
       END IF

   END FOR
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#   
FUNCTION pol1230_libera_oc()#
#---------------------------#

   UPDATE ordem_sup
      SET ies_situa_oc = 'A'
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND ies_versao_atual = 'S'
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'ordem_sup')
      RETURN FALSE
   END IF

   IF NOT pol1230_ins_audit() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1230_ins_audit()#
#---------------------------#

   INSERT INTO audit_oc_bloq_454
    VALUES(p_cod_empresa,
           p_num_oc,
           p_num_versao,
           p_user,
           p_operacao,
           p_dat_atu,
           p_hor_atu)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'audit_oc_bloq_454')
      RETURN FALSE
   END IF

   DELETE FROM oc_bloqueada_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'oc_bloqueada_454')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   
 
#---------------------------#   
FUNCTION pol1230_deleta_oc()#
#---------------------------#

   DELETE FROM ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'ordem_sup')
      RETURN FALSE
   END IF

   DELETE FROM ordem_sup_compl
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'ordem_sup_compl')
      RETURN FALSE
   END IF

   DELETE FROM prog_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'prog_ordem_sup')
      RETURN FALSE
   END IF

   DELETE FROM estrut_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'estrut_ordem_sup')
      RETURN FALSE
   END IF

   DELETE FROM ordem_sup_txt
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'ordem_sup_txt')
      RETURN FALSE
   END IF

   DELETE FROM prog_ord_sup_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'PROG_ORD_SUP_454')
      RETURN FALSE
   END IF

   DELETE FROM item_criticado_bi_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'item_criticado_bi_454')
      RETURN FALSE
   END IF   

   IF NOT pol1230_ins_audit() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
      