select * from turno
select * from parametros_885
select * from par_estoque

select * from cons_erro_885
select * from familia_insumo_885
select * from trans_consu_885

select * from apara_alternat_885
select * from item where den_item like '%APARA%'
                                                                BOBINA      APARAS     APARAS ALTERNATIVA
select * from item where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT4','002.030/11-IT2')
                                                                  BOBINA       APARAS
select * from item_man where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT4')
select * from estoque where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT4','002.030/11-IT2')
select * from estoque_lote where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT4','002.030/11-IT2')
select * from estoque_lote_ender where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT4','002.030/11-IT2')
select * from estoque_loc_reser where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT4')
select * from estoque_trans where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT4','002.030/11-IT2')
  and num_transac >= 2827

select * from item_ctr_grade where cod_empresa = '01' and cod_item in ('010010001','152210046','002.030/11-IT4','002.030/11-IT2')
select * from item_chapa_885 where num_pedido = 1 and num_sequencia = 1
select * from item_bobina_885 where num_pedido = 3 and num_sequencia = 1