
delete   from lt1200_comissoes
where mes_ref="07"
and ano_ref=2006
and dat_emissao > "10/07/2006"
and val_tot_mercadoria < 0
and ies_tipo_lancto='G'
and cod_repres in (select cod_repres
from lt1200_representante
where tipo="F" )
