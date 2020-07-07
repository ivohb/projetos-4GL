#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# OBJETIVO: INSPEÇÃO DE APARAS                                      #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_empresa            LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_user           LIKE usuarios.cod_usuario,
          p_msg                CHAR(100),
          p_den_empresa        CHAR(25), 
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
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
          p_query              CHAR(300),
          p_where              CHAR(300),
          p_num_transac        INTEGER


   DEFINE p_num_seq_ar         LIKE aviso_rec.num_seq,
          p_cod_item           LIKE aviso_rec.cod_item,
          p_den_item           LIKE item.den_item,
          p_num_transac_trgd   LIKE estoque_trans.num_transac,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_qtd_liber          LIKE aviso_rec.qtd_liber,
          p_qtd_excep          LIKE aviso_rec.qtd_liber_excep,
          p_qtd_rejeit         LIKE aviso_rec.qtd_rejeit,
          p_qtd_contagem       LIKE cont_aparas_885.qtd_contagem,
          p_qtd_inspecionada   LIKE cont_aparas_885.qtd_contagem,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_qtd_movto          LIKE estoque_trans.qtd_movto,
          p_dat_movto          LIKE estoque_trans.dat_movto,
          p_pre_unit_nf        LIKE aviso_rec.pre_unit_nf,
          p_ies_tip_movto      LIKE estoque_trans.ies_tip_movto,
          p_val_movto          LIKE estoque_trans.cus_tot_movto_p,
          p_cod_local          LIKE estoque_lote.cod_local,
          p_num_conta          LIKE estoque_trans.num_conta  

   DEFINE p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*
          
   DEFINE p_num_ar             INTEGER,
          p_num_ara            INTEGER,
          p_cod_status         CHAR(01),
          p_ies_situa          CHAR(01)
          
   
   DEFINE p_tela         RECORD
          num_aviso_rec  LIKE nf_sup.num_aviso_rec,
          cod_status     CHAR(01),
          num_nf         LIKE nf_sup.num_nf,
          dat_entrada    LIKE nf_sup.dat_emis_nf,
          cod_fornecedor LIKE fornecedor.cod_fornecedor,
          nom_fornecedor LIKE fornecedor.raz_social
   END RECORD

   DEFINE pr_item         ARRAY[200] OF RECORD
          num_seq_ar      LIKE cont_aparas_885.num_seq_ar,
          cod_item        LIKE aviso_rec.cod_item,
          num_lote        LIKE cont_aparas_885.num_lote,
          qtd_contagem    LIKE cont_aparas_885.qtd_contagem,
          qtd_liber       LIKE cont_aparas_885.qtd_liber,
          qtd_liber_excep LIKE cont_aparas_885.qtd_liber_excep,
          qtd_rejeit      LIKE cont_aparas_885.qtd_rejeit
   END RECORD
   
   DEFINE pr_texto        ARRAY[50] OF RECORD
          tex_linha_obs   CHAR(60)
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT
   LET p_versao = "pol0910-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0910.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol0910_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0910_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0910") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0910 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   IF NOT pol0910_le_empresa() THEN
      RETURN
   END IF
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta avisos de recebimento"
         IF pol0910_consultar() THEN
            ERROR 'Operação efetuada com sucesso!'
            NEXT OPTION "Inspecionar" 
         ELSE
            ERROR 'Operação cancelada!'
         END IF
      COMMAND "Inspecionar" "Inspeciona os itens do AR"
         IF p_ies_cons THEN
            IF p_tela.cod_status = 'I' THEN
               CALL log0030_mensagem('A inspeção do AR já foi consolidada','excla')
            ELSE
               CALL pol0910_inspecionar() RETURNING p_status
               IF p_status THEN
                  LET p_msg="Operação efetuada com Sucesso !!!"
                  CALL log0030_mensagem(p_msg,'exclamation')
                  CALL pol0910_exibe_itens() RETURNING p_status
               ELSE
                  CALL pol0910_exibe_itens() RETURNING p_status 
                  ERROR "Operação Cancelada !!!"
               END IF      
            END IF
         ELSE
            ERROR "Execute a consulta previamente !!!"
            NEXT OPTION 'Consultar'
         END IF
      COMMAND "Seguinte" "Exibe o Proximo AR Encontrado na Consulta"
         CALL pol0910_paginacao("S")
      COMMAND "Anterior" "Exibe o AR Anterior Encontrado na Consulta"
         CALL pol0910_paginacao("A")
      COMMAND KEY("L") "consoLidar" "Consolida a inspeção e alimenta o estoque"
         IF p_ies_cons THEN
            IF p_tela.cod_status = 'I' THEN
               CALL log0030_mensagem('A inspeção do AR já foi consolidada','excla')
            ELSE
               CALL pol0910_Consolidar() RETURNING p_status
               IF p_status THEN
                  LET p_ies_cons = FALSE
                  LET p_msg="Operação efetuada com sucesso !!!"
                  CALL log0030_mensagem(p_msg,'exclamation')
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF      
            END IF
         ELSE
            ERROR "Execute a consulta previamente !!!"
            NEXT OPTION 'Consultar'
         END IF
{      COMMAND "Desconsolidar" "Cancela a consolidação e reverte o estoque"
         IF p_ies_cons THEN
            CALL pol0910_Desconsolidar() RETURNING p_status
            IF p_status THEN
               LET p_ies_cons = FALSE
               LET p_msg="Operação efetuada c/ sucesso."
               CALL log0030_mensagem(p_msg,'info')
            ELSE
               ERROR "Operação Cancelada !!!"
            END IF      
         ELSE
            ERROR "Execute a consulta previamente !!!"
            NEXT OPTION 'Consultar'
         END IF}
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0910_sobre()
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
   CLOSE WINDOW w_pol0910

END FUNCTION

#----------------------------#
FUNCTION pol0910_le_empresa()
#----------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
         LET p_cod_empresa = p_cod_emp_ofic
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#----------------------------#
 FUNCTION pol0910_consultar()
#----------------------------#

   LET p_num_ara = p_tela.num_aviso_rec

   CALL pol0910_limpa_tela()   
      
   CONSTRUCT BY NAME p_where ON 
      ar_aparas_885.num_aviso_rec

   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_tela.num_aviso_rec = p_num_ara
         CALL pol0910_exibe_dados() RETURNING p_ies_cons
      END IF
      RETURN FALSE
   END IF

   LET p_query = "SELECT num_aviso_rec, cod_status FROM ar_aparas_885 ",
                  " WHERE ", p_where CLIPPED,  
                  "   AND cod_empresa = '",p_cod_empresa,"' ", 
                  "   AND cod_status IN ('L','I') ",             
                  "ORDER BY num_aviso_rec"

   PREPARE var_queri FROM p_query   
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ar_aparas_885:prepare')
      RETURN FALSE
   END IF
   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_queri
   OPEN cq_consulta
   FETCH cq_consulta INTO 
         p_tela.num_aviso_rec,
         p_tela.cod_status
      
   IF SQLCA.SQLCODE = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de Pesquisa nao Encontrados", 'excla')
      LET p_ies_cons = FALSE
   ELSE 
      IF NOT pol0910_exibe_dados() THEN
         LET p_ies_cons = FALSE
      ELSE
         LET p_ies_cons = TRUE
      END IF
   END IF

   RETURN(p_ies_cons)

END FUNCTION

#------------------------------#
 FUNCTION pol0910_exibe_dados()
#------------------------------#

   IF NOT pol0910_le_nf_sup() THEN
      RETURN FALSE
   END IF  
    
   IF NOT pol0910_le_fornec() THEN
      RETURN FALSE
   END IF     

   DISPLAY BY NAME p_tela.*
   
   IF NOT pol0910_exibe_itens() THEN
      RETURN FALSE
   END IF 
   
   RETURN TRUE
   
 END FUNCTION

#---------------------------#
FUNCTION pol0910_le_nf_sup()
#---------------------------#

   SELECT num_nf,
          dat_entrada_nf,
          cod_fornecedor
     INTO p_tela.num_nf,
          p_tela.dat_entrada,
          p_tela.cod_fornecedor
     FROM nf_sup
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","nf_sup")       
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0910_le_fornec()
#---------------------------#
   
   SELECT raz_social
     INTO p_tela.nom_fornecedor
     FROM fornecedor
    WHERE cod_fornecedor = p_tela.cod_fornecedor
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","fornecedor")       
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
 
#-----------------------------------#
 FUNCTION pol0910_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   IF p_ies_cons THEN
      LET p_num_ara = p_tela.num_aviso_rec
      WHILE TRUE
         CASE
            WHEN p_funcao = "S" FETCH NEXT cq_consulta     
                 INTO p_tela.num_aviso_rec, p_tela.cod_status
            WHEN p_funcao = "A" FETCH PREVIOUS cq_consulta
                 INTO p_tela.num_aviso_rec, p_tela.cod_status
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_tela.num_aviso_rec = p_num_ara
            EXIT WHILE
         END IF
         
         IF pol0910_exibe_dados() THEN
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0910_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE

END FUNCTION


#----------------------------#
FUNCTION pol0910_exibe_itens()
#----------------------------#

   INITIALIZE pr_item TO NULL
   LET p_index = 1

   DECLARE cq_itens CURSOR FOR 
   
    SELECT num_seq_ar,
           num_lote,
           qtd_contagem,
           qtd_liber,
           qtd_liber_excep,
           qtd_rejeit
      FROM cont_aparas_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec
       
   FOREACH cq_itens INTO 
           pr_item[p_index].num_seq_ar,
           pr_item[p_index].num_lote,
           pr_item[p_index].qtd_contagem,
           pr_item[p_index].qtd_liber,
           pr_item[p_index].qtd_liber_excep,
           pr_item[p_index].qtd_rejeit

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cont_aparas_885')
         RETURN FALSE
      END IF
 
      SELECT cod_item
        INTO pr_item[p_index].cod_item
        FROM aviso_rec
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_tela.num_aviso_rec
         AND num_seq       = pr_item[p_index].num_seq_ar
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','aviso_rec:1')
         RETURN FALSE
      END IF

      LET p_index = p_index + 1

      IF p_index > 200 THEN
         CALL log0030_mensagem('Limite de linhas ultrapassado !!!','excla')
         EXIT FOREACH
      END IF

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
   BEFORE INPUT 
      EXIT INPUT 
      
   END INPUT 
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0910_inspecionar()
#----------------------------#
      
   LET INT_FLAG = FALSE 
   
   CALL SET_COUNT(p_index)
   
   INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW

         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE() 

         DISPLAY '' TO den_item 
         
         IF pr_item[p_index].num_seq_ar IS NOT NULL THEN
            SELECT den_item
              INTO p_den_item
              FROM item 
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = pr_item[p_index].cod_item
            
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo','item')
               RETURN FALSE 
            END IF  
         
            DISPLAY p_den_item TO den_item 
          END IF  

      AFTER FIELD qtd_liber
         IF pr_item[p_index].qtd_liber IS NULL THEN
            ERROR "Campo com prenchimento obrigatório !!!"
            NEXT FIELD qtd_liber
         END IF
         
         IF pr_item[p_index].qtd_liber < 0 THEN 
            ERROR "Valor ilegal para o campo em questão !!!"
            NEXT FIELD qtd_liber
         END IF

         IF pr_item[p_index+1].num_seq_ar IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
            ELSE
               NEXT FIELD qtd_liber_excep
            END IF
         END IF
         
          
      AFTER FIELD qtd_liber_excep
         IF pr_item[p_index].qtd_liber_excep IS NULL THEN
            ERROR "Campo com prenchimento obrigatório !!!"
            NEXT FIELD qtd_liber_excep
         END IF
         
         IF pr_item[p_index].qtd_liber_excep < 0 THEN 
            ERROR "Valor ilegal para o campo em questão !!!"
            NEXT FIELD qtd_liber_excep
         END IF  

         IF pr_item[p_index+1].num_seq_ar IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
            ELSE
               NEXT FIELD qtd_rejeit
            END IF
         END IF
         
         
      AFTER FIELD qtd_rejeit
         IF pr_item[p_index].qtd_rejeit IS NULL THEN
            ERROR "Campo com prenchimento obrigatório !!!"
            NEXT FIELD qtd_rejeit
         END IF
         
         IF pr_item[p_index].qtd_rejeit < 0 THEN 
            ERROR "Valor ilegal para o campo em questão !!!"
            NEXT FIELD qtd_rejeit
         END IF 

         IF pr_item[p_index+1].num_seq_ar IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
            ELSE
               NEXT FIELD qtd_liber
            END IF
         END IF
  
         
   END INPUT 
 
   IF INT_FLAG THEN
      RETURN FALSE
   END IF   
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0910_grava_lotes() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0910_grava_lotes()
#-----------------------------#
      
   FOR p_ind = 1 TO ARR_COUNT()
         
      UPDATE cont_aparas_885
         SET qtd_liber       = pr_item[p_ind].qtd_liber,
             qtd_liber_excep = pr_item[p_ind].qtd_liber_excep,
             qtd_rejeit      = pr_item[p_ind].qtd_rejeit
       WHERE cod_empresa     = p_cod_empresa
         AND num_aviso_rec   = p_tela.num_aviso_rec
         AND num_seq_ar      = pr_item[p_ind].num_seq_ar
         AND num_lote        = pr_item[p_ind].num_lote
             
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Atualizando','cont_aparas_885')
         RETURN FALSE
      END IF
   
   END FOR
   
   SELECT COUNT(qtd_rejeit)
     INTO p_count
     FROM cont_aparas_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      AND qtd_rejeit    > 0

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Lendo','cont_aparas_885')
      RETURN FALSE
   END IF
     
   IF p_count > 0 THEN
      IF NOT pol0910_info_texto() THEN
         CLOSE WINDOW w_pol09101
         RETURN FALSE
       END IF
       CLOSE WINDOW w_pol09101
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0910_info_texto()
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09101") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09101 AT 5,4 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_tela.num_aviso_rec TO num_aviso_rec

   DECLARE cq_seq CURSOR FOR
    SELECT num_seq_ar,
           SUM(qtd_rejeit)
      FROM cont_aparas_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec
     GROUP BY num_seq_ar
   
   FOREACH cq_seq INTO p_num_seq_ar, p_qtd_rejeit

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Lendo','cq_seq')
         RETURN FALSE
      END IF
 
      IF p_qtd_rejeit IS NULL OR p_qtd_rejeit = 0 THEN
         CONTINUE FOREACH
      END IF
      
      DISPLAY p_num_seq_ar TO num_seq
      
      SELECT cod_item 
        INTO p_cod_item
        FROM aviso_rec
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_tela.num_aviso_rec
         AND num_seq       = p_num_seq_ar

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Lendo','aviso_rec')
         RETURN FALSE
      END IF
        
      DISPLAY p_cod_item TO cod_item
      DISPLAY p_qtd_rejeit TO qtd_rejeit
      
      INITIALIZE pr_texto TO NULL
      LET p_index = 1
      
      DECLARE cq_txt CURSOR FOR
       SELECT tex_linha_obs
         FROM aviso_rec_rej
        WHERE cod_empresa   = p_cod_empresa
          AND num_aviso_rec = p_tela.num_aviso_rec
          AND num_seq       = p_num_seq_ar
   
      FOREACH cq_txt INTO pr_texto[p_index].tex_linha_obs
   
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('Lendo','cq_txt')
            RETURN FALSE
         END IF

         LET p_index = p_index + 1
      
         IF p_index > 50 THEN
            CALL log0030_mensagem("Limite de linhas ultrapassado","excla")
            EXIT FOREACH
         END IF
      
      END FOREACH

      CALL SET_COUNT(p_index - 1)
   
      INPUT ARRAY pr_texto WITHOUT DEFAULTS FROM sr_texto.*
   
         BEFORE ROW

            LET p_index = ARR_CURR()
            LET s_index = SCR_LINE() 

         AFTER FIELD tex_linha_obs
            IF pr_texto[p_index].tex_linha_obs IS NULL THEN
               IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
               ELSE
                  ERROR "Campo com preenchimento obrigatório!"
                  NEXT FIELD tex_linha_obs
               END IF
            END IF

   
      END INPUT
   
      IF INT_FLAG THEN
         RETURN FALSE
      END IF
      
      IF NOT pol0910_grava_texto() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0910_grava_texto()
#-----------------------------#

   DEFINE m_ind SMALLINT
   
   DELETE FROM aviso_rec_rej
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      AND num_seq       = p_num_seq_ar

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Deletando','aviso_rec_rej')
      RETURN FALSE
   END IF

   FOR m_ind = 1 TO ARR_COUNT()
      IF pr_texto[m_ind].tex_linha_obs IS NOT NULL THEN
         INSERT INTO aviso_rec_rej
          VALUES(p_cod_empresa, 
                 p_tela.num_aviso_rec, 
                 p_num_seq_ar,
                 m_ind,
                 pr_texto[m_ind].tex_linha_obs)

         IF STATUS <> 0 THEN 
            CALL log003_err_sql('Deletando','aviso_rec_rej')
            RETURN FALSE
         END IF
      END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol0910_Consolidar()
#----------------------------#

   DEFINE m_con SMALLINT
   
   IF NOT log004_confirm(6,10) THEN 
      RETURN FALSE 
   END IF 
   
   FOR m_con = 1 TO ARR_COUNT()
      
      SELECT qtd_contagem,
             (qtd_liber + qtd_liber_excep + qtd_rejeit)
        INTO p_qtd_contagem,
             p_qtd_inspecionada
        FROM cont_aparas_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_tela.num_aviso_rec
         AND num_seq_ar    = pr_item[m_con].num_seq_ar
         AND num_lote      = pr_item[m_con].num_lote 
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','cont_aparas_885')
         RETURN FALSE 
      END IF
            
      IF p_qtd_inspecionada <> p_qtd_contagem THEN 
         CALL log0030_mensagem(
          'A quantidade inspecionada é diferente da quantidade contada !!!','excla')
         RETURN FALSE 
      END IF 
   
   END FOR 

   CALL log085_transacao("BEGIN")
   
   IF NOT pol0910_calc_inspecao() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")   
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0910_Lancamentos() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   UPDATE ar_aparas_885
      SET cod_status = 'I'
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update', 'ar_aparas_885')
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   UPDATE cont_aparas_885
      SET dat_inspecao = p_dat_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update', 'cont_aparas_885')
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   LET p_tela.cod_status = 'I'
   DISPLAY p_tela.cod_status TO cod_status
   
   RETURN TRUE 
   
END FUNCTION  

#-------------------------------#
FUNCTION pol0910_calc_inspecao()
#-------------------------------#

   DEFINE p_fat_conversao LIKE umd_aparas_885.fat_conversao,
          p_qtd_insp_calc LIKE cont_aparas_885.qtd_contagem,
          p_qtd_nf        LIKE cont_aparas_885.qtd_contagem,
          p_qtd_dif       LIKE cont_aparas_885.qtd_contagem
   
   DECLARE cq_umd CURSOR FOR
    SELECT num_seq_ar,
           fat_conversao
      FROM umd_aparas_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
   
   FOREACH cq_umd INTO
           p_num_seq_ar,
           p_fat_conversao
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","CQ_UMD")       
         RETURN FALSE
      END IF
            
      UPDATE cont_aparas_885
         SET qtd_liber_calc  = qtd_liber * p_fat_conversao,
             qtd_excep_calc  = qtd_liber_excep * p_fat_conversao,
             qtd_rejeit_calc = qtd_rejeit * p_fat_conversao
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_tela.num_aviso_rec
         AND num_seq_ar    = p_num_seq_ar
         
      SELECT SUM(qtd_liber_calc + qtd_excep_calc + qtd_rejeit_calc)
        INTO p_qtd_insp_calc
        FROM cont_aparas_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_tela.num_aviso_rec
         AND num_seq_ar    = p_num_seq_ar
 
       SELECT qtd_declarad_nf
        INTO p_qtd_nf
        FROM aviso_rec
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_tela.num_aviso_rec
         AND num_seq       = p_num_seq_ar
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','aviso_rec:3')
         RETURN FALSE
      END IF
      
      IF p_qtd_insp_calc = p_qtd_nf THEN
         CONTINUE FOREACH
      END IF
      
      LET p_qtd_dif = p_qtd_insp_calc - p_qtd_nf
      
      DECLARE cq_dif CURSOR FOR
       SELECT num_lote,
              qtd_liber_calc,
              qtd_excep_calc,
              qtd_rejeit_calc
         FROM cont_aparas_885
        WHERE cod_empresa   = p_cod_empresa
          AND num_aviso_rec = p_tela.num_aviso_rec
          AND num_seq_ar    = p_num_seq_ar
     
      FOREACH cq_dif INTO
              p_num_lote, 
              p_qtd_liber,
              p_qtd_excep,
              p_qtd_rejeit

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_dif')
            RETURN FALSE
         END IF
         
         IF p_qtd_liber > p_qtd_dif THEN
            LET p_qtd_liber = p_qtd_liber - p_qtd_dif
         ELSE
            IF p_qtd_excep > p_qtd_dif THEN
               LET p_qtd_excep = p_qtd_excep - p_qtd_dif
            ELSE
               IF p_qtd_rejeit > p_qtd_dif THEN
                  LET p_qtd_rejeit = p_qtd_rejeit - p_qtd_dif
               ELSE
                  CALL log0030_mensagem(
                   'Erro de arredondamento nas quantidades inspecionadas!','excla')
                  RETURN FALSE
               END IF
            END IF
         END IF
         
         UPDATE cont_aparas_885
            SET qtd_liber_calc  = p_qtd_liber,
                qtd_excep_calc  = p_qtd_excep,
                qtd_rejeit_calc = p_qtd_rejeit
          WHERE cod_empresa   = p_cod_empresa
            AND num_aviso_rec = p_tela.num_aviso_rec
            AND num_seq_ar    = p_num_seq_ar
            AND num_lote      = p_num_lote
            
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizanado','cont_aparas_885')
            RETURN FALSE
         END IF
         
         EXIT FOREACH
         
      END FOREACH
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION


#-----------------------------#
 FUNCTION pol0910_Lancamentos()
#-----------------------------# 
   
   LET p_dat_movto = TODAY
   LET p_ies_tip_movto = 'N'

   DECLARE cq_ar CURSOR FOR
    SELECT num_seq_ar
      FROM umd_aparas_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec
     ORDER BY num_seq_ar

   FOREACH cq_ar INTO p_num_seq_ar

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","cq_ar")       
         RETURN FALSE
      END IF   

      IF NOT pol0910_ins_mov_ar() THEN
         RETURN FALSE
      END IF
   
      DECLARE cq_lanc CURSOR FOR
       SELECT num_lote,
              qtd_liber_calc,
              qtd_excep_calc,
              qtd_rejeit_calc
         FROM cont_aparas_885
        WHERE cod_empresa   = p_cod_empresa
          AND num_aviso_rec = p_tela.num_aviso_rec
          AND num_seq_ar    = p_num_seq_ar
   
      FOREACH cq_lanc INTO
              p_num_lote,
              p_qtd_liber,
              p_qtd_excep,
              p_qtd_rejeit
           
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","cq_lanc")       
            RETURN FALSE
         END IF   
   
         LET p_qtd_movto = p_qtd_liber + p_qtd_excep + p_qtd_rejeit

         IF NOT pol0910_ins_mov_trgd() THEN
            RETURN FALSE
         END IF
                            
         LET p_num_transac_trgd = p_num_transac
                     
         IF p_qtd_liber > 0 THEN 
            LET p_qtd_movto = p_qtd_liber
            LET p_ies_situa = 'L'
            IF NOT pol0910_insere_estoque() THEN 
               RETURN FALSE 
            END IF
         END IF  
      
         IF p_qtd_excep > 0 THEN 
            LET p_qtd_movto = p_qtd_excep
            LET p_ies_situa = 'E'
            IF NOT pol0910_insere_estoque() THEN 
               RETURN FALSE 
            END IF
         END IF  

         IF p_qtd_rejeit > 0 THEN 
            LET p_qtd_movto = p_qtd_rejeit
            LET p_ies_situa = 'R'
            IF NOT pol0910_insere_estoque() THEN 
               RETURN FALSE 
            END IF
         END IF  
  
         IF NOT pol0910_atu_estoque() THEN
            RETURN FALSE
         END IF

      END FOREACH

      IF NOT pol0910_atualiza_ar() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
            
   RETURN TRUE 
   
END FUNCTION 

#-----------------------------#
FUNCTION pol0910_atualiza_ar()
#-----------------------------#

   SELECT SUM(qtd_liber_calc),
          SUM(qtd_excep_calc),
          SUM(qtd_rejeit_calc)
     INTO p_qtd_liber,
          p_qtd_excep,
          p_qtd_rejeit
     FROM cont_aparas_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      AND num_seq_ar    = p_num_seq_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('sumando', 'qtd_inspecionada')
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   IF p_qtd_liber IS NULL THEN
      LET p_qtd_liber = 0
   END IF

   IF p_qtd_excep IS NULL THEN
      LET p_qtd_excep = 0
   END IF

   IF p_qtd_rejeit IS NULL THEN
      LET p_qtd_rejeit = 0
   END IF
    
   UPDATE aviso_rec
      SET ies_liberacao_insp = 'S',
          ies_liberacao_cont = 'S',
          ies_liberacao_ar   = '1',
          ies_situa_ar       = 'E',
          qtd_recebida       = qtd_declarad_nf,
          qtd_rejeit         = p_qtd_rejeit,
          qtd_liber          = p_qtd_liber,
          qtd_liber_excep    = p_qtd_excep
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      AND num_seq       = p_num_seq_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update', 'aviso_rec')
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol0910_insere_estoque()
#--------------------------------#
 
   SELECT *
     INTO p_estoque_lote_ender.*
     FROM estoque_lote_ender
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_cod_item
      AND cod_local     = p_cod_local
      AND ies_situa_qtd = p_ies_situa
      AND num_lote      = p_num_lote

   IF STATUS = 0 THEN
      IF NOT pol0910_atu_est_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         CALL pol0910_carrega_lote_ender()
         IF NOT pol0910_ins_est_lote_ender() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql("LENDO","estoque_lote_ender")       
         RETURN FALSE
      END IF
   END IF   

   SELECT num_transac
     INTO p_num_transac
     FROM estoque_lote
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_cod_item
      AND cod_local     = p_cod_local
      AND ies_situa_qtd = p_ies_situa
      AND num_lote      = p_num_lote

   IF STATUS = 0 THEN
      IF NOT pol0910_atu_est_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol0910_ins_est_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql("LENDO","estoque_lote_ender")       
         RETURN FALSE
      END IF
   END IF   

   LET p_val_movto = p_qtd_movto * p_pre_unit_nf
   
   IF NOT pol0910_ins_mov_insp() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0910_atu_est_lote_ender()
#-----------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_estoque_lote_ender.num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Atualiando","estoque_lote_ender")       
      RETURN FALSE
   END IF   
       
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0910_atu_est_lote()
#------------------------------#

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Atualiando","estoque_lote")       
      RETURN FALSE
   END IF   
       
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0910_atu_estoque()
#----------------------------#

   UPDATE estoque
      SET qtd_liberada    = qtd_liberada + p_qtd_liber,
          qtd_lib_excep   = qtd_lib_excep + p_qtd_excep,
          qtd_rejeitada   = qtd_rejeitada + p_qtd_rejeit,
          dat_ult_entrada = p_dat_movto
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Atualiando","estoque")       
      RETURN FALSE
   END IF   
       
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0910_carrega_lote_ender()
#-----------------------------------#

   LET p_estoque_lote_ender.cod_empresa        = p_cod_empresa
	 LET p_estoque_lote_ender.cod_item           = p_cod_item
	 LET p_estoque_lote_ender.cod_local          = p_cod_local
	 LET p_estoque_lote_ender.num_lote           = p_num_lote
	 LET p_estoque_lote_ender.ies_situa_qtd      = p_ies_situa
	 LET p_estoque_lote_ender.qtd_saldo          = p_qtd_movto
   LET p_estoque_lote_ender.largura            = 0
   LET p_estoque_lote_ender.altura             = 0
   LET p_estoque_lote_ender.num_serie          = ' '
   LET p_estoque_lote_ender.diametro           = 0
   LET p_estoque_lote_ender.comprimento        = 0
   LET p_estoque_lote_ender.dat_hor_producao   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.endereco           = ' '
   LET p_estoque_lote_ender.num_volume         = '0'
   LET p_estoque_lote_ender.cod_grade_1        = ' '
   LET p_estoque_lote_ender.cod_grade_2        = ' '
   LET p_estoque_lote_ender.cod_grade_3        = ' '
   LET p_estoque_lote_ender.cod_grade_4        = ' '
   LET p_estoque_lote_ender.cod_grade_5        = ' '
   LET p_estoque_lote_ender.num_ped_ven        = 0
   LET p_estoque_lote_ender.num_seq_ped_ven    = 0
   LET p_estoque_lote_ender.num_transac        = 0
   LET p_estoque_lote_ender.ies_origem_entrada = ' '
   LET p_estoque_lote_ender.dat_hor_validade   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.num_peca           = ' '
   LET p_estoque_lote_ender.dat_hor_reserv_1   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_2   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_3   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.qtd_reserv_1       = 0
   LET p_estoque_lote_ender.qtd_reserv_2       = 0
   LET p_estoque_lote_ender.qtd_reserv_3       = 0
   LET p_estoque_lote_ender.num_reserv_1       = 0
   LET p_estoque_lote_ender.num_reserv_2       = 0
   LET p_estoque_lote_ender.num_reserv_3       = 0
   LET p_estoque_lote_ender.tex_reservado      = ' '
   
