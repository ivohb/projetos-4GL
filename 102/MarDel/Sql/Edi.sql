SET ISOLATION TO DIRTY READ

SELECT * FROM caminho_5054
select * from item_edi_vw_5054
select * from item where cod_item in ('CH-6028', 'RL-0020',  'RL-1058') and cod_empresa = '01'
select * from item_fornec where cod_fornecedor = '060608866000101'
select * from unimed_edi_vw_5054
select * from fornec_edi_vw_5054
select * from processo_edi_vw_5054
select * from fornecedor where cod_fornecedor in ('000323232000423', '000353812000110')
select * from log_versao_prg where num_programa = 'CRE2020'
select * from w_edi_volksvagen order by cod_item, prz_entrega
                                                            14/11/2011 02/05/2011 24/10/2011
select * from ordem_sup where cod_empresa = '01' and num_oc in (421759,371062,421760) and ies_versao_atual = 'S' order by num_oc
select * from prog_ordem_sup where cod_empresa = '01' and num_oc in (421759,371062,421760) order by num_oc, num_versao

 insert into w_edi_volksvagen values
  ('01',371062,'RL-0020','000323232000423',34,'vw000','VW-0020','PEDRO','25/09/2011')


    SELECT o.num_oc,
           o.num_versao,
           o.cod_item,
           o.cod_fornecedor,
           i.cod_item_vw,
           i.num_ped_vw,
           p.num_prog_entrega,
           p.dat_entrega_prev,
           (p.qtd_solic - p.qtd_recebida)
      FROM ordem_sup o,
           prog_ordem_sup p,
           fornec_edi_vw_5054 f,
           item_edi_vw_5054 i
     WHERE o.cod_empresa = '01'
       AND o.ies_situa_oc = 'R'
       AND o.ies_versao_atual = 'S'
       AND o.cod_empresa = p.cod_empresa
       AND o.num_oc = p.num_oc
       AND o.num_versao = p.num_versao
       AND p.dat_entrega_prev >= '01/09/2011'
       AND p.dat_entrega_prev <= '31/12/2011'
       AND o.cod_fornecedor = f.cod_fornecedor
       AND o.cod_item = i.cod_item
       AND i.cod_empresa = o.cod_empresa
       ORDER BY o.num_oc, p.dat_entrega_prev
