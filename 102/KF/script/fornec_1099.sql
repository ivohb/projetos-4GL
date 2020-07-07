create table fornec_1099 (
   cod_fornecedor   char(15)
);

create unique index fornec_1099 on
 fornec_1099(cod_fornecedor);

create table tg_fornec_1099 (
   id               serial,
   cod_fornecedor   char(15)
);

create trigger ins_fornecedor insert on fornecedor referencing 
new as novo for each row (
    insert into tg_fornec_1099 (id, cod_fornecedor)
    values (0 ,novo.cod_fornecedor));


create procedure proc_fornecedor (
   t_cod_fornecedor char(15))

   define p_count  integer;
   
   set isolation to dirty read;

   select count(cod_fornecedor)
     into p_count
     from tg_fornec_1099
    where cod_fornecedor = t_cod_fornecedor;

   if p_count = 0 then
      insert into tg_fornec_1099 (id, cod_fornecedor)
      values (0 ,t_cod_fornecedor);
   end if

end procedure;

create trigger upd_fornecedor update on fornecedor referencing 
new as novo for each row (
    execute procedure proc_fornecedor(novo.cod_fornecedor));

