
SELECT
equipamento.cod_equip,
cent_trabalho.den_cent_trab,
"FINITO" AS finito_infinito,
CASE
WHEN equipamento.cod_uni_funcio[1,5]='11714' THEN "1"
WHEN equipamento.cod_uni_funcio[1,5]='11715' THEN "2"
WHEN equipamento.cod_uni_funcio[1,5]='11716' THEN "3"
END AS posicao,
CAST(85 AS INT) AS eficiencia,
CASE
WHEN equipamento.cod_uni_funcio[1,5]='11714' THEN "ESTAMPARIA"
WHEN equipamento.cod_uni_funcio[1,5]='11715' THEN "SOLDA"
WHEN equipamento.cod_uni_funcio[1,5]='11716' THEN "USINAGEM"
END AS setor
FROM equipamento 
LEFT JOIN cent_trabalho
ON cent_trabalho.cod_empresa=equipamento.cod_empresa
AND cent_trabalho.cod_cent_trab=equipamento.cod_cent_trab
WHERE equipamento.cod_empresa='01'
AND equipamento.cod_uni_funcio[1,7] IN ('1171401','1171501','1171601')
ORDER BY SETOR, cent_trabalho.cod_cent_trab desc

LEFT JOIN min_eqpto_compl
ON equipamento.cod_empresa=min_eqpto_compl.empresa
AND equipamento.cod_equip=min_eqpto_compl.eqpto
WHERE equipamento.cod_empresa='01'
AND equipamento.cod_uni_funcio[1,7] IN ('1171401','1171501','1171601')
AND min_eqpto_compl.val_logico="S"
AND min_eqpto_compl.campo="ATIVO"

   SELECT equipamento.cod_equip, 
          cent_trabalho.den_cent_trab, 
          cent_trabalho.cod_cent_trab,
          CASE
             WHEN equipamento.cod_uni_funcio[1,5]='11714' THEN "1"
             WHEN equipamento.cod_uni_funcio[1,5]='11715' THEN "2"
             WHEN equipamento.cod_uni_funcio[1,5]='11716' THEN "3"
          END AS posicao,
          CASE
             WHEN equipamento.cod_uni_funcio[1,5]='11714' THEN "ESTAMPARIA"
             WHEN equipamento.cod_uni_funcio[1,5]='11715' THEN "SOLDA"
             WHEN equipamento.cod_uni_funcio[1,5]='11716' THEN "USINAGEM"
          END AS setor
     FROM equipamento 
          LEFT JOIN cent_trabalho
             ON cent_trabalho.cod_empresa = equipamento.cod_empresa
            AND cent_trabalho.cod_cent_trab = equipamento.cod_cent_trab
          INNER JOIN min_eqpto_compl
             ON equipamento.cod_empresa = min_eqpto_compl.empresa
            AND equipamento.cod_equip = min_eqpto_compl.eqpto
            AND min_eqpto_compl.val_logico = 'S'
            AND min_eqpto_compl.campo = 'ATIVO'   
    WHERE equipamento.cod_empresa = '01'
      AND equipamento.cod_uni_funcio[1,7] IN ('1171401','1171501','1171601')
    ORDER BY setor, cent_trabalho.cod_cent_trab desc

SELECT
eg.cod_item_pai,
eg.cod_item_compon,
eg.qtd_necessaria,
"SIM" AS multil,
"NAO" AS ignorar
FROM estrut_grade eg
LEFT JOIN item i ON i.cod_empresa=eg.cod_empresa AND i.cod_item=eg.cod_item_pai
LEFT JOIN man_processo_item mp ON mp.empresa=eg.cod_empresa AND mp.item=eg.cod_item_pai
WHERE
eg.cod_empresa='01'
AND i.ies_situacao='A'
AND i.ies_tip_item='P'
AND mp.validade_final IS NULL
