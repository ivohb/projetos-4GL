   SELECT UNIQUE
          consumo.cod_empresa,
          consumo.cod_item,
          consumo.cod_roteiro,
          consumo.num_altern_roteiro,
          consumo.num_seq_operac,
          consumo.cod_operac,
          consumo.parametro[1,7]
     FROM consumo
    WHERE consumo.cod_empresa = '01'
    ORDER BY consumo.cod_empresa, consumo.cod_item

   SELECT consumo_txt.num_seq_linha,
          consumo_txt.tex_processo
     FROM consumo_txt,consumo
    WHERE consumo_txt.cod_empresa = '01'
      AND consumo_txt.num_processo = '0000006'
      AND consumo_txt.ies_tipo = 'P'
      AND consumo.cod_empresa = '01'
      AND consumo.cod_item = '10000000010010'
      AND consumo.cod_roteiro = 'PADRAO'
      AND consumo.num_altern_roteiro = 1
      AND consumo.num_seq_operac = '044'
    ORDER BY consumo_txt.num_seq_linha

    select * from consumo where cod_operac= '044' and cod_empresa = '01'

   SELECT consumo_txt.*
     FROM consumo_txt, consumo
    WHERE consumo.cod_empresa = '01'
      AND consumo.cod_operac = '044'
      AND consumo_txt.cod_empresa = consumo.cod_empresa
      AND consumo_txt.num_processo = consumo.parametro[1,7]
      AND consumo_txt.ies_tipo = 'G'
    ORDER BY 2,4


  select * from operacao where cod_empresa = '01' and cod_operac not in (select distinct cod_operac from consumo where cod_empresa = '01')
   SELECT DISTINCT
          parametro[1,7]
     FROM consumo
    WHERE cod_empresa = '01'
      AND cod_operac  = '030'
