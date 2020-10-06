###PARSER-Não remover esta linha(Framework Logix)###
#---------------------------------------------#
# SISTEMA.: GEO                               #
# PROGRAMA: geo1028 (mcx0805)                 #
# OBJETIVO: GERACAO DOCUMENTOS - TRB          #
# AUTOR...: EVANDRO SIMENES                   #
# DATA....: 29/04/2016                        #
#---------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
         p_user          LIKE usuario.nom_usuario,
         p_status        SMALLINT,
         g_ies_grafico   SMALLINT,
         m_nom_help      CHAR(200),
         m_versao_funcao CHAR(18),
         p_comando       CHAR(80),
         p_caminho       CHAR(80),
         p_nom_tela      CHAR(80),
         g_val_docum     LIKE mcx_movto.val_docum

END GLOBALS

# MODULARES
  DEFINE mr_tela        RECORD
                           empresa_destino LIKE mcx_movto_trb.empresa_destino,
                           des_emp_destino LIKE empresa.den_empresa,
                           banco           LIKE mcx_movto_trb.banco,
                           nom_banco       LIKE bancos.nom_banco,
                           agencia         LIKE mcx_movto_trb.agencia,
                           conta_banco     LIKE mcx_movto_trb.conta_banco,
                           lote            LIKE mcx_movto_trb.lote,
                           sequencia_docum LIKE mcx_movto_trb.sequencia_docum,
                           docum           LIKE mcx_movto_trb.docum,
                           dat_movto       LIKE mcx_movto_trb.dat_movto,
                           dias_retencao   SMALLINT,
                           debito_credito  LIKE mcx_movto_trb.debito_credito,
                           des_deb_cre     CHAR(07),
                           val_docum       LIKE mcx_movto_trb.val_docum,
                           tip_docum       LIKE mcx_movto_trb.tip_docum,
                           des_tip_docum   CHAR(09)
                        END RECORD

 DEFINE m_caixa        LIKE mcx_movto.caixa,
        m_dat_movto    LIKE mcx_movto.dat_movto,
        m_operacao     LIKE mcx_movto.operacao,
        m_sequencia    LIKE mcx_movto.sequencia_caixa,
        m_num_docum    LIKE mcx_movto.docum,
        m_tip_operacao LIKE mcx_movto.tip_operacao

# END MODULARES

#--------------------------------------------------------------------------------------#
 FUNCTION geo1028_gera_trb(l_caixa, l_dat_movto, l_operacao, l_sequencia, l_num_docum)
#--------------------------------------------------------------------------------------#
 DEFINE l_caixa      LIKE mcx_movto.caixa,
        l_dat_movto  LIKE mcx_movto.dat_movto,
        l_operacao   LIKE mcx_movto.operacao,
        l_sequencia  LIKE mcx_movto.sequencia_caixa,
        l_num_docum  LIKE mcx_movto.docum,
        l_enter      SMALLINT,
        l_status     SMALLINT

 INITIALIZE mr_tela.*  TO NULL

 LET m_caixa     = l_caixa
 LET m_dat_movto = l_dat_movto
 LET m_operacao  = l_operacao
 LET m_sequencia = l_sequencia
 LET m_num_docum = l_num_docum


 CALL geo1028_seleciona_tip_operacao()


 #LET m_versao_funcao = "geo1028-05.10.02p" #Favor nao alterar esta linha (SUPORTE)

 #OPTIONS
 #  HELP     FILE m_nom_help

 #CALL log130_procura_caminho("geo1028") RETURNING p_nom_tela
 #OPEN WINDOW w_geo1028 AT 4,2 WITH FORM p_nom_tela
 #     ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

 #DISPLAY p_cod_empresa TO empresa
 #CURRENT WINDOW IS w_geo1028

 #IF NOT geo1028_verifica_registros() THEN
 #   IF NOT geo1028_inclusao() THEN
 #      CLOSE WINDOW w_geo1028
 #      LET g_val_docum = NULL
 #      RETURN "X"
 #   END IF
 #ELSE
    CALL geo1028_verifica_empresa() RETURNING l_status
    CALL geo1028_verifica_banco()   RETURNING l_status
    CALL geo1028_busca_deb_cre()
    CALL geo1028_busca_tip_docum()
    CALL geo1028_busca_dias_retencao()

    #DISPLAY BY NAME mr_tela.*
    #PROMPT "Tecle <ENTER> para continuar." FOR l_enter
 #END IF

 #CLOSE WINDOW w_geo1028
 LET g_val_docum = mr_tela.val_docum
 RETURN mr_tela.docum

