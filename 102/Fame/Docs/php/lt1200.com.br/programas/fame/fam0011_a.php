<?php
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenï¿½o:     Henrique
 //Data manutenï¿½o:24/08/2005
 //Mdulo:         Fame
 //Processo:      Vendas - Gerar RelatÃ³rio e arquivo TXT Controle Saida
 //-----------------------------------------------------------------------------
 $prog="fame/fam0011";
 $versao="1";
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $ped=$pedido;
 $emp=$empresa;
 $vlm=0;
 $vlipi=0;
 $vlfrete=0;
 $vlftreipi=0;
 $frete="0";
 $pc_frete=0;
 $desc1=0;
 $desc2=0;
 
 $transac=" set isolation to dirty read";
 $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_trans = $cquery($transac,$res_trans);
 
 $pedido="SELECT 0 as tipo, count(b.nota_fiscal) as qtd_nff,sum(b.val_nota_fiscal) as val_tot_nff
        from lt1200:lt1200_ctr_emb j,
             empresa a,
             fat_nf_mestre b,
             clientes c,
             cidades f
        where j.cod_empresa='".$empresa."'
          and j.data_saida between '".$dini."' and '".$dfin."' 
	  and a.cod_empresa=j.cod_empresa
	  and b.empresa=j.cod_empresa
          and b.nota_fiscal=j.num_nff
          and b.serie_nota_fiscal=j.ser_nff
          and b.cliente=c.cod_cliente
          and f.cod_cidade=c.cod_cidade 
     union
         SELECT 0 as tipo,count(b.nota_fiscal) as qtd_nff,sum(b.val_nota_fiscal) as val_tot_nff
          from lt1200:lt1200_ctr_emb j,
             empresa a,
             fat_nf_mestre b,
             clientes c,
             cidades f,
             fat_nf_item i,
             item k
        where j.cod_empresa='02'
          and j.data_saida between '".$dini."' and '".$dfin."' 
	  and a.cod_empresa='01'
	  and b.empresa=j.cod_empresa
          and b.nota_fiscal=j.num_nff
          and b.serie_nota_fiscal=j.ser_nff
          and b.cliente=c.cod_cliente
          and f.cod_cidade=c.cod_cidade
          and b.empresa = i.empresa
          and b.trans_nota_fiscal = i.trans_nota_fiscal
          and i.empresa = k.cod_empresa
          and i.item = k.cod_item
          and k.gru_ctr_estoq=22
          group by 1 
        ";
 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($pedido,$res);
 $mat=$cfetch_row($result);
 $qtd_nff=0;
 $val_tot_nff=0;
 while (is_array($mat))
 {
  $qtd_nff=$qtd_nff+$mat["qtd_nff"];
  $val_tot_nff=$val_tot_nff+$mat["val_tot_nff"];
  $mat=$cfetch_row($result);
 }
 $val_tot_nff_pdf=$val_tot_nff;
 $pedido="SELECT a.den_empresa,a.end_empresa,a.den_bairro,a.den_munic,
                a.uni_feder,a.num_telefone,a.num_fax,
                b.finalidade AS ies_finalidade,b.nota_fiscal AS num_nff,b.val_frete_cliente AS val_frete_cli,CAST(b.dat_hor_emissao AS date) AS dat_emissao,
        b1.val_tributo_tot/ DECODE(b1.bc_tributo_tot,0,1) * 100 as pct_icm,b2.bc_tributo_tot as val_tot_base_ipi,b1.bc_tributo_tot AS val_tot_base_icm,
		b.val_mercadoria AS val_tot_mercadoria,b.val_nota_fiscal AS val_tot_nff,
		b2.val_tributo_tot AS val_tot_ipi,b1.val_tributo_tot AS val_tot_icm,		
                c.cod_cliente,c.nom_cliente,c.end_cliente,
                c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                c.num_telefone as fone_cli, c.num_fax as fax_cli,
                c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                f.den_cidade as cidade_cli,
                f.cod_uni_feder as uf_cli,b.tip_frete AS ies_frete,
		j.apolice,j.comp_apolice,
		j.data_saida,j.chapa
        from lt1200:lt1200_ctr_emb j,
             empresa a,
             fat_nf_mestre b,
             fat_mestre_fiscal b1,
             fat_mestre_fiscal b2,
             clientes c,
             cidades f
        where j.cod_empresa='".$empresa."'
          and j.data_saida between '".$dini."' and '".$dfin."' 
	  and a.cod_empresa=j.cod_empresa
	  and b.empresa=j.cod_empresa
          and b.nota_fiscal=j.num_nff
          and b.serie_nota_fiscal=j.ser_nff 
          and b.cliente=c.cod_cliente
          and f.cod_cidade=c.cod_cidade
          AND b1.empresa=b.empresa
		  AND b1.trans_nota_fiscal=b.trans_nota_fiscal
		  AND b1.tributo_benef='ICMS'
		  AND b2.empresa=b.empresa
		  AND b2.trans_nota_fiscal=b.trans_nota_fiscal
		  AND b2.tributo_benef='IPI'
  union
      SELECT a.den_empresa,a.end_empresa,a.den_bairro,a.den_munic,
                a.uni_feder,a.num_telefone,a.num_fax,
                b.finalidade AS ies_finalidade,b.nota_fiscal AS num_nff,b.val_frete_cliente AS val_frete_cli,CAST(b.dat_hor_emissao AS date) AS dat_emissao,
        b1.val_tributo_tot/ DECODE(b1.bc_tributo_tot,0,1) * 100 as pct_icm,b2.bc_tributo_tot as val_tot_base_ipi,b1.bc_tributo_tot AS val_tot_base_icm,
		b.val_mercadoria AS val_tot_mercadoria,b.val_nota_fiscal AS val_tot_nff,
		b2.val_tributo_tot AS val_tot_ipi,b1.val_tributo_tot AS val_tot_icm,	
                c.cod_cliente,c.nom_cliente,c.end_cliente,
                c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                c.num_telefone as fone_cli, c.num_fax as fax_cli,
                c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                f.den_cidade as cidade_cli,
                f.cod_uni_feder as uf_cli,b.tip_frete AS ies_frete,
                j.apolice,j.comp_apolice,
                j.data_saida,j.chapa
        from lt1200:lt1200_ctr_emb j,
             empresa a,
             fat_nf_mestre b,
             fat_mestre_fiscal b1,
             fat_mestre_fiscal b2,
             clientes c,
             cidades f
        where j.cod_empresa='02'
          and j.data_saida between '".$dini."' and '".$dfin."'
          and a.cod_empresa='01'
          and b.empresa=j.cod_empresa
          and b.nota_fiscal=j.num_nff
          and b.serie_nota_fiscal=j.ser_nff
          and b.cliente=c.cod_cliente
          and f.cod_cidade=c.cod_cidade
		  AND b1.empresa=b.empresa
		  AND b1.trans_nota_fiscal=b.trans_nota_fiscal
		  AND b1.tributo_benef='ICMS'
		  AND b2.empresa=b.empresa
		  AND b2.trans_nota_fiscal=b.trans_nota_fiscal
		  AND b2.tributo_benef='IPI'
          ";
 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($pedido,$res);
 $mat=$cfetch_row($result);
 $chapa=$mat["chapa"];
 $val_nff=$mat["val_tot_nff"];
 $apolice=$mat["comp_apolice"].$mat["apolice"];
 $data_saida=$mat["data_saida"];
 $data_saida=substr($data_saida,0,2).substr($data_saida,3,2).substr($data_saida,8,2);
 $style="border-top:.75pt;border-color:#FF9900;border-style:solid;border-bottom:none;border-left:none;border-right:none";
 $nstyle ="border-color:white;border-style:solid;border-bottom:none;border-left:none;border-right:none;border-top:none";
 $pagina=1;
 $linha=1;

 $filename = 'tmp/saida.txt';
 $pula_linha="\n";

 if (is_writable($filename))
 {
  if (!$fp = fopen($filename, 'w+'))
  {
   print "Cannot open file ($filename)";
   exit;
  }
   fwrite($fp, 'ARR5444');
   fwrite($fp, $apolice);
   fwrite($fp, '000000000000');
   fwrite($fp, $data_saida);
   // variavel com tamanho do campo a ser formatado
   $tamanho="00000";
   // tamanho da variavel
   $tc=5;
   // retorna o tamanho utilizado pelo valor a ser impresso
   $qtd_nff=round($qtd_nff);
   $tam=strlen($qtd_nff);
   $tam=($tc-$tam);
   fwrite($fp, substr($tamanho,0,$tam));
   fwrite($fp, $qtd_nff);

   // variavel com tamanho do campo a ser formatado
   $tamanho="0000000000000000";
   // tamanho da variavel
   $tc=16;
   // retorna o tamanho utilizado pelo valor a ser impresso
   $val_tot_nff=round($val_tot_nff*100);
   $tam=strlen($val_tot_nff);
   $tam=($tc-$tam);
   fwrite($fp, substr($tamanho,0,$tam));
   fwrite($fp, $val_tot_nff);
   fwrite($fp, '                             '."\n");

  while (is_array($mat))
  {
   fwrite($fp, 'IRR2199');
   // variavel com tamanho do campo a ser formatado
   $tamanho="          ";
   // tamanho da variavel
   $tc=10;
   // retorna o tamanho utilizado pelo valor a ser impresso
   $num_nff=round($mat["num_nff"]);
   $tam=strlen($num_nff);
   $tam=($tc-$tam);
   fwrite($fp, substr($tamanho,0,$tam));
   fwrite($fp, $num_nff);

   // variavel com tamanho do campo a ser formatado
   $tamanho="        ";
   // tamanho da variavel
   $tc=8;
   // retorna o tamanho utilizado pelo valor a ser impresso
   $chapa=chop($mat["chapa"]);
   $tam=strlen($chapa);
   $tam=($tc-$tam);
   fwrite($fp, substr($tamanho,0,$tam));
   fwrite($fp, $chapa);
   fwrite($fp, $data_saida);
   fwrite($fp, 'SAO PAULO      2599000');

   // variavel com tamanho do campo a ser formatado
   $tamanho="0000000000000000";
   // tamanho da variavel
   $tc=16;
   // retorna o tamanho utilizado pelo valor a ser impresso
   $val_tot_nff=round($mat["val_tot_nff"]*100);
   $tam=strlen($val_tot_nff);
   $tam=($tc-$tam);
   fwrite($fp, substr($tamanho,0,$tam));
   fwrite($fp, $val_tot_nff);
   fwrite($fp,'005000');
   fwrite($fp,'         ');
   fwrite($fp, $pula_linha);
   $mat=$cfetch_row($result);
  }
   fclose($fp);
//   printf("ARQUIVO GERADO EM /usr/local/apache2/htdocs/lt1200.com.br/programas/fame/tmp/saida.txt ");
 } else {
//  print "The file $filename is not writable";
 }




  $dia=date("d");
  $mes=date("m");
  $ano=date("Y");
  include("../../bibliotecas/inicio.inc");
  include("../../bibliotecas/usuario.inc");
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

  $pedido="SELECT a.den_empresa,a.end_empresa,a.den_bairro,a.den_munic,
                a.uni_feder,a.num_telefone,a.num_fax,
                b.finalidade AS ies_finalidade,b.nota_fiscal AS num_nff,b.val_frete_cliente AS val_frete_cli,CAST(b.dat_hor_emissao AS date) AS dat_emissao,
        b1.val_tributo_tot/DECODE(b1.bc_tributo_tot,0,1) * 100 as pct_icm,b2.bc_tributo_tot as val_tot_base_ipi,b1.bc_tributo_tot AS val_tot_base_icm,
		b.val_mercadoria AS val_tot_mercadoria,b.val_nota_fiscal AS val_tot_nff,
		b2.val_tributo_tot AS val_tot_ipi,b1.val_tributo_tot AS val_tot_icm,
                c.cod_cliente,c.nom_cliente,c.end_cliente,
                c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                c.num_telefone as fone_cli, c.num_fax as fax_cli,
                c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                f.den_cidade as cidade_cli,
                f.cod_uni_feder as uf_cli,b.tip_frete AS ies_frete,
		j.apolice,j.comp_apolice,
		j.data_saida,j.chapa
        from lt1200:lt1200_ctr_emb j,
             empresa a,
             fat_nf_mestre b,
             fat_mestre_fiscal b1,
             fat_mestre_fiscal b2,
             clientes c,
             cidades f
        where j.cod_empresa='".$empresa."'
          and j.data_saida between '".$dini."' and '".$dfin."' 
	  and a.cod_empresa=j.cod_empresa
	  and b.empresa=j.cod_empresa
          and b.nota_fiscal=j.num_nff
          and b.serie_nota_fiscal=j.ser_nff 
          and b.cliente=c.cod_cliente
          and f.cod_cidade=c.cod_cidade
          AND b1.empresa=b.empresa
		  AND b1.trans_nota_fiscal=b.trans_nota_fiscal
		  AND b1.tributo_benef='ICMS'
		  AND b2.empresa=b.empresa
		  AND b2.trans_nota_fiscal=b.trans_nota_fiscal
		  AND b2.tributo_benef='IPI'
union 
      SELECT a.den_empresa,a.end_empresa,a.den_bairro,a.den_munic,
                a.uni_feder,a.num_telefone,a.num_fax,
                b.finalidade AS ies_finalidade,b.nota_fiscal AS num_nff,b.val_frete_cliente AS val_frete_cli,CAST(b.dat_hor_emissao AS date) AS dat_emissao,
        b1.val_tributo_tot/ DECODE(b1.bc_tributo_tot,0,1) * 100 as pct_icm,b2.bc_tributo_tot as val_tot_base_ipi,b1.bc_tributo_tot AS val_tot_base_icm,
		b.val_mercadoria AS val_tot_mercadoria,b.val_nota_fiscal AS val_tot_nff,
		b2.val_tributo_tot AS val_tot_ipi,b1.val_tributo_tot AS val_tot_icm,
                c.cod_cliente,c.nom_cliente,c.end_cliente,
                c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                c.num_telefone as fone_cli, c.num_fax as fax_cli,
                c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                f.den_cidade as cidade_cli,
                f.cod_uni_feder as uf_cli,b.tip_frete AS ies_frete,
                j.apolice,j.comp_apolice,
                j.data_saida,j.chapa
        from lt1200:lt1200_ctr_emb j,
             empresa a,
             fat_nf_mestre b,
             fat_mestre_fiscal b1,
             fat_mestre_fiscal b2,
             clientes c,
             cidades f
        where j.cod_empresa='02'
          and j.data_saida between '".$dini."' and '".$dfin."'
          and a.cod_empresa='01'
          and b.empresa=j.cod_empresa
          and b.nota_fiscal=j.num_nff
          and b.serie_nota_fiscal=j.ser_nff
          and b.cliente=c.cod_cliente
          and f.cod_cidade=c.cod_cidade
          AND b1.empresa=b.empresa
		  AND b1.trans_nota_fiscal=b.trans_nota_fiscal
		  AND b1.tributo_benef='ICMS'
		  AND b2.empresa=b.empresa
		  AND b2.trans_nota_fiscal=b.trans_nota_fiscal
		  AND b2.tributo_benef='IPI'
          order by 17,9

          ";
 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($pedido,$res);
 $mat=$cfetch_row($result);
 $val_nff=$mat["val_tot_nff"];
 $apolice=$mat["comp_apolice"].$mat["apolice"];
 $qtd_nff=round($qtd_nff);
 $val_tot_nff=round($val_tot_nff*100);
 $titulo="RELAÇÃO DE NOTAS FISCAIS SEGURADAS NO PERÍODO : ".$dini."  a  ".$dfin;
 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
 $coluna=0;
 $pdf->SetFillColor(0);
 $pdf->SetFont('Arial','B',8);
 $pdf->ln();
 $pdf->cell(75,5,'NUMERO DA APOLICE: '.$apolice,'LRTB',0,'L');
 $pdf->cell(105,5,'QTD NOTAS: '.number_format($qtd_nff,0,",",".").'  VALOR NFF.:'.number_format($val_tot_nff_pdf,2,",","."),'LRTB',0,'L');
 $pdf->ln();
 while (is_array($mat))
 {
  $data_saida=$mat["data_saida"];
  $data_saida=substr($data_saida,0,2).substr($data_saida,3,2).substr($data_saida,8,2);
  $pdf->SetFillColor(0);
  $pdf->SetFont('Arial','B',8);
  $pdf->cell(10,5,'',0,0,'R');
  $pdf->cell(15,5,round($mat["num_nff"]),'LB',0,'L');
  $pdf->cell(15,5,$mat["data_saida"],'LB',0,'C');
  $pdf->cell(20,5,number_format($mat["val_tot_mercadoria"],2,",","."),'LRB',0,'R');
  $coluna=$coluna+1;
  $mat=$cfetch_row($result);
  if($coluna == 3)
  {
   $pdf->ln();
   $coluna=0;
  }
 }
 $pdf->Output('seguro.pdf',true);
?>
