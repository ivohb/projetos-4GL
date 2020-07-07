C:\Users\totvs.INTRANET\Documents\TDS\Workspace
logix teste: D:\Totvs\logix\apo\tst\20180816_01
Compilação: D:\Totvs\logix\apo\atu_prd
select * from cfp_parm
select * from log_versao_prg where num_programa = 'POL1365'
select * from proces_apont_405
select * from exec_proces_405
select * from man_apo_nest_405
select * from man_erro_405
select * from man_apo_logix_405
select * from local
select * from item_sucata_405
select * from item where cod_empresa = '06' and gru_ctr_estoq = 99
select * from item where cod_empresa = '06' and cod_item = '10-998-00001' -- sucata 99
select * from item where cod_empresa = '06' and gru_ctr_estoq = 99
select * from item where cod_empresa = '06' and cod_item in ( '55-200-05614' , '10-998-00001' , '10-510-05052' )
select * from estoque where cod_empresa = '06' and cod_item in ('55-200-00990','10-510-12048')
select * from estoque_lote where cod_empresa = '06' and cod_item in ('55-200-00990','10-510-12048')
select * from estoque_lote_ender where cod_empresa = '06' and cod_item in ('55-200-00990','10-510-12048')
select * from estoque_trans where cod_empresa = '06' and num_docum = '8851766' order by num_transac
select * from item where cod_empresa = '06' and cod_item in ('55-200-00990','10-510-12048')
select * from item_man where cod_empresa = '06' and cod_item in ('55-200-00990','10-510-12048')
select * from man_apo_nest_405   select * from man_apo_logix_405
select * from ordens where cod_empresa = '06' and num_ordem in ( 7737502 , 8851766  )
select * from ord_oper where cod_empresa = '06' and num_ordem in ( 7737502 , 8851766  )
select * from necessidades where   cod_empresa = '06' and num_ordem = 8851766
select * from ord_compon where   cod_empresa = '06' and num_ordem = 8851766 -- 10-510-12048 9114
select * from ord_oper where   cod_empresa = '06' and num_ordem = 8851766
select * from man_op_componente_operacao where   empresa = '06' and ordem_producao = 8851766
select * from estoque_trans where cod_empresa = '06' and num_docum = '7737502' order by num_transac

select max(* from exec_proces_405




select * from estoque where cod_empresa = '06' and cod_item = '10-510-12048' -- 18821,938 0,012
select * from estoque_lote where cod_empresa = '06' and cod_item = '10-510-12048'
select * from estoque_lote_ender where cod_empresa = '06' and cod_item = '10-510-12048'
