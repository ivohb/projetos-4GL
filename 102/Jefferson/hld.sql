 OBTER SCRIPT NO ORACLE:
 dIREITO DO MOUSE SOBRE A TABELA + EXPORTAR
 
 create table hld
   (
  hld_linpro char(2 ), 
	hld_istcia char(2 ), 
	hld_empres char(32 ), 
	hld_filial char(12 ), 
	hld_establ char(32 ), 
	hld_banco  char(32 ), 
	hld_undneg char(32 ), 
	hld_espdoc char(32 ), 
	hld_fornec char(32 ), 
	hld_regiao char(32 ), 
	hld_modali char(32 ), 
	hld_moeda  char(32 ), 
	hld_data   datetime, 
	hld_dtemis datetime, 
	hld_serdoc char(8 ), 
	hld_numdoc char(40 ), 
	hld_parcel char(2 ), 
	hld_vcompr decimal(18,2), 
	hld_vvecto decimal(18,2), 
	hld_przvct decimal(10,0), 
	hld_grpfor char(32 ), 
	hld_vsubvc decimal(18,2), 
	hld_livre0 decimal(18,4), 
	hld_livre1 decimal(18,4), 
	hld_livre2 decimal(18,4), 
	hld_livre3 decimal(18,4), 
	hld_livre4 decimal(18,4), 
	hld_livre5 datetime, 
	hld_livre6 datetime, 
	hld_livre7 datetime, 
	hld_livre8 char(50 ), 
	hld_livre9 char(50 )
);

create index ix_hld_linpro on hld(hld_linpro);


“As tabelas que precisam ser alimentadas com o tipo de despesa são:
•	Contas a Pagar - Vencimento (HLD) Kpi10016.4gl
•	Contas a Pagar - Pagamento (HLI) Kpi10017.4gl
•	Contas a Pagar - Carteira (HLK) Kpi10018.4gl
•	Recebimento das Compras (HKM) Kpi10022.4gl
•	Devolução de Compras (HKL) Kpi10023.4gl
•	Compras (HKO) Kpi10021.2.4gl
•	Compras - Carteira (HKQ) Kpi10021.1.4gl”

