---Esta rotina esta na trigger tr_ordens que esta em \Ethos Met\Transferencias\trigger
---rotina que inclui o número da ordem na tabela 'ethosm_ops_atualiz' para o Robo 
---'ATULOGMS atualizar os dados da pagina web consulta do acompanhamento da producao 

insert 
  into ethosm_ops_atualiz
select cod_empresa,
       num_ordem,
       '1'
  from ordens
 where cod_empresa     = n_cod_empresa
   and num_ordem       = n_num_ordem
   and not exists(
select * 
  from ethosm_ops_atualiz
 where ethosm_ops_atualiz.cod_empresa = ordens.cod_empresa
   and ethosm_ops_atualiz.num_ordem   = ordens.num_ordem);
