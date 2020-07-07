#--------------------------------------------------------------------#
# SISTEMA.: ARE - AUTOMAÇÃO COMERCIAL DE REDES                       #
# PROGRAMA: ARE0070                                                  #
# OBJETIVO: MANUTENCAO CADASTRO DE PONTOS DE VENDA - SOL_PARAMETROS  #
# AUTOR...: ALUIZIO FERNANDO HABIZENREUTER                           #
# DATA....: 10/02/2004                                               #
#--------------------------------------------------------------------#
 DATABASE logix

 GLOBALS
     DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
            p_user                 LIKE usuario.nom_usuario,
            p_status               SMALLINT

     DEFINE p_ies_impressao        CHAR(001),
            g_ies_ambiente         CHAR(001),
            p_nom_arquivo          CHAR(100),
            p_nom_arquivo_back     CHAR(100),
    				p_msg						       CHAR(300) 
            

     DEFINE g_ies_grafico          SMALLINT

     DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
 END GLOBALS

#MODULARES
     DEFINE m_den_empresa          LIKE empresa.den_empresa

     DEFINE m_consulta_ativa       SMALLINT

     DEFINE sql_stmt               CHAR(800),
            where_clause           CHAR(400)

     DEFINE m_comando              CHAR(080)

     DEFINE m_caminho              CHAR(150),
            m_last_row             SMALLINT

     DEFINE mr_sol_parametros     RECORD LIKE sol_parametros.*,
            mr_sol_parametrosr    RECORD LIKE sol_parametros.*,
            mr_tela1              RECORD
            ies_logix_instal   LIKE sol_parametros.ies_logix_instal,
            cod_empresa_compra    LIKE sol_parametros.cod_empresa_compra,
            list_preco_avista     LIKE sol_parametros.list_preco_avista,
            list_preco_aprazo     LIKE sol_parametros.list_preco_aprazo,
            list_preco_promoc     LIKE sol_parametros.list_preco_promoc,
            ult_cod_barra         LIKE sol_parametros.ult_cod_barra
                                  END RECORD,
            mr_tela2              RECORD
            num_ult_orcamento     LIKE sol_parametros.num_ult_orcamento,
            cod_nat_oper_orc      LIKE sol_parametros.cod_nat_oper_orc,
            pct_desc_orc          LIKE sol_parametros.pct_desc_orc,
            qtd_dias_valid_orc    LIKE sol_parametros.qtd_dias_valid_orc,
            cod_moeda             LIKE moeda.cod_moeda
                                  END RECORD,
            mr_tela3              RECORD
            oper_vend_checkout    LIKE sol_parametros.oper_vend_checkout,
            oper_esto_checkout    LIKE sol_parametros.oper_esto_checkout,
            oper_transf_entrad    LIKE sol_parametros.oper_transf_entrad,
            oper_transf_saida     LIKE sol_parametros.oper_transf_saida
                                  END RECORD,
            mr_tela4              RECORD
            num_ult_suprimento    LIKE sol_parametros.num_ult_suprimento,
            num_max_sangria       LIKE sol_parametros.num_max_sangria,
            num_ult_sangria       LIKE sol_parametros.num_ult_sangria,
            num_ult_vale_comp     LIKE sol_parametros.num_ult_vale_comp,
            qtd_dias_valid_val    LIKE sol_parametros.qtd_dias_valid_val,
            num_ult_movto_cx      LIKE sol_parametros.num_ult_movto_cx,
            num_ult_transac       LIKE sol_parametros.num_ult_transac,
            cod_portador_tes      LIKE sol_parametros.cod_portador_tes
                                  END RECORD,
            mr_tela5              RECORD
            val_minimo_supr_pv    LIKE  sol_parametros.val_minimo_supr_pv,
            val_max_sangria_pv    LIKE  sol_parametros.val_max_sangria_pv,
            nat_oper_checkout     LIKE  sol_parametros.nat_oper_checkout,
            maximo_pv_operador    LIKE  sol_parametros.maximo_pv_operador,
            cod_local             LIKE  estoque_lote.cod_local,
            qtd_dias_ch_avista    LIKE  sol_parametros.qtd_dias_ch_avista,
            val_max_ch_avista     LIKE  sol_parametros.val_max_ch_avista,
            nat_oper_emis_nf      LIKE  sol_parametros.nat_oper_emis_nf,
            cod_cliente           LIKE  sol_parametros.cod_cliente,
            cod_local_exped       LIKE  sol_parametros.cod_local_exped,
            cod_cnd_pgto_cupom    LIKE  sol_parametros.cod_cnd_pgto_cupom
                                  END RECORD

#END MODULARES

 MAIN
     CALL log0180_conecta_usuario()
     LET p_versao = 'ARE0070-10.02.01' 

     WHENEVER ANY ERROR CONTINUE

     CALL log1400_isolation()
     SET LOCK MODE TO WAIT 30

     WHENEVER ANY ERROR STOP

     DEFER INTERRUPT

     LET m_caminho = log140_procura_caminho('are0070.iem')

     OPTIONS
         PREVIOUS KEY control-b,
         NEXT     KEY control-f,
         HELP    FILE m_caminho

     CALL log001_acessa_usuario('ARE','LOGARE')
          RETURNING p_status, p_cod_empresa, p_user

     IF  p_status = 0 THEN
         CALL are0070_controle()
     END IF
 END MAIN

#---------------------------#
 FUNCTION are0070_controle()
#---------------------------#
     CALL log006_exibe_teclas('01', p_versao)

     CALL are0070_inicia_variaveis()

     LET m_caminho = log1300_procura_caminho('are0070','')

     OPEN WINDOW w_are0070 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     MENU 'OPCAO'
         COMMAND 'Incluir'   'Inclui um novo item na tabela de parâmetros gerais.'
            # HELP 001
             MESSAGE ''
             IF  log005_seguranca(p_user, 'ARE', 'ARE0070', 'IN') THEN
                IF are0070_verifica_empresa() = TRUE THEN
                   CALL are0070_inclusao_sol_parametros()
                ELSE
                   CALL log0030_mensagem('Parâmetros já cadastrados para esta empresa. Utilize a opção modificar.','excl')
                END IF
             END IF

         COMMAND 'Modificar' 'Modifica um item existente na tabela de parâmetros gerais.'
            # HELP 002
             MESSAGE ''
             IF  m_consulta_ativa THEN
                 IF  log005_seguranca(p_user, 'ARE', 'ARE0070', 'MO') THEN
                     CALL are0070_modificacao_sol_parametros()
                 END IF
             ELSE
                 CALL log0030_mensagem('Consulte previamente para fazer a modificação.','excl')
             END IF

         COMMAND 'Excluir'   'Exclui um item existente na tabela de parâmetros gerais.'
            # HELP 003
             MESSAGE ''
             IF  m_consulta_ativa THEN
                 IF  log005_seguranca(p_user, 'ARE', 'ARE0070', 'EX') THEN
                     CALL are0070_exclusao_sol_parametros()
                 END IF
             ELSE
                 CALL log0030_mensagem('Consulte previamente para fazer a exclusão.','excl')
             END IF

         COMMAND 'Consultar' 'Pesquisa a tabela de parâmetros gerais.'
            # HELP 004
             MESSAGE ''
             IF  log005_seguranca(p_user, 'ARE' , 'ARE0070', 'CO') THEN
                 CALL are0070_consulta_sol_parametros()
             END IF

         COMMAND KEY ('O') 'Orçamento' 'Consulta tela de orçamento '
            # HELP 004
             MESSAGE ''
             IF  log005_seguranca(p_user, 'ARE' , 'ARE0070', 'CO') THEN
                 CALL are0070_consulta_orcamento()
             END IF

         COMMAND KEY ('Q') 'estoQues' 'Consulta tela de estoques '
            # HELP 004
             MESSAGE ''
             IF  log005_seguranca(p_user, 'ARE' , 'ARE0070', 'CO') THEN
                 CALL are0070_consulta_estoques()
             END IF

         COMMAND KEY ('N') 'fiNanceiro' 'Consulta tela de financeiro '
            # HELP 004
             MESSAGE ''
             IF  log005_seguranca(p_user, 'ARE' , 'ARE0070', 'CO') THEN
                 CALL are0070_consulta_financeiro()
             END IF

         COMMAND KEY ('K') 'checK-out' 'Consulta tela de check-out'
            # HELP 004
             MESSAGE ''
             IF  log005_seguranca(p_user, 'ARE' , 'ARE0070', 'CO') THEN
                 CALL are0070_consulta_checkout()
             END IF

         COMMAND KEY ('S') "Sobre" "Exibe a versão do programa"
             CALL are0070_sobre() 		

         COMMAND KEY ("!")
             PROMPT "Digite o comando : " FOR m_comando
             RUN m_comando
             PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

         COMMAND 'Fim'       'Retorna ao menu anterior.'
            # HELP 008
             EXIT MENU
     END MENU

     CLOSE WINDOW w_are0070
 END FUNCTION

#-----------------------#
FUNCTION are0070_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-----------------------------------#
 FUNCTION are0070_verifica_empresa()
#-----------------------------------#
 SELECT * INTO mr_sol_parametros.* FROM sol_parametros
  WHERE cod_empresa = p_cod_empresa
 IF sqlca.sqlcode <> 0 THEN
    RETURN TRUE
 ELSE
    CALL are0070_exibe_dados()
    RETURN FALSE
 END IF

 END FUNCTION
#-----------------------------------#
 FUNCTION are0070_inicia_variaveis()
#-----------------------------------#
     LET m_consulta_ativa           = FALSE

     INITIALIZE mr_sol_parametros.*  TO NULL
     INITIALIZE mr_sol_parametrosr.* TO NULL
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0070_inclusao_sol_parametros()
#-------------------------------------------------------#
     LET mr_sol_parametros.*         = mr_sol_parametros.*

     INITIALIZE mr_sol_parametros.* TO NULL

     CLEAR FORM

     IF  are0070_entrada_dados('INCLUSAO') THEN
         WHENEVER ERROR CONTINUE

         SELECT * FROM sol_parametros
          WHERE cod_empresa  = p_cod_empresa
         IF sqlca.sqlcode <> 0 THEN
            INSERT INTO sol_parametros VALUES (mr_sol_parametros.*)
         ELSE
            UPDATE sol_parametros SET sol_parametros.* = mr_sol_parametros.*
             WHERE cod_empresa  = p_cod_empresa
         END IF
         WHENEVER ERROR STOP

         IF  sqlca.sqlcode = 0 THEN
             MESSAGE ' Inclusão efetuada com sucesso. ' ATTRIBUTE(REVERSE)
         ELSE
             CALL log003_err_sql('INCLUSAO','SOL_PARAMETROS')
         END IF
     ELSE
         LET mr_sol_parametros.*     = mr_sol_parametrosr.*
         CALL are0070_exibe_dados()
         ERROR ' Inclusão Cancelada. ' ATTRIBUTE(REVERSE)
     END IF
 END FUNCTION

#----------------------------------------#
 FUNCTION are0070_entrada_dados(l_funcao)
#----------------------------------------#
 DEFINE l_funcao              CHAR(015)
 IF are0070_entrada_dados1(l_funcao) = FALSE THEN
    RETURN FALSE
 END IF

 IF are0070_entrada_dados2(l_funcao) = FALSE THEN
    RETURN FALSE
 END IF

 IF are0070_entrada_dados3(l_funcao) = FALSE THEN
    RETURN FALSE
 END IF

 IF are0070_entrada_dados4(l_funcao) = FALSE THEN
    RETURN FALSE
 END IF

 IF are0070_entrada_dados5(l_funcao) = FALSE THEN
    RETURN FALSE
 END IF
 RETURN TRUE
 END FUNCTION

#----------------------------------------#
 FUNCTION are0070_entrada_dados1(l_funcao)
#----------------------------------------#
 DEFINE l_funcao              CHAR(015)

     IF  l_funcao = 'INCLUSAO' THEN
         LET mr_sol_parametros.cod_empresa = p_cod_empresa
         DISPLAY p_cod_empresa  TO cod_empresa
         CALL log006_exibe_teclas('01 02 03 07', p_versao)
     ELSE
         CALL log006_exibe_teclas('01 02 07', p_versao)
     END IF

     CURRENT WINDOW IS w_are0070

     LET int_flag = FALSE

     INPUT BY NAME mr_tela1.* WITHOUT DEFAULTS
         AFTER  FIELD ies_logix_instal
             IF  mr_tela1.ies_logix_instal IS NULL THEN
                 LET mr_tela1.ies_logix_instal = 'S'
                 DISPLAY BY NAME mr_tela1.ies_logix_instal
             END IF

         BEFORE FIELD cod_empresa_compra
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF
     	
          AFTER FIELD cod_empresa_compra
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela1.cod_empresa_compra IS NOT NULL THEN
                 IF  are0070_verifica_cod_empresa_compra() = FALSE THEN
                     NEXT FIELD cod_empresa_compra
                 END IF
             ELSE
                 CALL log0030_mensagem('Código empresa inválido.','excl')
                 NEXT FIELD cod_empresa_compra
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD list_preco_avista
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

          AFTER FIELD list_preco_avista
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela1.list_preco_avista IS NOT NULL THEN
                 IF  are0070_verifica_lista_preco(mr_tela1.list_preco_avista ) = FALSE THEN
                     CALL log0030_mensagem('Lista de preço não cadastrada.','excl')
                     NEXT FIELD list_preco_avista
                 END IF
             ELSE
                 CALL log0030_mensagem('Lista de preço inválida.','excl')
                 NEXT FIELD list_preco_avista
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD list_preco_aprazo
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

          AFTER FIELD list_preco_aprazo
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela1.list_preco_aprazo IS NOT NULL THEN
                 IF  are0070_verifica_lista_preco(mr_tela1.list_preco_aprazo ) = FALSE THEN
                     CALL log0030_mensagem('Lista de preço não cadastrada.','excl')
                     NEXT FIELD list_preco_aprazo
                 END IF
             ELSE
                 CALL log0030_mensagem('Lista de preço inválida.','excl')
                 NEXT FIELD list_preco_aprazo
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD list_preco_promoc
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

          AFTER FIELD list_preco_promoc
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela1.list_preco_promoc IS NOT NULL THEN
                 IF  are0070_verifica_lista_preco(mr_tela1.list_preco_promoc ) = FALSE THEN
                     CALL log0030_mensagem('Lista de preço não cadastrada.','excl')
                     NEXT FIELD list_preco_promoc
                 END IF
             ELSE
                 CALL log0030_mensagem('Lista de preço inválida.','excl')
                 NEXT FIELD list_preco_promoc
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

          #ON KEY (control-w)
           #  CALL are0070_help()

          ON KEY (control-z, f4)
             CALL are0070_popup()

     END INPUT



     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0070

     IF  int_flag THEN
         LET int_flag = FALSE
         RETURN FALSE
     ELSE
         LET mr_sol_parametros.cod_empresa         = p_cod_empresa
         LET mr_sol_parametros.ies_logix_instal = mr_tela1.ies_logix_instal
         LET mr_sol_parametros.cod_empresa_compra = mr_tela1.cod_empresa_compra
         LET mr_sol_parametros.list_preco_avista = mr_tela1.list_preco_avista
         LET mr_sol_parametros.list_preco_aprazo = mr_tela1.list_preco_aprazo
         LET mr_sol_parametros.list_preco_promoc = mr_tela1.list_preco_promoc
         LET mr_sol_parametros.ult_cod_barra     = mr_tela1.ult_cod_barra
         RETURN TRUE
     END IF
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0070_verifica_cod_empresa_compra()
#-------------------------------------------------------#
     SELECT den_empresa
       FROM empresa
      WHERE cod_empresa = mr_tela1.cod_empresa_compra

     IF  sqlca.sqlcode = 0 THEN
     ELSE
         CALL log0030_mensagem('Empresa não cadastrada.','excl')
         RETURN FALSE
     END IF
     RETURN TRUE

 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0070_verifica_lista_preco(l_num_list)
#-------------------------------------------------------#
DEFINE l_num_list    LIKE list_preco_mest.num_list_preco

     SELECT UNIQUE num_list_preco
       FROM desc_preco_mest
      WHERE cod_empresa = cod_empresa
        AND num_list_preco = l_num_list

     IF  sqlca.sqlcode = 0 THEN
     ELSE
         RETURN FALSE
     END IF
     RETURN TRUE

 END FUNCTION


#------------------------#
 FUNCTION are0070_popup()
#------------------------#
     DEFINE l_empresa             LIKE sol_parametros.cod_empresa,
            l_cod_operacao        LIKE estoque_operac.cod_operacao,
            l_cnd_pgto            LIKE cond_pgto.cod_cnd_pgto,
            l_cod_moeda           LIKE moeda.cod_moeda,
            l_cod_cliente         LIKE clientes.cod_cliente,
            l_cod_cnd_pgto        LIKE cond_pgto.cod_cnd_pgto,
            l_num_list            LIKE list_preco_mest.num_list_preco

     DEFINE l_condicao            CHAR(300)

     LET l_condicao = NULL

     CASE
         WHEN infield(cod_cnd_pgto_cupom)
             LET l_cod_cnd_pgto = log009_popup(8,20,
                                               'CONDIÇÕES DE PAGAMENTO',
                                               'cond_pgto',
                                               'cod_cnd_pgto',
                                               'den_cnd_pgto',
                                               'vdp0210',
                                               'N',
                                                l_condicao)

             IF  l_cod_cnd_pgto IS NOT NULL THEN
                 LET mr_tela5.cod_cnd_pgto_cupom = l_cod_cnd_pgto
                 CURRENT WINDOW IS w_are00704
                 DISPLAY BY NAME mr_tela5.cod_cnd_pgto_cupom
             END IF

         WHEN infield(cod_empresa_compra)
             LET l_empresa  = log009_popup(8,20,
                                               'EMPRESAS',
                                               'empresa',
                                               'cod_empresa',
                                               'den_empresa',
                                               'log0200',
                                               'N',
                                                l_condicao)

             IF  l_empresa IS NOT NULL THEN
                 LET mr_tela1.cod_empresa_compra = l_empresa
                 CURRENT WINDOW IS w_are0070
                 DISPLAY BY NAME mr_tela1.cod_empresa_compra
             END IF

         WHEN infield(list_preco_avista)
             LET l_num_list  = log009_popup(8,20,
                                               'LISTA DE PREÇOS',
                                               'desc_preco_mest',
                                               'num_list_preco',
                                               'den_list_preco',
                                               'vdp0270',
                                               'S',
                                                l_condicao)

             IF  l_num_list IS NOT NULL THEN
                 LET mr_tela1.list_preco_avista = l_num_list
                 CURRENT WINDOW IS w_are0070
                 DISPLAY BY NAME mr_tela1.list_preco_avista
             END IF

         WHEN infield(list_preco_aprazo)
             LET l_num_list  = log009_popup(8,20,
                                               'LISTA DE PREÇOS',
                                               'desc_preco_mest',
                                               'num_list_preco',
                                               'den_list_preco',
                                               'vdp0270',
                                               'S',
                                                l_condicao)

             IF  l_num_list IS NOT NULL THEN
                 LET mr_tela1.list_preco_aprazo = l_num_list
                 CURRENT WINDOW IS w_are0070
                 DISPLAY BY NAME mr_tela1.list_preco_aprazo
             END IF

         WHEN infield(list_preco_promoc)
             LET l_num_list  = log009_popup(8,20,
                                               'LISTA DE PREÇOS',
                                               'desc_preco_mest',
                                               'num_list_preco',
                                               'den_list_preco',
                                               'vdp0270',
                                               'S',
                                                l_condicao)

             IF  l_num_list IS NOT NULL THEN
                 LET mr_tela1.list_preco_promoc = l_num_list
                 CURRENT WINDOW IS w_are0070
                 DISPLAY BY NAME mr_tela1.list_preco_promoc
             END IF

         WHEN infield(oper_vend_checkout)
             LET l_cod_operacao = log009_popup(8,20,
                                               'OPERAÇÕES',
                                               'estoque_operac',
                                               'cod_operacao',
                                               'den_operacao',
                                               'sup0660',
                                               'S',
                                                l_condicao)

             IF  l_cod_operacao IS NOT NULL THEN
                 LET mr_tela3.oper_vend_checkout = l_cod_operacao
                 CURRENT WINDOW IS w_are00702
                 DISPLAY BY NAME mr_tela3.oper_vend_checkout
             END IF
             RETURN

         WHEN infield(oper_esto_checkout)
             LET l_cod_operacao = log009_popup(8,20,
                                               'OPERAÇÕES',
                                               'estoque_operac',
                                               'cod_operacao',
                                               'den_operacao',
                                               'sup0660',
                                               'S',
                                                l_condicao)

             IF  l_cod_operacao IS NOT NULL THEN
                 LET mr_tela3.oper_esto_checkout = l_cod_operacao
                 CURRENT WINDOW IS w_are00702
                 DISPLAY BY NAME mr_tela3.oper_esto_checkout
             END IF
             RETURN

         WHEN infield(oper_transf_entrad)
             LET l_cod_operacao = log009_popup(8,20,
                                               'OPERAÇÕES',
                                               'estoque_operac',
                                               'cod_operacao',
                                               'den_operacao',
                                               'sup0660',
                                               'S',
                                                l_condicao)

             IF  l_cod_operacao IS NOT NULL THEN
                 LET mr_tela3.oper_transf_entrad = l_cod_operacao
                 CURRENT WINDOW IS w_are00702
                 DISPLAY BY NAME mr_tela3.oper_transf_entrad
             END IF
             RETURN

         WHEN infield(oper_transf_saida)
             LET l_cod_operacao = log009_popup(8,20,
                                               'OPERAÇÕES',
                                               'estoque_operac',
                                               'cod_operacao',
                                               'den_operacao',
                                               'sup0660',
                                               'S',
                                                l_condicao)

             IF  l_cod_operacao IS NOT NULL THEN
                 LET mr_tela3.oper_transf_saida = l_cod_operacao
                 CURRENT WINDOW IS w_are00702
                 DISPLAY BY NAME mr_tela3.oper_transf_saida
             END IF
             RETURN

         WHEN infield(nat_oper_emis_nf)
             LET l_cod_operacao = log009_popup(8,20,
                                               'NATUREZA DE OPERAÇÕES',
                                               'nat_operacao',
                                               'cod_nat_oper',
                                               'den_nat_oper',
                                               'vdp0050',
                                               'N',
                                                l_condicao)

             IF  l_cod_operacao IS NOT NULL THEN
                 LET mr_tela5.nat_oper_emis_nf   = l_cod_operacao
                 CURRENT WINDOW IS w_are00704
                 DISPLAY BY NAME mr_tela5.nat_oper_emis_nf
             END IF
             RETURN

         WHEN infield(cod_nat_oper_orc)
             LET l_cod_operacao = log009_popup(8,20,
                                               'NATUREZA DE OPERAÇÕES',
                                               'nat_operacao',
                                               'cod_nat_oper',
                                               'den_nat_oper',
                                               'vdp0050',
                                               'N',
                                                l_condicao)

             IF  l_cod_operacao IS NOT NULL THEN
                 LET mr_tela2.cod_nat_oper_orc  = l_cod_operacao
                 CURRENT WINDOW IS w_are00701
                 DISPLAY BY NAME mr_tela2.cod_nat_oper_orc
             END IF
             RETURN

         WHEN infield(cod_moeda)
             LET l_cod_moeda    = log009_popup(8,20,
                                               'MOEDAS',
                                               'moeda',
                                               'cod_moeda',
                                               'den_moeda',
                                               'PAT1680',
                                               'N',
                                                l_condicao)

             IF  l_cod_moeda IS NOT NULL THEN
                 LET mr_tela2.cod_moeda  = l_cod_moeda
                 CURRENT WINDOW IS w_are00701
                 DISPLAY BY NAME mr_tela2.cod_moeda
             END IF
             RETURN

         WHEN infield(nat_oper_checkout)
             LET l_cod_operacao = log009_popup(8,20,
                                               'NATUREZA DE OPERAÇÕES',
                                               'nat_operacao',
                                               'cod_nat_oper',
                                               'den_nat_oper',
                                               'vdp0050',
                                               'N',
                                                l_condicao)

             IF  l_cod_operacao IS NOT NULL THEN
                 LET mr_tela5.nat_oper_checkout  = l_cod_operacao
                 CURRENT WINDOW IS w_are00704
                 DISPLAY BY NAME mr_tela5.nat_oper_checkout
             END IF
             RETURN

         WHEN infield(cod_cliente)
             LET l_cod_cliente = vdp372_popup_cliente()
             CALL log006_exibe_teclas("01 02 03 07", p_versao)
             CURRENT WINDOW IS w_are00704
             IF   l_cod_cliente IS NOT NULL
             THEN LET mr_tela5.cod_cliente = l_cod_cliente
                  DISPLAY BY NAME mr_tela5.cod_cliente
             END IF
             RETURN

      END CASE

     CALL log006_exibe_teclas('01 02 03 07', p_versao)
     CURRENT WINDOW IS w_are0070
 END FUNCTION

#------------------------#
 FUNCTION are0070_help()
#------------------------#
     CASE
         WHEN infield(cod_empresa)
             CALL SHOWHELP(101)

         WHEN infield(cod_ponto_venda)
             CALL showhelp(102)
     END CASE
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0070_bloqueia_sol_parametros()
#-------------------------------------------------------#
     DECLARE cm_sol_parametros CURSOR FOR
      SELECT * FROM sol_parametros
       WHERE sol_parametros.cod_empresa  = p_cod_empresa
     FOR UPDATE

     CALL log085_transacao("BEGIN")

     WHENEVER ERROR CONTINUE
        OPEN  cm_sol_parametros
        FETCH cm_sol_parametros INTO mr_sol_parametros.*
     WHENEVER ERROR STOP

     CASE
         WHEN sqlca.sqlcode = 0
             RETURN TRUE
         WHEN sqlca.sqlcode = NOTFOUND
             CALL log0030_mensagem(' Registro não mais existe na tabela.\nExecute a consulta novamente. ', 'exclamation')
             CALL log085_transacao("ROLLBACK")
         OTHERWISE
             CALL log003_err_sql('LEITURA','SOL_PARAMETROS')
             CALL log085_transacao("ROLLBACK")
     END CASE

         WHENEVER ERROR CONTINUE
            CLOSE cm_sol_parametros
            FREE  cm_sol_parametros
         WHENEVER ERROR STOP

     RETURN FALSE
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0070_modificacao_sol_parametros()
#-------------------------------------------------------#
     LET mr_sol_parametrosr.* = mr_sol_parametros.*

     IF  are0070_bloqueia_sol_parametros() THEN
         CALL are0070_exibe_dados()

         IF  are0070_entrada_dados('MODIFICACAO') THEN
            WHENEVER ERROR CONTINUE
            LET mr_sol_parametros.cod_aposentado     = mr_sol_parametrosr.cod_aposentado
            LET mr_sol_parametros.cod_cnd_pgto_conv  = mr_sol_parametrosr.cod_cnd_pgto_conv
            LET mr_sol_parametros.cod_form_pgto_conv = mr_sol_parametrosr.cod_form_pgto_conv
            LET mr_sol_parametros.cod_tip_cli_conv   = mr_sol_parametrosr.cod_tip_cli_conv
            LET mr_sol_parametros.dia_ini_comis_ext  = mr_sol_parametrosr.dia_ini_comis_ext
            LET mr_sol_parametros.dia_fim_comis_ext  = mr_sol_parametrosr.dia_fim_comis_ext
            LET mr_sol_parametros.dia_ini_comis_int  = mr_sol_parametrosr.dia_ini_comis_int
            LET mr_sol_parametros.dia_fim_comis_int  = mr_sol_parametrosr.dia_fim_comis_int
            LET mr_sol_parametros.ies_prox_tef       = mr_sol_parametrosr.ies_prox_tef
            UPDATE sol_parametros SET sol_parametros.* = mr_sol_parametros.*
              WHERE CURRENT OF cm_sol_parametros

             WHENEVER ERROR STOP

             IF  sqlca.sqlcode = 0 THEN
                 CLOSE cm_sol_parametros
                 CALL log085_transacao("COMMIT")
                 MESSAGE ' Modificação efetuada com sucesso. ' ATTRIBUTE(REVERSE)
             ELSE
                 CALL log003_err_sql('MODIFICACAO','SOL_PARAMETROS')
                 CLOSE cm_sol_parametros
                 CALL log085_transacao("ROLLBACK")
                 LET mr_sol_parametros.* = mr_sol_parametrosr.*
                 CALL are0070_exibe_dados()
             END IF
         ELSE
             CLOSE cm_sol_parametros
             CALL log085_transacao("ROLLBACK")
             LET mr_sol_parametros.* = mr_sol_parametrosr.*
             CALL are0070_exibe_dados()
             ERROR ' Modificação cancelada. ' ATTRIBUTE(REVERSE)
         END IF
     END IF
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0070_exclusao_sol_parametros()
#-------------------------------------------------------#
     IF  are0070_bloqueia_sol_parametros() THEN
         CALL are0070_exibe_dados()

         IF  log004_confirm(17,45)  THEN
             WHENEVER ERROR CONTINUE
                DELETE FROM sol_parametros
                WHERE CURRENT OF cm_sol_parametros
             WHENEVER ERROR STOP

             IF  sqlca.sqlcode = 0 THEN
                 CLOSE cm_sol_parametros
                 CALL log085_transacao("COMMIT")
                 MESSAGE ' Exclusão efetuada com sucesso. ' ATTRIBUTE(REVERSE)
                 INITIALIZE mr_sol_parametros.* TO NULL
                 CALL are0070_exibe_dados()
             ELSE
                 CALL log003_err_sql('EXCLUSAO','SOL_PARAMETROS')
                 CLOSE cm_sol_parametros
                 CALL log085_transacao("ROLLBACK")
             END IF
         ELSE
             CLOSE cm_sol_parametros
             CALL log085_transacao("ROLLBACK")
             ERROR ' Exclusão cancelada. '
         END IF
     END IF
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0070_consulta_sol_parametros()
#-------------------------------------------------------#
     CALL log006_exibe_teclas('01 02 07 08', p_versao)
     CURRENT WINDOW IS w_are0070

     LET where_clause       =  NULL

     CLEAR FORM

     DISPLAY p_cod_empresa TO cod_empresa

     LET int_flag           = FALSE

     CONSTRUCT BY NAME where_clause ON sol_parametros.ies_logix_instal,
                                       sol_parametros.cod_empresa_compra,
                                       sol_parametros.list_preco_avista,
                                       sol_parametros.list_preco_aprazo

     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0070

     IF  int_flag THEN
         LET int_flag         = FALSE
         ERROR ' Consulta cancelada. ' ATTRIBUTE (REVERSE)
     ELSE
         CALL are0070_prepara_consulta()
     END IF

     CALL are0070_exibe_dados()

     CALL log006_exibe_teclas('01 09', p_versao)
     CURRENT WINDOW IS w_are0070
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION are0070_prepara_consulta()
#-------------------------------------------------------#
     LET sql_stmt = 'SELECT * FROM sol_parametros',
                    ' WHERE cod_empresa = "',p_cod_empresa,'" AND ', where_clause CLIPPED

     PREPARE var_sol_parametros FROM sql_stmt

     DECLARE cq_sol_parametros SCROLL CURSOR WITH HOLD FOR var_sol_parametros

     OPEN  cq_sol_parametros
     FETCH cq_sol_parametros INTO mr_sol_parametros.*

     IF  sqlca.sqlcode = 0 THEN
         MESSAGE ' Consulta efetuada com sucesso. ' ATTRIBUTE (REVERSE)
         LET m_consulta_ativa = TRUE
     ELSE
         LET m_consulta_ativa = FALSE
         CALL log0030_mensagem(' Argumentos de pesquisa não encontrados. ','excl')
         CLEAR FORM
     END IF
 END FUNCTION


#------------------------------#
 FUNCTION are0070_exibe_dados()
#------------------------------#
     DISPLAY p_cod_empresa             TO cod_empresa
     LET mr_tela1.ies_logix_instal      = mr_sol_parametros.ies_logix_instal
     LET mr_tela1.cod_empresa_compra    = mr_sol_parametros.cod_empresa_compra
     LET mr_tela1.list_preco_avista     = mr_sol_parametros.list_preco_avista
     LET mr_tela1.list_preco_aprazo     = mr_sol_parametros.list_preco_aprazo
     LET mr_tela1.list_preco_promoc     = mr_sol_parametros.list_preco_promoc
     LET mr_tela1.ult_cod_barra         = mr_sol_parametros.ult_cod_barra
     LET mr_tela2.num_ult_orcamento     = mr_sol_parametros.num_ult_orcamento
     LET mr_tela2.cod_nat_oper_orc      = mr_sol_parametros.cod_nat_oper_orc
     LET mr_tela2.pct_desc_orc          = mr_sol_parametros.pct_desc_orc
     LET mr_tela2.qtd_dias_valid_orc    = mr_sol_parametros.qtd_dias_valid_orc
     LET mr_tela2.cod_moeda             = mr_sol_parametros.cod_moeda
     LET mr_tela3.oper_vend_checkout    = mr_sol_parametros.oper_vend_checkout
     LET mr_tela3.oper_esto_checkout    = mr_sol_parametros.oper_esto_checkout
     LET mr_tela3.oper_transf_entrad    = mr_sol_parametros.oper_transf_entrad
     LET mr_tela3.oper_transf_saida     = mr_sol_parametros.oper_transf_saida
     LET mr_tela4.num_ult_suprimento    = mr_sol_parametros.num_ult_suprimento
     LET mr_tela4.num_max_sangria       = mr_sol_parametros.num_max_sangria
     LET mr_tela4.num_ult_sangria       = mr_sol_parametros.num_ult_sangria
     LET mr_tela4.num_ult_vale_comp     = mr_sol_parametros.num_ult_vale_comp
     LET mr_tela4.qtd_dias_valid_val    = mr_sol_parametros.qtd_dias_valid_val
     LET mr_tela4.num_ult_movto_cx      = mr_sol_parametros.num_ult_movto_cx
     LET mr_tela4.num_ult_transac       = mr_sol_parametros.num_ult_transac
     LET mr_tela4.cod_portador_tes      = mr_sol_parametros.cod_portador_tes
     LET mr_tela5.val_minimo_supr_pv    = mr_sol_parametros.val_minimo_supr_pv
     LET mr_tela5.val_max_sangria_pv    = mr_sol_parametros.val_max_sangria_pv
     LET mr_tela5.nat_oper_checkout     = mr_sol_parametros.nat_oper_checkout
     LET mr_tela5.maximo_pv_operador    = mr_sol_parametros.maximo_pv_operador
     LET mr_tela5.cod_local             = mr_sol_parametros.cod_local
     LET mr_tela5.qtd_dias_ch_avista    = mr_sol_parametros.qtd_dias_ch_avista
     LET mr_tela5.val_max_ch_avista     = mr_sol_parametros.val_max_ch_avista
     LET mr_tela5.nat_oper_emis_nf      = mr_sol_parametros.nat_oper_emis_nf
     LET mr_tela5.cod_cliente           = mr_sol_parametros.cod_cliente
     LET mr_tela5.cod_local_exped       = mr_sol_parametros.cod_local_exped
     LET mr_tela5.cod_cnd_pgto_cupom    = mr_sol_parametros.cod_cnd_pgto_cupom
     DISPLAY BY NAME mr_tela1.*

 END FUNCTION

#----------------------------------------#
 FUNCTION are0070_entrada_dados2(l_funcao)
#----------------------------------------#
 DEFINE l_funcao              CHAR(015),
        l_den_operacao     LIKE estoque_operac.den_operacao,
        l_den_moeda        LIKE moeda.den_moeda

     LET m_caminho = log1300_procura_caminho('are00701','')

     OPEN WINDOW w_are00701 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     IF  l_funcao = 'INCLUSAO' THEN
         LET mr_sol_parametros.cod_empresa = p_cod_empresa
         DISPLAY p_cod_empresa  TO cod_empresa
         CALL log006_exibe_teclas('01 02 03 07', p_versao)
     ELSE
         DISPLAY BY NAME mr_tela2.*
         CALL are0070_exibe_dados2()
         CALL log006_exibe_teclas('01 02 07', p_versao)
     END IF

     CURRENT WINDOW IS w_are00701

     LET int_flag = FALSE
     DISPLAY p_cod_empresa  TO cod_empresa
     INPUT BY NAME mr_tela2.* WITHOUT DEFAULTS
         AFTER  FIELD num_ult_orcamento
             IF  mr_tela2.num_ult_orcamento IS NULL THEN
                 CALL log0030_mensagem('Número do último orçamento inválido.','excl')
                 NEXT FIELD num_ult_orcamento
             END IF

         BEFORE FIELD cod_nat_oper_orc
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

         AFTER  FIELD cod_nat_oper_orc
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela2.cod_nat_oper_orc IS NOT NULL THEN
                 LET l_den_operacao = are0070_verifica_nat_operacoes(mr_tela2.cod_nat_oper_orc)
                 IF l_den_operacao IS NULL THEN
                     NEXT FIELD cod_nat_oper_orc
                 END IF
                 DISPLAY l_den_operacao    TO den_nat_oper_orc
             ELSE
                 CALL log0030_mensagem('Código de operação inválido.','excl')
                 NEXT FIELD cod_nat_oper_orc
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         AFTER  FIELD pct_desc_orc
             IF  mr_tela2.pct_desc_orc IS NULL THEN
                 CALL log0030_mensagem('Percentual de desconto inválido.','excl')
                 NEXT FIELD pct_desc_orc
             END IF

         AFTER  FIELD qtd_dias_valid_orc
             IF  mr_tela2.qtd_dias_valid_orc IS NULL THEN
                 CALL log0030_mensagem('Quantidade de dias para orçamento inválido.','excl')
                 NEXT FIELD qtd_dias_valid_orc
             END IF

         BEFORE FIELD cod_moeda
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

         AFTER  FIELD cod_moeda
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela2.cod_moeda IS NOT NULL THEN
                 WHENEVER ERROR CONTINUE
                    SELECT den_moeda
                      INTO l_den_moeda
                      FROM moeda
                     WHERE cod_moeda = mr_tela2.cod_moeda
                 WHENEVER ERROR STOP
                 IF sqlca.sqlcode <> 0 THEN
                     CALL log0030_mensagem('Moeda não cadastrada.','excl')
                     NEXT FIELD cod_moeda
                 END IF
                 DISPLAY l_den_moeda       TO den_moeda
             ELSE
                 CALL log0030_mensagem('Código de moeda inválido.','excl')
                 NEXT FIELD cod_moeda
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         # ON KEY (control-w)
          #   CALL are0070_help()

          AFTER INPUT
             IF  NOT int_flag THEN
                 IF l_funcao = 'INCLUSAO' THEN
                 END IF
                 IF  mr_tela2.num_ult_orcamento IS NULL THEN
                     CALL log0030_mensagem('Número do último orçamento inválido.','excl')
                     NEXT FIELD num_ult_orcamento
                 END IF

                 IF  mr_tela2.cod_nat_oper_orc IS NOT NULL THEN
                     LET l_den_operacao = are0070_verifica_nat_operacoes(mr_tela2.cod_nat_oper_orc)
                     IF l_den_operacao IS NULL THEN
                         NEXT FIELD cod_nat_oper_orc
                     END IF
                     DISPLAY l_den_operacao    TO den_nat_oper_orc
                 ELSE
                     CALL log0030_mensagem('Código de operação inválido.','excl')
                     NEXT FIELD cod_nat_oper_orc
                 END IF

                 IF  mr_tela2.pct_desc_orc IS NULL THEN
                     CALL log0030_mensagem('Percentual de desconto inválido.','excl')
                     NEXT FIELD pct_desc_orc
                 END IF

                 IF  mr_tela2.qtd_dias_valid_orc IS NULL THEN
                     CALL log0030_mensagem('Quantidade de dias para orçamento inválido.','excl')
                     NEXT FIELD qtd_dias_valid_orc
                 END IF

                 IF  mr_tela2.cod_moeda IS NOT NULL THEN
                     WHENEVER ERROR CONTINUE
                        SELECT den_moeda
                          INTO l_den_moeda
                          FROM moeda
                         WHERE cod_moeda = mr_tela2.cod_moeda
                     WHENEVER ERROR STOP
                     IF sqlca.sqlcode <> 0 THEN
                        CALL log0030_mensagem('Moeda não cadastrada.','excl')
                        NEXT FIELD cod_moeda
                     END IF
                 ELSE
                     CALL log0030_mensagem('Código de moeda inválido.','excl')
                     NEXT FIELD cod_moeda
                 END IF
             END IF

          ON KEY (control-z, f4)
             CALL are0070_popup()

     END INPUT

     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are00701
     CLOSE WINDOW w_are00701
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0070

     IF  int_flag THEN
         LET int_flag = FALSE
         RETURN FALSE
     ELSE
         LET mr_sol_parametros.cod_empresa        = p_cod_empresa
         LET mr_sol_parametros.num_ult_orcamento  = mr_tela2.num_ult_orcamento
         LET mr_sol_parametros.cod_nat_oper_orc   = mr_tela2.cod_nat_oper_orc
         LET mr_sol_parametros.pct_desc_orc       = mr_tela2.pct_desc_orc
         LET mr_sol_parametros.qtd_dias_valid_orc = mr_tela2.qtd_dias_valid_orc
         LET mr_sol_parametros.cod_moeda          = mr_tela2.cod_moeda
         LET mr_sol_parametros.cod_aposentado     = NULL
         LET mr_sol_parametros.cod_cnd_pgto_conv  = NULL
         LET mr_sol_parametros.cod_form_pgto_conv  = NULL
         RETURN TRUE
     END IF
 END FUNCTION
#------------------------------#
 FUNCTION are0070_exibe_dados2()
#------------------------------#
 DEFINE l_den_operacao     LIKE estoque_operac.den_operacao,
        l_den_moeda        LIKE moeda.den_moeda

 LET l_den_operacao = NULL
 SELECT den_nat_oper INTO l_den_operacao
   FROM nat_operacao
  WHERE cod_nat_oper = mr_tela2.cod_nat_oper_orc

  DISPLAY p_cod_empresa             TO cod_empresa
  DISPLAY l_den_operacao            TO den_nat_oper_orc

 LET l_den_moeda = NULL
 SELECT den_moeda INTO l_den_moeda
   FROM moeda
  WHERE cod_moeda = mr_tela2.cod_moeda
  DISPLAY l_den_moeda               TO den_moeda

 END FUNCTION

#---------------------------------------------------#
 FUNCTION are0070_verifica_nat_operacoes(l_cod_nat_oper)
#---------------------------------------------------#
 DEFINE l_cod_nat_oper     LIKE nat_operacao.cod_nat_oper,
        l_den_nat_oper     LIKE nat_operacao.den_nat_oper

 LET l_den_nat_oper = NULL
 SELECT den_nat_oper INTO l_den_nat_oper
   FROM nat_operacao
  WHERE cod_nat_oper = l_cod_nat_oper

 IF sqlca.sqlcode <> 0 THEN
    CALL log0030_mensagem('Código de natureza de operação não cadastrado.','excl')
    LET l_den_nat_oper = NULL
 END IF
 RETURN l_den_nat_oper

 END FUNCTION

#----------------------------------------#
 FUNCTION are0070_entrada_dados3(l_funcao)
#----------------------------------------#
 DEFINE l_funcao              CHAR(015),
        l_den_operacao     LIKE estoque_operac.den_operacao

     LET m_caminho = log1300_procura_caminho('are00702','')

     OPEN WINDOW w_are00702 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     IF  l_funcao = 'INCLUSAO' THEN
         LET mr_sol_parametros.cod_empresa = p_cod_empresa
         DISPLAY p_cod_empresa  TO cod_empresa
         CALL log006_exibe_teclas('01 02 03 07', p_versao)
     ELSE
         DISPLAY BY NAME mr_tela3.*
         CALL are0070_exibe_dados3()
         CALL log006_exibe_teclas('01 02 07', p_versao)
     END IF

     CURRENT WINDOW IS w_are00702

     LET int_flag = FALSE
     DISPLAY p_cod_empresa  TO cod_empresa
     INPUT BY NAME mr_tela3.* WITHOUT DEFAULTS
         BEFORE FIELD oper_vend_checkout
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

         AFTER  FIELD oper_vend_checkout
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela3.oper_vend_checkout IS NOT NULL THEN
                 LET l_den_operacao = are0070_verifica_operacoes(mr_tela3.oper_vend_checkout)
                 IF l_den_operacao IS NULL THEN
                     NEXT FIELD oper_vend_checkout
                 END IF
                 DISPLAY l_den_operacao      TO den_vend_checkout
             ELSE
                 CALL log0030_mensagem('Código de operação inválido.','excl')
                 NEXT FIELD oper_vend_checkout
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD oper_esto_checkout
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

         AFTER  FIELD oper_esto_checkout
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela3.oper_esto_checkout IS NOT NULL THEN
                 LET l_den_operacao = are0070_verifica_operacoes(mr_tela3.oper_esto_checkout)
                 IF l_den_operacao IS NULL THEN
                     NEXT FIELD oper_esto_checkout
                 END IF
                 DISPLAY l_den_operacao    TO den_esto_checkout
             ELSE
                 CALL log0030_mensagem('Código de operação inválido.','excl')
                 NEXT FIELD oper_esto_checkout
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD oper_transf_entrad
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

         AFTER  FIELD oper_transf_entrad
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela3.oper_transf_entrad IS NOT NULL THEN
                 LET l_den_operacao = are0070_verifica_operacoes(mr_tela3.oper_transf_entrad)
                 IF l_den_operacao IS NULL THEN
                     NEXT FIELD oper_transf_entrad
                 END IF
                 DISPLAY l_den_operacao    TO den_transf_entrad
             ELSE
                 CALL log0030_mensagem('Código de operação inválido.','excl')
                 NEXT FIELD oper_transf_entrad
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         BEFORE FIELD oper_transf_saida
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

         AFTER  FIELD oper_transf_saida
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela3.oper_transf_saida IS NOT NULL THEN
                 LET l_den_operacao = are0070_verifica_operacoes(mr_tela3.oper_transf_saida)
                 IF l_den_operacao IS NULL THEN
                     NEXT FIELD oper_transf_saida
                 END IF
                 DISPLAY l_den_operacao    TO den_transf_saida
             ELSE
                 CALL log0030_mensagem('Código de operação inválido.','excl')
                 NEXT FIELD oper_transf_saida
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         # ON KEY (control-w)
          #   CALL are0070_help()

          AFTER INPUT
             IF  NOT int_flag THEN
                 IF l_funcao = 'INCLUSAO' THEN
                 END IF
                 IF  mr_tela3.oper_vend_checkout IS NOT NULL THEN
                     LET l_den_operacao = are0070_verifica_operacoes(mr_tela3.oper_vend_checkout)
                     IF l_den_operacao IS NULL THEN
                         NEXT FIELD oper_vend_checkout
                     END IF
                     DISPLAY l_den_operacao      TO den_vend_checkout
                 ELSE
                     CALL log0030_mensagem('Código de operação inválido.','excl')
                     NEXT FIELD oper_vend_checkout
                 END IF

                 IF  mr_tela3.oper_esto_checkout IS NOT NULL THEN
                     LET l_den_operacao = are0070_verifica_operacoes(mr_tela3.oper_esto_checkout)
                     IF l_den_operacao IS NULL THEN
                         NEXT FIELD oper_esto_checkout
                     END IF
                     DISPLAY l_den_operacao    TO den_esto_checkout
                 ELSE
                     CALL log0030_mensagem('Código de operação inválido.','excl')
                     NEXT FIELD oper_esto_checkout
                 END IF

                 IF  mr_tela3.oper_transf_entrad IS NOT NULL THEN
                     LET l_den_operacao = are0070_verifica_operacoes(mr_tela3.oper_transf_entrad)
                     IF l_den_operacao IS NULL THEN
                        NEXT FIELD oper_transf_entrad
                     END IF
                     DISPLAY l_den_operacao    TO den_transf_entrad
                 ELSE
                     CALL log0030_mensagem('Código de operação inválido.','excl')
                     NEXT FIELD oper_transf_entrad
                 END IF

                 IF  mr_tela3.oper_transf_saida IS NOT NULL THEN
                     LET l_den_operacao = are0070_verifica_operacoes(mr_tela3.oper_transf_saida)
                     IF l_den_operacao IS NULL THEN
                        NEXT FIELD oper_transf_saida
                     END IF
                     DISPLAY l_den_operacao    TO den_transf_saida
                 ELSE
                     CALL log0030_mensagem('Código de operação inválido.','excl')
                     NEXT FIELD oper_transf_saida
                 END IF
             END IF

          ON KEY (control-z, f4)
             CALL are0070_popup()

     END INPUT

     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are00702
     CLOSE WINDOW w_are00702
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0070

     IF  int_flag THEN
         LET int_flag = FALSE
         RETURN FALSE
     ELSE
         LET mr_sol_parametros.cod_empresa         = p_cod_empresa
         LET mr_sol_parametros.oper_vend_checkout = mr_tela3.oper_vend_checkout
         LET mr_sol_parametros.oper_transf_entrad = mr_tela3.oper_transf_entrad
         LET mr_sol_parametros.oper_transf_saida  = mr_tela3.oper_transf_saida
         LET mr_sol_parametros.oper_esto_checkout = mr_tela3.oper_esto_checkout
         RETURN TRUE
     END IF
 END FUNCTION

#---------------------------------------------------#
 FUNCTION are0070_verifica_operacoes(l_cod_operacao)
#---------------------------------------------------#
 DEFINE l_cod_operacao     LIKE estoque_operac.cod_operacao,
        l_den_operacao     LIKE estoque_operac.den_operacao

 LET l_den_operacao = NULL
 SELECT den_operacao INTO l_den_operacao
   FROM estoque_operac
  WHERE cod_empresa  = p_cod_empresa
    AND cod_operacao = l_cod_operacao

 IF sqlca.sqlcode <> 0 THEN
    CALL log0030_mensagem('Código de operação não cadastrado.','excl')
    LET l_den_operacao = NULL
 END IF
 RETURN l_den_operacao

 END FUNCTION

#------------------------------#
 FUNCTION are0070_exibe_dados3()
#------------------------------#
 DEFINE l_den_operacao     LIKE estoque_operac.den_operacao

 LET l_den_operacao = NULL
 SELECT den_operacao INTO l_den_operacao
   FROM estoque_operac
  WHERE cod_empresa  = p_cod_empresa
    AND cod_operacao = mr_tela3.oper_vend_checkout

  DISPLAY p_cod_empresa             TO cod_empresa
  DISPLAY l_den_operacao            TO den_vend_checkout

 LET l_den_operacao = NULL
 SELECT den_operacao INTO l_den_operacao
   FROM estoque_operac
  WHERE cod_empresa  = p_cod_empresa
    AND cod_operacao = mr_tela3.oper_esto_checkout
  DISPLAY l_den_operacao            TO den_esto_checkout

 LET l_den_operacao = NULL
 SELECT den_operacao INTO l_den_operacao
   FROM estoque_operac
  WHERE cod_empresa  = p_cod_empresa
    AND cod_operacao = mr_tela3.oper_transf_entrad
  DISPLAY l_den_operacao            TO den_transf_entrad

 LET l_den_operacao = NULL
 SELECT den_operacao INTO l_den_operacao
   FROM estoque_operac
  WHERE cod_empresa  = p_cod_empresa
    AND cod_operacao = mr_tela3.oper_transf_saida
  DISPLAY l_den_operacao            TO den_transf_saida

 END FUNCTION

#----------------------------------------#
 FUNCTION are0070_entrada_dados4(l_funcao)
#----------------------------------------#
 DEFINE l_funcao              CHAR(015)

     LET m_caminho = log1300_procura_caminho('are00703','')

     OPEN WINDOW w_are00703 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     IF  l_funcao = 'INCLUSAO' THEN
         LET mr_sol_parametros.cod_empresa = p_cod_empresa
         DISPLAY p_cod_empresa  TO cod_empresa
         CALL log006_exibe_teclas('01 02 03 07', p_versao)
     ELSE
         DISPLAY BY NAME mr_tela4.*
         CALL log006_exibe_teclas('01 02 07', p_versao)
     END IF

     CURRENT WINDOW IS w_are00703

     LET int_flag = FALSE
     DISPLAY p_cod_empresa  TO cod_empresa
     INPUT BY NAME mr_tela4.* WITHOUT DEFAULTS
         AFTER  FIELD num_ult_suprimento
             IF  mr_tela4.num_ult_suprimento IS NULL THEN
                 CALL log0030_mensagem('Número do último suprimento inválido','excl')
                 NEXT FIELD num_ult_suprimento
             END IF

         AFTER  FIELD num_max_sangria
             IF  mr_tela4.num_max_sangria IS NULL THEN
                 CALL log0030_mensagem('Número máximo de sangria inválido.','excl')
                 NEXT FIELD num_max_sangria
             END IF

         AFTER  FIELD num_ult_sangria
             IF  mr_tela4.num_ult_sangria IS NULL THEN
                 CALL log0030_mensagem('Número da última sangria inválida.','excl')
                 NEXT FIELD num_ult_sangria
             END IF

         AFTER  FIELD num_ult_vale_comp
             IF  mr_tela4.num_ult_vale_comp IS NULL THEN
                 CALL log0030_mensagem('Número do último Vale compra inválido.','excl')
                 NEXT FIELD num_ult_vale_comp
             END IF

         AFTER  FIELD qtd_dias_valid_val
             IF  mr_tela4.qtd_dias_valid_val IS NULL OR
                 mr_tela4.qtd_dias_valid_val < 0 THEN
                 CALL log0030_mensagem('Quantidade de dias da validade do vale esta inválido.','excl')
                 NEXT FIELD qtd_dias_valid_val
             END IF

         AFTER  FIELD num_ult_movto_cx
             IF  mr_tela4.num_ult_movto_cx IS NULL THEN
                 CALL log0030_mensagem('Número do último movimento de caixa inválido.','excl')
                 NEXT FIELD num_ult_movto_cx
             END IF


         AFTER  FIELD num_ult_transac
             IF  mr_tela4.num_ult_transac IS NULL THEN
                 CALL log0030_mensagem('Número da última transação tesouraria inválida','excl')
                 NEXT FIELD num_ult_transac
             END IF

         AFTER  FIELD cod_portador_tes
             IF  mr_tela4.cod_portador_tes IS NULL THEN
                 CALL log0030_mensagem('Código do Portador da Tesouraria inválido','excl')
                 NEXT FIELD cod_portador_tes
             END IF

         # ON KEY (control-w)
          #   CALL are0070_help()

          AFTER INPUT
             IF  NOT int_flag THEN
                 IF l_funcao = 'INCLUSAO' THEN
                 END IF
                 IF  mr_tela4.num_ult_suprimento IS NULL THEN
                     CALL log0030_mensagem('Número do último suprimento inválido','excl')
                     NEXT FIELD num_ult_suprimento
                 END IF

                 IF  mr_tela4.num_max_sangria IS NULL THEN
                     CALL log0030_mensagem('Código de operação inválido.','excl')
                     NEXT FIELD num_max_sangria
                 END IF

                 IF  mr_tela4.num_ult_sangria IS NULL THEN
                     CALL log0030_mensagem('Número da última sangria inválido.','excl')
                     NEXT FIELD num_ult_sangria
                 END IF

                 IF  mr_tela4.num_ult_vale_comp IS NULL THEN
                     CALL log0030_mensagem('Número do último Vale compra inválido.','excl')
                     NEXT FIELD num_ult_vale_comp
                 END IF

                 IF  mr_tela4.qtd_dias_valid_val IS NULL OR
                     mr_tela4.qtd_dias_valid_val < 0 THEN
                     CALL log0030_mensagem('Quantidade de dias da validade do vale esta inválido.','excl')
                     NEXT FIELD qtd_dias_valid_val
                 END IF
                 IF  mr_tela4.num_ult_movto_cx IS NULL THEN
                     CALL log0030_mensagem('Número do último movimento de compra inválido','excl')
                     NEXT FIELD num_ult_movto_cx
                 END IF
                 IF  mr_tela4.num_ult_transac  IS NULL THEN
                     CALL log0030_mensagem('Número do último movimento de tesouraria inválido.','excl')
                     NEXT FIELD num_ult_transac
                 END IF
                 IF  mr_tela4.cod_portador_tes IS NULL THEN
                     CALL log0030_mensagem('Código portador tesouraria inválido.','excl')
                     NEXT FIELD cod_portador_tes
                 END IF
             END IF

     END INPUT

     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are00703
     CLOSE WINDOW w_are00703
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0070

     IF  int_flag THEN
         LET int_flag = FALSE
         RETURN FALSE
     ELSE
         LET mr_sol_parametros.cod_empresa          = p_cod_empresa
         LET mr_sol_parametros.num_ult_suprimento   = mr_tela4.num_ult_suprimento
         LET mr_sol_parametros.num_max_sangria      = mr_tela4.num_max_sangria
         LET mr_sol_parametros.num_ult_sangria      = mr_tela4.num_ult_sangria
         LET mr_sol_parametros.num_ult_vale_comp    = mr_tela4.num_ult_vale_comp
         LET mr_sol_parametros.qtd_dias_valid_val   = mr_tela4.qtd_dias_valid_val
         LET mr_sol_parametros.num_ult_movto_cx     = mr_tela4.num_ult_movto_cx
         LET mr_sol_parametros.num_ult_transac      = mr_tela4.num_ult_transac
         LET mr_sol_parametros.cod_portador_tes     = mr_tela4.cod_portador_tes
         RETURN TRUE
     END IF
 END FUNCTION

#----------------------------------------#
 FUNCTION are0070_entrada_dados5(l_funcao)
#----------------------------------------#
 DEFINE l_funcao              CHAR(015),
        l_den_operacao        LIKE estoque_operac.den_operacao,
        l_nom_cliente         LIKE clientes.nom_cliente,
        l_den_cnd_pgto        LIKE cond_pgto.den_cnd_pgto

     LET m_caminho = log1300_procura_caminho('are00704','')

     OPEN WINDOW w_are00704 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     IF  l_funcao = 'INCLUSAO' THEN
         LET mr_sol_parametros.cod_empresa = p_cod_empresa
         DISPLAY p_cod_empresa  TO cod_empresa
         CALL log006_exibe_teclas('01 02 03 07', p_versao)
     ELSE
         CALL are0070_exibe_dados5()
         DISPLAY BY NAME mr_tela5.*
         CALL log006_exibe_teclas('01 02 07', p_versao)
     END IF

     CURRENT WINDOW IS w_are00704

     LET int_flag = FALSE
     DISPLAY p_cod_empresa  TO cod_empresa
     INPUT BY NAME mr_tela5.* WITHOUT DEFAULTS
         AFTER  FIELD val_minimo_supr_pv
             IF  mr_tela5.val_minimo_supr_pv IS NULL THEN
                 CALL log0030_mensagem('Valor mínimo suprimento inválido','excl')
                 NEXT FIELD val_minimo_supr_pv
             END IF

         AFTER  FIELD val_max_sangria_pv
             IF  mr_tela5.val_max_sangria_pv IS NULL THEN
                 CALL log0030_mensagem('Valor máximo para sangria inválido.','excl')
                 NEXT FIELD val_max_sangria_pv
             END IF

         BEFORE FIELD nat_oper_checkout
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

         AFTER  FIELD nat_oper_checkout
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela5.nat_oper_checkout IS NOT NULL THEN
                 LET l_den_operacao = are0070_verifica_nat_operacoes(mr_tela5.nat_oper_checkout)
                 IF l_den_operacao IS NULL THEN
                     NEXT FIELD nat_oper_checkout
                 END IF
                 DISPLAY l_den_operacao    TO den_oper_checkout
             ELSE
                 CALL log0030_mensagem('Código de operação inválido.','excl')
                 NEXT FIELD nat_oper_checkout
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         AFTER  FIELD maximo_pv_operador
             IF  mr_tela5.maximo_pv_operador IS NULL THEN
                 CALL log0030_mensagem('Máximo PV aberto por operador inválido.','excl')
                 NEXT FIELD maximo_pv_operador
             END IF

         AFTER  FIELD cod_local
           IF mr_tela5.cod_local IS NULL THEN
              CALL log0030_mensagem('Informe o código de local de estoque para CHECK-OUT','excl')
              NEXT FIELD cod_local
           END IF
{
           SELECT * FROM local
            WHERE cod_empresa = p_cod_empresa
              AND cod_local = mr_tela5.cod_local
           IF sqlca.sqlcode <> 0 THEN
              ERROR "Numero de lote nao cadastrado "
              NEXT FIELD cod_local
           END IF
}
         AFTER  FIELD qtd_dias_ch_avista
           IF mr_tela5.qtd_dias_ch_avista IS NULL OR
              mr_tela5.qtd_dias_ch_avista < 0 THEN
              CALL log0030_mensagem('Quantidade de dias para cheque deverá ser válido.','excl')
              NEXT FIELD qtd_dias_ch_avista
           END IF

         AFTER  FIELD val_max_ch_avista
           IF mr_tela5.val_max_ch_avista IS NULL OR
              mr_tela5.val_max_ch_avista <= 0 THEN
              CALL log0030_mensagem('Quantidade de dias para cheque devera ser válido.','excl')
              NEXT FIELD qtd_dias_ch_avista
           END IF

         BEFORE FIELD nat_oper_emis_nf
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

         AFTER  FIELD nat_oper_emis_nf
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela5.nat_oper_emis_nf IS NOT NULL THEN
                 LET l_den_operacao = are0070_verifica_nat_operacoes(mr_tela5.nat_oper_emis_nf)
                 IF l_den_operacao IS NULL THEN
                     NEXT FIELD nat_oper_emis_nf
                 END IF
                 DISPLAY l_den_operacao    TO den_oper_emis_nf
             ELSE
                 CALL log0030_mensagem('Código de operação inválido.','excl')
                 NEXT FIELD nat_oper_emis_nf
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)


         BEFORE FIELD cod_cliente
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

         AFTER  FIELD cod_cliente
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela5.cod_cliente IS NOT NULL THEN
                 SELECT nom_cliente INTO l_nom_cliente
                   FROM clientes
                  WHERE cod_cliente = mr_tela5.cod_cliente
                 IF sqlca.sqlcode <> 0 THEN
                    CALL log0030_mensagem('Cliente não cadastrado na tabela CLIENTE.','excl')
                    NEXT FIELD cod_cliente
                 END IF
                 DISPLAY l_nom_cliente     TO nom_cliente
             ELSE
                 CALL log0030_mensagem('Código de cliente inválido.','excl')
                 NEXT FIELD cod_cliente
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)

         AFTER  FIELD cod_local_exped
           IF mr_tela5.cod_local_exped IS NULL THEN
              CALL log0030_mensagem('Informe o código de local de estoque para CHECK-OUT','excl')
              NEXT FIELD cod_local_exped
           END IF

         BEFORE FIELD cod_cnd_pgto_cupom
     	     IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '( Zoom )' AT 3,68
     	     END IF

         AFTER  FIELD  cod_cnd_pgto_cupom
             IF g_ies_grafico THEN
--#          CALL fgl_dialog_setkeylabel('control-z','Zoom')
     	     ELSE DISPLAY '--------' AT 3,68
     	     END IF
             IF  mr_tela5.cod_cnd_pgto_cupom IS NOT NULL THEN
                 SELECT den_cnd_pgto INTO l_den_cnd_pgto
                   FROM cond_pgto
                  WHERE cod_cnd_pgto = mr_tela5.cod_cnd_pgto_cupom
                 IF sqlca.sqlcode <> 0 THEN
                    CALL log0030_mensagem('Condições de pagamento não cadastrada.','excl')
                    NEXT FIELD cod_cnd_pgto_cupom
                 END IF
                 DISPLAY l_den_cnd_pgto   TO den_cnd_pgto
             ELSE
                 CALL log0030_mensagem('Condição de pagamento inválido.','excl')
                 NEXT FIELD cod_cnd_pgto_cupom
             END IF

--#	    CALL fgl_dialog_setkeylabel('control-z',NULL)


        # ON KEY (control-w)
         #    CALL are0070_help()

          AFTER INPUT
             IF  NOT int_flag THEN
                 IF l_funcao = 'INCLUSAO' THEN
                 END IF
                 IF  mr_tela5.val_minimo_supr_pv IS NULL THEN
                     CALL log0030_mensagem('Valor mínimo suprimento inválido.','excl')
                     NEXT FIELD val_minimo_supr_pv
                 END IF

                 IF  mr_tela5.val_max_sangria_pv IS NULL THEN
                     CALL log0030_mensagem('Valor máximo para sangria inválido.','excl')
                     NEXT FIELD val_max_sangria_pv
                 END IF

                 IF  mr_tela5.nat_oper_checkout IS NOT NULL THEN
                     LET l_den_operacao = are0070_verifica_nat_operacoes(mr_tela5.nat_oper_checkout)
                     IF l_den_operacao IS NULL THEN
                         NEXT FIELD nat_oper_checkout
                     END IF
                     DISPLAY l_den_operacao    TO den_oper_checkout
                 ELSE
                     CALL log0030_mensagem('Código de operação inválido.','excl')
                     NEXT FIELD nat_oper_checkout
                 END IF

                 IF  mr_tela5.maximo_pv_operador IS NULL THEN
                     CALL log0030_mensagem('Máximo PV aberto por operador inválido.','excl')
                     NEXT FIELD maximo_pv_operador
                 END IF
             END IF

          ON KEY (control-z, f4)
             CALL are0070_popup()

     END INPUT

     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are00704
     CLOSE WINDOW w_are00704
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0070

     IF  int_flag THEN
         LET int_flag = FALSE
         RETURN FALSE
     ELSE
         LET mr_sol_parametros.cod_empresa          = p_cod_empresa
         LET mr_sol_parametros.val_minimo_supr_pv   = mr_tela5.val_minimo_supr_pv
         LET mr_sol_parametros.val_max_sangria_pv   = mr_tela5.val_max_sangria_pv
         LET mr_sol_parametros.nat_oper_checkout    = mr_tela5.nat_oper_checkout
         LET mr_sol_parametros.maximo_pv_operador   = mr_tela5.maximo_pv_operador
         LET mr_sol_parametros.cod_local            = mr_tela5.cod_local
         LET mr_sol_parametros.qtd_dias_ch_avista   = mr_tela5.qtd_dias_ch_avista
         LET mr_sol_parametros.val_max_ch_avista    = mr_tela5.val_max_ch_avista
         LET mr_sol_parametros.nat_oper_emis_nf     = mr_tela5.nat_oper_emis_nf
         LET mr_sol_parametros.cod_cliente          = mr_tela5.cod_cliente
         LET mr_sol_parametros.cod_local_exped      = mr_tela5.cod_local_exped
         LET mr_sol_parametros.cod_cnd_pgto_cupom   = mr_tela5.cod_cnd_pgto_cupom
         RETURN TRUE
     END IF
 END FUNCTION

#------------------------------#
 FUNCTION are0070_exibe_dados5()
#------------------------------#
 DEFINE l_den_operacao     LIKE estoque_operac.den_operacao,
        l_cnd_pgto            LIKE cond_pgto.den_cnd_pgto,
        l_nom_cliente         LIKE clientes.nom_cliente

 LET l_den_operacao = NULL
 SELECT den_nat_oper INTO l_den_operacao
   FROM nat_operacao
  WHERE cod_nat_oper = mr_tela5.nat_oper_checkout

  DISPLAY p_cod_empresa             TO cod_empresa
  DISPLAY l_den_operacao            TO den_oper_checkout

 SELECT den_nat_oper INTO l_den_operacao
   FROM nat_operacao
  WHERE cod_nat_oper = mr_tela5.nat_oper_emis_nf
  DISPLAY l_den_operacao            TO den_oper_emis_nf

   SELECT nom_cliente INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_tela5.cod_cliente
   DISPLAY l_nom_cliente     TO nom_cliente

   SELECT den_cnd_pgto INTO l_cnd_pgto
     FROM cond_pgto
    WHERE cod_cnd_pgto = mr_tela5.cod_cnd_pgto_cupom
   DISPLAY l_cnd_pgto    TO den_cnd_pgto
 END FUNCTION

#-------------------------------------#
 FUNCTION are0070_consulta_orcamento()
#-------------------------------------#
     LET m_caminho = log1300_procura_caminho('are00701','')

     OPEN WINDOW w_are00701 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     DISPLAY p_cod_empresa  TO cod_empresa
     DISPLAY BY NAME mr_tela2.*
     CALL are0070_exibe_dados2()

     CURRENT WINDOW IS w_are00701
     PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando
     CLOSE WINDOW w_are00701
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0070

 END FUNCTION

#-------------------------------------#
 FUNCTION are0070_consulta_estoques()
#-------------------------------------#
     LET m_caminho = log1300_procura_caminho('are00702','')

     OPEN WINDOW w_are00702 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     DISPLAY p_cod_empresa  TO cod_empresa
     DISPLAY BY NAME mr_tela3.*
     CALL are0070_exibe_dados3()

     CURRENT WINDOW IS w_are00702
     PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando
     CLOSE WINDOW w_are00702
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0070

 END FUNCTION

#-------------------------------------#
 FUNCTION are0070_consulta_financeiro()
#-------------------------------------#
     LET m_caminho = log1300_procura_caminho('are00703','')

     OPEN WINDOW w_are00703 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     DISPLAY p_cod_empresa  TO cod_empresa
     DISPLAY BY NAME mr_tela4.*

     CURRENT WINDOW IS w_are00703
     PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando
     CLOSE WINDOW w_are00703
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0070

 END FUNCTION

#-------------------------------------#
 FUNCTION are0070_consulta_checkout()
#-------------------------------------#
     LET m_caminho = log1300_procura_caminho('are00704','')

     OPEN WINDOW w_are00704 AT 2,2 WITH FORM m_caminho
         ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
     DISPLAY p_cod_empresa  TO cod_empresa
     DISPLAY BY NAME mr_tela5.*
     CALL are0070_exibe_dados5()

     CURRENT WINDOW IS w_are00704
     PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando
     CLOSE WINDOW w_are00704
     CALL log006_exibe_teclas('01', p_versao)
     CURRENT WINDOW IS w_are0070

 END FUNCTION
