select * from log_versao_prg where num_programa = 'LOG5500'
select * from menu_logix where cod_sistema = 999
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
alter table ar_aparas_885 add ies_financeiro char(01);
alter table ad_mestre_885 add ies_situacao char(01);

-- DELETE FROM etiq_aparas_885
select * from parametros_885
select * from ar_aparas_885 where num_aviso_rec = 51335
select * from umd_aparas_885 where num_aviso_rec = 51335
select * from cont_aparas_885 where num_aviso_rec = 51335
select * from etiq_aparas_885
select * from familia_insumo_885
select * from insumo_885 where cod_empresa = '02' and num_ar = 51337
select * from motivo_885
select * from user_liber_ar_885
select * from contas_tmp_885
select * from cotacao_preco_885
select * from insp_trans_885

select * from aviso_rec where cod_empresa = '02' and den_item like 'APARAS%' and cod_item = '010040002'
 and ies_liberacao_cont = 'N' and ies_liberacao_insp = 'N' and num_aviso_rec not in
  (select num_aviso_rec from umd_aparas_885) order by num_aviso_rec


select * from aviso_rec where cod_empresa = '02' and den_item like 'APARAS%' and cod_item = '010040006'
 and ies_liberacao_cont = 'N' and ies_liberacao_insp = 'N' and num_aviso_rec not in
  (select num_aviso_rec from umd_aparas_885) order by num_aviso_rec

select * from item where cod_empresa = '02' and cod_item = '010040002'
select * from aviso_rec where cod_empresa = '02' and num_aviso_rec = 51402 -- 10600 * 0,37 = 3922      51365 / 51375
select * from nf_sup where num_aviso_rec = 51375
select * from nf_sup where num_nf = 83524
select * from  familia_insumo_885

SELECT n.cod_fornecedor,  a.cod_item, n.dat_entrada_nf, n.num_nf,
n.num_aviso_rec, a.num_seq, a.pre_unit_nf, a.qtd_declarad_nf, a.val_liquido_item
FROM nf_sup n, aviso_rec a, item i, familia_insumo_885 f
WHERE n.cod_empresa = '01'
AND n.cod_empresa = a.cod_empresa AND n.num_aviso_rec = a.num_aviso_rec
AND i.cod_empresa = a.cod_empresa AND i.cod_item = a.cod_item
AND f.cod_empresa = i.cod_empresa AND f.cod_familia = i.cod_familia AND f.ies_apara = 'S'
ORDER BY n.cod_fornecedor, n.dat_entrada_nf

select * from relat_pol1277_885

select * from ad_mestre_885
select * from audit_cap_885
select * from ad_ap_885
select * from ap_885
select * from ap_tip_desp_885
select * from lanc_cont_cap_885
select * from adiant
select * from mov_adiant

select * from item where  cod_empresa = '02' and cod_item = '050590002' and cod_familia = '059'
select * from item where  cod_empresa = '02' and  cod_familia = '059' -- canudos (tubetes)
select * from estoque_trans where cod_empresa = '02' and cod_item = '010040002' and num_docum = '51337' order by 2
   and num_prog = 'POL0910' and dat_movto = '05/01/2015'
select * from estoque where  cod_empresa = '02' and cod_item = '010040002'
select * from estoque_lote where  cod_empresa = '02' and cod_item = '010040002' and num_lote is null
select * from estoque_lote_ender where  cod_empresa = '02' and cod_item = '010040002' and num_lote is null

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


SELECT n.cod_fornecedor,  a.cod_item, n.dat_entrada_nf, n.num_nf,
n.num_aviso_rec, a.pre_unit_nf, a.qtd_declarad_nf, a.val_liquido_item
FROM nf_sup n, aviso_rec a, item i, familia_insumo_885 f
WHERE n.cod_empresa = '02'
AND n.cod_empresa = a.cod_empresa AND n.num_aviso_rec = a.num_aviso_rec
AND i.cod_empresa = a.cod_empresa AND i.cod_item = a.cod_item
AND f.cod_empresa = i.cod_empresa AND f.cod_familia = i.cod_familia AND f.ies_apara = 'S'
AND n.dat_entrada_nf >= '01/01/2015'
AND n.dat_entrada_nf <= '28/02/2015'



SELECT * FROM CONS_INSUMO_885 WHERE CODITEM = '010040002' AND STATUSREGISTRO IN (0,2)
select * from estoque where cod_empresa = '02' and cod_item = '010040002'
select * from estoque_lote where cod_empresa = '02' and cod_item = '010040002'
select * from estoque_lote_ender where cod_empresa = '02' and cod_item = '010040002'
select * from estoque_loc_reser where cod_empresa = '02' and cod_item = '010040002' AND QTD_RESERVADA >0
select * from estoque_trans where cod_empresa='02' and cod_item = '010040002'
select * from baixa_aparas_885
28140

set transition isolation

create table baixa_aparas_885 (
  cod_empresa      char(02),
  dat_movto        datetime,
  cod_item         char(15),
  qtd_bx_trim      decimal(10,3),
  qtd_bx_logix     decimal(10,3),
  primary key(cod_empresa,dat_movto,cod_item)
);