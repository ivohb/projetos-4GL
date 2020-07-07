select * from fornec_tara_minima_885
select * from transportador_placa_885
select * from rotas_885
select * from tab_frete_885
select * from nf_x_tab_frete_885
select * from familia_insumo_885 where cod_empresa = '01'
select * from item where cod_empresa = '01' and cod_familia in ('008','026')
select * from fornecedor where cod_fornecedor = '000944746000153'
select * from clientes where cod_tip_cli in ('98','99') -- 1193/1891/1114
select * from cidades where cod_cidade ='12200'

select * from aviso_rec where den_item like '%CANUDO%'
select * from aviso_rec where num_aviso_rec = 584
select * from aviso_rec where num_aviso_rec = 4
select * from nf_sup where num_aviso_rec = 4
select * from ar_aparas_885 where num_aviso_rec = 584
select * from umd_aparas_885
select * from cont_aparas_885



