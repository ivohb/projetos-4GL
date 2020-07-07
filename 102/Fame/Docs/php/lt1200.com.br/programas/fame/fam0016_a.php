<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manuten�o:     Henrique
 //Data manuten�o30/08/2005
 //Mdulo:        Fame
 //Processo:      Mapa de Vendas
 //-----------------------------------------------------------------------------
 $prog="fame/fam0016";
 $versao=1;  
 $mes_ctr=round($mes_ini);
 $ano_ctr=round($ano_ini);
 $dia_ctr=round($dia_ini);
 $mesano_ctr=$mes_ctr.$ano_ctr;
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $data_cab=sprintf("%02d/%02d/%04d",$dia_ctr,$mes_ctr,$ano_ctr);
 $funcio="select a.cod_empresa,a.den_empresa,a.num_cgc,a.den_munic,a.end_empresa,
                a.num_telefone,a.cod_cep,a.ins_estadual,a.den_bairro,
		a.uni_feder,a.num_fax,
                b.cod_usuario,b.cod_rep,b.erep,
                b.fone,b.fax,b.celular,b.email

	from	empresa a,
                lt1200:lt1200_usuarios b
	where	a.cod_empresa='".$empresa."'
	        and b.cod_usuario='".$ifx_user."'
	";

 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($funcio,$res);
 $mat=$cfetch_row($result);
 $cab1=trim($mat[den_empresa]);
 $cab2=trim($mat[end_empresa]).'       Bairro:'.trim($mat[den_bairro]);
 $cab3=$mat[cod_cep].' - '.trim($mat[den_munic]).' - '.trim($mat[uni_feder]);
 $cab4='Fone: '.$mat[num_telefone].'   Fax: '.$mat[num_fax];
 $cab5="C.G.C.  :".$mat[num_cgc]."     Ins.Estadual:".$mat["ins_estadual"];
 $mes_num=$mes_ctr;
 require('../../bibliotecas/nome_mes.inc');

 $titulo="MOVIMENTO EM:".$data_cab."     Mes:".$nome_mes."      Dias Uteis
:".$dias_uteis."  Dia Util:".$dia_util;
 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_fame.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
 $vendas="S"; 
 $mes_12=$mes_ini;
 $ano_12=$ano_ini;
 $mes_count=$meses;
 $mes_count1=$meses;
 $meses=$meses-1;
 $fim=round($dia_ini)."/".round($mes_ini)."/".round($ano_ini);
 $ini_prod="01/".round($mes_ini)."/".round($ano_ini);
 if($mes_12-$meses <= 0)
 {
   $ano_1=$ano_12-1;
   $mes_1=(12-$meses)+($mes_12-$meses);
   $ini="01/".round(12+($mes_12-$meses)).'/'.round($ano_12-1);
   $mes_ini=round(12+($mes_12-$meses));
 }else{
   $ano_1=$ano_12;
   $mes_1=$mes_12-$meses;
   $ini="01/".round($mes_12-$meses).'/'.round($ano_12);
   $mes_ini=$mes_12-$meses;
 }
 $ini_orca=sprintf("%04d-%02d-%02d",$ano_1,$mes_ini,"01");
 $fin_orca=sprintf("%04d-%02d-%02d",$ano_ctr,$mes_ctr,$dia_ctr);
 $ini_orca=chop($ini_orca)." 00:00:00.000";
 $fin_orca=chop($fin_orca)." 00:00:00.000";

 $mes_control=1;
 $ano_controle=$ano_1;
 $mes_controle=$mes_ini;
 while ($mes_control <= $mes_count1)
 {
  $mes_array[round($mes_control)]=chop($ano_controle).'-'.chop($mes_controle);
  $mes_controle=$mes_controle+1;
  $mes_control=$mes_control+1;
  if($mes_controle > 12){
     $mes_controle=1;
     $ano_controle=$ano_controle+1;
  }
 }
 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
 if($vendas=="S")
 {
//CARTEIRA



  $selec_pedido="
        SELECT 'erp' as tipo_rel,(b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  year(e.prz_entrega) as ano ,month(e.prz_entrega) as mes,
		  (month(e.prz_entrega)||'/'||year(e.prz_entrega) ) as mesano,
		  i.nom_cliente,i.cod_cliente,
                  day(e.prz_entrega) as dia,
                  l.den_grupo_item ,
		  year(b.dat_pedido) as ano_ped ,month(b.dat_pedido) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,'' as sit_erp   ,
                  b.cod_repres
             from pedidos b,
                  ped_itens e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n
             where b.cod_empresa ='01'
               and b.ies_sit_pedido <> '9'
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and e.qtd_pecas_solic-e.qtd_pecas_cancel > 0
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
               and b.num_pedido not in (select cdped from vnxeorca)
  
union
        SELECT 'erp' as tipo_rel,(b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  year(e.prz_entrega) as ano ,month(e.prz_entrega) as mes,
		  (month(e.prz_entrega)||'/'||year(e.prz_entrega) ) as mesano,
		  i.nom_cliente,i.cod_cliente,
                  day(e.prz_entrega) as dia,
                  l.den_grupo_item ,
		  year(b.dat_pedido) as ano_ped ,month(b.dat_pedido) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,'' as sit_erp   ,
                  b.cod_repres

             from pedidos b,
                  ped_itens e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n,
                  vnxeorca o,
                  vnimpped p
             where b.cod_empresa ='01'
               and b.ies_sit_pedido <> '9'
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and e.qtd_pecas_solic-e.qtd_pecas_cancel > 0
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
               and o.cdped=b.num_pedido
               and p.cod_crm=o.cod               
  
union
          SELECT 'bat'as tipo_rel,(b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,'N' as ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic, 0 as qtd_pecas_atend,0 as qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  year(e.prz_entrega) as ano ,month(e.prz_entrega) as mes,
		  (month(e.prz_entrega)||'/'||year(e.prz_entrega)) as mesano,
		  i.nom_cliente,i.cod_cliente,
                  day(e.prz_entrega) as dia,
                  l.den_grupo_item ,
		  year(b.dat_digitacao) as ano_ped ,month(b.dat_digitacao) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,'' as sit_erp  ,
                  b.cod_repres 
             from pedido_dig_mest b,
                  pedido_dig_item e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n,
                  vnxeorca o,
                  vnimpped p

             where b.cod_empresa ='01'
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
               and b.cod_nat_oper not in ('16','32')
               and o.cdped=b.num_pedido
               and p.cod_crm=o.cod     

union


          SELECT 'bat'as tipo_rel,(b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,'N' as ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic, 0 as qtd_pecas_atend,0 as qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  year(e.prz_entrega) as ano ,month(e.prz_entrega) as mes,
		  (month(e.prz_entrega)||'/'||year(e.prz_entrega)) as mesano,
		  i.nom_cliente,i.cod_cliente,
                  day(e.prz_entrega) as dia,
                  l.den_grupo_item ,
		  year(b.dat_digitacao) as ano_ped ,month(b.dat_digitacao) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,'' as sit_erp  ,
                  b.cod_repres 
             from pedido_dig_mest b,
                  pedido_dig_item e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n
             where b.cod_empresa ='01'
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
               and b.num_pedido not in (select cdped from vnxeorca)
union
          SELECT 'crm' as tipo_rel,(b.cod||'-'||'01') as ped_emp,
                  (b.cod/1) as num_pedido,'01' as cod_empresa,
                  0 as pct_desc_financ,
                  0 as pct_desc_adic_ped,
                  b.pct_frete,'N' as ies_sit_pedido,
                  ((e.prunit*(100-e.descont))/100) as pre_unit,
                  e.qtde as qtd_pecas_solic,
                  0 as qtd_pecas_atend,0 as qtd_pecas_cancel,
                  0 as pct_desc_adic,0 as pct_desc_bruto,1 as num_sequencia,
		  year(b.dtprz) as ano ,month(b.dtprz) as mes,
		  (month(b.dtprz)||'/'||year(b.dtprz) ) as mesano,
		  i.nom_cliente,i.cod_cliente,
                  day(b.dtprz) as dia,
                  l.den_grupo_item ,
		  year(o.dt_import) as ano_ped ,month(o.dt_import) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,b.sit_erp,(b.cdrepr/1) as
                  cod_repres
             from vnxeorca b,
                  vnxeorit e,
                  vnempre f,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n,
                  vnimpped o 
             where
              (b.ies_sit_informacao <> '9' or b.ies_sit_informacao is null)
               and e.cdorca=b.cod
               and f.cod=b.cdempre
               and e.qtde > 0 
              and i.cod_cliente=f.cdclierp
               and i.cod_tip_cli<>'66'
               and k.cod_empresa='01'
               and k.cod_item=e.cdprod
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
               and o.cod_crm=b.cod
               and o.cod_item<>'Obs'
               and b.cdped is null



           order by 31,1,2";

  $res_pedido = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_pedido = $cquery($selec_pedido,$res_pedido);
  $mat_pedido=$cfetch_row($result_pedido);

  $ped_ant="0"; 
  $ped_atu=$mat_pedido["ped_emp"]; 
  $vlme=0;
  $vlmc=0;
  $vlma=0;
  $vlm=0;
  $matim=0;
  $matem=0;
  $totm=0;
  $matit=0;
  $matet=0;
  $tott=0;
  $mes_ant=0;
  $mes_atu=$mat_pedido["mesano"];
  $emp_ant=$mat_pedido["cod_empresa"];
  $emp_atu=$mat_pedido["cod_empresa"];
  $val_grupo_mes=0;
  $qtd_grupo_mes=0;
  $val_grupo_tmes=0;
  $qtd_grupo_tmes=0;
  $val_grupo_f=0;
  $qtd_grupo_f=0;
  $val_linha_mes=0;
  $qtd_linha_mes=0;
  $val_linha_tmes=0;
  $qtd_linha_tmes=0;
  $val_linha_f=0;
  $qtd_linha_f=0;
  $qtd_pecas_ant=0;
  $zero="";
  $valor_ped_mes=0;
  $valor_rep_mes=0;
  $valor_tot_mes=0;
  $valor_ped=0;
  $valor_rep=0;
  $valor_tot=0;
  $valor_local=0;
  while (is_array($mat_pedido))
  {
   $unit=(($mat_pedido["pre_unit"]-($mat_pedido["pre_unit"]*$mat_pedido["pct_desc_adic"]/100)));
   $unit=(($unit-($unit*$mat_pedido["pct_desc_bruto"]/100)));
   $unit=(($unit-($unit*$mat_pedido["pct_desc_adic_ped"]/100)));
   $unit=(($unit-($unit*$mat_pedido["pct_desc_financ"]/100)));

   if(chop($mat_pedido["sit_erp"])=="F")
   {
    $qtd_pecas_atend=$mat_pedido["qtd_pecas_solic"];
   }else{
    if($mat_pedido["qtd_pecas_atend"] > 0)
    {
     $qtd_pecas_atend=$mat_pedido["qtd_pecas_atend"];
    }else{
     $qtd_pecas_atend=0;
    }
   }

   $vlme=($vlme+($unit*$mat_pedido["qtd_pecas_solic"]));
   $vlmc=($vlmc+($unit*$mat_pedido["qtd_pecas_cancel"]));
   $vlma=($vlma+($unit*$qtd_pecas_atend)) ;
   $vlmet=($vlmet+($unit*$mat_pedido["qtd_pecas_solic"]));
   $vlmct=($vlmct+($unit*$mat_pedido["qtd_pecas_cancel"]));
   $vlmat=($vlmat+($unit*$qtd_pecas_atend)) ;

   $ped_atu=$mat_pedido["num_pedido"];
   $ped_atu_1=$mat_pedido["ped_emp"];
   $mes_atu=$mat_pedido["mes"];
   $ano_atu=$mat_pedido["ano"];
   $mes_atu_ped=$mat_pedido["mes_ped"];  
   $ano_atu_ped=$mat_pedido["ano_ped"];
   $emp_atu=$mat_pedido["cod_empresa"];
   $rep_atu=$mat_pedido["cod_repres"];
   $cli_atu=$mat_pedido["nom_cliente"];
   $cod_cli_atu=$mat_pedido["cod_cliente"]; 
   $tip_cli_atu=$mat_pedido["cod_tip_cli"]; 
   $dir_atu=$mat_pedido["cod_nivel_2"];
   $grupo_atu=$mat_pedido["den_grupo_item"];

   $linha_atu=$mat_pedido["den_estr_linprod"];

   $grupo_atu=$mat_pedido["den_grupo_item"];
   $linha_atu=$mat_pedido["den_estr_linprod"];
   $valorm=$vlme-$vlmc;
   $valorm=$valorm;
   $valor=$vlme-$vlmc-$vlma;
   $valor=$valor;

   $valor_ped_s=$valor_ped_s+$vlme-$vlmc-$vlma;     
   $valor_rep_s=$valor_rep_s+$vlme-$vlmc-$vlma;     
   $valor_tot_s=$valor_tot_s+$vlme-$vlmc-$vlma;     
   $valor_local_s=$valor_local_s+$vlme-$vlmc-$vlma;     

   $valor_ped_e=$valor_ped_e+$valorm;     
   $valor_rep_e=$valor_rep_e+$valorm;     
   $valor_tot_e=$valor_tot_e+$valorm;     
   $valor_local_e=$valor_local_e+$valorm;     
   $valor_ped_a=$valor_ped_a+$vlma;     
   $valor_rep_a=$valor_rep_a+$vlma;     
   $valor_tot_a=$valor_tot_a+$vlma;     
   $valor_local_a=$valor_local_a+$vlma;     
   if($mes_atu_ped==$mes_ctr and $ano_atu_ped==$ano_ctr )
   {
    $valor_ped_mes=$valor_ped_mes+$valorm;
    $valor_rep_mes=$valor_rep_mes+$valorm;
    $valor_tot_mes=$valor_tot_mes+$valorm;
   }


   $vlme=0;
   $vlmc=0;
   $vlma=0;

   $ped_ant=$mat_pedido["num_pedido"];
   $ped_ant_1=$mat_pedido["ped_emp"];
   $mes_ant=$mat_pedido["mes"];
   $ano_ant=$mat_pedido["ano"];
   $mes_ant_ped=$mat_pedido["mes_ped"];  
   $ano_ant_ped=$mat_pedido["ano_ped"];
   $emp_ant=$mat_pedido["cod_empresa"];
   $rep_ant=$mat_pedido["cod_repres"];
   $cli_ant=$mat_pedido["nom_cliente"];
   $cod_cli_ant=$mat_pedido["cod_cliente"]; 
   $tip_cli_ant=$mat_pedido["cod_tip_cli"]; 
   $dir_ant=$mat_pedido["cod_nivel_2"];
   $grupo_ant=$mat_pedido["den_grupo_item"];
   $linha_ant=$mat_pedido["den_estr_linprod"];
   $cod_item_ant=$mat_pedido["cod_item"];
   $den_item_ant=$mat_pedido["den_item"];
   $local_ant=$mat_pedido["tipo_rel"];
   $mat_pedido=$cfetch_row($result_pedido);

   $ped_atu=$mat_pedido["num_pedido"];
   $ped_atu_1=$mat_pedido["ped_emp"];
   $mes_atu=$mat_pedido["mes"];
   $ano_atu=$mat_pedido["ano"];
   $mes_atu_ped=$mat_pedido["mes_ped"];  
   $ano_atu_ped=$mat_pedido["ano_ped"];
   $emp_atu=$mat_pedido["cod_empresa"];
   $rep_atu=$mat_pedido["cod_repres"];
   $cli_atu=$mat_pedido["nom_cliente"];
   $cod_cli_atu=$mat_pedido["cod_cliente"]; 
   $tip_cli_atu=$mat_pedido["cod_tip_cli"]; 
   $dir_atu=$mat_pedido["cod_nivel_2"];
   $grupo_atu=$mat_pedido["den_grupo_item"];
   $linha_atu=$mat_pedido["den_estr_linprod"];
   $cod_item_atu=$mat_pedido["cod_item"];
   $local_atu=$mat_pedido["tipo_rel"];
   $pdf->SetFillColor(260);
   if($ped_atu<>$ped_ant)
   {
    $pdf->SetFont('Arial','B',8);
    $pdf->ln();
    $pdf->setx(30);
    $pdf->Cell(20,6,'Pedido',TBLR,0,'L',1);
    $pdf->Cell(20,6,number_format($ped_ant,0,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_ped_mes,2,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_ped_e,2,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_ped_a,2,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_ped_s,2,",","."),TBLR,0,'R',1);
    $pdf->Cell(15,6,$local_ant,TBLR,0,'R',1);
    $pdf->Cell(15,6,number_format($rep_ant,0,",","."),TBLR,0,'R',1);
    $valor_ped_e=0;
    $valor_ped_a=0;
    $valor_ped_s=0;
    $valor_ped_mes=0;
   }
   if($rep_atu<>$rep_ant)
   {
    $pdf->SetFont('Arial','B',8);
    $pdf->ln();
    $pdf->setx(10);
    $pdf->Cell(40,6,'Representante',TBLR,0,'L',1);
    $pdf->Cell(20,6,number_format($rep_ant,0,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_rep_mes,2,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_rep_e,2,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_rep_a,2,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_rep_s,2,",","."),TBLR,0,'R',1);
    $valor_rep_e=0;
    $valor_rep_a=0;
    $valor_rep_s=0;
    $valor_rep_mes=0;
    $pdf->ln();
   }

  }
  $pdf->SetFont('Arial','B',8);
    $pdf->ln();
    $pdf->setx(10);
    $pdf->Cell(60,6,'Total',TBLR,0,'L',1);
    $pdf->Cell(20,6,number_format($valor_tot_mes,2,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_tot_e,2,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_tot_a,2,",","."),TBLR,0,'R',1);
    $pdf->Cell(20,6,number_format($valor_tot_s,2,",","."),TBLR,0,'R',1);
 }
 $pdf->Output('mapa_vendas.pdf',D);
?>