<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenção:     Henrique
 //Data manutenção:21/06/2005
 //Módulo:         VDP
 //Processo:       Vendas - Emissão Espelho Nota Fiscal
 //-----------------------------------------------------------------------------
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
                (g.cod_nat_oper||' - '||g.den_nat_oper) as oper,(h.cod_cnd_pgto||' - '||den_cnd_pgto) as pgto,
                d.cod_repres,d.raz_social,d.num_telefone as fone_rep,
                i.ies_incid_ipi
        from empresa a,
             nf_mestre b,
             clientes c,
             representante d,
             cidades f,
             nat_operacao g,
             cond_pgto h,
             fiscal_par i
        where a.cod_empresa='".$empresa."'
          and b.cod_empresa=a.cod_empresa
          and b.num_nff='".$nff_."'
          and b.cod_repres=d.cod_repres
          and b.cod_cliente=c.cod_cliente
          and f.cod_cidade=c.cod_cidade
          and g.cod_nat_oper=b.cod_nat_oper
          and h.cod_cnd_pgto=b.cod_cnd_pgto
          and i.cod_nat_oper=g.cod_nat_oper
          and i.cod_empresa=a.cod_empresa
          and i.cod_uni_feder=f.cod_uni_feder
           ";
 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($pedido,$res);
 $mat=$cfetch_row($result);
 $cab1=$mat["den_empresa"];
 $cab3=$mat["den_bairro"];
 $cab4=$mat["den_munic"];
 $cab5=$mat["uni_feder"];
 $cab6=$mat["num_telefone"];
 $cab7=$mat["num_fax"];
 $cab0=$mat["num_nff"];
 $incid_ipi=$mat["ies_incid_ipi"];
 $fin=$mat["ies_finalidade"];
 $pgto=$mat["pgto"];
 $oper=$mat["oper"];
 $dat=$mat["dat_emissao"];
 $desc1=$mat["pct_desc_financ"];
 $desc2=$mat["pct_desc_adic"]; 
 $frete=substr($mat["ies_frete"],0,1);
 $pcfrete=$mat["pct_frete"];
 $val_frete=$mat["val_frete_cli"];
 $val_base_icm=$mat["val_tot_base_icm"];
 $val_base_ipi=$mat["val_tot_base_ipi"];
 $val_icm=$mat["val_tot_icm"];
 $val_ipi=$mat["val_tot_ipi"];
 $val_merc=$mat["val_tot_mercadoria"];
 $val_nff=$mat["val_tot_nff"];
 $style="border-top:.75pt;border-color:#FF9900;border-style:solid;border-bottom:none;border-left:none;border-right:none";
 $nstyle ="border-color:white;border-style:solid;border-bottom:none;border-left:none;border-right:none;border-top:none";
 $pagina=1;
 $linha=1;

 $filename = 'tmp/teste.txt';
 $pula_linha="\n";

 if (is_writable($filename)) 
 {
  if (!$fp = fopen($filename, 'w+')) 
  {
   print "Cannot open file ($filename)";
   exit;
  }
  fwrite($fp, '123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012'."\n");
  while (is_array($mat))
  {
   fwrite($fp, 'REPRESENTANTE: '.round($mat["cod_repres"]).'-'.$mat["raz_social"]);
   fwrite($fp, 'Fone  :'.$mat["fone_rep"]);
   fwrite($fp, 'Num Pedido :'.$mat["num_pedido_repres"]);
   fwrite($fp, $pula_linha);
   fwrite($fp,'CLIENTE' );
   fwrite($fp, $pula_linha);
   fwrite($fp, 'CODIGO:'.$mat["cod_cliente"]);
   fwrite($fp, 'Nome:'.$mat["nom_cliente"]);
   fwrite($fp, $pula_linha);
   fwrite($fp, 'Cidade:'.$mat["cidade_cli"]);
   fwrite($fp, 'UF:'.$mat["uf_cli"]);
   fwrite($fp, 'Fone:'.$mat["fone_cli"]);
   fwrite($fp, 'Fax:'.$mat["fax_cli"]);
   fwrite($fp, $pula_linha);
   fwrite($fp, 'Endereço:'.$mat["end_cliente"]);
   fwrite($fp, 'Bairro:'.$mat["bairro_cli"]);
   fwrite($fp, 'CEP:'.$mat["cep_cli"]);
   fwrite($fp, $pula_linha);
   fwrite($fp, 'CNPJ:'.$mat["num_cgc_cpf"]);
   fwrite($fp, 'Insc.Esta.:'.$mat["ins_estadual"]);
   fwrite($fp, 'Contato:'.$mat["nom_contato"]);
   fwrite($fp, $pula_linha);
   include("../../bibliotecas/frete_finalidade.inc");
   $mat=$cfetch_row($result);
  }
  $pedi="SELECT max(num_pedido) as num_pedido
             from  nf_item
           where  cod_empresa='".$emp."' and num_nff='".$nff_."' 
                  ";
  $resi = $cconnect("logix",$ifx_user,$ifx_senha);
  $resui = $cquery($pedi,$resi);
  $mat=$cfetch_row($resui);
  $pedi=$mat["num_pedido"];
  $pedido1="SELECT  a.den_bairro, a.end_entrega, a.num_cgc, a.cod_cep, a.ins_estadual,
                  b.den_cidade, b.cod_uni_feder
            from  ped_end_ent a, cidades b
           where  a.cod_empresa='".$emp."' and a.num_pedido='".$pedi."' 
                  and b.cod_cidade=a.cod_cidade ";
  $res1 = $cconnect("logix",$ifx_user,$ifx_senha);
  $result1 = $cquery($pedido1,$res1);
  $mat=$cfetch_row($result1);
  while (is_array($mat))
  {
   fwrite($fp, 'LOCAL DA ENTREGA');
   fwrite($fp, $pula_linha);
   fwrite($fp, 'Cidade:'.$mat["den_cidade"]);
   fwrite($fp, 'UF:'.$mat["cod_uni_feder"]);
   fwrite($fp, $pula_linha);
   fwrite($fp, 'Endereço:'.$mat["end_entrega"]);
   fwrite($fp, 'Bairro:'.$mat["den_bairro"]);
   fwrite($fp, 'CEP.:'.$mat["cod_cep"]);
   fwrite($fp, 'Bairro:'.$mat["den_bairro"]);
   fwrite($fp, $pula_linha);
   fwrite($fp, 'CNPJ.:'.$mat["num_cgc"]);
   fwrite($fp, 'Insc.Est.:'.$mat["ins_estadual"]);
   fwrite($fp, 'CEP.:'.$mat["cod_cep"]);
   fwrite($fp, 'Bairro:'.$mat["den_bairro"]);
   fwrite($fp, $pula_linha);
   $mat=$cfetch_row($result1);
  }
  $pedido11="SELECT  a.den_bairro, a.end_cobr, a.cod_cep, 
                   b.den_cidade, b.cod_uni_feder
             from  cli_end_cob a, cidades b, nf_mestre c 
	    where  c.cod_empresa='".$emp."' and c.num_nff='".$nff_."'
                   and b.cod_cidade=a.cod_cidade_cob 
                   and a.cod_cliente=c.cod_cliente ";
  $res11 = $cconnect("logix",$ifx_user,$ifx_senha);
  $result11 = $cquery($pedido11,$res11);
  $mat=$cfetch_row($result11);
  while (is_array($mat))
  {
   fwrite($fp, 'LOCAL DA COBRANÇA');
   fwrite($fp, $pula_linha);
   fwrite($fp, 'Cidade:'.$mat["den_cidade"]);
   fwrite($fp, 'UF:'.$mat["cod_uni_feder"]);
   fwrite($fp, $pula_linha);
   fwrite($fp, 'Endereço:'.$mat["end_entrega"]);
   fwrite($fp, 'Bairro:'.$mat["den_bairro"]);
   fwrite($fp, 'CEP.:'.$mat["cod_cep"]);
   fwrite($fp, $pula_linha);
   $mat=$cfetch_row($result11);
  }
  $pedido3="SELECT c.den_texto_1,c.den_texto_2,c.den_texto_3,
                 c.den_texto_4,c.den_texto_5 
            from ped_itens_texto c 
           where c.cod_empresa='".$emp."' 
                 and c.num_pedido='".$pedi."'
                 and c.num_sequencia='0'  ";
  $res3 = $cconnect("logix",$ifx_user,$ifx_senha);
  $result3 = $cquery($pedido3,$res3);
  $mat=$cfetch_row($result3);
  while (is_array($mat))
  {
   fwrite($fp,'OBSERVAÇOES PEDIDO' );
   fwrite($fp, $pula_linha);
   fwrite($fp, $mat["den_texto_1"]);
   if(substr($mat["den_texto_1"],1,1) <>"")
   {
    fwrite($fp, $mat["den_texto_1"]);
   fwrite($fp, $pula_linha);
   }
   if(substr($mat["den_texto_2"],1,1) <>"")
   {
    fwrite($fp, $mat["den_texto_2"]);
    fwrite($fp, $pula_linha);
   }
   if(substr($mat["den_texto_3"],1,1) <>"")
   {
    fwrite($fp, $mat["den_texto_3"]);
    fwrite($fp, $pula_linha);
   }
   if(substr($mat["den_texto_4"],1,1) <>"")
   {
    fwrite($fp, $mat["den_texto_4"]);
    fwrite($fp, $pula_linha);
   }
   if(substr($mat["den_texto_5"],1,1) <>"")
   {
    fwrite($fp, $mat["den_texto_5"]);
    fwrite($fp, $pula_linha);
   }
   $mat=$cfetch_row($result3);
  }
  fwrite($fp,'INFORMAÇÃO DO FATURAMENTO' );
  fwrite($fp, $pula_linha);
  fwrite($fp, 'Condiçoes de Pagamento:'.$pgto);
  fwrite($fp, $pula_linha);
  fwrite($fp, 'Natut.Operação:'.$oper);
  fwrite($fp, 'Finalidade:'.$textofin);
  fwrite($fp, $pula_linha);
  fwrite($fp, 'Frete.::'.$frete.$textof.$moeda);
  if($frete=="0")
  {
   $pcfrete=number_format($val_frete,2,",",".");
  }
  fwrite($fp, $pcfrete.$pe);
  $pedd="SELECT  *
            from  wfat_duplic
           where  cod_empresa='".$emp."'
                  and num_nff='".$nff_."'
		order by dig_duplicata";
  $resd = $cconnect("logix",$ifx_user,$ifx_senha);
  $resdd = $cquery($pedd,$resd);
  $mat=$cfetch_row($resdd);
  $cabd=1;
  while (is_array($mat))
  {
   if($cabd==1)
   {
    fwrite($fp, $pula_linha);
    fwrite($fp, 'PAGAMENTOS');
    fwrite($fp, $pula_linha);
    fwrite($fp, 'Vencimento');
    fwrite($fp, 'Valor R$');
    fwrite($fp, 'Vencimento');
    fwrite($fp, 'Valor R$');
    fwrite($fp, 'Vencimento');
    fwrite($fp, 'Valor R$');
    fwrite($fp, $pula_linha);
    $cabd=3;
    $eti=3;
   }
   if($eti==3)
   {
    $eti1=0;
    $eti=0;
   }
   if($eti1==0)
   {
    fwrite($fp, $pula_linha);
   }
   fwrite($fp,number_format($mat["dig_duplicata"],0,",",".")." - ". $mat["dat_vencto_sd"] );
   fwrite($fp,number_format($mat["val_duplic"],2,",",".") );
   $eti=$eti+1;
   $eti1=$eti1+1;
   if($eti1==0)
   {
    fwrite($fp, $pula_linha);
   }
   $mat=$cfetch_row($resdd);
  }
  $pedido2="SELECT distinct a.num_sequencia,a.cod_item,a.num_pedido,
                 (a.qtd_item) as qtd_saldo,
                 a.pre_unit_nf as pre_unit ,a.val_liq_item,
                 b.den_item,b.pct_ipi,b.cod_unid_med,
                 c.den_texto_1,c.den_texto_2,c.den_texto_3,c.den_texto_4,
                 c.den_texto_5,b.den_item as den_nota
            from nf_item a,
                 outer item b,
                 outer ped_itens_texto c

           where a.cod_empresa='".$emp."'
                 and a.num_nff='".$nff_."'
                 and b.cod_empresa=a.cod_empresa
                 and b.cod_item=a.cod_item
                 and c.cod_empresa=a.cod_empresa
                 and c.num_pedido=a.num_pedido
                 and c.num_sequencia=a.num_sequencia
           order by a.num_pedido,a.num_sequencia  ";
  $res2 = $cconnect("logix",$ifx_user,$ifx_senha);
  $result2 = $cquery($pedido2,$res2);
  $mat=$cfetch_row($result2);
  $cab=1;
  while (is_array($mat))
  {
   if($cab==1)
   {
    fwrite($fp, $pula_linha);
    fwrite($fp, 'ITENS DA NOTA FISCAL');
    fwrite($fp, $pula_linha);
    fwrite($fp, 'SEQ');
    fwrite($fp, 'CODIGO');
    fwrite($fp, 'QTDE');
    fwrite($fp, 'UN');
    fwrite($fp, 'DESCRIÇAO DO PRODUTO');
    fwrite($fp, 'LIQ');
    fwrite($fp, 'TOTAL');
    fwrite($fp, '%IPI');
    fwrite($fp, $pula_linha);
    $cab=2;
   }
   fwrite($fp, $pula_linha);
   fwrite($fp, $mat["num_sequencia"]);
   fwrite($fp, $mat["cod_item"]);
   fwrite($fp, number_format($mat["qtd_saldo"],2,",","."));
   fwrite($fp, $mat["cod_unid_med"]);
   if($mat["cod_item"]=="")
   {
    fwrite($fp,$mat["den_nota"] );
   }else{
   fwrite($fp,$mat["den_item"] );
   }   
   fwrite($fp,number_format($mat["pre_unit"],2,",",".") );
   fwrite($fp,number_format($mat["val_liq_item"],2,",",".") );
   if($incid_ipi==1)
   {
    fwrite($fp,number_format($mat["pct_ipi"],2,",",".") );
   }else{
    fwrite($fp,number_format(0,2,",",".") );
   }
   if(substr($mat["den_texto_1"],1,1) <>"")
   {
    fwrite($fp, $pula_linha);
    fwrite($fp, $mat["den_texto_1"]);
    fwrite($fp, $mat["prz_entrega"]);
   }
   if(substr($mat["den_texto_2"],1,1) <>"")
   {
    fwrite($fp, $pula_linha);
    fwrite($fp, $mat["den_texto_2"]);
   }
   if(substr($mat["den_texto_3"],1,1) <>"")
   {
    fwrite($fp, $pula_linha);
    fwrite($fp, $mat["den_texto_3"]);
   }
   if(substr($mat["den_texto_4"],1,1) <>"")
   {
    fwrite($fp, $pula_linha);
    fwrite($fp, $mat["den_texto_4"]);
   }
   if(substr($mat["den_texto_5"],1,1) <>"")
   {
    fwrite($fp, $pula_linha);
    fwrite($fp, $mat["den_texto_5"]);
   }
   $mat=$cfetch_row($result2);
  }
  // variavel com tamanho do campo a ser formatado
  $tamanho="               ";
  // tamanho da variavel
  $tc=15;
  
  fwrite($fp, $pula_linha);
  fwrite($fp, 'TOTAIS DA NFF');
  fwrite($fp, $pula_linha);
  fwrite($fp, "Valor da Mercadoria..: ");

  // retorna o tamanho utilizado pelo valor a ser impresso
  $tam=strlen(chop(number_format($val_merc,2,",",".")));
  $tam=($tc-$tam);
  fwrite($fp, substr($tamanho,0,$tam));
  fwrite($fp, number_format($val_merc,2,",","."));
  fwrite($fp, $pula_linha);
  fwrite($fp, "Valor do Frete.......: ");
  // retorna o tamanho utilizado pelo valor a ser impresso
  $tam=strlen(chop(number_format($val_frete,2,",",".")));
  $tam=($tc-$tam);
  fwrite($fp, substr($tamanho,0,$tam));
  fwrite($fp, number_format($val_frete,2,",","."));
  fwrite($fp, $pula_linha);
  fwrite($fp, "Valor Base IPI.......: ");
  // retorna o tamanho utilizado pelo valor a ser impresso
  $tam=strlen(chop(number_format($val_base_ipi,2,",",".")));
  $tam=($tc-$tam);
  fwrite($fp, substr($tamanho,0,$tam));
  fwrite($fp, number_format($val_base_ipi,2,",","."));
  fwrite($fp, $pula_linha);
  fwrite($fp, "Valor do IPI.........: ");
  // retorna o tamanho utilizado pelo valor a ser impresso
  $tam=strlen(chop(number_format(1320,2,",",".")));
  $tam=($tc-$tam);
  fwrite($fp, substr($tamanho,0,$tam));
  fwrite($fp, number_format(1320,2,",","."));
  fwrite($fp, $pula_linha);
  fwrite($fp, "Valor Base ICMS......: ");
  // retorna o tamanho utilizado pelo valor a ser impresso
  $tam=strlen(chop(number_format($val_base_icm,2,",",".")));
  $tam=($tc-$tam);
  fwrite($fp, substr($tamanho,0,$tam));
  fwrite($fp, number_format($val_base_icm,2,",","."));
  fwrite($fp, $pula_linha);
  fwrite($fp, "Valor  ICMS..........: ");
  // retorna o tamanho utilizado pelo valor a ser impresso
  $tam=strlen(chop(number_format($val_icm,2,",",".")));
  $tam=($tc-$tam);
  fwrite($fp, substr($tamanho,0,$tam));
  fwrite($fp, number_format($val_icm,2,",","."));
  fwrite($fp, $pula_linha);
  fwrite($fp, "Valor Total NFF......: ");
  // retorna o tamanho utilizado pelo valor a ser impresso
  $tam=strlen(chop(number_format($val_nff,2,",",".")));
  $tam=($tc-$tam);
  fwrite($fp, substr($tamanho,0,$tam));
  fwrite($fp, number_format($val_nff,2,",","."));
  fclose($fp);
 } else {
  print "The file $filename is not writable";
 }
?>
