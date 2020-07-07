<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenção:     Henrique
 //Data manutenção:24/06/2005
 //Módulo:         SUP
 //Processo:       SUPRIMENTOS - Emissão de Posição de Estoque
 //-----------------------------------------------------------------------------
 $prog="sup/sup0002";
 $versao=1;  
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
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
 if($local<>"TT")
 {
  $sel1="and b.cod_local='".$local."'";
 }else{
  $sel1="";
 } 
 $consulta= "select a.cod_empresa, a.cod_item, a.den_item ,
                           a.cod_unid_med as un,a.ies_ctr_estoque,
                           b.qtd_saldo, b.cod_empresa, b.cod_item,b.cod_local,
                           b,num_lote
                           from item a,
                                estoque_lote b
                           where a.cod_empresa='".$empresa."'
                             AND b.cod_empresa=a.cod_empresa
                             AND b.cod_item=a.cod_item
			     and b.qtd_saldo>0
                             $sel1
                           order by 9,3";

 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($consulta,$res);
 $mat=$cfetch_row($result);
 $titulo="Posição de Estoque Simples";
 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_fame.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
 $linha=0;
 $cod_ant=$mat["cod_item"];
 $cod_atu=$mat["cod_item"];
 $saldo_item=0;
 $un_ant=$mat["un"];
 $un_atu=$mat["un"];
 while (is_array($mat))
 {
  $pdf->SetFillColor(0);
  $pdf->SetFont('Arial','B',8);
  $pdf->setx(10);
  $pdf->cell(15,5,$mat["cod_local"],'LRTB',0,'C');
  $pdf->SetFont('Arial','B',8);
  $pdf->cell(15,5,$mat["cod_item"],'LRTB');
  $pdf->SetFont('Arial','B',8);
  $pdf->cell(115,5,$mat["den_item"],'LRTB');
  $pdf->cell(20,5,$mat["num_lote"],'LRTB');
  $un_atu=chop($un_atu);
  $pdf->SetFont('Arial','B',8);
  $pdf->cell(10,5,$un_atu,'LRTB',0,'C');
  $pdf->cell(20,5,number_format($mat["qtd_saldo"],3,",","."),'LRTB',0,'R');
  $pdf->ln();
  $saldo_item=$saldo_item+$mat["qtd_saldo"];
  $un_ant=$mat["un"];
  $cod_ant=$mat["cod_item"];

  $mat=$cfetch_row($result);
  $un_atu=chop($mat["un"]);
  $cod_atu=$mat["cod_item"];

  if($cod_ant<>$cod_atu)
  {
   $pdf->SetFillColor(220);
   $pdf->SetFont('Arial','B',10);
   $pdf->setx(10);
   $pdf->cell(165,5,"Total do Item ".$cod_ant,'LRTB',0,'C',1);
   $pdf->cell(10,5,$un_ant,'LRTB',0,'C');
   $pdf->cell(20,5,number_format($saldo_item,3,",","."),'LRTB',0,'R',1);
   $saldo_item=0;
   $pdf->ln();
   $pdf->ln();
  }  




 }
 $pdf->Output('est.pdf',true);
?>
