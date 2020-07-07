<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manuten�o:     Henrique
 //Data manuten�o30/08/2005
 //Mdulo:        Fame
 //Processo:      Mapa de Vendas ERP
 //-----------------------------------------------------------------------------
 ini_set("display_errors",0);
 $prog="fame/fam0010";
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

 $titulo="MOVIMENTO EM:".$data_cab."     Mes:".$nome_mes."      Dias Uteis :".$dias_uteis."  Dia Util:".$dia_util;
 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf_paisagem.php');
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
  $selec_pedidos="SELECT 
		  month(b.dat_hor_emissao) as mes,
                  year(b.dat_hor_emissao)  as ano,
		  (month(b.dat_hor_emissao)||'/'||year(b.dat_hor_emissao) ) as mesano,
                  c.pedido AS num_pedido,i.cod_tip_cli,
                  day(b.dat_hor_emissao) as dia
             from fat_nf_mestre_hist  b,
                  clientes i,
                  fat_nf_item_hist c

             where b.empresa ='".$empresa."'
               and CAST(b.dat_hor_emissao AS DATE) between '".$ini."' and '".$fim."'
               and b.sit_nota_fiscal <> 'C'
               and i.cod_cliente=b.cliente
	       and c.empresa=b.empresa
               and c.trans_nota_fiscal=b.trans_nota_fiscal
  union
  SELECT 
		  month(b.dat_hor_emissao) as mes,
                  year(b.dat_hor_emissao)  as ano,
		  (month(b.dat_hor_emissao)||'/'||year(b.dat_hor_emissao) ) as mesano,
                  c.pedido AS num_pedido,i.cod_tip_cli,
                  day(b.dat_hor_emissao) as dia


             from fat_nf_mestre b,
                  clientes i,
                  fat_nf_item c

             where b.empresa='".$empresa."'
               and CAST(b.dat_hor_emissao AS DATE) between '".$ini."' and '".$fim."'
               and b.sit_nota_fiscal <> 'C'
               and i.cod_cliente=b.cliente
	           and c.empresa=b.empresa
               and c.trans_nota_fiscal=b.trans_nota_fiscal
           order by  2,1,4 ";
  $res_pedidos = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_pedidos = $cquery($selec_pedidos,$res_pedidos);
  $mat_pedidos=$cfetch_row($result_pedidos);
  $qtd_pedi=0;
  $qtd_pede=0;
  $qtd_pedid=0;
  $qtd_peded=0;
  $qtd_pedit=0;
  $qtd_pedet=0;

  $mes_ant=0;
  $mes_atu=$mat_pedidos["mesano"];
  $ped_ant=$mat_pedidos["num_pedido"];
  $ped_atu=" ";
  $zero=" ";
  while (is_array($mat_pedidos))
  {
   $dia_rel=round($mat_pedidos["dia"]);
   $mes_rel=round($mat_pedidos["mes"]);
   $ano_rel=round($mat_pedidos["ano"]);
   $tip_cli_ant=$mat_pedidos["cod_tip_cli"];
   $mes_ant=$mat_pedidos["mesano"];
   $ped_ant=$mat_pedidos["num_pedido"];
   $mat_pedidos=$cfetch_row($result_pedidos);
   $mes_atu=$mat_pedidos["mesano"];
   $ped_atu=$mat_pedidos["num_pedido"];

   if($dia_rel==$dia_ctr and $mes_rel==$mes_ctr and $ano_rel==$ano_ctr)
   {
    if($ped_ant<>$ped_atu)
    {
     if($tip_cli_ant==66)
     {
      $qtd_peded=($qtd_peded+1);
     }elseif($tip_cli_ant<>66){
      $qtd_pedid=($qtd_pedid+1);
     }
    }
   }else{
    if($ped_ant<>$ped_atu)
    {
     if($tip_cli_ant==66)
     {
      $qtd_pede=($qtd_pede+1);
     }elseif($tip_cli_ant<>66){
      $qtd_pedi=($qtd_pedi+1);
     }
    }
   }


   if($mes_ant<>$mes_atu)
   {
    $qtd_pede_array[$mes_ant]=$qtd_pede;
    $qtd_pedi_array[$mes_ant]=$qtd_pedi;
    $qtd_pedet=$qtd_pedet+$qtd_pede;
    $qtd_pedit=$qtd_pedit+$qtd_pedi;
    $qtd_pede=0;
    $qtd_pedi=0;
   }
  }




  $selec_notas="SELECT (b.nota_fiscal||'-'||b.empresa) as nff_emp,
                  b.nota_fiscal AS num_nff,b.empresa AS cod_empresa,
                  b.sit_nota_fiscal AS ies_situacao,br.representante AS cod_repres,b.val_mercadoria AS val_tot_mercadoria,b.val_nota_fiscal AS val_tot_nff,
		  month(b.dat_hor_emissao) as mes,
                  year(b.dat_hor_emissao)  as ano,
		  (month(b.dat_hor_emissao)||'/'||year(b.dat_hor_emissao) ) as mesano,
		  i.nom_cliente,i.cod_cliente,i.cod_tip_cli,
                  day(b.dat_hor_emissao) as dia

             from fat_nf_mestre_hist  b,
             	  fat_nf_repr_hist br, 	
                  clientes i

             where b.empresa ='".$empresa."'
               and CAST(b.dat_hor_emissao AS DATE) between '".$ini."' and '".$fim."'
               and b.sit_nota_fiscal <> 'C'
               and i.cod_cliente=b.cliente
               AND br.empresa=b.empresa
               AND br.trans_nota_fiscal=b.trans_nota_fiscal
               AND br.seq_representante=1

  union
  SELECT (b.nota_fiscal||'-'||b.empresa) as nff_emp,
                  b.nota_fiscal AS num_nff,b.empresa AS cod_empresa,
                  b.sit_nota_fiscal AS ies_situacao,br.representante AS cod_repres,b.val_mercadoria AS val_tot_mercadoria,b.val_nota_fiscal AS val_tot_nff,
		  month(b.dat_hor_emissao) as mes,
                  year(b.dat_hor_emissao)  as ano,
		  (month(b.dat_hor_emissao)||'/'||year(b.dat_hor_emissao) ) as mesano,
		  i.nom_cliente,i.cod_cliente,i.cod_tip_cli,
                  day(b.dat_hor_emissao) as dia

             from fat_nf_mestre b,
                  fat_nf_repr br,
                  clientes i

             where b.empresa ='".$empresa."'
               and CAST(b.dat_hor_emissao AS DATE) between '".$ini."' and '".$fim."'
               and b.sit_nota_fiscal <> 'C'
               and i.cod_cliente=b.cliente
               AND br.empresa=b.empresa
               AND br.trans_nota_fiscal=b.trans_nota_fiscal
               AND br.seq_representante=1
           order by  9,8,3,2 ";
  $res_notas = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_notas = $cquery($selec_notas,$res_notas);
  $mat_notas=$cfetch_row($result_notas);
  $vlme=0;
  $vlmc=0;
  $vlma=0;
  $vlm=0;
  $matim=0;
  $matem=0;
  $totm=0;
  $matit=0;
  $matet=0;
  $matimd=0;
  $matemd=0;
  $totmd=0;
  $matitd=0;
  $matet=0;
  $tottd=0;
  $tott=0;

  $mes_ant=0;
  $mes_atu=$mat_notas["mesano"];
  $emp_ant=$mat_notas["cod_empresa"];
  $emp_atu=$mat_notas["cod_empresa"];
  $zero=" ";
  $limpo="&nbsp";
  $matiem01=0;
  $mateem01=0;
  $totem01=0;
  $matiem02=0;
  $mateem02=0;
  $totem02=0;
  $matiem03=0;
  $mateem03=0;
  $totem03=0;
  $pdf->SetFont('Arial','B',10);
  $pdf->Ln();
  $pdf->SetFillColor(0);
  $xpos=$pdf->getx();
  $ypos=$pdf->gety();
  $pdf->Settextcolor('255');
  $pdf->Cell(190,5,'NOTAS FISCAIS EMITIDAS ENTRE:'.$ini.' E '.$fim.'(VALOR TOTAL DA MERCADORIA)',TRL,0,'C',1);
  $pdf->SetFont('Arial','B',8);
  $pdf->Settextcolor('0','0','0');
  $pdf->SetFillColor(260);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->Cell(40,5,'',TL,0,'C',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(50,5,'MERCADO INTERNO',TRL,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(50,5,'MERCADO EXTERNO',TRL,0,'C',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(50,5,'TOTAIS',TRL,0,'C',1);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->SetFillColor(260);
  $pdf->Cell(40,5,'MES/ANO',LB,0,'C',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(25,5,'VALOR NOTAS',RBTL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RBTL,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(25,5,'VALOR NOTAS',RBTL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RBTL,0,'C',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(25,5,'VALOR NOTAS',RBTL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RBTL,0,'C',1);
  $pdf->SetFillColor(240);

  while (is_array($mat_notas))
  {
   $vlme=($vlme+($mat_notas["val_tot_mercadoria"]));
   $mes_atu=$mat_notas["mesano"];
   $mesano_ctr_atu=chop($mat_notas["mes"]).chop($mat_notas["ano"]);
   $emp_at=$mat_notas["cod_empresa"];
   $tip_cli_atu=$mat_notas["cod_tip_cli"];
   $dia_rel=round($mat_notas["dia"]);
   $mes_rel=round($mat_notas["mes"]);
   $ano_rel=round($mat_notas["ano"]);
   $valor=$vlme;
   $valor=round($valor,2);


   if($dia_rel==$dia_ctr and $mes_rel==$mes_ctr and $ano_rel==$ano_ctr)
   {
    if($tip_cli_atu==66)
    {
     $matemd=$matemd+$valor;
     $matetd=$matetd+$valor;
     $matet=$matet+$valor;
     $totmd=$totmd+$valor;
     $tottd=$tottd+$valor;
     $tott=$tott+$valor;
    }elseif($tip_cli_atu<>66){
     $matimd=$matimd+$valor;
     $matitd=$matitd+$valor;
     $matit=$matit+$valor;
     $totmd=$totmd+$valor;
     $tottd=$tottd+$valor;
     $tott=$tott+$valor;
    }
    $vlme=0;
   }else{
    if($tip_cli_atu==66)
    {
     $valor=round($valor,2);
     $matem=$matem+$valor;
     $matet=$matet+$valor;
     $totm=$totm+$valor;
     $tott=$tott+$valor;
     $mateem=$mateem+$valor;
     $mateet=$mateet+$valor;
     $totem=$totem+$valor;
     $totet=$totet+$valor;
    }elseif($tip_cli_atu<>66){
     $matim=$matim+$valor;
     $matit=$matit+$valor;
     $totm=$totm+$valor;
     $tott=$tott+$valor;
     $matiem=$matiem+$valor;
     $matiet=$matiet+$valor;
     $totem=$totem+$valor;
     $totet=$totet+$valor;
    }
   } 
   $vlme=0;
   $matiem=0;
   $mateem=0;
   $totem=0;


   $mes_ant=$mat_notas["mesano"];
   $emp_ant=$mat_notas["cod_empresa"];
   $mesano_ctr_ant=chop($mat_notas["mes"]).chop($mat_notas["ano"]);
   $emp_ant=$mat_notas["cod_empresa"];
   $tip_cli_ant=$mat_notas["cod_tip_cli"];

   $mat_notas=$cfetch_row($result_notas);

   $mes_atu=$mat_notas["mesano"];
   $emp_atu=$mat_notas["cod_empresa"];
   $mes_atu=$mat_notas["mesano"];
   $emp_atu=$mat_notas["cod_empresa"];
   $mesano_ctr_atu=chop($mat_notas["mes"]).chop($mat_notas["ano"]);
   $emp_atu=$mat_notas["cod_empresa"];
   $tip_cli_atu=$mat_notas["cod_tip_cli"];

   if($mes_ant<>$mes_atu)
   {
    if($mesano_ctr_ant<>$mesano_ctr)
    {
     $pdf->ln();
     $pdf->setx(10);
     $pdf->SetFillColor(260);
     $pdf->Cell(40,5,$mes_ant,LB,0,'L',1);
     $pdf->SetFillColor(220);
     $pdf->Cell(25,5,number_format($matim,2,",","."),LB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedi_array[$mes_ant],0,",","."),LB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->Cell(25,5,number_format($matem,2,",","."),LB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pede_array[$mes_ant],0,",","."),LB,0,'R',1);
     $pdf->SetFillColor(240);
     $pdf->Cell(25,5,number_format($totm,2,",","."),LB,0,'R',1);
     $pdf->Cell(25,5,number_format(($qtd_pedi_array[$mes_ant]+$qtd_pede_array[$mes_ant]),LRB,",","."),LRB,0,'R',1);
     $pdf->SetFillColor(260);
    }else{
     if(($dia_ctr-1)>0)
     {
      $pdf->ln();
      $pdf->setx(10);
      $pdf->SetFillColor(260);
      $pdf->Cell(40,5,'NFs ate Dia:'.($dia_ctr-1)."/".$mes_ctr."/".$ano_ctr,LB,0,'L',1);
      $pdf->SetFillColor(220);
      $pdf->Cell(25,5,number_format($matim,2,",","."),LB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_pedi_array[$mes_ant],0,",","."),LB,0,'R',1);
      $pdf->SetFillColor(260);
      $pdf->Cell(25,5,number_format($matem,2,",","."),LB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_pede_array[$mes_ant],0,",","."),LB,0,'R',1);
      $pdf->SetFillColor(240);
      $pdf->Cell(25,5,number_format($totm,2,",","."),LB,0,'R',1);
      $pdf->Cell(25,5,number_format(($qtd_pedi_array[$mes_ant]+$qtd_pede_array[$mes_ant]),LRB,",","."),LRB,0,'R',1);
      $pdf->SetFillColor(260);
     }    
     $pdf->ln();
     $pdf->setx(10);;
     $pdf->SetFillColor(260);
     $pdf->SetFont('Arial','B',8);
     $pdf->Cell(40,5,'NFs Dia:'.$dia_ctr."/".$mes_ctr."/".$ano_ctr,LB,0,'L',1);
     $pdf->SetFillColor(220);
     $pdf->Cell(25,5,number_format($matitd,2,",","."),LB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedid,0,",","."),LB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->Cell(25,5,number_format($matetd,2,",","."),LB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_peded,0,",","."),LB,0,'R',1);
     $pdf->SetFillColor(240);
     $pdf->Cell(25,5,number_format($tottd,2,",","."),LB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedid+$qtd_peded,0,",","."),LRB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->ln();
    }
    $matim=0;
    $matem=0;
    $totm=0;
   }
  }
  $pdf->setx(10);;
  $pdf->SetFillColor(260);
  $pdf->SetFont('Arial','B',10);
  $pdf->Cell(40,6,'Total Geral ',LTB,0,'L',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(25,6,number_format($matit,2,",","."),LTB,0,'R',1);
  $pdf->Cell(25,6,number_format($qtd_pedit+$qtd_pedid,0,",","."),LTB,0,'R',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(25,6,number_format($matet,2,",","."),LTB,0,'R',1);
  $pdf->Cell(25,6,number_format($qtd_pedet+$qtd_peded,0,",","."),LTB,0,'R',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(25,6,number_format($tott,2,",","."),LTB,0,'R',1);
  $pdf->Cell(25,6,number_format($qtd_pedit+$qtd_pedet+$qtd_pedid+$qtd_peded,0,",","."),LRTB,0,'R',1);
  $pdf->SetFillColor(260);
  $pdf->ln();
  $matem=0;
  $matemd=0;
  $matem=0;
  $totet=0;
  $matemd=0;
  $matet=0;

//Pedidos Exportacao
  $matem=0;
  $totet=0;
  $matemd=0;
  $matet=0;
 
  $selec_pedido="SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  b.ies_frete,b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  year(b.dat_pedido) as ano ,month(b.dat_pedido) as mes,
		  (month(b.dat_pedido)||'/'||year(b.dat_pedido) ) as mesano,
		  i.nom_cliente,i.cod_cliente,i.cod_tip_cli,
                  day(b.dat_pedido) as dia

             from pedidos b,
                  ped_itens e,
                  clientes i


             where b.cod_empresa ='".$empresa."'
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and b.dat_pedido between '".$ini."' and '".$fim."'
               and b.ies_sit_pedido <> '9'
               and i.cod_cliente=b.cod_cliente
               and i.cod_tip_cli='66'
                 order by 16,17,2,3    ";

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
  $matem=0;
  $matet=0;
  $matemd=0;
  $totet=0;
  $mes_ant=0;
  $mes_atu=$mat_pedido["mesano"];
  $emp_ant=$mat_pedido["cod_empresa"];
  $emp_atu=$mat_pedido["cod_empresa"];
  $qtd_peded=0;
  $qtd_pedet=0;
  $qtd_pede=0;
  $zero="";
  while(is_array($mat_pedido))
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
   if($dia_rel==$dia_ctr and $mes_rel==$mes_ctr and $ano_rel==$ano_ctr)
   {
    if($tip_cli_atu=='66')
    {
     $matemd=$matemd+$valor;
     $matet=$matet+$valor;
     $totet=$totet+$valor;
     if($ped_ant<>$ped_atu)
     {
      $qtd_peded=$qtd_peded+1;
      $qtd_pedet=$qtd_pedet+1;
     }
    }  
   }else{
    if($tip_cli_atu=='66')
    {
     $matem=$matem+$valor;
     $matet=$matet+$valor;
     $totet=$totet+$valor;
     $totem=$totem+$valor;
     if($ped_ant<>$ped_atu)
     {
      $qtd_pede=$qtd_pede+1;
      $qtd_pedet=$qtd_pedet+1;
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

   $pdf->SetFillColor(260);

   if($mes_ant<>$mes_atu)
   {
    if($mesano_ctr_ant<>$mesano_ctr)
    {
     $matem_array[$mes_ant]=$matem;
     $qtd_pede_array[$mes_ant]=$qtd_pede;
    }else{
     if(($dia_ctr-1>0))
     {
     $matem_array[$dia_ctr]=$matem;
     $qtd_pede_array[$dia_ctr]=$qtd_pede;
     }
    }
    $matem=0;
    $qtd_pede=0;
   }
  }
  $matem=0;

//Mercado Interno
  $matim=0;
  $totit=0;
  $matimd=0;
  $matit=0;

  $pdf->SetFont('Arial','B',10);
  $pdf->Ln();
  $pdf->SetFillColor(0);
  $xpos=$pdf->getx();
  $ypos=$pdf->gety();
  $pdf->Settextcolor('255');
  $pdf->Cell(190,5,'PEDIDOS ERP EMITIDOS ENTRE:'.$ini.' E '.$fim.'(VALOR TOTAL DA MERCADORIA)',TRL,0,'C',1);
  $pdf->SetFont('Arial','B',8);
  $pdf->Settextcolor('0','0','0');
  $pdf->SetFillColor(260);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->Cell(40,5,'',TL,0,'C',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(50,5,'MERCADO INTERNO',TBRL,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(50,5,'MERCADO EXTERNO',TBRL,0,'C',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(50,5,'TOTAIS',TBRL,0,'C',1);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->SetFillColor(260);
  $pdf->Cell(40,5,'MES/ANO',LB,0,'C',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(25,5,'VALOR PEDIDOS',RTBL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RTBL,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(25,5,'VALOR PEDIDOS',RTBL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RTBL,0,'C',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(25,5,'VALOR PEDIDOS',RTBL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RTBL,0,'C',1);
  $pdf->SetFillColor(260);


  $selec_pedido="SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  b.ies_frete,b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
		  year(b.dat_pedido) as ano ,month(b.dat_pedido) as mes,
		  (month(b.dat_pedido)||'/'||year(b.dat_pedido) ) as mesano,
		  i.nom_cliente,i.cod_cliente,i.cod_tip_cli,
                  day(b.dat_pedido) as dia

             from pedidos b,
                  ped_itens e,
                  clientes i
                  
             where b.cod_empresa ='".$empresa."'
               and e.cod_empresa=b.cod_empresa
               and b.dat_pedido between '".$ini."' and '".$fim."'
               and b.ies_sit_pedido <> '9'
               and e.num_pedido=b.num_pedido
               and i.cod_cliente=b.cod_cliente
           order by  16,17,3,2            ";
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

   $pdf->SetFillColor(260);

   if($mes_ant<>$mes_atu)
   {
    if($mesano_ctr_ant<>$mesano_ctr)
    {
     $pdf->ln();
     $pdf->setx(10);
     $pdf->SetFillColor(260);
     $pdf->Cell(40,5,$mes_ant,TRBL,0,'L',1);
     $pdf->SetFillColor(220);
     $pdf->Cell(25,5,number_format($matim,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedi,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->Cell(25,5,number_format($matem_array[$mes_ant],2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pede_array[$mes_ant],0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(240);
     $pdf->Cell(25,5,number_format($matim+$matem_array[$mes_ant],2,",","."),TRB,0,'R',1); 
     $pdf->Cell(25,5,number_format($qtd_pedi+$qtd_pede_array[$mes_ant],0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
    }else{
     if(($dia_ctr-1>0))
     {
      $pdf->ln();
      $pdf->setx(10);
      $pdf->SetFillColor(260);
      $pdf->Cell(40,5,'Pedidos ate Dia:'.($dia_ctr-1)."/".$mes_ctr."/".$ano_ctr,TRBL,0,'L',1);
      $pdf->SetFillColor(220);
      $pdf->Cell(25,5,number_format($matim,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_pedi,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
      $pdf->Cell(25,5,number_format($matem_array[$dia_ctr],2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_pede_array[$dia_ctr],0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(240);
      $pdf->Cell(25,5,number_format($matim+$matem_array[$dia_ctr],2,",","."),TRB,0,'R',1); 
      $pdf->Cell(25,5,number_format($qtd_pedi+$qtd_pede_array[$dia_ctr],0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
     }
     $pdf->ln();
     $pdf->setx(10);;
     $pdf->SetFillColor(260);
     $pdf->SetFont('Arial','B',8);
     $pdf->Cell(40,5,'Pedidos Dia:'.$dia_ctr."/".$mes_ctr."/".$ano_ctr,LRB,0,'L',1);
     $pdf->SetFillColor(220);
     $pdf->Cell(25,5,number_format($matimd,2,",","."),RB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedid,0,",","."),RB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->Cell(25,5,number_format($matemd,2,",","."),RB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_peded,0,",","."),RB,0,'R',1);
     $pdf->SetFillColor(240);
     $pdf->Cell(25,5,number_format($matimd+$matemd,2,",","."),RB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedid+$qtd_peded,0,",","."),RB,0,'R',1);
     $pdf->SetFillColor(260);
    }
    $matim=0;
    $matem=0;
    $jacm=0;
    $spm=0;
    $totm=0;
    $qtd_pedi=0;
    $qtd_pede=0;
   }
  }
  $pdf->ln();
  $pdf->setx(10); 
  $pdf->SetFillColor(260);
  $pdf->SetFont('Arial','B',10);
  $pdf->Cell(40,5,'Total Geral ',RLBT,0,'L',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(25,5,number_format($matit,2,",","."),RBT,0,'R',1);
  $pdf->Cell(25,5,number_format($qtd_pedit,0,",","."),RBT,0,'R',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(25,5,number_format($totet,2,",","."),RBT,0,'R',1);
  $pdf->Cell(25,5,number_format($qtd_pedet,0,",","."),RBT,0,'R',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(25,5,number_format($totet+$totit,2,",","."),RBT,0,'R',1);
  $pdf->Cell(25,5,number_format($qtd_pedet+$qtd_pedit,0,",","."),RBT,0,'R',1);
  $pdf->SetFillColor(260);
  $pdf->ln();
  $matim=0;
  $matem=0;
  $totm=0;


//CANCELADOS
  $matim=0;
  $matem=0;
  $totm=0;
  $matimd=0;
  $matemd=0;
  $totmd=0;
  $pdf->SetFont('Arial','B',10);
  $pdf->Ln();
  $pdf->SetFillColor(0);
  $xpos=$pdf->getx();
  $ypos=$pdf->gety();
  $pdf->Settextcolor('255');
  $pdf->Cell(190,5,'PEDIDOS ERP CANCELADOS ENTRE:'.$ini.' E '.$fim.'(VALOR TOTAL DA MERCADORIA)',TRL,0,'C',1);
  $pdf->SetFont('Arial','B',8);
  $pdf->Settextcolor('0','0','0');
  $pdf->SetFillColor(260);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->Cell(40,5,'',TL,0,'C',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(50,5,'MERCADO INTERNO',TBRL,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(50,5,'MERCADO EXTERNO',TBRL,0,'C',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(50,5,'TOTAIS',TBRL,0,'C',1);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->SetFillColor(260);
  $pdf->Cell(40,5,'MES/ANO',LB,0,'C',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(25,5,'VALOR PEDIDOS',RTBL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RTBL,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(25,5,'VALOR PEDIDOS',RTBL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RTBL,0,'C',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(25,5,'VALOR PEDIDOS',RTBL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RTBL,0,'C',1);
  $pdf->SetFillColor(260);
/*SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,b.num_pedido_repres,
                  b.ies_frete,b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,b.cod_repres,
                  e.pre_unit,a.texto[76,87] as qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.prz_entrega,e.num_sequencia,
		  year(a.data) as ano ,month(a.data) as mes,
		  (month(a.data)||'/'||year(a.data) ) as mesano,
		  i.nom_cliente,i.cod_cliente,i.cod_tip_cli,
                  day(a.data) as dia
             from audit_vdp a,
                  pedidos b,
                  ped_itens e,
                  clientes i,
                  representante d,
                  cidades f,
                  fiscal_par j


             where a.cod_empresa ='".$empresa."'
               and a.data between '".$ini."' and '".$fim."'
               and a.tipo_movto='C'
               and a.num_programa='VDP1080'
               and a.texto[1,3]='SEQ'
               and b.num_pedido=a.num_pedido               
               and b.cod_empresa=a.cod_empresa
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and trim(e.cod_item)=trim(a.texto[18,24])
               and e.num_sequencia=trim(a.texto[6,12])
               and i.cod_cliente=b.cod_cliente
               and f.cod_cidade=i.cod_cidade
               and d.cod_repres=b.cod_repres
               and j.cod_nat_oper=b.cod_nat_oper
               and j.cod_empresa=b.cod_empresa
               and j.cod_uni_feder=f.cod_uni_feder
union
*/
  $selec_pedido="
        SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,b.num_pedido_repres,
                  b.ies_frete,b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,b.cod_repres,
                  e.pre_unit,e.qtd_pecas_cancel as qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.prz_entrega,e.num_sequencia,
		  year(a.data) as ano ,month(a.data) as mes,
		  (month(a.data)||'/'||year(a.data) ) as mesano,
		  i.nom_cliente,i.cod_cliente,i.cod_tip_cli,
                  day(a.data) as dia
             from audit_vdp a,
                  pedidos b,
                  ped_itens e,
                  clientes i,
                  representante d,
                  cidades f
                  --,fiscal_par j


             where a.tipo_movto='C'
               and a.num_programa='VDP1080'
               and a.texto[1,16]='PEDIDO CANCELADO'
               and b.num_pedido=a.num_pedido               
               and b.cod_empresa=a.cod_empresa
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and i.cod_cliente=b.cod_cliente
               and f.cod_cidade=i.cod_cidade
               and d.cod_repres=b.cod_repres
               --and j.cod_nat_oper=b.cod_nat_oper
               --and j.cod_empresa=b.cod_empresa
               --and j.cod_uni_feder=f.cod_uni_feder
               and b.num_pedido in (select unique num_pedido from audit_vdp where
                                        cod_empresa ='".$empresa."'
                                        and data between '".$ini."' and '".$fim."'
                                        and tipo_movto='C'
                                        and texto[1,16]='PEDIDO CANCELADO'
                                        and num_programa='VDP1080')
           order by  ano,mes,b.cod_empresa,b.num_pedido            ";
  
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
  $matem=0;
  $totm=0;
  $matit=0;
  $matet=0;
  $tott=0;
  $mes_ant=0;
  $mes_atu=$mat_pedido["mesano"];
  $emp_ant=$mat_pedido["cod_empresa"];
  $emp_atu=$mat_pedido["cod_empresa"];
  $qtd_pedi=0;
  $qtd_pede=0;
  $qtd_pedid=0;
  $qtd_peded=0;
  $qtd_pedit=0;
  $qtd_pedet=0;
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
   $tip_cli_atu=$mat_pedido["cod_tip_cli"]; 
   $valor=$vlme;
   $valor=round($valor,2);

   if($dia_rel==$dia_ctr and $mes_rel==$mes_ctr and $ano_rel==$ano_ctr)
   {
    if($tip_cli_atu==66)
    {
     $valor=round($valor,2);
     $matemd=$matemd+$valor;
     $matet=$matet+$valor;
     $tott=$tott+$valor;
     if($ped_ant<>$ped_atu)
     {
      $qtd_peded=$qtd_peded+1;
     }
    }elseif($tip_cli_atu<>66){
     $matimd=$matimd+$valor;
     $matit=$matit+$valor;
     $tott=$tott+$valor;
     if($ped_ant<>$ped_atu)
     {
      $qtd_pedid=$qtd_pedid+1;
     }
    }  
   }else{
    if($tip_cli_atu==66)
    {
     $valor=$valor*$mat_pedido["us"];
     $valor=round($valor,2);
     $matem=$matem+$valor;
     $matet=$matet+$valor;
     $totm=$totm+$valor;
     $tott=$tott+$valor;
     $mateem=$mateem+$valor;
     $mateet=$mateet+$valor;
     $totem=$totem+$valor;
     $totet=$totet+$valor;
     if($ped_ant_1<>$ped_atu_1)
     {
      $qtd_pede=$qtd_pede+1;
      $qtd_pedet=$qtd_pedet+1;
     }
    }elseif($tip_cli_atu<>66){
     $matim=$matim+$valor;
     $matit=$matit+$valor;
     $totm=$totm+$valor;
     $tott=$tott+$valor;
     $matiem=$matiem+$valor;
     $matiet=$matiet+$valor;
     $totem=$totem+$valor;
     if($ped_ant_1<>$ped_atu_1)
     {
      $qtd_pedi=$qtd_pedi+1;
      $qtd_pedit=$qtd_pedit+1;
     }
     $totet=$totet+$valor; 
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

   $pdf->SetFillColor(260);

   if($mes_ant<>$mes_atu)
   {
    if($mesano_ctr_ant<>$mesano_ctr)
    {
     $pdf->ln();
     $pdf->setx(10);
     $pdf->SetFillColor(260);
     $pdf->Cell(40,5,$mes_ant,TRBL,0,'L',1);
     $pdf->SetFillColor(220);
     $pdf->Cell(25,5,number_format($matim,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedi,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->Cell(25,5,number_format($matem,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pede,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(240);
     $pdf->Cell(25,5,number_format($totm,2,",","."),TRB,0,'R',1); 
     $pdf->Cell(25,5,number_format($qtd_pedi+$qtd_pede,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
    }else{
     if(($dia_ctr-1>0))
     {
      $pdf->ln();
      $pdf->setx(10);
      $pdf->SetFillColor(260);
      $pdf->Cell(40,5,'Pedidos ate Dia:'.($dia_ctr-1)."/".$mes_ctr."/".$ano_ctr,TRBL,0,'L',1);
      $pdf->SetFillColor(220);
      $pdf->Cell(25,5,number_format($matim,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_pedi,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
      $pdf->Cell(25,5,number_format($matem,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_pede,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(240);
      $pdf->Cell(25,5,number_format($totm,2,",","."),TRB,0,'R',1); 
      $pdf->Cell(25,5,number_format($qtd_pedi+$qtd_pede,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
     }
     $pdf->ln();
     $pdf->setx(10);;
     $pdf->SetFillColor(260);
     $pdf->SetFont('Arial','B',8);
     $pdf->Cell(40,5,'Pedidos Dia:'.$dia_ctr."/".$mes_ctr."/".$ano_ctr,LRB,0,'L',1);
     $pdf->SetFillColor(220);
     $pdf->Cell(25,5,number_format($matimd,2,",","."),RB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedid,0,",","."),RB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->Cell(25,5,number_format($matemd,2,",","."),RB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_peded,0,",","."),RB,0,'R',1);
     $pdf->SetFillColor(240);
     $pdf->Cell(25,5,number_format($matimd+$matend,2,",","."),RB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedid+$qtd_peded,0,",","."),RB,0,'R',1);
     $pdf->SetFillColor(260);
    }
    $matim=0;
    $matem=0;
    $jacm=0;
    $spm=0;
    $totm=0;
    $qtd_pedi=0;
    $qtd_pede=0;
   }
  }
  $pdf->ln();
  $pdf->setx(10); 
  $pdf->SetFillColor(260);
  $pdf->SetFont('Arial','B',10);
  $pdf->Cell(40,5,'Total Geral ',RLBT,0,'L',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(25,5,number_format($matit,2,",","."),RBT,0,'R',1);
  $pdf->Cell(25,5,number_format($qtd_pedit+$qtd_pedid,0,",","."),RBT,0,'R',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(25,5,number_format($matet,2,",","."),RBT,0,'R',1);
  $pdf->Cell(25,5,number_format($qtd_pedet+$qtd_peded,0,",","."),RBT,0,'R',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(25,5,number_format($tott,2,",","."),RBT,0,'R',1);
  $pdf->Cell(25,5,number_format($qtd_pedet+$qtd_pedit+$qtd_peded+$qtd_pedid,0,",","."),RBT,0,'R',1);
  $pdf->SetFillColor(260);
  $pdf->ln();
  $matim=0;
  $matem=0;
  $totm=0;


//CARTEIRA

  $pdf->SetFont('Arial','B',10);
  $pdf->Ln();
  $pdf->SetFillColor(0);
  $xpos=$pdf->getx();
  $ypos=$pdf->gety();
  $pdf->Settextcolor('255');
  $pdf->Cell(240,5,'PEDIDOS EM CARTEIRA ERP (VALOR TOTAL DA MERCADORIA)',TRL,0,'C',1);
  $pdf->SetFont('Arial','B',8);
  $pdf->Settextcolor('0','0','0');
  $pdf->SetFillColor(260);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->Cell(70,5,'GRUPO DE',TLR,0,'C',1);
  $pdf->Cell(50,5,'FATURADO NO MES:'.$mes_ctr.'/'.$ano_ctr,TL,0,'C',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(50,5,'PEDIDOS DO MES:'.$mes_ctr.'/'.$ano_ctr,TL,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(35,5,'PROGRAMADO',TL,0,'C',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(35,5,'ENTREGA FUTURA',TLR,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->Cell(70,5,'PRODUTO',LBR,0,'C',1);
  $pdf->Cell(15,5,'QTD',RBTL,0,'C',1);
  $pdf->Cell(20,5,'VALOR',BTR,0,'C',1);
  $pdf->Cell(15,5,'PC.MEDIO',RBT,0,'C',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(15,5,'QTD',RBTL,0,'C',1);
  $pdf->Cell(20,5,'VALOR',BTR,0,'C',1);
  $pdf->Cell(15,5,'PC.MEDIO',RBT,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(15,5,'QTD',BTLR,0,'C',1);
  $pdf->Cell(20,5,'VALOR',BTR,0,'C',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(15,5,'QTD',RBTL,0,'C',1);
  $pdf->Cell(20,5,'VALOR',BTR,0,'C',1);
  $pdf->SetFillColor(260);
  $selec_pedido="
          SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
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
                  'PED' as tipo,0 as val_desc_merc,0 as val_tot_mercadoria
             from pedidos b,
                  ped_itens e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n
             where b.cod_empresa ='01'
               and b.ies_sit_pedido <> '9'
               and b.dat_pedido between '".$ini."' and '".$fin."'
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
union
         SELECT (b.nota_fiscal||'-'||b.empresa) as ped_emp,
                  b.nota_fiscal as num_pedido,b.empresa AS cod_empresa,
                  0 as pct_desc_financ,
                  0 as pct_desc_adic_ped,
                  e.pct_frete,b.sit_nota_fiscal as ies_sit_pedido,
                  e.preco_unit_liquido AS pre_unit,
                  e.qtd_item as qtd_pecas_solic,0 as qtd_pecas_atend,0 as qtd_pecas_cancel,
                  0 AS pct_desc_adic,0 as pct_desc_bruto,e.seq_item_pedido AS num_sequencia,
		  year(b.dat_hor_emissao) as ano ,month(b.dat_hor_emissao) as mes,
		  (month(b.dat_hor_emissao)||'/'||year(b.dat_hor_emissao) ) as mesano,
		  i.nom_cliente,i.cod_cliente,
                  day(b.dat_hor_emissao) as dia,
                  l.den_grupo_item ,
		  year(b.dat_hor_emissao) as ano_ped ,month(b.dat_hor_emissao) as mes_ped,
                  m.cod_familia,m.cod_item,m.den_item,
                  n.cod_lin_prod,n.den_estr_linprod,'' as sit_erp ,
                  'NFF' as tipo,e.val_desc_merc,(e.val_merc_item+e.val_desc_merc) as val_tot_mercadoria
             from fat_nf_mestre b,
                  fat_nf_item  e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n
             where b.empresa ='".$empresa."'
               and CAST(b.dat_hor_emissao AS DATE) between '".$ini."' and '".$fim."'
               and b.sit_nota_fiscal <> 'C'
               and e.empresa=b.empresa
               and e.trans_nota_fiscal=b.trans_nota_fiscal
               and i.cod_cliente=b.cliente
               and k.cod_empresa=e.empresa
               and k.cod_item=e.item
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
  
           order by n.cod_lin_prod,m.cod_familia,l.den_grupo_item,m.den_item,m.cod_item";

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

  $val_fat_grupo_mes=0;
  $qtd_fat_grupo_mes=0;
  $val_grupo_mes=0;
  $qtd_grupo_mes=0;
  $val_grupo_tmes=0;
  $qtd_grupo_tmes=0;
  $val_grupo_f=0;
  $qtd_grupo_f=0;

  $val_fat_linha_mes=0;
  $qtd_fat_linha_mes=0;
  $val_linha_mes=0;
  $qtd_linha_mes=0;
  $val_linha_tmes=0;
  $qtd_linha_tmes=0;
  $val_linha_f=0;
  $qtd_linha_f=0;

  $tval_fat_grupo_mes=0;
  $tqtd_fat_grupo_mes=0;
  $tval_grupo_mes=0;
  $tqtd_grupo_mes=0;
  $tval_grupo_tmes=0;
  $tqtd_grupo_tmes=0;
  $tval_grupo_f=0;
  $tqtd_grupo_f=0;


  $qtd_pecas_ant=0;
  $zero="";

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
   $valor=$vlme-$vlmc-$vlma;
   $tipo=$mat_pedido["tipo"];

   if($tipo=="PED")
   { 
    if($mes_atu_ped==$mes_ctr and $ano_atu_ped==$ano_ctr )
    {
     $qtd_pecas_ant=($qtd_pecas_ant+($mat_pedido["qtd_pecas_solic"]-$mat_pedido["qtd_pecas_cancel"]));
     $val_grupo_mes=$val_grupo_mes+$valorm;
     $qtd_grupo_mes=$qtd_grupo_mes+($mat_pedido["qtd_pecas_solic"]
               -$mat_pedido["qtd_pecas_cancel"]);
    }
    if($mes_atu <=$mes_ctr and $ano_atu==$ano_ctr )
    {
     $val_grupo_tmes=$val_grupo_tmes+$valor;
     $qtd_grupo_tmes=$qtd_grupo_tmes+($mat_pedido["qtd_pecas_solic"]-$qtd_pecas_atend
                 -$mat_pedido["qtd_pecas_cancel"]);
    }
   }
   //faturamento do mes
   if($tipo=="NFF")
   { 
    if($mes_atu_ped==$mes_ctr and $ano_atu_ped==$ano_ctr )
    {
     $val_desc_merc=$mat_pedido["val_desc_merc"];
     if($val_desc_merc > 0)
     {
     $val_tot_mercadoria=$mat_pedido["val_tot_mercadoria"]; 
     $val_desc_item=$valorm*100/$val_tot_mercadoria; 
      $val_desc_merc=($val_desc_merc*$val_desc_item)/100;
      $valorm=$valorm-$val_desc_merc;
     }
     $val_fat_grupo_mes=$val_fat_grupo_mes+$valorm;
     $qtd_fat_grupo_mes=$qtd_fat_grupo_mes+($mat_pedido["qtd_pecas_solic"]
               -$mat_pedido["qtd_pecas_cancel"]);
    }
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
   if($depura=="S")
   {   
    if($cod_item_atu<>$cod_item_ant)
    {
     $pdf->ln();
     $pdf->setx(10);
     $pdf->Cell(20,5,$cod_item_ant,TLR,0,'L',1);
     $pdf->Cell(120,5,$den_item_ant,TLR,0,'L',1);
     $pdf->Cell(15,5,number_format($qtd_pecas_ant,2,",","."),TLR,0,'R',1);
     $qtd_pecas_ant=0;
    }
   }
   $pdf->SetFillColor(260);
   if($grupo_atu<>$grupo_ant)
   {
    $pdf->ln();
    $pdf->setx(10);
    $pdf->Cell(70,5,chop($grupo_ant),TLR,0,'L',1);
    $pdf->Cell(15,5,number_format($qtd_fat_grupo_mes,0,",","."),TLR,0,'R',1);
    $pdf->Cell(20,5,number_format($val_fat_grupo_mes,2,",","."),TR,0,'R',1);
    $pdf->Cell(15,5,number_format(($val_fat_grupo_mes/$qtd_fat_grupo_mes),2,",","."),TR,0,'R',1); 
    $pdf->SetFillColor(220);
    $pdf->Cell(15,5,number_format($qtd_grupo_mes,0,",","."),TLR,0,'R',1);
    $pdf->Cell(20,5,number_format($val_grupo_mes,2,",","."),TR,0,'R',1);
    $pdf->Cell(15,5,number_format(($val_grupo_mes/$qtd_grupo_mes),2,",","."),TR,0,'R',1); 
    $pdf->SetFillColor(260);
    $pdf->Cell(15,5,number_format($qtd_grupo_tmes,0,",","."),TLR,0,'R',1);
    $pdf->Cell(20,5,number_format($val_grupo_tmes,2,",","."),TR,0,'R',1);
    $pdf->SetFillColor(240);
    $pdf->Cell(15,5,number_format($qtd_grupo_f,0,",","."),TLR,0,'R',1);
    $pdf->Cell(20,5,number_format($val_grupo_f,2,",","."),TR,0,'R',1);
    $pdf->SetFillColor(260);

    $tqtd_fat_grupo_mes=$tqtd_fat_grupo_mes+$qtd_fat_grupo_mes;
    $tval_fat_grupo_mes=$tval_fat_grupo_mes+$val_fat_grupo_mes;
    $tqtd_grupo_mes=$tqtd_grupo_mes+$qtd_grupo_mes;
    $tval_grupo_mes=$tval_grupo_mes+$val_grupo_mes;
    $tqtd_grupo_tmes=$tqtd_grupo_tmes+$qtd_grupo_tmes;
    $tval_grupo_tmes=$tval_grupo_tmes+$val_grupo_tmes;
    $tqtd_grupo_f=$tqtd_grupo_f+$qtd_grupo_f;
    $tval_grupo_f=$tval_grupo_f+$val_grupo_f;

    $qtd_fat_linha_mes=$qtd_fat_linha_mes+$qtd_fat_grupo_mes;
    $val_fat_linha_mes=$val_fat_linha_mes+$val_fat_grupo_mes;
    $qtd_linha_mes=$qtd_linha_mes+$qtd_grupo_mes;
    $val_linha_mes=$val_linha_mes+$val_grupo_mes;
    $qtd_linha_tmes=$qtd_linha_tmes+$qtd_grupo_tmes;
    $val_linha_tmes=$val_linha_tmes+$val_grupo_tmes;
    $qtd_linha_f=$qtd_linha_f+$qtd_grupo_f;
    $val_linha_f=$val_linha_f+$val_grupo_f;

    $qtd_fat_grupo_mes=0;
    $val_fat_grupo_mes=0;
    $qtd_grupo_mes=0;
    $val_grupo_mes=0;
    $qtd_grupo_tmes=0;
    $val_grupo_tmes=0;
    $qtd_grupo_f=0;
    $val_grupo_f=0;
   }
   if($linha_atu<>$linha_ant)
   {
    $pdf->ln();
    $pdf->setx(10);
    $pdf->SetFont('Arial','B',8);
    $pdf->SetFillColor(0);
    $pdf->Settextcolor('255');
    $pdf->Cell(70,5,"TOTAL:".chop($linha_ant),LTR,0,'L',1);
    $pdf->Cell(15,5,number_format($qtd_fat_linha_mes,0,",","."),TLR,0,'R',1);
    $pdf->Cell(20,5,number_format($val_fat_linha_mes,2,",","."),TR,0,'R',1);
    if($qtd_fat_linha_mes > 0)
    {
     $pdf->Cell(15,5,number_format(($val_fat_linha_mes/$qtd_fat_linha_mes),2,",","."),TR,0,'R',1); 
    }else{ 
     $pdf->Cell(15,5,0,TR,0,'R',1); 
    }
    $pdf->Cell(15,5,number_format($qtd_linha_mes,0,",","."),TLR,0,'R',1);
    $pdf->Cell(20,5,number_format($val_linha_mes,2,",","."),TR,0,'R',1);
    if($qtd_linha_mes >0)
    {
     $pdf->Cell(15,5,number_format(($val_linha_mes/$qtd_linha_mes),2,",","."),TR,0,'R',1); 
    }else{ 
     $pdf->Cell(15,5,0,TR,0,'R',1); 
    }
    $pdf->Cell(15,5,number_format($qtd_linha_tmes,0,",","."),TLR,0,'R',1);
    $pdf->Cell(20,5,number_format($val_linha_tmes,2,",","."),TR,0,'R',1);
    $pdf->Cell(15,5,number_format($qtd_linha_f,0,",","."),TLR,0,'R',1);
    $pdf->Cell(20,5,number_format($val_linha_f,2,",","."),TR,0,'R',1);
    $pdf->Settextcolor('0','0','0');
    $pdf->SetFillColor(260);
    $qtd_fat_linha_mes=0;
    $val_fat_linha_mes=0;
    $qtd_linha_mes=0;
    $val_linha_mes=0;
    $qtd_linha_tmes=0;
    $val_linha_tmes=0;
    $qtd_linha_f=0;
    $val_linha_f=0;
    $pdf->SetFont('Arial','B',8);
   }

  }
  $pdf->SetFont('Arial','B',8);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->Cell(70,6,'TOTAL GERAL',TBLR,0,'L',1);
  $pdf->Cell(15,6,number_format($tqtd_fat_grupo_mes,0,",","."),TBLR,0,'R',1);
  $pdf->Cell(20,6,number_format($tval_fat_grupo_mes,2,",","."),TBR,0,'R',1);
  $pdf->Cell(15,6,number_format(($tval_fat_grupo_mes/$tqtd_fat_grupo_mes),2,",","."),TBR,0,'R',1); 
  $pdf->SetFillColor(220);
  $pdf->Cell(15,6,number_format($tqtd_grupo_mes,0,",","."),TBLR,0,'R',1);
  $pdf->Cell(20,6,number_format($tval_grupo_mes,2,",","."),TBR,0,'R',1);
  $pdf->Cell(15,6,number_format(($tval_grupo_mes/$tqtd_grupo_mes),2,",","."),TBR,0,'R',1); 
  $pdf->SetFillColor(260);
  $pdf->Cell(15,6,number_format($tqtd_grupo_tmes,0,",","."),TBLR,0,'R',1);
  $pdf->Cell(20,6,number_format($tval_grupo_tmes,2,",","."),TBR,0,'R',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(15,6,number_format($tqtd_grupo_f,0,",","."),TBLR,0,'R',1);
  $pdf->Cell(20,6,number_format($tval_grupo_f,2,",","."),TBR,0,'R',1);
  $pdf->SetFillColor(260);
  $tqtd_fat_grupo_mes=0;
  $tval_fat_grupo_mes=0;
  $tqtd_grupo_mes=0;
  $tval_grupo_mes=0;
  $tqtd_grupo_tmes=0;
  $tval_grupo_tmes=0;
  $tqtd_grupo_f=0;
  $tval_grupo_f=0;
  $pdf->SetFont('Arial','B',10);
  $pdf->Ln();
  $pdf->SetFont('Arial','B',10);
  $pdf->Ln();
  $pdf->SetFillColor(0);
  $xpos=$pdf->getx();
  $ypos=$pdf->gety();
  $pdf->Settextcolor('255');
  $pdf->Cell(190,5,'ORDENS DE MONTAGEM VALOR TOTAL DA MERCADORIA)',TRL,0,'C',1);
  $pdf->SetFont('Arial','B',8);
  $pdf->Settextcolor('0','0','0');
  $pdf->SetFillColor(260);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->Cell(40,5,'',TL,0,'C',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(50,5,'MERCADO INTERNO',TBRL,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(50,5,'MERCADO EXTERNO',TBRL,0,'C',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(50,5,'TOTAIS',TBRL,0,'C',1);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->SetFillColor(260);
  $pdf->Cell(40,5,'MES/ANO',LB,0,'C',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(25,5,'VALOR PEDIDOS',RTBL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RTBL,0,'C',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(25,5,'VALOR PEDIDOS',RTBL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RTBL,0,'C',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(25,5,'VALOR PEDIDOS',RTBL,0,'C',1);
  $pdf->Cell(25,5,'QTD PEDIDOS',RTBL,0,'C',1);
  $pdf->SetFillColor(260);
  $selec_pedido="SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,b.num_pedido_repres,
                  b.ies_frete,b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,b.cod_repres,
                  e.pre_unit,e.qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.prz_entrega,e.num_sequencia,
		  year(e.prz_entrega) as ano ,month(e.prz_entrega) as mes,
		  (month(e.prz_entrega)||'/'||year(e.prz_entrega) ) as mesano,
		  i.nom_cliente,i.cod_cliente,i.cod_tip_cli,
                  day(e.prz_entrega) as dia,
                  n.ies_sit_om,n.num_om,
                  m.qtd_reservada,
                  o.local

             from pedidos b,
                  ped_itens e,

                  clientes i,
                  representante d,
                  cidades f,

                  --fiscal_par j,
                  item_vdp k,
                  grupo_item l,
                  ordem_montag_item m,
                  ordem_montag_mest n,
                  outer lt1200:lt1200_ctr_om o

		  		  
             where m.cod_empresa ='".$empresa."'
               and e.cod_item=m.cod_item
               and e.num_pedido=m.num_pedido
               and e.num_sequencia=m.num_sequencia
               and n.cod_empresa=m.cod_empresa
               and n.num_om=m.num_om
               and n.ies_sit_om <>'F'
               and b.cod_empresa=m.cod_empresa
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and b.ies_sit_pedido <> '9'
               and i.cod_cliente=b.cod_cliente
               and f.cod_cidade=i.cod_cidade
               and d.cod_repres=b.cod_repres
               --and j.cod_nat_oper=b.cod_nat_oper
               --and j.cod_empresa=b.cod_empresa
               --and j.cod_uni_feder=f.cod_uni_feder
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and l.cod_grupo_item=k.cod_grupo_item
               and o.cod_empresa=n.cod_empresa
               and o.num_om=n.num_om                

           order by  ano,mes,o.local desc,dia,b.cod_empresa,b.num_pedido            ";



  $res_pedido = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_pedido = $cquery($selec_pedido,$res_pedido);
  $mat_pedido=$cfetch_row($result_pedido);
  $ped_ant="0"; 
  $ped_atu=$mat_pedido["ped_emp"]; 
  $ped_ant_1="0"; 
  $ped_atu_1=$mat_pedido["ped_emp"]; 
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
  $qtd_pedi=0;
  $qtd_pede=0;
  $qtd_pedid=0;
  $qtd_peded=0;
  $qtd_pedit=0;
  $qtd_pedet=0;
  $matimd=0;
  $matemd=0;
  $qtd_pedid=0;
  $qtd_peded=0;
  $matimd_f=0;
  $matemd_f=0;
  $qtd_pedid_f=0;
  $qtd_peded_f=0;
  $matimd_e=0;
  $matemd_e=0;
  $qtd_pedid_e=0;
  $qtd_peded_e=0;
  $matimd_p=0;
  $matemd_p=0;
  $qtd_pedid_p=0;
  $qtd_peded_p=0;

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
   $mes_atu=chop($mat_pedido["mesano"]);
   $dia_rel_atu=chop($mat_pedido["dia"]);
   $ano_rel_atu=chop($mat_pedido["ano"]);
   $mes_rel_atu=chop($mat_pedido["mes"]);

   $emp_atu=$mat_pedido["cod_empresa"];
   $rep_atu=$mat_pedido["cod_repres"];
   $cli_atu=$mat_pedido["nom_cliente"];
   $cod_cli_atu=$mat_pedido["cod_cliente"]; 
   $tip_cli_atu=$mat_pedido["cod_tip_cli"]; 
   $local_atu=chop($mat_pedido["local"]);
   $valor=$vlme-$vlmc;
   $valor=round($valor,2);
   if($tip_cli_atu==66)
   {
    $matemd=$matemd+$valor;
    $matetd=$matetd+$valor;

    $matem=$matem+$valor;
    $matet=$matet+$valor;
    $totm=$totm+$valor;
    $tott=$tott+$valor;
    $mateem=$mateem+$valor;
    $mateet=$mateet+$valor;
    $totem=$totem+$valor;
    $totet=$totet+$valor;

    if($ped_ant_1<>$ped_atu_1)
    {
     $qtd_peded=$qtd_peded+1;
     $qtd_pede=$qtd_pede+1;
     $qtd_pedet=$qtd_pedet+1;
     if($local_atu=="FAT")
     {
      $qtd_peded_f=$qtd_peded_f+1;
     }else{
      if($mes_rel_atu<=$mes_ctr and $ano_rel_atu<=$ano_ctr and $dia_rel_atu <= $dia_ctr)
      {
       $qtd_peded_e=$qtd_peded_e+1;
      }else{
       $qtd_peded_p=$qtd_peded_p+1;
      }
     }
    }
    if($local_atu=="FAT")
    {
     $matemd_f=$matemd_f+$valor;
    }else{
     if($mes_rel_atu<=$mes_ctr and $ano_rel_atu<=$ano_ctr and $dia_rel_atu <= $dia_ctr)
     {
      $matemd_e=$matemd_e+$valor;
     }else{
      $matemd_p=$matemd_p+$valor;
     }
    }
   }elseif($tip_cli_atu<>66){
    $matimd=$matimd+$valor;
    $matitd=$matitd+$valor;
    $matim=$matim+$valor;
    $matit=$matit+$valor;
    $totm=$totm+$valor;
    $tott=$tott+$valor;
    $matiem=$matiem+$valor;
    $matiet=$matiet+$valor;
    $totem=$totem+$valor;
    if($ped_ant_1<>$ped_atu_1)
    {
     $qtd_pedid=$qtd_pedid+1;
     $qtd_pedi=$qtd_pedi+1;
     $qtd_pedit=$qtd_pedit+1;
     if($local_atu=="FAT")
     {
      $qtd_pedid_f=$qtd_pedid_f+1;
     }else{
      if($mes_rel_atu<=$mes_ctr and $ano_rel_atu<=$ano_ctr and $dia_rel_atu <= $dia_ctr)
      {
       $qtd_pedid_e=$qtd_pedid_e+1;
      }else{
       $qtd_pedid_p=$qtd_pedid_p+1;
      }
     }
    }
    $totet=$totet+$valor; 
    if($local_atu=="FAT")
    {
     $matimd_f=$matimd_f+$valor;
    }else{
     if($mes_rel_atu<=$mes_ctr and $ano_rel_atu<=$ano_ctr and $dia_rel_atu <= $dia_ctr)
     {
      $matimd_e=$matimd_e+$valor;
     }else{
      $matimd_p=$matimd_p+$valor;
     }
    }
   } 
   $vlme=0;
   $vlmc=0;
   $vlma=0;



   $ped_ant=$mat_pedido["num_pedido"];
   $ped_ant_1=$mat_pedido["ped_emp"];
   $emp_ant=$mat_pedido["cod_empresa"];
   $ped_ant=$mat_pedido["num_pedido"];
   $ped_ant_1=$mat_pedido["ped_emp"];
   $mes_ant=chop($mat_pedido["mesano"]);
   $mesano_ctr_ant=chop($mat_pedido["mes"]).chop($mat_pedido["ano"]);
   $emp_ant=$mat_pedido["cod_empresa"];
   $rep_ant=$mat_pedido["cod_repres"];
   $cli_ant=$mat_pedido["nom_cliente"];
   $tip_cli_ant=$mat_pedido["cod_tip_cli"]; 
   $dia_rel_ant=chop($mat_pedido["dia"]);
   $ano_rel_ant=chop($mat_pedido["ano"]);
   $mes_rel_ant=chop($mat_pedido["mes"]);
   $local_ant=chop($mat_pedido["local"]);
   $mat_pedido=$cfetch_row($result_pedido);
   $dia_rel_atu=chop($mat_pedido["dia"]);
   $ano_rel_atu=chop($mat_pedido["ano"]);
   $mes_rel_atu=chop($mat_pedido["mes"]);
   $ped_atu=$mat_pedido["num_pedido"];
   $ped_atu_1=$mat_pedido["ped_emp"];
   $mes_atu=chop($mat_pedido["mesano"]);
   $emp_atu=$mat_pedido["cod_empresa"];
   $ped_atu=$mat_pedido["num_pedido"];
   $ped_atu_1=$mat_pedido["ped_emp"];
   $mesano_ctr_atu=chop($mat_pedido["mes"]).chop($mat_pedido["ano"]);
   $rep_atu=$mat_pedido["cod_repres"];
   $cli_atu=$mat_pedido["nom_cliente"];
   $tip_cli_atu=$mat_pedido["cod_tip_cli"]; 

   $pdf->SetFillColor(260);
   
   if($det=="S")
   {
    if($dia_rel_ant <> $dia_rel_atu and $mes_rel_ant<=$mes_ctr and $ano_rel_ant<=$ano_ctr and $dia_rel_ant <= $dia_ctr)
    {
     $pdf->ln();
     $pdf->setx(10);
     $pdf->SetFillColor(260);
     $pdf->Cell(40,5,"IMEDIATO"."-".$local_ant,TRB,0,'R',1);
     $pdf->SetFillColor(220);
     $pdf->Cell(25,5,number_format($matimd,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedid,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->Cell(25,5,number_format($matemd,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_peded,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(240);
     $pdf->Cell(25,5,number_format($matimd+$matemd,2,",","."),TRB,0,'R',1); 
     $pdf->Cell(25,5,number_format($qtd_pedid+$qtd_peded,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
     $matimd=0;
     $matemd=0;
     $qtd_pedid=0;
     $qtd_peded=0;
    }elseif($dia_rel_ant <> $dia_rel_atu and $mes_rel_ant==$mes_ctr and $ano_rel_ant==$ano_ctr and $dia_rel_ant > $dia_ctr)
    {
     $pdf->ln();
     $pdf->setx(10);
     $pdf->SetFillColor(260);
     $pdf->Cell(40,5,$dia_rel_ant.'/'.$mes_ant,TRB,0,'R',1);
     $pdf->SetFillColor(220);
     $pdf->Cell(25,5,number_format($matimd,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedid,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->Cell(25,5,number_format($matemd,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_peded,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(240);
     $pdf->Cell(25,5,number_format($matimd+$matemd,2,",","."),TRB,0,'R',1); 
     $pdf->Cell(25,5,number_format($qtd_pedid+$qtd_peded,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
     $matimd=0;
     $matemd=0;
     $qtd_pedid=0;
     $qtd_peded=0;
    }elseif($dia_rel_ant <> $dia_rel_atu and $mes_rel_ant>$mes_ctr and $ano_rel_ant>=$ano_ctr )
    {   
     if($dia_rel_ant <> $dia_rel_atu )
     {
      $pdf->ln();
      $pdf->setx(10);
      $pdf->SetFillColor(260);
      $pdf->Cell(40,5,$dia_rel_ant.'/'.$mes_ant,TRB,0,'R',1);
      $pdf->SetFillColor(220);
      $pdf->Cell(25,5,number_format($matimd,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_pedid,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
      $pdf->Cell(25,5,number_format($matemd,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_peded,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(240);
      $pdf->Cell(25,5,number_format($matimd+$matemd,2,",","."),TRB,0,'R',1); 
      $pdf->Cell(25,5,number_format($qtd_pedid+$qtd_peded,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
      $matimd=0;
      $matemd=0;
      $qtd_pedid=0;
      $qtd_peded=0;
     }
    }
    if($mes_ant<>$mes_atu)
    {
     $pdf->ln();
     $pdf->setx(10);
     $pdf->SetFillColor(260);
     $pdf->Cell(40,5,$mes_ant,TRBL,0,'L',1);
     $pdf->SetFillColor(220);
     $pdf->Cell(25,5,number_format($matim,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedi,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->Cell(25,5,number_format($matem,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pede,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(240);
     $pdf->Cell(25,5,number_format($totm,2,",","."),TRB,0,'R',1); 
     $pdf->Cell(25,5,number_format($qtd_pedi+$qtd_pede,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
     $matim=0;
     $matem=0;
     $jacm=0;
     $spm=0;
     $totm=0;
     $qtd_pedi=0;
     $qtd_pede=0;
    }
   }else{
    if($mes_ant<>$mes_atu)
    {
     if(($matimd_f+$matemd_f+$qtd_pedid_f+$qtd_peded_f) > 0)
     {
      $pdf->ln();
      $pdf->setx(10);
      $pdf->SetFillColor(260);
      $pdf->Cell(40,5,"PRONTO PARA FATURAR",LTRB,0,'R',1);
      $pdf->SetFillColor(220);
      $pdf->Cell(25,5,number_format($matimd_f,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_pedid_f,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
      $pdf->Cell(25,5,number_format($matemd_f,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_peded_f,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(240);
      $pdf->Cell(25,5,number_format($matimd_f+$matemd_f,2,",","."),TRB,0,'R',1); 
      $pdf->Cell(25,5,number_format($qtd_pedid_f+$qtd_peded_f,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
      $matimd_f=0;
      $matemd_f=0;
      $qtd_pedid_f=0;
      $qtd_peded_f=0;
     }
     if(($matimd_e+$matemd_e+$qtd_pedid_e+$qtd_peded_e) > 0)
     {
      $pdf->ln();
      $pdf->setx(10);
      $pdf->SetFillColor(260);
      $pdf->Cell(40,5,"PRONTO PARA EMBALAR",LTRB,0,'R',1);
      $pdf->SetFillColor(220);
      $pdf->Cell(25,5,number_format($matimd_e,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_pedid_e,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
      $pdf->Cell(25,5,number_format($matemd_e,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_peded_e,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(240);
      $pdf->Cell(25,5,number_format($matimd_e+$matemd_e,2,",","."),TRB,0,'R',1); 
      $pdf->Cell(25,5,number_format($qtd_pedid_e+$qtd_peded_e,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
      $matimd_e=0;
      $matemd_e=0;
      $qtd_pedid_e=0;
      $qtd_peded_e=0;
     }
     if(($matimd_p+$matemd_p+$qtd_pedid_p+$qtd_peded_p) > 0)
     {
      $pdf->ln();
      $pdf->setx(10);
      $pdf->SetFillColor(260);
      $pdf->Cell(40,5,"PROGRAM/RETIRADAS",LTRB,0,'R',1);
      $pdf->SetFillColor(220);
      $pdf->Cell(25,5,number_format($matimd_p,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_pedid_p,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
      $pdf->Cell(25,5,number_format($matemd_p,2,",","."),TRB,0,'R',1);
      $pdf->Cell(25,5,number_format($qtd_peded_p,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(240);
      $pdf->Cell(25,5,number_format($matimd_p+$matemd_p,2,",","."),TRB,0,'R',1); 
      $pdf->Cell(25,5,number_format($qtd_pedid_p+$qtd_peded_p,0,",","."),TRB,0,'R',1);
      $pdf->SetFillColor(260);
      $matimd_p=0;
      $matemd_p=0;
      $qtd_pedid_p=0;
      $qtd_peded_p=0;
     }
     $pdf->ln();
     $pdf->setx(10);
     $pdf->SetFillColor(260);
     $pdf->Cell(40,5,$mes_ant,TRBL,0,'L',1);
     $pdf->SetFillColor(220);
     $pdf->Cell(25,5,number_format($matim,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pedi,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
     $pdf->Cell(25,5,number_format($matem,2,",","."),TRB,0,'R',1);
     $pdf->Cell(25,5,number_format($qtd_pede,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(240);
     $pdf->Cell(25,5,number_format($totm,2,",","."),TRB,0,'R',1); 
     $pdf->Cell(25,5,number_format($qtd_pedi+$qtd_pede,0,",","."),TRB,0,'R',1);
     $pdf->SetFillColor(260);
     $matim=0;
     $matem=0;
     $jacm=0;
     $spm=0;
     $totm=0;
     $qtd_pedi=0;
     $qtd_pede=0;
    } 
   } 
  }  

  $pdf->ln();
  $pdf->setx(10); 
  $pdf->SetFillColor(260);
  $pdf->SetFont('Arial','B',10);
  $pdf->Cell(40,5,'Total Geral ',RLBT,0,'L',1);
  $pdf->SetFillColor(220);
  $pdf->Cell(25,5,number_format($matit,2,",","."),RBT,0,'R',1);
  $pdf->Cell(25,5,number_format($qtd_pedit,0,",","."),RBT,0,'R',1);
  $pdf->SetFillColor(260);
  $pdf->Cell(25,5,number_format($matet,2,",","."),RBT,0,'R',1);
  $pdf->Cell(25,5,number_format($qtd_pedet,0,",","."),RBT,0,'R',1);
  $pdf->SetFillColor(240);
  $pdf->Cell(25,5,number_format($tott,2,",","."),RBT,0,'R',1);
  $pdf->Cell(25,5,number_format($qtd_pedet+$qtd_pedit,0,",","."),RBT,0,'R',1);
  $pdf->SetFillColor(260);
  $pdf->ln();
  $matim=0;
  $matem=0;
  $totm=0;
 }
 $pdf->Output('mapa_vendas.pdf',D);
?>