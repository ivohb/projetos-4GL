
create table item_ppte_req_159 
  (
    cod_empresa char(2),
    cod_grp_ctr_estoq decimal(2,0),
    ies_den_mat_prima char(1),
    ies_comprimento char(1),
    ies_tol_compr char(1),
    ies_largura char(1),
    ies_tol_largura char(1),
    ies_espessura char(1),
    ies_tol_espessura char(1),
    ies_gramatura char(1),
    ies_gramatura_min char(1),
    ies_gramatura_max char(1),
    ies_peso char(1),
    ies_peso_min char(1),
    ies_peso_max char(1),
    ies_lado_corte char(1),
    ies_compr_lamina char(1),
    ies_largura_lamina char(1),
    ies_batidas_hora char(1),
    ies_cavidade char(1),
    ies_qtd_pecas_emb char(1),
    ies_qtd_etiq_emb char(1),
    ies_pecas_pacote char(1),
    ies_area_aplicacao char(1),
    ies_alt_aplicacao char(1),
    ies_tol_resina char(1),
    ies_cod_tip_mat char(1),
    ies_observacao char(1),
    ies_dia_validade char(1),
    ies_fornecedor char(1)
  );

create index ix_it_ppte_req_159 on item_ppte_req_159 
    (cod_empresa,cod_grp_ctr_estoq) using btree ;


