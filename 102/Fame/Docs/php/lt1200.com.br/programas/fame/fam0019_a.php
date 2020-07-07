<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenï¿½o:     Henrique
 //Data manutenï¿½o30/08/2005
 //Mdulo:        Fame
 //Processo:     Relação cliente com Direito a Relogio
 //-----------------------------------------------------------------------------
 $prog="fame/fam0018";
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
 $empresa="01";
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

 $titulo="CLIENTES COM DIREITO A RELOGIO   PROCESSAMENTO:".$num_proc ;
 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf1.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_etiq.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
 $processos="and a.num_proc=".$proc;
 $selec_promo="select a.num_proc,a.num_om,a.num_nff,a.num_pedido,a.nducha,a.ducha,
                      b.nom_cliente,b.end_cliente,b.den_bairro,b.cod_cep,
                      c.den_cidade,c.cod_uni_feder,
                      b.num_cgc_cpf
                 from lt1200:lt1200_cli_prom a, clientes b,cidades c
                   where b.cod_cliente=a.cod_cliente
                   $processos
                   and c.cod_cidade=b.cod_cidade
                 order by 1,2";

  $res_promo = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_promo = $cquery($selec_promo,$res_promo);
  $mat_promo=$cfetch_row($result_promo);
  while (is_array($mat_promo))
  {
    $pdf->SetFont('Arial','B',10);
    $pdf->setx(20);
    $pdf->Cell(60,6,'Ordem: '.round($mat_promo["num_om"]),0,0,'L');
    $pdf->Cell(60,6,'Pedido: '.round($mat_promo["num_pedido"]),0,0,'L');
    $pdf->ln();
    $pdf->setx(20);
    $pdf->Cell(120,6,'Cliente:'.$mat_promo["nom_cliente"],0,0,'L');
    $pdf->ln();
    $pdf->setx(20);
    $pdf->Cell(120,6,'Endereço:'.chop($mat_promo["end_cliente"]).'-'.chop($mat_promo["den_bairro"]),0,0,'L');
    $pdf->ln();
    $pdf->setx(20);
    $pdf->Cell(120,5,'CEP:'.chop($mat_promo["cod_cep"]).'-'.chop($mat_promo["den_cidade"]).'-'.chop($mat_promo["cod_uni_feder"]),0,0,'L');
    $pdf->ln();
    $pdf->ln();
    $pdf->ln();
    $pdf->setx(20);
    $pdf->Cell(60,5,'Ordem: '.round($mat_promo["num_om"]),0,0,'L');
    $pdf->Cell(60,5,'Pedido: '.round($mat_promo["num_pedido"]),0,0,'L');
    $pdf->ln();
    $pdf->setx(20);
    $pdf->Cell(120,6,'C.G.C.: '.chop($mat_promo["num_cgc_cpf"]),0,0,'L');
    $pdf->ln();
    $pdf->setx(20);
    $pdf->Cell(120,6,'Cliente:'.$mat_promo["nom_cliente"],0,0,'L');
    $pdf->ln();
    $pdf->setx(20);
    $pdf->Settextcolor('250','0','0');
    $pdf->cell(120,6,'BRINDE :RELÓGIO DE PAREDE','',0,'C');
    $pdf->Settextcolor('0','0','0');
    $pdf->ln();
    $pdf->setx(20);
    $pdf->Cell(120,5,'',0,0,'L');
    $pdf->ln();
    $pdf->ln();
    $pdf->ln();
    $pdf->ln();

 $mat_promo=$cfetch_row($result_promo);
 }
 $lista='../../rels/'.chop($ifx_user).'.pdf';
 $pdf->Output($lista);
 printf("<SCRIPT LANGUAGE='javascript'>
  <!-- 
   window.open('$lista','nova')
   window.close('nova')

 -->
</SCRIPT>");


?>
