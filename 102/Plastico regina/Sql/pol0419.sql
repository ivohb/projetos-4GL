select * from embal_plast_regina
select * from fat_nf_mestre where empresa = '01'  and trans_nota_fiscal = 28 and nota_fiscal = 4923
select * from fat_nf_item where  trans_nota_fiscal = 28 order by 3
select * from ordem_montag_mest where num_om = 1
select * from ordem_montag_embal where num_om = 1
select * from item where cod_item = '000015'
select * from sup_item_terc_end 3 1 0 NF 1 534 1 000015 100
select * from item_de_terc
select * from nf_sup where cod_empresa = '01' order by 3
select * from aviso_rec where cod_empresa = '01' and num_aviso_rec = 534
select * from fat_nf_refer_item
select * from vdp_num_docum
alter table fat_nf_refer_item add chav_aces_nf_refer char(80)
select * from nf_embal_tmp
select * from fat_retn_item_nf