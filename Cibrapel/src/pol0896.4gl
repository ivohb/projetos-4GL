
#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# OBJETIVO: LANÇAMENTO DE CONTAGEM                                  #
# FUNÇÕES: FUNC002                                                  #
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
          p_where              CHAR(300)  

END GLOBALS

   DEFINE p_ins_umd            SMALLINT,
          p_num_ar             INTEGER,
          p_num_ara            INTEGER,
          p_cod_status         CHAR(01),
          p_ies_autorizado     CHAR(01),
          p_qtd_fardo          INTEGER,
          p_tip_movto          CHAR(01),
          p_num_registro       INTEGER,
          p_qtd_contagem       DECIMAL(15,3),
          p_qtd_declarad       DECIMAL(15,3),
          p_cod_item_tr        CHAR(15),
          p_pct_desc           DECIMAL(4,2),
          p_ies_troca_preco    CHAR(01),
          p_dat_emis_nf        DATETIME YEAR TO DAY,
          p_tip_frete          CHAR(01),
          p_reg_lagos          CHAR(01),
          p_val_pedagio        DECIMAL(10,2),
          p_peso_total         DECIMAL(10,3),
          p_qtd_lote           INTEGER
          

   DEFINE p_num_seq_ar         LIKE aviso_rec.num_seq,
          p_cod_item           LIKE aviso_rec.cod_item,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_ies_tip_frete      LIKE nf_sup.ies_tip_frete,
          p_cnd_pgto_nf        LIKE nf_sup.cnd_pgto_nf,
          p_preco_item         LIKE aviso_rec.pre_unit_nf,
          p_cod_cnd_pgto       LIKE nf_sup.cnd_pgto_nf,
          p_den_item           LIKE item.den_item_reduz,
          p_pre_unit_fob       LIKE cotacao_preco_885.pre_unit_fob,
          p_pre_unit_cif       LIKE cotacao_preco_885.pre_unit_cif                  
   
   DEFINE p_tela         RECORD
          num_aviso_rec  LIKE nf_sup.num_aviso_rec,
          cod_status     CHAR(01),
          ies_autorizado CHAR(01),
          num_nf         LIKE nf_sup.num_nf,
          dat_entrada    LIKE nf_sup.dat_emis_nf,
          cod_fornecedor LIKE fornecedor.cod_fornecedor,
          nom_fornecedor LIKE fornecedor.raz_social
   END RECORD

   DEFINE p_ar            RECORD
          tip_frete       CHAR(01), 
          reg_lagos       CHAR(01), 
          val_pedagio     DECIMAL(10,2)
   END RECORD
             
   DEFINE pr_item         ARRAY[200] OF RECORD
          num_seq         LIKE aviso_rec.num_seq,
          cod_item        LIKE aviso_rec.cod_item,
          den_item        LIKE aviso_rec.den_item,
          #qtd_nf          LIKE aviso_rec.qtd_declarad_nf,
          editar          CHAR(01)
   END RECORD
      
   DEFINE pr_lote         ARRAY[20] OF RECORD
          num_lote        LIKE cont_aparas_885.num_lote,
          qtd_fardo       LIKE cont_aparas_885.qtd_fardo,
          qtd_contagem    LIKE cont_aparas_885.qtd_contagem
   END RECORD

   DEFINE pr_troca        ARRAY[20] OF RECORD
          num_seq         DECIMAL(3,0),
          cod_item_ar     CHAR(15),
          preco_cotacao   DECIMAL(17,6),
          cod_item_tr     CHAR(15),
          preco_item_tr   DECIMAL(17,6),
          pct_desc        DECIMAL(4,2),
          ies_troca_preco CHAR(01)
   END RECORD


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT
   LET p_versao = "pol0896-10.02.01"
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0896.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol0896_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0896_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0896") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0896 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Dados da Tabela"
         CALL pol0896_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         CALL pol0896_paginacao("S")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         CALL pol0896_paginacao("A")
      COMMAND "Modificar" "Modifica dados na Tabela"
         IF p_ies_cons THEN
            CALL pol0896_modificar() RETURNING p_status
            IF p_status THEN
               LET p_msg = 'Modificação efetuada com sucesso!'
               CALL log0030_mensagem(p_msg,'info')
            ELSE
               ERROR 'Operação cancelada!'
            END IF
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND KEY("T")"auTorizar" "Autoriza a liberação do processo"
         IF p_ies_cons THEN
            IF pol0896_checa_status('A') THEN
               CALL pol0896_autorizar() RETURNING p_status
               IF p_status THEN
                  LET p_msg = 'Autorização efetuada com sucesso!'
                  CALL log0030_mensagem(p_msg,'info')
               ELSE
                  ERROR 'Operação cancelada!'
               END IF
            END IF
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND KEY("N")"caNcelar" "Cancela o lancamento da contagem"
         IF p_ies_cons THEN
            IF pol0896_checa_status('N') THEN
               CALL pol0896_Cancelar() RETURNING p_status
               IF p_status THEN
                  LET p_ies_cons = FALSE
                  LET p_msg="Cancelamento de contagem Efetuada c/ Sucesso."
                  CALL log0030_mensagem(p_msg,'info')
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF
            END IF      
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND KEY("L")"Liberar" "Libera o AR para inspecao."
         IF p_ies_cons THEN
            IF p_ies_autorizado = 'S' THEN
               IF pol0896_checa_status('L') THEN
                  CALL pol0896_Liberar() RETURNING p_status
                  IF p_status THEN
                     LET p_msg="Liberacao de AR Efetuada c/ Sucesso."
                     CALL log0030_mensagem(p_msg,'info')
                  ELSE
                     ERROR "Operação Cancelada !!!"
                  END IF
               END IF
            ELSE
               LET p_msg = 'Esse processo ainda não recebeu\n',
                           'autorização para ser liberado!\n'
               CALL log0030_mensagem(p_msg,'excla')
            END IF      
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
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
   CLOSE WINDOW w_pol0896

END FUNCTION

#--------------------------#
FUNCTION pol0896_modificar()
#--------------------------#

   IF NOT pol0896_exibe_itens() THEN
      RETURN FALSE
   END IF

   IF NOT pol0896_edita_itens() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION 

#---------------------------#
FUNCTION pol0896_le_nf_sup()
#---------------------------#

   SELECT num_nf,
          dat_entrada_nf,
          cod_fornecedor,
          ies_tip_frete,
          cnd_pgto_nf,
          dat_emis_nf
     INTO p_tela.num_nf,
          p_tela.dat_entrada,
          p_tela.cod_fornecedor,
          p_ies_tip_frete,
          p_cnd_pgto_nf,
          p_dat_emis_nf
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
FUNCTION pol0896_le_fornec()
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

#---------------------------------#
FUNCTION pol0896_checa_status(p_op)
#---------------------------------#

   DEFINE p_op CHAR(01)

   INITIALIZE p_msg TO NULL
   
   IF p_tela.cod_status = 'D' THEN
      LET p_msg = 'AR nao esta consolidado! - Acesso nao permitido!'
   ELSE 
      IF p_tela.cod_status = 'I' THEN
         LET p_msg = 'AR esta inspecionado! - Acesso nao permitido!'
      ELSE
         IF p_tela.cod_status = 'L' THEN
            IF p_op = 'L' THEN
               LET p_msg = 'AR ja esta liberado!'
            END IF
         ELSE
            IF p_tela.cod_status = 'P' THEN
               LET p_msg = 'AR esta processado! - Acesso nao permitido!'
            END IF
         END IF
      END IF
   END IF
   
   IF p_msg IS NOT NULL THEN
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
 
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0896_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL
   LET INT_FLAG = FALSE

END FUNCTION

#----------------------------#
FUNCTION pol0896_exibe_itens()
#----------------------------#

   INITIALIZE pr_item TO NULL
   LET p_index = 1

   DECLARE cq_itens CURSOR FOR 
    SELECT num_seq,
           cod_item,
           den_item,
           qtd_declarad_nf
      FROM aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec
   
   FOREACH cq_itens INTO 
           pr_item[p_index].num_seq,
           pr_item[p_index].cod_item,
           pr_item[p_index].den_item
           #pr_item[p_index].qtd_nf
 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','aviso_rec')
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1

      IF p_index > 200 THEN
         CALL log0030_mensagem('Limite de linhas ultrapassado','excla')
         EXIT FOREACH
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0896_edita_itens()
#-----------------------------#
   
   DEFINE p_qtd_linha INTEGER
   
   LET p_qtd_linha = p_index - 1
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
         IF NOT pol0896_exibe_lotes() THEN
            RETURN FALSE
         END IF
         
      AFTER FIELD editar
         IF pr_item[p_index].editar IS NOT NULL THEN
            LET pr_item[p_index].editar = NULL
            NEXT FIELD editar
         END IF

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 OR FGL_LASTKEY() = 13 THEN
         ELSE
            IF p_index >= p_qtd_linha THEN
               NEXT FIELD editar
            END IF
         END IF
         
        
         IF FGL_LASTKEY() = 13 THEN
            IF pr_item[p_index].num_seq IS NOT NULL THEN
               IF p_tela.cod_status = 'C' THEN
                  CALL pol0896_edita_lotes() RETURNING p_status
                  IF p_status THEN
                     NEXT FIELD editar
                  END IF
               ELSE
                  LET p_msg = 'O status atual do AR nao permite alteracao de peso'
                  CALL log0030_mensagem(p_msg,'excla')
                  NEXT FIELD editar
               END IF
            ELSE 
               NEXT FIELD editar
            END IF
         END IF         
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF   
   
   RETURN TRUE
   
END FUNCTION


#----------------------------#
FUNCTION pol0896_exibe_lotes()
#----------------------------#

   INITIALIZE pr_lote TO NULL
   
   LET p_ind = 1
   LET p_peso_total = 0

   DECLARE cq_lotes CURSOR FOR 
    SELECT num_lote,
           qtd_fardo,
           qtd_contagem
      FROM cont_aparas_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec
       AND num_seq_ar    = pr_item[p_index].num_seq
   
   FOREACH cq_lotes INTO 
           pr_lote[p_ind].num_lote,
           pr_lote[p_ind].qtd_fardo,
           pr_lote[p_ind].qtd_contagem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cont_aparas_885')
         RETURN FALSE
      END IF
      
      LET p_peso_total = p_peso_total + pr_lote[p_ind].qtd_contagem
      LET p_ind = p_ind + 1

      IF p_ind > 20 THEN
         CALL log0030_mensagem('Limite de lotes ultrapassado','excla')
         EXIT FOREACH
      END IF

   END FOREACH
   
   LET p_qtd_lote = p_ind - 1
   
   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_lote WITHOUT DEFAULTS FROM sr_lote.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
   DISPLAY p_peso_total TO peso_total
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0896_edita_lotes()
#-----------------------------#
   
   LET p_ind = p_qtd_lote
   
   CALL SET_COUNT(p_ind)
   
   INPUT ARRAY pr_lote WITHOUT DEFAULTS FROM sr_lote.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  

     AFTER ROW         
         CALL pol0896_soma_contagem()
         
      AFTER FIELD qtd_contagem
      
         IF pr_lote[p_ind].qtd_contagem IS NULL THEN
            ERROR 'Campo com preenchinmento obrigatorio!!!'
            NEXT FIELD qtd_contagem
         END IF

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_ind >= p_qtd_lote THEN
               CALL pol0896_soma_contagem()
               NEXT FIELD qtd_contagem
            END IF
         END IF

   END INPUT 

   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF   
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0896_grava_lotes() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0896_soma_contagem()#
#-------------------------------#
   
   LET p_peso_total = 0
   
   FOR p_count = 1 TO p_qtd_lote
       IF pr_lote[p_count].qtd_contagem IS NOT NULL THEN
          LET p_peso_total = p_peso_total + pr_lote[p_count].qtd_contagem
       END IF
   END FOR
   
   DISPLAY p_peso_total TO peso_total

END FUNCTION

#-----------------------------#
FUNCTION pol0896_grava_lotes()
#-----------------------------#
   
   DEFINE m_ind SMALLINT 
             
   FOR m_ind = 1 TO ARR_COUNT()

       IF pr_lote[m_ind].num_lote IS NOT NULL THEN
          UPDATE cont_aparas_885
             SET qtd_contagem = pr_lote[m_ind].qtd_contagem
           WHERE cod_empresa   = p_cod_empresa
             AND num_aviso_rec = p_tela.num_aviso_rec
             AND num_seq_ar    = pr_item[p_index].num_seq
             AND num_lote      = pr_lote[m_ind].num_lote
             
          IF STATUS <> 0 THEN 
             CALL log003_err_sql('Gravando','cont_aparas_885')
             RETURN FALSE
          END IF
       END IF
                 
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
 FUNCTION pol0896_consulta()
#--------------------------#

   LET p_num_ara = p_num_ar
   LET INT_FLAG  = FALSE

   CALL pol0896_limpa_tela()   
      
   CONSTRUCT BY NAME p_where ON 
      ar_aparas_885.num_aviso_rec,
      ar_aparas_885.cod_status

   IF INT_FLAG THEN
      IF p_num_ara > 0 THEN
         LET p_num_ar = p_num_ara
         CALL pol0896_exibe_dados()
      END IF
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET p_query = "SELECT num_aviso_rec FROM ar_aparas_885 ",
                  " WHERE ", p_where CLIPPED,  
                  "   AND cod_empresa = '",p_cod_empresa,"' ",              
                  "ORDER BY num_aviso_rec"

   PREPARE var_queri FROM p_query   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_queri
   OPEN cq_consulta
   FETCH cq_consulta INTO p_num_ar
      
   IF SQLCA.SQLCODE = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de Pesquisa nao Encontrados", 'excla')
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0896_le_ar_aparas_885() THEN
         LET p_ies_cons = TRUE
         CALL pol0896_exibe_dados()
      END IF
   END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol0896_le_ar_aparas_885()
#-----------------------------------#

   SELECT num_aviso_rec,
          cod_status,
          ies_autorizado,
          tip_frete,
          reg_lagos,
          val_pedagio
     INTO p_tela.num_aviso_rec,
          p_cod_status,
          p_ies_autorizado,
          p_tip_frete,
          p_reg_lagos,
          p_val_pedagio
     FROM ar_aparas_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ar_aparas_885')
      RETURN FALSE
   END IF

   LET p_tela.cod_status     = p_cod_status
   LET p_tela.ies_autorizado = p_ies_autorizado

   RETURN TRUE
   
END FUNCTION      
      
#------------------------------#
 FUNCTION pol0896_exibe_dados()
#------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL pol0896_le_nf_sup() RETURNING p_status
   CALL pol0896_le_fornec() RETURNING p_status

   DISPLAY BY NAME p_tela.*
   
 END FUNCTION

#-----------------------------------#
 FUNCTION pol0896_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   IF p_ies_cons THEN
      LET p_num_ara = p_num_ar
      WHILE TRUE
         CASE
            WHEN p_funcao = "S" FETCH NEXT cq_consulta     INTO p_num_ar
            WHEN p_funcao = "A" FETCH PREVIOUS cq_consulta INTO p_num_ar
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_num_ar = p_num_ara
            EXIT WHILE
         END IF
         
         IF pol0896_le_ar_aparas_885() THEN
            CALL pol0896_exibe_dados()
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol0896_Cancelar()
#--------------------------#

   IF log004_confirm(18,35) THEN
   ELSE
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   IF NOT pol0896_zera_contagem() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   ELSE
      IF NOT pol0896_atualiza_ar_aparas_885('C') THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   END IF
   
   CALL log085_transacao("COMMIT")

   CALL pol0896_limpa_tela()
   
   RETURN TRUE
      
END FUNCTION

#-------------------------------#
FUNCTION pol0896_zera_contagem()
#-------------------------------#

   UPDATE cont_aparas_885
      SET qtd_contagem = 0,
          qtd_liber = 0,
          qtd_liber_excep = 0,
          qtd_rejeit = 0,
          qtd_calculada = 0,
          pre_calculado = 0
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Gravando','cont_aparas_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0896_Liberar()
#-------------------------#

   SELECT COUNT(qtd_contagem)
     INTO p_count
     FROM cont_aparas_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      AND qtd_contagem  = 0
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cont_aparas_885')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_msg = 'Ha itens sem lancamento de contagem'
      CALL log0030_mensagem(p_msg, 'excla')
      RETURN FALSE
   END IF
   
   IF log004_confirm(18,35) THEN
   ELSE
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")

   IF NOT pol0896_atualiza_ar_aparas_885('L') THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
  
   IF NOT pol0896_atu_cont_aparas() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")

   LET p_tela.cod_status = 'L'
   DISPLAY p_tela.cod_status TO cod_status
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------------------#
FUNCTION pol0896_atualiza_ar_aparas_885(p_st)
#--------------------------------------------#

   DEFINE p_st CHAR(01)
   
   UPDATE ar_aparas_885
      SET cod_status = p_st
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','ar_aparas_885')
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION

#--------------------------------#
FUNCTION pol0896_atu_cont_aparas()
#--------------------------------#

   DEFINE p_pct_umid_pad  LIKE parametros_885.pct_umid_pad,
          p_ies_consid    LIKE umd_aparas_885.ies_consid,
          p_pct_umd_med   LIKE umd_aparas_885.pct_umd_med,
          p_qtd_calculada LIKE cont_aparas_885.qtd_calculada,
          p_qtd_da_seq    LIKE cont_aparas_885.qtd_calculada,
          p_val_calc      LIKE cont_aparas_885.pre_calculado,
          p_pre_cotacao   LIKE umd_aparas_885.preco_cotacao,
          p_preco_item_tr LIKE umd_aparas_885.preco_item_tr,
          p_fat_conversao DECIMAL(17,7),
          c_fat_conversao CHAR(10)
          
   SELECT pct_umid_pad
     INTO p_pct_umid_pad
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','parametros_885')
      RETURN FALSE
   END IF
   
   DECLARE cq_umd CURSOR FOR
    SELECT num_seq_ar,
           pct_umd_med,
           ies_consid,
           cod_item_tr,
           pct_desc,
           ies_troca_preco,
           preco_cotacao,
           preco_item_tr
      FROM umd_aparas_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec

   FOREACH cq_umd INTO 
           p_num_seq_ar,
           p_pct_umd_med,
           p_ies_consid,
           p_cod_item_tr,
           p_pct_desc,
           p_ies_troca_preco,
           p_pre_cotacao,
           p_preco_item_tr

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_umd')
         RETURN FALSE
      END IF
      
      #IF NOT pol0888_le_cotacao() THEN
      #   RETURN FALSE
      #END IF

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

      IF p_cod_item_tr IS NOT NULL AND p_ies_troca_preco = 'S' THEN
         LET p_cod_item   = p_cod_item_tr
         LET p_preco_item = p_preco_item_tr
      ELSE
         LET p_preco_item = p_pre_cotacao
      END IF

      IF p_preco_item IS NULL OR p_preco_item <= 0 THEN
         LET p_msg = 'Preço do item ', p_cod_item CLIPPED, ' não informado.\n',
                     'Utilizae a opção auTorizar, para informá-lo.'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
      
      IF p_pct_desc IS NOT NULL THEN
         LET p_preco_item = p_preco_item - (p_preco_item * p_pct_desc / 100)
      END IF
      
      LET p_qtd_da_seq = 0

      DECLARE cq_aparas CURSOR FOR
       SELECT num_lote,
              qtd_contagem
         FROM cont_aparas_885
        WHERE cod_empresa   = p_cod_empresa
          AND num_aviso_rec = p_tela.num_aviso_rec
          AND num_seq_ar    = p_num_seq_ar

      FOREACH cq_aparas INTO
              p_num_lote,
              p_qtd_contagem

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_aparas')
            RETURN FALSE
         END IF
         
         LET p_qtd_da_seq = p_qtd_da_seq + p_qtd_contagem
         
         IF p_ies_consid = 'N' THEN
            LET p_qtd_calculada = p_qtd_contagem -  (p_qtd_contagem * p_pct_umd_med / 100)
            LET p_qtd_calculada = p_qtd_calculada + (p_qtd_contagem * p_pct_umid_pad / 100)
         ELSE
            LET p_qtd_calculada = p_qtd_contagem
         END IF
                  
         LET p_val_calc = p_qtd_calculada * p_preco_item
         
         UPDATE cont_aparas_885
            SET qtd_calculada = p_qtd_calculada,
                pre_calculado = p_val_calc           #preço calculado
          WHERE cod_empresa   = p_cod_empresa
            AND num_aviso_rec = p_tela.num_aviso_rec
            AND num_seq_ar    = p_num_seq_ar
            AND num_lote      = p_num_lote

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizando','cont_aparas_885')
            RETURN FALSE
         END IF
         
      END FOREACH
      
      SELECT qtd_declarad_nf
        INTO p_qtd_declarad
        FROM aviso_rec
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_tela.num_aviso_rec
         AND num_seq       = p_num_seq_ar
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','aviso_rec')
         RETURN FALSE
      END IF
       
      LET p_fat_conversao = 1 +((p_qtd_declarad - p_qtd_da_seq)/p_qtd_da_seq)
      LET c_fat_conversao = p_fat_conversao

      UPDATE umd_aparas_885
         SET fat_conversao = c_fat_conversao,
             preco_cotacao = p_preco_item
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_tela.num_aviso_rec
         AND num_seq_ar    = p_num_seq_ar

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualisando','umd_aparas_885')
         RETURN FALSE
      END IF
          
   END FOREACH

   RETURN TRUE   
   
END FUNCTION

#----------------------------#
FUNCTION pol0888_le_cotacao()
#----------------------------#

   DEFINE p_dat_val_ini DATE,
          p_dat_val_fim DATE

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
   
   IF p_cod_item_tr IS NOT NULL AND p_ies_troca_preco = 'S' THEN
      LET p_cod_item = p_cod_item_tr
   END IF
   
   SELECT pre_unit_fob,                                 
          pre_unit_cif,                                    
          cnd_pgto,                                        
          dat_val_ini,                                     
          dat_val_fim                                      
     INTO p_pre_unit_fob,                                  
          p_pre_unit_cif,                                  
          p_cod_cnd_pgto,                                  
          p_dat_val_ini,                                   
          p_dat_val_fim                                    
     FROM cotacao_preco_885                                
    WHERE cod_empresa    = p_cod_empresa                 
      AND cod_fornecedor = p_tela.cod_fornecedor         
      AND cod_item       = p_cod_item    
      AND regiao_lagos   = p_reg_lagos          
      AND dat_val_ini    <= p_dat_emis_nf                
      AND dat_val_fim    >= p_dat_emis_nf                
    
    IF STATUS = 100 THEN
       LET p_msg = 'Preço cotação do item não cadastrado!'
       CALL log0030_mensagem(p_msg,'excla')
       RETURN FALSE
    ELSE
       IF STATUS <> 0 THEN
          CALL log003_err_sql('LENDO','cotacao_preco')
          RETURN FALSE
       END IF
    END IF

   IF p_tip_frete = 'F' THEN   
      LET p_preco_item = p_pre_unit_fob
   ELSE
      LET p_preco_item = p_pre_unit_cif
   END IF
      
   IF p_cod_cnd_pgto IS NULL OR p_cod_cnd_pgto = 0 THEN
      LET p_cod_cnd_pgto = p_cnd_pgto_nf
   END IF
   
   LET p_cod_cnd_pgto = p_cnd_pgto_nf #forçar usar a mesma condição de pgto da NF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0896_autorizar()
#---------------------------#

   SELECT cod_usuario
     FROM user_liber_ar_885
    WHERE cod_usuario = p_user
   
   IF STATUS = 100 THEN
      LET p_msg = 'Você não está autorizado\n',
                  'a executar essa operação!\n'
      CALL log0030_mensagem(p_msg, 'excla')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','user_liber_ar_885')
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol0896_troca_item() THEN
      RETURN FALSE
   END IF         

   DISPLAY p_ies_autorizado TO ies_autorizado
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0896_troca_item()
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08961") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08961 AT 5,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol0896_aceita_cabec() THEN
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE
   
   IF pol0896_carrega_troca() THEN
      IF pol0896_edita_troca() THEN
         LET p_retorno = TRUE
      END IF
   END IF

   CLOSE WINDOW w_pol08961
   
   RETURN (p_retorno)

END FUNCTION         

#------------------------------#
FUNCTION pol0896_aceita_cabec()
#------------------------------#

   LET p_ar.tip_frete   = p_tip_frete 
   LET p_ar.reg_lagos   = p_reg_lagos
   LET p_ar.val_pedagio = p_val_pedagio
      
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_ar.* WITHOUT DEFAULTS  

      AFTER INPUT
      
         IF NOT INT_FLAG THEN
            IF p_ar.tip_frete MATCHES '[CF]' THEN
            ELSE
               ERROR 'Valor inválido p/ o campo!!!'
               NEXT FIELD tip_frete
            END IF
            
            IF p_ar.reg_lagos MATCHES '[SN]' THEN
            ELSE
               ERROR 'Valor inválido p/ o campo!!!'
               NEXT FIELD reg_lagos
            END IF
            
            IF p_ar.val_pedagio  IS NULL OR p_ar.val_pedagio < 0 THEN
               ERROR 'Valor inválido p/ o campo!!!'
               NEXT FIELD val_pedagio
            END IF
           
         END IF

   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol0896_carrega_troca()
#-------------------------------#

   LET p_index = 1
   INITIALIZE pr_troca TO NULL
   
   DECLARE cq_troca CURSOR FOR
    SELECT a.num_seq,
           a.cod_item,
           b.preco_cotacao,
           b.cod_item_tr,
           b.preco_item_tr,
           b.pct_desc,
           b.ies_troca_preco
      FROM aviso_rec a
           INNER JOIN umd_aparas_885 b
              ON a.cod_empresa   = b.cod_empresa
             AND a.num_aviso_rec = b.num_aviso_rec
             AND a.num_seq       = b.num_seq_ar
     WHERE a.cod_empresa   = p_cod_empresa
       AND a.num_aviso_rec = p_tela.num_aviso_rec

   FOREACH cq_troca INTO 
           p_num_seq_ar, 
           p_cod_item,
           pr_troca[p_index].preco_cotacao,
           pr_troca[p_index].cod_item_tr,
           pr_troca[p_index].preco_item_tr,
           pr_troca[p_index].pct_desc,
           pr_troca[p_index].ies_troca_preco           
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','join:cq_troca')
         RETURN FALSE
      END IF
      
      #LET p_den_item = pol0896_le_item()
      
      LET pr_troca[p_index].num_seq     = p_num_seq_ar
      LET pr_troca[p_index].cod_item_ar = p_cod_item
            
      LET p_index = p_index + 1
      
      IF p_index > 20 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou!','excla')
         EXIT FOREACH
      END IF
      
   END FOREACH
      
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0896_le_item()
#-------------------------#

   DEFINE p_den_item_reduz LIKE item.den_item_reduz
   
   SELECT den_item_reduz
     INTO p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      LET p_den_item_reduz = NULL
   END IF
   
   RETURN (p_den_item_reduz)
   
END FUNCTION

#-----------------------------#
FUNCTION pol0896_edita_troca()
#-----------------------------#

   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_troca WITHOUT DEFAULTS FROM sr_troca.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD preco_cotacao
         
         IF pr_troca[p_index].num_seq IS NOT NULL THEN
            IF pr_troca[p_index].preco_cotacao IS NULL OR
               pr_troca[p_index].preco_cotacao <= 0 THEN
               ERROR 'Valor inválido para o campo!!!'
               NEXT FIELD preco_cotacao
            END IF
         END IF
         
      AFTER FIELD cod_item_tr
         
         IF pr_troca[p_index].cod_item_tr IS NOT NULL THEN
            LET p_cod_item = pr_troca[p_index].cod_item_tr
            LET p_den_item = pol0896_le_item()
            #DISPLAY pr_troca[p_index].den_item_tr TO sr_troca[s_index].den_item_tr
            IF p_den_item IS NULL THEN
               ERROR 'Item inválido!!!'
               NEXT FIELD cod_item_tr
            END IF
         ELSE
            #LET pr_troca[p_index].den_item_tr = NULL
            #DISPLAY "" TO sr_troca[s_index].den_item_tr 
            LET pr_troca[p_index].ies_troca_preco = 'N'  
            DISPLAY "" TO sr_troca[s_index].ies_troca_preco
            LET pr_troca[p_index].preco_item_tr = NULL
            DISPLAY "" TO sr_troca[s_index].preco_item_tr
            NEXT FIELD pct_desc
         END IF
      
      BEFORE FIELD preco_item_tr
         
         IF pr_troca[p_index].cod_item_tr IS NULL THEN
            NEXT FIELD pct_desc
         END IF
         
      AFTER FIELD preco_item_tr
         
         IF pr_troca[p_index].num_seq IS NOT NULL THEN
            IF pr_troca[p_index].preco_item_tr IS NULL OR
               pr_troca[p_index].preco_item_tr <= 0 THEN
               ERROR 'Valor inválido para o campo!!!'
               NEXT FIELD preco_item_tr
            END IF
         END IF

      AFTER FIELD pct_desc
         
         IF pr_troca[p_index].pct_desc IS NOT NULL THEN
            IF pr_troca[p_index].pct_desc < 0 THEN
               ERROR 'Desconto inválido!'
               NEXT FIELD pct_desc
            END IF
         END IF
      
      BEFORE FIELD ies_troca_preco
      
         IF pr_troca[p_index].cod_item_tr IS NULL THEN
            NEXT FIELD preco_cotacao
         END IF
      
      AFTER FIELD ies_troca_preco
         
         IF pr_troca[p_index].ies_troca_preco = 'S' THEN
            IF pr_troca[p_index].cod_item_tr IS NULL THEN
               LET pr_troca[p_index].ies_troca_preco = 'N'  
               DISPLAY "" TO sr_troca[s_index].ies_troca_preco
            END IF
         END IF
        
      AFTER ROW
         
         IF NOT INT_FLAG THEN
            IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
            ELSE
               IF pr_troca[p_index].cod_item_ar IS NULL THEN
                  ERROR 'Não há mais linhas nessa direção'
                  NEXT FIELD cod_item_tr
               END IF
            END IF
         END IF

      ON KEY (control-z)
         CALL pol00896_popup()
            
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF   
   
   CALL log085_transacao("BEGIN")

   IF NOT pol0896_grava_troca() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   RETURN TRUE
   
END FUNCTION

#------------------------#
FUNCTION pol00896_popup()
#------------------------#

    DEFINE p_codigo CHAR(15)

   CASE
      {WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0721
         IF p_codigo IS NOT NULL THEN
            LET p_ft_item_885.cod_cliente = p_codigo CLIPPED
            DISPLAY p_codigo TO p_ft_item_885.cod_cliente
         END IF}

      WHEN INFIELD(cod_item_tr)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol08961
         IF p_codigo IS NOT NULL THEN
           LET pr_troca[p_index].cod_item_tr = p_codigo
           DISPLAY p_codigo TO sr_troca[s_index].cod_item_tr
         END IF

   END CASE

END FUNCTION 


#-----------------------------#
FUNCTION pol0896_grava_troca()
#-----------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_troca[p_ind].num_seq IS NOT NULL THEN
          IF NOT pol0896_atu_troca() THEN
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   IF NOT pol0896_atu_ar_aparas() THEN
      RETURN FALSE
   END IF
   
   LET p_ies_autorizado = 'S'
   LET p_tela.ies_autorizado = 'S'   

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0896_atu_troca()
#---------------------------#

   UPDATE umd_aparas_885
      SET preco_cotacao   = pr_troca[p_ind].preco_cotacao,
          cod_item_tr     = pr_troca[p_ind].cod_item_tr,
          preco_item_tr   = pr_troca[p_ind].preco_item_tr,
          pct_desc        = pr_troca[p_ind].pct_desc,
          ies_troca_preco = pr_troca[p_ind].ies_troca_preco
    WHERE cod_empresa     = p_cod_empresa
      AND num_aviso_rec   = p_tela.num_aviso_rec
      AND num_seq_ar      = pr_troca[p_ind].num_seq

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','umd_aparas_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0896_atu_ar_aparas()
#------------------------------#

   UPDATE ar_aparas_885
      SET ies_autorizado = 'S',
          tip_frete      = p_ar.tip_frete,
          reg_lagos      = p_ar.reg_lagos,
          val_pedagio    = p_ar.val_pedagio
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','ar_aparas_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
         
#----------------FIM DO PROGRAMA------------------#
