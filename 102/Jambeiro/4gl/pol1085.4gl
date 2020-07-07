#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1085                                                 #
# OBJETIVO: CONSULTA DEMANDA DE PEDIDOS                             #
# AUTOR...: PAULO CESAR MARTINEZ                                    #
# DATA....: 15/02/2011                                              #
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
          p_msg                CHAR(500),
          p_last_row           SMALLINT
          
   DEFINE p_ped_dem_5000  RECORD 
          num_projeto          LIKE ped_dem_5000.num_projeto,
          num_pedido           LIKE ped_dem_5000.num_pedido,
          num_seq              LIKE ped_dem_5000.num_seq,
          cod_item_pai         LIKE ped_dem_5000.cod_item_pai,
          num_op_pai           LIKE ped_dem_5000.num_op_pai,
          prz_entrega          DATE,
          qtd_saldo            LIKE ped_dem_5000.qtd_saldo
   END RECORD         

   DEFINE p_num_sequencia      LIKE ped_dem_5000.num_seq,
          p_num_sequencia_ant  LIKE ped_dem_5000.num_seq,
          p_num_pedido         LIKE ped_dem_5000.num_pedido,
          p_num_pedido_ant     LIKE ped_dem_5000.num_pedido
           

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1085-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1085_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1085_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1085") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1085 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
   CALL pol1085_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela"
         CALL pol1085_consulta() RETURNING p_status
         IF p_status THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'Operação cancelada'
         END IF
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1085_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1085_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				 CALL pol1085_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1085

END FUNCTION



#--------------------------#
 FUNCTION pol1085_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  
 
   CALL pol1085_limpa_tela()
   LET p_num_sequencia_ant = p_num_sequencia
   LET p_num_pedido_ant = p_num_pedido
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      ped_dem_5000.num_projeto,
      ped_dem_5000.num_pedido,
      ped_dem_5000.num_seq,
      ped_dem_5000.cod_item_pai,
      ped_dem_5000.num_op_pai,
      ped_dem_5000.prz_entrega,
      ped_dem_5000.qtd_saldo
    
   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_num_sequencia = p_num_sequencia_ant   
         LET p_num_pedido = p_num_pedido_ant   
         CALL pol1085_exibe_dados() RETURNING p_status
      ELSE
         CALL pol1085_limpa_tela()
      END IF
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT num_pedido, num_seq ",
                  "  FROM ped_dem_5000 ",
                  " WHERE cod_empresa = '",p_cod_empresa,"' ",
                  " AND ", where_clause CLIPPED,
                  " ORDER BY num_pedido, num_seq"

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_num_pedido, p_num_sequencia

   IF STATUS = 0 THEN
      IF pol1085_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   ELSE   
      IF STATUS = 100 THEN
         CALL log0030_mensagem("Argumentos de pesquisa não encontrados!","excla")
      ELSE
         CALL log003_err_sql('Lendo','revisao_hist_1040')
      END IF
   END IF
   
   CALL pol1085_limpa_tela()
   
   LET p_ies_cons = FALSE
   
   RETURN FALSE 
 
END FUNCTION

#------------------------------#
 FUNCTION pol1085_exibe_dados()
#------------------------------#

  SELECT num_projeto,
         num_pedido,
         num_seq,
         cod_item_pai,
         num_op_pai,
         EXTEND(prz_entrega, YEAR TO DAY),       
         qtd_saldo
    INTO p_ped_dem_5000.*
    FROM ped_dem_5000
   WHERE cod_empresa = p_cod_empresa
     AND num_seq     = p_num_sequencia
     AND num_pedido  = p_num_pedido
     

   IF STATUS = 0 THEN
      DISPLAY BY NAME p_ped_dem_5000.*
      RETURN TRUE
   ELSE
      CALL log003_err_sql('lendo','ped_dem_5000')
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol1085_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_num_sequencia_ant = p_num_sequencia
   LET p_num_pedido_ant = p_num_pedido

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_num_pedido, p_num_sequencia
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_num_pedido, p_num_sequencia
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção"
            LET p_num_sequencia = p_num_sequencia_ant
            LET p_num_pedido    = p_num_pedido_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      IF pol1085_exibe_dados() THEN
         EXIT WHILE
      END IF

   END WHILE

END FUNCTION

#---------------------------#
FUNCTION pol1085_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-----------------------#
 FUNCTION pol1085_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#



