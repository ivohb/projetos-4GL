#-------------------------------------------------------------------#
# SISTEMA.: CONTAS A RECEBER                                        #
# PROGRAMA: pol0484                                                 #
# MODULOS.: pol0484-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: RELATÓRIO DE COMISSÕES                                  #
# AUTOR...: POLO INFORMATICA - BI                                   #
# DATA....: 22/09/2006                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_cod_emp_nf         CHAR(02),            # Ivo: 04/01/2011
          p_user               LIKE usuario.nom_usuario,
          p_den_repres         LIKE representante.raz_social,
          p_ies_pgto_docum     LIKE docum.ies_pgto_docum,
          p_val_tot_nff        LIKE fat_nf_mestre.val_nota_fiscal, #Will - 25/10/10
          p_val_comis          LIKE fat_nf_mestre.val_nota_fiscal, #Will - 25/10/10
          p_trans_nota_fiscal  LIKE fat_nf_mestre.trans_nota_fiscal,     #Will - 25/10/10
          p_trans_nota_orig    LIKE fat_nf_mestre.trans_nota_fiscal,     #Will - 25/10/10
          p_cod_consig         LIKE pedidos.cod_consig,
          p_seq_item_ped       INTEGER,
          p_tip_item           CHAR(01),
          p_msg                CHAR(300),
          p_tem_item           SMALLINT,
          p_ies_frete          CHAR(01),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_val_prop           DECIMAL(10,6),
          p_val_bruto          DECIMAL(10,2),
          p_emp_duplic         CHAR(02),
          p_val_liqui          DECIMAL(10,2),
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_num_nff            INTEGER,
          p_normal             CHAR(02),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_val_irrf           DECIMAL(8,2),
          p_tot_com_pgto       DECIMAL(11,2),
          p_sub_tot_dupl       DECIMAL(11,2),
          p_tot_ger_dupl       DECIMAL(11,2),
          p_tot_liq_receb      DECIMAL(12,2),
          p_tot_irrf           DECIMAL(12,2),
          p_tot_ger_com_pgto   DECIMAL(12,2),
          p_liq_receb          DECIMAL(12,2),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          p_sql                VARCHAR(1000),
          p_ies_meta           CHAR(01),
          p_pct_comis          DECIMAL(5,2),
          p_pct_acres          DECIMAL(5,2),
          p_pct_prod_normal    DECIMAL(5,2),
          p_pct_prod_novo      DECIMAL(5,2),
          p_val_abat           DECIMAL(12,2)

   DEFINE p_num_pedido         LIKE nf_item.num_pedido,    
          p_num_sequencia      LIKE nf_item.num_sequencia, 
          p_cod_item           LIKE nf_item.cod_item,      
          p_qtd_item           LIKE nf_item.qtd_item,      
          p_val_liq_item       LIKE nf_item.val_liq_item,   
          p_val_fret_it        LIKE fat_nf_mestre.val_nota_fiscal, #Will - 25/10/10
          p_val_base_com       LIKE fat_nf_mestre.val_nota_fiscal, #Will - 25/10/10  
          p_cod_tip_carteira   LIKE pedidos.cod_tip_carteira,
          p_cod_repres         LIKE representante.cod_repres
          
   DEFINE p_tela RECORD
          dat_ini              DATE,
          dat_fim              DATE,
          niv_repres           CHAR(01),
          cod_emp_dupl         LIKE empresa.cod_empresa,
          den_emp_dupl         LIKE empresa.den_empresa
   END RECORD 

   DEFINE p_repres RECORD
          cod_repres           LIKE representante.cod_repres,
          den_repres           LIKE representante.raz_social
   END RECORD 

   DEFINE pr_repres ARRAY[500] OF RECORD
          cod_repres LIKE representante.cod_repres,
          den_repres LIKE representante.raz_social
   END RECORD

   DEFINE p_docum RECORD
          cod_cliente          LIKE clientes.cod_cliente,
          nom_cliente          LIKE clientes.nom_reduzido,
          num_pedido           LIKE docum.num_pedido,
          lp                   CHAR(03),
          num_docum            LIKE docum.num_docum,
          num_docum_origem     LIKE docum.num_docum_origem,
          val_liq_orig         DECIMAL(10,2),
          val_frete            DECIMAL(10,2),
          val_liq              DECIMAL(10,2),
          val_pgto             DECIMAL(10,2),
          pct_comis            DECIMAL(5,2),
          val_comis            DECIMAL(9,2)
   END RECORD

