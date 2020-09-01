#-------------------------------------------------------------------#
# SISTEMA.: CONTAS A RECEBER                                        #
# PROGRAMA: pol1029                                                 #
# MODULOS.: pol1029-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: RELATÓRIO DE COMISSÕES                                  #
# AUTOR...: POLO INFORMATICA - BI                                   #
# DATA....: 22/09/2006                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_repres         LIKE representante.raz_social,
          p_cod_emp_nf         CHAR(02),            # Ivo: 04/01/2011
          p_ies_pgto_docum     LIKE docum.ies_pgto_docum,
          p_val_tot_nff        LIKE fat_nf_mestre.val_nota_fiscal,   #Will - 25/10/10
		      p_total_itens        LIKE fat_nf_mestre.val_nota_fiscal,   #Will - 25/10/10
          p_val_comis          LIKE fat_nf_mestre.val_nota_fiscal,   #Will - 25/10/10
          p_pct_comis_orig     DECIMAL(5,2),
          p_comis_item         LIKE fat_nf_mestre.val_nota_fiscal,   #Will - 25/10/10  
          p_trans_nota_orig    LIKE fat_nf_mestre.trans_nota_fiscal,     #Will - 25/10/10
          p_carteira           LIKE fat_nf_mestre.tip_carteira,
          p_seq_item_ped       INTEGER,
          p_tip_relat          CHAR(01),
          p_den_reduz          CHAR(18),
          p_ano_mes_proc       CHAR(07),
          p_den_erro           CHAR(30),
          p_ano_nf             DECIMAL(4,0),
          p_mes_nf             DECIMAL(2,0),
          p_dat_emis_nf        DATE,
          p_tip_item           CHAR(01),
          p_msg                CHAR(400),
          p_tem_item           SMALLINT,
          p_ies_frete          CHAR(01),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_val_prop           DECIMAL(11,9),
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
          p_tot_comis          DECIMAL(11,2),
          p_tot_base           DECIMAL(11,2),
          p_val_base           DECIMAL(11,2),
          p_val_adiant         DECIMAL(11,2),
          p_tot_ger_dupl       DECIMAL(11,2),
          p_sub_tot_comis      DECIMAL(11,2),
          p_sub_tot_base       DECIMAL(11,2),
          p_tot_liq_receb      DECIMAL(12,2),
          p_tot_irrf           DECIMAL(12,2),
          p_tot_ger_com_pgto   DECIMAL(12,2),
          p_liq_receb          DECIMAL(12,2),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          p_sql                VARCHAR(1100),
          p_ies_meta           CHAR(01),
          p_pct_comis          DECIMAL(5,2),
          p_pct_acres          DECIMAL(5,2),
          p_pct_prod_normal    DECIMAL(5,2),
          p_pct_prod_novo      DECIMAL(5,2),
          p_qtd_item_comis     INTEGER,
          p_dat_hohe           CHAR(10),
          p_last_row           SMALLINT,
          p_val_abat           DECIMAL(12,2),
          m_num_transac        integer
   
          
   DEFINE p_num_pedido         LIKE fat_nf_item.pedido,                 #Will - 25/10/10
          p_num_sequencia      LIKE fat_nf_item.seq_item_nf,            #Will - 25/10/10
          p_cod_item           LIKE fat_nf_item.item,                   #Will - 25/10/10
          p_qtd_item           LIKE fat_nf_item.qtd_item,               #Will - 25/10/10  
          p_val_liq_item       LIKE fat_nf_item.val_liquido_item,       #Will - 25/10/10 
          p_val_fret_it        LIKE fat_nf_mestre.val_nota_fiscal,      #Will - 25/10/10
          p_val_base_com       LIKE fat_nf_mestre.val_nota_fiscal,      #Will - 25/10/10
          p_cod_tip_carteira   LIKE pedidos.cod_tip_carteira,
          p_cod_repres         LIKE representante.cod_repres,
          p_trans_nota_fiscal  LIKE fat_nf_mestre.trans_nota_fiscal     #Will - 25/10/10
          
   DEFINE p_tela RECORD
          tip_proces           CHAR(01),
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

   DEFINE pr_representante     ARRAY[500] OF RECORD
          cod_repres           LIKE representante.cod_repres,
          raz_social           LIKE representante.raz_social,
          ies_meta             CHAR(01)
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol1029-10.02.17"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1029.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1029_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1029_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1029") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1029 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol1029_cria_tmp() THEN
      RETURN
   END IF
      
   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Listagem"
         HELP 001 
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol1029","IN")  THEN
            IF pol1029_del_tmp_repres() THEN
               LET p_count = 0
               IF pol1029_informar() THEN
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
         IF NOT pol1029_cria_tab_erro() THEN
            CONTINUE MENU
         END IF
         MESSAGE ""
         IF p_ies_cons THEN
            IF log0280_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol1029_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol1029.tmp'
                     START REPORT pol1029_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol1029_relat TO p_nom_arquivo
               END IF
               CALL pol1029_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
                  CONTINUE MENU
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol1029_relat   
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

      COMMAND "Inconsistências" "Lista as inconsistências"
         MESSAGE ""
         IF NOT pol1029_tem_erro() THEN
            CONTINUE MENU
         END IF
            IF log0280_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol1029_erro TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol1029.tmp'
                     START REPORT pol1029_erro  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol1029_erro TO p_nom_arquivo
               END IF
               CALL pol1029_imprime_erros()   
               FINISH REPORT pol1029_erro   
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
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol1029_sobre()
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
  
   CLOSE WINDOW w_pol1029

END FUNCTION


#--------------------------#
FUNCTION pol1029_informar()
#--------------------------#

   LET p_dat_hohe = TODAY
   
   INITIALIZE p_tela, pr_repres TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_tela.tip_proces = 'Q'
   LET p_dat_hohe[1,2] = '01'
   LET p_tela.dat_ini = p_dat_hohe
 
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD tip_proces    
      IF p_tela.dat_ini IS NULL THEN
            
      END IF 

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
         CALL pol1029_popup()
     
   END INPUT

   IF INT_FLAG = 0 THEN
      IF pol1029_aceita_repres() THEN
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
 FUNCTION pol1029_emite_relatorio()
#---------------------------------#

   LET p_msg = 'Imprimir os detalhes do pedido???'
   
   IF log0040_confirm(20,25,p_msg) = TRUE THEN
      LET p_tip_relat = 'A'
   ELSE
      LET p_tip_relat = 'S'
   END IF
   
   CURRENT WINDOW IS w_pol1029
   
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
         CALL pol1029_monta_select_1()
      ELSE
         IF p_tela.niv_repres = 2 THEN
            CALL pol1029_monta_select_2()
         ELSE
            CALL pol1029_monta_select_3()
         END IF 
      END IF

      CALL pol1029_processa()
      
   END FOREACH

END FUNCTION

#-------------------------------#
FUNCTION pol1029_monta_select_1()
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
               "(b.val_pago - b.val_juro_pago) ",
        "FROM docum a, docum_pgto b ",
       "WHERE a.cod_empresa   = '",p_tela.cod_emp_dupl,"' ",
         "AND a.cod_repres_1  = '",p_repres.cod_repres,"' ",
         "AND a.ies_tip_docum = 'DP' ",
         "AND a.ies_situa_docum <> 'C'",           # Ivo: 04/01/2011
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
        "ORDER BY 1,2,3 "

END FUNCTION

#-------------------------------#
FUNCTION pol1029_monta_select_2()
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
               "(b.val_pago - b.val_juro_pago) ",
        "FROM docum a, docum_pgto b ",
       "WHERE a.cod_empresa   = '",p_tela.cod_emp_dupl,"' ",
         "AND a.cod_repres_2  = '",p_repres.cod_repres,"' ",
         "AND a.ies_tip_docum = 'DP' ",
         "AND a.ies_situa_docum <> 'C'",           # Ivo: 04/01/2011
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
        "ORDER BY 1,2,3 "

END FUNCTION

#-------------------------------#
FUNCTION pol1029_monta_select_3()
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
               "(b.val_pago - b.val_juro_pago) ",
        "FROM docum a, docum_pgto b ",
       "WHERE a.cod_empresa   = '",p_tela.cod_emp_dupl,"' ",
         "AND a.cod_repres_3  = '",p_repres.cod_repres,"' ",
         "AND a.ies_tip_docum = 'DP' ",
         "AND a.ies_situa_docum <> 'C'",           # Ivo: 04/01/2011
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
        "ORDER BY 1,2,3 "

END FUNCTION

