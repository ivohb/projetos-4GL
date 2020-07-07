--- Gerar registro na tabela  ethosm_alt_odoper_txt
--- para o robo atulogms atualizar as datas limites
--- na tabela ethosm_oper_item no sqlservrer.

drop trigger     tr_ord_oper_txI;
drop trigger     tr_ord_oper_txU;
drop trigger     tr_ord_oper_txD;

drop procedure   pr_ord_oper_txt;

create procedure pr_ord_oper_txt

(
n_cod_empresa          char(02),
n_num_ordem            decimal(15,0),
n_num_processo         decimal(15,0),
n_ies_tipo             char(01),
n_num_seq_linha        decimal(4,0),
n_texo_processo_geral  char(4000),
n_tipo_proc            char(01)
)

define existe_reg      decimal(17,3);


if n_tipo_proc = "I" and n_ies_tipo = "Q" and n_num_seq_linha = 1 then

   delete from ethosm_alt_odoper_txt
    where cod_empresa   = n_cod_empresa
      and num_ordem     = n_num_ordem
      and num_processo  = n_num_processo;
   
   insert 
     into ethosm_alt_odoper_txt 
   values(n_cod_empresa,
          n_num_ordem,
          n_num_processo,
          n_texo_processo_geral[1,10]);
end if


if n_tipo_proc = "U" and n_ies_tipo = "Q" and n_num_seq_linha = 1 then

   let existe_reg = 0;

   select count(*) 
     into existe_reg
     from ethosm_alt_odoper_txt
    where cod_empresa           = n_cod_empresa
      and num_ordem             = n_num_ordem
      and num_processo          = n_num_processo;

   if existe_reg > 0 then
      update ethosm_alt_odoper_txt
         set texto_processo_geral  = n_texo_processo_geral[1,10]
       where cod_empresa           = n_cod_empresa
         and num_ordem             = n_num_ordem
         and num_processo          = n_num_processo
         and texto_processo_geral <> n_texo_processo_geral[1,10];
   end if

   if existe_reg = 0 then
      insert 
        into ethosm_alt_odoper_txt 
      values(n_cod_empresa,
             n_num_ordem,
             n_num_processo,
             n_texo_processo_geral[1,10]);
   end if

end if 

if n_tipo_proc = "D" and n_ies_tipo = "Q" and n_num_seq_linha = 1 then

   let existe_reg = 0;

   select count(*) 
     into existe_reg
     from ethosm_alt_odoper_txt
    where cod_empresa           = n_cod_empresa
      and num_ordem             = n_num_ordem
      and num_processo          = n_num_processo;

   if existe_reg > 0 then
      update ethosm_alt_odoper_txt
         set texto_processo_geral  = '01/01/1990'
       where cod_empresa           = n_cod_empresa
         and num_ordem             = n_num_ordem
         and num_processo          = n_num_processo;
   end if

   if existe_reg = 0 then
      insert 
        into ethosm_alt_odoper_txt 
      values(n_cod_empresa,
             n_num_ordem,
             n_num_processo,
             '01/01/1990');
   end if
   
end if


 
end procedure;


create trigger tr_ord_oper_txI insert on ord_oper_txt

referencing new as new_rec for each row 
(
execute procedure pr_ord_oper_txt(new_rec.cod_empresa,
                                  new_rec.num_ordem,
                                  new_rec.num_processo,
                                  new_rec.ies_tipo,
                                  new_rec.num_seq_linha,
                                  new_rec.texto_processo_geral,
                                  'I')
);

create trigger tr_ord_oper_txU update on ord_oper_txt

referencing new as new_rec for each row 
(
execute procedure pr_ord_oper_txt(new_rec.cod_empresa,
                                  new_rec.num_ordem,
                                  new_rec.num_processo,
                                  new_rec.ies_tipo,
                                  new_rec.num_seq_linha,
                                  new_rec.texto_processo_geral,
                                  'U')
);

create trigger tr_ord_oper_txD delete on ord_oper_txt

referencing old as old_rec for each row 
(
execute procedure pr_ord_oper_txt(old_rec.cod_empresa,
                                  old_rec.num_ordem,
                                  old_rec.num_processo,
                                  old_rec.ies_tipo,
                                  old_rec.num_seq_linha,
                                  old_rec.texto_processo_geral,
                                  'D')
);
