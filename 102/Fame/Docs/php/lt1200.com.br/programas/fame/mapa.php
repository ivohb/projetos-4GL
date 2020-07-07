<?
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $ifx_user='admlog';
 $ifx_senha='admf9';
 $selec_pedido=" insert into lt1200:lt1200_ped_mapa
          SELECT 'EMITIDOS','".$data."',
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic),
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  e.prz_entrega,
		  i.cod_cliente,
                  l.den_grupo_item ,
		  b.dat_pedido,
                  '',
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,
                  u.cod_fiscal

  $selec_pedido="SELECT 'EMITIDOS',
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  b.pct_desc_adic,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  year(b.dat_pedido) as ano ,month(b.dat_pedido) as mes,
		  (month(b.dat_pedido)||'/'||year(b.dat_pedido) ) as mesano,
                  day(b.dat_pedido) as dia,
		  year(b.dat_pedido) as ano_ped ,month(b.dat_pedido) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  '' as sit_erp,
                  (b.cod_nat_oper/1) as cod_tip_cli   ,b.cod_repres     
             from pedidos b,
                  ped_itens e,
                  item_vdp k,
                  item m
             where b.cod_empresa ='01'
               and b.dat_pedido between '".$ini."' and '".$fim."'
               and b.ies_sit_pedido in ('N','2','F','3','1','B')
               and b.num_pedido not in (select cdped from vnxeorca where cdped is not null)
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and e.qtd_pecas_solic-e.qtd_pecas_cancel > 0
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and b.cod_nat_oper not in ('16','32')
union all

        SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  year(p.dt_import) as ano ,month(p.dt_import) as mes,
		  (month(p.dt_import)||'/'||year(p.dt_import) ) as mesano,
                  day(p.dt_import) as dia,
		  year(p.dt_import) as ano_ped ,month(p.dt_import) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  '' as sit_erp,(o.cdoperac/1) as cod_tip_cli,b.cod_repres        
             from pedidos b,
                  ped_itens e,
                  item_vdp k,
                  item m,
                  vnxeorca o,
                  vnimpped p
             where b.cod_empresa ='01'
               and b.ies_sit_pedido in ('N','2','F','3','1','B')
               and p.dt_import between '".$ini_orca."' and '".$fin_orca."'
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and e.qtd_pecas_solic-e.qtd_pecas_cancel > 0
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and o.cdped=b.num_pedido
               and p.cod_crm=o.cod     
               and p.cod_item='000'
               and b.cod_nat_oper not in ('16','32')
union all
          SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,'N' as ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic, 0 as qtd_pecas_atend,0 as qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  year(b.dat_digitacao) as ano ,month(b.dat_digitacao) as mes,
		  (month(b.dat_digitacao)||'/'||year(b.dat_digitacao)) as mesano,
                  day(b.dat_digitacao) as dia,
		  year(b.dat_digitacao) as ano_ped ,month(b.dat_digitacao) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  '' as sit_erp ,(b.cod_nat_oper/1) as cod_tip_cli,b.cod_repres          
             from pedido_dig_mest b ,
                  pedido_dig_item e,
                  item_vdp k,
                  item m
             where b.cod_empresa ='01'
               and b.dat_digitacao between '".$ini."' and '".$fim."'
               and b.num_pedido not in (select cdped from vnxeorca where cdped is not null)
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and b.cod_nat_oper not in ('16','32')
union all

          SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,'N' as ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic, 0 as qtd_pecas_atend,0 as qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  year(p.dt_import) as ano ,month(p.dt_import) as mes,
		  (month(p.dt_import)||'/'||year(p.dt_import)) as mesano,
                  day(p.dt_import) as dia,
		  year(p.dt_import) as ano_ped ,month(p.dt_import) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  '' as sit_erp ,(b.cod_nat_oper/1) as cod_tip_cli,b.cod_repres     
             from pedido_dig_mest b,
                  pedido_dig_item e,
                  item_vdp k,
                  item m,
                  vnxeorca o,
                  vnimpped p

             where b.cod_empresa ='01'
               and p.dt_import between '".$ini_orca."' and '".$fin_orca."'
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and b.cod_nat_oper not in ('16','32')
               and o.cdped=b.num_pedido
               and p.cod_crm=o.cod     
               and p.cod_item='000'

union all
          SELECT (b.cod||'-'||'01') as ped_emp,
                  (b.cod/1) as num_pedido,'01' as cod_empresa,
                  0 as pct_desc_financ,
                  0 as pct_desc_adic_ped,
                  b.pct_frete,'N' as ies_sit_pedido,
                  e.prunit as pre_unit,
                  e.qtde as qtd_pecas_solic,
                  0 as qtd_pecas_atend,0 as qtd_pecas_cancel,
                  e.descont as pct_desc_adic,0 as pct_desc_bruto,1 as num_sequencia,
		  year(o.dt_import) as ano ,month(o.dt_import) as mes,
		  (month(o.dt_import)||'/'||year(o.dt_import) ) as mesano,
                  day(o.dt_import) as dia,
		  year(o.dt_import) as ano_ped ,month(o.dt_import) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  b.sit_erp,(b.cdoperac/1) as cod_tip_cli,round(b.cdrepr/1) as cod_repres
             from vnxeorca b,
                  vnxeorit e,
                  vnempre f,
                  item_vdp k,
                  item m,
                  vnimpped o 
             where
              (b.ies_sit_informacao not in ('9') or b.ies_sit_informacao is null)
               and o.dt_import between '".$ini_orca."' and '".$fin_orca."'
               and e.cdorca=b.cod
               and f.cod=b.cdempre
               and e.qtde > 0 
               and b.cdoperac not in('16','32')
               and k.cod_empresa='01'
               and k.cod_item=e.cdprod
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and o.cod_crm=b.cod
               and o.cod_item='000'
               and b.cdped is null

           order by  15,16,3,26,2            ";



          SELECT 'EMITIDOS','".$data."',
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic),
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  e.prz_entrega,
		  i.cod_cliente,
                  l.den_grupo_item ,
		  b.dat_pedido,
                  '',
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,
                  u.cod_fiscal
   
             from pedidos b,
                  ped_itens e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n,
                  cidades q,
                  fiscal_par u

             where 
                b.dat_pedido = '".$data."' 
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and i.cod_cliente=b.cod_cliente
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
               and q.cod_cidade=i.cod_cidade
               and u.cod_empresa=b.cod_empresa
               and u.cod_nat_oper=b.cod_nat_oper
               and u.cod_uni_feder=q.cod_uni_feder

                      ";
  $res_pedido = ifx_connect("logix",$ifx_user,$ifx_senha);
  $result_pedido = ifx_query($selec_pedido,$res_pedido);
/*
//cancelados
$selec_pedido="  insert into lt1200:lt1200_ped_mapa
          SELECT 'CANCELADOS','".$data."',
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  e.prz_entrega,
		  i.cod_cliente,
                  l.den_grupo_item ,
		  b.dat_pedido,
		  $data,
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,
                  u.cod_fiscal   
             from audit_vdp a,
                  pedidos b,
                  ped_itens e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n,
                  cidades q,
                  fiscal_par u

             where 
                a.data = '".$data."' 
               and a.tipo_movto='C'
               and a.num_programa='VDP1080'
               and a.texto[1,3]='SEQ'
               and b.cod_empresa =a.cod_empresa
               and b.num_pedido=a.num_pedido
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and i.cod_cliente=b.cod_cliente
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
               and q.cod_cidade=i.cod_cidade
               and u.cod_empresa=b.cod_empresa
               and u.cod_nat_oper=b.cod_nat_oper
               and u.cod_uni_feder=q.cod_uni_feder

                       ";
  $res_pedido = ifx_connect("logix",$ifx_user,$ifx_senha);
  $result_pedido = ifx_query($selec_pedido,$res_pedido);

$selec_pedido="  insert into lt1200:lt1200_ped_mapa

          SELECT 'CANCELADOS','".$data."',
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  e.prz_entrega,
		  i.cod_cliente,
                  l.den_grupo_item ,
		  b.dat_pedido,
                  $data,
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,
                  u.cod_fiscal 
   
             from audit_vdp a,
                  pedidos b,
                  ped_itens e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n,
                  cidades q,
                  fiscal_par u

             where 
                a.data = '".$data."' 
               and a.tipo_movto='C'
               and a.num_programa='VDP1080'
               and a.texto[1,16]='PEDIDO CANCELADO'
               and b.cod_empresa =a.cod_empresa
               and b.num_pedido=a.num_pedido
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and i.cod_cliente=b.cod_cliente
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
               and q.cod_cidade=i.cod_cidade
               and u.cod_empresa=b.cod_empresa
               and u.cod_nat_oper=b.cod_nat_oper
               and u.cod_uni_feder=q.cod_uni_feder

                       ";
  $res_pedido = ifx_connect("logix",$ifx_user,$ifx_senha);
  $result_pedido = ifx_query($selec_pedido,$res_pedido);
*/

//carteira
  $selec_pedido=" insert into lt1200:lt1200_ped_mapa
          SELECT 'CARTEIRA','".$data."',
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  e.prz_entrega,
		  i.cod_cliente,
                  l.den_grupo_item ,
		  b.dat_pedido,
                  '',
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,
                  u.cod_fiscal 
   
             from pedidos b,
                  ped_itens e,
                  clientes i,
                  cidades q,
                  fiscal_par u,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n

             where 
                b.ies_sit_pedido <> '9'
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and e.qtd_pecas_solic-e.qtd_pecas_cancel-qtd_pecas_atend  > 0
               and i.cod_cliente=b.cod_cliente
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
               and q.cod_cidade=i.cod_cidade
               and u.cod_empresa=b.cod_empresa
               and u.cod_nat_oper=b.cod_nat_oper
               and u.cod_uni_feder=q.cod_uni_feder
           ";

  $res_pedido = ifx_connect("logix",$ifx_user,$ifx_senha);
  $result_pedido = ifx_query($selec_pedido,$res_pedido);

?>