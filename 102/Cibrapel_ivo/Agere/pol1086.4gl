#-------------------------------------------------------------------#
# OBJETIVO: ESTORNO DE APONTAMENTO DE BOBINA                        #
# DATA....: 03/03/2011                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_dat_movto          DATE,
          p_dat_estorno        DATE,
          p_mensagem           CHAR(60),
          p_num_seq            INTEGER,
          p_num_reg            CHAR(6),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_comando            CHAR(200),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_arq_origem         CHAR(100),
          p_arq_destino        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(300),
          p_last_row           SMALLINT,
          p_num_bobina         CHAR(20),
          p_ies_apon           SMALLINT,
          p_num_transac        INTEGER
               
         
  
   DEFINE p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1086-05.10.03"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1086_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1086_menu()
#----------------------#
          
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1086") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1086 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol1086_carrega_boninas() THEN
      RETURN
   END IF
   
   LET p_ies_cons = TRUE
   
   MENU "OPCAO"
      COMMAND "Processar" "Processa o estorno das bobinas"
         IF p_ies_cons THEN
            CALL log085_transacao("BEGIN")
            CALL pol1086_processar() RETURNING p_status
            MESSAGE ''
            IF p_status THEN
               ERROR 'Processamento efetuado com sucesso !'
               CALL log085_transacao("COMMIT")
               LET p_ies_cons = FALSE
               NEXT OPTION 'Fim'
            ELSE
               CALL log085_transacao("ROLLBACK")
               ERROR 'Operação cancelada !!!'
            END IF 
         END IF
      COMMAND "Consultar" "Consulta as divergências encontradas no processamento"
         CALL pol1086_consultar()
      COMMAND "Carregar" "Carrega as bobinas selecionadas pelo Matheus"
         CALL pol1086_carregar()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1086

END FUNCTION

#--------------------------------#
FUNCTION pol1086_carrega_boninas()
#--------------------------------#
   
   DEFINE p_ies_carga CHAR(01)
   
   SELECT ies_carga
     INTO p_ies_carga
     FROM bob_carga_885

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','bob_carga_885')     
      RETURN FALSE
   END IF
   
   IF p_ies_carga = 'S' THEN
      RETURN TRUE
   END IF
  
   CALL log085_transacao("BEGIN")  
  
   SELECT nom_caminho
     INTO p_caminho
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = "UNL"
      
   LET p_nom_arquivo = 'bobinas.unl'
   LET p_arq_origem = p_caminho CLIPPED, p_nom_arquivo

   LOAD FROM p_arq_origem INSERT INTO bob_tmp_885

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("LOAD","bob_tmp_885")
      CALL log085_transacao("ROLLBACK")  
      RETURN FALSE
   END IF
   
   UPDATE bob_carga_885 SET ies_carga = 'S'

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("update","bob_carga_885")
      CALL log085_transacao("ROLLBACK")  
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1086_processar()
#---------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   DELETE FROM bob_erro_885
      
   LET p_dat_estorno = '01/01/2011'

   DECLARE cq_bob CURSOR FOR
    SELECT DISTINCT num_bobina
      FROM bob_tmp_885
   
   FOREACH cq_bob INTO p_num_bobina
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','bob_tmp_885:cq_bob')
         RETURN FALSE
      END IF
      
      MESSAGE 'Processando... ', p_num_bobina
      
      LET p_ies_apon = FALSE
      
      DECLARE cq_apon CURSOR FOR
       SELECT *
         FROM estoque_trans
        WHERE cod_empresa IN ('02','O2')
          AND (cod_operacao  = 'TDM+' OR
               cod_operacao  = 'APOM' OR
               cod_operacao  = 'IMPL' OR
               cod_operacao  = 'APON')
          AND ies_tip_movto = 'N'
          AND num_lote_dest = p_num_bobina
      
      FOREACH cq_apon INTO p_estoque_trans.*
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','bob_tmp_885:cq_bob')
            RETURN FALSE
         END IF

         LET p_ies_apon = TRUE
         
         LET p_dat_movto = p_estoque_trans.dat_movto 
         
         IF p_dat_movto < p_dat_estorno THEN
            CONTINUE FOREACH
         END IF
                  
         SELECT num_transac_rev
           FROM estoque_trans_rev
          WHERE cod_empresa = p_estoque_trans.cod_empresa
            AND num_transac_normal = p_estoque_trans.num_transac
         
         IF STATUS = 0 THEN
            CONTINUE  FOREACH
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('lendo','bob_tmp_885:cq_bob')
               RETURN FALSE
            END IF
         END IF

         IF NOT pol1086_estorna_trans() THEN
            RETURN FALSE
         END IF
         
         DELETE FROM bob_tmp_885 WHERE num_bobina = p_num_bobina
         
         #IF NOT pol1086_baixa_estoque() THEN
          #  RETURN FALSE
         #END IF
                  
      END FOREACH
      
      IF NOT p_ies_apon THEN
         LET p_msg = 'Bobina nao foi apontada pelo processo de integracao'
         IF NOT pol1086_critica() THEN
            RETURN FALSE
         END IF
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1086_baixa_estoque()
#-------------------------------#

   DEFINE p_qtd_liberada, p_qtd_lib_excep DECIMAL(10,2)
   
   SELECT num_transac
     INTO p_num_transac
     FROM estoque_lote
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_estoque_trans.cod_item
      AND num_lote    = p_estoque_trans.num_lote_dest
      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest

   IF STATUS = 100 THEN
      LET p_msg = 'Bobina nao encontrada na tab estoque_lote'
      IF NOT pol1086_critica() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote')
         RETURN FALSE
      END IF
   END IF
   
   DELETE FROM estoque_lote
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_lote')
      RETURN FALSE
   END IF
   
   SELECT num_transac
     INTO p_num_transac
     FROM estoque_lote_ender
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_estoque_trans.cod_item
      AND num_lote    = p_estoque_trans.num_lote_dest
      AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest

   IF STATUS = 100 THEN
      LET p_msg = 'Bobina nao encontrada na tab estoque_lote_ender'
      IF NOT pol1086_critica() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote')
         RETURN FALSE
      END IF
   END IF
   
   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_lote')
      RETURN FALSE
   END IF
   
   SELECT qtd_liberada,
          qtd_lib_excep
     INTO p_qtd_liberada,
          p_qtd_lib_excep
     FROM estoque
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_estoque_trans.cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque')
      RETURN FALSE
   END IF
   
   IF p_estoque_trans.ies_sit_est_dest = 'L' THEN
      IF p_estoque_trans.qtd_movto < p_qtd_liberada THEN
         LET p_qtd_liberada = p_qtd_liberada - p_estoque_trans.qtd_movto
      ELSE
         LET p_qtd_liberada = 0
      END IF
   ELSE
      IF p_estoque_trans.ies_sit_est_dest = 'E' THEN
         IF p_estoque_trans.qtd_movto < p_qtd_lib_excep THEN
            LET p_qtd_lib_excep = p_qtd_lib_excep - p_estoque_trans.qtd_movto
         ELSE
            LET p_qtd_lib_excep = 0
         END IF
      ELSE
         LET p_msg = 'Status da bobina: ', p_estoque_trans.ies_sit_est_dest, 
                     ' status esperados: L/E'
         IF NOT pol1086_critica() THEN
            RETURN FALSE
         END IF
         RETURN TRUE
      END IF
   END IF
   
   UPDATE estoque
      SET qtd_liberada  = p_qtd_liberada,
          qtd_lib_excep = p_qtd_lib_excep
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND cod_item    = p_estoque_trans.cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','estoque')
      RETURN FALSE
   END IF

   IF NOT pol1086_estorna_trans() THEN
      RETURN FALSE
   END IF
         
   DELETE FROM bob_tmp_885 WHERE num_bobina = p_num_bobina

   IF STATUS <> 0 THEN
      CALL log003_err_sql('deletando','bob_tmp_885:cq_bob')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1086_critica()
