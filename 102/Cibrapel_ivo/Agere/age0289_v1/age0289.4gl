#---------------------------------------------------------------------------#
# SISTEMA.: ESPECIFICO                                                      #
# PROGRAMA: AGE0289                                                         #
# OBJETIVO: RELATORIO DE COMISSAO DOS VENDEDORES                            #
# CLIENTE : CIBRAPEL                                                        #
# AUTOR...: RODRIGO SMANIA CIA                                              #
# DATA....: 09/12/2013                                                      #
#---------------------------------------------------------------------------#
DATABASE logix

GLOBALS
                                                                                           
   DEFINE p_den_empresa           LIKE empresa.den_empresa,
          p_cod_empresa           LIKE empresa.cod_empresa,
          p_user                  LIKE usuario.nom_usuario,
          p_cancel                SMALLINT,
          p_status                SMALLINT,
          comando                 CHAR(80),
          p_caminho               CHAR(80),
          p_nom_arquivo           CHAR(100),
          p_ies_impressao         CHAR(01),
          p_val_cliche            LIKE nf_item.val_liq_item,
          p_pct_max_cliche        LIKE par_vdp_885.pct_max_cliche,
          p_i                     INTEGER, 
          g_ies_ambiente          CHAR(01),
          g_ies_grafico           SMALLINT,
          p_versao                CHAR(18),
          g_pais                  CHAR(02),
          sql_stmt                CHAR(5000),
          p_total_credito         DECIMAL(15,2),
          p_total_debito          DECIMAL(15,2),
          p_last_row              SMALLINT,
          p_nf_mestre             RECORD LIKE nf_mestre.*,
          p_nf_item               RECORD LIKE nf_item.*

   DEFINE p_tela         RECORD
          cod_empresa    LIKE nf_mestre.cod_empresa,  
          cod_item       LIKE item.cod_item,  
          den_item       LIKE item.den_item,  
          val_cliche     LIKE nf_item.val_liq_item,     
          val_fat_tot    LIKE nf_item.val_liq_item
                     END RECORD 	
                                                                                           
END GLOBALS

    DEFINE  m_caminho             CHAR(80),
            m_comando             CHAR(80),
            m_last_row            SMALLINT
                                 
    DEFINE m_filtros              RECORD 
                                  dat_de      DATE,
                                  dat_ate     DATE,
                                  ies_repres  CHAR(01)
                                  END RECORD
                                                                                           
    DEFINE  m_consulta_ativa      SMALLINT, 
            m_houve_erro          SMALLINT
                  
MAIN                                                                                       
                                                                                           
  LET p_versao = "AGE0289-10.02.10" #Favor nao alterar esta linha (SUPORTE)                
      WHENEVER ERROR CONTINUE                                                              
      CALL log1400_isolation()                                                             
      WHENEVER ERROR STOP                                                                  
                                                                                           
    DEFER INTERRUPT        
                                                                  
    CALL log140_procura_caminho("age0289.iem") RETURNING comando
    
    OPTIONS                                                                                
      FIELD    ORDER UNCONSTRAINED,                                                        
      HELP     FILE  comando,
      HELP     KEY   control-w,
      NEXT     KEY   control-f,
      PREVIOUS KEY   control-b
                                                                                           
 INITIALIZE p_cod_empresa, p_user, p_status, comando, p_nom_arquivo TO NULL
                                                                                           
  CALL log001_acessa_usuario("VDP", "LOGERP")
       RETURNING p_status, p_cod_empresa, p_user
       
  LET p_user = 'admlog'
  LET p_status = 0
  
  IF p_status = 0  THEN
     CALL age0289_controle()
  END IF                                                                                
                                                                     

END MAIN

#---------------------------#
 FUNCTION age0289_controle()
#---------------------------#
   
   DEFINE l_nom_tela CHAR(80)
   
   LET m_houve_erro     = FALSE

   CALL log006_exibe_teclas("01", p_versao)  
   CALL log130_procura_caminho("age0289") RETURNING l_nom_tela   
   OPEN WINDOW w_age0289 AT 2,2 WITH FORM l_nom_tela
   ATTRIBUTE (BORDER,MESSAGE LINE LAST,PROMPT LINE LAST)
            
            
   MENU "Op��o"
   
      COMMAND "Informar" "Informar os filtros a serem processados"
       HELP 001
       MESSAGE ' '
       CLEAR FORM
       CALL age0289_informar()    
       NEXT OPTION "Processar"  
       
      
      COMMAND "Processar" "Processar a extra��o dos dados"
       IF m_consulta_ativa = TRUE THEN 
          IF age0289_processar() THEN
             MESSAGE " Processando concluido ... " 
          END IF 
       ELSE
          ERROR ' Informe os parametros antes de Processar! '
       END IF
       
      
      COMMAND "Fim" "Retorna ao Menu Anterior."
       HELP 003     
       EXIT MENU
       
  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)
    
   END MENU
   
   CLOSE WINDOW w_age0289

END FUNCTION

#---------------------------#
 FUNCTION age0289_informar()
#---------------------------#
   
   IF age0289_entrada_dados() THEN
      LET m_consulta_ativa = TRUE
   ELSE 
      LET m_consulta_ativa = FALSE
   END IF

END FUNCTION


#--------------------------------#
 FUNCTION age0289_entrada_dados()    
#--------------------------------#

   LET int_flag = FALSE
   
   INITIALIZE m_filtros.* TO NULL
   LET m_filtros.dat_de         = TODAY
   LET m_filtros.dat_ate        = TODAY
   LET m_filtros.ies_repres     = "S"
       
   WHENEVER ERROR CONTINUE
     DELETE FROM cre0270_repres
      WHERE nom_usuario = p_user
   WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("DELETE","CRE0270_REPRES")
    END IF
                     
   INPUT m_filtros.dat_de,
         m_filtros.dat_ate,
         m_filtros.ies_repres
          WITHOUT DEFAULTS
          FROM dat_de,     
               dat_ate,    
               ies_repres
               
      AFTER FIELD dat_de
         IF m_filtros.dat_de IS NULL THEN
            ERROR ' Informe a data inicio '
            NEXT FIELD dat_de
         END IF
         
      AFTER FIELD dat_ate
         IF m_filtros.dat_ate IS NULL THEN
            ERROR ' Informe a data final '
            NEXT FIELD dat_ate
         END IF               
               
      
      AFTER FIELD ies_repres
         IF m_filtros.ies_repres = "N" THEN
            CALL log006_exibe_teclas("01 02 03 05 06 07",p_versao)
            CURRENT WINDOW IS w_age0289
            IF   cre027_gerencia_entrada_dados(7, 48,p_user, "age0289", "REPRESENTANTES") = FALSE
            THEN CALL log006_exibe_teclas("01",p_versao)
                 CURRENT WINDOW IS w_age0289
                 LET m_filtros.ies_repres = "S"
                 DISPLAY BY NAME m_filtros.ies_repres
            ELSE CALL log006_exibe_teclas("01",p_versao)
                 CURRENT WINDOW IS w_age0289
            END IF
         END IF
               
   END INPUT 
       
   IF int_flag = 0 THEN
      RETURN TRUE
   ELSE
      LET int_flag = 0
      RETURN FALSE
   END IF
 
END FUNCTION


#----------------------------#
 FUNCTION age0289_processar()
#----------------------------#

   DEFINE l_cod_lin_prod DECIMAL(2,0)
   DEFINE l_num_nff_origem DECIMAL(6,0)
   DEFINE l_num_sequencia DECIMAL(5,0)
   DEFINE l_cod_item CHAR(15)
   DEFINE l_val_saldo,
          l_val_devolucao  LIKE nf_item.val_liq_item
   
   DEFINE lr_comissoes RECORD
                       tipo               CHAR(10),
                       cod_empresa        CHAR(02),
                       cod_repres         DECIMAL(4,0),
                       raz_social         CHAR(26),
                       num_nff            DECIMAL(6,0),
                       num_pedido         DECIMAL(6,0),
                       dat_emissao        DATE,
                       cod_item           CHAR(15),
                       den_item           CHAR(20),
                       cod_cliente        CHAR(15),
                       nom_cliente        CHAR(25),
                       val_liq_item       DECIMAL(15,2),
                       comissao           CHAR(09),
                       val_comissao       DECIMAL(15,2),
                       ies_retido         CHAR(01)
                       END RECORD

   MESSAGE " Processando ... " 
   
   DELETE FROM t_age0289
   
   LET sql_stmt = "select a.cod_empresa,a.cod_repres, d.raz_social, a.num_nff,",
                  "       b.num_pedido,a.dat_emissao,b.cod_item,c.den_item, ",
                  "       a.cod_cliente, e.nom_cliente, b.val_liq_item,a.val_tot_mercadoria",
                  "  from nf_mestre a, nf_item b, item c, representante d, clientes e",
                  " where a.cod_empresa = '",p_cod_empresa,"'",
                  "   and a.ies_situacao='N' ",
                  "   and a.cod_nat_oper <> ('416') ",
                  "   and a.cod_nat_oper <> '418' ",
                  "   and a.cod_nat_oper <> '421' ",
                  "   and a.cod_nat_oper <> '406' ",
                  "   and a.cod_nat_oper <> '414' ",
                  "   and a.cod_nat_oper <> '438'",
                  "   and a.cod_empresa=b.cod_empresa",
                  "   and a.num_nff=b.num_nff",
                  "   and b.cod_empresa=c.cod_empresa",
                  "   and b.cod_item=c.cod_item",
                  "   AND a.cod_repres = d.cod_repres",
                  "   AND a.cod_cliente = e.cod_cliente"
                  
   
   IF m_filtros.ies_repres = 'S' THEN 
      LET sql_stmt = sql_stmt CLIPPED, " AND a.cod_repres IN(SELECT cod_repres FROM representante) "
   ELSE
      LET sql_stmt = sql_stmt CLIPPED, " AND a.cod_repres IN(SELECT cod_repres FROM cre0270_repres",
                                       "                      WHERE nom_usuario = '",p_user,"' ",
                                       "                        AND cod_programa = 'age0289' ) "
   END IF


   LET sql_stmt = sql_stmt CLIPPED, "   AND a.dat_emissao >= '",m_filtros.dat_de,"' ",
                                    "   AND a.dat_emissao <= '",m_filtros.dat_ate,"' "

   WHENEVER ERROR CONTINUE
   PREPARE var_query FROM sql_stmt
   WHENEVER ERROR STOP  
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql_detalhe("PREPARE SQL","var_query",sql_stmt)
      RETURN FALSE
   END IF
   
   DECLARE cq_comissao CURSOR FOR var_query
   FOREACH cq_comissao INTO lr_comissoes.cod_empresa       ,
                            lr_comissoes.cod_repres        ,
                            lr_comissoes.raz_social        ,
                            lr_comissoes.num_nff           ,
                            lr_comissoes.num_pedido        ,
                            lr_comissoes.dat_emissao       ,
                            lr_comissoes.cod_item          ,
                            lr_comissoes.den_item          ,
                            lr_comissoes.cod_cliente       ,
                            lr_comissoes.nom_cliente       ,
                            lr_comissoes.val_liq_item      
      
      LET lr_comissoes.tipo = 'VENDA'
      
      INITIALIZE l_cod_lin_prod TO NULL
      SELECT cod_lin_prod
        INTO l_cod_lin_prod
        FROM item
       WHERE cod_empresa = lr_comissoes.cod_empresa
         AND cod_item = lr_comissoes.cod_item
         
      IF l_cod_lin_prod = 1 THEN 
         LET lr_comissoes.comissao = '     2,50' #CHAPA
         LET lr_comissoes.val_comissao = (lr_comissoes.val_liq_item * 2.5) / 100
      ELSE 
         LET lr_comissoes.comissao = '     2,00' #CAIXA
         LET lr_comissoes.val_comissao = (lr_comissoes.val_liq_item * 2) / 100
      END IF
      
      SELECT UNIQUE 1
        FROM custo_cliche_885
       WHERE cod_item = lr_comissoes.cod_item
         AND saldo_cliche > 0
      IF sqlca.sqlcode = 100 THEN
         LET lr_comissoes.ies_retido = ' '
      ELSE
      
         SELECT val_cliche 
           INTO p_val_cliche
           FROM custo_cliche_885                 
          WHERE cod_item  = lr_comissoes.cod_item
         
         LET p_tela.val_cliche =  p_val_cliche
         SELECT pct_max_cliche
           INTO p_pct_max_cliche 
           FROM par_vdp_885
          WHERE cod_empresa = 'O1'
         LET p_tela.val_fat_tot =   p_val_cliche / (p_pct_max_cliche/100)
      
         DECLARE c_notas CURSOR FOR
         SELECT a.num_nff,a.dat_emissao,SUM(b.val_liq_item) 
           FROM nf_mestre a,nf_item b
          WHERE a.cod_empresa = lr_comissoes.cod_empresa
            AND b.cod_item = lr_comissoes.cod_item
            AND a.cod_empresa = b.cod_empresa
            AND a.num_nff     = b.num_nff
            AND a.ies_situacao = 'N' 
          GROUP BY a.num_nff,a.dat_emissao   
         
         LET p_i = 1
         FOREACH c_notas INTO p_nf_mestre.num_nff,p_nf_mestre.dat_emissao,p_nf_item.val_liq_item
         
            IF p_i = 1 THEN 
               LET l_val_saldo = p_tela.val_fat_tot - p_nf_item.val_liq_item
            ELSE
               LET l_val_saldo = l_val_saldo - p_nf_item.val_liq_item
            END IF    
         
            LET p_i = p_i + 1
         END FOREACH
         
         {IF lr_comissoes.val_liq_item > l_val_saldo THEN
            LET lr_comissoes.ies_retido = ' '
         ELSE
            LET lr_comissoes.ies_retido = 'R'
            LET lr_comissoes.tipo = 'RETIDO'
         END IF }
         
         IF l_val_saldo > 0 THEN
            LET lr_comissoes.ies_retido = 'R'
            LET lr_comissoes.tipo = 'RETIDO'
         ELSE
            LET lr_comissoes.ies_retido = ' '
         END IF
      
      END IF 
                            
      INSERT INTO t_age0289 VALUES(lr_comissoes.*)
   
   END FOREACH        
        
   
   
   ### DEVOLUCAO - ini

   LET sql_stmt = "SELECT a.num_nff_origem, b.num_sequencia, b.cod_item, (qtd_item*pre_unit)",
                  "  FROM dev_mestre a, dev_item b",
                  " WHERE a.cod_empresa = '",p_cod_empresa,"'",
                  "   AND a.cod_empresa = b.cod_empresa ",
                  "   AND a.num_nff = b.num_nff ",
                  "   AND a.dat_lancamento >= '",m_filtros.dat_de,"' ",
                  "   AND a.dat_lancamento <= '",m_filtros.dat_ate,"' "
                                    
   IF m_filtros.ies_repres = 'S' THEN 
      LET sql_stmt = sql_stmt CLIPPED, " AND a.cod_repres IN(SELECT cod_repres FROM representante) "
   ELSE
      LET sql_stmt = sql_stmt CLIPPED, " AND a.cod_repres IN(SELECT cod_repres FROM cre0270_repres",
                                       "                      WHERE nom_usuario = '",p_user,"' ",
                                       "                        AND cod_programa = 'age0289' ) "
   END IF
   
   WHENEVER ERROR CONTINUE
   PREPARE var_query3 FROM sql_stmt
   WHENEVER ERROR STOP  
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql_detalhe("PREPARE SQL","var_query3",sql_stmt)
      RETURN FALSE
   END IF
   
   DECLARE cq_dev CURSOR FOR var_query3
   FOREACH cq_dev INTO l_num_nff_origem, l_num_sequencia, l_cod_item, l_val_devolucao
   
   

      LET sql_stmt = "select a.cod_empresa,a.cod_repres, d.raz_social, a.num_nff,",
                     "       b.num_pedido,a.dat_emissao,b.cod_item,c.den_item, ",
                     "       a.cod_cliente, e.nom_cliente, b.val_liq_item,a.val_tot_mercadoria",
                     "  from nf_mestre a, nf_item b, item c, representante d, clientes e",
                     " where a.cod_empresa = '",p_cod_empresa,"'",
                     "   and a.num_nff = ",l_num_nff_origem,
                     "   and b.num_sequencia = ",l_num_sequencia,
                     "   and b.cod_item = '",l_cod_item,"'",
                     "   and a.ies_situacao='N' ",
                     "   and a.cod_nat_oper <> ('416') ",
                     "   and a.cod_nat_oper <> '418' ",
                     "   and a.cod_nat_oper <> '421' ",
                     "   and a.cod_nat_oper <> '406' ",
                     "   and a.cod_nat_oper <> '414' ",
                     "   and a.cod_nat_oper <> '438'",
                     "   and a.cod_empresa=b.cod_empresa",
                     "   and a.num_nff=b.num_nff",
                     "   and b.cod_empresa=c.cod_empresa",
                     "   and b.cod_item=c.cod_item",
                     "   AND a.cod_repres = d.cod_repres",
                     "   AND a.cod_cliente = e.cod_cliente"
      
      WHENEVER ERROR CONTINUE
      PREPARE var_query2 FROM sql_stmt
      WHENEVER ERROR STOP  
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql_detalhe("PREPARE SQL","var_query",sql_stmt)
         RETURN FALSE
      END IF
      
      DECLARE cq_comissao CURSOR FOR var_query2
      FOREACH cq_comissao INTO lr_comissoes.cod_empresa       ,
                               lr_comissoes.cod_repres        ,
                               lr_comissoes.raz_social        ,
                               lr_comissoes.num_nff           ,
                               lr_comissoes.num_pedido        ,
                               lr_comissoes.dat_emissao       ,
                               lr_comissoes.cod_item          ,
                               lr_comissoes.den_item          ,
                               lr_comissoes.cod_cliente       ,
                               lr_comissoes.nom_cliente       ,
                               lr_comissoes.val_liq_item      
         
         LET lr_comissoes.tipo = 'DEVOLUCAO'
         
         LET lr_comissoes.val_liq_item = l_val_devolucao
         
         INITIALIZE l_cod_lin_prod TO NULL
         SELECT cod_lin_prod
           INTO l_cod_lin_prod
           FROM item
          WHERE cod_empresa = lr_comissoes.cod_empresa
            AND cod_item = lr_comissoes.cod_item
            
         IF l_cod_lin_prod = 1 THEN 
            LET lr_comissoes.comissao = '     2,50' #CHAPA
            LET lr_comissoes.val_comissao = (lr_comissoes.val_liq_item * 2.5) / 100
         ELSE 
            LET lr_comissoes.comissao = '     2,00' #CAIXA
            LET lr_comissoes.val_comissao = (lr_comissoes.val_liq_item * 2) / 100
         END IF 
                               
         INSERT INTO t_age0289 VALUES(lr_comissoes.*)
      
      END FOREACH           
      
   END FOREACH
   ### DEVOLUCAO - fim
   
   CALL age0289_relatorio()
   
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE 
   END IF                
  
END FUNCTION


#----------------------------#
 FUNCTION age0289_relatorio()
#----------------------------#

   DEFINE l_cod_repres_char CHAR(10)

   DEFINE lr_comissoes RECORD
                       tipo               CHAR(10),
                       cod_empresa        CHAR(02),
                       cod_repres         DECIMAL(4,0),
                       raz_social         CHAR(26),
                       num_nff            DECIMAL(6,0),
                       num_pedido         DECIMAL(6,0),
                       dat_emissao        DATE,
                       cod_item           CHAR(15),
                       den_item           CHAR(20),
                       cod_cliente        CHAR(15),
                       nom_cliente        CHAR(25),
                       val_liq_item       DECIMAL(15,2),
                       comissao           CHAR(09),
                       val_comissao       DECIMAL(15,2),
                       ies_retido         CHAR(01)
                       END RECORD                       
   DEFINE l_caminho          CHAR(200),
          l_caminho_pdf      CHAR(200)
   DEFINE l_cod_repres       DECIMAL(4,0)
   

   LET p_last_row = FALSE
   INITIALIZE p_nom_rel TO NULL
 
   IF   log0280_saida_relat(19,40) IS NOT NULL
   THEN ERROR " Processando a extracao do relatorio ... "
        IF   p_ies_impressao = "S"
        THEN IF   g_ies_ambiente = "U"
             THEN START REPORT age0289_relat TO PIPE p_nom_arquivo
             ELSE START REPORT age0289_relat TO PRINTER
             END IF
        ELSE START REPORT age0289_relat TO p_nom_arquivo
        END IF


      DECLARE cq_comissoes CURSOR FOR 
      SELECT tipo         ,
cod_empresa  ,
cod_repres   ,
raz_social   ,
num_nff      ,
num_pedido   ,
dat_emissao  ,
cod_item     ,
den_item     ,
cod_cliente  ,
nom_cliente  ,
val_liq_item ,
comissao     ,
val_comissao ,
ies_retido   
        FROM t_age0289
group by tipo         ,
cod_empresa  ,
cod_repres   ,
raz_social   ,
num_nff      ,
num_pedido   ,
dat_emissao  ,
cod_item     ,
den_item     ,
cod_cliente  ,
nom_cliente  ,
val_liq_item ,
comissao     ,
val_comissao ,
ies_retido   
       ORDER BY cod_repres, tipo DESC, comissao, num_nff
      FOREACH cq_comissoes INTO lr_comissoes.*
         OUTPUT TO REPORT age0289_relat(lr_comissoes.*)
      END FOREACH
      
      FINISH REPORT age0289_relat   
      
       ERROR " FIM do processamento "

       IF   p_ies_impressao = "S"
       THEN MESSAGE "Relatorio gravado com sucesso" ATTRIBUTE(REVERSE)
       ELSE MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo CLIPPED
               ATTRIBUTE(REVERSE)
       END IF
  END IF
      

END FUNCTION


#------------------------------#
 REPORT age0289_relat(lr_comissoes) 
#------------------------------#
   DEFINE l_val_tot_comissao,
          l_val_tot_comissao_cx_ch,
          l_val_tot_receb,
          l_val_tot_retido,
          l_val_tot_devolucao,
          l_val_tot_repres DECIMAL(15,2)
   DEFINE l_caixa_chapa CHAR(15)

   DEFINE lr_comissoes RECORD
                       tipo               CHAR(10),
                       cod_empresa        CHAR(02),
                       cod_repres         DECIMAL(4,0),
                       raz_social         CHAR(26),
                       num_nff            DECIMAL(6,0),
                       num_pedido         DECIMAL(6,0),
                       dat_emissao        DATE,
                       cod_item           CHAR(15),
                       den_item           CHAR(20),
                       cod_cliente        CHAR(15),
                       nom_cliente        CHAR(25),
                       val_liq_item       DECIMAL(15,2),
                       comissao           CHAR(09),
                       val_comissao       DECIMAL(15,2),
                       ies_retido         CHAR(01)
                       END RECORD

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 66
   FORMAT
   PAGE HEADER
   
      PRINT log5211_retorna_configuracao(PAGENO,66,165) CLIPPED
      PRINT COLUMN 002, '-------------------------------------------------------------------------------------------------------------------------------------------'
      PRINT COLUMN 060, 'RELACAO DE COMISSOES',
            COLUMN 131, TODAY USING 'dd/mm/yyyy'
      PRINT COLUMN 133, TIME

   BEFORE GROUP OF lr_comissoes.cod_repres
      PRINT COLUMN 002, 'Vendedor: ',lr_comissoes.cod_repres, ' - ', lr_comissoes.raz_social CLIPPED,
            COLUMN 109, 'Periodo: ', m_filtros.dat_de ,' a ', m_filtros.dat_ate
   
   BEFORE GROUP OF lr_comissoes.tipo
      PRINT 
      PRINT COLUMN 002, '* ',lr_comissoes.tipo CLIPPED, ' *'
      PRINT 
      
   BEFORE GROUP OF lr_comissoes.comissao
      IF lr_comissoes.comissao = '     2,50' THEN
         LET l_caixa_chapa = 'Caixas'
      ELSE
         LET l_caixa_chapa = 'Chapas'
      END IF 
      
      IF lr_comissoes.tipo = 'VENDA' THEN   
         PRINT COLUMN 002, '[ ',l_caixa_chapa CLIPPED,' ]'
      ELSE
         #PRINT
      END IF 
      PRINT 
      PRINT COLUMN 002, '--------- --------- ---------- --------------- -------------------- ------------------------- ----------------- --------- -----------------'
      PRINT COLUMN 002, 'NUM.NF    PEDIDO    EMISSAO    ITEM            DESCRICAO            CLIENTE                             VAL.NFF %COMISSAO      VAL.COMISSAO'
      PRINT COLUMN 002, '--------- --------- ---------- --------------- -------------------- ------------------------- ----------------- --------- -----------------'
   
   ON EVERY ROW
      
      PRINT COLUMN 002, lr_comissoes.num_nff USING '<<<<<<<<<',
            COLUMN 012, lr_comissoes.num_pedido USING '<<<<<<<<<',
            COLUMN 022, lr_comissoes.dat_emissao,
            COLUMN 033, lr_comissoes.cod_item,
            COLUMN 049, lr_comissoes.den_item,
            COLUMN 070, lr_comissoes.nom_cliente,
            COLUMN 096, lr_comissoes.val_liq_item,
            COLUMN 114, lr_comissoes.comissao,
            COLUMN 124, lr_comissoes.val_comissao, ' ', lr_comissoes.ies_retido

   AFTER GROUP OF lr_comissoes.comissao
      SELECT SUM(val_comissao)
        INTO l_val_tot_comissao_cx_ch
        FROM t_age0289
       WHERE cod_empresa = lr_comissoes.cod_empresa
         AND cod_repres = lr_comissoes.cod_repres
         AND tipo = lr_comissoes.tipo
         AND comissao = lr_comissoes.comissao


      IF lr_comissoes.tipo = 'VENDA' THEN   
         PRINT 
         PRINT COLUMN 106, 'Total ',l_caixa_chapa CLIPPED,':',
               COLUMN 124, l_val_tot_comissao_cx_ch
      END IF 


   AFTER GROUP OF lr_comissoes.tipo
      PRINT 
      
      SELECT SUM(val_comissao)
        INTO l_val_tot_comissao 
        FROM t_age0289
       WHERE cod_empresa = lr_comissoes.cod_empresa
         AND cod_repres = lr_comissoes.cod_repres
         AND tipo = lr_comissoes.tipo
      
      PRINT COLUMN 093, 'TOTAL ',lr_comissoes.tipo CLIPPED,' REPRESENTANTE:',
            COLUMN 124, l_val_tot_comissao

   AFTER GROUP OF lr_comissoes.cod_repres       
      PRINT 
      
      SELECT SUM(NVL(val_comissao,0))
        INTO l_val_tot_receb
        FROM t_age0289
       WHERE cod_empresa = lr_comissoes.cod_empresa
         AND cod_repres = lr_comissoes.cod_repres
         AND tipo = 'VENDA'
         
         IF l_val_tot_receb IS NULL THEN
            LET l_val_tot_receb = 0
         END IF 
         
      SELECT SUM(NVL(val_comissao,0))
        INTO l_val_tot_retido
        FROM t_age0289
       WHERE cod_empresa = lr_comissoes.cod_empresa
         AND cod_repres = lr_comissoes.cod_repres
         AND tipo = 'RETIDO'
         
      IF l_val_tot_retido IS NULL THEN
         LET l_val_tot_retido = 0
      END IF 
         
      SELECT SUM(NVL(val_comissao,0))
        INTO l_val_tot_devolucao
        FROM t_age0289
       WHERE cod_empresa = lr_comissoes.cod_empresa
         AND cod_repres = lr_comissoes.cod_repres
         AND tipo = 'DEVOLUCAO'
      
      IF l_val_tot_devolucao IS NULL THEN
         LET l_val_tot_devolucao = 0
      END IF 
         
      LET l_val_tot_repres = l_val_tot_receb - (l_val_tot_retido + l_val_tot_devolucao)
      
      PRINT COLUMN 094, 'TOTAL COMISSAO REPRESENTANTE:',
            COLUMN 124, l_val_tot_repres
      SKIP TO TOP OF PAGE 
                   

END REPORT


{
CREATE TABLE t_age0289(
tipo char(10),
cod_empresa        CHAR(02),
                       cod_repres         DECIMAL(4,0),
                       raz_social         CHAR(26),
                       num_nff            DECIMAL(6,0),
                       num_pedido         DECIMAL(6,0),
                       dat_emissao        DATETIME,
                       cod_item           CHAR(15),
                       den_item           CHAR(20),
                       cod_cliente        CHAR(15),
                       nom_cliente        CHAR(25),
                       val_liq_item       DECIMAL(15,2),
                       comissao           char(09),
                       val_comissao       DECIMAL(15,2),
                       ies_retido         char(01));
}