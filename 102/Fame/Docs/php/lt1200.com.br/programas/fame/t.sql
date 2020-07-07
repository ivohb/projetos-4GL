         SELECT 0 as tipo,count(b.num_nff) as qtd_nff,sum(b.val_tot_nff) as val_tot_nff
          from lt1200:lt1200_ctr_emb j,
             empresa a,
             nf_mestre_ser b,
             clientes c,
             cidades f,
             nf_item_ser i,
             item k
        where j.cod_empresa='02'
          and j.data_saida between '".$dini."' and '".$dfin."' 
	  and a.cod_empresa='01'
	  and b.cod_empresa=j.cod_empresa
          and b.num_nff=j.num_nff
          and b.ser_nff=j.ser_nff
          and b.cod_cliente=c.cod_cliente
          and f.cod_cidade=c.cod_cidade
          and b.cod_empresa = i.cod_empresa
          and b.num_nff = i.num_nff
          and i.cod_empresa = k.cod_empresa
          and i.cod_item = k.cod_item
          and k.gru_ctr_estoq=22
          group by 1 