END FUNCTION

#--------------------------------------#
 FUNCTION geo1028_verifica_registros()
#--------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT empresa_destino, banco, agencia, conta_banco, lote,
         sequencia_docum, docum, val_docum, tip_docum, dat_movto, debito_credito
    INTO mr_tela.empresa_destino, mr_tela.banco, mr_tela.agencia,
         mr_tela.conta_banco, mr_tela.lote, mr_tela.sequencia_docum,
         mr_tela.docum, mr_tela.val_docum, mr_tela.tip_docum,
         mr_tela.dat_movto, mr_tela.debito_credito
    FROM mcx_movto_trb
   WHERE empresa   = p_cod_empresa
     AND caixa     = m_caixa
     AND dat_movto = m_dat_movto
     AND sequencia_caixa = m_sequencia
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE mr_tela.* TO NULL
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------#
 FUNCTION geo1028_inclusao()
#---------------------------#
 CLEAR FORM
 DISPLAY p_cod_empresa TO empresa

 IF geo1028_entrada_dados() THEN
    IF geo1028_gera_movfin() THEN
       RETURN TRUE
    END IF
 END IF

 RETURN FALSE

 END FUNCTION

#-------------------------------#
 FUNCTION geo1028_busca_dados()
#-------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT banco, agencia, conta_banco
    INTO mr_tela.banco, mr_tela.agencia, mr_tela.conta_banco
    FROM mcx_oper_caixa_trb
   WHERE empresa  = p_cod_empresa
     AND operacao = m_operacao
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
   SELECT empresa_matriz
     INTO mr_tela.empresa_destino
     FROM mcx_matriz_filial
    WHERE empresa_filial = p_cod_empresa
 WHENEVER ERROR STOP

 IF mr_tela.empresa_destino IS NULL THEN
    LET mr_tela.empresa_destino = p_cod_empresa
 END IF

 END FUNCTION

#--------------------------------#
 FUNCTION geo1028_entrada_dados()
#--------------------------------#
 DEFINE l_mes_caixa      CHAR(02),
        l_ano_caixa      CHAR(04),
        l_dat_caixa_ini  DATE,
        l_dat_caixa_fim  DATE

 CALL log006_exibe_teclas("01 02 03 ", m_versao_funcao)
 CURRENT WINDOW IS w_geo1028

 LET INT_FLAG = FALSE

 IF m_tip_operacao = 'S' THEN
    LET mr_tela.debito_credito = 'C'
    LET mr_tela.tip_docum = 'CR'
 ELSE
    LET mr_tela.debito_credito = 'D'
    LET mr_tela.tip_docum = 'DB'
 END IF

 DISPLAY BY NAME mr_tela.debito_credito, mr_tela.tip_docum
 CALL geo1028_busca_tip_docum()


 CALL geo1028_busca_dados()

 INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

    BEFORE FIELD empresa_destino
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('control-z',"Zoom")
       ELSE
          DISPLAY "( Zoom )" AT 3,60
       END IF

    AFTER FIELD empresa_destino
       IF mr_tela.empresa_destino IS NOT NULL THEN
          IF NOT geo1028_verifica_empresa() THEN
             ERROR "Empresa não cadastrada."
             NEXT FIELD empresa_destino
          END IF
       ELSE
          LET mr_tela.des_emp_destino = NULL
          DISPLAY BY NAME mr_tela.des_emp_destino
       END IF

    AFTER FIELD banco
       IF mr_tela.banco IS NOT NULL THEN
          IF NOT geo1028_verifica_banco() THEN
             ERROR "Banco não cadastrado."
             NEXT FIELD banco
          END IF
       ELSE
          LET mr_tela.nom_banco = NULL
          DISPLAY BY NAME mr_tela.nom_banco
       END IF

    AFTER FIELD agencia
       IF mr_tela.agencia IS NOT NULL THEN
          IF NOT geo1028_verifica_agencia() THEN
             ERROR "Agência não cadastrada para este banco."
             NEXT FIELD agencia
          END IF
       END IF

    AFTER FIELD conta_banco
       IF mr_tela.conta_banco IS NOT NULL THEN
          IF NOT geo1028_verifica_conta() THEN
             ERROR "Conta não cadastrada para esta agência."
             NEXT FIELD conta_banco
          END IF
       END IF
       IF mr_tela.lote IS NULL OR mr_tela.lote = 0 OR mr_tela.lote = ' ' THEN             
          CALL geo1028_busca_lote(FALSE)                                                  
          CALL geo1028_busca_seq()                                                        
          WHILE geo1028_verifica_inclusao_trb()                                         
             LET mr_tela.sequencia_docum = mr_tela.sequencia_docum + 1                       
             IF mr_tela.sequencia_docum = 99 THEN                                               
                CALL geo1028_busca_lote(TRUE)                                                   
                LET mr_tela.sequencia_docum = 1                                              
             END IF                                                                       
          END WHILE                                                                                                                                                       
          DISPLAY BY NAME mr_tela.sequencia_docum                                      
       END IF       
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('control-z',"")
       ELSE
          DISPLAY "--------" AT 3,60
       END IF

    AFTER FIELD docum
       IF mr_tela.docum IS NOT NULL THEN
          IF geo1028_verifica_inclusao() THEN
             ERROR "Documento já existente no Módulo de Caixa."
             NEXT FIELD empresa_destino
          END IF
          IF geo1028_verifica_inclusao_trb() THEN
             ERROR "Documento já existente no TRB."
             NEXT FIELD empresa_destino
          END IF
       END IF
       LET mr_tela.dat_movto = m_dat_movto
       DISPLAY BY NAME mr_tela.dat_movto

    AFTER FIELD dat_movto
       LET l_mes_caixa = EXTEND(m_dat_movto, MONTH TO MONTH)
       LET l_ano_caixa = EXTEND(m_dat_movto, YEAR TO YEAR)
       LET l_dat_caixa_ini = MDY(l_mes_caixa,"01",l_ano_caixa)
       LET l_dat_caixa_fim = l_dat_caixa_ini + 1 UNITS MONTH
       LET l_dat_caixa_fim = l_dat_caixa_fim - 1 UNITS DAY

       IF mr_tela.dat_movto < l_dat_caixa_ini OR mr_tela.dat_movto > l_dat_caixa_fim THEN
          ERROR "Data do Movimento deve estar dentro do mês do CAIXA."
          NEXT FIELD dat_movto
       END IF

    BEFORE FIELD dias_retencao
       LET mr_tela.dias_retencao = 0
       DISPLAY BY NAME mr_tela.dias_retencao


    {AFTER FIELD tip_docum
       IF mr_tela.tip_docum IS NOT NULL THEN
          CALL geo1028_busca_tip_docum()

          IF mr_tela.tip_docum = 'CR' THEN
             LET mr_tela.debito_credito = "C"
          ELSE
             LET mr_tela.debito_credito = "D"
          END IF
          DISPLAY BY NAME mr_tela.debito_credito
          CALL geo1028_busca_deb_cre()
       END IF}

    ON KEY (control-w)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
       CALL geo1028_help()
    ON KEY (control-z,f4)
       CALL geo1028_popup()

    AFTER INPUT
       IF NOT INT_FLAG THEN
          IF mr_tela.empresa_destino IS NOT NULL THEN
             IF NOT geo1028_verifica_empresa() THEN
                ERROR "Empresa não cadastrada."
                NEXT FIELD empresa_destino
             END IF
          ELSE
             ERROR "Empresa Destino deve ser informada."
             NEXT FIELD empresa_destino
          END IF

          IF mr_tela.banco IS NOT NULL THEN
             IF NOT geo1028_verifica_banco() THEN
                ERROR "Banco não cadastrado."
                NEXT FIELD banco
             END IF
          ELSE
             ERROR "Banco deve ser informado."
             NEXT FIELD banco
          END IF

          IF mr_tela.agencia IS NOT NULL THEN
             IF NOT geo1028_verifica_agencia() THEN
                ERROR "Agência não cadastrada para este banco."
                NEXT FIELD agencia
             END IF
          ELSE
             ERROR "Agência deve ser informada."
             NEXT FIELD agencia
          END IF

          IF mr_tela.conta_banco IS NOT NULL THEN
             IF NOT geo1028_verifica_conta() THEN
                ERROR "Conta não cadastrada para esta agência."
                NEXT FIELD conta_banco
             END IF
          ELSE
             ERROR "Conta deve ser informada."
             NEXT FIELD conta_banco
          END IF

          IF mr_tela.lote IS NULL OR mr_tela.lote = " " THEN
             CALL geo1028_busca_lote(FALSE)
             CALL geo1028_busca_seq()                                                        
             WHILE geo1028_verifica_inclusao_trb()                                  
                LET mr_tela.sequencia_docum = mr_tela.sequencia_docum + 1                       
                IF mr_tela.sequencia_docum = 99 THEN                                               
                   CALL geo1028_busca_lote(TRUE)                                                   
                   LET mr_tela.sequencia_docum = 1                                              
                END IF                                                                       
             END WHILE                                                                                                                                                       DISPLAY BY NAME mr_tela.sequencia_docum   
          END IF

          IF mr_tela.docum IS NOT NULL THEN
             IF geo1028_verifica_inclusao() THEN
                ERROR "Documento já existente no Módulo de Caixa."
                NEXT FIELD empresa_destino
             END IF
			          IF geo1028_verifica_inclusao_trb() THEN
			             ERROR "Documento já existente no TRB."
			             NEXT FIELD empresa_destino
			          END IF
          ELSE
             ERROR "Documento deve ser informado."
             NEXT FIELD docum
          END IF

          IF mr_tela.dias_retencao IS NULL THEN
             ERROR "Quantidade de Dias de Retenção deve ser informada."
             NEXT FIELD dias_retencao
          END IF
          IF mr_tela.val_docum IS NULL THEN
             ERROR "Valor do Documento deve ser informado."
             NEXT FIELD val_docum
          END IF
          {IF mr_tela.tip_docum IS NOT NULL THEN
             CALL geo1028_busca_tip_docum()

             IF mr_tela.tip_docum = 'CR' THEN
                LET mr_tela.debito_credito = "C"
             ELSE
                LET mr_tela.debito_credito = "D"
             END IF
             DISPLAY BY NAME mr_tela.debito_credito
             CALL geo1028_busca_deb_cre()
          ELSE
             ERROR "Tipo do Documento deve ser informado."
             NEXT FIELD tip_docum
          END IF}

          IF NOT log004_confirm(10,20) THEN
             NEXT FIELD empresa_destino
          END IF
       END IF
 END INPUT

 CALL log006_exibe_teclas('01', m_versao_funcao)
 CURRENT WINDOW IS w_geo1028

 IF INT_FLAG THEN
    LET int_flag = FALSE
    CLEAR FORM
    DISPLAY p_cod_empresa TO empresa
    DISPLAY "--------" AT 3,60
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#-------------------------------------#
 FUNCTION geo1028_verifica_inclusao()
