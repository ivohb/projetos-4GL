
cre_popup_sist_781
cre0270_empresa
cre0270_tip_doc
cre0270_num_docum
cre0270_portador
cre_txt_sist_gerad
par_rel_cre_tex

create table cre_compl_docum 
  (
    empresa char(2) not null ,
    docum char(14) not null ,
    tip_docum char(2) not null ,
    sistema_gerador char(20) not null ,
    val_desc_comercial decimal(15,2) not null ,
    val_cons_pesquisa decimal(15,2) not null ,
    val_outro_desc decimal(15,2) not null ,
    val_desc_pamcard decimal(15,2) not null ,
    val_credito decimal(15,2) not null ,
    val_debito decimal(15,2) not null ,
    val_acumulado_ant decimal(15,2) not null ,
    val_honorar decimal(15,2) not null ,
    pct_irrf decimal(5,2) not null ,
    val_irrf decimal(15,2) not null ,
    tip_portador_pagto char(1) not null ,
    dat_bilhetag date,
    endereco_cobranca char(46),
    compl_end_cobranca char(30),
    bairro_cobranca char(60),
    cidade_cobranca char(60),
    estado_cobranca char(20),
    cep_cobranca char(9),
    sucursal char(10),
    moeda_fatura decimal(2,0),
    filial_cobranca char(10),
    filial_admin char(10),
    tip_nota_fiscal char(2),
    tip_cli_contrato char(15),
    grupo_economico smallint,
    natureza_operacao smallint not null ,
    cond_pagto decimal(3,0) not null ,
    endereco_etiq char(46),
    compl_end_etiq char(30),
    bairro_etiq char(60),
    cidade_etiq char(60),
    estado_etiq char(20),
    cep_etiq char(9),
    caixa_postal_etiq char(5),
    obs_endereco_etiq char(60),
    tip_contrato char(10) not null ,
    meio_envio char(10),
    roteiro char(10),
    dirigente_cliente char(5) not null ,
    geren_cta_cliente char(10) not null ,
    dirigente_negocio char(5) not null ,
    geren_cta_negocio char(10) not null ,
    ramo_ativ char(5) not null ,
    corretor char(10),
    contrato_agrupado char(1),
    empresa_item char(2),
    item_preco_minimo char(15),
    qtd_preco_minimo smallint,
    val_tot_pre_minimo decimal(15,2),
    primary key (empresa,docum,tip_docum)  constraint "informix".pk_crecodoc
  );

create table cre_itcompl_docum                 
  (
    empresa char(2) not null ,
    docum char(14) not null ,
    tip_docum char(2) not null ,
    sequencia_docum smallint not null ,
    praca integer not null ,
    item char(15) not null ,
    qtd_item decimal(12,3) not null ,
    preco_unit decimal(17,6) not null ,
    val_tot_item decimal(15,2) not null ,
    cobra_servico char(1) not null ,
    cnpj_cli_ligacao char(19) not null ,
    cnpj_cli_execucao char(19) not null ,
    processo char(20),
    tip_item char(1) not null ,
    emite_nota_fiscal char(1) not null ,
    disposit char(10),
    val_base_irrf decimal(13,2) not null ,
    atendto char(15),
    empresa_origem char(2) not null ,
    natureza_operacao smallint not null ,
    dat_servico date not null ,
    cnpj_cli_agrupado char(19),
    primary key (empresa,docum,tip_docum,sequencia_docum)  constraint "informix".pk_crecitem
  );
  
CREATE TABLE ctr_titulo_complementar ( 
    empresa                         CHAR(2) NOT NULL,
    titulo                 CHAR(20) NOT NULL,
    tip_titulo         CHAR(2) NOT NULL,
    emp_item_pminimo                 CHAR(2),
    item_pminimo             CHAR(15),
    qtde_pminimo             DECIMAL(10,3),
    val_total_pminimo     DECIMAL(17,6),
    endereco_cobranca  CHAR(46),
    compl_endereco        CHAR(30),
    bairro_cobranca          CHAR(60),
    cidade_cobranca         CHAR(60),
    estado_cobranca        CHAR(20),
    cep_cobranca               CHAR(9),
    PRIMARY KEY(empresa,tip_titulo,titulo)
)

CREATE UNIQUE INDEX 12956_92002
    ON USUAPLIC.ctr_titulo_complementar(empresa, titulo, tip_titulo)



CREATE TABLE ctr_titulo_mestre ( 
    empresa                         CHAR(2) NOT NULL,
    titulo                 CHAR(20) NOT NULL,
    tip_titulo        CHAR(2) NOT NULL,
    sit_aprovacao               CHAR(1) NOT NULL,
    idcontrato                      VARCHAR(10) NOT NULL,
    contr_agrupado          CHAR(1) NOT NULL,
    dat_emissao                 DATE,
    dat_vencimento         DATE,
    dat_competencia       DATE,
    cliente              CHAR(15),
    val_faturado                 DECIMAL(17,6) NOT NULL,
    natureza_operacao   SMALLINT NOT NULL,
    cond_pagamento       SMALLINT NOT NULL,
    sit_titulo        CHAR(1),
    dat_cancelamento     DATETIME YEAR to SECOND,
    pedido            INTEGER,
    lote_faturamento      INTEGER,
    usuario_fatura             CHAR(10),
    dat_fatura                     DATETIME YEAR to SECOND,
    usuario_aprovacao    CHAR(10),
    dat_aprovacao             DATETIME YEAR to SECOND,
    tip_cli_contrato           CHAR(15),
    tip_contrato                  CHAR(10),
    tip_nota_fiscal             CHAR(2),
    sistema_gerador         CHAR(20) NOT NULL,
    val_credito                    DECIMAL(15,6) NOT NULL,
    val_debito                     DECIMAL(15,6) NOT NULL,
    val_acumulado            DECIMAL(15,6) NOT NULL,
    filial_cobranca              CHAR(10) NOT NULL,
    filial_admin                    CHAR(10),
    hierarq_cliente            CHAR(5),
    gecon_cliente              CHAR(10),
    hierarq_negocio          CHAR(5),
    gecon_negocio            CHAR(10),
    ramo_atividade           CHAR(5) NOT NULL,
    corretor          CHAR(10),
    texto_consistencia     VARCHAR(255),
    PRIMARY KEY(empresa,tip_titulo,titulo)
)

CREATE UNIQUE INDEX 13006_121623
    ON USUAPLIC.ctr_titulo_mestre(empresa, titulo, tip_titulo)



CREATE TABLE ctr_titulo_item ( 
    empresa                         CHAR(2) NOT NULL,           
    titulo                 CHAR(20) NOT NULL,
    tip_titulo         CHAR(2) NOT NULL,
    sequencia_item          SMALLINT NOT NULL,
    praca                INTEGER,
    item                  CHAR(15) NOT NULL,
    qtd_item                        DECIMAL(10,3) NOT NULL,
    val_unitario                   DECIMAL(17,6) NOT NULL,
    val_total_item             DECIMAL(17,6) NOT NULL,
    cobra_servico               CHAR(1) NOT NULL,
    cnpj_ligacao                  CHAR(19),
    cnpj_execucao            CHAR(19),
    processo                         CHAR(20) NOT NULL,
    tip_item         CHAR(1) NOT NULL,
    emite_nota_fiscal      CHAR(1) NOT NULL,
    empresa_origem        CHAR(2),
    natureza_operacao   SMALLINT,
    dat_servico                   DATE,
    cnpj_ctr_agrupado    CHAR(19),
    PRIMARY KEY(empresa,sequencia_item,tip_titulo,titulo)
)

CREATE UNIQUE INDEX 12957_92006
    ON ctr_titulo_item(empresa, titulo, tip_titulo, sequencia_item)

