###PARSER-Não remover esta linha(Framework Logix)###
#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: SUP0360                                                 #
# MODULOS.: SUP0360 LOG0010 LOG0030 LOG0040 LOG0050 LOG0060         #
# OBJETIVO: MANUTENCAO DA TABELA "PROG_ORDEM_SUP"                   #
# AUTOR...: JUAREZ TAMANINI                                         #
# DATA....: 29/01/1992                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE g_pais              CHAR(02)
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_cons_saldo        CHAR(01),
         p_user              LIKE usuario.nom_usuario,
         p_prx_num_prog      LIKE prog_ordem_sup.num_prog_entrega,
         p_cod_comprador     LIKE comprador.cod_comprador,
         p_cod_compra_ordem  LIKE ordem_sup.cod_comprador,
         g_ies_ambiente      CHAR(01),
         p_flag_atua_c       SMALLINT,
         p_grade_pc          SMALLINT,
         p_cont_desp         SMALLINT,
         p_flag_atua_l       SMALLINT,
         p_flag_atua_f       SMALLINT,
         p_achou             SMALLINT,
         p_achou_qtd         SMALLINT,
         p_qtd_solic_s       LIKE ordem_sup.qtd_solic,
         p_cod_item          LIKE item.cod_item,
         p_status            SMALLINT,
         p_cancel            INTEGER,
         p_conta             SMALLINT,
         p_pri_vez           SMALLINT,
         p_ies_item_estoq    LIKE ordem_sup.ies_item_estoq,
         g_ies_grafico       SMALLINT,
         g_ies_genero        SMALLINT

  DEFINE g_conta_inativa    SMALLINT #547191

  DEFINE p_audit             RECORD
                             nom_usuario LIKE audit_sup.nom_usuario,
                             dat_proces  LIKE audit_sup.dat_proces,
                             hor_operac  LIKE audit_sup.hor_operac
                             END RECORD

  DEFINE p_ordem_sup         RECORD LIKE ordem_sup.*,
         p_ordem_supr        RECORD LIKE ordem_sup.*,
         p_prog_ordem_sup    RECORD LIKE prog_ordem_sup.*,
         p_prog_ordem_supr   RECORD LIKE prog_ordem_sup.*,
         p_formonly    RECORD
                          tex_situa_oc   CHAR(11),
                          qtd_solic      LIKE ordem_sup.qtd_solic,
                          den_item_reduz LIKE item.den_item_reduz,
                          cod_unid_med   LIKE item.cod_unid_med
                          END RECORD,
         p_formonlyr   RECORD
                          tex_situa_oc   CHAR(11),
                          qtd_solic      LIKE ordem_sup.qtd_solic,
                          den_item_reduz LIKE item.den_item_reduz,
                          cod_unid_med   LIKE item.cod_unid_med
                       END RECORD,
         p_programas_oc ARRAY[499] OF RECORD
                        inf_complement   CHAR(01),
                        num_prog_entrega LIKE prog_ordem_sup.num_prog_entrega,
                        dat_entrega_prev LIKE prog_ordem_sup.dat_entrega_prev,
                        qtd_solic        LIKE prog_ordem_sup.qtd_solic,
                        qtd_recebida     LIKE prog_ordem_sup.qtd_recebida,
                        num_pedido_fornec LIKE prog_ordem_sup.num_pedido_fornec,
                        ies_situa_prog   LIKE prog_ordem_sup.ies_situa_prog
                        END RECORD,

         p_prog_sal ARRAY[499] OF RECORD
                        inf_complement   CHAR(01),
                        num_prog_entrega LIKE prog_ordem_sup.num_prog_entrega,
                        dat_entrega_prev LIKE prog_ordem_sup.dat_entrega_prev,
                        qtd_solic        LIKE prog_ordem_sup.qtd_solic,
                        qtd_recebida     LIKE prog_ordem_sup.qtd_recebida,
                        num_pedido_fornec LIKE prog_ordem_sup.num_pedido_fornec,
                        ies_situa_prog   LIKE prog_ordem_sup.ies_situa_prog,
                        ies_atualiza   CHAR(01)
                        END RECORD,
         p_prog_situa ARRAY[499] OF RECORD
                        inf_complement    CHAR(01),
                        num_prog_entrega  LIKE prog_ordem_sup.num_prog_entrega,
                        dat_entrega_prev  LIKE prog_ordem_sup.dat_entrega_prev,
                        qtd_solic         LIKE prog_ordem_sup.qtd_solic,
                        qtd_recebida      LIKE prog_ordem_sup.qtd_recebida,
                        num_pedido_fornec LIKE prog_ordem_sup.num_pedido_fornec,
                        ies_situa_prog    LIKE prog_ordem_sup.ies_situa_prog,
                        ies_atualiza      CHAR(01)
                        END RECORD,
         p_inf_complement ARRAY[499] OF RECORD
                        dat_origem       LIKE prog_ordem_sup.dat_origem,
                        dat_palpite      LIKE prog_ordem_sup.dat_palpite,
                        qtd_em_transito  LIKE prog_ordem_sup.qtd_em_transito,
                        tex_observacao   LIKE prog_ordem_sup.tex_observacao
                        END RECORD

  DEFINE p_compl        RECORD
                        dat_origem       LIKE prog_ordem_sup.dat_origem,
                        dat_palpite      LIKE prog_ordem_sup.dat_palpite,
                        qtd_em_transito  LIKE prog_ordem_sup.qtd_em_transito,
                        tex_observacao   LIKE prog_ordem_sup.tex_observacao
                        END RECORD

  DEFINE p_qtd_tot_prog      LIKE prog_ordem_sup.qtd_solic,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         p_cont              SMALLINT,
         p_operacao          CHAR(08),
         p_contador          SMALLINT,
         p_ies_cons          SMALLINT,
         p_num_args          SMALLINT,
         p_cod_empresa_arg   LIKE ordem_sup.cod_empresa,
         p_num_oc_arg        LIKE ordem_sup.num_oc,
         p_num_versao_arg    LIKE ordem_sup.num_versao,
         p_saldo_liquidado   LIKE prog_ordem_sup.qtd_solic

  DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

#MODULARES
DEFINE m_dir_arq_help         CHAR(100),
       m_window               CHAR(08)

DEFINE  mc_curr               SMALLINT,
        ma_curr               SMALLINT

DEFINE  p_dest_prog_ord  ARRAY[99] OF RECORD
                            cod_local        LIKE dest_prog_ord_sup.cod_local,
                            qtd_particip     LIKE dest_prog_ord_sup.qtd_particip_comp,
                            pct_particip     LIKE dest_prog_ord_sup.pct_particip_comp,
                            num_docum        LIKE dest_prog_ord_sup.num_docum
                         END RECORD

DEFINE  p_cont_dest           SMALLINT,
        p_flag_dest           SMALLINT,
        p_tot_prog            DECIMAL(13,3),
        p_ies_distr_obj       LIKE par_sup_pad.par_ies,
        p_ies_dat_retro       LIKE par_sup_pad.par_ies,
        p_dest_prog_ord_sup   RECORD LIKE dest_prog_ord_sup.*,
        p_par_con             RECORD LIKE par_con.*,
        p_ies_situa_oc_D_ou_T CHAR(01),
        m_possui_centraliz    SMALLINT

DEFINE comando        CHAR(100),
       m_cursor_saldo SMALLINT

DEFINE m_ies_ajuste_data_oc  CHAR(01),
       m_ies_excl_oc_aberta  CHAR(01),
       m_ies_excl_oc_deb_dir CHAR(01),
       m_ies_prog_alt_sup0360 CHAR(01),
       m_controla_gao        CHAR(01),
       m_orcamento_periodo   CHAR(01),
       m_usa_cond_pagto      CHAR(01),
       m_estorna_liquid      CHAR(01),
       m_cod_empresa_ativ    LIKE ordem_sup.cod_empresa,
       m_ies_oc_estoque      SMALLINT,
       m_fat_conver          LIKE fat_conver.fat_conver_unid,
       m_cod_grp_desp_nfr    LIKE grupo_ctr_desp.gru_ctr_desp,
       m_cod_grp_desp_fat    LIKE grupo_ctr_desp.gru_ctr_desp,
       m_tip_desp_cons_fat   LIKE tipo_despesa.cod_tip_despesa,
       m_cod_tip_desp_cons   LIKE tipo_despesa.cod_tip_despesa,
       m_ies_utiliz_provisao CHAR(01),
       m_utiliz_nfm_import   CHAR(01),
       m_permitir_cancelar_oc_pc_edi   CHAR(01),
       m_oc_pc_realizado     CHAR(01),
       m_desig_cons6510      CHAR(01),
       m_total               SMALLINT  # 547191

DEFINE mr_usuario RECORD
                  cod_comprador LIKE comprador.cod_comprador,
                  cod_progr     LIKE programador.cod_progr
                  END RECORD

DEFINE m_pedido_score         LIKE sup_recb_score_34.ordem_compra

DEFINE ma_qtd_reservada ARRAY[499] OF DECIMAL(12,3)
#END MODULARES

MAIN

     CALL log0180_conecta_usuario()

  CALL fgl_setenv("VERSION_INFO","L10-SUP0360-10.01.$Revision: 10 $p") #Informacao da versao do programa controlado pelo SourceSafe - Nao remover esta linha.
 LET p_versao = "SUP0360-10.01.10p" #Favor nao alterar esta linha (SUPORTE)

 WHENEVER ERROR CONTINUE
 CALL log1400_isolation()
 SET LOCK MODE TO WAIT 120
 WHENEVER ERROR STOP

 DEFER INTERRUPT
 CALL log140_procura_caminho("sup0360.iem") RETURNING m_dir_arq_help
 OPTIONS
   HELP FILE m_dir_arq_help,
   NEXT KEY control-f,
   PREVIOUS KEY control-b
 CALL log001_acessa_usuario("SUPRIMEN","LOGERP;LOGLQ2")
      RETURNING p_status, p_cod_empresa, p_user

 IF p_status = 0  THEN
    LET m_cod_empresa_ativ = p_cod_empresa
    LET p_num_args = num_args()
    IF p_num_args > 0 THEN
       LET p_cod_empresa_arg = arg_val(1)
       LET p_num_oc_arg      = arg_val(2)
       LET p_num_versao_arg  = arg_val(3)
       LET p_cod_empresa = p_cod_empresa_arg
    END IF
    CALL sup036_controle()
 END IF
END MAIN

#--------------------------#
 FUNCTION sup036_controle()
#--------------------------#
  DEFINE l_count           SMALLINT,
         l_cod_empresa_aux LIKE ordem_sup.cod_empresa

  INITIALIZE p_prog_ordem_sup.*, p_prog_ordem_supr.* TO NULL
  INITIALIZE p_formonly.*, p_formonlyr.* TO NULL
  INITIALIZE p_flag_atua_c,p_flag_atua_l,p_flag_atua_f TO NULL
  INITIALIZE comando TO NULL
  INITIALIZE p_ordem_sup.*, p_ordem_supr.* TO NULL
  INITIALIZE pa_curr, sc_curr, p_cont,p_contador,p_ies_cons TO NULL
  INITIALIZE p_prog_situa     TO NULL
  INITIALIZE p_programas_oc   TO NULL
  INITIALIZE p_prog_sal       TO NULL
  INITIALIZE p_inf_complement TO NULL

  LET m_cursor_saldo = FALSE

  CALL sup0360_leitura_parametros()

  INITIALIZE l_count TO NULL
  SELECT COUNT(*) INTO l_count
    FROM centraliz_emp_sup
   WHERE cod_empresa = p_cod_empresa
  IF l_count IS NULL THEN
     LET l_count = 0
  END IF
  LET m_possui_centraliz = (l_count > 0)

  IF g_pais = "AR" THEN
     LET m_window = "sup0360a"
  ELSE
     LET m_window = "sup03601"
  END IF

  CALL log006_exibe_teclas("01",p_versao)
  CALL log130_procura_caminho(m_window) RETURNING comando
  OPEN WINDOW w_sup03601 AT 2,07 WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF p_num_args <> 0 THEN
     IF log005_seguranca(p_user,"SUPRIMEN","SUP0360","CO")  THEN
        LET p_cons_saldo = "S"
        CALL sup036_consulta_prog_ordem_sup_saldos()
     END IF
  END IF

  CALL sup0063_cria_temp_controle()

  MENU "OPCAO"
    COMMAND KEY("D") "consulta_salDos" "Exibe os programas de entrega (somente com saldo)"
      HELP 009
      MESSAGE ""
      LET l_cod_empresa_aux = p_cod_empresa
      LET p_cod_empresa     = m_cod_empresa_ativ
      IF log005_seguranca(p_user,"SUPRIMEN","SUP0360","CO") THEN
         LET p_cod_empresa = l_cod_empresa_aux
         LET p_cons_saldo = "S"
         CALL sup036_consulta_prog_ordem_sup_saldos()
      ELSE
         LET p_cod_empresa = l_cod_empresa_aux
      END IF
    COMMAND "Consultar"  "Consulta os programas de entrega "
      HELP 004
      MESSAGE ""
      LET l_cod_empresa_aux = p_cod_empresa
      LET p_cod_empresa     =  m_cod_empresa_ativ
      IF log005_seguranca(p_user,"SUPRIMEN","SUP0360","CO") THEN
         LET p_cod_empresa = l_cod_empresa_aux
         LET p_cons_saldo = "N"
         CALL sup036_consulta_prog_ordem_sup()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte"
         END IF
      ELSE
         LET p_cod_empresa = l_cod_empresa_aux
      END IF
    COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
      HELP 005
      MESSAGE ""
      CALL sup036_paginacao("SEGUINTE")
    COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
      HELP 006
      MESSAGE ""
      CALL sup036_paginacao("ANTERIOR")
    COMMAND "Modificar" "Modifica os programas de entrega desta ordem de compra"
      HELP 002
      MESSAGE ""
      CALL gao0001_inicializa_gao()
      IF p_ordem_sup.cod_empresa IS NOT NULL THEN
         LET l_cod_empresa_aux = p_cod_empresa
         LET p_cod_empresa     = m_cod_empresa_ativ
         IF log005_seguranca(p_user,"SUPRIMEN","SUP0360","MO")  THEN
            LET p_cod_empresa = l_cod_empresa_aux

            #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = TRUE  THEN
            #IF sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
            CALL sup0360_verifica_contas(p_ordem_sup.cod_empresa,
                                         p_ordem_sup.num_oc)

            IF sup036_verifica_oc_centralizada() = FALSE THEN
               IF sup0360_valida_oc_consignacao(p_ordem_sup.*) THEN
                  IF sup0360_acesso_oc() THEN
                     LET p_cons_saldo = "N"
                     CALL sup036_modificacao_prog_ordem_sup()
                     CALL sup036_exibe_dados("ORDEM")
                  ELSE
                     NEXT OPTION "Consultar"
                  END IF
               END IF
            ELSE
               ERROR " Ordem de Compra Centralizada. Modificacao nao permitida. Alterar pelo SUP0767. "
            END IF

            #ELSE
            #   CALL log0030_mensagem("Usuario nao é substituto do comprador.","exclamation")
            #END IF
         ELSE
            LET p_cod_empresa = l_cod_empresa_aux
         END IF
      ELSE
         CALL log0030_mensagem(" Consulte previamente para fazer a modificacao. ","info")
      END IF
    COMMAND KEY ("N") "iNf.complement"  "Consulta programas de entrega e suas informacoes complementares"
      HELP 010
      MESSAGE ""
      CALL gao0001_inicializa_gao()
      IF p_ordem_sup.cod_empresa IS NOT NULL THEN
         LET l_cod_empresa_aux = p_cod_empresa
         LET p_cod_empresa     = m_cod_empresa_ativ
         IF log005_seguranca(p_user,"SUPRIMEN","SUP0360","CO")  THEN
            LET p_cod_empresa = l_cod_empresa_aux
            CALL sup415_consulta_inf_complement(p_ordem_sup.cod_empresa,
                                                p_ordem_sup.num_oc,
                                                p_ordem_sup.num_versao)
         ELSE
            LET p_cod_empresa = l_cod_empresa_aux
         END IF
      ELSE
         CALL log0030_mensagem(" Consulte previamente para realizar consulta.","info")
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando: " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 008
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_sup03601
END FUNCTION

#--------------------------------------#
 FUNCTION sup036_verifica_programador()
#--------------------------------------#
  SELECT * FROM programador
   WHERE cod_empresa = p_cod_empresa
     AND login       = p_user
     AND cod_progr   = p_ordem_sup.cod_progr

  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  ELSE
     SELECT * FROM comprador
      WHERE cod_empresa   = p_cod_empresa
        AND login         = p_user
        AND cod_comprador = p_ordem_sup.cod_comprador
     IF sqlca.sqlcode = 0 THEN
        RETURN TRUE
     ELSE
        RETURN FALSE
     END IF
  END IF
 END FUNCTION

#----------------------#
 FUNCTION sup036_help()
#----------------------#
  CASE
    WHEN infield(num_oc)            CALL showhelp(101)
    WHEN infield(ies_situa_prog)    CALL showhelp(102)
    WHEN infield(num_versao)        CALL showhelp(103)
    WHEN infield(dat_entrega_prev)  CALL showhelp(104)
    WHEN infield(qtd_solic)         CALL showhelp(105)
    WHEN infield(num_pedido_fornec) CALL showhelp(106)
    WHEN infield(inf_complement)    CALL showhelp(107)
    WHEN infield(cod_local)         CALL showhelp(108)
    WHEN infield(qtd_particip)      CALL showhelp(105)
    WHEN infield(num_docum)         CALL showhelp(109)
    WHEN infield(cod_item)          CALL showhelp(110)
  END CASE
END FUNCTION

#-----------------------------------#
 FUNCTION sup036_exibe_dados(l_tipo)
#-----------------------------------#
  DEFINE l_tipo CHAR(10),
         l_msg  CHAR(20)

  IF p_ordem_sup.cod_empresa <> p_cod_empresa THEN
     LET p_cod_empresa = p_ordem_sup.cod_empresa
     CALL sup0360_leitura_parametros()
  END IF

  INITIALIZE p_formonly.* TO NULL

  WHENEVER ERROR CONTINUE
  SELECT item.den_item_reduz, item.cod_unid_med
    INTO p_formonly.den_item_reduz, p_formonly.cod_unid_med
    FROM item
   WHERE item.cod_empresa = p_ordem_sup.cod_empresa
     AND item.cod_item    = p_ordem_sup.cod_item
  WHENEVER ERROR STOP

  CASE p_ordem_sup.ies_situa_oc
  WHEN "A"  LET p_formonly.tex_situa_oc = "ABERTA"
  WHEN "R"  LET p_formonly.tex_situa_oc = "REALIZADA"
  WHEN "C"  LET p_formonly.tex_situa_oc = "CANCELADA"
  WHEN "L"  LET p_formonly.tex_situa_oc = "LIQUIDADA"
  WHEN "P"  LET p_formonly.tex_situa_oc = "PLANEJADA"
  WHEN "D"  LET p_formonly.tex_situa_oc = "CONDICIONAL"
  OTHERWISE LET p_formonly.tex_situa_oc = " "
  END CASE

  CALL sup036_verifica_ordem_sup()
  CALL sup036_verifica_audit()

  DISPLAY BY NAME p_ordem_sup.cod_empresa,
                  p_ordem_sup.num_oc,
                  p_ordem_sup.num_versao,
                  p_ordem_sup.ies_situa_oc,
                  p_ordem_sup.qtd_solic,
                  p_ordem_sup.cod_item,
                  p_formonly.*

  IF p_ordem_sup.num_pedido <> 0 THEN
     IF NOT g_ies_genero THEN
        DISPLAY " Nr. Pedido: ",p_ordem_sup.num_pedido," " AT 05,51 ATTRIBUTE(REVERSE)  #Vanderlei - OS 372096 #
     ELSE
        LET l_msg = "Nr. Pedido: ",p_ordem_sup.num_pedido CLIPPED
        CALL log4050_altera_atributo("lb_pedido","text",l_msg)
     END IF
  ELSE
     IF NOT g_ies_genero THEN
        DISPLAY "                    " AT 05,51    #Vanderlei - OS 372096 #
     ELSE
        CALL log4050_altera_atributo("lb_pedido","text","")
     END IF
  END IF

  IF l_tipo = "TOTAL" THEN
     CALL sup036_exibe_prog_entrega("CONSULTA")
  END IF
END FUNCTION

#------------------------------------#
 FUNCTION sup036_verifica_ordem_sup()
#------------------------------------#
  LET m_ies_oc_estoque = FALSE
  IF p_ordem_sup.ies_item_estoq = "S" THEN
     IF NOT sup0360_item_controle_estoque_fisico(p_ordem_sup.cod_item) THEN
        LET m_ies_oc_estoque = TRUE
     END IF
  END IF

  LET m_fat_conver = 1
  IF sup0538_existe_unid_compra_item(p_ordem_sup.cod_empresa,p_ordem_sup.cod_item) THEN
     LET m_fat_conver = sup0538_fat_conver_estoque_compra_item(p_ordem_sup.cod_empresa,p_ordem_sup.cod_item)
     LET p_ordem_sup.qtd_solic = p_ordem_sup.qtd_solic / m_fat_conver
     LET p_formonly.cod_unid_med = sup0538_unid_compra_item(p_ordem_sup.cod_empresa,p_ordem_sup.cod_item)
  ELSE
     IF NOT m_ies_oc_estoque THEN
        LET p_formonly.cod_unid_med = p_ordem_sup.cod_unid_med
     END IF
  END IF

  LET p_qtd_solic_s        = p_ordem_sup.qtd_solic
  LET p_formonly.qtd_solic = p_ordem_sup.qtd_solic
  LET p_ies_item_estoq     = p_ordem_sup.ies_item_estoq

  DISPLAY BY NAME p_formonly.qtd_solic
 END FUNCTION

#-----------------------------------------#
 FUNCTION sup036_verifica_prog_ordem_sup()
#-----------------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT *
    FROM prog_ordem_sup
   WHERE cod_empresa  = p_ordem_sup.cod_empresa
     AND num_oc       = p_ordem_sup.num_oc
     AND num_versao   = p_ordem_sup.num_versao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 OR sqlca.sqlcode = -284 THEN
     RETURN TRUE
  END IF
  RETURN FALSE
