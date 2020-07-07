create trigger insert_ar_skiplot insert on aviso_rec referencing 
new as novo for each row (EXECUTE PROCEDURE 


create procedure proc_fornecpolo (
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

create trigger upd_fornec_polo update on fornecedor referencing 
new as novo for each row (
    execute procedure proc_fornecpolo(novo.cod_fornecedor));

