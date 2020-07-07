#-------------------------------------------------------------------#
# PROGRAMA: pol0927                                                 #
# OBJETIVO: DEVOLUÇÃO DOS CLIENTES(KITS)                            #
# CLIENTE.: ALBRAS                                                  #
# DATA....: 22/04/2009                                              #
# POR.....: WILLIANS                                                #
# ALTERACÃO MOTIVO                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
        	p_den_empresa        LIKE empresa.den_empresa,
        	p_user               LIKE usuario.nom_usuario,
        	p_id_ajust           INTEGER,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_msg                CHAR(150),
          p_nom_arquivo        CHAR(100),
          p_count              SMALLINT,
          p_rowid              SMALLINT,
       	  p_houve_erro         SMALLINT,
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
       	  p_retorno            SMALLINT,
          p_nom_tela           CHAR(200),
       	  p_status             SMALLINT,
       	  p_caminho            CHAR(100),
       	  comando              CHAR(80),
          p_versao             CHAR(18),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),
          p_ies_cons           SMALLINT,
          p_tip_ajust          CHAR(01),
          p_tem_lote           SMALLINT,
          p_num_processo       INTEGER,
          p_cod_status         CHAR(01),
          p_ies_info           SMALLINT,
          p_hoje               DATE 

   
   DEFINE p_tela               RECORD
          num_aviso_rec        LIKE aviso_rec.num_aviso_rec,
          num_nf               LIKE nf_sup.num_nf,
          cod_fornecedor       LIKE nf_sup.cod_fornecedor
   END RECORD 
   
   DEFINE p_num_aviso_rec      LIKE aviso_rec.num_aviso_rec,
          p_num_nf             LIKE nf_sup.num_nf,
          p_dat_emis_nf        LIKE nf_sup.dat_emis_nf,
          p_cod_fornecedor     LIKE nf_sup.cod_fornecedor,
          p_raz_social         LIKE fornecedor.raz_social,
          p_ies_especie_nf     LIKE nf_sup.ies_especie_nf,
          p_qtd_movto          LIKE estoque_trans.qtd_movto,
          p_cod_local          LIKE estoque_lote.cod_local,
          p_ies_situa          LIKE estoque_lote.ies_situa_qtd,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_largura            LIKE estoque_trans_end.largura,
          p_altura             LIKE estoque_trans_end.altura,
          p_diametro           LIKE estoque_trans_end.diametro,
          p_comprimento        LIKE estoque_trans_end.comprimento,
          p_ies_liberacao_insp LIKE aviso_rec.ies_liberacao_insp,
          p_num_nff_origem     LIKE dev_mestre.num_nff_origem,
          p_qtd_item           LIKE dev_item.qtd_item,
          p_cod_item           LIKE dev_item.cod_item,
          p_quantidade_estoq   INTEGER,
          p_comprimento        LIKE estoque_trans_end.comprimento, 
          p_diametro           LIKE estoque_trans_end.diametro,
          p_largura            LIKE estoque_trans_end.largura,
          p_altura             LIKE estoque_trans_end.altura,
          p_num_seq            LIKE estoque_trans.num_seq,
          p_num_docum          LIKE ordens.num_docum,
          p_num_pedido         INTEGER,
          p_num_ped_seq        INTEGER,
          p_num_ordem          LIKE ordens.num_ordem,
          p_num_transac_ender  LIKE estoque_lote_ender.num_transac,
          p_num_transac_lote   LIKE estoque_lote.num_transac,
          p_qtd_saldo          LIKE estoque_lote_ender.qtd_saldo,
          p_qtd_reservada      LIKE estoque_loc_reser.qtd_reservada,
          p_cod_operac_estoq_l LIKE par_sup.cod_operac_estoq_l,
          p_num_transac        LIKE estoque_trans.num_transac,
          p_num_transac_orig   LIKE estoque_trans.num_transac,
          p_cod_tip_movto      LIKE estoque_trans.ies_tip_movto,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_ies_situa_orig     LIKE estoque_trans.ies_sit_est_orig,
          p_ies_situa_dest     LIKE estoque_trans.ies_sit_est_dest,
          p_cod_local_orig     LIKE estoque_trans.cod_local_est_orig,
          p_cod_local_dest     LIKE estoque_trans.cod_local_est_dest,
          p_cod_local_prod     LIKE estoque_trans.cod_local_est_dest,
          p_num_lote_orig      LIKE estoque_lote.num_lote,
          p_num_lote_dest      LIKE estoque_lote.num_lote,
          p_ies_operacao       CHAR(01)

   DEFINE p_estoque_trans      RECORD LIKE estoque_trans.*,      
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*
                
       
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT 
   LET p_versao = "pol0927-10.02.00"
   
   OPTIONS
     NEXT KEY control-f,
     PREVIOUS KEY control-b,
     DELETE KEY control-e

   CALL log001_acessa_usuario("ESPEC999","")     
       RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0927_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0927_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0927") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0927 AT 2,2 WITH FORM p_nom_tela 
    ATTRIBUTES(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa
   LET p_ies_info = FALSE 

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ o processamento"
         CALL pol0927_limpa_tela()
         CALL pol0927_informar() RETURNING p_status
         IF p_status THEN
            ERROR "Parâmetros informados com sucesso !!!"
            LET p_ies_info = TRUE
            NEXT OPTION 'Processar'
         ELSE
            ERROR "Operação Cancelada !!!"
            LET p_ies_info = FALSE
         END IF 
      COMMAND "Processar" "Processa os dados já informados com sucesso"
         IF p_ies_info THEN
            CALL pol0927_processar() RETURNING p_status
            IF p_status THEN
               ERROR "Processamento efetuado com sucesso !!!"   
               LET p_ies_info = FALSE
            ELSE
               ERROR 'Operação canceada!!!'
            END IF
         ELSE
            ERROR 'Informe os parâmetros previamente!!!'
            NEXT OPTION "Informar"
         END IF 
         NEXT OPTION "Fim" 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0927_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0927

END FUNCTION

#--------------------------#
FUNCTION pol0927_informar()
#--------------------------#
   
   INITIALIZE p_tela TO NULL
   

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD num_aviso_rec
         IF p_tela.num_aviso_rec IS NULL THEN
            NEXT FIELD num_nf
         END IF

         SELECT num_nf,
                dat_emis_nf,
                cod_fornecedor,
                ies_especie_nf
           INTO p_tela.num_nf,
                p_dat_emis_nf,
                p_tela.cod_fornecedor,
                p_ies_especie_nf
           FROM nf_sup
          WHERE cod_empresa    = p_cod_empresa
            AND num_aviso_rec  = p_tela.num_aviso_rec

         IF STATUS = 100 THEN
            ERROR 'AR não encontrado!!!'
            NEXT FIELD num_aviso_rec
         ELSE 
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo', 'nf_sup')
               NEXT FIELD num_aviso_rec
            END IF 
         END IF
         
         IF p_ies_especie_nf <> 'NFD' THEN 
            ERROR 'A espécie da nota encontrada não é de devolução!!!'
            NEXT FIELD num_aviso_rec
         END IF 
         
         SELECT raz_social
           INTO p_raz_social
           FROM fornecedor
          WHERE cod_fornecedor = p_tela.cod_fornecedor
           
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo', 'fornecedor')
         END IF 
         
         DISPLAY p_tela.num_nf         TO num_nf
         DISPLAY p_dat_emis_nf         TO dat_emis_nf
         DISPLAY p_tela.cod_fornecedor TO cod_fornecedor
         DISPLAY p_raz_social          TO raz_social
         
         IF NOT pol0927_ve_possibilidade() THEN 
            NEXT FIELD num_aviso_rec
         END IF 
         
         EXIT INPUT
         
         AFTER FIELD num_nf
            IF p_tela.num_nf IS NULL THEN 
               NEXT FIELD num_aviso_rec
            END IF 
            
         AFTER FIELD cod_fornecedor
            IF p_tela.cod_fornecedor IS NULL THEN 
               ERROR "Campo com prenchimento obrigatório!!!"
               NEXT FIELD cod_fornecedor
            END IF 
         
            SELECT num_aviso_rec,
                   dat_emis_nf,
                   ies_especie_nf
              INTO p_tela.num_aviso_rec,
                   p_dat_emis_nf,
                   p_ies_especie_nf
              FROM nf_sup
             WHERE cod_empresa    = p_cod_empresa
               AND num_nf         = p_tela.num_nf
               AND cod_fornecedor = p_tela.cod_fornecedor
            
            IF STATUS = 100 THEN
               ERROR 'NF não encontrada ou não é do fornecedor informado!!!'
               NEXT FIELD num_nf
            ELSE 
               IF STATUS <> 0 THEN 
                  CALL log003_err_sql('lendo', 'nf_sup')
                  NEXT FIELD cod_fornecedor
               END IF 
            END IF
         
            IF p_ies_especie_nf <> 'NFD' THEN 
               ERROR 'A espécie da nota encontrada não é de devolução!!!'
               NEXT FIELD num_nf
            END IF 
            
            SELECT raz_social
              INTO p_raz_social
              FROM fornecedor
             WHERE cod_fornecedor = p_tela.cod_fornecedor
            
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo', 'fornecedor')
            END IF 
         
            DISPLAY p_tela.num_aviso_rec  TO num_aviso_rec
            DISPLAY p_dat_emis_nf         TO dat_emis_nf
            DISPLAY p_raz_social          TO raz_social
            
            IF NOT pol0927_ve_possibilidade() THEN 
               NEXT FIELD num_nf
            END IF 
            
   ON KEY (control-z)
      CALL pol0927_popup()
   
   END INPUT

   IF INT_FLAG THEN
      
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol0927_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   
END FUNCTION

#-----------------------#
 FUNCTION pol0927_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     
      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0927
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_fornecedor = p_codigo CLIPPED
            DISPLAY p_tela.cod_fornecedor TO cod_fornecedor
         END IF

   END CASE
   

END FUNCTION

#-----------------------------------#
 FUNCTION pol0927_ve_possibilidade()
#-----------------------------------#

    {SELECT COUNT(ies_liberacao_insp)
      INTO p_count
      FROM aviso_rec
     WHERE cod_empresa        = p_cod_empresa
       AND num_aviso_rec      = p_tela.num_aviso_rec
       AND ies_liberacao_insp = 'N'
            
    IF p_count > 0 THEN 
       ERROR "Nota fiscal não inspecionada!!!"
       RETURN FALSE 
    END IF}
     
    SELECT num_nff_origem 
      INTO p_num_nff_origem 
      FROM dev_mestre
     WHERE cod_empresa  = p_cod_empresa
       AND num_nff      = p_tela.num_aviso_rec
       AND cod_cliente  = p_tela.cod_fornecedor
               
    IF STATUS = 100 THEN
       ERROR "Nota de devolução não relacionada com a nota de saída!!!"
       RETURN FALSE
    ELSE 
       IF STATUS <> 0 THEN 
          CALL log003_err_sql('lendo','dev_mestre')
          RETURN FALSE
       END IF
    END IF  
    
    IF p_num_nff_origem = 0 THEN
       ERROR 'NFD relacionada com NFS inexistente. Cheque o relacionamento'
       RETURN FALSE
    END IF
    
    SELECT num_aviso_rec
      FROM ar_proces_304
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_tela.num_aviso_rec
       
    IF STATUS = 100 THEN
    ELSE 
       IF STATUS <> 0 THEN 
          CALL log003_err_sql('lendo','ar_proces_304')
          RETURN FALSE 
       ELSE 
          ERROR "AR já processado!!!"
          RETURN FALSE
       END IF 
    END IF
       
    RETURN TRUE 
    
END FUNCTION

#---------------------------#
 FUNCTION pol0927_processar()
#---------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   #baixa do estoque o item devolvido 
   
   IF NOT pol0927_baixa_estoque() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   #entra no estoque os componentes usados 
   #na produção do item devolvido   

   IF NOT pol0927_entrada_estoque() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   IF NOT pol0927_insere_AR() THEN 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
 FUNCTION pol0927_baixa_estoque()
#-------------------------------#
   
   DEFINE p_qtd_insp LIKE estoque_trans.qtd_movto
   
   DECLARE cq_baixa_estoque CURSOR FOR  
    SELECT cod_item,
           num_sequencia
      FROM dev_item
     WHERE cod_empresa = p_cod_empresa
       AND num_nff     = p_tela.num_aviso_rec
       
    FOREACH cq_baixa_estoque INTO
            p_cod_item,
            p_num_seq
                  
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','dev_item')
         RETURN FALSE
      END IF  
   
      SELECT cod_operac_estoq_l
        INTO p_cod_operac_estoq_l
        FROM par_sup
       WHERE cod_empresa = p_cod_empresa
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','par_sup')
         RETURN FALSE
      END IF 

      LET p_qtd_insp = 0
      
      DECLARE cq_trans CURSOR FOR
       SELECT MAX(num_transac)
         FROM estoque_trans
        WHERE cod_empresa   = p_cod_empresa
          AND num_docum     = p_tela.num_aviso_rec
          AND num_seq       = p_num_seq
          AND cod_item      = p_cod_item
          AND cod_operacao  = p_cod_operac_estoq_l
          AND ies_tip_movto = 'N'
     GROUP BY num_lote_dest
                             
      FOREACH cq_trans INTO p_num_transac
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","estoque_trans:1")       
            RETURN FALSE
         END IF
         
         SELECT qtd_movto,
                cod_local_est_dest,
                num_lote_dest,
                ies_sit_est_dest
           INTO p_qtd_movto,
                p_cod_local,
                p_num_lote,
                p_ies_situa
           FROM estoque_trans
          WHERE cod_empresa = p_cod_empresa
            AND num_transac = p_num_transac
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","estoque_trans:3")       
            RETURN 
         END IF
         
         LET p_qtd_insp = p_qtd_insp + p_qtd_movto

         SELECT comprimento,
                altura,
                largura,
                diametro
           INTO p_comprimento,
                p_altura,
                p_largura,
                p_diametro
           FROM estoque_trans_end
          WHERE cod_empresa   = p_cod_empresa
            AND num_transac   = p_num_transac
            AND ies_tip_movto = 'N'
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","estoque_trans_end")       
            RETURN 
         END IF

         IF NOT pol0927_proces_baixa() THEN
            RETURN FALSE
         END IF
         
      END FOREACH
        
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0927_proces_baixa()
#------------------------------#

   IF NOT pol0927_bx_estoque_lote_ender() THEN
      RETURN FALSE
   END IF
         
   IF NOT pol0927_bx_estoque_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol0927_bx_estoque() THEN
      RETURN FALSE
   END IF
         
   LET p_cod_tip_movto = 'N'
   LET p_ies_operacao = 'S'
         
   IF NOT pol0927_insere_transacao() THEN
      RETURN FALSE
   END IF
         
   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0927_bx_estoque_lote_ender()
#---------------------------------------#

   CALL pol0927_le_estoque_lote_ender()

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','estoque_lote_ender')
      RETURN FALSE
   END IF

   LET p_num_transac_ender = p_estoque_lote_ender.num_transac
   LET p_qtd_saldo         = p_estoque_lote_ender.qtd_saldo
   
   IF NOT pol0927_le_reserva() THEN
      RETURN FALSE
   END IF
   
   IF p_qtd_saldo < p_qtd_movto THEN 
      LET p_msg = "Não há saldo suficiente na tabela: estoque_lote_ender!!!"
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE 
   END IF 
   
   IF p_qtd_saldo > p_qtd_movto THEN
      IF NOT pol0927_atualiza_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0927_deleta_ender() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE 

END FUNCTION 

#--------------------------------------#
FUNCTION pol0927_le_estoque_lote_ender()
#--------------------------------------#

   IF p_num_lote IS NOT NULL THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_item
         AND cod_local     = p_cod_local
         AND num_lote      = p_num_lote
         AND ies_situa_qtd = p_ies_situa
         AND comprimento   = p_comprimento
         AND largura       = p_largura
         AND altura        = p_altura
         AND diametro      = p_diametro
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_item
         AND cod_local     = p_cod_local
         AND num_lote      IS NULL
         AND ies_situa_qtd = p_ies_situa
         AND comprimento   = p_comprimento
         AND largura       = p_largura
         AND altura        = p_altura
         AND diametro      = p_diametro
   END IF     
   
END FUNCTION

#--------------------------------#
FUNCTION pol0927_atualiza_ender()
#--------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo   = qtd_saldo - p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac_ender

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Update','estoque_lote_ender')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0927_deleta_ender()
#------------------------------#

   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac_ender

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_lote_ender')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0927_le_reserva()
#----------------------------#
   
   IF p_num_lote IS NOT NULL THEN
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada
        FROM estoque_loc_reser a,
             est_loc_reser_end b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.cod_item    = p_cod_item
         AND a.cod_local   = p_cod_local
         AND a.num_lote    = p_num_lote
         AND b.cod_empresa = a.cod_empresa
         AND b.num_reserva = a.num_reserva
         AND b.largura     = p_largura
         AND b.altura      = p_altura
         AND b.diametro    = p_diametro
         AND b.comprimento = p_comprimento   
   ELSE
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada
        FROM estoque_loc_reser a,
             est_loc_reser_end b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.cod_item    = p_cod_item
         AND a.cod_local   = p_cod_local
         AND a.num_lote    IS NULL
         AND b.cod_empresa = a.cod_empresa
         AND b.num_reserva = a.num_reserva
         AND b.largura     = p_largura
         AND b.altura      = p_altura
         AND b.diametro    = p_diametro
         AND b.comprimento = p_comprimento   
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_loc_reser')
      RETURN FALSE
   END IF  

   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF
       
   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol0927_bx_estoque_lote()
#---------------------------------#

   CALL pol0927_le_estoque_lote()
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_lote')
      RETURN FALSE
   END IF
         
   IF NOT pol0927_le_reserva() THEN
      RETURN FALSE
   END IF
   
   IF p_qtd_saldo < p_qtd_movto THEN 
      CALL log0030_mensagem("Não há saldo suficiente na tabela: estoque_lote!!!", 'excla')
      RETURN FALSE 
   END IF 
   
   IF p_qtd_saldo > p_qtd_movto THEN
      IF NOT pol0927_atualiza_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0927_deleta_lote() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE 

END FUNCTION 

#--------------------------------#
FUNCTION pol0927_le_estoque_lote()
#--------------------------------#

   IF p_num_lote IS NOT NULL THEN
      SELECT qtd_saldo,
             num_transac
        INTO p_qtd_saldo,
             p_num_transac_lote
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_item
         AND cod_local     = p_cod_local
         AND num_lote      = p_num_lote
         AND ies_situa_qtd = p_ies_situa
   ELSE 
      SELECT qtd_saldo,
             num_transac
        INTO p_qtd_saldo,
             p_num_transac_lote
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_item
         AND cod_local     = p_cod_local
         AND num_lote      IS NULL 
         AND ies_situa_qtd = p_ies_situa
   END IF 
   
END FUNCTION

#-------------------------------#
 FUNCTION pol0927_atualiza_lote()
#-------------------------------#

   UPDATE estoque_lote
      SET qtd_saldo   = qtd_saldo - p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac_lote

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','estoque_lote')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol0927_deleta_lote()
#-----------------------------#

   DELETE FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac_lote

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_lote')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
 FUNCTION pol0927_bx_estoque()
#-----------------------------#

   DEFINE p_qtd_liberada  LIKE estoque.qtd_liberada,
          p_qtd_lib_excep LIKE estoque.qtd_lib_excep,
          p_qtd_rejeitada LIKE estoque.qtd_rejeitada
   
   SELECT qtd_liberada,
          qtd_lib_excep,
          qtd_rejeitada
     INTO p_qtd_liberada,
          p_qtd_lib_excep,
          p_qtd_rejeitada
     FROM estoque 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','estoque')
      RETURN FALSE 
   END IF
   
   IF p_ies_situa = 'L' THEN 
      IF p_qtd_liberada < p_qtd_movto THEN
         CALL log0030_mensagem("Não há saldo suficiente na tabela: estoque!!!",'excla')
         RETURN FALSE 
      END IF 
      LET p_qtd_liberada = p_qtd_liberada - p_qtd_movto
   ELSE 
      IF p_ies_situa = 'E' THEN
         IF p_qtd_lib_excep < p_qtd_movto THEN
            CALL log0030_mensagem("Não há saldo suficiente na tabela: estoque!!!",'excla')
            RETURN FALSE 
         END IF 
         LET p_qtd_lib_excep = p_qtd_lib_excep - p_qtd_movto
      ELSE 
         IF p_qtd_rejeitada < p_qtd_movto THEN
            CALL log0030_mensagem("Não há saldo suficiente na tabela: estoque!!!",'excla')
            RETURN FALSE 
         END IF
         LET p_qtd_rejeitada = p_qtd_rejeitada - p_qtd_movto
      END IF
   END IF  
   
   UPDATE estoque
      SET qtd_liberada   = p_qtd_liberada, 
          qtd_lib_excep  = p_qtd_lib_excep, 
          qtd_rejeitada  = p_qtd_rejeitada
    WHERE cod_empresa    = p_cod_empresa
      AND cod_item       = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','estoque')
      RETURN FALSE
   END IF
   
   RETURN TRUE 

END FUNCTION 


#----------------------------------#
 FUNCTION pol0927_insere_transacao()
#----------------------------------#

   IF NOT pol0927_ins_estoque_trans() THEN
      RETURN FALSE
   END IF

   IF NOT pol0927_ins_estoque_audit() THEN
      RETURN FALSE
   END IF

   IF NOT pol0927_ins_estoque_trans_end() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0927_ins_estoque_trans()
#-----------------------------------#

   IF NOT pol0927_pega_dados_mov() THEN
      RETURN FALSE
   END IF

   INSERT INTO estoque_trans(
          cod_empresa,
          num_transac,
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
                  p_estoque_trans.num_transac,
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

   LET p_num_transac_orig = SQLCA.SQLERRD[2]

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0927_pega_dados_mov()
#--------------------------------#

   DEFINE p_num_conta       LIKE estoque_trans.num_conta,
          p_ies_com_detalhe LIKE estoque_operac.ies_com_detalhe
            
   IF NOT pol0927_le_operacao() THEN
      RETURN FALSE
   END IF
   
   SELECT ies_com_detalhe
     INTO p_ies_com_detalhe
     FROM estoque_operac
    WHERE cod_empresa  = p_cod_empresa
      AND cod_operacao = p_cod_operacao

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Lendo','estoque_operac')
     RETURN FALSE
   END IF

   IF p_ies_com_detalhe <> 'S' THEN 
      LET p_num_conta = NULL
   ELSE
      IF p_ies_operacao = 'S' THEN
         SELECT num_conta_debito 
           INTO p_num_conta
           FROM estoque_operac_ct
          WHERE cod_empresa  = p_cod_empresa
            AND cod_operacao = p_cod_operacao
      ELSE
         SELECT num_conta_credito 
           INTO p_num_conta
           FROM estoque_operac_ct
          WHERE cod_empresa  = p_cod_empresa
            AND cod_operacao = p_cod_operacao
      END IF
   END IF
   
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Lendo','estoque_operac_ct')
     RETURN FALSE
   END IF
   
   LET p_estoque_trans.cod_empresa        = p_cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_cod_item
   LET p_estoque_trans.dat_movto          = TODAY
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_docum          = p_tela.num_aviso_rec
   LET p_estoque_trans.num_seq            = p_num_seq
   LET p_estoque_trans.ies_tip_movto      = p_cod_tip_movto
   LET p_estoque_trans.qtd_movto          = p_qtd_movto
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   IF p_ies_operacao = 'S' THEN 
      LET p_estoque_trans.cod_local_est_orig = p_cod_local
      LET p_estoque_trans.num_lote_orig      = p_num_lote
      LET p_estoque_trans.ies_sit_est_orig   = p_ies_situa
      LET p_estoque_trans.cod_local_est_dest = NULL
      LET p_estoque_trans.num_lote_dest      = NULL
      LET p_estoque_trans.ies_sit_est_dest   = NULL
   ELSE
      LET p_estoque_trans.cod_local_est_orig = NULL
      LET p_estoque_trans.num_lote_orig      = NULL
      LET p_estoque_trans.ies_sit_est_orig   = NULL
      LET p_estoque_trans.cod_local_est_dest = p_cod_local
      LET p_estoque_trans.num_lote_dest      = p_num_lote
      LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa
   END IF
   LET p_estoque_trans.cod_turno   = NULL
   LET p_estoque_trans.nom_usuario = p_user
   LET p_estoque_trans.dat_proces  = TODAY
   LET p_estoque_trans.hor_operac  = TIME
   LET p_estoque_trans.num_prog    = "pol0927"

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0927_le_operacao()
#-----------------------------#

   IF p_ies_operacao = 'S' THEN   
      SELECT cod_oper_sai    
        INTO p_cod_operacao
        FROM oper_dev_304
       WHERE cod_empresa = p_cod_empresa
   ELSE                
      SELECT cod_oper_ent    
        INTO p_cod_operacao
        FROM oper_dev_304
       WHERE cod_empresa = p_cod_empresa
   END IF
   
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Lendo','oper_dev_304')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0927_ins_estoque_audit()
#-----------------------------------#
  
  LET p_hoje = TODAY  
  
  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, 
            p_num_transac_orig, 
            p_user, 
            p_hoje,
            'pol0927')

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria')  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------------#
 FUNCTION pol0927_ins_estoque_trans_end()
#---------------------------------------#

   DEFINE p_estoque_trans_end  RECORD LIKE estoque_trans_end.*

   LET p_estoque_trans_end.num_transac      = p_num_transac_orig
   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = ' '
   LET p_estoque_trans_end.tex_reservado    = " "

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end')
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0927_entrada_estoque()
#--------------------------------#
   
   DECLARE cq_entra_estoque CURSOR FOR  
    SELECT cod_item,
           num_sequencia,
           qtd_item
      FROM dev_item
     WHERE cod_empresa = p_cod_empresa
       AND num_nff     = p_tela.num_aviso_rec
       
   FOREACH cq_entra_estoque INTO
           p_cod_item,
           p_num_seq,
           p_qtd_item
                  
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','dev_item:2')
         RETURN FALSE
      END IF  
      
      IF pol0927_proces_entrada() THEN 
      ELSE 
         RETURN FALSE 
      END IF   
      
   END FOREACH
    
   RETURN TRUE
   
END FUNCTION


#--------------------------------#
FUNCTION pol0927_proces_entrada()
#--------------------------------#

   DEFINE p_qtd_neces       LIKE ord_compon.qtd_necessaria,
          p_ies_ctr_estoque LIKE item.ies_ctr_estoque,
          p_ies_ctr_lote    LIKE item.ies_ctr_lote
   
   SELECT num_pedido,
          num_sequencia
     INTO p_num_pedido,
          p_num_ped_seq
     FROM nf_item
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_num_nff_origem
      AND cod_item    = p_cod_item
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','nf_item')
      RETURN FALSE
   END IF

   LET p_num_docum = p_num_pedido
   LET p_num_docum = p_num_docum CLIPPED, '/', p_num_ped_seq USING '<<<'

   IF NOT pol0927_le_num_ordem() THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_compon CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_num_ordem
   
   FOREACH cq_compon INTO
      p_cod_item,
      p_qtd_neces
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ord_compon')
         RETURN FALSE
      END IF
      
      LET p_qtd_movto = p_qtd_item * p_qtd_neces
      
      SELECT ies_ctr_estoque,
             ies_ctr_lote,
             cod_local_estoq
        INTO p_ies_ctr_estoque,
             p_ies_ctr_lote,
             p_cod_local
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item')
         RETURN FALSE
      END IF
      
      IF p_ies_ctr_estoque = 'N' THEN
         CONTINUE FOREACH
      END IF
      
      IF p_ies_ctr_lote = 'N' THEN
         LET p_num_lote = NULL
      ELSE
         LET p_num_lote = p_tela.num_aviso_rec USING '<<<<<<'
         LET p_num_lote = p_num_lote CLIPPED, '-', p_num_seq USING '<<<'
      END IF
      
      LET p_ies_situa   = 'L'
      LET p_largura     = 0
      LET p_altura      = 0
      LET p_diametro    = 0
      LET p_comprimento = 0
      
      IF NOT pol0927_efetua_entrada() THEN
         RETURN FALSE
      END IF
      
   END FOREACH      
         
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0927_le_num_ordem()
#-----------------------------#

   INITIALIZE p_num_ordem TO NULL
   
   DECLARE cq_op CURSOR FOR
    SELECT num_ordem
  		FROM ordens
		 WHERE cod_empresa = p_cod_empresa
		   AND cod_item    = p_cod_item
		   AND ies_origem  = 'H'
		   AND num_docum   = p_num_docum

   FOREACH cq_op INTO p_num_ordem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordens')
         RETURN FALSE
      END IF  
      
      EXIT FOREACH
   
   END FOREACH
   
   IF p_num_ordem IS NULL THEN
      LET p_msg = 'Não foi possivel localizar a OP do item: ', p_cod_item
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0927_efetua_entrada()
#--------------------------------#

   CALL pol0927_le_estoque_lote_ender() 
   
   IF STATUS = 0 THEN
      LET p_qtd_movto = -p_qtd_movto
      IF NOT pol0927_atualiza_ender() THEN
         RETURN FALSE
      END IF
      LET p_qtd_movto = -p_qtd_movto
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol0927_insere_lote_ender() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','estoque_lote_ender:e')
         RETURN FALSE
      END IF
   END IF

   CALL pol0927_le_estoque_lote()
    
   IF STATUS = 0 THEN
      LET p_qtd_movto = -p_qtd_movto
      IF NOT pol0927_atualiza_lote() THEN
         RETURN FALSE
      END IF
      LET p_qtd_movto = -p_qtd_movto
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol0927_insere_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','estoque_lote:e')
         RETURN FALSE
      END IF
   END IF

   UPDATE estoque
      SET qtd_liberada   = qtd_liberada + p_qtd_movto 
    WHERE cod_empresa    = p_cod_empresa
      AND cod_item       = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','estoque')
      RETURN FALSE
   END IF
            
   LET p_cod_tip_movto = 'N'
   LET p_ies_operacao = 'E'
         
   IF NOT pol0927_insere_transacao() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0927_insere_lote_ender()
#-----------------------------------#

   CALL pol0927_carrega_campos()
   
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
          num_transac,
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
                 p_estoque_lote_ender.num_transac,
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

#-------------------------------#
FUNCTION pol0927_carrega_campos()
#-------------------------------#

   LET p_estoque_lote_ender.cod_empresa        = p_cod_empresa
	 LET p_estoque_lote_ender.cod_item           = p_cod_item
	 LET p_estoque_lote_ender.cod_local          = p_cod_local
	 LET p_estoque_lote_ender.num_lote           = p_num_lote
	 LET p_estoque_lote_ender.ies_situa_qtd      = p_ies_situa
	 LET p_estoque_lote_ender.qtd_saldo          = p_qtd_movto
   LET p_estoque_lote_ender.largura            = p_largura
   LET p_estoque_lote_ender.altura             = p_altura
   LET p_estoque_lote_ender.num_serie          = ' '
   LET p_estoque_lote_ender.diametro           = p_diametro
   LET p_estoque_lote_ender.comprimento        = p_comprimento
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

#-----------------------------#
 FUNCTION pol0927_insere_lote()
#-----------------------------#

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo,
          num_transac)  
   VALUES(p_cod_empresa,
             p_cod_item,
            p_cod_local,
             p_num_lote,
            p_ies_situa,
          p_qtd_movto,0)
                 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estoque_lote')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
 FUNCTION pol0927_insere_AR()
#---------------------------#

   INSERT INTO ar_proces_304(
          cod_empresa, 
          num_aviso_rec)  
   VALUES(p_cod_empresa,
          p_tela.num_aviso_rec
          )
                 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ar_proces_304')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------#
 FUNCTION pol0927_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION