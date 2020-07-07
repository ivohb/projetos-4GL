SET ISOLATION TO DIRTY READ
select * from grupo_ctr_estoq
select * from clientes_codesp
select * from rejeicao_cli_codesp
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
select * from nfs_codesp
select * from itens_nfs_codesp
select * from rejeicao_nfs_codesp
select * from par_solc_fat_codesp
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
select * from fat_nf_mestre where trans_nota_fiscal >= 304 nota_fiscal = 1759
select * from fat_nf_item where trans_nota_fiscal >= 304
select * from fat_nf_item_fisc where trans_nota_fiscal >= 304
select * from fat_mestre_fiscal where trans_nota_fiscal >= 304
select * from fat_nf_duplicata where trans_nota_fiscal >= 304
select * from fat_nf_repr where trans_nota_fiscal >= 304
select * from fat_nf_texto_hist where trans_nota_fiscal >= 304
select * from fat_nf_integr where trans_nota_fiscal >= 304

select * from sup_nf_devol_cli

select tabname from systables
where tabname like '%setor%'