#-------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT *
    FROM mcx_movto_trb
   WHERE empresa         = p_cod_empresa
     AND caixa           = m_caixa
     AND dat_movto       = m_dat_movto
     AND empresa_destino = mr_tela.empresa_destino
     AND docum           = mr_tela.docum
     AND sequencia_caixa = m_sequencia
     AND sequencia_docum = mr_tela.sequencia_docum
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    RETURN TRUE
 END IF

 RETURN FALSE

 END FUNCTION

#-----------------------------------------#
 FUNCTION geo1028_verifica_inclusao_trb()
#-----------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT * FROM movfin
   WHERE cod_empresa = mr_tela.empresa_destino
     AND num_lote    = mr_tela.lote
     AND seq_dig     = mr_tela.sequencia_docum
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    RETURN TRUE
 END IF

 RETURN FALSE

 END FUNCTION

#-----------------------------------#
 FUNCTION geo1028_verifica_empresa()
#-----------------------------------#
 LET mr_tela.des_emp_destino = NULL

 WHENEVER ERROR CONTINUE
  SELECT den_empresa
    INTO mr_tela.des_emp_destino
    FROM empresa
   WHERE cod_empresa = mr_tela.empresa_destino
 WHENEVER ERROR STOP

 DISPLAY BY NAME mr_tela.des_emp_destino

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------------#
 FUNCTION geo1028_verifica_banco()
#---------------------------------#
 LET mr_tela.nom_banco = NULL

 WHENEVER ERROR CONTINUE
  SELECT nom_banco
    INTO mr_tela.nom_banco
    FROM bancos
   WHERE cod_banco = mr_tela.banco
 WHENEVER ERROR STOP

 DISPLAY BY NAME mr_tela.nom_banco

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------------#
 FUNCTION geo1028_verifica_agencia()
#------------------------------------#
 DECLARE cl_agencia_bco CURSOR FOR
  SELECT num_agencia
    FROM agencia_bco
   WHERE cod_banco   = mr_tela.banco
     AND num_agencia = mr_tela.agencia

  OPEN cl_agencia_bco
 FETCH cl_agencia_bco

 IF SQLCA.sqlcode = 0 THEN
    CLOSE cl_agencia_bco
     FREE cl_agencia_bco
    RETURN TRUE
 ELSE
    CLOSE cl_agencia_bco
     FREE cl_agencia_bco
    RETURN FALSE
 END IF

END FUNCTION

#------------------------------------#
 FUNCTION geo1028_verifica_conta()
#------------------------------------#
 DECLARE cl_conta CURSOR FOR
  SELECT b.num_conta_banc
    FROM agencia_bco a, agencia_bc_item b
   WHERE b.cod_empresa    = mr_tela.empresa_destino
     AND b.num_conta_banc = mr_tela.conta_banco
     AND b.cod_agen_bco   = a.cod_agen_bco
     AND a.cod_banco      = mr_tela.banco
     AND a.num_agencia    = mr_tela.agencia

  OPEN cl_conta
 FETCH cl_conta

 IF sqlca.sqlcode = 0 THEN
    CLOSE cl_conta
    FREE cl_conta
    RETURN TRUE
 ELSE
    CLOSE cl_conta
    FREE cl_conta
    RETURN FALSE
 END IF

END FUNCTION

#-----------------------------#
 FUNCTION geo1028_busca_lote(l_precisa_lote_novo)
#-----------------------------#
 DEFINE l_num_lote           LIKE capa_lotes.num_ult_lote_doc,
        l_precisa_lote_novo  SMALLINT

 INITIALIZE mr_tela.lote TO NULL

 IF l_precisa_lote_novo = FALSE THEN
    WHENEVER ERROR CONTINUE
     SELECT MAX(lote)
       INTO l_num_lote
       FROM mcx_movto_trb
      WHERE empresa         = p_cod_empresa
        AND caixa           = m_caixa
        AND dat_movto       = m_dat_movto
        AND empresa_destino = mr_tela.empresa_destino
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode = 0 THEN
       LET mr_tela.lote = l_num_lote
       DISPLAY BY NAME mr_tela.lote
       RETURN
    END IF
 END IF

    WHENEVER ERROR CONTINUE
     SELECT num_ult_lote_doc
       INTO mr_tela.lote
       FROM capa_lotes
      WHERE cod_empresa = mr_tela.empresa_destino
    WHENEVER ERROR STOP

    IF mr_tela.lote IS NULL OR mr_tela.lote = " " THEN
       LET mr_tela.lote = 0
    END IF
    LET mr_tela.lote = mr_tela.lote + 1

			 WHENEVER ERROR CONTINUE
			  UPDATE capa_lotes
			     SET num_ult_lote_doc = mr_tela.lote
			   WHERE cod_empresa = mr_tela.empresa_destino
			 WHENEVER ERROR STOP

 DISPLAY BY NAME mr_tela.lote

 END FUNCTION

