#------------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                       #
# PROGRAMA: pol0793                                                      #
# OBJETIVO: Exportacao de dados para arquivo TXT - para EDI              #
# CLIENTE.: PROLIND                                                      #
# AUTOR...: POLO INFORMATICA - ANA PAULA QF                              #
# DATA....: 14/04/2008                                                   #
# ALTERADO: 14/04/2008 por Ana Paula - versao 09                         #
# ALTERADO: 11/07/2009 por Manuel - versao 10                            #
#------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_msg                  CHAR(300),
          p_nom_tela             CHAR(080),
          p_houve_erro           SMALLINT,
          p_count                SMALLINT,
          p_status               SMALLINT,
          p_versao               CHAR(18),
          p_ies_situacao         LIKE nf_mestre.ies_situacao,
          p_num_reserva          LIKE ordem_montag_grade.num_reserva,
          p_num_lote             CHAR(15),
          p_num_seq              SMALLINT,
          p_pedido_cli           CHAR(25),
          p_num_pedido_cli       CHAR(25),
          p_cod_fornec_cliente   CHAR(15),
          p_ser_nf               CHAR(01),
          p_serie_nf             CHAR(02),
          p_val_tot_ipi_acum     DECIMAL(15,3),
          p_data_arquivo         DATE,
          p_hora_arquivo         DATETIME HOUR TO SECOND,
          p_diretorio_1054       CHAR(40),
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
          i                      SMALLINT
                              
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
             cod_item_cli        CHAR(18),
             cod_item_cli1       DECIMAL(18,0),
             num_lote            CHAR(15),
             num_pedido          LIKE wfat_item.num_pedido,
             num_pedido_cli      CHAR(10),
             den_item1           CHAR(60),
             den_item2           CHAR(60),
             den_item3           CHAR(60),
             den_item            CHAR(60),
             cod_fiscal          LIKE wfat_item_fiscal.cod_fiscal,
             cod_cla_fisc        CHAR(10),              
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
             num_seq_pedido      CHAR(05),
             ies_tip_controle    CHAR(01),
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
            campo_numerico      CHAR(01)
          END RECORD

   DEFINE p_wfat_mestre            RECORD LIKE wfat_mestre.*,
          p_wfat_item              RECORD LIKE wfat_item.*,
          p_wfat_item_fiscal       RECORD LIKE wfat_item_fiscal.*,
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
          p_cliente_1054           RECORD LIKE cliente_1054.*          
          
   DEFINE p_cod_item_cliente      LIKE cliente_item.cod_item_cliente

   DEFINE p_periodo_de            LIKE nf_mestre.dat_emissao,
          p_periodo_ate           LIKE nf_mestre.dat_emissao,
          p_ser_nff               LIKE nf_mestre_ser.ser_nff

   DEFINE p_notas_de              LIKE nf_mestre.num_nff,
          p_notas_ate             LIKE nf_mestre.num_nff
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0793-10.02.01"
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
      CALL pol0793_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0793_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0793") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0793 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST) 

   MENU "OPCAO"
      COMMAND "Informar" "Informar parametros para solicitação de Ordem de Montagem."
         HELP 0100
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0793","IN") THEN
            CALL pol0793_informar() RETURNING p_status
         END IF
         NEXT OPTION "Processar"
      COMMAND "Processar" "Processa solicitação de Ordem de Montagem."
         HELP 0101
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0793","CO") THEN
            IF log004_confirm(16,30) THEN
               IF pol0793_processa_notas() THEN
                  ERROR "Processamento Efetuado com Sucesso"
                  CALL pol0793_gera_arq_txt()
                  NEXT OPTION "Fim"
               ELSE
                  ERROR "Nao existem dados para serem processados !!!"
               END IF
            ELSE
               ERROR "Processamento Cancelado"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0793_sobre() 
      COMMAND KEY("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle algo para continuar" FOR CHAR p_comando
      COMMAND "Fim" "Retorna ao menu anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0793

END FUNCTION

#-----------------------#
FUNCTION pol0793_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#--------------------------#
FUNCTION pol0793_informar()
#--------------------------#

   LET p_houve_erro = FALSE
   
   IF pol0793_entrada_dados("INCLUSAO") THEN
   ELSE
      CLEAR FORM
      ERROR " Inclusao Cancelada. "
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------------#
FUNCTION pol0793_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL  log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0793
   DISPLAY p_cod_empresa TO cod_empresa                        

   INITIALIZE p_periodo_de,
              p_periodo_ate,         
              p_notas_de,
              p_notas_ate,
              p_ser_nff,
              p_caminho,
              p_wfat_mestre.num_nff TO NULL
      
   DISPLAY p_caminho             TO caminho  
   DISPLAY p_wfat_mestre.num_nff TO num_nff_process {mostra nf em processam.}
   
   LET p_periodo_de  = TODAY
   LET p_periodo_ate = TODAY
   LET p_notas_de    = 0
   LET p_notas_ate   = 999999

   INPUT p_periodo_de,
         p_periodo_ate,         
         p_notas_de,
         p_notas_ate WITHOUT DEFAULTS

    FROM periodo_de,
         periodo_ate,
         notas_de,
         notas_ate      

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
   END INPUT
 
   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0793

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF
   
END FUNCTION

#--------------------------------#
FUNCTION pol0793_processa_notas()
#--------------------------------#    

   CALL pol0793_cria_tabela_temporaria()
   
   CALL pol0793_busca_dados_empresa()

   LET p_data_arquivo = TODAY
   LET p_hora_arquivo = TIME

   DECLARE cq_wfat_mestre CURSOR FOR
    SELECT *
      FROM wfat_mestre
     WHERE cod_empresa  = p_cod_empresa
       AND dat_emissao >= p_periodo_de
       AND dat_emissao <= p_periodo_ate
       AND num_nff     >= p_notas_de
       AND num_nff     <= p_notas_ate
       AND cod_cliente IN(SELECT cod_cliente
        FROM cliente_1054)
     ORDER BY cod_cliente,num_nff

   LET p_ies_situacao = NULL
      
   FOREACH cq_wfat_mestre INTO p_wfat_mestre.*

      INITIALIZE pa_corpo_nff, p_nff TO NULL  
   
     
         DISPLAY p_wfat_mestre.num_nff TO num_nff_process {mostra nf em processam.}

         LET p_nff.cod_cliente   = p_wfat_mestre.cod_cliente
         LET p_nff.nat_oper      = p_wfat_mestre.cod_nat_oper
         LET p_nff.cod_fiscal    = p_wfat_mestre.cod_fiscal
         LET p_nff.num_nff       = p_wfat_mestre.num_nff
         LET p_nff.pct_icm       = p_wfat_mestre.pct_icm

         SELECT ser_nff,
                ies_situacao
           INTO p_serie_nf,
                p_ies_situacao
           FROM nf_mestre
          WHERE cod_empresa = p_cod_empresa
            AND num_nff     = p_wfat_mestre.num_nff

         LET p_ser_nf = p_serie_nf[2,2]
         
         IF p_ies_situacao <> 'C' THEN
            LET p_ies_situacao = NULL
         END IF

         LET p_nff.dat_emissao = p_wfat_mestre.dat_emissao

         CALL pol0793_busca_dados_clientes()
  
         LET p_nff.nom_destinatario = p_clientes.nom_cliente
         LET p_nff.num_cgc_cpf      = p_clientes.num_cgc_cpf

         LET p_nff.cod_cliente = p_clientes.cod_cliente

         IF p_clientes.ies_zona_franca = "S" OR
            p_clientes.ies_zona_franca = "A" OR
            p_nff.cod_fiscal = 6109 THEN
            LET p_nff.pct_icm = 0
         END IF   

         CALL pol0793_busca_dados_cidades(p_clientes.cod_cidade)

         LET p_nff.cod_uni_feder = p_cidades.cod_uni_feder

         CALL pol0793_carrega_corpo_nff() 

         CALL pol0793_carrega_corpo_nota()
      
         LET p_nff.val_tot_base_icm   = p_wfat_mestre.val_tot_base_icm 
         LET p_nff.val_tot_icm        = p_wfat_mestre.val_tot_icm

         IF p_nff.val_tot_icm = 0 THEN
            LET p_nff.val_tot_base_icm = 0
         END IF
 
         LET p_nff.val_tot_base_ret   = p_wfat_mestre.val_tot_base_ret
         LET p_nff.val_tot_icm_ret    = p_wfat_mestre.val_tot_icm_ret
         LET p_nff.val_tot_mercadoria = p_wfat_mestre.val_tot_mercadoria
         LET p_nff.val_frete_cli      = p_wfat_mestre.val_frete_cli
         LET p_nff.val_seguro_cli     = p_wfat_mestre.val_seguro_cli
         LET p_nff.val_tot_despesas   = 0
         LET p_nff.val_tot_base_ipi   = p_wfat_mestre.val_tot_mercadoria
         LET p_nff.val_tot_ipi        = p_wfat_mestre.val_tot_ipi
         LET p_nff.val_tot_nff        = p_wfat_mestre.val_tot_nff
         LET p_nff.num_pedido         = p_wfat_item.num_pedido
         LET p_nff.num_suframa        = p_clientes.num_suframa
         LET p_nff.num_om             = p_wfat_item.num_om

   END FOREACH
   RETURN TRUE 

END FUNCTION

#--------------------------------------#
FUNCTION pol0793_carrega_ies_controle()
#--------------------------------------#  

   INITIALIZE p_nat_operacao.ies_tip_controle  TO NULL 

   SELECT b.ies_tip_controle,            
          a.pct_icm,
          sum(a.val_icm),
          a.cod_fiscal,
          a.cod_tributacao
     INTO p_nat_operacao.ies_tip_controle,
          p_wfat_item_fiscal.pct_icm,
          p_wfat_item_fiscal.val_icm,
          p_wfat_item_fiscal.cod_fiscal,
          p_wfat_item_fiscal.cod_tributacao
     FROM wfat_item_fiscal a,
          nat_operacao b,
          wfat_item c
    WHERE a.cod_empresa   = p_cod_empresa
      AND a.num_nff       = p_wfat_item.num_nff
      AND a.num_pedido    = p_wfat_item.num_pedido
      AND a.num_sequencia = p_wfat_item.num_sequencia 
      AND a.cod_nat_oper  = b.cod_nat_oper
      AND a.cod_empresa   = c.cod_empresa
      AND a.num_nff       = c.num_nff
      AND a.num_pedido    = c.num_pedido
      AND a.num_sequencia = c.num_sequencia
    GROUP BY 1, 2, 4, 5  
                    
   IF SQLCA.SQLCODE <> 0 THEN 
      LET p_nat_operacao.ies_tip_controle  = 'N'
   END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol0793_carrega_corpo_nota()
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
      
      INSERT INTO w_edi_1054 VALUES (p_nff.num_nff,
                                     "SEE",
                                     "07",
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
                                     pa_corpo_nff[i].campo_numerico)
   END FOR
END FUNCTION

#------------------------------------------------#
FUNCTION pol0793_busca_dados_cidades(p_cod_cidade)
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
FUNCTION pol0793_busca_dados_empresa()            
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
FUNCTION pol0793_cria_tabela_temporaria()
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
    campo_numerico      CHAR(01)
   );

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-w_edi_1054")
   END IF
         
   CALL log085_transacao("COMMIT")         
   WHENEVER ERROR STOP

