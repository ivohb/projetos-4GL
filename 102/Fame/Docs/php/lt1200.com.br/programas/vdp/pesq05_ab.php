<?
if($prog_c=='G')
{
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $link = $cconnect("lt1200",$ifx_user,$ifx_senha);
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 if($dados=='01')
 {
  $titulo='Titulos Recebidos';
  $d_dados='Pagos';
  $pesq="select  b.dat_pgto-a.dat_vencto_s_desc as  dias,
               '".$data."'-a.dat_vencto_s_desc as vencto_data,
               a.val_bruto,b.val_pago,
               a.dat_vencto_s_desc,b.dat_pgto
           from  logix:docum a,
                 logix:docum_pgto b 
           where a.cod_empresa='01'
              and b.cod_empresa=a.cod_empresa
              and b.num_docum=a.num_docum ";
  $result = $cquery($pesq,$link);
 }elseif($dados=='02')
 {
  $titulo='Titulos a Receber - n�o Vencidos';
  $d_dados='A vencer';
  $pesq="select  b.dat_pgto-a.dat_vencto_s_desc as  dias,
               '".$data."'-a.dat_vencto_s_desc as vencto_data,
               a.val_bruto,b.val_pago,
               a.dat_vencto_s_desc,b.dat_pgto
           from  logix:docum a,
                 outer logix:docum_pgto b 
           where a.cod_empresa='01'
              and b.cod_empresa=a.cod_empresa
              and b.num_docum=a.num_docum
              and '".$data."'-a.dat_vencto_s_desc < 0 ";
  $result = $cquery($pesq,$link);
 }elseif($dados=='03'){
  $titulo='Titulos a Receber - Vencidos';
  $d_dados='Vencidos';
  $pesq="select  b.dat_pgto-a.dat_vencto_s_desc as  dias,
               '".$data."'-a.dat_vencto_s_desc as vencto_data,
               a.val_bruto,b.val_pago,
               a.dat_vencto_s_desc,b.dat_pgto
           from  logix:docum a,
                 outer logix:docum_pgto b 
           where a.cod_empresa='01'
              and b.cod_empresa=a.cod_empresa
              and b.num_docum=a.num_docum
              and '".$data."'-a.dat_vencto_s_desc >0 ";
  $result = $cquery($pesq,$link);
 }else{
  $titulo='Vis�o Geral';
  $d_dados='Vis�o Geral';
  $pesq="select  b.dat_pgto-a.dat_vencto_s_desc as  dias,
               '".$data."'-a.dat_vencto_s_desc as vencto_data,
               a.val_bruto,b.val_pago,
               a.dat_vencto_s_desc,b.dat_pgto
           from  logix:docum a,
                 outer logix:docum_pgto b 
           where a.cod_empresa='01'
              and b.cod_empresa=a.cod_empresa
              and b.num_docum=a.num_docum         ";
  $result = $cquery($pesq,$link);

 } 
 $mat=$cfetch_row($result);
 $c1o=0;
 $c1b=0;
 $c1r=0;
 $c1p=0;
 $c1n=0;
 $c2o=0;
 $c2b=0;
 $c2r=0;
 $c2p=0;
 $c2n=0;
 $c3o=0;
 $c3b=0;
 $c3r=0;
 $c3p=0;
 $c3n=0;
 $mat=$cfetch_row($result);
 while (is_array($mat))
 {
  $dat_pgto=$mat["dat_pgto"];
  $dias=$mat["dias"];
  $vencto_data=$mat["vencto_data"];
  $val_bruto=$mat["val_bruto"];
  $val_pago=round($mat["val_pago"],2);

   // titulos pagos
  
  if($val_pago > 0)
  {
   if($dias > 90){
    $c1p=$c1p+$val_bruto;
   }elseif($dias > 60){
    $c1r=$c1r+$val_bruto;
   }elseif($dias > 30){
    $c1b=$c1b+$val_bruto;
   }else {
    $c1o=$c1o+$val_bruto;
   }
  }else{
   if($vencto_data <=0)
   {
    $vencto_datac=($vencto_data*-1);
    if($vencto_datac > 90){
     $c2p=$c2p+$val_bruto;
    }elseif($vencto_datac > 60){
     $c2r=$c2r+$val_bruto;
    }elseif($vencto_datac > 30){
     $c2b=$c2b+$val_bruto;
    }else {
     $c2o=$c2o+$val_bruto;
    }
   }else{
    if($vencto_data > 90){
     $c3p=$c3p+$val_bruto;
    }elseif($vencto_data > 60){
     $c3r=$c3r+$val_bruto;
    }elseif($vencto_data > 30){
     $c3b=$c3b+$val_bruto;
    }else {
     $c3o=$c3o+$val_bruto;
    }
   }
  } 
  $mat=$cfetch_row($result);
 }
$total1=$c1o+$c1b+$c1r+$c1p;
if($total1 > 0)
{
 $pc1o=(round(($c1o*10000)/$total1)/100);
 $pc1b=(round(($c1b*10000)/$total1)/100);
 $pc1r=(round(($c1r*10000)/$total1)/100);
 $pc1p=(round(($c1p*10000)/$total1)/100);
 $co=$c1o;
 $cb=$c1b;
 $cr=$c1r;
 $cp=$c1p;
}else{
 $pc1o=0;
 $pc1b=0;
 $pc1r=0;
 $pc1p=0;
}
$total2=$c2o+$c2b+$c2r+$c2p;
if($total2 > 0)
{
 $pc2o=(round(($c2o*10000)/$total2)/100);
 $pc2b=(round(($c2b*10000)/$total2)/100);
 $pc2r=(round(($c2r*10000)/$total2)/100);
 $pc2p=(round(($c2p*10000)/$total2)/100);
 $co=$c2o;
 $cb=$c2b;
 $cr=$c2r;
 $cp=$c2p;
}else{
 $pc2o=0;
 $pc2b=0;
 $pc2r=0;
 $pc2p=0;
}
$total3=$c3o+$c3b+$c3r+$c3p;

if($total3 > 0)
{
 $pc3o=(round(($c3o*10000)/$total3)/100);
 $pc3b=(round(($c3b*10000)/$total3)/100);
 $pc3r=(round(($c3r*10000)/$total3)/100);
 $pc3p=(round(($c3p*10000)/$total3)/100);
 $co=$c3o;
 $cb=$c3b;
 $cr=$c3r;
 $cp=$c3p;
}else{
 $pc3o=0;
 $pc3b=0;
 $pc3r=0;
 $pc3p=0;
}
 define('FPDF_FONTPATH','../../fpdf153/font/');
 require('../../fpdf153/mem_image.php');
 require('../../fpdf153/fpdf.php');
 require('../../fpdf153/rotation.php');
 require('../../fpdf153/rounded_rect2.php');
 include('../../fpdf153/phplot.php'); 
 $graph = new PHPlot(640,400);
 //cria um gr�fico com tamanho 640x400 pixels 
 $graph->SetPlotType($tipo);
 $graph->SetFileFormat('jpg');
 $graph->SetLegend('ate 30 dias');
 $graph->SetLegend('30 a 60 dias');
 $graph->SetLegend('60 a 90 dias');
 $graph->SetLegend('> 90 dias');
 //Dados para gerar o grafico 
 if($dados=='00')
 {
  $example_data = array(array('Pagos',$c1o,$c1b,$c1r,$c1p),
                        array('A vencer',$c2o,$c2b,$c2r,$c2p),
                        array('Vencidos',$c3o,$c3b,$c3r,$c3p)   ); 
 }else{
  $example_data = array(array($d_dados,$co,$cb,$cr,$cp)); 
 }               
 $graph->SetDataValues($example_data); 
 $graph->SetPrintImage(false);
 $graph->DrawGraph(); 
 $pdf= new MEM_IMAGE();
 $pdf->AddPage();
 $pdf->SetFillColor(260);
 $pdf->Image('../../imagens/logocpd3.jpg',12,15,76,10);
 $pdf->Cell(100);
 $pdf->SetFont('Arial','B',10);
 $pdf->Cell(170,4,'Contas a Receber',0,0,'L');
 $pdf->Ln();
 $pdf->Ln();
 $pdf->Cell(100);
 $pdf->SetFont('Arial','B',10);
 $pdf->Cell(170,4,' '.trim($titulo),0,0,'L');
 $pdf->SetFont('Arial','B',12);
 $pdf->Cell(93,4,$data,0,0,'R');
 $pdf->SetFont('Arial','B',8);
 $pdf->Ln();
 $pdf->Ln();
 $pdf->GDImage($graph->img,10,40,180);
 $pdf->Ln(125);
 if($dados=='00')
 {
  $pdf->Cell(55,5,'',0,0,'C');
  $pdf->Cell(30,5,'ESCALA','LRTB',0,'C');
  $pdf->Cell(30,5,'PAGOS','LRTB',0,'C');
  $pdf->Cell(30,5,'A VENCER','LRTB',0,'C');
  $pdf->Cell(30,5,'VENCIDOS','LRTB',0,'C');
  $pdf->Ln();
  $pdf->Cell(55,5,'',0,0,'C');
  $pdf->cell(30,5,'ate 30 dias','LRTB',0,'C');
  $pdf->cell(30,5,number_format($c1o,2,",","."),'LRTB',0,'R');
  $pdf->cell(30,5,number_format($c2o,2,",","."),'LRTB',0,'R');
  $pdf->cell(30,5,number_format($c3o,2,",","."),'LRTB',0,'R');
  $pdf->Ln();
  $pdf->Cell(55,5,'',0,0,'C');
  $pdf->cell(30,5,'30 a 60 dias','LRTB',0,'C');
  $pdf->cell(30,5,number_format($c1b,2,",","."),'LRTB',0,'R');
  $pdf->cell(30,5,number_format($c2b,2,",","."),'LRTB',0,'R');
  $pdf->cell(30,5,number_format($c3b,2,",","."),'LRTB',0,'R');
  $pdf->Ln();
  $pdf->Cell(55,5,'',0,0,'C');
  $pdf->cell(30,5,'60 a 90 dias','LRTB',0,'C');
  $pdf->cell(30,5,number_format($c1r,2,",","."),'LRTB',0,'R');
  $pdf->cell(30,5,number_format($c2r,2,",","."),'LRTB',0,'R');
  $pdf->cell(30,5,number_format($c3r,2,",","."),'LRTB',0,'R');
  $pdf->Ln();
  $pdf->Cell(55,5,'',0,0,'C');
  $pdf->cell(30,5,'> 90 dias','LRTB',0,'C');
  $pdf->cell(30,5,number_format($c1p,2,",","."),'LRTB',0,'R');
  $pdf->cell(30,5,number_format($c2p,2,",","."),'LRTB',0,'R');
  $pdf->cell(30,5,number_format($c3p,2,",","."),'LRTB',0,'R');
  $pdf->Ln();
 }else{
  $pdf->Cell(55,5,'',0,0,'C');
  $pdf->Cell(30,5,'ESCALA','LRTB',0,'C');
  $pdf->Cell(30,5,'VALORES','LRTB',0,'C');
  $pdf->Ln();
  $pdf->Cell(55,5,'',0,0,'C');
  $pdf->cell(30,5,'ate 30 dias','LRTB',0,'C');
  $pdf->cell(30,5,number_format($co,2,",","."),'LRTB',0,'R');
  $pdf->Ln();
  $pdf->Cell(55,5,'',0,0,'C');
  $pdf->cell(30,5,'30 a 60 dias','LRTB',0,'C');
  $pdf->cell(30,5,number_format($cb,2,",","."),'LRTB',0,'R');
  $pdf->Ln();
  $pdf->Cell(55,5,'',0,0,'C');
  $pdf->cell(30,5,'60 a 90 dias','LRTB',0,'C');
  $pdf->cell(30,5,number_format($cr,2,",","."),'LRTB',0,'R');
  $pdf->Ln();
  $pdf->Cell(55,5,'',0,0,'C');
  $pdf->cell(30,5,'> 90 dias','LRTB',0,'C');
  $pdf->cell(30,5,number_format($cp,2,",","."),'LRTB',0,'R');
  $pdf->Ln();
 }

 $lista=chop($ifx_user.'.pdf');
 $pdf->Output($lista);
 printf("<SCRIPT LANGUAGE='javascript'>
  <!-- 
   open('$lista','resultado')
 -->
</SCRIPT>");

}
?> 
      