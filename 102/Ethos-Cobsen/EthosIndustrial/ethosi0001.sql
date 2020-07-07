






create view "Administrator".vi_itfim_x_compon (raz_social,cod_fornecedor,cod_empresa,cod_item,den_item,cod_compon,den_compon,qtde_estrutura,menor_preco_em,menor_preco,ultimo_preco_em,ultimo_preco) as 
  select x12.raz_social ,x8.cod_fornecedor ,x0.cod_empresa ,x0.cod_item 
    ,x1.den_item_reduz ,x0.cod_compon ,x0.den_compon ,x0.tot_necessario 
    ::decimal(17,3) ,x5.dat_entrada_nf ,CASE WHEN (x10.fat_conver_unid 
    IS NOT NULL )  THEN (x4.pre_unit_nf / x10.fat_conver_unid 
    ) ::decimal(17,6)  WHEN (x11.fat_conver_unid IS NOT NULL 
    )  THEN (x4.pre_unit_nf / x11.fat_conver_unid ) ::decimal(17,
    6)  ELSE (x4.pre_unit_nf / 1. ) ::decimal(17,6)  END ,x7.dat_entrada_nf 
    ,CASE WHEN (x8.fat_conver_unid IS NOT NULL )  THEN (x6.pre_unit_nf 
    / x8.fat_conver_unid ) ::decimal(17,6)  WHEN (x9.fat_conver_unid 
    IS NOT NULL )  THEN (x6.pre_unit_nf / x9.fat_conver_unid 
    ) ::decimal(17,6)  ELSE (x6.pre_unit_nf / 1. ) ::decimal(17,
    6)  END from (((((((((((("informix".vi_itcb_totnece x0 left 
    join "informix".item x1 on ((x0.cod_empresa = x1.cod_empresa 
    ) AND (x0.cod_item = x1.cod_item ) ) )left join "informix"
    .vi_ult_compg x2 on ((x2.cod_empresa = x0.cod_empresa ) AND 
    (x2.cod_item = x0.cod_compon ) ) )left join "informix".vi_menor_preco 
    x3 on ((x3.cod_empresa = x0.cod_empresa ) AND (x3.cod_item 
    = x0.cod_compon ) ) )left join "informix".aviso_rec x4 on 
    (((x4.cod_empresa = x0.cod_empresa ) AND (x4.num_aviso_rec 
    = x3.num_aviso_rec ) ) AND (x4.cod_item = x0.cod_compon ) 
    ) )left join "informix".nf_sup x5 on ((x5.cod_empresa = x0.cod_empresa 
    ) AND (x5.num_aviso_rec = x3.num_aviso_rec ) ) )left join 
    "informix".aviso_rec x6 on (((x6.cod_empresa = x0.cod_empresa 
    ) AND (x6.num_aviso_rec = x2.ult_aviso_rec ) ) AND (x6.cod_item 
    = x0.cod_compon ) ) )left join "informix".nf_sup x7 on ((x7.cod_empresa 
    = x0.cod_empresa ) AND (x7.num_aviso_rec = x2.ult_aviso_rec 
    ) ) )left join "informix".ordem_sup x8 on (((x0.cod_empresa 
    = x8.cod_empresa ) AND (x6.num_oc = x8.num_oc ) ) AND (x8.ies_versao_atual 
    = 'S' ) ) )left join "informix".h_ordem_sup x9 on (((x0.cod_empresa 
    = x9.cod_empresa ) AND (x6.num_oc = x9.num_oc ) ) AND (x9.ies_versao_atual 
    = 'S' ) ) )left join "informix".ordem_sup x10 on (((x0.cod_empresa 
    = x10.cod_empresa ) AND (x4.num_oc = x10.num_oc ) ) AND (x10.ies_versao_atual 
    = 'S' ) ) )left join "informix".h_ordem_sup x11 on (((x0.cod_empresa 
    = x11.cod_empresa ) AND (x4.num_oc = x11.num_oc ) ) AND (x11.ies_versao_atual 
    = 'S' ) ) )left join "informix".fornecedor x12 on (x8.cod_fornecedor 
    = x12.cod_fornecedor ) )where (x0.cod_empresa = '06' ) ;  
                                   

