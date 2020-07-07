alter table conhec_proces_455 add val_tolerancia decimal(12,2)
select * from frete_sup where num_conhec in (1,3838,3939, 3535, 3131)
select * from frete_sup_x_nff  where num_conhec in (1)
select * from sup_frete_x_nf_entrada
select * from pedagio_frete where num_nf_conhec in (3838,3939, 3535, 3131)
select * from sup_par_frete where num_conhec in (3838,3939, 3535, 3131)
select * from frete_sup_compl
select * from dest_frete_sup


select * from clientes where cod_cliente = '056908569000104'
select * from empresa
select * from fat_nf_mestre where empresa = '01' and trans_nota_fiscal = 3
select * from fat_nf_item where trans_nota_fiscal = 3147


select * from nf_sup where num_conhec in (3535, 3939)
select * from aviso_rec where num_aviso_rec  in (102320,102321)
select * from aviso_rec_compl where num_aviso_rec  in (102320,102321)

select * from pedido_sup
select * from ordem_montag_mest

select * from nf_sup where num_aviso_rec = 102320
select * from fat_nf_mestre
--DELETE FROM preco_frete_455
alter table preco_frete_455 add operacao         char(60)
select * from par_frete_455
select * from preco_frete_455
select * from carreta_455
select * from conhec_proces_455
select * from audit_conhec_455
select * from erro_conhec_455
select * from transportador_455
select * from tip_veiculo_455
select * from rota_frete_455

       SELECT f.cod_transpor,
              f.num_conhec,
              f.ser_conhec,
              f.ssr_conhec,
              f.val_frete,
              f.tip_frete,
              f.dat_emis_conhec
         FROM frete_sup f
        WHERE f.cod_empresa = '01'
          AND f.dat_emis_conhec >= '01/12/2013'
          AND f.num_conhec NOT IN
              (SELECT c.num_conhec FROM conhec_proces_455 c
                WHERE c.cod_empresa = f.cod_empresa
                  AND c.cod_transpor = f.cod_transpor
                  AND c.num_conhec = f.num_conhec
                  AND c.ser_conhec = f.ser_conhec
                  AND c.ssr_conhec = f.ssr_conhec)

     SELECT cliente,
             placa_veiculo,
             SUM(peso_bruto)
        FROM fat_nf_mestre
       WHERE empresa = '01'
         AND sit_nota_fiscal = 'N'
         AND trans_nota_fiscal IN
             (SELECT trans_nota_fiscal_fatura
                FROM frete_sup_x_nff
               WHERE cod_empresa = '01'
                 AND num_conhec = 3838
                 AND ser_conhec = 'U'
                 AND ssr_conhec = 1)
       GROUP BY cliente, placa_veiculo

       select * from log_versao_prg where num_programa = 'POL1250'