END FUNCTION

#------------------------------------#
FUNCTION pol0910_ins_est_lote_ender()
#------------------------------------#

   INSERT INTO estoque_lote_ender(
          cod_empresa,
          cod_item,
          cod_local,
          num_lote,
          endereco,
          num_volume,
          cod_grade_1,
          cod_grade_2,
          cod_grade_3,
          cod_grade_4,
          cod_grade_5,
          dat_hor_producao,
          num_ped_ven,
          num_seq_ped_ven,
          ies_situa_qtd,
          qtd_saldo,
          ies_origem_entrada,
          dat_hor_validade,
          num_peca,
          num_serie,
          comprimento,
          largura,
          altura,
          diametro,
          dat_hor_reserv_1,
          dat_hor_reserv_2,
          dat_hor_reserv_3,
          qtd_reserv_1,
          qtd_reserv_2,
          qtd_reserv_3,
          num_reserv_1,
          num_reserv_2,
          num_reserv_3,
          tex_reservado) 
          VALUES(p_estoque_lote_ender.cod_empresa,
                 p_estoque_lote_ender.cod_item,
                 p_estoque_lote_ender.cod_local,
                 p_estoque_lote_ender.num_lote,
                 p_estoque_lote_ender.endereco,
                 p_estoque_lote_ender.num_volume,
                 p_estoque_lote_ender.cod_grade_1,
                 p_estoque_lote_ender.cod_grade_2,
                 p_estoque_lote_ender.cod_grade_3,
                 p_estoque_lote_ender.cod_grade_4,
                 p_estoque_lote_ender.cod_grade_5,
                 p_estoque_lote_ender.dat_hor_producao,
                 p_estoque_lote_ender.num_ped_ven,
                 p_estoque_lote_ender.num_seq_ped_ven,
                 p_estoque_lote_ender.ies_situa_qtd,
                 p_estoque_lote_ender.qtd_saldo,
                 p_estoque_lote_ender.ies_origem_entrada,
                 p_estoque_lote_ender.dat_hor_validade,
                 p_estoque_lote_ender.num_peca,
                 p_estoque_lote_ender.num_serie,
                 p_estoque_lote_ender.comprimento,
                 p_estoque_lote_ender.largura,
                 p_estoque_lote_ender.altura,
                 p_estoque_lote_ender.diametro,
                 p_estoque_lote_ender.dat_hor_reserv_1,
                 p_estoque_lote_ender.dat_hor_reserv_2,
                 p_estoque_lote_ender.dat_hor_reserv_3,
                 p_estoque_lote_ender.qtd_reserv_1,
                 p_estoque_lote_ender.qtd_reserv_2,
                 p_estoque_lote_ender.qtd_reserv_3,
                 p_estoque_lote_ender.num_reserv_1,
                 p_estoque_lote_ender.num_reserv_2,
                 p_estoque_lote_ender.num_reserv_3,
                 p_estoque_lote_ender.tex_reservado)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_lote_ender')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0910_ins_est_lote()
