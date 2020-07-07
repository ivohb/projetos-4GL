  SELECT nom_caminho, ies_ambiente   FROM path_logix_v2   WHERE cod_empresa = '01'  AND cod_sistema = 'UNL'
SET ISOLATION TO DIRTY READ
-- delete from arq_banco_265 WHERE COD_STATUS = 'P'
select * from banco_265
select * from tip_acerto_265
select * from evento_265
select * from layout_265
select * from arq_banco_265
select * from diverg_consig_265
select * from obs_consig_265
select * from contr_consig_265
select * from carga_erro_265
select * from hist_movto_265
select * from tip_acerto_265
select * from alerta_consig_265
select * from contr_audit_265

 DELETE FROM diverg_consig_265
    WHERE TO_CHAR(dat_referencia, 'YYYY-MM') = '2013-01'
      AND cod_banco = 654

  SELECT a.cod_empresa,
          a.num_matricula,
          a.dat_referencia,
          a.cod_tip_proc,
          a.cod_categoria,
          a.cod_evento,
          a.dat_pagto,
          a.ies_calculado,
          a.qtd_horas,
          a.val_evento,
          b.num_cpf
     FROM hist_movto a , fun_infor b
    WHERE TO_CHAR(a.dat_referencia, 'YYYY-MM') = '2013-01'
      AND a.cod_evento IN
          (SELECT DISTINCT cod_evento
             FROM evento_265
            WHERE cod_banco = 654
              AND tip_evento IN (1,4))
      AND b.cod_empresa = a.cod_empresa
      AND b.num_matricula = a.num_matricula
     ORDER BY num_matricula, cod_empresa

select *  FROM funcionario  where cod_empresa = '01' order by 2
 and num_matricula in (select num_matricula from fun_infor where cod_empresa = '01')

select *  FROM fun_infor  where cod_empresa = '01' order by 2
 and num_matricula in (select num_matricula from hist_movto where cod_empresa = '01')

 select * from fun_infor order by 2
select * from ultimo_proces
update hist_movto set dat_referencia = '01/01/2013' where dat_referencia = '01/03/2009'
select * from hist_movto where dat_referencia = '01/01/2013'

   SELECT COUNT(id_registro)
     FROM diverg_consig_265
    WHERE dat_referencia = '01/01/2013'
      AND dat_acerto_prev IS NOT NULL
      AND cod_banco = 654

      select * from diverg_consig_265
      select * from arq_banco_265
      select * from contr_consig_265

   DELETE FROM contr_consig_265
     WHERE cod_banco = 654
       AND id_arq_banco in
      (select id_registro FROM arq_banco_265
        WHERE dat_referencia >= '01/01/2013' AND cod_banco = 654 )


   DELETE FROM arq_banco_265
    WHERE dat_referencia >= '01/01/2013'
      AND cod_banco = 654

   DELETE FROM diverg_consig_265
    WHERE dat_referencia >= '01/01/2013'
      AND cod_banco = 654

