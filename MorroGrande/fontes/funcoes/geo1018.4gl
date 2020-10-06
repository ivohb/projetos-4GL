###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: GEO                                                   #
# PROGRAMA: geo1018 (COPIA ADAPTADA/AUTOMATIZADA DE MCX0007)      #
# OBJETIVO: GERAÇAO DE MOVIMENTACAO DE CAIXA                      #
# AUTOR...: EVANDRO SIMENES                                       #
# DATA....: 13/03/2016                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT

  DEFINE p_nom_arquivo          CHAR(100),
         g_ies_ambiente         CHAR(01),
         p_comando              CHAR(080),
         p_caminho              CHAR(80),
         p_ies_impressao        CHAR(01),
         g_modulo               CHAR(04),
         m_nom_help      CHAR(200),
         g_ies_grafico          SMALLINT,
         g_erro                 SMALLINT, # Variável utilizada no mcx0809
         g_control_e            SMALLINT, # Variável utilizada no 
         g_docum_baixado        SMALLINT, # Variável utilizada no 
         g_val_docum            LIKE mcx_movto.val_docum,
         g_operacao             LIKE mcx_movto.operacao

  DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

# MODULARES
  DEFINE ma_dados     ARRAY[9999] OF RECORD
                        caixa            LIKE mcx_caixa.caixa,
                        des_caixa        LIKE mcx_caixa.des_caixa,
                        dat_movto        LIKE mcx_movto.dat_movto,
                        tip_operacao     LIKE mcx_operacao_caixa.tip_operacao,
                        operacao         LIKE mcx_operacao_caixa.operacao,
                        des_operacao     LIKE mcx_operacao_caixa.des_operacao,
                        docum            LIKE mcx_movto.docum,
                        val_docum        LIKE mcx_movto.val_docum,
                        hist_movto       LIKE mcx_movto.hist_movto,
                        sequencia_caixa  LIKE mcx_movto.sequencia_caixa,
                        centro_custo     LIKE cad_cc.cod_cent_cust,
                        cod_titulo       CHAR(14),
                        cod_cliente      CHAR(15),
                        tip_docum        LIKE docum.ies_tip_docum 
                     END RECORD
 
  DEFINE m_den_empresa          LIKE empresa.den_empresa,
         m_caminho              CHAR(150),
         m_nom_tela             CHAR(200),
         #m_nom_help             CHAR(200),
         m_comando              CHAR(080),
         where_clause           CHAR(500),
         sql_stmt               CHAR(1500),
         m_consulta_ativa       SMALLINT,
         m_arr_curr             SMALLINT,
         m_scr_lin              SMALLINT,
         m_tot_reg              SMALLINT,
         m_entrou               SMALLINT,
         m_num_seq              SMALLINT,
         m_control_e            SMALLINT,
         m_baixa_ap             SMALLINT,
         m_abre_aen             LIKE par_con.ies_contab_aen,
         m_linha_produto        LIKE mcx_aen_4.linha_produto,
         m_linha_receita        LIKE mcx_aen_4.linha_receita,
         m_segmto_mercado       LIKE mcx_aen_4.segmto_mercado,
         m_classe_uso           LIKE mcx_aen_4.classe_uso,
         m_mcx_movto            RECORD LIKE mcx_movto.*,
         m_tip_contab_conta     LIKE mcx_operacao_caixa.tip_contab_conta,
         m_tip_contab_cc        LIKE mcx_operacao_caixa.tip_contab_cc,
         m_val_aen              LIKE mcx_movto.val_docum,
         m_dat_movto            LIKE mcx_movto.dat_movto,
         m_seq_dig              LIKE mcx_movto.sequencia_caixa,
         m_docum_ant            LIKE mcx_movto.docum,
         m_empresa              LIKE empresa.cod_empresa,
         m_cod_empresa          LIKE empresa.cod_empresa,
         m_num_ap               LIKE ap.num_ap,
         m_cancel               INTEGER,
         m_data_corte           DATE,
         m_formula_hist_compl   CHAR(100),
         m_cod_titulo           CHAR(14)

  DEFINE mr_tela     RECORD
                        caixa         LIKE mcx_caixa.caixa,
                        des_caixa     LIKE mcx_caixa.des_caixa,
                        dat_movto     LIKE mcx_movto.dat_movto
                     END RECORD

  DEFINE mr_telar    RECORD
                        caixa         LIKE mcx_caixa.caixa,
                        des_caixa     LIKE mcx_caixa.des_caixa,
                        dat_movto     LIKE mcx_movto.dat_movto
                     END RECORD

  DEFINE ma_tela     ARRAY[9999] OF RECORD
                        tip_operacao     LIKE mcx_operacao_caixa.tip_operacao,
                        operacao         LIKE mcx_operacao_caixa.operacao,
                        des_operacao     LIKE mcx_operacao_caixa.des_operacao,
                        docum            LIKE mcx_movto.docum,
                        val_docum        LIKE mcx_movto.val_docum,
                        hist_movto       LIKE mcx_movto.hist_movto,
                        sequencia_caixa  LIKE mcx_movto.sequencia_caixa
                     END RECORD

  DEFINE mr_tela_b   RECORD
                        tip_operacao     LIKE mcx_operacao_caixa.tip_operacao,
                        operacao         LIKE mcx_operacao_caixa.operacao,
                        des_operacao     LIKE mcx_operacao_caixa.des_operacao,
                        docum            LIKE mcx_movto.docum,
                        val_docum        LIKE mcx_movto.val_docum,
                        hist_movto       LIKE mcx_movto.hist_movto,
                        sequencia_caixa  LIKE mcx_movto.sequencia_caixa
                     END RECORD

 DEFINE ma_relat     ARRAY[200] OF RECORD
                        qtd_informacao SMALLINT,
                        num_conta_cont LIKE mcx_lancto_contab.conta_contab,
                        tip_lancto     LIKE mcx_lancto_contab.tip_lancto,
                        linha_produto  LIKE mcx_aen_4.linha_produto,
                        linha_receita  LIKE mcx_aen_4.linha_receita,
                        segmto_mercado LIKE mcx_aen_4.segmto_mercado,
                        classe_uso     LIKE mcx_aen_4.classe_uso
                     END RECORD

 DEFINE m_valida_dt_dt_proc_che_mcx CHAR(01) #OS 513834
 DEFINE ma_aen_automatica  ARRAY[9999] OF CHAR(01)
# END MODULARES


#-------------------------------------#
 FUNCTION geo1018_verifica_parametro()
#-------------------------------------#
 DEFINE l_status SMALLINT #OS 513834

 WHENEVER ERROR CONTINUE
  SELECT ies_contab_aen
    INTO m_abre_aen
    FROM par_con
   WHERE cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP
 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECAO","par_con")
 END IF

#OS 513834
 CALL log2250_busca_parametro(p_cod_empresa,"valida_dt_proc_che_mcx")
      RETURNING m_valida_dt_dt_proc_che_mcx, l_status
 IF NOT l_status OR
        m_valida_dt_dt_proc_che_mcx IS NULL THEN
    LET m_valida_dt_dt_proc_che_mcx = "N"
 END IF
#----------


 END FUNCTION

#--------------------------#
 FUNCTION geo1018_controle(la_dados)
#--------------------------#
 DEFINE la_dados     ARRAY[9999] OF RECORD
                        caixa            LIKE mcx_caixa.caixa,
                        des_caixa        LIKE mcx_caixa.des_caixa,
                        dat_movto        LIKE mcx_movto.dat_movto,
                        tip_operacao     LIKE mcx_operacao_caixa.tip_operacao,
                        operacao         LIKE mcx_operacao_caixa.operacao,
                        des_operacao     LIKE mcx_operacao_caixa.des_operacao,
                        docum            LIKE mcx_movto.docum,
                        val_docum        LIKE mcx_movto.val_docum,
                        hist_movto       LIKE mcx_movto.hist_movto,
                        sequencia_caixa  LIKE mcx_movto.sequencia_caixa,
                        centro_custo     LIKE cad_cc.cod_cent_cust,
                        cod_titulo       CHAR(14),
                        cod_cliente      CHAR(15),
                        tip_docum        LIKE docum.ies_tip_docum
                     END RECORD
 
 LET ma_dados = la_dados
 CALL geo1018_inicializa()

 #CALL log006_exibe_teclas("01 02", p_versao)
 CALL geo1018_verifica_parametro()

 LET m_consulta_ativa = FALSE
 CALL log130_procura_caminho("geo1018") RETURNING m_nom_tela
 IF conm57_ctb_dat_contab_logix_10_leitura(p_cod_empresa,0,1) THEN
     LET m_data_corte = conm57_ctb_dat_contab_logix_10_get_data_contabilizacao()
 ELSE
     LET m_data_corte =  NULL
 END IF
 
 ### JA ENTRA DIRETO NA INCLUSAO
 CALL geo1018_inicializa()
 CALL geo1018_inclusao()
 
 {OPEN WINDOW w_geo1018 AT 2,2 WITH FORM m_nom_tela
    ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 DISPLAY p_cod_empresa TO empresa

 # busca a data de corte para a empresa selecionada no cursor

 MENU "OPÇÃO"
   COMMAND "Incluir"    "Inclui registro na movimentação de caixa."
       HELP 001
       MESSAGE ""
       LET int_flag = 0
       IF log005_seguranca(p_user,"MCX","geo1018","IN") THEN
          CALL geo1018_inicializa()
          CLEAR FORM
          DISPLAY p_cod_empresa TO empresa
          CALL geo1018_inclusao()
       END IF

   COMMAND "Consultar"  "Consulta registros da movimentação de caixa."
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF log005_seguranca(p_user,"MCX","geo1018","CO") THEN
          CALL geo1018_consulta()
       END IF

   COMMAND "Modificar"  "Modifica registro na movimentação de caixa."
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF m_consulta_ativa THEN
          IF log005_seguranca(p_user,"MCX","geo1018","MO") THEN
             IF geo1018_verifica_saldo() THEN
#OS 513834
                IF m_valida_dt_dt_proc_che_mcx = "S" AND NOT geo1018_valida_dt_proc_che_mcx() THEN
                   CALL log0030_mensagem("Data do movimento difere da data de processamento do CHE","info")
                ELSE
                   CALL geo1018_modificacao()
                END IF
#---------
             ELSE
                CALL log0030_mensagem("Caixa não pode ser modificado pois já está FECHADO.","info")
             END IF
          END IF
       ELSE
          CALL log0030_mensagem("Consulte previamente para fazer a modificação. ","info")
       END IF

   COMMAND "Listar"      "Emite relatório dos movimentos."
       HELP 007
       MESSAGE ""
       IF log005_seguranca(p_user, "MCX", "geo1018", "CO") THEN
          IF m_consulta_ativa THEN
             IF log0280_saida_relat(19,17) IS NOT NULL THEN
                CALL geo1018_lista()
             END IF
          ELSE
             CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
          END IF
       END IF

   COMMAND KEY ("!")
       PROMPT "Digite o comando : " FOR p_comando
       RUN p_comando
       PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando

   COMMAND "Fim"        "Retorna ao menu anterior."
       HELP 008
       EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

 END MENU

 CLOSE WINDOW w_geo1018}

END FUNCTION

#------------------------------#
 FUNCTION geo1018_inicializa()
#------------------------------#
 INITIALIZE mr_tela.*, mr_telar.*, ma_tela TO NULL
 INITIALIZE m_nom_tela  TO NULL

 END FUNCTION

#----------------------------------------#
 FUNCTION geo1018_entrada_dados(l_funcao)
#----------------------------------------#
 DEFINE l_funcao            CHAR(15),
        l_sequencia_caixa   LIKE mcx_movto.sequencia_caixa

 #CALL log006_exibe_teclas("01 02 03 07", p_versao)
 #CURRENT WINDOW IS w_geo1018

 LET INT_FLAG = FALSE
 
 LET mr_tela.caixa     = ma_dados[1].caixa
 
 IF NOT geo1018_verifica_caixa() THEN
    CALL log0030_mensagem("Caixa não cadastrado.","info")
    #NEXT FIELD caixa
 END IF
 
 LET mr_tela.dat_movto = ma_dados[1].dat_movto 
 
 IF mr_tela.dat_movto IS NOT NULL THEN
    IF geo1018_verifica_saldo_fechado() THEN
       #NEXT FIELD dat_movto
    END IF

    IF m_data_corte IS NOT NULL THEN
       IF mr_tela.dat_movto >= m_data_corte THEN
          IF con2900_valida_periodo_sistema(p_cod_empresa, "MCX", mr_tela.dat_movto) = FALSE THEN
             #NEXT FIELD dat_movto
          END IF
       END IF
    END IF
 ELSE
    CALL log0030_mensagem("Data do movimento deve ser informada.","info")
    #NEXT FIELD dat_movto
 END IF

#OS 513834
 IF m_valida_dt_dt_proc_che_mcx = "S" AND NOT geo1018_valida_dt_proc_che_mcx() THEN
    CALL log0030_mensagem("Data do movimento difere da data de processamento do CHE","info")
    LET mr_tela.dat_movto = geo1018_busca_dt_proc_che_mcx()
    #DISPLAY BY NAME mr_tela.dat_movto
    #NEXT FIELD dat_movto
 END IF

 
 IF NOT geo1018_verifica_programa_em_uso() THEN
    CALL geo1018_trava_registro()
    IF NOT geo1018_input_array(l_funcao) THEN
       LET int_flag = FALSE
       RETURN FALSE
    END IF
 END IF
 
 RETURN TRUE

 END FUNCTION

#--------------------------------------------#
 FUNCTION geo1018_verifica_programa_em_uso()
#--------------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT cod_empresa
    FROM tran_arg
   WHERE cod_empresa   = p_cod_empresa
     AND num_programa  = "geo1018"
     AND data_proc     = mr_tela.dat_movto
     AND num_arg       = mr_tela.caixa
     AND indice_arg    = 1
   GROUP BY cod_empresa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
#    CALL log0030_mensagem("Registro sendo atualizado por outro usuário. Aguarde e tente novamente. ","info")
#    RETURN TRUE
 END IF

 RETURN FALSE

 END FUNCTION

#----------------------------------#
 FUNCTION geo1018_trava_registro()
#----------------------------------#
 DEFINE l_time  DATETIME HOUR TO SECOND

 LET l_time = TIME

 WHENEVER ERROR CONTINUE
  INSERT INTO tran_arg VALUES (p_cod_empresa, "geo1018", p_user,
                               mr_tela.dat_movto, l_time, mr_tela.caixa,
                               1, NULL, NULL, NULL, NULL, NULL)
 WHENEVER ERROR STOP

 END FUNCTION

#-----------------------------------#
 FUNCTION geo1018_libera_registro()
#-----------------------------------#
 WHENEVER ERROR CONTINUE
  DELETE FROM tran_arg
   WHERE cod_empresa   = p_cod_empresa
     AND num_programa  = "geo1018"
     AND login_usuario = p_user
     AND data_proc     = mr_tela.dat_movto
     AND num_arg       = mr_tela.caixa
     AND indice_arg    = 1
 WHENEVER ERROR STOP
 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","tran_arg")
 END IF

 END FUNCTION

#--------------------------------------#
 FUNCTION geo1018_input_array(l_funcao)
#--------------------------------------#
 DEFINE l_funcao            CHAR(15),
        l_status            SMALLINT,
        l_erro              SMALLINT,
        l_erro_inclusao     SMALLINT,
        l_cont              SMALLINT,
        l_mesmo_docum_oper  SMALLINT,
        l_sequencia_caixa   LIKE mcx_movto.sequencia_caixa,
        l_operacao_ant      LIKE mcx_movto.operacao,
        l_hist_ant          LIKE mcx_movto.hist_movto,
        l_ind               SMALLINT

 #CALL log006_exibe_teclas("01 02 03 07 17 18 86 87", p_versao)
 #CURRENT WINDOW IS w_geo1018
 
 LET m_tot_reg = 0
 FOR l_ind = 1 TO 9999
    
    IF ma_dados[l_ind].operacao IS NULL OR ma_dados[l_ind].operacao = "" THEN
       EXIT FOR
    END IF 
    
    LET m_arr_curr = l_ind
    
    LET INT_FLAG = FALSE
    LET m_control_e  = FALSE
    LET l_mesmo_docum_oper = FALSE

    CALL geo1018_busca_sequencia() RETURNING l_sequencia_caixa

    INITIALIZE m_mcx_movto.* TO NULL

    #CALL SET_COUNT(m_tot_reg)
 
             
   
   #BEFORE FIELD operacao   
    IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
       IF m_mcx_movto.docum IS NULL OR m_mcx_movto.docum <> "X" THEN
          IF l_erro THEN
             LET l_operacao_ant = NULL
          ELSE
             LET l_operacao_ant = ma_tela[m_arr_curr].operacao
          END IF
       ELSE
          LET l_operacao_ant = NULL
       END IF
    ELSE
       LET l_operacao_ant = NULL
    END IF
   
         
   LET ma_tela[l_ind].operacao = ma_dados[l_ind].operacao
      
   #AFTER FIELD operacao
    IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
       IF ma_tela[m_arr_curr].sequencia_caixa IS NULL THEN
          LET ma_tela[m_arr_curr].sequencia_caixa = 0
          IF l_sequencia_caixa IS NULL OR l_sequencia_caixa = 0 THEN
             LET ma_tela[m_arr_curr].sequencia_caixa = m_arr_curr
          ELSE
             LET ma_tela[m_arr_curr].sequencia_caixa = l_sequencia_caixa + 1
          END IF
          LET l_sequencia_caixa = l_sequencia_caixa + 1
       END IF
       IF l_operacao_ant IS NOT NULL AND NOT m_control_e AND
          l_operacao_ant <> ma_tela[m_arr_curr].operacao THEN
           ERROR "Uma vez já informada, a operação não pode mais ser alterada."
           LET ma_tela[m_arr_curr].operacao = l_operacao_ant
   #        DISPLAY ma_tela[m_arr_curr].operacao TO s_movtos[m_scr_lin].operacao
    #       NEXT FIELD operacao
       END IF
            
       IF NOT geo1018_verifica_operacao() THEN
          ERROR "Operação não cadastrada."
          LET l_erro = TRUE
   #       NEXT FIELD operacao
       END IF
       CALL geo1018_verifica_tip_operacao()
   
       IF geo1018_oper_estorno() THEN
          IF ma_tela[m_arr_curr].docum IS NULL THEN
             CALL mcx0302_estorno(mr_tela.caixa,
                                  mr_tela.dat_movto,
                                  ma_tela[m_arr_curr].tip_operacao)
                  RETURNING m_mcx_movto.*
   
             CALL geo1018_carrega_mcx_movto(3)
             # Neste momento carrego a variável g_operacao
             #CALL log006_exibe_teclas("01", p_versao)
   #          CURRENT WINDOW IS w_geo1018
             IF m_mcx_movto.empresa IS NULL THEN
   #            NEXT FIELD operacao
             END IF
          ELSE
             #NEXT FIELD sequencia_caixa
          END IF
       END IF
   
       IF g_operacao IS NULL THEN
         # Fazer esta lógica pois como as tabelas do mcx tem chave estrangeira,
         # primeiro tenho que incluir na tabela pai (mcx_movto) para depois inserir
         # nas tabelas filhas.
         IF l_funcao = "INCLUSAO" THEN
            # Se o usuário deu control-c em alguma função.
            IF m_mcx_movto.docum = "X" THEN
               CALL geo1018_elimina_dados() RETURNING p_status
            END IF
            IF NOT geo1018_verifica_movto() THEN
               IF NOT geo1018_insere_movto(1) THEN
   #               EXIT INPUT
               END IF
            ELSE
               # Fazer o delete da mcx_movto pois o usuário pode ter digitado
               # uma operação que baixa cre, por exemplo, e no meio da baixa ter
               # dado control-c e informar outra operação que faça um processo
               # totalmente diferente.
               IF INT_FLAG THEN
                  CALL geo1018_elimina_dados() RETURNING p_status
               END IF
               IF NOT geo1018_insere_movto(1) THEN
   #               EXIT INPUT
               END IF
            END IF
         END IF
   
         CALL geo1018_busca_parametros(ma_tela[m_arr_curr].tip_operacao)
   
         # Carregar a variavel m_mcx_movto para o  poder utilizar
         CALL geo1018_carrega_mcx_movto(1)
   
         CALL geo1021_gera_integracao(m_mcx_movto.*,"mcx0007",ma_dados[l_ind].cod_titulo, ma_dados[l_ind].cod_cliente, ma_dados[l_ind].tip_docum)
              RETURNING m_mcx_movto.*, m_baixa_ap, m_cod_empresa, m_num_ap
   
   #      CALL log006_exibe_teclas("01", p_versao)
   #      CURRENT WINDOW IS w_geo1018
          LET INT_FLAG = FALSE
   
          # Verificação se o usuário deu control-c em alguma função chamada pelo 
          IF m_mcx_movto.docum = "X" THEN
             IF l_funcao = "INCLUSAO" THEN
                LET ma_tela[m_arr_curr].docum = NULL
   #             DISPLAY ma_tela[m_arr_curr].docum TO s_movtos[m_scr_lin].docum
   #             NEXT FIELD operacao
             END IF
          ELSE
             IF g_modulo = "CRE1" THEN
                IF NOT g_docum_baixado THEN
                   LET ma_tela[m_arr_curr].docum = NULL
   #                DISPLAY ma_tela[m_arr_curr].docum TO s_movtos[m_scr_lin].docum
                   ERROR "Não foi realizada a baixa do documento selecionado."
   #                NEXT FIELD operacao
                END IF
             END IF
             # Atualizar os campos DOCUM e VAL_DOCUM do array, depois que o  processou.
             CALL geo1018_carrega_mcx_movto(2)
          END IF
       ELSE
             {No caso de uma operação de estorno, fazer a inclusão do movimento
	          antes. }
          IF NOT INT_FLAG THEN
             IF NOT geo1018_atualiza_movimento() THEN
                CALL log085_transacao("ROLLBACK")
   #             EXIT INPUT
             END IF
          END IF
   
          # Se a operação for de estorno, inserir dados mcx_lancto_contab e
          # mcx_aen_4 da operacao escolhida.
          IF NOT geo1018_insere_dados_estorno() THEN
   #          NEXT FIELD operacao
          END IF
          IF NOT geo1018_grava_estorno() THEN
   #          NEXT FIELD operacao
          END IF
   #       NEXT FIELD sequencia_caixa
       END IF
   
       IF ma_tela[m_arr_curr].docum IS NOT NULL THEN
          IF ma_tela[m_arr_curr].docum IS NOT NULL AND
             ma_tela[m_arr_curr].val_docum IS NOT NULL THEN
             IF l_funcao = "INCLUSAO" THEN
                #Operação que não gera nenhuma integração.
                IF g_modulo <> "MCX" THEN
   #                 NEXT FIELD hist_movto
                ELSE
   #                 NEXT FIELD docum
                END IF
             END IF
          END IF
          IF ma_tela[m_arr_curr].docum IS NOT NULL AND
             ma_tela[m_arr_curr].val_docum IS NULL THEN
             IF NOT l_mesmo_docum_oper THEN
   #             NEXT FIELD val_docum
             END IF
          END IF
       END IF
    ELSE
       LET ma_tela[m_arr_curr].des_operacao = NULL
    END IF
            
   
   #BEFORE FIELD docum
    IF ma_tela[m_arr_curr].docum IS NOT NULL THEN
       IF l_erro THEN
          LET m_docum_ant = NULL
       ELSE
          LET m_docum_ant = ma_tela[m_arr_curr].docum
       END IF
    ELSE
       LET m_docum_ant = NULL
    END IF
    IF geo1018_oper_estorno() THEN
    #   NEXT FIELD sequencia_caixa
    END IF
    
    
    LET ma_tela[l_ind].docum = ma_dados[l_ind].docum
    
   
   #AFTER FIELD docum
    IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
       IF ma_tela[m_arr_curr].docum IS NOT NULL THEN
          # O usuário pode alterar o número do documento caso a operação não gere
          # integração com nenhum módulo.
   
          CALL geo1018_carrega_mcx_movto(1)
          CALL geo1021_gera_integracao(m_mcx_movto.*,"mcx0007",ma_dados[l_ind].cod_titulo, ma_dados[l_ind].cod_cliente, ma_dados[l_ind].tip_docum)
               RETURNING m_mcx_movto.*,   m_baixa_ap, m_cod_empresa, m_num_ap
          #CALL log006_exibe_teclas("01", p_versao)
   #       CURRENT WINDOW IS w_geo1018
          LET INT_FLAG = FALSE
   
          IF g_modulo <> "MCX" THEN
             IF m_docum_ant IS NOT NULL AND
                m_docum_ant <> ma_tela[m_arr_curr].docum THEN
                 ERROR "Uma vez já informado, o documento não pode mais ser alterado."
                 LET ma_tela[m_arr_curr].docum = m_docum_ant
   #              DISPLAY ma_tela[m_arr_curr].docum TO s_movtos[m_scr_lin].docum
   #              NEXT FIELD val_docum
             END IF
          END IF
       ELSE
          ERROR "Documento deve ser informado."
   #       NEXT FIELD docum
       END IF
    ELSE
       IF ma_tela[m_arr_curr].operacao  IS NULL AND
          ma_tela[m_arr_curr].docum IS NOT NULL THEN
          ERROR "Operação deve ser informada."
    #     NEXT FIELD operacao
       END IF
    END IF
   
   #BEFORE FIELD val_docum
    LET m_val_aen = ma_tela[m_arr_curr].val_docum
    IF geo1018_oper_estorno() THEN
    #   NEXT FIELD sequencia_caixa
    END IF
    
    
    LET ma_tela[l_ind].val_docum = ma_dados[l_ind].val_docum
    
   
   #AFTER FIELD val_docum
    IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
       IF m_val_aen IS NOT NULL THEN
          IF m_val_aen <> ma_tela[m_arr_curr].val_docum THEN
             IF g_modulo = "CAP1" THEN
                ERROR "Valor do documento não pode ser alterado pois este documento foi baixado no CAP."
                LET ma_tela[m_arr_curr].val_docum = m_val_aen
                #DISPLAY ma_tela[m_arr_curr].val_docum TO s_movtos[m_scr_lin].val_docum
                #NEXT FIELD hist_movto
             END IF
             IF g_modulo = "CRE1" THEN
                ERROR "Valor do documento não pode ser alterado pois este documento foi baixado no CRE."
                LET ma_tela[m_arr_curr].val_docum = m_val_aen
                #DISPLAY ma_tela[m_arr_curr].val_docum TO s_movtos[m_scr_lin].val_docum
                #NEXT FIELD hist_movto
             END IF
             IF m_abre_aen <> "N" AND m_abre_aen IS NOT NULL THEN
                #Abrir o AEN e os lançamentos pois o valor do array mudou.
                CALL mcx0802_area_linha(mr_tela.caixa, mr_tela.dat_movto,
                                        ma_tela[m_arr_curr].operacao,
                                        ma_tela[m_arr_curr].tip_operacao,
                                        ma_tela[m_arr_curr].docum,
                                        ma_tela[m_arr_curr].val_docum,
                                        ma_tela[m_arr_curr].sequencia_caixa,
                                        m_linha_produto, m_linha_receita,
                                        m_segmto_mercado, m_classe_uso, 0)
                     RETURNING l_status

                #CALL log006_exibe_teclas("01 02", p_versao)
                IF NOT l_status THEN
                   #EXIT INPUT
                   EXIT FOR
                END IF
             END IF
        
             CALL geo1019_lanc_cont(mr_tela.caixa, mr_tela.dat_movto,
                                    ma_tela[m_arr_curr].operacao,
                                    ma_tela[m_arr_curr].tip_operacao,
                                    ma_tela[m_arr_curr].docum,
                                    ma_tela[m_arr_curr].val_docum,
                                    ma_tela[m_arr_curr].hist_movto,
                                    ma_tela[m_arr_curr].sequencia_caixa,
                                    ma_dados[l_ind].centro_custo)
                RETURNING l_status
#              CURRENT WINDOW IS w_geo1018
              #CALL log006_exibe_teclas("01 02", p_versao)
              IF NOT l_status THEN
                     #EXIT INPUT
                     EXIT FOR
              END IF
          END IF
          CALL geo1018_verifica_pendencia("MODIFICACAO", m_arr_curr)
              RETURNING l_status
       END IF
    ELSE
       IF ma_tela[m_arr_curr].operacao  IS NULL AND
          ma_tela[m_arr_curr].val_docum IS NOT NULL THEN
           ERROR "Operação deve ser informada."
           #NEXT FIELD operacao
       END IF
    END IF

   #BEFORE FIELD hist_movto
    LET l_hist_ant = ma_tela[m_arr_curr].hist_movto
    IF geo1018_oper_estorno() THEN
    END IF
   
    IF ma_tela[m_arr_curr].operacao IS NULL THEN
       CALL log0030_mensagem("Operação não preenchida.","excl")
    END IF

    IF geo1018_mcx_hist_contabil_existe() THEN
       IF ma_tela[m_arr_curr].hist_movto IS NULL OR
          ma_tela[m_arr_curr].hist_movto = " "   THEN
          LET ma_tela[m_arr_curr].hist_movto = geo1018_ext_hist()
       END IF
    END IF
    
    
    LET ma_tela[l_ind].hist_movto = ma_dados[l_ind].hist_movto
    
   
   #AFTER FIELD
    IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
       IF  ma_tela[m_arr_curr].operacao IS NOT NULL
       AND ma_tela[m_arr_curr].hist_movto IS NULL THEN
           ERROR "Histórico do movimento deve ser informado."
       END IF
 
       CALL geo1018_verifica_contab()
       IF m_tip_contab_conta = "M" OR m_tip_contab_cc = "M" THEN
          IF ma_tela[m_arr_curr].val_docum IS NOT NULL THEN
          
             CALL geo1019_lanc_cont(mr_tela.caixa, mr_tela.dat_movto,
                                    ma_tela[m_arr_curr].operacao,
                                    ma_tela[m_arr_curr].tip_operacao,
                                    ma_tela[m_arr_curr].docum,
                                    ma_tela[m_arr_curr].val_docum,
                                    ma_tela[m_arr_curr].hist_movto,
                                    ma_tela[m_arr_curr].sequencia_caixa,
                                    ma_dados[l_ind].centro_custo)
                 RETURNING l_status
          
             IF NOT l_status THEN
                #EXIT INPUT
                EXIT FOR
             END IF
          END IF
       END IF
       #--inicio--OS  395807 #
       IF ma_aen_automatica[m_arr_curr] = "M" THEN
          #  Abrir o AEN e os lançamentos pois o cadastrado da
          #  tabela mcx_operacao_caixa está como manual(aen_automatica = "M") O.S 395807
          CALL mcx0802_area_linha(mr_tela.caixa, mr_tela.dat_movto,
                                  ma_tela[m_arr_curr].operacao,
                                  ma_tela[m_arr_curr].tip_operacao,
                                  ma_tela[m_arr_curr].docum,
                                  ma_tela[m_arr_curr].val_docum,
                                  ma_tela[m_arr_curr].sequencia_caixa,
                                  m_linha_produto, m_linha_receita,
                                  m_segmto_mercado, m_classe_uso, 0)
               RETURNING l_status

          #CALL log006_exibe_teclas("01 02", p_versao)
          IF NOT l_status THEN
             #EXIT INPUT
             EXIT FOR
          END IF
       END IF
       #---fim----OS 395807  #
    ELSE
       IF  ma_tela[m_arr_curr].operacao IS NULL
       AND ma_tela[m_arr_curr].hist_movto IS NOT NULL THEN
           ERROR "Operação deve ser informada."
       END IF
    END IF

   #AFTER INPUT
    IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
       IF NOT geo1018_verifica_operacao() THEN
          ERROR "Operação não cadastrada."
       END IF
       CALL geo1018_verifica_tip_operacao()
    END IF

    IF ma_tela[m_arr_curr].operacao IS NULL AND
       ma_tela[m_arr_curr].docum IS NOT NULL THEN
       ERROR "Operação deve ser informada."
    END IF

    IF ma_tela[m_arr_curr].operacao IS NOT NULL AND
       ma_tela[m_arr_curr].docum IS NULL THEN
       ERROR "Documento deve ser informado."
    END IF

    IF ma_tela[m_arr_curr].operacao IS NULL AND
       ma_tela[m_arr_curr].val_docum IS NOT NULL THEN
       ERROR "Operação deve ser informada."
    END IF

    IF ma_tela[m_arr_curr].operacao IS NOT NULL AND
       ma_tela[m_arr_curr].val_docum IS NULL THEN
       ERROR "Valor do documento deve ser informado."
    END IF

    IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
       IF ma_tela[m_arr_curr].sequencia_caixa IS NULL THEN
          LET ma_tela[m_arr_curr].sequencia_caixa = 0
          IF l_sequencia_caixa IS NULL OR l_sequencia_caixa = 0 THEN
             LET ma_tela[m_arr_curr].sequencia_caixa = m_arr_curr
          ELSE
             LET ma_tela[m_arr_curr].sequencia_caixa = l_sequencia_caixa + 1
          END IF
          #DISPLAY ma_tela[m_arr_curr].sequencia_caixa TO s_movtos[m_scr_lin].sequencia_caixa
       END IF
    END IF
    IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
       IF ma_tela[m_arr_curr].hist_movto IS NULL THEN
          ERROR "Histórico do movimento deve ser informado."
       END IF
    END IF
    #IF NOT log004_confirm(10,20) THEN
       #NEXT FIELD operacao
    #END IF
    #Este programa efetiva a cada linha (dá um commit a cada input)
    IF NOT INT_FLAG THEN
       IF NOT geo1018_atualiza_movimento() THEN
          CALL log085_transacao("ROLLBACK")
          #EXIT INPUT
          EXIT FOR
       END IF
    END IF
    
    #AFTER ROW
    IF NOT geo1018_atualiza_movimento() THEN
       CALL log085_transacao("ROLLBACK")
       LET l_erro_inclusao = TRUE
       #EXIT INPUT
       EXIT FOR
    END IF
   
    CALL log085_transacao("COMMIT")
    IF m_baixa_ap = TRUE THEN
       CALL log120_procura_caminho("cap0890") RETURNING m_caminho
       LET m_caminho = m_caminho CLIPPED, " geo1018",   " ",
                                          "N",          " ",
                                           m_mcx_movto.dat_movto, " ", # 753290
                                           m_mcx_movto.dat_movto, " ", # 753290
                                           m_cod_empresa," ",
                                           m_num_ap  CLIPPED
        RUN m_caminho RETURNING m_cancel
        LET m_baixa_ap = FALSE
        INITIALIZE m_num_ap TO NULL
    END IF
    
    LET m_tot_reg = m_tot_reg + 1
 END FOR
 
 
 
 IF l_erro_inclusao THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#--------------------------------------#
 FUNCTION geo1018_atualiza_movimento()
#--------------------------------------#
 IF NOT geo1018_verifica_movto() THEN
    IF NOT geo1018_insere_movto(2) THEN
       RETURN FALSE
    END IF
 ELSE
    IF NOT geo1018_atualiza_movto() THEN
       RETURN FALSE
    END IF
 END IF
 IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
    IF g_operacao IS NULL THEN
       IF NOT geo1018_aen_lanc() THEN
          RETURN FALSE
       END IF
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#-------------------------------------#
 FUNCTION geo1018_insere_movto(l_ind)
#-------------------------------------#
 DEFINE l_where_clause        CHAR(250),
        l_ind                 SMALLINT,
        l_docum               LIKE mcx_movto.docum,
        l_val_docum           LIKE mcx_movto.val_docum,
        l_hist_movto          LIKE mcx_movto.hist_movto,
        l_status              SMALLINT,
        l_message             CHAR(80)

 IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
    WHENEVER ERROR CONTINUE
    SELECT empresa
      FROM mcx_movto
     WHERE empresa         = p_cod_empresa
       AND caixa           = mr_tela.caixa
       AND dat_movto       = mr_tela.dat_movto
       AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode = NOTFOUND THEN
       IF l_ind = 1 THEN
          LET l_docum      = "X"
          LET l_val_docum  = 0
          LET l_hist_movto = NULL
       ELSE
          LET l_docum      = ma_tela[m_arr_curr].docum
          LET l_val_docum  = ma_tela[m_arr_curr].val_docum
          LET l_hist_movto = ma_tela[m_arr_curr].hist_movto
       END IF

       WHENEVER ERROR CONTINUE
       INSERT INTO mcx_movto VALUES (p_cod_empresa,
                                     mr_tela.caixa,
                                     mr_tela.dat_movto,
                                     ma_tela[m_arr_curr].operacao,
                                     ma_tela[m_arr_curr].tip_operacao,
                                     l_docum,
                                     l_val_docum,
                                     l_hist_movto,
                                     ma_tela[m_arr_curr].sequencia_caixa)
       WHENEVER ERROR STOP

       IF SQLCA.SQLCODE <> 0 THEN
          CALL log003_err_sql("INCLUSAO","MCX_MOVTO")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF

       CALL fcl1260_integracao_mcx_fcx(p_cod_empresa,
                                       mr_tela.caixa,
                                       ma_tela[m_arr_curr].sequencia_caixa,
                                       mr_tela.dat_movto,
                                       "IN")
                             RETURNING l_status,
                                       l_message
       IF NOT l_status THEN
          CALL log0030_mensagem(l_message,"info")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF


       IF NOT geo1018_verifica_pendencia("INCLUSAO", m_arr_curr) THEN
          CALL log003_err_sql("UPDATE","MCX_PENDENCIA")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF

       IF NOT mcx0812_geracao_auditoria(p_cod_empresa,
                                        'mcx_movto',
                                        'I',
                                        ma_tela[m_arr_curr].tip_operacao,
                                        mr_tela.caixa,
                                        ma_tela[m_arr_curr].sequencia_caixa,
                                        mr_tela.dat_movto,
                                        l_val_docum,
                                        'geo1018') THEN
          CALL log085_transacao("ROLLBACK")
          CALL log003_err_sql('INSERT','mcx_auditoria')
          RETURN FALSE
       END IF
    ELSE
       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("SELECT","MCX_MOVTO")
       END IF
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#----------------------------------#
 FUNCTION geo1018_atualiza_movto()
#----------------------------------#
 DEFINE l_where_clause   CHAR(250),
        l_status         SMALLINT,
        l_message        CHAR(80)

 IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN

    CALL fcl1260_integracao_mcx_fcx(p_cod_empresa,
                                    mr_tela.caixa,
                                    ma_tela[m_arr_curr].sequencia_caixa,
                                    mr_tela.dat_movto,
                                    "EX")
                          RETURNING l_status,
                                    l_message
    IF NOT l_status THEN
       CALL log0030_mensagem(l_message,"info")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF

    WHENEVER ERROR CONTINUE
    UPDATE mcx_movto
       SET docum      = ma_tela[m_arr_curr].docum,
           val_docum  = ma_tela[m_arr_curr].val_docum,
           hist_movto = ma_tela[m_arr_curr].hist_movto
     WHERE empresa    = p_cod_empresa
       AND caixa      = mr_tela.caixa
       AND dat_movto  = mr_tela.dat_movto
       AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
    WHENEVER ERROR STOP

    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql("UPDATE","MCX_MOVTO")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF

    CALL fcl1260_integracao_mcx_fcx(p_cod_empresa,
                                    mr_tela.caixa,
                                    ma_tela[m_arr_curr].sequencia_caixa,
                                    mr_tela.dat_movto,
                                    "IN")
                          RETURNING l_status,
                                    l_message
    IF NOT l_status THEN
       CALL log0030_mensagem(l_message,"info")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF

    IF NOT mcx0812_geracao_auditoria(p_cod_empresa,
                                     'mcx_movto',
                                     'M',
                                     ma_tela[m_arr_curr].tip_operacao,
                                     mr_tela.caixa,
                                     ma_tela[m_arr_curr].sequencia_caixa,
                                     mr_tela.dat_movto,
                                     ma_tela[m_arr_curr].val_docum,
                                     'geo1018') THEN
       CALL log085_transacao("ROLLBACK")
       CALL log003_err_sql('INSERT','mcx_auditoria')
       RETURN FALSE
    END IF

    IF NOT geo1018_verifica_pendencia("MODIFICACAO", m_arr_curr) THEN
       CALL log003_err_sql("UPDATE","MCX_PENDENCIA")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#----------------------------------#
 FUNCTION geo1018_verifica_movto()
#----------------------------------#

 WHENEVER ERROR CONTINUE
  SELECT empresa, caixa, dat_movto, operacao
    FROM mcx_movto
   WHERE empresa = p_cod_empresa
     AND caixa   = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 100 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------------#
 FUNCTION geo1018_busca_ap_baixada()
#------------------------------------#
 DEFINE l_num_ap   LIKE mcx_mov_baixa_cap.autoriz_pagto

 WHENEVER ERROR CONTINUE
  SELECT autoriz_pagto
    INTO l_num_ap
    FROM mcx_mov_baixa_cap
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
 WHENEVER ERROR STOP
 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("SELEÇÃO","mcx_mov_baixa_cap")
 END IF
 RETURN l_num_ap

 END FUNCTION

#-------------------------------#
 FUNCTION geo1018_oper_estorno()
#-------------------------------#
 DEFINE l_ies_estorno   CHAR(01)

 WHENEVER ERROR CONTINUE
  SELECT eh_estorno
    INTO l_ies_estorno
    FROM mcx_operacao_caixa
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
 WHENEVER ERROR STOP
 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF
 IF l_ies_estorno = "S" THEN
    RETURN TRUE
 END IF

 RETURN FALSE

 END FUNCTION

#---------------------------------------#
 FUNCTION geo1018_insere_dados_estorno()
#---------------------------------------#
 DEFINE l_mcx_lancto_contab   RECORD LIKE mcx_lancto_contab.*,
        l_mcx_aen_4           RECORD LIKE mcx_aen_4.*

 DECLARE cl_lanc CURSOR FOR

  SELECT empresa, caixa, dat_movto, sequencia_caixa, sequencia_lancto,
         eh_manual_autom, tip_lancto, conta_contab, val_lancto,
         hist_lancto, lote_lancto, eh_conta_caixa
    FROM mcx_lancto_contab
   WHERE empresa   = m_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = m_dat_movto
     AND sequencia_caixa = m_seq_dig

 FOREACH cl_lanc INTO l_mcx_lancto_contab.*

     LET l_mcx_lancto_contab.empresa         = p_cod_empresa
     LET l_mcx_lancto_contab.dat_movto       = mr_tela.dat_movto
     LET l_mcx_lancto_contab.sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
     LET l_mcx_lancto_contab.lote_lancto     = 0

     IF l_mcx_lancto_contab.tip_lancto = "D" THEN
        LET l_mcx_lancto_contab.tip_lancto = "C"
     ELSE
        LET l_mcx_lancto_contab.tip_lancto = "D"
     END IF

     WHENEVER ERROR CONTINUE
      INSERT INTO mcx_lancto_contab VALUES (l_mcx_lancto_contab.*)
     WHENEVER ERROR STOP

     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql("INSERT","mcx_lancto_contab_ESTORNO")
        RETURN FALSE
     END IF

 END FOREACH

 DECLARE cl_aen CURSOR FOR
  SELECT * FROM mcx_aen_4
   WHERE empresa    = m_empresa
     AND caixa      = mr_tela.caixa
     AND dat_lancto = m_dat_movto
     AND sequencia_caixa = m_seq_dig

 FOREACH cl_aen INTO l_mcx_aen_4.*

     LET l_mcx_aen_4.empresa         = p_cod_empresa
     LET l_mcx_aen_4.dat_lancto      = mr_tela.dat_movto
     LET l_mcx_aen_4.sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa

     WHENEVER ERROR CONTINUE
      INSERT INTO mcx_aen_4 VALUES (l_mcx_aen_4.*)
     WHENEVER ERROR STOP

     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql("INSERT","MCX_AEN_4_ESTORNO")
        RETURN FALSE
     END IF

 END FOREACH

 RETURN TRUE

 END FUNCTION

#--------------------------------#
 FUNCTION geo1018_grava_estorno()
#--------------------------------#
 DEFINE l_where_clause    CHAR(250)

 WHENEVER ERROR CONTINUE
  INSERT INTO mcx_estorno VALUES (p_cod_empresa, mr_tela.caixa, mr_tela.dat_movto,
                                  ma_tela[m_arr_curr].operacao,
                                  ma_tela[m_arr_curr].sequencia_caixa,
                                  mr_tela.caixa, m_dat_movto, g_operacao, m_seq_dig)
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("INSERT","MCX_ESTORNO")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
 END IF

 IF NOT mcx0812_geracao_auditoria(p_cod_empresa,
                                  'mcx_movto',
                                  'I',
                                  ma_tela[m_arr_curr].tip_operacao,
                                  mr_tela.caixa,
                                  ma_tela[m_arr_curr].sequencia_caixa,
                                  mr_tela.dat_movto,
                                  ma_tela[m_arr_curr].val_docum,
                                  'geo1018') THEN
    CALL log085_transacao("ROLLBACK")
    CALL log003_err_sql('INSERT','mcx_auditoria')
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#-----------------------------------------#
 FUNCTION geo1018_verifica_docum_existe()
#-----------------------------------------#
 DEFINE l_sequencia_caixa   LIKE mcx_movto.sequencia_caixa

 WHENEVER ERROR CONTINUE
  SELECT sequencia_caixa
    INTO l_sequencia_caixa
    FROM mcx_movto
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
     AND operacao  = ma_tela[m_arr_curr].operacao
     AND docum     = ma_tela[m_arr_curr].docum
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    IF l_sequencia_caixa <> ma_tela[m_arr_curr].sequencia_caixa THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#-----------------------------#
 FUNCTION geo1018_aen_lanc()
#-----------------------------#
 IF ma_tela[m_arr_curr].operacao IS NOT NULL THEN
    IF m_abre_aen <> 'N' THEN
       IF ma_aen_automatica[m_arr_curr] <> "M" THEN  # O.S 395807
          IF NOT geo1018_insere_aen() THEN
             RETURN FALSE
          END IF
       END IF
    END IF

    IF NOT geo1018_insere_lanc_contabil() THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------------------#
 FUNCTION geo1018_verifica_delete(l_funcao)
#------------------------------------------#
 DEFINE l_funcao        CHAR(20),
        l_where_clause  CHAR(250)

 CALL geo1018_carrega_mcx_movto(1)

 CALL geo1021_gera_integracao(m_mcx_movto.*,"control-e")
      RETURNING m_mcx_movto.*, m_baixa_ap, m_cod_empresa, m_num_ap

 #CALL log006_exibe_teclas("01", p_versao)
 #CURRENT WINDOW IS w_geo1018

 CALL geo1018_carrega_mcx_movto(2)

 IF g_control_e THEN
    IF log004_confirm(10,20) THEN
       IF geo1018_elimina_dados() THEN

          IF NOT mcx0812_geracao_auditoria(p_cod_empresa,
                                           'mcx_movto',
                                           'E',
                                           ma_tela[m_arr_curr].tip_operacao,
                                           mr_tela.caixa,
                                           ma_tela[m_arr_curr].sequencia_caixa,
                                           mr_tela.dat_movto,
                                           ma_tela[m_arr_curr].val_docum,
                                           'geo1018') THEN
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql('INSERT','mcx_auditoria')
            RETURN
          END IF

          CALL geo1018_control_e(l_funcao)
          LET m_val_aen   = ma_tela[m_arr_curr].val_docum
          LET m_control_e = TRUE
          CALL log085_transacao("COMMIT")
          CALL log085_transacao("BEGIN")
          LET m_docum_ant = ma_tela[m_arr_curr].docum
       END IF
    END IF
 ELSE
    CASE g_modulo
       WHEN "CAP"  CALL log0030_mensagem("Movimento não pode ser excluido pois existe uma AP associada.","info")
       WHEN "CAP1" CALL log0030_mensagem("Movimento não pode ser excluido pois uma AP foi baixada no CAP.","info")
       WHEN "SUP"  CALL log0030_mensagem("Movimento não pode ser excluido pois existe uma nota fiscal associada.","info")
       WHEN "CRE"  CALL log0030_mensagem("Movimento não pode ser excluido pois existe um documento associado no CRE.","info")
       WHEN "CRE1" CALL log0030_mensagem("Movimento não pode ser excluido pois um documento foi baixado no CRE.","info")
       WHEN "TRA"  CALL log0030_mensagem("Movimento não pode ser excluido pois o caixa destino já está fechado.","info")
    END CASE
 END IF

 END FUNCTION

#------------------------------------------#
 FUNCTION geo1018_carrega_mcx_movto(l_ind)
#------------------------------------------#
 DEFINE l_ind  SMALLINT

 CASE l_ind
    WHEN 1
       IF m_mcx_movto.dat_movto IS NULL THEN
          LET m_mcx_movto.dat_movto = mr_tela.dat_movto
       END IF
       LET m_mcx_movto.empresa      = p_cod_empresa
       LET m_mcx_movto.caixa        = mr_tela.caixa
       LET m_mcx_movto.operacao     = ma_tela[m_arr_curr].operacao
       LET m_mcx_movto.tip_operacao = ma_tela[m_arr_curr].tip_operacao
       LET m_mcx_movto.docum        = ma_tela[m_arr_curr].docum
       LET m_mcx_movto.val_docum    = ma_tela[m_arr_curr].val_docum
       LET m_mcx_movto.hist_movto   = ma_tela[m_arr_curr].hist_movto
       LET m_mcx_movto.sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
    WHEN 2
       LET ma_tela[m_arr_curr].docum = m_mcx_movto.docum
       IF m_mcx_movto.val_docum <> 0 THEN
          LET ma_tela[m_arr_curr].val_docum = m_mcx_movto.val_docum
       END IF
    WHEN 3
       LET m_empresa                      = m_mcx_movto.empresa
       LET m_dat_movto                    = m_mcx_movto.dat_movto
       LET g_operacao                     = m_mcx_movto.operacao
       LET m_seq_dig                      = m_mcx_movto.sequencia_caixa
       LET ma_tela[m_arr_curr].docum      = m_mcx_movto.docum
       LET ma_tela[m_arr_curr].val_docum  = m_mcx_movto.val_docum
       LET ma_tela[m_arr_curr].hist_movto = "ESTORNO ",m_mcx_movto.hist_movto CLIPPED
 END CASE

# DISPLAY ma_tela[m_arr_curr].* TO s_movtos[m_scr_lin].*

 END FUNCTION

#----------------------------------#
 FUNCTION geo1018_verifica_contab()
#----------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT tip_contab_conta, tip_contab_cc
    INTO m_tip_contab_conta, m_tip_contab_cc
    FROM mcx_operacao_caixa
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
 WHENEVER ERROR STOP

 END FUNCTION

#----------------------------------------#
 FUNCTION geo1018_verifica_lancamentos()
#----------------------------------------#
 DEFINE l_cont  SMALLINT

 LET l_cont = 0

 WHENEVER ERROR CONTINUE
  SELECT COUNT(*)
    INTO l_cont
    FROM mcx_lancto_contab
   WHERE empresa = p_cod_empresa
     AND caixa   = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
 WHENEVER ERROR STOP

 IF l_cont > 0 THEN
    RETURN TRUE
 END IF

 RETURN FALSE

 END FUNCTION

#--------------------------------#
 FUNCTION geo1018_elimina_dados()
#--------------------------------#
 DEFINE l_empresa_destino  LIKE mcx_movto_gera_cre.empresa_destino,
        l_num_docum        LIKE mcx_movto_gera_cre.docum,
        l_tip_docum        LIKE mcx_movto_gera_cre.tip_docum,
        l_cliente          LIKE mcx_movto_gera_cre.cliente,
        l_caixa_destino    LIKE mcx_oper_cx_transf.caixa_destino,
        l_oper_destino     LIKE mcx_oper_cx_transf.operacao_destino,
        l_num_ap           LIKE mcx_mov_baixa_cap.autoriz_pagto,
        l_num_nf           LIKE mcx_movto_gera_cap.nota_fiscal,
        l_ser_nf           LIKE mcx_movto_gera_cap.serie_nota_fiscal,
        l_ssr_nf           LIKE mcx_movto_gera_cap.subserie_nf,
        l_fornecedor       LIKE mcx_movto_gera_cap.fornecedor,
        l_sequencia_docum  LIKE mcx_movto_trb.sequencia_docum,
        l_sequencia_caixa  LIKE mcx_movto.sequencia_caixa,
        l_especie_nf       LIKE mcx_movto_sup.espc_nota_fiscal,
        l_num_conc         LIKE movfin.num_conc,
        l_modulo           CHAR(03),
        l_lote             LIKE mcx_movto_trb.lote,
        l_status           SMALLINT,
        l_message          CHAR(80)

 CASE g_modulo
    WHEN "CAP"
       WHENEVER ERROR CONTINUE
        SELECT empresa_destino, nota_fiscal, serie_nota_fiscal, subserie_nf, fornecedor
          INTO l_empresa_destino, l_num_nf, l_ser_nf, l_ssr_nf, l_fornecedor
          FROM mcx_movto_gera_cap
         WHERE empresa   = p_cod_empresa
           AND caixa     = mr_tela.caixa
           AND dat_movto = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
       WHENEVER ERROR STOP

       WHENEVER ERROR CONTINUE
        DELETE FROM mcx_movto_gera_cap
         WHERE empresa         = p_cod_empresa
           AND caixa           = mr_tela.caixa
           AND dat_movto       = mr_tela.dat_movto
           AND empresa_destino = l_empresa_destino
           AND nota_fiscal     = l_num_nf
           AND serie_nota_fiscal = l_ser_nf
           AND subserie_nf     = l_ssr_nf
           AND fornecedor      = l_fornecedor
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOVTO_GERA_CAP")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF

    WHEN "CAP1"
       WHENEVER ERROR CONTINUE
        SELECT empresa_destino, autoriz_pagto
          INTO l_empresa_destino, l_num_ap
          FROM mcx_mov_baixa_cap
         WHERE empresa   = p_cod_empresa
           AND caixa     = mr_tela.caixa
           AND dat_movto = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
       WHENEVER ERROR STOP

       WHENEVER ERROR CONTINUE
        DELETE FROM mcx_mov_baixa_cap
         WHERE empresa         = p_cod_empresa
           AND caixa           = mr_tela.caixa
           AND dat_movto       = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
           AND empresa_destino = l_empresa_destino
           AND autoriz_pagto   = l_num_ap
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","mcx_mov_baixa_cap")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF

    WHEN "CRE"
       WHENEVER ERROR CONTINUE
        SELECT empresa_destino, docum, tip_docum, cliente
          INTO l_empresa_destino, l_num_docum, l_tip_docum, l_cliente
          FROM mcx_movto_gera_cre
         WHERE empresa    = p_cod_empresa
           AND caixa      = mr_tela.caixa
           AND dat_movto  = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
       WHENEVER ERROR STOP

       WHENEVER ERROR CONTINUE
        DELETE FROM mcx_movto_gera_cre
         WHERE empresa         = p_cod_empresa
           AND caixa           = mr_tela.caixa
           AND dat_movto       = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
           AND empresa_destino = l_empresa_destino
           AND docum           = l_num_docum
           AND tip_docum       = l_tip_docum
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOVTO_GERA_CRE")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF

    WHEN "CRE1"
       WHENEVER ERROR CONTINUE
        SELECT empresa_destino, docum, tip_docum, sequencia_docum
          INTO l_empresa_destino, l_num_docum, l_tip_docum, l_sequencia_caixa
          FROM mcx_mov_baixa_cre
         WHERE empresa    = p_cod_empresa
           AND caixa      = mr_tela.caixa
           AND dat_movto  = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
       WHENEVER ERROR STOP

       WHENEVER ERROR CONTINUE
        DELETE FROM mcx_mov_baixa_cre
         WHERE empresa         = p_cod_empresa
           AND caixa           = mr_tela.caixa
           AND dat_movto       = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
           AND empresa_destino = l_empresa_destino
           AND docum           = l_num_docum
           AND tip_docum       = l_tip_docum
           AND sequencia_docum = l_sequencia_caixa
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOV_BAIXA_CRE")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF

    WHEN "SUP"
       WHENEVER ERROR CONTINUE
        SELECT empresa_destino, nota_fiscal, serie_nota_fiscal, subserie_nf,
               espc_nota_fiscal, fornecedor
          INTO l_empresa_destino, l_num_nf, l_ser_nf, l_ssr_nf, l_especie_nf, l_fornecedor
          FROM mcx_movto_sup
         WHERE empresa   = p_cod_empresa
           AND caixa     = mr_tela.caixa
           AND dat_movto = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
       WHENEVER ERROR STOP

       WHENEVER ERROR CONTINUE
        DELETE FROM mcx_movto_sup
         WHERE empresa    = p_cod_empresa
           AND caixa      = mr_tela.caixa
           AND dat_movto  = mr_tela.dat_movto
           AND empresa_destino   = l_empresa_destino
           AND nota_fiscal       = l_num_nf
           AND serie_nota_fiscal = l_ser_nf
           AND subserie_nf       = l_ssr_nf
           AND espc_nota_fiscal  = l_especie_nf
           AND fornecedor        = l_fornecedor
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOVTO_SUP")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF

    WHEN "TRB"
       WHENEVER ERROR CONTINUE
        SELECT empresa_destino, docum, sequencia_docum,lote
          INTO l_empresa_destino, l_num_docum, l_sequencia_docum,l_lote
          FROM mcx_movto_trb
         WHERE empresa   = p_cod_empresa
           AND caixa     = mr_tela.caixa
           AND dat_movto = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
       WHENEVER ERROR STOP

       WHENEVER ERROR CONTINUE
        DELETE FROM mcx_movto_trb
         WHERE empresa   = p_cod_empresa
           AND caixa     = mr_tela.caixa
           AND dat_movto = mr_tela.dat_movto
           AND empresa_destino = l_empresa_destino
           AND docum           = l_num_docum
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
           AND sequencia_docum = l_sequencia_docum
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOVTO_TRB")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF

       WHENEVER ERROR CONTINUE
       SELECT num_conc
         INTO l_num_conc
         FROM movfin
        WHERE cod_empresa = l_empresa_destino
          AND num_lote    = l_lote
          AND seq_dig     = l_sequencia_docum
      WHENEVER ERROR STOP

       IF l_num_conc IS NOT NULL THEN
          CALL log0030_mensagem('Lote já conciliado no TRB e não pode ser excluído.','exclamation')
          CALL log085_transacao("ROLLBACK")
       END IF

       WHENEVER ERROR CONTINUE
        DELETE FROM movfin
         WHERE cod_empresa = l_empresa_destino
           AND num_lote    = l_lote
           AND seq_dig     = l_sequencia_docum
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MOVFIN")
          CALL log085_transacao("ROLLBACK")
          RETURN FALSE
       END IF

       WHENEVER ERROR CONTINUE
        SELECT cod_empresa
          FROM movfin
         WHERE cod_empresa = l_empresa_destino
           AND num_lote    = l_lote
       WHENEVER ERROR STOP
       IF sqlca.sqlcode = 100 THEN
          WHENEVER ERROR CONTINUE
           DELETE FROM lotedoc
           WHERE lotedoc.cod_empresa = l_empresa_destino
             AND lotedoc.num_lote    = l_lote
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("EXCLUSAO","LOTEDOC")
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
          END IF
       END IF
 END CASE

 IF geo1018_oper_estorno() THEN
    WHENEVER ERROR CONTINUE
     DELETE FROM mcx_estorno
      WHERE empresa   = p_cod_empresa
        AND caixa     = mr_tela.caixa
        AND dat_movto = mr_tela.dat_movto
        AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("DELETE","MCX_ESTORNO")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
 END IF

 WHENEVER ERROR CONTINUE
  DELETE FROM mcx_lancto_contab
   WHERE empresa       = p_cod_empresa
     AND caixa         = mr_tela.caixa
     AND dat_movto     = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","mcx_lancto_contab")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  DELETE FROM mcx_aen_4
   WHERE empresa       = p_cod_empresa
     AND caixa         = mr_tela.caixa
     AND dat_lancto    = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","MCX_AEN_4")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
 END IF

 CASE g_modulo
    WHEN "CAP"  LET l_modulo = "CAP"
    WHEN "CAP1" LET l_modulo = "CAP"
    WHEN "SUP"  LET l_modulo = "SUP"
    WHEN "CRE"  LET l_modulo = "CRE"
    WHEN "CRE1" LET l_modulo = "CRE"
    WHEN "TRB"  LET l_modulo = "TRB"
    WHEN "TRA"  LET l_modulo = "TRA"
 END CASE

 IF g_modulo <> "MCX" THEN
    WHENEVER ERROR CONTINUE
     DELETE FROM mcx_pendencia
      WHERE empresa       = p_cod_empresa
        AND caixa         = mr_tela.caixa
        AND dat_movto     = mr_tela.dat_movto
        AND modulo_origem = l_modulo
        AND docum         = ma_tela[m_arr_curr].docum
        AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("DELETE","MCX_PENDENCIA")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
 END IF

 IF g_modulo = "TRA" THEN
    WHENEVER ERROR CONTINUE
     SELECT empresa_destino, caixa_destino, oper_destino
       INTO l_empresa_destino, l_caixa_destino, l_oper_destino
       FROM mcx_oper_cx_transf
      WHERE empresa  = p_cod_empresa
        AND operacao = ma_tela[m_arr_curr].operacao
    WHENEVER ERROR STOP

    WHENEVER ERROR CONTINUE
     DELETE FROM mcx_movto
      WHERE empresa   = l_empresa_destino
        AND caixa     = l_caixa_destino
        AND dat_movto = mr_tela.dat_movto
        AND docum     = ma_tela[m_arr_curr].docum
        AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
        AND operacao  = l_oper_destino
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("DELETE","MCX_MOVTO_TRANSF")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
 END IF

 CALL fcl1260_integracao_mcx_fcx(p_cod_empresa,
                                 mr_tela.caixa,
                                 ma_tela[m_arr_curr].sequencia_caixa,
                                 mr_tela.dat_movto,
                                 "EX")
                       RETURNING l_status,
                                 l_message

 IF NOT l_status THEN
    CALL log0030_mensagem(l_message,"info")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  DELETE FROM mcx_movto
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","MCX_MOVTO")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#-------------------------------------#
 FUNCTION geo1018_control_e(l_funcao)
#-------------------------------------#
 DEFINE l_cont         SMALLINT,
        l_funcao       CHAR(20),
        l_tot_reg      SMALLINT,
        l_ind          SMALLINT

 IF l_funcao = "MODIFICACAO" THEN
    LET l_tot_reg = m_tot_reg
 ELSE
    CALL geo1018_retorna_qtd_registros() RETURNING l_tot_reg
 END IF

 IF l_tot_reg > 0 AND l_tot_reg >= m_arr_curr THEN
    INITIALIZE ma_tela[m_arr_curr].* TO NULL
    #DISPLAY ma_tela[m_arr_curr].* TO s_movtos[m_scr_lin].*
    FOR l_cont = m_arr_curr TO l_tot_reg
        IF ma_tela[l_cont+1].operacao IS NOT NULL THEN
           LET ma_tela[l_cont].* = ma_tela[l_cont+1].*
           WHENEVER ERROR CONTINUE
            UPDATE mcx_movto
               SET sequencia_caixa = ma_tela[l_cont].sequencia_caixa
             WHERE empresa   = p_cod_empresa
               AND caixa     = mr_tela.caixa
               AND dat_movto = mr_tela.dat_movto
               AND sequencia_caixa = ma_tela[l_cont+1].sequencia_caixa
           WHENEVER ERROR STOP
        END IF
    END FOR
    INITIALIZE ma_tela[l_tot_reg].* TO NULL
    LET l_tot_reg = l_tot_reg - 1
 END IF

 IF m_tot_reg > 0 THEN
    LET m_tot_reg = l_tot_reg
 END IF

 LET l_ind = m_arr_curr
 FOR l_cont = m_scr_lin TO 5
    #DISPLAY ma_tela[l_ind].* TO s_movtos[l_cont].*
    LET l_ind = l_ind + 1
 END FOR

 END FUNCTION

#-----------------------------------------#
 FUNCTION geo1018_retorna_qtd_registros()
#-----------------------------------------#
 DEFINE l_cont   SMALLINT

 FOR l_cont = 1 TO 1000
     IF ma_tela[l_cont].operacao IS NULL THEN
        EXIT FOR
     END IF
 END FOR

 LET l_cont = l_cont - 1

 RETURN l_cont

 END FUNCTION

#--------------------------------------------------#
 FUNCTION geo1018_busca_parametros(l_tip_operacao)
#--------------------------------------------------#
 DEFINE l_tip_operacao     LIKE mcx_movto.tip_operacao

 WHENEVER ERROR CONTINUE
  SELECT *
    FROM mcx_oper_cx_transf
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    LET l_tip_operacao = "T"
 END IF

 CALL mcx0304_busca_parametros(p_cod_empresa, l_tip_operacao)
    RETURNING m_linha_produto, m_linha_receita, m_segmto_mercado, m_classe_uso

 END FUNCTION

#-----------------------------------------#
 FUNCTION geo1018_verifica_tip_operacao()
#-----------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT tip_operacao
    INTO ma_tela[m_arr_curr].tip_operacao
    FROM mcx_operacao_caixa
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
 WHENEVER ERROR STOP

 #DISPLAY ma_tela[m_arr_curr].tip_operacao TO s_movtos[m_scr_lin].tip_operacao

 END FUNCTION

#----------------------------------#
 FUNCTION geo1018_verifica_caixa()
#----------------------------------#
 LET mr_tela.des_caixa = NULL

 WHENEVER ERROR CONTINUE
  SELECT des_caixa
    INTO mr_tela.des_caixa
    FROM mcx_caixa
   WHERE empresa = p_cod_empresa
     AND caixa   = mr_tela.caixa
 WHENEVER ERROR STOP

 #DISPLAY BY NAME mr_tela.des_caixa

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#----------------------------------#
 FUNCTION geo1018_verifica_saldo()
#----------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT val_saldo
    FROM mcx_saldo
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_saldo = mr_tela.dat_movto
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#-----------------------------------------#
 FUNCTION geo1018_verifica_saldo_fechado()
#-----------------------------------------#
 DEFINE l_max_data  LIKE mcx_saldo.dat_saldo

 LET l_max_data = NULL

 WHENEVER ERROR CONTINUE
  SELECT MAX(dat_saldo)
    INTO l_max_data
    FROM mcx_saldo
   WHERE empresa = p_cod_empresa
     AND caixa   = mr_tela.caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    IF mr_tela.dat_movto <= l_max_data THEN
       ERROR "Não é possível incluir. Existem caixas fechados com data superior ao informado."
       RETURN TRUE
    END IF
 END IF

 RETURN FALSE

 END FUNCTION

#-------------------------------------#
 FUNCTION geo1018_verifica_operacao()
#-------------------------------------#
 LET ma_tela[m_arr_curr].des_operacao = NULL

 WHENEVER ERROR CONTINUE
  SELECT des_operacao, aen_automatica
    INTO ma_tela[m_arr_curr].des_operacao, ma_aen_automatica[m_arr_curr] # O.S 395807
    FROM mcx_operacao_caixa
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
 WHENEVER ERROR STOP

 #DISPLAY ma_tela[m_arr_curr].des_operacao TO s_movtos[m_scr_lin].des_operacao

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#----------------------------------#
 FUNCTION geo1018_busca_sequencia()
#----------------------------------#
 DEFINE l_sequencia_caixa  LIKE mcx_movto.sequencia_caixa

 LET l_sequencia_caixa = 0

 WHENEVER ERROR CONTINUE
  SELECT MAX(sequencia_caixa)
    INTO l_sequencia_caixa
    FROM mcx_movto
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
 WHENEVER ERROR STOP

 RETURN l_sequencia_caixa

 END FUNCTION

#-------------------------#
 FUNCTION geo1018_popup()
#-------------------------#
 DEFINE l_operacao        LIKE mcx_operacao_caixa.operacao,
        l_caixa           LIKE mcx_movto.caixa

 CASE
  WHEN INFIELD(caixa)
    LET l_caixa = log009_popup(8,20,
                  "CAIXA",
                  "mcx_caixa",
                  "caixa",
                  "des_caixa",
                  "mcx0003",
                  "S",
                  "")

    #CURRENT WINDOW IS w_geo1018

    IF l_caixa IS NOT NULL AND l_caixa <> " " THEN
       LET mr_tela.caixa = l_caixa
       #DISPLAY BY NAME mr_tela.caixa
    END IF

  WHEN INFIELD(operacao)
    LET l_operacao = mcx0301_popup_operacoes_caixa(p_cod_empresa)
    #CURRENT WINDOW IS w_geo1018

    IF l_operacao IS NOT NULL AND l_operacao <> " " THEN
       LET ma_tela[m_arr_curr].operacao = l_operacao
       #DISPLAY ma_tela[m_arr_curr].operacao TO s_movtos[m_scr_lin].operacao
    END IF
 END CASE

 END FUNCTION

#---------------------------#
 FUNCTION geo1018_inclusao()
#---------------------------#
 DEFINE l_cont          SMALLINT,
        l_erro          SMALLINT,
        l_where_clause  CHAR(250),
        l_empresa       LIKE mcx_movto.empresa,
        l_caixa         LIKE mcx_movto.caixa,
        l_operacao      LIKE mcx_movto.operacao,
        l_hist_movto    LIKE mcx_movto.hist_movto

 #DISPLAY p_cod_empresa TO empresa

 INITIALIZE mr_tela.*, ma_tela TO NULL
 LET mr_tela.* = mr_telar.*

 IF geo1018_entrada_dados("INCLUSAO") THEN
    MESSAGE "Inclusão efetuada com sucesso." ATTRIBUTE(REVERSE)
 ELSE
    ERROR "Inclusão Cancelada."
 END IF

 CALL geo1018_libera_registro()

 LET mr_telar.* = mr_tela.*

 END FUNCTION

#-----------------------------------------------------#
 FUNCTION geo1018_verifica_pendencia(l_funcao, l_cont)
#-----------------------------------------------------#
 DEFINE l_cont       SMALLINT,
        l_funcao     CHAR(20),
        l_historico  LIKE mcx_pendencia.hist

 WHENEVER ERROR CONTINUE
  SELECT val_docum
    FROM mcx_pendencia
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
     AND docum     = ma_tela[l_cont].docum
     AND sequencia_caixa  = ma_tela[l_cont].sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
     UPDATE mcx_pendencia
        SET val_docum = ma_tela[l_cont].val_docum
      WHERE empresa   = p_cod_empresa
        AND caixa     = mr_tela.caixa
        AND dat_movto = mr_tela.dat_movto
        AND docum     = ma_tela[l_cont].docum
        AND sequencia_caixa = ma_tela[l_cont].sequencia_caixa
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#-----------------------------#
 FUNCTION geo1018_insere_aen()
#-----------------------------#
 DEFINE l_valor_aen  LIKE mcx_aen_4.val_aen

 WHENEVER ERROR CONTINUE
  SELECT SUM(val_aen)
    INTO l_valor_aen
    FROM mcx_aen_4
   WHERE empresa    = p_cod_empresa
     AND caixa      = mr_tela.caixa
     AND dat_lancto = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
 WHENEVER ERROR STOP

 IF l_valor_aen IS NOT NULL OR l_valor_aen <> " " THEN
    IF l_valor_aen <> ma_tela[m_arr_curr].val_docum THEN
       IF NOT geo1018_atualiza_aen() THEN
          RETURN FALSE
       END IF
    END IF
 ELSE
    IF NOT geo1018_insere_aen1() THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#-------------------------------#
 FUNCTION geo1018_atualiza_aen()
#-------------------------------#
 WHENEVER ERROR CONTINUE
  DELETE FROM mcx_aen_4
   WHERE empresa = p_cod_empresa
     AND caixa   = mr_tela.caixa
     AND dat_lancto = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","MCX_AEN_4")
    RETURN FALSE
 END IF

 IF NOT geo1018_insere_aen1() THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------------------#
 FUNCTION geo1018_insere_lanc_contabil()
#---------------------------------------#
 # Fazer a inclusao e testar log0030_err_sql_registro_duplicado() ou 268.

 DEFINE l_val_lancto  LIKE mcx_lancto_contab.val_lancto

 WHENEVER ERROR CONTINUE
  SELECT SUM(val_lancto)
    INTO l_val_lancto
    FROM mcx_lancto_contab
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
     AND eh_conta_caixa  = "S"
 WHENEVER ERROR STOP

 IF l_val_lancto IS NOT NULL OR l_val_lancto <> " " THEN
    IF l_val_lancto <> ma_tela[m_arr_curr].val_docum THEN
       IF NOT geo1018_atualiza_lanc() THEN
          RETURN FALSE
       END IF
    END IF
 ELSE
    IF NOT geo1018_insere_lancamentos() THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#----------------------------------#
 FUNCTION geo1018_atualiza_lanc()
#----------------------------------#
 WHENEVER ERROR CONTINUE
  DELETE FROM mcx_lancto_contab
   WHERE empresa = p_cod_empresa
     AND caixa   = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","mcx_lancto_contab")
    RETURN FALSE
 END IF

 IF NOT geo1018_insere_lancamentos() THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#-------------------------------------#
 FUNCTION geo1018_insere_lancamentos()
#-------------------------------------#
 DEFINE l_tip_contab_cc   LIKE mcx_operacao_caixa.tip_contab_cc,
        l_conta_cx        LIKE mcx_caixa.conta_caixa,
        l_conta_operacao  LIKE mcx_operacao_caixa.conta_contab,
        l_num_conta_cont  LIKE plano_contas.num_conta_reduz,
        l_plano_contas    RECORD LIKE plano_contas.*,
        l_status          SMALLINT,
        l_cont, l_ind     SMALLINT,
        l_conta_caixa     CHAR(01),
        l_conta_oper      CHAR(01),
        l_msg             CHAR(60)

 WHENEVER ERROR CONTINUE
  SELECT tip_contab_cc
    INTO l_tip_contab_cc
    FROM mcx_operacao_caixa
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
 WHENEVER ERROR STOP

 CASE ma_tela[m_arr_curr].tip_operacao
   WHEN "E" LET l_conta_caixa = "D"
            LET l_conta_oper  = "C"

   WHEN "S" LET l_conta_caixa = "C"
            LET l_conta_oper  = "D"
 END CASE

 # Buscar a conta caixa
 WHENEVER ERROR CONTINUE
  SELECT conta_caixa
    INTO l_conta_cx
    FROM mcx_caixa
   WHERE empresa = p_cod_empresa
     AND caixa   = mr_tela.caixa
 WHENEVER ERROR STOP

 CALL con088_verifica_cod_conta(p_cod_empresa, l_conta_cx, "S",TODAY)
      RETURNING l_plano_contas.*, l_status

 IF NOT l_status THEN
    LET l_msg = "Conta caixa não cadastrada para a seqüência  ",ma_tela[m_arr_curr].sequencia_caixa
    CALL log0030_mensagem(l_msg,"info")
    RETURN FALSE
 END IF

 # Buscar a conta operação
 WHENEVER ERROR CONTINUE
  SELECT conta_contab
    INTO l_conta_operacao
    FROM mcx_operacao_caixa
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
 WHENEVER ERROR STOP

 CALL con088_verifica_cod_conta(p_cod_empresa, l_conta_operacao, "S",TODAY)
      RETURNING l_plano_contas.*, l_status

 IF NOT l_status THEN
    LET l_msg = "Conta operação não cadastrada para a seqüência  ",ma_tela[m_arr_curr].sequencia_caixa
    CALL log0030_mensagem(l_msg,"info")
    RETURN FALSE
 END IF

 # Inserir a conta caixa
 WHENEVER ERROR CONTINUE
  INSERT INTO mcx_lancto_contab VALUES (p_cod_empresa, mr_tela.caixa, mr_tela.dat_movto,
                                        ma_tela[m_arr_curr].sequencia_caixa, 1, l_tip_contab_cc,
                                        l_conta_caixa, l_conta_cx,
                                        ma_tela[m_arr_curr].val_docum,
                                        ma_tela[m_arr_curr].hist_movto, 0, "S")
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("INSERT","MCX_CONTA_CAIXA")
    RETURN FALSE
 END IF

 # Inserir a conta operacao
 WHENEVER ERROR CONTINUE
  INSERT INTO mcx_lancto_contab VALUES (p_cod_empresa, mr_tela.caixa, mr_tela.dat_movto,
                                        ma_tela[m_arr_curr].sequencia_caixa, 2,
                                        l_tip_contab_cc, l_conta_oper, l_conta_operacao,
                                        ma_tela[m_arr_curr].val_docum,
                                        ma_tela[m_arr_curr].hist_movto, 0, "N")
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("INSERT","MCX_CONTA_OPERACAO")
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------#
 FUNCTION geo1018_insere_aen1()
#------------------------------#
 WHENEVER ERROR CONTINUE
  INSERT INTO mcx_aen_4 VALUES (p_cod_empresa, mr_tela.caixa, mr_tela.dat_movto,
                                ma_tela[m_arr_curr].sequencia_caixa, 1,
                                ma_tela[m_arr_curr].val_docum,
                                m_linha_produto, m_linha_receita, m_segmto_mercado, m_classe_uso)
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("INSERT","MCX_AEN 2")
    RETURN FALSE
 END IF

 # Se a operação gera cre, tenho que gravar os mesmos registros na adocum_aen
 IF g_modulo = "CRE" THEN
    IF NOT geo1018_grava_adto_aen() THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#-----------------------------------#
 FUNCTION geo1018_grava_adto_aen()
#-----------------------------------#
 DEFINE l_empresa_destino LIKE mcx_movto_gera_cre.empresa_destino,
        l_num_lote_cre    LIKE mcx_movto_gera_cre.lote_cre,
        l_num_docum       LIKE mcx_movto_gera_cre.docum,
        l_tip_docum       LIKE mcx_movto_gera_cre.tip_docum,
        l_cliente         LIKE mcx_movto_gera_cre.cliente,
        l_seq_adto        SMALLINT,
        l_seq_aen         SMALLINT,
        l_cont            SMALLINT

 WHENEVER ERROR CONTINUE
  SELECT empresa_destino, lote_cre, docum, tip_docum, cliente
    INTO l_empresa_destino, l_num_lote_cre, l_num_docum, l_tip_docum, l_cliente
    FROM mcx_movto_gera_cre
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
     AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
  SELECT COUNT(*)
    INTO l_cont
    FROM adto_cre_aen
   WHERE cod_empresa = l_empresa_destino
     AND cod_cliente = l_cliente
     AND ies_tip_reg = "A"
     AND num_pedido  = l_num_docum
     AND dat_atualiz = TODAY
 WHENEVER ERROR STOP

 # Se existir um registro significa que já foi incluido pelo mcx0806.
 IF l_cont = 1 THEN
    RETURN TRUE
 ELSE
    # Se existir mais de um registro eliminar e incluir novamente.
    IF l_cont > 1 THEN
       WHENEVER ERROR CONTINUE
        DELETE FROM adto_cre_aen
         WHERE cod_empresa = l_empresa_destino
           AND cod_cliente = l_cliente
           AND ies_tip_reg = "A"
           AND num_pedido  = l_num_docum
          AND dat_atualiz = TODAY
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","ADTO_CRE_AEN")
          RETURN FALSE
       END IF
    END IF
 END IF

 IF SQLCA.sqlcode = 0 THEN
    # Buscar a máxima sequencia do adto
    WHENEVER ERROR CONTINUE
     SELECT MAX(num_seq_adto)
       INTO l_seq_adto
       FROM adto_cre_aen
      WHERE cod_empresa  = l_empresa_destino
        AND cod_cliente  = l_cliente
        AND ies_tip_reg  = "A"
        AND num_pedido   = l_num_docum
    WHENEVER ERROR STOP

    IF l_seq_adto IS NULL OR l_seq_adto = " " THEN
       LET l_seq_adto = 0
    END IF
    LET l_seq_adto = l_seq_adto + 1

    # Buscar a máxima sequencia da aen.
    WHENEVER ERROR CONTINUE
     SELECT MAX(num_seq_aen)
       INTO l_seq_aen
       FROM adto_cre_aen
      WHERE cod_empresa  = l_empresa_destino
        AND cod_cliente  = l_cliente
        AND ies_tip_reg  = "A"
        AND num_pedido   = l_num_docum
        AND num_seq_adto = l_seq_adto
    WHENEVER ERROR STOP

    IF l_seq_aen IS NULL OR l_seq_aen = " " THEN
       LET l_seq_aen = 0
    END IF
    LET l_seq_aen = l_seq_aen + 1

    WHENEVER ERROR CONTINUE
     INSERT INTO adto_cre_aen VALUES (l_empresa_destino, l_cliente, "A", l_seq_adto,
                                      l_num_docum, l_seq_aen, m_linha_produto,
                                      m_linha_receita, m_segmto_mercado, m_classe_uso,
                                      "100", TODAY)
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","ADTO_CRE_AEN")
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------#
 FUNCTION geo1018_help()
#------------------------#
 CASE
    WHEN infield(caixa)      CALL showhelp(101)
    WHEN infield(dat_movto)  CALL showhelp(102)
    WHEN infield(operacao)   CALL showhelp(103)
    WHEN infield(docum)      CALL showhelp(104)
    WHEN infield(val_docum)  CALL showhelp(105)
    WHEN infield(hist_movto) CALL showhelp(106)
 END CASE
END FUNCTION

#---------------------------#
 FUNCTION geo1018_consulta()
#---------------------------#
 DEFINE l_status  SMALLINT

 #CALL log006_exibe_teclas('01 02 03 07 08', p_versao)
 #CURRENT WINDOW IS w_geo1018

 LET where_clause =  NULL

 CLEAR FORM
 LET INT_FLAG = FALSE

 #DISPLAY p_cod_empresa TO empresa

 INITIALIZE mr_tela.*, ma_tela TO NULL

 {CONSTRUCT BY NAME where_clause ON caixa, dat_movto

     BEFORE FIELD caixa
        IF g_ies_grafico THEN
           --# CALL fgl_dialog_setKeyLabel('control-z',"Zoom")
        ELSE
           #DISPLAY "( Zoom )" AT 3,66
        END IF

     AFTER FIELD caixa
        CALL get_fldbuf(caixa) RETURNING mr_tela.caixa

        IF mr_tela.caixa IS NULL THEN
           CALL log0030_mensagem("Caixa deve ser informado.","info")
           NEXT FIELD caixa
        ELSE
           CALL geo1018_verifica_caixa() RETURNING l_status
        END IF

#OS 513834
        IF m_valida_dt_dt_proc_che_mcx = "N" THEN
           LET mr_tela.dat_movto = TODAY
        ELSE
           LET mr_tela.dat_movto = geo1018_busca_dt_proc_che_mcx()
        END IF
#---------

        #DISPLAY BY NAME mr_tela.dat_movto
        IF g_ies_grafico THEN
           --# CALL fgl_dialog_setKeyLabel('control-z',"")
        ELSE
           #DISPLAY "--------" AT 3,66
        END IF

     AFTER FIELD dat_movto
        CALL get_fldbuf(dat_movto) RETURNING mr_tela.dat_movto

        IF mr_tela.dat_movto IS NULL THEN
           CALL log0030_mensagem("Data do movimento deve ser informada.","info")
           NEXT FIELD dat_movto
        END IF

     ON KEY (control-w)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE CONSTRUCT
        #lds END IF
        CALL geo1018_help()
     ON KEY (control-z, f4)
        CALL geo1018_popup()

     AFTER CONSTRUCT
        IF NOT INT_FLAG THEN
           CALL get_fldbuf(caixa) RETURNING mr_tela.caixa

           IF mr_tela.caixa IS NULL THEN
              CALL log0030_mensagem("Caixa deve ser informado.","info")
              NEXT FIELD caixa
           ELSE
              CALL geo1018_verifica_caixa() RETURNING l_status
           END IF

           CALL get_fldbuf(dat_movto) RETURNING mr_tela.dat_movto

           IF mr_tela.dat_movto IS NULL THEN
              CALL log0030_mensagem("Data do movimento deve ser informada.","info")
              NEXT FIELD dat_movto
           END IF
        END IF

 END CONSTRUCT

 #CALL log006_exibe_teclas('01', p_versao)
 #CURRENT WINDOW IS w_geo1018

 IF INT_FLAG THEN
    LET int_flag = FALSE
    INITIALIZE mr_tela.*, ma_tela TO NULL
    CLEAR FORM
    #DISPLAY p_cod_empresa TO empresa
    ERROR 'Consulta cancelada.'
 ELSE
    CALL geo1018_prepara_consulta()
 END IF

 CALL geo1018_exibe_dados()

 #CALL log006_exibe_teclas('01 09', p_versao)
 #CURRENT WINDOW IS w_geo1018
}
END FUNCTION

#-----------------------------------#
 FUNCTION geo1018_prepara_consulta()
#-----------------------------------#
 DEFINE l_cont   SMALLINT

 LET sql_stmt = "SELECT UNIQUE caixa, dat_movto ",
                "  FROM mcx_movto ",
                " WHERE empresa = """,p_cod_empresa,""" ",
               #"   AND ",where_clause CLIPPED, -> where_clause preenche data sem aspas quando da esc sem passar pelo campo
                "   AND caixa = '", mr_tela.caixa, "'",
                "   AND dat_movto = '", mr_tela.dat_movto, "'",
                " ORDER BY caixa, dat_movto"

 PREPARE var_movto FROM sql_stmt
 DECLARE cl_movto SCROLL CURSOR WITH HOLD FOR var_movto

 OPEN  cl_movto
 FETCH cl_movto INTO mr_tela.caixa, mr_tela.dat_movto

 IF SQLCA.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
     SELECT des_caixa
       INTO mr_tela.des_caixa
       FROM mcx_caixa
      WHERE empresa = p_cod_empresa
        AND caixa   = mr_tela.caixa
    WHENEVER ERROR STOP

    CALL geo1018_exibe_dados()
    CALL geo1018_mostra_array() RETURNING l_cont
    CALL geo1018_exibe_array(l_cont)
    LET m_tot_reg = l_cont - 1

    MESSAGE 'Consulta efetuada com sucesso. ' ATTRIBUTE (REVERSE)
    LET m_consulta_ativa = TRUE
 ELSE
    LET m_consulta_ativa = FALSE
    CLEAR FORM
    INITIALIZE mr_tela.*, ma_tela TO NULL
    #DISPLAY p_cod_empresa TO empresa
    CALL log0030_mensagem('Argumentos de pesquisa não encontrados. ','info')
 END IF

END FUNCTION

#--------------------------------#
 FUNCTION geo1018_mostra_array()
#--------------------------------#
 DEFINE l_cont  SMALLINT

 INITIALIZE ma_tela TO NULL

 LET l_cont = 1

 DECLARE cl_movto2 CURSOR FOR
  SELECT tip_operacao, operacao, docum, val_docum, hist_movto, sequencia_caixa
    FROM mcx_movto
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
   ORDER BY sequencia_caixa

 FOREACH cl_movto2 INTO ma_tela[l_cont].tip_operacao,
                        ma_tela[l_cont].operacao,
                        ma_tela[l_cont].docum,
                        ma_tela[l_cont].val_docum,
                        ma_tela[l_cont].hist_movto,
                        ma_tela[l_cont].sequencia_caixa

    WHENEVER ERROR CONTINUE
     SELECT des_operacao
       INTO ma_tela[l_cont].des_operacao
       FROM mcx_operacao_caixa
      WHERE empresa  = p_cod_empresa
        AND operacao = ma_tela[l_cont].operacao
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       LET ma_tela[l_cont].des_operacao  = NULL
    END IF

    LET l_cont = l_cont + 1

    IF l_cont > 9999 THEN
       EXIT FOREACH
    END IF

 END FOREACH

 CALL SET_COUNT(l_cont)

 RETURN l_cont

 END FUNCTION

#------------------------------#
 FUNCTION geo1018_exibe_dados()
#------------------------------#

 #DISPLAY p_cod_empresa TO empresa

 #DISPLAY BY NAME mr_tela.*

END FUNCTION

#------------------------------------#
 FUNCTION geo1018_exibe_array(l_cont)
#------------------------------------#
 DEFINE l_cont     SMALLINT,
        l_ind      SMALLINT,
        l_tot_prod SMALLINT

 LET l_tot_prod = l_cont - 1
 CALL SET_COUNT(l_cont - 1)

 IF l_tot_prod > 5 THEN
    #DISPLAY ARRAY ma_tela TO s_movtos.*
    #END DISPLAY
 ELSE
    FOR l_ind = 1 TO 5
       #DISPLAY ma_tela[l_ind].* TO s_movtos[l_ind].*
    END FOR
 END IF

 END FUNCTION

#------------------------------#
 FUNCTION geo1018_modificacao()
#------------------------------#
 DEFINE l_cont          SMALLINT

 IF NOT geo1018_verifica_programa_em_uso() THEN
    CALL geo1018_trava_registro()

    IF geo1018_input_array('MODIFICACAO') THEN
       MESSAGE "Modificação efetuada com sucesso." ATTRIBUTE(REVERSE)
    ELSE
       CALL log085_transacao("ROLLBACK")
       CALL geo1018_mostra_dados()
       LET m_consulta_ativa = FALSE
       ERROR 'Modificação cancelada.'
    END IF
 END IF

 CALL geo1018_libera_registro()

END FUNCTION

#-------------------------------#
 FUNCTION geo1018_mostra_dados()
#-------------------------------#
 DEFINE l_cont  SMALLINT

 LET l_cont = 1

 DECLARE cl_movto1 CURSOR FOR
  SELECT tip_operacao, operacao, docum, val_docum, hist_movto, sequencia_caixa
    FROM mcx_movto
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
   ORDER BY sequencia_caixa

 FOREACH cl_movto1 INTO ma_tela[l_cont].tip_operacao, ma_tela[l_cont].operacao,
                        ma_tela[l_cont].docum, ma_tela[l_cont].val_docum,
                        ma_tela[l_cont].hist_movto, ma_tela[l_cont].sequencia_caixa

    WHENEVER ERROR CONTINUE
     SELECT des_operacao
       INTO ma_tela[l_cont].des_operacao
       FROM mcx_operacao_caixa
      WHERE empresa  = p_cod_empresa
        AND operacao = ma_tela[l_cont].operacao
    WHENEVER ERROR STOP

    LET l_cont = l_cont + 1

 END FOREACH

 #DISPLAY p_cod_empresa TO empresa
 CALL geo1018_verifica_caixa() RETURNING p_status
 #DISPLAY BY NAME mr_tela.caixa, mr_tela.dat_movto

 FOR l_cont = 1 TO 5
    #DISPLAY ma_tela[l_cont].* TO s_movtos[l_cont].*
 END FOR

 END FUNCTION

#------------------------#
 FUNCTION geo1018_lista()
#------------------------#
 DEFINE lr_relat          RECORD
                             tip_operacao    LIKE mcx_operacao_caixa.tip_operacao,
                             operacao        LIKE mcx_operacao_caixa.operacao,
                             des_operacao    LIKE mcx_operacao_caixa.des_operacao,
                             docum           LIKE mcx_movto.docum,
                             val_docum       LIKE mcx_movto.val_docum,
                             hist_movto      LIKE mcx_movto.hist_movto,
                             sequencia_caixa LIKE mcx_movto.sequencia_caixa
                          END RECORD

 DEFINE l_mensagem         CHAR(100),
        l_tot_reg          SMALLINT,
        l_qtd_lancamentos  SMALLINT,
        l_qtd_aen          SMALLINT,
        l_qtd_reg          SMALLINT,
        l_qtd_array        SMALLINT,
        l_plano_contas     RECORD LIKE plano_contas.*

 SELECT den_empresa
   INTO m_den_empresa
   FROM empresa
  WHERE cod_empresa = p_cod_empresa

 IF p_ies_impressao = 'S' THEN
    IF g_ies_ambiente = 'U' THEN
       START REPORT geo1018_relat TO PIPE p_nom_arquivo
    ELSE
       CALL log150_procura_caminho('LST') RETURNING p_caminho
       LET p_caminho = p_caminho CLIPPED, 'geo1018.tmp'
       START REPORT geo1018_relat TO p_caminho
    END IF
 ELSE
    START REPORT geo1018_relat TO p_nom_arquivo
 END IF

 LET l_tot_reg   = 0
 LET l_qtd_array = 0

 MESSAGE 'Processando a extração do relatório ... ' ATTRIBUTE(REVERSE)

 DECLARE cl_caixa CURSOR FOR
  SELECT tip_operacao, operacao, docum, val_docum, hist_movto, sequencia_caixa
    FROM mcx_movto a
   WHERE empresa   = p_cod_empresa
     AND caixa     = mr_tela.caixa
     AND dat_movto = mr_tela.dat_movto
   ORDER BY caixa, dat_movto, sequencia_caixa

 FOREACH cl_caixa INTO lr_relat.tip_operacao, lr_relat.operacao,
                       lr_relat.docum, lr_relat.val_docum,
                       lr_relat.hist_movto, lr_relat.sequencia_caixa

     WHENEVER ERROR CONTINUE
      SELECT des_operacao
        INTO lr_relat.des_operacao
        FROM mcx_operacao_caixa
       WHERE empresa  = p_cod_empresa
         AND operacao = lr_relat.operacao
     WHENEVER ERROR STOP

     IF SQLCA.sqlcode <> 0 THEN
        LET lr_relat.des_operacao = NULL
     END IF

     WHENEVER ERROR CONTINUE
     SELECT COUNT(*)
       INTO l_qtd_lancamentos
       FROM mcx_lancto_contab
      WHERE empresa   = p_cod_empresa
        AND caixa     = mr_tela.caixa
        AND dat_movto = mr_tela.dat_movto
       AND sequencia_caixa = lr_relat.sequencia_caixa
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_qtd_aen
        FROM mcx_aen_4
       WHERE empresa    = p_cod_empresa
         AND caixa      = mr_tela.caixa
         AND dat_lancto = mr_tela.dat_movto
         AND sequencia_caixa = lr_relat.sequencia_caixa
     WHENEVER ERROR STOP

     LET l_qtd_array = l_qtd_array + 1

     IF l_qtd_lancamentos > l_qtd_aen THEN
        CALL geo1018_carrega_lanc(lr_relat.sequencia_caixa, l_qtd_array)
        CALL geo1018_carrega_aen(lr_relat.sequencia_caixa, l_qtd_array)
     ELSE
        CALL geo1018_carrega_aen(lr_relat.sequencia_caixa, l_qtd_array)
        CALL geo1018_carrega_lanc(lr_relat.sequencia_caixa, l_qtd_array)
     END IF

     IF l_qtd_lancamentos > l_qtd_aen THEN
        LET l_qtd_reg = l_qtd_lancamentos
     ELSE
        LET l_qtd_reg = l_qtd_aen
     END IF

     OUTPUT TO REPORT geo1018_relat(lr_relat.*, l_qtd_reg)
     LET l_tot_reg = l_tot_reg + 1

 END FOREACH

 FINISH REPORT geo1018_relat

 IF  g_ies_ambiente = 'W' AND  p_ies_impressao = 'S'  THEN
     LET m_comando = 'lpdos.bat ', p_caminho CLIPPED, ' ', p_nom_arquivo CLIPPED
     RUN m_comando
 END IF

 IF l_tot_reg > 0 THEN
    IF p_ies_impressao = 'S' THEN
       CALL log0030_mensagem('Relatório gravado com sucesso','info')
    ELSE
       LET  l_mensagem = 'Relatório gravado no arquivo ',p_nom_arquivo CLIPPED
       CALL log0030_mensagem(l_mensagem,'info')
    END IF
 ELSE
    INITIALIZE lr_relat.* TO NULL
    CALL log0030_mensagem('Não existem dados para serem listados. ' ,'info')
 END IF

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION geo1018_carrega_lanc(l_sequencia_caixa, l_qtd_array)
#-------------------------------------------------------------#
 DEFINE l_sequencia_caixa     LIKE mcx_movto.sequencia_caixa,
        l_seq_lancto          LIKE mcx_lancto_contab.sequencia_lancto,
        l_qtd_array           SMALLINT

 DECLARE cl_lanc_cont CURSOR FOR
 SELECT conta_contab, tip_lancto, sequencia_lancto
   FROM mcx_lancto_contab
  WHERE empresa   = p_cod_empresa
    AND caixa     = mr_tela.caixa
    AND dat_movto = mr_tela.dat_movto
    AND sequencia_caixa = l_sequencia_caixa
  ORDER BY sequencia_lancto

 FOREACH cl_lanc_cont INTO ma_relat[l_qtd_array].num_conta_cont,
                           ma_relat[l_qtd_array].tip_lancto,
                           l_seq_lancto

     LET ma_relat[l_qtd_array].qtd_informacao = l_qtd_array
     LET l_qtd_array = l_qtd_array + 1

 END FOREACH

 END FUNCTION

#-------------------------------------------------------#
 FUNCTION geo1018_carrega_aen(l_sequencia_caixa, l_qtd_array)
#-------------------------------------------------------#
 DEFINE l_sequencia_caixa   LIKE mcx_movto.sequencia_caixa,
        l_seq_aen           LIKE mcx_aen_4.sequencia_aen,
        l_qtd_array         SMALLINT

 DECLARE cl_aen_4 CURSOR FOR
 SELECT linha_produto, linha_receita, segmto_mercado, classe_uso, sequencia_aen
   FROM mcx_aen_4
  WHERE empresa    = p_cod_empresa
    AND caixa      = mr_tela.caixa
    AND dat_lancto = mr_tela.dat_movto
    AND sequencia_caixa = l_sequencia_caixa
  ORDER BY sequencia_aen

 FOREACH cl_aen_4 INTO ma_relat[l_qtd_array].linha_produto,
                       ma_relat[l_qtd_array].linha_receita,
                       ma_relat[l_qtd_array].segmto_mercado,
                       ma_relat[l_qtd_array].classe_uso,
                       l_seq_aen

     LET ma_relat[l_qtd_array].qtd_informacao = l_qtd_array
     LET l_qtd_array = l_qtd_array + 1

 END FOREACH

 END FUNCTION

#-----------------------------------------#
 REPORT geo1018_relat(lr_relat, l_qtd_reg)
#-----------------------------------------#
 DEFINE lr_relat          RECORD
                             tip_operacao    LIKE mcx_operacao_caixa.tip_operacao,
                             operacao        LIKE mcx_operacao_caixa.operacao,
                             des_operacao    LIKE mcx_operacao_caixa.des_operacao,
                             docum           LIKE mcx_movto.docum,
                             val_docum       LIKE mcx_movto.val_docum,
                             hist_movto      LIKE mcx_movto.hist_movto,
                             sequencia_caixa LIKE mcx_movto.sequencia_caixa
                          END RECORD

 DEFINE l_last_row        SMALLINT,
        l_qtd_reg         SMALLINT,
        l_cont            SMALLINT

 OUTPUT
      LEFT MARGIN 0
      TOP MARGIN 0
      BOTTOM MARGIN 1

 FORMAT
     PAGE HEADER
       PRINT log5211_retorna_configuracao(PAGENO,66,142) CLIPPED;
       PRINT COLUMN 001, m_den_empresa
       PRINT COLUMN 001, 'geo1018',
             COLUMN 044, 'RELATORIO DAS MOVIMENTACOES DE CAIXA (ENTRADAS/SAIDAS)',
             COLUMN 133, 'FL. ', PAGENO USING '####'
       PRINT COLUMN 102, 'EXTRAIDO EM ', TODAY USING 'dd/mm/yyyy', ' AS ', TIME, ' HRS.'
       SKIP 1 LINE
       PRINT COLUMN 006, "CAIXA: ", mr_tela.caixa USING "##&", " - ", mr_tela.des_caixa
       PRINT COLUMN 001, "DATA MOVTO: ",mr_tela.dat_movto
       SKIP 1 LINE
       PRINT COLUMN 001, "E/S OPERACAO                   DOCUMENTO       VALOR DOCUMENTO  HISTORICO                      SEQ   D/C CONTA CONTABIL          AEN"
       PRINT COLUMN 001, "--- -------------------------- --------------- ---------------- ------------------------------ ----- --- ----------------------- -----------"

     ON EVERY ROW
       NEED 3 LINES
       PRINT COLUMN 002, lr_relat.tip_operacao,
             COLUMN 005, lr_relat.operacao          USING "####&", " ",
                         lr_relat.des_operacao[1,20],
             COLUMN 032, lr_relat.docum,
             COLUMN 048, lr_relat.val_docum         USING "############&.&&",
             COLUMN 065, lr_relat.hist_movto[1,30],
             COLUMN 096, lr_relat.sequencia_caixa   USING "####&",
             COLUMN 103, ma_relat[1].tip_lancto,
             COLUMN 106, ma_relat[1].num_conta_cont,
             COLUMN 130, ma_relat[1].linha_produto  USING "#&",
             COLUMN 133, ma_relat[1].linha_receita  USING "#&",
             COLUMN 136, ma_relat[1].segmto_mercado USING "#&",
             COLUMN 139, ma_relat[1].classe_uso     USING "#&"

       FOR l_cont = 2 TO l_qtd_reg
           IF ma_relat[l_cont].qtd_informacao IS NOT NULL THEN
              PRINT COLUMN 103, ma_relat[l_cont].tip_lancto,
                    COLUMN 106, ma_relat[l_cont].num_conta_cont,
                    COLUMN 130, ma_relat[l_cont].linha_produto  USING "#&",
                    COLUMN 133, ma_relat[l_cont].linha_receita  USING "#&",
                    COLUMN 136, ma_relat[l_cont].segmto_mercado USING "#&",
                    COLUMN 139, ma_relat[l_cont].classe_uso     USING "#&"
           END IF
       END FOR
       SKIP 1 LINE

     ON LAST ROW
       LET l_last_row = TRUE

     PAGE TRAILER
       IF l_last_row = TRUE THEN
          PRINT '* * * ULTIMA FOLHA * * *',
                log5211_termino_impressao() CLIPPED
       ELSE
          PRINT ' '
       END IF

END REPORT

#OS 513834 ------------------------------#
 FUNCTION geo1018_busca_dt_proc_che_mcx()
#----------------------------------------#
 DEFINE l_par_data_che LIKE par_che_pad.par_data

    WHENEVER ERROR CONTINUE
      SELECT par_data
        INTO l_par_data_che
        FROM par_che_pad
       WHERE cod_empresa = p_cod_empresa
         AND cod_parametro = "dat_process_che"
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       LET l_par_data_che = TODAY
    END IF

    RETURN l_par_data_che

 END FUNCTION

#OS 513834 ---------------------------------#
 FUNCTION geo1018_valida_dt_proc_che_mcx()
#-------------------------------------------#
 DEFINE l_par_data_che LIKE par_che_pad.par_data

    WHENEVER ERROR CONTINUE
      SELECT par_data
        INTO l_par_data_che
        FROM par_che_pad
       WHERE cod_empresa = p_cod_empresa
         AND cod_parametro = "dat_process_che"
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       RETURN TRUE
    END IF

    IF l_par_data_che <> mr_tela.dat_movto THEN
       RETURN FALSE
    END IF

    RETURN TRUE

 END FUNCTION

#-------------------------------------------#
 FUNCTION geo1018_mcx_hist_contabil_existe()
#-------------------------------------------#
  INITIALIZE m_formula_hist_compl TO NULL

  WHENEVER ERROR CONTINUE
  SELECT formula_hist_compl
    INTO m_formula_hist_compl
    FROM mcx_hist_contabil
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0   AND
     sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("SELECT","MCX_HIST_CONTABIL")
  END IF

  IF m_formula_hist_compl IS NULL OR
     m_formula_hist_compl = " "   THEN
     RETURN FALSE
  END IF

  RETURN TRUE
 END FUNCTION

#---------------------------#
 FUNCTION geo1018_ext_hist()
#---------------------------#
  DEFINE l_ext_hist     CHAR(050),
         l_ext_hist_aux CHAR(200),
         l_codigo       CHAR(100),
         l_codigo_decif CHAR(050),
         l_tam          SMALLINT,
         l_ind          SMALLINT,
         l_pos_ant      SMALLINT,
         l_modulo       CHAR(004),
         l_status       SMALLINT

  INITIALIZE l_ext_hist,
             l_ext_hist_aux,
             l_modulo TO NULL

  LET l_tam     = LENGTH(m_formula_hist_compl)
  LET l_status  = FALSE
  LET l_pos_ant = 0

  FOR l_ind = 1 TO l_tam
     IF m_formula_hist_compl[l_ind] <> "@" THEN
        IF NOT l_status THEN
           IF m_formula_hist_compl[l_ind] = " " AND l_pos_ant = 0 THEN
              LET l_ext_hist_aux = l_ext_hist_aux CLIPPED, m_formula_hist_compl[l_ind]
              LET l_pos_ant = 1
           END IF

           IF m_formula_hist_compl[l_ind] <> " " AND l_pos_ant = 0 THEN
              LET l_ext_hist_aux = l_ext_hist_aux CLIPPED, m_formula_hist_compl[l_ind]
           END IF

           IF m_formula_hist_compl[l_ind] <> " " AND l_pos_ant = 1 THEN
              LET l_ext_hist_aux = l_ext_hist_aux CLIPPED, " ", m_formula_hist_compl[l_ind]
              LET l_pos_ant = 0
           END IF
        ELSE
           LET l_ext_hist_aux = l_ext_hist_aux CLIPPED, " ", m_formula_hist_compl[l_ind]
           LET l_status = FALSE

           IF m_formula_hist_compl[l_ind] = " " THEN
              LET l_pos_ant = 1
           ELSE
              LET l_pos_ant = 0
           END IF
        END IF
     ELSE
        WHILE TRUE
           IF l_ind = l_tam THEN
              EXIT WHILE
           END IF

           LET l_ind = l_ind + 1

           IF m_formula_hist_compl[l_ind] = " " THEN
              EXIT WHILE
           END IF

           LET l_codigo = l_codigo CLIPPED, m_formula_hist_compl[l_ind]
        END WHILE

        IF l_codigo IS NOT NULL THEN
           IF l_modulo IS NULL THEN
              LET l_modulo = geo1018_verifica_modulo()
           END IF

           LET l_codigo_decif = geo1018_decifra_cod(l_codigo,l_modulo)

           IF l_ext_hist_aux IS NULL THEN
              LET l_ext_hist_aux = l_codigo_decif
           ELSE
              LET l_ext_hist_aux = l_ext_hist_aux CLIPPED, " ", l_codigo_decif
           END IF

           INITIALIZE l_codigo TO NULL
           LET l_status = TRUE
        END IF
     END IF
  END FOR

  LET l_ext_hist = l_ext_hist_aux[01,50]

  RETURN l_ext_hist
 END FUNCTION

#----------------------------------#
 FUNCTION geo1018_verifica_modulo()
#----------------------------------#
  DEFINE l_gera_baixa_docum LIKE mcx_oper_caixa_cap.gera_baixa_docum

  # Verifica se a operacao gera ou baixa CAP
  WHENEVER ERROR CONTINUE
   SELECT gera_baixa_docum
     INTO l_gera_baixa_docum
     FROM mcx_oper_caixa_cap
    WHERE empresa  = p_cod_empresa
      AND operacao = ma_tela[m_arr_curr].operacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     IF l_gera_baixa_docum = "G" THEN
        RETURN "CAP"
     ELSE
        RETURN "CAP1"
     END IF
  END IF

  # Verifica se a operacao gera ou baixa CRE
  WHENEVER ERROR CONTINUE
   SELECT gera_baixa_docum
     INTO l_gera_baixa_docum
     FROM mcx_oper_caixa_cre
    WHERE empresa  = p_cod_empresa
      AND operacao = ma_tela[m_arr_curr].operacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     IF l_gera_baixa_docum = "G" THEN
        RETURN "CRE"
     ELSE
        RETURN "CRE1"
     END IF
  END IF

  # Verifica se a operacao gera SUP
  WHENEVER ERROR CONTINUE
   SELECT gera_pend_sup_autm
     FROM mcx_oper_caixa_sup
    WHERE empresa  = p_cod_empresa
      AND operacao = ma_tela[m_arr_curr].operacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     RETURN "SUP"
  END IF

  # Verifica se a operacao gera TRB
  WHENEVER ERROR CONTINUE
   SELECT empresa
     FROM mcx_oper_caixa_trb
    WHERE empresa  = p_cod_empresa
      AND operacao = ma_tela[m_arr_curr].operacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     RETURN "TRB"
  END IF

  # Verifica se a operacao gera TRANSFERENCIA
  WHENEVER ERROR CONTINUE
   SELECT empresa
     FROM mcx_oper_cx_transf
    WHERE empresa  = p_cod_empresa
      AND operacao = ma_tela[m_arr_curr].operacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     RETURN "TRA"
  END IF

  # Se não atender a nenhuma situacao acima, será uma movimentação normal.
  RETURN "MCX"
 END FUNCTION

#-----------------------------------------------#
 FUNCTION geo1018_decifra_cod(l_codigo,l_modulo)
#-----------------------------------------------#
  DEFINE l_codigo         CHAR(100),
         l_modulo         CHAR(004),
         l_codigo_decif   CHAR(050),
         l_cod_fornecedor CHAR(015),
         l_den_fornecedor CHAR(050),
         l_cod_portador   DECIMAL(4,0),
         l_tip_portador   CHAR(001),
         l_nom_portador   CHAR(036),
         l_cod_cliente    CHAR(015),
         l_nom_cliente    CHAR(036),
         l_cod_repres     DECIMAL(4,0),
         l_raz_social     CHAR(036),
         l_cod_banco      DECIMAL(3,0),
         l_nom_banco      CHAR(030),
         l_cod_agencia    CHAR(006),
         l_cod_agen_bco   DECIMAL(3,0),
         l_conta_bco      CHAR(015),
         l_den_agencia    CHAR(015),
         l_conta_corrente CHAR(015)

  CASE l_codigo
     WHEN "DOCUM"  #Numero do documento
        LET l_codigo_decif = ma_tela[m_arr_curr].docum

     WHEN "FORNEC" #Código do fornecedor
        LET l_cod_fornecedor = geo1018_busca_fornecedor(l_modulo)
        LET l_codigo_decif   = l_cod_fornecedor #CAP/SUP

     WHEN "NOMFOR" #Denominação do fornecedor
        LET l_cod_fornecedor = geo1018_busca_fornecedor(l_modulo)

        WHENEVER ERROR CONTINUE
        SELECT raz_social
          INTO l_den_fornecedor
          FROM fornecedor
         WHERE cod_fornecedor = l_cod_fornecedor
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0   AND
           sqlca.sqlcode <> 100 THEN
           CALL log003_err_sql("SELECT","FORNECEDOR")
        END IF

        LET l_codigo_decif = l_den_fornecedor #CAP/SUP

     WHEN "PORTAD" #Código do portador
        CALL geo1018_busca_portador()
           RETURNING l_cod_portador, l_tip_portador

        LET l_codigo_decif = l_cod_portador #CRE

     WHEN "NOMPOR" #Denominação do portador
        CALL geo1018_busca_portador()
           RETURNING l_cod_portador, l_tip_portador

        WHENEVER ERROR CONTINUE
        SELECT nom_portador
          INTO l_nom_portador
          FROM portador
         WHERE cod_portador     = l_cod_portador
           AND ies_tip_portador = l_tip_portador
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           IF sqlca.sqlcode <> 100 THEN
              CALL log003_err_sql("SELECT","PORTADOR")
           END IF
        END IF

        LET l_codigo_decif = l_nom_portador #CRE

     WHEN "CLIENT" #Código do cliente
        LET l_cod_cliente = geo1018_busca_cliente(l_modulo)

        LET l_codigo_decif = l_cod_cliente #CRE

     WHEN "NOMCLI" #Deniminação do cliente
        LET l_cod_cliente = geo1018_busca_cliente(l_modulo)

        WHENEVER ERROR CONTINUE
        SELECT nom_cliente
          INTO l_nom_cliente
          FROM clientes
         WHERE cod_cliente = l_cod_cliente
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           IF sqlca.sqlcode <> 100 THEN
              CALL log003_err_sql("SELECT","CLIENTES")
           END IF
        END IF

        LET l_codigo_decif = l_nom_cliente #CRE

     WHEN "REPRES" #Código representante
        LET l_cod_repres = geo1018_busca_representante()

        LET l_codigo_decif = l_cod_repres #CRE

     WHEN "NOMREP" #Denominação do representante
        LET l_cod_repres = geo1018_busca_representante()

        WHENEVER ERROR CONTINUE
        SELECT raz_social
          INTO l_raz_social
          FROM representante
         WHERE cod_repres = l_cod_repres
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           IF sqlca.sqlcode <> 100 THEN
              CALL log003_err_sql("SELECT","REPRESENTANTE")
           END IF
        END IF

        LET l_codigo_decif = l_raz_social #CRE

     WHEN "BANCO"  #Código do banco
        CALL geo1018_busca_banco()
           RETURNING l_cod_banco, l_cod_agencia

        LET l_codigo_decif = l_cod_banco #TRB

     WHEN "NOMBAN" #Denominação do banco
        CALL geo1018_busca_banco()
           RETURNING l_cod_banco, l_cod_agencia

        WHENEVER ERROR CONTINUE
        SELECT nom_banco
          INTO l_nom_banco
          FROM bancos
         WHERE cod_banco  = l_cod_banco
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           IF sqlca.sqlcode <> 100 THEN
              CALL log003_err_sql("SELECT","BANCOS")
           END IF
        END IF

        LET l_codigo_decif = l_nom_banco #TRB

     WHEN "AGENCI" #Código da agencia
        CALL geo1018_busca_banco()
           RETURNING l_cod_banco, l_cod_agencia

        WHENEVER ERROR CONTINUE
        SELECT agencia
          INTO l_cod_agencia
          FROM mcx_oper_caixa_trb
         WHERE empresa  = p_cod_empresa
           AND operacao = ma_tela[m_arr_curr].operacao
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           IF sqlca.sqlcode <> 100 THEN
              CALL log003_err_sql("SELECT","MCX_OPER_CAIXA_TRB")
           END IF
        END IF

        LET l_codigo_decif = l_cod_agencia #TRB

     WHEN "NOMAGE" #Denominação da agencia
        CALL geo1018_busca_banco()
           RETURNING l_cod_banco, l_cod_agencia

        WHENEVER ERROR CONTINUE
        DECLARE cq_agencias CURSOR FOR
        SELECT cod_agen_bco
          FROM agencia_bco
         WHERE cod_banco   = l_cod_banco
           AND num_agencia = l_cod_agencia
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("DECLARE","CQ_AGENCIAS")
        END IF

        WHENEVER ERROR CONTINUE
        OPEN cq_agencias
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("OPEN","CQ_AGENCIAS")
        END IF

        WHENEVER ERROR CONTINUE
        FETCH cq_agencias INTO l_cod_agen_bco
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0    AND
           sqlca.sqlcode <> 100 THEN
           CALL log003_err_sql("FETCH","CQ_AGENCIAS")
        END IF

        WHILE sqlca.sqlcode = 0
           WHENEVER ERROR CONTINUE
           DECLARE cq_contas CURSOR FOR
           SELECT num_conta_banc
             FROM agencia_bc_item
            WHERE cod_empresa  = p_cod_empresa
              AND cod_agen_bco = l_cod_agen_bco
            ORDER BY num_conta_banc DESC
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","CQ_CONTAS")
           END IF

           WHENEVER ERROR CONTINUE
           OPEN cq_contas
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("OPEN","CQ_CONTAS")
           END IF

           WHENEVER ERROR CONTINUE
           FETCH cq_contas INTO l_conta_bco
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0   AND
              sqlca.sqlcode <> 100 THEN
              CALL log003_err_sql("FETCH","CQ_CONTAS")
           END IF

           IF sqlca.sqlcode = 0 THEN
              CLOSE cq_contas
              WHENEVER ERROR CONTINUE
              SELECT nom_agencia
                INTO l_den_agencia
                FROM agencia_bco
               WHERE cod_agen_bco = l_cod_agen_bco
                 AND cod_banco    = l_cod_banco
                 AND num_agencia  = l_cod_agencia
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 LET l_den_agencia = "  "
              END IF

              EXIT WHILE
           ELSE
              WHENEVER ERROR CONTINUE
              FETCH cq_agencias INTO l_cod_agen_bco
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0   AND
                 sqlca.sqlcode <> 100 THEN
                 CALL log003_err_sql("FETCH","CQ_AGENCIAS")
                 EXIT WHILE
              END IF
           END IF
        END WHILE
        CLOSE cq_agencias

        IF l_conta_bco IS NULL THEN
           RETURN FALSE
        ELSE
           RETURN TRUE
        END IF

        LET l_codigo_decif = l_den_agencia #TRB

     WHEN "CONTA"  #Conta corrente
        WHENEVER ERROR CONTINUE
        SELECT conta_banco
          INTO l_conta_corrente
          FROM mcx_oper_caixa_trb
         WHERE empresa  = p_cod_empresa
           AND operacao = ma_tela[m_arr_curr].operacao
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0   AND
           sqlca.sqlcode <> 100 THEN
           CALL log003_err_sql("SELECT","MCX_OPER_CAIXA_TRB")
        END IF

        LET l_codigo_decif = l_conta_corrente #TRB
  END CASE

  RETURN l_codigo_decif
 END FUNCTION

#-------------------------------------------#
 FUNCTION geo1018_busca_fornecedor(l_modulo)
#-------------------------------------------#
  DEFINE l_modulo         CHAR(04),
         l_cod_fornecedor CHAR(15)

  INITIALIZE l_cod_fornecedor TO NULL

  CASE l_modulo
     WHEN "CAP"
        WHENEVER ERROR CONTINUE
        SELECT fornecedor
          INTO l_cod_fornecedor
          FROM mcx_movto_gera_cap
         WHERE empresa         = p_cod_empresa
           AND caixa           = mr_tela.caixa
           AND dat_movto       = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0   AND
           sqlca.sqlcode <> 100 THEN
           CALL log003_err_sql("SELECT","MCX_MOVTO_GERA_CAP")
        END IF
     WHEN "CAP1"
        WHENEVER ERROR CONTINUE
        SELECT a.cod_fornecedor
          INTO l_cod_fornecedor
          FROM mcx_mov_baixa_cap m,
               ap a
         WHERE m.empresa          = p_cod_empresa
           AND m.caixa            = mr_tela.caixa
           AND m.dat_movto        = mr_tela.dat_movto
           AND m.sequencia_caixa  = ma_tela[m_arr_curr].sequencia_caixa
           AND a.cod_empresa      = m.empresa_destino
           AND a.num_ap           = m.autoriz_pagto
           AND a.ies_versao_atual = 'S'
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0   AND
           sqlca.sqlcode <> 100 THEN
           CALL log003_err_sql("SELECT","AP")
        END IF
     WHEN "SUP"
        WHENEVER ERROR CONTINUE
        SELECT fornecedor
          INTO l_cod_fornecedor
          FROM mcx_movto_sup
         WHERE empresa         = p_cod_empresa
           AND caixa           = mr_tela.caixa
           AND dat_movto       = mr_tela.dat_movto
           AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0   AND
           sqlca.sqlcode <> 100 THEN
           CALL log003_err_sql("SELECT","MCX_MOVTO_SUP")
        END IF
  END CASE

  RETURN l_cod_fornecedor

 END FUNCTION

#---------------------------------#
 FUNCTION geo1018_busca_portador()
#---------------------------------#
  DEFINE l_cod_portador   DECIMAL(4,0),
         l_tip_portador   CHAR(001)

  WHENEVER ERROR CONTINUE
  SELECT portador_cre,
         tip_portador_cre
    INTO l_cod_portador,
         l_tip_portador
    FROM mcx_oper_caixa_cre
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("SELECT","MCX_OPER_CAIXA_CRE")
     END IF
  END IF

  RETURN l_cod_portador, l_tip_portador
 END FUNCTION

#----------------------------------------#
 FUNCTION geo1018_busca_cliente(l_modulo)
#----------------------------------------#
  DEFINE l_modulo      CHAR(004),
         l_cod_cliente CHAR(015)

  IF l_modulo = "CRE1" THEN
     WHENEVER ERROR CONTINUE
     SELECT cliente
       INTO l_cod_cliente
       FROM mcx_mov_baixa_cre
      WHERE empresa         = p_cod_empresa
        AND caixa           = mr_tela.caixa
        AND dat_movto       = mr_tela.dat_movto
        AND sequencia_caixa = ma_tela[m_arr_curr].sequencia_caixa
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        IF sqlca.sqlcode <> 100 THEN
           CALL log003_err_sql("SELECT","MCX_MOV_BAIXA_CRE")
        END IF
     END IF
  ELSE
     WHENEVER ERROR CONTINUE
     SELECT cliente_cre
       INTO l_cod_cliente
       FROM mcx_oper_caixa_cre
      WHERE empresa  = p_cod_empresa
        AND operacao = ma_tela[m_arr_curr].operacao
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        IF sqlca.sqlcode <> 100 THEN
           CALL log003_err_sql("SELECT","MCX_OPER_CAIXA_CRE")
        END IF
     END IF
  END IF

  RETURN l_cod_cliente
 END FUNCTION

#--------------------------------------#
 FUNCTION geo1018_busca_representante()
#--------------------------------------#
  DEFINE l_cod_repres DECIMAL(4,0)

  WHENEVER ERROR CONTINUE
  SELECT representante_cre
    INTO l_cod_repres
    FROM mcx_oper_caixa_cre
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("SELECT","MCX_OPER_CAIXA_CRE")
     END IF
  END IF

  RETURN l_cod_repres
 END FUNCTION

#------------------------------#
 FUNCTION geo1018_busca_banco()
#------------------------------#
  DEFINE l_cod_banco   DECIMAL(3,0),
         l_cod_agencia CHAR(006)

  WHENEVER ERROR CONTINUE
  SELECT banco,
         agencia
    INTO l_cod_banco,
         l_cod_agencia
    FROM mcx_oper_caixa_trb
   WHERE empresa  = p_cod_empresa
     AND operacao = ma_tela[m_arr_curr].operacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("SELECT","MCX_OPER_CAIXA_CRE")
     END IF
  END IF

  RETURN l_cod_banco, l_cod_agencia
 END FUNCTION

#-------------------------------#
 FUNCTION geo1018_version_info()
#-------------------------------#
  RETURN "$Archive: /logix10R2/financeiro/controle_movimento_caixa/programas/geo1018.4gl $|$Revision: 8 $|$Date: 16/04/10 14:47 $|$Modtime: 15/04/10 14:22 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION

