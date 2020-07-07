<?PHP

  //-----------------------------------------------------------------------------
  //Desenvolvedor: Henrique Antonio Conte
  //Manutenção:
  //Data manutenção:21/06/2005
  //Módulo:         SUP
  //Processo:       Notas Fiscais Emitidas
   //Versão:         1.0
  $prog="vdp/vdp0011";
  $versao=1;
  //-----------------------------------------------------------------------------
  $dia=date("d");
  $mes=date("m");
  $ano=date("Y");
  if($erep=="S")
  {
   $sel_rep="and b.cod_repres='".$cod_rep."'";
  }else{
    $sel_rep="";
  }
  if($codigo<>"todos")
  {
   $sel_item="and h.cod_item in (".$codigo.")";
   $desc_item=",h.den_item";
  }else{
   $sel_item="";
   $desc_item=",h.den_item";
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
  $consulta="SELECT a.den_empresa,a.end_empresa,a.den_bairro,a.cod_empresa,
                  a.den_munic,a.uni_feder,a.num_telefone,a.num_fax,
                  b.num_nff,b.val_tot_mercadoria,b.dat_emissao,
		  b.ies_situacao,b.val_tot_nff,b.cod_fiscal,
                  c.cod_cliente,c.nom_cliente,c.end_cliente,
                  c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                  c.num_telefone as fone_cli, c.num_fax as fax_cli,
                  c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                  d.cod_repres,d.raz_social,d.num_telefone as fone_rep,
                  e.num_pedido,e.val_liq_item,e.qtd_item,
                  f.den_cidade as cidade_cli,f.cod_uni_feder as uf_cli,
                  g.dat_pedido,g.num_pedido_repres,
                  h.cod_item,h.den_item,
                  i.cod
             from empresa a,
                  nf_mestre b,
                  item h,
                  clientes c,
                  representante d,
                  nf_item e,
                  cidades f,
                  outer pedidos g,
                  outer vnxeorca i

             where a.cod_empresa='".$empresa."'
		   and b.cod_empresa=a.cod_empresa
                   and e.cod_empresa=a.cod_empresa
                   and b.dat_emissao between '".$dini."' and '".$dfin."'
                   and b.cod_cliente=c.cod_cliente
                   and h.cod_item=e.cod_item                   
                   $sel_item
                   and f.cod_cidade=c.cod_cidade
                   and d.cod_repres=b.cod_repres
                   and e.num_nff=b.num_nff
                   and g.num_pedido=e.num_pedido
                   and g.cod_empresa=e.cod_empresa
                   and b.ies_situacao <> 'C'
                   $sel_rep
                   and i.cdped=e.num_pedido
             order by  b.num_nff,e.num_pedido desc,e.cod_item";
  $res2 = $cconnect("logix",$ifx_user,$ifx_senha);
  $result2 = $cquery($consulta,$res2);
  $mat=$cfetch_row($result2);
  $cab=1;
  $ped_ant="0"; 
  $ped_atu=$mat["num_pedido"]; 
  $nf_ant="0"; 
  $nf_atu=round($mat["num_nff"]); 
  $rep_ant=round($mat["cod_repres"])." - ".$mat["raz_social"]; 
  $rep_atu=round($mat["cod_repres"])." - ".$mat["raz_social"];
  $den_item=chop($mat["den_item"]);
  $cod_item=$mat["cod_item"];
  $titulo="Notas Fiscais Emitidas no período : ".$dini."  a  ".$dfin;
  $titulo_rel="Item".$cod_item."-".$den_item;
  $vlme=0;
  $vlmc=0;
  $vlma=0;
  $vlm=0;
  $linha=1;
  $c_ped=0;
  $pdf=new PDF();
  $pdf->Open();
  $pdf->AliasNbPages();
  $pdf->AddPage();
  while (is_array($mat))
  {
   $sit_ant=$mat["ies_situacao"];
   if($mat["ies_situacao"]=="C")
   {
    $sit_ant="CANC";
   }
   $cfop=$mat["cod_fiscal"];
   $dnf_atu=$mat["dat_emissao"];
   $cli_atu=$mat["nom_cliente"];
   $emp_atu=$mat["cod_empresa"];
   if($nf_ant.$ped_ant<>$nf_atu.$ped_atu)
   {
    $pdf->ln();
    $pdf->SetFillColor(0);
    $pdf->SetFont('Arial','B',8);
    $pdf->setx(10);
    $pdf->cell(15,5,round($mat["num_nff"]),'LB',0,'L');
    $pdf->cell(15,5,$mat["dat_emissao"],'LB',0,'C');
    $pdf->cell(20,5,number_format($mat["val_tot_nff"],2,",","."),'LRB',0,'R');
    $pdf->cell(60,5,$mat["nom_cliente"],'LRB',0,'L');
    $pdf->cell(15,5,round($mat["num_pedido"]),'LRB',0,'L');
    $pdf->cell(15,5,round($mat["cod"]),'LRB',0,'L');
    $vlnf=$mat["val_tot_nff"];
    $vlnft=$vlnft+$vlnf;
    $c_ped=1;
   } 
   if($codigo<>"todos")
   {
    $pdf->ln();
    $pdf->setx(30);
    $pdf->cell(15,5,$mat["cod_item"],'TRB',0,'C');
    $pdf->cell(50,5,chop($mat["den_item"]),'TRB',0,'R');
    $pdf->cell(25,5,number_format($mat["qtd_item"],2,",","."),'TRB',0,'R');
    $pdf->cell(25,5,number_format($mat["val_liq_item"],2,",","."),'TRB',0,'R');
    $pdf->ln();
    $vlmt=($vlmt+$vlm);
    $vlmtr=($vlmtr+$vlm);
    $vlnf=0;
    $vlm=0;
   }
   $ped_ant=$mat["num_pedido"];
   $nf_ant=round($mat["num_nff"]);
   $dped_ant=$mat["dat_pedido"];
   $dnf_ant=$mat["dat_emissao"];
   //passa para proximo registro
   $mat=$cfetch_row($result2);
   $ped_atu=$mat["num_pedido"];
   $nf_atu=round($mat["num_nff"]);
  }
  $pdf->ln();
  $pdf->cell(50,5,"TOTAL NOTAS",'LRTB',0,'C');
  $pdf->cell(30,5,number_format($vlnft,2,",","."),'LRTB',0,'R');
  $pdf->Output('notas.pdf',true);
?>
