SET ISOLATION TO DIRTY READ

select clientes.cod_cliente as Cliente,
       clientes.nom_cliente as Nome,
       clientes.dat_atualiz as Data,
       cidades.den_cidade as Cidade,
       cidades.cod_uni_feder as UF
  from clientes, cidades
 where clientes.cod_cidade = cidades.cod_cidade
   and clientes.cod_cliente = '11'
 order by cidades.cod_uni_feder, cidades.den_cidade, clientes.nom_cliente

 select * from systables where tabName = 'item'

    SELECT a.*
      FROM syscolumns a, systables b
     WHERE a.tabid = b.tabid
       AND b.tabName = 'clientes'


select * from relat_ireport_912
select * from tabela_relat_912
select * from filtro_tabela_912

