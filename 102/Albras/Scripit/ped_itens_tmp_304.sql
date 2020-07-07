{ TABLE "admlog".ped_itens_tmp_304 row size = 33 number of columns = 5 index size 
              = 0 }
create table "admlog".ped_itens_tmp_304 
  (
    num_pedido decimal(6,0),
    num_seq decimal(3,0),
    cod_item char(15),
    qtd_saldo decimal(10,3),
    dat_entrega date
  );
revoke all on "admlog".ped_itens_tmp_304 from "public" as "admlog";




