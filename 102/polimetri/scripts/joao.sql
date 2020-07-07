    SELECT distinct ordem_sup.num_oc
      FROM ordem_sup,
           prog_ordem_sup
     WHERE ordem_sup.cod_empresa = '01'
      -- AND ordem_sup.cod_item = 'PB.054'
       AND ordem_sup.ies_situa_oc IN ('A', 'R')
       AND ordem_sup.ies_versao_atual = 'S'
       AND prog_ordem_sup.dat_entrega_prev <= '01/01/2013'
       AND prog_ordem_sup.cod_empresa = ordem_sup.cod_empresa
       AND prog_ordem_sup.num_oc = ordem_sup.num_oc
       AND prog_ordem_sup.num_versao = ordem_sup.num_versao
       AND prog_ordem_sup.ies_situa_prog NOT IN ('C')
       AND (prog_ordem_sup.qtd_solic - prog_ordem_sup.qtd_recebida) = 0
       into temp ivo

       select * from ivo

   update ordem_sup set ordem_sup.ies_situa_oc = 'L' where ordem_sup.ies_versao_atual = 'S' and ordem_sup.num_oc in (select num_oc from ivo)

       delete from ivo



select * from ordem_sup where num_oc = 315
