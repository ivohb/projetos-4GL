#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1226                                                 #
# OBJETIVO: ITEM FORNEC PARA SKIP-LOT                               #
# AUTOR...: IVO BL                                                  #
# DATA....: 25/09/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_opcao              CHAR(01),
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
          p_8lpp               CHAR(100),
          p_last_row           SMALLINT,
          p_ies_inclu          SMALLINT,
          P_consulta_ent       CHAR(100),
          P_consulta_sai       CHAR(100),
          p_msg                CHAR(300),
          p_excluiu            SMALLINT
  
   
END GLOBALS

DEFINE p_fornec_item_5054    RECORD LIKE fornec_item_5054.*,
       p_fornec_item_5054a   RECORD LIKE fornec_item_5054.*

DEFINE p_raz_social          LIKE fornecedor.raz_social,
       p_den_item            LIKE item.den_item,
       p_den_reduz           LIKE item.den_item_reduz,
       p_descricao           LIKE grupo_skip_lot_5054.descricao,
       p_qtd_entrada         LIKE grupo_skip_lot_5054.qtd_entrada,
       p_inspecao            LIKE item_fornec.ies_tipo_inspecao,
       p_qtd_inspecao        LIKE item_fornec.qtd_inspecao,
       p_reservado           LIKE item_barra.reservado_03,
       p_qtd_entr_sem_insp   LIKE item_fornec.qtd_entr_sem_insp,
       p_tem_inspecao        CHAR(01)  

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1226-10.02.04"
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
      CALL pol1226_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1226_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1226") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1226 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   LET p_ies_cons  = FALSE
   CALL pol1226_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         LET p_ies_cons = FALSE
         LET p_opcao = 'I'
         CALL pol1226_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            CALL pol1226_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
         LET p_opcao = 'C'
         CALL pol1226_consulta() RETURNING p_status
         IF p_status THEN
            IF p_ies_cons THEN
               ERROR 'Consulta efetuada com sucesso !!!'
               NEXT OPTION "Seguinte" 
            ELSE
               CALL pol1226_limpa_tela()
               ERROR 'Argumentos de pesquisa não encontrados !!!'
            END IF 
         ELSE
            CALL pol1226_limpa_tela()
            ERROR 'Operação cancelada!!!'
            NEXT OPTION 'Incluir'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1226_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1226_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela"
         LET p_opcao = 'M'
         IF p_ies_cons THEN
            CALL pol1226_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
        IF p_ies_cons THEN
           CALL pol1226_exclusao() RETURNING p_retorno
           IF p_retorno THEN
              ERROR 'Exclusão efetuada com sucesso !!!'
           ELSE
              ERROR 'Operação cancelada !!!'
           END IF
        ELSE
           ERROR "Consulte previamente para fazer a exclusão !!!"
        END IF  
      COMMAND "Listar" "Listagem"
         LET p_opcao = 'L'
         CALL pol1226_listagem()     
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1226_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1226

END FUNCTION

#-----------------------#
 FUNCTION pol1226_sobre()
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
 FUNCTION pol1226_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1226_inclusao()
#--------------------------#

   CALL pol1226_limpa_tela()
   
   INITIALIZE p_fornec_item_5054.* TO NULL
   
   IF pol1226_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO fornec_item_5054
       VALUES(p_fornec_item_5054.*)
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERT", "fornec_item_5054") 
         CALL log085_transacao("ROLLBACK")  
         RETURN FALSE
      END IF
      
      IF NOT pol1226_atu_sup0090() THEN 
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      CALL log085_transacao("COMMIT")
   ELSE
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1226_atu_sup0090()#
#-----------------------------#
   
   DEFINE p_cod_item CHAR(15)
          
   DECLARE cq_sup CURSOR FOR
    SELECT cod_item
      FROM fornec_item_5054
     WHERE cod_fornecedor = p_fornec_item_5054.cod_fornecedor
       AND cod_grupo = p_fornec_item_5054.cod_grupo

   FOREACH cq_sup INTO p_cod_item
      
      IF STATUS <> 0 THEN   
         CALL log003_err_sql('FOREACH','cq_sup')
         RETURN TRUE
      END IF
      
      SELECT qtd_entr_sem_insp
        INTO p_qtd_entr_sem_insp
        FROM item_fornec                                                     
       WHERE cod_empresa = p_cod_empresa                                     
         AND cod_fornecedor = p_fornec_item_5054.cod_fornecedor              
         AND cod_item = p_cod_item                         
      
      IF STATUS <> 0 THEN   
         CALL log003_err_sql('FOREACH','cq_sup')
         RETURN FALSE
      END IF
      
      EXIT FOREACH      
   
   END FOREACH

   UPDATE item_fornec 
      SET qtd_inspecao = p_qtd_entrada,
          qtd_entr_sem_insp = p_qtd_entr_sem_insp                                            
    WHERE cod_fornecedor = p_fornec_item_5054.cod_fornecedor              
      AND cod_item = p_fornec_item_5054.cod_item                          
   
   IF STATUS <> 0 THEN                                                    
      CALL log003_err_sql("UPDATE", "ITEM_FORNEC")                
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1226_gra_sup0090()#
#-----------------------------#

   UPDATE item_fornec 
      SET qtd_inspecao = p_qtd_entrada,
          qtd_entr_sem_insp = p_qtd_entr_sem_insp                                            
    WHERE cod_fornecedor = p_fornec_item_5054.cod_fornecedor              
      AND cod_item = p_fornec_item_5054.cod_item                          
   
   IF STATUS <> 0 THEN                                                    
      CALL log003_err_sql("UPDATE", "ITEM_FORNEC")                
      RETURN FALSE
   END IF  
   
   RETURN TRUE

END FUNCTION                                                                  

#-------------------------------------#
 FUNCTION pol1226_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01) 
   LET INT_FLAG = FALSE
   
   INPUT BY NAME 
      p_fornec_item_5054.cod_fornecedor,
      p_fornec_item_5054.cod_item,
      p_fornec_item_5054.cod_grupo
    WITHOUT DEFAULTS
      
      BEFORE FIELD cod_fornecedor
         
         IF p_funcao = 'M' THEN
            NEXT FIELD cod_grupo
         END IF
      
      AFTER FIELD cod_fornecedor
         
         IF p_fornec_item_5054.cod_fornecedor IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório."
            NEXT FIELD cod_fornecedor   
         END IF
      
         CALL pol1226_le_fornecedor(p_fornec_item_5054.cod_fornecedor)
         
         IF p_raz_social IS NULL THEN
            ERROR "Fornecedor não cadastrado."
            NEXT FIELD cod_fornecedor
         END IF
         
         DISPLAY p_raz_social TO raz_social

      AFTER FIELD cod_item
         
         IF p_fornec_item_5054.cod_item IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório."
            NEXT FIELD cod_item   
         END IF
      
         CALL pol1226_le_item(p_fornec_item_5054.cod_item)
         
         IF p_den_item IS NULL THEN
            ERROR "Item não cadastrado."
            NEXT FIELD cod_item
         END IF
         
         IF p_tem_inspecao = 'S' THEN
         ELSE
            ERROR 'Item sem inspeção.'
            NEXT FIELD cod_item
         END IF
         
         DISPLAY p_den_item TO den_item

      AFTER FIELD cod_grupo
         
         IF p_fornec_item_5054.cod_grupo IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório"
            NEXT FIELD cod_grupo   
         END IF
      
         CALL pol1226_le_grupo(p_fornec_item_5054.cod_grupo)
         
         IF p_descricao IS NULL THEN
            ERROR "Grupo não cadastrado."
            NEXT FIELD cod_grupo
         END IF
         
         DISPLAY p_descricao TO descricao
         DISPLAY p_qtd_entrada TO qtd_entrada

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
         
            IF p_fornec_item_5054.cod_item IS NULL THEN 
               ERROR "Informe o código do item."
               NEXT FIELD cod_item   
            END IF

            IF p_fornec_item_5054.cod_grupo IS NULL THEN 
               ERROR "Informe o código do grupo."
               NEXT FIELD cod_grupo   
            END IF
         
            IF NOT pol1226_eh_possivel() THEN
               NEXT FIELD cod_fornecedor
            END IF
            
         END IF   

      ON KEY (control-z)
         CALL pol1226_popup()
                                                         
   END INPUT 

   IF INT_FLAG  THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1226_le_fornecedor(p_cod)#
#------------------------------------#

   DEFINE p_cod CHAR(15)
   
   SELECT raz_social
     INTO p_raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_cod

   IF STATUS <> 0 THEN
      LET p_raz_social = NULL
   END IF

END FUNCTION

#------------------------------#
FUNCTION pol1226_le_item(p_cod)#
#------------------------------#

   DEFINE p_cod CHAR(15)
   
   SELECT den_item,
          den_item_reduz,
          ies_tem_inspecao
     INTO p_den_item,
          p_den_reduz,
          p_tem_inspecao
     FROM item
    WHERE cod_empresa = p_cod_empresa 
      AND cod_item = p_cod

   IF STATUS <> 0 THEN
      LET p_den_item = NULL
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol1226_le_grupo(p_cod)#
#-------------------------------#

   DEFINE p_cod CHAR(15)
   
   SELECT descricao,
          qtd_entrada
     INTO p_descricao,
          p_qtd_entrada
     FROM grupo_skip_lot_5054
    WHERE cod_grupo = p_cod

   IF STATUS <> 0 THEN
      LET p_descricao = NULL
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol1226_eh_possivel()#
#-----------------------------#

   DEFINE p_qtd01, p_qtd02 CHAR(10)

   IF p_opcao = 'I' THEN      
      SELECT cod_item                                                        
        FROM fornec_item_5054                                                
       WHERE cod_fornecedor = p_fornec_item_5054.cod_fornecedor              
         AND cod_item = p_fornec_item_5054.cod_item                          
   
      IF STATUS = 0 THEN                                                     
         ERROR 'Fornecedor/item já cadastrado.'                              
         RETURN FALSE
      END IF                                                                 
   END IF
                                                                          
   SELECT ies_tipo_inspecao,
          qtd_inspecao,
          qtd_entr_sem_insp
     INTO p_inspecao,
          p_qtd_inspecao,
          p_qtd_entr_sem_insp
     FROM item_fornec                                                     
    WHERE cod_empresa = p_cod_empresa                                     
      AND cod_fornecedor = p_fornec_item_5054.cod_fornecedor              
      AND cod_item = p_fornec_item_5054.cod_item                          
   
   IF STATUS <> 0 THEN                                                    
      ERROR 'Fornecedor/item não cadastrado no SUP0090, p/ a Empresa ', p_cod_empresa            
      RETURN FALSE
   END IF                                                                 
                                                                          
   IF p_inspecao = '2' THEN                                               
      LET p_msg = 'Fornecedor/item com inspeção\n',                       
                  'por quantidade física não pode\n',                      
                  'ser incluído do skip-lot.'                             
      CALL log0030_mensagem(p_msg,'info')                                 
      RETURN FALSE
   END IF                                                                 

   SELECT reservado_03                                               
     INTO p_reservado                                                      
     FROM item_barra                                                   
    WHERE cod_empresa = p_cod_empresa                                     
      AND cod_item = p_fornec_item_5054.cod_item  
                              
   IF STATUS <> 0 THEN                                                    
      ERROR 'Fornecedor/item não cadastrado no MAN992, para a Empresa ', p_cod_empresa               
      RETURN FALSE
   END IF                                                                 

   IF p_reservado[1,1] = 'S' THEN                                               
   ELSE
      LET p_msg = 'Item está cadastrado no programa MAN9922,\n',
                  'más não está com a opção de integração\n',
                  'com o módulo IQPF de qualidade acionada.' 
      CALL log0030_mensagem(p_msg,'info')                                 
      RETURN FALSE
   END IF                                                                 

   IF p_qtd_entrada <> p_qtd_inspecao THEN
      LET p_qtd01 = p_qtd_inspecao
      LET p_qtd02 = p_qtd_entrada
      LET p_msg = 'A quantidade de entradas sem\n',
                  'inspeção do SUP0090: ',p_qtd01 CLIPPED, '\n',
                  'será substituída pela quantidade\n',
                  'do grupo selecionado: ',p_qtd02 CLIPPED, '\n',
                  'Continuar assim mesmo ???'
      IF NOT log0040_confirm(20,25,p_msg) THEN
         RETURN FALSE
      END IF   
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1226_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1226
         IF p_codigo IS NOT NULL THEN
            LET p_fornec_item_5054.cod_fornecedor = p_codigo
            DISPLAY p_codigo TO cod_fornecedor
         END IF

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1226
         IF p_codigo IS NOT NULL THEN
           LET p_fornec_item_5054.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

      WHEN INFIELD(cod_grupo)
         CALL log009_popup(8,25,"GRUPOS SKIP-LOT","grupo_skip_lot_5054",
                     "cod_grupo","descricao","POL1225","S"," 1=1 order by descricao") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1226
         IF p_codigo IS NOT NULL THEN
            LET p_fornec_item_5054.cod_grupo = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_grupo
         END IF

   END CASE
   
END FUNCTION
  
#--------------------------#
 FUNCTION pol1226_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1226_limpa_tela()
   
   LET p_fornec_item_5054a.* = p_fornec_item_5054.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      fornec_item_5054.cod_fornecedor,
      fornec_item_5054.cod_item,
      fornec_item_5054.cod_grupo

      ON KEY (control-z)
         CALL pol1226_popup()

   END CONSTRUCT
               
   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_fornec_item_5054.* = p_fornec_item_5054a.*   
         CALL pol1226_exibe_dados() RETURNING p_status
      ELSE
         CALL pol1226_limpa_tela()
      END IF
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT * ",
                  "  FROM fornec_item_5054 ",
                  " WHERE ", where_clause CLIPPED,
                  " order by cod_fornecedor, cod_item "
                  

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','VAR_QUERY')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_fornec_item_5054.*

   IF STATUS = 0 THEN
      IF pol1226_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   ELSE   
      IF STATUS = 100 THEN
         CALL log0030_mensagem("Argumentos de pesquisa não encontrados!","excla")
      ELSE
         CALL log003_err_sql('FETCH','CQ_PADRAO')
      END IF
   END IF

   CALL pol1226_limpa_tela()
   
   LET p_ies_cons = FALSE
         
   RETURN FALSE
   
END FUNCTION

#------------------------------#
 FUNCTION pol1226_exibe_dados()
#------------------------------#
  
  CALL pol1226_le_fornecedor(p_fornec_item_5054.cod_fornecedor)
  CALL pol1226_le_item(p_fornec_item_5054.cod_item) 
  CALL pol1226_le_grupo(p_fornec_item_5054.cod_grupo)
  
  DISPLAY BY NAME p_fornec_item_5054.*
  DISPLAY p_raz_social TO raz_social
  DISPLAY p_den_item TO den_item
  DISPLAY p_descricao TO descricao
  DISPLAY p_qtd_entrada TO qtd_entrada
 
  LET p_excluiu = FALSE
  
  RETURN TRUE
  
END FUNCTION

#-----------------------------------#
 FUNCTION pol1226_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_fornec_item_5054a.* = p_fornec_item_5054.*

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_fornec_item_5054.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_fornec_item_5054.*
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_fornec_item_5054.* = p_fornec_item_5054a.*
         ELSE
            CALL log003_err_sql('FETCH','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      SELECT *
        INTO p_fornec_item_5054.*
        FROM fornec_item_5054
       WHERE cod_fornecedor = p_fornec_item_5054.cod_fornecedor
         AND cod_item = p_fornec_item_5054.cod_item
      
      IF STATUS = 0 THEN
         IF pol1226_exibe_dados() THEN
            EXIT WHILE
         ELSE
            RETURN
         END IF
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('SELECT','fornec_item_5054')
            RETURN
         END IF
      END IF
       
    END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1226_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR WITH HOLD FOR
    SELECT cod_grupo 
      FROM fornec_item_5054  
     WHERE cod_fornecedor = p_fornec_item_5054.cod_fornecedor
       AND cod_item = p_fornec_item_5054.cod_item
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","fornec_item_5054")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1226_modificacao()
#-----------------------------#
   
   DEFINE p_cod_grupo LIKE fornec_item_5054.cod_grupo
   
   IF p_excluiu THEN
      LET p_msg = 'Não dados na tela\n a serem modificados'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE
   
   IF pol1226_prende_registro() THEN
      LET p_cod_grupo = p_fornec_item_5054.cod_grupo
      IF pol1226_edita_dados("M") THEN
         IF p_fornec_item_5054.cod_grupo <> p_cod_grupo THEN
            IF pol1226_upd_modif() THEN
               LET p_retorno = TRUE
            END IF
         END IF
      ELSE
         LET p_fornec_item_5054.* = p_fornec_item_5054A.*
         CALL pol1226_exibe_dados() RETURNING p_status
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

#---------------------------#
FUNCTION pol1226_upd_modif()#
#---------------------------#

   IF NOT pol1226_atu_sup0090() THEN
      RETURN FALSE
   END IF

   SELECT qtd_entr_sem_insp
     INTO p_qtd_entr_sem_insp
     FROM item_fornec                                                     
    WHERE cod_empresa = p_cod_empresa                                     
      AND cod_fornecedor = p_fornec_item_5054.cod_fornecedor              
      AND cod_item = p_fornec_item_5054.cod_item                         
      
   IF STATUS <> 0 THEN   
      CALL log003_err_sql('FOREACH','cq_sup')
      RETURN FALSE
   END IF
   
   UPDATE fornec_item_5054
      SET fornec_item_5054.* = p_fornec_item_5054.*
    WHERE cod_fornecedor = p_fornec_item_5054.cod_fornecedor
      AND cod_item = p_fornec_item_5054.cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","fornec_item_5054")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1226_exclusao()
#--------------------------#

   IF p_excluiu THEN
      LET p_msg = 'Não dados na tela\n a serem excluídos'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1226_prende_registro() THEN
      DELETE FROM fornec_item_5054
       WHERE cod_fornecedor = p_fornec_item_5054.cod_fornecedor
         AND cod_item = p_fornec_item_5054.cod_item
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_fornec_item_5054 TO NULL
         CALL pol1226_limpa_tela()
         LET p_retorno = TRUE  
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("DELETE","fornec_item_5054")
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

#-------------------------#
FUNCTION pol1226_listagem()
#-------------------------#     

   IF NOT pol1226_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1226_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT *
      FROM fornec_item_5054
     ORDER BY cod_grupo, cod_fornecedor, cod_item
   
   FOREACH cq_impressao INTO 
           p_fornec_item_5054.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_IMPRESSAO')
         EXIT FOREACH
      END IF      
      
      CALL pol1226_le_fornecedor(p_fornec_item_5054.cod_fornecedor)
      CALL pol1226_le_item(p_fornec_item_5054.cod_item) 
      CALL pol1226_le_grupo(p_fornec_item_5054.cod_grupo)
      
      OUTPUT TO REPORT pol1226_relat(p_fornec_item_5054.cod_grupo) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1226_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados. "
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
      ERROR 'Relatório gerado com sucesso!!!'
   END IF
  
END FUNCTION 

#------------------------------#
FUNCTION pol1226_escolhe_saida()
#------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1226.tmp"
         START REPORT pol1226_relat TO p_caminho
      ELSE
         START REPORT pol1226_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1226_le_empresa()
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

#---------------------------------#
 REPORT pol1226_relat(p_cod_grupo)#
#---------------------------------#

   DEFINE p_cod_grupo LIKE fornec_item_5054.cod_grupo
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
   
   ORDER EXTERNAL BY p_cod_grupo
          
   FORMAT

      FIRST PAGE HEADER
              
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 074, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1226",
               COLUMN 025, "FORNECEDOR/ITEM P/ SKIP-LOT",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------"
         PRINT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 074, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1226",
               COLUMN 025, "FORNECEDOR/ITEM P/ SKIP-LOT",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------"
         PRINT

      BEFORE GROUP OF p_cod_grupo
         PRINT COLUMN 001, 'GRUPO: ', p_fornec_item_5054.cod_grupo, ' ', p_descricao CLIPPED, ' ', p_qtd_entrada
         PRINT
         PRINT COLUMN 001, '  FORNECEDOR                 NOME                   ITEM           DESCRICAO'
         PRINT COLUMN 001, '--------------- ------------------------------ --------------- ------------------'

      AFTER GROUP OF p_cod_grupo

         PRINT
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_fornec_item_5054.cod_fornecedor,
               COLUMN 017, p_raz_social[1,30],
               COLUMN 048, p_fornec_item_5054.cod_item,
               COLUMN 064, p_den_reduz
         
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#