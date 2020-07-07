#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1098                                                 #
# OBJETIVO: ASSOCIAÇÃO DAS COLUNAS COM AS OPERAÇOES                 #
# AUTOR...: IVO                                                     #
# DATA....: 16/05/11                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          m_ind                SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(300),
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_total              INTEGER,
          p_reg                INTEGER,
          p_qtd_counteudo      INTEGER,
          p_num_seq_operac     INTEGER
         
  
   DEFINE pr_operac            ARRAY[30] OF RECORD
          cod_roteiro          LIKE consumo.cod_roteiro,
          cod_operac           LIKE consumo.cod_operac,
          den_operac           LIKE operacao.den_operac,
          editar               CHAR(01)
   END RECORD

   DEFINE pr_coluna            ARRAY[30] OF RECORD             
          cod_coluna           LIKE op_coluna_912.cod_coluna,
          coluna               LIKE op_coluna_912.coluna,
          tamanho              LIKE op_coluna_912.tamanho,
          ies_deletar          CHAR(01)
   END RECORD

   DEFINE pr_seq_oper          ARRAY[30] OF RECORD
          seq_oper             LIKE op_coluna_item_912.seq_oper
   END RECORD

   DEFINE p_cod_item           LIKE item.cod_item,
          p_cod_item_ant       LIKE item.cod_item,
          p_den_item           LIKE item.den_item,
          p_cod_operac         LIKE consumo.cod_operac,
          p_cod_roteiro        LIKE consumo.cod_roteiro,
          p_cod_coluna         LIKE op_coluna_912.cod_coluna,
          p_den_coluna         LIKE op_coluna_912.coluna,
          p_seq_oper           LIKE op_coluna_item_912.seq_oper,
          p_oper_ant           LIKE op_coluna_item_912.cod_operac,
          p_den_operac         CHAR(25)

          
END GLOBALS

DEFINE m_copia                 RECORD
       cod_item_orig           CHAR(15),
       den_item_orig           CHAR(50),
       cod_item_dest           CHAR(15),
       den_item_dest           CHAR(50)
END RECORD       

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1098-10.02.07"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
   
   #LET p_cod_empresa = '21'; LET p_user = 'admlog'; LET p_status = FALSE
   
   IF p_status = 0 THEN
      CALL pol1098_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1098_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1098") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1098 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol1098_cria_temp() THEN
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1098_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1098_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1098_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1098_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1098_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1098_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1098_listar()
      COMMAND KEY ("P") "coPiar" "Cópia de dados entre itens"
         IF pol1098_copiar() THEN
            ERROR 'Operação efetuada com sucesso.'
         ELSE
            ERROR 'Operação cancelada.'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1098_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1098

END FUNCTION

#-----------------------#
 FUNCTION pol1098_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
FUNCTION pol1098_cria_temp()
#--------------------------#
   
   DROP TABLE coluna_tmp_912
   
   CREATE  TABLE coluna_tmp_912(
      cod_item      char(15),    
      cod_operac    char(5),     
      cod_roteiro   char(15),    
      cod_coluna    decimal(9,0),
      seq_oper      INTEGER,
      ies_deletar   CHAR(01)
   );

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","coluna_tmp_912")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol1098_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE pr_operac TO NULL
   INITIALIZE p_cod_item TO NULL
   LET p_opcao = 'I'
   DELETE FROM coluna_tmp_912
   LET p_qtd_counteudo = 0
   
   IF pol1098_edita_item() THEN   
      IF pol1098_edita_operac('I') THEN  
         CALL log085_transacao("BEGIN")
         IF pol1098_grava_op_coluna('I') THEN
            CALL log085_transacao("COMMIT")
            RETURN TRUE                                                                    
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      END IF
   END IF
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1098_edita_item()
#-----------------------------#
   
   LET INT_FLAG = FALSE
   
   INPUT p_cod_item WITHOUT DEFAULTS
    FROM cod_item
            
      AFTER FIELD cod_item
      IF p_cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_item   
      END IF
                            
      SELECT den_item
        INTO p_den_item
        FROM item
       WHERE cod_item = p_cod_item
       
      IF STATUS = 100 THEN
         ERROR "Item inexistente !!!"
         NEXT FIELD cod_item
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','item')
            RETURN FALSE
         END IF 
      END IF

      DISPLAY p_den_item TO den_item
      
      LET p_count = 0
      
      SELECT COUNT(cod_item)
        INTO p_count
        FROM op_coluna_item_912
       WHERE cod_item = p_cod_item
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','op_coluna_item_912')
         RETURN FALSE
      END IF 
  
      IF p_count > 0 THEN
         ERROR "Já existem associações p/ esse item !!! - Use a opção modificar"
         NEXT FIELD cod_item
      END IF
      
      IF NOT pol1098_le_consumo() THEN   
         NEXT FIELD cod_item
      END IF
      
      ON KEY (control-z)
         CALL pol1098_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1098_le_consumo()
