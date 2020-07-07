<?PHP
  //-----------------------------------------------------------------------------
  //Desenvolvedor: Henrique Antonio Conte
  //Manutenção:
  //Data manutenção:21/06/2005
  //Módulo:         SUP
  //Processo:       Notas Fiscais Emitidas
   //Versão:         1.0
  $prog="vdp/vdp0013";
  $versao=1;
  //-----------------------------------------------------------------------------
  $dia=date("d");
  $mes=date("m");
  $ano=date("Y");
  include("../../bibliotecas/inicio.inc");
  include("../../bibliotecas/usuario.inc");
  
  $res=$cconnect("logix",$ifx_user,$ifx_senha);
  $cquery("SET ISOLATION TO DIRTY READ;",$res);
  
  include("../../bibliotecas/atu_ped.inc");
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
  require('../fpdf151/fpdf_paisagem.php');
  require('../fpdf151/rotation.php');
  include('../../bibliotecas/cabec_fame.inc');
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);

  $consulta="
    SELECT
                  b.trans_nota_fiscal,b.nota_fiscal AS num_nff,b.val_mercadoria AS val_tot_mercadoria,b.val_nota_fiscal AS val_tot_nff,b.val_desc_nf,b.val_acre_nf,
                  CAST(b.dat_hor_emissao AS DATE) AS dat_emissao,b.sit_nota_fiscal AS ies_situacao,
                  c.cod_cliente,c.nom_reduzido as nom_cliente,c.end_cliente,
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
                  outer representante k,
                  fat_nf_item e,
                  outer pedidos g
             where b.empresa='".$empresa."'
                   and b.serie_nota_fiscal='1'
                   and e.empresa=b.empresa
                   and CAST(b.dat_hor_emissao AS DATE) BETWEEN '".$dini."' and '".$dfin."'
                   and b.cliente=c.cod_cliente
                   AND h.cod_empresa=b.empresa
                   and h.cod_item=e.item
                   and d.cod_repres=br.representante
                   and j.cod_nivel_4=br.representante
                   and k.cod_repres=j.cod_nivel_3
                   and e.trans_nota_fiscal=b.trans_nota_fiscal
                   and g.num_pedido=e.pedido
                   and g.cod_empresa=e.empresa
                   AND br.empresa=b.empresa
                   AND br.trans_nota_fiscal=b.trans_nota_fiscal
                   AND br.seq_representante=1
union
    SELECT
                  b.trans_nota_fiscal,b.nota_fiscal AS num_nff,b.val_mercadoria AS val_tot_mercadoria,b.val_nota_fiscal AS val_tot_nff,b.val_desc_nf,b.val_acre_nf,
				  CAST(b.dat_hor_emissao AS DATE) AS dat_emissao,b.sit_nota_fiscal AS ies_situacao,	
                  c.cod_cliente,c.nom_reduzido as nom_cliente,c.end_cliente,
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
                   and CAST(b.dat_hor_emissao AS DATE) BETWEEN '".$dini."' and '".$dfin."'
                   and b.cliente=c.cod_cliente
                   AND h.cod_empresa=b.empresa
                   and h.cod_item=e.item
                   and d.cod_repres=br.representante
                   and j.cod_nivel_3=br.representante
                   and j.cod_nivel_4=0
                   and k.cod_repres=j.cod_nivel_3
                   and e.trans_nota_fiscal=b.trans_nota_fiscal
                   and g.num_pedido=e.pedido
                   and g.cod_empresa=e.empresa
                   AND br.empresa=b.empresa
                   AND br.trans_nota_fiscal=b.trans_nota_fiscal
                   AND br.seq_representante=1
             order by b.sit_nota_fiscal,b.nota_fiscal  ";
  $res2 = $cconnect("logix",$ifx_user,$ifx_senha);
  $result2 = $cquery($consulta,$res2);
  $mat_notas=$cfetch_row($result2);
  $cab=1;
  $titulo="Notas Fiscais Emitidas no período : ".$dini."  a  ".$dfin;
  $pdf=new PDF();
  $pdf->Open();
  $pdf->AliasNbPages();
  $pdf->addpage(); 
  $sit_ant="";
  $sit_atu=$mat_notas["ies_situacao"];
  $nf_ant="";
  $nf_atu=$mat_notas["num_nff"];
  $vlnfmerc=0;
  $vlnficm=0;
  $vlnfret=0;
  $vlnfipi=0;
  $vlnfdesc=0;
  $vlnfacre=0;
  $vlnftot=0;
  while (is_array($mat_notas))
  {

   if($sit_ant<>$sit_atu)
   {
    if($sit_atu=="C")
    {
     $pdf->ln();
     $pdf->ln();
     $pdf->SetFillColor(0);
     $pdf->SetFont('Arial','B',12);
     $pdf->setx(10);
     $pdf->cell(275,5,"CANCELADAS",'LRTB',0,'C');
    }else{
     $pdf->ln();
     $pdf->ln();
     $pdf->SetFillColor(0);
     $pdf->SetFont('Arial','B',12);
     $pdf->setx(10);
     $pdf->cell(275,5,"EMITIDAS",'LRTB',0,'C');
    }
   }
   if($nf_ant<>$nf_atu)
   {/*
     * 24/08/2010 - Marcelo Peres
     * Busco os totais dos impostos e os CFOPs que existam na NF
     */
   	$cod_fiscal=array();
   	$val_tot_icm=0;
   	$val_tot_icm_ret=0;
   	$val_tot_ipi=0;
   	$val_acre_nf=0;
   	
   	$res_fiscal=$cquery("SELECT DISTINCT cod_fiscal,tributo_benef,sum(val_tributo_tot) as val_tributo_tot 
   						 FROM fat_nf_item_fisc 
						 WHERE empresa='".$empresa."' 
						 AND trans_nota_fiscal=".$mat_notas["trans_nota_fiscal"]."
						 AND trim(tributo_benef) IN ('ICMS','ICMS_ST','IPI')
						 GROUP BY cod_fiscal,tributo_benef",
   	                    $cconnect("logix",$ifx_user,$ifx_senha));
   	                    
	$mat_fiscal=$cfetch_row($res_fiscal);
	   	                    
   	while(is_array($mat_fiscal))
   		{
   		$cod_fiscal[]=$mat_fiscal["cod_fiscal"];
   		
		switch(trim($mat_fiscal["tributo_benef"]))
			{
			case "ICMS":
				$val_tot_icm = $val_tot_icm + $mat_fiscal["val_tributo_tot"];
				break;
			case "ICMS_ST":
				$val_tot_icm_ret = $val_tot_icm_ret + $mat_fiscal["val_tributo_tot"];
				break; 
			case "IPI":
				$val_tot_ipi = $val_tot_ipi + $mat_fiscal["val_tributo_tot"];
				break;	
			}
   		
   		$mat_fiscal=$cfetch_row($res_fiscal);	
   		}
   	//Evito valores negativos
   	$val_acre_nf = ($mat_notas["val_acre_nf"] - $val_tot_icm_ret - $val_tot_ipi);
   	if($val_acre_nf < 0)
   		$val_acre_nf = 0;
   	
    $pdf->ln();
    $pdf->SetFillColor(0);
    $pdf->SetFont('Arial','B',8);
    $pdf->setx(10);
    $pdf->cell(15,5,round($nf_atu),'LB',0,'L');
    $pdf->cell(15,5,$mat_notas["dat_emissao"],'LB',0,'C');
    $pdf->cell(28,5,implode(",",array_unique($cod_fiscal)),'LB',0,'C');
    $pdf->cell(18,5,number_format($mat_notas["val_tot_mercadoria"],2,",","."),'LRB',0,'R');
    $pdf->cell(16,5,number_format($val_tot_icm,2,",","."),'LRB',0,'R');
    $pdf->cell(16,5,number_format($val_tot_icm_ret,2,",","."),'LRB',0,'R');
    $pdf->cell(16,5,number_format($val_tot_ipi,2,",","."),'LRB',0,'R');
    $pdf->cell(16,5,number_format($mat_notas["val_desc_nf"],2,",","."),'LRB',0,'R');
    $pdf->cell(16,5,number_format($val_acre_nf,2,",","."),'LRB',0,'R');
    $pdf->cell(20,5,number_format($mat_notas["val_tot_nff"],2,",","."),'LRB',0,'R');
    $pdf->cell(54,5,$mat_notas["nom_cliente"],'LRB',0,'L');
    $pdf->cell(15,5,round($mat_notas["num_pedido"]),'LRB',0,'L');
    $pdf->cell(15,5,round($mat_notas["num_pedido_repres"]),'LRB',0,'L');
    $pdf->cell(15,5,chop($mat_notas["dat_pedido"]),'LRB',0,'R');
    $vlnfmerc=$vlnfmerc+$mat_notas["val_tot_mercadoria"];
    $vlnficm=$vlnficm+$val_tot_icm;
    $vlnfret=$vlnfret+$val_tot_icm_ret;
    $vlnfipi=$vlnfipi+$val_tot_ipi;
    $vlnfdesc=$vlnfdesc+$mat_notas["val_desc_nf"];
    $vlnfacre=$vlnfacre+$val_acre_nf;
    $vlnftot=$vlnftot+$mat_notas["val_tot_nff"];
   }   
   $nf_ant=$mat_notas["num_nff"];
   $sit_ant=$mat_notas["ies_situacao"];
   $mat_notas=$cfetch_row($result2);
   $nf_atu=$mat_notas["num_nff"];
   $sit_atu=$mat_notas["ies_situacao"];
   if($sit_ant<>$sit_atu)
   {
    if($sit_ant=="C")
    {
     $pdf->ln();
     $pdf->SetFillColor(0);
     $pdf->SetFont('Arial','B',8);
     $pdf->setx(10);
     $pdf->cell(58,6,'TOTAL CANCELADAS','LB',0,'L');
    }else{
     $pdf->ln();
     $pdf->SetFillColor(0);
     $pdf->SetFont('Arial','B',8);
     $pdf->setx(10);
     $pdf->cell(58,6,'TOTAL EMITIDAS','LB',0,'L');
    }
    $pdf->cell(18,6,number_format($vlnfmerc,2,",","."),'LRB',0,'R');
    $pdf->cell(16,6,number_format($vlnficm,2,",","."),'LRB',0,'R');
    $pdf->cell(16,6,number_format($vlnfret,2,",","."),'LRB',0,'R');
    $pdf->cell(16,6,number_format($vlnfipi,2,",","."),'LRB',0,'R');
    $pdf->cell(16,6,number_format($vlnfdesc,2,",","."),'LRB',0,'R');
    $pdf->cell(16,6,number_format($vlnfacre,2,",","."),'LRB',0,'R');
    $pdf->cell(20,6,number_format($vlnftot,2,",","."),'LRB',0,'R');
    $pdf->ln();
    $vlnfmerc=0;
    $vlnficm=0;
    $vlnfret=0;
    $vlnfipi=0;
    $vlnfdesc=0;
    $vlnfacre=0;
    $vlnftot=0;
   }


  }
  $pdf->Output('notas.pdf',true);
?>
