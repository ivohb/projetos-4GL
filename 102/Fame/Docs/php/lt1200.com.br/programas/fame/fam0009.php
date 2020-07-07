<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:22/08/2005
 //Módulo:         Fame
 //Processo:       Envio para Faturamento
 //Versão:         1.0
 $versao=1;
 $prog="fame/fam0009";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0009.php'></tr>");
  include("../../bibliotecas/autentica.inc");
  if($prog_c=="I")
  {
   $fazer="I";
  }elseif($prog_c=="E")
  {
   $fazer="E";
  }else{
   $fazer="N";
  }
  if($fazer=='E')
  {
   $cons_faz="delete from  lt1200_ctr_om
            where cod_empresa='".$empresa."'
             and num_om='".$num_om."'
              ";

   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
   $fazer='N';
  }
  if($fazer=='I')
  {
   $cons_faz="insert into  lt1200_ctr_om (
          cod_empresa,num_om,local)
        values ('".$empresa."','".$num_om."','FAT')";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
   $fazer='N';
  }

  $selec_ordens="select  *
                        from lt1200_ctr_om a,
                             logix:ordem_montag_mest b
                        where b.cod_empresa=a.cod_empresa
                          and b.num_om=a.num_om
                          and ies_sit_om <> 'F' 
                       order by a.cod_empresa,a.num_om
                   ";
  $res_ordens = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_ordens = $cquery($selec_ordens,$res_ordens);
  $mat_ordens=$cfetch_row($result_ordens);

  printf("<tr>
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Envio para  Faturamento</font></b>
      </td>
     ");

  printf("<FORM METHOD='POST' ACTION='fam0009.php'>");
  printf("</tr><tr>");
  include("../../bibliotecas/empresa.inc");
  printf("
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       OM</font></b>
      </td>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='num_om'  size='8' maxlenght='8'>  
      </td>
      <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Incluir '>
      </td>
     </tr> 
     </FORM>");

  while (is_array($mat_ordens))
  {
   printf("<FORM METHOD='POST' ACTION='fam0009.php'>");
   printf("<tr>");
   printf("<td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='empresa' size='10' maxlenght='10'
       value='".$mat_ordens["cod_empresa"]."' readonly> 
      </td>");
   printf("<td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='text' name='num_om' size='10' maxlenght='10'
       value='".round($mat_ordens["num_om"])."' readonly> 
      </td>

      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='E' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Excluir '>
      </td>
     </tr> 
     </FORM>");
   $mat_ordens=$cfetch_row($result_ordens);
  }
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






