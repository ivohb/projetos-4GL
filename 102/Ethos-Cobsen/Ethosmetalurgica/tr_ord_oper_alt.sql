--- Inclui o numero da ordem de producao na tabela 'ethosm_ops_atualiz'
--- para  o  programa  robo  'gedlogms' atualizar a tabela
--- ethosm_oper_item - campo saldo_a_aptar) tambem no SQLSERVER.

drop trigger     tr_ord_oper_alt;
drop procedure   pr_ord_oper_alt;

create procedure pr_ord_oper_alt

(
n_cod_empresa          char(02),
n_num_ordem            integer,
n_num_seq_operac       decimal(3,0),
n_qtd_planejada        decimal(10,3),
n_qtd_boas             decimal(10,3),
n_qtd_refugo           decimal(10,3),
n_qtd_sucata           decimal(10,3),
o_qtd_planejada        decimal(10,3),
o_qtd_boas             decimal(10,3),
o_qtd_refugo           decimal(10,3),
o_qtd_sucata           decimal(10,3)
)

define v_saldo_ant       decimal(17,3);
define v_saldo_atu       decimal(17,3);

let v_saldo_ant = (o_qtd_planejada - o_qtd_boas - o_qtd_refugo - o_qtd_sucata);

let v_saldo_atu = (n_qtd_planejada - n_qtd_boas - n_qtd_refugo - n_qtd_sucata);

if v_saldo_ant <> v_saldo_atu then

   insert
     into ethosm_ops_atualiz
   select cod_empresa,
          num_ordem,
          num_seq_operac
     from ord_oper
    where cod_empresa   = n_cod_empresa
      and num_ordem     = n_num_ordem
      and num_seq_operac = n_num_seq_operac
      and not exists(
   select *
     from ethosm_ops_atualiz
    where ethosm_ops_atualiz.cod_empresa     = ord_oper.cod_empresa
      and ethosm_ops_atualiz.num_ordem       = ord_oper.num_ordem
      and ethosm_ops_atualiz.num_seq_operac  = ord_oper.num_seq_operac);

end if

end procedure;


create trigger tr_ord_oper_alt update on ord_oper

referencing new as new_rec
            old as old_rec for each row
(
execute procedure pr_ord_oper_alt(new_rec.cod_empresa,
                                   new_rec.num_ordem,
                                   new_rec.num_seq_operac,
                                   new_rec.qtd_planejada,
                                   new_rec.qtd_boas,
                                   new_rec.qtd_refugo,
                                   new_rec.qtd_sucata,
                                   old_rec.qtd_planejada,
                                   old_rec.qtd_boas,
                                   old_rec.qtd_refugo,
                                   old_rec.qtd_sucata)
)
