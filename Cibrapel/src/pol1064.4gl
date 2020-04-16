#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1064                                                 #
# OBJETIVO: RELATÓRIO P/ PAGAMENTO DE APARAS - CIBRAPEL             #
# AUTOR...: WILL                                                    #
# DATA....: 06/10/10                                                #
# CONVERSÃO 10.02: 16/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
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
          P_comprime           CHAR(01),
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
          p_ies_info           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          p_chave              CHAR(500),
          p_peso_umd           DECIMAL(10,3),
          p_peso_dif           DECIMAL(10,3),
          p_qtd_ap             INTEGER,
          p_val_pedagio        DECIMAL(7,2),
          p_raz_social         LIKE fornecedor.raz_social,
          p_num_ap             LIKE ap.num_ap,
          p_dat_vencto_s_desc  LIKE ap.dat_vencto_s_desc,
          p_num_ad             LIKE ad_ap.num_ad,
          p_num_nf             LIKE ad_mestre.num_nf,
          p_ser_nf             LIKE ad_mestre.ser_nf,
          p_ssr_nf             LIKE ad_mestre.ssr_nf,
          p_cod_fornecedor     LIKE ad_mestre.cod_fornecedor,
          p_num_aviso_rec      LIKE nf_sup.num_aviso_rec,
          p_cod_item           LIKE aviso_rec.cod_item,       
          p_pre_unit_nf        LIKE aviso_rec.pre_unit_nf,    
          p_qtd_recebida       LIKE aviso_rec.qtd_recebida,   
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_cod_familia        LIKE item.cod_familia,
          p_pct_umd_med        LIKE umd_aparas_885.pct_umd_med,
          p_pct_umid_pad       LIKE umd_aparas_885.pct_umd_med,
          p_cod_empresa_destin LIKE emp_orig_destino.cod_empresa_destin,
          p_val_saldo_adiant   LIKE adiant.val_saldo_adiant,
          p_num_seq            LIKE aviso_rec.num_seq,
          p_preco_cotacao      LIKE umd_aparas_885.preco_cotacao,
          p_qtd_contagem       LIKE cont_aparas_885.qtd_contagem,
          p_total              LIKE aviso_rec.val_liquido_item,
          p_diferenca          LIKE aviso_rec.val_liquido_item,
          p_num_ap_ger         LIKE ap.num_ap,
          p_dat_vencto_ger     LIKE ap.dat_vencto_s_desc,
          p_val_nom_ap         LIKE ap.val_nom_ap,
          p_val_nom_ap_ger     LIKE ap.val_nom_ap,
          p_tot_pagar          LIKE aviso_rec.val_liquido_item,
          p_dat_emis_nf        LIKE nf_sup.dat_emis_nf,
          p_num_parcela        LIKE ap.num_parcela
                       
   DEFINE p_tela               RECORD 
          dat_inicial          DATE,
          dat_final            DATE,
          cod_fornecedor       LIKE fornecedor.cod_fornecedor,
          tip_relat            CHAR(01)
   END RECORD  
   
END GLOBALS

DEFINE sql_stmt                CHAR(600)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1064-10.02.00  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1064_controle()
   END IF
END MAIN

#---------------------------#
 FUNCTION pol1064_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1064") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1064 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol1064_le_umidade() THEN
      RETURN
   END IF

   CALL pol1064_limpa_tela()

   IF NOT pol1064_cria_tab_tmp() THEN
      RETURN
   END IF
      
   LET p_ies_info = FALSE  
   
   MENU "OPCAO"
      COMMAND "Informar" "Informe dados á serem listados."
         CALL pol1064_Informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Dados informados com sucesso!!!'
            LET p_ies_info = TRUE
            NEXT OPTION "Listar" 
         ELSE
            LET p_ies_info = FALSE
            ERROR 'Operação cancelada'
         END IF
      COMMAND "Listar" "Listagem dos parâmetros já informados com sucesso."
         IF p_ies_info THEN
            CALL pol1064_listar()
         ELSE
            ERROR "Informe primeiro os parâmetros!!!"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa."
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1064

END FUNCTION

#----------------------------#
FUNCTION pol1064_le_umidade()
#----------------------------#

   SELECT pct_umid_pad
     INTO p_pct_umid_pad
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','parametros_885')
      RETURN FALSE
   END IF

   RETURN TRUE 