#------------------------------#

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo)  
          VALUES(p_cod_empresa,
                 p_cod_item,
                 p_cod_local,
                 p_num_lote,
                 p_ies_situa,
                 p_qtd_movto)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_lote')
     RETURN FALSE
   END IF
  
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0910_ins_mov_ar()
#----------------------------#

   INITIALIZE p_estoque_trans.* TO NULL

   SELECT cod_operac_estoq_c
     INTO p_cod_operacao
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","PAR_SUP")       
      RETURN FALSE
   END IF

   SELECT num_conta_deb_desp 
     INTO p_num_conta
     FROM dest_aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      AND num_seq       = p_num_seq_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','dest_aviso_rec')
      RETURN FALSE
   END IF     

   SELECT cod_item,
          pre_unit_nf,
          qtd_declarad_nf 
     INTO p_cod_item,
          p_pre_unit_nf,
          p_estoque_trans.qtd_movto
     FROM aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      AND num_seq       = p_num_seq_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','aviso_rec:4')
      RETURN FALSE
   END IF     

   SELECT cod_local_estoq
     INTO p_cod_local
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","item")       
      RETURN FALSE
   END IF   
   
   LET p_estoque_trans.cod_empresa        = p_cod_empresa
   LET p_estoque_trans.cod_item           = p_cod_item
   LET p_estoque_trans.dat_movto          = p_dat_movto
   LET p_estoque_trans.dat_ref_moeda_fort = p_tela.dat_entrada
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = "pol0910"
   LET p_estoque_trans.num_docum          = p_tela.num_aviso_rec
   LET p_estoque_trans.num_seq            = p_num_seq_ar
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.ies_sit_est_orig   = NULL
   LET p_estoque_trans.ies_sit_est_dest   = 'I'
   LET p_estoque_trans.cod_local_est_orig = NULL
   LET p_estoque_trans.cod_local_est_dest = p_cod_local
   LET p_estoque_trans.num_lote_orig      = NULL
   LET p_estoque_trans.num_lote_dest      = NULL
   LET p_estoque_trans.ies_tip_movto      = p_ies_tip_movto
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME

   INITIALIZE p_estoque_trans_end.*   TO NULL

   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.endereco         =  " "
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.cod_grade_1      = " "
   LET p_estoque_trans_end.cod_grade_2      = " "
   LET p_estoque_trans_end.cod_grade_3      = " "
   LET p_estoque_trans_end.cod_grade_4      = " "
   LET p_estoque_trans_end.cod_grade_5      = " "
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = " "
   LET p_estoque_trans_end.num_ped_ven      = 0
   LET p_estoque_trans_end.num_seq_ped_ven  = 0
   LET p_estoque_trans_end.dat_hor_producao = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_validade = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.num_peca         = " "
   LET p_estoque_trans_end.num_serie        = " "
   LET p_estoque_trans_end.comprimento      = 0
   LET p_estoque_trans_end.largura          = 0
   LET p_estoque_trans_end.altura           = 0
   LET p_estoque_trans_end.diametro         = 0
   LET p_estoque_trans_end.dat_hor_reserv_1 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_reserv_2 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_reserv_3 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.qtd_reserv_1     = 0
   LET p_estoque_trans_end.qtd_reserv_2     = 0
   LET p_estoque_trans_end.qtd_reserv_3     = 0
   LET p_estoque_trans_end.num_reserv_1     = 0
   LET p_estoque_trans_end.num_reserv_2     = 0
   LET p_estoque_trans_end.num_reserv_3     = 0
   LET p_estoque_trans_end.tex_reservado    = " "
   LET p_estoque_trans_end.cus_unit_movto_p = 0
   LET p_estoque_trans_end.cus_unit_movto_f = 0
   LET p_estoque_trans_end.cus_tot_movto_p  = 0
   LET p_estoque_trans_end.cus_tot_movto_f  = 0
   
   IF NOT pol0910_movta_estoque() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0910_ins_mov_trgd()
#-------------------------------#

   SELECT par_txt 
     INTO p_cod_operacao
     FROM par_sup_pad 
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'oper_transf_grade'
 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','oper_transf_grade')
      RETURN FALSE
   END IF
   
   LET p_num_conta = NULL
   
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.qtd_movto          = p_qtd_movto
   LET p_estoque_trans.cod_local_est_orig = p_cod_local
   LET p_estoque_trans.cod_local_est_dest = p_cod_local
   LET p_estoque_trans.num_lote_orig      = NULL
   LET p_estoque_trans.num_lote_dest      = p_num_lote
   LET p_estoque_trans.ies_sit_est_orig   = 'I'
   LET p_estoque_trans.ies_sit_est_dest   = 'I'
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0

   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p

   IF NOT pol0910_movta_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#-------------------------------#
FUNCTION pol0910_ins_mov_insp()
#-------------------------------#
 

   SELECT cod_operac_estoq_l
     INTO p_cod_operacao
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","PAR_SUP")       
      RETURN FALSE
   END IF
   
   LET p_num_conta = NULL

   LET p_estoque_trans.cus_unit_movto_p   = p_pre_unit_nf
   LET p_estoque_trans.cus_tot_movto_p    = p_val_movto
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.qtd_movto          = p_qtd_movto
   LET p_estoque_trans.cod_local_est_orig = p_cod_local
   LET p_estoque_trans.cod_local_est_dest = p_cod_local
   LET p_estoque_trans.num_lote_orig      = p_num_lote
   LET p_estoque_trans.num_lote_dest      = p_num_lote
   LET p_estoque_trans.ies_sit_est_orig   = 'I'
   LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME

   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p

   IF NOT pol0910_movta_estoque() THEN
      RETURN FALSE
   END IF
   
   INSERT INTO sup_mov_orig_dest
    VALUES(p_cod_empresa, p_num_transac_trgd, p_num_transac, 3)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','sup_mov_orig_dest')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0910_movta_estoque()
#-------------------------------#

   IF NOT pol0910_ins_est_trans() THEN
      RETURN FALSE
   END IF

   IF NOT pol0910_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol0910_ins_est_auditoria() THEN
      RETURN FALSE
   END IF
  
   IF NOT pol0910_ins_insp_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0910_ins_est_trans()
#-------------------------------#

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

   LET p_num_transac = SQLCA.SQLERRD[2]

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0910_ins_est_trans_end()
#------------------------------------#

   LET p_estoque_trans_end.num_transac = p_num_transac

   INSERT INTO estoque_trans_end 
      VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0910_ins_est_auditoria()
#-----------------------------------#

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, 
            p_num_transac, 
            p_user, 
            getdate(),
            'pol0910')

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria')
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0910_ins_insp_trans()
#--------------------------------#

   INSERT INTO insp_trans_885
    VALUES(p_cod_empresa,
           p_tela.num_aviso_rec,
           p_num_seq_ar,
           p_num_transac)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','insp_trans_885')
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol0910_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
           
#---FIM---#