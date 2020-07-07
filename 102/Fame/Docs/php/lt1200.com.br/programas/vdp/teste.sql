SELECT unique 'NF' as ies_tip_docto,'G' as ies_tipo_lancto,
                     '08' as mes_ref,'2006' as ano_ref,
                     '01' as cod_empresa,
                     c.texto_compl1[9,11] as cod_repres ,
                     c.texto_compl2[1,6] as num_nff,
                     a.num_aviso_rec as num_docum,
                     a.dat_entrada_nf as dat_emissao,
                     a.cod_fornecedor as cod_cliente,
                     sum(b.val_base_c_ipi_it) as val_tot_mercadoria,
                     a.val_tot_nf_c as val_tot_docum,
                     c.texto_compl1[13,120] as observacao,
                     c.texto_compl1[1,7] as val_frete
              from logix:nf_sup a,
                   logix:aviso_rec b,
                   logix:nfe_sup_compl c
    where a.cod_operacao[3,5] in ('101','102','201','202')
           and a.dat_entrada_nf between  '11/07/2006' and '09/08/2006'
           and b.cod_empresa=a.cod_empresa
           and b.num_aviso_rec=a.num_aviso_rec
           and c.cod_empresa=a.cod_empresa
           and c.num_aviso_rec=a.num_aviso_rec

     group by 1,2,3,4,5,6,7,8,9,10,12,13,14