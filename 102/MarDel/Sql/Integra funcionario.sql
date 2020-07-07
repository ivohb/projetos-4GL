SET ISOLATION TO DIRTY READ
O MIN1500 é o cadastro do parâmetro... e o MIN1510 é a manutenção dos valores dos parâmetros.
select * from min_par_modulo
select * from item_ppap_970
select * from ciclo_peca_5054
select * from uni_funcional order by cod_uni_funcio
select * from cargo where cod_empresa = '01'  order by cod_cargo
select * from turno
select * from escala where cod_empresa = '01'
select * from func_rm_5054
select * from func_erro_5054
select * from logix.funcionario where num_matricula = 1112
select * from funcionario where num_matricula = 1111
select * from fun_infor where num_matricula = 1111
select * from rhu_fic_sal_funcio where matricula in (953,954)
select * from fun_diversos where num_matricula in (953,954)
select * from fun_contrato where num_matricula in (953,954)
select * from fun_salario where num_matricula in (953,954)
select * from fun_identidade where num_matricula in (953,954)
select * from fun_sindicato where num_matricula in (953,954)
select * from fun_espelho_ponto where num_matricula in (953,954)
select * from rhu_funcio_nom where matricula in (953,954)
select * from alterac_saude where num_matricula in (953,954)
select * from rhu_fun_previdenc  where matricula in (953,954)
select * from sil_dimensao_funcio where matricula in (953,954)
select * from rhu_ficha_quadro_funcional where matricula in (953,954)
select * from rhu_audit_tab_rhu where matricula in (953,954)
select * from rhu_funcio_login where matricula in (953,954)
select * from rhu_fic_uni_func where matricula in (953,954)

insert into funcionario
insert into fun_infor
insert into fun_fonetica
insert into rhu_fic_uni_func
insert into rhu_fic_sal_funcio
insert into fun_diversos
insert into fun_contrato
insert into fun_salario
insert into fun_identidade
insert into fun_sindicato
insert into fun_espelho_ponto
insert into rhu_funcio_login
insert into rhu_funcio_nom
insert into alterac_saude
insert into rhu_fun_previdenc
insert into sil_dimensao_funcio
insert into rhu_ficha_quadro_funcional
insert into rhu_audit_tab_rhu

