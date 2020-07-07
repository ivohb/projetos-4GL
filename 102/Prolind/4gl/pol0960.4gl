#------------------------------------------------------------------------#
# SISTEMA.: SAIDAS                                                       #
# PROGRAMA: pol0960  - marcio.rebelo@prolind.com.br                      #
# OBJETIVO: Exportacao de dados para arquivo TXT - para EDI              #
# CLIENTE.: PROLIND                                                      #
# AUTOR...: IVO                                                          #
# DATA....: 04/08/09                                                     #
#------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_ies_tip_controle     LIKE nat_operacao.ies_tip_controle,
          p_tributo_benef        LIKE fat_nf_item_fisc.tributo_benef,
          p_nom_tela             CHAR(080),
          p_msg                  CHAR(300),
          p_houve_erro           SMALLINT,
          p_count                SMALLINT,
          p_status               SMALLINT,
          p_versao               CHAR(18),
          p_num_reserva          LIKE ordem_montag_grade.num_reserva,
          p_num_lote             CHAR(15),
          p_num_seq              SMALLINT,
          p_pedido_cli           CHAR(25),
          p_num_pedido_cli       CHAR(25),
          p_cod_fornec_cliente   CHAR(15),
          p_serie_nf             CHAR(02),
          p_val_tot_ipi_acum     DECIMAL(15,3),
          p_data_arquivo         DATE,
          p_hora_arquivo         DATETIME HOUR TO SECOND,
          p_diretorio_1054       CHAR(80),
          p_compl                CHAR(30),
          p_data_arq             CHAR(10),
          p_hora_arq             CHAR(19),
          p_data_rem             CHAR(08),
          p_hora_rem             CHAR(04),
          p_data_tit             CHAR(08),
          p_nota_fiscal          DECIMAL(6,0),
          p_nota_fiscal1         DECIMAL(6,0),
          p_contador             SMALLINT,
          p_ind                  SMALLINT,
          i                      SMALLINT,
		      p_prz_entrega          DATE 
                              
   DEFINE p_comando       CHAR(80),
          p_caminho       CHAR(80),
          p_caminho_a     CHAR(80),
          m_caminho       CHAR(80),
          p_caminho_help  CHAR(80)

   DEFINE p_nff       
          RECORD
             num_nff             DECIMAL(6,0),
             ser_nf              CHAR(02),
             den_nat_oper        LIKE nat_operacao.den_nat_oper, 
             cod_fiscal          LIKE fat_nf_item_fisc.cod_fiscal,
             cod_fiscal1         LIKE fat_nf_item_fisc.cod_fiscal,
             den_nat_oper1       LIKE nat_operacao.den_nat_oper, 
             ins_estadual_trib   LIKE subst_trib_uf.ins_estadual,
             ins_estadual_emp    LIKE empresa.ins_estadual,
             dat_emissao         DATE,
             nom_destinatario    CHAR(36),
             num_cgc_cpf         CHAR(19),
             dat_saida           DATE,
             cod_uni_feder       LIKE cidades.cod_uni_feder,
             cod_cliente         LIKE clientes.cod_cliente,

 { Corpo da nota contendo os itens da mesma. Pode conter ate 999 itens }

             val_tot_base_icm    DECIMAL(15,2),
             val_tot_icm         DECIMAL(15,2),
             val_tot_base_ret    DECIMAL(15,2),
             val_tot_icm_ret     DECIMAL(15,2),
             val_tot_mercadoria  DECIMAL(15,2),
             val_frete_cli       DECIMAL(15,2),
             val_seguro_cli      DECIMAL(15,2),
             val_tot_despesas    DECIMAL(15,2),
             val_tot_base_ipi    DECIMAL(15,2),
             val_tot_ipi         DECIMAL(15,2),
             val_tot_nff         DECIMAL(15,2),

             nom_transpor        LIKE clientes.nom_cliente,
             ies_frete           DECIMAL(1,0),
             num_placa           CHAR(7),
             cod_uni_feder_trans LIKE cidades.cod_uni_feder,
             num_pedido          INTEGER,
             num_suframa         LIKE clientes.num_suframa,
             num_om              INTEGER,
             num_pedido_repres   CHAR(10),
             num_pedido_cli      CHAR(25),
             nat_oper            INTEGER,
             pct_icm             DECIMAL(5,2)     
          END RECORD

   DEFINE pa_cod_see             ARRAY[999] OF RECORD 
          cod_see                CHAR(03)
   END RECORD
   
   DEFINE pa_corpo_nff           ARRAY[999] OF RECORD 
             cod_item            CHAR(15),
             cod_item_cli        CHAR(18),
             cod_item_cli1       DECIMAL(18,0),
             num_lote            CHAR(15),
             num_pedido          INTEGER,
             num_pedido_cli      CHAR(10),
             den_item1           CHAR(60),
             den_item2           CHAR(60),
             den_item3           CHAR(60),
             den_item            CHAR(60),
             cod_fiscal          INTEGER,
             cod_cla_fisc        CHAR(10),              
             cod_origem          DECIMAL(1,0),
             cod_tributacao      DECIMAL(2,0),
             pes_unit            DECIMAL(9,4),
             cod_unid_med        CHAR(03),
             cod_unid_med_cli    CHAR(3),
             qtd_item            DECIMAL(12,3),
             qtd_item_cli        DECIMAL(3,0),
             pre_unit            DECIMAL(17,6),
             val_liq_item        DECIMAL(15,2),
             pct_icm             DECIMAL(5,2),
             valor_icm           DECIMAL(15,2),
             pct_ipi             DECIMAL(5,2),
             val_ipi             DECIMAL(15,2),
             val_icm_ret         DECIMAL(15,2),
             num_sequencia       INTEGER,
             num_seq_pedido      CHAR(05),
             ies_tip_controle    CHAR(01),
			       prz_entrega         DATE,
             campo_numerico      CHAR(01)
          END RECORD

   DEFINE p_edi1
          RECORD
            data_arquivo        CHAR(10),
            hora_arquivo        CHAR(19),
            num_nf              DECIMAL(6,0),
            org_id_cliente      CHAR(05),
            buyer_plant_id      CHAR(15),
            numero_nf           DECIMAL(17,0),
            posicao_nf          CHAR(06),
            dat_emissao         CHAR(10),
            cod_item            CHAR(18),
            cod_item1           DECIMAL(18,0),
            num_lote            CHAR(10),
            num_sequencia       CHAR(05),
            qtd_item            CHAR(10),
            uom                 CHAR(03),
            pre_unit            CHAR(17),
            cod_unid_med        CHAR(09),
            moeda               CHAR(03),
            pct_ipi             CHAR(02),
            pct_icm             CHAR(02),
            val_ipi             CHAR(13),
            valor_icm           CHAR(13),
            nbm                 CHAR(10),
			      prz_entrega         CHAR(10),
            campo_numerico      CHAR(01)
          END RECORD

   DEFINE p_ed1
          RECORD
             num_nf           CHAR(06),
             data_arquivo     CHAR(08),
             hora_arquivo     CHAR(06)
          END RECORD
   
   DEFINE p_w_edi_1054
          RECORD
            num_nf              DECIMAL(6,0),
            org_id_cliente      CHAR(05),
            buyer_plant_id      CHAR(15),
            numero_nf           DECIMAL(6,0),
            posicao_nf          DECIMAL(5,0),
            dat_emissao         DATE,
            cod_item            CHAR(18),
            cod_item1           DECIMAL(18,0),
            num_lote            CHAR(10),
            num_sequencia       CHAR(05),
            qtd_item            DECIMAL(12,3),
            uom                 CHAR(03),
            pre_unit            DECIMAL(17,6),
            cod_unid_med        CHAR(03),
            moeda               CHAR(03),
            pct_ipi             DECIMAL(6,0),
            pct_icm             DECIMAL(6,0),
            val_ipi             DECIMAL(15,2),
            valor_icm           DECIMAL(15,2),
            nbm                 CHAR(10),
			      prz_entrega         CHAR(10),
            campo_numerico      CHAR(01)
          END RECORD

   DEFINE p_fat_nf_mestre          RECORD LIKE fat_nf_mestre.*,
          p_fat_nf_item            RECORD LIKE fat_nf_item.*,
          p_fat_nf_item_fisc       RECORD LIKE fat_nf_item_fisc.*,
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
          p_item_dev_terc          RECORD LIKE item_dev_terc.*

   DEFINE  p_cliente_1054           RECORD       
           cod_cliente char(15),
           cod_see     char(3)  
   END RECORD
            
   DEFINE p_cod_item_cliente      LIKE cliente_item.cod_item_cliente

   DEFINE p_periodo_de            DATE,
          p_periodo_ate           DATE,
          p_ser_nff               CHAR (02),
          p_ies_duplicata         CHAR(01)

   DEFINE p_notas_de              INTEGER,
          p_notas_ate             INTEGER
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0960-10.02.06"
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

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN 
      CALL pol0960_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0960_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0960") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0960 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST) 

   MENU "OPCAO"
      COMMAND "Informar" "Informar parametros para solicitação de Ordem de Montagem."
         HELP 0100
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0960","IN") THEN
            CALL pol0960_informar() RETURNING p_status
         END IF
         NEXT OPTION "Processar"
      COMMAND "Processar" "Processa solicitação de Ordem de Montagem."
         HELP 0101
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0960","CO") THEN
            IF log004_confirm(16,30) THEN
               IF pol0960_processa_notas() THEN
                  ERROR "Processamento Efetuado com Sucesso"
                  CALL pol0960_gera_arq_txt()
                  NEXT OPTION "Fim"
               ELSE
                  ERROR "Nao existem dados para serem processados !!!"
               END IF
            ELSE
               ERROR "Processamento Cancelado"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0960_sobre() 
      COMMAND KEY("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle algo para continuar" FOR CHAR p_comando
      COMMAND "Fim" "Retorna ao menu anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0960

END FUNCTION

#-----------------------#
FUNCTION pol0960_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#--------------------------#
FUNCTION pol0960_informar()
#--------------------------#

   LET p_houve_erro = FALSE
   
   IF pol0960_entrada_dados("INCLUSAO") THEN
   ELSE
      CLEAR FORM
      ERROR " Inclusao Cancelada. "
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------------#
FUNCTION pol0960_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL  log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0960
   DISPLAY p_cod_empresa TO cod_empresa                        

   INITIALIZE p_periodo_de,
              p_periodo_ate,         
              p_notas_de,
              p_notas_ate,
              p_ser_nff,
              p_caminho TO NULL
      
   DISPLAY p_caminho             TO caminho  
   
   LET p_periodo_de  = TODAY
   LET p_periodo_ate = TODAY
   LET p_notas_de    = 0
   LET p_notas_ate   = 999999
   LET p_ser_nff = '1'
   LET p_ies_duplicata = 'S'

   INPUT p_periodo_de,
         p_periodo_ate,         
         p_notas_de,
         p_notas_ate, p_ser_nff, p_ies_duplicata WITHOUT DEFAULTS

    FROM periodo_de,
         periodo_ate,
         notas_de,
         notas_ate, ser_nff, ies_duplicata     
   
   AFTER FIELD periodo_de
   
   AFTER FIELD periodo_ate
      IF p_periodo_ate IS NOT NULL THEN
         IF p_periodo_ate < p_periodo_de THEN
            ERROR 'Data Final < Data Inicial'
            NEXT FIELD periodo_de
         END IF
      END IF
            
   AFTER FIELD notas_de
   
   AFTER FIELD notas_ate
      IF p_notas_ate IS NOT NULL THEN
         IF p_notas_ate < p_notas_de THEN
            ERROR 'Número da NF final < número NF inicial'
            NEXT FIELD notas_de
         END IF      
      END IF
      
   AFTER FIELD ser_nff
      IF p_ser_nff IS NULL THEN
         ERROR "Campo com preenchimento obrigatório!"
         NEXT FIELD ser_nff
      END IF
 
   END INPUT
 
 
   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0960

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF
   
END FUNCTION

#--------------------------------#
FUNCTION pol0960_processa_notas()
#--------------------------------#    

   CALL pol0960_cria_tabela_temporaria()
   
   CALL pol0960_busca_dados_empresa()

   LET p_data_arquivo = TODAY
   LET p_hora_arquivo = TIME

   DECLARE cq_mestre CURSOR FOR
    SELECT *
      FROM fat_nf_mestre
     WHERE empresa  = p_cod_empresa
       AND DATE(dat_hor_emissao) >= p_periodo_de
       AND DATE(dat_hor_emissao) <= p_periodo_ate
       AND nota_fiscal       >= p_notas_de
       AND nota_fiscal       <= p_notas_ate
       AND serie_nota_fiscal  = p_ser_nff
       AND sit_nota_fiscal <> 'C'
       AND cliente IN(SELECT cod_cliente FROM cliente_1054)
     ORDER BY cliente, nota_fiscal
      
   FOREACH cq_mestre INTO p_fat_nf_mestre.*
      
      IF p_ies_duplicata = 'S' THEN
         IF p_fat_nf_mestre.val_duplicata > 0 THEN
         ELSE
            CONTINUE FOREACH
         END IF
      END IF
      
      INITIALIZE pa_corpo_nff, p_nff, pa_cod_see TO NULL  
   
     
         LET p_nff.cod_cliente   = p_fat_nf_mestre.cliente
         LET p_nff.nat_oper      = p_fat_nf_mestre.natureza_operacao
         LET p_nff.num_nff       = p_fat_nf_mestre.nota_fiscal
         LET p_nff.dat_emissao   = DATE(p_fat_nf_mestre.dat_hor_emissao)
         
         CALL pol0960_busca_dados_clientes()
  
         LET p_nff.nom_destinatario = p_clientes.nom_cliente
         LET p_nff.num_cgc_cpf      = p_clientes.num_cgc_cpf
         LET p_nff.cod_cliente = p_clientes.cod_cliente

         {LET p_nff.cod_fiscal    = p_wfat_mestre_ser.cod_fiscal
         LET p_nff.pct_icm       = p_wfat_mestre_ser.pct_icm

         IF p_clientes.ies_zona_franca = "S" OR
            p_clientes.ies_zona_franca = "A" OR
            p_nff.cod_fiscal = 6109 THEN
            LET p_nff.pct_icm = 0
         END IF} 

         CALL pol0960_busca_dados_cidades(p_clientes.cod_cidade)

         LET p_nff.cod_uni_feder = p_cidades.cod_uni_feder
         
         SELECT ies_tip_controle
           INTO p_ies_tip_controle
           FROM nat_operacao
          WHERE cod_nat_oper = p_fat_nf_mestre.natureza_operacao
         
         IF STATUS <> 0 THEN
            LET p_ies_tip_controle = 'N'
         END IF
           
         CALL pol0960_carrega_corpo_nff() 

         CALL pol0960_carrega_corpo_nota()
      
         {LET p_nff.val_tot_base_icm   = p_wfat_mestre_ser.val_tot_base_icm 
         LET p_nff.val_tot_icm        = p_wfat_mestre_ser.val_tot_icm

         IF p_nff.val_tot_icm = 0 THEN
            LET p_nff.val_tot_base_icm = 0
         END IF
 
         LET p_nff.val_tot_base_ret   = p_wfat_mestre_ser.val_tot_base_ret
         LET p_nff.val_tot_icm_ret    = p_wfat_mestre_ser.val_tot_icm_ret
         LET p_nff.val_tot_mercadoria = p_wfat_mestre_ser.val_tot_mercadoria
         LET p_nff.val_frete_cli      = p_wfat_mestre_ser.val_frete_cli
         LET p_nff.val_seguro_cli     = p_wfat_mestre_ser.val_seguro_cli
         LET p_nff.val_tot_despesas   = 0
         LET p_nff.val_tot_base_ipi   = p_wfat_mestre_ser.val_tot_mercadoria
         LET p_nff.val_tot_ipi        = p_wfat_mestre_ser.val_tot_ipi
         LET p_nff.val_tot_nff        = p_wfat_mestre_ser.val_tot_nff
         LET p_nff.num_pedido         = p_wfat_item_ser.num_pedido
         LET p_nff.num_suframa        = p_clientes.num_suframa
         LET p_nff.num_om             = p_wfat_item_ser.num_om}

   END FOREACH
   
   RETURN TRUE 

END FUNCTION


#-----------------------------------#
FUNCTION pol0960_carrega_corpo_nota()
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
	  
      INSERT INTO w_edi_1054 
         VALUES (p_nff.num_nff,
                 "SEE",                                              
                 pa_cod_see[i].cod_see,                       
                 p_nff.num_nff,                                     
                 pa_corpo_nff[i].num_sequencia,                     
                 p_nff.dat_emissao,                                 
                 pa_corpo_nff[i].cod_item_cli,                      
                 pa_corpo_nff[i].cod_item_cli1,                     
                 pa_corpo_nff[i].num_pedido_cli,                    
                 pa_corpo_nff[i].num_seq_pedido,                     
                 pa_corpo_nff[i].qtd_item,                          
                 pa_corpo_nff[i].cod_unid_med,                      
                 pa_corpo_nff[i].pre_unit,                          
                 "1",                                               
                 "BRL",                                             
                 pa_corpo_nff[i].pct_ipi,                           
                 pa_corpo_nff[i].pct_icm,                           
                 pa_corpo_nff[i].val_ipi,                           
                 pa_corpo_nff[i].valor_icm,                         
                 pa_corpo_nff[i].cod_cla_fisc,                      
								 pa_corpo_nff[i].prz_entrega,                      
                 pa_corpo_nff[i].campo_numerico)                    
   END FOR
   
END FUNCTION

#------------------------------------------------#
FUNCTION pol0960_busca_dados_cidades(p_cod_cidade)
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
FUNCTION pol0960_busca_dados_empresa()            
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
FUNCTION pol0960_cria_tabela_temporaria()
#----------------------------------------#

  WHENEVER ERROR CONTINUE
  CALL log085_transacao("BEGIN") 

   DROP TABLE w_edi_1054;
   CREATE TABLE w_edi_1054
   (
    num_nf              DECIMAL(6,0),
    org_id_cliente      CHAR(05),
    buyer_plant_id      CHAR(15),
    numero_nf           DECIMAL(17,0),
    posicao_nf          DECIMAL(5,0),
    dat_emissao         DATE,
    cod_item            CHAR(18),
    cod_item1           DECIMAL(18,0),
    num_lote            CHAR(10),
    num_sequencia       CHAR(05),
    qtd_item            DECIMAL(12,3),
    uom                 CHAR(03),
    pre_unit            DECIMAL(17,6),
    cod_unid_med        CHAR(03),
    moeda               CHAR(03),
    pct_ipi             DECIMAL(6,0),
    pct_icm             DECIMAL(6,0),
    val_ipi             DECIMAL(15,2),
    valor_icm           DECIMAL(15,2),
    nbm                 CHAR(10),
	  prz_entrega         DATE,
    campo_numerico      CHAR(01)
   );

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-w_edi_1054")
   END IF
         
   CALL log085_transacao("COMMIT")         
   WHENEVER ERROR STOP

END FUNCTION

#--------------------------------------#
FUNCTION pol0960_busca_dados_clientes()
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
 FUNCTION pol0960_help()
#-----------------------#
    OPTIONS HELP FILE p_caminho_help
    CASE
        WHEN INFIELD (periodo_de)  CALL showhelp(103)
        WHEN INFIELD (periodo_ate) CALL showhelp(104)
    END CASE
    CURRENT WINDOW IS w_pol0960
END FUNCTION

#----------------------------------#
FUNCTION pol0960_carrega_corpo_nff()
#----------------------------------#

   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli,
          p_hist_icms          LIKE vdp_excecao_icms.hist_icms,
          p_hist_excecao       LIKE vdp_exc_ipi_cli.hist_excecao
  
   DEFINE p_ind                SMALLINT,
          p_count              SMALLINT,
          sql_stmt             CHAR(2000),
          p_item_cli           CHAR(18),
          m_ind                SMALLINT,
          p_letra              CHAR(01),
          p_char               CHAR(01)

   INITIALIZE p_fat_nf_item_fisc, p_fat_nf_item TO NULL

   LET p_ind   = 0 
   LET p_count = 0 

   DECLARE cq_item CURSOR FOR 
    SELECT *
      FROM fat_nf_item 
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
     ORDER BY pedido, seq_item_pedido  

   FOREACH cq_item INTO p_fat_nf_item.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','fat_nf_item')
         RETURN FALSE
      END IF

      LET p_ind = p_ind + 1
      IF p_ind > 999 THEN
         EXIT FOREACH
      END IF
      
      SELECT cod_see
        INTO pa_cod_see[p_ind].cod_see   #ivo 14/01/14
        FROM cliente_1054
       WHERE cod_cliente = p_clientes.cod_cliente 
      
      LET pa_corpo_nff[p_ind].cod_item      = p_fat_nf_item.item
      LET pa_corpo_nff[p_ind].num_sequencia = p_ind
      LET pa_corpo_nff[p_ind].num_pedido    = p_fat_nf_item.pedido

      CALL pol0960_busca_dados_pedido()

      CALL pol0960_item_cliente()

      LET pa_corpo_nff[p_ind].cod_item_cli  = p_cod_item_cliente[1,18]
      LET pa_corpo_nff[p_ind].cod_item_cli1 = p_cod_item_cliente[1,18]
      
      LET p_item_cli = pa_corpo_nff[p_ind].cod_item_cli CLIPPED
      LET p_char = 'N'
      
      FOR m_ind = 1 to LENGTH(p_item_cli)
          LET p_letra = p_item_cli[m_ind]
          IF p_letra MATCHES '[0123456789]' THEN
          ELSE  
             LET p_char = 'S'
             EXIT FOR
          END IF
      END FOR
      
      
      IF p_char = 'N' THEN
         LET pa_corpo_nff[p_ind].cod_item_cli   = NULL
         LET pa_corpo_nff[p_ind].campo_numerico = "S"
      ELSE
         LET pa_corpo_nff[p_ind].cod_item_cli1  = NULL
         LET pa_corpo_nff[p_ind].campo_numerico = "N"
      END IF    
      
      LET pa_corpo_nff[p_ind].den_item1      = p_fat_nf_item.des_item[1,45]
      LET pa_corpo_nff[p_ind].num_pedido_cli = p_nff.num_pedido_cli[1,10]
      LET pa_corpo_nff[p_ind].num_seq_pedido = p_nff.num_pedido_cli[12,14]

      CALL pol0960_carrega_pedido_cli()
    
      LET pa_corpo_nff[p_ind].cod_cla_fisc = p_fat_nf_item.classif_fisc
      LET pa_corpo_nff[p_ind].cod_unid_med = p_fat_nf_item.unid_medida
      LET pa_corpo_nff[p_ind].qtd_item     = p_fat_nf_item.qtd_item
      LET pa_corpo_nff[p_ind].pre_unit     = p_fat_nf_item.preco_unit_liquido
      LET pa_corpo_nff[p_ind].val_liq_item = p_fat_nf_item.val_liquido_item
      LET pa_corpo_nff[p_ind].ies_tip_controle = p_ies_tip_controle

  	  CALL pol0960_busca_prz_entrega()

      IF p_prz_entrega IS NULL THEN 
         LET p_prz_entrega = p_nff.dat_emissao
	    END IF 
	  
      LET pa_corpo_nff[p_ind].prz_entrega = p_prz_entrega
 
      DECLARE cq_fisc CURSOR FOR
       SELECT bc_trib_mercadoria,
              val_trib_merc,
              tributacao,
              cod_fiscal,
              aliquota,
              origem_produto,
              tributo_benef
         FROM fat_nf_item_fisc
        WHERE empresa = p_cod_empresa
          AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
          AND seq_item_nf = p_fat_nf_item.seq_item_nf
          AND (tributo_benef = 'ICMS' OR tributo_benef = 'IPI')
      
      FOREACH cq_fisc INTO 
              p_fat_nf_item_fisc.bc_trib_mercadoria,  
              p_fat_nf_item_fisc.val_trib_merc,       
              p_fat_nf_item_fisc.tributacao,          
              p_fat_nf_item_fisc.cod_fiscal,          
              p_fat_nf_item_fisc.aliquota,            
              p_fat_nf_item_fisc.origem_produto,
              p_tributo_benef      

         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','fat_nf_item_fisc')
            RETURN FALSE
         END IF
         
         LET pa_corpo_nff[p_ind].cod_fiscal       = p_fat_nf_item_fisc.cod_fiscal
         LET pa_corpo_nff[p_ind].cod_origem       = p_fat_nf_item_fisc.origem_produto 
         LET pa_corpo_nff[p_ind].cod_tributacao   = p_fat_nf_item_fisc.tributacao
         
         IF p_tributo_benef = 'IPI' THEN
            LET pa_corpo_nff[p_ind].pct_ipi = p_fat_nf_item_fisc.aliquota
            LET pa_corpo_nff[p_ind].val_ipi = p_fat_nf_item_fisc.val_trib_merc
         ELSE
            IF p_tributo_benef = 'ICMS' THEN
               LET pa_corpo_nff[p_ind].pct_icm   = p_fat_nf_item_fisc.aliquota
               LET pa_corpo_nff[p_ind].valor_icm = p_fat_nf_item_fisc.val_trib_merc
            END IF
         END IF

      END FOREACH

    END FOREACH
    
END FUNCTION

#-----------------------------------#
FUNCTION pol0960_busca_dados_pedido()
#-----------------------------------#  

   INITIALIZE p_nff.num_pedido_repres,                       
              p_nff.num_pedido_cli   TO  NULL                    

   SELECT pedidos.num_pedido_repres, 
          pedidos.num_pedido_cli
     INTO p_nff.num_pedido_repres,
          p_nff.num_pedido_cli
     FROM pedidos
    WHERE pedidos.cod_empresa = p_fat_nf_item.empresa 
      AND pedidos.num_pedido  = p_fat_nf_item.pedido

END FUNCTION
#-----------------------------------#
FUNCTION pol0960_busca_prz_entrega()
#-----------------------------------#

   SELECT ped_itens.prz_entrega
     INTO p_prz_entrega
     FROM ped_itens 
    WHERE ped_itens.cod_empresa = p_fat_nf_item.empresa 
      AND ped_itens.num_pedido  = p_fat_nf_item.pedido
	  AND ped_itens.num_pedido    = p_fat_nf_item.seq_item_pedido
	  
	  IF STATUS <> 0 THEN
	     LET p_prz_entrega = NULL
	  END IF
	  
END FUNCTION

#-----------------------------------#
FUNCTION pol0960_carrega_pedido_cli()
#-----------------------------------# 

   DECLARE cq_trata CURSOR FOR
   SELECT * 
     FROM cliente_1054
    WHERE cod_cliente = p_fat_nf_mestre.cliente
    ORDER BY cod_cliente
   
   FOREACH cq_trata INTO p_cliente_1054.*
      EXIT FOREACH
   END FOREACH
         
   END FUNCTION

#-----------------------------#
FUNCTION pol0960_item_cliente()
#-----------------------------#

   INITIALIZE p_cod_item_cliente TO NULL
 
   SELECT cod_item_cliente
     INTO p_cod_item_cliente
     FROM cliente_item
    WHERE cod_empresa        = p_cod_empresa
      AND cod_cliente_matriz = p_nff.cod_cliente
      AND cod_item           = p_fat_nf_item.item

END FUNCTION
  
#--------------------------------#
 FUNCTION pol0960_gera_arq_txt()
#--------------------------------#

   DEFINE p_minuto       SMALLINT,
          p_minuto_1     CHAR(02)          
              
   LET p_data_arquivo = TODAY
   LET p_hora_arquivo = TIME
  
   LET p_data_arq = p_data_arquivo
   LET p_hora_arq = p_hora_arquivo  

   LET p_data_rem = p_data_arq[7,10], p_data_arq[4,5],p_data_arq[1,2]
   LET p_data_tit = p_data_arq[1,2],  p_data_arq[4,5],p_data_arq[7,10]
   LET p_hora_rem = p_hora_arq[1,2],  p_hora_arq[4,5]
              
   SELECT diretorio
     INTO p_diretorio_1054
     FROM diretorio_1054
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      ERROR 'o arquivo TXT nao pode ser gerado!!!'
      RETURN 
   END IF
   
   LET p_contador = 0

   SELECT COUNT(*)
     INTO p_contador
     FROM w_edi_1054

   IF p_contador > 0 THEN
      LET p_compl = 'REM',p_data_tit,p_hora_rem,'.txt'
      LET p_caminho = p_diretorio_1054 CLIPPED, p_compl
      DISPLAY p_caminho TO caminho
      START REPORT pol0960_header TO p_caminho
   ELSE
      ERROR " nao existem dados a serem gerados "
      RETURN
   END IF
     
   DECLARE cq_edi1 CURSOR FOR 
    SELECT num_nf,
           org_id_cliente,
           buyer_plant_id,
           numero_nf,
           posicao_nf,
           dat_emissao,
           cod_item,
           cod_item1,
           num_lote,
           num_sequencia,
           trunc(qtd_item,2),
           uom,
           replace(trunc(pre_unit,2),",","."),
           cod_unid_med,
           moeda,
           pct_ipi,
           pct_icm,
           replace(trunc(val_ipi,2),",","."),
           replace(trunc(valor_icm,2),",","."),
           nbm,
		       prz_entrega,
           campo_numerico
      FROM w_edi_1054

   FOREACH cq_edi1 INTO 
           p_edi1.num_nf,           
           p_edi1.org_id_cliente,                
           p_edi1.buyer_plant_id,                
           p_edi1.numero_nf,                     
           p_edi1.posicao_nf,                    
           p_edi1.dat_emissao,                   
           p_edi1.cod_item,                      
           p_edi1.cod_item1,                     
           p_edi1.num_lote,                      
           p_edi1.num_sequencia,                 
           p_edi1.qtd_item,                      
           p_edi1.uom,                           
           p_edi1.pre_unit,                      
           p_edi1.cod_unid_med,                  
           p_edi1.moeda,                         
           p_edi1.pct_ipi,                       
           p_edi1.pct_icm,                       
           p_edi1.val_ipi,                       
           p_edi1.valor_icm,                     
						p_edi1.nbm,                          
           p_edi1.prz_entrega,                   
           p_edi1.campo_numerico                 
      
      IF p_edi1.num_lote IS NULL THEN
         LET p_edi1.num_lote = "000000"
      END IF
      
      IF p_edi1.valor_icm IS NULL THEN
         LET p_edi1.valor_icm = "0000000000000"
      END IF

      LET p_edi1.data_arquivo = p_data_arquivo
      LET p_edi1.hora_arquivo = p_hora_arquivo
      LET p_nota_fiscal       = p_edi1.num_nf
      LET p_ed1.num_nf        = p_edi1.num_nf
      LET p_ed1.data_arquivo  = 
          p_edi1.data_arquivo[7,10],p_edi1.data_arquivo[4,5],p_edi1.data_arquivo[1,2]
      LET p_ed1.hora_arquivo  = 
          p_edi1.hora_arquivo[1,2],p_edi1.hora_arquivo[4,5],p_edi1.hora_arquivo[7,10]
      LET p_edi1.dat_emissao  = 
          p_edi1.dat_emissao[1,2],".",p_edi1.dat_emissao[4,5],".",p_edi1.dat_emissao[7,10]
	    LET p_edi1.prz_entrega  = 
	        p_edi1.prz_entrega[1,2],".",p_edi1.prz_entrega[4,5],".",p_edi1.prz_entrega[7,10]
         
      OUTPUT TO REPORT pol0960_header()   

   END FOREACH

   FINISH REPORT pol0960_header
   
END FUNCTION

#------------------------#
 REPORT pol0960_header()
#------------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0  
          BOTTOM MARGIN 0
          PAGE   LENGTH 1

  FORMAT

      ON EVERY ROW

         CASE 
            WHEN p_edi1.campo_numerico = "N"
               PRINT COLUMN 001, p_edi1.org_id_cliente CLIPPED,";",
                                 p_edi1.buyer_plant_id USING "&&",";",
                                 p_edi1.numero_nf  USING "<<<<<<<<<<<<<<<&&",";",
                                 p_edi1.posicao_nf USING "&&&&&",";",
                                 p_edi1.dat_emissao,";",
                                 p_edi1.dat_emissao,";",								 
                                 p_edi1.cod_item CLIPPED,";",";",
                                 p_edi1.num_lote CLIPPED,";","00",
                                 p_edi1.num_sequencia CLIPPED,";",";",";",";",
								 p_edi1.prz_entrega,";",
                                 p_edi1.qtd_item USING "<<<<<<<<<<",";", 
                                 p_edi1.uom CLIPPED,";",
                                 p_edi1.pre_unit CLIPPED,";",
                                 p_edi1.cod_unid_med CLIPPED,";",
                                 p_edi1.moeda,";",
                                 p_edi1.pct_ipi USING "&&",";",
                                 p_edi1.pct_icm USING "&&",";",
                                 p_edi1.val_ipi CLIPPED,";",
                                 p_edi1.valor_icm CLIPPED,";",
                                 p_edi1.nbm               USING "&&&&&&&&","00",";",
                                 ";",";",";",";",";",";",";",";",";",";",";",";",";",";",";",
                                 ";",";",";",";",";",";",";",";",";",";",";",";",";",";",";",
                                 ";",";",";",";",";",";",";"                                                              
            WHEN p_edi1.campo_numerico = "S"
               PRINT COLUMN 001, p_edi1.org_id_cliente CLIPPED,";",
                                 p_edi1.buyer_plant_id USING "&&",";",
                                 p_edi1.numero_nf  USING "<<<<<<<<<<<<<<<&&",";",
                                 p_edi1.posicao_nf USING "&&&&&",";",
                                 p_edi1.dat_emissao,";",
                                 p_edi1.dat_emissao,";",								 
                                 p_edi1.cod_item1 USING "&&&&&&&&&&&&&&&&&&",";",";",
                                 p_edi1.num_lote CLIPPED,";","00",
                                 p_edi1.num_sequencia CLIPPED,";",";",";",";",
								 p_edi1.prz_entrega,";",
                                 p_edi1.qtd_item USING "<<<<<<<<<<",";", 
                                 p_edi1.uom CLIPPED,";",
                                 p_edi1.pre_unit CLIPPED,";",
                                 p_edi1.cod_unid_med CLIPPED,";",
                                 p_edi1.moeda,";",
                                 p_edi1.pct_ipi USING "&&",";",
                                 p_edi1.pct_icm USING "&&",";",
                                 p_edi1.val_ipi CLIPPED,";",
                                 p_edi1.valor_icm CLIPPED,";",
                                 p_edi1.nbm               USING "&&&&&&&&","00",";",
                                 ";",";",";",";",";",";",";",";",";",";",";",";",";",";",";",
                                 ";",";",";",";",";",";",";",";",";",";",";",";",";",";",";",
                                 ";",";",";",";",";",";",";"                                                              
         END CASE
                                 
   END REPORT
#------------------------FIM DO PROGRAMA-----------------------------#
