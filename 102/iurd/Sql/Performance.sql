SET ISOLATION TO DIRTY READ
select * from ad_mestre where cod_empresa = '02'
select * from aprov_necessaria
UF = 121030000 Nivel = 30

select * from usu_niv_temp_265
121030000 30 111000000 40

insert into aprov_necessaria (cod_empresa, num_ad, num_versao, num_linha_grade, cod_nivel_autor, cod_uni_funcio, ies_aprovado)
select cod_empresa, num_ad, 1, 1, '30', '121030000', 'N' from ad_mestre where cod_empresa = '02'

       SELECT aprov_necessaria.num_ad,
              aprov_necessaria.num_versao,
              aprov_necessaria.num_linha_grade,
              aprov_necessaria.cod_nivel_autor,
              aprov_necessaria.cod_uni_funcio
         FROM aprov_necessaria, ad_mestre
        WHERE aprov_necessaria.cod_empresa = '02'
          AND aprov_necessaria.num_ad IS NOT NULL
          AND aprov_necessaria.cod_nivel_autor IS NOT NULL
          AND aprov_necessaria.ies_aprovado = 'N'
          AND ad_mestre.cod_empresa = aprov_necessaria.cod_empresa
          AND ad_mestre.num_ad = aprov_necessaria.num_ad
          AND EXISTS
              (SELECT DISTINCT tmp.cod_emp_usuario
                 FROM usu_niv_temp_265 tmp
                WHERE tmp.cod_emp_usuario = aprov_necessaria.cod_empresa
                  AND tmp.cod_nivel_autor = aprov_necessaria.cod_nivel_autor
                  AND tmp.ies_tip_autor = 'H')
        ORDER BY aprov_necessaria.num_ad