END GLOBALS

DEFINE m_num_transac          INTEGER,
       m_serie_nf             CHAR(02)


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol0484-10.02.17"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0484.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0484_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0484_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0484") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0484 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Listagem"
         HELP 001 
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0484","IN")  THEN
            IF pol0484_cria_temp() THEN
               LET p_count = 0
               IF pol0484_informar() THEN
                  MESSAGE "Parâmetros informados com sucesso !!!" ATTRIBUTE(REVERSE)
                  LET p_ies_cons = TRUE
                  NEXT OPTION "Listar"
               ELSE
                  ERROR "Operação Cancelada !!!"
                  NEXT OPTION "Fim"
               END IF
            ELSE
               MESSAGE "Erro no processamento. Operação cancelada !!!" ATTRIBUTE(REVERSE)
               NEXT OPTION "Fim"
            END IF 
         END IF 
      COMMAND "Listar" "Lista Relatório de Comissões"
         HELP 007
         MESSAGE ""
         IF p_ies_cons THEN
            IF log0280_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0484_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0484.tmp'
                     START REPORT pol0484_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0484_relat TO p_nom_arquivo
               END IF
               CALL pol0484_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
                  CONTINUE MENU
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0484_relat   
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         ELSE
            ERROR 'Informe previamente os parâmetros!!!'
            NEXT OPTION "Informar"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0484_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
  
   CLOSE WINDOW w_pol0484

END FUNCTION


#--------------------------#
FUNCTION pol0484_informar()
#--------------------------#

   INITIALIZE p_tela, pr_repres TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
 
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_ini    
      IF p_tela.dat_ini IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_ini       
      END IF 

      AFTER FIELD dat_fim   
      IF p_tela.dat_fim IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_fim
      ELSE
         IF p_tela.dat_ini > p_tela.dat_fim THEN
            ERROR "Data Inicial nao pode ser maior que data Final"
            NEXT FIELD dat_ini
         END IF 
         IF p_tela.dat_fim - p_tela.dat_ini > 720 THEN 
            ERROR "Periodo nao pode ser maior que 720 Dias"
            NEXT FIELD dat_ini
         END IF 
      END IF 

      BEFORE FIELD niv_repres  
      IF p_tela.niv_repres IS NULL THEN 
         LET p_tela.niv_repres = 1
      END IF
      
      AFTER FIELD niv_repres  
      IF p_tela.niv_repres IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD niv_repres
      END IF
      
      IF p_tela.niv_repres < 0 OR p_tela.niv_repres > 3 THEN
         ERROR "Nível Inválido !!!"
         NEXT FIELD niv_repres
      END IF

      BEFORE FIELD cod_emp_dupl
         IF p_tela.cod_emp_dupl IS NULL THEN
            LET p_tela.cod_emp_dupl = p_cod_empresa
         END IF

      AFTER FIELD cod_emp_dupl
         IF p_tela.cod_emp_dupl IS NULL THEN
            ERROR "Campo com preenchimento obrigatorio !!!"
            NEXT FIELD cod_emp_dupl
         END IF
         
         SELECT den_empresa
           INTO p_tela.den_emp_dupl
           FROM empresa
          WHERE cod_empresa = p_tela.cod_emp_dupl
         
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR "Empresa inexistente !!!"
            NEXT FIELD cod_emp_dupl
         END IF
         
         DISPLAY p_tela.den_emp_dupl TO den_emp_dupl

      ON KEY (control-z)
         CALL pol0484_popup()
     
   END INPUT

   IF INT_FLAG = 0 THEN
      IF pol0484_aceita_repres() THEN
         RETURN TRUE
      END IF
   ELSE
      LET INT_FLAG = 0
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE
   
END FUNCTION


#---------------------------------#
 FUNCTION pol0484_emite_relatorio()
#---------------------------------#

   SELECT den_empresa 
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_tela.cod_emp_dupl

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_count = 0
   LET p_tot_ger_com_pgto = 0
   LET p_tot_ger_dupl     = 0
   LET p_tot_liq_receb    = 0
   LET p_tot_irrf         = 0

   DECLARE cq_repres CURSOR FOR
    SELECT a.cod_repres,
           b.raz_social
      FROM repres_kana_temp a,
           representante b
     WHERE b.cod_repres = a.cod_repres
     ORDER BY 1
   
   FOREACH cq_repres INTO p_repres.* 

      IF p_tela.niv_repres = 1 THEN
         CALL pol0484_monta_select_1()
      ELSE
         IF p_tela.niv_repres = 2 THEN
            CALL pol0484_monta_select_2()
         ELSE
            CALL pol0484_monta_select_3()
         END IF 
      END IF

      CALL pol0484_processa()
      
   END FOREACH

END FUNCTION

#-------------------------------#
FUNCTION pol0484_monta_select_1()
#-------------------------------#
               

   LET p_sql = 
       "SELECT  a.cod_empresa,      ",
               "a.cod_cliente,      ",
               "a.num_pedido,       ",
               "a.num_docum,        ",
               "a.val_bruto,        ",
               "a.val_liquido,      ",
               "a.pct_comis_1,      ",
               "b.val_abat,          ",
               "SUM(b.val_pago - b.val_juro_pago) ",
        "FROM docum a, docum_pgto b ",
       "WHERE a.cod_empresa   = '",p_tela.cod_emp_dupl,"' ",
         "AND a.cod_repres_1  = '",p_repres.cod_repres,"' ",
         "AND a.ies_tip_docum = 'DP' ",
         "AND a.ies_situa_docum <> 'C' ",           # Ivo: 04/01/2011
         "AND b.cod_empresa   = a.cod_empresa ",
         "AND b.num_docum     = a.num_docum ",
         "AND b.dat_pgto      >= '",p_tela.dat_ini,"' ",
         "AND b.dat_pgto      <= '",p_tela.dat_fim,"' ",
         "AND b.cod_portador NOT IN (370,700,701) ",
         "AND b.ies_forma_pgto NOT IN ('NC','AB','DV') ",
         "AND b.num_docum NOT IN ",
              "(SELECT c.num_docum FROM docum_comis_pagas c ",
                "WHERE c.cod_empresa   = b.cod_empresa ",
                  "AND c.num_docum     = b.num_docum ",
                  "AND c.ies_tip_docum = b.ies_tip_docum ",
                  "AND c.num_seq_docum = b.num_seq_docum) ",
        "GROUP BY a.cod_empresa, a.cod_cliente, a.num_pedido, a.num_docum, ",
        "a.val_bruto, a.val_liquido, a.pct_comis_1, b.val_abat ",               
        "ORDER BY a.cod_empresa, a.cod_cliente, a.num_pedido "

END FUNCTION

#-------------------------------#
FUNCTION pol0484_monta_select_2()
#-------------------------------#

   LET p_sql = 
       "SELECT  a.cod_empresa,      ",
               "a.cod_cliente,      ",
               "a.num_pedido,       ",
               "a.num_docum,        ",
               "a.val_bruto,        ",
               "a.val_liquido,      ",
               "a.pct_comis_2,      ",
               "b.val_abat,          ",
               "SUM(b.val_pago - b.val_juro_pago) ",
        "FROM docum a, docum_pgto b ",
       "WHERE a.cod_empresa   = '",p_tela.cod_emp_dupl,"' ",
         "AND a.cod_repres_2  = '",p_repres.cod_repres,"' ",
         "AND a.ies_tip_docum = 'DP' ",
         "AND a.ies_situa_docum <> 'C' ",           # Ivo: 04/01/2011
         "AND b.cod_empresa   = a.cod_empresa ",
         "AND b.num_docum     = a.num_docum ",
         "AND b.dat_pgto      >= '",p_tela.dat_ini,"' ",
         "AND b.dat_pgto      <= '",p_tela.dat_fim,"' ",
         "AND b.cod_portador NOT IN (370,700,701) ",
         "AND b.ies_forma_pgto NOT IN ('NC','AB','DV') ",
         "AND b.num_docum NOT IN ",
              "(SELECT c.num_docum FROM docum_comis_pagas c ",
                "WHERE c.cod_empresa   = b.cod_empresa ",
                  "AND c.num_docum     = b.num_docum ",
                  "AND c.ies_tip_docum = b.ies_tip_docum ",
                  "AND c.num_seq_docum = b.num_seq_docum) ",
        "GROUP BY a.cod_empresa, a.cod_cliente, a.num_pedido, a.num_docum, ",
        "a.val_bruto, a.val_liquido, a.pct_comis_2, b.val_abat ",               
        "ORDER BY a.cod_empresa, a.cod_cliente, a.num_pedido "

END FUNCTION

#-------------------------------#
FUNCTION pol0484_monta_select_3()
#-------------------------------#

   LET p_sql = 
       "SELECT  a.cod_empresa,      ",
               "a.cod_cliente,      ",
               "a.num_pedido,       ",
               "a.num_docum,        ",
               "a.val_bruto,        ",
               "a.val_liquido,      ",
               "a.pct_comis_3,      ",
               "b.val_abat,          ",
               "SUM(b.val_pago - b.val_juro_pago) ",
        "FROM docum a, docum_pgto b ",
       "WHERE a.cod_empresa   = '",p_tela.cod_emp_dupl,"' ",
         "AND a.cod_repres_3  = '",p_repres.cod_repres,"' ",
         "AND a.ies_tip_docum = 'DP' ",
         "AND a.ies_situa_docum <> 'C' ",           # Ivo: 04/01/2011
         "AND b.cod_empresa   = a.cod_empresa ",
         "AND b.num_docum     = a.num_docum ",
         "AND b.dat_pgto      >= '",p_tela.dat_ini,"' ",
         "AND b.dat_pgto      <= '",p_tela.dat_fim,"' ",
         "AND b.cod_portador NOT IN (370,700,701) ",
         "AND b.ies_forma_pgto NOT IN ('NC','AB','DV') ",
         "AND b.num_docum NOT IN ",
              "(SELECT c.num_docum FROM docum_comis_pagas c ",
                "WHERE c.cod_empresa   = b.cod_empresa ",
                  "AND c.num_docum     = b.num_docum ",
                  "AND c.ies_tip_docum = b.ies_tip_docum ",
                  "AND c.num_seq_docum = b.num_seq_docum) ",
        "GROUP BY a.cod_empresa, a.cod_cliente, a.num_pedido, a.num_docum, ",
        "a.val_bruto, a.val_liquido, a.pct_comis_3, b.val_abat ",               
        "ORDER BY a.cod_empresa, a.cod_cliente, a.num_pedido "

END FUNCTION

#-------------------------#
FUNCTION pol0484_le_nota()#
#-------------------------#

   SELECT trans_nota_fiscal,
          nota_fiscal,
          emp_nota_fiscal
     INTO m_num_transac,
          p_docum.num_docum_origem,
          p_cod_emp_nf
     FROM cre_nf_orig_docum
    WHERE empresa_docum = p_emp_duplic
      AND docum = p_docum.num_docum
      AND tip_docum = 'DP'

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Lendo','cre_nf_orig_docum')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol0484_processa()
#--------------------------#
      
   PREPARE var_query FROM p_sql 
   DECLARE cq_pgto CURSOR FOR var_query
   
   FOREACH cq_pgto INTO                                                                   
           p_emp_duplic,                                                                     
           p_docum.cod_cliente,                                                              
           p_docum.num_pedido,                                                               
           p_docum.num_docum,                                                                
           p_val_bruto,                                                                      
           p_val_liqui,                                                                      
           p_docum.pct_comis,                                                                
           p_val_abat,                                                                 
           p_docum.val_pgto                                                                  

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_pgto')
         RETURN
      END IF

      IF NOT pol0484_le_nota() THEN
         RETURN
      END IF
                                                                                              
      INITIALIZE p_docum.lp TO NULL                                                          
                                                                                          
      IF p_docum.pct_comis IS NULL THEN                                                      
         LET p_docum.pct_comis = 0                                                           
      END IF                                                                                 
                                                                                             
      SELECT val_liq_orig                                                                    
        INTO p_docum.val_liq_orig                                                            
        FROM recalc_base_kana                                                                
       WHERE cod_empresa   = p_emp_duplic                                                    
         AND num_docum     = p_docum.num_docum                                               
         AND ies_tip_docum = 'DP'                                                            
                                                                                          
      IF STATUS <> 0 THEN                                                                    
         LET p_docum.val_liq_orig = p_val_liqui                                              
      END IF                                                                                 
      
      IF NOT pol0484_le_fat_nf_mestre() THEN
         RETURN
      END IF                                                     

      IF p_ies_frete = '1' THEN
         
         IF p_docum.num_pedido IS NULL  OR
            p_docum.num_pedido = 0 THEN
            IF NOT pol0484_busca_pedido() THEN
               RETURN
            END IF                                                     
         END IF
         
         SELECT COUNT(empresa)
           INTO p_count
           FROM ped_info_compl
          WHERE empresa = p_cod_empresa
            AND pedido =  p_docum.num_pedido 
            AND campo LIKE '%CONSIGNATARIO%'
        
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ped_info_compl')
            RETURN
         END IF

         IF p_count = 0 THEN
            SELECT cod_consig
              INTO p_cod_consig
              FROM pedidos
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido =  p_docum.num_pedido 
            IF STATUS = 0 THEN
               IF p_cod_consig IS NULL OR p_cod_consig = ' ' THEN
               ELSE
                  LET p_count = 1
               END IF
            END IF
         END IF
         
         IF p_count > 0 THEN
            LET p_ies_frete = '*'
         END IF
         
      END IF
                                                                                                
      SELECT parametro_texto                                                                 
        INTO p_docum.lp                                                                      
        FROM ped_info_compl                                                                  
       WHERE empresa = p_cod_emp_nf                                                          
         AND pedido  = p_docum.num_pedido                                                    
         AND campo   = 'linha_produto'                                                       
                                                                                             
      IF STATUS <> 0 THEN 
         LET p_docum.lp = NULL                                                      
      END IF                                                                                 
                                                                                             
      LET p_val_prop = (p_docum.val_pgto + p_val_abat) / p_val_bruto                                        

      IF p_docum.val_liq_orig > 0 THEN                                                       
         LET p_docum.val_frete = (p_docum.val_liq_orig - p_val_liqui) * p_val_prop           
      ELSE                                                                                   
         LET p_docum.val_frete = 0                                                           
      END IF                                                                                 
      
      LET p_docum.val_liq   = p_val_liqui * p_val_prop                                       
      LET p_docum.val_comis = p_docum.val_liq * p_docum.pct_comis / 100                      
                                                                                 
      SELECT nom_reduzido                                                                    
        INTO p_docum.nom_cliente                                                             
        FROM clientes                                                                        
       WHERE cod_cliente = p_docum.cod_cliente                                               
                                                                                                                                                                                    
      OUTPUT TO REPORT pol0484_relat(p_repres.cod_repres)                                    
                                                                                             
      LET p_count = p_count + 1                                                              
                                                                                          
   END FOREACH                                                                               

END FUNCTION 

#----------------------------------#
FUNCTION  pol0484_le_fat_nf_mestre()
#----------------------------------#
   
   #...---#


   SELECT tip_frete,                        #Will - 25/10/10
          val_nota_fiscal,                  #Will - 25/10/10
          empresa,                          #Will - 25/10/10
          trans_nota_fiscal
     INTO p_ies_frete,                      #Will - 25/10/10
          p_val_tot_nff,                    #Will - 25/10/10
          p_cod_empresa,                    #Will - 25/10/10
          p_trans_nota_fiscal
     FROM fat_nf_mestre                     #Will - 25/10/10
    WHERE empresa           = p_cod_emp_nf  #Will - 25/10/10
      AND trans_nota_fiscal = m_num_transac      
    UNION
   SELECT tip_frete,                        #Will - 25/10/10
          val_nota_fiscal,                  #Will - 25/10/10
          empresa,                           #Will - 25/10/10
          trans_nota_fiscal
     INTO p_ies_frete,                      #Will - 25/10/10
          p_val_tot_nff,                    #Will - 25/10/10
          p_cod_empresa,                    #Will - 25/10/10
          p_trans_nota_fiscal
     FROM fat_nf_mestre_hist                #Will - 25/10/10
    WHERE empresa           = p_cod_emp_nf  #Will - 25/10/10
      AND trans_nota_fiscal = m_num_transac      
    
   IF STATUS <> 0 THEN
      LET p_msg = 'Não foi possivel localizar a NF na\n',  #Will - 25/10/10
                  'tabela fat_nf_mestre para o titulo: ',  #Will - 25/10/10
                  p_docum.num_docum CLIPPED,'\n'           #Will - 25/10/10
      CALL log0030_mensagem(p_msg,'excla')                 #Will - 25/10/10
      RETURN FALSE                                         #Will - 25/10/10
   END IF                                                  #Will - 25/10/10

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0484_busca_pedido()#
#------------------------------#
   
   DEFINE p_num_pedido INTEGER
   LET p_trans_nota_orig = NULL
   
   DECLARE cq_refer CURSOR FOR
    SELECT trans_nf_refer,
           seq_item_nf_refer
      FROM fat_nf_refer_item
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = p_trans_nota_fiscal

   FOREACH cq_refer INTO p_trans_nota_orig,
           p_seq_item_ped
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_refer')
         RETURN FALSE                                         
      END IF                                      
                  
      EXIT FOREACH
      
   END FOREACH
         
   DECLARE cq_item_nf CURSOR FOR
    SELECT pedido
      FROM fat_nf_item
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = p_trans_nota_orig

   FOREACH cq_item_nf INTO p_num_pedido
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('FOREACH','cq_item_nf')
         RETURN FALSE
      END IF
      
      LET p_docum.num_pedido = p_num_pedido
      
      EXIT FOREACH
   
   END FOREACH

   IF p_docum.num_pedido = 0 OR p_docum.num_pedido IS NULL THEN
      LET p_msg = 'Não foi possivel localizar o pedido\n',
                  'para o titulo: ',p_docum.num_docum CLIPPED,'\n' 
      CALL log0030_mensagem(p_msg,'excla')                 
      RETURN FALSE                                         
   END IF                                                  
      
   RETURN TRUE

END FUNCTION

#------------------------------#
REPORT pol0484_relat(p_relat)
#------------------------------#

   DEFINE p_relat     RECORD
          cod_repres  LIKE docum.cod_repres_1
   END RECORD
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
          PAGE  LENGTH 66

     ORDER EXTERNAL BY p_relat.cod_repres
   
   FORMAT

      FIRST PAGE HEADER
              
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001, p_comprime, p_den_empresa,
               COLUMN 046, "COMISSOES PAGAS A REPRESENTANTES",
               COLUMN 122, "PAG.:   ", PAGENO USING "##&"
         PRINT COLUMN 001, "POL0484",
               COLUMN 046, "PERIODO: ", p_tela.dat_ini, " - ", p_tela.dat_fim,
               COLUMN 095, "DATA DA EMISSAO: ", TODAY USING "DD/MM/YYYY", ' - ', TIME
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"

      PAGE HEADER
   
         PRINT COLUMN 001, p_comprime, p_den_empresa,
               COLUMN 046, "COMISSOES PAGAS A REPRESENTANTES",
               COLUMN 122, "PAG.:   ", PAGENO USING "##&"
         PRINT COLUMN 001, "POL0484",
               COLUMN 046, "PERIODO: ", p_tela.dat_ini, " - ", p_tela.dat_fim,
               COLUMN 095, "DATA DA EMISSAO: ", TODAY USING "DD/MM/YYYY", ' - ', TIME
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "------------"

         PRINT COLUMN 001, '    CLIENTE      NOME RESUMIDO  PED REPRES LP    DUPLICATA       FATURA      VR DUPLICATA DES FRETE/TP      VR PAGO % COM   VR COMIS'
         PRINT COLUMN 001, '--------------- --------------- ---------- --- -------------- -------------- ------------ ------------ ------------ ----- ----------'

      BEFORE GROUP OF p_relat.cod_repres

         SKIP TO TOP OF PAGE
         PRINT 
         PRINT COLUMN 001, 'REPRESENTANTE: ', p_relat.cod_repres, ' ', p_repres.den_repres
         PRINT
         LET p_tot_com_pgto = 0 
         LET p_sub_tot_dupl = 0

         PRINT COLUMN 001, '    CLIENTE      NOME RESUMIDO  PED REPRES LP    DUPLICATA       FATURA      VR DUPLICATA DES FRETE/TP      VR PAGO % COM   VR COMIS'
         PRINT COLUMN 001, '--------------- --------------- ---------- --- -------------- -------------- ------------ ------------ ------------ ----- ----------'
                 
      ON EVERY ROW
         
         PRINT COLUMN 001, p_docum.cod_cliente,
               COLUMN 017, p_docum.nom_cliente,
               COLUMN 033, p_docum.num_pedido[1,10],
               COLUMN 044, p_docum.lp,
               COLUMN 048, p_docum.num_docum,
               COLUMN 063, p_docum.num_docum_origem,
               COLUMN 078, p_docum.val_liq_orig USING '#,###,##&.&&',
               COLUMN 091, p_docum.val_frete USING '###,##&.&&',
               COLUMN 102, p_ies_frete,
               COLUMN 104, p_docum.val_liq USING '#,###,##&.&&',
               COLUMN 117, p_docum.pct_comis USING '#&.&&',
               COLUMN 123, p_docum.val_comis USING '###,##&.&&'
         
         LET p_tot_com_pgto = p_tot_com_pgto + p_docum.val_comis
         LET p_sub_tot_dupl = p_sub_tot_dupl + p_docum.val_liq

      AFTER GROUP OF p_relat.cod_repres
      
         LET p_val_irrf = p_tot_com_pgto * 1.5 / 100
         LET p_liq_receb = p_tot_com_pgto - p_val_irrf
         
         SKIP 1 LINES
         PRINT COLUMN 051, "TOTAL DO REPRESENTANTE: R$",
               COLUMN 104, p_sub_tot_dupl USING '#,###,##&.&&',
               COLUMN 123, p_tot_com_pgto USING '###,##&.&&'

         PRINT COLUMN 051, "IRRF: 1,50%      VALOR: R$",
               COLUMN 124, p_val_irrf USING '##,##&.&&'
                    
         PRINT COLUMN 051, "VAL. LIQUIDO A RECEBER: R$",
               COLUMN 123, p_liq_receb USING '###,##&.&&'
                              
         LET p_tot_ger_com_pgto = p_tot_ger_com_pgto + p_tot_com_pgto
         #LET p_tot_ger_dupl = p_tot_ger_dupl + p_sub_tot_dupl
         LET p_tot_liq_receb = p_tot_liq_receb + p_liq_receb
         LET p_tot_irrf = p_tot_irrf + p_val_irrf
         
         SKIP 2 LINES

      ON LAST ROW

         SKIP 1 LINES
         PRINT COLUMN 102, 'TOTAL COMIÕES: R$',
               COLUMN 120, p_tot_ger_com_pgto USING '##,###,##&.&&'
         PRINT COLUMN 102, 'TOTAL    IRRF: R$',
               COLUMN 120, p_tot_irrf USING '##,###,##&.&&'
         PRINT COLUMN 102, 'TOTAL LIQUIDO: R$',
               COLUMN 120, p_tot_liq_receb USING '##,###,##&.&&'
               
               
         PRINT COLUMN 001, p_descomprime
      
END REPORT


#-----------------------------#
FUNCTION pol0484_cria_temp()
#-----------------------------#

   
   DROP TABLE repres_kana_temp;

   CREATE TEMP TABLE repres_kana_temp
   (
      cod_repres   DECIMAL(4,0)
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","repres_kana_temp")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0484_aceita_repres()
#-------------------------------#

   INPUT ARRAY pr_repres
      WITHOUT DEFAULTS FROM sr_repres.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD cod_repres
         IF pr_repres[p_index].cod_repres IS NOT NULL THEN
            IF pol0484_repetiu_cod() THEN
               ERROR "Representante já Indormado !!!"
               NEXT FIELD cod_repres
            END IF
            SELECT raz_social
              INTO pr_repres[p_index].den_repres
              FROM representante
             WHERE cod_repres = pr_repres[p_index].cod_repres
            IF SQLCA.sqlcode = NOTFOUND THEN
               ERROR 'Representante não cadastrado !!!'
               NEXT FIELD cod_repres
            END IF
            DISPLAY pr_repres[p_index].den_repres TO
                    sr_repres[s_index].den_repres
         ELSE
            IF FGL_LASTKEY() = FGL_KEYVAL("RETURN") OR
               FGL_LASTKEY() = FGL_KEYVAL("DOWN")THEN
               NEXT FIELD cod_repres
            END IF
         END IF

      ON KEY (control-z)
         CALL pol0484_popup()
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      IF pol0484_grava_repres() THEN
         RETURN TRUE
      ELSE
         RETURN FALSE
      END IF
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF   

END FUNCTION

#-----------------------------#
FUNCTION pol0484_repetiu_cod()
#-----------------------------#

   DEFINE m_ind SMALLINT

   FOR m_ind = 1 TO ARR_COUNT()
       IF m_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_repres[m_ind].cod_repres = pr_repres[p_index].cod_repres THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0484_grava_repres()
#-----------------------------#

   DEFINE p_qtd_repres SMALLINT
 

   IF ARR_COUNT() < 1 THEN
      DECLARE cq_representante CURSOR FOR 
       SELECT cod_repres  
         FROM representante
      FOREACH cq_representante INTO p_cod_repres
         INSERT into repres_kana_temp 
         VALUES(p_cod_repres)
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("INCLUSÃO","repres_kana_temp")
            RETURN FALSE
         END IF
      END FOREACH
   ELSE
      FOR p_ind = 1 TO ARR_COUNT()
          IF pr_repres[p_ind].cod_repres IS NULL THEN
             CONTINUE FOR
          END IF
          INSERT INTO repres_kana_temp
          VALUES (pr_repres[p_ind].cod_repres)

          IF SQLCA.SQLCODE <> 0 THEN 
             CALL log003_err_sql("INCLUSÃO","repres_kana_temp")
             RETURN FALSE
          END IF
      END FOR
   END IF

   RETURN TRUE
      
END FUNCTION

#-----------------------#
FUNCTION pol0484_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_repres)
         CALL log009_popup(8,15,"REPRESENTATES","representante",
                     "cod_repres","raz_social","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0484
         IF p_codigo IS NOT NULL THEN
            LET pr_repres[p_index].cod_repres = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_repres[s_index].cod_repres
         END IF
   
      WHEN INFIELD(cod_emp_dupl)
         CALL log009_popup(8,25,"EMPRESAS","empresa",
                     "cod_empresa","den_empresa","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0484
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_emp_dupl = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_emp_dupl
            
         END IF

   END CASE

END FUNCTION

#-----------------------#
 FUNCTION pol0484_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------FIM DO PROGRAMA----------------------#