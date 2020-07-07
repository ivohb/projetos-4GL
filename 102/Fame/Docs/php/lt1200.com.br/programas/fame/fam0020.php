<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Módulo:         VDP
 //Processo:       Manutenção Custo Operacional Vendedor
 $versao=1;
 $prog="fame/fam0020";
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

  $salario=str_replace(".","",$salario);
  $cota=str_replace(".","",$cota);
  $val_merc_nff=str_replace(".","",$val_merc_nff);
  $valor_comissao=str_replace(".","",$valor_comissao);
  $sal_bruto=str_replace(".","",$sal_bruto);
  $sal_liquido=str_replace(".","",$sal_liquido);
  $dsr=str_replace(".","",$dsr);
  $encargos=str_replace(".","",$encargos);
  $despesas=str_replace(".","",$despesas);

  $salario=str_replace(",",".",$salario);
  $cota=str_replace(",",".",$cota);
  $val_merc_nff=str_replace(",",".",$val_merc_nff);
  $valor_comissao=str_replace(",",".",$valor_comissao);
  $sal_bruto=str_replace(",",".",$sal_bruto);
  $sal_liquido=str_replace(",",".",$sal_liquido);
  $dsr=str_replace(",",".",$dsr);
  $encargos=str_replace(",",".",$encargos);
  $despesas=str_replace(",",".",$despesas);


  if($fazer=='I')
  {
   $cons_zona="select codhie from vnempre
                where cdclierp='".$cod_repres."'
                  and cdrelac='7' ";
   $res_zona = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_zona = $cquery($cons_zona,$res_zona);
   $mat_zona=$cfetch_row($result_zona);
   $zona=trim($mat_zona["codhie"]);

    $cons_faz="insert into  lt1200_hist_comis
            (mes_ref,ano_ref,
             cod_repres,tipo,cod_empresa,num_matricula,salario,
             cota,val_merc_nff,cod_supervisor,valor_comissao,sal_bruto,
             sal_liquido,dsr,encargos,despesas,zona)

        values ('".$mes_ref."','".$ano_ref."','".$cod_repres."',
                '".$tipo."','".$cod_empresa."','".$num_matricula."',
                '".$salario."','".$cota."','".$val_merc_nff."',
                '".$cod_supervisor."','".$valor_comissao."',
                '".$sal_bruto."','".$sal_liquido."','".$dsr."',
                '".$encargos."','".$despesas."','".$zona."')";
    $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_faz = $cquery($cons_faz,$res_faz);
    $prog_c="V";
    $fazer="V";
  }
  if($fazer=='A')
  {
    $cons_faz="update  lt1200_hist_comis
            set cota='".$cota."',val_merc_nff='".$val_merc_nff."',
                sal_bruto='".$sal_bruto."',sal_liquido='".$sal_liquido."',
                salario ='".$salario."',valor_comissao='".$valor_comissao."',
                dsr='".$dsr."',encargos='".$encargos."',
                despesas='".$despesas."',zona='".$zona."'

            where cod_repres='".$cod_repres."'
                and mes_ref='".$mes_ref_c."'
                and ano_ref='".$ano_ref_c."'
                 ";
    $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_faz = $cquery($cons_faz,$res_faz);
    $prog_c="V";
    $fazer="V";
  }

  if($fazer=='E')
  {
    $cons_faz="delete from   lt1200_hist_comis
            where cod_repres='".$cod_repres."'
                and mes_ref='".$mes_ref_c."'
                and ano_ref='".$ano_ref_c."' ";


    $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_faz = $cquery($cons_faz,$res_faz);
    $prog_c="V";
    $fazer="V";
  }




  if($fazer=="N")
  {

   $ajuste_val="select cod_repres,mes_ref,ano_ref,cod_empresa,num_matricula
                   from lt1200_hist_comis
               where sal_bruto is null
                 and sal_liquido is null
                 and dsr is null
                 and encargos is null
             order by 1";
    $res_ajuste = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_ajus = $cquery($ajuste_val,$res_ajuste);
    $mat_ajuste=$cfetch_row($result_ajus);
    while (is_array($mat_ajuste))
    {
     $ano_ref=$mat_ajuste["ano_ref"];
     $mes_ref=$mat_ajuste["mes_ref"];
     $dat_ref=sprintf("%04d-%02d",$ano_ref,$mes_ref);
     $empresa_ref=$mat_ajuste["cod_empresa"];
     $matricula_ref=round($mat_ajuste["num_matricula"]);
     $cod_repres_ref=round($mat_ajuste["cod_repres"]);   
     $sel_ajuste="select sum(val_evento) as valor
                 from hist_movto 
                  where cod_empresa='".$empresa_ref."'
                      and num_matricula='".$matricula_ref."'
                      and dat_referencia='".$dat_ref."'
                      and cod_evento between '1' and '99' ";
     $res_ajuste = $cconnect("logix",$ifx_user,$ifx_senha);
     $result_ajuste = $cquery($sel_ajuste,$res_ajuste);
     $mat_ajuste=$cfetch_row($result_ajuste);
     $bruto=$mat_ajuste["valor"]; 

     $sel_ajuste="select sum(val_evento) as valor
                 from hist_movto 
                  where cod_empresa='".$empresa_ref."'
                      and num_matricula='".$matricula_ref."'
                      and dat_referencia='".$dat_ref."'
                      and cod_evento between '100' and '199' ";
     $res_ajuste = $cconnect("logix",$ifx_user,$ifx_senha);
     $result_ajuste = $cquery($sel_ajuste,$res_ajuste);
     $mat_ajuste=$cfetch_row($result_ajuste);
     $descontos=$mat_ajuste["valor"]; 

     $sel_ajuste="select sum(val_evento) as valor
                 from hist_movto 
                  where cod_empresa='".$empresa_ref."'
                      and num_matricula='".$matricula_ref."'
                      and dat_referencia='".$dat_ref."'
                      and cod_evento ='42' ";
     $res_ajuste = $cconnect("logix",$ifx_user,$ifx_senha);
     $result_ajuste = $cquery($sel_ajuste,$res_ajuste);
     $mat_ajuste=$cfetch_row($result_ajuste);
     $dsr=$mat_ajuste["valor"]; 

     $sel_ajuste="select sum(val_evento) as valor
                 from hist_movto 
                  where cod_empresa='".$empresa_ref."'
                      and num_matricula='".$matricula_ref."'
                      and dat_referencia='".$dat_ref."'
                      and cod_evento in ('900','901','902','906','907','908') ";
     $res_ajuste = $cconnect("logix",$ifx_user,$ifx_senha);
     $result_ajuste = $cquery($sel_ajuste,$res_ajuste);
     $mat_ajuste=$cfetch_row($result_ajuste);
     $encargos=$mat_ajuste["valor"]; 
    
     $liquido=$bruto-$descontos;
     $aplic_ajuste="update lt1200_hist_comis
                     set sal_bruto='".$bruto."',
                         sal_liquido='".$liquido."',
                         dsr='".$dsr."',
                         encargos='".$encargos."'
                     where mes_ref='".$mes_ref."'
                           and ano_ref='".$ano_ref."'
                           and cod_repres='".$cod_repres_ref."' ";
     $res_ajuste = $cconnect("lt1200",$ifx_user,$ifx_senha);
     $result_ajuste = $cquery($aplic_ajuste,$res_ajuste);

     $mat_ajuste=$cfetch_row($result_ajus);
    }


   $ajuste_dat="select cod_repres,mes_ref,ano_ref
                   from lt1200_hist_comis
               where ano_mes_ref is null
             order by 1";
    $res_ajuste = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_ajus = $cquery($ajuste_dat,$res_ajuste);
    $mat_ajuste=$cfetch_row($result_ajus);
    while (is_array($mat_ajuste))
    {
     $ano_ref=$mat_ajuste["ano_ref"];
     $mes_ref=$mat_ajuste["mes_ref"];
     $ano_mes_ref=sprintf("%04d-%02d",$ano_ref,$mes_ref);
     $cod_repres_ref=round($mat_ajuste["cod_repres"]);   
     $aplic_ajuste="update lt1200_hist_comis
                     set ano_mes_ref='".$ano_mes_ref."'
                     where mes_ref='".$mes_ref."'
                           and ano_ref='".$ano_ref."'
                           and cod_repres='".$cod_repres_ref."' ";
     $res_ajuste = $cconnect("lt1200",$ifx_user,$ifx_senha);
     $result_ajuste = $cquery($aplic_ajuste,$res_ajuste);
     $mat_ajuste=$cfetch_row($result_ajus);
    }
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
                        

                     order by 15,14,3
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
   $cod_supervisor=round($mat_rep["cod_nivel_3"]); 
   $raz_rep=$mat_rep["raz_social"];
   printf("<FORM METHOD='POST' ACTION='fam0020.php'>");
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
       <input type='hidden' value='".$cod_supervisor."' name='cod_supervisor' 
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
       <input type='submit' name='Confirmar' value='Lançamentos'>
       </td>");
      }
     printf("</tr> 
     </FORM>");
    $mat_rep=$cfetch_row($result_rep);
   }
  }


  if($fazer=="V")
  {
   printf("<FORM METHOD='POST' ACTION='fam0020.php'>");
   $selec_comis="select unique a.cod_repres,a.raz_social,b.cod_empresa,
                        b.num_matricula,b.tipo
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
   $cod_empresa=chop($mat_comis["cod_empresa"]);
   $num_matricula=chop($mat_comis["num_matricula"]);
   $tipo=chop($mat_comis["tipo"]);

   printf("</tr></table><table border=1>
            <tr>
      <td width='750'  style=$n_style      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Representante:$raz_social</font></b>
      </td>
     </tr></table><table border=1><tr>
      <td width='60'  style=$n_style     align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Mes/ano:</font></b>
      </td>
     <td width='35'  style=$n_style      align='left'>
       <input type='text' name='mes_ref' value='".$mes_ref."'
	size='2' maxlenght='2' > 
      </td> 
     <td width='65'  style=$n_style      align='left'>
       <input type='text' name='ano_ref' value='".$ano_ref."' size='4'
	maxlenght='4' > </td> 
      <td width='60'  style=$n_style       align='right'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Cota:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='cota' value='".$cota."'
	size='12' maxlenght='20' > 
      </td>
      <td width='60'  style=$n_style       align='right'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Fatur:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='val_merc_nff' value='".$val_merc_nff."'
	size='12' maxlenght='20' > 
      </td>
     </tr><tr>

");
      printf("<td width='70'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Bruto:</font></b>
      </td>
     <td width='120'  colspan=2 style=$n_style      align='left'>
       <input type='text' name='sal_bruto' value='".$sal_bruto."'
	size='12' maxlenght='20' > 
      </td>
     <td width='60'  style=$n_style       align='right'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Liquido:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='sal_liquido' value='".$sal_liquido."'
	size='12' maxlenght='20' > 
      </td>
      <td width='60'  style=$n_style       align='right'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Salario:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='salario' value='".$salario."'
	size='12' maxlenght='20' > 
      </td>
     <td width='60'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Comissão:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='valor_comissao' value='".$valor_comissao."'
	size='12' maxlenght='20' > 
      </td>
    </tr><tr>
     <td width='60'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       D.S.R.</font></b>
      </td>
     <td width='120' colspan=2 style=$n_style      align='left'>
       <input type='text' name='dsr' value='".$dsr."'
	size='12' maxlenght='20' > 
      </td>
     <td width='60'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Despesas:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='despesas' value='".$despesas."'
	size='12' maxlenght='20' > 
      </td>
     <td width='60'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Encargos:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='encargos' value='".$encargos."'
	size='12' maxlenght='20' > 
      </td>

");



    printf("<td width='80'  style=$n_style colspan='8'      align='center'>
     <input type='submit' name='Confirmar' value='Incluir '>
    </td>
   </tr> ");
   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='".$cod_repres."' name='cod_repres' size='1' maxlenght='1' readonly> 
    </td>");
   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='".$tipo."' name='tipo' 
       size='1' maxlenght='1' readonly> 
      </td>");      
   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='".$num_matricula."' name='num_matricula' size='1' maxlenght='1' readonly> 
    </td>");
   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='".$cod_empresa."' name='cod_empresa' size='1' maxlenght='1' readonly> 
    </td>");
   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='".$cod_supervisor."' name='cod_supervisor' size='1' maxlenght='1' readonly> 
    </td>");
   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='".$tipo."' name='tipo' 
       size='1' maxlenght='1' readonly> 
      </td>");      


   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
    </td>
   </FORM></TABLE><TABLE>");






   
//Alteracao

   $sel_lanc_comis="select b.mes_ref,b.ano_ref,b.cod_repres,
                           b.tipo,b.cod_empresa,b.num_matricula,
                           b.salario,b.cota,b.val_merc_nff,
                           b.valor_comissao,b.sal_bruto,b.sal_liquido,
                           b.dsr,b.encargos,b.despesas,b.zona
	    	   from 
                        lt1200_hist_comis b,
                        lt1200_representante c
                  where b.cod_repres='".$cod_repres."' 
                        and c.cod_repres=b.cod_repres                      

                        order  by ano_ref desc ,mes_ref desc 
                                           ";
   $link=$cconnect("lt1200",$ifx_user,$ifx_senha);
   $res_lanc_comis=$cquery($sel_lanc_comis,$link);
   $mat_lanc_comis=$cfetch_row($res_lanc_comis);

   while (is_array($mat_lanc_comis))
   {
    $mes_ref=$mat_lanc_comis["mes_ref"];
    $ano_ref=$mat_lanc_comis["ano_ref"];
    $cod_repres=$mat_lanc_comis["cod_repres"];
    $tipo=$mat_lanc_comis["tipo"]; 
    $cod_empresa=$mat_lanc_comis["cod_empresa"];
    $num_matricula=$mat_lanc_comis["num_matricula"];
    $salario=number_format($mat_lanc_comis["salario"],2,",",".");
    $cota=number_format($mat_lanc_comis["cota"],2,",",".");
    $val_merc_nff=number_format($mat_lanc_comis["val_merc_nff"],2,",",".");
    $valor_comissao=number_format($mat_lanc_comis["valor_comissao"],2,",",".");
    $sal_bruto=number_format($mat_lanc_comis["sal_bruto"],2,",",".");
    $sal_liquido=number_format($mat_lanc_comis["sal_liquido"],2,",",".");
    $dsr=number_format($mat_lanc_comis["dsr"],2,",",".");
    $encargos=number_format($mat_lanc_comis["encargos"],2,",",".");
    $despesas=number_format($mat_lanc_comis["despesas"],2,",",".");
    $zona=$mat_lanc_comis["zona"];
    printf("<FORM METHOD='POST' ACTION='fam0020.php'>");
     printf("</tr></table><table border=1>
            <tr>
      <td width='750'  style=$n_style      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Representante:$raz_social</font></b>
      </td>
     </tr></table><table border=1><tr>
      <td width='60'  style=$n_style     align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Mes/ano:</font></b>
      </td>
     <td width='35'  style=$n_style      align='left'>
       <input type='text' name='mes_ref' value='".$mes_ref."'
	size='2' maxlenght='2' > 
      </td> 
     <td width='65'  style=$n_style      align='left'>
       <input type='text' name='ano_ref' value='".$ano_ref."' size='4'
	maxlenght='4' > </td> 
      <td width='60'  style=$n_style       align='right'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Cota:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='cota' value='".$cota."'
	size='12' maxlenght='20' > 
      </td>
      <td width='60'  style=$n_style       align='right'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Fatur:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='val_merc_nff' value='".$val_merc_nff."'
	size='12' maxlenght='20' > 
      </td>
     </tr><tr>

");

      printf("<td width='70'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Bruto:</font></b>
      </td>
     <td width='120'  colspan=2 style=$n_style      align='left'>
       <input type='text' name='sal_bruto' value='".$sal_bruto."'
	size='12' maxlenght='20' > 
      </td>
     <td width='60'  style=$n_style       align='right'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Liquido:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='sal_liquido' value='".$sal_liquido."'
	size='12' maxlenght='20' > 
      </td>
      <td width='60'  style=$n_style       align='right'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Salario:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='salario' value='".$salario."'
	size='12' maxlenght='20' > 
      </td>
     <td width='60'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Comissão:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='valor_comissao' value='".$valor_comissao."'
	size='12' maxlenght='20' > 
      </td>
    </tr><tr>
     <td width='60'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       D.S.R.</font></b>
      </td>
     <td width='120' colspan=2 style=$n_style      align='left'>
       <input type='text' name='dsr' value='".$dsr."'
	size='12' maxlenght='20' > 
      </td>
     <td width='60'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Despesas:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='despesas' value='".$despesas."'
	size='12' maxlenght='20' > 
      </td>
     <td width='60'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Encargos:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='encargos' value='".$encargos."'
	size='12' maxlenght='20' > 
      </td>
     <td width='60'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Zona:</font></b>
      </td>
     <td width='120'  style=$n_style      align='left'>
       <input type='text' name='zona' value='".$zona."'
	size='12' maxlenght='20' > 
      </td>
           ");
   printf("<td width='0'  style=$n_style colspan='1'     align='left'>
    <input type='hidden' value='".$empresa."' name='cod_empresa' size='1' maxlenght='1' readonly> 
    </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$mes_ref."' name='mes_ref_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$ano_ref."' name='ano_ref_c' size='1' maxlenght='1' readonly> 
     </td>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='".$cod_repres."' name='cod_repres' size='1' maxlenght='1' readonly> 
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

    printf("<FORM METHOD='POST' ACTION='fam0020.php'>");
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






