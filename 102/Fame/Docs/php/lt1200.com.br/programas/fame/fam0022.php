<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Marcelo Peres
 //Manutenção:    
 //Data manutenção:23/01/2012
 //Módulo:         Fame
 //Processo:       Cadastro de Faixas de Comissoes - Telemarketing
 //Versão:         1.0
 $versao=1;
 $prog="fame/fam0022";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0022.php'></tr>");
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
  if($fazer=='E')
  {
   $cons_faz="delete from  lt1200_faixas_comis_tlmk 
            where faixa='".$faixa_c."'
              ";

   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  if($fazer=='I')
  {
   $cons_faz="insert into  lt1200_faixas_comis_tlmk (
          faixa,pct_ini,pct_fin,pct_sal)
        values ('".$faixa."','".$pct_ini."','".$pct_fin."','".$pct_sal."')";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  if($fazer=='A')
  {
   $cons_faz="update  lt1200_faixas_comis_tlmk set
                         pct_ini='".$pct_ini."',
                         pct_fin='".$pct_fin."',
                         pct_sal='".$pct_sal."'
                     where faixa='".$faixa_c."' ";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }


  $selec_faixa="select  *
                        from lt1200_faixas_comis_tlmk a
                       order by faixa
                   ";
  $res_faixa = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_faixa = $cquery($selec_faixa,$res_faixa);
  $mat_faixa=$cfetch_row($result_faixa);

  printf("<tr>
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Faixas de Comissoes Telemarketing</font></b>
      </td>
     </tr>
     <tr>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Faixa</font></b>
      </td>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Inicio</font></b>
      </td>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Fim</font></b>
      </td>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Variável</font></b>
      </td>
     </tr>
     ");

  printf("<FORM METHOD='POST' ACTION='fam0022.php'>");
  printf("</tr>
      <tr>
      <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='faixa'  size='8' maxlenght='8'>  
      </td>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='pct_ini'  size='8' maxlenght='8'>  
      </td>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='pct_fin'  size='8' maxlenght='8'>  
      </td>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='pct_sal'  size='8' maxlenght='8'>  
      </td>

      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Incluir '>
      </td>
     </tr> 
     </FORM>");

  while (is_array($mat_faixa))
  {
   printf("<FORM METHOD='POST' ACTION='fam0022.php'>");
   printf("<tr>

      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='faixa' value='".$mat_faixa["faixa"]."'
       size='8' maxlenght='8'>
      </td>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='pct_ini' value='".$mat_faixa["pct_ini"]."'
       size='8' maxlenght='8'>
      </td>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='pct_fin' value='".$mat_faixa["pct_fin"]."'
       size='8' maxlenght='8'>
      </td>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='pct_sal' value='".$mat_faixa["pct_sal"]."'
       size='8' maxlenght='8'>
      </td>

      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='faixa_c' size='10' maxlenght='10'
       value='".$mat_faixa["faixa"]."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='A' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     <td width='10'  style=$n_style colspan='1'      align='center'>
       <input type='submit' name='Confirmar' value='Alterar '>
      </td>
     </FORM>");

   printf("<FORM METHOD='POST' ACTION='fam0022.php'>");
   printf("
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='faixa_c' size='10' maxlenght='10'
       value='".$mat_faixa["faixa"]."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='E' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Excluir '>
      </td>
     </tr> 
     </FORM>");
   $mat_faixa=$cfetch_row($result_faixa);
  }
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






