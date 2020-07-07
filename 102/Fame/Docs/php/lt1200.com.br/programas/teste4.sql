select a.zona[1,5],a.zona,
 a.mes_ref,a.ano_ref,a.cod_repres,a.mes_ref+a.ano_ref,
 a.tipo,a.cod_empresa,a.num_matricula, a.pct_nff,a.pct_dp,a.salario,
 a.fixo,a.cota,a.val_merc_nff, a.val_merc_dp,a.cod_supervisor,
 a.pct_alcancado,a.valor_comissao,a.outros,
 a.indenizacao,a.sal_bruto,a.sal_liquido, a.dsr,a.encargos,a.despesas,a.zona,
 a.zona[1,2]||a.zona[4,5] as nivel, b.raz_social,a.zona[7,8] as sup from
 lt1200:lt1200_hist_comis a, representante b ,canal_venda x where
 a.ano_mes_ref between '2006-01' and '2006-06' and a.tipo='F' and a.cota > 0
 and a.zona[7,8] <>'' and b.cod_repres=a.cod_repres and x.cod_nivel_4=0 and
 x.cod_nivel_3=b.cod_repres 
union 
 select
 a.zona[1,5],a.zona,a.mes_ref,a.ano_ref,a.cod_repres,a.mes_ref+a.ano_ref,
 a.tipo,a.cod_empresa,a.num_matricula, a.pct_nff,a.pct_dp,a.salario,
 a.fixo,a.cota,a.val_merc_nff, a.val_merc_dp,a.cod_supervisor,
 a.pct_alcancado,a.valor_comissao,a.outros,
 a.indenizacao,a.sal_bruto,a.sal_liquido, a.dsr,a.encargos,a.despesas,a.zona,
 a.zona[1,2]||a.zona[4,5] as nivel, b.raz_social,a.zona[7,8] as sup from
 lt1200:lt1200_hist_comis a, representante b ,canal_venda x where
 a.ano_mes_ref between '2006-01' and '2006-06' and a.tipo='F' and a.cota > 0
 and a.zona[7,8] <>'' and b.cod_repres=a.cod_repres and
 x.cod_nivel_4=b.cod_repres order by 1,2,5,4,3,6