#-----------------------------#
 FUNCTION geo1028_busca_seq()
#-----------------------------#
 WHENEVER ERROR CONTINUE
 SELECT MAX(sequencia_docum)
   INTO mr_tela.sequencia_docum
   FROM mcx_movto_trb
  WHERE empresa         = p_cod_empresa
    AND caixa           = m_caixa
    AND dat_movto       = m_dat_movto
    AND empresa_destino = mr_tela.empresa_destino
    AND lote            = mr_tela.lote
 WHENEVER ERROR STOP

 IF mr_tela.sequencia_docum IS NULL AND mr_tela.lote IS NOT NULL THEN
    LET mr_tela.sequencia_docum = 1
 ELSE
    IF mr_tela.sequencia_docum = 99 THEN
       # Neste momento tem que ser criado um lote novo e
       # criar a primeira sequencia do lote.
       CALL geo1028_busca_lote(TRUE)
       LET mr_tela.sequencia_docum = 1
    ELSE
       LET mr_tela.sequencia_docum = mr_tela.sequencia_docum + 1
    END IF
 END IF

 IF mr_tela.sequencia_docum IS NULL AND mr_tela.lote IS NULL THEN
    CALL geo1028_busca_lote(TRUE)
    LET mr_tela.sequencia_docum = 1
 END IF

 DISPLAY BY NAME mr_tela.sequencia_docum

 END FUNCTION

#--------------------------------#
 FUNCTION geo1028_busca_deb_cre()
#--------------------------------#
 CASE mr_tela.debito_credito
    WHEN "D" LET mr_tela.des_deb_cre = "DÉBITO"
    WHEN "C" LET mr_tela.des_deb_cre = "CRÉDITO"
 END CASE

 DISPLAY BY NAME mr_tela.des_deb_cre

 END FUNCTION

#----------------------------------#
 FUNCTION geo1028_busca_tip_docum()
#----------------------------------#
 CASE mr_tela.tip_docum
    WHEN "CH" LET mr_tela.des_tip_docum = "CHEQUE"
    WHEN "DP" LET mr_tela.des_tip_docum = "DUPLICATA"
    WHEN "CR" LET mr_tela.des_tip_docum = "CRÉDITO"
    WHEN "DB" LET mr_tela.des_tip_docum = "DÉBITO"
 END CASE

 DISPLAY BY NAME mr_tela.des_tip_docum

 END FUNCTION

#----------------------------------------#
 FUNCTION geo1028_busca_dias_retencao()
#----------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT qtd_dia_retencao
    INTO mr_tela.dias_retencao
    FROM movfin
   WHERE cod_empresa = mr_tela.empresa_destino
     AND num_lote    = mr_tela.lote
     AND seq_dig     = m_sequencia
 WHENEVER ERROR STOP

 END FUNCTION

#-----------------------------#
 FUNCTION geo1028_gera_movfin()
#-----------------------------#
 DEFINE l_dat_lib       DATE,
        l_sql_stmt      CHAR(2000),
        l_num_colunas   SMALLINT,
        l_compl_hist    LIKE movfin.compl_hist

 WHENEVER ERROR CONTINUE
  INSERT INTO mcx_movto_trb VALUES (p_cod_empresa, m_caixa, m_dat_movto,
                                    m_sequencia, mr_tela.empresa_destino,
                                    mr_tela.docum, mr_tela.tip_docum,
                                    mr_tela.banco, mr_tela.agencia,
                                    mr_tela.conta_banco, mr_tela.lote,
                                    mr_tela.sequencia_docum, mr_tela.debito_credito,
                                    mr_tela.val_docum)
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("INSERT","MCX_MOVTO_TRB")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
 END IF

 LET l_dat_lib = mr_tela.dat_movto + mr_tela.dias_retencao

 WHENEVER ERROR CONTINUE
  SELECT den_empresa
    INTO l_compl_hist
    FROM empresa
   WHERE cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP

 IF log0150_verifica_se_coluna_existe('movfin','tip_transf') THEN
    WHENEVER ERROR CONTINUE
      INSERT INTO movfin
      VALUES (mr_tela.empresa_destino,  # cod_empresa
              mr_tela.banco,            # cod_banco
              mr_tela.lote,             # num_lote
              mr_tela.sequencia_docum,  # seq_dig
              mr_tela.dat_movto,        # dat_movto
              mr_tela.docum,            # docum
              mr_tela.debito_credito,   # deb_cre
              NULL,                     # conta_deb
              NULL,                     # conta_cre
              mr_tela.val_docum,        # val_docum
              NULL,                     # cod_hist
              l_compl_hist,             # compl_hist
              'M',                      # origem_docum
              NULL,                     # dat_emis_fls
              NULL,                     # num_conc
              mr_tela.conta_banco,      # conta_banco
              mr_tela.agencia,          # agencia
              mr_tela.tip_docum,        # tip_docum
              0,                        # num_lote_lanc
              NULL,                     # cod_transacao
              NULL,                     # identificacao
              NULL,                     # area_cr_cc
              NULL,                     # num_lote_gecon
              NULL,                     # cod_lin_prod
              NULL,                     # cod_lin_recei
              NULL,                     # cod_seg_merc
              NULL,                     # cod_cla_uso
              NULL,                     # cod_conta_fluxo
              'N',                      # ies_docto_receb
              NULL,                     # num_relac
              mr_tela.val_docum,        # val_contabil
              0,                        # tip_transf
              'B',                      # tip_movto
              NULL,                     # tip_docum_cap
              mr_tela.dias_retencao,    # qtd_dia_retencao
              l_dat_lib)                # dat_liberacao
    WHENEVER ERROR STOP

 ELSE
  WHENEVER ERROR CONTINUE
    INSERT INTO movfin
      VALUES (mr_tela.empresa_destino,  # cod_empresa
              mr_tela.banco,            # cod_banco
              mr_tela.lote,             # num_lote
              mr_tela.sequencia_docum,  # seq_dig
              mr_tela.dat_movto,        # dat_movto
              mr_tela.docum,            # docum
              mr_tela.debito_credito,   # deb_cre
              NULL,                     # conta_deb
              NULL,                     # conta_cre
              mr_tela.val_docum,        # val_docum
              NULL,                     # cod_hist
              l_compl_hist,             # compl_hist
              'M',                      # origem_docum
              NULL,                     # dat_emis_fls
              NULL,                     # num_conc
              mr_tela.conta_banco,      # conta_banco
              mr_tela.agencia,          # agencia
              mr_tela.tip_docum,        # tip_docum
              0,                        # num_lote_lanc
              NULL,                     # cod_transacao
              NULL,                     # identificacao
              NULL,                     # area_cr_cc
              NULL,                     # num_lote_gecon
              NULL,                     # cod_lin_prod
              NULL,                     # cod_lin_recei
              NULL,                     # cod_seg_merc
              NULL,                     # cod_cla_uso
              NULL,                     # cod_conta_fluxo
              'N',                      # ies_docto_receb
              NULL,                     # num_relac
              mr_tela.val_docum)        # val_contabil
    WHENEVER ERROR STOP

 END IF

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("INSERT","MOVFIN")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  SELECT * FROM lotedoc
   WHERE cod_empresa = mr_tela.empresa_destino
     AND num_lote    = mr_tela.lote
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
     UPDATE lotedoc
        SET qtd_lanc     = qtd_lanc + 1,
            val_tot_real = val_tot_real + mr_tela.val_docum
      WHERE cod_empresa  = mr_tela.empresa_destino
        AND num_lote     = mr_tela.lote
    WHENEVER ERROR STOP

			 IF SQLCA.sqlcode <> 0 THEN
			    CALL log003_err_sql("UPDATE","LOTEDOC")
			    CALL log085_transacao("ROLLBACK")
			    RETURN FALSE
			 END IF
 ELSE
    WHENEVER ERROR CONTINUE
     INSERT INTO lotedoc VALUES (mr_tela.empresa_destino, mr_tela.lote,
                                 1, mr_tela.dat_movto,
                                 mr_tela.val_docum, 0, 0, "M")
    WHENEVER ERROR STOP

			 IF SQLCA.sqlcode <> 0 THEN
			    CALL log003_err_sql("INSERT","LOTEDOC")
			    CALL log085_transacao("ROLLBACK")
			    RETURN FALSE
			 END IF
 END IF

 RETURN TRUE

 END FUNCTION

#--------------------------#
 FUNCTION geo1028_popup()
#--------------------------#
 CASE
   WHEN INFIELD(empresa_destino)
      LET mr_tela.empresa_destino = men011_popup_cod_empresa(FALSE)
      CURRENT WINDOW IS w_geo1028

      IF mr_tela.empresa_destino IS NOT NULL THEN
         DISPLAY BY NAME mr_tela.empresa_destino
      END IF

   WHEN INFIELD(banco)
      LET mr_tela.banco = trb011_popup_bancos()
      CURRENT WINDOW IS w_geo1028

      IF mr_tela.banco IS NOT NULL THEN
         DISPLAY BY NAME mr_tela.banco
      END IF

   WHEN INFIELD(agencia)
      LET mr_tela.agencia = trb028_popup_agencias(mr_tela.empresa_destino,
                                                  mr_tela.banco)
      CURRENT WINDOW IS w_geo1028
      IF mr_tela.agencia IS NOT NULL THEN
         DISPLAY BY NAME mr_tela.agencia
      END IF

   WHEN INFIELD(conta_banco)
      LET mr_tela.conta_banco = trb024_popup_conta_banc(mr_tela.empresa_destino,
                                                        mr_tela.banco,
                                                        mr_tela.agencia)
      CURRENT WINDOW IS w_geo1028
      IF mr_tela.conta_banco IS NOT NULL THEN
         DISPLAY BY NAME mr_tela.conta_banco
      END IF

   WHEN INFIELD(tip_docum)
      LET mr_tela.tip_docum = log0830_list_box(5,20,
                         "CH {CHEQUE}, DP {DUPLICATA}, CR {CRÉDITO}, DB {DÉBITO}")

      CURRENT WINDOW IS w_geo1028
      DISPLAY BY NAME mr_tela.tip_docum
 END CASE

 END FUNCTION

#------------------------#
 FUNCTION geo1028_help()
#------------------------#
 CASE
    WHEN infield(empresa_destino) CALL showhelp(117)
    WHEN infield(banco)           CALL showhelp(128)
    WHEN infield(agencia)         CALL showhelp(129)
    WHEN infield(conta_banco)     CALL showhelp(130)
    WHEN infield(docum)           CALL showhelp(131)
    WHEN infield(dias_retencao)   CALL showhelp(132)
    WHEN infield(deb_cre)         CALL showhelp(133)
    WHEN infield(val_docum)       CALL showhelp(134)
    WHEN infield(tip_docum)       CALL showhelp(135)
 END CASE
END FUNCTION


#-------------------------------------------#
 FUNCTION geo1028_seleciona_tip_operacao()
#-------------------------------------------#

WHENEVER ERROR CONTINUE
  SELECT tip_operacao
    INTO m_tip_operacao
    FROM mcx_operacao_caixa
   WHERE empresa  = p_cod_empresa
     AND operacao = m_operacao
WHENEVER ERROR STOP

IF SQLCA.sqlcode <> 0 THEN
   IF SQLCA.sqlcode = 100 THEN
      ERROR " Não há tipo de operação para a operação: ", m_operacao
   ELSE
      CALL log003_err_sql("SELECT","MCX_OPERACAO_CAIXA")
   END IF
END IF

END FUNCTION

#-------------------------------#
 FUNCTION geo1028_version_info()
#-------------------------------#
  RETURN "$Archive: /logix10R2/financeiro/controle_movimento_caixa/funcoes/geo1028.4gl $|$Revision: 2 $|$Date: 16/07/09 10:34 $|$Modtime: 15/07/09 20:00 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION

