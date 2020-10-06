###PARSER-Não remover esta linha(Framework Logix)###
#------------------------------------------------------------------------------#
# SISTEMA.: CONTAS A RECEBER                                                   #
# OBJETIVO: IMPRESSÃO DE BOLETOS LASER                                         #
# AUTOR(A): MARCOS HEYSE PEREIRA                                               #
# DATA....: 08/08/2007                                                         #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa                  LIKE empresa.cod_empresa,
          p_user                         LIKE usuario.nom_usuario,
          p_versao                       CHAR(18) #Favor não alterar esta linha (SUPORTE)

   DEFINE p_ies_impressao                CHAR(01),
          p_nom_arquivo                  CHAR(100)

   DEFINE g_ies_ambiente                 CHAR(01),
          g_ies_grafico                  SMALLINT

   DEFINE gr_par_bloq_laser              RECORD LIKE par_bloqueto_laser.*,
          gr_par_bloqueto                 RECORD LIKE par_bloqueto_laser.*,
          gr_nf_bloqueto                  RECORD LIKE nf_bloqueto.*

   DEFINE gr_relat                       RECORD
           cod_cliente                    LIKE clientes.cod_cliente,
           nom_banco                      CHAR(30),
           cod_banco                      CHAR(05),
           den_empresa                    CHAR(36),
           cod_agencia                    CHAR(06),
           cod_cedente                    CHAR(15),
           dat_vencto                     DATE,
           cod_carteira                   CHAR(06),
           nosso_numero                   CHAR(20),
           dat_emissao                    DATE,
           dat_proces                     DATE,
           num_docum                      CHAR(14),
           esp_docum                      CHAR(08),
           cod_aceite                     CHAR(05),
           val_docum                      DECIMAL(16,2),
           esp_moeda                      CHAR(10),
           nom_cliente                    CHAR(36),
           end_cliente                    CHAR(36),
           den_bairro                     CHAR(20),
           cod_cep                        CHAR(09),
           den_cidade                     CHAR(30),
           cod_uni_feder                  CHAR(02),
           num_cgc_cpf                    CHAR(19),
           loc_pgto_1                     CHAR(60),
           loc_pgto_2                     CHAR(60),
           instrucoes1                    CHAR(65),
           instrucoes2                    CHAR(65),
           instrucoes3                    CHAR(65),
           instrucoes4                    CHAR(65),
           instrucoes5                    CHAR(65),
           instrucoes6                    CHAR(65),
           txt_barras                     CHAR(54),
           cod_barras                     CHAR(44),
           out_deducoes                   DECIMAL(16,2)
                                         END RECORD

   DEFINE p_relat                        RECORD
           cod_cliente                    LIKE clientes.cod_cliente,
           nom_banco                      CHAR(30),
           cod_banco                      CHAR(05),
           den_empresa                    CHAR(36),
           cod_agencia                    CHAR(06),
           cod_cedente                    CHAR(15),
           dat_vencto                     DATE,
           cod_carteira                   CHAR(06),
           nosso_numero                   CHAR(20),
           dat_emissao                    DATE,
           dat_proces                     DATE,
           num_docum                      CHAR(14),
           esp_docum                      CHAR(08),
           cod_aceite                     CHAR(05),
           val_docum                      DECIMAL(16,2),
           esp_moeda                      CHAR(10),
           nom_cliente                    CHAR(36),
           end_cliente                    CHAR(36),
           den_bairro                     CHAR(20),
           cod_cep                        CHAR(09),
           den_cidade                     CHAR(30),
           cod_uni_feder                  CHAR(02),
           num_cgc_cpf                    CHAR(19),
           loc_pgto_1                     CHAR(60),
           loc_pgto_2                     CHAR(60),
           instrucoes1                    CHAR(74),
           instrucoes2                    CHAR(74),
           instrucoes3                    CHAR(74),
           instrucoes4                    CHAR(74),
           instrucoes5                    CHAR(74),
           instrucoes6                    CHAR(74),
           txt_barras                     CHAR(54),
           cod_barras                     CHAR(44),
           out_deducoes                   DECIMAL(16,2)
                                         END RECORD

   DEFINE g_cod_cliente_j_safra          LIKE par_escritural.idn_emp_header,
          g_numero_convenio              CHAR(07),
          g_novo_numero                  CHAR(20),
          g_cod_carteira                 CHAR(02),
          g_reimpressao                  SMALLINT



END GLOBALS

#MODULARES

   DEFINE m_caminho                     CHAR(250),
          m_comando                     CHAR(250)

   DEFINE m_cod_programa                CHAR(07)

   DEFINE m_status                      SMALLINT,
          m_cont                        SMALLINT,
          m_concorr_reprocessar         SMALLINT

   DEFINE mr_tela                       RECORD
           cod_empresa_padrao            CHAR(02),
           ies_empresa                   CHAR(01),
           ies_empresa_fat               CHAR(01),
           ies_cliente                   CHAR(01),
           ies_nota_fiscal               CHAR(01),
           ies_tip_docum                 CHAR(01),
           ies_tip_cobr                  CHAR(01),
           ies_docum                     CHAR(01),
           ies_docum_ini                 CHAR(14),
           ies_docum_fim                 CHAR(14),
           ies_emis                      CHAR(01),
           dat_emis_ini                  DATE,
           dat_emis_fim                  DATE,
           ies_vencto                    CHAR(01),
           dat_vencto_ini                DATE,
           dat_vencto_fim                DATE,
           ies_com_port                  CHAR(01),
           ies_com_port_todos_port       CHAR(01),
           ies_sem_port                  CHAR(01),
           ies_sem_port_tipo_emis        CHAR(01),
           portador_determ               INTEGER
                                        END RECORD

   DEFINE mr_param                      RECORD
            origem                         CHAR(02),
            empresa                        LIKE empresa.cod_empresa,
            portador                       LIKE portador.cod_portador,
            tip_nota_fiscal                LIKE fat_nf_mestre.tip_nota_fiscal,
            serie_nota_fiscal              LIKE fat_nf_mestre.serie_nota_fiscal,
            nota_fiscal_ini                LIKE fat_nf_mestre.nota_fiscal,
            nota_fiscal_fim                LIKE fat_nf_mestre.nota_fiscal,
            instrucoes_1                   CHAR(60),
            instrucoes_2                   CHAR(60),
            instrucoes_3                   CHAR(60),
            instrucoes_4                   CHAR(60),
            instrucoes_5                   CHAR(60),
            instrucoes_6                   CHAR(60)
                                        END RECORD

   DEFINE mr_docum                      RECORD LIKE docum.*,
          mr_dados_cliente              RECORD LIKE clientes.*,
          mr_docum_banco                RECORD LIKE docum_banco.*,
          mr_empresa_cre_txt            RECORD LIKE empresa_cre_txt.*,
          mr_cre_tit_cob_esp            RECORD LIKE cre_tit_cob_esp.*

   DEFINE mr_nota                       RECORD
            trans_nota_fiscal              LIKE fat_nf_duplicata.trans_nota_fiscal,
            seq_duplicata                  LIKE fat_nf_duplicata.seq_duplicata
                                        END RECORD

   DEFINE m_origem_duplicata            CHAR(02)

   DEFINE m_dat_proces_doc              LIKE par_cre.dat_proces_doc,
          m_empresa_anterior            LIKE docum.cod_empresa,
          m_cod_empresa_matr            LIKE empresa_consol.cod_empresa,
          m_val_outras_deducoes         LIKE docum.val_saldo,
          m_num_docum_origem            LIKE docum.num_docum_origem

   DEFINE m_portador                    LIKE portador.cod_portador,
          m_portador_impressao          LIKE portador.cod_portador,
          m_val_boleto                  LIKE docum.val_bruto,
          m_pct_juro_mora               LIKE juro_mora.pct_juro_mora

   DEFINE m_ies_protesto                CHAR(01),
          m_qtd_dias_protesto           CHAR(02),
          m_portador_char               CHAR(04),
          m_cedente                     CHAR(70)

   DEFINE m_val_desc                    DECIMAL(11,2),
          m_val_juro_mora               DECIMAL(11,2),
          m_pct_juro_mora_aux           DECIMAL(9,6),
          m_pct_juro_mora_nc            DECIMAL(9,6),
          m_val_max_bol                 DECIMAL(15,2),
          m_pct_desc_financ             LIKE adocum.pct_desc

   DEFINE m_dat_aux                     DATE

   DEFINE m_boleto_cond_pre_datado      CHAR(01),
          m_boleto_cond_contra_partida  CHAR(01),
          m_tem_par_boleto_port         CHAR(01),
          m_verifica_cep                CHAR(01),
          m_selec_nf_bloq_x_portador    CHAR(01),
          m_imp_bloq_end_cob            CHAR(01),
          m_nr_bloq_empresa_consol      CHAR(01),
          m_empresa_ctrl_cre            CHAR(02),
          m_ies_reimp_bloq              CHAR(01),
          m_layout_santander            CHAR(01),
          m_qtd_dias_emis_bloq          SMALLINT

   DEFINE m_emitiu                      SMALLINT,
          m_imprime_boleto              SMALLINT,
          m_empresa_mudou               SMALLINT

   DEFINE ma_doc_orig_unico ARRAY[999] OF RECORD
          emp_nota_fiscal                 LIKE cre_nf_orig_docum.emp_nota_fiscal,
          tip_nota_fiscal                 LIKE cre_nf_orig_docum.tip_nota_fiscal,
          nota_fiscal                     LIKE cre_nf_orig_docum.nota_fiscal,
          serie_nota_fiscal               LIKE cre_nf_orig_docum.serie_nota_fiscal,
          subserie_nf                     LIKE cre_nf_orig_docum.subserie_nf
                                        END RECORD
   DEFINE m_nota_fiscal                 SMALLINT,
          m_existe_nota                 SMALLINT

   DEFINE m_codigo_cip                  CHAR(03)
   DEFINE m_par_clientes_cre_txt        LIKE clientes_cre_txt.parametro
   DEFINE m_sacador_avalista            CHAR(70)

   DEFINE m_empresa_menu_217            CHAR(01),
          m_vendor_sem_contrato         SMALLINT

   DEFINE m_imprime_desp_fin            CHAR(01),
          m_antecipacao_pedido          CHAR(01),
          m_param_nf                    CHAR(500),
          m_titulo_bancario             LIKE ped_blqt_antecip.num_titulo_banco

   DEFINE m_dv_verificador              INTEGER,
          m_num_pedido                  LIKE pedidos.num_pedido

   DEFINE m_imprimir_endereco_cnpj_boleto   CHAR(01),
          m_qtd_vias                        CHAR(01)

   DEFINE m_consdr_cli_nao_protes CHAR(01)

   DEFINE mr_empresa    RECORD
                          end_empresa        LIKE empresa.end_empresa,
                          den_munic          LIKE empresa.den_munic,
                          den_bairro         LIKE empresa.den_bairro,
                          uni_feder          LIKE empresa.uni_feder,
                          cod_cep            LIKE empresa.cod_cep,
                          num_cgc            LIKE empresa.num_cgc
                        END RECORD

#::: TRATAMENTO DE EPL'S GOLDEN e EXATA :::#
 DEFINE m_especifico  SMALLINT #::: Define se será executado uma rotina especifica.
 DEFINE m_cod_cliente CHAR(04) #::: Código do cliente que o programa esta sendo executado.
 DEFINE m_formato     CHAR(01) #::: Formato da impressao se estiver L, o programa será executado normalmente.
 DEFINE m_envia_email SMALLINT
   #Ch. 751379
   DEFINE m_portador_correspondente CHAR(04),
          m_portador_original       CHAR(04),
          m_imprime_cedente         CHAR(01),
          m_imprime_sacador         CHAR(01)
   #Fim Ch. 751379

#END MODULARES

MAIN

  CALL geo1015_main()
  
END MAIN

#------------------------------#
FUNCTION geo1015_main()
#------------------------------#
   CALL fgl_setenv("VERSION_INFO","L10-geo1015-10.02.$Revision: 73 $p") #Informacao da versao do programa controlado pelo SourceSafe - Nao remover esta linha.
   LET p_versao = 'geo1015-10.02.28p'

   CALL log0180_conecta_usuario()

   CALL log1400_isolation()

   WHENEVER ERROR CONTINUE
   SET LOCK MODE TO WAIT
   WHENEVER ERROR STOP

   DEFER INTERRUPT

   #CALL log001_acessa_usuario('CRECEBER','LOGERP')
   #     RETURNING m_status,p_cod_empresa,p_user
   LET m_status = 0
   #IF m_status = 0 THEN
      CALL geo1015_executa()
   #END IF


END FUNCTION

#---------------------------#
FUNCTION geo1015_executa()
#---------------------------#
   
   IF NOT geo1015_busca_parametros() THEN
      RETURN
   END IF

   CALL geo1015_cria_w_nota_fiscal()
   LET p_user = 'admlog'
   
   LET mr_param.origem            = log1200_parametro_programa_le(1,0)
   LET mr_param.empresa           = log1200_parametro_programa_le(2,0)
   LET mr_param.portador          = log1200_parametro_programa_le(3,0)
   LET mr_param.tip_nota_fiscal   = log1200_parametro_programa_le(4,0)
   LET mr_param.serie_nota_fiscal = log1200_parametro_programa_le(5,0)
   LET mr_param.nota_fiscal_ini   = log1200_parametro_programa_le(6,0)
   LET mr_param.nota_fiscal_fim   = log1200_parametro_programa_le(7,0)
   
   LET p_cod_empresa = mr_param.empresa
   
   
   INSERT INTO geo_audit VALUES (p_cod_empresa, 'geo1015',CURRENT,p_user)
   
   WHENEVER ERROR CONTINUE
     #DELETE FROM tran_arg
     # WHERE cod_empresa   = p_cod_empresa
     #   AND num_programa  = 'geo1015'
     #   AND login_usuario = p_user
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('DELETE','tran_arg')
   END IF
   
   IF geo1015_informa_dados() THEN
       #initialize mr_param.* to null
       CALL geo1015_imprime_boleto()
   END IF

END FUNCTION

#----------------------------#
 FUNCTION geo1015_controle()
#----------------------------#

 DEFINE l_tela          CHAR(100),
        l_acabou        CHAR(01),
        l_parametro_1   CHAR(10)

   IF NOT geo1015_busca_parametros() THEN
      RETURN
   END IF

   CALL geo1015_cria_w_nota_fiscal()

   CALL geo1015_busca_tran_arg()

   IF mr_param.origem = 'NF' THEN {Não deve abrir tela de input do geo1015}
      IF log_existe_epl('geo1015y_cria_temp')THEN # CLIENTE CERAMFIX

         CALL geo1015y_cria_temp()

         CALL log_setvar("parametro_1",mr_param.origem)
         CALL log_setvar("origem",mr_param.origem)
         CALL log_setvar("empresa",mr_param.empresa)
         CALL log_setvar("portador",mr_param.portador)
         CALL log_setvar("tip_nota_fiscal",mr_param.tip_nota_fiscal)
         CALL log_setvar("serie_nota_fiscal",mr_param.serie_nota_fiscal)
         CALL log_setvar("nota_fiscal_ini",mr_param.nota_fiscal_ini)# pegar ini e fim e receber todas nesse intervalo na temporaria
         CALL log_setvar("nota_fiscal_fim",mr_param.nota_fiscal_fim)
         CALL log_setvar("instrucoes_2",mr_param.instrucoes_2)
         CALL log_setvar("instrucoes_3",mr_param.instrucoes_3)
         CALL log_setvar("instrucoes_4",mr_param.instrucoes_4)
         CALL log_setvar("instrucoes_5",mr_param.instrucoes_5)
         CALL log_setvar("instrucoes_6",mr_param.instrucoes_6)
         CALL log_setvar("formato",m_formato)
         CALL log_setvar("antecipacao_pedido",m_antecipacao_pedido)
         CALL log_setvar("portador_determ",mr_tela.portador_determ)
         CALL log_setvar("ies_sem_port_tipo_emis",mr_tela.ies_sem_port_tipo_emis)
         CALL log_setvar("param_nf",m_param_nf)

         CALL geo1015y_carrega_temp()

         LET l_acabou = 'N'

         WHILE l_acabou <> 'S'

            CALL log130_procura_caminho('cre1100b')
               RETURNING l_tela

            OPEN WINDOW w_cre1100b AT 2,2 WITH FORM l_tela
                 ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

            CURRENT WINDOW IS w_cre1100b

            CALL geo1015y_cursor_temp()

            LET l_acabou = log_getvar("acabou")
            IF l_acabou = "S" THEN
               CLOSE WINDOW w_cre1100b
               RETURN
            END IF

         END WHILE
      ELSE
         CALL log130_procura_caminho('cre1100b')
            RETURNING l_tela

         OPEN WINDOW w_cre1100b AT 2,2 WITH FORM l_tela
              ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

         CURRENT WINDOW IS w_cre1100b

         CALL geo1015_verifica_utilizacao_epl_1131_e_1130()

         #CALL geo1015_imprime_boleto()
         
         IF geo1015_informa_dados() THEN
           #initialize mr_param.* to null
           CALL geo1015_imprime_boleto()
         END IF

         CLOSE WINDOW w_cre1100b
         RETURN
      END IF
   END IF

   CALL log006_exibe_teclas('01',p_versao)
   IF LOG_existe_epl("geo1015y_open_window_principal") THEN # Chamado TDFXXU
      IF geo1015y_open_window_principal() THEN
         LET l_tela = LOG_getVar( "EPL_caminho_tela_especifica" )
      END IF
   ELSE

      CALL log130_procura_caminho('cre11000')
           RETURNING l_tela
    END IF

   OPEN WINDOW w_geo1015_principal AT 2,2 WITH FORM l_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL geo1015_ativa_help()

   MENU 'Opção'

     COMMAND KEY ('P') 'Processar_impressão' 'Efetua impressão de documentos.'
        #HELP 001
        MESSAGE ''
        LET g_reimpressao = FALSE

        CALL geo1015_verifica_utilizacao_epl_1131_e_1130()

        IF geo1015_informa_dados() THEN
           IF log_existe_epl('geo1015y_before_envia_impressao') THEN
              IF log0040_confirm(7,46,"Deseja enviar boleto por email?")THEN
                 LET m_envia_email = TRUE
              ELSE
                 LET m_envia_email = FALSE
              END IF
           END IF
           CALL geo1015_imprime_boleto()
        END IF

     COMMAND KEY ('R') 'processar_Reimpressão' 'Efetua reimpressão de documentos.'
        #HELP 004
        MESSAGE ''
        LET g_reimpressao = TRUE

        CALL geo1015_verifica_utilizacao_epl_1131_e_1130()

        IF geo1015_informa_dados() THEN
           IF log_existe_epl('geo1015y_before_envia_impressao') THEN
              IF log0040_confirm(7,46,"Deseja enviar boleto por email?")THEN
                 LET m_envia_email = TRUE
              ELSE
                 LET m_envia_email = FALSE
              END IF
           END IF
           CALL log_setvar("envia_boleto",m_envia_email)
           CALL geo1015_imprime_boleto()
        END IF

     COMMAND 'Fim' 'Retorna ao menu anterior.'
        HELP 010
        EXIT MENU

  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

   END MENU

   CLOSE WINDOW w_geo1015_principal

END FUNCTION

#-----------------------------------------#
 FUNCTION geo1015_set_variaveis(lr_param)
#-----------------------------------------#
  DEFINE lr_param  RECORD
                   origem          CHAR(02),
                   nota_fiscal     SMALLINT,
                   ies_sem_port    CHAR(01),
                   ies_empresa     CHAR(01),
                   ies_cliente     CHAR(01),
                   ies_empresa_fat CHAR(01),
                   ies_tip_docum   CHAR(01),
                   ies_tip_cobr    CHAR(01),
                   ies_docum       CHAR(01),
                   ies_emis        CHAR(01),
                   ies_vencto      CHAR(01),
                   ies_com_port    CHAR(01),
                   nota            LIKE fat_nf_mestre.nota_fiscal
                   END RECORD


  LET mr_param.origem          = lr_param.origem
  LET m_nota_fiscal            = lr_param.nota_fiscal
  LET mr_tela.ies_sem_port     = lr_param.ies_sem_port
  LET mr_tela.ies_empresa      = lr_param.ies_empresa
  LET mr_tela.ies_cliente      = lr_param.ies_cliente
  LET mr_tela.ies_empresa_fat  = lr_param.ies_empresa_fat
  LET mr_tela.ies_tip_docum    = lr_param.ies_tip_docum
  LET mr_tela.ies_tip_cobr     = lr_param.ies_tip_cobr
  LET mr_tela.ies_docum        = lr_param.ies_docum
  LET mr_tela.ies_emis         = lr_param.ies_emis
  LET mr_tela.ies_vencto       = lr_param.ies_vencto
  LET mr_tela.ies_com_port     = lr_param.ies_com_port
  LET mr_param.nota_fiscal_ini = lr_param.nota
  LET mr_param.nota_fiscal_fim = lr_param.nota

END FUNCTION

#------------------------------------#
 FUNCTION geo1015_busca_parametros()
#------------------------------------#

   DEFINE l_qtd_dia_max_bol     SMALLINT

   INITIALIZE m_dat_proces_doc  TO NULL
   INITIALIZE l_qtd_dia_max_bol TO NULL
   INITIALIZE m_val_max_bol     TO NULL
   INITIALIZE m_dat_aux         TO NULL

   LET m_cod_programa = 'CRE1100'

   IF NOT crem2_par_cre_leitura(TRUE,TRUE) THEN
      RETURN FALSE
   END IF

   CALL log2250_busca_parametro(p_cod_empresa,"imprimir_endereco_cnpj_boleto")
        RETURNING m_imprimir_endereco_cnpj_boleto, m_status

   IF m_status = FALSE OR m_imprimir_endereco_cnpj_boleto IS NULL OR m_imprimir_endereco_cnpj_boleto = " " THEN
      LET m_imprimir_endereco_cnpj_boleto = 'N'
   END IF

   CALL log2250_busca_parametro(p_cod_empresa,'qtd_vias_impressao_boleto')
       RETURNING m_qtd_vias, m_status

       IF NOT m_status OR m_qtd_vias IS NULL OR m_qtd_vias = ' ' OR (m_qtd_vias <> '2' AND m_qtd_vias <> '3') THEN
          LET m_qtd_vias = '2'
       END IF

   LET m_dat_proces_doc = crem2_par_cre_get_dat_proces_doc()

   IF NOT crem7_par_cre_txt_leitura(TRUE,TRUE) THEN
      RETURN FALSE
   END IF

   CALL log2250_busca_parametro(p_cod_empresa, 'qtd_min_dias_val_max_bol')
        RETURNING l_qtd_dia_max_bol, m_status

   IF NOT m_status THEN
      RETURN FALSE
   END IF

   CALL log2250_busca_parametro(p_cod_empresa,'val_max_bol')
      RETURNING m_val_max_bol, m_status

   IF NOT m_status THEN
      RETURN FALSE
   END IF

   IF m_val_max_bol IS NULL THEN
      LET m_val_max_bol = 0
   END IF

   IF l_qtd_dia_max_bol > 0 THEN
      LET m_dat_aux = l_qtd_dia_max_bol + TODAY
   ELSE
      LET m_dat_aux = NULL
   END IF

   CALL log2250_busca_parametro(p_cod_empresa,'ies_bloq_nf_pre_dt')
      RETURNING m_boleto_cond_pre_datado, m_status

   IF m_status = FALSE OR
      m_boleto_cond_pre_datado IS NULL OR
      m_boleto_cond_pre_datado = ' ' THEN
      LET m_boleto_cond_pre_datado = 'N'
   END IF

   CALL log2250_busca_parametro(p_cod_empresa,'blo_nf_ctr_aprs')
      RETURNING m_boleto_cond_contra_partida, m_status

   IF m_status = FALSE OR
      m_boleto_cond_contra_partida IS NULL OR
      m_boleto_cond_contra_partida = ' ' THEN
      LET m_boleto_cond_contra_partida = 'N'
   END IF

   CALL log2250_busca_parametro(p_cod_empresa,'selec_nf_bloqueto_x_portador')
      RETURNING m_selec_nf_bloq_x_portador, m_status

   IF m_status = FALSE OR
      m_selec_nf_bloq_x_portador IS NULL OR
      m_selec_nf_bloq_x_portador = ' ' THEN
      LET m_selec_nf_bloq_x_portador = '1'
   END IF

   {De para do parâmetro para a tela do geo1015 (mr_tela.ies_sem_port_tipo_emis)}
   {para que no programa possam ser testados os mesmos códigos:                  }

   CASE m_selec_nf_bloq_x_portador
      WHEN '1'
         LET m_selec_nf_bloq_x_portador = 'U' {Utilizar portador do cliente}
      WHEN '2'
         LET m_selec_nf_bloq_x_portador = 'C' {Clientes com portador igual ao informado}
      WHEN '3'
         LET m_selec_nf_bloq_x_portador = 'P' {Utilizar portador informado}
      WHEN '4'
         LET m_selec_nf_bloq_x_portador = 'S' {Clientes com portador igual ao informado ou sem portador}
    # WHEN '5'
    #    LET m_selec_nf_bloq_x_portador = '5' {tela só vai até o 4}
   END CASE

   {Layout para boleto bancario para o Santander Banespa? (Mais detalhes no help do parâmetro)
    "1" - Antigo Banespa
    "2" - Santander 8 posições
    "3" - Santander 13 posições }
   CALL log2250_busca_parametro(p_cod_empresa,'novo_layout_santander')
      RETURNING m_layout_santander, m_status
   IF m_status = FALSE OR
      m_layout_santander IS NULL OR
      m_layout_santander NOT MATCHES "[123]" THEN
      LET m_layout_santander = "3"
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION geo1015_ativa_help()
#-----------------------------#
{OBJETIVO: Acionar o arquivo de ajuda (arquivo .iem) do fonte atual.

OBSERVAÇÃO: Esta função sempre precisará ser acionada no início do programa
            e sempre após a execução de alguma função externa (.4gl) que
            tenha acionado outro arquivo de HELP, para reativar o arquivo
            de help do fonte atual.
}
   DEFINE l_arquivo_help CHAR(100)

   #LET l_arquivo_help = log140_procura_caminho('geo1015.iem')

   OPTIONS HELP FILE l_arquivo_help

END FUNCTION


#---------------------------------#
 FUNCTION geo1015_informa_dados()
#---------------------------------#

   DEFINE l_cod_programa_aux CHAR(9)

   WHENEVER ERROR CONTINUE
   DELETE FROM cre_selecao_data
    WHERE usuario  = p_user
      AND programa = m_cod_programa
   WHENEVER ERROR STOP

   IF sqlca.sqlcode < 0 THEN
   END IF

   WHENEVER ERROR CONTINUE
   DELETE FROM cre0270_empresa
    WHERE nom_usuario  = p_user
      AND cod_programa = m_cod_programa
   WHENEVER ERROR STOP

   IF sqlca.sqlcode < 0 THEN
   END IF

   WHENEVER ERROR CONTINUE
   DELETE FROM cre0270_tip_doc
    WHERE nom_usuario = p_user
      AND cod_programa = m_cod_programa
   WHENEVER ERROR STOP

   IF sqlca.sqlcode < 0 THEN
   END IF

   WHENEVER ERROR CONTINUE
   DELETE FROM cre0270_portador
    WHERE nom_usuario = p_user
      AND cod_programa = m_cod_programa
   WHENEVER ERROR STOP

   IF sqlca.sqlcode < 0 THEN
   END IF

   WHENEVER ERROR CONTINUE
   DELETE FROM cre0270_num_docum
    WHERE nom_usuario = p_user
      AND cod_programa = m_cod_programa
   WHENEVER ERROR STOP

   IF sqlca.sqlcode < 0 THEN
   END IF

   WHENEVER ERROR CONTINUE
   DELETE FROM cre0270_clientes
    WHERE nom_usuario = p_user
      AND cod_programa = m_cod_programa
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
   DELETE FROM cre0270_clientes
    WHERE nom_usuario = p_user
      AND cod_programa = 'CRE110F'
   WHENEVER ERROR STOP

   IF sqlca.sqlcode < 0 THEN
   END IF

   INITIALIZE mr_tela.* TO NULL
   INITIALIZE ma_doc_orig_unico TO NULL
   INITIALIZE m_formato TO NULL

   IF NOT crem7_par_cre_txt_leitura(TRUE,TRUE) THEN
      RETURN FALSE
   END IF
   LET m_empresa_menu_217 = crem7_par_cre_txt_get_posicao_parametro(217,217)

   LET m_existe_nota                    = FALSE
   LET mr_tela.ies_empresa              = 'S'
   LET mr_tela.ies_empresa_fat          = 'S'
   LET mr_tela.ies_cliente              = 'S'
   LET mr_tela.ies_nota_fiscal          = 'N'
   LET mr_tela.ies_tip_docum            = 'S'
   LET mr_tela.ies_tip_cobr             = 'S'
   LET mr_tela.ies_docum                = 'S'
   LET mr_tela.ies_docum_ini            = ''
   LET mr_tela.ies_docum_fim            = ''
   LET mr_tela.ies_emis                 = 'S'
   LET mr_tela.dat_emis_ini             = ''
   LET mr_tela.dat_emis_fim             = ''
   LET mr_tela.dat_vencto_ini           = ''
   LET mr_tela.dat_vencto_fim           = ''
   LET mr_tela.ies_vencto               = 'S'
   LET mr_tela.ies_com_port             = 'N'
   LET mr_tela.ies_com_port_todos_port  = 'S'
   LET mr_tela.ies_sem_port             = 'S'

   LET mr_tela.ies_sem_port_tipo_emis = "P"
   LET mr_tela.portador_determ = mr_param.portador


   IF geo1015_gerencia_nota_fiscal() THEN
      LET mr_tela.ies_tip_docum = 'S'
      LET mr_tela.ies_docum = 'S'
   END IF
   
   
   LET INT_FLAG = FALSE


   IF INT_FLAG THEN
      LET INT_FLAG = 0
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION


#--------------------------------#
 FUNCTION geo1015_somente_vendor()
#--------------------------------#
{OBJETIVO: verifica se somente o tipo vendor foi selecionado.
}
  DEFINE l_cont SMALLINT

  IF mr_tela.ies_tip_cobr = 'N' THEN
     WHENEVER ERROR CONTINUE
       SELECT COUNT(ies_tip_cobr)
         INTO l_cont
         FROM cre0270_tip_cobr
        WHERE ies_tip_cobr <> 'V'
          AND nom_usuario = p_user
          AND cod_programa = m_cod_programa
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('SELECT COUNT','CRE0270_TIP_COBR')
        RETURN FALSE
     END IF

     IF l_cont > 0 THEN
        RETURN FALSE
     ELSE
        RETURN TRUE
     END IF
  END IF

  RETURN FALSE

 END FUNCTION

#-----------------------------------------#
 FUNCTION geo1015_grava_cre0270_tip_doc()
#-----------------------------------------#

   DEFINE l_houve_erro        SMALLINT,
          l_tipo_gravado      CHAR(01),
          l_tip_docum         CHAR(02)

   DEFINE l_sql_stmt          CHAR(500)

   WHENEVER ERROR CONTINUE
   DELETE FROM cre0270_tip_doc
    WHERE cod_programa = m_cod_programa
      AND nom_usuario  = p_user
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
   END IF

   LET l_houve_erro = FALSE
   LET l_tipo_gravado = 'N'

   IF mr_tela.ies_empresa = 'N' THEN
      IF UPSHIFT(m_empresa_menu_217) = 'S' THEN
         LET l_sql_stmt = ' SELECT ies_tip_docum ',
                            ' FROM par_tipo_docum  ',
                           ' WHERE par_tipo_docum.deb_cre = "D" ',
                             ' AND par_tipo_docum.cod_empresa = "',p_cod_empresa,'" '
      ELSE
         LET l_sql_stmt = ' SELECT ies_tip_docum ',
                            ' FROM par_tipo_docum,cre0270_empresa ',
                           ' WHERE par_tipo_docum.deb_cre = "D" ',
                             ' AND par_tipo_docum.cod_empresa = cre0270_empresa.cod_empresa ',
                             ' AND cre0270_empresa.cod_programa =  "',m_cod_programa,'"',
                             ' AND cre0270_empresa.nom_usuario = "',p_user,'" '
      END IF
   ELSE
      LET l_sql_stmt = ' SELECT UNIQUE ies_tip_docum ',
                       ' FROM par_tipo_docum ',
                      ' WHERE par_tipo_docum.deb_cre = "D" ',
                      ' GROUP BY ies_tip_docum '
   END IF

   WHENEVER ERROR CONTINUE
   PREPARE var_query_tip_doc FROM l_sql_stmt
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('SELEÇÃO','PAR_TIPO_DOCUM')
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   FREE var_query_tip_doc
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
   DECLARE cq_grava_tip CURSOR WITH HOLD FOR var_query_tip_doc
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('SELEÇÃO','PAR_TIPO_DOCUM')
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   FOREACH cq_grava_tip INTO l_tip_docum
   WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('SELEÇÃO','PAR_TIPO_DOCUM')
         LET l_houve_erro = TRUE
         EXIT FOREACH
      END IF

      WHENEVER ERROR CONTINUE
      SELECT 0
        FROM cre0270_tip_doc
       WHERE nom_usuario   = p_user
         AND cod_programa  = m_cod_programa
         AND ies_tip_docum = l_tip_docum
      WHENEVER ERROR STOP

      IF sqlca.sqlcode < 0 THEN
         CALL log003_err_sql('SELEÇÃO','CRE0270_TIP_DOC')
         LET l_houve_erro = TRUE
         EXIT FOREACH
      END IF

      IF sqlca.sqlcode = 100 THEN

         WHENEVER ERROR CONTINUE
         INSERT INTO cre0270_tip_doc
               (nom_usuario,
                cod_programa,
                ies_tip_docum)
         VALUES
               (p_user,
                m_cod_programa,
                l_tip_docum)
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('INCLUSÃO','CRE0270_TIP_DOC')
            LET l_houve_erro = TRUE
            EXIT FOREACH
         END IF

         LET l_tipo_gravado = 'S'

      END IF

      WHENEVER ERROR CONTINUE

   END FOREACH

   WHENEVER ERROR CONTINUE
   FREE cq_grava_tip
   WHENEVER ERROR STOP

   IF l_tipo_gravado = 'N' THEN
      CALL log0030_mensagem('Não existem Tipos de Documento cadastrados (CRE0300)','exclamation')
      RETURN FALSE
   END IF

   IF l_houve_erro = TRUE THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#----------------------------------#
 FUNCTION geo1015_verifica_tipos()
#----------------------------------#

   DEFINE l_cont           SMALLINT,
          l_tip_docum      CHAR(02),
          l_retorno        SMALLINT

   LET l_retorno = FALSE

   WHENEVER ERROR CONTINUE
   DECLARE cq_tipo_doc CURSOR FOR
   SELECT ies_tip_docum
     FROM cre0270_tip_doc
    WHERE cod_programa = m_cod_programa
      AND nom_usuario  = p_user
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('SELEÇÃO','CRE0270_TIP_DOC')
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   FOREACH cq_tipo_doc INTO l_tip_docum
   WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('SELEÇÃO','CRE0270_TIP_DOC')
         EXIT FOREACH
      END IF

      LET l_retorno = TRUE
      LET l_cont = 0

      IF mr_tela.ies_empresa = 'S' THEN
         WHENEVER ERROR CONTINUE
         SELECT COUNT(*)
           INTO l_cont
           FROM par_tipo_docum
          WHERE par_tipo_docum.ies_tip_docum = l_tip_docum
            AND par_tipo_docum.deb_cre      <> 'D'
          GROUP BY par_tipo_docum.ies_tip_docum
         WHENEVER ERROR STOP
         IF sqlca.sqlcode < 0 THEN
            CALL log003_err_sql('SELEÇÃO','PAR_TIPO_DOCUM-1')
            EXIT FOREACH
         END IF
      ELSE
         IF UPSHIFT(m_empresa_menu_217) = 'S' THEN
            WHENEVER ERROR CONTINUE
            SELECT COUNT(*)
              INTO l_cont
              FROM par_tipo_docum
             WHERE par_tipo_docum.cod_empresa   = p_cod_empresa
               AND par_tipo_docum.ies_tip_docum = l_tip_docum
               AND par_tipo_docum.deb_cre      <> 'D'
             GROUP BY par_tipo_docum.ies_tip_docum
             WHENEVER ERROR STOP
            IF sqlca.sqlcode < 0 THEN
               CALL log003_err_sql('SELEÇÃO','PAR_TIPO_DOCUM-2')
               EXIT FOREACH
            END IF
         ELSE
            WHENEVER ERROR CONTINUE
            SELECT COUNT(*)
              INTO l_cont
              FROM par_tipo_docum,
                   cre0270_empresa
             WHERE par_tipo_docum.cod_empresa   = cre0270_empresa.cod_empresa
               AND par_tipo_docum.ies_tip_docum = l_tip_docum
               AND par_tipo_docum.deb_cre      <> 'D'
               AND cre0270_empresa.cod_programa = m_cod_programa
               AND cre0270_empresa.nom_usuario  = p_user
             GROUP BY par_tipo_docum.ies_tip_docum
             WHENEVER ERROR STOP
            IF sqlca.sqlcode < 0 THEN
               CALL log003_err_sql('SELEÇÃO','PAR_TIPO_DOCUM-3')
               EXIT FOREACH
            END IF
         END IF
      END IF

      IF l_cont > 0 THEN
         LET l_retorno = FALSE
         EXIT FOREACH
      END IF

      WHENEVER ERROR CONTINUE

   END FOREACH

   WHENEVER ERROR CONTINUE
   FREE cq_tipo_doc
   WHENEVER ERROR STOP

   IF NOT l_retorno THEN
      CALL log0030_mensagem('Tipos Documento CREDITO não imprimem boletos (CRE0300)','exclamation')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#-----------------------------#
 FUNCTION geo1015_valida_portador(l_portador)
#-----------------------------#

   DEFINE l_portador LIKE portador.cod_portador

   WHENEVER ERROR CONTINUE
     SELECT cod_portador
       FROM portador
      WHERE cod_portador = l_portador
        AND ies_tip_portador = 'B'
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF sqlca.sqlcode <> NOTFOUND THEN
         CALL log003_err_sql('SELECT','PORTADOR')
      END IF

      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#----------------------------------#
 FUNCTION geo1015_imprime_boleto()
#----------------------------------#

   INITIALIZE m_empresa_anterior TO NULL
   INITIALIZE m_empresa_mudou    TO NULL

   CALL vdpm315_par_bloqueto_laser_set_null()

   LET m_emitiu = FALSE
   LET m_vendor_sem_contrato = FALSE

   IF m_antecipacao_pedido = 'S' THEN #quando for antecipação de pedido - 766519
      IF NOT geo1015_monta_sql_selecao_pedido() THEN
         RETURN
      END IF
   ELSE
      IF mr_param.origem = 'NF' THEN
         IF NOT geo1015_monta_sql_selecao_nf() THEN
            RETURN
         END IF
      ELSE
         IF NOT geo1015_monta_sql_selecao() THEN
            RETURN
         END IF
      END IF
   END IF

   IF NOT geo1015_processa_impressao() THEN
      RETURN
   END IF

END FUNCTION


#-------------------------------------#
 FUNCTION geo1015_monta_sql_selecao()
#-------------------------------------#

   DEFINE sql_stmt                 CHAR(5000),
          where_clause             CHAR(4000)

   DEFINE l_cont                   SMALLINT,
          l_cliente_especifico     SMALLINT

   INITIALIZE sql_stmt TO NULL

   LET sql_stmt =

       'SELECT DISTINCT "DC", ', {DOCUM}
             ' docum.cod_empresa, ',
             ' docum.num_docum, ',
             ' docum.ies_tip_docum, ',
             ' docum.cod_cliente, ', #541817
             ' 0, ', {fat_nf_duplicata.trans_nota_fiscal}
             ' 0 ',  {fat_nf_duplicata.seq_duplicata}
        ' FROM docum, par_tipo_docum, clientes '

#MARCOS
#CRE10560
   LET where_clause =
       ' WHERE docum.cod_cliente              = clientes.cod_cliente ',
         ' AND docum.ies_pgto_docum          <> "T" ',
         ' AND docum.ies_situa_docum         <> "C" ',
         ' AND docum.cod_empresa              = par_tipo_docum.cod_empresa ',
         ' AND docum.ies_tip_docum            = par_tipo_docum.ies_tip_docum ',
         ' AND par_tipo_docum.deb_cre         = "D" ',
         ' AND docum.cod_cnd_pgto NOT IN ("4"' #MARCOS VDP2197

   #Verifica se a condição de pagamento contra-apresentação gera boleto
   IF m_boleto_cond_contra_partida = 'S' THEN
      LET where_clause = where_clause CLIPPED, ',"2"'
   END IF

   #Verifica se a condição de pagamento pré-datado gera boleto
   IF m_boleto_cond_pre_datado = 'S' THEN
      LET where_clause = where_clause CLIPPED, ',"15"'
   END IF

   LET where_clause = where_clause CLIPPED, ')'

   IF m_val_max_bol > 0 THEN
      IF m_dat_aux IS NULL THEN
         #572487
         #O documento não é vendor -> Valida pelos valores da docum
         #O documento é vendor     -> Valida pelos valores da cre_tit_cob_esp
         LET where_clause = where_clause CLIPPED,
             ' AND ( ',
             '       (    (docum.ies_tip_cobr IS NULL OR docum.ies_tip_cobr <> "V")',
             '        AND (',
             '                docum.val_saldo <= ', log2260_troca_virgula_por_ponto(m_val_max_bol),
             '             OR docum.val_bruto <= ', log2260_troca_virgula_por_ponto(m_val_max_bol),
             '            ) ',
             '       )'

         IF log0150_verifica_se_tabela_existe('cre_tit_cob_esp') THEN
            LET where_clause = where_clause CLIPPED,
                '     OR',
                '       (    docum.ies_tip_cobr = "V"',
                '        AND EXISTS (SELECT cre_tit_cob_esp.empresa',
                '                      FROM cre_tit_cob_esp',
                '                     WHERE cre_tit_cob_esp.empresa = docum.cod_empresa',
                '                       AND cre_tit_cob_esp.docum = docum.num_docum',
                '                       AND cre_tit_cob_esp.tip_docum = docum.ies_tip_docum',
                '                       AND cre_tit_cob_esp.ativo = "S"',
                '                       AND (   cre_tit_cob_esp.val_saldo_cliente   <= ', log2260_troca_virgula_por_ponto(m_val_max_bol),
                '                            OR cre_tit_cob_esp.val_parcela_cliente <= ', log2260_troca_virgula_por_ponto(m_val_max_bol),
                '                           )',
                '                   )',
                '       )'
         END IF

         LET where_clause = where_clause CLIPPED, '     )'
      ELSE
         IF log_existe_epl("geo1015y_busca_docum_vencido") THEN

         ELSE
         LET where_clause = where_clause CLIPPED,
             ' AND (',
             '         (    (docum.ies_tip_cobr IS NULL OR docum.ies_tip_cobr <> "V")',
             '          AND (',
             '                   (    docum.dat_vencto_s_desc >= "', m_dat_aux, '" ',
             '                    AND (   docum.val_bruto     <= ', log2260_troca_virgula_por_ponto(m_val_max_bol),
             '                         OR docum.val_saldo     <= ', log2260_troca_virgula_por_ponto(m_val_max_bol),
             '                        )',
             '                   )',
             '                OR',
             '                   (   docum.dat_vencto_s_desc < "', m_dat_aux, '"',
             '                   ) ',
             '              )',
             '         )'
         END IF

         IF log0150_verifica_se_tabela_existe('cre_tit_cob_esp') THEN
            LET where_clause = where_clause CLIPPED,
                '      OR',
                '         (    docum.ies_tip_cobr = "V"',
                '          AND EXISTS (SELECT cre_tit_cob_esp.empresa',
                '                        FROM cre_tit_cob_esp',
                '                       WHERE cre_tit_cob_esp.empresa = docum.cod_empresa',
                '                         AND cre_tit_cob_esp.docum = docum.num_docum',
                '                         AND cre_tit_cob_esp.tip_docum = docum.ies_tip_docum',
                '                         AND cre_tit_cob_esp.ativo = "S"',
                '                         AND (',
                '                                 (   cre_tit_cob_esp.dat_vencimento >= "', m_dat_aux, '" ',
                '                                  AND (   cre_tit_cob_esp.val_saldo_cliente   <= ', log2260_troca_virgula_por_ponto(m_val_max_bol),
                '                                       OR cre_tit_cob_esp.val_parcela_cliente <= ', log2260_troca_virgula_por_ponto(m_val_max_bol),
                '                                      )',
                '                                 )',
                '                              OR',
                '                                 (   cre_tit_cob_esp.dat_vencimento < "', m_dat_aux, '" ',
                '                                 )',
                '                              )',
                '                     )',
                '         )'
         END IF

         LET where_clause = where_clause CLIPPED, '     )'
      END IF
   END IF

   IF g_reimpressao THEN #CRE10560 - REIMPRESSÃO

      LET sql_stmt = sql_stmt CLIPPED, ', docum_banco '
      LET where_clause = where_clause CLIPPED,
                    ' AND docum_banco.cod_empresa   = docum.cod_empresa ',
                    ' AND docum_banco.num_docum     = docum.num_docum ',
                    ' AND docum_banco.ies_tip_docum = docum.ies_tip_docum ',
                    ' AND docum_banco.cod_portador  = docum.cod_portador ',
                    ' AND docum_banco.num_titulo_banco IS NOT NULL '
   END IF


   IF LOG_existe_epl("geo1015y_considera_origem_fat") THEN
      IF geo1015y_considera_origem_fat() THEN
         LET sql_stmt = sql_stmt CLIPPED,LOG_getVar("EPL_sql_stmt")
         LET where_clause = where_clause CLIPPED,LOG_getVar("EPL_where_clause")
      END IF
   END IF

   IF mr_tela.ies_empresa = 'N' THEN
      IF UPSHIFT(m_empresa_menu_217) = 'S' THEN
         LET where_clause = where_clause CLIPPED,
                    ' AND docum.cod_empresa = "',p_cod_empresa,'" '
      ELSE
         WHENEVER ERROR CONTINUE
         SELECT COUNT(*)
           INTO l_cont
           FROM cre0270_empresa
          WHERE cod_programa = m_cod_programa
            AND nom_usuario  = p_user
         WHENEVER ERROR STOP
         IF sqlca.sqlcode < 0 THEN
            CALL log003_err_sql('SELEÇÃO','CRE0270_EMPRESA')
            RETURN FALSE
         END IF

         IF l_cont > 0 THEN
            LET sql_stmt = sql_stmt CLIPPED, ', cre0270_empresa emp2'

            LET where_clause = where_clause CLIPPED,
                ' AND (emp2.nom_usuario  = "', p_user, '" ',
                ' AND  emp2.cod_programa = "', m_cod_programa, '" ',
                ' AND  emp2.cod_empresa  = docum.cod_empresa )'
         END IF
      END IF
   END IF

   IF mr_tela.ies_cliente = 'N' THEN
      WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_cont
        FROM cre0270_clientes
       WHERE nom_usuario   = p_user
         AND cod_programa  = m_cod_programa
      WHENEVER ERROR STOP

      IF sqlca.sqlcode < 0 THEN
         CALL log003_err_sql('SELEÇÃO','CRE0270_CLIENTES')
         RETURN FALSE
      END IF

      IF l_cont > 0 THEN
          LET sql_stmt = sql_stmt CLIPPED, ', cre0270_clientes '

          LET where_clause = where_clause CLIPPED,
              ' AND cre0270_clientes.nom_usuario  = "', p_user, '" ',
              ' AND cre0270_clientes.cod_programa = "', m_cod_programa, '" ',
              ' AND cre0270_clientes.cod_cliente  = docum.cod_cliente '
      END IF
   END IF

   #seleciona duplicata(s) existente(s) na(s) nota(s) ficai(s) informada(s).
   IF m_nota_fiscal THEN
      IF mr_tela.ies_empresa_fat = 'N' THEN
         LET sql_stmt = sql_stmt CLIPPED, ', w_nota_fiscal '
      ELSE
         LET sql_stmt = sql_stmt CLIPPED, ', cre_nf_orig_docum, w_nota_fiscal '
      END IF

      LET where_clause = where_clause CLIPPED,
                ' AND docum.cod_empresa                   = cre_nf_orig_docum.empresa_docum',
                ' AND docum.num_docum                     = cre_nf_orig_docum.docum ',
                ' AND docum.ies_tip_docum                 = cre_nf_orig_docum.tip_docum',
                ' AND cre_nf_orig_docum.emp_nota_fiscal   = w_nota_fiscal.empresa',
                ' AND cre_nf_orig_docum.tip_nota_fiscal   = w_nota_fiscal.tipo',
                ' AND cre_nf_orig_docum.nota_fiscal       = w_nota_fiscal.nota_fiscal',
                ' AND cre_nf_orig_docum.serie_nota_fiscal = w_nota_fiscal.serie',
                ' AND cre_nf_orig_docum.subserie_nf       = w_nota_fiscal.subserie'
   END IF

   #---Seleciona por documento(s), quando não houver filtro por nota fiscal.---#
   IF mr_tela.ies_tip_docum = 'N' THEN
      WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_cont
        FROM cre0270_tip_doc
       WHERE cod_programa = m_cod_programa
         AND nom_usuario  = p_user
      WHENEVER ERROR STOP

      IF sqlca.sqlcode < 0 THEN
         CALL log003_err_sql('SELEÇÃO','CRE0270_TIP_DOC')
         RETURN FALSE
      END IF

      IF l_cont > 0 THEN
         LET sql_stmt = sql_stmt CLIPPED, ', cre0270_tip_doc '

         LET where_clause = where_clause CLIPPED,
             ' AND cre0270_tip_doc.nom_usuario   = "', p_user, '" ',
             ' AND cre0270_tip_doc.cod_programa  = "', m_cod_programa, '" ',
             ' AND cre0270_tip_doc.ies_tip_docum = docum.ies_tip_docum  '
      END IF
   END IF

   #Seleciona por tipo de cobrança
   IF mr_tela.ies_tip_cobr = 'N' THEN
      WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_cont
        FROM cre0270_tip_cobr
       WHERE cod_programa = m_cod_programa
         AND nom_usuario  = p_user
      WHENEVER ERROR STOP
      IF sqlca.sqlcode < 0 THEN
         CALL log003_err_sql('SELEÇÃO','CRE0270_TIP_COBR')
         RETURN FALSE
      END IF

      IF l_cont > 0 THEN
         LET sql_stmt = sql_stmt CLIPPED, ', cre0270_tip_cobr '

         LET where_clause = where_clause CLIPPED,
             ' AND cre0270_tip_cobr.nom_usuario   = "', p_user, '" ',
             ' AND cre0270_tip_cobr.cod_programa  = "', m_cod_programa, '" ',
             ' AND cre0270_tip_cobr.ies_tip_cobr  = docum.ies_tip_cobr  '
      END IF
   END IF

   IF mr_tela.ies_docum = 'S' THEN
      IF mr_tela.ies_docum_ini IS NOT NULL AND
         mr_tela.ies_docum_ini <> ' ' THEN
         LET where_clause = where_clause CLIPPED,
             ' AND docum.num_docum  BETWEEN "', mr_tela.ies_docum_ini, '" ',
                                      ' AND "', mr_tela.ies_docum_fim, '" '
      END IF
   ELSE
      WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_cont
        FROM cre0270_num_docum
       WHERE cod_programa = m_cod_programa
         AND nom_usuario  = p_user
      WHENEVER ERROR STOP

      IF sqlca.sqlcode < 0 THEN
         CALL log003_err_sql('SELEÇÃO','CRE0270_NUM_DOCUM')
         RETURN FALSE
      END IF

      IF l_cont > 0 THEN
         LET sql_stmt = sql_stmt CLIPPED, ', cre0270_num_docum '

         LET where_clause = where_clause CLIPPED,
             ' AND cre0270_num_docum.nom_usuario   = "', p_user, '" ',
             ' AND cre0270_num_docum.cod_programa  = "', m_cod_programa, '" ',
             ' AND cre0270_num_docum.cod_empresa   = docum.cod_empresa ',
             ' AND cre0270_num_docum.num_docum     = docum.num_docum ',
             ' AND cre0270_num_docum.ies_tip_docum = docum.ies_tip_docum '
      END IF
   END IF
   #---Seleciona por documento(s), quando não houver filtro por nota fiscal.--#

   IF mr_tela.ies_emis = 'S' THEN
      IF mr_tela.dat_emis_ini IS NOT NULL THEN
         LET where_clause = where_clause CLIPPED,
             ' AND docum.dat_emis           BETWEEN "', mr_tela.dat_emis_ini, '" ',
                                              ' AND "', mr_tela.dat_emis_fim, '" '
      END IF
   ELSE
      WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_cont
        FROM cre_selecao_data
       WHERE usuario  = p_user
         AND programa = m_cod_programa
         AND tip_data = 'DATA_EMISSAO'
      WHENEVER ERROR STOP

      IF sqlca.sqlcode < 0 THEN
         CALL log003_err_sql('SELEÇÃO','CRE_SELECAO_DATA')
         RETURN FALSE
      END IF

      IF l_cont > 0 THEN
         LET sql_stmt = sql_stmt CLIPPED, ', cre_selecao_data '

         LET where_clause = where_clause CLIPPED,
             ' AND cre_selecao_data.usuario  = "', p_user, '" ',
             ' AND cre_selecao_data.programa = "', m_cod_programa, '" ',
             ' AND cre_selecao_data.tip_data = "DATA_EMISSAO" ',
             ' AND cre_selecao_data.data     = docum.dat_emis '
      END IF
   END IF

   IF mr_tela.ies_vencto = 'S' THEN
      IF mr_tela.dat_vencto_ini IS NOT NULL THEN
         LET where_clause = where_clause CLIPPED,
             ' AND docum.dat_vencto_s_desc  BETWEEN "', mr_tela.dat_vencto_ini, '" ',
                                              ' AND "', mr_tela.dat_vencto_fim, '" '
      END IF
   ELSE
      WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_cont
        FROM cre_selecao_data
       WHERE programa = m_cod_programa
         AND usuario  = p_user
         AND tip_data = 'DATA_VENCTO_S_DESC'
      WHENEVER ERROR STOP

      IF sqlca.sqlcode < 0 THEN
         CALL log003_err_sql('SELEÇÃO','CRE_SELECAO_DATA')
         RETURN FALSE
      END IF

      IF l_cont > 0 THEN
         LET sql_stmt = sql_stmt CLIPPED, ', cre_selecao_data '

         LET where_clause = where_clause CLIPPED,
             ' AND cre_selecao_data.usuario   = "', p_user, '" ',
             ' AND cre_selecao_data.programa  = "', m_cod_programa, '" ',
             ' AND cre_selecao_data.tip_data  = "DATA_VENCTO_S_DESC" ',
             ' AND cre_selecao_data.data      = docum.dat_vencto_s_desc '
      END IF
   END IF

   IF mr_tela.ies_com_port = 'S' THEN

      IF NOT g_reimpressao THEN

         LET where_clause = where_clause CLIPPED,
             ' AND docum.ies_cnd_bordero         IN ("B", "T") ',
             ' AND docum.ies_tip_emis_docum       = "N" ',
             ' AND docum.ies_tip_cobr            IS NOT NULL '

      END IF

      IF mr_tela.ies_com_port_todos_port = 'S' THEN
         LET where_clause = where_clause CLIPPED,
             ' AND docum.ies_tip_portador         = "B" '
      ELSE
         WHENEVER ERROR CONTINUE
         SELECT COUNT(*)
           INTO l_cont
           FROM cre0270_portador
          WHERE cod_programa = m_cod_programa
            AND nom_usuario  = p_user
         WHENEVER ERROR STOP

         IF sqlca.sqlcode < 0 THEN
            CALL log003_err_sql('SELEÇÃO','CRE0270_PORTADOR')
            RETURN FALSE
         END IF

         IF l_cont > 0 THEN
            LET sql_stmt = sql_stmt CLIPPED, ', cre0270_portador '

            LET where_clause = where_clause CLIPPED,
                ' AND cre0270_portador.nom_usuario      = "', p_user, '" ',
                ' AND cre0270_portador.cod_programa     = "', m_cod_programa, '" ',
                ' AND cre0270_portador.cod_portador     = docum.cod_portador ',
                ' AND cre0270_portador.ies_tip_portador = docum.ies_tip_portador '
         END IF
      END IF
   END IF

   IF mr_tela.ies_sem_port = 'S' THEN

      LET where_clause = where_clause CLIPPED,
          ' AND (docum.ies_tip_cobr      IS NULL ',
          ' AND  docum.cod_portador      = 0 ',
          ' AND  (docum.ies_tip_portador IS NULL ',
          '  OR   docum.ies_tip_portador = " ")) '

      CASE mr_tela.ies_sem_port_tipo_emis
         WHEN 'U'
              LET where_clause = where_clause CLIPPED,
                  ' AND clientes.ies_tip_portador = "B" '
         WHEN 'C'
              LET where_clause = where_clause CLIPPED,
                  ' AND clientes.cod_portador     = ', mr_tela.portador_determ,
                  ' AND clientes.ies_tip_portador = "B" '
         WHEN 'S'
              LET where_clause = where_clause CLIPPED,
                  ' AND ((clientes.cod_portador     = ', mr_tela.portador_determ,
                  ' AND   clientes.ies_tip_portador = "B") ',
                   ' OR   clientes.cod_portador IS NULL ',
                   ' OR   clientes.cod_portador = 0) '
         {OTHERWISE  #541817
              CALL log0030_mensagem('Erro 3. Contate o desenvolvedor','exclamation')
              RETURN FALSE}
      END CASE

   END IF

   #Função específica cliente 834 - SOMAT: agrupamento de NSs e DPs na impressão/
   #reimpressão do boleto (OS 422113).
   #Caso o cliente seja 834 a seleção de documentos será ser ordenada por tipo
   #de documento e depois por documento.
   IF Find4GLFunction('crey2_ordenacao') THEN #OS 594370
      CALL crey2_ordenacao()
         RETURNING m_status, l_cliente_especifico
   ELSE
      LET l_cliente_especifico = FALSE
   END IF

   IF l_cliente_especifico THEN
      IF NOT m_status THEN
         RETURN FALSE
      END IF

      LET sql_stmt = sql_stmt     CLIPPED,
                     where_clause CLIPPED,
                     ' ORDER BY docum.cod_empresa, docum.ies_tip_docum, docum.num_docum '
   ELSE
      LET sql_stmt = sql_stmt     CLIPPED,
                     where_clause CLIPPED,
                     ' ORDER BY docum.cod_empresa, docum.num_docum '
   END IF

   LET sql_stmt = sql_stmt CLIPPED

   IF NOT geo1015_declara_cursor(sql_stmt,'DC') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------------#
 FUNCTION geo1015_monta_sql_selecao_nf()
#----------------------------------------#
   DEFINE sql_stmt                 CHAR(5000),
          where_clause             CHAR(4000),
          l_where_clause           CHAR(100)

   INITIALIZE sql_stmt, where_clause TO NULL

   LET sql_stmt =
      'SELECT "NF", ', {NOTA FISCAL}
            ' fat_nf_duplicata.empresa, ',
            ' fat_nf_mestre.nota_fiscal, ',  {docum.num_docum}
            ' "DP", ',                       {docum.ies_tip_docum}
            ' fat_nf_mestre.cliente, ',
            ' fat_nf_duplicata.trans_nota_fiscal, ',
            ' fat_nf_duplicata.seq_duplicata ',
       ' FROM fat_nf_duplicata, fat_nf_mestre, clientes, cond_pgto '

   LET where_clause =
      ' WHERE fat_nf_duplicata.empresa = "',mr_param.empresa,'" ',
        ' AND fat_nf_duplicata.dat_vencto_sdesc > EXTEND(fat_nf_mestre.dat_hor_emissao,YEAR TO DAY) ',
        ' AND fat_nf_mestre.empresa           = fat_nf_duplicata.empresa ',
        ' AND fat_nf_mestre.trans_nota_fiscal = fat_nf_duplicata.trans_nota_fiscal ',
        ' AND fat_nf_mestre.sit_nota_fiscal   = "N" '

   IF mr_param.tip_nota_fiscal IS NOT NULL AND
      mr_param.tip_nota_fiscal <> ' ' THEN
      LET where_clause = where_clause CLIPPED,
        ' AND fat_nf_mestre.tip_nota_fiscal  = "',mr_param.tip_nota_fiscal,'" '
   END IF

   IF mr_param.serie_nota_fiscal IS NOT NULL AND
      mr_param.serie_nota_fiscal <> ' ' THEN
      LET where_clause = where_clause CLIPPED,
        ' AND fat_nf_mestre.serie_nota_fiscal  = "',mr_param.serie_nota_fiscal,'" '
   END IF

   LET where_clause = where_clause CLIPPED,
        ' AND fat_nf_mestre.nota_fiscal BETWEEN ',mr_param.nota_fiscal_ini,
                                          ' AND ',mr_param.nota_fiscal_fim

   LET where_clause = where_clause CLIPPED,
        ' AND fat_nf_mestre.cond_pagto = cond_pgto.cod_cnd_pgto ',
        ' AND cond_pgto.ies_tipo     <> "V" '

   IF m_boleto_cond_contra_partida = 'S' THEN
      LET where_clause = where_clause CLIPPED,
        ' AND cond_pgto.ies_tipo  <> "C" '
   END IF

   IF m_boleto_cond_pre_datado = 'S' THEN
      LET where_clause = where_clause CLIPPED,
        ' AND cond_pgto.ies_tipo  <> "P" '
   END IF

   IF m_dat_aux IS NOT NULL AND m_val_max_bol > 0 THEN

      LET where_clause = where_clause CLIPPED,
        ' AND ((fat_nf_duplicata.dat_vencto_sdesc >= "',m_dat_aux,'" ',
        ' AND   fat_nf_duplicata.val_duplicata    <= ',log2260_troca_virgula_por_ponto(m_val_max_bol),' )',
        '  OR   fat_nf_duplicata.dat_vencto_sdesc <  "',m_dat_aux,'" )'
   ELSE
      IF m_val_max_bol > 0 THEN
         LET where_clause = where_clause CLIPPED,
         ' AND fat_nf_duplicata.val_duplicata <= ',log2260_troca_virgula_por_ponto(m_val_max_bol)
      END IF
   END IF

   {##comentado para realizar essa consistência depois, para que apresente uma msg ao usuário, informando
   que a duplicata já foi enviada ao CRE.

   {Não considerar duplicatas já enviadas para CRE

   LET where_clause = where_clause CLIPPED,
        ' AND NOT EXISTS (SELECT fat_nf_integr.trans_nota_fiscal ',
                          ' FROM fat_nf_integr ',
                         ' WHERE fat_nf_integr.empresa            = fat_nf_mestre.empresa ',
                           ' AND fat_nf_integr.trans_nota_fiscal  = fat_nf_mestre.trans_nota_fiscal ',
                           ' AND fat_nf_integr.sit_nota_fiscal    = "N" ',
                           ' AND fat_nf_integr.status_intg_creceb = "I" )'
    }

   LET where_clause = where_clause CLIPPED,
        ' AND clientes.cod_cliente = fat_nf_mestre.cliente '

   IF log_existe_epl('geo1015y_before_monta_sql_selecao_nf') THEN

      CALL geo1015y_before_monta_sql_selecao_nf()

      LET l_where_clause = log_getvar("where_clause")
      LET where_clause = where_clause CLIPPED, l_where_clause


   ELSE
   IF mr_tela.ies_sem_port_tipo_emis = 'U' OR {U = 1}
      mr_tela.ies_sem_port_tipo_emis = 'C' OR {C = 2}
      mr_tela.ies_sem_port_tipo_emis = '5' THEN

      LET where_clause = where_clause CLIPPED,
        ' AND clientes.ies_tip_portador = "B" '

      END IF
   END IF

   IF Find4GLFunction("crey49_filtro_selecao_documentos") THEN
      LET where_clause = where_clause CLIPPED, crey49_filtro_selecao_documentos()
   END IF

   LET sql_stmt = sql_stmt CLIPPED, where_clause CLIPPED,
       ' ORDER BY fat_nf_mestre.nota_fiscal, ',
                ' fat_nf_duplicata.seq_duplicata '

   IF NOT geo1015_declara_cursor(sql_stmt,'NF') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

 END FUNCTION

 #----------------------------------------#
 FUNCTION geo1015_monta_sql_selecao_pedido()
#----------------------------------------#
   DEFINE sql_stmt                 CHAR(5000),
          where_clause             CHAR(4000)

   INITIALIZE sql_stmt, where_clause TO NULL

   LET sql_stmt =
      "SELECT 'AN',", {Antecipação - pedido}
            " pedidos.cod_empresa,",
            " pedidos.num_pedido,",  {docum.num_docum}
            " 'AN',",                {docum.ies_tip_docum}
            " pedidos.cod_cliente,",
            " ped_duplicata.num_duplicata, ",
            " ped_duplicata.dig_duplicata ",
       " FROM ped_duplicata, pedidos, clientes, cond_pgto "

   LET where_clause =
       " WHERE pedidos.cod_empresa          = '",p_cod_empresa,"'",
         " AND pedidos.num_pedido          >= ", mr_param.nota_fiscal_ini,
         " AND pedidos.num_pedido          <= ", mr_param.nota_fiscal_fim,
         " AND pedidos.ies_sit_pedido       IN ('N','A','F','C')",
         " AND pedidos.cod_cnd_pgto         = cond_pgto.cod_cnd_pgto",
         " AND cond_pgto.ies_tipo           <> 'V'",
         " AND pedidos.cod_empresa          = ped_duplicata.cod_empresa",
         " AND pedidos.num_pedido           = ped_duplicata.num_pedido",
         " AND ped_duplicata.dat_vencto_sd >= pedidos.dat_pedido",
         " AND clientes.cod_cliente         = pedidos.cod_cliente"

   IF m_boleto_cond_contra_partida = 'S' THEN
      LET where_clause = where_clause CLIPPED,
        " AND cond_pgto.ies_tipo  <> 'C' "
   END IF

   IF m_boleto_cond_pre_datado = 'S' THEN
      LET where_clause = where_clause CLIPPED,
        " AND cond_pgto.ies_tipo  <> 'P' "
   END IF

   IF m_dat_aux IS NOT NULL AND m_val_max_bol > 0 THEN

      LET where_clause = where_clause CLIPPED,
        " AND ((ped_duplicata.dat_vencto_sd >= '",m_dat_aux,"'",
        " AND   ped_duplicata.val_duplic    <= ",log2260_troca_virgula_por_ponto(m_val_max_bol)," )",
        "  OR   ped_duplicata.dat_vencto_sd <  '",m_dat_aux,"')"
   ELSE
      IF m_val_max_bol > 0 THEN
         LET where_clause = where_clause CLIPPED,
         " AND ped_duplicata.val_duplic <= ",log2260_troca_virgula_por_ponto(m_val_max_bol)
      END IF
   END IF

   IF mr_tela.ies_sem_port_tipo_emis = 'U' OR {U = 1}
      mr_tela.ies_sem_port_tipo_emis = 'C' OR {C = 2}
      mr_tela.ies_sem_port_tipo_emis = '5' THEN

      LET where_clause = where_clause CLIPPED,
        " AND clientes.ies_tip_portador = 'B' "

   END IF

   IF Find4GLFunction("crey49_filtro_selecao_documentos") THEN
      LET where_clause = where_clause CLIPPED, crey49_filtro_selecao_documentos()
   END IF

   LET sql_stmt = sql_stmt CLIPPED, where_clause CLIPPED,
       " ORDER BY ped_duplicata.num_duplicata,",
                " ped_duplicata.dig_duplicata"

   IF NOT geo1015_declara_cursor(sql_stmt,'NF') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

 END FUNCTION

#-----------------------------------------------------#
 FUNCTION geo1015_declara_cursor(l_sql_stmt,l_origem)
#-----------------------------------------------------#
   DEFINE l_sql_stmt   VARCHAR(15000),
          l_origem     CHAR(02),
          l_msg        CHAR(30)

   WHENEVER ERROR CONTINUE
   PREPARE var_query FROM l_sql_stmt
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF l_origem = 'DC' THEN
         LET l_msg = 'DOCUM-1'
      ELSE
         LET l_msg = 'FAT_NF_DUPLICATA-1'
      END IF
      CALL log003_err_sql('SELEÇÃO',l_msg)
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   DECLARE cq_documentos CURSOR WITH HOLD FOR var_query
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF l_origem = 'DC' THEN
         LET l_msg = 'DOCUM-2'
      ELSE
         LET l_msg = 'FAT_NF_DUPLICATA-2'
      END IF
      CALL log003_err_sql('SELEÇÃO',l_msg)
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   OPEN cq_documentos
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF l_origem = 'DC' THEN
         LET l_msg = 'DOCUM-3'
      ELSE
         LET l_msg = 'FAT_NF_DUPLICATA-3'
      END IF
      CALL log003_err_sql('SELEÇÃO',l_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

 END FUNCTION

#--------------------------------------#
 FUNCTION geo1015_processa_impressao()
#--------------------------------------#

   DEFINE l_msg               CHAR(300)
   DEFINE l_qtd_dias_bloq LIKE cli_bloqueto.qtd_dias_bloq
   DEFINE l_houve_erro        SMALLINT,
          l_imprime               SMALLINT,
          l_retorno               SMALLINT,
          l_vence_hoje            SMALLINT,
          l_linha_digitavel       CHAR(99)

   DEFINE l_seq_obs     LIKE docum_obs.num_seq_docum,
          l_dat_obs     LIKE docum_obs.dat_obs,
          l_tex_obs_1   LIKE docum_obs.tex_obs_1,
          l_tex_obs_2   LIKE docum_obs.tex_obs_2,
          l_tex_obs_3   LIKE docum_obs.tex_obs_3,
          l_dat_atualiz LIKE docum_obs.dat_atualiz,
          l_mensagem    CHAR(200)

   DEFINE l_achou_dados SMALLINT
   DEFINE l_trans_nota_fiscal INTEGER

   INITIALIZE mr_docum TO NULL
   
   
   
   LET l_houve_erro  = FALSE
   LET l_achou_dados = FALSE

   LET m_formato = "P"
   LET g_reimpressao = FALSE
   CALL geo1015_grava_audit("1BOLETO NF "||mr_param.nota_fiscal_ini)
   
   SELECT DISTINCT trans_nota_fiscal
     INTO l_trans_nota_fiscal
     FROM fat_nf_mestre
    WHERE empresa = p_cod_empresa
      AND nota_fiscal = mr_param.nota_fiscal_ini
      AND serie_nota_fiscal = mr_param.serie_nota_fiscal
      #AND tip_nota_fiscal = mr_param.tip_nota_fiscal
    IF sqlca.sqlcode = 0 THEN
       CALL geo1015_grava_audit("1aBOLETO NF "||mr_param.nota_fiscal_ini||" TRANS "||l_trans_nota_fiscal)
    ELSE
       CALL geo1015_grava_audit("1bBOLETO NF "||mr_param.nota_fiscal_ini)
    END IF 
   
   
   #WHILE TRUE
   WHENEVER ERROR CONTINUE
   FOREACH cq_documentos INTO m_origem_duplicata,
	                              mr_docum.cod_empresa,
	                              mr_docum.num_docum,
	                              mr_docum.ies_tip_docum,
	                              mr_docum.cod_cliente, #541817
	                              mr_nota.trans_nota_fiscal,   #armazena o valor da ped_duplicata.num_duplicata - qndo for antecipação pedido
	                              mr_nota.seq_duplicata        #armazena o valor da ped_duplicata.dig_duplicata - qndo for antecipação pedido
	    WHENEVER ERROR STOP
	    INITIALIZE l_qtd_dias_bloq TO NULL
	    SELECT qtd_dias_bloq
	      INTO l_qtd_dias_bloq
	     FROM cli_bloqueto
	    WHERE cod_cliente = mr_docum.cod_cliente
	    IF sqlca.sqlcode = 0 THEN
	    	IF l_qtd_dias_bloq = 0 THEN
	    	   CALL geo1015_grava_audit("2BOLETO NFa l_qtd_dias_bloq = 0 - nao imprime boleto "||mr_param.nota_fiscal_ini)
	    	   CONTINUE FOREACH
	    	END IF 
	    END IF 
	    
	    CALL geo1015_grava_audit("2BOLETO NF "||mr_param.nota_fiscal_ini)
	    IF sqlca.sqlcode < 0 THEN
	       CALL log003_err_sql('FETCH','CQ_DOCUMENTOS')
	       LET l_houve_erro = TRUE
	       CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
	       EXIT FOREACH
	    END IF
	    CALL geo1015_grava_audit("3BOLETO NF "||mr_param.nota_fiscal_ini)
	    IF sqlca.sqlcode = 100 THEN
	       CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
	       EXIT FOREACH
        END IF
        CALL geo1015_grava_audit("4BOLETO NF "||mr_param.nota_fiscal_ini)
        #541817
        WHENEVER ERROR CONTINUE
        SELECT COUNT(*)
          FROM vdp_emp_cli_par
         WHERE empresa   = mr_docum.cod_empresa
           AND cliente   = mr_docum.cod_cliente
           AND parametro = 'GERA BLOQUETO'
           AND par_existencia <> 'S'
           HAVING COUNT(*) > 0
        WHENEVER ERROR STOP
        CALL geo1015_grava_audit("5BOLETO NF "||mr_param.nota_fiscal_ini)
        IF sqlca.sqlcode = 0 THEN
           #CONTINUE FOREACH
        END IF
        #Fim
        CALL geo1015_grava_audit("6BOLETO NF "||mr_param.nota_fiscal_ini)
        IF mr_docum.cod_empresa = m_empresa_anterior THEN
           LET m_empresa_mudou    = FALSE
        ELSE
           LET m_empresa_mudou    = TRUE
           LET m_empresa_anterior = mr_docum.cod_empresa
        END IF
        CALL geo1015_grava_audit("7BOLETO NF "||mr_param.nota_fiscal_ini)
        IF m_empresa_mudou THEN
           IF NOT geo1015_busca_parametros_por_empresa() THEN
              LET l_houve_erro = TRUE
              CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
              EXIT FOREACH
           END IF
        END IF
        CALL geo1015_grava_audit("8BOLETO NF "||mr_param.nota_fiscal_ini)
        #BEGIN deve ficar aqui, devido ao bloqueia da tabela PAR_BLOQUE_LASER
        CALL log085_transacao('BEGIN')
        CALL geo1015_grava_audit("9BOLETO NF "||mr_param.nota_fiscal_ini)
        IF NOT geo1015_busca_e_consiste_informacoes() THEN
           CALL log085_transacao('ROLLBACK')
           LET l_houve_erro = TRUE
           CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
           EXIT FOREACH
        END IF
        CALL geo1015_grava_audit("10BOLETO NF "||mr_param.nota_fiscal_ini)
        IF NOT m_imprime_boleto THEN
           CALL log085_transacao('ROLLBACK')
           CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
           CONTINUE FOREACH
        END IF
        CALL geo1015_grava_audit("11BOLETO NF "||mr_param.nota_fiscal_ini)
        IF NOT g_reimpressao THEN
           #Não permitir fazer a IMPRESSÃO de um documento já impresso.
           IF crem131_docum_banco_leitura(mr_docum.cod_empresa,
                                        mr_docum.num_docum,
                                        mr_docum.ies_tip_docum,
                                        m_portador,
                                        FALSE,1) THEN
              #RETIREI POIS ACHEI QUE AQUI PODERIA ESTAR OCASIONANDO A FALHA NA IMPRESSAO DOS BOLETOS
              CALL geo1015_grava_audit("11aBOLETO NF "||mr_param.nota_fiscal_ini)
              CALL log085_transacao('ROLLBACK')
              
              DELETE 
                FROM geo_reprocessa_boleto
               WHERE trans_nota_fiscal = l_trans_nota_fiscal
              CONTINUE FOREACH
           END IF
        END IF
        CALL geo1015_grava_audit("12BOLETO NF "||mr_param.nota_fiscal_ini)
        IF NOT geo1015_monta_arquivo_txt() THEN
           CALL log085_transacao('ROLLBACK')
           LET l_houve_erro = TRUE
           CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
           EXIT FOREACH
        END IF
        CALL geo1015_grava_audit("13BOLETO NF "||mr_param.nota_fiscal_ini)
        IF NOT geo1015_consiste_controle_numeracao_boleto() THEN
           CALL log085_transacao('ROLLBACK')
           LET l_houve_erro = TRUE
           CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
           EXIT FOREACH
        END IF
        CALL geo1015_grava_audit("14BOLETO NF "||mr_param.nota_fiscal_ini||" DOCUM "||mr_docum.num_docum||" TIP "||mr_docum.ies_tip_docum||" EMPRESA "||mr_docum.cod_empresa)
        IF NOT g_reimpressao THEN
           IF NOT geo1015_atualiza_par_bloqueto_laser() THEN
              CALL geo1015_grava_audit("14hBOLETO NF "||mr_param.nota_fiscal_ini)
              CALL log085_transacao("ROLLBACK")
              CALL geo1015_grava_audit("14iBOLETO NF "||mr_param.nota_fiscal_ini)
              LET l_houve_erro = TRUE
              CALL geo1015_grava_audit("14jBOLETO NF "||mr_param.nota_fiscal_ini)
              CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
              EXIT FOREACH
           ELSE
              # Abre uma nova transação (A FUNÇÃO geo1015_atualiza_par_bloqueto_laser() EFETUA O COMMIT
              # Necessário para minimizar erros de concorrencia.
              CALL geo1015_grava_audit("14kBOLETO NF "||mr_param.nota_fiscal_ini)
              CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
              CALL log085_transacao('BEGIN')
              CALL geo1015_grava_audit("14mBOLETO NF "||mr_param.nota_fiscal_ini)
           END IF
        END IF
        CALL geo1015_grava_audit("15BOLETO NF "||mr_param.nota_fiscal_ini)

        LET l_imprime = TRUE
        {WHENEVER ERROR CONTINUE
          SELECT parametro
            INTO m_par_clientes_cre_txt
            FROM clientes_cre_txt
           WHERE cod_cliente = mr_docum.cod_cliente
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
           CALL log003_err_sql("SELECT","DOCUM")
        END IF
        CALL geo1015_grava_audit("16BOLETO NF "||mr_param.nota_fiscal_ini)
        #IF m_par_clientes_cre_txt[304,304] = "S" THEN   # Sacado eletrônico
        #   IF m_par_clientes_cre_txt[305,305] = "N" THEN
              LET l_imprime = FALSE
           ELSE
              IF m_par_clientes_cre_txt[305,305] = "P" THEN
                 #IF NOT geo1015_pergunta() THEN
                    LET l_imprime = FALSE
                 #END IF
              END IF
           END IF
        END IF}
        CALL geo1015_grava_audit("17BOLETO NF "||mr_param.nota_fiscal_ini)
        WHENEVER ERROR CONTINUE
        
        #CREATE TABLE geo_inf_boleto (
        #   cod_empresa CHAR(2),
        #   nota_fiscal INTEGER,
        #   serie_nota_fiscal CHAR(3),
        #   linha_digitavel CHAR(99)
        #)
        
        
        LET l_linha_digitavel = gr_relat.txt_barras[1,5],
                                gr_relat.txt_barras[7,11],
                                gr_relat.txt_barras[13,17],
                                gr_relat.txt_barras[19,24],
                                gr_relat.txt_barras[26,30],
                                gr_relat.txt_barras[32,37],
                                gr_relat.txt_barras[39,39],
                                gr_relat.txt_barras[41,54]
                                       
        INSERT INTO geo_inf_boleto VALUES (p_cod_empresa, mr_param.nota_fiscal_ini, mr_param.serie_nota_fiscal, l_linha_digitavel, gr_relat.num_docum)
        IF sqlca.sqlcode <> 0 THEN
           INSERT INTO geo_audit VALUES (p_cod_empresa, 'geo1015',CURRENT,'ERRO INSERT: '||sqlca.sqlcode)
        END IF 
        WHENEVER ERROR STOP
        CALL geo1015_grava_audit("18BOLETO NF "||mr_param.nota_fiscal_ini)
        #:: IMPRESSÃO PDF PADRÃO ::# 724265
        CALL cre11001_monta_arquivo_formato_pdf(gr_relat.*          ,
                                                       gr_par_bloq_laser.* ,
                                                       mr_docum.*          ,
                                                       m_cedente           ,
                                                       m_sacador_avalista  ,
                                                       m_codigo_cip,
                                                       m_imprimir_endereco_cnpj_boleto,
                                                       m_qtd_vias)
         RETURNING p_nom_arquivo
         CALL geo1015_grava_audit("19BOLETO NF "||mr_param.nota_fiscal_ini)
         IF NOT g_reimpressao THEN

            #Efetua a atualização do código de barras
            IF NOT vdp0856_atualiza_bloqueto_fat_nf_duplicata(mr_docum.cod_empresa,
                                                              mr_nota.trans_nota_fiscal,
                                                              mr_nota.seq_duplicata,
                                                              m_portador,
                                                              gr_par_bloq_laser.num_agencia,
                                                              gr_par_bloq_laser.dig_agencia,
                                                             g_novo_numero,0) THEN
               CALL log085_transacao('ROLLBACK')
               LET l_houve_erro = TRUE
               CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
               EXIT FOREACH
            END IF
            CALL geo1015_grava_audit("20BOLETO NF "||mr_param.nota_fiscal_ini)
            IF NOT crem17_docum_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                    mr_docum.ies_tip_docum,FALSE,TRUE) THEN
               CALL geo1015_grava_audit("20aBOLETO NF "||mr_param.nota_fiscal_ini)
               CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
               RETURN FALSE
            END IF
            CALL geo1015_grava_audit("21BOLETO NF "||mr_param.nota_fiscal_ini)
            CALL crem17_docum_get_all() RETURNING mr_docum.*
            
            #Efetua a gravação/atualização do número do título bancário
            IF NOT geo1015_atualiza_docum_banco() THEN
               CALL log085_transacao('ROLLBACK')
               LET l_houve_erro = TRUE
               CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
               EXIT FOREACH
            END IF
            CALL geo1015_grava_audit("22BOLETO NF "||mr_param.nota_fiscal_ini)
            IF NOT geo1015_atualiza_determinacao_portador_documento() THEN
               CALL log085_transacao('ROLLBACK')
               LET l_houve_erro = TRUE
               CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
               EXIT FOREACH
            END IF
            CALL geo1015_grava_audit("23BOLETO NF "||mr_param.nota_fiscal_ini)
             #Efetua a atualização do código de barras
	        IF NOT geo1015_atualiza_cre_docum_compl() THEN
	           CALL log085_transacao('ROLLBACK')
	           LET l_houve_erro = TRUE
	           CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
	           EXIT FOREACH
	        END IF
	        CALL geo1015_grava_audit("24BOLETO NF "||mr_param.nota_fiscal_ini)
	        ## Fazer o IF diferente de NF e colocar a inclusao dentro.
	        IF NOT geo1015_inclui_docum_obs() THEN
	           CALL log085_transacao('ROLLBACK')
	           LET l_houve_erro = TRUE
	           CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
	           EXIT FOREACH
	        END IF
            CALL geo1015_grava_audit("25BOLETO NF "||mr_param.nota_fiscal_ini)
         END IF

         #Efetua a atualização do valor limite de emissão de boletos diário
         IF NOT geo1015_atualiza_fat_ctr_val_diario() THEN
            CALL log085_transacao('ROLLBACK')
            LET l_houve_erro = TRUE
            CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
            EXIT FOREACH
         END IF
         CALL geo1015_grava_audit("26BOLETO NF "||mr_param.nota_fiscal_ini)

         CALL log085_transacao('COMMIT')

         IF l_imprime THEN
            LET m_emitiu = TRUE
         END IF

         LET l_achou_dados = TRUE
         CALL geo1015_grava_audit("27BOLETO NF "||mr_param.nota_fiscal_ini)
   #END WHILE
   END FOREACH
   CALL geo1015_grava_audit("27aBOLETO NF "||mr_param.nota_fiscal_ini)
   WHENEVER ERROR CONTINUE
   CLOSE cq_documentos
   FREE cq_documentos
   WHENEVER ERROR STOP
   CALL geo1015_grava_audit("27bBOLETO NF "||mr_param.nota_fiscal_ini)
   
   IF l_houve_erro THEN
      CALL geo1015_grava_audit("28aBOLETO ERRO NF "||mr_param.nota_fiscal_ini||" TRANS "||l_trans_nota_fiscal)
      IF l_trans_nota_fiscal IS NOT NULL AND l_trans_nota_fiscal <> " " AND l_trans_nota_fiscal <> 0 THEN
         CALL geo1015_grava_audit("28bBOLETO ERRO NF "||mr_param.nota_fiscal_ini||" TRANS "||l_trans_nota_fiscal)
         CALL geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
      END IF
      CALL geo1015_grava_audit("28dBOLETO ERRO NF "||mr_param.nota_fiscal_ini||" TRANS "||l_trans_nota_fiscal)
      
      RETURN FALSE
   END IF
   
   CALL geo1015_grava_audit("28eBOLETO NF "||mr_param.nota_fiscal_ini)
   DELETE 
     FROM geo_reprocessa_boleto
    WHERE trans_nota_fiscal = l_trans_nota_fiscal
   CALL geo1015_grava_audit("28BOLETO NF "||mr_param.nota_fiscal_ini)
   RETURN TRUE

END FUNCTION

#-----------------------------------------------------------#
FUNCTION geo1015_grava_reprocessa_boleto(l_trans_nota_fiscal)
#-----------------------------------------------------------#
   DEFINE l_trans_nota_fiscal   INTEGER
      IF l_trans_nota_fiscal IS NOT NULL AND l_trans_nota_fiscal <> " " AND l_trans_nota_fiscal <> 0 THEN
         SELECT * 
           FROM geo_reprocessa_boleto
          WHERE trans_nota_fiscal = l_trans_nota_fiscal
         IF sqlca.sqlcode = NOTFOUND THEN
            CALL geo1015_grava_audit("28cBOLETO ERRO NF "||mr_param.nota_fiscal_ini||" TRANS "||l_trans_nota_fiscal)
            INSERT INTO geo_reprocessa_boleto VALUES (l_trans_nota_fiscal)
            IF sqlca.sqlcode <> 0 THEN
               CALL geo1015_grava_audit("28dBOLETO ERRO NF "||mr_param.nota_fiscal_ini||" TRANS "||l_trans_nota_fiscal)
            END IF 
         END IF 
      END IF 
END FUNCTION
#------------------------------------------------#
 FUNCTION geo1015_busca_parametros_por_empresa()
#------------------------------------------------#

   WHENEVER ERROR CONTINUE
     SELECT empresa.end_empresa,
            empresa.den_munic  ,
            empresa.den_bairro ,
            empresa.uni_feder  ,
            empresa.cod_cep    ,
            empresa.num_cgc
       INTO mr_empresa.end_empresa,
            mr_empresa.den_munic  ,
            mr_empresa.den_bairro ,
            mr_empresa.uni_feder  ,
            mr_empresa.cod_cep    ,
            mr_empresa.num_cgc
       FROM empresa
      WHERE empresa.cod_empresa = mr_docum.cod_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode < 0 THEN
      CALL log003_err_sql("SELECT","EMPRESA")
   END IF

   CALL log2250_busca_parametro(mr_docum.cod_empresa,'ver_cep_port_x_cep_cliente')
        RETURNING m_verifica_cep, m_status

   IF NOT m_status THEN
      RETURN FALSE
   END IF

   IF m_verifica_cep IS NULL OR m_verifica_cep = ' ' THEN
      LET m_verifica_cep = 'N'
   END IF

   #--------------------------------------------------------------------------------#
   #Leitura dos parâmetros do contas a receber para a empresa do documento

   INITIALIZE mr_empresa_cre_txt.* TO NULL

   IF NOT crem136_empresa_cre_txt_leitura(mr_docum.cod_empresa,FALSE,TRUE) THEN
      RETURN FALSE
   END IF

   LET mr_empresa_cre_txt.parametros = crem136_empresa_cre_txt_get_parametros()

   #--------------------------------------------------------------------------------#
   #Leitura dos parâmetros do VDP

   CALL log2250_busca_parametro(mr_docum.cod_empresa,'imp_bloq_end_cob')
      RETURNING m_imp_bloq_end_cob, m_status

   IF m_status = FALSE OR
      m_imp_bloq_end_cob IS NULL OR
      m_imp_bloq_end_cob = ' ' THEN
      LET m_imp_bloq_end_cob = 'S'
   END IF

   CALL log2250_busca_parametro(mr_docum.cod_empresa,'nr_bloqueto_empresa_consol')
      RETURNING m_nr_bloq_empresa_consol, m_status

   IF m_status = FALSE OR
      m_nr_bloq_empresa_consol IS NULL OR
      m_nr_bloq_empresa_consol = ' ' THEN
      LET m_nr_bloq_empresa_consol = 'N'
   END IF

   CALL log2250_busca_parametro(mr_docum.cod_empresa,'empresa_ctrl_cre')
      RETURNING m_empresa_ctrl_cre, m_status

   IF m_status = FALSE OR
      m_empresa_ctrl_cre IS NULL OR
      m_empresa_ctrl_cre = ' ' THEN
      LET m_empresa_ctrl_cre = mr_docum.cod_empresa
   END IF

   CALL log2250_busca_parametro(mr_docum.cod_empresa,'ies_reimp_bloq')
      RETURNING m_ies_reimp_bloq, m_status

   IF m_status = FALSE OR
      m_ies_reimp_bloq IS NULL OR
      m_ies_reimp_bloq = ' ' THEN
      LET m_ies_reimp_bloq = 'S'
   END IF

   CALL log2250_busca_parametro(mr_docum.cod_empresa,'qtd_dias_emissao_bloqueto')
      RETURNING m_qtd_dias_emis_bloq, m_status

   IF m_status = FALSE OR
      m_qtd_dias_emis_bloq IS NULL OR
      m_qtd_dias_emis_bloq = ' ' THEN
      INITIALIZE m_qtd_dias_emis_bloq TO NULL
   END IF

   RETURN TRUE

END FUNCTION


#------------------------------------------------#
 FUNCTION geo1015_busca_e_consiste_informacoes()
#------------------------------------------------#

   DEFINE l_portador                   LIKE port_corresp.cod_portador,
          l_port_corrsp_nom_port       CHAR(01),
          l_retorno                    SMALLINT

   DEFINE l_agrupamento                SMALLINT,
          l_cliente_especifico         SMALLINT,
          l_ja_impresso                SMALLINT,
          l_val_saldo_aux              LIKE docum.val_saldo,
          l_pct_desc                   LIKE adocum.pct_desc

   DEFINE l_ies_compl_emp              LIKE par_cre.ies_consol_emp,
          l_qtd_dias_protesto_cli      CHAR(02),
          l_msg                        CHAR(99)

   DEFINE l_logradouro                 LIKE cli_end_det_cobranca_entrega.logradouro,
          l_bairro                     LIKE cli_end_det_cobranca_entrega.bairro_cobr_entga,
          l_num_iden_lograd            LIKE cli_end_det_cobranca_entrega.num_iden_lograd



   LET m_imprime_boleto = TRUE

   INITIALIZE mr_cre_tit_cob_esp.* TO NULL

   #--------------------------------------------------------------------------------#
   #Leitura do documento a ser impresso
   CASE m_origem_duplicata

      WHEN 'DC' {DOCUM}

         IF NOT crem17_docum_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,FALSE,TRUE) THEN
            RETURN FALSE
         END IF

         CALL crem17_docum_get_all() RETURNING mr_docum.*

         #572487
         IF mr_docum.ies_tip_cobr = 'V' THEN
            CALL crer44_leitura_cre_tit_cob_esp(mr_docum.cod_empresa,
                                                  mr_docum.num_docum,
                                                  mr_docum.ies_tip_docum,
                                                  mr_docum.ies_tip_cobr,TRUE)
              RETURNING m_status, mr_cre_tit_cob_esp.*

            IF NOT m_status THEN
               LET m_vendor_sem_contrato = TRUE

               LET m_imprime_boleto = FALSE
               RETURN TRUE
            END IF
         END IF

         LET m_pct_desc_financ = mr_docum.pct_desc

         INITIALIZE l_pct_desc TO NULL

         WHENEVER ERROR CONTINUE
         SELECT parametro[1,6]
           INTO l_pct_desc
           FROM docum_txt
          WHERE cod_empresa   = mr_docum.cod_empresa
            AND num_docum     = mr_docum.num_docum
            AND ies_tip_docum = mr_docum.ies_tip_docum
         WHENEVER ERROR STOP
         IF sqlca.sqlcode = 0 AND l_pct_desc IS NOT NULL AND l_pct_desc > 0 THEN
            LET m_pct_desc_financ = l_pct_desc
         END IF

      WHEN 'NF' {NOTA FISCAL}

         IF NOT geo1015_busca_dados_nota_fiscal() THEN
            RETURN FALSE
         END IF

      WHEN 'AN' {ANTECIPAÇÃO PEDIDO}

         IF NOT geo1015_busca_dados_pedido() THEN
            RETURN FALSE
         END IF

   END CASE

   {Verifica parâmetro que indica se deverá ser utilizado o valor saldo ou bruto do documento
    #572487
    Se for duplicata vendor, obtém o valor da cre_tit_cob_esp.
    Se for duplicata não vendor ou for nota fiscal, obtém da docum ou dat fat_nf_mestre
   }
   IF m_origem_duplicata = 'DC' AND mr_docum.ies_tip_cobr = 'V' THEN {DOCUM}
      IF UPSHIFT(mr_empresa_cre_txt.parametros[350,350]) = 'S' THEN
         LET m_val_boleto = mr_cre_tit_cob_esp.val_saldo_cliente
      ELSE
         LET m_val_boleto = mr_cre_tit_cob_esp.val_parcela_cliente
      END IF
   ELSE
      IF UPSHIFT(mr_empresa_cre_txt.parametros[350,350]) = 'S' THEN
         LET m_val_boleto = mr_docum.val_saldo
      ELSE
         LET m_val_boleto = mr_docum.val_bruto
      END IF
   END IF

   #--------------------------------------------------------------------------------#
   #Verifica se a forma de pagamento do pedido é 'BO' (boleto) e se a quantidade de
   #dias limite para a emissão de boletos não excedeu.

   IF g_reimpressao = FALSE OR mr_param.origem = 'NF' THEN
      IF NOT geo1015_consiste_quantidade_dias_vencimento() THEN
         LET m_imprime_boleto = FALSE
         RETURN TRUE
      END IF
   END IF



   #--------------------------------------------------------------------------------#
   #Leitura dos dados do cliente do documento

   IF NOT vdpm7_clientes_leitura(mr_docum.cod_cliente,FALSE,TRUE) THEN
      RETURN FALSE
   END IF

   #--------------------------------------------------------------------------------#
   #Verifica se imprime bloqueto para cliente com endereço de cobrança

   IF (m_origem_duplicata = 'NF' OR m_origem_duplicata = 'AN') AND m_imp_bloq_end_cob = 'N' THEN
      IF vdpm188_cli_end_cob_leitura(mr_docum.cod_cliente,FALSE,1) THEN

         LET m_imprime_boleto = FALSE
         RETURN TRUE
      END IF
   END IF

   #--------------------------------------------------------------------------------#
   #Verifica parametrização e define o Portador que será utilizado na impressão do boleto

   IF m_origem_duplicata = 'DC' THEN
      IF mr_docum.cod_portador > 0 THEN
         LET m_portador = mr_docum.cod_portador
      ELSE
         IF mr_tela.ies_sem_port_tipo_emis = 'U' THEN
            LET m_portador = vdpm7_clientes_get_cod_portador()
         ELSE
            LET m_portador = mr_tela.portador_determ
         END IF
      END IF
   ELSE
      IF mr_tela.ies_sem_port_tipo_emis = 'P' {3} THEN
         LET m_portador = mr_tela.portador_determ
      END IF

      IF mr_tela.ies_sem_port_tipo_emis = 'U' {1} OR
         mr_tela.ies_sem_port_tipo_emis = 'C' {2} OR
         mr_tela.ies_sem_port_tipo_emis = 'S' {4} OR
         mr_tela.ies_sem_port_tipo_emis = '5'   THEN

         IF vdpm7_clientes_get_cod_portador() IS NOT NULL AND
            vdpm7_clientes_get_cod_portador() <> ' ' THEN

            IF mr_tela.ies_sem_port_tipo_emis = 'C' {2} OR
               mr_tela.ies_sem_port_tipo_emis = 'S' {4} THEN

               IF vdpm7_clientes_get_cod_portador() = mr_tela.portador_determ THEN
                  LET m_portador = vdpm7_clientes_get_cod_portador()
               ELSE
                  LET m_imprime_boleto = FALSE
                  RETURN TRUE
               END IF
            ELSE
               LET m_portador = vdpm7_clientes_get_cod_portador()
            END IF
         ELSE
            IF mr_tela.ies_sem_port_tipo_emis = 'S' {4} THEN
               LET m_portador = mr_tela.portador_determ
            ELSE
               LET m_imprime_boleto = FALSE
               RETURN TRUE
            END IF
         END IF
      END IF

      #-----------------------------------------------------------------------------#
      # Tipo 5, utiliza o portador da primeira impressão, se houver

      IF mr_tela.ies_sem_port_tipo_emis = '5' AND
         mr_docum.cod_portador IS NOT NULL AND
         mr_docum.cod_portador <> ' ' THEN
         LET m_portador = mr_docum.cod_portador
      END IF

      #-----------------------------------------------------------------------------#
      # Verifica se tem cadastro de portador por período

      IF mr_tela.ies_sem_port_tipo_emis = 'U' OR {1}
         mr_tela.ies_sem_port_tipo_emis = '5' THEN
         CALL geo1015_determina_portador()
      END IF

      #-----------------------------------------------------------------------------#
      # Verifica se permite reimpressão de bloqueto para portador diferente

      IF g_reimpressao = TRUE AND m_ies_reimp_bloq = 'N' AND
         mr_tela.portador_determ <> vdpm121_fat_nf_duplicata_get_portador() THEN
         LET m_imprime_boleto = FALSE
         RETURN TRUE
      END IF

   END IF
   LET l_msg = '1- Portador',m_portador," NF ",mr_param.nota_fiscal_ini
   INSERT INTO geo_audit VALUES (p_cod_empresa, 'geo1015',CURRENT,l_msg)
   LET l_msg = ""
   IF NOT geo1015_consiste_portador(m_portador) THEN
      RETURN FALSE
   END IF

   #--------------------------------------------------------------------------------#
   #Verifica tipo de cobrança do pedido

   IF (m_origem_duplicata = 'NF' OR m_origem_duplicata = 'AN') THEN
      IF geo1015_tipo_cobranca_pedido_nao_emite_boleto() THEN
         LET m_imprime_boleto = FALSE
         RETURN TRUE
      END IF
   END IF

   #--------------------------------------------------------------------------------#
   #Efetua validação do código do CEP do portador

   IF m_verifica_cep = 'S' THEN
      CALL geo1015_consiste_cep_portador()
           RETURNING m_status, m_imprime_boleto

      IF NOT m_status THEN
         RETURN FALSE
      END IF

      IF NOT m_imprime_boleto THEN
         RETURN TRUE
      END IF
   END IF

   #--------------------------------------------------------------------------------#
   #Consiste se o valor do boleto está dentro do limite diário de emissão de boletos

   IF NOT g_reimpressao THEN
      IF NOT geo1015_consiste_val_limite_diario_boletos() THEN
         RETURN FALSE
      END IF
   END IF

   #--------------------------------------------------------------------------------#
   #Leitura e consistência dos dados da docum_banco

   CASE m_origem_duplicata
      WHEN 'DC'
         IF crem131_docum_banco_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                        mr_docum.ies_tip_docum,m_portador,TRUE,TRUE) THEN

            LET mr_docum_banco.num_titulo_banco = crem131_docum_banco_get_num_titulo_banco()

            IF NOT g_reimpressao THEN
               IF mr_docum_banco.num_titulo_banco IS NOT NULL AND
                  mr_docum_banco.num_titulo_banco <> ' ' THEN
                  LET m_imprime_boleto = FALSE
                  RETURN TRUE
               END IF
            END IF
         ELSE
            IF g_reimpressao THEN {?}
               CALL log0030_exibe_ultima_mensagem()
               RETURN FALSE
            END IF
         END IF

      WHEN 'NF' {m_origem_duplicata = 'NF'}

         #--------------------------------------------------------------------------------#
         #Busca o título bancário utilizado na primeira impressão do bloqueto
         IF g_reimpressao THEN
            LET mr_docum_banco.num_titulo_banco = vdpm121_fat_nf_duplicata_get_titulo_bancario()
         END IF

      WHEN 'AN'
         IF g_reimpressao THEN
            LET mr_docum_banco.num_titulo_banco = m_titulo_bancario
         END IF
   END CASE

   #--------------------------------------------------------------------------------#

   #Função específica cliente 834 - SOMAT: agrupamento de NSs e DPs na impressão/
   #reimpressão do boleto (OS 422113).
   #O processo de agrupamento deverá ser realizado somente para documentos do tipo
   #'DP' e com portador de impressão UNIBANCO.

   IF m_origem_duplicata = 'DC' THEN

      {572487 Para essa EPL, não foi previsto a leitura da cre_tit_cob_esp para o somatório
       do saldo de documento.}
      IF Find4GLFunction('crey2_agrupamento') THEN #OS 594370
         CALL crey2_agrupamento(mr_docum.*, m_portador_impressao)
              RETURNING l_agrupamento, l_cliente_especifico, l_ja_impresso, l_val_saldo_aux
      ELSE
         LET l_cliente_especifico = FALSE
      END IF

      IF l_cliente_especifico THEN
         IF l_agrupamento THEN
            IF l_ja_impresso THEN
               LET m_imprime_boleto = FALSE
               RETURN TRUE
            END IF

            LET mr_docum.val_saldo = l_val_saldo_aux
         END IF
      END IF
   END IF

   #--------------------------------------------------------------------------------#
   #Verifica se busca os parâmetros de impressão pela empresa consolidadora ou do documento

   LET m_cod_empresa_matr = mr_docum.cod_empresa

   #Verifica os parâmetros que indicam se serão utilizados os parâmetros de
   #impressão de boletos da empresa consolidadora ou da empresa do documento.

   IF m_nr_bloq_empresa_consol = 'S' THEN

      LET l_ies_compl_emp = crem2_par_cre_get_ies_consol_emp()

      IF l_ies_compl_emp = 'S' THEN

         WHENEVER ERROR CONTINUE
         SELECT cod_empresa
           INTO m_cod_empresa_matr
           FROM empresa_consol
          WHERE cod_programa    = 'geo1015'
            AND cod_empr_consol = mr_docum.cod_empresa
         WHENEVER ERROR STOP

         IF sqlca.sqlcode < 0 THEN
            CALL log003_err_sql('SELEÇÃO','EMPRESA_CONSOL-1')
            RETURN FALSE
         ELSE
            IF sqlca.sqlcode = NOTFOUND THEN
               {Procurar tbem pelo VDP2197 para cadastros antigos}
               WHENEVER ERROR CONTINUE
               SELECT cod_empresa
                 INTO m_cod_empresa_matr
                 FROM empresa_consol
                WHERE cod_programa    = 'VDP2197'
                  AND cod_empr_consol = mr_docum.cod_empresa
               WHENEVER ERROR STOP

               IF sqlca.sqlcode < 0 THEN
                  CALL log003_err_sql('SELEÇÃO','EMPRESA_CONSOL-2')
                  RETURN FALSE
               END IF
            END IF
         END IF

         IF sqlca.sqlcode = 100 OR
            m_cod_empresa_matr IS NULL OR
            m_cod_empresa_matr = '  ' THEN
            LET m_cod_empresa_matr = mr_docum.cod_empresa
         END IF
      END IF
   END IF

   #--------------------------------------------------------------------------------#
   #Leitura dos parâmetros de impressão usando a empresa definida acima

   IF NOT g_reimpressao THEN
      IF NOT vdpm315_par_bloqueto_laser_bloqueio_registro(m_cod_empresa_matr,m_portador,FALSE) THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT vdpm315_par_bloqueto_laser_leitura(m_cod_empresa_matr,m_portador,TRUE,TRUE) THEN
      RETURN FALSE
   END IF

   LET gr_par_bloq_laser.cod_empresa      = vdpm315_par_bloqueto_laser_get_cod_empresa()
   LET gr_par_bloq_laser.cod_portador     = vdpm315_par_bloqueto_laser_get_cod_portador()
   LET gr_par_bloq_laser.dig_portador     = vdpm315_par_bloqueto_laser_get_dig_portador()
   LET gr_par_bloq_laser.num_agencia      = vdpm315_par_bloqueto_laser_get_num_agencia()
   LET gr_par_bloq_laser.dig_agencia      = vdpm315_par_bloqueto_laser_get_dig_agencia()
   LET gr_par_bloq_laser.num_conta        = vdpm315_par_bloqueto_laser_get_num_conta()
   LET gr_par_bloq_laser.dig_conta        = vdpm315_par_bloqueto_laser_get_dig_conta()
   LET gr_par_bloq_laser.cod_cedente      = vdpm315_par_bloqueto_laser_get_cod_cedente()
   LET gr_par_bloq_laser.num_ult_bloqueto = vdpm315_par_bloqueto_laser_get_num_ult_bloqueto()
   LET gr_par_bloq_laser.instrucoes_1     = vdpm315_par_bloqueto_laser_get_instrucoes_1()
   LET gr_par_bloq_laser.instrucoes_2     = vdpm315_par_bloqueto_laser_get_instrucoes_2()
   LET gr_par_bloq_laser.instrucoes_3     = vdpm315_par_bloqueto_laser_get_instrucoes_3()
   LET gr_par_bloq_laser.instrucoes_4     = vdpm315_par_bloqueto_laser_get_instrucoes_4()
   LET gr_par_bloq_laser.par_bloq_txt     = vdpm315_par_bloqueto_laser_get_par_bloq_txt()

   LET g_cod_carteira                     = gr_par_bloq_laser.par_bloq_txt[20,21]

   #--------------------------------------------------------------------------------#
   #Leitura dos dados da empresa do documento

   IF NOT logm2_empresa_leitura(mr_docum.cod_empresa,FALSE,TRUE) THEN
      RETURN FALSE
   END IF

   #--------------------------------------------------------------------------------#
   #Busca o percentual de juro de mora do documento

   IF m_origem_duplicata = 'DC' THEN

      WHENEVER ERROR CONTINUE
        SELECT pct_juro_mora
          INTO m_pct_juro_mora
          FROM docum
         WHERE cod_empresa = mr_docum.cod_empresa
           AND num_docum = mr_docum.num_docum
           AND ies_tip_docum = mr_docum.ies_tip_docum
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         IF sqlca.sqlcode <> 100 THEN
            CALL log003_err_sql('SELECT','DOCUM')
         ELSE
            LET m_pct_juro_mora = 0
         END IF
      END IF

   ELSE {m_origem_duplicata = 'NF'}

      CALL geo1015_busca_clientes_cre_txt()

      IF m_par_clientes_cre_txt[11,11] = "N" THEN
         LET m_pct_juro_mora = 0
      ELSE

         IF m_par_clientes_cre_txt[05,10] > 0 THEN
            LET m_pct_juro_mora = m_par_clientes_cre_txt[05,10]
         ELSE
            WHENEVER ERROR CONTINUE
            SELECT pct_juro_mora
              INTO m_pct_juro_mora
              FROM juro_mora
             WHERE cod_empresa = mr_docum.cod_empresa
               AND dat_ini IN (SELECT MAX(dat_ini)
                                 FROM juro_mora
                                WHERE cod_empresa = mr_docum.cod_empresa)
            WHENEVER ERROR STOP

            IF sqlca.sqlcode < 0 THEN
               CALL log003_err_sql('SELEÇÃO','JURO_MORA')
               RETURN FALSE
            END IF

            IF m_pct_juro_mora IS NULL THEN
               LET m_pct_juro_mora = 0
            END IF
         END IF
      END IF
   END IF

   #--------------------------------------------------------------------------------#
   #Busca endereço de cobrança do cliente, conforme parametrizado no VDP2822

   IF gr_par_bloq_laser.par_bloq_txt[142] = 'C' THEN

      IF vdpm188_cli_end_cob_leitura(mr_docum.cod_cliente,FALSE,TRUE) THEN

         INITIALIZE l_logradouro, l_num_iden_lograd, l_bairro TO NULL

         IF vdpm557_cli_end_det_cobranca_entrega_leitura(mr_docum.cod_cliente,
                     'C',         # tipo C indica que é endereço de cobrança.
                     1,           #No caso de endereço de cobrança é sempre 1
                     TRUE, TRUE) THEN
             LET l_logradouro      = vdpm557_cli_end_det_cobranca_entrega_get_logradouro()
             LET l_num_iden_lograd = vdpm557_cli_end_det_cobranca_entrega_get_num_iden_lograd()
             LET l_bairro          = vdpm557_cli_end_det_cobranca_entrega_get_bairro_cobr_entga()
         END IF

         IF l_logradouro IS NULL OR l_logradouro = ' ' THEN
            LET mr_dados_cliente.end_cliente = vdpm188_cli_end_cob_get_end_cobr()
         ELSE
            LET mr_dados_cliente.end_cliente = l_logradouro clipped, ', ', l_num_iden_lograd
         END IF

         IF l_bairro IS NULL OR l_bairro = ' ' THEN
            LET mr_dados_cliente.den_bairro  = vdpm188_cli_end_cob_get_den_bairro()
         ELSE
            LET mr_dados_cliente.den_bairro  = l_bairro
         END IF

         LET mr_dados_cliente.cod_cidade  = vdpm188_cli_end_cob_get_cod_cidade_cob()
         LET mr_dados_cliente.cod_cep     = vdpm188_cli_end_cob_get_cod_cep()
      ELSE
         LET mr_dados_cliente.end_cliente = vdpm7_clientes_get_end_cliente()
         LET mr_dados_cliente.den_bairro  = vdpm7_clientes_get_den_bairro()
         LET mr_dados_cliente.cod_cidade  = vdpm7_clientes_get_cod_cidade()
         LET mr_dados_cliente.cod_cep     = vdpm7_clientes_get_cod_cep()
      END IF
   ELSE
      LET mr_dados_cliente.end_cliente = vdpm7_clientes_get_end_cliente()
      LET mr_dados_cliente.den_bairro  = vdpm7_clientes_get_den_bairro()
      LET mr_dados_cliente.cod_cidade  = vdpm7_clientes_get_cod_cidade()
      LET mr_dados_cliente.cod_cep     = vdpm7_clientes_get_cod_cep()
   END IF


   #--------------------------------------------------------------------------------#
   #Leitura dos dados da cidade do cliente

   IF NOT vdpm1_cidades_leitura(mr_dados_cliente.cod_cidade,FALSE,TRUE) THEN
      RETURN FALSE
   END IF

   #--------------------------------------------------------------------------------#
   #Verifica se o cliente é protestável

   CALL log2250_busca_parametro( mr_docum.cod_empresa, "consdr_cli_nao_protes" )
        RETURNING m_consdr_cli_nao_protes, m_status

   IF NOT m_status THEN
      RETURN FALSE
   END IF

   CALL geo1015_busca_parametro_escrit_compl(mr_docum.cod_empresa,'Dias para protestar')
        RETURNING m_status, l_qtd_dias_protesto_cli

   IF NOT m_status THEN
      RETURN FALSE
   END IF

   LET m_qtd_dias_protesto = l_qtd_dias_protesto_cli

   IF crem177_clientes_cre_leitura(mr_docum.cod_cliente,FALSE,TRUE) THEN
      LET m_ies_protesto      = crem177_clientes_cre_get_ies_protesto()
      LET m_qtd_dias_protesto = crem177_clientes_cre_get_qtd_dias_protesto()

      IF m_qtd_dias_protesto <= 0 THEN
         LET m_qtd_dias_protesto = l_qtd_dias_protesto_cli

         IF m_qtd_dias_protesto IS NOT NULL THEN
            IF m_qtd_dias_protesto > 0 THEN
               LET m_ies_protesto = 'S'
            ELSE
               LET m_ies_protesto = 'N'
            END IF
         ELSE
            LET m_ies_protesto = 'N'
         END IF

      END IF
   ELSE
      IF m_consdr_cli_nao_protes IS NULL OR m_consdr_cli_nao_protes = 'N' THEN
         LET m_ies_protesto = 'S'
      ELSE
         LET m_ies_protesto = 'N'
      END IF
   END IF

   #--------------------------------------------------------------------------------#
   #Verifica se deverá ser utilizado o nome do portador correspondente ou
   #do portador do documento na impressão do boleto bancário

   LET m_portador_original = m_portador #Ch. 751379

   INITIALIZE m_portador_correspondente TO NULL

   IF trbm15_port_corresp_leitura(m_portador,FALSE,TRUE) THEN
      LET m_portador_correspondente = trbm15_port_corresp_get_cod_port_corresp()
   END IF

   IF m_portador_correspondente IS NULL OR m_portador_correspondente = ' ' THEN
      LET m_portador_correspondente = m_portador_original
   END IF

   CALL log2250_busca_parametro(mr_docum.cod_empresa,'imprime_corrp_blqt_banc')
      RETURNING l_port_corrsp_nom_port, m_status

   #Se o parâmetro estiver desativado, continua buscando a PORTADOR da forma antiga, ou seja, usando a variável m_portador
   IF l_port_corrsp_nom_port = 'S' THEN
      LET l_portador = m_portador_correspondente
   ELSE
      LET l_portador = m_portador_original
   END IF

   IF NOT crem15_portador_leitura(l_portador,'B',TRUE,TRUE) THEN
      RETURN FALSE
   END IF

   #--------------------------------------------------------------------------------#
   #Efetua a amarração das notas de crédito do CRE
   IF NOT geo1015_efetua_amarracao_com_cre() THEN
      RETURN FALSE
   END IF

   IF Find4GLFunction("crey52_funcao_especifico_1131") THEN
      IF NOT crey52_efetua_amarracao_com_cre_notas_debito( mr_docum.cod_empresa   ,
                                                           mr_docum.num_docum     ,
                                                           mr_docum.ies_tip_docum ,
                                                           mr_docum.cod_cliente   ) THEN
         RETURN FALSE
      END IF

      IF crey52_get_outros_acrescimos() > 0 THEN
         LET m_val_boleto = m_val_boleto + crey52_get_outros_acrescimos()
      END IF

   END IF

   #--------------------------------------------------------------------------------#
   IF m_origem_duplicata = 'DC' THEN
      IF crer1_cre_fat_unico_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,0,'F','',TRUE) THEN

         IF vdpm95_fat_nf_mestre_get_nota_fiscal() IS NOT NULL THEN
            #LET m_val_nota_fiscal   = vdpm95_fat_nf_mestre_get_val_nota_fiscal()
         END IF

      ELSE
         RETURN FALSE
      END IF
   END IF
   #--------------------------------------------------------------------------------#

   #--------------------------------------------------------------------------------#
   #Verifica se existe nome do cedente parametrizado para o portador

   INITIALIZE m_cedente TO NULL

   CALL log2250_busca_parametro(p_cod_empresa,'emite_cedente_port_corresp')
        RETURNING m_imprime_cedente, m_status
   IF m_imprime_cedente IS NULL OR m_imprime_cedente = " " OR m_status = FALSE THEN
      LET m_imprime_cedente = 'N'
   END IF

   IF m_imprime_cedente = 'S' THEN
      IF vdpm327_vdp_par_blqt_compl_leitura(m_cod_empresa_matr,m_portador_correspondente,'Cedente Bloqueto',FALSE,TRUE) THEN
         LET m_cedente = vdpm327_vdp_par_blqt_compl_get_parametro_texto()
         IF m_cedente = ' ' THEN
            LET m_cedente = NULL
         END IF
      END IF
   ELSE
      IF vdpm327_vdp_par_blqt_compl_leitura(m_cod_empresa_matr,m_portador_original,'Cedente Bloqueto',FALSE,TRUE) THEN
         LET m_cedente = vdpm327_vdp_par_blqt_compl_get_parametro_texto()
         IF m_cedente = ' ' THEN
            LET m_cedente = NULL
         END IF
      END IF
   END IF
   #Fim Ch. 751379

   IF vdpm327_vdp_par_blqt_compl_leitura(m_cod_empresa_matr,m_portador,'codigo_cip',FALSE,TRUE) THEN
      LET m_codigo_cip = vdpm327_vdp_par_blqt_compl_get_parametro_texto()

      IF m_codigo_cip = ' ' THEN
         LET m_codigo_cip = NULL
      END IF
   END IF

   #--------------------------------------------------------------------------------#

   #Ch. 751379
   CALL log2250_busca_parametro(p_cod_empresa,'emite_sac_aval_port_corresp')
        RETURNING m_imprime_sacador, m_status
   IF m_imprime_sacador IS NULL OR m_imprime_sacador = " " OR m_status = FALSE THEN
      LET m_imprime_sacador = 'N'
   END IF

   IF m_imprime_sacador = 'S' THEN
      LET m_sacador_avalista = ""
      IF vdpm327_vdp_par_blqt_compl_leitura(m_cod_empresa_matr,m_portador_correspondente,'Sacador/Avalista',FALSE,TRUE) THEN
         LET m_sacador_avalista = vdpm327_vdp_par_blqt_compl_get_parametro_texto()
      END IF
   ELSE
      LET m_sacador_avalista = ""
      IF vdpm327_vdp_par_blqt_compl_leitura(m_cod_empresa_matr,m_portador_original,'Sacador/Avalista',FALSE,TRUE) THEN
         LET m_sacador_avalista = vdpm327_vdp_par_blqt_compl_get_parametro_texto()
      END IF
   END IF
   #Fim Ch. 751379

   LET m_imprime_desp_fin = ""
   IF vdpm327_vdp_par_blqt_compl_leitura(m_cod_empresa_matr,m_portador,'despesa_fin',FALSE,TRUE) THEN
      LET m_imprime_desp_fin = vdpm327_vdp_par_blqt_compl_get_par_existencia()
   END IF

   RETURN TRUE

END FUNCTION


#-------------------------------------------------------#
 FUNCTION geo1015_consiste_quantidade_dias_vencimento()
#-------------------------------------------------------#

   DEFINE l_qtd_dia_boleto    LIKE vdp_cli_bloqueto.qtd_dia_bloqueto,
          l_forma_pagto       LIKE ped_compl_pedido.forma_pagto,
          l_diferenca_data    LIKE cli_bloqueto.qtd_dias_bloq

   IF mr_docum.dat_prorrogada IS NOT NULL THEN
      LET l_diferenca_data = mr_docum.dat_prorrogada    - mr_docum.dat_emis
   ELSE
      LET l_diferenca_data = mr_docum.dat_vencto_s_desc - mr_docum.dat_emis
   END IF

   #------------------------------------------------------------------------#
   #Busca a forma de pagamento do pedido

   CALL geo1015_busca_forma_pagamento_pedido()
      RETURNING l_forma_pagto

   IF l_forma_pagto IS NULL THEN
      LET l_forma_pagto = '  '
   END IF

   #------------------------------------------------------------------------#
   #Verifica a quantidade de dias limite para a emissão dos boletos por empresa e cliente

   IF vdpm323_vdp_cli_bloqueto_leitura(mr_docum.cod_empresa,mr_docum.cod_cliente,FALSE,TRUE) THEN
      LET l_qtd_dia_boleto = vdpm323_vdp_cli_bloqueto_get_qtd_dia_bloqueto()
   ELSE
      #Se não encontrar, verifica a quantidade na tabela por cliente
      IF vdpm324_cli_bloqueto_leitura(mr_docum.cod_cliente,FALSE,TRUE) THEN
         LET l_qtd_dia_boleto = vdpm324_cli_bloqueto_get_qtd_dias_bloq()
      ELSE
         #Se não encontrar, verifica a quantidade de dias na tabela por empresa
         LET l_qtd_dia_boleto = m_qtd_dias_emis_bloq
      END IF
   END IF

   IF  l_qtd_dia_boleto IS NOT NULL
   AND l_qtd_dia_boleto > 0 THEN

      IF l_diferenca_data > l_qtd_dia_boleto AND
         l_forma_pagto   <> 'BO' THEN
         RETURN FALSE
      END IF

   END IF

   RETURN TRUE

END FUNCTION


#-----------------------------------------------#
 FUNCTION geo1015_consiste_portador(l_portador)
#-----------------------------------------------#

   DEFINE l_portador                  LIKE portador.cod_portador

   DEFINE l_cont                      SMALLINT,
          l_port_char_consol          CHAR(04)

   DEFINE l_msg                       CHAR(80)
   

   INITIALIZE m_portador_char         TO NULL
   INITIALIZE m_portador              TO NULL
   INITIALIZE m_portador_impressao    TO NULL
   INITIALIZE m_tem_par_boleto_port   TO NULL
   LET l_msg = '2- Portador'||l_portador||" NF "||mr_param.nota_fiscal_ini
   INSERT INTO geo_audit VALUES (p_cod_empresa, 'geo1015',CURRENT,l_msg)
   LET l_msg = ""
   IF NOT crem15_portador_existe(l_portador,'B',FALSE,FALSE) THEN
      RETURN FALSE
   END IF

   #Checando se existe parametros para o portador informado no VDP2822.
   WHENEVER ERROR CONTINUE
   SELECT portador,
          par_existencia
     INTO m_portador,
          m_tem_par_boleto_port
     FROM cre_portador_compl
    WHERE port_consolidado = l_portador
      AND campo            = 'par_blqt_port_doc'
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 0 AND m_tem_par_boleto_port = 'S' THEN
      LET m_portador_char = l_portador USING '&&&&'
      LET m_portador      = l_portador
   ELSE
      IF m_portador IS NULL THEN
         WHENEVER ERROR CONTINUE
         SELECT UNIQUE(portador)
           INTO m_portador
           FROM cre_portador_compl
          WHERE port_consolidado = l_portador
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 OR m_portador IS NULL THEN
            LET m_portador = l_portador
         END IF
      END IF

      LET m_portador_char = m_portador USING '&&&&'
   END IF

   LET l_cont = 0

   WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_cont
     FROM par_bloqueto_laser
    WHERE cod_portador = m_portador
   WHENEVER ERROR STOP

   IF sqlca.sqlcode < 0 THEN
      CALL log003_err_sql('SELEÇÃO','PAR_BLOQUETO_LASER')
      RETURN FALSE
   END IF

   IF l_cont = 0 THEN
      LET l_msg = 'Parâmetros para o Portador ', m_portador_char CLIPPED, ' não cadastrados (VDP2822).'
      CALL log0030_mensagem(l_msg,'exclamation')
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE      #Checando se o programa esta preparado para imprimir nesse banco.
   SELECT UNIQUE(portador)      #O portador da impressao pode ser diferente do portador dos
     INTO m_portador_impressao  #parametros de impressao de boletos.
     FROM cre_portador_compl
    WHERE port_consolidado = l_portador
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 0 THEN
      LET m_portador_char      = m_portador_impressao USING '&&&&'
   ELSE
      LET m_portador_impressao = m_portador_char
   END IF

   IF m_portador_char[2,4] <> '001' AND
      m_portador_char[2,4] <> '237' AND
      m_portador_char[2,4] <> '275' AND
      m_portador_char[2,4] <> '341' AND
      m_portador_char[2,4] <> '356' AND
      m_portador_char[2,4] <> '399' AND
      m_portador_char[2,4] <> '409' AND
      m_portador_char[2,4] <> '422' AND
      m_portador_char[2,4] <> '074' AND
      m_portador_char[2,4] <> '394' AND
      m_portador_char[2,4] <> '027' AND
      m_portador_char[2,4] <> '033' AND
      m_portador_char[2,4] <> '038' AND
      m_portador_char[2,4] <> '041' AND
      m_portador_char[2,4] <> '104' AND
      m_portador_char[2,4] <> '231' AND
      m_portador_char[2,4] <> '291' AND
      m_portador_char[2,4] <> '347' AND
      m_portador_char[2,4] <> '353' AND
      m_portador_char[2,4] <> '389' AND
      m_portador_char[2,4] <> '392' AND
      m_portador_char[2,4] <> '453' AND
      m_portador_char[2,4] <> '479' AND
      m_portador_char[2,4] <> '025' AND
      m_portador_char[2,4] <> '044' AND
      m_portador_char[2,4] <> '004' AND
      m_portador_char[2,4] <> '745' THEN    {Os 537265 Ivanele}

      LET l_msg = 'Não existe impressão de boleto para o Portador: ', m_portador_char
      CALL log0030_mensagem(l_msg,'exclamation')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#-----------------------------------------#
 FUNCTION geo1015_consiste_cep_portador()
#-----------------------------------------#

   DEFINE l_portador           LIKE vdp_port_sequencia.portador,
          l_cod_cep            CHAR(09),
          l_msg                CHAR(170)

   INITIALIZE l_msg TO NULL

   IF m_verifica_cep = 'S' THEN
      LET l_cod_cep = vdpm7_clientes_get_cod_cep()
      LET l_cod_cep = l_cod_cep[1,5]

      WHENEVER ERROR CONTINUE
      SELECT 0
        FROM agencias_bancarias
       WHERE cod_portador = m_portador
         AND cod_cep      = l_cod_cep
      WHENEVER ERROR STOP

      IF sqlca.sqlcode = 0 THEN
         RETURN TRUE, TRUE
      END IF

      WHENEVER ERROR CONTINUE
      DECLARE cq_vdp_sequencia CURSOR FOR
      SELECT portador,
             seq_prioridade
        FROM vdp_port_sequencia
       ORDER BY seq_prioridade
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('SELEÇÃO','VDP_PORT_SEQUENCIA')
         RETURN FALSE, FALSE
      END IF

      WHENEVER ERROR CONTINUE
      FOREACH cq_vdp_sequencia INTO l_portador
      WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('SELEÇÃO','VDP_PORT_SEQUENCIA')
            RETURN FALSE, FALSE
         END IF

         WHENEVER ERROR CONTINUE
         SELECT 0
           FROM agencias_bancarias
          WHERE cod_portador = l_portador
            AND cod_cep      = l_cod_cep
         WHENEVER ERROR STOP

         IF sqlca.sqlcode = 0 THEN
            IF NOT geo1015_consiste_portador(l_portador) THEN
               RETURN FALSE, FALSE
            END IF

            RETURN TRUE, TRUE
         END IF

         WHENEVER ERROR CONTINUE

      END FOREACH

      LET l_msg = 'O boleto não será emitido por falta de portador com o cep igual ao do cliente : ' CLIPPED, ' ' , l_cod_cep
      CALL log0030_mensagem(l_msg, 'exclamation')

      RETURN TRUE, FALSE
   ELSE
      RETURN TRUE, TRUE
   END IF

END FUNCTION


#------------------------------------------------------#
 FUNCTION geo1015_consiste_val_limite_diario_boletos()
#------------------------------------------------------#

   DEFINE l_val_acumulado_dia     DECIMAL(17,2),
          l_limite                DECIMAL(17,6),
          l_msg                   CHAR(300)

   WHENEVER ERROR CONTINUE
   SELECT val_lim_dia
     INTO l_limite
     FROM vdp_lim_bloqueto
    WHERE empresa      = mr_docum.cod_empresa
      AND portador     = m_portador
      AND dat_inicial  <= TODAY
      AND dat_final    >= TODAY
   WHENEVER ERROR STOP

   IF sqlca.sqlcode < 0 THEN
      CALL log003_err_sql('SELEÇÃO','VDP_LIM_BLOQUETO')
      RETURN FALSE
   END IF

   IF sqlca.sqlcode = 100 THEN
      RETURN TRUE
   END IF

   IF m_val_boleto > l_limite THEN
      LET l_msg = 'Valor do documento para o portador ', m_portador,' \n',
                  'ultrapassou o limite informado que é \n',
                  'de: ', l_limite USING '###,###,###,##&.&&','. \n',
                  'Verificar cadastro de Valor Limite por Portador, \n',
                  'no VDP1477. '

      CALL log0030_mensagem(l_msg,'exclamation')
      RETURN FALSE
   END IF

   IF vdpm325_fat_ctr_val_diario_leitura(mr_docum.cod_empresa,m_portador,TODAY,FALSE,TRUE) THEN

      LET l_val_acumulado_dia = vdpm325_fat_ctr_val_diario_get_val_acumulado_dia() + m_val_boleto

      IF l_val_acumulado_dia > l_limite THEN
         LET l_msg = 'Valor Limite Diário para emissão de boletos \n',
                     'por portador, ',m_portador,' ultrapassou o limite \n',
                     'informado que é de: ', l_limite,'. \n',
                     'Verificar cadastro de Valor Limite por Portador, \n',
                     'no VDP1477. '

         CALL log0030_mensagem(l_msg,'exclamation')

         RETURN FALSE
      END IF

   END IF

   RETURN TRUE

 END FUNCTION

#--------------------------------------------#
 FUNCTION geo1015_efetua_amarracao_com_cre()
#--------------------------------------------#

   DEFINE l_pct_juro_mora_cli     LIKE juro_mora.pct_juro_mora

   #Verifica se o sistema trabalha com notas de crédito vinculadas
   IF UPSHIFT(crem7_par_cre_txt_get_posicao_parametro(309,309)) <> 'S' THEN
      RETURN TRUE
   END IF

   LET m_pct_juro_mora_nc = 0

   IF crem8_clientes_cre_txt_leitura(mr_docum.cod_cliente,FALSE,TRUE) THEN
      LET m_pct_juro_mora_nc = crem8_clientes_cre_txt_get_posicao_parametros(103,104)
   END IF

   IF m_pct_juro_mora_nc IS NULL THEN
      LET m_pct_juro_mora_nc = 0
   END IF

   IF m_pct_juro_mora_nc = 0 THEN

      IF m_origem_duplicata = 'DC' THEN

         WHENEVER ERROR CONTINUE
           SELECT pct_juro_mora
             INTO m_pct_juro_mora
             FROM docum
            WHERE cod_empresa = mr_docum.cod_empresa
              AND num_docum = mr_docum.num_docum
              AND ies_tip_docum = mr_docum.ies_tip_docum
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
            IF sqlca.sqlcode <> 100 THEN
               CALL log003_err_sql('SELECT','DOCUM')
            ELSE
               LET m_pct_juro_mora = 0
            END IF
         END IF

      ELSE {m_origem_duplicata = 'NF'}

         CALL geo1015_busca_clientes_cre_txt()

         IF m_par_clientes_cre_txt[11,11] = "N" THEN
            LET m_pct_juro_mora = 0
         ELSE
            IF m_par_clientes_cre_txt[05,10] > 0 THEN
               LET m_pct_juro_mora = m_par_clientes_cre_txt[05,10]
            ELSE
               WHENEVER ERROR CONTINUE
               SELECT pct_juro_mora
                 INTO m_pct_juro_mora_nc
                 FROM juro_mora
                WHERE cod_empresa = mr_docum.cod_empresa
                  AND ies_cotacao = 'CR$'
                  AND dat_ini     = (SELECT MAX(dat_ini)
                                       FROM juro_mora
                                      WHERE cod_empresa = mr_docum.cod_empresa
                                        AND ies_cotacao = 'CR$'
                                        AND dat_ini    <= mr_docum.dat_emis)
               WHENEVER ERROR STOP
               IF sqlca.sqlcode < 0 THEN
                  CALL log003_err_sql('SELEÇÃO','JURO_MORA')
                  RETURN FALSE
               END IF

               IF m_pct_juro_mora_nc IS NULL THEN
                  LET m_pct_juro_mora_nc = 0
               END IF
            END IF
         END IF
      END IF
   END IF

   IF NOT g_reimpressao THEN
      IF NOT geo1015_vincular_nota() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT geo1015_busca_saldo_documento() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION


#---------------------------------#
 FUNCTION geo1015_vincular_nota()
#---------------------------------#

   DEFINE lr_docum_posterior              RECORD LIKE docum_posterior.*,
          lr_docum                        RECORD LIKE docum.*

   DEFINE l_empresa_cre                   LIKE empresa_cre.cod_empresa

   DEFINE l_valor                         DECIMAL(17,2),
          l_valor_par                     DECIMAL(17,2),
          l_vinculada                     CHAR(01),
          l_nota_ja_vinculad              SMALLINT,
          l_vinculou                      SMALLINT

   DEFINE l_cli_tem_encargos_vincular_nc  CHAR(01)

   DEFINE l_msg    CHAR(200)
   DEFINE l_erro   SMALLINT

   CALL log2250_busca_parametro(p_cod_empresa,'cli_tem_encargos_vincular_nc')
        RETURNING l_cli_tem_encargos_vincular_nc, m_status

   #Verifica se o cliente está parametrizado para fazer vinculação (CRE6960)
   IF UPSHIFT(crem8_clientes_cre_txt_get_posicao_parametros(096,096)) = 'N' THEN
      RETURN TRUE
   END IF

   LET l_empresa_cre = m_empresa_ctrl_cre

   INITIALIZE lr_docum              TO NULL
   INITIALIZE m_val_outras_deducoes TO NULL
   INITIALIZE m_num_docum_origem    TO NULL

   LET l_vinculou = FALSE

   WHENEVER ERROR CONTINUE
   DECLARE cq_notas_credito CURSOR FOR
    SELECT cod_empresa              , num_docum                ,
           ies_tip_docum            , dat_emis                 ,
           dat_vencto_c_desc        , pct_desc                 ,
           dat_vencto_s_desc        , dat_prorrogada           ,
           ies_cobr_juros           , cod_cliente              ,
           cod_repres_1             , cod_repres_2             ,
           cod_repres_3             , val_liquido              ,
           val_bruto                , val_saldo                ,
           val_fat                  , val_desc_dia             ,
           val_desp_financ          , ies_tip_cobr             ,
           pct_juro_mora            , cod_portador             ,
           ies_tip_portador         , ies_cnd_bordero          ,
           ies_situa_docum          , dat_alter_situa          ,
           ies_pgto_docum           , ies_pendencia            ,
           ies_bloq_justific        , num_pedido               ,
           num_docum_origem         , ies_tip_docum_orig       ,
           ies_serie_fat            , cod_local_fat            ,
           cod_tip_comis            , pct_comis_1              ,
           pct_comis_2              , pct_comis_3              ,
           val_desc_comis           , dat_competencia          ,
           ies_tip_emis_docum       , dat_emis_docum           ,
           num_lote_remessa         , dat_gravacao             ,
           cod_cnd_pgto             , cod_deb_cred_cl          ,
           ies_docum_suspenso       , ies_tip_port_defin       ,
           ies_ctr_endosso          , cod_mercado              ,
           num_lote_lanc_cont       , dat_atualiz
      FROM docum
     WHERE cod_empresa     =  l_empresa_cre
       AND cod_cliente     =  mr_docum.cod_cliente
       AND ies_tip_docum   =  'NC'
       AND ies_situa_docum <> 'C'
       AND ies_pgto_docum  =  'A'
   WHENEVER ERROR STOP

   IF sqlca.sqlcode < 0 THEN
      CALL log003_err_sql('SELEÇÃO','DOCUM')
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   FOREACH cq_notas_credito INTO lr_docum.*
   WHENEVER ERROR STOP

      IF sqlca.sqlcode < 0 THEN
         CALL log003_err_sql('SELEÇÃO','DOCUM')
         RETURN FALSE
      END IF

      LET l_nota_ja_vinculad = FALSE

      WHENEVER ERROR CONTINUE
      SELECT 0
        FROM docum_posterior
       WHERE cod_empresa   = lr_docum.cod_empresa
         AND num_docum     = lr_docum.num_docum
         AND ies_tip_docum = lr_docum.ies_tip_docum
      WHENEVER ERROR STOP

      IF sqlca.sqlcode = 0
      OR sqlca.sqlcode = -284 THEN
         LET l_nota_ja_vinculad = TRUE
      ELSE
         IF sqlca.sqlcode < 0 THEN
            CALL log003_err_sql('SELEÇÃO','DOCUM_POSTERIOR')
            RETURN FALSE
         END IF
      END IF

      IF l_nota_ja_vinculad THEN
#         LET l_msg = 'Cliente com todas NC''s já vinculadas'
#         IF NOT geo1015_atualiza_cre_doc_nvinculado(lr_docum.cod_empresa,
#                                                     lr_docum.num_docum,
#                                                     lr_docum.ies_tip_docum,
#                                                     l_msg,
#                                                     TODAY,
#                                                     lr_docum.cod_cliente) THEN
#            RETURN FALSE
#         END IF

         CONTINUE FOREACH
      END IF

      WHENEVER ERROR CONTINUE
      SELECT parametro[197]
        INTO l_vinculada
        FROM docum_txt
       WHERE cod_empresa   = lr_docum.cod_empresa
         AND num_docum     = lr_docum.num_docum
         AND ies_tip_docum = lr_docum.ies_tip_docum
      WHENEVER ERROR STOP

      IF sqlca.sqlcode = 0 THEN
         IF l_vinculada IS NOT NULL AND l_vinculada <> 'S' THEN
            LET l_msg = 'Cliente com NC''s parametrizadas para não vinculação'

            IF NOT geo1015_atualiza_cre_doc_nvinculado(lr_docum.cod_empresa,
                                                        lr_docum.num_docum,
                                                        lr_docum.ies_tip_docum,
                                                        l_msg,
                                                        TODAY,
                                                        lr_docum.cod_cliente) THEN
               RETURN FALSE
            END IF

            CONTINUE FOREACH
         END IF
      END IF

      #MARCOS - DUVIDA??
      WHENEVER ERROR CONTINUE
      SELECT 0
        FROM par_sup_pad
       WHERE cod_empresa   = lr_docum.cod_empresa
         AND cod_parametro = 'cod_abat_cre'
         AND par_num       = lr_docum.cod_deb_cred_cl
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         EXIT FOREACH
      END IF

      IF lr_docum.val_saldo > m_val_boleto THEN
         LET l_msg = 'Valor saldo da NC é maior que o valor da duplicata a ser vinculada'

         IF NOT geo1015_atualiza_cre_doc_nvinculado(lr_docum.cod_empresa,
                                                     lr_docum.num_docum,
                                                     lr_docum.ies_tip_docum,
                                                     l_msg,
                                                     TODAY,
                                                     lr_docum.cod_cliente) THEN
            RETURN FALSE
         END IF

         CONTINUE FOREACH
      END IF

      LET l_valor = m_val_boleto - lr_docum.val_saldo

      #Valor mínimo para cobrança de uma duplicata que sera utilizado para
      #comparar a diferença entre o valor do boleto e o valor da Nota de Crédito
      LET l_valor_par = crem7_par_cre_txt_get_posicao_parametro(310,324)

      IF l_valor_par IS NULL THEN
         LET l_valor_par = 0
      END IF

      LET l_valor_par = l_valor_par / 100   ### 2 decimais

      IF l_valor < l_valor_par THEN
         LET l_msg = 'Valor restante, entre o valor da NC e o valor da DP, é menor que o parâmetro[310,324] do CRE6710'

         IF NOT geo1015_atualiza_cre_doc_nvinculado(lr_docum.cod_empresa,
                                                     lr_docum.num_docum,
                                                     lr_docum.ies_tip_docum,
                                                     l_msg,
                                                     TODAY,
                                                     lr_docum.cod_cliente) THEN
            RETURN FALSE
         END IF

         CONTINUE FOREACH
      END IF

      IF l_cli_tem_encargos_vincular_nc = 'S' THEN
         WHENEVER ERROR CONTINUE
         SELECT 0
           FROM docum
          WHERE cod_empresa     = lr_docum.cod_empresa
            AND cod_cliente     = lr_docum.cod_cliente
            AND ies_tip_docum   IN ('NS','ND')
            AND ies_situa_docum <> 'C'
            AND ies_pgto_docum   = 'A'
         WHENEVER ERROR STOP
         IF sqlca.sqlcode = 0 OR sqlca.sqlcode = -284 THEN
             LET l_msg = 'Cliente possui encargos financeiros em aberto'       # <- Não alterar esta linha
             IF NOT geo1015_atualiza_cre_doc_nvinculado(lr_docum.cod_empresa, #    A alteração desta linha irá impactar
                                                         lr_docum.num_docum,   #    no programa cre0149
                                                         lr_docum.ies_tip_docum,
                                                         l_msg,
                                                         TODAY,
                                                         lr_docum.cod_cliente) THEN
                RETURN FALSE
             END IF

            CONTINUE FOREACH
         END IF
      END IF

      IF lr_docum.pct_juro_mora IS NOT NULL AND
         m_pct_juro_mora_nc = 0 THEN
         LET m_pct_juro_mora_nc = lr_docum.pct_juro_mora
      END IF

      INITIALIZE lr_docum_posterior.* TO NULL

      LET lr_docum_posterior.cod_empresa        = lr_docum.cod_empresa
      LET lr_docum_posterior.num_docum          = lr_docum.num_docum
      LET lr_docum_posterior.ies_tip_docum      = lr_docum.ies_tip_docum

      WHENEVER ERROR CONTINUE
      SELECT MAX(num_seq_docum)
        INTO lr_docum_posterior.num_seq_docum
        FROM docum_posterior
       WHERE cod_empresa      = lr_docum_posterior.cod_empresa
         AND num_docum        = lr_docum_posterior.num_docum
         AND ies_tip_docum    = lr_docum_posterior.ies_tip_docum
         AND num_seq_docum    = lr_docum_posterior.num_seq_docum
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0
      OR lr_docum_posterior.num_seq_docum IS NULL THEN
         LET lr_docum_posterior.num_seq_docum   = 0
      END IF

      LET lr_docum_posterior.num_seq_docum      = lr_docum_posterior.num_seq_docum + 1

      LET lr_docum_posterior.num_docum_post     = mr_docum.num_docum
      LET lr_docum_posterior.ies_tip_docum_post = mr_docum.ies_tip_docum

      CALL crem63_docum_posterior_set_cod_empresa(lr_docum.cod_empresa)
      CALL crem63_docum_posterior_set_num_docum(lr_docum.num_docum)
      CALL crem63_docum_posterior_set_ies_tip_docum(lr_docum.ies_tip_docum)
      CALL crem63_docum_posterior_set_num_seq_docum(lr_docum_posterior.num_seq_docum)
      CALL crem63_docum_posterior_set_num_docum_post(mr_docum.num_docum)
      CALL crem63_docum_posterior_set_ies_tip_docum_post(mr_docum.ies_tip_docum)

      IF NOT cret63_docum_posterior_inclui(TRUE,FALSE) THEN
         RETURN FALSE
      END IF

      LET l_vinculou            = TRUE
      LET m_val_outras_deducoes = lr_docum.val_saldo
      LET m_num_docum_origem    = lr_docum.num_docum_origem

      EXIT FOREACH  ### deve vincular um documento por nota/boleto

   END FOREACH

   WHENEVER ERROR CONTINUE
   FREE cq_notas_credito
   WHENEVER ERROR STOP

   IF NOT l_vinculou THEN
      INITIALIZE m_val_outras_deducoes TO NULL
      INITIALIZE m_num_docum_origem    TO NULL
   END IF

   RETURN TRUE

END FUNCTION


#-----------------------------------------------------------------------------------------------------------#
 FUNCTION geo1015_atualiza_cre_doc_nvinculado(l_empresa,l_num_docum,l_ies_tip_docum,l_msg,l_data,l_cliente)
#-----------------------------------------------------------------------------------------------------------#

   DEFINE l_empresa             LIKE docum.cod_empresa,
          l_num_docum           LIKE docum.num_docum,
          l_ies_tip_docum       LIKE docum.ies_tip_docum,
          l_msg                 CHAR(200),
          l_data                DATE,
          l_cliente             LIKE docum.cod_cliente

   IF crem176_cre_doc_nvinculado_leitura(l_empresa,l_num_docum,l_ies_tip_docum,FALSE,TRUE) THEN
      IF NOT cret176_cre_doc_nvinculado_exclui(l_empresa,l_num_docum,l_ies_tip_docum,TRUE,FALSE,FALSE) THEN
         RETURN FALSE
      END IF
   END IF

   CALL crem176_cre_doc_nvinculado_set_empresa(l_empresa)
   CALL crem176_cre_doc_nvinculado_set_docum(l_num_docum)
   CALL crem176_cre_doc_nvinculado_set_tip_docum(l_ies_tip_docum)
   CALL crem176_cre_doc_nvinculado_set_motivo_nvinculado(l_msg)
   CALL crem176_cre_doc_nvinculado_set_dat_processamento(l_data)
   CALL crem176_cre_doc_nvinculado_set_cliente(l_cliente)

   IF NOT cret176_cre_doc_nvinculado_inclui(TRUE,FALSE) THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------------#
 FUNCTION geo1015_busca_saldo_documento()
#-----------------------------------------#

   DEFINE l_docum_val_saldo         LIKE docum.val_saldo,
          l_docum_num_docum_origem  LIKE docum.num_docum_origem

   DEFINE l_empresa_cre             LIKE empresa_cre.cod_empresa,
          l_num_docum               LIKE  docum_posterior.num_docum

   INITIALIZE m_val_outras_deducoes TO NULL
   INITIALIZE m_num_docum_origem    TO NULL

   LET l_empresa_cre = m_empresa_ctrl_cre

   WHENEVER ERROR CONTINUE
   DECLARE cq_saldo_documento CURSOR FOR
    SELECT num_docum
      FROM docum_posterior
     WHERE cod_empresa        = l_empresa_cre
       AND ies_tip_docum      = 'NC'
       AND num_seq_docum      = 1
       AND num_docum_post     = mr_docum.num_docum
       AND ies_tip_docum_post = mr_docum.ies_tip_docum
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('SELEÇÃO','DOCUM_POSTERIOR')
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   FOREACH cq_saldo_documento INTO l_num_docum
   WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('SELEÇÃO','DOCUM_POSTERIOR')
         RETURN FALSE
      END IF

      WHENEVER ERROR CONTINUE
      SELECT val_saldo,
             num_docum_origem
        INTO l_docum_val_saldo,
             l_docum_num_docum_origem
        FROM docum
       WHERE cod_empresa     =  l_empresa_cre
         AND num_docum       =  l_num_docum
         AND ies_tip_docum   =  'NC'
         AND cod_cliente     =  mr_docum.cod_cliente
         AND ies_situa_docum <> 'C'
         AND ies_pgto_docum  =  'A'
      WHENEVER ERROR STOP

      IF sqlca.sqlcode < 0 THEN
         CALL log003_err_sql('SELEÇÃO','DOCUM')
         RETURN FALSE
      END IF

      WHENEVER ERROR CONTINUE

      IF sqlca.sqlcode = 100 THEN
         CONTINUE FOREACH
      END IF

      LET m_val_outras_deducoes = l_docum_val_saldo
      LET m_num_docum_origem    = l_docum_num_docum_origem

   END FOREACH

   WHENEVER ERROR CONTINUE
   FREE cq_saldo_documento
   WHENEVER ERROR STOP

   RETURN TRUE

END FUNCTION


#-------------------------------------#
 FUNCTION geo1015_monta_arquivo_txt()
#-------------------------------------#
   DEFINE l_emp_consol            LIKE docum.cod_empresa #725648

   DEFINE lr_fiscal_hist          RECORD LIKE fiscal_hist.*

   DEFINE l_portador              LIKE portador.cod_portador,
          l_num_titulo_completo   LIKE docum_banco.num_titulo_banco

   DEFINE l_titulo_banco          DECIMAL(17,0),
          l_titulo_banco_char     LIKE docum_banco.num_titulo_banco

   DEFINE l_instrucao_abatimento  SMALLINT

   DEFINE l_abatimento            DECIMAL(16,2)

   DEFINE l_pct_cofins            DECIMAL(5,2),
          l_pct_pis               DECIMAL(5,2),
          l_pct_csll              DECIMAL(5,2),
          l_pct_ret               DECIMAL(5,2),
          l_val_base              DECIMAL(17,2),
          l_pct_irrf              DECIMAL(5,2),
          l_cod_hist_fiscal       DECIMAL(12,2)

   DEFINE l_tem_fiscal            CHAR(01),
          l_motivo_retencao       CHAR(01),
          l_cod_portador          CHAR(04),
          l_instrucoes1           CHAR(74),
          l_instrucoes2           CHAR(74),
          lr_cre_tit_cob_esp_banco_ant RECORD LIKE cre_tit_cob_esp.*

   DEFINE lr_instr_vendor RECORD
            qtd_dias_1            SMALLINT,
            pct_taxa_efetiva_1    LIKE cre_tit_cob_esp.pct_taxa_efetiva,
            base_1                DECIMAL (24,11),
            expoente_1            DECIMAL (24,11),
            exponencial_1         DECIMAL (24,11),
            val_parcela_cliente_1 LIKE cre_tit_cob_esp.val_parcela_cliente,
            qtd_dias_2            SMALLINT,
            pct_taxa_efetiva_2    LIKE cre_tit_cob_esp.pct_taxa_efetiva,
            base_2                DECIMAL (24,11),
            expoente_2            DECIMAL (24,11),
            exponencial_2         DECIMAL (24,11),
            val_abatimento        LIKE docum_pgto.val_pago
          END RECORD

   {Os 537265 Ivanele}
   DEFINE l_indice                CHAR(01),
          l_base                  CHAR(06),
          l_seq                   CHAR(02),
          l_dig                   CHAR(01),
          l_portfolio             CHAR(03)
   {Fim 537265 Ivanele}

   DEFINE l_port_compl            LIKE docum.cod_portador
   DEFINE l_observacao CHAR(400)

   DEFINE l_qtd_dias_protesto     CHAR(02)

   DEFINE l_instrucao_especifica  CHAR(400)

   INITIALIZE gr_relat            TO NULL
   INITIALIZE gr_nf_bloqueto       TO NULL

   INITIALIZE l_pct_csll          TO NULL
   INITIALIZE l_pct_pis           TO NULL
   INITIALIZE l_pct_cofins        TO NULL
   INITIALIZE l_val_base          TO NULL
   INITIALIZE l_pct_ret           TO NULL
   INITIALIZE l_pct_irrf          TO NULL
   INITIALIZE l_cod_hist_fiscal   TO NULL
   INITIALIZE l_tem_fiscal        TO NULL
   INITIALIZE l_motivo_retencao   TO NULL

   LET l_instrucao_abatimento = FALSE

   LET gr_relat.cod_cliente          = mr_docum.cod_cliente
   LET gr_relat.nom_banco            = crem15_portador_get_nom_portador()

   LET gr_relat.cod_banco            = m_portador_char[2,4], '-', gr_par_bloq_laser.dig_portador

   LET gr_relat.den_empresa          = logm2_empresa_get_den_empresa()

   LET gr_relat.cod_agencia          = gr_par_bloq_laser.num_agencia USING '&&&&',
                                       gr_par_bloq_laser.dig_agencia USING '&'

   LET gr_relat.cod_cedente          = gr_par_bloq_laser.cod_cedente CLIPPED

   IF mr_docum.dat_prorrogada IS NOT NULL THEN
      LET gr_relat.dat_vencto        = mr_docum.dat_prorrogada
   ELSE
      LET gr_relat.dat_vencto        = mr_docum.dat_vencto_s_desc
   END IF

   LET gr_relat.cod_carteira         = gr_par_bloq_laser.par_bloq_txt[20,25]
   LET gr_relat.dat_emissao          = mr_docum.dat_emis
   LET gr_relat.dat_proces           = mr_docum.dat_emis

   #IF Find4GLFunction("crey68_imprimir_documento_origem_da_docum") THEN
   #   IF crey68_imprimir_documento_origem_da_docum() AND mr_docum.num_docum_origem IS NOT NULL THEN
   #      LET gr_relat.num_docum = mr_docum.num_docum_origem
   #   ELSE
   #      LET gr_relat.num_docum = mr_docum.num_docum
   #   END IF
   #ELSE
   #   LET gr_relat.num_docum = mr_docum.num_docum
   #END IF

   LET gr_relat.num_docum = mr_docum.num_docum

   IF Find4GLFunction("crey68_busca_dados_sip") THEN
      CALL crey68_busca_dados_sip( mr_docum.cod_empresa   ,
                                   mr_docum.num_docum     ,
                                   mr_docum.ies_tip_docum )
      RETURNING l_observacao


      IF l_observacao IS NOT NULL AND l_observacao <> " " THEN

         IF l_observacao[001,065] IS NOT NULL AND l_observacao[001,065] <> " " THEN
            LET gr_relat.instrucoes6 = l_observacao[001,065]
         END IF

         IF l_observacao[066,131] IS NOT NULL AND l_observacao[066,131] <> " " THEN
            LET gr_relat.instrucoes5 = gr_relat.instrucoes6
            LET gr_relat.instrucoes6 = l_observacao[066,131]
         END IF

         IF l_observacao[132,197] IS NOT NULL AND l_observacao[132,197] <> " " THEN
            LET gr_relat.instrucoes4 = gr_relat.instrucoes5
            LET gr_relat.instrucoes5 = gr_relat.instrucoes6
            LET gr_relat.instrucoes6 = l_observacao[132,197]
         END IF

         IF l_observacao[198,263] IS NOT NULL AND l_observacao[198,263] <> " " THEN
            LET gr_relat.instrucoes3 = gr_relat.instrucoes4
            LET gr_relat.instrucoes4 = gr_relat.instrucoes5
            LET gr_relat.instrucoes5 = gr_relat.instrucoes6
            LET gr_relat.instrucoes6 = l_observacao[198,263]
         END IF

         IF l_observacao[264,329] IS NOT NULL AND l_observacao[264,329] <> " " THEN
            LET gr_relat.instrucoes2 = gr_relat.instrucoes3
            LET gr_relat.instrucoes3 = gr_relat.instrucoes4
            LET gr_relat.instrucoes4 = gr_relat.instrucoes5
            LET gr_relat.instrucoes5 = gr_relat.instrucoes6
            LET gr_relat.instrucoes6 = l_observacao[264,329]
         END IF

         IF l_observacao[330,400] IS NOT NULL AND l_observacao[330,400] <> " " THEN
            LET gr_relat.instrucoes1 = gr_relat.instrucoes2
            LET gr_relat.instrucoes2 = gr_relat.instrucoes3
            LET gr_relat.instrucoes3 = gr_relat.instrucoes4
            LET gr_relat.instrucoes4 = gr_relat.instrucoes5
            LET gr_relat.instrucoes5 = gr_relat.instrucoes6
            LET gr_relat.instrucoes6 = l_observacao[330,400]
         END IF

      END IF
   END IF

   #::: FUNÇÃO UTILIZADA PELO CLIENTE: 5002 - DOHLER
   IF LOG_existe_epl("geo1015y_busca_instrucao_especifica") THEN
      CALL LOG_setVar( "PRG_cod_empresa"    , mr_docum.cod_empresa      )
      CALL LOG_setVar( "PRG_num_docum"      , mr_docum.num_docum        )
      CALL LOG_setVar( "PRG_tip_docum"      , mr_docum.ies_tip_docum    )
      CALL LOG_setVar( "PRG_cod_cliente"    , mr_docum.cod_cliente      )
      CALL LOG_setVar( "PRG_num_docum_orig" , mr_docum.num_docum_origem )
      CALL LOG_setVar( "PRG_dat_emis"       , mr_docum.dat_emis         )
      CALL LOG_setVar( "PRG_reimpressao"    , g_reimpressao             )
      CALL LOG_setVar( "PRG_data_proces"    , m_dat_proces_doc          )

      CALL geo1015y_busca_instrucao_especifica()

      LET l_instrucao_especifica = LOG_getVar( "EPL_instrucao" )

      IF l_instrucao_especifica IS NOT NULL AND l_instrucao_especifica <> " " THEN
         IF l_instrucao_especifica[001,065] IS NOT NULL AND l_instrucao_especifica[001,065] <> " " THEN
            LET gr_relat.instrucoes6 = l_instrucao_especifica[001,065]
         END IF

         IF l_instrucao_especifica[066,131] IS NOT NULL AND l_instrucao_especifica[066,131] <> " " THEN
            LET gr_relat.instrucoes5 = gr_relat.instrucoes6
            LET gr_relat.instrucoes6 = l_instrucao_especifica[066,131]
         END IF

         IF l_instrucao_especifica[132,197] IS NOT NULL AND l_instrucao_especifica[132,197] <> " " THEN
            LET gr_relat.instrucoes4 = gr_relat.instrucoes5
            LET gr_relat.instrucoes5 = gr_relat.instrucoes6
            LET gr_relat.instrucoes6 = l_instrucao_especifica[132,197]
         END IF

         IF l_instrucao_especifica[198,263] IS NOT NULL AND l_instrucao_especifica[198,263] <> " " THEN
            LET gr_relat.instrucoes3 = gr_relat.instrucoes4
            LET gr_relat.instrucoes4 = gr_relat.instrucoes5
            LET gr_relat.instrucoes5 = gr_relat.instrucoes6
            LET gr_relat.instrucoes6 = l_instrucao_especifica[198,263]
         END IF

         IF l_instrucao_especifica[264,329] IS NOT NULL AND l_instrucao_especifica[264,329] <> " " THEN
            LET gr_relat.instrucoes2 = gr_relat.instrucoes3
            LET gr_relat.instrucoes3 = gr_relat.instrucoes4
            LET gr_relat.instrucoes4 = gr_relat.instrucoes5
            LET gr_relat.instrucoes5 = gr_relat.instrucoes6
            LET gr_relat.instrucoes6 = l_instrucao_especifica[264,329]
         END IF

         IF l_instrucao_especifica[330,400] IS NOT NULL AND l_instrucao_especifica[330,400] <> " " THEN
            LET gr_relat.instrucoes1 = gr_relat.instrucoes2
            LET gr_relat.instrucoes2 = gr_relat.instrucoes3
            LET gr_relat.instrucoes3 = gr_relat.instrucoes4
            LET gr_relat.instrucoes4 = gr_relat.instrucoes5
            LET gr_relat.instrucoes5 = gr_relat.instrucoes6
            LET gr_relat.instrucoes6 = l_instrucao_especifica[330,400]
         END IF
      END IF
   END IF

   LET gr_relat.esp_docum            = gr_par_bloq_laser.par_bloq_txt[26,31]

   IF gr_par_bloq_laser.par_bloq_txt[32,32] = 'S' THEN
      LET gr_relat.cod_aceite        = 'SIM'
   ELSE
      LET gr_relat.cod_aceite        = 'NAO'
   END IF

   LET gr_relat.val_docum            = m_val_boleto
   LET gr_relat.esp_moeda            = 'R$'
   LET gr_relat.nom_cliente          = vdpm7_clientes_get_nom_cliente()
   LET gr_relat.end_cliente          = mr_dados_cliente.end_cliente
   LET gr_relat.den_bairro           = mr_dados_cliente.den_bairro
   LET gr_relat.cod_cep              = mr_dados_cliente.cod_cep
   LET gr_relat.den_cidade           = vdpm1_cidades_get_den_cidade()
   LET gr_relat.cod_uni_feder        = vdpm1_cidades_get_cod_uni_feder()
   LET gr_relat.num_cgc_cpf          = vdpm7_clientes_get_num_cgc_cpf()
   LET gr_relat.loc_pgto_1           = gr_par_bloq_laser.par_bloq_txt[34,83]
   LET gr_relat.loc_pgto_2           = gr_par_bloq_laser.par_bloq_txt[84,133]
   ### LET gr_relat.instrucoes4          = gr_par_bloq_laser.instrucoes_1
   LET gr_relat.out_deducoes         = m_val_outras_deducoes

   #TFADU2#
   IF LOG_existe_epl("geo1015y_informar_dados_cliente") THEN

      CALL LOG_setVar("cod_cliente",mr_docum.cod_cliente)
      CALL LOG_setVar("nom_cliente",gr_relat.nom_cliente)
      CALL LOG_setVar("end_cliente",gr_relat.end_cliente)

      CALL geo1015y_informar_dados_cliente()

   END IF

   IF gr_relat.out_deducoes IS NULL THEN
      LET gr_relat.out_deducoes = 0
   END IF

   #Verifica parâmetro que indica se deverá ser utilizado o valor saldo ou bruto do documento
   IF UPSHIFT(mr_empresa_cre_txt.parametros[350,350]) = 'S' THEN
      LET l_instrucao_abatimento = FALSE
   ELSE
      #572487 Se for vendor, lê os valores da cre_tit_cob_esp. Senão, lê da docum.
      IF m_origem_duplicata = 'DC' AND mr_docum.ies_tip_cobr = 'V' THEN {DOCUM}
         LET l_abatimento = mr_cre_tit_cob_esp.val_parcela_cliente - mr_cre_tit_cob_esp.val_saldo_cliente
      ELSE
         LET l_abatimento = mr_docum.val_bruto - mr_docum.val_saldo
      END IF

      IF l_abatimento > 0 THEN
         LET l_instrucao_abatimento  = TRUE
      END IF
   END IF

   #572487
   IF m_origem_duplicata = 'DC' AND mr_docum.ies_tip_cobr = 'V' THEN

      INITIALIZE l_instrucoes1, l_instrucoes2, lr_instr_vendor.* TO NULL

      IF NOT mr_cre_tit_cob_esp.dat_repactuacao IS NULL THEN
         LET lr_instr_vendor.qtd_dias_2 = mr_cre_tit_cob_esp.dat_repactuacao - mr_docum.dat_emis
      ELSE
         LET lr_instr_vendor.qtd_dias_2 = mr_cre_tit_cob_esp.dat_vencimento - mr_docum.dat_emis
      END IF

      LET lr_instr_vendor.pct_taxa_efetiva_2 = mr_cre_tit_cob_esp.pct_taxa_efetiva

      #Verifica se houve alteração de valor do saldo do documento.
      #Para isso, seleciona o registro atual e o último registro do tipo banco
      IF g_reimpressao THEN
         CALL geo1015_get_cre_tit_cob_esp_banco_ant(mr_docum.cod_empresa,
                                                     mr_docum.num_docum,
                                                     mr_docum.ies_tip_docum,
                                                     mr_docum.ies_tip_cobr,
                                                     mr_cre_tit_cob_esp.contrato_cobranca,
                                                     mr_cre_tit_cob_esp.versao)
           RETURNING m_status, lr_cre_tit_cob_esp_banco_ant.*

         IF NOT m_status THEN
            RETURN FALSE
         END IF

         #Se for null, é porque não há registro anterior do tipo banco. Houve apenas reimpressão de documento sem motivo
         IF NOT lr_cre_tit_cob_esp_banco_ant.val_parcela_cliente IS NULL THEN
            IF lr_cre_tit_cob_esp_banco_ant.val_parcela_cliente <> mr_cre_tit_cob_esp.val_parcela_cliente OR
               lr_cre_tit_cob_esp_banco_ant.val_saldo_cliente <> mr_cre_tit_cob_esp.val_saldo_cliente THEN
               INITIALIZE l_instrucoes1, l_instrucoes2 TO NULL
               LET l_instrucoes1 = 'TÍTULO RENEGOCIADO'

               LET lr_instr_vendor.val_parcela_cliente_1 = lr_cre_tit_cob_esp_banco_ant.val_parcela_cliente

               IF (lr_cre_tit_cob_esp_banco_ant.pct_taxa_efetiva <> mr_cre_tit_cob_esp.pct_taxa_efetiva) OR
                  (lr_cre_tit_cob_esp_banco_ant.dat_repactuacao <> mr_cre_tit_cob_esp.dat_repactuacao) OR
                  (lr_cre_tit_cob_esp_banco_ant.dat_repactuacao IS NULL AND
                   NOT mr_cre_tit_cob_esp.dat_repactuacao IS NULL) THEN

                  IF NOT mr_cre_tit_cob_esp.dat_repactuacao IS NULL THEN
                     LET lr_instr_vendor.qtd_dias_1 = mr_cre_tit_cob_esp.dat_repactuacao - mr_cre_tit_cob_esp.dat_vencimento
                  ELSE
                     LET lr_instr_vendor.qtd_dias_1 = 0
                  END IF

                  LET lr_instr_vendor.pct_taxa_efetiva_1 = mr_cre_tit_cob_esp.pct_taxa_efetiva
                  LET lr_instr_vendor.base_1 = (1 + (lr_instr_vendor.pct_taxa_efetiva_1 / 100))
                  LET lr_instr_vendor.expoente_1 = (lr_instr_vendor.qtd_dias_1 / 30)
                  LET lr_instr_vendor.exponencial_1 = log039_expo_sp(lr_instr_vendor.base_1, lr_instr_vendor.expoente_1)

                  LET l_instrucoes1 = l_instrucoes1 CLIPPED, ' - Nova taxa: ',
                                      lr_instr_vendor.pct_taxa_efetiva_1 USING '#&.&&&&&&',
                                      '  Dias: ', lr_instr_vendor.qtd_dias_1

                  IF NOT lr_cre_tit_cob_esp_banco_ant.dat_repactuacao IS NULL THEN
                     LET lr_instr_vendor.qtd_dias_2 = lr_cre_tit_cob_esp_banco_ant.dat_repactuacao - mr_docum.dat_emis
                  ELSE
                     LET lr_instr_vendor.qtd_dias_2 = lr_cre_tit_cob_esp_banco_ant.dat_vencimento - mr_docum.dat_emis
                  END IF

                  LET lr_instr_vendor.pct_taxa_efetiva_2 = lr_cre_tit_cob_esp_banco_ant.pct_taxa_efetiva

                  CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)
               END IF
            END IF
         END IF
      END IF

      INITIALIZE l_instrucoes1, l_instrucoes2 TO NULL

      LET lr_instr_vendor.base_2 = (1 + (lr_instr_vendor.pct_taxa_efetiva_2 / 100))
      LET lr_instr_vendor.expoente_2 = (lr_instr_vendor.qtd_dias_2 / 30)
      LET lr_instr_vendor.exponencial_2 = log039_expo_sp(lr_instr_vendor.base_2, lr_instr_vendor.expoente_2)

      LET lr_instr_vendor.val_abatimento = geo1015_get_val_abatimento_vendor(mr_docum.cod_empresa, mr_docum.num_docum, mr_docum.ies_tip_docum)

      LET l_instrucoes1 = 'Original: ', mr_cre_tit_cob_esp.val_original USING '<<<,<<<,<<&.&&',
                          '  IOF: ', mr_cre_tit_cob_esp.pct_iof USING '#&.&&&&',
                          '  Taxa: ', lr_instr_vendor.pct_taxa_efetiva_2 USING '<&.&&&&',
                          '  Dias: ', lr_instr_vendor.qtd_dias_2
      LET l_instrucoes2 = 'VENDOR - (', mr_cre_tit_cob_esp.val_original USING '<<<<<<<<&.&&',
                          ' * ', lr_instr_vendor.exponencial_2 USING '<&.&&&&&&&', ')'

      IF NOT lr_instr_vendor.exponencial_1 IS NULL THEN
         LET l_instrucoes2 = l_instrucoes2 CLIPPED,
                             ' + (', lr_instr_vendor.val_parcela_cliente_1 USING '<<<,<<<,<<&.&&',
                             ' * ', lr_instr_vendor.exponencial_2 USING '<&.&&&&&&&',
                             ')'
      END IF

      LET l_instrucoes2 = l_instrucoes2 CLIPPED, ' - ', lr_instr_vendor.val_abatimento USING '<<<,<<<,<<&.&&'

      CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)
   END IF

   IF m_origem_duplicata = 'NF' OR m_origem_duplicata = 'AN' THEN
      IF mr_param.instrucoes_2 IS NOT NULL AND
         mr_param.instrucoes_2 <> ' ' THEN
         CALL geo1015_preenche_instrucoes(mr_param.instrucoes_2,
                                           mr_param.instrucoes_3)
      END IF

      IF mr_param.instrucoes_4 IS NOT NULL AND
         mr_param.instrucoes_4 <> ' ' THEN
         CALL geo1015_preenche_instrucoes(mr_param.instrucoes_4,
                                           mr_param.instrucoes_5)
      END IF

      IF mr_param.instrucoes_6 IS NOT NULL AND
         mr_param.instrucoes_6 <> ' ' THEN
         CALL geo1015_preenche_instrucoes(mr_param.instrucoes_6,'')
      END IF
   END IF
   IF m_pct_juro_mora > 0 THEN
      INITIALIZE l_instrucoes2 TO NULL
      IF m_especifico = TRUE THEN
         CASE m_cod_cliente
            WHEN '1131'
               CALL crey52_monta_percentual_juro_mora(m_pct_juro_mora, gr_relat.val_docum)
                  RETURNING m_val_juro_mora
         END CASE
      ELSE
         LET m_pct_juro_mora_aux = m_pct_juro_mora / 30
         LET m_val_juro_mora     = (gr_relat.val_docum * m_pct_juro_mora_aux) /100
      END IF
      LET l_instrucoes1       = 'COBRAR COMISSAO PERMANENCIA DE R$ ',m_val_juro_mora USING "<<<<<<<<<<<&.&&",' POR DIA DE ATRASO'
      CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)
   END IF

   IF m_pct_desc_financ > 0 THEN

      LET l_instrucoes1 = NULL
      LET l_instrucoes2 = NULL

      IF (m_origem_duplicata = 'NF' OR m_origem_duplicata = 'AN') THEN
         CALL vdp0856_mensagem_instrucoes_bloqueto('2',
                                                   mr_docum.dat_vencto_c_desc,
                                                   mr_docum.dat_vencto_s_desc,
                                                   m_pct_desc_financ)
            RETURNING l_instrucoes1
      END IF

      IF l_instrucoes1 IS NULL OR l_instrucoes1 = ' ' THEN
         IF m_imprime_desp_fin = "P" THEN
            LET l_instrucoes1 =
               "PAGTO ATE ", mr_docum.dat_vencto_c_desc     USING "DD/MM/YYYY",
               " DESCONTAR ", m_pct_desc_financ  USING "#&.&&",
               "% NO VALOR DO TITULO."

         ELSE
            LET m_val_desc    = (gr_relat.val_docum * m_pct_desc_financ) /100

            LET l_instrucoes1 =
               "PAGTO ATE ", mr_docum.dat_vencto_c_desc USING "DD/MM/YYYY",
               " CONCEDER UM DESCONTO DE R$", m_val_desc  USING "<<<<<<<<<<<<<&.&&"

            LET l_instrucoes2 = "NO VALOR DO TITULO."

         END IF
      END IF

      CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)

   END IF

   #Indica se será impresso informações de protesto ou NC vinculada do CRE
   IF gr_par_bloq_laser.par_bloq_txt[140,140] = 'S' AND
      m_ies_protesto = 'S' THEN
      IF m_qtd_dias_protesto IS NULL OR m_qtd_dias_protesto <= 0 THEN
         LET l_instrucoes1 = 'SUJEITO A PROTESTO'
      ELSE
         LET l_instrucoes1 = 'SUJEITO A PROTESTO / ',m_qtd_dias_protesto USING '&&',' DIAS DE ATRASO NAO RECEBER'
      END IF
      LET l_instrucoes2 = NULL

      CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)
   END IF

   #---------OS 300469 - M.P.135------------------# Inicio
   LET l_tem_fiscal = FALSE

   IF m_origem_duplicata = 'DC' THEN
      CALL geo1015_busca_retencoes_docum()
         RETURNING l_pct_cofins,
                   l_pct_pis,
                   l_pct_csll,
                   l_val_base,
                   l_pct_irrf,
                   l_cod_hist_fiscal,
                   l_motivo_retencao
   ELSE
      CALL geo1015_busca_retencoes_nota_fiscal()
         RETURNING l_pct_cofins,
                   l_pct_pis,
                   l_pct_csll,
                   l_val_base,
                   l_pct_irrf,
                   l_cod_hist_fiscal,
                   l_motivo_retencao
   END IF

   IF l_cod_hist_fiscal IS NULL THEN
      LET l_cod_hist_fiscal = 0
   ELSE
      LET l_tem_fiscal = TRUE
   END IF

   IF l_pct_csll   = 0 AND
      l_pct_pis    = 0 AND
      l_pct_cofins = 0 AND
      l_pct_irrf   = 0 AND
      l_val_base   = 0 THEN


      # Alterado para imprimir as instruções gravadas pelo vdp, sempre que tiver espaço Chamado: SDHEXX

      ### LET l_instrucoes1 = gr_par_bloq_laser.instrucoes_1
      ### LET l_instrucoes2 = gr_par_bloq_laser.instrucoes_2
      ###
      ### IF l_instrucoes1 IS NULL THEN
      ###    LET l_instrucoes1 = ' '
      ### END IF
      ###
      ### IF l_instrucoes2 IS NULL THEN
      ###    LET l_instrucoes2 = ' '
      ### END IF
      ###
      ###
      ###
      ### CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)
      ###
      ###
      ### LET l_instrucoes1 = gr_par_bloq_laser.instrucoes_3
      ### LET l_instrucoes2 = gr_par_bloq_laser.instrucoes_4
      ###
      ### IF l_instrucoes1 IS NULL THEN
      ###    LET l_instrucoes1 = ' '
      ### END IF
      ###
      ### IF l_instrucoes2 IS NULL THEN
      ###    LET l_instrucoes2 = ' '
      ### END IF
      ###
      ### CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)



   ELSE

      LET l_pct_ret = l_pct_csll + l_pct_pis + l_pct_cofins

      IF l_tem_fiscal THEN
         IF vdpm162_fiscal_hist_leitura(l_cod_hist_fiscal,FALSE,TRUE) THEN
            LET lr_fiscal_hist.tex_hist_1 = vdpm162_fiscal_hist_get_tex_hist_1()
            LET lr_fiscal_hist.tex_hist_1 = vdpm162_fiscal_hist_get_tex_hist_2()
         END IF

         LET l_instrucoes1 = 'VALOR SUJEITO A RETENCAO ', lr_fiscal_hist.tex_hist_1[1,47]
         LET l_instrucoes2 = lr_fiscal_hist.tex_hist_1[51,75], lr_fiscal_hist.tex_hist_2[1,47]

         CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)
      ELSE
         IF l_motivo_retencao MATCHES '[SO]' THEN
            LET l_instrucoes1 = 'VALOR SUJEITO A RETENCAO DE ACORDO COM ART. 5 DA LEI 10.925/2004'
            LET l_instrucoes2 = NULL

            IF l_pct_irrf THEN
               LET l_instrucoes1 = l_instrucoes1 CLIPPED,
                                   ' E'
               LET l_instrucoes2 = ' COM ART. 64 DA LEI 9430/96'
            END IF

            CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)

         ELSE
            LET l_instrucoes1 = 'VALOR SUJEITO A RETENCAO DE ACORDO COM ART. 30 DA LEI 10.833/03 E'
            LET l_instrucoes2 = 'COM ART. 64 DA LEI 9430/96'

            CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)
         END IF
      END IF

   END IF

   ### Chamado: SDHEXX -----#

    LET l_instrucoes1 = gr_par_bloq_laser.instrucoes_1
    LET l_instrucoes2 = gr_par_bloq_laser.instrucoes_2

    IF l_instrucoes1 IS NULL THEN
       LET l_instrucoes1 = ' '
    END IF

    IF l_instrucoes2 IS NULL THEN
       LET l_instrucoes2 = ' '
    END IF

    CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)

    LET l_instrucoes1 = gr_par_bloq_laser.instrucoes_3
    LET l_instrucoes2 = gr_par_bloq_laser.instrucoes_4

    IF l_instrucoes1 IS NULL THEN
       LET l_instrucoes1 = ' '
    END IF

    IF l_instrucoes2 IS NULL THEN
       LET l_instrucoes2 = ' '
    END IF

    CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)
    ### Fim chamado: SDHEXX -----#

   #----------------------------------------------# Fim

   #Emite instrução de abatimento - Inicio
   IF l_instrucao_abatimento THEN
      LET l_instrucao_abatimento = FALSE

      LET l_instrucoes1 = 'CONCEDER DESCONTO DE: ', l_abatimento USING "<<<<<<<<<<<<<&.&&"
      LET l_instrucoes2 = NULL

      CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)

   END IF
   #Emite instrução de abatimento - Fim

   #Indica se será impresso informações de protesto ou NC vinculada do CRE
   IF gr_par_bloq_laser.par_bloq_txt[140,140] = 'S' THEN

      #Emite instrução de desconto de nota de crédito atrelada à NF de devolução - Início
      IF gr_relat.out_deducoes > 0 THEN

         LET l_instrucoes1 = 'DESCONTO DE ', gr_relat.out_deducoes USING '######&.&&',
                             ', REFERENTE A LIQUIDACAO DE SUA NF DE'
         LET l_instrucoes2 = 'DEVOLUCAO NR. ', mr_docum.num_docum_origem

         CALL geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)

      END IF
      #Emite instrução de desconto de nota de crédito atrelada à NF de devolução - Fim

   END IF

   {Emite instruções informadas na geração de bloqueto para Nota Fiscal ou antecipação de pedido}

   #Quando utilizado o EPL crey72 todas as mensagens de instrução no Boleto serão específicas
   IF Find4glFunction("crey72_consulta_instrucao_emissao_boleto") THEN

      CALL geo1015_busca_parametro_escrit_compl(mr_docum.cod_empresa,'Dias para protestar')
         RETURNING m_status, l_qtd_dias_protesto
      IF NOT m_status THEN
         RETURN FALSE
      END IF

      CALL crey72_set_cod_cliente(mr_docum.cod_cliente)
      CALL crey72_set_num_docum_origem(m_num_docum_origem)
      CALL crey72_set_outras_deducoes(m_val_outras_deducoes)
      CALL crey72_set_dias_protesto(l_qtd_dias_protesto)
      CALL crey72_set_pct_juro_mora(m_pct_juro_mora)
      CALL crey72_set_val_docum(gr_relat.val_docum)
      CALL crey72_set_data_vencto_com_desconto(mr_docum.dat_vencto_c_desc)
      CALL crey72_set_pct_desconto(m_pct_desc_financ)
      CALL crey72_set_pct_csll(l_pct_csll)
      CALL crey72_set_pct_pis(l_pct_pis)
      CALL crey72_set_pct_cofins(l_pct_cofins)
      CALL crey72_set_valor_base(l_val_base)
      CALL crey72_set_param_vdp_instrucao2(mr_param.instrucoes_2)
      CALL crey72_set_param_vdp_instrucao3(mr_param.instrucoes_3)
      CALL crey72_set_param_vdp_instrucao4(mr_param.instrucoes_4)
      CALL crey72_set_param_vdp_instrucao5(mr_param.instrucoes_5)
      CALL crey72_set_param_vdp_instrucao6(mr_param.instrucoes_6)

      CALL crey72_consulta_instrucao_emissao_boleto(gr_par_bloq_laser.cod_empresa,gr_par_bloq_laser.cod_portador)
         RETURNING gr_relat.instrucoes1,
                   gr_relat.instrucoes2,
                   gr_relat.instrucoes3,
                   gr_relat.instrucoes4,
                   gr_relat.instrucoes5,
                   gr_relat.instrucoes6
   END IF

   LET l_titulo_banco      = NULL
   LET l_titulo_banco_char = NULL

   IF g_reimpressao THEN

      CASE m_portador_char[2,4]
         WHEN '001' # BRASIL
              LET l_titulo_banco_char = mr_docum_banco.num_titulo_banco

         WHEN '341' # ITAU
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,8]

         WHEN '409' # UNIBANCO
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,10]

         WHEN '074' # J.SAFRA
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[3,11]

         WHEN '394' # BMC
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[3,11]

         WHEN '027' # BESC
              #Verifica tipo de cobrança
              IF gr_par_bloq_laser.par_bloq_txt[139,139] = '1' THEN
                 LET l_titulo_banco = mr_docum_banco.num_titulo_banco[2,7]  # CRE10606 - Cobranca Registrada ( Escritural )
              ELSE
                 LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,13] # CRE10607 - Cobranca (Direta)
              END IF

         WHEN '033' # BANESPA
              CASE m_layout_santander
                 WHEN "1" #Antigo Banespa
                    LET l_titulo_banco = mr_docum_banco.num_titulo_banco[04,10] USING "&&&&&&&"  # CRE10608

                 WHEN "2" #Santander 8 posições
                    LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,7] USING '&&&&&&&' # CRE10638

                 WHEN "3" #Santander 13 posições
                    LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,12] USING '&&&&&&&&&&&&' # CRE10628
              END CASE

         WHEN '353' # SANTANDER
              #Mesmo sendo Santander, se estiver com a remessa do 33, deverá usar o boleto com o layout do 33 Santander/Banespa.
              CALL geo1015_verifica_portador_complementar() RETURNING l_port_compl

              IF l_port_compl = '033' THEN
                 CASE m_layout_santander
                    WHEN "1" #Antigo Banespa
                       LET l_titulo_banco = mr_docum_banco.num_titulo_banco[04,10] USING "&&&&&&&"  # CRE10608

                    WHEN "2" #Santander 8 posições
                       LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,7] USING '&&&&&&&' # CRE10638

                    WHEN "3" #Santander 13 posições
                       LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,12] USING '&&&&&&&&&&&&' # CRE10628
                 END CASE
              ELSE
                 LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,12] USING "&&&&&&&&&&&&" # CRE10618
              END IF

         WHEN '038' # BANESTADO
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,9] USING "&&&&&&&&&" # CRE10609

         WHEN '041' # BANRISUL
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,8] # CRE10613

         WHEN '104' # C.E.F.
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[2,10] # CRE10614

         WHEN '231' # BOA VISTA
              LET l_titulo_banco        = mr_docum_banco.num_titulo_banco[7,11] # CRE10615
              LET l_num_titulo_completo = mr_docum_banco.num_titulo_banco[1,11]

         WHEN '291' # BCN
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,7] # CRE10616

         WHEN '347' # SUDAMERIS
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,9] # CRE10617

         WHEN '389' # MERCANTIL DO BRASIL
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,10] USING "&&&&&&&&&&" # CRE10619

         WHEN '392' # MERCANTIL DE SAO PAULO - FINASA
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,10] USING "&&&&&&&&&&" # CRE10621

         WHEN '453' # BANCO RURAL S.A.
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,7] # CRE10622

         WHEN '479' # BOSTON
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,8] USING "&&&&&&&&" # CRE10623

         WHEN '004' # BANCO DO NORDESTE
              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,7] USING "&&&&&&&" # CRE10625

         WHEN '399' # HSBC/BAMERINDUS
              #Verifica tipo de cobrança
              IF gr_par_bloq_laser.par_bloq_txt[139,139] = '2' THEN
                 LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,16]   # Cobrança Não Registrada
              ELSE
                 LET l_titulo_banco = mr_docum_banco.num_titulo_banco         # Cobrança Registrada
              END IF

         WHEN '275'  # REAL
            LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,7] USING '&&&&&&&'

         WHEN '356'  # REAL
            LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,7] USING '&&&&&&&'

         {Os 537265 Ivanele}
         WHEN '745'
            LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,11] USING "&&&&&&&&&&&"
         {Fim 537265 Ivanele}
         OTHERWISE

              LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,11]       # ALPHA

      END CASE

   END IF

   CASE m_portador_char[2,4]

     WHEN '001'  # BANCO DO BRASIL

         CALL geo1015_busca_parametro_escrit_compl(mr_docum.cod_empresa,'Numero contrato')
            RETURNING m_status, g_numero_convenio
         IF NOT m_status THEN
            RETURN FALSE
         END IF

         IF g_numero_convenio IS NULL OR g_numero_convenio = ' ' THEN #725648
            LET l_emp_consol = crem2_par_cre_get_cod_emp_consol()
            CALL geo1015_busca_parametro_escrit_compl(l_emp_consol,'Numero contrato')
               RETURNING m_status, g_numero_convenio
            IF NOT m_status THEN
               RETURN FALSE
            END IF
         END IF

         IF g_numero_convenio IS NULL OR g_numero_convenio = ' ' THEN
            CALL log0030_mensagem('Parâmetro "número do contrato" não cadastrado para o banco do Brasil (001). ','exclamation')
            RETURN FALSE
         END IF

         CALL cre10601_calcula_barras(l_titulo_banco_char)

     WHEN '237'  # BRADESCO
          CALL cre1060_calcula_barras(l_titulo_banco)

     WHEN '275'  # REAL
          CALL cre10580_calcula_barras(l_titulo_banco)

     WHEN '341'  # ITAU
          CALL cre10602_calcula_barras(l_titulo_banco)

     WHEN '356'  # REAL
          CALL cre10580_calcula_barras(l_titulo_banco)

     WHEN '399'  # HSBC
          #Verifica tipo de cobrança
          IF gr_par_bloq_laser.par_bloq_txt[139,139] = '2' THEN # Cobrança Não Registrada
             LET p_relat.*                      = gr_relat.*
             LET gr_par_bloqueto.*               = gr_par_bloq_laser.*
             LET gr_nf_bloqueto.num_titulo_banco = l_titulo_banco

             CALL vdp4569_calcula_cod_barras()

             LET gr_relat.nosso_numero          = p_relat.nosso_numero
             LET gr_relat.cod_barras            = p_relat.cod_barras
             LET gr_relat.cod_cedente           = p_relat.cod_cedente
             LET gr_relat.txt_barras            = p_relat.txt_barras
             LET g_novo_numero                  = p_relat.nosso_numero USING '&&&&&&&&&&&&&&&&'
          ELSE
             CALL cre10570_calcula_barras(l_titulo_banco)
          END IF

     WHEN '409'  # UNIBANCO
          #Verifica tipo de cobrança
          IF gr_par_bloq_laser.par_bloq_txt[139,139] = '2' THEN
             CALL cre10603_calcula_barras(l_titulo_banco, FALSE) # Cobrança Não Registrada
          ELSE
             CALL cre10603_calcula_barras(l_titulo_banco, TRUE)  # Cobrança Registrada
          END IF

     WHEN '422'  # SAFRA
          CALL cre1059_calcula_barras(l_titulo_banco)

     WHEN '074'  # J.SAFRA

          CALL geo1015_busca_parametro_escrit_compl(mr_docum.cod_empresa,'Identificacao header')
             RETURNING m_status, g_cod_cliente_j_safra
          IF NOT m_status THEN
             RETURN FALSE
          END IF

          CALL cre10604_calcula_barras(l_titulo_banco)

     WHEN '394'  # BMC
          CALL cre10605_calcula_barras(l_titulo_banco)

     WHEN '027'  # BESC
          #Verifica tipo de cobrança
          IF gr_par_bloq_laser.par_bloq_txt[139,139] = '1' THEN
             CALL cre10606_calcula_cod_barras(l_titulo_banco) # Cobrança Registrada
          ELSE
             CALL cre10607_calcula_cod_barras(l_titulo_banco)
          END IF

     WHEN '033'  # BANESPA
          CASE m_layout_santander
             WHEN "1" #Antigo Banespa
                CALL cre10608_calcula_cod_barras(l_titulo_banco)

             WHEN "2" #Santander 8 posições
                CALL cre10638_set_parametros(g_reimpressao,mr_docum_banco.num_titulo_banco)
                CALL cre10638_calcula_cod_barras(l_titulo_banco)

             WHEN "3" #Santander 13 posições
                CALL cre10628_set_parametros(g_reimpressao,mr_docum_banco.num_titulo_banco)
                CALL cre10628_calcula_cod_barras(l_titulo_banco) #717511
          END CASE

     WHEN '353'  # SANTANDER
          #Mesmo sendo Santander, se estiver com a remessa do 33, deverá usar o boleto com o layout do 33 Santander/Banespa.
          CALL geo1015_verifica_portador_complementar() RETURNING l_port_compl

          IF l_port_compl = '033' THEN

             CASE m_layout_santander
                WHEN "1" #Antigo Banespa
                   CALL cre10608_calcula_cod_barras(l_titulo_banco)


                WHEN "2" #Santander 8 posições
                   CALL cre10638_set_parametros(g_reimpressao,mr_docum_banco.num_titulo_banco)
                   CALL cre10638_calcula_cod_barras(l_titulo_banco)

                WHEN "3" #Santander 13 posições
                   CALL cre10628_set_parametros(g_reimpressao,mr_docum_banco.num_titulo_banco)
                   CALL cre10628_calcula_cod_barras(l_titulo_banco) #717511

             END CASE
          ELSE
             CALL cre10618_calcula_cod_barras(l_titulo_banco)
          END IF

     WHEN '038'  # BANESTADO
          CALL cre10609_calcula_cod_barras(l_titulo_banco)

     WHEN '041'  # BANRISUL
          CALL cre10613_calcula_cod_barras(l_titulo_banco)

     WHEN '104'  # C.E.F
          CALL cre10614_calcula_cod_barras(l_titulo_banco)

     WHEN '231'  # BOA VISTA
          CALL cre10615_calcula_cod_barras(l_titulo_banco,l_num_titulo_completo)

     WHEN '291'  # BCN
          CALL cre10616_calcula_cod_barras(l_titulo_banco)

     WHEN '347'  # SUDAMERIS
          CALL cre10617_calcula_cod_barras(l_titulo_banco)

     WHEN '389' # MERCANTIL DO BRASIL
          CALL cre10619_calcula_cod_barras(l_titulo_banco)

     WHEN '392'  # MERCANTIL DE SAO PAULO - FINASA
          CALL cre10621_calcula_cod_barras(l_titulo_banco)

     WHEN '453'  # RURAL
          CALL cre10622_calcula_cod_barras(l_titulo_banco)

     WHEN '479'  # BOSTON
          CALL cre10623_calcula_cod_barras(l_titulo_banco)

     WHEN '025'  # ALPHA
          CALL cre10624_calcula_cod_barras(l_titulo_banco)

     WHEN '004'  # BANCO DO NORDESTE
          CALL cre10625_calcula_cod_barras(l_titulo_banco)

     WHEN '044'  # BVA
          CALL cre0228_calcula_barras(l_titulo_banco)

     WHEN '745'  # CITY BANK                                  {OS 537265 Ivanele}

          CALL geo1015_consulta_cosmos()
          RETURNING l_indice, l_base, l_seq, l_dig,l_portfolio

          CALL cre10691_calcula_barras("geo1015",
                                       l_titulo_banco,
                                       l_indice,
                                       l_base,
                                       l_seq,
                                       l_dig,
                                       l_portfolio)

     OTHERWISE
          CALL log0030_mensagem('Banco sem função para cálculo do código de barras.','info')

   END CASE


   RETURN TRUE

END FUNCTION

{Os 537265 Ivanele}
#----------------------------------#
FUNCTION geo1015_consulta_cosmos()
#----------------------------------#
  DEFINE l_parametro_texto LIKE vdp_par_blqt_compl.parametro_texto,
         l_indice          CHAR(01),
         l_base            CHAR(06),
         l_seq             CHAR(02),
         l_dig             CHAR(01),
         l_portfolio       CHAR(03)

  WHENEVER ERROR CONTINUE
  SELECT parametro_texto[1,1],
         parametro_texto[2,7],
         parametro_texto[8,9],
         parametro_texto[10,10]
    INTO l_indice,
         l_base,
         l_seq,
         l_dig
    FROM vdp_par_blqt_compl
   WHERE empresa  = mr_docum.cod_empresa
     AND portador = m_portador
     AND campo    = 'conta_cosmos'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     INITIALIZE l_indice,
               l_base,
               l_seq,
               l_dig TO NULL
  END IF

  WHENEVER ERROR CONTINUE
  SELECT parametro_texto
    INTO l_parametro_texto
    FROM vdp_par_blqt_compl
   WHERE empresa  = mr_docum.cod_empresa
     AND portador = m_portador
     AND campo    = 'portfolio'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     LET l_portfolio = l_parametro_texto
  END IF

  RETURN l_indice, l_base, l_seq, l_dig,l_portfolio

END FUNCTION
{Fim 537265 Ivanele}

#------------------------------------------------------------------#
 FUNCTION geo1015_preenche_instrucoes(l_instrucoes1,l_instrucoes2)
#------------------------------------------------------------------#

   DEFINE l_instrucoes1           CHAR(74),
          l_instrucoes2           CHAR(74)

   IF l_instrucoes1 IS NULL THEN
   #OR l_instrucoes1 = ' ' THEN
      LET l_instrucoes1 = l_instrucoes2
      LET l_instrucoes2 = NULL
   END IF

   #IF l_instrucoes2 = ' ' THEN
   #   LET l_instrucoes2 = NULL
   #END IF

   IF l_instrucoes2 IS NULL THEN

      CASE
         WHEN gr_relat.instrucoes1 IS NULL OR gr_relat.instrucoes1 = ' '
              LET gr_relat.instrucoes1 = l_instrucoes1
              EXIT CASE
         WHEN gr_relat.instrucoes2 IS NULL OR gr_relat.instrucoes2 = ' '
              LET gr_relat.instrucoes2 = l_instrucoes1
              EXIT CASE
         WHEN gr_relat.instrucoes3 IS NULL OR gr_relat.instrucoes3 = ' '
              LET gr_relat.instrucoes3 = l_instrucoes1
              EXIT CASE
         WHEN gr_relat.instrucoes4 IS NULL OR gr_relat.instrucoes4 = ' '
              LET gr_relat.instrucoes4 = l_instrucoes1
              EXIT CASE
         WHEN gr_relat.instrucoes5 IS NULL OR gr_relat.instrucoes5 = ' '
              LET gr_relat.instrucoes5 = l_instrucoes1
              EXIT CASE
         WHEN gr_relat.instrucoes6 IS NULL OR gr_relat.instrucoes6 = ' '
              LET gr_relat.instrucoes6 = l_instrucoes1
              EXIT CASE
         OTHERWISE
      END CASE

   ELSE

      CASE
         WHEN (gr_relat.instrucoes1 IS NULL OR gr_relat.instrucoes1 = ' ') AND
              (gr_relat.instrucoes2 IS NULL OR gr_relat.instrucoes2 = ' ')
              LET gr_relat.instrucoes1 = l_instrucoes1
              LET gr_relat.instrucoes2 = l_instrucoes2
              EXIT CASE
         WHEN (gr_relat.instrucoes2 IS NULL OR gr_relat.instrucoes2 = ' ') AND
              (gr_relat.instrucoes3 IS NULL OR gr_relat.instrucoes3 = ' ')
              LET gr_relat.instrucoes2 = l_instrucoes1
              LET gr_relat.instrucoes3 = l_instrucoes2
              EXIT CASE
         WHEN (gr_relat.instrucoes3 IS NULL OR gr_relat.instrucoes3 = ' ') AND
              (gr_relat.instrucoes4 IS NULL OR gr_relat.instrucoes4 = ' ')
              LET gr_relat.instrucoes3 = l_instrucoes1
              LET gr_relat.instrucoes4 = l_instrucoes2
              EXIT CASE
         WHEN (gr_relat.instrucoes4 IS NULL OR gr_relat.instrucoes4 = ' ') AND
              (gr_relat.instrucoes5 IS NULL OR gr_relat.instrucoes5 = ' ')
              LET gr_relat.instrucoes4 = l_instrucoes1
              LET gr_relat.instrucoes5 = l_instrucoes2
              EXIT CASE
         WHEN (gr_relat.instrucoes5 IS NULL OR gr_relat.instrucoes5 = ' ') AND
              (gr_relat.instrucoes6 IS NULL OR gr_relat.instrucoes6 = ' ')
              LET gr_relat.instrucoes5 = l_instrucoes1
              LET gr_relat.instrucoes6 = l_instrucoes2
              EXIT CASE
         OTHERWISE

      END CASE

   END IF

 END FUNCTION

#-----------------------------------------#
 FUNCTION geo1015_busca_retencoes_docum()
#-----------------------------------------#
   DEFINE l_pct_cofins            DECIMAL(5,2),
          l_pct_pis               DECIMAL(5,2),
          l_pct_csll              DECIMAL(5,2),
          l_val_base              DECIMAL(17,2),
          l_pct_irrf              DECIMAL(5,2),
          l_cod_hist_fiscal       DECIMAL(12,2)

   DEFINE l_motivo_retencao       CHAR(01)

   INITIALIZE l_pct_cofins        TO NULL
   INITIALIZE l_pct_pis           TO NULL
   INITIALIZE l_pct_csll          TO NULL
   INITIALIZE l_val_base          TO NULL
   INITIALIZE l_pct_irrf          TO NULL
   INITIALIZE l_cod_hist_fiscal   TO NULL
   INITIALIZE l_motivo_retencao   TO NULL

   IF crem48_cre_docum_compl_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,'pct_csll',FALSE,TRUE) THEN
      LET l_pct_csll = crem48_cre_docum_compl_get_parametro_val()
   END IF

   IF l_pct_csll IS NULL THEN
      LET l_pct_csll = 0
   END IF

   IF crem48_cre_docum_compl_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,'pct_pis',FALSE,TRUE) THEN
      LET l_pct_pis = crem48_cre_docum_compl_get_parametro_val()
   END IF

   IF l_pct_pis IS NULL THEN
      LET l_pct_pis = 0
   END IF

   IF crem48_cre_docum_compl_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,'pct_cofins',FALSE,TRUE) THEN
      LET l_pct_cofins = crem48_cre_docum_compl_get_parametro_val()
   END IF

   IF l_pct_cofins IS NULL THEN
      LET l_pct_cofins = 0
   END IF

   IF crem48_cre_docum_compl_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,'val_base',FALSE,TRUE) THEN
      LET l_val_base = crem48_cre_docum_compl_get_parametro_val()
   END IF

   IF l_val_base IS NULL THEN
      LET l_val_base = 0
   END IF

   IF crem48_cre_docum_compl_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,'pct_irrf',FALSE,TRUE) THEN
      LET l_pct_irrf = crem48_cre_docum_compl_get_parametro_val()
   END IF

   IF l_pct_irrf IS NULL THEN
      LET l_pct_irrf = 0
   END IF

   IF crem48_cre_docum_compl_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,'cod_hist_fiscal',FALSE,TRUE) THEN
      LET l_cod_hist_fiscal = crem48_cre_docum_compl_get_parametro_val()
   END IF

   IF crem48_cre_docum_compl_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,'motivo_retencao',FALSE,TRUE) THEN
      LET l_motivo_retencao = crem48_cre_docum_compl_get_par_existencia()
   END IF

   IF l_motivo_retencao IS NULL THEN
      LET l_motivo_retencao = 'A'
   END IF

   RETURN l_pct_cofins,
          l_pct_pis,
          l_pct_csll,
          l_val_base,
          l_pct_irrf,
          l_cod_hist_fiscal,
          l_motivo_retencao

 END FUNCTION

#-----------------------------------------------#
 FUNCTION geo1015_busca_retencoes_nota_fiscal()
#-----------------------------------------------#
   DEFINE l_status                SMALLINT,
          l_retencao_cre_vdp      CHAR(03)

   DEFINE l_pct_cofins            DECIMAL(5,2),
          l_pct_pis               DECIMAL(5,2),
          l_pct_csll              DECIMAL(5,2),
          l_val_base              DECIMAL(17,2),
          l_pct_irrf              DECIMAL(5,2),
          l_cod_hist_fiscal       DECIMAL(12,2)

   DEFINE l_motivo_retencao       CHAR(01)

   INITIALIZE l_pct_cofins        TO NULL
   INITIALIZE l_pct_pis           TO NULL
   INITIALIZE l_pct_csll          TO NULL
   INITIALIZE l_val_base          TO NULL
   INITIALIZE l_pct_irrf          TO NULL
   INITIALIZE l_cod_hist_fiscal   TO NULL
   INITIALIZE l_motivo_retencao   TO NULL

   CALL vdpt214_fat_nf_item_fisc_retorna_max_retencao_cre_vdp(mr_docum.cod_empresa,
                                                              mr_nota.trans_nota_fiscal,
                                                              'PIS_RET',0)
      RETURNING l_status, l_retencao_cre_vdp

   {Não faz retenção no CRE}
   IF l_retencao_cre_vdp <> 'CRE' THEN
      RETURN 0, 0, 0, 0, 0, '', ''
   END IF

   CALL vdpt214_fat_nf_item_fisc_retorna_max_motivo_retencao(mr_docum.cod_empresa,
                                                             mr_nota.trans_nota_fiscal,
                                                             'PIS_RET',0)
      RETURNING l_status, l_retencao_cre_vdp

   IF l_motivo_retencao IS NULL THEN
      LET l_motivo_retencao = 'A'
   END IF

   CALL vdpt214_fat_nf_item_fisc_retorna_max_hist_fiscal(mr_docum.cod_empresa,
                                                         mr_nota.trans_nota_fiscal,
                                                         'PIS_RET',0)
      RETURNING l_status, l_cod_hist_fiscal

   CALL vdpt214_fat_nf_item_fisc_retorna_max_aliquota(mr_docum.cod_empresa,
                                                      mr_nota.trans_nota_fiscal,
                                                      'PIS_RET',0)
      RETURNING l_status, l_pct_pis

   CALL vdpt214_fat_nf_item_fisc_retorna_max_aliquota(mr_docum.cod_empresa,
                                                      mr_nota.trans_nota_fiscal,
                                                      'COFINS_RET',0)
      RETURNING l_status, l_pct_cofins

   CALL vdpt214_fat_nf_item_fisc_retorna_max_aliquota(mr_docum.cod_empresa,
                                                      mr_nota.trans_nota_fiscal,
                                                      'CSLL_RET',0)
      RETURNING l_status, l_pct_csll

   CALL vdpt214_fat_nf_item_fisc_retorna_max_aliquota(mr_docum.cod_empresa,
                                                      mr_nota.trans_nota_fiscal,
                                                      'IRRF_RET',0)
      RETURNING l_status, l_pct_irrf

   IF vdpm215_fat_mestre_fiscal_leitura(mr_docum.cod_empresa,
                                        mr_nota.trans_nota_fiscal,
                                        'PIS_RET',0,1) THEN
      LET l_val_base = vdpm215_fat_mestre_fiscal_get_bc_tributo_tot()
   ELSE
      IF vdpm215_fat_mestre_fiscal_leitura(mr_docum.cod_empresa,
                                           mr_nota.trans_nota_fiscal,
                                           'COFINS_RET',0,1) THEN
         LET l_val_base = vdpm215_fat_mestre_fiscal_get_bc_tributo_tot()
      ELSE
         IF vdpm215_fat_mestre_fiscal_leitura(mr_docum.cod_empresa,
                                              mr_nota.trans_nota_fiscal,
                                              'CSLL_RET',0,1) THEN
            LET l_val_base = vdpm215_fat_mestre_fiscal_get_bc_tributo_tot()
         ELSE
            IF vdpm215_fat_mestre_fiscal_leitura(mr_docum.cod_empresa,
                                                 mr_nota.trans_nota_fiscal,
                                                 'IRRF_RET',0,1) THEN
               LET l_val_base = vdpm215_fat_mestre_fiscal_get_bc_tributo_tot()
            END IF
         END IF
      END IF
   END IF

   IF l_val_base IS NULL OR l_val_base = ' ' THEN
      LET l_val_base = 0
   END IF

   RETURN l_pct_cofins,
          l_pct_pis,
          l_pct_csll,
          l_val_base,
          l_pct_irrf,
          l_cod_hist_fiscal,
          l_motivo_retencao

 END FUNCTION

#------------------------------------------------------#
 FUNCTION geo1015_consiste_controle_numeracao_boleto()
#------------------------------------------------------#
   DEFINE l_num_bloqueto_ini        LIKE vdp_ctr_num_blqt.num_bloqueto_ini,
          l_num_bloqueto_fim        LIKE vdp_ctr_num_blqt.num_bloqueto_fim
   DEFINE l_num_titulo_banco        DECIMAL(20,0)
   DEFINE l_tamanho                 SMALLINT
   DEFINE l_msg                     CHAR(300)

   IF vdpm326_vdp_ctr_num_blqt_leitura(mr_docum.cod_empresa,m_portador,FALSE,TRUE) THEN
      LET l_num_bloqueto_ini = vdpm326_vdp_ctr_num_blqt_get_num_bloqueto_ini()
      LET l_num_bloqueto_fim = vdpm326_vdp_ctr_num_blqt_get_num_bloqueto_fim()

      LET l_tamanho = LENGTH(g_novo_numero)

      IF g_novo_numero[l_tamanho] MATCHES '[0123456789]' THEN
         LET l_num_titulo_banco = g_novo_numero
      ELSE
         LET l_num_titulo_banco = g_novo_numero[1,l_tamanho-1]
      END IF

      IF l_num_titulo_banco < l_num_bloqueto_ini
      OR l_num_titulo_banco > l_num_bloqueto_fim THEN

         LET l_msg = 'O Número do boleto: ',gr_relat.nosso_numero,' \n',
                     'ultrapassou o número fornecido pelo Banco que é \n',
                     'de ' ,l_num_bloqueto_ini CLIPPED, ' até ' ,l_num_bloqueto_fim CLIPPED, ', \n',
                     'para o portador: ', m_portador, '. \n',
                     'Verificar se não ficaram parcelas em aberto para \n',
                     'o documento.'

         CALL log0030_mensagem(l_msg,"info")

         RETURN FALSE

      END IF
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------------------#
 FUNCTION geo1015_atualiza_par_bloqueto_laser()
#-----------------------------------------------#
   DEFINE l_num_ult_bloqueto      LIKE par_bloqueto_laser.num_ult_bloqueto

   CALL geo1015_grava_audit("14aBOLETO NF "||mr_param.nota_fiscal_ini)
   IF NOT vdpm315_par_bloqueto_laser_leitura(m_cod_empresa_matr,m_portador,TRUE,TRUE) THEN
      RETURN FALSE
   END IF
   CALL geo1015_grava_audit("14bBOLETO NF "||mr_param.nota_fiscal_ini)
   LET l_num_ult_bloqueto = vdpm315_par_bloqueto_laser_get_num_ult_bloqueto() # CONTROLE DE CONCORRENCIA DO REGISTRO
   CALL geo1015_grava_audit("14cBOLETO NF "||mr_param.nota_fiscal_ini)
   IF l_num_ult_bloqueto = gr_relat.nosso_numero THEN
      #IF NOT log0040_confirm(06,15,'Número do título bancário utilizado por outro bloqueto\.Processar novamente?') THEN
      #   LET m_concorr_reprocessar = FALSE
      #ELSE
         LET m_concorr_reprocessar = TRUE
      #END IF
      CALL log085_transacao('ROLLBACK')
      RETURN FALSE
   END IF
   CALL geo1015_grava_audit("14dBOLETO NF "||mr_param.nota_fiscal_ini)

   LET m_concorr_reprocessar = FALSE

   CALL vdpm315_par_bloqueto_laser_set_num_ult_bloqueto(gr_relat.nosso_numero)
   CALL geo1015_grava_audit("14eBOLETO NF "||mr_param.nota_fiscal_ini)
   IF NOT vdpt315_par_bloqueto_laser_modifica(TRUE,FALSE) THEN
      CALL log085_transacao('ROLLBACK')
      RETURN FALSE
   END IF
   
   CALL geo1015_grava_audit("14fBOLETO NF "||mr_param.nota_fiscal_ini)

   CALL log085_transacao('COMMIT')
   CALL geo1015_grava_audit("14gBOLETO NF "||mr_param.nota_fiscal_ini)
   RETURN TRUE

END FUNCTION

#-------------------------#
 FUNCTION geo1015_popup()
#-------------------------#

   DEFINE l_portador LIKE portador.cod_portador

   CASE
     WHEN INFIELD(portador_determ)
       CALL cre323_popup_port_banco()
            RETURNING l_portador

       IF l_portador IS NOT NULL THEN

          CURRENT WINDOW IS w_geo1015_principal

          LET mr_tela.portador_determ = l_portador

          DISPLAY BY NAME mr_tela.portador_determ
       END IF

   END CASE

END FUNCTION


#---------------------------------------#
FUNCTION geo1015_atualiza_docum_banco()
#---------------------------------------#

   DEFINE l_cliente_especifico  SMALLINT

   DEFINE l_variavel_nula       CHAR(01)

   #IF crem131_docum_banco_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
   #                               mr_docum.ies_tip_docum,m_portador,FALSE,TRUE) THEN
   #
   #   INITIALIZE l_variavel_nula TO NULL
   #
   #   CALL crem131_docum_banco_set_num_titulo_banco(g_novo_numero)
   #   CALL crem131_docum_banco_set_dat_confirm_banco(l_variavel_nula)
   #   CALL crem131_docum_banco_set_ies_emis_boleto('C')
   #
   #   IF NOT cret131_docum_banco_modifica(TRUE,FALSE) THEN
   #      RETURN FALSE
   #   END IF
   #
   #ELSE

      CALL crem131_docum_banco_set_cod_empresa(mr_docum.cod_empresa)
      CALL crem131_docum_banco_set_num_docum(mr_docum.num_docum)
      CALL crem131_docum_banco_set_ies_tip_docum(mr_docum.ies_tip_docum)
      CALL crem131_docum_banco_set_cod_portador(m_portador)
      CALL crem131_docum_banco_set_cod_agencia(0)
      CALL crem131_docum_banco_set_dig_agencia(0)
      CALL crem131_docum_banco_set_num_titulo_banco(g_novo_numero)
      CALL crem131_docum_banco_set_dat_confirm_banco(l_variavel_nula)
      CALL crem131_docum_banco_set_ies_emis_boleto('C')

      IF NOT cret131_docum_banco_inclui(TRUE,FALSE) THEN
         RETURN FALSE
      END IF

   #END IF

   #Função específica cliente 834 - SOMAT: agrupamento de NSs e DPs na
   #impressão/reimpressão do boleto (OS 422113).
   #Deverá ser atualizada/gravada a tabela DOCUM_BANCO para os documentos
   #do tipo 'NS' que foram agrupados.
   IF Find4GLFunction('crey2_docum_banco') THEN #OS 594370
      CALL crey2_docum_banco(mr_docum.*, g_novo_numero)
         RETURNING m_status, l_cliente_especifico
   ELSE
      LET l_cliente_especifico = FALSE
   END IF

   IF l_cliente_especifico THEN
      IF NOT m_status THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION


#-----------------------------------------------#
 FUNCTION geo1015_atualiza_fat_ctr_val_diario()
#-----------------------------------------------#

   DEFINE l_val_acumulado_dia     DECIMAL(17,2),
          l_limite                DECIMAL(17,6),
          l_msg                   CHAR(300)

   IF vdpm325_fat_ctr_val_diario_leitura(mr_docum.cod_empresa,m_portador,TODAY,FALSE,TRUE) THEN

      LET l_val_acumulado_dia = vdpm325_fat_ctr_val_diario_get_val_acumulado_dia()

      IF l_val_acumulado_dia IS NULL THEN
         LET l_val_acumulado_dia = m_val_boleto
      ELSE
         LET l_val_acumulado_dia = l_val_acumulado_dia + m_val_boleto
      END IF

      CALL vdpm325_fat_ctr_val_diario_set_val_acumulado_dia(l_val_acumulado_dia)

      IF NOT vdpt325_fat_ctr_val_diario_modifica(TRUE,FALSE) THEN
         RETURN FALSE
      END IF

   ELSE

      CALL vdpm325_fat_ctr_val_diario_set_empresa(mr_docum.cod_empresa)
      CALL vdpm325_fat_ctr_val_diario_set_portador(m_portador)
      CALL vdpm325_fat_ctr_val_diario_set_dat(TODAY)
      CALL vdpm325_fat_ctr_val_diario_set_val_acumulado_dia(m_val_boleto)

      IF NOT vdpt325_fat_ctr_val_diario_inclui(TRUE,FALSE) THEN
         RETURN FALSE
      END IF

   END IF

   RETURN TRUE

END FUNCTION


#------------------------------------------------------------#
 FUNCTION geo1015_atualiza_determinacao_portador_documento()
#------------------------------------------------------------#

   CALL crem17_docum_set_cod_portador(m_portador)
   CALL crem17_docum_set_ies_tip_portador('B')
   CALL crem17_docum_set_ies_tip_cobr('S')
   CALL crem17_docum_set_ies_cnd_bordero('B')
   CALL crem17_docum_set_ies_tip_emis_docum('N')
   CALL crem17_docum_set_dat_atualiz(m_dat_proces_doc)

   IF NOT cret17_docum_modifica(TRUE,FALSE) THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#--------------------------------------------#
 FUNCTION geo1015_atualiza_cre_docum_compl()
#--------------------------------------------#

  DEFINE l_texto_campo     LIKE cre_docum_compl.campo

  LET l_texto_campo = 'CRE10560-Cod.Barras Port: ', mr_docum.cod_portador

   IF crem48_cre_docum_compl_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,l_texto_campo,FALSE,TRUE) THEN


      CALL crem48_cre_docum_compl_set_parametro_texto(gr_relat.cod_barras)

      IF NOT cret48_cre_docum_compl_modifica(TRUE,FALSE) THEN
         RETURN FALSE
      END IF

   ELSE

      CALL crem48_cre_docum_compl_set_empresa(mr_docum.cod_empresa)
      CALL crem48_cre_docum_compl_set_docum(mr_docum.num_docum)
      CALL crem48_cre_docum_compl_set_tip_docum(mr_docum.ies_tip_docum)
      CALL crem48_cre_docum_compl_set_campo(l_texto_campo)
      CALL crem48_cre_docum_compl_set_parametro_texto(gr_relat.cod_barras)
      CALL crem48_cre_docum_compl_set_parametro_dat(CURRENT)

      IF NOT cret48_cre_docum_compl_inclui(TRUE,FALSE) THEN
         RETURN FALSE
      END IF

   END IF

   RETURN TRUE

END FUNCTION


#--------------------------------------#
 REPORT geo1015_relat_boleto_a_laser()
#--------------------------------------#

   DEFINE l_cod_cedente_caixa  CHAR(47)
   DEFINE l_funcao             CHAR(04),
          l_tam                SMALLINT,
          l_num_inicial        CHAR(20),
          l_dig                SMALLINT,
          l_dig_1              CHAR(02),
          l_num_inic_001       DECIMAL(20,0),
          l_dif                SMALLINT,
          l_for                SMALLINT,
          l_num_docum_inv      LIKE docum.num_docum,
          l_padrao             SMALLINT #TEXKEK

   DEFINE l_agencia_cedente_compl CHAR(100)
   DEFINE l_nosso_numero_compl    CHAR(20)
   DEFINE l_variavel_completa     CHAR(700)
   DEFINE l_posicao_inicial       SMALLINT

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          #PAGE  LENGTH 1

   FORMAT

   ON EVERY ROW
      # Reinicializa impressora

      PRINT ASCII 27,"E";
      #TEXKEK
      LET l_padrao = TRUE
      IF LOG_existe_epl("geo1015y_impr_boleto_folha_oficio") THEN
         #EPL executado indicar se utiliza papel oficio

         CALL LOG_setVar("padrao",l_padrao)
         #EPL Parametro indica se utiliza a rotina padrao
         #EPL tipo: smallint

         CALL geo1015y_impr_boleto_folha_oficio()

         LET l_padrao = LOG_getVar("padrao")
      END IF

      IF l_padrao = TRUE THEN
      PRINT ASCII 27,"&l26A";       # Papel A4
      ELSE
         PRINT ASCII 27,"&l3A";         # Papel Oficio
         PRINT ASCII 27,"&l11E";        # margem superior
      END IF
      #FIM

      # horizontais RECIBO DO SACADO

      PRINT ASCII 27, "*p0018x0018Y" , ASCII 27, "*c6b2319a0P";
      PRINT ASCII 27, "*p0018x+105Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      ELSE
         PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      END IF

      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c6b2319a0P";
      PRINT ASCII 27, "*p0018x+150Y" , ASCII 27, "*c6b2319a0P";

      #TESOURA e linha tracejada
      PRINT ASCII 27, "*p0000x1030Y" , ASCII 27, "(s1p10v0s0b3140T",
            ASCII 27,"(579L","#";
      PRINT ASCII 27, "*p0029x+010Y" , ASCII 27, "(s1p20h1s0b4099T",
            ASCII 27,"(12U";

      FOR l_for = 1 TO 92
          PRINT "- ";
      END FOR

      #   verticais RECIBO DO SACADO

      PRINT ASCII 27, "*p0018x0018Y", ASCII 27, "*c0830b3a0P";
      PRINT ASCII 27, "*p1555x+000Y", ASCII 27, "*c0680b3a0P";
      PRINT ASCII 27, "*p2335x+000Y", ASCII 27, "*c0830b3a0P";
      PRINT ASCII 27, "*p0336x+180Y", ASCII 27, "*c0144b3a0P";
      PRINT ASCII 27, "*p0750x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p0975x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p1161x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p0505x+072Y", ASCII 27, "*c0072b3a0P";

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27, "*p0244x+000Y", ASCII 27, "*c0072b3a0P";
      END IF

      PRINT ASCII 27, "*p0813x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p1218x+000Y", ASCII 27, "*c0072b3a0P";

      IF gr_relat.cod_banco[1,3] = "341"
      OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27, "*p0000x0072Y",ASCII 27,"(s1p12v0s3b4168T", " ";
      ELSE
         PRINT ASCII 27, "*p0530x+072Y", ASCII 27, "*c0072b3a0P";
         PRINT ASCII 27, "*p0830x+000Y", ASCII 27, "*c0072b3a0P";
      END IF

      #   sombreado RECIBO DO SACADO

      #PRINT ASCII 27, "*p1555x0018Y" , ASCII 27, "*c0105b0787a10g2P";
      #PRINT ASCII 27, "*p1555x+250Y" , ASCII 27, "*c0072b0787a10g2P";

      #      preenchimento RECIBO DO SACADO

      PRINT ASCII 27,"(12U";

      IF gr_relat.cod_banco[1,3] = "025" THEN
         PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p12v0s0b4101T",
                        "BRADESCO";
         PRINT ASCII 27,"*p0525x+000Y",ASCII 27,"(s1p16v0s3b4168T","| ",
                        "237-2", " |";
      ELSE
         LET l_tam = LENGTH(gr_relat.nom_banco)
         CASE
           WHEN l_tam <= 16
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p12v0s0b4101T",
                             gr_relat.nom_banco[1,16] CLIPPED;
           WHEN l_tam <= 17
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p11v0s0b4101T",
                             gr_relat.nom_banco[1,17] CLIPPED;
           WHEN l_tam <= 19
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p10v0s0b4101T",
                             gr_relat.nom_banco[1,19] CLIPPED;
           WHEN l_tam <= 20
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p09v0s0b4101T",
                             gr_relat.nom_banco[1,20] CLIPPED;
           WHEN l_tam <= 23
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p08v0s0b4101T",
                             gr_relat.nom_banco[1,23] CLIPPED;
           WHEN l_tam <= 27
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p07v0s0b4101T",
                             gr_relat.nom_banco[1,27] CLIPPED;
           WHEN l_tam <= 30
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p06v0s0b4101T",
                             gr_relat.nom_banco[1,30] CLIPPED;
         END CASE

         IF gr_relat.cod_banco = '353-b' AND m_portador_char[2,4]= '033' THEN
            LET gr_relat.cod_banco = '033-7'
         END IF #717511

         PRINT ASCII 27,"*p0525x+000Y",ASCII 27,"(s1p16v0s3b4168T","| ",
                       gr_relat.cod_banco, " |";
      END IF

      PRINT ASCII 27,"*p1724x+000Y",ASCII 27,"(s1p10v0s3b4168T",
                      "Recibo do Sacado";
      PRINT ASCII 27,"*p0033x+042Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Local de Pagamento";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T","Vencimento";
      PRINT ASCII 27,"*p0033x+105Y",ASCII 27,"(s0p20h1s0b4099T","Cedente";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Agencia/Codigo Cedente";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Data do Documento";
      PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "No. do Documento";
      PRINT ASCII 27,"*p0758x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Especie Doc.";
      PRINT ASCII 27,"*p0983x+000Y",ASCII 27,"(s0p20h1s0b4099T","Aceite";
      PRINT ASCII 27,"*p1168x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Data do Processamento";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Nosso Numero";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Uso do Banco";

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27,"*p0265x+000Y",ASCII 27,"(s0p20h1s0b4099T","CIP";
      END IF

      PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s3b4099T","Carteira";
      PRINT ASCII 27,"*p0513x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Especie da Moeda";
      PRINT ASCII 27,"*p0813x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     " Quantidade";
      PRINT ASCII 27,"*p1228x+000Y",ASCII 27,"(s0p20h1s0b4099T","Valor";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (=) Valor do Documento";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" OR gr_relat.cod_banco[1,3] = "001" THEN
         PRINT ASCII 27,"*p0000x+072Y",ASCII 27,"(s0p20h1s0b4099T", " ";
      ELSE
         PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Valor do Desconto";
         PRINT ASCII 27,"*p0600x+000Y",ASCII 27,"(s0p20h1s0b4099T","Ate";
         PRINT ASCII 27,"*p0950x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Com. Permanencia por dia";
      END IF
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (-) Desconto/Abatimento";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27,"*p0033x+020Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
         PRINT ASCII 27,"*p0000x+052Y",ASCII 27,"(s0p20h1s0b4099T"," ";
      ELSE
         PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
      END IF

      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (-) Outras Deducoes";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (+) Mora/Multa";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (+) Outros Acrescimos";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (=) Valor Cobrado";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Sacado";

      IF m_imprimir_endereco_cnpj_boleto = 'S' THEN
         PRINT ASCII 27,"*p1330x+000Y",ASCII 27,"(s0p20h1s0b4099T","Cedente";
      END IF

      PRINT ASCII 27,"*p0033x+122Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Sacador/Avalista:";

      IF gr_relat.cod_banco[1,3] = "409" THEN
         PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Cod. Trans CVT:";
      ELSE
         PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Codigo de Baixa:";
      END IF

      PRINT ASCII 27,"*p0033x+035Y",ASCII 27,"(s0p15h1s0b4099T",
                     "Recebimento atraves do cheque nr.";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p14h1s0b4099T",
                     "Autenticacao Mecanica";
      PRINT ASCII 27,"*p0033x+028Y",ASCII 27,"(s0p15h1s0b4099T","do banco:";
      PRINT ASCII 27,"*p0033x+028Y",ASCII 27,"(s0p15h1s0b4099T",
                   "Esta quitacao so tera validade apos pagamento do cheque";
      PRINT ASCII 27,"*p0033x+028Y",ASCII 27,"(s0p15h1s0b4099T",
                     "pelo banco sacado";

      #   horizontais FICHA DE COMPENSAÇÃO'

      PRINT ASCII 27, "*p0018x1140Y" , ASCII 27, "*c6b2319a0P";
      PRINT ASCII 27, "*p0018x+105Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      ELSE
         PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      END IF

      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c6b2319a0P";
      PRINT ASCII 27, "*p0018x+150Y" , ASCII 27, "*c6b2319a0P";

      #:: colocado no chamado 729328
      # imprime a tesourinha depois do codigo de barras.
      PRINT ASCII 27, "*p0000x+300Y" , ASCII 27, "(s1p10v0s0b3140T", #180
            ASCII 27,"(579L","#";
      PRINT ASCII 27, "*p0029x+005Y" , ASCII 27, "(s1p20h1s0b4099T",
            ASCII 27,"(12U";
      FOR l_for = 1 TO 92
         PRINT "- ";
      END FOR
      #:: 729328

      #   verticais FICHA DE COMPENSAÇÃO

      PRINT ASCII 27, "*p0018x1140Y", ASCII 27, "*c0830b3a0P";
      PRINT ASCII 27, "*p1555x+000Y", ASCII 27, "*c0680b3a0P";
      PRINT ASCII 27, "*p2335x+000Y", ASCII 27, "*c0830b3a0P";
      PRINT ASCII 27, "*p0336x+180Y", ASCII 27, "*c0144b3a0P";
      PRINT ASCII 27, "*p0750x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p0975x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p1161x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p0505x+072Y", ASCII 27, "*c0072b3a0P";

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27, "*p0244x+000Y", ASCII 27, "*c0072b3a0P";
      END IF

      PRINT ASCII 27, "*p0813x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p1218x+000Y", ASCII 27, "*c0072b3a0P";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27, "*p0000x0072Y",ASCII 27,"(s1p12v0s3b4168T", " " ;
      ELSE
         PRINT ASCII 27, "*p0530x+072Y", ASCII 27, "*c0072b3a0P";
         PRINT ASCII 27, "*p0830x+000Y", ASCII 27, "*c0072b3a0P";
      END IF

      #   sombreado FICHA DE COMPENSAÇÃO

      #PRINT ASCII 27, "*p1555x1140Y" , ASCII 27, "*c0105b0787a10g2P";
      #PRINT ASCII 27, "*p1555x+250Y" , ASCII 27, "*c0072b0787a10g2P";

      #   preenchimento FICHA DE COMPENSAÇÃO

      PRINT ASCII 27,"(12U";

      IF gr_relat.cod_banco[1,3] = "025" THEN
         PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p12v0s0b4101T",
                        "BRADESCO";
         PRINT ASCII 27,"*p0525x+000Y",ASCII 27,"(s1p16v0s3b4168T","| ",
                        "237-2", " |";
      ELSE
         LET l_tam = LENGTH(gr_relat.nom_banco)
         CASE
           WHEN l_tam <= 16
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p12v0s0b4101T",
                             gr_relat.nom_banco[1,16] CLIPPED;
           WHEN l_tam <= 17
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p11v0s0b4101T",
                             gr_relat.nom_banco[1,17] CLIPPED;
           WHEN l_tam <= 19
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p10v0s0b4101T",
                             gr_relat.nom_banco[1,19] CLIPPED;
           WHEN l_tam <= 20
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p09v0s0b4101T",
                             gr_relat.nom_banco[1,20] CLIPPED;
           WHEN l_tam <= 23
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p08v0s0b4101T",
                             gr_relat.nom_banco[1,23] CLIPPED;
           WHEN l_tam <= 27
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p07v0s0b4101T",
                             gr_relat.nom_banco[1,27] CLIPPED;
           WHEN l_tam <= 30
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p06v0s0b4101T",
                             gr_relat.nom_banco[1,30] CLIPPED;
         END CASE

         IF gr_relat.cod_banco = '353-b' AND m_portador_char[2,4]= '033' THEN
            LET gr_relat.cod_banco = '033-7'
         END IF #717511

         PRINT ASCII 27,"*p0525x+000Y",ASCII 27,"(s1p16v0s3b4168T","| ",
                         gr_relat.cod_banco, " | ";
      END IF

      #Texto do código de barras da Ficha de compensação - concatenado ao código do banco
      PRINT ASCII 27,"(s0P",ASCII 27,"(s0p11h0s3b4102T",gr_relat.txt_barras; #simenes

 #    PRINT ASCII 27,"*p1724x+000Y",ASCII 27,"(s1p10v0s3b4168T",
 #                     "Ficha de Compensação";
      PRINT ASCII 27,"*p0033x+040Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Local de Pagamento";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T","Vencimento";
      PRINT ASCII 27,"*p0033x+105Y",ASCII 27,"(s0p20h1s0b4099T","Cedente";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Agencia/Codigo Cedente";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Data do Documento";
      PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "No. do Documento";
      PRINT ASCII 27,"*p0758x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Especie Doc.";
      PRINT ASCII 27,"*p0983x+000Y",ASCII 27,"(s0p20h1s0b4099T","Aceite";
      PRINT ASCII 27,"*p1168x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Data do Processamento";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Nosso Numero";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Uso do Banco";

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27,"*p0265x+000Y",ASCII 27,"(s0p20h1s0b4099T","CIP";
      END IF

      PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s3b4099T","Carteira";
      PRINT ASCII 27,"*p0513x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Especie da Moeda";
      PRINT ASCII 27,"*p0813x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     " Quantidade";
      PRINT ASCII 27,"*p1228x+000Y",ASCII 27,"(s0p20h1s0b4099T","Valor";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (=) Valor do Documento";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" OR gr_relat.cod_banco[1,3] = "001" THEN
         PRINT ASCII 27,"*p0000x+072Y",ASCII 27,"(s0p20h1s0b4099T", " ";
      ELSE
         PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Valor do Desconto";
         PRINT ASCII 27,"*p0600x+000Y",ASCII 27,"(s0p20h1s0b4099T","Ate";
         PRINT ASCII 27,"*p0950x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Com. Permanencia por dia";
      END IF

      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (-) Desconto/Abatimento";

      IF gr_relat.cod_banco[1,3] = "341"  OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27,"*p0033x+020Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
         PRINT ASCII 27,"*p0000x+052Y",ASCII 27,"(s0p20h1s0b4099T"," ";
      ELSE
         PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
      END IF

      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (-) Outras Deducoes";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (+) Mora/Multa";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (+) Outros Acrescimos";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (=) Valor Cobrado";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Sacado";
      PRINT ASCII 27,"*p0033x+120Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Sacador/Avalista:";

      IF gr_relat.cod_banco[1,3] = "409" THEN
         PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Cod. Trans CVT:";
      ELSE
         PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Codigo de Baixa:";
      END IF

      PRINT ASCII 27,"*p1300x+045Y",ASCII 27,"(s0p14h1s0b4099T",
                     "  Autenticacao Mecanica/";

      #MARCOS
      #PRINT ASCII 27,"*p1555x+045Y",ASCII 27,"(s0p14h1s0b4099T",
      #               "Autenticacao Mecanica";

      #   horizontais FICHA DE COMPENSACAO

      #PRINT ASCII 27, "*p0018x2250Y" , ASCII 27, "*c6b2319a0P";
      #PRINT ASCII 27, "*p0018x+105Y" , ASCII 27, "*c3b2319a0P";
      #PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      #PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      #PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      #
      #IF gr_relat.cod_banco[1,3] = "341"
      #OR gr_relat.cod_banco[1,3] = "422" THEN
      #   PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      #ELSE
      #   PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      #END IF
      #
      #PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      #PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      #PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      #PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c6b2319a0P";
      #PRINT ASCII 27, "*p0018x+150Y" , ASCII 27, "*c6b2319a0P";

      #   verticais FICHA DE COMPENSACAO

      #PRINT ASCII 27, "*p0018x2250Y", ASCII 27, "*c0830b3a0P";
      #PRINT ASCII 27, "*p1555x+000Y", ASCII 27, "*c0680b3a0P";
      #PRINT ASCII 27, "*p2335x+000Y", ASCII 27, "*c0830b3a0P";
      #PRINT ASCII 27, "*p0336x+180Y", ASCII 27, "*c0144b3a0P";
      #PRINT ASCII 27, "*p0750x+000Y", ASCII 27, "*c0072b3a0P";
      #PRINT ASCII 27, "*p0975x+000Y", ASCII 27, "*c0072b3a0P";
      #PRINT ASCII 27, "*p1161x+000Y", ASCII 27, "*c0072b3a0P";
      #PRINT ASCII 27, "*p0505x+072Y", ASCII 27, "*c0072b3a0P";

      #IF  m_codigo_cip IS NOT NULL
      #AND m_codigo_cip <> " " THEN
      #   PRINT ASCII 27, "*p0244x+000Y", ASCII 27, "*c0072b3a0P";
      #END IF

      #PRINT ASCII 27, "*p0813x+000Y", ASCII 27, "*c0072b3a0P";
      #PRINT ASCII 27, "*p1218x+000Y", ASCII 27, "*c0072b3a0P";
      #
      #IF gr_relat.cod_banco[1,3] = "341"
      #OR gr_relat.cod_banco[1,3] = "422" THEN
      #   PRINT ASCII 27, "*p0000x0072Y",ASCII 27,"(s1p12v0s3b4168T", " " ;
      #ELSE
      #   PRINT ASCII 27, "*p0530x+072Y", ASCII 27, "*c0072b3a0P";
      #   PRINT ASCII 27, "*p0830x+000Y", ASCII 27, "*c0072b3a0P";
      #END IF


      #   sombreado FICHA DE COMPENSACAO

      #PRINT ASCII 27, "*p1555x2250Y" , ASCII 27, "*c0105b0787a10g2P";
      #PRINT ASCII 27, "*p1555x+250Y" , ASCII 27, "*c0072b0787a10g2P";

      #   preenchimento FICHA DE COMPENSACAO

      #PRINT ASCII 27,"(12U";
      #
      #LET l_tam = LENGTH(gr_relat.nom_banco)
      #CASE
      #  WHEN l_tam <= 16
      #    PRINT ASCII 27,"*p0018x2240Y",ASCII 27,"(s1p12v0s0b4101T",
      #                    gr_relat.nom_banco[1,16] CLIPPED;
      #  WHEN l_tam <= 17
      #    PRINT ASCII 27,"*p0018x2240Y",ASCII 27,"(s1p11v0s0b4101T",
      #                    gr_relat.nom_banco[1,17] CLIPPED;
      #  WHEN l_tam <= 19
      #    PRINT ASCII 27,"*p0018x2240Y",ASCII 27,"(s1p10v0s0b4101T",
      #                    gr_relat.nom_banco[1,19] CLIPPED;
      #  WHEN l_tam <= 20
      #    PRINT ASCII 27,"*p0018x2240Y",ASCII 27,"(s1p09v0s0b4101T",
      #                    gr_relat.nom_banco[1,20] CLIPPED;
      #  WHEN l_tam <= 23
      #    PRINT ASCII 27,"*p0018x2240Y",ASCII 27,"(s1p08v0s0b4101T",
      #                    gr_relat.nom_banco[1,23] CLIPPED;
      #  WHEN l_tam <= 27
      #    PRINT ASCII 27,"*p0018x2240Y",ASCII 27,"(s1p07v0s0b4101T",
      #                    gr_relat.nom_banco[1,27] CLIPPED;
      #  WHEN l_tam <= 30
      #    PRINT ASCII 27,"*p0018x2240Y",ASCII 27,"(s1p06v0s0b4101T",
      #                    gr_relat.nom_banco[1,30] CLIPPED;
      #END CASE
      #
      #PRINT ASCII 27,"*p0525x+000Y",ASCII 27,"(s1p16v0s3b4168T","| ",
      #                gr_relat.cod_banco, " |";
      #
      #PRINT ASCII 27,"*p0033x+040Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Local de Pagamento";
      #PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T","Vencimento";
      #PRINT ASCII 27,"*p0033x+105Y",ASCII 27,"(s0p20h1s0b4099T","Cedente";
      #PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Agencia/Codigo Cedente";
      #PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Data do Documento";
      #PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "No. do Documento";
      #PRINT ASCII 27,"*p0758x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Especie Doc.";
      #PRINT ASCII 27,"*p0983x+000Y",ASCII 27,"(s0p20h1s0b4099T","Aceite";
      #PRINT ASCII 27,"*p1168x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Data do Processamento";
      #PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Nosso Numero";
      #PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Uso do Banco";

      #IF  m_codigo_cip IS NOT NULL
      #AND m_codigo_cip <> " " THEN
      #   PRINT ASCII 27,"*p0265x+000Y",ASCII 27,"(s0p20h1s0b4099T","CIP";
      #END IF

      #PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s3b4099T","Carteira";
      #PRINT ASCII 27,"*p0513x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Especie da Moeda";
      #PRINT ASCII 27,"*p0813x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               " Quantidade";
      #PRINT ASCII 27,"*p1228x+000Y",ASCII 27,"(s0p20h1s0b4099T","Valor";
      #PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "  (=) Valor do Documento";
      #PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      #
      #IF gr_relat.cod_banco[1,3] = "341"
      #OR gr_relat.cod_banco[1,3] = "422" THEN
      #   PRINT ASCII 27,"*p0000x+072Y",ASCII 27,"(s0p20h1s0b4099T", " ";
      #ELSE
      #   PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Valor do Desconto";
      #   PRINT ASCII 27,"*p0600x+000Y",ASCII 27,"(s0p20h1s0b4099T","Ate";
      #   PRINT ASCII 27,"*p0950x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Com. Permanencia por dia";
      #END IF
      #
      #PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "  (-) Desconto/Abatimento";
      #
      #IF gr_relat.cod_banco[1,3] = "341"
      #OR gr_relat.cod_banco[1,3] = "422" THEN
      #   PRINT ASCII 27,"*p0033x+020Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
      #   PRINT ASCII 27,"*p0000x+052Y",ASCII 27,"(s0p20h1s0b4099T"," ";
      #ELSE
      #   PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
      #END IF
      #
      #PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "  (-) Outras Deducoes";
      #PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      #PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "  (+) Mora/Multa";
      #PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "  (+) Outros Acrescimos";
      #PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      #PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "  (=) Valor Cobrado";
      #PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Sacado";
      #PRINT ASCII 27,"*p0033x+120Y",ASCII 27,"(s0p20h1s0b4099T",
      #               "Sacador/Avalista:";
      #
      #IF gr_relat.cod_banco[1,3] = "409" THEN
      #   PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #                  "Cod. Trans CVT:";
      #ELSE
      #  PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
      #                 "Codigo de Baixa:";
      #END IF
      #
      #PRINT ASCII 27,"*p1300x+045Y",ASCII 27,"(s0p14h1s0b4099T",
      #               "  Autenticacao Mecanica/";

      # Codigo de barra

      # Posicao do codigo de barra
      #PRINT ASCII 27,"*p0018x3115Y";
      PRINT ASCII 27,"*p0018x2041Y";
      PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
      PRINT ASCII 27 , "*p+3X";
      PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
      PRINT ASCII 27 , "*p+3X";

      FOR l_for = 1 TO 43 STEP 2
          # 1 bit
          IF gr_relat.cod_barras[l_for] = "1" OR
             gr_relat.cod_barras[l_for] = "3" OR
             gr_relat.cod_barras[l_for] = "5" OR
             gr_relat.cod_barras[l_for] = "8" THEN
             PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
          ELSE
             PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
          END IF
          IF gr_relat.cod_barras[l_for+1] = "1" OR
             gr_relat.cod_barras[l_for+1] = "3" OR
             gr_relat.cod_barras[l_for+1] = "5" OR
             gr_relat.cod_barras[l_for+1] = "8" THEN
             PRINT ASCII 27 , "*p+9X";
          ELSE
             PRINT ASCII 27 , "*p+3X";
          END IF
          #  2 bit
          IF gr_relat.cod_barras[l_for] = "2" OR
             gr_relat.cod_barras[l_for] = "3" OR
             gr_relat.cod_barras[l_for] = "6" OR
             gr_relat.cod_barras[l_for] = "9" THEN
             PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
          ELSE
             PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
          END IF
          IF gr_relat.cod_barras[l_for+1] = "2" OR
             gr_relat.cod_barras[l_for+1] = "3" OR
             gr_relat.cod_barras[l_for+1] = "6" OR
             gr_relat.cod_barras[l_for+1] = "9" THEN
             PRINT ASCII 27 , "*p+9X";
          ELSE
             PRINT ASCII 27 , "*p+3X";
          END IF
          # 3 bit
          IF gr_relat.cod_barras[l_for] = "0" OR
             gr_relat.cod_barras[l_for] = "4" OR
             gr_relat.cod_barras[l_for] = "5" OR
             gr_relat.cod_barras[l_for] = "6" THEN
             PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
          ELSE
             PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
          END IF
          IF gr_relat.cod_barras[l_for+1] = "0" OR
             gr_relat.cod_barras[l_for+1] = "4" OR
             gr_relat.cod_barras[l_for+1] = "5" OR
             gr_relat.cod_barras[l_for+1] = "6" THEN
             PRINT ASCII 27 , "*p+9X";
          ELSE
             PRINT ASCII 27 , "*p+3X";
          END IF
          # 4 bit
          IF gr_relat.cod_barras[l_for] = "0" OR
             gr_relat.cod_barras[l_for] = "7" OR
             gr_relat.cod_barras[l_for] = "8" OR
             gr_relat.cod_barras[l_for] = "9" THEN
             PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
          ELSE
             PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
          END IF
          IF gr_relat.cod_barras[l_for+1] = "0" OR
             gr_relat.cod_barras[l_for+1] = "7" OR
             gr_relat.cod_barras[l_for+1] = "8" OR
             gr_relat.cod_barras[l_for+1] = "9" THEN
             PRINT ASCII 27 , "*p+9X";
          ELSE
             PRINT ASCII 27 , "*p+3X";
          END IF
          # 5 bit
          IF gr_relat.cod_barras[l_for] = "1" OR
             gr_relat.cod_barras[l_for] = "2" OR
             gr_relat.cod_barras[l_for] = "4" OR
             gr_relat.cod_barras[l_for] = "7" THEN
             PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
          ELSE
             PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
          END IF
          IF gr_relat.cod_barras[l_for+1] = "1" OR
             gr_relat.cod_barras[l_for+1] = "2" OR
             gr_relat.cod_barras[l_for+1] = "4" OR
             gr_relat.cod_barras[l_for+1] = "7" THEN
             PRINT ASCII 27 , "*p+9X";
          ELSE
             PRINT ASCII 27 , "*p+3X";
          END IF
      END FOR

      PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
      PRINT ASCII 27 , "*p+3X";
      PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";

      #   Preenchimento RECIBO DO SACADO

      PRINT ASCII 27,"(12U",ASCII 27,"(s0p13h0s3b4099T";
      PRINT ASCII 27,"*p0030x0082Y", gr_relat.loc_pgto_1;

      LET l_variavel_completa = gr_relat.dat_vencto
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", gr_relat.dat_vencto   USING "dd/mm/yyyy";

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.loc_pgto_2;

      IF m_cedente IS NULL THEN
         PRINT ASCII 27,"*p0030x+070Y", gr_relat.den_empresa;
      ELSE
         PRINT ASCII 27,"*p0030x+070Y", m_cedente[1,60];
      END IF

      CASE
         WHEN gr_relat.cod_banco[1,3] = "001"
            LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia CLIPPED,"-",
                                          gr_par_bloq_laser.dig_agencia CLIPPED,
                                          '/',
                                          gr_relat.cod_cedente

        {WHEN gr_relat.cod_banco[1,3] = '104'
            LET l_cod_cedente_caixa = gr_relat.cod_cedente,'00000000000000000000000000000000'
            LET m_dv_verificador    = cap446_calcula_dv_geral('DVB',l_cod_cedente_caixa)

            LET l_agencia_cedente_compl = gr_relat.cod_cedente[1,4],'.',
                                          gr_relat.cod_cedente[5,7],'.',
                                          gr_relat.cod_cedente[8,15],'-',
                                          m_dv_verificador                                  }

         WHEN gr_relat.cod_banco[1,3] = "275"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                          "/",
                                          gr_relat.cod_cedente CLIPPED,
                                          "/",
                                          gr_relat.nosso_numero[9,9]

         WHEN gr_relat.cod_banco[1,3] = "341"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                          "/",
                                          gr_relat.cod_cedente CLIPPED

         WHEN gr_relat.cod_banco[1,3] = "356"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                          "/",
                                          gr_relat.cod_cedente CLIPPED,
                                          "/",
                                          gr_relat.nosso_numero[9,9]

         WHEN gr_relat.cod_banco[1,3] = "399"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                          "/",
                                          gr_relat.cod_cedente

         WHEN gr_relat.cod_banco[1,3] = "409" AND gr_par_bloq_laser.par_bloq_txt[139,139] = "2"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia,
                                          gr_par_bloq_laser.par_bloq_txt[151] CLIPPED,
                                          "/",
                                          gr_par_bloq_laser.num_conta USING "<<<<<<<<<<<<","-",
                                          gr_par_bloq_laser.dig_conta USING "&"

         WHEN gr_relat.cod_banco[1,3] = "422"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia CLIPPED,
                                          ".",
                                          gr_relat.cod_cedente

         WHEN gr_relat.cod_banco[1,3] = "027"
            IF gr_par_bloq_laser.par_bloq_txt[139,139] = "2" THEN
               LET l_agencia_cedente_compl = gr_relat.nosso_numero[1,15],
                                             '-',
                                             gr_relat.nosso_numero[16]

            ELSE
               LET l_agencia_cedente_compl = gr_relat.cod_agencia[2,4]  USING "&&&",
                                             "-",
                                             gr_relat.cod_carteira[1,2] USING "&&",
                                             "-",
                                             gr_relat.nosso_numero[1,4],
                                             ".",
                                             gr_relat.nosso_numero[5,8],
                                             "-9"
            END IF

         WHEN gr_relat.cod_banco[1,3] = "389"
            LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia USING "&&&&",
                                          "/",
                                          gr_relat.cod_cedente[1,8],
                                          "-",
                                          gr_relat.cod_cedente[9,9]

         OTHERWISE
            LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia CLIPPED,"-",
                                          gr_par_bloq_laser.dig_agencia CLIPPED,
                                          "/",
                                          gr_relat.cod_cedente

      END CASE

      LET l_variavel_completa = l_agencia_cedente_compl
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_agencia_cedente_compl;

      PRINT ASCII 27,"*p0060x+072Y", gr_relat.dat_emissao  USING "dd/mm/yyyy";

      IF Find4GLFunction("crey49_verifica_inversao") THEN
         CALL crey49_verifica_inversao(m_portador_original)
         RETURNING m_status

         IF m_status = TRUE THEN
            CALL crey49_inverte_documento(gr_relat.num_docum)
            RETURNING l_num_docum_inv

            PRINT ASCII 27,"*p0400x+000Y", l_num_docum_inv;
         ELSE
            PRINT ASCII 27,"*p0400x+000Y", gr_relat.num_docum;
         END IF
      ELSE
         PRINT ASCII 27,"*p0400x+000Y", gr_relat.num_docum;
      END IF

      #OS453604
      IF NOT (gr_relat.cod_banco[1,3] = "399" AND
         gr_par_bloq_laser.par_bloq_txt[139,139] = "2") THEN
         PRINT ASCII 27,"*p0761x+000Y", gr_relat.esp_docum;
         PRINT ASCII 27,"*p0990x+000Y", gr_relat.cod_aceite;
         PRINT ASCII 27,"*p1250x+000Y", TODAY USING "dd/mm/yyyy";
      END IF

      CASE
         WHEN gr_relat.cod_banco[1,3] = "275"
            LET l_nosso_numero_compl = gr_relat.nosso_numero[1,7]

         WHEN gr_relat.cod_banco[1,3] = "356"
            LET l_nosso_numero_compl = gr_relat.nosso_numero[1,7]

         WHEN gr_relat.cod_banco[1,3] = "237"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,2],
                                       "/",
                                       gr_relat.nosso_numero

         WHEN gr_relat.cod_banco[1,3] = "044"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,2],
                                       "/",
                                       gr_relat.nosso_numero

         WHEN gr_relat.cod_banco[1,3] = "025"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,3],
                                       "/",
                                       gr_relat.nosso_numero

         OTHERWISE
            LET l_tam = LENGTH(gr_relat.nosso_numero)
            LET l_dif = 17 - l_tam

            IF l_dif >= 0 THEN
               LET l_nosso_numero_compl = gr_relat.nosso_numero
            ELSE
               LET l_dif = l_dif * (-1)
               LET l_nosso_numero_compl = gr_relat.nosso_numero[1,l_tam-l_dif]
            END IF

      END CASE

      LET l_variavel_completa = l_nosso_numero_compl
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_nosso_numero_compl;

      PRINT ASCII 27,"*p0033x+072Y", gr_par_bloq_laser.par_bloq_txt[11,19];

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27,"*p0255x+000Y", m_codigo_cip;
      END IF

      #OS453604
      IF gr_relat.cod_banco[1,3] = '399' AND
         gr_par_bloq_laser.par_bloq_txt[139,139] = '2' THEN
         PRINT ASCII 27,"*p0343x+000YCNR";
         PRINT ASCII 27,"*p0540x+000Y09-REAL";
      ELSE
         PRINT ASCII 27,"*p0343x+000Y", gr_relat.cod_carteira;
         PRINT ASCII 27,"*p0540x+000Y", gr_relat.esp_moeda;
      END IF

      LET l_variavel_completa = gr_relat.val_docum USING "#,###,###,##&.&&"
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_variavel_completa;

      PRINT ASCII 27,"*p1000x+072Y";
      PRINT ASCII 27,"*p0030x+072Y", gr_relat.instrucoes1;

      IF gr_relat.out_deducoes > 0 THEN

         LET l_variavel_completa = gr_relat.out_deducoes USING "#,###,###,##&.&&"
         CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                           2300                )
         RETURNING l_posicao_inicial

         PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_variavel_completa;

      ELSE
         PRINT ASCII 27,"*p1800x+000Y"," ";
      END IF

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes2;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes3;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes4;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes5;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes6;

      IF m_imprimir_endereco_cnpj_boleto = 'S' THEN
         PRINT ASCII 27,"(12U",ASCII 27,"(s0p18h0s3b4099T"; # Diminuir tamanho tamanho da fonte

         PRINT ASCII 27,"*p0140x+113Y", gr_relat.nom_cliente,
                                        "  CNPJ/CPF: ",
                                        gr_relat.num_cgc_cpf;

         PRINT ASCII 27,"*p1400x+000Y", "    RUA: ",
                                        mr_empresa.end_empresa;

         PRINT ASCII 27,"*p0140x+030Y", gr_relat.end_cliente,
                                        "    BAIRRO: ",
                                        gr_relat.den_bairro;

         PRINT ASCII 27,"*p1400x+000Y", " BAIRRO: ",
                                        mr_empresa.den_bairro,
                                        "   CEP: ",
                                        mr_empresa.cod_cep;


         PRINT ASCII 27,"*p0140x+030Y", gr_relat.den_cidade,
                                        "              UF: ",
                                        gr_relat.cod_uni_feder,
                                        "   CEP: ",
                                        gr_relat.cod_cep;

         PRINT ASCII 27,"*p1400x+000Y", " CIDADE: ",
                                        mr_empresa.den_munic,
                                        "  UF: ",
                                        mr_empresa.uni_feder;

         PRINT ASCII 27,"*p0950x+028Y", gr_par_bloq_laser.par_bloq_txt[11,19] CLIPPED,
                                        gr_par_bloq_laser.par_bloq_txt[152,152];

         PRINT ASCII 27,"*p1400x+000Y", "   CNPJ: ",
                                        mr_empresa.num_cgc;

         PRINT ASCII 27,"*p0290x+021Y", m_sacador_avalista[1,35];


         PRINT ASCII 27,"(12U",ASCII 27,"(s0p12h0s3b4099T"; # Aumentar novamente o tamanho da fonte

      ELSE
         #TFADU2#
         IF LOG_existe_epl("geo1015y_get_nome_cliente") THEN

            PRINT ASCII 27,"*p0140x+113Y", LOG_getVar("nom_cliente"),
                                           "  - ",
                                           gr_relat.num_cgc_cpf;
         ELSE
            PRINT ASCII 27,"*p0230x+133Y", gr_relat.nom_cliente,
                                           "  CNPJ/CPF: ",
                                           gr_relat.num_cgc_cpf;
         END IF
         #TFADU2#
         IF LOG_existe_epl("geo1015y_get_end_cliente") THEN
            PRINT ASCII 27,"*p0140x+030Y", LOG_getVar("end_cliente"),
                                        " - ",
                                        gr_relat.den_cidade,
                                        " - ",
                                        gr_relat.cod_uni_feder,
                                        " - ",
                                        gr_relat.den_bairro,
                                        " - ",
                                        gr_relat.cod_cep,
                                        "                        ",
                                        gr_par_bloq_laser.par_bloq_txt[11,19];
         ELSE
            PRINT ASCII 27,"*p0230x+030Y", gr_relat.end_cliente,
                                           "    BAIRRO: ",
                                           gr_relat.den_bairro;
            PRINT ASCII 27,"*p0230x+030Y", gr_relat.den_cidade,
                                           "              UF: ",
                                           gr_relat.cod_uni_feder;
            PRINT ASCII 27,"*p0290x+030Y", m_sacador_avalista[1,39];
            PRINT ASCII 27,"*p1197x+000Y", " CEP: ",
                                           gr_relat.cod_cep,
                                           "                        ",
                                           gr_par_bloq_laser.par_bloq_txt[11,19];
         END IF
      END IF

      IF Find4GLFunction("crey52_funcao_especifico_1131") THEN

         IF crey52_get_outros_acrescimos() > 0 THEN

            LET l_variavel_completa = crey52_get_outros_acrescimos() USING "#,###,###,##&.&&"
            CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                              2300                )
            RETURNING l_posicao_inicial

            PRINT ASCII 27,"*p",l_posicao_inicial,"x-228Y", l_variavel_completa;

            LET l_variavel_completa = (gr_relat.val_docum + crey52_get_outros_acrescimos()) USING "#,###,###,##&.&&"
            CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                              2300                )
            RETURNING l_posicao_inicial

            PRINT ASCII 27,"*p",l_posicao_inicial,"x+072Y", l_variavel_completa;

         END IF

      END IF


      #   Preenchimento FICHA DO COMPENSAÇÃO

      PRINT ASCII 27,"(12U",ASCII 27,"(s0p13h0s3b4099T";
      PRINT ASCII 27,"*p0030x1215Y", gr_relat.loc_pgto_1;

      LET l_variavel_completa = gr_relat.dat_vencto
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", gr_relat.dat_vencto USING "dd/mm/yyyy";

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.loc_pgto_2;

      IF m_cedente IS NULL THEN
         PRINT ASCII 27,"*p0030x+060Y", gr_relat.den_empresa;
      ELSE
         PRINT ASCII 27,"*p0030x+060Y", m_cedente[1,60];
      END IF

      CASE
        WHEN gr_relat.cod_banco[1,3] = "001"
           LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia CLIPPED,"-",
                                         gr_par_bloq_laser.dig_agencia CLIPPED,
                                         '/',
                                         gr_relat.cod_cedente


        # Caixa Econômica Federal (Código Febraban 104) # 725652
        {WHEN gr_relat.cod_banco[1,3] = '104'
           LET l_cod_cedente_caixa = gr_relat.cod_cedente,'00000000000000000000000000000000'
           LET m_dv_verificador    = cap446_calcula_dv_geral('DVB',l_cod_cedente_caixa)

           LET l_agencia_cedente_compl = gr_relat.cod_cedente[1,4],'.',
                                         gr_relat.cod_cedente[5,7],'.',
                                         gr_relat.cod_cedente[8,15],'-',
                                         m_dv_verificador                                  }



        WHEN gr_relat.cod_banco[1,3] = "341"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente CLIPPED


        WHEN gr_relat.cod_banco[1,3] = "275"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente CLIPPED,
                                         "/",
                                         gr_relat.nosso_numero[9,9]

        WHEN gr_relat.cod_banco[1,3] = "356"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente CLIPPED,
                                         "/",
                                         gr_relat.nosso_numero[9,9]

        WHEN gr_relat.cod_banco[1,3] = "399"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente


        WHEN gr_relat.cod_banco[1,3] = "409" AND gr_par_bloq_laser.par_bloq_txt[139,139] = "2"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia,
                                         gr_par_bloq_laser.par_bloq_txt[151] CLIPPED,
                                         "/",
                                         gr_par_bloq_laser.num_conta USING "<<<<<<<<<<<<","-",
                                         gr_par_bloq_laser.dig_conta USING "&"


        WHEN gr_relat.cod_banco[1,3] = "422"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia CLIPPED,
                                         ".",
                                         gr_relat.cod_cedente

        WHEN gr_relat.cod_banco[1,3] = "389"
           LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia USING "&&&&",
                                         "/",
                                         gr_relat.cod_cedente[1,8],
                                         "-",
                                         gr_relat.cod_cedente[9,9]

        OTHERWISE
           LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia CLIPPED,"-",
                                         gr_par_bloq_laser.dig_agencia CLIPPED,
                                         "/",
                                         gr_relat.cod_cedente

      END CASE

      LET l_variavel_completa = l_agencia_cedente_compl
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_agencia_cedente_compl;


      PRINT ASCII 27,"*p0060x+072Y", gr_relat.dat_emissao USING "dd/mm/yyyy";

      IF Find4GLFunction("crey49_verifica_inversao") THEN
         CALL crey49_verifica_inversao(m_portador_original)
         RETURNING m_status

         IF m_status = TRUE THEN
            CALL crey49_inverte_documento(gr_relat.num_docum)
            RETURNING l_num_docum_inv

            PRINT ASCII 27,"*p0400x+000Y", l_num_docum_inv;
         ELSE
            PRINT ASCII 27,"*p0400x+000Y", gr_relat.num_docum;
         END IF
      ELSE
         PRINT ASCII 27,"*p0400x+000Y", gr_relat.num_docum;
      END IF

      #OS453604
      IF NOT (gr_relat.cod_banco[1,3] = "399" AND
         gr_par_bloq_laser.par_bloq_txt[139,139] = "2") THEN
         PRINT ASCII 27,"*p0761x+000Y", gr_relat.esp_docum;
         PRINT ASCII 27,"*p0990x+000Y", gr_relat.cod_aceite;
         PRINT ASCII 27,"*p1250x+000Y", TODAY USING "dd/mm/yyyy";
      END IF

      CASE
         WHEN gr_relat.cod_banco[1,3] = "027"
            IF gr_par_bloq_laser.par_bloq_txt[139,139] = "2" THEN
               LET l_nosso_numero_compl = gr_relat.nosso_numero[1,15],
                                          '-',
                                          gr_relat.nosso_numero[16]
            ELSE
               LET l_nosso_numero_compl = gr_relat.cod_agencia[2,4]  USING "&&&",
                                          "-",
                                          gr_relat.cod_carteira[1,2] USING "&&",
                                          "-",
                                          gr_relat.nosso_numero[1,4],
                                          ".",
                                          gr_relat.nosso_numero[5,8],
                                          "-",
                                          "9"
            END IF

         WHEN gr_relat.cod_banco[1,3] = "356"
            LET l_nosso_numero_compl = gr_relat.nosso_numero[1,7]

         WHEN gr_relat.cod_banco[1,3] = "275"
            LET l_nosso_numero_compl = gr_relat.nosso_numero[1,7]

         WHEN gr_relat.cod_banco[1,3] = "237"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,2],
                                       "/",
                                       gr_relat.nosso_numero

         WHEN gr_relat.cod_banco[1,3] = "044"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,2],
                                       "/",
                                       gr_relat.nosso_numero

         WHEN gr_relat.cod_banco[1,3] = "025"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,3],
                                       "/",
                                       gr_relat.nosso_numero

         OTHERWISE
            LET l_tam = LENGTH(gr_relat.nosso_numero)
            LET l_dif = 17 - l_tam
            IF l_dif >= 0 THEN
               LET l_nosso_numero_compl = gr_relat.nosso_numero
            ELSE
               LET l_dif = l_dif * (-1)
               LET l_nosso_numero_compl = gr_relat.nosso_numero[1,l_tam-l_dif]
            END IF
      END CASE

      LET l_variavel_completa = l_nosso_numero_compl
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_nosso_numero_compl;


      PRINT ASCII 27,"*p0033x+072Y", gr_par_bloq_laser.par_bloq_txt[11,19];

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27,"*p0255x+000Y", m_codigo_cip;
      END IF

      #OS453604
      IF gr_relat.cod_banco[1,3] = '399' AND
         gr_par_bloq_laser.par_bloq_txt[139,139] = '2' THEN
         PRINT ASCII 27,"*p0343x+000YCNR";
         PRINT ASCII 27,"*p0540x+000Y09-REAL";
      ELSE
         PRINT ASCII 27,"*p0343x+000Y", gr_relat.cod_carteira;
         PRINT ASCII 27,"*p0540x+000Y", gr_relat.esp_moeda;
      END IF

      LET l_variavel_completa = gr_relat.val_docum USING "#,###,###,##&.&&"
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_variavel_completa;


      PRINT ASCII 27,"*p1000x+072Y";
      PRINT ASCII 27,"*p0030x+072Y", gr_relat.instrucoes1;

      CASE
        WHEN gr_relat.cod_banco[1,3] = "399"
          PRINT ASCII 27,"*p1800x+000Y"," ";
        OTHERWISE
          IF gr_relat.out_deducoes > 0 THEN

             LET l_variavel_completa = gr_relat.out_deducoes USING "#,###,###,##&.&&"
             CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                               2300                )
             RETURNING l_posicao_inicial

             PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_variavel_completa;

          ELSE
             PRINT ASCII 27,"*p1800x+000Y"," ";
          END IF
      END CASE

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes2;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes3;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes4;

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes5;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes6;
      PRINT ASCII 27,"*p0230x+133Y", gr_relat.nom_cliente,
                                     "  CNPJ/CPF: ",
                                     gr_relat.num_cgc_cpf;
      PRINT ASCII 27,"*p0230x+030Y", gr_relat.end_cliente,
                                     "    BAIRRO: ",
                                     gr_relat.den_bairro;
      PRINT ASCII 27,"*p0230x+030Y", gr_relat.den_cidade,
                                     "              UF: ",
                                     gr_relat.cod_uni_feder;
      PRINT ASCII 27,"*p0290x+030Y", m_sacador_avalista[1,39];
      PRINT ASCII 27,"*p1197x+000Y", " CEP: ",
                                     gr_relat.cod_cep,
                                     "                        ",
                                     gr_par_bloq_laser.par_bloq_txt[11,19];

      PRINT ASCII 27,"*p1833x+038Y", "Ficha de Compensacao"

      IF Find4GLFunction("crey52_funcao_especifico_1131") THEN

         IF crey52_get_outros_acrescimos() > 0 THEN

            LET l_variavel_completa = crey52_get_outros_acrescimos() USING "#,###,###,##&.&&"
            CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                              2300                )
            RETURNING l_posicao_inicial

            PRINT ASCII 27,"*p",l_posicao_inicial,"x-310Y", l_variavel_completa;

            LET l_variavel_completa = ( gr_relat.val_docum + crey52_get_outros_acrescimos()) USING "#,###,###,##&.&&"
            CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                              2300                )
            RETURNING l_posicao_inicial

            PRINT ASCII 27,"*p",l_posicao_inicial,"x+072Y", l_variavel_completa;

         END IF

      END IF


      #   Preenchimento FICHA DE COMPENSACAO

END REPORT

#--------------------------------------#
 REPORT geo1015_relat_boleto_a_laser_3_vias()
#--------------------------------------#

   DEFINE l_cod_cedente_caixa  CHAR(47)
   DEFINE l_funcao             CHAR(04),
          l_tam                SMALLINT,
          l_num_inicial        CHAR(20),
          l_dig                SMALLINT,
          l_dig_1              CHAR(02),
          l_num_inic_001       DECIMAL(20,0),
          l_dif                SMALLINT,
          l_for                SMALLINT,
          l_num_docum_inv      LIKE docum.num_docum,
          l_padrao             SMALLINT #TEXKEK

   DEFINE l_agencia_cedente_compl CHAR(100)
   DEFINE l_nosso_numero_compl    CHAR(20)
   DEFINE l_variavel_completa     CHAR(700)
   DEFINE l_posicao_inicial       SMALLINT

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          #PAGE  LENGTH 1

   FORMAT

   ON EVERY ROW
      # Reinicializa impressora

      PRINT ASCII 27,"E";
      #TEXKEK
      LET l_padrao = TRUE
      IF LOG_existe_epl("geo1015y_impr_boleto_folha_oficio") THEN
         #EPL executado indicar se utiliza papel oficio

         CALL LOG_setVar("padrao",l_padrao)
         #EPL Parametro indica se utiliza a rotina padrao
         #EPL tipo: smallint

         CALL geo1015y_impr_boleto_folha_oficio()

         LET l_padrao = LOG_getVar("padrao")
      END IF

      IF l_padrao = TRUE THEN
      PRINT ASCII 27,"&l26A";       # Papel A4
      ELSE
         PRINT ASCII 27,"&l3A";         # Papel Oficio
         PRINT ASCII 27,"&l11E";        # margem superior
      END IF
      #FIM

      # horizontais RECIBO DO SACADO

      PRINT ASCII 27, "*p0018x0018Y" , ASCII 27, "*c6b2319a0P";
      PRINT ASCII 27, "*p0018x+105Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      ELSE
         PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      END IF

      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c6b2319a0P";
      PRINT ASCII 27, "*p0018x+150Y" , ASCII 27, "*c6b2319a0P";

      #TESOURA e linha tracejada
      PRINT ASCII 27, "*p0000x1030Y" , ASCII 27, "(s1p10v0s0b3140T",
            ASCII 27,"(579L","#";
      PRINT ASCII 27, "*p0029x+010Y" , ASCII 27, "(s1p20h1s0b4099T",
            ASCII 27,"(12U";

      FOR l_for = 1 TO 92
          PRINT "- ";
      END FOR

      #   verticais RECIBO DO SACADO

      PRINT ASCII 27, "*p0018x0018Y", ASCII 27, "*c0830b3a0P";
      PRINT ASCII 27, "*p1555x+000Y", ASCII 27, "*c0680b3a0P";
      PRINT ASCII 27, "*p2335x+000Y", ASCII 27, "*c0830b3a0P";
      PRINT ASCII 27, "*p0336x+180Y", ASCII 27, "*c0144b3a0P";
      PRINT ASCII 27, "*p0750x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p0975x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p1161x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p0505x+072Y", ASCII 27, "*c0072b3a0P";

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27, "*p0244x+000Y", ASCII 27, "*c0072b3a0P";
      END IF

      PRINT ASCII 27, "*p0813x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p1218x+000Y", ASCII 27, "*c0072b3a0P";

      IF gr_relat.cod_banco[1,3] = "341"
      OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27, "*p0000x0072Y",ASCII 27,"(s1p12v0s3b4168T", " ";
      ELSE
         PRINT ASCII 27, "*p0530x+072Y", ASCII 27, "*c0072b3a0P";
         PRINT ASCII 27, "*p0830x+000Y", ASCII 27, "*c0072b3a0P";
      END IF

      #   sombreado RECIBO DO SACADO

      #PRINT ASCII 27, "*p1555x0018Y" , ASCII 27, "*c0105b0787a10g2P";
      #PRINT ASCII 27, "*p1555x+250Y" , ASCII 27, "*c0072b0787a10g2P";

      #      preenchimento RECIBO DO SACADO

      PRINT ASCII 27,"(12U";

      IF gr_relat.cod_banco[1,3] = "025" THEN
         PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p12v0s0b4101T",
                        "BRADESCO";
         PRINT ASCII 27,"*p0525x+000Y",ASCII 27,"(s1p16v0s3b4168T","| ",
                        "237-2", " |";
      ELSE
         LET l_tam = LENGTH(gr_relat.nom_banco)
         CASE
           WHEN l_tam <= 16
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p12v0s0b4101T",
                             gr_relat.nom_banco[1,16] CLIPPED;
           WHEN l_tam <= 17
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p11v0s0b4101T",
                             gr_relat.nom_banco[1,17] CLIPPED;
           WHEN l_tam <= 19
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p10v0s0b4101T",
                             gr_relat.nom_banco[1,19] CLIPPED;
           WHEN l_tam <= 20
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p09v0s0b4101T",
                             gr_relat.nom_banco[1,20] CLIPPED;
           WHEN l_tam <= 23
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p08v0s0b4101T",
                             gr_relat.nom_banco[1,23] CLIPPED;
           WHEN l_tam <= 27
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p07v0s0b4101T",
                             gr_relat.nom_banco[1,27] CLIPPED;
           WHEN l_tam <= 30
             PRINT ASCII 27,"*p0018x0000Y",ASCII 27,"(s1p06v0s0b4101T",
                             gr_relat.nom_banco[1,30] CLIPPED;
         END CASE

         IF gr_relat.cod_banco = '353-b' AND m_portador_char[2,4]= '033' THEN
            LET gr_relat.cod_banco = '033-7'
         END IF #717511

         PRINT ASCII 27,"*p0525x+000Y",ASCII 27,"(s1p16v0s3b4168T","| ",
                       gr_relat.cod_banco, " |";
      END IF

      PRINT ASCII 27,"*p1724x+000Y",ASCII 27,"(s1p10v0s3b4168T",
                      "Recibo do Sacado";
      PRINT ASCII 27,"*p0033x+042Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Local de Pagamento";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T","Vencimento";
      PRINT ASCII 27,"*p0033x+105Y",ASCII 27,"(s0p20h1s0b4099T","Cedente";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Agencia/Codigo Cedente";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Data do Documento";
      PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "No. do Documento";
      PRINT ASCII 27,"*p0758x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Especie Doc.";
      PRINT ASCII 27,"*p0983x+000Y",ASCII 27,"(s0p20h1s0b4099T","Aceite";
      PRINT ASCII 27,"*p1168x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Data do Processamento";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Nosso Numero";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Uso do Banco";

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27,"*p0265x+000Y",ASCII 27,"(s0p20h1s0b4099T","CIP";
      END IF

      PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s3b4099T","Carteira";
      PRINT ASCII 27,"*p0513x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Especie da Moeda";
      PRINT ASCII 27,"*p0813x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     " Quantidade";
      PRINT ASCII 27,"*p1228x+000Y",ASCII 27,"(s0p20h1s0b4099T","Valor";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (=) Valor do Documento";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" OR gr_relat.cod_banco[1,3] = "001" THEN
         PRINT ASCII 27,"*p0000x+072Y",ASCII 27,"(s0p20h1s0b4099T", " ";
      ELSE
         PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Valor do Desconto";
         PRINT ASCII 27,"*p0600x+000Y",ASCII 27,"(s0p20h1s0b4099T","Ate";
         PRINT ASCII 27,"*p0950x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Com. Permanencia por dia";
      END IF
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (-) Desconto/Abatimento";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27,"*p0033x+020Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
         PRINT ASCII 27,"*p0000x+052Y",ASCII 27,"(s0p20h1s0b4099T"," ";
      ELSE
         PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
      END IF

      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (-) Outras Deducoes";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (+) Mora/Multa";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (+) Outros Acrescimos";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (=) Valor Cobrado";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Sacado";

      IF m_imprimir_endereco_cnpj_boleto = 'S' THEN
         PRINT ASCII 27,"*p1330x+000Y",ASCII 27,"(s0p20h1s0b4099T","Cedente";
      END IF

      PRINT ASCII 27,"*p0033x+122Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Sacador/Avalista:";

      IF gr_relat.cod_banco[1,3] = "409" THEN
         PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Cod. Trans CVT:";
      ELSE
         PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Codigo de Baixa:";
      END IF

      PRINT ASCII 27,"*p0033x+035Y",ASCII 27,"(s0p15h1s0b4099T",
                     "Recebimento atraves do cheque nr.";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p14h1s0b4099T",
                     "Autenticacao Mecanica";
      PRINT ASCII 27,"*p0033x+028Y",ASCII 27,"(s0p15h1s0b4099T","do banco:";
      PRINT ASCII 27,"*p0033x+028Y",ASCII 27,"(s0p15h1s0b4099T",
                   "Esta quitacao so tera validade apos pagamento do cheque";
      PRINT ASCII 27,"*p0033x+028Y",ASCII 27,"(s0p15h1s0b4099T",
                     "pelo banco sacado";

      #   horizontais FICHA DE COMPENSAÇÃO'

      PRINT ASCII 27, "*p0018x1140Y" , ASCII 27, "*c6b2319a0P";
      PRINT ASCII 27, "*p0018x+105Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      ELSE
         PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      END IF

      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c6b2319a0P";
      PRINT ASCII 27, "*p0018x+150Y" , ASCII 27, "*c6b2319a0P";

      #:: colocado no chamado 729328
      # imprime a tesourinha depois do codigo de barras.
      PRINT ASCII 27, "*p0000x+140Y" , ASCII 27, "(s1p10v0s0b3140T", #180
            ASCII 27,"(579L","#";
      PRINT ASCII 27, "*p0029x+005Y" , ASCII 27, "(s1p20h1s0b4099T",
            ASCII 27,"(12U";
      FOR l_for = 1 TO 92
         PRINT "- ";
      END FOR
      #:: 729328

      #   verticais FICHA DE COMPENSAÇÃO

      PRINT ASCII 27, "*p0018x1140Y", ASCII 27, "*c0830b3a0P";
      PRINT ASCII 27, "*p1555x+000Y", ASCII 27, "*c0680b3a0P";
      PRINT ASCII 27, "*p2335x+000Y", ASCII 27, "*c0830b3a0P";
      PRINT ASCII 27, "*p0336x+180Y", ASCII 27, "*c0144b3a0P";
      PRINT ASCII 27, "*p0750x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p0975x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p1161x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p0505x+072Y", ASCII 27, "*c0072b3a0P";

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27, "*p0244x+000Y", ASCII 27, "*c0072b3a0P";
      END IF

      PRINT ASCII 27, "*p0813x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p1218x+000Y", ASCII 27, "*c0072b3a0P";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27, "*p0000x0072Y",ASCII 27,"(s1p12v0s3b4168T", " " ;
      ELSE
         PRINT ASCII 27, "*p0530x+072Y", ASCII 27, "*c0072b3a0P";
         PRINT ASCII 27, "*p0830x+000Y", ASCII 27, "*c0072b3a0P";
      END IF

      #   sombreado FICHA DE COMPENSAÇÃO

      #PRINT ASCII 27, "*p1555x1140Y" , ASCII 27, "*c0105b0787a10g2P";
      #PRINT ASCII 27, "*p1555x+250Y" , ASCII 27, "*c0072b0787a10g2P";

      #   preenchimento FICHA DE COMPENSAÇÃO

      PRINT ASCII 27,"(12U";

      IF gr_relat.cod_banco[1,3] = "025" THEN
         PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p12v0s0b4101T",
                        "BRADESCO";
         PRINT ASCII 27,"*p0525x+000Y",ASCII 27,"(s1p16v0s3b4168T","| ",
                        "237-2", " |";
      ELSE
         LET l_tam = LENGTH(gr_relat.nom_banco)
         CASE
           WHEN l_tam <= 16
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p12v0s0b4101T",
                             gr_relat.nom_banco[1,16] CLIPPED;
           WHEN l_tam <= 17
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p11v0s0b4101T",
                             gr_relat.nom_banco[1,17] CLIPPED;
           WHEN l_tam <= 19
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p10v0s0b4101T",
                             gr_relat.nom_banco[1,19] CLIPPED;
           WHEN l_tam <= 20
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p09v0s0b4101T",
                             gr_relat.nom_banco[1,20] CLIPPED;
           WHEN l_tam <= 23
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p08v0s0b4101T",
                             gr_relat.nom_banco[1,23] CLIPPED;
           WHEN l_tam <= 27
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p07v0s0b4101T",
                             gr_relat.nom_banco[1,27] CLIPPED;
           WHEN l_tam <= 30
             PRINT ASCII 27,"*p0018x1128Y",ASCII 27,"(s1p06v0s0b4101T",
                             gr_relat.nom_banco[1,30] CLIPPED;
         END CASE

         IF gr_relat.cod_banco = '353-b' AND m_portador_char[2,4]= '033' THEN
            LET gr_relat.cod_banco = '033-7'
         END IF #717511

         PRINT ASCII 27,"*p0525x+000Y",ASCII 27,"(s1p16v0s3b4168T","| ",
                         gr_relat.cod_banco, " | ";
      END IF

      #Texto do código de barras da Ficha de compensação - concatenado ao código do banco
      #PRINT ASCII 27,"(s0P",ASCII 27,"(s0p11h0s3b4102T",gr_relat.txt_barras;

 #    PRINT ASCII 27,"*p1724x+000Y",ASCII 27,"(s1p10v0s3b4168T",
 #                     "Ficha de Compensação";
      PRINT ASCII 27,"*p0033x+040Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Local de Pagamento";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T","Vencimento";
      PRINT ASCII 27,"*p0033x+105Y",ASCII 27,"(s0p20h1s0b4099T","Cedente";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Agencia/Codigo Cedente";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Data do Documento";
      PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "No. do Documento";
      PRINT ASCII 27,"*p0758x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Especie Doc.";
      PRINT ASCII 27,"*p0983x+000Y",ASCII 27,"(s0p20h1s0b4099T","Aceite";
      PRINT ASCII 27,"*p1168x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Data do Processamento";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Nosso Numero";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Uso do Banco";

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27,"*p0265x+000Y",ASCII 27,"(s0p20h1s0b4099T","CIP";
      END IF

      PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s3b4099T","Carteira";
      PRINT ASCII 27,"*p0513x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Especie da Moeda";
      PRINT ASCII 27,"*p0813x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     " Quantidade";
      PRINT ASCII 27,"*p1228x+000Y",ASCII 27,"(s0p20h1s0b4099T","Valor";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (=) Valor do Documento";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";

      IF gr_relat.cod_banco[1,3] = "341" OR gr_relat.cod_banco[1,3] = "422" OR gr_relat.cod_banco[1,3] = "001" THEN
         PRINT ASCII 27,"*p0000x+072Y",ASCII 27,"(s0p20h1s0b4099T", " ";
      ELSE
         PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Valor do Desconto";
         PRINT ASCII 27,"*p0600x+000Y",ASCII 27,"(s0p20h1s0b4099T","Ate";
         PRINT ASCII 27,"*p0950x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Com. Permanencia por dia";
      END IF

      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (-) Desconto/Abatimento";

      IF gr_relat.cod_banco[1,3] = "341"  OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27,"*p0033x+020Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
         PRINT ASCII 27,"*p0000x+052Y",ASCII 27,"(s0p20h1s0b4099T"," ";
      ELSE
         PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
      END IF

      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (-) Outras Deducoes";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (+) Mora/Multa";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (+) Outros Acrescimos";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (=) Valor Cobrado";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Sacado";
      PRINT ASCII 27,"*p0033x+120Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Sacador/Avalista:";

      IF gr_relat.cod_banco[1,3] = "409" THEN
         PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Cod. Trans CVT:";
      ELSE
         PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Codigo de Baixa:";
      END IF

      PRINT ASCII 27,"*p1555x+043Y",ASCII 27,"(s0p14h1s0b4099T",
                     "  Autenticacao Mecanica";

      #MARCOS
      #PRINT ASCII 27,"*p1555x+045Y",ASCII 27,"(s0p14h1s0b4099T",
      #               "Autenticacao Mecanica";

      #   horizontais FICHA DE COMPENSACAO

      PRINT ASCII 27, "*p0018x2230Y" , ASCII 27, "*c6b2319a0P";
      PRINT ASCII 27, "*p0018x+105Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";

      IF gr_relat.cod_banco[1,3] = "341"
      OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      ELSE
         PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c3b2319a0P";
      END IF

      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p1555x+072Y" , ASCII 27, "*c3b0782a0P";
      PRINT ASCII 27, "*p0018x+072Y" , ASCII 27, "*c6b2319a0P";
      PRINT ASCII 27, "*p0018x+150Y" , ASCII 27, "*c6b2319a0P";

      #   verticais FICHA DE COMPENSACAO

      PRINT ASCII 27, "*p0018x2230Y", ASCII 27, "*c0830b3a0P";
      PRINT ASCII 27, "*p1555x+000Y", ASCII 27, "*c0680b3a0P";
      PRINT ASCII 27, "*p2335x+000Y", ASCII 27, "*c0830b3a0P";
      PRINT ASCII 27, "*p0336x+180Y", ASCII 27, "*c0144b3a0P";
      PRINT ASCII 27, "*p0750x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p0975x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p1161x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p0505x+072Y", ASCII 27, "*c0072b3a0P";

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27, "*p0244x+000Y", ASCII 27, "*c0072b3a0P";
      END IF

      PRINT ASCII 27, "*p0813x+000Y", ASCII 27, "*c0072b3a0P";
      PRINT ASCII 27, "*p1218x+000Y", ASCII 27, "*c0072b3a0P";

      IF gr_relat.cod_banco[1,3] = "341"
      OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27, "*p0000x0072Y",ASCII 27,"(s1p12v0s3b4168T", " " ;
      ELSE
         PRINT ASCII 27, "*p0530x+072Y", ASCII 27, "*c0072b3a0P";
         PRINT ASCII 27, "*p0830x+000Y", ASCII 27, "*c0072b3a0P";
      END IF


      #   sombreado FICHA DE COMPENSACAO

      #PRINT ASCII 27, "*p1555x2230Y" , ASCII 27, "*c0105b0787a10g2P";
      #PRINT ASCII 27, "*p1555x+250Y" , ASCII 27, "*c0072b0787a10g2P";

      #   preenchimento FICHA DE COMPENSACAO

      PRINT ASCII 27,"(12U";

      LET l_tam = LENGTH(gr_relat.nom_banco)
      CASE
        WHEN l_tam <= 16
          PRINT ASCII 27,"*p0018x2216Y",ASCII 27,"(s1p12v0s0b4101T",
                          gr_relat.nom_banco[1,16] CLIPPED;
        WHEN l_tam <= 17
          PRINT ASCII 27,"*p0018x2220Y",ASCII 27,"(s1p11v0s0b4101T",
                          gr_relat.nom_banco[1,17] CLIPPED;
        WHEN l_tam <= 19
          PRINT ASCII 27,"*p0018x2220Y",ASCII 27,"(s1p10v0s0b4101T",
                          gr_relat.nom_banco[1,19] CLIPPED;
        WHEN l_tam <= 20
          PRINT ASCII 27,"*p0018x2220Y",ASCII 27,"(s1p09v0s0b4101T",
                          gr_relat.nom_banco[1,20] CLIPPED;
        WHEN l_tam <= 23
          PRINT ASCII 27,"*p0018x2220Y",ASCII 27,"(s1p08v0s0b4101T",
                          gr_relat.nom_banco[1,23] CLIPPED;
        WHEN l_tam <= 27
          PRINT ASCII 27,"*p0018x2220Y",ASCII 27,"(s1p07v0s0b4101T",
                          gr_relat.nom_banco[1,27] CLIPPED;
        WHEN l_tam <= 30
          PRINT ASCII 27,"*p0018x2220Y",ASCII 27,"(s1p06v0s0b4101T",
                          gr_relat.nom_banco[1,30] CLIPPED;
      END CASE

      PRINT ASCII 27,"*p0525x+000Y",ASCII 27,"(s1p16v0s3b4168T","| ",
                      gr_relat.cod_banco, " |";

      #Texto do código de barras da Ficha de compensação - concatenado ao código do banco
      PRINT ASCII 27,"(s0P",ASCII 27,"(s0p11h0s3b4102T",gr_relat.txt_barras;


      PRINT ASCII 27,"*p0033x+040Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Local de Pagamento";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T","Vencimento";
      PRINT ASCII 27,"*p0033x+105Y",ASCII 27,"(s0p20h1s0b4099T","Cedente";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Agencia/Codigo Cedente";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Data do Documento";
      PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "No. do Documento";
      PRINT ASCII 27,"*p0758x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Especie Doc.";
      PRINT ASCII 27,"*p0983x+000Y",ASCII 27,"(s0p20h1s0b4099T","Aceite";
      PRINT ASCII 27,"*p1168x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Data do Processamento";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Nosso Numero";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Uso do Banco";

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27,"*p0265x+000Y",ASCII 27,"(s0p20h1s0b4099T","CIP";
      END IF

      PRINT ASCII 27,"*p0343x+000Y",ASCII 27,"(s0p20h1s3b4099T","Carteira";
      PRINT ASCII 27,"*p0513x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Especie da Moeda";
      PRINT ASCII 27,"*p0813x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     " Quantidade";
      PRINT ASCII 27,"*p1228x+000Y",ASCII 27,"(s0p20h1s0b4099T","Valor";
      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (=) Valor do Documento";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";

      IF gr_relat.cod_banco[1,3] = "341"
      OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27,"*p0000x+072Y",ASCII 27,"(s0p20h1s0b4099T", " ";
      ELSE
         PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Valor do Desconto";
         PRINT ASCII 27,"*p0600x+000Y",ASCII 27,"(s0p20h1s0b4099T","Ate";
         PRINT ASCII 27,"*p0950x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Com. Permanencia por dia";
      END IF

      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (-) Desconto/Abatimento";

      IF gr_relat.cod_banco[1,3] = "341"
      OR gr_relat.cod_banco[1,3] = "422" THEN
         PRINT ASCII 27,"*p0033x+020Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
         PRINT ASCII 27,"*p0000x+052Y",ASCII 27,"(s0p20h1s0b4099T"," ";
      ELSE
         PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Instrucoes - Todas as informacoes deste bloqueto sao de exclusiva responsabilidade do cedente";
      END IF

      PRINT ASCII 27,"*p1555x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (-) Outras Deducoes";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (+) Mora/Multa";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (+) Outros Acrescimos";
      PRINT ASCII 27,"*p2346x+000Y",ASCII 27,"(s1p10v0s3b4168T","";
      PRINT ASCII 27,"*p1555x+072Y",ASCII 27,"(s0p20h1s0b4099T",
                     "  (=) Valor Cobrado";
      PRINT ASCII 27,"*p0033x+072Y",ASCII 27,"(s0p20h1s0b4099T","Sacado";
      PRINT ASCII 27,"*p0033x+120Y",ASCII 27,"(s0p20h1s0b4099T",
                     "Sacador/Avalista:";

      IF gr_relat.cod_banco[1,3] = "409" THEN
         PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                        "Cod. Trans CVT:";
      ELSE
        PRINT ASCII 27,"*p1833x+000Y",ASCII 27,"(s0p20h1s0b4099T",
                       "Codigo de Baixa:";
      END IF

      PRINT ASCII 27,"*p1300x+045Y",ASCII 27,"(s0p14h1s0b4099T",
                     "  Autenticacao Mecanica/";

      # Codigo de barra

      # Posicao do codigo de barra

      #PRINT ASCII 27,"*p0018x3115Y";
      PRINT ASCII 27,"*p0018x3141Y";
      PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
      PRINT ASCII 27 , "*p+3X";
      PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
      PRINT ASCII 27 , "*p+3X";

      FOR l_for = 1 TO 43 STEP 2
          # 1 bit
          IF gr_relat.cod_barras[l_for] = "1" OR
             gr_relat.cod_barras[l_for] = "3" OR
             gr_relat.cod_barras[l_for] = "5" OR
             gr_relat.cod_barras[l_for] = "8" THEN
             PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
          ELSE
             PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
          END IF
          IF gr_relat.cod_barras[l_for+1] = "1" OR
             gr_relat.cod_barras[l_for+1] = "3" OR
             gr_relat.cod_barras[l_for+1] = "5" OR
             gr_relat.cod_barras[l_for+1] = "8" THEN
             PRINT ASCII 27 , "*p+9X";
          ELSE
             PRINT ASCII 27 , "*p+3X";
          END IF
          #  2 bit
          IF gr_relat.cod_barras[l_for] = "2" OR
             gr_relat.cod_barras[l_for] = "3" OR
             gr_relat.cod_barras[l_for] = "6" OR
             gr_relat.cod_barras[l_for] = "9" THEN
             PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
          ELSE
             PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
          END IF
          IF gr_relat.cod_barras[l_for+1] = "2" OR
             gr_relat.cod_barras[l_for+1] = "3" OR
             gr_relat.cod_barras[l_for+1] = "6" OR
             gr_relat.cod_barras[l_for+1] = "9" THEN
             PRINT ASCII 27 , "*p+9X";
          ELSE
             PRINT ASCII 27 , "*p+3X";
          END IF
          # 3 bit
          IF gr_relat.cod_barras[l_for] = "0" OR
             gr_relat.cod_barras[l_for] = "4" OR
             gr_relat.cod_barras[l_for] = "5" OR
             gr_relat.cod_barras[l_for] = "6" THEN
             PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
          ELSE
             PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
          END IF
          IF gr_relat.cod_barras[l_for+1] = "0" OR
             gr_relat.cod_barras[l_for+1] = "4" OR
             gr_relat.cod_barras[l_for+1] = "5" OR
             gr_relat.cod_barras[l_for+1] = "6" THEN
             PRINT ASCII 27 , "*p+9X";
          ELSE
             PRINT ASCII 27 , "*p+3X";
          END IF
          # 4 bit
          IF gr_relat.cod_barras[l_for] = "0" OR
             gr_relat.cod_barras[l_for] = "7" OR
             gr_relat.cod_barras[l_for] = "8" OR
             gr_relat.cod_barras[l_for] = "9" THEN
             PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
          ELSE
             PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
          END IF
          IF gr_relat.cod_barras[l_for+1] = "0" OR
             gr_relat.cod_barras[l_for+1] = "7" OR
             gr_relat.cod_barras[l_for+1] = "8" OR
             gr_relat.cod_barras[l_for+1] = "9" THEN
             PRINT ASCII 27 , "*p+9X";
          ELSE
             PRINT ASCII 27 , "*p+3X";
          END IF
          # 5 bit
          IF gr_relat.cod_barras[l_for] = "1" OR
             gr_relat.cod_barras[l_for] = "2" OR
             gr_relat.cod_barras[l_for] = "4" OR
             gr_relat.cod_barras[l_for] = "7" THEN
             PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
          ELSE
             PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";
          END IF
          IF gr_relat.cod_barras[l_for+1] = "1" OR
             gr_relat.cod_barras[l_for+1] = "2" OR
             gr_relat.cod_barras[l_for+1] = "4" OR
             gr_relat.cod_barras[l_for+1] = "7" THEN
             PRINT ASCII 27 , "*p+9X";
          ELSE
             PRINT ASCII 27 , "*p+3X";
          END IF
      END FOR

      PRINT ASCII 27 , "*c160b09A", ASCII 27, "*c0P",ASCII 27, "*p+9X";
      PRINT ASCII 27 , "*p+3X";
      PRINT ASCII 27 , "*c160b03A", ASCII 27, "*c0P",ASCII 27, "*p+3X";

      #   Preenchimento RECIBO DO SACADO

      PRINT ASCII 27,"(12U",ASCII 27,"(s0p13h0s3b4099T";
      PRINT ASCII 27,"*p0030x0082Y", gr_relat.loc_pgto_1;

      LET l_variavel_completa = gr_relat.dat_vencto
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", gr_relat.dat_vencto   USING "dd/mm/yyyy";

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.loc_pgto_2;

      IF m_cedente IS NULL THEN
         PRINT ASCII 27,"*p0030x+070Y", gr_relat.den_empresa;
      ELSE
         PRINT ASCII 27,"*p0030x+070Y", m_cedente[1,60];
      END IF

      CASE
         WHEN gr_relat.cod_banco[1,3] = "001"
            LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia CLIPPED,"-",
                                          gr_par_bloq_laser.dig_agencia CLIPPED,
                                          '/',
                                          gr_relat.cod_cedente

        {WHEN gr_relat.cod_banco[1,3] = '104'
            LET l_cod_cedente_caixa = gr_relat.cod_cedente,'00000000000000000000000000000000'
            LET m_dv_verificador    = cap446_calcula_dv_geral('DVB',l_cod_cedente_caixa)

            LET l_agencia_cedente_compl = gr_relat.cod_cedente[1,4],'.',
                                          gr_relat.cod_cedente[5,7],'.',
                                          gr_relat.cod_cedente[8,15],'-',
                                          m_dv_verificador                                  }

         WHEN gr_relat.cod_banco[1,3] = "275"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                          "/",
                                          gr_relat.cod_cedente CLIPPED,
                                          "/",
                                          gr_relat.nosso_numero[9,9]

         WHEN gr_relat.cod_banco[1,3] = "341"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                          "/",
                                          gr_relat.cod_cedente CLIPPED

         WHEN gr_relat.cod_banco[1,3] = "356"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                          "/",
                                          gr_relat.cod_cedente CLIPPED,
                                          "/",
                                          gr_relat.nosso_numero[9,9]

         WHEN gr_relat.cod_banco[1,3] = "399"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                          "/",
                                          gr_relat.cod_cedente

         WHEN gr_relat.cod_banco[1,3] = "409" AND gr_par_bloq_laser.par_bloq_txt[139,139] = "2"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia,
                                          gr_par_bloq_laser.par_bloq_txt[151] CLIPPED,
                                          "/",
                                          gr_par_bloq_laser.num_conta USING "<<<<<<<<<<<<","-",
                                          gr_par_bloq_laser.dig_conta USING "&"

         WHEN gr_relat.cod_banco[1,3] = "422"
            LET l_agencia_cedente_compl = gr_relat.cod_agencia CLIPPED,
                                          ".",
                                          gr_relat.cod_cedente

         WHEN gr_relat.cod_banco[1,3] = "027"
            IF gr_par_bloq_laser.par_bloq_txt[139,139] = "2" THEN
               LET l_agencia_cedente_compl = gr_relat.nosso_numero[1,15],
                                             '-',
                                             gr_relat.nosso_numero[16]

            ELSE
               LET l_agencia_cedente_compl = gr_relat.cod_agencia[2,4]  USING "&&&",
                                             "-",
                                             gr_relat.cod_carteira[1,2] USING "&&",
                                             "-",
                                             gr_relat.nosso_numero[1,4],
                                             ".",
                                             gr_relat.nosso_numero[5,8],
                                             "-9"
            END IF

         WHEN gr_relat.cod_banco[1,3] = "389"
            LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia USING "&&&&",
                                          "/",
                                          gr_relat.cod_cedente[1,8],
                                          "-",
                                          gr_relat.cod_cedente[9,9]

         OTHERWISE
            LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia CLIPPED,"-",
                                          gr_par_bloq_laser.dig_agencia CLIPPED,
                                          "/",
                                          gr_relat.cod_cedente

      END CASE

      LET l_variavel_completa = l_agencia_cedente_compl
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_agencia_cedente_compl;

      PRINT ASCII 27,"*p0060x+072Y", gr_relat.dat_emissao  USING "dd/mm/yyyy";

      IF Find4GLFunction("crey49_verifica_inversao") THEN
         CALL crey49_verifica_inversao(m_portador_original)
         RETURNING m_status

         IF m_status = TRUE THEN
            CALL crey49_inverte_documento(gr_relat.num_docum)
            RETURNING l_num_docum_inv

            PRINT ASCII 27,"*p0400x+000Y", l_num_docum_inv;
         ELSE
            PRINT ASCII 27,"*p0400x+000Y", gr_relat.num_docum;
         END IF
      ELSE
         PRINT ASCII 27,"*p0400x+000Y", gr_relat.num_docum;
      END IF

      #OS453604
      IF NOT (gr_relat.cod_banco[1,3] = "399" AND
         gr_par_bloq_laser.par_bloq_txt[139,139] = "2") THEN
         PRINT ASCII 27,"*p0761x+000Y", gr_relat.esp_docum;
         PRINT ASCII 27,"*p0990x+000Y", gr_relat.cod_aceite;
         PRINT ASCII 27,"*p1250x+000Y", TODAY USING "dd/mm/yyyy";
      END IF

      CASE
         WHEN gr_relat.cod_banco[1,3] = "275"
            LET l_nosso_numero_compl = gr_relat.nosso_numero[1,7]

         WHEN gr_relat.cod_banco[1,3] = "356"
            LET l_nosso_numero_compl = gr_relat.nosso_numero[1,7]

         WHEN gr_relat.cod_banco[1,3] = "237"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,2],
                                       "/",
                                       gr_relat.nosso_numero

         WHEN gr_relat.cod_banco[1,3] = "044"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,2],
                                       "/",
                                       gr_relat.nosso_numero

         WHEN gr_relat.cod_banco[1,3] = "025"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,3],
                                       "/",
                                       gr_relat.nosso_numero

         OTHERWISE
            LET l_tam = LENGTH(gr_relat.nosso_numero)
            LET l_dif = 17 - l_tam

            IF l_dif >= 0 THEN
               LET l_nosso_numero_compl = gr_relat.nosso_numero
            ELSE
               LET l_dif = l_dif * (-1)
               LET l_nosso_numero_compl = gr_relat.nosso_numero[1,l_tam-l_dif]
            END IF

      END CASE

      LET l_variavel_completa = l_nosso_numero_compl
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_nosso_numero_compl;

      PRINT ASCII 27,"*p0033x+072Y", gr_par_bloq_laser.par_bloq_txt[11,19];

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27,"*p0255x+000Y", m_codigo_cip;
      END IF

      #OS453604
      IF gr_relat.cod_banco[1,3] = '399' AND
         gr_par_bloq_laser.par_bloq_txt[139,139] = '2' THEN
         PRINT ASCII 27,"*p0343x+000YCNR";
         PRINT ASCII 27,"*p0540x+000Y09-REAL";
      ELSE
         PRINT ASCII 27,"*p0343x+000Y", gr_relat.cod_carteira;
         PRINT ASCII 27,"*p0540x+000Y", gr_relat.esp_moeda;
      END IF

      LET l_variavel_completa = gr_relat.val_docum USING "#,###,###,##&.&&"
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_variavel_completa;

      PRINT ASCII 27,"*p1000x+072Y";
      PRINT ASCII 27,"*p0030x+072Y", gr_relat.instrucoes1;

      IF gr_relat.out_deducoes > 0 THEN

         LET l_variavel_completa = gr_relat.out_deducoes USING "#,###,###,##&.&&"
         CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                           2300                )
         RETURNING l_posicao_inicial

         PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_variavel_completa;

      ELSE
         PRINT ASCII 27,"*p1800x+000Y"," ";
      END IF

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes2;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes3;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes4;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes5;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes6;

      IF m_imprimir_endereco_cnpj_boleto = 'S' THEN
         PRINT ASCII 27,"(12U",ASCII 27,"(s0p18h0s3b4099T"; # Diminuir tamanho tamanho da fonte

         PRINT ASCII 27,"*p0140x+113Y", gr_relat.nom_cliente,
                                        "  CNPJ/CPF: ",
                                        gr_relat.num_cgc_cpf;

         PRINT ASCII 27,"*p1400x+000Y", "    RUA: ",
                                        mr_empresa.end_empresa;

         PRINT ASCII 27,"*p0140x+030Y", gr_relat.end_cliente,
                                        "    BAIRRO: ",
                                        gr_relat.den_bairro;

         PRINT ASCII 27,"*p1400x+000Y", " BAIRRO: ",
                                        mr_empresa.den_bairro,
                                        "   CEP: ",
                                        mr_empresa.cod_cep;


         PRINT ASCII 27,"*p0140x+030Y", gr_relat.den_cidade,
                                        "              UF: ",
                                        gr_relat.cod_uni_feder,
                                        "   CEP: ",
                                        gr_relat.cod_cep;

         PRINT ASCII 27,"*p1400x+000Y", " CIDADE: ",
                                        mr_empresa.den_munic,
                                        "  UF: ",
                                        mr_empresa.uni_feder;

         PRINT ASCII 27,"*p0950x+028Y", gr_par_bloq_laser.par_bloq_txt[11,19] CLIPPED,
                                        gr_par_bloq_laser.par_bloq_txt[152,152];

         PRINT ASCII 27,"*p1400x+000Y", "   CNPJ: ",
                                        mr_empresa.num_cgc;

         PRINT ASCII 27,"*p0290x+021Y", m_sacador_avalista[1,35];


         PRINT ASCII 27,"(12U",ASCII 27,"(s0p12h0s3b4099T"; # Aumentar novamente o tamanho da fonte

      ELSE
         #TFADU2#
         IF LOG_existe_epl("geo1015y_get_nome_cliente") THEN

            PRINT ASCII 27,"*p0140x+113Y", LOG_getVar("nom_cliente"),
                                           "  - ",
                                           gr_relat.num_cgc_cpf;
         ELSE
            PRINT ASCII 27,"*p0230x+133Y", gr_relat.nom_cliente,
                                           "  CNPJ/CPF: ",
                                           gr_relat.num_cgc_cpf;
         END IF
         #TFADU2#
         IF LOG_existe_epl("geo1015y_get_end_cliente") THEN
            PRINT ASCII 27,"*p0140x+030Y", LOG_getVar("end_cliente"),
                                        " - ",
                                        gr_relat.den_cidade,
                                        " - ",
                                        gr_relat.cod_uni_feder,
                                        " - ",
                                        gr_relat.den_bairro,
                                        " - ",
                                        gr_relat.cod_cep,
                                        "                        ",
                                        gr_par_bloq_laser.par_bloq_txt[11,19];
         ELSE
            PRINT ASCII 27,"*p0230x+030Y", gr_relat.end_cliente,
                                           "    BAIRRO: ",
                                           gr_relat.den_bairro;
            PRINT ASCII 27,"*p0230x+030Y", gr_relat.den_cidade,
                                           "              UF: ",
                                           gr_relat.cod_uni_feder;
            PRINT ASCII 27,"*p0290x+030Y", m_sacador_avalista[1,39];
            PRINT ASCII 27,"*p1197x+000Y", " CEP: ",
                                           gr_relat.cod_cep,
                                           "                        ",
                                           gr_par_bloq_laser.par_bloq_txt[11,19];
         END IF
      END IF

      IF Find4GLFunction("crey52_funcao_especifico_1131") THEN

         IF crey52_get_outros_acrescimos() > 0 THEN

            LET l_variavel_completa = crey52_get_outros_acrescimos() USING "#,###,###,##&.&&"
            CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                              2300                )
            RETURNING l_posicao_inicial

            PRINT ASCII 27,"*p",l_posicao_inicial,"x-228Y", l_variavel_completa;

            LET l_variavel_completa = (gr_relat.val_docum + crey52_get_outros_acrescimos()) USING "#,###,###,##&.&&"
            CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                              2300                )
            RETURNING l_posicao_inicial

            PRINT ASCII 27,"*p",l_posicao_inicial,"x+072Y", l_variavel_completa;

         END IF

      END IF


      #   Preenchimento FICHA DO CAIXA

      PRINT ASCII 27,"(12U",ASCII 27,"(s0p13h0s3b4099T";
      PRINT ASCII 27,"*p0030x1215Y", gr_relat.loc_pgto_1;

      LET l_variavel_completa = gr_relat.dat_vencto
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", gr_relat.dat_vencto USING "dd/mm/yyyy";

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.loc_pgto_2;

      IF m_cedente IS NULL THEN
         PRINT ASCII 27,"*p0030x+060Y", gr_relat.den_empresa;
      ELSE
         PRINT ASCII 27,"*p0030x+060Y", m_cedente[1,60];
      END IF

      CASE
        WHEN gr_relat.cod_banco[1,3] = "001"
           LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia CLIPPED,"-",
                                         gr_par_bloq_laser.dig_agencia CLIPPED,
                                         '/',
                                         gr_relat.cod_cedente


        # Caixa Econômica Federal (Código Febraban 104) # 725652
        {WHEN gr_relat.cod_banco[1,3] = '104'
           LET l_cod_cedente_caixa = gr_relat.cod_cedente,'00000000000000000000000000000000'
           LET m_dv_verificador    = cap446_calcula_dv_geral('DVB',l_cod_cedente_caixa)

           LET l_agencia_cedente_compl = gr_relat.cod_cedente[1,4],'.',
                                         gr_relat.cod_cedente[5,7],'.',
                                         gr_relat.cod_cedente[8,15],'-',
                                         m_dv_verificador                                  }



        WHEN gr_relat.cod_banco[1,3] = "341"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente CLIPPED


        WHEN gr_relat.cod_banco[1,3] = "275"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente CLIPPED,
                                         "/",
                                         gr_relat.nosso_numero[9,9]

        WHEN gr_relat.cod_banco[1,3] = "356"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente CLIPPED,
                                         "/",
                                         gr_relat.nosso_numero[9,9]

        WHEN gr_relat.cod_banco[1,3] = "399"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente


        WHEN gr_relat.cod_banco[1,3] = "409" AND gr_par_bloq_laser.par_bloq_txt[139,139] = "2"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia,
                                         gr_par_bloq_laser.par_bloq_txt[151] CLIPPED,
                                         "/",
                                         gr_par_bloq_laser.num_conta USING "<<<<<<<<<<<<","-",
                                         gr_par_bloq_laser.dig_conta USING "&"


        WHEN gr_relat.cod_banco[1,3] = "422"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia CLIPPED,
                                         ".",
                                         gr_relat.cod_cedente

        WHEN gr_relat.cod_banco[1,3] = "389"
           LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia USING "&&&&",
                                         "/",
                                         gr_relat.cod_cedente[1,8],
                                         "-",
                                         gr_relat.cod_cedente[9,9]

        OTHERWISE
           LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia CLIPPED,"-",
                                         gr_par_bloq_laser.dig_agencia CLIPPED,
                                         "/",
                                         gr_relat.cod_cedente

      END CASE

      LET l_variavel_completa = l_agencia_cedente_compl
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_agencia_cedente_compl;


      PRINT ASCII 27,"*p0060x+072Y", gr_relat.dat_emissao USING "dd/mm/yyyy";

      IF Find4GLFunction("crey49_verifica_inversao") THEN
         CALL crey49_verifica_inversao(m_portador_original)
         RETURNING m_status

         IF m_status = TRUE THEN
            CALL crey49_inverte_documento(gr_relat.num_docum)
            RETURNING l_num_docum_inv

            PRINT ASCII 27,"*p0400x+000Y", l_num_docum_inv;
         ELSE
            PRINT ASCII 27,"*p0400x+000Y", gr_relat.num_docum;
         END IF
      ELSE
         PRINT ASCII 27,"*p0400x+000Y", gr_relat.num_docum;
      END IF

      #OS453604
      IF NOT (gr_relat.cod_banco[1,3] = "399" AND
         gr_par_bloq_laser.par_bloq_txt[139,139] = "2") THEN
         PRINT ASCII 27,"*p0761x+000Y", gr_relat.esp_docum;
         PRINT ASCII 27,"*p0990x+000Y", gr_relat.cod_aceite;
         PRINT ASCII 27,"*p1250x+000Y", TODAY USING "dd/mm/yyyy";
      END IF

      CASE
         WHEN gr_relat.cod_banco[1,3] = "027"
            IF gr_par_bloq_laser.par_bloq_txt[139,139] = "2" THEN
               LET l_nosso_numero_compl = gr_relat.nosso_numero[1,15],
                                          '-',
                                          gr_relat.nosso_numero[16]
            ELSE
               LET l_nosso_numero_compl = gr_relat.cod_agencia[2,4]  USING "&&&",
                                          "-",
                                          gr_relat.cod_carteira[1,2] USING "&&",
                                          "-",
                                          gr_relat.nosso_numero[1,4],
                                          ".",
                                          gr_relat.nosso_numero[5,8],
                                          "-",
                                          "9"
            END IF

         WHEN gr_relat.cod_banco[1,3] = "356"
            LET l_nosso_numero_compl = gr_relat.nosso_numero[1,7]

         WHEN gr_relat.cod_banco[1,3] = "275"
            LET l_nosso_numero_compl = gr_relat.nosso_numero[1,7]

         WHEN gr_relat.cod_banco[1,3] = "237"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,2],
                                       "/",
                                       gr_relat.nosso_numero

         WHEN gr_relat.cod_banco[1,3] = "044"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,2],
                                       "/",
                                       gr_relat.nosso_numero

         WHEN gr_relat.cod_banco[1,3] = "025"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,3],
                                       "/",
                                       gr_relat.nosso_numero

         OTHERWISE
            LET l_tam = LENGTH(gr_relat.nosso_numero)
            LET l_dif = 17 - l_tam
            IF l_dif >= 0 THEN
               LET l_nosso_numero_compl = gr_relat.nosso_numero
            ELSE
               LET l_dif = l_dif * (-1)
               LET l_nosso_numero_compl = gr_relat.nosso_numero[1,l_tam-l_dif]
            END IF
      END CASE

      LET l_variavel_completa = l_nosso_numero_compl
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_nosso_numero_compl;


      PRINT ASCII 27,"*p0033x+072Y", gr_par_bloq_laser.par_bloq_txt[11,19];

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27,"*p0255x+000Y", m_codigo_cip;
      END IF

      #OS453604
      IF gr_relat.cod_banco[1,3] = '399' AND
         gr_par_bloq_laser.par_bloq_txt[139,139] = '2' THEN
         PRINT ASCII 27,"*p0343x+000YCNR";
         PRINT ASCII 27,"*p0540x+000Y09-REAL";
      ELSE
         PRINT ASCII 27,"*p0343x+000Y", gr_relat.cod_carteira;
         PRINT ASCII 27,"*p0540x+000Y", gr_relat.esp_moeda;
      END IF

      LET l_variavel_completa = gr_relat.val_docum USING "#,###,###,##&.&&"
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_variavel_completa;


      PRINT ASCII 27,"*p1000x+072Y";
      PRINT ASCII 27,"*p0030x+072Y", gr_relat.instrucoes1;

      CASE
        WHEN gr_relat.cod_banco[1,3] = "399"
          PRINT ASCII 27,"*p1800x+000Y"," ";
        OTHERWISE
          IF gr_relat.out_deducoes > 0 THEN

             LET l_variavel_completa = gr_relat.out_deducoes USING "#,###,###,##&.&&"
             CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                               2300                )
             RETURNING l_posicao_inicial

             PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_variavel_completa;

          ELSE
             PRINT ASCII 27,"*p1800x+000Y"," ";
          END IF
      END CASE

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes2;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes3;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes4;

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes5;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes6;
      PRINT ASCII 27,"*p0230x+133Y", gr_relat.nom_cliente,
                                     "  CNPJ/CPF: ",
                                     gr_relat.num_cgc_cpf;
      PRINT ASCII 27,"*p0230x+030Y", gr_relat.end_cliente,
                                     "    BAIRRO: ",
                                     gr_relat.den_bairro;
      PRINT ASCII 27,"*p0230x+030Y", gr_relat.den_cidade,
                                     "              UF: ",
                                     gr_relat.cod_uni_feder;
      PRINT ASCII 27,"*p0290x+030Y", m_sacador_avalista[1,39];
      PRINT ASCII 27,"*p1197x+000Y", " CEP: ",
                                     gr_relat.cod_cep,
                                     "                        ",
                                     gr_par_bloq_laser.par_bloq_txt[11,19];

      #PRINT ASCII 27,"*p1833x+038Y", "Ficha de Compensacao"

      IF Find4GLFunction("crey52_funcao_especifico_1131") THEN

         IF crey52_get_outros_acrescimos() > 0 THEN

            LET l_variavel_completa = crey52_get_outros_acrescimos() USING "#,###,###,##&.&&"
            CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                              2300                )
            RETURNING l_posicao_inicial

            PRINT ASCII 27,"*p",l_posicao_inicial,"x-310Y", l_variavel_completa;

            LET l_variavel_completa = ( gr_relat.val_docum + crey52_get_outros_acrescimos()) USING "#,###,###,##&.&&"
            CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                              2300                )
            RETURNING l_posicao_inicial

            PRINT ASCII 27,"*p",l_posicao_inicial,"x+072Y", l_variavel_completa;

         END IF

      END IF


      #   Preenchimento FICHA DO COMPENSAÇÃO

      PRINT ASCII 27,"(12U",ASCII 27,"(s0p13h0s3b4099T";
      PRINT ASCII 27,"*p0030x2305Y", gr_relat.loc_pgto_1;

      LET l_variavel_completa = gr_relat.dat_vencto
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", gr_relat.dat_vencto USING "dd/mm/yyyy";

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.loc_pgto_2;

      IF m_cedente IS NULL THEN
         PRINT ASCII 27,"*p0030x+060Y", gr_relat.den_empresa;
      ELSE
         PRINT ASCII 27,"*p0030x+060Y", m_cedente[1,60];
      END IF

      CASE
        WHEN gr_relat.cod_banco[1,3] = "001"
           LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia CLIPPED,"-",
                                         gr_par_bloq_laser.dig_agencia CLIPPED,
                                         '/',
                                         gr_relat.cod_cedente


        # Caixa Econômica Federal (Código Febraban 104) # 725652
        {WHEN gr_relat.cod_banco[1,3] = '104'
           LET l_cod_cedente_caixa = gr_relat.cod_cedente,'00000000000000000000000000000000'
           LET m_dv_verificador    = cap446_calcula_dv_geral('DVB',l_cod_cedente_caixa)

           LET l_agencia_cedente_compl = gr_relat.cod_cedente[1,4],'.',
                                         gr_relat.cod_cedente[5,7],'.',
                                         gr_relat.cod_cedente[8,15],'-',
                                         m_dv_verificador                                  }



        WHEN gr_relat.cod_banco[1,3] = "341"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente CLIPPED


        WHEN gr_relat.cod_banco[1,3] = "275"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente CLIPPED,
                                         "/",
                                         gr_relat.nosso_numero[9,9]

        WHEN gr_relat.cod_banco[1,3] = "356"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente CLIPPED,
                                         "/",
                                         gr_relat.nosso_numero[9,9]

        WHEN gr_relat.cod_banco[1,3] = "399"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia[1,4],
                                         "/",
                                         gr_relat.cod_cedente


        WHEN gr_relat.cod_banco[1,3] = "409" AND gr_par_bloq_laser.par_bloq_txt[139,139] = "2"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia,
                                         gr_par_bloq_laser.par_bloq_txt[151] CLIPPED,
                                         "/",
                                         gr_par_bloq_laser.num_conta USING "<<<<<<<<<<<<","-",
                                         gr_par_bloq_laser.dig_conta USING "&"


        WHEN gr_relat.cod_banco[1,3] = "422"
           LET l_agencia_cedente_compl = gr_relat.cod_agencia CLIPPED,
                                         ".",
                                         gr_relat.cod_cedente

        WHEN gr_relat.cod_banco[1,3] = "389"
           LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia USING "&&&&",
                                         "/",
                                         gr_relat.cod_cedente[1,8],
                                         "-",
                                         gr_relat.cod_cedente[9,9]

        OTHERWISE
           LET l_agencia_cedente_compl = gr_par_bloq_laser.num_agencia CLIPPED,"-",
                                         gr_par_bloq_laser.dig_agencia CLIPPED,
                                         "/",
                                         gr_relat.cod_cedente

      END CASE

      LET l_variavel_completa = l_agencia_cedente_compl
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_agencia_cedente_compl;


      PRINT ASCII 27,"*p0060x+072Y", gr_relat.dat_emissao USING "dd/mm/yyyy";

      IF Find4GLFunction("crey49_verifica_inversao") THEN
         CALL crey49_verifica_inversao(m_portador_original)
         RETURNING m_status

         IF m_status = TRUE THEN
            CALL crey49_inverte_documento(gr_relat.num_docum)
            RETURNING l_num_docum_inv

            PRINT ASCII 27,"*p0400x+000Y", l_num_docum_inv;
         ELSE
            PRINT ASCII 27,"*p0400x+000Y", gr_relat.num_docum;
         END IF
      ELSE
         PRINT ASCII 27,"*p0400x+000Y", gr_relat.num_docum;
      END IF

      #OS453604
      IF NOT (gr_relat.cod_banco[1,3] = "399" AND
         gr_par_bloq_laser.par_bloq_txt[139,139] = "2") THEN
         PRINT ASCII 27,"*p0761x+000Y", gr_relat.esp_docum;
         PRINT ASCII 27,"*p0990x+000Y", gr_relat.cod_aceite;
         PRINT ASCII 27,"*p1250x+000Y", TODAY USING "dd/mm/yyyy";
      END IF

      CASE
         WHEN gr_relat.cod_banco[1,3] = "027"
            IF gr_par_bloq_laser.par_bloq_txt[139,139] = "2" THEN
               LET l_nosso_numero_compl = gr_relat.nosso_numero[1,15],
                                          '-',
                                          gr_relat.nosso_numero[16]
            ELSE
               LET l_nosso_numero_compl = gr_relat.cod_agencia[2,4]  USING "&&&",
                                          "-",
                                          gr_relat.cod_carteira[1,2] USING "&&",
                                          "-",
                                          gr_relat.nosso_numero[1,4],
                                          ".",
                                          gr_relat.nosso_numero[5,8],
                                          "-",
                                          "9"
            END IF

         WHEN gr_relat.cod_banco[1,3] = "356"
            LET l_nosso_numero_compl = gr_relat.nosso_numero[1,7]

         WHEN gr_relat.cod_banco[1,3] = "275"
            LET l_nosso_numero_compl = gr_relat.nosso_numero[1,7]

         WHEN gr_relat.cod_banco[1,3] = "237"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,2],
                                       "/",
                                       gr_relat.nosso_numero

         WHEN gr_relat.cod_banco[1,3] = "044"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,2],
                                       "/",
                                       gr_relat.nosso_numero

         WHEN gr_relat.cod_banco[1,3] = "025"
            LET l_nosso_numero_compl = gr_relat.cod_carteira[1,3],
                                       "/",
                                       gr_relat.nosso_numero

         OTHERWISE
            LET l_tam = LENGTH(gr_relat.nosso_numero)
            LET l_dif = 17 - l_tam
            IF l_dif >= 0 THEN
               LET l_nosso_numero_compl = gr_relat.nosso_numero
            ELSE
               LET l_dif = l_dif * (-1)
               LET l_nosso_numero_compl = gr_relat.nosso_numero[1,l_tam-l_dif]
            END IF
      END CASE

      LET l_variavel_completa = l_nosso_numero_compl
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_nosso_numero_compl;


      PRINT ASCII 27,"*p0033x+072Y", gr_par_bloq_laser.par_bloq_txt[11,19];

      IF  m_codigo_cip IS NOT NULL
      AND m_codigo_cip <> " " THEN
         PRINT ASCII 27,"*p0255x+000Y", m_codigo_cip;
      END IF

      #OS453604
      IF gr_relat.cod_banco[1,3] = '399' AND
         gr_par_bloq_laser.par_bloq_txt[139,139] = '2' THEN
         PRINT ASCII 27,"*p0343x+000YCNR";
         PRINT ASCII 27,"*p0540x+000Y09-REAL";
      ELSE
         PRINT ASCII 27,"*p0343x+000Y", gr_relat.cod_carteira;
         PRINT ASCII 27,"*p0540x+000Y", gr_relat.esp_moeda;
      END IF

      LET l_variavel_completa = gr_relat.val_docum USING "#,###,###,##&.&&"
      CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                        2300                )
      RETURNING l_posicao_inicial

      PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_variavel_completa;


      PRINT ASCII 27,"*p1000x+072Y";
      PRINT ASCII 27,"*p0030x+072Y", gr_relat.instrucoes1;

      CASE
        WHEN gr_relat.cod_banco[1,3] = "399"
          PRINT ASCII 27,"*p1800x+000Y"," ";
        OTHERWISE
          IF gr_relat.out_deducoes > 0 THEN

             LET l_variavel_completa = gr_relat.out_deducoes USING "#,###,###,##&.&&"
             CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                               2300                )
             RETURNING l_posicao_inicial

             PRINT ASCII 27,"*p",l_posicao_inicial,"x+000Y", l_variavel_completa;

          ELSE
             PRINT ASCII 27,"*p1800x+000Y"," ";
          END IF
      END CASE

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes2;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes3;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes4;

      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes5;
      PRINT ASCII 27,"*p0030x+030Y", gr_relat.instrucoes6;
      PRINT ASCII 27,"*p0230x+133Y", gr_relat.nom_cliente,
                                     "  CNPJ/CPF: ",
                                     gr_relat.num_cgc_cpf;
      PRINT ASCII 27,"*p0230x+030Y", gr_relat.end_cliente,
                                     "    BAIRRO: ",
                                     gr_relat.den_bairro;
      PRINT ASCII 27,"*p0230x+030Y", gr_relat.den_cidade,
                                     "              UF: ",
                                     gr_relat.cod_uni_feder;
      PRINT ASCII 27,"*p0290x+030Y", m_sacador_avalista[1,39];
      PRINT ASCII 27,"*p1197x+000Y", " CEP: ",
                                     gr_relat.cod_cep,
                                     "                        ",
                                     gr_par_bloq_laser.par_bloq_txt[11,19];

      PRINT ASCII 27,"*p1833x+038Y", "Ficha de Compensacao"

      IF Find4GLFunction("crey52_funcao_especifico_1131") THEN

         IF crey52_get_outros_acrescimos() > 0 THEN

            LET l_variavel_completa = crey52_get_outros_acrescimos() USING "#,###,###,##&.&&"
            CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                              2300                )
            RETURNING l_posicao_inicial

            PRINT ASCII 27,"*p",l_posicao_inicial,"x-310Y", l_variavel_completa;

            LET l_variavel_completa = ( gr_relat.val_docum + crey52_get_outros_acrescimos()) USING "#,###,###,##&.&&"
            CALL geo1015_ajusta_alinhamento( l_variavel_completa ,
                                              2300                )
            RETURNING l_posicao_inicial

            PRINT ASCII 27,"*p",l_posicao_inicial,"x+072Y", l_variavel_completa;

         END IF

      END IF


      #   Preenchimento FICHA DE COMPENSACAO

END REPORT

#---------------------------------------#
 FUNCTION geo1015_cria_w_nota_fiscal()
#---------------------------------------#

 WHENEVER ERROR CONTINUE
 DROP TABLE w_nota_fiscal;
 IF sqlca.sqlcode <> 0 THEN
 END IF

 DELETE FROM w_nota_fiscal;
 IF sqlca.sqlcode <> 0 THEN
 END IF

 CREATE TEMP TABLE w_nota_fiscal
 ( empresa      CHAR(02),
   tipo         CHAR(08),
   nota_fiscal  DECIMAL(10),
   serie        CHAR(03),
   subserie     DECIMAL(5)
 ) WITH NO LOG;

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("CRIACAO","TABELA-TEMPORARIA")
 END IF
 WHENEVER ERROR STOP

END FUNCTION


#----------------------------------------#
 FUNCTION geo1015_gerencia_nota_fiscal()
#----------------------------------------#
 DEFINE l_curr,
        l_ind,
        l_scr_line,
        l_count     SMALLINT

 DEFINE l_tela      CHAR(100)

 LET int_flag = FALSE

 #CALL log130_procura_caminho('cre1100a')
 #     RETURNING l_tela

 #OPEN WINDOW w_cre1100a AT 2,2 WITH FORM l_tela
 #     ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  CALL geo1015_carrega_array()
 # CALL set_count(m_cont)

 # CALL log006_exibe_teclas("01 02 07",p_versao)
 # CURRENT WINDOW IS w_cre1100a

 { INPUT ARRAY ma_doc_orig_unico WITHOUT DEFAULTS FROM s_doc_orig.*
     BEFORE ROW
        LET l_curr     = arr_curr()
        LET m_cont     = arr_count()
        LET l_scr_line = scr_line()

     BEFORE FIELD tip_nota_fiscal
        IF ma_doc_orig_unico[l_curr].emp_nota_fiscal IS NULL OR
           ma_doc_orig_unico[l_curr].emp_nota_fiscal = ' ' THEN
           CALL log0030_mensagem('Campo de preenchimento obrigatório!','info')
           NEXT FIELD empresa
        END IF

     AFTER FIELD tip_nota_fiscal
        IF ma_doc_orig_unico[l_curr].tip_nota_fiscal IS NULL OR
           ma_doc_orig_unico[l_curr].tip_nota_fiscal = ' ' THEN
           CALL log0030_mensagem('Campo de preenchimento obrigatório!','info')
           NEXT FIELD tip_nota_fiscal
        END IF

        IF ma_doc_orig_unico[l_curr].tip_nota_fiscal <> 'FATPRDSV' AND
           ma_doc_orig_unico[l_curr].tip_nota_fiscal <> 'FATSERV' AND
           ma_doc_orig_unico[l_curr].tip_nota_fiscal <> 'FATSVTRP' AND
           ma_doc_orig_unico[l_curr].tip_nota_fiscal <> 'CONHEC' AND
           ma_doc_orig_unico[l_curr].tip_nota_fiscal <> 'FATECF' THEN
           CALL log0030_mensagem('Tipo de nota fiscal inválido','info')
           NEXT FIELD tip_nota_fiscal
        END IF

     AFTER FIELD nota_fiscal
        IF ma_doc_orig_unico[l_curr].nota_fiscal IS NULL OR
           ma_doc_orig_unico[l_curr].nota_fiscal = ' '  THEN
           CALL log0030_mensagem('Campo de preenchimento obrigatório!','info')
           NEXT FIELD nota_fiscal
        END IF
        IF NOT geo1015_consiste_nota_fiscal(ma_doc_orig_unico[l_curr].emp_nota_fiscal,
                                             ma_doc_orig_unico[l_curr].tip_nota_fiscal,
                                             ma_doc_orig_unico[l_curr].nota_fiscal    , 0, 0) THEN
           CALL log0030_mensagem('Nota fiscal não cadastrada.','excl')
           NEXT FIELD empresa
        END IF

     AFTER FIELD serie_nota_fiscal
        IF ma_doc_orig_unico[l_curr].serie_nota_fiscal IS NULL OR
           ma_doc_orig_unico[l_curr].serie_nota_fiscal = ' ' THEN
           LET ma_doc_orig_unico[l_curr].serie_nota_fiscal = ' '
        END IF
        IF NOT geo1015_consiste_nota_fiscal(ma_doc_orig_unico[l_curr].emp_nota_fiscal,
                                             ma_doc_orig_unico[l_curr].tip_nota_fiscal,
                                             ma_doc_orig_unico[l_curr].nota_fiscal    ,
                                             ma_doc_orig_unico[l_curr].serie_nota_fiscal,
                                             0) THEN
           CALL log0030_mensagem('Série não cadastrada.','excl')
           NEXT FIELD nota_fiscal
        END IF

     AFTER FIELD subserie_nf
        IF ma_doc_orig_unico[l_curr].subserie_nf IS NULL OR
           ma_doc_orig_unico[l_curr].subserie_nf = ' ' THEN
           CALL log0030_mensagem('Campo de preenchimento obrigatório!','info')
           NEXT FIELD subserie_nf
        END IF
        IF NOT geo1015_consiste_nota_fiscal(ma_doc_orig_unico[l_curr].emp_nota_fiscal,
                                             ma_doc_orig_unico[l_curr].tip_nota_fiscal,
                                             ma_doc_orig_unico[l_curr].nota_fiscal    ,
                                             ma_doc_orig_unico[l_curr].serie_nota_fiscal,
                                             ma_doc_orig_unico[l_curr].subserie_nf) THEN
           CALL log0030_mensagem('Subsérie não cadastrada.','excl')
           NEXT FIELD serie_nota_fiscal
        END IF

     AFTER ROW
        LET m_cont = arr_count()
        IF NOT int_flag THEN
           IF geo1015_verifica_nota_fiscal(l_curr, m_cont) THEN
              CALL log0030_mensagem("Nota fiscal já informada.","excl")
              NEXT FIELD empresa
           END IF
        END IF

     AFTER INPUT
        IF int_flag THEN
           EXIT INPUT
        END IF

        FOR l_ind = 1 TO m_cont

           IF ma_doc_orig_unico[l_ind].emp_nota_fiscal   IS NOT NULL OR
              ma_doc_orig_unico[l_ind].tip_nota_fiscal   IS NOT NULL OR
              ma_doc_orig_unico[l_ind].nota_fiscal       IS NOT NULL OR
              ma_doc_orig_unico[l_ind].serie_nota_fiscal IS NOT NULL OR
              ma_doc_orig_unico[l_ind].subserie_nf       IS NOT NULL THEN

              IF ma_doc_orig_unico[l_ind].emp_nota_fiscal IS NULL OR
                 ma_doc_orig_unico[l_ind].emp_nota_fiscal = ' ' THEN
                 CALL log0030_mensagem('Empresa deve ser informada.','excl')
                 NEXT FIELD empresa
              END IF

              IF ma_doc_orig_unico[l_ind].tip_nota_fiscal IS NULL OR
                 ma_doc_orig_unico[l_ind].tip_nota_fiscal = ' ' THEN
                 CALL log0030_mensagem('Tipo de nota fiscal deve ser informado.','excl')
                 NEXT FIELD tip_nota_fiscal
              END IF

              IF ma_doc_orig_unico[l_ind].tip_nota_fiscal <> 'FATPRDSV' AND
                 ma_doc_orig_unico[l_ind].tip_nota_fiscal <> 'FATSERV' AND
                 ma_doc_orig_unico[l_ind].tip_nota_fiscal <> 'FATSVTRP' AND
                 ma_doc_orig_unico[l_curr].tip_nota_fiscal <> 'CONHEC' AND
                 ma_doc_orig_unico[l_ind].tip_nota_fiscal <> 'FATECF' THEN
                 CALL log0030_mensagem('Tipo de nota fiscal inválido','info')
                 NEXT FIELD tip_nota_fiscal
              END IF

              IF ma_doc_orig_unico[l_ind].nota_fiscal IS NULL OR
                 ma_doc_orig_unico[l_ind].nota_fiscal = ' ' THEN
                 CALL log0030_mensagem('Nota fiscal deve ser informada.','excl')
                 NEXT FIELD nota_fiscal
              END IF
              IF NOT geo1015_consiste_nota_fiscal(ma_doc_orig_unico[l_ind].emp_nota_fiscal,
                                                   ma_doc_orig_unico[l_ind].tip_nota_fiscal,
                                                   ma_doc_orig_unico[l_ind].nota_fiscal    ,
                                                   0,
                                                   0) THEN
                 CALL log0030_mensagem('Nota fiscal não cadastrada.','excl')
                 NEXT FIELD empresa
              END IF

              IF ma_doc_orig_unico[l_ind].serie_nota_fiscal IS NULL OR
                 ma_doc_orig_unico[l_ind].serie_nota_fiscal = ' ' THEN
                 LET ma_doc_orig_unico[l_ind].serie_nota_fiscal = ' '
              END IF
              IF NOT geo1015_consiste_nota_fiscal(ma_doc_orig_unico[l_ind].emp_nota_fiscal,
                                                   ma_doc_orig_unico[l_ind].tip_nota_fiscal,
                                                   ma_doc_orig_unico[l_ind].nota_fiscal    ,
                                                   ma_doc_orig_unico[l_ind].serie_nota_fiscal,
                                                   0) THEN
                 CALL log0030_mensagem('Série não cadastrada.','excl')
                 NEXT FIELD nota_fiscal
              END IF

              IF ma_doc_orig_unico[l_ind].subserie_nf IS NULL OR
                 ma_doc_orig_unico[l_ind].subserie_nf = ' 'THEN
                 CALL log0030_mensagem('Subsérie deve ser informada.','excl')
                 NEXT FIELD serie_nota_fiscal
              END IF
              IF NOT geo1015_consiste_nota_fiscal(ma_doc_orig_unico[l_ind].emp_nota_fiscal,
                                                   ma_doc_orig_unico[l_ind].tip_nota_fiscal,
                                                   ma_doc_orig_unico[l_ind].nota_fiscal    ,
                                                   ma_doc_orig_unico[l_ind].serie_nota_fiscal,
                                                   ma_doc_orig_unico[l_ind].subserie_nf) THEN
                 CALL log0030_mensagem('Subsérie não cadastrada.','excl')
                 NEXT FIELD subserie_nf
              END IF

              IF geo1015_verifica_nota_fiscal(l_ind, m_cont) THEN
                 CALL log0030_mensagem("Nota fiscal já informada.","excl")
                 NEXT FIELD empresa
              END IF
           END IF
        END FOR

     ON KEY (control-z, f4)
        CALL geo1015_pop_up_tipo_nf(l_scr_line)

  END INPUT

  CLOSE WINDOW w_cre1100a
}
  IF int_flag THEN
     WHENEVER ERROR CONTINUE
     DELETE FROM w_nota_fiscal
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
     END IF
     LET m_nota_fiscal = FALSE
     LET m_existe_nota = FALSE
     LET int_flag = FALSE
     RETURN FALSE
  END IF

  IF ma_doc_orig_unico[1].emp_nota_fiscal IS NULL THEN
     LET m_nota_fiscal = FALSE
     LET m_existe_nota = FALSE
     RETURN FALSE
  ELSE
     CALL geo1015_carrega_temporaria()
     RETURN TRUE
  END IF

END FUNCTION


#-----------------------------------------#
FUNCTION geo1015_pop_up_tipo_nf(l_scr_line)
#-----------------------------------------#
  DEFINE l_scr_line         SMALLINT,
         l_lista_opcoes     CHAR(300)

  CASE
     WHEN infield(tip_nota_fiscal)
        LET l_lista_opcoes = l_lista_opcoes CLIPPED," FATPRDSV {",vdpm95_fat_nf_mestre_get_descricao_tip_nota_fiscal("FATPRDSV",FALSE),"} "
        LET l_lista_opcoes = l_lista_opcoes CLIPPED,",FATSERV {",vdpm95_fat_nf_mestre_get_descricao_tip_nota_fiscal("FATSERV",FALSE),"} "
        LET l_lista_opcoes = l_lista_opcoes CLIPPED,",FATSVTRP {",vdpm95_fat_nf_mestre_get_descricao_tip_nota_fiscal("FATSVTRP",FALSE),"} "
        LET l_lista_opcoes = l_lista_opcoes CLIPPED,",FATECF {",vdpm95_fat_nf_mestre_get_descricao_tip_nota_fiscal("FATECF",FALSE),"} "
        LET l_lista_opcoes = l_lista_opcoes CLIPPED,",CONHEC {",vdpm95_fat_nf_mestre_get_descricao_tip_nota_fiscal("CONHEC",FALSE),"} "
        LET ma_doc_orig_unico[l_scr_line].tip_nota_fiscal = log0830_list_box(10,42,l_lista_opcoes)
        DISPLAY ma_doc_orig_unico[l_scr_line].tip_nota_fiscal TO s_doc_orig[l_scr_line].tip_nota_fiscal
     OTHERWISE ERROR 'ZOOM não disponível para este campo!'
  END CASE

END FUNCTION

#---------------------------------------------------------------#
 FUNCTION geo1015_verifica_nota_fiscal(l_arr_curr, l_arr_count)
#---------------------------------------------------------------#
 DEFINE l_arr_curr                SMALLINT,
        l_arr_count               SMALLINT,
        l_ind                     SMALLINT

 FOR l_ind = 1 TO l_arr_count
    IF l_ind = l_arr_curr THEN
       CONTINUE FOR
    END IF

    IF ma_doc_orig_unico[l_ind].emp_nota_fiscal IS NULL OR
       ma_doc_orig_unico[l_ind].emp_nota_fiscal = ' ' THEN
       EXIT FOR
    END IF

    IF ma_doc_orig_unico[l_ind].emp_nota_fiscal   = ma_doc_orig_unico[l_arr_curr].emp_nota_fiscal   AND
       ma_doc_orig_unico[l_ind].tip_nota_fiscal   = ma_doc_orig_unico[l_arr_curr].tip_nota_fiscal   AND
       ma_doc_orig_unico[l_ind].nota_fiscal       = ma_doc_orig_unico[l_arr_curr].nota_fiscal       AND
       ma_doc_orig_unico[l_ind].serie_nota_fiscal = ma_doc_orig_unico[l_arr_curr].serie_nota_fiscal AND
       ma_doc_orig_unico[l_ind].subserie_nf       = ma_doc_orig_unico[l_arr_curr].subserie_nf       THEN
       RETURN TRUE
    END IF

 END FOR

 RETURN FALSE

END FUNCTION

#--------------------------------#
 FUNCTION geo1015_carrega_array()
#--------------------------------#
 DEFINE l_ind       SMALLINT

 LET ma_doc_orig_unico[1].emp_nota_fiscal = mr_param.empresa
 LET ma_doc_orig_unico[1].tip_nota_fiscal = mr_param.tip_nota_fiscal
 LET ma_doc_orig_unico[1].nota_fiscal = mr_param.nota_fiscal_ini
 LET ma_doc_orig_unico[1].serie_nota_fiscal = mr_param.serie_nota_fiscal
 LET ma_doc_orig_unico[1].subserie_nf = 0


 {WHENEVER ERROR CONTINUE
  DECLARE cq_temporaria CURSOR FOR
   SELECT empresa, tipo, nota_fiscal, serie, subserie
     FROM w_nota_fiscal
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql('DECLARE','CQ_TEMPORARIA')
 END IF

 LET l_ind = 1
 LET m_nota_fiscal = FALSE

 WHENEVER ERROR CONTINUE
  FOREACH cq_temporaria INTO ma_doc_orig_unico[l_ind].emp_nota_fiscal,
                             ma_doc_orig_unico[l_ind].tip_nota_fiscal,
                             ma_doc_orig_unico[l_ind].nota_fiscal,
                             ma_doc_orig_unico[l_ind].serie_nota_fiscal,
                             ma_doc_orig_unico[l_ind].subserie_nf
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('FOREACH','CQ_TEMPORARIA')
 END IF
    LET l_ind = l_ind + 1
    LET m_nota_fiscal = TRUE
 END FOREACH

 LET m_cont = l_ind  - 1
}

LET m_cont = 1
LET m_nota_fiscal = FALSE
END FUNCTION

#-------------------------------------#
 FUNCTION geo1015_carrega_temporaria()
#-------------------------------------#
 DEFINE l_ind       SMALLINT

 WHENEVER ERROR CONTINUE
   DELETE FROM w_nota_fiscal;
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
 END IF

 FOR l_ind = 1 TO 999
    IF ma_doc_orig_unico[l_ind].emp_nota_fiscal IS NULL THEN
       EXIT FOR
    END IF

    LET m_nota_fiscal = TRUE
    LET m_existe_nota = TRUE

    IF ma_doc_orig_unico[l_ind].serie_nota_fiscal IS NULL THEN
       LET ma_doc_orig_unico[l_ind].serie_nota_fiscal = ' '
    END IF

    WHENEVER ERROR CONTINUE
      INSERT INTO w_nota_fiscal (empresa    ,
                                 tipo       ,
                                 nota_fiscal,
                                 serie      ,
                                 subserie   )
      VALUES (ma_doc_orig_unico[l_ind].emp_nota_fiscal  ,
              ma_doc_orig_unico[l_ind].tip_nota_fiscal  ,
              ma_doc_orig_unico[l_ind].nota_fiscal      ,
              ma_doc_orig_unico[l_ind].serie_nota_fiscal,
              ma_doc_orig_unico[l_ind].subserie_nf      )
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('INSERT','TEMPORARIA')
    END IF
 END FOR

END FUNCTION

#----------------------------------------#
 FUNCTION geo1015_consiste_nota_fiscal(l_empresa,l_tipo,l_nota_fiscal,l_serie_nf,l_subserie_nf)
#----------------------------------------#
 DEFINE l_count           SMALLINT # LIKE  cre_nf_orig_docum.nota_fiscal
 DEFINE l_empresa         CHAR(02),
        l_tipo            CHAR(08),
        l_nota_fiscal     DECIMAL(10),
        l_serie_nf        LIKE cre_nf_orig_docum.serie_nota_fiscal,
        l_subserie_nf     LIKE cre_nf_orig_docum.subserie_nf,
        l_sql_stmt        CHAR(300),
        l_sql_where       CHAR(300),
        l_sql_from        CHAR(100),
        l_controle        SMALLINT

 LET l_sql_stmt = " SELECT COUNT(nota_fiscal) "

 LET l_sql_from = "  FROM cre_nf_orig_docum  "

 LET l_sql_where = " WHERE emp_nota_fiscal = '",l_empresa    ,"' ",
                   "   AND tip_nota_fiscal = '",l_tipo       ,"' ",
                   "   AND nota_fiscal     = '",l_nota_fiscal,"' "

 IF l_serie_nf <> 0 OR l_serie_nf = " " THEN
    LET l_sql_where = l_sql_where CLIPPED,
                   " AND serie_nota_fiscal = '",l_serie_nf,"' "
 END IF

 IF l_subserie_nf <> 0 THEN
    LET l_sql_where = l_sql_where CLIPPED,
                   " AND subserie_nf = '",l_subserie_nf,"' "
 END IF

 LET l_sql_stmt = l_sql_stmt CLIPPED, l_sql_from CLIPPED,l_sql_where CLIPPED
 LET l_controle = FALSE

 WHENEVER ERROR CONTINUE
 PREPARE var_nota_fiscal FROM l_sql_stmt
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('SELEÇÃO','CRE_NF_ORIG_DOCUM')
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cq_nota_fiscal CURSOR WITH HOLD FOR var_nota_fiscal
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_NOTA_FISCAL")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_nota_fiscal INTO l_count
 WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CQ_NOTA_FISCAL")
       RETURN FALSE
    END IF

 END FOREACH

 IF l_count = 0 THEN
    RETURN FALSE
 ELSE
   RETURN TRUE
 END IF

 CLOSE cq_nota_fiscal
 FREE cq_nota_fiscal

END FUNCTION

#-----------------------------------------#
 FUNCTION geo1015_busca_clientes_cre_txt()
#-----------------------------------------#

   INITIALIZE m_par_clientes_cre_txt TO NULL

   WHENEVER ERROR CONTINUE
     SELECT parametro
       INTO m_par_clientes_cre_txt
       FROM clientes_cre_txt
      WHERE cod_cliente = mr_docum.cod_cliente
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
      CALL log003_err_sql("SELECT","DOCUM")
   END IF

 END FUNCTION

#----------------------------------#
 FUNCTION geo1015_busca_tran_arg()
#----------------------------------#
   DEFINE l_parametro_1   CHAR(10)

   INITIALIZE mr_param.* TO NULL
   INITIALIZE l_parametro_1 TO NULL


   LET l_parametro_1 = log1200_parametro_programa_le(1,0)

   IF  l_parametro_1 IS NULL OR l_parametro_1 = " " THEN
   	   LET l_parametro_1 = "CR"
   END IF

   IF l_parametro_1 = 'NF' THEN
      CALL geo1015_busca_parametros_nf()
   END IF

 END FUNCTION

#---------------------------------------#
 FUNCTION geo1015_busca_parametros_nf()
#---------------------------------------#

   LET mr_param.origem            = log1200_parametro_programa_le(1,0)
   LET mr_param.empresa           = log1200_parametro_programa_le(2,0)
   LET mr_param.portador          = log1200_parametro_programa_le(3,0)
   LET mr_param.tip_nota_fiscal   = log1200_parametro_programa_le(4,0)
   LET mr_param.serie_nota_fiscal = log1200_parametro_programa_le(5,0)
   LET mr_param.nota_fiscal_ini   = log1200_parametro_programa_le(6,0)
   LET mr_param.nota_fiscal_fim   = log1200_parametro_programa_le(7,0)

 # mr_param.instrucoes_1 - mensagem fixa para prazo de vencimento com desconto
 # LET mr_param.instrucoes_1      = log1200_parametro_programa_le(8,0)

   #LET mr_param.instrucoes_2      = log1200_parametro_programa_le(9,0)
   #LET mr_param.instrucoes_3      = log1200_parametro_programa_le(10,0)
   #LET mr_param.instrucoes_4      = log1200_parametro_programa_le(11,0)
   #LET mr_param.instrucoes_5      = log1200_parametro_programa_le(12,0)
   #LET mr_param.instrucoes_6      = log1200_parametro_programa_le(13,0)

   #LET p_ies_impressao            = log1200_parametro_programa_le(14,0)
   #LET p_nom_arquivo              = log1200_parametro_programa_le(15,0)
   #LET m_formato                  = log1200_parametro_programa_le(16,0)
   #LET m_antecipacao_pedido       = log1200_parametro_programa_le(17,0) #766519
   #LET m_param_nf                 = log1200_parametro_programa_le(18,0) #ch especifico TEIAD7

   LET mr_tela.portador_determ        = mr_param.portador
   LET mr_tela.ies_sem_port_tipo_emis = m_selec_nf_bloq_x_portador

  WHENEVER ERROR CONTINUE
    #DELETE FROM tran_arg
    # WHERE cod_empresa   = p_cod_empresa
    #   AND num_programa  = 'geo1015'
    #   AND login_usuario = p_user
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('DELETE','tran_arg')
  END IF

 END FUNCTION

#-------------------------------------------#
 FUNCTION geo1015_busca_dados_nota_fiscal()
#-------------------------------------------#
   DEFINE l_status   SMALLINT
   DEFINE l_mensagem CHAR(100)

   IF NOT vdpm7_clientes_leitura(mr_docum.cod_cliente,FALSE,TRUE) THEN
      RETURN FALSE
   END IF

   IF NOT vdpm95_fat_nf_mestre_leitura(mr_docum.cod_empresa,
                                       mr_nota.trans_nota_fiscal,
                                       TRUE,TRUE) THEN
      RETURN FALSE
   END IF

   DISPLAY vdpm95_fat_nf_mestre_get_nota_fiscal()       TO nota_fiscal
   DISPLAY vdpm95_fat_nf_mestre_get_serie_nota_fiscal() TO serie_nota_fiscal
   CALL LOG_refresh_display()

   IF NOT vdpm121_fat_nf_duplicata_leitura(mr_docum.cod_empresa,
                                           mr_nota.trans_nota_fiscal,
                                           mr_nota.seq_duplicata,
                                           TRUE,TRUE) THEN
      RETURN FALSE
   END IF

   CALL vdpr50_monta_documento_cre(mr_docum.cod_empresa,
                                   vdpm95_fat_nf_mestre_get_nota_fiscal(),
                                   vdpm95_fat_nf_mestre_get_serie_nota_fiscal(),
                                   vdpm95_fat_nf_mestre_get_tip_nota_fiscal(),
                                   mr_nota.seq_duplicata,0)
      RETURNING l_status, mr_docum.num_docum

   IF NOT l_status THEN
      RETURN FALSE
   END IF

   ## 726432
   WHENEVER ERROR CONTINUE
     SELECT cod_empresa
       FROM docum
      WHERE cod_empresa   = mr_docum.cod_empresa
        AND num_docum     = mr_docum.num_docum
        AND ies_tip_docum = "DP"
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      #LET l_mensagem = "Empresa ",mr_docum.cod_empresa," Duplicata ",mr_docum.num_docum CLIPPED," já existente no Contas a Receber."
      #CALL log0030_mensagem(l_mensagem,"exclamation")
      #RETURN FALSE
   ELSE
      IF sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("SELECT","DOCUM")
         RETURN FALSE
      END IF
   END IF
   ## 726432

   {Verificar se é reimpressão de bloqueto via nota fiscal}

   IF vdpm121_fat_nf_duplicata_get_titulo_bancario() IS NOT NULL AND
      vdpm121_fat_nf_duplicata_get_titulo_bancario() <> ' ' THEN
      LET g_reimpressao = TRUE
   ELSE
      LET g_reimpressao = FALSE
   END IF

   { Setar no record mr_docum.* os valores que possuem correspondente  }
   { na nota fiscal. Os campos não utilizados, são preenchidos com     }
   { defaults (ZERO/NULL). Revisar os LETs caso mais algum campo passe }
   { a ser utilizado na emissão do bloqueto.                           }

   LET mr_docum.dat_emis           = vdpm95_fat_nf_mestre_get_dat_hor_emissao()
   LET mr_docum.dat_vencto_c_desc  = vdpm121_fat_nf_duplicata_get_dat_vencto_cdesc()
   LET m_pct_desc_financ           = vdpm121_fat_nf_duplicata_get_pct_desc_financ()
   LET mr_docum.dat_vencto_s_desc  = vdpm121_fat_nf_duplicata_get_dat_vencto_sdesc()
   LET mr_docum.dat_prorrogada     = NULL
   LET mr_docum.ies_cobr_juros     = NULL
   LET mr_docum.cod_repres_1       = 0
   LET mr_docum.cod_repres_2       = 0
   LET mr_docum.cod_repres_3       = 0
   LET mr_docum.val_liquido        = 0
   LET mr_docum.val_bruto          = vdpm121_fat_nf_duplicata_get_val_duplicata()
   LET mr_docum.val_saldo          = vdpm121_fat_nf_duplicata_get_val_duplicata()
   LET mr_docum.val_fat            = 0
   LET mr_docum.val_desc_dia       = 0
   LET mr_docum.val_desp_financ    = 0
   LET mr_docum.ies_tip_cobr       = ' '
   LET mr_docum.pct_juro_mora      = 0

   {Utilizar na reimpressão o mesmo portador da primeira impressão do bloqueto}

   IF g_reimpressao = TRUE AND
      mr_tela.ies_sem_port_tipo_emis = '5' AND
      vdpm121_fat_nf_duplicata_get_portador() > 0 THEN

      LET mr_docum.cod_portador    = vdpm121_fat_nf_duplicata_get_portador()
   ELSE
      LET mr_docum.cod_portador    = vdpm7_clientes_get_cod_portador()
   END IF

   LET mr_docum.ies_tip_portador   = 'B'
   LET mr_docum.ies_cnd_bordero    = ' '
   LET mr_docum.ies_situa_docum    = ' '
   LET mr_docum.dat_alter_situa    = NULL
   LET mr_docum.ies_pgto_docum     = NULL
   LET mr_docum.ies_pendencia      = NULL
   LET mr_docum.ies_bloq_justific  = NULL
   LET mr_docum.num_pedido         = 0
   LET mr_docum.num_docum_origem   = NULL
   LET mr_docum.ies_tip_docum_orig = NULL
   LET mr_docum.ies_serie_fat      = NULL
   LET mr_docum.cod_local_fat      = NULL
   LET mr_docum.cod_tip_comis      = NULL
   LET mr_docum.pct_comis_1        = 0
   LET mr_docum.pct_comis_2        = 0
   LET mr_docum.pct_comis_3        = 0
   LET mr_docum.val_desc_comis     = 0
   LET mr_docum.dat_competencia    = NULL
   LET mr_docum.ies_tip_emis_docum = NULL
   LET mr_docum.dat_emis_docum     = NULL
   LET mr_docum.num_lote_remessa   = NULL
   LET mr_docum.dat_gravacao       = NULL
   LET mr_docum.cod_cnd_pgto       = NULL
   LET mr_docum.cod_deb_cred_cl    = NULL
   LET mr_docum.ies_docum_suspenso = NULL
   LET mr_docum.ies_tip_port_defin = NULL
   LET mr_docum.ies_ctr_endosso    = NULL
   LET mr_docum.cod_mercado        = NULL
   LET mr_docum.num_lote_lanc_cont = NULL
   LET mr_docum.dat_atualiz        = NULL

   RETURN TRUE

 END FUNCTION

#---------------------------------------#
 FUNCTION geo1015_busca_dados_pedido()
#---------------------------------------#
{função criada no chamado ch: 766519
para antecipação de pedidos}

  DEFINE l_num_titulo_banco    LIKE ped_blqt_antecip.num_titulo_banco,
         l_portador            LIKE ped_blqt_antecip.portador,
         l_mensagem            CHAR(200)

   LET m_num_pedido = mr_docum.num_docum

   {Não considerar duplicatas já enviadas para CRE}
   WHENEVER ERROR CONTINUE
   SELECT ped_movto_dupl.num_pedido
     FROM ped_movto_dupl
    WHERE ped_movto_dupl.cod_empresa  = mr_docum.cod_empresa
      AND ped_movto_dupl.num_pedido   = m_num_pedido
      AND ped_movto_dupl.num_lote     > 0
      AND ped_movto_dupl.ies_operacao = 'I'
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      LET l_mensagem = "Empresa ",mr_docum.cod_empresa," Pedido ",m_num_pedido CLIPPED," já existente no Contas a Receber."
      CALL log0030_mensagem(l_mensagem,"exclamation")
      RETURN FALSE
   ELSE
      IF sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql('SELECT','PED_MOVTO_DUPL')
         RETURN FALSE
      END IF
   END IF


   IF NOT vdpm7_clientes_leitura(mr_docum.cod_cliente,FALSE,TRUE) THEN
      RETURN FALSE
   END IF

   IF NOT vdpm46_pedidos_leitura(mr_docum.cod_empresa,
                                 m_num_pedido,
                                 TRUE,TRUE) THEN
      RETURN FALSE
   END IF

   IF NOT vdpm148_ped_duplicata_leitura(mr_docum.cod_empresa,
                                        m_num_pedido,
                                        mr_nota.trans_nota_fiscal, # var. armazena o valor da ped_duplicata.num_duplicata
                                        mr_nota.seq_duplicata,     # var. armazena o valor da ped_duplicata.dig_duplicata
                                        TRUE,TRUE) THEN
      RETURN FALSE
   END IF

   {Verificar se é reimpressão de bloqueto}
   LET l_num_titulo_banco = NULL
   LET l_portador         = 0

   WHENEVER ERROR CONTINUE
   SELECT num_titulo_banco,
          portador
     INTO l_num_titulo_banco,
          l_portador
     FROM ped_blqt_antecip
    WHERE empresa       = mr_docum.cod_empresa
      AND pedido        = m_num_pedido
      AND duplicata     = mr_nota.trans_nota_fiscal  # var. armazena o valor da ped_duplicata.num_duplicata
      AND dig_duplicata = mr_nota.seq_duplicata      # var. armazena o valor da ped_duplicata.dig_duplicata
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
      CALL log003_err_sql('SELECT','PED_BLQT_ANTECIP')
      RETURN FALSE
   END IF

   IF l_num_titulo_banco IS NOT NULL AND l_num_titulo_banco <> ' ' THEN
      LET g_reimpressao     = TRUE
      LET m_titulo_bancario = l_num_titulo_banco
   ELSE
      LET g_reimpressao     = FALSE
      LET m_titulo_bancario = NULL
   END IF

   #monta o numero do documento
   LET mr_docum.num_docum  = m_num_pedido          USING "&&&&&&",
                             mr_nota.seq_duplicata USING "&&",
                             "P"

   { Setar no record mr_docum.* os valores que possuem correspondente  }
   { no pedido. Os campos não utilizados, são preenchidos com     }
   { defaults (ZERO/NULL). Revisar os LETs caso mais algum campo passe }
   { a ser utilizado na emissão do bloqueto.                           }

   LET mr_docum.dat_emis           = vdpm46_pedidos_get_dat_pedido()
   LET mr_docum.dat_vencto_c_desc  = vdpm148_ped_duplicata_get_dat_vencto_cd()
   LET m_pct_desc_financ           = vdpm148_ped_duplicata_get_pct_desc_financ()
   LET mr_docum.dat_vencto_s_desc  = vdpm148_ped_duplicata_get_dat_vencto_sd()
   LET mr_docum.dat_prorrogada     = NULL
   LET mr_docum.ies_cobr_juros     = NULL
   LET mr_docum.cod_repres_1       = 0
   LET mr_docum.cod_repres_2       = 0
   LET mr_docum.cod_repres_3       = 0
   LET mr_docum.val_liquido        = 0
   LET mr_docum.val_bruto          = vdpm148_ped_duplicata_get_val_antecipado()
   LET mr_docum.val_saldo          = vdpm148_ped_duplicata_get_val_antecipado()
   LET mr_docum.val_fat            = 0
   LET mr_docum.val_desc_dia       = 0
   LET mr_docum.val_desp_financ    = 0
   LET mr_docum.ies_tip_cobr       = ' '
   LET mr_docum.pct_juro_mora      = 0

   {Utilizar na reimpressão o mesmo portador da primeira impressão do bloqueto}

   IF g_reimpressao = TRUE AND
      mr_tela.ies_sem_port_tipo_emis = '5' AND
      l_portador > 0 THEN

      LET mr_docum.cod_portador    = l_portador
   ELSE
      LET mr_docum.cod_portador    = vdpm7_clientes_get_cod_portador()
   END IF

   LET mr_docum.ies_tip_portador   = 'B'
   LET mr_docum.ies_cnd_bordero    = ' '
   LET mr_docum.ies_situa_docum    = ' '
   LET mr_docum.dat_alter_situa    = NULL
   LET mr_docum.ies_pgto_docum     = NULL
   LET mr_docum.ies_pendencia      = NULL
   LET mr_docum.ies_bloq_justific  = NULL
   LET mr_docum.num_pedido         = 0
   LET mr_docum.num_docum_origem   = NULL
   LET mr_docum.ies_tip_docum_orig = NULL
   LET mr_docum.ies_serie_fat      = NULL
   LET mr_docum.cod_local_fat      = NULL
   LET mr_docum.cod_tip_comis      = NULL
   LET mr_docum.pct_comis_1        = 0
   LET mr_docum.pct_comis_2        = 0
   LET mr_docum.pct_comis_3        = 0
   LET mr_docum.val_desc_comis     = 0
   LET mr_docum.dat_competencia    = NULL
   LET mr_docum.ies_tip_emis_docum = NULL
   LET mr_docum.dat_emis_docum     = NULL
   LET mr_docum.num_lote_remessa   = NULL
   LET mr_docum.dat_gravacao       = NULL
   LET mr_docum.cod_cnd_pgto       = NULL
   LET mr_docum.cod_deb_cred_cl    = NULL
   LET mr_docum.ies_docum_suspenso = NULL
   LET mr_docum.ies_tip_port_defin = NULL
   LET mr_docum.ies_ctr_endosso    = NULL
   LET mr_docum.cod_mercado        = NULL
   LET mr_docum.num_lote_lanc_cont = NULL
   LET mr_docum.dat_atualiz        = NULL

   RETURN TRUE

 END FUNCTION

#--------------------------------------#
 FUNCTION geo1015_determina_portador()
#--------------------------------------#
{USO INTERNO

 OBJETIVO: Verificar se existe portador parametrizado por período,
           se houver, deve utilizar este portador para emitir o boleto.
}

   DEFINE l_cod_portador   LIKE portador.cod_portador

   INITIALIZE l_cod_portador TO NULL

   WHENEVER ERROR CONTINUE
    SELECT portador
      INTO l_cod_portador
      FROM vdp_detm_port_per
     WHERE empresa      = p_cod_empresa
       AND dat_inicial <= mr_docum.dat_emis
       AND dat_final   >= mr_docum.dat_emis
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      INITIALIZE l_cod_portador TO NULL
   END IF

   IF l_cod_portador > 0 THEN
      LET m_portador = l_cod_portador
   END IF

 END FUNCTION

#--------------------------------------#
 FUNCTION geo1015_pedido_nota_fiscal()
#--------------------------------------#
   DEFINE l_pedido   LIKE pedidos.num_pedido

   WHENEVER ERROR CONTINUE
   DECLARE cq_pedidos_nf CURSOR FOR
    SELECT UNIQUE fat_nf_item.pedido
      FROM fat_nf_item
     WHERE fat_nf_item.empresa           = mr_docum.cod_empresa
       AND fat_nf_item.trans_nota_fiscal = mr_nota.trans_nota_fiscal
       AND fat_nf_item.pedido            > 0
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('DECLARE','CQ_PEDIDOS_NF')
      RETURN 0
   END IF

   WHENEVER ERROR CONTINUE
   OPEN cq_pedidos_nf
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('OPEN','CQ_PEDIDOS_NF')
      RETURN 0
   END IF

   WHENEVER ERROR CONTINUE
   FETCH cq_pedidos_nf INTO l_pedido
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF sqlca.sqlcode <> NOTFOUND THEN
         CALL log003_err_sql('OPEN','CQ_PEDIDOS_NF')
         RETURN 0
      END IF
   END IF

   WHENEVER ERROR CONTINUE
   FREE cq_pedidos_nf
   WHENEVER ERROR STOP

   RETURN l_pedido

 END FUNCTION

#---------------------------------------------------------#
 FUNCTION geo1015_tipo_cobranca_pedido_nao_emite_boleto()
#---------------------------------------------------------#
   DEFINE l_pedido   LIKE pedidos.num_pedido

   IF m_origem_duplicata = 'AN' THEN
      LET l_pedido = m_num_pedido
   ELSE
      LET l_pedido = geo1015_pedido_nota_fiscal()
   END IF

   IF l_pedido > 0 THEN
      IF vdpm64_ped_info_compl_leitura(mr_docum.cod_empresa ,
                                       l_pedido,'TIPO COBRANCA',
                                       FALSE,1) THEN
         IF vdpm64_ped_info_compl_get_par_existencia() = 'C' THEN
            RETURN TRUE
         END IF
      END IF
   END IF

   RETURN FALSE

 END FUNCTION

#------------------------------------------------#
 FUNCTION geo1015_busca_forma_pagamento_pedido()
#------------------------------------------------#
   DEFINE l_pedido        LIKE pedidos.num_pedido

   DEFINE l_forma_pagto   LIKE ped_compl_pedido.forma_pagto

   IF m_origem_duplicata = 'DC' THEN

      IF crem48_cre_docum_compl_leitura(mr_docum.cod_empresa,mr_docum.num_docum,
                                        mr_docum.ies_tip_docum,'forma_pgto_pedido',
                                        FALSE,TRUE) THEN

         LET l_forma_pagto = crem48_cre_docum_compl_get_parametro_texto()
      END IF
   ELSE

      IF m_origem_duplicata = 'AN' THEN
         LET l_pedido = m_num_pedido
      ELSE
         LET l_pedido = geo1015_pedido_nota_fiscal()
      END IF

      IF vdpm22_ped_compl_pedido_leitura(mr_docum.cod_empresa,
                                         l_pedido,FALSE,1) THEN

         LET l_forma_pagto = vdpm22_ped_compl_pedido_get_forma_pagto()
      END IF

   END IF

   RETURN l_forma_pagto

 END FUNCTION

#--------------------------------------------------------------#
 FUNCTION geo1015_reimprimindo_com_titulo_bancario_diferente()
#--------------------------------------------------------------#
{USO INTERNO
 OBJETIVO: Atualmente a rotina de REIMPRESSÃO esta instável, e para cada
           banco existe uma forma diferente de calculo do número do título
           bancário, tanto para impressão como reimpressão.
           Essa função tem o objetivo de verificar se o número retornado
           pelas funções de cada banco, está igual ao numero da impressão, que é
           o correto.
           Se estiver diferente, significa que ocorreu algum erro e o processo
           deve ser cancelado.
}

  DEFINE l_titulo_bancario   LIKE docum_banco.num_titulo_banco,
         l_mensagem          CHAR(200)

  CASE m_origem_duplicata
     WHEN 'DC'
        LET l_titulo_bancario = crem131_docum_banco_get_num_titulo_banco()


        IF gr_relat.cod_banco[1,3] = '356' THEN
           LET l_titulo_bancario = l_titulo_bancario[1,7]
        END IF

     WHEN 'NF'
        LET l_titulo_bancario = vdpm121_fat_nf_duplicata_get_titulo_bancario()

     WHEN 'AN'
        LET l_titulo_bancario = m_titulo_bancario
  END CASE

  IF g_novo_numero <> l_titulo_bancario THEN
     LET l_mensagem = "Erro na reimpressão. O número do título bancário reimpresso '",g_novo_numero CLIPPED,"'",
                      " é diferente do número do título bancário gerado na impressão '",l_titulo_bancario CLIPPED,"'."
     CALL log0030_mensagem(l_mensagem,"exclamation")
     RETURN TRUE
  END IF

  RETURN FALSE

 END FUNCTION


#------------------------------------#
 FUNCTION geo1015_inclui_docum_obs()
#------------------------------------#
 DEFINE l_seq_obs                 LIKE docum_obs.num_seq_docum,
        l_dat_obs                 LIKE docum_obs.dat_obs,
        l_tex_obs_1               LIKE docum_obs.tex_obs_1,
        l_tex_obs_2               LIKE docum_obs.tex_obs_2,
        l_tex_obs_3               LIKE docum_obs.tex_obs_3,
        l_dat_atualiz             LIKE docum_obs.dat_atualiz

  #OS 574044 - gravar docum_obs na impressao e reimpressao do boleto
  #busca última sequencia de obs para a chave
  INITIALIZE l_seq_obs TO NULL

  WHENEVER ERROR CONTINUE
    SELECT MAX(num_seq_docum)
      INTO l_seq_obs
      FROM docum_obs
     WHERE cod_empresa   = mr_docum.cod_empresa
       AND num_docum     = mr_docum.num_docum
       AND ies_tip_docum = mr_docum.ies_tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql('SELECT', 'DOCUM_OBS')
     RETURN FALSE
  END IF

  IF l_seq_obs IS NULL THEN
     LET l_seq_obs = 1
  END IF

  LET l_seq_obs = l_seq_obs + 1
  LET l_dat_obs = m_dat_proces_doc
  LET l_dat_atualiz = TODAY

  IF g_reimpressao THEN #true
     LET l_tex_obs_1 = 'REIMPRESSAO DE BOLETO ATRAVES DO PROGRAMA geo1015. PORTADOR ', mr_docum.cod_portador USING '<<<&'
  ELSE
     LET l_tex_obs_1 = 'IMPRESSAO DE BOLETO ATRAVES DO PROGRAMA geo1015. PORTADOR ', mr_docum.cod_portador CLIPPED USING '<<<&'
  END IF
  LET l_tex_obs_2 = 'OCORRIDO EM ', l_dat_obs, ' AS ', TIME, ' HORAS, '
  LET l_tex_obs_3 = 'PELO LOGIN ', p_user

  WHENEVER ERROR CONTINUE
    INSERT INTO docum_obs(cod_empresa,
                          num_docum,
                          ies_tip_docum,
                          num_seq_docum,
                          dat_obs,
                          tex_obs_1,
                          tex_obs_2,
                          tex_obs_3,
                          dat_atualiz)
    VALUES (mr_docum.cod_empresa,
            mr_docum.num_docum,
            mr_docum.ies_tip_docum,
            l_seq_obs,
            l_dat_obs,
            l_tex_obs_1,
            l_tex_obs_2,
            l_tex_obs_3,
            l_dat_atualiz)
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("INSERT", "DOCUM_OBS")
        RETURN FALSE
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION geo1015_get_cre_tit_cob_esp_banco_ant(l_empresa, l_docum, l_tip_docum, l_tip_cobranca, l_contrato,l_versao)
#------------------------------------#

  DEFINE l_empresa           LIKE cre_tit_cob_esp.empresa,
         l_docum             LIKE cre_tit_cob_esp.docum,
         l_tip_docum         LIKE cre_tit_cob_esp.tip_docum,
         l_tip_cobranca      LIKE cre_tit_cob_esp.tip_cobranca,
         l_contrato          LIKE cre_tit_cob_esp.contrato_cobranca,
         l_versao            LIKE cre_tit_cob_esp.versao,
         lr_cre_tit_cob_esp RECORD LIKE cre_tit_cob_esp.*

  INITIALIZE lr_cre_tit_cob_esp.* TO NULL

  IF NOT log0150_verifica_se_tabela_existe('cre_tit_cob_esp') THEN
     CALL log0030_mensagem("A tabela cre_tit_cob_esp não existe no banco de dados. Verifique junto a área de TI para o correto funcionamento da rotina.","excl")
     RETURN FALSE, lr_cre_tit_cob_esp.*
  ELSE
     WHENEVER ERROR CONTINUE
       SELECT c1.val_parcela_cliente,
              c1.val_saldo_cliente,
              c1.pct_taxa_efetiva,
              c1.dat_vencimento,
              c1.dat_repactuacao,
              c1.val_parcela_cliente
         INTO lr_cre_tit_cob_esp.val_parcela_cliente,
              lr_cre_tit_cob_esp.val_saldo_cliente,
              lr_cre_tit_cob_esp.pct_taxa_efetiva,
              lr_cre_tit_cob_esp.dat_vencimento,
              lr_cre_tit_cob_esp.dat_repactuacao,
              lr_cre_tit_cob_esp.val_parcela_cliente
         FROM cre_tit_cob_esp c1
        WHERE c1.empresa           = l_empresa
          AND c1.docum             = l_docum
          AND c1.tip_docum         = l_tip_docum
          AND c1.tip_cobranca      = l_tip_cobranca
          AND c1.contrato_cobranca = l_contrato
          AND c1.sit_tit_cobranca  = 'B'
          AND c1.versao = (SELECT MAX(versao)
                             FROM cre_tit_cob_esp c3
                            WHERE c3.empresa           = c1.empresa
                              AND c3.docum             = c1.docum
                              AND c3.tip_docum         = c1.tip_docum
                              AND c3.tip_cobranca      = c1.tip_cobranca
                              AND c3.contrato_cobranca = c1.contrato_cobranca
                              AND c3.sit_tit_cobranca  = 'B'
                              AND c3.versao            < l_versao)
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
        CALL log003_err_sql('SELECT B','CRE_TIT_COB_ESP')
        RETURN FALSE, lr_cre_tit_cob_esp.*
     END IF

     RETURN TRUE, lr_cre_tit_cob_esp.*
  END IF

 END FUNCTION

#------------------------------------#
 FUNCTION geo1015_get_val_abatimento_vendor(l_empresa, l_docum, l_tip_docum)
#------------------------------------#
  DEFINE l_empresa   LIKE docum.cod_empresa,
         l_docum     LIKE docum.num_docum,
         l_tip_docum LIKE docum.ies_tip_docum

  DEFINE l_val_abat_docum  LIKE docum_pgto.val_pago,
         l_val_abat_vendor LIKE cre_pagamento_titulo_vendor.val_vendor_pago

  INITIALIZE l_val_abat_docum, l_val_abat_vendor TO NULL

  WHENEVER ERROR CONTINUE
    SELECT SUM (val_pago - val_juro_pago + val_desc_conc + val_abat)
      FROM docum_pgto
     WHERE cod_empresa   = l_empresa
       AND num_docum     = l_docum
       AND ies_tip_docum = l_tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('SELECT ABAT','DOCUM_PGTO')
  END IF

  IF NOT log0150_verifica_se_tabela_existe('cre_pagamento_titulo_vendor') THEN
     CALL log0030_mensagem("A tabela cre_pagamento_titulo_vendor não existe no banco de dados. Verifique junto a área de TI para o correto funcionamento da rotina.","excl")
  ELSE
     WHENEVER ERROR CONTINUE
       SELECT SUM (val_vendor_pago - val_juros_vendor + val_desconto + val_abatimento)
         FROM cre_pagamento_titulo_vendor
        WHERE empresa   = l_empresa
          AND docum     = l_docum
          AND tip_docum = l_tip_docum
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('SELECT ABAT','CRE_PAGAMENTO_TITULO_VENDOR')
     END IF
  END IF

  IF l_val_abat_docum IS NULL THEN
     LET l_val_abat_docum = 0
  END IF

  IF l_val_abat_vendor IS NULL THEN
     LET l_val_abat_vendor = 0
  END IF

  RETURN l_val_abat_docum + l_val_abat_vendor

 END FUNCTION

#-------------------------------------------------------#
 FUNCTION geo1015_verifica_utilizacao_epl_1131_e_1130()
#-------------------------------------------------------#

 #::: VERIFICA SE IRA USAR FUNÇÕES ESPECIFICAS DA GOLDEN / EXATA :::#
 LET m_especifico  = FALSE
 LET m_cod_cliente = "105"

 IF m_especifico = FALSE THEN
    IF Find4GLFunction("crey52_funcao_especifico_1131") THEN
       CALL crey52_funcao_especifico_1131()
       RETURNING m_especifico, m_cod_cliente
       LET m_formato = "G"
    END IF
 END IF

 IF m_especifico = FALSE THEN
    IF Find4GLFunction("crey54_funcao_especifico_1130") THEN
       CALL crey54_funcao_especifico_1130()
       RETURNING m_especifico, m_cod_cliente
       LET m_formato = "G"
    END IF
 END IF

 END FUNCTION

#---------------------------#
FUNCTION geo1015_pergunta()   #--# Chamado 724247 #--#
#---------------------------#
 DEFINE l_mensagem CHAR(200)

 #DEFINE l_tecla CHAR(01)
 #
 #OPEN WINDOW w_aviso AT 9,20 WITH 7 ROWS, 40 COLUMNS
 #   ATTRIBUTE(BORDER, PROMPT LINE LAST)
 #
 #DISPLAY "     !!!  IMPRESSÃO DE BOLETO  !!!     " AT 01,01
 #DISPLAY "          -------------------          " AT 02,01
 #DISPLAY "                                       " AT 03,01
 #DISPLAY "  Imprimir boleto para este cliente ?  " AT 04,01
 #DISPLAY "                                       " AT 05,01
 #PROMPT  "  " FOR CHAR l_tecla
 #CLOSE WINDOW w_aviso
 #
 #LET l_tecla = UPSHIFT(l_tecla)
 #
 #IF l_tecla = 'S' THEN
 #   RETURN TRUE
 #ELSE
 #   RETURN FALSE
 #END IF

 LET l_mensagem = "Imprimir boleto para o cliente: ", mr_docum.cod_cliente

 IF NOT log0040_confirm( 06, 15, l_mensagem ) THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#--------------------------------------------------#
 FUNCTION geo1015_verifica_portador_complementar()
#--------------------------------------------------#
 DEFINE l_portador         LIKE docum.cod_portador

 CALL geo1015_busca_parametro_escrit_compl(mr_docum.cod_empresa,'Numero banco camara compensacao')
    RETURNING m_status, l_portador
 IF NOT m_status THEN
    RETURN FALSE
 END IF

 IF l_portador IS NULL OR l_portador = ' ' THEN
    RETURN m_portador
 END IF

 RETURN l_portador
END FUNCTION


#-----------------------------------------------------------#
 FUNCTION geo1015_ajusta_alinhamento( l_variavel_completa ,
                                       l_posicao_limite    )
#-----------------------------------------------------------#
 DEFINE l_variavel_completa CHAR(112)
 DEFINE l_posicao_limite    SMALLINT #::: Corresponde a ultima casa disponivel no PDF para a apresentação da dados.
 DEFINE l_posicao_inicial   SMALLINT
 DEFINE l_tamanho_total     SMALLINT
 DEFINE l_tamanho_aux       SMALLINT
 DEFINE l_indice            SMALLINT

 LET l_variavel_completa = l_variavel_completa CLIPPED

 LET l_tamanho_aux   = 0
 LET l_tamanho_total = LENGTH( l_variavel_completa )

 LET l_tamanho_aux = l_tamanho_total * 25

 LET l_posicao_inicial = l_posicao_limite - l_tamanho_aux

 RETURN l_posicao_inicial

 END FUNCTION

#-----------------------------------------------#
 FUNCTION geo1015_atualiza_ped_blqt_antecip()
#-----------------------------------------------#

   WHENEVER ERROR CONTINUE
   SELECT empresa
     FROM ped_blqt_antecip
    WHERE empresa       = mr_docum.cod_empresa
      AND pedido        = m_num_pedido
      AND duplicata     = mr_nota.trans_nota_fiscal
      AND dig_duplicata = mr_nota.seq_duplicata
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      WHENEVER ERROR CONTINUE
      UPDATE ped_blqt_antecip
         SET ped_blqt_antecip.portador         = m_portador,
             ped_blqt_antecip.agencia_bancaria = gr_par_bloq_laser.num_agencia,
             ped_blqt_antecip.dig_age_bancaria = gr_par_bloq_laser.dig_agencia,
             ped_blqt_antecip.num_titulo_banco = g_novo_numero
       WHERE empresa       = mr_docum.cod_empresa
         AND pedido        = m_num_pedido
         AND duplicata     = mr_nota.trans_nota_fiscal
         AND dig_duplicata = mr_nota.seq_duplicata
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("UPDATE","PED_BLQT_ANTECIP")
         RETURN FALSE
      END IF
   ELSE
      IF sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("SELECT","PED_BLQT_ANTECIP")
         RETURN FALSE
      END IF

      WHENEVER ERROR CONTINUE
      INSERT INTO ped_blqt_antecip(empresa,
                                   pedido,
                                   duplicata,
                                   dig_duplicata,
                                   portador,
                                   agencia_bancaria,
                                   dig_age_bancaria,
                                   num_titulo_banco)
                           VALUES (mr_docum.cod_empresa,
                                   m_num_pedido,
                                   mr_nota.trans_nota_fiscal,
                                   mr_nota.seq_duplicata,
                                   m_portador,
                                   gr_par_bloq_laser.num_agencia,
                                   gr_par_bloq_laser.dig_agencia,
                                   g_novo_numero)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","PED_BLQT_ANTECIP")
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

 END FUNCTION

#-----------------------------------------------------------------#
 FUNCTION geo1015_busca_parametro_escrit_compl(l_empresa,l_campo)
#-----------------------------------------------------------------#
  DEFINE l_empresa    LIKE cre_escrit_compl.empresa,
         l_campo      LIKE cre_escrit_compl.campo,
         l_parametro  LIKE cre_escrit_compl.parametro_texto

  INITIALIZE l_parametro TO NULL

  WHENEVER ERROR CONTINUE
  SELECT DISTINCT(parametro_texto)
    INTO l_parametro
    FROM cre_escrit_compl
   WHERE empresa      = l_empresa
     AND portador     = m_portador
     AND tip_portador = 'B'
     AND tip_cobranca = 'S'
     AND grupo        IS NOT NULL
     AND padrao_arq   = '01' #CNAB 400
     AND campo        = l_campo
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode = 100 THEN
        WHENEVER ERROR CONTINUE
        SELECT DISTINCT(parametro_texto)
          INTO l_parametro
          FROM cre_escrit_compl
         WHERE empresa      = l_empresa
           AND portador     = m_portador
           AND tip_portador = 'B'
           AND tip_cobranca = 'S'
           AND grupo        IS NOT NULL
           AND padrao_arq   = '02' #CNAB 240
           AND campo        = l_campo
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           IF sqlca.sqlcode = 100 THEN
              INITIALIZE l_parametro TO NULL
           ELSE
              CALL log003_err_sql("SELECT","CRE_ESCRIT_COMPL-2")
              RETURN FALSE, l_parametro CLIPPED
           END IF
        END IF
     ELSE
        CALL log003_err_sql("SELECT","CRE_ESCRIT_COMPL")
        RETURN FALSE, l_parametro CLIPPED
     END IF
  END IF

  RETURN TRUE,l_parametro CLIPPED

 END FUNCTION

#-------------------------------#
 FUNCTION geo1015_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Sustentacao/10R2-11R0/10R2-11R0/financeiro/contas_receber/programas/geo1015.4gl $|$Revision: 73 $|$Date: 14/12/12 14:59 $|$Modtime: 29/04/11 9:20 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION

 
 #-----------------------------------#
 FUNCTION geo1015_grava_audit(l_msg)
 #-----------------------------------#
    DEFINE l_msg    CHAR(99)
    
    #WHENEVER ERROR CONTINUE
    INSERT INTO geo_audit VALUES (p_cod_empresa, 'geo1015',CURRENT,l_msg)
    #WHENEVER ERROR STOP
 END FUNCTION