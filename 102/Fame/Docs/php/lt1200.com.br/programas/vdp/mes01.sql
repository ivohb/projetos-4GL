unload to acerta.sql
select "update lt1200_hist_comis set cod_supervisor='"||b.cod_nivel_3||
"' where mes_ref=1 and ano_ref=2006 and cod_repres='"||a.cod_repres||"';"


 from lt1200_hist_comis a, logix:canal_venda b

where b.cod_nivel_4=a.cod_repres
and a.cod_supervisor=0
and ano_ref=2006
