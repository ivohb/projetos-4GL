   SELECT UNIQUE 
          consumo.cod_empresa, 
          consumo.cod_item, 
          consumo.cod_roteiro, 
          consumo.num_altern_roteiro, 
          consumo.num_seq_operac, 
          consumo.cod_operac, 
          consumo_txt.ies_tipo 
     FROM consumo, consumo_txt  
    WHERE consumo_txt.cod_empresa  = consumo.cod_empresa    
      AND consumo_txt.num_processo = consumo.parametro[1,7]  
    ORDER BY consumo.cod_empresa, consumo.cod_item

  SELECT DEN_OPERAC 
  FROM OPERACAO WHERE OPERACAO.COD_EMPRESA=? AND OPERACAO.COD_OPERAC=?

   SELECT consumo_txt.num_seq_linha, 
          consumo_txt.tex_processo 
     FROM consumo_txt,consumo 
    WHERE consumo_txt.cod_empresa =  
      AND consumo_txt.num_processo = consumo.parametro[1, 7] 
      AND consumo_txt.ies_tipo =  
      AND consumo.cod_empresa = consumo_txt.cod_empresa 
      AND consumo.cod_item =  
      AND consumo.cod_roteiro =  
      AND consumo.num_altern_roteiro =  
      AND consumo.num_seq_operac =  
    ORDER BY consumo_txt.num_seq_linha
  
create