#-------------------------#
FUNCTION pol1029_le_nota()#
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
FUNCTION pol1029_processa()
#--------------------------#

   LET p_dat_hohe = p_tela.dat_ini
   LET p_ano_mes_proc = p_dat_hohe[7,10],p_dat_hohe[3,6]
   
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

      IF NOT pol1029_le_nota() THEN
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
      
      IF NOT pol1029_le_fat_nf_mestre() THEN   #Will - 25/10/10
         RETURN
      END IF                                                     
      
      IF p_docum.num_pedido IS NULL  OR
         p_docum.num_pedido = 0 THEN
         IF NOT pol1029_busca_pedido() THEN
            RETURN
         END IF           
      END IF

      IF p_ies_frete = '1' THEN

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

         IF p_count > 0 THEN
            LET p_ies_frete = '*'
         END IF

      END IF
    
      LET p_dat_hohe = p_dat_emis_nf
      LET p_ano_nf = p_dat_hohe[7,10]
      LET p_mes_nf = p_dat_hohe[4,5]

      SELECT cod_repres
        FROM repres_meta_444
       WHERE cod_repres = p_repres.cod_repres
         AND ano        = p_ano_nf
         AND mes        = p_mes_nf
      
      IF STATUS = 100 THEN
         LET p_ies_meta = 'N'
      ELSE
         IF STATUS = 0 THEN
            LET p_ies_meta = 'S'
         ELSE
            CALL log003_err_sql('Lendo','repres_meta_444')
            RETURN
         END IF
      END IF
      
      IF p_docum.num_pedido IS NULL OR p_docum.num_pedido = ' ' THEN
         LET  p_docum.lp = ''
      ELSE                                                                                
         SELECT parametro_texto                                                                 
           INTO p_docum.lp                                                                      
           FROM ped_info_compl                                                                  
          WHERE empresa = p_cod_empresa                                                          
            AND pedido  = p_docum.num_pedido                                                    
            AND campo   = 'linha_produto'                                                       
                                                                                             
         IF STATUS <> 0 THEN                                                       
            SELECT parametro_texto                                                              
              INTO p_docum.lp                                                                   
              FROM ped_info_compl                                                               
             WHERE empresa = '01'                                                               
               AND pedido  = p_docum.num_pedido                                                 
               AND campo   = 'linha_produto'                                                    
         END IF                                                                                 
      END IF
                                                                                          
      LET p_val_prop = (p_docum.val_pgto + p_val_abat) / p_val_bruto                                        

      IF p_docum.val_liq_orig > 0 THEN                                                       
         LET p_docum.val_frete = (p_docum.val_liq_orig - p_val_liqui) * p_val_prop           
      ELSE                                                                                   
         LET p_docum.val_frete = 0                                                           
      END IF                                                                                 
      
      IF p_docum.pct_comis <= 0 THEN
         LET p_val_comis = 0
         LET p_qtd_item_comis = 0 
      ELSE
         IF NOT pol1029_checa_comis_pedido() THEN
            CONTINUE FOREACH
         END IF
      END IF
      
      IF p_val_comis = 0 AND p_qtd_item_comis = 0 THEN
         LET p_val_prop = (p_docum.val_pgto + p_val_abat) / p_val_bruto                                        
         LET p_docum.val_liq   = p_val_liqui * p_val_prop                                       
         LET p_docum.val_comis = p_docum.val_liq * p_docum.pct_comis / 100                      
      ELSE
         LET p_docum.val_comis = p_val_comis
         LET p_docum.pct_comis = p_val_comis / p_docum.val_liq * 100
         LET p_val_prop = (p_docum.val_pgto + p_val_abat) / p_val_bruto                                        
         LET p_docum.val_liq   = p_docum.val_liq * p_val_prop                                       
         LET p_docum.val_comis = p_docum.val_liq * p_docum.pct_comis/ 100  

         IF p_tela.niv_repres = 1 THEN
            UPDATE docum SET pct_comis_1 = p_docum.pct_comis
             WHERE cod_empresa = p_emp_duplic 
               AND num_docum   = p_docum.num_docum
         ELSE
            IF p_tela.niv_repres = 2 THEN
               UPDATE docum SET pct_comis_2 = p_docum.pct_comis
                WHERE cod_empresa = p_emp_duplic 
                  AND num_docum   = p_docum.num_docum
            ELSE
               UPDATE docum SET pct_comis_3 = p_docum.pct_comis
                WHERE cod_empresa = p_emp_duplic 
                  AND num_docum   = p_docum.num_docum            
            END IF 
         END IF
      END IF            
                                                                         
      SELECT nom_reduzido                                                                    
        INTO p_docum.nom_cliente                                                             
        FROM clientes                                                                        
       WHERE cod_cliente = p_docum.cod_cliente                                               
                                                                                                                                                                                    
      OUTPUT TO REPORT pol1029_relat(p_repres.cod_repres)                                    
                                                                                             
      LET p_count = p_count + 1                                                              
                                                                                          
   END FOREACH                                                                               

END FUNCTION 

#----------------------------------#
FUNCTION  pol1029_le_fat_nf_mestre()    #Will - 25/10/10
#----------------------------------#
   

   #...---#

   SELECT tip_frete,                        #Will - 25/10/10
          val_mercadoria,                   #Will - 25/10/10
          empresa,                          #Will - 25/10/10
          dat_hor_emissao,                  #Will - 25/10/10
          trans_nota_fiscal,                 #Will - 25/10/10
          tip_carteira
     INTO p_ies_frete,                      #Will - 25/10/10
          p_val_tot_nff,                    #Will - 25/10/10
          p_cod_empresa,                    #Will - 25/10/10
          p_dat_emis_nf,                    #Will - 25/10/10
          p_trans_nota_fiscal,               #Will - 25/10/10
          p_carteira
     FROM fat_nf_mestre                     #Will - 25/10/10
    WHERE empresa           = p_cod_emp_nf  #Will - 25/10/10
      AND trans_nota_fiscal = m_num_transac      
    UNION 
   SELECT tip_frete,                        #Will - 25/10/10
          val_mercadoria,                   #Will - 25/10/10
          empresa,                          #Will - 25/10/10
          dat_hor_emissao,                  #Will - 25/10/10
          trans_nota_fiscal,                 #Will - 25/10/10
          tip_carteira
     INTO p_ies_frete,                      #Will - 25/10/10
          p_val_tot_nff,                    #Will - 25/10/10
          p_cod_empresa,                    #Will - 25/10/10
          p_dat_emis_nf,                    #Will - 25/10/10
          p_trans_nota_fiscal,               #Will - 25/10/10
          p_carteira
     FROM fat_nf_mestre_hist                #Will - 25/10/10
    WHERE empresa           = p_cod_emp_nf  #Will - 25/10/10
      AND trans_nota_fiscal = m_num_transac      
    
   IF STATUS = 100 THEN
      SELECT tip_frete,                        #Will - 25/10/10
             val_mercadoria,                   #Will - 25/10/10
             empresa,                          #Will - 25/10/10
             dat_hor_emissao,                  #Will - 25/10/10
             trans_nota_fiscal,                 #Will - 25/10/10
             tip_carteira
        INTO p_ies_frete,                      #Will - 25/10/10
             p_val_tot_nff,                    #Will - 25/10/10
             p_cod_empresa,                    #Will - 25/10/10
             p_dat_emis_nf,                    #Will - 25/10/10
             p_trans_nota_fiscal,               #Will - 25/10/10
             p_carteira
        FROM fat_nf_mestre                     #Will - 25/10/10
       WHERE empresa           = '01'          #Will - 25/10/10
         AND trans_nota_fiscal = m_num_transac      
       UNION 
      SELECT tip_frete,                        #Will - 25/10/10
             val_mercadoria,                   #Will - 25/10/10
             empresa,                          #Will - 25/10/10
             dat_hor_emissao,                  #Will - 25/10/10
             trans_nota_fiscal,                 #Will - 25/10/10
             tip_carteira
        INTO p_ies_frete,                      #Will - 25/10/10
             p_val_tot_nff,                    #Will - 25/10/10
             p_cod_empresa,                    #Will - 25/10/10
             p_dat_emis_nf,                    #Will - 25/10/10
             p_trans_nota_fiscal,               #Will - 25/10/10
             p_carteira
        FROM fat_nf_mestre_hist                #Will - 25/10/10
       WHERE empresa           = '01'          #Will - 25/10/10
         AND trans_nota_fiscal = m_num_transac      

      IF STATUS = 100 THEN                                    #Will - 25/10/10
         LET p_msg = 'Não foi possivel localizar a NF na\n',  #Will - 25/10/10
                     'tabela fat_nf_mestre para o titulo: ',  #Will - 25/10/10
                     p_docum.num_docum CLIPPED,'\n'           #Will - 25/10/10
         CALL log0030_mensagem(p_msg,'excla')                 #Will - 25/10/10
         RETURN FALSE                                         #Will - 25/10/10
      ELSE                                                    #Will - 25/10/10
         IF STATUS <> 0 THEN                                  #Will - 25/10/10
            CALL log003_err_sql("Lendo", "fat_nf_mestre")     #Will - 25/10/10
            RETURN FALSE                                      #Will - 25/10/10
         END IF                                               #Will - 25/10/10
      END IF                                                  #Will - 25/10/10
   ELSE                                                       #Will - 25/10/10
      IF STATUS <> 0 THEN                                     #Will - 25/10/10
         CALL log003_err_sql("Lendo", "fat_nf_mestre")        #Will - 25/10/10
         RETURN FALSE                                         #Will - 25/10/10
      END IF                                                  #Will - 25/10/10
   END IF                                                     #Will - 25/10/10

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1029_busca_pedido()#
#------------------------------#
   
   DEFINE p_pedido INTEGER
   
   SELECT trans_nf_refer,
          seq_item_nf_refer
     INTO p_trans_nota_orig,
          p_seq_item_ped
     FROM fat_nf_refer_item
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_trans_nota_fiscal
      
   IF STATUS <> 0 THEN
      LET p_msg = 'Não foi possivel localizar o pedido\n',
                  'para o titulo: ',p_docum.num_docum CLIPPED,'\n' 
      CALL log0030_mensagem(p_msg,'excla')                 
      RETURN FALSE                                         
   END IF                                                  
   
   DECLARE cq_item_nf CURSOR FOR
    SELECT pedido
      FROM fat_nf_item
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = p_trans_nota_orig

   FOREACH cq_item_nf INTO p_pedido
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('FOREACH','cq_item_nf')
         RETURN FALSE
      END IF
      
      LET p_docum.num_pedido = p_pedido
      
      EXIT FOREACH
   
   END FOREACH

   IF p_docum.num_pedido = 0 OR p_docum.num_pedido IS NULL THEN
      IF p_ies_frete = '1' OR p_docum.pct_comis > 0 THEN
         LET p_msg = 'Não foi possivel localizar o pedido\n',
                  'para o titulo: ',p_docum.num_docum CLIPPED,'\n' 
         CALL log0030_mensagem(p_msg,'excla')                 
         RETURN FALSE                                         
      END IF
   END IF                                                  
      
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1029_checa_comis_pedido()
#-----------------------------------#

   DEFINE p_qtd_item_nf      INTEGER,
          c_men_ped          CHAR(20),
          c_pedido           CHAR(7)
          
   IF NOT pol1029_del_comis_tmp() THEN
      RETURN FALSE
   END IF

   SELECT COUNT(pedido)                                #Will - 25/10/10
     INTO p_count                                          #Will - 25/10/10
     FROM fat_nf_item                                      #Will - 25/10/10
    WHERE empresa           = p_cod_empresa                #Will - 25/10/10
      AND trans_nota_fiscal = p_trans_nota_fiscal          #Will - 25/10/10
   
   IF p_count = 0 THEN                                     #Will - 25/10/10
      LET p_msg = 'Não foi possivel localizar a NF na\n',  #Will - 25/10/10
                  'tabela fat_nf_item para o titulo: ',    #Will - 25/10/10
                  p_docum.num_docum CLIPPED,'\n'           #Will - 25/10/10
      CALL log0030_mensagem(p_msg,'excla')                 #Will - 25/10/10
      RETURN FALSE                                         #Will - 25/10/10
   END IF                                                  #Will - 25/10/10
           
   LET p_qtd_item_nf    = 0
   LET p_qtd_item_comis = 0      
   LET p_val_comis      = 0
   LET p_docum.val_liq  = 0
   LET c_men_ped        = ""
   LET p_total_itens    = 0 
   
   SELECT SUM(val_liquido_item - val_desc_contab)        #Ivo  - 10/02/2014
     INTO p_total_itens                                  #Will - 25/10/10
     FROM fat_nf_item                                    #Will - 25/10/10
    WHERE empresa           = p_cod_empresa              #Will - 25/10/10
      AND trans_nota_fiscal = p_trans_nota_fiscal        #Will - 25/10/10
	   
	  IF STATUS <> 0 THEN
       LET p_total_itens  = p_val_tot_nff 
    END IF
	  	   

   DECLARE cq_nfi CURSOR FOR
    SELECT pedido,                                        #Will - 25/10/10
           seq_item_pedido,                               #Will - 25/10/10
           item,                                          #Will - 25/10/10
           qtd_item,                                      #Will - 25/10/10
           (val_liquido_item - val_desc_contab)           #Ivo - 10/02/2014
      FROM fat_nf_item                                    #Will - 25/10/10
     WHERE empresa           = p_cod_empresa              #Will - 25/10/10
       AND trans_nota_fiscal = p_trans_nota_fiscal        #Will - 25/10/10
 
   FOREACH cq_nfi INTO 
           p_num_pedido,    
           p_num_sequencia, 
           p_cod_item,      
           p_qtd_item,      
           p_val_liq_item   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_item:cq_nfi')
         RETURN FALSE
      END IF
      
	  	  
      LET p_qtd_item_nf = p_qtd_item_nf + 1
      LET p_val_prop = p_val_liq_item / p_total_itens  
      
      SELECT pct_comis_orig
        INTO p_pct_comis_orig
        FROM pct_comis_meta_444
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_seq_item  = p_num_sequencia
         AND cod_item      = p_cod_item

      IF STATUS = 100 THEN
         
         LET p_pct_comis_orig = p_docum.pct_comis
         LET p_pct_comis      = p_pct_comis_orig
         
         IF p_tip_relat = 'A' THEN
            IF NOT pol1029_ins_comis_tmp() THEN
               RETURN FALSE
            END IF
         END IF
         
         LET c_pedido = p_num_pedido
         
         IF c_men_ped = "" THEN
            LET c_men_ped = c_men_ped CLIPPED, c_pedido 
         ELSE
            LET c_men_ped = c_men_ped CLIPPED,"/", c_pedido 
         END IF
         
         INSERT INTO comis_erro_kana
          VALUES(p_cod_empresa, 
                 p_repres.cod_repres,
                 p_num_pedido, 
                 p_num_sequencia, 
                 p_cod_item,
                 "ITEM DO PEDIDO SEM COMISSAO")
          
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','comis_erro_kana')
            RETURN FALSE
         END IF
          
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','pct_comis_meta_444')
            RETURN FALSE
         END IF
      END IF

      LET p_qtd_item_comis = p_qtd_item_comis + 1 
      
      IF p_ies_meta = 'S' AND p_pct_comis_orig > 0 THEN
         IF NOT pol1029_le_pct_acres() THEN
            RETURN FALSE
         END IF
      
         LET p_pct_comis = p_pct_comis_orig + p_pct_acres
      
         IF p_tip_item = 'N' THEN
            IF p_pct_comis > p_pct_prod_novo THEN
               LET p_pct_comis = p_pct_prod_novo
            END IF
         ELSE
            IF p_pct_comis > p_pct_prod_normal THEN
               LET p_pct_comis = p_pct_prod_normal
            END IF
         END IF
      ELSE
         LET p_pct_comis = p_pct_comis_orig 
      END IF
                          
      LET p_val_base_com  = p_val_liqui * p_val_prop 
      LET p_comis_item    = p_val_base_com * p_pct_comis / 100
      LET p_val_comis     = p_val_comis + p_comis_item
      LET p_docum.val_liq = p_docum.val_liq + p_val_base_com
 
      IF NOT pol1029_atu_pct_comis() THEN
         RETURN FALSE
      END IF
      
      IF p_tip_relat = 'A' THEN
         IF NOT pol1029_ins_comis_tmp() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH

   IF p_qtd_item_comis = 0 THEN
      LET p_val_comis = 0
      DELETE FROM comis_erro_kana
       WHERE cod_empresa = p_cod_empresa
         AND cod_repres  = p_repres.cod_repres
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Deletando','comis_erro_kana')
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   IF p_qtd_item_comis < p_qtd_item_nf THEN
      LET p_msg = 'Titulo             :',p_docum.num_docum,'\n',
                  'Nota Fiscal        :',p_docum.num_docum_origem,'\n',
                  'Itens da NF        :',p_qtd_item_nf,'\n',
                  'Itens com comissão :',p_qtd_item_comis,'\n',
                  'Pedido(s) da NF....:',c_men_ped,'\n',
                  'Representante......:',p_repres.cod_repres,'\n'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION 

#-------------------------------#
FUNCTION pol1029_atu_pct_comis()
#-------------------------------#

   UPDATE pct_comis_meta_444
      SET pct_comis_meta = p_pct_comis
    WHERE cod_empresa  = p_cod_empresa
      AND num_pedido   = p_num_pedido
      AND num_seq_item = p_num_sequencia
      AND cod_item     = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('atualizando','pct_comis_meta_444')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1029_ins_comis_tmp()
#------------------------------#

   SELECT den_item_reduz
     INTO p_den_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo","item")
      RETURN FALSE
   END IF

   INSERT INTO comis_tmp_kana
    VALUES(p_num_pedido,
           p_num_sequencia,
           p_cod_item,
           p_den_reduz,
           p_pct_comis_orig,
           p_pct_comis)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Inserindo","comis_tmp_kana")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   

#-----------------------------#
FUNCTION pol1029_le_pct_acres()
#-----------------------------#

   DEFINE p_pct_acres_norm  DECIMAL(5,2),
          p_pct_acres_novo  DECIMAL(5,2),
          p_cod_familia     LIKE item.cod_familia
          
   SELECT cod_tip_carteira
     INTO p_cod_tip_carteira
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_num_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','pedidos')
      RETURN FALSE
   END IF
   
   SELECT comis_acres_normal,
          comis_acres_novo,
          comis_prod_normal,
          comis_prod_novo
     INTO p_pct_acres_norm,
          p_pct_acres_novo,
          p_pct_prod_normal,
          p_pct_prod_novo
     FROM par_comis_444
    WHERE cod_empresa = p_cod_emp_nf
      AND cod_tip_carteira = p_cod_tip_carteira
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_comis_444')
      RETURN FALSE
   END IF
   
   SELECT cod_familia
     INTO p_cod_familia
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF

   SELECT COUNT(cod_familia)
     INTO p_count
     FROM kana_novos_produtos_familias
    WHERE cod_familia   = p_cod_familia
      AND data_inicio  <= p_dat_emis_nf
      AND data_termino >= p_dat_emis_nf
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','kana_novos_produtos_familias')
      RETURN FALSE
   END IF

   IF p_count = 0 THEN
      LET p_pct_acres = p_pct_acres_norm
      LET p_tip_item = 'V'
      RETURN TRUE
   END IF
   
   SELECT COUNT(cod_item)
     INTO p_count
     FROM kana_novos_produtos_itens_retira
    WHERE cod_item      = p_cod_item
      AND data_inicio  <= p_dat_emis_nf
      AND data_termino >= p_dat_emis_nf
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','kana_novos_produtos_itens_retira')
      RETURN FALSE
   END IF

   IF p_count = 0 THEN
      LET p_pct_acres = p_pct_acres_novo
      LET p_tip_item = 'N'
   ELSE
      LET p_pct_acres = p_pct_acres_norm
      LET p_tip_item = 'V'
   END IF
   
   RETURN TRUE
   
END FUNCTION
   
#------------------------------#
REPORT pol1029_relat(p_relat)
#------------------------------#

   DEFINE p_relat     RECORD
          cod_repres  LIKE docum.cod_repres_1
   END RECORD
   
   DEFINE p_skip INTEGER
   
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
         PRINT COLUMN 001, "pol1029",
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
         PRINT COLUMN 001, "pol1029",
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
         LET p_tot_comis  = 0 
         LET p_tot_base   = 0
         LET p_cod_repres = p_relat.cod_repres

         PRINT COLUMN 001, '    CLIENTE      NOME RESUMIDO  PED REPRES LP  DUPLICATA   FATURA     DATA   VR DUPLICATA DES FRETE/TP      VR PAGO % COM   VR COMIS'
         PRINT COLUMN 001, '--------------- --------------- ---------- --- ----------- -------- -------- ------------ ------------ ------------ ----- ----------'
                 
      ON EVERY ROW
         
         PRINT COLUMN 001, p_docum.cod_cliente,
               COLUMN 017, p_docum.nom_cliente,
               COLUMN 033, p_docum.num_pedido[1,10],
               COLUMN 044, p_docum.lp,
               COLUMN 048, p_docum.num_docum[1,11],
               COLUMN 060, p_docum.num_docum_origem[1,8],
               COLUMN 069, p_dat_emis_nf USING 'dd/mm/yy',
               COLUMN 078, p_docum.val_liq_orig USING '#,###,##&.&&',
               COLUMN 091, p_docum.val_frete USING '###,##&.&&',
               COLUMN 102, p_ies_frete,
               COLUMN 104, p_docum.val_liq USING '#,###,##&.&&',
               COLUMN 117, p_docum.pct_comis USING '#&.&&',
               COLUMN 123, p_docum.val_comis USING '###,##&.&&'
         
         LET p_tot_comis = p_tot_comis + p_docum.val_comis
         LET p_tot_base  = p_tot_base + p_docum.val_liq
         LET p_skip = 0
         
         DECLARE cq_tmp CURSOR FOR
          SELECT num_pedido,
                 num_seq,
                 cod_item,
                 den_reduz,
                 pct_orig,
                 pct_calc
            FROM comis_tmp_kana

         FOREACH cq_tmp INTO           
                 p_num_pedido,       
                 p_num_sequencia,    
                 p_cod_item,         
                 p_den_reduz,        
                 p_pct_comis_orig,   
                 p_pct_comis
              
            IF STATUS <> 0 THEN
               CALL log003_err_sql("Lendo", "comis_tmp_kana:2")
               EXIT FOREACH
            END IF
            
            IF p_skip = 0 THEN
               SKIP 1 LINE
               LET p_skip = 1
            END IF
            
            PRINT COLUMN 004, ' Pedido: '  ,p_num_pedido     USING '&&&&&&',
                              ' Seq: '     ,p_num_sequencia  USING '&&&',
                              ' Item: '    ,p_cod_item, ' - ', p_den_reduz,
                              ' Pct Orig: ',p_pct_comis_orig USING '#&.&&',
                              ' Pct pago: ',p_pct_comis      USING '#&.&&'  
                 
         END FOREACH 
             
         SKIP p_skip LINE
         
      AFTER GROUP OF p_relat.cod_repres
      
         CALL pol1029_le_val_adiant()
         
         LET p_sub_tot_comis = p_tot_comis - p_val_adiant
         LET p_sub_tot_base  = p_tot_base - p_val_base
         
         LET p_val_irrf  = p_sub_tot_comis * 1.5 / 100
         LET p_liq_receb = p_sub_tot_comis - p_val_irrf
         
         CALL pol1029_ins_val_adiant()
         
         SKIP 1 LINES
         PRINT COLUMN 051, "TOTAL DO REPRESENTANTE: R$",
               COLUMN 104, p_tot_base  USING '#,###,##&.&&',
               COLUMN 123, p_tot_comis USING '###,##&.&&'

         PRINT COLUMN 051, " VALOR DO ADIANTAMENTO: R$",
               COLUMN 104, p_val_base   USING '#,###,##&.&&',
               COLUMN 123, p_val_adiant USING '###,##&.&&'
         PRINT COLUMN 123, '----------'

         PRINT COLUMN 051, "       SUB TOTAL BRUTO: R$",
               COLUMN 104, p_sub_tot_base  USING '#,###,##&.&&',
               COLUMN 123, p_sub_tot_comis USING '###,##&.&&'

         PRINT COLUMN 051, "IRRF: 1,50%      VALOR: R$",
               COLUMN 124, p_val_irrf USING '##,##&.&&'
                    
         PRINT COLUMN 051, "VAL. LIQUIDO A RECEBER: R$",
               COLUMN 123, p_liq_receb USING '###,##&.&&'
                              
         LET p_tot_ger_com_pgto = p_tot_ger_com_pgto + p_sub_tot_comis
         #LET p_tot_ger_dupl = p_tot_ger_dupl + p_tot_base
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

#-------------------------------#
FUNCTION pol1029_le_val_adiant()
#-------------------------------#

   LET p_val_adiant = 0
   LET p_val_base   = 0

   IF p_tela.tip_proces = 'Q' THEN
      RETURN
   END IF
       
   SELECT val_base,
          val_adiant
     INTO p_val_base,
          p_val_adiant
     FROM repres_adiant_444
    WHERE cod_repres = p_cod_repres
      AND ano_mes    = p_ano_mes_proc
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','repres_adiant_444')
   END IF
   
END FUNCTION

#--------------------------------#
FUNCTION pol1029_ins_val_adiant()
#--------------------------------#

   IF p_tela.tip_proces = 'M' THEN
      RETURN
   END IF

   DELETE FROM repres_adiant_444
    WHERE cod_repres = p_cod_repres
      AND ano_mes    = p_ano_mes_proc

   INSERT INTO repres_adiant_444
    VALUES(p_cod_repres,
           p_ano_mes_proc,
           p_tot_base,
           p_tot_comis,
           p_val_irrf)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','repres_adiant_444')
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1029_cria_tmp()
#--------------------------#
    
   CREATE TEMP TABLE repres_kana_temp
   (
      cod_repres   DECIMAL(4,0)
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","repres_kana_temp")
      RETURN FALSE
   END IF

   DROP TABLE comis_tmp_kana;

   CREATE  TABLE comis_tmp_kana (
      num_pedido INTEGER,
      num_seq    INTEGER,
      cod_item   CHAR(15),
      den_reduz  CHAR(18),
      pct_orig   DECIMAL(5,2),
      pct_calc   DECIMAL(5,2)
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","comis_tmp_kana")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1029_cria_tab_erro()
#------------------------------#

   DROP TABLE comis_erro_kana;

   CREATE  TABLE comis_erro_kana (
      cod_empresa CHAR(02),
      cod_repres  DECIMAL(4,0),
      num_pedido  INTEGER,
      num_seq     INTEGER,
      cod_item    CHAR(15),
      den_erro    CHAR(30)
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","comis_erro_kana")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1029_del_tmp_repres()
#--------------------------------#

   DELETE FROM repres_kana_temp
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando","repres_kana_temp")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1029_del_comis_tmp()
#-------------------------------#

   DELETE FROM comis_tmp_kana
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando","comis_tmp_kana")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-------------------------------#
FUNCTION pol1029_aceita_repres()
#-------------------------------#

   INPUT ARRAY pr_repres
      WITHOUT DEFAULTS FROM sr_repres.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD cod_repres
         IF pr_repres[p_index].cod_repres IS NOT NULL THEN
            IF pol1029_repetiu_cod() THEN
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
         CALL pol1029_popup()
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      IF pol1029_grava_repres() THEN
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
FUNCTION pol1029_repetiu_cod()
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
FUNCTION pol1029_grava_repres()
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
FUNCTION pol1029_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_repres)
         CALL log009_popup(8,15,"REPRESENTATES","representante",
                     "cod_repres","raz_social","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1029
         IF p_codigo IS NOT NULL THEN
            LET pr_repres[p_index].cod_repres = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_repres[s_index].cod_repres
         END IF
   
      WHEN INFIELD(cod_emp_dupl)
         CALL log009_popup(8,25,"EMPRESAS","empresa",
                     "cod_empresa","den_empresa","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol1029
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_emp_dupl = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_emp_dupl
            
         END IF

   END CASE

END FUNCTION

#--------------------------#
FUNCTION pol1029_tem_erro()
#--------------------------#

   SELECT COUNT(cod_empresa)
     INTO p_count
     FROM comis_erro_kana
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','comis_erro_kana')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      CALL log0030_mensagem('Não existem inconsistências a listar','excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1029_imprime_erros()
#-------------------------------#

   IF NOT pol1029_le_den_empresa() THEN
      RETURN
   END IF   

   DECLARE cq_erro CURSOR FOR
    SELECT cod_repres,
           num_pedido,
           num_seq,   
           cod_item,  
           den_erro  
      FROM comis_erro_kana
     WHERE cod_empresa = p_cod_empresa

   FOREACH cq_erro INTO 
           p_cod_repres,
           p_num_pedido,
           p_num_sequencia,
           p_cod_item,
           p_den_erro

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Inconsistências')
         EXIT FOREACH
      END IF
      
      OUTPUT TO REPORT pol1029_erro() 

   END FOREACH
   
END FUNCTION

#----------------------#
REPORT pol1029_erro()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
      
      FIRST PAGE HEADER  
      
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 070, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1029",
               COLUMN 020, "PEDIDOS/ITENS SEM LANCAMENTO DE COMISSAO",
               COLUMN 065, "EMIS: ", TODAY USING "dd/mm/yyyy"

         PRINT COLUMN 002, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, 'REPR PEDIDO SEQ ITEM            MENSAGEM'
         PRINT COLUMN 002, '---- ------ --- --------------- ------------------------------'
           
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 070, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1029",
               COLUMN 020, "PEDIDOS/ITENS SEM LANCAMENTO DE COMISSAO",
               COLUMN 065, "EMIS: ", TODAY USING "dd/mm/yyyy"

         PRINT COLUMN 002, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, 'REPR PEDIDO SEQ ITEM            MENSAGEM'
         PRINT COLUMN 002, '---- ------ --- --------------- ------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_cod_repres    USING "####",
               COLUMN 007, p_num_pedido    USING "######",
               COLUMN 014, p_num_sequencia USING "###",      
               COLUMN 018, p_cod_item,
               COLUMN 034, p_den_erro

      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#--------------------------------#
 FUNCTION pol1029_le_den_empresa()
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

#-----------------------#
 FUNCTION pol1029_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------FIM DO PROGRAMA----------------------#