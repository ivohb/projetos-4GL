<?PHP
  //-----------------------------------------------------------------------------
  //Desenvolvedor: Henrique Antonio Conte
  //Manutenção:
  //Data manutenção:21/06/2005
  //Módulo:         SUP
  //Processo:       Notas Fiscais Emitidas
   //Versão:         1.0
  $prog="vdp/vdp0014";
  $versao=1;
  //-----------------------------------------------------------------------------
  $dia=date("d");
  $mes=date("m");
  $ano=date("Y");
  include("../../bibliotecas/inicio.inc");
  include("../../bibliotecas/usuario.inc");
//  include("../../bibliotecas/atu_ped.inc");
  $srepres=round($srepres);
  if($erep=="S")
  {
   $sel_rep="and b.cod_repres='".$cod_rep."'";
  }elseif($erep=="C"){
   if($srepres=="todos")
   {
    $sel_rep="and j.cod_nivel_3='".$cod_rep."'";
   }else{
    $sel_rep="and j.cod_nivel_3='".$cod_rep."' and d.cod_repres='".$srepres."'";
   }    
  }else{
   if($srepres=="todos")
   {
    $sel_rep="and d.cod_repres > 0";
   }else{
    $sel_rep="and d.cod_repres='".$srepres."'";
   }
  }
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
  define('FPDF_FONTPATH','../fpdf151/font/');
  require('../fpdf151/fpdf.php');
  require('../fpdf151/rotation.php');
  include('../../bibliotecas/cabec_fame.inc');
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);

  $consulta="
    SELECT   f.den_cidade,f.cod_uni_feder,sum(b.val_mercadoria) as valor

             from
                  fat_nf_mestre b,
                  clientes c,
                  cidades f
             where b.empresa='".$empresa."'
                   and CAST(b.dat_hor_emissao AS date) BETWEEN '".$dini."' and '".$dfin."'
                   and c.cod_cliente=b.cliente
                   and b.sit_nota_fiscal <> 'C'
                   and f.cod_cidade=c.cod_cidade
              group by 1,2             
               order by 2,1 ";
  $res2 = $cconnect("logix",$ifx_user,$ifx_senha);
  $result2 = $cquery($consulta,$res2);
  $mat_notas=$cfetch_row($result2);
  $cab=1;
  $titulo="Notas Fiscais Emitidas no período : ".$dini."  a  ".$dfin;
  $pdf=new PDF();
  $pdf->Open();
  $pdf->AliasNbPages();
  $pdf->addpage(); 
  while (is_array($mat_notas))
  {
   $pdf->ln();
   $pdf->cell(70,6,$mat_notas["den_cidade"],'LRTB',0,'L');
   $pdf->cell(20,6,$mat_notas["cod_uni_feder"],'LRTB',0,'L');
   $pdf->cell(40,6,number_format($mat_notas["valor"],2,",","."),'LRTB',0,'R');
   $val_tot=$val_tot+$mat_notas["valor"];
   $mat_notas=$cfetch_row($result2);
  }
   $pdf->ln();
   $pdf->cell(90,6,'Total:','LRTB',0,'L');
   $pdf->cell(40,6,number_format($val_tot,2,",","."),'LRTB',0,'R');
   $pdf->ln();
  $pdf->Output('notas.pdf',true);
?>
