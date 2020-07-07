<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Módulo:         VDP
 //Processo:       Manutenção de Representantes
 $Versao=1;
 $prog="vdp/vdp0007";
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
  }elseif($prog_c=="V")
  {
   $fazer="V";
  }elseif($prog_c=="A")
  {
   $fazer="A";
  }elseif($prog_c=="E")
  {
  $fazer="E";
  }elseif($prog_c=="Z")
  {
  $fazer="Z";
  }else{
   $fazer="N";
  }

  $pct_nff=str_replace(".",".",$pct_nff);
  $pct_dp=str_replace(".",".",$pct_dp);
  $fixo=str_replace(".",".",$fixo);
  $teto=str_replace(".",".",$teto);
  $cota=str_replace(".",".",$cota);
  $pct_nff=str_replace(",",".",$pct_nff);
  $pct_dp=str_replace(",",".",$pct_dp);
  $fixo=str_replace(",",".",$fixo);
  $teto=str_replace(",",".",$teto);
  $cota=str_replace(",",".",$cota);





  if($fazer=='I')
  {
   $cons_faz="insert into  lt1200_representante
                 (cod_repres,tipo,num_matricula,cod_empresa,
                 pct_nff,pct_dp,ind,fixo,teto,cota,nivel)
                 values ('".$cod_repres."','".$tipo."','".$num_matricula."',
                '".$cod_empresa."','".$pct_nff."','".$pct_dp."',
                '".$ind."','".$fixo."','".$teto."','".$cota."','".$nivel."')";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
   $fazer="N";
  }
  if($fazer=='A')
  {
   $cons_faz="update  lt1200_representante  set
                        tipo ='".$tipo."',
                        num_matricula='".$num_matricula."',
                        cod_empresa='".$cod_empresa."',
                        pct_nff='".$pct_nff."',
                        pct_dp='".$pct_dp."',
                        ind='".$ind."',
                        fixo='".$fixo."',
                        teto='".$teto."',
                        cota='".$cota."',
                        nivel='".$nivel."'
                     where cod_repres='".$cod_repres."' ";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
   $fazer="N";
  }
  if($fazer=='Z')
  {
   $cons_faz="update  lt1200_representante  set
                        cota=0 ";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
   $fazer="N";
  }
  if($fazer=="N")
  {
   $selec_rep="select a.cod_repres,b.cod_repres as cod_repc,
                     a.raz_social,b.tipo,b.num_matricula,b.cod_empresa,
                     b.pct_nff,b.pct_dp,b.ind,b.fixo,b.teto,b.cota,
                     c.cod_nivel_4,c.cod_nivel_3
                   from logix:representante a,
                        logix:canal_venda c,
                         outer lt1200_representante b
                     where c.cod_nivel_4=a.cod_repres
                           and b.cod_repres=a.cod_repres
			   and c.cod_nivel_6=0
                           and c.cod_nivel_7=0                       
   union
           select a.cod_repres,b.cod_repres as cod_repc,
                     a.raz_social,b.tipo,b.num_matricula,b.cod_empresa,
                     b.pct_nff,b.pct_dp,b.ind,b.fixo,b.teto,b.cota,
                     c.cod_nivel_4,c.cod_nivel_3
                   from logix:representante a,
                        logix:canal_venda c,
                         outer lt1200_representante b
                     where c.cod_nivel_3=a.cod_repres
                           and b.cod_repres=a.cod_repres
			   and c.cod_nivel_6=0
                           and c.cod_nivel_7=0                       
                           and c.cod_nivel_4=0
                           
   union
           select a.cod_repres,b.cod_repres as cod_repc,
                     a.raz_social,b.tipo,b.num_matricula,b.cod_empresa,
                     b.pct_nff,b.pct_dp,b.ind,b.fixo,b.teto,b.cota,
                     c.cod_nivel_4,c.cod_nivel_3
                   from logix:representante a,
                        logix:canal_venda c,
                         outer lt1200_representante b
                     where c.cod_nivel_2=a.cod_repres
                           and b.cod_repres=a.cod_repres
			   and c.cod_nivel_6=0
                           and c.cod_nivel_7=0                       
                           and c.cod_nivel_4=0
                           and c.cod_nivel_3=0
                        
                                       
                       
                     order by c.cod_nivel_3,a.raz_social
                         
	";
   $res_rep = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_rep = $cquery($selec_rep,$res_rep);
   $mat_rep=$cfetch_row($result_rep);

   printf("   <tr>     
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Representantes</font></b>
      </td>
     </tr>
     <tr>     
      <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Cód.Sup.</font></b>
      </td>
      <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Código</font></b>
      </td>
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Nome</font></b>
      </td>");
   while (is_array($mat_rep))
   {
   $cod_repc=round($mat_rep["cod_repc"]);
   $cod_rep=round($mat_rep["cod_repres"]);  
   $cod_sup=round($mat_rep["cod_nivel_3"]); 
   $raz_rep=chop($mat_rep["raz_social"]); 
   printf("<FORM METHOD='POST' ACTION='vdp0007.php'>");
      printf("</tr><tr><td width='30'  style=$n_style colspan='3'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $cod_sup</font></i>
      </td>
      <td width='30'  style=$n_style colspan='3'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $cod_rep</font></i>
      </td>
      <td width='350'  style=$n_style colspan='35'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $raz_rep</font></i>
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='".$cod_rep."' name='cod_repres' size='1' maxlenght='1' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='V' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>");

      if($cod_repc<>$cod_rep)
      {
       printf("<td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Incluir '>
       </td>");
      }else{
       printf("<td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='VER/Alterar '>
       </td>");
      }
     printf("</tr> 
     </FORM>");
    $mat_rep=$cfetch_row($result_rep);
   }
  }

  if($fazer=="V")
  {
   $selec_rep="select a.cod_repres,b.cod_repres as cod_repc,
                     a.raz_social,b.tipo,b.num_matricula,b.cod_empresa,
                     b.pct_nff,b.pct_dp,b.ind,b.fixo,b.teto,b.cota,
                     c.cod_nivel_4,c.cod_nivel_3,b.nivel
                   from logix:representante a,
                        logix:canal_venda c,
                         outer lt1200_representante b
                     where a.cod_repres='".$cod_repres."'
                           and c.cod_nivel_4=a.cod_repres
                           and a.ies_situacao='N'
                           
                           and b.cod_repres=a.cod_repres
			   and c.cod_nivel_6=0
                           and c.cod_nivel_7=0                       
  union
       select a.cod_repres,b.cod_repres as cod_repc,
                     a.raz_social,b.tipo,b.num_matricula,b.cod_empresa,
                     b.pct_nff,b.pct_dp,b.ind,b.fixo,b.teto,b.cota,
                     c.cod_nivel_4,c.cod_nivel_3,b.nivel
                   from logix:representante a,
                        logix:canal_venda c,
                         outer lt1200_representante b
                     where a.cod_repres='".$cod_repres."'
                           and c.cod_nivel_3=a.cod_repres
                           and a.ies_situacao='N'
                           
                           and b.cod_repres=a.cod_repres
			   and c.cod_nivel_6=0
                           and c.cod_nivel_7=0                       
                           and c.cod_nivel_4=0
  union
       select a.cod_repres,b.cod_repres as cod_repc,
                     a.raz_social,b.tipo,b.num_matricula,b.cod_empresa,
                     b.pct_nff,b.pct_dp,b.ind,b.fixo,b.teto,b.cota,
                     c.cod_nivel_4,c.cod_nivel_3,b.nivel
                   from logix:representante a,
                        logix:canal_venda c,
                         outer lt1200_representante b
                     where a.cod_repres='".$cod_repres."'
                           and c.cod_nivel_2=a.cod_repres
                           and a.ies_situacao='N'
                           
                           and b.cod_repres=a.cod_repres
			   and c.cod_nivel_6=0
                           and c.cod_nivel_7=0                       
                           and c.cod_nivel_4=0
                           and c.cod_nivel_3=0                         
                           
                       
                     order by c.cod_nivel_3,a.raz_social
                         
	";
  $res_rep = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_rep = $cquery($selec_rep,$res_rep);
  $mat_rep=$cfetch_row($result_rep);
  while (is_array($mat_rep))
  {
   $cod_repc=round($mat_rep["cod_repc"]);
   $cod_rep=round($mat_rep["cod_repres"]);
   if($cod_rep<>$cod_repc)
   {
    printf("<FORM METHOD='POST' ACTION='vdp0007.php'>");
    printf("
     <tr>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Código:</font></b>
     </td>
     <td width='10'  style=$n_style colspan='1'     align='left'>
      <input type='text' name='cod_repres' size='4' maxlenght='4'
      value='".$cod_rep."' readonly> 
     </td>
     <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Razão:</font></b>
     </td>
     <td width='150'  style=$n_style colspan='15'     align='left'>
      <input type='text' name='raz_social' size='50' 
      value='".$mat_rep["raz_social"]."' readonly> 
     </td>
     <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tipo:</font></b>
     </td>
     <td width='40'  style=$n_style colspan='4'     align='left'>
      <select name='tipo'>");
      printf("<option value='' selected >Selecione Tipo</option>");
      printf("<option value='F'>Funcionario</option>");
      printf("<option value='R'>Representante</option>");
      printf("<option value='A'>Autonomo</option>");
      printf("<option value='C'>Func.Repre</option>");
      printf("<option value='K'>Teleatendimento</option>");
      printf("</select>
     </td></tr><tr>" );

     printf("<td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Empresa:</font></b>
     </td>");
    $cod_emp="0";
    $nom_emp="Selecione uma Empresa";
    printf("<td width='150'  style=$n_style colspan='15' align='left'  >
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
     </td>");
     printf("<td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Matricula:</font></b>
     </td>");
    printf("<td width='30'  style=$n_style colspan='3'     align='left'>
      <input type='text' name='num_matricula' size='10' maxlenght='10'
       value='".$mat_rep["num_matricula"]."'> 
      </td>
      <tr>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       NFF:</font></b>
     </td>

      <td width='30'  style=$n_style colspan='3'     align='left'>
       <input type='text' name='pct_nff' size='10' maxlenght='15'
       value='".$mat_rep["pct_nff"]."' > 
      </td>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Pagamento:</font></b>
     </td>
      <td width='30'  style=$n_style colspan='3'     align='right'>
       <input type='text' name='pct_dp' size='10' maxlenght='15'
       value='".$mat_rep["pct_dp"]."' > 
      </td>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Indenização:</font></b>
     </td>
      <td width='50'  style=$n_style colspan='5'     align='left'>
       <select name='ind'>");
       printf("<option value='' selected ></option>");
       printf("<option value='S'>Sim</option>");
       printf("<option value='N'>Nao</option>");
       printf("</select>
      </td></tr><tr>

     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       V.Fixo:</font></b>
     </td>

      <td width='30'  style=$n_style colspan='3'     align='left'>
       <input type='text' name='fixo' size='10' maxlenght='15'
       value='".$mat_rep["fixo"]."' > 
      </td>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Teto:</font></b>
     </td>

      <td width='30'  style=$n_style colspan='3'     align='left'>
       <input type='text' name='teto' size='10' maxlenght='15'
       value='".$mat_rep["teto"]."' > 
      </td>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Cota.R$:</font></b>
     </td>

      <td width='30'  style=$n_style colspan='3'     align='left'>
       <input type='text' name='cota' size='10' maxlenght='15'
       value='".$mat_rep["cota"]."' > 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Incluir '>
      </td>
      </tr> 
      </FORM>");
   }else{
    printf("<FORM METHOD='POST' ACTION='vdp0007.php'>");
    printf("
      <tr>
      <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Código:</font></b>
     </td>
     <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='cod_repres' size='4' maxlenght='4'
       value='".$cod_rep."' readonly> 
      </td>
     <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Razão:</font></b>
     </td>
      <td width='150'  style=$n_style colspan='15'     align='left'>
       <input type='text' name='raz_social' size='50' 
       value='".$mat_rep["raz_social"]."' readonly> 
      </td>
     <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tipo:</font></b>
     </td>
      <td width='40'  style=$n_style colspan='4'     align='left'>
       <select name='tipo'>");
    if($mat_rep["tipo"]=="F")
    {
     $den_tipo="Funcionario";
    }elseif($mat_rep["tipo"]=="R"){
     $den_tipo="Representante";
    }elseif($mat_rep["tipo"]=="A"){
     $den_tipo="Autonomo";
    }elseif($mat_rep["tipo"]=="C"){
     $den_tipo="Func.Repre";
    }elseif($mat_rep["tipo"]=="K"){
     $den_tipo="Teleatendimento";
    }else{
     $den_tipo="Selecione Tipo";
    }
    $ctipo=$mat_rep["tipo"];
    printf("<option value=$ctipo selected >$den_tipo</option>");
    printf("<option value='F'>Funcionario</option>");
    printf("<option value='R'>Representante</option>");
    printf("<option value='C'>Func.Repre</option>");
    printf("<option value='A'>Autonomo</option>");
    printf("<option value='K'>Teleatendimento</option>");
    printf("</select>
    </td></tr><tr>" );

    $sel_empresa="select * from empresa
                        where cod_empresa='".$mat_rep["cod_empresa"]."'
                          order by cod_empresa ";
    $link=$cconnect("logix",$ifx_user,$ifx_senha);
    $res_empresa=$cquery($sel_empresa,$link);
    $mat_empresa=$cfetch_row($res_empresa);
    $cod_emp=$mat_empresa["cod_empresa"];

$nom_emp=$mat_empresa["cod_empresa"].'-'.trim($mat_empresa["den_empresa"]);
    printf("<td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Empresa:</font></b>
     </td>");

    printf(" <td width='150'  style=$n_style colspan='15' align='left' >
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
     </td> 
    <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Matricúla:</font></b>
     </td>
     <td width='40'  style=$n_style colspan='4'     align='left'>
     <input type='text' name='num_matricula' size='10' maxlenght='10'
     value='".round($mat_rep["num_matricula"])."'> 
     </td>
     <tr>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       NFF:</font></b>
     </td>
     <td width='30'  style=$n_style colspan='3'     align='left'>
     <input type='text' name='pct_nff' size='10' maxlenght='15'
     value='".$mat_rep["pct_nff"]."' > 
     </td>
     <td width='50'  style=$n_style colspan='5'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Pagamento:</font></b>
     </td>
     <td width='30'  style=$n_style colspan='3'     align='left'>
     <input type='text' name='pct_dp' size='10' maxlenght='15'
     value='".$mat_rep["pct_dp"]."' > 
     </td>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Indenização:</font></b>
     </td>
     <td width='40'  style=$n_style colspan='4'     align='left'>
     <select name='ind'>");
     $c_ind=$mat_rep["ind"];
     if(chop($mat_rep["ind"])=="S")
     {
      $den_ind="Sim";
     }elseif(chop($mat_rep["ind"])=="N"){
      $den_ind="Nao";
     }else{
      $den_ind='';
     }
     printf("<option value=$c_ind selected >$den_ind</option>");
     printf("<option value='S'>Sim</option>");
     printf("<option value='N'>Nao</option>");
     printf("</select>
      </td></tr><tr>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       V.Fixo:</font></b>
     </td>
      <td width='30'  style=$n_style colspan='3'     align='left'>
       <input type='text' name='fixo' size='10' maxlenght='15'
       value='".$mat_rep["fixo"]."' > 
      </td>
     <td width='50'  style=$n_style colspan='5'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Teto:</font></b>
     </td>
      <td width='30'  style=$n_style colspan='3'     align='left'>
       <input type='text' name='teto' size='10' maxlenght='15'
       value='".$mat_rep["teto"]."' > 
      </td>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Cota.R$:</font></b>
     </td>
      <td width='30'  style=$n_style colspan='3'     align='left'>
       <input type='text' name='cota' size='10' maxlenght='15'
       value='".$mat_rep["cota"]."' > 
      </td>


      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='A' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Alterar '>
      </td>
     </tr> 
     <tr> 
      <td width='40'  style=$n_style colspan='4'     align='left'>
       <select name='nivel'>");
    $cnivel=chop($mat_rep["nivel"]);
    if($mat_rep["nivel"]=="G")
    {
     $den_tipo="Gestor";
    }elseif($mat_rep["nivel"]=="R"){
     $den_tipo="Representante";
    }elseif($mat_rep["nivel"]=="S"){
     $den_tipo="Supervisor";
    }else{
     $den_tipo="Selecione Nivel";
    }
    printf("<option value=$cnivel selected >$den_tipo</option>");
    printf("<option value='R'>Representante</option>");
    printf("<option value='S'>Supervisor</option>");
    printf("<option value='G'>Gestor</option>");
    printf("</select>
    </td></tr>

     </FORM>");
    }
    $count=$count+1;
    $mat_rep=$cfetch_row($result_rep);
   }
  }
    printf("<FORM METHOD='POST' ACTION='vdp0007.php'>");
    printf("
      <tr>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='Z' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='250'  style=$n_style colspan='25'      align='center'>
       <input type='submit' name='Confirmar' value='Zerar Todas as Cotas '>
      </td>
     </tr> 
     </FORM>");


 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






