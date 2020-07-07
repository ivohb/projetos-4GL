<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manuten��o:    
 //Data manuten��o:21/06/2005
 //M�dulo:         VDP
 //Processo:       Manuten��o de Representantes
 $versao=1;
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
  }elseif($prog_c=="V")
  {
   $fazer="V";
  }elseif($prog_c=="A")
  {
   $fazer="A";
  }elseif($prog_c=="E")
  {
   $fazer="E";
  }else{
   $fazer="N";
  }

  $pct_nff=str_replace(".",".",$pct_nff);
  $pct_dp=str_replace(".",".",$pct_dp);
  $fixo=str_replace(".",".",$fixo);
  $teto=str_replace(".",".",$teto);
  $cota=str_replace(".",".",$cota);

  if($fazer=='I')
  {
   $val_tot_mercadoria=str_replace(".",".",$val_tot_mercadoria);
   $val_tot_docum=str_replace(".",".",$val_tot_docum);
   $val_tot_mercadoria=str_replace(",",".",$val_tot_mercadoria);
   $val_tot_docum=str_replace(",",".",$val_tot_docum);
   $fixo=str_replace(".",".",$fixo);
   
   $cons_cli="select cod_cliente,nom_cliente from logix:clientes
               where cod_cliente='".$cod_cliente."' ";

   $res_cli = $cconnect("lt1200",$ifx_user,$ifx_senha);

   $result_cli = $cquery($cons_cli,$res_cli);
   $mat_cli=$cfetch_row($result_cli);
   $ccli=chop($mat_cli["nom_cliente"]);
   if($ccli<>'')
   {
    $cons1=0;
   }else{
    $cons1=1;
   }
   if($ies_tip_docto=="GR")
   {
    $cons1=0;
   }
   if($ies_tip_docto=="CP")
   {
    $cons1=0;
   }

   if($tipo=="F")
   {
    $sit="sit_func";
   }elseif($tipo=="R"){
    $sit="sit_rep";
   }elseif($tipo=="A"){
    $sit="sit_aut";
   }elseif($tipo=="C"){
    $sit="sit_fr";
   }elseif($tipo=="K"){
   	$sit="sit_tel";
   }


    
   $cons_ctr_comis="select ".$sit." as sit
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
             val_tot_mercadoria,val_tot_docum,observacao,cod_supervisor)
        values ('".$ies_tip_docto."','A','".$mes_ref."',
                '".$ano_ref."','".$cod_empresa."','".$cod_repres."',
                '".$num_nff."','".$num_docum."','".$dat_emissao."',
                '".$cod_cliente."','".$val_tot_mercadoria."','".$val_tot_docum."',
                '".$observacao."','".$cod_supervisor."')";
    $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_faz = $cquery($cons_faz,$res_faz);
    $prog_c="V";
    $fazer="V";
   }else{
    $prog_c="V";
    $fazer="V";
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
       Cliente N�o Cadastrado </font></b>
      </td>
     </tr>");
    }
    $cons1=0;
    $cons2=0;
    $cons3=0;
   }
  }
  if($fazer=='A')
  {
   $val_tot_mercadoria=str_replace(".",".",$val_tot_mercadoria);
   $val_tot_docum=str_replace(".",".",$val_tot_docum);
   $val_tot_mercadoria_c=str_replace(".",".",$val_tot_mercadoria_c);
   $val_tot_docum_c=str_replace(".",".",$val_tot_docum_c);
   $val_tot_mercadoria=str_replace(",",".",$val_tot_mercadoria);
   $val_tot_docum=str_replace(",",".",$val_tot_docum);
   $val_tot_mercadoria_c=str_replace(",",".",$val_tot_mercadoria_c);
   $val_tot_docum_c=str_replace(",",".",$val_tot_docum_c);
   $fixo=str_replace(".",".",$fixo);
   
   $cons_cli="select cod_cliente from logix:clientes
               where cod_cliente='".$cod_cliente."' ";

   $res_cli = $cconnect("lt1200",$ifx_user,$ifx_senha);

   $result_cli = $cquery($cons_cli,$res_cli);
   $mat_cli=$cfetch_row($result_cli);
   $ccli=$mat_cli["cod_cliente"];
   if($ccli==$cod_cliente)
   {
    $cons1=0;
   }else{
    $cons1=1;
   }
   if($ies_tip_docto=="GR")
   {
    $cons1=0;
   }
   if($ies_tip_docto=="CP")
   {
    $cons1=0;
   }

   if($tipo=="F")
   {
    $sit="sit_func";
   }elseif($tipo=="R"){
    $sit="sit_rep";
   }elseif($tipo=="A"){
    $sit="sit_aut";
   }elseif($tipo=="C"){
    $sit="sit_fr";
   }elseif($tipo=="K"){
   	$sit="sit_tel";
   }


    
   $cons_ctr_comis="select '".$sit."' as sit
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
            set 
                ies_tip_docto='".$ies_tip_docto."',
                mes_ref='".$mes_ref."',
                ano_ref='".$ano_ref."',
                num_nff='".$num_nff."',
                num_docum='".$num_docum."',
                dat_emissao='".$dat_emissao."',
                cod_cliente='".$cod_cliente."',
                val_tot_mercadoria='".$val_tot_mercadoria."',
                val_tot_docum='".$val_tot_docum."',
                observacao='".$observacao."',
                cod_supervisor='".$cod_supervisor."'
            where cod_repres='".$cod_repres."'
                and ies_tip_docto='".$ies_tip_docto_c."'
                and mes_ref='".$mes_ref_c."'
                and ano_ref='".$ano_ref_c."'
                and num_nff='".$num_nff_c."'
                and num_docum='".$num_docum_c."'
                and cod_supervisor='".$cod_supervisor_c."'
                and dat_emissao='".$dat_emissao_c."'
                and cod_cliente='".$cod_cliente_c."'
                and ies_tipo_lancto='A'
                and cod_empresa='".$cod_empresa."' ";
    $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_faz = $cquery($cons_faz,$res_faz);
    $prog_c="V";
    $fazer="V";
   }else{
    $prog_c="V";
    $fazer="V";
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
       Cliente N�o Cadastrado </font></b>
      </td>
     </tr>");
    }
    $cons1=0;
    $cons2=0;
    $cons3=0;
   }
  }

  if($fazer=='E')
  {
    $cons_faz="delete from   lt1200_comissoes
            where cod_repres='".$cod_repres."'
                and ies_tip_docto='".$ies_tip_docto_c."'
                and mes_ref='".$mes_ref_c."'
                and ano_ref='".$ano_ref_c."'
                and num_nff='".$num_nff_c."'
                and num_docum='".$num_docum_c."'
                and dat_emissao='".$dat_emissao_c."'
                and cod_cliente='".$cod_cliente_c."'
                and ies_tipo_lancto='A'
                and cod_empresa='".$cod_empresa_c."' ";


    $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_faz = $cquery($cons_faz,$res_faz);
    $prog_c="V";
    $fazer="V";
  }




  if($fazer=="N")
  {
   $selec_rep="select a.cod_repres,b.cod_repres as cod_repc,
                     a.raz_social,b.tipo,b.num_matricula,b.cod_empresa,
                     b.pct_nff,b.pct_dp,b.ind,b.fixo,b.teto,b.cota,b.tipo,
                     c.cod_nivel_4,c.cod_nivel_3
                   from logix:representante a,
                        logix:canal_venda c,
                         lt1200_representante b
                     where c.cod_nivel_4=a.cod_repres
                           and b.cod_repres=a.cod_repres
			   and c.cod_nivel_6=0
                           and c.cod_nivel_7=0                       
  union
           select a.cod_repres,b.cod_repres as cod_repc,
                     a.raz_social,b.tipo,b.num_matricula,b.cod_empresa,
                     b.pct_nff,b.pct_dp,b.ind,b.fixo,b.teto,b.cota,b.tipo,
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
                     b.pct_nff,b.pct_dp,b.ind,b.fixo,b.teto,b.cota,b.tipo,
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

                     order by 14,3
	";
   $res_rep = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_rep = $cquery($selec_rep,$res_rep);
   $mat_rep=$cfetch_row($result_rep);
   printf("   <tr>     
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Representantes</font></b>
      </td>
     </tr>");
   while (is_array($mat_rep))
   {
   $tipo=chop($mat_rep["tipo"]);
   $cod_repc=round($mat_rep["cod_repc"]);
   $cod_rep=round($mat_rep["cod_repres"]);  
   $cod_sup=round($mat_rep["cod_nivel_3"]); 
   $raz_rep=$mat_rep["raz_social"];
   printf("<FORM METHOD='POST' ACTION='vdp0008.php'>");
      printf("</tr><tr><td width='30'  style=$n_style colspan='3'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $cod_rep</font></i>
      </td>
      <td width='350'  style=$n_style colspan='35'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $raz_rep</font></i>
      </td>");
      printf("<td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='".$tipo."' name='tipo' 
       size='1' maxlenght='1' readonly> 
      </td>      
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='".$cod_rep."' name='cod_repres' 
       size='1' maxlenght='1' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='".$cod_sup."' name='cod_supervisor' 
       size='1' maxlenght='1' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='".$cod_empresa."' name='cod_empresa' 
       size='1' maxlenght='1' readonly> 
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
       <input type='submit' name='Confirmar' value='Lan�amentos'>
       </td>");
      }
     printf("</tr> 
     </FORM>");
    $mat_rep=$cfetch_row($result_rep);
   }
  }
  if($fazer=="V")
  {
   printf("<FORM METHOD='POST' ACTION='vdp0008.php'>");
   $selec_comis="select unique a.cod_repres,a.raz_social
                   from logix:representante a,
                        lt1200_representante b
                     where a.cod_repres='".$cod_repres."'
                           and b.cod_repres=a.cod_repres
                     order by a.raz_social	";
  
   $res_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_comis = $cquery($selec_comis,$res_comis);
   $mat_comis=$cfetch_row($result_comis);
   $cod_repres=round($mat_comis["cod_repres"]);
   $raz_social=round($mat_comis["cod_repres"]).'-'.trim($mat_comis["raz_social"]);
   printf("</tr>
            <tr>
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Representante:$raz_social</font></b>
      </td>
     <tr>
      <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Empresa:</font></b>
      </td>
     <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='cod_empresa' value='".$cod_empresa."'
	size='2' maxlenght='2' > 
      </td>
      <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tipo:</font></b>
      </td>
      <td width='40'  style=$n_style colspan='4'     align='left'>
       <select name='ies_tip_docto'>");
   if($ies_tip_docto=="NF")
   {
    $den_docto="Nota Fiscal";
   }elseif($ies_tip_docto=="DP"){
    $den_docto="Duplicata";
   }elseif($ies_tip_docto=="GR"){
    $den_docto="Geral";
   }elseif($ies_tip_docto=="BC"){
    $den_docto="Bonif.Constr.";
   }elseif($ies_tip_docto=="AC"){
    $den_docto="Adiant.Comis.";
   }elseif($ies_tip_docto=="CP"){
    $den_docto="Complemento";
   }elseif($ies_tip_docto=="EI"){
    $den_docto="Estorno Inden.";
   }elseif($ies_tip_docto=="EF"){
    $den_docto="Frete";
   }elseif($ies_tip_docto=="EG"){
    $den_docto="GNRE";
   }else{
    $den_docto="Selecione Tipo";
   }
   printf("<option value=$ies_tip_docto selected >".$den_docto."</option>");
   printf("<option value='NF'>Nota Fiscal</option>");
   printf("<option value='DP'>Duplicata</option>");
   printf("<option value='GR'>Geral</option>");
   printf("<option value='BC'>Bonif.Constr.</option>");
   printf("<option value='AC'>Adiant.Comis.</option>");
   printf("<option value='EI'>Estorno Inden.</option>");
   printf("<option value='CP'>Complemento</option>");
   printf("<option value='EF'>Frete</option>");
   printf("<option value='EG'>GNRE</option>");
   printf("</select>  </td>" );
   printf("
    </td> 
    <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Cliente:</font></b>
    </td>

    <td width='40'  style=$n_style colspan='4'     align='left'>
       <input type='text' name='cod_cliente' value='".$cod_cliente."' size='15' maxlenght='15' > 
      </td>
    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Mes:</font></b>
    </td>

    <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='mes_ref' value='".$mes_ref."' size='2' maxlenght='2' > 
      </td>

    <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Ano:</font></b>
    </td>


    <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='ano_ref' value='".$ano_ref."' size='4' maxlenght='4' > 
      </td>
    </tr><tr>
    <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Num.NFF:</font></b>
    </td>
    <td width='40'  style=$n_style colspan='4'     align='left'>
       <input type='text' name='num_nff' value='".$num_nff."' size='10' maxlenght='16' > 
      </td>
    <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Num.DP:</font></b>
    </td>
    <td width='50'  style=$n_style colspan='5'     align='left'>
       <input type='text' name='num_docum' value='".$num_docum."'
       size='10' maxlenght='16' > 
      </td>
    <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Dat.DCTO:</font></b>
    </td>
    <td width='50'  style=$n_style colspan='5'     align='left'>
       <input type='text' name='dat_emissao' value='".$dat_emissao."'
       size='10' maxlenght='10' > 
      </td>
    </tr>
    <tr>
    <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       VL.Merc:</font></b>
    </td>

    <td width='40'  style=$n_style colspan='4'     align='left'>
       <input type='text' name='val_tot_mercadoria'  value='".$val_tot_mercadoria."'
      size='15' maxlenght='16' > 
      </td>

    <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       VL.Docto:</font></b>
    </td>
    <td width='40'  style=$n_style colspan='4'     align='left'>
       <input type='text' name='val_tot_docum' value='".$val_tot_docum."' 
        size='15' maxlenght='16' > 
      </td>
    </tr><tr>
    <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       OBS:</font></b>
    </td>
    <td width='250'  style=$n_style colspan='25'     align='left'>
       <input type='text' name='observacao' value='".$observacao."' size='60' maxlenght='60' > 
      </td>   
    </tr><tr><td width='40'  style=$n_style colspan='4'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Supervisor:</font></b>
    </td>
    <td width='30'  style=$n_style colspan='3'     align='left'>
       <input type='text' name='cod_supervisor' value='".$cod_supervisor."' size='3' maxlenght='3' > 
      </td>    ");


   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='".$cod_repres."' name='cod_repres' size='1' maxlenght='1' readonly> 
    </td>");
   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='".$tipo."' name='tipo' 
       size='1' maxlenght='1' readonly> 
      </td>");      
   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
    </td>
    <td width='80'  style=$n_style colspan='8'      align='center'>
     <input type='submit' name='Confirmar' value='Incluir '>
    </td>
   </tr> 
   </FORM>");

   $sel_tip="select tipo from
                        lt1200_representante 
                  where cod_repres='".$cod_repres."' 
                                           ";
 
   $link=$cconnect("lt1200",$ifx_user,$ifx_senha);
   $res_tip=$cquery($sel_tip,$link);
   $mat_tip=$cfetch_row($res_tip);
   $tipo=$mat_tip["tipo"];

   if($tipo=="F")
   {
    $sit="a.sit_func";
   }elseif($tipo=="R"){
    $sit="a.sit_rep";
   }elseif($tipo=="A"){
    $sit="a.sit_aut";
   }elseif($tipo=="C"){
    $sit="a.sit_fr";
   }elseif($tipo=="K"){
   	$sit="a.sit_tel";
   }

   
//Alteracao

   $sel_lanc_comis="select b.ies_tip_docto,b.cod_empresa,
                           b.cod_repres,b.num_nff,b.num_docum,b.dat_emissao,
			   b.cod_cliente,b.val_tot_docum,b.val_tot_mercadoria,
			   b.observacao,b.mes_ref,b.ano_ref,c.tipo,
                           b.cod_supervisor
	    	   from lt1200_ctr_comis a,
                        lt1200_comissoes b,
                        lt1200_representante c
                  where  ".$sit." <>'F'
			and b.ano_ref=a.ano_ref
                        and b.mes_ref=a.mes_ref 
                        and b.cod_repres='".$cod_repres."' 
                        and b.ies_tipo_lancto <>'G'  
                        and c.cod_repres=b.cod_repres                      

                                           ";
   $link=$cconnect("lt1200",$ifx_user,$ifx_senha);
   $res_lanc_comis=$cquery($sel_lanc_comis,$link);
   $mat_lanc_comis=$cfetch_row($res_lanc_comis);

   while (is_array($mat_lanc_comis))
   {
    $ies_tip_docto=$mat_lanc_comis["ies_tip_docto"];
    $empresa=$mat_lanc_comis["cod_empresa"];
    $cod_empresa=$mat_lanc_comis["cod_empresa"];
    $cod_repres=$mat_lanc_comis["cod_repres"];
    $num_nff=$mat_lanc_comis["num_nff"];
    $num_docum=$mat_lanc_comis["num_docum"];
    $dat_emissao=$mat_lanc_comis["dat_emissao"];
    $cod_cliente=$mat_lanc_comis["cod_cliente"];
    $val_tot_mercadoria=$mat_lanc_comis["val_tot_mercadoria"];
    $val_tot_docum=$mat_lanc_comis["val_tot_docum"];
    $observacao=$mat_lanc_comis["observacao"];
    $mes_ref=$mat_lanc_comis["mes_ref"];
    $ano_ref=$mat_lanc_comis["ano_ref"];
    $cod_supervisor=round($mat_lanc_comis["cod_supervisor"]);
    printf("<FORM METHOD='POST' ACTION='vdp0008.php'>");
    printf("<tr>
      <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Empresa:</font></b>
      </td>
     <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='cod_empresa' value='".$cod_empresa."'
	size='2' maxlenght='2' > 
      </td>
      <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tipo:</font></b>
      </td>
      <td width='40'  style=$n_style colspan='4'     align='left'>
       <select name='ies_tip_docto'>");
    if($ies_tip_docto=="NF")
    {
     $den_docto="Nota Fiscal";
    }elseif($ies_tip_docto=="DP"){
     $den_docto="Duplicata";
    }elseif($ies_tip_docto=="GR"){
     $den_docto="Geral";
    }elseif($ies_tip_docto=="BC"){
     $den_docto="Bonif.Constr.";
    }elseif($ies_tip_docto=="AC"){
     $den_docto="Adiant.Comis.";
    }elseif($ies_tip_docto=="CP"){
     $den_docto="Complemento";
    }elseif($ies_tip_docto=="EI"){
     $den_docto="Estorno Inden.";
    }elseif($ies_tip_docto=="EF"){
     $den_docto="Frete";
    }elseif($ies_tip_docto=="EG"){
     $den_docto="GNRE";
    }else{
     $den_docto="Selecione Tipo";
    }
    printf("<option value=$ies_tip_docto selected >".$den_docto."</option>");
    printf("<option value='NF'>Nota Fiscal</option>");
    printf("<option value='DP'>Duplicata</option>");
    printf("<option value='GR'>Geral</option>");
    printf("<option value='BC'>Bonif.Constr.</option>");
    printf("<option value='AC'>Adiant.Comis.</option>");
    printf("<option value='EI'>Estorno Inden.</option>");
    printf("<option value='CP'>Complemento</option>");
    printf("<option value='EF'>Frete</option>");
    printf("<option value='EG'>GNRE</option>");
    printf("</select>  </td>" );
    printf("
     </td> 
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Cliente:</font></b>
     </td>
     <td width='40'  style=$n_style colspan='4'     align='left'>
       <input type='text' name='cod_cliente' value='".$cod_cliente."' size='15' maxlenght='15' > 
      </td>
     <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Mes:</font></b>
     </td>
     <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='mes_ref' value='".$mes_ref."' size='2' maxlenght='2' > 
      </td>
     <td width='10'  style=$n_style colspan='1'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Ano:</font></b>
     </td>
     <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='ano_ref' value='".$ano_ref."' size='4' maxlenght='4' > 
      </td>
     </tr><tr>
     <td width='30'  style=$n_style colspan='3'      align='left'>
        <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Num.NFF:</font></b>
     </td>
     <td width='40'  style=$n_style colspan='4'     align='left'>
       <input type='text' name='num_nff' value='".$num_nff."' size='10' maxlenght='16' > 
      </td>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Num.DP:</font></b>
     </td>
     <td width='50'  style=$n_style colspan='5'     align='left'>
       <input type='text' name='num_docum' value='".$num_docum."'
       size='10' maxlenght='16' > 
      </td>
     <td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Dat.DCTO:</font></b>
     </td>
     <td width='50'  style=$n_style colspan='5'     align='left'>
       <input type='text' name='dat_emissao' value='".$dat_emissao."'
       size='10' maxlenght='10' > 
      </td>
     </tr>
     <tr>
     <td width='30'  style=$n_style colspan='3'      align='left'>
        <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       VL.Merc:</font></b>
     </td>
     <td width='40'  style=$n_style colspan='4'     align='left'>
       <input type='text' name='val_tot_mercadoria'  value='".$val_tot_mercadoria."'
      size='15' maxlenght='16' > 
      </td>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       VL.Docto:</font></b>
     </td>
     <td width='40'  style=$n_style colspan='4'     align='left'>
       <input type='text' name='val_tot_docum' value='".$val_tot_docum."' 
        size='15' maxlenght='16' > 
      </td>
     </tr><tr>
     <td width='30'  style=$n_style colspan='3'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       OBS:</font></b>
     </td>
     <td width='250'  style=$n_style colspan='25'     align='left'>
       <input type='text' name='observacao' value='".$observacao."' size='60' maxlenght='60' > 
      </td>   
    </tr><tr><td width='40'  style=$n_style colspan='4'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Supervisor:</font></b>
    </td>
    <td width='30'  style=$n_style colspan='3'     align='left'>
       <input type='text' name='cod_supervisor' value='".$cod_supervisor."' size='3' maxlenght='3' > 
      </td>   
 ");

   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='".$empresa."' name='cod_empresa' size='1' maxlenght='1' readonly> 
    </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$ies_tip_docto."'
     name='ies_tip_docto_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$mes_ref."' name='mes_ref_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$ano_ref."' name='ano_ref_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$num_nff."' name='num_nff_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$num_docum."' name='num_docum_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$dat_emissao."' name='dat_emissao_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$cod_cliente."' name='cod_cliente_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$val_tot_mercadoria."' 
name='val_tot_mercadoria_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$val_tot_docum."' name='val_tot_docum_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$observacao."' name='observacao_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$cod_repres."' name='cod_repres' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$cod_supervisor."' name='cod_supervisor_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='".$tipo."' name='tipo_c' 
       size='1' maxlenght='1' readonly> 
      </td>");      
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='A' name='prog_c' size='1' maxlenght='1' readonly> 
     </td>
     </tr><tr>
    <td width='80'  style=$n_style colspan='8'      align='center'>
     <input type='submit' name='Confirmar' value='Alterar '>
     </td>
     </FORM>");




    printf("<FORM METHOD='POST' ACTION='vdp0008.php'>");
   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='".$empresa."' name='cod_empresa_c' size='1' maxlenght='1' readonly> 
    </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$ies_tip_docto."'
     name='ies_tip_docto_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$mes_ref."' name='mes_ref_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$ano_ref."' name='ano_ref_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$num_nff."' name='num_nff_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$num_docum."' name='num_docum_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$dat_emissao."' name='dat_emissao_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$cod_cliente."' name='cod_cliente_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$val_tot_mercadoria."'
name='val_tot_mercadoria_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$val_tot_docum."' name='val_tot_docum_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$observacao."' name='observacao_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$cod_supervisor."' name='cod_supervisor_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$cod_repres."' name='cod_repres' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='".$tipo."' name='tipo' 
       size='1' maxlenght='1' readonly> 
      </td>");      
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='E' name='prog_c' size='1' maxlenght='1' readonly> 
     </td>
     <td width='80'  style=$n_style colspan='8'      align='center'>
     <input type='submit' name='Confirmar' value='Excluir '>
     </td>
     </tr> 
     </FORM>");
    $mat_lanc_comis=$cfetch_row($res_lanc_comis);
   }

  }
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