END FUNCTION

#----------------------------#
 FUNCTION pol1064_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 

#-----------------------------#
FUNCTION pol1064_cria_tab_tmp()
#-----------------------------#

   DROP TABLE w_pol1064_885
   
   CREATE TABLE w_pol1064_885
     (
      num_nf          DECIMAL(7,0),
      dat_emis_nf     DATE,
      cod_fornecedor  CHAR(15),
      num_ap_ofic     DECIMAL(6,0),
      num_adiant_ofic DECIMAL(6,0),
      num_ap_ger      DECIMAL(6,0)
     );
     
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("criando","w_pol1064_885")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------#
 FUNCTION pol1064_Informar()
#--------------------------#
      
   CALL pol1064_limpa_tela()
   
   INITIALIZE p_tela TO NULL
   LET p_tela.tip_relat = 'V'
   
   DELETE FROM w_pol1064_885
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletanto','w_pol1064_885')
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
   
   AFTER FIELD dat_inicial
      IF p_tela.dat_inicial IS NULL THEN
         ERROR "Campo com prenchimento obrigatório !!!"
         NEXT FIELD dat_inicial
      END IF
      
   AFTER FIELD dat_final
      IF p_tela.dat_final IS NULL THEN
         ERROR "Campo com prenchimento obrigatório !!!"
         NEXT FIELD dat_final
      END IF
      
      IF p_tela.dat_inicial > p_tela.dat_final THEN
         ERROR "A data inicial do periodo não pode ser maior que a data final do periodo !!!"
         NEXT FIELD dat_inicial
      ELSE
         IF p_tela.dat_final - p_tela.dat_inicial > 365 THEN
            ERROR "O periodo para listagem não pode ser maior que 365 dias !!!"
            NEXT FIELD dat_inicial
         END IF 
      END IF 
          
   AFTER FIELD cod_fornecedor
      IF p_tela.cod_fornecedor IS NOT NULL THEN
         
         SELECT raz_social                                    
           INTO p_raz_social                                  
           FROM fornecedor                                    
          WHERE cod_fornecedor = p_tela.cod_fornecedor        
                                                              
         IF STATUS = 100 THEN                                 
            ERROR "Fornecedor não encontrado !!!"             
            NEXT FIELD cod_fornecedor                         
         ELSE                                                 
            IF STATUS <> 0 THEN                               
               CALL log003_err_sql("lendo", "fornecedor")     
               RETURN FALSE                                   
            END IF                                            
         END IF                                               
      ELSE
         LET p_raz_social = NULL
      END IF
         
      DISPLAY p_raz_social TO raz_social

   AFTER FIELD tip_relat
        IF p_tela.tip_relat IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD tip_relat
        END IF     
           
   ON KEY (control-z)
      CALL pol1064_popup()
    
   END INPUT 
    
  IF INT_FLAG THEN
     CALL pol1064_limpa_tela()
     RETURN FALSE
  END IF
   
  RETURN TRUE
   
END FUNCTION

#-----------------------#
 FUNCTION pol1064_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_fornecedor = p_codigo
            DISPLAY p_codigo TO cod_fornecedor
         END IF
         
   END CASE 

END FUNCTION       
         
#------------------------#
 FUNCTION pol1064_Listar()
#------------------------#

   CALL pol1064_inicializa_relat()
   
   IF p_tela.tip_relat = 'V' THEN
      CALL pol1064_por_vencto_ap() RETURNING p_status
   ELSE
      CALL pol1064_por_entrada_nf() RETURNING p_status
   END IF

   CALL pol1064_finaliza_relat()

END FUNCTION
   
#----------------------------------#
FUNCTION pol1064_inicializa_relat()
#----------------------------------#
      
   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1064_relat TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1064.tmp' 
         START REPORT pol1064_relat TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1064_relat TO p_nom_arquivo
   END IF
          
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_count = 0

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'Empresa')
      RETURN FALSE
   END IF 

   IF NOT pol1064_le_orig_destino() THEN
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1064_finaliza_relat()
#--------------------------------#

   FINISH REPORT pol1064_relat

   FINISH REPORT pol0778_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
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
      ERROR 'Relatório gerado com sucesso !!!'
   END IF
     
END FUNCTION 

#------------------------------#
FUNCTION pol1064_por_vencto_ap()
#------------------------------#

   CALL pol1064_monta_select_ap()

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao CURSOR FOR var_query

   FOREACH cq_padrao INTO
           p_cod_fornecedor,
           p_num_ap,
           p_dat_vencto_s_desc,
           p_val_nom_ap,
           p_num_parcela 
  
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','cursor: cq_padrao')
         RETURN FALSE
      END IF
      
      ERROR 'Imprimindo AP' , p_num_ap
            
      SELECT num_ad
        INTO p_num_ad
        FROM ad_ap
       WHERE cod_empresa = p_cod_empresa_destin
         AND num_ap      = p_num_ap
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','ad_ap')
         RETURN FALSE
      END IF
      
      SELECT COUNT(num_ap)
        INTO p_qtd_ap
        FROM ad_ap
       WHERE cod_empresa = p_cod_empresa_destin
         AND num_ad      = p_num_ad

      IF STATUS <> 0 OR p_qtd_ap = 0 THEN
         CALL log003_err_sql('lendo','ap_ad:')
         RETURN FALSE
      END IF
      
      SELECT num_nf,
             ser_nf,
             ssr_nf
        INTO p_num_nf,
             p_ser_nf,
             p_ssr_nf
        FROM ad_mestre
       WHERE cod_empresa = p_cod_empresa_destin
         AND num_ad      = p_num_ad
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','ad_mestre')
         RETURN FALSE
      END IF 
      
      IF p_ser_nf IS NULL THEN
         LET p_ser_nf = " "
      END IF
      
      IF p_ssr_nf IS NULL THEN
         LET p_ssr_nf = " "
      END IF
      
      IF NOT pol1064_is_numero(p_num_nf) THEN
         CONTINUE FOREACH
      END IF
      
      SELECT num_aviso_rec,
             dat_emis_nf
        INTO p_num_aviso_rec,
             p_dat_emis_nf
        FROM nf_sup
       WHERE cod_empresa    = p_cod_empresa
         AND num_nf         = p_num_nf
         AND ser_nf         = p_ser_nf
         AND ssr_nf         = p_ssr_nf
         AND cod_fornecedor = p_cod_fornecedor
         
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','nf_sup')
            RETURN FALSE
         END IF
      END IF

      SELECT val_pedagio
        INTO p_val_pedagio
        FROM ar_aparas_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso_rec
         AND cod_status    = 'P'
         
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','ar_aparas_885')
            RETURN FALSE
         END IF
      END IF

      SELECT cod_item,
             pre_unit_nf,
             qtd_recebida,
             num_seq
        INTO p_cod_item,
             p_pre_unit_nf,
             p_qtd_recebida,
             p_num_seq
        FROM aviso_rec
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso_rec
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','aviso_rec')
         RETURN FALSE
      END IF 

      SELECT raz_social
        INTO p_raz_social
        FROM fornecedor
       WHERE cod_fornecedor = p_cod_fornecedor
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','fornecedor')
         RETURN FALSE
      END IF
              
      SELECT pct_umd_med,
             preco_cotacao
        INTO p_pct_umd_med,
             p_preco_cotacao
        FROM umd_aparas_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso_rec
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','umd_aparas_885')
         RETURN FALSE
      END IF
      
      IF p_preco_cotacao IS NULL OR p_preco_cotacao < 0 THEN
         LET p_preco_cotacao = 0
      END IF
            
      SELECT den_item_reduz,
             cod_familia
        INTO p_den_item_reduz,
             p_cod_familia
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','item')
         RETURN FALSE
      END IF
                           
      SELECT SUM(qtd_contagem)
        INTO p_qtd_contagem
        FROM cont_aparas_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso_rec
         AND num_seq_ar    = p_num_seq
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','cont_aparas_885')
         RETURN FALSE
      END IF  
      
      IF p_qtd_contagem IS NULL OR p_qtd_contagem < 0 THEN
         LET p_qtd_contagem = 0
      END IF
      
      LET p_total = p_qtd_contagem * p_preco_cotacao      

      SELECT val_saldo_adiant
        INTO p_val_saldo_adiant
        FROM adiant
       WHERE cod_empresa    = p_cod_empresa_destin
         AND cod_fornecedor = p_cod_fornecedor
         AND num_ad_nf_orig = p_num_nf
         AND ser_nf         = p_ser_nf
         AND ssr_nf         = p_ssr_nf
         
      IF STATUS = 100 THEN
         LET p_val_saldo_adiant = 0
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo","adiant")
            RETURN FALSE
         END IF
      END IF

      IF p_val_saldo_adiant > 0 THEN
         LET p_val_saldo_adiant = p_val_saldo_adiant / p_qtd_ap
         LET p_num_ap_ger     = NULL                                                
         LET p_dat_vencto_ger = " "
         LET p_val_nom_ap_ger = 0                                                   
      ELSE
         IF NOT pol1064_le_titulos_ger() THEN
            RETURN FALSE
         END IF
      END IF
            
      LET p_tot_pagar = p_val_nom_ap + p_val_nom_ap_ger - p_val_saldo_adiant
      #LET p_tot_pagar = p_val_nom_ap_ger - p_val_saldo_adiant
      LET p_peso_umd = p_qtd_contagem * p_pct_umd_med / 100  

      if p_pct_umd_med > p_pct_umid_pad then
         let p_peso_dif = (p_qtd_contagem * (p_pct_umd_med - p_pct_umid_pad)) / 100
      else
         let p_peso_dif = 0
      end if    

      OUTPUT TO REPORT pol1064_relat(p_cod_fornecedor) 
      
      LET p_count = 1 
      
   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1064_is_numero(p_num_nota)
#-------------------------------------#

   DEFINE p_num_nota CHAR(07),
          p_ind      INTEGER
   
   FOR p_ind = 1 TO LENGTH(p_num_nota)
      IF p_num_nota[p_ind] MATCHES '[0123456789]' THEN
      ELSE
         RETURN FALSE
      END IF
   END FOR
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1064_le_titulos_ger()
#--------------------------------#
   
   DEFINE p_num_ad_ger INTEGER,
          p_tem_ap     SMALLINT
   
   LET p_tem_ap = FALSE
   
   SELECT num_ad
     INTO p_num_ad_ger
     FROM ad_mestre_885
    WHERE cod_empresa    = p_cod_empresa_destin
      AND cod_fornecedor = p_cod_fornecedor   
      AND num_nf         = p_num_nf           
      AND ser_nf         = p_ser_nf           
      AND ssr_nf         = p_ssr_nf           

   IF STATUS = 100 THEN
      LET p_num_ap_ger     = NULL                                                
      LET p_dat_vencto_ger = " "
      LET p_val_nom_ap_ger = 0                                                   
      RETURN TRUE     
   ELSE
      IF STATUS <> 0 THEN
         ERROR 'Operação: lendo AD da empresa: ', p_cod_emp_ger
         CALL log003_err_sql('Lendo','ad_mestre')
         RETURN FALSE
      END IF
   END IF   

   DECLARE cq_ad_ap CURSOR FOR
    SELECT num_ap
      FROM ad_ap_885
     WHERE cod_empresa = p_cod_empresa_destin
       AND num_ad      = p_num_ad_ger

   FOREACH cq_ad_ap INTO p_num_ap_ger
   
      IF STATUS <> 0 THEN
         ERROR 'Operação: lendo AP da empresa: ', p_cod_emp_ger
         CALL log003_err_sql('Lendo','cq_ad_ap')
         RETURN FALSE
      END IF   
   
      SELECT dat_vencto_s_desc,                                            
             val_nom_ap                                                          
        INTO p_dat_vencto_ger,                                                   
             p_val_nom_ap_ger                                                    
        FROM ap_885                                                              
       WHERE cod_empresa = p_cod_empresa_destin                               
         AND num_ap      = p_num_ap_ger
         AND num_parcela = p_num_parcela                        
         AND ies_versao_atual = 'S'                                
      
      IF STATUS = 0 THEN
         LET p_tem_ap = TRUE
         EXIT FOREACH
      ELSE
         IF STATUS <> 100 THEN
            ERROR 'Operação: lendo AP da empresa: ', p_cod_emp_ger
            CALL log003_err_sql('Lendo','ap:cq_ad_ap')
            RETURN FALSE
         END IF
      END IF
   
   END FOREACH  
                                                                   
   IF NOT p_tem_ap THEN                                                       
      LET p_num_ap_ger     = NULL                                                
      LET p_dat_vencto_ger = " "
      LET p_val_nom_ap_ger = 0                                                   
   END IF                                                                        
      
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1064_le_orig_destino()
#----------------------------------#
      
   SELECT cod_empresa_destin                                  
     INTO p_cod_empresa_destin                             
     FROM emp_orig_destino                                 
    WHERE cod_empresa_orig = p_cod_empresa                 
                                                              
   IF STATUS = 100 THEN                                    
      LET p_cod_empresa_destin = p_cod_empresa             
   ELSE                                                    
      IF STATUS <> 0 THEN                                  
         CALL log003_err_sql("lendo","emp_orig_destino")   
         RETURN FALSE                                      
      END IF                                               
   END IF                                                  
   
   RETURN TRUE
   
