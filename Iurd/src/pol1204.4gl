#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1204                                                 #
# OBJETIVO: BAIXA DE ETAPAS DE CONTRATO                             #
# DATA....: 11/06/2013                                              #
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
          p_caminho            CHAR(080),
          p_last_row           SMALLINT
                   
END GLOBALS

DEFINE p_cos_pagto RECORD LIKE cos_pagto_etapa.*

DEFINE p_salto              SMALLINT,
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
       p_msg                CHAR(500),
       p_opcao              CHAR(01),
       p_excluiu            SMALLINT,
       p_dat_proces         DATE,
       p_val_baixar         DECIMAL(12,2),
       sql_stmt             CHAR(500),
       where_clause         CHAR(500),
       p_num_oc             INTEGER,
       p_num_contr          INTEGER,
       p_num_etapa          INTEGER,
       p_num_versao         INTEGER,
       p_versao_oc          INTEGER,
       p_num_prog           INTEGER,
       p_dat_vencto         DATE,
       p_val_etapa          DECIMAL(12,2),
       p_val_oc_etapa       DECIMAL(12,2),
       p_cnpj               CHAR(20),
       m_estornar           SMALLINT,
       m_qtd_item           INTEGER

DEFINE pr_etapa            ARRAY[1000] OF RECORD
   contrato_servico        INTEGER,
   versao_contrato         INTEGER,
   num_etapa               INTEGER,
   dat_vencto_etapa        DATE,
   val_etapa               DECIMAL(12,2),
   val_oc_etapa            DECIMAL(12,2),
   ies_baixar              CHAR(01),
   num_oc                  DECIMAL(9,0)
END RECORD

DEFINE p_tela              RECORD
   num_aviso_rec           INTEGER,
   num_nf                  INTEGER,
   ies_especie_nf          CHAR(2),
   ser_nf                  CHAR(2),
   ssr_nf                  CHAR(3),
   dat_emis_nf             DATE,
   dat_entrada_nf          DATE,
   val_tot_nf_d            DECIMAL(12,2),
   cod_fornecedor          CHAR(15),
   raz_social              CHAR(40),
   num_contrato            INTEGER,
   saldo_da_nf             DECIMAL(12,2)
END RECORD

DEFINE parametro     RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   
   LET p_versao = "pol1204-10.02.30"
   
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   LET parametro.num_programa = 'POL1204'
   LET parametro.cod_empresa = p_cod_empresa
   LET parametro.usuario = p_user
            
   IF p_status = 0 THEN
      CALL pol1204_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1204_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1204") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1204 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar par�metros p/ o processamento."
         LET m_estornar = FALSE
         IF pol1204_informar() THEN
            LET p_ies_cons = TRUE
            ERROR 'Opera��o efetuada com sucesso !!!'
            NEXT OPTION "Processar" 
         ELSE
            LET p_ies_cons = FALSE
            ERROR 'Opera��o cancela !!!'
         END IF 
      COMMAND "Processar" "Processa a baixa da(s) etapa(s)."
         IF p_ies_cons THEN
            LET p_ies_cons = FALSE
            IF pol1204_processar() THEN
               ERROR 'Opera��o efetuada com sucesso !!!'
               NEXT OPTION "Fim" 
            ELSE
               ERROR 'Opera��o cancela !!!'
            END IF
         ELSE
            ERROR "Informe previamente os par�metros !!!"
            NEXT OPTION "Informar" 
         END IF 
      COMMAND "Estornar" "Estronar baixa do AR da tela."
         LET m_estornar = TRUE
         IF pol1204_estornar() THEN
            ERROR 'Opera��o efetuada com sucesso !!!'
            NEXT OPTION "Fim" 
         ELSE
            ERROR 'Opera��o cancela !!!'
         END IF
         LET m_estornar = FALSE
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
				CALL pol1204_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1204

END FUNCTION

#----------------------------#
FUNCTION pol1204_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-----------------------#
 FUNCTION pol1204_sobre()
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

#---------------------------#
 FUNCTION pol1204_informar()#
#---------------------------#
   
   LET INT_FLAG = FALSE
   INITIALIZE p_tela, pr_etapa TO NULL
   CALL pol1204_limpa_tela()
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
            
      AFTER FIELD num_aviso_rec

         IF p_tela.num_aviso_rec IS NULL THEN 
            ERROR "Campo com preenchimento obrigat�rio !!!"
            NEXT FIELD num_aviso_rec   
         END IF
         
         IF NOT pol1204_le_nf() THEN
            NEXT FIELD num_aviso_rec
         END IF

         IF m_estornar THEN
            DISPLAY BY NAME p_tela.*
            RETURN TRUE
         END IF
            
                            
      ON KEY (control-z)
         CALL pol1204_popup()
      
      AFTER INPUT
         
         IF p_tela.num_contrato IS NULL THEN
            IF m_qtd_item > 1 THEN
               LET p_msg = 'AR com mais de um item. \n Favor informar o contrato.'
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD num_contrato
            END IF
         END IF
         
         IF NOT INT_FLAG THEN
            IF p_tela.num_contrato IS NOT NULL THEN
               IF NOT pol1204_le_contrato() THEN
                  NEXT FIELD num_contrato
               END IF
            ELSE          
               IF NOT pol1204_busca_contrato() THEN
                  NEXT FIELD num_aviso_rec
               END IF
            END IF
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1204_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1204_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)


   
END FUNCTION 

#------------------------#
 FUNCTION pol1204_le_nf()#
#------------------------#
   
   DEFINE l_num_oc         INTEGER
   
   DEFINE p_val_pago       DECIMAL(12,2),
          p_cod_fornecedor CHAR(15)
   
   SELECT n.num_aviso_rec,
          n.num_nf, 
          n.ies_especie_nf,
          n.ser_nf,
          n.ssr_nf,  
          n.dat_emis_nf,   
          n.dat_entrada_nf,
          n.val_tot_nf_d,  
          n.cod_fornecedor,
          f.raz_social
     INTO p_tela.num_aviso_rec,   
          p_tela.num_nf,          
          p_tela.ies_especie_nf,  
          p_tela.ser_nf,          
          p_tela.ssr_nf,          
          p_tela.dat_emis_nf,     
          p_tela.dat_entrada_nf,  
          p_tela.val_tot_nf_d,    
          p_tela.cod_fornecedor,  
          p_tela.raz_social                
     FROM nf_sup n, fornecedor f
    WHERE n.cod_empresa = p_cod_empresa
      AND n.num_aviso_rec = p_tela.num_aviso_rec
      AND f.cod_fornecedor = n.cod_fornecedor

   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','nf_sup')
      RETURN FALSE
   END IF
   
   IF m_estornar THEN
      RETURN TRUE
   END IF
   
   SELECT num_cgc_cpf
     INTO p_cnpj
     FROM fornecedor
    WHERE cod_fornecedor = p_tela.cod_fornecedor

   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','fornecedor')
      RETURN FALSE
   END IF
   
   LET p_val_pago = 0
      
   SELECT SUM(val_pagar)
     INTO p_val_pago
     FROM cos_pagto_etapa p, cos_contr_servico c
    WHERE p.empresa = p_cod_empresa
      AND p.nota_fiscal = p_tela.num_nf
      AND p.serie_nota_fiscal = p_tela.ser_nf
      AND p.subserie_nf = p_tela.ssr_nf
      AND p.contrato_servico = c.contrato_servico
      AND p.versao_contrato = c.versao_contrato
      AND c.empresa = p.empresa
      AND c.fornecedor = p_tela.cod_fornecedor

   IF p_val_pago IS NULL THEN
      LET p_val_pago = 0
   END IF
   
   LET p_tela.saldo_da_nf = p_tela.val_tot_nf_d - p_val_pago

   IF p_tela.saldo_da_nf <= 0 THEN
      LET p_msg = 'Nota fiscal sem saldo, para\n baixar estapas de contrato'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   DISPLAY BY NAME p_tela.*            

   SELECT COUNT(num_aviso_rec)
     INTO m_qtd_item
     FROM aviso_rec
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec

   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','aviso_rec:count')
      RETURN FALSE
   END IF
   
   LET p_num_oc = NULL
   
   DECLARE cq_rec CURSOR FOR
    SELECT DISTINCT num_oc
      FROM aviso_rec
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec
   
   FOREACH cq_rec INTO l_num_oc
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','aviso_rec')
         RETURN FALSE
      END IF
      
      LET p_num_oc = l_num_oc
      
      EXIT FOREACH
   
   END FOREACH
              
   RETURN TRUE
          
END FUNCTION 

#---------------------------------#
 FUNCTION pol1204_busca_contrato()#
#---------------------------------#
   
   DEFINE l_num_oc INTEGER
   
   INITIALIZE pr_etapa TO NULL
   LET p_dat_proces = TODAY
   LET p_ind = 1

   DECLARE cq_contr CURSOR FOR
    SELECT DISTINCT
           e.contrato_servico,
           e.versao_contrato,
           e.num_etapa,
           e.dat_vencto_etapa,
           e.val_etapa, 
           f.val_oc_etapa, 
           'N',
           f.ordem_compra
      FROM cos_etapa_contrato e,
           cos_contr_servico c,
           cos_oc_etapa f
     WHERE e.empresa = p_cod_empresa
       AND e.sit_etapa = 'I'
       AND c.empresa = e.empresa
       AND c.contrato_servico = e.contrato_servico
       AND c.versao_contrato = e.versao_contrato
       AND c.fornecedor = p_tela.cod_fornecedor
       AND f.empresa = e.empresa
       AND f.contrato_servico = e.contrato_servico
       AND f.versao_contrato = e.versao_contrato
       AND f.num_etapa = e.num_etapa
     ORDER BY e.contrato_servico, e.dat_vencto_etapa
     
   FOREACH cq_contr INTO pr_etapa[p_ind].*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_contr')
         RETURN FALSE
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 1000 THEN
         LET p_msg = 'Limite de etapas previstas ultrapassou!.'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   IF p_ind = 1 THEN
   
      IF p_num_oc IS NOT NULL AND   
         p_num_oc > 0 THEN
   
         SELECT COUNT(ordem_compra)
           INTO p_count
           FROM sup_relc_oc_cnpj
          WHERE empresa = p_cod_empresa
            AND ordem_compra = p_num_oc
            AND cnpj = p_cnpj
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','sup_relc_oc_cnpj')
            RETURN FALSE
         END IF

         IF p_count = 0 THEN
            LET p_msg = 'Falta contrato v�lido/n para a NF informada.'
            CALL log0030_mensagem(p_msg,'info')
            RETURN FALSE
         END IF

      ELSE

         LET p_num_oc = NULL

         DECLARE cq_relac CURSOR FOR   
          SELECT DISTINCT ordem_compra
            FROM sup_relc_oc_cnpj
           WHERE empresa = p_cod_empresa
             AND cnpj = p_cnpj

         FOREACH cq_relac INTO l_num_oc

            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','sup_relc_oc_cnpj')
               RETURN FALSE
            END IF

            LET p_num_oc = l_num_oc
            EXIT FOREACH

         END FOREACH

         IF p_num_oc IS NULL THEN
            LET p_msg = 'Falta contrato v�lido/n para a NF informada.'
            CALL log0030_mensagem(p_msg,'info')
            RETURN FALSE
         END IF

      END IF      
        
      DECLARE cq_cos CURSOR FOR                               
       SELECT DISTINCT
              e.contrato_servico,                               
              e.versao_contrato,                                
              e.num_etapa,                                      
              e.dat_vencto_etapa,                               
              e.val_etapa, 0, 'N',
              c.ordem_compra                                 
         FROM cos_etapa_contrato e,                             
              cos_oc_contrato c
        WHERE e.empresa = p_cod_empresa                         
          AND e.sit_etapa = 'I'                                 
          AND c.empresa = e.empresa                             
          AND c.contrato_servico = e.contrato_servico           
          AND c.versao_contrato = e.versao_contrato             
          AND c.ordem_compra = p_num_oc                         
        ORDER BY e.contrato_servico, e.dat_vencto_etapa         
   
      FOREACH cq_cos INTO pr_etapa[p_ind].*

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_cos')
            RETURN FALSE
         END IF
         
         SELECT val_oc_etapa INTO pr_etapa[p_ind].val_oc_etapa
           FROM cos_oc_etapa
          WHERE empresa = p_cod_empresa
            AND contrato_servico = pr_etapa[p_ind].contrato_servico
            AND versao_contrato = pr_etapa[p_ind].versao_contrato
            AND num_etapa = pr_etapa[p_ind].num_etapa
            AND ordem_compra = pr_etapa[p_ind].num_oc

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','cos_oc_etapa:val_oc_etapa')
            LET pr_etapa[p_ind].val_oc_etapa = 0
         END IF
         
         LET p_ind = p_ind + 1
   
         IF p_ind > 1000 THEN
            LET p_msg = 'Limite de etapas previstas ultrapassou!.'
            CALL log0030_mensagem(p_msg,'excla')
            EXIT FOREACH
         END IF
   
      END FOREACH
   
   END IF
   
   IF p_ind = 1 THEN
      LET p_msg = 'N�o h� contrato vigente, para\n o fornecedor/nota informados'
      CALL log0030_mensagem(p_msg, 'excla')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_etapa
      WITHOUT DEFAULTS FROM sr_etapa.*
         BEFORE INPUT
            EXIT INPUT
   END INPUT

   RETURN TRUE
   
END FUNCTION 

#------------------------------#
 FUNCTION pol1204_le_contrato()#
#------------------------------#
   
   INITIALIZE pr_etapa TO NULL
   LET p_dat_proces = TODAY
   LET p_ind = 1

   DECLARE cq_etapas CURSOR FOR
    SELECT DISTINCT 
           e.contrato_servico,
           e.versao_contrato,
           e.num_etapa,
           e.dat_vencto_etapa,
           e.val_etapa, 
           f.val_oc_etapa,
           'N',
           f.ordem_compra
      FROM cos_etapa_contrato e,                             
           cos_contr_servico c,                              
           cos_oc_etapa f                                    
     WHERE e.empresa = p_cod_empresa                         
       AND e.sit_etapa = 'I'                                 
       AND c.empresa = e.empresa                             
       AND c.contrato_servico = e.contrato_servico           
       AND c.versao_contrato = e.versao_contrato          
       AND c.contrato_servico = p_tela.num_contrato       
       AND f.empresa = e.empresa                             
       AND f.contrato_servico = e.contrato_servico           
       AND f.versao_contrato = e.versao_contrato             
       AND f.num_etapa = e.num_etapa                         
     ORDER BY e.contrato_servico, e.dat_vencto_etapa         
     
   FOREACH cq_etapas INTO pr_etapa[p_ind].*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_contr')
         RETURN FALSE
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 1000 THEN
         LET p_msg = 'Limite de etapas previstas ultrapassou!.'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
      
   END FOREACH
     
   IF p_ind = 1 THEN
      LET p_msg = 'O contrato informado n�o � v�lido;'
      CALL log0030_mensagem(p_msg, 'excla')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_etapa
      WITHOUT DEFAULTS FROM sr_etapa.*
         BEFORE INPUT
            EXIT INPUT
   END INPUT   

   RETURN TRUE
   
END FUNCTION 

#---------------------------#
FUNCTION pol1204_processar()#
#---------------------------#

   INPUT ARRAY pr_etapa
      WITHOUT DEFAULTS FROM sr_etapa.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  
         
         CALL pol1204_val_baixar()

     AFTER FIELD ies_baixar         

        IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
             OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
        ELSE
           CALL pol1204_val_baixar()
           IF pr_etapa[p_ind+1].contrato_servico IS NULL THEN              
              NEXT FIELD ies_baixar
           END IF
        END IF
      
      AFTER INPUT
      
         IF NOT INT_FLAG THEN
            CALL pol1204_val_baixar()
            IF p_val_baixar > p_tela.saldo_da_nf THEN
               LET p_msg = 'Valor da baixa n�o pode ser\n',
                           'maior que o valor da nota.'
               CALL log0030_mensagem(p_msg,'excla')
               NEXT FIELD ies_baixar
            END IF
         END IF
                 
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1204_limpa_tela()
      RETURN FALSE
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   IF NOT pol1204_baixa_estapa() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#-----------------------------#
FUNCTION pol1204_val_baixar()#
#-----------------------------#

   LET p_val_baixar = 0
   
   FOR p_index = 1 to ARR_COUNT()
       IF pr_etapa[p_index].ies_baixar = 'S' THEN
          LET p_val_baixar = p_val_baixar + pr_etapa[p_index].val_oc_etapa
       END IF
   END FOR

   DISPLAY p_val_baixar TO val_baixar
    
END FUNCTION       

#------------------------------#
FUNCTION pol1204_baixa_estapa()#
#------------------------------#
   
   DEFINE l_num_oc      INTEGER
   
   CALL log085_transacao("BEGIN")
   
   FOR p_index = 1 TO ARR_COUNT()
       IF pr_etapa[p_index].contrato_servico IS NULL THEN
          EXIT FOR
       END IF
       
       IF pr_etapa[p_index].ies_baixar = 'S' THEN
          IF NOT pol1204_grava_tabs() THEN
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
          END IF    
       END IF
   
   END FOR

   UPDATE nf_sup 
      SET ies_nf_aguard_nfe = 'S',
          ies_especie_nf = 'NFS'
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_tela.num_aviso_rec

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'NF_SUP')
      RETURN FALSE
   END IF

   UPDATE ctb_lanc_ctbl_recb 
      SET espc_nota_fiscal = 'NFS'
    WHERE empresa = p_cod_empresa                                  
      AND nota_fiscal = p_tela.num_nf                                
      AND serie_nota_fiscal = p_tela.ser_nf                          
      AND subserie_nf = p_tela.ssr_nf                                 
      AND fornec_nota_fiscal = p_tela.cod_fornecedor         

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'ctb_lanc_ctbl_recb')
      RETURN FALSE
   END IF

   UPDATE lanc_cont_rec 
      SET ies_especie = 'NFS'  
    WHERE cod_empresa = p_cod_empresa                    
      AND num_nf = p_tela.num_nf                             
      AND ser_nf = p_tela.ser_nf                             
      AND ssr_nf = p_tela.ssr_nf                             
      AND cod_fornecedor = p_tela.cod_fornecedor      
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'lanc_cont_rec')
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")

   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1204_grava_tabs()#
#----------------------------#
  
   DEFINE l_num_prog    INTEGER
   
   LET p_num_contr  = pr_etapa[p_index].contrato_servico
   LET p_num_versao = pr_etapa[p_index].versao_contrato
   LET p_num_etapa  = pr_etapa[p_index].num_etapa
   LET p_dat_vencto = pr_etapa[p_index].dat_vencto_etapa
   LET p_val_etapa  = pr_etapa[p_index].val_etapa 
   LET p_val_oc_etapa = pr_etapa[p_index].val_oc_etapa
   LET p_num_oc     = pr_etapa[p_index].num_oc
   LET p_num_prog   = NULL
   
   DECLARE cq_bx_progs CURSOR FOR      
   SELECT p.num_prog_entrega,                                
          p.num_versao
     FROM prog_ordem_sup p, ordem_sup o                         
    WHERE o.cod_empresa = p_cod_empresa                         
      AND o.num_oc = p_num_oc                                   
      AND o.ies_versao_atual = 'S'                              
      AND p.cod_empresa = o.cod_empresa                         
      AND p.num_oc = o.num_oc                                   
      AND p.num_versao = o.num_versao    
      AND p.ies_situa_prog = 'F'        
     ORDER BY p.num_prog_entrega               
   
   FOREACH cq_bx_progs INTO l_num_prog,                                           
          p_versao_oc

      IF STATUS <> 0 THEN                                     
         CALL log003_err_sql('FOREACH', 'prog_ordem_sup/ordem_sup')    
         RETURN FALSE                                           
      END IF                                                    
      
      LET p_num_prog = l_num_prog
      EXIT FOREACH
   
   END FOREACH
   
   IF p_num_prog IS NULL THEN
      LET p_msg = 'N�o foi possivel atualizar a programa��o\n de entrega da OC ', p_num_oc      
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   END IF
                                                   
   UPDATE prog_ordem_sup_com                                 
      SET val_receb = val_receb + p_val_oc_etapa                
    WHERE cod_empresa = p_cod_empresa                        
      AND num_oc = p_num_oc                                  
      AND num_versao = p_versao_oc                           
      AND num_prog_entrega = p_num_prog                      
                                                                
   IF STATUS <> 0 THEN                                       
      CALL log003_err_sql('UPDATE', 'prog_ordem_sup_com')    
      RETURN FALSE                                           
   END IF                                                    

   SELECT 1 FROM cos_pagto_etapa
    WHERE empresa = p_cod_empresa
      AND filial = 0
      AND contrato_servico = p_num_contr
      AND versao_contrato = p_num_versao
      AND parcela = p_num_etapa
      AND nota_fiscal = p_tela.num_nf
      AND serie_nota_fiscal = p_tela.ser_nf
      AND subserie_nf = p_tela.ssr_nf

   IF STATUS = 0 THEN           
      RETURN TRUE
   END IF
   
   IF STATUS <> 100 THEN                            
      CALL log003_err_sql('UPDATE', 'prog_ordem_sup_com')    
      RETURN FALSE                                           
   END IF                                                    
   
   IF NOT pol1204_ins_cos_pagto_etapa() THEN
      RETURN FALSE
   END IF
   
   UPDATE cos_etapa_contrato 
      SET sit_etapa = 'L' 
    WHERE empresa = p_cod_empresa
      AND contrato_servico = p_num_contr 
      AND num_etapa = p_num_etapa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'cos_etapa_contrato')
      RETURN FALSE
   END IF
   
   LET parametro.texto = 'PAGAMENTO DA ETAPA ', p_num_etapa, ' DO CONTRATO ', p_num_contr
   CALL pol1161_grava_auadit(parametro) RETURNING p_status
   
   RETURN TRUE

END FUNCTION   
   
#-------------------------------------#
FUNCTION pol1204_ins_cos_pagto_etapa()#
#-------------------------------------#

   DEFINE p_pct_iss DECIMAL(5,2),
          p_val_iss DECIMAL(12,2),
          p_aviso_rec CHAR(06)
   
   INITIALIZE p_cos_pagto.* TO NULL
   
   SELECT perc_reten_iss 
     INTO p_pct_iss
     FROM reten_iss 
    WHERE cod_empresa = p_cod_empresa 
      AND num_ad_nf_orig = p_tela.num_nf
      AND ser_nf = p_tela.ser_nf 
      AND ssr_nf = p_tela.ssr_nf
      AND ies_especie_nf = p_tela.ies_especie_nf
      AND cod_fornecedor = p_tela.cod_fornecedor

   IF STATUS <> 0 THEN
      LET p_pct_iss = 0
   END IF   
   
   IF p_percent IS NULL THEN
      LET p_pct_iss = 0
   END IF
   
   LET p_val_iss = p_val_etapa * p_pct_iss / 100
   
   SELECT num_ad 
     INTO p_cos_pagto.apropr_desp
     FROM ad_mestre
    WHERE cod_empresa_orig = p_cod_empresa 
      AND num_nf = p_tela.num_nf
      AND ser_nf = p_tela.ser_nf
      AND ssr_nf = p_tela.ssr_nf
      AND cod_fornecedor = p_tela.cod_fornecedor 
   
   IF STATUS <> 0 THEN
      LET p_cos_pagto.apropr_desp = NULL
   END IF
       
   LET p_cos_pagto.empresa           = p_cod_empresa
   LET p_cos_pagto.filial            = 0
   LET p_cos_pagto.contrato_servico  = p_num_contr
   LET p_cos_pagto.versao_contrato   = p_num_versao
   LET p_cos_pagto.liberacao_val     = NULL
   LET p_cos_pagto.liberacao_etapa   = NULL
   LET p_cos_pagto.parcela           = p_num_etapa
   LET p_cos_pagto.nota_fiscal       = p_tela.num_nf
   LET p_cos_pagto.serie_nota_fiscal = p_tela.ser_nf
   LET p_cos_pagto.subserie_nf       = p_tela.ssr_nf
   LET p_cos_pagto.dat_vencto        = p_dat_vencto
   LET p_cos_pagto.qtd_medicao       = NULL
   LET p_cos_pagto.unid_medida       = NULL
   LET p_cos_pagto.preco_unit        = p_val_etapa
   LET p_cos_pagto.val_pagar         = p_val_etapa
   LET p_cos_pagto.val_iss           = p_val_iss
   LET p_cos_pagto.aliquota_iss      = p_pct_iss
   LET p_cos_pagto.retencao_iss      = 'N'
   LET p_cos_pagto.val_deducao       = NULL
   LET p_cos_pagto.val_acresc        = NULL
   LET p_cos_pagto.val_pago          = NULL
   LET p_cos_pagto.dat_pagto         = NULL
   LET p_aviso_rec                   = p_tela.num_aviso_rec USING '&&&&&&'
   LET p_cos_pagto.hist_pagto[750,755] = p_aviso_rec
   LET p_cos_pagto.hist_pagto[756,767] = '/001-001 001'
   
   INSERT INTO cos_pagto_etapa
    VALUES(p_cos_pagto.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','COS_PAGTO_ETAPA')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   
#--------------------------#   
FUNCTION pol1204_estornar()#
#--------------------------#

   IF NOT pol1204_informar() THEN
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1204_est_baixas() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1204_est_baixas()#
#----------------------------#

   DEFINE l_num_prog   LIKE prog_ordem_sup.num_prog_entrega,
          l_versao_oc  LIKE prog_ordem_sup.num_versao
   
   DEFINE l_num_ar     CHAR(06),
          l_num_oc     INTEGER,
          l_val_oc     DECIMAL(12,2),
          l_num_oc_ant INTEGER,
          l_ies_baixa  SMALLINT,
          l_prog       SMALLINT,
          l_val_receb  DECIMAL(12,2)
   
      
   LET l_ies_baixa = FALSE   
   
   LET l_num_ar = p_tela.num_aviso_rec USING '&&&&&&'

   DECLARE cq_estorno CURSOR FOR
    SELECT * 
      FROM cos_pagto_etapa
     WHERE empresa = p_cod_empresa
       AND nota_fiscal = p_tela.num_nf
       AND serie_nota_fiscal = p_tela.ser_nf
       AND subserie_nf = p_tela.ssr_nf
       AND hist_pagto[750,755] = l_num_ar
       
   FOREACH cq_estorno  INTO p_cos_pagto.*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cos_pagto_etapa:cq_estorno')
         RETURN FALSE
      END IF
      
      LET l_ies_baixa = TRUE
           
      DECLARE cq_oc_etapa CURSOR FOR
       SELECT ordem_compra
        INTO l_num_oc
        FROM cos_oc_etapa
       WHERE empresa = p_cod_empresa
         AND contrato_servico = p_cos_pagto.contrato_servico
         AND versao_contrato = p_cos_pagto.versao_contrato
         AND num_etapa = p_cos_pagto.parcela
      
      FOREACH cq_oc_etapa INTO l_num_oc, l_val_oc
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('UPDATE', 'cos_oc_etapa:cq_oc_etapa')
            RETURN FALSE
         END IF
   
         LET l_prog = FALSE
      
         DECLARE cq_ext_progs CURSOR FOR                            
         SELECT p.num_prog_entrega,                                 
                p.num_versao                                        
           FROM prog_ordem_sup p, ordem_sup o                       
          WHERE o.cod_empresa = p_cod_empresa                       
            AND o.ies_versao_atual = 'S'                            
            AND p.cod_empresa = o.cod_empresa                       
            AND p.num_oc = l_num_oc                                 
            AND p.num_oc = o.num_oc                                 
            AND p.num_versao = o.num_versao                         
            AND p.ies_situa_prog = 'F'                              
           ORDER BY p.num_prog_entrega                              
                                                                    
         FOREACH cq_ext_progs INTO l_num_prog, l_versao_oc          
                                                                    
            IF STATUS <> 0 THEN                                     
               CALL log003_err_sql('FOREACH', 'cq_ext_progs')       
               RETURN FALSE                                         
            END IF                                                  
                                                                    
            LET l_prog = TRUE                                       
            EXIT FOREACH                                            
                                                                    
         END FOREACH                                                
                                                                    
         IF NOT l_prog THEN
            LET p_msg = 'N�o foi possivel estornar a programa��o\n de entrega da OC ', l_num_oc      
            CALL log0030_mensagem(p_msg, 'info')
            RETURN FALSE
         END IF

         SELECT val_receb                                        
           INTO l_val_receb                                      
           FROM prog_ordem_sup_com                               
          WHERE cod_empresa = p_cod_empresa                      
            AND num_oc = l_num_oc                                
            AND num_versao = l_versao_oc                         
            AND num_prog_entrega = l_num_prog                    
                                                                 
         IF STATUS <> 0 THEN                                     
            CALL log003_err_sql('SELECT', 'prog_ordem_sup_com')  
            RETURN FALSE                                         
         END IF                                                  
      
         IF l_val_oc < l_val_receb THEN                            
            UPDATE prog_ordem_sup_com                              
               SET val_receb = val_receb - l_val_oc                
             WHERE cod_empresa = p_cod_empresa                     
               AND num_oc = l_num_oc                               
               AND num_versao = l_versao_oc                        
               AND num_prog_entrega = l_num_prog                   
                                                                   
            IF STATUS <> 0 THEN                                    
               CALL log003_err_sql('UPDATE', 'prog_ordem_sup_com') 
               RETURN FALSE                                        
            END IF                                                 
         END IF
   
      END FOREACH
      
   END FOREACH

   IF NOT l_ies_baixa THEN
      LET p_msg = 'N�O H� ETAPAS BAIXADAS PARA ESSE AR,'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   DELETE FROM cos_pagto_etapa
    WHERE empresa = p_cod_empresa
      AND nota_fiscal = p_tela.num_nf
      AND serie_nota_fiscal = p_tela.ser_nf
      AND subserie_nf = p_tela.ssr_nf
      AND hist_pagto[750,755] = l_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'cos_pagto_etapa')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         


#-------------------------------- FIM DE PROGRAMA BL-----------------------------#


{

   CREATE TABLE aviso_rec_iurd (
     cod_empresa     CHAR(02),
     num_aviso_rec   INTEGER,
     num_oc          INTEGER
   );
   
   CREATE UNIQUE INDEX ix_aviso_rec_iurd ON
    aviso_rec_iurd(cod_empresa, num_aviso_rec);
    
    
   

