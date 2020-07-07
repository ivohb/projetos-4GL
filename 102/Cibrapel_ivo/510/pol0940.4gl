#-------------------------------------------------------------------#
# OBJETIVO: EXCLUSÃO DOS APONTAMENTOS CRITICADOS                    #
# DATA....: 05/06/2009                                              #
# Autor...: Willians                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_descarta           SMALLINT,
          p_ies_copiar         SMALLINT,
          p_imprimiu           SMALLINT,
          p_msg                CHAR(100),
          p_salto              SMALLINT,
          p_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          p_ind                SMALLINT,
          s_index              SMALLINT,
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
          p_chave              CHAR(400),
          p_query              CHAR(600),
          p_excluir            CHAR(01)

   DEFINE p_num_ordem          LIKE ordens.num_ordem
   
   DEFINE pr_apont             ARRAY[5000] OF RECORD
          numsequencia         LIKE apont_trim_885.numsequencia,
          numordem             LIKE apont_trim_885.numordem,
          coditem              LIKE apont_trim_885.coditem,
          num_lote             LIKE apont_trim_885.num_lote,
          codmaquina           LIKE apont_trim_885.codmaquina,
          inicio               CHAR(08),
          qtdprod              LIKE apont_trim_885.qtdprod,
          tipmovto             LIKE apont_trim_885.tipmovto,
          mensagem             LIKE apont_erro_885.mensagem,
          excluir              CHAR(01)   
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0940-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0940.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0940_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0940_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0940") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0940 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO codempresa
   
   IF NOT pol0940_le_empresa_ger() THEN
      RETURN
   END IF
  
   MENU "OPCAO"
      COMMAND "Informar" "Iforma os parâmetros p/ a desconsolidação"
         CALL pol0940_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso'
            LET p_ies_cons = TRUE
            NEXT OPTION 'Processar'
         ELSE
            CLEAR FORM 
            DISPLAY p_cod_empresa TO codempresa
            ERROR "Operação Cancelada !!!"
            LET p_ies_cons = FALSE
            NEXT OPTION "Fim"
         END IF
      COMMAND "Processar" "Processa a desconsolidação dos apontamentos selecionados"
         IF p_ies_cons THEN
            CALL pol0940_Excluir() RETURNING p_status
            IF p_status THEN
               CLEAR FORM 
               DISPLAY p_cod_empresa TO codempresa
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               CLEAR FORM 
               DISPLAY p_cod_empresa TO codempresa
               ERROR 'Operação cancelada !!!'
               NEXT OPTION "Fim"
            END IF
         ELSE
            ERROR 'Informe os parâmetros previamente!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0940_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0940

END FUNCTION

#--------------------------------#
 FUNCTION pol0940_le_empresa_ger()
#--------------------------------#

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
      END IF
   END IF

   LET p_cod_empresa = p_cod_emp_ger

   RETURN TRUE 

END FUNCTION
#-------------------------------#
 FUNCTION pol0940_carrega_dados()
#-------------------------------#

   LET p_index = 1
   
   DECLARE cq_apont CURSOR FOR 
  
   SELECT numsequencia,
          numordem,
          coditem,
          num_lote,
          codmaquina,
          convert(CHAR(8),inicio,1),
          qtdprod,
          tipmovto
     FROM apont_trim_885
    WHERE codempresa     = p_cod_empresa
      AND statusregistro = '2'                               
      
   FOREACH cq_apont INTO 
           pr_apont[p_index].numsequencia,
           pr_apont[p_index].numordem,
           pr_apont[p_index].coditem,
           pr_apont[p_index].num_lote,
           pr_apont[p_index].codmaquina,
           pr_apont[p_index].inicio,
           pr_apont[p_index].qtdprod,
           pr_apont[p_index].tipmovto
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','apont_trim_885')
         RETURN FALSE
      END IF 
      
      IF p_num_ordem IS NULL THEN
      ELSE
         IF pr_apont[p_index].numordem <> p_num_ordem THEN
            CONTINUE FOREACH
         END IF
      END IF
      
      LET pr_apont[p_index].excluir = 'N'
      
      DECLARE cq_men CURSOR FOR 
      
      SELECT mensagem
        FROM apont_erro_885
       WHERE codempresa   = p_cod_empresa
         AND numsequencia = pr_apont[p_index].numsequencia
      
      FOREACH cq_men INTO
              pr_apont[p_index].mensagem
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','apont_erro_885')
            RETURN FALSE
         END IF
      
         EXIT FOREACH
    
      END FOREACH
      
      LET p_index = p_index + 1
            
   END FOREACH
   
   IF p_index = 1 THEN
      CALL log0030_mensagem("Não há apontamentos criticados !!!","exclamation")
      RETURN FALSE 
   END IF 
      
   RETURN TRUE 

END FUNCTION 

#--------------------------#
 FUNCTION pol0940_informar()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO codempresa
   LET INT_FLAG = FALSE
   
   INITIALIZE pr_apont, p_num_ordem TO NULL
   
   INPUT p_num_ordem WITHOUT DEFAULTS FROM num_ordem

   AFTER FIELD num_ordem
   IF p_num_ordem IS NOT NULL THEN 

     SELECT COUNT(numordem)
       INTO p_count
       FROM apont_trim_885
      WHERE codempresa     = p_cod_empresa
        AND numordem       = p_num_ordem
        AND statusregistro = '2'                               
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'apont_trim_885')
         NEXT FIELD num_ordem
      END IF
      
      IF p_count = 0 THEN
         ERROR "Essa ordem não existe ou não possui criticas!!!"
         NEXT FIELD num_ordem
      END IF
      
   END IF 

   END INPUT 
            
  IF INT_FLAG THEN
     RETURN FALSE
  END IF
   
   IF pol0940_carrega_dados() = FALSE THEN 
      RETURN FALSE 
   END IF 
   
   LET INT_FLAG = FALSE
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_apont 
      WITHOUT DEFAULTS FROM sr_apont.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
      
      BEFORE FIELD excluir
         LET p_excluir = pr_apont[p_index].excluir  
      
      AFTER FIELD excluir
      
         IF NOT pr_apont[p_index].excluir MATCHES '[SN]' THEN   
            ERROR "Valor ilegal para o campo em questão!"
            LET pr_apont[p_index].excluir = p_excluir
            NEXT FIELD Excluir
         END IF 
            
         IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            IF pr_apont[p_index+1].numsequencia IS NULL THEN
               ERROR 'Não existem mais registros nessa direção!'
               NEXT FIELD excluir
            END IF
         END IF
   END INPUT
      
   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO codempresa
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION    
 
#-------------------------#
 FUNCTION pol0940_excluir()
#-------------------------#
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_ind = 1
   
   FOR p_index = 1 TO ARR_COUNT()
      
      IF pr_apont[p_index].excluir = 'S' THEN 
         IF pol0940_atualizar() = FALSE THEN 
            RETURN FALSE 
         ELSE 
            LET p_ind = p_ind + 1
         END IF  
      END IF 
           
   END FOR 
   
   IF p_ind = 1 THEN 
      CALL log0030_mensagem("Não há registros a serem excluídos !!!","exclamation")
      RETURN FALSE
   ELSE 
      RETURN TRUE 
   END IF 
   
END FUNCTION   
      
#---------------------------#
 FUNCTION pol0940_atualizar()
#---------------------------#

   UPDATE apont_trim_885
      SET statusregistro = '3', usuario = p_user
    WHERE codempresa     = p_cod_empresa
      AND numsequencia   = pr_apont[p_index].numsequencia
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('modificando','apont_trim_885')
      RETURN FALSE 
   END IF 
   
   DELETE FROM apont_erro_885
         WHERE codempresa   = p_cod_empresa        
           AND numsequencia = pr_apont[p_index].numsequencia
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('excluindo','apont_erro_885')
      RETURN FALSE 
   END IF 
   
   RETURN TRUE 
   
END FUNCTION
   
#-----------------------#
 FUNCTION pol0940_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION