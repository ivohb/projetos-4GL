#------------------------------------------------------------------------------#
# SISTEMA.: PRODUCAO                                                           #
# PROGRAMA: POL0483                                                            #
# MODULOS.: POL0483                                                            #
# OBJETIVO: PROGRAMA PARA calculo base de COMISSOES                            #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE 
         p_cod_empresa   CHAR(02),
         p_cod_emp_dupl  CHAR(02),
         p_cod_emp_proc  CHAR(02),
         p_cod_emp_nf    CHAR(02),            # Ivo: 04/01/2011
         p_cancel        INTEGER,
         p_tem_frete     SMALLINT,
         p_trans_nota_fiscal INTEGER,
         p_den_empresa   LIKE empresa.den_empresa,
         p_val_fret_it   LIKE fat_nf_mestre.val_nota_fiscal,  #Will - 25/10/10
         p_val_base_com  LIKE fat_nf_mestre.val_nota_fiscal,  #Will - 25/10/10
         l_num_ped       LIKE pedidos.num_pedido,
         p_val_tot_nff   LIKE fat_nf_mestre.val_nota_fiscal,  #Will - 25/10/10
         p_val_docum_orig LIKE fat_nf_mestre.val_nota_fiscal, #Will - 25/10/10
         p_nf_cod_empresa LIKE fat_nf_mestre.empresa,         #Will - 25/10/10
         p_tem_item      SMALLINT,
         p_dat_ini       DATE,
         p_dat_fim       DATE,
         p_ies_tip_portador LIKE portador.ies_tip_portador, 
         comando         CHAR(80),
         p_ind           SMALLINT,
         p_count         SMALLINT,
         p_ies_processou SMALLINT,
         p_resposta      CHAR(1),
         p_ies_tipo      CHAR(1),
         p_data          DATE,
         p_hora          CHAR(05),
         p_versao        CHAR(18),
         p_pct_dupl      DECIMAL(11,9),
         p_fat_nf_item   RECORD LIKE fat_nf_item.*,     #Will - 25/10/10        
         p_docum         RECORD LIKE docum.*,
         p_docum_pgto    RECORD LIKE docum_pgto.*,
         p_val_frete_unit DECIMAL(12,2),
         p_nota_dec      DECIMAL(06,0),
         p_msg           CHAR(300)


 DEFINE p_user            LIKE usuario.nom_usuario,
        p_status          SMALLINT,
        p_ies_situa       SMALLINT,
        p_nom_help        CHAR(200),
        p_nom_tela        CHAR(200),
        p_wfat            RECORD LIKE fat_nf_mestre.*   #Will - 25/10/10  
END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  CALL log0180_conecta_usuario()
  DEFER INTERRUPT 
  LET p_versao = "POL0483-10.02.09"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0483.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL pol0483_controle()
  END IF
END MAIN



#--------------------------#
 FUNCTION pol0483_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0483") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0483 AT 2,2 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar"   "Informar parametros "
         HELP 0009
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","POL0483","CO") THEN
            IF pol0483_entrada_parametros() THEN
               NEXT OPTION "Processar"
            END IF
         END IF
      COMMAND "Processar"  "Processa recálculo da base de comissões"
         HELP 1053
         IF  log005_seguranca(p_user,"VDP","POL0483","IN") THEN
           IF log004_confirm(16,30) THEN  
             CALL log085_transacao("BEGIN") 
             IF pol0483_processa() THEN
                ERROR "Processamento Efetuado com Sucesso"
                CALL log085_transacao("COMMIT") 
             ELSE
                ERROR "Processamento Cancelado"
                CALL log085_transacao("ROLLBACK") 
             END IF
           ELSE
             ERROR "Processamento Cancelado"          
           END IF
         END IF
       COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0483_sobre()
       COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
       COMMAND "Fim" "Sai do programa"
            EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0483
END FUNCTION


#-----------------------------------#
FUNCTION pol0483_entrada_parametros()
#-----------------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0483

   INITIALIZE p_dat_ini, p_dat_fim TO NULL

   INPUT p_dat_ini,
         p_dat_fim,
         p_cod_emp_dupl
  WITHOUT DEFAULTS
    FROM dat_ini,
         dat_fim,
         cod_emp_dupl

      AFTER FIELD dat_ini       
         IF p_dat_ini  IS NULL THEN
            ERROR "Data invalida"         
            NEXT FIELD dat_ini        
         END IF

      AFTER FIELD dat_fim
         IF p_dat_fim  IS NULL THEN
            ERROR "Data invalida"         
            NEXT FIELD dat_fim
         ELSE
            IF p_dat_ini > p_dat_fim THEN          
               ERROR "Data final maior que inicial"
               NEXT FIELD dat_fim
            END IF 
         END IF
         
      BEFORE FIELD cod_emp_dupl
         IF p_cod_emp_dupl IS NULL THEN
            LET p_cod_emp_dupl = p_cod_empresa
         END IF

      AFTER FIELD cod_emp_dupl
         IF p_cod_emp_dupl IS NULL THEN
            ERROR "Campo com preenchimento obrigatorio !!!"
            NEXT FIELD cod_emp_dupl
         END IF
         
         SELECT den_empresa
           INTO p_den_empresa
           FROM empresa
          WHERE cod_empresa = p_cod_emp_dupl
         
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR "Empresa inexistente !!!"
            NEXT FIELD cod_emp_dupl
         END IF
         
         DISPLAY p_den_empresa TO den_emp_dupl

      ON KEY (control-z)
         CALL pol0483_popup()
            
   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0483

   IF int_flag THEN
      LET int_flag = 0
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------#
 FUNCTION pol0483_processa()
#-----------------------------#

DEFINE l_serie      		CHAR(2),
       l_num_transac    INTEGER

 DISPLAY "Titulo: "  AT  15,17
 LET p_ies_situa = 0
 

 DECLARE cq_docum CURSOR FOR 
   SELECT DISTINCT num_docum 
     FROM docum_pgto          
    WHERE cod_empresa = p_cod_emp_dupl
      AND dat_pgto >= p_dat_ini
      AND dat_pgto <= p_dat_fim
      AND cod_portador NOT IN (370,700,701)
    ORDER BY num_docum
      
 FOREACH cq_docum INTO p_docum_pgto.num_docum

   DISPLAY p_docum_pgto.num_docum AT 15,25 

   SELECT val_liq_orig
     INTO p_val_docum_orig
     FROM recalc_base_kana
    WHERE cod_empresa   = p_cod_emp_dupl
      AND num_docum     = p_docum_pgto.num_docum
      AND ies_tip_docum = 'DP'
   
   IF STATUS = 0 THEN 
      
      UPDATE docum 
         SET val_liquido = p_val_docum_orig
       WHERE cod_empresa   = p_cod_emp_dupl
         AND num_docum     = p_docum_pgto.num_docum
         AND ies_tip_docum = 'DP'

      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDATE","docum")
         RETURN FALSE
      END IF
      
      DELETE FROM recalc_base_kana
       WHERE cod_empresa   = p_cod_emp_dupl
         AND num_docum     = p_docum_pgto.num_docum
         AND ies_tip_docum = 'DP'

      IF STATUS <> 0 THEN
         CALL log003_err_sql("DELETE","recalc_base_kana")
         RETURN FALSE
      END IF
   
   ELSE
      LET p_val_docum_orig = 0
   END IF

   SELECT * 
     INTO p_docum.*
     FROM docum
    WHERE cod_empresa   = p_cod_emp_dupl
      AND num_docum     = p_docum_pgto.num_docum
      AND ies_tip_docum = 'DP'

   IF STATUS <> 0 THEN 
      CONTINUE FOREACH
   END IF

   SELECT trans_nota_fiscal,
          nota_fiscal,
          emp_nota_fiscal,
          serie_nota_fiscal
     INTO l_num_transac,
          p_nota_dec,
          p_cod_emp_nf,
          l_serie
     FROM cre_nf_orig_docum
    WHERE empresa_docum = p_docum.cod_empresa
      AND docum = p_docum.num_docum
      AND tip_docum = p_docum.ies_tip_docum

   IF STATUS <> 0 THEN 
      CONTINUE FOREACH
   END IF

   IF p_val_docum_orig = 0 THEN
      LET p_val_docum_orig = p_docum.val_liquido
   END IF
   
   #...---#

   LET p_ies_situa = 1

   SELECT empresa,                           #Will - 25/10/10
          val_nota_fiscal,                   #Will - 25/10/10
          trans_nota_fiscal                  #Will - 25/10/10
     INTO p_nf_cod_empresa,                  #Will - 25/10/10
          p_val_tot_nff,                     #Will - 25/10/10
          p_trans_nota_fiscal                #Will - 25/10/10
     FROM fat_nf_mestre                      #Will - 25/10/10
    WHERE empresa           = p_cod_emp_nf   #Ivo: 04/01/2011
      AND trans_nota_fiscal = l_num_transac
    UNION
   SELECT empresa,                           #Will - 25/10/10
          val_nota_fiscal,                   #Will - 25/10/10
          trans_nota_fiscal                  #Will - 25/10/10
     INTO p_nf_cod_empresa,                  #Will - 25/10/10
          p_val_tot_nff,                     #Will - 25/10/10
          p_trans_nota_fiscal                #Will - 25/10/10
     FROM fat_nf_mestre_hist                 #Will - 25/10/10
    WHERE empresa           = p_cod_emp_nf   #Ivo: 04/01/2011
      AND trans_nota_fiscal = l_num_transac
    
   IF STATUS = 100 THEN      
      LET p_msg = 'NF: ', p_nota_dec, 'Série: ', l_serie, '\n',
                  'Inexistente na tabela FAT_NF_MESTRE!' 
      CALL log0030_mensagem(p_msg,'excla')                        
      RETURN FALSE                                                                        #Will - 25/10/10
   ELSE                                                                                      #Will - 25/10/10
      IF STATUS <> 0 THEN                                                                    #Will - 25/10/10
         CALL log003_err_sql("Lendo", "fat_nf_mestre")                                       #Will - 25/10/10
         RETURN FALSE                                                                        #Will - 25/10/10
      END IF                                                                                 #Will - 25/10/10
   END IF                                                                                    #Will - 25/10/10       

####  verifica a existência de frete p/ algum pedido da NF

   SELECT COUNT(num_pedido)
     INTO p_count
     FROM frete_unit_kana
    WHERE cod_empresa = p_nf_cod_empresa
      AND num_pedido IN (SELECT DISTINCT pedido                                       #Will - 25/10/10
                           FROM fat_nf_item                                  #Will - 25/10/10
                          WHERE empresa           = p_nf_cod_empresa         #Will - 25/10/10
                            AND trans_nota_fiscal = p_trans_nota_fiscal)     #Will - 25/10/10

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","frete_unit_kana:count")
      RETURN FALSE
   END IF

   IF p_count = 0 THEN
      CONTINUE FOREACH
   END IF
                               
   LET p_pct_dupl = p_docum.val_bruto / p_val_tot_nff   
   LET p_val_base_com = 0  
   LET p_tem_item = FALSE
      
   DECLARE cq_nfi CURSOR FOR
    SELECT *                                           #Will - 25/10/10
      FROM fat_nf_item                                 #Will - 25/10/10
     WHERE empresa           = p_nf_cod_empresa        #Will - 25/10/10
       AND trans_nota_fiscal = p_trans_nota_fiscal     #Will - 25/10/10
 
   FOREACH cq_nfi INTO p_fat_nf_item.*                 #Will - 25/10/10

     LET p_tem_item = TRUE
   
     SELECT val_frete_unit
       INTO p_val_frete_unit
       FROM frete_unit_kana
      WHERE cod_empresa   = p_nf_cod_empresa
        AND num_pedido    = p_fat_nf_item.pedido           #Will - 25/10/10
        AND num_sequencia = p_fat_nf_item.seq_item_pedido  #Will - 25/10/10
        AND cod_item      = p_fat_nf_item.item             #Will - 25/10/10

     IF SQLCA.sqlcode <> 0 THEN
        LET p_val_frete_unit = 0
     END IF
        
     LET p_val_fret_it =  p_val_frete_unit * p_fat_nf_item.qtd_item                          #Will - 25/10/10
        
     LET p_val_base_com = p_val_base_com + 
         (p_fat_nf_item.val_liquido_item - p_fat_nf_item.val_desc_contab) - p_val_fret_it    #Ivo - 04/12/2013

   END FOREACH

   IF NOT p_tem_item THEN
      MESSAGE 'NF: ', p_nota_dec, 'Inexistente na tab. FAT_NF_ITEM' ATTRIBUTE(REVERSE)       #Will - 25/10/10
      CALL log003_err_sql("LEITURA","FAT_NF_ITEM")                                           #Will - 25/10/10
      RETURN FALSE
   END IF
   

   LET p_docum.val_liquido = p_val_base_com * p_pct_dupl
   
   UPDATE docum 
      SET val_liquido = p_docum.val_liquido
    WHERE cod_empresa = p_cod_emp_dupl
      AND num_docum =   p_docum.num_docum

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","docum")
      RETURN FALSE
   END IF
         
   INSERT INTO recalc_base_kana 
      VALUES (p_cod_emp_dupl,
              p_docum.num_docum,
              p_docum.ies_tip_docum,
              p_val_docum_orig)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERINDO","recalc_base_kana")
      RETURN FALSE
   END IF
    
 END FOREACH 
 
IF p_ies_situa <> 1 THEN
   MESSAGE "Não há duplicatas a pagar para os parametros informados"
   RETURN FALSE
ELSE
   RETURN TRUE 
END IF
 
END FUNCTION  


#-----------------------#
 FUNCTION pol0483_popup()
#-----------------------#

   DEFINE p_codigo CHAR(30)
   
   CASE
      WHEN INFIELD(cod_emp_dupl)
         CALL log009_popup(8,25,"EMPRESAS","empresa",
                     "cod_empresa","den_empresa","","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0483
         IF p_codigo IS NOT NULL THEN
            LET p_cod_emp_dupl = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_emp_dupl
         END IF
   END CASE

END FUNCTION

#-----------------------#
 FUNCTION pol0483_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION