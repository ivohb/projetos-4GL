select * from fornec_1099
select * from fornecedor where ies_fornec_ativo = 'A'
select * from fornecedor where  raz_social like '%TEST%'
select * from fornecedor where  cod_fornecedor = '000272073000132'

update fornecedor set raz_social_reduz = 'MIL T '
 where cod_fornecedor = '000272073000132'

update fornecedor set ies_fornec_ativo = 'I'
 where cod_fornecedor = '000272073000132'

-- DROP procedure pr_fornec01
-- drop trigger tg_fornec_upd
-- drop trigger tg_fornec_ins
-- drop trigger forn_upd_1099
-- drop trigger forn_ins_1099

-- drop trigger fornec_1099_ins
-- DROP procedure upd_teste
select * from orc_mat_prod_1054

CREATE PROCEDURE upd_teste (codigo char(02))

   set isolation to dirty read;

      update teste
         set situacao = 'I'
       where codigo = codigo
         and not exists (select cod_fornecedor from fornec_1099
            where cod_fornecedor = codigo);

END PROCEDURE;

create trigger teste_ins insert on teste
   referencing new as novo for each row (
        execute procedure upd_teste (novo.codigo)
   );


select * from teste
select * from fornec_1099
--delete from fornec_1099
insert into teste(codigo, nome, situacao) values('5','Will','A')