create table  gi_param_ar_912 
   (           
   cod_tipo_obrigacao  integer,
   den_parametro       varchar2(100 byte) not null, 
   cod_operacao        char(7 byte) not null, 
   cod_item            char(15 byte) not null, 
   especie_nf          CHAR(03),
   cnd_pgto            DECIMAL(4,0),
   cod_uni_funcio      CHAR(10),
   primary key (cod_tipo_obrigacao )

);

