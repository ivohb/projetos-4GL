SET ISOLATION TO DIRTY READ
select * from cfop_x_natoper_509
select * from grupo_ctr_estoq
select * from grupo_item_509
select * from clientes_509
select * from rejeicao_cli_509
select * from vdp_cli_grp_email
select * from vdp_cliente_grupo
select * from VDP_CLIENTE_COMPL
select * from vdp_cli_parametro
select * from cli_dist_geog
select * from vdp_cli_fornec_cpl
select * from audit_logix
select * from cliente_alter
select * from logix.obf_cidade_ibge where cidade_ibge = 3550308
-- delete from rejeicao_cli_509
select * from nf_mestre_509
select * from nf_itens_509
select * from rejeicao_nf_509
select * from par_solc_fat_codesp
select * from par_omc_509
select * from grupo_item_509
select * from cli_end_ent
select * from cli_end_cob
select * from log_versao_prg where num_programa = 'VDP0815'
select * from vdp_cli_grp_email
select * from logix.empresa
select * from logix.clientes where cod_cliente in ('95396','55415','1799')
select * from fornecedor where cod_fornecedor = '95396'
select * from sil_dimensao_fornecedor
select * from logix.item where cod_empresa = '01' and den_item like '%MAO%'
select * from empresa
select * from vdp_num_docum
select * from cond_pgto
  -- delete from fat_nf_integr where trans_nota_fiscal >= 50180
select * from logix.fat_nf_mestre where trans_nota_fiscal >= 304 nota_fiscal = 1759
select * from logix.fat_nf_item where trans_nota_fiscal >= 304
select * from logix.fat_nf_item_fisc where trans_nota_fiscal >= 304
select * from logix.fat_mestre_fiscal where trans_nota_fiscal >= 304
select * from logix.fat_nf_duplicata where trans_nota_fiscal >= 304
select * from logix.fat_nf_repr where trans_nota_fiscal >= 304
select * from logix.fat_nf_texto_hist where trans_nota_fiscal >= 304
select * from logix.fat_nf_integr where trans_nota_fiscal >= 304

select * from logix.nf_sup where num_nf = 751 and cod_fornecedor = '001273'
select * from logix.aviso_rec where num_aviso_rec = 582
select * from logix.dest_aviso_rec where num_aviso_rec = 582
select * from logix.aviso_rec_compl where num_aviso_rec = 582
select * from logix.nf_sup_erro where num_aviso_rec = 582
select * from logix.audit_ar where num_aviso_rec = 582
select * from logix.sup_ar_piscofim where aviso_recebto = 582
select * from logix.ar_pis_cofins where num_aviso_rec = 582

select * from sup_nf_devol_cli

select tabname from systables
where tabname like '%setor%'

select * from logix.item where cod_empresa = '01' and cod_item = '000015'
select * from logix.item where cod_empresa = '01' and cod_item = '010040001'
select * from logix.item_vdp where cod_empresa = '01' and cod_item = '010040001'
select * from logix.item_man where cod_empresa = '01'  and cod_item = '010040001'
select * from logix.item_sup where cod_empresa = '01'  and cod_item = '010040001'
select * from logix.item_barra where cod_empresa = '01'  and cod_item = '010040001'
select * from logix.item_grade where cod_empresa = '01'  and cod_item = '010040001'
select * from logix.item_ctr_grade where cod_empresa = '01'  and cod_item = '010040001'
select * from logix.item_embalagem where cod_empresa = '01'  and cod_item = '010040001'
select * from logix.item_custo where cod_empresa = '01'  and cod_item = '010040001'
select * from logix.item_esp where cod_empresa = '01'  and cod_item = '010040001'

select cod_operacao, * from nf_sup where cod_empresa = '01'
select cod_operac_estoq, * from aviso_rec where cod_empresa = '01' and num_aviso_rec >= 49429 and num_aviso_rec <= 50000


select r.empresa,
       r.matricula,
       r.foto,
       f.nom_funcionario
  from rhu_funcio_foto r, funcionario f
 where r.empresa = '01'
   and (r.matricula = 99997 or (r.matricula >= 3 and r.matricula <= 20))
   and f.cod_empresa = r.empresa
   and f.num_matricula = r.matricula

select *
  from funcionario
 where cod_empresa = '01'
   and (num_matricula = 99997 or (num_matricula >= 3 and num_matricula <= 20))


select *
  from unidade_funcional
 where cod_empresa = '01'

select * from par_omc_509

      SELECT INCIDE,ALIQUOTA  FROM LOGIX.obf_config_fiscal WHERE empresa = '01' AND tributo_benef = 'COFINS_REC'
alter table logix.fat_nf_item_fisc add iden_processo        integer


select * from titulos_509
select * from logix.docum
select * from logix.docum_pgto