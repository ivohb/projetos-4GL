create procedure pr_fornec01
(
   t_cod_fornecedor        char(15),
   t_operacao              char(01)
)

   set isolation to dirty read;


   if t_operacao = 'I' then
      update fornecedor
         set ies_fornec_ativo = 'I'
       where cod_fornecedor = t_cod_fornecedor;
   end if
   
   if t_operacao = 'A' then
      update fornecedor
         set ies_fornec_ativo = 'I'
       where cod_fornecedor = t_cod_fornecedor
         and not exists (select cod_fornecedor from fornec_1099
            where cod_fornecedor = t_cod_fornecedor);

      update fornecedor
         set ies_fornec_ativo = 'A'
       where fornec_1099 = t_cod_fornecedor
         and exists (select cod_fornecedor from fornec_1099
            where cod_fornecedor = t_cod_fornecedor);
   end if       

end procedure;


create trigger tg_fornec01_ins insert on fornecedor
   referencing new as new_rec for each row (
        execute procedure pr_fornec01(new_rec.cod_fornecedor, 'I' ));

create trigger tg_fornec02_upd update on fornecedor 
   referencing new as upd_rec for each row (
       execute procedure pr_fornec01(upd_rec.cod_fornecedor, 'U' ));



create trigger fornec_ins_1099 insert on fornecedor referencing
new as novo for each row
(insert into fornec_1099 (cod_fornecedor) values (novo.cod_fornecedor));


create trigger fornec_upd_1099 update on fornecedor referencing
new as novo for each row
(insert into fornec_1099 (cod_fornecedor) values (novo.cod_fornecedor));

-----marcos



create trigger trg_item_upd update on item referencing new as new
    for each row when((new.ies_tip_item = 'F') or (new.ies_tip_item = 'C'))
        (
          insert into item_integr_912 (cod_empresa,cod_item,tipo,data_hora) values
                                      (new.cod_empresa,new.cod_item,'A',current)
        );

drop trigger trg_item_ins;

create trigger trg_item_ins insert on item referencing new as new
    for each row when((new.ies_tip_item = 'F') or (new.ies_tip_item = 'C'))
        (
          insert into item_integr_912 (cod_empresa,cod_item,tipo,data_hora) values
                                      (new.cod_empresa,new.cod_item,'I',current)
        );
        
drop trigger trg_item_del;

create trigger trg_item_del delete on item referencing old as old
    for each row when((old.ies_tip_item = 'F') or (old.ies_tip_item = 'C'))
        (
          insert into item_integr_912 (cod_empresa,cod_item,tipo,data_hora) values
                                      (old.cod_empresa,old.cod_item,'D',current)
        );

 create trigger trg_forn_upd update on fornecedor referencing new as new
    for each row when(new.ies_fornec_ativo = 'I')
        (
          update fornecedor set ies_fornec_ativo = 'A' where cod_fornecedor = new.cod_fornecedor
        );
                