
create table item_ppte_159 
  (
    cod_empresa char(2),
    cod_item char(15),
    cod_fornecedor char(15),
    den_mat_prima char(76),
    comprimento integer,
    tol_compr decimal(10,2),
    largura integer,
    tol_largura decimal(10,2),
    espessura integer,
    tol_espessura decimal(10,2),
    gramatura integer,
    gramatura_min integer,
    gramatura_max integer,
    peso integer,
    peso_min integer,
    peso_max integer,
    lado_corte char(10),
    compr_lamina integer,
    largura_lamina integer,
    batidas_hora integer,
    cavidade integer,
    pecas_pacote integer,
    area_aplicacao decimal(10,2),
    alt_aplicacao decimal(10,2),
    tol_resina decimal(10,2),
    cod_tip_mat decimal(3,0),
    dia_validade integer,
    qtd_pecas_emb integer,
    qtd_etiq_emb integer,
    observacao char(75)
  );

create index item_ppte_159_x1 on item_ppte_159 
    (cod_empresa,cod_item) using btree ;


