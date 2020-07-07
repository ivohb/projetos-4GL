#-----------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX X TRIM                                     #
# OBJETIVO: IMPORTAÇÃO DE ROMANEIO DO TRIM                              #
# DATA....: 24/07/2007                                                  #
# ALTERAÇÕES MOTIVO                                                     #
# 11/11/08 - checar estoque em ambas as empresas, de acordo com a regra #
# 15/05/09 - se o item não tem dimensional,despresar o que o trim manda #
# 17/08/09 - Gravação num_romaneio no campo ped_itens_texto.den_texto_1 #
# 17/08/09 - Gravação num_lacre no campo ped_itens_texto.den_texto_2    #
# 17/08/09 - Gravação qtd_pacotes no campo ped_itens_texto.den_texto_3  #
# 19/08/09 - adquações para impressão da danfe pelo logix padrão        #
# 24/09/09 - Criticar o romaneio se tiver plca de caminhão sem a uf dela#
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_seq_sf             SMALLINT,
          p_ped_char           CHAR(06),
          p_seq_char           CHAR(03),
          p_count              INTEGER,
          p_status             SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ies_cons           SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          p_msg                CHAR(100)
   
   DEFINE p_statusRegistro     LIKE romaneio_885.statusRegistro,
          p_ies_largura        LIKE item_ctr_grade.ies_largura,
          p_num_lote_om        LIKE ordem_montag_mest.num_lote_om,
          p_ies_altura         LIKE item_ctr_grade.ies_altura,
          p_ies_diametro       LIKE item_ctr_grade.ies_diametro,
          p_ies_comprimento    LIKE item_ctr_grade.ies_comprimento,
          p_ies_serie          LIKE item_ctr_grade.reservado_2,
          p_ctr_lote           LIKE item.ies_ctr_lote,
          p_cod_status         LIKE romaneio_885.statusRegistro,
          p_cod_cid_dest       LIKE roma_item_885.codciddest,
          p_cod_compon         LIKE item.cod_item,
          p_cod_tip_carteira   LIKE pedidos.cod_tip_carteira,
          p_num_seq_item       LIKE roma_item_885.numseqitem,
          p_codcarteira        LIKE pedidos.cod_tip_carteira,
          p_numsequencia       LIKE roma_item_885.numsequencia,
          p_num_pedido         LIKE ped_itens.num_pedido, 
          p_qtd_reservada      LIKE estoque_loc_reser.qtd_reservada,
          l_num_lote_om        LIKE ordem_montag_lote.num_lote_om,
          p_den_erro           LIKE roma_erro_885.den_erro,
          p_tipooperacao       LIKE roma_item_885.tipooperacao,
          p_tip_trim           LIKE empresas_885.tip_trim,
          p_numromaneio        LIKE roma_item_885.numromaneio,
          p_numroma_ant        LIKE roma_item_885.numromaneio,
          l_num_om             LIKE ordem_montag_mest.num_om,
          p_numpedido          LIKE roma_item_885.numpedido,
          l_num_lote           LIKE ordem_montag_mest.num_lote_om,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ant        LIKE empresa.cod_empresa,
          p_pct_desc_valor     LIKE desc_nat_oper_885.pct_desc_valor,
          p_pct_desc_qtd       LIKE desc_nat_oper_885.pct_desc_qtd,
          p_pct_desc_oper      LIKE desc_nat_oper_885.pct_desc_oper,
          p_cod_cnd_pgto       LIKE pedidos.cod_cnd_pgto,
          p_numseqitem         LIKE roma_item_885.numseqitem,
          #p_coditem            LIKE roma_item_885.coditem,
          p_qtdpecas           LIKE roma_item_885.qtdpecas,
          p_cod_cliente        LIKE pedidos.cod_cliente,
          p_cli_ant            LIKE pedidos.cod_cliente,
          p_num_sequencia      LIKE romaneio_885.numsequencia,
          p_cod_emp_log        LIKE empresa.cod_empresa,
          p_qtd_saldo          LIKE ped_itens.qtd_pecas_solic,
          p_qtd_estoq          LIKE estoque_lote.qtd_saldo,
          p_qtd_estoq_reser    LIKE estoque_lote.qtd_saldo,
          p_cod_local_estoq    LIKE item.cod_local_estoq,
          p_ies_ctr_estoque    LIKE item.ies_ctr_estoque,
          p_cod_item           LIKE item.cod_item,
          p_coditem            LIKE item.cod_item,
          p_num_docum          LIKE ordens.num_docum,
          p_ies_sit_om         LIKE ordem_montag_mest.ies_sit_om,
          p_ies_sit_pedido     LIKE pedidos.ies_sit_pedido,
          l_cod_tip_carteira   LIKE pedidos.cod_tip_carteira,
          p_num_om             LIKE roma_papel_885.numromaneio,
          p_peso_total         LIKE ordem_montag_item.pes_total_item,
          p_peso_carga         LIKE ordem_montag_item.pes_total_item,
          p_numlote            LIKE roma_item_885.numlote,
          p_largura            LIKE roma_item_885.largura,
          p_diametro           LIKE roma_item_885.diametro,
          p_tubete             LIKE roma_item_885.tubete,
          p_comprimento        LIKE roma_item_885.comprimento,
          p_serie              LIKE est_loc_reser_end.num_serie,
          p_pre_unit           LIKE ped_itens.pre_unit,
          p_pecas_solic        LIKE ped_itens.qtd_pecas_solic,
          p_val_pedido         LIKE frete_peso_885.val_tonelada,
          p_val_tot            LIKE frete_peso_885.val_tonelada,
          p_val_tonelada       LIKE frete_peso_885.val_tonelada,
          p_val_frete          LIKE frete_peso_885.val_tonelada,
          p_val_ger            LIKE frete_peso_885.val_tonelada,
          p_val_fret_ofic      LIKE frete_peso_885.val_tonelada,
          p_val_fret_ger       LIKE frete_peso_885.val_tonelada,
          p_cod_cid_orig       LIKE clientes.cod_cidade,
          p_num_cgc            LIKE empresa.num_cgc,
          p_num_versao         LIKE frete_rota_885.num_versao,
          p_ies_tip_controle   LIKE nat_operacao.ies_tip_controle,
          p_cod_nat_oper       LIKE pedidos.cod_nat_oper,
          p_ies_situa_qtd      LIKE estoque_lote.ies_situa_qtd,
          p_num_trans_origem   LIKE estoque_trans.num_transac,
          p_num_trans_destino  LIKE estoque_trans.num_transac,
          p_num_transac        LIKE estoque_trans.num_transac,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_texto_ped          LIKE ped_itens_texto.den_texto_1,
          p_num_lacre          LIKE ped_itens_texto.den_texto_2,
          p_qtd_pacote         LIKE roma_item_885.qtdpacote,
          p_txt_pacote         LIKE ped_itens_texto.den_texto_3,
          p_cod_grupo_item     LIKE grupo_item.cod_grupo_item,
          l_cod_embal_int      LIKE item_embalagem.cod_embal
           
          
   DEFINE p_tolmais            DECIMAL(10,3),
          p_pct_desc           DECIMAL(5,2),
          p_selecionou         SMALLFLOAT,
          p_tolentmais         DECIMAL(5,2),
          p_faturar            CHAR(01),
          p_coefic             DECIMAL(17,7),
          p_saldo_txt          CHAR(22),
          p_pecas_txt          CHAR(22),
          p_peso_romaneio      DECIMAL(10,3),
          p_peso_romaneiob     DECIMAL(10,3),
          p_peso_ger           DECIMAL(10,3),
          p_peso_ofic          DECIMAL(10,3),
          p_qtd_pecas_solic    INTEGER,
          p_qtd_romanear       DECIMAL(10,0),
          p_qtd_reservar       DECIMAL(10,0),
          p_dat_hor            DATETIME YEAR TO SECOND,
          p_qtd_roma_aux       CHAR(12),
          p_ies_itens_nff      CHAR(01),
          p_gerou_solicit      SMALLINT,
          p_pct_romanear       DECIMAL(5,2),
          p_pct_emp_ger        DECIMAL(5,2),
          p_pct_emp_ofic       DECIMAL(5,2),
          p_qtd_itens          SMALLINT,
          p_criticou           SMALLINT,
          p_hor_atual          CHAR(08),
          p_cod_transp         CHAR(02),
          p_cod_transp_auto    CHAR(02),
          p_num_sf             INTEGER,
          p_num_solicit        INTEGER,
          p_criticou_item      SMALLINT,
          p_qtd_item           SMALLINT,
          p_oper_e_trnsf       CHAR(04),
          p_oper_s_trnsf       CHAR(04),
          p_cod_pacote_bob     CHAR(03),
          p_ies_pacote         CHAR(01),
          l_qtd_volume         DECIMAL(6,0)
          
             
   DEFINE mr_ordem_montag_mest  RECORD LIKE ordem_montag_mest.*,
          mr_ordem_montag_item  RECORD LIKE ordem_montag_item.*,
          mr_ordem_montag_grade RECORD LIKE ordem_montag_grade.*,
          p_fat_solic_ser_comp  RECORD LIKE fat_solic_ser_comp.*,
          p_romaneio_885        RECORD LIKE romaneio_885.*,
          p_roma_item_885       RECORD LIKE roma_item_885.*,
          p_estoque_lote_ender  RECORD LIKE estoque_lote_ender.*,
          p_ped_item_nat        RECORD LIKE ped_item_nat.*

   DEFINE p_nf_solicit          RECORD
          cod_empresa          char(2),
          num_solicit          decimal(4,0),
          dat_refer            DATE,
          cod_via_transporte   decimal(2,0),
          cod_entrega          decimal(4,0),
          cod_mercado          char(2),
          cod_local_embarque   decimal(3,0),
          ies_mod_embarque     decimal(2,0),
          ies_tip_solicit      char(1),
          ies_lotes_geral      char(1),
          cod_tip_carteira     char(2),
          num_lote_om          decimal(6,0),
          num_om               decimal(6,0),
          num_controle         decimal(3,0),
          num_texto_1          decimal(3,0),
          num_texto_2          decimal(3,0),
          num_texto_3          decimal(3,0),
          val_frete            decimal(15,2),
          val_seguro           decimal(15,2),
          val_frete_ex         decimal(15,2),
          val_seguro_ex        decimal(15,2),
          pes_tot_bruto        decimal(13,4),
          ies_situacao         char(1),
          num_sequencia        SMALLINT,
          nom_usuario          char(8),
          cod_transpor         char(15),
          num_placa            char(7),
          num_volume           decimal(6,0),
          cod_embal_1          char(3),
          qtd_embal_1          decimal(6,0),
          cod_embal_2          char(3),
          qtd_embal_2          decimal(4,0),
          cod_embal_3          char(3),
          qtd_embal_3          decimal(4,0),
          cod_embal_4          char(3),
          qtd_embal_4          decimal(4,0),
          cod_embal_5          char(3),
          qtd_embal_5          decimal(4,0),
          cod_cnd_pgto         decimal(3,0),
          pes_tot_liquido      decimal(13,4),
          qtd_dias_acr_dupl    decimal(3,0)
   END RECORD
          

   DEFINE p_roma               RECORD
          NumSequencia         LIKE romaneio_885.NumSequencia,
          CodEmpresa           LIKE romaneio_885.CodEmpresa,
          TipoOperacao         LIKE romaneio_885.TipoOperacao,
          numromaneio          LIKE romaneio_885.numromaneio,
          coderptranspor       LIKE romaneio_885.coderptranspor,
          placaveiculo         LIKE romaneio_885.placaveiculo,
          pesobalanca          LIKE romaneio_885.pesobalanca,
          pesocarregado        LIKE romaneio_885.pesocarregado,
          codtipfrete          LIKE romaneio_885.codtipfrete,
          valfrete             LIKE romaneio_885.valfrete,
          codpercurso          LIKE romaneio_885.codpercurso,
          codveiculo           LIKE romaneio_885.codveiculo,
          codtipcarga          LIKE romaneio_885.codtipcarga,
          codciddest           LIKE romaneio_885.codciddest,
          ufveiculo            CHAR(02)
          
   END RECORD

   DEFINE p_sol                RECORD
          num_om               LIKE ordem_montag_mest.num_om,
          num_pedido           LIKE pedidos.num_pedido,
          cod_acao             CHAR(01)
   END RECORD

   DEFINE p_item_roma          RECORD
          num_sequencia        DECIMAL(6,0),
          cod_item             CHAR(15),
          numlote              CHAR(15),
          largura              INTEGER,
          diametro             INTEGER,
          altura               INTEGER,
          comprimento          INTEGER,
          pes_item             DECIMAL(12,2),
          pes_itemb            DECIMAL(12,2),
          qtd_reservada        DECIMAL(10,3),
          qtd_volumes          INTEGER
   END RECORD

   DEFINE p_romaneios         ARRAY[200] OF RECORD
          num_sequencia       LIKE roma_erro_885.num_sequencia,
          den_erro            LIKE roma_erro_885.den_erro,
          dat_hor             DATE
   END RECORD

   DEFINE pr_om               ARRAY[200] OF RECORD
          num_om              LIKE solicit_fat_885.num_om,
          num_pedido          LIKE solicit_fat_885.num_pedido,
          cod_cliente         LIKE clientes.cod_cliente,
          nom_cliente         LIKE clientes.nom_cliente,
          cod_status          LIKE solicit_fat_885.cod_status,
          cod_acao            CHAR(01)
   END RECORD

  DEFINE lr_fat_solic_mestre	RECORD LIKE fat_solic_mestre.*
  DEFINE lr_fat_solic_fatura	RECORD LIKE fat_solic_fatura.*
  DEFINE lr_fat_solic_embal		RECORD LIKE fat_solic_embal.*
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "POL0619-05.10.43"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0619.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol0619_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0619_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   

	# Eliminando solicitacoes nao faturadas
	DELETE FROM nf_solicit                            
	WHERE nf_solicit.cod_empresa = p_cod_empresa
	AND nf_solicit.nom_usuario = p_user
	AND NOT EXISTS (SELECT 1 FROM fat_solic_mestre
					WHERE empresa = nf_solicit.cod_empresa
					AND usuario = nf_solicit.nom_usuario
					AND solicitacao_fatura = nf_solicit.num_solicit)

    DELETE FROM fat_solic_ser_comp
    WHERE empresa = p_cod_empresa 
    AND usuario = p_user
	AND NOT EXISTS (SELECT 1 FROM fat_solic_mestre
					WHERE empresa = nf_solicit.cod_empresa
					AND usuario = nf_solicit.nom_usuario
					AND solicitacao_fatura = nf_solicit.num_solicit)

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0619") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0619 AT 02,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0619_le_parametros() THEN
      RETURN
   END IF

   DISPLAY p_cod_emp_ofic TO cod_empresa

   LET p_num_sequencia = 0

   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa parametros p/ o processamento "
         IF NOT pol0619_informar() THEN
            LET p_ies_cons = FALSE
            CALL pol0619_limpa_tela()
            ERROR 'OPERAÇÃO CANCELADA !!!'
         ELSE
            ERROR 'PARAMETROS INFORMADOS COM SUCESSO !!!'
         END IF
      COMMAND "Desconsolidar" "Prepara romaneio p/ ser desconsolidade pelo Trim "
         IF p_ies_cons THEN
            CALL log085_transacao("BEGIN")
            IF pol0619_muda_status('3') THEN
               CALL log085_transacao("COMMIT")
               ERROR 'OPERAÇÃO EFETUADA COM SUCESSO !!!'
            ELSE 
               CALL log085_transacao("ROLLBACK")
               ERROR 'OPERAÇÃO CANCELADA !!!'
            END IF
         ELSE
            ERROR 'INFORME PREVIAMENTE OS PARÂMETROS'
         END IF
      COMMAND "Cancelar" "Cancela o romaneio enviado pelo Trim "
         IF p_ies_cons THEN
            CALL log085_transacao("BEGIN")
            IF pol0619_muda_status('4') THEN
               CALL pol0619_limpa_tela()
               CALL log085_transacao("COMMIT")
               ERROR 'OPERAÇÃO EFETUADA COM SUCESSO !!!'
            ELSE 
               CALL log085_transacao("ROLLBACK")
               ERROR 'OPERAÇÃO CANCELADA !!!'
            END IF
         ELSE
            ERROR 'INFORME PREVIAMENTE OS PARÂMETROS'
         END IF
      COMMAND "Reprocessar" "Reprocessa a solicitação de faturamento "
         IF p_ies_cons THEN
            IF p_cod_status = '1' THEN
               CALL log0030_mensagem('Romaneio já processado','exclamation')
            ELSE
               CALL pol0619_processar() RETURNING p_status
               IF p_status THEN
                  ERROR 'PROCESSAMENTO EFETUADO COM SUCESSO!'
               ELSE
                  ERROR 'OPERAÇÃO CANCELADA!'
               END IF
            END IF
         ELSE
            ERROR 'INFORME PREVIAMENTE OS PARÂMETROS'
         END IF
      COMMAND "OM logix" "Odens de montagem geradas no logix "
         CALL pol0619_om_logix()
  #lds COMMAND KEY ("F11") "Sobre" "Informaþ§es sobre a aplicaþÒo (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
 
   CLOSE WINDOW w_pol0619


END FUNCTION

#-----------------------#
 FUNCTION pol0619_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
FUNCTION pol0619_le_parametros()
#-------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
         LET p_cod_emp_ger = p_cod_empresa
      END IF
   END IF

   SELECT cod_pacote_bob
     INTO p_cod_pacote_bob
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','parametros_885')
      RETURN FALSE
   END IF

   SELECT num_cgc
     INTO p_num_cgc
     FROM empresa
    WHERE cod_empresa = p_cod_emp_ofic
    
   IF STATUS <> 0 THEN
      LET p_den_erro = 'ERRO:(',STATUS, ') LENDO EMPRESA'
      RETURN FALSE
   END IF

   SELECT cod_cidade
     INTO p_cod_cid_orig
     FROM clientes
    WHERE num_cgc_cpf = p_num_cgc

   IF STATUS <> 0 THEN
      LET p_den_erro = 'ERRO:(',STATUS, ') LENDO EMPRESA'
      RETURN FALSE
   END IF

   SELECT tip_trim
     INTO p_tip_trim
     FROM empresas_885
    WHERE cod_emp_gerencial = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresas_885')
      RETURN FALSE
   END IF

   SELECT substring(par_vdp_txt,215,2)
     INTO p_cod_transp
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      ERROR 'Não foi possivel ler parâmetro do transportador'
      CALL log003_err_sql('Lendo','par_vdp')
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_cod_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF STATUS <> 0 THEN
      ERROR 'Não foi possivel ler código de transportador autônomo'
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF

   SELECT par_txt 
     INTO p_oper_s_trnsf
     FROM par_sup_pad 
    WHERE cod_empresa   = p_cod_empresa 
      AND cod_parametro = 'oper_sai_trf_grade'

   IF STATUS <> 0 THEN
      ERROR 'Não foi possivel ler oeração de saída transf grade'
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF

   SELECT par_txt 
     INTO p_oper_e_trnsf
     FROM par_sup_pad 
    WHERE cod_empresa   = p_cod_empresa 
      AND cod_parametro = 'oper_ent_trf_grade'

   IF STATUS <> 0 THEN
      ERROR 'Não foi possivel ler oeração de entrada transf grade'
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF 
 
   LET p_cod_empresa = p_cod_emp_ger

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0619_informar()
#--------------------------#

   INITIALIZE p_num_solicit, p_texto_ped TO NULL
   LET INT_FLAG = FALSE
   CALL pol0619_limpa_tela()
   LET p_cod_empresa = p_cod_emp_ger
 
   INPUT p_num_solicit WITHOUT DEFAULTS FROM num_roma

      AFTER FIELD num_roma
         IF p_num_solicit IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD num_roma
         END IF
         
         SELECT MAX(numsequencia)
           INTO p_num_sequencia
           FROM romaneio_885
          WHERE codempresa  = p_cod_empresa
            AND numromaneio = p_num_solicit
            AND statusregistro IN ('0','1','2','3')
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','romaneio_885')
            NEXT FIELD num_roma
         END IF
         
         IF p_num_sequencia IS NULL THEN
            CALL log0030_mensagem('Romaneio Inexistente.','exclamation')
            NEXT FIELD num_roma
         END IF

         SELECT statusregistro,
                numlacre
           INTO p_cod_status,
                p_num_lacre
           FROM romaneio_885
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_sequencia
            
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','romaneio_885')
            NEXT FIELD num_roma
         END IF
        
         LET p_num_lacre = UPSHIFT(p_num_lacre)
         
         #IF p_num_lacre IS NOT NULL THEN
         #  LET p_num_lacre = 'LACRE: ', p_num_lacre CLIPPED
         #END IF
        
         DISPLAY  p_cod_status TO cod_status
         
         IF p_cod_status MATCHES '[02]' THEN
         ELSE
            IF p_cod_status = '1' THEN
               CALL log0030_mensagem('Romaneio já processado','excla')
            ELSE
               IF p_cod_status = '3' THEN
                  CALL log0030_mensagem('Romaneio aguardando desconsolidação do Trim','excla')
               ELSE
                  CALL log0030_mensagem('Romaneio Inexistente.','exclamation')
               END IF
            END IF
            NEXT FIELD num_roma
         END IF

      ON KEY (control-z)
         CALL pol0619_popup('T')

   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF p_cod_status = '2' THEN
      IF NOT pol0619_carrega_criticas() THEN
         RETURN FALSE
      END IF
      CALL pol0619_exibe_criticas()
      DISPLAY 'Reprocessar/Desconsolidar' TO den_oper
      LET p_ies_cons = TRUE
      RETURN TRUE
   END IF

   IF log004_confirm(18,35) THEN
      CALL pol0619_processar() RETURNING p_status
   ELSE
      LET p_status = FALSE
   END IF

   RETURN(p_status)
   
END FUNCTION


#---------------------------#
FUNCTION pol0619_processar()
#---------------------------#

   CALL log085_transacao("BEGIN")
   
   IF NOT pol0619_importa_romaneio() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   CALL pol0619_limpa_tela()
   DISPLAY p_num_solicit TO num_roma

   IF p_statusRegistro = 1 THEN
      DISPLAY 'OM logix' TO den_oper
      LET p_den_erro = 'Procesamento efetuado com sucesso.'
      CALL log0030_mensagem(p_den_erro,'exclamation')
   ELSE
      IF NOT pol0619_carrega_criticas() THEN
         RETURN FALSE
      END IF
      CALL pol0619_exibe_criticas()
      DISPLAY 'Reprocessar/Desconsolidar' TO den_oper
      LET p_ies_cons = TRUE
   END IF
   
   DISPLAY p_statusRegistro TO cod_status
   
   RETURN TRUE

END FUNCTION
  
#----------------------------------#
FUNCTION pol0619_importa_romaneio()
#----------------------------------#

   UPDATE romaneio_885
      SET statusregistro = 'I'
    WHERE codempresa  = p_cod_empresa
      AND numromaneio = p_num_solicit
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','romaneio_885')
      RETURN FALSE
   END IF

   IF NOT pol0619_le_romaneio_885() THEN
      RETURN FALSE
   END IF

   IF NOT pol0619_deleta_erros() THEN
      RETURN FALSE
   END IF

   LET p_criticou = FALSE
   LET p_numsequencia = 0
   LET p_statusRegistro = 1
   LET p_faturar = 'T'

   CALL pol0619_gera_num_sf()
      
   IF NOT pol0619_consiste_roma() THEN
      RETURN FALSE
   END IF

   IF NOT p_criticou THEN
      IF NOT pol0619_insere_solicit() THEN
         CALL log0030_mensagem(p_den_erro,'excla')
         RETURN FALSE
      END IF
   END IF

   IF NOT pol0619_grava_roma() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0619_le_romaneio_885()
#---------------------------------#

   SELECT NumSequencia,
          CodEmpresa,
          TipoOperacao,
          numromaneio,
          coderptranspor,
          placaveiculo,
          pesobalanca,
          pesocarregado,
          codtipfrete,
          valfrete,
          codpercurso,
          codveiculo,
          codtipcarga,
          codciddest,
          ufveiculo
     INTO p_roma.*
     FROM romaneio_885
    WHERE numromaneio  = p_num_solicit
      AND NumSequencia = p_num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','romaneio_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0619_gera_num_sf()
#-----------------------------#
   
   DEFINE p_ind SMALLINT,
          p_txt CHAR(04),
          p_sol CHAR(12),
          p_ctr SMALLINT
   
   INITIALIZE p_txt, p_sol TO NULL
   LET p_ctr = 0
   LET p_sol = p_num_solicit
   
   FOR p_ind = LENGTH(p_sol CLIPPED) TO 1 step -1
       LET p_txt = p_sol[p_ind], p_txt
       LET p_ctr = p_ctr + 1
       IF p_ctr >= 4 THEN
          EXIT FOR
       END IF
   END FOR
   
   LET p_num_sf = p_txt
   LET p_seq_sf = 0

END FUNCTION

#------------------------------#
FUNCTION pol0619_consiste_roma()
#------------------------------#

   IF p_roma.tipooperacao <> '0'  THEN
      LET p_den_erro = 'TIPO DE OPERACAO INVALIDA'
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_roma.placaveiculo IS NOT NULL THEN
      IF p_roma.ufveiculo IS NULL THEN
         LET p_den_erro = 'UF DO VEICULO NA FOI INFORMADA'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_roma.codtipfrete MATCHES '[PRF]' THEN
      IF p_roma.codtipfrete = 'F' THEN
      ELSE
         IF NOT pol0619_checa_transportes() THEN
            RETURN FALSE
         END IF
      END IF
   ELSE
      LET p_den_erro = 'TIPO DE FRETE INVALIDO'
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol0619_conta_item() THEN
      RETURN FALSE
   END IF
   
   IF p_qtd_item = 0 THEN
      LET p_den_erro = 'ROMANEIO SEM OS ITENS CORRESPONDENTES'
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0619_consiste_itens() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0619_conta_item()
#----------------------------#

   SELECT COUNT(numseqpai)
     INTO p_qtd_item
     FROM roma_item_885
    WHERE codempresa  = p_roma.codempresa
      AND numseqpai   = p_roma.numsequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','roma_item_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol0619_checa_transportes()
#------------------------------------#

   IF p_roma.coderptranspor IS NULL THEN
      LET p_den_erro = 'CODIGO DO TRNSPORTADOR ESTA NULO'
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      SELECT cod_cliente
        FROM clientes
       WHERE cod_cliente = p_roma.coderptranspor
         AND (cod_tip_cli = p_cod_transp OR cod_tip_cli = p_cod_transp_auto)
   
      IF STATUS = 100 THEN
         LET p_den_erro = 'TRANSPORTADORA NAO CADASTRADA NO LOGIX'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','clientes')
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF p_roma.codveiculo IS NULL THEN
      LET p_den_erro = 'CODIGO DO VEICULO ESTA NULO'
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_roma.codtipcarga IS NULL THEN
      LET p_den_erro = 'TIPO DE CARGA ESTA NULO'
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_roma.codciddest IS NULL THEN
      LET p_den_erro = 'CIDADE DESTINO ESTA NULO'
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      SELECT cod_cidade
        FROM cidades
       WHERE cod_cidade = p_roma.codciddest
   
      IF STATUS = 100 THEN
         LET p_den_erro = 'CIDADE DESTINO NAO CADASTRADA NO LOGIX'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cidades')
            RETURN FALSE
         END IF
      END IF
   
   END IF

   IF p_roma.valfrete IS NULL OR p_roma.valfrete <= 0 THEN
      LET p_den_erro = 'VALOR DO FRETE ENVIADO INVALIDO'
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

{   IF NOT p_criticou THEN
      IF p_roma.codtipfrete = 'R' THEN
         SELECT val_frete
           FROM frete_rota_885
          WHERE cod_empresa      = p_roma.codempresa
            AND cod_transpor     = p_roma.coderptranspor
            AND cod_veiculo      = p_roma.codveiculo
            AND cod_tip_carga    = p_roma.codtipcarga
            AND cod_cid_orig     = p_cod_cid_orig
            AND cod_cid_dest     = p_roma.codciddest
            AND ies_versao_atual = 'S'
         IF STATUS = 100 THEN 
            LET p_den_erro = 'DADOS DO TRANSPORTE NAO CADASTRADOS NO POL0746'
            IF NOT pol0619_insere_erro() THEN
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','frete_rota_885')
               RETURN FALSE
            END IF
         END IF
      ELSE
         SELECT val_tonelada
           FROM frete_peso_885
          WHERE cod_empresa      = p_cod_empresa
            AND cod_percurso     = p_roma.codpercurso
            AND ies_versao_atual = 'S'
         IF STATUS = 100 THEN 
            LET p_den_erro = 'DADOS DO TRANSPORTE NAO CADASTRADOS NO POL0747'
            IF NOT pol0619_insere_erro() THEN
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','frete_peso_885')
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF   }

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0619_consiste_itens()
#-------------------------------#

   IF p_tip_trim = 'B' THEN

      LET p_tubete = 0
      LET p_diametro = 0
      
      DECLARE cq_dimen CURSOR FOR
       SELECT numsequencia, 
              numpedido,
              numseqitem
         FROM roma_item_885
        WHERE codempresa  = p_cod_empresa
          AND numromaneio = p_num_solicit
          AND numseqpai   = p_num_sequencia
        ORDER BY numpedido, numseqitem
   
      FOREACH cq_dimen INTO 
              p_numsequencia,
              p_num_pedido,
              p_num_seq_item
   
         SELECT largura,
                comprimento
           INTO p_largura,
                p_comprimento
           FROM item_chapa_885        
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_num_pedido
            AND num_sequencia = p_num_seq_item
   
         IF STATUS = 100 THEN
            LET p_largura     = 0
            LET p_comprimento = 0
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('LENDO','ITEM_CHAPA_885')  
               RETURN FALSE
            END IF
         END IF
         
         UPDATE roma_item_885
            SET largura     = p_largura,
                diametro    = p_diametro,
                tubete      = p_tubete,
                comprimento = p_comprimento
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_numsequencia

         IF STATUS <> 0 THEN
            CALL log003_err_sql('ATUALIZANDO','ROMA_ITEM_885')
            RETURN FALSE
         END IF
            
      END FOREACH
      
   END IF

   LET p_criticou_item = FALSE
   
   DECLARE cq_ci CURSOR FOR
    SELECT numsequencia,
           tipooperacao,
           numromaneio,
           numpedido,
           numseqitem,
           coditem,
           numlote,
           largura,
           diametro,
           tubete,
           comprimento,
           qtdpecas,
           codcarteira,
           numsequencia,
           pesoitem,
           pesobrutoitem
      FROM roma_item_885
     WHERE codempresa  = p_cod_empresa
       AND numromaneio = p_num_solicit
       AND numseqpai   = p_num_sequencia
     ORDER BY numpedido, numseqitem
   
   FOREACH cq_ci INTO 
           p_numsequencia,
           p_tipooperacao,
           p_numromaneio,
           p_numpedido,
           p_numseqitem,
           p_coditem,
           p_numlote,
           p_largura,
           p_diametro,
           p_tubete,
           p_comprimento,
           p_qtdpecas,
           p_codcarteira,
           p_numsequencia,
           p_peso_romaneio,
           p_peso_romaneiob

      LET p_criticou_item = FALSE
      
      IF p_numpedido IS NULL OR p_numpedido = 0 THEN
         LET p_den_erro = 'NUM PEDIDO DA SEQ.',p_numsequencia,' INVALIDO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0619_consiste_pedidos() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_tipooperacao IS NULL OR p_tipooperacao <> p_roma.tipooperacao THEN
         LET p_den_erro = 'TIP OPERACAO DA SEQ.',p_numsequencia,' DO ROMANEIO INVALIDA'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
       
      IF p_numromaneio IS NULL OR p_numromaneio = 0 OR 
         p_numromaneio <> p_num_solicit THEN 
         LET p_den_erro = 'NUM ROMANEIO DA SEQ.',p_numsequencia,' DA INVALIDO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_numseqitem IS NULL OR p_numseqitem = 0 THEN
         LET p_den_erro = 'NUMERO DE SEQUENCIA DO PEDIDO INVALIDO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_coditem IS NULL OR p_coditem = 0 THEN
         LET p_den_erro = 'CODIGO DO ITEM INVALIDO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
      CALL pol0619_le_item(p_coditem)
      
      IF STATUS = 100 THEN
         LET p_den_erro = 'ITEM ENVIADO NAO CADASTRADO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF p_ctr_lote = 'S' AND p_numlote IS NULL THEN
         LET p_den_erro = 'NUMERO DO LOTE NAO ENVIADO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF NOT pol0619_le_item_ctr_grade(p_coditem) THEN
         RETURN FALSE
      END IF

      IF p_ies_largura = 'S' THEN 
         IF p_largura IS NULL THEN
            LET p_den_erro = 'DIMENSIONAL LARGURA INVALIDO'
            IF NOT pol0619_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         LET p_largura = 0
      END IF

      IF p_ies_altura = 'S' THEN
         IF p_tubete IS NULL THEN
            LET p_den_erro = 'DIMENSIONAL ALTURA INVALIDO'
            IF NOT pol0619_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         LET p_tubete = 0
      END IF

      IF p_ies_diametro = 'S' THEN
         IF p_diametro IS NULL THEN
            LET p_den_erro = 'DIMENSIONAL DIAMETRO INVALIDO'
            IF NOT pol0619_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         LET p_diametro = 0
      END IF

      IF p_ies_comprimento = 'S' THEN
         IF p_comprimento IS NULL THEN
            LET p_den_erro = 'DIMENSIONAL COMPRIMENTO INVALIDO'
            IF NOT pol0619_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         LET p_comprimento = 0
      END IF

      IF p_qtdpecas IS NULL OR p_qtdpecas = 0 THEN
         LET p_den_erro = 'QUANTIDADE DE PECAS INVALIDA'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_peso_romaneio IS NULL THEN
         LET p_den_erro = 'PESO LIQUIDO DO ITEM ESTA NULO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_peso_romaneiob IS NULL THEN
         LET p_den_erro = 'PESO BRUTO DO ITEM ESTA NULO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
           
      IF NOT p_criticou_item THEN
         IF NOT pol0618_checa_saldo() THEN
            RETURN FALSE
         END IF              
      END IF

      IF p_criticou_item THEN
         UPDATE roma_item_885
            SET statusregistro = '2'
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_numsequencia
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizando','roma_item_885')
            RETURN FALSE
         END IF
      END IF

   END FOREACH

   RETURN TRUE
            
END FUNCTION

#-----------------------------#
FUNCTION pol0618_checa_saldo()
#-----------------------------#

   SELECT pct_desc_valor,
          pct_desc_qtd,
          pct_desc_oper
     INTO p_pct_desc_valor,
          p_pct_desc_qtd,
          p_pct_desc_oper
     FROM desc_nat_oper_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_numpedido
	
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','desc_nat_oper_885:cs')
      RETURN FALSE
   END IF
      
   IF p_pct_desc_qtd > 0 THEN
      LET p_pct_emp_ger  = p_pct_desc_qtd
      LET p_pct_emp_ofic = 100 - p_pct_emp_ger
   ELSE
      IF p_pct_desc_valor > 0 THEN
         LET p_pct_emp_ger  = 100
         LET p_pct_emp_ofic = 100
      ELSE
         LET p_pct_emp_ger  = 0
         LET p_pct_emp_ofic = 100
      END IF
   END IF

   LET p_qtd_romanear = p_qtdpecas * p_pct_emp_ger / 100
   IF p_qtd_romanear > 0 THEN
      IF NOT pol0618_tem_saldo() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_criticou_item THEN
      RETURN TRUE
   END IF
   
   LET p_qtd_romanear = p_qtdpecas * p_pct_emp_ofic / 100

   IF p_qtd_romanear > 0 THEN
      LET p_cod_empresa = p_cod_emp_ofic
      CALL pol0618_tem_saldo() RETURNING p_status
      LET p_cod_empresa = p_cod_emp_ger
      IF NOT p_status THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0618_tem_saldo()
#---------------------------#
  
  DEFINE p_local LIKE item.cod_local_estoq
  
  SELECT cod_local_estoq
    INTO p_local
    FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = p_coditem
 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:local')
      RETURN FALSE
   END IF  

  IF p_numlote IS NULL THEN
      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_coditem
         AND cod_local     = p_local
         AND largura       = p_largura
         AND altura        = p_tubete
         AND diametro      = p_diametro
         AND comprimento   = p_comprimento
         AND ies_situa_qtd IN ('L','E')
         AND num_lote      IS NULL
   ELSE
      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_coditem
         AND cod_local     = p_local
         AND num_lote      = p_numlote
         AND largura       = p_largura
         AND altura        = p_tubete
         AND diametro      = p_diametro
         AND comprimento   = p_comprimento
         AND ies_situa_qtd IN ('L','E')
   END IF   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_lote_ender:1')
      RETURN FALSE
   END IF  

   IF p_qtd_saldo IS NULL THEN 
      LET p_qtd_saldo = 0 
   END IF
   
   SELECT SUM(qtd_reservada)
     INTO p_qtd_reservada
     FROM estoque_loc_reser a,
          est_loc_reser_end b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_coditem
      AND a.cod_local   = p_local
      AND a.num_lote    = p_numlote
      AND a.num_reserva = b.num_reserva
      AND b.largura     = p_largura
      AND b.altura      = p_tubete
      AND b.diametro    = p_diametro
      AND b.comprimento = p_comprimento
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_loc_reser:ts')
      RETURN FALSE
   END IF  

   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF
       
   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   IF p_qtd_saldo = 0 OR p_qtd_saldo < p_qtd_romanear THEN
      LET p_saldo_txt = p_qtd_saldo
      LET p_pecas_txt = p_qtd_romanear
      LET p_saldo_txt = p_saldo_txt CLIPPED, ' X ', p_pecas_txt
      LET p_den_erro = 'ITEM ',p_coditem CLIPPED, ' LOT ',p_numlote CLIPPED, 
          ' SEM SALDO ', p_saldo_txt
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF      

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0619_consiste_pedidos()
#----------------------------------#

      SELECT ies_sit_pedido,
             cod_cliente,
             cod_nat_oper,
             cod_tip_carteira
        INTO p_ies_sit_pedido,
             p_cod_cliente,
             p_cod_nat_oper,
             p_cod_tip_carteira
        FROM pedidos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_numpedido

      IF STATUS = 100 THEN
         LET p_den_erro = 'PEDIDO ',p_numpedido,' NAO CADASTRADO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','pedidos')
            RETURN FALSE
         END IF
      END IF

      IF p_codcarteira IS NULL  OR p_codcarteira = ' ' THEN
          
          UPDATE roma_item_885
             SET codcarteira  = p_cod_tip_carteira
           WHERE numsequencia = p_numsequencia

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Atualizando','roma_item_885')
             RETURN FALSE
          END IF  
      END IF
      
      IF p_ies_sit_pedido = '9' THEN
         LET p_den_erro = 'PEDIDO ',p_numpedido,' ESTA CANCELADO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_ies_sit_pedido = 'B' THEN
         LET p_den_erro = 'PEDIDO ',p_numpedido,' ESTA BLOQUEADO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF p_ies_sit_pedido = 'S' THEN
         LET p_den_erro = 'PEDIDO ',p_numpedido,' ESTA SUSPENSO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_ies_sit_pedido = 'O' THEN
         LET p_den_erro = 'PEDIDO ',p_numpedido,' STATUS:O - FATURAMENTO NAO PERMITIDO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
         
      IF p_ies_sit_pedido <> 'F' AND p_ies_sit_pedido <> 'A' THEN
         #IF NOT pol0619_verifica_credito() THEN
         #   RETURN FALSE
         #END IF
      END IF

      SELECT ies_tip_controle
        INTO p_ies_tip_controle
        FROM nat_operacao
       WHERE cod_nat_oper = p_cod_nat_oper

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nat_operacao')
         RETURN FALSE
      END IF  

      IF p_ies_tip_controle = '8' THEN
         LET p_den_erro = 'PEDIDO ',p_numpedido,'C/ NAT.OPER. VENDA FURURA'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol0619_verifica_credito()
#----------------------------------#

   DEFINE lr_par_vdp           RECORD LIKE par_vdp.*,
          lr_cli_credito       RECORD LIKE cli_credito.*,
          l_valor_cli          DECIMAL(15,2),
          l_parametro          CHAR(1)
          
   SELECT *
     INTO lr_cli_credito.*
     FROM cli_credito
    WHERE cod_cliente = p_cod_cliente
      
   IF sqlca.sqlcode <> 0 THEN
      LET p_den_erro = 'CLIENTE SEM DADOS DE CREDITO'
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   SELECT *
     INTO lr_par_vdp.*
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF lr_par_vdp.par_vdp_txt[367] = 'S' THEN
      IF lr_cli_credito.qtd_dias_atr_dupl > lr_par_vdp.qtd_dias_atr_dupl THEN
         LET p_den_erro = 'CLIENTE COM DUPLICATAS EM ATRASO EXCEDIDO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      IF lr_cli_credito.qtd_dias_atr_med > lr_par_vdp.qtd_dias_atr_med THEN
         LET p_den_erro = 'CLIENTE COM ATRASO MEDIO EXCEDIDO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   SELECT par_ies
     INTO l_parametro
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'ies_limite_credito'
    
   IF l_parametro = 'S' THEN         
      LET l_valor_cli = lr_cli_credito.val_ped_carteira + 
                        lr_cli_credito.val_dup_aberto
      IF l_valor_cli > lr_cli_credito.val_limite_cred THEN
         LET p_den_erro = 'LIMITE DE CREDITO EXCEDIDO'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF lr_cli_credito.dat_val_lmt_cr IS NOT NULL THEN
      IF lr_cli_credito.dat_val_lmt_cr < TODAY THEN
         LET p_den_erro = 'DATA CREDITO EXPIRADA'
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF    
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION pol0619_insere_erro()
#-----------------------------#

   LET p_statusRegistro = '2'
   LET p_criticou      = TRUE
   LET p_criticou_item = TRUE
   LET p_dat_hor = CURRENT YEAR TO SECOND
   
   INSERT INTO roma_erro_885
    VALUES(p_cod_emp_ger,
           p_numsequencia,
           p_num_solicit,
           p_den_erro,
           p_dat_hor)
   
   IF STATUS <> 0 THEN
      LET p_den_erro = 'ERRO:(',STATUS, ') INSERINDO ROMA_ERRO_885'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0619_grava_roma()
#-----------------------------#

   UPDATE romaneio_885
      SET StatusRegistro = p_statusRegistro
    WHERE codempresa   = p_cod_empresa
      AND NumSequencia = p_num_sequencia
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','romaneio_885')
      RETURN FALSE
   END IF
   
   IF p_statusRegistro = 1 THEN
      UPDATE roma_item_885
         SET StatusRegistro = '1'
       WHERE codempresa  = p_cod_empresa
         AND numseqpai   = p_num_sequencia
         AND numromaneio = p_num_solicit

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','romaneio_885')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION


#------------------------------#
FUNCTION pol0619_pega_lote_om()
#------------------------------#

      SELECT MAX(num_lote_om)
        INTO l_num_lote_om
        FROM ordem_montag_lote
       WHERE cod_empresa = p_cod_emp_ofic
      
      IF l_num_lote_om IS NULL THEN
         LET l_num_lote_om = 0
      ELSE
         IF STATUS <> 0 THEN
            LET p_den_erro = 'ERRO:(',STATUS, ') LENDO ORDEM_MONTAG_LOTE'
            RETURN FALSE
         END IF
      END IF

      LET l_num_lote_om = l_num_lote_om + 1
        
      SELECT num_ult_om
        INTO l_num_om
        FROM par_vdp
       WHERE cod_empresa = p_cod_emp_ofic

      IF l_num_om IS NULL THEN
         LET l_num_om = 0
      ELSE
         IF STATUS <> 0 THEN
            LET p_den_erro = 'ERRO:(',STATUS, ') LENDO PAR_VDP'
            RETURN FALSE
         END IF
      END IF

      LET l_num_om = l_num_om + 1
 
      UPDATE par_vdp
         SET num_ult_om = l_num_om
       WHERE cod_empresa = p_cod_emp_ofic

      IF STATUS <> 0 THEN
         LET p_den_erro = 'ERRO:(',STATUS, ') LENDO PAR_VDP'
	       RETURN FALSE
    	END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0619_insere_solicit()
#--------------------------------#

   IF NOT pol0619_cria_om_tmp() THEN
      RETURN FALSE
   END IF
   
   SELECT SUM(pesobrutoitem)
     INTO p_peso_carga
     FROM roma_item_885
    WHERE codempresa  = p_roma.codempresa
      AND numseqpai   = p_roma.numsequencia

   IF STATUS <> 0 THEN
      LET p_den_erro = 'ERRO:(',STATUS, ') SOMANDO ROMA_ITEM_885'
      RETURN FALSE
   END IF
               
   LET p_peso_total = 0
   LET p_gerou_solicit = FALSE
   
   DECLARE cq_pedido CURSOR FOR
    SELECT UNIQUE numpedido
      FROM roma_item_885
     WHERE codempresa  = p_roma.codempresa
       AND numseqpai   = p_roma.numsequencia
    ORDER BY numpedido
    
   IF STATUS <> 0 THEN
      LET p_den_erro = 'ERRO:(',STATUS, ') LENDO ROMA_ITEM_885'
      RETURN FALSE
   END IF

   FOREACH cq_pedido INTO p_num_pedido

      SELECT pct_desc_valor,
             pct_desc_qtd,
             pct_desc_oper
        INTO p_pct_desc_valor,
             p_pct_desc_qtd,
             p_pct_desc_oper
        FROM desc_nat_oper_885
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_num_pedido
	
      IF STATUS <> 0 THEN
         LET p_den_erro = 'ERRO:(',STATUS, ') LENDO DESC_NAT_OPER_885'
         RETURN FALSE
      END IF
      
		  IF p_pct_desc_qtd < 100 THEN
		     IF p_faturar = 'T' THEN
   
    		    SELECT num_pedido
			        FROM pedidos
			       WHERE cod_empresa = p_cod_emp_ofic
			         AND num_pedido  = p_num_pedido
				     
   			    IF STATUS = 0 THEN
			      ELSE
			         IF STATUS = 100 THEN
			            IF NOT pol0619_copia_pedido() THEN
			               RETURN FALSE
			            END IF
			         ELSE
                  LET p_den_erro = 'ERRO:(',STATUS, ') LENDO PEDIDOS'
			            RETURN FALSE
			         END IF
			      END IF
			   END IF
      END IF

      IF p_pct_desc_qtd > 0 THEN
         LET p_pct_emp_ger  = p_pct_desc_qtd
         LET p_pct_emp_ofic = 100 - p_pct_emp_ger
      ELSE
         IF p_pct_desc_valor > 0 THEN
            LET p_pct_emp_ger  = 100
            LET p_pct_emp_ofic = 100
         ELSE
            LET p_pct_emp_ger  = 0
            LET p_pct_emp_ofic = 100
         END IF
      END IF

      IF NOT pol0619_cria_item_roma_tmp() THEN
         RETURN FALSE
      END IF
      
	    DECLARE cq_roma_it CURSOR FOR
	    SELECT numseqitem,
	           coditem,
	           numlote,
	           largura,
	           diametro,
	           tubete,
	           comprimento,
	           pesoitem,
	           pesobrutoitem,
	           qtdpecas,
	           qtdvolumes,
	           tolmais,
	           codcarteira
	      FROM roma_item_885
	     WHERE codempresa  = p_roma.codempresa
	       AND numseqpai   = p_roma.numsequencia
	       AND numpedido   = p_num_pedido
	     ORDER BY numseqitem
	     
	    FOREACH cq_roma_it INTO    
          p_item_roma.num_sequencia,
          p_item_roma.cod_item,
          p_item_roma.numlote,
          p_item_roma.largura,
          p_item_roma.diametro,
          p_item_roma.altura,
          p_item_roma.comprimento,
          p_item_roma.pes_item,
          p_item_roma.pes_itemb,
          p_item_roma.qtd_reservada,
          p_item_roma.qtd_volumes,
          p_tolmais,
          p_cod_tip_carteira

         IF STATUS <> 0 THEN
            LET p_den_erro = 'ERRO:(',STATUS, ') LENDO CQ_ROMA_IT'
            RETURN FALSE
         END IF
         
         IF NOT pol0619_le_item_ctr_grade(p_item_roma.cod_item) THEN
            RETURN FALSE
         END IF

         IF p_ies_largura = 'S' THEN 
         ELSE
            LET p_item_roma.largura = 0
         END IF

         IF p_ies_altura = 'S' THEN 
         ELSE
            LET p_item_roma.altura = 0
         END IF

         IF p_ies_comprimento = 'S' THEN 
         ELSE
            LET p_item_roma.comprimento = 0
         END IF

         IF p_ies_diametro = 'S' THEN 
         ELSE
            LET p_item_roma.diametro = 0
         END IF
                 
         INSERT INTO item_roma_tmp
           VALUES(p_item_roma.*)
           
   	     IF STATUS <> 0 THEN
            LET p_den_erro = 'ERRO:(',STATUS, ') INSERINDO ITEM_ROMA_TMP'
	          RETURN FALSE
	       END IF
	       
	       IF NOT pol0619_trata_tolerancia() THEN
	          RETURN FALSE
	       END IF

         SELECT ies_itens_nff
           INTO p_ies_itens_nff
           FROM tipo_carteira
          WHERE cod_tip_carteira = p_cod_tip_carteira

         IF STATUS <> 0 THEN
            LET p_den_erro = 'ERRO:(',STATUS, ') LENDO TIPO_CARTEIRA'
            RETURN FALSE
         END IF
         
         IF p_ies_itens_nff = 'S' THEN
            IF NOT pol0619_gerar() THEN
               RETURN FALSE
            END IF
            
            DELETE FROM item_roma_tmp
            IF STATUS <> 0 THEN
               LET p_den_erro = 'ERRO:(',STATUS, ') DELETANDO ITEM_ROMA_TMP'
               RETURN FALSE
            END IF
            
         END IF
         
        
      END FOREACH

      SELECT COUNT(cod_item)
        INTO p_qtd_itens
        FROM item_roma_tmp
        
      IF STATUS <> 0 THEN
         LET p_den_erro = 'ERRO:(',STATUS, ') LENDO ITEM_ROMA_TMP:COUNT'
	       RETURN FALSE
	    END IF
        
      IF p_qtd_itens > 0 THEN
         IF NOT pol0619_gerar() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
  
   IF p_roma.codtipfrete <> 'F' THEN
      SELECT COUNT(num_om)
        INTO p_count
        FROM om_tmp_885
     
      IF p_count > 0 THEN 
         IF p_faturar = 'T' THEN
            IF NOT pol0619_grava_frete_885() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF
   
   RETURN TRUE
  
END FUNCTION

#-----------------------# 
FUNCTION pol0619_gerar()
#-----------------------# 
         
   LET p_pct_romanear = p_pct_emp_ger

   IF p_faturar = 'T' THEN
      IF NOT pol0619_pega_lote_om() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_pct_romanear > 0 THEN
      IF NOT pol0619_gera_roma() THEN
         RETURN FALSE
      END IF
   END IF
        
   IF p_pct_emp_ofic > 0 THEN
      LET p_pct_romanear = p_pct_emp_ofic
      LET p_cod_empresa  = p_cod_emp_ofic
      IF NOT pol0619_gera_roma() THEN
         RETURN FALSE
      END IF
      LET p_cod_empresa  = p_cod_emp_ger
   END IF
  
   RETURN TRUE
   
END FUNCTION
#----------------------------------#
FUNCTION pol0619_trata_tolerancia()
#----------------------------------#

   DEFINE p_cod_emp_atu LIKE empresa.cod_empresa,
          p_giro        SMALLINT
          
   LET p_cod_emp_atu = p_cod_emp_ger
   LET p_giro = 1
   
   WHILE p_giro <= 2
      
      SELECT parametro_val
        FROM ped_info_compl
       WHERE empresa = p_cod_emp_atu
         AND pedido  = p_numpedido
         AND campo   = 'pct_tolerancia_maximo'

      IF STATUS = 100 THEN
         INSERT INTO ped_info_compl
            VALUES(p_cod_emp_atu,
                   p_numpedido,
                   'pct_tolerancia_maximo',
                   NULL,
                   NULL,
                   p_tolmais,
                   NULL,
                   NULL)

	       IF STATUS <> 0 THEN
            LET p_den_erro = 'ERRO:(',STATUS, ') INSERINDO PED_INFO_COMPL'
	          RETURN FALSE
	       END IF
      ELSE
         UPDATE ped_info_compl
            SET parametro_val = p_tolmais
          WHERE empresa = p_cod_emp_atu
            AND pedido  = p_numpedido
            AND campo   = 'pct_tolerancia_maximo'

	       IF STATUS <> 0 THEN
            LET p_den_erro = 'ERRO:(',STATUS, ') AUTALIZANDO PED_INFO_COMPL'
	          RETURN FALSE
	       END IF

      END IF
      
      LET p_cod_emp_atu = p_cod_emp_ofic
      LET p_giro = p_giro + 1
      
   END WHILE

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0619_gera_roma()
#---------------------------#

   DEFINE l_peso_unit         LIKE item.pes_unit,
          l_qtd_padr_embal    LIKE item_embalagem.qtd_padr_embal,
          l_cod_embal_matriz  LIKE embalagem.cod_embal_matriz,
          p_num_lote          LIKE estoque_lote.num_lote,
          p_qtd_saldo         LIKE estoque_lote.qtd_saldo,
          p_qtd_reser         LIKE estoque_lote.qtd_saldo,
          p_qtd_a_reser       LIKE estoque_lote.qtd_saldo,
          p_qtd_ja_reser      LIKE estoque_lote.qtd_saldo,
          p_num_seq           LIKE ped_itens.num_sequencia,
          l_num_reserva       INTEGER,
          l_ind               SMALLINT,
          l_qtd_vol           CHAR(10)

   LET p_peso_romaneio  = 0     
   LET p_peso_romaneiob = 0     

   SELECT cod_cliente,
          cod_tip_carteira,
          cod_cnd_pgto
     INTO p_cod_cliente,
          l_cod_tip_carteira,
          p_cod_cnd_pgto
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_num_pedido

   IF SQLCA.SQLCODE <> 0 THEN
      LET p_den_erro = 'ERRO:(',STATUS, ') LENDO PEDIDOS'
      RETURN FALSE
   END IF

   IF p_faturar = 'P' THEN
      SELECT num_om,
             num_lote_om,
             val_frete,
             val_ger
        INTO l_num_om,
             l_num_lote_om,
             p_val_fret_ofic,
             p_val_fret_ger
        FROM solicit_fat_885
       WHERE cod_empresa = p_cod_empresa
         AND num_solicit = p_num_solicit
         AND num_pedido  = p_num_pedido
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','solicit_fat_885')
         RETURN
      END IF

      UPDATE solicit_fat_885
         SET cod_status = 'N'
       WHERE cod_empresa = p_cod_empresa
         AND num_solicit = p_num_solicit
         AND num_pedido  = p_num_pedido

      IF SQLCA.SQLCODE <> 0 THEN
          CALL log003_err_sql('Atualizando','solicit_fat_885')
          RETURN FALSE
      END IF

   END IF
   
   INSERT INTO ordem_montag_lote 
	  VALUES(p_cod_empresa,
	         l_num_lote_om,
	         'N',
	          0,
	          getdate(),
	          0,
	          l_cod_tip_carteira,
	          NULL,
	          0,
	          0,
	          0)
	
	  IF SQLCA.SQLCODE <> 0 THEN
       LET p_den_erro = 'ERRO:(',STATUS, ') INSERINDO ORDEM_MONTAG_LOTE'
       RETURN FALSE
	  END IF

   DECLARE cq_tmp CURSOR FOR
    SELECT *
      FROM item_roma_tmp
   
   FOREACH cq_tmp INTO p_item_roma.*

      CALL pol0619_le_item(p_item_roma.cod_item) 
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item')
         RETURN FALSE
      END IF

      IF p_ctr_lote = 'S' THEN
         LET p_num_lote = p_item_roma.numlote
      ELSE
         LET p_num_lote = NULL
      END IF

      IF p_num_lote IS NOT NULL THEN
         SELECT *
           INTO p_estoque_lote_ender.*
           FROM estoque_lote_ender
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_item_roma.cod_item
            AND cod_local   = p_cod_local_estoq
            AND num_lote    = p_num_lote
            AND largura     = p_item_roma.largura
            AND altura      = p_item_roma.altura
            AND diametro    = p_item_roma.diametro
            AND comprimento = p_item_roma.comprimento
            AND ies_situa_qtd IN ('L','E')
            AND qtd_saldo   > 0
      ELSE
         SELECT *
           INTO p_estoque_lote_ender.*
           FROM estoque_lote_ender
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_item_roma.cod_item
            AND cod_local   = p_cod_local_estoq
            AND num_lote      IS NULL
            AND largura     = p_item_roma.largura
            AND altura      = p_item_roma.altura
            AND diametro    = p_item_roma.diametro
            AND comprimento = p_item_roma.comprimento
            AND ies_situa_qtd IN ('L','E')
            AND qtd_saldo   > 0
      END IF

     IF STATUS <> 0 THEN
         ERROR p_item_roma.cod_item
         CALL log003_err_sql('Lendo','estoque_lote_ender:2')
         RETURN FALSE
      END IF

      IF p_estoque_lote_ender.ies_situa_qtd = 'E' THEN
         LET p_cod_emp_ant = p_cod_empresa
         IF NOT pol0619_transf_situa() THEN
            RETURN FALSE
         END IF
         IF p_cod_empresa = p_cod_emp_ofic THEN
            LET p_cod_empresa = p_cod_emp_ger
         ELSE
            LET p_cod_empresa = p_cod_emp_ofic
         END IF
         IF NOT pol0619_transf_situa() THEN
            RETURN FALSE
         END IF
         LET p_cod_empresa = p_cod_emp_ant
      END IF
      
      LET p_qtd_reservar = p_item_roma.qtd_reservada * p_pct_romanear / 100
      
      INSERT INTO estoque_loc_reser(
             cod_empresa,
             cod_item,
             cod_local,
             qtd_reservada,
             num_lote,
             ies_origem,
             num_docum,
             num_referencia,
             ies_situacao,
             dat_prev_baixa,
             num_conta_deb,
             cod_uni_funcio,
             nom_solicitante,
             dat_solicitacao,
             nom_aprovante,
             dat_aprovacao,
             qtd_atendida,
             dat_ult_atualiz)
           VALUES(p_cod_empresa,
                  p_item_roma.cod_item,
                  p_cod_local_estoq,
                  p_qtd_reservar,
                  p_num_lote,
                  'P',
                  p_num_pedido,
                  NULL,
                  'N',
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  getdate(),
                  NULL,
                  NULL,
                  0,
                  NULL)
   
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_den_erro = 'ERRO:(',STATUS, ') INSERINDO ESTOQUE_LOC_RESER'
         RETURN FALSE
      END IF

      LET l_num_reserva = SQLCA.SQLERRD[2]
      
      INSERT INTO est_loc_reser_end (
						cod_empresa,
						num_reserva,
						endereco,
						num_volume,
						cod_grade_1,
						cod_grade_2,
						cod_grade_3,
						cod_grade_4,
						cod_grade_5,
						dat_hor_producao,
						num_ped_ven,
						num_seq_ped_ven,
						dat_hor_validade,
						num_peca,
						num_serie,
						comprimento,
						largura,
						altura,
						diametro,
						dat_hor_reserv_1,
						dat_hor_reserv_2,
						dat_hor_reserv_3,
						qtd_reserv_1,
						qtd_reserv_2,
						qtd_reserv_3,
						num_reserv_1,
						num_reserv_2,
						num_reserv_3,
						tex_reservado)
            VALUES(p_cod_empresa,
                   l_num_reserva,
                   p_estoque_lote_ender.endereco,
                   p_estoque_lote_ender.num_volume,
                   p_estoque_lote_ender.cod_grade_1,
                   p_estoque_lote_ender.cod_grade_2,
                   p_estoque_lote_ender.cod_grade_3,
                   p_estoque_lote_ender.cod_grade_4,
                   p_estoque_lote_ender.cod_grade_5,
                   p_estoque_lote_ender.dat_hor_producao,
                   p_estoque_lote_ender.num_ped_ven,
                   p_estoque_lote_ender.num_seq_ped_ven,
                   p_estoque_lote_ender.dat_hor_validade,
                   p_estoque_lote_ender.num_peca,
                   p_estoque_lote_ender.num_serie,
                   p_estoque_lote_ender.comprimento,
                   p_estoque_lote_ender.largura,
                   p_estoque_lote_ender.altura,
                   p_estoque_lote_ender.diametro,
                   p_estoque_lote_ender.dat_hor_reserv_1,
                   p_estoque_lote_ender.dat_hor_reserv_2,
                   p_estoque_lote_ender.dat_hor_reserv_3,
                   p_estoque_lote_ender.qtd_reserv_1,
                   p_estoque_lote_ender.qtd_reserv_2,
                   p_estoque_lote_ender.qtd_reserv_3,
                   p_estoque_lote_ender.num_reserv_1,
                   p_estoque_lote_ender.num_reserv_2,
                   p_estoque_lote_ender.num_reserv_3,
                   p_estoque_lote_ender.tex_reservado)
                   
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_den_erro = 'ERRO:(',STATUS, ') INSERINDO EST_LOC_RESER_END'
         RETURN FALSE
      END IF

      INSERT INTO ordem_montag_grade
            VALUES(p_cod_empresa,
                   l_num_om,
                   p_num_pedido,
                   p_item_roma.num_sequencia,
                   p_item_roma.cod_item,
                   p_qtd_reservar,
                   l_num_reserva,
                   p_estoque_lote_ender.cod_grade_1,
                   p_estoque_lote_ender.cod_grade_2,
                   p_estoque_lote_ender.cod_grade_3,
                   p_estoque_lote_ender.cod_grade_4,
                   p_estoque_lote_ender.cod_grade_5,
                   NULL)
          
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_den_erro = 'ERRO:(',STATUS, ') INSERINDO ORDEM_MONTAG_GRADE'
         RETURN FALSE
      END IF

   END FOREACH

   LET l_qtd_volume = 0
   LET p_val_pedido = 0

   DECLARE cq_montag_item CURSOR FOR
    SELECT num_sequencia,
           cod_item,
           SUM(qtd_reservada),
           SUM(qtd_volumes),
           SUM(pes_item),
           SUM(pes_itemb)
      FROM item_roma_tmp
     GROUP BY num_sequencia, cod_item
      
   FOREACH cq_montag_item INTO
           p_item_roma.num_sequencia,
           p_item_roma.cod_item,
           p_item_roma.qtd_reservada,
           p_item_roma.qtd_volumes,
           p_item_roma.pes_item,
           p_item_roma.pes_itemb

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Lendo','item_roma_tmp')
         RETURN FALSE
      END IF
           
      SELECT DISTINCT iespacote
        INTO p_ies_pacote
        FROM roma_item_885
       WHERE codempresa = p_cod_emp_ger
      	 AND numseqpai  = p_roma.numsequencia
	       AND numpedido  = p_num_pedido
	       AND numseqitem = p_item_roma.num_sequencia
	       AND coditem    = p_item_roma.cod_item
	       
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Lendo','roma_item_885:iespacote')
         RETURN FALSE
      END IF

      IF p_ies_pacote IS NULL THEN
         LET p_ies_pacote = 'N'
      END IF
      
      IF p_ies_pacote = 'S' THEN
         LET l_cod_embal_int = p_cod_pacote_bob
      ELSE
         INITIALIZE l_cod_embal_matriz to NULL

         SELECT a.qtd_padr_embal, 
                a.cod_embal, 
                b.cod_embal_matriz
           INTO l_qtd_padr_embal, 
                l_cod_embal_int, 
                l_cod_embal_matriz
           FROM item_embalagem a, 
                embalagem b
          WHERE a.cod_empresa   = p_cod_empresa
            AND a.cod_item      = p_item_roma.cod_item
            AND a.cod_embal     = b.cod_embal
            AND a.ies_tip_embal IN ('I','N')

         IF SQLCA.SQLCODE = 100 THEN   
            LET l_qtd_padr_embal = 0
            LET l_cod_embal_int  = 0
         ELSE
            IF SQLCA.SQLCODE = 0 THEN   
               IF l_cod_embal_matriz IS NOT NULL THEN
                  LET l_cod_embal_int = l_cod_embal_matriz
               END IF 	     
            ELSE
               LET p_den_erro = 'ERRO:(',STATUS, ') LENDO ITEM_EMBALAGEM/EMBALAGEM'
               RETURN FALSE
            END IF
         END IF
      END IF
      
      LET p_qtd_romanear = p_item_roma.qtd_reservada * p_pct_romanear / 100
      
      IF p_pct_desc_qtd > 0 THEN
         LET p_peso_ger  = p_item_roma.pes_itemb * p_pct_desc_qtd / 100
         LET p_peso_ofic = p_item_roma.pes_itemb - p_peso_ger
         IF p_cod_empresa = p_cod_emp_ger THEN
            LET mr_ordem_montag_item.pes_total_item = p_peso_ger
         ELSE
            LET mr_ordem_montag_item.pes_total_item = p_peso_ofic
            LET p_peso_romaneiob = p_peso_romaneiob + p_peso_ofic
         END IF
      ELSE
         LET mr_ordem_montag_item.pes_total_item = p_item_roma.pes_itemb
         LET p_peso_romaneiob = p_peso_romaneiob + p_item_roma.pes_itemb
      END IF
      
      LET mr_ordem_montag_item.cod_empresa     = p_cod_empresa
      LET mr_ordem_montag_item.num_om          = l_num_om
      LET mr_ordem_montag_item.num_pedido      = p_num_pedido
      LET mr_ordem_montag_item.num_sequencia   = p_item_roma.num_sequencia 
      LET mr_ordem_montag_item.cod_item        = p_item_roma.cod_item
      LET mr_ordem_montag_item.qtd_reservada   = p_qtd_romanear
      LET mr_ordem_montag_item.ies_bonificacao = 'N'

      INITIALIZE p_cod_grupo_item TO NULL
      
      SELECT grupo_item.cod_grupo_item
        INTO p_cod_grupo_item
        FROM item_vdp
        LEFT OUTER join grupo_item ON
             item_vdp.cod_grupo_item =  grupo_item.cod_grupo_item
       WHERE item_vdp.cod_empresa    = p_cod_empresa
         AND item_vdp.cod_item       = mr_ordem_montag_item.cod_item 

      IF STATUS = 100 THEN
         LET p_den_erro = 'ITEM ',mr_ordem_montag_item.cod_item CLIPPED, 
                          ' NÃO É UM ITEM VDP'
         RETURN FALSE
      END IF

      IF p_cod_grupo_item IS NULL THEN
         LET p_den_erro = 'ERRO:(',STATUS, ') LENDO ITEM_VDP E GRUPO_ITEM'
         RETURN FALSE
      END IF
            
      IF p_cod_grupo_item = '04' THEN
         LET mr_ordem_montag_item.qtd_volume_item = p_item_roma.qtd_volumes
      ELSE
         IF p_qtd_romanear < 100000 THEN
            LET mr_ordem_montag_item.qtd_volume_item = p_qtd_romanear
         ELSE
            LET mr_ordem_montag_item.qtd_volume_item = 0
         END IF
      END IF

      INSERT INTO ordem_montag_item VALUES (mr_ordem_montag_item.*)

      IF SQLCA.SQLCODE <> 0 THEN
         LET p_den_erro = 'ERRO:(',STATUS, ') INSERINDO ORDEM_MONTAG_ITEM'
         RETURN FALSE
      END IF

      
      SELECT SUM(qtdpacote)
        INTO p_qtd_pacote
        FROM roma_item_885
       WHERE codempresa  = p_roma.codempresa
         AND numseqpai   = p_roma.numsequencia
         AND numpedido   = p_num_pedido
         AND numseqitem  = mr_ordem_montag_item.num_sequencia
      
      LET p_txt_pacote = NULL
   
      IF p_qtd_pacote IS NOT NULL THEN
         IF p_qtd_pacote > 0 THEN
            LET p_txt_pacote = p_qtd_pacote
            LET p_txt_pacote = 'PACOTES: ', p_txt_pacote CLIPPED
         END IF
      END IF   
      
      SELECT cod_empresa
        FROM ped_itens_texto
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_sequencia = mr_ordem_montag_item.num_sequencia
         
      IF STATUS = 0 THEN
         UPDATE ped_itens_texto
            SET den_texto_3 = p_txt_pacote
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_num_pedido
            AND num_sequencia = mr_ordem_montag_item.num_sequencia
      ELSE
         INSERT INTO ped_itens_texto(
            cod_empresa,
            num_pedido,
            num_sequencia,
            den_texto_3)
          VALUES(p_cod_empresa,
                 p_num_pedido,
                 mr_ordem_montag_item.num_sequencia,
                 p_txt_pacote)
      END IF
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Gravando','ped_itens_texto')
         RETURN FALSE
      END IF
            
      LET l_qtd_volume = l_qtd_volume + mr_ordem_montag_item.qtd_volume_item
      
      UPDATE ped_itens 
         SET qtd_pecas_romaneio = qtd_pecas_romaneio + mr_ordem_montag_item.qtd_reservada
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = mr_ordem_montag_item.num_pedido
         AND num_sequencia = mr_ordem_montag_item.num_sequencia
        
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_den_erro = 'ERRO:(',STATUS, ') ATUALIZANADO PED_ITENS'
         RETURN FALSE
      END IF

      SELECT pre_unit
        INTO p_pre_unit
        FROM ped_itens
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = mr_ordem_montag_item.num_pedido
         AND num_sequencia = mr_ordem_montag_item.num_sequencia

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Lendo','ped_itens')
         RETURN FALSE
      END IF
      
      LET p_val_pedido = p_val_pedido +
          mr_ordem_montag_item.qtd_reservada * p_pre_unit
      
      INSERT INTO ordem_montag_embal 
         VALUES(p_cod_empresa,
                mr_ordem_montag_item.num_om,
                mr_ordem_montag_item.num_sequencia,	
                mr_ordem_montag_item.cod_item,
                l_cod_embal_int,
                mr_ordem_montag_item.qtd_volume_item,
                0,
                0,
                'T',
                1,
                1,
                mr_ordem_montag_item.qtd_reservada)

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Inserindo','ordem_montag_embal')
         RETURN FALSE
      END IF
      
      UPDATE estoque
         SET qtd_reservada = 
             qtd_reservada +  mr_ordem_montag_item.qtd_reservada
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = mr_ordem_montag_item.cod_item
 
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Atualizando','estoque')
         RETURN FALSE
      END IF

   END FOREACH
   
	 LET mr_ordem_montag_mest.cod_empresa   = p_cod_empresa
	 LET mr_ordem_montag_mest.num_om        = l_num_om
	 LET mr_ordem_montag_mest.num_lote_om   = l_num_lote_om
	 LET mr_ordem_montag_mest.cod_transpor  = p_roma.coderptranspor
	 LET mr_ordem_montag_mest.qtd_volume_om = l_qtd_volume
	 LET mr_ordem_montag_mest.dat_emis      = TODAY 
   LET mr_ordem_montag_mest.ies_sit_om    = 'N'
	
	 INSERT INTO ordem_montag_mest VALUES (mr_ordem_montag_mest.*)
	
	 IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Inserindo','ordem_montag_mest')
	    RETURN FALSE
	 END IF
	  
	 INSERT INTO om_list 
	     VALUES (p_cod_empresa,
	             mr_ordem_montag_mest.num_om,
	             mr_ordem_montag_item.num_pedido,
	             getdate(),
	             p_user)
	
	 IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Inserindo','om_list')
	    RETURN FALSE
	 END IF
	 
	 LET p_num_pedido = mr_ordem_montag_item.num_pedido

   INSERT INTO om_tmp_885
    VALUES(p_cod_empresa,mr_ordem_montag_mest.num_om, p_val_pedido)

	 IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Inserindo','om_tmp_885')
	    RETURN FALSE
	 END IF

   #IF p_texto_ped IS NULL THEN
      IF NOT pol0619_grava_texto() THEN
         RETURN FALSE
      END IF
   #END IF
   
   IF p_faturar = 'T' THEN
      SELECT COUNT(num_om)
        INTO p_count 
        FROM solicit_fat_885
       WHERE cod_empresa = p_cod_emp_ofic
         AND num_solicit = p_num_solicit
         AND num_om      = l_num_om

     	IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Lendo','solicit_fat_885')
	       RETURN FALSE
	    END IF
      
      IF p_count = 0 THEN
         DECLARE cq_cid CURSOR FOR
          SELECT codciddest
            FROM roma_item_885
           WHERE codempresa  = p_cod_emp_ger
             AND numseqpai   = p_num_sequencia
             AND numromaneio = p_num_solicit
             AND numpedido   = p_num_pedido
       
         FOREACH cq_cid INTO p_cod_cid_dest
        	   IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql('Lendo','codciddest')
	             RETURN FALSE
	          END IF
            EXIT FOREACH
         END FOREACH
      
         INSERT INTO solicit_fat_885
          VALUES(p_cod_emp_ofic, 
                 p_num_solicit, 
                 l_num_om, 
                 getdate(), 
                 'N',
                 p_num_pedido,
                 0,
                 l_num_lote_om,
                 p_cod_cid_dest,
                 0)

      	 IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql('Inserindo','solicit_fat_885')
            RETURN FALSE
      	 END IF
   	  END IF
   END IF
   
   LET p_gerou_solicit = TRUE

   IF p_cod_empresa = p_cod_emp_ger THEN
      IF p_pct_desc_qtd < 100 THEN
         RETURN TRUE
      END IF
   END IF

   IF NOT pol0619_gera_solicit() THEN
      RETURN FALSE
   END IF
	
	 IF p_faturar = 'P' THEN
	    LET p_num_om = l_num_om
   	  IF NOT pol0619_insere_frete_roma() THEN
	       RETURN FALSE
	    END IF
	 END IF
	
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0619_grava_texto()
#-----------------------------#

   LET p_texto_ped = p_num_solicit
   LET p_texto_ped = 'LAUDO: ', p_texto_ped CLIPPED
   
   SELECT cod_empresa
     FROM ped_itens_texto
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_num_pedido
      AND num_sequencia = 0
         
   IF STATUS = 0 THEN
      UPDATE ped_itens_texto
         SET den_texto_1 = p_texto_ped,
             den_texto_2 = p_num_lacre
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_sequencia = 0
   ELSE
      INSERT INTO ped_itens_texto(
         cod_empresa,
         num_pedido,
         num_sequencia,
         den_texto_1,
         den_texto_2)
       VALUES(p_cod_empresa,
              p_num_pedido,
              0,
              p_texto_ped,
              p_num_lacre)
   END IF
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Gravando','ped_itens_texto')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------------------#
FUNCTION pol0619_le_item_ctr_grade(p_cod_item)
#--------------------------------------------#

   DEFINE p_cod_item   LIKE item.cod_item,
          p_achou      SMALLINT

   LET p_achou = FALSE
   
   DECLARE cq_ctr CURSOR FOR
    SELECT ies_largura,
           ies_altura,
           ies_diametro,
           ies_comprimento,
           reservado_2
      FROM item_ctr_grade
     WHERE cod_empresa   = p_cod_emp_ofic
       AND cod_item      = p_cod_item

   FOREACH cq_ctr INTO
           p_ies_largura,
           p_ies_altura,
           p_ies_diametro,
           p_ies_comprimento,
           p_ies_serie
   
      IF STATUS <> 0 THEN
        CALL log003_err_sql('Lendo','item_ctr_grade')
        RETURN FALSE
      END IF

      LET p_achou = TRUE
      EXIT FOREACH

   END FOREACH
   
   IF NOT p_achou THEN
      LET p_ies_largura     = 'N'
      LET p_ies_altura      = 'N'
      LET p_ies_diametro    = 'N'
      LET p_ies_comprimento = 'N'
      LET p_ies_serie       = 'N'
   ELSE
      IF STATUS <> 0 THEN
        CALL log003_err_sql('Lendo','item_ctr_grade')
        RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0619_le_item(p_cod_item)
#----------------------------------#

   DEFINE p_cod_item LIKE item.cod_item

   SELECT ies_ctr_lote,
          ies_ctr_estoque,
          cod_local_estoq
     INTO p_ctr_lote,
          p_ies_ctr_estoque,
          p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
     
END FUNCTION

#------------------------------#
FUNCTION pol0619_gera_solicit()
#------------------------------#

  INITIALIZE p_nf_solicit TO NULL
  
  LET p_seq_sf = p_seq_sf + 1
  LET p_nf_solicit.cod_empresa        = p_cod_empresa
  LET p_nf_solicit.num_solicit        = p_num_sf
  LET p_nf_solicit.dat_refer          = TODAY
  LET p_nf_solicit.cod_via_transporte = 1
  LET p_nf_solicit.cod_entrega        = 1
  LET p_nf_solicit.ies_tip_solicit    = 'R'
  LET p_nf_solicit.ies_lotes_geral    = 'N'
  LET p_nf_solicit.cod_tip_carteira   = l_cod_tip_carteira
  LET p_nf_solicit.num_lote_om        = l_num_lote_om
  LET p_nf_solicit.num_om             = l_num_om
  LET p_nf_solicit.val_frete          = 0
  LET p_nf_solicit.val_seguro         = 0
  LET p_nf_solicit.val_frete_ex       = 0
  LET p_nf_solicit.val_seguro_ex      = 0
  LET p_nf_solicit.pes_tot_bruto      = p_peso_romaneiob
  LET p_nf_solicit.ies_situacao       = 'C'
  LET p_nf_solicit.num_sequencia      = p_seq_sf
  LET p_nf_solicit.nom_usuario        = p_user
  LET p_nf_solicit.cod_transpor       = p_roma.coderptranspor
  LET p_nf_solicit.num_placa          = p_roma.placaveiculo
  LET p_nf_solicit.num_volume         = NULL
  LET p_nf_solicit.cod_cnd_pgto       = p_cod_cnd_pgto
  LET p_nf_solicit.pes_tot_liquido    = p_peso_romaneiob 
  LET p_nf_solicit.cod_embal_1        = l_cod_embal_int
  LET p_nf_solicit.qtd_embal_1        = l_qtd_volume

  LET p_peso_total = p_peso_total + p_peso_romaneiob
  
  INSERT INTO nf_solicit_885
   VALUES(p_nf_solicit.cod_empresa,
          p_num_solicit,
          p_nf_solicit.num_solicit,
          p_nf_solicit.dat_refer,
          p_nf_solicit.cod_via_transporte,
          p_nf_solicit.cod_entrega,
          p_nf_solicit.ies_tip_solicit,
          p_nf_solicit.ies_lotes_geral,
          p_nf_solicit.cod_tip_carteira,
          p_nf_solicit.num_lote_om,
          p_nf_solicit.num_om,
          p_nf_solicit.val_frete,
          p_nf_solicit.val_seguro,
          p_nf_solicit.val_frete_ex,
          p_nf_solicit.val_seguro_ex,
          p_nf_solicit.pes_tot_bruto,
          p_nf_solicit.ies_situacao,
          p_nf_solicit.num_sequencia,
          p_nf_solicit.nom_usuario,
          p_nf_solicit.cod_transpor,
          p_nf_solicit.num_placa,
          p_nf_solicit.num_volume,
          p_nf_solicit.cod_cnd_pgto,
          p_nf_solicit.pes_tot_liquido,
          p_nf_solicit.cod_embal_1,
          p_nf_solicit.qtd_embal_1)

	IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('Inserindo','nf_solicit_885')
     RETURN FALSE
	END IF
  
  IF NOT pol0619_grava_nf_solicit() THEN
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0619_grava_nf_solicit()
#---------------------------------#

  LET p_nf_solicit.num_controle = p_nf_solicit.num_sequencia

  IF p_nf_solicit.qtd_embal_1 IS NULL THEN
     SELECT SUM(qtd_volume_item)
       INTO p_nf_solicit.qtd_embal_1
       FROM ordem_montag_item
      WHERE cod_empresa = p_cod_empresa
        AND num_om = p_nf_solicit.num_om
     IF p_nf_solicit.qtd_embal_1 IS NULL THEN    
        LET p_nf_solicit.qtd_embal_1 = 0
     END IF    
  END IF
  
  INSERT INTO nf_solicit
     VALUES(p_nf_solicit.*)

	IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('Inserindo','nf_solicit')
     RETURN FALSE
	END IF

  LET p_fat_solic_ser_comp.empresa            = p_nf_solicit.cod_empresa
  LET p_fat_solic_ser_comp.solicitacao_fatura = p_nf_solicit.num_solicit
  LET p_fat_solic_ser_comp.ord_montag         = p_nf_solicit.num_om
  LET p_fat_solic_ser_comp.serie_nota_fiscal  = '1'
  LET p_fat_solic_ser_comp.seq_solicitacao    = p_nf_solicit.num_sequencia
  LET p_fat_solic_ser_comp.usuario            = p_nf_solicit.nom_usuario
  LET p_fat_solic_ser_comp.campo              = 'CUBAGEM NOTA FISCAL'

  INSERT INTO fat_solic_ser_comp
     VALUES(p_fat_solic_ser_comp.*)

	IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('Inserindo','fat_solic_ser_comp:1')
     RETURN FALSE
	END IF

  LET p_fat_solic_ser_comp.campo           = 'uf_placa'
  LET p_fat_solic_ser_comp.parametro_texto = p_roma.ufveiculo
  
  INSERT INTO fat_solic_ser_comp
     VALUES(p_fat_solic_ser_comp.*)

	IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('Inserindo','fat_solic_ser_comp:2')
     RETURN FALSE
	END IF

	#--------------------------#
	# Tabelas Logix 10
	#--------------------------#
	
	# FAT_SOLIC_MESTRE
	SELECT *
	INTO lr_fat_solic_mestre.*
	FROM FAT_SOLIC_MESTRE
	WHERE empresa = p_nf_solicit.cod_empresa
	AND solicitacao_fatura = p_nf_solicit.num_solicit
	IF sqlca.sqlcode <> 0 THEN
		INITIALIZE lr_fat_solic_mestre.* TO NULL
		LET lr_fat_solic_mestre.trans_solic_fatura 	= 0
		LET lr_fat_solic_mestre.empresa 			= p_nf_solicit.cod_empresa
		LET lr_fat_solic_mestre.tip_docum 			= 'SOLPRDSV'
		LET lr_fat_solic_mestre.serie_fatura		= '1'
		LET lr_fat_solic_mestre.subserie_fatura		= '0'
		LET lr_fat_solic_mestre.especie_fatura		= 'NFF'
		LET lr_fat_solic_mestre.solicitacao_fatura	= p_nf_solicit.num_solicit
		LET lr_fat_solic_mestre.usuario				= p_nf_solicit.nom_usuario
		LET lr_fat_solic_mestre.inscricao_estadual	= NULL
		LET lr_fat_solic_mestre.dat_refer			= p_nf_solicit.dat_refer
		LET lr_fat_solic_mestre.tip_solicitacao		= 'O'
		LET lr_fat_solic_mestre.lote_geral			= 'N' 
		LET lr_fat_solic_mestre.tip_carteira		= NULL
		LET lr_fat_solic_mestre.sit_solic_fatura	= 'C'
		INSERT INTO fat_solic_mestre (		empresa, 
											tip_docum, 
											serie_fatura, 
											subserie_fatura, 
											especie_fatura, 
											solicitacao_fatura, 
											usuario, 
											inscricao_estadual, 
											dat_refer, 
											tip_solicitacao, 
											lote_geral, 
											tip_carteira, 
											sit_solic_fatura)
									VALUES (lr_fat_solic_mestre.empresa,
											lr_fat_solic_mestre.tip_docum,
											lr_fat_solic_mestre.serie_fatura, 
											lr_fat_solic_mestre.subserie_fatura, 
											lr_fat_solic_mestre.especie_fatura, 
											lr_fat_solic_mestre.solicitacao_fatura, 
											lr_fat_solic_mestre.usuario, 
											lr_fat_solic_mestre.inscricao_estadual, 
											lr_fat_solic_mestre.dat_refer, 
											lr_fat_solic_mestre.tip_solicitacao, 
											lr_fat_solic_mestre.lote_geral, 
											lr_fat_solic_mestre.tip_carteira, 
											lr_fat_solic_mestre.sit_solic_fatura)
	    LET lr_fat_solic_mestre.trans_solic_fatura = SQLCA.SQLERRD[2]
	END IF
	
	# FAT_SOLIC_FATURA
	INITIALIZE lr_fat_solic_fatura.* TO NULL
	LET lr_fat_solic_fatura.trans_solic_fatura	= lr_fat_solic_mestre.trans_solic_fatura
	LET lr_fat_solic_fatura.ord_montag			= p_nf_solicit.num_om
	LET lr_fat_solic_fatura.lote_ord_montag		= 0
	LET lr_fat_solic_fatura.seq_solic_fatura	= p_nf_solicit.num_sequencia
	LET lr_fat_solic_fatura.controle			= NULL
	LET lr_fat_solic_fatura.cond_pagto			= p_nf_solicit.cod_cnd_pgto
	LET lr_fat_solic_fatura.qtd_dia_acre_dupl	= NULL
	LET lr_fat_solic_fatura.texto_1				= NULL
	LET lr_fat_solic_fatura.texto_2				= NULL
	LET lr_fat_solic_fatura.texto_3				= NULL
	LET lr_fat_solic_fatura.via_transporte		= p_nf_solicit.cod_via_transporte
	LET lr_fat_solic_fatura.cidade_dest_frete	= NULL
	LET lr_fat_solic_fatura.tabela_frete		= NULL
	LET lr_fat_solic_fatura.seq_tabela_frete	= NULL
	LET lr_fat_solic_fatura.sequencia_faixa		= NULL
	LET lr_fat_solic_fatura.transportadora		= p_nf_solicit.cod_transpor
	LET lr_fat_solic_fatura.placa_veiculo		= p_nf_solicit.num_placa
	LET lr_fat_solic_fatura.placa_carreta_1		= NULL
	LET lr_fat_solic_fatura.placa_carreta_2		= NULL
	LET lr_fat_solic_fatura.estado_placa_veic	= p_roma.ufveiculo
	LET lr_fat_solic_fatura.estado_plac_carr_1	= NULL
	LET lr_fat_solic_fatura.estado_plac_carr_2	= NULL
	LET lr_fat_solic_fatura.val_frete			= p_nf_solicit.val_frete
	LET lr_fat_solic_fatura.val_seguro			= p_nf_solicit.val_seguro
	LET lr_fat_solic_fatura.peso_liquido		= p_nf_solicit.pes_tot_liquido
	LET lr_fat_solic_fatura.peso_bruto			= p_nf_solicit.pes_tot_bruto
	LET lr_fat_solic_fatura.primeiro_volume		= 1
	IF p_nf_solicit.num_volume IS NULL THEN
		LET lr_fat_solic_fatura.volume_cubico = 0
	ELSE
		LET lr_fat_solic_fatura.volume_cubico = p_nf_solicit.num_volume
	END IF
	LET lr_fat_solic_fatura.mercado				= NULL
	LET lr_fat_solic_fatura.local_embarque		= NULL
	LET lr_fat_solic_fatura.modo_embarque		= NULL
	LET lr_fat_solic_fatura.dat_hor_embarque	= NULL
	LET lr_fat_solic_fatura.cidade_embarque		= NULL
	LET lr_fat_solic_fatura.sit_solic_fatura	= 'C'
	 
	# Alterado em 14/04/2013
	#INSERT INTO fat_solic_fatura VALUES (lr_fat_solic_fatura.*)
			INSERT INTO FAT_SOLIC_FATURA
                	(
                	TRANS_SOLIC_FATURA,
                	ORD_MONTAG,
                	LOTE_ORD_MONTAG,
                	SEQ_SOLIC_FATURA,
                	CONTROLE,
                	COND_PAGTO,
                	QTD_DIA_ACRE_DUPL,
                	TEXTO_1,
                	TEXTO_2,
                	TEXTO_3,
                	VIA_TRANSPORTE,
                	CIDADE_DEST_FRETE,
                	TABELA_FRETE,
                	SEQ_TABELA_FRETE,
                	SEQUENCIA_FAIXA,
                	TRANSPORTADORA,
                	PLACA_VEICULO,
                	PLACA_CARRETA_1,
                	PLACA_CARRETA_2,
                	ESTADO_PLACA_VEIC,
                	ESTADO_PLAC_CARR_1,
                	ESTADO_PLAC_CARR_2,
                	VAL_FRETE,
                	VAL_SEGURO,
                	PESO_LIQUIDO,
                	PESO_BRUTO,
                	PRIMEIRO_VOLUME,
                	VOLUME_CUBICO,
                	mercado,
                	local_embarque,
                	modo_embarque,
                	dat_hor_embarque,
                	cidade_embarque,
                	sit_solic_fatura
                	)
                values 
                	(
                	lr_fat_solic_fatura.trans_solic_fatura,
                	lr_fat_solic_fatura.ord_montag,
                	lr_fat_solic_fatura.lote_ord_montag,
                	lr_fat_solic_fatura.seq_solic_fatura,
                	lr_fat_solic_fatura.controle,
                	lr_fat_solic_fatura.cond_pagto,
                	lr_fat_solic_fatura.qtd_dia_acre_dupl,
                	lr_fat_solic_fatura.texto_1,
                	lr_fat_solic_fatura.texto_2,
                	lr_fat_solic_fatura.texto_3,
                	lr_fat_solic_fatura.via_transporte,
                	lr_fat_solic_fatura.cidade_dest_frete,
                	lr_fat_solic_fatura.tabela_frete,
                	lr_fat_solic_fatura.seq_tabela_frete,
                	lr_fat_solic_fatura.sequencia_faixa,
                	lr_fat_solic_fatura.transportadora,
                	lr_fat_solic_fatura.placa_veiculo,
                	lr_fat_solic_fatura.placa_carreta_1,
                	lr_fat_solic_fatura.placa_carreta_2,
                	lr_fat_solic_fatura.estado_placa_veic,
                	lr_fat_solic_fatura.estado_plac_carr_1,
                	lr_fat_solic_fatura.estado_plac_carr_2,
                	lr_fat_solic_fatura.val_frete,
                	lr_fat_solic_fatura.val_seguro,
                	lr_fat_solic_fatura.peso_liquido,
                	lr_fat_solic_fatura.peso_bruto,
                	lr_fat_solic_fatura.primeiro_volume,
                	lr_fat_solic_fatura.volume_cubico,
                	lr_fat_solic_fatura.mercado,
                	lr_fat_solic_fatura.local_embarque,
                	lr_fat_solic_fatura.modo_embarque,
                	lr_fat_solic_fatura.dat_hor_embarque,
                	lr_fat_solic_fatura.cidade_embarque,
                	lr_fat_solic_fatura.sit_solic_fatura)
	
	# FAT_SOLIC_EMBAL
	IF p_nf_solicit.cod_embal_1 IS NOT NULL THEN
		INITIALIZE lr_fat_solic_embal.* TO NULL
		LET lr_fat_solic_embal.trans_solic_fatura	= lr_fat_solic_mestre.trans_solic_fatura
		LET lr_fat_solic_embal.ord_montag			= p_nf_solicit.num_om
		LET lr_fat_solic_embal.lote_ord_montag		= 0
		LET lr_fat_solic_embal.embalagem			= p_nf_solicit.cod_embal_1
		LET lr_fat_solic_embal.qtd_embalagem		= p_nf_solicit.qtd_embal_1
		
		# Ajuste da embalagem e insert
		IF lr_fat_solic_embal.embalagem IS NULL THEN
			LET lr_fat_solic_embal.embalagem = 99
		END IF
		IF lr_fat_solic_embal.qtd_embalagem > 0 THEN
			INSERT INTO fat_solic_embal VALUES (lr_fat_solic_embal.*)
		END IF            
		
	END IF	

  RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0619_copia_pedido()
#------------------------------#

   DEFINE p_pedidos         RECORD LIKE pedidos.*
   DEFINE p_ped_itens       RECORD LIKE ped_itens.*
   DEFINE p_ped_end_ent     RECORD LIKE ped_end_ent.*
   DEFINE p_ped_info_compl  RECORD LIKE ped_info_compl.*
   DEFINE p_ped_itens_texto RECORD LIKE ped_itens_texto.*

   SELECT * 
     INTO p_pedidos.*
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_num_pedido

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','pedidos')
      RETURN FALSE
   END IF
   
   LET p_pedidos.cod_empresa = p_cod_emp_ofic      
   
   INSERT INTO pedidos
    VALUES(p_pedidos.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','pedido')
      RETURN FALSE
   END IF    
   
   DECLARE cq_pi CURSOR FOR 
    SELECT *
      FROM ped_itens
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_num_pedido

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','ped_itens')
      RETURN FALSE
   END IF

   FOREACH cq_pi INTO p_ped_itens.*
      
      IF p_pct_desc_qtd > 0 THEN
         LET p_qtd_pecas_solic = p_ped_itens.qtd_pecas_solic * ((100 - p_pct_desc_qtd)/100)
         LET p_pre_unit = p_ped_itens.pre_unit
         LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_pct_desc_oper/100)
      ELSE
         LET p_qtd_pecas_solic = p_ped_itens.qtd_pecas_solic
         LET p_pre_unit = p_ped_itens.pre_unit * ((100 - p_pct_desc_valor)/100)
         LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - p_pre_unit
         LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_pct_desc_oper/100)
      END IF
      
      UPDATE ped_itens
         SET pre_unit = p_ped_itens.pre_unit
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_sequencia = p_ped_itens.num_sequencia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','ped_itens')
         RETURN FALSE
      END IF    
    
      LET p_ped_itens.qtd_pecas_solic = p_qtd_pecas_solic
      LET p_ped_itens.pre_unit = p_pre_unit
      LET p_ped_itens.cod_empresa = p_cod_emp_ofic
      
      INSERT INTO ped_itens
       VALUES(p_ped_itens.*)
      
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Inserindo','ped_itens')
         RETURN FALSE
      END IF    
      
   END FOREACH

      DECLARE cq_ped_nat CURSOR FOR
       SELECT *
         FROM ped_item_nat
        WHERE cod_empresa   = p_cod_empresa
          AND num_pedido    = p_ped_itens.num_pedido

      FOREACH cq_ped_nat INTO p_ped_item_nat.*

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ped_item_nat')
            RETURN FALSE
         END IF    
         
         LET p_ped_item_nat.cod_empresa = p_cod_emp_ofic
         
         INSERT INTO ped_item_nat
          VALUES(p_ped_item_nat.*)

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Inserindo','ped_item_nat')
            RETURN FALSE
         END IF    
      
      END FOREACH
   
   DECLARE cq_pe CURSOR FOR 
    SELECT *
      FROM ped_end_ent
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_num_pedido

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','ped_end_ent')
      RETURN FALSE
   END IF

   FOREACH cq_pe INTO p_ped_end_ent.*
      
      LET p_ped_end_ent.cod_empresa = p_cod_emp_ofic
      
      INSERT INTO ped_end_ent
       VALUES(p_ped_end_ent.*)
      
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Inserindo','ped_end_ent')
         RETURN FALSE
      END IF    

   END FOREACH

   DECLARE cq_pic CURSOR FOR 
    SELECT *
      FROM ped_info_compl
     WHERE empresa = p_cod_empresa
       AND pedido  = p_num_pedido

   FOREACH cq_pic INTO p_ped_info_compl.*

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','ped_info_compl')
         RETURN FALSE
      END IF
      
      DELETE FROM ped_info_compl
       WHERE empresa = p_cod_emp_ofic
         AND pedido  = p_num_pedido

      LET p_ped_info_compl.empresa = p_cod_emp_ofic
         
      INSERT INTO ped_info_compl
       VALUES(p_ped_info_compl.*)
      
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Inserindo','ped_info_compl')
         RETURN FALSE
      END IF    

   END FOREACH

   DECLARE cq_pit CURSOR FOR 
    SELECT *
      FROM ped_itens_texto
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_num_pedido

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','ped_itens_texto')
      RETURN FALSE
   END IF

   FOREACH cq_pit INTO p_ped_itens_texto.*
      
      LET p_ped_itens_texto.cod_empresa = p_cod_emp_ofic

      SELECT cod_empresa
        FROM ped_itens_texto
       WHERE cod_empresa   = p_cod_emp_ofic
         AND num_pedido    = p_num_pedido
         AND num_sequencia = p_ped_itens_texto.num_sequencia
 
      IF STATUS = 100 THEN
         INSERT INTO ped_itens_texto
          VALUES(p_ped_itens_texto.*)
      
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Inserindo','ped_itens_texto')
            RETURN FALSE
         END IF    
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ped_itens_texto')
            RETURN FALSE
         END IF         
      END IF
      

   END FOREACH

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol0619_cria_item_roma_tmp()
#------------------------------------#

   DROP TABLE item_roma_tmp

   IF STATUS = 0 OR STATUS -206 THEN 
      CREATE TABLE item_roma_tmp(
          num_sequencia  DECIMAL(6,0),
          cod_item       CHAR(15),
          numlote        CHAR(15),
          largura        INTEGER,
          diametro       INTEGER,
          tubete         INTEGER,
          comprimento    INTEGER,
          pes_item       DECIMAL(12,2),
          pes_itemb      DECIMAL(12,2),
          qtd_reservada  DECIMAL(10,3),
          qtd_volumes    INTEGER
      );

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql('Criando','item_roma_tmp')
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0619_cria_om_tmp()
#-----------------------------#

  DROP TABLE om_tmp_885

   IF STATUS = 0 OR STATUS -206 THEN 
        CREATE TABLE om_tmp_885(
        cod_empresa CHAR(02),
        num_om      INTEGER,
        val_pedido  DECIMAL(12,2)
      );

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql('Criando','om_tmp_885')
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0619_grava_frete_885()
#--------------------------------#

   SELECT val_frete,
          num_versao
     INTO p_val_frete,
          p_num_versao
     FROM frete_rota_885
    WHERE cod_empresa      = p_cod_empresa
      AND cod_transpor     = p_roma.coderptranspor
      AND cod_veiculo      = p_roma.codveiculo
      AND cod_tip_carga    = p_roma.codtipcarga
      AND cod_tip_frete    = p_roma.codtipfrete
      AND cod_percurso     = p_roma.codpercurso
      AND cod_cid_orig     = p_cod_cid_orig
      AND cod_cid_dest     = p_roma.codciddest
      AND ies_versao_atual = 'S'
         
   IF STATUS = 100 THEN 
      LET p_val_frete  = 0
      LET p_num_versao = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','frete_rota_885')
         RETURN FALSE
      END IF
   END IF
      

   IF p_roma.codtipfrete = 'P' THEN
      LET p_val_frete = p_peso_total * p_val_frete / 1000
   END IF
   
   SELECT pct_desc
     INTO p_pct_desc
     FROM desc_transp_885
    WHERE cod_empresa  = p_cod_empresa
      AND cod_transpor = p_roma.coderptranspor
      
   IF STATUS = 100 THEN
      LET p_pct_desc = 0
   ELSE
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Lendo','desc_transp_885')
         RETURN FALSE
      END IF
   END IF
   
   LET p_val_fret_ger  = p_roma.valfrete  * p_pct_desc / 100
   LET p_val_fret_ofic = p_roma.valfrete  - p_val_fret_ger
   
   INSERT INTO frete_solicit_885
    VALUES(p_cod_emp_ofic,
           p_num_solicit,
           p_roma.coderptranspor,
           p_roma.placaveiculo,
           p_cod_cid_orig,
           p_roma.codciddest,
           p_roma.codveiculo,
           p_roma.codtipcarga,
           p_roma.codtipfrete,
           p_roma.codpercurso,
           NULL,
           NULL,
           p_roma.valfrete,
           p_val_frete,
           p_val_fret_ofic,
           p_val_fret_ger,
           p_num_versao,
           getdate(),
           'N',
           p_num_sequencia,
           'S',
           p_peso_carga)
           
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo','frete_solicit_885')
      RETURN FALSE
   END IF
           
   IF p_val_fret_ofic > 0 THEN
      IF NOT pol0619_rateia_frete() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0619_rateia_frete()
#-----------------------------#
   
   SELECT SUM(val_pedido)
     INTO p_val_tot
     FROM om_tmp_885

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Lendo','om_tmp_885:1')
      RETURN FALSE
   END IF

   IF p_val_tot IS NULL THEN
      RETURN TRUE
   END IF
     
   LET p_coefic = p_roma.valfrete / p_val_tot
   LET p_val_ger = 0
   
   DECLARE cq_oms CURSOR FOR
    SELECT num_om,
       SUM (val_pedido)
      FROM om_tmp_885 
     GROUP BY num_om
     ORDER BY num_om
   
   FOREACH cq_oms INTO p_num_om, p_val_pedido
   
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Lendo','om_tmp_885:2')
         RETURN FALSE
      END IF
      
      LET p_val_frete = p_val_pedido * p_coefic
      LET p_val_fret_ofic = p_val_frete * ((100 - p_pct_desc ) / 100)
      LET p_val_fret_ger  = p_val_frete * (p_pct_desc / 100)
      
      IF NOT pol0619_insere_frete_roma() THEN
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0619_insere_frete_roma()
#-----------------------------------#

   DEFINE p_op CHAR(01)
   
   INSERT INTO frete_roma_885
    VALUES(p_cod_emp_ofic,
           p_num_solicit,
           p_num_om,
           p_val_fret_ofic,
           p_val_fret_ger,
           1,'S')
                   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo','frete_roma_885')
      RETURN FALSE
   END IF

   IF p_faturar = 'T' THEN
      UPDATE solicit_fat_885
         SET val_frete = p_val_fret_ofic,
               val_ger = p_val_fret_ger
       WHERE cod_empresa IN(p_cod_emp_ofic,p_cod_emp_ger)
         AND num_solicit = p_num_solicit
         AND num_om      = p_num_om

      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Atualizando','solicit_fat_885')
         RETURN FALSE
      END IF
   END IF
      
   UPDATE nf_solicit
      SET val_frete = p_val_fret_ofic
    WHERE cod_empresa = p_cod_emp_ofic
      AND num_solicit = p_num_sf
      AND num_om      = p_num_om

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Atualizando','nf_solicit')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0619_carrega_criticas()
#--------------------------------#

   INITIALIZE p_romaneios TO NULL
   
   LET p_index = 1

   INITIALIZE p_romaneios TO NULL
   
   DECLARE cq_erros CURSOR FOR
    SELECT num_sequencia,
           den_erro,
           dat_hor
      FROM roma_erro_885
     WHERE cod_empresa  = p_cod_empresa
       AND num_romaneio = p_num_solicit
    
   FOREACH cq_erros INTO 
           p_romaneios[p_index].num_sequencia,
           p_romaneios[p_index].den_erro,
           p_dat_hor
           
      LET p_romaneios[p_index].dat_hor = EXTEND(p_dat_hor, YEAR TO DAY)

      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo","roma_erro_885")    
         RETURN FALSE
      END IF

      LET p_index = p_index + 1

      IF p_index > 2000 THEN
         ERROR 'Limite de Linhas Ultrapassado!'
         EXIT FOREACH
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0619_exibe_criticas()
#--------------------------------#

   CALL SET_COUNT(p_index - 1)

   IF ARR_COUNT() > 11 THEN
      DISPLAY ARRAY p_romaneios TO s_romaneios.*
   ELSE
      INPUT ARRAY p_romaneios WITHOUT DEFAULTS FROM s_romaneios.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0619_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_emp_ofic TO cod_empresa

END FUNCTION

#----------------------------------------#
FUNCTION pol0619_muda_status(p_cod_status)
#----------------------------------------#

   DEFINE p_cod_status CHAR(01),
          p_stat_reg   INTEGER
   
   IF NOT log004_confirm(18,35) THEN
      RETURN FALSE
   END IF
   
   UPDATE romaneio_885
      SET statusregistro = p_cod_status,
          usuario        = p_user
    WHERE codempresa   = p_cod_empresa
      AND numromaneio  = p_num_solicit
      AND numsequencia = p_num_sequencia
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Excluindo','romaneio_885')
      RETURN FALSE
   END IF

   UPDATE roma_item_885
      SET statusregistro = p_cod_status
    WHERE codempresa   = p_cod_empresa
      AND numromaneio  = p_num_solicit
      AND numseqpai    = p_num_sequencia
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Excluindo','roma_item_885')
      RETURN FALSE
   END IF
   
   DELETE FROM roma_erro_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_romaneio  = p_num_solicit
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Excluindo','roma_erro_885')
      RETURN FALSE
   END IF
   
   CALL pol0619_limpa_tela()
   LET p_ies_cons = FALSE
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0619_detalhar()
#--------------------------#


END FUNCTION

#--------------------------#
FUNCTION pol0619_om_logix()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06191") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06191 AT 05,05 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa
   
   LET p_selecionou = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa parametros p/ o processamento "
         IF NOT pol0619_par_info('1') THEN
            CALL pol0619_limpa_tela()
            ERROR 'OPERAÇÃO CANCELADA !!!'
         ELSE
            IF p_selecionou THEN
               ERROR 'OPERAÇÃO EFETUADA COM SUCESSO !!!'
               NEXT OPTION 'Processar'
            ELSE
               ERROR 'NENHUMA AÇÃO FOI SELECIONADA !!!'
            END IF
         END IF
      COMMAND "Processar" "Processa as opções selecionadas "
         IF p_selecionou THEN
            IF log004_confirm(18,35) THEN
               CALL log085_transacao("BEGIN")
               CALL pol0619_opc_proces() RETURNING p_status
               IF p_status THEN
                  CALL log085_transacao("COMMIT")
               ELSE
                 CALL log085_transacao("ROLLBACK")
               END IF
               CALL log0030_mensagem(p_den_erro,'info')
               LET p_cod_empresa = p_cod_emp_ofic
               LET p_selecionou = FALSE
               NEXT OPTION 'Informar'
            END IF
         ELSE
            ERROR 'INFORME PREVIAMENTE OS PARÂMETROS'
         END IF
      COMMAND "Restaurar" "Restaura solicitação excluida pelo concelamento da NF"
         IF pol0619_par_info('2') THEN
            IF NOT pol0619_restaurar() THEN
               ERROR 'OPERAÇÃO CANCELADA !!!'
            ELSE
               CALL log0030_mensagem('RESTAURAÇÃO PROCESSADA COM SUCESSO' ,'excla')
            END IF
         ELSE
            ERROR 'OPERAÇÃO CANCELADA !!!'
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
 
   CLOSE WINDOW w_pol06191


END FUNCTION

#-----------------------------#
FUNCTION pol0619_par_info(p_op)
#-----------------------------#

   DEFINE p_op CHAR(01)
   
   LET p_cod_empresa = p_cod_emp_ger
   
   INITIALIZE p_num_solicit, pr_om TO NULL
   LET INT_FLAG = FALSE
   CALL pol0619_limpa_tela()
   
   INPUT p_num_solicit WITHOUT DEFAULTS FROM num_roma

      AFTER FIELD num_roma
         IF p_num_solicit IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD num_roma
         END IF
         
         SELECT COUNT(num_om)
           INTO p_count
           FROM solicit_fat_885
          WHERE num_solicit = p_num_solicit
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','solicit_fat_885')
            NEXT FIELD num_roma
         END IF
         
         IF p_count = 0 THEN
            CALL log0030_mensagem('Romaneio não está processado.','excla')
            NEXT FIELD num_roma
         END IF

      ON KEY (control-z)
         CALL pol0619_popup('L')

   END INPUT

   LET p_selecionou = FALSE
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF p_op = '2' THEN
      RETURN TRUE
   END IF

   SELECT numsequencia
     INTO p_num_sequencia
     FROM romaneio_885
    WHERE codempresa     = p_cod_empresa
      AND numromaneio    = p_num_solicit
      AND statusregistro = '1'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','romaneio_885')
      RETURN FALSE
   END IF

   CALL pol0619_gera_num_sf()

   CALL pol0619_exibe_oms() RETURNING p_status

   IF p_status THEN
   
      FOR p_index = 1 TO ARR_COUNT()
          IF pr_om[p_index].cod_acao IS NOT NULL THEN
             LET p_selecionou = TRUE
             EXIT FOR
          END IF
      END FOR

   END IF
      
   RETURN(p_status)

END FUNCTION

#---------------------------#
FUNCTION pol0619_exibe_oms()
#---------------------------#

   LET p_index = 1
   INITIALIZE pr_om TO NULL
   
   DECLARE cq_ord_m CURSOR FOR
    SELECT DISTINCT
           num_om,
           num_pedido,
           cod_status
      FROM solicit_fat_885
     WHERE num_solicit = p_num_solicit
   
   FOREACH cq_ord_m INTO
           pr_om[p_index].num_om,
           pr_om[p_index].num_pedido,
           pr_om[p_index].cod_status

      IF pr_om[p_index].cod_status = 'N' THEN
         SELECT ies_sit_om
           INTO p_cod_status
           FROM ordem_montag_mest
          WHERE cod_empresa = p_cod_emp_ofic
            AND num_om      = pr_om[p_index].num_om
         IF STATUS = 0 THEN
            LET pr_om[p_index].cod_status = p_cod_status
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('Lendo','pedidos')
               RETURN FALSE
            END IF
         END IF
      END IF         

      SELECT cod_cliente
        INTO pr_om[p_index].cod_cliente
        FROM pedidos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = pr_om[p_index].num_pedido
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','pedidos')
         RETURN FALSE
      END IF
        
      SELECT nom_cliente
        INTO pr_om[p_index].nom_cliente
        FROM clientes
       WHERE cod_cliente = pr_om[p_index].cod_cliente

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','clientes')
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 200 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassado','excla')
         RETURN FALSE
      END IF
      
   END FOREACH

   CALL pol0619_selec_acao() RETURNING p_status
   
   RETURN(p_status)
      
END FUNCTION

#----------------------------#
FUNCTION pol0619_selec_acao()
#----------------------------#

   CALL SET_COUNT(p_index -1)
   
   INPUT ARRAY pr_om
      WITHOUT DEFAULTS FROM sr_om.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()

      AFTER FIELD cod_acao
         IF pr_om[p_index].cod_acao IS NOT NULL THEN
            IF pr_om[p_index].cod_acao MATCHES '[CG]' THEN
            ELSE
               ERROR 'Acão inválida !!!'
               NEXT FIELD cod_acao
            END IF
            IF pr_om[p_index].cod_acao = 'C' THEN
               IF pr_om[p_index].cod_status <> 'N' THEN
                  ERROR 'ORDEM DE MONTAGEM ESTÁ CANCELADA OU FATURADA'
                  NEXT FIELD cod_acao
               END IF
            ELSE
               IF pr_om[p_index].cod_acao = 'G' THEN
                  IF pr_om[p_index].cod_status <> 'C' THEN
                     ERROR 'Ordem de montagem já existe'
                     NEXT FIELD cod_acao
                  END IF
               END IF
            END IF
         END IF               
         
   END INPUT

   IF NOT INT_FLAG THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol0619_checa_possib_canc()
#-----------------------------------#

   INITIALIZE p_den_erro, p_ies_sit_om TO NULL
      
   SELECT ies_sit_om
     INTO p_ies_sit_om
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_emp_ger
      AND num_om      = p_sol.num_om
   
   IF STATUS <> 0 THEN 
      SELECT ies_sit_om
        INTO p_ies_sit_om
        FROM ordem_montag_mest
       WHERE cod_empresa = p_cod_emp_ofic
         AND num_om      = p_sol.num_om
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_montag_mest')
         RETURN
      END IF 
   END IF

   IF p_ies_sit_om = 'F' THEN
      LET p_den_erro = 'ORDEM DE MONTAGEM JÁ FATURADA'
   END IF
   
END FUNCTION

#----------------------------#
FUNCTION pol0619_opc_proces()
#----------------------------#

   LET p_den_erro = 'Operacao cancelada.'
   
   IF NOT pol0619_cria_solicit_tmp() THEN
      RETURN FALSE
   END IF

   FOR p_index = 1 TO ARR_COUNT()
       IF pr_om[p_index].cod_acao IS NULL THEN
       ELSE
          INSERT INTO solicit_tmp_885
           VALUES(pr_om[p_index].num_om,
                  pr_om[p_index].num_pedido,
                  pr_om[p_index].cod_acao)
          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','solicit_tmp_885')
             RETURN FALSE
          END IF
       END IF
   END FOR

   LET p_criticou = FALSE

   IF NOT pol0619_deleta_erros() THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_tmp_c CURSOR FOR
    SELECT num_om,
           num_pedido,
           cod_acao
      FROM solicit_tmp_885
     WHERE cod_acao = 'C'

   FOREACH cq_tmp_c INTO p_sol.*
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','solicit_tmp_885')
         RETURN FALSE
      END IF

      IF NOT pol0619_cancela_om() THEN
         RETURN FALSE
      END IF
      
   END FOREACH

   SELECT COUNT(num_om)
     INTO p_count
     FROM solicit_tmp_885
    WHERE cod_acao = 'G'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','solicit_tmp_885')
      RETURN FALSE
   END IF
    
   IF p_count > 0 THEN
      UPDATE roma_item_885
         SET numseqpai = 0
       WHERE codempresa  = p_cod_empresa
         AND numromaneio = p_num_solicit
         AND numseqpai   = p_num_sequencia
         AND numpedido  NOT IN (SELECT num_pedido
                                  FROM solicit_tmp_885
                                 WHERE cod_acao = 'G')
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','roma_item_885')
         RETURN FALSE
      END IF

      IF NOT pol0619_regera_om() THEN
         RETURN FALSE
      END IF
      
      UPDATE roma_item_885
         SET numseqpai = p_num_sequencia
       WHERE codempresa  = p_cod_empresa
         AND numromaneio = p_num_solicit
         AND numseqpai   = 0
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','roma_item_885')
         RETURN FALSE
      END IF

   END IF
   
   SELECT COUNT(num_om)
     INTO p_count
     FROM solicit_fat_885
    WHERE cod_empresa = p_cod_emp_ofic
      AND num_solicit = p_num_solicit
      AND cod_status  = 'N'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','solicit_fat_885')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      IF NOT pol0619_deleta_solicit() THEN
         RETURN FALSE
      END IF
   END IF
   
   LET p_den_erro = 'Processamento efetuado com sucesso.'

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0619_cancela_om()
#----------------------------#

   CALL pol0619_checa_possib_canc()

   IF p_den_erro IS NOT NULL THEN
      IF NOT pol0619_insere_erro() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   DECLARE cd_emp CURSOR FOR 
    SELECT cod_empresa,
           num_om
      FROM ordem_montag_mest
     WHERE num_om = p_sol.num_om

   FOREACH cd_emp INTO p_cod_empresa, p_num_om

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_montag_mest')
         RETURN FALSE
      END IF
      
      IF NOT pol0619_cancela_roma() THEN
         RETURN FALSE
      END IF

      UPDATE solicit_fat_885
         SET cod_status = 'C'
       WHERE cod_empresa = p_cod_empresa
         AND num_solicit = p_num_solicit
         AND num_om      = p_num_om

      IF SQLCA.SQLCODE <> 0 THEN
          CALL log003_err_sql('Atualizando','solicit_fat_885')
          RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0619_deleta_erros()
#------------------------------#
   
   DELETE FROM roma_erro_885
    WHERE cod_empresa  = p_cod_empresa
      AND num_romaneio = p_num_solicit

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','roma_erro_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#------------------------------#
FUNCTION pol0619_cancela_roma()
#------------------------------#
 DEFINE l_trans_solic_fatura 	INTEGER
 DEFINE l_solicitacao_fatura	INTEGER

   DEFINE l_num_reserva   LIKE ordem_montag_grade.num_reserva,
          p_num_sequencia LIKE ped_itens.num_sequencia,
          p_qtd_reservada LIKE ordem_montag_item.qtd_reservada,
          p_cod_item      LIKE ordem_montag_item.cod_item,
          p_texto         CHAR(40)


   DECLARE cq_ped CURSOR FOR 
    SELECT num_pedido,
           num_sequencia,
           cod_item,
           qtd_reservada
      FROM ordem_montag_item
     WHERE cod_empresa = p_cod_empresa
       AND num_om      = p_num_om

   FOREACH cq_ped INTO 
           p_num_pedido, 
           p_num_sequencia, 
           p_cod_item,
           p_qtd_reservada
   
      UPDATE ped_itens
         SET qtd_pecas_romaneio = qtd_pecas_romaneio - p_qtd_reservada
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_sequencia = p_num_sequencia

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Atualizando','ped_itens')
         RETURN FALSE
      END IF
      
      UPDATE estoque
         SET qtd_reservada = qtd_reservada - p_qtd_reservada
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item

      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Atualizando','estoque')
         RETURN FALSE
      END IF
         
   END FOREACH

   DELETE FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_item')
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_embal
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_embal')
      RETURN FALSE
   END IF

   DECLARE cq_reser CURSOR FOR
    SELECT num_reserva
      FROM ordem_montag_grade
     WHERE cod_empresa = p_cod_empresa
       AND num_om      = p_num_om
      
   FOREACH cq_reser INTO l_num_reserva
  
      UPDATE estoque_loc_reser
         SET qtd_reservada = 0
       WHERE cod_empresa = p_cod_empresa
         AND num_reserva = l_num_reserva
      
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql('Deletando','estoque_loc_reser')
         RETURN FALSE
      END IF
  
   END FOREACH
  
   DELETE FROM ordem_montag_grade
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_grade')
      RETURN FALSE
   END IF

   SELECT num_lote_om
     INTO l_num_lote_om
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Lendo','ordem_montag_mest')
      RETURN FALSE
   END IF
     
   DELETE FROM ordem_montag_lote
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_om = l_num_lote_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_lote')
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_mest')
      RETURN FALSE
   END IF

   DELETE FROM om_list
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','om_list')
      RETURN FALSE
   END IF

   DELETE FROM frete_roma_885
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om
      
   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('Deletando','frete_roma_885')
      RETURN FALSE
   END IF

   	INITIALIZE l_trans_solic_fatura TO NULL
	SELECT a.trans_solic_fatura, a.solicitacao_fatura
	INTO l_trans_solic_fatura, l_solicitacao_fatura
	FROM FAT_SOLIC_MESTRE a, fat_solic_fatura b
	WHERE a.trans_solic_fatura = b.trans_solic_fatura
	AND a.empresa = p_cod_empresa
	AND b.ord_montag = p_num_om
	IF l_trans_solic_fatura IS NOT NULL THEN
		DELETE FROM fat_solic_fatura WHERE trans_solic_fatura = l_trans_solic_fatura AND ord_montag = p_num_om
		DELETE FROM fat_solic_embal	 WHERE trans_solic_fatura = l_trans_solic_fatura AND ord_montag = p_num_om

		SELECT DISTINCT 1
		FROM FAT_SOLIC_MESTRE a, fat_solic_fatura b
		WHERE a.trans_solic_fatura = b.trans_solic_fatura
		AND a.empresa = p_cod_empresa
		AND a.solicitacao_fatura = p_nf_solicit.num_solicit
		IF sqlca.sqlcode <> 0 THEN
			DELETE FROM fat_solic_mestre WHERE trans_solic_fatura = l_trans_solic_fatura
		END IF

	END IF

   DELETE FROM nf_solicit
     WHERE cod_empresa = p_cod_empresa
       AND num_solicit = p_num_sf
       AND num_om      = p_num_om

   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Deletando','nf_solicit')
       RETURN FALSE
   END IF

   DELETE FROM fat_solic_ser_comp
     WHERE empresa            = p_cod_empresa
       AND solicitacao_fatura = p_num_sf
       AND ord_montag         = p_num_om

   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Deletando','fat_solic_ser_comp')
       RETURN FALSE
   END IF

   LET p_hor_atual = CURRENT HOUR TO SECOND
   
   LET p_texto = "CANCELAMENTO DA OM Nr.", p_num_om USING '&&&&&&&&&&'
   
   INSERT INTO audit_vdp (
      cod_empresa,
      num_pedido,
      tipo_informacao,
      tipo_movto,
      texto,
      num_programa,
      data,
      hora,
      usuario)
    VALUES(p_cod_empresa,
           0,
           'C',
           'C', 
           p_texto,
           'POL0619',
           getdate(),
           p_hor_atual,
           p_user)
           
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_vdp')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0619_deleta_solicit()
#--------------------------------#

   SELECT num_sequencia
     INTO p_num_sequencia
     FROM frete_solicit_885
    WHERE cod_empresa = p_cod_emp_ofic
      AND num_solicit = p_num_solicit

   IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
       CALL log003_err_sql('Lendo','frete_solicit_885')
       RETURN FALSE
   END IF
   
   IF SQLCA.SQLCODE = 100 THEN
      SELECT MAX(numsequencia)
        INTO p_num_sequencia
        FROM romaneio_885
       WHERE codempresa  = p_cod_emp_ger
         AND numromaneio = p_num_solicit

      IF p_num_sequencia IS NULL THEN
         CALL log003_err_sql('Lendo','romaneio_885:sequencia')
         RETURN FALSE
      END IF
   END IF

   UPDATE romaneio_885
      SET StatusRegistro = '2'
    WHERE codempresa   = p_cod_emp_ger
      AND numromaneio  = p_num_solicit
      AND numsequencia = p_num_sequencia
      
   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Atualizando','romaneio_885')
       RETURN FALSE
   END IF
      
   DELETE FROM frete_solicit_885
     WHERE num_solicit = p_num_solicit

   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Deletando','frete_solicit_885')
       RETURN FALSE
   END IF

   DELETE FROM solicit_fat_885
     WHERE num_solicit = p_num_solicit

   IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('Deletando','solicit_fat_885')
       RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0619_cheka_fat()
#---------------------------#

   DEFINE p_qtd_om_fat SMALLINT
   
   DECLARE cq_fat CURSOR FOR 
    SELECT num_om
      FROM solicit_fat_885
     WHERE num_solicit = p_num_solicit
      
   FOREACH cq_fat INTO p_num_om

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','solicit_fat_885')
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      SELECT COUNT(num_om)
        INTO p_qtd_om_fat
        FROM ordem_montag_mest
       WHERE num_om     = p_num_om
         AND ies_sit_om = 'F'
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_montag_mest')
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF p_qtd_om_fat > 0 THEN
         CALL log003_err_sql('Lendo','ordem_montag_mest')
         IF NOT pol0619_insere_erro() THEN
            RETURN FALSE
         END IF
         EXIT FOREACH
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION  pol0619_regera_om()
#----------------------------#

   IF NOT pol0619_le_romaneio_885() THEN
      RETURN FALSE
   END IF

   LET p_criticou = FALSE
   LET p_numsequencia = 0
   LET p_faturar = 'P'

   IF NOT pol0619_consiste_roma() THEN
      RETURN FALSE
   END IF

   IF p_criticou THEN
      IF pol0619_carrega_criticas() THEN
         CALL pol0619_criticas_exibe()
      END IF
      LET p_den_erro = 'Operacção cancelada.'
      RETURN FALSE
   END IF

   LET p_den_erro = NULL

   IF NOT pol0619_insere_solicit() THEN
      CALL log0030_mensagem(p_den_erro,'excla')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0619_criticas_exibe()
#--------------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06192") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06192 AT 07,04 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY p_romaneios TO s_romaneios.*
  
   CLOSE WINDOW w_pol06192
   
END FUNCTION

#----------------------------------#
FUNCTION pol0619_cria_solicit_tmp()
#----------------------------------#

   DROP TABLE solicit_tmp_885

   IF STATUS = 0 OR STATUS -206 THEN 
 
      CREATE TABLE solicit_tmp_885(
         num_om     INTEGER,
         num_pedido DECIMAL(6,0),
         cod_acao   CHAR(01)
       );

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","solicit_tmp_885")
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0619_popup(p_ch)
#--------------------------#

   DEFINE p_codigo CHAR(15),
          p_ch     CHAR(01)

   CASE
   
      WHEN INFIELD(num_roma)
         LET p_codigo = pol0619_escolhe_roma(p_ch)
         CLOSE WINDOW w_pol06193
         IF p_codigo IS NOT NULL THEN
            LET p_num_solicit = p_codigo
            DISPLAY p_num_solicit TO num_roma
         END IF
   
   END CASE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0619_escolhe_roma(p_ch)
#---------------------------------#

   DEFINE pr_pop_roma ARRAY[200] OF RECORD
          num_roma INTEGER
   END RECORD
   
   DEFINE p_ch     CHAR(01),
          sql_stmt CHAR(600)

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06193") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   IF p_ch = 'T' THEN
      OPEN WINDOW w_pol06193 AT 08,14 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   ELSE
      OPEN WINDOW w_pol06193 AT 09,63 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   END IF
   
   LET INT_FLAG = FALSE
   LET p_ind = 1
   
   IF p_ch = 'T' THEN
      LET sql_stmt = "SELECT numromaneio FROM romaneio_885 ",
                     " WHERE statusregistro IN ('0','2') ",
                     "   AND codempresa ='",p_cod_empresa,"' ",
                     " ORDER BY numromaneio "
   ELSE
      LET sql_stmt = "SELECT num_solicit FROM solicit_fat_885 ",
                     " WHERE cod_empresa ='",p_cod_empresa,"' ",
                     " ORDER BY num_solicit desc"
   END IF

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_pop CURSOR FOR var_query
      
   FOREACH cq_pop INTO pr_pop_roma[p_ind].num_roma
   
      LET p_ind = p_ind + 1
      
   END FOREACH
   
   IF p_ind = 1 THEN
      CALL log0030_mensagem('Naõ há romaneio p/ integrar.','excla')
      RETURN ""
   END IF
   
   CALL SET_COUNT(p_ind -1)
   
   DISPLAY ARRAY pr_pop_roma TO sr_pop_roma.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE()

   
   IF INT_FLAG THEN
      RETURN ""
   ELSE
      RETURN(pr_pop_roma[p_ind].num_roma)
   END IF
   
END FUNCTION

#---------------------------#
FUNCTION pol0619_restaurar()
#---------------------------#

   CALL pol0619_gera_num_sf()
   
   SELECT COUNT(num_solicit)
     INTO p_count
     FROM nf_solicit
    WHERE num_solicit = p_num_sf
    
   IF p_count > 0 THEN
      CALL log0030_mensagem('Solicitação sem necessidade de restauração','excla')
      RETURN FALSE
   END IF
   
   INITIALIZE p_nf_solicit TO NULL
   
   DECLARE cq_nfs CURSOR FOR
    SELECT cod_empresa,
           num_solicit,
           dat_refer,
           cod_via_transporte,
           cod_entrega,
           ies_tip_solicit,
           ies_lotes_geral,
           cod_tip_carteira,
           num_lote_om,
           num_om,
           val_frete,
           val_seguro,
           val_frete_ex,
           val_seguro_ex,
           pes_tot_bruto,
           ies_situacao,
           num_sequencia,
           nom_usuario,
           cod_transpor,
           num_placa,
           num_volume,
           cod_cnd_pgto,
           pes_tot_liquido,
           cod_embal_1,
           qtd_embal_1
      FROM nf_solicit_885
     WHERE cod_empresa  = p_cod_emp_ofic
       AND num_romaneio = p_num_solicit 

   
   FOREACH cq_nfs INTO 
           p_nf_solicit.cod_empresa,
           p_nf_solicit.num_solicit,
           p_nf_solicit.dat_refer,
           p_nf_solicit.cod_via_transporte,
           p_nf_solicit.cod_entrega,
           p_nf_solicit.ies_tip_solicit,
           p_nf_solicit.ies_lotes_geral,
           p_nf_solicit.cod_tip_carteira,
           p_nf_solicit.num_lote_om,
           p_nf_solicit.num_om,
           p_nf_solicit.val_frete,
           p_nf_solicit.val_seguro,
           p_nf_solicit.val_frete_ex,
           p_nf_solicit.val_seguro_ex,
           p_nf_solicit.pes_tot_bruto,
           p_nf_solicit.ies_situacao,
           p_nf_solicit.num_sequencia,
           p_nf_solicit.nom_usuario,
           p_nf_solicit.cod_transpor,
           p_nf_solicit.num_placa,
           p_nf_solicit.num_volume,
           p_nf_solicit.cod_cnd_pgto,
           p_nf_solicit.pes_tot_liquido,
           p_nf_solicit.cod_embal_1,
           p_nf_solicit.qtd_embal_1    

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("LENDO","nf_solicit_885")
         RETURN FALSE
      END IF

      IF NOT pol0619_grava_nf_solicit() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   RETURN TRUE
      
END FUNCTION

#------------------------------#
FUNCTION pol0619_transf_situa()
#------------------------------#

   LET p_cod_operacao = p_oper_s_trnsf
   LET p_estoque_lote_ender.ies_situa_qtd = 'E'
   
   IF NOT pol0619_ins_transf() THEN
      RETURN FALSE
   END IF
   
   LET p_num_trans_origem = p_num_transac

   LET p_cod_operacao = p_oper_e_trnsf
   LET p_estoque_lote_ender.ies_situa_qtd = 'L'	
   
   IF NOT pol0619_ins_transf() THEN
      RETURN FALSE
   END IF
   
   LET p_num_trans_destino = p_num_transac
   
   INSERT INTO sup_mov_orig_dest
      VALUES(p_cod_empresa,
             p_num_trans_origem,
             p_num_trans_destino,'2')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','sup_mov_orig_dest')
      RETURN FALSE
   END IF

   IF NOT pol0619_atuali_estoq() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION            

#----------------------------#
FUNCTION pol0619_ins_transf()
#----------------------------#

   DEFINE p_estoque_trans     RECORD LIKE estoque_trans.*,
          p_estoque_trans_end RECORD LIKE estoque_trans_end.*
   
   DEFINE p_ies_com_detalhe   LIKE estoque_operac.ies_com_detalhe,
          p_num_conta         LIKE estoque_operac_ct.num_conta_debito

   INITIALIZE p_estoque_trans,
              p_estoque_trans_end TO NULL
              
   SELECT ies_com_detalhe
     INTO p_ies_com_detalhe
     FROM estoque_operac
    WHERE cod_empresa  = p_cod_empresa
      AND cod_operacao = p_cod_operacao

   IF STATUS = 100 THEN
     LET p_ies_com_detalhe = 'N'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_operac')
         RETURN FALSE
      END IF
   END IF

   IF p_ies_com_detalhe = 'S' THEN 
      IF p_cod_operacao = p_oper_s_trnsf THEN
         SELECT num_conta_debito 
           INTO p_num_conta
           FROM estoque_operac_ct
          WHERE cod_empresa  = p_cod_empresa
            AND cod_operacao = p_cod_operacao
      ELSE
         SELECT num_conta_credito 
           INTO p_num_conta
           FROM estoque_operac_ct
          WHERE cod_empresa  = p_cod_empresa
            AND cod_operacao = p_cod_operacao
      END IF
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_operac_ct')
         RETURN FALSE
      END IF
   ELSE
      LET p_num_conta = NULL
   END IF
      
   LET p_estoque_trans.cod_empresa        = p_cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_estoque_lote_ender.cod_item
   LET p_estoque_trans.dat_movto          = TODAY
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.ies_tip_movto      = 'N'
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = "pol0619"
   LET p_estoque_trans.num_docum          = p_num_solicit
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.qtd_movto          = p_estoque_lote_ender.qtd_saldo

   IF p_cod_operacao = p_oper_s_trnsf THEN 
      LET p_estoque_trans.ies_sit_est_orig   = p_estoque_lote_ender.ies_situa_qtd
      LET p_estoque_trans.cod_local_est_orig = p_estoque_lote_ender.cod_local
      LET p_estoque_trans.num_lote_orig      = p_estoque_lote_ender.num_lote
   ELSE
      LET p_estoque_trans.ies_sit_est_dest   = p_estoque_lote_ender.ies_situa_qtd
      LET p_estoque_trans.cod_local_est_dest = p_estoque_lote_ender.cod_local
      LET p_estoque_trans.num_lote_dest      = p_estoque_lote_ender.num_lote
   END IF
   
   INSERT INTO estoque_trans(
          cod_empresa,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   


   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans')
     RETURN FALSE
   END IF

   LET p_num_transac = SQLCA.SQLERRD[2]

   LET p_estoque_trans_end.num_transac      = p_num_transac
   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = 0
   LET p_estoque_trans_end.cus_unit_movto_f = 0
   LET p_estoque_trans_end.cus_tot_movto_p  = 0
   LET p_estoque_trans_end.cus_tot_movto_f  = 0
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = ' '
   LET p_estoque_trans_end.tex_reservado    = " "

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end')  
     RETURN FALSE
   END IF

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, p_num_transac, p_user, getdate(),'pol0619')

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria')   
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0619_atuali_estoq()
#------------------------------#

   UPDATE estoque
      SET qtd_lib_excep = qtd_lib_excep - p_estoque_lote_ender.qtd_saldo,
          qtd_liberada  = qtd_liberada  + p_estoque_lote_ender.qtd_saldo
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_estoque_lote_ender.cod_item
      
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Atualizando','estoque')   
     RETURN FALSE
   END IF

   IF p_estoque_lote_ender.num_lote IS NOT NULL THEN
      UPDATE estoque_lote
         SET ies_situa_qtd = 'L'
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
         AND cod_local   = p_estoque_lote_ender.cod_local
         AND num_lote    = p_estoque_lote_ender.num_lote
         AND ies_situa_qtd = 'E'
      IF STATUS = 0 THEN
         UPDATE estoque_lote_ender
            SET ies_situa_qtd = 'L'
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND num_lote    = p_estoque_lote_ender.num_lote
            AND largura     = p_estoque_lote_ender.largura
            AND altura      = p_estoque_lote_ender.altura
            AND diametro    = p_estoque_lote_ender.diametro
            AND comprimento = p_estoque_lote_ender.comprimento
            AND ies_situa_qtd = 'E'
      ELSE
         CALL log003_err_sql('Atualizando','estoque_lote')
         RETURN FALSE
      END IF
   ELSE
      UPDATE estoque_lote
         SET ies_situa_qtd = 'L'
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
         AND cod_local   = p_estoque_lote_ender.cod_local
         AND ies_situa_qtd = 'E'         
         AND num_lote IS NULL
      IF STATUS = 0 THEN
         UPDATE estoque_lote_ender
            SET ies_situa_qtd = 'L'
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND largura     = p_estoque_lote_ender.largura
            AND altura      = p_estoque_lote_ender.altura
            AND diametro    = p_estoque_lote_ender.diametro
            AND comprimento = p_estoque_lote_ender.comprimento
            AND ies_situa_qtd = 'E'
            AND num_lote IS NULL
      ELSE
         CALL log003_err_sql('Atualizando','estoque_lote')
         RETURN FALSE
      END IF
   END IF
      
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Atualizando','estoque_lote_ender')   
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------FIM DO PROGRAMA------------------#