END FUNCTION

#-----------------------------------#
 FUNCTION sup036_cursor_for_update()
#-----------------------------------#
  DECLARE cm_ordem_sup CURSOR FOR
   SELECT * INTO p_ordem_sup.*
     FROM ordem_sup
    WHERE cod_empresa      = p_ordem_sup.cod_empresa
      AND num_oc           = p_ordem_sup.num_oc
      AND ies_versao_atual = "S"
  FOR UPDATE

  WHENEVER ERROR CONTINUE
  CALL log085_transacao("BEGIN")
  OPEN cm_ordem_sup
  FETCH cm_ordem_sup
  WHENEVER ERROR STOP

  CASE sqlca.sqlcode
    WHEN    0 RETURN TRUE
    WHEN -250 CALL log0030_mensagem(" Registro sendo atualizado por outro usuario. Aguarde e tente novamente. ","exclamation")
    WHEN  100 CALL log0030_mensagem(" Registro nao mais existe na tabela. Execute a CONSULTA novamente. ","exclamation")
    OTHERWISE CALL log003_err_sql("CONSULTA","ORDEM_SUP")
  END CASE

  WHENEVER ERROR CONTINUE
  CALL log085_transacao("ROLLBACK")
  WHENEVER ERROR STOP

  RETURN FALSE
END FUNCTION

#--------------------------------------------#
 FUNCTION sup036_modificacao_prog_ordem_sup()
#--------------------------------------------#

  DEFINE p_prim                        SMALLINT

  DEFINE l_ind                         SMALLINT,
         l_ind2                        SMALLINT,
         l_msg                         CHAR(100),
         l_cod_fornecedor              LIKE fornecedor_edi.cod_fornecedor

  LET p_prim = TRUE
  LET p_houve_erro = FALSE

  IF p_ordem_sup.ies_imobilizado = "C" THEN
     ERROR " Ordem de contrato deve ter controle por valor (SUP8530). "
     RETURN
  END IF

  IF sup036_ordem_controla_valor() THEN
     CALL log0030_mensagem("Ordem de compra controlada por VALOR. Atualizar via programa SUP8530","exclamation")
     RETURN
  END IF

  IF p_ordem_sup.ies_imobilizado = "S" AND m_utiliz_nfm_import = "S" THEN
     IF sup0360_ordem_importacao("I") THEN
        RETURN
     END IF
  END IF

  IF  (p_ordem_sup.ies_situa_oc = "A" OR p_ordem_sup.ies_situa_oc = "P")
  OR ((p_ordem_sup.ies_situa_oc = "D" OR p_ordem_sup.ies_situa_oc = "T")
  AND  p_ies_situa_oc_D_ou_T    = "S")
  OR (p_ordem_sup.ies_situa_oc = "R" AND sup0360_verifica_nova_versao_oc(p_ordem_sup.num_oc)) THEN
     IF NOT sup0360_verifica_fornec_edi(p_ordem_sup.cod_fornecedor) THEN
        ERROR "Programação de entrega não pode ser modificado pois pertence a um fornecedor EDI."
        RETURN
     ELSE
        IF sup036_cursor_for_update() THEN
           IF sup0538_existe_unid_compra_item(p_ordem_sup.cod_empresa,p_ordem_sup.cod_item) THEN
              LET m_fat_conver = sup0538_fat_conver_estoque_compra_item(p_ordem_sup.cod_empresa,p_ordem_sup.cod_item)
              LET p_ordem_sup.qtd_solic    = p_ordem_sup.qtd_solic / m_fat_conver
              LET p_ordem_sup.qtd_recebida = p_ordem_sup.qtd_recebida / m_fat_conver
           END IF

           LET p_ordem_supr.* = p_ordem_sup.*
           LET p_formonlyr.*  = p_formonly.*

           IF sup036_modifica_prog_entrega() THEN
              CALL sup0156_atualiza_orcamento_oc(p_ordem_sup.cod_empresa,
                   p_ordem_sup.num_oc,"EXCLUSAO")
                   RETURNING p_status, l_msg

              #547191
              IF find4GLFunction('supy43_cliente_55') THEN
                 IF supy43_cliente_55(p_cod_empresa) = TRUE AND
                    g_conta_inativa     = TRUE THEN
                 ELSE
                    IF NOT p_status THEN
                       CALL log0030_mensagem(l_msg,"exclamation")
                       LET p_houve_erro = TRUE
                    END IF
                 END IF
              ELSE
                 IF NOT p_status THEN
                    CALL log0030_mensagem(l_msg,"exclamation")
                    LET p_houve_erro = TRUE
                 END IF
              END IF

              IF NOT p_houve_erro THEN
                 IF NOT fcl1150_integra_oc_fcx(p_ordem_sup.cod_empresa,
                                               p_ordem_sup.num_oc,"EX") THEN
                    LET p_houve_erro = TRUE
                 END IF
              END IF

              IF NOT p_houve_erro THEN
                 # Inicio OS 277428
                 # Somente atualizar o orçamento se a OC já foi designada.
                 IF p_ordem_sup.pre_unit_oc > 0 THEN
                    IF NOT sup0360_verifica_orcamento(p_ordem_sup.cod_empresa,
                                                      p_ordem_sup.num_oc,
                                                      p_ordem_sup.cod_fornecedor,
                                                      p_ordem_sup.qtd_solic,
                                                      p_ordem_sup.pre_unit_oc,
                                                      p_ordem_sup.pct_ipi,
                                                      p_ordem_sup.cnd_pgto,
                                                      p_ordem_sup.num_cotacao,
                                                      p_ordem_sup.cod_item,
                                                      "EX") THEN
                        LET p_houve_erro = TRUE
                    END IF
                 END IF
                 # Fim OS 277428
              END IF

              IF NOT p_houve_erro THEN
                 FOR l_ind = 1 TO p_cont
                    LET p_achou = FALSE

                    IF p_programas_oc[l_ind].dat_entrega_prev IS NULL
                    OR p_programas_oc[l_ind].dat_entrega_prev = " " THEN
                       EXIT FOR
                    END IF

                    FOR l_ind2 = 1 TO p_cont
                       IF  p_programas_oc[l_ind].num_prog_entrega =
                           p_prog_sal[l_ind2].num_prog_entrega
                       AND p_programas_oc[l_ind].num_prog_entrega IS NOT NULL THEN
                          IF p_programas_oc[l_ind].qtd_solic IS NULL THEN
                             CONTINUE FOR
                          END IF

                          CALL sup036_move_prog_ordem_sup(l_ind)

                          LET p_prog_ordem_sup.num_prog_entrega =
                              p_programas_oc[l_ind].num_prog_entrega
                          LET p_programas_oc[l_ind].inf_complement = "S"
                          LET p_prog_sal[l_ind].ies_atualiza = "S"

                          #O.S. 559541
                          IF p_prog_ordem_sup.ies_situa_prog <> "L"
                          AND p_prog_ordem_sup.qtd_solic = p_prog_ordem_sup.qtd_recebida THEN
                             LET l_msg = "Deseja liquidar a programação nº ",
                             p_prog_ordem_sup.num_prog_entrega USING "<<<<&", "?"

                             IF log0040_confirm(13,39,l_msg) THEN
                                LET p_prog_ordem_sup.ies_situa_prog = "L"
                             END IF
                          END IF
                          #O.S. 559541

                          WHENEVER ERROR CONTINUE
                          UPDATE prog_ordem_sup
                             SET prog_ordem_sup.* = p_prog_ordem_sup.*
                           WHERE cod_empresa      = p_prog_ordem_sup.cod_empresa
                             AND num_oc           = p_prog_ordem_sup.num_oc
                             AND num_versao       = p_prog_ordem_sup.num_versao
                             AND num_prog_entrega = p_prog_ordem_sup.num_prog_entrega
                          WHENEVER ERROR STOP
                          IF sqlca.sqlcode <> 0 THEN
                             CALL log003_err_sql("MODIFICACAO","PROG_ORDEM_SUP")
                             LET p_houve_erro = TRUE
                             EXIT FOR
                          END IF

                          IF p_ies_distr_obj = "S" THEN
                             IF sup036_insere_dest_prog(l_ind) = FALSE THEN
                                LET p_houve_erro = TRUE
                                EXIT FOR
                             END IF
                          END IF

                          LET p_achou = TRUE
                          EXIT FOR
                       END IF
                    END FOR

                    IF p_houve_erro THEN
                       EXIT FOR
                    END IF

                    IF p_achou = FALSE THEN
                       IF p_programas_oc[l_ind].inf_complement <> "S"
                       OR p_programas_oc[l_ind].inf_complement IS NULL THEN

                          IF p_programas_oc[l_ind].qtd_solic IS NULL THEN
                             CONTINUE FOR
                          END IF

                          IF p_prim = TRUE THEN
                             DECLARE cm_prox  SCROLL CURSOR FOR
                              SELECT num_prog_entrega
                                FROM prog_ordem_sup
                               WHERE cod_empresa = p_ordem_sup.cod_empresa
                                 AND num_oc      = p_ordem_sup.num_oc
                                 AND num_versao  = p_ordem_sup.num_versao
                               ORDER BY num_prog_entrega DESC
                             OPEN cm_prox
                             FETCH cm_prox INTO p_prx_num_prog
                             CLOSE cm_prox
                             LET p_prx_num_prog = p_prx_num_prog + 1

                             LET p_prim = FALSE
                          ELSE
                             LET p_prx_num_prog = p_prx_num_prog + 1
                          END IF

                          CALL sup036_move_prog_ordem_sup(l_ind)

                          LET p_prog_ordem_sup.num_prog_entrega = p_prx_num_prog
                          LET p_programas_oc[l_ind].inf_complement = "S"

                          WHENEVER ERROR CONTINUE
                          INSERT INTO prog_ordem_sup VALUES (p_prog_ordem_sup.*)
                          WHENEVER ERROR STOP
                          IF sqlca.sqlcode <> 0 THEN
                             CALL log003_err_sql("INCLUSAO","PROG_ORDEM_SUP")
                             LET p_houve_erro = TRUE
                             EXIT FOR
                          END IF

                          IF p_ies_distr_obj = "S" THEN
                             IF sup036_insere_dest_prog(l_ind) = FALSE THEN
                                LET p_houve_erro = TRUE
                                EXIT FOR
                             END IF
                          END IF
                       END IF
                    END IF
                 END FOR
              END IF

              IF NOT p_houve_erro THEN
                 IF NOT sup036_atua_ordem_sup() THEN
                    LET p_houve_erro = TRUE
                 END IF
              END IF

              IF NOT p_houve_erro THEN
                 IF  p_ordem_sup.cod_fornecedor <> " "
                 AND p_ordem_sup.pre_unit_oc > 0 THEN
                    #------ verifica grade de aprovacao --------#
                    LET p_conta = 0
                    SELECT COUNT(*)
                      INTO p_conta
                      FROM grade_aprov_oc
                     WHERE cod_empresa      = p_ordem_sup.cod_empresa
                       AND ies_versao_atual = "S"
                    IF p_conta IS NULL OR p_conta = " " THEN
                       LET p_conta = 0
                    END IF
                    IF p_conta > 0 THEN
                       WHENEVER ERROR CONTINUE
                       DELETE FROM aprov_ordem_sup
                        WHERE cod_empresa   = p_ordem_sup.cod_empresa
                          AND num_oc        = p_ordem_sup.num_oc
                          AND num_versao_oc = p_ordem_sup.num_versao
                       WHENEVER ERROR STOP
                       IF sqlca.sqlcode <> 0 THEN
                          CALL log003_err_sql("EXCLUSAO","APROV_ORDEM_SUP")
                          LET p_houve_erro = TRUE
                       ELSE
                          LET p_cont_desp = NULL
                          SELECT COUNT(*) INTO p_cont_desp
                            FROM grade_aprov_oc
                           WHERE cod_empresa      = p_ordem_sup.cod_empresa
                             AND ies_versao_atual = "S"
                             AND ies_situa_grade  = "L"
                             AND cod_tip_desp_ini <= p_ordem_sup.cod_tip_despesa
                             AND cod_tip_desp_fim >= p_ordem_sup.cod_tip_despesa
                          IF p_cont_desp > 0 THEN
                             CALL sup666_grava_aprov_ordem_sup(p_ordem_sup.num_oc,
                                                               p_ordem_sup.num_versao,
                                                               p_ordem_sup.cod_tip_despesa,
                                                               p_ordem_sup.cod_empresa)
                                  RETURNING p_status
                             IF p_ordem_sup.num_pedido <> 0 THEN
                                IF sup668_validacao_alcada_oc(p_ordem_sup.num_oc,
                                                              p_ordem_sup.num_versao,
                                                              p_user,
                                                              p_ordem_sup.cod_empresa) = TRUE THEN
                                END IF
                             END IF
                          END IF
                       END IF
                    END IF
                 END IF
              END IF

              IF NOT p_houve_erro THEN
                 IF p_ordem_sup.num_pedido > 0 THEN
                    IF NOT sup036_atualiza_val_tot_ped() THEN
                       LET p_houve_erro = TRUE
                    ELSE
                       CALL sup036_monta_audit_sup()
                    END IF
                 END IF
              END IF

              IF NOT p_houve_erro THEN
                 IF NOT fcl1150_integra_oc_fcx(p_ordem_sup.cod_empresa,
                                               p_ordem_sup.num_oc,"IN") THEN
                    LET p_houve_erro = TRUE
                 END IF
              END IF

              IF NOT p_houve_erro THEN
                 IF p_ordem_sup.ies_situa_oc <> "C" AND
                    p_ordem_sup.ies_situa_oc <> "L" THEN
                    CALL sup0156_atualiza_orcamento_oc(p_ordem_sup.cod_empresa,
                         p_ordem_sup.num_oc,"INCLUSAO")
                         RETURNING p_status, l_msg

                    #547191
                    IF find4GLFunction('supy43_cliente_55') THEN
                       IF supy43_cliente_55(p_cod_empresa) = TRUE AND
                          g_conta_inativa     = TRUE THEN
                       ELSE
                          IF NOT p_status THEN
                             CALL log0030_mensagem(l_msg,"exclamation")
                             LET p_houve_erro = TRUE
                          END IF
                       END IF
                    ELSE
                       IF NOT p_status THEN
                          CALL log0030_mensagem(l_msg,"exclamation")
                          LET p_houve_erro = TRUE
                       END IF
                    END IF
                 END IF
              END IF

              IF NOT p_houve_erro THEN
                 IF p_ordem_sup.ies_situa_oc <> "L" OR
                    (p_ordem_sup.ies_situa_oc = "L" AND
                     m_estorna_liquid = "N") THEN
                    CALL sup0772_atualiza_oc_oln_gao(p_ordem_sup.cod_empresa,
                                                     p_ordem_sup.num_oc,
                                                     p_ordem_sup.qtd_solic,
                                                     p_ordem_sup.pre_unit_oc,
                                                     TODAY,
                                                     "OC",
                                                     "SUP0360",
                                                     0,
                                                     0,
                                                     0,
                                                     TRUE,  # Somente atualizar se a OC
                                                            # estiver APROVADA
                                                     TRUE,  # Buscar VAL_PREVISTO caso o
                                                            # preço estiver zerado
                                                     TRUE,  # Considerar o Valor do IPI
                                                     FALSE, # Trata-se de Recebimento
                                                     FALSE, # Trata-se de Devolução à Fornecedor
                                                     "IN")
                         RETURNING p_status, l_msg
                    IF p_status = FALSE THEN
                       CALL log0030_mensagem(l_msg,"exclamation")
                       IF g_ies_grafico = FALSE THEN
                          SLEEP 2
                       END IF
                       LET p_houve_erro = TRUE
                    END IF
                 END IF
              END IF

              IF NOT p_houve_erro THEN
                 # Inicio OS 277428
                 # Somente atualizar o orçamento se a OC já foi designada.
                 IF p_ordem_sup.pre_unit_oc > 0 THEN
                    IF NOT sup0360_verifica_orcamento(p_ordem_sup.cod_empresa,
                                                      p_ordem_sup.num_oc,
                                                      p_ordem_sup.cod_fornecedor,
                                                      p_ordem_sup.qtd_solic,
                                                      p_ordem_sup.pre_unit_oc,
                                                      p_ordem_sup.pct_ipi,
                                                      p_ordem_sup.cnd_pgto,
                                                      p_ordem_sup.num_cotacao,
                                                      p_ordem_sup.cod_item,
                                                      "IN") THEN
                       LET p_houve_erro = TRUE
                    END IF
                 END IF
                 # Fim OS 277428
              END IF

              IF NOT p_houve_erro THEN
                 WHENEVER ERROR CONTINUE
                 CALL log085_transacao("COMMIT")
                 WHENEVER ERROR STOP
                 IF sqlca.sqlcode <> 0 THEN
                    CALL log003_err_sql("EFETIVACAO-COMMIT","ORDEM_SUP")
                 ELSE
                    CALL sup036_verifica_ordem_sup()
                    MESSAGE " Modificacao efetuada com sucesso " ATTRIBUTE(REVERSE)
                 END IF
              ELSE
                 WHENEVER ERROR CONTINUE
                 CALL log085_transacao("ROLLBACK")
                 WHENEVER ERROR STOP
              END IF
           ELSE
              LET p_ordem_sup.* = p_ordem_supr.*
              LET p_formonly.*  = p_formonlyr.*
              DISPLAY BY NAME p_ordem_sup.cod_empresa,
                              p_ordem_sup.num_oc,
                              p_ordem_sup.num_versao,
                              p_ordem_sup.ies_situa_oc,
                              p_ordem_sup.cod_item,
                              p_formonly.*
              ERROR " Modificacao cancelada. "
              WHENEVER ERROR CONTINUE
              CALL log085_transacao("ROLLBACK")
              WHENEVER ERROR STOP
           END IF
        END IF
     END IF
  ELSE
     IF p_ordem_sup.ies_situa_oc = "R" THEN
        IF p_ordem_sup.ies_versao_atual = "S" THEN
           CALL log0030_mensagem(" Modificacao nao permitida. Crie nova versao para a ordem. ","exclamation")
        ELSE
           CALL log0030_mensagem("Modificacao nao permitida. Esta nao e'a versao atual da ordem.","exclamation")
        END IF
     ELSE
        CALL log0030_mensagem(" Modificacao nao permitida. Situacao incompativel da ordem ","exclamation")
     END IF
  END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION sup036_consulta_prog_ordem_sup()
