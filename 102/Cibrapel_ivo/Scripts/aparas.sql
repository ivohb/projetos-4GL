alter table ar_aparas_885 add ies_financeiro char(01);
alter table ad_mestre_885 add ies_situacao char(01);

-- DELETE FROM etiq_aparas_885
select * from parametros_885
select * from ar_aparas_885
select * from umd_aparas_885
select * from cont_aparas_885
select * from etiq_aparas_885
select * from familia_insumo_885
select * from insumo_885 order by 1
select * from motivo_885
select * from user_liber_ar_885
select * from contas_tmp_885
select * from cotacao_preco_885
select * from insp_trans_885

select * from item where cod_empresa = '01' and den_item like 'APARAS%' order by cod_item
select * from aviso_rec where cod_item = '010010002'
select * from aviso_rec where num_aviso_rec = 584
select * from nf_sup where num_aviso_rec = 584
select * from ad_mestre_885
select * from audit_cap_885
select * from ad_ap_885
select * from ap_885
select * from ap_tip_desp_885
select * from lanc_cont_cap_885
select * from adiant
select * from mov_adiant

select * from item where  cod_empresa = '01' and cod_item = '010010002'
select * from estoque_trans where cod_empresa = '01' and cod_item = '010010002' and num_prog = 'POL0910' order by 2
select * from estoque where  cod_empresa = '01' and cod_item = '010010002'
select * from estoque_lote where  cod_empresa = '01' and cod_item = '010010002'
select * from estoque_lote_ender where  cod_empresa = '01' and cod_item = '010010002'


select * from rota_frete_455

select * from log_versao_prg where num_programa = 'POL1267'

    SELECT a.num_transac,
           a.num_lote_dest,
           a.cod_item,
           a.num_docum,
           a.num_seq,
           a.dat_movto,
           a.qtd_movto,
           a.ies_tip_movto,
           a.cod_operacao
      FROM estoque_trans a,
           item b
     WHERE a.cod_empresa    = '01'
       AND a.num_seq        IS NOT NULL
       AND a.cod_operacao   = 'INSP'
       AND a.dat_movto >= '01/01/2012'
       AND a.ies_tip_movto  IN ('N','R')
       AND ies_sit_est_dest IN ('L','E')
       AND b.cod_empresa    = a.cod_empresa
       AND b.cod_item       = a.cod_item
       AND b.cod_familia IN (SELECT c.cod_familia
                               FROM familia_insumo_885 c
                              WHERE c.cod_empresa = b.cod_empresa)
       AND a.num_transac NOT IN (SELECT d.num_sequencia
                                   FROM insumo_885 d
                                  WHERE d.cod_empresa = a.cod_empresa)








