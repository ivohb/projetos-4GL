#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: POL1067                                                 #
# CLIENTE.: ITAESBRA
# OBJETIVO: INCLUSÃO/ALTERAÇÃO DE PEDIDOS                           #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 16/11/2010                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_pedido         LIKE frete_unit_kana.num_pedido,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_cod_cidade         LIKE cidades.cod_cidade,
          p_den_cidade         LIKE cidades.den_cidade,
          p_cod_uni_feder      LIKE cidades.cod_uni_feder,
          p_qtd_saldo          DECIMAL(10,3),
          p_qtd_dif            DECIMAL(10,3),
          p_consistido         SMALLINT,
          p_val_total          DECIMAL(11,2),
          p_qtd_solic          DECIMAL(10,2),
          p_opcao              CHAR(01),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_sem_saldo          SMALLINT,
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
          p_dat_txt            CHAR(10),
          p_dat_inv            CHAR(10),
          p_tot_ger            DECIMAL(13,2),
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          sql_stmt             CHAR(500),
          where_clause         CHAR(300),
          p_msg                CHAR(100),
          p_ind                SMALLINT,
          p_prz_entrega        LIKE ped_itens.prz_entrega,
          p_qtd_cancel         LIKE ped_itens.qtd_pecas_solic,
          p_num_pedido_cli     LIKE pedidos.num_pedido_cli

   DEFINE p_ped_itens    RECORD LIKE ped_itens.*          
   
   DEFINE p_tela               RECORD
          num_pedido           LIKE pedidos.num_pedido,
          ies_sit_pedido       LIKE pedidos.ies_sit_pedido,
          cod_cliente          LIKE clientes.cod_cliente,
          nom_cliente          LIKE clientes.nom_cliente
   END RECORD

   DEFINE pr_itens     ARRAY[10000] OF RECORD 
          num_seq      LIKE ped_itens.num_sequencia,
          cod_item     LIKE ped_itens.cod_item,
          den_item     LIKE item.den_item_reduz,
          prz_entrega  LIKE ped_itens.prz_entrega,
          qtd_saldo    LIKE ped_itens.qtd_pecas_solic
   END RECORD

   DEFINE p_texto              RECORD
          den_texto_1          LIKE ped_itens_texto.den_texto_1,
          den_texto_2          LIKE ped_itens_texto.den_texto_2,
          den_texto_3          LIKE ped_itens_texto.den_texto_3,
          den_texto_4          LIKE ped_itens_texto.den_texto_4,
          den_texto_5          LIKE ped_itens_texto.den_texto_5
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10 
   DEFER INTERRUPT
   LET p_versao = "pol1067-10.02.08"
   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1067_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1067_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1067") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1067 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
      
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta pedido de vendas"
         CALL pol1067_consultar() RETURNING p_status
         IF p_status THEN
            ERROR "Operação efetuada c/ Sucesso !!!"
            LET p_ies_cons = TRUE   
         ELSE
            ERROR "Operação Cancelada !!!"
            LET p_ies_cons = FALSE   
         END IF      
      COMMAND "Modificar" "Modifica itens do pedido"
         IF p_ies_cons THEN
            CALL pol1067_modificar() RETURNING p_status
            IF p_status THEN
               ERROR "Operação efetuada c/ Sucesso !!!"
            ELSE
               ERROR "Operação Cancelada !!!"
            END IF      
         ELSE
            ERROR "Efetue a consulta previamente!!!"
            NEXT OPTION "Informar"
         END IF
      COMMAND "Incluir" "Inclui item no pedido"
         IF p_ies_cons THEN
            CALL pol1067_incluir() RETURNING p_status
            IF p_status THEN
               ERROR "Operação efetuada c/ Sucesso !!!"
            ELSE
               ERROR "Operação Cancelada !!!"
            END IF      
         ELSE
            ERROR "Efetue a consulta previamente!!!"
            NEXT OPTION "Informar"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0482_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1067

END FUNCTION

#-----------------------#
 FUNCTION pol0482_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1067_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#---------------------------#
FUNCTION pol1067_consultar()
#---------------------------#

   CALL pol1067_limpa_tela()
   INITIALIZE p_tela TO NULL
   LET INT_FLAG = FALSE

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS
        
      AFTER FIELD num_pedido

         IF p_tela.num_pedido IS NULL THEN
            ERROR "Campo com Preenchimento Obrigatório !!!"
            NEXT FIELD num_pedido
         END IF
         
         IF NOT pol1067_le_pedido() THEN
            NEXT FIELD num_pedido
         END IF
         
         DISPLAY BY NAME p_tela.*
         DISPLAY p_den_cidade TO den_cidade
         DISPLAY p_cod_uni_feder TO cod_uni_feder
            
   END INPUT

   IF INT_FLAG THEN
      CALL pol1067_limpa_tela()
      RETURN FALSE
   END IF

   IF NOT pol1067_carrega_itens() THEN
      RETURN FALSE
   END IF
   
   CALL pol1067_exibe_itens()
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1067_exibe_itens()
#-----------------------------#

   CURRENT WINDOW IS w_pol1067
   
   INPUT ARRAY pr_itens 
      WITHOUT DEFAULTS FROM sr_itens.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION

#---------------------------#
FUNCTION pol1067_le_pedido()
#---------------------------#

   SELECT cod_cliente,
          ies_sit_pedido,
          num_pedido_cli
     INTO p_tela.cod_cliente,
          p_tela.ies_sit_pedido,
          p_num_pedido_cli
     FROM pedidos
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_tela.num_pedido
    
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','Pedido')
      RETURN FALSE
   END IF
       
   IF STATUS = 100 THEN
      ERROR 'Pedido inexistente!'
      RETURN FALSE
   ELSE   
      IF p_tela.ies_sit_pedido = '9' THEN
         ERROR 'Pedido cancelado!'
         RETURN FALSE
      END IF
   END IF
   
   SELECT nom_cliente,
          cod_cidade
     INTO p_tela.nom_cliente,
          p_cod_cidade
     FROM clientes
    WHERE cod_cliente = p_tela.cod_cliente
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','Clientes')
      RETURN FALSE
   END IF
   
   SELECT den_cidade,
          cod_uni_feder
     INTO p_den_cidade,
          p_cod_uni_feder
     FROM cidades
    WHERE cod_cidade = p_cod_cidade
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cidades')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1067_carrega_itens()
#------------------------------#

   INITIALIZE pr_itens TO NULL
      
   LET p_index = 1
   
   DECLARE cq_it CURSOR FOR
    SELECT num_sequencia,
           cod_item,
           prz_entrega,
           (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio)
      FROM ped_itens
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_tela.num_pedido
     ORDER BY prz_entrega
   
   FOREACH cq_it INTO
           pr_itens[p_index].num_seq,
           pr_itens[p_index].cod_item,
           pr_itens[p_index].prz_entrega,
           pr_itens[p_index].qtd_saldo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ped_itens')
         RETURN FALSE
      END IF
          
      IF pr_itens[p_index].qtd_saldo <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      SELECT den_item_reduz
        INTO pr_itens[p_index].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = pr_itens[p_index].cod_item

      IF STATUS <> 0 THEN
         LET pr_itens[p_index].den_item = 'ERRO LENDO ITEM'
      END IF
      
      LET p_index = p_index + 1
      
   END FOREACH      

   IF p_index = 1 THEN
      LET p_sem_saldo = TRUE
   ELSE
      LET p_sem_saldo = FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1067_modificar()
#---------------------------#

   IF p_sem_saldo THEN
      LET p_msg = 'Pedido sem saldo!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_itens
      WITHOUT DEFAULTS FROM sr_itens.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD prz_entrega
      
         IF pr_itens[p_index].prz_entrega IS NULL THEN
            ERROR 'Informe uma data maior ou igual a data atual'
            NEXT FIELD prz_entrega
         END IF

      AFTER FIELD qtd_saldo
      
         IF pr_itens[p_index].qtd_saldo IS NULL OR
            pr_itens[p_index].qtd_saldo < 0 THEN
            ERROR 'O saldo deve ser maior ou igual a zero !!!'
            NEXT FIELD qtd_saldo
         END IF
         
      AFTER ROW
         
         IF NOT INT_FLAG THEN
            IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN 
            ELSE
               IF pr_itens[p_index+1].num_seq IS NULL THEN
                  NEXT FIELD prz_entrega
               END IF
            END IF
         END IF   
      
      ON KEY (control-t)
      	 CALL pol1067_edita_txto()
         
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1067_carrega_itens() RETURNING p_status
      CALL pol1067_exibe_itens()
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1067_atualiza_itens() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1067_atualiza_itens()
#--------------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
      IF pr_itens[p_ind].num_seq IS NOT NULL THEN
         
         SELECT prz_entrega,
                qtd_pecas_solic,
                qtd_pecas_cancel,
                (qtd_pecas_solic  -
                 qtd_pecas_atend  -
                 qtd_pecas_cancel - qtd_pecas_romaneio)
           INTO p_prz_entrega,
                p_qtd_solic,
                p_qtd_cancel,
                p_qtd_saldo
           FROM ped_itens
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_tela.num_pedido
            AND num_sequencia = pr_itens[p_ind].num_seq
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ped_itens')
            RETURN FALSE
         END IF
         
         IF p_prz_entrega <> pr_itens[p_ind].prz_entrega   OR
            p_qtd_saldo <> pr_itens[p_ind].qtd_saldo THEN
            
            IF p_qtd_saldo > pr_itens[p_ind].qtd_saldo THEN
               LET p_qtd_dif = p_qtd_saldo - pr_itens[p_ind].qtd_saldo
               LET p_qtd_cancel = p_qtd_cancel + p_qtd_dif
            END IF
            
            IF p_qtd_saldo < pr_itens[p_ind].qtd_saldo THEN
               LET p_qtd_dif = pr_itens[p_ind].qtd_saldo - p_qtd_saldo
               LET p_qtd_solic = p_qtd_solic + p_qtd_dif
            END IF
            
            UPDATE ped_itens
               SET prz_entrega      = pr_itens[p_ind].prz_entrega,
                   qtd_pecas_solic  = p_qtd_solic,
                   qtd_pecas_cancel = p_qtd_cancel
             WHERE cod_empresa   = p_cod_empresa
               AND num_pedido    = p_tela.num_pedido
               AND num_sequencia = pr_itens[p_ind].num_seq
         
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Atualizando','ped_itens')
               RETURN FALSE
            END IF
         
            LET p_msg = 'Alteracao da sequencia: ',pr_itens[p_ind].num_seq
            LET p_msg = p_msg CLIPPED, ' do pedido: ',p_tela.num_pedido
         
            IF NOT pol1067_insere_audit('A') THEN
               RETURN FALSE
            END IF
        
        END IF
         
      END IF
   END FOR
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1067_insere_audit(p_tip)
#----------------------------------#

   DEFINE p_audit_vdp RECORD LIKE audit_vdp.*
   DEFINE p_tip       CHAR(01)
   
   LET p_audit_vdp.cod_empresa      = p_cod_empresa
   LET p_audit_vdp.num_pedido       = p_tela.num_pedido
   LET p_audit_vdp.tipo_informacao  = 'M'
   LET p_audit_vdp.tipo_movto       = p_tip
   LET p_audit_vdp.texto            = p_msg
   LET p_audit_vdp.num_programa     = 'POL1067'
   LET p_audit_vdp.data             = TODAY
   LET p_audit_vdp.hora             = TIME
   LET p_audit_vdp.usuario          = p_user
   LET p_audit_vdp.num_transacao    = 0
   
   INSERT INTO audit_vdp
     VALUES(p_audit_vdp.*)
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_vdp')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1067_edita_txto()
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol10671") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol10671 AT 9,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY pr_itens[p_index].num_seq  TO num_seq
   DISPLAY pr_itens[p_index].cod_item TO cod_item
   DISPLAY pr_itens[p_index].den_item TO den_item_reduz

   SELECT den_texto_1,
          den_texto_2,
          den_texto_3,
          den_texto_4,
          den_texto_5
     INTO p_texto.den_texto_1,
          p_texto.den_texto_2,
          p_texto.den_texto_3,
          p_texto.den_texto_4,
          p_texto.den_texto_5 
     FROM ped_itens_texto
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_tela.num_pedido
      AND num_sequencia = pr_itens[p_index].num_seq

   IF STATUS = 100 THEN
      INITIALIZE p_texto TO NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ped_itens_texto')
         CLOSE WINDOW w_pol10671
         RETURN
      END IF
   END IF
         
   LET INT_FLAG = FALSE
      
   INPUT BY NAME p_texto.*
      WITHOUT DEFAULTS
        
      AFTER FIELD den_texto_1
   
   END INPUT
   
   IF NOT INT_FLAG THEN
      CALL pol1067_grava_txt()
   END IF
   
   CLOSE WINDOW w_pol10671
   
END FUNCTION

#---------------------------#
FUNCTION pol1067_grava_txt()
#---------------------------#

   UPDATE ped_itens_texto
      SET den_texto_1 = p_texto.den_texto_1,
          den_texto_2 = p_texto.den_texto_2,
          den_texto_3 = p_texto.den_texto_3,
          den_texto_4 = p_texto.den_texto_4,
          den_texto_5 = p_texto.den_texto_5 
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_tela.num_pedido
      AND num_sequencia = pr_itens[p_index].num_seq

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','ped_itens_texto')
   END IF

END FUNCTION

