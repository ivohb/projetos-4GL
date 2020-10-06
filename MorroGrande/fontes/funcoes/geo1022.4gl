###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------#
# SISTEMA.: GEO                                             #
# PROGRAMA: geo1022 (COPIA ADAPTADA/AUTOMATIZADA DE MCX0808)#
# OBJETIVO: BAIXA DOCUMENTOS - CRE                          #
# AUTOR...: EVANDRO SIMENES                                 #
# DATA....: 22/03/2016                                      #
#-----------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE g_ies_grafico   SMALLINT,
         p_nom_tela      CHAR(80),
         p_cod_empresa   LIKE empresa.cod_empresa,
         p_user          CHAR(08),
         g_val_docum     LIKE mcx_movto.val_docum,
         m_nom_help      CHAR(200),
         g_seq_docum_cre LIKE docum_pgto.num_seq_docum

END GLOBALS

# MODULARES
  DEFINE mr_tela        RECORD
                           empresa       LIKE empresa.cod_empresa,
                           den_empresa   LIKE empresa.den_empresa,
                           cliente       LIKE clientes.cod_cliente,
                           nom_cliente   LIKE clientes.nom_cliente,
                           representante LIKE representante.cod_repres,
                           nr_docum      LIKE docum.num_docum,
                           tip_docum1    LIKE docum.ies_tip_docum,
                           dat_inicial   DATE,
                           dat_final     DATE
                        END RECORD

  DEFINE mr_tela2       RECORD
                           empresa         LIKE docum.cod_empresa,
                           den_empresa     LIKE empresa.den_empresa,
                           num_docum       LIKE docum.num_docum,
                           tip_docum       LIKE docum.ies_tip_docum,
                           des_tipo_docum  LIKE par_tipo_docum.des_tipo_docum,
                           dat_vencto      LIKE docum.dat_vencto_s_desc,
                           dat_prorrogada  LIKE docum.dat_prorrogada,
                           cod_cliente     LIKE docum.cod_cliente,
                           nom_cliente     LIKE clientes.nom_cliente,
                           cod_repres      LIKE docum.cod_repres_1,
                           raz_social      LIKE representante.raz_social,
                           val_bruto       LIKE docum.val_bruto
                        END RECORD

  DEFINE ma_tela        ARRAY[500] OF RECORD
                           gera_baixa_docum LIKE mcx_oper_caixa_cre.gera_baixa_docum,
                           tip_docum        LIKE mcx_mov_baixa_cre.tip_docum,
                           num_docum        LIKE mcx_mov_baixa_cre.docum,
                           repres           LIKE representante.cod_repres,
                           dat_vencto       LIKE docum.dat_vencto_s_desc,
                           valor            LIKE docum.val_bruto,
                           des_cliente      LIKE clientes.nom_cliente
                        END RECORD

  DEFINE ma_tela2       ARRAY[1] OF RECORD
                           gera_baixa_docum LIKE mcx_oper_caixa_cre.gera_baixa_docum,
                           tip_docum        LIKE mcx_mov_baixa_cre.tip_docum,
                           num_docum        LIKE mcx_mov_baixa_cre.docum,
                           repres           LIKE representante.cod_repres,
                           dat_vencto       LIKE docum.dat_vencto_s_desc,
                           valor            LIKE docum.val_bruto,
                           des_cliente      LIKE clientes.nom_cliente
                        END RECORD

 DEFINE m_cont            SMALLINT,
        m_arr_curr        SMALLINT,
        m_scr_lin         SMALLINT,
        m_tot_reg         SMALLINT,
        m_consulta_ativa  SMALLINT,
        #m_nom_help        CHAR(200),
        m_versao_funcao   CHAR(18),
        m_den_empresa     LIKE empresa.den_empresa,
        m_nom_cliente     LIKE clientes.nom_cliente,
        m_raz_social      LIKE representante.raz_social,
        m_par_existencia  CHAR(01)

 DEFINE m_dat_movto       LIKE mcx_movto.dat_movto # OS 418784

# END MODULARES

#-------------------------------#
 FUNCTION geo1022_version_info()
#-------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Sustentacao/10R2-11R0/10R2-11R0/financeiro/controle_movimento_caixa/funcoes/geo1022.4gl $|$Revision: 12 $|$Date: 06/09/12 14:39 $|$Modtime: 13/04/10 15:29 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION

#-------------------------------------------------------------------------#
 FUNCTION geo1022_baixa_cre(l_caixa, l_dat_movto, l_seq_dig, l_num_docum, l_cod_titulo, l_cod_cliente, l_tip_docum)
#-------------------------------------------------------------------------#
 DEFINE l_caixa       LIKE mcx_movto.caixa,
        l_dat_movto   LIKE mcx_movto.dat_movto,
        l_seq_dig     LIKE mcx_movto.sequencia_caixa,
        l_num_docum   LIKE mcx_movto.docum,
        l_status      SMALLINT,
        l_enter       SMALLINT,
        l_cont        SMALLINT,
        l_cod_titulo  CHAR(14),
        l_cod_cliente CHAR(15),
        l_tip_docum   LIKE docum.ies_tip_docum

 INITIALIZE mr_tela.*, ma_tela TO NULL
 LET g_val_docum = NULL

 #OPTIONS
   #HELP     FILE m_nom_help

 LET m_versao_funcao = "geo1022-10.01.00p" #Favor nao alterar esta linha (SUPORTE)

 LET m_dat_movto = l_dat_movto # OS 418784

 IF NOT geo1022_verifica_registros(l_caixa, l_dat_movto, l_seq_dig, l_num_docum, l_cod_titulo) THEN
    #CALL log130_procura_caminho("geo1022") RETURNING p_nom_tela
    #OPEN WINDOW w_geo1022 AT 4,2 WITH FORM p_nom_tela
    #     ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

    #CURRENT WINDOW IS w_geo1022

    IF geo1022_entrada_dados(l_cod_cliente, l_tip_docum, l_cod_titulo) THEN
       IF m_consulta_ativa THEN
          IF geo1022_input_array() THEN
             FOR l_cont = 1 TO m_cont
                 IF ma_tela[l_cont].gera_baixa_docum = "S" THEN
                    LET ma_tela2[1].* = ma_tela[l_cont].*
                    LET g_val_docum = ma_tela2[1].valor
     #               CLOSE WINDOW w_geo1022
                    RETURN mr_tela.empresa, ma_tela2[1].num_docum, ma_tela2[1].tip_docum,
                           mr_tela.cliente
                 END IF
             END FOR
          END IF
       END IF
    END IF
 ELSE
    #CALL log130_procura_caminho("geo10221") RETURNING p_nom_tela
    #OPEN WINDOW w_geo10221 AT 4,2 WITH FORM p_nom_tela
    #     ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

    #CURRENT WINDOW IS w_geo10221

    CALL geo1022_verifica_empresa(mr_tela2.empresa)     RETURNING l_status
    CALL geo1022_verifica_cliente(mr_tela2.cod_cliente) RETURNING l_status
    CALL geo1022_verifica_repres(mr_tela2.cod_repres)   RETURNING l_status
    CALL geo1022_verifica_tip_docum()

    LET mr_tela2.den_empresa = m_den_empresa
    LET mr_tela2.nom_cliente = m_nom_cliente
    LET mr_tela2.raz_social  = m_raz_social

    #DISPLAY BY NAME mr_tela2.*
    #PROMPT "Tecle <ENTER> para continuar." FOR l_enter
    #CLOSE WINDOW w_geo10221
    RETURN mr_tela2.empresa, mr_tela2.num_docum, mr_tela2.tip_docum, mr_tela2.cod_cliente
 END IF

 RETURN "","X","",""

END FUNCTION

 #-------------------------------------------------------------#
 FUNCTION geo1022_busca_tratamento_mcx(l_empresa, l_tip_docum)
#-------------------------------------------------------------#
 DEFINE l_empresa          CHAR(02),
        l_tip_docum        LIKE cre_tip_doc_compl.tip_docum

 INITIALIZE m_par_existencia TO NULL

 #---------#
 #OS 473239#
 #---------#
 WHENEVER ERROR CONTINUE
 SELECT par_existencia
        #parametro_texto
   INTO m_par_existencia
   FROM cre_tip_doc_compl
  WHERE empresa   = l_empresa
    AND tip_docum = l_tip_docum
    AND campo     = 'tratamento mcx'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 100 THEN
 ELSE
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("LEITURA","CRE_TIP_DOC_COMPL")
    END IF
 END IF

 IF m_par_existencia = " " THEN
    INITIALIZE m_par_existencia TO NULL
 END IF

 RETURN m_par_existencia

END FUNCTION

#-----------------------------------------------------------------------------------#
 FUNCTION geo1022_verifica_registros(l_caixa, l_dat_movto, l_seq_dig, l_num_docum, l_cod_titulo)
#-----------------------------------------------------------------------------------#
 DEFINE l_caixa          LIKE mcx_movto.caixa,
        l_dat_movto      LIKE mcx_movto.dat_movto,
        l_seq_dig        LIKE mcx_movto.sequencia_caixa,
        l_num_docum      LIKE mcx_movto.docum,
        l_seq_docum      LIKE mcx_mov_baixa_cre.sequencia_docum,
        l_cod_titulo     CHAR(14)
        

 DECLARE cl_cre CURSOR FOR
  SELECT empresa_destino, docum, tip_docum, sequencia_docum, cliente
    FROM mcx_mov_baixa_cre
   WHERE empresa   = p_cod_empresa
     AND caixa     = l_caixa
     AND dat_movto = l_dat_movto
     AND sequencia_caixa = l_seq_dig
   ORDER BY sequencia_docum

 FOREACH cl_cre INTO mr_tela2.empresa, mr_tela2.num_docum, mr_tela2.tip_docum, l_seq_docum,
                     mr_tela2.cod_cliente

    IF l_num_docum = mr_tela2.num_docum THEN

       CALL geo1022_busca_tratamento_mcx(mr_tela2.empresa,mr_tela2.tip_docum)
            RETURNING m_par_existencia
       IF m_par_existencia IS NOT NULL THEN
          CASE
            WHEN "2"
                WHENEVER ERROR CONTINUE
                 SELECT num_docum, ies_tip_docum, dat_vencto_s_desc, dat_prorrogada,
                        cod_cliente, cod_repres_1
                   INTO mr_tela2.num_docum, mr_tela2.tip_docum, mr_tela2.dat_vencto,
                        mr_tela2.dat_prorrogada, mr_tela2.cod_cliente, mr_tela2.cod_repres
                   FROM docum
                  WHERE cod_empresa   = mr_tela2.empresa
                    AND num_docum     = mr_tela2.num_docum
                    AND ies_tip_docum = mr_tela2.tip_docum
                WHENEVER ERROR STOP
                IF sqlca.sqlcode < 0 THEN
                   CALL log003_err_sql("LEITURA","DOCUM")
                END IF

                WHENEVER ERROR CONTINUE
                 SELECT val_docum
                   INTO mr_tela2.val_bruto
                   FROM mcx_movto
                  WHERE empresa   = p_cod_empresa
                    AND caixa     = l_caixa
                    AND dat_movto = l_dat_movto
                    AND sequencia_caixa = l_seq_dig
                WHENEVER ERROR STOP
                IF sqlca.sqlcode < 0 THEN
                   CALL log003_err_sql("LEITURA","DOCUM")
                END IF
            WHEN "1"
                WHENEVER ERROR CONTINUE
                 SELECT dat_devol, dat_devol
                   INTO mr_tela2.dat_vencto, mr_tela2.dat_prorrogada
                   FROM dev_adiant
                  WHERE cod_empresa = mr_tela2.empresa
                    AND num_pedido  = mr_tela2.num_docum
                    AND ies_tip_reg = "A"
                    AND cod_cliente = mr_tela2.cod_cliente
                WHENEVER ERROR STOP
                IF sqlca.sqlcode < 0 THEN
                   CALL log003_err_sql("LEITURA","DOCUM")
                END IF

                WHENEVER ERROR CONTINUE
                 SELECT val_docum
                   INTO mr_tela2.val_bruto
                   FROM mcx_movto
                  WHERE empresa   = p_cod_empresa
                    AND caixa     = l_caixa
                    AND dat_movto = l_dat_movto
                    AND sequencia_caixa = l_seq_dig
                WHENEVER ERROR STOP
                IF sqlca.sqlcode < 0 THEN
                   CALL log003_err_sql("LEITURA","DOCUM")
                END IF
          END CASE
       ELSE
          CASE mr_tela2.tip_docum
            WHEN "DP"
                WHENEVER ERROR CONTINUE
                 SELECT num_docum, ies_tip_docum, dat_vencto_s_desc, dat_prorrogada,
                        cod_cliente, cod_repres_1
                   INTO mr_tela2.num_docum, mr_tela2.tip_docum, mr_tela2.dat_vencto,
                        mr_tela2.dat_prorrogada, mr_tela2.cod_cliente, mr_tela2.cod_repres
                   FROM docum
                  WHERE cod_empresa   = mr_tela2.empresa
                    AND num_docum     = mr_tela2.num_docum
                    AND ies_tip_docum = mr_tela2.tip_docum
                WHENEVER ERROR STOP

                WHENEVER ERROR CONTINUE
                 SELECT val_docum
                   INTO mr_tela2.val_bruto
                   FROM mcx_movto
                  WHERE empresa   = p_cod_empresa
                    AND caixa     = l_caixa
                    AND dat_movto = l_dat_movto
                    AND sequencia_caixa = l_seq_dig
                WHENEVER ERROR STOP

            WHEN "AD"
                WHENEVER ERROR CONTINUE
                 SELECT dat_devol, dat_devol
                   INTO mr_tela2.dat_vencto, mr_tela2.dat_prorrogada
                   FROM dev_adiant
                  WHERE cod_empresa = mr_tela2.empresa
                    AND num_pedido  = mr_tela2.num_docum
                    AND ies_tip_reg = "A"
                    AND cod_cliente = mr_tela2.cod_cliente
                WHENEVER ERROR STOP

                WHENEVER ERROR CONTINUE
                 SELECT val_docum
                   INTO mr_tela2.val_bruto
                   FROM mcx_movto
                  WHERE empresa   = p_cod_empresa
                    AND caixa     = l_caixa
                    AND dat_movto = l_dat_movto
                    AND sequencia_caixa = l_seq_dig
                WHENEVER ERROR STOP
          END CASE
       END IF
       RETURN TRUE
    END IF

 END FOREACH

 RETURN FALSE

END FUNCTION

#--------------------------------#
 FUNCTION geo1022_entrada_dados(l_cod_cliente,l_tip_docum, l_cod_titulo)
#--------------------------------#
   DEFINE l_cod_titulo       CHAR(14)
   DEFINE l_cod_cliente      CHAR(15)
   DEFINE l_tip_docum        LIKE docum.ies_tip_docum
 CALL log006_exibe_teclas("01 02 03 ", m_versao_funcao)
 CURRENT WINDOW IS w_geo1022

 LET INT_FLAG = FALSE
 
 LET mr_tela.nr_docum = l_cod_titulo
 
 
 #INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

    # BEFORE FIELD empresa
        IF g_ies_grafico THEN
     #      --# CALL fgl_dialog_setkeylabel('control-z',"Zoom")
        ELSE
     #      DISPLAY "( Zoom )" AT 3,60
        END IF
LET mr_tela.empresa = p_cod_empresa
 
     #AFTER FIELD empresa
        IF mr_tela.empresa IS NOT NULL THEN
           IF NOT geo1022_verifica_empresa(mr_tela.empresa) THEN
              ERROR "Empresa não cadastrada."
      #        NEXT FIELD empresa
           END IF
           LET mr_tela.den_empresa = m_den_empresa
       #    DISPLAY BY NAME mr_tela.den_empresa
        ELSE
           ERROR "Empresa deve ser informada."
        #   NEXT FIELD empresa
        END IF
LET mr_tela.cliente = l_cod_cliente
 
     #AFTER FIELD cliente
        IF mr_tela.cliente IS NOT NULL THEN
           IF NOT geo1022_verifica_cliente(mr_tela.cliente) THEN
              ERROR "Cliente não cadastrado."
      #        NEXT FIELD cliente
           END IF
           LET mr_tela.nom_cliente = m_nom_cliente
       #    DISPLAY BY NAME mr_tela.nom_cliente
        ELSE
           ERROR "Cliente deve ser informado."
        #   NEXT FIELD cliente
        END IF

     #AFTER FIELD representante
        IF mr_tela.representante IS NOT NULL THEN
           IF NOT geo1022_verifica_repres(mr_tela.representante) THEN
              ERROR "Representante não cadastrado."
      #        NEXT FIELD representante
           END IF
        END IF
        IF g_ies_grafico THEN
       #    --# CALL fgl_dialog_setkeylabel('control-z',"")
        ELSE
        #   DISPLAY "--------" AT 3,60
        END IF

     #BEFORE FIELD tip_docum1
        IF g_ies_grafico THEN
      #     --# CALL fgl_dialog_setkeylabel('control-z',"Zoom")
        ELSE
      #     DISPLAY "( Zoom )" AT 3,60
        END IF
LET mr_tela.tip_docum1 = l_tip_docum
     #AFTER FIELD tip_docum1
        IF mr_tela.tip_docum1 IS NOT NULL THEN
           #IF mr_tela.tip_docum1 <> "DP" AND mr_tela.tip_docum1 <> "NP" AND
           #   mr_tela.tip_docum1 <> "NS" AND mr_tela.tip_docum1 <> "ND" AND
           #   mr_tela.tip_docum1 <> "AD" AND mr_tela.tip_docum1 <> "NC" THEN
           #    ERROR "Tipo de Documento não cadastrado."
           #    NEXT FIELD tip_docum1
           #END IF
           WHENEVER ERROR CONTINUE
            SELECT ies_tip_docum
              FROM par_tipo_docum
             WHERE cod_empresa   = mr_tela.empresa
               AND ies_tip_docum = mr_tela.tip_docum1
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 100 THEN
              CALL log0030_mensagem("Tipo de Documento inválido.","excl")
      #        NEXT FIELD tip_docum1
           ELSE
              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("LEITURA","PAR_TIPO_DOCUM")
              END IF
           END IF
        ELSE
           ERROR "Tipo de Documento deve ser informado."
      #     NEXT FIELD tip_docum1
        END IF
        IF g_ies_grafico THEN
      #     --# CALL fgl_dialog_setkeylabel('control-z',"Zoom")
        ELSE
      #     DISPLAY "( Zoom )" AT 3,60
        END IF

    # AFTER FIELD dat_final
        IF mr_tela.dat_inicial IS NOT NULL THEN
           IF mr_tela.dat_final IS NOT NULL THEN
              IF mr_tela.dat_inicial > mr_tela.dat_final THEN
                 ERROR "Data Inicial deve ser menor que a Data Final."
       #          NEXT FIELD dat_inicial
              END IF
           END IF
        END IF

     

     #AFTER INPUT
        IF NOT INT_FLAG THEN
           IF mr_tela.empresa IS NOT NULL THEN
              IF NOT geo1022_verifica_empresa(mr_tela.empresa) THEN
                 ERROR "Empresa não cadastrada."
        #         NEXT FIELD empresa
              END IF
              LET mr_tela.den_empresa = m_den_empresa
         #     DISPLAY BY NAME mr_tela.den_empresa
           ELSE
              ERROR "Empresa deve ser informada."
       #       NEXT FIELD empresa
           END IF

           IF mr_tela.cliente IS NOT NULL THEN
              IF NOT geo1022_verifica_cliente(mr_tela.cliente) THEN
                 ERROR "Cliente não cadastrado."
        #         NEXT FIELD cliente
              END IF
              LET mr_tela.nom_cliente = m_nom_cliente
       #       DISPLAY BY NAME mr_tela.nom_cliente
           ELSE
              ERROR "Cliente deve ser informado."
       #       NEXT FIELD cliente
           END IF

           IF mr_tela.representante IS NOT NULL THEN
              IF NOT geo1022_verifica_repres(mr_tela.representante) THEN
                 ERROR "Representante não cadastrado."
        #         NEXT FIELD representante
              END IF
           END IF

           IF mr_tela.tip_docum1 IS NOT NULL THEN
			           {IF mr_tela.tip_docum1 <> "DP" AND mr_tela.tip_docum1 <> "NP" AND
			              mr_tela.tip_docum1 <> "NS" AND mr_tela.tip_docum1 <> "ND" AND
			              mr_tela.tip_docum1 <> "AD" AND mr_tela.tip_docum1 <> "NC" THEN
                  ERROR "Tipo de Documento não cadastrado."
                  NEXT FIELD tip_docum1
              END IF}
              WHENEVER ERROR CONTINUE
               SELECT ies_tip_docum
                 FROM par_tipo_docum
                WHERE cod_empresa   = mr_tela.empresa
                  AND ies_tip_docum = mr_tela.tip_docum1
              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 100 THEN
                 CALL log0030_mensagem("Tipo de Documento inválido.","excl")
        #         NEXT FIELD tip_docum1
              ELSE
                 IF sqlca.sqlcode <> 0 THEN
                    CALL log003_err_sql("LEITURA","PAR_TIPO_DOCUM")
                 END IF
              END IF
           ELSE
              ERROR "Tipo de Documento deve ser informado."
        #      NEXT FIELD tip_docum1
           END IF

           IF mr_tela.dat_inicial IS NOT NULL THEN
              IF mr_tela.dat_final IS NOT NULL THEN
                 IF mr_tela.dat_inicial > mr_tela.dat_final THEN
                    ERROR "Data Inicial deve ser menor que a Data Final."
          #          NEXT FIELD dat_inicial
                 END IF
              END IF
           END IF
        END IF
 #END INPUT

 #CALL log006_exibe_teclas('01', m_versao_funcao)
 #CURRENT WINDOW IS w_geo1022

 IF INT_FLAG THEN
    LET int_flag = FALSE
    INITIALIZE mr_tela.*, ma_tela TO NULL
   # CLEAR FORM
    RETURN FALSE
 ELSE
    CALL geo1022_prepara_consulta()
 END IF

 #CALL log006_exibe_teclas('01 09', m_versao_funcao)
 #CURRENT WINDOW IS w_geo1022

 RETURN TRUE

END FUNCTION

#---------------------------------------------#
 FUNCTION geo1022_verifica_empresa(l_empresa)
#---------------------------------------------#
 DEFINE l_empresa    LIKE empresa.cod_empresa

 INITIALIZE m_den_empresa, mr_tela.den_empresa TO NULL

 WHENEVER ERROR CONTINUE
  SELECT den_empresa
    INTO m_den_empresa
    FROM empresa
   WHERE cod_empresa = l_empresa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#---------------------------------------------#
 FUNCTION geo1022_verifica_cliente(l_cliente)
#---------------------------------------------#
 DEFINE l_cliente    LIKE clientes.cod_cliente

 INITIALIZE m_nom_cliente, mr_tela.nom_cliente TO NULL

 WHENEVER ERROR CONTINUE
  SELECT nom_cliente
    INTO m_nom_cliente
    FROM clientes
   WHERE cod_cliente = l_cliente
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#-------------------------------------------#
 FUNCTION geo1022_verifica_repres(l_repres)
#-------------------------------------------#
 DEFINE l_repres   LIKE representante.cod_repres

 WHENEVER ERROR CONTINUE
  SELECT raz_social
    INTO m_raz_social
    FROM representante
   WHERE cod_repres = l_repres
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION geo1022_prepara_consulta()
#-----------------------------------#
 DEFINE l_cont       SMALLINT,
        l_cliente    LIKE clientes.cod_cliente,
        l_num_ad     LIKE ad_ap.num_ad,
        l_tip_desp   LIKE ad_mestre.cod_tip_despesa,
        l_sql_stmt   CHAR(1500),
        l_total_cre  DECIMAL(13,2),
        l_val_pgto   DECIMAL(13,2),
        l_val_juro   DECIMAL(13,2),
        l_total_bxa  DECIMAL(13,2),
        l_total_dev  DECIMAL(13,2),
        l_val_devol  DECIMAL(13,2),
        l_flag       SMALLINT
        

 LET l_cont = 1
 LET l_flag = FALSE

 IF m_par_existencia = '1'
 OR (m_par_existencia IS NULL
 AND mr_tela.tip_docum1 = 'AD') THEN
    LET l_sql_stmt = "SELECT '",mr_tela.tip_docum1,"', num_pedido, '', ",
                     "       '', sum(val_adiant), cod_cliente ",
                     "  FROM adiant_cred ",
                     " WHERE cod_empresa      = '",mr_tela.empresa,"' ",
                     "   AND ies_contabilizar = 'S' ",
                     "   AND ies_posicao      = 'A' ",
                     "   AND cod_cliente      = '",mr_tela.cliente,"' "

    IF mr_tela.nr_docum IS NOT NULL THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                   "   AND num_pedido = '",mr_tela.nr_docum,"' "
    END IF

    LET l_sql_stmt = l_sql_stmt CLIPPED,
                   " GROUP BY num_pedido, cod_cliente ",
                   " ORDER BY num_pedido "
 ELSE
    LET l_sql_stmt = "SELECT ies_tip_docum, num_docum, cod_repres_1, ",
                     "       dat_vencto_s_desc, val_saldo, cod_cliente ",
                     "  FROM docum ",
                     " WHERE cod_empresa      = '",mr_tela.empresa,"' ",
                     "   AND ies_situa_docum <> 'C' ",
                     #"   AND ies_pgto_docum  <> 'T' ",
                     "   AND cod_cliente      = '",mr_tela.cliente,"' ",
                     "   AND ies_tip_docum    = '",mr_tela.tip_docum1,"' " #,
                     #"   AND val_saldo       <> 0 "
                       

    IF mr_tela.representante IS NOT NULL THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                   "   AND cod_repres_1 = ?"
    END IF

    IF mr_tela.nr_docum IS NOT NULL THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                   "   AND num_docum = '",mr_tela.nr_docum,"' "
    END IF

    IF mr_tela.dat_inicial IS NOT NULL AND mr_tela.dat_final IS NOT NULL THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                   "   AND ((dat_prorrogada IS NULL ",
                   "   AND dat_vencto_s_desc BETWEEN '",mr_tela.dat_inicial,"' ",
                   "   AND '",mr_tela.dat_final,"') ",
                   "    OR (dat_prorrogada IS NOT NULL ",
                   "   AND dat_prorrogada BETWEEN '",mr_tela.dat_inicial,"' ",
                   "   AND '",mr_tela.dat_final,"'))"
    END IF
    LET l_sql_stmt = l_sql_stmt CLIPPED,
                   " ORDER BY ies_tip_docum, num_docum, cod_repres_1, dat_vencto_s_desc "
 END IF

 PREPARE var_ap FROM l_sql_stmt
 DECLARE cl_ap SCROLL CURSOR WITH HOLD FOR var_ap

 IF m_par_existencia = '1' OR
   (m_par_existencia IS NULL AND
    mr_tela.tip_docum1 = 'AD') THEN
    WHENEVER ERROR CONTINUE
    OPEN cl_ap
    WHENEVER ERROR STOP
    IF sqlca.sqlcode < 0 THEN
       CALL log003_err_sql("OPEN","CL_AP")
    END IF
 ELSE
    IF mr_tela.representante IS NOT NULL THEN
       WHENEVER ERROR CONTINUE
       OPEN cl_ap USING mr_tela.representante
       WHENEVER ERROR STOP
       IF sqlca.sqlcode < 0 THEN
          CALL log003_err_sql("OPEN","CL_AP")
       END IF
    ELSE
       WHENEVER ERROR CONTINUE
       OPEN cl_ap
       WHENEVER ERROR STOP
       IF sqlca.sqlcode < 0 THEN
          CALL log003_err_sql("OPEN","CL_AP")
       END IF
    END IF
 END IF

 WHENEVER ERROR CONTINUE
 FETCH cl_ap INTO ma_tela[l_cont].tip_docum,
                  ma_tela[l_cont].num_docum,
                  ma_tela[l_cont].repres,
                  ma_tela[l_cont].dat_vencto,
                  ma_tela[l_cont].valor,
                  l_cliente
 WHENEVER ERROR STOP
 IF sqlca.sqlcode < 0 THEN
    CALL log003_err_sql("FETCH","CL_AP")
 END IF
 WHILE SQLCA.sqlcode = 0

     IF m_par_existencia = '1'
     OR (m_par_existencia IS NULL
     AND ma_tela[l_cont].tip_docum = 'AD') THEN
        LET l_total_cre = ma_tela[l_cont].valor
        LET l_total_bxa = 0
        LET l_total_dev = 0

        DECLARE cl_consulta1 CURSOR FOR
         SELECT bxa_adiant.val_pgto, bxa_adiant.val_juro
           FROM bxa_adiant
          WHERE bxa_adiant.cod_emp_adiant = mr_tela.empresa
            AND bxa_adiant.cod_cliente    = l_cliente
            AND bxa_adiant.num_pedido     = ma_tela[l_cont].num_docum
            AND bxa_adiant.dat_credito  <= TODAY

        FOREACH cl_consulta1 INTO l_val_pgto, l_val_juro
           IF l_val_juro IS NULL THEN
              LET l_val_juro = 0
           END IF

           IF l_val_pgto IS NULL THEN
              LET l_val_pgto = 0
           END IF

           LET l_total_bxa = l_total_bxa + l_val_pgto + l_val_juro
        END FOREACH

        DECLARE cl_consulta2 CURSOR FOR
         SELECT dev_adiant.val_devol
           FROM dev_adiant
          WHERE dev_adiant.cod_empresa = mr_tela.empresa
            AND dev_adiant.cod_cliente = l_cliente
            AND dev_adiant.num_pedido  = ma_tela[l_cont].num_docum
            AND dev_adiant.dat_devol  <= TODAY

        FOREACH cl_consulta2 INTO l_val_devol

           IF l_val_devol IS NULL THEN
              LET l_val_devol = 0
           END IF

           LET l_total_dev = l_total_dev + l_val_devol
        END FOREACH

        LET ma_tela[l_cont].valor = (l_total_cre - l_total_bxa) - l_total_dev
     END IF

     WHENEVER ERROR CONTINUE
      SELECT nom_cliente
        INTO ma_tela[l_cont].des_cliente
        FROM clientes
       WHERE cod_cliente = l_cliente
     WHENEVER ERROR STOP

     #IF ma_tela[l_cont].valor <> 0 THEN
        LET l_cont = l_cont + 1
     #END IF

     IF l_cont > 200 THEN
        EXIT WHILE
     END IF

     FETCH cl_ap INTO ma_tela[l_cont].tip_docum,
                      ma_tela[l_cont].num_docum,
                      ma_tela[l_cont].repres,
                      ma_tela[l_cont].dat_vencto,
                      ma_tela[l_cont].valor,
                      l_cliente

 END WHILE

 IF SQLCA.sqlcode <> 0 AND SQLCA.sqlcode <> NOTFOUND THEN
    CALL log003_err_sql("FETCH","CL_AP")
 END IF

 #LET l_cont = l_cont - 1
 #CALL SET_COUNT(l_cont)

 IF l_cont >= 1 THEN
    CALL geo1022_exibe_array()
    LET m_cont = l_cont
    LET m_consulta_ativa = TRUE
 ELSE
    CALL log0030_mensagem('Argumentos de pesquisa não encontrados. ','info')
    LET m_consulta_ativa = FALSE
 END IF

END FUNCTION

#------------------------------#
 FUNCTION geo1022_exibe_array()
#------------------------------#
 DEFINE l_ind      SMALLINT

 FOR l_ind = 1 TO 4
    #DISPLAY ma_tela[l_ind].* TO s_docum[l_ind].*
 END FOR

END FUNCTION

#------------------------------#
 FUNCTION geo1022_input_array()
#------------------------------#
 DEFINE l_cont           SMALLINT,
        l_nom_programa   CHAR(300),
        lr_baixa_ad      RECORD
                            cre1650   CHAR(01),
                            cre1660   CHAR(01),
                            cre4190   CHAR(01)
                         END RECORD

 DEFINE l_integr_cre     CHAR(08),
        l_cancel         SMALLINT,
        l_comando        CHAR(90),
        l_linha_selec    SMALLINT

 FOR l_cont = 1 TO m_cont
     LET ma_tela[l_cont].gera_baixa_docum = "N"
 END FOR

 #CALL SET_COUNT(m_cont)
 #INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_docum.*
   LET m_arr_curr = 1
   #BEFORE ROW
   #   LET m_arr_curr = ARR_CURR()
   #   LET m_scr_lin  = SCR_LINE()
   LET ma_tela[m_arr_curr].gera_baixa_docum = "S"
   #AFTER FIELD gera_baixa_docum
      IF ma_tela[m_arr_curr].gera_baixa_docum = "S" THEN
         FOR l_cont = 1 TO m_cont
             IF l_cont <> m_arr_curr THEN
                IF ma_tela[l_cont].gera_baixa_docum = ma_tela[m_arr_curr].gera_baixa_docum THEN
                   CALL log0030_mensagem("Documento já selecionado.","excl")
                   LET ma_tela[m_arr_curr].gera_baixa_docum = 'N'
     #              DISPLAY ma_tela[m_arr_curr].gera_baixa_docum TO s_docum[m_scr_lin].gera_baixa_docum
      #             NEXT FIELD gera_baixa_docum
                END IF
             END IF
         END FOR
      END IF

   #AFTER INPUT
      IF NOT INT_FLAG THEN
         IF ma_tela[m_arr_curr].gera_baixa_docum = "S" THEN
            FOR l_cont = 1 TO m_cont
                IF l_cont <> m_arr_curr THEN
                   IF ma_tela[l_cont].gera_baixa_docum = ma_tela[m_arr_curr].gera_baixa_docum THEN
                      CALL log0030_mensagem("Documento já selecionado.","excl")
                      LET ma_tela[m_arr_curr].gera_baixa_docum = 'N'
    #                  DISPLAY ma_tela[m_arr_curr].gera_baixa_docum TO s_docum[m_scr_lin].gera_baixa_docum
     #                 NEXT FIELD gera_baixa_docum
                   END IF
                END IF
            END FOR
         END IF

         FOR l_cont = 1 TO m_cont
            IF ma_tela[l_cont].gera_baixa_docum = "S" THEN
               LET l_linha_selec = l_cont
            END IF
         END FOR

        # IF NOT log004_confirm(8,20) THEN
        #    NEXT FIELD gera_baixa_docum
        # END IF

         CALL geo1022_carrega_info_cre()

         IF m_par_existencia = '1'
         OR ( m_par_existencia IS NULL
         AND ma_tela[l_linha_selec].tip_docum = 'AD') THEN
            CALL log130_procura_caminho("geo10222") RETURNING p_nom_tela
            OPEN WINDOW w_geo10222 AT 4,2 WITH FORM p_nom_tela
                 ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

            CURRENT WINDOW IS w_geo10222
            INPUT BY NAME lr_baixa_ad.*

               AFTER FIELD cre1650
                  IF lr_baixa_ad.cre1650 = 'X' THEN
                     EXIT INPUT
                  END IF

               AFTER FIELD cre1660
                  IF lr_baixa_ad.cre1660 = 'X' THEN
                     EXIT INPUT
                  END IF

               AFTER FIELD cre4190
                  IF lr_baixa_ad.cre4190 = 'X' THEN
                     EXIT INPUT
                  END IF

               ON KEY (control-w)
                  #lds IF NOT LOG_logix_versao5() THEN
                  #lds CONTINUE INPUT
                  #lds END IF
                  CALL geo1022_help()

               AFTER INPUT
                  IF NOT INT_FLAG AND
                     lr_baixa_ad.cre1650 <> 'X' AND
                     lr_baixa_ad.cre1660 <> 'X' AND
                     lr_baixa_ad.cre4190 <> 'X' THEN
                     CALL log0030_mensagem('Obrigatório selecionar o tipo da baixa. ','info')
                     NEXT FIELD cre1650
                  END IF

            END INPUT

            CLOSE WINDOW w_geo10222

            CURRENT WINDOW IS w_geo1022

            IF NOT INT_FLAG THEN
               CASE
                  WHEN lr_baixa_ad.cre1650 = 'X'
                     CALL log120_procura_caminho('cre1650') RETURNING l_nom_programa
                     LET l_nom_programa = l_nom_programa CLIPPED, ' ',mr_tela.empresa, ' "',ma_tela[l_linha_selec].num_docum, '" ', mr_tela.cliente
                     RUN l_nom_programa
                  WHEN lr_baixa_ad.cre1660 = 'X'
                     CALL log120_procura_caminho('cre1660') RETURNING l_nom_programa
                     LET l_nom_programa = l_nom_programa CLIPPED, ' ',mr_tela.empresa, ' "',ma_tela[l_linha_selec].num_docum, '" ', mr_tela.cliente
                     RUN l_nom_programa
                  WHEN lr_baixa_ad.cre4190 = 'X'
                     CALL log120_procura_caminho('cre4190') RETURNING l_nom_programa
                     LET l_nom_programa = l_nom_programa CLIPPED, ' ',mr_tela.empresa, ' "',ma_tela[l_linha_selec].num_docum, '" ', mr_tela.cliente
                     RUN l_nom_programa
               END CASE
            END IF
         ELSE
            IF m_par_existencia = '1' OR
              (m_par_existencia IS NULL AND
               ma_tela[l_linha_selec].tip_docum = 'NC') THEN

               CALL geo1022_escolhe_baixa_nc()
                  RETURNING l_integr_cre

               IF l_integr_cre = ' ' THEN
                  #caso o usuário cancele o INPUT
                  #EXIT INPUT
                  #RETURN FALSE
               END IF
            ELSE
               LET l_integr_cre = 'cre00330'
            END IF

            #IF log005_seguranca(p_user,"CRECEBER",l_integr_cre,"MO")  THEN
               ERROR " Aguarde ... Processando integracao com Contas a Receber... "

               #CALL log120_procura_caminho(l_integr_cre) RETURNING l_comando

               #LET l_comando = l_comando CLIPPED, " ",mr_tela.empresa," ",
               #                                     ma_tela[l_linha_selec].num_docum," ",
               #                                     ma_tela[l_linha_selec].tip_docum," ",
               #                                     m_dat_movto," "

               #RUN l_comando RETURNING l_cancel
               #LET l_cancel = l_cancel / 256

               #IF l_cancel = 0 THEN
               #   IF l_integr_cre = 'cre00330' THEN
               #      CALL log120_procura_caminho('cre1580') RETURNING l_nom_programa
               #         RUN l_nom_programa
               #   END IF
               #ELSE
               #   PROMPT "Tecle ENTER para continuar" FOR l_comando
               #END IF
            #END IF

         END IF
      END IF

# END INPUT

 IF int_flag THEN
    INITIALIZE ma_tela TO NULL
    #CLEAR FORM
    RETURN FALSE
 END IF
 RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION geo1022_escolhe_baixa_nc()
#----------------------------------#
 DEFINE lr_baixa_nc RECORD
           cre00330    CHAR(01),
           cre4220     CHAR(01)
                    END RECORD

 LET INT_FLAG = FALSE

 CALL log130_procura_caminho("geo10223") RETURNING p_nom_tela
 OPEN WINDOW w_geo10223 AT 4,2 WITH FORM p_nom_tela
    ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

 CALL log006_exibe_teclas("01 02 03 07 ", m_versao_funcao)
 CURRENT WINDOW IS w_geo10223
 INPUT BY NAME lr_baixa_nc.cre00330,
               lr_baixa_nc.cre4220

    AFTER FIELD cre00330
       IF lr_baixa_nc.cre00330 = 'X' THEN
          EXIT INPUT
       END IF

    AFTER FIELD cre4220
       IF lr_baixa_nc.cre4220 = 'X' THEN
          EXIT INPUT
       END IF

    ON KEY (control-w)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
       CALL geo1022_help()

    AFTER INPUT
       IF NOT INT_FLAG AND
          lr_baixa_nc.cre4220  <> 'X' AND
          lr_baixa_nc.cre00330 <> 'X' THEN
          CALL log0030_mensagem('Obrigatório selecionar o tipo da baixa. ','info')
          NEXT FIELD cre4220
       END IF

 END INPUT

 CLOSE WINDOW w_geo10223
 CURRENT WINDOW IS w_geo1022

 IF NOT INT_FLAG THEN
    CASE
       WHEN lr_baixa_nc.cre4220 = 'X'
          RETURN "cre4220"
       WHEN lr_baixa_nc.cre00330 = 'X'
          RETURN "cre00330"
    END CASE
 END IF

 RETURN " "
END FUNCTION

#-------------------------------------#
 FUNCTION geo1022_verifica_tip_docum()
#-------------------------------------#
 LET mr_tela2.des_tipo_docum = NULL

 CASE mr_tela2.tip_docum
    WHEN "DP" LET mr_tela2.des_tipo_docum = "DUPLICATA"
    WHEN "ND" LET mr_tela2.des_tipo_docum = "NOTA DE DEBITO"
    WHEN "NS" LET mr_tela2.des_tipo_docum = "NOTA DEBITO S/NOTA"
    WHEN "NP" LET mr_tela2.des_tipo_docum = "NOTA PROMISSORIA"
    WHEN "AD" LET mr_tela2.des_tipo_docum = "ADIANTAMENTO"
    WHEN "NC" LET mr_tela2.des_tipo_docum = "NOTA DE CREDITO"
 END CASE

END FUNCTION

#------------------------#
 FUNCTION geo1022_help()
#------------------------#
 CASE
    WHEN infield(empresa)           CALL showhelp(117)
    WHEN infield(cliente)           CALL showhelp(139)
    WHEN infield(representante)     CALL showhelp(140)
    WHEN infield(nr_docum)          CALL showhelp(148)
    WHEN infield(tip_docum1)        CALL showhelp(136)
    WHEN infield(dat_inicial)       CALL showhelp(149)
    WHEN infield(dat_final)         CALL showhelp(150)
    WHEN infield(gera_baixa_docum)  CALL showhelp(151)
    WHEN infield(cre1650)           CALL showhelp(161)
    WHEN infield(cre1660)           CALL showhelp(162)
    WHEN infield(cre4190)           CALL showhelp(163)
 END CASE
END FUNCTION

#--------------------------#
 FUNCTION geo1022_popup()
#--------------------------#
 DEFINE l_condicao  CHAR(50)

 CASE
   WHEN INFIELD(empresa)
      LET mr_tela.empresa = men011_popup_cod_empresa(FALSE)
      CURRENT WINDOW IS w_geo1022

      IF mr_tela.empresa IS NOT NULL THEN
         DISPLAY BY NAME mr_tela.empresa
      END IF

   WHEN INFIELD(cliente)
      LET mr_tela.cliente = vdp372_popup_cliente()
      CURRENT WINDOW IS w_geo1022

      IF mr_tela.cliente IS NOT NULL THEN
         DISPLAY BY NAME mr_tela.cliente
      END IF

   WHEN INFIELD(representante)
         LET mr_tela.representante = cre300_popup_represen_1()
         CURRENT WINDOW IS w_geo1022

         IF mr_tela.representante IS NOT NULL THEN
            DISPLAY BY NAME mr_tela.representante
         END IF

   WHEN INFIELD(tip_docum1)
      IF mr_tela.empresa IS NOT NULL THEN
         LET l_condicao = " cod_empresa = '",mr_tela.empresa,"' "
      END IF
      LET mr_tela.tip_docum1 = log009_popup(08,20,"TIPOS DOCUMENTOS","par_tipo_docum",
                              "ies_tip_docum","des_tipo_docum",
                              "CRE0300","N",l_condicao)
          #log0830_list_box(10,37,'AD {Adiantamento}, DP {Duplicata}, ND {Nota Débito}, NS {Nota Débito s/nota}, NP {Nota Promissória}, NC {Nota de Crédito}')
      CURRENT WINDOW IS w_geo1022

      IF mr_tela.tip_docum1 IS NOT NULL THEN
         DISPLAY BY NAME mr_tela.tip_docum1
      END IF

 END CASE

END FUNCTION

#-----------------------------------#
 FUNCTION geo1022_carrega_info_cre()
#-----------------------------------#
DEFINE l_ind SMALLINT

LET g_seq_docum_cre = 0

FOR l_ind = 1 TO 500
   IF ma_tela[l_ind].gera_baixa_docum = 'S' THEN
      IF m_par_existencia = '1'
      OR (m_par_existencia IS NULL
      AND ma_tela[l_ind].tip_docum = "AD") THEN
         WHENEVER ERROR CONTINUE
         SELECT MAX(num_seq_devol)
           INTO g_seq_docum_cre
           FROM dev_adiant
          WHERE cod_empresa = mr_tela.empresa
            AND num_pedido  = ma_tela[l_ind].num_docum
            AND ies_tip_reg = "A"
            AND cod_cliente = mr_tela.cliente
         WHENEVER ERROR STOP
      ELSE
         WHENEVER ERROR CONTINUE
         SELECT MAX(num_seq_docum)
           INTO g_seq_docum_cre
           FROM docum_pgto
          WHERE cod_empresa   = mr_tela.empresa
            AND num_docum     = ma_tela[l_ind].num_docum
            AND ies_tip_docum = ma_tela[l_ind].tip_docum
         WHENEVER ERROR STOP
      END IF

      IF SQLCA.sqlcode <> 0 OR g_seq_docum_cre IS NULL THEN
         LET g_seq_docum_cre = 0
      END IF

      EXIT FOR

   END IF
END FOR

END FUNCTION

#------------------------------------------#
 FUNCTION geo1022_processa_contas_receber()
#------------------------------------------#
 DEFINE l_indice     SMALLINT
 DEFINE l_tem_dados  SMALLINT
 DEFINE l_houve_erro SMALLINT

 CALL mcx0814_cria_temporaria_processamento()

 FOR l_indice = 1 TO 500
    IF ma_tela[l_indice].num_docum IS NULL OR ma_tela[l_indice].num_docum = " " THEN
       EXIT FOR
    END IF

    IF ma_tela[l_indice].gera_baixa_docum = "S" THEN
       WHENEVER ERROR CONTINUE
         INSERT INTO t_temp_processamento( empresa   ,
                                           num_docum ,
                                           tip_docum ,
                                           valor     )
         VALUES ( mr_tela.empresa                    ,
                  ma_tela[l_indice].num_docum        ,
                  ma_tela[l_indice].tip_docum        ,
                  ma_tela[l_indice].valor            )
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("INSERT","T_TEMP_PROCESSAMENTO")
       END IF
    END IF
 END FOR

 CALL mcx0814_efetua_baixa_automatica_contas_receber()
 RETURNING l_tem_dados, l_houve_erro

 IF NOT l_tem_dados THEN
    CALL log0030_mensagem("Não existem dados para efetuar o processamento.","Info")
 ELSE
    IF l_houve_erro THEN
       CALL log0030_mensagem("Ocorreram erros durante a execução da rotina. Consulte o relatório de erros para mais informações.","Info")
       CALL mcx0814_lista_relatorio_erros()
    ELSE
       CALL log0030_mensagem("Processamento efetuado com sucesso.","Info")
    END IF
 END IF

END FUNCTION

