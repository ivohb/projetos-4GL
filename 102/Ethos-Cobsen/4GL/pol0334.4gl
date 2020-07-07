#-------------------------------------------------------------------#
# SISTEMA.: ENVIO DE PROGRAMAÇÃO E RECEBIMENTO DE MATERIAIS VIA EDI #
# PROGRAMA: POL0334                                                 #
# MODULOS.: POL0334 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: ENVIO DE CONFIRMAÇÃO DA PROGRAMAÇÃO PARA CATERPILLAR    #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 25/02/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_houve_erro    SMALLINT,
          comando         CHAR(80),
          p_comprime      CHAR(01),
          p_descomprime   CHAR(01),
       #   p_versao        CHAR(17),
          p_versao        CHAR(18),
          p_ies_impressao CHAR(001),           
          g_ies_ambiente  CHAR(001),
          p_nom_arquivo   CHAR(100),
          p_arquivo       CHAR(025),
          p_caminho       CHAR(080),
          p_nom_tela      CHAR(200),
          p_nom_help      CHAR(200),
          p_r             CHAR(001),
          p_count         SMALLINT,
          p_ies_cons      SMALLINT,
          p_last_row      SMALLINT,
          p_grava         SMALLINT,
          pa_curr         SMALLINT,
          pa_curr1        SMALLINT,
          sc_curr         SMALLINT,
          sc_curr1        SMALLINT,
          w_a             SMALLINT,
          p_msg           CHAR(500)

END GLOBALS

   DEFINE m_count           SMALLINT

   DEFINE ma_tela ARRAY[9] OF RECORD
      cod_cliente           LIKE clientes.cod_cliente,
      nom_cliente           LIKE clientes.nom_cliente
   END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0334-10.02.00"
   INITIALIZE p_nom_help TO NULL
   CALL log140_procura_caminho("pol0334.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,        
      PREVIOUS KEY control-b

   # CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0334_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0334_controle()
#--------------------------#
   DEFINE l_informou_dados     SMALLINT

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0334") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0334 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST) 

   LET l_informou_dados = FAlSE

   MENU "OPCAO"
      COMMAND "Informar" "Informa clientes para gerar Arquivo de Confirmação."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0334","IN") THEN
            IF pol0334_informa_clientes() THEN
               LET l_informou_dados = TRUE
               NEXT OPTION "Processar"
            ELSE
               ERROR 'Operação Cancelada.'
            END IF
         END IF

      COMMAND "Processar" "Gera o Arquivo de Confirmação."
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF l_informou_dados THEN
            IF log005_seguranca(p_user,"VDP","pol0334","MO") THEN 
               CALL pol0334_processa()
               LET l_informou_dados = FALSE
            END IF
         ELSE
            ERROR "Informe os parâmetros primeiramente."
            NEXT OPTION "Informar"
         END IF
      
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0334_sobre()
      
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTece ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0

      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0334

END FUNCTION       

#----------------------------------#
 FUNCTION pol0334_informa_clientes()
#----------------------------------#
   DEFINE l_ind              SMALLINT,
          l_informou         SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0334

   LET INT_FLAG   = FALSE
   LET l_informou = FALSE 
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_clientes.*

      BEFORE FIELD cod_cliente
         LET pa_curr   = ARR_CURR()
         LET sc_curr   = SCR_LINE()

      AFTER FIELD cod_cliente
         IF ma_tela[pa_curr].cod_cliente IS NOT NULL AND
            ma_tela[pa_curr].cod_cliente <> ' ' THEN
            IF pol0334_verifica_cliente() = FALSE THEN
               ERROR 'Fornecedor não Cadastrado.'
               NEXT FIELD cod_cliente
            END IF                        
         END IF

      ON KEY (Control-z)
         CALL pol0334_popup()

      AFTER INPUT
         IF INT_FLAG = FALSE THEN
            FOR l_ind = 1 TO 9      
               IF ma_tela[l_ind].cod_cliente IS NOT NULL AND
                  ma_tela[l_ind].cod_cliente <> ' ' THEN
                  LET l_informou = TRUE
                  EXIT FOR 
               END IF
            END FOR
            IF l_informou = FALSE THEN
               ERROR 'Obrigatório informar algum cliente.'
               NEXT FIELD cod_cliente
            END IF
         END IF  

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0334

   IF INT_FLAG THEN
      CLEAR FORM
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION               

#----------------------------------#
 FUNCTION pol0334_verifica_cliente()
#----------------------------------#

   SELECT raz_social 
     INTO ma_tela[pa_curr].nom_cliente
     FROM fornecedor 
    WHERE cod_fornecedor = ma_tela[pa_curr].cod_cliente
   IF sqlca.sqlcode = 0 THEN
      DISPLAY ma_tela[pa_curr].nom_cliente TO s_clientes[sc_curr].nom_cliente
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION        

#--------------------------#
 FUNCTION pol0334_processa()
#--------------------------#
   DEFINE sql_stmt               CHAR(1000),
          l_condicao             CHAR(150),
          l_num_aviso_rec        LIKE aviso_rec.num_aviso_rec
  
   CALL pol0334_cria_temporaria()
   CALL pol0334_monta_selecao_clientes() RETURNING l_condicao

   LET m_count = 0 
   CALL log085_transacao("BEGIN")
   # BEGIN WORK 
 
   MESSAGE 'Processando...'  ATTRIBUTE(REVERSE) 

   LET sql_stmt = " SELECT nf_sup.num_aviso_rec ",
                  "   FROM nf_sup ",
                  "  WHERE nf_sup.cod_empresa = '",p_cod_empresa,"'",
                  "    AND nf_sup.cod_fornecedor IN (",l_condicao CLIPPED,")",
                  "    AND NOT EXISTS ",
                         " (SELECT r.num_aviso_rec ",
                         "  FROM recbto_ethos_cat r ", 
                         " WHERE r.cod_empresa   = '",p_cod_empresa,"'",
                         "   AND r.num_aviso_rec = nf_sup.num_aviso_rec )"   

   PREPARE var_query FROM sql_stmt
   DECLARE cq_nf_sup SCROLL CURSOR WITH HOLD FOR var_query      
  
   FOREACH cq_nf_sup INTO l_num_aviso_rec
     
      WHENEVER ERROR CONTINUE
        INSERT INTO w_temp_cat VALUES (l_num_aviso_rec)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO","W_TEMP_CAT")
         CALL log085_transacao("ROLLBACK")
         # ROLLBACK WORK 
         LET m_count = 0
         RETURN
      END IF

      WHENEVER ERROR CONTINUE
        INSERT INTO recbto_ethos_cat VALUES (p_cod_empresa,
                                             l_num_aviso_rec)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO","RECBTO_ETHOS_CAT")
         CALL log085_transacao("ROLLBACK")
         # ROLLBACK WORK 
         LET m_count = 0
         RETURN
      END IF

      LET m_count = m_count + 1

   END FOREACH

   CALL log085_transacao("COMMIT")
   # COMMIT WORK
   CALL pol0334_gera_arquivo()
   
END FUNCTION

#---------------------------------#
 FUNCTION pol0334_cria_temporaria()
#---------------------------------#

   WHENEVER ERROR CONTINUE
       DROP TABLE w_temp_cat;
   WHENEVER ERROR STOP

   CREATE TABLE w_temp_cat
      (
      num_aviso_rec          DECIMAL(6,0) 
      )

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","W_TEMP_CAT")     
   END IF

END FUNCTION
            
#----------------------------------------#
 FUNCTION pol0334_monta_selecao_clientes()
#----------------------------------------#
   DEFINE l_condicao             CHAR(150),
          l_ind                  SMALLINT

   LET l_condicao = ' '

   FOR l_ind = 1 TO 9 
      IF ma_tela[l_ind].cod_cliente IS NOT NULL AND
         ma_tela[l_ind].cod_cliente <> ' ' THEN
         LET l_condicao = l_condicao CLIPPED,
             ',"',ma_tela[l_ind].cod_cliente, '"'
      END IF
   END FOR

   LET l_condicao = l_condicao[2,150]

   RETURN l_condicao

END FUNCTION                 
 
#------------------------------#
 FUNCTION pol0334_gera_arquivo()
#------------------------------#
   DEFINE l_num_cnpj            CHAR(19),
          l_cnpj_ethos          CHAR(19),
          l_dat_hora            CHAR(19)
    
   MESSAGE " Processando a Extração do Arquivo..." ATTRIBUTE(REVERSE)

   IF m_count = 0 THEN
      MESSAGE "Não Existem Dados para gerar arquivo." ATTRIBUTE(REVERSE)
      RETURN
   END IF
 
   SELECT num_cgc_cpf
     INTO l_num_cnpj
     FROM clientes 
    WHERE cod_cliente = '1'

   IF sqlca.sqlcode <> 0 THEN
      LET l_num_cnpj = ' '
   END IF

   SELECT num_cgc
     INTO l_cnpj_ethos
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      LET l_cnpj_ethos = ' '
   END IF                 

   LET l_cnpj_ethos = l_cnpj_ethos[2,3],
                      l_cnpj_ethos[5,7],
                      l_cnpj_ethos[9,11],
                      l_cnpj_ethos[13,16],
                      l_cnpj_ethos[18,19]
   LET l_num_cnpj   = l_num_cnpj[2,3],
                      l_num_cnpj[5,7],
                      l_num_cnpj[9,11],
                      l_num_cnpj[13,16],
                      l_num_cnpj[18,19]

   LET l_dat_hora = CURRENT YEAR TO SECOND

   LET l_dat_hora = l_dat_hora[1,4],
                    l_dat_hora[6,7],
                    l_dat_hora[9,10],
                    l_dat_hora[12,13],
                    l_dat_hora[15,16],
                    l_dat_hora[18,19]

   CALL log150_procura_caminho ('LST') RETURNING p_nom_arquivo
   LET p_nom_arquivo = p_nom_arquivo CLIPPED,l_num_cnpj CLIPPED,'_RND01901_',
                       l_cnpj_ethos CLIPPED,'_',l_dat_hora CLIPPED,'.txt'     

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol0334_relat_arq TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol0330.tmp'
         START REPORT pol0334_relat_arq TO p_caminho
      END IF
   ELSE
      START REPORT pol0334_relat_arq TO p_nom_arquivo
   END IF
   
   CALL pol0334_emite_arquivo_edi()

   ERROR "Arquivo Processado com Sucesso."

   FINISH REPORT pol0334_relat_arq

   MESSAGE "Arquivo: ",p_nom_arquivo ATTRIBUTE(REVERSE)  
 
END FUNCTION

#-----------------------------------#
 FUNCTION pol0334_emite_arquivo_edi()
#-----------------------------------#   
   DEFINE lr_arq_edi       RECORD
       ident_itp                CHAR(3), # 1-3     Ident. tipo registro - ITP
       ident_proc               CHAR(3), # 4-6     Ident. do processo
       num_ver_transac          CHAR(2), # 7-8     Numero da Versao Transacao
       num_ctr_transm           CHAR(5), # 9-13    Numero controle transmissao
       ident_ger_mov            CHAR(12),# 14-25   Ident. Geracao do movimento
       ident_tms_comun          CHAR(14),# 26-39   Ident. Transmissor na Comun.
       ident_rcp_comun          CHAR(14),# 40-53   Ident. Receptor na Comun.
       cod_int_tms              CHAR(8), # 54-61   Código Interno do Transmissor
       cod_int_rcp              CHAR(8), # 54-61   Código Interno do Receptor
       nom_tms                  CHAR(25),# 62-69   Nome do Transmissor
       nom_rcp                  CHAR(25),# 70-94   Nome do Receptor
       espaco_itp               CHAR(9), # 95-119  Espaço
       ident_cr1                CHAR(3), # 1-3     Ident. Tipo Registro - CR1
       num_nf_orig              CHAR(6), # 4-9     Número da NF origem
       ser_nf_orig              CHAR(4), # 10-13   Séria da NF de origem
       dat_embarq               CHAR(6), # 14-19   Data de Embarque
       dat_receb                CHAR(6), # 20-25   Data do Recebimento
       tip_receb                CHAR(1), # 26-26   Tipo de Recebimento
       cod_fab_dest             CHAR(3), # 27-29   Código da Fábrica destino
       dat_nf_orig              CHAR(6), # 30-35   Data da NF de origem    
       dat_ent_sist             CHAR(6), # 36-41   Data de Entrada no sistema
       dat_conf_fis             CHAR(6), # 42-47   Data Conferência Física
       cod_forn_mat_prim        CHAR(7), # 48-54   Cód. Fornecedor Matéria Prima
       espaco_cr1               CHAR(74),# 55-128  Espaço
       ident_cr2                CHAR(3), # 1-3     Ident. Tipo Registro - CR2
       cod_item                 CHAR(30),# 4-33    Código do item
       qtd_embarcada            CHAR(9), # 34-42   Quantidade Embarcada
       qtd_recebida             CHAR(9), # 43-51   Quantidade Recebida
       qtd_devolvida            CHAR(9), # 52-60   Quantidade Devolvida
       uni_med_estoq            CHAR(2), # 61-62   Unidade de medida estoque
       qtd_casas_dec            CHAR(1), # 63-63   Quantidade de Casas Decimais
       cod_discrep              CHAR(2), # 64-65   Código da discrepância
       qtd_aju_acum             CHAR(9), # 66-74   Quantidade p/ ajuste de Acum
       qtd_questao              CHAR(9), # 75-83   Quantidade em questão
       num_ped_comp             CHAR(12),# 84-95   Numero do pedido de compra
       alt_tec_item             CHAR(4), # 96-99   Alteração Técnica do Item
       espaco_cr2               CHAR(29),# 100-128 Espaço
       ident_ftp                CHAR(3), # 1-3     Ident. Tipo Registro - FTP 
       num_ctr_tms_ftp          CHAR(5), # 4-8     Numero Contr. Transmissao
       qtd_reg_transac          CHAR(9), # 9-17    Quantidade Registro Transacao
       num_tot_val              CHAR(17),# 18-34   Numero total de valores
       categ_operac             CHAR(1), # 35-35   Categoria da Operacao
       espaco_ftp               CHAR(93) # 36-128  Espaço
                            END RECORD         

    DEFINE l_num_aviso_rec      LIKE aviso_rec.num_aviso_rec,
           l_num_nf             DECIMAL(6,0), 
           l_ser_nf             CHAR(1), 
           l_cod_fornecedor     LIKE nf_sup.cod_fornecedor, 
           l_dat_emis_nf        DATE, 
           l_dat_entrada_nf     DATE,
           l_cod_item           LIKE aviso_rec.cod_item, 
           l_qtd_declarad_nf    DECIMAL(9,0), 
           l_qtd_recebida       DECIMAL(9,0), 
           l_qtd_devolvida      DECIMAL(9,0), 
           l_cod_unid_med       CHAR(2),
           l_num_reg            SMALLINT,
           l_num_cnpj           CHAR(19),
           l_cnpj_ethos         CHAR(19),
           l_cod_item_cat       CHAR(30), 
           l_num_ped_cat        CHAR(12),
           l_dat_atual          CHAR(6), 
           l_hor_atual          CHAR(8),
           l_sequencia          LIKE aviso_rec.num_seq,
           l_capa               SMALLINT

    LET l_capa = TRUE 

    SELECT COUNT(*)
      INTO l_num_reg
      FROM w_temp_cat
    
   DECLARE cq_relat CURSOR FOR
    SELECT UNIQUE *
      FROM w_temp_cat
     ORDER BY num_aviso_rec 

   FOREACH cq_relat INTO l_num_aviso_rec    

      WHENEVER ERROR CONTINUE 
      SELECT num_nf, 
             ser_nf, 
             cod_fornecedor, 
             dat_emis_nf, 
             dat_entrada_nf
        INTO l_num_nf, 
             l_ser_nf, 
             l_cod_fornecedor, 
             l_dat_emis_nf, 
             l_dat_entrada_nf
        FROM nf_sup
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = l_num_aviso_rec
      WHENEVER ERROR STOP
    
      SELECT raz_social, num_cgc_cpf
        INTO lr_arq_edi.nom_rcp, l_num_cnpj
        FROM fornecedor 
       WHERE cod_fornecedor = l_cod_fornecedor

      IF sqlca.sqlcode <> 0 THEN
         LET l_num_cnpj = ' '
         LET lr_arq_edi.nom_rcp = ' '
      END IF

      SELECT den_empresa, num_cgc
        INTO lr_arq_edi.nom_tms, l_cnpj_ethos
        FROM empresa
       WHERE cod_empresa = p_cod_empresa

      IF sqlca.sqlcode <> 0 THEN
         LET l_cnpj_ethos = ' '
         LET lr_arq_edi.nom_tms = ' '
      END IF                        

      LET lr_arq_edi.ident_itp       = 'ITP'
      LET lr_arq_edi.ident_proc      = '019'        
      LET lr_arq_edi.num_ver_transac = '01' 
      LET lr_arq_edi.num_ctr_transm  = '00000'        
    
      LET l_dat_atual = TODAY USING 'yymmdd'
      LET l_hor_atual = CURRENT HOUR TO SECOND
      LET lr_arq_edi.ident_ger_mov    = l_dat_atual,
                                        l_hor_atual[1,2],
                                        l_hor_atual[4,5],
                                        l_hor_atual[7,8]    
    
      LET lr_arq_edi.ident_tms_comun  = l_cnpj_ethos[2,3],
                                        l_cnpj_ethos[5,7],
                                        l_cnpj_ethos[9,11],
                                        l_cnpj_ethos[13,16],
                                        l_cnpj_ethos[18,19]         
      LET lr_arq_edi.ident_rcp_comun  = l_num_cnpj[2,3],
                                        l_num_cnpj[5,7],
                                        l_num_cnpj[9,11],
                                        l_num_cnpj[13,16],
                                        l_num_cnpj[18,19] 
      LET lr_arq_edi.cod_int_tms      = 'Q7586S0 '        
      LET lr_arq_edi.cod_int_rcp      = ' '       
      LET lr_arq_edi.espaco_itp       = ' '      
 
      IF l_capa THEN
         OUTPUT TO REPORT pol0334_relat_arq(1, lr_arq_edi.*)
         LET l_capa = FALSE
      END IF

      LET lr_arq_edi.ident_cr1        = 'CR1'       
      LET lr_arq_edi.num_nf_orig      = l_num_nf USING '&&&&&&'      
      LET lr_arq_edi.ser_nf_orig      = l_ser_nf      
      LET lr_arq_edi.dat_embarq       = l_dat_emis_nf USING 'yymmdd'     
      LET lr_arq_edi.dat_receb        = l_dat_entrada_nf USING 'yymmdd'       
      LET lr_arq_edi.tip_receb        = '1'      
      LET lr_arq_edi.cod_fab_dest     = '028'       
      LET lr_arq_edi.dat_nf_orig      = l_dat_emis_nf USING 'yymmdd'      
      LET lr_arq_edi.dat_ent_sist     = l_dat_entrada_nf USING 'yymmdd'       
      LET lr_arq_edi.dat_conf_fis     = l_dat_entrada_nf USING 'yymmdd'        
      LET lr_arq_edi.cod_forn_mat_prim = 'Q2008Y1'
      LET lr_arq_edi.espaco_cr1      = ' '       

      OUTPUT TO REPORT pol0334_relat_arq(2, lr_arq_edi.*)
      
      DECLARE cq_relat_it CURSOR FOR
       SELECT cod_item,
              qtd_declarad_nf,
              qtd_recebida,
              qtd_devolvid,
              cod_unid_med_nf
         FROM aviso_rec
        WHERE cod_empresa   = p_cod_empresa
          AND num_aviso_rec = l_num_aviso_rec

      FOREACH cq_relat_it INTO l_cod_item,
                               l_qtd_declarad_nf,
                               l_qtd_recebida,
                               l_qtd_devolvida,
                               l_cod_unid_med

         SELECT cod_item_cat, num_ped_cater
           INTO l_cod_item_cat, l_num_ped_cat
           FROM item_prog_ethos
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = l_cod_item
      
         LET lr_arq_edi.ident_cr2       = 'CR2'       
         LET lr_arq_edi.cod_item        = l_cod_item_cat       
         LET lr_arq_edi.qtd_embarcada   = l_qtd_declarad_nf USING '&&&&&&&&&' 
         LET lr_arq_edi.qtd_recebida    = l_qtd_recebida USING '&&&&&&&&&'      
         LET lr_arq_edi.qtd_devolvida   = l_qtd_devolvida USING '&&&&&&&&&' 
         LET lr_arq_edi.uni_med_estoq   = l_cod_unid_med       
         LET lr_arq_edi.qtd_casas_dec   = '0'       
     
         IF l_qtd_declarad_nf = l_qtd_recebida THEN
            LET lr_arq_edi.cod_discrep  = '33'
         ELSE
            IF l_qtd_recebida > l_qtd_declarad_nf THEN
               LET lr_arq_edi.cod_discrep  = '30'
            ELSE
               LET lr_arq_edi.cod_discrep  = '31'
            END IF   
         END IF           
      
         LET lr_arq_edi.qtd_aju_acum       = '000000000' 
         LET lr_arq_edi.qtd_questao        = '000000000'    
         LET lr_arq_edi.num_ped_comp       = l_num_ped_cat    
         LET lr_arq_edi.alt_tec_item       = '  00'    
         LET lr_arq_edi.espaco_cr2         = ' '    

         OUTPUT TO REPORT pol0334_relat_arq(3, lr_arq_edi.*)
     
      END FOREACH
 
      INITIALIZE lr_arq_edi.* TO NULL
      LET m_count = m_count + 1

   END FOREACH

   LET lr_arq_edi.ident_ftp          = 'FTP'    
   LET lr_arq_edi.num_ctr_tms_ftp    = '00000'    
   LET lr_arq_edi.qtd_reg_transac    = l_num_reg    
   LET lr_arq_edi.num_tot_val        = '00000000000000000'    
   LET lr_arq_edi.categ_operac       = ' '   
   LET lr_arq_edi.espaco_ftp         = ' '   

   OUTPUT TO REPORT pol0334_relat_arq(4, lr_arq_edi.*)

END FUNCTION    

#-------------------------------------------#
 REPORT pol0334_relat_arq(l_tipo, lr_arq_edi)
#-------------------------------------------#   
    DEFINE lr_arq_edi       RECORD
       ident_itp                CHAR(3), # 1-3     Ident. tipo registro - ITP
       ident_proc               CHAR(3), # 4-6     Ident. do processo
       num_ver_transac          CHAR(2), # 7-8     Numero da Versao Transacao
       num_ctr_transm           CHAR(5), # 9-13    Numero controle transmissao
       ident_ger_mov            CHAR(12),# 14-25   Ident. Geracao do movimento
       ident_tms_comun          CHAR(14),# 26-39   Ident. Transmissor na Comun.
       ident_rcp_comun          CHAR(14),# 40-53   Ident. Receptor na Comun.
       cod_int_tms              CHAR(8), # 54-61   Código Interno do Transmissor
       cod_int_rcp              CHAR(8), # 54-61   Código Interno do Receptor
       nom_tms                  CHAR(25),# 62-69   Nome do Transmissor
       nom_rcp                  CHAR(25),# 70-94   Nome do Receptor
       espaco_itp               CHAR(9), # 95-119  Espaço
       ident_cr1                CHAR(3), # 1-3     Ident. Tipo Registro - CR1
       num_nf_orig              CHAR(6), # 4-9     Número da NF origem
       ser_nf_orig              CHAR(4), # 10-13   Séria da NF de origem
       dat_embarq               CHAR(6), # 14-19   Data de Embarque
       dat_receb                CHAR(6), # 20-25   Data do Recebimento
       tip_receb                CHAR(1), # 26-26   Tipo de Recebimento
       cod_fab_dest             CHAR(3), # 27-29   Código da Fábrica destino
       dat_nf_orig              CHAR(6), # 30-35   Data da NF de origem
       dat_ent_sist             CHAR(6), # 36-41   Data de Entrada no sistema
       dat_conf_fis             CHAR(6), # 42-47   Data Conferência Física 
       cod_forn_mat_prim        CHAR(7), # 48-54   Cód. Fornecedor Matéria Prima
       espaco_cr1               CHAR(74),# 55-128  Espaço
       ident_cr2                CHAR(3), # 1-3     Ident. Tipo Registro - CR2
       cod_item                 CHAR(30),# 4-33    Código do item
       qtd_embarcada            CHAR(9), # 34-42   Quantidade Embarcada
       qtd_recebida             CHAR(9), # 43-51   Quantidade Recebida
       qtd_devolvida            CHAR(9), # 52-60   Quantidade Devolvida
       uni_med_estoq            CHAR(2), # 61-62   Unidade de medida estoque
       qtd_casas_dec            CHAR(1), # 63-63   Quantidade de Casas Decimais
       cod_discrep              CHAR(2), # 64-65   Código da discrepância
       qtd_aju_acum             CHAR(9), # 66-74   Quantidade p/ ajuste de Acum
       qtd_questao              CHAR(9), # 75-83   Quantidade em questão
       num_ped_comp             CHAR(12),# 84-95   Numero do pedido de compra
       alt_tec_item             CHAR(4), # 96-99   Alteração Técnica do Item
       espaco_cr2               CHAR(29),# 100-128 Espaço
       ident_ftp                CHAR(3), # 1-3     Ident. Tipo Registro - FTP
       num_ctr_tms_ftp          CHAR(5), # 4-8     Numero Contr. Transmissao
       qtd_reg_transac          CHAR(9), # 9-17    Quantidade Registro Transacao
       num_tot_val              CHAR(17),# 18-34   Numero total de valores
       categ_operac             CHAR(1), # 35-35   Categoria da Operacao
       espaco_ftp               CHAR(93) # 36-128  Espaço
                            END RECORD           

   DEFINE l_tipo                SMALLINT

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1

   FORMAT

      ON EVERY ROW 
         CASE
            WHEN l_tipo = 1 
               PRINT COLUMN 001, lr_arq_edi.ident_itp;
               PRINT COLUMN 004, lr_arq_edi.ident_proc;       
               PRINT COLUMN 007, lr_arq_edi.num_ver_transac;  
               PRINT COLUMN 009, lr_arq_edi.num_ctr_transm;   
               PRINT COLUMN 014, lr_arq_edi.ident_ger_mov;    
               PRINT COLUMN 026, lr_arq_edi.ident_tms_comun;  
               PRINT COLUMN 040, lr_arq_edi.ident_rcp_comun;  
               PRINT COLUMN 054, lr_arq_edi.cod_int_tms;      
               PRINT COLUMN 062, lr_arq_edi.cod_int_rcp;      
               PRINT COLUMN 070, lr_arq_edi.nom_tms;          
               PRINT COLUMN 095, lr_arq_edi.nom_rcp;          
               PRINT COLUMN 120, lr_arq_edi.espaco_itp       
     
            WHEN l_tipo = 2
               PRINT COLUMN 001, lr_arq_edi.ident_cr1;        
               PRINT COLUMN 004, lr_arq_edi.num_nf_orig USING '&&&&&&'; 
               PRINT COLUMN 010, lr_arq_edi.ser_nf_orig;      
               PRINT COLUMN 014, lr_arq_edi.dat_embarq;       
               PRINT COLUMN 020, lr_arq_edi.dat_receb;        
               PRINT COLUMN 026, lr_arq_edi.tip_receb;        
               PRINT COLUMN 027, lr_arq_edi.cod_fab_dest;     
               PRINT COLUMN 030, lr_arq_edi.dat_nf_orig;      
               PRINT COLUMN 036, lr_arq_edi.dat_ent_sist;     
               PRINT COLUMN 042, lr_arq_edi.dat_conf_fis;     
               PRINT COLUMN 048, lr_arq_edi.cod_forn_mat_prim;
               PRINT COLUMN 055, lr_arq_edi.espaco_cr1       
      
            WHEN l_tipo = 3
               PRINT COLUMN 001, lr_arq_edi.ident_cr2;        
               PRINT COLUMN 004, lr_arq_edi.cod_item;         
               PRINT COLUMN 034, lr_arq_edi.qtd_embarcada;    
               PRINT COLUMN 043, lr_arq_edi.qtd_recebida;     
               PRINT COLUMN 052, lr_arq_edi.qtd_devolvida;    
               PRINT COLUMN 061, lr_arq_edi.uni_med_estoq;    
               PRINT COLUMN 063, lr_arq_edi.qtd_casas_dec;    
               PRINT COLUMN 064, lr_arq_edi.cod_discrep;      
               PRINT COLUMN 066, lr_arq_edi.qtd_aju_acum;     
               PRINT COLUMN 075, lr_arq_edi.qtd_questao;      
               PRINT COLUMN 084, lr_arq_edi.num_ped_comp;     
               PRINT COLUMN 096, lr_arq_edi.alt_tec_item;     
               PRINT COLUMN 100, lr_arq_edi.espaco_cr2       
             
            WHEN l_tipo = 4  
               PRINT COLUMN 001, lr_arq_edi.ident_ftp;        
               PRINT COLUMN 004, lr_arq_edi.num_ctr_tms_ftp;  
               PRINT COLUMN 009, lr_arq_edi.qtd_reg_transac;  
               PRINT COLUMN 018, lr_arq_edi.num_tot_val;      
               PRINT COLUMN 035, lr_arq_edi.categ_operac;     
               PRINT COLUMN 036, lr_arq_edi.espaco_ftp;       
               PRINT log500_termina_configuracao()
         END CASE

END REPORT 

#-----------------------#
 FUNCTION pol0334_popup()
#-----------------------#
   CASE
      WHEN INFIELD(cod_cliente)
         CALL sup162_popup_fornecedor() RETURNING ma_tela[pa_curr].cod_cliente
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0334
         DISPLAY ma_tela[pa_curr].cod_cliente TO s_clientes[sc_curr].cod_cliente
         CALL pol0334_verifica_cliente() RETURNING p_status
   END CASE

END FUNCTION        

#-----------------------#
 FUNCTION pol0334_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION