<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:12/08/2005
 //Módulo:         VDP
 //Processo:       Lançamentos de Comissões
 $Versao=1;
 $prog="vdp/vdp0008";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  include("../../bibliotecas/autentica.inc");

  if($prog_c=="I")
  {
   $fazer="I";
  }elseif($prog_c=="A")
  {
   $fazer="A";
  }elseif($prog_c=="E")
  {
  $fazer="E";
  }else{
   $fazer="N";
  }
  printf("cliente-".$cod_cliente);
  if($fazer=='I')
  {
   $val_tot_mercadoria=str_replace(",",".",$val_tot_mercadoria);
   $val_tot_docum=str_replace(",",".",$val_tot_docum);
   $fixo=str_replace(",",".",$fixo);
   
   $cons_cli="select cod_cliente,nom_cliente from logix:clientes
               where cod_cliente='".$cod_cliente."' ";

   $res_cli = $cconnect("lt1200",$ifx_user,$ifx_senha);

   $result_cli = $cquery($cons_cli,$res_cli);
   $mat_cli=$cfetch_row($result_cli);
   $ccli=chop($mat_cli["nom_cliente"]);
   printf($cons_cli);
   if($ccli=="")
   {
    $cons1=1 ;
   }else{
    $cons1=0;
   }

   $cons_ctr_comis="select sit
                     from lt1200_ctr_comis
                      where mes_ref='".$mes_ref."'
                         and ano_ref='".$ano_ref."' 
                         and cod_empresa='".$cod_empresa."' ";

   $res_ctr_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_ctr_comis = $cquery($cons_ctr_comis,$res_ctr_comis);
   $mat_ctr_comis=$cfetch_row($result_ctr_comis);

   $cctr=$mat_ctr_comis["sit"];
   if(chop($cctr)=="F")
   {
    $cons2=1;
   }else{
    $cons2=0;
   }
   $cons3=$cons1+$cons2;
   if($cons3==0)
   {
    $cons_faz="insert into  lt1200_comissoes
            (ies_tip_docto,ies_tipo_lancto,mes_ref,ano_ref,cod_empresa,
             cod_repres,num_nff,num_docum,dat_emissao,cod_cliente,
             val_tot_mercadoria,val_tot_docum,observacao)
        values ('".$ies_tip_docto."','A','".$mes_ref."',
                '".$ano_ref."','".$cod_empresa."','".$cod_repres."',
                '".$num_nff."','".$num_docum."','".$dat_emissao."',
                '".$cod_cliente."','".$val_tot_mercadoria."','".$val_tot_docum."',
                '".$observacao."')";
    $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_faz = $cquery($cons_faz,$res_faz);
    $prog_c="N";
   }else{
    printf("<FORM METHOD='POST' ACTION='vdp0008.php'>");
    if($cons2 > 0)
    {
     printf("<tr>
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='4' color=red>
       Periodo ja Encerrado</font></b>
      </td>
     </tr>");
    }
    if($cons1 >0)
    {
     printf("<tr>
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='4' color=red>
       Cliente Não Cadastrado </font></b>
      </td>
     </tr>");
    }
    $cons1=0;
    $cons2=0;
    $cons3=0;

     printf("<tr>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tipo:</font></b>
      </td>");
      if($ies_tip_docto=="NF")
      {
       $ttipo="Nota Fiscal";
      }else{
       $ttipo="Duplicata";
      }
      printf("<td width='30'  style=$n_style colspan='3'     align='left'>
       <select name='ies_tip_docto'>");
    printf("<option value=$ies_tip_docto selected >$ttipo</option>");
    printf("<option value='NF'>Nota Fiscal</option>");
    printf("<option value='DP'>Duplicata</option>");
    printf("<td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Empresa:</font></b>
      </td>");
    printf("</select>
      </td>" );


    $cod_emp="0";
    $nom_emp="Selecione uma Empresa";

    $sel_empresa="select * from empresa
                      where cod_empresa='".$cod_empresa."'
                        order by cod_empresa ";
    $link=$cconnect("logix",$ifx_user,$ifx_senha);
    $res_empresa=$cquery($sel_empresa,$link);

    $mat_empresa=$cfetch_row($res_empresa);

    $cod_emp=trim($mat_empresa["cod_empresa"]);
    $nom_emp=trim($mat_empresa["cod_empresa"]).'-'.trim($mat_empresa["den_empresa"]);

    printf(" <td width='350'  style=$n_style colspan='35'  >
        <select name='cod_empresa'>");

    printf("<option value='$cod_emp' >$nom_emp</option>");
    $sel_empresa="select * from empresa
                        order by cod_empresa ";
    $link=$cconnect("logix",$ifx_user,$ifx_senha);
    $res_empresa=$cquery($sel_empresa,$link);
    $mat_empresa=$cfetch_row($res_empresa);
    while(is_array($mat_empresa))
    {
     $cod_emp=trim($mat_empresa["cod_empresa"]);
     $nom_emp=trim($mat_empresa["cod_empresa"]).'-'.trim($mat_empresa["den_empresa"]);
     printf("<option value='$cod_emp' >$nom_emp</option>");
     $mat_empresa=$cfetch_row($res_empresa);
    }
    printf("</select>
    </td> ");

    $selec_comis="select unique a.cod_repres,a.raz_social
                   from logix:representante a,
                        lt1200_representante b
                     where a.cod_repres='".$cod_repres."'
                       and b.cod_repres=a.cod_repres
                      order by a.raz_social	";
    $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_comis = $cquery($selec_comis,$res_comis);
    $mat_comis=$cfetch_row($result_comis);
    $cod_rep=round($mat_comis["cod_repres"]);
    $raz_social=round($mat_comis["cod_repres"]).'-'.trim($mat_comis["raz_social"]);


    $selec_comis="select unique a.cod_repres,a.raz_social
                   from logix:representante a,
                        lt1200_representante b
                     where b.cod_repres=a.cod_repres
                     order by a.raz_social	";
    $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_comis = $cquery($selec_comis,$res_comis);
    $mat_comis=$cfetch_row($result_comis);
    printf("</tr><tr>");
    printf("<td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Representante:</font></b>
      </td>");

    printf(" <td width='150'  style=$n_style colspan='15'  >
          <select name='cod_repres'>");
    printf("<option value='$cod_rep' >$raz_social</option>");
    while(is_array($mat_comis))
    {
     $cod_rep=round($mat_comis["cod_repres"]);
     $raz_social=round($mat_comis["cod_repres"]).'-'.trim($mat_comis["raz_social"]);
     printf("<option value='$cod_rep' >$raz_social</option>");
     $mat_comis=$cfetch_row($result_comis);
    }
    printf("</select>
    </td> 
    <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Cliente:</font></b>
    </td>

    <td width='100'  style=$n_style colspan='10'     align='right'>
       <input type='text' name='cod_cliente' value=".$cod_cliente." size='15' maxlenght='15' > 
      </td>
    </tr>
    <tr>

    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Mes:</font></b>
    </td>

    <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='mes_ref' value=".$mes_ref." size='2' maxlenght='2' > 
      </td>

    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Ano:</font></b>
    </td>


    <td width='10'  style=$n_style colspan='1'     align='right'>
       <input type='text' name='ano_ref' value=".$ano_ref." size='4' maxlenght='4' > 
      </td>

    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Num.NFF:</font></b>
    </td>
    <td width='50'  style=$n_style colspan='5'     align='right'>
       <input type='text' name='num_nff' value=".$num_nff." size='10' maxlenght='16' > 
      </td>
    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Num.DP:</font></b>
    </td>
    <td width='50'  style=$n_style colspan='5'     align='right'>
       <input type='text' name='num_docum' value=".$num_docum." size='10' maxlenght='16' > 
      </td>
    <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Dat.DCTO:</font></b>
    </td>
    <td width='50'  style=$n_style colspan='5'     align='right'>
       <input type='text' name='dat_emissao' value=".$dat_emissao." size='10' maxlenght='10' > 
      </td>
    </tr>
    <tr>
    <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       VLR.Merc:</font></b>
    </td>

    <td width='50'  style=$n_style colspan='5'     align='right'>
       <input type='text' name='val_tot_mercadoria' value=".$val_tot_mercadoria." size='16' maxlenght='16' > 
      </td>

    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       VLR.Docto:</font></b>
    </td>
    <td width='50'  style=$n_style colspan='5'     align='right'>
       <input type='text' name='val_tot_docum' value=".$val_tot_docum."  size='16' maxlenght='16' > 
      </td>
    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       OBS:</font></b>
    </td>
    <td width='250'  style=$n_style colspan='25'     align='right'>
       <input type='text' name='observacao' value='".$observacao."' size='60' maxlenght='60' > 
      </td>    ");

     printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
     </td>
     <td width='80'  style=$n_style colspan='8'      align='center'>
      <input type='submit' name='Confirmar' value='Incluir '>
     </td>
     </tr> 
     <tr>
    <td width='250'  style=$n_style colspan='25     align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       _______________________________________________________</font></b>
    </td>
     </tr>

     <tr>
    <td width='250'  style=$n_style colspan='25'      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=red>
       Novo Lancamento</font></b>
    </td>
     </tr>


     </FORM>");
   }
     
 
  }
  if($fazer=='A')
  {
   $val_tot_mercadoria=str_replace(",",".",$val_tot_mercadoria);
   $val_tot_docum=str_replace(",",".",$val_tot_docum);
   $fixo=str_replace(",",".",$fixo);
   
   $cons_cli="select cod_cliente,nom_cliente from logix:clientes
               where cod_cliente='".$cod_cliente."' ";

   $res_cli = $cconnect("lt1200",$ifx_user,$ifx_senha);

   $result_cli = $cquery($cons_cli,$res_cli);
   $mat_cli=$cfetch_row($result_cli);
   $ccli=chop($mat_cli["nom_cliente"]);
   printf($cons_cli);
   if($ccli=="")
   {
    $cons1=1 ;
   }else{
    $cons1=0;
   }

   $cons_ctr_comis="select sit
                     from lt1200_ctr_comis
                      where mes_ref='".$mes_ref."'
                         and ano_ref='".$ano_ref."' 
                         and cod_empresa='".$cod_empresa."' ";

   $res_ctr_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_ctr_comis = $cquery($cons_ctr_comis,$res_ctr_comis);
   $mat_ctr_comis=$cfetch_row($result_ctr_comis);

   $cctr=$mat_ctr_comis["sit"];
   if(chop($cctr)=="F")
   {
    $cons2=1;
   }else{
    $cons2=0;
   }
   $cons3=$cons1+$cons2;
   if($cons3==0)
   {
    $cons_faz="update  lt1200_comissoes
               set ies_tip_docto='".$ies_tip_docto."',
                   mes_ref='".$mes_ref."',
                   ano_ref='".$ano_ref."',
                   num_nff='".$num_nff."',
                   num_docum='".$num_docum."',
                   dat_emissao='".$dat_emissao."',
                   cod_cliente='".$cod_cliente."',
                   val_tot_mercadoria='".$val_tot_mercadoria."',
                   val_tot_docum='".$val_tot_docum."', 
                   observacao='".$observacao."'
                where cod_repres='".$cod_repres."'
                      and num_docum='".$num_docum_."'
                      and ies_tip_lancto='A'
                      and mes_ref='".$mes_ref_."'
                      and ano_ref='".$ano_ref_."'";
    $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_faz = $cquery($cons_faz,$res_faz);
    $prog_c="N";
   }else{
    printf("<FORM METHOD='POST' ACTION='vdp0008.php'>");
    if($cons2 > 0)
    {
     printf("<tr>
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='4' color=red>
       Periodo ja Encerrado</font></b>
      </td>
     </tr>");
    }
    if($cons1 >0)
    {
     printf("<tr>
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='4' color=red>
       Cliente Não Cadastrado </font></b>
      </td>
     </tr>");
    }
    $cons1=0;
    $cons2=0;
    $cons3=0;
   }
  }

  $selec_comis="select a.cod_repres,b.cod_repres as cod_repc,
                     a.raz_social,b.tipo,b.num_matricula,b.cod_empresa,
                     b.pct_nff,b.pct_dp,b.ind,b.fixo,
                     c.cod_nivel_4,c.cod_nivel_3
                   from logix:representante a,
                        logix:canal_venda c,
                         outer lt1200_representante b
                     where c.cod_nivel_4=a.cod_repres
			   and c.cod_nivel_6=0
                           and c.cod_nivel_7=0                       
                           and b.cod_repres=a.cod_repres
                       
                     order by c.cod_nivel_3,c.cod_nivel_4
                         
	";
  $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_comis = $cquery($selec_comis,$res_comis);
  $mat_comis=$cfetch_row($result_comis);


  printf("<FORM METHOD='POST' ACTION='vdp0008.php'>");
  printf("
     <tr>
      <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tipo:</font></b>
      </td>

      <td width='30'  style=$n_style colspan='3'     align='left'>
       <select name='ies_tip_docto'>");
  printf("<option value='' selected >Selecione Tipo</option>");
  printf("<option value='NF'>Nota Fiscal</option>");
  printf("<option value='DP'>Duplicata</option>");

  printf("<td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Empresa:</font></b>
      </td>");
  printf("</select>
      </td>" );
  $cod_emp="0";
  $nom_emp="Selecione uma Empresa";
  printf(" <td width='350'  style=$n_style colspan='35'  >
          <select name='cod_empresa'>");
  printf("<option value='$cod_emp' >$nom_emp</option>");
  $sel_empresa="select * from empresa
                        order by cod_empresa ";
  $link=$cconnect("logix",$ifx_user,$ifx_senha);
  $res_empresa=$cquery($sel_empresa,$link);
  $mat_empresa=$cfetch_row($res_empresa);
  while(is_array($mat_empresa))
  {
   $cod_emp=trim($mat_empresa["cod_empresa"]);
   $nom_emp=trim($mat_empresa["cod_empresa"]).'-'.trim($mat_empresa["den_empresa"]);
   printf("<option value='$cod_emp' >$nom_emp</option>");
   $mat_empresa=$cfetch_row($res_empresa);
  }
  printf("</select>
    </td> ");

  $selec_comis="select unique a.cod_repres,a.raz_social
                   from logix:representante a,
                        lt1200_representante b
                     where b.cod_repres=a.cod_repres
                     order by a.raz_social	";
  $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_comis = $cquery($selec_comis,$res_comis);
  $mat_comis=$cfetch_row($result_comis);
  printf("</tr><tr>");
  printf("<td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Representante:</font></b>
      </td>");

  printf(" <td width='150'  style=$n_style colspan='15'  >
          <select name='cod_repres'>");
  $cod_rep="0";
  $raz_social="Selecione um Representante";
  printf("<option value='$cod_rep' >$raz_social</option>");
  while(is_array($mat_comis))
  {
   $cod_rep=round($mat_comis["cod_repres"]);
   $raz_social=round($mat_comis["cod_repres"]).'-'.trim($mat_comis["raz_social"]);
   printf("<option value='$cod_rep' >$raz_social</option>");
   $mat_comis=$cfetch_row($result_comis);
  }
  printf("</select>
    </td> 
    <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Cliente:</font></b>
    </td>

    <td width='100'  style=$n_style colspan='10'     align='right'>
       <input type='text' name='cod_cliente' size='15' maxlenght='15' > 
      </td>
   </tr>
   <tr>

    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Mes:</font></b>
    </td>

    <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='mes_ref' size='2' maxlenght='2' > 
      </td>

    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Ano:</font></b>
    </td>


    <td width='10'  style=$n_style colspan='1'     align='right'>
       <input type='text' name='ano_ref' size='4' maxlenght='4' > 
      </td>

    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Num.NFF:</font></b>
    </td>
    <td width='50'  style=$n_style colspan='5'     align='right'>
       <input type='text' name='num_nff' size='10' maxlenght='16' > 
      </td>
    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Num.DP:</font></b>
    </td>
    <td width='50'  style=$n_style colspan='5'     align='right'>
       <input type='text' name='num_docum' size='10' maxlenght='16' > 
      </td>
    <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Dat.DCTO:</font></b>
    </td>
    <td width='50'  style=$n_style colspan='5'     align='right'>
       <input type='text' name='dat_emissao' size='10' maxlenght='10' > 
      </td>
    </tr>
    <tr>
    <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       VLR.Merc:</font></b>
    </td>

    <td width='50'  style=$n_style colspan='5'     align='right'>
       <input type='text' name='val_tot_mercadoria' size='16' maxlenght='16' > 
      </td>

    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       VLR.Docto:</font></b>
    </td>
    <td width='50'  style=$n_style colspan='5'     align='right'>
       <input type='text' name='val_tot_docum' size='16' maxlenght='16' > 
      </td>
    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       OBS:</font></b>
    </td>
    <td width='250'  style=$n_style colspan='25'     align='right'>
       <input type='text' name='observacao' size='60' maxlenght='60' > 
      </td>    ");

    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
    </td>
    <td width='80'  style=$n_style colspan='8'      align='center'>
     <input type='submit' name='Confirmar' value='Incluir '>
    </td>
   </tr> 
  </FORM>");

 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






