#-------------------------------------------------------------------#
# PROGRAMA: pol0628                                                 #
# MODULOS.: pol0628-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE ITENS RELACIONADOS - GRAUNA                 #
# AUTOR...: POLO INFORMATICA - Ana Paula                            #
# DATA....: 20/08/2007                                              #
# ALTERADO: 14/03/2008 por Ana Paula - versao 04                    #
#-------------------------------------------------------------------#

 DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_item           LIKE item.cod_item,
          p_empresa            LIKE empresa.cod_empresa,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_retorno            SMALLINT,          
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_houve_erro         SMALLINT,
          p_seq                SMALLINT,
          p_metodo_avaliacao   LIKE item_relac_1040.metodo_avaliacao 

   DEFINE p_cod_item_final     LIKE item.cod_item,
          p_den_item           LIKE item.den_item,
          p_num_sequencia      DECIMAL(2,0),
          p_cod_item_relac     CHAR(15),
          den_relat            CHAR(50),
          p_ies_inspecao       CHAR(01)

   DEFINE pr_item_relac        ARRAY[500] OF RECORD
          cod_item_relac       LIKE item_relac_1040.cod_item_relac, 
          seq_relatorio        LIKE item_relac_1040.seq_relatorio,
          lay_out              LIKE item_relac_1040.lay_out,
          den_relatorio        LIKE item_relac_1040.den_relatorio,
          metodo_avaliacao     LIKE item_relac_1040.metodo_avaliacao
   END RECORD

   DEFINE p_item_relac_1040  RECORD LIKE item_relac_1040.*,
          p_item_relac_1040a RECORD LIKE item_relac_1040.*

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0628-05.10.04"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0628.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0628_controle()
   END IF

END MAIN
  
#--------------------------#
 FUNCTION pol0628_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0628") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0628 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0628_incluir() RETURNING p_status
         IF p_status THEN
            MESSAGE "Inclusão de Dados Efetuada c/ Sucesso !!!"
               ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Operação Cancelada !!!"
               ATTRIBUTE(REVERSE)
         END IF      
         LET p_ies_cons = FALSE   
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0628_consultar()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0628_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0628_paginacao("ANTERIOR")
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0628_modificar() RETURNING p_status
            IF p_status THEN
               MESSAGE "Modificação de Dados Efetuada c/ Sucesso !!!"
                  ATTRIBUTE(REVERSE)
            ELSE
               MESSAGE "Operação Cancelada !!!"
                  ATTRIBUTE (REVERSE)
            END IF
          ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF p_item_relac_1040.cod_item_final IS NULL THEN
               ERROR "Não há dados na tela a serem excluídos !!!"
            ELSE
                CALL pol0628_excluir() RETURNING p_status
               IF p_status THEN
                  MESSAGE "Exclusão de Dados Efetuada c/ Sucesso !!!"
                     ATTRIBUTE(REVERSE)
               ELSE
                  MESSAGE "Operação Cancelada !!!"
                     ATTRIBUTE(REVERSE)
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
         HELP 007
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0628

END FUNCTION

#--------------------------#
FUNCTION pol0628_incluir()
#--------------------------#

   IF pol0628_aceita_chave() THEN
      IF pol0628_aceita_itens() THEN
         CALL pol0628_grava_itens()
      END IF
   END IF

   RETURN(p_retorno)
   
END FUNCTION

#------------------------------#
FUNCTION pol0628_aceita_chave()
#------------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0628
   CLEAR FORM
   
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_item_relac_1040 TO NULL
  
   LET p_item_relac_1040.cod_empresa = p_cod_empresa
 
   INPUT BY NAME p_item_relac_1040.cod_item_final WITHOUT DEFAULTS  

      AFTER FIELD cod_item_final
      IF p_item_relac_1040.cod_item_final IS NULL THEN
         ERROR "Campo com Preenchimento Obrigatório !!!"
         NEXT FIELD cod_item_final
      END IF
     
      SELECT den_item
        INTO p_den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_item_relac_1040.cod_item_final
 
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR "Item nao cadastrado na Tabela ITEM !!!"  
            NEXT FIELD cod_item_final
         ELSE
            DISPLAY p_den_item TO den_item
         END IF

      LET p_cod_item = p_item_relac_1040.cod_item_final
      
      ON KEY (control-z)
         CALL pol0628_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE 
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF

   RETURN(p_retorno)

END FUNCTION 

#-----------------------------#
FUNCTION pol0628_aceita_itens()
#-----------------------------#

   INITIALIZE pr_item_relac TO NULL

   WHENEVER ERROR CONTINUE

   LET p_index = 1
   
   DECLARE cq_it CURSOR FOR 
    SELECT seq_relatorio, 
           lay_out, 
           den_relatorio, 
           metodo_avaliacao, 
           cod_item_relac
      FROM item_relac_1040
     WHERE cod_empresa    = p_cod_empresa
       AND cod_item_final = p_item_relac_1040.cod_item_final
     ORDER BY seq_relatorio

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","ITEM_RELAC_1040:cq_it")       
      RETURN FALSE
   END IF
   
   FOREACH cq_it INTO 
           pr_item_relac[p_index].seq_relatorio,
           pr_item_relac[p_index].lay_out,
           pr_item_relac[p_index].den_relatorio,
           pr_item_relac[p_index].metodo_avaliacao,
           pr_item_relac[p_index].cod_item_relac  
      
      LET p_index = p_index + 1

      IF p_index > 500 THEN
         EXIT FOREACH
      END IF

   END FOREACH

   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_item_relac 
         WITHOUT DEFAULTS FROM sr_item_relac.*

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
                         
      BEFORE FIELD cod_item_relac
         LET p_cod_item_relac = pr_item_relac[p_index].cod_item_relac

      AFTER FIELD cod_item_relac
         IF pr_item_relac[p_index].cod_item_relac IS NOT NULL THEN
            SELECT den_item
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = pr_item_relac[p_index].cod_item_relac
   
            IF SQLCA.sqlcode = NOTFOUND THEN
               ERROR "Item nao cadastrado na Tabela ITEM !!!"  
               NEXT FIELD cod_item_relac
            END IF
         END IF

      AFTER FIELD seq_relatorio
         IF pr_item_relac[p_index].seq_relatorio IS NOT NULL THEN
            IF pol0628_repetiu_seq() THEN
               ERROR 'Sequencia já Informada'
               NEXT FIELD seq_relatorio
            END IF
         ELSE
            ERROR 'campo com preenchimento obrigatório'
            NEXT FIELD seq_relatorio
         END IF

      AFTER FIELD lay_out
         IF pr_item_relac[p_index].lay_out IS NULL THEN
            ERROR 'campo com preenchimento obrigatório'
            NEXT FIELD lay_out
         END IF
        
         IF pr_item_relac[p_index].lay_out MATCHES "[ABCDE]" THEN
            IF pr_item_relac[p_index].lay_out = "A" THEN
               LET pr_item_relac[p_index].metodo_avaliacao = "VISUAL"
            END IF
            IF pr_item_relac[p_index].lay_out = "B" THEN
               LET pr_item_relac[p_index].metodo_avaliacao = "DIMENSIONAL"
            END IF
            IF pr_item_relac[p_index].lay_out = "C" THEN
               LET pr_item_relac[p_index].metodo_avaliacao = "EXECUTADOS"
            END IF
            IF pr_item_relac[p_index].lay_out = "D" THEN
               LET pr_item_relac[p_index].metodo_avaliacao = "OBSERVACAO"
            END IF
            IF pr_item_relac[p_index].lay_out = "E" THEN
               LET pr_item_relac[p_index].metodo_avaliacao = "DIMENSIONAL"
            END IF
            DISPLAY pr_item_relac[p_index].metodo_avaliacao TO sr_item_relac[p_index].metodo_avaliacao
         ELSE
            ERROR 'Valor Ilegal p/ o Campo! - Informe A,B,C,D ou E'
            NEXT FIELD lay_out
         END IF
       
      AFTER FIELD den_relatorio
         IF pr_item_relac[p_index].den_relatorio IS NULL THEN
            ERROR 'campo com preenchimento obrigatório'
            NEXT FIELD den_relatorio
         END IF

{      AFTER FIELD metodo_avaliacao
         IF pr_item_relac[p_index].metodo_avaliacao IS NULL THEN
            ERROR 'campo com preenchimento obrigatório'
            NEXT FIELD metodo_avaliacao
         END IF
          
         SELECT empresa
           FROM avf_metd_avaliacao
          WHERE empresa          = p_cod_empresa
            AND metodo_avaliacao = pr_item_relac[p_index].metodo_avaliacao
          
        IF STATUS = 100 THEN
            ERROR 'Método não cadastrado!!!'
            NEXT FIELD metodo_avaliacao
        ELSE
           IF STATUS <> 0 THEN
              CALL log003_err_sql("LEITURA","avf_metd_avaliacao")       
              RETURN FALSE
           END IF
        END IF
 }       
      ON KEY (control-z)
         CALL pol0628_popup()
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE
   ELSE
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF   
   RETURN(p_retorno)
   
END FUNCTION

#-------------------------------#
FUNCTION pol0628_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_item_relac[p_ind].cod_item_relac = pr_item_relac[p_index].cod_item_relac THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0628_repetiu_seq()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_item_relac[p_ind].seq_relatorio = pr_item_relac[p_index].seq_relatorio THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   
   RETURN FALSE
   
END FUNCTION


#-----------------------------#
FUNCTION pol0628_grava_itens()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 
   
   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")

   DELETE FROM item_relac_1040
    WHERE cod_empresa    = p_cod_empresa
      AND cod_item_final = p_item_relac_1040.cod_item_final

   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE 
      MESSAGE "Erro na deleção" ATTRIBUTE(REVERSE)
   ELSE
      FOR p_ind = 1 TO ARR_COUNT()
          IF pr_item_relac[p_ind].cod_item_relac <> " " THEN

             INSERT INTO item_relac_1040
                VALUES(p_cod_empresa,
                       p_item_relac_1040.cod_item_final,
                       pr_item_relac[p_ind].seq_relatorio,
                       pr_item_relac[p_ind].lay_out,
                       pr_item_relac[p_ind].den_relatorio,
                       pr_item_relac[p_ind].metodo_avaliacao,
                       pr_item_relac[p_ind].cod_item_relac)

             IF sqlca.sqlcode <> 0 THEN 
                LET p_houve_erro = TRUE
                MESSAGE "Erro na inclusão" ATTRIBUTE(REVERSE)
                EXIT FOR
             END IF

          END IF
          
      END FOR
   END IF
   
   IF NOT p_houve_erro THEN
      CALL log085_transacao("COMMIT")	      
      LET p_retorno = TRUE
   ELSE
      CALL log003_err_sql("GRAVAÇÃO","ITEM_RELAC_1040")
      CALL log085_transacao("ROLLBACK")
      LET p_retorno = FALSE
   END IF      
   
   WHENEVER ERROR STOP
   
END FUNCTION

#-----------------------#
FUNCTION pol0628_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item_final)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0628
         IF p_codigo IS NOT NULL THEN
           LET p_item_relac_1040.cod_item_final = p_codigo
           DISPLAY p_codigo TO cod_item_final
         END IF

      WHEN INFIELD(cod_item_relac)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0628
         IF p_codigo IS NOT NULL THEN
           LET pr_item_relac[p_index].cod_item_relac = p_codigo
           DISPLAY p_codigo TO cod_item_relac
         END IF

      WHEN INFIELD(metodo_avaliacao)
         CALL log009_popup(8,25,"METODOS DE AVALIAÇÃO","avf_metd_avaliacao",
                     "metodo_avaliacao","des_metd_avaliacao","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0628
         IF p_codigo IS NOT NULL THEN
            LET pr_item_relac[p_index].metodo_avaliacao = p_codigo CLIPPED
            DISPLAY p_codigo TO metodo_avaliacao
         END IF

   END CASE
   
END FUNCTION

#----------------------------#
 FUNCTION pol0628_consultar()
#----------------------------#

  DEFINE sql_stmt, 
         where_clause CHAR(300)  

   LET p_item_relac_1040a.* = p_item_relac_1040.*
   LET p_cod_item_final     = p_item_relac_1040.cod_item_final

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
   CONSTRUCT BY NAME where_clause ON item_relac_1040.cod_item_final
   
         ON KEY (control-z)
         CALL pol0628_popup()
         
   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0628

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_item_relac_1040.* = p_item_relac_1040a.*
      CALL pol0628_exibe_cabec()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM item_relac_1040 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_empresa,cod_item_final "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_item_relac_1040.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0628_exibe_cabec()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0628_exibe_cabec()
#------------------------------#


   DISPLAY p_cod_empresa TO cod_empresa

   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_relac_1040.cod_item_final
   
   DISPLAY p_item_relac_1040.cod_item_final TO cod_item_final
   DISPLAY p_den_item TO den_item

   CALL pol0628_exibe_item()
     
END FUNCTION
  
  #---------------------------------#
    FUNCTION pol0628_exibe_item()
  #---------------------------------#

   LET p_index = 1

    DECLARE cq_item_relac1 CURSOR FOR 
    SELECT seq_relatorio,
           lay_out,
           den_relatorio,
           metodo_avaliacao,
           cod_item_relac
      FROM item_relac_1040
     WHERE cod_empresa    = p_cod_empresa
       AND cod_item_final = p_item_relac_1040.cod_item_final
     ORDER BY seq_relatorio

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","ITEM_RELAC_1040:cq_it")       
      RETURN FALSE
   END IF
   
   FOREACH cq_item_relac1 INTO 
           pr_item_relac[p_index].seq_relatorio,
           pr_item_relac[p_index].lay_out,
           pr_item_relac[p_index].den_relatorio,
           pr_item_relac[p_index].metodo_avaliacao,
           pr_item_relac[p_index].cod_item_relac  
                         
      LET p_index = p_index + 1

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_item_relac WITHOUT DEFAULTS FROM sr_item_relac.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol0628_paginacao(p_funcao)
#-----------------------------------#
   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cod_item_final = p_item_relac_1040.cod_item_final
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_item_relac_1040.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_item_relac_1040.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_item_relac_1040.cod_item_final = p_cod_item_final
            EXIT WHILE
         END IF

         IF p_item_relac_1040.cod_item_final = p_cod_item_final THEN
            CONTINUE WHILE
         END IF

         SELECT COUNT(cod_item_final) INTO p_count
           FROM item_relac_1040
          WHERE cod_empresa = p_cod_empresa
            AND cod_item_final    = p_item_relac_1040.cod_item_final
            
         IF p_count > 0 THEN
            CALL pol0628_exibe_cabec()
            EXIT WHILE 
         END IF

      END WHILE
                  
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol0628_modificar()
#--------------------------#

   IF pol0628_aceita_itens() THEN
      CALL pol0628_grava_itens()
   ELSE
      CALL pol0628_exibe_item()
   END IF

   RETURN(p_retorno)
   
END FUNCTION

#------------------------#
FUNCTION pol0628_excluir()
#------------------------#

   LET p_retorno = FALSE

   IF log004_confirm(18,35) THEN
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      DELETE FROM item_relac_1040
        WHERE cod_empresa    = p_cod_empresa
          AND cod_item_final = p_item_relac_1040.cod_item_final
          
      IF STATUS = 0 THEN 
         CALL log085_transacao("COMMIT")
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         INITIALIZE p_item_relac_1040.* TO NULL
      ELSE
         CALL log003_err_sql("DELEÇÃO","ITEM_RELAC_1040")
      END IF
   END IF
   WHENEVER ERROR STOP
   RETURN(p_retorno)
   
END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#
