delete from log_dados_sessao_logix
SELECT * FROM CLIENTES WHERE COD_CLIENTE = '001505705000204'
select * from portador where cod_portador = 900

       SELECT a.cod_empresa, a.num_docum, a.ies_tip_docum, a.val_liquido,
              a.cod_cliente, a.dat_vencto_s_desc, b.dat_pgto
         FROM docum a, docum_pgto b, clientes c
        WHERE a.cod_empresa = b.cod_empresa
          AND a.num_docum = b.num_docum
          AND a.ies_tip_docum  = b.ies_tip_docum
          AND a.ies_pendencia = 'S'
          AND a.cod_mercado = 'I'
          AND a.ies_pgto_docum = 'T'
          AND a.ies_situa_docum <> 'C'
          AND c.cod_cliente = a.cod_cliente
          and a.cod_cliente = '004733224000163'
          AND b.dat_pgto >= '19/11/2014'
          AND b.dat_pgto <= '19/11/2014'

select * from docum where cod_empresa = '01' and val_saldo > 0 and cod_mercado = 'I' and num_docum = '01074336031'
select * from docum_pgto where cod_empresa = '01'  and num_docum = '01074336031'

order by  c.nom_cliente, a.num_docum
select * from docum where cod_empresa = '01' and val_saldo > 0 and cod_mercado = 'I' and num_docum in
 ('0100345301','0100345301','0100382101','0100382201','0100383701')
select * from docum where cod_empresa = '01' and val_saldo > 0 and cod_mercado = 'I' and ies_pendencia = 'S'
select * from docum_pgto where cod_empresa = '01' and dat_pgto >= '01/02/2014' and dat_pgto <= '02/02/2014'
select dat_pgto, dat_credito from docum_pgto where cod_empresa = '01' and dat_pgto >= '01/02/2014' and dat_pgto <= '02/02/2014'

select * from juro_mora
select pct_juro_mora from juro_mora where cod_empresa = '01'
select * from clientes_cre_txt
select substring(parametro,5,6) from clientes_cre_txt

        SELECT *
          FROM docum d
         WHERE d.val_saldo > 0 and cod_cliente = '031069347000114'
           AND d.ies_pgto_docum <> 'T'
           AND d.ies_situa_docum <> 'C'
           and d.dat_vencto_s_desc >= '15/05/2011' and d.dat_vencto_s_desc <= '15/05/2011'