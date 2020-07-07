select * from nf_sup where cod_empresa = '01' order by dat_emis_nf desc
select * from codigo_fiscal
select * from cod_fiscal_sup where cod_fiscal = '5.101'

select * from status_nf_ronc
select * from nf_recebida_ronc

       SELECT n.num_aviso_rec, n.num_nf, n.ser_nf, n.dat_emis_nf, n.cod_fornecedor, f.raz_social
         FROM nf_sup n, fornecedor f
        WHERE cod_empresa = '01'
          AND n.ies_nf_aguard_nfe = '7'
          AND n.cod_fornecedor = f.cod_fornecedor




