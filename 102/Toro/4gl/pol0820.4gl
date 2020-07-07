#-----------------------------------------------------------------------#
# PROGRAMA: POL0820                                                     #
# OBJETIVO: TRANSFERENCIAS PENDENTES NO COLETOR POR USUARIO             #
# AUTOR...: POLO INFORMATICA - BRUNO                                    #
# DATA....: 20/06/2008                                                  #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_usuario2       LIKE etiq_coletada_912.cod_usuario,
          p_msg                CHAR(300),
          p_lin_imp            SMALLINT,
          p_salto              SMALLINT,
          p_num_ordem          INTEGER,       
          p_ies_cons           SMALLINT,
          p_rowid              INTEGER,
          sql_stmt             CHAR(500),
          where_clause         CHAR(300),  
          p_count              INTEGER,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_status             SMALLINT,
          p_sobe               DECIMAL(1,0),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_tela2          CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_qtd_estoque        INTEGER, 
          p_caminho            CHAR(080)

   DEFINE p_cabec              RECORD
          cod_usuario2           LIKE etiq_coletada_912.cod_usuario

   END RECORD

   DEFINE pr_item              ARRAY[300] OF RECORD
          cod_usuario          LIKE etiq_coletada_912.cod_usuario,
          cod_item             LIKE item_barra.cod_item,
          denominacao          LIKE item.den_item,
          qtd_pend             SMALLINT,
          qtd_estoque          SMALLINT
   END RECORD

   DEFINE p_etiq_coletada_912  RECORD LIKE etiq_coletada_912.*
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0819-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0820.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0820_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0820_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0820") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0820 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
      MENU "OPCAO"
      COMMAND 'Consultar' 'Consulta as auditorias gravadas'
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
            CALL pol0820_consultar()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0820_sobre() 
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0820

END FUNCTION

#-----------------------#
FUNCTION pol0820_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
 FUNCTION pol0820_consultar()
#---------------------------#

   CLEAR FORM 
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE pr_item TO NULL

   INITIALIZE p_cabec.cod_usuario2 TO NULL


   INPUT BY NAME p_cabec.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_usuario2
         INITIALIZE p_cabec.cod_usuario2 TO NULL
                
      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            
             IF p_cabec.cod_usuario2 IS NULL THEN  
              SELECT COUNT (a.cod_usuario)
              INTO   p_count
              FROM   etiq_coletada_912 a, item_barra b, item c
              WHERE  a.cod_empresa=b.cod_empresa
              AND    a.cod_item_cliente=b.cod_item_barra_ser
              AND    a.ies_situacao='E'
              AND    a.cod_empresa=c.cod_empresa
              AND    b.cod_item=c.cod_item
              AND    b.cod_empresa= p_cod_empresa
            ELSE
              SELECT COUNT (a.cod_usuario)
              INTO   p_count
              FROM   etiq_coletada_912 a, item_barra b, item c
              WHERE  a.cod_empresa=b.cod_empresa
              AND    a.cod_item_cliente = b.cod_item_barra_ser
              AND    a.ies_situacao='E'
              AND    a.cod_empresa=c.cod_empresa
              AND    b.cod_item=c.cod_item
              AND    b.cod_empresa= p_cod_empresa
              AND    a.cod_usuario= p_cabec.cod_usuario2
            END IF 
                                    
            IF STATUS <> 0 THEN
               CALL log003_err_sql("LEITURA","etiq_coletada_912")
               LET INT_FLAG = TRUE
            ELSE
               IF p_count = 0 THEN
                  ERROR 'Não existem registros a serem listados!'
                  NEXT FIELD cod_usuario2
               END IF
            END IF
            
         END IF
                     
   END INPUT

   IF NOT pol0820_carrega_dados() THEN
      RETURN
   END IF
   
   IF p_count > 11 THEN
      DISPLAY ARRAY pr_item TO  sr_item.* 
   ELSE
      INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0820_carrega_dados()
#---------------------------------#

   DEFINE p_opcao CHAR(01)
   
   LET p_index = 1

    IF p_cabec.cod_usuario2 IS NOT NULL THEN
      LET sql_stmt = 
          "SELECT a.cod_usuario, b.cod_item, c.den_item[1,35] as denominacao,sum(qtd_pecas) as qtd_pend, 0 ",
          "FROM etiq_coletada_912 a, item_barra b, item c ",
          "WHERE  a.cod_empresa = b.cod_empresa ",
          "AND    a.cod_item_cliente = b.cod_item_barra_ser ",
          "AND    a.ies_situacao= 'E' ",
          "AND    a.cod_empresa = c.cod_empresa ",
          "AND    b.cod_item = c.cod_item ",
          "AND    b.cod_empresa = '",p_cod_empresa,"' ",
          "AND    a.cod_usuario = '",p_cabec.cod_usuario2,"' ",
          "GROUP BY 1, 2, 3 ",
          "ORDER BY 1, 2 "
           
   ELSE  
    
        
      LET sql_stmt = 
          "SELECT a.cod_usuario, b.cod_item, c.den_item[1,35] as denominacao,sum(qtd_pecas) as qtd_pend, 0 ",
          "FROM etiq_coletada_912 a, item_barra b, item c ",
          "WHERE  a.cod_empresa = b.cod_empresa ",
          "AND    a.cod_item_cliente = b.cod_item_barra_ser ",
          "AND    a.ies_situacao= 'E' ",
          "AND    a.cod_empresa = c.cod_empresa ",
          "AND    b.cod_item = c.cod_item ",
          "AND    b.cod_empresa = '",p_cod_empresa,"' ",
          "GROUP BY 1, 2, 3 ",
          "ORDER BY 1, 2 "
           
   END IF 
 
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","etiq_coletada_912")
      RETURN FALSE
   END IF

   PREPARE var_query FROM sql_stmt      
   DECLARE cq_op CURSOR FOR var_query
   FOREACH cq_op INTO pr_item[p_index].*
 
     INITIALIZE p_qtd_estoque TO NULL 
     
     SELECT SUM(qtd_saldo)
     INTO   p_qtd_estoque 
     FROM estoque_lote
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = pr_item[p_index].cod_item 
       AND ies_situa_qtd = 'L' 
       AND cod_local IN (SELECT cod_local_estoq 
                           FROM item 
                          WHERE cod_empresa = p_cod_empresa
                            AND cod_item    = pr_item[p_index].cod_item)
                            
     LET pr_item[p_index].qtd_estoque =   p_qtd_estoque
     LET p_index = p_index + 1
      IF p_index > 1000 THEN
         ERROR 'Limite de linhas ultrapassado!'
         EXIT FOREACH
      END IF
      
   END FOREACH
    
   CALL SET_COUNT(p_index - 1)

   RETURN TRUE
   
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
