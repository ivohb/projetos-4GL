<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manuten��o:    
 //Data manuten��o:21/06/2005
 //M�dulo:         VDP
 //Processo:       Encerrar Periodo de Comissoes
 //Vers�o:         1.0
 $prog="vdp/vdp0009";
 $versao="1";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 include("../../bibliotecas/autentica.inc");
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");

 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $data_ref=sprintf("%02d/%02d/%04d",$dia_ref,$mes_ref,$ano_ref);
 $datah=sprintf("%04d-%02d-%02d",$ano_ref,$mes_ref,$dia_ref);
 $datah=chop($datah)." 00:00:00";
 if($nome_<>"")
 {
  if($prog_c=="P")
  {
   if($tipo=="F")
   {
    $sit="sit_func";
   }elseif($tipo=="R"){
    $sit="sit_rep";
   }elseif($tipo=="A"){
    $sit="sit_aut";
   }elseif($tipo=="C"){
    $sit="sit_fr";
   }
   $teste=1;
   if($teste==1)
   {
     $sel_repres1='and d.cod_repres=b.cod_repres';
     $sel_tipo1="and f.tipo='".$tipo."' "; 
     $t_canal_vendas1='and g.cod_nivel_3=d.cod_repres and g.cod_nivel_4=0';
     $sel_repres='and d.cod_repres=b.cod_repres';
     $sel_tipo="and f.tipo='".$tipo."' "; 
     $t_canal_vendas='and g.cod_nivel_4=d.cod_repres ';
    if($tipo=="F" or $tipo=="C" or $tipo=="S")
    {
     $sel_sal=',h.salario';
     $tab_sal=',fun_salario h';
     $selec_sal='and h.cod_empresa=f.cod_empresa and
              h.num_matricula=f.num_matricula';
    }else{
     $sel_sal='';
     $tab_sal='';
     $selec_sal='';
    }
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);
  $consulta="  
               SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao,
                  b.num_pedido,b.num_pedido_repres,b.dat_pedido,b.dat_emis_repres,
                  c.cod_cliente,c.nom_cliente,c.end_cliente,
                  c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                  c.num_telefone as fone_cli, c.num_fax as fax_cli,
                  c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                  g.cod_nivel_3 as cod_repres,d.raz_social,d.num_telefone as fone_rep,
                  e.sit_func,e.sit_rep,e.sit_aut,e.sit_fr,
                  z.cota,f.pct_nff,f.pct_dp,f.ind,
                  f.fixo,f.teto,f.num_matricula,f.cod_empresa,
                  g.cod_nivel_4,g.cod_nivel_3
                  $sel_sal,
                  0,f.nivel
             from lt1200:lt1200_comissoes b,     
                  clientes c,
                  representante d,
                  lt1200:lt1200_ctr_comis e,
                  lt1200:lt1200_representante f,
                  canal_venda g
		  $tab_sal
                  , lt1200:lt1200_cota_mes z 
 
             where
               b.cod_empresa='".$empresa."'
               and b.mes_ref='".$mes_ref."'
               and b.ano_ref='".$ano_ref."'
               and c.cod_cliente=b.cod_cliente
               and e.mes_ref=b.mes_ref
               and e.ano_ref=b.ano_ref
               and e.cod_empresa=b.cod_empresa 
               and b.ies_tip_docto in ('DP','NF')               
               and g.cod_nivel_4=b.cod_repres 
               and d.cod_repres=g.cod_nivel_3
               and f.cod_repres=g.cod_nivel_3
               and f.tipo='".$tipo."'  
               and h.cod_empresa=f.cod_empresa 
               and h.num_matricula=f.num_matricula
               and z.cod_repres=g.cod_nivel_3
               and z.mes_ref=b.mes_ref
               and z.ano_ref=b.ano_ref

union
               SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao,
                  b.num_pedido,b.num_pedido_repres,b.dat_pedido,b.dat_emis_repres,
                  c.cod_cliente,c.nom_cliente,c.end_cliente,
                  c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                  c.num_telefone as fone_cli, c.num_fax as fax_cli,
                  c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                  g.cod_nivel_3 as cod_repres,d.raz_social,d.num_telefone as fone_rep,
                  e.sit_func,e.sit_rep,e.sit_aut,e.sit_fr,
                  z.cota,f.pct_nff,f.pct_dp,f.ind,
                  f.fixo,f.teto,f.num_matricula,f.cod_empresa,
                  g.cod_nivel_4,g.cod_nivel_3
                  $sel_sal,
                  0,f.nivel
             from lt1200:lt1200_comissoes b,     
                  clientes c,
                  representante d,
                  lt1200:lt1200_ctr_comis e,
                  lt1200:lt1200_representante f,
                  canal_venda g
		  $tab_sal
                  , lt1200:lt1200_cota_mes z 
 
             where
               b.cod_empresa='".$empresa."'
               and b.mes_ref='".$mes_ref."'
               and b.ano_ref='".$ano_ref."'
               and c.cod_cliente=b.cod_cliente
               and e.mes_ref=b.mes_ref
               and e.ano_ref=b.ano_ref
               and e.cod_empresa=b.cod_empresa 
               and b.ies_tip_docto in ('DP','NF')               
               and g.cod_nivel_3=b.cod_repres
               and g.cod_nivel_4=0 
               and d.cod_repres=g.cod_nivel_3
               and f.cod_repres=g.cod_nivel_3
               and f.tipo='".$tipo."'  
               and h.cod_empresa=f.cod_empresa 
               and h.num_matricula=f.num_matricula
               and z.cod_repres=g.cod_nivel_3
               and z.mes_ref=b.mes_ref
               and z.ano_ref=b.ano_ref


          order by 25,2 desc,1 desc ,3,5 ";


    $res = $cconnect("logix",$ifx_user,$ifx_senha);
    $result2 = $cquery($consulta,$res);
    $mat=$cfetch_row($result2);
    $nf_ant="0"; 
    $nf_atu=$mat["num_nff"]; 
    $val_nf=0;
    $val_dp=0;
    $rep_atu=$mat["cod_repres"];
    $rep_ant="";
    $raz_atu=$mat["raz_social"];
    $nivel_atu=$mat["nivel"];
    while (is_array($mat))
    {
     $zona=$mat["zona"];
     $num_ped_logix=round($mat["num_pedido"]);
     $num_ped_rep=round($mat["num_pedido_repres"]);
     $dat_emis=$mat["dat_pedido"];
     $dat_emis_rep=$mat["dat_emis_repres"];
     $salario=$mat["salario"];
     if($rep_ant<>$rep_atu)
     {
      $raz_atu=$mat["raz_social"];
      $matricula=$mat["num_matricula"];
     } 
     $tipo_docto=chop($mat["ies_tip_docto"]);
     $num_nff=round($mat["num_nff"]);
     $emp_nff=chop($mat["emp_nff"]);
     if(chop($mat["ies_tip_docto"])=='NF')
     {
      $val_nf=$val_nf+$mat["val_tot_mercadoria"];
      $val_nf_t=$val_nf_t+$mat["val_tot_mercadoria"];
     }else{
      $val_dp=$val_dp+$mat["val_tot_mercadoria"];
      $val_dp_t=$val_dp_t+$mat["val_tot_mercadoria"];
     }
     $rep_ant=$mat["cod_repres"];
     $fixo=$mat["fixo"];
     $sup_ant=$mat["cod_nivel_3"];
     $raz_ant=$mat["raz_social"];
     $cota=$mat["cota"];
     $pct_nff=$mat["pct_nff"];
     $pct_dp=$mat["pct_dp"];
     $teto=$mat["teto"];
     $matricula=chop($mat["num_matricula"]);
     $empresa=chop($mat["cod_empresa"]);
     $tipo_ant=$mat["ies_tipo_lancto"];
     $ind=$mat["ind"];
     if(chop($mat["nivel"])=="G")
     {
      $gestor="S";
     }else{
      $gestor="N";
     }
     
     $nivel_ant=chop($mat["nivel"]);
     $rep_ant=$mat["cod_repres"];
     $mat=$cfetch_row($result2);
     $nivel_atu=$mat["nivel"];
     $tipo_atu=$mat["ies_tipo_lancto"];
     $raz_atu=$mat["raz_social"];
     $rep_atu=$mat["cod_repres"];
     if($rep_ant<>$rep_atu)
     {
      if($tipo=="F" or  $tipo=="S")
      {
       if($cota==0)
       {
        $pct_alcancado=0;
       }else{
        $pct_alcancado=round((($val_nf*100)/$cota));
        $pct_imprime=$pct_alcancado;
       }
       if($gestor=="S")
       {
        $pct_alc=round($pct_alcancado);     
        $pct_imprime=$pct_alcancado;
        $cons_faixa="SELECT *
                 from lt1200_faixas_comis a
                where '".$pct_alc."' between  a.pct_ini and a.pct_fin
                 " ;
        $res_faixa = $cconnect("lt1200",$ifx_user,$ifx_senha);
        $result_faixa = $cquery($cons_faixa,$res_faixa);
        $mat_faixa=$cfetch_row($result_faixa);
        $pct_sal=$mat_faixa["pct_sal"];
        $pct_alcancado=$pct_sal;
       }else{
        if($pct_alcancado < $pct_nff)
        {
         $pct_alcancado=0;
        }
       }
       $sal_alcancado=($salario*$pct_alcancado/100);
       if($ind=="S")
       {
        $val_ind=($sal_alcancado/12);
       }
      }
      if($tipo=="R" or $tipo=="A" or $tipo=="C")
      {
       $val_com_nff=($val_nf*$pct_nff/100);
       $val_com_dp=($val_dp*$pct_dp/100);
       $val_tot_com=$val_com_nff+$val_com_dp;
       $sal_alcancado=$val_tot_com;
       if($ind=="S")
       {
        $val_ind=($sal_alcancado/12);
       }
      }


      if($gestor=="S")
      {
       $pct_alcancado=$pct_alc;
      }

      $ano_mes=sprintf("%04d-%02d",$ano_ref,$mes_ref);

      if($nivel_ant=="S" or $nivel_ant=="s")
      {
       $insert_hist="insert into lt1200_hist_comis 
                 (mes_ref,ano_ref,cod_repres,tipo,cod_empresa,num_matricula,
                  pct_nff,pct_dp,salario,fixo,cota,val_merc_nff,val_merc_dp,
                  cod_supervisor,pct_alcancado,valor_comissao,outros,indenizacao,
                  sal_bruto,sal_liquido,dsr,encargos,despesas,zona,ano_mes_ref)
                  values('".$mes_ref."','".$ano_ref."','".$rep_ant."',
                         '".$tipo."','".$empresa."','".$matricula."',
                         '".$pct_nff."','".$pct_dp."','".$salario."',
                         '".$fixo."','".$cota."','".$val_nf."','".$val_dp."',
                         '".$sup_ant."','".$pct_imprime."','".$sal_alcancado."',
                         '".$val_extra."','".$val_ind."',
                         0,0,0,0,0,'".$zona."','".$ano_mes."')       ";

      $res_hist_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
      $result_hist_comis = $cquery($insert_hist,$res_hist_comis);
     
      }

      $val_extra=0;
      $val_ind=0;
      $sal_alcancado=0;
      $val_dp=0;
      $val_nf=0;
     }
    }
   }
  }
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='acerta_comis.php'></tr>");
  include("../../bibliotecas/empresa.inc");
     printf("<td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tipo:</font></b>
     </td>
     <td width='150'  style=$n_style colspan='15'     align='left'>
      <select name='tipo'>");
      printf("<option value='' selected >Selecione Tipo</option>");
      printf("<option value='F'>Funcionario</option>");
      printf("<option value='R'>Representante</option>");
      printf("<option value='A'>Autonomo</option>");
      printf("<option value='C'>Func.Repre</option>");
      printf("</select>
     </td></tr><tr>" );

   PRINTF("</table><TABLE WIDTH=750 BORDER=0 border-style=solid bordercolor=$c_color  CELLPADDING=1 CELLSPACING=0 RULES=groups  style='page-break-after:right' >
         <tr >");

    printf("<td width='20'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Dia:</font></b>
    </td>
    <td width='20'  style=$n_style      align='left'>
       <input type='text' name='dia_ref'  size='2' maxlenght='2' > 
      </td>");
    printf("<td width='20'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Mes:</font></b>
    </td>
    <td width='20'  style=$n_style      align='left'>
       <input type='text' name='mes_ref' value='".$mes_ref."' size='2' maxlenght='2' > 
      </td>
    <td width='20'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Ano:</font></b>
    </td>
    <td width='20'  style=$n_style     align='left'>
       <input type='text' name='ano_ref' value='".$ano_ref."' size='4' maxlenght='4' > 
      </td>
");
    printf("<td width='40'   style=$n_style      align='left'>
         <input type='submit' name='Confirmar' value='Encerrar Per�odo'>
        </td>
        <td width='150'   style=$n_style     align='center'>
         <input type='reset' name='Cancelar' value='Limpar Campos'>
        </td>
       </tr>");
    printf("<td width='0'  style=$n_style colspan='1'     align='left'>
     <input type='hidden' value='P' name='prog_c' size='1' maxlenght='1' readonly> 
     </td>
      </FORM>");

         PRINTF("<TABLE WIDTH=750 BORDER=1 border-style=solid bordercolor=$c_color  CELLPADDING=1 CELLSPACING=0 RULES=groups  style='page-break-after:right' >
         <tr >
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         <td width='10' style=$n_style height=1 ></td>
         </tr>");
   $cons_ctr_comis="select * 
                     from lt1200_ctr_comis
                    order by cod_empresa,ano_ref desc,mes_ref desc ";

   $res_ctr_comis = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_ctr_comis = $cquery($cons_ctr_comis,$res_ctr_comis);
   $mat_ctr_comis=$cfetch_row($result_ctr_comis);

    printf("</tr><tr><td width='30'  style=$n_style colspan='3'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          EMP</font></i>
      </td>");
    printf("<td width='70'  style=$n_style colspan='7'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          MES</font></i>
      </td>");
    printf("<td width='100'  style=$n_style colspan='10'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          FUNC</font></i>
      </td>");
    printf("<td width='100'  style=$n_style colspan='10'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          REPRES</font></i>
      </td>");
    printf("<td width='100'  style=$n_style colspan='10'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          FUN/REP</font></i>
      </td>");
    printf("<td width='100'  style=$n_style colspan='10'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          AUTONOMOS</font></i>
      </td>");
 
   while (is_array($mat_ctr_comis))
   {
    $cod_empresa=$mat_ctr_comis["cod_empresa"];
    $mes_ano_ref=$mat_ctr_comis["mes_ref"].'/'.$mat_ctr_comis["ano_ref"];
    $sit_func=chop($mat_ctr_comis["sit_func"]);
    $sit_rep=chop($mat_ctr_comis["sit_rep"]);
    $sit_fr=chop($mat_ctr_comis["sit_fr"]);
    $sit_aut=chop($mat_ctr_comis["sit_aut"]);

    if($sit_func=="F")
    {
     $sit_func="Fechado";
    }elseif($sit_func=="G"){
     $sit_func="Gerado";
    }else{
     $sit_func="Aberto";
    } 
    if($sit_rep=="F")
    {
     $sit_rep="Fechado";
    }elseif($sit_rep=="G"){
     $sit_rep="Gerado";
    }else{
     $sit_rep="Aberto";
    } 
    if($sit_fr=="F")
    {
     $sit_fr="Fechado";
    }elseif($sit_fr=="G"){
     $sit_fr="Gerado";
    }else{
     $sit_fr="Aberto";
    } 
    if($sit_aut=="F")
    {
     $sit_aut="Fechado";
    }elseif($sit_aut=="G"){
     $sit_aut="Gerado";
    }else{
     $sit_aut="Aberto";
    } 
    
   
    printf("</tr><tr><td width='30'  style=$n_style colspan='3'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $cod_empresa</font></i>
      </td>");
    printf("<td width='70'  style=$n_style colspan='7'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $mes_ano_ref</font></i>
      </td>");
    printf("<td width='100'  style=$n_style colspan='10'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $sit_func</font></i>
      </td>");
    printf("<td width='100'  style=$n_style colspan='10'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $sit_rep</font></i>
      </td>");
    printf("<td width='100'  style=$n_style colspan='10'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $sit_fr</font></i>
      </td>");
    printf("<td width='100'  style=$n_style colspan='10'     align='left'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          $sit_aut</font></i>
      </td>");
    $mat_ctr_comis=$cfetch_row($result_ctr_comis);
   }

 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>