#-------------------------#
FUNCTION pol1067_incluir()
#-------------------------#

   DEFINE p_num_seq INTEGER
   
   SELECT MIN(num_sequencia)
     INTO p_num_seq
     FROM ped_itens
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_tela.num_pedido
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ped_itens')
      RETURN FALSE
   END IF

   SELECT *
     INTO p_ped_itens.*
     FROM ped_itens
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_tela.num_pedido
      AND num_sequencia = p_num_seq
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ped_itens')
      RETURN FALSE
   END IF

   SELECT COUNT(cod_item)
     INTO p_count
     FROM ped_itens
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_tela.num_pedido
      AND cod_item      <> p_ped_itens.cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ped_itens')
      RETURN FALSE
   END IF

   IF p_count > 0 THEN
      LET p_msg = "Inclusão de novo item não permitida,\n",
                  "pois, o pedido contém itens diferentes"
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF
   
   SELECT MAX(num_sequencia)
     INTO p_num_seq
     FROM ped_itens
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_tela.num_pedido
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ped_itens')
      RETURN FALSE
   END IF

   SELECT den_item_reduz
     INTO p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_ped_itens.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF
    
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol10672") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol10672 AT 5,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   LET p_ped_itens.num_sequencia = p_num_seq + 1
   LET p_ped_itens.qtd_pecas_solic  = NULL
   LET p_ped_itens.qtd_pecas_atend  = 0
   LET p_ped_itens.qtd_pecas_cancel = 0
   LET p_ped_itens.qtd_pecas_reserv = 0
   LET p_ped_itens.qtd_pecas_romaneio = 0
   LET p_ped_itens.prz_entrega = TODAY
   
   INITIALIZE p_texto TO NULL
   
   LET p_texto.den_texto_1 = 'PV: ', p_tela.num_pedido USING '&&&&&&', ' ',
                             'OC: ', p_num_pedido_cli
     
   LET INT_FLAG = FALSE

   DISPLAY p_den_item_reduz TO den_item_reduz
   
   INPUT p_ped_itens.cod_empresa,      
         p_ped_itens.num_pedido,       
         p_ped_itens.num_sequencia,    
         p_ped_itens.cod_item,         
         p_ped_itens.pct_desc_adic,    
         p_ped_itens.pre_unit,         
         p_ped_itens.qtd_pecas_solic,  
         p_ped_itens.prz_entrega,      
         p_ped_itens.val_desc_com_unit,
         p_ped_itens.val_frete_unit,   
         p_ped_itens.val_seguro_unit,  
         p_ped_itens.pct_desc_bruto,
         p_texto.den_texto_1,
         p_texto.den_texto_2,
         p_texto.den_texto_3,
         p_texto.den_texto_4,
         p_texto.den_texto_5
      WITHOUT DEFAULTS FROM
         cod_empresa,      
         num_pedido,       
         num_sequencia,    
         cod_item,         
         pct_desc_adic,    
         pre_unit,         
         qtd_pecas_solic,  
         prz_entrega,      
         val_desc_com_unit,
         val_frete_unit,   
         val_seguro_unit,  
         pct_desc_bruto,   
         den_texto_1,
         den_texto_2,
         den_texto_3,
         den_texto_4,
         den_texto_5
         
      AFTER FIELD qtd_pecas_solic
      
         IF p_ped_itens.qtd_pecas_solic IS NULL OR 
            p_ped_itens.qtd_pecas_solic < 0 THEN
            ERROR 'Informe um valor maior que zero!'
            NEXT FIELD qtd_pecas_solic
         END IF

      AFTER FIELD prz_entrega
      
         IF p_ped_itens.prz_entrega IS NULL OR 
            p_ped_itens.prz_entrega < TODAY THEN
            ERROR 'Informe uma data maior ou igual a data atual!'
            NEXT FIELD prz_entrega
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      CLOSE WINDOW w_pol10672
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1067_insere_item() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")

   CLOSE WINDOW w_pol10672      

   CALL pol1067_carrega_itens() RETURNING p_status
   CALL pol1067_exibe_itens()

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1067_insere_item()
#-----------------------------#

   INSERT INTO ped_itens
     VALUES(p_ped_itens.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ped_itens')
      RETURN FALSE
   END IF

   IF p_texto.den_texto_1 IS NOT NULL OR
      p_texto.den_texto_2 IS NOT NULL OR
      p_texto.den_texto_3 IS NOT NULL OR
      p_texto.den_texto_4 IS NOT NULL OR
      p_texto.den_texto_5 IS NOT NULL THEN
      
      INSERT INTO ped_itens_texto
        VALUES(p_cod_empresa,
               p_tela.num_pedido,
               p_ped_itens.num_sequencia,
               p_texto.den_texto_1,
               p_texto.den_texto_2,
               p_texto.den_texto_3,
               p_texto.den_texto_4,
               p_texto.den_texto_5)
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','ped_itens_texto')
         RETURN FALSE
      END IF
      
   END IF

   LET p_msg = 'inclusao da sequencia: ',p_ped_itens.num_sequencia 
   LET p_msg = p_msg CLIPPED, ' no pedido: ',p_tela.num_pedido
         
   IF NOT pol1067_insere_audit('I') THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------FIM DO PROGAMA------------#


  