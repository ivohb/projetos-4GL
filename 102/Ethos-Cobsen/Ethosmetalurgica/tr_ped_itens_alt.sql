--- Inclui o numero do pedido na tabela 'ethosm_ped_atualiz'
--- para  o  programa  robo  'gedlogms' atualizar a tabela
--- 'ethosm_oper_item' - campo saldo_item_ped) tambem no SQLSERVER.


drop trigger     tr_ped_itens_alt;
drop procedure   pr_ped_itens_alt;

create procedure pr_ped_itens_alt

(
n_cod_empresa          char(02),
n_num_pedido           decimal(6,0),
n_num_sequencia        decimal(5,0),
n_qtd_pecas_solic      decimal(10,3),
n_qtd_pecas_atend      decimal(10,3),
n_qtd_pecas_cancel     decimal(10,3),
o_qtd_pecas_solic      decimal(10,3),
o_qtd_pecas_atend      decimal(10,3),
o_qtd_pecas_cancel     decimal(10,3)
)

define v_saldo_ant       decimal(17,3);
define v_saldo_atu       decimal(17,3);

let v_saldo_ant = (o_qtd_pecas_solic - o_qtd_pecas_atend - o_qtd_pecas_cancel);

let v_saldo_atu = (n_qtd_pecas_solic - n_qtd_pecas_atend - n_qtd_pecas_cancel);

if v_saldo_ant <> v_saldo_atu then

   insert
     into ethosm_ped_atualiz
   select cod_empresa,
          num_pedido,
          num_sequencia
     from ped_itens
    where cod_empresa   = n_cod_empresa
      and num_pedido    = n_num_pedido
      and num_sequencia = n_num_sequencia
      and not exists(
   select *
     from ethosm_ped_atualiz
    where ethosm_ped_atualiz.cod_empresa                   = ped_itens.cod_empresa
      and cast(ethosm_ped_atualiz.pedido as decimal(10,0)) = ped_itens.num_pedido
      and ethosm_ped_atualiz.sequencia_ped                 = ped_itens.num_sequencia);

end if

end procedure;


create trigger tr_ped_itens_alt update on ped_itens

referencing new as new_rec
            old as old_rec for each row
(
execute procedure pr_ped_itens_alt(new_rec.cod_empresa,
                                   new_rec.num_pedido,
                                   new_rec.num_sequencia,
                                   new_rec.qtd_pecas_solic,
                                   new_rec.qtd_pecas_atend,
                                   new_rec.qtd_pecas_cancel,
                                   old_rec.qtd_pecas_solic,
                                   old_rec.qtd_pecas_atend,
                                   old_rec.qtd_pecas_cancel)
)
