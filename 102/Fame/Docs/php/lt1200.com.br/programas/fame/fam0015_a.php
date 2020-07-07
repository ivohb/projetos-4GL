<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenï¿½o:     Henrique
 //Data manutenï¿½o30/08/2005
 //Mdulo:        Fame
 //Processo:      Mapa de Vendas
 //-----------------------------------------------------------------------------
 $prog="fame/fam0015";
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

 $titulo="Relatório Vendas";
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
 $selec_pedido="SELECT a.cod as ped_emp,
                  (a.cod/1) as num_pedido,'01' as cod_empresa,
                  0 as ies_frete,0 as pct_desc_financ,
                  0 as pct_desc_adic_ped,
		  0 as pct_frete,'' as ies_sit_pedido,
                  a.totliq as pre_unit,1 as qtd_pecas_solic,0 as qtd_pecas_atend,
                  0 as qtd_pecas_cancel,
                  0 as pct_desc_adic,0 as pct_desc_bruto,0 as num_sequencia,
		  a.cdempre,a.dtorca,a.num_pedido_cli,a.ies_aceite_finan,
		  a.ies_aceite_comer,a.ies_sit_informacao, a.dat_base_venc_dupl, a.totliqped,
		  a.cdped, a.sit_erp,a.cdrepr,
		  year(a.dat_base_venc_dupl) as ano ,month(a.dat_base_venc_dupl) as mes,
		  (month(a.dat_base_venc_dupl)||'/'||year(a.dat_base_venc_dupl) ) as mesano,
		  c.nom_cliente,c.cod_cliente,c.cod_tip_cli,
                  day(a.dat_base_venc_dupl) as dia

             from vnxeorca a,
                  vnempre b,
                  clientes c

             where b.cod=a.cdempre
               and c.cod_cliente=b.cdclierp

           order by  26,25,23            ";
  $res_pedido = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_pedido = $cquery($selec_pedido,$res_pedido);
  $mat_pedido=$cfetch_row($result_pedido);
  $ped_atu="0";
  $ped_ant=$mat_pedido["ped_emp"];
  $ped_atu_1="0";
  $ped_ant_1=$mat_pedido["ped_emp"];
  $vlme=0;
  $vlmc=0;
  $vlma=0;
  $vlm=0;
  $matim=0;
  $totm=0;
  $matit=0;
  $tott=0;
  $mes_ant=0;
  $mes_atu=$mat_pedido["mesano"];
  $emp_ant=$mat_pedido["cod_empresa"];
  $emp_atu=$mat_pedido["cod_empresa"];
  $qtd_pedi=0;
  $qtd_pedid=0;
  $qtd_pedit=0;

  $zero="";
  while (is_array($mat_pedido))
  {
   $dia_rel=round($mat_pedido["dia"]);
   $mes_rel=round($mat_pedido["mes"]);
   $ano_rel=round($mat_pedido["ano"]);
   $unit=(($mat_pedido["pre_unit"]-($mat_pedido["pre_unit"]*$mat_pedido["pct_desc_adic"]/100)));
   $unit=(round(($unit*100),0)/100);
   $unit=(($unit-($unit*$mat_pedido["pct_desc_bruto"]/100)));
   $unit=(round(($unit*100),0)/100);
   $unit=(($unit-($unit*$mat_pedido["pct_desc_adic_ped"]/100)));
   $unit=(round(($unit*100),0)/100);
   $unit=(($unit-($unit*$mat_pedido["pct_desc_financ"]/100)));
   $unit=(round(($unit*100),0)/100);
   $vlme=($vlme+($unit*$mat_pedido["qtd_pecas_solic"]));
   $vlmc=($vlmc+($unit*$mat_pedido["qtd_pecas_cancel"]));
   $vlma=($vlma+($unit*$mat_pedido["qtd_pecas_atend"])) ;
   $vlmet=($vlmet+($unit*$mat_pedido["qtd_pecas_solic"]));
   $vlmct=($vlmct+($unit*$mat_pedido["qtd_pecas_cancel"]));
   $vlmat=($vlmat+($unit*$mat_pedido["qtd_pecas_atend"])) ;
   $ped_atu=$mat_pedido["num_pedido"];
   $ped_atu_1=$mat_pedido["ped_emp"];
   $mes_atu=$mat_pedido["mesano"];
   $mesano_ctr_atu=chop($mat_pedido["mes"]).chop($mat_pedido["ano"]);
   $emp_atu=$mat_pedido["cod_empresa"];
   $rep_atu=$mat_pedido["cod_repres"];
   $cli_atu=$mat_pedido["nom_cliente"];
   $cod_cli_atu=$mat_pedido["cod_cliente"];
   $tip_cli_atu=round($mat_pedido["cod_tip_cli"]);
   $valor=$vlme-$vlmc;
   $valor=round($valor,2);

   $cdped=$mat_pedido["cdped"];
   $dt_orca=$mat_pedido["dtorca"];
   $num_ped=$mat_pedido["num_pedido_cli"];
   $tot_liq=$mat_pedido["totliqped"];
   $sit_erp=$mat_pedido["sit_erp"];
   $cod_rep=$mat_pedido["cdrepr"];

   if($dia_rel==$dia_ctr and $mes_rel==$mes_ctr and $ano_rel==$ano_ctr)
   {
    if($tip_cli_atu<>66)
    {
     $matimd=$matimd+$valor;
     $matit=$matit+$valor;
     $totit=$totit+$valor;
     if($ped_ant<>$ped_atu)
     {
      $qtd_pedid=$qtd_pedid+1;
      $qtd_pedit=$qtd_pedit+1;
     }
    }
   }else{
    if($tip_cli_atu<>66)
    {
     $matim=$matim+$valor;
     $matit=$matit+$valor;
     $totit=$totit+$valor;
     $totem=$totem+$valor;
     if($ped_ant_1<>$ped_atu_1)
     {
      $qtd_pedi=$qtd_pedi+1;
      $qtd_pedit=$qtd_pedit+1;
     }
    }
   }

   $vlme=0;
   $vlmc=0;
   $vlma=0;
   $ped_ant=$mat_pedido["num_pedido"];
   $ped_ant_1=$mat_pedido["ped_emp"];
   $mes_ant=$mat_pedido["mesano"];
   $emp_ant=$mat_pedido["cod_empresa"];
   $ped_ant=$mat_pedido["num_pedido"];
   $ped_ant_1=$mat_pedido["ped_emp"];
   $mes_ant=$mat_pedido["mesano"];
   $mesano_ctr_ant=chop($mat_pedido["mes"]).chop($mat_pedido["ano"]);
   $emp_ant=$mat_pedido["cod_empresa"];
   $rep_ant=$mat_pedido["cod_repres"];
   $cli_ant=$mat_pedido["nom_cliente"];
   $tip_cli_ant=$mat_pedido["cod_tip_cli"];

   $mat_pedido=$cfetch_row($result_pedido);
/*
   $ped_atu=$mat_pedido["num_pedido"];
   $ped_atu_1=$mat_pedido["ped_emp"];
   $mes_atu=$mat_pedido["mesano"];
   $emp_atu=$mat_pedido["cod_empresa"];
   $ped_atu=$mat_pedido["num_pedido"];
   $ped_atu_1=$mat_pedido["ped_emp"];
   $mes_atu=$mat_pedido["mesano"];
   $mesano_ctr_atu=chop($mat_pedido["mes"]).chop($mat_pedido["ano"]);
   $emp_atu=$mat_pedido["cod_empresa"];
   $rep_atu=$mat_pedido["cod_repres"];
   $cli_atu=$mat_pedido["nom_cliente"];
   $tip_cli_atu=$mat_pedido["cod_tip_cli"];
*/
   $pdf->setx(10);
   $pdf->SetFillColor(260);
   $pdf->Cell(20,5,$cod_rep,LTRB,0,'L',1);
   $pdf->Cell(30,5,substr($dt_orca,0,10),LTRB,0,'L',1);
//   $pdf->SetFillColor(220);
   $pdf->Cell(25,5,number_format($num_ped,0,",","."),LTRB,0,'R',1);
   $pdf->Cell(25,5,number_format($cdped,0,",","."),LTRB,0,'R',1);
         //$pdf->Cell(25,5,number_format($qtd_pedi+$qtd_pede_array[$mes_ant],0,",","."),LTRB,0,'R',1);

   $pdf->SetFillColor(260);
   $pdf->Cell(25,5,number_format($tot_liq,2,",","."),LTRB,0,'R',1);
   $pdf->Cell(25,5,$sit_erp,LTRB,0,'R',1);
   $pdf->ln();
   $pdf->SetFillColor(260);
  }
  $pdf->ln();
  $matim=0;
  $matem=0;
  $totm=0;
 $pdf->Output('relatório_vendas.pdf',D);
?>