END FUNCTION
                                                              
#---------------------------------#
 FUNCTION pol1064_monta_select_ap()
#---------------------------------#
   
   INITIALIZE p_chave TO NULL
   
   LET p_chave = " cod_empresa = '", p_cod_empresa_destin,"' "
   LET p_chave = p_chave CLIPPED,    
          " AND dat_vencto_s_desc >= '",p_tela.dat_inicial,"' "
   LET p_chave = p_chave CLIPPED,    
          " AND dat_vencto_s_desc <= '",p_tela.dat_final,"' "
   IF p_tela.cod_fornecedor IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND cod_fornecedor = '",p_tela.cod_fornecedor,"' "
   END IF
   
   LET sql_stmt = " SELECT cod_fornecedor, num_ap, dat_vencto_s_desc, val_nom_ap, ",
                  " num_parcela FROM ap WHERE ",p_chave CLIPPED,
                  " AND ies_versao_atual = 'S' ",
                  " AND dat_pgto IS NULL ", 
                  " AND cod_fornecedor in ",
                  "     (SELECT distinct fornecedor FROM sup_par_fornecedor ",
                  "       WHERE parametro_numerico = 10 ",
                  "         AND parametro = 'subtipo_fornecedor') ", 
                  " ORDER BY cod_fornecedor, dat_vencto_s_desc"
                  
END FUNCTION

#---------------------------------#
 FUNCTION pol1064_monta_select_nf()
#---------------------------------#
   
   INITIALIZE p_chave TO NULL
   
   LET p_chave = " cod_empresa = '", p_cod_empresa,"' "
   LET p_chave = p_chave CLIPPED,    
          " AND dat_entrada_nf >= '",p_tela.dat_inicial,"' "
   LET p_chave = p_chave CLIPPED,    
          " AND dat_entrada_nf <= '",p_tela.dat_final,"' "
   
   IF p_tela.cod_fornecedor IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND cod_fornecedor = '",p_tela.cod_fornecedor,"' "
   END IF

   LET sql_stmt = " SELECT num_aviso_rec, cod_fornecedor, ",
                  " num_nf, ser_nf, ssr_nf, dat_entrada_nf",
                  " FROM nf_sup WHERE ",p_chave CLIPPED,
                  " AND ies_especie_nf != 'NFS' ",  
                  " AND ies_especie_nf != 'CON' ",  
                  " AND cod_fornecedor in ",
                  "     (SELECT distinct fornecedor FROM sup_par_fornecedor ",
                  "       WHERE parametro_numerico = 10 ",
                  "         AND parametro = 'subtipo_fornecedor') ", 
                  " ORDER BY cod_fornecedor, dat_entrada_nf"
                  
END FUNCTION

#--------------------------------#
FUNCTION pol1064_por_entrada_nf()
#--------------------------------#

   CALL pol1064_monta_select_nf()

   PREPARE v_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF
   
   DECLARE cq_nf CURSOR FOR v_query

   FOREACH cq_nf INTO 
           p_num_aviso_rec,
           p_cod_fornecedor,
           p_num_nf,
           p_ser_nf,
           p_ssr_nf,
           p_dat_emis_nf
  
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','cursor: cq_nf')
         RETURN FALSE
      END IF

      ERROR 'Imprimindo NF' , p_num_nf

      SELECT val_pedagio
        INTO p_val_pedagio
        FROM ar_aparas_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso_rec
         AND cod_status    = 'P'
         
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','ar_aparas_885')
            RETURN FALSE
         END IF
      END IF
      
      IF p_ser_nf IS NULL THEN
         LET p_ser_nf = " "
      END IF
      
      IF p_ssr_nf IS NULL THEN
         LET p_ssr_nf = " "
      END IF

      SELECT num_ad
        INTO p_num_ad
        FROM ad_mestre
       WHERE cod_empresa    = p_cod_empresa_destin
         AND cod_fornecedor = p_cod_fornecedor   
         AND num_nf         = p_num_nf           
         AND ser_nf         = p_ser_nf           
         AND ssr_nf         = p_ssr_nf           
         
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','ad_mestre')
            RETURN FALSE
         END IF
      END IF 

      SELECT COUNT(num_ap)
        INTO p_qtd_ap
        FROM ad_ap
       WHERE cod_empresa = p_cod_empresa_destin
         AND num_ad      = p_num_ad

      IF STATUS <> 0 OR p_qtd_ap = 0 THEN
         CALL log003_err_sql('lendo','ap_ad:')
         RETURN FALSE
      END IF
      
      DECLARE cq_aps CURSOR FOR
       SELECT num_ap
         FROM ad_ap
        WHERE cod_empresa = p_cod_empresa_destin
          AND num_ad      = p_num_ad
      
      FOREACH cq_aps INTO p_num_ap
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','ad_ap:cq_aps')
            RETURN FALSE
         END IF

         SELECT dat_vencto_s_desc,
                val_nom_ap,
                num_parcela
           INTO p_dat_vencto_s_desc,
                p_val_nom_ap,
                p_num_parcela
           FROM ap
          WHERE cod_empresa = p_cod_empresa_destin
            AND num_aP      = p_num_ap
            AND ies_versao_atual = 'S'
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','ap:cq_aps')
            RETURN FALSE
         END IF
      
         SELECT raz_social                                            
           INTO p_raz_social                                          
           FROM fornecedor                                            
          WHERE cod_fornecedor = p_cod_fornecedor                     
                                                                      
         IF STATUS <> 0 THEN                                          
            CALL log003_err_sql('lendo','fornecedor:cq_aps')          
            RETURN FALSE                                              
         END IF                                                       
              
         SELECT cod_item,                                         
                pre_unit_nf,                                      
                qtd_recebida,                                     
                num_seq                                           
           INTO p_cod_item,                                       
                p_pre_unit_nf,                                    
                p_qtd_recebida,                                   
                p_num_seq                                         
           FROM aviso_rec                                         
          WHERE cod_empresa   = p_cod_empresa                     
            AND num_aviso_rec = p_num_aviso_rec                   
                                                                  
         IF STATUS <> 0 THEN                                      
            CALL log003_err_sql('lendo','aviso_rec')              
            RETURN FALSE                                          
         END IF                                                   

         SELECT pct_umd_med,                                           
                preco_cotacao                                          
           INTO p_pct_umd_med,                                         
                p_preco_cotacao                                        
           FROM umd_aparas_885                                         
          WHERE cod_empresa   = p_cod_empresa                          
            AND num_aviso_rec = p_num_aviso_rec                        
            AND num_seq_ar    = p_num_seq                              
                                                                       
         IF STATUS <> 0 THEN                                           
            CALL log003_err_sql('lendo','umd_aparas_885')              
            RETURN FALSE                                               
         END IF                                                        
      
         IF p_preco_cotacao IS NULL OR p_preco_cotacao < 0 THEN                         
            LET p_preco_cotacao = 0                                                     
         END IF                                                                         
                                                                                        
         SELECT den_item_reduz,                                                         
                cod_familia                                                             
           INTO p_den_item_reduz,                                                       
                p_cod_familia                                                           
           FROM item                                                                    
          WHERE cod_empresa = p_cod_empresa                                             
            AND cod_item    = p_cod_item                                                
                                                                                        
         IF STATUS <> 0 THEN                                                            
            CALL log003_err_sql('lendo','item')                                         
            RETURN FALSE                                                                
         END IF                                                                         

         SELECT SUM(qtd_contagem)                                
           INTO p_qtd_contagem                                   
           FROM cont_aparas_885                                  
          WHERE cod_empresa   = p_cod_empresa                    
            AND num_aviso_rec = p_num_aviso_rec                  
            AND num_seq_ar    = p_num_seq                        
                                                                 
         IF STATUS <> 0 THEN                                     
            CALL log003_err_sql('lendo','cont_aparas_885')       
            RETURN FALSE                                         
         END IF                                                  

         IF p_qtd_contagem IS NULL OR p_qtd_contagem < 0 THEN
            LET p_qtd_contagem = 0
         END IF
      
         LET p_total = p_qtd_contagem * p_preco_cotacao      

         SELECT val_saldo_adiant                                      
           INTO p_val_saldo_adiant                                    
           FROM adiant                                                
          WHERE cod_empresa    = p_cod_empresa_destin                 
            AND cod_fornecedor = p_cod_fornecedor                     
            AND num_ad_nf_orig = p_num_nf                             
            AND ser_nf         = p_ser_nf                             
            AND ssr_nf         = p_ssr_nf                             
                                                                      
         IF STATUS = 100 THEN                                         
            LET p_val_saldo_adiant = 0                                
         ELSE                                                         
            IF STATUS <> 0 THEN                                       
               CALL log003_err_sql("lendo","adiant")                  
               RETURN FALSE                                           
            END IF                                                    
         END IF                                                       
      
         IF p_val_saldo_adiant > 0 THEN
            LET p_val_saldo_adiant = p_val_saldo_adiant / p_qtd_ap
            LET p_num_ap_ger     = NULL                                                
            LET p_dat_vencto_ger = " "
            LET p_val_nom_ap_ger = 0                                                   
         ELSE
            IF NOT pol1064_le_titulos_ger() THEN
               RETURN FALSE
            END IF
         END IF
      
         LET p_tot_pagar = p_val_nom_ap + p_val_nom_ap_ger - p_val_saldo_adiant
         #LET p_tot_pagar = p_val_nom_ap_ger - p_val_saldo_adiant
         LET p_peso_umd = p_qtd_contagem * p_pct_umd_med / 100

         if p_pct_umd_med > p_pct_umid_pad then
            let p_peso_dif = (p_qtd_contagem * (p_pct_umd_med - p_pct_umid_pad)) / 100
         else
            let p_peso_dif = 0
         end if    
      
         OUTPUT TO REPORT pol1064_relat(p_cod_fornecedor) 
      
         LET p_count = 1 
      
      END FOREACH
      
   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------------#
 REPORT pol1064_relat(p_cod_fornecedor)
#-------------------------------------#
  
  DEFINE p_cod_fornecedor LIKE fornecedor.cod_fornecedor,
         p_med_pct        DECIMAL(5,2),
         p_tot_peso_umd   DECIMAL(10,3),
         p_tot_peso_dif   DECIMAL(10,3),
         p_tot_contagem   DECIMAL(10,3)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 2
          BOTTOM MARGIN 2
          PAGE   LENGTH 66
          
  ORDER EXTERNAL BY p_cod_fornecedor     
          
   FORMAT
      
      FIRST PAGE HEADER  
      
         PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001, p_den_empresa, p_comprime, 
               COLUMN 208, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1064",
               COLUMN 044, "TITULOS PARA PAGAMENTO DE APARAS",
               COLUMN 079, p_tela.dat_inicial, " - ", p_tela.dat_final,
               COLUMN 189, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa, p_comprime, 
               COLUMN 175, "PAG. ", PAGENO USING "##&"
                              
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      
      BEFORE GROUP OF p_cod_fornecedor
         SKIP 2 LINES
         PRINT COLUMN 003, "Fornecedor: ", p_cod_fornecedor, " - ", p_raz_social
         PRINT
         PRINT COLUMN 001, " Emissao     NF    Desc. reduz. item   Qtd recebida   P unit Titulo Vencimento   Valor     Peso balanca   P cot    Total    % Umd   Peso Umd   Titulo Vencimento   Valor    Adiantamento Pedagio    A pagar    Dif Umd"
         PRINT COLUMN 001, "---------- ------- ------------------ --------------- ------ ------ ---------- ---------- --------------- ------ ---------- ----- ------------ ------ ---------- ---------- ------------ ------- ------------- ---------"
         
      ON EVERY ROW
         
         PRINT COLUMN 001, p_dat_emis_nf,
               COLUMN 012, p_num_nf             USING '#######',
               COLUMN 020, p_den_item_reduz,
               COLUMN 039, p_qtd_recebida       USING '###,###,##&.&&&',
               COLUMN 055, p_pre_unit_nf        USING '##&.&&',
               COLUMN 062, p_num_ap             USING '######',
               COLUMN 069, p_dat_vencto_s_desc,
               COLUMN 080, p_val_nom_ap         USING '###,##&.&&',
               COLUMN 091, p_qtd_contagem       USING '###,###,##&.&&&',
               COLUMN 107, p_preco_cotacao      USING '&.&&&&',
               COLUMN 114, p_total              USING '###,##&.&&',
               COLUMN 125, p_pct_umd_med        USING '#&.&&',
               COLUMN 131, p_peso_umd           USING '####,##&.&&&',
               COLUMN 144, p_num_ap_ger         USING '######',
               COLUMN 151, p_dat_vencto_ger,
               COLUMN 162, p_val_nom_ap_ger     USING '###,##&.&&',
               COLUMN 173, p_val_saldo_adiant   USING '###,##&.&&',
               COLUMN 186, p_val_pedagio        USING '###&.&&',
               COLUMN 194, p_tot_pagar          USING '+#,###,##&.&&',
               COLUMN 208, p_peso_dif           USING '#,##&.&&&'                
      
      AFTER GROUP OF p_cod_fornecedor

         LET p_tot_peso_umd = GROUP SUM(p_peso_umd)   
         LET p_tot_peso_dif = GROUP SUM(p_peso_dif)            
         LET p_tot_contagem = GROUP SUM(p_qtd_contagem)
         LET p_med_pct = p_tot_peso_umd / p_tot_contagem * 100
         
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 039, GROUP SUM(p_qtd_recebida)     USING '###,###,##&.&&&',
               COLUMN 080, GROUP SUM(p_val_nom_ap)       USING '###,##&.&&',
               COLUMN 091, p_tot_contagem                USING '###,###,##&.&&&',
               COLUMN 114, GROUP SUM(p_total)            USING '###,##&.&&',
               COLUMN 125, p_med_pct                     USING '#&.&&',
               COLUMN 131, p_tot_peso_umd                USING '####,##&.&&&',
               COLUMN 162, GROUP SUM(p_val_nom_ap_ger)   USING '###,##&.&&',
               COLUMN 173, GROUP SUM(p_val_saldo_adiant) USING '###,##&.&&',
               COLUMN 186, GROUP SUM(p_val_pedagio)      USING '###&.&&',
               COLUMN 194, GROUP SUM(p_tot_pagar)        USING '+#,###,##&.&&',
               COLUMN 208, p_tot_peso_dif                USING '#,##&.&&&'
                     
      ON LAST ROW
 
         LET p_tot_peso_umd = SUM(p_peso_umd)
         LET p_tot_peso_dif = SUM(p_peso_dif)            
         LET p_tot_contagem = SUM(p_qtd_contagem)
         LET p_med_pct = p_tot_peso_umd / p_tot_contagem * 100
         
         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 039, SUM(p_qtd_recebida)     USING '###,###,##&.&&&',
               COLUMN 080, SUM(p_val_nom_ap)       USING '###,##&.&&',
               COLUMN 091, p_tot_contagem          USING '###,###,##&.&&&',
               COLUMN 114, SUM(p_total)            USING '###,##&.&&',
               COLUMN 125, p_med_pct               USING '#&.&&',
               COLUMN 131, p_tot_peso_umd          USING '####,##&.&&&',
               COLUMN 162, SUM(p_val_nom_ap_ger)   USING '###,##&.&&',
               COLUMN 173, SUM(p_val_saldo_adiant) USING '###,##&.&&',
               COLUMN 186, SUM(p_val_pedagio)      USING '###&.&&',
               COLUMN 194, SUM(p_tot_pagar)        USING '+#,###,##&.&&',
               COLUMN 208, p_tot_peso_dif          USING '#,##&.&&&'               
               
         LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 066, "* * * ULTIMA FOLHA * * *"
           LET p_last_row = FALSE
        ELSE 
           PRINT " "
        END IF
                                 
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#