
create trigger tg_ordem_sup_1099 update on SUP_PAR_OC
   referencing new as novo for each row
    when((novo.parametro='dat_ult_designacao'))
   (execute procedure pr_cotacao_1099(
      novo.empresa, novo.ordem_compra));



create trigger tg_ins_ordem_sup_1099 insert on SUP_PAR_OC
   referencing new as novo for each row
    when((novo.parametro='dat_ult_designacao'))
   (execute procedure pr_cotacao_1099(
      novo.empresa, novo.ordem_compra));



create procedure pr_cotacao_1099
  (
   p_cod_empresa           char(02),
   p_num_ordem             DECIMAL(9,0)
  )

  define p_pre_ant         decimal(12,2);
  define p_num_oc          integer;
  define p_count           integer;
  define p_cod_item        char(15);
  define p_pre_unit        decimal(12,2);
  define p_ies_situa_oc    char(01);
  define p_cod_familia     char(03);
  define p_causa           char(80);

  set isolation to dirty read;

  select cod_item, pre_unit_oc, ies_situa_oc 
    into p_cod_item, p_pre_unit, p_ies_situa_oc
   from ordem_sup
  where cod_empresa = p_cod_empresa
    and num_oc = p_num_ordem
    and ies_versao_atual = 'S'
    and num_pedido = 0;

  if p_ies_situa_oc <> 'A' then
     return;
  end if;

  select cod_familia
    into p_cod_familia
   from item
  where cod_empresa = p_cod_empresa
    and cod_item = p_cod_item;
   
   select count(cod_familia) into p_count
     from familia_oc_1099
    where cod_empresa = p_cod_empresa
      and cod_familia = p_cod_familia;

   IF p_count = 0 THEN
      return;
   END IF;

   select count(tip_liberac) into p_count
     from oc_bloqueada_1099
    where cod_empresa = p_cod_empresa
      and num_oc = p_num_ordem
      and tip_liberac IN ('A','C')

   IF p_count > 0 THEN
      return;
   END IF;
   
  let p_num_oc = 0;
  let p_pre_ant = 0;
  let p_causa = 'PRIMEIRA COMPRA';

  FOREACH select ordem_sup.pre_unit_oc, ordem_sup.num_oc into p_pre_ant, p_num_oc
     FROM ordem_sup, pedido_sup
    WHERE ordem_sup.cod_empresa = p_cod_empresa
      AND ordem_sup.cod_item = p_cod_item
      AND ordem_sup.num_pedido > 0
      AND ordem_sup.ies_situa_oc IN ('R','L')
      AND ordem_sup.ies_versao_atual  = 'S'
      AND pedido_sup.cod_empresa      = ordem_sup.cod_empresa
      AND pedido_sup.num_pedido       = ordem_sup.num_pedido
      AND pedido_sup.ies_versao_atual = 'S'
      AND pedido_sup.ies_situa_ped IN ('R','L')
    ORDER BY ordem_sup.dat_emis DESC, ordem_sup.num_pedido DESC
    
    let p_causa = 'PRECO MAIOR QUE ULTIMA COMPRA';
    
    select count(tip_liberac) into p_count
      from oc_bloqueada_1099
     where cod_empresa = p_cod_empresa
       and num_oc = p_num_oc
       and tip_liberac = 'C';

    IF p_count = 0 THEN
       exit FOREACH;
    END IF;

  END FOREACH;
  
  if p_pre_unit > p_pre_ant then
     update ordem_sup
        set ies_situa_oc = 'X'
      where cod_empresa = p_cod_empresa
        and num_oc = p_num_ordem
        and ies_versao_atual = 'S';
     
     delete from oc_bloqueada_1099
      where cod_empresa = p_cod_empresa and num_oc = p_num_ordem;
     
     insert into oc_bloqueada_1099(cod_empresa, num_oc, pre_unit_oc, pre_unit_ant, causa, tip_liberac, oc_pre_ant)
      values(p_cod_empresa, p_num_ordem, p_pre_unit, p_pre_ant, p_causa, 'N', p_num_oc);

  end if;

end procedure;





