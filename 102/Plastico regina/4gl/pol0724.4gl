#------------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                       #
# PROGRAMA: pol0724                                                      #
# OBJETIVO: Exportacao de dados para arquivo TXT - para EDI              #
# CLIENTE.: PLASTICOS REGINA                                             #
# AUTOR...: POLO INFORMATICA - ANA PAULA QF                              #
# DATA....: 25/01/2008                                                   #
# ALTERADO: 19/02/2008 por Ana Paula - versao 08                         #
# ALTERADO: 29/07/2008 por Ana Paula - versao 11                         #
#------------------------------------------------------------------------#
DATABASE logix

# Linhas comentadas da 1041 a 1045
# Alterações linha 618 mudança no ORDER BY
# Alterações da linha 666 a 669, foi acrescentado esta variavel p_primeiro_header

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_nom_tela             CHAR(080),
          p_nom_help             CHAR(200),
          p_cod_uni_feder        LIKE cidades.cod_uni_feder,
          p_cod_cliente          LIKE clientes.cod_cliente,
          p_num_pedido           LIKE pedido_dig_mest.num_pedido,
          p_transacao            SMALLINT,
          p_codigo               DECIMAL(15,0),
          p_houve_erro           SMALLINT,
          p_count                SMALLINT,
          p_status               SMALLINT,
          p_versao               CHAR(18),
          p_des_especie          CHAR(15), 
          p_qtd_volumes          CHAR(30),
          p_qtd_devolvida        DECIMAL(15,3),
          p_qtd_tot_recebida     DECIMAL(15,3),
          p_val_unitario         DECIMAL(15,2), 
          p_unid_terc            CHAR(02),
          p_den_item_reduz       LIKE item.den_item_reduz, 
          p_qtd_item             LIKE nf_item.qtd_item,
          p_pre_unit_nf          LIKE nf_item.pre_unit_nf,
          p_pre_tot_nf           LIKE nf_mestre.val_tot_nff,
          p_ies_situacao         LIKE nf_mestre.ies_situacao,
          p_unid_med             LIKE item.cod_unid_med,
          p_cod_item_cliente     LIKE cliente_item.cod_item_cliente,
          p_num_reserva          LIKE ordem_montag_grade.num_reserva,
          p_num_lote             CHAR(15),
          p_num_seq              SMALLINT,
          p_pedido_cli           CHAR(25),
          p_num_pedido_cli       CHAR(25),
          p_cod_fornec_cliente   CHAR(15),
          p_ser_nf               CHAR(01),
          p_serie_nf             CHAR(02),
          p_ies_conver           CHAR(01),
          p_val_tot_ipi_acum     DECIMAL(15,3),
          p_data_arquivo         DATE,
          p_hora_arquivo         DATETIME HOUR TO SECOND,
          p_conta_notas          SMALLINT,
          p_soma_vlr_total       DECIMAL(15,2),
          p_rem_data             DATETIME DAY TO MINUTE,
          p_dir_ferrero_713      CHAR(40),
          p_compl                CHAR(30),
          p_data                 CHAR(10),
          p_hora                 CHAR(19),
          p_data_arq             CHAR(10),
          p_hora_arq             CHAR(19),
          p_data_rem             CHAR(08),
          p_data_tit             CHAR(08),
          p_hora_rem             CHAR(04),
          p_val_mo               DECIMAL(15,2), 
          p_nota_fiscal          DECIMAL(6,0),
          p_nota_fiscal1         DECIMAL(6,0),
          p_contador             SMALLINT,
          p_cod_itemc            CHAR(13),
          p_cod_item_retornoc    CHAR(13),
          p_ind                  SMALLINT,
          i                      SMALLINT,
          p_destinatario         CHAR(19),
          p_destinatario1        CHAR(19),
          p_primeira_vez         SMALLINT,
          p_comeco               CHAR(01),
          p_valor_total          DECIMAL(17,0),
          p_qtde_notas           SMALLINT,
          p_cod_unid_med         CHAR(03),
          p_val_remessa          DECIMAL(15,2), 
          p_val_icms             DECIMAL(15,2),
          p_val_ipi              DECIMAL(15,2),
          p_val_liq_item         DECIMAL(15,2),
          p_observacao           CHAR(50),
          p_pct_icms             DECIMAL(6,3),
          p_pct_ipi              DECIMAL(6,3),
          p_zero                 CHAR(01),
          p_cod_operacao         INTEGER,
          p_fim                  CHAR(01),
          p_nota                 LIKE wfat_mestre.num_nff,
          p_primeiro_header      CHAR(01),
		  p_msg               	 CHAR(300),
		  p_zeros_i2             DECIMAL(6,0)
                    
   DEFINE p_comando       CHAR(80),
          p_caminho       CHAR(80),
          p_caminho_a     CHAR(80),
          m_caminho       CHAR(80),
          p_caminho_help  CHAR(80)

   DEFINE p_num_nf            DECIMAL(7,0),
          p_dat_emis_nf       DATE,
          p_cod_item          CHAR(15),
          p_cod_item_retorno  CHAR(15),
          p_num_nf_retorno    DECIMAL(6,0),
          p_dat_nf_retorno    DATE
          
   DEFINE p_nff       
          RECORD
             num_nff             DECIMAL(6,0),
             ser_nf              CHAR(02),
             den_nat_oper        LIKE nat_operacao.den_nat_oper, 
             cod_fiscal          LIKE wfat_mestre.cod_fiscal,
             cod_fiscal1         LIKE wfat_mestre.cod_fiscal,
             den_nat_oper1       LIKE nat_operacao.den_nat_oper, 
             ins_estadual_trib   LIKE subst_trib_uf.ins_estadual,
             ins_estadual_emp    LIKE empresa.ins_estadual,
             dat_emissao         LIKE wfat_mestre.dat_emissao,
             nom_destinatario    CHAR(36),
             num_cgc_cpf         CHAR(19),
             dat_saida           LIKE wfat_mestre.dat_emissao,
             cod_uni_feder       LIKE cidades.cod_uni_feder,
             cod_cliente         LIKE clientes.cod_cliente,

 { Corpo da nota contendo os itens da mesma. Pode conter ate 999 itens }

             val_tot_base_icm    LIKE wfat_mestre.val_tot_base_icm,
             val_tot_icm         LIKE wfat_mestre.val_tot_icm,
             val_tot_base_ret    LIKE wfat_mestre.val_tot_base_ret,
             val_tot_icm_ret     LIKE wfat_mestre.val_tot_icm_ret,
             val_tot_mercadoria  LIKE wfat_mestre.val_tot_mercadoria,
             val_frete_cli       LIKE wfat_mestre.val_frete_cli,
             val_seguro_cli      LIKE wfat_mestre.val_seguro_cli,
             val_tot_despesas    LIKE wfat_mestre.val_seguro_cli,
             val_tot_base_ipi    LIKE wfat_mestre.val_tot_mercadoria,
             val_tot_ipi         LIKE wfat_mestre.val_tot_ipi,
             val_tot_nff         LIKE wfat_mestre.val_tot_nff,

             nom_transpor        LIKE clientes.nom_cliente,
             ies_frete           LIKE wfat_mestre.ies_frete,
             num_placa           LIKE wfat_mestre.num_placa,
             cod_uni_feder_trans LIKE cidades.cod_uni_feder,
             qtd_volumes         DECIMAL(5,0),
             des_especie1        CHAR(15),
             des_especie2        CHAR(15),
             des_especie3        CHAR(15),
             des_especie4        CHAR(15),
             des_especie5        CHAR(15),
             den_marca           LIKE clientes.den_marca,
             num_pri_volume      LIKE wfat_mestre.num_pri_volume,
             num_ult_volume      LIKE wfat_mestre.num_pri_volume,
             pes_tot_bruto       LIKE wfat_mestre.pes_tot_bruto,
             pes_tot_liquido     LIKE wfat_mestre.pes_tot_liquido,
             num_pedido          LIKE wfat_item.num_pedido,
             num_suframa         LIKE clientes.num_suframa,
             num_om              LIKE wfat_item.num_om,
             num_pedido_repres   CHAR(10),
             num_pedido_cli      CHAR(25),
             nat_oper            INTEGER,
             pct_icm             LIKE wfat_item_fiscal.pct_icm     
          END RECORD

   DEFINE pa_corpo_nff           ARRAY[999] OF RECORD 
             cod_item            CHAR(15),
             cod_item_cli        CHAR(13),
             num_lote            CHAR(15),
             num_pedido          LIKE wfat_item.num_pedido,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,
             den_item1           CHAR(060),
             den_item2           CHAR(060),
             den_item3           CHAR(060),
             den_item            CHAR(060),
             cod_fiscal          LIKE wfat_item_fiscal.cod_fiscal,
             cod_cla_fisc        CHAR(010),              
             cod_origem          LIKE wfat_mestre.cod_origem,
             cod_tributacao      LIKE wfat_mestre.cod_tributacao,
             pes_unit            LIKE wfat_item.pes_unit,
             cod_unid_med        CHAR(03),
             cod_unid_med_cli    LIKE wfat_item.cod_unid_med,
             qtd_item            DECIMAL(12,3),
             qtd_item_cli        LIKE wfat_item.qtd_item,
             pre_unit            DECIMAL(17,6),
             val_liq_item        DECIMAL(15,2),
             pct_icm             LIKE wfat_item_fiscal.pct_icm,
             valor_icm           LIKE wfat_item_fiscal.val_icm,
             pct_ipi             LIKE wfat_item.pct_ipi,
             val_ipi             LIKE wfat_item.val_ipi,
             val_icm_ret         LIKE wfat_item.val_icm_ret,
			 num_sequencia       LIKE wfat_item.num_sequencia,
             ies_tip_controle    CHAR(01)
          END RECORD

   DEFINE p_edi1
          RECORD
            tipo_registro    CHAR(01),
            num_nf           DECIMAL(6,0),
            ser_nf           CHAR(02),
            cnpj_emitente    CHAR(19),
            cnpj_destinat    CHAR(19),
            nome_destinat    CHAR(36),
            data_arquivo     CHAR(10),
            hora_arquivo     CHAR(19)
          END RECORD

   DEFINE p_ed1
          RECORD
            tipo_registro    CHAR(01),
            num_nf           DECIMAL(6,0),
            ser_nf           CHAR(02),
            cnpj_emitente    CHAR(14),
            cnpj_destinat    CHAR(14),
            nome_destinat    CHAR(36),
            data_arquivo     CHAR(08),
            hora_arquivo     CHAR(06)
          END RECORD
          
   DEFINE p_edi2
          RECORD
             tipo_registro       CHAR(01), 
             num_nf              DECIMAL(6,0),
             ser_nf              CHAR(02),
             cod_operacao        INTEGER,
             dat_emissao         CHAR(10),
             val_tot_nff         DECIMAL(17,0),
             val_tot_base_icm    DECIMAL(17,0),
             val_tot_icm         DECIMAL(17,0),
             val_base_icm_subst  DECIMAL(17,0),
             val_icm_subst       DECIMAL(17,0),
             val_tot_base_ipi    DECIMAL(17,0),
             val_tot_ipi         DECIMAL(17,0),
             val_frete           DECIMAL(17,0),
             val_seguro          DECIMAL(17,0),
             desp_acessorio      DECIMAL(17,0),
             peso_tot_liquido    DECIMAL(14,0),
             peso_tot_bruto      DECIMAL(14,0),
             qtd_volumes         DECIMAL(5,0),
             zeros_n1            DECIMAL(2,0),
             especie             CHAR(15),
             id_cancelamento     CHAR(01)
          END RECORD

   DEFINE p_ed2
          RECORD
             tipo_registro       CHAR(01), 
             num_nf              DECIMAL(6,0),
             ser_nf              CHAR(02),
             cod_operacao        INTEGER,
             dat_emissao         CHAR(08),
             val_tot_nff         DECIMAL(17,0),
             val_tot_base_icm    DECIMAL(17,0),
             val_tot_icm         DECIMAL(17,0),
             val_base_icm_subst  DECIMAL(17,0),
             val_icm_subst       DECIMAL(17,0),
             val_tot_base_ipi    DECIMAL(17,0),
             val_tot_ipi         DECIMAL(17,0),
             val_frete           DECIMAL(17,0),
             val_seguro          DECIMAL(17,0),
             desp_acessorio      DECIMAL(17,0),
             peso_tot_liquido    DECIMAL(14,0),
             peso_tot_bruto      DECIMAL(14,0),
             qtd_volumes         DECIMAL(5,0),
             zeros_n1            DECIMAL(2,0),
             especie             CHAR(15),
             id_cancelamento     CHAR(01)
          END RECORD
                          
   DEFINE p_edi3                 RECORD
          tipo_registro          CHAR(01),
          num_nf                 DECIMAL(6,0),
          ser_nf                 CHAR(02),          
          cod_item               CHAR(13),
          num_lote               CHAR(15),
          cod_unid_med           CHAR(11),
          qtd_item               DECIMAL(12,0),
          zeros_i1               DECIMAL(2,0), 
          pre_unit               DECIMAL(17,0),
          val_liq_item           DECIMAL(17,0),
          pct_icm                DECIMAL(5,0),
          valor_icm              DECIMAL(17,0),
          zeros_i2               DECIMAL(6,0),
          pct_ipi                DECIMAL(6,0),
          val_ipi                DECIMAL(17,0),          
          num_nf_retorno         DECIMAL(6,0),
          dat_nf_retorno         CHAR(10),
          cod_item_retorno       CHAR(13),
          observacao             CHAR(50),
          cod_operacao           INTEGER
          END RECORD

   DEFINE p_ed3                 RECORD
          tipo_registro          CHAR(01),
          num_nf                 DECIMAL(6,0),
          ser_nf                 CHAR(02),          
          cod_item               CHAR(13),
          num_lote               CHAR(15),
          cod_unid_med           CHAR(11),
          qtd_item               DECIMAL(12,0),
          zeros_i1               DECIMAL(2,0), 
          pre_unit               DECIMAL(17,0),
          val_liq_item           DECIMAL(17,0),
          pct_icm                DECIMAL(5,0),
          valor_icm              DECIMAL(17,0),
          zeros_i2               DECIMAL(6,0),
          pct_ipi                DECIMAL(6,0),
          val_ipi                DECIMAL(17,0),          
          num_nf_retorno         DECIMAL(6,0),
          dat_nf_retorno         CHAR(08),
          cod_item_retorno       CHAR(13),
          observacao             CHAR(50),
          cod_operacao           INTEGER
          END RECORD

   DEFINE p_edi4                 RECORD
          tipo_registro          CHAR(01),
          num_nf                 DECIMAL(6,0),
          ser_nf                 CHAR(02),          
          fim                    CHAR(06),
          qtde_notas             SMALLINT,
          vlr_total              DECIMAL(14,0)
          END RECORD
   
   DEFINE p_trailler
          RECORD
            tipo_registro    CHAR(01),
            num_nf           DECIMAL(6,0),
            ser_nf           CHAR(02),          
            fim              CHAR(06),
            qtde_notas       SMALLINT,
            vlr_total        DECIMAL(15,2)
          END RECORD

   DEFINE p_w_edi
          RECORD
            tipo_registro       CHAR(01),
            num_nf              DECIMAL(6,0),
            ser_nf              CHAR(02),
            cnpj_emitente       CHAR(19),
            cnpj_destinat       CHAR(19),
            nome_destinat       CHAR(36),
            data_arquivo        DATE,
            hora_arquivo        DATETIME HOUR TO SECOND,
            cod_operacao        INTEGER,
            dat_emissao         DATE,
            val_tot_nff         DECIMAL(15,2),
            val_tot_base_icm    DECIMAL(15,2),
            val_tot_icm         DECIMAL(15,2),
            val_base_icm_subst  DECIMAL(17,0),
            val_icm_subst       DECIMAL(17,0),
            val_tot_base_ipi    DECIMAL(15,2),
            val_tot_ipi         DECIMAL(15,2),
            val_frete           DECIMAL(17,0),
            val_seguro          DECIMAL(17,0),
            desp_acessorio      DECIMAL(17,0),
            peso_tot_liquido    DECIMAL(13,4),
            peso_tot_bruto      DECIMAL(13,4),
            qtd_volumes         DECIMAL(5,0),
            zeros_n1            DECIMAL(2,0),
            especie             CHAR(15),
            id_cancelamento     CHAR(01),
            cod_item            CHAR(13),
            num_lote            CHAR(15),
            cod_unid_med        CHAR(11),
            qtd_item            DECIMAL(12,3),
            zeros_i1            DECIMAL(2,0), 
            pre_unit            DECIMAL(17,6),
            val_liq_item        DECIMAL(15,2),
            pct_icm             DECIMAL(5,2),
            valor_icm           DECIMAL(15,2),
            zeros_i2            DECIMAL(6,0),
            pct_ipi             DECIMAL(6,3),
            val_ipi             DECIMAL(15,2),
            fim                 CHAR(06),
            qtde_notas          SMALLINT,
            vlr_total           DECIMAL(15,2),
            cod_item_retorno    CHAR(13),
            num_nf_retorno      DECIMAL(6,0),
            dat_nf_retorno      DATE,   
            observacao          CHAR(50) 
          END RECORD

   DEFINE cod_item_cli        LIKE cliente_item.tex_complementar,
          num_pedido          LIKE wfat_item.num_pedido,
          num_pedido_cli      LIKE pedidos.num_pedido_cli,
          cod_cla_fisc        CHAR(010),              
          cod_origem          LIKE wfat_mestre.cod_origem,
          cod_tributacao      LIKE wfat_mestre.cod_tributacao
          
   DEFINE p_fat_nf_mestre          RECORD LIKE fat_nf_mestre.*,
          p_fat_nf_item            RECORD LIKE fat_nf_item.*,
          p_fat_nf_item_fisc       RECORD LIKE fat_nf_item_fisc.*,
		      p_fat_mestre_fiscal      RECORD LIKE fat_mestre_fiscal.*,
          p_empresa                RECORD LIKE empresa.*,
          p_cidades                RECORD LIKE cidades.*,          
          p_embalagem              RECORD LIKE embalagem.*,
          p_clientes               RECORD LIKE clientes.*,
          p_paises                 RECORD LIKE paises.*,
          p_uni_feder              RECORD LIKE uni_feder.*,
          p_transport              RECORD LIKE clientes.*,
          p_fator_cv_unid          RECORD LIKE fator_cv_unid.*,  
          p_subst_trib_uf          RECORD LIKE subst_trib_uf.*,
          p_nat_operacao           RECORD LIKE nat_operacao.*,
          p_pedidos                RECORD LIKE pedidos.*,
          p_tipo_venda             RECORD LIKE tipo_venda.*,
          p_nf_referencia          RECORD LIKE nf_referencia.*,
          p_ctr_unid_med           RECORD LIKE ctr_unid_med.*,
          p_item_de_terc           RECORD LIKE item_de_terc.*,
          p_item_dev_terc          RECORD LIKE item_dev_terc.*,
          p_cli_ferrero_713        RECORD LIKE cli_ferrero_713.*          
          
   DEFINE g_cod_item_cliente   LIKE cliente_item.tex_complementar 

   DEFINE p_periodo_de          LIKE nf_mestre.dat_emissao,
          p_periodo_ate         LIKE nf_mestre.dat_emissao

   DEFINE p_notas_de            LIKE fat_nf_mestre.nota_fiscal,
          p_notas_ate           LIKE fat_nf_mestre.nota_fiscal
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0724-10.02.07"
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180 
   WHENEVER ERROR STOP
   DEFER INTERRUPT
   
   INITIALIZE p_caminho TO NULL
   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_caminho = p_caminho CLIPPED
   OPTIONS
      HELP FILE p_caminho

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN 
      CALL pol0724_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0724_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0724") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0724 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST) 

   MENU "OPCAO"
      COMMAND "Informar" "Informar parametros para solicitação de Ordem de Montagem."
         HELP 0100
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0724","IN") THEN
            CALL pol0724_informar() RETURNING p_status
         END IF
         NEXT OPTION "Processar"
      COMMAND "Processar" "Processa solicitação de Ordem de Montagem."
         HELP 0101
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0724","CO") THEN
            IF log004_confirm(16,30) THEN
               IF pol0724_processa_notas() THEN
                  IF p_fim = "S" THEN
                     ERROR "Processamento Efetuado com Sucesso"
                     CALL pol0724_exporta_header()
                     NEXT OPTION "Fim"
                  ELSE
                     ERROR "Nota/Item: ", p_fat_nf_mestre.nota_fiscal," / ",p_cod_item, " nao cadastrado na cliente_item. Programa Cancelado !!!"
                     NEXT OPTION "Fim"
                  END IF
               ELSE
                  IF p_fim = "N" THEN
                     ERROR "Nota/Item: ", p_fat_nf_mestre.nota_fiscal," / ",p_cod_item, " nao cadastrado na cliente_item. Programa Cancelado !!!"
                  ELSE
                     ERROR "Nao existem dados para serem processados !!!"
                  END IF
               END IF
            ELSE
               ERROR "Processamento Cancelado"
            END IF
         END IF
      COMMAND KEY("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle algo para continuar" FOR CHAR p_comando
	  COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol0724_sobre()
      COMMAND "Fim" "Retorna ao menu anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0724

END FUNCTION

#--------------------------#
FUNCTION pol0724_informar()
#--------------------------#

   LET p_houve_erro = FALSE
   
   IF pol0724_entrada_dados("INCLUSAO") THEN
   ELSE
      CLEAR FORM
      ERROR " Inclusao Cancelada. "
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
#-----------------------#
FUNCTION pol0724_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " LOGIX 10.02 \n\n",
               " Home page: www.aceex.com.br \n\n",
               " (0xx11) 4991-6667 \n\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
#---------------------------------------#
FUNCTION pol0724_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL  log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0724
   DISPLAY p_cod_empresa TO cod_empresa                        
   
   LET p_periodo_de          = TODAY
   LET p_periodo_ate         = TODAY
   LET p_notas_de            = 0
   LET p_notas_ate           = 999999
   LET p_caminho             = NULL
   INITIALIZE p_fat_nf_mestre.nota_fiscal to NULL

   DISPLAY p_caminho TO caminho ## limpa o campo
   DISPLAY p_fat_nf_mestre.nota_fiscal TO num_nff_process ## limpa o campo

   INPUT p_periodo_de,
         p_periodo_ate,         
         p_notas_de,
         p_notas_ate WITHOUT DEFAULTS

    FROM periodo_de,
         periodo_ate,
         notas_de,
         notas_ate      

   AFTER FIELD periodo_de
{      IF p_periodo_de IS NULL THEN
         ERROR 'Campo com preenchimento obrigatorio'
         NEXT FIELD periodo_de
      END IF
}
   AFTER FIELD periodo_ate
      IF p_periodo_ate IS NOT NULL THEN
         IF p_periodo_ate < p_periodo_de THEN
            ERROR 'Data Final < Data Inicial'
            NEXT FIELD periodo_de
         END IF
      END IF
            
   AFTER FIELD notas_de
{      IF p_tela.notas_de IS NULL THEN
         ERROR 'Campo com preenchimento obrigatorio'
         NEXT FIELD notas_de
      END IF      
}
   AFTER FIELD notas_ate
      IF p_notas_ate IS NOT NULL THEN
         IF p_notas_ate < p_notas_de THEN
            ERROR 'Número da NF final < número NF inicial'
            NEXT FIELD notas_de
         END IF      
      END IF
   END INPUT
 
   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0724

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF
   
END FUNCTION

#--------------------------------#
FUNCTION pol0724_processa_notas()
#--------------------------------#    

   CALL pol0724_cria_tabela_temporaria()
   
   CALL pol0724_busca_dados_empresa()

   LET p_conta_notas = 0
   LET p_soma_vlr_total = 0
   LET p_data_arquivo = TODAY
   LET p_hora_arquivo = TIME

   DECLARE cq_fat_mestre CURSOR FOR
    SELECT *
      FROM fat_nf_mestre
     WHERE empresa  = p_cod_empresa
       AND date(dat_hor_emissao) >= p_periodo_de
       AND date(dat_hor_emissao) <= p_periodo_ate
       AND nota_fiscal     >= p_notas_de
       AND nota_fiscal     <= p_notas_ate
       AND cliente IN (SELECT cod_cliente FROM cli_ferrero_713)
     ORDER BY nota_fiscal

   LET p_ies_situacao = NULL
   LET p_primeiro_header = "S"
      
   FOREACH cq_fat_mestre INTO p_fat_nf_mestre.*

      INITIALIZE pa_corpo_nff, p_nff TO NULL  
   
      
         DISPLAY p_fat_nf_mestre.nota_fiscal TO num_nff_process {mostra nf em processam.}

         LET p_nff.cod_cliente   = p_fat_nf_mestre.cliente
         LET p_nff.nat_oper      = p_fat_nf_mestre.natureza_operacao
         LET p_nff.num_nff       = p_fat_nf_mestre.nota_fiscal


		     SELECT cod_fiscal,
                aliquota
           INTO p_nff.cod_fiscal,
                p_nff.pct_icm 
           FROM FAT_NF_ITEM_FISC
          WHERE empresa = p_cod_empresa
		        AND tributo_benef = 'ICMS'
            AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal
			      AND seq_item_nf        = 1 
	
    		 IF sqlca.sqlcode = 100 THEN 
			      LET p_nff.cod_fiscal      = 0
			      LET p_nff.pct_icm         = 0
		     ELSE
			      IF sqlca.sqlcode <> 0 THEN 
				       CALL log003_err_sql("LEITURA 3","FAT_NF_ITEM_FISC")
			      END IF
		     END IF 	
	 
         SELECT serie_nota_fiscal,
                sit_nota_fiscal,
			          date(dat_hor_emissao)
           INTO p_serie_nf,
                p_ies_situacao,
				        p_nff.dat_emissao
           FROM fat_nf_mestre
          WHERE empresa = p_cod_empresa
            AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal

         LET p_nota   = p_fat_nf_mestre.nota_fiscal
         LET p_ser_nf = p_serie_nf[2,2]
         
         IF p_ies_situacao <> 'C' THEN
            LET p_ies_situacao = NULL
         END IF

         CALL pol0724_busca_dados_clientes()
  
         LET p_nff.nom_destinatario = p_clientes.nom_cliente
         LET p_nff.num_cgc_cpf      = p_clientes.num_cgc_cpf

         #IF p_primeiro_header = "S" THEN
            CALL pol0724_grava_header()
         #   LET p_primeiro_header = "N"
         #END IF
         
         LET p_nff.cod_cliente = p_clientes.cod_cliente

         IF p_clientes.ies_zona_franca = "S" OR
            p_clientes.ies_zona_franca = "A" OR
            p_nff.cod_fiscal = 6109 THEN
            LET p_nff.pct_icm = 0
         END IF   

         CALL pol0724_busca_dados_cidades(p_clientes.cod_cidade)
         LET p_nff.cod_uni_feder = p_cidades.cod_uni_feder

         CALL pol0724_carrega_corpo_nff() 

         IF p_fim = "N" THEN
            EXIT FOREACH
         END IF
         
         CALL pol0724_carrega_corpo_nota()
  
		     INITIALIZE p_fat_mestre_fiscal.* TO NULL 
         SELECT *
           INTO p_fat_mestre_fiscal.*
           FROM FAT_MESTRE_FISCAL
          WHERE empresa = p_cod_empresa
            AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal
			      AND tributo_benef = 'ICMS'

   		   IF sqlca.sqlcode = 100 THEN 
			      LET p_fat_mestre_fiscal.bc_tributo_tot       = 0
			      LET p_fat_mestre_fiscal.val_tributo_tot      = 0
		     ELSE
			      IF sqlca.sqlcode <> 0 THEN 
				       CALL log003_err_sql("LEITURA 2","FAT_MESTRE_FISCAL")
			      END IF
		     END IF 
  
         LET p_nff.val_tot_base_icm   = p_fat_mestre_fiscal.bc_tributo_tot
         LET p_nff.val_tot_icm        = p_fat_mestre_fiscal.val_tributo_tot

         IF p_nff.val_tot_icm = 0 THEN
            LET p_nff.val_tot_base_icm = 0
         END IF
 
		     INITIALIZE p_fat_mestre_fiscal.* TO NULL 
         SELECT *
           INTO p_fat_mestre_fiscal.*
           FROM FAT_MESTRE_FISCAL
          WHERE empresa = p_cod_empresa
            AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal
			      AND tributo_benef = 'IPI'

			
	       IF sqlca.sqlcode = 100 THEN 
		        LET p_fat_mestre_fiscal.val_tributo_tot = 0
	       ELSE
		        IF sqlca.sqlcode <> 0 THEN 
			         CALL log003_err_sql("LEITURA 2","FAT_MESTRE_FISCAL")
		        END IF
	       END IF 
 
         LET p_nff.val_tot_base_ret   = 0
         LET p_nff.val_tot_icm_ret    = 0
         LET p_nff.val_tot_mercadoria = p_fat_nf_mestre.val_mercadoria
         LET p_nff.val_frete_cli      = p_fat_nf_mestre.val_frete_cliente
         LET p_nff.val_seguro_cli     = p_fat_nf_mestre.val_seguro_cliente
         LET p_nff.val_tot_despesas   = 0
         LET p_nff.val_tot_base_ipi   = p_fat_nf_mestre.val_mercadoria
         LET p_nff.val_tot_ipi        = p_fat_mestre_fiscal.val_tributo_tot
         LET p_nff.val_tot_nff        = p_fat_nf_mestre.val_nota_fiscal
  
         LET p_nff.qtd_volumes		= 0
		 
           SELECT sum(qtd_volume)
           INTO p_nff.qtd_volumes	
           FROM FAT_NF_EMBALAGEM
          WHERE empresa = p_cod_empresa
            AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal
			
		 IF sqlca.sqlcode = 100 THEN 
			LET p_nff.qtd_volumes		= 0
		 ELSE
			 IF sqlca.sqlcode <> 0 THEN 
				CALL log003_err_sql("LEITURA","FAT_NF_EMBALAGEM")
			 END IF
		 END IF	 
		 
		 IF (p_nff.qtd_volumes	 IS NULL)  OR 
			(p_nff.qtd_volumes	 <=  0 )  THEN 
		    LET p_nff.qtd_volumes		= 0
			INITIALIZE  p_nff.des_especie1 TO NULL 
		 ELSE
			LET p_nff.des_especie1 = "VOLUME"
		 END IF	 
			
         LET p_nff.den_marca       = p_clientes.den_marca
         LET p_nff.pes_tot_bruto   = p_fat_nf_mestre.peso_bruto
         LET p_nff.pes_tot_liquido = p_fat_nf_mestre.peso_liquido
         LET p_nff.num_pedido      = p_fat_nf_item.pedido
         LET p_nff.num_suframa     = p_clientes.num_suframa
         LET p_nff.num_om          = p_fat_nf_item.ord_montag
 
         CALL pol0724_grava_cabec()       

   END FOREACH

   IF p_fim = "S" THEN
      CALL pol0724_grava_trailler()
      RETURN TRUE
   ELSE
      LET p_fim = "N"
      RETURN FALSE  
   END IF   

END FUNCTION

#--------------------------------------#
FUNCTION pol0724_carrega_ies_controle(p_ind)
#--------------------------------------#  
   DEFINE p_ind                SMALLINT

   INITIALIZE p_nat_operacao.ies_tip_controle  TO NULL 

     
   SELECT b.ies_tip_controle,
          a.aliquota,
          a.val_tributo_tot,
          a.cod_fiscal,
          a.tributacao,
		  a.origem_produto
     INTO pa_corpo_nff[p_ind].ies_tip_controle,
          pa_corpo_nff[p_ind].pct_icm,
          pa_corpo_nff[p_ind].valor_icm,
          pa_corpo_nff[p_ind].cod_fiscal,
          pa_corpo_nff[p_ind].cod_tributacao,
		  pa_corpo_nff[p_ind].cod_origem 
     FROM fat_nf_item_fisc a,
          nat_operacao b,
          fat_nf_item c
    WHERE a.empresa   		= p_cod_empresa
      AND a.trans_nota_fiscal  	= p_fat_nf_mestre.trans_nota_fiscal
      AND a.seq_item_nf   		= p_fat_nf_item.seq_item_nf
	  AND a.trans_nota_fiscal  	= c.trans_nota_fiscal
	  AND a.seq_item_nf   		= c.seq_item_nf
      AND c.natureza_operacao  	= b.cod_nat_oper
      AND a.empresa   			= c.empresa
	  AND a.tributo_benef		= 'ICMS'
	  
	                    
   IF SQLCA.SQLCODE <> 0 THEN 
      LET p_nat_operacao.ies_tip_controle  = 'N'
   END IF

END FUNCTION

#---------------------------#
FUNCTION pol0724_nf_benef(p_ind)
#---------------------------#
  DEFINE p_seq_nf    DEC(5,0),
         p_ind     smallint


   INITIALIZE p_num_nf,
              p_qtd_devolvida,
              p_num_nf_retorno,
              p_dat_nf_retorno,
              p_dat_emis_nf,
              p_cod_item,
              p_cod_unid_med,
              p_qtd_tot_recebida,
              p_val_remessa,
              p_val_icms,
              p_val_ipi TO NULL

		LET p_seq_nf = p_fat_nf_item.seq_item_nf
	
	    IF  p_nff.dat_emissao   <  '12/11/2012'  THEN 		
		    DECLARE cq_nf_item1 CURSOR FOR
		    SELECT num_sequencia
			  FROM NF_ITEM
			WHERE  COD_EMPRESA 	= '01'
			  AND  NUM_NFF		=  p_nff.num_nff
			  AND  COD_ITEM		=  p_fat_nf_item.item
			  AND  qtd_item		=  p_fat_nf_item.qtd_item		  
			FOREACH cq_nf_item1  INTO p_seq_nf 
				EXIT FOREACH
			END FOREACH
	   END IF 
	 
       DECLARE cq_retorno1 CURSOR FOR
       SELECT a.num_nf,
              a.qtd_devolvida, 
              a.num_nf_retorno,
              a.dat_emis_nf,
              b.dat_emis_nf,
              b.cod_item,
              b.cod_unid_med,
              b.qtd_tot_recebida,
              b.val_remessa,
              b.val_icms,
              b.val_ipi
         FROM item_dev_terc a,
              item_de_terc b
        WHERE a.cod_empresa      = p_cod_empresa
          AND a.num_nf_retorno   = p_nff.num_nff
          AND b.cod_empresa      = a.cod_empresa
          AND b.num_nf           = a.num_nf
          AND b.ser_nf           = a.ser_nf
          AND b.ssr_nf           = a.ssr_nf
          AND b.ies_especie_nf   = a.ies_especie_nf
          AND b.cod_fornecedor   = a.cod_fornecedor
          AND b.num_sequencia    = a.num_sequencia
          AND b.cod_item         = p_fat_nf_item.item
          AND a.num_sequencia_nf = p_seq_nf
		  AND a.dat_emis_nf      >= '01/09/2009'
		  AND b.dat_emis_nf      >= '01/09/2009'
   
      FOREACH cq_retorno1 INTO p_num_nf,
                               p_qtd_devolvida,
                               p_num_nf_retorno,
                               p_dat_nf_retorno,
                               p_dat_emis_nf,
                               p_cod_item,
                               p_cod_unid_med,
                               p_qtd_tot_recebida,
                               p_val_remessa,
                               p_val_icms,
                               p_val_ipi

         INSERT INTO nf_benef VALUES ( p_num_nf,
                                       p_qtd_devolvida,
                                       p_num_nf_retorno,
                                       p_dat_nf_retorno,
                                       p_dat_emis_nf,
                                       p_cod_item,
                                       p_cod_item,
                                       p_cod_unid_med,
                                       p_qtd_tot_recebida,
                                       p_val_remessa,
                                       p_val_icms,
                                       p_val_ipi,
                                       pa_corpo_nff[p_ind].cod_fiscal)									   
      END FOREACH

END FUNCTION

#--------------------------------#
FUNCTION pol0724_grava_header()
#--------------------------------#

      LET p_conta_notas = p_conta_notas + 1
      INSERT INTO w_edi VALUES ("H",
                                p_nff.num_nff,
                                p_ser_nf,
                                p_empresa.num_cgc,
                                p_nff.num_cgc_cpf,
                                p_nff.nom_destinatario,      
                                p_data_arquivo,
                                p_hora_arquivo,
                                NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                NULL,NULL,NULL,NULL,NULL,NULL,NULL)

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INSERÇÃO","TABELA-WNOTAS_H")
      END IF
   
   END FUNCTION
   
#-----------------------------#
FUNCTION pol0724_grava_cabec()
#-----------------------------#

   LET p_soma_vlr_total = p_soma_vlr_total + p_nff.val_tot_nff
   INSERT INTO w_edi VALUES ("N",
                              p_nff.num_nff,
                              p_ser_nf,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              p_nff.cod_fiscal,
                              p_nff.dat_emissao,                                
                              p_nff.val_tot_nff,
                              p_nff.val_tot_base_icm,
                              p_nff.val_tot_icm,
                              0,
                              0,
                              p_nff.val_tot_base_ipi,
                              p_nff.val_tot_ipi,
                              0,
                              0,
                              0,
                              p_nff.pes_tot_liquido,
                              p_nff.pes_tot_bruto,
                              p_nff.qtd_volumes,
                              0,
                              p_nff.des_especie1,
                              p_ies_situacao,
                              NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                              NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("INSERÇÃO","TABELA-WNOTAS_N")
     END IF
     
   END FUNCTION
   
#--------------------------------#
FUNCTION pol0724_grava_trailler()
#--------------------------------#

   INSERT INTO w_edi VALUES ("T",
                             NULL,
                             NULL,
                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                             NULL,NULL,NULL,NULL,NULL,
                             "FIM",
                             p_conta_notas,
                             p_soma_vlr_total,
                             NULL,NULL,NULL,NULL)
                             
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("INSERÇÃO","TABELA-trailler")
     END IF
   END FUNCTION

#-----------------------------------#
FUNCTION pol0724_carrega_corpo_nota()
#-----------------------------------#

   DEFINE i,j        SMALLINT,
          p_pes_unit LIKE item.pes_unit,    
          p_pes_tot  LIKE item.pes_unit

   LET p_num_seq = 0               

   FOR i = 1 TO 999

      IF pa_corpo_nff[i].cod_item     IS NULL AND
         pa_corpo_nff[i].cod_cla_fisc IS NULL AND
         pa_corpo_nff[i].pct_ipi      IS NULL AND 
         pa_corpo_nff[i].qtd_item     IS NULL AND
         pa_corpo_nff[i].pre_unit     IS NULL THEN
         CONTINUE FOR
      END IF

      IF pa_corpo_nff[i].ies_tip_controle = "3" then
         #p_fat_nf_item_fisc.cod_fiscal = '5902' OR
         #p_fat_nf_item_fisc.cod_fiscal = '6902' THEN 
         CONTINUE FOR
      END IF
      
      IF pa_corpo_nff[i].pct_ipi IS NULL THEN #ivo 12/03/2014
         LET pa_corpo_nff[i].pct_ipi = 0
      END IF
      
       INSERT INTO w_edi VALUES ("I",
                                p_nff.num_nff,
                                p_ser_nf,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                pa_corpo_nff[i].cod_fiscal,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                pa_corpo_nff[i].cod_item_cli,
                                pa_corpo_nff[i].num_lote,
                                pa_corpo_nff[i].cod_unid_med,
                                pa_corpo_nff[i].qtd_item,
                                "00",
                                pa_corpo_nff[i].pre_unit,
                                pa_corpo_nff[i].val_liq_item,
                                pa_corpo_nff[i].pct_icm,
                                pa_corpo_nff[i].valor_icm,
								pa_corpo_nff[i].num_sequencia,
#                                "000000",
                                pa_corpo_nff[i].pct_ipi,
                                pa_corpo_nff[i].val_ipi,
                                NULL,NULL,NULL,
                                NULL,NULL,NULL,NULL)

   END FOR
END FUNCTION

#------------------------------------------------#
FUNCTION pol0724_busca_dados_cidades(p_cod_cidade)
#------------------------------------------------#
   DEFINE p_cod_cidade     LIKE cidades.cod_cidade

   INITIALIZE p_cidades.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_cidades.*
     FROM cidades
    WHERE cod_cidade = p_cod_cidade
   WHENEVER ERROR STOP
END FUNCTION

#------------------------------------#
FUNCTION pol0724_busca_dados_empresa()            
#------------------------------------#
   INITIALIZE p_empresa.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT empresa.*
     INTO p_empresa.*
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   WHENEVER ERROR STOP
END FUNCTION

#----------------------------------------#
FUNCTION pol0724_cria_tabela_temporaria()
#----------------------------------------#

  WHENEVER ERROR CONTINUE
  CALL log085_transacao("BEGIN") 

   DROP TABLE w_edi;
   CREATE TEMP TABLE w_edi
   (
    tipo_registro         CHAR(01),
    num_nf                DECIMAL(6,0),
    ser_nf                CHAR(01),
    cnpj_emitente         CHAR(19),
    cnpj_destinat         CHAR(19),
    nome_destinat         CHAR(36),
    data_arquivo          DATE,
    hora_arquivo          DATETIME HOUR TO SECOND,
    cod_operacao          INTEGER,
    dat_emissao           DATE,
    val_tot_nff           DECIMAL(15,2),
    val_tot_base_icm      DECIMAL(15,2),
    val_tot_icm           DECIMAL(15,2),    
    val_base_icm_subst    DECIMAL(17,0),
    val_icm_subst         DECIMAL(17,0),
    val_tot_base_ipi      DECIMAL(15,2),
    val_tot_ipi           DECIMAL(15,2),
    val_frete             DECIMAL(17,0),
    val_seguro            DECIMAL(17,0),   
    desp_acessorio        DECIMAL(17,0),
    peso_tot_liquido      DECIMAL(13,4),
    peso_tot_bruto        DECIMAL(13,4),
    qtd_volumes           DECIMAL(5,0),
    zeros_n1              DECIMAL(2,0),
    especie               CHAR(15),
    id_cancelamento       CHAR(01),
    cod_item              CHAR(13),
    num_lote              CHAR(15),
    cod_unid_med          CHAR(11),
    qtd_item              DECIMAL(12,3),
    zeros_i1              DECIMAL(2,0),
    pre_unit              DECIMAL(17,6),
    val_liq_item          DECIMAL(15,2),
    pct_icm               DECIMAL(5,2),
    valor_icm             DECIMAL(15,2),
    zeros_i2              DECIMAL(6,0),
    pct_ipi               DECIMAL(6,3),
    val_ipi               DECIMAL(15,2),
    fim                   CHAR(06),
    qtde_notas            SMALLINT,
    vlr_total             DECIMAL(15,2),    
    cod_item_retorno      CHAR(13),
    num_nf_retorno        DECIMAL(6,0),
    dat_nf_retorno        DATE,
    observacao            CHAR(50)    
   );

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-w_edi")
   END IF
 

   DROP TABLE nf_benef;
   CREATE TEMP TABLE nf_benef
   (
    num_nf           DECIMAL(7,0),
    qtd_devolvida    DECIMAL(12,3),
    num_nf_retorno   DECIMAL(6,0),
    dat_nf_retorno   DATE, 
    dat_emis_nf      DATE,
    cod_item         CHAR(15),
    cod_item_retorno CHAR(15),
    cod_unid_med     CHAR(03),
    qtd_tot_recebida DECIMAL(12,3),
    val_remessa      DECIMAL(17,2),
    val_icms         DECIMAL(17,2),
    val_ipi          DECIMAL(17,2),
    cod_operacao     INTEGER
    );
    
   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-retorno")
   END IF
         
   CALL log085_transacao("COMMIT")         
   WHENEVER ERROR STOP

END FUNCTION

#--------------------------------------#
FUNCTION pol0724_busca_dados_clientes()
#--------------------------------------#

   INITIALIZE p_clientes.* TO NULL
   INITIALIZE p_cod_fornec_cliente TO NULL
   
   SELECT *
     INTO p_clientes.*
     FROM clientes
    WHERE cod_cliente = p_fat_nf_mestre.cliente
    
  SELECT cod_fornec_cliente
    INTO p_cod_fornec_cliente
    FROM cli_info_adic
   WHERE cod_cliente = p_fat_nf_mestre.cliente
   
END FUNCTION

#-----------------------#
 FUNCTION pol0724_help()
#-----------------------#
    OPTIONS HELP FILE p_caminho_help
    CASE
        WHEN INFIELD (periodo_de)  CALL showhelp(103)
        WHEN INFIELD (periodo_ate) CALL showhelp(104)
    END CASE
    CURRENT WINDOW IS w_pol0724
END FUNCTION

#----------------------------------#
FUNCTION pol0724_carrega_corpo_nff()
#----------------------------------#

   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli,
          p_hist_icms          LIKE vdp_excecao_icms.hist_icms,
          p_hist_excecao       LIKE vdp_exc_ipi_cli.hist_excecao
  
   DEFINE p_ind                SMALLINT,
          p_count              SMALLINT,
          sql_stmt             CHAR(2000)

   INITIALIZE p_fat_nf_item_fisc.* , 
              p_fat_nf_item.*   TO NULL

   LET p_ind   = 0 
   LET p_count = 0 

   DECLARE cq_fat_item CURSOR FOR 
    SELECT *
      FROM fat_nf_item 
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal
     ORDER BY seq_item_nf 

   FOREACH cq_fat_item INTO p_fat_nf_item.*

      LET p_ind = p_ind + 1
      IF p_ind > 999 THEN
         EXIT FOREACH
      END IF

      LET pa_corpo_nff[p_ind].cod_item      = p_fat_nf_item.item
      LET pa_corpo_nff[p_ind].num_sequencia = p_fat_nf_item.seq_item_nf
      LET pa_corpo_nff[p_ind].num_pedido    = p_fat_nf_item.pedido

      LET p_cod_item = p_fat_nf_item.item
      CALL pol0724_item_cliente()

      IF p_cod_item_cliente IS NULL THEN
         LET p_fim = "N"
         EXIT FOREACH
      ELSE
         LET p_fim = "S"
      END IF
      
      LET pa_corpo_nff[p_ind].cod_item_cli   = p_cod_item_cliente[1,13]
      LET pa_corpo_nff[p_ind].den_item1      = p_fat_nf_item.des_item[1,45]
      LET pa_corpo_nff[p_ind].num_pedido_cli = p_nff.num_pedido_cli
      LET p_pedido_cli                       = p_nff.num_pedido_cli

      CALL pol0724_carrega_pedido_cli()
      LET pa_corpo_nff[p_ind].num_pedido_cli = p_num_pedido_cli
    
      LET pa_corpo_nff[p_ind].cod_unid_med   = p_fat_nf_item.unid_medida
      LET pa_corpo_nff[p_ind].qtd_item       = p_fat_nf_item.qtd_item
      LET pa_corpo_nff[p_ind].pre_unit       = p_fat_nf_item.preco_unit_liquido
      LET pa_corpo_nff[p_ind].val_liq_item   = p_fat_nf_item.val_liquido_item
# LE IPI	

		INITIALIZE p_fat_nf_item_fisc.*  TO NULL
		 SELECT *
       INTO p_fat_nf_item_fisc.*
       FROM fat_nf_item_fisc
      WHERE empresa = p_cod_empresa
		    AND tributo_benef = 'IPI'
        AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal
			  AND seq_item_nf        = p_fat_nf_item.seq_item_nf
			
	 IF sqlca.sqlcode = 100 THEN 
		LET p_fat_nf_item_fisc.aliquota 	= 0 
		LET p_fat_nf_item_fisc.val_tributo_tot      = 0
	 ELSE
		 IF sqlca.sqlcode <> 0 THEN 
			CALL log003_err_sql("LEITURA IPI","FAT_NF_ITEM_FISC")
		 END IF
	 END IF
	
      LET pa_corpo_nff[p_ind].pct_ipi        = p_fat_nf_item_fisc.aliquota
      LET pa_corpo_nff[p_ind].val_ipi        = p_fat_nf_item_fisc.val_tributo_tot
# LE ICMS_RET	 

		INITIALIZE p_fat_nf_item_fisc.*  TO NULL
		
		 SELECT *
           INTO p_fat_nf_item_fisc.*
           FROM fat_nf_item_fisc
          WHERE empresa = p_cod_empresa
		    AND tributo_benef = 'ICMS_RET'
            AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal
			AND seq_item_nf        = p_fat_nf_item.seq_item_nf
			
	 IF sqlca.sqlcode = 100 THEN 
		LET p_fat_nf_item_fisc.aliquota 	= 0 
		LET p_fat_nf_item_fisc.val_tributo_tot      = 0
	 ELSE
		 IF sqlca.sqlcode <> 0 THEN 
			CALL log003_err_sql("LEITURA ICMS","FAT_NF_ITEM_FISC")
		 END IF
	 END IF
	  
      LET pa_corpo_nff[p_ind].val_icm_ret    = p_fat_nf_item_fisc.val_tributo_tot
      LET p_val_tot_ipi_acum                 = p_val_tot_ipi_acum + pa_corpo_nff[p_ind].val_ipi
      
      CALL pol0724_carrega_ies_controle(p_ind)

      IF pa_corpo_nff[p_ind].valor_icm  = 0 THEN
         LET pa_corpo_nff[p_ind].pct_icm = 0
      END IF
      
      IF pa_corpo_nff[p_ind].ies_tip_controle = "3"  OR
         pa_corpo_nff[p_ind].cod_fiscal = '5902' OR
         pa_corpo_nff[p_ind].cod_fiscal = '6902' THEN
         CALL pol0724_nf_benef(p_ind)
      END IF   

      # --- ROTINA PARA PEGAR NUM LOTE --- #
      INITIALIZE p_num_reserva TO NULL
      DECLARE cq_lote CURSOR FOR
      SELECT num_reserva  
        FROM ordem_montag_grade        
       WHERE cod_empresa = p_cod_empresa
         AND num_om      = p_fat_nf_item.ord_montag
         AND cod_item    = p_fat_nf_item.item         

       FOREACH cq_lote INTO p_num_reserva

          IF p_num_reserva IS NOT NULL OR
             p_num_reserva > 0 THEN
   
             INITIALIZE p_num_lote TO NULL
             SELECT num_lote 
               INTO p_num_lote
               FROM estoque_loc_reser
              WHERE cod_empresa = p_cod_empresa 
                AND num_reserva = p_num_reserva 

             IF SQLCA.sqlcode = 0 THEN
                IF pa_corpo_nff[p_ind].num_lote IS NOT NULL THEN
                   LET pa_corpo_nff[p_ind].num_lote = pa_corpo_nff[p_ind].num_lote CLIPPED,"/",p_num_lote CLIPPED
                ELSE
                   LET pa_corpo_nff[p_ind].num_lote = p_num_lote
                END IF
             END IF
          END IF 
       END FOREACH
       # ---  FIM --- # 

    END FOREACH

END FUNCTION
#-----------------------------------#
FUNCTION pol0724_carrega_pedido_cli()
#-----------------------------------# 

   DECLARE cq_trata CURSOR FOR
   SELECT * 
     FROM cli_ferrero_713
    WHERE cod_cliente = p_fat_nf_mestre.cliente
    ORDER BY cod_cliente
   
   FOREACH cq_trata INTO p_cli_ferrero_713.*
      EXIT FOREACH
   END FOREACH
         
   END FUNCTION

#-----------------------------#
FUNCTION pol0724_item_cliente()
#-----------------------------#

   INITIALIZE g_cod_item_cliente,
              p_cod_item_cliente TO NULL
 
   SELECT cod_item_cliente,
          tex_complementar
     INTO p_cod_item_cliente,
          g_cod_item_cliente
     FROM cliente_item
    WHERE cod_empresa        = p_cod_empresa
      AND cod_cliente_matriz = p_nff.cod_cliente
      AND cod_item           = p_cod_item
   
   IF SQLCA.sqlcode <> 0 THEN
      INITIALIZE g_cod_item_cliente,
                 p_cod_item_cliente TO NULL
   END IF
   
END FUNCTION

#--------------------------------#
 FUNCTION pol0724_exporta_header()
#--------------------------------#

   INITIALIZE p_edi1.* TO NULL
   INITIALIZE p_edi2.* TO NULL
   INITIALIZE p_edi3.* TO NULL
   INITIALIZE p_edi4.* TO NULL
   
   DECLARE cq_exp_header CURSOR FOR 
    SELECT num_nf
      FROM w_edi
     WHERE tipo_registro = 'N'
 
   FOREACH cq_exp_header INTO p_edi1.num_nf

      DECLARE cq_retorno4 CURSOR FOR 
       SELECT num_nf,
              SUM(qtd_devolvida),
              num_nf_retorno,
              dat_nf_retorno,
              dat_emis_nf,
              cod_item,
              cod_item_retorno,
              cod_unid_med,
              SUM(qtd_tot_recebida),
              SUM(val_remessa),
              val_icms,
              val_ipi,
              cod_operacao
         FROM nf_benef
        WHERE num_nf_retorno = p_edi1.num_nf
        GROUP BY num_nf,
                 num_nf_retorno,
                 dat_nf_retorno,
                 dat_emis_nf,
                 cod_item,
                 cod_item_retorno,
                 cod_unid_med,
                 val_icms,
                 val_ipi,
                 cod_operacao
              
      FOREACH cq_retorno4 INTO p_num_nf,
                               p_qtd_devolvida,
                               p_num_nf_retorno,
                               p_dat_nf_retorno,
                               p_dat_emis_nf,
                               p_cod_item,
                               p_cod_item_retorno,
                               p_cod_unid_med,
                               p_qtd_tot_recebida,
                               p_val_remessa,
                               p_val_icms,
                               p_val_ipi,
                               p_cod_operacao
             
         IF p_cod_item IS NOT NULL THEN
           
            CALL pol0724_item_cliente()
   
            LET p_observacao        = "materia prima beneficiada ref. s/nf: ", p_num_nf USING '&&&&&&'
            LET p_val_unitario      = 0
            LET p_val_liq_item      = 0
            LET p_val_unitario      = p_val_remessa / p_qtd_tot_recebida
            LET p_val_liq_item      = p_qtd_devolvida * p_val_unitario
            LET p_pct_icms          = ( p_val_liq_item / p_val_icms )
            LET p_pct_ipi           = ( p_val_liq_item / p_val_ipi )
            LET p_cod_itemc         = p_cod_item_cliente[1,13]
            LET p_cod_item_retornoc = p_cod_item_cliente[1,13]      

            INSERT INTO w_edi VALUES ("C",
                                      p_edi1.num_nf,
                                      p_ser_nf,
                                      NULL,NULL,NULL,NULL,NULL,
                                      p_cod_operacao,
                                      NULL,NULL,NULL,NULL,NULL,NULL,
                                      NULL,NULL,NULL,NULL,NULL,NULL,
                                      NULL,NULL,NULL,NULL,NULL,
                                      p_cod_itemc,
                                      NULL,
                                      p_cod_unid_med,
                                      p_qtd_devolvida,
                                      NULL,
                                      p_val_unitario,
                                      p_val_liq_item,
                                      p_pct_icms,
                                      p_val_icms,
                                      NULL,
                                      p_pct_ipi,
                                      p_val_ipi,
                                      NULL,NULL,NULL,
                                      p_cod_item_retornoc, 
                                      p_num_nf,
                                      p_dat_emis_nf,
                                      p_observacao)
         END IF
      END FOREACH
   END FOREACH
 
   CALL pol0724_gera_arq_txt()
   
   END FUNCTION
   
#--------------------------------#
 FUNCTION pol0724_gera_arq_txt()
#--------------------------------#

   DEFINE p_primeira_vez SMALLINT,
          p_minuto       SMALLINT,
          p_minuto_1     CHAR(02)          
              
   LET p_primeira_vez = 0
   
   LET p_data_arquivo = TODAY
   LET p_hora_arquivo = TIME
   LET p_destinatario = NULL
  
   LET p_data_arq = p_data_arquivo
   LET p_hora_arq = p_hora_arquivo  
   LET p_valor_total = 0
   LET p_qtde_notas  = 0

   LET p_data_rem = p_data_arq[7,10], p_data_arq[4,5],p_data_arq[1,2]
   LET p_data_tit = p_data_arq[1,2],  p_data_arq[4,5],p_data_arq[7,10]
   LET p_hora_rem = p_hora_arq[1,2],  p_hora_arq[4,5]
              
   SELECT diretorio
     INTO p_dir_ferrero_713
     FROM dir_ferrero_713
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      ERROR 'o arquivo TXT nao pode ser gerado!!!'
      RETURN 
   END IF
   
   SELECT COUNT(*)
     INTO p_contador
     FROM w_edi
   
   IF p_contador > 0 THEN
      LET p_compl = 'REM',p_data_tit,p_hora_rem,'.txt'
      LET p_caminho = p_dir_ferrero_713 CLIPPED, p_compl
      DISPLAY p_caminho TO caminho
      LET p_comeco = "S"
      START REPORT pol0724_header TO p_caminho
   ELSE
      RETURN
   END IF
     
   DECLARE cq_edi1 CURSOR FOR 
    SELECT tipo_registro,
           num_nf,
           ser_nf,
           cnpj_emitente,
           cnpj_destinat,
           nome_destinat,
           TO_CHAR(data_arquivo),
           TO_CHAR(hora_arquivo)
      FROM w_edi
     WHERE tipo_registro = 'H'
     ORDER BY num_nf
     
    FOREACH cq_edi1 INTO p_edi1.tipo_registro,
                        p_edi1.num_nf,
                        p_edi1.ser_nf,
                        p_edi1.cnpj_emitente,
                        p_edi1.cnpj_destinat,
                        p_edi1.nome_destinat

      LET p_primeira_vez = p_primeira_vez + 1
      IF p_destinatario <> p_edi1.cnpj_destinat AND
         p_primeira_vez <> 1 THEN
         
         FINISH REPORT pol0724_header

         LET p_valor_total  = 0
         LET p_qtde_notas   = 0
         LET p_data_arquivo = TODAY
         LET p_hora_arquivo = TIME
         LET p_minuto       = p_hora_arq[4,5] + p_primeira_vez
         LET p_minuto_1     = p_minuto

         LET p_data_arq = p_data_arquivo
         LET p_hora_arq = p_hora_arquivo

         LET p_data_rem = p_data_arq[7,10], p_data_arq[4,5],p_data_arq[1,2]
         LET p_data_tit = p_data_arq[1,2],  p_data_arq[4,5],p_data_arq[7,10]
         LET p_hora_rem = p_hora_arq[1,2],  p_minuto_1
         
         LET p_compl = 'REM',p_data_tit,p_hora_rem,'.txt'
         LET p_caminho = p_dir_ferrero_713 CLIPPED, p_compl
         DISPLAY p_caminho TO caminho
         START REPORT pol0724_header TO p_caminho

      END IF   
         
      LET p_edi1.data_arquivo = p_data_arquivo
      LET p_edi1.hora_arquivo = p_hora_arquivo
      
      LET p_nota_fiscal       = p_edi1.num_nf
      LET p_destinatario      = p_edi1.cnpj_destinat

      LET p_ed1.tipo_registro = p_edi1.tipo_registro
      LET p_ed1.num_nf        = p_edi1.num_nf
      LET p_ed1.ser_nf        = p_edi1.ser_nf
      LET p_ed1.cnpj_emitente = p_edi1.cnpj_emitente[2,3],p_edi1.cnpj_emitente[5,7],p_edi1.cnpj_emitente[9,11],
                                p_edi1.cnpj_emitente[13,16],p_edi1.cnpj_emitente[18,19]
                                 
      LET p_ed1.cnpj_destinat = p_edi1.cnpj_destinat[2,3],p_edi1.cnpj_destinat[5,7],p_edi1.cnpj_destinat[9,11],
                                p_edi1.cnpj_destinat[13,16],p_edi1.cnpj_destinat[18,19]
                                 
      LET p_ed1.nome_destinat = p_edi1.nome_destinat
      LET p_ed1.data_arquivo  = p_edi1.data_arquivo[7,10],p_edi1.data_arquivo[4,5],p_edi1.data_arquivo[1,2]
      LET p_ed1.hora_arquivo  = p_edi1.hora_arquivo[1,2],p_edi1.hora_arquivo[4,5],p_edi1.hora_arquivo[7,10]
      
      SELECT tipo_registro,
             num_nf,
             ser_nf,
             cod_operacao,
             TO_CHAR(dat_emissao),
             trunc(val_tot_nff,2) * 100,
             trunc(val_tot_base_icm,2) * 100,
             trunc(val_tot_icm,2) * 100,
             val_base_icm_subst,
             val_icm_subst,
             trunc(val_tot_base_ipi,2) * 100,
             trunc(val_tot_ipi,2) * 100,
             val_frete,
             val_seguro,
             desp_acessorio,
             replace(trunc(peso_tot_liquido,3),',',''),
             replace(trunc(peso_tot_bruto,3),',',''),
             replace(qtd_volumes,',',''),
             zeros_n1,
             especie,
             id_cancelamento

         INTO p_edi2.tipo_registro,
              p_edi2.num_nf,
              p_edi2.ser_nf,
              p_edi2.cod_operacao,
              p_edi2.dat_emissao,
              p_edi2.val_tot_nff,
              p_edi2.val_tot_base_icm,
              p_edi2.val_tot_icm,
              p_edi2.val_base_icm_subst,
              p_edi2.val_icm_subst,
              p_edi2.val_tot_base_ipi,
              p_edi2.val_tot_ipi,
              p_edi2.val_frete,
              p_edi2.val_seguro,
              p_edi2.desp_acessorio,
              p_edi2.peso_tot_liquido,
              p_edi2.peso_tot_bruto,
              p_edi2.qtd_volumes,
              p_edi2.zeros_n1,
              p_edi2.especie,
              p_edi2.id_cancelamento
         FROM w_edi          
        WHERE tipo_registro = 'N'
          AND num_nf        = p_edi1.num_nf
      
      LET p_ed2.dat_emissao = p_edi2.dat_emissao[1,2],p_edi2.dat_emissao[4,5],p_edi2.dat_emissao[7,10]
      LET p_qtde_notas      = p_qtde_notas + 1
      LET p_valor_total     = p_valor_total + p_edi2.val_tot_nff
	    LET p_zeros_i2        = 0 
	  
      DECLARE cq_edi3 CURSOR FOR
       SELECT tipo_registro,
              num_nf,
              ser_nf,
              cod_item,
              num_lote,
              cod_unid_med,
              replace(qtd_item,',',''),
              zeros_i1,
              replace(trunc(pre_unit,5),',',''),
              replace(trunc(val_liq_item,2),',',''),
              replace(pct_icm,',',''),
              replace(trunc(valor_icm),',',''),
              0,
              replace(trunc(pct_ipi,2),',',''),
              replace(trunc(val_ipi,2),',',''),
              num_nf_retorno,
              dat_nf_retorno,
              cod_item_retorno,
              observacao,
              cod_operacao
         FROM w_edi
        WHERE (tipo_registro = 'I' OR tipo_registro = 'C')
          AND num_nf         = p_edi1.num_nf
       ORDER BY tipo_registro desc, zeros_i2    asc

      FOREACH cq_edi3 INTO p_edi3.tipo_registro,
                           p_edi3.num_nf,
                           p_edi3.ser_nf,
                           p_edi3.cod_item,
                           p_edi3.num_lote,
                           p_edi3.cod_unid_med,
                           p_edi3.qtd_item,
                           p_edi3.zeros_i1,
                           p_edi3.pre_unit,
                           p_edi3.val_liq_item,
                           p_edi3.pct_icm,
                           p_edi3.valor_icm,
                           p_edi3.zeros_i2,
                           p_edi3.pct_ipi,
                           p_edi3.val_ipi,
                           p_edi3.num_nf_retorno,
                           p_edi3.dat_nf_retorno,
                           p_edi3.cod_item_retorno,
                           p_edi3.observacao,
                           p_edi3.cod_operacao

            LET p_ed3.dat_nf_retorno = p_edi3.dat_nf_retorno[1,2],p_edi3.dat_nf_retorno[4,5],p_edi3.dat_nf_retorno[7,10]
            LET p_zero = "0"
          
            OUTPUT TO REPORT pol0724_header()   

            LET p_nota_fiscal1  = p_edi3.num_nf
            LET p_destinatario1 = p_edi1.cnpj_destinat
   
      END FOREACH

   END FOREACH

   FINISH REPORT pol0724_header
   
END FUNCTION

#------------------------#
 REPORT pol0724_header()
#------------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0  
          BOTTOM MARGIN 0
          PAGE   LENGTH 1

  FORMAT
      FIRST PAGE HEADER 
          PRINT COLUMN 001, p_ed1.tipo_registro,
                            p_ed1.cnpj_emitente,
                            p_ed1.cnpj_destinat,
                            p_ed1.nome_destinat,"    ",
                            p_ed1.data_arquivo,
                            p_ed1.hora_arquivo

      ON EVERY ROW

      CASE 
          WHEN p_nota_fiscal <> p_nota_fiscal1 OR 
               p_comeco = "S"
             PRINT COLUMN 001, p_edi2.tipo_registro,
                               p_edi1.num_nf  USING "&&&&&&",
                               p_edi1.ser_nf,
                               p_edi2.cod_operacao USING "&&&&",
                               p_ed2.dat_emissao,
                               p_edi2.val_tot_nff        USING "&&&&&&&&&&&&&&&&&",               
                               p_edi2.val_tot_base_icm   USING "&&&&&&&&&&&&&&&&&",
                               p_edi2.val_tot_icm        USING "&&&&&&&&&&&&&&&&&",
                               p_edi2.val_base_icm_subst USING "&&&&&&&&&&&&&&&&&",
                               p_edi2.val_icm_subst      USING "&&&&&&&&&&&&&&&&&",
                               p_edi2.val_tot_base_ipi   USING "&&&&&&&&&&&&&&&&&",
                               p_edi2.val_tot_ipi        USING "&&&&&&&&&&&&&&&&&",
                               p_edi2.val_frete          USING "&&&&&&&&&&&&&&&&&",
                               p_edi2.val_seguro         USING "&&&&&&&&&&&&&&&&&",
                               p_edi2.desp_acessorio     USING "&&&&&&&&&&&&&&&&&",
                               p_edi2.peso_tot_liquido   USING "&&&&&&&&&&&&&&",
                               p_edi2.peso_tot_bruto     USING "&&&&&&&&&&&&&&",
                               p_edi2.qtd_volumes        USING "&&&&&&&&&&",
                               p_edi2.zeros_n1           USING "&&",
                               p_edi2.especie,
                               p_edi2.id_cancelamento
          LET p_comeco = "N"
     
     END CASE 

      CASE 
         WHEN p_edi3.tipo_registro = "I"
            PRINT COLUMN 001,p_edi3.tipo_registro,
                             p_edi3.num_nf            USING "&&&&&&",
                             p_edi3.ser_nf,
                             p_edi3.cod_item,
                             p_edi3.num_lote[1,6],
                             p_edi3.cod_unid_med,
                             p_edi3.qtd_item          USING "&&&&&&&&&&&",
                             p_edi3.zeros_i1          USING "&&",
                             p_edi3.pre_unit          USING "&&&&&&&&&&&&&&&&&",
                             p_edi3.val_liq_item      USING "&&&&&&&&&&&&&&&&&",
                             p_zero,
                             p_edi3.pct_icm           USING "&&&&&",
                             p_edi3.valor_icm         USING "&&&&&&&&&&&&&&&&&",
                             p_edi3.zeros_i2          USING "&&&&&&",
                             p_edi3.pct_ipi           USING "&&&&&&",
                             p_edi3.val_ipi           USING "&&&&&&&&&&&&&&&&&", 
                             p_edi3.cod_operacao      USING "&&&&"
             
          WHEN p_edi3.tipo_registro = "C"
             PRINT COLUMN 001,p_edi3.tipo_registro,
                              p_edi3.num_nf           USING "&&&&&&",
                              p_edi3.ser_nf,
                              p_edi3.cod_item,
                              p_edi3.num_nf_retorno   USING "&&&&&&",
                              p_ed3.dat_nf_retorno,
                              p_edi3.cod_item_retorno, 
                              p_edi3.qtd_item         USING "&&&&&&&&&&&",
                              p_edi3.cod_unid_med,
                              p_edi3.pre_unit         USING "&&&&&&&&&&&&&&&&&",
                              p_edi3.val_liq_item     USING "&&&&&&&&&&&&&&&&&",
                              p_edi3.observacao,
                              p_zero,
                              p_edi3.pct_icm          USING "&&&&&",
                              p_edi3.valor_icm        USING "&&&&&&&&&&&&&&&&&",
                              p_edi3.pct_ipi          USING "&&&&&&",
                              p_edi3.val_ipi          USING "&&&&&&&&&&&&&&&&&", 
                              p_edi3.cod_operacao     USING "&&&&"
       END CASE
     
       ON LAST ROW
       
               PRINT COLUMN 001, "T",
                                 "FIM   ",
                                 p_qtde_notas     USING "&&&&&&&&&&&&&&",
                                 p_valor_total    USING "&&&&&&&&&&&&&&"    
      
   END REPORT

#------------------------FIM DO PROGRAMA-----------------------------#
