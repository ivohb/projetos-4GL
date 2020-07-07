SET ISOLATION TO DIRTY READ
-- delete from meio_inspecao_1120
select * from consumo where cod_empresa = '01' and cod_item in (select cod_item from item where cod_empresa = '01')
 select * from plan_inspecao_1120 where cod_item = '0010045002A-01'
   order by cod_item, cod_roteiro, cod_operac, num_seq_operac, sequencia_cota

 select * from plan_inspecao_1120 where cod_item = '0010045000T-01'
   order by cod_item, cod_roteiro, cod_operac, num_seq_operac, sequencia_cota

   SELECT COUNT(cod_empresa)
     FROM meio_copia_1120

   select * from meio_copia_1120
select * from meio_inspecao_1120 where cod_item = '0010045002A-01'
order by cod_item, cod_roteiro, cod_operac, num_seq_operac, sequencia_cota

select * from meio_inspecao_1120 where cod_item = '0010045000T-01'
order by cod_item, cod_roteiro, cod_operac, num_seq_operac, sequencia_cota

select * from plan_temp_1120
select * from meio_temp_1120

select * from consumo where cod_empresa = '01' and cod_item = '0010045002A-01' order by cod_item, cod_operac

select min(num_cota) from plan_inspecao_1120 where cod_item = '0010045002A-01'


   ALTER TABLE meio_inspecao_1120 ADD cota decimal(6,0)


   CREATE TABLE meio_copia_1120
  (
    cod_empresa    char(2) not null ,
    cod_item       char(15) not null ,
    cod_operac     char(5) not null ,
    num_seq_operac decimal(3,0) not null ,
    cod_roteiro    char(15) not null ,
    num_cota       decimal(6,0) not null ,
    sequencia_cota decimal(6,0) not null ,
    meio_inspecao  char(15) not null,
    cota           decimal(6,0)
  );
