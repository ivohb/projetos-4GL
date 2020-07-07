select * from grupo_skip_lot_5054

select cod_grupo from fornec_item_5054 where cod_empresa = '01' and cod_item = 'PC-0020' and cod_fornecedor = '057482713000156'
select * from fornec_item_5054 where cod_empresa = '01' and cod_grupo = '001' and cod_fornecedor = '057482713000156'
select cod_grupo from fornec_item_5054 where cod_empresa = '01' and cod_item = '99.999.8099' and cod_fornecedor = '056690498000116'

select * from fornec_item_5054
select * from item_fornec where  cod_fornecedor = '057482713000156' and cod_item = 'PC-0010'
select * from item_fornec where  cod_fornecedor = '057482713000156' and cod_item = 'PC-0020'
select * from item_fornec where cod_empresa = '01' and cod_fornecedor = '043007434000126' and cod_item in ('PA-0001', 'PC-0020')
select * from item_fornec where cod_empresa = '01' and cod_fornecedor = '056690498000116' and cod_item in ('99.999.8099', 'PC-0020')

select * from item_barra where cod_empresa = '01' and cod_item in ('PC-0010', 'PC-0020', 'PA-0001')  --  reservado_03[1,1]=’S’)


select * from nf_sup where cod_empresa = '01' and num_aviso_rec = 4
select * from aviso_rec where cod_empresa = '01' and num_aviso_rec = 4 and num_seq = 3

update aviso_rec set ies_liberacao_cont = 'S' where cod_empresa = '01' and num_aviso_rec = 4 and num_seq = 3
update aviso_rec set ies_liberacao_insp = 'S' where cod_empresa = '01' and num_aviso_rec = 4 and num_seq = 3
update aviso_rec set qtd_recebida = 10 where cod_empresa = '01' and num_aviso_rec = 4
select * from teste

drop trigger skip_lot;
create trigger skip_lot update on aviso_rec
   referencing new as novo old as velho for each row
    when((velho.ies_liberacao_cont = 'N') and (novo.ies_liberacao_cont = 'S'))
   (execute procedure grava_fornec(
      novo.cod_empresa, novo.num_aviso_rec, novo.cod_item));

drop procedure grava_fornec
create procedure grava_fornec
   (
      p_cod_empresa char(02),
      p_num_ar      integer,
      p_cod_item    char(15)
   )

   define p_cod_fornecedor char(15);
   define p_qtd_entr_sem_insp decimal(10,3);
   define p_cod_grupo char(03);

   set isolation to dirty read;

   select cod_fornecedor
     into p_cod_fornecedor
     from nf_sup
    where cod_empresa = p_cod_empresa
      and num_aviso_rec = p_num_ar;

   select qtd_entr_sem_insp
     into p_qtd_entr_sem_insp
     from item_fornec
    where cod_empresa = p_cod_empresa
      and cod_fornecedor = p_cod_fornecedor
      and cod_item = p_cod_item;

   select cod_grupo
     into p_cod_grupo
     from fornec_item_5054
    where cod_empresa = p_cod_empresa
      and cod_fornecedor = p_cod_fornecedor
      and cod_item = p_cod_item;

   if p_cod_grupo is null or p_cod_grupo = ' ' then
      insert into teste values(p_cod_fornecedor, 'ivo', p_num_ar);
   else
      insert into teste values(p_cod_fornecedor, p_cod_grupo, p_qtd_entr_sem_insp);
   end if;

end procedure;

select * from teste

create table teste(
 cod_fornecedor char(15),
 cod_item char(15),
 qtd_entr_sem_insp decimal(10,3)
)