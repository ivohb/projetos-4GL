<?php
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manuten�o:     Henrique
 //Data manuten�o:24/08/2005
 //Mdulo:         Fame
 //Processo:      Vendas - Gerar Relatório e arquivo TXT Controle Saida
 //-----------------------------------------------------------------------------
 $prog="fame/fam00005";
 $versao="1";
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $ped=$pedido;
 $emp=$empresa;
 $funcio="select a.cod_empresa,a.den_empresa,a.num_cgc,a.den_munic,a.end_empresa,
                a.num_telefone,a.cod_cep,a.ins_estadual,a.den_bairro,
		a.uni_feder,a.num_fax

	from	empresa a
	where	a.cod_empresa='".$empresa."'
	";

 $res_cab = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_cab = $cquery($funcio,$res_cab);
 $mat_cab=$cfetch_row($result_cab);

 $cab1=trim($mat_cab[den_empresa]);
 $cab2=trim($mat_cab[end_empresa]).'       Bairro:'.trim($mat_cab[den_bairro]);
 $cab3=$mat_cab[cod_cep].' - '.trim($mat_cab[den_munic]).' - '.trim($mat_cab[uni_feder]);
 $cab4='Fone: '.$mat_cab[num_telefone].'   Fax: '.$mat_cab[num_fax];
 $cab5="C.G.C.  :".$mat_cab[num_cgc]."     Ins.Estadual:".$mat_cab["ins_emp"];
 /*
 $pedido="SELECT a.den_empresa,a.end_empresa,a.den_bairro,a.den_munic,
                a.uni_feder,a.num_telefone,a.num_fax,
                b.ies_finalidade,b.num_nff,b.val_frete_cli,b.dat_emissao,
		b.pct_icm,b.val_tot_base_ipi,b.val_tot_base_icm,
		b.val_tot_mercadoria,b.val_tot_nff,
		b.val_tot_ipi,b.val_tot_icm,
                c.cod_cliente,c.nom_cliente,c.end_cliente,
                c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                c.num_telefone as fone_cli, c.num_fax as fax_cli,
                c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                f.den_cidade as cidade_cli,
                f.cod_uni_feder as uf_cli,b.ies_frete,
		j.apolice,j.comp_apolice,
		j.data_saida,j.chapa,j.seq_entrega,
		k.cpf_moto,k.nome_moto,k.rg_moto,k.fone_moto,
		b.cod_transpor
        from lt1200:lt1200_ctr_emb j,
             empresa a,
             nf_mestre b,
             clientes c,
             cidades f,
	     lt1200:lt1200_motoristas k
        where j.cod_empresa='".$empresa."'
          and j.num_emb='".$num_emb."'
	  and a.cod_empresa=j.cod_empresa
	  and b.cod_empresa=j.cod_empresa
          and b.num_nff=j.num_nff
          and b.cod_cliente=c.cod_cliente
          and f.cod_cidade=c.cod_cidade
	  and k.cpf_moto=j.cpf_moto
  union
        SELECT a.den_empresa,a.end_empresa,a.den_bairro,a.den_munic,
                a.uni_feder,a.num_telefone,a.num_fax,
                b.ies_finalidade,b.num_nff,b.val_frete_cli,b.dat_emissao,
		b.pct_icm,b.val_tot_base_ipi,b.val_tot_base_icm,
		b.val_tot_mercadoria,b.val_tot_nff,
		b.val_tot_ipi,b.val_tot_icm,
                c.cod_cliente,c.nom_cliente,c.end_cliente,
                c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                c.num_telefone as fone_cli, c.num_fax as fax_cli,
                c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                f.den_cidade as cidade_cli,
                f.cod_uni_feder as uf_cli,b.ies_frete,
		j.apolice,j.comp_apolice,
		j.data_saida,j.chapa,j.seq_entrega,
		k.cpf_moto,k.nome_moto,k.rg_moto,k.fone_moto,
		b.cod_transpor
        from lt1200:lt1200_ctr_emb j,
             empresa a,
             nf_mestre_ser b,
             clientes c,
             cidades f,
	     lt1200:lt1200_motoristas k
        where j.cod_empresa='".$empresa."'
          and j.num_emb='".$num_emb."'
	  and a.cod_empresa=j.cod_empresa
	  and b.cod_empresa=j.cod_empresa
          and b.num_nff=j.num_nff
          and b.ser_nff=j.ser_nff
          and b.cod_cliente=c.cod_cliente
          and f.cod_cidade=c.cod_cidade
	  and k.cpf_moto=j.cpf_moto

      order by 36
         ";
 */
 $pedido="SELECT a.den_empresa,a.end_empresa,a.den_bairro,a.den_munic,
                a.uni_feder,a.num_telefone,a.num_fax,
        b.finalidade AS ies_finalidade,b.nota_fiscal AS num_nff,b.val_frete_cliente AS val_frete_cli,CAST(b.dat_hor_emissao AS DATE) AS dat_emissao,
		b1.val_tributo_tot/DECODE(b1.bc_tributo_tot,0,1) * 100 as pct_icm,b2.bc_tributo_tot as val_tot_base_ipi,b1.bc_tributo_tot AS val_tot_base_icm,
		b.val_mercadoria AS val_tot_mercadoria,b.val_nota_fiscal AS val_tot_nff,
		b2.val_tributo_tot AS val_tot_ipi,b1.val_tributo_tot AS val_tot_icm,b.tip_frete AS ies_frete,
                c.cod_cliente,c.nom_cliente,c.end_cliente,
                c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                c.num_telefone as fone_cli, c.num_fax as fax_cli,
                c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                f.den_cidade as cidade_cli,
                f.cod_uni_feder as uf_cli,
		j.apolice,j.comp_apolice,
		j.data_saida,j.chapa,j.seq_entrega,
		k.cpf_moto,k.nome_moto,k.rg_moto,k.fone_moto,
		b.transportadora AS cod_transpor
        from lt1200:lt1200_ctr_emb j,
             empresa a,
             fat_nf_mestre b,
           outer fat_mestre_fiscal b1,
           outer fat_mestre_fiscal b2,
             clientes c,
             cidades f,
	     lt1200:lt1200_motoristas k
        where j.cod_empresa='".$empresa."'
          and j.num_emb='".$num_emb."'
	  and a.cod_empresa=j.cod_empresa
	  and b.empresa=j.cod_empresa
      and b.nota_fiscal=j.num_nff
      and b.serie_nota_fiscal=j.ser_nff
      and b.cliente=c.cod_cliente
      and f.cod_cidade=c.cod_cidade
	  and k.cpf_moto=j.cpf_moto
	  AND b1.empresa=b.empresa
	  AND b1.trans_nota_fiscal=b.trans_nota_fiscal
	  AND b1.tributo_benef='ICMS'
	  AND b2.empresa=b.empresa
	  AND b2.trans_nota_fiscal=b.trans_nota_fiscal
	  AND b2.tributo_benef='IPI' 
	  order by 36
	  ";
 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($pedido,$res);
 $mat=$cfetch_row($result);


 $titulo="Relatorio de Controle de Saida numero: ".$num_emb." de: ".$mat["data_saida"] ;
 define('FPDF_FONTPATH','../fpdf151/font/');
 require('../fpdf151/fpdf.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_fame.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
 $linha=0;
 $pdf->ln();
 $pdf->SetFillColor(0);
 $pdf->SetFont('Arial','B',10);
 $pdf->setx(10);
 $pdf->cell(10,5,'Dados do Veiculo','0',0,'L');
 $pdf->ln();
 $pdf->SetFillColor(0);
 $pdf->SetFont('Arial','B',10);
 $pdf->setx(10);
 $pdf->cell(95,5,'Placa do Caminhao:'.$mat["chapa"],'0',0,'L');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(95,5,'Nome do Motorista:'.chop($mat["nome_moto"]),'0',0,'L');
 $pdf->cell(90,5,'Tel:'.chop($mat["fone_moto"]),'0',0,'L');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(95,5,'R.G. do Motorista:'.chop($mat["rg_moto"]),'0',0,'L');
 $pdf->cell(90,5,'C.P.F.:'.chop($mat["cpf_moto"]),'0',0,'L');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(190,5,'','B',0,'L');



 while (is_array($mat))
 {
  $transpor=chop($mat["cod_transpor"]);
  if($transpor=="060620366000195")
  {
   $transpor="";
  }
  if($transpor=="")
  {
   $entrega="SELECT a.endereco_entrega AS end_entrega,a.bairro_entrega AS den_bairro,
                  b.den_cidade,b.cod_uni_feder

        from 
         logix:fat_nf_mestre x,
         logix:fat_nf_end_entrega a,
	     logix:cidades b
        where x.empresa='".$empresa."'
          AND x.nota_fiscal='".$num_nff."'
          AND a.empresa=x.empresa
          and a.trans_nota_fiscal=x.trans_nota_fiscal
	  and b.cod_cidade=a.cidade_entrega  
           ";
  }else{
   $entrega="SELECT a.end_cliente as end_entrega,a.den_bairro,
                  b.den_cidade,b.cod_uni_feder,a.nom_cliente,a.num_telefone as fone_cli

        from logix:clientes a,
	     logix:cidades b
        where a.cod_class='T'
          and a.cod_cliente='".$transpor."'
	  and b.cod_cidade=a.cod_cidade
           ";
  }
  $res_entrega = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_entrega = $cquery($entrega,$res_entrega);
  $mat_entrega=$cfetch_row($result_entrega);
  $centrega=chop($mat_entrega["end_entrega"]);


  $pdf->ln();
  $pdf->SetFillColor(0);
  $pdf->SetFont('Arial','B',8);
  $pdf->setx(10);

  if($centrega=="")
  {
   $pdf->cell(30,5,'Entrega:'.round($mat["seq_entrega"]),'0',0,'L');
   $pdf->cell(160,5,'Cliente:'.chop($mat["nom_cliente"]),'0',0,'L');
   $pdf->ln();
   $pdf->setx(40);
   $pdf->cell(180,5,'Endereco Entrega:'.chop($mat["end_cliente"]).' - Bairro: '.chop($mat["bairro_cli"]),'0',0,'L');
   $pdf->ln();
   $pdf->setx(40);
   $pdf->cell(90,5,'Cidade Entrega:'.chop($mat["cidade_cli"]),'0',0,'L');
   $pdf->cell(45,5,'UF Entrega:'.chop($mat["uf_cli"]),'0',0,'L');
   $pdf->cell(45,5,'Fone:'.chop($mat["fone_cli"]),'0',0,'L');
  }else{
   $pdf->cell(30,5,'Entrega:'.round($mat["seq_entrega"]),'0',0,'L');
   $pdf->cell(160,5,'Cliente:'.chop($mat_entrega["nom_cliente"]),'0',0,'L');
   $pdf->ln();
   $pdf->setx(40);
   $pdf->cell(180,5,'EnderecoEntrega:'.chop($mat_entrega["end_entrega"]).'-Bairro:'.
         chop($mat_entrega["den_bairro"]),'0',0,'L');
   $pdf->ln();
   $pdf->setx(40);
   $pdf->cell(90,5,'Cidade Entrega:'.chop($mat_entrega["den_cidade"]),'0',0,'L');
   $pdf->cell(45,5,'UF Entrega:'.chop($mat_entrega["cod_uni_feder"]),'0',0,'L');
   $pdf->cell(45,5,'Fone:'.chop($mat_entrega["fone_cli"]),'0',0,'L');
 }
  $pdf->ln();
  $pdf->setx(40);
  $pdf->cell(45,5,'Nota Fiscal:'.round($mat["num_nff"]),'0',0,'L');
  $pdf->cell(45,5,'Valor:'.number_format($mat["val_tot_nff"],3,",","."),'0',0,'L');
  $pdf->ln();
  $pdf->setx(10);
  $pdf->cell(190,5,'','B',0,'L');

  $mat=$cfetch_row($result);
 }
 $pdf->Output('entrega.pdf',true);
?>
