SET ISOLATION TO DIRTY READ
select * from erro_contagem_1099
select * from empresa_manut_ind_1099
select * from grupo_ativ_manut_ind_1099
select * from usuario_manut_ind_1099

select * from item where cod_empresa = '01' and cod_item = '160080600306'         Final 50 peças faturadas
select * from estrutura where cod_empresa = '01' and cod_item_pai = '160080600300'
 select * from estrutura where cod_empresa = '01' and cod_item_pai = '16008060030010'

    select * from estrutura where cod_empresa = '01' and cod_item_pai = '160080600302'      -- tipo B
       select * from estrutura where cod_empresa = '01' and cod_item_pai = '160000600302'
          select * from estrutura where cod_empresa = '01' and cod_item_pai = '160000600301'
              select * from estrutura where cod_empresa = '01' and cod_item_pai = 'MORL2062'
    select * from estrutura where cod_empresa = '01' and cod_item_pai = '160080600306'     -- tipo B

    select * from estrutura where cod_empresa = '01' and cod_item_pai = '160080600305'
       select * from estrutura where cod_empresa = '01' and cod_item_pai = '16008060030550'      -- mudei de B para P
          select * from estrutura where cod_empresa = '01' and cod_item_pai = '16000060030540'
             select * from estrutura where cod_empresa = '01' and cod_item_pai = '16000060030530'
                select * from estrutura where cod_empresa = '01' and cod_item_pai = '16000060030515'

                   select * from estrutura where cod_empresa = '01' and cod_item_pai = '16000060030510'  -- mudei de P para B
                      select * from estrutura where cod_empresa = '01' and cod_item_pai = '160000600303'
                         select * from estrutura where cod_empresa = '01' and cod_item_pai = '16000060030310'
                            select * from estrutura where cod_empresa = '01' and cod_item_pai = 'MORL7002 '
                      select * from estrutura where cod_empresa = '01' and cod_item_pai = '160230600304'
                         select * from estrutura where cod_empresa = '01' and cod_item_pai = '160000600304'
                            select * from estrutura where cod_empresa = '01' and cod_item_pai = 'MORL2064'

 select * from estrutura where cod_empresa = '01' and cod_item_pai = 'BB-2002  '

select * from fat_nf_mestre where empresa = '01' and status_nota_fiscal = 'F'
select * from fat_nf_item where empresa = '01'  and trans_nota_fiscal < 1000
select * from fat_nf_item_fisc where empresa = '01' and trans_nota_fiscal < 1000
select * from nat_operacao where cod_nat_oper = 201
select * from estoque_operac where cod_operacao = 'TR08'

select * from nf_proces_1099
select * from nf_item_proces_1099
select * from item_temp_1099
select * from erro_contagem_1099

select * from consumo where cod_empresa = '01' and cod_item = '160080600300'    -- oper 038/1
select * from consumo_fer where cod_empresa = '01' and num_processo = '0000179' -- fer F100000004501   50
select * from consumo where cod_empresa = '01' and cod_item = '16008060030010' -- oper 034/1
select * from consumo_fer where cod_empresa = '01' and num_processo = '0000175' -- fer D16008060030010
select * from consumo where cod_empresa = '01' and cod_item = '160080600305'    -- oper 022/1
select * from consumo_fer where cod_empresa = '01' and num_processo = '0002000' -- fer F16000060030520 100
select * from consumo where cod_empresa = '01' and cod_item = '16008060030550' -- sem cadastro
select * from consumo where cod_empresa = '01' and cod_item = '16000060030540' -- oper 034/1
select * from consumo_fer where cod_empresa = '01' and num_processo = '0000174' -- fer D16000060030540
select * from consumo where cod_empresa = '01' and cod_item = '16000060030530' -- oper 039/1
select * from consumo_fer where cod_empresa = '01' and num_processo = '0000173' -- sem cadastro
select * from consumo where cod_empresa = '01' and cod_item = '16000060030515' -- oper 090/1
select * from consumo_fer where cod_empresa = '01' and num_processo = '0001608' -- fer F16000060030520 100

select * from consumo_fer where cod_empresa = '01'
select * from ferramentas
select * from componente
select distinct * from qtd_acum_ativ_osp where empresa = '01' and cod_equip = 'F100000004501'      89886 + 50
select distinct * from qtd_acum_ativ_osp where empresa = '01' and cod_equip = 'F16000060030520'    6130 + 200

        SELECT cod_item_compon,
               qtd_necessaria
          FROM estrutura
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item_pai = p_item.cod_item
           AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))

       SELECT fat_nf_item.empresa,
              fat_nf_item.trans_nota_fiscal,
              fat_nf_item.seq_item_nf,
              fat_nf_item.item,
              fat_nf_item.qtd_item,
              fat_nf_item.natureza_operacao
         FROM fat_nf_item,
              fat_nf_mestre,
              nat_operacao,
              estoque_operac
        WHERE fat_nf_mestre.empresa = '01'
          AND fat_nf_mestre.trans_nota_fiscal > 0
          AND DATE(fat_nf_mestre.dat_hor_emissao) >= '01/01/2011'
          AND fat_nf_mestre.status_nota_fiscal = 'F'
          AND fat_nf_item.empresa = fat_nf_mestre.empresa
          AND fat_nf_item.trans_nota_fiscal = fat_nf_mestre.trans_nota_fiscal
          AND nat_operacao.cod_nat_oper = fat_nf_item.natureza_operacao
          AND estoque_operac.cod_empresa = fat_nf_mestre.empresa
          AND estoque_operac.cod_operacao = nat_operacao.cod_movto_estoq
          AND estoque_operac.ies_com_quantidade = 'S'
          AND fat_nf_item.trans_nota_fiscal = 178
          AND fat_nf_item.seq_item_nf = 1

select * from docum where cod_empresa = '11'
select * from docum_pgto where cod_empresa = '11'
-- delete from os_email_1099
select * from os_email_1099
select * from erro_email_1099
SELECT * FROM EMAIL_TEMP_1099 order by 3
select * from os_ativ_osp where cod_empresa = '01' and cod_equip = 'F100000004501'
select * from usuarios where cod_usuario = 'admlog'
select distinct num_os, cod_equip, cod_grp_atividade, dat_base from os_ativ_osp where cod_empresa = '01' and cod_equip = 'F100000004501'

       SELECT DISTINCT num_os,
              cod_equip, cod_grp_atividade, dat_base
         FROM os_ativ_osp
        WHERE cod_empresa = '01'
          AND dat_base >= '01/07/2011'
          AND num_os NOT IN
            (SELECT num_os FROM os_email_1099 WHERE cod_empresa = '01')

