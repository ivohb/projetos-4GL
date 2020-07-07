select * from cracha_imp_265
select  * from rhu_funcio_foto where empresa = '01' and matricula <= 10
select  * from funcionario where cod_empresa = '01' and num_matricula <= 10
select * from unidade_funcional

insert into cracha_imp_265 select cod_empresa ,num_matricula, nom_funcionario,'31/12/2012'
    from funcionario where cod_empresa = '01' and num_matricula <= 10

       SELECT cod_empresa, num_matricula, nom_funcionario
         FROM funcionario

        ORDER BY nom_funcionario