#-------------------------#

   INSERT INTO bob_erro_885
    VALUES(p_num_bobina, p_msg)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','bob_erro_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1086_estorna_trans()
#-------------------------------#

   SELECT *
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_estoque_trans.cod_empresa
      AND num_transac = p_estoque_trans.num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_trans_end')
      RETURN FALSE
   END IF

   LET p_estoque_trans.ies_tip_movto = 'R'
   
   INSERT INTO estoque_trans(
          cod_empresa,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   


   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans')
     RETURN FALSE
   END IF

   LET p_estoque_trans_end.num_transac = SQLCA.SQLERRD[2]

   INSERT INTO estoque_trans_rev
    VALUES(p_estoque_trans.cod_empresa,
           p_estoque_trans.num_transac,
           p_estoque_trans_end.num_transac)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end') 
     RETURN FALSE
   END IF
   
   LET p_estoque_trans_end.ies_tip_movto = 'R'
   
   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end') 
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1086_consultar()
#---------------------------#

   DEFINE pr_div     ARRAY[1000] OF RECORD
          num_bobina  CHAR(20),
          mensagem    CHAR(70)
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10861") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10861 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_ind = 1
    
   DECLARE cq_erro CURSOR FOR
    SELECT num_bobina,
           mensagem
      FROM bob_erro_885
   
   FOREACH cq_erro INTO 
           pr_div[p_ind].num_bobina,
           pr_div[p_ind].mensagem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','bob_erro_885')           
         RETURN FALSE
      END IF
      
      LET p_ind = p_ind + 1
      
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_div TO sr_div.*
   
   CLOSE WINDOW w_pol10861
   
END FUNCTION

#-------------------------#
FUNCTION pol1086_carregar()
#-------------------------#


   SELECT nom_caminho
     INTO p_caminho
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = "UNL"
      
   LET p_nom_arquivo = 'bobina.unl'
   LET p_arq_origem = p_caminho CLIPPED, p_nom_arquivo

   LOAD FROM p_arq_origem INSERT INTO bob_matheus_885
	
   IF STATUS <> 0 THEN 
      ERROR p_arq_origem
      CALL log003_err_sql("LOAD","bob_matheus_885")
      ERROR 'Operação cancelada!'
   ELSE
      ERROR 'Carga OK!'
   END IF

END FUNCTION
