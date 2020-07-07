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
  include("../../bibliotecas/inicio.inc");
  include("../../bibliotecas/usuario.inc");
  include("../../bibliotecas/atu_ped.inc");
  $codigo='todos';
 if($erep=="S")
 {
  $sel_rep="and br.representante ='".$cod_rep."'";
  $sel_rep1="and b.cdrepr='".$cod_rep."'";
 }elseif($erep=="C") {
  if($srepres=="todos")
  {
   $sel_rep="and j.cod_nivel_3='".$cod_rep."'";
   $sel_rep1="and j.cod_nivel_3='".$cod_rep."'";
  }else{
   $sel_rep="and br.representante ='".$srepres."' and j.cod_nivel_4='".$cod_rep."'";
   $sel_rep1="and b.cdrepr='".$srepres."' and j.cod_nivel_4='".$cod_rep."'";
  }    
 }else{
  if($srepres=="todos")
  {
   $sel_rep=" and br.representante > 0";
   $sel_rep1="and b.cdrepr > 0";
  }else{
   if($supervisor=="S")
   {
    $sel_rep="and j.cod_nivel_3='".$srepres."'";
    $sel_rep1="and j.cod_nivel_3='".$srepres."'";
   }else{
    $sel_rep="and br.representante ='".$srepres."'";
    $sel_rep1="and b.cdrepr='".$srepres."'";
   }
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
  $consulta=" 
    SELECT
                  b.nota_fiscal AS num_nff,b.val_mercadoria AS val_tot_mercadoria,CAST(b.dat_hor_emissao AS DATE)  AS dat_emissao,
		          b.sit_nota_fiscal AS ies_situacao,
                  c.cod_cliente,c.nom_cliente,c.end_cliente,
                  c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                  c.num_telefone as fone_cli, c.num_fax as fax_cli,
                  c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                  d.cod_repres,d.raz_social,d.num_telefone as fone_rep,
                  e.pedido AS num_pedido,e.val_liquido_item AS val_liq_item,e.qtd_item,
                  day(g.dat_pedido)||'/'||month(g.dat_pedido)||'/'||year(g.dat_pedido) as dat_pedido,
                  g.num_pedido_repres,
                  h.cod_item,h.den_item,
                  k.cod_repres as cod_supervisor,k.raz_social as raz_supervisor

             from 
                  fat_nf_mestre b,
                  fat_nf_repr br,
                  item h,
                  clientes c,
                  representante d,
                  canal_venda j,
                  representante k,
                  fat_nf_item e,
                  outer pedidos g
             where b.empresa='".$empresa."'
             	   and b.serie_nota_fiscal='1'
                   and e.empresa=b.empresa
                   and CAST(b.dat_hor_emissao AS DATE) between '".$dini."' and '".$dfin."'
                   and b.cliente=c.cod_cliente
                   and h.cod_item=e.item                   
                   AND h.cod_empresa=e.empresa
                   and d.cod_repres=br.representante
                   and j.cod_nivel_4=br.representante
                   and k.cod_repres=j.cod_nivel_3
                   and e.trans_nota_fiscal=b.trans_nota_fiscal
                   and g.num_pedido=e.pedido
                   and g.cod_empresa=e.empresa
                   and b.sit_nota_fiscal ='N'
                   AND br.empresa=b.empresa
                   AND br.trans_nota_fiscal=b.trans_nota_fiscal
                   AND br.seq_representante=1
                   $sel_rep
union
    SELECT
                  b.nota_fiscal AS num_nff,b.val_mercadoria AS val_tot_mercadoria,CAST(b.dat_hor_emissao AS DATE)  AS dat_emissao,
		  		  b.sit_nota_fiscal AS ies_situacao,
                  c.cod_cliente,c.nom_cliente,c.end_cliente,
                  c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                  c.num_telefone as fone_cli, c.num_fax as fax_cli,
                  c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                  d.cod_repres,d.raz_social,d.num_telefone as fone_rep,
                  e.pedido AS num_pedido,e.val_liquido_item AS val_liq_item,e.qtd_item,
                  day(g.dat_pedido)||'/'||month(g.dat_pedido)||'/'||year(g.dat_pedido) as dat_pedido,
                  g.num_pedido_repres,
                  h.cod_item,h.den_item,
                  k.cod_repres as cod_supervisor,k.raz_social as raz_supervisor

             from 
                  fat_nf_mestre b,
                  fat_nf_repr br,
                  item h,
                  clientes c,
                  representante d,
                  canal_venda j,
                  representante k,
                  fat_nf_item e,
                  outer pedidos g
             where b.empresa='".$empresa."'
                   and b.serie_nota_fiscal='1'
                   and e.empresa=b.empresa
                   and CAST(b.dat_hor_emissao AS DATE) between '".$dini."' and '".$dfin."'
                   and b.cliente=c.cod_cliente
                   and h.cod_item=e.item                   
                   AND h.cod_empresa=e.empresa
                   and d.cod_repres=br.representante
                   and j.cod_nivel_3=br.representante
                   and k.cod_repres=j.cod_nivel_3
                   and e.trans_nota_fiscal=b.trans_nota_fiscal
                   and g.num_pedido=e.pedido
                   and g.cod_empresa=e.empresa
                   and b.sit_nota_fiscal ='N'
                   AND br.empresa=b.empresa
                   AND br.trans_nota_fiscal=b.trans_nota_fiscal
                   AND br.seq_representante=1
                   $sel_rep

             order by k.cod_repres,d.cod_repres,b.nota_fiscal,e.pedido,g.num_pedido_repres";
  $res2 = $cconnect("logix",$ifx_user,$ifx_senha);
  $result2 = $cquery($consulta,$res2);
  $mat=$cfetch_row($result2);
  $cab=1;
  $ped_ant="0"; 
  $ped_atu=$mat["num_pedido"]; 
  $nf_ant="0"; 
  $nf_atu=round($mat["num_nff"]); 
  $rep_ant=""; 
  $rep_atu=round($mat["cod_repres"])." - ".$mat["raz_social"];
  $sup_ant=""; 
  $sup_atu=round($mat["cod_supervisor"])." - ".$mat["raz_supervisor"];
  $den_item=chop($mat["den_item"]);
  $cod_item=$mat["cod_item"];
  $titulo="Notas Fiscais Emitidas no período : ".$dini."  a  ".$dfin;
  $titulo_rel='Representante:'.round($mat["cod_repres"]).'-'.chop($mat["raz_social"]);
  $vlme=0;
  $vlmc=0;
  $vlma=0;
  $vlm=0;
  $linha=1;
  $c_ped=0;
  $pdf=new PDF();
  $pdf->Open();
  $pdf->AliasNbPages();
  $cont_rep=0;
  $vlnfr=0;
  $vlnft=0;
  $vlnfc=0;
  while (is_array($mat))
  {
   if($sup_ant.$rep_ant<>$sup_atu.$rep_atu)
   {
    $titulo_sup='Supervisor:'.round($mat["cod_supervisor"]).'-'.chop($mat["raz_supervisor"]);
    $titulo_rel='Representante:'.round($mat["cod_repres"]).'-'.chop($mat["raz_social"]);
    $pdf->AddPage();
   }
   $sit_ant=$mat["ies_situacao"];
   if($mat["ies_situacao"]=="C")
   {
    $sit_ant="CANC";
   }
   //$cfop=$mat["cod_fiscal"];
   $dnf_atu=$mat["dat_emissao"];
   $cli_atu=$mat["nom_cliente"];
   $emp_atu=$mat["cod_empresa"];
   if($nf_ant.$ped_ant<>$nf_atu.$ped_atu)
   {
    $pdf->SetFillColor(0);
    $pdf->SetFont('Arial','B',8);
    $pdf->setx(10);
    $pdf->cell(15,5,round($mat["num_nff"]),'LB',0,'L');
    $pdf->cell(15,5,$mat["dat_emissao"],'LB',0,'C');
    $pdf->cell(20,5,number_format($mat["val_tot_mercadoria"],2,",","."),'LRB',0,'R');
    $pdf->cell(85,5,$mat["nom_cliente"],'LRB',0,'L');
    $pdf->cell(20,5,round($mat["num_pedido"]),'LRB',0,'L');
    $pdf->cell(20,5,round($mat["num_pedido_repres"]),'LRB',0,'L');
    $pdf->cell(20,5,chop($mat["dat_pedido"]),'LRB',0,'R');
    $pdf->ln();
    $c_ped=1;
   } 
   if($nf_ant<>$nf_atu)
   {
    $vlnfr=$vlnfr+$mat["val_tot_mercadoria"];
    $vlnft=$vlnft+$mat["val_tot_mercadoria"];
    $vlnfc=$vlnfc+$mat["val_tot_mercadoria"];
   }

   if($codigo<>"todos")
   {
    $pdf->setx(30);
    $pdf->cell(15,5,$mat["cod_item"],'TRB',0,'C');
    $pdf->cell(50,5,chop($mat["den_item"]),'TRB',0,'R');
    $pdf->cell(25,5,number_format($mat["qtd_item"],2,",","."),'TRB',0,'R');
    $pdf->cell(25,5,number_format($mat["val_liq_item"],2,",","."),'TRB',0,'R');
    $pdf->ln();
   }
   $ped_ant=$mat["num_pedido"];
   $nf_ant=round($mat["num_nff"]);
   $dped_ant=$mat["dat_pedido"];
   $dnf_ant=$mat["dat_emissao"];
   $rep_ant=round($mat["cod_repres"])." - ".$mat["raz_social"];
   $sup_ant=round($mat["cod_supervisor"])." - ".$mat["raz_supervisor"];
   $cod_sup_ant=round($mat["cod_supervisor"]);
   //passa para proximo registro
   $mat=$cfetch_row($result2);
   $ped_atu=$mat["num_pedido"];
   $nf_atu=round($mat["num_nff"]);
   $rep_atu=round($mat["cod_repres"])." - ".$mat["raz_social"];
   $sup_atu=round($mat["cod_supervisor"])." - ".$mat["raz_supervisor"];
   
   if($sup_ant.$rep_ant<>$sup_atu.$rep_atu)
   {
    $pdf->ln();
    $pdf->cell(165,5,"TOTAL REPRESENTANTE :".$rep_ant ,'LRTB',0,'R');
    $pdf->cell(30,5,number_format($vlnfr,2,",","."),'LRTB',0,'R');
    $vlnfr=0;
   }
   if($sup_ant<>$sup_atu)
   {
    $pdf->ln();
    $pdf->ln();
    $pdf->cell(165,5,"TOTAL COORDENADOR :".$sup_ant,0,0,'R');
    $pdf->cell(30,5,number_format($vlnfc,2,",","."),'LRTB',0,'R');
    $vlnfc=0;

   }   
  }
  $pdf->ln();
  $pdf->ln();
  $pdf->cell(165,5,"TOTAL GERAL NOTAS",0,0,'R');
  $pdf->cell(30,5,number_format($vlnft,2,",","."),'LRTB',0,'R');
  $pdf->Output('notas.pdf',true);
?>
