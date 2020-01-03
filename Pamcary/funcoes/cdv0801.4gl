#------------------------------------------------------------------------#
# SISTEMA..............: CDV                                             #
# PROGRAMA.............: CDV0801                                         #
# OBJETIVO.............: GERAÇÃO DE AUDITORIA                            #
# AUTOR................: FABIANO PEDRO ESPINDOLA                         #
# DATA.................: 13.07.2005                                      #
#------------------------------------------------------------------------#
DATABASE logix

 GLOBALS
  DEFINE p_user         LIKE usuario.nom_usuario
  DEFINE p_cod_empresa  LIKE empresa.cod_empresa
  DEFINE g_tipo_sgbd    CHAR(003)
 END GLOBALS

#MODULARES
  DEFINE sql_stmt      CHAR(5000),
         sql_stmt_aux  CHAR(5000),
         m_cont        SMALLINT,
         m_erro        CHAR(100)

  DEFINE ma_chave_primaria     ARRAY[16]   OF CHAR(18)
  DEFINE ma_rowid              ARRAY[1000] OF char(30)
  DEFINE ma_chave_reg_anterior ARRAY[1000] OF CHAR(250)
  DEFINE ma_chave_reg_atual    ARRAY[1000] OF CHAR(250)

  DEFINE ma_reg_anterior    ARRAY[1000] OF RECORD
            campo_1   CHAR(250),
            campo_2   CHAR(250),
            campo_3   CHAR(250),
            campo_4   CHAR(250),
            campo_5   CHAR(250),
            campo_6   CHAR(250),
            campo_7   CHAR(250),
            campo_8   CHAR(250),
            campo_9   CHAR(250),
            campo_10  CHAR(250),
            campo_11  CHAR(250),
            campo_12  CHAR(250),
            campo_13  CHAR(250),
            campo_14  CHAR(250),
            campo_15  CHAR(250),
            campo_16  CHAR(250),
            campo_17  CHAR(250),
            campo_18  CHAR(250),
            campo_19  CHAR(250),
            campo_20  CHAR(250),
            campo_21  CHAR(250),
            campo_22  CHAR(250),
            campo_23  CHAR(250),
            campo_24  CHAR(250),
            campo_25  CHAR(250),
            campo_26  CHAR(250),
            campo_27  CHAR(250),
            campo_28  CHAR(250),
            campo_29  CHAR(250),
            campo_30  CHAR(250),
            campo_31  CHAR(250),
            campo_32  CHAR(250),
            campo_33  CHAR(250),
            campo_34  CHAR(250),
            campo_35  CHAR(250),
            campo_36  CHAR(250),
            campo_37  CHAR(250),
            campo_38  CHAR(250),
            campo_39  CHAR(250),
            campo_40  CHAR(250),
            campo_41  CHAR(250),
            campo_42  CHAR(250),
            campo_43  CHAR(250),
            campo_44  CHAR(250),
            campo_45  CHAR(250),
            campo_46  CHAR(250),
            campo_47  CHAR(250),
            campo_48  CHAR(250),
            campo_49  CHAR(250),
            campo_50  CHAR(250),
            campo_51  CHAR(250),
            campo_52  CHAR(250),
            campo_53  CHAR(250),
            campo_54  CHAR(250),
            campo_55  CHAR(250),
            campo_56  CHAR(250),
            campo_57  CHAR(250),
            campo_58  CHAR(250),
            campo_59  CHAR(250),
            campo_60  CHAR(250),
            campo_61  CHAR(250),
            campo_62  CHAR(250),
            campo_63  CHAR(250),
            campo_64  CHAR(250),
            campo_65  CHAR(250),
            campo_66  CHAR(250),
            campo_67  CHAR(250),
            campo_68  CHAR(250),
            campo_69  CHAR(250),
            campo_70  CHAR(250),
            campo_71  CHAR(250),
            campo_72  CHAR(250),
            campo_73  CHAR(250),
            campo_74  CHAR(250),
            campo_75  CHAR(250),
            campo_76  CHAR(250),
            campo_77  CHAR(250),
            campo_78  CHAR(250),
            campo_79  CHAR(250),
            campo_80  CHAR(250),
            campo_81  CHAR(250),
            campo_82  CHAR(250),
            campo_83  CHAR(250),
            campo_84  CHAR(250),
            campo_85  CHAR(250),
            campo_86  CHAR(250),
            campo_87  CHAR(250),
            campo_88  CHAR(250),
            campo_89  CHAR(250),
            campo_90  CHAR(250),
            campo_91  CHAR(250),
            campo_92  CHAR(250),
            campo_93  CHAR(250),
            campo_94  CHAR(250),
            campo_95  CHAR(250),
            campo_96  CHAR(250),
            campo_97  CHAR(250),
            campo_98  CHAR(250),
            campo_99  CHAR(250),
            campo_100 CHAR(250),
            campo_101 CHAR(250),
            campo_102 CHAR(250),
            campo_103 CHAR(250),
            campo_104 CHAR(250),
            campo_105 CHAR(250),
            campo_106 CHAR(250),
            campo_107 CHAR(250),
            campo_108 CHAR(250),
            campo_109 CHAR(250),
            campo_110 CHAR(250),
            campo_111 CHAR(250),
            campo_112 CHAR(250),
            campo_113 CHAR(250),
            campo_114 CHAR(250),
            campo_115 CHAR(250),
            campo_116 CHAR(250),
            campo_117 CHAR(250),
            campo_118 CHAR(250),
            campo_119 CHAR(250),
            campo_120 CHAR(250),
            campo_121 CHAR(250),
            campo_122 CHAR(250),
            campo_123 CHAR(250),
            campo_124 CHAR(250),
            campo_125 CHAR(250),
            campo_126 CHAR(250),
            campo_127 CHAR(250),
            campo_128 CHAR(250),
            campo_129 CHAR(250),
            campo_130 CHAR(250)
           END RECORD

  DEFINE m_cod_empresa    LIKE empresa.cod_empresa

  DEFINE ma_reg_atual     ARRAY[1000] OF RECORD
            campo_1  CHAR(250),
            campo_2  CHAR(250),
            campo_3  CHAR(250),
            campo_4  CHAR(250),
            campo_5  CHAR(250),
            campo_6  CHAR(250),
            campo_7  CHAR(250),
            campo_8  CHAR(250),
            campo_9  CHAR(250),
            campo_10 CHAR(250),
            campo_11 CHAR(250),
            campo_12 CHAR(250),
            campo_13 CHAR(250),
            campo_14 CHAR(250),
            campo_15 CHAR(250),
            campo_16 CHAR(250),
            campo_17 CHAR(250),
            campo_18 CHAR(250),
            campo_19 CHAR(250),
            campo_20 CHAR(250),
            campo_21 CHAR(250),
            campo_22 CHAR(250),
            campo_23 CHAR(250),
            campo_24 CHAR(250),
            campo_25 CHAR(250),
            campo_26 CHAR(250),
            campo_27 CHAR(250),
            campo_28 CHAR(250),
            campo_29 CHAR(250),
            campo_30 CHAR(250),
            campo_31 CHAR(250),
            campo_32 CHAR(250),
            campo_33 CHAR(250),
            campo_34 CHAR(250),
            campo_35 CHAR(250),
            campo_36 CHAR(250),
            campo_37 CHAR(250),
            campo_38 CHAR(250),
            campo_39 CHAR(250),
            campo_40 CHAR(250),
            campo_41 CHAR(250),
            campo_42 CHAR(250),
            campo_43 CHAR(250),
            campo_44 CHAR(250),
            campo_45 CHAR(250),
            campo_46 CHAR(250),
            campo_47 CHAR(250),
            campo_48 CHAR(250),
            campo_49 CHAR(250),
            campo_50 CHAR(250),
            campo_51 CHAR(250),
            campo_52 CHAR(250),
            campo_53 CHAR(250),
            campo_54 CHAR(250),
            campo_55 CHAR(250),
            campo_56 CHAR(250),
            campo_57 CHAR(250),
            campo_58 CHAR(250),
            campo_59 CHAR(250),
            campo_60 CHAR(250),
            campo_61 CHAR(250),
            campo_62 CHAR(250),
            campo_63 CHAR(250),
            campo_64 CHAR(250),
            campo_65 CHAR(250),
            campo_66 CHAR(250),
            campo_67 CHAR(250),
            campo_68 CHAR(250),
            campo_69 CHAR(250),
            campo_70 CHAR(250),
            campo_71 CHAR(250),
            campo_72 CHAR(250),
            campo_73 CHAR(250),
            campo_74 CHAR(250),
            campo_75 CHAR(250),
            campo_76 CHAR(250),
            campo_77 CHAR(250),
            campo_78 CHAR(250),
            campo_79 CHAR(250),
            campo_80 CHAR(250),
            campo_81 CHAR(250),
            campo_82 CHAR(250),
            campo_83 CHAR(250),
            campo_84 CHAR(250),
            campo_85 CHAR(250),
            campo_86 CHAR(250),
            campo_87 CHAR(250),
            campo_88 CHAR(250),
            campo_89 CHAR(250),
            campo_90 CHAR(250),
            campo_91 CHAR(250),
            campo_92 CHAR(250),
            campo_93 CHAR(250),
            campo_94 CHAR(250),
            campo_95 CHAR(250),
            campo_96 CHAR(250),
            campo_97 CHAR(250),
            campo_98 CHAR(250),
            campo_99 CHAR(250),
            campo_100   CHAR(250),
            campo_101   CHAR(250),
            campo_102   CHAR(250),
            campo_103   CHAR(250),
            campo_104   CHAR(250),
            campo_105   CHAR(250),
            campo_106   CHAR(250),
            campo_107   CHAR(250),
            campo_108   CHAR(250),
            campo_109   CHAR(250),
            campo_110   CHAR(250),
            campo_111   CHAR(250),
            campo_112   CHAR(250),
            campo_113   CHAR(250),
            campo_114   CHAR(250),
            campo_115   CHAR(250),
            campo_116   CHAR(250),
            campo_117   CHAR(250),
            campo_118   CHAR(250),
            campo_119   CHAR(250),
            campo_120   CHAR(250),
            campo_121   CHAR(250),
            campo_122   CHAR(250),
            campo_123   CHAR(250),
            campo_124   CHAR(250),
            campo_125   CHAR(250),
            campo_126   CHAR(250),
            campo_127   CHAR(250),
            campo_128   CHAR(250),
            campo_129   CHAR(250),
            campo_130   CHAR(250)
           END RECORD

 DEFINE mr_cdv_auditoria_781  RECORD LIKE cdv_auditoria_781.*

#END MODULARES

##############################################################################################
## PASSAGEM DE PARÂMETROS:                                                                  ##
## 1. TABELA  - Nome da tabela com o registro incluído/modificado/excluído.                 ##
##     Quando for um registro referente a Processo, pode ser NULO.                          ##
## 2. WHERE CLAUSE  - No caso de modificação/exclusão, enviar o mesmo where                 ##
##     feito no programa para a seleção dos registros modificados/excluídos.                ##
##     No caso de Processo, enviar a mensagem que deve ser registrada.                      ##
##                  Obs: Passar o where_clause sem " AND " no início.                       ##
##  Ex: LET l_where_clause = " empresa = '", p_cod_empresa, "' and filial = ", l_filial     ##
## 3. TIP. MANUT.   - I - Inclusão, M - Modificação, E - Exclusão, P - Processo             ##
## 4. NUM. PROGRAMA - Programa que está fazendo a manutenção da tabela.                     ##
## 5. CHAMADA    - Número da chamada, necessário apenas para a Modificação.                 ##
##      Passar 1 antes do UPDATE e 2 após o UPDATE. Para os outros casos                    ##
##      (Inclusão / Exclusao / Processo passar 0                                            ##
##############################################################################################
## CHAMADAS:                                                                                ##
## INCLUSÃO - Após a inclusão do registro (logo apos o teste de sqlcode do INSERT, montar o ##
##             where_clause e chamar a função passando a tabela, o where_clause , "I",      ##
##             programa, 0.                                                                 ##
## MODIFICAÇÃO - Chamar a função antes da modificação, passando a tabela, o where usado no  ##
##      UPDATE, "M", programa, 1.                                                           ##
##      Após o UPDATE chamar novamente com os mesmos parâmetros mas com número de           ##
##      chamada 2.                                                                          ##
## EXCLUSÃO - Antes do DELETE dos registros chamar a função passando a tabela, o where      ##
##      usado no DELETE, 'E', programa, 0.                                                  ##
## PROCESSO - Antes ou depois do processamento efetuado chamar a função passando nulo,      ##
##      a mensagem que deve ser registrada, "P", programa, 0 e nulo.                        ##
##############################################################################################
## A função retorna TRUE ou FALSE e não possui BEGIN/COMMIT/ROLLBACK.                       ##
## No caso da função retornar FALSE, deverá ser feito ROLLBACK no programa chamador para    ##
## desfazer toda a transação.                                                               ##
##############################################################################################
#----------------------------------------------------------------------------------------------------------#
 FUNCTION cdv0801_geracao_auditoria(l_cod_empresa, l_tabela,l_where_clause,l_tip_manut,l_programa,l_chamada)
#----------------------------------------------------------------------------------------------------------#
 DEFINE l_tabela        CHAR(18),
        l_where_clause  CHAR(2000),
        l_tip_manut     CHAR(01),
        l_programa      CHAR(08),
        l_chamada       DECIMAL(1,0),
        l_rowid         CHAR(30),
        l_gravou        SMALLINT,
        l_executa_audit CHAR(01),
        l_cod_empresa   LIKE empresa.cod_empresa

 LET m_cod_empresa  = l_cod_empresa

 LET l_where_clause = log0800_replace(l_where_clause,',','.')

 LET l_gravou = FALSE
 LET m_cont   = 0

 CASE l_tip_manut
    WHEN 'I'
       IF cdv0801_inclusao_auditoria(l_tabela,l_programa,l_where_clause) THEN
          LET l_gravou = TRUE
       END IF
    WHEN 'M'
       IF cdv0801_modificacao_auditoria(l_tabela,l_where_clause,l_programa,l_chamada) THEN
          LET l_gravou = TRUE
       END IF
    WHEN 'E'
       IF cdv0801_exclusao_auditoria(l_tabela,l_where_clause, l_programa) THEN
          LET l_gravou = TRUE
       END IF
    WHEN 'P'
       IF cdv0801_processo_auditoria(l_where_clause,l_programa) THEN
          LET l_gravou = TRUE
       END IF
 END CASE

 IF l_gravou THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#--------------------------------------------------------------------------#
FUNCTION cdv0801_inclusao_auditoria(l_tabela,l_programa, l_where_clause)
#--------------------------------------------------------------------------#
 DEFINE l_tabela         CHAR(018),
        l_programa       CHAR(008),
        l_where_clause   CHAR(2000),
        l_chave_registro CHAR(250),
        l_rowid          CHAR(30)

 LET l_rowid = cdv0801_rowid(l_tabela, l_where_clause)

 CALL cdv0801_gera_chave_tabela(l_tabela, l_rowid) RETURNING l_chave_registro

 INITIALIZE mr_cdv_auditoria_781.* TO NULL

 LET mr_cdv_auditoria_781.empresa           = m_cod_empresa
 LET mr_cdv_auditoria_781.usuario           = p_user
 LET mr_cdv_auditoria_781.programa          = l_programa
 LET mr_cdv_auditoria_781.tip_manut         = 'I'
 LET mr_cdv_auditoria_781.nom_tabela        = l_tabela
 LET mr_cdv_auditoria_781.nom_campo         = NULL
 LET mr_cdv_auditoria_781.val_ant           = NULL
 LET mr_cdv_auditoria_781.val_atual         = NULL
 LET mr_cdv_auditoria_781.chave_registro    = l_chave_registro
 LET mr_cdv_auditoria_781.txt_processamento = NULL

 IF cdv0801_insere_audit() THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#----------------------------------------------------------------------------------------#
 FUNCTION cdv0801_modificacao_auditoria(l_tabela,l_where_clause,l_programa,l_chamada)
#----------------------------------------------------------------------------------------#
 DEFINE l_tabela          CHAR(18),
        l_tabela1         CHAR(10),
        l_where_clause    CHAR(2000),
        l_programa        CHAR(08),
        l_chamada         DECIMAL(1,0),
        l_total_colunas   SMALLINT,
        l_cont            SMALLINT,
        l_where           CHAR(500),
        l_rowid           CHAR(30),
        l_index           SMALLINT,
        l_chave           CHAR(250)

 LET l_total_colunas = 0

 LET l_tabela = DOWNSHIFT(l_tabela)

 WHENEVER ERROR CONTINUE
 SELECT COUNT(syscolumns.colname)
   INTO l_total_colunas
   FROM systables, syscolumns
  WHERE systables.tabname = l_tabela
    AND syscolumns.tabid  = systables.tabid
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
 END IF

 IF l_total_colunas = 0 OR l_total_colunas IS NULL THEN
    CALL log0030_mensagem("Tabela sem colunas registradas.",'info')
    RETURN FALSE
 END IF

 LET l_tabela1 = l_tabela[1,10]

 IF l_chamada = 1 THEN
    LET sql_stmt =  "DROP TABLE t_", l_tabela1 CLIPPED,"_ant;"

    WHENEVER ERROR CONTINUE
     PREPARE var_exec FROM sql_stmt
    WHENEVER ERROR STOP

    WHENEVER ERROR CONTINUE
     EXECUTE var_exec
    WHENEVER ERROR STOP

    LET l_chave = '          '

    LET sql_stmt = "SELECT ", l_tabela CLIPPED, ".*, ",
                   "'                                                                                     ' as key, ",
                   l_tabela CLIPPED, ".rowid as row_id ",
                   " FROM ", l_tabela CLIPPED,
                  " WHERE ", l_where_clause CLIPPED,
                   " INTO TEMP t_", l_tabela1 CLIPPED,"_ant;"

    WHENEVER ERROR CONTINUE
     PREPARE var_query FROM sql_stmt
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log0030_mensagem("Problema na leitura dos dados.",'info')
       RETURN FALSE
    END IF

    WHENEVER ERROR CONTINUE
     EXECUTE var_query
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log0030_mensagem("Problema na execução da leitura de dados.",'info')
       RETURN FALSE
    END IF

    LET sql_stmt =  "SELECT ", l_tabela CLIPPED, ".rowid, ",
                    l_tabela CLIPPED, ".* FROM ", l_tabela CLIPPED,
                    " WHERE ", l_where_clause CLIPPED,
                   " ORDER BY ", l_tabela CLIPPED, ".rowid "

    WHENEVER ERROR CONTINUE
     PREPARE var_queryX FROM sql_stmt
     DECLARE cq_antigos CURSOR FOR var_queryX
    WHENEVER ERROR STOP

    FOREACH cq_antigos INTO l_rowid, ma_reg_anterior[1].*
       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("CQ_ANTIGOS","FOREACH")
          EXIT FOREACH
       END IF

       LET sql_stmt_aux = " UPDATE t_", l_tabela1 CLIPPED,"_ant SET key = '", cdv0801_gera_chave_tabela(l_tabela, l_rowid) CLIPPED, "' ",
                           " WHERE t_", l_tabela1 CLIPPED,"_ant.row_id = ", l_rowid

       WHENEVER ERROR CONTINUE
        PREPARE var_update_antigos FROM sql_stmt_aux
       WHENEVER ERROR STOP

       WHENEVER ERROR CONTINUE
        EXECUTE var_update_antigos
       WHENEVER ERROR STOP

    END FOREACH

    WHENEVER ERROR CONTINUE
     FREE cq_antigos
    WHENEVER ERROR STOP

    RETURN TRUE

 END IF

 INITIALIZE ma_reg_anterior       TO NULL
 INITIALIZE ma_chave_reg_anterior TO NULL

 LET l_cont = 1

 LET sql_stmt = " SELECT t_", l_tabela1 CLIPPED,"_ant.row_id, ",
                 " t_", l_tabela1 CLIPPED,"_ant.key, ",
                 " t_", l_tabela1 CLIPPED,"_ant.* ",
            " FROM t_", l_tabela1 CLIPPED,"_ant ",
            "ORDER BY t_", l_tabela1 CLIPPED,"_ant.row_id "

 WHENEVER ERROR CONTINUE
  PREPARE var_query1 FROM sql_stmt
  DECLARE cq_t_antigos CURSOR FOR var_query1
 WHENEVER ERROR STOP

 FOREACH cq_t_antigos INTO l_rowid, ma_chave_reg_anterior[l_cont], ma_reg_anterior[l_cont].*
    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("CQ_T_ANTIGOS","FOREACH")
       EXIT FOREACH
    END IF

    LET l_cont = l_cont + 1

 END FOREACH

 WHENEVER ERROR CONTINUE
  FREE cq_t_antigos
 WHENEVER ERROR STOP

 INITIALIZE ma_chave_primaria TO NULL
 LET l_cont = 1

 LET sql_stmt = "SELECT syscolumns.colname ",
       "  FROM systables, sysconstraints, syscoldepend, syscolumns, sysindexes ",
       " WHERE systables.tabname  = '", DOWNSHIFT(l_tabela), "' ",
         " AND sysconstraints.tabid = systables.tabid",
         " AND sysconstraints.constrtype = 'P' ",
         " AND syscoldepend.tabid = systables.tabid ",
         " AND syscolumns.tabid   = systables.tabid ",
         " AND syscolumns.colno   = syscoldepend.colno ",
         " AND sysindexes.tabid   = syscolumns.tabid ",
         " AND sysindexes.idxtype = 'U' ",
         " AND syscolumns.colno  IN (sysindexes.part1, sysindexes.part2, ",
                                   " sysindexes.part3, sysindexes.part4, ",
                                   " sysindexes.part5, sysindexes.part6, ",
                                   " sysindexes.part7, sysindexes.part8, ",
                                   " sysindexes.part9, sysindexes.part10, ",
                                   " sysindexes.part11, sysindexes.part12, ",
                                   " sysindexes.part13, sysindexes.part14, ",
                                   " sysindexes.part15, sysindexes.part16 )"
 WHENEVER ERROR CONTINUE
  PREPARE var_campos_chave FROM sql_stmt
  DECLARE cq_campos_chave CURSOR FOR var_campos_chave
 WHENEVER ERROR STOP

 FOREACH cq_campos_chave INTO ma_chave_primaria[l_cont]
    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("CQ_CAMPOS_CHAVE","FOREACH")
       EXIT FOREACH
    END IF

    LET l_cont = l_cont + 1
 END FOREACH

 WHENEVER ERROR CONTINUE
  FREE cq_campos_chave
 WHENEVER ERROR STOP

 LET l_cont  = 1
 LET l_where = NULL

 FOR l_cont = 1 TO 16
     IF ma_chave_primaria[l_cont] IS NOT NULL THEN
        IF l_where IS NULL THEN
           LET l_where = l_tabela CLIPPED, ".",
                         ma_chave_primaria[l_cont] CLIPPED,
                         " = b.", ma_chave_primaria[l_cont] CLIPPED
        ELSE
           LET l_where = l_where CLIPPED,
                         " AND ", l_tabela CLIPPED, ".",
                         ma_chave_primaria[l_cont] CLIPPED,
                         " = b.", ma_chave_primaria[l_cont] CLIPPED
        END IF
     END IF

 END FOR

 INITIALIZE sql_stmt TO NULL
 INITIALIZE ma_reg_atual TO NULL
 LET l_cont = 1

 LET sql_stmt = "SELECT ", l_tabela CLIPPED, ".rowid, ",
               l_tabela CLIPPED, ".* ",
           " FROM ", l_tabela CLIPPED,
          " WHERE ", l_where_clause CLIPPED

 WHENEVER ERROR CONTINUE
 PREPARE var_query_2 FROM sql_stmt
 DECLARE cq_t_atuais CURSOR FOR var_query_2
 WHENEVER ERROR STOP

 FOREACH cq_t_atuais INTO ma_rowid[l_cont], ma_reg_atual[l_cont].*
    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("CQ_T_ATUAIS","FOREACH")
       EXIT FOREACH
    END IF

    LET ma_chave_reg_atual[l_cont] = cdv0801_gera_chave_tabela(l_tabela , ma_rowid[l_cont])
    LET l_cont = l_cont + 1

 END FOREACH

 WHENEVER ERROR CONTINUE
 FREE cq_t_atuais
 WHENEVER ERROR STOP

 FOR l_index = 1 TO 1000
     IF ma_chave_reg_anterior[l_index] IS NULL THEN
        CONTINUE FOR
     END IF

     FOR l_cont = 1 TO 1000
         IF ma_chave_reg_atual[l_cont] IS NULL THEN
            CONTINUE FOR
         END IF

         IF ma_chave_reg_anterior[l_index] = ma_chave_reg_atual[l_cont] THEN
            INITIALIZE ma_chave_reg_anterior[l_index] TO NULL
            INITIALIZE ma_chave_reg_atual   [l_cont]  TO NULL

            IF l_total_colunas >= 1 THEN
               IF ma_reg_anterior[l_index].campo_1 <> ma_reg_atual[l_cont].campo_1 OR
                 (ma_reg_anterior[l_index].campo_1 IS NULL AND ma_reg_atual[l_cont].campo_1 IS NOT NULL ) OR
                 (ma_reg_anterior[l_index].campo_1 IS NOT NULL AND ma_reg_atual[l_cont].campo_1 IS NULL ) THEN
                   IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,1,
                      ma_reg_anterior[l_index].campo_1, ma_reg_atual[l_cont].campo_1) THEN
                       RETURN FALSE
                   END IF
               END IF
            ELSE
               CONTINUE FOR
            END IF

            IF l_total_colunas >= 2 THEN
               IF ma_reg_anterior[l_index].campo_2 <> ma_reg_atual[l_cont].campo_2 OR
                  ( ma_reg_anterior[l_index].campo_2 IS NULL AND ma_reg_atual[l_cont].campo_2 IS NOT NULL ) OR
                  ( ma_reg_anterior[l_index].campo_2 IS NOT NULL AND ma_reg_atual[l_cont].campo_2 IS NULL ) THEN
                  IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,2,
                     ma_reg_anterior[l_index].campo_2, ma_reg_atual[l_cont].campo_2) THEN
                      RETURN FALSE
                   END IF
               END IF
            ELSE
               CONTINUE FOR
            END IF

            IF l_total_colunas >= 3 THEN
               IF ma_reg_anterior[l_index].campo_3 <> ma_reg_atual[l_cont].campo_3 OR
                  ( ma_reg_anterior[l_index].campo_3 IS NULL AND ma_reg_atual[l_cont].campo_3 IS NOT NULL ) OR
                  ( ma_reg_anterior[l_index].campo_3 IS NOT NULL AND ma_reg_atual[l_cont].campo_3 IS NULL ) THEN
                  IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,3,
                     ma_reg_anterior[l_index].campo_3, ma_reg_atual[l_cont].campo_3) THEN
                      RETURN FALSE
                   END IF
               END IF
            ELSE
               CONTINUE FOR
            END IF

            IF l_total_colunas >= 4 THEN
             IF ma_reg_anterior[l_index].campo_4 <> ma_reg_atual[l_cont].campo_4 OR
              ( ma_reg_anterior[l_index].campo_4 IS NULL AND ma_reg_atual[l_cont].campo_4 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_4 IS NOT NULL AND ma_reg_atual[l_cont].campo_4 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,4,
                  ma_reg_anterior[l_index].campo_4, ma_reg_atual[l_cont].campo_4) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 5 THEN
             IF ma_reg_anterior[l_index].campo_5 <> ma_reg_atual[l_cont].campo_5 OR
              ( ma_reg_anterior[l_index].campo_5 IS NULL AND ma_reg_atual[l_cont].campo_5 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_5 IS NOT NULL AND ma_reg_atual[l_cont].campo_5 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,5,
                  ma_reg_anterior[l_index].campo_5, ma_reg_atual[l_cont].campo_5) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 6 THEN
             IF ma_reg_anterior[l_index].campo_6 <> ma_reg_atual[l_cont].campo_6 OR
              ( ma_reg_anterior[l_index].campo_6 IS NULL AND ma_reg_atual[l_cont].campo_6 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_6 IS NOT NULL AND ma_reg_atual[l_cont].campo_6 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,6,
                  ma_reg_anterior[l_index].campo_6, ma_reg_atual[l_cont].campo_6) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 7 THEN
             IF ma_reg_anterior[l_index].campo_7 <> ma_reg_atual[l_cont].campo_7 OR
              ( ma_reg_anterior[l_index].campo_7 IS NULL AND ma_reg_atual[l_cont].campo_7 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_7 IS NOT NULL AND ma_reg_atual[l_cont].campo_7 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,7,
                  ma_reg_anterior[l_index].campo_7, ma_reg_atual[l_cont].campo_7) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 8 THEN
             IF ma_reg_anterior[l_index].campo_8 <> ma_reg_atual[l_cont].campo_8 OR
              ( ma_reg_anterior[l_index].campo_8 IS NULL AND ma_reg_atual[l_cont].campo_8 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_8 IS NOT NULL AND ma_reg_atual[l_cont].campo_8 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,8,
                  ma_reg_anterior[l_index].campo_8, ma_reg_atual[l_cont].campo_8) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 9 THEN
             IF ma_reg_anterior[l_index].campo_9 <> ma_reg_atual[l_cont].campo_9 OR
              ( ma_reg_anterior[l_index].campo_9 IS NULL AND ma_reg_atual[l_cont].campo_9 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_9 IS NOT NULL AND ma_reg_atual[l_cont].campo_9 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,9,
                  ma_reg_anterior[l_index].campo_9, ma_reg_atual[l_cont].campo_9) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 10 THEN
             IF ma_reg_anterior[l_index].campo_10 <> ma_reg_atual[l_cont].campo_10 OR
              ( ma_reg_anterior[l_index].campo_10 IS NULL AND ma_reg_atual[l_cont].campo_10 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_10 IS NOT NULL AND ma_reg_atual[l_cont].campo_10 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,10,
                  ma_reg_anterior[l_index].campo_10, ma_reg_atual[l_cont].campo_10) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 11 THEN
             IF ma_reg_anterior[l_index].campo_11 <> ma_reg_atual[l_cont].campo_11 OR
              ( ma_reg_anterior[l_index].campo_11 IS NULL AND ma_reg_atual[l_cont].campo_11 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_11 IS NOT NULL AND ma_reg_atual[l_cont].campo_11 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,11,
                  ma_reg_anterior[l_index].campo_11, ma_reg_atual[l_cont].campo_11) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 12 THEN
             IF ma_reg_anterior[l_index].campo_12 <> ma_reg_atual[l_cont].campo_12 OR
              ( ma_reg_anterior[l_index].campo_12 IS NULL AND ma_reg_atual[l_cont].campo_12 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_12 IS NOT NULL AND ma_reg_atual[l_cont].campo_12 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,12,
                  ma_reg_anterior[l_index].campo_12, ma_reg_atual[l_cont].campo_12) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 13 THEN
             IF ma_reg_anterior[l_index].campo_13 <> ma_reg_atual[l_cont].campo_13 OR
              ( ma_reg_anterior[l_index].campo_13 IS NULL AND ma_reg_atual[l_cont].campo_13 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_13 IS NOT NULL AND ma_reg_atual[l_cont].campo_13 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,13,
                  ma_reg_anterior[l_index].campo_13, ma_reg_atual[l_cont].campo_13) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 14 THEN
             IF ma_reg_anterior[l_index].campo_14 <> ma_reg_atual[l_cont].campo_14 OR
              ( ma_reg_anterior[l_index].campo_14 IS NULL AND ma_reg_atual[l_cont].campo_14 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_14 IS NOT NULL AND ma_reg_atual[l_cont].campo_14 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,14,
                  ma_reg_anterior[l_index].campo_14, ma_reg_atual[l_cont].campo_14) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 15 THEN
             IF ma_reg_anterior[l_index].campo_15 <> ma_reg_atual[l_cont].campo_15 OR
              ( ma_reg_anterior[l_index].campo_15 IS NULL AND ma_reg_atual[l_cont].campo_15 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_15 IS NOT NULL AND ma_reg_atual[l_cont].campo_15 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,15,
                  ma_reg_anterior[l_index].campo_15, ma_reg_atual[l_cont].campo_15) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 16 THEN
             IF ma_reg_anterior[l_index].campo_16 <> ma_reg_atual[l_cont].campo_16 OR
              ( ma_reg_anterior[l_index].campo_16 IS NULL AND ma_reg_atual[l_cont].campo_16 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_16 IS NOT NULL AND ma_reg_atual[l_cont].campo_16 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,16,
                  ma_reg_anterior[l_index].campo_16, ma_reg_atual[l_cont].campo_16) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 17 THEN
             IF ma_reg_anterior[l_index].campo_17 <> ma_reg_atual[l_cont].campo_17 OR
              ( ma_reg_anterior[l_index].campo_17 IS NULL AND ma_reg_atual[l_cont].campo_17 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_17 IS NOT NULL AND ma_reg_atual[l_cont].campo_17 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,17,
                  ma_reg_anterior[l_index].campo_17, ma_reg_atual[l_cont].campo_17) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 18 THEN
             IF ma_reg_anterior[l_index].campo_18 <> ma_reg_atual[l_cont].campo_18 OR
              ( ma_reg_anterior[l_index].campo_18 IS NULL AND ma_reg_atual[l_cont].campo_18 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_18 IS NOT NULL AND ma_reg_atual[l_cont].campo_18 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,18,
                  ma_reg_anterior[l_index].campo_18, ma_reg_atual[l_cont].campo_18) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 19 THEN
             IF ma_reg_anterior[l_index].campo_19 <> ma_reg_atual[l_cont].campo_19 OR
              ( ma_reg_anterior[l_index].campo_19 IS NULL AND ma_reg_atual[l_cont].campo_19 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_19 IS NOT NULL AND ma_reg_atual[l_cont].campo_19 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,19,
                  ma_reg_anterior[l_index].campo_19, ma_reg_atual[l_cont].campo_19) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 20 THEN
             IF ma_reg_anterior[l_index].campo_20 <> ma_reg_atual[l_cont].campo_20 OR
              ( ma_reg_anterior[l_index].campo_20 IS NULL AND ma_reg_atual[l_cont].campo_20 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_20 IS NOT NULL AND ma_reg_atual[l_cont].campo_20 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,20,
                  ma_reg_anterior[l_index].campo_20, ma_reg_atual[l_cont].campo_20) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 21 THEN
             IF ma_reg_anterior[l_index].campo_21 <> ma_reg_atual[l_cont].campo_21 OR
              ( ma_reg_anterior[l_index].campo_21 IS NULL AND ma_reg_atual[l_cont].campo_21 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_21 IS NOT NULL AND ma_reg_atual[l_cont].campo_21 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,21,
                  ma_reg_anterior[l_index].campo_21, ma_reg_atual[l_cont].campo_21) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 22 THEN
             IF ma_reg_anterior[l_index].campo_22 <> ma_reg_atual[l_cont].campo_22 OR
              ( ma_reg_anterior[l_index].campo_22 IS NULL AND ma_reg_atual[l_cont].campo_22 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_22 IS NOT NULL AND ma_reg_atual[l_cont].campo_22 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,22,
                  ma_reg_anterior[l_index].campo_22, ma_reg_atual[l_cont].campo_22) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 23 THEN
             IF ma_reg_anterior[l_index].campo_23 <> ma_reg_atual[l_cont].campo_23 OR
              ( ma_reg_anterior[l_index].campo_23 IS NULL AND ma_reg_atual[l_cont].campo_23 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_23 IS NOT NULL AND ma_reg_atual[l_cont].campo_23 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,23,
                  ma_reg_anterior[l_index].campo_23, ma_reg_atual[l_cont].campo_23) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 24 THEN
             IF ma_reg_anterior[l_index].campo_24 <> ma_reg_atual[l_cont].campo_24 OR
              ( ma_reg_anterior[l_index].campo_24 IS NULL AND ma_reg_atual[l_cont].campo_24 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_24 IS NOT NULL AND ma_reg_atual[l_cont].campo_24 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,24,
                  ma_reg_anterior[l_index].campo_24, ma_reg_atual[l_cont].campo_24) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 25 THEN
             IF ma_reg_anterior[l_index].campo_25 <> ma_reg_atual[l_cont].campo_25 OR
              ( ma_reg_anterior[l_index].campo_25 IS NULL AND ma_reg_atual[l_cont].campo_25 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_25 IS NOT NULL AND ma_reg_atual[l_cont].campo_25 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,25,
                  ma_reg_anterior[l_index].campo_25, ma_reg_atual[l_cont].campo_25) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 26 THEN
             IF ma_reg_anterior[l_index].campo_26 <> ma_reg_atual[l_cont].campo_26 OR
              ( ma_reg_anterior[l_index].campo_26 IS NULL AND ma_reg_atual[l_cont].campo_26 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_26 IS NOT NULL AND ma_reg_atual[l_cont].campo_26 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,26,
                  ma_reg_anterior[l_index].campo_26, ma_reg_atual[l_cont].campo_26) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 27 THEN
             IF ma_reg_anterior[l_index].campo_27 <> ma_reg_atual[l_cont].campo_27 OR
              ( ma_reg_anterior[l_index].campo_27 IS NULL AND ma_reg_atual[l_cont].campo_27 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_27 IS NOT NULL AND ma_reg_atual[l_cont].campo_27 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,27,
                  ma_reg_anterior[l_index].campo_27, ma_reg_atual[l_cont].campo_27) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 28 THEN
             IF ma_reg_anterior[l_index].campo_28 <> ma_reg_atual[l_cont].campo_28 OR
              ( ma_reg_anterior[l_index].campo_28 IS NULL AND ma_reg_atual[l_cont].campo_28 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_28 IS NOT NULL AND ma_reg_atual[l_cont].campo_28 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,28,
                  ma_reg_anterior[l_index].campo_28, ma_reg_atual[l_cont].campo_28) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 29 THEN
             IF ma_reg_anterior[l_index].campo_29 <> ma_reg_atual[l_cont].campo_29 OR
              ( ma_reg_anterior[l_index].campo_29 IS NULL AND ma_reg_atual[l_cont].campo_29 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_29 IS NOT NULL AND ma_reg_atual[l_cont].campo_29 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,29,
                  ma_reg_anterior[l_index].campo_29, ma_reg_atual[l_cont].campo_29) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 30 THEN
             IF ma_reg_anterior[l_index].campo_30 <> ma_reg_atual[l_cont].campo_30 OR
              ( ma_reg_anterior[l_index].campo_30 IS NULL AND ma_reg_atual[l_cont].campo_30 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_30 IS NOT NULL AND ma_reg_atual[l_cont].campo_30 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,30,
                  ma_reg_anterior[l_index].campo_30, ma_reg_atual[l_cont].campo_30) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 31 THEN
             IF ma_reg_anterior[l_index].campo_31 <> ma_reg_atual[l_cont].campo_31 OR
              ( ma_reg_anterior[l_index].campo_31 IS NULL AND ma_reg_atual[l_cont].campo_31 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_31 IS NOT NULL AND ma_reg_atual[l_cont].campo_31 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,31,
                  ma_reg_anterior[l_index].campo_31, ma_reg_atual[l_cont].campo_31) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 32 THEN
             IF ma_reg_anterior[l_index].campo_32 <> ma_reg_atual[l_cont].campo_32 OR
              ( ma_reg_anterior[l_index].campo_32 IS NULL AND ma_reg_atual[l_cont].campo_32 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_32 IS NOT NULL AND ma_reg_atual[l_cont].campo_32 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,32,
                  ma_reg_anterior[l_index].campo_32, ma_reg_atual[l_cont].campo_32) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 33 THEN
             IF ma_reg_anterior[l_index].campo_33 <> ma_reg_atual[l_cont].campo_33 OR
              ( ma_reg_anterior[l_index].campo_33 IS NULL AND ma_reg_atual[l_cont].campo_33 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_33 IS NOT NULL AND ma_reg_atual[l_cont].campo_33 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,33,
                  ma_reg_anterior[l_index].campo_33, ma_reg_atual[l_cont].campo_33) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 34 THEN
             IF ma_reg_anterior[l_index].campo_34 <> ma_reg_atual[l_cont].campo_34 OR
              ( ma_reg_anterior[l_index].campo_34 IS NULL AND ma_reg_atual[l_cont].campo_34 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_34 IS NOT NULL AND ma_reg_atual[l_cont].campo_34 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,34,
                  ma_reg_anterior[l_index].campo_34, ma_reg_atual[l_cont].campo_34) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 35 THEN
             IF ma_reg_anterior[l_index].campo_35 <> ma_reg_atual[l_cont].campo_35 OR
              ( ma_reg_anterior[l_index].campo_35 IS NULL AND ma_reg_atual[l_cont].campo_35 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_35 IS NOT NULL AND ma_reg_atual[l_cont].campo_35 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,35,
                  ma_reg_anterior[l_index].campo_35, ma_reg_atual[l_cont].campo_35) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 36 THEN
             IF ma_reg_anterior[l_index].campo_36 <> ma_reg_atual[l_cont].campo_36 OR
              ( ma_reg_anterior[l_index].campo_36 IS NULL AND ma_reg_atual[l_cont].campo_36 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_36 IS NOT NULL AND ma_reg_atual[l_cont].campo_36 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,36,
                  ma_reg_anterior[l_index].campo_36, ma_reg_atual[l_cont].campo_36) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 37 THEN
             IF ma_reg_anterior[l_index].campo_37 <> ma_reg_atual[l_cont].campo_37 OR
              ( ma_reg_anterior[l_index].campo_37 IS NULL AND ma_reg_atual[l_cont].campo_37 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_37 IS NOT NULL AND ma_reg_atual[l_cont].campo_37 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,37,
                  ma_reg_anterior[l_index].campo_37, ma_reg_atual[l_cont].campo_37) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 38 THEN
             IF ma_reg_anterior[l_index].campo_38 <> ma_reg_atual[l_cont].campo_38 OR
              ( ma_reg_anterior[l_index].campo_38 IS NULL AND ma_reg_atual[l_cont].campo_38 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_38 IS NOT NULL AND ma_reg_atual[l_cont].campo_38 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,38,
                  ma_reg_anterior[l_index].campo_38, ma_reg_atual[l_cont].campo_38) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 39 THEN
             IF ma_reg_anterior[l_index].campo_39 <> ma_reg_atual[l_cont].campo_39 OR
              ( ma_reg_anterior[l_index].campo_39 IS NULL AND ma_reg_atual[l_cont].campo_39 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_39 IS NOT NULL AND ma_reg_atual[l_cont].campo_39 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,39,
                  ma_reg_anterior[l_index].campo_39, ma_reg_atual[l_cont].campo_39) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 40 THEN
             IF ma_reg_anterior[l_index].campo_40 <> ma_reg_atual[l_cont].campo_40 OR
              ( ma_reg_anterior[l_index].campo_40 IS NULL AND ma_reg_atual[l_cont].campo_40 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_40 IS NOT NULL AND ma_reg_atual[l_cont].campo_40 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,40,
                  ma_reg_anterior[l_index].campo_40, ma_reg_atual[l_cont].campo_40) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 41 THEN
             IF ma_reg_anterior[l_index].campo_41 <> ma_reg_atual[l_cont].campo_41 OR
              ( ma_reg_anterior[l_index].campo_41 IS NULL AND ma_reg_atual[l_cont].campo_41 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_41 IS NOT NULL AND ma_reg_atual[l_cont].campo_41 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,41,
                  ma_reg_anterior[l_index].campo_41, ma_reg_atual[l_cont].campo_41) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 42 THEN
             IF ma_reg_anterior[l_index].campo_42 <> ma_reg_atual[l_cont].campo_42 OR
              ( ma_reg_anterior[l_index].campo_42 IS NULL AND ma_reg_atual[l_cont].campo_42 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_42 IS NOT NULL AND ma_reg_atual[l_cont].campo_42 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,42,
                  ma_reg_anterior[l_index].campo_42, ma_reg_atual[l_cont].campo_42) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 43 THEN
             IF ma_reg_anterior[l_index].campo_43 <> ma_reg_atual[l_cont].campo_43 OR
              ( ma_reg_anterior[l_index].campo_43 IS NULL AND ma_reg_atual[l_cont].campo_43 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_43 IS NOT NULL AND ma_reg_atual[l_cont].campo_43 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,43,
                  ma_reg_anterior[l_index].campo_43, ma_reg_atual[l_cont].campo_43) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 44 THEN
             IF ma_reg_anterior[l_index].campo_44 <> ma_reg_atual[l_cont].campo_44 OR
              ( ma_reg_anterior[l_index].campo_44 IS NULL AND ma_reg_atual[l_cont].campo_44 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_44 IS NOT NULL AND ma_reg_atual[l_cont].campo_44 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,44,
                  ma_reg_anterior[l_index].campo_44, ma_reg_atual[l_cont].campo_44) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 45 THEN
             IF ma_reg_anterior[l_index].campo_45 <> ma_reg_atual[l_cont].campo_45 OR
              ( ma_reg_anterior[l_index].campo_45 IS NULL AND ma_reg_atual[l_cont].campo_45 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_45 IS NOT NULL AND ma_reg_atual[l_cont].campo_45 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,45,
                  ma_reg_anterior[l_index].campo_45, ma_reg_atual[l_cont].campo_45) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 46 THEN
             IF ma_reg_anterior[l_index].campo_46 <> ma_reg_atual[l_cont].campo_46 OR
              ( ma_reg_anterior[l_index].campo_46 IS NULL AND ma_reg_atual[l_cont].campo_46 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_46 IS NOT NULL AND ma_reg_atual[l_cont].campo_46 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,46,
                  ma_reg_anterior[l_index].campo_46, ma_reg_atual[l_cont].campo_46) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 47 THEN
             IF ma_reg_anterior[l_index].campo_47 <> ma_reg_atual[l_cont].campo_47 OR
              ( ma_reg_anterior[l_index].campo_47 IS NULL AND ma_reg_atual[l_cont].campo_47 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_47 IS NOT NULL AND ma_reg_atual[l_cont].campo_47 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,47,
                  ma_reg_anterior[l_index].campo_47, ma_reg_atual[l_cont].campo_47) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 48 THEN
             IF ma_reg_anterior[l_index].campo_48 <> ma_reg_atual[l_cont].campo_48 OR
              ( ma_reg_anterior[l_index].campo_48 IS NULL AND ma_reg_atual[l_cont].campo_48 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_48 IS NOT NULL AND ma_reg_atual[l_cont].campo_48 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,48,
                  ma_reg_anterior[l_index].campo_48, ma_reg_atual[l_cont].campo_48) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 49 THEN
             IF ma_reg_anterior[l_index].campo_49 <> ma_reg_atual[l_cont].campo_49 OR
              ( ma_reg_anterior[l_index].campo_49 IS NULL AND ma_reg_atual[l_cont].campo_49 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_49 IS NOT NULL AND ma_reg_atual[l_cont].campo_49 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,49,
                  ma_reg_anterior[l_index].campo_49, ma_reg_atual[l_cont].campo_49) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 50 THEN
             IF ma_reg_anterior[l_index].campo_50 <> ma_reg_atual[l_cont].campo_50 OR
              ( ma_reg_anterior[l_index].campo_50 IS NULL AND ma_reg_atual[l_cont].campo_50 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_50 IS NOT NULL AND ma_reg_atual[l_cont].campo_50 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,50,
                  ma_reg_anterior[l_index].campo_50, ma_reg_atual[l_cont].campo_50) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 51 THEN
             IF ma_reg_anterior[l_index].campo_51 <> ma_reg_atual[l_cont].campo_51 OR
              ( ma_reg_anterior[l_index].campo_51 IS NULL AND ma_reg_atual[l_cont].campo_51 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_51 IS NOT NULL AND ma_reg_atual[l_cont].campo_51 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,51,
                  ma_reg_anterior[l_index].campo_51, ma_reg_atual[l_cont].campo_51) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 52 THEN
             IF ma_reg_anterior[l_index].campo_52 <> ma_reg_atual[l_cont].campo_52 OR
              ( ma_reg_anterior[l_index].campo_52 IS NULL AND ma_reg_atual[l_cont].campo_52 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_52 IS NOT NULL AND ma_reg_atual[l_cont].campo_52 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,52,
                  ma_reg_anterior[l_index].campo_52, ma_reg_atual[l_cont].campo_52) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 53 THEN
             IF ma_reg_anterior[l_index].campo_53 <> ma_reg_atual[l_cont].campo_53 OR
              ( ma_reg_anterior[l_index].campo_53 IS NULL AND ma_reg_atual[l_cont].campo_53 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_53 IS NOT NULL AND ma_reg_atual[l_cont].campo_53 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,53,
                  ma_reg_anterior[l_index].campo_53, ma_reg_atual[l_cont].campo_53) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 54 THEN
             IF ma_reg_anterior[l_index].campo_54 <> ma_reg_atual[l_cont].campo_54 OR
              ( ma_reg_anterior[l_index].campo_54 IS NULL AND ma_reg_atual[l_cont].campo_54 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_54 IS NOT NULL AND ma_reg_atual[l_cont].campo_54 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,54,
                  ma_reg_anterior[l_index].campo_54, ma_reg_atual[l_cont].campo_54) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 55 THEN
             IF ma_reg_anterior[l_index].campo_55 <> ma_reg_atual[l_cont].campo_55 OR
              ( ma_reg_anterior[l_index].campo_55 IS NULL AND ma_reg_atual[l_cont].campo_55 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_55 IS NOT NULL AND ma_reg_atual[l_cont].campo_55 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,55,
                  ma_reg_anterior[l_index].campo_55, ma_reg_atual[l_cont].campo_55) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 56 THEN
             IF ma_reg_anterior[l_index].campo_56 <> ma_reg_atual[l_cont].campo_56 OR
              ( ma_reg_anterior[l_index].campo_56 IS NULL AND ma_reg_atual[l_cont].campo_56 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_56 IS NOT NULL AND ma_reg_atual[l_cont].campo_56 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,56,
                  ma_reg_anterior[l_index].campo_56, ma_reg_atual[l_cont].campo_56) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 57 THEN
             IF ma_reg_anterior[l_index].campo_57 <> ma_reg_atual[l_cont].campo_57 OR
              ( ma_reg_anterior[l_index].campo_57 IS NULL AND ma_reg_atual[l_cont].campo_57 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_57 IS NOT NULL AND ma_reg_atual[l_cont].campo_57 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,57,
                  ma_reg_anterior[l_index].campo_57, ma_reg_atual[l_cont].campo_57) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 58 THEN
             IF ma_reg_anterior[l_index].campo_58 <> ma_reg_atual[l_cont].campo_58 OR
              ( ma_reg_anterior[l_index].campo_58 IS NULL AND ma_reg_atual[l_cont].campo_58 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_58 IS NOT NULL AND ma_reg_atual[l_cont].campo_58 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,58,
                  ma_reg_anterior[l_index].campo_58, ma_reg_atual[l_cont].campo_58) THEN
               RETURN FALSE
              END IF
             END IF
            END IF

            IF l_total_colunas >= 59 THEN
             IF ma_reg_anterior[l_index].campo_59 <> ma_reg_atual[l_cont].campo_59 OR
              ( ma_reg_anterior[l_index].campo_59 IS NULL AND ma_reg_atual[l_cont].campo_59 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_59 IS NOT NULL AND ma_reg_atual[l_cont].campo_59 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,59,
                  ma_reg_anterior[l_index].campo_59, ma_reg_atual[l_cont].campo_59) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 60 THEN
             IF ma_reg_anterior[l_index].campo_60 <> ma_reg_atual[l_cont].campo_60 OR
              ( ma_reg_anterior[l_index].campo_60 IS NULL AND ma_reg_atual[l_cont].campo_60 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_60 IS NOT NULL AND ma_reg_atual[l_cont].campo_60 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,60,
                  ma_reg_anterior[l_index].campo_60, ma_reg_atual[l_cont].campo_60) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 61 THEN
             IF ma_reg_anterior[l_index].campo_61 <> ma_reg_atual[l_cont].campo_61 OR
              ( ma_reg_anterior[l_index].campo_61 IS NULL AND ma_reg_atual[l_cont].campo_61 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_61 IS NOT NULL AND ma_reg_atual[l_cont].campo_61 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,61,
                  ma_reg_anterior[l_index].campo_61, ma_reg_atual[l_cont].campo_61) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 62 THEN
             IF ma_reg_anterior[l_index].campo_62 <> ma_reg_atual[l_cont].campo_62 OR
              ( ma_reg_anterior[l_index].campo_62 IS NULL AND ma_reg_atual[l_cont].campo_62 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_62 IS NOT NULL AND ma_reg_atual[l_cont].campo_62 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,62,
                  ma_reg_anterior[l_index].campo_62, ma_reg_atual[l_cont].campo_62) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 63 THEN
             IF ma_reg_anterior[l_index].campo_63 <> ma_reg_atual[l_cont].campo_63 OR
              ( ma_reg_anterior[l_index].campo_63 IS NULL AND ma_reg_atual[l_cont].campo_63 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_63 IS NOT NULL AND ma_reg_atual[l_cont].campo_63 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,63,
                  ma_reg_anterior[l_index].campo_63, ma_reg_atual[l_cont].campo_63) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 64 THEN
             IF ma_reg_anterior[l_index].campo_64 <> ma_reg_atual[l_cont].campo_64 OR
              ( ma_reg_anterior[l_index].campo_64 IS NULL AND ma_reg_atual[l_cont].campo_64 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_64 IS NOT NULL AND ma_reg_atual[l_cont].campo_64 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,64,
                  ma_reg_anterior[l_index].campo_64, ma_reg_atual[l_cont].campo_64) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 65 THEN
             IF ma_reg_anterior[l_index].campo_65 <> ma_reg_atual[l_cont].campo_65 OR
              ( ma_reg_anterior[l_index].campo_65 IS NULL AND ma_reg_atual[l_cont].campo_65 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_65 IS NOT NULL AND ma_reg_atual[l_cont].campo_65 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,65,
                  ma_reg_anterior[l_index].campo_65, ma_reg_atual[l_cont].campo_65) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 66 THEN
             IF ma_reg_anterior[l_index].campo_66 <> ma_reg_atual[l_cont].campo_66 OR
              ( ma_reg_anterior[l_index].campo_66 IS NULL AND ma_reg_atual[l_cont].campo_66 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_66 IS NOT NULL AND ma_reg_atual[l_cont].campo_66 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,66,
                  ma_reg_anterior[l_index].campo_66, ma_reg_atual[l_cont].campo_66) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 67 THEN
             IF ma_reg_anterior[l_index].campo_67 <> ma_reg_atual[l_cont].campo_67 OR
              ( ma_reg_anterior[l_index].campo_67 IS NULL AND ma_reg_atual[l_cont].campo_67 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_67 IS NOT NULL AND ma_reg_atual[l_cont].campo_67 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,67,
                  ma_reg_anterior[l_index].campo_67, ma_reg_atual[l_cont].campo_67) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 68 THEN
             IF ma_reg_anterior[l_index].campo_68 <> ma_reg_atual[l_cont].campo_68 OR
              ( ma_reg_anterior[l_index].campo_68 IS NULL AND ma_reg_atual[l_cont].campo_68 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_68 IS NOT NULL AND ma_reg_atual[l_cont].campo_68 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,68,
                  ma_reg_anterior[l_index].campo_68, ma_reg_atual[l_cont].campo_68) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 69 THEN
             IF ma_reg_anterior[l_index].campo_69 <> ma_reg_atual[l_cont].campo_69 OR
              ( ma_reg_anterior[l_index].campo_69 IS NULL AND ma_reg_atual[l_cont].campo_69 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_69 IS NOT NULL AND ma_reg_atual[l_cont].campo_69 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,69,
                  ma_reg_anterior[l_index].campo_69, ma_reg_atual[l_cont].campo_69) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 70 THEN
             IF ma_reg_anterior[l_index].campo_70 <> ma_reg_atual[l_cont].campo_70 OR
              ( ma_reg_anterior[l_index].campo_70 IS NULL AND ma_reg_atual[l_cont].campo_70 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_70 IS NOT NULL AND ma_reg_atual[l_cont].campo_70 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,70,
                  ma_reg_anterior[l_index].campo_70, ma_reg_atual[l_cont].campo_70) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 71 THEN
             IF ma_reg_anterior[l_index].campo_71 <> ma_reg_atual[l_cont].campo_71 OR
              ( ma_reg_anterior[l_index].campo_71 IS NULL AND ma_reg_atual[l_cont].campo_71 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_71 IS NOT NULL AND ma_reg_atual[l_cont].campo_71 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,71,
                  ma_reg_anterior[l_index].campo_71, ma_reg_atual[l_cont].campo_71) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 72 THEN
             IF ma_reg_anterior[l_index].campo_72 <> ma_reg_atual[l_cont].campo_72 OR
              ( ma_reg_anterior[l_index].campo_72 IS NULL AND ma_reg_atual[l_cont].campo_72 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_72 IS NOT NULL AND ma_reg_atual[l_cont].campo_72 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,72,
                  ma_reg_anterior[l_index].campo_72, ma_reg_atual[l_cont].campo_72) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 73 THEN
             IF ma_reg_anterior[l_index].campo_73 <> ma_reg_atual[l_cont].campo_73 OR
              ( ma_reg_anterior[l_index].campo_73 IS NULL AND ma_reg_atual[l_cont].campo_73 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_73 IS NOT NULL AND ma_reg_atual[l_cont].campo_73 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,73,
                  ma_reg_anterior[l_index].campo_73, ma_reg_atual[l_cont].campo_73) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 74 THEN
             IF ma_reg_anterior[l_index].campo_74 <> ma_reg_atual[l_cont].campo_74 OR
              ( ma_reg_anterior[l_index].campo_74 IS NULL AND ma_reg_atual[l_cont].campo_74 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_74 IS NOT NULL AND ma_reg_atual[l_cont].campo_74 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,74,
                  ma_reg_anterior[l_index].campo_74, ma_reg_atual[l_cont].campo_74) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 75 THEN
             IF ma_reg_anterior[l_index].campo_75 <> ma_reg_atual[l_cont].campo_75 OR
              ( ma_reg_anterior[l_index].campo_75 IS NULL AND ma_reg_atual[l_cont].campo_75 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_75 IS NOT NULL AND ma_reg_atual[l_cont].campo_75 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,75,
                  ma_reg_anterior[l_index].campo_75, ma_reg_atual[l_cont].campo_75) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 76 THEN
             IF ma_reg_anterior[l_index].campo_76 <> ma_reg_atual[l_cont].campo_76 OR
              ( ma_reg_anterior[l_index].campo_76 IS NULL AND ma_reg_atual[l_cont].campo_76 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_76 IS NOT NULL AND ma_reg_atual[l_cont].campo_76 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,76,
                  ma_reg_anterior[l_index].campo_76, ma_reg_atual[l_cont].campo_76) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 77 THEN
             IF ma_reg_anterior[l_index].campo_77 <> ma_reg_atual[l_cont].campo_77 OR
              ( ma_reg_anterior[l_index].campo_77 IS NULL AND ma_reg_atual[l_cont].campo_77 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_77 IS NOT NULL AND ma_reg_atual[l_cont].campo_77 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,77,
                  ma_reg_anterior[l_index].campo_77, ma_reg_atual[l_cont].campo_77) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 78 THEN
             IF ma_reg_anterior[l_index].campo_78 <> ma_reg_atual[l_cont].campo_78 OR
              ( ma_reg_anterior[l_index].campo_78 IS NULL AND ma_reg_atual[l_cont].campo_78 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_78 IS NOT NULL AND ma_reg_atual[l_cont].campo_78 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,78,
                  ma_reg_anterior[l_index].campo_78, ma_reg_atual[l_cont].campo_78) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 79 THEN
             IF ma_reg_anterior[l_index].campo_79 <> ma_reg_atual[l_cont].campo_79 OR
              ( ma_reg_anterior[l_index].campo_79 IS NULL AND ma_reg_atual[l_cont].campo_79 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_79 IS NOT NULL AND ma_reg_atual[l_cont].campo_79 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,79,
                  ma_reg_anterior[l_index].campo_79, ma_reg_atual[l_cont].campo_79) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 80 THEN
             IF ma_reg_anterior[l_index].campo_80 <> ma_reg_atual[l_cont].campo_80 OR
              ( ma_reg_anterior[l_index].campo_80 IS NULL AND ma_reg_atual[l_cont].campo_80 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_80 IS NOT NULL AND ma_reg_atual[l_cont].campo_80 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,80,
                  ma_reg_anterior[l_index].campo_80, ma_reg_atual[l_cont].campo_80) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 81 THEN
             IF ma_reg_anterior[l_index].campo_81 <> ma_reg_atual[l_cont].campo_81 OR
              ( ma_reg_anterior[l_index].campo_81 IS NULL AND ma_reg_atual[l_cont].campo_81 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_81 IS NOT NULL AND ma_reg_atual[l_cont].campo_81 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,81,
                  ma_reg_anterior[l_index].campo_81, ma_reg_atual[l_cont].campo_81) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 82 THEN
             IF ma_reg_anterior[l_index].campo_82 <> ma_reg_atual[l_cont].campo_82 OR
              ( ma_reg_anterior[l_index].campo_82 IS NULL AND ma_reg_atual[l_cont].campo_82 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_82 IS NOT NULL AND ma_reg_atual[l_cont].campo_82 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,82,
                  ma_reg_anterior[l_index].campo_82, ma_reg_atual[l_cont].campo_82) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 83 THEN
             IF ma_reg_anterior[l_index].campo_83 <> ma_reg_atual[l_cont].campo_83 OR
              ( ma_reg_anterior[l_index].campo_83 IS NULL AND ma_reg_atual[l_cont].campo_83 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_83 IS NOT NULL AND ma_reg_atual[l_cont].campo_83 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,83,
                  ma_reg_anterior[l_index].campo_83, ma_reg_atual[l_cont].campo_83) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 84 THEN
             IF ma_reg_anterior[l_index].campo_84 <> ma_reg_atual[l_cont].campo_84 OR
              ( ma_reg_anterior[l_index].campo_84 IS NULL AND ma_reg_atual[l_cont].campo_84 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_84 IS NOT NULL AND ma_reg_atual[l_cont].campo_84 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,84,
                  ma_reg_anterior[l_index].campo_84, ma_reg_atual[l_cont].campo_84) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 85 THEN
             IF ma_reg_anterior[l_index].campo_85 <> ma_reg_atual[l_cont].campo_85 OR
              ( ma_reg_anterior[l_index].campo_85 IS NULL AND ma_reg_atual[l_cont].campo_85 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_85 IS NOT NULL AND ma_reg_atual[l_cont].campo_85 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,85,
                  ma_reg_anterior[l_index].campo_85, ma_reg_atual[l_cont].campo_85) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 86 THEN
             IF ma_reg_anterior[l_index].campo_86 <> ma_reg_atual[l_cont].campo_86 OR
              ( ma_reg_anterior[l_index].campo_86 IS NULL AND ma_reg_atual[l_cont].campo_86 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_86 IS NOT NULL AND ma_reg_atual[l_cont].campo_86 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,86,
                  ma_reg_anterior[l_index].campo_86, ma_reg_atual[l_cont].campo_86) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 87 THEN
             IF ma_reg_anterior[l_index].campo_87 <> ma_reg_atual[l_cont].campo_87 OR
              ( ma_reg_anterior[l_index].campo_87 IS NULL AND ma_reg_atual[l_cont].campo_87 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_87 IS NOT NULL AND ma_reg_atual[l_cont].campo_87 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,87,
                  ma_reg_anterior[l_index].campo_87, ma_reg_atual[l_cont].campo_87) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 88 THEN
             IF ma_reg_anterior[l_index].campo_88 <> ma_reg_atual[l_cont].campo_88 OR
              ( ma_reg_anterior[l_index].campo_88 IS NULL AND ma_reg_atual[l_cont].campo_88 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_88 IS NOT NULL AND ma_reg_atual[l_cont].campo_88 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,88,
                  ma_reg_anterior[l_index].campo_88, ma_reg_atual[l_cont].campo_88) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 89 THEN
             IF ma_reg_anterior[l_index].campo_89 <> ma_reg_atual[l_cont].campo_89 OR
              ( ma_reg_anterior[l_index].campo_89 IS NULL AND ma_reg_atual[l_cont].campo_89 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_89 IS NOT NULL AND ma_reg_atual[l_cont].campo_89 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,89,
                  ma_reg_anterior[l_index].campo_89, ma_reg_atual[l_cont].campo_89) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 90 THEN
             IF ma_reg_anterior[l_index].campo_90 <> ma_reg_atual[l_cont].campo_90 OR
              ( ma_reg_anterior[l_index].campo_90 IS NULL AND ma_reg_atual[l_cont].campo_90 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_90 IS NOT NULL AND ma_reg_atual[l_cont].campo_90 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,90,
                  ma_reg_anterior[l_index].campo_90, ma_reg_atual[l_cont].campo_90) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 91 THEN
             IF ma_reg_anterior[l_index].campo_91 <> ma_reg_atual[l_cont].campo_91 OR
              ( ma_reg_anterior[l_index].campo_91 IS NULL AND ma_reg_atual[l_cont].campo_91 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_91 IS NOT NULL AND ma_reg_atual[l_cont].campo_91 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,91,
                  ma_reg_anterior[l_index].campo_91, ma_reg_atual[l_cont].campo_91) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 92 THEN
             IF ma_reg_anterior[l_index].campo_92 <> ma_reg_atual[l_cont].campo_92 OR
              ( ma_reg_anterior[l_index].campo_92 IS NULL AND ma_reg_atual[l_cont].campo_92 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_92 IS NOT NULL AND ma_reg_atual[l_cont].campo_92 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,92,
                  ma_reg_anterior[l_index].campo_92, ma_reg_atual[l_cont].campo_92) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 93 THEN
             IF ma_reg_anterior[l_index].campo_93 <> ma_reg_atual[l_cont].campo_93 OR
              ( ma_reg_anterior[l_index].campo_93 IS NULL AND ma_reg_atual[l_cont].campo_93 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_93 IS NOT NULL AND ma_reg_atual[l_cont].campo_93 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,93,
                  ma_reg_anterior[l_index].campo_93, ma_reg_atual[l_cont].campo_93) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 94 THEN
             IF ma_reg_anterior[l_index].campo_94 <> ma_reg_atual[l_cont].campo_94 OR
              ( ma_reg_anterior[l_index].campo_94 IS NULL AND ma_reg_atual[l_cont].campo_94 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_94 IS NOT NULL AND ma_reg_atual[l_cont].campo_94 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,94,
                  ma_reg_anterior[l_index].campo_94, ma_reg_atual[l_cont].campo_94) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 95 THEN
             IF ma_reg_anterior[l_index].campo_95 <> ma_reg_atual[l_cont].campo_95 OR
              ( ma_reg_anterior[l_index].campo_95 IS NULL AND ma_reg_atual[l_cont].campo_95 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_95 IS NOT NULL AND ma_reg_atual[l_cont].campo_95 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,95,
                  ma_reg_anterior[l_index].campo_95, ma_reg_atual[l_cont].campo_95) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 96 THEN
             IF ma_reg_anterior[l_index].campo_96 <> ma_reg_atual[l_cont].campo_96 OR
              ( ma_reg_anterior[l_index].campo_96 IS NULL AND ma_reg_atual[l_cont].campo_96 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_96 IS NOT NULL AND ma_reg_atual[l_cont].campo_96 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,96,
                  ma_reg_anterior[l_index].campo_96, ma_reg_atual[l_cont].campo_96) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 97 THEN
             IF ma_reg_anterior[l_index].campo_97 <> ma_reg_atual[l_cont].campo_97 OR
              ( ma_reg_anterior[l_index].campo_97 IS NULL AND ma_reg_atual[l_cont].campo_97 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_97 IS NOT NULL AND ma_reg_atual[l_cont].campo_97 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,97,
                  ma_reg_anterior[l_index].campo_97, ma_reg_atual[l_cont].campo_97) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 98 THEN
             IF ma_reg_anterior[l_index].campo_98 <> ma_reg_atual[l_cont].campo_98 OR
              ( ma_reg_anterior[l_index].campo_98 IS NULL AND ma_reg_atual[l_cont].campo_98 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_98 IS NOT NULL AND ma_reg_atual[l_cont].campo_98 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,98,
                  ma_reg_anterior[l_index].campo_98, ma_reg_atual[l_cont].campo_98) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 99 THEN
             IF ma_reg_anterior[l_index].campo_99 <> ma_reg_atual[l_cont].campo_99 OR
              ( ma_reg_anterior[l_index].campo_99 IS NULL AND ma_reg_atual[l_cont].campo_99 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_99 IS NOT NULL AND ma_reg_atual[l_cont].campo_99 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,99,
                  ma_reg_anterior[l_index].campo_99, ma_reg_atual[l_cont].campo_99) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 100 THEN
             IF ma_reg_anterior[l_index].campo_100 <> ma_reg_atual[l_cont].campo_100 OR
              ( ma_reg_anterior[l_index].campo_100 IS NULL AND ma_reg_atual[l_cont].campo_100 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_100 IS NOT NULL AND ma_reg_atual[l_cont].campo_100 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,100,
                  ma_reg_anterior[l_index].campo_100, ma_reg_atual[l_cont].campo_100) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 101 THEN
             IF ma_reg_anterior[l_index].campo_101 <> ma_reg_atual[l_cont].campo_101 OR
              ( ma_reg_anterior[l_index].campo_101 IS NULL AND ma_reg_atual[l_cont].campo_101 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_101 IS NOT NULL AND ma_reg_atual[l_cont].campo_101 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,101,
                  ma_reg_anterior[l_index].campo_101, ma_reg_atual[l_cont].campo_101) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 102 THEN
             IF ma_reg_anterior[l_index].campo_102 <> ma_reg_atual[l_cont].campo_102 OR
              ( ma_reg_anterior[l_index].campo_102 IS NULL AND ma_reg_atual[l_cont].campo_102 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_102 IS NOT NULL AND ma_reg_atual[l_cont].campo_102 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,102,
                  ma_reg_anterior[l_index].campo_102, ma_reg_atual[l_cont].campo_102) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 103 THEN
             IF ma_reg_anterior[l_index].campo_103 <> ma_reg_atual[l_cont].campo_103 OR
              ( ma_reg_anterior[l_index].campo_103 IS NULL AND ma_reg_atual[l_cont].campo_103 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_103 IS NOT NULL AND ma_reg_atual[l_cont].campo_103 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,103,
                  ma_reg_anterior[l_index].campo_103, ma_reg_atual[l_cont].campo_103) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 104 THEN
             IF ma_reg_anterior[l_index].campo_104 <> ma_reg_atual[l_cont].campo_104 OR
              ( ma_reg_anterior[l_index].campo_104 IS NULL AND ma_reg_atual[l_cont].campo_104 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_104 IS NOT NULL AND ma_reg_atual[l_cont].campo_104 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,104,
                  ma_reg_anterior[l_index].campo_104, ma_reg_atual[l_cont].campo_104) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 105 THEN
             IF ma_reg_anterior[l_index].campo_105 <> ma_reg_atual[l_cont].campo_105 OR
              ( ma_reg_anterior[l_index].campo_105 IS NULL AND ma_reg_atual[l_cont].campo_105 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_105 IS NOT NULL AND ma_reg_atual[l_cont].campo_105 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,105,
                  ma_reg_anterior[l_index].campo_105, ma_reg_atual[l_cont].campo_105) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 106 THEN
             IF ma_reg_anterior[l_index].campo_106 <> ma_reg_atual[l_cont].campo_106 OR
              ( ma_reg_anterior[l_index].campo_106 IS NULL AND ma_reg_atual[l_cont].campo_106 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_106 IS NOT NULL AND ma_reg_atual[l_cont].campo_106 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,106,
                  ma_reg_anterior[l_index].campo_106, ma_reg_atual[l_cont].campo_106) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 107 THEN
             IF ma_reg_anterior[l_index].campo_107 <> ma_reg_atual[l_cont].campo_107 OR
              ( ma_reg_anterior[l_index].campo_107 IS NULL AND ma_reg_atual[l_cont].campo_107 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_107 IS NOT NULL AND ma_reg_atual[l_cont].campo_107 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,107,
                  ma_reg_anterior[l_index].campo_107, ma_reg_atual[l_cont].campo_107) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 108 THEN
             IF ma_reg_anterior[l_index].campo_108 <> ma_reg_atual[l_cont].campo_108 OR
              ( ma_reg_anterior[l_index].campo_108 IS NULL AND ma_reg_atual[l_cont].campo_108 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_108 IS NOT NULL AND ma_reg_atual[l_cont].campo_108 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,108,
                  ma_reg_anterior[l_index].campo_108, ma_reg_atual[l_cont].campo_108) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 109 THEN
             IF ma_reg_anterior[l_index].campo_109 <> ma_reg_atual[l_cont].campo_109 OR
              ( ma_reg_anterior[l_index].campo_109 IS NULL AND ma_reg_atual[l_cont].campo_109 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_109 IS NOT NULL AND ma_reg_atual[l_cont].campo_109 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,109,
                  ma_reg_anterior[l_index].campo_109, ma_reg_atual[l_cont].campo_109) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 110 THEN
             IF ma_reg_anterior[l_index].campo_110 <> ma_reg_atual[l_cont].campo_110 OR
              ( ma_reg_anterior[l_index].campo_110 IS NULL AND ma_reg_atual[l_cont].campo_110 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_110 IS NOT NULL AND ma_reg_atual[l_cont].campo_110 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,110,
                  ma_reg_anterior[l_index].campo_110, ma_reg_atual[l_cont].campo_110) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 111 THEN
             IF ma_reg_anterior[l_index].campo_111 <> ma_reg_atual[l_cont].campo_111 OR
              ( ma_reg_anterior[l_index].campo_111 IS NULL AND ma_reg_atual[l_cont].campo_111 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_111 IS NOT NULL AND ma_reg_atual[l_cont].campo_111 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,111,
                  ma_reg_anterior[l_index].campo_111, ma_reg_atual[l_cont].campo_111) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 112 THEN
             IF ma_reg_anterior[l_index].campo_112 <> ma_reg_atual[l_cont].campo_112 OR
              ( ma_reg_anterior[l_index].campo_112 IS NULL AND ma_reg_atual[l_cont].campo_112 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_112 IS NOT NULL AND ma_reg_atual[l_cont].campo_112 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,112,
                  ma_reg_anterior[l_index].campo_112, ma_reg_atual[l_cont].campo_112) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 113 THEN
             IF ma_reg_anterior[l_index].campo_113 <> ma_reg_atual[l_cont].campo_113 OR
              ( ma_reg_anterior[l_index].campo_113 IS NULL AND ma_reg_atual[l_cont].campo_113 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_113 IS NOT NULL AND ma_reg_atual[l_cont].campo_113 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,113,
                  ma_reg_anterior[l_index].campo_113, ma_reg_atual[l_cont].campo_113) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 114 THEN
             IF ma_reg_anterior[l_index].campo_114 <> ma_reg_atual[l_cont].campo_114 OR
              ( ma_reg_anterior[l_index].campo_114 IS NULL AND ma_reg_atual[l_cont].campo_114 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_114 IS NOT NULL AND ma_reg_atual[l_cont].campo_114 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,114,
                  ma_reg_anterior[l_index].campo_114, ma_reg_atual[l_cont].campo_114) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 115 THEN
             IF ma_reg_anterior[l_index].campo_115 <> ma_reg_atual[l_cont].campo_115 OR
              ( ma_reg_anterior[l_index].campo_115 IS NULL AND ma_reg_atual[l_cont].campo_115 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_115 IS NOT NULL AND ma_reg_atual[l_cont].campo_115 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,115,
                  ma_reg_anterior[l_index].campo_115, ma_reg_atual[l_cont].campo_115) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 116 THEN
             IF ma_reg_anterior[l_index].campo_116 <> ma_reg_atual[l_cont].campo_116 OR
              ( ma_reg_anterior[l_index].campo_116 IS NULL AND ma_reg_atual[l_cont].campo_116 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_116 IS NOT NULL AND ma_reg_atual[l_cont].campo_116 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,116,
                  ma_reg_anterior[l_index].campo_116, ma_reg_atual[l_cont].campo_116) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 117 THEN
             IF ma_reg_anterior[l_index].campo_117 <> ma_reg_atual[l_cont].campo_117 OR
              ( ma_reg_anterior[l_index].campo_117 IS NULL AND ma_reg_atual[l_cont].campo_117 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_117 IS NOT NULL AND ma_reg_atual[l_cont].campo_117 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,117,
                  ma_reg_anterior[l_index].campo_117, ma_reg_atual[l_cont].campo_117) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 118 THEN
             IF ma_reg_anterior[l_index].campo_118 <> ma_reg_atual[l_cont].campo_118 OR
              ( ma_reg_anterior[l_index].campo_118 IS NULL AND ma_reg_atual[l_cont].campo_118 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_118 IS NOT NULL AND ma_reg_atual[l_cont].campo_118 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,118,
                  ma_reg_anterior[l_index].campo_118, ma_reg_atual[l_cont].campo_118) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 119 THEN
             IF ma_reg_anterior[l_index].campo_119 <> ma_reg_atual[l_cont].campo_119 OR
              ( ma_reg_anterior[l_index].campo_119 IS NULL AND ma_reg_atual[l_cont].campo_119 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_119 IS NOT NULL AND ma_reg_atual[l_cont].campo_119 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,119,
                  ma_reg_anterior[l_index].campo_119, ma_reg_atual[l_cont].campo_119) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 120 THEN
             IF ma_reg_anterior[l_index].campo_120 <> ma_reg_atual[l_cont].campo_120 OR
              ( ma_reg_anterior[l_index].campo_120 IS NULL AND ma_reg_atual[l_cont].campo_120 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_120 IS NOT NULL AND ma_reg_atual[l_cont].campo_120 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,120,
                  ma_reg_anterior[l_index].campo_120, ma_reg_atual[l_cont].campo_120) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 121 THEN
             IF ma_reg_anterior[l_index].campo_121 <> ma_reg_atual[l_cont].campo_121 OR
              ( ma_reg_anterior[l_index].campo_121 IS NULL AND ma_reg_atual[l_cont].campo_121 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_121 IS NOT NULL AND ma_reg_atual[l_cont].campo_121 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,121,
                  ma_reg_anterior[l_index].campo_121, ma_reg_atual[l_cont].campo_121) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 122 THEN
             IF ma_reg_anterior[l_index].campo_122 <> ma_reg_atual[l_cont].campo_122 OR
              ( ma_reg_anterior[l_index].campo_122 IS NULL AND ma_reg_atual[l_cont].campo_122 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_122 IS NOT NULL AND ma_reg_atual[l_cont].campo_122 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,122,
                  ma_reg_anterior[l_index].campo_122, ma_reg_atual[l_cont].campo_122) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 123 THEN
             IF ma_reg_anterior[l_index].campo_123 <> ma_reg_atual[l_cont].campo_123 OR
              ( ma_reg_anterior[l_index].campo_123 IS NULL AND ma_reg_atual[l_cont].campo_123 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_123 IS NOT NULL AND ma_reg_atual[l_cont].campo_123 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,123,
                  ma_reg_anterior[l_index].campo_123, ma_reg_atual[l_cont].campo_123) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 124 THEN
             IF ma_reg_anterior[l_index].campo_124 <> ma_reg_atual[l_cont].campo_124 OR
              ( ma_reg_anterior[l_index].campo_124 IS NULL AND ma_reg_atual[l_cont].campo_124 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_124 IS NOT NULL AND ma_reg_atual[l_cont].campo_124 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,124,
                  ma_reg_anterior[l_index].campo_124, ma_reg_atual[l_cont].campo_124) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 125 THEN
             IF ma_reg_anterior[l_index].campo_125 <> ma_reg_atual[l_cont].campo_125 OR
              ( ma_reg_anterior[l_index].campo_125 IS NULL AND ma_reg_atual[l_cont].campo_125 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_125 IS NOT NULL AND ma_reg_atual[l_cont].campo_125 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,125,
                  ma_reg_anterior[l_index].campo_125, ma_reg_atual[l_cont].campo_125) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 126 THEN
             IF ma_reg_anterior[l_index].campo_126 <> ma_reg_atual[l_cont].campo_126 OR
              ( ma_reg_anterior[l_index].campo_126 IS NULL AND ma_reg_atual[l_cont].campo_126 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_126 IS NOT NULL AND ma_reg_atual[l_cont].campo_126 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,126,
                  ma_reg_anterior[l_index].campo_126, ma_reg_atual[l_cont].campo_126) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 127 THEN
             IF ma_reg_anterior[l_index].campo_127 <> ma_reg_atual[l_cont].campo_127 OR
              ( ma_reg_anterior[l_index].campo_127 IS NULL AND ma_reg_atual[l_cont].campo_127 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_127 IS NOT NULL AND ma_reg_atual[l_cont].campo_127 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,127,
                  ma_reg_anterior[l_index].campo_127, ma_reg_atual[l_cont].campo_127) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 128 THEN
             IF ma_reg_anterior[l_index].campo_128 <> ma_reg_atual[l_cont].campo_128 OR
              ( ma_reg_anterior[l_index].campo_128 IS NULL AND ma_reg_atual[l_cont].campo_128 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_128 IS NOT NULL AND ma_reg_atual[l_cont].campo_128 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,128,
                  ma_reg_anterior[l_index].campo_128, ma_reg_atual[l_cont].campo_128) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 129 THEN
             IF ma_reg_anterior[l_index].campo_129 <> ma_reg_atual[l_cont].campo_129 OR
              ( ma_reg_anterior[l_index].campo_129 IS NULL AND ma_reg_atual[l_cont].campo_129 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_129 IS NOT NULL AND ma_reg_atual[l_cont].campo_129 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,129,
                  ma_reg_anterior[l_index].campo_129, ma_reg_atual[l_cont].campo_129) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

            IF l_total_colunas >= 130 THEN
             IF ma_reg_anterior[l_index].campo_130 <> ma_reg_atual[l_cont].campo_130 OR
              ( ma_reg_anterior[l_index].campo_130 IS NULL AND ma_reg_atual[l_cont].campo_130 IS NOT NULL ) OR
              ( ma_reg_anterior[l_index].campo_130 IS NOT NULL AND ma_reg_atual[l_cont].campo_130 IS NULL ) THEN
              IF NOT cdv0801_grava_auditoria(ma_rowid[l_cont], l_tabela,l_programa,130,
                  ma_reg_anterior[l_index].campo_130, ma_reg_atual[l_cont].campo_130) THEN
               RETURN FALSE
              END IF
             END IF
            ELSE
             CONTINUE FOR
            END IF

        END IF
     END FOR
 END FOR

 # Os registros que sobraram (<> NULL) no array ma_chave_reg_anterior são os que foram excluidos...
 # Grava auditoria de exclusão para esses registros
 FOR l_index = 1 TO 1000
     IF ma_chave_reg_anterior[l_index] IS NULL THEN
      CONTINUE FOR
     END IF

     LET mr_cdv_auditoria_781.empresa           = m_cod_empresa
     LET mr_cdv_auditoria_781.usuario           = p_user
     LET mr_cdv_auditoria_781.programa          = l_programa
     LET mr_cdv_auditoria_781.tip_manut         = 'E'
     LET mr_cdv_auditoria_781.nom_tabela        = l_tabela
     LET mr_cdv_auditoria_781.nom_campo         = NULL
     LET mr_cdv_auditoria_781.val_ant           = NULL
     LET mr_cdv_auditoria_781.val_atual         = NULL
     LET mr_cdv_auditoria_781.chave_registro    = ma_chave_reg_anterior[l_index]
     LET mr_cdv_auditoria_781.txt_processamento = NULL

     IF NOT cdv0801_insere_audit() THEN
        RETURN FALSE
     END IF

 END FOR

 # Os registros que sobraram (<> NULL) no array ma_chave_reg_atual são os que foram inseridos...
 # Grava auditoria de inserção para esses registros
 FOR l_index = 1 TO 1000
     IF ma_chave_reg_atual[l_index] IS NULL THEN
      CONTINUE FOR
     END IF

     INITIALIZE mr_cdv_auditoria_781.* TO NULL

     LET mr_cdv_auditoria_781.empresa           = m_cod_empresa
     LET mr_cdv_auditoria_781.usuario           = p_user
     LET mr_cdv_auditoria_781.programa          = l_programa
     LET mr_cdv_auditoria_781.tip_manut         = 'I'
     LET mr_cdv_auditoria_781.nom_tabela        = l_tabela
     LET mr_cdv_auditoria_781.nom_campo         = NULL
     LET mr_cdv_auditoria_781.val_ant           = NULL
     LET mr_cdv_auditoria_781.val_atual         = NULL
     LET mr_cdv_auditoria_781.chave_registro    = ma_chave_reg_atual[l_index]
     LET mr_cdv_auditoria_781.txt_processamento = NULL

     IF NOT cdv0801_insere_audit() THEN
        RETURN FALSE
     END IF

 END FOR

 RETURN TRUE

 END FUNCTION

#----------------------------------------------------------------------------------------------------#
 FUNCTION cdv0801_grava_auditoria(l_rowid, l_tabela, l_programa, l_num_col, l_val_ant, l_val_atual)
#----------------------------------------------------------------------------------------------------#
 DEFINE l_rowid          CHAR(30),
        l_tabela         CHAR(18),
        l_programa       CHAR(08),
        l_num_col        SMALLINT,
        l_val_ant        CHAR(250),
        l_val_atual      CHAR(250),
        l_nom_campo      CHAR(18),
        l_chave_registro CHAR(250)

 LET l_tabela = DOWNSHIFT(l_tabela)

 WHENEVER ERROR CONTINUE
  SELECT syscolumns.colname
    INTO l_nom_campo
    FROM systables, syscolumns
   WHERE systables.tabname = l_tabela
     AND syscolumns.tabid  = systables.tabid
     AND syscolumns.colno  = l_num_col
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql('LEITURA','syscolumns')
    RETURN FALSE
 END IF

 CALL cdv0801_gera_chave_tabela(l_tabela, l_rowid) RETURNING l_chave_registro

 INITIALIZE mr_cdv_auditoria_781.* TO NULL

 LET mr_cdv_auditoria_781.empresa           = m_cod_empresa
 LET mr_cdv_auditoria_781.usuario           = p_user
 LET mr_cdv_auditoria_781.programa          = l_programa
 LET mr_cdv_auditoria_781.tip_manut         = 'M'
 LET mr_cdv_auditoria_781.nom_tabela        = l_tabela
 LET mr_cdv_auditoria_781.nom_campo         = l_nom_campo
 LET mr_cdv_auditoria_781.val_ant           = l_val_ant
 LET mr_cdv_auditoria_781.val_atual         = l_val_atual
 LET mr_cdv_auditoria_781.chave_registro    = l_chave_registro
 LET mr_cdv_auditoria_781.txt_processamento = NULL

 IF cdv0801_insere_audit() THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#-----------------------------------------------------------------------#
 FUNCTION cdv0801_exclusao_auditoria(l_tabela,l_where_clause,l_programa)
#-----------------------------------------------------------------------#
 DEFINE l_tabela          CHAR(18),
        l_where_clause    CHAR(2000),
        l_programa        CHAR(08),
        l_rowid           CHAR(30),
        l_chave_registro  CHAR(250)

 LET sql_stmt = "SELECT rowid ",
       " FROM ",  l_tabela CLIPPED ,
       " WHERE ", l_where_clause CLIPPED

 WHENEVER ERROR CONTINUE
  PREPARE var_query_3 FROM sql_stmt
  DECLARE cq_exclusao CURSOR FOR var_query_3
 WHENEVER ERROR STOP

 FOREACH cq_exclusao INTO l_rowid
    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("CQ_EXCLUSAO","FOREACH")
       EXIT FOREACH
   END IF

   CALL cdv0801_gera_chave_tabela(l_tabela, l_rowid) RETURNING l_chave_registro

   LET mr_cdv_auditoria_781.empresa           = m_cod_empresa
   LET mr_cdv_auditoria_781.usuario           = p_user
   LET mr_cdv_auditoria_781.programa          = l_programa
   LET mr_cdv_auditoria_781.tip_manut         = 'E'
   LET mr_cdv_auditoria_781.nom_tabela        = l_tabela
   LET mr_cdv_auditoria_781.nom_campo         = NULL
   LET mr_cdv_auditoria_781.val_ant           = NULL
   LET mr_cdv_auditoria_781.val_atual         = NULL
   LET mr_cdv_auditoria_781.chave_registro    = l_chave_registro
   LET mr_cdv_auditoria_781.txt_processamento = NULL

   IF NOT cdv0801_insere_audit() THEN
      RETURN FALSE
   END IF

 END FOREACH
 WHENEVER ERROR CONTINUE
  FREE cq_exclusao
 WHENEVER ERROR STOP

 RETURN TRUE

 END FUNCTION

#-------------------------------------------------------------#
 FUNCTION cdv0801_processo_auditoria(l_where_clause,l_programa)
#-------------------------------------------------------------#
 DEFINE l_where_clause CHAR(2000),
        l_programa     CHAR(08)

 LET mr_cdv_auditoria_781.empresa           = m_cod_empresa
 LET mr_cdv_auditoria_781.usuario           = p_user
 LET mr_cdv_auditoria_781.programa          = l_programa
 LET mr_cdv_auditoria_781.tip_manut         = 'P'
 LET mr_cdv_auditoria_781.nom_tabela        = NULL
 LET mr_cdv_auditoria_781.nom_campo         = NULL
 LET mr_cdv_auditoria_781.val_ant           = NULL
 LET mr_cdv_auditoria_781.val_atual         = NULL
 LET mr_cdv_auditoria_781.chave_registro    = NULL
 LET mr_cdv_auditoria_781.txt_processamento = l_where_clause

 IF cdv0801_insere_audit() THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv0801_gera_chave_tabela(l_tabela, l_rowid)
#-----------------------------------------------------#
 DEFINE l_tabela           CHAR(18),
        l_rowid            CHAR(30),
        l_coluna_chave     CHAR(18),
        l_campos           CHAR(4500),
        l_chave_registro   CHAR(250),
        l_chave_registro_2 CHAR(250),
        l_cont             SMALLINT

  DEFINE la_chave_tabela  ARRAY[1000] OF RECORD
            campo_1  CHAR(250),
            campo_2  CHAR(250),
            campo_3  CHAR(250),
            campo_4  CHAR(250),
            campo_5  CHAR(250),
            campo_6  CHAR(250),
            campo_7  CHAR(250),
            campo_8  CHAR(250),
            campo_9  CHAR(250),
            campo_10 CHAR(250),
            campo_11 CHAR(250),
            campo_12 CHAR(250),
            campo_13 CHAR(250),
            campo_14 CHAR(250),
            campo_15 CHAR(250),
            campo_16 CHAR(250)
           END RECORD

 INITIALIZE l_coluna_chave, l_campos, l_chave_registro, l_chave_registro_2 TO NULL
 INITIALIZE la_chave_tabela TO NULL

 LET sql_stmt = "SELECT syscolumns.colname ",
    "  FROM systables, sysconstraints, syscoldepend, syscolumns, sysindexes ",
    " WHERE systables.tabname   = '", DOWNSHIFT(l_tabela), "' ",
    "   AND sysconstraints.tabid   = systables.tabid",
    "   AND sysconstraints.constrtype = 'P' ",
    "   AND syscoldepend.tabid  = systables.tabid ",
    "   AND syscolumns.tabid    = systables.tabid ",
    "   AND syscolumns.colno    = syscoldepend.colno ",
    "   AND sysindexes.tabid    = syscolumns.tabid ",
    "   AND sysindexes.idxtype  = 'U' ",
    "   AND syscolumns.colno  IN (sysindexes.part1, sysindexes.part2, ",
    "        sysindexes.part3, sysindexes.part4, ",
    "        sysindexes.part5, sysindexes.part6, ",
    "        sysindexes.part7, sysindexes.part8, ",
    "        sysindexes.part9, sysindexes.part10,",
    "        sysindexes.part11, sysindexes.part12,",
    "        sysindexes.part13, sysindexes.part14,",
    "        sysindexes.part15, sysindexes.part16)"

 WHENEVER ERROR CONTINUE
 PREPARE var_campos_chave2 FROM sql_stmt
 DECLARE cq_campos_chave_2 CURSOR FOR var_campos_chave2
 WHENEVER ERROR STOP

 FOREACH cq_campos_chave_2 INTO l_coluna_chave
    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("CQ_CAMPOS_CHAVE_2","FOREACH")
       EXIT FOREACH
    END IF

    IF l_coluna_chave IS NOT NULL THEN
       IF l_campos IS NULL THEN
          LET l_campos = l_coluna_chave CLIPPED
       ELSE
          LET l_campos = l_campos CLIPPED, ", ", l_coluna_chave CLIPPED
       END IF
    END IF

 END FOREACH

 WHENEVER ERROR CONTINUE
  FREE cq_campos_chave_2
 WHENEVER ERROR STOP

 LET l_cont = 1

 LET sql_stmt = "SELECT ", l_campos CLIPPED,
           " FROM " , l_tabela CLIPPED ,
          " WHERE rowid = ", l_rowid

 WHENEVER ERROR CONTINUE
 PREPARE var_query_4 FROM sql_stmt
 DECLARE cq_inclusao CURSOR FOR var_query_4
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
 END IF

 WHENEVER ERROR CONTINUE
 OPEN  cq_inclusao
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
 END IF

 WHENEVER ERROR CONTINUE
 FETCH cq_inclusao INTO la_chave_tabela[l_cont].*
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
 END IF

 WHENEVER ERROR CONTINUE
 CLOSE cq_inclusao
 WHENEVER ERROR STOP

 INITIALIZE l_chave_registro, l_chave_registro_2 TO NULL

 LET l_chave_registro = la_chave_tabela[l_cont].campo_1 CLIPPED, "|", la_chave_tabela[l_cont].campo_2 CLIPPED, "|",
     la_chave_tabela[l_cont].campo_3 CLIPPED,  "|", la_chave_tabela[l_cont].campo_4 CLIPPED, "|",
     la_chave_tabela[l_cont].campo_5 CLIPPED,  "|", la_chave_tabela[l_cont].campo_6 CLIPPED, "|",
     la_chave_tabela[l_cont].campo_7 CLIPPED,  "|", la_chave_tabela[l_cont].campo_8 CLIPPED, "|",
     la_chave_tabela[l_cont].campo_9 CLIPPED,  "|", la_chave_tabela[l_cont].campo_10 CLIPPED, "|",
     la_chave_tabela[l_cont].campo_11 CLIPPED, "|", la_chave_tabela[l_cont].campo_12 CLIPPED, "|",
     la_chave_tabela[l_cont].campo_13 CLIPPED, "|", la_chave_tabela[l_cont].campo_14 CLIPPED, "|",
     la_chave_tabela[l_cont].campo_15 CLIPPED, "|", la_chave_tabela[l_cont].campo_16 CLIPPED, "|"

 FOR l_cont = 1 TO 249
     IF l_chave_registro[l_cont,l_cont] = '|' AND
        l_chave_registro[l_cont+1,l_cont+1] = '|' THEN
         LET l_chave_registro_2 = l_chave_registro[1,l_cont]
         EXIT FOR
     END IF
 END FOR

 RETURN l_chave_registro_2

 END FUNCTION

#------------------------------#
 FUNCTION cdv0801_insere_audit()
#------------------------------#
 DEFINE l_segundos   CHAR(2)
 DEFINE l_max        LIKE cdv_auditoria_781.seq_auditoria

 LET mr_cdv_auditoria_781.dat_manut = EXTEND(CURRENT, YEAR TO DAY)
 LET mr_cdv_auditoria_781.hor_manut = EXTEND(CURRENT, hour TO second)

 # Algumas vezes o processamento é muito rápido e ocorre no mesmo segundo.
 # A lógica abaixo atualiza o segundo para não dar erro de chave duplicada.
 LET l_segundos = EXTEND(CURRENT, second TO second)
 LET l_segundos = l_segundos + m_cont
 LET m_cont    = m_cont + 1

 LET mr_cdv_auditoria_781.hor_manut = mr_cdv_auditoria_781.hor_manut[1,6] CLIPPED, l_segundos USING '&&'

 INITIALIZE l_max TO NULL

 WHENEVER ERROR CONTINUE
 SELECT MAX(seq_auditoria) + 1
   INTO l_max
   FROM cdv_auditoria_781
  WHERE empresa   = mr_cdv_auditoria_781.empresa
    AND usuario   = mr_cdv_auditoria_781.usuario
    AND programa  = mr_cdv_auditoria_781.programa
    AND tip_manut = mr_cdv_auditoria_781.tip_manut
    AND dat_manut = mr_cdv_auditoria_781.dat_manut
    AND hor_manut = mr_cdv_auditoria_781.hor_manut
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql('LEITURA','cdv_auditoria_781')
    RETURN FALSE
 END IF

 IF l_max IS NULL THEN
    LET l_max = 1
 END IF

 LET mr_cdv_auditoria_781.seq_auditoria = l_max

 WHENEVER ERROR CONTINUE
 INSERT INTO cdv_auditoria_781 (empresa, usuario, programa, tip_manut,
                                dat_manut, hor_manut, seq_auditoria, nom_tabela,
                                nom_campo, val_ant, val_atual, chave_registro,
                                txt_processamento)
                        VALUES (mr_cdv_auditoria_781.empresa,
                                mr_cdv_auditoria_781.usuario,
                                mr_cdv_auditoria_781.programa,
                                mr_cdv_auditoria_781.tip_manut,
                                mr_cdv_auditoria_781.dat_manut,
                                mr_cdv_auditoria_781.hor_manut,
                                mr_cdv_auditoria_781.seq_auditoria,
                                mr_cdv_auditoria_781.nom_tabela,
                                mr_cdv_auditoria_781.nom_campo,
                                mr_cdv_auditoria_781.val_ant,
                                mr_cdv_auditoria_781.val_atual,
                                mr_cdv_auditoria_781.chave_registro,
                                mr_cdv_auditoria_781.txt_processamento)
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql('INCLUSÃO','cdv_auditoria_781')
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#-----------------------------------------------------#
FUNCTION cdv0801_rowid(l_tabela, l_where_clause)      #
#-----------------------------------------------------#
# Retorna o primeiro rowid encontrado na where clause #
#-----------------------------------------------------#
 DEFINE l_tabela       CHAR(18),
     l_where_clause CHAR(2000),
     l_rowid        char(30)

 INITIALIZE l_rowid TO NULL

	LET sql_stmt = "SELECT ",l_tabela CLIPPED ,".rowid ",
	                 "FROM ",  l_tabela, " ",
	                "WHERE ", l_where_clause CLIPPED

 WHENEVER ERROR CONTINUE
 PREPARE var_rowid FROM sql_stmt
 DECLARE cq_rowid CURSOR FOR var_rowid
 WHENEVER ERROR STOP

 FOREACH cq_rowid INTO l_rowid
    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("CQ_ROWID","FOREACH")
       EXIT FOREACH
    END IF
    RETURN l_rowid
 END FOREACH

 WHENEVER ERROR CONTINUE
 FREE cq_rowid
 WHENEVER ERROR STOP

 RETURN l_rowid

END FUNCTION

#-------------------------------------------#
FUNCTION cdv0801_valor_campo(l_linha, l_campo)
#-------------------------------------------#
 DEFINE l_linha SMALLINT
 DEFINE l_campo SMALLINT

 CASE l_campo
  WHEN 1   RETURN ma_reg_anterior[l_linha].campo_1
  WHEN 2   RETURN ma_reg_anterior[l_linha].campo_2
  WHEN 3   RETURN ma_reg_anterior[l_linha].campo_3
  WHEN 4   RETURN ma_reg_anterior[l_linha].campo_4
  WHEN 5   RETURN ma_reg_anterior[l_linha].campo_5
  WHEN 6   RETURN ma_reg_anterior[l_linha].campo_6
  WHEN 7   RETURN ma_reg_anterior[l_linha].campo_7
  WHEN 8   RETURN ma_reg_anterior[l_linha].campo_8
  WHEN 9   RETURN ma_reg_anterior[l_linha].campo_9
  WHEN 10  RETURN ma_reg_anterior[l_linha].campo_10
  WHEN 11  RETURN ma_reg_anterior[l_linha].campo_11
  WHEN 12  RETURN ma_reg_anterior[l_linha].campo_12
  WHEN 13  RETURN ma_reg_anterior[l_linha].campo_13
  WHEN 14  RETURN ma_reg_anterior[l_linha].campo_14
  WHEN 15  RETURN ma_reg_anterior[l_linha].campo_15
  WHEN 16  RETURN ma_reg_anterior[l_linha].campo_16
  WHEN 17  RETURN ma_reg_anterior[l_linha].campo_17
  WHEN 18  RETURN ma_reg_anterior[l_linha].campo_18
  WHEN 19  RETURN ma_reg_anterior[l_linha].campo_19
  WHEN 20  RETURN ma_reg_anterior[l_linha].campo_20
  WHEN 21  RETURN ma_reg_anterior[l_linha].campo_21
  WHEN 22  RETURN ma_reg_anterior[l_linha].campo_22
  WHEN 23  RETURN ma_reg_anterior[l_linha].campo_23
  WHEN 24  RETURN ma_reg_anterior[l_linha].campo_24
  WHEN 25  RETURN ma_reg_anterior[l_linha].campo_25
  WHEN 26  RETURN ma_reg_anterior[l_linha].campo_26
  WHEN 27  RETURN ma_reg_anterior[l_linha].campo_27
  WHEN 28  RETURN ma_reg_anterior[l_linha].campo_28
  WHEN 29  RETURN ma_reg_anterior[l_linha].campo_29
  WHEN 30  RETURN ma_reg_anterior[l_linha].campo_30
  WHEN 31  RETURN ma_reg_anterior[l_linha].campo_31
  WHEN 32  RETURN ma_reg_anterior[l_linha].campo_32
  WHEN 33  RETURN ma_reg_anterior[l_linha].campo_33
  WHEN 34  RETURN ma_reg_anterior[l_linha].campo_34
  WHEN 35  RETURN ma_reg_anterior[l_linha].campo_35
  WHEN 36  RETURN ma_reg_anterior[l_linha].campo_36
  WHEN 37  RETURN ma_reg_anterior[l_linha].campo_37
  WHEN 38  RETURN ma_reg_anterior[l_linha].campo_38
  WHEN 39  RETURN ma_reg_anterior[l_linha].campo_39
  WHEN 40  RETURN ma_reg_anterior[l_linha].campo_40
  WHEN 41  RETURN ma_reg_anterior[l_linha].campo_41
  WHEN 42  RETURN ma_reg_anterior[l_linha].campo_42
  WHEN 43  RETURN ma_reg_anterior[l_linha].campo_43
  WHEN 44  RETURN ma_reg_anterior[l_linha].campo_44
  WHEN 45  RETURN ma_reg_anterior[l_linha].campo_45
  WHEN 46  RETURN ma_reg_anterior[l_linha].campo_46
  WHEN 47  RETURN ma_reg_anterior[l_linha].campo_47
  WHEN 48  RETURN ma_reg_anterior[l_linha].campo_48
  WHEN 49  RETURN ma_reg_anterior[l_linha].campo_49
  WHEN 50  RETURN ma_reg_anterior[l_linha].campo_50
  WHEN 51  RETURN ma_reg_anterior[l_linha].campo_51
  WHEN 52  RETURN ma_reg_anterior[l_linha].campo_52
  WHEN 53  RETURN ma_reg_anterior[l_linha].campo_53
  WHEN 54  RETURN ma_reg_anterior[l_linha].campo_54
  WHEN 55  RETURN ma_reg_anterior[l_linha].campo_55
  WHEN 56  RETURN ma_reg_anterior[l_linha].campo_56
  WHEN 57  RETURN ma_reg_anterior[l_linha].campo_57
  WHEN 58  RETURN ma_reg_anterior[l_linha].campo_58
  WHEN 59  RETURN ma_reg_anterior[l_linha].campo_59
  WHEN 60  RETURN ma_reg_anterior[l_linha].campo_60
  WHEN 61  RETURN ma_reg_anterior[l_linha].campo_61
  WHEN 62  RETURN ma_reg_anterior[l_linha].campo_62
  WHEN 63  RETURN ma_reg_anterior[l_linha].campo_63
  WHEN 64  RETURN ma_reg_anterior[l_linha].campo_64
  WHEN 65  RETURN ma_reg_anterior[l_linha].campo_65
  WHEN 66  RETURN ma_reg_anterior[l_linha].campo_66
  WHEN 67  RETURN ma_reg_anterior[l_linha].campo_67
  WHEN 68  RETURN ma_reg_anterior[l_linha].campo_68
  WHEN 69  RETURN ma_reg_anterior[l_linha].campo_69
  WHEN 70  RETURN ma_reg_anterior[l_linha].campo_70
  WHEN 71  RETURN ma_reg_anterior[l_linha].campo_71
  WHEN 72  RETURN ma_reg_anterior[l_linha].campo_72
  WHEN 73  RETURN ma_reg_anterior[l_linha].campo_73
  WHEN 74  RETURN ma_reg_anterior[l_linha].campo_74
  WHEN 75  RETURN ma_reg_anterior[l_linha].campo_75
  WHEN 76  RETURN ma_reg_anterior[l_linha].campo_76
  WHEN 77  RETURN ma_reg_anterior[l_linha].campo_77
  WHEN 78  RETURN ma_reg_anterior[l_linha].campo_78
  WHEN 79  RETURN ma_reg_anterior[l_linha].campo_79
  WHEN 80  RETURN ma_reg_anterior[l_linha].campo_80
  WHEN 81  RETURN ma_reg_anterior[l_linha].campo_81
  WHEN 82  RETURN ma_reg_anterior[l_linha].campo_82
  WHEN 83  RETURN ma_reg_anterior[l_linha].campo_83
  WHEN 84  RETURN ma_reg_anterior[l_linha].campo_84
  WHEN 85  RETURN ma_reg_anterior[l_linha].campo_85
  WHEN 86  RETURN ma_reg_anterior[l_linha].campo_86
  WHEN 87  RETURN ma_reg_anterior[l_linha].campo_87
  WHEN 88  RETURN ma_reg_anterior[l_linha].campo_88
  WHEN 89  RETURN ma_reg_anterior[l_linha].campo_89
  WHEN 90  RETURN ma_reg_anterior[l_linha].campo_90
  WHEN 91  RETURN ma_reg_anterior[l_linha].campo_91
  WHEN 92  RETURN ma_reg_anterior[l_linha].campo_92
  WHEN 93  RETURN ma_reg_anterior[l_linha].campo_93
  WHEN 94  RETURN ma_reg_anterior[l_linha].campo_94
  WHEN 95  RETURN ma_reg_anterior[l_linha].campo_95
  WHEN 96  RETURN ma_reg_anterior[l_linha].campo_96
  WHEN 97  RETURN ma_reg_anterior[l_linha].campo_97
  WHEN 98  RETURN ma_reg_anterior[l_linha].campo_98
  WHEN 99  RETURN ma_reg_anterior[l_linha].campo_99
  WHEN 100 RETURN ma_reg_anterior[l_linha].campo_100
  WHEN 101 RETURN ma_reg_anterior[l_linha].campo_101
  WHEN 102 RETURN ma_reg_anterior[l_linha].campo_102
  WHEN 103 RETURN ma_reg_anterior[l_linha].campo_103
  WHEN 104 RETURN ma_reg_anterior[l_linha].campo_104
  WHEN 105 RETURN ma_reg_anterior[l_linha].campo_105
  WHEN 106 RETURN ma_reg_anterior[l_linha].campo_106
  WHEN 107 RETURN ma_reg_anterior[l_linha].campo_107
  WHEN 108 RETURN ma_reg_anterior[l_linha].campo_108
  WHEN 109 RETURN ma_reg_anterior[l_linha].campo_109
  WHEN 110 RETURN ma_reg_anterior[l_linha].campo_110
  WHEN 111 RETURN ma_reg_anterior[l_linha].campo_111
  WHEN 112 RETURN ma_reg_anterior[l_linha].campo_112
  WHEN 113 RETURN ma_reg_anterior[l_linha].campo_113
  WHEN 114 RETURN ma_reg_anterior[l_linha].campo_114
  WHEN 115 RETURN ma_reg_anterior[l_linha].campo_115
  WHEN 116 RETURN ma_reg_anterior[l_linha].campo_116
  WHEN 117 RETURN ma_reg_anterior[l_linha].campo_117
  WHEN 118 RETURN ma_reg_anterior[l_linha].campo_118
  WHEN 119 RETURN ma_reg_anterior[l_linha].campo_119
  WHEN 120 RETURN ma_reg_anterior[l_linha].campo_120
  WHEN 121 RETURN ma_reg_anterior[l_linha].campo_121
  WHEN 122 RETURN ma_reg_anterior[l_linha].campo_122
  WHEN 123 RETURN ma_reg_anterior[l_linha].campo_123
  WHEN 124 RETURN ma_reg_anterior[l_linha].campo_124
  WHEN 125 RETURN ma_reg_anterior[l_linha].campo_125
  WHEN 126 RETURN ma_reg_anterior[l_linha].campo_126
  WHEN 127 RETURN ma_reg_anterior[l_linha].campo_127
  WHEN 128 RETURN ma_reg_anterior[l_linha].campo_128
  WHEN 129 RETURN ma_reg_anterior[l_linha].campo_129
  WHEN 130 RETURN ma_reg_anterior[l_linha].campo_130
 END CASE

END FUNCTION

#-------------------------------#
 FUNCTION cdv0801_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/funcoes/cdv0801.4gl $|$Revision: 8 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION