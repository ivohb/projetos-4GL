SELECT NUMORDEM, SUM(QTDCONSUMO) FROM CONS_PAPEL_885 WHERE NUMSEQUENCIA IN (
select NUMSEQUENCIA from cons_erro_885 where datconsumo >= '01/10/2014' AND datconsumo <= '31/10/2014'
  AND MENSAGEM LIKE 'NAO EXISTE OF DA CHAPA%'
)
 GROUP BY NUMORDEM

select * from cons_erro_885 where datconsumo >= '01/10/2014' AND datconsumo <= '31/10/2014'

SELECT * FROM cons_papel_885  WHERE codempresa ='O1' and numsequencia = 5772487

select * from cons_erro_885 where datconsumo in
(
SELECT *  FROM cons_papel_885  WHERE codempresa ='O1' and numsequencia in (5710123, 5751140)
 AND StatusRegistro = '3'
 AND datconsumo >= '01/09/2014' AND datconsumo <= '30/09/2014'
 )



update cons_papel_885 set StatusRegistro = '2'  WHERE codempresa ='O1'
 AND StatusRegistro = '0'
 AND datconsumo >= '01/09/2014' AND datconsumo <= '30/09/2014'

  select * from cons_papel_885
    WHERE codempresa     = 'O1'
      AND StatusRegistro = '0'
      AND datconsumo IN
          (SELECT dat_consumo
             FROM dat_consumo_885
            WHERE cod_empresa = 'O1'
              AND cod_status  = 'S')

1847516 SUBIU

AP AGUARDANDO 4862667,215
ESTORNO AGUA  3850213,215


SELECT SUM(QTDCONSUMIDA) FROM cons_insumo_885 WHERE DATCONSUMO >= '01/01/2015' AND DATCONSUMO <= '31/01/2015'
  AND ESTORNO = 1 AND STATUSREGISTRO = 0


select * FROM estoque_trans
WHERE estoque_trans.cod_empresa='02'
AND estoque_trans.cod_operacao IN ('AR','TRGD','INSP')
and num_docum='49571'
order by num_docum,num_seq,cod_operacao