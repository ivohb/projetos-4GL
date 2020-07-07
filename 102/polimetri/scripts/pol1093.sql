SET ISOLATION TO DIRTY READ
select * from item where cod_empresa = '01' and ies_tip_item = 'F'    110020310300    130000503200

      select * from ordens
       where cod_empresa = '01'
        and  ies_situa = '4'
        AND dat_entrega between '01/01/2011' AND '31/01/2011'

    SELECT cod_item,
           cod_item_pai,
           round(SUM(qtd_planej),6)
    FROM ordens
   WHERE cod_empresa = '01'
     AND ies_situa = '1'
     AND dat_entrega >= '01/01/2011'
     AND dat_entrega <=  '31/01/2011'
   GROUP BY cod_item, cod_item_pai


       select cod_item, cod_item_pai, sum(qtd_planej)
       from ordens
       where cod_empresa = '01'
        and  ies_situa = '1'
        AND dat_entrega between '01/01/2011' AND '31/01/2011'
      GROUP BY cod_item, cod_item_pai
      order by cod_item, cod_item_pai

    select * from ordens
       where cod_empresa = '01'
        and  ies_situa = '4'
        and cod_item = '13000050030040'

    SELECT cod_item,
           cod_item_pai,
           SUM(qtd_planej)
    FROM ordens
   WHERE cod_empresa = '01'
     AND ies_situa = '1'
     AND dat_entrega >= '01/01/2011'
     AND dat_entrega <= '31/01/2011'
   GROUP BY cod_item, cod_item_pai
   ORDER BY cod_item

