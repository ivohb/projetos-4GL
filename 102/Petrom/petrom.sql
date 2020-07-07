
select * from it_analise_petrom

select * from especific_petrom

 SELECT den_item_petrom
     FROM item_petrom
    WHERE cod_empresa     = '01'

 select * from item_petrom

  SELECT *
      FROM especific_petrom
     WHERE cod_empresa  = '01'
       AND cod_item     = '110011'
       AND cod_cliente IS NULL
       AND tip_analise  = '1'

 select * from especific_petrom

 select * from analise_petrom

 select * from validade_lote_455

INSERT INTO validade_lote_455
        VALUES(p_cod_empresa,
               mr_tela.cod_item,
               mr_tela.lote_tanque,
               mr_tela.dat_fabricacao)

create table validade_lote_455(
   cod_empresa      char(02) not null,
   cod_item         char(15) not null,
   lote_tanque      char(10) not null,
   dat_fabricacao   date     not null
);

create unique index ix_validade_lote_455
   on validade_lote_455(cod_empresa, cod_item, lote_tanque);

select * from analise_petrom

 DELETE FROM analise_petrom
       WHERE cod_empresa = '01'
         AND cod_item    = '110011'
         AND dat_analise = '9/11/2010'
         AND lote_tanque = '1'
         AND num_pa      is null

        INSERT INTO analise_petrom
            VALUES ('01',
                    '110011',
                    '9/11/2010',
                    '12:43:35',
                    '1',
                    1,
                    '',
                    '1',
                    1)

    SELECT *
      FROM par_laudo_petrom
     WHERE cod_empresa  = '01'
       AND cod_item     = '110011'
       AND cod_cliente IS NULL

   SELECT *
     FROM it_analise_petrom
    WHERE cod_empresa = '01'
      AND tip_analise = '1'

    SELECT a.tip_analise, b.den_analise
      FROM it_analise_petrom b, especific_petrom a
     WHERE a.cod_empresa = b.cod_empresa
       AND a.tip_analise = b.tip_analise
       AND a.cod_empresa = '01'
       AND a.cod_item    = '110011'

    SELECT tip_analise, den_analise
      FROM it_analise_petrom
     WHERE cod_empresa = '01'

    select * from especific_petrom

   SELECT a.cliente, a.trans_nota_fiscal, b.nom_cliente
     FROM fat_nf_mestre a, clientes b
    WHERE a.empresa     = '01'
      AND a.nota_fiscal = '2'
      AND a.cliente     = b.cod_cliente


       SELECT item
         FROM fat_nf_item
        WHERE empresa           = '01'
          AND trans_nota_fiscal = '2'
          AND item              = '1310582000A-22'

       select * from fat_nf_item

       select * from item_refer_petrom

     select * from analise_petrom

     SELECT cod_empresa
       FROM analise_petrom
      WHERE cod_empresa = '01'
        AND cod_item    = '1310582000A-22'
        AND lote_tanque = '1'

         SELECT *
           FROM fat_nf_mestre
          WHERE empresa     = '01'
            AND nota_fiscal = '1'

         select * from pa_laudo_petrom