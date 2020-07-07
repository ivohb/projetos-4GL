{ TABLE "admlog".spe_contab_prod row size = 53 number of columns = 7 index size = 
              0 }
create table "admlog".spe_contab_prod 
  (
    cod_item varchar(15),
    ies_tip_item varchar(1),
    subtotal decimal(12,4),
    icms decimal(12,4),
    piscofins decimal(12,4),
    total decimal(12,4),
    custo_arb decimal(12,4)
  );
revoke all on "admlog".spe_contab_prod from "public" as "admlog";