#-----------------------------------------#
  DEFINE sql_stmt, where_clause, where_clause1, where_clause2 CHAR(1300),
         l_primeira_vez    SMALLINT,
         l_aux             CHAR(100),
         l_informou_versao SMALLINT

  INITIALIZE sql_stmt, where_clause, where_clause1, where_clause2 TO NULL

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_sup03601

  IF p_num_args > 0 THEN
  ELSE
     LET p_cod_empresa = m_cod_empresa_ativ
  END IF

  CALL sup0538_inicializa_variaveis()
  LET p_ordem_supr.* = p_ordem_sup.*

  INITIALIZE p_ordem_sup.* TO NULL

  INITIALIZE where_clause, where_clause1, sql_stmt  TO NULL

  INITIALIZE p_cod_comprador TO NULL
  SELECT cod_comprador INTO p_cod_comprador
    FROM comprador
   WHERE cod_empresa = p_cod_empresa
     AND login       = p_user

  CLEAR FORM
  LET l_primeira_vez    = TRUE
  LET l_informou_versao = FALSE

  IF NOT g_ies_genero THEN
     DISPLAY "                    " AT 05,51    #Vanderlei - OS 372096 #
  ELSE
     CALL log4050_altera_atributo("lb_pedido","text","")
  END IF

  LET int_flag = 0
  CONSTRUCT BY NAME where_clause ON ordem_sup.cod_empresa,
                                    ordem_sup.num_oc,
                                    ordem_sup.num_versao,
                                    ordem_sup.ies_situa_oc,
                                    ordem_sup.cod_item

  BEFORE FIELD cod_empresa
    IF l_primeira_vez THEN
       DISPLAY p_cod_empresa TO cod_empresa
       LET l_primeira_vez = FALSE
       NEXT FIELD num_oc
    END IF
    IF NOT m_possui_centraliz THEN
       NEXT FIELD num_oc
    END IF
    IF g_ies_grafico THEN
       --#  CALL fgl_dialog_setkeylabel("Control-Z", NULL)
    ELSE
       DISPLAY "--------" AT 3,59
    END IF

  BEFORE FIELD cod_item
    IF g_ies_grafico THEN
       --# CALL fgl_dialog_setkeylabel("Control-Z", "Zoom")
    ELSE
       DISPLAY "( Zoom )" AT 3,59
    END IF

  AFTER FIELD cod_item
    IF g_ies_grafico THEN
       --#  CALL fgl_dialog_setkeylabel("Control-Z", NULL)
    ELSE
       DISPLAY "--------" AT 3,59
    END IF

  BEFORE FIELD ies_situa_oc
    IF g_ies_grafico THEN
       --# CALL fgl_dialog_setkeylabel("Control-Z", "Zoom")
    ELSE
       DISPLAY "( Zoom )" AT 3,59
    END IF

  AFTER FIELD ies_situa_oc
    IF g_ies_grafico THEN
       --# CALL fgl_dialog_setkeylabel("Control-Z", "")
    ELSE
       DISPLAY "--------" AT 3,59
    END IF

  ON KEY (control-w,f1)
     #lds IF NOT LOG_logix_versao5() THEN
     #lds CONTINUE CONSTRUCT
     #lds END IF
    CALL sup036_help()

  ON KEY (control-z, f4)
    CALL sup0360_popups()

  AFTER CONSTRUCT
    IF int_flag = 0 THEN
       LET l_aux = get_fldbuf(num_versao)
       IF l_aux IS NOT NULL THEN
          LET l_informou_versao = TRUE
       END IF
    END IF

  END CONSTRUCT

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_sup03601

  IF int_flag THEN
     LET p_ordem_sup.* = p_ordem_supr.*
     LET p_formonly.* = p_formonlyr.*
     DISPLAY BY NAME p_ordem_sup.cod_empresa,
                     p_ordem_sup.num_oc,
                     p_ordem_sup.num_versao,
                     p_ordem_sup.ies_situa_oc,
                     p_ordem_sup.cod_item,
                     p_formonly.*
     ERROR "Consulta cancelada"
     RETURN
  END IF

  IF m_possui_centraliz THEN
     LET sql_stmt = "SELECT ordem_sup.* FROM ordem_sup, centraliz_emp_sup ",
                     "WHERE ",where_clause CLIPPED,
                      " AND ordem_sup.cod_empresa = centraliz_emp_sup.cod_empresa "
  ELSE
     LET sql_stmt = "SELECT ordem_sup.* FROM ordem_sup ",
                     "WHERE ",where_clause  CLIPPED,
                      " AND ordem_sup.cod_empresa = """,p_cod_empresa,""" "
  END IF

  IF NOT l_informou_versao THEN
     LET sql_stmt = sql_stmt CLIPPED, " AND ordem_sup.ies_versao_atual =  ""S"" "
  END IF

  LET m_cursor_saldo = FALSE

  PREPARE var_query FROM sql_stmt
  DECLARE cq_ordem_sup SCROLL CURSOR WITH HOLD FOR var_query
  OPEN cq_ordem_sup
  FETCH cq_ordem_sup INTO p_ordem_sup.*
  IF sqlca.sqlcode = NOTFOUND THEN
     CLEAR FORM
     CALL log0030_mensagem( "Argumentos de pesquisa nao encontrados", "exclamation")
     LET p_ies_cons = FALSE
  ELSE
     LET p_ies_cons = TRUE
     CALL sup036_exibe_dados("TOTAL")
  END IF
 END FUNCTION

#------------------------------------------------#
 FUNCTION sup036_consulta_prog_ordem_sup_saldos()
#------------------------------------------------#
  DEFINE sql_stmt, where_clause, where_clause1, where_clause2 CHAR(1000),
         l_primeira_vez    SMALLINT,
         l_aux             CHAR(100),
         l_informou_versao SMALLINT

  CALL sup0538_inicializa_variaveis()

  IF p_num_args <> 0 THEN
     LET sql_stmt = "SELECT ordem_sup.* ",
                      "FROM ordem_sup ",
                     "WHERE ordem_sup.cod_empresa = """,p_cod_empresa_arg,""" ",
                       "AND ordem_sup.num_oc = ",p_num_oc_arg," ",
                       "AND ordem_sup.num_versao = ",p_num_versao_arg," ",
                       "AND ordem_sup.ies_situa_oc NOT IN (""L"",""C"") "
     LET p_num_args = 0
  ELSE
     CALL log006_exibe_teclas("01 02 03 07",p_versao)
     CURRENT WINDOW IS w_sup03601

     LET p_ordem_supr.* = p_ordem_sup.*

     INITIALIZE p_ordem_sup.* TO NULL
     INITIALIZE where_clause, where_clause1, sql_stmt  TO NULL

     LET l_primeira_vez = TRUE
     LET l_informou_versao = FALSE

     CLEAR FORM

     IF NOT g_ies_genero THEN
        DISPLAY "                    " AT 05,51    #Vanderlei - OS 372096 #
     ELSE
        CALL log4050_altera_atributo("lb_pedido","text","")
     END IF

     LET int_flag = 0
     CONSTRUCT BY NAME where_clause ON ordem_sup.cod_empresa,
                                       ordem_sup.num_oc,
                                       ordem_sup.num_versao,
                                       ordem_sup.ies_situa_oc,
                                       ordem_sup.cod_item

     BEFORE FIELD cod_empresa
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel("Control-Z", "")
       ELSE
          DISPLAY "--------" AT 3,59
       END IF

       IF l_primeira_vez THEN
          DISPLAY p_cod_empresa TO cod_empresa
          LET l_primeira_vez = FALSE
          NEXT FIELD num_oc
       END IF
       IF NOT m_possui_centraliz THEN
          NEXT FIELD num_oc
       END IF

     BEFORE FIELD cod_item
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel("Control-Z", "Zoom")
       ELSE
          DISPLAY "( Zoom )" AT 3,59
       END IF

     AFTER FIELD cod_item
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel("Control-Z", "")
       ELSE
          DISPLAY "--------" AT 3,59
       END IF

     BEFORE FIELD ies_situa_oc
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel("Control-Z", "Zoom")
       ELSE
          DISPLAY "( Zoom )" AT 3,59
       END IF

     AFTER FIELD ies_situa_oc
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel("Control-Z", "")
       ELSE
          DISPLAY "--------" AT 3,59
       END IF

     ON KEY (control-w,f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE CONSTRUCT
        #lds END IF
       CALL sup036_help()

     ON KEY (control-z, f4)
       CALL sup0360_popups()

     AFTER CONSTRUCT
       IF int_flag = 0 THEN
          LET l_aux = get_fldbuf(num_versao)
          IF l_aux IS NOT NULL THEN
             LET l_informou_versao = TRUE
          END IF
       END IF

     END CONSTRUCT

     CALL log006_exibe_teclas("01",p_versao)
     CURRENT WINDOW IS w_sup03601

     IF int_flag THEN
        LET p_ordem_sup.* = p_ordem_supr.*
        LET p_formonly.* = p_formonlyr.*
        DISPLAY BY NAME p_ordem_sup.cod_empresa,
                        p_ordem_sup.num_oc,
                        p_ordem_sup.num_versao,
                        p_ordem_sup.ies_situa_oc,
                        p_ordem_sup.qtd_solic,
                        p_ordem_sup.cod_item,
                        p_formonly.*
        ERROR "Consulta cancelada"
        RETURN
     END IF

     IF m_possui_centraliz THEN
        LET sql_stmt = "SELECT ordem_sup.* ",
                         "FROM ordem_sup, centraliz_emp_sup ",
                        "WHERE ",where_clause  CLIPPED," ",
                          "AND ordem_sup.cod_empresa = centraliz_emp_sup.cod_empresa ",
                          "AND ordem_sup.ies_situa_oc NOT IN (""L"",""C"") "
     ELSE
        LET sql_stmt = "SELECT ordem_sup.* ",
                         "FROM ordem_sup ",
                        "WHERE ",where_clause  CLIPPED," ",
                          "AND ordem_sup.cod_empresa = """,p_cod_empresa,""" ",
                          "AND ordem_sup.ies_situa_oc NOT IN (""L"",""C"") "
     END IF

     IF NOT l_informou_versao THEN
        LET sql_stmt = sql_stmt CLIPPED, " AND ordem_sup.ies_versao_atual =  ""S"" "
     END IF
  END IF

  LET m_cursor_saldo = TRUE

  PREPARE var_query2 FROM sql_stmt
  DECLARE cq_ordem_s SCROLL CURSOR WITH HOLD FOR var_query2

  OPEN cq_ordem_s
  FETCH cq_ordem_s INTO p_ordem_sup.*

  IF sqlca.sqlcode = NOTFOUND THEN
     CLEAR FORM
     CALL log0030_mensagem( " Argumentos de pesquisa nao encontrados. ","exclamation")
     LET p_ies_cons = FALSE
  ELSE
     LET p_ies_cons = TRUE
     CALL sup036_exibe_dados("TOTAL")
  END IF
 END FUNCTION

#-----------------------------------#
 FUNCTION sup036_paginacao(p_funcao)
#-----------------------------------#
  DEFINE p_funcao CHAR(20)

  IF p_ies_cons  THEN
     LET p_ordem_supr.* = p_ordem_sup.*
     LET p_formonlyr.* = p_formonly.*
     WHILE TRUE
        CASE
        WHEN p_funcao = "SEGUINTE"
           IF m_cursor_saldo = TRUE THEN
              FETCH NEXT  cq_ordem_s   INTO p_ordem_sup.*
           ELSE
              FETCH NEXT  cq_ordem_sup INTO p_ordem_sup.*
           END IF

        WHEN p_funcao = "ANTERIOR"
           IF m_cursor_saldo = TRUE THEN
              FETCH PREVIOUS cq_ordem_s   INTO p_ordem_sup.*
           ELSE
              FETCH PREVIOUS cq_ordem_sup INTO p_ordem_sup.*
           END IF
        END CASE

        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao existem mais itens nesta direcao"
           LET p_ordem_sup.* = p_ordem_supr.*
           LET p_formonly.* = p_formonlyr.*
           EXIT WHILE
        END IF

        SELECT * INTO p_ordem_sup.*
          FROM ordem_sup
         WHERE cod_empresa      = p_ordem_sup.cod_empresa
           AND num_oc           = p_ordem_sup.num_oc
           AND num_versao       = p_ordem_sup.num_versao
        IF sqlca.sqlcode = 0 THEN
           CALL sup036_exibe_dados("TOTAL")
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa"
  END IF
 END FUNCTION

#--------------------------------------------#
 FUNCTION sup036_exibe_prog_entrega(l_funcao)
#--------------------------------------------#
  DEFINE l_funcao CHAR(8),
         l_ind    SMALLINT
  DEFINE sql_stmt, where_clause, where_clause1, where_clause2 CHAR(1000)

  LET p_cont = 0
  LET p_cont_dest = 0

  INITIALIZE p_programas_oc, p_prog_sal, ma_qtd_reservada TO NULL

  IF p_cons_saldo = "S" THEN
     LET sql_stmt = "SELECT * FROM prog_ordem_sup WHERE ",
                    "prog_ordem_sup.cod_empresa = """,p_ordem_sup.cod_empresa,""" ",
                    "AND prog_ordem_sup.num_oc = ",p_ordem_sup.num_oc," ",
                    "AND prog_ordem_sup.num_versao = ",p_ordem_sup.num_versao," ",
                    "AND prog_ordem_sup.qtd_solic >= prog_ordem_sup.qtd_recebida ",
                    "AND prog_ordem_sup.ies_situa_prog IN (""F"",""P"") ",
                    "ORDER BY dat_entrega_prev "
  ELSE
     LET sql_stmt = "SELECT * FROM prog_ordem_sup WHERE ",
                    "prog_ordem_sup.cod_empresa = """,p_ordem_sup.cod_empresa,""" ",
                    "AND prog_ordem_sup.num_oc = ",p_ordem_sup.num_oc," ",
                    "AND prog_ordem_sup.num_versao = ",p_ordem_sup.num_versao," ",
                    "ORDER BY dat_entrega_prev "
  END IF

  PREPARE var_query3 FROM sql_stmt
  DECLARE ce_prog_ordem_sup SCROLL CURSOR WITH HOLD FOR var_query3
  FOREACH ce_prog_ordem_sup INTO p_prog_ordem_sup.*
     LET p_cont = p_cont + 1

     LET p_prog_ordem_sup.qtd_solic    = p_prog_ordem_sup.qtd_solic / m_fat_conver
     LET p_prog_ordem_sup.qtd_recebida = p_prog_ordem_sup.qtd_recebida / m_fat_conver

     LET p_programas_oc[p_cont].inf_complement    = "*"
     LET p_programas_oc[p_cont].num_prog_entrega  = p_prog_ordem_sup.num_prog_entrega
     LET p_programas_oc[p_cont].ies_situa_prog    = p_prog_ordem_sup.ies_situa_prog
     LET p_programas_oc[p_cont].dat_entrega_prev  = p_prog_ordem_sup.dat_entrega_prev
     LET p_programas_oc[p_cont].qtd_solic         = p_prog_ordem_sup.qtd_solic
     LET p_programas_oc[p_cont].qtd_recebida      = p_prog_ordem_sup.qtd_recebida
     LET p_programas_oc[p_cont].num_pedido_fornec = p_prog_ordem_sup.num_pedido_fornec
     LET ma_qtd_reservada[p_cont] = sup477_baixa_saldo_pedido(p_ordem_sup.cod_empresa,
                                                              p_ordem_sup.num_pedido,
                                                              p_ordem_sup.num_oc,
                                                              p_prog_ordem_sup.num_prog_entrega)
     LET p_prog_sal[p_cont].num_prog_entrega  = p_programas_oc[p_cont].num_prog_entrega
     LET p_prog_sal[p_cont].ies_situa_prog    = p_programas_oc[p_cont].ies_situa_prog
     LET p_prog_sal[p_cont].dat_entrega_prev  = p_programas_oc[p_cont].dat_entrega_prev
     LET p_prog_sal[p_cont].qtd_solic         = p_programas_oc[p_cont].qtd_solic
     LET p_prog_sal[p_cont].qtd_recebida      = p_programas_oc[p_cont].qtd_recebida
     LET p_prog_sal[p_cont].num_pedido_fornec = p_programas_oc[p_cont].num_pedido_fornec
     LET p_prog_sal[p_cont].ies_atualiza      = "N"

     LET p_inf_complement[p_cont].dat_origem      = p_prog_ordem_sup.dat_origem
     LET p_inf_complement[p_cont].dat_palpite     = p_prog_ordem_sup.dat_palpite
     LET p_inf_complement[p_cont].qtd_em_transito = p_prog_ordem_sup.qtd_em_transito
     LET p_inf_complement[p_cont].tex_observacao  = p_prog_ordem_sup.tex_observacao

     IF p_ies_distr_obj = "S" THEN
        IF  p_prog_ordem_sup.ies_situa_prog != "L"
        AND p_prog_ordem_sup.ies_situa_prog != "C" THEN
           LET p_cont_dest = p_cont_dest + 1
           CALL sup036_carrega_w_dest() RETURNING p_status
        END IF
     END IF
  END FOREACH

  LET m_total = p_cont # 547191

  FOR l_ind = (p_cont + 1) to 499
     INITIALIZE p_inf_complement[l_ind].* TO NULL
  END FOR

  IF l_funcao = "CONSULTA" THEN
     IF g_pais = "AR" THEN
        LET m_window = "sup0360b"
     ELSE
        LET m_window = "sup03602"
     END IF

     CALL log006_exibe_teclas("02 17 18",p_versao)
     CALL log130_procura_caminho(m_window) RETURNING comando
     OPEN WINDOW w_sup03602 AT 13,07 WITH FORM comando
          ATTRIBUTE(BORDER,MESSAGE LINE LAST,PROMPT LINE LAST,FORM LINE 1)

     LET int_flag = 0
     CALL set_count(p_cont)
     DISPLAY ARRAY p_programas_oc TO s_sup03602.*

     ON KEY(f1, control-t)
        LET pa_curr = arr_curr()
        IF  p_ies_distr_obj = "S"
        AND p_programas_oc[pa_curr].dat_entrega_prev IS NOT NULL THEN
           IF sup036_carrega_dest_prog(pa_curr,"CONSULTA") = FALSE THEN
              EXIT DISPLAY
           END IF
        END IF
     END DISPLAY

     CLOSE WINDOW w_sup03602

     CALL log006_exibe_teclas("01",p_versao)
     CURRENT WINDOW IS w_sup03601
  END IF
 END FUNCTION

#---------------------------------------#
 FUNCTION sup036_modifica_prog_entrega()
#---------------------------------------#
  INITIALIZE p_prog_sal, p_prog_situa, p_programas_oc TO NULL

  LET p_contador        = 0
  LET p_cont            = 0
  LET p_saldo_liquidado = 0

  INITIALIZE p_programas_oc, p_prog_situa, p_prog_sal TO NULL

  DECLARE c_prog_ordem_sup CURSOR FOR
   SELECT * FROM prog_ordem_sup
    WHERE cod_empresa    = p_ordem_sup.cod_empresa
      AND num_oc         = p_ordem_sup.num_oc
      AND num_versao     = p_ordem_sup.num_versao
      AND ies_situa_prog IN ("P","F","L")
    ORDER BY dat_entrega_prev

  FOREACH c_prog_ordem_sup INTO p_prog_ordem_sup.*
     LET p_prog_ordem_sup.qtd_solic    = p_prog_ordem_sup.qtd_solic / m_fat_conver
     LET p_prog_ordem_sup.qtd_recebida = p_prog_ordem_sup.qtd_recebida / m_fat_conver

#adriana 24/08
     LET p_contador = p_contador + 1
     LET p_prog_situa[p_contador].inf_complement    = "*"
     LET p_prog_situa[p_contador].num_prog_entrega  = p_prog_ordem_sup.num_prog_entrega
     LET p_prog_situa[p_contador].ies_situa_prog    = p_prog_ordem_sup.ies_situa_prog
     LET p_prog_situa[p_contador].dat_entrega_prev  = p_prog_ordem_sup.dat_entrega_prev
     LET p_prog_situa[p_contador].qtd_solic         = p_prog_ordem_sup.qtd_solic
     LET p_prog_situa[p_contador].qtd_recebida      = p_prog_ordem_sup.qtd_recebida
     LET p_prog_situa[p_contador].num_pedido_fornec = p_prog_ordem_sup.num_pedido_fornec
#fim adriana

     IF p_prog_ordem_sup.ies_situa_prog = "P"
     OR p_prog_ordem_sup.ies_situa_prog = "F" THEN
        LET p_cont = p_cont + 1
        LET p_programas_oc[p_cont].inf_complement    = "*"
        LET p_programas_oc[p_cont].num_prog_entrega  = p_prog_ordem_sup.num_prog_entrega
        LET p_programas_oc[p_cont].ies_situa_prog    = p_prog_ordem_sup.ies_situa_prog
        LET p_programas_oc[p_cont].dat_entrega_prev  = p_prog_ordem_sup.dat_entrega_prev
        LET p_programas_oc[p_cont].qtd_solic         = p_prog_ordem_sup.qtd_solic
        LET p_programas_oc[p_cont].qtd_recebida      = p_prog_ordem_sup.qtd_recebida
        LET p_programas_oc[p_cont].num_pedido_fornec = p_prog_ordem_sup.num_pedido_fornec
        LET p_prog_sal[p_cont].num_prog_entrega  = p_programas_oc[p_cont].num_prog_entrega
        LET p_prog_sal[p_cont].ies_situa_prog    = p_programas_oc[p_cont].ies_situa_prog
        LET p_prog_sal[p_cont].dat_entrega_prev  = p_programas_oc[p_cont].dat_entrega_prev
        LET p_prog_sal[p_cont].qtd_solic         = p_programas_oc[p_cont].qtd_solic
        LET p_prog_sal[p_cont].qtd_recebida      = p_programas_oc[p_cont].qtd_recebida
        LET p_prog_sal[p_cont].num_pedido_fornec = p_programas_oc[p_cont].num_pedido_fornec
        LET p_prog_sal[p_cont].ies_atualiza      = "N"
     ELSE
        LET p_saldo_liquidado = p_saldo_liquidado + p_prog_ordem_sup.qtd_solic
     END IF
  END FOREACH

  IF g_pais = "AR" THEN
     LET m_window = "sup0360d"
  ELSE
     LET m_window = "sup03604"
  END IF

  CALL log006_exibe_teclas("01 02 07 17 18",p_versao)
  CALL log1300_procura_caminho("sup03602",m_window) RETURNING comando
  OPEN WINDOW w_sup03602 AT 13,07 WITH FORM comando
       ATTRIBUTE(BORDER,MESSAGE LINE LAST,PROMPT LINE LAST,FORM LINE 1)
#adriana 24/08
  LET p_operacao = "MODIFICA"
#fim adriana
  CALL sup036_input_array()
  CLOSE WINDOW w_sup03602
  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_sup03601

  IF int_flag = 0 THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF
 END FUNCTION

#-----------------------------#
 FUNCTION sup036_input_array()
#-----------------------------#
  DEFINE l_num_pedido_fornec_ant LIKE prog_ordem_sup.num_pedido_fornec,
         p_indicador             SMALLINT,
         l_qtd_reg               SMALLINT,
         l_msg                   CHAR(130),
         l_qtd_solic_total       LIKE prog_ordem_sup.qtd_solic

  IF p_ies_distr_obj = "S" THEN
     IF NOT g_ies_genero THEN
        DISPLAY "CONTROL-T - objeTivo " AT 10,02
     ELSE
        CALL log4050_altera_atributo("lb_objetivo","text","CONTROL-T - objeTivo")
        # CALL ui.Interface.refresh()
     END IF

     DELETE FROM w_dest
     LET p_cons_saldo = "S"
     CALL sup036_exibe_prog_entrega("INCLUSAO")
  END IF

  CALL sup0772_atualiza_oc_oln_gao(p_ordem_sup.cod_empresa,
                                   p_ordem_sup.num_oc,
                                   p_ordem_supr.qtd_solic,
                                   p_ordem_sup.pre_unit_oc,
                                   TODAY,
                                   "OC",
                                   "SUP0360",
                                   0,
                                   0,
                                   0,
                                   TRUE,  # Somente atualizar se a OC
                                          # estiver APROVADA
                                   TRUE,  # Buscar VAL_PREVISTO caso o
                                          # preço estiver zerado
                                   TRUE,  # Considerar o Valor do IPI
                                   FALSE, # Trata-se de Recebimento
                                   FALSE, # Trata-se de Devolução à Fornecedor
                                   "EX")
       RETURNING p_status, l_msg
  IF p_status = FALSE THEN
     CALL log0030_mensagem(l_msg,"exclamation")
     IF g_ies_grafico = FALSE THEN
        SLEEP 2
     END IF
     LET p_houve_erro = TRUE
  END IF

  IF NOT p_houve_erro THEN
    WHILE TRUE
     CALL set_count(p_cont)

--#  CALL fgl_keysetlabel('insert',NULL)
--#  CALL fgl_keysetlabel('delete',NULL)
     LET int_flag = 0
     INPUT ARRAY p_programas_oc WITHOUT DEFAULTS FROM s_sup03602.*
     BEFORE INPUT
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel("Control-Z", NULL)
       END IF

     BEFORE ROW
        LET sc_curr = scr_line()
        LET pa_curr = arr_curr()
        LET l_num_pedido_fornec_ant = p_programas_oc[pa_curr].num_pedido_fornec
        IF l_num_pedido_fornec_ant IS NULL THEN
           LET l_num_pedido_fornec_ant = " "
        END IF
        IF p_ies_distr_obj = "S" THEN
           LET p_cont_dest = 0
           SELECT COUNT(*) INTO p_cont_dest
             FROM w_dest
            WHERE cod_empresa = p_ordem_sup.cod_empresa
              AND num_oc      = p_ordem_sup.num_oc
              AND num_versao  = p_ordem_sup.num_versao
        END IF

     AFTER  FIELD inf_complement
        IF p_programas_oc[pa_curr].inf_complement <> "*" THEN
           LET p_programas_oc[pa_curr].inf_complement = "*"
           DISPLAY "*" TO s_sup03602[sc_curr].inf_complement
        END IF

     AFTER FIELD dat_entrega_prev
        IF p_programas_oc[pa_curr].dat_entrega_prev IS NULL THEN
           IF p_programas_oc[pa_curr].qtd_solic IS NOT NULL THEN
              ERROR " Informe a data de previsao de entrega "
              NEXT FIELD dat_entrega_prev
           END IF
        ELSE
           IF p_ordem_sup.num_pedido = 0 AND p_ies_dat_retro = "N" THEN
              IF  p_programas_oc[pa_curr].dat_entrega_prev < TODAY
              AND p_programas_oc[pa_curr].qtd_solic IS NOT NULL THEN
                 ERROR " Data de previsao de entrega nao pode ser menor a data de hoje. "
                 NEXT FIELD dat_entrega_prev
              END IF
           END IF
           IF sup036_verifica_data_valida(pa_curr) = FALSE THEN
              ERROR "Data de entrega nao e dia util"
              NEXT FIELD dat_entrega_prev
           END IF
        END IF

       #547191
       IF find4GLFunction('supy43_cliente_55') THEN
          IF supy43_cliente_55(p_cod_empresa)   = TRUE THEN
             IF sup0156_verifica_conta_contabel(p_cod_empresa,p_ordem_sup.num_oc) = TRUE THEN

                IF pa_curr < m_total THEN
                   IF fgl_lastkey() = fgl_keyval("UP") OR
                      fgl_lastkey() = fgl_keyval("LEFT") THEN
                      LET pa_curr = pa_curr - 1
                   ELSE
                      LET pa_curr = pa_curr + 1
                   END IF
                   LET sc_curr = pa_curr MOD 7
                   --#CALL fgl_dialog_setcurrline(sc_curr,pa_curr)
                   NEXT FIELD dat_entrega_prev
                ELSE
                   EXIT INPUT
                END IF
             END IF
          END IF
       END IF

     BEFORE FIELD qtd_solic
        IF p_ies_distr_obj = "S" THEN
           IF p_cont_dest > 0 THEN
              NEXT FIELD num_pedido_fornec
           END IF
        END IF

     AFTER FIELD qtd_solic
        IF p_programas_oc[pa_curr].ies_situa_prog IS NOT NULL THEN
           IF p_programas_oc[pa_curr].qtd_solic IS NULL THEN
              ERROR " Informe a quantidade pedida "
              NEXT FIELD qtd_solic
           END IF
        END IF
        IF p_programas_oc[pa_curr].qtd_solic IS NOT NULL THEN
           IF p_programas_oc[pa_curr].dat_entrega_prev IS NULL THEN
              ERROR " Informe a data de previsao de entrega "
              NEXT FIELD dat_entrega_prev
           END IF
           IF p_programas_oc[pa_curr].qtd_solic < 0 THEN
              ERROR "Quantidade incorreta."
              NEXT FIELD qtd_solic
           END IF

           IF ma_qtd_reservada[pa_curr] IS NOT NULL AND ma_qtd_reservada[pa_curr] <> 0 THEN
              IF p_programas_oc[pa_curr].qtd_solic < ma_qtd_reservada[pa_curr] THEN
                 LET l_msg = "Existe pendência de contagem para esta programação (quantidade: ", ma_qtd_reservada[pa_curr] USING "<<<,<<<,<<<,<<&.&&&", ")."
                 CALL log0030_mensagem(l_msg,"exclamation")
                 NEXT FIELD qtd_solic
              END IF
           END IF
        END IF

     BEFORE FIELD ies_situa_prog
        IF g_ies_grafico THEN
           --# CALL fgl_dialog_setkeylabel("Control-Z","Zoom")
        END IF
        IF p_programas_oc[pa_curr].ies_situa_prog IS NULL THEN
           IF p_ordem_sup.ies_situa_oc = "P" THEN
              LET p_programas_oc[pa_curr].ies_situa_prog = "P"
           ELSE
              LET p_programas_oc[pa_curr].ies_situa_prog = "F"
           END IF
           DISPLAY p_programas_oc[pa_curr].ies_situa_prog
                TO s_sup03602[sc_curr].ies_situa_prog
        END IF

     AFTER FIELD ies_situa_prog
        IF g_ies_grafico THEN
           --# CALL fgl_dialog_setkeylabel("Control-Z", NULL)
        END IF
        LET pa_curr = arr_curr()
        LET sc_curr = scr_line()
        IF sup0360_existe_recebimento(p_programas_oc[pa_curr].num_prog_entrega) THEN
           IF p_programas_oc[pa_curr].ies_situa_prog IS NULL
           OR p_programas_oc[pa_curr].ies_situa_prog = "P"
           OR p_programas_oc[pa_curr].ies_situa_prog = "C" THEN
              ERROR " Situacao do programa de entrega invalido. Existe recebimento."
              NEXT FIELD ies_situa_prog
           END IF

           IF p_programas_oc[pa_curr].ies_situa_prog = "L" THEN
              IF sup477_baixa_saldo_pedido(p_ordem_sup.cod_empresa,
                                           p_ordem_sup.num_pedido,
                                           p_ordem_sup.num_oc,
                                           p_programas_oc[pa_curr].num_prog_entrega) > 0 THEN
                 ERROR "Existe quantidade em processo de contagem no recebimento. "
                 NEXT FIELD ies_situa_prog
              END IF
           END IF
        END IF

        IF (p_programas_oc[pa_curr].ies_situa_prog = "P"
        AND p_ordem_sup.ies_situa_oc <> "P")
        OR (p_programas_oc[pa_curr].ies_situa_prog = "F"
        AND p_ordem_sup.ies_situa_oc <> "A"
        AND p_ordem_sup.ies_situa_oc <> "D"
        AND p_ordem_sup.ies_situa_oc <> "T") THEN
           IF (p_ordem_sup.ies_situa_oc = "R" AND sup0360_verifica_nova_versao_oc(p_ordem_sup.num_oc)) THEN
           ELSE
              ERROR "Situacao da programacao de entrega difere da situacao da ordem de compra"
              NEXT FIELD ies_situa_prog
           END IF
        END IF

        IF p_cont_dest > 0 AND p_programas_oc[pa_curr].dat_entrega_prev IS NOT NULL THEN
           IF sup036_carrega_dest_prog(pa_curr,"INCLUSAO") = FALSE THEN
              EXIT INPUT
           END IF
           LET p_ordem_sup.qtd_solic = p_ordem_sup.qtd_solic -
                                       (p_programas_oc[pa_curr].qtd_solic - p_tot_prog)
           LET p_programas_oc[pa_curr].qtd_solic = p_tot_prog
           DISPLAY p_programas_oc[pa_curr].qtd_solic TO s_sup03602[sc_curr].qtd_solic
           IF p_programas_oc[pa_curr].qtd_solic = 0 THEN
              ERROR " Quantidade nao pode ser zero. "
              NEXT FIELD dat_entrega_prev
           END IF
        END IF
        IF pa_curr > p_cont THEN
           LET p_cont = pa_curr
        END IF

     AFTER FIELD num_pedido_fornec
        IF l_num_pedido_fornec_ant <> p_programas_oc[pa_curr].num_pedido_fornec THEN

           IF NOT sup0360_valida_num_pedido_fornec_array() THEN
              CALL log0030_mensagem(" Número do pedido de fornecedor já informado nesta OC. ", "exclamation")
              NEXT FIELD num_pedido_fornec
           END IF

           IF NOT sup2701_valida_pedido_fornecedor(p_cod_empresa,
                                                   p_prog_ordem_sup.num_oc,
                                                   p_programas_oc[pa_curr].num_pedido_fornec) THEN
              CALL log0030_mensagem(" Número do pedido de fornecedor já informado em outra OC ou programação. ", "exclamation")
              NEXT FIELD num_pedido_fornec
           END IF

        END IF

        #O.S.518585

        IF NOT find4GLFunction('supy80_cliente_970') THEN
           IF p_programas_oc[pa_curr].num_pedido_fornec IS NOT NULL
              AND p_programas_oc[pa_curr].num_pedido_fornec <> " "
              AND (p_ordem_sup.num_pedido = 0) THEN

              CALL log0030_mensagem("Ordem de compra ainda não possui pedido de compra","exclamation")
              NEXT FIELD num_pedido_fornec
           END IF
        END IF
        #O.S.518585

     ON KEY (control-w,f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL sup036_help()

     ON KEY (control-z, f4)
        CALL sup0360_popups()

     AFTER INSERT
        LET p_cont = p_cont + 1

     ON KEY (control-p)
        INITIALIZE p_compl.* TO NULL
        LET pa_curr = arr_curr()
        CALL sup414_manutencao_inf_complement(p_ordem_sup.cod_empresa,
                                              p_ordem_sup.num_oc,
                                              p_ordem_sup.num_versao,
                                              p_programas_oc[pa_curr].num_prog_entrega)
             RETURNING p_compl.*
        LET p_inf_complement[pa_curr].dat_origem      = p_compl.dat_origem
        LET p_inf_complement[pa_curr].dat_palpite     = p_compl.dat_palpite
        LET p_inf_complement[pa_curr].qtd_em_transito = p_compl.qtd_em_transito / m_fat_conver
        LET p_inf_complement[pa_curr].tex_observacao  = p_compl.tex_observacao

        CALL log006_exibe_teclas("01 02 03 07",p_versao)
        CURRENT WINDOW IS w_sup03602

     ON KEY(control-t)
        IF  p_ies_distr_obj = "S"
        AND p_programas_oc[pa_curr].dat_entrega_prev IS NOT NULL THEN
           IF sup036_carrega_dest_prog(pa_curr,"INCLUSAO") = FALSE THEN
              EXIT INPUT
           END IF
           LET p_ordem_sup.qtd_solic = p_ordem_sup.qtd_solic -
                                       (p_programas_oc[pa_curr].qtd_solic - p_tot_prog)
           LET p_programas_oc[pa_curr].qtd_solic = p_tot_prog
           DISPLAY p_programas_oc[pa_curr].qtd_solic TO s_sup03602[sc_curr].qtd_solic
           IF p_programas_oc[pa_curr].qtd_solic = 0 THEN
              ERROR " Quantidade nao pode ser zero. "
              NEXT FIELD dat_entrega_prev
           END IF
        END IF

     #ldsON KEY (INSERT)
     #lds   CANCEL INSERT

     #ldsON KEY (DELETE)
     #lds   CANCEL DELETE

     AFTER INPUT
        LET l_qtd_reg = arr_count()
        IF int_flag THEN
           LET pa_curr = 1
           EXIT INPUT
        END IF

        LET pa_curr = arr_curr()
        IF p_programas_oc[pa_curr].ies_situa_prog IS NULL
        OR p_programas_oc[pa_curr].ies_situa_prog = " " THEN
           IF p_ordem_sup.ies_situa_oc = "P" THEN
              LET p_programas_oc[pa_curr].ies_situa_prog = "P"
           ELSE
              LET p_programas_oc[pa_curr].ies_situa_prog = "F"
           END IF
        END IF

        LET p_ordem_sup.dat_entrega_prev = p_programas_oc[1].dat_entrega_prev
        LET l_qtd_solic_total = 0

        FOR p_indicador = 1 TO l_qtd_reg
           IF (p_programas_oc[p_indicador].ies_situa_prog = "P"
           AND p_ordem_sup.ies_situa_oc <> "P")
           OR (p_programas_oc[p_indicador].ies_situa_prog = "F"
           AND p_ordem_sup.ies_situa_oc <> "A"
           AND p_ordem_sup.ies_situa_oc <> "D"
           AND p_ordem_sup.ies_situa_oc <> "T") THEN
              IF (p_ordem_sup.ies_situa_oc = "R" AND sup0360_verifica_nova_versao_oc(p_ordem_sup.num_oc)) THEN
              ELSE
                 ERROR "Situacao da programacao de entrega difere da situacao da ordem de compra"
                 NEXT FIELD ies_situa_prog
              END IF
           END IF
           IF p_programas_oc[p_indicador].dat_entrega_prev IS NULL THEN
              IF p_programas_oc[p_indicador].qtd_solic IS NOT NULL THEN
                 ERROR "Informe a data de previsao de entrega"
                 NEXT FIELD dat_entrega_prev
              END IF
           ELSE
              IF p_ordem_sup.num_pedido = 0 AND p_ies_dat_retro = "N" THEN
                 IF  p_programas_oc[p_indicador].dat_entrega_prev < TODAY
                 AND p_programas_oc[p_indicador].qtd_solic IS NOT NULL THEN
                    ERROR "Data de previsao de entrega nao pode ser menor a data de hoje"
                    NEXT FIELD dat_entrega_prev
                 END IF
              END IF
              IF sup036_verifica_data_valida(p_indicador) = FALSE THEN
                 ERROR "Data de entrega nao e dia util"
                 NEXT FIELD dat_entrega_prev
              END IF
              IF p_programas_oc[p_indicador].dat_entrega_prev <
                 p_ordem_sup.dat_entrega_prev THEN
                 LET p_ordem_sup.dat_entrega_prev =
                     p_programas_oc[p_indicador].dat_entrega_prev
              END IF

              IF ma_qtd_reservada[p_indicador] IS NOT NULL AND ma_qtd_reservada[p_indicador] <> 0 THEN
                 IF p_programas_oc[p_indicador].qtd_solic < ma_qtd_reservada[p_indicador] THEN
                    LET l_msg = "Existe pendência de contagem para programação nº ",
                    p_programas_oc[p_indicador].num_prog_entrega USING "<<<<<",
                    " (quantidade: ", ma_qtd_reservada[pa_curr] USING "<<<,<<<,<<<,<<&.&&&", ")."
                    CALL log0030_mensagem(l_msg,"exclamation")
                    NEXT FIELD qtd_solic
                 END IF
              END IF

              LET l_qtd_solic_total = l_qtd_solic_total + p_programas_oc[p_indicador].qtd_solic

           END IF
        END FOR

        #O.S. 559541
        IF NOT sup0360_verifica_qtd_solic_total(l_qtd_solic_total, p_ordem_sup.num_oc) THEN
           NEXT FIELD inf_complement
        END IF
        #O.S. 559541

        IF p_ies_distr_obj = "S" THEN
           IF sup036_verifica_obj() = FALSE THEN
              ERROR "Possui programacoes sem objetivos"
              NEXT FIELD dat_entrega_prev
           END IF
        END IF

     END INPUT

     IF int_flag THEN
        EXIT WHILE
     END IF

     IF sup036_verifica_situa() = FALSE THEN
        ERROR "Deve existir pelo menos um programa de entrega"
        CONTINUE WHILE
     END IF

     IF NOT sup036_atualiza_ordem() THEN
        CONTINUE WHILE
     END IF
     EXIT WHILE
    END WHILE
  END IF
 END FUNCTION

#------------------------------------------------------#
 FUNCTION sup036_carrega_dest_prog(p_ind_prog,p_funcao)
#------------------------------------------------------#
  DEFINE p_funcao        CHAR(10),
         p_num_prog      LIKE prog_ordem_sup.num_prog_entrega,
         p_cod_local     LIKE dest_prog_ord_sup.cod_local,
         p_qtd_particip  LIKE dest_prog_ord_sup.qtd_particip_comp,
         p_pct_particip  LIKE dest_prog_ord_sup.pct_particip_comp,
         p_num_docum     LIKE dest_prog_ord_sup.num_docum,
         p_ind_dest      SMALLINT,
         p_ind_prog      SMALLINT,
         l_ind           SMALLINT,
         sql_stmt        CHAR(2000)

  INITIALIZE p_dest_prog_ord,p_dest_prog_ord_sup.* TO NULL

  IF g_pais = "AR" THEN
     LET m_window = "sup0360c"
  ELSE
     LET m_window = "sup03603"
  END IF

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CALL log130_procura_caminho(m_window) RETURNING comando
  OPEN WINDOW w_sup03603 AT 10,25 WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  LET p_tot_prog = 0
  LET l_ind = 0

  INITIALIZE sql_stmt TO NULL
  LET sql_stmt = "SELECT cod_local, qtd_particip_comp, pct_particip_comp, num_docum "
  IF p_funcao = "INCLUSAO" THEN
     LET sql_stmt = sql_stmt CLIPPED, " FROM w_dest "
  ELSE
     LET sql_stmt = sql_stmt CLIPPED, " FROM dest_prog_ord_sup "
  END IF
  LET sql_stmt = sql_stmt CLIPPED,
      " WHERE cod_empresa = """,p_ordem_sup.cod_empresa,""" ",
      " AND num_oc = ", p_ordem_sup.num_oc,
      " AND num_versao = ",p_ordem_sup.num_versao
  IF p_funcao = "CONSULTA" THEN
     LET sql_stmt = sql_stmt CLIPPED,
     " AND num_prog_entrega = ",p_programas_oc[p_ind_prog].num_prog_entrega
  ELSE
     LET sql_stmt = sql_stmt CLIPPED,
     " AND num_prog_entrega = ",p_ind_prog
  END IF

  PREPARE var_query4 FROM sql_stmt
  DECLARE cq_dest_prg CURSOR FOR var_query4

  FOREACH cq_dest_prg INTO p_cod_local,p_qtd_particip,p_pct_particip,p_num_docum
     LET l_ind = l_ind + 1

     LET p_dest_prog_ord[l_ind].cod_local    = p_cod_local
     IF p_funcao = "CONSULTA" THEN
        LET p_dest_prog_ord[l_ind].qtd_particip = p_qtd_particip / m_fat_conver
     ELSE
        LET p_dest_prog_ord[l_ind].qtd_particip = p_qtd_particip
     END IF
     LET p_dest_prog_ord[l_ind].pct_particip = p_pct_particip
     LET p_dest_prog_ord[l_ind].num_docum    = p_num_docum
  END FOREACH

  CALL set_count(l_ind)

  IF p_funcao = "INCLUSAO" THEN
     LET int_flag = 0
     INPUT ARRAY p_dest_prog_ord WITHOUT DEFAULTS FROM s_sup03603.*

       BEFORE ROW
         LET mc_curr = scr_line()
         LET ma_curr = arr_curr()

       BEFORE FIELD cod_local
         LET mc_curr = scr_line()
         LET ma_curr = arr_curr()

         IF g_ies_grafico THEN
            --# CALL fgl_dialog_setkeylabel("Control-Z", "Zoom")
         ELSE
            DISPLAY "(Zoom)" AT 1,40
         END IF

       AFTER FIELD cod_local
         IF g_ies_grafico THEN
            --# CALL fgl_dialog_setkeylabel("Control-Z", NULL)
         ELSE
            DISPLAY "      " AT 1,40
         END IF

         IF p_dest_prog_ord[ma_curr].cod_local IS NOT NULL THEN
            IF sup036_verifica_local(p_dest_prog_ord[ma_curr].cod_local) = FALSE THEN
               ERROR "Codigo do local nao cadastrado."
               NEXT FIELD cod_local
            END IF
         END IF

       AFTER FIELD qtd_particip
         IF p_dest_prog_ord[ma_curr].cod_local IS NOT NULL THEN
            IF p_dest_prog_ord[ma_curr].qtd_particip IS NULL
            OR p_dest_prog_ord[ma_curr].qtd_particip < 0 THEN
               ERROR "Quantidade incorreta. "
               NEXT FIELD qtd_particip
            END IF
         END IF

       ON KEY (control-w,f1)
          #lds IF NOT LOG_logix_versao5() THEN
          #lds CONTINUE INPUT
          #lds END IF
         CALL sup036_help()

       ON KEY (control-z, f4)
         CALL sup0360_popups()

     END INPUT
  ELSE
     LET int_flag = 0
     DISPLAY ARRAY p_dest_prog_ord TO s_sup03603.*
  END IF

  LET int_flag = 0
  CLOSE WINDOW w_sup03603
  CURRENT WINDOW IS w_sup03602

  LET p_tot_prog = 0
  FOR l_ind = 1 TO 99
     IF p_dest_prog_ord[l_ind].cod_local IS NOT NULL THEN
        LET p_tot_prog = p_tot_prog + p_dest_prog_ord[l_ind].qtd_particip
     END IF
  END FOR

  IF sup036_grava_dest_ordem(p_ind_prog) = FALSE THEN
     LET p_houve_erro = TRUE
  END IF

  RETURN TRUE
 END FUNCTION

#----------------------------------------#
 FUNCTION sup036_verifica_local(p_local)
#----------------------------------------#
  DEFINE p_local     LIKE local.cod_local

  SELECT * FROM local
   WHERE local.cod_empresa  = p_cod_empresa
     AND local.cod_local    = p_local
  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF
 END FUNCTION

#------------------------------------#
 FUNCTION sup036_verifica_qtd_solic()
#------------------------------------#
  DEFINE l_ind SMALLINT

  LET p_qtd_tot_prog = 0

  FOR l_ind = 1 TO p_cont
     IF (p_programas_oc[l_ind].qtd_solic IS NULL
     OR  p_programas_oc[l_ind].qtd_solic = 0
     OR  p_programas_oc[l_ind].ies_situa_prog = "C") THEN
        CONTINUE FOR
     END IF
     LET p_qtd_tot_prog = p_qtd_tot_prog + p_programas_oc[l_ind].qtd_solic
  END FOR
 END FUNCTION

#-------------------------------------------#
 FUNCTION sup036_verifica_data_valida(l_ind)
#-------------------------------------------#
  DEFINE p_semana_sup     RECORD LIKE semana_sup.*,
         p_feriado_sup    RECORD LIKE feriado_sup.*,
         l_ind            SMALLINT,
         p_ies_dia_semana LIKE semana_sup.ies_dia_semana

  LET p_ies_dia_semana = WEEKDAY(p_programas_oc[l_ind].dat_entrega_prev)

  SELECT * INTO p_feriado_sup.* FROM feriado_sup
   WHERE cod_empresa = p_cod_empresa
     AND dat_ref     = p_programas_oc[l_ind].dat_entrega_prev

  SELECT * INTO p_semana_sup.* FROM semana_sup
   WHERE cod_empresa    = p_cod_empresa
     AND ies_dia_semana = p_ies_dia_semana

  IF sqlca.sqlcode = 0 THEN
     IF p_semana_sup.ies_situa <> "3" THEN
        IF (p_feriado_sup.ies_situa <> "3")  OR
           (p_feriado_sup.ies_situa IS NULL) THEN
           RETURN TRUE
        END IF
     ELSE
        IF (p_feriado_sup.ies_situa = "1")   OR
           (p_feriado_sup.ies_situa = "2")   THEN
           RETURN TRUE
        END IF
     END IF
  END IF
  RETURN FALSE
 END FUNCTION

#--------------------------------#
 FUNCTION sup036_atualiza_ordem()
#--------------------------------#
 DEFINE p_novo_tot_oc   LIKE ordem_sup.qtd_solic,
        l_qtd_score     LIKE ordem_sup.qtd_recebida

 CALL sup036_verifica_qtd_solic()

 LET p_novo_tot_oc = (p_qtd_tot_prog + p_saldo_liquidado)

 IF sup0360_verifica_pedido_score() = TRUE THEN
    LET l_qtd_score = p_qtd_solic_s - p_novo_tot_oc
    IF l_qtd_score <> 0 THEN
       IF sup0968_atualiza_tabela_score("2",
                                        p_ordem_sup.num_oc,
                                        p_ordem_sup.num_pedido,
                                        p_ordem_sup.cod_item,
                                        m_pedido_score,
                                        l_qtd_score) = FALSE THEN
          RETURN FALSE
       END IF
    END IF
 END IF

 WHENEVER ERROR CONTINUE
 UPDATE ordem_sup
    SET qtd_solic        = (p_novo_tot_oc * m_fat_conver),
        dat_entrega_prev = p_ordem_sup.dat_entrega_prev
  WHERE cod_empresa      = p_cod_empresa
    AND num_oc           = p_ordem_sup.num_oc
    AND ies_versao_atual = "S"
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CASE sqlca.sqlcode
    WHEN -250 CALL log0030_mensagem(" Registro sendo atualizado por outro usuario. Aguarde e tente novamente. ","exclamation")
    WHEN  100 CALL log0030_mensagem(" Registro nao mais existe na tabela. Execute a CONSULTA novamente. ","exclamation")
    OTHERWISE CALL log003_err_sql("MODIFICACAO","ORDEM_SUP")
    END CASE
    RETURN FALSE
 END IF

 IF p_qtd_solic_s <> p_novo_tot_oc THEN
    IF sup0360_sistema_argentino() THEN
       IF sup0360_existe_estouro_oc_contrato(p_ordem_sup.num_oc) THEN
          RETURN FALSE
       END IF
    END IF
 END IF

 LET p_ordem_sup.qtd_solic = p_novo_tot_oc

 IF NOT sup036_atualiza_dest_ordem_sup(p_novo_tot_oc) THEN
    RETURN FALSE
 END IF

 LET p_formonly.qtd_solic = p_novo_tot_oc
 DISPLAY BY NAME p_formonly.qtd_solic

 RETURN TRUE
END FUNCTION

#--------------------------------#
 FUNCTION sup036_verifica_situa()
#--------------------------------#
  DEFINE flag_situa_f,
         flag_situa_c,
         flag_situa_l    SMALLINT,
         p_ind1          SMALLINT,
         p_ind3          SMALLINT,
         p_conta         SMALLINT,
         sql_stmt        CHAR(500),
         l_ind           SMALLINT

  LET flag_situa_f = FALSE
  LET flag_situa_c = FALSE
  LET flag_situa_l = FALSE
  LET p_ind1       = 0
  LET p_ind3       = 0

  IF p_operacao = "MODIFICA" THEN
     FOR p_ind1 = 1 TO p_contador
        FOR p_ind3 = 1 TO p_cont
           IF p_prog_situa[p_ind1].num_prog_entrega = p_programas_oc[p_ind3].num_prog_entrega THEN
              LET p_prog_situa[p_ind1].inf_complement    = p_programas_oc[p_ind3].inf_complement
              LET p_prog_situa[p_ind1].num_prog_entrega  = p_programas_oc[p_ind3].num_prog_entrega
              LET p_prog_situa[p_ind1].ies_situa_prog    = p_programas_oc[p_ind3].ies_situa_prog
              LET p_prog_situa[p_ind1].dat_entrega_prev  = p_programas_oc[p_ind3].dat_entrega_prev
              LET p_prog_situa[p_ind1].qtd_solic         = p_programas_oc[p_ind3].qtd_solic
              LET p_prog_situa[p_ind1].qtd_recebida      = p_programas_oc[p_ind3].qtd_recebida
              LET p_prog_situa[p_ind1].num_pedido_fornec = p_programas_oc[p_ind3].num_pedido_fornec
           END IF
        END FOR
     END FOR
     FOR p_ind1 = 1 TO p_cont
        IF p_programas_oc[p_ind1].num_prog_entrega IS NULL THEN
           LET p_contador = p_contador + 1
           LET p_prog_situa[p_contador].inf_complement    = p_programas_oc[p_ind1].inf_complement
           LET p_prog_situa[p_contador].num_prog_entrega  = p_programas_oc[p_ind1].num_prog_entrega
           LET p_prog_situa[p_contador].ies_situa_prog    = p_programas_oc[p_ind1].ies_situa_prog
           LET p_prog_situa[p_contador].dat_entrega_prev  = p_programas_oc[p_ind1].dat_entrega_prev
           LET p_prog_situa[p_contador].qtd_solic         = p_programas_oc[p_ind1].qtd_solic
           LET p_prog_situa[p_contador].qtd_recebida      = p_programas_oc[p_ind1].qtd_recebida
           LET p_prog_situa[p_contador].num_pedido_fornec = p_programas_oc[p_ind1].num_pedido_fornec
        END IF
     END FOR
  END IF

  IF p_operacao = "INCLUSAO" THEN
     FOR l_ind = 1 TO p_cont
        IF (p_programas_oc[l_ind].ies_situa_prog = "P" OR
            p_programas_oc[l_ind].ies_situa_prog = "F") AND
            p_programas_oc[l_ind].qtd_solic > 0 THEN
            LET flag_situa_f = TRUE
        END IF
        IF p_programas_oc[l_ind].ies_situa_prog = "L" AND
           p_programas_oc[l_ind].qtd_solic > 0 THEN
           LET flag_situa_l = TRUE
        END IF
     END FOR

     LET flag_situa_c = TRUE

     FOR l_ind = 1 TO p_cont
        IF p_programas_oc[l_ind].ies_situa_prog <> "C" THEN
           LET flag_situa_c = FALSE
           EXIT FOR
        END IF
     END FOR

     IF flag_situa_c = TRUE THEN
        LET p_conta = NULL
        LET sql_stmt =
            "SELECT COUNT(*) FROM prog_ordem_sup ",
            "WHERE cod_empresa = """,p_ordem_sup.cod_empresa,""" ",
            "AND num_oc = ",p_ordem_sup.num_oc," ",
            "AND num_versao = ",p_ordem_sup.num_versao," ",
            "AND num_prog_entrega NOT IN ("

        FOR l_ind = 1 TO p_cont
           IF p_programas_oc[l_ind].num_prog_entrega > 0 THEN
              IF l_ind <> p_cont THEN
                 LET sql_stmt = sql_stmt CLIPPED,
                     p_programas_oc[l_ind].num_prog_entrega USING "###",","
              ELSE
                 LET sql_stmt = sql_stmt CLIPPED,
                     p_programas_oc[l_ind].num_prog_entrega USING "###"
              END IF
           END IF
        END FOR

        LET sql_stmt = sql_stmt  CLIPPED, ")",
            " AND prog_ordem_sup.ies_situa_prog <> ""C"" "

        PREPARE var_atua1 FROM sql_stmt
        DECLARE cq_atua1 CURSOR FOR var_atua1
        FOREACH cq_atua1 INTO p_conta
           EXIT FOREACH
        END FOREACH

        IF p_conta > 0 THEN
           LET flag_situa_c = FALSE
        END IF
     END IF
  ELSE
     FOR l_ind = 1 TO p_contador
        IF (p_prog_situa[l_ind].ies_situa_prog = "P" OR
            p_prog_situa[l_ind].ies_situa_prog = "F") AND
            p_prog_situa[l_ind].qtd_solic > 0 THEN
           LET flag_situa_f = TRUE
        END IF
        IF p_prog_situa[l_ind].ies_situa_prog = "L" AND
           p_prog_situa[l_ind].qtd_solic > 0 THEN
           LET flag_situa_l = TRUE
        END IF
     END FOR

     LET flag_situa_c = TRUE

     FOR l_ind = 1 TO p_cont
        IF p_programas_oc[l_ind].ies_situa_prog <> "C" THEN
           LET flag_situa_c = FALSE
           EXIT FOR
        END IF
     END FOR

     IF flag_situa_c = TRUE THEN
        LET p_conta = NULL
        LET sql_stmt =
            "SELECT COUNT(*) FROM prog_ordem_sup ",
            "WHERE prog_ordem_sup.cod_empresa = """,p_ordem_sup.cod_empresa,""" ",
            "AND prog_ordem_sup.num_oc = ",p_ordem_sup.num_oc," ",
            "AND prog_ordem_sup.num_versao = ",p_ordem_sup.num_versao," ",
            "AND prog_ordem_sup.num_prog_entrega NOT IN ("

        FOR l_ind = 1 TO p_cont
           IF p_programas_oc[l_ind].num_prog_entrega > 0 THEN
              IF l_ind <> p_cont THEN
                 LET sql_stmt = sql_stmt CLIPPED,
                     p_programas_oc[l_ind].num_prog_entrega USING "###",","
              ELSE
                 LET sql_stmt = sql_stmt CLIPPED,
                     p_programas_oc[l_ind].num_prog_entrega USING "###"
              END IF
           END IF
        END FOR

        LET sql_stmt = sql_stmt  CLIPPED, ")",
            " AND prog_ordem_sup.ies_situa_prog <> ""C"" "

        PREPARE var_atua2 FROM sql_stmt
        DECLARE cq_atua2 CURSOR FOR var_atua2
        FOREACH cq_atua2 INTO p_conta
           EXIT FOREACH
        END FOREACH

        IF p_conta > 0 THEN
           LET flag_situa_c = FALSE
        END IF
     END IF
  END IF

  IF flag_situa_c = TRUE AND flag_situa_f = FALSE AND flag_situa_l = FALSE THEN
     LET p_flag_atua_c = TRUE
  ELSE
     LET p_flag_atua_c = FALSE
  END IF

  IF flag_situa_l = TRUE AND flag_situa_f = FALSE THEN
     LET p_flag_atua_l = TRUE
  ELSE
     LET p_flag_atua_l = FALSE
  END IF

  IF flag_situa_c = TRUE AND flag_situa_l = TRUE AND flag_situa_f = FALSE THEN
     LET p_flag_atua_c = TRUE
     LET p_flag_atua_l = FALSE
  END IF

  IF flag_situa_f = TRUE THEN
     LET p_flag_atua_c = FALSE
     LET p_flag_atua_l = FALSE
     LET p_flag_atua_f = TRUE
  END IF

  RETURN TRUE
 END FUNCTION

#--------------------------------#
 FUNCTION sup036_atua_ordem_sup()
#--------------------------------#
  DEFINE p_cont_prog   SMALLINT,
         p_cont_liq    SMALLINT,
         p_cont_canc   SMALLINT,
         p_cont_plan   SMALLINT,
         l_lead_time   DECIMAL(6,0),
         l_msg         CHAR(100),
         l_ult_prog    LIKE prog_ordem_sup.num_prog_entrega,
         l_situa_ant   LIKE ordem_sup.ies_situa_oc

  LET l_situa_ant = p_ordem_sup.ies_situa_oc

  IF m_ies_ajuste_data_oc = "S" AND p_ordem_sup.ies_situa_oc = "P" THEN
     LET l_lead_time = NULL
     SELECT (tmp_necessar_p_ped + tmp_necessar_fabr + tmp_transpor +
             tmp_inspecao + tmp_necessar_cont)
       INTO l_lead_time
       FROM item_sup
      WHERE cod_empresa = p_ordem_sup.cod_empresa
        AND cod_item    = p_ordem_sup.cod_item
     IF l_lead_time IS NULL THEN
        LET l_lead_time = 0
     END IF
     LET p_cont_prog = 0
     SELECT COUNT(*)
       INTO p_cont_prog
       FROM prog_ordem_sup
      WHERE cod_empresa      = p_ordem_sup.cod_empresa
        AND num_oc           = p_ordem_sup.num_oc
        AND ies_situa_prog   IN ("F","P")
        AND dat_entrega_prev < TODAY
        AND num_versao       = p_ordem_sup.num_versao
     IF p_cont_prog > 0 THEN
        CALL log0030_mensagem( "Existe(m) entrega(s) inferiores a data atual","exclamation")
        RETURN FALSE
     END IF
     LET p_ordem_sup.dat_emis        = TODAY
     LET p_ordem_sup.dat_abertura_oc = p_ordem_sup.dat_entrega_prev - l_lead_time UNITS DAY
     LET p_ordem_sup.dat_origem      = p_ordem_sup.dat_entrega_prev
  END IF

  LET p_cont_plan = 0
  SELECT COUNT(*) INTO p_cont_plan
    FROM prog_ordem_sup
   WHERE cod_empresa    = p_ordem_sup.cod_empresa
     AND num_oc         = p_ordem_sup.num_oc
     AND ies_situa_prog = "P"
     AND num_versao     = p_ordem_sup.num_versao
  IF p_cont_plan > 0 THEN
     LET p_ordem_sup.ies_situa_oc = "P"
  ELSE
     LET p_cont_prog = 0
     SELECT COUNT(*) INTO p_cont_prog
       FROM prog_ordem_sup
      WHERE cod_empresa    = p_ordem_sup.cod_empresa
        AND num_oc         = p_ordem_sup.num_oc
        AND ies_situa_prog = "F"
        AND num_versao     = p_ordem_sup.num_versao
     IF p_cont_prog > 0 THEN
        IF  p_ordem_sup.ies_situa_oc <> "D"
        AND p_ordem_sup.ies_situa_oc <> "T" THEN
           IF (p_ordem_sup.ies_situa_oc = "R" AND sup0360_verifica_nova_versao_oc(p_ordem_sup.num_oc)) THEN
           ELSE
              LET p_ordem_sup.ies_situa_oc = "A"
           END IF
        END IF
     ELSE
        LET p_cont_liq = 0
        SELECT COUNT(*) INTO p_cont_liq
          FROM prog_ordem_sup
         WHERE cod_empresa    = p_ordem_sup.cod_empresa
           AND num_oc         = p_ordem_sup.num_oc
           AND ies_situa_prog = "L"
           AND num_versao     = p_ordem_sup.num_versao
        IF p_cont_liq > 0 THEN
           LET p_ordem_sup.ies_situa_oc = "L"
        ELSE
           LET p_cont_prog = 0
           SELECT COUNT(*) INTO p_cont_prog
             FROM prog_ordem_sup
            WHERE cod_empresa    = p_ordem_sup.cod_empresa
              AND num_oc         = p_ordem_sup.num_oc
              AND num_versao     = p_ordem_sup.num_versao

           LET p_cont_canc = 0
           SELECT COUNT(*) INTO p_cont_canc
             FROM prog_ordem_sup
            WHERE cod_empresa    = p_ordem_sup.cod_empresa
              AND num_oc         = p_ordem_sup.num_oc
              AND ies_situa_prog = "C"
              AND num_versao     = p_ordem_sup.num_versao
           IF p_cont_canc = p_cont_prog THEN
              LET p_ordem_sup.ies_situa_oc = "C"
           END IF
        END IF
     END IF
  END IF

  DECLARE cm_prg_ord_s CURSOR FOR
   SELECT dat_entrega_prev
     FROM prog_ordem_sup
    WHERE cod_empresa    = p_ordem_sup.cod_empresa
      AND num_oc         = p_ordem_sup.num_oc
      AND num_versao     = p_ordem_sup.num_versao
      AND ies_situa_prog IN ("P","F","L")
     ORDER BY dat_entrega_prev
  FOREACH cm_prg_ord_s INTO p_ordem_sup.dat_entrega_prev
     EXIT FOREACH
  END FOREACH

  IF p_ordem_sup.ies_situa_oc = "L" OR p_ordem_sup.ies_situa_oc = "C" THEN
     IF p_ordem_sup.num_pedido > 0 THEN
        IF sup0360_ordem_importacao("R") THEN
           RETURN FALSE
        END IF
     END IF

     #O.S. 559541
     IF p_ordem_sup.ies_situa_oc = "L" THEN
        LET l_msg = "Deseja liquidar Ordem de Compra?"
     END IF

     IF p_ordem_sup.ies_situa_oc = "C" THEN
        LET l_msg = "Deseja cancelar Ordem de Compra?"
     END IF
     #O.S. 559541

     IF log0040_confirm(13,39,l_msg) THEN
        WHENEVER ERROR CONTINUE
        UPDATE ordem_sup
           SET ies_situa_oc = p_ordem_sup.ies_situa_oc
         WHERE cod_empresa  = p_ordem_sup.cod_empresa
           AND num_oc       = p_ordem_sup.num_oc
           AND num_versao   = p_ordem_sup.num_versao
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("UPDATE","ordem_sup")
           RETURN FALSE
        END IF
     ELSE
        LET p_ordem_sup.ies_situa_oc = l_situa_ant
     END IF
  ELSE
     WHENEVER ERROR CONTINUE
     UPDATE ordem_sup
        SET ies_situa_oc     = p_ordem_sup.ies_situa_oc,
            dat_entrega_prev = p_ordem_sup.dat_entrega_prev,
            dat_emis         = p_ordem_sup.dat_emis,
            dat_abertura_oc  = p_ordem_sup.dat_abertura_oc,
            dat_origem       = p_ordem_sup.dat_origem
      WHERE cod_empresa = p_ordem_sup.cod_empresa
        AND num_oc      = p_ordem_sup.num_oc
        AND num_versao  = p_ordem_sup.num_versao
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("MODIFICACAO","ORDEM_SUP")
        RETURN FALSE
     END IF
  END IF

  IF p_ordem_sup.num_pedido > 0 THEN
     IF NOT sup036_atualiza_pedido() THEN
        RETURN FALSE
     END IF
  ELSE
     IF p_ordem_sup.ies_situa_oc = "C" THEN
        IF NOT sup1310_exclui_reserva_oc(p_ordem_sup.cod_empresa,p_ordem_sup.num_oc) THEN
           RETURN FALSE
        END IF
     END IF
  END IF
  RETURN TRUE
 END FUNCTION

#---------------------------------#
 FUNCTION sup036_atualiza_pedido()
#---------------------------------#
  DEFINE p_ies_situa_ped CHAR(01),
         l_msg           CHAR(150)

  IF sup036_verifica_lib_ordem(p_ordem_sup.num_pedido) THEN
     IF NOT sup0360_existe_adiant() THEN
        IF NOT sup036_existe_ordem_liq(p_ordem_sup.num_pedido) THEN

           IF log0040_confirm(13,39,"Deseja Cancelar Pedido de Compra?") THEN
              WHENEVER ERROR CONTINUE
              UPDATE pedido_sup
                 SET ies_situa_ped    = "C"
               WHERE cod_empresa      = p_cod_empresa
                 AND num_pedido       = p_ordem_sup.num_pedido
                 AND ies_versao_atual = "S"
              WHENEVER ERROR STOP
           END IF
        ELSE
           IF log0040_confirm(13,39,"Deseja Liquidar Pedido de Compra?") THEN
              WHENEVER ERROR CONTINUE
              UPDATE pedido_sup
                 SET ies_situa_ped    = "L",
                     dat_liquidac     = TODAY
               WHERE cod_empresa      = p_cod_empresa
                 AND num_pedido       = p_ordem_sup.num_pedido
                 AND ies_versao_atual = "S"
              WHENEVER ERROR STOP
           END IF
        END IF
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("MODIFICACAO","PEDIDO_SUP")
           RETURN FALSE
        END IF
     ELSE
        LET l_msg = "Pedido de compra ", p_ordem_sup.num_pedido USING "<<<<<<", " possui adiantamento e não poderá ser liquidado/cancelado."
        CALL log0030_mensagem(l_msg,"info")
     END IF
  END IF
  RETURN TRUE
 END FUNCTION

#------------------------------------------------#
 FUNCTION sup036_verifica_lib_ordem(p_num_pedido)
#------------------------------------------------#
  DEFINE p_num_pedido   LIKE pedido_sup.num_pedido

  WHENEVER ERROR CONTINUE
  SELECT num_oc FROM ordem_sup
   WHERE cod_empresa      = p_cod_empresa
     AND ies_versao_atual = "S"
     AND num_pedido       = p_num_pedido
     AND ies_situa_oc     NOT IN ("L","C")
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
     RETURN TRUE
  END IF
  RETURN FALSE
 END FUNCTION

#----------------------------------------------#
 FUNCTION sup036_existe_ordem_liq(p_num_pedido)
#----------------------------------------------#
  DEFINE p_num_pedido  LIKE pedido_sup.num_pedido

  WHENEVER ERROR CONTINUE
  SELECT num_oc FROM ordem_sup
   WHERE cod_empresa      = p_cod_empresa
     AND ies_versao_atual = "S"
     AND num_pedido       = p_num_pedido
     AND ies_situa_oc     = "L"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 OR sqlca.sqlcode = -284 THEN
     RETURN TRUE
  END IF
  RETURN FALSE
 END FUNCTION

#------------------------------------------#
 FUNCTION sup036_move_prog_ordem_sup(l_ind)
#------------------------------------------#
  DEFINE l_ind SMALLINT

  LET p_prog_ordem_sup.cod_empresa      = p_ordem_sup.cod_empresa
  LET p_prog_ordem_sup.num_oc           = p_ordem_sup.num_oc
  LET p_prog_ordem_sup.num_versao       = p_ordem_sup.num_versao

  LET p_prog_ordem_sup.dat_entrega_prev = p_programas_oc[l_ind].dat_entrega_prev
  LET p_prog_ordem_sup.qtd_solic        = p_programas_oc[l_ind].qtd_solic * m_fat_conver
  IF p_programas_oc[l_ind].qtd_recebida IS NULL  THEN
     LET p_prog_ordem_sup.qtd_recebida  = 0
  ELSE
     LET p_prog_ordem_sup.qtd_recebida  = p_programas_oc[l_ind].qtd_recebida * m_fat_conver
  END IF
  IF p_programas_oc[l_ind].ies_situa_prog IS NULL  THEN
     LET p_prog_ordem_sup.ies_situa_prog   = "F"
  ELSE
     LET p_prog_ordem_sup.ies_situa_prog   = p_programas_oc[l_ind].ies_situa_prog
  END IF
  LET p_prog_ordem_sup.num_pedido_fornec   = p_programas_oc[l_ind].num_pedido_fornec
  # estoque em transito
  LET p_prog_ordem_sup.qtd_em_transito     = p_inf_complement[l_ind].qtd_em_transito * m_fat_conver
  LET p_prog_ordem_sup.dat_palpite         = p_inf_complement[l_ind].dat_palpite
  LET p_prog_ordem_sup.tex_observacao      = p_inf_complement[l_ind].tex_observacao
  LET p_prog_ordem_sup.dat_origem          = p_inf_complement[l_ind].dat_origem
  IF p_prog_ordem_sup.dat_origem IS NULL THEN
     LET p_prog_ordem_sup.dat_origem = p_programas_oc[l_ind].dat_entrega_prev
  END IF
 END FUNCTION

#----------------------------------------#
 FUNCTION sup036_verifica_grade_aprov_pc()
#----------------------------------------#
  LET p_grade_pc = 0
  SELECT COUNT(*)
    INTO p_grade_pc
    FROM grade_aprov_pc
   WHERE cod_empresa = p_cod_empresa
     AND ies_versao_atual = "S"
     AND ies_situa_grade  = "L"
  IF p_grade_pc = " " OR p_grade_pc IS NULL THEN
     LET p_grade_pc = 0
  END IF
 END FUNCTION

#--------------------------------------#
 FUNCTION sup036_ordem_controla_valor()
#--------------------------------------#
 DEFINE p_contador SMALLINT

 LET p_contador = NULL

 WHENEVER ERROR CONTINUE
 SELECT COUNT(*) INTO p_contador
   FROM prog_ordem_sup_com
  WHERE cod_empresa = p_ordem_sup.cod_empresa
    AND num_oc      = p_ordem_sup.num_oc
    AND num_versao  = p_ordem_sup.num_versao
 WHENEVER ERROR STOP

 IF p_contador > 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF
 END FUNCTION

#--------------------------------------#
 FUNCTION sup036_atualiza_val_tot_ped()
#--------------------------------------#
 DEFINE p_ord_sup_tot RECORD LIKE ordem_sup.*,
        p_val_tot_ped LIKE pedido_sup.val_tot_ped ,
        p_num_versao_ped LIKE pedido_sup.num_versao

 LET p_val_tot_ped = 0

 DECLARE cq_tot_ped CURSOR FOR
  SELECT *
    FROM ordem_sup
   WHERE cod_empresa      = p_cod_empresa
     AND num_pedido       = p_ordem_sup.num_pedido
     AND ies_versao_atual = "S"

 FOREACH cq_tot_ped INTO p_ord_sup_tot.*
    IF p_ord_sup_tot.ies_situa_oc = "C" THEN
       CONTINUE FOREACH
    END IF
    IF p_ord_sup_tot.qtd_solic = 0 THEN
       LET p_ord_sup_tot.qtd_solic = 1
    END IF
    LET p_val_tot_ped = p_val_tot_ped +
        (p_ord_sup_tot.qtd_solic * p_ord_sup_tot.pre_unit_oc *
        (p_ord_sup_tot.pct_ipi / 100 + 1))
 END FOREACH

 IF p_val_tot_ped IS NULL  THEN
    LET p_val_tot_ped = 0
 END IF

 WHENEVER ERROR CONTINUE
 UPDATE pedido_sup SET val_tot_ped = p_val_tot_ped
  WHERE cod_empresa      = p_ordem_sup.cod_empresa
    AND num_pedido       = p_ordem_sup.num_pedido
    AND ies_versao_atual = "S"
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("MODIFICACAO","PEDIDO_SUP")
    RETURN FALSE
 END IF

 LET p_num_versao_ped  = NULL
 SELECT num_versao INTO p_num_versao_ped
   FROM pedido_sup
  WHERE cod_empresa = p_ordem_sup.cod_empresa
    AND num_pedido  = p_ordem_sup.num_pedido
    AND ies_versao_atual = "S"

 IF NOT sup868_grava_aprov_ped_sup(p_ordem_sup.num_pedido,
                                 p_num_versao_ped,
                                 p_val_tot_ped,
                                 p_ordem_sup.cod_empresa) THEN
    RETURN FALSE
 END IF

 RETURN TRUE
END FUNCTION

#--------------------------------#
 FUNCTION sup036_verifica_audit()
#--------------------------------#
  LET p_audit.nom_usuario = NULL
  LET p_audit.dat_proces  = NULL
  LET p_audit.hor_operac  = NULL

  SELECT nom_usuario,
         dat_proces,
         hor_operac
    INTO p_audit.nom_usuario,
         p_audit.dat_proces,
         p_audit.hor_operac
    FROM audit_sup
   WHERE cod_empresa      = p_ordem_sup.cod_empresa
     AND num_pedido_ordem = p_ordem_sup.num_oc
     AND ies_tipo         = "3"
     AND num_versao       = p_ordem_sup.num_versao

  DISPLAY BY NAME p_audit.nom_usuario
  DISPLAY BY NAME p_audit.dat_proces
  DISPLAY BY NAME p_audit.hor_operac
END FUNCTION

#----------------------------------#
 FUNCTION sup036_monta_audit_sup()
#----------------------------------#
  DEFINE p_audit_sup      RECORD LIKE audit_sup.*

  INITIALIZE p_audit_sup.* TO NULL

  DELETE FROM audit_sup
   WHERE cod_empresa      = p_cod_empresa
     AND num_pedido_ordem = p_ordem_sup.num_oc
     AND num_versao       = p_ordem_sup.num_versao
     AND ies_tipo         = "3"

  LET p_audit_sup.num_pedido_ordem = p_ordem_sup.num_oc
  LET p_audit_sup.ies_tipo         = "3"
  LET p_audit_sup.num_versao       = p_ordem_sup.num_versao
  LET p_audit_sup.cod_empresa      = p_cod_empresa
  LET p_audit_sup.nom_usuario      = p_user
  LET p_audit_sup.dat_proces       = TODAY
  LET p_audit_sup.hor_operac       = TIME
  LET p_audit_sup.num_prog         = "SUP0360"

  CALL sup225_grava_audit(p_audit_sup.*)

  LET p_audit.nom_usuario = p_user
  LET p_audit.dat_proces  = p_audit_sup.dat_proces
  LET p_audit.hor_operac  = p_audit_sup.hor_operac

  DISPLAY BY NAME p_audit.nom_usuario
  DISPLAY BY NAME p_audit.dat_proces
  DISPLAY BY NAME p_audit.hor_operac
 END FUNCTION

#-----------------------------#
 FUNCTION sup036_verif_solic()
#-----------------------------#
  WHENEVER ERROR CONTINUE
  SELECT num_oc
    FROM ordem_sup_audit
   WHERE cod_empresa    = p_ordem_sup.cod_empresa
     AND num_oc         = p_ordem_sup.num_oc
     AND nom_usuario    = p_user
     AND ies_tipo_audit = "1"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF
 END FUNCTION

#-----------------------------#
 FUNCTION sup036_verif_aprov()
#-----------------------------#
  SELECT num_oc
    FROM ordem_sup_audit
   WHERE cod_empresa    = p_ordem_sup.cod_empresa
     AND num_oc         = p_ordem_sup.num_oc
     AND nom_usuario    = p_user
     AND ies_tipo_audit = "2"
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF
 END FUNCTION

#--------------------------------------------#
 FUNCTION sup036_grava_dest_ordem(p_ind_prog)
#--------------------------------------------#
  DEFINE p_ind_prog,p_ind_aux SMALLINT

  DELETE FROM w_dest
   WHERE cod_empresa = p_ordem_sup.cod_empresa
     AND num_oc      = p_ordem_sup.num_oc
     AND num_versao  = p_ordem_sup.num_versao
     AND num_prog_entrega = p_ind_prog

  FOR p_ind_aux = 1 TO 99
     IF p_dest_prog_ord[p_ind_aux].cod_local IS NOT NULL AND
        p_dest_prog_ord[p_ind_aux].qtd_particip > 0 THEN
        LET p_dest_prog_ord_sup.num_prog_entrega  = p_ind_prog
        LET p_dest_prog_ord_sup.cod_local         = p_dest_prog_ord[p_ind_aux].cod_local
        LET p_dest_prog_ord_sup.pct_particip_comp = (p_dest_prog_ord[p_ind_aux].qtd_particip/p_tot_prog)*100
        LET p_dest_prog_ord_sup.qtd_particip_comp = p_dest_prog_ord[p_ind_aux].qtd_particip
        LET p_dest_prog_ord_sup.num_docum         = p_dest_prog_ord[p_ind_aux].num_docum
        WHENEVER ERROR CONTINUE
        INSERT INTO w_dest
        VALUES (p_ordem_sup.cod_empresa,
                p_ordem_sup.num_oc,
                p_ordem_sup.num_versao,
                p_dest_prog_ord_sup.num_prog_entrega,
                p_dest_prog_ord_sup.cod_local,
                p_dest_prog_ord_sup.pct_particip_comp,
                p_dest_prog_ord_sup.qtd_particip_comp,
                p_dest_prog_ord_sup.num_docum)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("W_DEST","GRAVA_1")
           RETURN FALSE
        END IF
     END IF
  END FOR
  RETURN  TRUE
 END FUNCTION

#------------------------------#
 FUNCTION sup036_verifica_obj()
#------------------------------#
  DEFINE p_cont_dest   SMALLINT,
         p_flag_atual  SMALLINT,
         p_flag_ant    SMALLINT,
         l_ind         SMALLINT

  INITIALIZE p_flag_atual, p_flag_ant TO NULL

  FOR l_ind = 1 TO p_cont
    LET p_flag_ant = p_flag_atual

    IF p_programas_oc[l_ind].ies_situa_prog = "C" OR
       p_programas_oc[l_ind].dat_entrega_prev IS NULL THEN
       CONTINUE FOR
    END IF

    LET p_cont_dest = 0
    SELECT COUNT(*) INTO p_cont_dest
      FROM w_dest
     WHERE cod_empresa      = p_ordem_sup.cod_empresa
       AND num_oc           = p_ordem_sup.num_oc
       AND num_versao       = p_ordem_sup.num_versao
       AND num_prog_entrega = l_ind
    IF p_cont_dest > 0 THEN
       LET p_flag_atual = TRUE
    ELSE
       LET p_flag_atual = FALSE
    END IF

    IF l_ind > 1 THEN
       IF p_flag_atual != p_flag_ant THEN
          RETURN FALSE
       END IF
    END IF
  END FOR
  RETURN TRUE
 END FUNCTION

#-----------------------------#
 FUNCTION sup036_cria_w_dest()
#-----------------------------#
# esta tabela sera utiizada para nao utilizar um array bi-dimensional
# pois poderao ser alterados o conteudo deste array
# a numeracao da programacao sera a ocorrencia do array
# pois so sera considerado na hora de gravacao
# onde podera ser incluidas novas programacoes e so obtera o numero na
# gravacao da prog_ordem_sup
  WHENEVER ERROR CONTINUE
  DROP TABLE w_dest
  CREATE TEMP TABLE w_dest
  (cod_empresa       CHAR(02),
   num_oc            DECIMAL(9,0),
   num_versao        DECIMAL(3,0),
   num_prog_entrega  DECIMAL(3,0),
   cod_local         CHAR(10),
   pct_particip_comp DECIMAL(8,5),
   qtd_particip_comp DECIMAL(12,3),
   num_docum         CHAR(10)
  ) WITH NO LOG  ;
  WHENEVER ERROR STOP

  IF sqlca.sqlcode != 0 THEN
     CALL log003_err_sql("CREATE","W_DEST")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  CREATE UNIQUE INDEX ix_w_dest ON w_dest
  (cod_empresa,num_oc,num_versao,num_prog_entrega,cod_local);
  WHENEVER ERROR STOP

  IF sqlca.sqlcode != 0 THEN
     CALL log003_err_sql("CREATE_IX ","W_DEST")
     RETURN FALSE
  END IF
  RETURN TRUE
 END FUNCTION

#--------------------------------#
 FUNCTION sup036_carrega_w_dest()
#--------------------------------#
  DECLARE cq_dest CURSOR FOR
   SELECT *
     FROM dest_prog_ord_sup
    WHERE cod_empresa      = p_prog_ordem_sup.cod_empresa
      AND num_oc           = p_prog_ordem_sup.num_oc
      AND num_versao       = p_prog_ordem_sup.num_versao
      AND num_prog_entrega = p_prog_ordem_sup.num_prog_entrega

  OPEN cq_dest
  FETCH cq_dest INTO p_dest_prog_ord_sup.*
  WHILE sqlca.sqlcode = 0
    LET p_dest_prog_ord_sup.qtd_particip_comp = p_dest_prog_ord_sup.qtd_particip_comp / m_fat_conver
    LET p_dest_prog_ord_sup.num_prog_entrega = p_cont_dest
# utilizara a ocorrencia do array p/ considerar o numero da programacao
    WHENEVER ERROR CONTINUE
    INSERT INTO w_dest VALUES (p_dest_prog_ord_sup.*)
    WHENEVER ERROR STOP
    IF sqlca.sqlcode != 0 AND sqlca.sqlcode != -239 AND sqlca.sqlcode != -268 THEN
       CALL log003_err_sql("CONSULTA","W_DEST")
       RETURN FALSE
    END IF
    FETCH cq_dest INTO p_dest_prog_ord_sup.*
  END WHILE

  RETURN TRUE
END FUNCTION

#--------------------------------------------#
 FUNCTION sup036_insere_dest_prog(p_ind_prog)
#--------------------------------------------#
  DEFINE p_ind_prog SMALLINT

  WHENEVER ERROR CONTINUE
  DELETE FROM dest_prog_ord_sup
   WHERE cod_empresa      = p_prog_ordem_sup.cod_empresa
     AND num_oc           = p_prog_ordem_sup.num_oc
     AND num_versao       = p_prog_ordem_sup.num_versao
     AND num_prog_entrega = p_prog_ordem_sup.num_prog_entrega
  WHENEVER ERROR STOP

  LET p_dest_prog_ord_sup.cod_empresa = p_prog_ordem_sup.cod_empresa
  LET p_dest_prog_ord_sup.num_oc      = p_prog_ordem_sup.num_oc
  LET p_dest_prog_ord_sup.num_versao  = p_prog_ordem_sup.num_versao

  DECLARE cq_dest1 CURSOR WITH HOLD FOR
   SELECT *
     FROM w_dest
    WHERE cod_empresa = p_prog_ordem_sup.cod_empresa
      AND num_oc      = p_prog_ordem_sup.num_oc
      AND num_versao  = p_prog_ordem_sup.num_versao
      AND num_prog_entrega = p_ind_prog

  OPEN cq_dest1
  FETCH cq_dest1 INTO p_dest_prog_ord_sup.*

  WHILE sqlca.sqlcode = 0
    LET p_dest_prog_ord_sup.qtd_particip_comp = p_dest_prog_ord_sup.qtd_particip_comp * m_fat_conver
    LET p_dest_prog_ord_sup.num_prog_entrega = p_prog_ordem_sup.num_prog_entrega

    WHENEVER ERROR CONTINUE
    INSERT INTO dest_prog_ord_sup VALUES (p_dest_prog_ord_sup.*)
    WHENEVER ERROR STOP
    IF sqlca.sqlcode != 0 THEN
       CALL log003_err_sql("INCLUSAO","DEST_PROG_ORD_SUP")
       CLOSE cq_dest1
       RETURN FALSE
    END IF

    FETCH cq_dest1 INTO p_dest_prog_ord_sup.*
  END WHILE

  CLOSE cq_dest1

  RETURN TRUE
 END FUNCTION

#----------------------------------------------#
 FUNCTION sup036_atualiza_dest_ordem_sup(l_qtd)
#----------------------------------------------#
 DEFINE l_qtd        LIKE ordem_sup.qtd_solic ,
        lr_dest_oc   RECORD LIKE dest_ordem_sup.*,
        l_houve_erro SMALLINT

 LET l_houve_erro = FALSE

 LET l_qtd = l_qtd * m_fat_conver

 DECLARE cq_dest_oc CURSOR FOR
  SELECT dest_ordem_sup.*
    FROM dest_ordem_sup
   WHERE dest_ordem_sup.cod_empresa = p_cod_empresa
     AND dest_ordem_sup.num_oc      = p_ordem_sup.num_oc
 FOREACH cq_dest_oc INTO lr_dest_oc.*
    WHENEVER ERROR CONTINUE
    UPDATE dest_ordem_sup
       SET qtd_particip_comp = ((pct_particip_comp * l_qtd) / 100)
     WHERE cod_empresa        = p_cod_empresa
       AND num_oc             = lr_dest_oc.num_oc
       AND cod_area_negocio   = lr_dest_oc.cod_area_negocio
       AND cod_lin_negocio    = lr_dest_oc.cod_lin_negocio
       AND num_conta_deb_desp = lr_dest_oc.num_conta_deb_desp
       AND cod_secao_receb    = lr_dest_oc.cod_secao_receb
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("MODIFICACAO","DEST_ORDEM_SUP")
       LET l_houve_erro = TRUE
       EXIT FOREACH
    END IF
 END FOREACH

 RETURN (l_houve_erro = FALSE)
 END FUNCTION

#---------------------------------------------------------#
 FUNCTION sup0360_item_controle_estoque_fisico(l_cod_item)
#---------------------------------------------------------#
  DEFINE l_cod_item   CHAR(15),
         l_ies_ctr    CHAR(01)

  LET l_ies_ctr = NULL
  SELECT parametros[17] INTO l_ies_ctr
    FROM item_parametro
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = l_cod_item
  IF sqlca.sqlcode = 0 THEN
     IF l_ies_ctr IS NULL OR l_ies_ctr = " " OR l_ies_ctr = "N" THEN
        RETURN FALSE
     END IF
     RETURN TRUE
  END IF
  RETURN FALSE
 END FUNCTION

#-------------------------------------#
 FUNCTION sup0360_leitura_parametros()
#-------------------------------------#
  INITIALIZE p_par_con.* TO NULL
  SELECT * INTO p_par_con.*
    FROM par_con
   WHERE cod_empresa = p_cod_empresa

####OS 57360
  INITIALIZE p_ies_situa_oc_D_ou_T TO NULL
  SELECT par_ies INTO p_ies_situa_oc_D_ou_T
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_situa_oc_D_ou_T"
  IF sqlca.sqlcode <> 0
  OR p_ies_situa_oc_D_ou_T IS NULL OR p_ies_situa_oc_D_ou_T = " " THEN
     LET p_ies_situa_oc_D_ou_T = "N"
  END IF
##################

  INITIALIZE p_ies_dat_retro TO NULL
  SELECT par_ies INTO p_ies_dat_retro
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_dat_retro_prog"
  IF sqlca.sqlcode <> 0
  OR p_ies_dat_retro IS NULL OR p_ies_dat_retro = " " THEN
     LET p_ies_dat_retro = "N"
  END IF

  INITIALIZE m_oc_pc_realizado TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"permite_criar_oc_pc_realizado")
        RETURNING m_oc_pc_realizado, p_status

  IF m_oc_pc_realizado IS NULL THEN
     LET m_oc_pc_realizado = 'N'
  END IF

  INITIALIZE p_ies_distr_obj TO NULL
  SELECT par_ies INTO p_ies_distr_obj
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_distr_objetivo"
  IF sqlca.sqlcode <> 0
  OR p_ies_distr_obj = " " OR p_ies_distr_obj IS NULL THEN
     LET p_ies_distr_obj = "N"
  END IF
  IF p_ies_distr_obj = "S" THEN
     IF NOT sup036_cria_w_dest() THEN
        LET p_ies_distr_obj = "N"
     END IF
  END IF

  INITIALIZE m_ies_ajuste_data_oc TO NULL
  SELECT par_ies INTO m_ies_ajuste_data_oc
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_ajuste_data_oc"
  IF sqlca.sqlcode <> 0
  OR m_ies_ajuste_data_oc IS NULL OR m_ies_ajuste_data_oc = " " THEN
     LET m_ies_ajuste_data_oc = "N"
  END IF

  INITIALIZE m_ies_excl_oc_aberta TO NULL
  SELECT par_ies INTO m_ies_excl_oc_aberta
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_excl_oc_aberta"
  IF sqlca.sqlcode <> 0
  OR m_ies_excl_oc_aberta IS NULL OR m_ies_excl_oc_aberta = " " THEN
     LET m_ies_excl_oc_aberta = "N"
  END IF

  INITIALIZE m_ies_excl_oc_deb_dir TO NULL
  SELECT par_ies INTO m_ies_excl_oc_deb_dir
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_excl_oc_deb_dir"
  IF sqlca.sqlcode <> 0
  OR m_ies_excl_oc_deb_dir IS NULL OR m_ies_excl_oc_deb_dir = " " THEN
     LET m_ies_excl_oc_deb_dir = "N"
  END IF

  INITIALIZE mr_usuario.* TO NULL
  SELECT cod_comprador INTO mr_usuario.cod_comprador
    FROM comprador
   WHERE cod_empresa = p_cod_empresa
     AND login       = p_user

  SELECT cod_progr INTO mr_usuario.cod_progr
    FROM programador
   WHERE cod_empresa = p_cod_empresa
     AND login       = p_user

  WHENEVER ERROR CONTINUE
  INITIALIZE m_ies_utiliz_provisao TO NULL
  SELECT par_ies
    INTO m_ies_utiliz_provisao
    FROM par_imp
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_utiliz_provisao"
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 OR m_ies_utiliz_provisao IS NULL OR
     m_ies_utiliz_provisao = " " THEN
     LET m_ies_utiliz_provisao = "N"
  END IF

  WHENEVER ERROR CONTINUE
  INITIALIZE m_utiliz_nfm_import TO NULL
  SELECT par_ies
    INTO m_utiliz_nfm_import
    FROM par_imp
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "utiliz_nfm_import"
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 OR m_utiliz_nfm_import IS NULL OR
     m_utiliz_nfm_import = " " THEN
     LET m_utiliz_nfm_import = "N"
  END IF

  LET m_ies_prog_alt_sup0360 = NULL
  SELECT par_sup_pad.par_ies
    INTO m_ies_prog_alt_sup0360
    FROM par_sup_pad
   WHERE par_sup_pad.cod_empresa   = p_cod_empresa
     AND par_sup_pad.cod_parametro = "ies_prog_alt_sup0360"
  IF sqlca.sqlcode <> 0             OR
     m_ies_prog_alt_sup0360 IS NULL OR
     m_ies_prog_alt_sup0360 = " " THEN
     LET m_ies_prog_alt_sup0360 = "N"
  END IF

  INITIALIZE m_controla_gao TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_ind_especial
    INTO m_controla_gao
    FROM gao_par_padrao
   WHERE empresa = p_cod_empresa
     AND parametro = "controla_gao"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR
     m_controla_gao IS NULL OR
     m_controla_gao = " " THEN
     LET m_controla_gao = "N"
  END IF

  INITIALIZE m_orcamento_periodo TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_ind_especial
    INTO m_orcamento_periodo
    FROM gao_par_padrao
   WHERE empresa = p_cod_empresa
     AND parametro = "orcamento_periodo"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR
     m_orcamento_periodo IS NULL OR
     m_orcamento_periodo = " " THEN
     LET m_orcamento_periodo = "N"
  END IF

  INITIALIZE m_usa_cond_pagto TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_ind_especial
    INTO m_usa_cond_pagto
    FROM gao_par_padrao
   WHERE empresa = p_cod_empresa
     AND parametro = "usa_cond_pagto"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR
     m_usa_cond_pagto IS NULL OR
     m_usa_cond_pagto = " " THEN
     LET m_usa_cond_pagto = "N"
  END IF

  CALL log2250_busca_parametro(p_cod_empresa, "estorna_na_liquidacao_pedido")
       RETURNING m_estorna_liquid, p_status

  IF p_status = FALSE OR
     m_estorna_liquid IS NULL OR
     m_estorna_liquid = " " THEN
     LET m_estorna_liquid = "N"
  END IF

  INITIALIZE m_permitir_cancelar_oc_pc_edi TO NULL
  CALL log2250_busca_parametro(p_cod_empresa, "permitir_cancelar_oc_pc_edi") #OS463024
     RETURNING m_permitir_cancelar_oc_pc_edi, p_status

  IF p_status = FALSE
  OR m_permitir_cancelar_oc_pc_edi IS NULL
  OR m_permitir_cancelar_oc_pc_edi = " " THEN
     LET m_permitir_cancelar_oc_pc_edi = "N"
  END IF

  INITIALIZE m_desig_cons6510 TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_sup_pad.par_ies
    INTO m_desig_cons6510
    FROM par_sup_pad
   WHERE par_sup_pad.cod_empresa   = p_cod_empresa
     AND par_sup_pad.cod_parametro = "desig_cons6510"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR
     m_desig_cons6510 = " " OR
     m_desig_cons6510 IS NULL THEN
     LET m_desig_cons6510 = "N"
  END IF

  INITIALIZE m_cod_grp_desp_nfr TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_sup_pad.par_val
    INTO m_cod_grp_desp_nfr
    FROM par_sup_pad
   WHERE par_sup_pad.cod_empresa   = p_cod_empresa
     AND par_sup_pad.cod_parametro = "cod_grp_desp_nfr"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET m_cod_grp_desp_nfr = 0
  END IF

  INITIALIZE m_cod_grp_desp_fat TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_sup_pad.par_val
    INTO m_cod_grp_desp_fat
    FROM par_sup_pad
   WHERE par_sup_pad.cod_empresa   = p_cod_empresa
     AND par_sup_pad.cod_parametro = "cod_grp_desp_fat"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET m_cod_grp_desp_fat = 0
  END IF

  INITIALIZE m_cod_tip_desp_cons TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_sup_compl_1.cod_tip_desp_cons
    INTO m_cod_tip_desp_cons
    FROM par_sup_compl_1
   WHERE par_sup_compl_1.cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET m_cod_tip_desp_cons = 0
  END IF

  INITIALIZE m_tip_desp_cons_fat TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_sup_pad.par_val
    INTO m_tip_desp_cons_fat
    FROM par_sup_pad
   WHERE par_sup_pad.cod_empresa   = p_cod_empresa
     AND par_sup_pad.cod_parametro = "tip_desp_cons_fat"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET m_tip_desp_cons_fat = 0
  END IF

 END FUNCTION

#----------------------------#
 FUNCTION sup0360_acesso_oc()
#----------------------------#
  IF p_ordem_sup.ies_versao_atual <> "S" THEN
     CALL log0030_mensagem("Somente versao atual da ordem pode ser modificada","exclamation")
     RETURN FALSE
  END IF

  IF p_ordem_sup.ies_situa_oc = "L" THEN
     CALL log0030_mensagem("Ordem de compra LIQUIDADA nao permite modificacao","exclamation")
     RETURN FALSE
  END IF

  IF p_ordem_sup.ies_situa_oc = "C" THEN
     CALL log0030_mensagem("Ordem de compra CANCELADA nao permite modificacao","exclamation")
     RETURN FALSE
  END IF

  IF p_ordem_sup.ies_situa_oc = "S" THEN
     CALL log0030_mensagem("Ordem de compra SUSPENSA nao permite modificacao","exclamation")
     RETURN FALSE
  END IF

  IF p_ordem_sup.num_pedido > 0 THEN
     IF p_ordem_sup.ies_situa_oc <> "A" THEN
        IF p_ordem_sup.ies_situa_oc = "R" AND sup0360_verifica_nova_versao_oc(p_ordem_sup.num_oc) THEN
        ELSE
           IF p_ordem_sup.ies_imobilizado = "C" THEN
              CALL log0030_mensagem("Somente ordens ABERTAS ligadas a contrato podem sofrer modificacao","exclamation")
           ELSE
              CALL log0030_mensagem("Somente ordens ABERTAS ligadas a pedido podem sofrer modificacao","exclamation")
           END IF
           RETURN FALSE
        END IF
     END IF

     #736097#
     IF find4GLFunction('supy62_empresa_55') THEN
        IF supy62_empresa_55() THEN
           IF find4GLFunction('supy62_valida_programador_subst') THEN
              IF NOT supy62_valida_comprador_subst(p_ordem_sup.num_oc, FALSE) THEN
                 IF NOT supy62_valida_programador_subst(p_ordem_sup.cod_empresa, p_ordem_sup.cod_item, p_user, TRUE) THEN
                    RETURN FALSE
                 END IF
              END IF
           END IF
        END IF
     ELSE
        IF m_ies_prog_alt_sup0360 = "N" THEN
           IF mr_usuario.cod_comprador IS NULL THEN
              CALL log0030_mensagem("Usuario nao cadastrado como COMPRADOR","exclamation")
              RETURN FALSE
           END IF
           IF p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
              #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
              IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                 CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                 RETURN FALSE
              END IF
           END IF
        ELSE # OS 554644
           #IF (mr_usuario.cod_progr IS NULL OR
           #    p_ordem_sup.cod_progr <> mr_usuario.cod_progr) AND
           #   (mr_usuario.cod_comprador IS NULL OR
           #    p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador) THEN
               #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
           IF p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
              IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                 CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                 RETURN FALSE
              END IF
           END IF
        END IF
     END IF
  ELSE
     IF find4GLFunction('supy62_empresa_55') THEN
        IF supy62_empresa_55() THEN
           IF find4GLFunction('supy62_valida_programador_subst') THEN
              IF NOT supy62_valida_comprador_subst(p_ordem_sup.num_oc, FALSE) THEN
                 IF NOT supy62_valida_programador_subst(p_ordem_sup.cod_empresa, p_ordem_sup.cod_item, p_user, TRUE) THEN
                    RETURN FALSE
                 END IF
              END IF
           END IF
        END IF
     ELSE
        CASE p_ordem_sup.ies_situa_oc
        WHEN "P"
           IF m_ies_oc_estoque THEN
              IF mr_usuario.cod_progr IS NULL THEN
                 CALL log0030_mensagem("Usuario nao cadastrado como PROGRAMADOR","exclamation")
                 RETURN FALSE
              END IF
              IF p_ordem_sup.cod_progr <> mr_usuario.cod_progr THEN
                 CALL log0030_mensagem("Usuario nao e' PROGRAMADOR desta ordem de compra","exclamation")
                 RETURN FALSE
              END IF
           ELSE
              IF NOT sup036_verif_solic() THEN
                 CALL log0030_mensagem("Usuario nao e' SOLICITANTE desta ordem de compra","exclamation")
                 RETURN FALSE
              END IF
           END IF
        WHEN ("D" OR "T")
           IF m_ies_prog_alt_sup0360 = "N" THEN
              IF mr_usuario.cod_comprador IS NULL THEN
                 CALL log0030_mensagem("Usuario nao cadastrado como COMPRADOR","exclamation")
                 RETURN FALSE
              END IF
              IF p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
                 #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
                 IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                    CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                    RETURN FALSE
                 END IF
              END IF
           ELSE # OS 554644
              #IF (mr_usuario.cod_progr IS NULL OR
              #    p_ordem_sup.cod_progr <> mr_usuario.cod_progr) AND
              #   (mr_usuario.cod_comprador IS NULL OR
              #    p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador) THEN
                  #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
              IF p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
                  IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                     CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                     RETURN FALSE
                  END IF
              END IF
           END IF
        WHEN "A"
           #apos designacao do fornecedor somente o comprador
           #podera' modificar a ordem de compra
           IF p_ordem_sup.cod_fornecedor = " " THEN
              IF m_ies_oc_estoque THEN
                 IF m_ies_excl_oc_aberta = "S" THEN
                    IF (mr_usuario.cod_progr IS NULL OR
                        p_ordem_sup.cod_progr <> mr_usuario.cod_progr) AND
                       (mr_usuario.cod_comprador IS NULL OR
                        p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador) THEN

                        #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
                        IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                           CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                           RETURN FALSE
                        END IF

                    END IF
                 ELSE
                    IF m_ies_prog_alt_sup0360 = "N" THEN
                       IF (mr_usuario.cod_comprador IS NULL OR
                           p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador) THEN
                           #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
                           IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                               CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                              RETURN FALSE
                          END IF
                       END IF
                    ELSE #OS 554644
                       #IF (mr_usuario.cod_progr IS NULL OR
                       #    p_ordem_sup.cod_progr <> mr_usuario.cod_progr) AND
                       #   (mr_usuario.cod_comprador IS NULL OR
                       #    p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador) THEN
                           #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
                       IF  p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
                           IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                              CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                              RETURN FALSE
                           END IF
                       END IF
                    END IF
                 END IF
              ELSE
                 IF m_ies_excl_oc_deb_dir = "S" THEN
                    IF NOT sup036_verif_solic() AND
                       NOT sup036_verif_aprov() THEN
                       IF m_ies_prog_alt_sup0360 = "N" THEN
                          IF mr_usuario.cod_comprador IS NULL
                          OR p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
                             #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
                             IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                                CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                                RETURN FALSE
                              END IF
                          END IF
                       ELSE
                          IF (mr_usuario.cod_progr IS NULL OR
                              p_ordem_sup.cod_progr <> mr_usuario.cod_progr) AND
                             (mr_usuario.cod_comprador IS NULL OR
                              p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador) THEN
                             CALL log0030_mensagem("Ordem de compra de outro PROGRAMADOR","exclamation")
                             RETURN FALSE
                          END IF
                       END IF
                    END IF
                 ELSE
                    IF NOT sup036_verif_aprov() THEN
                       IF m_ies_prog_alt_sup0360 = "N" THEN
                          IF mr_usuario.cod_comprador IS NULL
                          OR p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
                             #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
                             IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                                CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                                RETURN FALSE
                             END IF
                          END IF
                       ELSE #OS 554644
                          #IF (mr_usuario.cod_progr IS NULL OR
                          #    p_ordem_sup.cod_progr <> mr_usuario.cod_progr) AND
                          #   (mr_usuario.cod_comprador IS NULL OR
                          #    p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador) THEN
                              #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
                          IF p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
                              IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                                 CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                                 RETURN FALSE
                              END IF
                          END IF
                       END IF
                    END IF
                 END IF
              END IF
           ELSE
              IF m_ies_prog_alt_sup0360 = "N" THEN
                 IF mr_usuario.cod_comprador IS NULL THEN
                    CALL log0030_mensagem("Usuario nao cadastrado como COMPRADOR","exclamation")
                    RETURN FALSE
                 END IF
                 IF p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
                    #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
                    IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                       CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                       RETURN FALSE
                     END IF
                 END IF
              ELSE # OS 554644
                 #IF (mr_usuario.cod_progr IS NULL OR
                 #    p_ordem_sup.cod_progr <> mr_usuario.cod_progr) AND
                 #   (mr_usuario.cod_comprador IS NULL OR
                 #    p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador) THEN
                     #IF sup0360_comprador_autorizado(p_ordem_sup.cod_comprador) = FALSE THEN
                 IF  p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
                     IF NOT sup1662_comprador_substituto(p_ordem_sup.cod_comprador, p_user) THEN
                        CALL log0030_mensagem("Ordem de compra de outro COMPRADOR","exclamation")
                        RETURN FALSE
                     END IF
                 END IF
              END IF
           END IF
        END CASE
     END IF
  END IF

  RETURN TRUE
 END FUNCTION

#------------------------------------#
 FUNCTION sup0360_sistema_argentino()
#------------------------------------#
  DEFINE l_char CHAR(01)

  LET l_char = "N"
  SELECT parametros[76,76] INTO l_char
    FROM par_logix
   WHERE par_logix.cod_empresa = p_cod_empresa

  RETURN (l_char = "S")
 END FUNCTION

#-----------------------------------------#
 FUNCTION sup0360_tipo_compra_oc(l_num_oc)
#-----------------------------------------#
  DEFINE l_num_oc     LIKE ordem_sup.num_oc,
         l_tip_compra LIKE ordem_sup_compl.tip_compra

  LET l_tip_compra = "S" #Spot (Compra Normal)

  SELECT tip_compra INTO l_tip_compra
    FROM ordem_sup_compl
   WHERE cod_empresa = p_cod_empresa
     AND num_oc      = l_num_oc

  RETURN l_tip_compra
 END FUNCTION

#---------------------------------------------------#
 FUNCTION sup0360_valor_limite_oc_contrato(l_num_oc)
#---------------------------------------------------#
  DEFINE l_num_oc           LIKE ordem_sup.num_oc,
         l_val_tot_contrato LIKE ordem_sup_compl.val_tot_contrato

  LET l_val_tot_contrato = 0
  SELECT val_tot_contrato INTO l_val_tot_contrato
    FROM ordem_sup_compl
   WHERE cod_empresa = p_cod_empresa
     AND num_oc      = l_num_oc

  IF l_val_tot_contrato IS NULL THEN
     LET l_val_tot_contrato = 0
  END IF

  RETURN l_val_tot_contrato
 END FUNCTION

#-----------------------------------------------------------#
 FUNCTION sup0360_valor_total_oc_contrato(l_num_oc_contrato)
#-----------------------------------------------------------#
  DEFINE l_num_oc_contrato  LIKE ordem_sup.num_oc,
         l_qtd_solic        LIKE ordem_sup.qtd_solic,
         l_pre_unit_oc      LIKE ordem_sup.pre_unit_oc,
         l_val_tot_contrato LIKE ordem_sup_compl.val_tot_contrato

  LET l_val_tot_contrato = 0

  DECLARE cc_soma_vlr CURSOR FOR
   SELECT ordem_sup.qtd_solic, ordem_sup.pre_unit_oc
     FROM ordem_sup, ordem_sup_compl
    WHERE ordem_sup.cod_empresa       = p_cod_empresa
      AND ordem_sup_compl.cod_empresa = p_cod_empresa
      AND ordem_sup.num_oc            = ordem_sup_compl.num_oc
      AND ordem_sup.ies_versao_atual  = "S"
      AND ordem_sup_compl.oc_contrato = l_num_oc_contrato

  FOREACH cc_soma_vlr INTO l_qtd_solic, l_pre_unit_oc
     IF l_qtd_solic <> 0 THEN
        LET l_val_tot_contrato = l_val_tot_contrato + (l_qtd_solic * l_pre_unit_oc)
     ELSE
        LET l_val_tot_contrato = l_val_tot_contrato + l_pre_unit_oc
     END IF
  END FOREACH

  RETURN l_val_tot_contrato
 END FUNCTION

#-----------------------------------------------------#
 FUNCTION sup0360_existe_estouro_oc_contrato(l_num_oc)
#-----------------------------------------------------#
  DEFINE l_num_oc          LIKE ordem_sup.num_oc,
         l_tip_compra_oc   LIKE ordem_sup_compl.tip_compra,
         l_num_oc_contrato LIKE ordem_sup_compl.oc_contrato

  LET l_tip_compra_oc = sup0360_tipo_compra_oc(p_ordem_sup.num_oc)
  IF l_tip_compra_oc NOT MATCHES "[CR]" THEN
     RETURN FALSE
  END IF

  IF l_tip_compra_oc = "C" THEN
     LET l_num_oc_contrato = l_num_oc
     IF NOT sup0360_recalcula_tot_contrato(l_num_oc_contrato) THEN
        RETURN TRUE
     END IF
  ELSE
     SELECT oc_contrato INTO l_num_oc_contrato
       FROM ordem_sup_compl
      WHERE cod_empresa = p_cod_empresa
        AND num_oc      = l_num_oc
  END IF

  IF sup0360_valor_total_oc_contrato(l_num_oc_contrato)
   > sup0360_valor_limite_oc_contrato(l_num_oc_contrato) THEN
     CALL log0030_mensagem("O valor total do contrato foi excedido. Modificacao cancelada","exclamation")
     RETURN TRUE
  END IF

  RETURN FALSE
 END FUNCTION

#----------------------------------------------------------#
 FUNCTION sup0360_recalcula_tot_contrato(l_num_oc_contrato)
#----------------------------------------------------------#
  DEFINE l_num_oc_contrato LIKE ordem_sup_compl.oc_contrato,
         l_val_tot_contrato LIKE ordem_sup_compl.val_tot_contrato,
         l_val_aux          LIKE ordem_sup_compl.val_tot_contrato,
         l_qtd_mult         INTEGER

  IF p_ordem_sup.qtd_solic = 0 THEN
     LET l_val_tot_contrato = p_ordem_sup.pre_unit_oc
  ELSE
     LET l_val_tot_contrato = p_ordem_sup.pre_unit_oc * p_ordem_sup.qtd_solic
  END IF

  WHENEVER ERROR CONTINUE
  UPDATE ordem_sup_compl
     SET val_tot_contrato = l_val_tot_contrato
   WHERE cod_empresa = p_cod_empresa
     AND num_oc      = l_num_oc_contrato
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("MODIFICACAO","ORDEM_SUP_COMPL")
     RETURN FALSE
  END IF

  RETURN TRUE
 END FUNCTION

#-------------------------#
 FUNCTION sup0360_popups()
#-------------------------#
   DEFINE l_char         CHAR(01),
          l_cod_local    LIKE dest_prog_ord_sup.cod_local,
          l_ies_situa_oc LIKE ordem_sup.ies_situa_oc

   INITIALIZE l_char, l_cod_local, l_ies_situa_oc TO NULL

   CASE
   WHEN INFIELD(cod_item)
      LET p_cod_item = sup702_popup_item()
      IF p_cod_item IS NOT NULL THEN
         CURRENT WINDOW IS w_sup03601
         DISPLAY p_cod_item TO cod_item
      END IF
      CALL log006_exibe_teclas("01 02 03 07",p_versao)
      CURRENT WINDOW IS w_sup03601

   WHEN INFIELD(ies_situa_oc)
      LET l_ies_situa_oc = log0830_list_box(11,25, "A {Aberto}, P {Planejada}, C {Cancelada}, D {Condicional}, L {Liquidada}, S {Suspensa}, T {Tomada de preco}")
      IF l_ies_situa_oc IS NOT NULL AND int_flag = 0 THEN
         CURRENT WINDOW IS w_sup03601
         DISPLAY l_ies_situa_oc TO ies_situa_oc
      END IF
      CALL log006_exibe_teclas("01 02 03 07",p_versao)
      CURRENT WINDOW IS w_sup03601

   WHEN INFIELD(ies_situa_prog)
      LET p_prog_ordem_sup.ies_situa_prog = log0830_list_box(15,42,
          "P {Planejado}, F {Firme}, C {Cancelado}, L {Liquidado}")
      IF int_flag = 0 THEN
         LET p_programas_oc[pa_curr].ies_situa_prog = p_prog_ordem_sup.ies_situa_prog
         DISPLAY p_programas_oc[pa_curr].ies_situa_prog
              TO s_sup03602[sc_curr].ies_situa_prog
      END IF
      CALL log006_exibe_teclas("01 02 03 07",p_versao)
      CURRENT WINDOW IS w_sup03602

   WHEN INFIELD(cod_local)
      LET l_cod_local = sup109_popup_local(p_prog_ordem_sup.cod_empresa)
      IF l_cod_local IS NOT NULL  THEN
         CURRENT WINDOW IS w_sup03603
         LET p_dest_prog_ord[ma_curr].cod_local = l_cod_local
         DISPLAY p_dest_prog_ord[ma_curr].cod_local
              TO s_sup03603[mc_curr].cod_local
      END IF
      CALL log006_exibe_teclas("01 02 03 07",p_versao)
      CURRENT WINDOW IS w_sup03603

   END CASE

   LET int_flag = 0
   OPTIONS
     HELP FILE m_dir_arq_help
 END FUNCTION

#-------------------------------------------#
 FUNCTION sup0360_ordem_importacao(l_funcao)
#-------------------------------------------#
  DEFINE l_ordem_compra       LIKE imp_ped_mst_proc.oc_nf_mestre,
         l_funcao             CHAR(01),
         l_count              SMALLINT

  ## I = verifica se OC eh de importacao,
  ## R = verifica se OC esta relacionado com processo mesmo sem utilizar
  ## conceito de provisao de despesa e relacionamento com NFM nacional
  IF l_funcao = "R" THEN
     INITIALIZE l_count TO NULL
     WHENEVER ERROR CONTINUE
     SELECT COUNT(*) INTO l_count
       FROM processo_imp, proc_item
      WHERE processo_imp.cod_empresa      = p_ordem_sup.cod_empresa
        AND processo_imp.ies_versao_atual = "S"
        AND processo_imp.ies_situacao     <> "C"
        AND proc_item.cod_empresa         = p_ordem_sup.cod_empresa
        AND proc_item.num_processo        = processo_imp.num_processo
        AND proc_item.num_versao          = processo_imp.num_versao
        AND proc_item.num_pedido          = p_ordem_sup.num_pedido
        AND proc_item.num_oc              = p_ordem_sup.num_oc
     WHENEVER ERROR STOP

     IF l_count > 0 THEN
        ERROR "Ordem de compra relacionada a processo de importacao"
        RETURN TRUE
     END IF
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  INITIALIZE l_ordem_compra TO NULL
  SELECT oc_nf_mestre
    INTO l_ordem_compra
    FROM imp_ped_mst_proc
   WHERE empresa       = p_ordem_sup.cod_empresa
     AND oc_nf_entrada = p_ordem_sup.num_oc
  WHENEVER ERROR STOP

  IF l_ordem_compra IS NOT NULL THEN
     ERROR "Ordem de compra relacionada a um pedido da NFM nacional" ATTRIBUTE(REVERSE)
     RETURN TRUE
  END IF


  WHENEVER ERROR CONTINUE
  INITIALIZE l_ordem_compra TO NULL
  SELECT oc_nf_entrada
    INTO l_ordem_compra
    FROM imp_ped_mst_proc
   WHERE empresa      = p_ordem_sup.cod_empresa
     AND oc_nf_mestre = p_ordem_sup.num_oc
  WHENEVER ERROR STOP

  IF l_ordem_compra IS NOT NULL THEN
     ERROR "Ordem relacionada a um processo de importacao (NFM Nacional)" ATTRIBUTE(REVERSE)
     RETURN TRUE
  END IF
  RETURN FALSE
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION sup0360_existe_recebimento(l_num_prog_entrega)
#-------------------------------------------------------#
  DEFINE l_num_prog_entrega LIKE prog_ordem_sup.num_prog_entrega

  IF p_ordem_sup.num_pedido = 0 THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  SELECT ar_ped.num_aviso_rec
    FROM ar_ped, aviso_rec_compl
   WHERE ar_ped.cod_empresa            = p_ordem_sup.cod_empresa
     AND ar_ped.num_pedido             = p_ordem_sup.num_pedido
     AND ar_ped.num_oc                 = p_ordem_sup.num_oc
     AND ar_ped.num_prog_entrega       = l_num_prog_entrega
     AND aviso_rec_compl.cod_empresa   = p_ordem_sup.cod_empresa
     AND aviso_rec_compl.num_aviso_rec = ar_ped.num_aviso_rec
     AND aviso_rec_compl.ies_situacao  NOT IN ("C")
  WHENEVER ERROR STOP

  IF sqlca.sqlcode = 0 OR sqlca.sqlcode = -284 THEN
     RETURN TRUE
  END IF
  RETURN FALSE
 END FUNCTION

#------------------------------------------#
 FUNCTION sup036_verifica_oc_centralizada()
#------------------------------------------#
 DEFINE l_contador       SMALLINT

 IF p_ordem_sup.num_pedido = 0 THEN
    RETURN FALSE
 END IF

 LET l_contador = NULL

 SELECT COUNT(*)
   INTO l_contador
   FROM sup_ped_com_cetl
  WHERE sup_ped_com_cetl.emp_relacionada    = p_ordem_sup.cod_empresa
    AND sup_ped_com_cetl.pedido_relacionado = p_ordem_sup.num_pedido

 IF sqlca.sqlcode <> 0 OR
    l_contador IS NULL THEN
    LET l_contador = 0
 END IF

 IF l_contador > 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#----------------------------------------#
 FUNCTION sup0360_verifica_pedido_score()
#----------------------------------------#
 INITIALIZE m_pedido_score TO NULL

 WHENEVER ERROR CONTINUE
 SELECT tex_observ_pedido[1,22]
   INTO m_pedido_score
   FROM pedido_sup_txt
  WHERE cod_empresa   = p_cod_empresa
    AND num_pedido    = p_ordem_sup.num_pedido
    AND num_seq       = 1
    AND ies_tip_texto = "S"
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#---------------------------------------------------------------------------------------#
 FUNCTION sup0360_verifica_orcamento(l_empresa, l_num_oc, l_fornec, l_qtd_solic,
                                     l_pre_unit_oc, l_pct_ipi, l_cnd_pgto, l_num_cotacao,
                                     l_item, l_funcao)
#---------------------------------------------------------------------------------------#
 DEFINE l_empresa              LIKE ordem_sup.cod_empresa,
        l_num_oc               LIKE ordem_sup.num_oc,
        l_fornec               LIKE ordem_sup.cod_fornecedor,
        l_qtd_solic            LIKE ordem_sup.qtd_solic,
        l_pre_unit_oc          LIKE ordem_sup.pre_unit_oc,
        l_ies_tip_incid_ipi    LIKE ordem_sup.ies_tip_incid_ipi,
        l_pct_ipi              LIKE ordem_sup.pct_ipi,
        l_ies_tip_incid_icms   LIKE ordem_sup.ies_tip_incid_icms,
        l_cnd_pgto             LIKE ordem_sup.cnd_pgto,
        l_num_cotacao          LIKE ordem_sup.num_cotacao,
        l_num_versao           LIKE ordem_sup.num_versao,
        l_item                 LIKE ordem_sup.cod_item,
        l_ies_pagamento        LIKE cond_pgto_cap.ies_pagamento,
        l_valor_compra         DECIMAL(17,2),
        l_funcao               CHAR(02)

 IF l_funcao = "IN" THEN
    WHENEVER ERROR CONTINUE
     SELECT ies_pagamento
       INTO l_ies_pagamento
       FROM cond_pgto_cap
      WHERE cnd_pgto = l_cnd_pgto
    WHENEVER ERROR STOP

    {Se a condição de pagamento for igual a 3 (sem pagamento), somente fazer o estorno
     do orçamento. Não fazer a inclusão/atualização.}
    IF l_ies_pagamento = "3" THEN
       RETURN TRUE
    END IF
 END IF

 WHENEVER ERROR CONTINUE
  SELECT ies_tip_incid_ipi, ies_tip_incid_icms
    INTO l_ies_tip_incid_ipi, l_ies_tip_incid_icms
    FROM ordem_sup
   WHERE cod_empresa = l_empresa
     AND num_oc      = l_num_oc
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 100 THEN
    WHENEVER ERROR CONTINUE
     SELECT ies_tip_incid_ipi, ies_tip_incid_icms
       INTO l_ies_tip_incid_ipi, l_ies_tip_incid_icms
       FROM item_sup
      WHERE cod_empresa = l_empresa
        AND cod_item    = l_item
    WHENEVER ERROR STOP
 END IF

 WHENEVER ERROR CONTINUE
  SELECT num_versao_cot
    INTO l_num_versao
    FROM ordem_sup_cot
   WHERE cod_empresa    = l_empresa
     AND num_oc         = l_num_oc
     AND cod_fornecedor = l_fornec
     AND num_cotacao    = l_num_cotacao
 WHENEVER ERROR STOP

 IF l_qtd_solic = 0 THEN
    LET l_valor_compra = (l_pre_unit_oc * (1 + (l_pct_ipi/100)))
 ELSE
    LET l_valor_compra = ((l_qtd_solic * l_pre_unit_oc) * (1 + (l_pct_ipi/100)))
 END IF


 IF find4GLFunction('supy39_atualiza_val_realiz') THEN
    IF NOT supy39_atualiza_val_realiz(l_empresa,
                                      l_num_oc,
                                      l_fornec,
                                      l_cnd_pgto,
                                      l_pre_unit_oc,
                                      l_pct_ipi,
                                      l_valor_compra,
                                      l_ies_tip_incid_ipi,
                                      l_ies_tip_incid_icms,
                                      l_num_cotacao,
                                      l_num_versao,
                                      l_funcao) THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION


#------------------------------------------------#
 FUNCTION sup0360_valida_num_pedido_fornec_array()
#------------------------------------------------#
 DEFINE l_status     SMALLINT,
        l_linha      SMALLINT

 DEFINE l_duplica_pedido_fornec CHAR(01)

 INITIALIZE l_duplica_pedido_fornec TO NULL
 CALL log2250_busca_parametro(p_cod_empresa,"duplica_pedido_fornec_oc_prog")
       RETURNING l_duplica_pedido_fornec, l_status
 IF l_duplica_pedido_fornec IS NULL OR
    l_duplica_pedido_fornec = " " THEN
    LET l_duplica_pedido_fornec = "N"
 END IF

 IF l_duplica_pedido_fornec = "P" THEN

    FOR l_linha = 1 TO 499
       IF l_linha <> sc_curr THEN
          IF p_programas_oc[l_linha].num_pedido_fornec =
             p_programas_oc[sc_curr].num_pedido_fornec THEN
             RETURN FALSE
          END IF
       END IF
    END FOR

 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------------------------------#
 FUNCTION sup0360_verifica_fornec_edi(l_cod_fornec)
#---------------------------------------------------#
 DEFINE l_cod_fornec  LIKE fornecedor.cod_fornecedor

 WHENEVER ERROR CONTINUE #OS463024
   SELECT cod_fornecedor
     FROM fornecedor_edi
    WHERE cod_empresa    = p_cod_empresa
      AND cod_fornecedor = l_cod_fornec
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    IF m_permitir_cancelar_oc_pc_edi = "N" THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#-------------------------------------------------#
 FUNCTION sup0360_verifica_nova_versao_oc(l_num_oc)
#-------------------------------------------------#
 DEFINE l_num_oc       LIKE ordem_sup.num_oc

 IF m_oc_pc_realizado = "S" THEN

    WHENEVER ERROR CONTINUE
    SELECT empresa
      FROM sup_par_oc
     WHERE empresa       = p_cod_empresa
       AND ordem_compra  = l_num_oc
       AND parametro     = "oc_realiz_temp"
       AND seq_parametro = 0
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode = 0 THEN
       RETURN TRUE
    END IF

 END IF

 RETURN FALSE
 END FUNCTION

##---------------------------------------------------------------#
# FUNCTION sup0360_comprador_autorizado(l_cod_comprador)
##---------------------------------------------------------------#
#  DEFINE l_cod_comprador LIKE comprador.cod_comprador,
#         l_msg CHAR(100)
#
#  IF mr_usuario.cod_comprador IS NULL OR
#     l_cod_comprador <> mr_usuario.cod_comprador THEN
#
#     WHENEVER ERROR CONTINUE
#       SELECT cod_comprador
#         FROM comprador_master
#        WHERE cod_empresa      = p_cod_empresa
#          AND login_substituto = p_user
#          AND cod_comprador    = l_cod_comprador
#     WHENEVER ERROR STOP
#     IF sqlca.sqlcode <> 0 AND
#        sqlca.sqlcode <> -284 THEN
#        IF mr_usuario.cod_comprador IS NULL THEN
#           CALL log0030_mensagem("Login nao cadastrado como comprador","excla")
#        ELSE
#            LET l_msg  = "Usuario nao é substituto do comprador ",l_cod_comprador USING "<<<"
#           CALL log0030_mensagem (l_msg,"excla")
#        END IF
#
#        RETURN FALSE
#     END IF
#  END IF
#
#  RETURN TRUE
#
# END FUNCTION

#O.S. 559541
#---------------------------------------------------------#
 FUNCTION sup0360_verifica_qtd_solic_total(l_qtd_total, l_num_oc)
#---------------------------------------------------------#
 DEFINE l_qtd_total      LIKE ordem_sup.qtd_solic,
        l_num_oc         LIKE ordem_sup.num_oc

 DEFINE l_posicao        SMALLINT,
        l_pct_tolerancia LIKE par_sup.pct_maximo_div_q,
        l_qtd_ar_ped     LIKE ar_ped.qtd_reservada,
        l_val_tolareacia LIKE ar_ped.qtd_reservada,
        l_val_aceite     LIKE ar_ped.qtd_reservada,
        l_status         SMALLINT,
        l_solic_ant      LIKE ordem_sup.qtd_solic,
        l_solic_tot      LIKE ordem_sup.qtd_solic

 IF m_oc_pc_realizado = 'S' AND p_ordem_sup.num_pedido <> 0 THEN

    LET l_qtd_ar_ped = sup477_baixa_saldo_pedido(p_cod_empresa,
                                                 p_ordem_sup.num_pedido,
                                                 l_num_oc,0)

    WHENEVER ERROR CONTINUE
    SELECT SUM(prog_ordem_sup.qtd_solic)
      INTO l_solic_ant
      FROM prog_ordem_sup, ordem_sup
     WHERE prog_ordem_sup.cod_empresa = p_cod_empresa
       AND ordem_sup.cod_empresa      = p_cod_empresa
       AND prog_ordem_sup.num_oc      = l_num_oc
       AND ordem_sup.num_oc           = l_num_oc
       AND ordem_sup.ies_versao_atual = "S"
       AND prog_ordem_sup.num_versao  = ordem_sup.num_versao
       AND prog_ordem_sup.ies_situa_prog IN ("F","P")
       AND (prog_ordem_sup.qtd_solic - prog_ordem_sup.qtd_recebida) > 0
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       LET l_solic_ant = 0
    END IF

    IF l_solic_ant IS NULL THEN
       LET l_solic_ant = 0
    END IF

    WHENEVER ERROR CONTINUE
    SELECT SUM(prog_ordem_sup.qtd_solic)
      INTO l_solic_tot
      FROM prog_ordem_sup, ordem_sup
     WHERE prog_ordem_sup.cod_empresa = p_cod_empresa
       AND ordem_sup.cod_empresa      = p_cod_empresa
       AND prog_ordem_sup.num_oc      = l_num_oc
       AND ordem_sup.num_oc           = l_num_oc
       AND ordem_sup.ies_versao_atual = "S"
       AND prog_ordem_sup.num_versao  = ordem_sup.num_versao
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       LET l_solic_tot = 0
    END IF

    IF l_solic_tot IS NULL THEN
       LET l_solic_tot = 0
    END IF

    LET l_qtd_total = (l_qtd_total - l_solic_ant) + l_solic_tot

    IF l_qtd_ar_ped > l_qtd_total THEN
       CALL log0030_mensagem("Quantidade já recebida maior que quantidade a ser solicitada.","exclamation")
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

END FUNCTION

#---------------------------------------------------#
 FUNCTION sup0360_valida_oc_consignacao(lr_ordem_sup)
#---------------------------------------------------#
 DEFINE lr_ordem_sup    RECORD LIKE ordem_sup.*,
        l_ies_oc_consig SMALLINT,
        l_count         SMALLINT,
        l_msg           CHAR(100)

 LET l_ies_oc_consig = FALSE

 IF m_tip_desp_cons_fat = 0 AND
    m_cod_tip_desp_cons = 0 AND
    m_cod_grp_desp_nfr  = 0 AND
    m_cod_grp_desp_fat  = 0 THEN
    RETURN TRUE
 END IF

 IF (lr_ordem_sup.cod_tip_despesa > 0 AND
    (lr_ordem_sup.cod_tip_despesa = m_cod_tip_desp_cons OR
     lr_ordem_sup.cod_tip_despesa = m_tip_desp_cons_fat)) THEN
    LET l_ies_oc_consig = TRUE
 END IF

 IF (lr_ordem_sup.gru_ctr_desp > 0 AND
    (lr_ordem_sup.gru_ctr_desp = m_cod_grp_desp_nfr OR
     lr_ordem_sup.gru_ctr_desp = m_cod_grp_desp_fat)) THEN
    LET l_ies_oc_consig = TRUE
 END IF

 INITIALIZE l_count TO NULL
 WHENEVER ERROR CONTINUE
 SELECT COUNT(*)
   INTO l_count
   FROM item_forn_particip
  WHERE cod_empresa       = lr_ordem_sup.cod_empresa
    AND cod_item          = lr_ordem_sup.cod_item
    AND cod_fornecedor    = lr_ordem_sup.cod_fornecedor
    AND ies_tip_contrato  = "3"
    AND dat_ini_vigencia <= lr_ordem_sup.dat_entrega_prev
    AND dat_fim_vigencia >= lr_ordem_sup.dat_entrega_prev
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("LEITURA","ITEM_FORN_PARTICIP")
    RETURN FALSE
 END IF

 IF l_count IS NULL THEN
    LET l_count = 0
 END IF

 INITIALIZE l_msg TO NULL
 IF l_count > 0 THEN
    IF m_desig_cons6510 = "V" THEN
       LET l_msg = "OC de consignação sem contrato de consignação vigente para o item."
    END IF
    LET l_ies_oc_consig = TRUE
 END IF

 IF l_ies_oc_consig THEN
    IF m_desig_cons6510 = "V" THEN
       IF lr_ordem_sup.cod_tip_despesa <> m_cod_tip_desp_cons OR
          lr_ordem_sup.gru_ctr_desp <> m_cod_grp_desp_nfr THEN
          LET l_msg = "OC de consignação nao é de remessa. Não permite modificação."
       ELSE
          IF lr_ordem_sup.qtd_solic <> 0 THEN
             LET l_msg = "OC de consignação não é de complemento de valor. Não permite modificação."
          END IF
       END IF
    ELSE
       IF m_desig_cons6510 = "N" THEN
          LET l_msg = "OC de consignação. Não permite modificação."
       ELSE
          IF (lr_ordem_sup.cod_tip_despesa > 0 AND
              lr_ordem_sup.cod_tip_despesa = m_tip_desp_cons_fat) OR
             (lr_ordem_sup.gru_ctr_desp > 0 AND
              lr_ordem_sup.gru_ctr_desp = m_cod_grp_desp_fat) THEN
             LET l_msg = "OC de consignação não é de remessa. Não permite modificação."
          END IF
       END IF
    END IF
    IF l_msg IS NOT NULL THEN
       CALL log0030_mensagem(l_msg,"exclamation")
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#-------------------------------#
 FUNCTION sup0360_existe_adiant()
#-------------------------------#
  DEFINE l_cod_empresa        LIKE empresa.cod_empresa,
         l_val_saldo_adiant   LIKE adiant.val_saldo_adiant

  INITIALIZE l_cod_empresa TO NULL
  WHENEVER ERROR CONTINUE
  SELECT emp_orig_destino.cod_empresa_destin
    INTO l_cod_empresa
    FROM emp_orig_destino
   WHERE emp_orig_destino.cod_empresa_orig = p_cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR l_cod_empresa IS NULL THEN
     LET l_cod_empresa = p_cod_empresa
  END IF

  WHENEVER ERROR CONTINUE
  SELECT SUM(val_saldo_adiant)
    INTO l_val_saldo_adiant
    FROM adiant
   WHERE adiant.cod_empresa    = l_cod_empresa
     AND adiant.num_pedido     = p_ordem_sup.num_pedido
     AND adiant.cod_fornecedor = p_ordem_sup.cod_fornecedor
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("SELECT","ADIANT")
  END IF

  IF l_val_saldo_adiant > 0 THEN
     RETURN TRUE
  END IF

  RETURN FALSE

 END FUNCTION

#---------------------------------------------#
 FUNCTION sup0360_verifica_contas(l_cod_empresa,
                                 l_num_oc)
#---------------------------------------------#
 DEFINE l_cod_empresa        LIKE dest_ordem_sup.cod_empresa,
        l_num_oc             LIKE dest_ordem_sup.num_oc,
        l_num_conta_deb_desp LIKE dest_ordem_sup.num_conta_deb_desp

 DEFINE lr_plano_contas RECORD LIKE plano_contas.*

 IF find4GLFunction('supy43_cliente_55') THEN
    IF NOT supy43_cliente_55(l_cod_empresa) THEN
       RETURN
    END IF
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cl_dest_ordem_sup CURSOR FOR
  SELECT dest_ordem_sup.num_conta_deb_desp
    FROM dest_ordem_sup
   WHERE dest_ordem_sup.cod_empresa = l_cod_empresa
     AND dest_ordem_sup.num_oc      = l_num_oc
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("FOREACH","CL_DEST_ORDEM_SUP")
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cl_dest_ordem_sup INTO l_num_conta_deb_desp
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CL_DEST_ORDEM_SUP")
    END IF

    CALL con088_verifica_cod_conta(l_cod_empresa,
                                   l_num_conta_deb_desp,
                                   "S",
                                   TODAY)
    RETURNING lr_plano_contas.*, p_status

    IF lr_plano_contas.ies_sit_conta <> "A" THEN
       CALL log0030_mensagem("Conta contábil da OC inativa. Permite somente alteração da data de entrega prevista.","exclamation")
       EXIT FOREACH
    END IF

 END FOREACH
 FREE cl_dest_ordem_sup

 END FUNCTION

#-------------------------------#
 FUNCTION sup0360_version_info()
#-------------------------------#
  RETURN "$Archive: /logix10R2/suprimentos/suprimentos/programas/sup0360.4gl $|$Revision: 9 $|$Date: 13/01/11 16:31 $|$Modtime: 11/01/11 11:22 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION

