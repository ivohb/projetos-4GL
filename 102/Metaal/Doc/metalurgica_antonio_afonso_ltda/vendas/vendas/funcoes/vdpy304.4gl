###PARSER-Não remover esta linha(Framework Logix)###
 #--------------------------------------------------------------------#
 # SISTEMA.: VDP                                                      #
 #    FONTE: VDPY304                                                  #
 # OBJETIVO: EPL RESPONSAVEL PELO ACRESCIMO DO PERCENTUAL NO VALOR    #
 #           UNITARIO DO ITEM.                                        #
 # AUTOR...: RODRIGO EXTERKOETTER                                     #
 # DATA....: 31/05/2009                                               #
 #--------------------------------------------------------------------#

 DATABASE logix
GLOBALS
 DEFINE p_user                      LIKE usuario.nom_usuario
END GLOBALS
 DEFINE m_versao_funcao             CHAR(18),
        m_arquivo_help              CHAR(100),
        m_caminho                   CHAR(100)

 DEFINE m_cons_ativa                SMALLINT

 DEFINE m_cod_empresa               LIKE empresa.cod_empresa,
        m_cod_item                  LIKE vdp_parametro_item.item,
        m_den_item                  LIKE item.den_item,
        m_perc_acrescim             LIKE vdp_parametro_item.parametro_val,
        m_user                      LIKE usuario.nom_usuario

 DEFINE mr_vdp_par_item             RECORD LIKE vdp_parametro_item.*

#------------------------------------------------------------#
 FUNCTION vdpy304_consiste_cliente(l_user)
#------------------------------------------------------------#
  DEFINE l_user                      LIKE usuario.nom_usuario

  LET m_versao_funcao = "VDPY304-05.10.01ee" # favor não alterar esta linha (Suporte)
  LET m_user = l_user

  RETURN TRUE

END FUNCTION

#----------------------------------------------------------#
 FUNCTION vdpy304_carrega_dados(l_empresa, l_item,l_den_item)
#----------------------------------------------------------#
  DEFINE l_empresa       LIKE empresa.cod_empresa,
         l_item          LIKE vdp_parametro_item.item,
         l_den_item      LIKE item.den_item

  LET m_cons_ativa = FALSE
  LET m_cod_empresa = l_empresa
  LET m_cod_item = l_item
  LET m_den_item = l_den_item

  INITIALIZE mr_vdp_par_item.* TO NULL
  CALL log130_procura_caminho('vdp41323')
   RETURNING m_caminho

  OPEN WINDOW vdp41323 AT 2,2 WITH FORM m_caminho
   ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  CALL log006_exibe_teclas("01", m_versao_funcao)
  CURRENT WINDOW IS vdp41323

  IF m_cod_item IS NOT NULL THEN
     LET m_cons_ativa = TRUE
     IF vdpy304_consulta_adicional() THEN
        DISPLAY mr_vdp_par_item.parametro_val TO perc_acrescimo
     END IF
  END IF

  DISPLAY m_cod_empresa   TO empresa
  DISPLAY l_item      TO cod_item
  DISPLAY l_den_item  TO den_item

  MENU "Opção"

    COMMAND "Modificar" "Modifica na tabela VDP_PARAMETRO_ITEM."
      HELP 002
      MESSAGE ""
      IF log005_seguranca(m_user,"VDP","VDP4132","MO") THEN
         IF m_cons_ativa THEN
            CALL vdpy304_modificacao()
         ELSE
            CALL log0030_mensagem("Consulte previamente para fazer a modificação."
                                 ,"exclamation")
         END IF
      END IF

     COMMAND "Fim"  "Retorna ao Menu Anterior"
     HELP 008
     EXIT MENU
  END MENU

  CLOSE WINDOW vdp41323

END FUNCTION

#-------------------------------------------------------------------#
 FUNCTION vdpy304_entrada_dados()
#-------------------------------------------------------------------#

   INITIALIZE m_perc_acrescim TO NULL

   CALL log006_exibe_teclas("01 02 07", m_versao_funcao)
   CURRENT WINDOW IS vdp41323
   LET int_flag = 0
   LET m_perc_acrescim = mr_vdp_par_item.parametro_val

   INPUT m_perc_acrescim  WITHOUT DEFAULTS FROM perc_acrescimo

    ON KEY ('control-w',f1)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
    CALL vdpy304_help()

   END INPUT

   IF int_flag <> 0 THEN
      LET int_flag = 0
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------------------------#
 FUNCTION vdpy304_modificacao()
#---------------------------------------------------------#
  DEFINE l_texto           LIKE audit_logix.texto

  IF vdpy304_entrada_dados() THEN
     IF mr_vdp_par_item.parametro_val IS NOT NULL THEN
        IF m_perc_acrescim <> mr_vdp_par_item.parametro_val THEN
           LET l_texto = "Indicador do percentual de acréscimo ", m_perc_acrescim USING "##&.&&", " sofreu alteração de: ",
                         mr_vdp_par_item.parametro_val USING "##&.&&", " para ", m_perc_acrescim USING "##&.&&"
           IF vdpy304_insert_audit_logix(l_texto) = FALSE THEN
              RETURN
           END IF
        END IF
        IF NOT vdpy304_modifica_parametro(m_perc_acrescim) THEN
           RETURN
        END IF
        let  mr_vdp_par_item.parametro_val = m_perc_acrescim 
     ELSE

       IF NOT vdpy304_grava_parametro('pct_acrescim',
                                      'Indicador do percentual de acrescimo.',
                                      '','',
                                      m_perc_acrescim) THEN
          RETURN
       END IF

     END IF

  END IF

  END FUNCTION

#------------------------------------------------------------------#
 FUNCTION vdpy304_modifica_parametro(l_valor)
#------------------------------------------------------------------#
 DEFINE l_valor                        LIKE vdp_parametro_item.parametro_val

 WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("BEGIN TRANSACTION","vdpy304_grava_parametro")
     RETURN FALSE
  END IF

 WHENEVER ERROR CONTINUE
 UPDATE vdp_parametro_item
    SET parametro_val   = l_valor
  WHERE empresa   = mr_vdp_par_item.empresa
    AND item      = mr_vdp_par_item.item
    AND parametro = mr_vdp_par_item.parametro
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("ATUALIZACAO","VDP_PARAMETRO_ITEM")
    WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("ROLLBACK TRANSACTION","vdpy304_grava_parametro")
       RETURN FALSE
    END IF

    ERROR "Modificação cancelada."
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
     CALL log085_transacao("COMMIT")
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("COMMIT TRANSACTION","vdpy304_grava_parametro")
    RETURN FALSE
 END IF

 MESSAGE "Modificação efetuada com sucesso."
 RETURN TRUE

END FUNCTION

#-------------------------------------------#
 FUNCTION vdpy304_insert_audit_logix(l_texto)
#-------------------------------------------#

  DEFINE l_texto LIKE audit_logix.texto,
          l_hora       CHAR(08)

   LET l_hora = TIME

   IF m_user IS NULL OR m_user = " " THEN
      LET m_user = p_user
   END IF

   WHENEVER ERROR CONTINUE
   INSERT INTO audit_logix(cod_empresa,
                           texto,
                           num_programa,
                           data,
                           hora,
                           usuario)
          VALUES (m_cod_empresa,
                  l_texto,
                  "VDPY304",
                  TODAY,
                  l_hora,
                  m_user)
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","AUDIT_LOGIX")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------------------#
 FUNCTION vdpy304_grava_parametro(l_parametro,
                                  l_des_parametro,
                                  l_ies_param,
                                  l_char,
                                  l_valor)
#-------------------------------------------------#

 DEFINE l_parametro                    LIKE vdp_parametro_item.parametro,
        l_des_parametro                LIKE vdp_parametro_item.des_parametro,
        l_ies_param                    LIKE vdp_parametro_item.parametro_ind,
        l_char                         LIKE vdp_parametro_item.parametro_texto,
        l_valor                        LIKE vdp_parametro_item.parametro_val

 WHENEVER ERROR CONTINUE
 INSERT INTO vdp_parametro_item (empresa,
                                 item,
                                 parametro,
                                 des_parametro,
                                 parametro_ind,
                                 parametro_texto,
                                 parametro_val,
                                 parametro_num,
                                 parametro_dat )
                         VALUES (m_cod_empresa,
                                 m_cod_item,
                                 l_parametro,
                                 l_des_parametro,
                                 l_ies_param,
                                 l_char,
                                 l_valor,
                                 NULL,
                                 '' )
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    IF log0030_err_sql_registro_duplicado() THEN
       IF NOT vdpy304_modifica_parametro(m_perc_acrescim) THEN
          RETURN FALSE
       END IF
    ELSE
       CALL log003_err_sql("INSERT","vdp_parametro_item")
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

END FUNCTION

#-----------------------------------------#
 FUNCTION vdpy304_consulta_adicional()
#-----------------------------------------#

   WHENEVER ERROR CONTINUE
     SELECT empresa,
            item,
            parametro,
            des_parametro,
            parametro_ind,
            parametro_texto,
            parametro_val,
            parametro_num,
            parametro_dat
       INTO mr_vdp_par_item.empresa,
            mr_vdp_par_item.item,
            mr_vdp_par_item.parametro,
            mr_vdp_par_item.des_parametro,
            mr_vdp_par_item.parametro_ind,
            mr_vdp_par_item.parametro_texto,
            mr_vdp_par_item.parametro_val,
            mr_vdp_par_item.parametro_num,
            mr_vdp_par_item.parametro_dat
       FROM vdp_parametro_item
      WHERE empresa   = m_cod_empresa
        AND item      = m_cod_item
        AND parametro = 'pct_acrescim'
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
      CALL log003_err_sql("SELECT","vdp_parametro_item")
      RETURN FALSE
   ELSE
      IF sqlca.sqlcode = 100 THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

 END FUNCTION

#----------------------#
 FUNCTION vdpy304_help()
#----------------------#

   CASE
      WHEN INFIELD(perc_acrescimo)      CALL SHOWHELP(114)
   END CASE

END FUNCTION

#----------------------------------------------------#
 FUNCTION vdpy304_acresc_perc_val_unit_item(l_cod_empresa, l_cod_item )
#----------------------------------------------------#
  DEFINE l_cod_empresa     LIKE empresa.cod_empresa,
         l_cod_item        LIKE item.cod_item,
         l_op              LIKE vdp_parametro_item.parametro_val

  WHENEVER ERROR CONTINUE
    SELECT parametro_val
      INTO l_op
      FROM vdp_parametro_item
     WHERE empresa   = l_cod_empresa
       AND item      = l_cod_item
       AND parametro = 'pct_acrescim'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("SELECT","vdp_parametro_item")
     RETURN l_op, FALSE
  ELSE
     IF sqlca.sqlcode = 100 THEN
        RETURN l_op, FALSE
     END IF
  END IF

  RETURN l_op, TRUE

END FUNCTION

#---------------------------------------------------------------#
 FUNCTION vdpy304_grava_vdp_ped_item_compl(l_empresa, l_num_pedido, l_sequencia, l_cod_item)
#---------------------------------------------------------------#
  DEFINE l_empresa          LIKE empresa.cod_empresa,
         l_num_pedido       LIKE pedidos.num_pedido,
         l_sequencia        LIKE vdp_ped_item_compl.sequencia_pedido,
         l_cod_item         LIKE item.cod_item

  DEFINE l_val_op           LIKE vdp_parametro_item.parametro_val,
         l_status           SMALLINT

  CALL vdpy304_acresc_perc_val_unit_item(l_empresa, l_cod_item)
       RETURNING l_val_op, l_status
  IF l_status THEN
     WHENEVER ERROR CONTINUE
       INSERT INTO vdp_ped_item_compl(empresa,
                                  pedido,
                                  sequencia_pedido,
                                  campo,
                                  par_existencia,
                                  parametro_texto,
                                  parametro_val,
                                  parametro_dat)
              VALUES(l_empresa,
                     l_num_pedido,
                     l_sequencia,
                     'pct_acrescim',
                     '',
                     'Indicador do percentual de acrescimo.',
                     l_val_op,
                     '')
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        IF NOT log0030_err_sql_registro_duplicado() THEN
           CALL log003_err_sql("INSERT","vdp_ped_item_compl")
        END IF
     END IF
  END IF

END FUNCTION

#-------------------------------------------------------------------#
 FUNCTION vdpy304_verif_vdp_ped_item_compl(l_empresa, l_num_pedido, l_sequencia)
#-------------------------------------------------------------------#
  DEFINE l_empresa          LIKE empresa.cod_empresa,
         l_num_pedido       LIKE pedidos.num_pedido,
         l_sequencia        LIKE vdp_ped_item_compl.sequencia_pedido

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM vdp_ped_item_compl
     WHERE empresa = l_empresa
       AND pedido = l_num_pedido
       AND sequencia_pedido = l_sequencia
       AND campo = 'pct_acrescim'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("SELECT","vdp_ped_item_compl")
     RETURN FALSE
  ELSE
     IF sqlca.sqlcode = 100 THEN
        RETURN FALSE
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#---------------------------------------------#
 FUNCTION vdpy304_version_info()
#---------------------------------------------#
  RETURN "$Archive: /especificos/logix10R2/metalurgica_antonio_afonso_ltda/vendas/vendas/funcoes/vdpy304.4gl $|$Revision: 2 $|$Date: 14/10/09 10:18 $|$Modtime: 14/10/09 8:39 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION