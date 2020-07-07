#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0916                                                 #
# OBJETIVO: CONSULTA DE INSUMOS EXPORTADOS PARA O TRIM              #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 04/03/09                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
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
          p_msg                CHAR(100),
          p_last_row           SMALLINT
          
   DEFINE p_insumo_885         RECORD 
          cod_item             LIKE insumo_885.cod_item,
          num_lote             LIKE insumo_885.num_lote,
          largura              LIKE insumo_885.largura,
          diametro             LIKE insumo_885.diametro,
          tubete               LIKE insumo_885.tubete,
          qtd_movto            LIKE insumo_885.qtd_movto,
          tip_movto            LIKE insumo_885.tip_movto,
          dat_movto            LIKE insumo_885.dat_movto,
          val_movto            LIKE insumo_885.val_movto,
          ies_bobina           LIKE insumo_885.ies_bobina,
          qtd_fardos           LIKE insumo_885.qtd_fardos,
          num_nf               LIKE insumo_885.num_nf,
          dat_emis_nf          LIKE insumo_885.dat_emis_nf,
          num_ar               LIKE insumo_885.num_ar,
          cod_fornecedor       LIKE insumo_885.cod_fornecedor,
          nom_fornecedor       LIKE insumo_885.nom_fornecedor,
          cod_status           LIKE insumo_885.cod_status
   END RECORD         

   DEFINE p_den_item           LIKE item.den_item 
   
   DEFINE p_num_sequencia      LIKE insumo_885.num_sequencia,
          p_num_sequencia_ant  LIKE insumo_885.num_sequencia

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0916-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0916_controle()
   END IF
END MAIN

#---------------------------#
 FUNCTION pol0916_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0916") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0916 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0916_le_empresa() THEN
      RETURN
   END IF

   DISPLAY p_cod_emp_ofic TO cod_empresa
      
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela"
         CALL pol0916_consulta() RETURNING p_status
         IF p_status THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'Operação cancelada'
         END IF
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0916_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0916_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0916_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0916

END FUNCTION

#----------------------------#
FUNCTION pol0916_le_empresa()
#----------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa  = p_cod_emp_ger
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

   RETURN TRUE 

END FUNCTION

#---------------------------#
FUNCTION pol0916_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_emp_ofic TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol0916_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol0916_limpa_tela()
   
   LET p_num_sequencia_ant = p_num_sequencia
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      insumo_885.cod_item,
      insumo_885.num_lote,
      insumo_885.largura,
      insumo_885.diametro,
      insumo_885.tubete,
      insumo_885.qtd_movto,
      insumo_885.tip_movto,
      insumo_885.dat_movto,
      insumo_885.val_movto,
      insumo_885.ies_bobina,
      insumo_885.qtd_fardos,
      insumo_885.num_nf,
      insumo_885.dat_emis_nf,
      insumo_885.num_ar,
      insumo_885.cod_fornecedor,
      insumo_885.nom_fornecedor,
      insumo_885.cod_status
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_num_sequencia = p_num_sequencia_ant   
         CALL pol0916_exibe_dados() RETURNING p_status
      ELSE
         CALL pol0916_limpa_tela()
      END IF
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT num_sequencia",
                  "  FROM insumo_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " order by cod_item, dat_movto"
                  

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_num_sequencia

   IF STATUS = 0 THEN
      IF pol0916_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   ELSE   
      IF STATUS = 100 THEN
         CALL log0030_mensagem("Argumentos de pesquisa não encontrados!","excla")
      ELSE
         CALL log003_err_sql('Lendo','insumo_885')
      END IF
   END IF

   CALL pol0916_limpa_tela()
   
   LET p_ies_cons = FALSE
         
   RETURN FALSE
   
END FUNCTION

#------------------------------#
 FUNCTION pol0916_exibe_dados()
#------------------------------#

  SELECT cod_item,
         num_lote,
         largura,
         diametro,
         tubete,
         qtd_movto,
         tip_movto,
         dat_movto,
         val_movto,
         ies_bobina,
         qtd_fardos,
         num_nf,
         dat_emis_nf,
         num_ar,
         cod_fornecedor,
         nom_fornecedor,
         cod_status
         
    INTO p_insumo_885.*
    FROM insumo_885
   WHERE cod_empresa   = p_cod_empresa
     AND num_sequencia = p_num_sequencia
     
  IF STATUS = 0 THEN
     
     SELECT den_item
       INTO p_den_item
       FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = p_insumo_885.cod_item
     
         IF STATUS = 0 THEN
            DISPLAY BY NAME p_insumo_885.*
            DISPLAY p_den_item TO den_item
            RETURN TRUE
         ELSE
            CALL log003_err_sql('Lendo','item')
            RETURN FALSE
         END IF    
  ELSE
     CALL log003_err_sql('Lendo','insumo_885')
     RETURN FALSE
  END IF 
   
END FUNCTION


#-----------------------------------#
 FUNCTION pol0916_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_num_sequencia_ant = p_num_sequencia

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_num_sequencia
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_num_sequencia
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção"
            LET p_num_sequencia = p_num_sequencia_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      IF pol0916_exibe_dados() THEN
         EXIT WHILE
      END IF

   END WHILE

END FUNCTION

#-----------------------#
 FUNCTION pol0916_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#



