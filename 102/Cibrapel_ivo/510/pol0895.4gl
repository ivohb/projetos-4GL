#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# OBJETIVO: LANÇAMENTO DE LOTES DE APARAS                           #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_empresa            LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_user           LIKE usuarios.cod_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
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

   DEFINE p_num_ar             INTEGER,
          p_num_ara            INTEGER,
          p_cod_status         CHAR(01),
          p_qtd_fardo          INTEGER,
          p_tip_movto          CHAR(01),
          p_num_registro       INTEGER,
          p_qtd_contagem       DECIMAL(15,3),
          p_ies_apara          CHAR(01),
          p_pct_umd_pad        DECIMAL(5,2),
          p_ins_ar             SMALLINT,
          p_qtd_itens          SMALLINT

   DEFINE p_num_seq_ar         LIKE aviso_rec.num_seq,
          p_cod_item           LIKE aviso_rec.cod_item,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_cod_familia        LIKE item.cod_familia
          
   
   DEFINE p_tela         RECORD
          num_aviso_rec  LIKE nf_sup.num_aviso_rec,
          cod_status     CHAR(01),
          num_nf         LIKE nf_sup.num_nf,
          dat_entrada    LIKE nf_sup.dat_emis_nf,
          cod_fornecedor LIKE fornecedor.cod_fornecedor,
          nom_fornecedor LIKE fornecedor.raz_social
   END RECORD

   DEFINE pr_item         ARRAY[200] OF RECORD
          num_seq         LIKE aviso_rec.num_seq,
          cod_item        LIKE aviso_rec.cod_item,
          den_item        LIKE aviso_rec.den_item,
          pct_umd_med     DECIMAL(5,2),
          ies_consid      CHAR(01),
          cod_motivo      CHAR(02),
          den_motivo      CHAR(30)
   END RECORD
      
   DEFINE pr_lote         ARRAY[20] OF RECORD
          num_lote        LIKE cont_aparas_885.num_lote,
          qtd_fardo       LIKE cont_aparas_885.qtd_fardo,
          qtd_contagem    LIKE cont_aparas_885.qtd_contagem
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT
   LET p_versao = "pol0895-05.10.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0895.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol0895_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0895_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0895") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0895 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0895_le_parametros() THEN
      RETURN FALSE
   END IF

   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         IF pol0895_incluir() THEN
            ERROR "Inclusão de Dados Efetuada c/ Sucesso !!!"
            LET p_ies_cons = TRUE
         ELSE
            CALL pol0895_limpa_tela()
            ERROR "Operação Cancelada !!!"
            LET p_ies_cons = FALSE   
         END IF      
      COMMAND "Modificar" "Modifica dados na Tabela"
         IF p_ies_cons THEN
            IF pol0895_le_status('A') THEN
               CALL pol0895_editar() RETURNING p_status
               IF p_status THEN
                  LET p_msg = "Modificação de Dados Efetuada c/ Sucesso !"
                  CALL log0030_mensagem(p_msg,'info')
                ELSE
                  ERROR "Operação Cancelada !!!"
               END IF
            END IF      
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Excluir" "Exclui Todos os dados da Tela"
         IF p_ies_cons THEN
            IF p_tela.num_aviso_rec IS NULL THEN
               ERROR "Não há dados na tela a serem excluídos !!!"
            ELSE
               IF pol0895_le_status('E') THEN
                  CALL pol0895_excluir() RETURNING p_status
                  IF p_status THEN
                    LET p_msg = "Exclusão de Dados Efetuada c/ Sucesso !"
                    CALL log0030_mensagem(p_msg,'info')
                  ELSE
                     ERROR "Operação Cancelada !!!"
                  END IF
               END IF      
            END IF
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         CALL pol0895_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         CALL pol0895_paginacao("S")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         CALL pol0895_paginacao("A")
      COMMAND KEY("O")"cOnsolidar" "Conclui o lancamento e exporta p/ o Trim"
         IF p_ies_cons THEN
            IF pol0895_le_status('C') THEN
               CALL pol0895_exporta("C") RETURNING p_status
               IF p_status THEN
                  CALL log0030_mensagem("Consolidacao Efetuada c/ Sucesso.",'info')
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF
            END IF      
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Desconsolidar" "Reabre o processo p/ alteracoes"
         IF p_ies_cons THEN
            IF pol0895_le_status('D') THEN
               CALL pol0895_exporta("D") RETURNING p_status
               IF p_status THEN
                  CALL log0030_mensagem("Desconsolidacao Efetuada c/ Sucesso.",'info')
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF
            END IF      
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
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
  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)
   END MENU
   CLOSE WINDOW w_pol0895

END FUNCTION

#-----------------------#
 FUNCTION pol0895_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
FUNCTION pol0895_le_parametros()
#-------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
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
         LET p_cod_emp_ger = p_cod_empresa
         LET p_cod_empresa = p_cod_emp_ofic
      END IF
   END IF

   SELECT pct_umid_pad
     INTO p_pct_umd_pad
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","parametros_885")       
      RETURN
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol0895_incluir()
#------------------------#

   IF pol0895_informar() THEN
      IF pol0895_editar() THEN
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#------------------------#
FUNCTION pol0895_editar()
#------------------------#

   IF NOT pol0895_carrega_itens() THEN
      RETURN FALSE
   END IF

   IF NOT pol0895_edita_dados() THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   IF NOT pol0895_grava_dados() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION 

#--------------------------#
FUNCTION pol0895_informar()
#--------------------------#
   
   CALL pol0895_limpa_tela()
   INITIALIZE p_tela TO NULL

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS  

      AFTER FIELD num_aviso_rec

          IF p_tela.num_aviso_rec IS NULL THEN
             ERROR "Campo com Preenchimento Obrigatório !!!"
             NEXT FIELD num_aviso_rec
          END IF

          IF NOT pol0895_le_nf_sup() THEN
             NEXT FIELD num_aviso_rec
          END IF

          IF NOT pol0895_le_fornec() THEN
             NEXT FIELD num_aviso_rec
          END IF

          LET p_num_ar = p_tela.num_aviso_rec
          
          IF NOT pol0895_le_status('I') THEN
             NEXT FIELD num_aviso_rec
          END IF

          DISPLAY p_tela.cod_status     TO cod_status
          DISPLAY p_tela.num_nf         TO num_nf
          DISPLAY p_tela.dat_entrada    TO dat_entrada
          DISPLAY p_tela.cod_fornecedor TO cod_fornecedor
          DISPLAY p_tela.nom_fornecedor TO nom_fornecedor
          DISPLAY p_pct_umd_pad         TO pct_umd_pad

   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   DISPLAY 'D' TO cod_status

   RETURN TRUE

END FUNCTION 

#----------------------------#
FUNCTION pol0895_grava_dados()
#----------------------------#

   LET p_num_ar = p_tela.num_aviso_rec
   
   IF p_ins_ar THEN
      IF NOT pol0895_ins_ar() THEN
         RETURN FALSE
      END IF
   END IF
  
   IF NOT pol0895_del_umd() THEN
      RETURN FALSE
   END IF
   
   FOR p_index = 1 TO p_qtd_itens
       IF pr_item[p_index].num_seq IS NOT NULL THEN
          IF NOT pol0895_ins_umd() THEN
             RETURN FALSE
          END IF
       END IF
   END FOR

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol0895_ins_ar()
#------------------------#

   INSERT INTO ar_aparas_885
    VALUES(p_cod_empresa,
           p_num_ar, 'D','N','F','N',0)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Gravando","ar_aparas_885")       
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION 

#-------------------------#
FUNCTION pol0895_del_umd()
#-------------------------#

   DELETE FROM umd_aparas_885
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando","umd_aparas_885")       
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0895_ins_umd()
#-------------------------#

   INSERT INTO umd_aparas_885(
      cod_empresa,          
      num_aviso_rec,  
      num_seq_ar,     
      pct_umd_med,    
      ies_consid,     
      cod_motivo,     
      fat_conversao)  
    VALUES(p_cod_empresa,
           p_num_ar,
           pr_item[p_index].num_seq,
           pr_item[p_index].pct_umd_med,
           pr_item[p_index].ies_consid,
           pr_item[p_index].cod_motivo,0)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Inserindo","umd_aparas_885")       
      RETURN FALSE
   END IF           
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0895_le_nf_sup()
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
FUNCTION pol0895_le_fornec()
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

#-------------------------------#
FUNCTION pol0895_le_status(p_op)
#-------------------------------#

   DEFINE p_op CHAR(01)
   
   CALL pol0895_le_ar_aparas()
      
   IF STATUS = 0 THEN
      LET p_ins_ar = FALSE
   ELSE
      LET p_cod_status = 'D'
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","ar_aparas_885")    
         RETURN FALSE   
      ELSE
         IF NOT pol0895_le_ar() THEN
            RETURN FALSE
         END IF
         LET p_ins_ar = TRUE
      END IF
   END IF
   
   LET p_tela.cod_status = p_cod_status
   
   IF p_cod_status = 'I' THEN
      LET p_msg = 'AR esta inspecionado! - Acesso nao permitido'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   IF p_op MATCHES '[I]' THEN
      RETURN TRUE
   END IF

   IF p_op = 'D' THEN
      IF p_cod_status = 'D' THEN
         LET p_msg = 'AR nao esta Consolidado!'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
   ELSE
      IF p_cod_status MATCHES '[CL]' THEN
         LET p_msg = 'AR esta Consolidado! - Desconsolide-o previamente.'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0895_le_ar_aparas()
#------------------------------#

   SELECT cod_status
     INTO p_cod_status
     FROM ar_aparas_885
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar

END FUNCTION

#-----------------------#
FUNCTION pol0895_le_ar()
#-----------------------#

   SELECT COUNT(num_seq)
     INTO p_count
     FROM aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar
      AND (ies_liberacao_cont = 'S' OR ies_liberacao_insp = 'S')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','Aviso_rec')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      CALL log0030_mensagem(
      'AR com processo de contagem/inspeção iniciado por outro programa!','excla')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

      
#----------------------------#
FUNCTION pol0895_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL
   LET INT_FLAG = FALSE

END FUNCTION

#------------------------------#
FUNCTION pol0895_carrega_itens()
#------------------------------#

   INITIALIZE pr_item TO NULL
   LET p_index = 1

   DECLARE cq_itens CURSOR FOR 
    SELECT num_seq,
           cod_item
      FROM aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec
   
   FOREACH cq_itens INTO 
           pr_item[p_index].num_seq,
           pr_item[p_index].cod_item
 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','aviso_rec')
         RETURN FALSE
      END IF

      SELECT den_item_reduz,
             cod_familia
        INTO pr_item[p_index].den_item,
             p_cod_familia
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = pr_item[p_index].cod_item
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item')
         RETURN FALSE
      END IF
      
      SELECT ies_apara
        FROM familia_insumo_885
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_cod_familia
         AND ies_apara   = 'S'
   
      IF STATUS = 100 THEN
         LET p_msg = 'Item:',pr_item[p_index].cod_item
         LET p_msg = p_msg CLIPPED, ' nao e aparas'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","familia_insumo_885")
            RETURN FALSE
         END IF
      END IF
      
      SELECT pct_umd_med,
             ies_consid,
             cod_motivo
        INTO pr_item[p_index].pct_umd_med,
             pr_item[p_index].ies_consid,
             pr_item[p_index].cod_motivo
        FROM umd_aparas_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_tela.num_aviso_rec
         AND num_seq_ar    = pr_item[p_index].num_seq

      IF STATUS = 100 THEN
         LET pr_item[p_index].ies_consid = 'N'
      ELSE
         IF STATUS = 0 THEN
            IF pr_item[p_index].cod_motivo IS NOT NULL THEN
               LET pr_item[p_index].den_motivo = pol0895_le_motivo()
            END IF
         ELSE
            CALL log003_err_sql("LENDO","umd_aparas_885")
            RETURN FALSE
         END IF
      END IF
      
      LET p_index = p_index + 1

      IF p_index > 200 THEN
         CALL log0030_mensagem('Limite de linhas ultrapassado','excla')
         EXIT FOREACH
      END IF

   END FOREACH
   
   LET p_qtd_itens = p_index - 1
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0895_le_motivo()
#---------------------------#

   DEFINE p_den_motivo LIKE motivo_885.den_motivo
   
   SELECT den_motivo
     INTO p_den_motivo
     FROM motivo_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_motivo  = pr_item[p_index].cod_motivo

   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         LET p_den_motivo = ' Mot não cadastrado'
      ELSE
         CALL log003_err_sql('Lendo','motivo_885')
         LET p_den_motivo = ' '
      END IF
   END IF
   
   RETURN(p_den_motivo)
   
END FUNCTION

#-----------------------------#
FUNCTION pol0895_edita_dados()
#-----------------------------#

   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
         IF NOT pol0895_exibe_lotes() THEN
            RETURN FALSE
         END IF

         IF pr_item[p_index].num_seq IS NULL THEN
            NEXT FIELD pct_umd_med
         END IF         
         
      AFTER FIELD pct_umd_med
         
         IF pr_item[p_index].num_seq IS NULL THEN
            LET pr_item[p_index].pct_umd_med = NULL
            DISPLAY '' TO sr_item[s_index].pct_umd_med
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN
            ELSE
               NEXT FIELD pct_umd_med
            END IF
         ELSE
            IF pr_item[p_index].pct_umd_med IS NULL OR
               pr_item[p_index].pct_umd_med < 0   THEN
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD pct_umd_med
            END IF
            IF pr_item[p_index].pct_umd_med <= p_pct_umd_pad THEN
               LET pr_item[p_index].ies_consid = 'S'
               DISPLAY 'S' TO sr_item[s_index].ies_consid
               NEXT FIELD den_motivo
            END IF
         END IF
         
         BEFORE FIELD ies_consid
            IF pr_item[p_index].pct_umd_med IS NULL OR 
               pr_item[p_index].pct_umd_med = ' ' THEN
               NEXT FIELD pct_umd_med
            END IF
            IF pr_item[p_index].pct_umd_med <= p_pct_umd_pad THEN
               NEXT FIELD den_motivo
            END IF
                     
         BEFORE FIELD cod_motivo
            IF pr_item[p_index].ies_consid = 'N' THEN
               INITIALIZE pr_item[p_index].cod_motivo TO NULL
               DISPLAY '' TO sr_item[s_index].cod_motivo
               DISPLAY '' TO sr_item[s_index].den_motivo
               NEXT FIELD den_motivo
            END IF
            
         AFTER FIELD cod_motivo
            IF pr_item[p_index].cod_motivo IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD cod_motivo
            END IF
         
            LET pr_item[p_index].den_motivo = pol0895_le_motivo()
            
            IF pr_item[p_index].den_motivo[1] = ' ' THEN
               ERROR 'Motivo inválido !!!'
               NEXT FIELD cod_motivo
            END IF
            
            DISPLAY pr_item[p_index].den_motivo TO sr_item[s_index].den_motivo
            
         ON KEY (control-t)
            IF pr_item[p_index].num_seq IS NOT NULL THEN
               IF p_cod_status = 'D' THEN
                  CALL pol0895_edita_lotes() RETURNING p_status
                  IF NOT p_status THEN
                     CALL pol0895_exibe_lotes() RETURNING p_status
                  END IF
               ELSE
                  LET p_msg = 'AR esta consolidado - Acesso nao permitido'
                  CALL log0030_mensagem(p_msg,'excla')
                  NEXT FIELD pct_umd_med
               END IF
            END IF     
         
         ON KEY (control-z)
            CALL pol0895_popup()  
         
   END INPUT 

   IF INT_FLAG THEN
      CALL pol0895_carrega_itens() RETURNING p_status
      IF p_status THEN
         INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
            BEFORE INPUT
               EXIT INPUT
         END INPUT
      END IF
      RETURN FALSE
   END IF   
   
   RETURN TRUE
   
END FUNCTION

#-----------------------#
FUNCTION pol0895_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_motivo)
         CALL log009_popup(8,10,"MOTIVOS","motivo_885",
                     "cod_motivo","den_motivo","pol0911","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01", p_versao)
      
         IF p_codigo IS NOT NULL THEN
            LET pr_item[p_index].cod_motivo = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_item[s_index].cod_motivo
         END IF
      
   END CASE

END FUNCTION

#----------------------------#
FUNCTION pol0895_exibe_lotes()
#----------------------------#

   INITIALIZE pr_lote TO NULL
   
   LET p_ind = 1

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
 
      LET p_ind = p_ind + 1

      IF p_ind > 20 THEN
         CALL log0030_mensagem('Limite de lotes ultrapassado','excla')
         EXIT FOREACH
      END IF

   END FOREACH

   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_lote WITHOUT DEFAULTS FROM sr_lote.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0895_edita_lotes()
#-----------------------------#
   
   CALL SET_COUNT(p_ind)
   
   INPUT ARRAY pr_lote
      WITHOUT DEFAULTS FROM sr_lote.*
      
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  
         
      AFTER FIELD num_lote
         
         IF pol0895_repetiu_lote() THEN
            ERROR 'Lote ja Informado!!!' 
            NEXT FIELD num_lote
         END IF
         
         IF pr_lote[p_ind].num_lote IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
            ELSE
               ERROR 'Campo com preenchinmento obrigatorio!!!'
               NEXT FIELD num_lote
            END IF
         END IF

      BEFORE FIELD qtd_fardo
         IF pr_lote[p_ind].num_lote IS NULL THEN
            NEXT FIELD num_lote
         END IF

      AFTER FIELD qtd_fardo
         IF pr_lote[p_ind].qtd_fardo IS NULL OR 
            pr_lote[p_ind].qtd_fardo = 0 THEN
            ERROR 'Campo com preenchinmento obrigatorio!!!'
            NEXT FIELD qtd_fardo
         END IF

   END INPUT 

   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF   
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0895_grava_lotes() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0895_repetiu_lote()
#------------------------------#

   DEFINE m_ind SMALLINT
   
   FOR m_ind = 1 TO ARR_COUNT()
       IF m_ind = p_ind THEN
          CONTINUE FOR
       END IF
       IF pr_lote[m_ind].num_lote = pr_lote[p_ind].num_lote THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0895_grava_lotes()
#-----------------------------#
   
   DEFINE m_ind SMALLINT 
             
   DELETE FROM cont_aparas_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      AND num_seq_ar    = pr_item[p_index].num_seq

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Deletando','cont_aparas_885')
      RETURN FALSE
   END IF
   
   FOR m_ind = 1 TO ARR_COUNT()

       IF pr_lote[m_ind].num_lote IS NOT NULL THEN
          INSERT INTO cont_aparas_885
          VALUES (p_cod_empresa, 
                  p_tela.num_aviso_rec,
                  pr_item[p_index].num_seq,
                  pr_lote[m_ind].num_lote,
                  pr_lote[m_ind].qtd_fardo, 
                  0,0,0,0,0,0,0,0,0,"")
                  
          IF STATUS <> 0 THEN 
             CALL log003_err_sql('Inserindo','cont_aparas_885')
             RETURN FALSE
          END IF
       END IF
                 
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
 FUNCTION pol0895_consulta()
#--------------------------#

   LET p_num_ara = p_num_ar

   CALL pol0895_limpa_tela()   
      
   CONSTRUCT BY NAME p_where ON 
      ar_aparas_885.num_aviso_rec,
      ar_aparas_885.cod_status

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_num_ar = p_num_ara
      CALL pol0895_exibe_dados()
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
      CALL log0030_mensagem("Argumentos de Pesquisa nao Encontrados",'excla')
      LET p_ies_cons = FALSE
   ELSE 
      CALL pol0895_le_ar_aparas()
      IF STATUS = 0 THEN
         LET p_ies_cons = TRUE
         CALL pol0895_exibe_dados()
      END IF
   END IF

END FUNCTION

      
#------------------------------#
 FUNCTION pol0895_exibe_dados()
#------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_tela.num_aviso_rec = p_num_ar
   LET p_tela.cod_status    = p_cod_status
   
   IF pol0895_le_nf_sup() THEN
      CALL pol0895_le_fornec() RETURNING p_status
   END IF
   
   DISPLAY BY NAME p_tela.*
   DISPLAY p_pct_umd_pad TO pct_umd_pad
   
 END FUNCTION

#-----------------------------------#
 FUNCTION pol0895_paginacao(p_funcao)
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
         
         CALL pol0895_le_ar_aparas()
         
         IF STATUS = 0 THEN
            CALL pol0895_exibe_dados()
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#------------------------#
FUNCTION pol0895_excluir()
#------------------------#

   IF log004_confirm(18,35) THEN
      CALL log085_transacao("BEGIN")
      IF NOT pol0895_deleta_ar() THEN      
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         CALL pol0895_limpa_tela()
         INITIALIZE p_num_ar, p_tela.num_aviso_rec TO NULL
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE      
      
END FUNCTION

#---------------------------#
FUNCTION pol0895_deleta_ar()
#---------------------------#

   DELETE FROM ar_aparas_885
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Excluindo','ar_aparas_885')
      RETURN FALSE
   END IF

   IF NOT pol0895_del_umd() THEN
      RETURN FALSE
   END IF

   
   DELETE FROM cont_aparas_885
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Excluindo','cont_aparas_885')
      RETURN FALSE
   END IF
      
   RETURN TRUE
      
END FUNCTION

#----------------------------#
FUNCTION pol0895_exporta(p_op)
#----------------------------#

   DEFINE p_op CHAR(01)

   IF log004_confirm(18,35) THEN
   ELSE
      RETURN FALSE
   END IF
         
   IF p_op = 'C' THEN
      LET p_tip_movto  = 'N'
   ELSE
      IF pol0895_lancou_contagem() THEN
         RETURN FALSE
      END IF
      LET p_tip_movto  = 'R'   
   END IF

   LET p_cod_status = p_op

   CALL log085_transacao("BEGIN")
   
   IF NOT pol0895_proces_export() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   ELSE
      CALL log085_transacao("COMMIT")
   END IF

   LET p_tela.cod_status = p_op
   
   DISPLAY p_tela.cod_status TO cod_status
   
   RETURN TRUE
      
END FUNCTION

#---------------------------------#
FUNCTION pol0895_lancou_contagem()
#---------------------------------#

   SELECT SUM(qtd_contagem)
     INTO p_qtd_contagem
     FROM cont_aparas_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cont_aparas_885')
      RETURN TRUE
   END IF
   
   IF p_qtd_contagem > 0 THEN
      LET p_msg='NF em processo de contagem. Desconsolidacao nao permitida'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN TRUE
   END IF

   RETURN FALSE
      
END FUNCTION

#-------------------------------#
FUNCTION pol0895_proces_export()
#-------------------------------#

   SELECT MAX(num_registro)
     INTO p_num_registro
     FROM etiq_aparas_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','etiq_aparas_885')    
      RETURN FALSE
   END IF
   
   IF p_num_registro IS NULL THEN
      LET p_num_registro = 0
   END IF

   IF NOT pol0895_atualiza_ar_aparas_885() THEN
      RETURN FALSE
   END IF

   DECLARE cq_exp CURSOR FOR 
   SELECT num_seq_ar,
          num_lote,
          qtd_fardo
     FROM cont_aparas_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec
   
   FOREACH cq_exp INTO
           p_num_seq_ar,
           p_num_lote,
           p_qtd_fardo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_exp')
         RETURN FALSE
      END IF
      
      IF NOT pol0895_inse_etiq() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE
      
END FUNCTION

#----------------------------------------#
FUNCTION pol0895_atualiza_ar_aparas_885()
#----------------------------------------#

   UPDATE ar_aparas_885
      SET cod_status = p_cod_status
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','ar_aparas_885')
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION

#---------------------------#
FUNCTION pol0895_inse_etiq()
#---------------------------#

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

   LET p_num_registro = p_num_registro + 1
   
   INSERT INTO etiq_aparas_885
    VALUES(p_cod_empresa,
           p_num_registro,
           p_tela.num_nf,
           p_tela.num_aviso_rec,
           p_num_seq_ar,
           p_tela.dat_entrada,
           p_tela.cod_fornecedor,
           p_tela.nom_fornecedor,
           p_cod_item,
           p_num_lote,
           p_qtd_fardo,
           p_tip_movto,
           0)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','etiq_aparas_885')
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION
