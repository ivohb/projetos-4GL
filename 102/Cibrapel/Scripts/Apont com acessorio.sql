select * from apont_trim_885 where numordem = 278471

select * from ordens where cod_empresa = '01' and num_docum = '77560/5'

select * from ord_compon where cod_empresa = '01' and num_ordem = 278471
select * from ord_compon where cod_empresa = '01' and num_ordem = 278472

select * from estoque_trans where cod_empresa = '01' and num_docum = '278471' and num_prog = 'POL1275 ' order by 2
select * from estoque_lote where cod_item = '17938'


Apontamento relamado pela LU

select * from apont_trim_885 where num_lote = '77491/1'

select * from ordens where cod_empresa = '01' and num_docum = '77560/5'

select * from ord_compon where cod_empresa = '01' and num_ordem = 278471
select * from ord_compon where cod_empresa = '01' and num_ordem = 278472



select * from estoque_trans where cod_empresa = '01' and num_docum = '278471' and num_prog = 'POL1275 ' order by 2
select * from estoque_lote where cod_item = '17938'