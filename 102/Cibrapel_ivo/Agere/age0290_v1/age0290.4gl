#---------------------------------------------------------------------------#
# SISTEMA.: ESPECIFICO                                                      #
# PROGRAMA: AGE0290                                                         #
# OBJETIVO: RELATORIO DE CLICHES E SALDOS PARA LIBERACAO DE COMISSOES       #
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
          p_empresas_885          RECORD LIKE empresas_885.*,
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
            m_last_row            SMALLINT,
            m_funcao              CHAR(01)
                                 
    DEFINE m_filtros              RECORD 
                                  cod_repres DECIMAL(4,0),
                                  raz_social CHAR(50),
                                  cod_item   CHAR(41),
                                  den_item   CHAR(30)
                                  END RECORD
                                                                                           
    DEFINE  m_consulta_ativa      SMALLINT, 
            m_houve_erro          SMALLINT
                  
MAIN                                                                                       
                                                                                           
  LET p_versao = "AGE0290-10.02.01" #Favor nao alterar esta linha (SUPORTE)                
      WHENEVER ERROR CONTINUE                                                              
      CALL log1400_isolation()                                                             
      WHENEVER ERROR STOP                                                                  
                                                                                           
    DEFER INTERRUPT        
                                                                  
    CALL log140_procura_caminho("age0290.iem") RETURNING comando
    
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
     CALL age0290_controle()
  END IF                                                                                
                                                                     

END MAIN

#---------------------------#
 FUNCTION age0290_controle()
#---------------------------#
   
   DEFINE l_nom_tela CHAR(80)
   
   LET m_houve_erro     = FALSE

   CALL log006_exibe_teclas("01", p_versao)  
   CALL log130_procura_caminho("age0290") RETURNING l_nom_tela   
   OPEN WINDOW w_age0290 AT 2,2 WITH FORM l_nom_tela
   ATTRIBUTE (BORDER,MESSAGE LINE LAST,PROMPT LINE LAST)
            
   INITIALIZE p_empresas_885.* TO NULL
   
    SELECT * 
      INTO p_empresas_885.*		
      FROM empresas_885 
     WHERE cod_emp_oficial = p_cod_empresa
    IF SQLCA.sqlcode <> 0 THEN  
       SELECT * 
         INTO p_empresas_885.*		
         FROM empresas_885 
        WHERE cod_emp_gerencial = p_cod_empresa
       IF SQLCA.sqlcode = 0 THEN  
       END IF 
    ELSE
    END IF 
            
   MENU "Op��o"
   
      COMMAND "Informar" "Informar os filtros a serem processados"
       HELP 001
       MESSAGE ' '
       CLEAR FORM
       CALL age0290_informar()    
       NEXT OPTION "Processar"  
       
      
      COMMAND "Processar" "Processar a extra��o dos dados"
       IF m_consulta_ativa = TRUE THEN 
          IF age0290_relatorio() THEN
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
   
   CLOSE WINDOW w_age0290

END FUNCTION

#---------------------------#
 FUNCTION age0290_informar()
#---------------------------#
   
   IF age0290_entrada_dados() THEN
      LET m_consulta_ativa = TRUE
   ELSE 
      LET m_consulta_ativa = FALSE
   END IF

END FUNCTION


#--------------------------------#
 FUNCTION age0290_entrada_dados()    
#--------------------------------#

   LET int_flag = FALSE
   
   INITIALIZE m_filtros.* TO NULL
   
   INITIALIZE m_funcao TO NULL 
                            
   INPUT m_filtros.cod_repres,
         m_filtros.cod_item
          WITHOUT DEFAULTS
          FROM cod_repres,     
               cod_item
               
      AFTER FIELD cod_repres
         IF m_filtros.cod_repres IS NOT NULL THEN
            SELECT raz_social
              INTO m_filtros.raz_social
              FROM representante
             WHERE cod_repres = m_filtros.cod_repres
             
            IF sqlca.sqlcode <> 0 THEN
               ERROR ' Vendedor nao encontrado! '
               NEXT FIELD cod_repres
            END IF 
         
            DISPLAY BY NAME m_filtros.raz_social
            
            LET m_funcao = 'R'
            
            EXIT INPUT 
         END IF 
        
      AFTER FIELD cod_item
         IF m_filtros.cod_repres IS NULL AND m_filtros.cod_item IS NULL THEN
            ERROR ' Informe o Vendedor ou o Item! '
            NEXT FIELD cod_repres
         END IF 
         
         IF m_filtros.cod_item IS NOT NULL THEN
            SELECT val_cliche 
              INTO p_val_cliche
              FROM custo_cliche_885                 
             WHERE cod_empresa = p_empresas_885.cod_emp_gerencial          
               AND cod_item  = m_filtros.cod_item
            IF SQLCA.SQLCODE <> 0 THEN
               ERROR "ITEM NAO POSSUI CLICHE" 
               NEXT FIELD cod_item
            END IF
            
            SELECT den_item
              INTO m_filtros.den_item
              FROM item
             WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
               AND cod_item = m_filtros.cod_item
               
               
            LET m_funcao = 'C'
            DISPLAY BY NAME m_filtros.den_item
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
 FUNCTION age0290_relatorio()
#----------------------------#
   DEFINE l_val_saldo DECIMAL(15,2)

   DEFINE lr_relat     RECORD
                       cod_repres         DECIMAL(4,0),
                       raz_social         CHAR(30),
                       cod_item           CHAR(15),
                       den_item           CHAR(20),
                       custo_cliche       DECIMAL(15,2),
                       valor_faturado     DECIMAL(15,2),
                       num_nff            DECIMAL(6,0),
                       dat_emissao        DATE,
                       val_liq_item       DECIMAL(15,2),
                       val_a_fat          DECIMAL(15,2)
                       END RECORD    

   DELETE FROM t_age0290
   
   IF m_funcao = 'R' THEN 
      DECLARE cq_itens CURSOR FOR 
      SELECT b.cod_item 
        FROM cliente_885 a, cliente_item b
       WHERE a.CodCliente = b.cod_cliente_matriz
         AND b.cod_empresa = p_empresas_885.cod_emp_gerencial
         AND a.CodRepresentante = m_filtros.cod_repres
      FOREACH cq_itens INTO m_filtros.cod_item
      
         SELECT val_cliche 
           INTO p_val_cliche
           FROM custo_cliche_885                 
          WHERE cod_empresa = p_empresas_885.cod_emp_gerencial          
            AND cod_item  = m_filtros.cod_item
            AND saldo_cliche > 0 
         IF sqlca.sqlcode <> 0 THEN
            CONTINUE FOREACH
         END IF 
         
         LET p_tela.val_cliche =  p_val_cliche
         SELECT pct_max_cliche
           INTO p_pct_max_cliche 
           FROM par_vdp_885
          WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
         LET p_tela.val_fat_tot =   p_val_cliche / (p_pct_max_cliche/100)   
      
         DECLARE c_notas CURSOR FOR
         SELECT a.num_nff,a.dat_emissao,SUM(b.val_liq_item)
           FROM nf_mestre a,nf_item b
          WHERE a.cod_empresa IN (p_empresas_885.cod_emp_gerencial, p_empresas_885.cod_emp_oficial)
            AND b.cod_item = m_filtros.cod_item
            AND a.cod_empresa = b.cod_empresa
            AND a.num_nff     = b.num_nff
            AND a.ies_situacao = 'N' 
          GROUP BY a.num_nff, a.dat_emissao
      
         LET p_i = 1
         FOREACH c_notas INTO p_nf_mestre.num_nff,p_nf_mestre.dat_emissao,p_nf_item.val_liq_item
         
            LET lr_relat.cod_item     = m_filtros.cod_item
            
            SELECT den_item
              INTO lr_relat.den_item
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item = lr_relat.cod_item
            
            LET lr_relat.custo_cliche   = p_val_cliche
            LET lr_relat.valor_faturado = p_tela.val_fat_tot
            LET lr_relat.num_nff        = p_nf_mestre.num_nff
            LET lr_relat.dat_emissao    = p_nf_mestre.dat_emissao
            LET lr_relat.val_liq_item   = p_nf_item.val_liq_item
            IF p_i = 1 THEN 
               LET lr_relat.val_a_fat = p_tela.val_fat_tot - p_nf_item.val_liq_item
               LET l_val_saldo = p_tela.val_fat_tot - p_nf_item.val_liq_item
            ELSE
               LET lr_relat.val_a_fat = l_val_saldo - p_nf_item.val_liq_item
               LET l_val_saldo = l_val_saldo - p_nf_item.val_liq_item
            END IF  
            
            LET lr_relat.cod_repres = m_filtros.cod_repres
            LET lr_relat.raz_social = m_filtros.raz_social
            
            INSERT INTO t_age0290 VALUES(lr_relat.*)  
         
            LET p_i = p_i + 1
         END FOREACH
      END FOREACH 
    
   ELSE
   
      LET p_tela.val_cliche =  p_val_cliche
      SELECT pct_max_cliche
        INTO p_pct_max_cliche 
        FROM par_vdp_885
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      LET p_tela.val_fat_tot =   p_val_cliche / (p_pct_max_cliche/100)   
   
      DECLARE c_notas CURSOR FOR
      SELECT a.num_nff,a.dat_emissao,SUM(b.val_liq_item) 
        FROM nf_mestre a,nf_item b
       WHERE a.cod_empresa IN (p_empresas_885.cod_emp_gerencial, p_empresas_885.cod_emp_oficial)
         AND b.cod_item = m_filtros.cod_item
         AND a.cod_empresa = b.cod_empresa
         AND a.num_nff     = b.num_nff
         AND a.ies_situacao = 'N' 
       GROUP BY a.num_nff,a.dat_emissao   
      
      LET p_i = 1
      FOREACH c_notas INTO p_nf_mestre.num_nff,p_nf_mestre.dat_emissao,p_nf_item.val_liq_item
      
         LET lr_relat.cod_item     = m_filtros.cod_item
         
         SELECT den_item
           INTO lr_relat.den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = lr_relat.cod_item
         
         LET lr_relat.custo_cliche   = p_val_cliche
         LET lr_relat.valor_faturado = p_tela.val_fat_tot
         LET lr_relat.num_nff        = p_nf_mestre.num_nff
         LET lr_relat.dat_emissao    = p_nf_mestre.dat_emissao
         LET lr_relat.val_liq_item   = p_nf_item.val_liq_item
         IF p_i = 1 THEN 
            LET lr_relat.val_a_fat = p_tela.val_fat_tot - p_nf_item.val_liq_item
            LET l_val_saldo = p_tela.val_fat_tot - p_nf_item.val_liq_item
         ELSE
            LET lr_relat.val_a_fat = l_val_saldo - p_nf_item.val_liq_item
            LET l_val_saldo = l_val_saldo - p_nf_item.val_liq_item
         END IF  
         
         SELECT a.CodRepresentante, a.NomeRepresentante 
           INTO lr_relat.cod_repres, lr_relat.raz_social
           FROM cliente_885 a, cliente_item b
          WHERE a.CodCliente = b.cod_cliente_matriz
            AND b.cod_empresa = p_empresas_885.cod_emp_gerencial
            AND b.cod_item = lr_relat.cod_item
         
         INSERT INTO t_age0290 VALUES(lr_relat.*)  
      
         LET p_i = p_i + 1
      END FOREACH

   END IF 

   LET p_last_row = FALSE
   INITIALIZE p_nom_rel TO NULL
 
   IF   log0280_saida_relat(19,40) IS NOT NULL
   THEN ERROR " Processando a extracao do relatorio ... "
        IF   p_ies_impressao = "S"
        THEN IF   g_ies_ambiente = "U"
             THEN START REPORT age0290_relat TO PIPE p_nom_arquivo
             ELSE START REPORT age0290_relat TO PRINTER
             END IF
        ELSE START REPORT age0290_relat TO p_nom_arquivo
        END IF


      DECLARE cq_relat CURSOR FOR 
      SELECT * 
        FROM t_age0290
       ORDER BY cod_item, dat_emissao 
      FOREACH cq_relat INTO lr_relat.*
         OUTPUT TO REPORT age0290_relat(lr_relat.*)
      END FOREACH
      
      FINISH REPORT age0290_relat   
      
       ERROR " FIM do processamento "

       IF   p_ies_impressao = "S"
       THEN MESSAGE "Relatorio gravado com sucesso" ATTRIBUTE(REVERSE)
       ELSE MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo CLIPPED
               ATTRIBUTE(REVERSE)
       END IF
  END IF
      