END FUNCTION

#--------------------------------------#
FUNCTION pol0793_busca_dados_clientes()
#--------------------------------------#

   INITIALIZE p_clientes.* TO NULL
   INITIALIZE p_cod_fornec_cliente TO NULL
   
   SELECT *
     INTO p_clientes.*
     FROM clientes
    WHERE cod_cliente = p_wfat_mestre.cod_cliente
    
  SELECT cod_fornec_cliente
    INTO p_cod_fornec_cliente
    FROM cli_info_adic
   WHERE cod_cliente = p_wfat_mestre.cod_cliente
   
END FUNCTION

#-----------------------#
 FUNCTION pol0793_help()
#-----------------------#
    OPTIONS HELP FILE p_caminho_help
    CASE
        WHEN INFIELD (periodo_de)  CALL showhelp(103)
        WHEN INFIELD (periodo_ate) CALL showhelp(104)
    END CASE
    CURRENT WINDOW IS w_pol0793
END FUNCTION

#----------------------------------#
FUNCTION pol0793_carrega_corpo_nff()
#----------------------------------#

   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli,
          p_hist_icms          LIKE vdp_excecao_icms.hist_icms,
          p_hist_excecao       LIKE vdp_exc_ipi_cli.hist_excecao
  
   DEFINE p_ind                SMALLINT,
          p_count              SMALLINT,
          sql_stmt             CHAR(2000)

   INITIALIZE p_wfat_item_fiscal.* TO NULL

   LET p_ind   = 0 
   LET p_count = 0 

   DECLARE cq_wfat_item CURSOR FOR 
    SELECT *
      FROM wfat_item 
     WHERE cod_empresa = p_cod_empresa
       AND num_nff     = p_wfat_mestre.num_nff
     ORDER BY num_pedido,num_sequencia  

   FOREACH cq_wfat_item INTO p_wfat_item.*

      LET p_ind = p_ind + 1
      IF p_ind > 999 THEN
         EXIT FOREACH
      END IF

      LET pa_corpo_nff[p_ind].cod_item      = p_wfat_item.cod_item
      LET pa_corpo_nff[p_ind].num_sequencia = p_ind
      LET pa_corpo_nff[p_ind].num_pedido    = p_wfat_item.num_pedido

      CALL pol0793_busca_dados_pedido()

      CALL pol0793_item_cliente()

      LET pa_corpo_nff[p_ind].cod_item_cli  = p_cod_item_cliente[1,18]
      LET pa_corpo_nff[p_ind].cod_item_cli1 = p_cod_item_cliente[1,18]
 
      IF pa_corpo_nff[p_ind].cod_item_cli[1,1] = "0" OR
         pa_corpo_nff[p_ind].cod_item_cli[1,1] = "1" OR
         pa_corpo_nff[p_ind].cod_item_cli[1,1] = "2" OR
         pa_corpo_nff[p_ind].cod_item_cli[1,1] = "3" OR
         pa_corpo_nff[p_ind].cod_item_cli[1,1] = "4" OR
         pa_corpo_nff[p_ind].cod_item_cli[1,1] = "5" OR
         pa_corpo_nff[p_ind].cod_item_cli[1,1] = "6" OR
         pa_corpo_nff[p_ind].cod_item_cli[1,1] = "7" OR
         pa_corpo_nff[p_ind].cod_item_cli[1,1] = "8" OR
         pa_corpo_nff[p_ind].cod_item_cli[1,1] = "9" THEN
         
         LET pa_corpo_nff[p_ind].cod_item_cli   = NULL
         LET pa_corpo_nff[p_ind].campo_numerico = "S"
      ELSE
         LET pa_corpo_nff[p_ind].cod_item_cli1  = NULL
         LET pa_corpo_nff[p_ind].campo_numerico = "N"
      END IF
    
      
      LET pa_corpo_nff[p_ind].den_item1      = p_wfat_item.den_item[1,45]
      LET pa_corpo_nff[p_ind].num_pedido_cli = p_nff.num_pedido_cli[1,10]
      LET pa_corpo_nff[p_ind].num_seq_pedido = p_nff.num_pedido_cli[12,14]

      #LET pa_corpo_nff[p_ind].num_pedido_cli = p_nff.num_pedido_cli
      #LET p_pedido_cli                       = p_nff.num_pedido_cli

      CALL pol0793_carrega_pedido_cli()
    
      LET pa_corpo_nff[p_ind].cod_unid_med = p_wfat_item.cod_unid_med  
      LET pa_corpo_nff[p_ind].qtd_item     = p_wfat_item.qtd_item
      LET pa_corpo_nff[p_ind].pre_unit     = p_wfat_item.pre_unit_nf
      LET pa_corpo_nff[p_ind].val_liq_item = p_wfat_item.val_liq_item
      #(p_wfat_item.val_liq_item * p_wfat_item_fiscal.pct_icm) /100

      IF p_wfat_mestre.val_tot_icm       = 0 OR
         p_wfat_mestre.val_tot_base_icm  = 0 THEN
         LET pa_corpo_nff[p_ind].pct_icm = 0
      END IF

      LET pa_corpo_nff[p_ind].pct_ipi        = p_wfat_item.pct_ipi
      LET pa_corpo_nff[p_ind].val_ipi        = p_wfat_item.val_ipi
      LET pa_corpo_nff[p_ind].val_icm_ret    = p_wfat_item.val_icm_ret
      LET pa_corpo_nff[p_ind].cod_cla_fisc   = p_wfat_item.cod_cla_fisc

      LET p_val_tot_ipi_acum                 = p_val_tot_ipi_acum + p_wfat_item.val_ipi
      
      CALL pol0793_carrega_ies_controle()
      LET pa_corpo_nff[p_ind].ies_tip_controle = p_nat_operacao.ies_tip_controle
      LET pa_corpo_nff[p_ind].pct_icm          = p_wfat_item_fiscal.pct_icm
      LET pa_corpo_nff[p_ind].cod_fiscal       = p_wfat_item_fiscal.cod_fiscal 
      LET pa_corpo_nff[p_ind].cod_origem       = p_wfat_item_fiscal.cod_origem
      LET pa_corpo_nff[p_ind].cod_tributacao   = p_wfat_item_fiscal.cod_tributacao
      LET pa_corpo_nff[p_ind].valor_icm        = p_wfat_item_fiscal.val_icm

    END FOREACH
    
END FUNCTION

#-----------------------------------#
FUNCTION pol0793_busca_dados_pedido()
#-----------------------------------#  

   INITIALIZE p_nff.num_pedido_repres,                       
              p_nff.num_pedido_cli   TO  NULL                    

   SELECT pedidos.num_pedido_repres, 
          pedidos.num_pedido_cli
     INTO p_nff.num_pedido_repres,
          p_nff.num_pedido_cli
     FROM pedidos
    WHERE pedidos.cod_empresa = p_wfat_mestre.cod_empresa 
      AND pedidos.num_pedido  = p_wfat_item.num_pedido

END FUNCTION

#-----------------------------------#
FUNCTION pol0793_carrega_pedido_cli()
#-----------------------------------# 

   DECLARE cq_trata CURSOR FOR
   SELECT * 
     FROM cliente_1054
    WHERE cod_cliente = p_wfat_mestre.cod_cliente
    ORDER BY cod_cliente
   
   FOREACH cq_trata INTO p_cliente_1054.*
      EXIT FOREACH
   END FOREACH
         
   END FUNCTION

#-----------------------------#
FUNCTION pol0793_item_cliente()
#-----------------------------#

   INITIALIZE p_cod_item_cliente TO NULL
 
   SELECT cod_item_cliente
     INTO p_cod_item_cliente
     FROM cliente_item
    WHERE cod_empresa        = p_cod_empresa
      AND cod_cliente_matriz = p_nff.cod_cliente
      AND cod_item           = p_wfat_item.cod_item

END FUNCTION
  
#--------------------------------#
 FUNCTION pol0793_gera_arq_txt()
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
      START REPORT pol0793_header TO p_caminho
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
           campo_numerico
      FROM w_edi_1054

   FOREACH cq_edi1 INTO p_edi1.num_nf,
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
      LET p_ed1.data_arquivo  = p_edi1.data_arquivo[7,10],p_edi1.data_arquivo[4,5],p_edi1.data_arquivo[1,2]
      LET p_ed1.hora_arquivo  = p_edi1.hora_arquivo[1,2],p_edi1.hora_arquivo[4,5],p_edi1.hora_arquivo[7,10]
      LET p_edi1.dat_emissao  = p_edi1.dat_emissao[1,2],".",p_edi1.dat_emissao[4,5],".",p_edi1.dat_emissao[7,10]
         
      OUTPUT TO REPORT pol0793_header()   

   END FOREACH

   FINISH REPORT pol0793_header
   
END FUNCTION

#------------------------#
 REPORT pol0793_header()
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
                                 p_edi1.cod_item CLIPPED,";",";",
                                 p_edi1.num_lote CLIPPED,";","00",
                                 p_edi1.num_sequencia CLIPPED,";",";",";",";",
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
                                 p_edi1.cod_item1 USING "&&&&&&&&&&&&&&&&&&",";",";",
                                 p_edi1.num_lote CLIPPED,";","00",
                                 p_edi1.num_sequencia CLIPPED,";",";",";",";",
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
