select * from sup_item_terc_end
select * from fat_retn_item_nf

select * from ordem_montag_tran a, ordem_montag_mest b
where a.cod_empresa = b.cod_empresa and b.ies_sit_om <> 'F' and a.num_om = b.num_om

select * from ordem_montag_tran where num_om = 46252
select * from ordem_montag_mest where num_om = 46252
select * from ldi_retn_terc_grd where ord_montag = 46252



select * from pedidos where cod_empresa = '05'
select * from DESC_PRECO_MEST
select * from LDI_OM_GRADE_COMPL
select * from VDP_CLI_PARAMETRO
SELECT COND_PGTO.IES_TIPO FROM COND_PGTO,PEDIDOS WHERE PEDIDOS.COD_EMPRESA=? AND PEDIDOS.NUM_PEDIDO=? AND COND_PGTO.COD_CND_PGTO=PEDIDOS.COD_CND_PGTO
SELECT SUM( VAL_ADIANT ) FROM ADIANT_CRED WHERE COD_EMPRESA=? AND COD_CLIENTE=? AND IES_POSICAO='A'
SELECT SUM( BXA_ADIANT.VAL_PGTO+BXA_ADIANT.VAL_JURO ) FROM BXA_ADIANT WHERE BXA_ADIANT.COD_EMP_ADIANT=? AND BXA_ADIANT.COD_CLIENTE=?
SELECT SUM( DEV_ADIANT.VAL_DEVOL ) FROM DEV_ADIANT WHERE DEV_ADIANT.COD_EMPRESA=? AND DEV_ADIANT.COD_CLIENTE=?
SELECT VAL_PARAMETRO FROM VDP_CLI_PARAMETRO WHERE CLIENTE=? AND PARAMETRO='ord_montag_antecip'
SELECT VAL_PARAMETRO FROM VDP_CLI_PARAMETRO WHERE CLIENTE=? AND PARAMETRO='dupl_aberta_antecip'