END FUNCTION


#------------------------------#
 REPORT age0290_relat(lr_relat) 
#------------------------------#
   DEFINE lr_relat     RECORD
                       cod_repres         DECIMAL(4,0),
                       raz_social         CHAR(30),
                       cod_item           CHAR(15),
                       den_item           CHAR(20),
                       custo_cliche       DECIMAL(15,2),
                       valor_faturado     DECIMAL(15,2),
                       num_nff            DECIMAL(6,0),
                       dat_emissao        DATE,
                       val_liq_item       DECIMAL(15,2),
                       val_a_fat          DECIMAL(15,2)
                       END RECORD    

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 66
   FORMAT
   PAGE HEADER
   
      PRINT log5211_retorna_configuracao(PAGENO,66,165) CLIPPED
      PRINT COLUMN 002, '--------------------------------------------------------------------------------'
      PRINT COLUMN 009, 'RELATORIO DE CLICHES E SALDOS PARA LIBERACAO DE COMISSOES',
            COLUMN 070, TODAY USING 'dd/mm/yyyy'
      PRINT COLUMN 072, TIME
      PRINT COLUMN 005, 'VENDEDOR:',lr_relat.cod_repres, '-',lr_relat.raz_social
      PRINT 

   BEFORE GROUP OF lr_relat.cod_item
      PRINT 
      PRINT COLUMN 009, 'Item: ', lr_relat.cod_item CLIPPED, '-', lr_relat.den_item
      PRINT COLUMN 005, 'C.Cliche:', lr_relat.custo_cliche,
            COLUMN 038, 'Valor de Fat.Total:', lr_relat.valor_faturado
      PRINT COLUMN 012, 'Num.NF    Dt.Emissao      Val.Faturado    Val. a Fafurar'
      PRINT COLUMN 012, '--------- ---------- ----------------- -----------------'

   
   ON EVERY ROW
      
      PRINT COLUMN 012, lr_relat.num_nff USING '<<<<<<<<<',
            COLUMN 022, lr_relat.dat_emissao,
            COLUMN 033, lr_relat.val_liq_item,
            COLUMN 051, lr_relat.val_a_fat


                   

END REPORT


{
CREATE TABLE t_age0290(
                       cod_repres         DECIMAL(4,0),
                       raz_social         CHAR(30),
                       cod_item           CHAR(15),
                       den_item           CHAR(20),
                       custo_cliche       DECIMAL(15,2),
                       valor_faturado     DECIMAL(15,2),
                       num_nff            DECIMAL(6,0),
                       dat_emissao        DATETIME,
                       val_liq_item       DECIMAL(15,2),
                       val_a_fat          DECIMAL(15,2));
}
