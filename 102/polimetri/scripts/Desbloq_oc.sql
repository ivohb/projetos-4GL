select * from mapa_compras_454           PRIMARY KEY(cod_empresa,cod_item)
select * from mapa_compras_data_454      PRIMARY KEY(cod_empresa,cod_item,seq_campo,campo,seq_periodo,periodo)
select * from mapa_periodos_454          PRIMARY KEY(cod_empresa,cod_frequencia,seq_periodo)
select * from man_par_prog_454           PRIMARY KEY(empresa,item)
select * from audit_oc_bloq_454

select * from usuario_oc_bloq_454
select * from ordem_sup where cod_empresa = '01' and ies_situa_oc = 'X'
select * from ordem_sup where cod_empresa = '01' and num_oc =   360646
select * from prog_ordem_sup where cod_empresa = '01' and num_oc =   360646



