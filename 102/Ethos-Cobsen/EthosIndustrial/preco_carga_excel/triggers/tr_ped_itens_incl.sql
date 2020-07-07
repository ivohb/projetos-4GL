--- Inclui o numero do pedido/sequencia na tabela 'ethosi_ped_inclus'
--- para  saber em que dia foi realizada a inclusão.


drop trigger     tr_ped_itens_incl;
drop procedure   pr_ped_itens_incl;

create procedure pr_ped_itens_incl

(
n_cod_empresa          char(02),
n_num_pedido           decimal(6,0),
n_num_sequencia        decimal(5,0)
)

define ja_existe   decimal(10,0);
define v_usuario   char(08);
let v_usuario     = null;


select usuario 
  into v_usuario
  from log_dados_sessao_logix
 where sid = (select dbinfo('sessionid') 
                from systables 
               where tabid=1);
 if v_usuario is null then
    let v_usuario = "admlog";
 end if

select count(*) 
  into ja_existe
  from ethosi_ped_inclus
 where cod_empresa   = n_cod_empresa
   and num_pedido    = n_num_pedido
   and num_sequencia = n_num_sequencia;

if ja_existe = 0 then
   insert  
     into ethosi_ped_inclus
   values(n_cod_empresa, n_num_pedido, 
          n_num_sequencia, today,v_usuario);
end if

end procedure;


create trigger tr_ped_itens_incl insert on ped_itens

referencing new as new_rec for each row
(
execute procedure pr_ped_itens_incl(new_rec.cod_empresa,
                                    new_rec.num_pedido,
                                    new_rec.num_sequencia)
)
