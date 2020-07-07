
select * from titulos_509
select * from rejeicao_tit_509
select * from docum where cod_empresa = '01'
select * from docum_pgto
select * from bancos
select * from titulos_509 t inner join  docum d
 on d.cod_empresa = t.cod_empresa and d.num_docum_origem = t.num_nf
