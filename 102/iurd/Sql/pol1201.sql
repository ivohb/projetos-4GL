SET ISOLATION TO DIRTY READ
select * from PAR_SUP_PAD where cod_empresa = '01' -- contém política de aprovação da empresa (SUP0048)
select * from nivel_autoridade where cod_empresa = '01'  -- contém os níveis de autoridade ex: CO - comprador, SC - supervisor de compra (SUP6040)
select * from SUP_NIV_AUTORID_COMPLEMENTAR               -- contém a hierarquia
select * from usuario_nivel_aut where cod_empresa = '01' and ies_versao_atual = 'S' -- contém o nível do usuário. ex: admlog é SC (SUP6050)
select * from USUARIO_NIVEL_SUBS where cod_empresa = '01' and ies_versao_atual = 'S' -- contém usuário substitudo do titular (SUP0810)
select * from USUAR_APROV_FILIAL -- contem as filiais que o usuário poderá aprovar, a partir do nivel de aprovação que o mesmo tem na matriz(SUP4460)

select * from grade_aprov_oc where cod_empresa = '01' and ies_versao_atual = 'S'  -- contém a grade de arovação das Ordens de Compras para
                                   -- determinado tipo de despesa. ex: tipo desp 101 será aprovada pro CD e depois SC. (SUP6080)
select * from grade_aprov_pc where cod_empresa = '01' and ies_versao_atual = 'S'  -- contém a grade de arovação dos Pedidos de Compras para
                                   -- determinado tipo de despesa. ex: tipo desp 101 será aprovada pro CD e depois SC. (SUP6070)

select * from sup_exc_grd_apr_oc --contém fornecedores/tipos de despesas que não ficarão pedentes de aprovação pela grade de aprovação de OC

select * from ordem_sup where cod_empresa = '01' and num_oc >= 421960
select * from aprov_ordem_sup where cod_empresa = '01'
select * from aprov_ped_sup where cod_empresa = '01'
select * from log_versao_prg where num_programa = 'SUP0290'

select * from nf_sup where cod_empresa = '01' and cod_fornecedor = '061854147000133'
select * from nf_sup where num_aviso_rec in (84723, 84832)
select * from aviso_rec where num_aviso_rec in (84723, 84832)

select * from COS_CONTR_SERVICO
select * from COS_ETAPA_CONTRATO
select * from cos_pagto_etapa
select * from COS_OC_CONTRATO
select * from COS_OC_etapa
select * from ordem_sup  where num_oc = 315
select * from prog_ordem_sup where num_oc = 315
select * from PROG_ORDEM_SUP_COM  where num_oc = 315
select * from COD_SECAO_RECEB
SELECT PERC_RETEN_ISS FROM RETEN_ISS

select NOM_RESP_ACEITE_ER from nf_sup where cod_empresa = '01' and num_aviso_rec < 1000
SELECT * FROM AVISO_REC_COMPL WHERE COD_EMPRESA='01' AND NUM_AVISO_REC=500

  SELECT e.contrato_servico,
           e.versao_contrato,
           e.num_etapa,
           e.dat_vencto_etapa,
           e.val_etapa, 'N'
      FROM cos_etapa_contrato e,
           cos_contr_servico c
     WHERE e.empresa = '01'
       AND e.sit_etapa = 'A'
       AND c.empresa = e.empresa
       AND c.contrato_servico = e.contrato_servico
       AND c.versao_contrato = e.versao_contrato
       AND c.fornecedor = '061854147000133'
       AND c.dat_ini_contrato <= '11/06/2013'
       AND c.dat_fim_contrato >= '11/06/2013'
select * from res_cpr_deb_direto where cod_empresa = '01'
select * from aprov_etapa_265
select * from cos_libr_etapa
select * from cos_etapas
select * from cos_oc_etapa
select * from sip_etapa_servico

select tabname from systables
where tabname like '%etap%'

select * from item where cod_empresa = '01' and ies_ctr_estoque = 'N' and cod_item = '99.999.8096'
select * from ordem_sup where cod_empresa = '01' and cod_item = '99.999.8096' order by num_oc
select * from ordem_sup where cod_empresa = '01' and num_oc = 315
select * from PROG_ordem_sup where cod_empresa = '01' and num_oc = 315
select * from PROG_ORDEM_SUP_COM where cod_empresa = '01' and num_oc = 315

select * from ORDEM_SUP_AUDIT where cod_empresa = '01' and num_oc = 313

select * from ordem_sup_compl where cod_empresa = '01' and num_oc = 313
select * from pedido_sup where cod_empresa = '01' and num_pedido = 55
select * from comprador
select * from log_versao_prg where num_programa = 'SUP6510'

select * from COS_CONTR_SERVICO
select * from COS_ETAPA_CONTRATO
select * from cos_pagto_etapa
select * from nf_sup where cod_empresa = '01' and cod_fornecedor = '061854147000133'
select * from nf_sup where num_aviso_rec in (84723, 84832)

SELECT cos_etapa_contrato.sit_etapa,
       cos_etapa_contrato.contrato_servico,
       cos_etapa_contrato.num_etapa,
       cos_contr_servico.fornecedor,
       cos_etapa_contrato.dat_vencto_etapa,
       cos_etapa_contrato.val_etapa
 FROM cos_etapa_contrato,cos_contr_servico
WHERE cos_etapa_contrato.empresa = '01'
  AND cos_etapa_contrato.contrato_servico between 0 and '9999999999'
  AND cos_etapa_contrato.num_etapa between 0 and 9999
  AND cos_etapa_contrato.dat_vencto_etapa between '01/01/1990' and '31/12/2999'
  AND cos_contr_servico.empresa = cos_etapa_contrato.empresa
  AND cos_contr_servico.contrato_servico = cos_etapa_contrato.contrato_servico
  AND cos_contr_servico.versao_contrato = cos_etapa_contrato.versao_contrato
  AND cos_contr_servico.filial=0

Verifica quais estao em aberto e altera o status para L de liquidado
SELECT * FROM cos_etapa_contrato
--UPDATE cos_etapa_contrato SET sit_etapa='L'
WHERE dat_vencto_etapa<='09/28/2013'
AND sit_etapa IN ('A','I')
AND empresa ='23'
AND contrato_servico =98
AND num_etapa IN ('06')



Inserir informações
SELECT * FROM  cos_pagto_etapa
WHERE dat_vencto<='today'
AND contrato_servico='90'
AND empresa='21'
AND nota_fiscal='1219451'

    SELECT e.contrato_servico,
           e.versao_contrato,
           e.num_etapa,
           e.dat_vencto_etapa,
           e.val_etapa, 'N'
      FROM cos_etapa_contrato e,
           cos_contr_servico c
     WHERE e.empresa = '01'
       AND e.sit_etapa = 'A'
       AND c.empresa = e.empresa
       AND c.contrato_servico = e.contrato_servico
       AND c.versao_contrato = e.versao_contrato
       AND c.fornecedor = '061854147000133'
       AND c.dat_ini_contrato <= '11/06/2013'
       AND c.dat_fim_contrato >= '11/06/2013'

   SELECT SUM(val_pagar)
     FROM cos_pagto_etapa p, cos_contr_servico c
    WHERE p.empresa = '01'
      AND p.nota_fiscal = 340085
      AND p.serie_nota_fiscal = '1'
      AND p.subserie_nf = 0
      AND p.contrato_servico = c.contrato_servico
      AND p.versao_contrato = c.versao_contrato
      AND c.empresa = p.empresa
      AND c.fornecedor = '061854147000133'