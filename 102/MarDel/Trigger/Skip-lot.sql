
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
   else
      update item_fornec set qtd_entr_sem_insp = p_qtd_entr_sem_insp
       where cod_empresa    = p_cod_empresa 
         and cod_fornecedor = p_cod_fornecedor
         and cod_item in
             (select cod_item from fornec_item_5054
               where cod_empresa = p_cod_empresa
                 and cod_grupo = p_cod_grupo);
   end if;
  
end procedure;

create trigger skip_lot update on aviso_rec 
   referencing new as novo old as velho for each row 
    when((velho.ies_liberacao_cont = 'N') and (novo.ies_liberacao_cont = 'S'))
   (execute procedure grava_fornec(
      novo.cod_empresa, novo.num_aviso_rec, novo.cod_item));
