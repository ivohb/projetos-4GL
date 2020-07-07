SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
select * from log_val_parametro where empresa = '01' and parametro = 'gera_est_trans_relac'
select * from par_pcp
select * from item_altern
select * from log_val_parametro where parametro = 'gera_est_trans_relac'
select * from parametros_885 -- 002.030/11-IT1
select * from par_estoque
select * from par_pcp
select * from estoque_operac where cod_empresa = '01' BRPS
select * from estoque_operac_ct where cod_empresa = '01'
select * from de_para_maq_885
select * from turno
select * from familia_insumo_885

-- delete from apont_erro_885
select *  from ordens_885
select *  from ordens_bob_885
select * from apont_msg_885 where cod_empresa = '01'
SELECT * FROM proces_apont_885
select * from apont_trim_885 where tipmovto in ('R','S')
select * from consumo_trimbox_885
select * from apont_erro_885
select * from apont_papel_885 order by numordem, numlote, numsequencia
select * from estoque_trans where cod_empresa = '02' and num_docum = '11353' and dat_movto >= '04/02/2015'

select * from pedidos where cod_empresa = '01' and num_pedido = 73453
select * from ped_itens where cod_empresa = '01' and num_pedido = 6
select * from desc_nat_oper_885 where cod_empresa = '01' and num_pedido = 73453

select * from ordens_885 where  ies_situa = '3'
select * from ordens where cod_empresa = '01' and num_ordem = 266973         --OF do acessório
select * from ord_compon where cod_empresa = '01' and num_ordem = 266973
select * from necessidades where cod_empresa = '01' and num_ordem = 266973
select * from ordens where num_ordem = 263352         --OF da chapa do acessório
select * from ord_compon where num_ordem = 266972
select * from necessidades where num_ordem = 263352


        SELECT n.cod_fornecedor,  a.cod_item, n.dat_entrada_nf, n.num_nf,
        n.num_aviso_rec, a.num_seq, a.pre_unit_nf, a.qtd_declarad_nf, a.val_liquido_item
        FROM nf_sup n, aviso_rec a, item i, familia_insumo_885 f
        WHERE n.cod_empresa = '02'
        AND n.cod_empresa = a.cod_empresa AND n.num_aviso_rec = a.num_aviso_rec
        AND i.cod_empresa = a.cod_empresa AND i.cod_item = a.cod_item
        AND f.cod_empresa = i.cod_empresa AND f.cod_familia = i.cod_familia AND f.ies_apara = 'S'
        AND n.dat_entrada_nf >= '02/01/2015'
        AND n.dat_entrada_nf <= '02/01/2015'

select * from item_vdp where cod_empresa = '01' and cod_item = '2313-039-6'
select * from grupo_produto_885 where cod_grupo = '02'
select * from man_apo_mestre where empresa = '01' and ordem_producao = 266973
select * from man_apo_detalhe where empresa = '01' and seq_reg_mestre = 2909
select * from man_tempo_producao where empresa = '01' and seq_reg_mestre >= 2909
select * from man_item_produzido where empresa = '01' and seq_reg_mestre >= 2909
select * from man_comp_consumido where empresa = '01' and seq_reg_mestre >= 2909
select * from chf_componente where empresa = '01' and sequencia_registro >= 10863480
-- delete from apo_oper
select * from apo_oper where cod_empresa = '01' and num_processo >= 10963881
select * from cfp_apms  where cod_empresa = '01' and num_seq_registro >= 10863480
select * from cfp_appr  where cod_empresa = '01' and num_seq_registro >= 10863480
select * from cfp_aptm  where cod_empresa = '01' and num_seq_registro >= 10863480
select * from man_relc_tabela  where empresa = '01' and seq_reg_mestre >= 2055
select * from man_def_producao  where empresa = '01' and seq_reg_mestre >= 2055
select * from insumo_885 where cod_empresa = '02' and num_ar = 50691

select * from apont_trans_885 where  cod_empresa = '01' ORDER BY 2,3
select *  from apont_sequencia_885 where cod_empresa = '01' ORDER BY 2

select * from item where cod_empresa = '01' and cod_item in
select * from item_man where cod_empresa = '01' and cod_item in
select * from estoque where cod_empresa = '01' and cod_item in
select * from estoque_lote where cod_empresa = '01' and cod_item = '17729'  1865
select * from estoque_lote_ender where cod_empresa = '01' and cod_item in
select * from estoque_loc_reser where cod_empresa = '01' and cod_item in
select * from estoque_trans where cod_empresa='01' and num_docum = '266973'
select * from est_trans_relac where cod_empresa='01' and dat_movto>='20/01/2015'

select * from romaneio_885 where numromaneio =  383865
select * from roma_item_885
select * from roma_erro_885

select * from ordem_montag_lote
select * from estoque_loc_reser where num_reserva = 964
select * from est_loc_reser_end where num_reserva = 964
select * from ordem_montag_grade where cod_empresa = '01' and num_om >= 117818
select * from ordem_montag_item where cod_empresa = '01' and num_om >= 117818
select * from ordem_montag_mest where cod_empresa = '02' and num_om >= 27447
select * from ordem_montag_embal where cod_empresa = '01' and num_om >= 117818
select * from om_list  where cod_empresa = '01' and num_om >= 117818

select * from  desc_transp_885
select * from frete_rota_885
select * from solicit_fat_885
select * from frete_solicit_885
select * from frete_compl_885
select * from nf_solicit
select * from nf_solicit_885
select * from fat_solic_ser_comp
select * from fat_solic_mestre
select * from fat_solic_fatura order by 1
select * from fat_solic_embal

select * from fat_nf_mestre where empresa = '02' and nota_fiscal >= 19525
select * from fat_nf_item where empresa = '02' and trans_nota_fiscal >= 97012



select * from nfe_x_nff_885 where cod_empresa = '01' and cod_for = '033941642000144' and num_nfe = 228
SELECT * FROM nf_sup WHERE cod_empresa = '01' AND (ies_especie_nf = 'NFS' OR ies_especie_nf = 'CON') and dat_entrada_nf >= '01/01/2015'
 and cod_fornecedor in (select cod_transpor from desc_transp_885)
select * from desc_transp_885 where cod_empresa = '01' and cod_transpor = '033941642000144'
SELECT * FROM nf_sup WHERE cod_empresa = '01' AND (ies_especie_nf = 'NFS' OR ies_especie_nf = 'CON') and dat_entrada_nf >= '01/01/2015'
 and cod_fornecedor = '033941642000144' -- 227/228

     SELECT a.peso_bruto,
             b.nom_reduzido,
             c.den_cidade,
             a.serie_nota_fiscal,
             a.sit_nota_fiscal
        FROM fat_nf_mestre a,
             clientes  b,
             cidades   c
       WHERE a.empresa = '01'
         AND a.nota_fiscal =  80718
         AND b.cod_cliente = a.cliente
         AND c.cod_cidade  = b.cod_cidade