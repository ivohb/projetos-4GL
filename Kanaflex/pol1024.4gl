#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol1024                                                 #
# OBJETIVO: COMISSÃO POR ITEM DO PEDIDO                             #
# AUTOR...: WILLIANS                                                #
# DATA....: 17/03/2010                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_consistido         SMALLINT,
          p_val_total          DECIMAL(11,2),
          p_qtd_solic          DECIMAL(10,2),
          p_opcao              CHAR(01),
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
          p_dat_txt            CHAR(10),
          p_dat_inv            CHAR(10),
          p_tot_ger            DECIMAL(13,2),
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          sql_stmt             CHAR(500), 
          where_clause         CHAR(500),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_cod_item           CHAR(15),
          p_hoje               DATE
            
   DEFINE p_pct_comis_meta_444 RECORD LIKE pct_comis_meta_444.*          
   
   DEFINE p_num_pedido         LIKE pedidos.num_pedido,
          p_num_pedido_ant     LIKE pedidos.num_pedido
   
   DEFINE p_tela               RECORD
          cod_empresa          LIKE empresa.cod_empresa,
          num_pedido           LIKE pedidos.num_pedido,
          cod_tip_carteira     LIKE tipo_carteira.cod_tip_carteira,
          den_tip_carteira     LIKE tipo_carteira.den_tip_carteira,
          cod_repres           LIKE representante.cod_repres,
          raz_social           LIKE representante.raz_social,
          cod_cliente          LIKE clientes.cod_cliente,
          nom_cliente          LIKE clientes.nom_reduzido
   END RECORD

   DEFINE pr_itens             ARRAY[300] OF RECORD 
          num_seq_item         LIKE ped_itens.num_sequencia,
          cod_item             LIKE ped_itens.cod_item,
          den_item             LIKE item.den_item_reduz,
          pct_comis_orig       LIKE pct_comis_meta_444.pct_comis_orig,
          pct_comis_meta       LIKE pct_comis_meta_444.pct_comis_meta
   END RECORD
   
   DEFINE p_relat              RECORD
          num_pedido           LIKE pedidos.num_pedido,
          num_seq_item         LIKE ped_itens.num_sequencia,
          cod_item             LIKE ped_itens.cod_item,
          pct_comis_orig       LIKE pct_comis_meta_444.pct_comis_orig,
          pct_comis_meta       LIKE pct_comis_meta_444.pct_comis_meta
   END RECORD       
         
   DEFINE p_cod_tip_carteira   LIKE tipo_carteira.cod_tip_carteira,
          p_den_tip_carteira   LIKE tipo_carteira.den_tip_carteira,
          p_ies_sit_pedido     LIKE pedidos.ies_sit_pedido,
          p_cod_repres         LIKE representante.cod_repres,
          p_raz_social         LIKE representante.raz_social,
          p_pct_acres_norm     DECIMAL(5,2),
          p_pct_acres_novo     DECIMAL(5,2),
          p_pct_acres          LIKE par_comis_444.comis_acres_novo
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol1024-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1024.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol1024_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1024_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1024") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1024 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1024_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         LET p_opcao = "I"
         CALL pol1024_incluir() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = FALSE
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
         IF pol1024_consulta() THEN
            LET p_ies_cons = TRUE
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'Consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1024_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1024_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            LET p_opcao = "M"
            CALL pol1024_modificar() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_num_pedido TO num_pedido
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol1024_excluir() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem"
         CALL pol1024_listagem()   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1024_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1024

END FUNCTION

#-----------------------------#
 FUNCTION pol1024_limpa_tela()
#-----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 

#-------------------------#
 FUNCTION pol1024_incluir()
#-------------------------#
   
   CALL pol1024_limpa_tela()
   
   IF pol1024_aceita_chave() THEN      # CONSISTÊNCIA DO PEDIDO
      IF pol1024_aceita_itens() THEN   # CARREGA O VETOR: (pr_itens) Com os campos: (num_seq_item, cod_item, den_item, pct_comis_orig)   
         IF pol1024_grava_itens() THEN # GRAVA DADOS CARREGADOS NA TABELA: (pct_comis_meta_444)                                                    
            RETURN TRUE                                                                    
         END IF                                                                      
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#---------------------------#
 FUNCTION pol1024_modificar()
#---------------------------#

   LET p_tela.num_pedido = p_num_pedido  
   
   IF pol1024_aceita_itens() THEN   # MODIFICA O VETOR JÁ CARREGADO NA CONSULTA          
      IF pol1024_grava_itens() THEN # GRAVA DADOS CARREGADOS NA TABELA: (pct_comis_meta_444)       
         #CALL pol1024_exibe_dados() RETURNING p_status 
         RETURN TRUE
      END IF
   END IF

   LET p_num_pedido = p_tela.num_pedido
   CALL pol1024_exibe_dados() RETURNING p_status

   RETURN FALSE
   
END FUNCTION

#------------------------------#
 FUNCTION pol1024_aceita_chave()
#------------------------------#
   
   LET INT_FLAG = FALSE 
   INITIALIZE p_tela.* TO NULL
   LET p_tela.cod_empresa = p_cod_empresa 
   
   INPUT BY NAME p_tela.* 
      WITHOUT DEFAULTS  

#------------------- CONSISTINDO O PEDIDO -------------------"

      AFTER FIELD num_pedido
         
         LET p_consistido = TRUE
         
         # VERIFICA SE O CAMPO FOI PRENCHIDO CORRETAMENTE
         
         IF p_tela.num_pedido IS NULL THEN 
            ERROR "Campo com prenchimento obrigatório !!!"
            NEXT FIELD num_pedido
         END IF 
         
         # VERIFICA SE O PEDIDO EXISTE NA TABELA (pedidos) OU NA TABELA (pedido_dig_mest)
            
         SELECT cod_cliente,
                cod_tip_carteira,
                ies_sit_pedido,
                cod_repres
           INTO p_tela.cod_cliente,
                p_cod_tip_carteira,
                p_ies_sit_pedido,
                p_cod_repres
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_tela.num_pedido
            
         IF STATUS = 100 THEN 
            
            SELECT cod_cliente,
                   cod_tip_carteira,
                   ies_sit_pedido,
                   cod_repres
              INTO p_tela.cod_cliente,
                   p_cod_tip_carteira,
                   p_ies_sit_pedido,
                   p_cod_repres
              FROM pedido_dig_mest
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido  = p_tela.num_pedido
               
            IF STATUS = 100 THEN 
               ERROR 'Pedido Inexistente !!!'
               NEXT FIELD num_pedido
            ELSE
               IF STATUS <> 0 THEN 
                  CALL log003_err_sql("Lendo","pedido_dig_mest")
                  RETURN FALSE 
               END IF 
            END IF   
                  
            LET p_consistido = FALSE
         
         ELSE
         
            IF STATUS <> 0 THEN 
               CALL log003_err_sql("Lendo","pedidos")
               RETURN FALSE 
            END IF                  
               
         END IF
         
         # VERIFICA SE O PEDIDO JÁ FOI CANCELADO
         
         IF p_ies_sit_pedido = '9' THEN 
            ERROR "Esse pedido já foi cancelado !!!"
            NEXT FIELD num_pedido
         END IF 
         
         # VERIFICA SE O PEDIDO CONTEM UM LANÇAMENTO DE COMISSÃO
         
         SELECT COUNT(num_pedido)
           INTO p_count
           FROM pct_comis_meta_444
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_tela.num_pedido
         
         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Lendo","pct_comis_meta_444")
            RETURN FALSE 
         END IF
         
         IF p_count > 0 THEN
            ERROR 'O pedido já contem um lançamento de comissão !!!'
            NEXT FIELD num_pedido
         END IF
         
         # BUSCA PARÂMETROS DA COMISSÃO ATRAVÉS DA CARTEIRA

         CALL pol1024_le_param()
                        
         IF STATUS = 100 THEN 
            ERROR 'Parâmetros de comissão não cadastrados p/ a carteira: (',p_cod_tip_carteira, ') !!!'
            NEXT FIELD num_pedido
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql("Lendo","par_comis_444")
               RETURN FALSE
            END IF 
         END IF 
                  
         # BUSCA A DESCRIÇÃO DO CLIENTE
         
         SELECT nom_reduzido
           INTO p_tela.nom_cliente
           FROM clientes
          WHERE cod_cliente = p_tela.cod_cliente
          
          IF STATUS <> 0 THEN 
             CALL log003_err_sql("Lendo","clientes")
             NEXT FIELD num_pedido
          END IF
             
          # BUSCA A DESCRIÇÃO DA CARTEIRA
          
          SELECT den_tip_carteira
            INTO p_den_tip_carteira
            FROM tipo_carteira
           WHERE cod_tip_carteira = p_cod_tip_carteira
           
          IF STATUS <> 0 THEN 
             CALL log003_err_sql("Lendo","tipo_carteira")
             NEXT FIELD num_pedido
          END IF 
          
          # BUSCA A DESCRIÇÃO DO REPRESENTANTE
          
          SELECT raz_social
            INTO p_raz_social
            FROM representante
           WHERE cod_repres = p_cod_repres
          
          IF STATUS <> 0 THEN 
             CALL log003_err_sql("Lendo","representante")
             NEXT FIELD num_pedido
          END IF 
          
          # MOSTRA OS DADOS CARREGADOS
          
          DISPLAY p_tela.cod_cliente TO cod_cliente
          DISPLAY p_tela.nom_cliente TO nom_cliente
          DISPLAY p_cod_tip_carteira TO cod_tip_carteira
          DISPLAY p_den_tip_carteira TO den_tip_carteira
          DISPLAY p_cod_repres       TO cod_repres
          DISPLAY p_raz_social       TO raz_social
          
   END INPUT 

   IF INT_FLAG = FALSE THEN
      RETURN TRUE
   ELSE
      CALL pol1024_limpa_tela()
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF

END FUNCTION 

#--------------------------#
FUNCTION pol1024_le_param()
#--------------------------#

   SELECT comis_prod_normal,                     
          comis_prod_novo                              
     INTO p_pct_acres_norm,                            
          p_pct_acres_novo                             
     FROM par_comis_444                                
    WHERE cod_empresa      = p_cod_empresa             
      AND cod_tip_carteira = p_cod_tip_carteira        
                                                 
END FUNCTION

#------------------------------#
 FUNCTION pol1024_aceita_itens()
#------------------------------#   
   
   IF p_opcao = 'I' THEN
      INITIALIZE pr_itens TO NULL
      IF NOT pol1024_carrega_ped_itens() THEN # CARREGA O VETOR: (pr_itens)
         RETURN FALSE
      END IF 
   END IF
     
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_itens
      WITHOUT DEFAULTS FROM sr_itens.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

#------------- CONSISTINDO A PORCENTAGEM DE COMISSÃO -------------#
     
      AFTER FIELD pct_comis_orig
          
         IF pr_itens[p_index].pct_comis_orig IS NULL  AND 
            pr_itens[p_index].num_seq_item   IS NOT NULL THEN
            ERROR 'O valor da comissão não pode ser nulo !!!'
            NEXT FIELD pct_comis_orig
         END IF   

         # VERIFICA SE O ITEM EM QUESTÃO É CONSIDERADO: "NOVO" OU "VELHO" 
         
         IF NOT pol1024_le_pct_acres() THEN 
            RETURN FALSE 
         END IF    
         
         IF pr_itens[p_index].pct_comis_orig > p_pct_acres OR
            pr_itens[p_index].pct_comis_orig < 0           THEN 
            ERROR "Porcentagem inválida segundo os parâmetros de comissão da carteira (", p_cod_tip_carteira, ") !!!" 
            NEXT FIELD pct_comis_orig
         END IF 
 
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_itens[p_index+1].cod_item IS NULL THEN
               ERROR 'Não há mais itens nessa direção'
               NEXT FIELD pct_comis_orig
            END IF
         END IF
        
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF   
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1024_carrega_ped_itens()
#-----------------------------------#

   IF p_consistido THEN # VARIÁVEL QUE CONTÉM A ORIGEM DO PEDIDO CARREGADO  
      # PEDIDO ORIGINADO DA TABELA: (pedidos)
      LET sql_stmt = 
          " SELECT a.num_sequencia, a.cod_item, b.den_item_reduz ",
          " FROM ped_itens a, item b ",
          " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
          "   AND a.num_pedido    = '",p_tela.num_pedido,"' ",
          "   AND b.cod_empresa   = a.cod_empresa ",
          "   AND b.cod_item      = a.cod_item "
   ELSE                  
      # PEDIDO ORIGINADO DA TABELA: (pedido_dig_mest)
      LET sql_stmt = 
          " SELECT a.num_sequencia, a.cod_item, b.den_item_reduz ",
          "   FROM pedido_dig_item a, item b ",
          "  WHERE a.cod_empresa = '",p_cod_empresa,"' ",
          "    AND a.num_pedido    = '",p_tela.num_pedido,"' ",
          "    AND b.cod_empresa   = a.cod_empresa ",
          "    AND b.cod_item      = a.cod_item "
   END IF   
   
   PREPARE var_query FROM sql_stmt   
   DECLARE cq_ped_itens CURSOR FOR var_query
   
   LET p_index = 1
   
   FOREACH cq_ped_itens 
      INTO pr_itens[p_index].num_seq_item,
           pr_itens[p_index].cod_item,
           pr_itens[p_index].den_item
      
      LET pr_itens[p_index].pct_comis_orig = 0
      LET pr_itens[p_index].pct_comis_meta = NULL 
      
      LET p_index = p_index + 1

      IF p_index > 300 THEN
         ERROR "Limite de grades ultrapassado !!!"
         EXIT FOREACH
      END IF

   END FOREACH
   
   RETURN TRUE 
   
END FUNCTION

#------------------------------#
 FUNCTION pol1024_le_pct_acres()
#------------------------------#

   DEFINE p_cod_familia    LIKE item.cod_familia
   
   SELECT cod_familia
     INTO p_cod_familia
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = pr_itens[p_index].cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF
   
   LET p_hoje = TODAY
   
   SELECT COUNT(cod_familia)
     INTO p_count
     FROM kana_novos_produtos_familias
    WHERE cod_familia   = p_cod_familia
      AND data_inicio  <= p_hoje
      AND data_termino >= p_hoje
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','kana_novos_produtos_familias')
      RETURN FALSE
   END IF

   IF p_count = 0 THEN
      LET p_pct_acres = p_pct_acres_norm
      RETURN TRUE
   END IF
   
   SELECT COUNT(cod_item)
     INTO p_count
     FROM kana_novos_produtos_itens_retira
    WHERE cod_item = pr_itens[p_index].cod_item
      AND data_inicio  <= p_hoje
      AND data_termino >= p_hoje
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','kana_novos_produtos_itens_retira')
      RETURN FALSE
   END IF

   IF p_count = 0 THEN
      LET p_pct_acres = p_pct_acres_novo
   ELSE
      LET p_pct_acres = p_pct_acres_norm
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1024_grava_itens()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 
   
   CALL log085_transacao("BEGIN")

   WHENEVER ERROR CONTINUE
   IF p_opcao = 'M' THEN
      IF NOT pol1024_deleta() THEN     # DELETA O PEDIDO DA TABELA: (pct_comis_meta_444)
         RETURN FALSE
      END IF
   END IF
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_itens[p_ind].num_seq_item IS NOT NULL THEN
          
		       INSERT INTO pct_comis_meta_444
		       VALUES (p_cod_empresa,
		               p_tela.num_pedido,
		               pr_itens[p_ind].num_seq_item,
		               p_cod_repres,
		               pr_itens[p_ind].cod_item,
		               pr_itens[p_ind].pct_comis_orig,
		               pr_itens[p_ind].pct_comis_meta)
		
		       IF STATUS <> 0 THEN 
		          MESSAGE "Erro na inclusão" ATTRIBUTE(REVERSE)
		          CALL log003_err_sql("GRAVAÇÃO","pct_comis_meta_444")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
       END IF
   END FOR
         
   CALL log085_transacao("COMMIT")	      
   
   RETURN TRUE
      
END FUNCTION

#---------------------------------------#
FUNCTION pol1024_checa_compatibilidade()
#---------------------------------------#

   CALL log085_transacao("BEGIN")
   
   IF p_consistido THEN 
      IF NOT pol1024_compat_ped_itens() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1024_compat_pedido_dig_item() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1024_compat_ped_itens()
#----------------------------------#
   
   DELETE FROM pct_comis_meta_444                                        
    WHERE cod_empresa = p_cod_empresa                                       
      AND num_pedido  = p_num_pedido                                        
      AND num_seq_item NOT IN                                               
          (SELECT num_sequencia FROM ped_itens                              
            WHERE cod_empresa = p_cod_empresa                               
              AND num_pedido  = p_num_pedido)                               

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Atualizando","pct_comis_meta_444:delete")
      RETURN FALSE
   END IF
                                                                         
   INSERT INTO pct_comis_meta_444                                           
    SELECT a.cod_empresa,                                                   
           a.num_pedido,                                                    
           a.num_sequencia,                                                 
           b.cod_repres,                                                    
           a.cod_item, 0, ''                                                
      FROM ped_itens a, pedidos b                                           
     WHERE a.cod_empresa = p_cod_empresa                                    
       AND a.num_pedido  = p_num_pedido                                     
       AND a.num_sequencia NOT IN                                           
          (SELECT num_seq_item FROM pct_comis_meta_444                      
            WHERE cod_empresa = p_cod_empresa                               
              AND num_pedido  = p_num_pedido)                               
       AND b.cod_empresa = a.cod_empresa                                    
       AND b.num_pedido  = a.num_pedido                                     

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Atualizando","pct_comis_meta_444:insert")
      RETURN FALSE
   END IF

   LET p_msg = ""
   
   DECLARE cq_alerta CURSOR FOR
    SELECT b.cod_item
      FROM pct_comis_meta_444 a, ped_itens b
     WHERE a.cod_empresa = '01'
       AND a.num_pedido  = 50169
       AND a.num_pedido  = b.num_pedido
       AND a.num_seq_item = b.num_sequencia
       AND a.cod_item     <> b.cod_item

   FOREACH cq_alerta INTO p_cod_item

      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo","pct_comis_meta_444/ped_itens")
         RETURN FALSE
      END IF
      
      IF p_msg IS NULL THEN
         LET p_msg = p_cod_item
      ELSE
         LET p_msg = p_msg CLIPPED, "/", p_cod_item
      END IF
   
   END FOREACH 
   
   IF p_msg IS NOT NULL THEN
      LET p_msg = p_msg CLIPPED, " : ", "ITEN(S) TROCADO(S) NO PEDIDO"
      CALL log0030_mensagem(p_msg,'excla')
   END IF
             
   UPDATE pct_comis_meta_444
      SET pct_comis_meta_444.cod_item =
         (SELECT ped_itens.cod_item
            FROM ped_itens
           WHERE ped_itens.cod_empresa   = pct_comis_meta_444.cod_empresa
             AND ped_itens.num_pedido    = pct_comis_meta_444.num_pedido
             AND ped_itens.num_sequencia = pct_comis_meta_444.num_seq_item)
    WHERE pct_comis_meta_444.cod_empresa = p_cod_empresa
      AND pct_comis_meta_444.num_pedido  = p_num_pedido

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Atualizando","pct_comis_meta_444:update")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1024_compat_pedido_dig_item()
#---------------------------------------#

   DELETE FROM pct_comis_meta_444                                        
    WHERE cod_empresa = p_cod_empresa                                       
      AND num_pedido  = p_num_pedido                                        
      AND num_seq_item NOT IN                                               
          (SELECT num_sequencia FROM pedido_dig_item                              
            WHERE cod_empresa = p_cod_empresa                               
              AND num_pedido  = p_num_pedido)                               

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Atualizando","pct_comis_meta_444-delete")
      RETURN FALSE
   END IF
                                                                         
   INSERT INTO pct_comis_meta_444                                           
    SELECT a.cod_empresa,                                                   
           a.num_pedido,                                                    
           a.num_sequencia,                                                 
           b.cod_repres,                                                    
           a.cod_item, 0, ''                                                
      FROM pedido_dig_item a, pedido_dig_mest b                                           
     WHERE a.cod_empresa = p_cod_empresa                                    
       AND a.num_pedido  = p_num_pedido                                     
       AND a.num_sequencia NOT IN                                           
          (SELECT num_seq_item FROM pct_comis_meta_444                      
            WHERE cod_empresa = p_cod_empresa                               
              AND num_pedido  = p_num_pedido)                               
       AND b.cod_empresa = a.cod_empresa                                    
       AND b.num_pedido  = a.num_pedido                                     

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Atualizando","pct_comis_meta_444-insert")
      RETURN FALSE
   END IF

   LET p_msg = ""
   
   DECLARE cq_alerta2 CURSOR FOR
    SELECT b.cod_item
      FROM pct_comis_meta_444 a, pedido_dig_item b
     WHERE a.cod_empresa = '01'
       AND a.num_pedido  = 50169
       AND a.num_pedido  = b.num_pedido
       AND a.num_seq_item = b.num_sequencia
       AND a.cod_item     <> b.cod_item

   FOREACH cq_alerta2 INTO p_cod_item

      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo","pct_comis_meta_444/ped_itens")
         RETURN FALSE
      END IF
      
      IF p_msg IS NULL THEN
         LET p_msg = p_cod_item
      ELSE
         LET p_msg = p_msg CLIPPED, "/", p_cod_item
      END IF
   
   END FOREACH 
   
   IF p_msg IS NOT NULL THEN
      LET p_msg = p_msg CLIPPED, " : ", "ITEN(S) TROCADO(S) NO PEDIDO"
      CALL log0030_mensagem(p_msg,'excla')
   END IF
   
   UPDATE pct_comis_meta_444
      SET pct_comis_meta_444.cod_item =
         (SELECT pedido_dig_item.cod_item
            FROM pedido_dig_item
           WHERE pedido_dig_item.cod_empresa   = pct_comis_meta_444.cod_empresa
             AND pedido_dig_item.num_pedido    = pct_comis_meta_444.num_pedido
             AND pedido_dig_item.num_sequencia = pct_comis_meta_444.num_seq_item)
    WHERE pct_comis_meta_444.cod_empresa = p_cod_empresa
      AND pct_comis_meta_444.num_pedido  = p_num_pedido

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Atualizando","pct_comis_meta_444-update")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
 

#------------------------#
 FUNCTION pol1024_deleta()
#------------------------#

   DELETE FROM pct_comis_meta_444
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_tela.num_pedido

   IF STATUS <> 0 THEN 
      MESSAGE "Erro na deleção" ATTRIBUTE(REVERSE)
      CALL log003_err_sql("DELEÇÃO","pct_comis_meta_444")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#--------------------------#
 FUNCTION pol1024_consulta()
#--------------------------#
      
   CALL pol1024_limpa_tela()
   
   LET p_num_pedido_ant = p_num_pedido
   LET INT_FLAG         = FALSE
      
   CONSTRUCT BY NAME where_clause ON 
      pct_comis_meta_444.num_pedido

   IF INT_FLAG THEN
      IF p_ies_cons THEN   
         LET p_num_pedido = p_num_pedido_ant
         CALL pol1024_exibe_dados() RETURNING p_status
      END IF 
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT num_pedido FROM pct_comis_meta_444 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY num_pedido"

   PREPARE var_query_2 FROM sql_stmt   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_query_2
   
   OPEN cq_consulta
   
   FETCH cq_consulta INTO p_num_pedido
   
   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1024_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE 
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1024_exibe_dados()
#-----------------------------#
      
   INITIALIZE pr_itens TO NULL

   # BUSCA O CLIENTE, A CARTEIRA E O REPRESENTANTE
   
   SELECT cod_cliente,
          cod_tip_carteira,
          cod_repres
     INTO p_tela.cod_cliente,
          p_cod_tip_carteira,
          p_cod_repres
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_num_pedido
      
   IF STATUS = 100 THEN 
      
      SELECT cod_cliente,
             cod_tip_carteira,
             cod_repres
        INTO p_tela.cod_cliente,
             p_cod_tip_carteira,
             p_cod_repres
        FROM pedido_dig_mest
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_num_pedido
         
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo", "pedido_dig_mest")
         RETURN FALSE  
      END IF
      
      LET p_consistido = FALSE #o pedido ainda está na pedido_dig_mest/pedido_dig_item
   ELSE
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo", "pedidos")
         RETURN FALSE  
      END IF
      
      LET p_consistido = TRUE #o pedido já está na pedidos/ped_itens
      
   END IF 

   #Compatibiliza as tabelas ped_itens e pct_comis_meta_444, pois
   #após a inclusão do pedio na mesma, a ped_itens pode ter sido alterada
   
   IF NOT pol1024_checa_compatibilidade() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol1024_carrega_itens() THEN  # CARREGA O VETOR (pr_itens)
      RETURN FALSE
   END IF  

   # BUSCA PARÂMETROS DA COMISSÃO ATRAVÉS DA CARTEIRA

   CALL pol1024_le_param()
         
   # BUSCA A DESCRIÇÃO DO CLIENTE
       
   SELECT nom_reduzido
     INTO p_tela.nom_cliente
     FROM clientes
    WHERE cod_cliente = p_tela.cod_cliente
          
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo","clientes")
      RETURN FALSE
   END IF
       
   # BUSCA A DESCRIÇÃO DA CARTEIRA
          
   SELECT den_tip_carteira
     INTO p_den_tip_carteira
     FROM tipo_carteira
    WHERE cod_tip_carteira = p_cod_tip_carteira
          
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo","tipo_carteira")
      RETURN FALSE
   END IF 
          
   # BUSCA A DESCRIÇÃO DO REPRESENTANTE
          
   SELECT raz_social
     INTO p_raz_social
     FROM representante
    WHERE cod_repres = p_cod_repres
         
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo","representante")
      RETURN FALSE
   END IF 
   
   # MOSTRA OS DADOS CARREGADOS
   
   DISPLAY p_num_pedido       TO num_pedido
   DISPLAY p_tela.cod_cliente TO cod_cliente
   DISPLAY p_tela.nom_cliente TO nom_cliente
   DISPLAY p_cod_tip_carteira TO cod_tip_carteira
   DISPLAY p_den_tip_carteira TO den_tip_carteira       
   DISPLAY p_cod_repres       TO cod_repres
   DISPLAY p_raz_social       TO raz_social
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_itens WITHOUT DEFAULTS FROM sr_itens.*
      BEFORE INPUT
      EXIT INPUT
   END INPUT
   
   RETURN TRUE 
   
 END FUNCTION

#-------------------------------#
 FUNCTION pol1024_carrega_itens()
#-------------------------------#

   LET p_index = 1
  
   DECLARE cq_itens CURSOR FOR 
   
   # CARREGA O VETOR (pr_itens)
   
   SELECT num_seq_item,      
          cod_item,      
          pct_comis_orig,
          pct_comis_meta
     FROM pct_comis_meta_444
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_num_pedido
    ORDER BY num_seq_item    
       
   FOREACH cq_itens 
      INTO pr_itens[p_index].num_seq_item,
           pr_itens[p_index].cod_item,
           pr_itens[p_index].pct_comis_orig,
           pr_itens[p_index].pct_comis_meta
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo","pct_comis_meta_444")
         RETURN FALSE
      END IF
      
      # BUSCA A DESCRIÇÃO DO ITEM
       
      SELECT den_item_reduz
        INTO pr_itens[p_index].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = pr_itens[p_index].cod_item
         
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo","item")
         RETURN FALSE
      END IF
      
      LET p_index    = p_index + 1

      IF p_index > 300 THEN
         EXIT FOREACH
      END IF

   END FOREACH
   
   RETURN TRUE 
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1024_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   IF p_ies_cons THEN
      
      LET p_num_pedido_ant = p_num_pedido
      
      WHILE TRUE
         CASE
            WHEN p_funcao = "S" FETCH NEXT cq_consulta INTO p_num_pedido
                            
            WHEN p_funcao = "A" FETCH PREVIOUS cq_consulta INTO p_num_pedido 
                            
         END CASE

         IF status = 100 THEN
            ERROR "Nao existem mais itens nesta direção !!!"
            LET p_num_pedido = p_num_pedido_ant 
            EXIT WHILE
         END IF

         IF p_num_pedido = p_num_pedido_ant THEN
            CONTINUE WHILE
         END IF 
         
         SELECT COUNT(num_pedido)
           INTO p_count
           FROM pct_comis_meta_444
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_num_pedido
         
         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Lendo", "pct_comis_meta_444")
            EXIT WHILE 
         END IF 
         
         IF p_count > 0 THEN
            CALL pol1024_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "Nao existe nenhuma consulta ativa !!!"
   END IF

END FUNCTION

#------------------------#
FUNCTION pol1024_excluir()
#------------------------#

  IF NOT log004_confirm(18,35) THEN
     RETURN FALSE
  END IF 
  
  LET p_tela.num_pedido = p_num_pedido
      
  CALL log085_transacao("BEGIN")
  
  IF pol1024_deleta() THEN
     CALL log085_transacao("COMMIT")
     CALL pol1024_limpa_tela()
     INITIALIZE p_tela.num_pedido TO NULL
     RETURN TRUE
  END IF
  
  RETURN FALSE
      
END FUNCTION

#--------------------------#
 FUNCTION pol1024_listagem()
#--------------------------#     

   IF NOT pol1024_escolhe_saida() THEN
   		RETURN 
   END IF
   
   IF NOT pol1024_le_empresa() THEN
      RETURN
   END IF 
      
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_imprime CURSOR FOR

   # BUSCA O CLIENTE, A CARTEIRA E O REPRESENTANTE
   
   SELECT num_pedido,     
          num_seq_item,    
          cod_item,      
          pct_comis_orig,
          pct_comis_meta
     FROM pct_comis_meta_444
    WHERE cod_empresa = p_cod_empresa
    ORDER BY num_pedido, num_seq_item, cod_item 
          
   FOREACH cq_imprime 
      INTO p_relat.num_pedido,
           p_relat.num_seq_item,
           p_relat.cod_item,
           p_relat.pct_comis_orig,
           p_relat.pct_comis_meta
           
      IF STATUS <> 0 THEN                               
         CALL log003_err_sql("Lendo","cursor:cq_imprime")        
         RETURN FALSE                                   
      END IF         
      
      OUTPUT TO REPORT pol1024_relat()
     
      LET p_count = p_count + 1
      
   END FOREACH

   FINISH REPORT pol1024_relat   
   
   IF p_count = 0 THEN
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
  
END FUNCTION 

#------------------------------#
FUNCTION pol1024_escolhe_saida()
#------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1024.tmp"
         START REPORT pol1024_relat TO p_caminho
      ELSE
         START REPORT pol1024_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1024_le_empresa()
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
 REPORT pol1024_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
      
      FIRST PAGE HEADER  
      
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1024",
               COLUMN 019, "COMISSÃO POR ITEM DO PEDIDO",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '      Pedido Sequência      Item       Pct. comis. orig. Pct. comis. meta'
         PRINT COLUMN 001, '      ------ --------- --------------- ----------------- ----------------'
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1024",
               COLUMN 019, "COMISSÃO POR ITEM DO PEDIDO",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '      Pedido Sequência      Item       Pct. comis. orig. Pct. comis. meta'
         PRINT COLUMN 001, '      ------ --------- --------------- ----------------- ----------------'
                            
      ON EVERY ROW

         PRINT COLUMN 005, p_relat.num_pedido,          
               COLUMN 020, p_relat.num_seq_item        USING('###'),
               COLUMN 024, p_relat.cod_item,     
               COLUMN 051, p_relat.pct_comis_orig      USING('##&.&&'),
               COLUMN 068, p_relat.pct_comis_meta      USING('##&.&&')
         

      ON LAST ROW

        LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-----------------------#
 FUNCTION pol1024_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#