select * from relat_pol1277_885
select * from periodo_pol1277_885
select * from fornecedor  -- 005436961000167  007358761004580
select * from item where cod_empresa = '01' and den_item like '%APARA%'  -- 010010002  010490014
select * from empresa
insert into relat_pol1277_885 values (
'01','007358761004580',123460,1,'05/03/2015',195,'010490014',15000,0.40,6000,0,0.00,0,15000,'NAO INICIADO')


select r.*, e.den_empresa, f.raz_social, i.den_item_reduz
  from relat_pol1277_885 r, empresa e, fornecedor f, item i
 where r.cod_empresa = e.cod_empresa and r.cod_empresa = i.cod_empresa
   and r.cod_item = i.cod_item and r.cod_fornecedor = f.cod_fornecedor

   alter table relat_pol1277_885 add usuario           VARCHAR(08)

   CREATE TABLE periodo_pol1277_885 (
       cod_empresa       VARCHAR(02),
       usuario           VARCHAR(08),
       dat_ini           VARCHAR(10),
       dat_fim           VARCHAR(10)
);