#---------------------------#

   DELETE FROM coluna_tmp_912
   
   INITIALIZE pr_operac TO NULL
   LET p_index = 1
   
   DECLARE cq_cons CURSOR FOR
    SELECT DISTINCT
           cod_roteiro,
           cod_operac,
           num_seq_operac
      FROM consumo
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_cod_item
     ORDER BY num_seq_operac
   
   FOREACH cq_cons INTO    
           pr_operac[p_index].cod_roteiro,
           pr_operac[p_index].cod_operac,
           p_num_seq_operac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','consumo:cq_cons')    
         RETURN FALSE
      END IF
      
      SELECT den_operac
        INTO pr_operac[p_index].den_operac
        FROM operacao
       WHERE cod_empresa = p_cod_empresa
         AND cod_operac  = pr_operac[p_index].cod_operac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','operacao:cq_cons')    
         RETURN FALSE
      END IF
      
      IF NOT pol1098_copia_operac() THEN
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
   END FOREACH
   
   IF p_index = 1 THEN
      LET p_msg = 'Item sem roteiro cadastrado!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)
   
   RETURN TRUE

END FUNCTION    

#------------------------------#
FUNCTION pol1098_copia_operac()
#------------------------------#

   DEFINE p_cod_prod CHAR(15)
      
   DECLARE cq_copia CURSOR FOR
   
    SELECT cod_item,
           MAX(rowid)
      FROM op_coluna_item_912
     WHERE cod_empresa = p_cod_empresa
       AND cod_operac  = pr_operac[p_index].cod_operac
       AND cod_roteiro = pr_operac[p_index].cod_roteiro
     GROUP BY cod_item 
     ORDER BY 2 DESC
   
   FOREACH cq_copia INTO p_cod_prod
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','op_coluna_item_912:cq_copia')
         RETURN FALSE
      END IF
            
      DECLARE cq_grava_copia CURSOR FOR
       SELECT cod_coluna,
              seq_oper
         FROM op_coluna_item_912
        WHERE cod_empresa = p_cod_empresa
          AND cod_operac  = pr_operac[p_index].cod_operac
          AND cod_roteiro = pr_operac[p_index].cod_roteiro
          AND cod_item    = p_cod_prod
   
      FOREACH cq_grava_copia INTO p_cod_coluna, p_seq_oper
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','op_coluna_item_912:cq_grava_copia')
            RETURN FALSE
         END IF
         
         INSERT INTO coluna_tmp_912
          VALUES(p_cod_item,
                 pr_operac[p_index].cod_operac,
                 pr_operac[p_index].cod_roteiro,
                 p_cod_coluna, p_seq_oper,'N')

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','coluna_tmp_912:cq_grava_copia')
            RETURN FALSE
         END IF
      
      END FOREACH
      
      EXIT FOREACH
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1098_edita_operac(p_op)
#---------------------------------#

   DEFINE p_op CHAR(01)
   
   INPUT ARRAY pr_operac
      WITHOUT DEFAULTS FROM sr_operac.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

         IF NOT pol1098_exibe_coluna() THEN
            RETURN FALSE
         END IF

      BEFORE FIELD editar
      
         IF p_op <> 'C' THEN
            ERROR '<Enter> = Edita conteúdo' 
         END IF

      AFTER FIELD editar
      
         IF pr_operac[p_index].editar IS NOT NULL THEN
            LET pr_operac[p_index].editar = NULL
            NEXT FIELD editar
         END IF
         
         IF pr_operac[p_index].cod_roteiro IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN
            ELSE
               NEXT FIELD editar
            END IF
         END IF
         
         IF FGL_LASTKEY() = 13 AND p_op <> 'C' THEN
            IF pr_operac[p_index].cod_roteiro IS NOT NULL THEN
               CALL pol1098_edita_coluna(p_op)
            END IF
         END IF         

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            IF NOT pol1098_todas_operacoes() THEN
               NEXT FIELD editar
            END IF
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1098_todas_operacoes()
#--------------------------------#

   FOR m_ind = 1 TO ARR_COUNT()
       IF pr_operac[m_ind].cod_operac IS NOT NULL THEN
          SELECT COUNT(cod_coluna)
            INTO p_count
            FROM coluna_tmp_912
           WHERE cod_item   = p_cod_item
             AND cod_operac = pr_operac[m_ind].cod_operac
             AND ies_deletar = 'N'
          IF p_count = 0 THEN
             LET p_msg = 'Operação ', pr_operac[m_ind].cod_operac CLIPPED,
                         ' sem associação de colunas!'
             CALL log0030_mensagem(p_msg,'excla')
             RETURN FALSE
          END IF
       END IF
   END FOR
    
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1098_exibe_coluna()
#-----------------------------#

   INITIALIZE pr_coluna, pr_seq_oper TO NULL
   
   LET p_ind = 1
   LET p_total = 0

   DECLARE cq_col CURSOR FOR 
    SELECT cod_coluna,
           seq_oper,
           ies_deletar
      FROM coluna_tmp_912
     WHERE cod_item   = p_cod_item
       AND cod_operac = pr_operac[p_index].cod_operac
     ORDER BY seq_oper
   
   FOREACH cq_col INTO 
           pr_coluna[p_ind].cod_coluna,
           pr_seq_oper[p_ind].seq_oper,
           pr_coluna[p_ind].ies_deletar

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','coluna_tmp_912:cq_col')
         RETURN FALSE
      END IF
 
      SELECT coluna,
             tamanho
        INTO pr_coluna[p_ind].coluna,
             pr_coluna[p_ind].tamanho
        FROM op_coluna_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_coluna  = pr_coluna[p_ind].cod_coluna
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','op_coluna_912:cq_col')
      END IF
      
      LET p_total = p_total + pr_coluna[p_ind].tamanho
      LET p_ind = p_ind + 1      

      IF p_ind > 30 THEN
         CALL log0030_mensagem('linhas da grade ultrapassau','excla')
         EXIT FOREACH
      END IF

   END FOREACH

   LET p_reg = p_ind - 1

   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_coluna WITHOUT DEFAULTS FROM sr_coluna.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
   DISPLAY p_total TO total
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1098_edita_coluna(p_op)
#----------------------------------#   

   DEFINE p_op CHAR(01)
   
   CALL SET_COUNT(p_ind)
   
   INPUT ARRAY pr_coluna
      WITHOUT DEFAULTS FROM sr_coluna.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  
         
         CALL pol1098_calc_total()
      
      AFTER FIELD cod_coluna
      
         IF pr_coluna[p_ind].cod_coluna IS NULL THEN 
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN
            ELSE
               ERROR 'Campo com preenchimento obrigatório !!!'
               NEXT FIELD cod_coluna
            END IF
         ELSE
            SELECT coluna,
                   tamanho
              INTO pr_coluna[p_ind].coluna,
                   pr_coluna[p_ind].tamanho                                                                 
              FROM op_coluna_912                                                                                   
             WHERE cod_empresa = p_cod_empresa                                        
               AND cod_coluna  = pr_coluna[p_ind].cod_coluna                                              
               
            IF STATUS <> 0 THEN   
               ERROR "Coluna não cadastrada no pol1097 !!!"                                                    
               NEXT FIELD cod_coluna                                                                         
            END IF       

            DISPLAY pr_coluna[p_ind].coluna  TO sr_coluna[s_ind].Coluna
            DISPLAY pr_coluna[p_ind].tamanho TO sr_coluna[s_ind].tamanho  

            IF pr_coluna[p_ind].ies_deletar IS NULL THEN
               LET pr_coluna[p_ind].ies_deletar = 'N'
               DISPLAY pr_coluna[p_ind].ies_deletar TO sr_coluna[s_ind].ies_deletar
            END IF
            
            CALL pol1098_calc_total()

            IF p_total > 75 THEN
               LET p_msg = 'TOTAL DA COLUNA ULTRAPASSOU O LIMITE DE 75 POSIÇÕES!'
               ERROR p_msg
               NEXT FIELD cod_coluna
            END IF

         END IF
            
      AFTER INPUT
      
         IF NOT INT_FLAG THEN
            CALL pol1098_calc_total()
         
            IF p_total > 75 THEN
               LET p_msg = 'Total da coluna\n ultrapassou o limite\n de 75 posições!'
               CALL log0030_mensagem(p_msg,'excla')
               NEXT FIELD cod_coluna
            END IF
         END IF

      ON KEY (control-d)
         IF pr_coluna[p_ind].ies_deletar = 'S' THEN
            LET pr_coluna[p_ind].ies_deletar = 'N'
            DISPLAY 'N' TO sr_coluna[s_ind].ies_deletar
         ELSE
            IF p_opcao = 'M' AND p_ind <= p_reg THEN
               LET p_seq_oper = pr_seq_oper[p_ind].seq_oper 
               SELECT COUNT(cod_item)                                              
                 INTO p_count                                             
                 FROM op_col_dados_912                                    
                WHERE cod_empresa = p_cod_empresa                         
                  AND cod_item    = p_cod_item                            
                  AND cod_operac  = pr_operac[p_index].cod_operac           
                  AND seq_oper    = p_seq_oper           
               IF STATUS <> 0 THEN                                        
                  CALL log003_err_sql('lendo','op_col_dados_912')         
                  RETURN FALSE                                            
               END IF                                                     
               IF p_count > 0 THEN                                        
                  LET p_msg = 'Colunas já associadas ao conteúdo\n',      
                              'pelo pol1099 não podem ser excluidas!'     
                  CALL log0030_mensagem(p_msg,'excla')                    
               ELSE                                                                
                  LET pr_coluna[p_ind].ies_deletar = 'S'                  
                  DISPLAY 'S' TO sr_coluna[s_ind].ies_deletar             
               END IF                                               
            ELSE
               LET pr_coluna[p_ind].ies_deletar = 'S'
               DISPLAY 'S' TO sr_coluna[s_ind].ies_deletar
            END IF
         END IF
                    
      ON KEY (control-z)
         CALL pol1098_popup()

   END INPUT 

   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN
   END IF

   CALL pol1098_grava_tmp(p_op)
               
END FUNCTION

#---------------------------#
FUNCTION pol1098_calc_total()
#---------------------------#

   LET p_total = 0
   
   FOR m_ind = 1 TO ARR_COUNT()
       IF pr_coluna[m_ind].tamanho IS NOT NULL THEN 
          IF pr_coluna[m_ind].ies_deletar = 'N' THEN
             LET p_total = p_total + pr_coluna[m_ind].tamanho
          END IF
       END IF
   END FOR
         
   DISPLAY p_total TO total

END FUNCTION

#------------------------------#
FUNCTION pol1098_grava_tmp(p_op)
#------------------------------#
   
   DEFINE p_op  CHAR(01)
   
   DELETE FROM coluna_tmp_912
    WHERE cod_item   = p_cod_item  
      AND cod_operac = pr_operac[p_index].cod_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Delete','coluna_tmp_912')  
      RETURN
   END IF    

   LET p_seq_oper = 0
      
   FOR m_ind = 1 TO ARR_COUNT()
       IF pr_coluna[m_ind].cod_coluna IS NOT NULL THEN
          IF p_op = 'I' THEN
             LET p_seq_oper = p_seq_oper + 1
          ELSE
             IF m_ind <= p_reg THEN
                LET p_seq_oper = pr_seq_oper[m_ind].seq_oper
             ELSE
                LET p_seq_oper = p_seq_oper + 1
             END IF
          END IF
          INSERT INTO coluna_tmp_912
           VALUES(p_cod_item,
                  pr_operac[p_index].cod_operac,
                  pr_operac[p_index].cod_roteiro,
                  pr_coluna[m_ind].cod_coluna, 
                  p_seq_oper,
                  pr_coluna[m_ind].ies_deletar)
          IF STATUS <> 0 THEN
             CALL log003_err_sql('Insert','coluna_tmp_912')  
             EXIT FOR
          END IF    
       END IF
   END FOR

END FUNCTION

#-----------------------#
 FUNCTION pol1098_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_coluna)
         
         CALL log009_popup(8,25,"COLUNAS","op_coluna_912",
                     "cod_coluna","COLUNA","pol1097","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1098
         
         IF p_codigo IS NOT NULL THEN
            LET pr_coluna[p_ind].cod_coluna = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_coluna[s_ind].cod_coluna
         END IF

      WHEN INFIELD(cod_item)
      
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1098
         
         IF p_codigo IS NOT NULL THEN
           LET p_cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

      WHEN INFIELD(cod_item_orig)
      
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1098a 
         
         IF p_codigo IS NOT NULL THEN
           LET m_copia.cod_item_orig = p_codigo
           DISPLAY p_codigo TO cod_item_orig
         END IF

      WHEN INFIELD(cod_item_dest)
      
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1098a
         
         IF p_codigo IS NOT NULL THEN
           LET m_copia.cod_item_dest = p_codigo
           DISPLAY p_codigo TO cod_item_dest
         END IF

   END CASE 

END FUNCTION 

#-------------------------------------#
 FUNCTION pol1098_grava_op_coluna(p_op)
#-------------------------------------#

   DEFINE p_op CHAR(01)
   
   IF p_op = 'M' THEN
      DELETE FROM op_coluna_item_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Delete','op_coluna_item_912')
         RETURN FALSE
      END IF
   END IF
   
   DECLARE cq_col_tmp CURSOR FOR
    SELECT cod_operac,
           cod_roteiro,
           cod_coluna,
           seq_oper
      FROM coluna_tmp_912
     WHERE cod_item = p_cod_item
       AND ies_deletar = 'N'

   FOREACH cq_col_tmp INTO              
           p_cod_operac,
           p_cod_roteiro,
           p_cod_coluna,
           p_seq_oper
      
      IF NOT pol1098_inc_col_item(p_cod_item) THEN
         RETURN FALSE
      END IF
		          
   END FOREACH
     
   RETURN TRUE
      
END FUNCTION

#----------------------------------------#
FUNCTION pol1098_inc_col_item(l_cod_item)
#----------------------------------------#

   DEFINE l_cod_item CHAR(15)
   
   INSERT INTO op_coluna_item_912                            
		  VALUES (p_cod_empresa,                                    
		          l_cod_item,                                       
		          p_cod_operac,                                     
		          p_cod_roteiro,                                    
		          p_seq_oper,                                       
		          p_cod_coluna)                                     
		                                                          
		IF STATUS <> 0 THEN                                         
		   CALL log003_err_sql("Incluindo", "op_coluna_item_912")   
      RETURN FALSE                                              
   END IF                                                       
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol1098_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_item_ant = p_cod_item
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      op_coluna_item_912.cod_item
      
      ON KEY (control-z)
         CALL pol1098_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_item = p_cod_item_ant
         CALL pol1098_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT DISTINCT cod_item ",
                  "  FROM op_coluna_item_912 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_item

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1098_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1098_exibe_dados()
#------------------------------#

   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','item')
      RETURN FALSE 
   END IF
   
   DISPLAY p_cod_item TO cod_item
   DISPLAY p_den_item TO den_item
        
   IF NOT pol1098_carrega_operac() THEN
      RETURN FALSE
   END IF
   
   CALL pol1098_edita_operac('C') RETURNING p_status

   SELECT COUNT(cod_item)
     INTO p_qtd_counteudo
     FROM op_col_dados_912
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','op_col_dados_912')
      RETURN FALSE 
   END IF
        
   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol1098_carrega_operac()
#---------------------------------#
   
   INITIALIZE pr_operac, pr_seq_oper, pr_coluna TO NULL
   
   DELETE FROM coluna_tmp_912
   
   LET p_index = 1
   
   DECLARE cq_oper CURSOR FOR
    SELECT DISTINCT
           cod_roteiro,
           cod_operac
      FROM op_coluna_item_912
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_cod_item
     
   FOREACH cq_oper INTO
           pr_operac[p_index].cod_roteiro,
           pr_operac[p_index].cod_operac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "op_coluna_item_912:cq_array")
         RETURN FALSE
      END IF
      
      SELECT den_operac
        INTO pr_operac[p_index].den_operac
        FROM operacao
       WHERE cod_empresa = p_cod_empresa
         AND cod_operac  = pr_operac[p_index].cod_operac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "operacao:cq_array")
         RETURN FALSE
      END IF

      DECLARE cq_le_col CURSOR FOR
       SELECT cod_coluna,
              seq_oper
         FROM op_coluna_item_912
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = p_cod_item
          AND cod_operac  = pr_operac[p_index].cod_operac
        ORDER BY seq_oper

      FOREACH cq_le_col INTO p_cod_coluna, p_seq_oper
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "op_coluna_912:cq_le_col")
            RETURN FALSE
         END IF

         INSERT INTO coluna_tmp_912
           VALUES(p_cod_item,
                  pr_operac[p_index].cod_operac,
                  pr_operac[p_index].cod_roteiro,
                  p_cod_coluna, p_seq_oper, 'N')
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Insert','coluna_tmp_912')  
            RETURN FALSE
         END IF    
      
      END FOREACH
            
      LET p_index = p_index + 1
      
   END FOREACH
         
   CALL SET_COUNT(p_index - 1)
     
   INPUT ARRAY pr_operac WITHOUT DEFAULTS FROM sr_operac.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
   RETURN TRUE
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol1098_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_item_ant = p_cod_item

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_item
         
      END CASE

      IF STATUS = 0 THEN
         
         LET p_count = 0
         
         SELECT COUNT(cod_item)
           INTO p_count
           FROM op_coluna_item_912
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item
                        
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "op_coluna_item_912")
            RETURN FALSE
         END IF
         
         IF p_count > 0 THEN   
            CALL pol1098_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_item = p_cod_item_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1098_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR WITH HOLD FOR
    SELECT cod_item 
      FROM op_coluna_item_912  
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_cod_item
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","op_coluna_item_912")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1098_modificacao()
#-----------------------------#
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'

   IF NOT pol1098_carrega_operac() THEN
      RETURN FALSE
   END IF
   
   IF pol1098_prende_registro() THEN
      IF pol1098_edita_operac('M') THEN  
         CALL log085_transacao("BEGIN")
         IF pol1098_grava_op_coluna('M') THEN
            CALL log085_transacao("COMMIT")
            CLOSE cq_prende
            RETURN TRUE                                                                    
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      END IF
      CLOSE cq_prende
   END IF

   RETURN FALSE
   
END FUNCTION

#--------------------------#
 FUNCTION pol1098_exclusao()
#--------------------------#

   IF p_cod_item IS NULL THEN
      LET p_msg = 'Não a dados na tela a serem excluídos!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   IF p_qtd_counteudo > 0 THEN
      LET p_msg = 'Colunas já associadas ao conteúdo\n',
                  'pelo pol1099 não podem ser excluidas!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1098_prende_registro() THEN
      DELETE FROM op_coluna_item_912
			 WHERE cod_empresa = p_cod_empresa
			   AND cod_item    = p_cod_item
         
      IF STATUS = 0 THEN               
         INITIALIZE p_cod_item, pr_operac TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","op_coluna_item_912")
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#--------------------------#
 FUNCTION pol1098_listar()
#--------------------------#     

   IF NOT pol1098_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1098_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_imp CURSOR FOR
    SELECT cod_item,
           cod_operac,
           cod_roteiro,
           cod_coluna
      FROM op_coluna_item_912
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_item, cod_operac, cod_coluna                         
  
   FOREACH cq_imp INTO
           p_cod_item,
           p_cod_operac,
           p_cod_roteiro,
           p_cod_coluna
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'op_coluna_item_912:cq_imp')
         RETURN
      END IF 
   
      SELECT den_item
        INTO p_den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'item:cq_imp')
         EXIT FOREACH
      END IF                                                             
                                                                                       
      SELECT den_operac
        INTO p_den_operac
        FROM operacao
       WHERE cod_empresa = p_cod_empresa
         AND cod_operac  = p_cod_operac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','operacao:cq_imp')    
         RETURN FALSE
      END IF
      
      SELECT coluna
        INTO p_den_coluna
        FROM op_coluna_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_coluna  = p_cod_coluna
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','op_coluna_912:cq_imp')    
         RETURN FALSE
      END IF
      
      OUTPUT TO REPORT pol1098_relat(p_cod_item) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1098_relat   
   
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
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1098_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1098.tmp"
         START REPORT pol1098_relat TO p_caminho
      ELSE
         START REPORT pol1098_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1098_le_den_empresa()
#--------------------------------#

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

#--------------------------------#
 REPORT pol1098_relat(p_cod_item)
#--------------------------------#
    
   DEFINE p_cod_item LIKE item.cod_item
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_den_empresa, 
               COLUMN 073, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1098",
               COLUMN 012, "ASSOCIACAO DAS COLUNAS COM AS OPERACOES",
               COLUMN 053, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "---------------------------------------------------------------------------------"
         PRINT
               
      BEFORE GROUP OF p_cod_item
         
         PRINT
         PRINT COLUMN 003, "Item: ", p_cod_item, " - ", p_den_item
         PRINT
         PRINT COLUMN 001, 'Roteiro         Operacao        Descricao           Coluna       Descricao'
         PRINT COLUMN 001, '--------------- -------- ------------------------- --------- ------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_cod_roteiro,
               COLUMN 017, p_cod_operac,
               COLUMN 026, p_den_operac,
               COLUMN 052, p_cod_coluna  USING "#########",
               COLUMN 062, p_den_coluna
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#------------------------#
FUNCTION pol1098_copiar()#
#------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1098a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1098a AT 5,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
 
   CALL pol1098_info_orig_dest() RETURNING p_status

   CLOSE WINDOW w_pol1098a
   
   RETURN p_status

END FUNCTION
 
#--------------------------------#
FUNCTION pol1098_info_orig_dest()#
#--------------------------------#

   LET INT_FLAG = FALSE
   INITIALIZE m_copia TO NULL
   
   INPUT BY NAME m_copia.* WITHOUT DEFAULTS
            
      AFTER FIELD cod_item_orig
      IF m_copia.cod_item_orig IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_item_orig   
      END IF
                            
      SELECT den_item
        INTO m_copia.den_item_orig
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = m_copia.cod_item_orig
       
      IF STATUS = 100 THEN
         ERROR "Item inexistente !!!"
         NEXT FIELD cod_item_orig
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','item')
            RETURN FALSE
         END IF 
      END IF

      DISPLAY m_copia.den_item_orig TO den_item_orig
      
      SELECT COUNT(cod_item)
        INTO p_count
        FROM op_coluna_item_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = m_copia.cod_item_orig
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','op_coluna_item_912')
         RETURN FALSE
      END IF 
 
      IF p_count = 0 THEN
         LET p_msg = 'Item sem dados cadastrados no POL1098'
         CALL log0030_mensagem(p_msg, 'info')
         NEXT FIELD cod_item_orig
      END IF
      
      AFTER FIELD cod_item_dest
      
      IF m_copia.cod_item_dest IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_item_dest   
      END IF
                            
      SELECT den_item
        INTO m_copia.den_item_dest
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = m_copia.cod_item_dest
       
      IF STATUS = 100 THEN
         ERROR "Item inexistente !!!"
         NEXT FIELD cod_item_dest
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','item')
            RETURN FALSE
         END IF 
      END IF

      DISPLAY m_copia.den_item_dest TO den_item_dest
      
      SELECT COUNT(cod_item)
        INTO p_count
        FROM op_coluna_item_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = m_copia.cod_item_dest
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','op_coluna_item_912')
         RETURN FALSE
      END IF 
 
      IF p_count > 0 THEN
         LET p_msg = 'Item já possui dados cadastrados no POL1098'
         CALL log0030_mensagem(p_msg, 'info')
         NEXT FIELD cod_item_dest
      END IF

      ON KEY (control-z)
         CALL pol1098_popup()
      
   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF      
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   IF NOT pol1098_efetua_copia() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1098_efetua_copia()#
#------------------------------#

   DEFINE l_cod_operac     char(5),
          l_cod_roteiro    char(15),
          l_seq_oper       decimal(2,0),
          l_linha          decimal(1,0),
          l_conteudo       varchar(100)
   
   DECLARE cq_col_item CURSOR FOR
    SELECT cod_operac,
           cod_roteiro,
           cod_coluna,
           seq_oper
      FROM op_coluna_item_912
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = m_copia.cod_item_orig

   FOREACH cq_col_item INTO              
           p_cod_operac,
           p_cod_roteiro,
           p_cod_coluna,
           p_seq_oper
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_col_item')
         RETURN FALSE
      END IF
      
      IF NOT pol1098_inc_col_item(m_copia.cod_item_dest) THEN
         RETURN FALSE
      END IF
		          
   END FOREACH

   DECLARE cq_op_col CURSOR FOR
    SELECT cod_operac,
           cod_roteiro,
           seq_oper,
           linha,
           conteudo
      FROM op_col_dados_912
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = m_copia.cod_item_orig

   FOREACH cq_op_col INTO              
           l_cod_operac,
           l_cod_roteiro,
           l_seq_oper,
           l_linha,
           l_conteudo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_op_col')
         RETURN FALSE
      END IF
      
      INSERT INTO op_col_dados_912(
         cod_empresa,
         cod_item,   
         cod_operac, 
         cod_roteiro,
         seq_oper,   
         linha,      
         conteudo)
       VALUES(p_cod_empresa,
              m_copia.cod_item_dest,
              l_cod_operac,
              l_cod_roteiro,
              l_seq_oper,
              l_linha,
              l_conteudo)
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','op_col_dados_912')
         RETURN FALSE
      END IF
		          
   END FOREACH
     
   RETURN TRUE
      
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

