#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1277                                                 #
# OBJETIVO: RELATÓRIO DE ENTRDA DE APARAS                           #
# AUTOR...: IVO                                                     #
# DATA....: 25/02/15                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_fornecedor      VARCHAR(10),
       m_item            VARCHAR(10),
       m_datini          VARCHAR(10),
       m_datfim          VARCHAR(10),
       m_page_length     SMALLINT,
       m_ies_info        SMALLINT,
       m_peso_balanca    DECIMAL(10,3),
       m_dif_qtd         DECIMAL(10,3),
       m_preco_cotacao   DECIMAL(8,2),
       m_den_status      VARCHAR(15),
       m_cod_sttus       VARCHAR(01),
       m_val_cotacao     DECIMAL(12,2),
       m_count           INTEGER,
       m_den_item        VARCHAR(40),
       m_raz_social      VARCHAR(40),
       m_msg             VARCHAR(150),
       m_nom_tela        VARCHAR(200),
       m_ies_cons        SMALLINT

DEFINE mr_parametro      RECORD
       dat_ini           DATE,
       dat_fim           DATE,
       cod_fornecedor    VARCHAR(15),
       cod_item          VARCHAR(15)
END RECORD

DEFINE mr_relat          RECORD
       cod_fornecedor    VARCHAR(15),
       cod_item          VARCHAR(15),
       dat_entrada_nf    DATE,
       num_nf            INTEGER,
       num_aviso_rec     INTEGER,
       num_seq_ar        INTEGER,
       pre_unit_nf       DECIMAL(6,2),
       qtd_declarad_nf   DECIMAL(10,3),
       val_liquido_item  DECIMAL(7,2)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   DEFER INTERRUPT

   LET p_versao = "pol1277-10.02.00  "
   CALL func002_versao_prg(p_versao)

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol1277_menu()
   END IF   
   
END MAIN

#----------------------#
FUNCTION pol1277_menu()#
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE m_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1277") RETURNING m_nom_tela
   LET m_nom_tela = m_nom_tela CLIPPED 
   OPEN WINDOW w_pol1277 AT 2,2 WITH FORM m_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros p/ o processamento"
         IF pol1277_informar() THEN
            LET m_ies_cons = TRUE
            ERROR 'Parâmetros informados com sucesso.'
            NEXT OPTION "Listar"
         ELSE
            LET m_ies_cons = TRUE
            CALL pol1277_limpa_tela()
            ERROR 'Operação cancelada'
         END IF
      COMMAND "Listar" "Processa a geração do relatório"
         IF m_ies_cons THEN
            CALL pol1277_processar() 
         ELSE
            ERROR "Informe os parâmetros previamente"
            NEXT OPTION "Informar"
         END IF
         LET m_ies_cons = FALSE
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1277

END FUNCTION

#----------------------------#
FUNCTION pol1277_limpa_tela()#
#----------------------------#
   
   CLEAR FORM
   
   DISPLAY p_cod_empresa TO cod_empresa
       
END FUNCTION

#--------------------------#
FUNCTION pol1277_informar()#
#--------------------------#
   
   DEFINE l_qtd_dias INTEGER
   
   LET INT_FLAG = FALSE
   INITIALIZE mr_parametro TO NULL
   
   INPUT BY NAME mr_parametro.* WITHOUT DEFAULTS 
   
      AFTER FIELD cod_fornecedor
         
         IF mr_parametro.cod_fornecedor IS NOT NULL THEN
            SELECT raz_social
              INTO m_raz_social
              FROM fornecedor
             WHERE cod_fornecedor = mr_parametro.cod_fornecedor
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','fornecedor')
               NEXT FIELD cod_fornecedor
            END IF
         ELSE
            LET m_raz_social = NULL
         END IF
         
         DISPLAY m_raz_social TO raz_social

      AFTER FIELD cod_item
         
         IF mr_parametro.cod_item IS NOT NULL THEN
            SELECT den_item
              INTO m_den_item
              FROM item
             WHERE cod_empresa = p_cod_empresa 
               AND cod_item = mr_parametro.cod_item
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','item')
               NEXT FIELD item
            END IF
         ELSE
            LET m_den_item = NULL
         END IF
         
         DISPLAY m_den_item TO den_item
            
      AFTER INPUT
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         IF mr_parametro.dat_ini IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD dat_ini
         END IF

         IF mr_parametro.dat_fim IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD dat_fim
         END IF
         
         IF mr_parametro.dat_ini > mr_parametro.dat_fim THEN
            ERROR 'Periodo inválido.'
            NEXT FIELD dat_ini
         END IF
         
         LET l_qtd_dias = mr_parametro.dat_fim - mr_parametro.dat_ini
         
         IF l_qtd_dias > 365 THEN
            ERROR 'O período não deve ser maior que um ano'
            NEXT FIELD dat_ini
         END IF

      ON KEY (control-z)
         CALL pol1277_popup()
  
   END INPUT
   
   RETURN TRUE 
    
END FUNCTION

#-----------------------#
FUNCTION pol1277_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1277

         IF p_codigo IS NOT NULL THEN
            LET mr_parametro.cod_fornecedor = p_codigo
            DISPLAY p_codigo TO cod_fornecedor
         END IF

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1277

         IF p_codigo IS NOT NULL THEN
           LET mr_parametro.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

   END CASE

END FUNCTION 

#---------------------------#
FUNCTION pol1277_processar()#
#---------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE m_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1277a") RETURNING m_nom_tela
   LET m_nom_tela = m_nom_tela CLIPPED 
   OPEN WINDOW w_pol1277a AT 8,10 WITH FORM m_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol1277_carrega_dados()
   
   SELECT COUNT(*)
     INTO m_count
     FROM relat_pol1277_885
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','relat_pol1277_885')
   ELSE
      IF m_count = 0 THEN
         LET m_msg = 'Não há dados para os\n parâmetros informados'
         CALL log0030_mensagem(m_msg,'info')
      ELSE
         CALL pol1277_exec_delphi()
      END IF
   END IF
      
   CLOSE WINDOW w_pol1277a

END FUNCTION

#-------------------------------#
FUNCTION pol1277_carrega_dados()#
#-------------------------------#

   DEFINE sql_stmt      VARCHAR(5000),
          l_progres     SMALLINT

   IF NOT pol1277_del_tab_relat() THEN
      RETURN FALSE
   END IF

   LET sql_stmt =
       " SELECT n.cod_fornecedor,  a.cod_item, n.dat_entrada_nf, n.num_nf, ",
       " n.num_aviso_rec, a.num_seq, a.pre_unit_nf, a.qtd_declarad_nf, a.val_liquido_item ",
       " FROM nf_sup n, aviso_rec a, item i, familia_insumo_885 f ",
       " WHERE n.cod_empresa = '",p_cod_empresa,"' ",
       " AND n.cod_empresa = a.cod_empresa AND n.num_aviso_rec = a.num_aviso_rec ",
       " AND i.cod_empresa = a.cod_empresa AND i.cod_item = a.cod_item ",
       " AND f.cod_empresa = i.cod_empresa AND f.cod_familia = i.cod_familia AND f.ies_apara = 'S' ",
       " AND n.dat_entrada_nf >= '",mr_parametro.dat_ini,"' ",
       " AND n.dat_entrada_nf <= '",mr_parametro.dat_fim,"' "

   IF mr_parametro.cod_fornecedor IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND n.cod_fornecedor = '",mr_parametro.cod_fornecedor,"' "
   END IF
   
   IF mr_parametro.cod_item IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND i.cod_item = '",mr_parametro.cod_item,"' "
   END IF
   
   LET sql_stmt = sql_stmt CLIPPED, " ORDER BY n.cod_fornecedor, n.dat_entrada_nf "
   
   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','var_query')
      RETURN FALSE
   END IF
   
   LET m_count = 0
   
   DECLARE cq_padrao CURSOR FOR var_query

   FOREACH cq_padrao INTO mr_relat.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_padrao')
         RETURN FALSE
      END IF
      
      DISPLAY mr_relat.num_aviso_rec TO num_ar
      #lds CALL LOG_refresh_display()	
      
      SELECT cod_status 
        INTO m_cod_sttus
        FROM ar_aparas_885 
       WHERE cod_empresa = p_cod_empresa
         AND num_aviso_rec = mr_relat.num_aviso_rec

      IF STATUS = 100 THEN
         LET m_den_status = 'NAO INICIADA'
         LET m_preco_cotacao = 0
         LET m_peso_balanca = 0
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ar_aparas_885')
            RETURN FALSE
         ELSE
            IF NOT pol1277_le_contagem() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
      
      LET m_val_cotacao = m_peso_balanca * m_preco_cotacao
      
      LET m_dif_qtd = mr_relat.qtd_declarad_nf - m_peso_balanca
      
      IF NOT pol1277_ins_relat() THEN
         RETURN FALSE
      END IF
      
      INITIALIZE mr_relat, m_peso_balanca, m_preco_cotacao,
         m_val_cotacao, m_dif_qtd, m_den_status TO NULL
            
   END FOREACH

   INSERT INTO periodo_relat_885
     VALUES('POL1277', p_cod_empresa, p_user, 
            mr_parametro.dat_ini, mr_parametro.dat_fim)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','periodo_pol1277_885')
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1277_del_tab_relat()#
#-------------------------------#   
   
   DELETE FROM relat_pol1277_885
    WHERE cod_empresa = p_cod_empresa
      AND usuario = p_user
   
   SELECT COUNT(*) 
     INTO m_count
     FROM relat_pol1277_885
    WHERE cod_empresa = p_cod_empresa
      AND usuario = p_user
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','relat_pol1277_885')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Não foi possivel limpar a\n',
                  'tabela relat_pol1277_885'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   DELETE FROM periodo_relat_885
    WHERE cod_empresa = p_cod_empresa
      AND nom_programa = 'POL1277'
      AND usuario = p_user

   SELECT COUNT(*) 
     INTO m_count
     FROM periodo_relat_885
    WHERE cod_empresa = p_cod_empresa
      AND nom_programa = 'POL1277'
      AND usuario = p_user
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','periodo_pol1277_885')
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Não foi possivel limpar a\n',
                  'tabela periodo_pol1277_885'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1277_le_contagem()#
#-----------------------------#

   LET m_peso_balanca = 0
   
   SELECT preco_cotacao 
     INTO m_preco_cotacao
     FROM umd_aparas_885 
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = mr_relat.num_aviso_rec
      AND num_seq_ar = mr_relat.num_seq_ar

   IF STATUS <> 0 THEN
      LET m_preco_cotacao = 0
   ELSE
      SELECT SUM(qtd_contagem)
        INTO m_peso_balanca
        FROM cont_aparas_885
       WHERE cod_empresa = p_cod_empresa
         AND num_aviso_rec = mr_relat.num_aviso_rec
         AND num_seq_ar = mr_relat.num_seq_ar
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cont_aparas_885')
         RETURN FALSE
      END IF
      IF m_peso_balanca IS NULL THEN
         LET m_peso_balanca = 0
      END IF
   END IF
   
   CASE m_cod_sttus
        WHEN 'D' LET m_den_status = 'LANCANDO LOTE'
        WHEN 'C' LET m_den_status = 'LANCANDO PESO'
        WHEN 'L' LET m_den_status = 'INSPECIONANDO'
        WHEN 'I' LET m_den_status = 'INTEGRANDO CAP'
        WHEN 'P' LET m_den_status = 'CONCLUIDA'
   END CASE
   
   RETURN TRUE
              
END FUNCTION

#---------------------------#
FUNCTION pol1277_ins_relat()#
#---------------------------#

   INSERT INTO relat_pol1277_885
   VALUES(p_cod_empresa,
          mr_relat.cod_fornecedor,   
          mr_relat.num_aviso_rec,    
          mr_relat.num_seq_ar,       
          mr_relat.dat_entrada_nf,   
          mr_relat.num_nf,           
          mr_relat.cod_item,         
          mr_relat.qtd_declarad_nf,  
          mr_relat.pre_unit_nf,      
          mr_relat.val_liquido_item,
          m_peso_balanca,    
          m_preco_cotacao,   
          m_val_cotacao,     
          m_dif_qtd,         
          m_den_status,
          p_user)      
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','relat_pol1277_885')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1277_exec_delphi()#
#-----------------------------#

   DEFINE l_param        CHAR(42),
          l_comando      CHAR(200),
          l_caminho      CHAR(100)
          
   LET l_param = p_cod_empresa CLIPPED, ' ', p_user CLIPPED
   
   SELECT nom_caminho
     INTO l_caminho
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = 'DPH'
  
   IF l_caminho IS NULL THEN
      LET m_msg = 'Caminho do sistema DPH não en-\n',
                  'contrado. Consulte a log1100.'
      CALL log0030_mensagem(m_msg,'Info')
      RETURN
   END IF
  
   LET l_comando = l_caminho CLIPPED, 'pgi1277.exe ', l_param

   CALL conout(l_comando)

   CALL runOnClient(l_comando)

END FUNCTION   

#-------------------------------- FIM DE PROGRAMA -----------------------------#
